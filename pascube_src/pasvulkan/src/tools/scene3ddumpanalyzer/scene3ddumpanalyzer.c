/*
 * scene3ddumpanalyzer -- offline analyzer for Scene3D debug dumps.
 *
 * Reads the .bin dumps produced by PasVulkan.Scene3D.DebugDump
 * (see unit PasVulkan.Scene3D.DebugDump.pas) and scans bounding-sphere
 * (MBSP / GBSP) dumps for anomalies:
 *   - NaN / Inf
 *   - zero radius
 *   - huge radius jumps between consecutive frames (per IFF, per index)
 *   - huge position jumps between consecutive frames (per IFF, per index)
 *
 * If NMAP dumps are present, anomaly reports are augmented with
 * instance-node attribution (group name, node name, buffer offsets).
 *
 * Usage:
 *   scene3ddumpanalyzer <dumps-directory> [--pos-threshold F] [--rad-threshold F]
 *
 * Build:
 *   cc -O2 -std=c99 -Wall -o scene3ddumpanalyzer scene3ddumpanalyzer.c -lm
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <math.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>

#define DUMP_MAGIC "PVSD"
#define HEADER_SIZE 40

typedef struct {
    char     magic[4];
    uint32_t version;
    uint32_t frameIndex;
    uint32_t inFlightFrameIndex;
    char     tag[4];
    uint32_t reserved;
    uint64_t sizeBytes;
    uint64_t extraInfo;
} DumpHeader;

typedef struct {
    uint32_t frameIndex;
    uint32_t inFlightFrameIndex;
    char     tag[4];
    uint64_t sizeBytes;
    uint64_t extraInfo;
    float   *data;    /* vec4 payload (x,y,z,r) */
    size_t   count;   /* number of vec4s */
    char     filename[512];
} DumpFile;

static int read_dump(const char *path, DumpFile *out) {
    FILE *f = fopen(path, "rb");
    if (!f) return 0;
    DumpHeader h;
    if (fread(&h, 1, HEADER_SIZE, f) != HEADER_SIZE) { fclose(f); return 0; }
    if (memcmp(h.magic, DUMP_MAGIC, 4) != 0) { fclose(f); return 0; }
    out->frameIndex = h.frameIndex;
    out->inFlightFrameIndex = h.inFlightFrameIndex;
    memcpy(out->tag, h.tag, 4);
    out->sizeBytes = h.sizeBytes;
    out->extraInfo = h.extraInfo;
    out->count = (size_t)(h.sizeBytes / sizeof(float) / 4);
    if (out->count == 0) { out->data = NULL; fclose(f); return 1; }
    out->data = (float*)malloc(out->count * sizeof(float) * 4);
    if (!out->data) { fclose(f); return 0; }
    if (fread(out->data, sizeof(float) * 4, out->count, f) != out->count) {
        free(out->data); out->data = NULL; fclose(f); return 0;
    }
    fclose(f);
    return 1;
}

static void free_dump(DumpFile *d) {
    if (d->data) { free(d->data); d->data = NULL; }
}

static int filter_bin(const struct dirent *e) {
    size_t n = strlen(e->d_name);
    return n > 4 && strcmp(e->d_name + n - 4, ".bin") == 0;
}

/* string compare for sorting filenames lexicographically (frame_NNNNNNNN_iff_N_TAG.bin) */
static int cmp_dirent(const void *a, const void *b) {
    const struct dirent * const *da = (const struct dirent * const *)a;
    const struct dirent * const *db = (const struct dirent * const *)b;
    return strcmp((*da)->d_name, (*db)->d_name);
}

static int is_bad_float(float v) {
    return isnan(v) || isinf(v);
}

/* -------------- NMAP node-attribution map -------------- */
#pragma pack(push,1)
typedef struct {
    uint32_t boundingSphereIndex;
    uint32_t meshObjectID;
    uint32_t groupID;
    uint32_t instanceID;
    int32_t  nodeIdxInInstance;
    int32_t  groupNodeIndex;
    uint32_t nodeMatricesIndex;      /* absolute: rangeOffset + nodeIndex + 1 */
    uint32_t nodeMatricesRootIndex;  /* = rangeOffset */
    uint32_t morphWeightsOffset;
    uint32_t jointBlockOffset;
    uint32_t activeIFF;
    uint32_t reserved;
    char     groupName[64];
    char     nodeName[64];
} NMAPEntry;
typedef struct {
    uint32_t magic;       /* 'NMAP' little-endian */
    uint32_t version;
    uint32_t entryCount;
    uint32_t entrySize;   /* = sizeof(NMAPEntry) = 176 */
} NMAPHeader;
#pragma pack(pop)

static NMAPEntry *nmap_by_idx = NULL;   /* indexed by boundingSphereIndex */
static size_t    nmap_capacity = 0;
static int       nmap_loaded = 0;
static uint32_t  nmap_src_frame = 0;

static void ensure_nmap_cap(size_t new_cap) {
    if (new_cap <= nmap_capacity) return;
    NMAPEntry *n = (NMAPEntry*)realloc(nmap_by_idx, new_cap * sizeof(NMAPEntry));
    if (!n) { fprintf(stderr, "nmap realloc failed\n"); return; }
    memset(n + nmap_capacity, 0xff, (new_cap - nmap_capacity) * sizeof(NMAPEntry));
    nmap_by_idx = n;
    nmap_capacity = new_cap;
}

static void load_nmap(const char *path) {
    FILE *f = fopen(path, "rb");
    if (!f) return;
    DumpHeader dh;
    if (fread(&dh, 1, HEADER_SIZE, f) != HEADER_SIZE) { fclose(f); return; }
    if (memcmp(dh.magic, DUMP_MAGIC, 4) != 0) { fclose(f); return; }
    NMAPHeader nh;
    if (fread(&nh, 1, sizeof nh, f) != sizeof nh) { fclose(f); return; }
    if (nh.entrySize != sizeof(NMAPEntry)) {
        fprintf(stderr, "NMAP entrySize=%u but expected %zu; ignoring %s\n",
                nh.entrySize, sizeof(NMAPEntry), path);
        fclose(f);
        return;
    }
    for (uint32_t i = 0; i < nh.entryCount; ++i) {
        NMAPEntry e;
        if (fread(&e, 1, sizeof e, f) != sizeof e) break;
        uint32_t idx = e.boundingSphereIndex;
        if (idx >= nmap_capacity) {
            size_t nc = nmap_capacity ? nmap_capacity * 2 : 1024;
            while (nc <= idx) nc *= 2;
            ensure_nmap_cap(nc);
        }
        nmap_by_idx[idx] = e;
    }
    nmap_src_frame = dh.frameIndex;
    nmap_loaded = 1;
    fclose(f);
}

static void fmt_attribution(uint32_t sphereIndex, char *out, size_t outsz) {
    if (!nmap_loaded || sphereIndex >= nmap_capacity) {
        snprintf(out, outsz, " (no NMAP)");
        return;
    }
    NMAPEntry *e = &nmap_by_idx[sphereIndex];
    if (e->boundingSphereIndex != sphereIndex) {
        snprintf(out, outsz, " (unmapped)");
        return;
    }
    char gn[65]; memcpy(gn, e->groupName, 64); gn[64] = 0;
    char nn[65]; memcpy(nn, e->nodeName, 64); nn[64] = 0;
    snprintf(out, outsz,
        " group=\"%s\" inst=%u node=\"%s\" nIdx=%d gNode=%d mesh=%u "
        "nmtxAbs=%u nmtxRoot=%u mtwg=%u jblk=%u active=%u",
        gn, e->instanceID, nn, e->nodeIdxInInstance, e->groupNodeIndex, e->meshObjectID,
        e->nodeMatricesIndex, e->nodeMatricesRootIndex,
        e->morphWeightsOffset, e->jointBlockOffset, e->activeIFF);
}

/* -------------------------------------------------------- */

static void analyze_pair(const DumpFile *prev, const DumpFile *curr,
                         float pos_thresh, float rad_thresh, int *report_count) {
    size_t n = prev->count < curr->count ? prev->count : curr->count;
    for (size_t i = 0; i < n; ++i) {
        const float *p = prev->data + i * 4;
        const float *c = curr->data + i * 4;
        int any = 0;
        char reason[256]; reason[0] = 0;
        if (is_bad_float(c[0]) || is_bad_float(c[1]) || is_bad_float(c[2]) || is_bad_float(c[3])) {
            snprintf(reason, sizeof reason, "NaN/Inf");
            any = 1;
        } else if (c[3] == 0.0f && p[3] != 0.0f) {
            snprintf(reason, sizeof reason, "radius 0 (was %.4f)", p[3]);
            any = 1;
        } else {
            float dx = c[0] - p[0], dy = c[1] - p[1], dz = c[2] - p[2];
            float dpos = sqrtf(dx*dx + dy*dy + dz*dz);
            float drad = fabsf(c[3] - p[3]);
            if (dpos > pos_thresh) {
                snprintf(reason, sizeof reason,
                    "pos jump %.4f (%.3f,%.3f,%.3f -> %.3f,%.3f,%.3f)",
                    dpos, p[0],p[1],p[2], c[0],c[1],c[2]);
                any = 1;
            } else if (drad > rad_thresh) {
                snprintf(reason, sizeof reason,
                    "radius jump %.4f (%.4f -> %.4f)", drad, p[3], c[3]);
                any = 1;
            }
        }
        if (any) {
            int is_gbsp = (memcmp(curr->tag, "GBSP", 4) == 0);
            char attr[512]; attr[0] = 0;
            if (is_gbsp) fmt_attribution((uint32_t)i, attr, sizeof attr);
            printf("[%.4s iff=%u frame %u->%u] idx %zu: %s  r=(%.4f,%.4f,%.4f,%.4f)%s\n",
                curr->tag, curr->inFlightFrameIndex,
                prev->frameIndex, curr->frameIndex, i, reason,
                c[0], c[1], c[2], c[3], attr);
            (*report_count)++;
        }
    }
}

static void scan_statics(const DumpFile *d, int *report_count) {
    int is_gbsp = (memcmp(d->tag, "GBSP", 4) == 0);
    for (size_t i = 0; i < d->count; ++i) {
        const float *c = d->data + i * 4;
        if (is_bad_float(c[0]) || is_bad_float(c[1]) || is_bad_float(c[2]) || is_bad_float(c[3])) {
            char attr[512]; attr[0] = 0;
            if (is_gbsp) fmt_attribution((uint32_t)i, attr, sizeof attr);
            printf("[%.4s iff=%u frame %u] idx %zu: NaN/Inf (%.4f,%.4f,%.4f,%.4f)%s\n",
                d->tag, d->inFlightFrameIndex, d->frameIndex, i, c[0], c[1], c[2], c[3], attr);
            (*report_count)++;
        }
    }
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: %s <dumps-dir> [--pos-threshold F] [--rad-threshold F]\n", argv[0]);
        return 2;
    }
    const char *dir = argv[1];
    float pos_thresh = 5.0f;
    float rad_thresh = 5.0f;
    for (int i = 2; i + 1 < argc; ++i) {
        if (strcmp(argv[i], "--pos-threshold") == 0) pos_thresh = (float)atof(argv[++i]);
        else if (strcmp(argv[i], "--rad-threshold") == 0) rad_thresh = (float)atof(argv[++i]);
    }

    struct dirent **list = NULL;
    int n = scandir(dir, &list, filter_bin, NULL);
    if (n < 0) {
        fprintf(stderr, "scandir %s: %s\n", dir, strerror(errno));
        return 1;
    }
    qsort(list, n, sizeof list[0], cmp_dirent);

    /* First pass: load all NMAP dumps (they contain node attribution metadata). */
    for (int i = 0; i < n; ++i) {
        const char *name = list[i]->d_name;
        if (strstr(name, "_NMAP.bin")) {
            char path[1024];
            snprintf(path, sizeof path, "%s/%s", dir, name);
            load_nmap(path);
        }
    }
    if (nmap_loaded) {
        fprintf(stderr, "NMAP loaded (last src frame=%u, capacity=%zu)\n",
                nmap_src_frame, nmap_capacity);
    }

    /* we key previous dumps by (tag,iff) */
    DumpFile prev[256][8]; /* 256 distinct first-char tags, 8 IFFs -- plenty */
    memset(prev, 0, sizeof prev);

    int report_count = 0;
    int total = 0;
    for (int i = 0; i < n; ++i) {
        /* skip NMAP (already handled above) */
        if (strstr(list[i]->d_name, "_NMAP.bin")) {
            free(list[i]);
            continue;
        }
        char path[1024];
        snprintf(path, sizeof path, "%s/%s", dir, list[i]->d_name);
        DumpFile d;
        memset(&d, 0, sizeof d);
        snprintf(d.filename, sizeof d.filename, "%s", list[i]->d_name);
        if (!read_dump(path, &d)) {
            fprintf(stderr, "skip bad dump: %s\n", list[i]->d_name);
            free(list[i]); continue;
        }
        total++;

        /* only diff bounding-sphere tags (MBSP/GBSP); statics (NaN) everywhere */
        int is_sphere = (memcmp(d.tag, "MBSP", 4) == 0) || (memcmp(d.tag, "GBSP", 4) == 0);
        unsigned tag0 = (unsigned char)d.tag[0];
        unsigned iff = d.inFlightFrameIndex < 8 ? d.inFlightFrameIndex : 7;

        if (is_sphere) {
            if (prev[tag0][iff].data && memcmp(prev[tag0][iff].tag, d.tag, 4) == 0) {
                analyze_pair(&prev[tag0][iff], &d, pos_thresh, rad_thresh, &report_count);
            }
            scan_statics(&d, &report_count);
            free_dump(&prev[tag0][iff]);
            prev[tag0][iff] = d;
            /* don't free d here; ownership moved into prev */
        } else {
            /* animation buffers: only NaN scan for now, payload layout varies */
            /* (interpret as raw float array) */
            for (size_t j = 0; j + 0 < d.count * 4; ++j) {
                float v = ((float*)d.data)[j];
                if (is_bad_float(v)) {
                    printf("[%.4s iff=%u frame %u] float idx %zu: NaN/Inf\n",
                        d.tag, d.inFlightFrameIndex, d.frameIndex, j);
                    report_count++;
                    break; /* one per file is enough */
                }
            }
            free_dump(&d);
        }
        free(list[i]);
    }
    free(list);

    /* cleanup remaining prev */
    for (int a = 0; a < 256; ++a)
        for (int b = 0; b < 8; ++b)
            free_dump(&prev[a][b]);

    fprintf(stderr, "scanned %d files, %d anomaly reports\n", total, report_count);
    return 0;
}
