#!/bin/bash

FILLTYPE_NO_TEXTURE=0
FILLTYPE_TEXTURE=1
FILLTYPE_ATLAS_TEXTURE=2
FILLTYPE_VECTOR_PATH=3

glslc -x glsl -g --target-env=vulkan -fshader-stage=vertex -DUSECLIPDISTANCE=0 -DUSETEXTURE=1 -o canvas_vert.spv canvas.vert
glslc -x glsl -g --target-env=vulkan -fshader-stage=vertex -DUSECLIPDISTANCE=0 -DUSETEXTURE=0 -o canvas_no_texture_vert.spv canvas.vert

glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_NO_TEXTURE -DBLENDING=1 -DUSECLIPDISTANCE=0 -DUSENODISCARD=1 -o canvas_frag_no_texture.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_TEXTURE -DBLENDING=1 -DUSECLIPDISTANCE=0 -DUSENODISCARD=1 -o canvas_frag_texture.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_ATLAS_TEXTURE -DBLENDING=1 -DUSECLIPDISTANCE=0 -DUSENODISCARD=1 -o canvas_frag_atlas_texture.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_VECTOR_PATH -DBLENDING=1 -DUSECLIPDISTANCE=0 -DUSENODISCARD=1 -o canvas_frag_vectorpath.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_NO_TEXTURE -DBLENDING=1 -DUSECLIPDISTANCE=0 -DUSENODISCARD=1 -DGUI_ELEMENTS -o canvas_frag_gui_no_texture.spv canvas.frag

glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_NO_TEXTURE -DBLENDING=0 -DUSECLIPDISTANCE=0 -DUSENODISCARD=0 -o canvas_frag_no_texture_no_blending.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_TEXTURE -DBLENDING=0 -DUSECLIPDISTANCE=0 -DUSENODISCARD=0 -o canvas_frag_texture_no_blending.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_ATLAS_TEXTURE -DBLENDING=0 -DUSECLIPDISTANCE=0 -DUSENODISCARD=0 -o canvas_frag_atlas_texture_no_blending.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_VECTOR_PATH -DBLENDING=0 -DUSECLIPDISTANCE=0 -DUSENODISCARD=0 -o canvas_frag_vectorpath_no_blending.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_NO_TEXTURE -DBLENDING=0 -DUSECLIPDISTANCE=0 -DUSENODISCARD=0 -DGUI_ELEMENTS -o canvas_frag_gui_no_texture_no_blending.spv canvas.frag

glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_NO_TEXTURE -DBLENDING=0 -DUSECLIPDISTANCE=0 -DUSENODISCARD=1 -o canvas_frag_no_texture_no_blending_no_discard.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_TEXTURE -DBLENDING=0 -DUSECLIPDISTANCE=0 -DUSENODISCARD=1 -o canvas_frag_texture_no_blending_no_discard.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_ATLAS_TEXTURE -DBLENDING=0 -DUSECLIPDISTANCE=0 -DUSENODISCARD=1 -o canvas_frag_atlas_texture_no_blending_no_discard.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_VECTOR_PATH -DBLENDING=0 -DUSECLIPDISTANCE=0 -DUSENODISCARD=1 -o canvas_frag_vectorpath_no_blending_no_discard.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_NO_TEXTURE -DBLENDING=0 -DUSECLIPDISTANCE=0 -DUSENODISCARD=1 -DGUI_ELEMENTS -o canvas_frag_gui_no_texture_no_blending_no_discard.spv canvas.frag

glslc -x glsl -g --target-env=vulkan -fshader-stage=vertex -DUSECLIPDISTANCE=1 -DUSETEXTURE=1 -o canvas_vert_clip_distance.spv canvas.vert
glslc -x glsl -g --target-env=vulkan -fshader-stage=vertex -DUSECLIPDISTANCE=1 -DUSETEXTURE=0 -o canvas_no_texture_vert_clip_distance.spv canvas.vert

glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_NO_TEXTURE -DBLENDING=1 -DUSECLIPDISTANCE=1 -DUSENODISCARD=1 -o canvas_frag_no_texture_clip_distance.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_TEXTURE -DBLENDING=1 -DUSECLIPDISTANCE=1 -DUSENODISCARD=1 -o canvas_frag_texture_clip_distance.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_ATLAS_TEXTURE -DBLENDING=1 -DUSECLIPDISTANCE=1 -DUSENODISCARD=1 -o canvas_frag_atlas_texture_clip_distance.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_VECTOR_PATH -DBLENDING=1 -DUSECLIPDISTANCE=1 -DUSENODISCARD=1 -o canvas_frag_vectorpath_clip_distance.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_NO_TEXTURE -DBLENDING=1 -DUSECLIPDISTANCE=1 -DUSENODISCARD=1 -DGUI_ELEMENTS -o canvas_frag_gui_no_texture_clip_distance.spv canvas.frag

glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_NO_TEXTURE -DBLENDING=0 -DUSECLIPDISTANCE=1 -DUSENODISCARD=0 -o canvas_frag_no_texture_no_blending_clip_distance.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_TEXTURE -DBLENDING=0 -DUSECLIPDISTANCE=1 -DUSENODISCARD=0 -o canvas_frag_texture_no_blending_clip_distance.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_ATLAS_TEXTURE -DBLENDING=0 -DUSECLIPDISTANCE=1 -DUSENODISCARD=0 -o canvas_frag_atlas_texture_no_blending_clip_distance.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_VECTOR_PATH -DBLENDING=0 -DUSECLIPDISTANCE=1 -DUSENODISCARD=0 -o canvas_frag_vectorpath_no_blending_clip_distance.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_NO_TEXTURE -DBLENDING=0 -DUSECLIPDISTANCE=1 -DUSENODISCARD=0 -DGUI_ELEMENTS -o canvas_frag_gui_no_texture_no_blending_clip_distance.spv canvas.frag

glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_NO_TEXTURE -DBLENDING=0 -DUSECLIPDISTANCE=1 -DUSENODISCARD=1 -o canvas_frag_no_texture_no_blending_clip_distance_no_discard.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_TEXTURE -DBLENDING=0 -DUSECLIPDISTANCE=1 -DUSENODISCARD=1 -o canvas_frag_texture_no_blending_clip_distance_no_discard.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_ATLAS_TEXTURE -DBLENDING=0 -DUSECLIPDISTANCE=1 -DUSENODISCARD=1 -o canvas_frag_atlas_texture_no_blending_clip_distance_no_discard.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_VECTOR_PATH -DBLENDING=0 -DUSECLIPDISTANCE=1 -DUSENODISCARD=1 -o canvas_frag_vectorpath_no_blending_clip_distance_no_discard.spv canvas.frag
glslc -x glsl -g --target-env=vulkan -fshader-stage=fragment -DFILLTYPE=$FILLTYPE_NO_TEXTURE -DBLENDING=0 -DUSECLIPDISTANCE=1 -DUSENODISCARD=1 -DGUI_ELEMENTS -o canvas_frag_gui_no_texture_no_blending_clip_distance_no_discard.spv canvas.frag

#!/bin/bash

# Loop over *.spv files
#for f in *.spv; do
  # Uncomment desired commands
  # spirv-opt --strip-debug --unify-const --flatten-decorations --eliminate-dead-const $f -o $f
  # spirv-opt --strip-debug --unify-const --flatten-decorations --strength-reduction --simplify-instructions --remove-duplicates --redundancy-elimination --eliminate-dead-code-aggressive --eliminate-dead-branches --eliminate-dead-const $f -o $f
  # spirv-opt -O $f -o $f
  # spirv-opt --strip-debug --unify-const --flatten-decorations --eliminate-dead-const --strength-reduction --simplify-instructions --remove-duplicates -O $f -o $f
#done

# Loop over *.glsl files
for f in *.glsl; do
  echo "Processing $f . . ."

  glslfile="${f%.*}.glsl"
  spvfile="${f%.*}.spv"

  currentfilename="$f"

  filename="${f%.*}"

  if [[ $filename == *_frag* ]]; then
    stage=frag
  elif [[ $filename == *_comp* ]]; then
    stage=comp
  elif [[ $filename == *_tesc* ]]; then
    stage=tesc
  elif [[ $filename == *_tese* ]]; then
    stage=tese
  elif [[ $filename == *_geom* ]]; then
    stage=geom
  elif [[ $filename == *_vert* ]]; then
    stage=vert
  else
    echo "Unknown shader program stage"
    exit 1
  fi

  glslangValidator -g -S $stage -V "$glslfile" -o "$spvfile" && {
    echo >/dev/null
    # spirv-opt --strip-debug --unify-const --flatten-decorations --strength-reduction --simplify-instructions --remove-duplicates --redundancy-elimination --eliminate-dead-code-aggressive --eliminate-dead-branches --eliminate-dead-const "$spvfile" -o "$spvfile" && {
    #   echo "$spvfile generated . . ."
    # } || {
    #   exitWithError
    # }
  } || {
    exitWithError
  }
done

exit 0

exitWithError() {
  echo "Error at processing $currentfilename"
  exit 1
}
