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
// fwa_audio.h — the "FWAC" audio sub-codec interface for the FWV container. The implementation in fwa_audio.c is
// the Flexible Wavelet Audio (FWA) codec with its standalone main()/CLI guarded out (FWA_NO_MAIN); it is a
// separate translation unit, so all of its internals stay file-local static and nothing clashes with fwvwave.c.
// fwvenc.c calls fwa_encode, fwvplay.c calls fwa_decode. The encoded stream is self-describing (channels / sample
// rate / frame count live in its header), like the QOAL/RPCM blobs, so the container only needs the "FWAC" tag.
#ifndef FWA_AUDIO_H
#define FWA_AUDIO_H

#include <stdint.h>

// Wavelet-audio encode parameters (mirrors the fwa CLI). Derived in fwvenc.c from --fwa-quality / --fwa-mode /
// --fwa-lms-taps / --fwa-no-pair / --fwa-pair-ms.
typedef struct {
  int quality;       // 0 = lossless (reversible 5/3), >= 1 = lossy (9/7); higher = coarser
  int perceptual;    // psychoacoustic ATH-shaped quantiser step sizes (lossy)
  int packet;        // adaptive wavelet-packet best basis (lossy)
  int joint;         // joint-stereo intensity (collapse the top Side bands to mono; lossy)
  int lms;           // lossless LMS predictor instead of 5/3 (Q0 only)
  int lms_taps;      // LMS tap count (when lms != 0)
  int pair_enabled;  // multichannel: pairwise L/R Mid/Side (default on)
  int adapt;         // multichannel: per-pair adaptive best-of-both (default on)
} FwaParams;

// Encode interleaved int16 PCM (`samples` = frames per channel) -> a self-describing FWA blob; returns the blob
// (malloc'd, caller frees) and its byte length via *out_size, or NULL on failure.
uint8_t *fwa_encode(const short *pcm, int samples, int channels, int sample_rate, const FwaParams *params, uint64_t *out_size);

// Decode a FWA blob -> interleaved int16 PCM (malloc'd, caller frees); reports channels / sample_rate / `samples`
// (frames per channel) read from the stream header. `size` is accepted for signature parity (unused internally).
short *fwa_decode(const uint8_t *blob, uint64_t size, int *channels, int *sample_rate, int *samples);

#endif
