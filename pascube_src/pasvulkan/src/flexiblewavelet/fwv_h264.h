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
// fwv_h264.h — H.264 hardware-decode path.
// fwvplay creates ONE shared device (with the video-decode queue + VK_KHR_video extensions) and, when
// the container carries an H.264 stream and the GPU supports it, hands these shared handles + the embedded
// Annex-B blob to run_h264_player(). The two paths are separate after init (no mid-stream switching).
#ifndef FWV_H264_H
#define FWV_H264_H

#include <stdint.h>
#include <stddef.h>
#include <vulkan/vulkan.h>
#include <SDL2/SDL.h>

typedef struct {
  VkInstance instance;
  VkPhysicalDevice physical_device;
  VkDevice device;
  VkQueue graphics_queue;
  int graphics_family;
  VkQueue video_queue;
  int video_family;
  VkSwapchainKHR swapchain;
  VkImage *swapchain_images;
  uint32_t swapchain_image_count;
  VkExtent2D extent;                 // current swapchain extent (for aspect-correct letterbox blit)
  SDL_Window *window;
  const uint8_t *blob;               // embedded H.264 Annex-B elementary stream
  size_t blob_size;
  int verify;                        // headless: decode + PSNR vs ffmpeg, no present
  const char *decode_to;             // --decode-to <file.avi>: export every decoded frame to OpenDML AVI (no present)
  double fps;
  uint32_t fps_num, fps_den;         // for the AVI export's exact frame rate
  const int16_t *audio_pcm;          // decoded PCM16 (for the AVI export's audio stream); may be NULL
  uint64_t audio_frames;             // per-channel sample frames in audio_pcm
  // audio is already decoded + queued by fwvplay (OGGV/QOAL/RPCM); the H.264 path only paces to it.
  SDL_AudioDeviceID audio_device;
  uint32_t total_audio_bytes;
  int audio_channels;
  int audio_rate;
} FwvH264Context;

int run_h264_player(const FwvH264Context *ctx);

#endif
