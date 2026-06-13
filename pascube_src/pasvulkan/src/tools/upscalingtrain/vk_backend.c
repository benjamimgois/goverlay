/*
 * vk_backend.c — Vulkan compute backend implementation
 *
 * All buffers use HOST_VISIBLE + HOST_COHERENT memory with persistent mapping.
 * This works on all GPUs and provides zero-copy access on integrated GPUs.
 * Execution is synchronous (submit + fence wait).
 *
 * Copyright (C) 2026 Benjamin 'BeRo' Rosseaux. License see PasVulkan.Framework.pas (zlib)
 */

#ifdef USE_VULKAN

#include "vk_backend.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* ============================================================================
 * Helpers
 * ========================================================================= */

#define VK_CHECK(call) do {                                \
    VkResult _r = (call);                                  \
    if (_r != VK_SUCCESS) {                                \
        fprintf(stderr, "Vulkan error %d at %s:%d\n",      \
                (int)_r, __FILE__, __LINE__);               \
        exit(1);                                           \
    }                                                      \
} while(0)

static uint32_t find_memory_type(VkPhysicalDevice physDev,
                                  uint32_t typeBits,
                                  VkMemoryPropertyFlags props)
{
    VkPhysicalDeviceMemoryProperties mem;
    vkGetPhysicalDeviceMemoryProperties(physDev, &mem);

    /* Prefer HOST_VISIBLE + DEVICE_LOCAL if available */
    for (uint32_t i = 0; i < mem.memoryTypeCount; i++) {
        if ((typeBits & (1u << i)) &&
            (mem.memoryTypes[i].propertyFlags & (props | VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT))
                == (props | VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)) {
            return i;
        }
    }
    /* Fall back to just the requested properties */
    for (uint32_t i = 0; i < mem.memoryTypeCount; i++) {
        if ((typeBits & (1u << i)) &&
            (mem.memoryTypes[i].propertyFlags & props) == props) {
            return i;
        }
    }
    fprintf(stderr, "ERROR: no suitable memory type found\n");
    exit(1);
}

/* Like find_memory_type but matches exactly — does NOT try to add DEVICE_LOCAL.
 * Used for readback buffers where we need HOST_CACHED (not WC/BAR memory). */
static uint32_t find_memory_type_exact(VkPhysicalDevice physDev,
                                       uint32_t typeBits,
                                       VkMemoryPropertyFlags props)
{
    VkPhysicalDeviceMemoryProperties mem;
    vkGetPhysicalDeviceMemoryProperties(physDev, &mem);

    for (uint32_t i = 0; i < mem.memoryTypeCount; i++) {
        if ((typeBits & (1u << i)) &&
            (mem.memoryTypes[i].propertyFlags & props) == props) {
            return i;
        }
    }
    fprintf(stderr, "ERROR: no suitable memory type found (exact)\n");
    exit(1);
}

/* ============================================================================
 * Context creation
 * ========================================================================= */

VkCtx *vkctx_create(int use_device_local)
{
    VkCtx *ctx = (VkCtx *)calloc(1, sizeof(VkCtx));
    ctx->use_device_local = use_device_local;

    /* ---- Instance ----------------------------------------------------- */
    VkApplicationInfo appInfo = {
        .sType              = VK_STRUCTURE_TYPE_APPLICATION_INFO,
        .pApplicationName   = "CNN Upscaler",
        .applicationVersion = 1,
        .pEngineName        = "PasVulkan-Tools",
        .engineVersion      = 1,
        .apiVersion         = VK_API_VERSION_1_0
    };

    VkInstanceCreateInfo instInfo = {
        .sType            = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        .pApplicationInfo = &appInfo
    };

    VK_CHECK(vkCreateInstance(&instInfo, NULL, &ctx->instance));

    /* ---- Physical device (prefer discrete GPU) ------------------------ */
    uint32_t devCount = 0;
    vkEnumeratePhysicalDevices(ctx->instance, &devCount, NULL);
    if (devCount == 0) {
        fprintf(stderr, "ERROR: no Vulkan-capable GPU found\n");
        exit(1);
    }

    VkPhysicalDevice *devs = (VkPhysicalDevice *)malloc(devCount * sizeof(VkPhysicalDevice));
    vkEnumeratePhysicalDevices(ctx->instance, &devCount, devs);

    /* Score devices: discrete > integrated > virtual > cpu */
    int bestScore = -1;
    for (uint32_t i = 0; i < devCount; i++) {
        VkPhysicalDeviceProperties props;
        vkGetPhysicalDeviceProperties(devs[i], &props);
        int score = 0;
        switch (props.deviceType) {
            case VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU:   score = 4; break;
            case VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU: score = 3; break;
            case VK_PHYSICAL_DEVICE_TYPE_VIRTUAL_GPU:    score = 2; break;
            case VK_PHYSICAL_DEVICE_TYPE_CPU:            score = 1; break;
            default:                                     score = 0; break;
        }
        if (score > bestScore) {
            bestScore    = score;
            ctx->physDev = devs[i];
        }
    }
    free(devs);

    VkPhysicalDeviceProperties devProps;
    vkGetPhysicalDeviceProperties(ctx->physDev, &devProps);
    strncpy(ctx->deviceName, devProps.deviceName, sizeof(ctx->deviceName) - 1);
    ctx->deviceName[sizeof(ctx->deviceName) - 1] = '\0';
    ctx->maxWorkGroupSize = devProps.limits.maxComputeWorkGroupInvocations;
    printf("Vulkan GPU: %s (max workgroup: %u)\n",
           ctx->deviceName, ctx->maxWorkGroupSize);

    /* ---- Compute queue family ----------------------------------------- */
    uint32_t qfCount = 0;
    vkGetPhysicalDeviceQueueFamilyProperties(ctx->physDev, &qfCount, NULL);
    VkQueueFamilyProperties *qfProps = (VkQueueFamilyProperties *)
        malloc(qfCount * sizeof(VkQueueFamilyProperties));
    vkGetPhysicalDeviceQueueFamilyProperties(ctx->physDev, &qfCount, qfProps);

    ctx->queueFamily = UINT32_MAX;
    for (uint32_t i = 0; i < qfCount; i++) {
        if (qfProps[i].queueFlags & VK_QUEUE_COMPUTE_BIT) {
            /* Prefer a compute-only queue (avoids contention with graphics) */
            if (!(qfProps[i].queueFlags & VK_QUEUE_GRAPHICS_BIT) ||
                ctx->queueFamily == UINT32_MAX) {
                ctx->queueFamily = i;
                if (!(qfProps[i].queueFlags & VK_QUEUE_GRAPHICS_BIT))
                    break;  /* Found compute-only, stop looking */
            }
        }
    }
    free(qfProps);

    if (ctx->queueFamily == UINT32_MAX) {
        fprintf(stderr, "ERROR: no compute queue found\n");
        exit(1);
    }

    /* ---- Logical device ----------------------------------------------- */
    float prio = 1.0f;
    VkDeviceQueueCreateInfo queueInfo = {
        .sType            = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
        .queueFamilyIndex = ctx->queueFamily,
        .queueCount       = 1,
        .pQueuePriorities = &prio
    };

    VkDeviceCreateInfo devInfo = {
        .sType                = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
        .queueCreateInfoCount = 1,
        .pQueueCreateInfos    = &queueInfo
    };

    VK_CHECK(vkCreateDevice(ctx->physDev, &devInfo, NULL, &ctx->device));
    vkGetDeviceQueue(ctx->device, ctx->queueFamily, 0, &ctx->queue);

    /* ---- Command pool & buffer ---------------------------------------- */
    VkCommandPoolCreateInfo poolInfo = {
        .sType            = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
        .flags            = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT,
        .queueFamilyIndex = ctx->queueFamily
    };
    VK_CHECK(vkCreateCommandPool(ctx->device, &poolInfo, NULL, &ctx->cmdPool));

    VkCommandBufferAllocateInfo cmdInfo = {
        .sType              = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
        .commandPool        = ctx->cmdPool,
        .level              = VK_COMMAND_BUFFER_LEVEL_PRIMARY,
        .commandBufferCount = 1
    };
    VK_CHECK(vkAllocateCommandBuffers(ctx->device, &cmdInfo, &ctx->cmdBuf));

    /* ---- Fence -------------------------------------------------------- */
    VkFenceCreateInfo fenceInfo = {
        .sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO,
        .flags = 0
    };
    VK_CHECK(vkCreateFence(ctx->device, &fenceInfo, NULL, &ctx->fence));

    /* ---- Descriptor set layout (4 SSBOs) ------------------------------ */
    VkDescriptorSetLayoutBinding bindings[4];
    for (int i = 0; i < 4; i++) {
        bindings[i] = (VkDescriptorSetLayoutBinding){
            .binding         = (uint32_t)i,
            .descriptorType  = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
            .descriptorCount = 1,
            .stageFlags      = VK_SHADER_STAGE_COMPUTE_BIT
        };
    }

    VkDescriptorSetLayoutCreateInfo dsLayoutInfo = {
        .sType        = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
        .bindingCount = 4,
        .pBindings    = bindings
    };
    VK_CHECK(vkCreateDescriptorSetLayout(ctx->device, &dsLayoutInfo,
                                          NULL, &ctx->dsLayout));

    /* ---- Pipeline layout (4 SSBOs + 64-byte push constants) ----------- */
    VkPushConstantRange pcRange = {
        .stageFlags = VK_SHADER_STAGE_COMPUTE_BIT,
        .offset     = 0,
        .size       = sizeof(VkPC)
    };

    VkPipelineLayoutCreateInfo plInfo = {
        .sType                  = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
        .setLayoutCount         = 1,
        .pSetLayouts            = &ctx->dsLayout,
        .pushConstantRangeCount = 1,
        .pPushConstantRanges    = &pcRange
    };
    VK_CHECK(vkCreatePipelineLayout(ctx->device, &plInfo,
                                     NULL, &ctx->pipeLayout));

    /* ---- Descriptor pool & sets --------------------------------------- */
    VkDescriptorPoolSize poolSz = {
        .type            = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
        .descriptorCount = 4 * VK_MAX_DESC_SETS
    };

    VkDescriptorPoolCreateInfo dpInfo = {
        .sType         = VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO,
        .maxSets       = VK_MAX_DESC_SETS,
        .poolSizeCount = 1,
        .pPoolSizes    = &poolSz
    };
    VK_CHECK(vkCreateDescriptorPool(ctx->device, &dpInfo,
                                     NULL, &ctx->dsPool));

    VkDescriptorSetLayout layouts[VK_MAX_DESC_SETS];
    for (int i = 0; i < VK_MAX_DESC_SETS; i++) layouts[i] = ctx->dsLayout;

    VkDescriptorSetAllocateInfo dsAlloc = {
        .sType              = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO,
        .descriptorPool     = ctx->dsPool,
        .descriptorSetCount = VK_MAX_DESC_SETS,
        .pSetLayouts        = layouts
    };
    VK_CHECK(vkAllocateDescriptorSets(ctx->device, &dsAlloc, ctx->dsSets));
    ctx->dsNext = 0;

    /* ---- Dummy buffer (16 bytes, for unused SSBO bindings) ------------ */
    ctx->dummy = vkctx_create_buffer(ctx, 16);

    /* ---- Initial staging buffer --------------------------------------- */
    ctx->stagingCap = 0;
    memset(&ctx->staging, 0, sizeof(ctx->staging));
    ctx->readbackCap = 0;
    memset(&ctx->readback, 0, sizeof(ctx->readback));

    /* ---- Pipeline cache (load from disk if available) ----------------- */
    {
        /* Build cache file path next to the executable */
        snprintf(ctx->pipeCachePath, sizeof(ctx->pipeCachePath),
                 "pipeline_cache.bin");

        VkPipelineCacheCreateInfo pcci = {
            .sType = VK_STRUCTURE_TYPE_PIPELINE_CACHE_CREATE_INFO,
            .initialDataSize = 0,
            .pInitialData    = NULL
        };

        /* Try to load existing cache from disk */
        FILE *cf = fopen(ctx->pipeCachePath, "rb");
        void *cacheData = NULL;
        if (cf) {
            fseek(cf, 0, SEEK_END);
            long cacheSize = ftell(cf);
            fseek(cf, 0, SEEK_SET);
            if (cacheSize > 0) {
                cacheData = malloc((size_t)cacheSize);
                if (cacheData && fread(cacheData, 1, (size_t)cacheSize, cf) == (size_t)cacheSize) {
                    pcci.initialDataSize = (size_t)cacheSize;
                    pcci.pInitialData    = cacheData;
                    printf("Pipeline cache loaded (%ld bytes)\n", cacheSize);
                }
            }
            fclose(cf);
        }

        VkResult cr = vkCreatePipelineCache(ctx->device, &pcci, NULL, &ctx->pipeCache);
        free(cacheData);
        if (cr != VK_SUCCESS) {
            /* If loading failed (e.g. stale cache), retry without initial data */
            pcci.initialDataSize = 0;
            pcci.pInitialData    = NULL;
            VK_CHECK(vkCreatePipelineCache(ctx->device, &pcci, NULL, &ctx->pipeCache));
        }
    }

    printf("Vulkan memory mode: %s\n",
           ctx->use_device_local ? "DEVICE_LOCAL + staging" : "HOST_VISIBLE");

    return ctx;
}

/* ============================================================================
 * Context destruction
 * ========================================================================= */

void vkctx_destroy(VkCtx *ctx)
{
    if (!ctx) return;

    vkDeviceWaitIdle(ctx->device);

    /* Save pipeline cache to disk */
    if (ctx->pipeCache) {
        size_t cacheSize = 0;
        vkGetPipelineCacheData(ctx->device, ctx->pipeCache, &cacheSize, NULL);
        if (cacheSize > 0) {
            void *data = malloc(cacheSize);
            if (data) {
                if (vkGetPipelineCacheData(ctx->device, ctx->pipeCache,
                                           &cacheSize, data) == VK_SUCCESS) {
                    FILE *cf = fopen(ctx->pipeCachePath, "wb");
                    if (cf) {
                        fwrite(data, 1, cacheSize, cf);
                        fclose(cf);
                    }
                }
                free(data);
            }
        }
        vkDestroyPipelineCache(ctx->device, ctx->pipeCache, NULL);
    }

    vkctx_destroy_buffer(ctx, &ctx->dummy);
    vkctx_destroy_buffer(ctx, &ctx->staging);
    vkctx_destroy_buffer(ctx, &ctx->readback);
    vkDestroyDescriptorPool(ctx->device, ctx->dsPool, NULL);
    vkDestroyPipelineLayout(ctx->device, ctx->pipeLayout, NULL);
    vkDestroyDescriptorSetLayout(ctx->device, ctx->dsLayout, NULL);
    vkDestroyFence(ctx->device, ctx->fence, NULL);
    vkDestroyCommandPool(ctx->device, ctx->cmdPool, NULL);
    vkDestroyDevice(ctx->device, NULL);
    vkDestroyInstance(ctx->instance, NULL);

    free(ctx);
}

/* ============================================================================
 * Buffer management
 * ========================================================================= */

GpuBuf vkctx_create_buffer(VkCtx *ctx, VkDeviceSize size)
{
    GpuBuf buf = {0};
    buf.size = (size < 16) ? 16 : size;  /* minimum 16 bytes */
    buf.device_local = 0;

    VkBufferCreateInfo bci = {
        .sType       = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
        .size        = buf.size,
        .usage       = VK_BUFFER_USAGE_STORAGE_BUFFER_BIT
                     | VK_BUFFER_USAGE_TRANSFER_SRC_BIT
                     | VK_BUFFER_USAGE_TRANSFER_DST_BIT,
        .sharingMode = VK_SHARING_MODE_EXCLUSIVE
    };
    VK_CHECK(vkCreateBuffer(ctx->device, &bci, NULL, &buf.buffer));

    VkMemoryRequirements memReqs;
    vkGetBufferMemoryRequirements(ctx->device, buf.buffer, &memReqs);

    VkMemoryAllocateInfo mai = {
        .sType           = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
        .allocationSize  = memReqs.size,
        .memoryTypeIndex = find_memory_type(
            ctx->physDev, memReqs.memoryTypeBits,
            VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT
          | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT)
    };
    VK_CHECK(vkAllocateMemory(ctx->device, &mai, NULL, &buf.memory));
    VK_CHECK(vkBindBufferMemory(ctx->device, buf.buffer, buf.memory, 0));
    VK_CHECK(vkMapMemory(ctx->device, buf.memory, 0, buf.size, 0, &buf.mapped));

    return buf;
}

GpuBuf vkctx_create_buffer_gpu(VkCtx *ctx, VkDeviceSize size)
{
    /* If device-local mode is off, fall back to host-visible */
    if (!ctx->use_device_local) {
        return vkctx_create_buffer(ctx, size);
    }

    GpuBuf buf = {0};
    buf.size = (size < 16) ? 16 : size;
    buf.device_local = 1;
    buf.mapped = NULL;

    VkBufferCreateInfo bci = {
        .sType       = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
        .size        = buf.size,
        .usage       = VK_BUFFER_USAGE_STORAGE_BUFFER_BIT
                     | VK_BUFFER_USAGE_TRANSFER_SRC_BIT
                     | VK_BUFFER_USAGE_TRANSFER_DST_BIT,
        .sharingMode = VK_SHARING_MODE_EXCLUSIVE
    };
    VK_CHECK(vkCreateBuffer(ctx->device, &bci, NULL, &buf.buffer));

    VkMemoryRequirements memReqs;
    vkGetBufferMemoryRequirements(ctx->device, buf.buffer, &memReqs);

    /* Allocate in DEVICE_LOCAL memory (fastest VRAM) */
    VkMemoryAllocateInfo mai = {
        .sType           = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
        .allocationSize  = memReqs.size,
        .memoryTypeIndex = find_memory_type(
            ctx->physDev, memReqs.memoryTypeBits,
            VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
    };
    VK_CHECK(vkAllocateMemory(ctx->device, &mai, NULL, &buf.memory));
    VK_CHECK(vkBindBufferMemory(ctx->device, buf.buffer, buf.memory, 0));

    return buf;
}

void vkctx_destroy_buffer(VkCtx *ctx, GpuBuf *buf)
{
    if (!buf->buffer) return;
    if (buf->mapped) vkUnmapMemory(ctx->device, buf->memory);
    vkDestroyBuffer(ctx->device, buf->buffer, NULL);
    vkFreeMemory(ctx->device, buf->memory, NULL);
    memset(buf, 0, sizeof(*buf));
}

void vkctx_upload(GpuBuf *buf, const void *data, size_t bytes)
{
    memcpy(buf->mapped, data, bytes);
}

void vkctx_download(const GpuBuf *buf, void *data, size_t bytes)
{
    memcpy(data, buf->mapped, bytes);
}

void vkctx_zero_buffer(VkCtx *ctx, GpuBuf *buf)
{
    if (buf->device_local) {
        vkctx_zero_buffer_gpu(ctx, buf);
    } else {
        (void)ctx;
        memset(buf->mapped, 0, buf->size);
    }
}

/* ---- Staging buffer management ---------------------------------------- */

static void ensure_staging(VkCtx *ctx, VkDeviceSize need)
{
    if (ctx->stagingCap >= need) return;

    /* Free old staging buffer */
    if (ctx->staging.buffer)
        vkctx_destroy_buffer(ctx, &ctx->staging);

    /* Allocate new staging buffer with some headroom (round up to 1 MB) */
    VkDeviceSize cap = (need + (1 << 20) - 1) & ~((VkDeviceSize)(1 << 20) - 1);
    if (cap < need) cap = need;
    ctx->staging    = vkctx_create_buffer(ctx, cap);  /* host-visible */
    ctx->stagingCap = cap;
}

/* Create a HOST_CACHED readback buffer for fast GPU→CPU downloads.
 * On discrete GPUs, HOST_CACHED memory sits in system RAM and is CPU-cacheable,
 * unlike BAR/WC memory which has ~30 MB/s read speed. */
static void ensure_readback(VkCtx *ctx, VkDeviceSize need)
{
    if (ctx->readbackCap >= need) return;

    if (ctx->readback.buffer)
        vkctx_destroy_buffer(ctx, &ctx->readback);

    VkDeviceSize cap = (need + (1 << 20) - 1) & ~((VkDeviceSize)(1 << 20) - 1);
    if (cap < need) cap = need;

    /* Allocate with HOST_CACHED + HOST_VISIBLE + HOST_COHERENT */
    GpuBuf buf = {0};
    buf.size = cap;
    buf.device_local = 0;

    VkBufferCreateInfo bci = {
        .sType       = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
        .size        = cap,
        .usage       = VK_BUFFER_USAGE_TRANSFER_DST_BIT,
        .sharingMode = VK_SHARING_MODE_EXCLUSIVE
    };
    VK_CHECK(vkCreateBuffer(ctx->device, &bci, NULL, &buf.buffer));

    VkMemoryRequirements memReqs;
    vkGetBufferMemoryRequirements(ctx->device, buf.buffer, &memReqs);

    /* Try HOST_VISIBLE + HOST_CACHED + HOST_COHERENT (ideal for readback) */
    VkMemoryPropertyFlags readbackFlags =
        VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT
      | VK_MEMORY_PROPERTY_HOST_CACHED_BIT
      | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT;

    /* Some GPUs don't have coherent+cached; fall back to cached-only (need flush) */
    VkPhysicalDeviceMemoryProperties mem;
    vkGetPhysicalDeviceMemoryProperties(ctx->physDev, &mem);
    int found = 0;
    for (uint32_t i = 0; i < mem.memoryTypeCount; i++) {
        if ((memReqs.memoryTypeBits & (1u << i)) &&
            (mem.memoryTypes[i].propertyFlags & readbackFlags) == readbackFlags) {
            found = 1;
            break;
        }
    }
    if (!found) {
        /* Fall back: HOST_VISIBLE + HOST_CACHED (will need invalidate) */
        readbackFlags = VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT
                      | VK_MEMORY_PROPERTY_HOST_CACHED_BIT;
        for (uint32_t i = 0; i < mem.memoryTypeCount; i++) {
            if ((memReqs.memoryTypeBits & (1u << i)) &&
                (mem.memoryTypes[i].propertyFlags & readbackFlags) == readbackFlags) {
                found = 1;
                break;
            }
        }
    }
    if (!found) {
        /* Last resort: same as normal staging */
        readbackFlags = VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT
                      | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT;
    }

    VkMemoryAllocateInfo mai = {
        .sType           = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
        .allocationSize  = memReqs.size,
        .memoryTypeIndex = find_memory_type_exact(ctx->physDev, memReqs.memoryTypeBits, readbackFlags)
    };
    VK_CHECK(vkAllocateMemory(ctx->device, &mai, NULL, &buf.memory));
    VK_CHECK(vkBindBufferMemory(ctx->device, buf.buffer, buf.memory, 0));
    VK_CHECK(vkMapMemory(ctx->device, buf.memory, 0, cap, 0, &buf.mapped));

    ctx->readback    = buf;
    ctx->readbackCap = cap;
}

/* Submit a one-shot command buffer for a copy operation */
static void submit_copy(VkCtx *ctx)
{
    VK_CHECK(vkEndCommandBuffer(ctx->cmdBuf));

    VK_CHECK(vkResetFences(ctx->device, 1, &ctx->fence));
    VkSubmitInfo si = {
        .sType              = VK_STRUCTURE_TYPE_SUBMIT_INFO,
        .commandBufferCount = 1,
        .pCommandBuffers    = &ctx->cmdBuf
    };
    VK_CHECK(vkQueueSubmit(ctx->queue, 1, &si, ctx->fence));
    VK_CHECK(vkWaitForFences(ctx->device, 1, &ctx->fence, VK_TRUE, UINT64_MAX));
}

void vkctx_upload_staged(VkCtx *ctx, GpuBuf *dst, const void *data, size_t bytes)
{
    if (!dst->device_local) {
        /* Host-visible: direct memcpy */
        memcpy(dst->mapped, data, bytes);
        return;
    }

    ensure_staging(ctx, (VkDeviceSize)bytes);
    memcpy(ctx->staging.mapped, data, bytes);

    VK_CHECK(vkResetCommandBuffer(ctx->cmdBuf, 0));
    VkCommandBufferBeginInfo bi = {
        .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
        .flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT
    };
    VK_CHECK(vkBeginCommandBuffer(ctx->cmdBuf, &bi));

    VkBufferCopy region = { .srcOffset = 0, .dstOffset = 0, .size = bytes };
    vkCmdCopyBuffer(ctx->cmdBuf, ctx->staging.buffer, dst->buffer, 1, &region);

    submit_copy(ctx);
}

void vkctx_download_staged(VkCtx *ctx, const GpuBuf *src, void *data, size_t bytes)
{
    if (!src->device_local) {
        /* Host-visible: direct memcpy */
        memcpy(data, src->mapped, bytes);
        return;
    }

    ensure_readback(ctx, (VkDeviceSize)bytes);

    VK_CHECK(vkResetCommandBuffer(ctx->cmdBuf, 0));
    VkCommandBufferBeginInfo bi = {
        .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
        .flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT
    };
    VK_CHECK(vkBeginCommandBuffer(ctx->cmdBuf, &bi));

    VkBufferCopy region = { .srcOffset = 0, .dstOffset = 0, .size = bytes };
    vkCmdCopyBuffer(ctx->cmdBuf, src->buffer, ctx->readback.buffer, 1, &region);

    submit_copy(ctx);

    /* Invalidate cache if not coherent */
    VkMappedMemoryRange range = {
        .sType  = VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE,
        .memory = ctx->readback.memory,
        .offset = 0,
        .size   = VK_WHOLE_SIZE
    };
    vkInvalidateMappedMemoryRanges(ctx->device, 1, &range);

    memcpy(data, ctx->readback.mapped, bytes);
}

void vkctx_zero_buffer_gpu(VkCtx *ctx, GpuBuf *buf)
{
    VK_CHECK(vkResetCommandBuffer(ctx->cmdBuf, 0));
    VkCommandBufferBeginInfo bi = {
        .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
        .flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT
    };
    VK_CHECK(vkBeginCommandBuffer(ctx->cmdBuf, &bi));

    vkCmdFillBuffer(ctx->cmdBuf, buf->buffer, 0, buf->size, 0);

    submit_copy(ctx);
}

/* ============================================================================
 * Pipeline creation from embedded SPIR-V
 * ========================================================================= */

VkPipeline vkctx_create_pipeline(VkCtx *ctx,
                                  const uint32_t *spirv, size_t spirv_size)
{
    VkShaderModuleCreateInfo smci = {
        .sType    = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO,
        .codeSize = spirv_size,
        .pCode    = spirv
    };
    VkShaderModule module;
    VK_CHECK(vkCreateShaderModule(ctx->device, &smci, NULL, &module));

    VkComputePipelineCreateInfo cpci = {
        .sType  = VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO,
        .stage  = {
            .sType  = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,
            .stage  = VK_SHADER_STAGE_COMPUTE_BIT,
            .module = module,
            .pName  = "main"
        },
        .layout = ctx->pipeLayout
    };

    VkPipeline pipeline;
    VK_CHECK(vkCreateComputePipelines(ctx->device, ctx->pipeCache,
                                       1, &cpci, NULL, &pipeline));
    vkDestroyShaderModule(ctx->device, module, NULL);
    return pipeline;
}

void vkctx_destroy_pipeline(VkCtx *ctx, VkPipeline pipe)
{
    vkDestroyPipeline(ctx->device, pipe, NULL);
}

/* ============================================================================
 * Command recording & execution
 * ========================================================================= */

void vkctx_cmd_begin(VkCtx *ctx)
{
    VK_CHECK(vkResetCommandBuffer(ctx->cmdBuf, 0));

    VkCommandBufferBeginInfo bi = {
        .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
        .flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT
    };
    VK_CHECK(vkBeginCommandBuffer(ctx->cmdBuf, &bi));

    ctx->dsNext = 0;  /* reset descriptor set allocator */
}

void vkctx_cmd_end(VkCtx *ctx)
{
    VK_CHECK(vkEndCommandBuffer(ctx->cmdBuf));

    VK_CHECK(vkResetFences(ctx->device, 1, &ctx->fence));

    VkSubmitInfo si = {
        .sType              = VK_STRUCTURE_TYPE_SUBMIT_INFO,
        .commandBufferCount = 1,
        .pCommandBuffers    = &ctx->cmdBuf
    };
    VK_CHECK(vkQueueSubmit(ctx->queue, 1, &si, ctx->fence));
    VK_CHECK(vkWaitForFences(ctx->device, 1, &ctx->fence,
                              VK_TRUE, UINT64_MAX));
}

void vkctx_cmd_dispatch(VkCtx *ctx,
                         VkPipeline pipeline,
                         GpuBuf *buf0, GpuBuf *buf1,
                         GpuBuf *buf2, GpuBuf *buf3,
                         const VkPC *pc,
                         uint32_t gx, uint32_t gy, uint32_t gz)
{
    if (ctx->dsNext >= VK_MAX_DESC_SETS) {
        fprintf(stderr, "ERROR: descriptor set pool exhausted (%d)\n",
                VK_MAX_DESC_SETS);
        exit(1);
    }

    VkDescriptorSet ds = ctx->dsSets[ctx->dsNext++];

    /* Use dummy buffer for NULL buffer pointers */
    GpuBuf *bufs[4] = {
        buf0 ? buf0 : &ctx->dummy,
        buf1 ? buf1 : &ctx->dummy,
        buf2 ? buf2 : &ctx->dummy,
        buf3 ? buf3 : &ctx->dummy
    };

    VkDescriptorBufferInfo bufInfos[4];
    VkWriteDescriptorSet   writes[4];
    for (int i = 0; i < 4; i++) {
        bufInfos[i] = (VkDescriptorBufferInfo){
            .buffer = bufs[i]->buffer,
            .offset = 0,
            .range  = bufs[i]->size
        };
        writes[i] = (VkWriteDescriptorSet){
            .sType           = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET,
            .dstSet          = ds,
            .dstBinding      = (uint32_t)i,
            .descriptorCount = 1,
            .descriptorType  = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
            .pBufferInfo     = &bufInfos[i]
        };
    }
    vkUpdateDescriptorSets(ctx->device, 4, writes, 0, NULL);

    vkCmdBindPipeline(ctx->cmdBuf, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline);
    vkCmdBindDescriptorSets(ctx->cmdBuf, VK_PIPELINE_BIND_POINT_COMPUTE,
                             ctx->pipeLayout, 0, 1, &ds, 0, NULL);
    vkCmdPushConstants(ctx->cmdBuf, ctx->pipeLayout,
                        VK_SHADER_STAGE_COMPUTE_BIT, 0, sizeof(VkPC), pc);
    vkCmdDispatch(ctx->cmdBuf, gx, gy, gz);
}

void vkctx_cmd_barrier(VkCtx *ctx)
{
    VkMemoryBarrier barrier = {
        .sType         = VK_STRUCTURE_TYPE_MEMORY_BARRIER,
        .srcAccessMask = VK_ACCESS_SHADER_WRITE_BIT,
        .dstAccessMask = VK_ACCESS_SHADER_READ_BIT
                       | VK_ACCESS_SHADER_WRITE_BIT
    };
    vkCmdPipelineBarrier(ctx->cmdBuf,
                          VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
                          VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
                          0, 1, &barrier, 0, NULL, 0, NULL);
}

void vkctx_cmd_fill_zero(VkCtx *ctx, GpuBuf *buf)
{
    vkCmdFillBuffer(ctx->cmdBuf, buf->buffer, 0, buf->size, 0);

    VkMemoryBarrier barrier = {
        .sType         = VK_STRUCTURE_TYPE_MEMORY_BARRIER,
        .srcAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT,
        .dstAccessMask = VK_ACCESS_SHADER_READ_BIT | VK_ACCESS_SHADER_WRITE_BIT
    };
    vkCmdPipelineBarrier(ctx->cmdBuf,
                          VK_PIPELINE_STAGE_TRANSFER_BIT,
                          VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
                          0, 1, &barrier, 0, NULL, 0, NULL);
}

#endif /* USE_VULKAN */
