@echo off
setlocal enabledelayedexpansion
del test.spv >nul 2>nul
"%VULKAN_SDK%/Bin/glslc.exe" -o test.spv test.glsl || pause
rem pause