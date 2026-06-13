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
/*
 * fwvplay.c — windowed FWV player.
 *
 * Reads a .fwv container (per-frame index + the coded frames + optional audio), decodes each frame on the GPU
 * (bitplane_unpack -> dequant -> inverse wavelet -> YCoCg-R -> RGB), reconstructing inter (P / hierarchical B)
 * and 3D-DWT/MCTF frames via the DPB + motion compensation as needed, blits it to an SDL2/Vulkan swapchain,
 * plays the audio (Vorbis / QOA-LE / raw PCM / FWA) and syncs the video to the audio master clock. quality == 0
 * in the header selects the lossless integer 5/3 path. (Optionally decodes an embedded H.264 stream instead.)
 *
 *     ./fwvplay file.fwv               present in a window
 *     ./fwvplay file.fwv --decode-to out.avi   decode the whole stream to an AVI and exit
 *     ./fwvplay file.fwv --verify      GPU-vs-CPU decode PSNR self-check, then exit
 */
#define FWV_NO_MAIN
#include "fwvwave.c"
#include <vulkan/vulkan.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_vulkan.h>
#include "fwv_h264.h"   // the H.264 HW-decode path (separate TU)
#include "avi_writer.h"  // --decode-to OpenDML/AVI export
#include "fwa_audio.h"  // the "FWA" wavelet-audio sub-codec (separate TU, linked via the Makefile)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-but-set-variable"
#pragma GCC diagnostic ignored "-Wmaybe-uninitialized"
#include "stb_vorbis.c"
#pragma GCC diagnostic pop

#define VK_CHECK(expression) do {                                              \
    VkResult _result = (expression);                                           \
    if (_result) {                                                             \
      fprintf(stderr, "vk error %d at %d\n", _result, __LINE__);               \
      exit(1);                                                                 \
    }                                                                          \
  } while (0)

#define HOST_VISIBLE_COHERENT (VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT)
#define DEVICE_LOCAL          VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT

static VkDevice device;
static VkPhysicalDevice physical_device;
static VkCommandBuffer command_buffer;

// .fwv container header (binary-compatible with fwvenc's writer). The colour block is CICP
// (ITU-T H.273); the codec is currently 8-bit SDR, the HDR fields are reserved for later.
typedef struct {
  uint8_t  magic[4];            // "FWVC"
  uint16_t version;             // container format version
  uint16_t header_size;         // sizeof(ContainerHeader)
  uint32_t width, height, fps_num, fps_den, levels, quality, frame_count;
  // ---- colour / HDR signalling (CICP; default = SDR) ----
  uint8_t  bit_depth;           // 8 now; 10/12/16 reserved (source RGB component depth)
  uint8_t  colour_primaries;    // CICP: 1=BT.709 (default), 9=BT.2020, 12=Display-P3
  uint8_t  transfer_function;   // CICP: 13=sRGB (default), 1=BT.709, 16=PQ, 18=HLG, 8=linear
  uint8_t  matrix;              // CICP: 8=YCgCo (== our reversible YCoCg-R)
  uint8_t  full_range;          // 1 (YCoCg-R is full-range)
  uint8_t  colour_flags;        // bit0 = HDR, bit1 = HDR10 static metadata present
  uint16_t gop;                 // max keyframe interval (seek hint); actual I/P type is per-frame
  // ---- HDR10 static metadata (valid iff colour_flags bit1) ----
  uint16_t mastering_primaries_x[3], mastering_primaries_y[3];   // ST 2086 R/G/B chromaticity, x50000
  uint16_t mastering_white_x, mastering_white_y;
  uint32_t mastering_max_luminance, mastering_min_luminance;     // x10000 cd/m^2
  uint16_t max_content_light_level;     // MaxCLL (cd/m^2)
  uint16_t max_frame_avg_light_level;   // MaxFALL (cd/m^2)
  // ---- payload ----
  uint64_t audio_offset, audio_size, index_offset;
  // ---- codec config (appended in v4) ----
  uint8_t  prediction_method;   // 0 = coefdiff (A: coefficient diff), 1 = colordiff (B: YCoCg/pixel diff)
  uint8_t  chroma_quant_x16;    // chroma quant multiplier x16 (16 = 1.0 = off); 0 (old files) -> treated as 16
  uint8_t  chroma_format;       // 0 = 4:4:4 (default), 1 = 4:2:2 (chroma W/2 x H), 2 = 4:2:0 (chroma W/2 x H/2)
  uint8_t  reserved2[6];        // [0] = temporal levels, [1] = temporal wavelet; [2] = bframes gop; [3] = per-block mode; [4] = coding block size; [5] = motion block size
  // ---- audio (appended) ----
  uint8_t  audio_codec[4];      // sub-FOURCC: "OGGV" = OGG/Vorbis, "QOAL" = little-endian QOA, "RPCM" = raw PCM, "FWAC" = wavelet audio (fwa)
  uint8_t  mv_codec;            // motion-vector entropy coder. 0 = signed Exp-Golomb (default), 1 = adaptive binary range coder. (Occupies former padding; struct layout unchanged.)
  // ---- optional parallel H.264 elementary stream (Annex-B) for HW decode ----
  uint64_t h264_offset;         // byte offset of the H.264 Annex-B blob (full-res; the wavelet width/height may be down-scaled)
  uint64_t h264_size;           // 0 = no H.264 stream (wavelet-only container)
} ContainerHeader;

// Per-frame index entry. The on-disk
// index is in CODING order; poc gives the display position; ref0/ref1 are the coding-order indices of
// the L0/L1 references (-1 = none). type: 0 = I, 1 = P, 2 = B (3D-DWT reuses 2 as GOP continuation,
// method-scoped). quality is the per-GOP Q; temporal_id is the hierarchy level (QP-cascade / scalability).
typedef struct {
  uint64_t offset;
  uint32_t size;
  uint32_t poc;         // display-order position (the on-disk index is in CODING order)
  int32_t  ref0;        // coding-order index of the L0 reference (-1 = none)
  int32_t  ref1;        // coding-order index of the L1 reference (-1 = none)
  uint8_t  type;        // 0 = I, 1 = P, 2 = B
  uint8_t  quality;
  uint8_t  temporal_id; // hierarchy level (QP-cascading / temporal scalability)
  uint8_t  pad;
} FrameEntry;           // 28 bytes

// ---------------------------------------------------------------- Vulkan helpers

static uint32_t find_memory_type(uint32_t type_bits, VkMemoryPropertyFlags wanted) {
  VkPhysicalDeviceMemoryProperties memory_properties;
  vkGetPhysicalDeviceMemoryProperties(physical_device, &memory_properties);
  for (uint32_t i = 0; i < memory_properties.memoryTypeCount; i++) {
    if ((type_bits & (1u << i)) && ((memory_properties.memoryTypes[i].propertyFlags & wanted) == wanted)) {
      return i;
    }
  }
  die("no suitable memory type");
  return 0;
}

static void create_buffer(VkDeviceSize size, VkMemoryPropertyFlags properties, VkBuffer *out_buffer, VkDeviceMemory *out_memory) {
  VkBufferCreateInfo buffer_info = { VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO };
  buffer_info.size = size ? size : 4;
  buffer_info.usage = VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_SRC_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT;
  VK_CHECK(vkCreateBuffer(device, &buffer_info, 0, out_buffer));

  VkMemoryRequirements requirements;
  vkGetBufferMemoryRequirements(device, *out_buffer, &requirements);
  VkMemoryAllocateInfo allocate_info = { VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO };
  allocate_info.allocationSize = requirements.size;
  allocate_info.memoryTypeIndex = find_memory_type(requirements.memoryTypeBits, properties);
  VK_CHECK(vkAllocateMemory(device, &allocate_info, 0, out_memory));
  VK_CHECK(vkBindBufferMemory(device, *out_buffer, *out_memory, 0));
}

static uint32_t *load_spirv(const char *path, size_t *out_size) {
  FILE *file = fopen(path, "rb");
  if (!file) {
    fprintf(stderr, "open %s\n", path);
    exit(1);
  }
  fseek(file, 0, SEEK_END);
  long size = ftell(file);
  fseek(file, 0, SEEK_SET);
  uint32_t *code = checked_malloc(size);
  if (fread(code, 1, size, file) != (size_t)size) {
    die("spirv read");
  }
  fclose(file);
  *out_size = size;
  return code;
}

static VkDescriptorSetLayout create_descriptor_set_layout(int storage_buffer_count, int has_storage_image) {
  VkDescriptorSetLayoutBinding bindings[8];
  int binding_count = 0;
  for (int i = 0; i < storage_buffer_count; i++) {
    bindings[binding_count++] = (VkDescriptorSetLayoutBinding){ i, VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, 1, VK_SHADER_STAGE_COMPUTE_BIT, 0 };
  }
  if (has_storage_image) {
    bindings[binding_count++] = (VkDescriptorSetLayoutBinding){ storage_buffer_count, VK_DESCRIPTOR_TYPE_STORAGE_IMAGE, 1, VK_SHADER_STAGE_COMPUTE_BIT, 0 };
  }
  VkDescriptorSetLayoutCreateInfo info = { VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO };
  info.bindingCount = binding_count;
  info.pBindings = bindings;
  VkDescriptorSetLayout layout;
  VK_CHECK(vkCreateDescriptorSetLayout(device, &info, 0, &layout));
  return layout;
}

static VkPipelineLayout create_pipeline_layout(VkDescriptorSetLayout set_layout, uint32_t push_constant_size) {
  VkPushConstantRange push_range = { VK_SHADER_STAGE_COMPUTE_BIT, 0, push_constant_size };
  VkPipelineLayoutCreateInfo info = { VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO };
  info.setLayoutCount = 1;
  info.pSetLayouts = &set_layout;
  info.pushConstantRangeCount = 1;
  info.pPushConstantRanges = &push_range;
  VkPipelineLayout layout;
  VK_CHECK(vkCreatePipelineLayout(device, &info, 0, &layout));
  return layout;
}

static VkPipeline create_compute_pipeline(const char *spirv_path, VkPipelineLayout layout) {
  size_t code_size;
  uint32_t *code = load_spirv(spirv_path, &code_size);
  VkShaderModuleCreateInfo module_info = { VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO };
  module_info.codeSize = code_size;
  module_info.pCode = code;
  VkShaderModule module;
  VK_CHECK(vkCreateShaderModule(device, &module_info, 0, &module));
  free(code);

  VkComputePipelineCreateInfo pipeline_info = { VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO };
  pipeline_info.stage.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
  pipeline_info.stage.stage = VK_SHADER_STAGE_COMPUTE_BIT;
  pipeline_info.stage.module = module;
  pipeline_info.stage.pName = "main";
  pipeline_info.layout = layout;
  VkPipeline pipeline;
  VK_CHECK(vkCreateComputePipelines(device, 0, 1, &pipeline_info, 0, &pipeline));
  return pipeline;
}

// Like create_compute_pipeline but bakes the coding block size into specialization constant 0 (BS) — the
// bitplane_unpack pipeline must match the block size the encoder used (read from the container header).
static VkPipeline create_compute_pipeline_bs(const char *spirv_path, VkPipelineLayout layout, int block_size) {
  size_t code_size;
  uint32_t *code = load_spirv(spirv_path, &code_size);
  VkShaderModuleCreateInfo module_info = { VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO };
  module_info.codeSize = code_size;
  module_info.pCode = code;
  VkShaderModule module;
  VK_CHECK(vkCreateShaderModule(device, &module_info, 0, &module));
  free(code);
  int spec_values[2] = { block_size, (block_size == 128) ? 1 : 0 };   // [0] = BS, [1] = COOP (128 = one workgroup/block, thread 0)
  VkSpecializationMapEntry entries[2] = { { 0, 0, sizeof(int) }, { 1, sizeof(int), sizeof(int) } };
  VkSpecializationInfo spec = { 2, entries, sizeof(spec_values), spec_values };
  VkComputePipelineCreateInfo pipeline_info = { VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO };
  pipeline_info.stage.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
  pipeline_info.stage.stage = VK_SHADER_STAGE_COMPUTE_BIT;
  pipeline_info.stage.module = module;
  pipeline_info.stage.pName = "main";
  pipeline_info.stage.pSpecializationInfo = &spec;
  pipeline_info.layout = layout;
  VkPipeline pipeline;
  VK_CHECK(vkCreateComputePipelines(device, 0, 1, &pipeline_info, 0, &pipeline));
  return pipeline;
}

// Like create_compute_pipeline but bakes the motion block size into spec constant 0 (MB) and the per-block
// workgroup size into spec constant 1 (MB*MB). The player only runs the flat motion shaders (mc, blend_mode),
// which use id 0 and ignore id 1 (their workgroup stays a fixed 256), but we set both for symmetry with the encoder.
static VkPipeline create_compute_pipeline_motion(const char *spirv_path, VkPipelineLayout layout, int motion_block) {
  size_t code_size;
  uint32_t *code = load_spirv(spirv_path, &code_size);
  VkShaderModuleCreateInfo module_info = { VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO };
  module_info.codeSize = code_size;
  module_info.pCode = code;
  VkShaderModule module;
  VK_CHECK(vkCreateShaderModule(device, &module_info, 0, &module));
  free(code);
  int spec_values[2] = { motion_block, motion_block * motion_block };   // [0] = MB, [1] = per-block workgroup = MB*MB
  VkSpecializationMapEntry entries[2] = { { 0, 0, sizeof(int) }, { 1, sizeof(int), sizeof(int) } };
  VkSpecializationInfo spec = { 2, entries, sizeof(spec_values), spec_values };
  VkComputePipelineCreateInfo pipeline_info = { VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO };
  pipeline_info.stage.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
  pipeline_info.stage.stage = VK_SHADER_STAGE_COMPUTE_BIT;
  pipeline_info.stage.module = module;
  pipeline_info.stage.pName = "main";
  pipeline_info.stage.pSpecializationInfo = &spec;
  pipeline_info.layout = layout;
  VkPipeline pipeline;
  VK_CHECK(vkCreateComputePipelines(device, 0, 1, &pipeline_info, 0, &pipeline));
  return pipeline;
}

static VkDescriptorSet allocate_descriptor_set(VkDescriptorPool pool, VkDescriptorSetLayout layout) {
  VkDescriptorSetAllocateInfo info = { VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO };
  info.descriptorPool = pool;
  info.descriptorSetCount = 1;
  info.pSetLayouts = &layout;
  VkDescriptorSet set;
  VK_CHECK(vkAllocateDescriptorSets(device, &info, &set));
  return set;
}

static void bind_storage_buffers(VkDescriptorSet set, VkBuffer *buffers, int count) {
  VkDescriptorBufferInfo buffer_infos[4];
  VkWriteDescriptorSet writes[4] = { 0 };
  for (int i = 0; i < count; i++) {
    buffer_infos[i] = (VkDescriptorBufferInfo){ buffers[i], 0, VK_WHOLE_SIZE };
    writes[i].sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
    writes[i].dstSet = set;
    writes[i].dstBinding = i;
    writes[i].descriptorCount = 1;
    writes[i].descriptorType = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
    writes[i].pBufferInfo = &buffer_infos[i];
  }
  vkUpdateDescriptorSets(device, count, writes, 0, 0);
}

// Like bind_storage_buffers but each binding starts at a per-buffer BYTE OFFSET (MCTF: gop_buffer/mctf_scratch at
// a frame offset). offsets must satisfy minStorageBufferOffsetAlignment (frame strides are 256-aligned at the
// standard resolutions).
static void bind_storage_buffers_offset(VkDescriptorSet set, VkBuffer *buffers, const VkDeviceSize *offsets, int count) {
  VkDescriptorBufferInfo buffer_infos[4];
  VkWriteDescriptorSet writes[4] = { 0 };
  for (int i = 0; i < count; i++) {
    buffer_infos[i] = (VkDescriptorBufferInfo){ buffers[i], offsets[i], VK_WHOLE_SIZE };
    writes[i].sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
    writes[i].dstSet = set;
    writes[i].dstBinding = i;
    writes[i].descriptorCount = 1;
    writes[i].descriptorType = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
    writes[i].pBufferInfo = &buffer_infos[i];
  }
  vkUpdateDescriptorSets(device, count, writes, 0, 0);
}

static void memory_barrier(void) {
  VkMemoryBarrier barrier = { VK_STRUCTURE_TYPE_MEMORY_BARRIER };
  barrier.srcAccessMask = VK_ACCESS_SHADER_WRITE_BIT;
  barrier.dstAccessMask = VK_ACCESS_SHADER_READ_BIT | VK_ACCESS_SHADER_WRITE_BIT;
  vkCmdPipelineBarrier(command_buffer, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, 0, 1, &barrier, 0, 0, 0, 0);
}

// A compute->compute barrier on an explicit command buffer (memory_barrier() targets the global one).
static void compute_barrier(VkCommandBuffer cmd) {
  VkMemoryBarrier barrier = { VK_STRUCTURE_TYPE_MEMORY_BARRIER };
  barrier.srcAccessMask = VK_ACCESS_SHADER_WRITE_BIT;
  barrier.dstAccessMask = VK_ACCESS_SHADER_READ_BIT | VK_ACCESS_SHADER_WRITE_BIT;
  vkCmdPipelineBarrier(cmd, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, 0, 1, &barrier, 0, 0, 0, 0);
}

// ---- 3D-DWT GOP decode on the prefetch command buffer (shared by the up-front GOP 0 decode and the
// overlapped prefetch of later GOPs). Each call waits the prefetch fence (previous step done), records
// one step, and submits it; the caller waits the fence again only at the GOP swap. ----
typedef struct {
  VkQueue queue;
  VkCommandBuffer cmd;
  VkFence fence;
  VkPipeline unpack, dequant, transpose, inverse_row, temporal_int, temporal_float;
  VkPipelineLayout layout_unpack, layout_dequant, layout_transpose, layout_row, layout_temporal;
  VkDescriptorSet unpack_pf[3], dequant_pf[3], coeff_to_scratch_pf[3], scratch_to_coeff_pf[3], row_pf[3], row_scratch;
  VkDescriptorSet temporal[2][3];
  VkBuffer prefetch_coeff[3], gop_buffer[2][3];
  int width, height, levels, pixel_count, temporal_levels, temporal_wavelet, lossless;
  size_t plane_bytes;
  // MCTF (prediction_method==3): the temporal-DWT inverse is replaced by a frame-level predict-only MC-Haar inverse
  // (mc.comp warp + coeff_add), and the lossy spatial inverse rounds to int (round97) so the integer MC-Haar can run.
  int mctf, motion_blocks_x, motion_blocks_y, motion_block;
  VkPipeline mc, coeff_add, round;
  VkPipelineLayout layout_mc, layout_coeff_add, layout_round;
  VkBuffer mv_buffer, mctf_pred[3], mctf_scratch[3];
  void *mv_map;
  VkDescriptorSet mctf_mc[3], mctf_add[3];
} Decode3D;

// The caller must vkWaitForFences + vkResetFences on d->fence (and, for a spatial step, upload the
// payload) BEFORE calling — the wait guarantees the previous step finished reading the shared upload
// buffers before the host overwrites them.
// Wait for the previous decode3d step to finish (and reset the fence) before reusing the shared buffers.
static void decode3d_wait(const Decode3D *d) {
  vkWaitForFences(device, 1, &d->fence, VK_TRUE, UINT64_MAX);
  vkResetFences(device, 1, &d->fence);
}

static void decode3d_begin(const Decode3D *d) {
  vkResetCommandBuffer(d->cmd, 0);
  VkCommandBufferBeginInfo begin = { VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO };
  begin.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
  vkBeginCommandBuffer(d->cmd, &begin);
}

// Submit the recorded step ASYNC (signals d->fence on completion). The caller waits d->fence before the
// NEXT step reuses this command buffer / the shared upload+scratch buffers — so the GPU runs this step
// concurrently with the present, hiding the ~one-frame-time decode cost.
static void decode3d_submit(const Decode3D *d) {
  vkEndCommandBuffer(d->cmd);
  VkSubmitInfo submit = { VK_STRUCTURE_TYPE_SUBMIT_INFO };
  submit.commandBufferCount = 1;
  submit.pCommandBuffers = &d->cmd;
  VK_CHECK(vkQueueSubmit(d->queue, 1, &submit, d->fence));
}

// Spatial-inverse the subband frame whose payload is already uploaded (data/offset/step buffers) into
// prefetch_coeff, then copy it into gop_buffer[buf] slot. No round — the float result feeds the float
// temporal inverse (lossless stays integer). Submits async; the caller manages the fence.
static void decode3d_spatial(const Decode3D *d, int buf, int slot) {
  decode3d_begin(d);
  int scratch_stride = (d->width > d->height) ? d->width : d->height;
  for (int plane = 0; plane < 3; plane++) {
    int pw = plane_width(plane, d->width), ph = plane_height(plane, d->height);   // chroma smaller when subsampled
    int pp = pw * ph;
    int plane_blocks = block_count_x(pw) * block_count_y(ph);
    int block_workgroups = (plane_blocks + 63) / 64;
    int pixel_workgroups = (pp + 255) / 256;
    int level_width[16], level_height[16], level_count = 0, cw = pw, ch = ph;
    for (int level = 0; (level < d->levels) && (cw >= 2) && (ch >= 2); level++) {
      level_width[level_count] = cw;
      level_height[level_count] = ch;
      level_count++;
      cw = (cw + 1) / 2;
      ch = (ch + 1) / 2;
    }
    int32_t unpack_push[4] = { pw, ph, block_count_x(pw), block_count_y(ph) };
    vkCmdBindPipeline(d->cmd, VK_PIPELINE_BIND_POINT_COMPUTE, d->unpack);
    vkCmdBindDescriptorSets(d->cmd, VK_PIPELINE_BIND_POINT_COMPUTE, d->layout_unpack, 0, 1, &d->unpack_pf[plane], 0, 0);
    vkCmdPushConstants(d->cmd, d->layout_unpack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, unpack_push);
    vkCmdDispatch(d->cmd, block_workgroups, 1, 1);
    compute_barrier(d->cmd);
    if (!d->lossless) {
      int32_t dequant_push[2] = { pp, 0 };
      float chroma_multiplier = (plane == 0) ? 1.0f : g_chroma_quant;
      memcpy(&dequant_push[1], &chroma_multiplier, sizeof(float));
      vkCmdBindPipeline(d->cmd, VK_PIPELINE_BIND_POINT_COMPUTE, d->dequant);
      vkCmdBindDescriptorSets(d->cmd, VK_PIPELINE_BIND_POINT_COMPUTE, d->layout_dequant, 0, 1, &d->dequant_pf[plane], 0, 0);
      vkCmdPushConstants(d->cmd, d->layout_dequant, VK_SHADER_STAGE_COMPUTE_BIT, 0, 8, dequant_push);
      vkCmdDispatch(d->cmd, pixel_workgroups, 1, 1);
      compute_barrier(d->cmd);
    }
    for (int level_i = level_count - 1; level_i >= 0; level_i--) {
      int level_w = level_width[level_i], level_h = level_height[level_i];
      int32_t transpose_push_1[4] = { pw, level_w, level_h, scratch_stride };
      vkCmdBindPipeline(d->cmd, VK_PIPELINE_BIND_POINT_COMPUTE, d->transpose);
      vkCmdBindDescriptorSets(d->cmd, VK_PIPELINE_BIND_POINT_COMPUTE, d->layout_transpose, 0, 1, &d->coeff_to_scratch_pf[plane], 0, 0);
      vkCmdPushConstants(d->cmd, d->layout_transpose, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, transpose_push_1);
      vkCmdDispatch(d->cmd, (level_w + 15) / 16, (level_h + 15) / 16, 1);
      compute_barrier(d->cmd);
      int32_t row_push_1[4] = { scratch_stride, level_h, level_w, 1 };
      vkCmdBindPipeline(d->cmd, VK_PIPELINE_BIND_POINT_COMPUTE, d->inverse_row);
      vkCmdBindDescriptorSets(d->cmd, VK_PIPELINE_BIND_POINT_COMPUTE, d->layout_row, 0, 1, &d->row_scratch, 0, 0);
      vkCmdPushConstants(d->cmd, d->layout_row, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, row_push_1);
      vkCmdDispatch(d->cmd, level_w, 1, 1);
      compute_barrier(d->cmd);
      int32_t transpose_push_2[4] = { scratch_stride, level_h, level_w, pw };
      vkCmdBindPipeline(d->cmd, VK_PIPELINE_BIND_POINT_COMPUTE, d->transpose);
      vkCmdBindDescriptorSets(d->cmd, VK_PIPELINE_BIND_POINT_COMPUTE, d->layout_transpose, 0, 1, &d->scratch_to_coeff_pf[plane], 0, 0);
      vkCmdPushConstants(d->cmd, d->layout_transpose, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, transpose_push_2);
      vkCmdDispatch(d->cmd, (level_h + 15) / 16, (level_w + 15) / 16, 1);
      compute_barrier(d->cmd);
      int32_t row_push_2[4] = { pw, level_w, level_h, 1 };
      vkCmdBindPipeline(d->cmd, VK_PIPELINE_BIND_POINT_COMPUTE, d->inverse_row);
      vkCmdBindDescriptorSets(d->cmd, VK_PIPELINE_BIND_POINT_COMPUTE, d->layout_row, 0, 1, &d->row_pf[plane], 0, 0);
      vkCmdPushConstants(d->cmd, d->layout_row, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, row_push_2);
      vkCmdDispatch(d->cmd, level_h, 1, 1);
      compute_barrier(d->cmd);
    }
    if (d->mctf && !d->lossless) {   // MCTF gop is INTEGER: round the float 9/7 result to int before the integer MC-Haar inverse
      int32_t pixel_count_push = pp;
      vkCmdBindPipeline(d->cmd, VK_PIPELINE_BIND_POINT_COMPUTE, d->round);
      vkCmdBindDescriptorSets(d->cmd, VK_PIPELINE_BIND_POINT_COMPUTE, d->layout_round, 0, 1, &d->row_pf[plane], 0, 0);
      vkCmdPushConstants(d->cmd, d->layout_round, VK_SHADER_STAGE_COMPUTE_BIT, 0, 4, &pixel_count_push);
      vkCmdDispatch(d->cmd, (pp + 255) / 256, 1, 1);
      compute_barrier(d->cmd);
    }
    VkMemoryBarrier to_copy = { VK_STRUCTURE_TYPE_MEMORY_BARRIER };
    to_copy.srcAccessMask = VK_ACCESS_SHADER_WRITE_BIT;
    to_copy.dstAccessMask = VK_ACCESS_TRANSFER_READ_BIT;
    vkCmdPipelineBarrier(d->cmd, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 1, &to_copy, 0, 0, 0, 0);
    VkBufferCopy copy = { 0, (VkDeviceSize)slot * pp * 4, (VkDeviceSize)pp * 4 };
    vkCmdCopyBuffer(d->cmd, d->prefetch_coeff[plane], d->gop_buffer[buf][plane], 1, &copy);
  }
  decode3d_submit(d);
}

// Temporal-inverse the whole GOP in gop_buffer[buf] along the frame axis.
static void decode3d_temporal(const Decode3D *d, int buf, int gop_count) {
  decode3d_begin(d);
  int wavelet = d->temporal_wavelet;
  if (d->lossless && (wavelet == 2)) {
    wavelet = 1;
  }
  VkPipeline pipeline = d->lossless ? d->temporal_int : d->temporal_float;
  for (int plane = 0; plane < 3; plane++) {
    int pp = plane_width(plane, d->width) * plane_height(plane, d->height);   // per-plane (subsampled chroma)
    int32_t temporal_push[5] = { pp, gop_count, d->temporal_levels, wavelet, 1 };
    vkCmdBindPipeline(d->cmd, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline);
    vkCmdBindDescriptorSets(d->cmd, VK_PIPELINE_BIND_POINT_COMPUTE, d->layout_temporal, 0, 1, &d->temporal[buf][plane], 0, 0);
    vkCmdPushConstants(d->cmd, d->layout_temporal, VK_SHADER_STAGE_COMPUTE_BIT, 0, 20, temporal_push);
    vkCmdDispatch(d->cmd, (pp + 255) / 256, 1, 1);
  }
  decode3d_submit(d);
}

// Frame-level predict-only MC-Haar INVERSE (prediction_method==3), replacing decode3d_temporal. Deepest temporal
// level first; per pair even = low, odd = high + OBMC(low) using each high-pass frame's stored luma MV field
// (frame_mv, indexed by deinterleaved position low_count+k). Mirrors the CPU mctf_inverse. mv_buffer is reused
// per pair, so each pair is its own submit (the caller already waited+reset the fence before calling, matching
// decode3d_temporal's contract; the LAST submit is left pending for the caller's vkWaitForFences).
static void decode3d_mctf_inverse(const Decode3D *d, int buf, int gop_count, const int *frame_mv) {
  int luma_blocks = d->motion_blocks_x * d->motion_blocks_y;
  int plane_w[3], plane_h[3], plane_pp[3], plane_mbx[3];
  for (int plane = 0; plane < 3; plane++) {
    plane_w[plane] = plane_width(plane, d->width);
    plane_h[plane] = plane_height(plane, d->height);
    plane_pp[plane] = plane_w[plane] * plane_h[plane];
    plane_mbx[plane] = ((plane_w[plane] + d->motion_block) - 1) / d->motion_block;   // each plane's motion grid (subsampled chroma is smaller)
  }
  int lengths[16], count = 0, len = gop_count;
  for (int l = 0; (l < d->temporal_levels) && (len >= 2); l++) {
    lengths[count++] = len;
    len = (len + 1) / 2;
  }
  int submitted = 0;
  for (int l = count - 1; l >= 0; l--) {
    int level_len = lengths[l], low_count = (level_len + 1) / 2;
    for (int k = 0; k < low_count; k++) {
      int even = 2 * k;
      if (submitted) {
        decode3d_wait(d);   // wait the previous pair/back-copy before reusing the command buffer + mv_buffer
      }
      decode3d_begin(d);
      if (((2 * k) + 1) < level_len) {
        int odd = (2 * k) + 1;
        memcpy(d->mv_map, &frame_mv[((size_t)(low_count + k) * luma_blocks) * 2], (size_t)luma_blocks * 2 * 4);
        for (int plane = 0; plane < 3; plane++) {
          int pp = plane_pp[plane];
          VkDeviceSize low_off = (VkDeviceSize)k * pp * 4, high_off = (VkDeviceSize)(low_count + k) * pp * 4;
          VkDeviceSize even_off = (VkDeviceSize)even * pp * 4, odd_off = (VkDeviceSize)odd * pp * 4;
          // mc: warp gop@low(k) by this pair's MVs -> mctf_pred[plane]
          bind_storage_buffers_offset(d->mctf_mc[plane],
            (VkBuffer[]){ d->gop_buffer[buf][plane], d->mv_buffer, d->mctf_pred[plane] }, (VkDeviceSize[]){ low_off, 0, 0 }, 3);
          int32_t mc_push[3] = { plane_w[plane], plane_h[plane], plane_mbx[plane] };
          vkCmdBindPipeline(d->cmd, VK_PIPELINE_BIND_POINT_COMPUTE, d->mc);
          vkCmdBindDescriptorSets(d->cmd, VK_PIPELINE_BIND_POINT_COMPUTE, d->layout_mc, 0, 1, &d->mctf_mc[plane], 0, 0);
          vkCmdPushConstants(d->cmd, d->layout_mc, VK_SHADER_STAGE_COMPUTE_BIT, 0, 12, mc_push);
          vkCmdDispatch(d->cmd, (pp + 255) / 256, 1, 1);
          VkBufferCopy even_copy = { low_off, even_off, (VkDeviceSize)pp * 4 };    // even = low passthrough -> scratch
          vkCmdCopyBuffer(d->cmd, d->gop_buffer[buf][plane], d->mctf_scratch[plane], 1, &even_copy);
          VkBufferCopy high_copy = { high_off, odd_off, (VkDeviceSize)pp * 4 };    // high -> scratch@odd (coeff_add adds pred in place)
          vkCmdCopyBuffer(d->cmd, d->gop_buffer[buf][plane], d->mctf_scratch[plane], 1, &high_copy);
          VkMemoryBarrier to_add = { VK_STRUCTURE_TYPE_MEMORY_BARRIER };   // mc (compute) + copies (transfer) -> coeff_add (compute)
          to_add.srcAccessMask = VK_ACCESS_SHADER_WRITE_BIT | VK_ACCESS_TRANSFER_WRITE_BIT;
          to_add.dstAccessMask = VK_ACCESS_SHADER_READ_BIT | VK_ACCESS_SHADER_WRITE_BIT;
          vkCmdPipelineBarrier(d->cmd, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT | VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, 0, 1, &to_add, 0, 0, 0, 0);
          // coeff_add: scratch@odd (= high) += pred -> odd
          bind_storage_buffers_offset(d->mctf_add[plane],
            (VkBuffer[]){ d->mctf_scratch[plane], d->mctf_pred[plane] }, (VkDeviceSize[]){ odd_off, 0 }, 2);
          int32_t add_push[2] = { pp, 1 };
          vkCmdBindPipeline(d->cmd, VK_PIPELINE_BIND_POINT_COMPUTE, d->coeff_add);
          vkCmdBindDescriptorSets(d->cmd, VK_PIPELINE_BIND_POINT_COMPUTE, d->layout_coeff_add, 0, 1, &d->mctf_add[plane], 0, 0);
          vkCmdPushConstants(d->cmd, d->layout_coeff_add, VK_SHADER_STAGE_COMPUTE_BIT, 0, 8, add_push);
          vkCmdDispatch(d->cmd, (pp + 255) / 256, 1, 1);
        }
      } else {
        for (int plane = 0; plane < 3; plane++) {   // odd tail (no partner): even = low passthrough -> scratch@even
          int pp = plane_pp[plane];
          VkBufferCopy even_copy = { (VkDeviceSize)k * pp * 4, (VkDeviceSize)even * pp * 4, (VkDeviceSize)pp * 4 };
          vkCmdCopyBuffer(d->cmd, d->gop_buffer[buf][plane], d->mctf_scratch[plane], 1, &even_copy);
        }
      }
      decode3d_submit(d);
      submitted = 1;
    }
    decode3d_wait(d);   // copy scratch[0..level_len) back into gop_buffer (the interleaved frames for this level)
    decode3d_begin(d);
    for (int plane = 0; plane < 3; plane++) {
      VkBufferCopy back = { 0, 0, (VkDeviceSize)level_len * plane_pp[plane] * 4 };
      vkCmdCopyBuffer(d->cmd, d->mctf_scratch[plane], d->gop_buffer[buf][plane], 1, &back);
    }
    decode3d_submit(d);
    submitted = 1;
  }
}

// Finish a decoded GOP: MCTF MC-Haar inverse (prediction_method==3) or the open-loop temporal-DWT inverse.
static void decode3d_finish_gop(const Decode3D *d, int buf, int gop_count, int *const *mctf_mv) {
  if (d->mctf) {
    decode3d_mctf_inverse(d, buf, gop_count, mctf_mv[buf]);
  } else {
    decode3d_temporal(d, buf, gop_count);
  }
}

// Number of frames in the GOP starting at `start` (a type-0 frame followed by type-2 continuations).
static int gop_count_from(const FrameEntry *index, uint32_t start, uint32_t frame_count) {
  int count = 1;
  while (((start + (uint32_t)count) < frame_count) && (index[start + count].type != 0)) {
    count++;
  }
  return count;
}

// Container frames are compressed (method 1 = LZSS, 2 = LZBRRC, 0 = raw). read_frame
// reads frame `entry` from the container at its offset, decompressing the [method][raw_len] framing, into *buffer (grown as needed);
// returns the uncompressed payload length. An internal scratch holds the compressed bytes. The GPU never sees the
// compressed form — the rest of the player parses/uploads the decompressed bytes exactly as before.
static int g_decompress_frames = 0;
static size_t read_frame(FILE *file, const FrameEntry *entry, uint8_t **buffer, size_t *capacity) {
  fseeko(file, (off_t)entry->offset, SEEK_SET);
  if (!g_decompress_frames) {
    if (*capacity < (size_t)entry->size) {
      *capacity = entry->size;
      *buffer = realloc(*buffer, *capacity);
      if (!*buffer) {
        die("realloc");
      }
    }
    if (fread(*buffer, 1, entry->size, file) != entry->size) {
      die("frame read");
    }
    return entry->size;
  }
  static uint8_t *compressed = NULL;
  static size_t compressed_capacity = 0;
  if (compressed_capacity < (size_t)entry->size) {
    compressed_capacity = entry->size;
    compressed = realloc(compressed, compressed_capacity);
    if (!compressed) {
      die("realloc");
    }
  }
  if (fread(compressed, 1, entry->size, file) != entry->size) {
    die("frame read");
  }
  uint32_t raw_length;
  memcpy(&raw_length, compressed + 1, 4);
  if (*capacity < (size_t)raw_length) {
    *capacity = raw_length;
    *buffer = realloc(*buffer, *capacity);
    if (!*buffer) {
      die("realloc");
    }
  }
  if (compressed[0] == 1) {
    lz_decompress(compressed + 5, (size_t)entry->size - 5, *buffer, raw_length);
  } else if (compressed[0] == 2) {
    lzbrrc_decompress(compressed + 5, (size_t)entry->size - 5, *buffer, raw_length);
  } else {
    memcpy(*buffer, compressed + 5, raw_length);
  }
  return raw_length;
}

// Read subband frame `source_index`'s payload from the container and upload its packed bytes + block
// offsets to the shared upload buffers; (lossy) build its temporally-scaled quant map. Feeds decode3d_spatial.
static void upload_subband(FILE *file, const FrameEntry *index, uint32_t source_index, uint8_t **frame_buffer, size_t *frame_buffer_capacity,
                           const int *block_count_plane, void **offset_map, void *data_map, void **step_map, int *step,
                           int width, int height, int levels, int quality, int lossless,
                           int subband_in_gop, int gop_count, int temporal_levels, int *mctf_mv_out) {
  read_frame(file, &index[source_index], frame_buffer, frame_buffer_capacity);
  uint32_t *parse_offsets[3] = { (uint32_t *)offset_map[0], (uint32_t *)offset_map[1], (uint32_t *)offset_map[2] };
  int parsed_block_count;
  const uint8_t *mv_data;
  uint32_t mv_length;
  const uint8_t *frame_data = parse_frame_header(*frame_buffer, block_count_plane, &parsed_block_count, parse_offsets, &mv_data, &mv_length);
  if (mctf_mv_out && (mv_length > 0)) {   // MCTF high-pass frame: decode its luma MV field for the MC-Haar temporal inverse
    int motion_blocks_x = ((width + g_motion_block) - 1) / g_motion_block, motion_blocks_y = ((height + g_motion_block) - 1) / g_motion_block;
    if (g_mv_codec == 1) {
      mv_blob_decode_range(mv_data, (size_t)mv_length, 0, NULL, 0, mctf_mv_out, 0, NULL, 0, motion_blocks_x, motion_blocks_y);
    } else {
      BitReader mv_reader;
      bitreader_init(&mv_reader, mv_data, (size_t)mv_length);
      decode_motion_vectors(&mv_reader, mctf_mv_out, motion_blocks_x, motion_blocks_y);
    }
  }
  uint32_t data_length;
  memcpy(&data_length, frame_data - 4, 4);
  memcpy(data_map, frame_data, data_length);
  if (!lossless) {
    int level = temporal_quant_level(subband_in_gop, gop_count, temporal_levels);
    int effective_quality = (int)(((float)quality * temporal_quant_scale(level)) + 0.5f);
    if (effective_quality < 1) {
      effective_quality = 1;
    }
    for (int plane = 0; plane < 3; plane++) {   // per-plane quant steps (chroma is subsampled), as the encoder builds them
      int pw = plane_width(plane, width), ph = plane_height(plane, height);
      build_quantization_steps(step, pw, ph, levels, effective_quality);
      memcpy(step_map[plane], step, (size_t)(pw * ph) * 4);
    }
  }
}

// Verify only: CPU-decode a whole GOP (decode_gop_3ddwt) into cpu_gop_rgb to compare the GPU decode against.
static void cpu_decode_gop(FILE *file, const FrameEntry *index, uint32_t gop_start, int gop_count,
                           int width, int height, int levels, int quality, uint8_t **cpu_gop_rgb) {
  uint8_t *payload[MAX_GOP];
  size_t payload_length[MAX_GOP];
  for (int g = 0; g < gop_count; g++) {
    uint32_t source_index = gop_start + (uint32_t)g;
    payload[g] = NULL;
    size_t payload_capacity = 0;
    payload_length[g] = read_frame(file, &index[source_index], &payload[g], &payload_capacity);
  }
  decode_gop_3ddwt(payload, payload_length, gop_count, width, height, levels, quality, cpu_gop_rgb);
  for (int g = 0; g < gop_count; g++) {
    free(payload[g]);
  }
}

static void image_barrier(VkImage image, VkImageLayout old_layout, VkImageLayout new_layout,
                          VkAccessFlags src_access, VkAccessFlags dst_access,
                          VkPipelineStageFlags src_stage, VkPipelineStageFlags dst_stage) {
  VkImageMemoryBarrier barrier = { VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER };
  barrier.oldLayout = old_layout;
  barrier.newLayout = new_layout;
  barrier.srcAccessMask = src_access;
  barrier.dstAccessMask = dst_access;
  barrier.srcQueueFamilyIndex = barrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
  barrier.image = image;
  barrier.subresourceRange = (VkImageSubresourceRange){ VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1 };
  vkCmdPipelineBarrier(command_buffer, src_stage, dst_stage, 0, 0, 0, 0, 0, 1, &barrier);
}

// Create or recreate the swapchain at the surface's current size (call on startup and on resize /
// VK_ERROR_OUT_OF_DATE_KHR). Returns the new extent. If the surface is currently zero-sized (window
// minimized) it leaves the swapchain untouched and returns {0,0}, so the caller waits and retries.
static VkExtent2D recreate_swapchain(VkDevice device, VkPhysicalDevice physical_device, VkSurfaceKHR surface,
                                     VkSurfaceFormatKHR surface_format, VkSwapchainKHR *swapchain,
                                     VkImage **swapchain_images, uint32_t *swapchain_image_count) {
  VkSurfaceCapabilitiesKHR caps;
  vkGetPhysicalDeviceSurfaceCapabilitiesKHR(physical_device, surface, &caps);
  VkExtent2D extent = caps.currentExtent;
  if ((extent.width == 0) || (extent.height == 0)) {
    return extent;   // minimized: don't (re)create yet
  }
  vkDeviceWaitIdle(device);
  uint32_t image_count = caps.minImageCount + 1;
  if (caps.maxImageCount && (image_count > caps.maxImageCount)) {
    image_count = caps.maxImageCount;
  }
  VkSwapchainCreateInfoKHR info = { VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR };
  info.surface = surface;
  info.minImageCount = image_count;
  info.imageFormat = surface_format.format;
  info.imageColorSpace = surface_format.colorSpace;
  info.imageExtent = extent;
  info.imageArrayLayers = 1;
  info.imageUsage = VK_IMAGE_USAGE_TRANSFER_DST_BIT;
  info.preTransform = caps.currentTransform;
  info.compositeAlpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR;
  info.presentMode = VK_PRESENT_MODE_FIFO_KHR;
  info.clipped = VK_TRUE;
  info.oldSwapchain = *swapchain;
  VkSwapchainKHR new_swapchain;
  VK_CHECK(vkCreateSwapchainKHR(device, &info, 0, &new_swapchain));
  if (*swapchain) {
    vkDestroySwapchainKHR(device, *swapchain, 0);
  }
  *swapchain = new_swapchain;
  free(*swapchain_images);
  vkGetSwapchainImagesKHR(device, new_swapchain, swapchain_image_count, 0);
  *swapchain_images = checked_malloc(*swapchain_image_count * sizeof(VkImage));
  vkGetSwapchainImagesKHR(device, new_swapchain, swapchain_image_count, *swapchain_images);
  return extent;
}

// does this GPU support Vulkan H.264 hardware decode? Needs a VIDEO_DECODE queue family and
// H.264 High-profile / 4:2:0 / 8-bit decode caps (the profile the encoder targets). Mirrors vkvid_probe.
static int gpu_supports_h264_decode(VkInstance instance, VkPhysicalDevice gpu) {
  uint32_t family_count = 0;
  vkGetPhysicalDeviceQueueFamilyProperties(gpu, &family_count, 0);
  VkQueueFamilyProperties *families = checked_malloc(family_count * sizeof(*families));
  vkGetPhysicalDeviceQueueFamilyProperties(gpu, &family_count, families);
  int has_video_queue = 0;
  for (uint32_t i = 0; i < family_count; i++) {
    if (families[i].queueFlags & VK_QUEUE_VIDEO_DECODE_BIT_KHR) {
      has_video_queue = 1;
      break;
    }
  }
  free(families);
  if (!has_video_queue) {
    return 0;
  }
  PFN_vkGetPhysicalDeviceVideoCapabilitiesKHR get_caps =
      (PFN_vkGetPhysicalDeviceVideoCapabilitiesKHR)vkGetInstanceProcAddr(instance, "vkGetPhysicalDeviceVideoCapabilitiesKHR");
  if (!get_caps) {
    return 0;
  }
  VkVideoDecodeH264ProfileInfoKHR h264_profile = { VK_STRUCTURE_TYPE_VIDEO_DECODE_H264_PROFILE_INFO_KHR };
  h264_profile.stdProfileIdc = STD_VIDEO_H264_PROFILE_IDC_HIGH;
  h264_profile.pictureLayout = VK_VIDEO_DECODE_H264_PICTURE_LAYOUT_PROGRESSIVE_KHR;
  VkVideoProfileInfoKHR profile = { VK_STRUCTURE_TYPE_VIDEO_PROFILE_INFO_KHR };
  profile.pNext = &h264_profile;
  profile.videoCodecOperation = VK_VIDEO_CODEC_OPERATION_DECODE_H264_BIT_KHR;
  profile.chromaSubsampling = VK_VIDEO_CHROMA_SUBSAMPLING_420_BIT_KHR;
  profile.lumaBitDepth = VK_VIDEO_COMPONENT_BIT_DEPTH_8_BIT_KHR;
  profile.chromaBitDepth = VK_VIDEO_COMPONENT_BIT_DEPTH_8_BIT_KHR;
  VkVideoDecodeH264CapabilitiesKHR h264_caps = { VK_STRUCTURE_TYPE_VIDEO_DECODE_H264_CAPABILITIES_KHR };
  VkVideoDecodeCapabilitiesKHR decode_caps = { VK_STRUCTURE_TYPE_VIDEO_DECODE_CAPABILITIES_KHR };
  decode_caps.pNext = &h264_caps;
  VkVideoCapabilitiesKHR caps = { VK_STRUCTURE_TYPE_VIDEO_CAPABILITIES_KHR };
  caps.pNext = &decode_caps;
  return (get_caps(gpu, &profile, &caps) == VK_SUCCESS) ? 1 : 0;
}

// ---------------------------------------------------- hierarchical B-frame stream decoder
// Decodes the (coding-order) B-stream on the CPU with decode_frame_bidi, mirroring the H.264 player's
// DPB + POC reorder. Two independent stores keep eviction simple: the DPB holds reconstructed YCoCg per
// CODING index (a prediction reference, freed once no later frame references it — last_use), while the
// reconstructed RGB is held per POC for the display reorder (freed by the caller once presented). The
// blend weights are derived from the stored POCs (the container stores none). Bounded memory: only the
// live reference window (~2*period frames) plus the in-flight reorder frames are resident at once.
typedef struct {
  FILE *file;
  const FrameEntry *index;
  int frame_count, width, height, levels;
  int plane_pixels[3];
  size_t frame_bytes;
  int *last_use;        // [frame_count]: largest coding index that references this one (>= itself)
  int32_t **dpb;        // [frame_count*3]: reconstructed YCoCg planes per coding index (NULL = absent/evicted)
  uint8_t **rgb;        // [frame_count]: reconstructed RGB24 per POC (NULL = not decoded yet / freed after display)
  int cursor;           // next coding index to decode
  int evict_low;        // watermark: every dpb entry below this is already freed
  uint8_t *payload;     // grown-as-needed scratch for the per-frame payload read
  size_t payload_cap;
} BStream;

static void bstream_init(BStream *bs, FILE *file, const FrameEntry *index, int frame_count,
                         int width, int height, int levels, size_t frame_bytes) {
  bs->file = file;
  bs->index = index;
  bs->frame_count = frame_count;
  bs->width = width;
  bs->height = height;
  bs->levels = levels;
  bs->frame_bytes = frame_bytes;
  for (int p = 0; p < 3; p++) {
    bs->plane_pixels[p] = plane_width(p, width) * plane_height(p, height);
  }
  bs->last_use = checked_malloc((size_t)frame_count * sizeof(int));
  bs->dpb = checked_malloc((size_t)frame_count * 3 * sizeof(int32_t *));
  bs->rgb = checked_malloc((size_t)frame_count * sizeof(uint8_t *));
  for (int c = 0; c < frame_count; c++) {
    bs->last_use[c] = c;   // a frame is at least live until it is itself decoded
    bs->rgb[c] = NULL;
    for (int p = 0; p < 3; p++) {
      bs->dpb[(c * 3) + p] = NULL;
    }
  }
  for (int c = 0; c < frame_count; c++) {   // last_use[ref] = the latest coding index referencing it
    if ((index[c].ref0 >= 0) && (index[c].ref0 < frame_count) && (c > bs->last_use[index[c].ref0])) {
      bs->last_use[index[c].ref0] = c;
    }
    if ((index[c].ref1 >= 0) && (index[c].ref1 < frame_count) && (c > bs->last_use[index[c].ref1])) {
      bs->last_use[index[c].ref1] = c;
    }
  }
  bs->cursor = 0;
  bs->evict_low = 0;
  bs->payload = NULL;
  bs->payload_cap = 0;
}

// Decode forward (in coding order) until the frame at display position target_poc is reconstructed.
static void bstream_decode_until(BStream *bs, int target_poc) {
  while (!bs->rgb[target_poc]) {
    int c = bs->cursor;
    const FrameEntry *entry = &bs->index[c];
    read_frame(bs->file, entry, &bs->payload, &bs->payload_cap);
    int32_t **ref0 = (entry->ref0 >= 0) ? &bs->dpb[entry->ref0 * 3] : NULL;
    int32_t **ref1 = (entry->ref1 >= 0) ? &bs->dpb[entry->ref1 * 3] : NULL;
    int weight0 = 0, weight1 = 0;   // weights derived from the temporal (POC) distances, as in build_b_range
    if (ref0 && ref1) {
      int poc_self = (int)entry->poc, poc0 = (int)bs->index[entry->ref0].poc, poc1 = (int)bs->index[entry->ref1].poc;
      weight0 = (256 * (poc1 - poc_self)) / (poc1 - poc0);
      weight1 = 256 - weight0;
    } else if (ref0) {
      weight0 = 256;
    }
    for (int p = 0; p < 3; p++) {
      bs->dpb[(c * 3) + p] = checked_malloc((size_t)bs->plane_pixels[p] * 4);
    }
    bs->rgb[entry->poc] = checked_malloc(bs->frame_bytes);
    decode_frame_bidi(bs->payload, bs->width, bs->height, bs->levels, entry->quality,
                      ref0, ref1, weight0, weight1, &bs->dpb[c * 3], bs->rgb[entry->poc]);
    bs->cursor++;
    // Evict DPB entries no longer referenced by any future frame (the RGB display copy is separate).
    for (int x = bs->evict_low; x < bs->cursor; x++) {
      if (bs->dpb[x * 3] && (bs->last_use[x] < bs->cursor)) {
        for (int p = 0; p < 3; p++) {
          free(bs->dpb[(x * 3) + p]);
          bs->dpb[(x * 3) + p] = NULL;
        }
      }
    }
    while ((bs->evict_low < bs->cursor) && !bs->dpb[bs->evict_low * 3]) {
      bs->evict_low++;
    }
  }
}

static void bstream_free(BStream *bs) {
  for (int c = 0; c < bs->frame_count; c++) {
    free(bs->rgb[c]);
    for (int p = 0; p < 3; p++) {
      free(bs->dpb[(c * 3) + p]);
    }
  }
  free(bs->rgb);
  free(bs->dpb);
  free(bs->last_use);
  free(bs->payload);
}

int main(int argc, char **argv) {
  if (argc < 2) {
    fprintf(stderr,
      "usage: %s file.fwv [flags...]\n"
      "  playback (default: open a window and play with audio):\n"
      "    --exposure=<f>                 HDR exposure override (default: keep the file's)\n"
      "    --output=scrgb|sdr             force scRGB FP16 swapchain or SDR tonemap (default: autodetect)\n"
      "    --decoder=h264|wavelet|auto    pick the embedded stream when both exist (default auto: H.264 where HW-decodable)\n"
      "  B-frame decode (auto-detected from the container):\n"
      "    --cpu-decode                   force the slow CPU B-decode oracle (GPU bidi decode is the default)\n"
      "    --gpu-decode                   force the GPU bidi decode (default; accepted for compatibility)\n"
      "  offline / debug (no window):\n"
      "    --decode-to <file.avi>         decode the whole stream to an OpenDML AVI (RGB + PCM16) and exit\n"
      "    --verify                       GPU-decode vs CPU-decode PSNR self-check, then exit\n"
      "    --dump                         dump the first decoded frame and exit\n",
      argv[0]);
    return 1;
  }
  float exposure_override = -1.0f;   // <0 = keep the default
  int output_mode = 0;               // 0 = autodetect, 1 = force scRGB FP16, 2 = force SDR tonemap
  int verify = 0;                    // --verify: GPU-decode vs CPU-decode PSNR check, no window
  int cpu_decode = 0;                // --cpu-decode: force the Stage A CPU B-decode (oracle/fallback); default for a B-stream is the GPU bidi decode (Stage B1b)
  int dump_first_frame = 0;          // --dump: write the GPU-decoded frame 0 to /tmp/fwv_frame0.ppm
  int decoder_choice = 0;            // --decoder: 0 = auto (H.264 if available, else wavelet), 1 = force H.264, 2 = force wavelet
  const char *decode_to_path = NULL; // --decode-to <file.avi>: decode the whole stream to an OpenDML AVI (RGB32 + PCM16)
  for (int a = 2; a < argc; a++) {
    if (strncmp(argv[a], "--exposure=", 11) == 0) {
      exposure_override = (float)atof(argv[a] + 11);
    } else if (strcmp(argv[a], "--output=scrgb") == 0) {
      output_mode = 1;
    } else if (strcmp(argv[a], "--output=sdr") == 0) {
      output_mode = 2;
    } else if (strcmp(argv[a], "--verify") == 0) {
      verify = 1;
    } else if (strcmp(argv[a], "--cpu-decode") == 0) {
      cpu_decode = 1;   // force the Stage A CPU B-decode (the GPU bidi decode is the default)
    } else if (strcmp(argv[a], "--gpu-decode") == 0) {
      cpu_decode = 0;   // accepted for compatibility; GPU bidi decode is now the default for a B-stream
    } else if (strcmp(argv[a], "--dump") == 0) {
      dump_first_frame = 1;
    } else if (strncmp(argv[a], "--decoder=", 10) == 0) {
      const char *value = argv[a] + 10;   // --decoder=h264|wavelet|auto
      decoder_choice = strstr(value, "h264") ? 1 : (strstr(value, "wav") ? 2 : 0);
    } else if ((strcmp(argv[a], "--decoder") == 0) && ((a + 1) < argc)) {
      const char *value = argv[++a];      // --decoder h264|wavelet|auto
      decoder_choice = strstr(value, "h264") ? 1 : (strstr(value, "wav") ? 2 : 0);
    } else if (strncmp(argv[a], "--decode-to=", 12) == 0) {
      decode_to_path = argv[a] + 12;
    } else if ((strcmp(argv[a], "--decode-to") == 0) && ((a + 1) < argc)) {
      decode_to_path = argv[++a];
    }
  }
  if (decode_to_path) {
    output_mode = 2;   // export is RGB32 8-bit SDR -> force the SDR (HDR-tonemapped) output path
  }
  FILE *file = fopen(argv[1], "rb");
  if (!file) {
    die("cannot open .fwv");
  }
  ContainerHeader header;
  if (((fread(&header, sizeof header, 1, file) != 1) || memcmp(header.magic, "FWVC", 4)) || (header.version != 1)) {
    die("not a .FWV (or unsupported version)");
  }
  g_decompress_frames = 1;                  // per-frame [method][raw_len] framing (method 1 = LZSS, 2 = LZBRRC, 0 = raw)
  g_mv_codec = header.mv_codec;             // motion-vector entropy coder selector (0 = Exp-Golomb, 1 = range)
  int width = header.width;
  int height = header.height;
  int levels = header.levels;
  int quality = header.quality;
  g_chroma_format = header.chroma_format;   // set before plane_width/plane_height are used (block counts, plane dims)
  int mode_3ddwt = (header.prediction_method == 2) || (header.prediction_method == 3);   // 2 = open-loop 3D-DWT, 3 = MCTF 3D-DWT
  g_mctf = (header.prediction_method == 3);   // MCTF: the temporal transform is predict-only MC-Haar (motion), g_motion_block from reserved2[5]
  int has_bframes = (header.prediction_method == 1) && (header.reserved2[2] > 0);   // hierarchical B-stream (coding-order index + POC reorder)
  if (((header.reserved2[4] == 32 || header.reserved2[4] == 64) || header.reserved2[4] == 128)) {
    g_block_size = header.reserved2[4];   // coding block size (32/64/128) — the bitplane_unpack pipeline is built for it
  }
  if (((header.reserved2[5] == 8 || header.reserved2[5] == 16) || header.reserved2[5] == 32)) {
    g_motion_block = header.reserved2[5];   // motion block size (8/16/32) — the mc/blend_mode pipelines are built for it
  } else if (header.reserved2[5] == 1) {
    g_motion_variable = 1;   // variable quadtree motion (root 32 -> 8); the fine grid is 8, the blob is a quadtree
    g_motion_block = 8;
  }
  if (mode_3ddwt) {
    g_temporal_levels = header.reserved2[0] ? header.reserved2[0] : 2;
    g_temporal_wavelet = header.reserved2[1];
    // chroma_format from the header (4:4:4 / 4:2:2 / 4:2:0); lossless was forced 4:4:4 at encode.
  }
  int blocks_x = block_count_x(width);
  int blocks_y = block_count_y(height);
  int block_count = blocks_x * blocks_y;   // luma (full-res) block count; chroma is per-plane (subsampled -> fewer)
  // Per-plane block count (luma full-res; chroma fewer when subsampled). 4:4:4 -> all three equal block_count.
  int block_count_plane[3];
  for (int p = 0; p < 3; p++) {
    block_count_plane[p] = block_count_x(plane_width(p, width)) * block_count_y(plane_height(p, height));
  }
  int pixel_count = width * height;
  double fps = (double)header.fps_num / (header.fps_den ? header.fps_den : 1);
  int lossless = (quality == 0);   // Q0 = reversible integer 5/3, skip dequant/round

  // Per-frame index: {offset, size, type (I/P), quality} of each frame's payload.
  FrameEntry *index = checked_malloc((size_t)header.frame_count * sizeof(FrameEntry));
  fseeko(file, (off_t)header.index_offset, SEEK_SET);
  if (fread(index, sizeof(FrameEntry), header.frame_count, file) != header.frame_count) {
    die("index");
  }
  printf("play %s: %dx%d @ %.2f fps | %u frames | audio=%s\n",
         argv[1], width, height, fps, header.frame_count, header.audio_size ? "yes" : "no");
  const char *primaries_name = (header.colour_primaries == 9) ? "BT.2020" : ((header.colour_primaries == 12) ? "Display-P3" : "BT.709");
  const char *transfer_name = (header.transfer_function == 16) ? "PQ" : ((header.transfer_function == 18) ? "HLG" : ((header.transfer_function == 8) ? "linear" : "sRGB"));
  const char *chroma_name = (g_chroma_format == 2) ? "4:2:0" : ((g_chroma_format == 1) ? "4:2:2" : "4:4:4");   // g_chroma_format set above
  printf("  colour: %s / %s / %d-bit %s%s / %s\n", primaries_name, transfer_name, header.bit_depth,
         (header.colour_flags & 1) ? "HDR" : "SDR", (header.colour_flags & 2) ? " +HDR10 metadata" : "", chroma_name);
  int is_hdr = (header.colour_flags & 1) != 0;
  size_t frame_bytes = (size_t)pixel_count * (is_hdr ? 6 : 3);   // one decoded RGB frame: 8-bit SDR (3B) or 16-bit HDR (6B)
  g_chroma_quant = header.chroma_quant_x16 ? ((float)header.chroma_quant_x16 / 16.0f) : 1.0f;   // chroma quant weighting from the container (0 = old file -> off)
  float hdr_exposure = 100.0f;   // SDR-display tonemap strength (X11); --exposure overrides
  if (is_hdr) {
    set_sample_mode(1);   // HDR is 12-bit BT.2020 (PQ or HLG), both unsigned (the CPU VERIFY decode reads these)
    if (exposure_override >= 0.0f) {
      hdr_exposure = exposure_override;   // --exposure=<f>
    }
  }

  // ---- SDL window + Vulkan instance + surface ----
  if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO)) {
    die(SDL_GetError());
  }
  SDL_Window *window = SDL_CreateWindow("fwvplay", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height,
                                        SDL_WINDOW_VULKAN | SDL_WINDOW_SHOWN | SDL_WINDOW_MAXIMIZED | SDL_WINDOW_RESIZABLE);
  SDL_PumpEvents();   // let the WM apply the maximize before we query the surface extent for the swapchain
  if (!window) {
    die(SDL_GetError());
  }
  unsigned extension_count = 0;
  SDL_Vulkan_GetInstanceExtensions(window, &extension_count, 0);
  const char **extensions = checked_malloc((extension_count + 1) * sizeof(char *));
  SDL_Vulkan_GetInstanceExtensions(window, &extension_count, extensions);
  // Add VK_EXT_swapchain_colorspace if the loader has it, so the surface can report HDR/scRGB colour
  // spaces (EXTENDED_SRGB_LINEAR). Optional: absent on most SDR-only X11 setups -> we fall back to sRGB.
  {
    uint32_t available_count = 0;
    vkEnumerateInstanceExtensionProperties(0, &available_count, 0);
    VkExtensionProperties *available = checked_malloc(available_count * sizeof(*available));
    vkEnumerateInstanceExtensionProperties(0, &available_count, available);
    for (uint32_t i = 0; i < available_count; i++) {
      if (!strcmp(available[i].extensionName, VK_EXT_SWAPCHAIN_COLOR_SPACE_EXTENSION_NAME)) {
        extensions[extension_count++] = VK_EXT_SWAPCHAIN_COLOR_SPACE_EXTENSION_NAME;
        break;
      }
    }
    free(available);
  }
  VkApplicationInfo application_info = { VK_STRUCTURE_TYPE_APPLICATION_INFO };
  application_info.apiVersion = VK_API_VERSION_1_3;   // 1.3 so VK_KHR_video_* deps (synchronization2) are core
  VkInstanceCreateInfo instance_info = { VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO };
  instance_info.pApplicationInfo = &application_info;
  instance_info.enabledExtensionCount = extension_count;
  instance_info.ppEnabledExtensionNames = extensions;
  VkInstance instance;
  VK_CHECK(vkCreateInstance(&instance_info, 0, &instance));
  VkSurfaceKHR surface;
  if (!SDL_Vulkan_CreateSurface(window, instance, &surface)) {
    die(SDL_GetError());
  }

  // ---- pick a physical device with a graphics + compute + present queue ----
  uint32_t device_count = 0;
  vkEnumeratePhysicalDevices(instance, &device_count, 0);
  VkPhysicalDevice *devices = checked_malloc(device_count * sizeof(*devices));
  vkEnumeratePhysicalDevices(instance, &device_count, devices);
  physical_device = VK_NULL_HANDLE;
  uint32_t queue_family_index = 0;
  for (uint32_t d = 0; (d < device_count) && (physical_device == VK_NULL_HANDLE); d++) {
    uint32_t family_count = 0;
    vkGetPhysicalDeviceQueueFamilyProperties(devices[d], &family_count, 0);
    VkQueueFamilyProperties *families = checked_malloc(family_count * sizeof(*families));
    vkGetPhysicalDeviceQueueFamilyProperties(devices[d], &family_count, families);
    for (uint32_t q = 0; q < family_count; q++) {
      VkBool32 present_supported = 0;
      vkGetPhysicalDeviceSurfaceSupportKHR(devices[d], q, surface, &present_supported);
      if (((families[q].queueFlags & VK_QUEUE_GRAPHICS_BIT) && (families[q].queueFlags & VK_QUEUE_COMPUTE_BIT)) && present_supported) {
        physical_device = devices[d];
        queue_family_index = q;
        break;
      }
    }
    free(families);
  }
  if (physical_device == VK_NULL_HANDLE) {
    die("no graphics+compute+present queue");
  }
  VkPhysicalDeviceProperties device_properties;
  vkGetPhysicalDeviceProperties(physical_device, &device_properties);
  printf("GPU: %s | decode: GPU\n", device_properties.deviceName);

  // pick the video decode path. H.264 HW where the GPU + container both support it (or forced),
  // otherwise the wavelet GPU-compute path. (--decoder auto|h264|wavelet)
  int gpu_h264 = gpu_supports_h264_decode(instance, physical_device);
  int has_h264_stream = (header.h264_size > 0);
  int use_h264 = (decoder_choice == 2) ? 0 : (has_h264_stream && gpu_h264);
  fprintf(stderr, "decoder: %s  (container h264=%s, gpu h264-decode=%s, request=%s)\n",
          use_h264 ? "H.264 (HW)" : "wavelet (GPU compute)",
          has_h264_stream ? "yes" : "no", gpu_h264 ? "yes" : "no",
          (decoder_choice == 1) ? "force-h264" : ((decoder_choice == 2) ? "force-wavelet" : "auto"));

  // when the H.264 path would be used, give the single shared device the video-decode queue +
  // VK_KHR_video extensions too (additive — the wavelet path simply ignores them). The two paths are
  // separate after init, so one device with the union of queues/extensions is enough.
  int enable_video_queue = (decoder_choice != 2) && (has_h264_stream && gpu_h264);
  int video_queue_family = -1;
  if (enable_video_queue) {
    uint32_t fc = 0;
    vkGetPhysicalDeviceQueueFamilyProperties(physical_device, &fc, 0);
    VkQueueFamilyProperties *fams = checked_malloc(fc * sizeof(*fams));
    vkGetPhysicalDeviceQueueFamilyProperties(physical_device, &fc, fams);
    for (uint32_t i = 0; i < fc; i++) {
      if (fams[i].queueFlags & VK_QUEUE_VIDEO_DECODE_BIT_KHR) {
        video_queue_family = (int)i;
        break;
      }
    }
    free(fams);
    if (video_queue_family < 0) {
      enable_video_queue = 0;
    }
  }

  float queue_priority = 1;
  VkDeviceQueueCreateInfo queue_infos[2];
  uint32_t queue_info_count = 0;
  queue_infos[queue_info_count] = (VkDeviceQueueCreateInfo){ VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO };
  queue_infos[queue_info_count].queueFamilyIndex = queue_family_index;
  queue_infos[queue_info_count].queueCount = 1;
  queue_infos[queue_info_count].pQueuePriorities = &queue_priority;
  queue_info_count++;
  if (enable_video_queue && ((uint32_t)video_queue_family != queue_family_index)) {
    queue_infos[queue_info_count] = (VkDeviceQueueCreateInfo){ VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO };
    queue_infos[queue_info_count].queueFamilyIndex = (uint32_t)video_queue_family;
    queue_infos[queue_info_count].queueCount = 1;
    queue_infos[queue_info_count].pQueuePriorities = &queue_priority;
    queue_info_count++;
  }
  const char *device_extensions_wavelet[] = { VK_KHR_SWAPCHAIN_EXTENSION_NAME };
  const char *device_extensions_video[] = {
    VK_KHR_SWAPCHAIN_EXTENSION_NAME,
    VK_KHR_VIDEO_QUEUE_EXTENSION_NAME,
    VK_KHR_VIDEO_DECODE_QUEUE_EXTENSION_NAME,
    VK_KHR_VIDEO_DECODE_H264_EXTENSION_NAME,
  };
  VkPhysicalDeviceSynchronization2Features sync2_feature = { VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SYNCHRONIZATION_2_FEATURES };
  sync2_feature.synchronization2 = VK_TRUE;
  VkDeviceCreateInfo device_info = { VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO };
  if (enable_video_queue) {
    device_info.pNext = &sync2_feature;   // the H.264 decode path uses synchronization2 barriers
  }
  device_info.queueCreateInfoCount = queue_info_count;
  device_info.pQueueCreateInfos = queue_infos;
  device_info.enabledExtensionCount = enable_video_queue ? 4 : 1;
  device_info.ppEnabledExtensionNames = enable_video_queue ? device_extensions_video : device_extensions_wavelet;
  VK_CHECK(vkCreateDevice(physical_device, &device_info, 0, &device));
  VkQueue queue;
  vkGetDeviceQueue(device, queue_family_index, 0, &queue);
  VkQueue video_queue = VK_NULL_HANDLE;
  if (enable_video_queue) {
    vkGetDeviceQueue(device, (uint32_t)video_queue_family, 0, &video_queue);
  }
  (void)video_queue;

  // ---- swapchain ----
  uint32_t format_count = 0;
  vkGetPhysicalDeviceSurfaceFormatsKHR(physical_device, surface, &format_count, 0);
  VkSurfaceFormatKHR *formats = checked_malloc(format_count * sizeof(*formats));
  vkGetPhysicalDeviceSurfaceFormatsKHR(physical_device, surface, &format_count, formats);
  // HDR output autodetect: on a real HDR display prefer scRGB FP16 (EXTENDED_SRGB_LINEAR); else (e.g.
  // X11, no HDR) fall back to 8-bit sRGB (the tonemap path). --output=sdr forces the fallback, =scrgb forces the try.
  int want_scrgb = is_hdr;
  if (output_mode == 2) {
    want_scrgb = 0;
  } else if (output_mode == 1) {
    want_scrgb = 1;
  }
  int use_scrgb_output = 0;
  VkSurfaceFormatKHR surface_format = formats[0];
  if (want_scrgb) {
    for (uint32_t i = 0; i < format_count; i++) {
      if ((formats[i].format == VK_FORMAT_R16G16B16A16_SFLOAT) && (formats[i].colorSpace == VK_COLOR_SPACE_EXTENDED_SRGB_LINEAR_EXT)) {
        surface_format = formats[i];
        use_scrgb_output = 1;
        break;
      }
    }
  }
  if (!use_scrgb_output) {
    for (uint32_t i = 0; i < format_count; i++) {
      if ((formats[i].format == VK_FORMAT_B8G8R8A8_UNORM) || (formats[i].format == VK_FORMAT_R8G8B8A8_UNORM)) {
        surface_format = formats[i];
        break;
      }
    }
  }
  printf("  output: %s\n", use_scrgb_output ? "scRGB FP16 (EXTENDED_SRGB_LINEAR, HDR display)"
                         : is_hdr ? "sRGB 8-bit (HDR tonemapped to SDR)" : "sRGB 8-bit");
  VkSwapchainKHR swapchain = VK_NULL_HANDLE;
  VkImage *swapchain_images = NULL;
  uint32_t swapchain_image_count = 0;
  VkExtent2D extent = recreate_swapchain(device, physical_device, surface, surface_format,
                                         &swapchain, &swapchain_images, &swapchain_image_count);

  // ---- decode buffers + output image (rgba8) ----
  size_t plane_bytes = (size_t)pixel_count * 4;
  size_t data_capacity = ((size_t)pixel_count * 4) + ((size_t)block_count * 16);
  VkBuffer data_buffer, offset_buffer[3], coeff_buffer[3], scratch_buffer, step_buffer[3];   // step is per-plane (chroma subsampled -> its own subband layout)
  VkBuffer previous_buffer[3];   // P-frame coefficient reference, GPU-resident across frames
  VkBuffer mv_buffer;            // motion: per-16x16-block [mv_x, mv_y] (half-pel); all-zero when there is no motion
  VkDeviceMemory data_memory, offset_memory[3], coeff_memory[3], scratch_memory, step_memory[3];
  VkDeviceMemory previous_memory[3], mv_memory;
  create_buffer(data_capacity, HOST_VISIBLE_COHERENT, &data_buffer, &data_memory);
  for (int plane = 0; plane < 3; plane++) {
    create_buffer((size_t)block_count * 4, HOST_VISIBLE_COHERENT, &offset_buffer[plane], &offset_memory[plane]);
    create_buffer(plane_bytes, DEVICE_LOCAL, &coeff_buffer[plane], &coeff_memory[plane]);
    create_buffer(plane_bytes, DEVICE_LOCAL, &previous_buffer[plane], &previous_memory[plane]);
    create_buffer(plane_bytes, HOST_VISIBLE_COHERENT, &step_buffer[plane], &step_memory[plane]);
  }
  // DWT transpose scratch (also reused for motion compensation): a W x H plane transposes to H x W
  // stored with row stride max(W,H), spanning max(W,H)^2 elements. pixel_count (W*H) is too small for
  // non-square planes (1920x1080 needs 1920^2), which let the transpose go out of bounds and zeroed
  // the right columns — visible as a broken (non-lossless) right side of the frame.
  size_t scratch_side = (size_t)((width > height) ? width : height);
  create_buffer(((scratch_side * scratch_side) * 4), DEVICE_LOCAL, &scratch_buffer, &scratch_memory);
  int motion_blocks_x = ((width + g_motion_block) - 1) / g_motion_block, motion_blocks_y = ((height + g_motion_block) - 1) / g_motion_block;
  create_buffer((((size_t)motion_blocks_x * motion_blocks_y) * 2) * 4, HOST_VISIBLE_COHERENT, &mv_buffer, &mv_memory);

  void *data_map, *offset_map[3], *step_map[3], *mv_map;
  VK_CHECK(vkMapMemory(device, mv_memory, 0, VK_WHOLE_SIZE, 0, &mv_map));
  memset(mv_map, 0, (((size_t)motion_blocks_x * motion_blocks_y) * 2) * 4);   // all-zero MVs (mc_prev == prev when there is no motion)
  VK_CHECK(vkMapMemory(device, data_memory, 0, VK_WHOLE_SIZE, 0, &data_map));
  for (int plane = 0; plane < 3; plane++) {
    VK_CHECK(vkMapMemory(device, offset_memory[plane], 0, VK_WHOLE_SIZE, 0, &offset_map[plane]));
    VK_CHECK(vkMapMemory(device, step_memory[plane], 0, VK_WHOLE_SIZE, 0, &step_map[plane]));
  }
  int *step = checked_malloc(pixel_count * sizeof(int));
  for (int plane = 0; plane < 3; plane++) {   // per-plane quant map (chroma subsampled -> its own subband layout); 4:4:4 -> all identical
    int plane_w = plane_width(plane, width), plane_h = plane_height(plane, height);
    build_quantization_steps(step, plane_w, plane_h, levels, quality);
    memcpy(step_map[plane], step, (size_t)(plane_w * plane_h) * 4);
  }

  VkImageCreateInfo image_info = { VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO };
  image_info.imageType = VK_IMAGE_TYPE_2D;
  VkFormat decode_image_format = use_scrgb_output ? VK_FORMAT_R16G16B16A16_SFLOAT : VK_FORMAT_R8G8B8A8_UNORM;
  image_info.format = decode_image_format;
  image_info.extent = (VkExtent3D){ width, height, 1 };
  image_info.mipLevels = 1;
  image_info.arrayLayers = 1;
  image_info.samples = 1;
  image_info.tiling = VK_IMAGE_TILING_OPTIMAL;
  image_info.usage = VK_IMAGE_USAGE_STORAGE_BIT | VK_IMAGE_USAGE_TRANSFER_SRC_BIT;
  VkImage decode_image;
  VK_CHECK(vkCreateImage(device, &image_info, 0, &decode_image));
  VkMemoryRequirements image_requirements;
  vkGetImageMemoryRequirements(device, decode_image, &image_requirements);
  VkMemoryAllocateInfo image_allocate = { VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO };
  image_allocate.allocationSize = image_requirements.size;
  image_allocate.memoryTypeIndex = find_memory_type(image_requirements.memoryTypeBits, DEVICE_LOCAL);
  VkDeviceMemory decode_image_memory;
  VK_CHECK(vkAllocateMemory(device, &image_allocate, 0, &decode_image_memory));
  vkBindImageMemory(device, decode_image, decode_image_memory, 0);
  VkImageViewCreateInfo view_info = { VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO };
  view_info.image = decode_image;
  view_info.viewType = VK_IMAGE_VIEW_TYPE_2D;
  view_info.format = decode_image_format;
  view_info.subresourceRange = (VkImageSubresourceRange){ VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1 };
  VkImageView decode_view;
  VK_CHECK(vkCreateImageView(device, &view_info, 0, &decode_view));

  // ---- pipelines (same decode chain as fwvdec) ----
  VkDescriptorSetLayout layout_1_buffer = create_descriptor_set_layout(1, 0);
  VkDescriptorSetLayout layout_2_buffers = create_descriptor_set_layout(2, 0);
  VkDescriptorSetLayout layout_3_buffers = create_descriptor_set_layout(3, 0);
  VkDescriptorSetLayout layout_colour = create_descriptor_set_layout(3, 1);
  VkPipelineLayout pipeline_layout_unpack = create_pipeline_layout(layout_3_buffers, 16);
  VkPipelineLayout pipeline_layout_dequant = create_pipeline_layout(layout_2_buffers, 8);   // { pixel_count, chroma_multiplier }
  VkPipelineLayout pipeline_layout_coeff_add = create_pipeline_layout(layout_2_buffers, 8);
  VkPipelineLayout pipeline_layout_transpose = create_pipeline_layout(layout_2_buffers, 16);
  VkPipelineLayout pipeline_layout_row = create_pipeline_layout(layout_1_buffer, 16);
  VkPipelineLayout pipeline_layout_round = create_pipeline_layout(layout_1_buffer, 4);
  VkPipelineLayout pipeline_layout_colour = create_pipeline_layout(layout_colour, 24);   // { width, height, shift_x, shift_y, small_w, small_h }

  VkPipeline pipeline_unpack = create_compute_pipeline_bs("shaders/bitplane_unpack.spv", pipeline_layout_unpack, g_block_size);
  VkPipeline pipeline_dequant = create_compute_pipeline("shaders/dequant97.spv", pipeline_layout_dequant);
  VkPipeline pipeline_transpose = create_compute_pipeline("shaders/transpose_f.spv", pipeline_layout_transpose);
  VkPipeline pipeline_inverse_row_97 = create_compute_pipeline("shaders/idwt97row.spv", pipeline_layout_row);
  VkPipeline pipeline_round = create_compute_pipeline("shaders/round97.spv", pipeline_layout_round);
  VkPipeline pipeline_colour = create_compute_pipeline("shaders/color.spv", pipeline_layout_colour);
  VkPipelineLayout pipeline_layout_colour_hdr = create_pipeline_layout(layout_colour, 32);   // {width, height, exposure, transfer, shift_x, shift_y, small_w, small_h}
  VkPipeline pipeline_colour_hdr = create_compute_pipeline("shaders/color_hdr.spv", pipeline_layout_colour_hdr);
  VkPipeline pipeline_colour_hdr_scrgb = create_compute_pipeline("shaders/color_hdr_scrgb.spv", pipeline_layout_colour_hdr);   // FP16 scRGB output
  VkPipeline pipeline_inverse_row_53 = create_compute_pipeline("shaders/idwt53row.spv", pipeline_layout_row);
  VkPipeline pipeline_inverse_row = lossless ? pipeline_inverse_row_53 : pipeline_inverse_row_97;
  VkPipeline pipeline_coeff_add = create_compute_pipeline("shaders/coeff_add.spv", pipeline_layout_coeff_add);
  VkPipeline pipeline_mc = create_compute_pipeline_motion("shaders/mc.spv", pipeline_layout_unpack, g_motion_block);            // {prev, mv, mc_prev=scratch}, push 12
  VkPipeline pipeline_motion_add = create_compute_pipeline("shaders/motion_add.spv", pipeline_layout_unpack);   // {coeff, mc_prev=scratch, prev}, push 8

  VkDescriptorPoolSize pool_sizes[2] = {
    { VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, 240 },   // raised for the 3D-DWT prefetch sets + bidi (B1b) + motion (B2) + mode (Phase 2) + MCTF (3 mc + 3 add) sets
    { VK_DESCRIPTOR_TYPE_STORAGE_IMAGE, 1 },
  };
  VkDescriptorPoolCreateInfo pool_info = { VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO };
  pool_info.maxSets = 92;   // B1b bidi (6) + B2 motion (6) + Phase 2 mode (3) + MCTF (set_mctf_mc[3] + set_mctf_add[3] = 6)
  pool_info.poolSizeCount = 2;
  pool_info.pPoolSizes = pool_sizes;
  VkDescriptorPool descriptor_pool;
  VK_CHECK(vkCreateDescriptorPool(device, &pool_info, 0, &descriptor_pool));

  VkDescriptorSet set_unpack[3], set_dequant[3], set_add[3], set_coeff_to_scratch[3], set_scratch_to_coeff[3], set_row[3];
  VkDescriptorSet set_mc_play[3], set_motion_add_play[3];   // motion (mc_prev reuses scratch_buffer, transient per plane)
  VkDescriptorSet set_row_scratch, set_colour;
  for (int plane = 0; plane < 3; plane++) {
    set_unpack[plane] = allocate_descriptor_set(descriptor_pool, layout_3_buffers);
    bind_storage_buffers(set_unpack[plane], (VkBuffer[]){ data_buffer, offset_buffer[plane], coeff_buffer[plane] }, 3);
    set_dequant[plane] = allocate_descriptor_set(descriptor_pool, layout_2_buffers);
    bind_storage_buffers(set_dequant[plane], (VkBuffer[]){ coeff_buffer[plane], step_buffer[plane] }, 2);
    set_add[plane] = allocate_descriptor_set(descriptor_pool, layout_2_buffers);
    bind_storage_buffers(set_add[plane], (VkBuffer[]){ coeff_buffer[plane], previous_buffer[plane] }, 2);
    set_mc_play[plane] = allocate_descriptor_set(descriptor_pool, layout_3_buffers);
    bind_storage_buffers(set_mc_play[plane], (VkBuffer[]){ previous_buffer[plane], mv_buffer, scratch_buffer }, 3);
    set_motion_add_play[plane] = allocate_descriptor_set(descriptor_pool, layout_3_buffers);
    bind_storage_buffers(set_motion_add_play[plane], (VkBuffer[]){ coeff_buffer[plane], scratch_buffer, previous_buffer[plane] }, 3);
    set_coeff_to_scratch[plane] = allocate_descriptor_set(descriptor_pool, layout_2_buffers);
    bind_storage_buffers(set_coeff_to_scratch[plane], (VkBuffer[]){ coeff_buffer[plane], scratch_buffer }, 2);
    set_scratch_to_coeff[plane] = allocate_descriptor_set(descriptor_pool, layout_2_buffers);
    bind_storage_buffers(set_scratch_to_coeff[plane], (VkBuffer[]){ scratch_buffer, coeff_buffer[plane] }, 2);
    set_row[plane] = allocate_descriptor_set(descriptor_pool, layout_1_buffer);
    bind_storage_buffers(set_row[plane], (VkBuffer[]){ coeff_buffer[plane] }, 1);
  }
  set_row_scratch = allocate_descriptor_set(descriptor_pool, layout_1_buffer);
  bind_storage_buffers(set_row_scratch, (VkBuffer[]){ scratch_buffer }, 1);

  // Stage B1b: GPU bidi decode — DPB pool + bidi_blend + per-frame-rebound sets (mirror of the
  // encoder). bidi_blend reuses pipeline_layout_unpack (3 buffers + 12-byte push); the reconstruct's
  // motion_add reuses pipeline_motion_add. Allocated only for --gpu-decode on a B-stream.
  int use_gpu_bdecode = has_bframes && !cpu_decode;
  int has_per_block_mode = use_gpu_bdecode && (header.reserved2[3] != 0);   // Phase 2: B MV blobs carry a per-block L0/L1/BI mode array
  VkPipeline pipeline_bidi_blend = use_gpu_bdecode ? create_compute_pipeline("shaders/bidi_blend.spv", pipeline_layout_unpack) : 0;
  VkPipelineLayout pipeline_layout_blend_mode = has_per_block_mode ? create_pipeline_layout(layout_3_buffers, 20) : 0;   // {prediction, mc1, modes}, push {5 ints}
  VkPipeline pipeline_blend_mode = has_per_block_mode ? create_compute_pipeline_motion("shaders/blend_mode.spv", pipeline_layout_blend_mode, g_motion_block) : 0;
  // Decode-Lead: hold a ~2*period lead of pre-decoded frames so the bursty coding-order decode becomes a
  // steady ~1 decode per displayed frame (smooth playback under Vsync). The pool holds the lead + the live
  // references, so size it 3*period + spare.
  int gdecode_period = header.reserved2[2] + 1;
  // Phase 3 step-map cache: deeper B-frames use a coarser (temporal-id-cascaded) quant. Rather than rebuild
  // the full per-pixel step map every frame (O(width*height) CPU — ~50 ms/frame at 4K, the decode bottleneck),
  // cache one GPU step buffer set per distinct quality (only a few exist) and just rebind the dequant set.
  #define STEP_CACHE_MAX 16
  VkBuffer step_cache_buf[STEP_CACHE_MAX][3] = { { 0, 0, 0 } };
  VkDeviceMemory step_cache_mem[STEP_CACHE_MAX][3] = { { 0, 0, 0 } };
  void *step_cache_map[STEP_CACHE_MAX][3] = { { 0, 0, 0 } };
  int step_cache_q[STEP_CACHE_MAX];
  int step_cache_n = 0, gdec_step_idx = -1;   // built-quality count + the currently-bound cache index
  int gdecode_lead = use_gpu_bdecode ? (2 * gdecode_period) : 0;
  int gdpb_slots = use_gpu_bdecode ? ((3 * gdecode_period) + 6) : 0;
  if (gdpb_slots > 64) {
    gdpb_slots = 64;
  }
  VkBuffer gdpb_buffer[64][3];
  VkDeviceMemory gdpb_memory[64][3];
  VkDescriptorSet set_gblend[3], set_gadd[3];
  VkFence bdecode_fence = 0;
  // Stage B2 decode: L1 motion vectors + the two motion-compensated predictions (gmc0/gmc1),
  // blended into scratch_buffer (consumed by the reconstruct's motion_add). mv_buffer/mv_map = L0.
  VkBuffer mv1_buffer = 0, mode_buffer = 0, gmc_buffer[2][3] = { { 0, 0, 0 }, { 0, 0, 0 } };
  VkDeviceMemory mv1_memory = 0, mode_memory = 0, gmc_memory[2][3] = { { 0, 0, 0 }, { 0, 0, 0 } };
  void *mv1_map = 0, *mode_map = 0;
  // MVs are decoded into these CPU-local (cached) scratch arrays and bulk-copied to the GPU-mapped buffers:
  // decode_motion_vectors does random neighbour reads (median predictor), and the GPU-mapped buffers are
  // write-combined VRAM on a discrete GPU (uncached reads ~PCIe latency each -> ~40 ms/frame at 4K). The
  // cached scratch makes those reads hit L1/L2; one sequential memcpy to VRAM then uploads the result.
  int *mv0_scratch = checked_malloc((((size_t)motion_blocks_x * motion_blocks_y) * 2) * 4);   // both the B path AND the I/P P-frame MV decode use this cached scratch
  int *mv1_scratch = checked_malloc((((size_t)motion_blocks_x * motion_blocks_y) * 2) * 4);
  VkDescriptorSet set_gmc0[3], set_gmc1[3], set_blend_mode[3];
  if (use_gpu_bdecode) {
    for (int slot = 0; slot < gdpb_slots; slot++) {
      for (int plane = 0; plane < 3; plane++) {
        create_buffer(plane_bytes, DEVICE_LOCAL, &gdpb_buffer[slot][plane], &gdpb_memory[slot][plane]);
      }
    }
    create_buffer((((size_t)motion_blocks_x * motion_blocks_y) * 2) * 4, HOST_VISIBLE_COHERENT, &mv1_buffer, &mv1_memory);
    VK_CHECK(vkMapMemory(device, mv1_memory, 0, VK_WHOLE_SIZE, 0, &mv1_map));
    if (has_per_block_mode) {   // Phase 2: per-block mode array, decoded from the MV blob into this host-visible buffer
      create_buffer(((size_t)motion_blocks_x * motion_blocks_y) * 4, HOST_VISIBLE_COHERENT, &mode_buffer, &mode_memory);
      VK_CHECK(vkMapMemory(device, mode_memory, 0, VK_WHOLE_SIZE, 0, &mode_map));
    }
    for (int plane = 0; plane < 3; plane++) {
      create_buffer(plane_bytes, DEVICE_LOCAL, &gmc_buffer[0][plane], &gmc_memory[0][plane]);
      create_buffer(plane_bytes, DEVICE_LOCAL, &gmc_buffer[1][plane], &gmc_memory[1][plane]);
      set_gblend[plane] = allocate_descriptor_set(descriptor_pool, layout_3_buffers);
      set_gadd[plane] = allocate_descriptor_set(descriptor_pool, layout_3_buffers);
      set_gmc0[plane] = allocate_descriptor_set(descriptor_pool, layout_3_buffers);
      set_gmc1[plane] = allocate_descriptor_set(descriptor_pool, layout_3_buffers);
      set_blend_mode[plane] = has_per_block_mode ? allocate_descriptor_set(descriptor_pool, layout_3_buffers) : 0;
    }
    VkFenceCreateInfo bf = { VK_STRUCTURE_TYPE_FENCE_CREATE_INFO };
    vkCreateFence(device, &bf, 0, &bdecode_fence);
  }
  set_colour = allocate_descriptor_set(descriptor_pool, layout_colour);
  {
    VkDescriptorBufferInfo colour_buffers[3];
    VkDescriptorImageInfo colour_image = { 0, decode_view, VK_IMAGE_LAYOUT_GENERAL };
    VkWriteDescriptorSet writes[4] = { 0 };
    for (int i = 0; i < 3; i++) {
      colour_buffers[i] = (VkDescriptorBufferInfo){ coeff_buffer[i], 0, VK_WHOLE_SIZE };
      writes[i].sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
      writes[i].dstSet = set_colour;
      writes[i].dstBinding = i;
      writes[i].descriptorCount = 1;
      writes[i].descriptorType = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
      writes[i].pBufferInfo = &colour_buffers[i];
    }
    writes[3].sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
    writes[3].dstSet = set_colour;
    writes[3].dstBinding = 3;
    writes[3].descriptorCount = 1;
    writes[3].descriptorType = VK_DESCRIPTOR_TYPE_STORAGE_IMAGE;
    writes[3].pImageInfo = &colour_image;
    vkUpdateDescriptorSets(device, 4, writes, 0, 0);
  }

  // 3D-DWT: a GOP of subband frames is spatially inverse-transformed into per-plane slots,
  // the temporal-inverse shader reconstructs the display frames along the frame axis, then each frame is
  // colour-converted and presented in order. To hide the per-GOP decode cost, two GOP buffers ping-pong:
  // one is presented while the NEXT GOP is decoded ahead of time on a separate (prefetch) command buffer
  // + fence, into its own prefetch_coeff (the present only touches coeff_buffer, so data/offset/step/
  // scratch are free for the prefetch to reuse). One subband frame is prefetched per displayed frame.
  VkBuffer gop_buffer[2][3] = { { 0, 0, 0 }, { 0, 0, 0 } };
  VkDeviceMemory gop_memory[2][3] = { { 0, 0, 0 }, { 0, 0, 0 } };
  VkBuffer prefetch_coeff[3] = { 0, 0, 0 };
  VkDeviceMemory prefetch_coeff_memory[3] = { 0, 0, 0 };
  VkPipelineLayout pipeline_layout_temporal = 0;
  VkPipeline pipeline_temporal_int = 0, pipeline_temporal_float = 0;
  VkDescriptorSet set_temporal[2][3] = { { 0, 0, 0 }, { 0, 0, 0 } };
  VkDescriptorSet set_unpack_pf[3], set_dequant_pf[3], set_coeff_to_scratch_pf[3], set_scratch_to_coeff_pf[3], set_row_pf[3];
  // MCTF (prediction_method==3): the MC-Haar temporal inverse needs a per-plane OBMC prediction scratch + a
  // deinterleave-reorder GOP, plus each high-pass frame's decoded luma MV field (per ping-pong buffer).
  VkBuffer mctf_pred[3] = { 0, 0, 0 }, mctf_scratch[3] = { 0, 0, 0 };
  VkDeviceMemory mctf_pred_memory[3] = { 0, 0, 0 }, mctf_scratch_memory[3] = { 0, 0, 0 };
  VkDescriptorSet set_mctf_mc[3] = { 0, 0, 0 }, set_mctf_add[3] = { 0, 0, 0 };
  int *mctf_mv[2] = { NULL, NULL };
  int gop_capacity = mode_3ddwt ? ((header.gop < 2) ? 16 : ((header.gop > MAX_GOP) ? MAX_GOP : header.gop)) : 0;
  if (mode_3ddwt && g_mctf) {
    for (int plane = 0; plane < 3; plane++) {
      int plane_pixels = plane_width(plane, width) * plane_height(plane, height);
      create_buffer((size_t)plane_pixels * 4, DEVICE_LOCAL, &mctf_pred[plane], &mctf_pred_memory[plane]);
      create_buffer((size_t)gop_capacity * plane_pixels * 4, DEVICE_LOCAL, &mctf_scratch[plane], &mctf_scratch_memory[plane]);
      set_mctf_mc[plane] = allocate_descriptor_set(descriptor_pool, layout_3_buffers);
      set_mctf_add[plane] = allocate_descriptor_set(descriptor_pool, layout_2_buffers);
    }
    for (int buffer = 0; buffer < 2; buffer++) {
      mctf_mv[buffer] = checked_malloc(((size_t)gop_capacity * motion_blocks_x * motion_blocks_y * 2) * sizeof(int));
    }
  }
  if (mode_3ddwt) {
    for (int buffer = 0; buffer < 2; buffer++) {
      for (int plane = 0; plane < 3; plane++) {   // chroma slots are smaller when subsampled (4:2:0 / 4:2:2)
        int plane_pixels = plane_width(plane, width) * plane_height(plane, height);
        create_buffer((size_t)gop_capacity * plane_pixels * 4, DEVICE_LOCAL, &gop_buffer[buffer][plane], &gop_memory[buffer][plane]);
      }
    }
    for (int plane = 0; plane < 3; plane++) {
      create_buffer(plane_bytes, DEVICE_LOCAL, &prefetch_coeff[plane], &prefetch_coeff_memory[plane]);
    }
    pipeline_layout_temporal = create_pipeline_layout(layout_1_buffer, 20);   // { pixel_count, num_frames, levels, wavelet, inverse }
    pipeline_temporal_int = create_compute_pipeline("shaders/tdwt_int.spv", pipeline_layout_temporal);
    pipeline_temporal_float = create_compute_pipeline("shaders/tdwt_float.spv", pipeline_layout_temporal);
    for (int buffer = 0; buffer < 2; buffer++) {
      for (int plane = 0; plane < 3; plane++) {
        set_temporal[buffer][plane] = allocate_descriptor_set(descriptor_pool, layout_1_buffer);
        bind_storage_buffers(set_temporal[buffer][plane], (VkBuffer[]){ gop_buffer[buffer][plane] }, 1);
      }
    }
    // Prefetch decode sets: identical to the present's decode sets but bound to prefetch_coeff (data /
    // offset / step / scratch are shared — the present never touches them in 3D-DWT mode).
    for (int plane = 0; plane < 3; plane++) {
      set_unpack_pf[plane] = allocate_descriptor_set(descriptor_pool, layout_3_buffers);
      bind_storage_buffers(set_unpack_pf[plane], (VkBuffer[]){ data_buffer, offset_buffer[plane], prefetch_coeff[plane] }, 3);
      set_dequant_pf[plane] = allocate_descriptor_set(descriptor_pool, layout_2_buffers);
      bind_storage_buffers(set_dequant_pf[plane], (VkBuffer[]){ prefetch_coeff[plane], step_buffer[plane] }, 2);
      set_coeff_to_scratch_pf[plane] = allocate_descriptor_set(descriptor_pool, layout_2_buffers);
      bind_storage_buffers(set_coeff_to_scratch_pf[plane], (VkBuffer[]){ prefetch_coeff[plane], scratch_buffer }, 2);
      set_scratch_to_coeff_pf[plane] = allocate_descriptor_set(descriptor_pool, layout_2_buffers);
      bind_storage_buffers(set_scratch_to_coeff_pf[plane], (VkBuffer[]){ scratch_buffer, prefetch_coeff[plane] }, 2);
      set_row_pf[plane] = allocate_descriptor_set(descriptor_pool, layout_1_buffer);
      bind_storage_buffers(set_row_pf[plane], (VkBuffer[]){ prefetch_coeff[plane] }, 1);
    }
  }

  VkCommandPoolCreateInfo command_pool_info = { VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO };
  command_pool_info.queueFamilyIndex = queue_family_index;
  command_pool_info.flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT;
  VkCommandPool command_pool;
  VK_CHECK(vkCreateCommandPool(device, &command_pool_info, 0, &command_pool));
  VkCommandBufferAllocateInfo command_buffer_info = { VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO };
  command_buffer_info.commandPool = command_pool;
  command_buffer_info.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
  command_buffer_info.commandBufferCount = 1;
  vkAllocateCommandBuffers(device, &command_buffer_info, &command_buffer);
  // 3D-DWT GOP prefetch runs on its own command buffer + fence so it overlaps the present.
  VkCommandBuffer prefetch_command_buffer = 0;
  VkFence prefetch_fence = 0;

  // Acquire semaphores toggle by frame & 1 (consumed same-frame by the submit, gated 1-deep by in_flight_fence).
  // The render-finished semaphore is signalled by the submit and waited by the PRESENT, whose lifetime is tied
  // to the swapchain IMAGE (not the frame) — with no per-frame queue drain, reusing it by frame & 1 races the
  // pending present (VUID-00067). So keep ONE render semaphore PER swapchain image, indexed by the acquired
  // image index: an image is only re-acquired after its present completes, so its render semaphore is then free.
  VkSemaphoreCreateInfo semaphore_info = { VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO };
  VkSemaphore acquire_semaphore[2], render_semaphore[8];
  for (int k = 0; k < 2; k++) {
    vkCreateSemaphore(device, &semaphore_info, 0, &acquire_semaphore[k]);
  }
  for (uint32_t k = 0; k < swapchain_image_count; k++) {   // swapchain_image_count = minImageCount + 1 (typically 3-4, always <= 8)
    vkCreateSemaphore(device, &semaphore_info, 0, &render_semaphore[k]);
  }
  VkFenceCreateInfo fence_info = { VK_STRUCTURE_TYPE_FENCE_CREATE_INFO };
  fence_info.flags = VK_FENCE_CREATE_SIGNALED_BIT;
  VkFence in_flight_fence;
  vkCreateFence(device, &fence_info, 0, &in_flight_fence);
  if (mode_3ddwt) {
    vkAllocateCommandBuffers(device, &command_buffer_info, &prefetch_command_buffer);
    vkCreateFence(device, &fence_info, 0, &prefetch_fence);   // starts signaled (no prefetch in flight)
  }

  // ---- audio: decode the Vorbis blob into PCM and queue it ----
  SDL_AudioDeviceID audio_device = 0;
  short *audio_pcm = NULL;
  uint32_t total_audio_bytes = 0;
  int audio_channels = 2, audio_rate = 48000;
  if (header.audio_size) {
    uint8_t *blob = checked_malloc(header.audio_size);
    fseeko(file, (off_t)header.audio_offset, SEEK_SET);
    if (fread(blob, 1, header.audio_size, file) == header.audio_size) {
      // Dispatch on the container's audio sub-FOURCC; unknown / all-zero (old files) -> OGG/Vorbis.
      int sample_count = 0;
      const char *codec_name = "Vorbis";
      if ((((header.audio_codec[0] == 'Q') && (header.audio_codec[1] == 'O')) && (header.audio_codec[2] == 'A')) && (header.audio_codec[3] == 'L')) {
        audio_pcm = qoal_decode(blob, header.audio_size, &audio_channels, &audio_rate, &sample_count);
        codec_name = "QOA-LE";
      } else if ((((header.audio_codec[0] == 'F') && (header.audio_codec[1] == 'W')) && (header.audio_codec[2] == 'A')) && (header.audio_codec[3] == 'C')) {
        audio_pcm = fwa_decode(blob, header.audio_size, &audio_channels, &audio_rate, &sample_count);
        codec_name = "FWAC";
      } else {
        if ((((header.audio_codec[0] == 'R') && (header.audio_codec[1] == 'P')) && (header.audio_codec[2] == 'C')) && (header.audio_codec[3] == 'M')) {
          audio_pcm = rpcm_decode_s16(blob, header.audio_size, &audio_channels, &audio_rate, &sample_count);
          codec_name = "RPCM";
        } else {
          sample_count = stb_vorbis_decode_memory(blob, (int)header.audio_size, &audio_channels, &audio_rate, &audio_pcm);
          codec_name = "Vorbis";
        }
      }
      if (sample_count > 0) {
        SDL_AudioSpec want = { 0 }, have;
        want.freq = audio_rate;
        want.format = AUDIO_S16SYS;
        want.channels = (Uint8)audio_channels;
        want.samples = 2048;
        audio_device = SDL_OpenAudioDevice(0, 0, &want, &have, 0);
        if (audio_device) {
          total_audio_bytes = ((uint32_t)sample_count * audio_channels) * 2;
          SDL_QueueAudio(audio_device, audio_pcm, total_audio_bytes);
          printf("audio: %s %d Hz x%d, %.1f s\n", codec_name, audio_rate, audio_channels, (double)sample_count / audio_rate);
        }
      }
    }
    free(blob);
  }

  // H.264 HW-decode path — hand the shared device/swapchain/audio + embedded Annex-B stream to
  // the ported H.264 decoder and return. The wavelet setup below is skipped (paths separate after init).
  if (use_h264) {
    uint8_t *h264_blob = checked_malloc(header.h264_size);
    fseeko(file, (off_t)header.h264_offset, SEEK_SET);
    if (fread(h264_blob, 1, header.h264_size, file) != header.h264_size) {
      die("h264 stream read");
    }
    FwvH264Context h264 = { 0 };
    h264.instance = instance;
    h264.physical_device = physical_device;
    h264.device = device;
    h264.graphics_queue = queue;
    h264.graphics_family = (int)queue_family_index;
    h264.video_queue = video_queue;
    h264.video_family = video_queue_family;
    h264.swapchain = swapchain;
    h264.swapchain_images = swapchain_images;
    h264.swapchain_image_count = swapchain_image_count;
    h264.extent = extent;
    h264.window = window;
    h264.blob = h264_blob;
    h264.blob_size = header.h264_size;
    h264.verify = verify;
    h264.decode_to = decode_to_path;
    h264.fps = fps;
    h264.fps_num = header.fps_num;
    h264.fps_den = header.fps_den;
    h264.audio_pcm = audio_pcm;
    h264.audio_frames = (audio_pcm && (audio_channels > 0)) ? ((uint64_t)total_audio_bytes / (uint32_t)(audio_channels * 2)) : 0;
    h264.audio_device = audio_device;
    h264.total_audio_bytes = total_audio_bytes;
    h264.audio_channels = audio_channels;
    h264.audio_rate = audio_rate;
    return run_h264_player(&h264);
  }

  // --decode-to (wavelet path): open the OpenDML AVI export. The decode loop below writes each frame.
  AviWriter *avi = NULL;
  if (decode_to_path) {
    uint64_t audio_frames = (audio_pcm && (audio_channels > 0)) ? ((uint64_t)total_audio_bytes / (uint32_t)(audio_channels * 2)) : 0;
    avi = avi_open(decode_to_path, width, height, header.fps_num, header.fps_den,
                   audio_pcm, audio_frames, audio_channels, audio_rate);
    if (!avi) {
      die("cannot open --decode-to output");
    }
    printf("decode-to: writing %s (OpenDML AVI, RGB32 + PCM16)\n", decode_to_path);
  }

  // ---- headless verify setup (--verify) ----
  VkBuffer readback_buffer = 0;
  VkDeviceMemory readback_memory = 0;
  void *readback_map = 0;
  uint8_t *cpu_rgb = 0;
  uint8_t *cpu_sdr = 0;                      // HDR: the CPU decode tonemapped, to match the GPU color_hdr present
  int32_t *cpu_previous[3] = { 0, 0, 0 };   // CPU P-frame coefficient reference (mirrors the GPU's)
  double verify_sum = 0;
  int verify_low = 0, verify_count = 0;
  if (verify || decode_to_path) {   // both need the per-frame readback of the decoded image
    create_buffer((size_t)pixel_count * (use_scrgb_output ? 8 : 4), HOST_VISIBLE_COHERENT, &readback_buffer, &readback_memory);   // rgba16f vs rgba8
    VK_CHECK(vkMapMemory(device, readback_memory, 0, VK_WHOLE_SIZE, 0, &readback_map));
  }
  if (verify) {
    cpu_rgb = checked_malloc(frame_bytes);   // HDR: int16 samples
    if (is_hdr) {
      cpu_sdr = checked_malloc((size_t)pixel_count * 3);
    }
    for (int plane = 0; plane < 3; plane++) {
      cpu_previous[plane] = checked_malloc((size_t)pixel_count * 4);
    }
    printf("VERIFY mode: GPU-decode(file) vs CPU %s(file), per frame\n", mode_3ddwt ? "decode_gop_3ddwt" : "decode_frame_coefdiff");
  }

  // ---- playback loop ----
  size_t frame_buffer_capacity = ((size_t)data_capacity + (((size_t)3 * block_count) * 4)) + 16;
  uint8_t *frame_buffer = checked_malloc(frame_buffer_capacity);   // sized for the max UNCOMPRESSED frame; read_frame won't grow it
  double start_time = 0;   // started just before the loop (after the GOP 0 decode) so frame 0 is on time
  int quit = 0;
  int need_recreate = 0;   // set on a resize / VK_ERROR_OUT_OF_DATE_KHR; the swapchain is rebuilt next frame
  int pixel_workgroups = (pixel_count + 255) / 256;   // frame-level: the colour pass writes full-res RGB
  // coefdiff predicts at Q0 only; colordiff (prediction_method 1) at any quality.
  int predictive = (header.gop > 1) && ((header.prediction_method == 1) ? 1 : lossless);
  int current_quality = quality;                    // per-GOP variable Q: rebuild the quant map when it changes
  // ---- 3D-DWT GOP prefetch state ----
  uint8_t **cpu_gop_rgb = NULL;   // verify: CPU decode of the current GOP
  uint32_t cur_gop_start = 0;     // the frame index of the GOP currently being presented (its type-0 frame)
  int cur_buf = 0, cur_gop_count = 0;
  int pf_buf = 1, pf_gop_count = 0, pf_step = 0, pf_done = 1;   // prefetch: which buffer, size, next subband, finished
  uint32_t pf_gop_start = 0;
  Decode3D d3d = { 0 };
  if (mode_3ddwt) {
    d3d.queue = queue;
    d3d.cmd = prefetch_command_buffer;
    d3d.fence = prefetch_fence;
    d3d.unpack = pipeline_unpack;
    d3d.dequant = pipeline_dequant;
    d3d.transpose = pipeline_transpose;
    d3d.inverse_row = pipeline_inverse_row;
    d3d.temporal_int = pipeline_temporal_int;
    d3d.temporal_float = pipeline_temporal_float;
    d3d.layout_unpack = pipeline_layout_unpack;
    d3d.layout_dequant = pipeline_layout_dequant;
    d3d.layout_transpose = pipeline_layout_transpose;
    d3d.layout_row = pipeline_layout_row;
    d3d.layout_temporal = pipeline_layout_temporal;
    d3d.row_scratch = set_row_scratch;
    d3d.width = width;
    d3d.height = height;
    d3d.levels = levels;
    d3d.pixel_count = pixel_count;
    d3d.temporal_levels = g_temporal_levels;
    d3d.temporal_wavelet = g_temporal_wavelet;
    d3d.lossless = lossless;
    d3d.plane_bytes = plane_bytes;
    // MCTF MC-Haar inverse fields (used only when prediction_method==3): mc/coeff_add warp + add, round97 for the
    // lossy spatial result, the host-visible mv_buffer for per-pair MV upload, and the pred/scratch GOP buffers.
    d3d.mctf = g_mctf;
    d3d.motion_blocks_x = motion_blocks_x;
    d3d.motion_blocks_y = motion_blocks_y;
    d3d.motion_block = g_motion_block;
    d3d.mc = pipeline_mc;
    d3d.coeff_add = pipeline_coeff_add;
    d3d.round = pipeline_round;
    d3d.layout_mc = pipeline_layout_unpack;            // mc.comp uses the 3-buffer unpack layout (push 12)
    d3d.layout_coeff_add = pipeline_layout_coeff_add;
    d3d.layout_round = pipeline_layout_round;
    d3d.mv_buffer = mv_buffer;
    d3d.mv_map = mv_map;
    for (int plane = 0; plane < 3; plane++) {
      d3d.unpack_pf[plane] = set_unpack_pf[plane];
      d3d.dequant_pf[plane] = set_dequant_pf[plane];
      d3d.coeff_to_scratch_pf[plane] = set_coeff_to_scratch_pf[plane];
      d3d.scratch_to_coeff_pf[plane] = set_scratch_to_coeff_pf[plane];
      d3d.row_pf[plane] = set_row_pf[plane];
      d3d.prefetch_coeff[plane] = prefetch_coeff[plane];
      d3d.mctf_pred[plane] = mctf_pred[plane];
      d3d.mctf_scratch[plane] = mctf_scratch[plane];
      d3d.mctf_mc[plane] = set_mctf_mc[plane];
      d3d.mctf_add[plane] = set_mctf_add[plane];
      for (int buffer = 0; buffer < 2; buffer++) {
        d3d.temporal[buffer][plane] = set_temporal[buffer][plane];
        d3d.gop_buffer[buffer][plane] = gop_buffer[buffer][plane];
      }
    }
    if (verify) {
      cpu_gop_rgb = checked_malloc((size_t)gop_capacity * sizeof(uint8_t *));
      for (int g = 0; g < gop_capacity; g++) {
        cpu_gop_rgb[g] = checked_malloc(frame_bytes);
      }
    }
    // GOP 0: decode synchronously into gop_buffer[0] before presenting its first frame.
    cur_gop_count = gop_count_from(index, 0, header.frame_count);
    for (int g = 0; g < cur_gop_count; g++) {
      decode3d_wait(&d3d);
      upload_subband(file, index, (uint32_t)g, &frame_buffer, &frame_buffer_capacity, block_count_plane, offset_map, data_map, step_map, step,
                     width, height, levels, quality, lossless, g, cur_gop_count, g_temporal_levels,
                     g_mctf ? &mctf_mv[0][(size_t)g * motion_blocks_x * motion_blocks_y * 2] : NULL);
      decode3d_spatial(&d3d, 0, g);
    }
    decode3d_wait(&d3d);
    decode3d_finish_gop(&d3d, 0, cur_gop_count, mctf_mv);
    vkWaitForFences(device, 1, &prefetch_fence, VK_TRUE, UINT64_MAX);   // GOP 0 fully decoded
    if (verify) {
      cpu_decode_gop(file, index, 0, cur_gop_count, width, height, levels, quality, cpu_gop_rgb);
    }
    // Begin prefetching GOP 1 (one subband per displayed frame, below).
    pf_gop_start = (uint32_t)cur_gop_count;
    if (pf_gop_start < header.frame_count) {
      pf_gop_count = gop_count_from(index, pf_gop_start, header.frame_count);
      pf_step = 0;
      pf_done = 0;
    }
  }

  // hierarchical B-stream playback state — a CPU coding-order decoder (decode_frame_bidi)
  // with a POC reorder, plus a host-visible RGBA8 staging buffer to upload each reconstructed frame into
  // decode_image (the existing letterbox blit / readback then runs unchanged for present / verify / decode-to).
  BStream bstream = { 0 };
  VkBuffer bf_upload_buffer = 0;
  VkDeviceMemory bf_upload_memory = 0;
  void *bf_upload_map = 0;
  // Stage B1b GPU-decode state: a coding-order GPU decode-ahead into the DPB pool, keyed like
  // the CPU BStream (last_use eviction) but the reconstructed YCoCg lives in GPU slots; poc_to_slot maps
  // each display POC to its slot for the colour pass. gframe_buffer is the per-frame payload read scratch.
  int *gdpb_last_use = NULL, *gdpb_poc_to_slot = NULL, *gdpb_coding_to_slot = NULL, gdpb_slot_coding[40], gcursor = 0;
  uint8_t *gframe_buffer = NULL;
  size_t gframe_cap = 0;
  if (has_bframes) {
    if (use_gpu_bdecode) {
      gdpb_last_use = checked_malloc((size_t)header.frame_count * sizeof(int));
      gdpb_poc_to_slot = checked_malloc((size_t)header.frame_count * sizeof(int));
      gdpb_coding_to_slot = checked_malloc((size_t)header.frame_count * sizeof(int));
      for (uint32_t c = 0; c < header.frame_count; c++) {
        gdpb_last_use[c] = (int)c;
        gdpb_poc_to_slot[c] = -1;
        gdpb_coding_to_slot[c] = -1;
      }
      for (uint32_t c = 0; c < header.frame_count; c++) {
        if ((index[c].ref0 >= 0) && ((int)c > gdpb_last_use[index[c].ref0])) {
          gdpb_last_use[index[c].ref0] = (int)c;
        }
        if ((index[c].ref1 >= 0) && ((int)c > gdpb_last_use[index[c].ref1])) {
          gdpb_last_use[index[c].ref1] = (int)c;
        }
      }
      for (int slot = 0; slot < gdpb_slots; slot++) {
        gdpb_slot_coding[slot] = -1;
      }
      printf("B-stream: %d frames, %d B/anchor, GPU bidi decode + POC reorder (%d DPB slots)\n",
             header.frame_count, header.reserved2[2], gdpb_slots);
    } else {
      bstream_init(&bstream, file, index, (int)header.frame_count, width, height, levels, frame_bytes);
      create_buffer((size_t)pixel_count * 4, HOST_VISIBLE_COHERENT, &bf_upload_buffer, &bf_upload_memory);   // rgba8
      VK_CHECK(vkMapMemory(device, bf_upload_memory, 0, VK_WHOLE_SIZE, 0, &bf_upload_map));
      printf("B-stream: %d frames, %d B/anchor, coding-order CPU decode + POC reorder\n",
             header.frame_count, header.reserved2[2]);
    }
  }

  // Start the master clock — and the audio — only now, after GOP 0 has been decoded, so the audio does
  // not run ahead during the (one-off) GOP 0 decode and the video stays in sync from frame 0. For the GPU
  // B-stream path the clock/audio start is DEFERRED until the decode-lead is pre-filled (see the loop), so
  // that one-off startup decode does not run the clock ahead either.
  int bdecode_clock_started = 0;
  int fwv_time = (getenv("FWV_TIME") != NULL);   // FWV_TIME=1 -> print B-decode CPU-prep vs GPU-busy breakdown at exit
  double bdec_cpu_ms = 0.0, bdec_gpu_ms = 0.0;
  double bdec_parse_ms = 0.0, bdec_rebind_ms = 0.0, bdec_record_ms = 0.0;   // CPU-prep sub-breakdown
  double bdec_pdata_ms = 0.0;   // within parse: fread + header + data-memcpy (the rest of parse is MV/mode decode)
  long bdec_count = 0;
  // Present-loop per-frame breakdown (both paths): fence-wait (GPU busy on the previous frame) + pace-wait
  // (idle, waiting for the audio/wall clock) + total, plus the single slowest frame and its type.
  double loop_total_ms = 0.0, loop_fence_ms = 0.0, loop_pace_ms = 0.0, loop_drain_ms = 0.0, loop_acquire_ms = 0.0, loop_max_ms = 0.0;
  long loop_count = 0; int loop_max_frame = -1, loop_max_type = -1;
  start_time = now_milliseconds();
  if (audio_device && !use_gpu_bdecode) {
    SDL_PauseAudioDevice(audio_device, 0);
  }

  for (uint32_t frame_index = 0; (frame_index < header.frame_count) && !quit; frame_index++) {
    double loop_t0 = fwv_time ? now_milliseconds() : 0.0;   // present-loop per-frame timer (both paths)
    SDL_Event event;
    while (SDL_PollEvent(&event)) {
      if ((event.type == SDL_QUIT) || ((event.type == SDL_KEYDOWN) && (event.key.keysym.sym == SDLK_ESCAPE))) {
        quit = 1;
      }
    }

    // Wait for the previous frame's GPU decode to finish *before* overwriting the shared upload
    // buffers (data_buffer / offset_buffer) — otherwise the previous decode reads half-new data.
    double loop_tf = fwv_time ? now_milliseconds() : 0.0;
    vkWaitForFences(device, 1, &in_flight_fence, VK_TRUE, UINT64_MAX);
    if (fwv_time) {
      double fence = now_milliseconds() - loop_tf;   // = the previous frame's GPU decode+present time
      loop_fence_ms += fence;
      if (fence > loop_max_ms) {
        loop_max_ms = fence;
        loop_max_frame = (int)((frame_index > 0) ? (frame_index - 1) : 0);
        loop_max_type = (int)index[loop_max_frame].type;
      }
    }

    // 3D-DWT: at a GOP boundary, swap to the prefetched GOP (finishing it synchronously if it fell
    // behind), then begin prefetching the GOP after it. The per-frame present below colour-converts the
    // current GOP's slot; one subband of the next GOP is prefetched per displayed frame (after present).
    if (mode_3ddwt && (frame_index >= cur_gop_start + (uint32_t)cur_gop_count)) {
      while (!pf_done) {   // the prefetch didn't keep up (rare): finish it now
        decode3d_wait(&d3d);
        upload_subband(file, index, pf_gop_start + (uint32_t)pf_step, &frame_buffer, &frame_buffer_capacity, block_count_plane, offset_map, data_map, step_map, step,
                       width, height, levels, quality, lossless, pf_step, pf_gop_count, g_temporal_levels,
                       g_mctf ? &mctf_mv[pf_buf][(size_t)pf_step * motion_blocks_x * motion_blocks_y * 2] : NULL);
        decode3d_spatial(&d3d, pf_buf, pf_step);
        pf_step++;
        if (pf_step >= pf_gop_count) {
          decode3d_wait(&d3d);
          decode3d_finish_gop(&d3d, pf_buf, pf_gop_count, mctf_mv);
          pf_done = 1;
        }
      }
      vkWaitForFences(device, 1, &prefetch_fence, VK_TRUE, UINT64_MAX);   // the prefetched GOP is fully decoded
      cur_buf = pf_buf;
      cur_gop_start = pf_gop_start;
      cur_gop_count = pf_gop_count;
      if (verify) {
        cpu_decode_gop(file, index, cur_gop_start, cur_gop_count, width, height, levels, quality, cpu_gop_rgb);
      }
      pf_buf = 1 - cur_buf;
      pf_gop_start = cur_gop_start + (uint32_t)cur_gop_count;
      if (pf_gop_start < header.frame_count) {
        pf_gop_count = gop_count_from(index, pf_gop_start, header.frame_count);
        pf_step = 0;
        pf_done = 0;
      } else {
        pf_done = 1;
      }
    }

    // Read this frame's payload from the container and split it into block bytes + offset tables. Skipped
    // for 3D-DWT (the present only colour-converts a GOP slot) and for the B-stream (its CPU coding-order
    // decoder reads payloads itself) — reusing the shared data/offset buffers here would race those paths.
    if (!mode_3ddwt && !has_bframes) {
      read_frame(file, &index[frame_index], &frame_buffer, &frame_buffer_capacity);
      // Prefix-sum the u16 sizes straight into the (host-visible) GPU offset buffers, then upload data.
      uint32_t *parse_offsets[3] = { (uint32_t *)offset_map[0], (uint32_t *)offset_map[1], (uint32_t *)offset_map[2] };
      int parsed_block_count;
      const uint8_t *mv_data;
      uint32_t mv_length;
      const uint8_t *frame_data = parse_frame_header(frame_buffer, block_count_plane, &parsed_block_count, parse_offsets, &mv_data, &mv_length);
      // Decode the motion vectors for mc.comp (colordiff P-frames). Decode into the cached scratch (random
      // neighbour reads in the predictor would otherwise be uncached PCIe reads from the write-combined VRAM
      // mv_buffer — ~23 ms/frame at 4K), then one memcpy to VRAM. (Same fix as the B decode-ahead path.)
      if (((header.prediction_method == 1) && (index[frame_index].type != 0)) && mv_length) {
        if (g_motion_variable) {   // variable: expand the quadtree into the fine 8-grid scratch, then upload
          memset(mv0_scratch, 0, (size_t)((motion_blocks_x * motion_blocks_y) * 2) * 4);
        }
        if (g_mv_codec == 1) {
          mv_blob_decode_range(mv_data, mv_length, 0, NULL, 0, mv0_scratch, 0, NULL, g_motion_variable, motion_blocks_x, motion_blocks_y);
        } else {
          BitReader mv_reader;
          bitreader_init(&mv_reader, mv_data, mv_length);
          if (g_motion_variable) {   // variable: expand the quadtree into the fine 8-grid scratch, then upload
            decode_motion_quadtree(&mv_reader, mv0_scratch, motion_blocks_x, motion_blocks_y);
          } else {
            decode_motion_vectors(&mv_reader, mv0_scratch, motion_blocks_x, motion_blocks_y);
          }
        }
        memcpy(mv_map, mv0_scratch, (size_t)((motion_blocks_x * motion_blocks_y) * 2) * 4);
      }
      uint32_t data_length;
      memcpy(&data_length, frame_data - 4, 4);
      memcpy(data_map, frame_data, data_length);
    }

    // Pace to the audio master clock (or wall-clock if there is no audio).
    double loop_tp = fwv_time ? now_milliseconds() : 0.0;
    if (audio_device) {
      double frame_time = frame_index / ((fps > 0) ? fps : 30.0);
      for (;;) {
        Uint32 queued = SDL_GetQueuedAudioSize(audio_device);
        double audio_seconds = ((double)(total_audio_bytes - queued) / (audio_channels * 2)) / (double)audio_rate;
        if (audio_seconds + 0.001 >= frame_time) {
          break;
        }
        if (queued == 0) {   // audio fully drained: its clock can't advance — stop waiting (else video longer than audio hangs at the end)
          break;
        }
        SDL_Event pace_event;
        while (SDL_PollEvent(&pace_event)) {
          if ((pace_event.type == SDL_QUIT) || ((pace_event.type == SDL_KEYDOWN) && (pace_event.key.keysym.sym == SDLK_ESCAPE))) {
            quit = 1;
          }
        }
        if (quit) {
          break;
        }
        SDL_Delay(1);
      }
    } else {
      double target = start_time + ((frame_index * 1000.0) / ((fps > 0) ? fps : 30.0));
      double delay = target - now_milliseconds();
      if (delay > 1) {
        SDL_Delay((uint32_t)delay);
      }
    }
    if (fwv_time) { loop_pace_ms += (now_milliseconds() - loop_tp); }

    uint32_t swapchain_index = 0;
    if (!verify && !decode_to_path) {   // decode-to is headless too: no swapchain acquire / present
      if (need_recreate) {   // window was resized / surface went out of date: rebuild the swapchain
        extent = recreate_swapchain(device, physical_device, surface, surface_format,
                                    &swapchain, &swapchain_images, &swapchain_image_count);
        if ((extent.width == 0) || (extent.height == 0)) {   // minimized: skip rendering until restored
          SDL_Delay(10);
          continue;
        }
        need_recreate = 0;
      }
      double loop_taq = fwv_time ? now_milliseconds() : 0.0;
      VkResult acquire_result = vkAcquireNextImageKHR(device, swapchain, UINT64_MAX, acquire_semaphore[frame_index & 1], 0, &swapchain_index);
      if (fwv_time) { loop_acquire_ms += (now_milliseconds() - loop_taq); }
      if (acquire_result == VK_ERROR_OUT_OF_DATE_KHR) {
        need_recreate = 1;
        continue;
      }
      if ((acquire_result != VK_SUCCESS) && (acquire_result != VK_SUBOPTIMAL_KHR)) {
        continue;
      }
    }
    // Stage B1b: GPU decode-ahead. Decode coding frames into the DPB pool until the frame at the
    // display POC is reconstructed, mirroring the encoder (unpack -> dequant -> inverse -> bidi_blend ->
    // motion_add into dpb[dst]). Runs on the shared command_buffer (free after the in-flight wait above)
    // with its own fence; the present recording below then re-records command_buffer for the colour pass.
    if (use_gpu_bdecode) {
      // Decode-Lead: decode until the display frame is reconstructed AND the lead is filled (or the pool is
      // full / the stream ends). The lead makes the per-frame decode steady (~1) instead of bursty.
      while (gcursor < (int)header.frame_count) {
        int need = (gdpb_poc_to_slot[frame_index] < 0);
        if (!need && (gcursor >= ((int)frame_index + gdecode_lead))) {
          break;   // display frame ready and the lead is full
        }
        double bdec_t0 = fwv_time ? now_milliseconds() : 0.0;   // CPU-prep timer (MV parse + rebinds + command recording)
        int c = gcursor;
        const FrameEntry *entry = &index[c];
        read_frame(file, entry, &gframe_buffer, &gframe_cap);
        uint32_t *parse_offsets[3] = { (uint32_t *)offset_map[0], (uint32_t *)offset_map[1], (uint32_t *)offset_map[2] };
        int parsed_block_count;
        const uint8_t *mv_data;
        uint32_t mv_length;
        const uint8_t *frame_data = parse_frame_header(gframe_buffer, block_count_plane, &parsed_block_count, parse_offsets, &mv_data, &mv_length);
        uint32_t data_length;
        memcpy(&data_length, frame_data - 4, 4);
        memcpy(data_map, frame_data, data_length);
        double bdec_tp1 = fwv_time ? now_milliseconds() : 0.0;   // split: fread + header + data-memcpy done; MV/mode decode follows
        // Stage B2: decode the L0 MVs (and the L1 MVs for a B-frame) from the single blob into the
        // host-visible mv_buffer / mv1_buffer for mc.comp.
        if ((entry->ref0 >= 0) && (mv_length > 0)) {
          int mv_block_count = motion_blocks_x * motion_blocks_y;
          int has_mode = (has_per_block_mode && (entry->ref1 >= 0));   // Phase 2: per-block mode array precedes the MVs
          int has_mv1 = (entry->ref1 >= 0);
          if (g_motion_variable) {   // quadtree decode fills via leaf-expansion; clear first (partial edges / safety)
            if (has_mode) {
              memset((int *)mode_map, 0, (size_t)mv_block_count * 4);
            }
            memset(mv0_scratch, 0, (size_t)(mv_block_count * 2) * 4);
            if (has_mv1) {
              memset(mv1_scratch, 0, (size_t)(mv_block_count * 2) * 4);
            }
          }
          // Decode into the cached scratch (random neighbour reads in the predictor), then one memcpy to VRAM.
          if (g_mv_codec == 1) {   // range codec: one stream for mode + mv0 [+ mv1]
            mv_blob_decode_range(mv_data, mv_length, has_mode, (int *)mode_map, g_motion_variable,
                                 mv0_scratch, has_mv1, mv1_scratch, g_motion_variable, motion_blocks_x, motion_blocks_y);
          } else {
            BitReader mv_reader;
            bitreader_init(&mv_reader, mv_data, mv_length);
            if (has_mode) {
              int *modes = (int *)mode_map;
              if (g_motion_variable) {   // variable: the mode field is a quadtree over the fine 8-grid
                decode_mode_quadtree(&mv_reader, modes, motion_blocks_x, motion_blocks_y);
              } else {
                for (int blk = 0; blk < mv_block_count; blk++) {
                  modes[blk] = (int)bitreader_get_bits(&mv_reader, 2);
                }
              }
            }
            if (g_motion_variable) {   // variable: the MV blobs are quadtrees over the fine 8-grid
              decode_motion_quadtree(&mv_reader, mv0_scratch, motion_blocks_x, motion_blocks_y);
            } else {
              decode_motion_vectors(&mv_reader, mv0_scratch, motion_blocks_x, motion_blocks_y);
            }
            if (has_mv1) {
              if (g_motion_variable) {
                decode_motion_quadtree(&mv_reader, mv1_scratch, motion_blocks_x, motion_blocks_y);
              } else {
                decode_motion_vectors(&mv_reader, mv1_scratch, motion_blocks_x, motion_blocks_y);
              }
            }
          }
          memcpy(mv_map, mv0_scratch, (size_t)(mv_block_count * 2) * 4);
          if (has_mv1) {
            memcpy(mv1_map, mv1_scratch, (size_t)(mv_block_count * 2) * 4);
          }
        }
        // Evict DPB slots no longer referenced (last_use passed) AND already displayed (poc < this display).
        for (int slot = 0; slot < gdpb_slots; slot++) {
          int sc = gdpb_slot_coding[slot];
          if (((sc >= 0) && (gdpb_last_use[sc] < c)) && ((int)index[sc].poc < (int)frame_index)) {
            gdpb_coding_to_slot[sc] = -1;
            gdpb_poc_to_slot[index[sc].poc] = -1;
            gdpb_slot_coding[slot] = -1;
          }
        }
        int dst = -1;
        for (int slot = 0; slot < gdpb_slots; slot++) {
          if (gdpb_slot_coding[slot] < 0) {
            dst = slot;
            break;
          }
        }
        if (dst < 0) {
          if (!need) {
            break;   // pool full but the display frame is ready -> the lead is just pool-limited, stop
          }
          die("B1b DPB pool exhausted");   // genuinely need this frame and no room -> pool sized too small
        }
        int ref0_slot = (entry->ref0 >= 0) ? gdpb_coding_to_slot[entry->ref0] : -1;
        int ref1_slot = (entry->ref1 >= 0) ? gdpb_coding_to_slot[entry->ref1] : -1;
        int is_pred = (entry->ref0 >= 0);
        int w0 = 0, w1 = 0;   // blend weights from the POC distances (as in the encoder / oracle)
        if ((ref0_slot >= 0) && (ref1_slot >= 0)) {
          int ps = (int)entry->poc, p0 = (int)index[entry->ref0].poc, p1 = (int)index[entry->ref1].poc;
          w0 = (256 * (p1 - ps)) / (p1 - p0);
          w1 = 256 - w0;
        } else if (ref0_slot >= 0) {
          w0 = 256;
        }
        int is_phase2_b = (has_per_block_mode && (ref1_slot >= 0));   // per-block L0/L1/BI mode (vs the unconditional BI blend)
        double bdec_ta = fwv_time ? now_milliseconds() : 0.0;   // end of parse (frame read + header + MV parse + uploads)
        for (int plane = 0; plane < 3; plane++) {
          if (is_pred) {
            bind_storage_buffers(set_gmc0[plane], (VkBuffer[]){ gdpb_buffer[ref0_slot][plane], mv_buffer, gmc_buffer[0][plane] }, 3);
            if (ref1_slot >= 0) {
              bind_storage_buffers(set_gmc1[plane], (VkBuffer[]){ gdpb_buffer[ref1_slot][plane], mv1_buffer, gmc_buffer[1][plane] }, 3);
            }
            if (is_phase2_b) {   // blend_mode applies the per-block mode into gmc0 in place; motion_add then reads gmc0
              bind_storage_buffers(set_blend_mode[plane], (VkBuffer[]){ gmc_buffer[0][plane], gmc_buffer[1][plane], mode_buffer }, 3);
            } else {
              int blend_r1 = (ref1_slot >= 0) ? 1 : 0;   // for a P-anchor blend gmc0 with itself (w1=0 -> = gmc0)
              bind_storage_buffers(set_gblend[plane], (VkBuffer[]){ gmc_buffer[0][plane], gmc_buffer[blend_r1][plane], scratch_buffer }, 3);
            }
          }
          bind_storage_buffers(set_gadd[plane], (VkBuffer[]){ coeff_buffer[plane], is_phase2_b ? gmc_buffer[0][plane] : scratch_buffer, gdpb_buffer[dst][plane] }, 3);
        }
        // Phase 3: pick this frame's dequant step map by its stored (temporal-id-cascaded) quality. Lazily
        // build + cache one GPU step buffer set per distinct quality, then rebind the dequant set only when
        // the quality changes — no per-frame O(width*height) rebuild (the 4K CPU bottleneck).
        if (!lossless) {
          int q = (int)entry->quality, idx = -1;
          for (int k = 0; k < step_cache_n; k++) {
            if (step_cache_q[k] == q) { idx = k; break; }
          }
          if ((idx < 0) && (step_cache_n < STEP_CACHE_MAX)) {
            idx = step_cache_n++;
            step_cache_q[idx] = q;
            for (int plane = 0; plane < 3; plane++) {
              int pw = plane_width(plane, width), ph = plane_height(plane, height);
              create_buffer((size_t)plane_bytes, HOST_VISIBLE_COHERENT, &step_cache_buf[idx][plane], &step_cache_mem[idx][plane]);
              VK_CHECK(vkMapMemory(device, step_cache_mem[idx][plane], 0, VK_WHOLE_SIZE, 0, &step_cache_map[idx][plane]));
              build_quantization_steps(step, pw, ph, levels, q);
              memcpy(step_cache_map[idx][plane], step, (size_t)(pw * ph) * 4);
            }
          }
          if ((idx >= 0) && (idx != gdec_step_idx)) {
            for (int plane = 0; plane < 3; plane++) {
              bind_storage_buffers(set_dequant[plane], (VkBuffer[]){ coeff_buffer[plane], step_cache_buf[idx][plane] }, 2);
            }
            gdec_step_idx = idx;
          }
        }
        double bdec_tb = fwv_time ? now_milliseconds() : 0.0;   // end of descriptor rebinds; command recording follows
        vkResetCommandBuffer(command_buffer, 0);
        VkCommandBufferBeginInfo bdec_begin = { VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO };
        bdec_begin.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
        vkBeginCommandBuffer(command_buffer, &bdec_begin);
        for (int plane = 0; plane < 3; plane++) {
          int plane_w = plane_width(plane, width), plane_h = plane_height(plane, height);
          int scratch_stride = (plane_w > plane_h) ? plane_w : plane_h;
          int plane_pixels = plane_w * plane_h;
          int plane_blocks_x = block_count_x(plane_w), plane_blocks_y = block_count_y(plane_h);
          int plane_block_count = plane_blocks_x * plane_blocks_y;
          int plane_pixel_workgroups = (plane_pixels + 255) / 256;
          int plane_unpack_workgroups = (g_block_size == 128) ? plane_block_count : ((plane_block_count + 63) / 64);   // coop: one workgroup per block
          int32_t unpack_push[4] = { plane_w, plane_h, plane_blocks_x, plane_blocks_y };
          int32_t plane_pixel_count_push = plane_pixels;
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_unpack);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_unpack, 0, 1, &set_unpack[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_unpack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, unpack_push);
          vkCmdDispatch(command_buffer, plane_unpack_workgroups, 1, 1);
          memory_barrier();
          if (!lossless) {
            int32_t dequant_push[2];
            dequant_push[0] = plane_pixel_count_push;
            float chroma_multiplier = (plane == 0) ? 1.0f : g_chroma_quant;
            memcpy(&dequant_push[1], &chroma_multiplier, sizeof(float));
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_dequant);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_dequant, 0, 1, &set_dequant[plane], 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_dequant, VK_SHADER_STAGE_COMPUTE_BIT, 0, 8, dequant_push);
            vkCmdDispatch(command_buffer, plane_pixel_workgroups, 1, 1);
            memory_barrier();
          }
          int level_width[16], level_height[16], level_count = 0, current_width = plane_w, current_height = plane_h;
          for (int level = 0; ((level < levels) && (current_width >= 2)) && (current_height >= 2); level++) {
            level_width[level_count] = current_width;
            level_height[level_count] = current_height;
            level_count++;
            current_width = (current_width + 1) / 2;
            current_height = (current_height + 1) / 2;
          }
          for (int level = level_count - 1; level >= 0; level--) {
            int level_w = level_width[level], level_h = level_height[level];
            int32_t transpose_push_1[4] = { plane_w, level_w, level_h, scratch_stride };
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_transpose);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_transpose, 0, 1, &set_coeff_to_scratch[plane], 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_transpose, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, transpose_push_1);
            vkCmdDispatch(command_buffer, (level_w + 15) / 16, (level_h + 15) / 16, 1);
            memory_barrier();
            int32_t row_push_1[4] = { scratch_stride, level_h, level_w, 1 };
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_inverse_row);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_row, 0, 1, &set_row_scratch, 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_row, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, row_push_1);
            vkCmdDispatch(command_buffer, level_w, 1, 1);
            memory_barrier();
            int32_t transpose_push_2[4] = { scratch_stride, level_h, level_w, plane_w };
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_transpose);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_transpose, 0, 1, &set_scratch_to_coeff[plane], 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_transpose, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, transpose_push_2);
            vkCmdDispatch(command_buffer, (level_h + 15) / 16, (level_w + 15) / 16, 1);
            memory_barrier();
            int32_t row_push_2[4] = { plane_w, level_w, level_h, 1 };
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_inverse_row);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_row, 0, 1, &set_row[plane], 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_row, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, row_push_2);
            vkCmdDispatch(command_buffer, level_h, 1, 1);
            memory_barrier();
          }
          if (!lossless) {
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_round);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_round, 0, 1, &set_row[plane], 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_round, VK_SHADER_STAGE_COMPUTE_BIT, 0, 4, &plane_pixel_count_push);
            vkCmdDispatch(command_buffer, plane_pixel_workgroups, 1, 1);
            memory_barrier();
          }
          // Reconstruct cur = residual + blend(MC(ref0,mv0), MC(ref1,mv1)) into the DPB slot (mirror of the
          // encoder). For a P-anchor only mc0 runs and the blend (w0=256,w1=0) reduces to gmc0.
          if (is_pred) {
            int plane_motion_blocks_x = ((plane_w + g_motion_block) - 1) / g_motion_block;
            int32_t mc_push[3] = { plane_w, plane_h, plane_motion_blocks_x };
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_mc);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_unpack, 0, 1, &set_gmc0[plane], 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_unpack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 12, mc_push);
            vkCmdDispatch(command_buffer, plane_pixel_workgroups, 1, 1);
            memory_barrier();
            if (ref1_slot >= 0) {
              vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_unpack, 0, 1, &set_gmc1[plane], 0, 0);
              vkCmdPushConstants(command_buffer, pipeline_layout_unpack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 12, mc_push);
              vkCmdDispatch(command_buffer, plane_pixel_workgroups, 1, 1);
              memory_barrier();
            }
            if (is_phase2_b) {   // Phase 2: apply the per-block mode (L0/L1/BI) into gmc0 in place
              int32_t mode_blend_push[5] = { plane_w, plane_h, plane_motion_blocks_x, w0, w1 };
              vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_blend_mode);
              vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_blend_mode, 0, 1, &set_blend_mode[plane], 0, 0);
              vkCmdPushConstants(command_buffer, pipeline_layout_blend_mode, VK_SHADER_STAGE_COMPUTE_BIT, 0, 20, mode_blend_push);
              vkCmdDispatch(command_buffer, plane_pixel_workgroups, 1, 1);
              memory_barrier();
            } else {
              int32_t blend_push[3] = { plane_pixels, w0, w1 };
              vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_bidi_blend);
              vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_unpack, 0, 1, &set_gblend[plane], 0, 0);
              vkCmdPushConstants(command_buffer, pipeline_layout_unpack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 12, blend_push);
              vkCmdDispatch(command_buffer, plane_pixel_workgroups, 1, 1);
              memory_barrier();
            }
          }
          int32_t add_push[2] = { plane_pixels, is_pred };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_motion_add);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_unpack, 0, 1, &set_gadd[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_unpack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 8, add_push);
          vkCmdDispatch(command_buffer, plane_pixel_workgroups, 1, 1);
          memory_barrier();
        }
        vkEndCommandBuffer(command_buffer);
        VkSubmitInfo bdec_submit = { VK_STRUCTURE_TYPE_SUBMIT_INFO };
        bdec_submit.commandBufferCount = 1;
        bdec_submit.pCommandBuffers = &command_buffer;
        double bdec_t1 = fwv_time ? now_milliseconds() : 0.0;   // CPU-prep done; the GPU-busy window starts here
        vkQueueSubmit(queue, 1, &bdec_submit, bdecode_fence);
        vkWaitForFences(device, 1, &bdecode_fence, VK_TRUE, UINT64_MAX);
        vkResetFences(device, 1, &bdecode_fence);
        if (fwv_time) {
          bdec_cpu_ms += (bdec_t1 - bdec_t0);
          bdec_gpu_ms += (now_milliseconds() - bdec_t1);
          bdec_parse_ms += (bdec_ta - bdec_t0);
          bdec_pdata_ms += (bdec_tp1 - bdec_t0);
          bdec_rebind_ms += (bdec_tb - bdec_ta);
          bdec_record_ms += (bdec_t1 - bdec_tb);
          bdec_count++;
        }
        gdpb_slot_coding[dst] = c;
        gdpb_coding_to_slot[c] = dst;
        gdpb_poc_to_slot[entry->poc] = dst;
        gcursor++;
      }
      if (!bdecode_clock_started) {   // the one-off decode-lead pre-fill is done -> start the clock/audio now
        start_time = now_milliseconds();
        if (audio_device) {
          SDL_PauseAudioDevice(audio_device, 0);
        }
        bdecode_clock_started = 1;
      }
    }

    vkResetFences(device, 1, &in_flight_fence);
    vkResetCommandBuffer(command_buffer, 0);
    VkCommandBufferBeginInfo begin_info = { VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO };
    begin_info.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
    vkBeginCommandBuffer(command_buffer, &begin_info);

    int is_predicted = (index[frame_index].type != 0);   // 3D-DWT: also marks GOP continuation frames (type 2)
    if (has_bframes && !use_gpu_bdecode) {
      // Stage A: decode (in coding order) up to this display POC on the CPU, expand its
      // reconstructed RGB into the staging buffer and upload it into decode_image; the existing letterbox
      // blit / readback path below then runs unchanged (present / verify / decode-to all consume decode_image).
      is_predicted = 0;
      bstream_decode_until(&bstream, (int)frame_index);
      const uint8_t *src = bstream.rgb[frame_index];
      uint8_t *dst = bf_upload_map;
      for (int i = 0; i < pixel_count; i++) {
        dst[(i * 4) + 0] = src[(i * 3) + 0];
        dst[(i * 4) + 1] = src[(i * 3) + 1];
        dst[(i * 4) + 2] = src[(i * 3) + 2];
        dst[(i * 4) + 3] = 255;
      }
      free(bstream.rgb[frame_index]);   // the display copy is consumed here; the DPB (references) is held separately
      bstream.rgb[frame_index] = NULL;
      image_barrier(decode_image, VK_IMAGE_LAYOUT_UNDEFINED, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 0, VK_ACCESS_TRANSFER_WRITE_BIT,
                    VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT);
      VkBufferImageCopy upload = { 0 };
      upload.imageSubresource = (VkImageSubresourceLayers){ VK_IMAGE_ASPECT_COLOR_BIT, 0, 0, 1 };
      upload.imageExtent = (VkExtent3D){ width, height, 1 };
      vkCmdCopyBufferToImage(command_buffer, bf_upload_buffer, decode_image, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, &upload);
      image_barrier(decode_image, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, VK_ACCESS_TRANSFER_WRITE_BIT, VK_ACCESS_TRANSFER_READ_BIT,
                    VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT);
    } else {
    // Output image into GENERAL so the colour shader can store into it.
    image_barrier(decode_image, VK_IMAGE_LAYOUT_UNDEFINED, VK_IMAGE_LAYOUT_GENERAL, 0, VK_ACCESS_SHADER_WRITE_BIT,
                  VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT);
    if (use_gpu_bdecode) {
      // Stage B1b: the decode-ahead above reconstructed this display POC's YCoCg into a DPB slot;
      // stage it into coeff_buffer (already rounded int) for the colour pass below.
      int dslot = gdpb_poc_to_slot[frame_index];
      for (int plane = 0; plane < 3; plane++) {
        int pp = plane_width(plane, width) * plane_height(plane, height);   // chroma slot is smaller when subsampled
        VkBufferCopy copy = { 0, 0, (VkDeviceSize)pp * 4 };
        vkCmdCopyBuffer(command_buffer, gdpb_buffer[dslot][plane], coeff_buffer[plane], 1, &copy);
        VkMemoryBarrier to_shader = { VK_STRUCTURE_TYPE_MEMORY_BARRIER };
        to_shader.srcAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
        to_shader.dstAccessMask = VK_ACCESS_SHADER_READ_BIT | VK_ACCESS_SHADER_WRITE_BIT;
        vkCmdPipelineBarrier(command_buffer, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, 0, 1, &to_shader, 0, 0, 0, 0);
      }
    } else if (mode_3ddwt) {
      // The GOP was already spatial+temporal inverse-transformed above; just fetch this frame's slot
      // into coeff_buffer (and round the float result for the lossy path) for the colour pass below.
      int slot = (int)(frame_index - cur_gop_start);
      for (int plane = 0; plane < 3; plane++) {
        int pp = plane_width(plane, width) * plane_height(plane, height);   // chroma slot is smaller when subsampled
        VkBufferCopy copy = { (VkDeviceSize)slot * pp * 4, 0, (VkDeviceSize)pp * 4 };
        vkCmdCopyBuffer(command_buffer, gop_buffer[cur_buf][plane], coeff_buffer[plane], 1, &copy);
        VkMemoryBarrier to_shader = { VK_STRUCTURE_TYPE_MEMORY_BARRIER };
        to_shader.srcAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
        to_shader.dstAccessMask = VK_ACCESS_SHADER_READ_BIT | VK_ACCESS_SHADER_WRITE_BIT;
        vkCmdPipelineBarrier(command_buffer, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, 0, 1, &to_shader, 0, 0, 0, 0);
        if (!lossless && !g_mctf) {   // MCTF already rounded the gop to int in decode3d_spatial (the integer MC-Haar runs on int) -> no round here
          int32_t pixel_count_push = pp;
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_round);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_round, 0, 1, &set_row[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_round, VK_SHADER_STAGE_COMPUTE_BIT, 0, 4, &pixel_count_push);
          vkCmdDispatch(command_buffer, (pp + 255) / 256, 1, 1);
          memory_barrier();
        }
      }
    } else {
      // Per-GOP variable Q: when the frame's quality differs from the current one (a GOP boundary in a
      // --vbr stream), rebuild the quant map. The wavelet stays the same here (a --vbr file is all-lossy);
      // mixing lossless and lossy GOPs would also need a per-frame 5/3-vs-9/7 switch (deferred).
      if (index[frame_index].quality != current_quality) {
        current_quality = index[frame_index].quality;
        for (int plane = 0; plane < 3; plane++) {   // per-plane quant map (4:4:4 -> all identical)
          int plane_w = plane_width(plane, width), plane_h = plane_height(plane, height);
          build_quantization_steps(step, plane_w, plane_h, levels, current_quality);
          memcpy(step_map[plane], step, (size_t)(plane_w * plane_h) * 4);
        }
      }
      for (int plane = 0; plane < 3; plane++) {
        // Per-plane dimensions: luma is full-res; chroma is subsampled when g_chroma_format != 0 (4:4:4 ->
        // these equal the frame dims, so 4:4:4 behaviour is unchanged). plane_w is the buffer ROW STRIDE.
        int plane_w = plane_width(plane, width), plane_h = plane_height(plane, height);
        // The transpose scratch needs a stride large enough for the transposed (tall) region: for WIDE
        // planes max == plane_w (unchanged), for TALL planes it grows to plane_h to avoid row overlap.
        int scratch_stride = (plane_w > plane_h) ? plane_w : plane_h;
        int plane_pixels = plane_w * plane_h;
        int plane_blocks_x = block_count_x(plane_w), plane_blocks_y = block_count_y(plane_h);
        int plane_block_count = plane_blocks_x * plane_blocks_y;
        int plane_pixel_workgroups = (plane_pixels + 255) / 256;
        int plane_unpack_workgroups = (g_block_size == 128) ? plane_block_count : ((plane_block_count + 63) / 64);   // coop: one workgroup per block
        int plane_motion_blocks_x = ((plane_w + g_motion_block) - 1) / g_motion_block;
        int32_t plane_unpack_push[4] = { plane_w, plane_h, plane_blocks_x, plane_blocks_y };
        int32_t plane_pixel_count_push = plane_pixels;

        vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_unpack);
        vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_unpack, 0, 1, &set_unpack[plane], 0, 0);
        vkCmdPushConstants(command_buffer, pipeline_layout_unpack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, plane_unpack_push);
        vkCmdDispatch(command_buffer, plane_unpack_workgroups, 1, 1);
        memory_barrier();

        // coefdiff (A) P-frame: add the previous coefficients to the unpacked difference here, BEFORE
        // dequant/inverse. (colordiff adds AFTER the inverse instead — see below.)
        if (predictive && (header.prediction_method == 0)) {
          int32_t add_push[2] = { plane_pixels, is_predicted };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_coeff_add);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_coeff_add, 0, 1, &set_add[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_coeff_add, VK_SHADER_STAGE_COMPUTE_BIT, 0, 8, add_push);
          vkCmdDispatch(command_buffer, plane_pixel_workgroups, 1, 1);
          memory_barrier();
        }

        if (!lossless) {
          int32_t dequant_push[2];   // { plane_pixels, chroma_multiplier } — must match the encoder
          dequant_push[0] = plane_pixel_count_push;
          float chroma_multiplier = (plane == 0) ? 1.0f : g_chroma_quant;
          memcpy(&dequant_push[1], &chroma_multiplier, sizeof(float));
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_dequant);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_dequant, 0, 1, &set_dequant[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_dequant, VK_SHADER_STAGE_COMPUTE_BIT, 0, 8, dequant_push);
          vkCmdDispatch(command_buffer, plane_pixel_workgroups, 1, 1);
          memory_barrier();
        }

        // Inverse 2D wavelet, coarsest level first. The level pyramid is per-plane (from plane_w/plane_h).
        int level_width[16], level_height[16], level_count = 0, current_width = plane_w, current_height = plane_h;
        for (int level = 0; ((level < levels) && (current_width >= 2)) && (current_height >= 2); level++) {
          level_width[level_count] = current_width;
          level_height[level_count] = current_height;
          level_count++;
          current_width = (current_width + 1) / 2;
          current_height = (current_height + 1) / 2;
        }
        for (int level = level_count - 1; level >= 0; level--) {
          int level_w = level_width[level];
          int level_h = level_height[level];

          // coeff (stride plane_w) -> scratch (stride scratch_stride): dest is scratch.
          int32_t transpose_push_1[4] = { plane_w, level_w, level_h, scratch_stride };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_transpose);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_transpose, 0, 1, &set_coeff_to_scratch[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_transpose, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, transpose_push_1);
          vkCmdDispatch(command_buffer, (level_w + 15) / 16, (level_h + 15) / 16, 1);
          memory_barrier();

          // Row pass on scratch: stride scratch_stride.
          int32_t row_push_1[4] = { scratch_stride, level_h, level_w, 1 };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_inverse_row);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_row, 0, 1, &set_row_scratch, 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_row, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, row_push_1);
          vkCmdDispatch(command_buffer, level_w, 1, 1);
          memory_barrier();

          // scratch (stride scratch_stride) -> coeff (stride plane_w): dest is coeff.
          int32_t transpose_push_2[4] = { scratch_stride, level_h, level_w, plane_w };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_transpose);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_transpose, 0, 1, &set_scratch_to_coeff[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_transpose, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, transpose_push_2);
          vkCmdDispatch(command_buffer, (level_h + 15) / 16, (level_w + 15) / 16, 1);
          memory_barrier();

          int32_t row_push_2[4] = { plane_w, level_w, level_h, 1 };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_inverse_row);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_row, 0, 1, &set_row[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_row, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, row_push_2);
          vkCmdDispatch(command_buffer, level_h, 1, 1);
          memory_barrier();
        }

        if (!lossless) {
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_round);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_round, 0, 1, &set_row[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_round, VK_SHADER_STAGE_COMPUTE_BIT, 0, 4, &plane_pixel_count_push);
          vkCmdDispatch(command_buffer, plane_pixel_workgroups, 1, 1);
          memory_barrier();
        }

        // colordiff (B) P-frame: motion-compensate the previous reconstructed YCoCg (mc_prev, in scratch)
        // and add it to the residual AFTER the inverse wavelet, saving the result as the next reference —
        // mirror of the encoder's closed-loop reconstruction. mv=0 => mc_prev == prev.
        if (predictive && (header.prediction_method == 1)) {
          if (is_predicted) {
            int32_t mc_push[3] = { plane_w, plane_h, plane_motion_blocks_x };
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_mc);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_unpack, 0, 1, &set_mc_play[plane], 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_unpack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 12, mc_push);
            vkCmdDispatch(command_buffer, plane_pixel_workgroups, 1, 1);
            memory_barrier();
          }
          int32_t add_push[2] = { plane_pixels, is_predicted };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_motion_add);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_unpack, 0, 1, &set_motion_add_play[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_unpack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 8, add_push);
          vkCmdDispatch(command_buffer, plane_pixel_workgroups, 1, 1);
          memory_barrier();
        }
      }
    }

    // Chroma upsample params for the colour shader: shift + the stored Co/Cg (plane 1) dims. 4:4:4 ->
    // shift 0 and small dims == frame dims, so the shader's upsample reduces to chroma[y*W+x] (unchanged).
    int32_t chroma_shift_x_value = chroma_shift_x(), chroma_shift_y_value = chroma_shift_y();
    int32_t chroma_small_w = plane_width(1, width), chroma_small_h = plane_height(1, height);
    if (is_hdr) {   // HDR present: scRGB FP16 (real HDR display) or PQ/HLG -> tonemap -> sRGB8 (SDR fallback)
      struct { int32_t width, height; float exposure; int32_t transfer, shift_x, shift_y, small_w, small_h; } hdr_push =
        { width, height, hdr_exposure, header.transfer_function, chroma_shift_x_value, chroma_shift_y_value, chroma_small_w, chroma_small_h };
      VkPipeline present_pipeline = use_scrgb_output ? pipeline_colour_hdr_scrgb : pipeline_colour_hdr;
      vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, present_pipeline);
      vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_colour_hdr, 0, 1, &set_colour, 0, 0);
      vkCmdPushConstants(command_buffer, pipeline_layout_colour_hdr, VK_SHADER_STAGE_COMPUTE_BIT, 0, 32, &hdr_push);
    } else {
      int32_t colour_push[6] = { width, height, chroma_shift_x_value, chroma_shift_y_value, chroma_small_w, chroma_small_h };
      vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_colour);
      vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_colour, 0, 1, &set_colour, 0, 0);
      vkCmdPushConstants(command_buffer, pipeline_layout_colour, VK_SHADER_STAGE_COMPUTE_BIT, 0, 24, colour_push);
    }
    vkCmdDispatch(command_buffer, pixel_workgroups, 1, 1);

    image_barrier(decode_image, VK_IMAGE_LAYOUT_GENERAL, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, VK_ACCESS_SHADER_WRITE_BIT, VK_ACCESS_TRANSFER_READ_BIT,
                  VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT);
    }   // end of the non-B (GPU wavelet decode + colour) path; the B-stream upload above already left decode_image in TRANSFER_SRC

    if (verify || decode_to_path) {
      // Headless: copy the decoded image out; verify compares to the CPU ref, decode-to writes the AVI; no present.
      VkBufferImageCopy copy = { 0 };
      copy.imageSubresource = (VkImageSubresourceLayers){ VK_IMAGE_ASPECT_COLOR_BIT, 0, 0, 1 };
      copy.imageExtent = (VkExtent3D){ width, height, 1 };
      vkCmdCopyImageToBuffer(command_buffer, decode_image, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, readback_buffer, 1, &copy);
      vkEndCommandBuffer(command_buffer);
      VkSubmitInfo submit = { VK_STRUCTURE_TYPE_SUBMIT_INFO };
      submit.commandBufferCount = 1;
      submit.pCommandBuffers = &command_buffer;
      vkQueueSubmit(queue, 1, &submit, in_flight_fence);
      vkQueueWaitIdle(queue);

      uint8_t *gpu_rgba = readback_map;
      if (dump_first_frame && (frame_index == 0)) {   // dump the GPU-decoded frame 0 as a PPM (--dump)
        FILE *ppm = fopen("/tmp/fwv_frame0.ppm", "wb");
        if (ppm) {
          fprintf(ppm, "P6\n%d %d\n255\n", width, height);
          for (int p = 0; p < pixel_count; p++) {
            fwrite(&gpu_rgba[p * 4], 1, 3, ppm);
          }
          fclose(ppm);
        }
      }
      if (decode_to_path) {   // --decode-to: write this decoded frame (RGBA8 SDR) to the OpenDML AVI
        avi_video_frame(avi, gpu_rgba);
      }
      if (verify && !has_bframes) {   // B-stream: decode_image already IS the CPU decode_frame_bidi output -> validate via --decode-to + external PSNR
        if (mode_3ddwt) {
          memcpy(cpu_rgb, cpu_gop_rgb[frame_index - cur_gop_start], frame_bytes);   // CPU reference from the per-GOP decode above
        } else if (header.prediction_method == 1) {
          decode_frame_colordiff(frame_buffer, index[frame_index].size, width, height, levels, current_quality, cpu_rgb, predictive ? cpu_previous : NULL, is_predicted);
        } else {
          decode_frame_coefdiff(frame_buffer, index[frame_index].size, width, height, levels, current_quality, cpu_rgb, predictive ? cpu_previous : NULL, is_predicted);
        }
        // HDR: tonemap the CPU decode the same way color_hdr does, so we compare like for like (both SDR).
        const uint8_t *reference = cpu_rgb;
        if (is_hdr) {
          hdr_to_srgb8((const int16_t *)cpu_rgb, cpu_sdr, pixel_count, hdr_exposure, header.transfer_function);
          reference = cpu_sdr;
        }
        double mean_squared_error = 0;
        for (int i = 0; i < pixel_count; i++) {
          for (int channel = 0; channel < 3; channel++) {
            int difference = (int)gpu_rgba[(i * 4) + channel] - (int)reference[(i * 3) + channel];
            mean_squared_error += (double)difference * difference;
          }
        }
        mean_squared_error /= (double)pixel_count * 3;
        double psnr = (mean_squared_error == 0) ? 99.99 : (10 * log10((255.0 * 255.0) / mean_squared_error));
        verify_sum += psnr;
        verify_count++;
        if (psnr < 40) {
          if (verify_low < 10) {
            printf("  frame %u: GPU-vs-CPU %.1f dB (LOW)\n", frame_index, psnr);
          }
          verify_low++;
        }
      }
      if (mode_3ddwt && !pf_done) {   // advance the prefetch one subband (so verify exercises that path too)
        decode3d_wait(&d3d);
        upload_subband(file, index, pf_gop_start + (uint32_t)pf_step, &frame_buffer, &frame_buffer_capacity, block_count_plane, offset_map, data_map, step_map, step,
                       width, height, levels, quality, lossless, pf_step, pf_gop_count, g_temporal_levels,
                       g_mctf ? &mctf_mv[pf_buf][(size_t)pf_step * motion_blocks_x * motion_blocks_y * 2] : NULL);
        decode3d_spatial(&d3d, pf_buf, pf_step);
        pf_step++;
        if (pf_step >= pf_gop_count) {
          decode3d_wait(&d3d);
          decode3d_finish_gop(&d3d, pf_buf, pf_gop_count, mctf_mv);
          pf_done = 1;
        }
      }
      continue;
    }

    // Letterbox the decoded frame into the (maximized) window: clear to black, then blit aspect-fit + centred.
    image_barrier(swapchain_images[swapchain_index], VK_IMAGE_LAYOUT_UNDEFINED, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 0, VK_ACCESS_TRANSFER_WRITE_BIT,
                  VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT);
    VkClearColorValue black = {{ 0.0f, 0.0f, 0.0f, 1.0f }};
    VkImageSubresourceRange full_range = { VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1 };
    vkCmdClearColorImage(command_buffer, swapchain_images[swapchain_index], VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, &black, 1, &full_range);
    VkMemoryBarrier clear_barrier = { VK_STRUCTURE_TYPE_MEMORY_BARRIER };   // clear must finish before the centred blit
    clear_barrier.srcAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
    clear_barrier.dstAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
    vkCmdPipelineBarrier(command_buffer, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 1, &clear_barrier, 0, 0, 0, 0);
    // aspect-fit the video into the window, centred (pillarbox if the window is wider, letterbox if taller)
    double video_aspect = (double)width / (double)height;
    int fit_w, fit_h;
    if (((double)extent.width / (double)extent.height) > video_aspect) {
      fit_h = (int)extent.height;
      fit_w = (int)(((double)extent.height * video_aspect) + 0.5);
    } else {
      fit_w = (int)extent.width;
      fit_h = (int)(((double)extent.width / video_aspect) + 0.5);
    }
    int fit_x = ((int)extent.width - fit_w) / 2;
    int fit_y = ((int)extent.height - fit_h) / 2;
    VkImageBlit blit = { 0 };
    blit.srcSubresource = blit.dstSubresource = (VkImageSubresourceLayers){ VK_IMAGE_ASPECT_COLOR_BIT, 0, 0, 1 };
    blit.srcOffsets[1] = (VkOffset3D){ width, height, 1 };
    blit.dstOffsets[0] = (VkOffset3D){ fit_x, fit_y, 0 };
    blit.dstOffsets[1] = (VkOffset3D){ fit_x + fit_w, fit_y + fit_h, 1 };
    vkCmdBlitImage(command_buffer, decode_image, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, swapchain_images[swapchain_index], VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, &blit, VK_FILTER_LINEAR);
    image_barrier(swapchain_images[swapchain_index], VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, VK_IMAGE_LAYOUT_PRESENT_SRC_KHR, VK_ACCESS_TRANSFER_WRITE_BIT, 0,
                  VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT);

    vkEndCommandBuffer(command_buffer);
    VkPipelineStageFlags wait_stage = VK_PIPELINE_STAGE_TRANSFER_BIT;
    VkSubmitInfo submit = { VK_STRUCTURE_TYPE_SUBMIT_INFO };
    submit.waitSemaphoreCount = 1;
    submit.pWaitSemaphores = &acquire_semaphore[frame_index & 1];
    submit.pWaitDstStageMask = &wait_stage;
    submit.commandBufferCount = 1;
    submit.pCommandBuffers = &command_buffer;
    submit.signalSemaphoreCount = 1;
    submit.pSignalSemaphores = &render_semaphore[swapchain_index];   // per-image: tied to the present's lifetime
    vkQueueSubmit(queue, 1, &submit, in_flight_fence);

    VkPresentInfoKHR present_info = { VK_STRUCTURE_TYPE_PRESENT_INFO_KHR };
    present_info.waitSemaphoreCount = 1;
    present_info.pWaitSemaphores = &render_semaphore[swapchain_index];   // per-image (matches the submit's signal)
    present_info.swapchainCount = 1;
    present_info.pSwapchains = &swapchain;
    present_info.pImageIndices = &swapchain_index;
    VkResult present_result = vkQueuePresentKHR(queue, &present_info);
    if ((present_result == VK_ERROR_OUT_OF_DATE_KHR) || (present_result == VK_SUBOPTIMAL_KHR)) {
      need_recreate = 1;   // surface size changed: rebuild the swapchain next frame
    }
    double loop_td = fwv_time ? now_milliseconds() : 0.0;
    // Present-pipelining: NO vkQueueWaitIdle. The loop-top in_flight_fence wait already gates the shared
    // buffer / command-buffer reuse for the next frame (it blocks until the previous submit's GPU work is
    // done), and the present then runs async / overlapped — exactly as the 3D-DWT path below already relies
    // on. A full per-frame drain is removed so an embedding game loop sharing this queue is never stalled.
    if (fwv_time) { loop_drain_ms += (now_milliseconds() - loop_td); }   // now ~0 — the GPU wait moved to the loop-top fence
    // 3D-DWT: leaving the queue running lets the prefetch step below execute on the GPU concurrently with the
    // next frame's audio-pacing wait (so the ~one-frame-time subband decode is hidden).

    // 3D-DWT: prefetch one subband of the next GOP — its decode overlaps the next frame's pacing.
    if (mode_3ddwt && !pf_done) {
      decode3d_wait(&d3d);
      upload_subband(file, index, pf_gop_start + (uint32_t)pf_step, &frame_buffer, &frame_buffer_capacity, block_count_plane, offset_map, data_map, step_map, step,
                     width, height, levels, quality, lossless, pf_step, pf_gop_count, g_temporal_levels,
                     g_mctf ? &mctf_mv[pf_buf][(size_t)pf_step * motion_blocks_x * motion_blocks_y * 2] : NULL);
      decode3d_spatial(&d3d, pf_buf, pf_step);
      pf_step++;
      if (pf_step >= pf_gop_count) {
        decode3d_wait(&d3d);
        decode3d_finish_gop(&d3d, pf_buf, pf_gop_count, mctf_mv);
        pf_done = 1;
      }
    }
    if (fwv_time) {
      loop_total_ms += (now_milliseconds() - loop_t0);
      loop_count++;
    }
  }

  vkDeviceWaitIdle(device);
  if (has_bframes) {
    bstream_free(&bstream);
    vkDestroyBuffer(device, bf_upload_buffer, 0);
    vkFreeMemory(device, bf_upload_memory, 0);
  }
  double elapsed = (now_milliseconds() - start_time) / 1000.0;
  if (fwv_time && (bdec_count > 0)) {
    double n = (double)bdec_count;
    printf("B-decode timing over %ld frames: CPU-prep %.2f ms/f [parse %.2f (data-copy %.2f + mv-decode %.2f) + rebind %.2f + record %.2f] + GPU-busy %.2f ms/f = %.2f ms/f (%.1f fps decode ceiling)\n",
           bdec_count, bdec_cpu_ms / n, bdec_parse_ms / n, bdec_pdata_ms / n, (bdec_parse_ms - bdec_pdata_ms) / n,
           bdec_rebind_ms / n, bdec_record_ms / n,
           bdec_gpu_ms / n, (bdec_cpu_ms + bdec_gpu_ms) / n,
           1000.0 / (((bdec_cpu_ms + bdec_gpu_ms) / n) + 0.0001));
  }
  if (fwv_time && (loop_count > 0)) {
    double n = (double)loop_count;
    printf("present-loop over %ld frames: total %.2f ms/f [fence-wait %.2f + pace-wait/idle %.2f + acquire %.2f + queue-drain/GPU+vsync %.2f] | slowest fence frame %d (type %d) %.2f ms\n",
           loop_count, loop_total_ms / n, loop_fence_ms / n, loop_pace_ms / n, loop_acquire_ms / n, loop_drain_ms / n, loop_max_frame, loop_max_type, loop_max_ms);
  }
  if (decode_to_path) {
    avi_close(avi);
    printf("decode-to: wrote %u frames to %s (%.2f s)\n", header.frame_count, decode_to_path, elapsed);
    return 0;
  }
  if (verify) {
    printf("VERIFY: GPU-decode(file) vs CPU %s avg %.2f dB over %d frames | %d LOW frames %s\n",
           mode_3ddwt ? "decode_gop_3ddwt" : "decode_frame_coefdiff",
           verify_sum / (verify_count ? verify_count : 1), verify_count, verify_low,
           verify_low ? "=> PLAYER DECODE PATH is the bug (data/parse)" : "=> decode CLEAN -> bug is blit/present");
    return 0;
  }
  printf("played %u frames in %.2f s (%.1f fps)\n", header.frame_count, elapsed, header.frame_count / elapsed);
  if (audio_device) {
    SDL_CloseAudioDevice(audio_device);
  }
  // Tear down the present-loop sync objects (the device is idle via vkDeviceWaitIdle above): the per-slot
  // acquire semaphores, the per-image render-finished semaphores, and the frame fence.
  for (int k = 0; k < 2; k++) {
    vkDestroySemaphore(device, acquire_semaphore[k], NULL);
  }
  for (uint32_t k = 0; k < swapchain_image_count; k++) {
    vkDestroySemaphore(device, render_semaphore[k], NULL);
  }
  vkDestroyFence(device, in_flight_fence, NULL);
  // explicitly tear down the swapchain (the device is already idle) BEFORE SDL destroys the
  // Vulkan surface — otherwise SDL destroys a surface that still has a live swapchain (with possibly a
  // present pending at the compositor), which intermittently hangs at the stream end (the decode-lead's
  // faster end made this latent race visible). vkDestroySwapchainKHR aborts/drains any pending present.
  vkDestroySwapchainKHR(device, swapchain, NULL);
  SDL_DestroyWindow(window);
  SDL_Quit();
  return 0;
}
