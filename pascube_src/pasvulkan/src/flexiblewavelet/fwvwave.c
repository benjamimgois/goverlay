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
 * fwvwave.c — the shared CPU reference core of the Flexible Wavelet Video (FWV) codec.
 *
 * Ground-truth CPU implementation that the GPU compute shaders are validated against (bit-exact for the lossless
 * 5/3 path, visually identical for the lossy 9/7 path). It is #included as a library by the GPU tools
 * (fwvenc / fwvdec / fwvplay), which define FWV_NO_MAIN to drop the standalone main() below and reuse the codec.
 * Holds the pieces shared across all modes: the YCoCg-R colour transform, the 1D/2D and temporal wavelets, the
 * bit-plane coding (independent 4-byte-aligned blocks), the motion-vector coders (Exp-Golomb + adaptive range),
 * the per-frame LZSS/LZBRRC frame compression, and the QOA-LE / raw-PCM audio sub-codecs.
 *
 * Per-frame spatial pipeline:
 *     RGB -> YCoCg-R colour transform -> 2D discrete wavelet transform -> quantize ->
 *            raw bit-plane coding in independent blocks -> byte stream + offset table
 * On top of that the container supports inter prediction (P / hierarchical B-frames with motion) and an
 * open-loop / motion-compensated (MCTF) 3D-DWT temporal mode, plus SDR/HDR (PQ/HLG, scRGB) and 4:4:4 / 4:2:2 / 4:2:0.
 *
 *     quality == 0 : LOSSLESS — reversible integer 5/3 (LeGall) wavelet, no quantization.
 *     quality >= 1 : LOSSY    — CDF 9/7 float wavelet, per-subband quantization.
 *
 * ffmpeg is used as a command-line tool only (via popen); the libav* libraries are never linked.
 *
 *     ./fwvwave in.(mp4|y4m) [quality=8] [levels=5] [max_frames]   (standalone CPU self-test: per-frame size + PSNR)
 */
#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <math.h>
#include <time.h>

// ------------------------------------------------------------------ small utilities

static void die(const char *message) {
  fprintf(stderr, "error: %s\n", message);
  exit(1);
}

// malloc that aborts on failure (and never returns a zero-size allocation).
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
  return (t.tv_sec * 1e3) + (t.tv_nsec * 1e-6);
}

// ----------------------------------------------------------------------- audio codecs
// The container tags its audio blob with a 4-byte sub-FOURCC (header.audio_codec): "OGGV" = OGG/Vorbis
// (the default, decoded with stb_vorbis in the player), "QOAL" = the little-endian QOA below, "RPCM" =
// raw PCM with a self-describing header. Each blob is self-contained; only the tag lives in the header.
// Every multi-byte field here is LITTLE-ENDIAN (the reference QOA is big-endian, which is dead weight on
// every contemporary target — x86, ARM/AArch64, RISC-V are all little-endian; big-endian only survives as
// network byte order).

static void store_u32_le(uint8_t *p, uint32_t v) {
  p[0] = (uint8_t)(v & 0xff);
  p[1] = (uint8_t)((v >> 8) & 0xff);
  p[2] = (uint8_t)((v >> 16) & 0xff);
  p[3] = (uint8_t)((v >> 24) & 0xff);
}

static uint32_t load_u32_le(const uint8_t *p) {
  return ((uint32_t)p[0]) | (((uint32_t)p[1]) << 8) | (((uint32_t)p[2]) << 16) | (((uint32_t)p[3]) << 24);
}

static void store_u64_le(uint8_t *p, uint64_t v) {
  for (int i = 0; i < 8; i++) {
    p[i] = (uint8_t)((v >> (i * 8)) & 0xff);
  }
}

static uint64_t load_u64_le(const uint8_t *p) {
  uint64_t v = 0;
  for (int i = 0; i < 8; i++) {
    v |= ((uint64_t)p[i]) << (i * 8);
  }
  return v;
}

// ---- RPCM: raw interleaved PCM with a 12-byte little-endian header ----
// Header: { u32 sample_rate, u32 channels, i32 bits } then the interleaved samples. `bits` is signed:
// > 0 = integer PCM, < 0 = float PCM, |bits| = bit depth. We emit s16 (bits = 16); the decoder also
// accepts s8 / s32 / f32 and converts to s16, so the tag stays valid if other depths appear later.

static uint8_t *rpcm_encode_s16(const short *pcm, int samples, int channels, int sample_rate, uint64_t *out_size) {
  size_t pcm_bytes = (((size_t)samples * channels) * sizeof(short));
  size_t total = (12 + pcm_bytes);
  uint8_t *blob = checked_malloc(total);
  store_u32_le(blob + 0, (uint32_t)sample_rate);
  store_u32_le(blob + 4, (uint32_t)channels);
  store_u32_le(blob + 8, (uint32_t)16);   // bits = +16 -> signed 16-bit integer PCM
  memcpy(blob + 12, pcm, pcm_bytes);
  *out_size = (uint64_t)total;
  return blob;
}

static int rpcm_clamp_s16(int v) {
  if (v < -32768) {
    return -32768;
  }
  if (v > 32767) {
    return 32767;
  }
  return v;
}

// Decode an RPCM blob to interleaved s16 PCM. Sets *channels/*sample_rate and *samples (per-channel
// sample count). Returns malloc'd PCM, or NULL on a malformed / unsupported blob.
static short *rpcm_decode_s16(const uint8_t *blob, uint64_t size, int *channels, int *sample_rate, int *samples) {
  if (size < 12) {
    return NULL;
  }
  int rate = (int)load_u32_le(blob + 0);
  int ch = (int)load_u32_le(blob + 4);
  int bits = (int)load_u32_le(blob + 8);
  if ((ch < 1) || (ch > 8)) {
    return NULL;
  }
  const uint8_t *data = blob + 12;
  size_t data_bytes = (size_t)(size - 12);
  int bytes_per_sample = ((bits < 0) ? -bits : bits) / 8;
  if ((bytes_per_sample < 1) || ((data_bytes % (size_t)bytes_per_sample) != 0)) {
    return NULL;
  }
  size_t total_values = (data_bytes / (size_t)bytes_per_sample);
  short *pcm = checked_malloc(total_values * sizeof(short));
  for (size_t i = 0; i < total_values; i++) {
    const uint8_t *s = data + (i * (size_t)bytes_per_sample);
    int value;
    if (bits == 16) {
      value = (int16_t)(((uint16_t)s[0]) | (((uint16_t)s[1]) << 8));
    } else {
      if (bits == 8) {
        value = ((int)s[0] - 128) << 8;   // unsigned 8-bit -> centred s16
      } else {
        if (bits == 32) {
          int32_t raw = (int32_t)load_u32_le(s);
          value = rpcm_clamp_s16(raw >> 16);   // s32 -> s16
        } else {
          if (bits == -32) {
            uint32_t bitsval = load_u32_le(s);
            float f;
            memcpy(&f, &bitsval, sizeof(float));
            value = rpcm_clamp_s16((int)lrintf(f * 32767.0f));
          } else {
            free(pcm);
            return NULL;   // unsupported depth
          }
        }
      }
    }
    pcm[i] = (short)value;
  }
  *channels = ch;
  *sample_rate = rate;
  *samples = (int)(total_values / (size_t)ch);
  return pcm;
}

// ---- QOA (little-endian reimplementation, tag "qoal") ----
// Faithful to the reference QOA codec (LMS order-4 predictor, 20-sample slices grouped into 5120-sample
// frames, 3-bit residuals, the scalefactor / (de)quant tables below) — only the byte serialisation is
// little-endian and the magic is "qoal". s16 in, s16 out.

#define QOA_SLICE_LEN 20
#define QOA_SLICES_PER_FRAME 256
#define QOA_FRAME_LEN (QOA_SLICES_PER_FRAME * QOA_SLICE_LEN)
#define QOA_LMS_LEN 4
#define QOA_MAX_CHANNELS 8

typedef struct {
  int history[QOA_LMS_LEN];
  int weights[QOA_LMS_LEN];
} QoaLms;

static const int qoa_quant_tab[17] = { 7, 7, 7, 5, 5, 3, 3, 1, 0, 0, 2, 2, 4, 4, 6, 6, 6 };
static const int qoa_reciprocal_tab[16] = { 65536, 9363, 3121, 1632, 1024, 705, 512, 391, 311, 253, 209, 175, 148, 126, 108, 93 };
static const int qoa_dequant_tab[16][8] = {
  {    1,    -1,    3,    -3,    5,    -5,     7,     -7 },
  {    5,    -5,   18,   -18,   32,   -32,    49,    -49 },
  {   16,   -16,   53,   -53,   95,   -95,   147,   -147 },
  {   34,   -34,  113,  -113,  203,  -203,   315,   -315 },
  {   63,   -63,  210,  -210,  378,  -378,   588,   -588 },
  {  104,  -104,  345,  -345,  621,  -621,   966,   -966 },
  {  158,  -158,  528,  -528,  950,  -950,  1477,  -1477 },
  {  228,  -228,  760,  -760, 1368, -1368,  2128,  -2128 },
  {  316,  -316, 1053, -1053, 1895, -1895,  2947,  -2947 },
  {  422,  -422, 1405, -1405, 2529, -2529,  3934,  -3934 },
  {  548,  -548, 1828, -1828, 3290, -3290,  5117,  -5117 },
  {  696,  -696, 2320, -2320, 4176, -4176,  6496,  -6496 },
  {  868,  -868, 2893, -2893, 5207, -5207,  8099,  -8099 },
  { 1064, -1064, 3548, -3548, 6386, -6386,  9933,  -9933 },
  { 1286, -1286, 4288, -4288, 7718, -7718, 12005, -12005 },
  { 1536, -1536, 5120, -5120, 9216, -9216, 14336, -14336 },
};

static int qoa_lms_predict(const QoaLms *lms) {
  int prediction = 0;
  for (int i = 0; i < QOA_LMS_LEN; i++) {
    prediction += (lms->weights[i] * lms->history[i]);
  }
  return (prediction >> 13);
}

static void qoa_lms_update(QoaLms *lms, int sample, int residual) {
  int delta = (residual >> 4);
  for (int i = 0; i < QOA_LMS_LEN; i++) {
    lms->weights[i] += ((lms->history[i] < 0) ? -delta : delta);
  }
  for (int i = 0; i < (QOA_LMS_LEN - 1); i++) {
    lms->history[i] = lms->history[i + 1];
  }
  lms->history[QOA_LMS_LEN - 1] = sample;
}

static int qoa_clamp(int v, int lo, int hi) {
  if (v < lo) {
    return lo;
  }
  if (v > hi) {
    return hi;
  }
  return v;
}

static int qoa_clamp_s16(int v) {
  if (v < -32768) {
    return -32768;
  }
  if (v > 32767) {
    return 32767;
  }
  return v;
}

static int qoa_div(int v, int scalefactor) {
  int reciprocal = qoa_reciprocal_tab[scalefactor];
  int n = (((v * reciprocal) + (1 << 15)) >> 16);
  n = ((n + (((v > 0) - (v < 0)))) - (((n > 0) - (n < 0))));   // round away from zero
  return n;
}

// Encode interleaved s16 PCM (`samples` per-channel sample frames) to a "qoal" blob. Returns malloc'd
// blob and its size.
static uint8_t *qoal_encode(const short *pcm, int samples, int channels, int sample_rate, uint64_t *out_size) {
  int num_frames = ((samples + (QOA_FRAME_LEN - 1)) / QOA_FRAME_LEN);
  size_t max_size = (8 + ((size_t)num_frames * (8 + ((size_t)16 * channels) + (((size_t)QOA_SLICES_PER_FRAME * channels) * 8))) + 64);
  uint8_t *blob = checked_malloc(max_size);
  size_t p = 0;
  blob[p++] = 'q';
  blob[p++] = 'o';
  blob[p++] = 'a';
  blob[p++] = 'l';
  store_u32_le(blob + p, (uint32_t)samples);   // total samples per channel
  p += 4;

  QoaLms lms[QOA_MAX_CHANNELS];
  int prev_scalefactor[QOA_MAX_CHANNELS];
  for (int c = 0; c < channels; c++) {
    lms[c].weights[0] = 0;
    lms[c].weights[1] = 0;
    lms[c].weights[2] = -(1 << 13);
    lms[c].weights[3] = (1 << 14);
    for (int i = 0; i < QOA_LMS_LEN; i++) {
      lms[c].history[i] = 0;
    }
    prev_scalefactor[c] = 0;
  }

  for (int frame_start = 0; frame_start < samples; frame_start += QOA_FRAME_LEN) {
    int frame_len = qoa_clamp(QOA_FRAME_LEN, 0, (samples - frame_start));
    int slices = ((frame_len + (QOA_SLICE_LEN - 1)) / QOA_SLICE_LEN);
    uint64_t frame_size = (8 + ((uint64_t)16 * channels) + (((uint64_t)slices * channels) * 8));
    store_u64_le(blob + p, (((uint64_t)channels << 56) | ((uint64_t)sample_rate << 32) | ((uint64_t)frame_len << 16) | frame_size));
    p += 8;
    for (int c = 0; c < channels; c++) {
      uint64_t history = 0, weights = 0;
      for (int i = 0; i < QOA_LMS_LEN; i++) {
        history = ((history << 16) | ((uint64_t)(lms[c].history[i] & 0xffff)));
        weights = ((weights << 16) | ((uint64_t)(lms[c].weights[i] & 0xffff)));
      }
      store_u64_le(blob + p, history);
      p += 8;
      store_u64_le(blob + p, weights);
      p += 8;
    }
    for (int c = 0; c < channels; c++) {
      for (int sample_index = 0; sample_index < frame_len; sample_index += QOA_SLICE_LEN) {
        int slice_len = qoa_clamp(QOA_SLICE_LEN, 0, (frame_len - sample_index));
        int slice_start = (((frame_start + sample_index) * channels) + c);
        int slice_end = (slice_start + (slice_len * channels));

        uint64_t best_error = (uint64_t)-1;
        uint64_t best_slice = 0;
        QoaLms best_lms = lms[c];
        int best_scalefactor = prev_scalefactor[c];
        for (int sfi = 0; sfi < 16; sfi++) {
          int scalefactor = ((sfi + prev_scalefactor[c]) % 16);
          QoaLms trial_lms = lms[c];
          uint64_t slice = (uint64_t)scalefactor;
          uint64_t current_error = 0;
          int ok = 1;
          for (int si = slice_start; si < slice_end; si += channels) {
            int sample = pcm[si];
            int predicted = qoa_lms_predict(&trial_lms);
            int residual = (sample - predicted);
            int scaled = qoa_div(residual, scalefactor);
            int clamped = qoa_clamp(scaled, -8, 8);
            int quantized = qoa_quant_tab[clamped + 8];
            int dequantized = qoa_dequant_tab[scalefactor][quantized];
            int reconstructed = qoa_clamp_s16(predicted + dequantized);
            int64_t error = (sample - reconstructed);
            current_error += (uint64_t)(error * error);
            if (current_error > best_error) {
              ok = 0;
              break;
            }
            qoa_lms_update(&trial_lms, reconstructed, dequantized);
            slice = ((slice << 3) | (uint64_t)quantized);
          }
          if (ok && (current_error < best_error)) {
            best_error = current_error;
            best_slice = slice;
            best_lms = trial_lms;
            best_scalefactor = scalefactor;
          }
        }
        lms[c] = best_lms;
        prev_scalefactor[c] = best_scalefactor;
        best_slice <<= (((QOA_SLICE_LEN - slice_len) * 3));   // pad a short trailing slice
        store_u64_le(blob + p, best_slice);
        p += 8;
      }
    }
  }
  *out_size = (uint64_t)p;
  return blob;
}

// Decode a "qoal" blob to interleaved s16 PCM. Sets *channels/*sample_rate and *samples (per-channel
// sample count). Returns malloc'd PCM, or NULL on a malformed blob.
static short *qoal_decode(const uint8_t *blob, uint64_t size, int *channels, int *sample_rate, int *samples) {
  if (size < 12) {
    return NULL;
  }
  if (((blob[0] != 'q') || (blob[1] != 'o')) || ((blob[2] != 'a') || (blob[3] != 'l'))) {
    return NULL;
  }
  int total_samples = (int)load_u32_le(blob + 4);
  size_t p = 8;

  int file_channels = 0, file_rate = 0;
  short *pcm = NULL;
  int written = 0;
  while ((p + 8) <= size) {
    uint64_t frame_header = load_u64_le(blob + p);
    p += 8;
    int frame_channels = (int)((frame_header >> 56) & 0xff);
    int frame_rate = (int)((frame_header >> 32) & 0xffffff);
    int frame_len = (int)((frame_header >> 16) & 0xffff);
    if ((frame_channels < 1) || (frame_channels > QOA_MAX_CHANNELS)) {
      free(pcm);
      return NULL;
    }
    if (file_channels == 0) {
      file_channels = frame_channels;
      file_rate = frame_rate;
      pcm = checked_malloc(((size_t)total_samples * file_channels) * sizeof(short));
    }
    int slices = ((frame_len + (QOA_SLICE_LEN - 1)) / QOA_SLICE_LEN);
    if ((p + (size_t)((16 * frame_channels) + ((slices * frame_channels) * 8))) > size) {
      free(pcm);
      return NULL;
    }
    QoaLms lms[QOA_MAX_CHANNELS];
    for (int c = 0; c < frame_channels; c++) {
      uint64_t history = load_u64_le(blob + p);
      p += 8;
      uint64_t weights = load_u64_le(blob + p);
      p += 8;
      for (int i = 0; i < QOA_LMS_LEN; i++) {
        lms[c].history[i] = (int)(int16_t)(history >> 48);
        history <<= 16;
        lms[c].weights[i] = (int)(int16_t)(weights >> 48);
        weights <<= 16;
      }
    }
    for (int c = 0; c < frame_channels; c++) {
      for (int sample_index = 0; sample_index < frame_len; sample_index += QOA_SLICE_LEN) {
        uint64_t slice = load_u64_le(blob + p);
        p += 8;
        int scalefactor = (int)((slice >> 60) & 0xf);
        int slice_len = qoa_clamp(QOA_SLICE_LEN, 0, (frame_len - sample_index));
        int base = ((written + sample_index) * frame_channels) + c;
        slice <<= 4;   // drop the 4 scalefactor bits; residuals are now in the top bits
        for (int s = 0; s < slice_len; s++) {
          int predicted = qoa_lms_predict(&lms[c]);
          int quantized = (int)((slice >> 61) & 0x7);
          int dequantized = qoa_dequant_tab[scalefactor][quantized];
          int reconstructed = qoa_clamp_s16(predicted + dequantized);
          pcm[base + (s * frame_channels)] = (short)reconstructed;
          slice <<= 3;
          qoa_lms_update(&lms[c], reconstructed, dequantized);
        }
      }
    }
    written += frame_len;
  }
  if (!pcm) {
    return NULL;
  }
  *channels = file_channels;
  *sample_rate = file_rate;
  *samples = written;
  return pcm;
}

// ------------------------------------------------------ CDF 9/7 wavelet (float, lossy)

#define MAX_LINE_LENGTH 8192   // longest DWT row/column the CPU path supports (>= 8K; was 2048 = 2K only)

/* The four lifting coefficients (alpha, beta, gamma, delta) and the scaling factor of the
 * irreversible Cohen-Daubechies-Feauveau 9/7 wavelet — the standard JPEG 2000 lossy transform. */
#define CDF97_ALPHA (-1.586134342f)
#define CDF97_BETA  (-0.052980118f)
#define CDF97_GAMMA ( 0.882911076f)
#define CDF97_DELTA ( 0.443506852f)
#define CDF97_SCALE ( 1.230174105f)

/* Reflect an index back into [0, length) with whole-sample symmetric extension at the borders.
 * Used so the lifting steps can read neighbours just past the line ends. */
static int mirror_index(int index, int length) {
  if (length == 1) {
    return 0;
  }
  int period = 2 * (length - 1);
  index %= period;
  if (index < 0) {
    index += period;
  }
  if (index >= length) {
    index = period - index;
  }
  return index;
}

static float sample_mirrored_float(const float *line, int index, int length) {
  return line[mirror_index(index, length)];
}

/* Forward 1D CDF 9/7: lifting in place on the interleaved samples, then deinterleave so the
 * low-pass (approximation) coefficients occupy the first half and the high-pass (detail)
 * coefficients the second half of the line. */
static void forward_cdf97(float *line, int length) {
  if (length < 2) {
    return;
  }
  float scratch[MAX_LINE_LENGTH];
  int k;
  for (k = 1; k < length; k += 2) {
    line[k] += CDF97_ALPHA * (sample_mirrored_float(line, k - 1, length) + sample_mirrored_float(line, k + 1, length));
  }
  for (k = 0; k < length; k += 2) {
    line[k] += CDF97_BETA * (sample_mirrored_float(line, k - 1, length) + sample_mirrored_float(line, k + 1, length));
  }
  for (k = 1; k < length; k += 2) {
    line[k] += CDF97_GAMMA * (sample_mirrored_float(line, k - 1, length) + sample_mirrored_float(line, k + 1, length));
  }
  for (k = 0; k < length; k += 2) {
    line[k] += CDF97_DELTA * (sample_mirrored_float(line, k - 1, length) + sample_mirrored_float(line, k + 1, length));
  }
  for (k = 0; k < length; k += 2) {
    line[k] *= (1.0f / CDF97_SCALE);
  }
  for (k = 1; k < length; k += 2) {
    line[k] *= CDF97_SCALE;
  }
  int low_count = (length + 1) / 2;
  for (k = 0; k < length; k++) {
    scratch[(k & 1) ? (low_count + (k >> 1)) : (k >> 1)] = line[k];
  }
  memcpy(line, scratch, (size_t)length * sizeof(float));
}

/* Inverse 1D CDF 9/7: interleave [low | high] back to even/odd, then undo the lifting in
 * reverse order. */
static void inverse_cdf97(float *line, int length) {
  if (length < 2) {
    return;
  }
  float scratch[MAX_LINE_LENGTH];
  int k;
  int low_count = (length + 1) / 2;
  for (k = 0; k < length; k++) {
    scratch[k] = line[(k & 1) ? (low_count + (k >> 1)) : (k >> 1)];
  }
  memcpy(line, scratch, (size_t)length * sizeof(float));
  for (k = 0; k < length; k += 2) {
    line[k] *= CDF97_SCALE;
  }
  for (k = 1; k < length; k += 2) {
    line[k] *= (1.0f / CDF97_SCALE);
  }
  for (k = 0; k < length; k += 2) {
    line[k] -= CDF97_DELTA * (sample_mirrored_float(line, k - 1, length) + sample_mirrored_float(line, k + 1, length));
  }
  for (k = 1; k < length; k += 2) {
    line[k] -= CDF97_GAMMA * (sample_mirrored_float(line, k - 1, length) + sample_mirrored_float(line, k + 1, length));
  }
  for (k = 0; k < length; k += 2) {
    line[k] -= CDF97_BETA * (sample_mirrored_float(line, k - 1, length) + sample_mirrored_float(line, k + 1, length));
  }
  for (k = 1; k < length; k += 2) {
    line[k] -= CDF97_ALPHA * (sample_mirrored_float(line, k - 1, length) + sample_mirrored_float(line, k + 1, length));
  }
}

/* Strided variants: gather a column (stride = image width) into a contiguous line, transform,
 * scatter back. Lets the same 1D routines do both the horizontal and the vertical pass. */
static void forward_cdf97_strided(float *base, int length, int stride) {
  float line[MAX_LINE_LENGTH];
  for (int i = 0; i < length; i++) {
    line[i] = base[(size_t)i * stride];
  }
  forward_cdf97(line, length);
  for (int i = 0; i < length; i++) {
    base[(size_t)i * stride] = line[i];
  }
}

static void inverse_cdf97_strided(float *base, int length, int stride) {
  float line[MAX_LINE_LENGTH];
  for (int i = 0; i < length; i++) {
    line[i] = base[(size_t)i * stride];
  }
  inverse_cdf97(line, length);
  for (int i = 0; i < length; i++) {
    base[(size_t)i * stride] = line[i];
  }
}

// Largest number of dyadic decomposition levels that still leaves at least a 2x2 low-pass band.
static int maximum_levels(int width, int height) {
  int levels = 0;
  int current_width = width;
  int current_height = height;
  while ((current_width >= 2 && current_height >= 2) && levels < 12) {
    current_width = (current_width + 1) / 2;
    current_height = (current_height + 1) / 2;
    levels++;
  }
  return levels;
}

/* Multi-level 2D forward 9/7: at each level transform every row then every column of the current
 * low-pass quadrant, then shrink to that quadrant for the next level. */
static void forward_dwt_2d(float *plane, int width, int height, int levels) {
  int current_width = width;
  int current_height = height;
  for (int level = 0; (level < levels && current_width >= 2) && current_height >= 2; level++) {
    for (int y = 0; y < current_height; y++) {
      forward_cdf97(plane + (size_t)y * width, current_width);
    }
    for (int x = 0; x < current_width; x++) {
      forward_cdf97_strided(plane + x, current_height, width);
    }
    current_width = (current_width + 1) / 2;
    current_height = (current_height + 1) / 2;
  }
}

// Multi-level 2D inverse 9/7: undo the levels from coarsest to finest (columns then rows).
static void inverse_dwt_2d(float *plane, int width, int height, int levels) {
  int level_width[16];
  int level_height[16];
  int level_count = 0;
  int current_width = width;
  int current_height = height;
  for (int level = 0; (level < levels && current_width >= 2) && current_height >= 2; level++) {
    level_width[level_count] = current_width;
    level_height[level_count] = current_height;
    level_count++;
    current_width = (current_width + 1) / 2;
    current_height = (current_height + 1) / 2;
  }
  for (int level = level_count - 1; level >= 0; level--) {
    current_width = level_width[level];
    current_height = level_height[level];
    for (int x = 0; x < current_width; x++) {
      inverse_cdf97_strided(plane + x, current_height, width);
    }
    for (int y = 0; y < current_height; y++) {
      inverse_cdf97(plane + (size_t)y * width, current_width);
    }
  }
}

// --------------------------------------- reversible 5/3 LeGall wavelet (integer, lossless)

static int sample_mirrored_int(const int32_t *line, int index, int length) {
  return line[mirror_index(index, length)];
}

/* Forward 1D 5/3: predict the detail (odd) samples from their even neighbours, update the
 * approximation (even) samples from the new detail, then deinterleave [low | high]. All integer,
 * arithmetic right shift = floor division, so it is exactly invertible. */
static void forward_legall53(int32_t *line, int length) {
  if (length < 2) {
    return;
  }
  int32_t scratch[MAX_LINE_LENGTH];
  int k;
  for (k = 1; k < length; k += 2) {
    line[k] -= (sample_mirrored_int(line, k - 1, length) + sample_mirrored_int(line, k + 1, length)) >> 1;
  }
  for (k = 0; k < length; k += 2) {
    line[k] += ((sample_mirrored_int(line, k - 1, length) + sample_mirrored_int(line, k + 1, length)) + 2) >> 2;
  }
  int low_count = (length + 1) / 2;
  for (k = 0; k < length; k++) {
    scratch[(k & 1) ? (low_count + (k >> 1)) : (k >> 1)] = line[k];
  }
  memcpy(line, scratch, (size_t)length * sizeof(int32_t));
}

// Inverse 1D 5/3: interleave [low | high] back, undo the update, then undo the predict.
static void inverse_legall53(int32_t *line, int length) {
  if (length < 2) {
    return;
  }
  int32_t scratch[MAX_LINE_LENGTH];
  int k;
  int low_count = (length + 1) / 2;
  for (k = 0; k < length; k++) {
    scratch[k] = line[(k & 1) ? (low_count + (k >> 1)) : (k >> 1)];
  }
  memcpy(line, scratch, (size_t)length * sizeof(int32_t));
  for (k = 0; k < length; k += 2) {
    line[k] -= ((sample_mirrored_int(line, k - 1, length) + sample_mirrored_int(line, k + 1, length)) + 2) >> 2;
  }
  for (k = 1; k < length; k += 2) {
    line[k] += (sample_mirrored_int(line, k - 1, length) + sample_mirrored_int(line, k + 1, length)) >> 1;
  }
}

static void forward_legall53_strided(int32_t *base, int length, int stride) {
  int32_t line[MAX_LINE_LENGTH];
  for (int i = 0; i < length; i++) {
    line[i] = base[(size_t)i * stride];
  }
  forward_legall53(line, length);
  for (int i = 0; i < length; i++) {
    base[(size_t)i * stride] = line[i];
  }
}

static void inverse_legall53_strided(int32_t *base, int length, int stride) {
  int32_t line[MAX_LINE_LENGTH];
  for (int i = 0; i < length; i++) {
    line[i] = base[(size_t)i * stride];
  }
  inverse_legall53(line, length);
  for (int i = 0; i < length; i++) {
    base[(size_t)i * stride] = line[i];
  }
}

static void forward_legall53_2d(int32_t *plane, int width, int height, int levels) {
  int current_width = width;
  int current_height = height;
  for (int level = 0; (level < levels && current_width >= 2) && current_height >= 2; level++) {
    for (int y = 0; y < current_height; y++) {
      forward_legall53(plane + (size_t)y * width, current_width);
    }
    for (int x = 0; x < current_width; x++) {
      forward_legall53_strided(plane + x, current_height, width);
    }
    current_width = (current_width + 1) / 2;
    current_height = (current_height + 1) / 2;
  }
}

static void inverse_legall53_2d(int32_t *plane, int width, int height, int levels) {
  int level_width[16];
  int level_height[16];
  int level_count = 0;
  int current_width = width;
  int current_height = height;
  for (int level = 0; (level < levels && current_width >= 2) && current_height >= 2; level++) {
    level_width[level_count] = current_width;
    level_height[level_count] = current_height;
    level_count++;
    current_width = (current_width + 1) / 2;
    current_height = (current_height + 1) / 2;
  }
  for (int level = level_count - 1; level >= 0; level--) {
    current_width = level_width[level];
    current_height = level_height[level];
    for (int x = 0; x < current_width; x++) {
      inverse_legall53_strided(plane + x, current_height, width);
    }
    for (int y = 0; y < current_height; y++) {
      inverse_legall53(plane + (size_t)y * width, current_width);
    }
  }
}

// ============================================ temporal (3D-DWT) transform — mode
/* The "3D DWT" mode (ported from the TAV codec). A group of pictures (GOP) is first transformed
 * along the TIME axis — a 1D wavelet across the frames, independently per pixel and plane — then
 * each resulting temporal-subband frame is spatially transformed and bit-plane coded exactly like
 * an intra frame. This is the OPEN-LOOP counterpart to the closed-loop P-frame prediction below:
 * no motion search, no reference, no drift; temporal redundancy is removed by the transform itself.
 *
 * Temporal wavelet g_temporal_wavelet: 0 = Haar, 1 = LeGall 5/3, 2 = CDF 9/7. The lossless path
 * (base_quality == 0) uses the integer-reversible Haar S-transform or 5/3 (a 9/7 request falls back
 * to 5/3, mirroring how the spatial path already forces integer 5/3 at Q0); the lossy path runs the
 * temporal transform in float. The frames are decomposed dyadically over g_temporal_levels levels,
 * deinterleaved [low | high] at each level exactly like the spatial 1D routines above, so the same
 * recurse-on-the-first-half structure applies along time. GOP lengths need not be powers of two:
 * the low half is ceil(n/2) and an odd tail sample passes through as a low-pass coefficient. */
static int g_temporal_levels = 2;     // dyadic temporal decomposition depth (TAV default 2)
static int g_temporal_wavelet = 0;    // 0 = Haar (default), 1 = 5/3, 2 = 9/7

// ---- single-level 1D temporal transforms (operate on line[0..len), deinterleave into [low|high]) ----

/* Reversible integer Haar (S-transform): high = a - b, low = b + floor((a-b)/2) = floor((a+b)/2).
 * Arithmetic right shift is floor division, so it inverts exactly — the lossless temporal filter. */
static void forward_haar_int(int32_t *line, int len) {
  if (len < 2) {
    return;
  }
  int32_t scratch[MAX_LINE_LENGTH];
  int low_count = (len + 1) / 2;
  for (int i = 0; i < low_count; i++) {
    int a = line[2 * i];
    if (((2 * i) + 1) < len) {
      int b = line[(2 * i) + 1];
      int high = a - b;
      scratch[i] = b + (high >> 1);
      scratch[low_count + i] = high;
    } else {
      scratch[i] = a;   // odd tail: no partner, passes through as a low-pass sample
    }
  }
  memcpy(line, scratch, (size_t)len * sizeof(int32_t));
}

static void inverse_haar_int(int32_t *line, int len) {
  if (len < 2) {
    return;
  }
  int32_t scratch[MAX_LINE_LENGTH];
  int low_count = (len + 1) / 2;
  for (int i = 0; i < low_count; i++) {
    if (((2 * i) + 1) < len) {
      int low = line[i];
      int high = line[low_count + i];
      int b = low - (high >> 1);
      scratch[2 * i] = high + b;
      scratch[(2 * i) + 1] = b;
    } else {
      scratch[2 * i] = line[i];
    }
  }
  memcpy(line, scratch, (size_t)len * sizeof(int32_t));
}

// Float Haar (orthonormal-free average/difference): low = (a+b)/2, high = (a-b)/2. Lossy temporal path.
static void forward_haar_float(float *line, int len) {
  if (len < 2) {
    return;
  }
  float scratch[MAX_LINE_LENGTH];
  int low_count = (len + 1) / 2;
  for (int i = 0; i < low_count; i++) {
    float a = line[2 * i];
    if (((2 * i) + 1) < len) {
      float b = line[(2 * i) + 1];
      scratch[i] = (a + b) * 0.5f;
      scratch[low_count + i] = (a - b) * 0.5f;
    } else {
      scratch[i] = a;
    }
  }
  memcpy(line, scratch, (size_t)len * sizeof(float));
}

static void inverse_haar_float(float *line, int len) {
  if (len < 2) {
    return;
  }
  float scratch[MAX_LINE_LENGTH];
  int low_count = (len + 1) / 2;
  for (int i = 0; i < low_count; i++) {
    if (((2 * i) + 1) < len) {
      float low = line[i];
      float high = line[low_count + i];
      scratch[2 * i] = low + high;
      scratch[(2 * i) + 1] = low - high;
    } else {
      scratch[2 * i] = line[i];
    }
  }
  memcpy(line, scratch, (size_t)len * sizeof(float));
}

/* Float CDF 5/3 (LeGall) lifting — the same predict/update steps as the integer forward_legall53,
 * but without the integer rounding, for the lossy temporal path. */
static void forward_legall53_float(float *line, int len) {
  if (len < 2) {
    return;
  }
  float scratch[MAX_LINE_LENGTH];
  for (int k = 1; k < len; k += 2) {
    line[k] -= 0.5f * (sample_mirrored_float(line, k - 1, len) + sample_mirrored_float(line, k + 1, len));
  }
  for (int k = 0; k < len; k += 2) {
    line[k] += 0.25f * (sample_mirrored_float(line, k - 1, len) + sample_mirrored_float(line, k + 1, len));
  }
  int low_count = (len + 1) / 2;
  for (int k = 0; k < len; k++) {
    scratch[(k & 1) ? (low_count + (k >> 1)) : (k >> 1)] = line[k];
  }
  memcpy(line, scratch, (size_t)len * sizeof(float));
}

static void inverse_legall53_float(float *line, int len) {
  if (len < 2) {
    return;
  }
  float scratch[MAX_LINE_LENGTH];
  int low_count = (len + 1) / 2;
  for (int k = 0; k < len; k++) {
    scratch[k] = line[(k & 1) ? (low_count + (k >> 1)) : (k >> 1)];
  }
  memcpy(line, scratch, (size_t)len * sizeof(float));
  for (int k = 0; k < len; k += 2) {
    line[k] -= 0.25f * (sample_mirrored_float(line, k - 1, len) + sample_mirrored_float(line, k + 1, len));
  }
  for (int k = 1; k < len; k += 2) {
    line[k] += 0.5f * (sample_mirrored_float(line, k - 1, len) + sample_mirrored_float(line, k + 1, len));
  }
}

// ---- multi-level dyadic temporal drivers (recurse on the [0, ceil(len/2)) low half each level) ----

static void temporal_forward_int(int32_t *line, int n, int levels, int wavelet) {
  int len = n;
  for (int l = 0; (l < levels) && (len >= 2); l++) {
    if (wavelet == 1) {
      forward_legall53(line, len);
    } else {
      forward_haar_int(line, len);
    }
    len = (len + 1) / 2;
  }
}

static void temporal_inverse_int(int32_t *line, int n, int levels, int wavelet) {
  int lengths[16];
  int count = 0;
  int len = n;
  for (int l = 0; (l < levels) && (len >= 2); l++) {
    lengths[count++] = len;
    len = (len + 1) / 2;
  }
  for (int l = count - 1; l >= 0; l--) {
    if (wavelet == 1) {
      inverse_legall53(line, lengths[l]);
    } else {
      inverse_haar_int(line, lengths[l]);
    }
  }
}

static void temporal_forward_float(float *line, int n, int levels, int wavelet) {
  int len = n;
  for (int l = 0; (l < levels) && (len >= 2); l++) {
    if (wavelet == 2) {
      forward_cdf97(line, len);
    } else if (wavelet == 1) {
      forward_legall53_float(line, len);
    } else {
      forward_haar_float(line, len);
    }
    len = (len + 1) / 2;
  }
}

static void temporal_inverse_float(float *line, int n, int levels, int wavelet) {
  int lengths[16];
  int count = 0;
  int len = n;
  for (int l = 0; (l < levels) && (len >= 2); l++) {
    lengths[count++] = len;
    len = (len + 1) / 2;
  }
  for (int l = count - 1; l >= 0; l--) {
    if (wavelet == 2) {
      inverse_cdf97(line, lengths[l]);
    } else if (wavelet == 1) {
      inverse_legall53_float(line, lengths[l]);
    } else {
      inverse_haar_float(line, lengths[l]);
    }
  }
}

/* The temporal subband a coefficient frame t belongs to: 0 = deepest temporal low-pass (the GOP
 * average — finest quant), higher = higher temporal frequency (coarser quant). Encoder and decoder
 * must agree, so both call this. It mirrors the deinterleaved multi-level layout: the deepest low
 * band is [0, len) after all the halvings; the high band introduced at split i occupies
 * [lengths[i+1], lengths[i]), with i = 0 the highest temporal frequency. */
static int temporal_quant_level(int t, int n, int levels) {
  int lengths[16];
  int count = 0;
  int len = n;
  for (int l = 0; (l < levels) && (len >= 2); l++) {
    lengths[count++] = len;
    len = (len + 1) / 2;
  }
  if (t < len) {
    return 0;
  }
  for (int i = 0; i < count; i++) {
    int high_begin = ((i + 1) < count) ? lengths[i + 1] : len;
    if ((t >= high_begin) && (t < lengths[i])) {
      return count - i;
    }
  }
  return count;
}

// Per-temporal-level quant multiplier (TAV: coarser quant for higher temporal frequencies).
static float temporal_quant_scale(int level) {
  const float BETA = 0.6f;
  const float KAPPA = 1.14f;
  return powf(2.0f, BETA * powf((float)level, KAPPA));
}

// ------------------------------------------------------ colour transform + quantization

static int clamp_byte(int value) {
  if (value < 0) {
    return 0;
  }
  if (value > 255) {
    return 255;
  }
  return value;
}

// HDR: the codec is a generic integer RGB transport. g_sample_bytes is the I/O sample
// width (1 = 8-bit SDR, the default; 2 = a 16-bit slot for >=10-bit HDR code values), and
// [g_sample_min, g_sample_max] the clamp range. The 16-bit slot is read/written as SIGNED int16 so the
// codec can also carry signed values (negatives); PQ/HLG use the non-negative [0,4095] sub-range. The
// colour space / transfer (sRGB, PQ, HLG) lives in the container metadata and is interpreted by the
// player, not here — exactly like the 8-bit path codes sRGB-gamma values as-is.
static int g_sample_bytes = 1;
static int g_sample_min = 0;
static int g_sample_max = 255;
static int g_sample_white = 256;   // code level of "reference white": quant Q scales by g_sample_white/256
                                   // (SDR 256, HDR 12-bit 4096; signed-16-bit test 1024)
static float g_chroma_quant = 1.0f;   // optional: coarsen the chroma (Co/Cg) quant step (>1 = fewer chroma bits);
                                      // 1.0 = off. Lossy only (Q0 has no quant -> stays 4:4:4-lossless).
static int g_plane_bytes = 0;         // debug: print per-plane (Y/Co/Cg) byte share (set by --plane-bytes)
static int g_quant_debug = 0;         // debug: print the measured 9/7 synthesis gains (set by --quant-debug)
// Chroma subsampling (Variante A: YCoCg-R kept; Co/Cg spatially down/upsampled at the I/O edges, lossy).
// 0 = 4:4:4 (default, full), 1 = 4:2:2 (chroma W/2 x H), 2 = 4:2:0 (chroma W/2 x H/2). Q0 stays 4:4:4.
static int g_chroma_format = 0;
static int chroma_shift_x(void) { return (g_chroma_format == 0) ? 0 : 1; }   // 4:2:2 and 4:2:0 halve horizontally
static int chroma_shift_y(void) { return (g_chroma_format == 2) ? 1 : 0; }   // only 4:2:0 halves vertically
static int plane_width(int plane, int frame_width) {
  int shift = (plane == 0) ? 0 : chroma_shift_x();
  return (frame_width + ((1 << shift) - 1)) >> shift;   // ceil(frame_width / 2^shift)
}
static int plane_height(int plane, int frame_height) {
  int shift = (plane == 0) ? 0 : chroma_shift_y();
  return (frame_height + ((1 << shift) - 1)) >> shift;
}

static int clamp_sample(int value) {
  if (value < g_sample_min) {
    return g_sample_min;
  }
  if (value > g_sample_max) {
    return g_sample_max;
  }
  return value;
}

// Select the sample I/O mode for the codec. 0 = SDR 8-bit; 1 = HDR 12-bit (0..4095, PQ or HLG); 2 =
// generic signed 16-bit (capability path; 1024 scale, carries negatives). Sets all four sample globals.
static void set_sample_mode(int mode) {
  if (mode == 1) {        // HDR 12-bit (PQ / HLG)
    g_sample_bytes = 2; g_sample_min = 0; g_sample_max = 4095; g_sample_white = 4096;
  } else if (mode == 2) { // generic signed 16-bit
    g_sample_bytes = 2; g_sample_min = -32768; g_sample_max = 32767; g_sample_white = 1024;
  } else {                // SDR 8-bit
    g_sample_bytes = 1; g_sample_min = 0; g_sample_max = 255; g_sample_white = 256;
  }
}

/* RGB -> YCoCg-R. This is a reversible (lossless) integer lifting transform: the inverse below
 * reconstructs the original RGB exactly for any 8-bit input. */
static void rgb_to_ycocg(const uint8_t *rgb, int32_t *luma, int32_t *chroma_orange, int32_t *chroma_green, int pixel_count) {
  const int16_t *rgb16 = (const int16_t *)rgb;
  for (int i = 0; i < pixel_count; i++) {
    int r = (g_sample_bytes == 2) ? rgb16[3 * i]             : rgb[3 * i];
    int g = (g_sample_bytes == 2) ? rgb16[(3 * i) + 1] : rgb[(3 * i) + 1];
    int b = (g_sample_bytes == 2) ? rgb16[(3 * i) + 2] : rgb[(3 * i) + 2];
    int co = r - b;
    int t = b + (co >> 1);
    int cg = g - t;
    int y = t + (cg >> 1);
    luma[i] = y;
    chroma_orange[i] = co;
    chroma_green[i] = cg;
  }
}

static void ycocg_to_rgb(const int32_t *luma, const int32_t *chroma_orange, const int32_t *chroma_green, uint8_t *rgb, int pixel_count) {
  int16_t *rgb16 = (int16_t *)rgb;
  for (int i = 0; i < pixel_count; i++) {
    int y = luma[i];
    int co = chroma_orange[i];
    int cg = chroma_green[i];
    int t = y - (cg >> 1);
    int g = cg + t;
    int b = t - (co >> 1);
    int r = b + co;
    if (g_sample_bytes == 2) {
      rgb16[3 * i] = (int16_t)clamp_sample(r);
      rgb16[(3 * i) + 1] = (int16_t)clamp_sample(g);
      rgb16[(3 * i) + 2] = (int16_t)clamp_sample(b);
    } else {
      rgb[3 * i] = clamp_byte(r);
      rgb[(3 * i) + 1] = clamp_byte(g);
      rgb[(3 * i) + 2] = clamp_byte(b);
    }
  }
}

// Box-average a full-resolution chroma plane down to its subsampled size (2x1 for 4:2:2, 2x2 for 4:2:0).
// Only used when g_chroma_format != 0 (4:4:4 leaves chroma full-res, untouched).
static void downsample_chroma(const int32_t *full, int32_t *small, int frame_width, int frame_height) {
  int sx = chroma_shift_x();
  int sy = chroma_shift_y();
  int small_width = plane_width(1, frame_width);
  int small_height = plane_height(1, frame_height);
  for (int yy = 0; yy < small_height; yy++) {
    for (int xx = 0; xx < small_width; xx++) {
      long sum = 0;
      int count = 0;
      for (int dy = 0; dy < (1 << sy); dy++) {
        for (int dx = 0; dx < (1 << sx); dx++) {
          int fx = (xx << sx) + dx;
          int fy = (yy << sy) + dy;
          if (fx >= frame_width) { fx = frame_width - 1; }
          if (fy >= frame_height) { fy = frame_height - 1; }
          sum += full[(fy * frame_width) + fx];
          count++;
        }
      }
      small[(yy * small_width) + xx] = (int32_t)((sum >= 0) ? ((sum + (count / 2)) / count) : -(((-sum) + (count / 2)) / count));
    }
  }
}

// Bilinear-upsample a subsampled chroma plane back to full resolution with CENTER siting: the chroma
// sample sits at the centre of its luma block, matching the box-average downsample, so there is no
// half-pixel chroma shift. Source position src = (out + 0.5)/2^shift - 0.5 (shift 0 -> identity). Lossy.
static void upsample_chroma(const int32_t *small, int32_t *full, int frame_width, int frame_height) {
  int small_width = plane_width(1, frame_width);
  int small_height = plane_height(1, frame_height);
  float scale_x = (float)(1 << chroma_shift_x());
  float scale_y = (float)(1 << chroma_shift_y());
  for (int y = 0; y < frame_height; y++) {
    float src_y = ((((float)y + 0.5f) / scale_y) - 0.5f);
    int y0 = (int)floorf(src_y);
    float fy = src_y - (float)y0;
    int sy0 = (y0 < 0) ? 0 : ((y0 > (small_height - 1)) ? (small_height - 1) : y0);
    int sy1 = ((y0 + 1) < 0) ? 0 : (((y0 + 1) > (small_height - 1)) ? (small_height - 1) : (y0 + 1));
    for (int x = 0; x < frame_width; x++) {
      float src_x = ((((float)x + 0.5f) / scale_x) - 0.5f);
      int x0 = (int)floorf(src_x);
      float fx = src_x - (float)x0;
      int sx0 = (x0 < 0) ? 0 : ((x0 > (small_width - 1)) ? (small_width - 1) : x0);
      int sx1 = ((x0 + 1) < 0) ? 0 : (((x0 + 1) > (small_width - 1)) ? (small_width - 1) : (x0 + 1));
      float top = ((1.0f - fx) * (float)small[(sy0 * small_width) + sx0]) + (fx * (float)small[(sy0 * small_width) + sx1]);
      float bottom = ((1.0f - fx) * (float)small[(sy1 * small_width) + sx0]) + (fx * (float)small[(sy1 * small_width) + sx1]);
      full[(y * frame_width) + x] = (int32_t)lrintf(((1.0f - fy) * top) + (fy * bottom));
    }
  }
}

// ---- HDR transfer functions ----
// SMPTE 2084 "PQ": maps a code value in [0,1] to/from linear light normalised so 1.0 = 10000 nits.
// REFERENCE_WHITE_NITS = 80 is the SDR reference white. The codec stores code values; these convert at
// the I/O edges (encoder ingest, player present) between the HDR source/display and those codes.
#define PQ_M1 0.1593017578125f
#define PQ_M2 78.84375f
#define PQ_C1 0.8359375f
#define PQ_C2 18.8515625f
#define PQ_C3 18.6875f
#define REFERENCE_WHITE_NITS 80.0f
#define PQ_PEAK_NITS 10000.0f
#define SIGNED_TEST_SCALE 1024   // generic signed-16-bit self-test scale (hdrtest only): 1.0 -> 1024

static float pq_encode(float linear_normalised) {   // linear [0,1] (1=10000 nits) -> PQ code [0,1]
  if (linear_normalised < 0.0f) {
    linear_normalised = 0.0f;
  }
  float lp = powf(linear_normalised, PQ_M1);
  return powf((PQ_C1 + (PQ_C2 * lp)) / (1.0f + (PQ_C3 * lp)), PQ_M2);
}

static float pq_decode(float code) {                 // PQ code [0,1] -> linear [0,1] (1=10000 nits)
  if (code < 0.0f) {
    code = 0.0f;
  }
  float vp = powf(code, 1.0f / PQ_M2);
  float numerator = vp - PQ_C1;
  if (numerator < 0.0f) {
    numerator = 0.0f;
  }
  float denominator = PQ_C2 - (PQ_C3 * vp);
  return powf(numerator / denominator, 1.0f / PQ_M1);
}

// Linear BT.2020 -> linear Rec.709 (the 3x3 the GLSL BT2020_TO_REC709 mat3 mirrors). The inverse
// (Rec.709 -> BT.2020) would be its matrix inverse; the current HDR paths only go 2020 -> 709.
static void bt2020_to_rec709(const float in[3], float out[3]) {
  out[0] = ((1.6605f * in[0]) - (0.5876f * in[1])) - (0.0728f * in[2]);
  out[1] = ((-0.1246f * in[0]) + (1.1329f * in[1])) - (0.0083f * in[2]);
  out[2] = ((-0.0182f * in[0]) - (0.1006f * in[1])) + (1.1187f * in[2]);
}

static float hlg_inverse_oetf(float v) {   // HLG signal [0,1] -> scene-linear [0,1]
  const float a = 0.17883277f, b = 0.28466892f, c = 0.55991073f;
  return (v <= 0.5f) ? ((v * v) / 3.0f) : ((expf((v - c) / a) + b) / 12.0f);
}

// HLG (BT.2020) signal [0,1] -> linear Rec.709 @ 10000 nits: inverse OETF -> scene-linear, the OOTF
// (system gamma 1.2, nominal 1000-nit, via BT.2020 luminance), BT.2020->709, and the 1000/10000 scale.
static void hlg_to_linear709(const float signal[3], float out[3]) {
  float scene[3] = { hlg_inverse_oetf(signal[0]), hlg_inverse_oetf(signal[1]), hlg_inverse_oetf(signal[2]) };
  float luminance = ((0.2627f * scene[0]) + (0.6780f * scene[1])) + (0.0593f * scene[2]);
  float gain = powf((luminance < 1e-6f) ? 1e-6f : luminance, 0.2f);
  float display[3] = { scene[0] * gain, scene[1] * gain, scene[2] * gain };
  bt2020_to_rec709(display, out);
  for (int c = 0; c < 3; c++) {
    out[c] *= (1000.0f / 10000.0f);
  }
}

static float srgb_oetf(float c) {   // linear -> sRGB gamma
  if (c <= 0.0f) {
    return 0.0f;
  }
  if (c >= 1.0f) {
    return 1.0f;
  }
  return (c <= 0.0031308f) ? (12.92f * c) : ((1.055f * powf(c, 1.0f / 2.4f)) - 0.055f);
}

// Tonemap a 12-bit BT.2020 HDR frame (transfer 16=PQ, 18=HLG) to displayable SDR sRGB 8-bit:
// PQ/HLG->linear, bt2020->709, per-channel Reinhard with an exposure lift, then sRGB gamma. The X11
// "seeing" path (no real HDR display); the wide-gamut/HDR range the FP16 output would carry is
// collapsed to SDR here. Mirrors the GPU color_hdr.comp, so the fwvplay VERIFY checks it exactly.
static void hdr_to_srgb8(const int16_t *code, uint8_t *out, int pixel_count, float exposure, int transfer) {
  for (int i = 0; i < pixel_count; i++) {
    float channel[3];
    if (transfer == 18) {   // HLG / BT.2020
      float signal[3] = { (float)code[3 * i] / 4095.0f, (float)code[(3 * i) + 1] / 4095.0f, (float)code[(3 * i) + 2] / 4095.0f };
      hlg_to_linear709(signal, channel);
    } else {               // PQ / BT.2020: PQ-decode then bt2020 -> 709
      float l[3];
      for (int c = 0; c < 3; c++) {
        l[c] = pq_decode((float)code[(3 * i) + c] / 4095.0f);
      }
      bt2020_to_rec709(l, channel);
    }
    for (int c = 0; c < 3; c++) {
      float v = channel[c] * exposure;
      if (v < 0.0f) {
        v = 0.0f;
      }
      v = v / (1.0f + v);                                    // Reinhard -> [0,1]
      out[(3 * i) + c] = (uint8_t)((srgb_oetf(v) * 255.0f) + 0.5f);
    }
  }
}

/* Per-subband quantization step (lossy path only). Psychovisual: the finest high-frequency
 * levels are quantized coarser; the coarse low-pass band finer. */
// Measure the CDF-9/7 synthesis L2 gain of every subband: drop a unit impulse into the subband, run
// the inverse DWT, take the L2 norm of the result (the synthesis basis function). Done on a small
// fixed grid — the gain is shift- and size-invariant away from the boundaries — and cached by level
// count. orientation 0=HL, 1=LH, 2=HH. The coarse subbands have a broad synthesis basis -> large
// gain; the finest HF a tiny one -> small gain. This is exactly what the quant step must divide by.
static void measure_synthesis_gains(int levels, float hf_gain[][3], float *ll_gain) {
  int grid = 1 << (levels + 3);
  if (grid < 64) { grid = 64; }
  if (grid > 512) { grid = 512; }
  float *plane = (float *)malloc(((size_t)grid * grid) * sizeof(float));
  for (int level = 0; level < levels; level++) {
    int quad_width = grid, quad_height = grid;
    for (int j = 0; j < level; j++) { quad_width = (quad_width + 1) / 2; quad_height = (quad_height + 1) / 2; }
    int half_width = (quad_width + 1) / 2, half_height = (quad_height + 1) / 2;
    int position_x[3] = { half_width + (quad_width - half_width) / 2, half_width / 2, half_width + (quad_width - half_width) / 2 };
    int position_y[3] = { half_height / 2, half_height + (quad_height - half_height) / 2, half_height + (quad_height - half_height) / 2 };
    for (int orientation = 0; orientation < 3; orientation++) {
      memset(plane, 0, ((size_t)grid * grid) * sizeof(float));
      plane[((size_t)position_y[orientation] * grid) + position_x[orientation]] = 1.0f;
      inverse_dwt_2d(plane, grid, grid, levels);
      double energy = 0.0;
      for (int i = 0; i < grid * grid; i++) { energy += (double)plane[i] * (double)plane[i]; }
      hf_gain[level][orientation] = (float)sqrt(energy);
    }
  }
  int ll_width = grid, ll_height = grid;
  for (int j = 0; j < levels; j++) { ll_width = (ll_width + 1) / 2; ll_height = (ll_height + 1) / 2; }
  memset(plane, 0, ((size_t)grid * grid) * sizeof(float));
  plane[((size_t)(ll_height / 2) * grid) + (ll_width / 2)] = 1.0f;
  inverse_dwt_2d(plane, grid, grid, levels);
  double energy = 0.0;
  for (int i = 0; i < grid * grid; i++) { energy += (double)plane[i] * (double)plane[i]; }
  *ll_gain = (float)sqrt(energy);
  free(plane);
}

// EXACT subband-gain + CSF weighted quantization. Each subband's quant step is
//   step = base_quality * COARSE_FACTOR * csf(level, orientation) / relative_gain(level, orientation)
// where relative_gain is the MEASURED 9/7 synthesis L2 norm of that subband normalised to the finest
// HF (which therefore anchors at base*COARSE_FACTOR, like 2g). This replaces 2g's geometric
// /LEVEL_RATIO guess with the implementation's actual subband norms, so the coarse subbands (large
// spatial support -> spread error) get exactly the protection their gain warrants. csf() is a visual
// weight: the eye tolerates coarser steps on the diagonal HH band and on the highest frequencies.
// COARSE_FACTOR, CSF_HH and CSF_FINE are the tunable knobs (set FWV_QUANT_DEBUG to print the gains).
static void build_quantization_steps(int *step, int width, int height, int levels, int base_quality) {
  const float COARSE_FACTOR = 2.0f;   // step of the finest-detail HF subband, in units of base_quality
  const float CSF_HH = 1.4f;          // diagonal (HH) band tolerates a coarser step (less visible)
  const float CSF_FINE = 1.25f;       // the finest level's highest frequencies tolerate a coarser step
  // Scale the quality to the reference-white level so a given Q means the same coarseness at any bit
  // depth: SDR -> x1, HDR 12-bit -> x16. (g_sample_white is set on both encoder and decoder.)
  base_quality = base_quality * (g_sample_white / 256);

  static int cached_levels = -1;
  static float hf_gain[16][3];
  static float ll_gain = 1.0f;
  if ((cached_levels != levels && levels >= 1) && levels <= 16) {
    measure_synthesis_gains(levels, hf_gain, &ll_gain);
    cached_levels = levels;
    if (g_quant_debug) {
      float reference = (hf_gain[0][0] > 0.0f) ? hf_gain[0][0] : 1.0f;
      fprintf(stderr, "[2h] subband synthesis gains (relative to finest HL):\n");
      for (int level = 0; level < levels; level++) {
        fprintf(stderr, "  L%d  HL=%.2f  LH=%.2f  HH=%.2f\n", level,
                hf_gain[level][0] / reference, hf_gain[level][1] / reference, hf_gain[level][2] / reference);
      }
      fprintf(stderr, "  LL=%.2f\n", ll_gain / reference);
    }
  }
  float gain_reference = hf_gain[0][0] > 0.0f ? hf_gain[0][0] : 1.0f;   // finest HF (HL) — the anchor

  for (int i = 0; i < width * height; i++) {
    step[i] = base_quality;
  }
  int current_width = width;
  int current_height = height;
  for (int level = 0; (level < levels && current_width >= 2) && current_height >= 2; level++) {
    int half_width = (current_width + 1) / 2;
    int half_height = (current_height + 1) / 2;
    int gain_level = (level < 16) ? level : 15;
    for (int y = 0; y < current_height; y++) {
      for (int x = 0; x < current_width; x++) {
        int in_right = (x >= half_width), in_bottom = (y >= half_height);
        if (!in_right && !in_bottom) {
          continue;   // the LL of this level -> set by the next level (or the final LL below)
        }
        int orientation = (in_right && !in_bottom) ? 0 : ((!in_right && in_bottom) ? 1 : 2);   // HL, LH, HH
        float csf = ((orientation == 2) ? CSF_HH : 1.0f) * ((level == 0) ? CSF_FINE : 1.0f);
        float relative_gain = hf_gain[gain_level][orientation] / gain_reference;
        if (relative_gain <= 0.0f) { relative_gain = 1.0f; }
        int q = (int)(((((float)base_quality * COARSE_FACTOR) * csf) / relative_gain) + 0.5f);
        if (q < 1) { q = 1; }
        step[((size_t)y * width) + x] = q;
      }
    }
    current_width = half_width;
    current_height = half_height;
  }
  float relative_ll = ll_gain / gain_reference;
  if (relative_ll <= 0.0f) { relative_ll = 1.0f; }
  int low_pass_q = (int)((((float)base_quality * COARSE_FACTOR) / relative_ll) + 0.5f);
  if (low_pass_q < 1) { low_pass_q = 1; }
  for (int y = 0; y < current_height; y++) {
    for (int x = 0; x < current_width; x++) {
      step[((size_t)y * width) + x] = low_pass_q;
    }
  }
}

// chroma_multiplier coarsens the step for the chroma planes (>1 = fewer chroma bits; the eye has lower
// chroma acuity). 1.0 for luma / SDR-default; the encoder and decoder must use the same value.
static void quantize(const float *source, int32_t *destination, const int *step, int count, float chroma_multiplier) {
  for (int i = 0; i < count; i++) {
    int q = (int)(((float)step[i] * chroma_multiplier) + 0.5f);
    if (q < 1) {
      q = 1;
    }
    float value = source[i] / (float)q;
    int magnitude = (int)fabsf(value);   // deadzone: floor, so |c| < q maps to 0 (the zero bin is 2x wide)
    destination[i] = (value < 0) ? -magnitude : magnitude;
  }
}

static void dequantize(const int32_t *source, float *destination, const int *step, int count, float chroma_multiplier) {
  for (int i = 0; i < count; i++) {
    int q = (int)(((float)step[i] * chroma_multiplier) + 0.5f);
    if (q < 1) {
      q = 1;
    }
    int index = source[i];   // deadzone reconstruction at the bin midpoint (index + 0.5) * q
    destination[i] = (index == 0) ? 0.0f : (((float)index + ((index > 0) ? 0.5f : -0.5f)) * (float)q);
  }
}

// ----------------------------------------------------------- raw bit-plane bit stream

typedef struct {
  uint8_t *bytes;
  size_t capacity;
  size_t length;
  uint32_t accumulator;
  int bits_in_accumulator;
} BitWriter;

static void bitwriter_init(BitWriter *writer) {
  writer->capacity = 1 << 16;
  writer->bytes = checked_malloc(writer->capacity);
  writer->length = 0;
  writer->accumulator = 0;
  writer->bits_in_accumulator = 0;
}

static void bitwriter_put_bit(BitWriter *writer, int bit) {
  writer->accumulator = (writer->accumulator << 1) | (bit & 1);
  if (++writer->bits_in_accumulator == 8) {
    if (writer->length == writer->capacity) {
      writer->capacity *= 2;
      writer->bytes = realloc(writer->bytes, writer->capacity);
      if (!writer->bytes) {
        die("realloc");
      }
    }
    writer->bytes[writer->length++] = (uint8_t)writer->accumulator;
    writer->accumulator = 0;
    writer->bits_in_accumulator = 0;
  }
}

static void bitwriter_put_bits(BitWriter *writer, uint32_t value, int bit_count) {
  for (int i = bit_count - 1; i >= 0; i--) {
    bitwriter_put_bit(writer, (value >> i) & 1);
  }
}

static void bitwriter_flush(BitWriter *writer) {
  while (writer->bits_in_accumulator) {
    bitwriter_put_bit(writer, 0);
  }
}

// Bulk MSB-first reader: a 64-bit window holds the next bits left-aligned (the next bit to read is bit 63),
// refilled a byte at a time up to 64 bits. get_bits extracts via a single shift, and Exp-Golomb counts its
// unary prefix with __builtin_clzll instead of bit-by-bit — at 4K the MV decode is ~1M bits/frame, so this
// is the whole-codec hot path. Bit-exact with the byte-wise reader it replaces (same MSB-first stream).
typedef struct {
  const uint8_t *bytes;
  size_t length;
  size_t position;
  uint64_t window;     // next bits, left-aligned (next bit at bit 63); zero-filled below window_bits
  int window_bits;     // number of valid bits currently in the window (0..64)
} BitReader;

static void bitreader_init(BitReader *reader, const uint8_t *bytes, size_t length) {
  reader->bytes = bytes;
  reader->length = length;
  reader->position = 0;
  reader->window = 0;
  reader->window_bits = 0;
}

static inline void bitreader_refill(BitReader *reader) {
  while ((reader->window_bits <= 56) && (reader->position < reader->length)) {
    reader->window |= (uint64_t)reader->bytes[reader->position++] << (56 - reader->window_bits);
    reader->window_bits += 8;
  }
}

static int bitreader_get_bit(BitReader *reader) {
  if (reader->window_bits == 0) {
    bitreader_refill(reader);
    if (reader->window_bits == 0) {
      return 0;   // past end of stream: read as zeros (matches the old reader)
    }
  }
  int bit = (int)(reader->window >> 63);
  reader->window <<= 1;
  reader->window_bits--;
  return bit;
}

static uint32_t bitreader_get_bits(BitReader *reader, int bit_count) {
  if (bit_count <= 0) {
    return 0;
  }
  if (reader->window_bits < bit_count) {
    bitreader_refill(reader);
  }
  uint32_t value = (uint32_t)(reader->window >> (64 - bit_count));   // top bit_count bits (zero-filled past end)
  if (reader->window_bits >= bit_count) {
    reader->window <<= bit_count;
    reader->window_bits -= bit_count;
  } else {
    reader->window = 0;
    reader->window_bits = 0;
  }
  return value;
}

// Signed Exp-Golomb (zigzag-map then unsigned Exp-Golomb): tiny codes for small magnitudes. Used for
// the motion-vector residuals.
static void bitwriter_put_signed_exp_golomb(BitWriter *writer, int value) {
  uint32_t mapped = ((uint32_t)value << 1) ^ (uint32_t)(value >> 31);   // zigzag (shift as unsigned: no UB on negatives)
  uint32_t m = mapped + 1;
  int bit_count = 0, t = (int)m;
  while (t > 1) {
    t >>= 1;
    bit_count++;
  }
  for (int i = 0; i < bit_count; i++) {
    bitwriter_put_bit(writer, 0);
  }
  for (int i = bit_count; i >= 0; i--) {
    bitwriter_put_bit(writer, (int)((m >> i) & 1u));
  }
}

static int bitreader_get_signed_exp_golomb(BitReader *reader) {
  bitreader_refill(reader);
  // The unary prefix is a run of 0s terminated by a 1; its length is the leading-zero count of the window.
  // A sentinel 1 just past the valid bits bounds clz so it never runs into the zero-fill (or past the end).
  uint64_t w = reader->window;
  if (reader->window_bits < 64) {
    w |= ((uint64_t)1 << (63 - reader->window_bits));
  }
  int bit_count = (w == 0) ? 31 : __builtin_clzll(w);
  if (bit_count > 31) {
    bit_count = 31;
  }
  int consume = bit_count + 1;   // the prefix zeros plus the terminating 1
  if (consume > reader->window_bits) {
    consume = reader->window_bits;
  }
  reader->window <<= consume;
  reader->window_bits -= consume;
  uint32_t m = ((uint32_t)1 << bit_count) | (bit_count > 0 ? bitreader_get_bits(reader, bit_count) : 0u);
  uint32_t mapped = m - 1;
  return (int)((mapped >> 1) ^ (~(mapped & 1) + 1));   // un-zigzag
}

// --------------------------------------------- motion: one [mv_x, mv_y] (half-pel) per MxM block
// Motion block is a runtime value (8 / 16 / 32), set from the encoder cmdline or the container header;
// it is an independent grid from the coding/bitplane BLOCK_SIZE. The OBMC overlap window is a fixed
// 4-pixel edge ramp, so the minimum motion block is 8 (below that the two ramps would overlap).
#define MAX_MOTION_BLOCK 32
static int g_motion_block = 16;   // default 16 (fast: 256-thread ME/mode_decide). --motion-block 32 = -10..-17%% bytes / +0.15 dB but ~+40%% encode time at 4K (1024-thread workgroups) — opt-in for quality/offline. 8 = finer/more MV bits.
static int g_merge_satd = 1;      // variable-motion (--motion-split) R-D merge residual metric: 1 = SATD (default, predicts coded bits better), 0 = SAD (--merge-metric sad; also skips the Hadamard pass → faster)
#define MOTION_BLOCK g_motion_block

static int median3(int a, int b, int c) {
  return (a < b) ? ((b < c) ? b : ((a < c) ? c : a)) : ((a < c) ? a : ((b < c) ? c : b));
}

// H.264-style median predictor: median of the left, up and up-right already-coded neighbour MVs.
static int predict_motion_component(const int *mv, int blocks_x, int bx, int by, int component) {
  int left = (bx > 0) ? mv[((by * blocks_x + (bx - 1)) * 2) + component] : 0;
  int up = (by > 0) ? mv[(((by - 1) * blocks_x + bx) * 2) + component] : 0;
  int up_right = (by > 0 && bx + 1 < blocks_x) ? mv[(((by - 1) * blocks_x + (bx + 1)) * 2) + component] : 0;
  return median3(left, up, up_right);
}

static void encode_motion_vectors(BitWriter *writer, const int *mv, int blocks_x, int blocks_y) {
  for (int by = 0; by < blocks_y; by++) {
    for (int bx = 0; bx < blocks_x; bx++) {
      for (int component = 0; component < 2; component++) {
        int prediction = predict_motion_component(mv, blocks_x, bx, by, component);
        bitwriter_put_signed_exp_golomb(writer, mv[((by * blocks_x + bx) * 2) + component] - prediction);
      }
    }
  }
}

static void decode_motion_vectors(BitReader *reader, int *mv, int blocks_x, int blocks_y) {
  for (int by = 0; by < blocks_y; by++) {
    for (int bx = 0; bx < blocks_x; bx++) {
      for (int component = 0; component < 2; component++) {
        int prediction = predict_motion_component(mv, blocks_x, bx, by, component);
        mv[((by * blocks_x + bx) * 2) + component] = prediction + bitreader_get_signed_exp_golomb(reader);
      }
    }
  }
}

// --------------------------------------------- variable motion size: a quadtree over the 32x32 root grid
// per-block variable motion: leaves at 32 / 16 / 8 px on a quadtree, but the FINE 8x8 MV field
// (fgx x fgy cells) is the single source of truth. The coder merges any node whose covered fine cells all
// share one MV into a single leaf (split=0), so the GPU encoder just writes the chosen leaf MV replicated
// across its cells and gets the optimal (lossless) quadtree for free; the decoder expands each leaf back
// to its fine cells. Downstream (mc/OBMC/blend) then runs unchanged on the fine 8-grid (g_motion_block=8).
#define MOTION_ROOT 32   // quadtree root block (px); leaves can be 32, 16 or 8
#define MOTION_LEAF 8    // finest leaf (px) = the fine MV-field cell

static int g_motion_variable = 0;   // 1 = variable quadtree motion (root 32 -> 8); 0 = the fixed g_motion_block grid
static int g_motion_split_bidi = 1; // 1 (DEFAULT) = the joint mode-aware blended-SAD B merge (per-leaf mode; faster than per-8 mode_decide AND better RD); 0 = --motion-split-fast single-ref 2-ME B
static int g_motion_lambda_abs = 256;   // variable-motion R-D: per-extra-leaf floor (SAD units); also the FIXED value when alpha==0
static int g_motion_lambda_alpha = 96;  // adaptive frame-level: lambda_abs = max(abs, (alpha*avg_32block_SAD)>>8); high-motion frames -> high lambda
                                        // -> the merge splits only on LOCALLY-strong motion (heterogeneous frames), not uniformly-high ones. 0 = fixed.

// Causal median predictor on the fine grid: left, up and up-LEFT are all guaranteed already-decoded under
// root-raster + child z-order (the uniform grid's up-RIGHT is NOT — it can be a not-yet-decoded sibling).
static int predict_fine_mv(const int *fine_mv, int fgx, int fx, int fy, int component) {
  int left    = (fx > 0)             ? fine_mv[(((fy * fgx) + (fx - 1)) * 2) + component] : 0;
  int up      = (fy > 0)             ? fine_mv[((((fy - 1) * fgx) + fx) * 2) + component] : 0;
  int up_left = ((fx > 0) && (fy > 0)) ? fine_mv[((((fy - 1) * fgx) + (fx - 1)) * 2) + component] : 0;
  return median3(left, up, up_left);
}

// Do all in-frame fine cells covered by the cells x cells node at (fx0,fy0) share the top-left cell's MV?
static int quadtree_node_uniform(const int *fine_mv, int fgx, int fgy, int fx0, int fy0, int cells) {
  int base = ((fy0 * fgx) + fx0) * 2;
  int mx = fine_mv[base], my = fine_mv[base + 1];
  for (int dy = 0; (dy < cells) && ((fy0 + dy) < fgy); dy++) {
    for (int dx = 0; (dx < cells) && ((fx0 + dx) < fgx); dx++) {
      int idx = (((fy0 + dy) * fgx) + (fx0 + dx)) * 2;
      if ((fine_mv[idx] != mx) || (fine_mv[idx + 1] != my)) {
        return 0;
      }
    }
  }
  return 1;
}

// (defined further down with the sparse-significance coder; forward-declared for the split-flag RLE here)
static void bitwriter_put_unsigned_exp_golomb(BitWriter *writer, uint32_t value);
static uint32_t bitreader_get_unsigned_exp_golomb(BitReader *reader);

// The split flags are coded as ONE run-length stream (not 1 raw bit per node inline): they are highly
// skewed (mostly 0 on coherent motion — every root a single 32-leaf), so RLE collapses an all-32 frame's
// ~2040 flag bits to a few bytes. Layout: [n_flags][run0_of_0s][run1_of_1s]... then all the leaf MVs.
static void write_flag_rle(BitWriter *writer, const uint8_t *flags, int n_flags) {
  bitwriter_put_unsigned_exp_golomb(writer, (uint32_t)n_flags);
  int i = 0, current = 0;   // the alternating runs start with a (possibly empty) run of 0s
  while (i < n_flags) {
    int run = 0;
    while ((i < n_flags) && (flags[i] == current)) {
      run++;
      i++;
    }
    bitwriter_put_unsigned_exp_golomb(writer, (uint32_t)run);
    current ^= 1;
  }
}

static int read_flag_rle(BitReader *reader, uint8_t *flags) {   // returns n_flags
  int n_flags = (int)bitreader_get_unsigned_exp_golomb(reader);
  int i = 0, current = 0;
  while (i < n_flags) {
    int run = (int)bitreader_get_unsigned_exp_golomb(reader);
    for (int k = 0; (k < run) && (i < n_flags); k++) {
      flags[i++] = (uint8_t)current;
    }
    current ^= 1;
  }
  return n_flags;
}

// Pass 1 (encode): walk the quadtree (merge-if-equal) collecting one split flag per non-8 node, in z-order.
static void collect_quadtree_flags(const int *fine_mv, int fgx, int fgy, int fx0, int fy0, int cells, uint8_t *flags, int *n_flags) {
  if (cells == 1) {
    return;   // 8-leaf: no flag
  }
  if (quadtree_node_uniform(fine_mv, fgx, fgy, fx0, fy0, cells)) {
    flags[(*n_flags)++] = 0;
  } else {
    flags[(*n_flags)++] = 1;
    int half = cells / 2;
    collect_quadtree_flags(fine_mv, fgx, fgy, fx0,        fy0,        half, flags, n_flags);
    collect_quadtree_flags(fine_mv, fgx, fgy, fx0 + half, fy0,        half, flags, n_flags);
    collect_quadtree_flags(fine_mv, fgx, fgy, fx0,        fy0 + half, half, flags, n_flags);
    collect_quadtree_flags(fine_mv, fgx, fgy, fx0 + half, fy0 + half, half, flags, n_flags);
  }
}

// Pass 2 (encode): re-walk (the same deterministic merge-if-equal) coding one MV delta per leaf.
static void encode_quadtree_mvs(BitWriter *writer, const int *fine_mv, int fgx, int fgy, int fx0, int fy0, int cells) {
  if ((cells == 1) || quadtree_node_uniform(fine_mv, fgx, fgy, fx0, fy0, cells)) {
    for (int component = 0; component < 2; component++) {
      int prediction = predict_fine_mv(fine_mv, fgx, fx0, fy0, component);
      bitwriter_put_signed_exp_golomb(writer, fine_mv[(((fy0 * fgx) + fx0) * 2) + component] - prediction);
    }
  } else {
    int half = cells / 2;
    encode_quadtree_mvs(writer, fine_mv, fgx, fgy, fx0,        fy0,        half);
    encode_quadtree_mvs(writer, fine_mv, fgx, fgy, fx0 + half, fy0,        half);
    encode_quadtree_mvs(writer, fine_mv, fgx, fgy, fx0,        fy0 + half, half);
    encode_quadtree_mvs(writer, fine_mv, fgx, fgy, fx0 + half, fy0 + half, half);
  }
}

// Decode: walk the quadtree driven by the pre-read flag array (same z-order), expanding each leaf MV.
static void decode_quadtree_mvs(BitReader *reader, int *fine_mv, int fgx, int fgy, int fx0, int fy0, int cells, const uint8_t *flags, int *flag_index) {
  int split = (cells != 1) ? flags[(*flag_index)++] : 0;
  if (!split) {
    int mv[2];
    for (int component = 0; component < 2; component++) {
      int prediction = predict_fine_mv(fine_mv, fgx, fx0, fy0, component);
      mv[component] = prediction + bitreader_get_signed_exp_golomb(reader);
    }
    for (int dy = 0; (dy < cells) && ((fy0 + dy) < fgy); dy++) {   // expand the leaf MV to all its fine cells
      for (int dx = 0; (dx < cells) && ((fx0 + dx) < fgx); dx++) {
        int idx = (((fy0 + dy) * fgx) + (fx0 + dx)) * 2;
        fine_mv[idx] = mv[0];
        fine_mv[idx + 1] = mv[1];
      }
    }
  } else {
    int half = cells / 2;
    decode_quadtree_mvs(reader, fine_mv, fgx, fgy, fx0,        fy0,        half, flags, flag_index);
    decode_quadtree_mvs(reader, fine_mv, fgx, fgy, fx0 + half, fy0,        half, flags, flag_index);
    decode_quadtree_mvs(reader, fine_mv, fgx, fgy, fx0,        fy0 + half, half, flags, flag_index);
    decode_quadtree_mvs(reader, fine_mv, fgx, fgy, fx0 + half, fy0 + half, half, flags, flag_index);
  }
}

// Max split flags = num_roots * 5 (a fully-split root emits 1 [32] + 4 [16] flags; 8-leaves emit none).
static int quadtree_flag_capacity(int fgx, int fgy) {
  int root_cells = MOTION_ROOT / MOTION_LEAF;
  int g32x = ((fgx + root_cells) - 1) / root_cells, g32y = ((fgy + root_cells) - 1) / root_cells;
  return ((g32x * g32y) * 5) + 16;
}

// Code / reconstruct the whole fine 8x8 MV field as a quadtree of 32x32 roots (raster order, z-order children).
static void encode_motion_quadtree(BitWriter *writer, const int *fine_mv, int fgx, int fgy) {
  int root_cells = MOTION_ROOT / MOTION_LEAF;   // 32 / 8 = 4 fine cells per root axis
  uint8_t *flags = checked_malloc((size_t)quadtree_flag_capacity(fgx, fgy));
  int n_flags = 0;
  for (int ry = 0; ry < fgy; ry += root_cells) {
    for (int rx = 0; rx < fgx; rx += root_cells) {
      collect_quadtree_flags(fine_mv, fgx, fgy, rx, ry, root_cells, flags, &n_flags);
    }
  }
  write_flag_rle(writer, flags, n_flags);
  for (int ry = 0; ry < fgy; ry += root_cells) {
    for (int rx = 0; rx < fgx; rx += root_cells) {
      encode_quadtree_mvs(writer, fine_mv, fgx, fgy, rx, ry, root_cells);
    }
  }
  free(flags);
}

static void decode_motion_quadtree(BitReader *reader, int *fine_mv, int fgx, int fgy) {
  int root_cells = MOTION_ROOT / MOTION_LEAF;
  uint8_t *flags = checked_malloc((size_t)quadtree_flag_capacity(fgx, fgy));
  read_flag_rle(reader, flags);
  int flag_index = 0;
  for (int ry = 0; ry < fgy; ry += root_cells) {
    for (int rx = 0; rx < fgx; rx += root_cells) {
      decode_quadtree_mvs(reader, fine_mv, fgx, fgy, rx, ry, root_cells, flags, &flag_index);
    }
  }
  free(flags);
}

// The per-block L0/L1/BI prediction-mode array (one mode 0/1/2 per fine 8-cell) is coded as its OWN quadtree, exactly
// like the MV field but with a 2-bit leaf value (no predictor): merge-if-equal collapses uniform-mode regions, so a
// mostly-one-mode frame costs a few bytes instead of one 2-bit code per 8-cell (the per-8 array was 16x the fixed grid).
static int quadtree_mode_uniform(const int *mode, int fgx, int fgy, int fx0, int fy0, int cells) {
  int m = mode[(fy0 * fgx) + fx0];
  for (int dy = 0; (dy < cells) && ((fy0 + dy) < fgy); dy++) {
    for (int dx = 0; (dx < cells) && ((fx0 + dx) < fgx); dx++) {
      if (mode[((fy0 + dy) * fgx) + (fx0 + dx)] != m) {
        return 0;
      }
    }
  }
  return 1;
}

static void collect_mode_flags(const int *mode, int fgx, int fgy, int fx0, int fy0, int cells, uint8_t *flags, int *n_flags) {
  if (cells == 1) {
    return;
  }
  if (quadtree_mode_uniform(mode, fgx, fgy, fx0, fy0, cells)) {
    flags[(*n_flags)++] = 0;
  } else {
    flags[(*n_flags)++] = 1;
    int half = cells / 2;
    collect_mode_flags(mode, fgx, fgy, fx0,        fy0,        half, flags, n_flags);
    collect_mode_flags(mode, fgx, fgy, fx0 + half, fy0,        half, flags, n_flags);
    collect_mode_flags(mode, fgx, fgy, fx0,        fy0 + half, half, flags, n_flags);
    collect_mode_flags(mode, fgx, fgy, fx0 + half, fy0 + half, half, flags, n_flags);
  }
}

static void encode_mode_leaves(BitWriter *writer, const int *mode, int fgx, int fgy, int fx0, int fy0, int cells) {
  if ((cells == 1) || quadtree_mode_uniform(mode, fgx, fgy, fx0, fy0, cells)) {
    bitwriter_put_bits(writer, (uint32_t)mode[(fy0 * fgx) + fx0], 2);
  } else {
    int half = cells / 2;
    encode_mode_leaves(writer, mode, fgx, fgy, fx0,        fy0,        half);
    encode_mode_leaves(writer, mode, fgx, fgy, fx0 + half, fy0,        half);
    encode_mode_leaves(writer, mode, fgx, fgy, fx0,        fy0 + half, half);
    encode_mode_leaves(writer, mode, fgx, fgy, fx0 + half, fy0 + half, half);
  }
}

static void decode_mode_leaves(BitReader *reader, int *mode, int fgx, int fgy, int fx0, int fy0, int cells, const uint8_t *flags, int *flag_index) {
  int split = (cells != 1) ? flags[(*flag_index)++] : 0;
  if (!split) {
    int m = (int)bitreader_get_bits(reader, 2);
    for (int dy = 0; (dy < cells) && ((fy0 + dy) < fgy); dy++) {
      for (int dx = 0; (dx < cells) && ((fx0 + dx) < fgx); dx++) {
        mode[((fy0 + dy) * fgx) + (fx0 + dx)] = m;
      }
    }
  } else {
    int half = cells / 2;
    decode_mode_leaves(reader, mode, fgx, fgy, fx0,        fy0,        half, flags, flag_index);
    decode_mode_leaves(reader, mode, fgx, fgy, fx0 + half, fy0,        half, flags, flag_index);
    decode_mode_leaves(reader, mode, fgx, fgy, fx0,        fy0 + half, half, flags, flag_index);
    decode_mode_leaves(reader, mode, fgx, fgy, fx0 + half, fy0 + half, half, flags, flag_index);
  }
}

static void encode_mode_quadtree(BitWriter *writer, const int *mode, int fgx, int fgy) {
  int root_cells = MOTION_ROOT / MOTION_LEAF;
  uint8_t *flags = checked_malloc((size_t)quadtree_flag_capacity(fgx, fgy));
  int n_flags = 0;
  for (int ry = 0; ry < fgy; ry += root_cells) {
    for (int rx = 0; rx < fgx; rx += root_cells) {
      collect_mode_flags(mode, fgx, fgy, rx, ry, root_cells, flags, &n_flags);
    }
  }
  write_flag_rle(writer, flags, n_flags);
  for (int ry = 0; ry < fgy; ry += root_cells) {
    for (int rx = 0; rx < fgx; rx += root_cells) {
      encode_mode_leaves(writer, mode, fgx, fgy, rx, ry, root_cells);
    }
  }
  free(flags);
}

static void decode_mode_quadtree(BitReader *reader, int *mode, int fgx, int fgy) {
  int root_cells = MOTION_ROOT / MOTION_LEAF;
  uint8_t *flags = checked_malloc((size_t)quadtree_flag_capacity(fgx, fgy));
  read_flag_rle(reader, flags);
  int flag_index = 0;
  for (int ry = 0; ry < fgy; ry += root_cells) {
    for (int rx = 0; rx < fgx; rx += root_cells) {
      decode_mode_leaves(reader, mode, fgx, fgy, rx, ry, root_cells, flags, &flag_index);
    }
  }
  free(flags);
}

// =============================================================== MV range codec (optional, --mv-codec range)
// An adaptive binary range coder (LZMA-style) as an alternative entropy backend for the per-frame MV blob, replacing the
// signed Exp-Golomb of the functions above. Residuals use a magnitude-class binarisation (truncated-unary class with
// adaptive context + bypass mantissa); the fixed-grid path conditions the class context on the left+up neighbour
// magnitudes (CABAC-like, ~-32% vs Exp-Golomb). Split flags and per-block modes are range-coded inline (one walk, no
// flag-RLE). ONE range stream per MV blob -> per-frame random access preserved. OPT-IN (default = Exp-Golomb); the
// container records the choice in ContainerHeader.mv_codec. CPU-only — the GPU pipeline is untouched.
static int g_mv_codec = 0;   // 0 = signed Exp-Golomb (default), 1 = adaptive binary range coder

#define MVRC_CAP 20    // truncated-unary magnitude-class cap
#define MVRC_NB  6     // neighbour-magnitude context buckets (fixed grid)

static int mvrc_bucket(int s) {
  return (s == 0) ? 0 : ((s <= 2) ? 1 : ((s <= 4) ? 2 : ((s <= 6) ? 3 : ((s <= 10) ? 4 : 5))));
}
static int mvrc_classof(uint32_t u) {
  return u ? (32 - __builtin_clz(u)) : 0;
}

// ---- encoder ----
typedef struct {
  uint8_t *out;
  size_t pos, cap;
  uint64_t code;
  uint32_t range, cache, ff;
  int first;
  uint16_t res[2][MVRC_NB][MVRC_CAP + 2];   // residual class bins: [component][neighbour bucket][unary position]
  uint16_t flag;                            // quadtree split flag
  uint16_t mode[2];                         // per-block mode (0/1/2) as two binary decisions
  int *cls;                                 // neighbour-class scratch (fixed grid), sized 2*blocks by the caller
} MVRangeEnc;

static void mvrc_enc_init(MVRangeEnc *e, uint8_t *out, size_t cap, int *cls) {
  e->out = out;
  e->pos = 0;
  e->cap = cap;
  e->code = 0;
  e->range = 0xffffffffu;
  e->cache = 0;
  e->ff = 0;
  e->first = 1;
  e->cls = cls;
  for (int c = 0; c < 2; c++) {
    for (int b = 0; b < MVRC_NB; b++) {
      for (int j = 0; j < (MVRC_CAP + 2); j++) {
        e->res[c][b][j] = 2048;
      }
    }
  }
  e->flag = 2048;
  e->mode[0] = 2048;
  e->mode[1] = 2048;
}
static void mvrc_enc_shift(MVRangeEnc *e) {
  int carry = ((e->code >> 32) != 0) ? 1 : 0;
  if ((e->code < (uint64_t)0xff000000) || carry) {
    if (e->first) {
      e->first = 0;
    } else if (e->pos < e->cap) {
      e->out[e->pos++] = (uint8_t)(e->cache + (uint32_t)carry);
    }
    while (e->ff != 0) {
      e->ff--;
      if (e->pos < e->cap) {
        e->out[e->pos++] = (uint8_t)(0xff + (uint32_t)carry);
      }
    }
    e->cache = (uint32_t)((e->code >> 24) & 0xff);
  } else {
    e->ff++;
  }
  e->code = (e->code << 8) & (uint64_t)0xffffffff;
}
static void mvrc_enc_bit(MVRangeEnc *e, uint16_t *p, int bit) {
  uint32_t bound = (e->range >> 12) * (*p);
  if (bit == 0) {
    e->range = bound;
    *p += (4096 - *p) >> 5;
  } else {
    e->code += bound;
    e->range -= bound;
    *p -= *p >> 5;
  }
  while (e->range < 0x1000000u) {
    e->range <<= 8;
    mvrc_enc_shift(e);
  }
}
static void mvrc_enc_bypass(MVRangeEnc *e, int bit) {
  uint32_t bound = e->range >> 1;
  if (bit == 0) {
    e->range = bound;
  } else {
    e->code += bound;
    e->range -= bound;
  }
  while (e->range < 0x1000000u) {
    e->range <<= 8;
    mvrc_enc_shift(e);
  }
}
static size_t mvrc_enc_flush(MVRangeEnc *e) {
  for (int i = 0; i < 5; i++) {
    mvrc_enc_shift(e);
  }
  return e->pos;
}
static void mvrc_enc_residual(MVRangeEnc *e, int component, int bucket, uint32_t u, int k) {
  uint16_t *ctx = e->res[component & 1][bucket];
  for (int j = 0; j < k; j++) {
    mvrc_enc_bit(e, &ctx[(j < MVRC_CAP) ? j : MVRC_CAP], 1);
  }
  mvrc_enc_bit(e, &ctx[(k < MVRC_CAP) ? k : MVRC_CAP], 0);
  for (int b = k - 2; b >= 0; b--) {
    mvrc_enc_bypass(e, (int)((u >> b) & 1));
  }
}
static void mvrc_enc_mode(MVRangeEnc *e, int m) {
  mvrc_enc_bit(e, &e->mode[0], (m != 0) ? 1 : 0);
  if (m != 0) {
    mvrc_enc_bit(e, &e->mode[1], (m == 2) ? 1 : 0);
  }
}

// ---- decoder (same model layout) ----
typedef struct {
  const uint8_t *in;
  size_t pos, len;
  uint32_t code, range;
  uint16_t res[2][MVRC_NB][MVRC_CAP + 2];
  uint16_t flag;
  uint16_t mode[2];
} MVRangeDec;

static void mvrc_dec_init(MVRangeDec *d, const uint8_t *in, size_t len) {
  d->in = in;
  d->len = len;
  d->pos = 0;
  d->range = 0xffffffffu;
  d->code = 0;
  for (int i = 0; i < 4; i++) {
    d->code = (d->code << 8) | ((d->pos < d->len) ? d->in[d->pos] : 0);
    d->pos++;
  }
  for (int c = 0; c < 2; c++) {
    for (int b = 0; b < MVRC_NB; b++) {
      for (int j = 0; j < (MVRC_CAP + 2); j++) {
        d->res[c][b][j] = 2048;
      }
    }
  }
  d->flag = 2048;
  d->mode[0] = 2048;
  d->mode[1] = 2048;
}
static int mvrc_dec_bit(MVRangeDec *d, uint16_t *p) {
  uint32_t bound = (d->range >> 12) * (*p);
  int bit;
  if (d->code < bound) {
    d->range = bound;
    *p += (4096 - *p) >> 5;
    bit = 0;
  } else {
    d->code -= bound;
    d->range -= bound;
    *p -= *p >> 5;
    bit = 1;
  }
  while (d->range < 0x1000000u) {
    d->code = (d->code << 8) | ((d->pos < d->len) ? d->in[d->pos] : 0);
    d->pos++;
    d->range <<= 8;
  }
  return bit;
}
static int mvrc_dec_bypass(MVRangeDec *d) {
  uint32_t bound = d->range >> 1;
  int bit;
  if (d->code < bound) {
    d->range = bound;
    bit = 0;
  } else {
    d->code -= bound;
    d->range -= bound;
    bit = 1;
  }
  while (d->range < 0x1000000u) {
    d->code = (d->code << 8) | ((d->pos < d->len) ? d->in[d->pos] : 0);
    d->pos++;
    d->range <<= 8;
  }
  return bit;
}
static int mvrc_dec_residual(MVRangeDec *d, int component, int bucket) {
  uint16_t *ctx = d->res[component & 1][bucket];
  int k = 0;
  while (mvrc_dec_bit(d, &ctx[(k < MVRC_CAP) ? k : MVRC_CAP]) == 1) {
    k++;
  }
  if (k == 0) {
    return 0;
  }
  uint32_t u = (uint32_t)1 << (k - 1);
  for (int b = k - 2; b >= 0; b--) {
    u |= (uint32_t)mvrc_dec_bypass(d) << b;
  }
  return (u & 1) ? -(int)((u + 1) >> 1) : (int)(u >> 1);
}
static int mvrc_dec_mode(MVRangeDec *d) {
  if (mvrc_dec_bit(d, &d->mode[0]) == 0) {
    return 0;
  }
  return mvrc_dec_bit(d, &d->mode[1]) ? 2 : 1;
}

// ---- field coders (mirror the Exp-Golomb walks above, but range-coded) ----
static void encode_motion_vectors_range(MVRangeEnc *e, const int *mv, int blocks_x, int blocks_y) {
  memset(e->cls, 0, (size_t)(blocks_x * blocks_y * 2) * sizeof(int));   // neighbour-class store, reset per field
  for (int by = 0; by < blocks_y; by++) {
    for (int bx = 0; bx < blocks_x; bx++) {
      for (int component = 0; component < 2; component++) {
        int prediction = predict_motion_component(mv, blocks_x, bx, by, component);
        int v = mv[((by * blocks_x + bx) * 2) + component] - prediction;
        int left = (bx > 0) ? e->cls[(((by * blocks_x) + (bx - 1)) * 2) + component] : 0;
        int up = (by > 0) ? e->cls[((((by - 1) * blocks_x) + bx) * 2) + component] : 0;
        uint32_t u = ((uint32_t)v << 1) ^ (uint32_t)(v >> 31);
        int k = mvrc_classof(u);
        mvrc_enc_residual(e, component, mvrc_bucket(left + up), u, k);
        e->cls[(((by * blocks_x) + bx) * 2) + component] = k;
      }
    }
  }
}
static void decode_motion_vectors_range(MVRangeDec *d, int *mv, int blocks_x, int blocks_y, int *cls) {
  memset(cls, 0, (size_t)(blocks_x * blocks_y * 2) * sizeof(int));
  for (int by = 0; by < blocks_y; by++) {
    for (int bx = 0; bx < blocks_x; bx++) {
      for (int component = 0; component < 2; component++) {
        int prediction = predict_motion_component(mv, blocks_x, bx, by, component);
        int left = (bx > 0) ? cls[(((by * blocks_x) + (bx - 1)) * 2) + component] : 0;
        int up = (by > 0) ? cls[((((by - 1) * blocks_x) + bx) * 2) + component] : 0;
        int v = mvrc_dec_residual(d, component, mvrc_bucket(left + up));
        mv[((by * blocks_x + bx) * 2) + component] = prediction + v;
        uint32_t u = ((uint32_t)v << 1) ^ (uint32_t)(v >> 31);
        cls[(((by * blocks_x) + bx) * 2) + component] = mvrc_classof(u);
      }
    }
  }
}
static void encode_quadtree_mvs_range(MVRangeEnc *e, const int *fine_mv, int fgx, int fgy, int fx0, int fy0, int cells) {
  int uniform = (cells == 1) || quadtree_node_uniform(fine_mv, fgx, fgy, fx0, fy0, cells);
  if (cells != 1) {
    mvrc_enc_bit(e, &e->flag, uniform ? 0 : 1);
  }
  if (uniform) {
    for (int component = 0; component < 2; component++) {
      int prediction = predict_fine_mv(fine_mv, fgx, fx0, fy0, component);
      int v = fine_mv[(((fy0 * fgx) + fx0) * 2) + component] - prediction;
      uint32_t u = ((uint32_t)v << 1) ^ (uint32_t)(v >> 31);
      mvrc_enc_residual(e, component, 0, u, mvrc_classof(u));   // z-order leaves: no spatial neighbour context (bucket 0)
    }
  } else {
    int half = cells / 2;
    encode_quadtree_mvs_range(e, fine_mv, fgx, fgy, fx0,        fy0,        half);
    encode_quadtree_mvs_range(e, fine_mv, fgx, fgy, fx0 + half, fy0,        half);
    encode_quadtree_mvs_range(e, fine_mv, fgx, fgy, fx0,        fy0 + half, half);
    encode_quadtree_mvs_range(e, fine_mv, fgx, fgy, fx0 + half, fy0 + half, half);
  }
}
static void decode_quadtree_mvs_range(MVRangeDec *d, int *fine_mv, int fgx, int fgy, int fx0, int fy0, int cells) {
  int split = (cells != 1) ? mvrc_dec_bit(d, &d->flag) : 0;
  if (!split) {
    int mv[2];
    for (int component = 0; component < 2; component++) {
      int prediction = predict_fine_mv(fine_mv, fgx, fx0, fy0, component);
      mv[component] = prediction + mvrc_dec_residual(d, component, 0);
    }
    for (int dy = 0; (dy < cells) && ((fy0 + dy) < fgy); dy++) {
      for (int dx = 0; (dx < cells) && ((fx0 + dx) < fgx); dx++) {
        int idx = (((fy0 + dy) * fgx) + (fx0 + dx)) * 2;
        fine_mv[idx] = mv[0];
        fine_mv[idx + 1] = mv[1];
      }
    }
  } else {
    int half = cells / 2;
    decode_quadtree_mvs_range(d, fine_mv, fgx, fgy, fx0,        fy0,        half);
    decode_quadtree_mvs_range(d, fine_mv, fgx, fgy, fx0 + half, fy0,        half);
    decode_quadtree_mvs_range(d, fine_mv, fgx, fgy, fx0,        fy0 + half, half);
    decode_quadtree_mvs_range(d, fine_mv, fgx, fgy, fx0 + half, fy0 + half, half);
  }
}
static void encode_mode_leaves_range(MVRangeEnc *e, const int *mode, int fgx, int fgy, int fx0, int fy0, int cells) {
  int uniform = (cells == 1) || quadtree_mode_uniform(mode, fgx, fgy, fx0, fy0, cells);
  if (cells != 1) {
    mvrc_enc_bit(e, &e->flag, uniform ? 0 : 1);
  }
  if (uniform) {
    mvrc_enc_mode(e, mode[(fy0 * fgx) + fx0]);
  } else {
    int half = cells / 2;
    encode_mode_leaves_range(e, mode, fgx, fgy, fx0,        fy0,        half);
    encode_mode_leaves_range(e, mode, fgx, fgy, fx0 + half, fy0,        half);
    encode_mode_leaves_range(e, mode, fgx, fgy, fx0,        fy0 + half, half);
    encode_mode_leaves_range(e, mode, fgx, fgy, fx0 + half, fy0 + half, half);
  }
}
static void decode_mode_leaves_range(MVRangeDec *d, int *mode, int fgx, int fgy, int fx0, int fy0, int cells) {
  int split = (cells != 1) ? mvrc_dec_bit(d, &d->flag) : 0;
  if (!split) {
    int m = mvrc_dec_mode(d);
    for (int dy = 0; (dy < cells) && ((fy0 + dy) < fgy); dy++) {
      for (int dx = 0; (dx < cells) && ((fx0 + dx) < fgx); dx++) {
        mode[((fy0 + dy) * fgx) + (fx0 + dx)] = m;
      }
    }
  } else {
    int half = cells / 2;
    decode_mode_leaves_range(d, mode, fgx, fgy, fx0,        fy0,        half);
    decode_mode_leaves_range(d, mode, fgx, fgy, fx0 + half, fy0,        half);
    decode_mode_leaves_range(d, mode, fgx, fgy, fx0,        fy0 + half, half);
    decode_mode_leaves_range(d, mode, fgx, fgy, fx0 + half, fy0 + half, half);
  }
}

// ---- blob level: ONE range stream covering the same fields the Exp-Golomb path packs into the BitWriter ----
// (optional per-block mode, then mv0, then optional mv1; each MV field fixed-grid or quadtree per `variable`).
static size_t mv_blob_encode_range(uint8_t **out, int has_mode, const int *mode_map, int mode_variable,
                                   const int *mv0, int has_mv1, const int *mv1, int variable, int bx, int by) {
  size_t cap = ((size_t)(bx * by) * 48) + 65536;   // range output is always < the Exp-Golomb size; generous + bounds-checked
  uint8_t *buf = checked_malloc(cap);
  int *cls = checked_malloc((size_t)(bx * by * 2) * sizeof(int));
  MVRangeEnc e;
  mvrc_enc_init(&e, buf, cap, cls);
  if (has_mode) {
    if (mode_variable) {
      int root_cells = MOTION_ROOT / MOTION_LEAF;
      for (int ry = 0; ry < by; ry += root_cells) {
        for (int rx = 0; rx < bx; rx += root_cells) {
          encode_mode_leaves_range(&e, mode_map, bx, by, rx, ry, root_cells);
        }
      }
    } else {
      for (int i = 0; i < (bx * by); i++) {
        mvrc_enc_mode(&e, mode_map[i]);
      }
    }
  }
  if (variable) {
    int root_cells = MOTION_ROOT / MOTION_LEAF;
    for (int ry = 0; ry < by; ry += root_cells) {
      for (int rx = 0; rx < bx; rx += root_cells) {
        encode_quadtree_mvs_range(&e, mv0, bx, by, rx, ry, root_cells);
      }
    }
  } else {
    encode_motion_vectors_range(&e, mv0, bx, by);
  }
  if (has_mv1) {
    if (variable) {
      int root_cells = MOTION_ROOT / MOTION_LEAF;
      for (int ry = 0; ry < by; ry += root_cells) {
        for (int rx = 0; rx < bx; rx += root_cells) {
          encode_quadtree_mvs_range(&e, mv1, bx, by, rx, ry, root_cells);
        }
      }
    } else {
      encode_motion_vectors_range(&e, mv1, bx, by);
    }
  }
  size_t length = mvrc_enc_flush(&e);
  free(cls);
  *out = buf;
  return length;
}
static void mv_blob_decode_range(const uint8_t *in, size_t len, int has_mode, int *mode_map, int mode_variable,
                                 int *mv0, int has_mv1, int *mv1, int variable, int bx, int by) {
  int *cls = checked_malloc((size_t)(bx * by * 2) * sizeof(int));
  MVRangeDec d;
  mvrc_dec_init(&d, in, len);
  if (has_mode) {
    if (mode_variable) {
      int root_cells = MOTION_ROOT / MOTION_LEAF;
      for (int ry = 0; ry < by; ry += root_cells) {
        for (int rx = 0; rx < bx; rx += root_cells) {
          decode_mode_leaves_range(&d, mode_map, bx, by, rx, ry, root_cells);
        }
      }
    } else {
      for (int i = 0; i < (bx * by); i++) {
        mode_map[i] = mvrc_dec_mode(&d);
      }
    }
  }
  if (variable) {
    int root_cells = MOTION_ROOT / MOTION_LEAF;
    for (int ry = 0; ry < by; ry += root_cells) {
      for (int rx = 0; rx < bx; rx += root_cells) {
        decode_quadtree_mvs_range(&d, mv0, bx, by, rx, ry, root_cells);
      }
    }
  } else {
    decode_motion_vectors_range(&d, mv0, bx, by, cls);
  }
  if (has_mv1) {
    if (variable) {
      int root_cells = MOTION_ROOT / MOTION_LEAF;
      for (int ry = 0; ry < by; ry += root_cells) {
        for (int rx = 0; rx < bx; rx += root_cells) {
          decode_quadtree_mvs_range(&d, mv1, bx, by, rx, ry, root_cells);
        }
      }
    } else {
      decode_motion_vectors_range(&d, mv1, bx, by, cls);
    }
  }
  free(cls);
}

static int clamp_pixel(int value, int low, int high) {
  return (value < low) ? low : ((value > high) ? high : value);
}

// Bilinear half-pel sample of previous[]. Deterministic integer rounding -> matches mc.comp exactly.
static int sample_half_pel(const int32_t *previous, int width, int height, int base_x, int base_y, int half_x, int half_y) {
  int x0 = clamp_pixel(base_x, 0, width - 1), y0 = clamp_pixel(base_y, 0, height - 1);
  if (half_x == 0 && half_y == 0) {
    return previous[(y0 * width) + x0];
  }
  int x1 = clamp_pixel(base_x + 1, 0, width - 1), y1 = clamp_pixel(base_y + 1, 0, height - 1);
  if (half_x == 1 && half_y == 0) {
    return ((previous[(y0 * width) + x0] + previous[(y0 * width) + x1]) + 1) >> 1;
  }
  if (half_x == 0 && half_y == 1) {
    return ((previous[(y0 * width) + x0] + previous[(y1 * width) + x0]) + 1) >> 1;
  }
  return ((((previous[(y0 * width) + x0] + previous[(y0 * width) + x1]) +
           previous[(y1 * width) + x0]) + previous[(y1 * width) + x1]) + 2) >> 2;
}

static int sample_block_mv(const int32_t *previous, const int *mv, int width, int height, int block, int x, int y) {
  int mv_x = mv[block * 2], mv_y = mv[(block * 2) + 1];
  return sample_half_pel(previous, width, height, x + (mv_x >> 1), y + (mv_y >> 1), mv_x & 1, mv_y & 1);
}

// OBMC edge window over an m-pixel block axis: 2, 1 near each edge, 0 in the middle (m=16 -> ..,1,2 at
// p=12..15, identical to the old fixed window). For m=8 the two 4-px ramps meet (no zero middle).
static int edge_weight(int p, int m) {
  return (p < 2) ? 2 : ((p < 4) ? 1 : ((p >= (m - 2)) ? 2 : ((p >= (m - 4)) ? 1 : 0)));
}

// mc_previous = the half-pel OBMC motion-compensated previous plane. EXACT mirror of mc.comp: each
// pixel blends its own block's MV prediction with the nearest vertical + horizontal neighbour blocks.
static void motion_compensate(const int32_t *previous, const int *mv, int32_t *mc_previous, int width, int height, int blocks_x) {
  int m = MOTION_BLOCK, half = m >> 1;
  int blocks_y = ((height + m) - 1) / m;
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int bx = x / m, by = y / m, px = x % m, py = y % m;
      int own_block = (by * blocks_x) + bx;
      int vertical_block = (clamp_pixel((py < half) ? (by - 1) : (by + 1), 0, blocks_y - 1) * blocks_x) + bx;
      int horizontal_block = (by * blocks_x) + clamp_pixel((px < half) ? (bx - 1) : (bx + 1), 0, blocks_x - 1);
      int vertical_weight = edge_weight(py, m), horizontal_weight = edge_weight(px, m);
      int own_weight = (8 - vertical_weight) - horizontal_weight;
      int prediction = sample_block_mv(previous, mv, width, height, own_block, x, y) * own_weight;
      if (vertical_weight > 0) {
        prediction += sample_block_mv(previous, mv, width, height, vertical_block, x, y) * vertical_weight;
      }
      if (horizontal_weight > 0) {
        prediction += sample_block_mv(previous, mv, width, height, horizontal_block, x, y) * horizontal_weight;
      }
      mc_previous[(y * width) + x] = (prediction + 4) >> 3;
    }
  }
}

// ============================================ MCTF (motion-compensated temporal filtering) — // Predict-only MC-Haar at the FRAME level for the 3D-DWT mode: the temporal low band keeps the even frame, the
// high band is the motion-compensated residual H = odd - OBMC(even). Lifting is invertible from the FORWARD motion
// alone (odd = H + OBMC(even) at decode), so no inverse warp / occlusion handling is needed. Motion is estimated on
// luma and shared by all three planes (4:4:4 only). Each high-pass frame carries its own MV field. This replaces the
// open-loop per-pixel-column temporal transform (which has no motion → large temporal high-pass on any movement).
static int g_mctf = 0;   // --mctf: motion-compensated temporal filtering in the 3D-DWT mode (predict-only MC-Haar)

// CPU luma block-matching motion search (4-step logarithmic, integer-pel). current vs reference on the MOTION_BLOCK
// grid; writes each block's MV in HALF-PEL units (×2) so motion_compensate consumes it directly.
static void motion_estimate_cpu(const int32_t *current, const int32_t *reference, int *mv,
                                int width, int height, int blocks_x, int blocks_y) {
  static const int neighbour_dx[8] = { -1, 1, 0, 0, -1, -1, 1, 1 };
  static const int neighbour_dy[8] = { 0, 0, -1, 1, -1, 1, -1, 1 };
  int m = MOTION_BLOCK;
  for (int by = 0; by < blocks_y; by++) {
    for (int bx = 0; bx < blocks_x; bx++) {
      int origin_x = bx * m, origin_y = by * m;
      int best_x = 0, best_y = 0;
      long best_cost = 0;
      for (int y = 0; (y < m) && ((origin_y + y) < height); y++) {       // seed: cost at mv=(0,0)
        for (int x = 0; (x < m) && ((origin_x + x) < width); x++) {
          int index = ((origin_y + y) * width) + (origin_x + x);
          int d = current[index] - reference[index];
          best_cost += (d < 0) ? -d : d;
        }
      }
      for (int step = 8; step >= 1; step >>= 1) {
        int improved = 1;
        while (improved) {
          improved = 0;
          int centre_x = best_x, centre_y = best_y;
          for (int n = 0; n < 8; n++) {
            int dx = centre_x + (neighbour_dx[n] * step), dy = centre_y + (neighbour_dy[n] * step);
            if (((dx < -60) || (dx > 60)) || ((dy < -60) || (dy > 60))) {
              continue;
            }
            long sad = 0;
            for (int y = 0; (y < m) && ((origin_y + y) < height); y++) {
              int ry = clamp_pixel(origin_y + y + dy, 0, height - 1);
              for (int x = 0; (x < m) && ((origin_x + x) < width); x++) {
                int rx = clamp_pixel(origin_x + x + dx, 0, width - 1);
                int d = current[((origin_y + y) * width) + (origin_x + x)] - reference[(ry * width) + rx];
                sad += (d < 0) ? -d : d;
              }
            }
            sad += (long)(((dx < 0) ? -dx : dx) + ((dy < 0) ? -dy : dy)) * 2;   // small rate bias toward (0,0)
            if (sad < best_cost) {
              best_cost = sad;
              best_x = dx;
              best_y = dy;
              improved = 1;
            }
          }
        }
      }
      // Half-pel refinement around the integer best (the OBMC warp samples half-pel, so it pays off).
      int best_hx = best_x * 2, best_hy = best_y * 2;
      long half_best = 0x7fffffffffffffffL;
      for (int refine_y = -1; refine_y <= 1; refine_y++) {
        for (int refine_x = -1; refine_x <= 1; refine_x++) {
          int hx = (best_x * 2) + refine_x, hy = (best_y * 2) + refine_y;
          long sad = 0;
          for (int y = 0; (y < m) && ((origin_y + y) < height); y++) {
            for (int x = 0; (x < m) && ((origin_x + x) < width); x++) {
              int pred = sample_half_pel(reference, width, height,
                                         (origin_x + x) + (hx >> 1), (origin_y + y) + (hy >> 1), hx & 1, hy & 1);
              int d = current[((origin_y + y) * width) + (origin_x + x)] - pred;
              sad += (d < 0) ? -d : d;
            }
          }
          sad += (long)(((hx < 0) ? -hx : hx) + ((hy < 0) ? -hy : hy));   // small rate bias (half-pel units)
          if (sad < half_best) {
            half_best = sad;
            best_hx = hx;
            best_hy = hy;
          }
        }
      }
      mv[((by * blocks_x) + bx) * 2] = best_hx;          // half-pel units
      mv[(((by * blocks_x) + bx) * 2) + 1] = best_hy;
    }
  }
}

/* Predict-only MC-Haar temporal FORWARD over a GOP, integer, all three planes, sharing the luma motion. Handles
 * chroma subsampling (4:2:2 / 4:2:0): motion is estimated on luma; each plane is warped at ITS OWN size with the
 * luma MV field on the plane's own MOTION_BLOCK grid (plane_motion_blocks_x) — exactly like the colordiff P/B path
 * (an approximation, but closed-loop-consistent enc↔dec so the lifting still inverts exactly). gop[plane] is
 * [frame * plane_pixels + pixel]; the result is the same deinterleaved [low | high] per-level layout as the per-pixel
 * temporal transform. frame_mv receives the luma MV field of each high-pass frame (indexed by deinterleaved position). */
static void mctf_forward(int32_t *gop[3], int num_frames, const int plane_w[3], const int plane_h[3], const int plane_pixels[3],
                         int levels_temporal, int *frame_mv, int luma_blocks_x, int luma_blocks_y) {
  int blocks = luma_blocks_x * luma_blocks_y;
  int plane_mbx[3];
  for (int plane = 0; plane < 3; plane++) {
    plane_mbx[plane] = ((plane_w[plane] + MOTION_BLOCK) - 1) / MOTION_BLOCK;
  }
  int32_t *mc = checked_malloc((size_t)plane_pixels[0] * 4);   // luma is the largest plane
  int32_t *scratch[3];
  for (int plane = 0; plane < 3; plane++) {
    scratch[plane] = checked_malloc(((size_t)num_frames * plane_pixels[plane]) * 4);
  }
  int len = num_frames;
  for (int l = 0; (l < levels_temporal) && (len >= 2); l++) {
    int low_count = (len + 1) / 2;
    for (int k = 0; k < low_count; k++) {
      int even = 2 * k;
      if (((2 * k) + 1) < len) {
        int odd = (2 * k) + 1;
        int *mv = &frame_mv[((low_count + k) * blocks) * 2];   // this pair's motion lives with the high frame
        motion_estimate_cpu(gop[0] + ((size_t)odd * plane_pixels[0]), gop[0] + ((size_t)even * plane_pixels[0]), mv,
                            plane_w[0], plane_h[0], luma_blocks_x, luma_blocks_y);
        for (int plane = 0; plane < 3; plane++) {
          int pp = plane_pixels[plane];
          motion_compensate(gop[plane] + ((size_t)even * pp), mv, mc, plane_w[plane], plane_h[plane], plane_mbx[plane]);
          memcpy(scratch[plane] + ((size_t)k * pp), gop[plane] + ((size_t)even * pp), (size_t)pp * 4);   // low = even
          int32_t *high = scratch[plane] + ((size_t)(low_count + k) * pp);
          const int32_t *odd_frame = gop[plane] + ((size_t)odd * pp);
          for (int i = 0; i < pp; i++) {
            high[i] = odd_frame[i] - mc[i];                                                              // high = odd - OBMC(even)
          }
        }
      } else {
        for (int plane = 0; plane < 3; plane++) {
          int pp = plane_pixels[plane];
          memcpy(scratch[plane] + ((size_t)k * pp), gop[plane] + ((size_t)even * pp), (size_t)pp * 4);   // odd tail → low passthrough
        }
      }
    }
    for (int plane = 0; plane < 3; plane++) {
      memcpy(gop[plane], scratch[plane], ((size_t)len * plane_pixels[plane]) * 4);
    }
    len = low_count;
  }
  free(mc);
  for (int plane = 0; plane < 3; plane++) {
    free(scratch[plane]);
  }
}

// Inverse of mctf_forward: deepest temporal level first, reconstruct even = low, odd = high + OBMC(even). Uses the
// same frame_mv (decoded per high-pass frame), so it inverts exactly given the forward motion.
static void mctf_inverse(int32_t *gop[3], int num_frames, const int plane_w[3], const int plane_h[3], const int plane_pixels[3],
                         int levels_temporal, const int *frame_mv, int luma_blocks_x, int luma_blocks_y) {
  int blocks = luma_blocks_x * luma_blocks_y;
  int plane_mbx[3];
  for (int plane = 0; plane < 3; plane++) {
    plane_mbx[plane] = ((plane_w[plane] + MOTION_BLOCK) - 1) / MOTION_BLOCK;
  }
  int lengths[16], count = 0, len = num_frames;
  for (int l = 0; (l < levels_temporal) && (len >= 2); l++) {
    lengths[count++] = len;
    len = (len + 1) / 2;
  }
  int32_t *mc = checked_malloc((size_t)plane_pixels[0] * 4);   // luma is the largest plane
  int32_t *scratch[3];
  for (int plane = 0; plane < 3; plane++) {
    scratch[plane] = checked_malloc(((size_t)num_frames * plane_pixels[plane]) * 4);
  }
  for (int l = count - 1; l >= 0; l--) {
    int level_len = lengths[l], low_count = (level_len + 1) / 2;
    for (int k = 0; k < low_count; k++) {
      int even = 2 * k;
      if (((2 * k) + 1) < level_len) {
        int odd = (2 * k) + 1;
        const int *mv = &frame_mv[((low_count + k) * blocks) * 2];
        for (int plane = 0; plane < 3; plane++) {
          int pp = plane_pixels[plane];
          const int32_t *low = gop[plane] + ((size_t)k * pp);
          memcpy(scratch[plane] + ((size_t)even * pp), low, (size_t)pp * 4);                 // even = low
          motion_compensate(low, mv, mc, plane_w[plane], plane_h[plane], plane_mbx[plane]);
          const int32_t *high = gop[plane] + ((size_t)(low_count + k) * pp);
          int32_t *odd_frame = scratch[plane] + ((size_t)odd * pp);
          for (int i = 0; i < pp; i++) {
            odd_frame[i] = high[i] + mc[i];                                                  // odd = high + OBMC(even)
          }
        }
      } else {
        for (int plane = 0; plane < 3; plane++) {
          int pp = plane_pixels[plane];
          memcpy(scratch[plane] + ((size_t)even * pp), gop[plane] + ((size_t)k * pp), (size_t)pp * 4);
        }
      }
    }
    for (int plane = 0; plane < 3; plane++) {
      memcpy(gop[plane], scratch[plane], ((size_t)level_len * plane_pixels[plane]) * 4);
    }
  }
  free(mc);
  for (int plane = 0; plane < 3; plane++) {
    free(scratch[plane]);
  }
}

/* The image is coded in independent 32x32 coefficient blocks. Each block is byte-aligned and its
 * start offset recorded, so every block can be decoded in parallel (no serial dependency) — that
 * is what lets the GPU decode them all at once. */
// Coding/bitplane block (the quadtree significance unit; motion is a separate 16x16 grid). The size is a
// runtime value (32 / 64 / 128), set from the encoder cmdline or the container header; the per-block byte size
// table is Exp-Golomb-coded so a block can exceed the old u16 cap. Array DIMENSIONS are sized for MAX_BLOCK_SIZE;
// all block-EXTENT uses go through the BLOCK_SIZE macro (= g_block_size).
#define MAX_BLOCK_SIZE 128
static int g_block_size = 32;
#define BLOCK_SIZE g_block_size
#define block_count_x(width)  (((width) + BLOCK_SIZE - 1) / BLOCK_SIZE)
#define block_count_y(height) (((height) + BLOCK_SIZE - 1) / BLOCK_SIZE)

// Unsigned Exp-Golomb (run-length significance coding in the sparse block codec).
static void bitwriter_put_unsigned_exp_golomb(BitWriter *writer, uint32_t value) {
  uint32_t m = value + 1;
  int bit_count = 0;
  for (uint32_t t = m; t > 1; t >>= 1) {
    bit_count++;
  }
  for (int i = 0; i < bit_count; i++) {
    bitwriter_put_bit(writer, 0);
  }
  for (int i = bit_count; i >= 0; i--) {
    bitwriter_put_bit(writer, (int)((m >> i) & 1u));
  }
}

static uint32_t bitreader_get_unsigned_exp_golomb(BitReader *reader) {
  int bit_count = 0;
  while (!bitreader_get_bit(reader)) {
    if (++bit_count > 31) {
      break;
    }
  }
  uint32_t m = 1;
  for (int i = 0; i < bit_count; i++) {
    m = (m << 1) | (uint32_t)bitreader_get_bit(reader);
  }
  return m - 1;
}

static int unsigned_exp_golomb_length(uint32_t value) {
  uint32_t m = value + 1;
  int bit_count = 0;
  for (uint32_t t = m; t > 1; t >>= 1) {
    bit_count++;
  }
  return (2 * bit_count) + 1;
}

// ---- QUADTREE significance (added on top of 2c's raw/RLE) ----
// Per plane a coefficient significance map can also be coded as a quadtree over the 32x32 block: at
// each node one "any set bit here?" flag; a 0 skips the whole subtree (so empty regions collapse to a
// single bit), recursion goes 32->16->...->1, and the 1x1 leaf carries the magnitude bit (+ sign at
// the first set bit). This captures 2D spatial clustering of significance that 1D RLE misses. The OR
// of the magnitudes per region (an OR-pyramid) gives each node's any-flag for any plane in O(1).
static void build_or_pyramid(const int32_t *magnitude, int bw, int bh, uint32_t qor[8][16384]) {
  for (int y = 0; y < BLOCK_SIZE; y++) {
    for (int x = 0; x < BLOCK_SIZE; x++) {
      qor[0][(y * BLOCK_SIZE) + x] = (x < bw && y < bh) ? (uint32_t)magnitude[(y * bw) + x] : 0u;
    }
  }
  int block_levels = 0;
  while ((1 << block_levels) < BLOCK_SIZE) {   // 5 for 32, 6 for 64, 7 for 128
    block_levels++;
  }
  for (int L = 1; L <= block_levels; L++) {
    int cells = BLOCK_SIZE >> L, child_stride = BLOCK_SIZE >> (L - 1);
    for (int cy = 0; cy < cells; cy++) {
      for (int cx = 0; cx < cells; cx++) {
        int c = ((2 * cy) * child_stride) + (2 * cx);
        qor[L][(cy * cells) + cx] = ((qor[L - 1][c] | qor[L - 1][c + 1]) | qor[L - 1][c + child_stride]) | qor[L - 1][(c + child_stride) + 1];
      }
    }
  }
}

static int region_any(uint32_t qor[8][16384], int x, int y, int size, int plane) {
  int L = 0;
  while ((1 << L) < size) L++;
  int cells = BLOCK_SIZE >> L;
  return (int)((qor[L][((y >> L) * cells) + (x >> L)] >> plane) & 1u);
}

// Bit cost of the quadtree significance for one plane (the any-flags + leaf bits; signs excluded).
static int quadtree_cost(uint32_t qor[8][16384], int plane, int x, int y, int size) {
  if (size == 1) {
    return 1;
  }
  if (!region_any(qor, x, y, size, plane)) {
    return 1;
  }
  int h = size / 2;
  return (((1 + quadtree_cost(qor, plane, x, y, h)) + quadtree_cost(qor, plane, x + h, y, h))
           + quadtree_cost(qor, plane, x, y + h, h)) + quadtree_cost(qor, plane, x + h, y + h, h);
}

static void encode_quadtree(BitWriter *writer, uint32_t qor[8][16384], int plane, int x, int y, int size,
                            const int32_t *magnitude, const uint8_t *negative, uint8_t *already_significant, int bw, int bh) {
  if (size == 1) {
    int valid = (x < bw && y < bh);
    int idx = (y * bw) + x;
    int bit = valid ? ((magnitude[idx] >> plane) & 1) : 0;
    bitwriter_put_bit(writer, bit);
    if (bit && !already_significant[idx]) {
      already_significant[idx] = 1;
      bitwriter_put_bit(writer, negative[idx]);
    }
    return;
  }
  int any = region_any(qor, x, y, size, plane);
  bitwriter_put_bit(writer, any);
  if (any) {
    int h = size / 2;
    encode_quadtree(writer, qor, plane, x, y, h, magnitude, negative, already_significant, bw, bh);
    encode_quadtree(writer, qor, plane, x + h, y, h, magnitude, negative, already_significant, bw, bh);
    encode_quadtree(writer, qor, plane, x, y + h, h, magnitude, negative, already_significant, bw, bh);
    encode_quadtree(writer, qor, plane, x + h, y + h, h, magnitude, negative, already_significant, bw, bh);
  }
}

static void decode_quadtree(BitReader *reader, int plane, int x, int y, int size,
                            int32_t *magnitude, int32_t *sign, uint8_t *already_significant, int bw, int bh) {
  if (size == 1) {
    int bit = bitreader_get_bit(reader);
    if ((bit && x < bw) && y < bh) {
      int idx = (y * bw) + x;
      magnitude[idx] |= (1 << plane);
      if (!already_significant[idx]) {
        already_significant[idx] = 1;
        sign[idx] = bitreader_get_bit(reader) ? -1 : 1;
      }
    }
    return;
  }
  if (bitreader_get_bit(reader)) {
    int h = size / 2;
    decode_quadtree(reader, plane, x, y, h, magnitude, sign, already_significant, bw, bh);
    decode_quadtree(reader, plane, x + h, y, h, magnitude, sign, already_significant, bw, bh);
    decode_quadtree(reader, plane, x, y + h, h, magnitude, sign, already_significant, bw, bh);
    decode_quadtree(reader, plane, x + h, y + h, h, magnitude, sign, already_significant, bw, bh);
  }
}

/* Encode one block. 5
 * bits for the number of bit-planes, then per plane MSB->LSB: a 2-bit method flag, the magnitude-bit
 * significance map in that method, with the sign interleaved at each newly-significant bit. The
 * encoder picks the cheapest of the three per plane, so it never loses to 2c (raw + RLE). */
static void encode_block(BitWriter *writer, const int32_t *coefficients, int width,
                         int block_x, int block_y, int block_width, int block_height, uint32_t qor[8][16384]) {
  int count = block_width * block_height;
  int32_t magnitude[MAX_BLOCK_SIZE * MAX_BLOCK_SIZE];
  uint8_t negative[MAX_BLOCK_SIZE * MAX_BLOCK_SIZE];
  uint8_t already_significant[MAX_BLOCK_SIZE * MAX_BLOCK_SIZE];
  int max_magnitude = 0;
  for (int y = 0; y < block_height; y++) {
    for (int x = 0; x < block_width; x++) {
      int value = coefficients[(((block_y + y) * width) + block_x) + x];
      int local_index = (y * block_width) + x;
      magnitude[local_index] = (value < 0) ? -value : value;
      negative[local_index] = value < 0;
      if (magnitude[local_index] > max_magnitude) {
        max_magnitude = magnitude[local_index];
      }
    }
  }
  int bit_plane_count = 0;
  while ((1 << bit_plane_count) <= max_magnitude) {
    bit_plane_count++;
  }
  bitwriter_put_bits(writer, (uint32_t)bit_plane_count, 5);
  if (!bit_plane_count) {
    return;
  }
  memset(already_significant, 0, (size_t)count);
  build_or_pyramid(magnitude, block_width, block_height, qor);   // qor scratch is owned by the caller (heap, per-thread)
  for (int plane = bit_plane_count - 1; plane >= 0; plane--) {
    // Costs of the three significance encodings for this plane (signs are equal in all three).
    int popcount = 0, rle_bits = 0, last = 0;
    for (int i = 0; i < count; i++) {
      if ((magnitude[i] >> plane) & 1) {
        rle_bits += unsigned_exp_golomb_length((uint32_t)(i - last));
        last = i + 1;
        popcount++;
      }
    }
    rle_bits += unsigned_exp_golomb_length((uint32_t)popcount);
    int qt_bits = quadtree_cost(qor, plane, 0, 0, BLOCK_SIZE);
    int method = 0, best = count;   // 0 = raw, 1 = RLE, 2 = quadtree
    if (rle_bits < best) { best = rle_bits; method = 1; }
    if (qt_bits < best) { method = 2; }
    bitwriter_put_bits(writer, (uint32_t)method, 2);
    if (method == 1) {
      bitwriter_put_unsigned_exp_golomb(writer, (uint32_t)popcount);
      last = 0;
      for (int i = 0; i < count; i++) {
        if ((magnitude[i] >> plane) & 1) {
          bitwriter_put_unsigned_exp_golomb(writer, (uint32_t)(i - last));
          last = i + 1;
          if (!already_significant[i]) {   // sign interleaved right at the newly-significant bit
            already_significant[i] = 1;
            bitwriter_put_bit(writer, negative[i]);
          }
        }
      }
    } else if (method == 2) {
      encode_quadtree(writer, qor, plane, 0, 0, BLOCK_SIZE, magnitude, negative, already_significant, block_width, block_height);
    } else {
      for (int i = 0; i < count; i++) {
        int bit = (magnitude[i] >> plane) & 1;
        bitwriter_put_bit(writer, bit);
        if (bit && !already_significant[i]) {
          already_significant[i] = 1;
          bitwriter_put_bit(writer, negative[i]);
        }
      }
    }
  }
}

static void decode_block(BitReader *reader, int32_t *coefficients, int width,
                         int block_x, int block_y, int block_width, int block_height) {
  int count = block_width * block_height;
  uint8_t already_significant[MAX_BLOCK_SIZE * MAX_BLOCK_SIZE];
  int32_t magnitude[MAX_BLOCK_SIZE * MAX_BLOCK_SIZE];
  int32_t sign[MAX_BLOCK_SIZE * MAX_BLOCK_SIZE];
  int bit_plane_count = (int)bitreader_get_bits(reader, 5);
  if (!bit_plane_count) {
    for (int y = 0; y < block_height; y++) {
      for (int x = 0; x < block_width; x++) {
        coefficients[(((block_y + y) * width) + block_x) + x] = 0;
      }
    }
    return;
  }
  memset(already_significant, 0, (size_t)count);
  memset(magnitude, 0, (size_t)count * sizeof(int32_t));
  memset(sign, 0, (size_t)count * sizeof(int32_t));
  for (int plane = bit_plane_count - 1; plane >= 0; plane--) {
    int method = (int)bitreader_get_bits(reader, 2);   // 0 = raw, 1 = RLE, 2 = quadtree
    if (method == 1) {
      int popcount = (int)bitreader_get_unsigned_exp_golomb(reader);
      int position = 0;
      for (int j = 0; j < popcount; j++) {
        position += (int)bitreader_get_unsigned_exp_golomb(reader);
        magnitude[position] |= (1 << plane);
        if (!already_significant[position]) {   // sign interleaved at the newly-significant bit
          already_significant[position] = 1;
          sign[position] = bitreader_get_bit(reader) ? -1 : 1;
        }
        position++;
      }
    } else if (method == 2) {
      decode_quadtree(reader, plane, 0, 0, BLOCK_SIZE, magnitude, sign, already_significant, block_width, block_height);
    } else {
      for (int i = 0; i < count; i++) {
        if (bitreader_get_bit(reader)) {
          magnitude[i] |= (1 << plane);
          if (!already_significant[i]) {
            already_significant[i] = 1;
            sign[i] = bitreader_get_bit(reader) ? -1 : 1;
          }
        }
      }
    }
  }
  for (int y = 0; y < block_height; y++) {
    for (int x = 0; x < block_width; x++) {
      int local_index = (y * block_width) + x;
      coefficients[(((block_y + y) * width) + block_x) + x] =
          (sign[local_index] < 0) ? -magnitude[local_index] : magnitude[local_index];
    }
  }
}

// A whole plane -> a byte-aligned block stream plus a per-block byte-offset table.
// Fills sizes[block] with the byte length of each (byte-aligned) block. The container stores these as
// u16 (a 32x32 block is at most ~4 KB: 1024 coefficients x 32 bits) and the decoder prefix-sums them
// back into offsets — half the table of the old u32 absolute offsets.
static double g_pcrd_lambda = 0.0;   // PCRD strength, set by --pcrd (0 = off, the default)

// PCRD-like rate-distortion bit-allocation. For each 32x32 block, drop the lowest
// bit-planes whose rate cost outweighs their distortion reduction, at a single global Lagrangian
// lambda — the textbook equal-slope condition that minimises total distortion for the resulting rate.
// Truncation = masking the low magnitude bits before the (unchanged) bit-plane coder, so the bitstream
// format and the GPU decoder are untouched. Because 2h's quant makes step*gain ~uniform across
// subbands, the image-domain distortion of an index error is ~uniform, so the squared INDEX error is a
// valid distortion proxy here (no per-coefficient subband/gain lookup needed). Called on the quantized
// coefficients (or residual) just before encode_plane; the colordiff closed loop then reconstructs
// from the same truncated buffer, so the reference cannot drift. lambda <= 0 disables it (== 2h).
static void apply_pcrd(int32_t *coefficients, int width, int height, double lambda) {
  if (lambda <= 0.0) {
    return;
  }
  enum { T_MAX = 8 };
  const double EMPTY_PLANE_BITS = 3.0;   // a masked-out plane still costs ~flag + empty significance
  int32_t magnitude[MAX_BLOCK_SIZE * MAX_BLOCK_SIZE];
  for (int block_y = 0; block_y < height; block_y += BLOCK_SIZE) {
    for (int block_x = 0; block_x < width; block_x += BLOCK_SIZE) {
      int block_width = (block_x + BLOCK_SIZE < width) ? BLOCK_SIZE : (width - block_x);
      int block_height = (block_y + BLOCK_SIZE < height) ? BLOCK_SIZE : (height - block_y);
      int count = block_width * block_height;
      int max_magnitude = 0;
      for (int y = 0; y < block_height; y++) {
        for (int x = 0; x < block_width; x++) {
          int value = coefficients[(((block_y + y) * width) + block_x) + x];
          int m = (value < 0) ? -value : value;
          magnitude[(y * block_width) + x] = m;
          if (m > max_magnitude) {
            max_magnitude = m;
          }
        }
      }
      if (max_magnitude == 0) {
        continue;
      }
      int bit_plane_count = 0;
      while ((1 << bit_plane_count) <= max_magnitude) {
        bit_plane_count++;
      }
      int max_t = (bit_plane_count < T_MAX) ? bit_plane_count : T_MAX;

      // Per-plane coding cost: the significance map (min raw vs RLE) + the signs of coefficients that
      // are first-significant there (the 2-bit method flag is added too).
      double cost[32];
      for (int plane = 0; plane < bit_plane_count; plane++) {
        int popcount = 0, rle_bits = 0, last = 0, newly_significant = 0;
        for (int i = 0; i < count; i++) {
          if (((magnitude[i] >> plane) & 1) != 0) {
            rle_bits += unsigned_exp_golomb_length((uint32_t)(i - last));
            last = i + 1;
            popcount++;
            if ((magnitude[i] >> plane) == 1) {
              newly_significant++;
            }
          }
        }
        rle_bits += unsigned_exp_golomb_length((uint32_t)popcount);
        int significance = (rle_bits < count) ? rle_bits : count;
        cost[plane] = (double)(significance + newly_significant) + 2.0;
      }

      // Rate (bits) and distortion (squared index error) for dropping the lowest t bit-planes.
      double rate[T_MAX + 1], distortion[T_MAX + 1];
      for (int t = 0; t <= max_t; t++) {
        double bits = 5.0;
        for (int plane = t; plane < bit_plane_count; plane++) {
          bits += cost[plane];
        }
        bits += (double)t * EMPTY_PLANE_BITS;
        rate[t] = bits;
        uint32_t low_mask = (t >= 31) ? 0xFFFFFFFFu : ((1u << t) - 1u);
        double energy = 0.0;
        for (int i = 0; i < count; i++) {
          double dropped = (double)((uint32_t)magnitude[i] & low_mask);
          energy += dropped * dropped;
        }
        distortion[t] = energy;
      }

      // Greedy equal-slope truncation: keep dropping while the next plane's distortion/rate slope is
      // below lambda (the bit-planes have a monotonically rising slope, so the cutoff is unique).
      int chosen = 0;
      while (chosen < max_t) {
        double delta_distortion = distortion[chosen + 1] - distortion[chosen];
        double delta_rate = rate[chosen] - rate[chosen + 1];
        if (delta_rate > 0.0 && delta_distortion < lambda * delta_rate) {
          chosen++;
        } else {
          break;
        }
      }
      if (chosen == 0) {
        continue;
      }

      uint32_t clear_mask = ~((chosen >= 31) ? 0xFFFFFFFFu : ((1u << chosen) - 1u));
      for (int y = 0; y < block_height; y++) {
        for (int x = 0; x < block_width; x++) {
          int idx = (((block_y + y) * width) + block_x) + x;
          int value = coefficients[idx];
          int m = (int)((uint32_t)((value < 0) ? -value : value) & clear_mask);
          coefficients[idx] = (value < 0) ? -m : m;
        }
      }
    }
  }
}

static void encode_plane(BitWriter *writer, const int32_t *coefficients, int width, int height, uint32_t *sizes) {
  uint32_t (*qor)[16384] = checked_malloc(sizeof(uint32_t[8][16384]));   // OR-pyramid scratch, owned here (per-thread)
  int block = 0;
  for (int block_y = 0; block_y < height; block_y += BLOCK_SIZE) {
    for (int block_x = 0; block_x < width; block_x += BLOCK_SIZE) {
      uint32_t before = (uint32_t)writer->length;
      encode_block(writer, coefficients, width, block_x, block_y,
                   (block_x + BLOCK_SIZE < width) ? BLOCK_SIZE : (width - block_x),
                   (block_y + BLOCK_SIZE < height) ? BLOCK_SIZE : (height - block_y), qor);
      bitwriter_flush(writer);
      sizes[block++] = (uint32_t)writer->length - before;
    }
  }
  free(qor);
}

static void decode_plane(const uint8_t *data, const uint32_t *offsets, int32_t *coefficients, int width, int height) {
  int block = 0;
  for (int block_y = 0; block_y < height; block_y += BLOCK_SIZE) {
    for (int block_x = 0; block_x < width; block_x += BLOCK_SIZE) {
      BitReader reader;
      bitreader_init(&reader, data + offsets[block++], 1u << 30);
      decode_block(&reader, coefficients, width, block_x, block_y,
                   (block_x + BLOCK_SIZE < width) ? BLOCK_SIZE : (width - block_x),
                   (block_y + BLOCK_SIZE < height) ? BLOCK_SIZE : (height - block_y));
    }
  }
}

// ------------------------------------------------------------------ frame codec (intra)

/* Frame payload layout:
 *     [block_count : u32]
 *     [sizes for plane 0, 1, 2 : block_count u16 each]   (byte length of each block)
 *     [data_length : u32]
 *     [data]
 * Storing per-block u16 SIZES (not u32 absolute offsets) halves this table; the decoder prefix-sums
 * them back into offsets (continuous across the three planes), keeping every block independently
 * (GPU-parallel) decodable. A 32x32 block is at most ~4 KB, so u16 cannot overflow. */

// ---------------------------------------------------------------- LZSS frame-payload compression
// Each frame's container payload is LZSS-compressed CPU-side (post-GPU readback); the GPU never sees it (the player
// decompresses on the CPU before the existing parse/upload). 16-bit window, 64-deep hash-chain match search. The
// decode is memcpy/memset-optimised (non-overlapping matches and literal runs copy in bulk), so it is nearly as fast
// as a raw copy. Container framing around the LZSS bytes ([method][raw_len]) is handled by the enc/dec helpers.
#define LZ_MAX_OFFSET 65535
#define LZ_MIN_MATCH  4
#define LZ_MAX_MATCH  259   // (length - LZ_MIN_MATCH) must fit one byte
#define LZ_HASH_SIZE  16384

static int lz_hash(const uint8_t *p) {
  return (int)((((p[0] * 506832829u) + (p[1] * 40503u)) + p[2]) >> 4) & (LZ_HASH_SIZE - 1);
}

// Compress in[0..n) into out (which must hold at least (n * 2) + 64 bytes). Control words are 32 bits (1 flag/token).
static size_t lz_compress(const uint8_t *in, size_t n, uint8_t *out) {
  int *head = checked_malloc(LZ_HASH_SIZE * sizeof(int));
  int *previous = checked_malloc((n ? n : 1) * sizeof(int));
  for (int i = 0; i < LZ_HASH_SIZE; i++) {
    head[i] = -1;
  }
  size_t out_position = 0, in_position = 0, control_position = 0;
  uint32_t control = 0;
  int control_bit = 32;
  while (in_position < n) {
    if (control_bit == 32) {
      control_position = out_position;
      out_position += 4;
      control = 0;
      control_bit = 0;
    }
    int best_length = 0, best_offset = 0;
    if ((in_position + LZ_MIN_MATCH) <= n) {
      int h = lz_hash(in + in_position);
      int guard = 0;
      for (int candidate = head[h]; (candidate >= 0) && (guard < 64); candidate = previous[candidate], guard++) {
        size_t offset = in_position - (size_t)candidate;
        if (offset > LZ_MAX_OFFSET) {
          break;
        }
        size_t length = 0;
        while (((length < LZ_MAX_MATCH) && ((in_position + length) < n)) && (in[candidate + length] == in[in_position + length])) {
          length++;
        }
        if ((int)length > best_length) {
          best_length = (int)length;
          best_offset = (int)offset;
          if (best_length == LZ_MAX_MATCH) {
            break;
          }
        }
      }
    }
    if (best_length >= LZ_MIN_MATCH) {
      control |= (uint32_t)1 << control_bit;
      out[out_position++] = (uint8_t)(best_offset & 255);
      out[out_position++] = (uint8_t)((best_offset >> 8) & 255);
      out[out_position++] = (uint8_t)(best_length - LZ_MIN_MATCH);
      for (int k = 0; (k < best_length) && (in_position < n); k++) {
        if ((in_position + LZ_MIN_MATCH) <= n) {
          int h = lz_hash(in + in_position);
          previous[in_position] = head[h];
          head[h] = (int)in_position;
        }
        in_position++;
      }
    } else {
      out[out_position++] = in[in_position];
      if ((in_position + LZ_MIN_MATCH) <= n) {
        int h = lz_hash(in + in_position);
        previous[in_position] = head[h];
        head[h] = (int)in_position;
      }
      in_position++;
    }
    control_bit++;
    if (control_bit == 32) {
      memcpy(out + control_position, &control, 4);
    }
  }
  if (control_bit != 32) {
    memcpy(out + control_position, &control, 4);
  }
  free(head);
  free(previous);
  return out_position;
}

// Decompress in[0..n) into out (must hold out_size bytes). memcpy/memset-optimised.
static void lz_decompress(const uint8_t *in, size_t n, uint8_t *out, size_t out_size) {
  size_t in_position = 0, out_position = 0;
  int control_bit = 32;
  uint32_t control = 0;
  while ((in_position < n) && (out_position < out_size)) {
    if (control_bit == 32) {
      memcpy(&control, in + in_position, 4);
      in_position += 4;
      control_bit = 0;
    }
    if (control & ((uint32_t)1 << control_bit)) {
      int offset = in[in_position] | (in[in_position + 1] << 8);
      int length = in[in_position + 2] + LZ_MIN_MATCH;
      in_position += 3;
      size_t source = out_position - (size_t)offset;
      if ((size_t)offset >= (size_t)length) {
        memcpy(out + out_position, out + source, (size_t)length);   // non-overlapping
      } else if (offset == 1) {
        memset(out + out_position, out[source], (size_t)length);    // 1-byte run
      } else {
        for (int k = 0; k < length; k++) {
          out[out_position + k] = out[source + k];                  // small-offset overlap (pattern fill)
        }
      }
      out_position += (size_t)length;
      control_bit++;
    } else {
      // a run of consecutive literals (control bits 0) -> one bulk copy
      uint32_t rest = control & ~(((uint32_t)1 << control_bit) - 1);
      int next = rest ? __builtin_ctz(rest) : 32;
      int run = next - control_bit;
      memcpy(out + out_position, in + in_position, (size_t)run);
      in_position += (size_t)run;
      out_position += (size_t)run;
      control_bit += run;
    }
  }
}

// ---------------------------------------------------------------- LZBRRC frame-payload compression
// LZBRRC = the engine's own PasVulkan.Compression.LZBRRC ported to C: LZ77 hash-chain matching feeding an LZMA-style
// binary range coder (adaptive 12-bit probability models) with Elias-gamma offsets/lengths + a repeat-offset slot.
// ~20% smaller than LZSS (best ratio of the candidates, native = no zlib dependency), but the bit-serial range decode
// is ~37x slower than LZSS-memcpy (~1.14 ms/frame at 4K). Selected per-stream via --frame-codec lzbrrc; the per-frame
// [method] byte = 2 so the decoder dispatches it independently of LZSS (method 1) and raw (method 0). Same on-wire
// container framing ([method][raw_len]) as LZSS; the LZBRRC bytes themselves carry a (redundant) 8-byte size header.
#define LZBRRC_WINDOW      32768
#define LZBRRC_WMASK       (LZBRRC_WINDOW - 1)
#define LZBRRC_HASH_BITS   16
#define LZBRRC_HASH_SIZE   (1 << LZBRRC_HASH_BITS)
#define LZBRRC_HASH_SHIFT  (32 - LZBRRC_HASH_BITS)
#define LZBRRC_MIN_MATCH   3
#define LZBRRC_MAX_OFFSET  0x7fffffffu
#define LZBRRC_ENCODE_LEVEL 2   // L2 = best ratio at the fastest encode (L5/L8 add ~0 ratio for much slower encode)

// Adaptive-model bank layout. Each gamma model owns 256 context slots (the context is an 8-bit value that wraps mod
// 256), the literal tree 256, the match-low tree 32; SIZE_MODELS is the total bank size.
enum {
  LZBRRC_FLAG_MODEL           = 0,
  LZBRRC_PREVIOUS_MATCH_MODEL = 2,
  LZBRRC_MATCH_LOW_MODEL      = 3,
  LZBRRC_LITERAL_MODEL        = 35,
  LZBRRC_GAMMA0_MODEL         = 291,
  LZBRRC_GAMMA1_MODEL         = 547,
  LZBRRC_SIZE_MODELS          = 803
};

static inline uint32_t lzbrrc_read32(const uint8_t *p) {
  uint32_t value;
  memcpy(&value, p, 4);
  return value;   // little-endian host (the 3-byte hash + 4-byte match compare read it back the same way)
}

// ---- encoder: binary range coder (LZMA-style carry-propagating output) over adaptive bit models ----
typedef struct {
  uint8_t *out;
  size_t position;
  size_t capacity;
  int overflow;
  uint64_t code;
  uint32_t range;
  uint32_t cache;
  uint32_t count_ff;
  int first_byte;
  uint32_t model[LZBRRC_SIZE_MODELS];
} LZBRRCEncoder;

static void lzbrrc_encoder_put(LZBRRCEncoder *encoder, uint8_t value) {
  if (encoder->position >= encoder->capacity) {
    encoder->overflow = 1;
    return;
  }
  encoder->out[encoder->position++] = value;
}

static void lzbrrc_encoder_shift(LZBRRCEncoder *encoder) {
  int carry = ((encoder->code >> 32) != 0) ? 1 : 0;
  if ((encoder->code < (uint64_t)0xff000000) || carry) {
    if (encoder->first_byte) {
      encoder->first_byte = 0;
    } else {
      lzbrrc_encoder_put(encoder, (uint8_t)(encoder->cache + (uint32_t)carry));
    }
    while (encoder->count_ff != 0) {
      encoder->count_ff--;
      lzbrrc_encoder_put(encoder, (uint8_t)(0xff + (uint32_t)carry));
    }
    encoder->cache = (uint32_t)((encoder->code >> 24) & 0xff);
  } else {
    encoder->count_ff++;
  }
  encoder->code = (encoder->code << 8) & (uint64_t)0xffffffff;
}

static int lzbrrc_encode_bit(LZBRRCEncoder *encoder, int model_index, int move, int bit) {
  uint32_t bound = (encoder->range >> 12) * encoder->model[model_index];
  if (bit == 0) {
    encoder->range = bound;
    encoder->model[model_index] += (4096 - encoder->model[model_index]) >> move;
  } else {
    encoder->code += bound;
    encoder->range -= bound;
    encoder->model[model_index] -= encoder->model[model_index] >> move;
  }
  while (encoder->range < 0x1000000) {
    encoder->range <<= 8;
    lzbrrc_encoder_shift(encoder);
  }
  return bit;
}

static void lzbrrc_encode_tree(LZBRRCEncoder *encoder, int model_index, int bits, int move, int value) {
  int context = 1;
  while (bits > 0) {
    bits--;
    context = (context << 1) | lzbrrc_encode_bit(encoder, model_index + context, move, (value >> bits) & 1);
  }
}

static void lzbrrc_encode_gamma(LZBRRCEncoder *encoder, int model_index, uint32_t value) {
  int top = (value != 0) ? (31 - __builtin_clz(value)) : 0;   // bit-scan-reverse (gamma values are always >= 2 here)
  if (top < 1) {
    top = 1;
  }
  top -= 1;
  uint8_t context = 1;   // 8-bit context, wraps mod 256 -> 256 model slots per gamma bank
  for (int index = top; index >= 0; index--) {
    context = (uint8_t)((context << 1) | lzbrrc_encode_bit(encoder, model_index + context, 5, (index != 0) ? 1 : 0));
    context = (uint8_t)((context << 1) | lzbrrc_encode_bit(encoder, model_index + context, 5, (value >> index) & 1));
  }
}

static void lzbrrc_encode_end(LZBRRCEncoder *encoder, int model_index) {
  uint8_t context = 1;
  for (int bits = 32; bits > 0; ) {
    bits--;
    context = (uint8_t)((context << 1) | lzbrrc_encode_bit(encoder, model_index + context, 5, (bits != 0) ? 1 : 0));
    lzbrrc_encode_bit(encoder, model_index + context, 5, 0);
    context = (uint8_t)(context << 1);
  }
}

// Compress in[0..n) into out (capacity out_capacity). Returns the byte length written, or SIZE_MAX if it would not fit
// (the caller then stores the frame raw). out should hold at least (n * 2) + 64 bytes for typical payloads.
static size_t lzbrrc_compress(const uint8_t *in, size_t n, uint8_t *out, size_t out_capacity, int level) {
  LZBRRCEncoder encoder;
  memset(&encoder, 0, sizeof(encoder));
  encoder.out = out;
  encoder.capacity = out_capacity;
  encoder.first_byte = 1;
  encoder.range = 0xffffffff;
  for (int i = 0; i < LZBRRC_SIZE_MODELS; i++) {
    encoder.model[i] = 2048;
  }
  for (int s = 0; s < 8; s++) {   // 8-byte little-endian uncompressed-size header
    lzbrrc_encoder_put(&encoder, (uint8_t)(((uint64_t)n >> (s * 8)) & 0xff));
  }
  int max_steps = 1 << level;
  uint32_t skip_strength = (uint32_t)(32 - 9) + (uint32_t)level;
  int greedy = (level >= 1) ? 1 : 0;
  int32_t *head = checked_malloc(LZBRRC_HASH_SIZE * sizeof(int32_t));
  int32_t *chain = checked_malloc(LZBRRC_WINDOW * sizeof(int32_t));
  for (int i = 0; i < LZBRRC_HASH_SIZE; i++) {
    head[i] = -1;
  }
  for (int i = 0; i < LZBRRC_WINDOW; i++) {
    chain[i] = -1;
  }
  int last_was_match = 0, first = 1;
  uint32_t last_match_distance = 0xffffffff;
  uint32_t unsuccessful = (uint32_t)1 << (skip_strength & 31);
  size_t end_search = (n >= 4) ? (n - 4) : 0;   // stop 4 before the end (the match compare reads a u32)
  size_t cur = 0;
  while (cur < end_search) {
    uint32_t h = ((((lzbrrc_read32(in + cur) & 0x00ffffff) * 0x1e35a7bdu) >> LZBRRC_HASH_SHIFT) & (LZBRRC_HASH_SIZE - 1));
    int32_t head_old = head[h];
    int32_t candidate = head_old;
    uint32_t best_distance = 0, best_length = 1;
    if (first) {
      first = 0;
      lzbrrc_encode_tree(&encoder, LZBRRC_LITERAL_MODEL, 8, 4, in[cur]);
    } else {
      int step = 0;
      while (((candidate >= 0) && (cur > (size_t)candidate)) && ((cur - (size_t)candidate) < LZBRRC_MAX_OFFSET)) {
        uint32_t difference = lzbrrc_read32(in + cur) ^ lzbrrc_read32(in + (size_t)candidate);
        if ((difference & 0x00ffffff) == 0) {
          if ((best_length <= (uint32_t)(n - cur)) && (in[cur + best_length - 1] == in[(size_t)candidate + best_length - 1])) {
            uint32_t length = LZBRRC_MIN_MATCH;
            while ((cur + length + 3) < n) {
              uint32_t d = lzbrrc_read32(in + cur + length) ^ lzbrrc_read32(in + (size_t)candidate + length);
              if (d == 0) {
                length += 4;
              } else {
                length += (uint32_t)(__builtin_ctz(d) >> 3);
                break;
              }
            }
            if (best_length < length) {
              best_distance = (uint32_t)(cur - (size_t)candidate);
              best_length = length;
            }
          }
        }
        step++;
        if (step < max_steps) {
          candidate = chain[((size_t)candidate) & LZBRRC_WMASK];
        } else {
          break;
        }
      }
      if ((best_distance > 0) && ((((best_distance < 96) && (best_length > 1)) || ((best_distance >= 96) && (best_length > 3))) || ((best_distance >= 2048) && (best_length > 4)))) {
        uint32_t match_length = best_length;
        lzbrrc_encode_bit(&encoder, LZBRRC_FLAG_MODEL + (last_was_match & 1), 5, 1);
        if ((!last_was_match) && (best_distance == last_match_distance)) {
          lzbrrc_encode_bit(&encoder, LZBRRC_PREVIOUS_MATCH_MODEL, 5, 1);
        } else {
          if (!last_was_match) {
            lzbrrc_encode_bit(&encoder, LZBRRC_PREVIOUS_MATCH_MODEL, 5, 0);
          }
          uint32_t offset = best_distance - 1;
          lzbrrc_encode_gamma(&encoder, LZBRRC_GAMMA0_MODEL, (offset >> 4) + 2);
          lzbrrc_encode_tree(&encoder, LZBRRC_MATCH_LOW_MODEL + ((((offset >> 4) != 0) ? 1 : 0) << 4), 4, 5, offset & 0xf);
          match_length -= (uint32_t)((best_distance >= 96) ? 1 : 0) + (uint32_t)((best_distance >= 2048) ? 1 : 0);
        }
        lzbrrc_encode_gamma(&encoder, LZBRRC_GAMMA1_MODEL, match_length);
        last_was_match = 1;
        last_match_distance = best_distance;
        unsuccessful = (uint32_t)1 << (skip_strength & 31);
      } else {
        uint32_t span = (best_length == 1) ? (unsuccessful >> (skip_strength & 31)) : best_length;
        uint32_t offset = 0;
        while (offset < span) {
          if ((cur + offset) < end_search) {
            lzbrrc_encode_bit(&encoder, LZBRRC_FLAG_MODEL + (last_was_match & 1), 5, 0);
            lzbrrc_encode_tree(&encoder, LZBRRC_LITERAL_MODEL, 8, 4, in[cur + offset]);
            last_was_match = 0;
            offset++;
          } else {
            best_length = offset;
            break;
          }
        }
        if (best_length == 1) {
          best_length = offset;
          if (unsuccessful < 0xffffffffu) {
            unsuccessful++;
          }
        }
      }
    }
    head[h] = (int32_t)cur;
    chain[cur & LZBRRC_WMASK] = head_old;
    if (greedy) {   // insert a hash entry for every byte of the matched span (better future matches)
      cur++;
      best_length--;
      while ((best_length > 0) && (cur < end_search)) {
        uint32_t hh = ((((lzbrrc_read32(in + cur) & 0x00ffffff) * 0x1e35a7bdu) >> LZBRRC_HASH_SHIFT) & (LZBRRC_HASH_SIZE - 1));
        int32_t old = head[hh];
        head[hh] = (int32_t)cur;
        chain[cur & LZBRRC_WMASK] = old;
        cur++;
        best_length--;
      }
    }
    cur += best_length;
  }
  while (cur < n) {   // tail literals (within 4 bytes of the end, where the u32 match compare cannot run)
    lzbrrc_encode_bit(&encoder, LZBRRC_FLAG_MODEL + (last_was_match & 1), 5, 0);
    lzbrrc_encode_tree(&encoder, LZBRRC_LITERAL_MODEL, 8, 4, in[cur]);
    last_was_match = 0;
    cur++;
  }
  lzbrrc_encode_bit(&encoder, LZBRRC_FLAG_MODEL + (last_was_match & 1), 5, 1);   // end marker: a "match" whose offset gamma = 0
  if (!last_was_match) {
    lzbrrc_encode_bit(&encoder, LZBRRC_PREVIOUS_MATCH_MODEL, 5, 0);
  }
  lzbrrc_encode_end(&encoder, LZBRRC_GAMMA0_MODEL);
  size_t min_position = encoder.position + 1;
  if (min_position < 2) {
    min_position = 2;
  }
  for (int c = 0; c < 5; c++) {   // flush the range coder
    lzbrrc_encoder_shift(&encoder);
  }
  while ((encoder.position > min_position) && (encoder.out[encoder.position - 1] == 0)) {
    encoder.position--;   // strip trailing zeros (the decoder synthesizes zeros past the end)
  }
  free(head);
  free(chain);
  if (encoder.overflow) {
    return (size_t)-1;
  }
  return encoder.position;
}

// ---- decoder: portable binary range decoder (no ASM) ----
typedef struct {
  const uint8_t *in;
  size_t length;
  size_t position;
  uint32_t code;
  uint32_t range;
  int ok;
  uint32_t model[LZBRRC_SIZE_MODELS];
} LZBRRCDecoder;

static int lzbrrc_decode_bit(LZBRRCDecoder *decoder, int model_index, int move) {
  uint32_t bound = (decoder->range >> 12) * decoder->model[model_index];
  int bit;
  if (decoder->code < bound) {
    decoder->range = bound;
    decoder->model[model_index] += (4096 - decoder->model[model_index]) >> move;
    bit = 0;
  } else {
    decoder->code -= bound;
    decoder->range -= bound;
    decoder->model[model_index] -= decoder->model[model_index] >> move;
    bit = 1;
  }
  while (decoder->range < 0x1000000) {
    if (decoder->position < decoder->length) {
      decoder->code = (decoder->code << 8) | decoder->in[decoder->position];
    } else if (decoder->position < (decoder->length + 5)) {
      decoder->code = decoder->code << 8;   // past the end: synthesize zero bytes (matches the stripped trailing zeros)
    } else {
      decoder->ok = 0;
      break;
    }
    decoder->position++;
    decoder->range <<= 8;
  }
  return bit;
}

static int lzbrrc_decode_tree(LZBRRCDecoder *decoder, int model_index, int max_value, int move) {
  int result = 1;
  while (decoder->ok && (result < max_value)) {
    result = (result << 1) | lzbrrc_decode_bit(decoder, model_index + result, move);
  }
  return result - max_value;
}

static int lzbrrc_decode_gamma(LZBRRCDecoder *decoder, int model_index) {
  int result = 1;
  uint8_t context = 1;   // 8-bit context, wraps mod 256
  do {
    context = (uint8_t)((context << 1) | lzbrrc_decode_bit(decoder, model_index + context, 5));
    result = (result << 1) | lzbrrc_decode_bit(decoder, model_index + context, 5);
    context = (uint8_t)((context << 1) | (result & 1));
  } while (decoder->ok && ((context & 2) != 0));
  return result;
}

// LZ77 copy from earlier output; the source may overlap the destination (run synthesis), so that case copies byte-wise.
static void lzbrrc_overlap_move(uint8_t *out, size_t source, size_t destination, int length) {
  if ((source + (size_t)length) <= destination) {
    memcpy(out + destination, out + source, (size_t)length);
  } else {
    for (int k = 0; k < length; k++) {
      out[destination + k] = out[source + k];
    }
  }
}

// Decompress in[0..n) into out (must hold out_size bytes). Returns the produced length, or 0 on a malformed stream.
static size_t lzbrrc_decompress(const uint8_t *in, size_t n, uint8_t *out, size_t out_size) {
  LZBRRCDecoder decoder;
  decoder.in = in;
  decoder.length = n;
  decoder.ok = 1;
  decoder.range = 0xffffffff;
  for (int i = 0; i < LZBRRC_SIZE_MODELS; i++) {
    decoder.model[i] = 2048;
  }
  // bytes 0..7 = the (redundant) little-endian size header; the code register starts at byte 8
  decoder.code = (((uint32_t)in[8] << 24) | ((uint32_t)in[9] << 16)) | (((uint32_t)in[10] << 8) | (uint32_t)in[11]);
  decoder.position = 12;
  int last_offset = 0, last_was_match = 0, flag = 0;
  size_t out_position = 0;
  for (;;) {
    if (flag) {
      int offset, length;
      if ((!last_was_match) && (lzbrrc_decode_bit(&decoder, LZBRRC_PREVIOUS_MATCH_MODEL, 5) != 0)) {
        offset = last_offset;
        length = 0;
      } else {
        offset = lzbrrc_decode_gamma(&decoder, LZBRRC_GAMMA0_MODEL);
        if (offset == 0) {
          break;   // end marker
        }
        offset -= 2;
        offset = ((offset << 4) + lzbrrc_decode_tree(&decoder, LZBRRC_MATCH_LOW_MODEL + (((offset != 0) ? 1 : 0) << 4), 16, 5)) + 1;
        length = (int)((offset >= 96) ? 1 : 0) + (int)((offset >= 2048) ? 1 : 0);
      }
      last_offset = offset;
      last_was_match = 1;
      length += lzbrrc_decode_gamma(&decoder, LZBRRC_GAMMA1_MODEL);
      if (((!decoder.ok) || ((out_position + (size_t)length) > out_size)) || ((size_t)offset > out_position)) {
        return 0;
      }
      lzbrrc_overlap_move(out, out_position - (size_t)offset, out_position, length);
      out_position += (size_t)length;
    } else {
      int value = lzbrrc_decode_tree(&decoder, LZBRRC_LITERAL_MODEL, 256, 4);
      if ((!decoder.ok) || (out_position >= out_size)) {
        return 0;
      }
      out[out_position++] = (uint8_t)value;
      last_was_match = 0;
    }
    flag = lzbrrc_decode_bit(&decoder, LZBRRC_FLAG_MODEL + (last_was_match & 1), 5);
  }
  return out_position;
}

// Assemble a frame payload from the per-plane block sizes, the optional coded motion vectors, and the
// concatenated block data. mv_data/mv_length are 0 for I-frames and non-motion / coefdiff frames.
// block_count is per-plane (chroma has fewer blocks when subsampled). For 4:4:4 all three are equal, so
// the on-wire bytes are identical to the old single-count format (the leading u32 stays = luma count).
static size_t assemble_frame(const int *block_count, uint32_t **sizes, const uint8_t *mv_data, size_t mv_length,
                             const uint8_t *data, size_t data_length, uint8_t **out) {
  if (g_plane_bytes) {   // measure the per-plane byte share (luma vs the two chroma planes)
    size_t plane_bytes[3] = { 0, 0, 0 };
    for (int plane = 0; plane < 3; plane++) {
      for (int block = 0; block < block_count[plane]; block++) {
        plane_bytes[plane] += sizes[plane][block];
      }
    }
    size_t chroma = plane_bytes[1] + plane_bytes[2];
    size_t total = plane_bytes[0] + chroma;
    fprintf(stderr, "  plane bytes: Y=%zu Co=%zu Cg=%zu | chroma=%zu (%.1f%% of data)\n",
            plane_bytes[0], plane_bytes[1], plane_bytes[2], chroma, total ? ((100.0 * chroma) / total) : 0.0);
  }
  // Code the per-block byte sizes with unsigned Exp-Golomb (was raw u16 = ~16% of a frame at 32x32; the
  // sizes are small and clustered so this shrinks the table several-fold, and it also lifts the u16 cap).
  BitWriter size_writer;
  bitwriter_init(&size_writer);
  for (int plane = 0; plane < 3; plane++) {
    for (int block = 0; block < block_count[plane]; block++) {
      bitwriter_put_unsigned_exp_golomb(&size_writer, sizes[plane][block]);
    }
  }
  bitwriter_flush(&size_writer);
  uint32_t size_blob_length = (uint32_t)size_writer.length;
  size_t header_size = (((((4 + 4) + size_blob_length) + 4) + mv_length) + 4);
  size_t total_size = header_size + data_length;
  uint8_t *frame = checked_malloc(total_size);
  size_t cursor = 0;
  memcpy(frame + cursor, &(uint32_t){ (uint32_t)block_count[0] }, 4);
  cursor += 4;
  memcpy(frame + cursor, &size_blob_length, 4);
  cursor += 4;
  memcpy(frame + cursor, size_writer.bytes, size_blob_length);
  cursor += size_blob_length;
  free(size_writer.bytes);
  memcpy(frame + cursor, &(uint32_t){ (uint32_t)mv_length }, 4);
  cursor += 4;
  if (mv_length) {
    memcpy(frame + cursor, mv_data, mv_length);
    cursor += mv_length;
  }
  memcpy(frame + cursor, &(uint32_t){ (uint32_t)data_length }, 4);
  cursor += 4;
  memcpy(frame + cursor, data, data_length);
  *out = frame;
  return total_size;
}

// Parse a frame payload header: prefix-sum the per-plane u16 sizes into the (continuous) per-plane
// offset arrays, hand back the coded motion-vector blob (if any), and return a pointer to the block data.
// block_count is per-plane (caller computes it from chroma_format + dims, since it is not stored per frame).
static const uint8_t *parse_frame_header(const uint8_t *frame, const int *block_count, int *out_block_count, uint32_t *offsets[3],
                                         const uint8_t **out_mv_data, uint32_t *out_mv_length) {
  uint32_t leading_count;
  memcpy(&leading_count, frame, 4);   // = luma block_count (sanity; the per-plane counts come from the caller)
  *out_block_count = (int)leading_count;
  size_t cursor = 4;
  uint32_t size_blob_length;
  memcpy(&size_blob_length, frame + cursor, 4);   // unsigned-Exp-Golomb-coded per-block byte sizes
  cursor += 4;
  BitReader size_reader;
  bitreader_init(&size_reader, frame + cursor, size_blob_length);
  uint32_t running = 0;
  for (int plane = 0; plane < 3; plane++) {
    for (int block = 0; block < block_count[plane]; block++) {
      offsets[plane][block] = running;
      running += bitreader_get_unsigned_exp_golomb(&size_reader);
    }
  }
  cursor += size_blob_length;
  uint32_t mv_length;
  memcpy(&mv_length, frame + cursor, 4);
  cursor += 4;
  *out_mv_data = frame + cursor;
  *out_mv_length = mv_length;
  cursor += mv_length;
  cursor += 4;   // skip the data_length field
  return frame + cursor;
}
// previous_coefficients (3 planes) is the reference for a P-frame: if is_predicted, the coefficient-
// domain difference (current - previous) is coded; either way this frame's (un-diffed) coefficients
// are saved back into it as the next frame's reference. Pass NULL / 0 for a stateless intra encode.
static size_t encode_frame_coefdiff(const uint8_t *rgb, int width, int height, int levels, int base_quality, uint8_t **out,
                           int32_t **previous_coefficients, int is_predicted) {
  int pixel_count = width * height;
  int block_count = block_count_x(width) * block_count_y(height);
  int32_t *luma = checked_malloc(pixel_count * 4);
  int32_t *chroma_orange = checked_malloc(pixel_count * 4);
  int32_t *chroma_green = checked_malloc(pixel_count * 4);
  float *float_plane = checked_malloc(pixel_count * sizeof(float));
  int *step = checked_malloc(pixel_count * sizeof(int));
  int32_t *diff_buffer = is_predicted ? checked_malloc((size_t)pixel_count * 4) : NULL;

  rgb_to_ycocg(rgb, luma, chroma_orange, chroma_green, pixel_count);
  build_quantization_steps(step, width, height, levels, base_quality);

  BitWriter writer;
  bitwriter_init(&writer);
  int32_t *planes[3] = { luma, chroma_orange, chroma_green };
  uint32_t *offsets[3];
  for (int plane = 0; plane < 3; plane++) {
    if (base_quality == 0) {
      // Lossless: reversible 5/3 integer transform, coefficients stay integer, no quant.
      forward_legall53_2d(planes[plane], width, height, levels);
    } else {
      // Lossy: 9/7 float transform, then quantize back to integer coefficients.
      for (int i = 0; i < pixel_count; i++) {
        float_plane[i] = (float)planes[plane][i];
      }
      forward_dwt_2d(float_plane, width, height, levels);
      quantize(float_plane, planes[plane], step, pixel_count, (plane == 0) ? 1.0f : g_chroma_quant);
    }
    offsets[plane] = checked_malloc((size_t)block_count * 4);
    // P-frame: code the coefficient-domain difference against the previous frame's coefficients.
    const int32_t *encode_source = planes[plane];
    if (is_predicted) {
      for (int i = 0; i < pixel_count; i++) {
        diff_buffer[i] = planes[plane][i] - previous_coefficients[plane][i];
      }
      encode_source = diff_buffer;
    }
    encode_plane(&writer, encode_source, width, height, offsets[plane]);
    // Save this frame's (un-diffed) coefficients as the reference for the next frame.
    if (previous_coefficients) {
      memcpy(previous_coefficients[plane], planes[plane], (size_t)pixel_count * 4);
    }
  }

  uint8_t *output;
  size_t total_size = assemble_frame((int[3]){ block_count, block_count, block_count }, offsets, NULL, 0, writer.bytes, writer.length, &output);   // coefdiff: 4:4:4 only

  free(luma);
  free(chroma_orange);
  free(chroma_green);
  free(float_plane);
  free(step);
  free(diff_buffer);
  free(writer.bytes);
  free(offsets[0]);
  free(offsets[1]);
  free(offsets[2]);
  *out = output;
  return total_size;
}

// previous_coefficients (3 planes) is the P-frame reference: if is_predicted, the unpacked
// difference is added to it; either way this frame's reconstructed coefficients are saved back into
// it (before the in-place inverse transform) as the next frame's reference. NULL / 0 = intra.
static void decode_frame_coefdiff(const uint8_t *frame, size_t length, int width, int height, int levels, int base_quality, uint8_t *rgb,
                         int32_t **previous_coefficients, int is_predicted) {
  (void)length;
  int pixel_count = width * height;
  int32_t *luma = checked_malloc(pixel_count * 4);
  int32_t *chroma_orange = checked_malloc(pixel_count * 4);
  int32_t *chroma_green = checked_malloc(pixel_count * 4);
  float *float_plane = checked_malloc(pixel_count * sizeof(float));
  int *step = checked_malloc(pixel_count * sizeof(int));

  build_quantization_steps(step, width, height, levels, base_quality);

  int block_count = block_count_x(width) * block_count_y(height);
  uint32_t *offsets[3];
  for (int plane = 0; plane < 3; plane++) {
    offsets[plane] = checked_malloc((size_t)block_count * 4);
  }
  int parsed_block_count;
  const uint8_t *mv_data;
  uint32_t mv_length;
  const uint8_t *data = parse_frame_header(frame, (int[3]){ block_count, block_count, block_count }, &parsed_block_count, offsets, &mv_data, &mv_length);   // coefdiff: 4:4:4
  (void)mv_data;
  (void)mv_length;

  int32_t *planes[3] = { luma, chroma_orange, chroma_green };
  for (int plane = 0; plane < 3; plane++) {
    decode_plane(data, offsets[plane], planes[plane], width, height);
    // P-frame: add the previous frame's coefficients back to the decoded difference.
    if (is_predicted) {
      for (int i = 0; i < pixel_count; i++) {
        planes[plane][i] += previous_coefficients[plane][i];
      }
    }
    // Save this frame's reconstructed coefficients before the in-place inverse transform destroys them.
    if (previous_coefficients) {
      memcpy(previous_coefficients[plane], planes[plane], (size_t)pixel_count * 4);
    }
    if (base_quality == 0) {
      inverse_legall53_2d(planes[plane], width, height, levels);
    } else {
      dequantize(planes[plane], float_plane, step, pixel_count, (plane == 0) ? 1.0f : g_chroma_quant);
      inverse_dwt_2d(float_plane, width, height, levels);
      for (int i = 0; i < pixel_count; i++) {
        planes[plane][i] = (int)lrintf(float_plane[i]);
      }
    }
  }
  ycocg_to_rgb(luma, chroma_orange, chroma_green, rgb, pixel_count);

  free(luma);
  free(chroma_orange);
  free(chroma_green);
  free(float_plane);
  free(step);
  free(offsets[0]);
  free(offsets[1]);
  free(offsets[2]);
}

// ---------------------------------------------------- variant B: pixel-domain (YCoCg) prediction
// Instead of differencing the wavelet coefficients (variant A above), B differences the YCoCg pixels
// BEFORE the transform: source = current - previous (for a P-frame), then transform/quant/code that
// residual. The reference `previous_ycocg` holds the *reconstructed* YCoCg of the previous frame, so
// the loop is closed (encoder reconstructs exactly what the decoder will) and lossy mode does not
// drift. B works for any quality; for Q0 it is bit-exact like A (just differenced pre-transform).

// Reconstruct one plane in place: quantised coefficients -> reconstructed YCoCg samples.
static void reconstruct_plane(int32_t *coefficients, float *float_plane, const int *step, int width, int height, int levels, int base_quality, float chroma_multiplier) {
  if (base_quality == 0) {
    inverse_legall53_2d(coefficients, width, height, levels);
  } else {
    dequantize(coefficients, float_plane, step, width * height, chroma_multiplier);
    inverse_dwt_2d(float_plane, width, height, levels);
    for (int i = 0; i < width * height; i++) {
      coefficients[i] = (int)lrintf(float_plane[i]);
    }
  }
}

static size_t encode_frame_colordiff(const uint8_t *rgb, int width, int height, int levels, int base_quality, uint8_t **out,
                             int32_t **previous_ycocg, int is_predicted) {
  int pixel_count = width * height;
  int32_t *luma = checked_malloc(pixel_count * 4);
  int32_t *chroma_orange = checked_malloc(pixel_count * 4);
  int32_t *chroma_green = checked_malloc(pixel_count * 4);
  float *float_plane = checked_malloc(pixel_count * sizeof(float));
  int *step = checked_malloc(pixel_count * sizeof(int));
  int32_t *source = checked_malloc(pixel_count * 4);   // residual (P) or current (I), transformed in place
  int32_t *recon = checked_malloc(pixel_count * 4);    // closed-loop reconstruction scratch
  // Motion: one [mv_x, mv_y] per 16x16 block. The CPU reference does no search, so the vectors are all
  // zero (mc_previous == previous == plain colordiff); the GPU encoder supplies real ones in step 2.
  int motion_blocks_x = ((width + MOTION_BLOCK) - 1) / MOTION_BLOCK, motion_blocks_y = ((height + MOTION_BLOCK) - 1) / MOTION_BLOCK;
  int *mv = checked_malloc((((size_t)motion_blocks_x * motion_blocks_y) * 2) * sizeof(int));
  int32_t *mc_previous = checked_malloc(pixel_count * 4);
  memset(mv, 0, (((size_t)motion_blocks_x * motion_blocks_y) * 2) * sizeof(int));

  rgb_to_ycocg(rgb, luma, chroma_orange, chroma_green, pixel_count);
  if (g_chroma_format != 0) {   // subsample Co/Cg to their plane size in place (decoder upsamples); lossy
    downsample_chroma(chroma_orange, chroma_orange, width, height);
    downsample_chroma(chroma_green, chroma_green, width, height);
  }

  BitWriter writer;
  bitwriter_init(&writer);
  int32_t *planes[3] = { luma, chroma_orange, chroma_green };
  uint32_t *offsets[3];
  int block_counts[3];   // per-plane (chroma fewer when subsampled); 4:4:4 -> all equal
  double pcrd_lambda = (base_quality > 0) ? g_pcrd_lambda : 0.0;   // --pcrd (0 = off, the default)
  for (int plane = 0; plane < 3; plane++) {
    int plane_w = plane_width(plane, width);
    int plane_h = plane_height(plane, height);
    int plane_pixels = plane_w * plane_h;
    int plane_motion_blocks_x = ((plane_w + MOTION_BLOCK) - 1) / MOTION_BLOCK;
    block_counts[plane] = block_count_x(plane_w) * block_count_y(plane_h);
    build_quantization_steps(step, plane_w, plane_h, levels, base_quality);
    // Motion-compensate the previous reconstructed frame, then take the pixel-domain residual.
    if (is_predicted) {
      motion_compensate(previous_ycocg[plane], mv, mc_previous, plane_w, plane_h, plane_motion_blocks_x);
    }
    for (int i = 0; i < plane_pixels; i++) {
      source[i] = is_predicted ? (planes[plane][i] - mc_previous[i]) : planes[plane][i];
    }
    // Transform + quantize the residual.
    if (base_quality == 0) {
      forward_legall53_2d(source, plane_w, plane_h, levels);
    } else {
      for (int i = 0; i < plane_pixels; i++) {
        float_plane[i] = (float)source[i];
      }
      forward_dwt_2d(float_plane, plane_w, plane_h, levels);
      quantize(float_plane, source, step, plane_pixels, (plane == 0) ? 1.0f : g_chroma_quant);
    }
    offsets[plane] = checked_malloc((size_t)block_counts[plane] * 4);
    apply_pcrd(source, plane_w, plane_h, pcrd_lambda);   // R-D truncate the least-worthwhile low bit-planes per block
    encode_plane(&writer, source, plane_w, plane_h, offsets[plane]);
    // Closed loop: reconstruct exactly what the decoder will, save it as the next reference.
    memcpy(recon, source, (size_t)plane_pixels * 4);
    reconstruct_plane(recon, float_plane, step, plane_w, plane_h, levels, base_quality, (plane == 0) ? 1.0f : g_chroma_quant);
    if (is_predicted) {
      for (int i = 0; i < plane_pixels; i++) {
        recon[i] += mc_previous[i];
      }
    }
    if (previous_ycocg) {
      memcpy(previous_ycocg[plane], recon, (size_t)plane_pixels * 4);   // reference for the next frame (NULL when stateless/all-intra)
    }
  }

  // Code the motion vectors (P-frame only; all-zero here -> a few bytes).
  uint8_t *mv_bytes = NULL;
  size_t mv_length = 0;
  if (is_predicted) {
    if (g_mv_codec == 1) {
      mv_length = mv_blob_encode_range(&mv_bytes, 0, NULL, 0, mv, 0, NULL, g_motion_variable, motion_blocks_x, motion_blocks_y);
    } else {
      BitWriter mv_writer;
      bitwriter_init(&mv_writer);
      if (g_motion_variable) {   // variable mode: motion_blocks_x/y are the fine 8-grid dims (g_motion_block forced to 8)
        encode_motion_quadtree(&mv_writer, mv, motion_blocks_x, motion_blocks_y);
      } else {
        encode_motion_vectors(&mv_writer, mv, motion_blocks_x, motion_blocks_y);
      }
      bitwriter_flush(&mv_writer);
      mv_bytes = mv_writer.bytes;
      mv_length = mv_writer.length;
    }
  }
  uint8_t *output;
  size_t total_size = assemble_frame(block_counts, offsets, mv_bytes, mv_length, writer.bytes, writer.length, &output);   // offsets[] holds per-block sizes
  free(mv_bytes);

  free(luma);
  free(chroma_orange);
  free(chroma_green);
  free(float_plane);
  free(step);
  free(source);
  free(recon);
  free(mv);
  free(mc_previous);
  free(writer.bytes);
  free(offsets[0]);
  free(offsets[1]);
  free(offsets[2]);
  *out = output;
  return total_size;
}

static void decode_frame_colordiff(const uint8_t *frame, size_t length, int width, int height, int levels, int base_quality, uint8_t *rgb,
                           int32_t **previous_ycocg, int is_predicted) {
  (void)length;
  int pixel_count = width * height;
  int32_t *luma = checked_malloc(pixel_count * 4);
  int32_t *chroma_orange = checked_malloc(pixel_count * 4);
  int32_t *chroma_green = checked_malloc(pixel_count * 4);
  float *float_plane = checked_malloc(pixel_count * sizeof(float));
  int *step = checked_malloc(pixel_count * sizeof(int));

  int block_counts[3];
  for (int p = 0; p < 3; p++) {
    block_counts[p] = block_count_x(plane_width(p, width)) * block_count_y(plane_height(p, height));
  }
  uint32_t *offsets[3];
  for (int plane = 0; plane < 3; plane++) {
    offsets[plane] = checked_malloc((size_t)block_counts[plane] * 4);
  }
  int parsed_block_count;
  const uint8_t *mv_data;
  uint32_t mv_length;
  const uint8_t *data = parse_frame_header(frame, block_counts, &parsed_block_count, offsets, &mv_data, &mv_length);

  // Decode the per-16x16-block motion vectors (P-frame) and motion-compensate the previous frame.
  int motion_blocks_x = ((width + MOTION_BLOCK) - 1) / MOTION_BLOCK, motion_blocks_y = ((height + MOTION_BLOCK) - 1) / MOTION_BLOCK;
  int *mv = checked_malloc((((size_t)motion_blocks_x * motion_blocks_y) * 2) * sizeof(int));
  int32_t *mc_previous = checked_malloc((size_t)pixel_count * 4);
  memset(mv, 0, (((size_t)motion_blocks_x * motion_blocks_y) * 2) * sizeof(int));
  if (is_predicted && mv_length) {
    if (g_mv_codec == 1) {
      mv_blob_decode_range(mv_data, mv_length, 0, NULL, 0, mv, 0, NULL, g_motion_variable, motion_blocks_x, motion_blocks_y);
    } else {
      BitReader mv_reader;
      bitreader_init(&mv_reader, mv_data, mv_length);
      if (g_motion_variable) {   // variable mode: expand the quadtree into the fine 8-grid mv field
        decode_motion_quadtree(&mv_reader, mv, motion_blocks_x, motion_blocks_y);
      } else {
        decode_motion_vectors(&mv_reader, mv, motion_blocks_x, motion_blocks_y);
      }
    }
  }

  int32_t *planes[3] = { luma, chroma_orange, chroma_green };
  for (int plane = 0; plane < 3; plane++) {
    int plane_w = plane_width(plane, width);
    int plane_h = plane_height(plane, height);
    int plane_pixels = plane_w * plane_h;
    int plane_motion_blocks_x = ((plane_w + MOTION_BLOCK) - 1) / MOTION_BLOCK;
    build_quantization_steps(step, plane_w, plane_h, levels, base_quality);
    decode_plane(data, offsets[plane], planes[plane], plane_w, plane_h);
    reconstruct_plane(planes[plane], float_plane, step, plane_w, plane_h, levels, base_quality, (plane == 0) ? 1.0f : g_chroma_quant);   // -> residual (P) or current (I)
    if (is_predicted) {
      motion_compensate(previous_ycocg[plane], mv, mc_previous, plane_w, plane_h, plane_motion_blocks_x);
      for (int i = 0; i < plane_pixels; i++) {
        planes[plane][i] += mc_previous[i];   // add the motion-compensated previous reconstructed frame
      }
    }
    if (previous_ycocg) {
      memcpy(previous_ycocg[plane], planes[plane], (size_t)plane_pixels * 4);   // this reconstructed frame is the next reference
    }
  }
  // Upsample subsampled chroma back to full resolution (4:4:4 is a no-op path), then YCoCg-R -> RGB.
  int32_t *co_full = chroma_orange, *cg_full = chroma_green;
  int32_t *co_temp = NULL, *cg_temp = NULL;
  if (g_chroma_format != 0) {
    co_temp = checked_malloc((size_t)pixel_count * 4);
    cg_temp = checked_malloc((size_t)pixel_count * 4);
    upsample_chroma(chroma_orange, co_temp, width, height);
    upsample_chroma(chroma_green, cg_temp, width, height);
    co_full = co_temp;
    cg_full = cg_temp;
  }
  ycocg_to_rgb(luma, co_full, cg_full, rgb, pixel_count);
  free(co_temp);
  free(cg_temp);

  free(luma);
  free(chroma_orange);
  free(chroma_green);
  free(float_plane);
  free(step);
  free(mv);
  free(mc_previous);
  free(offsets[0]);
  free(offsets[1]);
  free(offsets[2]);
}

// ------------------------------------------------ bidirectional (B-frame) colordiff codec
// Generalises colordiff to a WEIGHTED prediction from up to two reconstructed-YCoCg references:
//   ref0 && ref1 -> B-frame  (pred = (w0*ref0 + w1*ref1 + 128) >> 8, weights by temporal distance)
//   ref0 only    -> P-frame  (pred = ref0)
//   neither      -> I-frame  (pred = 0)
// recon_out[3] receives this frame's reconstruction so the caller can keep it in the DPB (hierarchical B
// are references). This CPU reference uses ZERO motion (MC == identity); the GPU encoder adds real motion.
static size_t encode_frame_bidi(const uint8_t *rgb, int width, int height, int levels, int base_quality,
                                int32_t **ref0, int32_t **ref1, int weight0, int weight1,
                                int32_t **recon_out, uint8_t **out) {
  int pixel_count = width * height;
  int32_t *luma = checked_malloc(pixel_count * 4);
  int32_t *chroma_orange = checked_malloc(pixel_count * 4);
  int32_t *chroma_green = checked_malloc(pixel_count * 4);
  float *float_plane = checked_malloc(pixel_count * sizeof(float));
  int *step = checked_malloc(pixel_count * sizeof(int));
  int32_t *source = checked_malloc(pixel_count * 4);
  int32_t *recon = checked_malloc(pixel_count * 4);
  int32_t *prediction = checked_malloc(pixel_count * 4);

  rgb_to_ycocg(rgb, luma, chroma_orange, chroma_green, pixel_count);
  if (g_chroma_format != 0) {
    downsample_chroma(chroma_orange, chroma_orange, width, height);
    downsample_chroma(chroma_green, chroma_green, width, height);
  }

  BitWriter writer;
  bitwriter_init(&writer);
  int32_t *planes[3] = { luma, chroma_orange, chroma_green };
  uint32_t *offsets[3];
  int block_counts[3];
  int has_prediction = (ref0 != NULL);
  double pcrd_lambda = (base_quality > 0) ? g_pcrd_lambda : 0.0;
  for (int plane = 0; plane < 3; plane++) {
    int plane_w = plane_width(plane, width), plane_h = plane_height(plane, height);
    int plane_pixels = plane_w * plane_h;
    block_counts[plane] = block_count_x(plane_w) * block_count_y(plane_h);
    build_quantization_steps(step, plane_w, plane_h, levels, base_quality);
    if (has_prediction) {
      if (ref1 != NULL) {
        for (int i = 0; i < plane_pixels; i++) {
          prediction[i] = (((weight0 * ref0[plane][i]) + (weight1 * ref1[plane][i])) + 128) >> 8;
        }
      } else {
        for (int i = 0; i < plane_pixels; i++) {
          prediction[i] = ref0[plane][i];
        }
      }
    }
    for (int i = 0; i < plane_pixels; i++) {
      source[i] = has_prediction ? (planes[plane][i] - prediction[i]) : planes[plane][i];
    }
    if (base_quality == 0) {
      forward_legall53_2d(source, plane_w, plane_h, levels);
    } else {
      for (int i = 0; i < plane_pixels; i++) {
        float_plane[i] = (float)source[i];
      }
      forward_dwt_2d(float_plane, plane_w, plane_h, levels);
      quantize(float_plane, source, step, plane_pixels, (plane == 0) ? 1.0f : g_chroma_quant);
    }
    offsets[plane] = checked_malloc((size_t)block_counts[plane] * 4);
    apply_pcrd(source, plane_w, plane_h, pcrd_lambda);
    encode_plane(&writer, source, plane_w, plane_h, offsets[plane]);
    memcpy(recon, source, (size_t)plane_pixels * 4);
    reconstruct_plane(recon, float_plane, step, plane_w, plane_h, levels, base_quality, (plane == 0) ? 1.0f : g_chroma_quant);
    if (has_prediction) {
      for (int i = 0; i < plane_pixels; i++) {
        recon[i] += prediction[i];
      }
    }
    if (recon_out) {
      memcpy(recon_out[plane], recon, (size_t)plane_pixels * 4);
    }
  }
  uint8_t *output;
  size_t total_size = assemble_frame(block_counts, offsets, NULL, 0, writer.bytes, writer.length, &output);
  free(luma);
  free(chroma_orange);
  free(chroma_green);
  free(float_plane);
  free(step);
  free(source);
  free(recon);
  free(prediction);
  free(writer.bytes);
  free(offsets[0]);
  free(offsets[1]);
  free(offsets[2]);
  *out = output;
  return total_size;
}

// Decode a bidi/colordiff frame: rebuild the same weighted prediction from ref0/ref1, add the decoded
// residual. recon_out[3] receives the reconstructed YCoCg (for the DPB); rgb (if non-NULL) gets the frame.
static void decode_frame_bidi(const uint8_t *frame, int width, int height, int levels, int base_quality,
                              int32_t **ref0, int32_t **ref1, int weight0, int weight1,
                              int32_t **recon_out, uint8_t *rgb) {
  int pixel_count = width * height;
  int32_t *luma = checked_malloc(pixel_count * 4);
  int32_t *chroma_orange = checked_malloc(pixel_count * 4);
  int32_t *chroma_green = checked_malloc(pixel_count * 4);
  float *float_plane = checked_malloc(pixel_count * sizeof(float));
  int *step = checked_malloc(pixel_count * sizeof(int));
  int block_counts[3];
  for (int p = 0; p < 3; p++) {
    block_counts[p] = block_count_x(plane_width(p, width)) * block_count_y(plane_height(p, height));
  }
  uint32_t *offsets[3];
  for (int plane = 0; plane < 3; plane++) {
    offsets[plane] = checked_malloc((size_t)block_counts[plane] * 4);
  }
  int parsed_block_count;
  const uint8_t *mv_data;
  uint32_t mv_length;
  const uint8_t *data = parse_frame_header(frame, block_counts, &parsed_block_count, offsets, &mv_data, &mv_length);
  (void)mv_data;
  (void)mv_length;
  int has_prediction = (ref0 != NULL);
  int32_t *planes[3] = { luma, chroma_orange, chroma_green };
  for (int plane = 0; plane < 3; plane++) {
    int plane_w = plane_width(plane, width), plane_h = plane_height(plane, height);
    int plane_pixels = plane_w * plane_h;
    build_quantization_steps(step, plane_w, plane_h, levels, base_quality);
    decode_plane(data, offsets[plane], planes[plane], plane_w, plane_h);
    reconstruct_plane(planes[plane], float_plane, step, plane_w, plane_h, levels, base_quality, (plane == 0) ? 1.0f : g_chroma_quant);
    if (has_prediction) {
      if (ref1 != NULL) {
        for (int i = 0; i < plane_pixels; i++) {
          planes[plane][i] += ((((weight0 * ref0[plane][i]) + (weight1 * ref1[plane][i])) + 128) >> 8);
        }
      } else {
        for (int i = 0; i < plane_pixels; i++) {
          planes[plane][i] += ref0[plane][i];
        }
      }
    }
    if (recon_out) {
      memcpy(recon_out[plane], planes[plane], (size_t)plane_pixels * 4);
    }
  }
  if (rgb) {
    int32_t *co_full = chroma_orange, *cg_full = chroma_green, *co_temp = NULL, *cg_temp = NULL;
    if (g_chroma_format != 0) {
      co_temp = checked_malloc((size_t)pixel_count * 4);
      cg_temp = checked_malloc((size_t)pixel_count * 4);
      upsample_chroma(chroma_orange, co_temp, width, height);
      upsample_chroma(chroma_green, cg_temp, width, height);
      co_full = co_temp;
      cg_full = cg_temp;
    }
    ycocg_to_rgb(luma, co_full, cg_full, rgb, pixel_count);
    free(co_temp);
    free(cg_temp);
  }
  free(luma);
  free(chroma_orange);
  free(chroma_green);
  free(float_plane);
  free(step);
  free(offsets[0]);
  free(offsets[1]);
  free(offsets[2]);
}

// hierarchical-B coding-order builder, SHARED by the GPU encoder (fwvenc.c) and the
// bframetest oracle below, so both construct the identical dyadic structure. One CodeStep = encode (or
// decode) the frame at display position `poc` from up to two references (poc indices here; -1 = none).
// weight0/weight1 are the temporal-distance blend weights (/256); temporal_id is the hierarchy depth
// (0 = anchor) for QP-cascading. The container stores the references as CODING-order indices and derives
// the weights back from the stored POCs, so no weight is written to disk.
typedef struct {
  int poc, ref0, ref1, weight0, weight1, temporal_id;   // ref* = -1 for none; weights /256 by temporal distance
} CodeStep;

// Append the hierarchical B-frames between two already-coded anchors [lo, hi] (dyadic midpoint
// recursion); depth is the temporal hierarchy level of the midpoint (the anchors themselves are 0).
static void build_b_range(CodeStep *steps, int *count, int lo, int hi, int depth) {
  if ((hi - lo) <= 1) {
    return;
  }
  int mid = (lo + hi) / 2;
  int weight0 = (256 * (hi - mid)) / (hi - lo);   // the temporally closer reference gets the larger weight
  steps[*count] = (CodeStep){ mid, lo, hi, weight0, 256 - weight0, depth };
  (*count)++;
  build_b_range(steps, count, lo, mid, depth + 1);
  build_b_range(steps, count, mid, hi, depth + 1);
}

// ----------------------------------------------------- 3D-DWT GOP codec
/* Encode a GOP of num_frames RGB frames with the temporal-then-spatial 3D-DWT. The temporal
 * transform couples the frames; the result is num_frames independent temporal-subband-frame
 * payloads (same on-wire layout as an intra coefdiff frame: 4:4:4, no motion vectors), returned in
 * out[]/out_len[]. The caller writes them to the container in order. GOP is 4:4:4 only for now
 * (chroma subsampling is ignored), keeping the first cut simple. */
#define MAX_GOP 64
static void encode_gop_3ddwt(uint8_t **rgb_frames, int num_frames, int width, int height,
                             int levels, int base_quality, uint8_t **out, size_t *out_len) {
  int pixel_count = width * height;
  int lossless = (base_quality == 0);
  int temporal_wavelet = g_temporal_wavelet;
  if (lossless && (temporal_wavelet == 2)) {
    temporal_wavelet = 1;   // 9/7 is float-only; the lossless path uses integer 5/3 along time
  }
  // MCTF (motion-compensated temporal filtering, --mctf): the temporal transform runs as an INTEGER frame-level
  // predict-only MC-Haar, so the temporal-domain frames are integer even in the lossy path (converted to float at the
  // spatial step). Each high-pass frame carries an MV field. int_temporal = the temporal frames are int. Chroma
  // subsampling (4:2:2 / 4:2:0) is handled per-plane in mctf_forward/inverse (luma motion, plane-sized warp).
  int int_temporal = lossless || g_mctf;
  int motion_blocks_x = ((width + MOTION_BLOCK) - 1) / MOTION_BLOCK;
  int motion_blocks_y = ((height + MOTION_BLOCK) - 1) / MOTION_BLOCK;
  int motion_blocks = motion_blocks_x * motion_blocks_y;
  int *frame_mv = g_mctf ? checked_malloc(((size_t)num_frames * motion_blocks * 2) * sizeof(int)) : NULL;

  // Per-plane dimensions: luma full-res, chroma subsampled when g_chroma_format != 0 (Q0 stays 4:4:4).
  int plane_w[3], plane_h[3], plane_pixels[3], plane_blocks[3];
  for (int plane = 0; plane < 3; plane++) {
    plane_w[plane] = plane_width(plane, width);
    plane_h[plane] = plane_height(plane, height);
    plane_pixels[plane] = plane_w[plane] * plane_h[plane];
    plane_blocks[plane] = block_count_x(plane_w[plane]) * block_count_y(plane_h[plane]);
  }

  // GOP planes laid out as [plane][(frame * plane_pixels) + pixel]: integers when int_temporal, float otherwise.
  int32_t *gop_int[3] = { NULL, NULL, NULL };
  float *gop_float[3] = { NULL, NULL, NULL };
  for (int plane = 0; plane < 3; plane++) {
    if (int_temporal) {
      gop_int[plane] = checked_malloc(((size_t)num_frames * plane_pixels[plane]) * 4);
    } else {
      gop_float[plane] = checked_malloc(((size_t)num_frames * plane_pixels[plane]) * sizeof(float));
    }
  }

  // 1) colour-transform every frame; chroma is down-sampled to its plane size (4:4:4 -> a no-op).
  int32_t *luma = checked_malloc((size_t)pixel_count * 4);
  int32_t *chroma_orange = checked_malloc((size_t)pixel_count * 4);
  int32_t *chroma_green = checked_malloc((size_t)pixel_count * 4);
  for (int f = 0; f < num_frames; f++) {
    rgb_to_ycocg(rgb_frames[f], luma, chroma_orange, chroma_green, pixel_count);
    if (g_chroma_format != 0) {   // box-average Co/Cg down to their subsampled plane size, in place
      downsample_chroma(chroma_orange, chroma_orange, width, height);
      downsample_chroma(chroma_green, chroma_green, width, height);
    }
    int32_t *src[3] = { luma, chroma_orange, chroma_green };
    for (int plane = 0; plane < 3; plane++) {
      size_t base = (size_t)f * plane_pixels[plane];
      if (int_temporal) {
        memcpy(gop_int[plane] + base, src[plane], (size_t)plane_pixels[plane] * 4);
      } else {
        for (int i = 0; i < plane_pixels[plane]; i++) {
          gop_float[plane][base + i] = (float)src[plane][i];
        }
      }
    }
  }
  free(luma);
  free(chroma_orange);
  free(chroma_green);

  // 2) temporal transform across the frames. MCTF = integer frame-level MC-Haar (motion-aligned); otherwise the
  // open-loop per-pixel-column wavelet (no motion). MCTF stores each high-pass frame's MV field in frame_mv.
  if (g_mctf) {
    mctf_forward(gop_int, num_frames, plane_w, plane_h, plane_pixels, g_temporal_levels, frame_mv, motion_blocks_x, motion_blocks_y);
  } else if (lossless) {
    int32_t temporal_line[MAX_GOP];
    for (int plane = 0; plane < 3; plane++) {
      int pp = plane_pixels[plane];
      for (int i = 0; i < pp; i++) {
        for (int f = 0; f < num_frames; f++) {
          temporal_line[f] = gop_int[plane][((size_t)f * pp) + i];
        }
        temporal_forward_int(temporal_line, num_frames, g_temporal_levels, temporal_wavelet);
        for (int f = 0; f < num_frames; f++) {
          gop_int[plane][((size_t)f * pp) + i] = temporal_line[f];
        }
      }
    }
  } else {
    float temporal_line[MAX_GOP];
    for (int plane = 0; plane < 3; plane++) {
      int pp = plane_pixels[plane];
      for (int i = 0; i < pp; i++) {
        for (int f = 0; f < num_frames; f++) {
          temporal_line[f] = gop_float[plane][((size_t)f * pp) + i];
        }
        temporal_forward_float(temporal_line, num_frames, g_temporal_levels, temporal_wavelet);
        for (int f = 0; f < num_frames; f++) {
          gop_float[plane][((size_t)f * pp) + i] = temporal_line[f];
        }
      }
    }
  }

  // 3) per temporal-subband frame: spatial transform + quant + bit-plane code -> a frame payload.
  int *step = checked_malloc((size_t)pixel_count * sizeof(int));
  float *float_plane = checked_malloc((size_t)pixel_count * sizeof(float));
  int32_t *coefficients = checked_malloc((size_t)pixel_count * 4);
  for (int f = 0; f < num_frames; f++) {
    int level = temporal_quant_level(f, num_frames, g_temporal_levels);
    int effective_quality = lossless ? 0 : (int)(((float)base_quality * temporal_quant_scale(level)) + 0.5f);
    if (!lossless && (effective_quality < 1)) {
      effective_quality = 1;
    }

    BitWriter writer;
    bitwriter_init(&writer);
    uint32_t *offsets[3];
    for (int plane = 0; plane < 3; plane++) {
      int pw = plane_w[plane], ph = plane_h[plane], pp = plane_pixels[plane];
      offsets[plane] = checked_malloc((size_t)plane_blocks[plane] * 4);
      if (lossless) {
        memcpy(coefficients, gop_int[plane] + ((size_t)f * pp), (size_t)pp * 4);
        forward_legall53_2d(coefficients, pw, ph, levels);
      } else {
        build_quantization_steps(step, pw, ph, levels, effective_quality);
        if (g_mctf) {
          for (int i = 0; i < pp; i++) {
            float_plane[i] = (float)gop_int[plane][((size_t)f * pp) + i];   // MCTF temporal-subband frames are integer
          }
        } else {
          memcpy(float_plane, gop_float[plane] + ((size_t)f * pp), (size_t)pp * sizeof(float));
        }
        forward_dwt_2d(float_plane, pw, ph, levels);
        quantize(float_plane, coefficients, step, pp, (plane == 0) ? 1.0f : g_chroma_quant);
      }
      encode_plane(&writer, coefficients, pw, ph, offsets[plane]);
    }
    uint8_t *mv_blob = NULL;
    size_t mv_blob_length = 0;
    if (g_mctf && (level > 0)) {   // high-pass frames carry their MV field; the deepest temporal-low (level 0) has none
      const int *fmv = &frame_mv[((size_t)f * motion_blocks) * 2];
      if (g_mv_codec == 1) {
        mv_blob_length = mv_blob_encode_range(&mv_blob, 0, NULL, 0, fmv, 0, NULL, 0, motion_blocks_x, motion_blocks_y);
      } else {
        BitWriter mv_writer;
        bitwriter_init(&mv_writer);
        encode_motion_vectors(&mv_writer, fmv, motion_blocks_x, motion_blocks_y);
        bitwriter_flush(&mv_writer);
        mv_blob = mv_writer.bytes;
        mv_blob_length = mv_writer.length;
      }
    }
    out_len[f] = assemble_frame(plane_blocks, offsets, mv_blob, mv_blob_length, writer.bytes, writer.length, &out[f]);
    free(mv_blob);
    free(writer.bytes);
    for (int plane = 0; plane < 3; plane++) {
      free(offsets[plane]);
    }
  }

  free(step);
  free(float_plane);
  free(coefficients);
  free(frame_mv);
  for (int plane = 0; plane < 3; plane++) {
    free(gop_int[plane]);
    free(gop_float[plane]);
  }
}

// Decode a GOP: spatial-inverse each temporal-subband frame, then inverse the temporal transform
// across the frames, then YCoCg-R -> RGB. rgb_out[f] receives the reconstructed frame in display order.
static void decode_gop_3ddwt(uint8_t **frames, size_t *frame_len, int num_frames, int width, int height,
                             int levels, int base_quality, uint8_t **rgb_out) {
  (void)frame_len;
  int pixel_count = width * height;
  int lossless = (base_quality == 0);
  int temporal_wavelet = g_temporal_wavelet;
  if (lossless && (temporal_wavelet == 2)) {
    temporal_wavelet = 1;
  }
  int int_temporal = lossless || g_mctf;   // MCTF temporal frames are integer (see encode_gop_3ddwt)
  int motion_blocks_x = ((width + MOTION_BLOCK) - 1) / MOTION_BLOCK;
  int motion_blocks_y = ((height + MOTION_BLOCK) - 1) / MOTION_BLOCK;
  int motion_blocks = motion_blocks_x * motion_blocks_y;
  int *frame_mv = g_mctf ? checked_malloc(((size_t)num_frames * motion_blocks * 2) * sizeof(int)) : NULL;

  // Per-plane dimensions: luma full-res, chroma subsampled when g_chroma_format != 0.
  int plane_w[3], plane_h[3], plane_pixels[3], plane_blocks[3];
  for (int plane = 0; plane < 3; plane++) {
    plane_w[plane] = plane_width(plane, width);
    plane_h[plane] = plane_height(plane, height);
    plane_pixels[plane] = plane_w[plane] * plane_h[plane];
    plane_blocks[plane] = block_count_x(plane_w[plane]) * block_count_y(plane_h[plane]);
  }

  int32_t *gop_int[3] = { NULL, NULL, NULL };
  float *gop_float[3] = { NULL, NULL, NULL };
  for (int plane = 0; plane < 3; plane++) {
    if (int_temporal) {
      gop_int[plane] = checked_malloc(((size_t)num_frames * plane_pixels[plane]) * 4);
    } else {
      gop_float[plane] = checked_malloc(((size_t)num_frames * plane_pixels[plane]) * sizeof(float));
    }
  }

  // 1) decode each subband frame's coefficients and invert the spatial transform (at each plane's size).
  int *step = checked_malloc((size_t)pixel_count * sizeof(int));
  float *float_plane = checked_malloc((size_t)pixel_count * sizeof(float));
  int32_t *coefficients = checked_malloc((size_t)pixel_count * 4);
  for (int f = 0; f < num_frames; f++) {
    int level = temporal_quant_level(f, num_frames, g_temporal_levels);
    int effective_quality = lossless ? 0 : (int)(((float)base_quality * temporal_quant_scale(level)) + 0.5f);
    if (!lossless && (effective_quality < 1)) {
      effective_quality = 1;
    }

    uint32_t *offsets[3];
    for (int plane = 0; plane < 3; plane++) {
      offsets[plane] = checked_malloc((size_t)plane_blocks[plane] * 4);
    }
    int parsed_block_count;
    const uint8_t *mv_data;
    uint32_t mv_length;
    const uint8_t *data = parse_frame_header(frames[f], plane_blocks, &parsed_block_count, offsets, &mv_data, &mv_length);
    if (g_mctf && (mv_length > 0)) {   // high-pass frame: decode its MV field for the temporal inverse warp
      int *fmv = &frame_mv[((size_t)f * motion_blocks) * 2];
      if (g_mv_codec == 1) {
        mv_blob_decode_range(mv_data, (size_t)mv_length, 0, NULL, 0, fmv, 0, NULL, 0, motion_blocks_x, motion_blocks_y);
      } else {
        BitReader mv_reader;
        bitreader_init(&mv_reader, mv_data, (size_t)mv_length);
        decode_motion_vectors(&mv_reader, fmv, motion_blocks_x, motion_blocks_y);
      }
    }
    for (int plane = 0; plane < 3; plane++) {
      int pw = plane_w[plane], ph = plane_h[plane], pp = plane_pixels[plane];
      decode_plane(data, offsets[plane], coefficients, pw, ph);
      if (lossless) {
        inverse_legall53_2d(coefficients, pw, ph, levels);
        memcpy(gop_int[plane] + ((size_t)f * pp), coefficients, (size_t)pp * 4);
      } else {
        build_quantization_steps(step, pw, ph, levels, effective_quality);
        dequantize(coefficients, float_plane, step, pp, (plane == 0) ? 1.0f : g_chroma_quant);
        inverse_dwt_2d(float_plane, pw, ph, levels);
        if (g_mctf) {
          for (int i = 0; i < pp; i++) {
            gop_int[plane][((size_t)f * pp) + i] = (int32_t)lrintf(float_plane[i]);   // MCTF temporal frames are integer
          }
        } else {
          memcpy(gop_float[plane] + ((size_t)f * pp), float_plane, (size_t)pp * sizeof(float));
        }
      }
    }
    for (int plane = 0; plane < 3; plane++) {
      free(offsets[plane]);
    }
  }
  free(step);
  free(float_plane);
  free(coefficients);

  // 2) inverse temporal transform across the frames. MCTF = integer frame-level MC-Haar inverse (motion); else per-pixel.
  if (g_mctf) {
    mctf_inverse(gop_int, num_frames, plane_w, plane_h, plane_pixels, g_temporal_levels, frame_mv, motion_blocks_x, motion_blocks_y);
  } else if (lossless) {
    int32_t temporal_line[MAX_GOP];
    for (int plane = 0; plane < 3; plane++) {
      int pp = plane_pixels[plane];
      for (int i = 0; i < pp; i++) {
        for (int f = 0; f < num_frames; f++) {
          temporal_line[f] = gop_int[plane][((size_t)f * pp) + i];
        }
        temporal_inverse_int(temporal_line, num_frames, g_temporal_levels, temporal_wavelet);
        for (int f = 0; f < num_frames; f++) {
          gop_int[plane][((size_t)f * pp) + i] = temporal_line[f];
        }
      }
    }
  } else {
    float temporal_line[MAX_GOP];
    for (int plane = 0; plane < 3; plane++) {
      int pp = plane_pixels[plane];
      for (int i = 0; i < pp; i++) {
        for (int f = 0; f < num_frames; f++) {
          temporal_line[f] = gop_float[plane][((size_t)f * pp) + i];
        }
        temporal_inverse_float(temporal_line, num_frames, g_temporal_levels, temporal_wavelet);
        for (int f = 0; f < num_frames; f++) {
          gop_float[plane][((size_t)f * pp) + i] = temporal_line[f];
        }
      }
    }
  }

  // 3) per frame: reconstruct the YCoCg planes, upsample subsampled chroma to full res, YCoCg-R -> RGB.
  int32_t *luma = checked_malloc((size_t)pixel_count * 4);
  int32_t *chroma_orange = checked_malloc((size_t)pixel_count * 4);
  int32_t *chroma_green = checked_malloc((size_t)pixel_count * 4);
  int32_t *co_full = checked_malloc((size_t)pixel_count * 4);
  int32_t *cg_full = checked_malloc((size_t)pixel_count * 4);
  for (int f = 0; f < num_frames; f++) {
    int32_t *dst[3] = { luma, chroma_orange, chroma_green };
    for (int plane = 0; plane < 3; plane++) {
      size_t base = (size_t)f * plane_pixels[plane];
      if (int_temporal) {
        memcpy(dst[plane], gop_int[plane] + base, (size_t)plane_pixels[plane] * 4);
      } else {
        for (int i = 0; i < plane_pixels[plane]; i++) {
          dst[plane][i] = (int)lrintf(gop_float[plane][base + i]);
        }
      }
    }
    int32_t *co = chroma_orange, *cg = chroma_green;
    if (g_chroma_format != 0) {   // bilinear-upsample the subsampled Co/Cg back to full resolution
      upsample_chroma(chroma_orange, co_full, width, height);
      upsample_chroma(chroma_green, cg_full, width, height);
      co = co_full;
      cg = cg_full;
    }
    ycocg_to_rgb(luma, co, cg, rgb_out[f], pixel_count);
  }
  free(luma);
  free(chroma_orange);
  free(chroma_green);
  free(co_full);
  free(cg_full);
  free(frame_mv);
  for (int plane = 0; plane < 3; plane++) {
    free(gop_int[plane]);
    free(gop_float[plane]);
  }
}

// ----------------------------------------------------------------------- ffmpeg input

static int probe_video_dimensions(const char *input, int *width, int *height) {
  char command[4096];
  snprintf(command, sizeof command,
           "ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0:s=x \"%s\"", input);
  FILE *pipe = popen(command, "r");
  if (!pipe) {
    return -1;
  }
  char text[64] = "";
  if (!fgets(text, sizeof text, pipe)) {
    pclose(pipe);
    return -1;
  }
  pclose(pipe);
  return (sscanf(text, "%dx%d", width, height) == 2) ? 0 : -1;
}

#ifndef FWV_NO_MAIN  // define FWV_NO_MAIN to #include this as the codec library (see fwvdec.c)

// HDR self-test: prove the codec carries 16-bit / signed HDR code values losslessly (Q0) and lossily
// (Q8): the PQ-12 HDR mode (non-negative) and a generic signed-16-bit capability check (with negatives).
static double hdr_rmse_16(const int16_t *a, const int16_t *b, int count) {
  double mse = 0.0;
  for (int i = 0; i < count; i++) {
    double d = (double)a[i] - (double)b[i];
    mse += d * d;
  }
  return sqrt(mse / count);
}

static int hdr_selftest(void) {
  int width = 256, height = 256, pixel_count = width * height, sample_count = pixel_count * 3;
  int16_t *source = checked_malloc((size_t)sample_count * sizeof(int16_t));
  int16_t *output = checked_malloc((size_t)sample_count * sizeof(int16_t));
  uint8_t *encoded;
  size_t length;

  // (A) PQ-12: a synthetic HDR ramp (linear up to ~12.5 = 1000 nits at 80-nit white) through PQ to 12-bit.
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int idx = (((y * width) + x) * 3);
      float channel[3] = { ((float)x / width) * 12.5f, ((float)y / height) * 12.5f, ((float)(x + y) / (width + height)) * 12.5f };
      for (int c = 0; c < 3; c++) {
        float linear = (channel[c] * REFERENCE_WHITE_NITS) / PQ_PEAK_NITS;
        source[idx + c] = (int16_t)((pq_encode(linear) * 4095.0f) + 0.5f);
      }
    }
  }
  set_sample_mode(1);   // PQ-12
  length = encode_frame_colordiff((const uint8_t *)source, width, height, 5, 0, &encoded, NULL, 0);
  decode_frame_colordiff(encoded, length, width, height, 5, 0, (uint8_t *)output, NULL, 0);
  int pq_lossless = (memcmp(source, output, (size_t)sample_count * sizeof(int16_t)) == 0);
  free(encoded);
  length = encode_frame_colordiff((const uint8_t *)source, width, height, 5, 8, &encoded, NULL, 0);
  decode_frame_colordiff(encoded, length, width, height, 5, 8, (uint8_t *)output, NULL, 0);
  double pq_q8_rmse = hdr_rmse_16(source, output, sample_count);
  printf("PQ-12    mode: Q0 %s | Q8 RMSE %.1f code (range 0..4095) | %zu bytes Q8\n",
         pq_lossless ? "LOSSLESS" : "MISMATCH", pq_q8_rmse, length);
  free(encoded);

  // (B) signed 16-bit capability: a generic signed-int16 round-trip (with negatives), 1024 scale.
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int idx = (((y * width) + x) * 3);
      float channel[3] = { (((float)x / width) * 12.5f) - 0.3f, (((float)y / height) * 12.5f) - 0.3f, ((float)(x + y) / (width + height)) * 12.5f };
      for (int c = 0; c < 3; c++) {
        source[idx + c] = (int16_t)(channel[c] * SIGNED_TEST_SCALE);
      }
    }
  }
  set_sample_mode(2);   // signed 16-bit
  length = encode_frame_colordiff((const uint8_t *)source, width, height, 5, 0, &encoded, NULL, 0);
  decode_frame_colordiff(encoded, length, width, height, 5, 0, (uint8_t *)output, NULL, 0);
  int signed_lossless = (memcmp(source, output, (size_t)sample_count * sizeof(int16_t)) == 0);
  free(encoded);
  length = encode_frame_colordiff((const uint8_t *)source, width, height, 5, 8, &encoded, NULL, 0);
  decode_frame_colordiff(encoded, length, width, height, 5, 8, (uint8_t *)output, NULL, 0);
  double signed_q8_rmse = hdr_rmse_16(source, output, sample_count);
  printf("signed-16-bit: Q0 %s | Q8 RMSE %.1f code (signed, with negatives) | %zu bytes Q8\n",
         signed_lossless ? "LOSSLESS" : "MISMATCH", signed_q8_rmse, length);
  free(encoded);

  // PQ transfer round-trip sanity (float -> PQ -> 12-bit -> PQ-decode -> float).
  double transfer_mse = 0.0;
  for (int i = 0; i <= 1000; i++) {
    float linear = (float)i / 1000.0f;                              // [0,1] @ 10000 nits
    int code = (int)((pq_encode(linear) * 4095.0f) + 0.5f);
    float back = pq_decode((float)code / 4095.0f);
    transfer_mse += (double)(linear - back) * (linear - back);
  }
  printf("PQ transfer  : float->12bit->float RMSE %.5f (linear, 1=10000 nits)\n", sqrt(transfer_mse / 1001.0));

  set_sample_mode(0);   // restore SDR defaults
  free(source);
  free(output);
  return (pq_lossless && signed_lossless) ? 0 : 1;
}

// HDR transcode demo: ingest a real HDR (PQ/bt2020) video, push it through the fwv codec at 12-bit,
// then tonemap to an SDR sRGB .mp4 you can play. Proves the whole chain on a real HDR source.
//   fwvwave hdr <input> <output.mp4> [quality=0] [frames=8] [exposure=100]
static int hdr_transcode(const char *input, const char *output, int quality, long frames, float exposure) {
  int width = 1920, height = 1080, pixel_count = width * height;   // downscale 4K HDR -> 1080p for the demo
  char command[1024];
  snprintf(command, sizeof command,
           "ffmpeg -v error -i \"%s\" -vf scale=%d:%d -frames:v %ld -f rawvideo -pix_fmt rgb48le -",
           input, width, height, frames);
  FILE *in_pipe = popen(command, "r");
  if (!in_pipe) {
    die("popen ffmpeg (HDR input) failed");
  }
  snprintf(command, sizeof command,
           "ffmpeg -v error -y -f rawvideo -pix_fmt rgb24 -s %dx%d -r 24 -i - -pix_fmt yuv420p \"%s\"",
           width, height, output);
  FILE *out_pipe = popen(command, "w");
  if (!out_pipe) {
    die("popen ffmpeg (SDR output) failed");
  }

  uint16_t *rgb48 = checked_malloc(((size_t)pixel_count * 3) * sizeof(uint16_t));
  int16_t *code = checked_malloc(((size_t)pixel_count * 3) * sizeof(int16_t));
  int16_t *decoded = checked_malloc(((size_t)pixel_count * 3) * sizeof(int16_t));
  uint8_t *srgb = checked_malloc((size_t)pixel_count * 3);

  set_sample_mode(1);   // PQ-12
  int base_quality = quality;   // build_quantization_steps now scales Q by g_sample_white/256 (PQ-12 -> x16)
  long done = 0;
  uint64_t encoded_bytes = 0;
  while (fread(rgb48, sizeof(uint16_t), (size_t)pixel_count * 3, in_pipe) == (size_t)pixel_count * 3) {
    for (int i = 0; i < pixel_count * 3; i++) {
      code[i] = (int16_t)(rgb48[i] >> 4);   // 16-bit (10-bit<<6) -> 12-bit PQ code
    }
    uint8_t *encoded;
    size_t length = encode_frame_colordiff((const uint8_t *)code, width, height, 5, base_quality, &encoded, NULL, 0);
    decode_frame_colordiff(encoded, length, width, height, 5, base_quality, (uint8_t *)decoded, NULL, 0);
    free(encoded);
    encoded_bytes += length;
    hdr_to_srgb8(decoded, srgb, pixel_count, exposure, 16);   // transcode ingests PQ/bt2020
    fwrite(srgb, 1, (size_t)pixel_count * 3, out_pipe);
    done++;
  }
  set_sample_mode(0);   // restore SDR defaults
  free(rgb48); free(code); free(decoded); free(srgb);
  pclose(in_pipe);
  pclose(out_pipe);
  printf("HDR transcode: %ld frames %dx%d, %s, %.2f MB fwv -> %s\n",
         done, width, height, (quality == 0) ? "lossless 12-bit" : "lossy", encoded_bytes / 1048576.0, output);
  return (done > 0) ? 0 : 1;
}

// Round-trip self-test for the audio codecs: RPCM must be bit-exact (lossless s16), QOA-LE must round-trip
// to a high SNR (a broken little-endian serialisation would decode to noise -> very low SNR).
static int audio_selftest(void) {
  const double pi = acos(-1.0);
  int rate = 48000, channels = 2, samples = 12000;   // 0.25 s stereo
  short *pcm = checked_malloc((((size_t)samples * channels) * sizeof(short)));
  for (int i = 0; i < samples; i++) {
    double t = ((double)i / rate);
    pcm[(i * channels) + 0] = (short)lrint(30000.0 * sin((((2.0 * pi) * 440.0) * t)));
    pcm[(i * channels) + 1] = (short)lrint(20000.0 * sin((((2.0 * pi) * 660.0) * t)));
  }
  int fail = 0;

  uint64_t rpcm_size = 0;
  uint8_t *rpcm_blob = rpcm_encode_s16(pcm, samples, channels, rate, &rpcm_size);
  int rc = 0, rr = 0, rs = 0;
  short *rpcm_back = rpcm_decode_s16(rpcm_blob, rpcm_size, &rc, &rr, &rs);
  if ((((!rpcm_back) || (rc != channels)) || (rr != rate)) || (rs != samples)) {
    printf("RPCM: header mismatch (c=%d r=%d s=%d)\n", rc, rr, rs);
    fail = 1;
  } else {
    long mismatches = 0;
    for (int i = 0; i < (samples * channels); i++) {
      if (rpcm_back[i] != pcm[i]) {
        mismatches++;
      }
    }
    printf("RPCM: %d smp x%d @%dHz | %ld/%d mismatches (must be 0) | blob %llu B (%.2fx)\n",
           rs, rc, rr, mismatches, (samples * channels), (unsigned long long)rpcm_size,
           ((double)((samples * channels) * 2) / (double)rpcm_size));
    if (mismatches) {
      fail = 1;
    }
  }
  free(rpcm_blob);
  free(rpcm_back);

  uint64_t qoa_size = 0;
  uint8_t *qoa_blob = qoal_encode(pcm, samples, channels, rate, &qoa_size);
  int qc = 0, qr = 0, qs = 0;
  short *qoa_back = qoal_decode(qoa_blob, qoa_size, &qc, &qr, &qs);
  if ((((!qoa_back) || (qc != channels)) || (qr != rate)) || (qs != samples)) {
    printf("QOA: header mismatch (c=%d r=%d s=%d)\n", qc, qr, qs);
    fail = 1;
  } else {
    double signal = 0, noise = 0;
    for (int i = 0; i < (samples * channels); i++) {
      double s = (double)pcm[i];
      double n = ((double)qoa_back[i] - s);
      signal += (s * s);
      noise += (n * n);
    }
    double snr = ((noise > 0) ? (10.0 * log10(signal / noise)) : 99.0);
    printf("QOA: %d smp x%d @%dHz | SNR %.1f dB (>30 ok) | blob %llu B (%.2fx)\n",
           qs, qc, qr, snr, (unsigned long long)qoa_size,
           ((double)((samples * channels) * 2) / (double)qoa_size));
    if (snr < 30.0) {
      fail = 1;
    }
  }
  free(qoa_blob);
  free(qoa_back);
  free(pcm);
  printf("audio self-test: %s\n", fail ? "FAIL" : "OK");
  return fail;
}

// B-frame self-test: one coding step = encode+decode a frame from up to two DPB references.
// (CodeStep + build_b_range are now shared with the encoder — see above, before the 3D-DWT section.)

// Compare hierarchical B-frames vs P-only at the same quality: B should need fewer bytes for similar PSNR.
static int bframe_selftest(const char *input, int quality, int levels, int max_frames, int period) {
  int width, height;
  if (probe_video_dimensions(input, &width, &height) != 0) {
    die("ffprobe failed");
  }
  char command[4096];
  snprintf(command, sizeof command, "ffmpeg -v error -i \"%s\" -frames:v %d -f rawvideo -pix_fmt rgb24 -", input, max_frames);
  FILE *pipe = popen(command, "r");
  if (!pipe) {
    die("popen ffmpeg failed");
  }
  size_t frame_bytes = (size_t)width * height * 3;
  uint8_t **frames = checked_malloc((size_t)max_frames * sizeof(uint8_t *));
  int n = 0;
  while (n < max_frames) {
    uint8_t *frame = checked_malloc(frame_bytes);
    if (fread(frame, 1, frame_bytes, pipe) != frame_bytes) {
      free(frame);
      break;
    }
    frames[n++] = frame;
  }
  pclose(pipe);
  int anchors = (n - 1) / period;
  if (anchors < 1) {
    die("not enough frames for one anchor period");
  }
  n = (anchors * period) + 1;   // keep whole anchor periods (last frame is an anchor)

  int plane_pixels[3];
  for (int p = 0; p < 3; p++) {
    plane_pixels[p] = plane_width(p, width) * plane_height(p, height);
  }
  int32_t ***dpb = checked_malloc((size_t)n * sizeof(void *));
  for (int f = 0; f < n; f++) {
    dpb[f] = checked_malloc(3 * sizeof(int32_t *));
    for (int p = 0; p < 3; p++) {
      dpb[f][p] = checked_malloc((size_t)plane_pixels[p] * 4);
    }
  }
  CodeStep *steps = checked_malloc((size_t)n * sizeof(CodeStep));
  uint8_t *decoded = checked_malloc(frame_bytes);

  printf("B-frame self-test: %dx%d, %d frames, period=%d (%d B between anchors), Q%d\n",
         width, height, n, period, period - 1, quality);
  for (int mode = 0; mode < 2; mode++) {
    int count = 0;
    if (mode == 0) {   // P-only: every frame predicts from the previous, in display order
      for (int f = 0; f < n; f++) {
        steps[count++] = (CodeStep){ f, f - 1, -1, 256, 0, 0 };
      }
    } else {           // hierarchical B: anchors first (I0 then P), then the B between each pair
      steps[count++] = (CodeStep){ 0, -1, -1, 0, 0, 0 };
      for (int a = period; a < n; a += period) {
        steps[count++] = (CodeStep){ a, a - period, -1, 256, 0, 0 };
      }
      for (int a = 0; (a + period) < n; a += period) {
        build_b_range(steps, &count, a, a + period, 1);
      }
    }
    size_t total_bytes = 0;
    double sum_psnr = 0;
    for (int s = 0; s < count; s++) {
      int32_t **r0 = (steps[s].ref0 >= 0) ? dpb[steps[s].ref0] : NULL;
      int32_t **r1 = (steps[s].ref1 >= 0) ? dpb[steps[s].ref1] : NULL;
      uint8_t *payload;
      size_t length = encode_frame_bidi(frames[steps[s].poc], width, height, levels, quality, r0, r1,
                                        steps[s].weight0, steps[s].weight1, dpb[steps[s].poc], &payload);
      decode_frame_bidi(payload, width, height, levels, quality, r0, r1, steps[s].weight0, steps[s].weight1, NULL, decoded);
      total_bytes += length;
      double mse = 0;
      for (size_t i = 0; i < frame_bytes; i++) {
        int d = (int)decoded[i] - (int)frames[steps[s].poc][i];
        mse += (double)d * d;
      }
      mse /= (double)frame_bytes;
      sum_psnr += (mse == 0) ? 99.99 : (10.0 * log10((255.0 * 255.0) / mse));
      free(payload);
    }
    double bpp = ((double)total_bytes * 8.0) / ((double)n * width * height);
    printf("  %-9s: %.2f dB | %.3f MB | %.4f bpp\n", (mode == 0) ? "P-only" : "hier-B",
           sum_psnr / count, (double)total_bytes / 1e6, bpp);
  }
  return 0;
}

// Roundtrip self-test for the variable-motion quadtree: synthesise several fine 8-grid MV fields (exercising
// 32 / 16 / 8 leaves + edge roots clipped at a non-multiple grid), code + expand, the result must match exactly.
static int motion_quadtree_selftest(void) {
  int fgx = 17, fgy = 11;   // deliberately NOT a multiple of the 4-cell root, so edge roots are clipped
  int n = (fgx * fgy) * 2;
  int *field = checked_malloc(n * sizeof(int));
  int *out = checked_malloc(n * sizeof(int));
  const char *names[6] = { "all-zero (->32)", "uniform (->32)", "per-root (32)", "per-16", "per-8 hash", "mixed" };
  int fail = 0;
  for (int pattern = 0; pattern < 6; pattern++) {
    for (int fy = 0; fy < fgy; fy++) {
      for (int fx = 0; fx < fgx; fx++) {
        int idx = ((fy * fgx) + fx) * 2, vx, vy;
        switch (pattern) {
          case 0:  vx = 0;                   vy = 0;                   break;
          case 1:  vx = 3;                   vy = -2;                  break;
          case 2:  vx = (fx / 4) - 2;        vy = (fy / 4) + 1;        break;   // 32-root uniform
          case 3:  vx = (fx / 2) - 4;        vy = (fy / 2) - 2;        break;   // 16-leaf uniform
          case 4:  vx = (((fx * 7) + (fy * 13)) & 15) - 8; vy = (((fx * 5) + (fy * 11)) & 15) - 8; break;   // 8-leaf hash
          default: vx = (fx < (fgx / 2)) ? 0 : ((((fx * 7) + (fy * 13)) & 15) - 8);
                   vy = (fx < (fgx / 2)) ? 0 : ((((fx * 5) + (fy * 11)) & 15) - 8); break;   // half uniform, half per-8
        }
        field[idx] = vx;
        field[idx + 1] = vy;
      }
    }
    BitWriter writer;
    bitwriter_init(&writer);
    encode_motion_quadtree(&writer, field, fgx, fgy);
    bitwriter_flush(&writer);
    memset(out, 0x7f, n * sizeof(int));   // poison: a fine cell the decoder forgets to fill stays != field
    BitReader reader;
    bitreader_init(&reader, writer.bytes, writer.length);
    decode_motion_quadtree(&reader, out, fgx, fgy);
    int mismatch = 0;
    for (int i = 0; i < n; i++) {
      if (out[i] != field[i]) {
        mismatch++;
      }
    }
    printf("  pattern %d %-16s: %zu bytes -> %s (%d mismatches)\n", pattern, names[pattern], writer.length, mismatch ? "FAIL" : "ok", mismatch);
    if (mismatch) {
      fail = 1;
    }
    free(writer.bytes);
  }
  free(field);
  free(out);
  printf("motion quadtree self-test: %s\n", fail ? "FAIL" : "PASS");
  return fail;
}

int main(int argc, char **argv) {
  if (argc >= 2 && !strcmp(argv[1], "mqtest")) {   // variable-motion quadtree roundtrip self-test
    return motion_quadtree_selftest();
  }
  if (argc >= 2 && !strcmp(argv[1], "bframetest")) {   // bframetest <in> [Q=8] [levels=5] [frames=33] [period=4]
    int q = (argc > 3) ? atoi(argv[3]) : 8;
    int lv = (argc > 4) ? atoi(argv[4]) : 5;
    int mf = (argc > 5) ? atoi(argv[5]) : 33;
    int period = (argc > 6) ? atoi(argv[6]) : 4;
    return bframe_selftest(argv[2], q, lv, mf, period);
  }
  if (argc >= 2 && !strcmp(argv[1], "hdrtest")) {
    return hdr_selftest();
  }
  if (argc >= 2 && !strcmp(argv[1], "audiotest")) {
    return audio_selftest();
  }
  if (argc >= 4 && !strcmp(argv[1], "hdr")) {
    int quality = (argc > 4) ? atoi(argv[4]) : 0;
    long frames = (argc > 5) ? atol(argv[5]) : 8;
    float exposure = (argc > 6) ? (float)atof(argv[6]) : 100.0f;
    return hdr_transcode(argv[2], argv[3], quality, frames, exposure);
  }
  if (argc < 2) {
    fprintf(stderr, "usage: %s in.(mp4|y4m) [quality=8] [levels=5] [max_frames=0] [gop=1]\n"
                    "  gop>1 with quality=0 enables A (coefficient-diff) P-frames\n"
                    "  --mode 3ddwt [--twavelet haar|53|97] [--temporal-levels N] [--mctf]  temporal 3D-DWT (GOP from the gop arg, default 16); --mctf = motion-compensated (predict-only MC-Haar)\n"
                    "  %s hdrtest  -> 16-bit round-trip self-test (PQ-12 + signed-16-bit)\n", argv[0], argv[0]);
    return 1;
  }
  const char *input = argv[1];
  int quality = (argc > 2) ? atoi(argv[2]) : 8;
  int levels = (argc > 3) ? atoi(argv[3]) : 5;
  long max_frames = (argc > 4) ? atol(argv[4]) : 0;
  int gop = (argc > 5) ? atoi(argv[5]) : 1;   // max keyframe interval (1 = all-intra)
  // Optional flags (append after the positional args):
  //   --pcrd[=<lambda>]   PCRD R-D bit-plane truncation (default off; lambda higher -> more truncation)
  //   --chroma[=<mult>]   coarsen the chroma quant step (default 2.0 when bare; 1.0 = off)
  //   --pmode=coefdiff    P-frame method coefdiff (A, Q0-only prediction); else colordiff (B, default)
  //   --plane-bytes       print the per-plane (Y/Co/Cg) byte share
  //   --quant-debug       print the measured 9/7 synthesis gains
  int method = 1;   // 0 = coefdiff (A), 1 = colordiff (B, default)
  int mode_3ddwt = 0;   // --mode 3ddwt: open-loop temporal 3D-DWT GOP mode (vs the I/P-frame path)
  for (int a = 2; a < argc; a++) {
    if (strncmp(argv[a], "--pcrd", 6) == 0) {
      g_pcrd_lambda = (argv[a][6] == '=') ? atof(argv[a] + 7) : 0.5;   // 0.5 = a moderate default
    } else if (strncmp(argv[a], "--chroma-format", 15) == 0) {   // --chroma-format=420|422|444 (must precede --chroma)
      g_chroma_format = strstr(argv[a], "420") ? 2 : (strstr(argv[a], "422") ? 1 : 0);
    } else if (strcmp(argv[a], "--420") == 0) {
      g_chroma_format = 2;
    } else if (strcmp(argv[a], "--422") == 0) {
      g_chroma_format = 1;
    } else if (strncmp(argv[a], "--chroma", 8) == 0) {
      g_chroma_quant = (argv[a][8] == '=') ? (float)atof(argv[a] + 9) : 2.0f;
    } else if (strncmp(argv[a], "--pmode", 7) == 0) {
      method = strstr(argv[a], "coef") ? 0 : 1;
    } else if (strcmp(argv[a], "--plane-bytes") == 0) {
      g_plane_bytes = 1;
    } else if (strcmp(argv[a], "--quant-debug") == 0) {
      g_quant_debug = 1;
    } else if (strncmp(argv[a], "--mode", 6) == 0) {   // --mode 3ddwt | --mode=3ddwt
      const char *value = (argv[a][6] == '=') ? (argv[a] + 7) : (((a + 1) < argc) ? argv[a + 1] : "");
      mode_3ddwt = (strstr(value, "3d") != NULL);
    } else if (strncmp(argv[a], "--twavelet", 10) == 0) {   // --twavelet haar|53|97
      const char *value = (argv[a][10] == '=') ? (argv[a] + 11) : (((a + 1) < argc) ? argv[a + 1] : "");
      g_temporal_wavelet = strstr(value, "97") ? 2 : (strstr(value, "53") ? 1 : 0);
    } else if (strncmp(argv[a], "--temporal-levels", 17) == 0) {   // --temporal-levels N
      const char *value = (argv[a][17] == '=') ? (argv[a] + 18) : (((a + 1) < argc) ? argv[a + 1] : "2");
      g_temporal_levels = atoi(value);
    } else if (strncmp(argv[a], "--mctf", 6) == 0) {   // motion-compensated temporal filtering (predict-only MC-Haar) in 3D-DWT
      g_mctf = 1;
    } else if (strncmp(argv[a], "--hdr", 5) == 0) {   // ingest a 10/12-bit HDR (PQ/HLG, BT.2020) source as 12-bit code (3D-DWT path)
      set_sample_mode(1);   // 12-bit unsigned [0,4095]; rgb48le >>4 on read. Keys the ingest off g_sample_bytes==2.
    } else if (strncmp(argv[a], "--block-size", 12) == 0) {   // --block-size 32|64|128 (coding block)
      const char *value = (argv[a][12] == '=') ? (argv[a] + 13) : (((a + 1) < argc) ? argv[a + 1] : "32");
      int bs = atoi(value);
      if ((bs == 32 || bs == 64) || bs == 128) {
        g_block_size = bs;
      }
    } else if (strncmp(argv[a], "--motion-split-fast", 19) == 0) {   // variable motion + the single-ref 2-ME B path (no joint merge)
      g_motion_variable = 1;
      g_motion_block = MOTION_LEAF;
      g_motion_split_bidi = 0;
    } else if (strncmp(argv[a], "--bidi-merge", 12) == 0) {   // explicit joint mode-aware B merge (the default; kept as an alias)
      g_motion_split_bidi = 1;
    } else if (strncmp(argv[a], "--motion-split", 14) == 0) {   // variable quadtree motion (root 32 -> 8); forces the fine 8-grid; joint B merge by default
      g_motion_variable = 1;
      g_motion_block = MOTION_LEAF;
    } else if (strncmp(argv[a], "--motion-lambda-alpha", 21) == 0) {   // adaptive frame-level scale (lambda_abs = alpha*avgSAD>>8)
      const char *value = (argv[a][21] == '=') ? (argv[a] + 22) : (((a + 1) < argc) ? argv[a + 1] : "48");
      g_motion_lambda_alpha = atoi(value);
    } else if (strncmp(argv[a], "--motion-lambda", 15) == 0) {   // FIXED absolute leaf cost (disables the adaptive frame-level lambda)
      const char *value = (argv[a][15] == '=') ? (argv[a] + 16) : (((a + 1) < argc) ? argv[a + 1] : "256");
      g_motion_lambda_abs = atoi(value);
      g_motion_lambda_alpha = 0;
    } else if (strncmp(argv[a], "--motion-block", 14) == 0) {   // --motion-block 8|16|32 (fixed motion grid)
      const char *value = (argv[a][14] == '=') ? (argv[a] + 15) : (((a + 1) < argc) ? argv[a + 1] : "16");
      int mb = atoi(value);
      if ((mb == 8 || mb == 16) || mb == 32) {
        g_motion_block = mb;
      }
    }
  }
  if (g_temporal_levels < 1) {
    g_temporal_levels = 1;
  }
  if (g_temporal_levels > 6) {
    g_temporal_levels = 6;
  }

  int width;
  int height;
  if (probe_video_dimensions(input, &width, &height) != 0) {
    die("ffprobe failed");
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
  printf("fwvwave: %s  %dx%d  quality=%d levels=%d gop=%d pmode=%s (%s, raw bit-plane)\n",
         input, width, height, quality, levels, gop, (method == 0) ? "coefdiff" : "colordiff",
         (quality == 0) ? "LOSSLESS 5/3 integer" : "lossy 9/7");

  char command[4096];
  const char *ingest_fmt = (g_sample_bytes == 2) ? "rgb48le" : "rgb24";   // HDR (--hdr) ingests 16-bit rgb48le
  if (max_frames) {
    snprintf(command, sizeof command,
             "ffmpeg -v error -i \"%s\" -frames:v %ld -f rawvideo -pix_fmt %s -", input, max_frames, ingest_fmt);
  } else {
    snprintf(command, sizeof command,
             "ffmpeg -v error -i \"%s\" -f rawvideo -pix_fmt %s -", input, ingest_fmt);
  }
  FILE *input_pipe = popen(command, "r");
  if (!input_pipe) {
    die("popen ffmpeg failed");
  }

  size_t frame_bytes = (((size_t)width * height) * 3) * g_sample_bytes;   // HDR (g_sample_bytes==2) = 16-bit rgb48le
  int pixel_count = width * height;
  uint8_t *rgb = checked_malloc(frame_bytes);
  uint8_t *reconstructed = checked_malloc(frame_bytes);
  // Separate encoder + decoder coefficient references (kept in lock-step for Q0 by losslessness).
  int32_t *previous_encode[3], *previous_decode[3];
  for (int plane = 0; plane < 3; plane++) {
    previous_encode[plane] = checked_malloc((size_t)pixel_count * 4);
    previous_decode[plane] = checked_malloc((size_t)pixel_count * 4);
  }
  long frame_index = 0;
  double sum_psnr = 0;
  double encode_milliseconds = 0;
  double decode_milliseconds = 0;
  unsigned long long total_bytes = 0;
  long intra_count = 0, predicted_count = 0;
  unsigned long long intra_bytes = 0, predicted_bytes = 0;

  if (mode_3ddwt) {
    // 3D-DWT mode: buffer a GOP of frames, transform/quant/code it as one unit, reconstruct, score.
    if (gop < 2) {
      gop = 16;
    }
    if (gop > MAX_GOP) {
      gop = MAX_GOP;
    }
    printf("  3D-DWT mode: GOP=%d temporal_levels=%d twavelet=%s (%s, 4:4:4)\n",
           gop, g_temporal_levels,
           g_mctf ? "MC-Haar" : ((g_temporal_wavelet == 2) ? "9/7" : ((g_temporal_wavelet == 1) ? "5/3" : "Haar")),
           g_mctf ? "MCTF predict-only" : "open-loop");
    uint8_t **gop_rgb = checked_malloc((size_t)gop * sizeof(uint8_t *));
    uint8_t **gop_reconstructed = checked_malloc((size_t)gop * sizeof(uint8_t *));
    uint8_t **gop_encoded = checked_malloc((size_t)gop * sizeof(uint8_t *));
    size_t *gop_encoded_length = checked_malloc((size_t)gop * sizeof(size_t));
    for (int g = 0; g < gop; g++) {
      gop_rgb[g] = checked_malloc(frame_bytes);
      gop_reconstructed[g] = checked_malloc(frame_bytes);
    }
    for (;;) {
      int want = gop;
      if (max_frames) {
        long left = max_frames - frame_index;
        if (left <= 0) {
          break;
        }
        if (left < want) {
          want = (int)left;
        }
      }
      int filled = 0;
      while ((filled < want) && (fread(gop_rgb[filled], 1, frame_bytes, input_pipe) == frame_bytes)) {
        filled++;
      }
      if (filled == 0) {
        break;
      }
      if (g_sample_bytes == 2) {   // HDR: rgb48le is 10-bit << 6; >>4 in place -> 12-bit BT.2020 code (mirrors fwvenc)
        for (int g = 0; g < filled; g++) {
          uint16_t *sample16 = (uint16_t *)gop_rgb[g];
          for (int s = 0; s < (pixel_count * 3); s++) {
            sample16[s] = (uint16_t)(sample16[s] >> 4);
          }
        }
      }
      double t0 = now_milliseconds();
      encode_gop_3ddwt(gop_rgb, filled, width, height, levels, quality, gop_encoded, gop_encoded_length);
      double t1 = now_milliseconds();
      decode_gop_3ddwt(gop_encoded, gop_encoded_length, filled, width, height, levels, quality, gop_reconstructed);
      double t2 = now_milliseconds();
      for (int g = 0; g < filled; g++) {
        double mean_squared_error = 0;
        for (size_t i = 0; i < frame_bytes; i++) {
          int difference = (int)gop_rgb[g][i] - (int)gop_reconstructed[g][i];
          mean_squared_error += (double)difference * difference;
        }
        mean_squared_error /= frame_bytes;
        double psnr = (mean_squared_error == 0) ? 99.99 : (10.0 * log10((255.0 * 255.0) / mean_squared_error));
        sum_psnr += psnr;
        total_bytes += gop_encoded_length[g];
        free(gop_encoded[g]);
        frame_index++;
      }
      encode_milliseconds += (t1 - t0);
      decode_milliseconds += (t2 - t1);
      if (filled < want) {
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
  } else {
    while (fread(rgb, 1, frame_bytes, input_pipe) == frame_bytes) {
      // A P-frames only for Q0 (coefficient-diff is exact only for the integer 5/3 path). A fixed GOP
      // here; the size-based scene-cut decision lives in the GPU encoder (where block sizes are free).
      int allow_predict = (method == 0) ? (quality == 0) : 1;   // A: Q0 only; B: any quality
      int is_predicted = ((gop > 1) && (frame_index % gop != 0)) && allow_predict;
      uint8_t *encoded;
      double t0 = now_milliseconds();
      size_t encoded_length = (method == 0)
                            ? encode_frame_coefdiff(rgb, width, height, levels, quality, &encoded, previous_encode, is_predicted)
                            : encode_frame_colordiff(rgb, width, height, levels, quality, &encoded, previous_encode, is_predicted);
      double t1 = now_milliseconds();
      if (method == 0) {
        decode_frame_coefdiff(encoded, encoded_length, width, height, levels, quality, reconstructed, previous_decode, is_predicted);
      } else {
        decode_frame_colordiff(encoded, encoded_length, width, height, levels, quality, reconstructed, previous_decode, is_predicted);
      }
      double t2 = now_milliseconds();

      double mean_squared_error = 0;
      for (size_t i = 0; i < frame_bytes; i++) {
        int difference = (int)rgb[i] - (int)reconstructed[i];
        mean_squared_error += (double)difference * difference;
      }
      mean_squared_error /= frame_bytes;
      double psnr = (mean_squared_error == 0) ? 99.99 : (10.0 * log10((255.0 * 255.0) / mean_squared_error));

      sum_psnr += psnr;
      total_bytes += encoded_length;
      if (is_predicted) {
        predicted_count++;
        predicted_bytes += encoded_length;
      } else {
        intra_count++;
        intra_bytes += encoded_length;
      }
      encode_milliseconds += t1 - t0;
      decode_milliseconds += t2 - t1;
      frame_index++;
      free(encoded);
      if (max_frames && frame_index >= max_frames) {
        break;
      }
    }
  }
  pclose(input_pipe);
  if (!frame_index) {
    die("no frames");
  }

  double raw_megabytes = ((double)frame_index * frame_bytes) / 1e6;
  double encoded_megabytes = (double)total_bytes / 1e6;
  printf("%ld frames | %.2f MB (%.1f:1, %.2f bpp) | PSNR %.2f dB | enc %.2f ms/f  dec %.2f ms/f\n",
         frame_index, encoded_megabytes, raw_megabytes / encoded_megabytes,
         ((double)total_bytes * 8.0) / (((double)frame_index * width) * height),
         sum_psnr / frame_index, encode_milliseconds / frame_index, decode_milliseconds / frame_index);
  if (predicted_count) {
    double intra_average = intra_count ? ((double)intra_bytes / intra_count) : 0;
    double predicted_average = (double)predicted_bytes / predicted_count;
    printf("  GOP=%d: %ld I (%.1f KB avg) + %ld P (%.1f KB avg) -> P is %.1fx smaller\n",
           gop, intra_count, intra_average / 1024.0, predicted_count, predicted_average / 1024.0,
           (predicted_average > 0) ? (intra_average / predicted_average) : 0.0);
  }

  free(rgb);
  free(reconstructed);
  for (int plane = 0; plane < 3; plane++) {
    free(previous_encode[plane]);
    free(previous_decode[plane]);
  }
  return 0;
}
#endif  // FWV_NO_MAIN
