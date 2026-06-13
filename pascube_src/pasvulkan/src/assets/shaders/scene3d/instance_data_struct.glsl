#ifndef INSTANCE_DATA_STRUCT_GLSL
#define INSTANCE_DATA_STRUCT_GLSL

// Shared InstanceData layout (std430) — single source of truth for the per-instance GPU data. Used by globaldescriptorset.glsl
// (the engine's set 0, binding 6 InstanceDataBuffer) and by the object-selection outline build pass (which binds the same
// buffer as set 1, binding 6). Must match the GPU layout of TpvScene3D.TInstanceData.

struct InstanceData {

  uvec4 SelectedDissolveDitheredTransparencyFlags;

  vec4 SelectedColorIntensity;

  vec4 DissolveColor0Scale;
  vec4 DissolveColor1Width;

  uvec4 colorKeysRG; // 2x half float RGBA
  uvec4 colorKeysBA; // 2x half float RGBA

  uvec4 materialColorKeys; // 4x packed RGBA8 per-material color tinting
  uvec4 unused1;
};

#endif // INSTANCE_DATA_STRUCT_GLSL
