#!/bin/sh
# Train CNN upscaler model from PNG files in data/ subdirectory
# Usage: ./train.sh [2x|4x] [srgb|linear] [--gpu] [--host-mem]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Defaults
FACTOR=2
COLORSPACE=srgb
USE_GPU=0
HOST_MEM=0
QUALITY=low

# Parse arguments (order-independent)
for arg in "$@"; do
    case "$arg" in
        2x|2)      FACTOR=2 ;;
        4x|4)      FACTOR=4 ;;
        srgb)      COLORSPACE=srgb ;;
        linear)    COLORSPACE=linear ;;
        --gpu|gpu) USE_GPU=1 ;;
        --host-mem) HOST_MEM=1 ;;
        low)       QUALITY=low ;;
        mid|medium) QUALITY=mid ;;
        high)      QUALITY=high ;;
        -h|--help)
            echo "Usage: $0 [2x|4x] [srgb|linear] [low|mid|high] [--gpu] [--host-mem]"
            echo ""
            echo "  2x|4x       Upscale factor (default: 2x)"
            echo "  srgb|linear Color space (default: srgb)"
            echo "  low         200 epochs, batch 16, feat 64/32 (default)"
            echo "  mid         400 epochs, batch 32, feat 64/32, deep"
            echo "  high        600 epochs, batch 64, feat 128/64, deep"
            echo "  --gpu       Use Vulkan compute backend"
            echo "  --host-mem  Force host-visible memory (slower, for debugging)"
            exit 0 ;;
        *)
            echo "Unknown argument: $arg"
            echo "Usage: $0 [2x|4x] [srgb|linear] [low|mid|high] [--gpu] [--host-mem]"
            exit 1 ;;
    esac
done

# Quality presets
case "$QUALITY" in
    low)
        EPOCHS=200; BATCH=16; FEAT1=64; FEAT2=32; DEEP=""; LR_DECAY=100 ;;
    mid)
        EPOCHS=400; BATCH=32; FEAT1=64; FEAT2=32; DEEP="--deep"; LR_DECAY=100 ;;
    high)
        EPOCHS=600; BATCH=64; FEAT1=128; FEAT2=64; DEEP="--deep"; LR_DECAY=150 ;;
esac

SUFFIX="${FACTOR}x_${COLORSPACE}_${QUALITY}"
MODEL="model_${SUFFIX}.bin"

# Build if needed
BUILD_ARGS="CC=${CC:-gcc} OPENMP=1"
if [ "$USE_GPU" -eq 1 ]; then
    BUILD_ARGS="$BUILD_ARGS VULKAN=1"
fi

if [ ! -f ./upscaler ] || [ ./upscaler -ot main.c ] || [ ./upscaler -ot cnn.c ] || [ ./upscaler -ot image.c ] || [ ./upscaler -ot export.c ] || [ ./upscaler -ot vk_backend.c ] || [ ./upscaler -ot vk_cnn.c ]; then
    echo "Building upscaler ($BUILD_ARGS)..."
    make $BUILD_ARGS
fi

# Check data directory
if [ ! -d data ] || [ -z "$(ls data/*.png 2>/dev/null)" ]; then
    echo "ERROR: No PNG files found in $SCRIPT_DIR/data/"
    echo "Place your ground-truth (full resolution) PNG images in the data/ directory."
    exit 1
fi

echo "=== Training ${FACTOR}x upscaler (${COLORSPACE}, ${QUALITY}$([ "$USE_GPU" -eq 1 ] && echo ', Vulkan GPU')) ==="
echo "Model output: ${MODEL}"
echo ""

GPU_FLAG=""
[ "$USE_GPU" -eq 1 ] && GPU_FLAG="--gpu"
[ "$HOST_MEM" -eq 1 ] && GPU_FLAG="$GPU_FLAG --host-mem"

./upscaler train \
    --data data \
    --factor "$FACTOR" \
    --colorspace "$COLORSPACE" \
    --epochs "$EPOCHS" \
    --batch "$BATCH" \
    --patch 32 \
    $DEEP \
    --lr 0.001 \
    --lr-decay "$LR_DECAY" \
    --feat1 "$FEAT1" \
    --feat2 "$FEAT2" \
    --loss l1 \
    --save-every 50 \
    --output "$MODEL" \
    $GPU_FLAG

echo ""
echo "=== Training complete ==="
echo "Model saved to: $SCRIPT_DIR/$MODEL"
echo ""
echo "Export to GLSL:"
echo "  ./upscaler export --model $MODEL --format glsl --output upscaler_weights_${SUFFIX}.glsl"
echo ""
echo "Run inference:"
echo "  ./upscaler infer --model $MODEL --input test.png --output test_hr.png${GPU_FLAG:+ $GPU_FLAG}"
