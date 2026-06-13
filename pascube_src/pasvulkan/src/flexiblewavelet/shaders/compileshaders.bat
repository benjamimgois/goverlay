@echo off
rem Compile the Flexible Wavelet Video (FWV) compute shaders to SPIR-V (one .spv per .comp).
rem Run after editing any shader; ..\..\assets\convert.dpr then embeds the .spv into the engine
rem (PasVulkanAssets.inc) as the FlexibleWaveletVideo<Name>SPIRV Pascal byte-array constants.

for %%s in (*.comp) do "%VULKAN_SDK%\Bin\glslc.exe" -O --target-env=vulkan -fshader-stage=compute "%%s" -o "%%~ns.spv"
