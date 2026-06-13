# Flexible Wavelet (FWV) — GPU wavelet codec
CC     ?= cc
# -ftrivial-auto-var-init=zero: zero-init all auto/stack locals. Standard hardening (Linux kernel / Chrome / Android)
# that makes an otherwise build-layout-dependent uninitialized-stack-local read deterministic + correct here (it was
# intermittently corrupting the encode output in ~a few %% of builds; invisible to ASan/UBSan/Valgrind/gdb). ~free.
CFLAGS ?= -O2 -Wall -Wextra -Wno-unused-function -std=c11 -ftrivial-auto-var-init=zero
GLSLC  ?= glslc

SPV = shaders/bitplane_unpack.spv shaders/dequant97.spv shaders/transpose_f.spv \
      shaders/idwt97row.spv shaders/round97.spv shaders/color.spv \
      shaders/rgb2yco.spv shaders/fwd97row.spv shaders/quant97fwd.spv \
      shaders/bitplane_size.spv shaders/bitplane_pack.spv \
      shaders/idwt53row.spv shaders/fwd53row.spv shaders/rgb2ycor.spv \
      shaders/coeff_diff.spv shaders/coeff_add.spv shaders/ycocg_diff.spv shaders/frame_energy.spv \
      shaders/mc.spv shaders/motion_add.spv shaders/motion_estimate.spv \
      shaders/apply_pcrd.spv shaders/chroma_downsample.spv \
      shaders/rgb2yco16.spv shaders/rgb2ycor16.spv shaders/color_hdr.spv shaders/color_hdr_scrgb.spv \
      shaders/tdwt_int.spv shaders/tdwt_float.spv shaders/nv12rgb.spv shaders/bidi_blend.spv shaders/motion_estimate_bidi.spv \
      shaders/mode_decide.spv shaders/blend_mode.spv \
      shaders/bitplane_pack_coop.spv shaders/bitplane_size_coop.spv shaders/motion_merge.spv \
      shaders/bidi_mode_sad.spv shaders/motion_merge_bidi.spv shaders/mode_decide_root.spv \
      shaders/int2float.spv

all: fwvwave fwvdec fwvenc fwvplay fwa

fwvwave: fwvwave.c
	$(CC) $(CFLAGS) -o $@ $< -lm

shaders/%.spv: shaders/%.comp
	$(GLSLC) -O $< -o $@

fwvdec: fwvdec.c fwvwave.c $(SPV)
	$(CC) $(CFLAGS) -Wno-missing-field-initializers -o $@ fwvdec.c -lvulkan -lm

fwvenc: fwvenc.c fwvwave.c fwa_audio.c fwa_audio.h $(SPV)
	$(CC) $(CFLAGS) -DFWA_NO_MAIN -Wno-missing-field-initializers -o $@ fwvenc.c fwa_audio.c -lvulkan -lm

fwvplay: fwvplay.c fwvwave.c fwa_audio.c fwa_audio.h fwv_h264.c fwv_h264.h avi_writer.c avi_writer.h stb_vorbis.c $(SPV)
	$(CC) $(CFLAGS) -DFWA_NO_MAIN -Wno-missing-field-initializers $(shell pkg-config --cflags sdl2) -o $@ fwvplay.c fwv_h264.c avi_writer.c fwa_audio.c $(shell pkg-config --libs sdl2) -lvulkan -lm

# standalone FWA audio CLI (test/enc/dec) — built WITHOUT -DFWA_NO_MAIN so fwa_audio.c's own main() is active
fwa: fwa_audio.c fwa_audio.h
	$(CC) $(CFLAGS) -Wno-missing-field-initializers -o $@ fwa_audio.c -lm

clean:
	rm -f fwvwave fwvdec fwvenc fwvplay fwa shaders/*.spv

.PHONY: all clean
