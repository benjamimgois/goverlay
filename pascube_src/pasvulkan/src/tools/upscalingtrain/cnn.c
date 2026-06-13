/*
 * cnn.c — Core CNN implementation
 *
 * - Random number generator (xoshiro128+)
 * - Conv2D forward / backward with same-padding
 * - Pixel shuffle / unshuffle
 * - ESPCN model creation, forward, backward
 * - Adam optimizer
 *
 * Copyright (C) 2026 Benjamin 'BeRo' Rosseaux. License see PasVulkan.Framework.pas (zlib)
 */

#include "upscaler.h"

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

/* ============================================================================
 * Random Number Generator  —  xoshiro128+
 * ========================================================================= */

static uint32_t rng_s[4];

static inline uint32_t rotl32(uint32_t x, int k) {
    return (x << k) | (x >> (32 - k));
}

static uint32_t rng_next(void) {
    const uint32_t result = rng_s[0] + rng_s[3];
    const uint32_t t = rng_s[1] << 9;
    rng_s[2] ^= rng_s[0];
    rng_s[3] ^= rng_s[1];
    rng_s[1] ^= rng_s[2];
    rng_s[0] ^= rng_s[3];
    rng_s[2] ^= t;
    rng_s[3] = rotl32(rng_s[3], 11);
    return result;
}

void rng_seed(uint32_t seed) {
    rng_s[0] = seed;
    rng_s[1] = seed ^ 0xDEADBEEFu;
    rng_s[2] = seed ^ 0xCAFEBABEu;
    rng_s[3] = seed ^ 0x12345678u;
    for (int i = 0; i < 20; i++) rng_next();
}

float rng_float(void) {
    return (float)(rng_next() >> 8) * (1.0f / 16777216.0f);
}

float rng_normal(void) {
    float u1, u2;
    do { u1 = rng_float(); } while (u1 < 1e-30f);
    u2 = rng_float();
    return sqrtf(-2.0f * logf(u1)) * cosf(2.0f * (float)M_PI * u2);
}

int rng_int(int lo, int hi) {
    if (lo >= hi) return lo;
    return lo + (int)(rng_float() * (float)(hi - lo + 1));
}

/* ============================================================================
 * Conv2D  —  Forward Pass
 *
 * input  : (batch, in_ch,  H, W)     CHW flat
 * output : (batch, out_ch, H, W)     same spatial dims (same-padding)
 * W      : (out_ch, in_ch, ks, ks)   flat
 * B      : (out_ch)
 * ========================================================================= */

static void conv2d_forward(const float * restrict W,
                           const float * restrict B,
                           const float * restrict input,
                           float       * restrict output,
                           int in_ch, int out_ch, int ks, int pad,
                           int batch, int H, int W_dim, int relu)
{
#ifdef _OPENMP
#pragma omp parallel for collapse(2) schedule(dynamic)
#endif
    for (int n = 0; n < batch; n++) {
        for (int oc = 0; oc < out_ch; oc++) {
            for (int oh = 0; oh < H; oh++) {
                for (int ow = 0; ow < W_dim; ow++) {
                    float sum = B[oc];
                    for (int ic = 0; ic < in_ch; ic++) {
                        const float *wptr = W + ((oc * in_ch + ic) * ks) * ks;
                        const float *iptr = input + (n * in_ch + ic) * H * W_dim;
                        for (int kh = 0; kh < ks; kh++) {
                            int ih = oh - pad + kh;
                            if (ih < 0 || ih >= H) continue;
                            const float *irow = iptr + ih * W_dim;
                            const float *wrow = wptr + kh * ks;
                            for (int kw = 0; kw < ks; kw++) {
                                int iw = ow - pad + kw;
                                if (iw >= 0 && iw < W_dim) {
                                    sum += wrow[kw] * irow[iw];
                                }
                            }
                        }
                    }
                    if (relu && sum < 0.0f) sum = 0.0f;
                    output[((n * out_ch + oc) * H + oh) * W_dim + ow] = sum;
                }
            }
        }
    }
}

/* ============================================================================
 * Conv2D  —  Backward Pass
 *
 * Computes:
 *   dW      += correlation(input, grad_output)
 *   dB      += sum(grad_output)
 *   grad_in  = full-conv(grad_output, flipped W)   [if grad_in != NULL]
 * ========================================================================= */

static void conv2d_backward(const float * restrict W,
                            const float * restrict input,
                            const float * restrict grad_out,
                            float       * restrict grad_in,   /* NULL for layer 0 */
                            float       * restrict dW,
                            float       * restrict dB,
                            int in_ch, int out_ch, int ks, int pad,
                            int batch, int H, int W_dim)
{
    /* --- dB ------------------------------------------------------------ */
    for (int oc = 0; oc < out_ch; oc++) {
        float sum = 0.0f;
        for (int n = 0; n < batch; n++) {
            const float *gptr = grad_out + (n * out_ch + oc) * H * W_dim;
            for (int p = 0; p < H * W_dim; p++) sum += gptr[p];
        }
        dB[oc] += sum;
    }

    /* --- dW ------------------------------------------------------------ */
#ifdef _OPENMP
#pragma omp parallel for collapse(2) schedule(dynamic)
#endif
    for (int oc = 0; oc < out_ch; oc++) {
        for (int ic = 0; ic < in_ch; ic++) {
            for (int kh = 0; kh < ks; kh++) {
                for (int kw = 0; kw < ks; kw++) {
                    float sum = 0.0f;
                    for (int n = 0; n < batch; n++) {
                        const float *gp = grad_out + (n * out_ch + oc) * H * W_dim;
                        const float *ip = input    + (n * in_ch  + ic) * H * W_dim;
                        for (int oh = 0; oh < H; oh++) {
                            int ih = oh - pad + kh;
                            if (ih < 0 || ih >= H) continue;
                            for (int ow = 0; ow < W_dim; ow++) {
                                int iw = ow - pad + kw;
                                if (iw >= 0 && iw < W_dim) {
                                    sum += gp[oh * W_dim + ow]
                                         * ip[ih * W_dim + iw];
                                }
                            }
                        }
                    }
                    dW[((oc * in_ch + ic) * ks + kh) * ks + kw] += sum;
                }
            }
        }
    }

    /* --- grad_input ---------------------------------------------------- */
    if (!grad_in) return;

    memset(grad_in, 0, (size_t)batch * in_ch * H * W_dim * sizeof(float));

#ifdef _OPENMP
#pragma omp parallel for collapse(2) schedule(dynamic)
#endif
    for (int n = 0; n < batch; n++) {
        for (int ic = 0; ic < in_ch; ic++) {
            float *gi = grad_in + (n * in_ch + ic) * H * W_dim;
            for (int ih = 0; ih < H; ih++) {
                for (int iw = 0; iw < W_dim; iw++) {
                    float sum = 0.0f;
                    for (int oc = 0; oc < out_ch; oc++) {
                        const float *gp = grad_out + (n * out_ch + oc) * H * W_dim;
                        const float *wp = W + (oc * in_ch + ic) * ks * ks;
                        for (int kh = 0; kh < ks; kh++) {
                            int oh = ih + pad - kh;
                            if (oh < 0 || oh >= H) continue;
                            for (int kw = 0; kw < ks; kw++) {
                                int ow = iw + pad - kw;
                                if (ow >= 0 && ow < W_dim) {
                                    sum += wp[kh * ks + kw]
                                         * gp[oh * W_dim + ow];
                                }
                            }
                        }
                    }
                    gi[ih * W_dim + iw] = sum;
                }
            }
        }
    }
}

/* ============================================================================
 * Pixel Shuffle  &  Unshuffle
 *
 * shuffle:   (N, C·r², H, W)  →  (N, C, H·r, W·r)
 * unshuffle: (N, C, H·r, W·r) →  (N, C·r², H, W)
 * ========================================================================= */

static void pixel_shuffle(const float *input, float *output,
                           int r, int out_ch, int batch, int H, int W_dim)
{
    const int rr  = r * r;
    const int oH  = H * r;
    const int oW  = W_dim * r;
    const int tch = out_ch * rr;   /* total input channels */

    for (int n = 0; n < batch; n++) {
        for (int c = 0; c < out_ch; c++) {
            for (int y = 0; y < oH; y++) {
                const int sy = y % r;
                const int ly = y / r;
                for (int x = 0; x < oW; x++) {
                    const int sx = x % r;
                    const int lx = x / r;
                    const int ic = c * rr + sy * r + sx;
                    output[((n * out_ch + c) * oH + y) * oW + x] =
                        input[((n * tch + ic) * H + ly) * W_dim + lx];
                }
            }
        }
    }
}

static void pixel_unshuffle(const float *input, float *output,
                             int r, int out_ch, int batch, int H, int W_dim)
{
    /* input:  (N, out_ch,      H·r, W·r)
     * output: (N, out_ch·r²,   H,   W)   */
    const int rr  = r * r;
    const int tch = out_ch * rr;
    const int iH  = H * r;
    const int iW  = W_dim * r;

    for (int n = 0; n < batch; n++) {
        for (int c = 0; c < out_ch; c++) {
            for (int y = 0; y < iH; y++) {
                const int sy = y % r;
                const int ly = y / r;
                for (int x = 0; x < iW; x++) {
                    const int sx = x % r;
                    const int lx = x / r;
                    const int oc = c * rr + sy * r + sx;
                    output[((n * tch + oc) * H + ly) * W_dim + lx] =
                        input[((n * out_ch + c) * iH + y) * iW + x];
                }
            }
        }
    }
}

/* ============================================================================
 * Internal buffer management
 * ========================================================================= */

static void model_ensure_buffers(Model *m, int batch, int h, int w)
{
    if (m->buf_h == h && m->buf_w == w && m->buf_n == batch)
        return;

    /* Free old */
    for (int i = 0; i <= m->num_layers; i++) {
        free(m->act[i]);      m->act[i]      = NULL;
        free(m->grad_act[i]); m->grad_act[i] = NULL;
    }

    /* Allocate new */
    for (int i = 0; i <= m->num_layers; i++) {
        int ch = (i == 0) ? m->in_channels : m->layer_out[i - 1];
        size_t sz = (size_t)batch * ch * h * w;
        m->act[i]      = (float *)calloc(sz, sizeof(float));
        m->grad_act[i] = (float *)calloc(sz, sizeof(float));
        if (!m->act[i] || !m->grad_act[i]) {
            fprintf(stderr, "ERROR: out of memory allocating layer %d buffers "
                    "(%zu floats)\n", i, sz);
            exit(1);
        }
    }

    m->buf_h = h;
    m->buf_w = w;
    m->buf_n = batch;
}

/* ============================================================================
 * Weight initialisation  —  He (Kaiming) for ReLU layers, Xavier for linear
 * ========================================================================= */

static void model_init_weights(Model *m)
{
    for (int i = 0; i < m->num_layers; i++) {
        int fan_in = m->layer_in[i] * m->layer_ks[i] * m->layer_ks[i];
        float std;
        if (m->layer_relu[i])
            std = sqrtf(2.0f / (float)fan_in);           /* He  */
        else
            std = sqrtf(1.0f / (float)fan_in);           /* Xavier-ish */

        for (int j = 0; j < m->w_count[i]; j++)
            m->W[i][j] = rng_normal() * std;
        /* biases stay zero (calloc) */
    }
}

/* ============================================================================
 * Model creation
 * ========================================================================= */

Model *model_create(int scale_factor, int in_channels,
                    int feat1, int feat2, int deep, int colorspace)
{
    Model *m = (Model *)calloc(1, sizeof(Model));
    if (!m) { fprintf(stderr, "ERROR: alloc Model\n"); exit(1); }

    m->scale_factor = scale_factor;
    m->in_channels  = in_channels;
    m->out_channels = 3;
    m->colorspace   = colorspace;

    const int r2 = scale_factor * scale_factor;

    if (deep) {
        /* 4-layer variant (recommended for 4× upscaling) */
        m->num_layers = 4;
        m->layer_in[0]  = in_channels; m->layer_out[0] = feat1;
        m->layer_ks[0]  = 5;           m->layer_relu[0] = 1;

        m->layer_in[1]  = feat1;       m->layer_out[1] = feat1;
        m->layer_ks[1]  = 3;           m->layer_relu[1] = 1;

        m->layer_in[2]  = feat1;       m->layer_out[2] = feat2;
        m->layer_ks[2]  = 3;           m->layer_relu[2] = 1;

        m->layer_in[3]  = feat2;       m->layer_out[3] = 3 * r2;
        m->layer_ks[3]  = 3;           m->layer_relu[3] = 0;
    } else {
        /* 3-layer standard ESPCN */
        m->num_layers = 3;
        m->layer_in[0]  = in_channels; m->layer_out[0] = feat1;
        m->layer_ks[0]  = 5;           m->layer_relu[0] = 1;

        m->layer_in[1]  = feat1;       m->layer_out[1] = feat2;
        m->layer_ks[1]  = 3;           m->layer_relu[1] = 1;

        m->layer_in[2]  = feat2;       m->layer_out[2] = 3 * r2;
        m->layer_ks[2]  = 3;           m->layer_relu[2] = 0;
    }

    for (int i = 0; i < m->num_layers; i++) {
        int ks = m->layer_ks[i];
        m->layer_pad[i] = ks / 2;
        m->w_count[i]   = m->layer_out[i] * m->layer_in[i] * ks * ks;
        m->b_count[i]   = m->layer_out[i];

        m->W[i]  = (float *)calloc(m->w_count[i], sizeof(float));
        m->B[i]  = (float *)calloc(m->b_count[i], sizeof(float));
        m->dW[i] = (float *)calloc(m->w_count[i], sizeof(float));
        m->dB[i] = (float *)calloc(m->b_count[i], sizeof(float));
        m->mW[i] = (float *)calloc(m->w_count[i], sizeof(float));
        m->vW[i] = (float *)calloc(m->w_count[i], sizeof(float));
        m->mB[i] = (float *)calloc(m->b_count[i], sizeof(float));
        m->vB[i] = (float *)calloc(m->b_count[i], sizeof(float));

        if (!m->W[i] || !m->B[i]) {
            fprintf(stderr, "ERROR: alloc layer %d weights\n", i);
            exit(1);
        }
    }

    model_init_weights(m);
    return m;
}

/* ============================================================================
 * Model destruction
 * ========================================================================= */

void model_free(Model *m)
{
    if (!m) return;
    for (int i = 0; i < m->num_layers; i++) {
        free(m->W[i]);  free(m->B[i]);
        free(m->dW[i]); free(m->dB[i]);
        free(m->mW[i]); free(m->vW[i]);
        free(m->mB[i]); free(m->vB[i]);
    }
    for (int i = 0; i <= m->num_layers; i++) {
        free(m->act[i]);
        free(m->grad_act[i]);
    }
    free(m);
}

/* ============================================================================
 * Forward pass
 *
 * input  : (batch, in_ch,  h, w)    — LR image patches
 * output : (batch, 3,      h·r, w·r) — HR result
 * ========================================================================= */

void model_forward(Model *m, const float *input, float *output,
                   int batch, int h, int w)
{
    model_ensure_buffers(m, batch, h, w);

    /* Copy input into act[0] */
    memcpy(m->act[0], input,
           (size_t)batch * m->in_channels * h * w * sizeof(float));

    /* Conv layers */
    for (int i = 0; i < m->num_layers; i++) {
        conv2d_forward(m->W[i], m->B[i],
                       m->act[i], m->act[i + 1],
                       m->layer_in[i], m->layer_out[i],
                       m->layer_ks[i], m->layer_pad[i],
                       batch, h, w,
                       m->layer_relu[i]);
    }

    /* Pixel shuffle: (batch, 3·r², h, w) → (batch, 3, h·r, w·r) */
    pixel_shuffle(m->act[m->num_layers], output,
                  m->scale_factor, m->out_channels, batch, h, w);
}

/* ============================================================================
 * Backward pass
 *
 * grad_output : (batch, 3, h·r, w·r)  — gradient of loss w.r.t. HR output
 *
 * Uses cached act[] from most recent forward().
 * Accumulates into dW[], dB[].
 * ========================================================================= */

void model_backward(Model *m, const float *grad_output)
{
    const int b = m->buf_n;
    const int h = m->buf_h;
    const int w = m->buf_w;
    const int r = m->scale_factor;

    /* Pixel unshuffle: (b, 3, h·r, w·r) → (b, 3·r², h, w) */
    pixel_unshuffle(grad_output, m->grad_act[m->num_layers],
                    r, m->out_channels, b, h, w);

    /* Backward through conv layers (reverse order) */
    for (int i = m->num_layers - 1; i >= 0; i--) {
        /* ReLU backward: zero gradient where activation was ≤ 0 */
        if (m->layer_relu[i]) {
            const int sz = b * m->layer_out[i] * h * w;
            float       *g = m->grad_act[i + 1];
            const float *a = m->act[i + 1];
            for (int j = 0; j < sz; j++) {
                if (a[j] <= 0.0f) g[j] = 0.0f;
            }
        }

        /* Conv backward */
        conv2d_backward(m->W[i], m->act[i], m->grad_act[i + 1],
                        (i > 0) ? m->grad_act[i] : NULL,
                        m->dW[i], m->dB[i],
                        m->layer_in[i], m->layer_out[i],
                        m->layer_ks[i], m->layer_pad[i],
                        b, h, w);
    }
}

/* ============================================================================
 * Training utilities
 * ========================================================================= */

void model_zero_grad(Model *m)
{
    for (int i = 0; i < m->num_layers; i++) {
        memset(m->dW[i], 0, (size_t)m->w_count[i] * sizeof(float));
        memset(m->dB[i], 0, (size_t)m->b_count[i] * sizeof(float));
    }
}

void model_scale_grads(Model *m, float s)
{
    for (int i = 0; i < m->num_layers; i++) {
        for (int j = 0; j < m->w_count[i]; j++) m->dW[i][j] *= s;
        for (int j = 0; j < m->b_count[i]; j++) m->dB[i][j] *= s;
    }
}

/* Adam with bias-corrected moments */
void model_adam_update(Model *m, float lr,
                       float beta1, float beta2, float eps, int step)
{
    const float bc1 = 1.0f - powf(beta1, (float)step);
    const float bc2 = 1.0f - powf(beta2, (float)step);

    for (int i = 0; i < m->num_layers; i++) {
        /* Weights */
        for (int j = 0; j < m->w_count[i]; j++) {
            float g = m->dW[i][j];
            m->mW[i][j] = beta1 * m->mW[i][j] + (1.0f - beta1) * g;
            m->vW[i][j] = beta2 * m->vW[i][j] + (1.0f - beta2) * g * g;
            float mh = m->mW[i][j] / bc1;
            float vh = m->vW[i][j] / bc2;
            m->W[i][j] -= lr * mh / (sqrtf(vh) + eps);
        }
        /* Biases */
        for (int j = 0; j < m->b_count[i]; j++) {
            float g = m->dB[i][j];
            m->mB[i][j] = beta1 * m->mB[i][j] + (1.0f - beta1) * g;
            m->vB[i][j] = beta2 * m->vB[i][j] + (1.0f - beta2) * g * g;
            float mh = m->mB[i][j] / bc1;
            float vh = m->vB[i][j] / bc2;
            m->B[i][j] -= lr * mh / (sqrtf(vh) + eps);
        }
    }
}
