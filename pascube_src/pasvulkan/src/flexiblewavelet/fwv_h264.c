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
 * fwv_h264.c — H.264 HW-decode helper: GPU NV12->RGB + aspect-correct present.
 *
 * Decodes every H.264 frame in hardware on the video-decode queue (DPB reference management +
 * frame_num wrap), then on the graphics queue converts the decoded NV12 to RGBA with a compute
 * shader (nv12rgb.comp, sampling the two plane views, BT.709), reorders into display (POC) order,
 * and blits each frame to the SDL2/Vulkan swapchain aspect-correct (contain / letterbox), synced
 * to the OGG/Vorbis audio master clock. No libav linked (ffmpeg CLI demux only).
 *
 * Set VERIFY=1 to run headless: each decoded frame is read back and compared (PSNR) to ffmpeg's
 * decode in display order, isolating content/order bugs from pure present-timing.
 *
 *     ./h264play2 in.(mp4|mkv|...)
 */
#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <math.h>
#include <time.h>
#include <vulkan/vulkan.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_vulkan.h>
#include "fwv_h264.h"   // shared-handle context (audio is owned by fwvplay)
#include "avi_writer.h"  // --decode-to OpenDML/AVI export

static AviWriter *g_avi = NULL;   // set when run_h264_player exports to AVI (no present, headless)

#define VK_CHECK(expression) do {                                              \
    VkResult _result = (expression);                                           \
    if (_result) {                                                             \
      fprintf(stderr, "vk error %d at line %d\n", _result, __LINE__);          \
      exit(1);                                                                 \
    }                                                                          \
  } while (0)

static void die(const char *message) {
  fprintf(stderr, "error: %s\n", message);
  exit(1);
}

static void *checked_malloc(size_t bytes) {
  void *pointer = malloc(bytes ? bytes : 1);
  if (!pointer) {
    die("out of memory");
  }
  return pointer;
}

static double now_milliseconds(void) {
  struct timespec t;
  clock_gettime(CLOCK_MONOTONIC, &t);
  return t.tv_sec * 1e3 + t.tv_nsec * 1e-6;
}

// ---------------- H.264 parse (bit reader + SPS / PPS / slice + POC) ----------------

typedef struct {
  const uint8_t *data;
  size_t length;
  size_t bit_position;
} BitReader;

static int read_bit(BitReader *reader) {
  if ((reader->bit_position >> 3) >= reader->length) {
    return 0;
  }
  int value = (reader->data[reader->bit_position >> 3] >> (7 - (reader->bit_position & 7))) & 1;
  reader->bit_position++;
  return value;
}

static uint32_t read_bits(BitReader *reader, int count) {
  uint32_t value = 0;
  for (int i = 0; i < count; i++) {
    value = (value << 1) | read_bit(reader);
  }
  return value;
}

static uint32_t read_unsigned_exp_golomb(BitReader *reader) {
  int leading_zeros = 0;
  while (!read_bit(reader) && leading_zeros < 32) {
    leading_zeros++;
  }
  uint32_t value = (1u << leading_zeros) - 1;
  for (int i = 0; i < leading_zeros; i++) {
    value += read_bit(reader) << (leading_zeros - 1 - i);
  }
  return value;
}

static int32_t read_signed_exp_golomb(BitReader *reader) {
  uint32_t code = read_unsigned_exp_golomb(reader);
  return (code & 1) ? (int32_t)((code + 1) >> 1) : -(int32_t)(code >> 1);
}

static void skip_scaling_lists(BitReader *reader, int list_count) {
  for (int i = 0; i < list_count; i++) {
    if (read_bit(reader)) {
      int last = 8, next = 8, size = i < 6 ? 16 : 64;
      for (int j = 0; j < size; j++) {
        if (next) {
          next = (last + read_signed_exp_golomb(reader) + 256) % 256;
        }
        last = next ? next : last;
      }
    }
  }
}

typedef struct {
  int profile_idc, level_idc, sps_id, chroma_format_idc, log2_max_frame_num_minus4, poc_type, log2_max_poc_lsb_minus4, max_num_ref;
  int width_in_mbs_minus1, height_in_map_units_minus1, frame_mbs_only, direct_8x8, mb_adaptive, gaps;
  int crop_left, crop_right, crop_top, crop_bottom, width, height;
} Sps;

static void parse_sps(const uint8_t *rbsp, size_t length, Sps *sps) {
  BitReader reader = { rbsp, length, 0 };
  memset(sps, 0, sizeof *sps);
  sps->profile_idc = read_bits(&reader, 8);
  read_bits(&reader, 8);
  sps->level_idc = read_bits(&reader, 8);
  sps->sps_id = read_unsigned_exp_golomb(&reader);
  sps->chroma_format_idc = 1;
  if (sps->profile_idc == 100 || sps->profile_idc == 110 || sps->profile_idc == 122 || sps->profile_idc == 244 ||
      sps->profile_idc == 44 || sps->profile_idc == 83 || sps->profile_idc == 86 || sps->profile_idc == 118 || sps->profile_idc == 128) {
    sps->chroma_format_idc = read_unsigned_exp_golomb(&reader);
    if (sps->chroma_format_idc == 3) {
      read_bit(&reader);
    }
    read_unsigned_exp_golomb(&reader);
    read_unsigned_exp_golomb(&reader);
    read_bit(&reader);
    if (read_bit(&reader)) {
      skip_scaling_lists(&reader, sps->chroma_format_idc != 3 ? 8 : 12);
    }
  }
  sps->log2_max_frame_num_minus4 = read_unsigned_exp_golomb(&reader);
  sps->poc_type = read_unsigned_exp_golomb(&reader);
  if (sps->poc_type == 0) {
    sps->log2_max_poc_lsb_minus4 = read_unsigned_exp_golomb(&reader);
  } else if (sps->poc_type == 1) {
    read_bit(&reader);
    read_signed_exp_golomb(&reader);
    read_signed_exp_golomb(&reader);
    int cycle = read_unsigned_exp_golomb(&reader);
    for (int i = 0; i < cycle; i++) {
      read_signed_exp_golomb(&reader);
    }
  }
  sps->max_num_ref = read_unsigned_exp_golomb(&reader);
  sps->gaps = read_bit(&reader);
  sps->width_in_mbs_minus1 = read_unsigned_exp_golomb(&reader);
  sps->height_in_map_units_minus1 = read_unsigned_exp_golomb(&reader);
  sps->frame_mbs_only = read_bit(&reader);
  if (!sps->frame_mbs_only) {
    sps->mb_adaptive = read_bit(&reader);
  }
  sps->direct_8x8 = read_bit(&reader);
  if (read_bit(&reader)) {
    sps->crop_left = read_unsigned_exp_golomb(&reader);
    sps->crop_right = read_unsigned_exp_golomb(&reader);
    sps->crop_top = read_unsigned_exp_golomb(&reader);
    sps->crop_bottom = read_unsigned_exp_golomb(&reader);
  }
  sps->width = (sps->width_in_mbs_minus1 + 1) * 16 - (sps->crop_left + sps->crop_right) * 2;
  sps->height = (sps->height_in_map_units_minus1 + 1) * 16 * (2 - sps->frame_mbs_only) - (sps->crop_top + sps->crop_bottom) * 2 * (2 - sps->frame_mbs_only);
}

typedef struct {
  int pps_id, sps_id, entropy_coding_mode, bottom_field_poc, num_ref_l0_minus1, num_ref_l1_minus1;
  int weighted_pred, weighted_bipred, pic_init_qp_minus26, pic_init_qs_minus26, chroma_qp_offset;
  int deblocking_control, constrained_intra, redundant, transform_8x8, second_chroma_qp_offset;
} Pps;

static void parse_pps(const uint8_t *rbsp, size_t length, Pps *pps) {
  BitReader reader = { rbsp, length, 0 };
  memset(pps, 0, sizeof *pps);
  pps->pps_id = read_unsigned_exp_golomb(&reader);
  pps->sps_id = read_unsigned_exp_golomb(&reader);
  pps->entropy_coding_mode = read_bit(&reader);
  pps->bottom_field_poc = read_bit(&reader);
  read_unsigned_exp_golomb(&reader);
  pps->num_ref_l0_minus1 = read_unsigned_exp_golomb(&reader);
  pps->num_ref_l1_minus1 = read_unsigned_exp_golomb(&reader);
  pps->weighted_pred = read_bit(&reader);
  pps->weighted_bipred = read_bits(&reader, 2);
  pps->pic_init_qp_minus26 = read_signed_exp_golomb(&reader);
  pps->pic_init_qs_minus26 = read_signed_exp_golomb(&reader);
  pps->chroma_qp_offset = read_signed_exp_golomb(&reader);
  pps->deblocking_control = read_bit(&reader);
  pps->constrained_intra = read_bit(&reader);
  pps->redundant = read_bit(&reader);
  pps->second_chroma_qp_offset = pps->chroma_qp_offset;
  size_t last_set_bit = 0;
  for (size_t bit = length * 8; bit > 0; bit--) {
    if ((rbsp[(bit - 1) >> 3] >> (7 - ((bit - 1) & 7))) & 1) {
      last_set_bit = bit - 1;
      break;
    }
  }
  if (reader.bit_position < last_set_bit) {
    pps->transform_8x8 = read_bit(&reader);
    if (read_bit(&reader)) {
      skip_scaling_lists(&reader, 6 + (pps->transform_8x8 ? 2 : 0));
    }
    pps->second_chroma_qp_offset = read_signed_exp_golomb(&reader);
  }
}

typedef struct {
  int type, frame_num, idr, poc_lsb, idr_pic_id;
} Slice;

static void parse_slice(const uint8_t *rbsp, size_t length, const Sps *sps, int nal_type, Slice *slice) {
  BitReader reader = { rbsp, length, 0 };
  read_unsigned_exp_golomb(&reader);
  slice->type = (int)(read_unsigned_exp_golomb(&reader) % 5);
  read_unsigned_exp_golomb(&reader);
  slice->frame_num = (int)read_bits(&reader, sps->log2_max_frame_num_minus4 + 4);
  slice->idr = (nal_type == 5);
  slice->idr_pic_id = 0;
  if (slice->idr) {
    slice->idr_pic_id = (int)read_unsigned_exp_golomb(&reader);
  }
  slice->poc_lsb = sps->poc_type == 0 ? (int)read_bits(&reader, sps->log2_max_poc_lsb_minus4 + 4) : 0;
}

static int compute_poc(const Sps *sps, const Slice *slice, int *previous_msb, int *previous_lsb) {
  if (slice->idr) {
    *previous_msb = 0;
    *previous_lsb = 0;
    return 0;
  }
  int max_lsb = 1 << (sps->log2_max_poc_lsb_minus4 + 4);
  int msb;
  if (slice->poc_lsb < *previous_lsb && (*previous_lsb - slice->poc_lsb) >= max_lsb / 2) {
    msb = *previous_msb + max_lsb;
  } else if (slice->poc_lsb > *previous_lsb && (slice->poc_lsb - *previous_lsb) > max_lsb / 2) {
    msb = *previous_msb - max_lsb;
  } else {
    msb = *previous_msb;
  }
  *previous_msb = msb;
  *previous_lsb = slice->poc_lsb;
  return msb + slice->poc_lsb;
}

static size_t to_rbsp(const uint8_t *nal, size_t length, uint8_t *out) {
  size_t out_length = 0;
  for (size_t i = 0; i < length; i++) {
    if (i >= 2 && nal[i] == 3 && nal[i - 1] == 0 && nal[i - 2] == 0 && i + 1 < length && nal[i + 1] <= 3) {
      continue;
    }
    out[out_length++] = nal[i];
  }
  return out_length;
}

static uint8_t *demux(const char *input, size_t *out_length) {
  char command[4096];
  snprintf(command, sizeof command, "ffmpeg -v error -i \"%s\" -an -c:v copy -bsf:v h264_mp4toannexb -f h264 -", input);
  FILE *pipe = popen(command, "r");
  if (!pipe) {
    die("popen");
  }
  size_t capacity = 1 << 20, length = 0;
  uint8_t *buffer = checked_malloc(capacity);
  for (;;) {
    if (length + 65536 > capacity) {
      capacity *= 2;
      buffer = realloc(buffer, capacity);
      if (!buffer) {
        die("realloc");
      }
    }
    size_t read = fread(buffer + length, 1, 65536, pipe);
    length += read;
    if (read < 65536) {
      break;
    }
  }
  pclose(pipe);
  *out_length = length;
  return buffer;
}

// Transcode the audio track to a temporary OGG/Vorbis blob (NULL if there is no audio).
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
  snprintf(command, sizeof command, "ffmpeg -v error -y -i \"%s\" -vn -c:a libvorbis -q:a 5 /tmp/h264_a.ogg", input);
  if (system(command)) {
    return 0;
  }
  FILE *audio_file = fopen("/tmp/h264_a.ogg", "rb");
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

// ---------------- Vulkan helpers ----------------

static VkPhysicalDevice physical_device;
static VkDevice device;

static uint32_t find_memory_type(uint32_t type_bits, VkMemoryPropertyFlags wanted) {
  VkPhysicalDeviceMemoryProperties memory_properties;
  vkGetPhysicalDeviceMemoryProperties(physical_device, &memory_properties);
  for (uint32_t i = 0; i < memory_properties.memoryTypeCount; i++) {
    if ((type_bits & (1u << i)) && (memory_properties.memoryTypes[i].propertyFlags & wanted) == wanted) {
      return i;
    }
  }
  for (uint32_t i = 0; i < memory_properties.memoryTypeCount; i++) {
    if (type_bits & (1u << i)) {
      return i;
    }
  }
  die("no suitable memory type");
  return 0;
}

static uint32_t *load_spirv(const char *path, size_t *out_size) {
  FILE *file = fopen(path, "rb");
  if (!file) {
    die("open spv");
  }
  fseek(file, 0, SEEK_END);
  long size = ftell(file);
  fseek(file, 0, SEEK_SET);
  uint32_t *code = checked_malloc(size);
  if (fread(code, 1, size, file) != (size_t)size) {
    die("spv");
  }
  fclose(file);
  *out_size = size;
  return code;
}

// synchronization2 image layout/access barrier on a colour image.
static void image_barrier(VkCommandBuffer command_buffer, VkImage image, VkImageLayout old_layout, VkImageLayout new_layout,
                          VkAccessFlags2 src_access, VkAccessFlags2 dst_access, VkPipelineStageFlags2 src_stage, VkPipelineStageFlags2 dst_stage) {
  VkImageMemoryBarrier2 barrier = { VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER_2 };
  barrier.srcStageMask = src_stage;
  barrier.srcAccessMask = src_access;
  barrier.dstStageMask = dst_stage;
  barrier.dstAccessMask = dst_access;
  barrier.oldLayout = old_layout;
  barrier.newLayout = new_layout;
  barrier.srcQueueFamilyIndex = barrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
  barrier.image = image;
  barrier.subresourceRange = (VkImageSubresourceRange){ VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1 };
  VkDependencyInfo dependency = { VK_STRUCTURE_TYPE_DEPENDENCY_INFO };
  dependency.imageMemoryBarrierCount = 1;
  dependency.pImageMemoryBarriers = &barrier;
  vkCmdPipelineBarrier2(command_buffer, &dependency);
}

// ---------------- present path (graphics queue) ----------------
// A decoded frame is converted into one of NPOOL RGBA pool images; present_one blits that pool
// image to the swapchain, aspect-correct (contain / letterbox). A pool slot is freed only after
// the present that used it completes (tracked per ring slot), so it is never overwritten in flight.

static VkQueue graphics_queue;
static VkSwapchainKHR swapchain;
static VkImage *swapchain_images;
static VkExtent2D extent;
static int present_width, present_height;
static VkImage *pool_images;
static VkSemaphore acquire_semaphore[4], render_semaphore[4];
static VkFence present_fence[4];
static VkCommandBuffer present_command[4];
static int ring_index;                 // 4-deep present ring
static int verify;                     // headless PSNR verify of the GPU path
static VkBuffer verify_buffer;
static void *verify_map;
static uint8_t **verify_output;
static int verify_count;
static int *pool_free, free_count, ring_pool[4];   // pool free-list

typedef struct {
  uint64_t key;   // (gop << 24) | (poc biased positive) — sorts into display order across GOPs
  int index;      // which pool image holds this frame
} ReorderEntry;

static void present_one(int pool_index) {
  if (verify || g_avi) {
    // Headless: read the pool image back; verify stores RGB for the PSNR check, AVI export writes the frame.
    vkWaitForFences(device, 1, &present_fence[0], VK_TRUE, UINT64_MAX);
    vkResetFences(device, 1, &present_fence[0]);
    vkResetCommandBuffer(present_command[0], 0);
    VkCommandBufferBeginInfo begin_info = { VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO };
    begin_info.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
    vkBeginCommandBuffer(present_command[0], &begin_info);
    VkBufferImageCopy copy = { 0 };
    copy.imageSubresource = (VkImageSubresourceLayers){ VK_IMAGE_ASPECT_COLOR_BIT, 0, 0, 1 };
    copy.imageExtent = (VkExtent3D){ present_width, present_height, 1 };
    vkCmdCopyImageToBuffer(present_command[0], pool_images[pool_index], VK_IMAGE_LAYOUT_GENERAL, verify_buffer, 1, &copy);
    vkEndCommandBuffer(present_command[0]);
    VkSubmitInfo submit = { VK_STRUCTURE_TYPE_SUBMIT_INFO };
    submit.commandBufferCount = 1;
    submit.pCommandBuffers = &present_command[0];
    vkQueueSubmit(graphics_queue, 1, &submit, present_fence[0]);
    vkWaitForFences(device, 1, &present_fence[0], VK_TRUE, UINT64_MAX);
    uint8_t *rgba = verify_map;
    if (g_avi) {
      avi_video_frame(g_avi, rgba);   // RGBA8 -> the OpenDML AVI
    } else {
      uint8_t *rgb = malloc((size_t)present_width * present_height * 3);
      for (int i = 0; i < present_width * present_height; i++) {
        rgb[i * 3] = rgba[i * 4];
        rgb[i * 3 + 1] = rgba[i * 4 + 1];
        rgb[i * 3 + 2] = rgba[i * 4 + 2];
      }
      verify_output[verify_count++] = rgb;
    }
    pool_free[free_count++] = pool_index;
    return;
  }

  int ri = ring_index;
  ring_index = (ring_index + 1) & 3;
  vkWaitForFences(device, 1, &present_fence[ri], VK_TRUE, UINT64_MAX);   // this ring slot's prior submit + present are done
  if (ring_pool[ri] >= 0) {
    pool_free[free_count++] = ring_pool[ri];   // now safe to recycle the pool slot that present used
  }
  ring_pool[ri] = pool_index;

  uint32_t image_index;
  if (vkAcquireNextImageKHR(device, swapchain, UINT64_MAX, acquire_semaphore[ri], 0, &image_index) != VK_SUCCESS) {
    return;
  }
  vkResetFences(device, 1, &present_fence[ri]);
  VkCommandBuffer command_buffer = present_command[ri];
  vkResetCommandBuffer(command_buffer, 0);
  VkCommandBufferBeginInfo begin_info = { VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO };
  begin_info.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
  vkBeginCommandBuffer(command_buffer, &begin_info);
  image_barrier(command_buffer, swapchain_images[image_index], VK_IMAGE_LAYOUT_UNDEFINED, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
                0, VK_ACCESS_2_TRANSFER_WRITE_BIT, VK_PIPELINE_STAGE_2_NONE, VK_PIPELINE_STAGE_2_CLEAR_BIT | VK_PIPELINE_STAGE_2_BLIT_BIT);

  // Clear to black (letterbox), then blit the frame into a centred aspect-correct rectangle.
  VkClearColorValue black = { { 0, 0, 0, 1 } };
  VkImageSubresourceRange range = { VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1 };
  vkCmdClearColorImage(command_buffer, swapchain_images[image_index], VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, &black, 1, &range);
  double scale = (extent.width / (double)present_width < extent.height / (double)present_height)
               ? extent.width / (double)present_width
               : extent.height / (double)present_height;
  int view_width = (int)(present_width * scale);
  int view_height = (int)(present_height * scale);
  int view_x = ((int)extent.width - view_width) / 2;
  int view_y = ((int)extent.height - view_height) / 2;
  VkImageBlit blit = { 0 };
  blit.srcSubresource = blit.dstSubresource = (VkImageSubresourceLayers){ VK_IMAGE_ASPECT_COLOR_BIT, 0, 0, 1 };
  blit.srcOffsets[1] = (VkOffset3D){ present_width, present_height, 1 };
  blit.dstOffsets[0] = (VkOffset3D){ view_x, view_y, 0 };
  blit.dstOffsets[1] = (VkOffset3D){ view_x + view_width, view_y + view_height, 1 };
  vkCmdBlitImage(command_buffer, pool_images[pool_index], VK_IMAGE_LAYOUT_GENERAL, swapchain_images[image_index], VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, &blit, VK_FILTER_LINEAR);
  image_barrier(command_buffer, swapchain_images[image_index], VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, VK_IMAGE_LAYOUT_PRESENT_SRC_KHR,
                VK_ACCESS_2_TRANSFER_WRITE_BIT, 0, VK_PIPELINE_STAGE_2_BLIT_BIT, VK_PIPELINE_STAGE_2_NONE);
  vkEndCommandBuffer(command_buffer);

  VkPipelineStageFlags wait_stage = VK_PIPELINE_STAGE_TRANSFER_BIT;
  VkSubmitInfo submit = { VK_STRUCTURE_TYPE_SUBMIT_INFO };
  submit.waitSemaphoreCount = 1;
  submit.pWaitSemaphores = &acquire_semaphore[ri];
  submit.pWaitDstStageMask = &wait_stage;
  submit.commandBufferCount = 1;
  submit.pCommandBuffers = &command_buffer;
  submit.signalSemaphoreCount = 1;
  submit.pSignalSemaphores = &render_semaphore[ri];
  vkQueueSubmit(graphics_queue, 1, &submit, present_fence[ri]);
  VkPresentInfoKHR present_info = { VK_STRUCTURE_TYPE_PRESENT_INFO_KHR };
  present_info.waitSemaphoreCount = 1;
  present_info.pWaitSemaphores = &render_semaphore[ri];
  present_info.swapchainCount = 1;
  present_info.pSwapchains = &swapchain;
  present_info.pImageIndices = &image_index;
  vkQueuePresentKHR(graphics_queue, &present_info);
}

int run_h264_player(const FwvH264Context *ctx) {
  // ---- shared handles from fwvplay (ONE device; the two video paths are separate after init) ----
  VkInstance instance = ctx->instance;
  physical_device = ctx->physical_device;
  device = ctx->device;
  graphics_queue = ctx->graphics_queue;
  VkQueue video_queue = ctx->video_queue;
  int video_decode_family = ctx->video_family;
  int graphics_family = ctx->graphics_family;
  swapchain = ctx->swapchain;
  swapchain_images = ctx->swapchain_images;
  extent = ctx->extent;
  SDL_Window *window = ctx->window;
  verify = ctx->verify;
  double fps = ctx->fps;
  SDL_AudioDeviceID audio_device = ctx->audio_device;
  uint32_t total_audio_bytes = ctx->total_audio_bytes;
  int audio_channels = ctx->audio_channels, audio_rate = ctx->audio_rate;
  (void)window;

  // ---- parse the embedded H.264 Annex-B blob into a frame list ----
  size_t stream_length = ctx->blob_size;
  const uint8_t *stream = ctx->blob;
  uint8_t *rbsp = checked_malloc(stream_length);
  Sps sps;
  Pps pps;
  int have_sps = 0, have_pps = 0;
  typedef struct {
    const uint8_t *nal;
    size_t length;
    int idr, frame_num, poc, type, ref_idc;
  } Frame;
  Frame *frames = checked_malloc(sizeof(Frame) * 300000);
  int frame_count = 0, previous_msb = 0, previous_lsb = 0;
  size_t i = 0;
  while (i + 3 < stream_length) {
    if (stream[i] == 0 && stream[i + 1] == 0 && stream[i + 2] == 1) {
      size_t start = i + 3, end = start;
      while (end + 3 < stream_length && !(stream[end] == 0 && stream[end + 1] == 0 && stream[end + 2] == 1)) {
        end++;
      }
      if (end + 3 >= stream_length) {
        end = stream_length;
      }
      int nal_type = stream[start] & 0x1f;
      int ref_idc = (stream[start] >> 5) & 3;
      if (nal_type == 7) {
        parse_sps(rbsp, to_rbsp(stream + start + 1, end - start - 1, rbsp), &sps);
        have_sps = 1;
      } else if (nal_type == 8) {
        parse_pps(rbsp, to_rbsp(stream + start + 1, end - start - 1, rbsp), &pps);
        have_pps = 1;
      } else if (nal_type == 5 || nal_type == 1) {
        Slice slice;
        parse_slice(rbsp, to_rbsp(stream + start + 1, end - start - 1, rbsp), &sps, nal_type, &slice);
        int poc = compute_poc(&sps, &slice, &previous_msb, &previous_lsb);
        frames[frame_count++] = (Frame){ stream + i, end - i, slice.idr, slice.frame_num, poc, slice.type, ref_idc };
      }
      i = end;
    } else {
      i++;
    }
  }
  if (!have_sps || !have_pps || !frame_count) {
    die("missing SPS/PPS/slices in the embedded H.264 stream");
  }
  int width = sps.width, height = sps.height;
  printf("H.264 HW decode: %dx%d @ %.2f fps | %d frames\n", width, height, fps, frame_count);

  present_width = width;
  present_height = height;

  // ---- present + compute command buffers on the graphics queue ----
  VkCommandPoolCreateInfo graphics_pool_info = { VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO };
  graphics_pool_info.queueFamilyIndex = graphics_family;
  graphics_pool_info.flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT;
  VkCommandPool graphics_pool;
  VK_CHECK(vkCreateCommandPool(device, &graphics_pool_info, 0, &graphics_pool));
  VkCommandBuffer graphics_buffers[5];   // 4 present (ring) + 1 compute
  VkCommandBufferAllocateInfo graphics_alloc = { VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO };
  graphics_alloc.commandPool = graphics_pool;
  graphics_alloc.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
  graphics_alloc.commandBufferCount = 5;
  vkAllocateCommandBuffers(device, &graphics_alloc, graphics_buffers);
  for (int k = 0; k < 4; k++) {
    present_command[k] = graphics_buffers[k];
  }
  VkCommandBuffer compute_command = graphics_buffers[4];
  VkSemaphoreCreateInfo semaphore_info = { VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO };
  VkFenceCreateInfo fence_info = { VK_STRUCTURE_TYPE_FENCE_CREATE_INFO };
  fence_info.flags = VK_FENCE_CREATE_SIGNALED_BIT;
  for (int k = 0; k < 4; k++) {
    vkCreateSemaphore(device, &semaphore_info, 0, &acquire_semaphore[k]);
    vkCreateSemaphore(device, &semaphore_info, 0, &render_semaphore[k]);
    vkCreateFence(device, &fence_info, 0, &present_fence[k]);
  }

  // ---- video profile / capabilities / session / parameters ----
  VkVideoDecodeH264ProfileInfoKHR h264_profile = { VK_STRUCTURE_TYPE_VIDEO_DECODE_H264_PROFILE_INFO_KHR };
  h264_profile.stdProfileIdc = STD_VIDEO_H264_PROFILE_IDC_HIGH;
  h264_profile.pictureLayout = VK_VIDEO_DECODE_H264_PICTURE_LAYOUT_PROGRESSIVE_KHR;
  VkVideoProfileInfoKHR profile = { VK_STRUCTURE_TYPE_VIDEO_PROFILE_INFO_KHR };
  profile.pNext = &h264_profile;
  profile.videoCodecOperation = VK_VIDEO_CODEC_OPERATION_DECODE_H264_BIT_KHR;
  profile.chromaSubsampling = VK_VIDEO_CHROMA_SUBSAMPLING_420_BIT_KHR;
  profile.lumaBitDepth = VK_VIDEO_COMPONENT_BIT_DEPTH_8_BIT_KHR;
  profile.chromaBitDepth = VK_VIDEO_COMPONENT_BIT_DEPTH_8_BIT_KHR;
  VkVideoProfileListInfoKHR profile_list = { VK_STRUCTURE_TYPE_VIDEO_PROFILE_LIST_INFO_KHR };
  profile_list.profileCount = 1;
  profile_list.pProfiles = &profile;
  PFN_vkGetPhysicalDeviceVideoCapabilitiesKHR get_video_capabilities =
      (PFN_vkGetPhysicalDeviceVideoCapabilitiesKHR)vkGetInstanceProcAddr(instance, "vkGetPhysicalDeviceVideoCapabilitiesKHR");
  VkVideoDecodeH264CapabilitiesKHR h264_caps = { VK_STRUCTURE_TYPE_VIDEO_DECODE_H264_CAPABILITIES_KHR };
  VkVideoDecodeCapabilitiesKHR decode_caps = { VK_STRUCTURE_TYPE_VIDEO_DECODE_CAPABILITIES_KHR };
  decode_caps.pNext = &h264_caps;
  VkVideoCapabilitiesKHR caps = { VK_STRUCTURE_TYPE_VIDEO_CAPABILITIES_KHR };
  caps.pNext = &decode_caps;
  VK_CHECK(get_video_capabilities(physical_device, &profile, &caps));
  VkExtent2D coded = { (sps.width_in_mbs_minus1 + 1) * 16, (sps.height_in_map_units_minus1 + 1) * 16 };
  VkFormat nv12 = VK_FORMAT_G8_B8R8_2PLANE_420_UNORM;

  #define LOAD(name) PFN_##name name = (PFN_##name)vkGetDeviceProcAddr(device, #name); if (!name) die("missing " #name);
  LOAD(vkCreateVideoSessionKHR)
  LOAD(vkGetVideoSessionMemoryRequirementsKHR)
  LOAD(vkBindVideoSessionMemoryKHR)
  LOAD(vkCreateVideoSessionParametersKHR)
  LOAD(vkCmdBeginVideoCodingKHR)
  LOAD(vkCmdControlVideoCodingKHR)
  LOAD(vkCmdDecodeVideoKHR)
  LOAD(vkCmdEndVideoCodingKHR)

  VkExtensionProperties std_header = {
    .extensionName = VK_STD_VULKAN_VIDEO_CODEC_H264_DECODE_EXTENSION_NAME,
    .specVersion = VK_STD_VULKAN_VIDEO_CODEC_H264_DECODE_SPEC_VERSION,
  };
  VkVideoSessionCreateInfoKHR session_info = { VK_STRUCTURE_TYPE_VIDEO_SESSION_CREATE_INFO_KHR };
  session_info.queueFamilyIndex = video_decode_family;
  session_info.pVideoProfile = &profile;
  session_info.pictureFormat = nv12;
  session_info.maxCodedExtent = coded;
  session_info.referencePictureFormat = nv12;
  session_info.maxDpbSlots = caps.maxDpbSlots < 17 ? caps.maxDpbSlots : 17;
  session_info.maxActiveReferencePictures = caps.maxActiveReferencePictures;
  session_info.pStdHeaderVersion = &std_header;
  VkVideoSessionKHR session;
  VK_CHECK(vkCreateVideoSessionKHR(device, &session_info, 0, &session));
  uint32_t memory_requirement_count = 0;
  vkGetVideoSessionMemoryRequirementsKHR(device, session, &memory_requirement_count, 0);
  VkVideoSessionMemoryRequirementsKHR *memory_requirements = checked_malloc(memory_requirement_count * sizeof(*memory_requirements));
  for (uint32_t k = 0; k < memory_requirement_count; k++) {
    memory_requirements[k] = (VkVideoSessionMemoryRequirementsKHR){ VK_STRUCTURE_TYPE_VIDEO_SESSION_MEMORY_REQUIREMENTS_KHR };
  }
  vkGetVideoSessionMemoryRequirementsKHR(device, session, &memory_requirement_count, memory_requirements);
  VkBindVideoSessionMemoryInfoKHR *binds = checked_malloc(memory_requirement_count * sizeof(*binds));
  for (uint32_t k = 0; k < memory_requirement_count; k++) {
    VkMemoryAllocateInfo allocate_info = { VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO };
    allocate_info.allocationSize = memory_requirements[k].memoryRequirements.size;
    allocate_info.memoryTypeIndex = find_memory_type(memory_requirements[k].memoryRequirements.memoryTypeBits, VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
    VkDeviceMemory memory;
    VK_CHECK(vkAllocateMemory(device, &allocate_info, 0, &memory));
    binds[k] = (VkBindVideoSessionMemoryInfoKHR){ VK_STRUCTURE_TYPE_BIND_VIDEO_SESSION_MEMORY_INFO_KHR };
    binds[k].memoryBindIndex = memory_requirements[k].memoryBindIndex;
    binds[k].memory = memory;
    binds[k].memorySize = allocate_info.allocationSize;
  }
  VK_CHECK(vkBindVideoSessionMemoryKHR(device, session, memory_requirement_count, binds));

  StdVideoH264SequenceParameterSet std_sps;
  memset(&std_sps, 0, sizeof std_sps);
  std_sps.profile_idc = STD_VIDEO_H264_PROFILE_IDC_HIGH;
  std_sps.level_idc = STD_VIDEO_H264_LEVEL_IDC_4_0;
  std_sps.seq_parameter_set_id = sps.sps_id;
  std_sps.chroma_format_idc = (StdVideoH264ChromaFormatIdc)sps.chroma_format_idc;
  std_sps.log2_max_frame_num_minus4 = sps.log2_max_frame_num_minus4;
  std_sps.pic_order_cnt_type = (StdVideoH264PocType)sps.poc_type;
  std_sps.log2_max_pic_order_cnt_lsb_minus4 = sps.log2_max_poc_lsb_minus4;
  std_sps.max_num_ref_frames = sps.max_num_ref;
  std_sps.pic_width_in_mbs_minus1 = sps.width_in_mbs_minus1;
  std_sps.pic_height_in_map_units_minus1 = sps.height_in_map_units_minus1;
  std_sps.frame_crop_left_offset = sps.crop_left;
  std_sps.frame_crop_right_offset = sps.crop_right;
  std_sps.frame_crop_top_offset = sps.crop_top;
  std_sps.frame_crop_bottom_offset = sps.crop_bottom;
  std_sps.flags.frame_mbs_only_flag = sps.frame_mbs_only;
  std_sps.flags.direct_8x8_inference_flag = sps.direct_8x8;
  std_sps.flags.frame_cropping_flag = (sps.crop_left || sps.crop_right || sps.crop_top || sps.crop_bottom);
  StdVideoH264PictureParameterSet std_pps;
  memset(&std_pps, 0, sizeof std_pps);
  std_pps.seq_parameter_set_id = pps.sps_id;
  std_pps.pic_parameter_set_id = pps.pps_id;
  std_pps.num_ref_idx_l0_default_active_minus1 = pps.num_ref_l0_minus1;
  std_pps.num_ref_idx_l1_default_active_minus1 = pps.num_ref_l1_minus1;
  std_pps.weighted_bipred_idc = (StdVideoH264WeightedBipredIdc)pps.weighted_bipred;
  std_pps.pic_init_qp_minus26 = pps.pic_init_qp_minus26;
  std_pps.pic_init_qs_minus26 = pps.pic_init_qs_minus26;
  std_pps.chroma_qp_index_offset = pps.chroma_qp_offset;
  std_pps.second_chroma_qp_index_offset = pps.second_chroma_qp_offset;
  std_pps.flags.entropy_coding_mode_flag = pps.entropy_coding_mode;
  std_pps.flags.weighted_pred_flag = pps.weighted_pred;
  std_pps.flags.deblocking_filter_control_present_flag = pps.deblocking_control;
  std_pps.flags.constrained_intra_pred_flag = pps.constrained_intra;
  std_pps.flags.bottom_field_pic_order_in_frame_present_flag = pps.bottom_field_poc;
  std_pps.flags.transform_8x8_mode_flag = pps.transform_8x8;
  std_pps.flags.redundant_pic_cnt_present_flag = pps.redundant;
  VkVideoDecodeH264SessionParametersAddInfoKHR add_info = { VK_STRUCTURE_TYPE_VIDEO_DECODE_H264_SESSION_PARAMETERS_ADD_INFO_KHR };
  add_info.stdSPSCount = 1;
  add_info.pStdSPSs = &std_sps;
  add_info.stdPPSCount = 1;
  add_info.pStdPPSs = &std_pps;
  VkVideoDecodeH264SessionParametersCreateInfoKHR h264_params = { VK_STRUCTURE_TYPE_VIDEO_DECODE_H264_SESSION_PARAMETERS_CREATE_INFO_KHR };
  h264_params.maxStdSPSCount = 1;
  h264_params.maxStdPPSCount = 1;
  h264_params.pParametersAddInfo = &add_info;
  VkVideoSessionParametersCreateInfoKHR parameters_info = { VK_STRUCTURE_TYPE_VIDEO_SESSION_PARAMETERS_CREATE_INFO_KHR };
  parameters_info.pNext = &h264_params;
  parameters_info.videoSession = session;
  VkVideoSessionParametersKHR parameters;
  VK_CHECK(vkCreateVideoSessionParametersKHR(device, &parameters_info, 0, &parameters));

  // ---- DPB pool (NV12 reference/decode-target images) + bitstream buffer ----
  size_t luma_size = (size_t)coded.width * coded.height, chroma_size = luma_size / 2;
  int slot_count = (int)caps.maxDpbSlots;
  if (slot_count > 8) {
    slot_count = 8;
  }
  int max_ref = sps.max_num_ref;
  if (max_ref < 1) {
    max_ref = 1;
  }
  if (max_ref > slot_count - 1) {
    max_ref = slot_count - 1;
  }
  VkImage dpb_image[8];
  VkImageView dpb_view[8];
  VkImageLayout dpb_layout[8];
  struct { int used, poc, frame_num; } slot[8];
  VkVideoPictureResourceInfoKHR picture_resource[8];
  for (int s = 0; s < slot_count; s++) {
    VkImageCreateInfo image_info = { VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO };
    image_info.pNext = &profile_list;
    image_info.imageType = VK_IMAGE_TYPE_2D;
    image_info.format = nv12;
    image_info.extent = (VkExtent3D){ coded.width, coded.height, 1 };
    image_info.mipLevels = 1;
    image_info.arrayLayers = 1;
    image_info.samples = 1;
    image_info.tiling = VK_IMAGE_TILING_OPTIMAL;
    image_info.usage = VK_IMAGE_USAGE_VIDEO_DECODE_DPB_BIT_KHR | VK_IMAGE_USAGE_VIDEO_DECODE_DST_BIT_KHR | VK_IMAGE_USAGE_TRANSFER_SRC_BIT;
    image_info.queueFamilyIndexCount = 1;
    image_info.pQueueFamilyIndices = (uint32_t[]){ video_decode_family };
    VK_CHECK(vkCreateImage(device, &image_info, 0, &dpb_image[s]));
    VkMemoryRequirements requirements;
    vkGetImageMemoryRequirements(device, dpb_image[s], &requirements);
    VkMemoryAllocateInfo allocate_info = { VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO };
    allocate_info.allocationSize = requirements.size;
    allocate_info.memoryTypeIndex = find_memory_type(requirements.memoryTypeBits, VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
    VkDeviceMemory memory;
    VK_CHECK(vkAllocateMemory(device, &allocate_info, 0, &memory));
    vkBindImageMemory(device, dpb_image[s], memory, 0);
    VkImageViewUsageCreateInfo view_usage = { VK_STRUCTURE_TYPE_IMAGE_VIEW_USAGE_CREATE_INFO };
    view_usage.usage = VK_IMAGE_USAGE_VIDEO_DECODE_DPB_BIT_KHR | VK_IMAGE_USAGE_VIDEO_DECODE_DST_BIT_KHR;
    VkImageViewCreateInfo view_info = { VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO };
    view_info.pNext = &view_usage;
    view_info.image = dpb_image[s];
    view_info.viewType = VK_IMAGE_VIEW_TYPE_2D;
    view_info.format = nv12;
    view_info.subresourceRange = (VkImageSubresourceRange){ VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1 };
    VK_CHECK(vkCreateImageView(device, &view_info, 0, &dpb_view[s]));
    dpb_layout[s] = VK_IMAGE_LAYOUT_UNDEFINED;
    slot[s].used = 0;
    picture_resource[s] = (VkVideoPictureResourceInfoKHR){ VK_STRUCTURE_TYPE_VIDEO_PICTURE_RESOURCE_INFO_KHR };
    picture_resource[s].codedExtent = coded;
    picture_resource[s].imageViewBinding = dpb_view[s];
  }
  VkDeviceSize alignment = caps.minBitstreamBufferSizeAlignment;
  size_t max_frame_length = 0;
  for (int f = 0; f < frame_count; f++) {
    if (frames[f].length + 1 > max_frame_length) {
      max_frame_length = frames[f].length + 1;
    }
  }
  size_t bitstream_length = (max_frame_length + alignment - 1) / alignment * alignment;
  VkBufferCreateInfo bitstream_info = { VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO };
  bitstream_info.pNext = &profile_list;
  bitstream_info.size = bitstream_length;
  bitstream_info.usage = VK_BUFFER_USAGE_VIDEO_DECODE_SRC_BIT_KHR;
  VkBuffer bitstream_buffer;
  VK_CHECK(vkCreateBuffer(device, &bitstream_info, 0, &bitstream_buffer));
  VkMemoryRequirements bitstream_requirements;
  vkGetBufferMemoryRequirements(device, bitstream_buffer, &bitstream_requirements);
  VkMemoryAllocateInfo bitstream_allocate = { VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO };
  bitstream_allocate.allocationSize = bitstream_requirements.size;
  bitstream_allocate.memoryTypeIndex = find_memory_type(bitstream_requirements.memoryTypeBits, VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
  VkDeviceMemory bitstream_memory;
  VK_CHECK(vkAllocateMemory(device, &bitstream_allocate, 0, &bitstream_memory));
  vkBindBufferMemory(device, bitstream_buffer, bitstream_memory, 0);
  void *bitstream_map;
  VK_CHECK(vkMapMemory(device, bitstream_memory, 0, VK_WHOLE_SIZE, 0, &bitstream_map));

  // ---- GPU NV12->RGB resources: a sampled NV12 stage image + plane views + sampler, and an RGBA pool ----
  #define REORDER 8
  int pool_count = REORDER + 8;   // held (<= REORDER+1) + in-flight presents (ring = 4) + spare
  uint32_t shared_families[2] = { (uint32_t)video_decode_family, (uint32_t)graphics_family };
  int concurrent = (video_decode_family != graphics_family);
  VkImageCreateInfo stage_info = { VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO };
  stage_info.flags = VK_IMAGE_CREATE_MUTABLE_FORMAT_BIT;   // needed to make R8 / R8G8 plane views
  stage_info.imageType = VK_IMAGE_TYPE_2D;
  stage_info.format = nv12;
  stage_info.extent = (VkExtent3D){ coded.width, coded.height, 1 };
  stage_info.mipLevels = 1;
  stage_info.arrayLayers = 1;
  stage_info.samples = 1;
  stage_info.tiling = VK_IMAGE_TILING_OPTIMAL;
  stage_info.usage = VK_IMAGE_USAGE_TRANSFER_DST_BIT | VK_IMAGE_USAGE_SAMPLED_BIT;
  if (concurrent) {
    stage_info.sharingMode = VK_SHARING_MODE_CONCURRENT;
    stage_info.queueFamilyIndexCount = 2;
    stage_info.pQueueFamilyIndices = shared_families;
  }
  VkImage stage_image;
  VK_CHECK(vkCreateImage(device, &stage_info, 0, &stage_image));
  VkMemoryRequirements stage_requirements;
  vkGetImageMemoryRequirements(device, stage_image, &stage_requirements);
  VkMemoryAllocateInfo stage_allocate = { VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO };
  stage_allocate.allocationSize = stage_requirements.size;
  stage_allocate.memoryTypeIndex = find_memory_type(stage_requirements.memoryTypeBits, VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
  VkDeviceMemory stage_memory;
  VK_CHECK(vkAllocateMemory(device, &stage_allocate, 0, &stage_memory));
  vkBindImageMemory(device, stage_image, stage_memory, 0);
  VkImageLayout stage_layout = VK_IMAGE_LAYOUT_UNDEFINED;
  VkImageView stage_luma_view, stage_chroma_view;
  VkImageViewCreateInfo plane_view = { VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO };
  plane_view.image = stage_image;
  plane_view.viewType = VK_IMAGE_VIEW_TYPE_2D;
  plane_view.format = VK_FORMAT_R8_UNORM;
  plane_view.subresourceRange = (VkImageSubresourceRange){ VK_IMAGE_ASPECT_PLANE_0_BIT, 0, 1, 0, 1 };
  VK_CHECK(vkCreateImageView(device, &plane_view, 0, &stage_luma_view));
  plane_view.format = VK_FORMAT_R8G8_UNORM;
  plane_view.subresourceRange.aspectMask = VK_IMAGE_ASPECT_PLANE_1_BIT;
  VK_CHECK(vkCreateImageView(device, &plane_view, 0, &stage_chroma_view));
  VkSamplerCreateInfo sampler_info = { VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO };
  sampler_info.magFilter = sampler_info.minFilter = VK_FILTER_NEAREST;
  sampler_info.addressModeU = sampler_info.addressModeV = VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE;
  VkSampler sampler;
  VK_CHECK(vkCreateSampler(device, &sampler_info, 0, &sampler));

  pool_images = checked_malloc((size_t)pool_count * sizeof(VkImage));
  VkImageView *pool_views = checked_malloc((size_t)pool_count * sizeof(VkImageView));
  for (int p = 0; p < pool_count; p++) {
    VkImageCreateInfo pool_info = { VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO };
    pool_info.imageType = VK_IMAGE_TYPE_2D;
    pool_info.format = VK_FORMAT_R8G8B8A8_UNORM;
    pool_info.extent = (VkExtent3D){ width, height, 1 };
    pool_info.mipLevels = 1;
    pool_info.arrayLayers = 1;
    pool_info.samples = 1;
    pool_info.tiling = VK_IMAGE_TILING_OPTIMAL;
    pool_info.usage = VK_IMAGE_USAGE_STORAGE_BIT | VK_IMAGE_USAGE_TRANSFER_SRC_BIT;
    VK_CHECK(vkCreateImage(device, &pool_info, 0, &pool_images[p]));
    VkMemoryRequirements requirements;
    vkGetImageMemoryRequirements(device, pool_images[p], &requirements);
    VkMemoryAllocateInfo allocate_info = { VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO };
    allocate_info.allocationSize = requirements.size;
    allocate_info.memoryTypeIndex = find_memory_type(requirements.memoryTypeBits, VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
    VkDeviceMemory memory;
    VK_CHECK(vkAllocateMemory(device, &allocate_info, 0, &memory));
    vkBindImageMemory(device, pool_images[p], memory, 0);
    VkImageViewCreateInfo view_info = { VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO };
    view_info.image = pool_images[p];
    view_info.viewType = VK_IMAGE_VIEW_TYPE_2D;
    view_info.format = VK_FORMAT_R8G8B8A8_UNORM;
    view_info.subresourceRange = (VkImageSubresourceRange){ VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1 };
    VK_CHECK(vkCreateImageView(device, &view_info, 0, &pool_views[p]));
  }
  pool_free = checked_malloc((size_t)pool_count * sizeof(int));
  free_count = pool_count;
  for (int p = 0; p < pool_count; p++) {
    pool_free[p] = p;
  }
  for (int k = 0; k < 4; k++) {
    ring_pool[k] = -1;
  }

  // verify is taken from ctx->verify; --verify on fwvplay drives it. ctx->decode_to exports to OpenDML AVI.
  if (ctx->decode_to) {
    g_avi = avi_open(ctx->decode_to, width, height, ctx->fps_num, ctx->fps_den,
                     ctx->audio_pcm, ctx->audio_frames, ctx->audio_channels, ctx->audio_rate);
    if (!g_avi) {
      die("cannot open --decode-to output");
    }
    printf("decode-to: writing %s (OpenDML AVI, RGB32 + PCM16)\n", ctx->decode_to);
  }
  verify_output = checked_malloc((size_t)frame_count * sizeof(void *));
  verify_count = 0;
  if (verify || g_avi) {   // both need the per-frame readback of the decoded pool image
    VkBufferCreateInfo verify_info = { VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO };
    verify_info.size = (size_t)width * height * 4;
    verify_info.usage = VK_BUFFER_USAGE_TRANSFER_DST_BIT;
    VK_CHECK(vkCreateBuffer(device, &verify_info, 0, &verify_buffer));
    VkMemoryRequirements requirements;
    vkGetBufferMemoryRequirements(device, verify_buffer, &requirements);
    VkMemoryAllocateInfo allocate_info = { VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO };
    allocate_info.allocationSize = requirements.size;
    allocate_info.memoryTypeIndex = find_memory_type(requirements.memoryTypeBits, VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_CACHED_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
    VkDeviceMemory memory;
    VK_CHECK(vkAllocateMemory(device, &allocate_info, 0, &memory));
    vkBindBufferMemory(device, verify_buffer, memory, 0);
    VK_CHECK(vkMapMemory(device, memory, 0, VK_WHOLE_SIZE, 0, &verify_map));
  }

  // One-time: move all pool images into GENERAL (the compute shader stores into them).
  VkFenceCreateInfo compute_fence_info = { VK_STRUCTURE_TYPE_FENCE_CREATE_INFO };
  VkFence compute_fence;
  vkCreateFence(device, &compute_fence_info, 0, &compute_fence);
  {
    VkCommandBufferBeginInfo begin_info = { VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO };
    begin_info.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
    vkBeginCommandBuffer(compute_command, &begin_info);
    for (int p = 0; p < pool_count; p++) {
      image_barrier(compute_command, pool_images[p], VK_IMAGE_LAYOUT_UNDEFINED, VK_IMAGE_LAYOUT_GENERAL,
                    0, VK_ACCESS_2_SHADER_WRITE_BIT, VK_PIPELINE_STAGE_2_NONE, VK_PIPELINE_STAGE_2_COMPUTE_SHADER_BIT);
    }
    vkEndCommandBuffer(compute_command);
    VkSubmitInfo submit = { VK_STRUCTURE_TYPE_SUBMIT_INFO };
    submit.commandBufferCount = 1;
    submit.pCommandBuffers = &compute_command;
    vkQueueSubmit(graphics_queue, 1, &submit, 0);
    vkQueueWaitIdle(graphics_queue);
  }

  // Compute pipeline: samples the stage NV12 plane views, writes RGBA into a pool image.
  size_t spirv_size;
  uint32_t *spirv = load_spirv("shaders/nv12rgb.spv", &spirv_size);
  VkShaderModuleCreateInfo module_info = { VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO };
  module_info.codeSize = spirv_size;
  module_info.pCode = spirv;
  VkShaderModule module;
  VK_CHECK(vkCreateShaderModule(device, &module_info, 0, &module));
  VkDescriptorSetLayoutBinding bindings[3] = {
    { 0, VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, 1, VK_SHADER_STAGE_COMPUTE_BIT, 0 },
    { 1, VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, 1, VK_SHADER_STAGE_COMPUTE_BIT, 0 },
    { 2, VK_DESCRIPTOR_TYPE_STORAGE_IMAGE, 1, VK_SHADER_STAGE_COMPUTE_BIT, 0 },
  };
  VkDescriptorSetLayoutCreateInfo set_layout_info = { VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO };
  set_layout_info.bindingCount = 3;
  set_layout_info.pBindings = bindings;
  VkDescriptorSetLayout set_layout;
  VK_CHECK(vkCreateDescriptorSetLayout(device, &set_layout_info, 0, &set_layout));
  VkPushConstantRange push_range = { VK_SHADER_STAGE_COMPUTE_BIT, 0, 8 };
  VkPipelineLayoutCreateInfo pipeline_layout_info = { VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO };
  pipeline_layout_info.setLayoutCount = 1;
  pipeline_layout_info.pSetLayouts = &set_layout;
  pipeline_layout_info.pushConstantRangeCount = 1;
  pipeline_layout_info.pPushConstantRanges = &push_range;
  VkPipelineLayout compute_layout;
  VK_CHECK(vkCreatePipelineLayout(device, &pipeline_layout_info, 0, &compute_layout));
  VkComputePipelineCreateInfo pipeline_info = { VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO };
  pipeline_info.stage.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
  pipeline_info.stage.stage = VK_SHADER_STAGE_COMPUTE_BIT;
  pipeline_info.stage.module = module;
  pipeline_info.stage.pName = "main";
  pipeline_info.layout = compute_layout;
  VkPipeline compute_pipeline;
  VK_CHECK(vkCreateComputePipelines(device, 0, 1, &pipeline_info, 0, &compute_pipeline));

  VkDescriptorPoolSize descriptor_sizes[2] = {
    { VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, (uint32_t)pool_count * 2 },
    { VK_DESCRIPTOR_TYPE_STORAGE_IMAGE, (uint32_t)pool_count },
  };
  VkDescriptorPoolCreateInfo descriptor_pool_info = { VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO };
  descriptor_pool_info.maxSets = (uint32_t)pool_count;
  descriptor_pool_info.poolSizeCount = 2;
  descriptor_pool_info.pPoolSizes = descriptor_sizes;
  VkDescriptorPool descriptor_pool;
  VK_CHECK(vkCreateDescriptorPool(device, &descriptor_pool_info, 0, &descriptor_pool));
  VkDescriptorSet *descriptor_sets = checked_malloc((size_t)pool_count * sizeof(VkDescriptorSet));
  for (int p = 0; p < pool_count; p++) {
    VkDescriptorSetAllocateInfo allocate_info = { VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO };
    allocate_info.descriptorPool = descriptor_pool;
    allocate_info.descriptorSetCount = 1;
    allocate_info.pSetLayouts = &set_layout;
    VK_CHECK(vkAllocateDescriptorSets(device, &allocate_info, &descriptor_sets[p]));
    VkDescriptorImageInfo luma = { sampler, stage_luma_view, VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL };
    VkDescriptorImageInfo chroma = { sampler, stage_chroma_view, VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL };
    VkDescriptorImageInfo destination = { 0, pool_views[p], VK_IMAGE_LAYOUT_GENERAL };
    VkWriteDescriptorSet writes[3] = { { VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET }, { VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET }, { VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET } };
    writes[0].dstSet = descriptor_sets[p]; writes[0].dstBinding = 0; writes[0].descriptorCount = 1; writes[0].descriptorType = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER; writes[0].pImageInfo = &luma;
    writes[1].dstSet = descriptor_sets[p]; writes[1].dstBinding = 1; writes[1].descriptorCount = 1; writes[1].descriptorType = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER; writes[1].pImageInfo = &chroma;
    writes[2].dstSet = descriptor_sets[p]; writes[2].dstBinding = 2; writes[2].descriptorCount = 1; writes[2].descriptorType = VK_DESCRIPTOR_TYPE_STORAGE_IMAGE; writes[2].pImageInfo = &destination;
    vkUpdateDescriptorSets(device, 3, writes, 0, 0);
  }

  VkCommandPoolCreateInfo video_pool_info = { VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO };
  video_pool_info.queueFamilyIndex = video_decode_family;
  video_pool_info.flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT;
  VkCommandPool video_pool;
  VK_CHECK(vkCreateCommandPool(device, &video_pool_info, 0, &video_pool));
  VkCommandBufferAllocateInfo video_alloc = { VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO };
  video_alloc.commandPool = video_pool;
  video_alloc.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
  video_alloc.commandBufferCount = 1;
  VkCommandBuffer decode_command;
  vkAllocateCommandBuffers(device, &video_alloc, &decode_command);

  // audio (audio_device / total_audio_bytes / audio_channels / audio_rate) is already decoded + queued by
  // fwvplay (OGGV/QOAL/RPCM) and arrives via ctx; the loop below only paces to it and unpauses it.

  // ---- decode loop: decode -> copy DPB to stage -> compute NV12->RGB -> reorder -> aspect blit ----
  ReorderEntry reorder[REORDER + 2];
  int reorder_count = 0, gop_index = 0, reset_done = 0, displayed = 0, quit = 0;
  double start_time = now_milliseconds();
  if (audio_device && !g_avi) {   // decode-to is headless: don't start audio playback
    SDL_PauseAudioDevice(audio_device, 0);
  }
  int max_frame_num = 1 << (sps.log2_max_frame_num_minus4 + 4);

  for (int f = 0; f < frame_count && !quit; f++) {
    SDL_Event event;
    while (SDL_PollEvent(&event)) {
      if (event.type == SDL_QUIT || (event.type == SDL_KEYDOWN && event.key.keysym.sym == SDLK_ESCAPE)) {
        quit = 1;
      }
    }
    if (frames[f].idr) {
      for (int s = 0; s < slot_count; s++) {
        slot[s].used = 0;
      }
      if (f > 0) {
        gop_index++;
      }
    }
    int current = -1;
    for (int s = 0; s < slot_count; s++) {
      if (!slot[s].used) {
        current = s;
        break;
      }
    }
    if (current < 0) {
      int oldest = -1, oldest_wrap = 0;
      for (int s = 0; s < slot_count; s++) {
        if (slot[s].used) {
          int wrap = slot[s].frame_num > frames[f].frame_num ? slot[s].frame_num - max_frame_num : slot[s].frame_num;
          if (oldest < 0 || wrap < oldest_wrap) {
            oldest = s;
            oldest_wrap = wrap;
          }
        }
      }
      slot[oldest].used = 0;
      current = oldest;
    }

    VkVideoReferenceSlotInfoKHR references[8], begin_slots[9];
    StdVideoDecodeH264ReferenceInfo reference_info[8];
    VkVideoDecodeH264DpbSlotInfoKHR reference_dpb[8];
    int reference_count = 0;
    for (int s = 0; s < slot_count; s++) {
      if (slot[s].used) {
        memset(&reference_info[reference_count], 0, sizeof reference_info[reference_count]);
        reference_info[reference_count].FrameNum = slot[s].frame_num;
        reference_info[reference_count].PicOrderCnt[0] = reference_info[reference_count].PicOrderCnt[1] = slot[s].poc;
        reference_dpb[reference_count] = (VkVideoDecodeH264DpbSlotInfoKHR){ VK_STRUCTURE_TYPE_VIDEO_DECODE_H264_DPB_SLOT_INFO_KHR };
        reference_dpb[reference_count].pStdReferenceInfo = &reference_info[reference_count];
        references[reference_count] = (VkVideoReferenceSlotInfoKHR){ VK_STRUCTURE_TYPE_VIDEO_REFERENCE_SLOT_INFO_KHR };
        references[reference_count].pNext = &reference_dpb[reference_count];
        references[reference_count].slotIndex = s;
        references[reference_count].pPictureResource = &picture_resource[s];
        reference_count++;
      }
    }
    StdVideoDecodeH264ReferenceInfo setup_info;
    memset(&setup_info, 0, sizeof setup_info);
    setup_info.FrameNum = frames[f].frame_num;
    setup_info.PicOrderCnt[0] = setup_info.PicOrderCnt[1] = frames[f].poc;
    VkVideoDecodeH264DpbSlotInfoKHR setup_dpb = { VK_STRUCTURE_TYPE_VIDEO_DECODE_H264_DPB_SLOT_INFO_KHR };
    setup_dpb.pStdReferenceInfo = &setup_info;
    VkVideoReferenceSlotInfoKHR setup_slot = { VK_STRUCTURE_TYPE_VIDEO_REFERENCE_SLOT_INFO_KHR };
    setup_slot.pNext = &setup_dpb;
    setup_slot.slotIndex = current;
    setup_slot.pPictureResource = &picture_resource[current];
    for (int k = 0; k < reference_count; k++) {
      begin_slots[k] = references[k];
    }
    begin_slots[reference_count] = setup_slot;
    begin_slots[reference_count].slotIndex = -1;

    memset(bitstream_map, 0, bitstream_length);
    ((uint8_t *)bitstream_map)[0] = 0;
    memcpy((uint8_t *)bitstream_map + 1, frames[f].nal, frames[f].length);
    size_t range = (frames[f].length + 1 + alignment - 1) / alignment * alignment;

    // Decode on the video queue, then copy the decoded NV12 into the (sampled) stage image.
    vkResetCommandBuffer(decode_command, 0);
    VkCommandBufferBeginInfo begin_info = { VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO };
    begin_info.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
    vkBeginCommandBuffer(decode_command, &begin_info);
    image_barrier(decode_command, dpb_image[current], dpb_layout[current], VK_IMAGE_LAYOUT_VIDEO_DECODE_DPB_KHR,
                  0, VK_ACCESS_2_VIDEO_DECODE_WRITE_BIT_KHR | VK_ACCESS_2_VIDEO_DECODE_READ_BIT_KHR, VK_PIPELINE_STAGE_2_ALL_COMMANDS_BIT, VK_PIPELINE_STAGE_2_VIDEO_DECODE_BIT_KHR);
    dpb_layout[current] = VK_IMAGE_LAYOUT_VIDEO_DECODE_DPB_KHR;
    VkVideoBeginCodingInfoKHR begin_coding = { VK_STRUCTURE_TYPE_VIDEO_BEGIN_CODING_INFO_KHR };
    begin_coding.videoSession = session;
    begin_coding.videoSessionParameters = parameters;
    begin_coding.referenceSlotCount = reference_count + 1;
    begin_coding.pReferenceSlots = begin_slots;
    vkCmdBeginVideoCodingKHR(decode_command, &begin_coding);
    if (!reset_done) {
      VkVideoCodingControlInfoKHR control = { VK_STRUCTURE_TYPE_VIDEO_CODING_CONTROL_INFO_KHR };
      control.flags = VK_VIDEO_CODING_CONTROL_RESET_BIT_KHR;
      vkCmdControlVideoCodingKHR(decode_command, &control);
      reset_done = 1;
    }
    StdVideoDecodeH264PictureInfo std_picture;
    memset(&std_picture, 0, sizeof std_picture);
    std_picture.flags.IdrPicFlag = frames[f].idr;
    std_picture.flags.is_reference = (frames[f].ref_idc != 0);
    std_picture.flags.is_intra = (frames[f].type == 2 || frames[f].idr);
    std_picture.seq_parameter_set_id = sps.sps_id;
    std_picture.pic_parameter_set_id = pps.pps_id;
    std_picture.frame_num = frames[f].frame_num;
    std_picture.PicOrderCnt[0] = std_picture.PicOrderCnt[1] = frames[f].poc;
    uint32_t slice_offset = 0;
    VkVideoDecodeH264PictureInfoKHR h264_picture = { VK_STRUCTURE_TYPE_VIDEO_DECODE_H264_PICTURE_INFO_KHR };
    h264_picture.pStdPictureInfo = &std_picture;
    h264_picture.sliceCount = 1;
    h264_picture.pSliceOffsets = &slice_offset;
    VkVideoDecodeInfoKHR decode = { VK_STRUCTURE_TYPE_VIDEO_DECODE_INFO_KHR };
    decode.pNext = &h264_picture;
    decode.srcBuffer = bitstream_buffer;
    decode.srcBufferRange = range;
    decode.dstPictureResource = picture_resource[current];
    decode.pSetupReferenceSlot = &setup_slot;
    decode.referenceSlotCount = reference_count;
    decode.pReferenceSlots = reference_count ? references : NULL;
    vkCmdDecodeVideoKHR(decode_command, &decode);
    VkVideoEndCodingInfoKHR end_coding = { VK_STRUCTURE_TYPE_VIDEO_END_CODING_INFO_KHR };
    vkCmdEndVideoCodingKHR(decode_command, &end_coding);

    image_barrier(decode_command, dpb_image[current], VK_IMAGE_LAYOUT_VIDEO_DECODE_DPB_KHR, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
                  VK_ACCESS_2_VIDEO_DECODE_WRITE_BIT_KHR, VK_ACCESS_2_TRANSFER_READ_BIT, VK_PIPELINE_STAGE_2_VIDEO_DECODE_BIT_KHR, VK_PIPELINE_STAGE_2_COPY_BIT);
    image_barrier(decode_command, stage_image, stage_layout, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
                  0, VK_ACCESS_2_TRANSFER_WRITE_BIT, VK_PIPELINE_STAGE_2_ALL_COMMANDS_BIT, VK_PIPELINE_STAGE_2_COPY_BIT);
    stage_layout = VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
    VkImageCopy plane_copies[2];
    memset(plane_copies, 0, sizeof plane_copies);
    plane_copies[0].srcSubresource = plane_copies[0].dstSubresource = (VkImageSubresourceLayers){ VK_IMAGE_ASPECT_PLANE_0_BIT, 0, 0, 1 };
    plane_copies[0].extent = (VkExtent3D){ coded.width, coded.height, 1 };
    plane_copies[1].srcSubresource = plane_copies[1].dstSubresource = (VkImageSubresourceLayers){ VK_IMAGE_ASPECT_PLANE_1_BIT, 0, 0, 1 };
    plane_copies[1].extent = (VkExtent3D){ coded.width / 2, coded.height / 2, 1 };
    vkCmdCopyImage(decode_command, dpb_image[current], VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, stage_image, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 2, plane_copies);
    image_barrier(decode_command, dpb_image[current], VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, VK_IMAGE_LAYOUT_VIDEO_DECODE_DPB_KHR,
                  VK_ACCESS_2_TRANSFER_READ_BIT, VK_ACCESS_2_VIDEO_DECODE_READ_BIT_KHR, VK_PIPELINE_STAGE_2_COPY_BIT, VK_PIPELINE_STAGE_2_VIDEO_DECODE_BIT_KHR);
    vkEndCommandBuffer(decode_command);
    VkSubmitInfo decode_submit = { VK_STRUCTURE_TYPE_SUBMIT_INFO };
    decode_submit.commandBufferCount = 1;
    decode_submit.pCommandBuffers = &decode_command;
    VK_CHECK(vkQueueSubmit(video_queue, 1, &decode_submit, 0));
    VK_CHECK(vkQueueWaitIdle(video_queue));

    // GPU NV12->RGB into a free pool slot.
    int pool_index = pool_free[--free_count];
    vkResetCommandBuffer(compute_command, 0);
    VkCommandBufferBeginInfo compute_begin = { VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO };
    compute_begin.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
    vkBeginCommandBuffer(compute_command, &compute_begin);
    image_barrier(compute_command, stage_image, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                  VK_ACCESS_2_TRANSFER_WRITE_BIT, VK_ACCESS_2_SHADER_READ_BIT, VK_PIPELINE_STAGE_2_COPY_BIT, VK_PIPELINE_STAGE_2_COMPUTE_SHADER_BIT);
    stage_layout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
    vkCmdBindPipeline(compute_command, VK_PIPELINE_BIND_POINT_COMPUTE, compute_pipeline);
    vkCmdBindDescriptorSets(compute_command, VK_PIPELINE_BIND_POINT_COMPUTE, compute_layout, 0, 1, &descriptor_sets[pool_index], 0, 0);
    int32_t push[2] = { width, height };
    vkCmdPushConstants(compute_command, compute_layout, VK_SHADER_STAGE_COMPUTE_BIT, 0, 8, push);
    vkCmdDispatch(compute_command, (width + 7) / 8, (height + 7) / 8, 1);
    // Make the compute write available to the later present blit (else it reads a stale pool slot).
    image_barrier(compute_command, pool_images[pool_index], VK_IMAGE_LAYOUT_GENERAL, VK_IMAGE_LAYOUT_GENERAL,
                  VK_ACCESS_2_SHADER_WRITE_BIT, VK_ACCESS_2_TRANSFER_READ_BIT, VK_PIPELINE_STAGE_2_COMPUTE_SHADER_BIT, VK_PIPELINE_STAGE_2_BLIT_BIT);
    vkEndCommandBuffer(compute_command);
    VkSubmitInfo compute_submit = { VK_STRUCTURE_TYPE_SUBMIT_INFO };
    compute_submit.commandBufferCount = 1;
    compute_submit.pCommandBuffers = &compute_command;
    VK_CHECK(vkResetFences(device, 1, &compute_fence));
    VK_CHECK(vkQueueSubmit(graphics_queue, 1, &compute_submit, compute_fence));
    VK_CHECK(vkWaitForFences(device, 1, &compute_fence, VK_TRUE, UINT64_MAX));

    reorder[reorder_count].key = ((uint64_t)gop_index << 24) | (uint32_t)(frames[f].poc + 0x800000);
    reorder[reorder_count].index = pool_index;
    reorder_count++;

    // Keep this frame's slot if it is a reference; sliding window to at most max_ref refs.
    if (frames[f].ref_idc) {
      slot[current].used = 1;
      slot[current].poc = frames[f].poc;
      slot[current].frame_num = frames[f].frame_num;
      int used_count = 0;
      for (int s = 0; s < slot_count; s++) {
        used_count += slot[s].used;
      }
      while (used_count > max_ref) {
        int oldest = -1, oldest_wrap = 0;
        for (int s = 0; s < slot_count; s++) {
          if (slot[s].used) {
            int wrap = slot[s].frame_num > frames[f].frame_num ? slot[s].frame_num - max_frame_num : slot[s].frame_num;
            if (oldest < 0 || wrap < oldest_wrap) {
              oldest = s;
              oldest_wrap = wrap;
            }
          }
        }
        slot[oldest].used = 0;
        used_count--;
      }
    }

    // Bumping: once the reorder buffer is full, present the lowest-POC frame (paced to the audio).
    if (reorder_count > REORDER) {
      int lowest = 0;
      for (int k = 1; k < reorder_count; k++) {
        if (reorder[k].key < reorder[lowest].key) {
          lowest = k;
        }
      }
      if (audio_device && !g_avi) {
        double frame_time = displayed / fps;
        for (;;) {
          Uint32 queued = SDL_GetQueuedAudioSize(audio_device);
          double audio_seconds = (double)(total_audio_bytes - queued) / (audio_channels * 2) / (double)audio_rate;
          if (audio_seconds + 0.001 >= frame_time || quit) {
            break;
          }
          SDL_Delay(1);
        }
      } else {
        double target = start_time + displayed * 1000.0 / fps;
        double delay = target - now_milliseconds();
        if (delay > 1) {
          SDL_Delay((uint32_t)delay);
        }
      }
      present_one(reorder[lowest].index);
      displayed++;
      for (int k = lowest; k < reorder_count - 1; k++) {
        reorder[k] = reorder[k + 1];
      }
      reorder_count--;
    }
  }

  // Flush the remaining buffered frames in display order.
  for (int p = 0; p < reorder_count && !quit; p++) {
    int lowest = p;
    for (int k = p + 1; k < reorder_count; k++) {
      if (reorder[k].key < reorder[lowest].key) {
        lowest = k;
      }
    }
    ReorderEntry temp = reorder[p];
    reorder[p] = reorder[lowest];
    reorder[lowest] = temp;
    if (audio_device && !g_avi) {
      double frame_time = displayed / fps;
      for (;;) {
        Uint32 queued = SDL_GetQueuedAudioSize(audio_device);
        double audio_seconds = (double)(total_audio_bytes - queued) / (audio_channels * 2) / (double)audio_rate;
        if (audio_seconds + 0.001 >= frame_time || quit) {
          break;
        }
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
          if (event.type == SDL_QUIT) {
            quit = 1;
          }
        }
        SDL_Delay(1);
      }
    }
    present_one(reorder[p].index);
    displayed++;
  }

  vkDeviceWaitIdle(device);
  double elapsed = (now_milliseconds() - start_time) / 1000.0;
  if (g_avi) {
    avi_close(g_avi);
    printf("decode-to: wrote %d frames in %.2f s\n", displayed, elapsed);
    return 0;
  }
  printf("played %d frames in %.2f s (%.1f fps) | HW H.264 decode + audio\n", displayed, elapsed, displayed / elapsed);

  if (verify && verify_count) {
    // Reference = ffmpeg's own decode of the SAME embedded H.264 (dumped to a temp file) in display order.
    FILE *blob_file = fopen("/tmp/fwv_verify.h264", "wb");
    if (blob_file) {
      fwrite(stream, 1, stream_length, blob_file);
      fclose(blob_file);
    }
    char command[4096];
    snprintf(command, sizeof command, "ffmpeg -v error -i /tmp/fwv_verify.h264 -frames:v %d -f rawvideo -pix_fmt rgb24 -", verify_count);
    FILE *reference_pipe = popen(command, "r");
    uint8_t *reference = checked_malloc((size_t)width * height * 3);
    double sse = 0;
    long sample_count = 0;
    int bad = 0;
    for (int k = 0; k < verify_count; k++) {
      if (fread(reference, 1, (size_t)width * height * 3, reference_pipe) != (size_t)width * height * 3) {
        break;
      }
      double frame_sse = 0;
      for (size_t j = 0; j < (size_t)width * height * 3; j++) {
        int difference = (int)verify_output[k][j] - (int)reference[j];
        frame_sse += (double)difference * difference;
      }
      sse += frame_sse;
      sample_count += (long)width * height * 3;
      double frame_mse = frame_sse / ((double)width * height * 3);
      double frame_psnr = frame_mse > 0 ? 10 * log10(255.0 * 255.0 / frame_mse) : 99;
      if (frame_psnr < 25) {
        if (bad < 6) {
          printf("  display frame %d: PSNR %.1f dB (LOW -> wrong content/order)\n", k, frame_psnr);
        }
        bad++;
      }
    }
    pclose(reference_pipe);
    double mean_squared_error = sample_count ? sse / (double)sample_count : 0;
    double psnr = mean_squared_error > 0 ? 10 * log10(255.0 * 255.0 / mean_squared_error) : 99;
    printf("VERIFY: GPU path avg PSNR over %d display frames = %.2f dB | %d low frames %s\n",
           verify_count, psnr, bad, (psnr > 40 && !bad) ? "=> content+order CORRECT (jitter is pure present timing)" : "=> content/order issue");
    return 0;
  }
  // fwvplay owns the SDL window + audio device + SDL lifetime (shared) — don't tear them down here.
  return 0;
}
