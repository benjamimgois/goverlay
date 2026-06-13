/*
 * vk_cnn.h — GPU-accelerated CNN operations via Vulkan compute
 *
 * Drop-in GPU replacement for CPU model operations.
 * The Model struct is still used for save/load/export;
 * VkCNN holds the GPU-side state and syncs weights on demand.
 *
 * Copyright (C) 2026 Benjamin 'BeRo' Rosseaux. License see PasVulkan.Framework.pas (zlib)
 */

#ifndef VK_CNN_H
#define VK_CNN_H

#ifdef USE_VULKAN

#include "upscaler.h"
#include "vk_backend.h"

typedef struct {
    VkCtx *ctx;

    /* Compute pipelines (one per shader) */
    VkPipeline pip_conv_fwd;
    VkPipeline pip_conv_bwd_data;
    VkPipeline pip_conv_bwd_filter;
    VkPipeline pip_conv_bwd_bias;
    VkPipeline pip_pixel_shuffle;
    VkPipeline pip_pixel_unshuffle;
    VkPipeline pip_relu_bwd;
    VkPipeline pip_adam;
    VkPipeline pip_loss_grad;
    VkPipeline pip_loss_reduce;
    VkPipeline pip_scale_buffer;

    /* Model architecture (copy from Model) */
    int num_layers;
    int scale_factor;
    int in_channels;
    int out_channels;
    int layer_in [MAX_LAYERS];
    int layer_out[MAX_LAYERS];
    int layer_ks [MAX_LAYERS];
    int layer_pad[MAX_LAYERS];
    int layer_relu[MAX_LAYERS];
    int w_count[MAX_LAYERS];
    int b_count[MAX_LAYERS];

    /* GPU buffers for parameters */
    GpuBuf gW[MAX_LAYERS];       /* weights */
    GpuBuf gB[MAX_LAYERS];       /* biases  */
    GpuBuf gdW[MAX_LAYERS];      /* weight gradients */
    GpuBuf gdB[MAX_LAYERS];      /* bias gradients   */
    GpuBuf gmW[MAX_LAYERS];      /* Adam moment 1 (weights) */
    GpuBuf gvW[MAX_LAYERS];      /* Adam moment 2 (weights) */
    GpuBuf gmB[MAX_LAYERS];      /* Adam moment 1 (biases)  */
    GpuBuf gvB[MAX_LAYERS];      /* Adam moment 2 (biases)  */

    /* GPU buffers for activations & gradients */
    GpuBuf gAct    [MAX_LAYERS + 1];
    GpuBuf gGradAct[MAX_LAYERS + 1];

    /* Buffers for batched input/output/target/loss */
    GpuBuf gInput;               /* LR input batch  */
    GpuBuf gOutput;              /* HR output        */
    GpuBuf gTarget;              /* HR ground truth  */
    GpuBuf gGrad;                /* HR gradient      */
    GpuBuf gLossElem;            /* per-element loss */
    GpuBuf gLossSum;             /* scalar loss sum (uint for atomic CAS) */

    /* Allocated dimensions */
    int buf_h, buf_w, buf_n;

    /* Mode: 0 = inference only, 1 = training (has gradient/optimizer buffers) */
    int training;

} VkCNN;

/* Lifecycle.
 *   host_mem  = 0: use DEVICE_LOCAL memory (fast, default)
 *   host_mem  = 1: use HOST_VISIBLE memory (slower, for debugging or iGPUs)
 *   training  = 0: inference only (fewer pipelines & buffers, faster init)
 *   training  = 1: full training support */
VkCNN *vkcnn_create(const Model *m, int host_mem, int training);
void   vkcnn_destroy(VkCNN *g);

/* Sync weights between CPU Model and GPU VkCNN */
void vkcnn_upload_weights(VkCNN *g, const Model *m);
void vkcnn_download_weights(VkCNN *g, Model *m);

/* Ensure activation buffers are allocated for given dimensions */
void vkcnn_ensure_buffers(VkCNN *g, int batch, int h, int w);

/* Forward pass (GPU): input → output on CPU, computation on GPU */
void vkcnn_forward(VkCNN *g, const float *input, float *output,
                   int batch, int h, int w);

/* Full combined training step (GPU):
 *   Performs zero_grad + forward + loss + backward + scale_grads + adam_update
 *   in a single GPU submission. Returns total loss.
 *   Much faster than calling individual functions. */
float vkcnn_train_step_full(VkCNN *g,
                             const float *input, const float *target,
                             int batch, int h, int w, int loss_type,
                             float lr, float beta1, float beta2,
                             float eps, int adam_step);

/* Full training step (GPU) — legacy, uses separate submissions.
 *   input  = LR patches [batch × in_ch × h × w]
 *   target = HR patches [batch × 3 × (h*r) × (w*r)]
 *   Returns average loss for this batch.
 *   Gradients are accumulated (not zeroed — call vkcnn_zero_grad first). */
float vkcnn_train_step(VkCNN *g,
                        const float *input, const float *target,
                        int batch, int h, int w, int loss_type);

/* Zero all gradient buffers */
void vkcnn_zero_grad(VkCNN *g);

/* Scale gradients (for batch averaging) */
void vkcnn_scale_grads(VkCNN *g, float s);

/* Adam update on GPU */
void vkcnn_adam_update(VkCNN *g, float lr,
                       float beta1, float beta2, float eps, int step);

#endif /* USE_VULKAN */
#endif /* VK_CNN_H */
