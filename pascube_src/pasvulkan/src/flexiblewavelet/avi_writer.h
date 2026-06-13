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
// avi_writer.h — a minimal OpenDML / AVI 2.0 muxer for `fwvplay --decode-to file.avi`.
// Writes uncompressed RGB32 (BI_RGB, bottom-up BGRA) video + 16-bit PCM audio, with the OpenDML
// superindex / ix## standard-index extensions so files can exceed 2 GB (4K RGB32 hits that in ~2 s).
// The caller feeds decoded RGBA8 frames one at a time; the writer interleaves the proportional audio
// from a caller-owned PCM buffer and patches all sizes / indexes on close.
#ifndef AVI_WRITER_H
#define AVI_WRITER_H

#include <stdint.h>

typedef struct AviWriter AviWriter;

// audio_pcm may be NULL (no audio). audio_frames = number of interleaved sample frames (per-channel count).
AviWriter *avi_open(const char *path, int width, int height, uint32_t fps_num, uint32_t fps_den,
                    const int16_t *audio_pcm, uint64_t audio_frames, int audio_channels, int audio_rate);

// One decoded frame: width*height RGBA8 (R,G,B,A bytes). The writer converts to bottom-up BGRA and also
// flushes the audio that belongs to this frame's time slice.
void avi_video_frame(AviWriter *writer, const uint8_t *rgba);

void avi_close(AviWriter *writer);   // flushes remaining audio + patches headers / indexes

#endif
