/*
 * upscaler.h — CNN Image Upscaler (ESPCN Architecture)
 *
 * Single-header declarations for a pure-C CNN super-resolution tool.
 * Architecture: ESPCN (Efficient Sub-Pixel Convolutional Neural Network)
 *   Conv2D → ReLU → Conv2D → ReLU → Conv2D → PixelShuffle
 *
 * All computation in LR space; pixel shuffle rearranges to HR output.
 * Training uses patch-based L1/MSE loss with Adam optimizer.
 *
 * Copyright (C) 2026 Benjamin 'BeRo' Rosseaux. License see PasVulkan.Framework.pas (zlib)
 */

#ifndef UPSCALER_H
#define UPSCALER_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdint.h>
#include <float.h>

/* ============================================================================
 * Constants & Defaults
 * ========================================================================= */

#define MAX_LAYERS            8
#define DEFAULT_SCALE         2
#define DEFAULT_FEATURES_1    64
#define DEFAULT_FEATURES_2    32
#define DEFAULT_LR            0.001f
#define DEFAULT_BETA1         0.9f
#define DEFAULT_BETA2         0.999f
#define DEFAULT_EPSILON       1e-8f
#define DEFAULT_EPOCHS        200
#define DEFAULT_BATCH_SIZE    16
#define DEFAULT_PATCH_SIZE    32    /* LR patch side length */
#define DEFAULT_LR_DECAY      100   /* halve LR every N epochs */
#define DEFAULT_SEED          42
#define DEFAULT_SAVE_EVERY    50

/* Color-space modes */
#define COLORSPACE_SRGB       0
#define COLORSPACE_LINEAR     1

/* Loss functions */
#define LOSS_L1               0
#define LOSS_MSE              1

/* Tonemapping variants (matching bidirectional_tonemapping.glsl) */
#define TONEMAP_NONE          0
#define TONEMAP_BRIAN_KARIS   1
#define TONEMAP_AMD           2

/* Binary model file magic */
#define MODEL_MAGIC           0x554E4E43u  /* "CNNU" little-endian */
#define MODEL_VERSION         1

/* ============================================================================
 * Random Number Generator
 * ========================================================================= */

void  rng_seed(uint32_t seed);
float rng_float(void);          /* uniform [0, 1)   */
float rng_normal(void);         /* standard normal   */
int   rng_int(int lo, int hi);  /* uniform [lo, hi]  */

/* ============================================================================
 * Model
 * ========================================================================= */

typedef struct {
    /* --- Architecture --------------------------------------------------- */
    int num_layers;
    int scale_factor;       /* 2 or 4                     */
    int in_channels;        /* 3 (RGB) or 4 (RGB+Depth)   */
    int out_channels;       /* always 3 (RGB)             */
    int colorspace;         /* COLORSPACE_SRGB / _LINEAR  */

    /* Per-layer configuration */
    int layer_in [MAX_LAYERS];
    int layer_out[MAX_LAYERS];
    int layer_ks [MAX_LAYERS];   /* kernel size */
    int layer_pad[MAX_LAYERS];   /* padding = ks/2 */
    int layer_relu[MAX_LAYERS];  /* 1 = ReLU after conv */
    int w_count[MAX_LAYERS];     /* weights per layer */
    int b_count[MAX_LAYERS];     /* biases per layer  */

    /* --- Learnable parameters ------------------------------------------- */
    float *W[MAX_LAYERS];        /* weights  [oc][ic][kh][kw] flat */
    float *B[MAX_LAYERS];        /* biases   [oc]                  */

    /* Gradient accumulators */
    float *dW[MAX_LAYERS];
    float *dB[MAX_LAYERS];

    /* Adam first / second moments */
    float *mW[MAX_LAYERS];
    float *vW[MAX_LAYERS];
    float *mB[MAX_LAYERS];
    float *vB[MAX_LAYERS];

    /* --- Forward / backward cache --------------------------------------- */
    float *act     [MAX_LAYERS + 1];  /* act[0]=input … act[N]=last conv */
    float *grad_act[MAX_LAYERS + 1];  /* gradient buffers                */
    int buf_h, buf_w, buf_n;          /* allocated spatial dims           */
} Model;

/* Lifecycle */
Model *model_create(int scale_factor, int in_channels,
                    int feat1, int feat2, int deep, int colorspace);
void   model_free(Model *model);

/* Forward / backward (h, w = LR spatial dims) */
void model_forward (Model *m, const float *input,  float *output,
                    int batch, int h, int w);
void model_backward(Model *m, const float *grad_output);

/* Training helpers */
void model_zero_grad  (Model *m);
void model_scale_grads(Model *m, float s);
void model_adam_update(Model *m, float lr,
                       float beta1, float beta2, float eps, int step);

/* ============================================================================
 * Image I/O & Processing
 * ========================================================================= */

/*
 * All image data uses CHW layout (channel-first):
 *   data[(c * H + y) * W + x]
 * Float range [0, 1] for 8-bit PNG values.
 * Returned pointers must be freed with free().
 */

/* PNG  (always outputs 3-channel RGB, strips alpha, expands gray) */
float *image_load_png(const char *path, int *out_w, int *out_h, int *out_ch);
int    image_save_png(const char *path, const float *data,
                      int w, int h, int channels);

/* Raw float32 depth (no header, width×height floats) */
float *image_load_depth(const char *path, int w, int h);

/* Downscaling */
float *image_downscale_box(const float *src, int sw, int sh,
                           int ch, int factor, int *ow, int *oh);
float *image_downscale_bilinear(const float *src, int sw, int sh,
                                int ch, int dw, int dh);

/* Extract LR/HR patch pair from a full-size HR image.
 * lr_patch and hr_patch must be pre-allocated:
 *   lr_patch: in_channels × lr_ps × lr_ps
 *   hr_patch: 3           × hr_ps × hr_ps   (hr_ps = lr_ps * scale)
 * depth may be NULL; if non-NULL it must be 1×sh×sw CHW.
 * Returns 1 on success. */
int image_extract_patch_pair(const float *hr_rgb, const float *hr_depth,
                             int img_w, int img_h,
                             int scale_factor, int lr_patch_size,
                             int in_channels,
                             float *lr_patch, float *hr_patch);

/* In-place augmentation (random flip / 90° rotation) for a pair of patches */
void image_augment(float *lr, float *hr,
                   int lr_s, int hr_s, int lr_ch, int hr_ch);

/* Colour-space conversion (in-place, count = total float elements) */
void image_srgb_to_linear(float *data, int count);
void image_linear_to_srgb(float *data, int count);

/* Bidirectional tonemapping (in-place, CHW, operates on first 3 channels) */
void image_apply_tonemapping        (float *data, int w, int h, int variant);
void image_apply_inverse_tonemapping(float *data, int w, int h, int variant);

/* ============================================================================
 * Model Save / Load / Export
 * ========================================================================= */

int    model_save(const Model *m, const char *path);
Model *model_load(const char *path);

/* Export weights as GLSL source with inline constant arrays */
int model_export_glsl(const Model *m, const char *path, int tonemap_variant);

/* ============================================================================
 * Vulkan Compute Backend (optional, compile with -DUSE_VULKAN)
 * ========================================================================= */

#ifdef USE_VULKAN
#include "vk_cnn.h"
#endif

#endif /* UPSCALER_H */
