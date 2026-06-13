/*
 * vk_cnn.c — GPU-accelerated CNN operations via Vulkan compute
 *
 * Implements ESPCN forward/backward pass and Adam optimizer on GPU.
 * All operations recorded in single command buffers for minimal overhead.
 *
 * Copyright (C) 2026 Benjamin 'BeRo' Rosseaux. License see PasVulkan.Framework.pas (zlib)
 */

#ifdef USE_VULKAN

#include "vk_cnn.h"
#include "shader_spirv.h"
#include <time.h>

/* Ceiling division */
#define CDIV(a, b) (((a) + (b) - 1) / (b))

/* ============================================================================
 * Creation
 * ========================================================================= */

VkCNN *vkcnn_create(const Model *m, int host_mem, int training)
{
    VkCNN *g = (VkCNN *)calloc(1, sizeof(VkCNN));
    if (!g) { fprintf(stderr, "ERROR: alloc VkCNN\n"); exit(1); }

    g->training = training;

    /* Init Vulkan context */
    g->ctx = vkctx_create(!host_mem);  /* use_device_local = !host_mem */

    /* Create compute pipelines — only what's needed */
    g->pip_conv_fwd        = vkctx_create_pipeline(g->ctx, spirv_conv_forward,        CONV_FORWARD_SIZE);
    g->pip_pixel_shuffle   = vkctx_create_pipeline(g->ctx, spirv_pixel_shuffle,       PIXEL_SHUFFLE_SIZE);

    if (training) {
        g->pip_conv_bwd_data   = vkctx_create_pipeline(g->ctx, spirv_conv_backward_data,  CONV_BACKWARD_DATA_SIZE);
        g->pip_conv_bwd_filter = vkctx_create_pipeline(g->ctx, spirv_conv_backward_filter,CONV_BACKWARD_FILTER_SIZE);
        g->pip_conv_bwd_bias   = vkctx_create_pipeline(g->ctx, spirv_conv_backward_bias,  CONV_BACKWARD_BIAS_SIZE);
        g->pip_pixel_unshuffle = vkctx_create_pipeline(g->ctx, spirv_pixel_unshuffle,     PIXEL_UNSHUFFLE_SIZE);
        g->pip_relu_bwd        = vkctx_create_pipeline(g->ctx, spirv_relu_backward,       RELU_BACKWARD_SIZE);
        g->pip_adam            = vkctx_create_pipeline(g->ctx, spirv_adam_update,          ADAM_UPDATE_SIZE);
        g->pip_loss_grad       = vkctx_create_pipeline(g->ctx, spirv_loss_grad,           LOSS_GRAD_SIZE);
        g->pip_loss_reduce     = vkctx_create_pipeline(g->ctx, spirv_loss_reduce,         LOSS_REDUCE_SIZE);
        g->pip_scale_buffer    = vkctx_create_pipeline(g->ctx, spirv_scale_buffer,        SCALE_BUFFER_SIZE);
    }

    /* Copy model architecture */
    g->num_layers    = m->num_layers;
    g->scale_factor  = m->scale_factor;
    g->in_channels   = m->in_channels;
    g->out_channels  = m->out_channels;
    for (int i = 0; i < m->num_layers; i++) {
        g->layer_in[i]   = m->layer_in[i];
        g->layer_out[i]  = m->layer_out[i];
        g->layer_ks[i]   = m->layer_ks[i];
        g->layer_pad[i]  = m->layer_pad[i];
        g->layer_relu[i] = m->layer_relu[i];
        g->w_count[i]    = m->w_count[i];
        g->b_count[i]    = m->b_count[i];
    }

    /* Allocate parameter buffers (in VRAM when device-local) */
    for (int i = 0; i < g->num_layers; i++) {
        size_t wsz = (size_t)g->w_count[i] * sizeof(float);
        size_t bsz = (size_t)g->b_count[i] * sizeof(float);

        g->gW[i]  = vkctx_create_buffer_gpu(g->ctx, wsz);
        g->gB[i]  = vkctx_create_buffer_gpu(g->ctx, bsz);

        if (training) {
            g->gdW[i] = vkctx_create_buffer_gpu(g->ctx, wsz);
            g->gdB[i] = vkctx_create_buffer_gpu(g->ctx, bsz);
            g->gmW[i] = vkctx_create_buffer_gpu(g->ctx, wsz);
            g->gvW[i] = vkctx_create_buffer_gpu(g->ctx, wsz);
            g->gmB[i] = vkctx_create_buffer_gpu(g->ctx, bsz);
            g->gvB[i] = vkctx_create_buffer_gpu(g->ctx, bsz);

            /* Zero optimizer state */
            vkctx_zero_buffer(g->ctx, &g->gmW[i]);
            vkctx_zero_buffer(g->ctx, &g->gvW[i]);
            vkctx_zero_buffer(g->ctx, &g->gmB[i]);
            vkctx_zero_buffer(g->ctx, &g->gvB[i]);
        }
    }

    /* Upload initial weights */
    vkcnn_upload_weights(g, m);

    printf("VkCNN initialized: %d layers, %d× scale on %s\n",
           g->num_layers, g->scale_factor, g->ctx->deviceName);

    return g;
}

void vkcnn_destroy(VkCNN *g)
{
    if (!g) return;

    vkDeviceWaitIdle(g->ctx->device);

    for (int i = 0; i < g->num_layers; i++) {
        vkctx_destroy_buffer(g->ctx, &g->gW[i]);
        vkctx_destroy_buffer(g->ctx, &g->gB[i]);
        if (g->training) {
            vkctx_destroy_buffer(g->ctx, &g->gdW[i]);
            vkctx_destroy_buffer(g->ctx, &g->gdB[i]);
            vkctx_destroy_buffer(g->ctx, &g->gmW[i]);
            vkctx_destroy_buffer(g->ctx, &g->gvW[i]);
            vkctx_destroy_buffer(g->ctx, &g->gmB[i]);
            vkctx_destroy_buffer(g->ctx, &g->gvB[i]);
        }
    }

    for (int i = 0; i <= g->num_layers; i++) {
        vkctx_destroy_buffer(g->ctx, &g->gAct[i]);
        vkctx_destroy_buffer(g->ctx, &g->gGradAct[i]);
    }

    vkctx_destroy_buffer(g->ctx, &g->gInput);
    vkctx_destroy_buffer(g->ctx, &g->gOutput);
    vkctx_destroy_buffer(g->ctx, &g->gTarget);
    vkctx_destroy_buffer(g->ctx, &g->gGrad);
    vkctx_destroy_buffer(g->ctx, &g->gLossElem);
    vkctx_destroy_buffer(g->ctx, &g->gLossSum);

    vkctx_destroy_pipeline(g->ctx, g->pip_conv_fwd);
    vkctx_destroy_pipeline(g->ctx, g->pip_pixel_shuffle);

    if (g->training) {
        vkctx_destroy_pipeline(g->ctx, g->pip_conv_bwd_data);
        vkctx_destroy_pipeline(g->ctx, g->pip_conv_bwd_filter);
        vkctx_destroy_pipeline(g->ctx, g->pip_conv_bwd_bias);
        vkctx_destroy_pipeline(g->ctx, g->pip_pixel_unshuffle);
        vkctx_destroy_pipeline(g->ctx, g->pip_relu_bwd);
        vkctx_destroy_pipeline(g->ctx, g->pip_adam);
        vkctx_destroy_pipeline(g->ctx, g->pip_loss_grad);
        vkctx_destroy_pipeline(g->ctx, g->pip_loss_reduce);
        vkctx_destroy_pipeline(g->ctx, g->pip_scale_buffer);
    }

    vkctx_destroy(g->ctx);
    free(g);
}

/* ============================================================================
 * Weight sync
 * ========================================================================= */

void vkcnn_upload_weights(VkCNN *g, const Model *m)
{
    for (int i = 0; i < g->num_layers; i++) {
        vkctx_upload_staged(g->ctx, &g->gW[i], m->W[i], (size_t)g->w_count[i] * sizeof(float));
        vkctx_upload_staged(g->ctx, &g->gB[i], m->B[i], (size_t)g->b_count[i] * sizeof(float));
    }
}

void vkcnn_download_weights(VkCNN *g, Model *m)
{
    for (int i = 0; i < g->num_layers; i++) {
        vkctx_download_staged(g->ctx, &g->gW[i], m->W[i], (size_t)g->w_count[i] * sizeof(float));
        vkctx_download_staged(g->ctx, &g->gB[i], m->B[i], (size_t)g->b_count[i] * sizeof(float));
    }
}

/* ============================================================================
 * Buffer management
 * ========================================================================= */

void vkcnn_ensure_buffers(VkCNN *g, int batch, int h, int w)
{
    if (g->buf_h == h && g->buf_w == w && g->buf_n == batch) return;

    /* Free old activation/gradient buffers */
    for (int i = 0; i <= g->num_layers; i++) {
        vkctx_destroy_buffer(g->ctx, &g->gAct[i]);
        if (g->training) vkctx_destroy_buffer(g->ctx, &g->gGradAct[i]);
    }
    vkctx_destroy_buffer(g->ctx, &g->gInput);
    vkctx_destroy_buffer(g->ctx, &g->gOutput);
    if (g->training) {
        vkctx_destroy_buffer(g->ctx, &g->gTarget);
        vkctx_destroy_buffer(g->ctx, &g->gGrad);
        vkctx_destroy_buffer(g->ctx, &g->gLossElem);
        vkctx_destroy_buffer(g->ctx, &g->gLossSum);
    }

    /* Allocate new (in VRAM when using device-local mode) */
    for (int i = 0; i <= g->num_layers; i++) {
        int ch = (i == 0) ? g->in_channels : g->layer_out[i - 1];
        size_t sz = (size_t)batch * ch * h * w * sizeof(float);
        g->gAct[i] = vkctx_create_buffer_gpu(g->ctx, sz);
        if (g->training) g->gGradAct[i] = vkctx_create_buffer_gpu(g->ctx, sz);
    }

    int r  = g->scale_factor;
    int oh = h * r;
    int ow = w * r;
    size_t out_sz = (size_t)batch * 3 * oh * ow * sizeof(float);

    g->gInput    = vkctx_create_buffer_gpu(g->ctx, (size_t)batch * g->in_channels * h * w * sizeof(float));
    g->gOutput   = vkctx_create_buffer_gpu(g->ctx, out_sz);
    if (g->training) {
        g->gTarget   = vkctx_create_buffer_gpu(g->ctx, out_sz);
        g->gGrad     = vkctx_create_buffer_gpu(g->ctx, out_sz);
        g->gLossElem = vkctx_create_buffer_gpu(g->ctx, out_sz); /* device-local: reduced on GPU */
        g->gLossSum  = vkctx_create_buffer(g->ctx, sizeof(uint32_t)); /* host-visible: read single float */
    }

    g->buf_h = h;
    g->buf_w = w;
    g->buf_n = batch;
}

/* ============================================================================
 * GPU Forward Pass
 * ========================================================================= */

static void record_forward(VkCNN *g, int batch, int h, int w)
{
    /* Copy input buffer → act[0] */
    /* (We upload directly into gAct[0], so no copy needed) */

    for (int i = 0; i < g->num_layers; i++) {
        VkPC pc = {0};
        pc.p[0] = g->layer_in[i];
        pc.p[1] = g->layer_out[i];
        pc.p[2] = g->layer_ks[i];
        pc.p[3] = g->layer_pad[i];
        pc.p[4] = h;
        pc.p[5] = w;
        pc.p[6] = batch;
        pc.p[7] = g->layer_relu[i];

        uint32_t gx = CDIV(w, 16);
        uint32_t gy = CDIV(h, 16);
        uint32_t gz = (uint32_t)(batch * g->layer_out[i]);

        vkctx_cmd_dispatch(g->ctx, g->pip_conv_fwd,
                            &g->gW[i], &g->gB[i],
                            &g->gAct[i], &g->gAct[i + 1],
                            &pc, gx, gy, gz);
        vkctx_cmd_barrier(g->ctx);
    }

    /* Pixel shuffle: act[N] → gOutput */
    {
        VkPC pc = {0};
        pc.p[0] = g->scale_factor;
        pc.p[1] = g->out_channels;
        pc.p[4] = h;
        pc.p[5] = w;
        pc.p[6] = batch;

        int r = g->scale_factor;
        uint32_t gx = CDIV(w * r, 16);
        uint32_t gy = CDIV(h * r, 16);
        uint32_t gz = (uint32_t)(batch * g->out_channels);

        vkctx_cmd_dispatch(g->ctx, g->pip_pixel_shuffle,
                            &g->gAct[g->num_layers], &g->gOutput,
                            NULL, NULL,
                            &pc, gx, gy, gz);
        vkctx_cmd_barrier(g->ctx);
    }
}

void vkcnn_forward(VkCNN *g, const float *input, float *output,
                   int batch, int h, int w)
{
    vkcnn_ensure_buffers(g, batch, h, w);

    /* Upload input to act[0] GPU buffer */
    size_t in_sz = (size_t)batch * g->in_channels * h * w * sizeof(float);
    vkctx_upload_staged(g->ctx, &g->gAct[0], input, in_sz);

    /* Record & execute forward pass */
    vkctx_cmd_begin(g->ctx);
    record_forward(g, batch, h, w);
    vkctx_cmd_end(g->ctx);

    /* Download output */
    int r = g->scale_factor;
    size_t out_sz = (size_t)batch * 3 * (h * r) * (w * r) * sizeof(float);
    vkctx_download_staged(g->ctx, &g->gOutput, output, out_sz);
}

/* ============================================================================
 * GPU Backward Pass
 * ========================================================================= */

static void record_backward(VkCNN *g, int batch, int h, int w)
{
    int r = g->scale_factor;

    /* Pixel unshuffle: gGrad (HR) → gGradAct[N] (LR with r² channels) */
    {
        VkPC pc = {0};
        pc.p[0] = r;
        pc.p[1] = g->out_channels;
        pc.p[4] = h;
        pc.p[5] = w;
        pc.p[6] = batch;

        int rr  = r * r;
        int tch = g->out_channels * rr;
        uint32_t gx = CDIV(w, 16);
        uint32_t gy = CDIV(h, 16);
        uint32_t gz = (uint32_t)(batch * tch);

        vkctx_cmd_dispatch(g->ctx, g->pip_pixel_unshuffle,
                            &g->gGrad, &g->gGradAct[g->num_layers],
                            NULL, NULL,
                            &pc, gx, gy, gz);
        vkctx_cmd_barrier(g->ctx);
    }

    /* Backward through conv layers (reverse order) */
    for (int i = g->num_layers - 1; i >= 0; i--) {

        /* ReLU backward: zero gradient where activation ≤ 0 */
        if (g->layer_relu[i]) {
            int count = batch * g->layer_out[i] * h * w;
            VkPC pc = {0};
            pc.p[0] = count;

            vkctx_cmd_dispatch(g->ctx, g->pip_relu_bwd,
                                &g->gAct[i + 1], &g->gGradAct[i + 1],
                                NULL, NULL,
                                &pc, CDIV(count, 256), 1, 1);
            vkctx_cmd_barrier(g->ctx);
        }

        VkPC pc = {0};
        pc.p[0] = g->layer_in[i];
        pc.p[1] = g->layer_out[i];
        pc.p[2] = g->layer_ks[i];
        pc.p[3] = g->layer_pad[i];
        pc.p[4] = h;
        pc.p[5] = w;
        pc.p[6] = batch;

        /* Conv backward data (skip for first layer) */
        if (i > 0) {
            uint32_t gx = CDIV(w, 16);
            uint32_t gy = CDIV(h, 16);
            uint32_t gz = (uint32_t)(batch * g->layer_in[i]);

            vkctx_cmd_dispatch(g->ctx, g->pip_conv_bwd_data,
                                &g->gW[i], &g->gGradAct[i + 1],
                                &g->gGradAct[i], NULL,
                                &pc, gx, gy, gz);
        }

        /* Conv backward filter (dW) */
        {
            int tw = g->w_count[i];
            vkctx_cmd_dispatch(g->ctx, g->pip_conv_bwd_filter,
                                &g->gAct[i], &g->gGradAct[i + 1],
                                &g->gdW[i], NULL,
                                &pc, CDIV(tw, 256), 1, 1);
        }

        /* Conv backward bias (dB) */
        {
            VkPC pc_b = {0};
            pc_b.p[0] = g->layer_out[i];
            pc_b.p[4] = h;
            pc_b.p[5] = w;
            pc_b.p[6] = batch;

            vkctx_cmd_dispatch(g->ctx, g->pip_conv_bwd_bias,
                                &g->gGradAct[i + 1], &g->gdB[i],
                                NULL, NULL,
                                &pc_b, CDIV(g->layer_out[i], 256), 1, 1);
        }

        vkctx_cmd_barrier(g->ctx);
    }
}

/* ============================================================================
 * GPU Training step  (forward + loss + backward in one submission)
 * ========================================================================= */

float vkcnn_train_step(VkCNN *g,
                        const float *input, const float *target,
                        int batch, int h, int w, int loss_type)
{
    vkcnn_ensure_buffers(g, batch, h, w);

    int r  = g->scale_factor;
    int oh = h * r;
    int ow = w * r;

    /* Upload input and target */
    size_t in_sz  = (size_t)batch * g->in_channels * h * w * sizeof(float);
    size_t out_sz = (size_t)batch * 3 * oh * ow * sizeof(float);
    vkctx_upload_staged(g->ctx, &g->gAct[0], input, in_sz);
    vkctx_upload_staged(g->ctx, &g->gTarget, target, out_sz);

    /* Record all GPU operations */
    vkctx_cmd_begin(g->ctx);

    /* Forward pass */
    record_forward(g, batch, h, w);

    /* Loss + gradient computation */
    {
        int count = batch * 3 * oh * ow;
        VkPC pc = {0};
        pc.p[0] = count;
        pc.p[1] = loss_type;

        vkctx_cmd_dispatch(g->ctx, g->pip_loss_grad,
                            &g->gOutput, &g->gTarget,
                            &g->gGrad, &g->gLossElem,
                            &pc, CDIV(count, 256), 1, 1);
        vkctx_cmd_barrier(g->ctx);
    }

    /* Backward pass */
    record_backward(g, batch, h, w);

    vkctx_cmd_end(g->ctx);

    /* Compute total loss on CPU from per-element loss buffer */
    int count = batch * 3 * oh * ow;
    float *loss_data = (float *)g->gLossElem.mapped;
    double total_loss = 0.0;
    for (int j = 0; j < count; j++) {
        total_loss += (double)loss_data[j];
    }

    return (float)total_loss;
}

/* ============================================================================
 * Gradient management
 * ========================================================================= */

void vkcnn_zero_grad(VkCNN *g)
{
    for (int i = 0; i < g->num_layers; i++) {
        vkctx_zero_buffer(g->ctx, &g->gdW[i]);
        vkctx_zero_buffer(g->ctx, &g->gdB[i]);
    }
}

void vkcnn_scale_grads(VkCNN *g, float s)
{
    for (int i = 0; i < g->num_layers; i++) {
        /* Download grads to temp, scale, re-upload */
        size_t wsz = (size_t)g->w_count[i] * sizeof(float);
        size_t bsz = (size_t)g->b_count[i] * sizeof(float);

        float *dw = (float *)malloc(wsz);
        float *db = (float *)malloc(bsz);

        vkctx_download_staged(g->ctx, &g->gdW[i], dw, wsz);
        vkctx_download_staged(g->ctx, &g->gdB[i], db, bsz);

        for (int j = 0; j < g->w_count[i]; j++) dw[j] *= s;
        for (int j = 0; j < g->b_count[i]; j++) db[j] *= s;

        vkctx_upload_staged(g->ctx, &g->gdW[i], dw, wsz);
        vkctx_upload_staged(g->ctx, &g->gdB[i], db, bsz);

        free(dw);
        free(db);
    }
}

/* ============================================================================
 * Adam update on GPU
 * ========================================================================= */

void vkcnn_adam_update(VkCNN *g, float lr,
                       float beta1, float beta2, float eps, int step)
{
    float bc1 = 1.0f - powf(beta1, (float)step);
    float bc2 = 1.0f - powf(beta2, (float)step);

    vkctx_cmd_begin(g->ctx);

    for (int i = 0; i < g->num_layers; i++) {
        /* Update weights */
        {
            VkPC pc = {0};
            pc.p[0] = g->w_count[i];
            pc.f[0] = lr;
            pc.f[1] = beta1;
            pc.f[2] = beta2;
            pc.f[3] = eps;
            pc.f[4] = bc1;
            pc.f[5] = bc2;

            vkctx_cmd_dispatch(g->ctx, g->pip_adam,
                                &g->gW[i], &g->gdW[i],
                                &g->gmW[i], &g->gvW[i],
                                &pc, CDIV(g->w_count[i], 256), 1, 1);
        }

        /* Update biases */
        {
            VkPC pc = {0};
            pc.p[0] = g->b_count[i];
            pc.f[0] = lr;
            pc.f[1] = beta1;
            pc.f[2] = beta2;
            pc.f[3] = eps;
            pc.f[4] = bc1;
            pc.f[5] = bc2;

            vkctx_cmd_dispatch(g->ctx, g->pip_adam,
                                &g->gB[i], &g->gdB[i],
                                &g->gmB[i], &g->gvB[i],
                                &pc, CDIV(g->b_count[i], 256), 1, 1);
        }

        vkctx_cmd_barrier(g->ctx);
    }

    vkctx_cmd_end(g->ctx);
}

/* ============================================================================
 * Combined training step — entire iter in ONE GPU submission
 *
 * Does: zero_grad → forward → loss+grad → backward → scale_grads → adam
 * Only the scalar loss sum is read back via a tiny host-visible buffer.
 * ========================================================================= */

float vkcnn_train_step_full(VkCNN *g,
                             const float *input, const float *target,
                             int batch, int h, int w, int loss_type,
                             float lr, float beta1, float beta2,
                             float eps, int adam_step)
{
    vkcnn_ensure_buffers(g, batch, h, w);

    int r  = g->scale_factor;
    int oh = h * r;
    int ow = w * r;
    float inv_batch = 1.0f / (float)batch;

    /* Upload input and target (staging → device) */
    size_t in_sz  = (size_t)batch * g->in_channels * h * w * sizeof(float);
    size_t out_sz = (size_t)batch * 3 * oh * ow * sizeof(float);
    vkctx_upload_staged(g->ctx, &g->gAct[0], input, in_sz);
    vkctx_upload_staged(g->ctx, &g->gTarget, target, out_sz);

    /* Zero the loss sum accumulator (host-visible, direct write) */
    uint32_t zero = 0;
    memcpy(g->gLossSum.mapped, &zero, sizeof(uint32_t));

    /* ---- Record everything in ONE command buffer ---- */
    vkctx_cmd_begin(g->ctx);

    /* 1) Zero gradient buffers */
    for (int i = 0; i < g->num_layers; i++) {
        vkctx_cmd_fill_zero(g->ctx, &g->gdW[i]);
        vkctx_cmd_fill_zero(g->ctx, &g->gdB[i]);
    }
    vkctx_cmd_barrier(g->ctx);

    /* 2) Forward pass */
    record_forward(g, batch, h, w);

    /* 3) Loss + gradient computation */
    {
        int count = batch * 3 * oh * ow;
        VkPC pc = {0};
        pc.p[0] = count;
        pc.p[1] = loss_type;

        vkctx_cmd_dispatch(g->ctx, g->pip_loss_grad,
                            &g->gOutput, &g->gTarget,
                            &g->gGrad, &g->gLossElem,
                            &pc, CDIV(count, 256), 1, 1);
        vkctx_cmd_barrier(g->ctx);

        /* 3b) Parallel reduction of loss → gLossSum */
        VkPC rpc = {0};
        rpc.p[0] = count;
        uint32_t reduce_groups = CDIV(count, 256);
        if (reduce_groups > 1024) reduce_groups = 1024; /* cap for grid-stride loop */

        vkctx_cmd_dispatch(g->ctx, g->pip_loss_reduce,
                            &g->gLossElem, &g->gLossSum,
                            NULL, NULL,
                            &rpc, reduce_groups, 1, 1);
        vkctx_cmd_barrier(g->ctx);
    }

    /* 4) Backward pass */
    record_backward(g, batch, h, w);

    /* 5) Scale gradients by 1/batch on GPU */
    for (int i = 0; i < g->num_layers; i++) {
        {
            VkPC pc = {0};
            pc.p[0] = g->w_count[i];
            pc.f[0] = inv_batch;
            vkctx_cmd_dispatch(g->ctx, g->pip_scale_buffer,
                                &g->gdW[i], NULL, NULL, NULL,
                                &pc, CDIV(g->w_count[i], 256), 1, 1);
        }
        {
            VkPC pc = {0};
            pc.p[0] = g->b_count[i];
            pc.f[0] = inv_batch;
            vkctx_cmd_dispatch(g->ctx, g->pip_scale_buffer,
                                &g->gdB[i], NULL, NULL, NULL,
                                &pc, CDIV(g->b_count[i], 256), 1, 1);
        }
    }
    vkctx_cmd_barrier(g->ctx);

    /* 6) Adam update */
    {
        float bc1 = 1.0f - powf(beta1, (float)adam_step);
        float bc2 = 1.0f - powf(beta2, (float)adam_step);

        for (int i = 0; i < g->num_layers; i++) {
            {
                VkPC pc = {0};
                pc.p[0] = g->w_count[i];
                pc.f[0] = lr;
                pc.f[1] = beta1;
                pc.f[2] = beta2;
                pc.f[3] = eps;
                pc.f[4] = bc1;
                pc.f[5] = bc2;
                vkctx_cmd_dispatch(g->ctx, g->pip_adam,
                                    &g->gW[i], &g->gdW[i],
                                    &g->gmW[i], &g->gvW[i],
                                    &pc, CDIV(g->w_count[i], 256), 1, 1);
            }
            {
                VkPC pc = {0};
                pc.p[0] = g->b_count[i];
                pc.f[0] = lr;
                pc.f[1] = beta1;
                pc.f[2] = beta2;
                pc.f[3] = eps;
                pc.f[4] = bc1;
                pc.f[5] = bc2;
                vkctx_cmd_dispatch(g->ctx, g->pip_adam,
                                    &g->gB[i], &g->gdB[i],
                                    &g->gmB[i], &g->gvB[i],
                                    &pc, CDIV(g->b_count[i], 256), 1, 1);
            }
            vkctx_cmd_barrier(g->ctx);
        }
    }

    vkctx_cmd_end(g->ctx);  /* Submit + wait — single sync point! */

    /* Read back the scalar loss (single uint→float, from host-visible buffer) */
    uint32_t loss_bits;
    memcpy(&loss_bits, g->gLossSum.mapped, sizeof(uint32_t));
    float total_loss;
    memcpy(&total_loss, &loss_bits, sizeof(float));
    return total_loss;
}

#endif /* USE_VULKAN */
