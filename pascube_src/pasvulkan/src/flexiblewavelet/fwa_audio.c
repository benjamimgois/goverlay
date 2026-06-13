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
 * fwa_audio.c — Flexible Wavelet Audio (FWA) codec.
 *
 * Self-made wavelet audio codec, sister to the FWV video codec; used as the "FWAC" audio sub-codec inside the
 * FWV container, and standalone via the FWA_NO_MAIN-guarded main()/CLI at the bottom. Per-channel decorrelation
 * (stereo Mid/Side; multichannel adaptive pairwise M/S) -> per-block 1D wavelet -> adaptive binary range coder:
 *
 *   quality == 0 : LOSSLESS — reversible integer 5/3 (LeGall) DWT, or an LMS predictor (mode "lms").
 *   quality >= 1 : LOSSY    — CDF 9/7 DWT with uniform or psychoacoustic (ATH-shaped) quantisation, plus the
 *                             optional adaptive wavelet-packet best basis and joint-stereo intensity.
 *
 * Channel count and sample rate are runtime (probed via ffprobe; stereo/48k fallback; `-ac`/`-sr` override). The
 * encoded stream is self-describing (channels / sample rate / frame count in its header). ffmpeg is used only to
 * ingest/normalise the input PCM (like FWV); the codec itself is third-party-free at runtime.
 */
#define _POSIX_C_SOURCE 200809L   // popen/pclose
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <math.h>
#include "fwa_audio.h"   // this file is the Flexible Wavelet Audio (FWA) codec linked into FWV as the "FWAC"
                          // sub-codec. It is compiled with -DFWA_NO_MAIN so fwa's own main()/CLI/file-I/O block
                          // (guarded by #ifndef FWA_NO_MAIN) is excluded; fwv feeds PCM via extract_audio_pcm.
                          // fwa_encode/fwa_decode (appended below the guard) are the only non-static symbols, so
                          // every fwa internal stays file-local and nothing clashes with fwvwave.c.

#define DEFAULT_SAMPLE_RATE 48000    // fallback when the source rate can't be probed
#define DEFAULT_CHANNELS    2         // fallback channel count (stereo) when the source can't be probed
#define MAX_CHANNELS        16        // sanity cap on the resolved channel count
#define BLOCK_SAMPLES 8192            // per-block length per channel (non-overlapping blocks)
#define MIN_BAND      4               // stop the dyadic split when the low band gets this small
#define FWA_MAGIC    0x43415746u     // "FWAC" (low byte first: F,W,A,C)
#define JOINT_TOP_BANDS 2             // joint-stereo intensity: top frequency bands of Side collapsed to mono (>~6 kHz)

static void *checked_malloc(size_t size) {
  void *pointer = malloc(size ? size : 1);
  if (!pointer) {
    fprintf(stderr, "out of memory\n");
    exit(1);
  }
  return pointer;
}

// --------------------------------------------------------------- PCM ingest (ffmpeg -> s16le, N channels)

// Probe the source's native channel count, sample rate and channel layout via ffprobe (one call). On any
// failure the passed-in defaults are left untouched, so ingest falls back to stereo/48k. `layout` (>=64
// bytes) receives the layout name (e.g. "5.1") for the pairwise-M/S channel decorrelation, or stays empty.
static void probe_source(const char *input, int *channels, int *sample_rate, char *layout) {
  char command[4096];
  snprintf(command, sizeof command,
           "ffprobe -v error -select_streams a:0 -show_entries stream=channels,sample_rate,channel_layout "
           "-of default=noprint_wrappers=1 \"%s\"", input);
  FILE *pipe = popen(command, "r");
  if (!pipe) {
    return;
  }
  char line[256];
  while (fgets(line, sizeof line, pipe)) {           // parse by key (ffprobe's CSV field order is not the requested order)
    int value = 0;
    if (sscanf(line, "channels=%d", &value) == 1) {
      *channels = value;
    } else if (sscanf(line, "sample_rate=%d", &value) == 1) {
      *sample_rate = value;
    } else if (!strncmp(line, "channel_layout=", 15)) {
      size_t length = strcspn(line + 15, "\r\n");
      if (length > 63) {
        length = 63;
      }
      memcpy(layout, line + 15, length);
      layout[length] = '\0';
    }
  }
  pclose(pipe);
}

// Linear-interpolation resampler (interleaved s16). Deliberately the simplest correct method so a higher-
// quality sinc/polyphase resampler can drop in later behind the same signature. Only invoked when the
// requested output rate differs from the source rate (`-sr`); native-rate ingest skips it entirely.
static int16_t *resample_linear(const int16_t *input, long in_frames, int channels,
                                int in_rate, int out_rate, long *out_frames) {
  long n = (long)(((double)in_frames * (double)out_rate) / (double)in_rate);
  if (n < 1) {
    n = 1;
  }
  int16_t *output = checked_malloc((size_t)(n * channels) * sizeof(int16_t));
  double step = ((double)in_rate / (double)out_rate);
  for (long j = 0; j < n; j++) {
    double position = ((double)j * step);
    long i0 = (long)position;
    double frac = (position - (double)i0);
    long i1 = (i0 + 1);
    if (i1 >= in_frames) {
      i1 = (in_frames - 1);
    }
    for (int c = 0; c < channels; c++) {
      double a = (double)input[(i0 * channels) + c];
      double b = (double)input[(i1 * channels) + c];
      double value = (a + ((b - a) * frac));
      long rounded = (long)((value >= 0.0) ? (value + 0.5) : (value - 0.5));
      if (rounded > 32767) {
        rounded = 32767;
      } else if (rounded < -32768) {
        rounded = -32768;
      }
      output[(j * channels) + c] = (int16_t)rounded;
    }
  }
  *out_frames = n;
  return output;
}

// Returns interleaved int16 samples (channels-major frames); *frame_count = number of frames. ffmpeg
// ingests at `native_rate` with `channels` channels; if `out_rate` differs we resample ourselves (linear).
static int16_t *read_pcm(const char *input, long *frame_count, int channels, int native_rate, int out_rate) {
  char command[4096];
  snprintf(command, sizeof command,
           "ffmpeg -v error -i \"%s\" -f s16le -acodec pcm_s16le -ar %d -ac %d -",
           input, native_rate, channels);
  FILE *pipe = popen(command, "r");
  if (!pipe) {
    fprintf(stderr, "ffmpeg ingest failed\n");
    exit(1);
  }
  size_t capacity = 1 << 20;
  size_t filled = 0;
  int16_t *samples = checked_malloc(capacity * sizeof(int16_t));
  size_t got = 0;
  while ((got = fread(&samples[filled], sizeof(int16_t), capacity - filled, pipe)) > 0) {
    filled += got;
    if (filled == capacity) {
      capacity *= 2;
      samples = realloc(samples, capacity * sizeof(int16_t));
      if (!samples) {
        fprintf(stderr, "out of memory\n");
        exit(1);
      }
    }
  }
  pclose(pipe);
  long frames = (long)(filled / channels);
  if ((out_rate > 0) && (out_rate != native_rate)) {       // own linear resample (sinc-swappable)
    long resampled_frames = 0;
    int16_t *resampled = resample_linear(samples, frames, channels, native_rate, out_rate, &resampled_frames);
    free(samples);
    samples = resampled;
    frames = resampled_frames;
  }
  *frame_count = frames;
  return samples;
}

// Minimal canonical 16-bit PCM WAV writer (so the decoded output is directly listenable).
static void write_wav(const char *path, const int16_t *interleaved, long frame_count, int channel_count, int sample_rate) {
  FILE *file = fopen(path, "wb");
  if (!file) {
    fprintf(stderr, "cannot open %s\n", path);
    exit(1);
  }
  uint32_t data_bytes = (uint32_t)((frame_count * channel_count) * 2);
  uint32_t byte_rate = (uint32_t)((sample_rate * channel_count) * 2);
  uint32_t riff_size = 36 + data_bytes;
  uint16_t block_align = (uint16_t)(channel_count * 2);
  uint16_t bits = 16;
  uint16_t format = 1;
  uint16_t channels = (uint16_t)channel_count;
  uint32_t rate = (uint32_t)sample_rate;
  uint32_t fmt_size = 16;
  fwrite("RIFF", 1, 4, file);
  fwrite(&riff_size, 4, 1, file);
  fwrite("WAVE", 1, 4, file);
  fwrite("fmt ", 1, 4, file);
  fwrite(&fmt_size, 4, 1, file);
  fwrite(&format, 2, 1, file);
  fwrite(&channels, 2, 1, file);
  fwrite(&rate, 4, 1, file);
  fwrite(&byte_rate, 4, 1, file);
  fwrite(&block_align, 2, 1, file);
  fwrite(&bits, 2, 1, file);
  fwrite("data", 1, 4, file);
  fwrite(&data_bytes, 4, 1, file);
  fwrite(interleaved, 2, (size_t)(frame_count * channel_count), file);
  fclose(file);
}

// ------------------------------------------------------------------ reversible Mid/Side (lossless lifting)

// S = L - R; M = R + floor(S/2) = floor((L+R)/2). Exactly invertible.
static void mid_side_forward(const int16_t *interleaved, long frame_count, int32_t *mid, int32_t *side) {
  for (long i = 0; i < frame_count; i++) {
    int left = interleaved[(i * 2) + 0];
    int right = interleaved[(i * 2) + 1];
    int s = left - right;
    int m = right + (s >> 1);
    mid[i] = m;
    side[i] = s;
  }
}

static int16_t clamp_int16(int value) {
  return (int16_t)((value > 32767) ? 32767 : ((value < -32768) ? -32768 : value));
}

static void mid_side_inverse(const int32_t *mid, const int32_t *side, int16_t *interleaved, long frame_count) {
  for (long i = 0; i < frame_count; i++) {
    int m = mid[i];
    int s = side[i];
    int right = m - (s >> 1);
    int left = right + s;
    interleaved[(i * 2) + 0] = clamp_int16(left);    // lossy quant can push loud samples past int16; clamp (no-op at Q0)
    interleaved[(i * 2) + 1] = clamp_int16(right);
  }
}

// ------------------------------------------------------------ per-channel decorrelation (mono/stereo/N)

// Split interleaved PCM into `channels` planar int32 channels. Stereo uses the reversible Mid/Side above
// (byte-identical to the original codec); mono and multichannel (N>=3) are coded INDEPENDENTLY for now --
// each channel deinterleaved as-is, no cross-channel decorrelation. (Layout-aware pairwise M/S = next step.)
static void decorrelate_forward(const int16_t *interleaved, long frame_count, int channels, int32_t *const *planes) {
  if (channels == 2) {
    mid_side_forward(interleaved, frame_count, planes[0], planes[1]);
    return;
  }
  for (int c = 0; c < channels; c++) {
    int32_t *plane = planes[c];
    for (long i = 0; i < frame_count; i++) {
      plane[i] = interleaved[(i * channels) + c];
    }
  }
}

static void decorrelate_inverse(int32_t *const *planes, long frame_count, int channels, int16_t *interleaved) {
  if (channels == 2) {
    mid_side_inverse(planes[0], planes[1], interleaved, frame_count);
    return;
  }
  for (int c = 0; c < channels; c++) {
    const int32_t *plane = planes[c];
    for (long i = 0; i < frame_count; i++) {
      interleaved[(i * channels) + c] = clamp_int16(plane[i]);   // clamp: lossy quant can push past int16 (no-op at Q0)
    }
  }
}

// ----------------------------------------------- layout-aware pairwise Mid/Side (M1, multichannel N>=3)
//
// Reversible Mid/Side on a single channel pair, planar in place: a := mid, b := side (same lifting as the
// stereo path, so it is exactly invertible for ANY two channels -- a non-ideal pairing only costs ratio).
static void ms_pair_forward(int32_t *a, int32_t *b, long frame_count) {
  for (long i = 0; i < frame_count; i++) {
    int left = a[i];
    int right = b[i];
    int s = left - right;
    a[i] = right + (s >> 1);
    b[i] = s;
  }
}

static void ms_pair_inverse(int32_t *a, int32_t *b, long frame_count) {
  for (long i = 0; i < frame_count; i++) {
    int m = a[i];
    int s = b[i];
    int right = m - (s >> 1);
    a[i] = right + s;
    b[i] = right;
  }
}

// Cheap whole-signal heuristic for the adaptive (`-adapt`) mode: M/S wins when sum|mid|+|side| < sum|L|+|R|
// (FLAC-style sum-of-magnitudes proxy for coded size). Returns 1 to M/S the pair, 0 to keep it independent.
static int ms_pair_beneficial(const int32_t *a, const int32_t *b, long frame_count) {
  double lr = 0.0;
  double ms = 0.0;
  for (long i = 0; i < frame_count; i++) {
    int left = a[i];
    int right = b[i];
    int s = left - right;
    int m = right + (s >> 1);
    lr += (fabs((double)left) + fabs((double)right));
    ms += (fabs((double)m) + fabs((double)s));
  }
  return (ms < lr) ? 1 : 0;
}

// Map an ffmpeg channel-layout name to the L/R partner pairs to Mid/Side. Channels not in a pair (FC, LFE,
// BC, ...) are coded independently. The pairing is stored explicitly in the stream, so the decoder never
// needs the layout; an unrecognised layout falls back to pairing just front L/R (channels 0,1).
static int derive_pairs(int channels, const char *layout, int pairs[][2]) {
  static const struct { const char *name; int count; int a[4]; int b[4]; } table[] = {
    { "2.1",           1, { 0 },       { 1 } },
    { "3.0",           1, { 0 },       { 1 } },
    { "3.0(back)",     1, { 0 },       { 1 } },
    { "4.0",           1, { 0 },       { 1 } },
    { "4.1",           1, { 0 },       { 1 } },
    { "quad",          2, { 0, 2 },    { 1, 3 } },
    { "quad(side)",    2, { 0, 2 },    { 1, 3 } },
    { "5.0",           2, { 0, 3 },    { 1, 4 } },
    { "5.0(side)",     2, { 0, 3 },    { 1, 4 } },
    { "5.1",           2, { 0, 4 },    { 1, 5 } },
    { "5.1(side)",     2, { 0, 4 },    { 1, 5 } },
    { "6.0",           2, { 0, 4 },    { 1, 5 } },
    { "6.0(front)",    3, { 0, 2, 4 }, { 1, 3, 5 } },
    { "6.1",           2, { 0, 5 },    { 1, 6 } },
    { "6.1(back)",     2, { 0, 5 },    { 1, 6 } },
    { "6.1(front)",    3, { 0, 3, 5 }, { 1, 4, 6 } },
    { "7.0",           3, { 0, 3, 5 }, { 1, 4, 6 } },
    { "7.0(front)",    3, { 0, 3, 5 }, { 1, 4, 6 } },
    { "7.1",           3, { 0, 4, 6 }, { 1, 5, 7 } },
    { "7.1(wide)",     3, { 0, 4, 6 }, { 1, 5, 7 } },
    { "7.1(wide-side)",3, { 0, 4, 6 }, { 1, 5, 7 } },
  };
  for (size_t t = 0; t < (sizeof table / sizeof table[0]); t++) {
    if (!strcmp(layout, table[t].name)) {
      int count = table[t].count;
      for (int k = 0; k < count; k++) {
        pairs[k][0] = table[t].a[k];
        pairs[k][1] = table[t].b[k];
      }
      return count;
    }
  }
  if (channels >= 2) {                                  // unknown layout: front L/R is channels 0,1 in essentially every layout
    pairs[0][0] = 0;
    pairs[0][1] = 1;
    return 1;
  }
  return 0;
}

// ffmpeg's default layout name for a forced `-ac N` channel count (matches the probed layouts), so the
// pairing for a downmix target is derived the same way as for a native multichannel source.
static const char *canonical_layout_name(int channels) {
  switch (channels) {
    case 1: return "mono";
    case 2: return "stereo";
    case 3: return "2.1";
    case 4: return "4.0";
    case 5: return "5.0";
    case 6: return "5.1";
    case 7: return "6.1";
    case 8: return "7.1";
    default: return "";
  }
}

// --------------------------------------------------------------- 1D LeGall 5/3 DWT (lossless, in place)

static int reflect(int index, int length) {
  if (index < 0) {
    index = -index;
  }
  if (index >= length) {
    index = ((2 * length) - 2) - index;
  }
  return (index < 0) ? 0 : ((index >= length) ? (length - 1) : index);
}

// One level of the reversible 5/3 transform on the first `length` samples, then deinterleave the low
// (smooth) half to the front and the high (detail) half to the back.
static void legall53_forward_level(int32_t *data, int length, int32_t *scratch) {
  for (int i = 1; i < length; i += 2) {   // predict: detail = odd - (left even + right even)/2
    int left = data[i - 1];
    int right = data[reflect(i + 1, length)];
    data[i] -= ((left + right) >> 1);
  }
  for (int i = 0; i < length; i += 2) {    // update: smooth = even + (left detail + right detail + 2)/4
    int left = data[reflect(i - 1, length)];
    int right = data[reflect(i + 1, length)];
    data[i] += (((left + right) + 2) >> 2);
  }
  int half = (length + 1) / 2;
  for (int i = 0; i < length; i++) {       // deinterleave: evens -> [0,half), odds -> [half,length)
    if ((i & 1) == 0) {
      scratch[i >> 1] = data[i];
    } else {
      scratch[half + (i >> 1)] = data[i];
    }
  }
  memcpy(data, scratch, (size_t)length * sizeof(int32_t));
}

static void legall53_inverse_level(int32_t *data, int length, int32_t *scratch) {
  int half = (length + 1) / 2;
  for (int i = 0; i < length; i++) {       // interleave back
    if ((i & 1) == 0) {
      scratch[i] = data[i >> 1];
    } else {
      scratch[i] = data[half + (i >> 1)];
    }
  }
  memcpy(data, scratch, (size_t)length * sizeof(int32_t));
  for (int i = 0; i < length; i += 2) {    // undo update
    int left = data[reflect(i - 1, length)];
    int right = data[reflect(i + 1, length)];
    data[i] -= (((left + right) + 2) >> 2);
  }
  for (int i = 1; i < length; i += 2) {    // undo predict
    int left = data[i - 1];
    int right = data[reflect(i + 1, length)];
    data[i] += ((left + right) >> 1);
  }
}

static int dwt_level_count(int length) {
  int levels = 0;
  int current = length;
  while (current >= (MIN_BAND * 2)) {
    levels++;
    current = (current + 1) / 2;
  }
  return levels;
}

static void dwt53_forward(int32_t *data, int length, int32_t *scratch) {
  int current = length;
  int levels = dwt_level_count(length);
  for (int level = 0; level < levels; level++) {
    legall53_forward_level(data, current, scratch);
    current = (current + 1) / 2;
  }
}

static void dwt53_inverse(int32_t *data, int length, int32_t *scratch) {
  int levels = dwt_level_count(length);
  int sizes[40];
  int current = length;
  for (int level = 0; level < levels; level++) {
    sizes[level] = current;
    current = (current + 1) / 2;
  }
  for (int level = levels - 1; level >= 0; level--) {
    legall53_inverse_level(data, sizes[level], scratch);
  }
}

// ----------------------------------------------------- QOA-style adaptive LMS predictor (lossless option)

// 4-tap sign-sign LMS (exactly QOA's qoa_lms_predict/update, but coding the EXACT integer residual so it
// stays lossless). An alternative lossless decorrelation to the 5/3 wavelet -- prediction tends to beat a
// wavelet for lossless audio (FLAC's LPC does too). prediction = (sum weights*history) >> 13; the weights
// adapt by +-(residual>>4) per the sign of each history tap. The prediction sum uses 64-bit because
// lossless residuals (and thus the weights) grow larger than QOA's bounded quantised ones.
#define LMS_MAX_TAPS 32

typedef struct {
  int32_t history[LMS_MAX_TAPS];
  int32_t weights[LMS_MAX_TAPS];
} LmsState;

// QOA's 4-tap init generalised to N taps: only the two most-recent weights start non-zero ({-1, 2}<<13),
// so the initial prediction is the same 2nd-order extrapolation (2*last - prev) regardless of tap count;
// the extra taps start at 0 and adapt. FLAC reaches order-32 LPC, so more taps tighten the prediction.
static void lms_init(LmsState *lms, int taps) {
  for (int i = 0; i < taps; i++) {
    lms->history[i] = 0;
    lms->weights[i] = 0;
  }
  if (taps >= 2) {
    lms->weights[taps - 2] = -(1 << 13);
    lms->weights[taps - 1] = (1 << 14);
  }
}

static int32_t lms_predict(const LmsState *lms, int taps) {
  int64_t prediction = 0;
  for (int i = 0; i < taps; i++) {
    prediction += ((int64_t)lms->weights[i] * (int64_t)lms->history[i]);
  }
  return (int32_t)(prediction >> 13);
}

// The adaptation step must shrink as taps grow or the sign-sign LMS diverges (more weights each nudged
// by the same delta = positive feedback). Scale it ~1/taps (NLMS-style): shift 4 at 4 taps -> 7 at 32.
static int lms_adapt_shift(int taps) {
  int shift = 4;
  for (int t = taps; t > 4; t >>= 1) {
    shift++;
  }
  return shift;
}

static void lms_update(LmsState *lms, int taps, int adapt_shift, int32_t sample, int32_t residual) {
  int32_t delta = (residual >> adapt_shift);
  for (int i = 0; i < taps; i++) {
    lms->weights[i] += ((lms->history[i] < 0) ? -delta : delta);
  }
  for (int i = 0; i < (taps - 1); i++) {
    lms->history[i] = lms->history[i + 1];
  }
  lms->history[taps - 1] = sample;
}

// Replace each sample with its prediction residual, in place (lossless, exactly invertible by lms_inverse).
static void lms_forward(int32_t *data, long count, int taps) {
  LmsState lms;
  lms_init(&lms, taps);
  int adapt_shift = lms_adapt_shift(taps);
  for (long i = 0; i < count; i++) {
    int32_t sample = data[i];
    int32_t residual = (sample - lms_predict(&lms, taps));
    data[i] = residual;
    lms_update(&lms, taps, adapt_shift, sample, residual);
  }
}

static void lms_inverse(int32_t *data, long count, int taps) {
  LmsState lms;
  lms_init(&lms, taps);
  int adapt_shift = lms_adapt_shift(taps);
  for (long i = 0; i < count; i++) {
    int32_t residual = data[i];
    int32_t sample = (residual + lms_predict(&lms, taps));
    data[i] = sample;
    lms_update(&lms, taps, adapt_shift, sample, residual);
  }
}

// --------------------------------------------------------------- 1D CDF 9/7 DWT (lossy, float, in place)

#define CDF97_ALPHA (-1.586134342059924f)
#define CDF97_BETA  (-0.052980118572961f)
#define CDF97_GAMMA ( 0.882911075530934f)
#define CDF97_DELTA ( 0.443506852043971f)
#define CDF97_SCALE ( 1.230174104914001f)

static void dwt97_forward_level(float *data, int length, float *scratch) {
  for (int i = 1; i < length; i += 2) {
    data[i] += (CDF97_ALPHA * (data[i - 1] + data[reflect(i + 1, length)]));
  }
  for (int i = 0; i < length; i += 2) {
    data[i] += (CDF97_BETA * (data[reflect(i - 1, length)] + data[reflect(i + 1, length)]));
  }
  for (int i = 1; i < length; i += 2) {
    data[i] += (CDF97_GAMMA * (data[i - 1] + data[reflect(i + 1, length)]));
  }
  for (int i = 0; i < length; i += 2) {
    data[i] += (CDF97_DELTA * (data[reflect(i - 1, length)] + data[reflect(i + 1, length)]));
  }
  for (int i = 1; i < length; i += 2) {
    data[i] *= CDF97_SCALE;
  }
  for (int i = 0; i < length; i += 2) {
    data[i] *= (1.0f / CDF97_SCALE);
  }
  int half = (length + 1) / 2;
  for (int i = 0; i < length; i++) {
    if ((i & 1) == 0) {
      scratch[i >> 1] = data[i];
    } else {
      scratch[half + (i >> 1)] = data[i];
    }
  }
  memcpy(data, scratch, (size_t)length * sizeof(float));
}

static void dwt97_inverse_level(float *data, int length, float *scratch) {
  int half = (length + 1) / 2;
  for (int i = 0; i < length; i++) {
    if ((i & 1) == 0) {
      scratch[i] = data[i >> 1];
    } else {
      scratch[i] = data[half + (i >> 1)];
    }
  }
  memcpy(data, scratch, (size_t)length * sizeof(float));
  for (int i = 0; i < length; i += 2) {
    data[i] *= CDF97_SCALE;
  }
  for (int i = 1; i < length; i += 2) {
    data[i] *= (1.0f / CDF97_SCALE);
  }
  for (int i = 0; i < length; i += 2) {
    data[i] -= (CDF97_DELTA * (data[reflect(i - 1, length)] + data[reflect(i + 1, length)]));
  }
  for (int i = 1; i < length; i += 2) {
    data[i] -= (CDF97_GAMMA * (data[i - 1] + data[reflect(i + 1, length)]));
  }
  for (int i = 0; i < length; i += 2) {
    data[i] -= (CDF97_BETA * (data[reflect(i - 1, length)] + data[reflect(i + 1, length)]));
  }
  for (int i = 1; i < length; i += 2) {
    data[i] -= (CDF97_ALPHA * (data[i - 1] + data[reflect(i + 1, length)]));
  }
}

static void dwt97_forward(float *data, int length, float *scratch) {
  int current = length;
  int levels = dwt_level_count(length);
  for (int level = 0; level < levels; level++) {
    dwt97_forward_level(data, current, scratch);
    current = (current + 1) / 2;
  }
}

static void dwt97_inverse(float *data, int length, float *scratch) {
  int levels = dwt_level_count(length);
  int sizes[40];
  int current = length;
  for (int level = 0; level < levels; level++) {
    sizes[level] = current;
    current = (current + 1) / 2;
  }
  for (int level = levels - 1; level >= 0; level--) {
    dwt97_inverse_level(data, sizes[level], scratch);
  }
}

// Deadzone quantize/dequantize with a per-coefficient step (uniform, or psychoacoustically shaped per
// subband -- see compute_steps()).
static void quantize_block(const float *coefficients, int32_t *indices, int length, const float *step_per_coeff) {
  for (int i = 0; i < length; i++) {
    float scaled = coefficients[i] / step_per_coeff[i];
    indices[i] = (int32_t)((scaled >= 0.0f) ? (scaled + 0.5f) : (scaled - 0.5f));
  }
}

static void dequantize_block(const int32_t *indices, float *coefficients, int length, const float *step_per_coeff) {
  for (int i = 0; i < length; i++) {
    coefficients[i] = ((float)indices[i] * step_per_coeff[i]);
  }
}

// ----------------------------------------------------------------- bit writer / reader (mantissa bits)

typedef struct {
  uint8_t *bytes;
  size_t capacity;
  size_t byte_position;
  int bit_position;
} BitWriter;

static void bitwriter_init(BitWriter *writer) {
  writer->capacity = 1024;
  writer->bytes = checked_malloc(writer->capacity);
  writer->bytes[0] = 0;
  writer->byte_position = 0;
  writer->bit_position = 0;
}

static void bitwriter_put(BitWriter *writer, uint32_t value, int bits) {
  for (int i = bits - 1; i >= 0; i--) {
    if ((writer->byte_position + 1) >= writer->capacity) {
      writer->capacity *= 2;
      writer->bytes = realloc(writer->bytes, writer->capacity);
    }
    int bit = (int)((value >> i) & 1u);
    writer->bytes[writer->byte_position] |= (uint8_t)(bit << (7 - writer->bit_position));
    writer->bit_position++;
    if (writer->bit_position == 8) {
      writer->bit_position = 0;
      writer->byte_position++;
      writer->bytes[writer->byte_position] = 0;
    }
  }
}

static size_t bitwriter_length(const BitWriter *writer) {
  return writer->byte_position + ((writer->bit_position > 0) ? 1 : 0);
}

typedef struct {
  const uint8_t *bytes;
  size_t byte_position;
  int bit_position;
} BitReader;

static void bitreader_init(BitReader *reader, const uint8_t *bytes) {
  reader->bytes = bytes;
  reader->byte_position = 0;
  reader->bit_position = 0;
}

static uint32_t bitreader_get(BitReader *reader, int bits) {
  uint32_t value = 0;
  for (int i = 0; i < bits; i++) {
    int bit = (reader->bytes[reader->byte_position] >> (7 - reader->bit_position)) & 1;
    value = (value << 1) | (uint32_t)bit;
    reader->bit_position++;
    if (reader->bit_position == 8) {
      reader->bit_position = 0;
      reader->byte_position++;
    }
  }
  return value;
}

// ------------------------------------------------------ wavelet packet best-basis (lossy 9/7 only)
//
// The dyadic 9/7 transform only ever splits the low band. A wavelet packet best-basis instead may split
// ANY band, recursively, and per block keeps the subtree that minimises an additive coding-bit cost.
// For tonal material this buys finer frequency resolution exactly where it pays off. The chosen tree is
// signalled with one bit per node in preorder (1 = split, 0 = leaf) so the decoder can replay the same
// recombination. Uniform quantisation only (perceptual + packet coupling is out of scope here).

// Estimated coding bits of a segment: additive (so subtree costs combine) and basis-independent. This is
// the RATE part of the best-basis rate-distortion cost.
static double segment_cost(const float *seg, int len) {
  double cost = 0.0;
  for (int i = 0; i < len; i++) {
    cost += log2((double)fabsf(seg[i]) + 1.0);
  }
  return cost;
}

// --- best-basis rate-distortion: synthesis-gain table -----------------------------------------------
//
// The 9/7 is BIORTHOGONAL, not energy-preserving: a unit quant error in a leaf at tree depth d does NOT
// cost a unit of sample-domain L2 error -- the synthesis (inverse) filters amplify it by a depth-
// dependent gain. A pure-rate best-basis therefore over-splits dense (broadband) bands, where the extra
// split amplifies quant noise more than it saves bits. We MEASURE the per-depth synthesis gain once per
// run (the textbook way) by synthesising a unit impulse and taking the L2 norm of the result, then fold
// gain(d)^2 into a distortion term so the split decision becomes rate-distortion.

#define MAX_SYNTHESIS_DEPTH 40
static double synthesis_gain_squared[MAX_SYNTHESIS_DEPTH + 1];   // gain(d)^2, indexed by leaf depth d
static int synthesis_gain_ready = 0;

// Build the length of a depth-d band and the parent lengths above it, exactly as packet_reconstruct
// recombines: a leaf at depth d sits in a band of length sizes[d], whose ancestors double back up to the
// root length sizes[0]. Returns the depth actually reachable for this root length.
static int packet_band_sizes(int root_length, int *sizes) {
  int depth = 0;
  int current = root_length;
  sizes[0] = current;
  while ((depth < MAX_SYNTHESIS_DEPTH) && (current >= 8)) {       // matches the len>=8 split guard
    int half = (current + 1) / 2;
    depth++;
    current = half;
    sizes[depth] = current;
  }
  return depth;
}

// Measure gain(d)^2 = sample-domain L2 energy produced by a single unit coefficient in a depth-d leaf,
// synthesised up through d inverse 9/7 levels. Cached per run; depends only on the filter + lengths.
static void measure_synthesis_gain(int root_length) {
  int sizes[MAX_SYNTHESIS_DEPTH + 1];
  int max_depth = packet_band_sizes(root_length, sizes);
  float *buffer = checked_malloc((size_t)root_length * sizeof(float));
  float *scratch = checked_malloc((size_t)root_length * sizeof(float));
  for (int depth = 0; depth <= max_depth; depth++) {
    for (int i = 0; i < root_length; i++) {
      buffer[i] = 0.0f;
    }
    buffer[0] = 1.0f;                                             // unit impulse at the start of the depth-d band
    for (int level = depth; level >= 1; level--) {               // synthesise up: depth-d band -> root
      dwt97_inverse_level(buffer, sizes[level - 1], scratch);
    }
    double energy = 0.0;
    for (int i = 0; i < root_length; i++) {
      energy += ((double)buffer[i] * (double)buffer[i]);
    }
    synthesis_gain_squared[depth] = energy;
  }
  for (int depth = max_depth + 1; depth <= MAX_SYNTHESIS_DEPTH; depth++) {
    synthesis_gain_squared[depth] = synthesis_gain_squared[max_depth];
  }
  synthesis_gain_ready = 1;
  free(buffer);
  free(scratch);
}

// Rate-distortion leaf cost: rate (coding bits) + lambda * distortion. The distortion is the sample-
// domain L2 error from uniformly quantising this leaf at `step`, i.e. (coeff count) * (step^2 / 12) per-
// coefficient variance AMPLIFIED by the measured 9/7 synthesis gain(depth)^2. lambda was calibrated
// (test.wav + Aquaman broadband, plus a synthetic tonal signal) so that packet >= uniform SNR at similar
// size on broadband while still winning on tonal -- a deeper split is taken only when its rate saving
// outweighs the extra synthesis-amplified quant noise it incurs. (FWA_LAMBDA env overrides for tuning.)
#define PACKET_RD_LAMBDA 0.0012
static double packet_rd_lambda(void) {
  const char *override = getenv("FWA_LAMBDA");
  return override ? atof(override) : PACKET_RD_LAMBDA;
}
static double packet_leaf_cost(const float *seg, int len, int depth, float step) {
  double rate = segment_cost(seg, len);
  int clamped_depth = (depth < 0) ? 0 : ((depth > MAX_SYNTHESIS_DEPTH) ? MAX_SYNTHESIS_DEPTH : depth);
  double gain_squared = synthesis_gain_ready ? synthesis_gain_squared[clamped_depth] : 1.0;
  double per_coeff_variance = (((double)step * (double)step) / 12.0);
  double distortion = (((double)len * per_coeff_variance) * gain_squared);
  return (rate + (packet_rd_lambda() * distortion));
}

// Replay every bit already written into `source` (in order) into `destination`, preserving order. Used
// to splice a child's preorder tree bits after the parent's split bit.
static void bitwriter_append(BitWriter *destination, const BitWriter *source) {
  size_t full_bytes = source->byte_position;
  for (size_t b = 0; b < full_bytes; b++) {
    bitwriter_put(destination, source->bytes[b], 8);
  }
  for (int bit = 0; bit < source->bit_position; bit++) {
    int value = (source->bytes[full_bytes] >> (7 - bit)) & 1;
    bitwriter_put(destination, (uint32_t)value, 1);
  }
}

// Recursive best-basis decompose. Trials a split on a COPY so a rejected split leaves `seg` untouched;
// commits the (already fully decomposed) split only when the children code cheaper than the leaf. Writes
// the chosen subtree's node bits into `tree` in preorder. Returns the RATE-DISTORTION cost of the kept
// basis: split iff (childcost_low + childcost_high) < leafcost, with all three being the R-D cost and the
// children evaluated at depth+1 so deeper splits carry more (synthesis-amplified) quant distortion. This
// stops the pure-rate criterion from over-splitting dense broadband bands. `step` is the quant step (=
// quality) so the distortion term scales with the operating point.
static double packet_decompose(float *seg, int len, int depth, int max_depth, float step, float *scratch, BitWriter *tree) {
  double leaf_cost = packet_leaf_cost(seg, len, depth, step);
  if ((depth >= max_depth) || (len < 8)) {
    bitwriter_put(tree, 0, 1);                            // forced leaf
    return leaf_cost;
  }
  float *copy = checked_malloc((size_t)len * sizeof(float));
  memcpy(copy, seg, (size_t)len * sizeof(float));
  dwt97_forward_level(copy, len, scratch);               // one trial split: [low half | high half]
  int half = (len + 1) / 2;
  BitWriter low_tree;
  BitWriter high_tree;
  bitwriter_init(&low_tree);
  bitwriter_init(&high_tree);
  double low_cost = packet_decompose(copy, half, depth + 1, max_depth, step, scratch, &low_tree);
  double high_cost = packet_decompose(copy + half, len - half, depth + 1, max_depth, step, scratch, &high_tree);
  double result;
  if ((low_cost + high_cost) < leaf_cost) {
    memcpy(seg, copy, (size_t)len * sizeof(float));       // commit the fully decomposed split
    bitwriter_put(tree, 1, 1);                            // split node, then children in preorder
    bitwriter_append(tree, &low_tree);
    bitwriter_append(tree, &high_tree);
    result = (low_cost + high_cost);
  } else {
    bitwriter_put(tree, 0, 1);                            // leaf; seg left untouched
    result = leaf_cost;
  }
  free(low_tree.bytes);
  free(high_tree.bytes);
  free(copy);
  return result;
}

// Inverse of packet_decompose: read the preorder tree, recombine split children back up with the inverse
// 9/7 step. A leaf bit means the coefficients are already in place for this segment.
static void packet_reconstruct(float *seg, int len, int depth, int max_depth, BitReader *tree, float *scratch) {
  (void)depth;
  (void)max_depth;
  int bit = (int)bitreader_get(tree, 1);
  if (bit == 0) {
    return;                                               // leaf: coefficients already in place
  }
  int half = (len + 1) / 2;
  packet_reconstruct(seg, half, depth + 1, max_depth, tree, scratch);
  packet_reconstruct(seg + half, len - half, depth + 1, max_depth, tree, scratch);
  dwt97_inverse_level(seg, len, scratch);                 // combine children back
}

// --------------------------------------------------------- coefficient <-> (class, mantissa) symbol map

#define CLASS_COUNT 33

static uint32_t zigzag(int32_t value) {
  return (uint32_t)((value << 1) ^ (value >> 31));
}

static int32_t unzigzag(uint32_t value) {
  return (int32_t)((value >> 1) ^ (~(value & 1u) + 1u));
}

static int magnitude_class(uint32_t value) {   // 0 for value 0, else floor(log2(value)) + 1
  int klass = 0;
  while (value) {
    klass++;
    value >>= 1;
  }
  return klass;
}

// ----------------------------------------------------------- Subbotin carryless range coder + contexts

#define RANGE_TOP    (1u << 24)
#define RANGE_BOTTOM (1u << 16)

typedef struct {
  uint32_t low;
  uint32_t range;
  uint32_t code;        // decoder only
  uint8_t *bytes;
  size_t position;
  size_t capacity;      // encoder: allocation; decoder: read limit (a bounded over-read returns 0)
} RangeCoder;

static void range_encoder_init(RangeCoder *coder) {
  coder->low = 0;
  coder->range = 0xFFFFFFFFu;
  coder->capacity = 1024;
  coder->bytes = checked_malloc(coder->capacity);
  coder->position = 0;
}

static void range_emit(RangeCoder *coder, uint8_t byte) {
  if (coder->position >= coder->capacity) {
    coder->capacity *= 2;
    coder->bytes = realloc(coder->bytes, coder->capacity);
  }
  coder->bytes[coder->position++] = byte;
}

static void range_normalise_encode(RangeCoder *coder) {
  while (((coder->low ^ (coder->low + coder->range)) < RANGE_TOP) ||
         ((coder->range < RANGE_BOTTOM) && ((coder->range = ((0u - coder->low) & (RANGE_BOTTOM - 1))), 1))) {
    range_emit(coder, (uint8_t)(coder->low >> 24));
    coder->low <<= 8;
    coder->range <<= 8;
  }
}

static void range_encode(RangeCoder *coder, uint32_t cumulative, uint32_t frequency, uint32_t total) {
  coder->range /= total;
  coder->low += (cumulative * coder->range);
  coder->range *= frequency;
  range_normalise_encode(coder);
}

static void range_encoder_flush(RangeCoder *coder) {
  for (int i = 0; i < 4; i++) {
    range_emit(coder, (uint8_t)(coder->low >> 24));
    coder->low <<= 8;
  }
}

static uint8_t range_read(RangeCoder *coder) {
  uint8_t byte = (coder->position < coder->capacity) ? coder->bytes[coder->position] : 0;
  coder->position++;
  return byte;
}

static void range_decoder_init(RangeCoder *coder, const uint8_t *bytes, size_t length) {
  coder->low = 0;
  coder->range = 0xFFFFFFFFu;
  coder->code = 0;
  coder->bytes = (uint8_t *)bytes;
  coder->capacity = length;
  coder->position = 0;
  for (int i = 0; i < 4; i++) {
    coder->code = (coder->code << 8) | range_read(coder);
  }
}

static uint32_t range_decode_freq(RangeCoder *coder, uint32_t total) {
  coder->range /= total;
  return (coder->code - coder->low) / coder->range;
}

static void range_decode_update(RangeCoder *coder, uint32_t cumulative, uint32_t frequency) {
  coder->low += (cumulative * coder->range);
  coder->range *= frequency;
  while (((coder->low ^ (coder->low + coder->range)) < RANGE_TOP) ||
         ((coder->range < RANGE_BOTTOM) && ((coder->range = ((0u - coder->low) & (RANGE_BOTTOM - 1))), 1))) {
    coder->code = (coder->code << 8) | range_read(coder);
    coder->low <<= 8;
    coder->range <<= 8;
  }
}

// Adaptive binary context: counts of 0s and 1s, halved when the total hits the cap (keeps total < BOTTOM).
typedef struct {
  uint16_t count0;
  uint16_t count1;
} BinaryContext;
#define CONTEXT_CAP 8192

static void binary_context_init(BinaryContext *context) {
  context->count0 = 1;
  context->count1 = 1;
}

static void binary_context_update(BinaryContext *context, int bit) {
  if (bit == 0) {
    context->count0++;
  } else {
    context->count1++;
  }
  if ((context->count0 + context->count1) >= CONTEXT_CAP) {
    context->count0 = (uint16_t)((context->count0 + 1) >> 1);
    context->count1 = (uint16_t)((context->count1 + 1) >> 1);
  }
}

static void binary_encode(RangeCoder *coder, BinaryContext *context, int bit) {
  uint32_t total = (uint32_t)(context->count0 + context->count1);
  if (bit == 0) {
    range_encode(coder, 0, context->count0, total);
  } else {
    range_encode(coder, context->count0, context->count1, total);
  }
  binary_context_update(context, bit);
}

static int binary_decode(RangeCoder *coder, BinaryContext *context) {
  uint32_t total = (uint32_t)(context->count0 + context->count1);
  uint32_t value = range_decode_freq(coder, total);
  int bit = (value >= context->count0) ? 1 : 0;
  if (bit == 0) {
    range_decode_update(coder, 0, context->count0);
  } else {
    range_decode_update(coder, context->count0, context->count1);
  }
  binary_context_update(context, bit);
  return bit;
}

static void range_encode_bypass(RangeCoder *coder, uint32_t value, int bits) {   // equiprobable raw bits
  for (int i = bits - 1; i >= 0; i--) {
    range_encode(coder, ((value >> i) & 1u), 1, 2);
  }
}

static uint32_t range_decode_bypass(RangeCoder *coder, int bits) {
  uint32_t value = 0;
  for (int i = 0; i < bits; i++) {
    uint32_t f = range_decode_freq(coder, 2);
    int bit = (f >= 1) ? 1 : 0;
    range_decode_update(coder, (uint32_t)bit, 1);
    value = (value << 1) | (uint32_t)bit;
  }
  return value;
}

// Ascending subband start positions of a `length`-sample multi-level 5/3 block: [0, LL_end, next-band,
// ...]. The bands have very different coefficient statistics, so they get separate contexts. Returns
// the band count.
static int band_starts(int length, int *starts) {
  int sizes[64];
  int levels = dwt_level_count(length);
  int current = length;
  for (int level = 0; level <= levels; level++) {
    sizes[level] = current;
    current = (current + 1) / 2;
  }
  int count = 0;
  starts[count++] = 0;
  for (int level = levels; level >= 1; level--) {
    int start = sizes[level];
    if ((start > starts[count - 1]) && (start < length)) {
      starts[count++] = start;
    }
  }
  return count;
}

// Joint-stereo intensity: zero the Side channel's coefficients in the top JOINT_TOP_BANDS frequency
// bands (the highest-frequency octaves, stored at the END of the coefficient array). The ear is nearly
// phase-deaf above ~6-10 kHz, so collapsing the Side highs to mono drops those bits with little audible
// loss. The decoder needs no change: the zeroed coefficients decode to 0 -> Side high-freq = 0.
static void joint_stereo_zero_side_highs(float *coefficients, int length) {
  int starts[64];
  int band_count = band_starts(length, starts);
  if (band_count <= JOINT_TOP_BANDS) {
    return;                                                // too few bands to keep any stereo high-freq distinction
  }
  int first_zeroed_band = (band_count - JOINT_TOP_BANDS);
  int zero_start = starts[first_zeroed_band];
  for (int i = zero_start; i < length; i++) {
    coefficients[i] = 0.0f;
  }
}

// ------------------------------------------------------------------------- psychoacoustic quant shaping

// Absolute Threshold of Hearing (Terhardt), dB SPL — high at very low and very high frequencies (where
// the ear is insensitive), minimal around 3-4 kHz.
static double ath_db(double frequency) {
  double f = frequency / 1000.0;
  if (f < 0.02) {
    f = 0.02;
  }
  return ((3.64 * pow(f, -0.8)) - (6.5 * exp((-0.6 * (f - 3.3)) * (f - 3.3)))) + (0.001 * pow(f, 4.0));
}

// Per-coefficient quant step = base_step scaled by a (capped) per-subband ATH weight, so the ear's less
// sensitive bands (very high / very low frequency) are quantised more coarsely. Deterministic from
// (length, base_step, sample_rate) so the decoder reproduces it exactly. perceptual == 0 -> flat base_step.
#define PERCEPTUAL_MAX_WEIGHT 8.0
static void compute_steps(int length, float base_step, int perceptual, int sample_rate, float *step_per_coeff) {
  if (!perceptual) {
    for (int i = 0; i < length; i++) {
      step_per_coeff[i] = base_step;
    }
    return;
  }
  int starts[64];
  int band_count = band_starts(length, starts);
  int levels = dwt_level_count(length);
  double nyquist = (sample_rate / 2.0);
  double band_weight[64];
  double minimum_ath = 1e9;
  double band_ath[64];
  for (int b = 0; b < band_count; b++) {
    double center;
    if (b == 0) {
      center = (nyquist / (double)(1 << (levels + 1)));    // LL (sub-bass)
    } else {
      int detail_level = levels - b;                       // band b -> detail band H_{detail_level}
      if (detail_level < 0) {
        detail_level = 0;
      }
      center = ((nyquist * 0.75) / (double)(1 << detail_level));
    }
    band_ath[b] = ath_db(center);
    if (band_ath[b] < minimum_ath) {
      minimum_ath = band_ath[b];
    }
  }
  for (int b = 0; b < band_count; b++) {
    double weight = pow(10.0, ((band_ath[b] - minimum_ath) / 20.0));
    if (weight > PERCEPTUAL_MAX_WEIGHT) {
      weight = PERCEPTUAL_MAX_WEIGHT;
    }
    if (weight < 1.0) {
      weight = 1.0;
    }
    band_weight[b] = weight;
  }
  int band = 0;
  for (int i = 0; i < length; i++) {
    while (((band + 1) < band_count) && (i >= starts[band + 1])) {
      band++;
    }
    step_per_coeff[i] = (float)((double)base_step * band_weight[band]);
  }
}

// ------------------------------------------------------------------ per-channel-block encode / decode

// Each coefficient: zigzag -> magnitude class, coded in UNARY (one context-adaptive bit per step,
// context = (subband, unary position) -> captures the wildly different per-band magnitude statistics),
// then (class-1) raw bypass mantissa bits. One range-coder stream per block per channel (contexts reset
// per block; the block is large so warm-up is cheap and blocks stay independent).
#define BAND_CONTEXTS 8

// Per-context adaptive multi-symbol model over the magnitude classes (counts, range-coded directly so a
// large class costs ~its information content, not a long unary run). Halved when the total hits the cap.
typedef struct {
  uint16_t counts[CLASS_COUNT];
  uint32_t total;
} ClassContext;
#define CLASS_CAP 16384

static void class_context_init(ClassContext *context) {
  for (int s = 0; s < CLASS_COUNT; s++) {
    context->counts[s] = 1;
  }
  context->total = CLASS_COUNT;
}

static void class_context_update(ClassContext *context, int symbol) {
  context->counts[symbol]++;
  context->total++;
  if (context->total >= CLASS_CAP) {
    context->total = 0;
    for (int s = 0; s < CLASS_COUNT; s++) {
      context->counts[s] = (uint16_t)((context->counts[s] + 1) >> 1);
      context->total += context->counts[s];
    }
  }
}

static void class_encode(RangeCoder *coder, ClassContext *context, int symbol) {
  uint32_t cumulative = 0;
  for (int s = 0; s < symbol; s++) {
    cumulative += context->counts[s];
  }
  range_encode(coder, cumulative, context->counts[symbol], context->total);
  class_context_update(context, symbol);
}

static int class_decode(RangeCoder *coder, ClassContext *context) {
  uint32_t target = range_decode_freq(coder, context->total);
  uint32_t cumulative = 0;
  int symbol = 0;
  while ((symbol < (CLASS_COUNT - 1)) && ((cumulative + context->counts[symbol]) <= target)) {
    cumulative += context->counts[symbol];
    symbol++;
  }
  range_decode_update(coder, cumulative, context->counts[symbol]);
  class_context_update(context, symbol);
  return symbol;
}

static size_t encode_block(const int32_t *coefficients, int length, uint8_t **out) {
  RangeCoder coder;
  range_encoder_init(&coder);
  ClassContext class_context[BAND_CONTEXTS];
  for (int c = 0; c < BAND_CONTEXTS; c++) {
    class_context_init(&class_context[c]);
  }
  int starts[64];
  int band_count = band_starts(length, starts);
  int band = 0;
  for (int i = 0; i < length; i++) {
    while (((band + 1) < band_count) && (i >= starts[band + 1])) {
      band++;
    }
    int band_context = (band < BAND_CONTEXTS) ? band : (BAND_CONTEXTS - 1);
    uint32_t value = zigzag(coefficients[i]);
    int klass = magnitude_class(value);
    class_encode(&coder, &class_context[band_context], klass);
    if (klass > 1) {
      uint32_t mantissa = value - (1u << (klass - 1));
      range_encode_bypass(&coder, mantissa, klass - 1);
    }
  }
  range_encoder_flush(&coder);
  *out = coder.bytes;
  return coder.position;
}

static void decode_block(const uint8_t *block, size_t block_length, int length, int32_t *coefficients) {
  RangeCoder coder;
  range_decoder_init(&coder, block, block_length);
  ClassContext class_context[BAND_CONTEXTS];
  for (int c = 0; c < BAND_CONTEXTS; c++) {
    class_context_init(&class_context[c]);
  }
  int starts[64];
  int band_count = band_starts(length, starts);
  int band = 0;
  for (int i = 0; i < length; i++) {
    while (((band + 1) < band_count) && (i >= starts[band + 1])) {
      band++;
    }
    int band_context = (band < BAND_CONTEXTS) ? band : (BAND_CONTEXTS - 1);
    int klass = class_decode(&coder, &class_context[band_context]);
    uint32_t value;
    if (klass == 0) {
      value = 0;
    } else if (klass == 1) {
      value = 1;
    } else {
      uint32_t mantissa = range_decode_bypass(&coder, klass - 1);
      value = (1u << (klass - 1)) + mantissa;
    }
    coefficients[i] = unzigzag(value);
  }
}

// ------------------------------------------------------------------------------ whole-signal codec

typedef struct {
  uint32_t magic;
  uint32_t sample_rate;
  uint16_t channels;
  uint16_t block_samples;
  uint16_t quality;        // 0 = lossless 5/3; >=1 = lossy 9/7 with quant step = quality
  uint16_t flags;          // bit0 = psychoacoustic per-band quant shaping; bit1 = wavelet-packet best-basis (uniform quant); bit2 = joint-stereo intensity (Side highs dropped); bit4 = multichannel pairwise-M/S plan present

  uint64_t frame_count;
} FwaHeader;

// Encode interleaved PCM into a malloc'd .fwa byte stream; returns its length. quality 0 = lossless.
// packet != 0 selects the wavelet-packet best-basis lossy mode (uniform quant; ignores perceptual).
// The psycho mode (perceptual lossy, non-packet) additionally drops the Side channel's high-frequency
// bands -- joint-stereo intensity -- recorded in header flags bit2 (decode-side it is a pure no-op).
static size_t fwacodec_encode(const int16_t *interleaved, long frame_count, int channels, int sample_rate, const char *layout, int pair_enabled, int adapt, int quality, int perceptual, int packet, int joint, int lms, int lms_taps, uint8_t **out) {
  int32_t **planes = checked_malloc((size_t)channels * sizeof(int32_t *));
  for (int c = 0; c < channels; c++) {
    planes[c] = checked_malloc((size_t)frame_count * sizeof(int32_t));
  }
  decorrelate_forward(interleaved, frame_count, channels, planes);

  // M1 layout-aware pairwise Mid/Side (multichannel N>=3; stereo's M/S already done in decorrelate_forward).
  int pairs[MAX_CHANNELS / 2][2];
  int pair_mode[MAX_CHANNELS / 2];
  int pair_count = 0;
  int pairing = (pair_enabled && (channels >= 3));
  if (pairing) {
    pair_count = derive_pairs(channels, layout, pairs);
    for (int k = 0; k < pair_count; k++) {
      int mode = adapt ? ms_pair_beneficial(planes[pairs[k][0]], planes[pairs[k][1]], frame_count) : 1;
      pair_mode[k] = mode;
      if (mode) {
        ms_pair_forward(planes[pairs[k][0]], planes[pairs[k][1]], frame_count);
      }
    }
    pairing = (pair_count > 0);                  // nothing to pair -> plain independent (M0), flag stays clear
  }

  if (lms && (quality == 0)) {                  // lossless LMS: decorrelate each channel in time before blocking
    for (int c = 0; c < channels; c++) {
      lms_forward(planes[c], frame_count, lms_taps);
    }
  }

  int32_t *scratch = checked_malloc((size_t)BLOCK_SAMPLES * sizeof(int32_t));
  int32_t *block_buffer = checked_malloc((size_t)BLOCK_SAMPLES * sizeof(int32_t));
  float *float_block = checked_malloc((size_t)BLOCK_SAMPLES * sizeof(float));
  float *float_scratch = checked_malloc((size_t)BLOCK_SAMPLES * sizeof(float));
  float *step_per_coeff = checked_malloc((size_t)BLOCK_SAMPLES * sizeof(float));
  float step = (float)((quality > 0) ? quality : 1);
  int joint_stereo = ((quality > 0) && joint && !packet && (channels == 2));   // joint-psycho collapses Side highs to mono (stereo only)
  if (packet) {
    measure_synthesis_gain(BLOCK_SAMPLES);                        // per-run 9/7 synthesis-gain table for the R-D best-basis cost
  }

  size_t capacity = (size_t)(frame_count * channels * 2) + 4096;
  uint8_t *stream = checked_malloc(capacity);
  uint16_t header_flags = (uint16_t)((perceptual ? 1u : 0u) | (packet ? 2u : 0u) | (joint_stereo ? 4u : 0u) | (pairing ? 16u : 0u) | ((lms && (quality == 0)) ? (8u | ((uint16_t)(lms_taps & 0xFF) << 8)) : 0u));   // bits 8-15 = LMS tap count
  FwaHeader header = { FWA_MAGIC, (uint32_t)sample_rate, (uint16_t)channels, BLOCK_SAMPLES, (uint16_t)quality, header_flags, (uint64_t)frame_count };
  size_t cursor = 0;
  memcpy(&stream[cursor], &header, sizeof header);
  cursor += sizeof header;
  if (pairing) {                                 // channel-pairing plan: [u8 pair_count] then per pair [u8 a][u8 b][u8 mode]
    stream[cursor++] = (uint8_t)pair_count;
    for (int k = 0; k < pair_count; k++) {
      stream[cursor++] = (uint8_t)pairs[k][0];
      stream[cursor++] = (uint8_t)pairs[k][1];
      stream[cursor++] = (uint8_t)pair_mode[k];
    }
  }

  for (long start = 0; start < frame_count; start += BLOCK_SAMPLES) {
    int length = (int)(((start + BLOCK_SAMPLES) <= frame_count) ? BLOCK_SAMPLES : (frame_count - start));
    for (int channel = 0; channel < channels; channel++) {
      BitWriter tree;
      size_t tree_byte_len = 0;
      if (quality == 0) {                                  // lossless: 5/3 wavelet OR LMS residuals (already in planes)
        memcpy(block_buffer, &planes[channel][start], (size_t)length * sizeof(int32_t));
        if (!lms) {
          dwt53_forward(block_buffer, length, scratch);
        }
      } else if (packet) {                                 // lossy 9/7 wavelet-packet best-basis (uniform or psychoacoustic quant)
        for (int i = 0; i < length; i++) {
          float_block[i] = (float)planes[channel][start + i];
        }
        bitwriter_init(&tree);
        int max_depth = dwt_level_count(length);
        packet_decompose(float_block, length, 0, max_depth, step, float_scratch, &tree);
        tree_byte_len = bitwriter_length(&tree);
        compute_steps(length, step, perceptual, sample_rate, step_per_coeff);   // packet-psycho: ATH weight by position (layout is freq-ordered)
        quantize_block(float_block, block_buffer, length, step_per_coeff);
      } else {                                             // lossy 9/7 dyadic (float) + uniform/psychoacoustic quant
        for (int i = 0; i < length; i++) {
          float_block[i] = (float)planes[channel][start + i];
        }
        dwt97_forward(float_block, length, float_scratch);
        if (joint_stereo && (channel == 1)) {              // Side: drop high-freq stereo (mono above ~6 kHz)
          joint_stereo_zero_side_highs(float_block, length);
        }
        compute_steps(length, step, perceptual, sample_rate, step_per_coeff);
        quantize_block(float_block, block_buffer, length, step_per_coeff);
      }
      uint8_t *encoded;
      size_t encoded_length = encode_block(block_buffer, length, &encoded);
      // packet payload prepends [u16 tree_byte_len][tree bytes]; the [u32] still counts everything after it.
      size_t payload_length = packet ? ((2 + tree_byte_len) + encoded_length) : encoded_length;
      if ((cursor + payload_length + 4) > capacity) {
        capacity = ((cursor + payload_length) + 4) * 2;
        stream = realloc(stream, capacity);
      }
      uint32_t encoded_length32 = (uint32_t)payload_length;
      memcpy(&stream[cursor], &encoded_length32, 4);
      cursor += 4;
      if (packet) {
        uint16_t tree_byte_len16 = (uint16_t)tree_byte_len;
        memcpy(&stream[cursor], &tree_byte_len16, 2);
        cursor += 2;
        memcpy(&stream[cursor], tree.bytes, tree_byte_len);
        cursor += tree_byte_len;
        free(tree.bytes);
      }
      memcpy(&stream[cursor], encoded, encoded_length);
      cursor += encoded_length;
      free(encoded);
    }
  }
  for (int c = 0; c < channels; c++) {
    free(planes[c]);
  }
  free(planes);
  free(scratch);
  free(block_buffer);
  free(float_block);
  free(float_scratch);
  free(step_per_coeff);
  *out = stream;
  return cursor;
}

static int16_t *fwacodec_decode(const uint8_t *stream, long *frame_count_out, int *channels_out, int *sample_rate_out) {
  FwaHeader header;
  memcpy(&header, stream, sizeof header);
  if (header.magic != FWA_MAGIC) {
    fprintf(stderr, "not a fwa stream\n");
    exit(1);
  }
  long frame_count = (long)header.frame_count;
  int channels = (int)header.channels;
  int sample_rate = (int)header.sample_rate;
  int quality = (int)header.quality;
  int perceptual = ((header.flags & 1) != 0);
  int packet = ((header.flags & 2) != 0);
  int lms = ((header.flags & 8) != 0);
  int lms_taps = (int)((header.flags >> 8) & 0xFF);
  int pairing = ((header.flags & 16) != 0);
  float step = (float)((quality > 0) ? quality : 1);
  size_t cursor = sizeof header;

  int pairs[MAX_CHANNELS / 2][2];               // multichannel pairwise-M/S plan (bit4): mirrors the encoder
  int pair_mode[MAX_CHANNELS / 2];
  int pair_count = 0;
  if (pairing) {
    pair_count = stream[cursor++];
    for (int k = 0; k < pair_count; k++) {
      pairs[k][0] = stream[cursor++];
      pairs[k][1] = stream[cursor++];
      pair_mode[k] = stream[cursor++];
    }
  }

  int32_t **planes = checked_malloc((size_t)channels * sizeof(int32_t *));
  for (int c = 0; c < channels; c++) {
    planes[c] = checked_malloc((size_t)frame_count * sizeof(int32_t));
  }
  int32_t *scratch = checked_malloc((size_t)BLOCK_SAMPLES * sizeof(int32_t));
  int32_t *block_buffer = checked_malloc((size_t)BLOCK_SAMPLES * sizeof(int32_t));
  float *float_block = checked_malloc((size_t)BLOCK_SAMPLES * sizeof(float));
  float *float_scratch = checked_malloc((size_t)BLOCK_SAMPLES * sizeof(float));
  float *step_per_coeff = checked_malloc((size_t)BLOCK_SAMPLES * sizeof(float));

  for (long start = 0; start < frame_count; start += BLOCK_SAMPLES) {
    int length = (int)(((start + BLOCK_SAMPLES) <= frame_count) ? BLOCK_SAMPLES : (frame_count - start));
    for (int channel = 0; channel < channels; channel++) {
      uint32_t encoded_length;
      memcpy(&encoded_length, &stream[cursor], 4);
      cursor += 4;
      const uint8_t *coeff_bytes = &stream[cursor];
      size_t coeff_length = encoded_length;
      const uint8_t *tree_bytes = NULL;
      if (packet) {                                        // payload = [u16 tree_byte_len][tree][coeff bytes]
        uint16_t tree_byte_len16;
        memcpy(&tree_byte_len16, &stream[cursor], 2);
        tree_bytes = &stream[cursor + 2];
        coeff_bytes = &stream[cursor + 2 + tree_byte_len16];
        coeff_length = encoded_length - (2 + (size_t)tree_byte_len16);
      }
      decode_block(coeff_bytes, coeff_length, length, block_buffer);
      cursor += encoded_length;
      if (quality == 0) {                                  // lossless: 5/3 wavelet OR LMS residuals (un-predicted after the loop)
        if (!lms) {
          dwt53_inverse(block_buffer, length, scratch);
        }
        memcpy(&planes[channel][start], block_buffer, (size_t)length * sizeof(int32_t));
      } else if (packet) {                                 // lossy 9/7 wavelet-packet: dequantize -> reconstruct -> round
        compute_steps(length, step, perceptual, sample_rate, step_per_coeff);   // matches the encoder (uniform or psychoacoustic)
        dequantize_block(block_buffer, float_block, length, step_per_coeff);
        BitReader treereader;
        bitreader_init(&treereader, tree_bytes);
        int max_depth = dwt_level_count(length);
        packet_reconstruct(float_block, length, 0, max_depth, &treereader, float_scratch);
        for (int i = 0; i < length; i++) {
          planes[channel][start + i] = (int32_t)lrintf(float_block[i]);
        }
      } else {                                             // lossy 9/7 dyadic: dequantize -> inverse -> round
        compute_steps(length, step, perceptual, sample_rate, step_per_coeff);
        dequantize_block(block_buffer, float_block, length, step_per_coeff);
        dwt97_inverse(float_block, length, float_scratch);
        for (int i = 0; i < length; i++) {
          planes[channel][start + i] = (int32_t)lrintf(float_block[i]);
        }
      }
    }
  }
  if (lms && (quality == 0)) {                  // undo the LMS prediction over each whole channel before decorrelation
    for (int c = 0; c < channels; c++) {
      lms_inverse(planes[c], frame_count, lms_taps);
    }
  }
  for (int k = 0; k < pair_count; k++) {        // undo multichannel pairwise M/S before the plain interleave
    if (pair_mode[k]) {
      ms_pair_inverse(planes[pairs[k][0]], planes[pairs[k][1]], frame_count);
    }
  }
  int16_t *interleaved = checked_malloc((size_t)(frame_count * channels) * sizeof(int16_t));
  decorrelate_inverse(planes, frame_count, channels, interleaved);
  for (int c = 0; c < channels; c++) {
    free(planes[c]);
  }
  free(planes);
  free(scratch);
  free(block_buffer);
  free(float_block);
  free(float_scratch);
  free(step_per_coeff);
  *frame_count_out = frame_count;
  *channels_out = channels;
  *sample_rate_out = sample_rate;
  return interleaved;
}

// ------------------------------------------------------------------------------------------- main

#ifndef FWA_NO_MAIN
static uint8_t *read_file(const char *path, size_t *size) {
  FILE *file = fopen(path, "rb");
  if (!file) {
    fprintf(stderr, "cannot open %s\n", path);
    exit(1);
  }
  fseek(file, 0, SEEK_END);
  long length = ftell(file);
  fseek(file, 0, SEEK_SET);
  uint8_t *data = checked_malloc((size_t)length);
  if (fread(data, 1, (size_t)length, file) != (size_t)length) {
    fprintf(stderr, "read %s\n", path);
    exit(1);
  }
  fclose(file);
  *size = (size_t)length;
  return data;
}

// Pull a "<flag> <int>" pair out of argv (wherever it sits), compacting the array so the positional
// arguments that follow still line up. Returns the value, or `fallback` if the flag is absent.
static int extract_int_flag(int *argc, char **argv, const char *flag, int fallback) {
  for (int i = 1; i < (*argc - 1); i++) {
    if (!strcmp(argv[i], flag)) {
      int value = atoi(argv[i + 1]);
      for (int j = i; j < (*argc - 2); j++) {
        argv[j] = argv[j + 2];
      }
      *argc -= 2;
      return value;
    }
  }
  return fallback;
}

// Pull a valueless "<flag>" out of argv (wherever it sits), compacting the array. Returns 1 if present.
static int extract_bool_flag(int *argc, char **argv, const char *flag) {
  for (int i = 1; i < *argc; i++) {
    if (!strcmp(argv[i], flag)) {
      for (int j = i; j < (*argc - 1); j++) {
        argv[j] = argv[j + 1];
      }
      *argc -= 1;
      return 1;
    }
  }
  return 0;
}

// Resolve channel count, sample rate and channel layout (forced overrides win, else the probed source
// values, else the stereo/48k fallbacks), then ingest. `-sr` triggers our own linear resample inside
// read_pcm. `layout_out` (>=64 bytes) gets the layout name driving the multichannel pairwise-M/S.
static int16_t *ingest(const char *input, int forced_channels, int forced_rate,
                       long *frame_count, int *channels_out, int *sample_rate_out, char *layout_out) {
  int native_channels = DEFAULT_CHANNELS;
  int native_rate = DEFAULT_SAMPLE_RATE;
  char layout[64] = "";
  probe_source(input, &native_channels, &native_rate, layout);
  int channels = (forced_channels > 0) ? forced_channels : native_channels;
  if (channels < 1) {
    channels = 1;
  } else if (channels > MAX_CHANNELS) {
    channels = MAX_CHANNELS;
  }
  int sample_rate = (forced_rate > 0) ? forced_rate : native_rate;
  int16_t *pcm = read_pcm(input, frame_count, channels, native_rate, sample_rate);
  if (forced_channels > 0) {                     // ffmpeg downmixed to a canonical layout for the forced count
    snprintf(layout_out, 64, "%s", canonical_layout_name(channels));
  } else {
    snprintf(layout_out, 64, "%s", layout);
  }
  *channels_out = channels;
  *sample_rate_out = sample_rate;
  return pcm;
}

int main(int argc, char **argv) {
  int forced_channels = extract_int_flag(&argc, argv, "-ac", 0);   // force channel count (else auto-detect)
  int forced_rate = extract_int_flag(&argc, argv, "-sr", 0);       // force sample rate via linear resample (else source rate)
  int no_pair = extract_bool_flag(&argc, argv, "-no-pair");        // multichannel: disable pairwise M/S (force independent M0)
  int pair_ms = extract_bool_flag(&argc, argv, "-pair-ms");        // multichannel: force always-M/S (else per-pair adaptive)
  int pair_enabled = !no_pair;
  int adapt = !pair_ms;                                            // N>=3 L/R pairs are adaptive (best-of-both) by default
  if (argc < 3) {
    fprintf(stderr,
            "usage:\n"
            "  %s test in.<any> [quality] [mode] [-ac N] [-sr HZ] [-no-pair] [-pair-ms]   round-trip + ratio/SNR. Q0 mode: 5/3 (default) | lms.\n"
            "                                       lossy mode: uniform | psycho (default) | joint-psycho | packet | packet-psycho\n"
            "  %s enc  in.<any> out.fwa [quality] [mode] [-ac N] [-sr HZ] [-no-pair] [-pair-ms]\n"
            "  %s dec  in.fwa  out.wav\n"
            "  channels/rate default to the source (ffprobe); -ac N forces channels, -sr HZ resamples (linear).\n"
            "  N>=3 channels adaptively Mid/Side the L/R pairs (best-of-both); -no-pair = independent, -pair-ms = force M/S.\n",
            argv[0], argv[0], argv[0]);
    return 1;
  }
  const char *command = argv[1];

  if (!strcmp(command, "test")) {
    long frame_count = 0;
    int channels = 0;
    int sample_rate = 0;
    char layout[64] = "";
    int16_t *pcm = ingest(argv[2], forced_channels, forced_rate, &frame_count, &channels, &sample_rate, layout);
    int quality = (argc > 3) ? atoi(argv[3]) : 0;
    int perceptual = (quality > 0);   // lossy default = psycho (perceptual, no joint-stereo)
    int packet = 0;
    int joint = 0;
    int lms = 0;
    int lms_taps = 4;
    if (argc > 4) {
      if (!strcmp(argv[4], "uniform")) {
        perceptual = 0;
      } else if (!strcmp(argv[4], "packet")) {
        perceptual = 0;
        packet = 1;
      } else if (!strcmp(argv[4], "packet-psycho")) {
        perceptual = 1;
        packet = 1;
      } else if (!strcmp(argv[4], "joint-psycho") || !strcmp(argv[4], "joint")) {
        perceptual = 1;
        joint = 1;
      } else if (!strcmp(argv[4], "lms")) {
        lms = 1;                                                // lossless LMS predictor (Q0 only); optional tap count
        if (argc > 5) {
          lms_taps = atoi(argv[5]);
        }
        lms_taps = (lms_taps < 1) ? 1 : ((lms_taps > LMS_MAX_TAPS) ? LMS_MAX_TAPS : lms_taps);
      }
    }
    uint8_t *stream;
    size_t stream_length = fwacodec_encode(pcm, frame_count, channels, sample_rate, layout, pair_enabled, adapt, quality, perceptual, packet, joint, lms, lms_taps, &stream);
    long decoded_count = 0;
    int decoded_channels = 0;
    int decoded_rate = 0;
    int16_t *decoded = fwacodec_decode(stream, &decoded_count, &decoded_channels, &decoded_rate);
    size_t sample_count = (size_t)(frame_count * channels);
    size_t raw_bytes = sample_count * 2;
    double seconds = (double)frame_count / sample_rate;
    double kbps = ((double)stream_length * 8.0) / (seconds * 1000.0);
    int result = 0;
    if (quality == 0) {
      int lossless = ((decoded_count == frame_count) && (memcmp(pcm, decoded, raw_bytes) == 0));
      char transform_label[32];
      if (lms) {
        snprintf(transform_label, sizeof transform_label, "LMS-%d", lms_taps);
      } else {
        snprintf(transform_label, sizeof transform_label, "5/3 wavelet");
      }
      printf("Q0 lossless (%s) | %.1f s | %dch %dHz | %s | %.2f MB raw -> %.2f MB (%.2f:1, %.0f kbps)\n",
             transform_label, seconds, channels, sample_rate, lossless ? "bit-exact" : "MISMATCH (BUG)",
             (double)raw_bytes / 1e6, (double)stream_length / 1e6, (double)raw_bytes / (double)stream_length, kbps);
      result = lossless ? 0 : 1;
    } else {
      double signal_energy = 0.0;
      double noise_energy = 0.0;
      for (size_t i = 0; i < sample_count; i++) {
        double sample = (double)pcm[i];
        double error = ((double)pcm[i] - (double)decoded[i]);
        signal_energy += (sample * sample);
        noise_energy += (error * error);
      }
      double snr = (noise_energy > 0.0) ? (10.0 * log10(signal_energy / noise_energy)) : 99.99;
      const char *mode_label = packet ? (perceptual ? "packet-psycho" : "packet") : (joint ? "joint-psycho" : (perceptual ? "psychoacoustic" : "uniform"));
      printf("Q%d lossy (%s) | %.1f s | %dch %dHz | SNR %.2f dB | %.2f MB raw -> %.2f MB (%.2f:1, %.0f kbps)\n",
             quality, mode_label, seconds, channels, sample_rate, snr, (double)raw_bytes / 1e6, (double)stream_length / 1e6,
             (double)raw_bytes / (double)stream_length, kbps);
    }
    free(pcm);
    free(stream);
    free(decoded);
    return result;
  }

  if (!strcmp(command, "enc")) {
    if (argc < 4) {
      fprintf(stderr, "usage: %s enc in.<any> out.fwa\n", argv[0]);
      return 1;
    }
    long frame_count = 0;
    int channels = 0;
    int sample_rate = 0;
    char layout[64] = "";
    int16_t *pcm = ingest(argv[2], forced_channels, forced_rate, &frame_count, &channels, &sample_rate, layout);
    int quality = (argc > 4) ? atoi(argv[4]) : 0;
    int perceptual = (quality > 0);
    int packet = 0;
    int joint = 0;
    int lms = 0;
    int lms_taps = 4;
    if (argc > 5) {
      if (!strcmp(argv[5], "uniform")) {
        perceptual = 0;
      } else if (!strcmp(argv[5], "packet")) {
        perceptual = 0;
        packet = 1;
      } else if (!strcmp(argv[5], "packet-psycho")) {
        perceptual = 1;
        packet = 1;
      } else if (!strcmp(argv[5], "joint-psycho") || !strcmp(argv[5], "joint")) {
        perceptual = 1;
        joint = 1;
      } else if (!strcmp(argv[5], "lms")) {
        lms = 1;
        if (argc > 6) {
          lms_taps = atoi(argv[6]);
        }
        lms_taps = (lms_taps < 1) ? 1 : ((lms_taps > LMS_MAX_TAPS) ? LMS_MAX_TAPS : lms_taps);
      }
    }
    uint8_t *stream;
    size_t stream_length = fwacodec_encode(pcm, frame_count, channels, sample_rate, layout, pair_enabled, adapt, quality, perceptual, packet, joint, lms, lms_taps, &stream);
    FILE *file = fopen(argv[3], "wb");
    fwrite(stream, 1, stream_length, file);
    fclose(file);
    printf("wrote %s: %dch %dHz | %.2f MB\n", argv[3], channels, sample_rate, (double)stream_length / 1e6);
    free(pcm);
    free(stream);
    return 0;
  }

  if (!strcmp(command, "dec")) {
    if (argc < 4) {
      fprintf(stderr, "usage: %s dec in.fwa out.wav\n", argv[0]);
      return 1;
    }
    size_t size = 0;
    uint8_t *stream = read_file(argv[2], &size);
    long frame_count = 0;
    int channels = 0;
    int sample_rate = 0;
    int16_t *pcm = fwacodec_decode(stream, &frame_count, &channels, &sample_rate);
    write_wav(argv[3], pcm, frame_count, channels, sample_rate);
    printf("wrote %s: %dch %dHz | %.1f s\n", argv[3], channels, sample_rate, (double)frame_count / sample_rate);
    free(stream);
    free(pcm);
    return 0;
  }

  fprintf(stderr, "unknown command: %s\n", command);
  return 1;
}
#endif

// ---- FWA wrappers: the only externally-visible symbols (everything above stays file-local static). They match
// fwv's qoal_encode/qoal_decode convention: interleaved int16 PCM, `samples` = frames per channel, and a
// self-describing stream (channels / rate / frame count in the fwa header). ----
uint8_t *fwa_encode(const short *pcm, int samples, int channels, int sample_rate, const FwaParams *params, uint64_t *out_size) {
  uint8_t *out = NULL;
  size_t length = fwacodec_encode(pcm, (long)samples, channels, sample_rate, "",
                              params->pair_enabled, params->adapt, params->quality, params->perceptual,
                              params->packet, params->joint, params->lms, params->lms_taps, &out);
  *out_size = (uint64_t)length;
  return out;
}

short *fwa_decode(const uint8_t *blob, uint64_t size, int *channels, int *sample_rate, int *samples) {
  (void)size;   // fwacodec_decode reads the frame/channel/rate counts from the stream header
  long frame_count = 0;
  int decoded_channels = 0, decoded_rate = 0;
  int16_t *pcm = fwacodec_decode(blob, &frame_count, &decoded_channels, &decoded_rate);
  *channels = decoded_channels;
  *sample_rate = decoded_rate;
  *samples = (int)frame_count;
  return pcm;
}
