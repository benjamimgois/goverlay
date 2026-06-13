/*
 * vk_backend.h — Vulkan compute backend infrastructure
 *
 * Thin abstraction over Vulkan for compute dispatch:
 *   - Instance/device/queue management
 *   - Buffer allocation (host-visible + coherent)
 *   - Compute pipeline creation from embedded SPIR-V
 *   - Descriptor set management
 *   - Synchronous command execution
 *
 * Copyright (C) 2026 Benjamin 'BeRo' Rosseaux. License see PasVulkan.Framework.pas (zlib)
 */

#ifndef VK_BACKEND_H
#define VK_BACKEND_H

#ifdef USE_VULKAN

#include <vulkan/vulkan.h>
#include <stdint.h>

/* Maximum descriptor sets per command buffer recording cycle */
#define VK_MAX_DESC_SETS 48

/* Push constants shared by all shaders (64 bytes) */
typedef struct {
    int32_t p[8];
    float   f[8];
} VkPC;

/* GPU buffer with persistent mapping */
typedef struct {
    VkBuffer       buffer;
    VkDeviceMemory memory;
    VkDeviceSize   size;
    void          *mapped;   /* non-NULL only for host-visible buffers */
    int            device_local; /* 1 if DEVICE_LOCAL without host mapping */
} GpuBuf;

/* Vulkan compute context */
typedef struct {
    VkInstance               instance;
    VkPhysicalDevice         physDev;
    VkDevice                 device;
    VkQueue                  queue;
    uint32_t                 queueFamily;

    VkCommandPool            cmdPool;
    VkCommandBuffer          cmdBuf;
    VkFence                  fence;

    VkDescriptorSetLayout    dsLayout;
    VkPipelineLayout         pipeLayout;
    VkDescriptorPool         dsPool;
    VkDescriptorSet          dsSets[VK_MAX_DESC_SETS];
    int                      dsNext;  /* next free descriptor set index */

    /* Small dummy buffer for unused SSBO bindings */
    GpuBuf                   dummy;

    /* Staging buffer (host-visible, reused for transfers) */
    GpuBuf                   staging;      /* upload: WC memory (fast writes) */
    VkDeviceSize             stagingCap;
    GpuBuf                   readback;     /* download: cached memory (fast reads) */
    VkDeviceSize             readbackCap;

    /* Pipeline cache (persisted to disk for fast subsequent launches) */
    VkPipelineCache          pipeCache;
    char                     pipeCachePath[512];

    /* Configuration */
    int                      use_device_local; /* 1 = DEVICE_LOCAL (fast), 0 = HOST_VISIBLE */

    /* Device properties */
    uint32_t                 maxWorkGroupSize;
    char                     deviceName[256];
} VkCtx;

/* ---- Lifecycle -------------------------------------------------------- */
VkCtx *vkctx_create(int use_device_local);
void   vkctx_destroy(VkCtx *ctx);

/* ---- Buffer management ------------------------------------------------ */

/* Create a host-visible buffer (always mapped, for staging/readback) */
GpuBuf vkctx_create_buffer(VkCtx *ctx, VkDeviceSize size);

/* Create a device-local buffer (fast VRAM, no CPU mapping).
 * Falls back to host-visible if use_device_local is 0. */
GpuBuf vkctx_create_buffer_gpu(VkCtx *ctx, VkDeviceSize size);

void   vkctx_destroy_buffer(VkCtx *ctx, GpuBuf *buf);

/* Direct memcpy for host-visible buffers */
void   vkctx_upload(GpuBuf *buf, const void *data, size_t bytes);
void   vkctx_download(const GpuBuf *buf, void *data, size_t bytes);
void   vkctx_zero_buffer(VkCtx *ctx, GpuBuf *buf);

/* Staged transfer for device-local buffers (CPU → staging → GPU copy).
 * These submit their own command buffer internally. */
void   vkctx_upload_staged(VkCtx *ctx, GpuBuf *dst, const void *data, size_t bytes);
void   vkctx_download_staged(VkCtx *ctx, const GpuBuf *src, void *data, size_t bytes);

/* Zero a device-local buffer via vkCmdFillBuffer (submits internally). */
void   vkctx_zero_buffer_gpu(VkCtx *ctx, GpuBuf *buf);

/* ---- Pipeline management ---------------------------------------------- */
VkPipeline vkctx_create_pipeline(VkCtx *ctx,
                                  const uint32_t *spirv, size_t spirv_size);
void       vkctx_destroy_pipeline(VkCtx *ctx, VkPipeline pipe);

/* ---- Command recording & execution ----------------------------------- */

/* Begin/end a command buffer recording session.
 * Between begin and end, use vkctx_cmd_* to record dispatches.
 * end() submits and waits for completion (synchronous). */
void vkctx_cmd_begin(VkCtx *ctx);
void vkctx_cmd_end(VkCtx *ctx);

/* Bind pipeline, bind 4 SSBOs, set push constants, dispatch */
void vkctx_cmd_dispatch(VkCtx *ctx,
                         VkPipeline pipeline,
                         GpuBuf *buf0, GpuBuf *buf1,
                         GpuBuf *buf2, GpuBuf *buf3,
                         const VkPC *pc,
                         uint32_t gx, uint32_t gy, uint32_t gz);

/* Insert a full memory barrier (for compute→compute dependencies) */
void vkctx_cmd_barrier(VkCtx *ctx);

/* Fill buffer with zeros via vkCmdFillBuffer (within command buffer) */
void vkctx_cmd_fill_zero(VkCtx *ctx, GpuBuf *buf);

#endif /* USE_VULKAN */
#endif /* VK_BACKEND_H */
