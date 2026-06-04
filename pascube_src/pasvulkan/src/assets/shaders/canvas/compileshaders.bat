@echo off

setlocal enabledelayedexpansion

set FILLTYPE_NO_TEXTURE=0
set FILLTYPE_TEXTURE=1
set FILLTYPE_ATLAS_TEXTURE=2
set FILLTYPE_VECTOR_PATH=3

"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=vertex -DUSECLIPDISTANCE=0 -DUSETEXTURE=1 -o canvas_vert.spv canvas.vert
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=vertex -DUSECLIPDISTANCE=0 -DUSETEXTURE=0 -o canvas_no_texture_vert.spv canvas.vert

"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_NO_TEXTURE% -DBLENDING=1 -DUSECLIPDISTANCE=0 -DUSENODISCARD=1 -o canvas_frag_no_texture.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_TEXTURE% -DBLENDING=1 -DUSECLIPDISTANCE=0 -DUSENODISCARD=1 -o canvas_frag_texture.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_ATLAS_TEXTURE% -DBLENDING=1 -DUSECLIPDISTANCE=0 -DUSENODISCARD=1 -o canvas_frag_atlas_texture.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_VECTOR_PATH% -DBLENDING=1 -DUSECLIPDISTANCE=0 -DUSENODISCARD=1 -o canvas_frag_vectorpath.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_NO_TEXTURE% -DBLENDING=1 -DUSECLIPDISTANCE=0 -DUSENODISCARD=1 -DGUI_ELEMENTS -o canvas_frag_gui_no_texture.spv canvas.frag

"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_NO_TEXTURE% -DBLENDING=0 -DUSECLIPDISTANCE=0 -DUSENODISCARD=0 -o canvas_frag_no_texture_no_blending.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_TEXTURE% -DBLENDING=0 -DUSECLIPDISTANCE=0 -DUSENODISCARD=0 -o canvas_frag_texture_no_blending.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_ATLAS_TEXTURE% -DBLENDING=0 -DUSECLIPDISTANCE=0 -DUSENODISCARD=0 -o canvas_frag_atlas_texture_no_blending.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_VECTOR_PATH% -DBLENDING=0 -DUSECLIPDISTANCE=0 -DUSENODISCARD=0 -o canvas_frag_vectorpath_no_blending.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_NO_TEXTURE% -DBLENDING=0 -DUSECLIPDISTANCE=0 -DUSENODISCARD=0 -DGUI_ELEMENTS -o canvas_frag_gui_no_texture_no_blending.spv canvas.frag

"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_NO_TEXTURE% -DBLENDING=0 -DUSECLIPDISTANCE=0 -DUSENODISCARD=1 -o canvas_frag_no_texture_no_blending_no_discard.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_TEXTURE% -DBLENDING=0 -DUSECLIPDISTANCE=0 -DUSENODISCARD=1 -o canvas_frag_texture_no_blending_no_discard.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_ATLAS_TEXTURE% -DBLENDING=0 -DUSECLIPDISTANCE=0 -DUSENODISCARD=1 -o canvas_frag_atlas_texture_no_blending_no_discard.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_VECTOR_PATH% -DBLENDING=0 -DUSECLIPDISTANCE=0 -DUSENODISCARD=1 -o canvas_frag_vectorpath_no_blending_no_discard.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_NO_TEXTURE% -DBLENDING=0 -DUSECLIPDISTANCE=0 -DUSENODISCARD=1 -DGUI_ELEMENTS -o canvas_frag_gui_no_texture_no_blending_no_discard.spv canvas.frag

"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=vertex -DUSECLIPDISTANCE=1 -DUSETEXTURE=1 -o canvas_vert_clip_distance.spv canvas.vert
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=vertex -DUSECLIPDISTANCE=1 -DUSETEXTURE=0 -o canvas_no_texture_vert_clip_distance.spv canvas.vert

"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_NO_TEXTURE% -DBLENDING=1 -DUSECLIPDISTANCE=1 -DUSENODISCARD=1 -o canvas_frag_no_texture_clip_distance.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_TEXTURE% -DBLENDING=1 -DUSECLIPDISTANCE=1 -DUSENODISCARD=1 -o canvas_frag_texture_clip_distance.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_ATLAS_TEXTURE% -DBLENDING=1 -DUSECLIPDISTANCE=1 -DUSENODISCARD=1 -o canvas_frag_atlas_texture_clip_distance.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_VECTOR_PATH% -DBLENDING=1 -DUSECLIPDISTANCE=1 -DUSENODISCARD=1 -o canvas_frag_vectorpath_clip_distance.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_NO_TEXTURE% -DBLENDING=1 -DUSECLIPDISTANCE=1 -DUSENODISCARD=1 -DGUI_ELEMENTS -o canvas_frag_gui_no_texture_clip_distance.spv canvas.frag

"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_NO_TEXTURE% -DBLENDING=0 -DUSECLIPDISTANCE=1 -DUSENODISCARD=0 -o canvas_frag_no_texture_no_blending_clip_distance.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_TEXTURE% -DBLENDING=0 -DUSECLIPDISTANCE=1 -DUSENODISCARD=0 -o canvas_frag_texture_no_blending_clip_distance.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_ATLAS_TEXTURE% -DBLENDING=0 -DUSECLIPDISTANCE=1 -DUSENODISCARD=0 -o canvas_frag_atlas_texture_no_blending_clip_distance.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_VECTOR_PATH% -DBLENDING=0 -DUSECLIPDISTANCE=1 -DUSENODISCARD=0 -o canvas_frag_vectorpath_no_blending_clip_distance.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_NO_TEXTURE% -DBLENDING=0 -DUSECLIPDISTANCE=1 -DUSENODISCARD=0 -DGUI_ELEMENTS -o canvas_frag_gui_no_texture_no_blending_clip_distance.spv canvas.frag

"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_NO_TEXTURE% -DBLENDING=0 -DUSECLIPDISTANCE=1 -DUSENODISCARD=1 -o canvas_frag_no_texture_no_blending_clip_distance_no_discard.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_TEXTURE% -DBLENDING=0 -DUSECLIPDISTANCE=1 -DUSENODISCARD=1 -o canvas_frag_texture_no_blending_clip_distance_no_discard.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_ATLAS_TEXTURE% -DBLENDING=0 -DUSECLIPDISTANCE=1 -DUSENODISCARD=1 -o canvas_frag_atlas_texture_no_blending_clip_distance_no_discard.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_VECTOR_PATH% -DBLENDING=0 -DUSECLIPDISTANCE=1 -DUSENODISCARD=1 -o canvas_frag_vectorpath_no_blending_clip_distance_no_discard.spv canvas.frag
"%VULKAN_SDK%/Bin/glslc.exe" -x glsl --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=%FILLTYPE_NO_TEXTURE% -DBLENDING=0 -DUSECLIPDISTANCE=1 -DUSENODISCARD=1 -DGUI_ELEMENTS -o canvas_frag_gui_no_texture_no_blending_clip_distance_no_discard.spv canvas.frag

for %%f in (*.spv) do (
  rem spirv-opt --strip-debug --unify-const --flatten-decorations --eliminate-dead-const %%f -o %%f
  rem spirv-opt --strip-debug --unify-const --flatten-decorations --strength-reduction --simplify-instructions --remove-duplicates --redundancy-elimination --eliminate-dead-code-aggressive --eliminate-dead-branches --eliminate-dead-const %%f -o %%f
  rem spirv-opt -O %%f -o %%f
  rem spirv-opt --strip-debug --unify-const --flatten-decorations --eliminate-dead-const --strength-reduction --simplify-instructions --remove-duplicates -O %%f -o %%f
)

for %%f in (*.glsl) do (
  
  echo Processing %%f . . .

  set glslfile=%%~dpnf.glsl
  set spvfile=%%~dpnf.spv

  set currentfilename=%%f

  set filename=%%~nf
  
  if not "x!filename:_frag=!" == "x!filename!" (
    set stage=frag 
  ) else (
    if not "x!filename:_comp=!" == "x!filename!" (
      set stage=comp
    ) else (
      if not "x!filename:_tesc=!" == "x!filename!" (
        set stage=tesc
      ) else (
        if not "x!filename:_tese=!" == "x!filename!" (
          set stage=tese
        ) else (
          if not "x!filename:_geom=!" == "x!filename!" (
            set stage=geom
          ) else (
            if not "x!filename:_vert=!" == "x!filename!" (
              set stage=vert
            ) else (
              echo Unknown shader program stage
              exit /b 1
            )
          )
        )
      )
    )
  )
  
  "%VULKAN_SDK%/Bin/glslangValidator.exe" -S !stage! -V "!glslfile!" -o "!spvfile!" && (
rem    "%VULKAN_SDK%/Bin/spirv-opt.exe" --strip-debug --unify-const --flatten-decorations --strength-reduction --simplify-instructions --remove-duplicates --redundancy-elimination --eliminate-dead-code-aggressive --eliminate-dead-branches --eliminate-dead-const "!spvfile!" -o "!spvfile!" && (
rem      echo "!spvfile! generated . . ."
rem    ) || (
rem      goto :Error
rem    )
  ) || (
    goto :Error
  )
  
)

goto Done

:Error
echo Error at processing !currentfilename!
exit /b 1

:Done

exit /b 0







