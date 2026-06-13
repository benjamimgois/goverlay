/*
 * image.c — Image I/O and processing
 *
 * - PNG load/save via libpng
 * - Raw float32 depth loading
 * - Box-filter and bilinear downscaling
 * - Patch extraction for training
 * - Data augmentation (flip, 90° rotate)
 * - sRGB ↔ linear conversion
 * - Bidirectional tonemapping (Brian Karis, AMD)
 *
 * Copyright (C) 2026 Benjamin 'BeRo' Rosseaux. License see PasVulkan.Framework.pas (zlib)
 */

#include "upscaler.h"
#include <png.h>

/* ============================================================================
 * PNG Loading  —  always returns 3-channel CHW float in [0,1]
 * ========================================================================= */

float *image_load_png(const char *path, int *out_w, int *out_h, int *out_ch)
{
    FILE *fp = fopen(path, "rb");
    if (!fp) { fprintf(stderr, "ERROR: cannot open %s\n", path); return NULL; }

    png_structp png = png_create_read_struct(PNG_LIBPNG_VER_STRING,
                                             NULL, NULL, NULL);
    if (!png) { fclose(fp); return NULL; }

    png_infop info = png_create_info_struct(png);
    if (!info) { png_destroy_read_struct(&png, NULL, NULL); fclose(fp); return NULL; }

    if (setjmp(png_jmpbuf(png))) {
        png_destroy_read_struct(&png, &info, NULL);
        fclose(fp);
        return NULL;
    }

    png_init_io(png, fp);
    png_read_info(png, info);

    int width      = (int)png_get_image_width(png, info);
    int height     = (int)png_get_image_height(png, info);
    int color_type = png_get_color_type(png, info);
    int bit_depth  = png_get_bit_depth(png, info);

    /* Normalise to 8-bit RGB */
    if (bit_depth == 16) png_set_strip_16(png);
    if (color_type == PNG_COLOR_TYPE_PALETTE) png_set_palette_to_rgb(png);
    if (color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8)
        png_set_expand_gray_1_2_4_to_8(png);
    if (png_get_valid(png, info, PNG_INFO_tRNS))
        png_set_tRNS_to_alpha(png);
    if (color_type == PNG_COLOR_TYPE_GRAY ||
        color_type == PNG_COLOR_TYPE_GRAY_ALPHA)
        png_set_gray_to_rgb(png);

    png_read_update_info(png, info);

    int channels = (int)png_get_channels(png, info);  /* 3 or 4 */
    size_t rowbytes = png_get_rowbytes(png, info);

    png_bytep *rows = (png_bytep *)malloc((size_t)height * sizeof(png_bytep));
    for (int y = 0; y < height; y++)
        rows[y] = (png_byte *)malloc(rowbytes);

    png_read_image(png, rows);
    png_destroy_read_struct(&png, &info, NULL);
    fclose(fp);

    /* Convert to CHW float (only first 3 channels = RGB) */
    int out_channels = 3;
    float *data = (float *)malloc((size_t)out_channels * height * width * sizeof(float));
    if (!data) { fprintf(stderr, "ERROR: alloc image\n"); goto cleanup; }

    for (int y = 0; y < height; y++) {
        const png_byte *row = rows[y];
        for (int x = 0; x < width; x++) {
            for (int c = 0; c < out_channels; c++) {
                data[(c * height + y) * width + x] =
                    (float)row[x * channels + c] / 255.0f;
            }
        }
    }

    *out_w  = width;
    *out_h  = height;
    *out_ch = out_channels;

cleanup:
    for (int y = 0; y < height; y++) free(rows[y]);
    free(rows);
    return data;
}

/* ============================================================================
 * PNG Saving  —  CHW float [0,1] → 8-bit RGB PNG
 * ========================================================================= */

int image_save_png(const char *path, const float *data,
                   int w, int h, int channels)
{
    FILE *fp = fopen(path, "wb");
    if (!fp) { fprintf(stderr, "ERROR: cannot create %s\n", path); return 0; }

    png_structp png = png_create_write_struct(PNG_LIBPNG_VER_STRING,
                                              NULL, NULL, NULL);
    if (!png) { fclose(fp); return 0; }

    png_infop info = png_create_info_struct(png);
    if (!info) { png_destroy_write_struct(&png, NULL); fclose(fp); return 0; }

    if (setjmp(png_jmpbuf(png))) {
        png_destroy_write_struct(&png, &info);
        fclose(fp);
        return 0;
    }

    png_init_io(png, fp);

    int out_ch = (channels >= 3) ? 3 : 1;
    int color  = (out_ch == 3) ? PNG_COLOR_TYPE_RGB : PNG_COLOR_TYPE_GRAY;

    png_set_IHDR(png, info, (png_uint_32)w, (png_uint_32)h,
                 8, color, PNG_INTERLACE_NONE,
                 PNG_COMPRESSION_TYPE_DEFAULT,
                 PNG_FILTER_TYPE_DEFAULT);
    png_write_info(png, info);

    png_byte *row = (png_byte *)malloc((size_t)w * out_ch);
    for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
            for (int c = 0; c < out_ch; c++) {
                float v = data[(c * h + y) * w + x];
                if (v < 0.0f) v = 0.0f;
                if (v > 1.0f) v = 1.0f;
                row[x * out_ch + c] = (png_byte)(v * 255.0f + 0.5f);
            }
        }
        png_write_row(png, row);
    }

    free(row);
    png_write_end(png, NULL);
    png_destroy_write_struct(&png, &info);
    fclose(fp);
    return 1;
}

/* ============================================================================
 * Raw float32 depth loading
 * ========================================================================= */

float *image_load_depth(const char *path, int w, int h)
{
    FILE *fp = fopen(path, "rb");
    if (!fp) { fprintf(stderr, "WARN: cannot open depth %s\n", path); return NULL; }

    size_t count = (size_t)w * h;
    float *data = (float *)malloc(count * sizeof(float));
    if (!data) { fclose(fp); return NULL; }

    size_t read = fread(data, sizeof(float), count, fp);
    fclose(fp);

    if (read != count) {
        fprintf(stderr, "WARN: depth file %s: expected %zu floats, got %zu\n",
                path, count, read);
        free(data);
        return NULL;
    }

    /* Already in 1×H×W CHW (single channel) — normalise to [0,1] */
    float mn = data[0], mx = data[0];
    for (size_t i = 1; i < count; i++) {
        if (data[i] < mn) mn = data[i];
        if (data[i] > mx) mx = data[i];
    }
    if (mx - mn > 1e-10f) {
        float inv = 1.0f / (mx - mn);
        for (size_t i = 0; i < count; i++)
            data[i] = (data[i] - mn) * inv;
    } else {
        memset(data, 0, count * sizeof(float));
    }

    return data;
}

/* ============================================================================
 * Box-filter downscale  (integer factor)
 *
 * src : CHW  (ch × sh × sw)
 * Returns newly allocated CHW at (ch × oh × ow) where oh = sh/f, ow = sw/f
 * ========================================================================= */

float *image_downscale_box(const float *src, int sw, int sh,
                           int ch, int factor, int *ow, int *oh)
{
    *ow = sw / factor;
    *oh = sh / factor;
    const float inv = 1.0f / (float)(factor * factor);

    float *dst = (float *)calloc((size_t)ch * (*oh) * (*ow), sizeof(float));

    for (int c = 0; c < ch; c++) {
        for (int dy = 0; dy < *oh; dy++) {
            for (int dx = 0; dx < *ow; dx++) {
                float sum = 0.0f;
                for (int ky = 0; ky < factor; ky++) {
                    int sy = dy * factor + ky;
                    for (int kx = 0; kx < factor; kx++) {
                        int sx = dx * factor + kx;
                        sum += src[(c * sh + sy) * sw + sx];
                    }
                }
                dst[(c * (*oh) + dy) * (*ow) + dx] = sum * inv;
            }
        }
    }
    return dst;
}

/* ============================================================================
 * Bilinear downscale  (arbitrary target size)
 * ========================================================================= */

float *image_downscale_bilinear(const float *src, int sw, int sh,
                                int ch, int dw, int dh)
{
    float *dst = (float *)malloc((size_t)ch * dw * dh * sizeof(float));

    for (int c = 0; c < ch; c++) {
        for (int dy = 0; dy < dh; dy++) {
            float sy = ((float)dy + 0.5f) * (float)sh / (float)dh - 0.5f;
            int y0 = (int)floorf(sy);
            int y1 = y0 + 1;
            float fy = sy - (float)y0;
            if (y0 < 0)   y0 = 0;
            if (y1 >= sh)  y1 = sh - 1;

            for (int dx = 0; dx < dw; dx++) {
                float sx = ((float)dx + 0.5f) * (float)sw / (float)dw - 0.5f;
                int x0 = (int)floorf(sx);
                int x1 = x0 + 1;
                float fx = sx - (float)x0;
                if (x0 < 0)   x0 = 0;
                if (x1 >= sw)  x1 = sw - 1;

                float v00 = src[(c * sh + y0) * sw + x0];
                float v01 = src[(c * sh + y0) * sw + x1];
                float v10 = src[(c * sh + y1) * sw + x0];
                float v11 = src[(c * sh + y1) * sw + x1];

                dst[(c * dh + dy) * dw + dx] =
                    v00 * (1.0f - fx) * (1.0f - fy) +
                    v01 * fx          * (1.0f - fy) +
                    v10 * (1.0f - fx) * fy +
                    v11 * fx          * fy;
            }
        }
    }
    return dst;
}

/* ============================================================================
 * Patch extraction  —  extracts a random LR/HR patch pair from an HR image
 *
 * hr_rgb   : 3 × img_h × img_w   (ground truth RGB)
 * hr_depth : 1 × img_h × img_w   (optional, may be NULL)
 * lr_patch : in_channels × lps × lps   (pre-allocated, filled on output)
 * hr_patch : 3 × hps × hps             (pre-allocated, filled on output)
 *   where hps = lps * scale_factor
 * ========================================================================= */

int image_extract_patch_pair(const float *hr_rgb, const float *hr_depth,
                             int img_w, int img_h,
                             int scale_factor, int lr_patch_size,
                             int in_channels,
                             float *lr_patch, float *hr_patch)
{
    const int hps = lr_patch_size * scale_factor;
    const int lps = lr_patch_size;

    /* Image must be large enough and divisible by scale */
    int usable_w = (img_w / scale_factor) * scale_factor;
    int usable_h = (img_h / scale_factor) * scale_factor;

    if (usable_w < hps || usable_h < hps) return 0;

    /* Random top-left in HR space, aligned to scale factor */
    int max_y = (usable_h - hps) / scale_factor;
    int max_x = (usable_w - hps) / scale_factor;
    int y0 = rng_int(0, max_y) * scale_factor;
    int x0 = rng_int(0, max_x) * scale_factor;

    /* Extract HR RGB patch (3 × hps × hps) */
    for (int c = 0; c < 3; c++) {
        for (int py = 0; py < hps; py++) {
            for (int px = 0; px < hps; px++) {
                hr_patch[(c * hps + py) * hps + px] =
                    hr_rgb[(c * img_h + y0 + py) * img_w + x0 + px];
            }
        }
    }

    /* Box-filter HR patch → LR RGB patch (3 × lps × lps) */
    const float inv = 1.0f / (float)(scale_factor * scale_factor);
    for (int c = 0; c < 3; c++) {
        for (int ly = 0; ly < lps; ly++) {
            for (int lx = 0; lx < lps; lx++) {
                float sum = 0.0f;
                for (int ky = 0; ky < scale_factor; ky++) {
                    for (int kx = 0; kx < scale_factor; kx++) {
                        int hy = ly * scale_factor + ky;
                        int hx = lx * scale_factor + kx;
                        sum += hr_patch[(c * hps + hy) * hps + hx];
                    }
                }
                lr_patch[(c * lps + ly) * lps + lx] = sum * inv;
            }
        }
    }

    /* Optional depth channel (index 3 in LR patch) */
    if (in_channels > 3 && hr_depth) {
        for (int ly = 0; ly < lps; ly++) {
            for (int lx = 0; lx < lps; lx++) {
                float sum = 0.0f;
                for (int ky = 0; ky < scale_factor; ky++) {
                    for (int kx = 0; kx < scale_factor; kx++) {
                        int hy = ly * scale_factor + ky;
                        int hx = lx * scale_factor + kx;
                        int sy = y0 + hy;
                        int sx = x0 + hx;
                        sum += hr_depth[sy * img_w + sx];
                    }
                }
                lr_patch[(3 * lps + ly) * lps + lx] = sum * inv;
            }
        }
    } else if (in_channels > 3) {
        /* No depth available — fill with zeros */
        memset(lr_patch + 3 * lps * lps, 0,
               (size_t)(in_channels - 3) * lps * lps * sizeof(float));
    }

    return 1;
}

/* ============================================================================
 * Data augmentation  —  random horizontal flip, vertical flip, 90° rotation
 *
 * Operates in-place on two square patches (LR and HR).
 * ========================================================================= */

/* Flip a single square CHW patch horizontally */
static void flip_h(float *p, int s, int ch) {
    for (int c = 0; c < ch; c++)
        for (int y = 0; y < s; y++)
            for (int x = 0; x < s / 2; x++) {
                int a = (c * s + y) * s + x;
                int b = (c * s + y) * s + (s - 1 - x);
                float t = p[a]; p[a] = p[b]; p[b] = t;
            }
}

/* Flip a single square CHW patch vertically */
static void flip_v(float *p, int s, int ch) {
    for (int c = 0; c < ch; c++)
        for (int y = 0; y < s / 2; y++)
            for (int x = 0; x < s; x++) {
                int a = (c * s + y) * s + x;
                int b = (c * s + (s - 1 - y)) * s + x;
                float t = p[a]; p[a] = p[b]; p[b] = t;
            }
}

/* Transpose a single square CHW patch (90° CW = transpose + flip_h) */
static void transpose_patch(float *p, int s, int ch) {
    for (int c = 0; c < ch; c++)
        for (int y = 0; y < s; y++)
            for (int x = y + 1; x < s; x++) {
                int a = (c * s + y) * s + x;
                int b = (c * s + x) * s + y;
                float t = p[a]; p[a] = p[b]; p[b] = t;
            }
}

void image_augment(float *lr, float *hr,
                   int lr_s, int hr_s, int lr_ch, int hr_ch)
{
    /* Random horizontal flip */
    if (rng_float() < 0.5f) {
        flip_h(lr, lr_s, lr_ch);
        flip_h(hr, hr_s, hr_ch);
    }
    /* Random vertical flip */
    if (rng_float() < 0.5f) {
        flip_v(lr, lr_s, lr_ch);
        flip_v(hr, hr_s, hr_ch);
    }
    /* Random 90° rotation (transpose + horizontal flip) */
    if (rng_float() < 0.5f) {
        transpose_patch(lr, lr_s, lr_ch);
        flip_h(lr, lr_s, lr_ch);
        transpose_patch(hr, hr_s, hr_ch);
        flip_h(hr, hr_s, hr_ch);
    }
}

/* ============================================================================
 * sRGB ↔ linear conversion  (in-place)
 * ========================================================================= */

static inline float srgb_to_lin(float s) {
    return (s <= 0.04045f) ? s / 12.92f
                           : powf((s + 0.055f) / 1.055f, 2.4f);
}

static inline float lin_to_srgb(float l) {
    if (l <= 0.0f) return 0.0f;
    return (l <= 0.0031308f) ? l * 12.92f
                             : 1.055f * powf(l, 1.0f / 2.4f) - 0.055f;
}

void image_srgb_to_linear(float *data, int count) {
    for (int i = 0; i < count; i++) data[i] = srgb_to_lin(data[i]);
}

void image_linear_to_srgb(float *data, int count) {
    for (int i = 0; i < count; i++) data[i] = lin_to_srgb(data[i]);
}

/* ============================================================================
 * Bidirectional tonemapping
 *
 * Matches PasVulkan's bidirectional_tonemapping.glsl
 * Variants: Brian Karis (default in engine), AMD
 * Operates on first 3 channels (RGB) in CHW layout.
 * ========================================================================= */

void image_apply_tonemapping(float *data, int w, int h, int variant)
{
    if (variant == TONEMAP_NONE) return;

    for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
            float r = data[(0 * h + y) * w + x];
            float g = data[(1 * h + y) * w + x];
            float b = data[(2 * h + y) * w + x];

            if (variant == TONEMAP_BRIAN_KARIS) {
                /* color / (|luma| + 1)  where luma = dot(RGB, (0.2125, 0.7154, 0.0721)) */
                float luma = r * 0.2125f + g * 0.7154f + b * 0.0721f;
                float denom = fabsf(luma) + 1.0f;
                r /= denom; g /= denom; b /= denom;
            } else { /* TONEMAP_AMD */
                /* color / (max(R,G,B) + 1) */
                float mx = r; if (g > mx) mx = g; if (b > mx) mx = b;
                float denom = mx + 1.0f;
                r /= denom; g /= denom; b /= denom;
            }

            data[(0 * h + y) * w + x] = r;
            data[(1 * h + y) * w + x] = g;
            data[(2 * h + y) * w + x] = b;
        }
    }
}

void image_apply_inverse_tonemapping(float *data, int w, int h, int variant)
{
    if (variant == TONEMAP_NONE) return;

    for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
            float r = data[(0 * h + y) * w + x];
            float g = data[(1 * h + y) * w + x];
            float b = data[(2 * h + y) * w + x];

            if (variant == TONEMAP_BRIAN_KARIS) {
                /* color / max(1 - |luma|, 1e-5) */
                float luma = r * 0.2125f + g * 0.7154f + b * 0.0721f;
                float denom = 1.0f - fabsf(luma);
                if (denom < 1e-5f) denom = 1e-5f;
                r /= denom; g /= denom; b /= denom;
            } else { /* TONEMAP_AMD */
                /* color / max(1 - max(R,G,B), 1e-5) */
                float mx = r; if (g > mx) mx = g; if (b > mx) mx = b;
                float denom = 1.0f - mx;
                if (denom < 1e-5f) denom = 1e-5f;
                r /= denom; g /= denom; b /= denom;
            }

            data[(0 * h + y) * w + x] = r;
            data[(1 * h + y) * w + x] = g;
            data[(2 * h + y) * w + x] = b;
        }
    }
}
