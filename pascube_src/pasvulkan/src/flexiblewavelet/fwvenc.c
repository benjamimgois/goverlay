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
 * fwvenc.c — GPU ENCODER (the novel part — GPU-side wavelet encoding).
 *
 * Includes fwvwave.c for the container format and the CPU reference decode. Per frame, in two
 * compute passes:
 *   Pass 1: upload RGB -> YCoCg-R -> forward wavelet -> quantize -> bitplane_size (bytes per block).
 *   (CPU)   prefix-sum the per-block sizes into byte offsets.
 *   Pass 2: bitplane_pack — each block writes its bytes at its 4-byte-aligned offset (no atomics).
 * The packed stream is byte-identical to the CPU encode_block, so the CPU/GPU decoder reads it.
 *
 * The spatial intra pipeline above is the base; on top the encoder also does inter prediction (P /
 * hierarchical B-frames with motion) and an open-loop / motion-compensated (MCTF) 3D-DWT temporal mode, plus
 * SDR/HDR and chroma subsampling. Without an output file it runs a self-test (CPU-decode the GPU stream, PSNR vs
 * the original); with an out.fwv it writes a full container (frames + index + optional audio: Vorbis / QOA-LE /
 * raw PCM / FWA). quality == 0 selects the lossless integer 5/3 path; quality >= 1 the lossy 9/7 path.
 *
 *     ./fwvenc in.(mp4|y4m) [out.fwv] [quality=8] [levels=5] [max_frames] [flags...]   (--help for the full list)
 */
#define FWV_NO_MAIN
#include "fwvwave.c"
#include "fwa_audio.h"   // the "FWA" wavelet-audio sub-codec (separate TU, linked via the Makefile)
#include <vulkan/vulkan.h>

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
static VkQueue queue;
static VkFence fence;

// ---------------------------------------------------------------- Vulkan helpers

static uint32_t find_memory_type(uint32_t type_bits, VkMemoryPropertyFlags wanted) {
  VkPhysicalDeviceMemoryProperties memory_properties;
  vkGetPhysicalDeviceMemoryProperties(physical_device, &memory_properties);
  for (uint32_t i = 0; i < memory_properties.memoryTypeCount; i++) {
    if ((type_bits & (1u << i)) && (memory_properties.memoryTypes[i].propertyFlags & wanted) == wanted) {
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

// Descriptor set layout with `storage_buffer_count` storage buffers (the encoder uses no images).
static VkDescriptorSetLayout create_descriptor_set_layout(int storage_buffer_count) {
  VkDescriptorSetLayoutBinding bindings[12];   // up to 11 (B2b joint motion search layout)
  for (int i = 0; i < storage_buffer_count; i++) {
    bindings[i] = (VkDescriptorSetLayoutBinding){ i, VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, 1, VK_SHADER_STAGE_COMPUTE_BIT, 0 };
  }
  VkDescriptorSetLayoutCreateInfo info = { VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO };
  info.bindingCount = storage_buffer_count;
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

// Like create_compute_pipeline but bakes the coding block size into specialization constant 0 (BS) — used for
// the bitplane shaders (bitplane_size/pack, apply_pcrd) so 32/64/128 each get a correctly-sized pipeline.
static VkPipeline create_compute_pipeline_bs(const char *spirv_path, VkPipelineLayout layout, int block_size) {
  size_t code_size;
  uint32_t *code = load_spirv(spirv_path, &code_size);
  VkShaderModuleCreateInfo module_info = { VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO };
  module_info.codeSize = code_size;
  module_info.pCode = code;
  VkShaderModule module;
  VK_CHECK(vkCreateShaderModule(device, &module_info, 0, &module));
  free(code);
  int spec_values[2] = { block_size, (block_size == 128) ? 1 : 0 };   // [0] = BS, [1] = COOP (128 = one workgroup/block)
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
// workgroup size into spec constant 1 (MB*MB) — used for the 5 motion shaders so 8/16/32 each get a
// correctly-sized pipeline. The flat shaders (mc, blend_mode) ignore id 1 (their workgroup stays a fixed 256).
static VkPipeline create_compute_pipeline_motion(const char *spirv_path, VkPipelineLayout layout, int motion_block) {
  size_t code_size;
  uint32_t *code = load_spirv(spirv_path, &code_size);
  VkShaderModuleCreateInfo module_info = { VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO };
  module_info.codeSize = code_size;
  module_info.pCode = code;
  VkShaderModule module;
  VK_CHECK(vkCreateShaderModule(device, &module_info, 0, &module));
  free(code);
  // [0] = MB, [1] = per-block workgroup = MB*MB, [2] = EMIT_SATD (1 only for the variable-motion R-D merge, which
  // consumes sad_out as SATD; 0 for fixed/B so the cooperative SATD pass — and its r[16] register pressure — is
  // COMPILED OUT, restoring motion_estimate.comp occupancy). Only motion_estimate.comp declares constant_id=2; the
  // other motion shaders (mc, blend_mode, motion_estimate_bidi, mode_decide) ignore the unused entry (Vulkan-legal).
  int spec_values[3] = { motion_block, motion_block * motion_block, (g_motion_variable && g_merge_satd) ? 1 : 0 };
  VkSpecializationMapEntry entries[3] = { { 0, 0, sizeof(int) }, { 1, sizeof(int), sizeof(int) }, { 2, 2 * sizeof(int), sizeof(int) } };
  VkSpecializationInfo spec = { 3, entries, sizeof(spec_values), spec_values };
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
  VkDescriptorBufferInfo buffer_infos[12];   // up to 11 (B2b joint motion search set)
  VkWriteDescriptorSet writes[12] = { 0 };
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

// Like bind_storage_buffers but each binding starts at a per-buffer BYTE OFFSET (for MCTF: gop_buffer[plane]
// at the even/odd FRAME offset). offsets[i] must satisfy minStorageBufferOffsetAlignment (frame strides
// f*plane_pixels*4 are large multiples of the plane size → 256-aligned for the standard test resolutions).
static void bind_storage_buffers_offset(VkDescriptorSet set, VkBuffer *buffers, const VkDeviceSize *offsets, int count) {
  VkDescriptorBufferInfo buffer_infos[12];
  VkWriteDescriptorSet writes[12] = { 0 };
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

static void submit_and_wait(void) {
  vkEndCommandBuffer(command_buffer);
  VkSubmitInfo submit = { VK_STRUCTURE_TYPE_SUBMIT_INFO };
  submit.commandBufferCount = 1;
  submit.pCommandBuffers = &command_buffer;
  VK_CHECK(vkResetFences(device, 1, &fence));
  VK_CHECK(vkQueueSubmit(queue, 1, &submit, fence));
  VK_CHECK(vkWaitForFences(device, 1, &fence, VK_TRUE, UINT64_MAX));
}

static void begin_recording(void) {
  VK_CHECK(vkResetCommandBuffer(command_buffer, 0));
  VkCommandBufferBeginInfo begin_info = { VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO };
  begin_info.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
  vkBeginCommandBuffer(command_buffer, &begin_info);
}

// Extract the audio track to a temporary OGG/Vorbis blob via ffmpeg (returns NULL if there is none).
static uint8_t *extract_audio(const char *input, uint64_t *out_size) {
  char command[4096];
  *out_size = 0;
  snprintf(command, sizeof command, "ffprobe -v error -select_streams a:0 -show_entries stream=codec_type -of csv=p=0 \"%s\"", input);
  FILE *probe = popen(command, "r");
  char codec_type[64] = "";
  if (probe) {
    if (!fgets(codec_type, sizeof codec_type, probe)) {
      codec_type[0] = 0;
    }
    pclose(probe);
  }
  if (strncmp(codec_type, "audio", 5)) {
    return 0;
  }
  snprintf(command, sizeof command, "ffmpeg -v error -y -i \"%s\" -vn -c:a libvorbis -q:a 5 /tmp/pvw2_a.ogg", input);
  if (system(command)) {
    return 0;
  }
  FILE *audio_file = fopen("/tmp/pvw2_a.ogg", "rb");
  if (!audio_file) {
    return 0;
  }
  fseek(audio_file, 0, SEEK_END);
  long size = ftell(audio_file);
  fseek(audio_file, 0, SEEK_SET);
  if (size <= 0) {
    fclose(audio_file);
    return 0;
  }
  uint8_t *blob = checked_malloc(size);
  if (fread(blob, 1, size, audio_file) != (size_t)size) {
    fclose(audio_file);
    free(blob);
    return 0;
  }
  fclose(audio_file);
  *out_size = (uint64_t)size;
  return blob;
}

// Extract the source audio as interleaved s16 PCM (for the QOA / RPCM paths). Probes channels + sample
// rate, then has ffmpeg decode to raw s16le. Returns malloc'd PCM and sets *samples (per channel) /
// *channels / *sample_rate; returns NULL if there is no audio stream.
static short *extract_audio_pcm(const char *input, int *out_samples, int *out_channels, int *out_rate) {
  char command[4096];
  int channels = 0, rate = 0;
  snprintf(command, sizeof command, "ffprobe -v error -select_streams a:0 -show_entries stream=channels -of csv=p=0 \"%s\"", input);
  FILE *probe = popen(command, "r");
  if (probe) {
    char line[64] = "";
    if (fgets(line, sizeof line, probe)) {
      channels = atoi(line);
    }
    pclose(probe);
  }
  snprintf(command, sizeof command, "ffprobe -v error -select_streams a:0 -show_entries stream=sample_rate -of csv=p=0 \"%s\"", input);
  probe = popen(command, "r");
  if (probe) {
    char line[64] = "";
    if (fgets(line, sizeof line, probe)) {
      rate = atoi(line);
    }
    pclose(probe);
  }
  if ((channels < 1) || (rate < 1)) {
    return NULL;
  }
  snprintf(command, sizeof command, "ffmpeg -v error -y -i \"%s\" -vn -f s16le -acodec pcm_s16le -ac %d -ar %d /tmp/pvw2_a.raw", input, channels, rate);
  if (system(command)) {
    return NULL;
  }
  FILE *raw = fopen("/tmp/pvw2_a.raw", "rb");
  if (!raw) {
    return NULL;
  }
  fseek(raw, 0, SEEK_END);
  long size = ftell(raw);
  fseek(raw, 0, SEEK_SET);
  if (size <= 0) {
    fclose(raw);
    return NULL;
  }
  short *pcm = checked_malloc((size_t)size);
  if (fread(pcm, 1, (size_t)size, raw) != (size_t)size) {
    fclose(raw);
    free(pcm);
    return NULL;
  }
  fclose(raw);
  *out_channels = channels;
  *out_rate = rate;
  *out_samples = (int)((size_t)size / (((size_t)channels) * sizeof(short)));
  return pcm;
}

// .fwv container header (must match fwvplay's reader). version + header_size make it growable:
// future fields can be appended and older readers skip to the payload via header_size. The colour
// block uses CICP code points (ITU-T H.273) so a player / engine knows how to display the frames;
// the codec itself is currently 8-bit SDR, the HDR fields are reserved for later.
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

// Per-frame index entry. The on-disk index is in
// CODING order; poc gives the display position. ref0/ref1 are the coding-order indices of the L0/L1
// references (-1 = none), so ARBITRARY coding structures (adaptive GOPs, non-dyadic / variable B
// counts, any hierarchy depth, long-term refs) need no format change — the decoder reads them directly,
// nothing is derived. quality is the per-GOP Q (the decoder rebuilds the quant map only when it
// changes). temporal_id is the hierarchy level (for QP-cascading / temporal scalability). I/P/3D-DWT
// frames set poc=display index, ref0=prev/-1, ref1=-1, temporal_id=0 (behaviourally unchanged). For the
// 3D-DWT path type stays 0 (GOP start) / 2 (continuation) — interpreted method-scoped (prediction_method
// 2), so it never collides with the colordiff "2 = B". Must match fwvplay's reader.
typedef struct {
  uint64_t offset;
  uint32_t size;
  uint32_t poc;         // display-order position (the on-disk index is in CODING order)
  int32_t  ref0;        // coding-order index of the L0 reference (-1 = none)
  int32_t  ref1;        // coding-order index of the L1 reference (-1 = none)
  uint8_t  type;        // 0 = I, 1 = P, 2 = B
  uint8_t  quality;
  uint8_t  temporal_id; // hierarchy level (QP-cascading / temporal scalability) — future-proof
  uint8_t  pad;
} FrameEntry;           // 28 bytes

// Source duration in seconds (for the encode progress total / ETA); 0 if ffprobe cannot tell.
static double probe_video_duration(const char *input) {
  char command[4096];
  snprintf(command, sizeof command, "ffprobe -v error -show_entries format=duration -of csv=p=0 \"%s\"", input);
  FILE *probe = popen(command, "r");
  double duration = 0;
  if (probe) {
    char line[64] = "";
    if (fgets(line, sizeof line, probe)) {
      duration = atof(line);
    }
    pclose(probe);
  }
  return duration;
}

// Same-line (\r) encode progress: percent, frame N/total, video-time/length, average ms/frame, rough ETA.
static void print_encode_progress(long done, long total, double fps_value, double elapsed_ms) {
  double avg_ms = (done > 0) ? (elapsed_ms / (double)done) : 0.0;
  double video_done = (fps_value > 0) ? ((double)done / fps_value) : 0.0;
  if (total > 0) {
    long shown = (done < total) ? done : total;
    double pct = (100.0 * (double)shown) / (double)total;
    double video_total = (fps_value > 0) ? ((double)total / fps_value) : 0.0;
    int eta_s = (int)(((avg_ms * (double)(total - shown)) / 1000.0) + 0.5);
    char eta_str[32];
    if (eta_s >= 60) {
      snprintf(eta_str, sizeof eta_str, "%dm%02ds", eta_s / 60, eta_s % 60);
    } else {
      snprintf(eta_str, sizeof eta_str, "%ds", eta_s);
    }
    fprintf(stderr, "\r  [%5.1f%%] %ld/%ld  %.1f/%.1fs  avg %.1f ms/f  ETA %s    ",
            pct, shown, total, video_done, video_total, avg_ms, eta_str);
  } else {
    fprintf(stderr, "\r  frame %ld  %.1fs  avg %.1f ms/f    ", done, video_done, avg_ms);
  }
  fflush(stderr);
}

// Encode the source to a full-res H.264 Annex-B elementary stream (the player's HW-decode path). High
// profile / yuv420p / progressive to match the Vulkan video decode profile. Returns malloc'd blob.
// ---- minimal pure-C MP4/MOV -> Annex-B H.264 demuxer (ffmpeg-free copy path) ----

static uint32_t mp4_u32(const uint8_t *p) { return (((uint32_t)p[0] << 24) | ((uint32_t)p[1] << 16)) | (((uint32_t)p[2] << 8) | (uint32_t)p[3]); }
static uint64_t mp4_u64(const uint8_t *p) { return ((uint64_t)mp4_u32(p) << 32) | (uint64_t)mp4_u32(p + 4); }

// Find a direct child box of `type` within [buf, buf+size); returns its body pointer + sets *body_size.
static const uint8_t *mp4_child(const uint8_t *buf, size_t size, const char *type, size_t *body_size) {
  size_t offset = 0;
  while ((offset + 8) <= size) {
    uint64_t box_size = mp4_u32(buf + offset);
    size_t header = 8;
    if (box_size == 1) {
      if ((offset + 16) > size) {
        break;
      }
      box_size = mp4_u64(buf + offset + 8);
      header = 16;
    } else if (box_size == 0) {
      box_size = size - offset;
    }
    if ((box_size < header) || ((offset + box_size) > size)) {
      break;
    }
    if (memcmp(buf + offset + 4, type, 4) == 0) {
      *body_size = (size_t)(box_size - header);
      return buf + offset + header;
    }
    offset += (size_t)box_size;
  }
  return NULL;
}

// Append `length` bytes from `data` to a growing malloc'd buffer (*buffer / *capacity / *length_out).
static void mp4_append(uint8_t **buffer, size_t *capacity, size_t *length_out, const uint8_t *data, size_t length) {
  if ((*length_out + length) > *capacity) {
    while ((*length_out + length) > *capacity) {
      *capacity *= 2;
    }
    *buffer = realloc(*buffer, *capacity);
    if (!*buffer) {
      die("realloc");
    }
  }
  memcpy(*buffer + *length_out, data, length);
  *length_out += length;
}

// Extract the H.264 video track from an MP4/MOV as an Annex-B blob, with NO ffmpeg. Returns NULL (so the
// caller falls back to ffmpeg) if the file isn't MP4, isn't decoder-compatible H.264 (8-bit 4:2:0), or uses
// a layout this minimal demuxer doesn't handle. Emits only the first `max_frames` samples when > 0.
static uint8_t *mp4_extract_h264_annexb(const char *input, long max_frames, uint64_t *out_size) {
  *out_size = 0;
  FILE *file = fopen(input, "rb");
  if (!file) {
    return NULL;
  }

  // 1) Scan top-level boxes for 'moov' (it may sit before or after 'mdat'); read it into memory.
  uint8_t *moov = NULL;
  size_t moov_size = 0;
  for (;;) {
    uint8_t header[16];
    long box_start = ftell(file);
    if (fread(header, 1, 8, file) != 8) {
      break;
    }
    uint64_t box_size = mp4_u32(header);
    int header_len = 8;
    if (box_size == 1) {
      if (fread(header + 8, 1, 8, file) != 8) {
        break;
      }
      box_size = mp4_u64(header + 8);
      header_len = 16;
    }
    if (box_size < (uint64_t)header_len) {
      break;
    }
    if (memcmp(header + 4, "moov", 4) == 0) {
      moov_size = (size_t)(box_size - header_len);
      moov = checked_malloc(moov_size);
      if (fread(moov, 1, moov_size, file) != moov_size) {
        free(moov);
        moov = NULL;
      }
      break;
    }
    if (fseeko(file, (off_t)box_start + (off_t)box_size, SEEK_SET) != 0) {
      break;
    }
  }
  if (!moov) {
    fclose(file);
    return NULL;
  }

  // 2) Find the VIDEO trak's stbl (handler_type == 'vide').
  const uint8_t *stbl = NULL;
  size_t stbl_size = 0;
  size_t offset = 0;
  while ((offset + 8) <= moov_size) {
    uint64_t box_size = mp4_u32(moov + offset);
    size_t header = 8;
    if (box_size == 1) {
      if ((offset + 16) > moov_size) {
        break;
      }
      box_size = mp4_u64(moov + offset + 8);
      header = 16;
    } else if (box_size == 0) {
      box_size = moov_size - offset;
    }
    if ((box_size < header) || ((offset + box_size) > moov_size)) {
      break;
    }
    if (memcmp(moov + offset + 4, "trak", 4) == 0) {
      const uint8_t *trak = moov + offset + header;
      size_t trak_size = (size_t)(box_size - header), mdia_size = 0;
      const uint8_t *mdia = mp4_child(trak, trak_size, "mdia", &mdia_size);
      if (mdia) {
        size_t hdlr_size = 0;
        const uint8_t *hdlr = mp4_child(mdia, mdia_size, "hdlr", &hdlr_size);   // body: vers/flags(4)+predef(4)+handler(4)
        if ((hdlr && (hdlr_size >= 12)) && (memcmp(hdlr + 8, "vide", 4) == 0)) {
          size_t minf_size = 0;
          const uint8_t *minf = mp4_child(mdia, mdia_size, "minf", &minf_size);
          if (minf) {
            stbl = mp4_child(minf, minf_size, "stbl", &stbl_size);
          }
        }
      }
      if (stbl) {
        break;
      }
    }
    offset += (size_t)box_size;
  }
  if (!stbl) {
    free(moov);
    fclose(file);
    return NULL;
  }

  // 3) stsd -> avc1/avc3 -> avcC (SPS/PPS + NAL length size + profile).
  size_t stsd_size = 0;
  const uint8_t *stsd = mp4_child(stbl, stbl_size, "stsd", &stsd_size);
  if (!stsd || (stsd_size < 16)) {
    free(moov);
    fclose(file);
    return NULL;
  }
  const uint8_t *entry = stsd + 8;   // skip version/flags(4) + entry_count(4)
  uint32_t entry_size = mp4_u32(entry);
  int is_avc = ((memcmp(entry + 4, "avc1", 4) == 0) || (memcmp(entry + 4, "avc3", 4) == 0));
  if (!is_avc || (entry_size < 86) || (((size_t)(entry - stsd) + entry_size) > stsd_size)) {
    free(moov);
    fclose(file);
    return NULL;
  }
  size_t avcc_size = 0;
  const uint8_t *avcc = mp4_child(entry + 8 + 78, (size_t)entry_size - 8 - 78, "avcC", &avcc_size);   // after the 78-byte VisualSampleEntry
  if (!avcc || (avcc_size < 7)) {
    free(moov);
    fclose(file);
    return NULL;
  }
  int profile_idc = avcc[1];
  if (((profile_idc != 66) && (profile_idc != 77)) && ((profile_idc != 88) && (profile_idc != 100))) {
    free(moov);   // High10/High4:2:2/High4:4:4 etc. -> not 8-bit 4:2:0 -> let ffmpeg handle it
    fclose(file);
    return NULL;
  }
  int nal_length_size = (avcc[4] & 3) + 1;

  // 4) Start the Annex-B output with the SPS/PPS NALs from avcC.
  size_t out_capacity = 1 << 20, out_length = 0;
  uint8_t *output = checked_malloc(out_capacity);
  static const uint8_t start_code[4] = { 0, 0, 0, 1 };
  size_t pos = 6;   // byte 5 = numOfSequenceParameterSets; SPS entries start at byte 6
  int sps_count = avcc[5] & 0x1f;
  for (int s = 0; (s < sps_count) && ((pos + 2) <= avcc_size); s++) {
    uint16_t length = (uint16_t)((avcc[pos] << 8) | avcc[pos + 1]);
    pos += 2;
    if ((pos + length) > avcc_size) {
      break;
    }
    mp4_append(&output, &out_capacity, &out_length, start_code, 4);
    mp4_append(&output, &out_capacity, &out_length, avcc + pos, length);
    pos += length;
  }
  if ((pos + 1) <= avcc_size) {
    int pps_count = avcc[pos++];
    for (int p = 0; (p < pps_count) && ((pos + 2) <= avcc_size); p++) {
      uint16_t length = (uint16_t)((avcc[pos] << 8) | avcc[pos + 1]);
      pos += 2;
      if ((pos + length) > avcc_size) {
        break;
      }
      mp4_append(&output, &out_capacity, &out_length, start_code, 4);
      mp4_append(&output, &out_capacity, &out_length, avcc + pos, length);
      pos += length;
    }
  }

  // 5) Sample table: sizes (stsz), chunk offsets (stco/co64), sample-to-chunk (stsc).
  size_t stsz_size = 0, stco_size = 0, co64_size = 0, stsc_size = 0;
  const uint8_t *stsz = mp4_child(stbl, stbl_size, "stsz", &stsz_size);
  const uint8_t *stco = mp4_child(stbl, stbl_size, "stco", &stco_size);
  const uint8_t *co64 = mp4_child(stbl, stbl_size, "co64", &co64_size);
  const uint8_t *stsc = mp4_child(stbl, stbl_size, "stsc", &stsc_size);
  if ((!stsz || !stsc) || (!stco && !co64)) {
    free(output);
    free(moov);
    fclose(file);
    return NULL;
  }
  uint32_t uniform_size = mp4_u32(stsz + 4);
  uint32_t sample_count = mp4_u32(stsz + 8);
  uint32_t chunk_count = mp4_u32((stco ? stco : co64) + 4);
  uint32_t stsc_count = mp4_u32(stsc + 4);
  if (((sample_count == 0) || (chunk_count == 0)) || (stsc_count == 0)) {
    free(output);   // empty sample table (e.g. a fragmented MP4: samples live in moof) -> let ffmpeg handle it
    free(moov);
    fclose(file);
    return NULL;
  }
  if (((max_frames > 0) && ((uint32_t)max_frames < sample_count))) {
    sample_count = (uint32_t)max_frames;
  }

  // 6) Walk samples: for each, file offset = chunk_offset + running offset within the chunk; copy its NALs.
  uint8_t *sample = NULL;
  size_t sample_capacity = 0;
  uint32_t chunk = 0, sample_in_chunk = 0, running = 0, stsc_index = 0;
  int ok = 1;
  for (uint32_t i = 0; (i < sample_count) && ok; i++) {
    if (chunk >= chunk_count) {
      ok = 0;
      break;
    }
    // samples-per-chunk for this chunk (stsc entries: first_chunk(1-based), samples_per_chunk, desc).
    while (((stsc_index + 1) < stsc_count) && ((chunk + 1) >= mp4_u32((stsc + 8) + ((stsc_index + 1) * 12)))) {
      stsc_index++;
    }
    uint32_t per_chunk = mp4_u32((stsc + 8) + (stsc_index * 12) + 4);
    uint64_t chunk_offset = stco ? mp4_u32((stco + 8) + (chunk * 4)) : mp4_u64((co64 + 8) + (chunk * 8));
    uint32_t sample_size = (uniform_size != 0) ? uniform_size : mp4_u32((stsz + 12) + (i * 4));
    uint64_t file_offset = chunk_offset + running;

    if (sample_size > sample_capacity) {
      sample_capacity = sample_size;
      sample = realloc(sample, sample_capacity);
      if (!sample) {
        die("realloc");
      }
    }
    if ((fseeko(file, (off_t)file_offset, SEEK_SET) != 0) || (fread(sample, 1, sample_size, file) != sample_size)) {
      ok = 0;
      break;
    }
    // The sample is a sequence of [NAL length : nal_length_size bytes][NAL]; rewrite to start-code Annex-B.
    size_t p = 0;
    while ((p + (size_t)nal_length_size) <= sample_size) {
      uint32_t nal_length = 0;
      for (int b = 0; b < nal_length_size; b++) {
        nal_length = (nal_length << 8) | sample[p + b];
      }
      p += nal_length_size;
      if ((p + nal_length) > sample_size) {
        break;
      }
      mp4_append(&output, &out_capacity, &out_length, start_code, 4);
      mp4_append(&output, &out_capacity, &out_length, sample + p, nal_length);
      p += nal_length;
    }

    running += sample_size;
    sample_in_chunk++;
    if (sample_in_chunk >= per_chunk) {
      chunk++;
      sample_in_chunk = 0;
      running = 0;
    }
  }
  free(sample);
  free(moov);
  fclose(file);
  if (!ok || (out_length == 0)) {
    free(output);
    return NULL;
  }
  *out_size = (uint64_t)out_length;
  return output;
}

// Produce the full-res H.264 Annex-B elementary stream for the player's HW-decode path. If the source is
// ALREADY decoder-compatible H.264 (8-bit yuv420p, progressive), copy its NAL units verbatim (lossless, no
// re-encode) — preferring our own ffmpeg-free MP4 demuxer, then ffmpeg stream-copy; otherwise transcode
// with libx264 (High / yuv420p). Returns malloc'd blob.
static uint8_t *prepare_h264_stream(const char *input, long max_frames, uint64_t *out_size) {
  char command[4096];
  char frames_arg[64] = "";
  *out_size = 0;

  // Preferred: our own ffmpeg-free MP4/MOV demuxer (raw NAL copy). NULL -> fall through to ffmpeg.
  uint8_t *mp4_blob = mp4_extract_h264_annexb(input, max_frames, out_size);
  if (mp4_blob) {
    fprintf(stderr, "embedding H.264 stream (pure-C MP4 demux, raw NAL copy, no ffmpeg)\n");
    return mp4_blob;
  }

  if (max_frames > 0) {   // match the wavelet stream's frame count (dual streams cover the same frames)
    snprintf(frames_arg, sizeof frames_arg, "-frames:v %ld ", max_frames);
  }

  // Probe the source video: stream-copy only if it is already H.264 / 8-bit 4:2:0 / progressive (the
  // profile the Vulkan video decoder targets); otherwise we must transcode.
  char info[256] = "";
  snprintf(command, sizeof command,
           "ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,pix_fmt,field_order -of default=noprint_wrappers=1 \"%s\"", input);
  FILE *probe = popen(command, "r");
  if (probe) {
    size_t n = fread(info, 1, sizeof(info) - 1, probe);
    info[n] = 0;
    pclose(probe);
  }
  int is_h264 = (strstr(info, "codec_name=h264") != NULL);
  int is_420_8bit = ((strstr(info, "pix_fmt=yuv420p") != NULL) && (strstr(info, "pix_fmt=yuv420p1") == NULL));   // exclude 10/12-bit
  int progressive = (((strstr(info, "field_order=") == NULL) || (strstr(info, "field_order=progressive") != NULL)) || (strstr(info, "field_order=unknown") != NULL));
  int can_copy = ((is_h264 && is_420_8bit) && progressive);

  if (can_copy) {
    fprintf(stderr, "embedding H.264 stream (raw NAL stream-copy, no re-encode)...\n");
    snprintf(command, sizeof command,
             "ffmpeg -hide_banner -loglevel error -stats -y -i \"%s\" -an %s-c:v copy -bsf:v h264_mp4toannexb -f h264 /tmp/fwv_v.h264", input, frames_arg);
  } else {
    fprintf(stderr, "encoding H.264 stream (libx264; source not copy-compatible H.264)...\n");
    snprintf(command, sizeof command,
             "ffmpeg -hide_banner -loglevel error -stats -y -i \"%s\" -an %s-c:v libx264 -profile:v high -pix_fmt yuv420p -f h264 /tmp/fwv_v.h264", input, frames_arg);
  }
  int status = system(command);
  fprintf(stderr, "\n");   // finish ffmpeg's -stats progress line
  if (status) {
    return NULL;
  }
  FILE *file = fopen("/tmp/fwv_v.h264", "rb");
  if (!file) {
    return NULL;
  }
  fseek(file, 0, SEEK_END);
  long size = ftell(file);
  fseek(file, 0, SEEK_SET);
  if (size <= 0) {
    fclose(file);
    return NULL;
  }
  uint8_t *blob = checked_malloc((size_t)size);
  if (fread(blob, 1, (size_t)size, file) != (size_t)size) {
    fclose(file);
    free(blob);
    return NULL;
  }
  fclose(file);
  *out_size = (uint64_t)size;
  return blob;
}

// Compress each frame's container payload (CPU-side, post-GPU readback). Returns the bytes written
// (= the FrameEntry.size). On-wire layout: [u8 method][u32 raw_len][data], method 1 = LZSS, 2 = LZBRRC, 0 = raw
// (incompressible fallback). --frame-codec selects LZSS (default, fast decode) or LZBRRC (~20% smaller, slow decode).
// --no-compress stores frames raw (method 0).
static int g_compress_frames = 1;
static int g_frame_codec = 0;   // 0 = LZSS (method 1, default), 1 = LZBRRC (method 2)
static size_t fwrite_frame(FILE *file, const uint8_t *payload, size_t length) {
  uint32_t raw_length = (uint32_t)length;
  uint8_t frame_header[5];
  memcpy(frame_header + 1, &raw_length, 4);
  if (g_compress_frames) {
    static uint8_t *scratch = NULL;
    static size_t scratch_capacity = 0;
    size_t needed = (length * 2) + 64;
    if (needed > scratch_capacity) {
      scratch_capacity = needed;
      scratch = realloc(scratch, scratch_capacity);
      if (!scratch) {
        die("realloc");
      }
    }
    size_t compressed;
    uint8_t method;
    if (g_frame_codec == 1) {
      compressed = lzbrrc_compress(payload, length, scratch, scratch_capacity, LZBRRC_ENCODE_LEVEL);
      method = 2;
    } else {
      compressed = lz_compress(payload, length, scratch);
      method = 1;
    }
    if (compressed < length) {
      frame_header[0] = method;
      fwrite(frame_header, 1, 5, file);
      fwrite(scratch, 1, compressed, file);
      return 5 + compressed;
    }
  }
  frame_header[0] = 0;   // --no-compress, or incompressible: stored raw (still the [method][raw_len] framing)
  fwrite(frame_header, 1, 5, file);
  fwrite(payload, 1, length, file);
  return 5 + length;
}

// append one coded frame's payload to the container and fill its explicit index entry (in
// coding order). Returns the coding index used; grows *index as needed; the caller frees the payload.
static long bframe_append(FILE *file, FrameEntry **index, long *capacity, long coding_index,
                          const uint8_t *payload, size_t length, uint32_t poc,
                          int32_t ref0, int32_t ref1, uint8_t type, uint8_t quality, uint8_t temporal_id) {
  if (coding_index >= *capacity) {
    *capacity = (*capacity) ? (*capacity * 2) : 256;
    *index = realloc(*index, (size_t)(*capacity) * sizeof(FrameEntry));
    if (!*index) {
      die("realloc");
    }
  }
  FrameEntry *entry = &(*index)[coding_index];
  entry->offset = (uint64_t)ftello(file);
  entry->poc = poc;
  entry->ref0 = ref0;
  entry->ref1 = ref1;
  entry->type = type;
  entry->quality = quality;
  entry->temporal_id = temporal_id;
  entry->pad = 0;
  entry->size = (uint32_t)fwrite_frame(file, payload, length);
  return coding_index;
}

// HDR ingest: ffmpeg rgb48le delivers the 10-bit source as (value << 6); shift it down to the codec's 12-bit
// BT.2020 code, in place. Same conversion the intra/colordiff and 3D-DWT read paths do (without it the colour
// shader sees 4x-too-large values and corrupts — the bug class the 3D-DWT path hit). Call after each B-frame read.
static void hdr_ingest_inplace(uint8_t *frame, int pixel_count) {
  uint16_t *sample = (uint16_t *)frame;
  for (int s = 0; s < (pixel_count * 3); s++) {
    sample[s] = (uint16_t)(sample[s] >> 4);
  }
}

// B-frame encode (Stage A: the validated CPU encode_frame_bidi oracle wired into the real
// container, so a B-stream actually plays; the GPU bidirectional path validates against this). OPEN-GOP
// hierarchical B: one leading I-frame, then P-anchors every `period` frames that chain across segment
// boundaries (with a periodic I-refresh every key_interval frames for seeking), and the dyadic B
// hierarchy between each anchor pair (build_b_range). The DPB holds reconstructed YCoCg per position
// within the current anchor pair [lo, hi] (slot 0 = lo anchor, slot hi = hi anchor); on each slide the
// hi anchor becomes the next lo. The index is written in CODING order with explicit poc + L0/L1
// coding-order references + temporal_id, and the player derives the blend weights back from the POCs.
static void encode_bframe_stream(FILE *input_pipe, FILE *container_file, FrameEntry **index, long *index_capacity,
                                 long *frame_index_out, unsigned long long *total_bytes_out,
                                 long *i_count_out, long *p_count_out, long *b_count_out,
                                 int width, int height, int levels, int quality, int bframes, int gop,
                                 size_t frame_bytes, long max_frames, double fps_value, long total_frames,
                                 double encode_start) {
  int period = bframes + 1;
  // Periodic I-refresh aligned to the anchor grid: round the requested keyframe interval down to a
  // multiple of period; gop <= period => only the very first frame is an I-frame (single open GOP).
  int key_interval = (gop > period) ? ((gop / period) * period) : 0;

  int plane_pixels[3];
  for (int p = 0; p < 3; p++) {
    plane_pixels[p] = plane_width(p, width) * plane_height(p, height);
  }
  // Per-position state for the current anchor pair (slots 0..period).
  uint8_t *rgb_slot[period + 1];
  int32_t *dpb[period + 1][3];   // reconstructed YCoCg per slot (the prediction references)
  long dpb_coding[period + 1];   // coding-order index of the frame currently held in each slot
  for (int s = 0; s <= period; s++) {
    rgb_slot[s] = checked_malloc(frame_bytes);
    for (int p = 0; p < 3; p++) {
      dpb[s][p] = checked_malloc((size_t)plane_pixels[p] * 4);
    }
    dpb_coding[s] = -1;
  }
  CodeStep steps[period + 1];

  long frame_index = 0;
  unsigned long long total_bytes = 0;
  long i_count = 0, p_count = 0, b_count = 0;

  if (fread(rgb_slot[0], 1, frame_bytes, input_pipe) == frame_bytes) {
    if (g_sample_bytes == 2) {   // HDR: rgb48le -> 12-bit code before encode_frame_bidi
      hdr_ingest_inplace(rgb_slot[0], width * height);
    }
    // ---- the stream's leading I-frame (poc 0, no references) ----
    uint8_t *payload;
    size_t length = encode_frame_bidi(rgb_slot[0], width, height, levels, quality, NULL, NULL, 0, 0, dpb[0], &payload);
    dpb_coding[0] = bframe_append(container_file, index, index_capacity, frame_index, payload, length,
                                  0, -1, -1, 0, (uint8_t)quality, 0);
    free(payload);
    total_bytes += length;
    frame_index++;
    i_count++;

    int lo = 0;   // global poc of the slot-0 anchor
    for (;;) {
      // Read up to `period` frames into slots 1..period (poc = lo+1 .. lo+got).
      int got = 0;
      while ((got < period) && (!max_frames || ((long)(lo + 1 + got) < max_frames))
             && (fread(rgb_slot[1 + got], 1, frame_bytes, input_pipe) == frame_bytes)) {
        got++;
      }
      if (got == 0) {
        break;
      }
      if (g_sample_bytes == 2) {   // HDR: convert each just-read anchor-pair frame to 12-bit code
        for (int i = 1; i <= got; i++) {
          hdr_ingest_inplace(rgb_slot[i], width * height);
        }
      }
      int hi = got;   // local slot of the hi anchor
      int hi_poc = lo + hi;
      int is_key = (key_interval > 0) && ((hi_poc % key_interval) == 0);

      // ---- the hi anchor: an I-refresh (seek point) or a P from the lo anchor ----
      if (is_key) {
        length = encode_frame_bidi(rgb_slot[hi], width, height, levels, quality, NULL, NULL, 0, 0, dpb[hi], &payload);
        dpb_coding[hi] = bframe_append(container_file, index, index_capacity, frame_index, payload, length,
                                       (uint32_t)hi_poc, -1, -1, 0, (uint8_t)quality, 0);
        i_count++;
      } else {
        length = encode_frame_bidi(rgb_slot[hi], width, height, levels, quality, dpb[0], NULL, 256, 0, dpb[hi], &payload);
        dpb_coding[hi] = bframe_append(container_file, index, index_capacity, frame_index, payload, length,
                                       (uint32_t)hi_poc, (int32_t)dpb_coding[0], -1, 1, (uint8_t)quality, 0);
        p_count++;
      }
      free(payload);
      total_bytes += length;
      frame_index++;

      // ---- the dyadic B hierarchy between local positions 0 (lo) and hi ----
      int count = 0;
      build_b_range(steps, &count, 0, hi, 1);
      for (int s = 0; s < count; s++) {
        int lp = steps[s].poc, r0 = steps[s].ref0, r1 = steps[s].ref1;
        length = encode_frame_bidi(rgb_slot[lp], width, height, levels, quality,
                                   dpb[r0], dpb[r1], steps[s].weight0, steps[s].weight1, dpb[lp], &payload);
        dpb_coding[lp] = bframe_append(container_file, index, index_capacity, frame_index, payload, length,
                                       (uint32_t)(lo + lp), (int32_t)dpb_coding[r0], (int32_t)dpb_coding[r1],
                                       2, (uint8_t)quality, (uint8_t)steps[s].temporal_id);
        free(payload);
        total_bytes += length;
        frame_index++;
        b_count++;
      }

      print_encode_progress(frame_index, total_frames, fps_value, now_milliseconds() - encode_start);

      // ---- slide: the hi anchor becomes the next lo (swap its slot into slot 0) ----
      for (int p = 0; p < 3; p++) {
        int32_t *swap = dpb[0][p];
        dpb[0][p] = dpb[hi][p];
        dpb[hi][p] = swap;
      }
      dpb_coding[0] = dpb_coding[hi];
      lo = hi_poc;
      if (got < period) {
        break;   // the final partial pair is done
      }
    }
  }

  for (int s = 0; s <= period; s++) {
    free(rgb_slot[s]);
    for (int p = 0; p < 3; p++) {
      free(dpb[s][p]);
    }
  }
  *frame_index_out = frame_index;
  *total_bytes_out = total_bytes;
  *i_count_out = i_count;
  *p_count_out = p_count;
  *b_count_out = b_count;
}

// Stage B1a: GPU coding-order driver. Yields one coding step per call (open-GOP hierarchical B,
// the SAME structure as encode_bframe_stream), filling rgb_dest with the step's source frame and reporting
// its references as DPB pool-slot indices (the local position within the current anchor pair: slot 0 = lo
// anchor, slot `hi` = hi anchor) PLUS the global coding index of each reference (for the explicit container
// index). When a pair finishes, *slide_from is set to the hi slot so the caller GPU-copies dpb[hi]->dpb[0]
// (the hi anchor becomes the next lo). Returns 0 at end of stream. SDR only; bframes <= 15 (slots <= 17).
typedef struct {
  FILE *pipe;
  size_t frame_bytes;
  long max_frames;
  int period, key_interval;
  uint8_t *rgb_slot[18];        // CPU source frames for the current anchor pair (period+1 <= 17)
  CodeStep step[18];            // the current pair's coding steps (local positions)
  int step_count, step_index;   // steps in the pair, and the next one to yield
  long slot_coding[18];         // global coding index currently held in each DPB pool slot
  int lo;                       // global poc of pool slot 0 (the lo anchor)
  int hi;                       // local slot of the current pair's hi anchor
  int started;                  // the leading I-frame has been emitted
} BGpuDriver;

static int bgpu_next(BGpuDriver *d, uint8_t *rgb_dest, long coding_index,
                     uint32_t *poc, int *type, int *ref0_slot, int *ref1_slot, int *dst_slot,
                     int *weight0, int *weight1, int *temporal_id, int *ref0_coding, int *ref1_coding,
                     int *slide_from) {
  *slide_from = -1;
  if (!d->started) {                                   // the stream's leading I-frame (poc 0, no references)
    if (fread(d->rgb_slot[0], 1, d->frame_bytes, d->pipe) != d->frame_bytes) {
      return 0;
    }
    if (g_sample_bytes == 2) {   // HDR: rgb48le -> 12-bit code before the colour pass reads rgb_dest
      hdr_ingest_inplace(d->rgb_slot[0], (int)(d->frame_bytes / 6));
    }
    d->started = 1;
    d->lo = 0;
    memcpy(rgb_dest, d->rgb_slot[0], d->frame_bytes);
    *poc = 0; *type = 0; *ref0_slot = -1; *ref1_slot = -1; *dst_slot = 0;
    *weight0 = 0; *weight1 = 0; *temporal_id = 0; *ref0_coding = -1; *ref1_coding = -1;
    d->slot_coding[0] = coding_index;
    return 1;
  }
  if (d->step_index >= d->step_count) {               // build the next anchor pair (read up to `period` frames)
    int got = 0;
    while ((got < d->period) && (!d->max_frames || ((long)(d->lo + 1 + got) < d->max_frames))
           && (fread(d->rgb_slot[1 + got], 1, d->frame_bytes, d->pipe) == d->frame_bytes)) {
      got++;
    }
    if (got == 0) {
      return 0;
    }
    if (g_sample_bytes == 2) {   // HDR: convert each just-read anchor-pair frame to 12-bit code
      for (int i = 1; i <= got; i++) {
        hdr_ingest_inplace(d->rgb_slot[i], (int)(d->frame_bytes / 6));
      }
    }
    d->hi = got;
    int hi_poc = d->lo + got;
    int is_key = (d->key_interval > 0) && ((hi_poc % d->key_interval) == 0);
    int count = 0;
    d->step[count++] = is_key ? (CodeStep){ got, -1, -1, 0, 0, 0 }      // I refresh (seek point)
                              : (CodeStep){ got, 0, -1, 256, 0, 0 };     // P anchor, ref0 = slot 0 (lo)
    build_b_range(d->step, &count, 0, got, 1);                          // the dyadic B hierarchy between 0 and hi
    d->step_count = count;
    d->step_index = 0;
  }
  CodeStep s = d->step[d->step_index++];
  int lp = s.poc;                                      // local position within the pair
  memcpy(rgb_dest, d->rgb_slot[lp], d->frame_bytes);
  *poc = (uint32_t)(d->lo + lp);
  *type = (s.ref0 < 0) ? 0 : ((s.ref1 < 0) ? 1 : 2);
  *ref0_slot = s.ref0; *ref1_slot = s.ref1; *dst_slot = lp;
  *weight0 = s.weight0; *weight1 = s.weight1; *temporal_id = s.temporal_id;
  *ref0_coding = (s.ref0 >= 0) ? (int)d->slot_coding[s.ref0] : -1;
  *ref1_coding = (s.ref1 >= 0) ? (int)d->slot_coding[s.ref1] : -1;
  d->slot_coding[lp] = coding_index;
  if (d->step_index >= d->step_count) {                // pair done: the hi anchor becomes the next lo
    *slide_from = d->hi;
    d->slot_coding[0] = d->slot_coding[d->hi];
    d->lo = d->lo + d->hi;
  }
  return 1;
}

// B2b: copy the just-searched motion vectors into a separate buffer so the joint refinement can
// use them as its search predictor (the refine overwrites the original buffer). Full sync around the copy.
static void snapshot_motion_vectors(VkCommandBuffer cmd, VkBuffer src, VkBuffer dst, int blocks_x, int blocks_y) {
  VkMemoryBarrier to_transfer = { VK_STRUCTURE_TYPE_MEMORY_BARRIER, 0, VK_ACCESS_SHADER_WRITE_BIT, VK_ACCESS_TRANSFER_READ_BIT };
  vkCmdPipelineBarrier(cmd, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 1, &to_transfer, 0, 0, 0, 0);
  VkBufferCopy copy = { 0, 0, (((VkDeviceSize)blocks_x * blocks_y) * 2) * 4 };
  vkCmdCopyBuffer(cmd, src, dst, 1, &copy);
  VkMemoryBarrier to_shader = { VK_STRUCTURE_TYPE_MEMORY_BARRIER, 0, VK_ACCESS_TRANSFER_WRITE_BIT, VK_ACCESS_SHADER_READ_BIT };
  vkCmdPipelineBarrier(cmd, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, 0, 1, &to_shader, 0, 0, 0, 0);
}

int main(int argc, char **argv) {
  if (argc < 2) {
    fprintf(stderr,
      "usage: %s in.(mp4|y4m) [out.fwv] [quality=8] [levels=5] [max_frames] [gop=1] [flags...]\n"
      "  with out.fwv -> write a container; otherwise run a PSNR self-test\n"
      "  quality : 0 = lossless (reversible 5/3), >=1 = lossy (9/7)\n"
      "  gop     : max keyframe interval (1 = all-intra)\n"
      "  rate control / P-frames:\n"
      "    --vbr <target_bpp>             lossy only: nudge Q per GOP toward target_bpp (per-GOP variable Q)\n"
      "    --pmode coefdiff|colordiff     P-frame method (default colordiff; coefdiff is Q0-only)\n"
      "    --pcrd[=<lambda>]              PCRD R-D bit-plane truncation (default off; lambda default 0.5)\n"
      "  hierarchical B-frames:\n"
      "    --bframes <N>                  N hierarchical bidirectional B-frames between anchors (period = N+1; default 0 = I/P only)\n"
      "    --no-per-block-mode            disable Phase 2 per-block L0/L1/BI prediction mode (default ON)\n"
      "    --bi-penalty=<N>               mode-decision bias in SAD units added to BI's cost (default -4096; negative prefers BI)\n"
      "    --no-qp-cascade                disable Phase 3 temporal-id QP-cascading (default ON, lossy B-streams: deeper B = coarser quant)\n"
      "    --joint                        EXPERIMENTAL joint/iterative bidirectional motion search (default off; ~neutral)\n"
      "    --cpu-bframes                  force the slow CPU reference B-encode oracle (instead of the GPU path)\n"
      "  coding block (entropy unit; separate from the 16x16 motion grid):\n"
      "    --block-size 32|64|128         coding/bitplane block (default 32; 64 ~ -30%% size, same PSNR, slightly coarser PCRD; 128 ~ -33%% via cooperative shaders)\n"
      "    --motion-block 8|16|32         motion block (default 16; 8 = finer motion + more MV bits, 16/32 = coarser + fewer MVs; independent of --block-size)\n"
      "    --merge-metric sad|satd        variable-motion (--motion-split) R-D merge metric (default satd; sad is faster — skips the Hadamard)\n"
      "    --motion-split                 variable per-block motion (quadtree 32->16->8, R-D); B uses the joint mode-aware merge (fast + per-leaf mode)\n"
      "    --motion-split-fast            variable motion but the single-ref 2-ME B path (slower per-8 mode_decide, weaker RD)\n"
      "    --motion-lambda-alpha N        variable-motion adaptive frame-level R-D scale (default 48; lambda = alpha*avgSAD>>8; 0 = fixed)\n"
      "    --motion-lambda N              variable-motion FIXED R-D leaf cost (SAD units; disables the adaptive frame-level lambda)\n"
      "  chroma (lossy only; Q0 stays 4:4:4):\n"
      "    --420 | --422 | --chroma-format=420|422|444   chroma subsampling (default 4:4:4)\n"
      "    --chroma[=<mult>]              coarsen chroma quant (default mult 2.0)\n"
      "  3D-DWT (open-loop temporal) mode:\n"
      "    --mode 3ddwt                   temporal 3D-DWT over the GOP\n"
      "    --twavelet haar|53|97          temporal wavelet (default haar; ignored with --mctf)\n"
      "    --temporal-levels <N>          temporal DWT levels (default 2)\n"
      "    --mctf                         motion-compensated temporal filtering (predict-only MC-Haar; SDR+HDR, 4:4:4/4:2:2/4:2:0)\n"
      "  dual video / scaling:\n"
      "    --h264                         also embed a full-res H.264 stream (player HW-decodes it where supported)\n"
      "    --scale <f>                    down-scale ONLY the wavelet stream (e.g. 0.5 or 1/4); H.264 stays full-res\n"
      "  audio / colour / misc:\n"
      "    --audio vorbis|qoa|rpcm|fwa   audio codec (default vorbis; fwa = Flexible Wavelet audio)\n"
      "    --fwa-quality N               FWA: 0 = lossless (5/3), >= 1 = lossy 9/7 (default 8)\n"
      "    --fwa-mode <m>                FWA mode: uniform|psycho|joint|packet|packet-psycho|lms (default: Q0 5/3, lossy joint-psycho)\n"
      "    --fwa-lms-taps N              FWA lms mode tap count (default 4)\n"
      "    --fwa-no-pair | --fwa-pair-ms  FWA multichannel pairing (default: adaptive pairwise M/S)\n"
      "    --hdr[=pq|hlg]                 12-bit BT.2020 HDR (transfer autodetected unless forced)\n"
      "    --frame-codec lzss|lzbrrc      per-frame compressor (default lzss = fast decode; lzbrrc = ~20%% smaller, ~37x slower decode)\n"
      "    --mv-codec golomb|range        motion-vector entropy coder (default golomb; range = adaptive binary range coder, ~-6%% file, CPU-only)\n"
      "    --no-compress                  store frames raw (no per-frame compression)\n"
      "    --debug                        extra GPU-vs-CPU validation prints\n",
      argv[0]);
    return 1;
  }
  // Pull out --vbr target_bpp; everything else is positional.
  const char *positional[16];
  int positional_count = 0;
  int vbr = 0;
  double vbr_target_bpp = 0;
  int debug = 0;              // --debug: print the per-frame P/I decision
  double pcrd_lambda = 0.0;   // --pcrd [or --pcrd=<lambda>]: PCRD R-D bit-plane truncation (default off)
  int hdr_mode = 0;           // --hdr: ingest a BT.2020 HDR source as 12-bit, tag the container HDR (default off)
  int hdr_transfer = 0;       // 0 = autodetect from the source (PQ/HLG); 16 = force PQ, 18 = force HLG
  int method = 1;   // P-frame method default: colordiff (B); --pmode coefdiff selects A (coefficient diff)
  int mode_3ddwt = 0;   // --mode 3ddwt: open-loop temporal 3D-DWT GOP mode
  int bframes = 0;      // --bframes N: N hierarchical B-frames between anchors (0 = off, I/P only)
  int cpu_bframes = 0;  // --cpu-bframes: force the CPU encode_frame_bidi oracle path (Stage A) instead of the GPU bidi path
  int joint_mv = 0;     // --joint: B2b joint/iterative bidirectional motion (EXPERIMENTAL, currently regresses vs independent); default = B2a independent
  int per_block_mode = 1;   // Phase 2 per-block L0/L1/BI prediction mode (default ON; --no-per-block-mode = always-BI)
  int bi_penalty = -4096;   // --bi-penalty=N: mode-decision bias (SAD units) added to BI's cost; negative = prefer BI (it averages noise / costs no extra residual since 2a always sends both MVs); tunable
  int qp_cascade = 1;       // Phase 3: deeper B-frames (higher temporal_id) get a coarser quant (lossy B-streams). Default ON (BeRo live-OK'd, big RD win); --no-qp-cascade disables
  int audio_codec_choice = 0;   // --audio: 0 = OGG/Vorbis (default), 1 = QOA-LE ("qoal"), 2 = RPCM (raw s16), 3 = FWA (wavelet)
  int fwa_quality = 8;            // --fwa-quality (default 8 = lossy joint-psycho; 0 = lossless 5/3)
  const char *fwa_mode = NULL;    // --fwa-mode (NULL -> derive: Q0 = 5/3, Q>0 = joint-psycho)
  int fwa_lms_taps = 4;           // --fwa-lms-taps (lms mode)
  int fwa_no_pair = 0, fwa_pair_ms = 0;   // multichannel pairing overrides (default: adaptive pairwise M/S)
  int want_h264 = 0;            // --h264: also embed a full-res H.264 Annex-B elementary stream
  double wavelet_scale = 1.0;   // --scale: down-scale ONLY the wavelet stream (e.g. 0.5 or 1/4)
  for (int i = 0; i < argc; i++) {
    if (!strcmp(argv[i], "--vbr") && (i + 1) < argc) {
      vbr = 1;
      vbr_target_bpp = atof(argv[++i]);
    } else if (!strcmp(argv[i], "--mode") && (i + 1) < argc) {
      mode_3ddwt = strstr(argv[++i], "3d") ? 1 : 0;
    } else if (!strcmp(argv[i], "--bframes") && (i + 1) < argc) {
      bframes = atoi(argv[++i]);   // N hierarchical B-frames between anchors (period = N+1)
    } else if (!strcmp(argv[i], "--cpu-bframes")) {
      cpu_bframes = 1;             // force the CPU encode_frame_bidi oracle (Stage A) instead of the GPU bidi path
    } else if (!strcmp(argv[i], "--joint")) {
      joint_mv = 1;               // EXPERIMENTAL B2b joint/iterative bidirectional motion refinement (currently regresses)
    } else if (!strcmp(argv[i], "--per-block-mode")) {
      per_block_mode = 1;         // Phase 2: per-block L0/L1/BI prediction mode (now the default; kept as a no-op alias)
    } else if (!strcmp(argv[i], "--no-per-block-mode")) {
      per_block_mode = 0;         // force the old always-BI B-prediction
    } else if (!strcmp(argv[i], "--qp-cascade")) {
      qp_cascade = 1;             // Phase 3: temporal-id QP-cascading on B-frames (now the default; kept as a no-op alias)
    } else if (!strcmp(argv[i], "--no-qp-cascade")) {
      qp_cascade = 0;             // force a flat quant across the B-hierarchy
    } else if (!strncmp(argv[i], "--bi-penalty=", 13)) {
      bi_penalty = atoi(argv[i] + 13);   // tune the BI R-D penalty
    } else if (!strcmp(argv[i], "--twavelet") && (i + 1) < argc) {
      const char *value = argv[++i];
      g_temporal_wavelet = strstr(value, "97") ? 2 : (strstr(value, "53") ? 1 : 0);
    } else if (!strcmp(argv[i], "--temporal-levels") && (i + 1) < argc) {
      g_temporal_levels = atoi(argv[++i]);
    } else if (!strcmp(argv[i], "--mctf")) {
      g_mctf = 1;                 // 3D-DWT mode: motion-compensated temporal filtering (predict-only MC-Haar) instead of open-loop
    } else if (!strcmp(argv[i], "--block-size") && (i + 1) < argc) {
      int bs = atoi(argv[++i]);   // coding block 32|64|128 (bigger = smaller; 128 uses the cooperative shaders)
      if ((bs == 32 || bs == 64) || bs == 128) {
        g_block_size = bs;
      }
    } else if (!strcmp(argv[i], "--motion-block") && (i + 1) < argc) {
      int mb = atoi(argv[++i]);   // motion block 8|16|32 (smaller = finer motion + more MV bits; bigger = coarser, fewer MVs)
      if ((mb == 8 || mb == 16) || mb == 32) {
        g_motion_block = mb;
      }
    } else if (!strcmp(argv[i], "--merge-metric") && (i + 1) < argc) {
      g_merge_satd = strstr(argv[++i], "sad") ? 0 : 1;   // variable-motion merge residual cost: sad (faster) or satd (default, better R-D)
    } else if (!strcmp(argv[i], "--no-compress")) {
      g_compress_frames = 0;   // store frames raw (no per-frame compression)
    } else if (!strcmp(argv[i], "--frame-codec") && (i + 1) < argc) {
      g_frame_codec = strstr(argv[++i], "lzbrrc") ? 1 : 0;   // frame compressor: lzss (default, fast decode) or lzbrrc (~20% smaller, slow decode)
    } else if (!strcmp(argv[i], "--mv-codec") && (i + 1) < argc) {
      g_mv_codec = strstr(argv[++i], "range") ? 1 : 0;   // MV entropy coder: golomb (default) or range (~-6% file, CPU-only)
    } else if (!strcmp(argv[i], "--motion-split")) {   // variable per-block motion (quadtree 32->16->8, R-D); B uses the joint mode-aware merge by default
      g_motion_variable = 1;
      g_motion_block = 8;
    } else if (!strcmp(argv[i], "--motion-split-fast")) {   // variable motion + the fast single-ref 2-ME B path (no joint merge)
      g_motion_variable = 1;
      g_motion_block = 8;
      g_motion_split_bidi = 0;
    } else if (!strcmp(argv[i], "--bidi-merge")) {   // explicit joint mode-aware B merge (now the default; kept as an alias)
      g_motion_split_bidi = 1;
    } else if (!strcmp(argv[i], "--motion-lambda-alpha") && (i + 1) < argc) {
      g_motion_lambda_alpha = atoi(argv[++i]);   // adaptive frame-level scale (lambda_abs = alpha*avgSAD>>8)
    } else if (!strcmp(argv[i], "--motion-lambda") && (i + 1) < argc) {
      g_motion_lambda_abs = atoi(argv[++i]);   // FIXED absolute leaf cost (disables adaptive)
      g_motion_lambda_alpha = 0;
    } else if (!strcmp(argv[i], "--audio") && (i + 1) < argc) {
      const char *value = argv[++i];   // --audio vorbis|qoa|rpcm|fwa
      audio_codec_choice = strstr(value, "fwa") ? 3 : (strstr(value, "qoa") ? 1 : (strstr(value, "rpcm") ? 2 : 0));
    } else if (!strcmp(argv[i], "--fwa-quality") && (i + 1) < argc) {
      fwa_quality = atoi(argv[++i]);   // FWA: 0 = lossless 5/3, >= 1 = lossy 9/7
    } else if (!strcmp(argv[i], "--fwa-mode") && (i + 1) < argc) {
      fwa_mode = argv[++i];            // uniform|psycho|joint|packet|packet-psycho|lms
    } else if (!strcmp(argv[i], "--fwa-lms-taps") && (i + 1) < argc) {
      fwa_lms_taps = atoi(argv[++i]);
    } else if (!strcmp(argv[i], "--fwa-no-pair")) {
      fwa_no_pair = 1;                 // multichannel: independent channels (no pairwise M/S)
    } else if (!strcmp(argv[i], "--fwa-pair-ms")) {
      fwa_pair_ms = 1;                 // multichannel: force always-M/S pairs (not adaptive)
    } else if (!strcmp(argv[i], "--h264")) {
      want_h264 = 1;   // also embed a full-res H.264 elementary stream (HW-decode path in the player)
    } else if (!strcmp(argv[i], "--scale") && (i + 1) < argc) {
      const char *value = argv[++i];   // "0.5" or "1/4" -> down-scale the wavelet stream only
      const char *slash = strchr(value, '/');
      if (slash) {
        double numerator = atof(value);
        double denominator = atof(slash + 1);
        wavelet_scale = (denominator != 0.0) ? (numerator / denominator) : 1.0;
      } else {
        wavelet_scale = atof(value);
      }
      if ((wavelet_scale <= 0.0) || (wavelet_scale > 1.0)) {
        wavelet_scale = 1.0;   // ignore nonsense / upscaling
      }
    } else if (!strcmp(argv[i], "--pmode") && (i + 1) < argc) {
      method = strstr(argv[++i], "coef") ? 0 : 1;   // "coefdiff" -> A, anything else ("colordiff") -> B
    } else if (!strncmp(argv[i], "--pcrd", 6)) {
      pcrd_lambda = (argv[i][6] == '=') ? atof(argv[i] + 7) : 0.5;   // 0.5 = a moderate default
    } else if (!strncmp(argv[i], "--chroma-format", 15)) {   // --chroma-format=420|422|444 (must precede --chroma, which is a prefix)
      g_chroma_format = strstr(argv[i], "420") ? 2 : (strstr(argv[i], "422") ? 1 : 0);
    } else if (!strcmp(argv[i], "--420")) {
      g_chroma_format = 2;
    } else if (!strcmp(argv[i], "--422")) {
      g_chroma_format = 1;
    } else if (!strncmp(argv[i], "--chroma", 8)) {
      g_chroma_quant = (argv[i][8] == '=') ? (float)atof(argv[i] + 9) : 2.0f;   // coarsen chroma quant (2.0 = moderate default)
    } else if (!strcmp(argv[i], "--debug")) {
      debug = 1;
    } else if (!strncmp(argv[i], "--hdr", 5)) {
      hdr_mode = 1;   // 12-bit BT.2020 HDR; the transfer (PQ/HLG) is autodetected unless forced here
      if (strstr(argv[i], "hlg")) {
        hdr_transfer = 18;        // --hdr=hlg
      } else if (strstr(argv[i], "pq")) {
        hdr_transfer = 16;        // --hdr=pq
      }
    } else if (positional_count < 16) {
      positional[positional_count++] = argv[i];
    }
  }
  const char *input = positional[1];
  const char *output = NULL;
  int argument = 2;
  if (positional_count > 2 && (strstr(positional[2], ".fwv") || strstr(positional[2], ".FWV"))) {   // accept .FWV too
    output = positional[2];
    argument = 3;
  }
  int quality = (positional_count > argument) ? atoi(positional[argument]) : 8;
  int levels = (positional_count > (argument + 1)) ? atoi(positional[argument + 1]) : 5;
  long max_frames = (positional_count > (argument + 2)) ? atol(positional[argument + 2]) : (output ? 0 : 4);
  int gop = (positional_count > (argument + 3)) ? atoi(positional[argument + 3]) : 1;   // max keyframe interval
  if (mode_3ddwt) {   // 3D-DWT GOP mode: the gop arg is the temporal decode unit (default 16, cap MAX_GOP)
    if (gop < 2) {
      gop = 16;
    }
    if (gop > MAX_GOP) {
      gop = MAX_GOP;
    }
    if (g_temporal_levels < 1) {
      g_temporal_levels = 1;
    }
    if (g_temporal_levels > 6) {
      g_temporal_levels = 6;
    }
  }
  if (!mode_3ddwt) {
    g_mctf = 0;   // MCTF (motion-compensated temporal filtering) only applies to the 3D-DWT GOP mode
  }
  set_sample_mode(hdr_mode ? 1 : 0);   // HDR (PQ or HLG) is 12-bit unsigned; SDR is 8-bit. Sets g_sample_* + quant scale.
  if (hdr_mode && hdr_transfer == 0) {   // autodetect PQ (smpte2084) vs HLG (arib-std-b67) from the source
    char probe_cmd[1024];
    snprintf(probe_cmd, sizeof probe_cmd,
             "ffprobe -v error -select_streams v:0 -show_entries stream=color_transfer -of default=noprint_wrappers=1:nokey=1 \"%s\"", input);
    FILE *probe = popen(probe_cmd, "r");
    char transfer_name[64] = "";
    if (probe) {
      if (!fgets(transfer_name, sizeof transfer_name, probe)) { transfer_name[0] = 0; }
      pclose(probe);
    }
    hdr_transfer = strstr(transfer_name, "arib-std-b67") ? 18 : 16;   // HLG, else PQ (default)
    fprintf(stderr, "HDR: detected transfer %s -> %s\n", transfer_name, (hdr_transfer == 18) ? "HLG" : "PQ");
  }

  int width;
  int height;
  if (probe_video_dimensions(input, &width, &height) != 0) {
    die("ffprobe failed");
  }
  int source_width = width, source_height = height;   // full-res, for the optional H.264 stream
  if (wavelet_scale < 1.0) {   // --scale: the wavelet stream is encoded at a reduced resolution
    int scaled_w = (int)((width * wavelet_scale) + 0.5) & ~1;     // keep dims even (chroma subsampling)
    int scaled_h = (int)((height * wavelet_scale) + 0.5) & ~1;
    if (scaled_w < 16) {
      scaled_w = 16;
    }
    if (scaled_h < 16) {
      scaled_h = 16;
    }
    width = scaled_w;
    height = scaled_h;
    fprintf(stderr, "wavelet scale %.4g -> %dx%d (H.264 stays %dx%d)\n", wavelet_scale, width, height, source_width, source_height);
  }
  // Frame rate (for the container header).
  unsigned fps_num = 30, fps_den = 1;
  {
    char command[4096];
    snprintf(command, sizeof command, "ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of csv=p=0 \"%s\"", input);
    FILE *probe = popen(command, "r");
    char text[64] = "";
    if (probe) {
      if (!fgets(text, sizeof text, probe)) {
        text[0] = 0;
      }
      pclose(probe);
    }
    sscanf(text, "%u/%u", &fps_num, &fps_den);
  }
  int level_limit = maximum_levels(width, height);
  if (levels > level_limit) {
    levels = level_limit;
  }
  if (levels < 1) {
    levels = 1;
  }
  if (quality < 0) {
    quality = 0;
  }
  int lossless = (quality == 0);   // Q0 = reversible integer 5/3, no quant
  if (lossless) {
    g_chroma_format = 0;   // lossless stays 4:4:4 (the codec only subsamples chroma in the lossy path)
  }
  // hierarchical B-frames (--bframes N). Stage A wires the validated CPU encode_frame_bidi
  // oracle into the real container (SDR colordiff only; mutually exclusive with the 3D-DWT GOP mode).
  int use_bframes = (bframes >= 1) && !mode_3ddwt;
  if (use_bframes) {
    if (bframes > 15) {
      bframes = 15;   // period <= 16: keeps the per-pair DPB / hierarchy depth sane
    }
    if (!output) {
      die("--bframes requires a container output (in.mp4 out.fwv ...)");
    }
    method = 1;   // B-frames live on the colordiff path; coefdiff (A) is not supported
    if (gop < (bframes + 1)) {
      gop = 0;   // gop too small to host an anchor refresh -> a single open GOP (only the first frame is I)
    }
  }
  int blocks_x = block_count_x(width);
  int blocks_y = block_count_y(height);
  int block_count = blocks_x * blocks_y;
  int pixel_count = width * height;

  // ---- Vulkan instance, device and compute queue ----
  VkApplicationInfo application_info = { VK_STRUCTURE_TYPE_APPLICATION_INFO };
  application_info.apiVersion = VK_API_VERSION_1_1;
  VkInstanceCreateInfo instance_info = { VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO };
  instance_info.pApplicationInfo = &application_info;
  VkInstance instance;
  VK_CHECK(vkCreateInstance(&instance_info, 0, &instance));

  uint32_t device_count = 0;
  vkEnumeratePhysicalDevices(instance, &device_count, 0);
  VkPhysicalDevice *devices = checked_malloc(device_count * sizeof(*devices));
  vkEnumeratePhysicalDevices(instance, &device_count, devices);
  physical_device = devices[0];
  VkPhysicalDeviceProperties device_properties;
  vkGetPhysicalDeviceProperties(physical_device, &device_properties);

  uint32_t queue_family_count = 0;
  vkGetPhysicalDeviceQueueFamilyProperties(physical_device, &queue_family_count, 0);
  VkQueueFamilyProperties *queue_families = checked_malloc(queue_family_count * sizeof(*queue_families));
  vkGetPhysicalDeviceQueueFamilyProperties(physical_device, &queue_family_count, queue_families);
  uint32_t queue_family_index = 0;
  for (uint32_t i = 0; i < queue_family_count; i++) {
    if (queue_families[i].queueFlags & VK_QUEUE_COMPUTE_BIT) {
      queue_family_index = i;
      break;
    }
  }

  float queue_priority = 1;
  VkDeviceQueueCreateInfo queue_info = { VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO };
  queue_info.queueFamilyIndex = queue_family_index;
  queue_info.queueCount = 1;
  queue_info.pQueuePriorities = &queue_priority;
  VkDeviceCreateInfo device_info = { VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO };
  device_info.queueCreateInfoCount = 1;
  device_info.pQueueCreateInfos = &queue_info;
  VK_CHECK(vkCreateDevice(physical_device, &device_info, 0, &device));
  vkGetDeviceQueue(device, queue_family_index, 0, &queue);
  printf("fwvenc GPU: %s | %dx%d quality=%d levels=%d | %d blocks\n",
         device_properties.deviceName, width, height, quality, levels, block_count);

  // ---- buffers ----
  size_t plane_bytes = (size_t)pixel_count * 4;
  size_t data_capacity = ((size_t)pixel_count * 4) + ((size_t)block_count * 16);
  VkBuffer rgb_buffer, coeff_buffer[3], scratch_buffer, step_buffer[3], size_buffer[3], offset_buffer[3], data_buffer;
  VkBuffer previous_buffer[3], difference_buffer[3];   // P-frame coefficient reference + difference
  VkBuffer size_buffer_diff[3];                        // P-frame: packed block sizes of the difference (for the I/P decision)
  VkBuffer energy_buffer;                               // colordiff: single host-visible L1-residual counter (scene-cut detect)
  VkBuffer mv_buffer;                                   // motion: per-block [mv_x, mv_y] (half-pel) — the fine 8-grid in variable mode
  VkBuffer mv_prev_buffer;                              // previous frame's MVs (temporal predictor; device-local snapshot of mv_buffer)
  VkBuffer sad_buffer;                                  // motion_estimate SAD output (binding 8); fixed/B bind+ignore it, the variable R-D merge reads it as sad8
  VkBuffer mv8_buffer = 0, mv16_buffer = 0, mv32_buffer = 0, sad16_buffer = 0, sad32_buffer = 0;   // variable motion: per-size ME outputs
  VkBuffer mv8_prev_buffer = 0, mv16_prev_buffer = 0, mv32_prev_buffer = 0;   // variable motion: per-size previous-frame MVs (temporal predictor)
  VkBuffer mv1_8_buffer = 0, mv1_16_buffer = 0, mv1_32_buffer = 0;            // variable B: per-size L1 (vs ref1) ME outputs
  VkBuffer modesad8_buffer = 0, modesad16_buffer = 0, modesad32_buffer = 0;   // variable B: per-size [sadL0,sadL1,sadBI] from bidi_mode_sad
  VkDeviceMemory rgb_memory, coeff_memory[3], scratch_memory, step_memory[3], size_memory[3], offset_memory[3], data_memory;
  VkDeviceMemory previous_memory[3], difference_memory[3], size_memory_diff[3], energy_memory, mv_memory, mv_prev_memory, sad_memory;
  VkDeviceMemory mv8_memory = 0, mv16_memory = 0, mv32_memory = 0, sad16_memory = 0, sad32_memory = 0;
  VkDeviceMemory mv8_prev_memory = 0, mv16_prev_memory = 0, mv32_prev_memory = 0;
  VkDeviceMemory mv1_8_memory = 0, mv1_16_memory = 0, mv1_32_memory = 0, modesad8_memory = 0, modesad16_memory = 0, modesad32_memory = 0;
  create_buffer((size_t)pixel_count * (hdr_mode ? 6 : 4), HOST_VISIBLE_COHERENT, &rgb_buffer, &rgb_memory);
  for (int plane = 0; plane < 3; plane++) {
    create_buffer(plane_bytes, DEVICE_LOCAL, &coeff_buffer[plane], &coeff_memory[plane]);
    create_buffer(plane_bytes, DEVICE_LOCAL, &previous_buffer[plane], &previous_memory[plane]);
    create_buffer(plane_bytes, DEVICE_LOCAL, &difference_buffer[plane], &difference_memory[plane]);
    create_buffer((size_t)block_count * 4, HOST_VISIBLE_COHERENT, &size_buffer[plane], &size_memory[plane]);
    create_buffer((size_t)block_count * 4, HOST_VISIBLE_COHERENT, &size_buffer_diff[plane], &size_memory_diff[plane]);
    create_buffer((size_t)block_count * 4, HOST_VISIBLE_COHERENT, &offset_buffer[plane], &offset_memory[plane]);
    create_buffer(plane_bytes, HOST_VISIBLE_COHERENT, &step_buffer[plane], &step_memory[plane]);   // per-plane quant map (chroma subsampled -> its own subband layout)
  }
  // DWT transpose scratch: a W x H plane is transposed to H x W and stored with row stride
  // max(W,H), spanning max(W,H) rows -> max(W,H)^2 elements. Sizing this at pixel_count (W*H) is too
  // small for non-square planes (1920x1080 needs 1920^2, not 1920*1080), so the transpose wrote/read
  // out of bounds and zeroed the right columns — which broke the lossless (5/3) path.
  size_t scratch_side = (size_t)((width > height) ? width : height);
  create_buffer(((scratch_side * scratch_side) * 4), DEVICE_LOCAL, &scratch_buffer, &scratch_memory);
  create_buffer(data_capacity, HOST_VISIBLE_COHERENT, &data_buffer, &data_memory);
  create_buffer(4, HOST_VISIBLE_COHERENT, &energy_buffer, &energy_memory);
  int motion_blocks_x = ((width + g_motion_block) - 1) / g_motion_block, motion_blocks_y = ((height + g_motion_block) - 1) / g_motion_block;
  create_buffer((((size_t)motion_blocks_x * motion_blocks_y) * 2) * 4, HOST_VISIBLE_COHERENT, &mv_buffer, &mv_memory);
  create_buffer((((size_t)motion_blocks_x * motion_blocks_y) * 2) * 4, DEVICE_LOCAL, &mv_prev_buffer, &mv_prev_memory);
  create_buffer(((size_t)motion_blocks_x * motion_blocks_y) * 4, HOST_VISIBLE_COHERENT, &sad_buffer, &sad_memory);   // ME SAD output (binding 8)
  if (g_motion_variable) {   // variable mode: motion_blocks here is the fine 8-grid; per-size ME outputs feed the R-D merge
    create_buffer((((size_t)motion_blocks_x * motion_blocks_y) * 2) * 4, DEVICE_LOCAL, &mv8_buffer, &mv8_memory);
    create_buffer((((size_t)motion_blocks_x * motion_blocks_y) * 2) * 4, DEVICE_LOCAL, &mv16_buffer, &mv16_memory);
    create_buffer((((size_t)motion_blocks_x * motion_blocks_y) * 2) * 4, DEVICE_LOCAL, &mv32_buffer, &mv32_memory);
    create_buffer(((size_t)motion_blocks_x * motion_blocks_y) * 4, DEVICE_LOCAL, &sad16_buffer, &sad16_memory);
    create_buffer(((size_t)motion_blocks_x * motion_blocks_y) * 4, HOST_VISIBLE_COHERENT, &sad32_buffer, &sad32_memory);   // host reads avg 32-SAD for the adaptive frame-level lambda
    // Per-size temporal predictors (previous frame's MVs), copied from mvN after each frame's merge. Zeroed
    // initially (host-visible) so the first predicted frame predicts from zero, exactly like the fixed path.
    VkBuffer *prev_b[3] = { &mv8_prev_buffer, &mv16_prev_buffer, &mv32_prev_buffer };
    VkDeviceMemory *prev_m[3] = { &mv8_prev_memory, &mv16_prev_memory, &mv32_prev_memory };
    for (int s = 0; s < 3; s++) {
      create_buffer((((size_t)motion_blocks_x * motion_blocks_y) * 2) * 4, HOST_VISIBLE_COHERENT, prev_b[s], prev_m[s]);
      void *map;
      VK_CHECK(vkMapMemory(device, *prev_m[s], 0, VK_WHOLE_SIZE, 0, &map));
      memset(map, 0, (((size_t)motion_blocks_x * motion_blocks_y) * 2) * 4);
      vkUnmapMemory(device, *prev_m[s]);
    }
    if (use_bframes && g_motion_split_bidi) {   // variable B (joint): per-size L1 MV outputs + the 3-mode SAD buffers (3 ints/block)
      create_buffer((((size_t)motion_blocks_x * motion_blocks_y) * 2) * 4, DEVICE_LOCAL, &mv1_8_buffer, &mv1_8_memory);
      create_buffer((((size_t)motion_blocks_x * motion_blocks_y) * 2) * 4, DEVICE_LOCAL, &mv1_16_buffer, &mv1_16_memory);
      create_buffer((((size_t)motion_blocks_x * motion_blocks_y) * 2) * 4, DEVICE_LOCAL, &mv1_32_buffer, &mv1_32_memory);
      create_buffer((((size_t)motion_blocks_x * motion_blocks_y) * 3) * 4, DEVICE_LOCAL, &modesad8_buffer, &modesad8_memory);
      create_buffer((((size_t)motion_blocks_x * motion_blocks_y) * 3) * 4, DEVICE_LOCAL, &modesad16_buffer, &modesad16_memory);
      create_buffer((((size_t)motion_blocks_x * motion_blocks_y) * 3) * 4, DEVICE_LOCAL, &modesad32_buffer, &modesad32_memory);
    }
  }

  // Stage B1a: the GPU DPB — a bounded pool of reconstructed-YCoCg reference buffer sets, one
  // per position within the current anchor pair (slot 0 = lo anchor, slot `period` = hi anchor). The
  // coding-order driver reconstructs each frame into its slot; the bidi blend reads two slots.
  int dpb_slots = use_bframes ? (bframes + 2) : 0;   // period + 1, with one spare
  VkBuffer dpb_buffer[18][3];
  VkDeviceMemory dpb_memory[18][3];
  for (int slot = 0; slot < dpb_slots; slot++) {
    for (int plane = 0; plane < 3; plane++) {
      create_buffer(plane_bytes, DEVICE_LOCAL, &dpb_buffer[slot][plane], &dpb_memory[slot][plane]);
    }
  }
  // Stage B2: bidirectional motion. mv1 = the L1 motion vectors (mv_buffer is L0); mv_zero is a
  // zeroed temporal predictor for the B searches; mc1 holds the L1 motion-compensated prediction (the L0
  // mc reuses difference_buffer, then bidi_blend combines them in place).
  VkBuffer mv1_buffer = 0, mv_zero_buffer = 0, mv_snap_buffer = 0, mode_buffer = 0, mc1_buffer[3] = { 0, 0, 0 };
  VkDeviceMemory mv1_memory = 0, mv_zero_memory = 0, mv_snap_memory = 0, mode_memory = 0, mc1_memory[3] = { 0, 0, 0 };
  void *mv1_map = 0, *mv_zero_map = 0, *mode_map = 0;
  if (use_bframes) {
    create_buffer((((size_t)motion_blocks_x * motion_blocks_y) * 2) * 4, HOST_VISIBLE_COHERENT, &mv1_buffer, &mv1_memory);
    create_buffer((((size_t)motion_blocks_x * motion_blocks_y) * 2) * 4, HOST_VISIBLE_COHERENT, &mv_zero_buffer, &mv_zero_memory);
    create_buffer((((size_t)motion_blocks_x * motion_blocks_y) * 2) * 4, DEVICE_LOCAL, &mv_snap_buffer, &mv_snap_memory);   // B2b: snapshot of the independent MV, used as the joint-search predictor
    create_buffer(((size_t)motion_blocks_x * motion_blocks_y) * 4, HOST_VISIBLE_COHERENT, &mode_buffer, &mode_memory);   // Phase 2: one prediction mode per 16x16 block
    VK_CHECK(vkMapMemory(device, mv1_memory, 0, VK_WHOLE_SIZE, 0, &mv1_map));
    VK_CHECK(vkMapMemory(device, mv_zero_memory, 0, VK_WHOLE_SIZE, 0, &mv_zero_map));
    VK_CHECK(vkMapMemory(device, mode_memory, 0, VK_WHOLE_SIZE, 0, &mode_map));
    memset(mv_zero_map, 0, (((size_t)motion_blocks_x * motion_blocks_y) * 2) * 4);   // zero L1/L0 temporal predictor for B
    for (int plane = 0; plane < 3; plane++) {
      create_buffer(plane_bytes, DEVICE_LOCAL, &mc1_buffer[plane], &mc1_memory[plane]);
    }
  }

  void *rgb_map, *step_map[3], *size_map[3], *size_map_diff[3], *offset_map[3], *data_map, *energy_map, *mv_map;
  void *sad32_map = 0;   // variable motion: the host reads the @32 SADs to set the next frame's adaptive lambda
  int prev_avg_sad = 0;  // average 32-block SAD of the previous frame (drives the adaptive frame-level lambda; 0 for frame 1)
  if (g_motion_variable) {
    VK_CHECK(vkMapMemory(device, sad32_memory, 0, VK_WHOLE_SIZE, 0, &sad32_map));
  }
  VK_CHECK(vkMapMemory(device, energy_memory, 0, VK_WHOLE_SIZE, 0, &energy_map));
  VK_CHECK(vkMapMemory(device, mv_memory, 0, VK_WHOLE_SIZE, 0, &mv_map));
  memset(mv_map, 0, (((size_t)motion_blocks_x * motion_blocks_y) * 2) * 4);   // all-zero MVs (mc_prev == prev when there is no motion)
  VK_CHECK(vkMapMemory(device, rgb_memory, 0, VK_WHOLE_SIZE, 0, &rgb_map));
  for (int plane = 0; plane < 3; plane++) {
    VK_CHECK(vkMapMemory(device, step_memory[plane], 0, VK_WHOLE_SIZE, 0, &step_map[plane]));
  }
  for (int plane = 0; plane < 3; plane++) {
    VK_CHECK(vkMapMemory(device, size_memory[plane], 0, VK_WHOLE_SIZE, 0, &size_map[plane]));
    VK_CHECK(vkMapMemory(device, size_memory_diff[plane], 0, VK_WHOLE_SIZE, 0, &size_map_diff[plane]));
    VK_CHECK(vkMapMemory(device, offset_memory[plane], 0, VK_WHOLE_SIZE, 0, &offset_map[plane]));
  }
  VK_CHECK(vkMapMemory(device, data_memory, 0, VK_WHOLE_SIZE, 0, &data_map));

  // ---- pipelines ----
  VkDescriptorSetLayout layout_1_buffer = create_descriptor_set_layout(1);
  VkDescriptorSetLayout layout_2_buffers = create_descriptor_set_layout(2);
  VkDescriptorSetLayout layout_3_buffers = create_descriptor_set_layout(3);
  VkDescriptorSetLayout layout_9_buffers = create_descriptor_set_layout(9);   // 3-plane predictive motion search: {cur0..2, prev0..2, mv, mv_prev, sad}
  VkDescriptorSetLayout layout_7_buffers = create_descriptor_set_layout(7);   // variable-motion R-D merge: {mv8, sad8, mv16, sad16, mv32, sad32, mv_out}
  VkDescriptorSetLayout layout_12_buffers = create_descriptor_set_layout(12);   // variable B: bidi_mode_sad {cur0..2,ref0_0..2,ref1_0..2,mv0,mv1,modesad} + merge_bidi {modesad8/16/32,mv0_8/16/32,mv1_8/16/32,mv0out,mv1out,modeout}
  VkDescriptorSetLayout layout_11_buffers = create_descriptor_set_layout(11);  // B2b joint search: {cur0..2, ref0..2, mc_other0..2, mv, mv_prev}
  VkDescriptorSetLayout layout_10_buffers = create_descriptor_set_layout(10);  // Phase 2 mode_decide: {cur0..2, mc0_0..2, mc1_0..2, modes}
  VkDescriptorSetLayout layout_colour = create_descriptor_set_layout(4);
  VkPipelineLayout pipeline_layout_colour = create_pipeline_layout(layout_colour, 8);
  VkPipelineLayout pipeline_layout_transpose = create_pipeline_layout(layout_2_buffers, 16);
  VkPipelineLayout pipeline_layout_row = create_pipeline_layout(layout_1_buffer, 16);
  VkPipelineLayout pipeline_layout_quant = create_pipeline_layout(layout_2_buffers, 8);   // { pixel_count, chroma_multiplier }
  VkPipelineLayout pipeline_layout_chroma_downsample = create_pipeline_layout(layout_2_buffers, 16);   // { frame_width, frame_height, shift_x, shift_y }
  VkPipelineLayout pipeline_layout_size = create_pipeline_layout(layout_2_buffers, 16);
  VkPipelineLayout pipeline_layout_pack = create_pipeline_layout(layout_3_buffers, 16);
  VkPipelineLayout pipeline_layout_coeff_diff = create_pipeline_layout(layout_3_buffers, 4);
  VkPipelineLayout pipeline_layout_motion_estimate = create_pipeline_layout(layout_9_buffers, 16);
  VkPipelineLayout pipeline_layout_merge = create_pipeline_layout(layout_7_buffers, 28);   // variable-motion R-D merge: push {fgx,fgy,g16x,g16y,g32x,g32y,lambda_abs}
  VkPipelineLayout pipeline_layout_bidi_sad = create_pipeline_layout(layout_12_buffers, 24);   // variable B bidi_mode_sad: push {w,h,blocks_x,lossless,weight0,weight1}
  VkPipelineLayout pipeline_layout_merge_bidi = create_pipeline_layout(layout_12_buffers, 28);  // variable B merge: push {fgx,fgy,g16x,g16y,g32x,g32y,lambda_abs}

  VkPipeline pipeline_colour_97 = create_compute_pipeline("shaders/rgb2yco.spv", pipeline_layout_colour);
  VkPipeline pipeline_transpose = create_compute_pipeline("shaders/transpose_f.spv", pipeline_layout_transpose);
  VkPipeline pipeline_forward_row_97 = create_compute_pipeline("shaders/fwd97row.spv", pipeline_layout_row);
  VkPipeline pipeline_quant = create_compute_pipeline("shaders/quant97fwd.spv", pipeline_layout_quant);
  VkPipeline pipeline_chroma_downsample = create_compute_pipeline("shaders/chroma_downsample.spv", pipeline_layout_chroma_downsample);   // box-average Co/Cg to subsampled size (Variante A; float 9/7 path)
  VkPipeline pipeline_chroma_downsample_int = create_compute_pipeline_bs("shaders/chroma_downsample.spv", pipeline_layout_chroma_downsample, 1);   // INT_MODE=1: integer box-average for the MCTF path (gop is integer YCoCg)
  // 128 uses the cooperative shaders (one workgroup/block + shared-memory pyramid) so the few large blocks
  // don't watchdog-timeout the GPU; 32/64 keep the cheaper one-thread-per-block path.
  VkPipeline pipeline_size = create_compute_pipeline_bs((g_block_size == 128) ? "shaders/bitplane_size_coop.spv" : "shaders/bitplane_size.spv", pipeline_layout_size, g_block_size);
  VkPipeline pipeline_pack = create_compute_pipeline_bs((g_block_size == 128) ? "shaders/bitplane_pack_coop.spv" : "shaders/bitplane_pack.spv", pipeline_layout_pack, g_block_size);
  VkPipeline pipeline_coeff_diff = create_compute_pipeline("shaders/coeff_diff.spv", pipeline_layout_coeff_diff);
  // MCTF lossy: convert the integer temporal-subband coefficients to float bit-patterns before the 9/7 spatial
  // (reuses pipeline_layout_row = 1 buffer + push). Only used for g_mctf && !lossless.
  VkPipeline pipeline_int2float = create_compute_pipeline("shaders/int2float.spv", pipeline_layout_row);
  // Lossless path: integer 5/3 forward row, and YCoCg-R written as int (not float bits).
  VkPipeline pipeline_forward_row_53 = create_compute_pipeline("shaders/fwd53row.spv", pipeline_layout_row);
  VkPipeline pipeline_forward_row = lossless ? pipeline_forward_row_53 : pipeline_forward_row_97;
  VkPipeline pipeline_colour_53 = create_compute_pipeline("shaders/rgb2ycor.spv", pipeline_layout_colour);
  VkPipeline pipeline_colour_97_hdr = create_compute_pipeline("shaders/rgb2yco16.spv", pipeline_layout_colour);    // 16-bit signed RGB -> YCoCg-R (float)
  VkPipeline pipeline_colour_53_hdr = create_compute_pipeline("shaders/rgb2ycor16.spv", pipeline_layout_colour);   // 16-bit signed RGB -> YCoCg-R (int)
  // MCTF (predict-only MC-Haar) is a purely INTEGER temporal transform, so its temporal-subband frames are
  // integer YCoCg-R even in the lossy path (converted to float per-frame only for the 9/7 spatial step). Use the
  // integer colour pipeline (rgb2ycor / rgb2ycor16) regardless of quality, like the lossless path. (g_mctf is only
  // set in the 3D-DWT mode, where pipeline_colour's other consumers — the I/P/B per-frame loops — do not run.)
  int want_int_colour = lossless || g_mctf;
  VkPipeline pipeline_colour = hdr_mode ? (want_int_colour ? pipeline_colour_53_hdr : pipeline_colour_97_hdr)
                                        : (want_int_colour ? pipeline_colour_53 : pipeline_colour_97);

  // ---- variant B (colordiff): a pre-DWT YCoCg subtract, plus the decoder's inverse path embedded
  // here so the encoder reconstructs each frame exactly like the player does (closed loop, no lossy
  // drift). The inverse reuses the forward's transpose/row descriptor sets (binding-compatible). ----
  VkPipelineLayout pipeline_layout_add = create_pipeline_layout(layout_2_buffers, 8);
  VkPipeline pipeline_ycocg_diff = create_compute_pipeline("shaders/ycocg_diff.spv", pipeline_layout_add);
  VkPipeline pipeline_energy = create_compute_pipeline("shaders/frame_energy.spv", pipeline_layout_pack);
  VkPipeline pipeline_mc = create_compute_pipeline_motion("shaders/mc.spv", pipeline_layout_pack, g_motion_block);            // {prev, mv, mc_prev}, push 12
  VkPipeline pipeline_motion_add = create_compute_pipeline("shaders/motion_add.spv", pipeline_layout_pack);   // {coeff, mc_prev, prev}, push 8 (per-pixel, no motion grid)
  VkPipeline pipeline_motion_estimate = create_compute_pipeline_motion("shaders/motion_estimate.spv", pipeline_layout_motion_estimate, g_motion_block);   // {cur0..2, prev0..2, mv, mv_prev, sad}, push 16
  // Variable motion: ME at 16 and 32 (the MB=8 search reuses pipeline_motion_estimate, since g_motion_block==8 here) + the R-D quadtree merge.
  VkPipeline pipeline_me_16 = g_motion_variable ? create_compute_pipeline_motion("shaders/motion_estimate.spv", pipeline_layout_motion_estimate, 16) : 0;
  VkPipeline pipeline_me_32 = g_motion_variable ? create_compute_pipeline_motion("shaders/motion_estimate.spv", pipeline_layout_motion_estimate, 32) : 0;
  VkPipeline pipeline_merge = g_motion_variable ? create_compute_pipeline("shaders/motion_merge.spv", pipeline_layout_merge) : 0;
  // Variable B path: per-size bidirectional 3-mode SAD + the joint mode-aware R-D merge (opt-in via --bidi-merge; the
  // default variable B uses the fast single-ref 2-ME path).
  int var_b = (g_motion_variable && use_bframes) && g_motion_split_bidi;
  VkPipeline pipeline_bidi_sad_8  = var_b ? create_compute_pipeline_motion("shaders/bidi_mode_sad.spv", pipeline_layout_bidi_sad, 8)  : 0;
  VkPipeline pipeline_bidi_sad_16 = var_b ? create_compute_pipeline_motion("shaders/bidi_mode_sad.spv", pipeline_layout_bidi_sad, 16) : 0;
  VkPipeline pipeline_bidi_sad_32 = var_b ? create_compute_pipeline_motion("shaders/bidi_mode_sad.spv", pipeline_layout_bidi_sad, 32) : 0;
  VkPipeline pipeline_merge_bidi  = var_b ? create_compute_pipeline("shaders/motion_merge_bidi.spv", pipeline_layout_merge_bidi) : 0;
  VkPipelineLayout pipeline_layout_me_bidi = create_pipeline_layout(layout_11_buffers, 24);   // B2b: {cur0..2, ref0..2, mc_other0..2, mv, mv_prev}, push {6 ints}
  VkPipeline pipeline_me_bidi = create_compute_pipeline_motion("shaders/motion_estimate_bidi.spv", pipeline_layout_me_bidi, g_motion_block);
  VkPipelineLayout pipeline_layout_mode_decide = create_pipeline_layout(layout_10_buffers, 28);   // Phase 2: {cur0..2, mc0_0..2, mc1_0..2, modes}, push {7 ints}
  VkPipeline pipeline_mode_decide = create_compute_pipeline_motion("shaders/mode_decide.spv", pipeline_layout_mode_decide, g_motion_block);
  // --motion-split-fast: coarse per-32-root mode decision (16x fewer workgroups than per-8 mode_decide, + better RD), writing the 8-grid.
  VkPipelineLayout pipeline_layout_mode_root = create_pipeline_layout(layout_10_buffers, 36);   // push {w,h,fgx,fgy,g32x,lossless,w0,w1,bi_penalty}
  VkPipeline pipeline_mode_decide_root = ((g_motion_variable && use_bframes) && (!g_motion_split_bidi)) ? create_compute_pipeline("shaders/mode_decide_root.spv", pipeline_layout_mode_root) : 0;
  VkPipelineLayout pipeline_layout_blend_mode = create_pipeline_layout(layout_3_buffers, 20);   // Phase 2: {prediction, mc1, modes}, push {5 ints}
  VkPipeline pipeline_blend_mode = create_compute_pipeline_motion("shaders/blend_mode.spv", pipeline_layout_blend_mode, g_motion_block);
  VkPipeline pipeline_dequant_inverse = create_compute_pipeline("shaders/dequant97.spv", pipeline_layout_quant);
  VkPipelineLayout pipeline_layout_pcrd = create_pipeline_layout(layout_1_buffer, 20);   // {coeff}, push {4 ints + lambda}
  VkPipeline pipeline_apply_pcrd = create_compute_pipeline_bs("shaders/apply_pcrd.spv", pipeline_layout_pcrd, g_block_size);
  VkPipeline pipeline_round = create_compute_pipeline("shaders/round97.spv", pipeline_layout_row);
  VkPipeline pipeline_inverse_row_97 = create_compute_pipeline("shaders/idwt97row.spv", pipeline_layout_row);
  VkPipeline pipeline_inverse_row_53 = create_compute_pipeline("shaders/idwt53row.spv", pipeline_layout_row);
  VkPipeline pipeline_inverse_row = lossless ? pipeline_inverse_row_53 : pipeline_inverse_row_97;
  VkPipeline pipeline_bidi_blend = create_compute_pipeline("shaders/bidi_blend.spv", pipeline_layout_pack);   // weighted 2-ref prediction (3 buffers + 12-byte push)

  VkDescriptorPoolSize pool_size = { VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, 512 };   // + MCTF: 1 ME (9) + 3 mc (3x3) + 3 diff (3x3) = 27
  VkDescriptorPoolCreateInfo pool_info = { VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO };
  pool_info.maxSets = 128;   // + MCTF (set_mctf_me + set_mctf_mc[3] + set_mctf_diff[3] = 7)
  pool_info.poolSizeCount = 1;
  pool_info.pPoolSizes = &pool_size;
  VkDescriptorPool descriptor_pool;
  VK_CHECK(vkCreateDescriptorPool(device, &pool_info, 0, &descriptor_pool));

  // Colour set: RGB in -> the 3 coefficient planes. Per plane: the two transpose directions, the
  // row transform, quant, bitplane_size, and bitplane_pack.
  VkDescriptorSet set_colour = allocate_descriptor_set(descriptor_pool, layout_colour);
  bind_storage_buffers(set_colour, (VkBuffer[]){ rgb_buffer, coeff_buffer[0], coeff_buffer[1], coeff_buffer[2] }, 4);
  VkDescriptorSet set_coeff_to_scratch[3], set_scratch_to_coeff[3], set_row[3], set_quant[3], set_size[3], set_pack[3];
  VkDescriptorSet set_diff[3], set_size_diff[3], set_pack_diff[3];   // coefdiff (A) P-frame sets
  VkDescriptorSet set_ycocg[3];                                      // colordiff (B): {coeff, prev_ycocg} for ycocg_diff + coeff_add
  VkDescriptorSet set_energy[3];                                     // colordiff (B): {coeff, prev, energy} for the scene-cut detector
  VkDescriptorSet set_mc[3], set_motion_add[3], set_ycocg_mc[3];     // motion: mc.comp, motion_add, ycocg_diff-vs-mc_prev (mc_prev reuses difference_buffer)
  VkDescriptorSet set_motion_estimate;                              // motion search: {cur_luma[0], prev_luma[0], mv}
  for (int plane = 0; plane < 3; plane++) {
    set_coeff_to_scratch[plane] = allocate_descriptor_set(descriptor_pool, layout_2_buffers);
    bind_storage_buffers(set_coeff_to_scratch[plane], (VkBuffer[]){ coeff_buffer[plane], scratch_buffer }, 2);
    set_scratch_to_coeff[plane] = allocate_descriptor_set(descriptor_pool, layout_2_buffers);
    bind_storage_buffers(set_scratch_to_coeff[plane], (VkBuffer[]){ scratch_buffer, coeff_buffer[plane] }, 2);
    set_row[plane] = allocate_descriptor_set(descriptor_pool, layout_1_buffer);
    bind_storage_buffers(set_row[plane], (VkBuffer[]){ coeff_buffer[plane] }, 1);
    set_quant[plane] = allocate_descriptor_set(descriptor_pool, layout_2_buffers);
    bind_storage_buffers(set_quant[plane], (VkBuffer[]){ coeff_buffer[plane], step_buffer[plane] }, 2);
    set_size[plane] = allocate_descriptor_set(descriptor_pool, layout_2_buffers);
    bind_storage_buffers(set_size[plane], (VkBuffer[]){ coeff_buffer[plane], size_buffer[plane] }, 2);
    set_pack[plane] = allocate_descriptor_set(descriptor_pool, layout_3_buffers);
    bind_storage_buffers(set_pack[plane], (VkBuffer[]){ coeff_buffer[plane], offset_buffer[plane], data_buffer }, 3);
    // P-frame sets: coeff_diff (cur, prev, diff) + bitplane size/pack reading the difference buffer.
    set_diff[plane] = allocate_descriptor_set(descriptor_pool, layout_3_buffers);
    bind_storage_buffers(set_diff[plane], (VkBuffer[]){ coeff_buffer[plane], previous_buffer[plane], difference_buffer[plane] }, 3);
    set_size_diff[plane] = allocate_descriptor_set(descriptor_pool, layout_2_buffers);
    bind_storage_buffers(set_size_diff[plane], (VkBuffer[]){ difference_buffer[plane], size_buffer_diff[plane] }, 2);
    set_pack_diff[plane] = allocate_descriptor_set(descriptor_pool, layout_3_buffers);
    bind_storage_buffers(set_pack_diff[plane], (VkBuffer[]){ difference_buffer[plane], offset_buffer[plane], data_buffer }, 3);
    set_ycocg[plane] = allocate_descriptor_set(descriptor_pool, layout_2_buffers);
    bind_storage_buffers(set_ycocg[plane], (VkBuffer[]){ coeff_buffer[plane], previous_buffer[plane] }, 2);
    set_energy[plane] = allocate_descriptor_set(descriptor_pool, layout_3_buffers);
    bind_storage_buffers(set_energy[plane], (VkBuffer[]){ coeff_buffer[plane], previous_buffer[plane], energy_buffer }, 3);
    // Motion sets (mc_prev reuses difference_buffer, which colordiff doesn't otherwise use).
    set_mc[plane] = allocate_descriptor_set(descriptor_pool, layout_3_buffers);
    bind_storage_buffers(set_mc[plane], (VkBuffer[]){ previous_buffer[plane], mv_buffer, difference_buffer[plane] }, 3);
    set_motion_add[plane] = allocate_descriptor_set(descriptor_pool, layout_3_buffers);
    bind_storage_buffers(set_motion_add[plane], (VkBuffer[]){ coeff_buffer[plane], difference_buffer[plane], previous_buffer[plane] }, 3);
    set_ycocg_mc[plane] = allocate_descriptor_set(descriptor_pool, layout_2_buffers);
    bind_storage_buffers(set_ycocg_mc[plane], (VkBuffer[]){ coeff_buffer[plane], difference_buffer[plane] }, 2);
  }
  // Motion search reads the luma (plane 0) of the current frame and the previous reconstructed frame.
  set_motion_estimate = allocate_descriptor_set(descriptor_pool, layout_9_buffers);
  bind_storage_buffers(set_motion_estimate, (VkBuffer[]){ coeff_buffer[0], coeff_buffer[1], coeff_buffer[2],
                       previous_buffer[0], previous_buffer[1], previous_buffer[2], mv_buffer, mv_prev_buffer, sad_buffer }, 9);
  VkDescriptorSet set_row_scratch = allocate_descriptor_set(descriptor_pool, layout_1_buffer);
  bind_storage_buffers(set_row_scratch, (VkBuffer[]){ scratch_buffer }, 1);

  // Stage B1a: bidi sets, REBOUND per coding step to the chosen DPB slots. bidi_blend reads two
  // references + writes the prediction into difference_buffer (the existing prediction slot, consumed by
  // ycocg_diff via set_ycocg_mc); the reconstruct's motion_add writes the recon into the frame's DPB slot.
  VkDescriptorSet set_bidi_blend[3], set_motion_add_bidi[3];
  for (int plane = 0; plane < 3; plane++) {
    set_bidi_blend[plane] = use_bframes ? allocate_descriptor_set(descriptor_pool, layout_3_buffers) : 0;
    set_motion_add_bidi[plane] = use_bframes ? allocate_descriptor_set(descriptor_pool, layout_3_buffers) : 0;
  }
  // Stage B2: motion sets, REBOUND per coding step (two separate search sets so no rebind happens
  // within a command buffer). set_me_b0/b1 search current vs ref0/ref1 into mv_buffer/mv1_buffer; set_mc_b0
  // mc's ref0 by mv0 into difference_buffer; set_mc_b1 mc's ref1 by mv1 into mc1_buffer; then set_bidi_blend
  // combines {difference, mc1} -> difference in place.
  VkDescriptorSet set_me_b0 = use_bframes ? allocate_descriptor_set(descriptor_pool, layout_9_buffers) : 0;
  VkDescriptorSet set_me_b1 = use_bframes ? allocate_descriptor_set(descriptor_pool, layout_9_buffers) : 0;
  // Variable-motion R-D: three ME search sets (8/16/32 -> mv8/16/32 + sad8/16/32, zero predictor) + the merge set.
  VkDescriptorSet set_me_var8 = 0, set_me_var16 = 0, set_me_var32 = 0, set_merge = 0;
  if (g_motion_variable) {
    set_me_var8 = allocate_descriptor_set(descriptor_pool, layout_9_buffers);
    bind_storage_buffers(set_me_var8, (VkBuffer[]){ coeff_buffer[0], coeff_buffer[1], coeff_buffer[2],
                         previous_buffer[0], previous_buffer[1], previous_buffer[2], mv8_buffer, mv8_prev_buffer, sad_buffer }, 9);
    set_me_var16 = allocate_descriptor_set(descriptor_pool, layout_9_buffers);
    bind_storage_buffers(set_me_var16, (VkBuffer[]){ coeff_buffer[0], coeff_buffer[1], coeff_buffer[2],
                         previous_buffer[0], previous_buffer[1], previous_buffer[2], mv16_buffer, mv16_prev_buffer, sad16_buffer }, 9);
    set_me_var32 = allocate_descriptor_set(descriptor_pool, layout_9_buffers);
    bind_storage_buffers(set_me_var32, (VkBuffer[]){ coeff_buffer[0], coeff_buffer[1], coeff_buffer[2],
                         previous_buffer[0], previous_buffer[1], previous_buffer[2], mv32_buffer, mv32_prev_buffer, sad32_buffer }, 9);
    set_merge = allocate_descriptor_set(descriptor_pool, layout_7_buffers);
    bind_storage_buffers(set_merge, (VkBuffer[]){ mv8_buffer, sad_buffer, mv16_buffer, sad16_buffer, mv32_buffer, sad32_buffer, mv_buffer }, 7);
  }
  // Variable-motion B path (Stage 2b): the L0 (vs ref0 -> mv_buffer) and L1 (vs ref1 -> mv1_buffer) searches each run
  // the 3-size ME + R-D merge. Six ME sets (rebound per coding step to the DPB ref slots) + a 2nd merge set for L1.
  VkDescriptorSet set_me_var8_b0 = 0, set_me_var16_b0 = 0, set_me_var32_b0 = 0;
  VkDescriptorSet set_me_var8_b1 = 0, set_me_var16_b1 = 0, set_me_var32_b1 = 0;
  VkDescriptorSet set_bidi_sad8 = 0, set_bidi_sad16 = 0, set_bidi_sad32 = 0, set_merge_bidi = 0;
  if ((g_motion_variable && use_bframes) && g_motion_split_bidi) {
    set_me_var8_b0  = allocate_descriptor_set(descriptor_pool, layout_9_buffers);
    set_me_var16_b0 = allocate_descriptor_set(descriptor_pool, layout_9_buffers);
    set_me_var32_b0 = allocate_descriptor_set(descriptor_pool, layout_9_buffers);
    set_me_var8_b1  = allocate_descriptor_set(descriptor_pool, layout_9_buffers);
    set_me_var16_b1 = allocate_descriptor_set(descriptor_pool, layout_9_buffers);
    set_me_var32_b1 = allocate_descriptor_set(descriptor_pool, layout_9_buffers);
    set_bidi_sad8  = allocate_descriptor_set(descriptor_pool, layout_12_buffers);   // rebound per step to the DPB refs
    set_bidi_sad16 = allocate_descriptor_set(descriptor_pool, layout_12_buffers);
    set_bidi_sad32 = allocate_descriptor_set(descriptor_pool, layout_12_buffers);
    set_merge_bidi = allocate_descriptor_set(descriptor_pool, layout_12_buffers);   // fixed: modesad8/16/32 + mv0_8/16/32 + mv1_8/16/32 -> mv0/mv1/mode fields
    bind_storage_buffers(set_merge_bidi, (VkBuffer[]){ modesad8_buffer, modesad16_buffer, modesad32_buffer,
                         mv8_buffer, mv16_buffer, mv32_buffer, mv1_8_buffer, mv1_16_buffer, mv1_32_buffer,
                         mv_buffer, mv1_buffer, mode_buffer }, 12);
  }
  // B2b joint-search sets (11 buffers each), rebound per coding step: refine mv0 against ref0 with MC_other
  // = MC(ref1,mv1) in mc1_buffer; refine mv1 against ref1 with MC_other = MC(ref0,mv0) in difference_buffer.
  VkDescriptorSet set_me_bidi0 = use_bframes ? allocate_descriptor_set(descriptor_pool, layout_11_buffers) : 0;
  VkDescriptorSet set_me_bidi1 = use_bframes ? allocate_descriptor_set(descriptor_pool, layout_11_buffers) : 0;
  // Phase 2: mode_decide reads current + MC0(difference) + MC1(mc1) -> modes; blend_mode applies the per-block
  // mode to the prediction slot per plane. Rebound per coding step (the DPB slots / MC buffers are fixed but
  // re-bound for clarity). set_mode_decide is bound once (fixed buffers); set_blend_mode[plane] per plane.
  VkDescriptorSet set_mode_decide = use_bframes ? allocate_descriptor_set(descriptor_pool, layout_10_buffers) : 0;
  VkDescriptorSet set_blend_mode[3];
  if (use_bframes) {
    bind_storage_buffers(set_mode_decide, (VkBuffer[]){ coeff_buffer[0], coeff_buffer[1], coeff_buffer[2],
                         difference_buffer[0], difference_buffer[1], difference_buffer[2],
                         mc1_buffer[0], mc1_buffer[1], mc1_buffer[2], mode_buffer }, 10);
    for (int plane = 0; plane < 3; plane++) {
      set_blend_mode[plane] = allocate_descriptor_set(descriptor_pool, layout_3_buffers);
      bind_storage_buffers(set_blend_mode[plane], (VkBuffer[]){ difference_buffer[plane], mc1_buffer[plane], mode_buffer }, 3);
    }
  }
  VkDescriptorSet set_mc_b0[3], set_mc_b1[3];
  for (int plane = 0; plane < 3; plane++) {
    set_mc_b0[plane] = use_bframes ? allocate_descriptor_set(descriptor_pool, layout_3_buffers) : 0;
    set_mc_b1[plane] = use_bframes ? allocate_descriptor_set(descriptor_pool, layout_3_buffers) : 0;
  }

  // 3D-DWT: per-plane GOP-resident coefficient buffers + the temporal-DWT pipeline. The
  // colour pass fills these one frame at a time; the temporal-DWT shader transforms along the frame
  // axis in place; then each temporal-subband frame is spatially transformed/packed via the sets above.
  VkBuffer gop_buffer[3] = { 0, 0, 0 };
  VkDeviceMemory gop_memory[3] = { 0, 0, 0 };
  VkPipelineLayout pipeline_layout_temporal = 0;
  VkPipeline pipeline_temporal_int = 0, pipeline_temporal_float = 0;
  VkDescriptorSet set_temporal[3] = { 0, 0, 0 };
  if (mode_3ddwt) {
    for (int plane = 0; plane < 3; plane++) {   // chroma slots are smaller when subsampled (4:2:0 / 4:2:2)
      int plane_pixels = plane_width(plane, width) * plane_height(plane, height);
      create_buffer((size_t)gop * plane_pixels * 4, DEVICE_LOCAL, &gop_buffer[plane], &gop_memory[plane]);
    }
    pipeline_layout_temporal = create_pipeline_layout(layout_1_buffer, 20);   // { pixel_count, num_frames, levels, wavelet, inverse }
    pipeline_temporal_int = create_compute_pipeline("shaders/tdwt_int.spv", pipeline_layout_temporal);
    pipeline_temporal_float = create_compute_pipeline("shaders/tdwt_float.spv", pipeline_layout_temporal);
    for (int plane = 0; plane < 3; plane++) {
      set_temporal[plane] = allocate_descriptor_set(descriptor_pool, layout_1_buffer);
      bind_storage_buffers(set_temporal[plane], (VkBuffer[]){ gop_buffer[plane] }, 1);
    }
  }

  // MCTF (--mctf): frame-level predict-only MC-Haar replaces the open-loop temporal DWT. mctf_pred holds the
  // per-plane OBMC prediction of the even frame; mctf_scratch is the deinterleave-reorder target GOP (the [low|high]
  // layout, mirroring the CPU mctf_forward's scratch[]). The motion search / mc / coeff_diff sets are REBOUND per
  // pair to gop_buffer at the even/odd frame offsets (like the B-path rebinds set_bidi_blend to DPB slots).
  VkBuffer mctf_pred[3] = { 0, 0, 0 }, mctf_scratch[3] = { 0, 0, 0 };
  VkDeviceMemory mctf_pred_memory[3] = { 0, 0, 0 }, mctf_scratch_memory[3] = { 0, 0, 0 };
  VkDescriptorSet set_mctf_me = 0, set_mctf_mc[3] = { 0, 0, 0 }, set_mctf_diff[3] = { 0, 0, 0 };
  if (mode_3ddwt && g_mctf) {
    for (int plane = 0; plane < 3; plane++) {
      int plane_pixels = plane_width(plane, width) * plane_height(plane, height);
      create_buffer((size_t)plane_pixels * 4, DEVICE_LOCAL, &mctf_pred[plane], &mctf_pred_memory[plane]);
      create_buffer((size_t)gop * plane_pixels * 4, DEVICE_LOCAL, &mctf_scratch[plane], &mctf_scratch_memory[plane]);
      set_mctf_mc[plane] = allocate_descriptor_set(descriptor_pool, layout_3_buffers);
      set_mctf_diff[plane] = allocate_descriptor_set(descriptor_pool, layout_3_buffers);
    }
    set_mctf_me = allocate_descriptor_set(descriptor_pool, layout_9_buffers);
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
  VkFenceCreateInfo fence_info = { VK_STRUCTURE_TYPE_FENCE_CREATE_INFO };
  VK_CHECK(vkCreateFence(device, &fence_info, 0, &fence));

  // ---- input + per-frame state ----
  char command[4096];
  const char *pix_fmt = hdr_mode ? "rgb48le" : "rgb24";   // HDR: 16-bit PQ/bt2020 code values
  char scale_filter[64] = "";
  if (wavelet_scale < 1.0) {   // down-scale the raw frames to the (reduced) wavelet dimensions
    snprintf(scale_filter, sizeof scale_filter, "-vf scale=%d:%d ", width, height);
  }
  if (max_frames) {
    snprintf(command, sizeof command, "ffmpeg -v error -i \"%s\" -frames:v %ld %s-f rawvideo -pix_fmt %s -", input, max_frames, scale_filter, pix_fmt);
  } else {
    snprintf(command, sizeof command, "ffmpeg -v error -i \"%s\" %s-f rawvideo -pix_fmt %s -", input, scale_filter, pix_fmt);
  }
  FILE *input_pipe = popen(command, "r");
  if (!input_pipe) {
    die("popen ffmpeg");
  }
  size_t frame_bytes = (size_t)pixel_count * (hdr_mode ? 6 : 3);   // rgb48le (HDR 16-bit) vs rgb24 (SDR)
  uint8_t *rgb = checked_malloc(frame_bytes);
  uint8_t *reconstructed = checked_malloc(frame_bytes);
  // Self-test (no output) coefficient reference, so the CPU decode tracks P-frames too.
  int32_t *self_previous[3];
  for (int plane = 0; plane < 3; plane++) {
    self_previous[plane] = checked_malloc((size_t)pixel_count * 4);
  }
  int *step = checked_malloc(pixel_count * sizeof(int));
  for (int plane = 0; plane < 3; plane++) {   // per-plane quant map: chroma is built at its (subsampled) plane size, matching the decoder
    int plane_w = plane_width(plane, width), plane_h = plane_height(plane, height);
    build_quantization_steps(step, plane_w, plane_h, levels, quality);
    memcpy(step_map[plane], step, (size_t)(plane_w * plane_h) * 4);
  }
  int current_quality = quality;   // per-GOP working Q (varies under --vbr); written into each FrameEntry
  uint32_t *offsets[3];
  for (int plane = 0; plane < 3; plane++) {
    offsets[plane] = checked_malloc((size_t)block_count * 4);
  }
  long frame_index = 0;
  long predicted_frames = 0;
  long bf_i_count = 0, bf_p_count = 0, bf_b_count = 0;   // per-type tallies for the B-frame summary
  double sum_psnr = 0;
  unsigned long long total_bytes = 0;
  int pixel_workgroups = (pixel_count + 255) / 256;   // frame-level: colour pass + colordiff scene-cut detector (per-plane below)

  // ---- optional container output ----
  FILE *container_file = NULL;
  FrameEntry *index = NULL;
  long index_capacity = 0;
  uint64_t audio_size = 0;
  uint8_t *audio = NULL;
  uint8_t audio_codec_tag[4] = { 'O', 'G', 'G', 'V' };   // default OGG/Vorbis
  uint64_t h264_blob_size = 0;
  uint8_t *h264_blob = NULL;   // --h264: full-res Annex-B elementary stream
  if (output) {
    container_file = fopen(output, "wb+");
    if (!container_file) {
      die("cannot open output");
    }
    ContainerHeader placeholder;
    memset(&placeholder, 0, sizeof placeholder);
    fwrite(&placeholder, sizeof placeholder, 1, container_file);   // reserve space, filled at the end
    if (audio_codec_choice == 0) {
      audio = extract_audio(input, &audio_size);   // OGG/Vorbis (transcoded by ffmpeg)
    } else {
      int a_samples = 0, a_channels = 0, a_rate = 0;
      short *pcm = extract_audio_pcm(input, &a_samples, &a_channels, &a_rate);
      if (pcm) {
        if (audio_codec_choice == 1) {
          audio = qoal_encode(pcm, a_samples, a_channels, a_rate, &audio_size);
          audio_codec_tag[0] = 'Q';
          audio_codec_tag[1] = 'O';
          audio_codec_tag[2] = 'A';
          audio_codec_tag[3] = 'L';
        } else if (audio_codec_choice == 3) {
          FwaParams wp = { 0 };   // FWA (wavelet audio): derive the fwa mode from --fwa-quality / --fwa-mode
          wp.quality = fwa_quality;
          wp.lms_taps = fwa_lms_taps;
          wp.pair_enabled = fwa_no_pair ? 0 : 1;
          wp.adapt = fwa_pair_ms ? 0 : 1;
          const char *mode = fwa_mode ? fwa_mode : ((fwa_quality == 0) ? "53" : "joint");
          if (!strcmp(mode, "uniform")) {
            wp.perceptual = 0;
          } else if (!strcmp(mode, "psycho")) {
            wp.perceptual = 1;
          } else if (!strcmp(mode, "packet")) {
            wp.packet = 1;
          } else if (!strcmp(mode, "packet-psycho")) {
            wp.perceptual = 1;
            wp.packet = 1;
          } else if ((!strcmp(mode, "joint")) || (!strcmp(mode, "joint-psycho"))) {
            wp.perceptual = 1;
            wp.joint = 1;
          } else if (!strcmp(mode, "lms")) {
            wp.lms = 1;   // lossless LMS predictor (Q0)
          } else {
            wp.perceptual = (fwa_quality > 0) ? 1 : 0;   // "53"/default: plain 5/3 lossless (Q0) or uniform lossy
          }
          audio = fwa_encode(pcm, a_samples, a_channels, a_rate, &wp, &audio_size);
          audio_codec_tag[0] = 'F';
          audio_codec_tag[1] = 'W';
          audio_codec_tag[2] = 'A';
          audio_codec_tag[3] = 'C';
        } else {
          audio = rpcm_encode_s16(pcm, a_samples, a_channels, a_rate, &audio_size);
          audio_codec_tag[0] = 'R';
          audio_codec_tag[1] = 'P';
          audio_codec_tag[2] = 'C';
          audio_codec_tag[3] = 'M';
        }
        free(pcm);
      }
    }
    if (want_h264) {   // additionally encode a full-res H.264 stream for the HW-decode path
      h264_blob = prepare_h264_stream(input, max_frames, &h264_blob_size);
      if (!h264_blob) {
        fprintf(stderr, "warning: --h264 requested but H.264 encode failed; writing wavelet-only\n");
      }
    }
    printf("writing container %s @ %u/%u fps, audio=%s [%c%c%c%c], h264=%s\n", output, fps_num, fps_den,
           audio ? "yes" : "no", audio_codec_tag[0], audio_codec_tag[1], audio_codec_tag[2],
           audio_codec_tag[3] ? audio_codec_tag[3] : ' ', h264_blob ? "yes" : "no");
  }

  // colordiff (B) predicts at any quality; coefdiff (A) only at Q0 (its diff is exact only for 5/3).
  int predictive = (gop > 1) && ((method == 1) ? 1 : lossless);

  // Encode progress (only while writing a container): derive the total frame count from max_frames or the
  // probed source duration so we can show percent / video-time / ETA on a single refreshing line.
  double fps_value = (double)fps_num / ((fps_den > 0) ? (double)fps_den : 1.0);
  double source_duration = probe_video_duration(input);
  long probed_frames = (source_duration > 0) ? (long)((source_duration * fps_value) + 0.5) : 0;
  long total_frames = (max_frames > 0) ? max_frames : probed_frames;
  if (((max_frames > 0) && (probed_frames > 0)) && (probed_frames < max_frames)) {
    total_frames = probed_frames;
  }
  double encode_start = now_milliseconds();

  if (use_bframes && cpu_bframes) {
    // ---- hierarchical B-frame encode (Stage A CPU oracle: --cpu-bframes; the GPU bidi path below is the default) ----
    printf("  B-frame mode: %d B between anchors (period %d), keyframe interval %d, chroma=%s (CPU oracle)\n",
           bframes, bframes + 1, (gop > (bframes + 1)) ? (((int)(gop / (bframes + 1))) * (bframes + 1)) : 0,
           (g_chroma_format == 2) ? "4:2:0" : ((g_chroma_format == 1) ? "4:2:2" : "4:4:4"));
    encode_bframe_stream(input_pipe, container_file, &index, &index_capacity, &frame_index, &total_bytes,
                         &bf_i_count, &bf_p_count, &bf_b_count, width, height, levels, quality, bframes, gop,
                         frame_bytes, max_frames, fps_value, total_frames, encode_start);
    predicted_frames = bf_p_count + bf_b_count;
  } else if (mode_3ddwt) {
    // ---- 3D-DWT GOP encode: GPU temporal-then-spatial DWT (open-loop, SDR) ----
    int temporal_wavelet = g_temporal_wavelet;
    if (lossless && (temporal_wavelet == 2)) {   // 9/7 is float-only; Q0 -> 5/3
      temporal_wavelet = 1;
    }
    printf("  3D-DWT mode: GOP=%d temporal_levels=%d temporal=%s chroma=%s (GPU)\n",
           gop, g_temporal_levels,
           g_mctf ? "MCTF predict-only MC-Haar" : ((temporal_wavelet == 2) ? "open-loop 9/7" : ((temporal_wavelet == 1) ? "open-loop 5/3" : "open-loop Haar")),
           (g_chroma_format == 2) ? "4:2:0" : ((g_chroma_format == 1) ? "4:2:2" : "4:4:4"));
    int scratch_stride = (width > height) ? width : height;
    // Per-plane dimensions + level pyramids (luma full-res; chroma subsampled when g_chroma_format != 0).
    int plane_w[3], plane_h[3], plane_pixels[3], plane_blocks[3], plane_level_count[3];
    int plane_level_width[3][16], plane_level_height[3][16];
    for (int plane = 0; plane < 3; plane++) {
      plane_w[plane] = plane_width(plane, width);
      plane_h[plane] = plane_height(plane, height);
      plane_pixels[plane] = plane_w[plane] * plane_h[plane];
      plane_blocks[plane] = block_count_x(plane_w[plane]) * block_count_y(plane_h[plane]);
      int level_count = 0, cw = plane_w[plane], ch = plane_h[plane];
      for (int level = 0; ((level < levels) && (cw >= 2)) && (ch >= 2); level++) {
        plane_level_width[plane][level_count] = cw;
        plane_level_height[plane][level_count] = ch;
        level_count++;
        cw = (cw + 1) / 2;
        ch = (ch + 1) / 2;
      }
      plane_level_count[plane] = level_count;
    }
    uint8_t **gop_rgb = checked_malloc((size_t)gop * sizeof(uint8_t *));
    uint8_t **gop_reconstructed = checked_malloc((size_t)gop * sizeof(uint8_t *));
    uint8_t **gop_encoded = checked_malloc((size_t)gop * sizeof(uint8_t *));
    size_t *gop_encoded_length = checked_malloc((size_t)gop * sizeof(size_t));
    // MCTF: per-high-pass-frame luma MV field (deinterleaved-position indexed), read back from mv_buffer after each
    // pair's motion search and coded into the assemble_frame MV blob in Phase C (mirrors CPU encode_gop_3ddwt).
    int *mctf_frame_mv = g_mctf ? checked_malloc(((size_t)gop * motion_blocks_x * motion_blocks_y * 2) * sizeof(int)) : NULL;
    if (g_mctf) {   // zero the motion_estimate temporal predictor once (never updated across pairs → predict=0, matching the CPU's no-predictor search)
      begin_recording();
      vkCmdFillBuffer(command_buffer, mv_prev_buffer, 0, (((VkDeviceSize)motion_blocks_x * motion_blocks_y) * 2) * 4, 0);
      submit_and_wait();
    }
    for (int g = 0; g < gop; g++) {
      gop_rgb[g] = checked_malloc(frame_bytes);
      gop_reconstructed[g] = checked_malloc(frame_bytes);
    }
    for (;;) {
      int filled = 0;
      while ((filled < gop) && (!max_frames || ((frame_index + filled) < max_frames))
             && (fread(gop_rgb[filled], 1, frame_bytes, input_pipe) == frame_bytes)) {
        filled++;
      }
      if (filled == 0) {
        break;
      }

      // Phase A: colour each frame (full res); chroma is down-sampled to its plane size; copy into the GOP slot.
      for (int f = 0; f < filled; f++) {
        if (hdr_mode) {   // HDR: rgb48le (10-bit << 6) -> 12-bit BT.2020 code, exactly as the intra/colordiff path does
          const uint16_t *source16 = (const uint16_t *)gop_rgb[f];   // (the 3D-DWT path was missing this >>4 -> 4x-too-large values overflowed the colour shader -> corruption)
          int16_t *destination16 = (int16_t *)rgb_map;
          for (int s = 0; s < pixel_count * 3; s++) {
            destination16[s] = (int16_t)(source16[s] >> 4);
          }
        } else {
          memcpy(rgb_map, gop_rgb[f], frame_bytes);
        }
        begin_recording();
        int32_t colour_push[2] = { width, height };
        vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_colour);
        vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_colour, 0, 1, &set_colour, 0, 0);
        vkCmdPushConstants(command_buffer, pipeline_layout_colour, VK_SHADER_STAGE_COMPUTE_BIT, 0, 8, colour_push);
        vkCmdDispatch(command_buffer, (pixel_count + 255) / 256, 1, 1);
        memory_barrier();   // colour (compute write) -> chroma_downsample (compute read of coeff)
        // Chroma down-sample (lossy only; lossless is forced 4:4:4): coeff[plane] (full) -> scratch (small) -> coeff[plane].
        if (g_chroma_format != 0) {
          for (int plane = 1; plane < 3; plane++) {
            int32_t downsample_push[4] = { width, height, chroma_shift_x(), chroma_shift_y() };
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, g_mctf ? pipeline_chroma_downsample_int : pipeline_chroma_downsample);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_chroma_downsample, 0, 1, &set_coeff_to_scratch[plane], 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_chroma_downsample, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, downsample_push);
            vkCmdDispatch(command_buffer, (plane_pixels[plane] + 255) / 256, 1, 1);
            VkMemoryBarrier ds_barrier = { VK_STRUCTURE_TYPE_MEMORY_BARRIER };   // downsample (compute write scratch) -> copy (transfer read)
            ds_barrier.srcAccessMask = VK_ACCESS_SHADER_WRITE_BIT;
            ds_barrier.dstAccessMask = VK_ACCESS_TRANSFER_READ_BIT;
            vkCmdPipelineBarrier(command_buffer, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 1, &ds_barrier, 0, 0, 0, 0);
            VkBufferCopy chroma_copy = { 0, 0, (VkDeviceSize)plane_pixels[plane] * 4 };   // small bytes -> coeff[plane] start
            vkCmdCopyBuffer(command_buffer, scratch_buffer, coeff_buffer[plane], 1, &chroma_copy);
            VkMemoryBarrier back_barrier = { VK_STRUCTURE_TYPE_MEMORY_BARRIER };   // copy done -> reuse scratch / read coeff
            back_barrier.srcAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
            back_barrier.dstAccessMask = (VK_ACCESS_SHADER_WRITE_BIT | VK_ACCESS_TRANSFER_READ_BIT);
            vkCmdPipelineBarrier(command_buffer, VK_PIPELINE_STAGE_TRANSFER_BIT, (VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT | VK_PIPELINE_STAGE_TRANSFER_BIT), 0, 1, &back_barrier, 0, 0, 0, 0);
          }
        }
        VkMemoryBarrier colour_barrier = { VK_STRUCTURE_TYPE_MEMORY_BARRIER };   // colour-written luma (compute) -> copy (transfer read)
        colour_barrier.srcAccessMask = VK_ACCESS_SHADER_WRITE_BIT;
        colour_barrier.dstAccessMask = VK_ACCESS_TRANSFER_READ_BIT;
        vkCmdPipelineBarrier(command_buffer, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 1, &colour_barrier, 0, 0, 0, 0);
        for (int plane = 0; plane < 3; plane++) {
          VkBufferCopy copy = { 0, (VkDeviceSize)f * plane_pixels[plane] * 4, (VkDeviceSize)plane_pixels[plane] * 4 };
          vkCmdCopyBuffer(command_buffer, coeff_buffer[plane], gop_buffer[plane], 1, &copy);
        }
        submit_and_wait();
      }

      // Phase B: temporal forward transform along the frame axis. MCTF (--mctf) = frame-level predict-only MC-Haar
      // (motion-aligned; mirrors CPU mctf_forward), else the open-loop per-pixel-column temporal wavelet.
      if (g_mctf) {
        int luma_blocks = motion_blocks_x * motion_blocks_y;
        int plane_mbx[3];
        for (int plane = 0; plane < 3; plane++) {
          plane_mbx[plane] = ((plane_w[plane] + g_motion_block) - 1) / g_motion_block;   // each plane's motion grid (subsampled chroma is smaller)
        }
        int len = filled;
        for (int l = 0; (l < g_temporal_levels) && (len >= 2); l++) {
          int low_count = (len + 1) / 2;
          for (int k = 0; k < low_count; k++) {
            int even = 2 * k;
            if (((2 * k) + 1) < len) {
              int odd = (2 * k) + 1;
              // 1) luma motion search (current = gop@odd, reference = gop@even). The chroma planes are subsampled, so
              //    the 3-plane SAD would mis-index them; bind the LUMA plane to all 3 current/ref slots (luma-only ME,
              //    matching the CPU oracle), push lossless=1 since gop holds INTEGER YCoCg (MCTF is always integer).
              begin_recording();
              VkDeviceSize odd0 = (VkDeviceSize)odd * plane_pixels[0] * 4, even0 = (VkDeviceSize)even * plane_pixels[0] * 4;
              bind_storage_buffers_offset(set_mctf_me,
                (VkBuffer[]){ gop_buffer[0], gop_buffer[0], gop_buffer[0], gop_buffer[0], gop_buffer[0], gop_buffer[0], mv_buffer, mv_prev_buffer, sad_buffer },
                (VkDeviceSize[]){ odd0, odd0, odd0, even0, even0, even0, 0, 0, 0 }, 9);
              int32_t me_push[4] = { plane_w[0], plane_h[0], motion_blocks_x, 1 };
              vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_motion_estimate);
              vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_motion_estimate, 0, 1, &set_mctf_me, 0, 0);
              vkCmdPushConstants(command_buffer, pipeline_layout_motion_estimate, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, me_push);
              vkCmdDispatch(command_buffer, motion_blocks_x * motion_blocks_y, 1, 1);
              submit_and_wait();
              memcpy(&mctf_frame_mv[((size_t)(low_count + k) * luma_blocks) * 2], mv_map, (size_t)luma_blocks * 2 * 4);   // this pair's MVs live with the high frame
              // 2) per plane: pred = OBMC(gop@even, mv); high = gop@odd - pred -> scratch@(low_count+k); low = gop@even -> scratch@k
              begin_recording();
              for (int plane = 0; plane < 3; plane++) {
                int pp = plane_pixels[plane];
                VkDeviceSize even_off = (VkDeviceSize)even * pp * 4, odd_off = (VkDeviceSize)odd * pp * 4;
                bind_storage_buffers_offset(set_mctf_mc[plane],
                  (VkBuffer[]){ gop_buffer[plane], mv_buffer, mctf_pred[plane] }, (VkDeviceSize[]){ even_off, 0, 0 }, 3);
                int32_t mc_push[3] = { plane_w[plane], plane_h[plane], plane_mbx[plane] };
                vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_mc);
                vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_pack, 0, 1, &set_mctf_mc[plane], 0, 0);
                vkCmdPushConstants(command_buffer, pipeline_layout_pack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 12, mc_push);
                vkCmdDispatch(command_buffer, (pp + 255) / 256, 1, 1);
                memory_barrier();   // mc writes pred -> coeff_diff reads pred
                // coeff_diff: high = gop@odd - pred. (binding 1 'previous'=pred is also overwritten with gop@odd; harmless, pred is scratch.)
                bind_storage_buffers_offset(set_mctf_diff[plane],
                  (VkBuffer[]){ gop_buffer[plane], mctf_pred[plane], mctf_scratch[plane] },
                  (VkDeviceSize[]){ odd_off, 0, (VkDeviceSize)(low_count + k) * pp * 4 }, 3);
                int32_t diff_push = pp;
                vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_coeff_diff);
                vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_coeff_diff, 0, 1, &set_mctf_diff[plane], 0, 0);
                vkCmdPushConstants(command_buffer, pipeline_layout_coeff_diff, VK_SHADER_STAGE_COMPUTE_BIT, 0, 4, &diff_push);
                vkCmdDispatch(command_buffer, (pp + 255) / 256, 1, 1);
                VkBufferCopy low_copy = { even_off, (VkDeviceSize)k * pp * 4, (VkDeviceSize)pp * 4 };   // low = even passthrough
                vkCmdCopyBuffer(command_buffer, gop_buffer[plane], mctf_scratch[plane], 1, &low_copy);
              }
              submit_and_wait();
            } else {
              begin_recording();   // odd tail (no partner): low = even passthrough -> scratch@k
              for (int plane = 0; plane < 3; plane++) {
                int pp = plane_pixels[plane];
                VkBufferCopy low_copy = { (VkDeviceSize)even * pp * 4, (VkDeviceSize)k * pp * 4, (VkDeviceSize)pp * 4 };
                vkCmdCopyBuffer(command_buffer, gop_buffer[plane], mctf_scratch[plane], 1, &low_copy);
              }
              submit_and_wait();
            }
          }
          begin_recording();   // copy scratch[0..len) back into gop_buffer (the deinterleaved [low | high] layout)
          for (int plane = 0; plane < 3; plane++) {
            VkBufferCopy back = { 0, 0, (VkDeviceSize)len * plane_pixels[plane] * 4 };
            vkCmdCopyBuffer(command_buffer, mctf_scratch[plane], gop_buffer[plane], 1, &back);
          }
          submit_and_wait();
          len = low_count;
        }
      } else {
        // open-loop temporal forward DWT along the frame axis, per plane (at each plane's size).
        begin_recording();
        VkPipeline temporal_pipeline = lossless ? pipeline_temporal_int : pipeline_temporal_float;
        for (int plane = 0; plane < 3; plane++) {
          int32_t temporal_push[5] = { plane_pixels[plane], filled, g_temporal_levels, temporal_wavelet, 0 };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, temporal_pipeline);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_temporal, 0, 1, &set_temporal[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_temporal, VK_SHADER_STAGE_COMPUTE_BIT, 0, 20, temporal_push);
          vkCmdDispatch(command_buffer, (plane_pixels[plane] + 255) / 256, 1, 1);
        }
        submit_and_wait();
      }

      if (debug) {   // --debug: full-luma-plane compare of the GPU temporal output vs CPU temporal_forward_*
        float *cpu_luma = checked_malloc((size_t)filled * pixel_count * sizeof(float));
        int32_t *tmp_y = checked_malloc((size_t)pixel_count * 4), *tmp_c = checked_malloc((size_t)pixel_count * 4), *tmp_g = checked_malloc((size_t)pixel_count * 4);
        for (int f = 0; f < filled; f++) {
          rgb_to_ycocg(gop_rgb[f], tmp_y, tmp_c, tmp_g, pixel_count);
          for (int i = 0; i < pixel_count; i++) {
            cpu_luma[((size_t)f * pixel_count) + i] = (float)tmp_y[i];
          }
        }
        float cpu_line[MAX_GOP];
        for (int i = 0; i < pixel_count; i++) {
          for (int f = 0; f < filled; f++) {
            cpu_line[f] = cpu_luma[((size_t)f * pixel_count) + i];
          }
          if (lossless) {
            int32_t cpu_int[MAX_GOP];
            for (int f = 0; f < filled; f++) {
              cpu_int[f] = (int32_t)cpu_line[f];
            }
            temporal_forward_int(cpu_int, filled, g_temporal_levels, temporal_wavelet);
            for (int f = 0; f < filled; f++) {
              cpu_luma[((size_t)f * pixel_count) + i] = (float)cpu_int[f];
            }
          } else {
            temporal_forward_float(cpu_line, filled, g_temporal_levels, temporal_wavelet);
            for (int f = 0; f < filled; f++) {
              cpu_luma[((size_t)f * pixel_count) + i] = cpu_line[f];
            }
          }
        }
        long mismatches = 0;
        double max_abs = 0;
        for (int f = 0; f < filled; f++) {
          begin_recording();
          VkBufferCopy c = { (VkDeviceSize)f * plane_bytes, 0, plane_bytes };
          vkCmdCopyBuffer(command_buffer, gop_buffer[0], data_buffer, 1, &c);
          submit_and_wait();
          for (int i = 0; i < pixel_count; i++) {
            float gpu_value = lossless ? (float)((const int32_t *)data_map)[i] : ((const float *)data_map)[i];
            float expected = cpu_luma[((size_t)f * pixel_count) + i];
            double d = fabs((double)gpu_value - (double)expected);
            if (d > 1e-3) {
              mismatches++;
            }
            if (d > max_abs) {
              max_abs = d;
            }
          }
        }
        fprintf(stderr, "  [debug] temporal luma (%s): %ld / %d mismatches vs CPU, max_abs=%.4g\n", lossless ? "int" : "float", mismatches, filled * pixel_count, max_abs);
        free(cpu_luma);
        free(tmp_y);
        free(tmp_c);
        free(tmp_g);
      }

      // Phase C: each temporal-subband frame -> spatial DWT + quant + bit-plane size/pack -> payload.
      for (int f = 0; f < filled; f++) {
        int level = temporal_quant_level(f, filled, g_temporal_levels);
        int effective_quality = lossless ? 0 : (int)(((float)quality * temporal_quant_scale(level)) + 0.5f);
        if (!lossless && (effective_quality < 1)) {
          effective_quality = 1;
        }
        begin_recording();
        for (int plane = 0; plane < 3; plane++) {
          int pw = plane_w[plane], ph = plane_h[plane], pp = plane_pixels[plane];
          VkBufferCopy copy = { (VkDeviceSize)f * pp * 4, 0, (VkDeviceSize)pp * 4 };
          vkCmdCopyBuffer(command_buffer, gop_buffer[plane], coeff_buffer[plane], 1, &copy);
          VkMemoryBarrier copy_barrier = { VK_STRUCTURE_TYPE_MEMORY_BARRIER };   // copy (transfer write) -> spatial (compute read)
          copy_barrier.srcAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
          copy_barrier.dstAccessMask = VK_ACCESS_SHADER_READ_BIT | VK_ACCESS_SHADER_WRITE_BIT;
          vkCmdPipelineBarrier(command_buffer, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, 0, 1, &copy_barrier, 0, 0, 0, 0);
          if (g_mctf && !lossless) {   // MCTF temporal-subband frames are integer; the lossy 9/7 spatial reads float bit-patterns -> convert once
            int32_t convert_push = pp;
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_int2float);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_row, 0, 1, &set_row[plane], 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_row, VK_SHADER_STAGE_COMPUTE_BIT, 0, 4, &convert_push);
            vkCmdDispatch(command_buffer, (pp + 255) / 256, 1, 1);
            memory_barrier();
          }
          for (int level_i = 0; level_i < plane_level_count[plane]; level_i++) {
            int level_w = plane_level_width[plane][level_i], level_h = plane_level_height[plane][level_i];
            int32_t row_push_1[4] = { pw, level_w, level_h, 1 };
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_forward_row);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_row, 0, 1, &set_row[plane], 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_row, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, row_push_1);
            vkCmdDispatch(command_buffer, level_h, 1, 1);
            memory_barrier();
            int32_t transpose_push_1[4] = { pw, level_w, level_h, scratch_stride };
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_transpose);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_transpose, 0, 1, &set_coeff_to_scratch[plane], 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_transpose, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, transpose_push_1);
            vkCmdDispatch(command_buffer, (level_w + 15) / 16, (level_h + 15) / 16, 1);
            memory_barrier();
            int32_t row_push_2[4] = { scratch_stride, level_h, level_w, 1 };
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_forward_row);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_row, 0, 1, &set_row_scratch, 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_row, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, row_push_2);
            vkCmdDispatch(command_buffer, level_w, 1, 1);
            memory_barrier();
            int32_t transpose_push_2[4] = { scratch_stride, level_h, level_w, pw };
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_transpose);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_transpose, 0, 1, &set_scratch_to_coeff[plane], 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_transpose, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, transpose_push_2);
            vkCmdDispatch(command_buffer, (level_h + 15) / 16, (level_w + 15) / 16, 1);
            memory_barrier();
          }
          if (!lossless) {   // per-plane, temporally-scaled quant steps (built into this plane's step buffer)
            build_quantization_steps(step, pw, ph, levels, effective_quality);
            memcpy(step_map[plane], step, (size_t)pp * 4);
            int32_t quant_push[2];
            quant_push[0] = pp;
            float chroma_multiplier = (plane == 0) ? 1.0f : g_chroma_quant;
            memcpy(&quant_push[1], &chroma_multiplier, sizeof(float));
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_quant);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_quant, 0, 1, &set_quant[plane], 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_quant, VK_SHADER_STAGE_COMPUTE_BIT, 0, 8, quant_push);
            vkCmdDispatch(command_buffer, (pp + 255) / 256, 1, 1);
            memory_barrier();
          }
          int32_t block_push[4] = { pw, ph, block_count_x(pw), block_count_y(ph) };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_size);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_size, 0, 1, &set_size[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_size, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, block_push);
          vkCmdDispatch(command_buffer, (g_block_size == 128) ? plane_blocks[plane] : ((plane_blocks[plane] + 63) / 64), 1, 1);   // coop (128): one workgroup per block
          memory_barrier();
        }
        submit_and_wait();

        if (debug && lossless) {   // --debug (lossless): GPU spatial output (luma) vs CPU forward_legall53_2d
          int32_t *temporal_luma = checked_malloc((size_t)pixel_count * 4);
          int32_t *gpu_spatial = checked_malloc((size_t)pixel_count * 4);
          begin_recording();
          VkBufferCopy c0 = { (VkDeviceSize)f * plane_bytes, 0, plane_bytes };
          vkCmdCopyBuffer(command_buffer, gop_buffer[0], data_buffer, 1, &c0);
          submit_and_wait();
          memcpy(temporal_luma, data_map, (size_t)pixel_count * 4);
          begin_recording();
          VkBufferCopy c1 = { 0, 0, plane_bytes };
          vkCmdCopyBuffer(command_buffer, coeff_buffer[0], data_buffer, 1, &c1);
          submit_and_wait();
          memcpy(gpu_spatial, data_map, (size_t)pixel_count * 4);
          forward_legall53_2d(temporal_luma, width, height, levels);
          long mismatches = 0;
          for (int i = 0; i < pixel_count; i++) {
            if (gpu_spatial[i] != temporal_luma[i]) {
              mismatches++;
            }
          }
          fprintf(stderr, "  [debug] frame %d spatial luma: %ld / %d mismatches vs CPU\n", f, mismatches, pixel_count);
          free(temporal_luma);
          free(gpu_spatial);
        }

        // prefix-sum the per-block sizes into byte offsets (per-plane; chroma has fewer blocks when subsampled).
        uint32_t cumulative = 0;
        for (int plane = 0; plane < 3; plane++) {
          const uint32_t *sizes = size_map[plane];
          for (int block = 0; block < plane_blocks[plane]; block++) {
            offsets[plane][block] = cumulative;
            cumulative += sizes[block];
          }
          memcpy(offset_map[plane], offsets[plane], (size_t)plane_blocks[plane] * 4);
        }
        size_t data_length = cumulative;

        begin_recording();
        for (int plane = 0; plane < 3; plane++) {
          int32_t block_push[4] = { plane_w[plane], plane_h[plane], block_count_x(plane_w[plane]), block_count_y(plane_h[plane]) };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_pack);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_pack, 0, 1, &set_pack[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_pack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, block_push);
          vkCmdDispatch(command_buffer, (g_block_size == 128) ? plane_blocks[plane] : ((plane_blocks[plane] + 63) / 64), 1, 1);   // coop (128): one workgroup per block
        }
        submit_and_wait();

        // MCTF: each high-pass frame (temporal_quant_level>0) carries its luma MV field; the deepest temporal-low
        // frames (level 0, the GOP keyframes) carry none. Coded with the same encode_motion_vectors as the CPU oracle.
        uint8_t *mv_blob = NULL;
        size_t mv_blob_length = 0;
        if (g_mctf && (level > 0)) {
          const int *frame_mv = &mctf_frame_mv[((size_t)f * motion_blocks_x * motion_blocks_y) * 2];
          if (g_mv_codec == 1) {
            mv_blob_length = mv_blob_encode_range(&mv_blob, 0, NULL, 0, frame_mv, 0, NULL, 0, motion_blocks_x, motion_blocks_y);
          } else {
            BitWriter mv_writer;
            bitwriter_init(&mv_writer);
            encode_motion_vectors(&mv_writer, frame_mv, motion_blocks_x, motion_blocks_y);
            bitwriter_flush(&mv_writer);
            mv_blob = mv_writer.bytes;
            mv_blob_length = mv_writer.length;
          }
        }
        uint8_t *frame;
        size_t total = assemble_frame(plane_blocks,
                                      (uint32_t *[3]){ (uint32_t *)size_map[0], (uint32_t *)size_map[1], (uint32_t *)size_map[2] },
                                      mv_blob, mv_blob_length, (const uint8_t *)data_map, data_length, &frame);
        free(mv_blob);
        gop_encoded[f] = frame;
        gop_encoded_length[f] = total;
        total_bytes += total;
      }

      if (output) {
        // Write each subband frame; type 0 marks the GOP start (seek point), 2 the continuations.
        for (int f = 0; f < filled; f++) {
          if (frame_index >= index_capacity) {
            index_capacity = index_capacity ? (index_capacity * 2) : 256;
            index = realloc(index, (size_t)index_capacity * sizeof(FrameEntry));
            if (!index) {
              die("realloc");
            }
          }
          index[frame_index].offset = (uint64_t)ftello(container_file);
          index[frame_index].type = (uint8_t)((f == 0) ? 0 : 2);   // 3D-DWT: 2 = GOP continuation (method-scoped, not B)
          index[frame_index].quality = (uint8_t)quality;
          index[frame_index].poc = (uint32_t)frame_index;          // 3D-DWT decodes in place; coding order == display order
          index[frame_index].ref0 = -1;                            // open-loop GOP — no inter-frame references
          index[frame_index].ref1 = -1;
          index[frame_index].temporal_id = 0;
          index[frame_index].pad = 0;
          index[frame_index].size = (uint32_t)fwrite_frame(container_file, gop_encoded[f], gop_encoded_length[f]);
          frame_index++;
        }
        print_encode_progress(frame_index, total_frames, fps_value, now_milliseconds() - encode_start);
      } else {
        if (debug) {   // --debug: compare the GPU stream byte-for-byte with the CPU encode_gop_3ddwt
          uint8_t *cpu_encoded[MAX_GOP];
          size_t cpu_encoded_length[MAX_GOP];
          encode_gop_3ddwt(gop_rgb, filled, width, height, levels, quality, cpu_encoded, cpu_encoded_length);
          for (int f = 0; f < filled; f++) {
            int same = (cpu_encoded_length[f] == gop_encoded_length[f]) && (memcmp(cpu_encoded[f], gop_encoded[f], cpu_encoded_length[f]) == 0);
            fprintf(stderr, "  [debug] frame %d stream: GPU %zu bytes vs CPU %zu bytes -> %s\n", f, gop_encoded_length[f], cpu_encoded_length[f], same ? "IDENTICAL" : "DIFFER");
            free(cpu_encoded[f]);
          }
        }
        // Self-test: CPU-decode the whole GOP (decode_gop_3ddwt) and score PSNR per frame vs the source.
        decode_gop_3ddwt(gop_encoded, gop_encoded_length, filled, width, height, levels, quality, gop_reconstructed);
        for (int f = 0; f < filled; f++) {
          double mean_squared_error = 0;
          for (size_t i = 0; i < frame_bytes; i++) {
            int difference = (int)gop_rgb[f][i] - (int)gop_reconstructed[f][i];
            mean_squared_error += (double)difference * difference;
          }
          mean_squared_error /= frame_bytes;
          sum_psnr += (mean_squared_error == 0) ? 99.99 : (10.0 * log10((255.0 * 255.0) / mean_squared_error));
          frame_index++;
        }
      }
      for (int f = 0; f < filled; f++) {
        free(gop_encoded[f]);
      }
      if (filled < gop) {
        break;
      }
    }
    for (int g = 0; g < gop; g++) {
      free(gop_rgb[g]);
      free(gop_reconstructed[g]);
    }
    free(gop_rgb);
    free(gop_reconstructed);
    free(gop_encoded);
    free(gop_encoded_length);
    free(mctf_frame_mv);
  } else {
    // Stage B1a: GPU hierarchical-B encode shares this (display-order I/P) loop in CODING order.
    // The driver yields one coding step per iteration into rgb_map; the bidi sets are rebound to the DPB
    // slots; the per-plane transform/quant/pack/reconstruct below is reused verbatim (I/P = use_bframes==0).
    BGpuDriver bgpu = { 0 };
    int b_ref0_slot = -1, b_ref1_slot = -1, b_dst_slot = 0, b_w0 = 0, b_w1 = 0, b_tid = 0;
    int b_ref0_coding = -1, b_ref1_coding = -1, b_type = 0;
    uint32_t b_poc = 0;
    if (use_bframes) {
      bgpu.pipe = input_pipe;
      bgpu.frame_bytes = frame_bytes;
      bgpu.max_frames = max_frames;
      bgpu.period = bframes + 1;
      bgpu.key_interval = (gop > (bframes + 1)) ? ((gop / (bframes + 1)) * (bframes + 1)) : 0;
      for (int s = 0; s <= bgpu.period; s++) {
        bgpu.rgb_slot[s] = checked_malloc(frame_bytes);
      }
      printf("  B-frame mode: %d B between anchors (period %d), keyframe interval %d, chroma=%s (GPU bidi, %s motion%s%s)\n",
             bframes, bframes + 1, bgpu.key_interval,
             (g_chroma_format == 2) ? "4:2:0" : ((g_chroma_format == 1) ? "4:2:2" : "4:4:4"),
             joint_mv ? "joint" : "independent",
             per_block_mode ? ", per-block L0/L1/BI" : "",
             (qp_cascade && !lossless) ? ", QP-cascade" : "");
    }
    for (;;) {
      int b_slide_from = -1;
      if (use_bframes) {
        if (!bgpu_next(&bgpu, rgb_map, frame_index, &b_poc, &b_type, &b_ref0_slot, &b_ref1_slot, &b_dst_slot,
                       &b_w0, &b_w1, &b_tid, &b_ref0_coding, &b_ref1_coding, &b_slide_from)) {
          break;
        }
        // Rebind the B2 motion + blend sets to this step's DPB slots. Search sets bind the current planes +
        // the reference slot + the MV output + a zero temporal predictor; mc sets bind ref + MVs + output;
        // the blend combines the two motion-compensated predictions {difference (mc0), mc1} -> difference.
        if (b_ref0_slot >= 0) {
          bind_storage_buffers(set_me_b0, (VkBuffer[]){ coeff_buffer[0], coeff_buffer[1], coeff_buffer[2],
                               dpb_buffer[b_ref0_slot][0], dpb_buffer[b_ref0_slot][1], dpb_buffer[b_ref0_slot][2], mv_buffer, mv_zero_buffer, sad_buffer }, 9);
          if (g_motion_variable && g_motion_split_bidi) {   // joint B: the 3-size L0 search reads ref0, writes mv8/16/32 (zero predictor)
            bind_storage_buffers(set_me_var8_b0, (VkBuffer[]){ coeff_buffer[0], coeff_buffer[1], coeff_buffer[2],
                                 dpb_buffer[b_ref0_slot][0], dpb_buffer[b_ref0_slot][1], dpb_buffer[b_ref0_slot][2], mv8_buffer, mv_zero_buffer, sad_buffer }, 9);
            bind_storage_buffers(set_me_var16_b0, (VkBuffer[]){ coeff_buffer[0], coeff_buffer[1], coeff_buffer[2],
                                 dpb_buffer[b_ref0_slot][0], dpb_buffer[b_ref0_slot][1], dpb_buffer[b_ref0_slot][2], mv16_buffer, mv_zero_buffer, sad16_buffer }, 9);
            bind_storage_buffers(set_me_var32_b0, (VkBuffer[]){ coeff_buffer[0], coeff_buffer[1], coeff_buffer[2],
                                 dpb_buffer[b_ref0_slot][0], dpb_buffer[b_ref0_slot][1], dpb_buffer[b_ref0_slot][2], mv32_buffer, mv_zero_buffer, sad32_buffer }, 9);
          }
          if (b_ref1_slot >= 0) {
            bind_storage_buffers(set_me_b1, (VkBuffer[]){ coeff_buffer[0], coeff_buffer[1], coeff_buffer[2],
                                 dpb_buffer[b_ref1_slot][0], dpb_buffer[b_ref1_slot][1], dpb_buffer[b_ref1_slot][2], mv1_buffer, mv_zero_buffer, sad_buffer }, 9);
            if (g_motion_variable && g_motion_split_bidi) {   // joint B: the 3-size L1 search reads ref1, writes mv1_8/16/32 + the bidi_mode_sad sets
              bind_storage_buffers(set_me_var8_b1, (VkBuffer[]){ coeff_buffer[0], coeff_buffer[1], coeff_buffer[2],
                                   dpb_buffer[b_ref1_slot][0], dpb_buffer[b_ref1_slot][1], dpb_buffer[b_ref1_slot][2], mv1_8_buffer, mv_zero_buffer, sad_buffer }, 9);
              bind_storage_buffers(set_me_var16_b1, (VkBuffer[]){ coeff_buffer[0], coeff_buffer[1], coeff_buffer[2],
                                   dpb_buffer[b_ref1_slot][0], dpb_buffer[b_ref1_slot][1], dpb_buffer[b_ref1_slot][2], mv1_16_buffer, mv_zero_buffer, sad16_buffer }, 9);
              bind_storage_buffers(set_me_var32_b1, (VkBuffer[]){ coeff_buffer[0], coeff_buffer[1], coeff_buffer[2],
                                   dpb_buffer[b_ref1_slot][0], dpb_buffer[b_ref1_slot][1], dpb_buffer[b_ref1_slot][2], mv1_32_buffer, mv_zero_buffer, sad32_buffer }, 9);
              // bidi_mode_sad sets: cur + ref0(dpb) + ref1(dpb) + mv0_S + mv1_S + modesad_S (one per size).
              bind_storage_buffers(set_bidi_sad8, (VkBuffer[]){ coeff_buffer[0], coeff_buffer[1], coeff_buffer[2],
                                   dpb_buffer[b_ref0_slot][0], dpb_buffer[b_ref0_slot][1], dpb_buffer[b_ref0_slot][2],
                                   dpb_buffer[b_ref1_slot][0], dpb_buffer[b_ref1_slot][1], dpb_buffer[b_ref1_slot][2], mv8_buffer, mv1_8_buffer, modesad8_buffer }, 12);
              bind_storage_buffers(set_bidi_sad16, (VkBuffer[]){ coeff_buffer[0], coeff_buffer[1], coeff_buffer[2],
                                   dpb_buffer[b_ref0_slot][0], dpb_buffer[b_ref0_slot][1], dpb_buffer[b_ref0_slot][2],
                                   dpb_buffer[b_ref1_slot][0], dpb_buffer[b_ref1_slot][1], dpb_buffer[b_ref1_slot][2], mv16_buffer, mv1_16_buffer, modesad16_buffer }, 12);
              bind_storage_buffers(set_bidi_sad32, (VkBuffer[]){ coeff_buffer[0], coeff_buffer[1], coeff_buffer[2],
                                   dpb_buffer[b_ref0_slot][0], dpb_buffer[b_ref0_slot][1], dpb_buffer[b_ref0_slot][2],
                                   dpb_buffer[b_ref1_slot][0], dpb_buffer[b_ref1_slot][1], dpb_buffer[b_ref1_slot][2], mv32_buffer, mv1_32_buffer, modesad32_buffer }, 12);
            }
            if (joint_mv) {   // B2b: refine mv0 vs ref0 with MC_other=MC1(mc1_buffer); refine mv1 vs ref1 with MC_other=MC0(difference_buffer).
              // Predictor = mv_snap = a snapshot of the independent MV (copied just before each refine), so
              // the rate bias keeps the refined MV near the honest motion and the grain zero_bias applies
              // only to genuinely-still blocks (NOT every block, as the zero predictor wrongly did).
              bind_storage_buffers(set_me_bidi0, (VkBuffer[]){ coeff_buffer[0], coeff_buffer[1], coeff_buffer[2],
                                   dpb_buffer[b_ref0_slot][0], dpb_buffer[b_ref0_slot][1], dpb_buffer[b_ref0_slot][2],
                                   mc1_buffer[0], mc1_buffer[1], mc1_buffer[2], mv_buffer, mv_snap_buffer }, 11);
              bind_storage_buffers(set_me_bidi1, (VkBuffer[]){ coeff_buffer[0], coeff_buffer[1], coeff_buffer[2],
                                   dpb_buffer[b_ref1_slot][0], dpb_buffer[b_ref1_slot][1], dpb_buffer[b_ref1_slot][2],
                                   difference_buffer[0], difference_buffer[1], difference_buffer[2], mv1_buffer, mv_snap_buffer }, 11);
            }
          }
        }
        for (int plane = 0; plane < 3; plane++) {
          if (b_ref0_slot >= 0) {
            bind_storage_buffers(set_mc_b0[plane], (VkBuffer[]){ dpb_buffer[b_ref0_slot][plane], mv_buffer, difference_buffer[plane] }, 3);
            if (b_ref1_slot >= 0) {
              bind_storage_buffers(set_mc_b1[plane], (VkBuffer[]){ dpb_buffer[b_ref1_slot][plane], mv1_buffer, mc1_buffer[plane] }, 3);
              bind_storage_buffers(set_bidi_blend[plane], (VkBuffer[]){ difference_buffer[plane], mc1_buffer[plane], difference_buffer[plane] }, 3);
            }
          }
          bind_storage_buffers(set_motion_add_bidi[plane], (VkBuffer[]){ coeff_buffer[plane], difference_buffer[plane], dpb_buffer[b_dst_slot][plane] }, 3);
        }
      } else {
        if (!((fread(rgb, 1, frame_bytes, input_pipe) == frame_bytes) && (!max_frames || (frame_index < max_frames)))) {
          break;
        }
        if (hdr_mode) {   // HDR (PQ or HLG): rgb48le (10-bit << 6) -> 12-bit BT.2020 code, both unsigned [0,1]
          const uint16_t *source16 = (const uint16_t *)rgb;
          int16_t *destination16 = (int16_t *)rgb_map;
          for (int s = 0; s < pixel_count * 3; s++) {
            destination16[s] = (int16_t)(source16[s] >> 4);
          }
        } else {
          memcpy(rgb_map, rgb, frame_bytes);
        }
      }
      // --vbr: at each GOP boundary, nudge Q toward the target bitrate (per-GOP variable Q). Lossy only.
      if (((((vbr && !lossless) && !use_bframes) && (frame_index % gop == 0))) && frame_index > 0) {
        // Rate-control off the ACTUAL on-disk bitrate (sum the written index entries = post LZSS/LZBRRC), so --vbr
        // targets the real file size. Only the output path writes frames; the no-output self-test keeps total_bytes
        // (uncompressed = the only size there).
        unsigned long long bytes_so_far = total_bytes;
        if (output) {
          bytes_so_far = 0;
          for (long fi = 0; fi < frame_index; fi++) {
            bytes_so_far += index[fi].size;
          }
        }
        double running_bpp = ((double)bytes_so_far * 8.0) / ((double)frame_index * pixel_count);
        if (running_bpp > vbr_target_bpp && current_quality < 31) {
          current_quality++;
        } else if (running_bpp < vbr_target_bpp && current_quality > 1) {
          current_quality--;
        }
        for (int plane = 0; plane < 3; plane++) {   // per-plane quant map (see the initial build above)
          int plane_w = plane_width(plane, width), plane_h = plane_height(plane, height);
          build_quantization_steps(step, plane_w, plane_h, levels, current_quality);
          memcpy(step_map[plane], step, (size_t)(plane_w * plane_h) * 4);
        }
      }
      int p_eligible = ((!use_bframes) && predictive) && (frame_index % gop != 0);   // a P-frame is allowed; the decision below picks I or P
      int is_predicted = use_bframes ? (b_type != 0) : 0;   // B-stream: I=0, P/B predicted (the type comes from the coding-order driver)

      // Phase 3: QP-cascading — deeper B-frames (higher temporal_id) get a coarser quant (they are referenced
      // less, so the coarser step saves bits with little visible loss). Rebuild the per-plane step map with the
      // cascaded quality; anchors (temporal_id 0 -> scale 1) keep the base quality. Lossy B-streams only; the
      // cascaded quality is stored per FrameEntry so the decoder dequantises identically.
      int frame_quality = current_quality;
      if (((use_bframes && qp_cascade) && !lossless)) {
        frame_quality = (int)(((float)current_quality * temporal_quant_scale(b_tid)) + 0.5f);
        if (frame_quality < 1) { frame_quality = 1; }
        if (frame_quality > 31) { frame_quality = 31; }
        for (int plane = 0; plane < 3; plane++) {
          int pw = plane_width(plane, width), ph = plane_height(plane, height);
          build_quantization_steps(step, pw, ph, levels, frame_quality);
          memcpy(step_map[plane], step, (size_t)(pw * ph) * 4);
        }
      }

      // colordiff (B): lean scene-cut detector. Colour the frame, sum the L1 residual against the
      // previous reconstructed frame, and decide I-vs-P BEFORE the subtract — a sudden cut spikes the
      // residual, so we keep a (cheaper, ghost-free) I-frame; normal motion stays a P-frame. (coefdiff
      // uses its own exact size-based decision after pass 1 instead.)
      if (method == 1 && p_eligible) {
        *(uint32_t *)energy_map = 0;
        begin_recording();
        int32_t colour_push[2] = { width, height };
        vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_colour);
        vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_colour, 0, 1, &set_colour, 0, 0);
        vkCmdPushConstants(command_buffer, pipeline_layout_colour, VK_SHADER_STAGE_COMPUTE_BIT, 0, 8, colour_push);
        vkCmdDispatch(command_buffer, pixel_workgroups, 1, 1);
        memory_barrier();
        int32_t energy_push[2] = { pixel_count, lossless };
        for (int plane = 0; plane < 3; plane++) {
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_energy);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_pack, 0, 1, &set_energy[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_pack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 8, energy_push);
          vkCmdDispatch(command_buffer, pixel_workgroups, 1, 1);
        }
        submit_and_wait();
        uint32_t residual_l1 = *(uint32_t *)energy_map;
        double average_residual = (double)residual_l1 / (3.0 * pixel_count);
        is_predicted = average_residual < 32.0;   // SCENE_CUT threshold (avg per-pixel L1 residual); tunable
        if (debug) fprintf(stderr, "  frame %ld: avg_residual=%.1f -> %s\n", frame_index, average_residual, is_predicted ? "P" : "I (cut)");
      }

      // ---- GPU pass 1: colour transform + forward wavelet + quant + per-block size ----
      begin_recording();
      int32_t colour_push[2] = { width, height };
      vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_colour);
      vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_colour, 0, 1, &set_colour, 0, 0);
      vkCmdPushConstants(command_buffer, pipeline_layout_colour, VK_SHADER_STAGE_COMPUTE_BIT, 0, 8, colour_push);
      vkCmdDispatch(command_buffer, pixel_workgroups, 1, 1);
      memory_barrier();

      // colordiff (B) P-frame: search for per-16x16-block motion vectors (luma) into mv_buffer, before
      // mc.comp uses them. One workgroup per block. (Skipped for the B-stream: Stage B1 is zero-MV.)
      if ((((!use_bframes) && (method == 1)) && is_predicted) && (!g_motion_variable)) {
        // Snapshot the previous frame's MVs (still in mv_buffer from the last frame) into mv_prev as this
        // frame's temporal predictor, before the search overwrites mv_buffer.
        VkBufferCopy mv_copy = { 0, 0, (((VkDeviceSize)motion_blocks_x * motion_blocks_y) * 2) * 4 };
        vkCmdCopyBuffer(command_buffer, mv_buffer, mv_prev_buffer, 1, &mv_copy);
        VkMemoryBarrier copy_barrier = { VK_STRUCTURE_TYPE_MEMORY_BARRIER };
        copy_barrier.srcAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
        copy_barrier.dstAccessMask = VK_ACCESS_SHADER_READ_BIT;
        vkCmdPipelineBarrier(command_buffer, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, 0, 1, &copy_barrier, 0, 0, 0, 0);
        int32_t me_push[4] = { width, height, motion_blocks_x, lossless };
        vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_motion_estimate);
        vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_motion_estimate, 0, 1, &set_motion_estimate, 0, 0);
        vkCmdPushConstants(command_buffer, pipeline_layout_motion_estimate, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, me_push);
        vkCmdDispatch(command_buffer, motion_blocks_x * motion_blocks_y, 1, 1);
        memory_barrier();
      }

      // Variable-motion P-frame: motion-search at 8/16/32 (mv8/16/32 + sad8/16/32, zero predictor), then the
      // R-D merge picks per-32-root the cheapest 32/16/8 partition and writes the chosen leaf MVs into the
      // fine 8-grid mv_buffer. mc.comp (g_motion_block==8) then runs unchanged; the CPU codes mv_map as a quadtree.
      if (((!use_bframes) && (method == 1)) && is_predicted && g_motion_variable) {
        int g16x = (width + 15) / 16, g16y = (height + 15) / 16;
        int g32x = (width + 31) / 32, g32y = (height + 31) / 32;
        int32_t me8_push[4]  = { width, height, motion_blocks_x, lossless };   // motion_blocks_x = fgx (8-grid)
        int32_t me16_push[4] = { width, height, g16x, lossless };
        int32_t me32_push[4] = { width, height, g32x, lossless };
        vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_motion_estimate);
        vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_motion_estimate, 0, 1, &set_me_var8, 0, 0);
        vkCmdPushConstants(command_buffer, pipeline_layout_motion_estimate, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, me8_push);
        vkCmdDispatch(command_buffer, motion_blocks_x * motion_blocks_y, 1, 1);
        vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_me_16);
        vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_motion_estimate, 0, 1, &set_me_var16, 0, 0);
        vkCmdPushConstants(command_buffer, pipeline_layout_motion_estimate, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, me16_push);
        vkCmdDispatch(command_buffer, g16x * g16y, 1, 1);
        vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_me_32);
        vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_motion_estimate, 0, 1, &set_me_var32, 0, 0);
        vkCmdPushConstants(command_buffer, pipeline_layout_motion_estimate, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, me32_push);
        vkCmdDispatch(command_buffer, g32x * g32y, 1, 1);
        memory_barrier();
        // Adaptive frame-level lambda: scale the absolute leaf cost by the previous frame's average 32-block SAD
        // (motion energy). Uniformly-high-motion frames -> high lambda -> the merge resists splitting; frames with
        // only LOCALLY-strong motion (low average) -> low lambda -> the strong-motion regions split. 0-lag default 256.
        int merge_lambda_abs = g_motion_lambda_abs;
        if (g_motion_lambda_alpha > 0) {
          int adaptive = (g_motion_lambda_alpha * prev_avg_sad) >> 8;
          merge_lambda_abs = (adaptive > g_motion_lambda_abs) ? adaptive : g_motion_lambda_abs;
        }
        int32_t merge_push[7] = { motion_blocks_x, motion_blocks_y, g16x, g16y, g32x, g32y, merge_lambda_abs };   // [6]=abs
        vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_merge);
        vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_merge, 0, 1, &set_merge, 0, 0);
        vkCmdPushConstants(command_buffer, pipeline_layout_merge, VK_SHADER_STAGE_COMPUTE_BIT, 0, 28, merge_push);
        vkCmdDispatch(command_buffer, ((g32x * g32y) + 63) / 64, 1, 1);
        memory_barrier();   // merge mv_buffer write -> mc read (downstream)
        // Snapshot this frame's per-size searches into the temporal predictors for the next frame. Barrier
        // compute -> transfer: the ME's writes to mvN must be visible to the copy read, and the ME's reads
        // of mvN_prev must finish before the copy overwrites mvN_prev (WAR).
        VkMemoryBarrier pre_copy = { VK_STRUCTURE_TYPE_MEMORY_BARRIER };
        pre_copy.srcAccessMask = VK_ACCESS_SHADER_WRITE_BIT | VK_ACCESS_SHADER_READ_BIT;
        pre_copy.dstAccessMask = VK_ACCESS_TRANSFER_READ_BIT | VK_ACCESS_TRANSFER_WRITE_BIT;
        vkCmdPipelineBarrier(command_buffer, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 1, &pre_copy, 0, 0, 0, 0);
        VkBufferCopy c8  = { 0, 0, (((VkDeviceSize)motion_blocks_x * motion_blocks_y) * 2) * 4 };
        VkBufferCopy c16 = { 0, 0, (((VkDeviceSize)g16x * g16y) * 2) * 4 };
        VkBufferCopy c32 = { 0, 0, (((VkDeviceSize)g32x * g32y) * 2) * 4 };
        vkCmdCopyBuffer(command_buffer, mv8_buffer,  mv8_prev_buffer,  1, &c8);
        vkCmdCopyBuffer(command_buffer, mv16_buffer, mv16_prev_buffer, 1, &c16);
        vkCmdCopyBuffer(command_buffer, mv32_buffer, mv32_prev_buffer, 1, &c32);
        VkMemoryBarrier snap_barrier = { VK_STRUCTURE_TYPE_MEMORY_BARRIER };
        snap_barrier.srcAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
        snap_barrier.dstAccessMask = VK_ACCESS_SHADER_READ_BIT;
        vkCmdPipelineBarrier(command_buffer, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, 0, 1, &snap_barrier, 0, 0, 0, 0);
      }

      // Stage B2: bidirectional motion search — current vs ref0 -> mv_buffer (L0), and for a
      // B-frame current vs ref1 -> mv1_buffer (L1). Independent searches with a zero temporal predictor.
      if ((use_bframes && is_predicted) && (!(g_motion_variable && g_motion_split_bidi))) {   // fast single-ref 2-ME L0/L1 (fixed, or the default variable B)
        int32_t me_push[4] = { width, height, motion_blocks_x, lossless };
        vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_motion_estimate);
        vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_motion_estimate, 0, 1, &set_me_b0, 0, 0);
        vkCmdPushConstants(command_buffer, pipeline_layout_motion_estimate, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, me_push);
        vkCmdDispatch(command_buffer, motion_blocks_x * motion_blocks_y, 1, 1);
        memory_barrier();
        if (b_ref1_slot >= 0) {
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_motion_estimate, 0, 1, &set_me_b1, 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_motion_estimate, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, me_push);
          vkCmdDispatch(command_buffer, motion_blocks_x * motion_blocks_y, 1, 1);
          memory_barrier();
        }
      }

      // Stage 2b: variable-motion B path. P-anchor (no ref1) = single-ref L0 merge -> mv_buffer (like the P path).
      // True B-frame = 3-size L0 (vs ref0 -> mv8/16/32) AND L1 (vs ref1 -> mv1_8/16/32) searches, then bidi_mode_sad
      // gives the per-block [L0,L1,BI] SADs at each size, and motion_merge_bidi picks the partition + the per-leaf mode
      // (mode-aware, bidirectional R-D) and writes mv0 (-> mv_buffer), mv1 (-> mv1_buffer) and the mode (-> mode_buffer).
      if (((use_bframes && is_predicted) && g_motion_variable) && g_motion_split_bidi) {
        int g16x = (width + 15) / 16, g16y = (height + 15) / 16;
        int g32x = (width + 31) / 32, g32y = (height + 31) / 32;
        int merge_lambda_abs = g_motion_lambda_abs;
        if (g_motion_lambda_alpha > 0) {
          int adaptive = (g_motion_lambda_alpha * prev_avg_sad) >> 8;
          merge_lambda_abs = (adaptive > g_motion_lambda_abs) ? adaptive : g_motion_lambda_abs;
        }
        int32_t me8_push[4]  = { width, height, motion_blocks_x, lossless };
        int32_t me16_push[4] = { width, height, g16x, lossless };
        int32_t me32_push[4] = { width, height, g32x, lossless };
        int32_t merge_push[7] = { motion_blocks_x, motion_blocks_y, g16x, g16y, g32x, g32y, merge_lambda_abs };
        // L0 search at 8/16/32 -> mv8/16/32.
        vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_motion_estimate);
        vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_motion_estimate, 0, 1, &set_me_var8_b0, 0, 0);
        vkCmdPushConstants(command_buffer, pipeline_layout_motion_estimate, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, me8_push);
        vkCmdDispatch(command_buffer, motion_blocks_x * motion_blocks_y, 1, 1);
        vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_me_16);
        vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_motion_estimate, 0, 1, &set_me_var16_b0, 0, 0);
        vkCmdPushConstants(command_buffer, pipeline_layout_motion_estimate, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, me16_push);
        vkCmdDispatch(command_buffer, g16x * g16y, 1, 1);
        vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_me_32);
        vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_motion_estimate, 0, 1, &set_me_var32_b0, 0, 0);
        vkCmdPushConstants(command_buffer, pipeline_layout_motion_estimate, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, me32_push);
        vkCmdDispatch(command_buffer, g32x * g32y, 1, 1);
        memory_barrier();
        if (b_ref1_slot < 0) {   // P-anchor: single-ref L0 merge -> mv_buffer
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_merge);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_merge, 0, 1, &set_merge, 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_merge, VK_SHADER_STAGE_COMPUTE_BIT, 0, 28, merge_push);
          vkCmdDispatch(command_buffer, ((g32x * g32y) + 63) / 64, 1, 1);
          memory_barrier();
        } else {                 // true B-frame: L1 search, bidi_mode_sad, joint mode-aware merge
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_motion_estimate);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_motion_estimate, 0, 1, &set_me_var8_b1, 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_motion_estimate, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, me8_push);
          vkCmdDispatch(command_buffer, motion_blocks_x * motion_blocks_y, 1, 1);
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_me_16);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_motion_estimate, 0, 1, &set_me_var16_b1, 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_motion_estimate, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, me16_push);
          vkCmdDispatch(command_buffer, g16x * g16y, 1, 1);
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_me_32);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_motion_estimate, 0, 1, &set_me_var32_b1, 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_motion_estimate, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, me32_push);
          vkCmdDispatch(command_buffer, g32x * g32y, 1, 1);
          memory_barrier();
          int32_t bs8_push[6]  = { width, height, motion_blocks_x, lossless, b_w0, b_w1 };
          int32_t bs16_push[6] = { width, height, g16x, lossless, b_w0, b_w1 };
          int32_t bs32_push[6] = { width, height, g32x, lossless, b_w0, b_w1 };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_bidi_sad_8);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_bidi_sad, 0, 1, &set_bidi_sad8, 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_bidi_sad, VK_SHADER_STAGE_COMPUTE_BIT, 0, 24, bs8_push);
          vkCmdDispatch(command_buffer, motion_blocks_x * motion_blocks_y, 1, 1);
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_bidi_sad_16);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_bidi_sad, 0, 1, &set_bidi_sad16, 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_bidi_sad, VK_SHADER_STAGE_COMPUTE_BIT, 0, 24, bs16_push);
          vkCmdDispatch(command_buffer, g16x * g16y, 1, 1);
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_bidi_sad_32);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_bidi_sad, 0, 1, &set_bidi_sad32, 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_bidi_sad, VK_SHADER_STAGE_COMPUTE_BIT, 0, 24, bs32_push);
          vkCmdDispatch(command_buffer, g32x * g32y, 1, 1);
          memory_barrier();
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_merge_bidi);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_merge_bidi, 0, 1, &set_merge_bidi, 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_merge_bidi, VK_SHADER_STAGE_COMPUTE_BIT, 0, 28, merge_push);
          vkCmdDispatch(command_buffer, ((g32x * g32y) + 63) / 64, 1, 1);
          memory_barrier();
        }
      }

      // Stage B2b: joint/iterative refinement (B-frames only) — minimise the BLENDED residual.
      // Re-search mv0 vs ref0 with MC_other = MC(ref1, mv1) (mc1_buffer); then re-search mv1 vs ref1 with
      // MC_other = MC(ref0, mv0_refined) (difference_buffer). One iteration each; the per-plane loop and the
      // MV payload below then use the refined mv_buffer / mv1_buffer.
      if (((((use_bframes && joint_mv) && is_predicted) && (b_ref1_slot >= 0))) && (!g_motion_variable)) {   // joint refine is single-size; skip for variable
        for (int plane = 0; plane < 3; plane++) {   // MC1 = MC(ref1, mv1) -> mc1_buffer
          int plane_w = plane_width(plane, width), plane_h = plane_height(plane, height);
          int32_t mc_push[3] = { plane_w, plane_h, ((plane_w + g_motion_block) - 1) / g_motion_block };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_mc);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_pack, 0, 1, &set_mc_b1[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_pack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 12, mc_push);
          vkCmdDispatch(command_buffer, ((plane_w * plane_h) + 255) / 256, 1, 1);
        }
        memory_barrier();
        snapshot_motion_vectors(command_buffer, mv_buffer, mv_snap_buffer, motion_blocks_x, motion_blocks_y);   // independent mv0 -> the joint-search predictor
        int32_t bidi_push0[6] = { width, height, motion_blocks_x, lossless, b_w0, b_w1 };   // refine mv0 (self=ref0)
        vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_me_bidi);
        vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_me_bidi, 0, 1, &set_me_bidi0, 0, 0);
        vkCmdPushConstants(command_buffer, pipeline_layout_me_bidi, VK_SHADER_STAGE_COMPUTE_BIT, 0, 24, bidi_push0);
        vkCmdDispatch(command_buffer, motion_blocks_x * motion_blocks_y, 1, 1);
        memory_barrier();
        for (int plane = 0; plane < 3; plane++) {   // MC0 = MC(ref0, mv0_refined) -> difference_buffer
          int plane_w = plane_width(plane, width), plane_h = plane_height(plane, height);
          int32_t mc_push[3] = { plane_w, plane_h, ((plane_w + g_motion_block) - 1) / g_motion_block };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_mc);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_pack, 0, 1, &set_mc_b0[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_pack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 12, mc_push);
          vkCmdDispatch(command_buffer, ((plane_w * plane_h) + 255) / 256, 1, 1);
        }
        memory_barrier();
        snapshot_motion_vectors(command_buffer, mv1_buffer, mv_snap_buffer, motion_blocks_x, motion_blocks_y);   // independent mv1 -> the joint-search predictor
        int32_t bidi_push1[6] = { width, height, motion_blocks_x, lossless, b_w1, b_w0 };   // refine mv1 (self=ref1)
        vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_me_bidi);
        vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_me_bidi, 0, 1, &set_me_bidi1, 0, 0);
        vkCmdPushConstants(command_buffer, pipeline_layout_me_bidi, VK_SHADER_STAGE_COMPUTE_BIT, 0, 24, bidi_push1);
        vkCmdDispatch(command_buffer, motion_blocks_x * motion_blocks_y, 1, 1);
        memory_barrier();
      }

      // Phase 2: per-block prediction-mode decision (B-frames only). Compute MC0 (all planes) ->
      // difference_buffer and MC1 (all planes) -> mc1_buffer, then mode_decide picks L0/L1/BI per block. The
      // per-plane loop below then applies the chosen mode (blend_mode) instead of an unconditional BI blend.
      if ((((use_bframes && per_block_mode) && is_predicted) && (b_ref1_slot >= 0))) {
        for (int plane = 0; plane < 3; plane++) {   // MC0 = MC(ref0, mv0) -> difference_buffer
          int plane_w = plane_width(plane, width), plane_h = plane_height(plane, height);
          int32_t mc_push[3] = { plane_w, plane_h, ((plane_w + g_motion_block) - 1) / g_motion_block };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_mc);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_pack, 0, 1, &set_mc_b0[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_pack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 12, mc_push);
          vkCmdDispatch(command_buffer, ((plane_w * plane_h) + 255) / 256, 1, 1);
        }
        for (int plane = 0; plane < 3; plane++) {   // MC1 = MC(ref1, mv1) -> mc1_buffer
          int plane_w = plane_width(plane, width), plane_h = plane_height(plane, height);
          int32_t mc_push[3] = { plane_w, plane_h, ((plane_w + g_motion_block) - 1) / g_motion_block };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_mc);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_pack, 0, 1, &set_mc_b1[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_pack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 12, mc_push);
          vkCmdDispatch(command_buffer, ((plane_w * plane_h) + 255) / 256, 1, 1);
        }
        memory_barrier();
        if (!(g_motion_variable && g_motion_split_bidi)) {   // joint B already wrote mode_buffer (merge_bidi); else mode_decide runs
          if (g_motion_variable) {   // --motion-split-fast: coarse per-32-root mode (16x fewer workgroups, writes the 8-grid uniformly)
            int g32x = (width + 31) / 32, g32y = (height + 31) / 32;
            int32_t root_push[9] = { width, height, motion_blocks_x, motion_blocks_y, g32x, lossless, b_w0, b_w1, bi_penalty };
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_mode_decide_root);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_mode_root, 0, 1, &set_mode_decide, 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_mode_root, VK_SHADER_STAGE_COMPUTE_BIT, 0, 36, root_push);
            vkCmdDispatch(command_buffer, g32x * g32y, 1, 1);
          } else {                   // fixed path: per-block mode_decide
            int32_t mode_push[7] = { width, height, motion_blocks_x, lossless, b_w0, b_w1, bi_penalty };   // R-D: BI pays for its 2nd MV
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_mode_decide);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_mode_decide, 0, 1, &set_mode_decide, 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_mode_decide, VK_SHADER_STAGE_COMPUTE_BIT, 0, 28, mode_push);
            vkCmdDispatch(command_buffer, motion_blocks_x * motion_blocks_y, 1, 1);
          }
          memory_barrier();
        }
      }

      // Chroma subsampling (Variante A): box-average the full-res Co/Cg planes down to their subsampled
      // size BEFORE the wavelet (lossy 9/7 path only; 4:4:4 and the lossless 5/3 path stay full-res). To
      // avoid an in-place read/write race, write the small plane into scratch_buffer (a full-plane device
      // buffer, free here) then copy the small bytes back into coeff_buffer[plane].
      if ((g_chroma_format != 0) && !lossless) {
        for (int plane = 1; plane < 3; plane++) {
          int small_w = plane_width(plane, width), small_h = plane_height(plane, height);
          int small_pixels = small_w * small_h;
          int32_t downsample_push[4] = { width, height, chroma_shift_x(), chroma_shift_y() };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_chroma_downsample);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_chroma_downsample, 0, 1, &set_coeff_to_scratch[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_chroma_downsample, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, downsample_push);
          vkCmdDispatch(command_buffer, (small_pixels + 255) / 256, 1, 1);
          memory_barrier();
          VkBufferCopy chroma_copy = { 0, 0, (VkDeviceSize)small_pixels * 4 };   // only the small bytes
          vkCmdCopyBuffer(command_buffer, scratch_buffer, coeff_buffer[plane], 1, &chroma_copy);
          VkMemoryBarrier copy_barrier = { VK_STRUCTURE_TYPE_MEMORY_BARRIER };
          copy_barrier.srcAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
          copy_barrier.dstAccessMask = VK_ACCESS_SHADER_READ_BIT | VK_ACCESS_SHADER_WRITE_BIT;
          vkCmdPipelineBarrier(command_buffer, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, 0, 1, &copy_barrier, 0, 0, 0, 0);
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
        int blocks_x = block_count_x(plane_w), blocks_y = block_count_y(plane_h);
        int block_count = blocks_x * blocks_y;
        int pixel_workgroups = (plane_pixels + 255) / 256;
        int block_workgroups = (g_block_size == 128) ? block_count : ((block_count + 63) / 64);   // coop (128): one workgroup per block (bitplane size/pack/pcrd)
        int plane_motion_blocks_x = ((plane_w + g_motion_block) - 1) / g_motion_block;
        // Level sizes for this plane, finest to coarsest.
        int level_width[16], level_height[16], level_count = 0, current_width = plane_w, current_height = plane_h;
        for (int level = 0; ((level < levels) && (current_width >= 2)) && current_height >= 2; level++) {
          level_width[level_count] = current_width;
          level_height[level_count] = current_height;
          level_count++;
          current_width = (current_width + 1) / 2;
          current_height = (current_height + 1) / 2;
        }
        // colordiff (B) P-frame: subtract the previous reconstructed YCoCg BEFORE the wavelet, so the
        // transform sees the spatial residual (current - previous), in place.
        if (use_bframes) {
          // B-stream (Stage B2, bidirectional motion): mc0 = MC(ref0, mv0) -> difference_buffer; for a
          // B-frame also mc1 = MC(ref1, mv1) -> mc1_buffer, then bidi_blend combines {difference, mc1} ->
          // difference (the weighted prediction); finally ycocg_diff subtracts it (the single-ref path).
          if (is_predicted) {
            if ((per_block_mode && b_ref1_slot >= 0)) {
              // Phase 2: MC0 (difference) and MC1 (mc1) were computed for all planes in the pre-pass and the
              // per-block mode was decided; apply the chosen mode (L0/L1/BI) into difference_buffer in place.
              int32_t mode_blend_push[5] = { plane_w, plane_h, plane_motion_blocks_x, b_w0, b_w1 };
              vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_blend_mode);
              vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_blend_mode, 0, 1, &set_blend_mode[plane], 0, 0);
              vkCmdPushConstants(command_buffer, pipeline_layout_blend_mode, VK_SHADER_STAGE_COMPUTE_BIT, 0, 20, mode_blend_push);
              vkCmdDispatch(command_buffer, pixel_workgroups, 1, 1);
              memory_barrier();
            } else {
            int32_t mc_push[3] = { plane_w, plane_h, plane_motion_blocks_x };
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_mc);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_pack, 0, 1, &set_mc_b0[plane], 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_pack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 12, mc_push);
            vkCmdDispatch(command_buffer, pixel_workgroups, 1, 1);
            memory_barrier();
            if (b_ref1_slot >= 0) {
              vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_pack, 0, 1, &set_mc_b1[plane], 0, 0);
              vkCmdPushConstants(command_buffer, pipeline_layout_pack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 12, mc_push);
              vkCmdDispatch(command_buffer, pixel_workgroups, 1, 1);
              memory_barrier();
              int32_t blend_push[3] = { plane_pixels, b_w0, b_w1 };
              vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_bidi_blend);
              vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_pack, 0, 1, &set_bidi_blend[plane], 0, 0);
              vkCmdPushConstants(command_buffer, pipeline_layout_pack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 12, blend_push);
              vkCmdDispatch(command_buffer, pixel_workgroups, 1, 1);
              memory_barrier();
            }
            }
            int32_t diff_push[2] = { plane_pixels, lossless };
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_ycocg_diff);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_add, 0, 1, &set_ycocg_mc[plane], 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_add, VK_SHADER_STAGE_COMPUTE_BIT, 0, 8, diff_push);
            vkCmdDispatch(command_buffer, pixel_workgroups, 1, 1);
            memory_barrier();
          }
        } else if (method == 1 && is_predicted) {
          // Motion-compensate the previous reconstructed frame (mc_prev = MC(prev, MVs)), then subtract
          // it as the residual. (With all-zero MVs, mc_prev == prev == plain colordiff.)
          int32_t mc_push[3] = { plane_w, plane_h, plane_motion_blocks_x };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_mc);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_pack, 0, 1, &set_mc[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_pack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 12, mc_push);
          vkCmdDispatch(command_buffer, pixel_workgroups, 1, 1);
          memory_barrier();
          int32_t diff_push[2] = { plane_pixels, lossless };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_ycocg_diff);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_add, 0, 1, &set_ycocg_mc[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_add, VK_SHADER_STAGE_COMPUTE_BIT, 0, 8, diff_push);
          vkCmdDispatch(command_buffer, pixel_workgroups, 1, 1);
          memory_barrier();
        }
        // Forward 2D wavelet: rows then columns at each level (finest first), with a transpose
        // turning the column pass into another row pass.
        for (int level = 0; level < level_count; level++) {
          int level_w = level_width[level];
          int level_h = level_height[level];

          int32_t row_push_1[4] = { plane_w, level_w, level_h, 1 };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_forward_row);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_row, 0, 1, &set_row[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_row, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, row_push_1);
          vkCmdDispatch(command_buffer, level_h, 1, 1);
          memory_barrier();

          // coeff (stride plane_w) -> scratch (stride scratch_stride): dest is scratch.
          int32_t transpose_push_1[4] = { plane_w, level_w, level_h, scratch_stride };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_transpose);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_transpose, 0, 1, &set_coeff_to_scratch[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_transpose, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, transpose_push_1);
          vkCmdDispatch(command_buffer, (level_w + 15) / 16, (level_h + 15) / 16, 1);
          memory_barrier();

          // Row pass on scratch: stride scratch_stride.
          int32_t row_push_2[4] = { scratch_stride, level_h, level_w, 1 };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_forward_row);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_row, 0, 1, &set_row_scratch, 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_row, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, row_push_2);
          vkCmdDispatch(command_buffer, level_w, 1, 1);
          memory_barrier();

          // scratch (stride scratch_stride) -> coeff (stride plane_w): dest is coeff.
          int32_t transpose_push_2[4] = { scratch_stride, level_h, level_w, plane_w };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_transpose);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_transpose, 0, 1, &set_scratch_to_coeff[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_transpose, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, transpose_push_2);
          vkCmdDispatch(command_buffer, (level_h + 15) / 16, (level_w + 15) / 16, 1);
          memory_barrier();
        }

        int32_t pixel_count_push = plane_pixels;
        int32_t quant_push[2];   // { plane_pixels, chroma_multiplier } — chroma planes get a coarser step
        quant_push[0] = plane_pixels;
        float chroma_multiplier = (plane == 0) ? 1.0f : g_chroma_quant;
        memcpy(&quant_push[1], &chroma_multiplier, sizeof(float));
        if (!lossless) {
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_quant);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_quant, 0, 1, &set_quant[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_quant, VK_SHADER_STAGE_COMPUTE_BIT, 0, 8, quant_push);
          vkCmdDispatch(command_buffer, pixel_workgroups, 1, 1);
          memory_barrier();
        }

        // PCRD (--pcrd): R-D truncate the low bit-planes per block, in place on coeff_buffer, BEFORE the
        // bitplane size/pack AND the closed-loop reconstruction (dequant_inverse), so all three see the
        // same truncated coefficients and the reference cannot drift. set_row binds {coeff_buffer[plane]}.
        if (!lossless && pcrd_lambda > 0.0) {
          struct { int32_t width, height, blocks_x, blocks_y; float lambda; } pcrd_push =
              { plane_w, plane_h, blocks_x, blocks_y, (float)pcrd_lambda };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_apply_pcrd);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_pcrd, 0, 1, &set_row[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_pcrd, VK_SHADER_STAGE_COMPUTE_BIT, 0, 20, &pcrd_push);
          vkCmdDispatch(command_buffer, block_workgroups, 1, 1);
          memory_barrier();
        }

        // P-frame: write (current - previous) into the difference buffer and save current as the next
        // frame's reference. The intra source (coeff_buffer) is left intact, so a later size-based
        // decision could still pack it; for now is_predicted picks the source per the fixed GOP.
        if (method == 0 && predictive) {
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_coeff_diff);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_coeff_diff, 0, 1, &set_diff[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_coeff_diff, VK_SHADER_STAGE_COMPUTE_BIT, 0, 4, &pixel_count_push);
          vkCmdDispatch(command_buffer, pixel_workgroups, 1, 1);
          memory_barrier();
        }

        // Size every block twice: the intra source always, and (for a P-eligible frame) the difference,
        // so the smaller of the two can be chosen after this pass (scene-cut safe).
        int32_t block_push[4] = { plane_w, plane_h, blocks_x, blocks_y };
        vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_size);
        vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_size, 0, 1, &set_size[plane], 0, 0);
        vkCmdPushConstants(command_buffer, pipeline_layout_size, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, block_push);
        vkCmdDispatch(command_buffer, block_workgroups, 1, 1);
        memory_barrier();
        if (method == 0 && p_eligible) {
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_size, 0, 1, &set_size_diff[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_size, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, block_push);
          vkCmdDispatch(command_buffer, block_workgroups, 1, 1);
          memory_barrier();
        }
      }
      submit_and_wait();

      // Per-plane block counts (chroma fewer when subsampled; 4:4:4 -> all equal the frame block_count).
      int block_counts[3];
      for (int plane = 0; plane < 3; plane++) {
        block_counts[plane] = block_count_x(plane_width(plane, width)) * block_count_y(plane_height(plane, height));
      }

      // ---- size-based I/P decision: a P-frame only if the difference packs smaller than the intra frame.
      // A scene cut / sudden new content makes the difference large, so this falls back to an I-frame and
      // avoids spending bits (and, in lossy mode later, artefacts) on a useless prediction. ----
      // coefdiff (A): exact size-based decision (colordiff already decided via the energy detector above).
      if (method == 0 && p_eligible) {
        uint64_t intra_total = 0, predicted_total = 0;
        for (int plane = 0; plane < 3; plane++) {
          const uint32_t *cur_sizes = size_map[plane];
          const uint32_t *diff_sizes = size_map_diff[plane];
          for (int block = 0; block < block_counts[plane]; block++) {
            intra_total += cur_sizes[block];
            predicted_total += diff_sizes[block];
          }
        }
        is_predicted = predicted_total < intra_total;
      }

      // ---- prefix-sum the chosen per-block sizes into byte offsets (CPU; a GPU scan is a later refinement) ----
      uint32_t cumulative = 0;
      for (int plane = 0; plane < 3; plane++) {
        const uint32_t *sizes = (method == 0 && is_predicted) ? size_map_diff[plane] : size_map[plane];
        for (int block = 0; block < block_counts[plane]; block++) {
          offsets[plane][block] = cumulative;
          cumulative += sizes[block];
        }
        memcpy(offset_map[plane], offsets[plane], (size_t)block_counts[plane] * 4);
      }
      size_t data_length = cumulative;

      // ---- GPU pass 2: pack each block's bytes at its offset ----
      begin_recording();
      for (int plane = 0; plane < 3; plane++) {
        // Per-plane dimensions (see pass 1); 4:4:4 -> these equal the frame dims.
        int plane_w = plane_width(plane, width), plane_h = plane_height(plane, height);
        int scratch_stride = (plane_w > plane_h) ? plane_w : plane_h;
        int plane_pixels = plane_w * plane_h;
        int blocks_x = block_count_x(plane_w), blocks_y = block_count_y(plane_h);
        int block_count = blocks_x * blocks_y;
        int pixel_workgroups = (plane_pixels + 255) / 256;
        int block_workgroups = (g_block_size == 128) ? block_count : ((block_count + 63) / 64);   // coop (128): one workgroup per block (bitplane size/pack/pcrd)
        int level_width[16], level_height[16], level_count = 0, current_width = plane_w, current_height = plane_h;
        for (int level = 0; ((level < levels) && (current_width >= 2)) && current_height >= 2; level++) {
          level_width[level_count] = current_width;
          level_height[level_count] = current_height;
          level_count++;
          current_width = (current_width + 1) / 2;
          current_height = (current_height + 1) / 2;
        }
        int32_t block_push[4] = { plane_w, plane_h, blocks_x, blocks_y };
        vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_pack);
        vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_pack, 0, 1, (method == 0 && is_predicted) ? &set_pack_diff[plane] : &set_pack[plane], 0, 0);
        vkCmdPushConstants(command_buffer, pipeline_layout_pack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 16, block_push);
        vkCmdDispatch(command_buffer, block_workgroups, 1, 1);

        // colordiff (B): closed-loop reconstruction. The quantized coefficients were just packed and are
        // no longer needed, so reconstruct this frame IN PLACE on coeff_buffer exactly as the decoder
        // will (dequant + inverse wavelet + round), then coeff_add stores the reconstructed YCoCg as the
        // next frame's reference (== the player's reference -> no lossy drift).
        if (method == 1) {
          memory_barrier();
          int32_t pixel_count_value = plane_pixels;   // for the round dispatch below
          int32_t dequant_push[2];   // must match the forward quant: { plane_pixels, chroma_multiplier }
          dequant_push[0] = plane_pixels;
          float dequant_chroma_multiplier = (plane == 0) ? 1.0f : g_chroma_quant;
          memcpy(&dequant_push[1], &dequant_chroma_multiplier, sizeof(float));
          if (!lossless) {
            vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_dequant_inverse);
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_quant, 0, 1, &set_quant[plane], 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_quant, VK_SHADER_STAGE_COMPUTE_BIT, 0, 8, dequant_push);
            vkCmdDispatch(command_buffer, pixel_workgroups, 1, 1);
            memory_barrier();
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
            vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_row, 0, 1, &set_row[plane], 0, 0);
            vkCmdPushConstants(command_buffer, pipeline_layout_row, VK_SHADER_STAGE_COMPUTE_BIT, 0, 4, &pixel_count_value);
            vkCmdDispatch(command_buffer, pixel_workgroups, 1, 1);
            memory_barrier();
          }
          // Reconstruct cur = residual + prediction, and save cur as the reference. For the B-stream the
          // prediction is the blend in difference_buffer and the reference destination is this frame's DPB
          // slot (set_motion_add_bidi, rebound above); for I/P it is mc_prev -> previous_buffer.
          int32_t add_push[2] = { plane_pixels, is_predicted };
          vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_motion_add);
          vkCmdBindDescriptorSets(command_buffer, VK_PIPELINE_BIND_POINT_COMPUTE, pipeline_layout_pack, 0, 1, use_bframes ? &set_motion_add_bidi[plane] : &set_motion_add[plane], 0, 0);
          vkCmdPushConstants(command_buffer, pipeline_layout_pack, VK_SHADER_STAGE_COMPUTE_BIT, 0, 8, add_push);
          vkCmdDispatch(command_buffer, pixel_workgroups, 1, 1);
          memory_barrier();
        }
      }
      submit_and_wait();

      // ---- assemble the frame payload (block_count, u16 size tables, data) ----
      uint32_t *frame_sizes[3];
      for (int plane = 0; plane < 3; plane++) {
        frame_sizes[plane] = (method == 0 && is_predicted) ? (uint32_t *)size_map_diff[plane] : (uint32_t *)size_map[plane];
      }
      // Code the motion vectors. I/P: one L0 set. B-stream (Stage B2): the L0 set, plus the L1 set for a
      // B-frame — concatenated in one blob (the decoder reads 1 or 2 sets per the frame's ref1 in the index).
      uint8_t *mv_bytes = NULL;
      size_t mv_length = 0;
      if (use_bframes && is_predicted) {
        int has_mode = (per_block_mode && (b_ref1_slot >= 0));   // Phase 2: per-block L0/L1/BI mode array precedes the MVs
        int has_mv1 = (b_ref1_slot >= 0);                        // B-frame: a second (L1) MV set
        if (g_mv_codec == 1) {   // range codec: one adaptive stream for mode + mv0 [+ mv1]
          mv_length = mv_blob_encode_range(&mv_bytes, has_mode, (const int *)mode_map, g_motion_variable,
                                           (const int *)mv_map, has_mv1, (const int *)mv1_map, g_motion_variable,
                                           motion_blocks_x, motion_blocks_y);
        } else {
          BitWriter mv_writer;
          bitwriter_init(&mv_writer);
          if (has_mode) {
            if (g_motion_variable) {   // variable: the mode field is on the fine 8-grid -> code as a quadtree (merge-if-equal)
              encode_mode_quadtree(&mv_writer, (const int *)mode_map, motion_blocks_x, motion_blocks_y);
            } else {
              const int *modes = (const int *)mode_map;
              for (int blk = 0; blk < (motion_blocks_x * motion_blocks_y); blk++) {
                bitwriter_put_bits(&mv_writer, (uint32_t)modes[blk], 2);
              }
            }
            // NOTE: 2b (drop the unused MV of L0/L1 blocks to save bits) is NOT done — under OBMC a block's MC blends
            // NEIGHBOUR MVs, so zeroing an "unused" MV changes adjacent used blocks' prediction and breaks the closed
            // loop. Always both MVs (2a) — closed-loop-exact; the mode array alone already improves the residual.
          }
          if (g_motion_variable) {   // variable mode: motion_blocks_x/y are the fine 8-grid -> quadtree (merge-if-equal)
            encode_motion_quadtree(&mv_writer, (const int *)mv_map, motion_blocks_x, motion_blocks_y);
          } else {
            encode_motion_vectors(&mv_writer, (const int *)mv_map, motion_blocks_x, motion_blocks_y);
          }
          if (has_mv1) {
            if (g_motion_variable) {
              encode_motion_quadtree(&mv_writer, (const int *)mv1_map, motion_blocks_x, motion_blocks_y);
            } else {
              encode_motion_vectors(&mv_writer, (const int *)mv1_map, motion_blocks_x, motion_blocks_y);
            }
          }
          bitwriter_flush(&mv_writer);
          mv_bytes = mv_writer.bytes;
          mv_length = mv_writer.length;
        }
        if (g_motion_variable && (g_motion_lambda_alpha > 0)) {   // this frame's @32 SADs (last = L1, or L0 for a P-anchor) -> next adaptive lambda
          int g32x = (width + 31) / 32, g32y = (height + 31) / 32, n_roots = g32x * g32y;
          const int32_t *sad32 = (const int32_t *)sad32_map;
          int64_t total_sad = 0;
          for (int r = 0; r < n_roots; r++) {
            total_sad += sad32[r];
          }
          prev_avg_sad = (n_roots > 0) ? (int)(total_sad / n_roots) : 0;
        }
      } else if (((!use_bframes) && (method == 1)) && is_predicted) {
        if (g_mv_codec == 1) {   // range codec: one stream for the single L0 set
          mv_length = mv_blob_encode_range(&mv_bytes, 0, NULL, 0,
                                           (const int *)mv_map, 0, NULL, g_motion_variable,
                                           motion_blocks_x, motion_blocks_y);
        } else {
          BitWriter mv_writer;
          bitwriter_init(&mv_writer);
          if (g_motion_variable) {   // variable mode: motion_blocks_x/y are the fine 8-grid -> quadtree (merge-if-equal)
            encode_motion_quadtree(&mv_writer, (const int *)mv_map, motion_blocks_x, motion_blocks_y);
          } else {
            encode_motion_vectors(&mv_writer, (const int *)mv_map, motion_blocks_x, motion_blocks_y);
          }
          bitwriter_flush(&mv_writer);
          mv_bytes = mv_writer.bytes;
          mv_length = mv_writer.length;
        }
        if (g_motion_variable && (g_motion_lambda_alpha > 0)) {   // average this frame's @32 SADs -> the next frame's adaptive lambda
          int g32x = (width + 31) / 32, g32y = (height + 31) / 32, n_roots = g32x * g32y;
          const int32_t *sad32 = (const int32_t *)sad32_map;
          int64_t total_sad = 0;
          for (int r = 0; r < n_roots; r++) {
            total_sad += sad32[r];
          }
          prev_avg_sad = (n_roots > 0) ? (int)(total_sad / n_roots) : 0;
        }
      }
      uint8_t *frame;
      size_t total = assemble_frame(block_counts, frame_sizes, mv_bytes, mv_length, (const uint8_t *)data_map, data_length, &frame);
      free(mv_bytes);

      if (output && use_bframes) {
        // B-stream: write the explicit coding-order index entry (poc + L0/L1 coding-order refs + temporal_id).
        bframe_append(container_file, &index, &index_capacity, frame_index, frame, total,
                      b_poc, b_ref0_coding, b_ref1_coding, (uint8_t)b_type, (uint8_t)frame_quality, (uint8_t)b_tid);
        if (b_type == 0) {
          bf_i_count++;
        } else if (b_type == 1) {
          bf_p_count++;
        } else {
          bf_b_count++;
        }
        predicted_frames += (b_type != 0);
      } else if (output) {
        // Append the frame and record its (offset, size) in the index.
        if (frame_index >= index_capacity) {
          index_capacity = index_capacity ? (index_capacity * 2) : 256;
          index = realloc(index, (size_t)index_capacity * sizeof(FrameEntry));
          if (!index) {
            die("realloc");
          }
        }
        index[frame_index].offset = (uint64_t)ftello(container_file);
        index[frame_index].type = (uint8_t)is_predicted;
        predicted_frames += is_predicted;
        index[frame_index].quality = (uint8_t)current_quality;
        index[frame_index].poc = (uint32_t)frame_index;                  // I/P: coding order == display order
        index[frame_index].ref0 = is_predicted ? ((int32_t)frame_index - 1) : -1;   // P predicts from the previous frame
        index[frame_index].ref1 = -1;                                    // single forward reference (no L1)
        index[frame_index].temporal_id = 0;
        index[frame_index].pad = 0;
        index[frame_index].size = (uint32_t)fwrite_frame(container_file, frame, total);
      } else {
        // Self-test: CPU-decode the GPU stream and measure PSNR against the original frame. Tracks the
        // P-frame reference (matching the active method) so gop>1 round-trips correctly here too.
        if (method == 1) {
          decode_frame_colordiff(frame, total, width, height, levels, quality, reconstructed, predictive ? self_previous : NULL, is_predicted);
        } else {
          decode_frame_coefdiff(frame, total, width, height, levels, quality, reconstructed, predictive ? self_previous : NULL, is_predicted);
        }
        double mean_squared_error = 0;
        for (size_t i = 0; i < frame_bytes; i++) {
          int difference = (int)rgb[i] - (int)reconstructed[i];
          mean_squared_error += (double)difference * difference;
        }
        mean_squared_error /= frame_bytes;
        sum_psnr += (mean_squared_error == 0) ? 99.99 : (10.0 * log10((255.0 * 255.0) / mean_squared_error));
      }
      total_bytes += total;
      frame_index++;
      if (output) {
        print_encode_progress(frame_index, total_frames, fps_value, now_milliseconds() - encode_start);
      }
      free(frame);
      // B-stream: the anchor pair finished -> the hi anchor's DPB slot becomes the next lo (slot 0).
      if (use_bframes && (b_slide_from >= 0)) {
        begin_recording();
        for (int plane = 0; plane < 3; plane++) {
          VkBufferCopy slide = { 0, 0, plane_bytes };
          vkCmdCopyBuffer(command_buffer, dpb_buffer[b_slide_from][plane], dpb_buffer[0][plane], 1, &slide);
        }
        submit_and_wait();
      }
    }
    if (use_bframes) {
      for (int s = 0; s <= bgpu.period; s++) {
        free(bgpu.rgb_slot[s]);
      }
    }
  }
  if (output && (frame_index > 0)) {
    fprintf(stderr, "\n");   // finish the same-line progress display
  }
  pclose(input_pipe);

  if (output) {
    // Write the audio blob, then the per-frame index, then back-fill the header.
    ContainerHeader header;
    memset(&header, 0, sizeof header);   // zero the reserved + HDR10 fields
    memcpy(header.magic, "FWVC", 4);   // uppercase magic (dual H.264 + wavelet container)
    header.version = 1;
    header.header_size = (uint16_t)sizeof header;
    header.mv_codec = (uint8_t)g_mv_codec;   // 0 = Exp-Golomb (default), 1 = range coder (--mv-codec range)
    header.prediction_method = mode_3ddwt ? (g_mctf ? (uint8_t)3 : (uint8_t)2) : (uint8_t)method;   // 3 = MCTF 3D-DWT, 2 = open-loop 3D-DWT GOP
    header.chroma_quant_x16 = (uint8_t)(g_chroma_quant * 16.0f + 0.5f);   // chroma quant weighting (16 = 1.0 = off)
    header.chroma_format = (uint8_t)g_chroma_format;
    header.reserved2[4] = (uint8_t)g_block_size;   // coding block size (32/64/128); the decoder builds the matching bitplane pipeline
    header.reserved2[5] = g_motion_variable ? (uint8_t)1 : (uint8_t)g_motion_block;   // 8/16/32 = fixed motion grid; 1 = variable quadtree (root 32, fine grid 8)
    if (mode_3ddwt) {   // 3D-DWT params for the decoder (stashed in the reserved bytes)
      header.reserved2[0] = (uint8_t)g_temporal_levels;
      header.reserved2[1] = (uint8_t)g_temporal_wavelet;
    }
    if (use_bframes) {   // B-stream marker + period hint (the player decodes in coding order, reorders by POC)
      header.reserved2[2] = (uint8_t)bframes;
      header.reserved2[3] = (uint8_t)per_block_mode;   // Phase 2: B-frame MV blobs carry a per-block L0/L1/BI mode array
    }
    header.width = width;
    header.height = height;
    header.fps_num = fps_num;
    header.fps_den = fps_den;
    header.levels = levels;
    header.quality = quality;
    header.frame_count = (uint32_t)frame_index;
    header.gop = (uint16_t)gop;
    // Colour: default SDR (BT.709 primaries, sRGB transfer, full-range YCoCg-R, 8-bit). The HDR
    // fields stay zero (colour_flags bit0/bit1 clear) until the pipeline gains 10/12-bit + PQ/HLG.
    header.bit_depth = 8;
    header.colour_primaries = 1;     // BT.709
    header.transfer_function = 13;   // sRGB
    header.matrix = 8;               // YCgCo == YCoCg-R
    header.full_range = 1;
    if (hdr_mode) {                  // --hdr: 12-bit BT.2020, transfer PQ (16) or HLG (18) per autodetect/flag
      header.bit_depth = 12;
      header.colour_primaries = 9;   // BT.2020
      header.transfer_function = (uint8_t)hdr_transfer;
      header.colour_flags = 1;       // bit0 = HDR
    }
    header.audio_offset = (uint64_t)ftello(container_file);
    if (audio) {
      fwrite(audio, 1, audio_size, container_file);
    }
    header.audio_size = audio ? audio_size : 0;
    memcpy(header.audio_codec, audio_codec_tag, 4);   // sub-FOURCC: OGGV / QOAL / RPCM / FWAC
    header.h264_offset = (uint64_t)ftello(container_file);   // full-res H.264 Annex-B (optional)
    if (h264_blob) {
      fwrite(h264_blob, 1, h264_blob_size, container_file);
    }
    header.h264_size = h264_blob ? h264_blob_size : 0;
    header.index_offset = (uint64_t)ftello(container_file);
    fwrite(index, sizeof(FrameEntry), frame_index, container_file);
    fseeko(container_file, 0, SEEK_SET);
    fwrite(&header, sizeof header, 1, container_file);
    fclose(container_file);
    // Report the ACTUAL on-disk video size: sum the index entries (each = the fwrite_frame return, i.e. the per-frame
    // [method][raw_len] framing AFTER LZSS/LZBRRC), not total_bytes which is the pre-compression assemble_frame sum.
    unsigned long long written_video_bytes = 0;
    for (long fi = 0; fi < frame_index; fi++) {
      written_video_bytes += index[fi].size;
    }
    if (use_bframes) {
      printf("wrote %s: %ld frames (%ld I + %ld P + %ld B, %d B/anchor), %.2f MB video + %.2f MB audio (%.2f bpp)\n",
             output, frame_index, bf_i_count, bf_p_count, bf_b_count, bframes,
             (double)written_video_bytes / 1e6, audio_size / 1e6,
             ((double)written_video_bytes * 8.0) / ((double)frame_index * pixel_count));
    } else {
      printf("wrote %s: %ld frames (%ld I + %ld P, gop=%d), %.2f MB video + %.2f MB audio (%.2f bpp)\n",
             output, frame_index, frame_index - predicted_frames, predicted_frames, gop,
             (double)written_video_bytes / 1e6, audio_size / 1e6,
             ((double)written_video_bytes * 8.0) / ((double)frame_index * pixel_count));
    }
    return 0;
  }

  double raw_megabytes = ((double)frame_index * frame_bytes) / 1e6;
  double encoded_megabytes = (double)total_bytes / 1e6;
  printf("%ld frames | GPU-encode: %.2f MB (%.1f:1, %.2f bpp) | PSNR(orig) %.2f dB\n",
         frame_index, encoded_megabytes, raw_megabytes / encoded_megabytes,
         ((double)total_bytes * 8.0) / ((double)frame_index * pixel_count), frame_index ? (sum_psnr / frame_index) : 0);
  return 0;
}
