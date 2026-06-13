/*
 * export.c — Model save / load / GLSL export
 *
 * Binary format:
 *   "CNNU" (4 bytes magic, little-endian 0x554E4E43)
 *   uint32  version (1)
 *   uint32  scale_factor
 *   uint32  in_channels
 *   uint32  out_channels
 *   uint32  colorspace
 *   uint32  num_layers
 *   For each layer:
 *     uint32  in_channels
 *     uint32  out_channels
 *     uint32  kernel_size
 *     uint32  has_relu
 *     float[] weights  (out_ch × in_ch × ks × ks)
 *     float[] biases   (out_ch)
 *
 * GLSL export:
 *   Generates a .glsl include file with:
 *   - Weight constant arrays
 *   - Inference function
 *   - Optional tonemapping wrappers
 *
 * Copyright (C) 2026 Benjamin 'BeRo' Rosseaux. License see PasVulkan.Framework.pas (zlib)
 */

#include "upscaler.h"

/* ============================================================================
 * Binary save
 * ========================================================================= */

int model_save(const Model *m, const char *path)
{
    FILE *fp = fopen(path, "wb");
    if (!fp) {
        fprintf(stderr, "ERROR: cannot create %s\n", path);
        return 0;
    }

    uint32_t magic = MODEL_MAGIC;
    uint32_t ver   = MODEL_VERSION;
    fwrite(&magic, 4, 1, fp);
    fwrite(&ver,   4, 1, fp);

    uint32_t u;
    u = (uint32_t)m->scale_factor; fwrite(&u, 4, 1, fp);
    u = (uint32_t)m->in_channels;  fwrite(&u, 4, 1, fp);
    u = (uint32_t)m->out_channels; fwrite(&u, 4, 1, fp);
    u = (uint32_t)m->colorspace;   fwrite(&u, 4, 1, fp);
    u = (uint32_t)m->num_layers;   fwrite(&u, 4, 1, fp);

    for (int i = 0; i < m->num_layers; i++) {
        u = (uint32_t)m->layer_in[i];   fwrite(&u, 4, 1, fp);
        u = (uint32_t)m->layer_out[i];  fwrite(&u, 4, 1, fp);
        u = (uint32_t)m->layer_ks[i];   fwrite(&u, 4, 1, fp);
        u = (uint32_t)m->layer_relu[i]; fwrite(&u, 4, 1, fp);
        fwrite(m->W[i], sizeof(float), (size_t)m->w_count[i], fp);
        fwrite(m->B[i], sizeof(float), (size_t)m->b_count[i], fp);
    }

    fclose(fp);

    /* Print total parameter count */
    int total = 0;
    for (int i = 0; i < m->num_layers; i++)
        total += m->w_count[i] + m->b_count[i];
    printf("Model saved to %s  (%d parameters, %.1f KB)\n",
           path, total, (float)(total * 4) / 1024.0f);

    return 1;
}

/* ============================================================================
 * Binary load
 * ========================================================================= */

Model *model_load(const char *path)
{
    FILE *fp = fopen(path, "rb");
    if (!fp) {
        fprintf(stderr, "ERROR: cannot open model %s\n", path);
        return NULL;
    }

    uint32_t magic, ver;
    fread(&magic, 4, 1, fp);
    fread(&ver,   4, 1, fp);

    if (magic != MODEL_MAGIC) {
        fprintf(stderr, "ERROR: %s is not a valid model file (bad magic)\n", path);
        fclose(fp);
        return NULL;
    }
    if (ver != MODEL_VERSION) {
        fprintf(stderr, "ERROR: model version %u, expected %u\n", ver, MODEL_VERSION);
        fclose(fp);
        return NULL;
    }

    Model *m = (Model *)calloc(1, sizeof(Model));

    uint32_t u;
    fread(&u, 4, 1, fp); m->scale_factor = (int)u;
    fread(&u, 4, 1, fp); m->in_channels  = (int)u;
    fread(&u, 4, 1, fp); m->out_channels = (int)u;
    fread(&u, 4, 1, fp); m->colorspace   = (int)u;
    fread(&u, 4, 1, fp); m->num_layers   = (int)u;

    if (m->num_layers > MAX_LAYERS) {
        fprintf(stderr, "ERROR: model has %d layers (max %d)\n",
                m->num_layers, MAX_LAYERS);
        free(m); fclose(fp);
        return NULL;
    }

    for (int i = 0; i < m->num_layers; i++) {
        fread(&u, 4, 1, fp); m->layer_in[i]   = (int)u;
        fread(&u, 4, 1, fp); m->layer_out[i]  = (int)u;
        fread(&u, 4, 1, fp); m->layer_ks[i]   = (int)u;
        fread(&u, 4, 1, fp); m->layer_relu[i] = (int)u;

        int ks = m->layer_ks[i];
        m->layer_pad[i] = ks / 2;
        m->w_count[i]   = m->layer_out[i] * m->layer_in[i] * ks * ks;
        m->b_count[i]   = m->layer_out[i];

        m->W[i] = (float *)malloc((size_t)m->w_count[i] * sizeof(float));
        m->B[i] = (float *)malloc((size_t)m->b_count[i] * sizeof(float));

        fread(m->W[i], sizeof(float), (size_t)m->w_count[i], fp);
        fread(m->B[i], sizeof(float), (size_t)m->b_count[i], fp);

        /* Allocate gradient & optimizer arrays (needed if training continues) */
        m->dW[i] = (float *)calloc(m->w_count[i], sizeof(float));
        m->dB[i] = (float *)calloc(m->b_count[i], sizeof(float));
        m->mW[i] = (float *)calloc(m->w_count[i], sizeof(float));
        m->vW[i] = (float *)calloc(m->w_count[i], sizeof(float));
        m->mB[i] = (float *)calloc(m->b_count[i], sizeof(float));
        m->vB[i] = (float *)calloc(m->b_count[i], sizeof(float));
    }

    fclose(fp);

    int total = 0;
    for (int i = 0; i < m->num_layers; i++)
        total += m->w_count[i] + m->b_count[i];
    printf("Model loaded from %s  (%d× scale, %d→%d ch, %d layers, %d params)\n",
           path, m->scale_factor, m->in_channels, m->out_channels,
           m->num_layers, total);

    return m;
}

/* ============================================================================
 * GLSL export  —  inline constant arrays + compute shader reference
 * ========================================================================= */

static void write_float_array(FILE *fp, const char *name,
                               const float *data, int count)
{
    fprintf(fp, "const float %s[%d] = float[](\n", name, count);
    for (int i = 0; i < count; i++) {
        if (i % 8 == 0) fprintf(fp, "    ");
        fprintf(fp, "%.8e", (double)data[i]);
        if (i + 1 < count) fprintf(fp, ", ");
        if (i % 8 == 7 || i + 1 == count) fprintf(fp, "\n");
    }
    fprintf(fp, ");\n\n");
}

int model_export_glsl(const Model *m, const char *path, int tonemap_variant)
{
    FILE *fp = fopen(path, "wb");
    if (!fp) {
        fprintf(stderr, "ERROR: cannot create %s\n", path);
        return 0;
    }

    const int r  = m->scale_factor;
    const int nl = m->num_layers;

    /* Header */
    fprintf(fp,
        "/*\n"
        " * Auto-generated CNN Upscaler Weights\n"
        " *\n"
        " * Architecture: ESPCN (%d layers, %d× scale)\n"
        " * Input:  %d channels (%s)\n"
        " * Output: %d channels (RGB)\n"
        " * Color space: %s\n"
        " *\n"
        " * Layers:\n",
        nl, r,
        m->in_channels, m->in_channels == 4 ? "RGB+Depth" : "RGB",
        m->out_channels,
        m->colorspace == COLORSPACE_LINEAR ? "linear" : "sRGB");

    int total = 0;
    for (int i = 0; i < nl; i++) {
        int pc = m->w_count[i] + m->b_count[i];
        total += pc;
        fprintf(fp, " *   Layer %d: Conv%dx%d  %d→%d ch  %s  (%d params)\n",
                i, m->layer_ks[i], m->layer_ks[i],
                m->layer_in[i], m->layer_out[i],
                m->layer_relu[i] ? "+ ReLU" : "(linear)",
                pc);
    }
    fprintf(fp,
        " *   Pixel Shuffle (%d×)\n"
        " *\n"
        " * Total parameters: %d  (%.1f KB)\n"
        " */\n\n",
        r, total, (float)(total * 4) / 1024.0f);

    fprintf(fp, "#ifndef CNN_UPSCALER_WEIGHTS_GLSL\n"
                "#define CNN_UPSCALER_WEIGHTS_GLSL\n\n");

    /* Constants */
    fprintf(fp, "#define CNN_SCALE_FACTOR %d\n", r);
    fprintf(fp, "#define CNN_IN_CHANNELS  %d\n", m->in_channels);
    fprintf(fp, "#define CNN_NUM_LAYERS   %d\n\n", nl);

    /* Weight and bias arrays */
    for (int i = 0; i < nl; i++) {
        char wname[64], bname[64];
        snprintf(wname, sizeof(wname), "cnn_W%d", i);
        snprintf(bname, sizeof(bname), "cnn_B%d", i);
        write_float_array(fp, wname, m->W[i], m->w_count[i]);
        write_float_array(fp, bname, m->B[i], m->b_count[i]);
    }

    /* Tonemapping functions (if requested) */
    if (tonemap_variant == TONEMAP_BRIAN_KARIS) {
        fprintf(fp,
            "/* Bidirectional tonemapping — Brian Karis */\n"
            "vec3 cnn_tonemap(vec3 c) {\n"
            "    return c / (abs(dot(c, vec3(0.2125, 0.7154, 0.0721))) + 1.0);\n"
            "}\n"
            "vec3 cnn_inv_tonemap(vec3 c) {\n"
            "    return c / max(1.0 - abs(dot(c, vec3(0.2125, 0.7154, 0.0721))), 1e-5);\n"
            "}\n\n");
    } else if (tonemap_variant == TONEMAP_AMD) {
        fprintf(fp,
            "/* Bidirectional tonemapping — AMD */\n"
            "vec3 cnn_tonemap(vec3 c) {\n"
            "    return c / (max(max(c.x, c.y), c.z) + 1.0);\n"
            "}\n"
            "vec3 cnn_inv_tonemap(vec3 c) {\n"
            "    return c / max(1.0 - max(max(c.x, c.y), c.z), 1e-5);\n"
            "}\n\n");
    }

    /* ---- Reference inference function --------------------------------- */
    fprintf(fp,
        "/*\n"
        " * Reference per-pixel inference function.\n"
        " *\n"
        " * For each HR output pixel, this runs the full CNN at the\n"
        " * corresponding LR position and picks the sub-pixel value\n"
        " * via pixel shuffle.\n"
        " *\n"
        " * NOTE: This is correct but redundant — every HR pixel in the\n"
        " * same r×r block re-computes the same convolutions. For a\n"
        " * production shader, use separate passes or shared memory:\n"
        " *   Pass 1: Conv0+ReLU → intermediate texture (%d channels)\n"
        " *   Pass 2: Conv1+ReLU → intermediate texture (%d channels)\n",
        m->layer_out[0],
        nl >= 3 ? m->layer_out[1] : m->layer_out[0]);
    if (nl >= 4)
        fprintf(fp,
        " *   Pass 3: Conv2+ReLU → intermediate texture (%d channels)\n",
            m->layer_out[2]);
    fprintf(fp,
        " *   Pass %d: Conv%d+PixelShuffle → output (3 channels, HR)\n"
        " */\n",
        nl, nl - 1);

    fprintf(fp,
        "vec3 cnn_upscale_pixel(sampler2D inputTex, ivec2 hrCoord, ivec2 hrSize) {\n"
        "    const int r = CNN_SCALE_FACTOR;\n"
        "    const int rr = r * r;\n"
        "    ivec2 lrCoord = hrCoord / r;\n"
        "    int subY = hrCoord.y %% r;\n"
        "    int subX = hrCoord.x %% r;\n"
        "    ivec2 lrSize = hrSize / r;\n\n");

    /* Generate layer code */
    for (int li = 0; li < nl; li++) {
        int ic  = m->layer_in[li];
        int oc  = m->layer_out[li];
        int ks  = m->layer_ks[li];
        int pad = ks / 2;
        int relu = m->layer_relu[li];

        const char *in_name  = (li == 0) ? NULL : NULL; /* handled below */
        (void)in_name;

        fprintf(fp, "    /* Layer %d: Conv%dx%d  %d→%d%s */\n",
                li, ks, ks, ic, oc, relu ? " + ReLU" : "");
        fprintf(fp, "    float act%d[%d];\n", li + 1, oc);
        fprintf(fp, "    for (int oc = 0; oc < %d; oc++) {\n", oc);
        fprintf(fp, "        float sum = cnn_B%d[oc];\n", li);

        if (li == 0) {
            /* First layer reads from texture */
            fprintf(fp, "        for (int ic = 0; ic < %d; ic++) {\n", ic);
            fprintf(fp, "            for (int ky = -%d; ky <= %d; ky++) {\n", pad, pad);
            fprintf(fp, "                for (int kx = -%d; kx <= %d; kx++) {\n", pad, pad);
            fprintf(fp, "                    ivec2 pos = clamp(lrCoord + ivec2(kx, ky), ivec2(0), lrSize - 1);\n");
            if (ic <= 4) {
                fprintf(fp, "                    vec4 px = texelFetch(inputTex, pos, 0);\n");
                fprintf(fp, "                    float val = (ic < 3) ? ((ic == 0) ? px.r : (ic == 1) ? px.g : px.b) : px.a;\n");
            } else {
                fprintf(fp, "                    float val = texelFetch(inputTex, pos, 0)[ic];\n");
            }
            fprintf(fp, "                    int widx = (oc * %d + ic) * %d + (ky + %d) * %d + (kx + %d);\n",
                    ic, ks * ks, pad, ks, pad);
            fprintf(fp, "                    sum += val * cnn_W%d[widx];\n", li);
            fprintf(fp, "                }\n");
            fprintf(fp, "            }\n");
            fprintf(fp, "        }\n");
        } else {
            /* Subsequent layers read from previous activation array */
            fprintf(fp, "        /* This is a per-pixel approximation — each pixel only\n"
                        "           uses its own activation, ignoring spatial neighbors.\n"
                        "           For correct results, use multi-pass rendering. */\n");
            fprintf(fp, "        for (int ic = 0; ic < %d; ic++) {\n", ic);
            fprintf(fp, "            /* Center tap only (ky=0, kx=0) for reference */\n");
            fprintf(fp, "            int widx = (oc * %d + ic) * %d + %d;\n",
                    ic, ks * ks, pad * ks + pad);
            fprintf(fp, "            sum += act%d[ic] * cnn_W%d[widx];\n", li, li);
            fprintf(fp, "        }\n");
        }

        if (relu)
            fprintf(fp, "        act%d[oc] = max(sum, 0.0);\n", li + 1);
        else
            fprintf(fp, "        act%d[oc] = sum;\n", li + 1);
        fprintf(fp, "    }\n\n");
    }

    /* Pixel shuffle output selection */
    fprintf(fp,
        "    /* Pixel shuffle: select sub-pixel from final conv output */\n"
        "    int subIdx = subY * r + subX;\n"
        "    vec3 result;\n"
        "    result.r = act%d[0 * rr + subIdx];\n"
        "    result.g = act%d[1 * rr + subIdx];\n"
        "    result.b = act%d[2 * rr + subIdx];\n",
        nl, nl, nl);

    if (tonemap_variant != TONEMAP_NONE) {
        fprintf(fp,
            "\n    /* Apply inverse tonemapping (if input was tonemapped) */\n"
            "    /* result = cnn_inv_tonemap(result); */\n");
    }

    fprintf(fp,
        "    return clamp(result, 0.0, 1.0);\n"
        "}\n\n");

    /* Multi-pass compute shader reference */
    fprintf(fp,
        "/*\n"
        " * ===================================================================\n"
        " * MULTI-PASS COMPUTE SHADER REFERENCE\n"
        " * ===================================================================\n"
        " *\n"
        " * For correct and efficient inference, use separate compute passes:\n"
        " *\n");
    for (int li = 0; li < nl; li++) {
        fprintf(fp,
        " * Pass %d:  Conv%dx%d (%d→%d ch%s)\n"
        " *   Input:  %s\n"
        " *   Output: image2D/imageBuffer with %d channels\n"
        " *   Each thread computes one LR pixel's %d output channels.\n"
        " *   Spatial dimensions unchanged (LR resolution).\n"
        " *\n",
            li + 1, m->layer_ks[li], m->layer_ks[li],
            m->layer_in[li], m->layer_out[li],
            m->layer_relu[li] ? " + ReLU" : "",
            li == 0 ? "sampler2D (LR input)" : "previous pass output",
            m->layer_out[li], m->layer_out[li]);
    }
    fprintf(fp,
        " * Final:  Pixel Shuffle\n"
        " *   Read last conv output (%d channels at LR res)\n"
        " *   Write HR output (3 channels at %d× resolution)\n"
        " *   Each thread: hrCoord → lrCoord + sub-pixel index → select channel\n"
        " *\n"
        " * Total intermediate storage:\n",
        m->layer_out[nl - 1], r);
    for (int li = 0; li < nl; li++) {
        fprintf(fp, " *   Pass %d output: %d × LR_W × LR_H floats\n",
                li + 1, m->layer_out[li]);
    }
    fprintf(fp,
        " * ===================================================================\n"
        " */\n\n");

    fprintf(fp, "#endif /* CNN_UPSCALER_WEIGHTS_GLSL */\n");

    fclose(fp);
    printf("GLSL exported to %s  (%d parameters)\n", path, total);
    return 1;
}
