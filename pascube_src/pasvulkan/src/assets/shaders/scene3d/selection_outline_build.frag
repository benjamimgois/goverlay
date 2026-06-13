#version 460 core

// Object-selection outline — outline BUILD pass (branch objectselectiontry1).
//
// Reads the selection mask (RG32UI: .x = instanceDataIndex, .y = depth bits) and writes the border ring into an ISOLATED premultiplied
// outline buffer: rgb = outlineColor * coverage, a = coverage; empty everywhere else. The scene is NOT touched here. A separate
// FXAA+composite pass then anti-aliases this buffer in isolation (so the already-AA'd scene never gets a second blur) and
// composites it over the scene under the UI.
//
// Edge = fixed-radius DILATION (cheap): a non-selected pixel that has a selected pixel within `thickness` is an outline pixel;
// the nearest selected pixel gives the distance for the AA smoothstep. Occlusion/x-ray "for free": occluded selected objects
// are still in the mask (the mask pass uses its own depth, not the scene depth), so their outline shows through.

#extension GL_EXT_samplerless_texture_functions : require
#extension GL_GOOGLE_include_directive : require

/* clang-format off */

#ifdef MULTIVIEW
  #extension GL_EXT_multiview : require
  #define VIEW_LAYER gl_ViewIndex
#else
  #define VIEW_LAYER 0
#endif
// The frame-graph creates 2D_ARRAY image views for these surface resources even for a single view -> always declare the
// sampler as 2D_ARRAY (layer 0 when single-view) so the OpTypeImage matches the view type (else VUID-vkCmdDraw-viewType-07752).
layout(set = 0, binding = 0) uniform utexture2DArray uSelectionMask;

layout(push_constant) uniform PushConstants {
  vec4 outlineColor;   // xyz = fallback color, w = fallback intensity/strength (used when the object has no SelectedColorIntensity)
  vec4 params;         // x = thickness (px), y/z/w = unused (kept for layout stability)
} pushConstants;

// Per-object outline color: mask.x IS the instance data index (instanceDataItems have their own IDs, NOT the object ID) ->
// look up its SelectedColorIntensity. Same buffer as the engine's set 0 binding 6, but bound here as set 1 = the
// GlobalVulkanDescriptorSet (like the selection list/mask passes).
#include "instance_data_struct.glsl"

layout(set = 1, binding = 6, std430) readonly buffer InstanceDataBuffer {
  InstanceData instanceDataItems[];
};

layout(location = 0) out vec4 outFragColor;

uvec2 fetchMask(const in ivec2 p){
  return texelFetch(uSelectionMask, ivec3(p, VIEW_LAYER), 0).xy;
}

void main(){
  ivec2 p = ivec2(gl_FragCoord.xy);

  // Interior of a selected object -> no outline (empty; a fill tint could go here later).
  if(fetchMask(p).x != 0u){
    outFragColor = vec4(0.0);
    return;
  }

  float thickness = max(1.0, pushConstants.params.x);
  int radius = int(ceil(thickness));

  float bestDist = thickness + 1.0;
  uint bestInstanceDataIndex = 0u;
  bool found = false;

  for(int dy = -radius; dy <= radius; dy++){
    for(int dx = -radius; dx <= radius; dx++){
      if((dx == 0) && (dy == 0)){
        continue;
      }
      ivec2 q = p + ivec2(dx, dy);
      uvec2 m = fetchMask(q);
      if(m.x != 0u){
        float d = length(vec2(dx, dy));
        if(d < bestDist){
          bestDist = d;
          bestInstanceDataIndex = m.x; // nearest selected pixel's instance data index (mask.x)
          found = true;
        }
      }
    }
  }

  if((!found) || (bestDist > thickness)){
    outFragColor = vec4(0.0); // no selected pixel within the border thickness
    return;
  }

  // Anti-aliased ring (perpendicular falloff); the along-silhouette staircase is smoothed by the following FXAA pass.
  float aa = 1.0 - smoothstep(thickness - 1.0, thickness, bestDist);

  // Per-object color/intensity from the nearest selected pixel's instance data. mask.x is the RAW inInstanceDataIndex whose
  // bit 31 is a flag (see mesh.frag) -> mask it off to get the real array index. Fall back to the push color only when the
  // instance has NO selection color set at all -> key the fallback on the whole vec4, NOT on .w alone: the intensity (.w) can
  // legitimately pulse through 0 (animated), and keying on .w made the outline drop to the fallback at every pulse trough.
  vec4 sci = instanceDataItems[bestInstanceDataIndex & 0x7fffffffu].SelectedColorIntensity;
  bool hasPerObject = max(max(sci.x, sci.y), max(sci.z, sci.w)) > 1e-6;
  vec3 color = hasPerObject ? sci.xyz : pushConstants.outlineColor.xyz;
  float intensity = hasPerObject ? sci.w : pushConstants.outlineColor.w;
  float coverage = clamp(intensity * aa, 0.0, 1.0);

  // Premultiplied: rgb already weighted by coverage so the FXAA pass can lerp all four channels consistently.
  outFragColor = vec4(color * coverage, coverage);
}
