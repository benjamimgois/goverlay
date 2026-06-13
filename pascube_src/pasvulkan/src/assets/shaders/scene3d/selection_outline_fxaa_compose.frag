#version 460 core

// Object-selection outline — FXAA + composite pass (branch objectselectiontry1).
//
// Anti-aliases the ISOLATED premultiplied outline buffer (from the outline-build pass) in isolation, then composites it over
// the scene (premultiplied-over) under the UI. Because FXAA only ever sees the outline buffer, the already-AA'd scene never
// gets a second blur. The outline buffer is premultiplied (rgb = color*coverage, a = coverage) so the same FXAA lerp applies
// to all four channels consistently -> the composite silhouette is anti-aliased, not just the colour.
//
// FXAA core adapted from antialiasing_fxaa.frag (linear-space, luma from rgb; no tonemapping since this is the LDR overlay).

#extension GL_EXT_samplerless_texture_functions : require

/* clang-format off */

#ifdef MULTIVIEW
  #extension GL_EXT_multiview : require
  #define VIEW_LAYER gl_ViewIndex
#else
  #define VIEW_LAYER 0
#endif
// Both are surface resources with 2D_ARRAY views even single-view (layer 0) -> always declare 2D_ARRAY so OpTypeImage matches
// the view type (VUID-vkCmdDraw-viewType-07752).
layout(set = 0, binding = 0) uniform sampler2DArray uOutline;    // premultiplied outline buffer (LINEAR clamped sampler)
layout(set = 0, binding = 1) uniform texture2DArray uSceneColor; // scene color (point read, composited under)

layout(location = 0) in vec2 inTexCoord;
layout(location = 0) out vec4 outFragColor;

vec4 fetchScene(const in ivec2 p){
  return texelFetch(uSceneColor, ivec3(p, VIEW_LAYER), 0);
}

vec4 sampleOutline(const in vec2 uv){
  return textureLod(uOutline, vec3(uv, float(VIEW_LAYER)), 0.0);
}

// textureLodOffset requires a compile-time-constant offset, so this must be a macro with literal offsets (not a function).
#define SAMPLE_OUTLINE_OFFSET(uv, ox, oy) textureLodOffset(uOutline, vec3((uv), float(VIEW_LAYER)), 0.0, ivec2((ox), (oy)))

void main(){
  vec2 invScale = vec2(1.0) / vec2(textureSize(uOutline, 0).xy);
  vec4 p = vec4(inTexCoord, inTexCoord - (invScale * (0.5 + (1.0 / 4.0))));

  const float FXAA_SPAN_MAX = 8.0,
              FXAA_REDUCE_MUL = 1.0 / 8.0,
              FXAA_REDUCE_MIN = 1.0 / 128.0;
  const vec3 luma = vec3(0.2126, 0.7152, 0.0722);

  vec4 cNW = sampleOutline(p.zw),
       cNE = SAMPLE_OUTLINE_OFFSET(p.zw, 1, 0),
       cSW = SAMPLE_OUTLINE_OFFSET(p.zw, 0, 1),
       cSE = SAMPLE_OUTLINE_OFFSET(p.zw, 1, 1),
       cM  = sampleOutline(p.xy);

  float lumaNW = dot(cNW.xyz, luma),
        lumaNE = dot(cNE.xyz, luma),
        lumaSW = dot(cSW.xyz, luma),
        lumaSE = dot(cSE.xyz, luma),
        lumaM  = dot(cM.xyz, luma),
        lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE))),
        lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));

  vec2 dir = vec2(-((lumaNW + lumaNE) - (lumaSW + lumaSE)), ((lumaNW + lumaSW) - (lumaNE + lumaSE)));
  float dirReduce = max((lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN),
        rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);
  dir = min(vec2(FXAA_SPAN_MAX), max(vec2(-FXAA_SPAN_MAX), dir * rcpDirMin)) * invScale;

  vec4 rgbA = 0.5 * (sampleOutline(p.xy + (dir * ((1.0 / 3.0) - 0.5))) +
                     sampleOutline(p.xy + (dir * ((2.0 / 3.0) - 0.5))));
  vec4 rgbB = (rgbA * 0.5) + (0.25 * (sampleOutline(p.xy + (dir * ((0.0 / 3.0) - 0.5))) +
                                      sampleOutline(p.xy + (dir * ((3.0 / 3.0) - 0.5)))));
  float lumaB = dot(rgbB.xyz, luma);
  vec4 outline = ((lumaB < lumaMin) || (lumaB > lumaMax)) ? rgbA : rgbB;

  // Premultiplied-over composite onto the scene (under the UI).
  vec4 scene = fetchScene(ivec2(gl_FragCoord.xy));
  outFragColor = vec4((scene.rgb * (1.0 - outline.a)) + outline.rgb, scene.a);
}
