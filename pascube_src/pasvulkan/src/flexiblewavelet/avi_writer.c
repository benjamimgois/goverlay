/******************************************************************************
 *                                 PasVulkan                                  *
 ******************************************************************************
 *                       Version see PasVulkan.Framework.pas                  *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2016-2026, Benjamin Rosseaux (benjamin@rosseaux.de)          *
 *                                                                            *
 * This software is provided 'as-is', without any express or implied          *
 * warranty. In no event will the authors be held liable for any damages      *
 * arising from the use of this software.                                     *
 *                                                                            *
 * Permission is granted to anyone to use this software for any purpose,      *
 * including commercial applications, and to alter it and redistribute it     *
 * freely, subject to the following restrictions:                             *
 *                                                                            *
 * 1. The origin of this software must not be misrepresented; you must not    *
 *    claim that you wrote the original software. If you use this software    *
 *    in a product, an acknowledgement in the product documentation would be  *
 *    appreciated but is not required.                                        *
 * 2. Altered source versions must be plainly marked as such, and must not be *
 *    misrepresented as being the original software.                          *
 * 3. This notice may not be removed or altered from any source distribution. *
 *                                                                            *
 ******************************************************************************
 *                  General guidelines for code contributors                  *
 *============================================================================*
 *                                                                            *
 * 1. Make sure you are legally allowed to make a contribution under the zlib *
 *    license.                                                                *
 * 2. The zlib license header goes at the top of each source file, with       *
 *    appropriate copyright notice.                                           *
 * 3. This PasVulkan wrapper may be used only with the PasVulkan-own Vulkan   *
 *    Pascal header.                                                          *
 * 4. After a pull request, check the status of your pull request on          *
      http://github.com/BeRo1985/pasvulkan                                    *
 * 5. Write code which's compatible with Delphi >= 2009 and FreePascal >=     *
 *    3.1.1                                                                   *
 * 6. Don't use Delphi-only, FreePascal-only or Lazarus-only libraries/units, *
 *    but if needed, make it out-ifdef-able.                                  *
 * 7. No use of third-party libraries/units as possible, but if needed, make  *
 *    it out-ifdef-able.                                                      *
 * 8. Try to use const when possible.                                         *
 * 9. Make sure to comment out writeln, used while debugging.                 *
 * 10. Make sure the code compiles on 32-bit and 64-bit platforms (x86-32,    *
 *     x86-64, ARM, ARM64, etc.).                                             *
 * 11. Make sure the code runs on all platforms with Vulkan support           *
 *                                                                            *
 ******************************************************************************/
// avi_writer.c — minimal OpenDML / AVI 2.0 muxer (RGB32 + PCM16). See avi_writer.h.
#define _POSIX_C_SOURCE 200809L
#define _FILE_OFFSET_BITS 64
#include "avi_writer.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

#define AVI_SEGMENT_LIMIT (1u << 30)   // start a new RIFF AVIX once a segment's movi reaches ~1 GB
#define AVI_MAX_SEGMENTS 4096           // superindex capacity (4096 GB worth of 1 GB segments)

typedef struct {
  uint32_t offset;   // chunk-DATA offset relative to the segment's qwBaseOffset
  uint32_t size;     // chunk data size (raw is always a key frame, so the delta high-bit stays clear)
} IxEntry;

typedef struct {
  uint64_t offset;   // absolute file offset of the ix## chunk
  uint32_t size;     // size of the ix## chunk (incl. its 8-byte header)
  uint32_t duration; // number of entries it indexes
} SuperEntry;

struct AviWriter {
  FILE *file;
  int width, height;
  uint32_t fps_num, fps_den;
  int audio_channels, audio_rate, block_align;
  const int16_t *audio_pcm;
  uint64_t audio_frames, audio_written;
  uint8_t *bgra;                 // one frame, bottom-up BGRA
  uint32_t video_frames;

  off_t riff_size_pos, movi_size_pos, movi_base;   // current segment
  int first_segment;

  IxEntry *vid_ix, *aud_ix;
  uint32_t vid_ix_count, aud_ix_count, vid_ix_cap, aud_ix_cap;
  SuperEntry vid_super[AVI_MAX_SEGMENTS], aud_super[AVI_MAX_SEGMENTS];
  uint32_t vid_super_count, aud_super_count;

  off_t avih_pos, vid_strh_pos, aud_strh_pos, vid_indx_pos, aud_indx_pos, dmlh_pos;
};

static void w8(FILE *f, uint8_t v) { fputc(v, f); }
static void w16(FILE *f, uint16_t v) { w8(f, (uint8_t)v); w8(f, (uint8_t)(v >> 8)); }
static void w32(FILE *f, uint32_t v) { w16(f, (uint16_t)v); w16(f, (uint16_t)(v >> 16)); }
static void w64(FILE *f, uint64_t v) { w32(f, (uint32_t)v); w32(f, (uint32_t)(v >> 32)); }
static void wcc(FILE *f, const char *cc) { fwrite(cc, 1, 4, f); }

static void patch32(FILE *f, off_t pos, uint32_t v) {
  off_t here = ftello(f);
  fseeko(f, pos, SEEK_SET);
  w32(f, v);
  fseeko(f, here, SEEK_SET);
}

static void patch64(FILE *f, off_t pos, uint64_t v) {
  off_t here = ftello(f);
  fseeko(f, pos, SEEK_SET);
  w64(f, v);
  fseeko(f, here, SEEK_SET);
}

// Start a RIFF segment ('AVI ' for the first, 'AVIX' afterwards) and open its movi LIST. Records the
// size-field offsets to patch and the base offset the segment's ix## entries are relative to.
static void begin_segment(AviWriter *w) {
  wcc(w->file, "RIFF");
  w->riff_size_pos = ftello(w->file);
  w32(w->file, 0);
  wcc(w->file, w->first_segment ? "AVI " : "AVIX");
  if (w->first_segment) {
    return;   // the first segment's hdrl is written by avi_open; it opens movi itself
  }
  wcc(w->file, "LIST");
  w->movi_size_pos = ftello(w->file);
  w32(w->file, 0);
  wcc(w->file, "movi");
  w->movi_base = ftello(w->file);
  w->vid_ix_count = 0;
  w->aud_ix_count = 0;
}

// Write a standard index (ix##) for the current segment and record a superindex entry for it.
static void write_std_index(AviWriter *w, const char *chunk_id, IxEntry *entries, uint32_t count,
                            SuperEntry *super, uint32_t *super_count) {
  off_t ix_offset = ftello(w->file);
  uint32_t ix_size = 24 + (count * 8);   // header (after the 8-byte chunk header) + entries
  wcc(w->file, (chunk_id[0] == '0' && chunk_id[1] == '0') ? "ix00" : "ix01");
  w32(w->file, ix_size);
  w16(w->file, 2);            // wLongsPerEntry
  w8(w->file, 0);            // bIndexSubType
  w8(w->file, 1);            // bIndexType = AVI_INDEX_OF_CHUNKS
  w32(w->file, count);       // nEntriesInUse
  wcc(w->file, chunk_id);    // dwChunkId ('00db' / '01wb')
  w64(w->file, (uint64_t)w->movi_base);   // qwBaseOffset (entries are relative to this)
  w32(w->file, 0);           // dwReserved3
  for (uint32_t i = 0; i < count; i++) {
    w32(w->file, entries[i].offset);
    w32(w->file, entries[i].size);   // high bit clear = key frame
  }
  if (*super_count < AVI_MAX_SEGMENTS) {
    super[*super_count].offset = (uint64_t)ix_offset;
    super[*super_count].size = ix_size + 8;
    super[*super_count].duration = count;
    (*super_count)++;
  }
}

// Close the current segment: write the two ix## indexes inside the movi LIST, patch the movi + RIFF sizes.
static void end_segment(AviWriter *w) {
  write_std_index(w, "00db", w->vid_ix, w->vid_ix_count, w->vid_super, &w->vid_super_count);
  write_std_index(w, "01wb", w->aud_ix, w->aud_ix_count, w->aud_super, &w->aud_super_count);
  off_t end = ftello(w->file);
  patch32(w->file, w->movi_size_pos, (uint32_t)(end - (w->movi_size_pos + 4)));
  patch32(w->file, w->riff_size_pos, (uint32_t)(end - (w->riff_size_pos + 4)));
  w->first_segment = 0;
}

static void add_ix(AviWriter *w, IxEntry **arr, uint32_t *count, uint32_t *cap, uint32_t offset, uint32_t size) {
  (void)w;
  if (*count == *cap) {
    *cap = *cap ? (*cap * 2) : 4096;
    *arr = realloc(*arr, *cap * sizeof(IxEntry));
  }
  (*arr)[*count].offset = offset;
  (*arr)[*count].size = size;
  (*count)++;
}

// Write whatever audio belongs up to the current video time (keeps A/V interleaved without drift).
static void flush_audio(AviWriter *w, int final) {
  if (!w->audio_pcm || (w->audio_frames == 0)) {
    return;
  }
  uint64_t target = final ? w->audio_frames
                          : (((uint64_t)w->audio_rate * w->video_frames * w->fps_den) / w->fps_num);
  if (target > w->audio_frames) {
    target = w->audio_frames;
  }
  if (target <= w->audio_written) {
    return;
  }
  uint32_t frames = (uint32_t)(target - w->audio_written);
  uint32_t bytes = frames * (uint32_t)w->block_align;
  off_t chunk = ftello(w->file);
  wcc(w->file, "01wb");
  w32(w->file, bytes);
  fwrite(w->audio_pcm + (w->audio_written * w->audio_channels), 1, bytes, w->file);
  add_ix(w, &w->aud_ix, &w->aud_ix_count, &w->aud_ix_cap, (uint32_t)((chunk + 8) - w->movi_base), bytes);
  w->audio_written = target;
}

AviWriter *avi_open(const char *path, int width, int height, uint32_t fps_num, uint32_t fps_den,
                    const int16_t *audio_pcm, uint64_t audio_frames, int audio_channels, int audio_rate) {
  AviWriter *w = calloc(1, sizeof(AviWriter));
  w->file = fopen(path, "wb+");
  if (!w->file) {
    free(w);
    return NULL;
  }
  w->width = width;
  w->height = height;
  w->fps_num = fps_num ? fps_num : 30;
  w->fps_den = fps_den ? fps_den : 1;
  w->audio_pcm = (audio_frames > 0) ? audio_pcm : NULL;
  w->audio_frames = w->audio_pcm ? audio_frames : 0;
  w->audio_channels = audio_channels;
  w->audio_rate = audio_rate;
  w->block_align = audio_channels * 2;
  w->bgra = malloc((size_t)width * height * 4);
  w->first_segment = 1;
  int have_audio = (w->audio_pcm != NULL);
  uint32_t image_bytes = (uint32_t)width * height * 4;

  begin_segment(w);   // RIFF 'AVI '

  // ---- hdrl ----
  wcc(w->file, "LIST");
  off_t hdrl_size_pos = ftello(w->file);
  w32(w->file, 0);
  wcc(w->file, "hdrl");

  wcc(w->file, "avih");
  w32(w->file, 56);
  w->avih_pos = ftello(w->file);
  w32(w->file, (uint32_t)(((uint64_t)1000000 * w->fps_den) / w->fps_num));   // dwMicroSecPerFrame
  w32(w->file, 0);             // dwMaxBytesPerSec (patched)
  w32(w->file, 0);             // dwPaddingGranularity
  w32(w->file, 0x00000810);    // AVIF_HASINDEX | AVIF_ISINTERLEAVED
  w32(w->file, 0);             // dwTotalFrames (patched)
  w32(w->file, 0);             // dwInitialFrames
  w32(w->file, have_audio ? 2 : 1);   // dwStreams
  w32(w->file, image_bytes);   // dwSuggestedBufferSize
  w32(w->file, (uint32_t)width);
  w32(w->file, (uint32_t)height);
  w32(w->file, 0); w32(w->file, 0); w32(w->file, 0); w32(w->file, 0);   // reserved

  // ---- video strl ----
  wcc(w->file, "LIST");
  off_t vstrl_size_pos = ftello(w->file);
  w32(w->file, 0);
  wcc(w->file, "strl");
  wcc(w->file, "strh");
  w32(w->file, 56);
  w->vid_strh_pos = ftello(w->file);
  wcc(w->file, "vids");
  w32(w->file, 0);             // fccHandler 0 = BI_RGB
  w32(w->file, 0);             // dwFlags
  w16(w->file, 0); w16(w->file, 0);   // priority, language
  w32(w->file, 0);             // dwInitialFrames
  w32(w->file, w->fps_den);    // dwScale
  w32(w->file, w->fps_num);    // dwRate
  w32(w->file, 0);             // dwStart
  w32(w->file, 0);             // dwLength (patched)
  w32(w->file, image_bytes);   // dwSuggestedBufferSize
  w32(w->file, 0xFFFFFFFF);    // dwQuality
  w32(w->file, 0);             // dwSampleSize
  w16(w->file, 0); w16(w->file, 0); w16(w->file, (uint16_t)width); w16(w->file, (uint16_t)height);   // rcFrame
  wcc(w->file, "strf");
  w32(w->file, 40);
  w32(w->file, 40);            // biSize
  w32(w->file, (uint32_t)width);
  w32(w->file, (uint32_t)height);   // bottom-up
  w16(w->file, 1);             // biPlanes
  w16(w->file, 32);            // biBitCount
  w32(w->file, 0);             // biCompression BI_RGB
  w32(w->file, image_bytes);   // biSizeImage
  w32(w->file, 0); w32(w->file, 0); w32(w->file, 0); w32(w->file, 0);   // ppm + clrused/important
  // video superindex placeholder
  wcc(w->file, "indx");
  w32(w->file, 24 + (AVI_MAX_SEGMENTS * 16));
  w->vid_indx_pos = ftello(w->file);
  w16(w->file, 4);             // wLongsPerEntry
  w8(w->file, 0);              // bIndexSubType
  w8(w->file, 0);              // bIndexType = AVI_INDEX_OF_INDEXES
  w32(w->file, 0);             // nEntriesInUse (patched)
  wcc(w->file, "00db");        // dwChunkId
  w32(w->file, 0); w32(w->file, 0); w32(w->file, 0);   // reserved
  for (int i = 0; i < AVI_MAX_SEGMENTS; i++) {
    w64(w->file, 0); w32(w->file, 0); w32(w->file, 0);
  }
  patch32(w->file, vstrl_size_pos, (uint32_t)(ftello(w->file) - (vstrl_size_pos + 4)));

  // ---- audio strl ----
  if (have_audio) {
    wcc(w->file, "LIST");
    off_t astrl_size_pos = ftello(w->file);
    w32(w->file, 0);
    wcc(w->file, "strl");
    wcc(w->file, "strh");
    w32(w->file, 56);
    w->aud_strh_pos = ftello(w->file);
    wcc(w->file, "auds");
    w32(w->file, 0);            // fccHandler
    w32(w->file, 0);            // dwFlags
    w16(w->file, 0); w16(w->file, 0);
    w32(w->file, 0);            // dwInitialFrames
    w32(w->file, 1);           // dwScale
    w32(w->file, (uint32_t)w->audio_rate);   // dwRate
    w32(w->file, 0);           // dwStart
    w32(w->file, 0);           // dwLength (patched, in sample frames)
    w32(w->file, (uint32_t)(w->audio_rate * w->block_align));   // dwSuggestedBufferSize (~1s)
    w32(w->file, 0xFFFFFFFF);  // dwQuality
    w32(w->file, (uint32_t)w->block_align);   // dwSampleSize
    w16(w->file, 0); w16(w->file, 0); w16(w->file, 0); w16(w->file, 0);   // rcFrame
    wcc(w->file, "strf");
    w32(w->file, 16);
    w16(w->file, 1);           // WAVE_FORMAT_PCM
    w16(w->file, (uint16_t)w->audio_channels);
    w32(w->file, (uint32_t)w->audio_rate);
    w32(w->file, (uint32_t)(w->audio_rate * w->block_align));   // nAvgBytesPerSec
    w16(w->file, (uint16_t)w->block_align);
    w16(w->file, 16);          // wBitsPerSample
    wcc(w->file, "indx");
    w32(w->file, 24 + (AVI_MAX_SEGMENTS * 16));
    w->aud_indx_pos = ftello(w->file);
    w16(w->file, 4);
    w8(w->file, 0);
    w8(w->file, 0);
    w32(w->file, 0);
    wcc(w->file, "01wb");
    w32(w->file, 0); w32(w->file, 0); w32(w->file, 0);
    for (int i = 0; i < AVI_MAX_SEGMENTS; i++) {
      w64(w->file, 0); w32(w->file, 0); w32(w->file, 0);
    }
    patch32(w->file, astrl_size_pos, (uint32_t)(ftello(w->file) - (astrl_size_pos + 4)));
  }

  // ---- odml ----
  wcc(w->file, "LIST");
  off_t odml_size_pos = ftello(w->file);
  w32(w->file, 0);
  wcc(w->file, "odml");
  wcc(w->file, "dmlh");
  w32(w->file, 4);
  w->dmlh_pos = ftello(w->file);
  w32(w->file, 0);             // dwTotalFrames (patched)
  patch32(w->file, odml_size_pos, (uint32_t)(ftello(w->file) - (odml_size_pos + 4)));

  patch32(w->file, hdrl_size_pos, (uint32_t)(ftello(w->file) - (hdrl_size_pos + 4)));

  // ---- first movi LIST ----
  wcc(w->file, "LIST");
  w->movi_size_pos = ftello(w->file);
  w32(w->file, 0);
  wcc(w->file, "movi");
  w->movi_base = ftello(w->file);
  w->vid_ix_count = 0;
  w->aud_ix_count = 0;
  return w;
}

void avi_video_frame(AviWriter *writer, const uint8_t *rgba) {
  AviWriter *w = writer;
  // RGBA8 (top-down) -> BGRA bottom-up.
  for (int y = 0; y < w->height; y++) {
    const uint8_t *src = rgba + ((size_t)(w->height - 1 - y) * w->width * 4);
    uint8_t *dst = w->bgra + ((size_t)y * w->width * 4);
    for (int x = 0; x < w->width; x++) {
      dst[(x * 4) + 0] = src[(x * 4) + 2];   // B
      dst[(x * 4) + 1] = src[(x * 4) + 1];   // G
      dst[(x * 4) + 2] = src[(x * 4) + 0];   // R
      dst[(x * 4) + 3] = src[(x * 4) + 3];   // A
    }
  }
  uint32_t bytes = (uint32_t)w->width * w->height * 4;
  off_t chunk = ftello(w->file);
  wcc(w->file, "00db");
  w32(w->file, bytes);
  fwrite(w->bgra, 1, bytes, w->file);
  add_ix(w, &w->vid_ix, &w->vid_ix_count, &w->vid_ix_cap, (uint32_t)((chunk + 8) - w->movi_base), bytes);
  w->video_frames++;
  flush_audio(w, 0);

  // Roll to a new RIFF AVIX once this segment's movi grew past the limit.
  if (((uint64_t)(ftello(w->file) - w->movi_base)) > AVI_SEGMENT_LIMIT) {
    end_segment(w);
    begin_segment(w);
  }
}

void avi_close(AviWriter *writer) {
  AviWriter *w = writer;
  flush_audio(w, 1);
  end_segment(w);

  // Patch headers.
  patch32(w->file, w->avih_pos + 16, w->video_frames);   // avih.dwTotalFrames
  patch32(w->file, w->dmlh_pos, w->video_frames);         // dmlh.dwTotalFrames
  patch32(w->file, w->vid_strh_pos + 32, w->video_frames);   // video strh.dwLength
  if (w->audio_pcm) {
    patch32(w->file, w->aud_strh_pos + 32, (uint32_t)w->audio_written);   // audio strh.dwLength (sample frames)
  }

  // Patch the video superindex (nEntriesInUse + the entries).
  patch32(w->file, w->vid_indx_pos + 4, w->vid_super_count);
  for (uint32_t i = 0; i < w->vid_super_count; i++) {
    off_t e = w->vid_indx_pos + 20 + ((off_t)i * 16);
    patch64(w->file, e, w->vid_super[i].offset);
    patch32(w->file, e + 8, w->vid_super[i].size);
    patch32(w->file, e + 12, w->vid_super[i].duration);
  }
  if (w->audio_pcm) {
    patch32(w->file, w->aud_indx_pos + 4, w->aud_super_count);
    for (uint32_t i = 0; i < w->aud_super_count; i++) {
      off_t e = w->aud_indx_pos + 20 + ((off_t)i * 16);
      patch64(w->file, e, w->aud_super[i].offset);
      patch32(w->file, e + 8, w->aud_super[i].size);
      patch32(w->file, e + 12, w->aud_super[i].duration);
    }
  }

  fclose(w->file);
  free(w->bgra);
  free(w->vid_ix);
  free(w->aud_ix);
  free(w);
}
