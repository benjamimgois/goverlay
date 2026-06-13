#!/bin/bash
# Compile the Flexible Wavelet Video (FWV) compute shaders to SPIR-V (one .spv per .comp).
# Run after editing any shader; ../../assets/convert.dpr then embeds the .spv into the engine
# (PasVulkanAssets.inc) as the FlexibleWaveletVideo<Name>SPIRV Pascal byte-array constants.

for shader in *.comp; do
  glslc -O --target-env=vulkan -fshader-stage=compute "$shader" -o "${shader%.comp}.spv"
done
