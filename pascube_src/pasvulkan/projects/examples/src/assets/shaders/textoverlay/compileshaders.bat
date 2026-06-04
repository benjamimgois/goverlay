@echo off
"%VULKAN_SDK%/Bin32/glslangValidator.exe" -V textoverlay.vert -o textoverlay_vert.spv
"%VULKAN_SDK%/Bin32/glslangValidator.exe" -V textoverlay.frag -o textoverlay_frag.spv
for %%f in (*.spv) do (
  rem spirv-opt --strip-debug --unify-const --flatten-decorations --eliminate-dead-const %%f -o %%f
  spirv-opt --strip-debug --unify-const --flatten-decorations --eliminate-dead-const --strength-reduction --simplify-instructions --remove-duplicates -O %%f -o %%f
)
copy /y textoverlay_vert.spv ..\..\..\..\assets\shaders\textoverlay\textoverlay_vert.spv
copy /y textoverlay_frag.spv ..\..\..\..\assets\shaders\textoverlay\textoverlay_frag.spv
del /f /q *.spv
