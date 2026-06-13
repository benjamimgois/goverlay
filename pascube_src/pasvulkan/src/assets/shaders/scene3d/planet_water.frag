#version 460 core

#pragma shader_stage(fragment)

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable
#extension GL_EXT_nonuniform_qualifier : enable
#extension GL_EXT_control_flow_attributes : enable
#if defined(USEDEMOTE)
  #extension GL_EXT_demote_to_helper_invocation : enable
#endif
#ifdef WIREFRAME
  #extension GL_EXT_fragment_shader_barycentric : enable
  #define HAVE_PERVERTEX
#endif

#if defined(TESSELLATION)
layout(early_fragment_tests) in;
#endif
      
// MSAA_FAST = MSAA input but not MSAA output, so that the water isn't multisampled then.

#define LIGHTCLUSTERS
#define FRUSTUMCLUSTERGRID

#define LIGHTS 
#define SHADOWS

#include "bufferreference_definitions.glsl"

#if defined(TESSELLATION)
layout(location = 0) in InBlock {
  vec3 localPosition;
  vec3 position;
  vec3 sphereNormal;
  vec3 normal;
  vec3 worldSpacePosition;
  vec3 viewSpacePosition;
  vec3 cameraRelativePosition;
//vec4 jitter;
  float mapValue;
  float waterOverSurface;
  float underWater;
  flat uint meshletID;
} inBlock;
#elif defined(UNDERWATER) || defined(WATER_CAUSTICS)
layout(location = 0) in InBlock {
  vec2 texCoord;
  float underWater;
} inBlock;
#else
layout(location = 0) in vec2 inTexCoord;
#endif

layout(location = 0) out vec4 outFragColor;

#if defined(VELOCITY)
  layout(location = 1) out vec2 outVelocity;
#elif defined(REFLECTIVESHADOWMAPOUTPUT)
  layout(location = 1) out vec4 outFragNormalUsed; // xyz = normal, w = 1.0 if normal was used, 0.0 otherwise (by clearing the normal buffer to vec4(0.0))
#endif

#if !(defined(TESSELLATION) || defined(UNDERWATER) || defined(WATER_CAUSTICS))
#ifdef MSAA
#ifndef MSAA_FAST
layout(input_attachment_index = 0, set = 1, binding = 9) uniform subpassInputMS uOITImgDepth; // Ignored/Unused in the MSAA_FAST case 
#endif
#else
layout(input_attachment_index = 0, set = 1, binding = 9) uniform subpassInput uOITImgDepth;
#endif
#endif // !(defined(TESSELLATION) || defined(UNDERWATER) || defined(WATER_CAUSTICS))

#if defined(TESSELLATION)
#define inViewSpacePosition inBlock.viewSpacePosition
#define inWorldSpacePosition inBlock.worldSpacePosition
#define inCameraRelativePosition inBlock.cameraRelativePosition
#else
vec3 viewSpacePosition;
vec3 worldSpacePosition;
vec3 cameraRelativePosition;

#define inViewSpacePosition viewSpacePosition
#define inWorldSpacePosition worldSpacePosition
#define inCameraRelativePosition cameraRelativePosition
#endif

// Global descriptor set

#define PLANETS
#ifdef RAYTRACING
  #define USE_MATERIAL_BUFFER_REFERENCE // needed for raytracing
#endif
#include "globaldescriptorset.glsl"
#undef PLANETS

// Pass descriptor set

#include "mesh_rendering_pass_descriptorset.glsl"
  
/*layout(set = 1, binding = 6, std430) readonly buffer ImageBasedSphericalHarmonicsMetaData {
  vec4 dominantLightDirection;
  vec4 dominantLightColor;
  vec4 ambientLightColor;
} imageBasedSphericalHarmonicsMetaData;*/

#ifdef FRUSTUMCLUSTERGRID
layout (set = 1, binding = 6, std140) readonly uniform FrustumClusterGridGlobals {
  uvec4 tileSizeZNearZFar; 
  vec4 viewRect;
  uvec4 countLightsViewIndexSizeOffsetedViewIndex;
  uvec4 clusterSize;
  vec4 scaleBiasMax;
} uFrustumClusterGridGlobals;

layout (set = 1, binding = 7, std430) readonly buffer FrustumClusterGridIndexList {
   uint frustumClusterGridIndexList[];
};

layout (set = 1, binding = 8, std430) readonly buffer FrustumClusterGridData {
  uvec4 frustumClusterGridData[]; // x = start light index, y = count lights, z = start decal index, w = count decals
};
#endif

// Per planet descriptor set

layout(set = 2, binding = 0) uniform sampler2D uPlanetTextures[]; // 0 = height map, 1 = normal map, 2 = tangent bitangent map
layout(set = 2, binding = 0) uniform sampler2DArray uPlanetArrayTextures[]; // 0 = height map, 1 = normal map, 2 = tangent bitangent map

// Per water render pass descriptor set

#if !(defined(TESSELLATION) || defined(UNDERWATER) || defined(WATER_CAUSTICS))
layout(set = 3, binding = 2) uniform sampler2DArray uTextureWaterAcceleration;
#endif

#define globalRaytracingFlags pushConstants.flags

#define PLANET_WATER
#include "planet_renderpass.glsl"

#define FRAGMENT_SHADER

#define WATER_FRAGMENT_SHADER

#define TRANSMISSION
#define TRANSMISSION_FORCED
#define VOLUMEATTENUTATION_FORCED

#include "math.glsl"

#ifdef RAYTRACING
  #include "raytracing.glsl"
#endif

#include "octahedral.glsl"
#include "octahedralmap.glsl"
#include "tangentspacebasis.glsl" 
#include "planet_noise.glsl"

float transmissionFactor = 1.0;
float volumeThickness = 0.005;
float volumeAttenuationDistance = 1.0 / 0.0; // +INF
vec3 volumeAttenuationColor = vec3(1.0); 
float volumeDispersion = 0.0;

float airIOR = 1.0;
float waterIOR = 1.3325;

#define IOR_TO_F0(ior) ((ior - 1.0) * (ior - 1.0)) / ((ior + 1.0) * (ior + 1.0))

float waterF0 = IOR_TO_F0(waterIOR) * IOR_TO_F0(waterIOR);

const vec3 inModelScale = vec3(1.0); 

float ior = waterIOR / airIOR;
 
int inViewIndex = int(gl_ViewIndex);

#define LIGHTING_GLOBALS
#include "lighting.glsl"
#undef LIGHTING_GLOBALS

#define UseEnvMap
#define UseEnvMapGGX
#undef UseEnvMapCharlie
#undef UseEnvMapLambertian

#include "roughness.glsl"

#include "meshlet.glsl"

vec3 imageLightBasedLightDirection = vec3(0.0, 1.0, 0.0);// imageBasedSphericalHarmonicsMetaData.dominantLightDirection.xyz;

vec3 viewDirection;

vec3 workNormal;

uint viewIndex = pushConstants.viewBaseIndex + uint(gl_ViewIndex);
mat4 viewMatrix = uView.views[viewIndex].viewMatrix;
mat4 inverseViewMatrix = uView.views[viewIndex].inverseViewMatrix;
mat4 projectionMatrix = uView.views[viewIndex].projectionMatrix;
mat4 inverseProjectionMatrix = uView.views[viewIndex].inverseProjectionMatrix;

#if !(defined(TESSELLATION) || defined(UNDERWATER) || defined(WATER_CAUSTICS))
mat4 viewProjectionMatrix = projectionMatrix * viewMatrix;
mat4 inverseViewProjectionMatrix = inverseViewMatrix * inverseProjectionMatrix;

float linearizeDepth(float z){
#if 1
  vec2 v = (inverseProjectionMatrix * vec4(vec3(fma(inTexCoord, vec2(2.0), vec2(-1.0)), z), 1.0)).zw;
#else
  vec2 v = fma(inverseProjectionMatrix[2].zw, vec2(z), inverseProjectionMatrix[3].zw);
#endif
  return v.x / v.y;
}

float delinearizeDepth(float z){
#if 1
  vec2 v = (projectionMatrix * vec4(vec3(fma(inTexCoord, vec2(2.0), vec2(-1.0)), z), 1.0)).zw;
#else
  vec2 v = fma(projectionMatrix[2].zw, vec2(z), projectionMatrix[3].zw);
#endif
  return v.x / v.y;
}
#endif

#define NOTEXCOORDS
#define inFrameIndex pushConstants.frameIndex
#include "shadows.glsl"

#undef ENABLE_ANISOTROPIC
#define SCREEN_SPACE_REFLECTIONS
#include "pbr.glsl"

const vec3 planetCenter = vec3(0.0); // The planet is at the origin in planet space
float planetBottomRadius = planetData.bottomRadiusTopRadiusHeightMapScale.x;
float planetTopRadius = planetData.bottomRadiusTopRadiusHeightMapScale.y;

mat4 planetModelMatrix = planetData.modelMatrix;
mat4 planetInverseModelMatrix = inverse(planetModelMatrix);

#include "planet_textures.glsl"

#include "planet_water.glsl"

#ifdef WATER_CAUSTICS
#include "planet_caustics.glsl"
#endif

// DDGI probe field for ray-tracing-based global illumination, gated to RT GI modes (DDGI now, Surfel later) — never
// CRH/VCT. Wired into the main water surface AND the underwater fullscreen pass (shore-foam ambient); WATER_CAUSTICS is
// excluded because that pass is purely additive refracted-sun light with no diffuse/ambient term for DDGI to feed. GI
// lives at the fixed dedicated set 4 (the water pipelines use sets 0..3), mirroring planet_renderpass.frag / planet_grass.frag.
#if defined(GLOBAL_ILLUMINATION_DDGI) && !defined(WATER_CAUSTICS)
  #define DDGI_DESCRIPTOR_SET 4
  #include "global_illumination_ddgi_sampling.glsl"
  #define WATER_DDGI 1
#elif defined(GLOBAL_ILLUMINATION_SURFEL) && !defined(WATER_CAUSTICS)
  #define GLOBAL_ILLUMINATION_SURFEL_SAMPLE
  #define GI_SURFEL_DESCRIPTOR_SET 4
  #include "global_illumination_surfel.glsl"
  #define WATER_SURFEL 1
#endif

// Diffuse ambient irradiance for the water surface at a given world position, in getIBLDiffuse()'s "ready to multiply by
// albedo" convention. Under the DDGI build variant it comes from the probe field (replacing the environment IBL diffuse);
// otherwise it is the environment IBL diffuse (which ignores the position). The specular reflection path stays IBL either
// way (water reflections are wanted). An explicit world position is taken because the underwater fullscreen pass has no
// per-fragment surface position (the file-scope inWorldSpacePosition is only valid on the tessellated surface) — the
// underwater shore-foam caller reconstructs the world position from the depth buffer instead. viewDirection is file-scope.
#if defined(WATER_DDGI)
vec3 waterDiffuseAmbient(const in vec3 worldPosition, const in vec3 n, out float skyVisibility){
  return ddgiSampleIrradiance(worldPosition, n, viewDirection, skyVisibility) * OneOverPI;
}
#elif defined(WATER_SURFEL)
vec3 waterDiffuseAmbient(const in vec3 worldPosition, const in vec3 n, out float skyVisibility){
  return giSurfelSampleIrradiance(worldPosition, n, skyVisibility) * OneOverPI;
}
#else
vec3 waterDiffuseAmbient(const in vec3 worldPosition, const in vec3 n, out float skyVisibility){
  skyVisibility = 1.0;
  return getIBLDiffuse(n);
}
#endif
vec3 waterDiffuseAmbient(const in vec3 worldPosition, const in vec3 n){
  float skyVisibility;
  return waterDiffuseAmbient(worldPosition, n, skyVisibility);
}

vec3 safeNormalize(vec3 v){
  return (length(v) > 0.0) ? normalize(v) : vec3(0.0);
}

// Accumulate a single Gerstner-style wave's normal gradient onto normalOffset.
// d3: 3D wave direction (unit vector in sphere tangent plane), k: wavenumber (rad/m),
// A: visual amplitude (normal-space, dimensionless), pos: planet-local position (meters).
// waveSpeed (global) controls the animation rate.
vec3 waveWindDir = vec3(1.0, 0.0, 0.0);
float waveAmplitude = 0.0;
float waveFrequency = 0.05;
float waveSteepness = 0.5;
float waveSpeed = 0.5;
float waveWhitecapFactor = 1.0;
float uvWaveFrequency    = 5.0; // spatial wave cycles per octahedral UV unit [0,1]
float uvWaveSpeed        = 0.3; // UV wave animation speed (UV units/s)
float uvWaveScale        = 10.0; // UV coordinate scale applied to octUV before wave phases (higher = finer ripples)
float waveDisplaceAmplitude          = 0.0; // per-vertex height displacement amplitude in meters (0=disabled)
float displaceHeightLowThreshold     = 0.0; // water depth below which displacement fades to 0
float displaceHeightHighThreshold    = 0.5; // water depth above which displacement is at full strength
float displaceHeightFactor           = 1.0; // overall multiplier on depth-based displacement fade
vec3  whitecapColor          = vec3(1.0);  // whitecap foam color (linear RGB)
float whitecapPatternScale   = 24.0;  // FBM breakup pattern scale
float whitecapSlopeThreshLow  = 0.05; // heightmap slope where whitecaps begin
float whitecapSlopeThreshHigh = 0.20; // heightmap slope where whitecaps are full
float whitecapBreakupLow     = 0.35;  // FBM breakup smoothstep low threshold
float whitecapBreakupHigh    = 0.75;  // FBM breakup smoothstep high threshold
float shoreFoamBreakupLow    = 0.35;  // shore foam FBM breakup smoothstep low threshold
float shoreFoamBreakupHigh   = 0.75;  // shore foam FBM breakup smoothstep high threshold
float shoreFoamPuddleMinHeight = 0.0005; // puddle suppression: foam fully off below this regional water height
float shoreFoamPuddleMaxHeight = 0.005;  // puddle suppression: foam fully on above this regional water height

// Fragment-local UV displacement wrapper using global uvWave* uniforms.
float computeWaveDisplacement(vec2 uv, float time){
  return computeWaveDisplacement(uv, time, uvWaveFrequency, uvWaveSpeed, uvWaveScale);
}

// Fragment-local Gerstner displacement wrapper using global wave* uniforms.
float computeGerstnerDisplacement(vec3 spherePos, float time){
  return computeGerstnerDisplacement(spherePos, waveWindDir, waveFrequency, waveSpeed, waveSteepness, time);
}

// Adds rain splash normal perturbation on top of a precomputed water normal.
// Uses analytic finite-difference slope at fine UV step (cellSize/16) and applies as
// tangent-space perturbation. Masked by local water depth so dry areas stay flat.
vec3 applyWaterRainSplashNormal(vec3 n, vec3 baseNormal){
#ifdef PLANET_DATA_GLSL
  float strength = unpackHalf2x16(planetData.waterRainSplashParams2.x).x;
  if(strength <= 0.0){
    return baseNormal;
  }
  vec2 euv = octPlanetUnsignedEncode(n);
  float waterDepth = getSphereHeightData(euv).y;
  vec2 splashDepthThresh = unpackHalf2x16(planetData.waterRainSplashParams2.y); // depthThresholdLow, depthThresholdHigh
  float fade = smoothstep(splashDepthThresh.x, max(splashDepthThresh.y, splashDepthThresh.x + 1e-6), waterDepth);
  if(fade <= 0.0){
    return baseNormal;
  }
  vec2 slope = getWaterRainSplashSlope(euv, pushConstants.time) * strength * fade;
  if(dot(slope, slope) <= 1e-12){
    return baseNormal;
  }
  // Build local sphere-tangent basis from neighbouring octahedral UV samples so it
  // follows the planet curvature instead of assuming flat-earth Y=up.
  vec2 duv = vec2(1.0) / vec2(textureSize(uPlanetTextures[PLANET_TEXTURE_HEIGHTMAP], 0).xy);
  vec3 pu = octPlanetUnsignedDecode(wrapOctahedralCoordinates(euv + vec2(duv.x, 0.0))) -
            octPlanetUnsignedDecode(wrapOctahedralCoordinates(euv - vec2(duv.x, 0.0)));
  vec3 pv = octPlanetUnsignedDecode(wrapOctahedralCoordinates(euv + vec2(0.0, duv.y))) -
            octPlanetUnsignedDecode(wrapOctahedralCoordinates(euv - vec2(0.0, duv.y)));
  vec3 tangent = normalize(pu - (n * dot(n, pu)));
  vec3 bitangent = normalize(pv - (n * dot(n, pv)) - (tangent * dot(tangent, pv)));
  return normalize(baseNormal - (tangent * slope.x) - (bitangent * slope.y));
#else
  return baseNormal;
#endif
}

vec3 getWaterNormal(vec3 position){

  vec3 n = normalize(position);

#if 1
  float texScale = 1.0 / 4096.0;

  vec3 normal;

  {

    // Calculate the normal as the average of the normals of some temporary virtual triangles
    
    // a(-1, -1) b( 0, -1) c( 1, -1)
    // d(-1,  0) e( 0,  0) f( 1,  0)
    // g(-1,  1) h( 0,  1) i( 1,  1)

    vec2 euv = octPlanetUnsignedEncode(n);
    
    vec2 auv = wrapOctahedralCoordinates(euv + (vec2(-1.0, -1.0) * texScale)); // -1, -1
    vec2 buv = wrapOctahedralCoordinates(euv + (vec2(0.0, -1.0) * texScale)); //  0, -1
    vec2 cuv = wrapOctahedralCoordinates(euv + (vec2(1.0, -1.0) * texScale)); //  1, -1
    vec2 duv = wrapOctahedralCoordinates(euv + (vec2(-1.0, 0.0) * texScale)); // -1,  0
    vec2 fuv = wrapOctahedralCoordinates(euv + (vec2(1.0, 0.0) * texScale)); //  1,  0
    vec2 guv = wrapOctahedralCoordinates(euv + (vec2(-1.0, 1.0) * texScale)); // -1,  1
    vec2 huv = wrapOctahedralCoordinates(euv + (vec2(0.0, 1.0) * texScale)); //  0,  1
    vec2 iuv = wrapOctahedralCoordinates(euv + (vec2(1.0, 1.0) * texScale)); //  1,  1

    float eh = getSphereHeight(euv);

    float ah = getSphereHeightEx(auv);
    float bh = getSphereHeightEx(buv);
    float ch = getSphereHeightEx(cuv);
    float dh = getSphereHeightEx(duv);
    float fh = getSphereHeightEx(fuv);
    float gh = getSphereHeightEx(guv);
    float hh = getSphereHeightEx(huv);
    float ih = getSphereHeightEx(iuv);

    // Correct height samples for wave displacement so normals match displaced geometry.
    // Combines UV chop (computeWaveDisplacement) and Gerstner swell (computeGerstnerDisplacement).
    // Uses center water depth for smoothstep (approximation; avoids 8 extra texture reads).
    if((waveDisplaceAmplitude > 0.0) || (waveAmplitude > 0.0)){
      float centerWaterDepth = getSphereHeightData(euv).y;
      float displacementFactor = smoothstep(displaceHeightLowThreshold, displaceHeightHighThreshold, centerWaterDepth) * displaceHeightFactor;
      if(displacementFactor > 0.0){
        float disT = pushConstants.time;
        float uvAmpl = waveDisplaceAmplitude * displacementFactor;
        float gAmpl  = waveAmplitude         * displacementFactor;
        eh += computeWaveDisplacement(euv, disT) * uvAmpl + computeGerstnerDisplacement(n * eh, disT) * gAmpl;
        if(ah > 0.0){ ah += computeWaveDisplacement(auv, disT) * uvAmpl + computeGerstnerDisplacement(octPlanetUnsignedDecode(auv) * ah, disT) * gAmpl; }
        if(bh > 0.0){ bh += computeWaveDisplacement(buv, disT) * uvAmpl + computeGerstnerDisplacement(octPlanetUnsignedDecode(buv) * bh, disT) * gAmpl; }
        if(ch > 0.0){ ch += computeWaveDisplacement(cuv, disT) * uvAmpl + computeGerstnerDisplacement(octPlanetUnsignedDecode(cuv) * ch, disT) * gAmpl; }
        if(dh > 0.0){ dh += computeWaveDisplacement(duv, disT) * uvAmpl + computeGerstnerDisplacement(octPlanetUnsignedDecode(duv) * dh, disT) * gAmpl; }
        if(fh > 0.0){ fh += computeWaveDisplacement(fuv, disT) * uvAmpl + computeGerstnerDisplacement(octPlanetUnsignedDecode(fuv) * fh, disT) * gAmpl; }
        if(gh > 0.0){ gh += computeWaveDisplacement(guv, disT) * uvAmpl + computeGerstnerDisplacement(octPlanetUnsignedDecode(guv) * gh, disT) * gAmpl; }
        if(hh > 0.0){ hh += computeWaveDisplacement(huv, disT) * uvAmpl + computeGerstnerDisplacement(octPlanetUnsignedDecode(huv) * hh, disT) * gAmpl; }
        if(ih > 0.0){ ih += computeWaveDisplacement(iuv, disT) * uvAmpl + computeGerstnerDisplacement(octPlanetUnsignedDecode(iuv) * ih, disT) * gAmpl; }
      }
    }

    vec3 a = octPlanetUnsignedDecode(auv) * ((ah > 0.0) ? ah : eh);
    vec3 b = octPlanetUnsignedDecode(buv) * ((bh > 0.0) ? bh : eh);
    vec3 c = octPlanetUnsignedDecode(cuv) * ((ch > 0.0) ? ch : eh);
    vec3 d = octPlanetUnsignedDecode(duv) * ((dh > 0.0) ? dh : eh);
    vec3 e = n * eh;
    vec3 f = octPlanetUnsignedDecode(fuv) * ((fh > 0.0) ? fh : eh);
    vec3 g = octPlanetUnsignedDecode(guv) * ((gh > 0.0) ? gh : eh);
    vec3 h = octPlanetUnsignedDecode(huv) * ((hh > 0.0) ? hh : eh);
    vec3 i = octPlanetUnsignedDecode(iuv) * ((ih > 0.0) ? ih : eh);

    // Calculate the smoothed normal at point e as the average of the normals of the surrounding triangles in triangle fan order:
    normal = safeNormalize(
      safeNormalize(cross(a - e, b - e)) + // Triangle EAB
      safeNormalize(cross(b - e, c - e)) + // Triangle EBC          
      safeNormalize(cross(c - e, f - e)) + // Triangle EDA
      safeNormalize(cross(f - e, i - e)) + // Triangle EFI
      safeNormalize(cross(i - e, h - e)) + // Triangle EIH
      safeNormalize(cross(h - e, g - e)) + // Triangle EHG
      safeNormalize(cross(g - e, d - e)) + // Triangle EGD
      safeNormalize(cross(d - e, a - e))   // Triangle EDA
    );   

  }       

  return applyWaterRainSplashNormal(n, normal);
#else

  const vec2 uvOfs = vec2(1.0 / 4096.0, 0.0);

  vec2 uv = octPlanetUnsignedEncode(n);
  vec2 uv00 = wrapOctahedralCoordinates(uv - uvOfs.xy);
  vec2 uv01 = wrapOctahedralCoordinates(uv + uvOfs.xy);
  vec2 uv10 = wrapOctahedralCoordinates(uv - uvOfs.yx);
  vec2 uv11 = wrapOctahedralCoordinates(uv + uvOfs.yx);

  float h = getSphereHeight(uv); 
  float h00 = getSphereHeightEx(uv00);
  float h01 = getSphereHeightEx(uv01);
  float h10 = getSphereHeightEx(uv10);
  float h11 = getSphereHeightEx(uv11);

  vec3 p = n * h; 
  vec3 p00 = octPlanetUnsignedDecode(uv00) * ((h00 > 0.0) ? h00 : h);
  vec3 p01 = octPlanetUnsignedDecode(uv01) * ((h01 > 0.0) ? h01 : h);
  vec3 p10 = octPlanetUnsignedDecode(uv10) * ((h10 > 0.0) ? h10 : h);
  vec3 p11 = octPlanetUnsignedDecode(uv11) * ((h11 > 0.0) ? h11 : h);
  
  vec3 tangent = (distance(p00, p01) > 0.0)
                    ? normalize(p01 - p00) 
                    : ((distance(p10, p11) > 0.0) 
                        ? normalize(cross(normalize(p11 - p10), p)) 
                        : normalize(p - p00));

  vec3 bitangent = (distance(p10, p11) > 0.0) 
                      ? normalize(p11 - p10) 
                      : ((distance(p01, p00) > 0.0)
                          ? normalize(cross(normalize(p01 - p00), p)) 
                          : normalize(p - p10));

  return applyWaterRainSplashNormal(n, normalize(cross(tangent, bitangent)));
#endif
}

float fresnelGet(float costheta, float ior){
  float r0 = (1.0f - ior) / (1.0f + ior);
  r0 *= r0;
  float x = 1.0 - costheta;
  return r0 + ((1.0 - r0) * (x * x * x));
}

float fresnelDielectric(vec3 Incoming, vec3 Normal, float eta){
  // compute fresnel reflectance without explicitly computing the refracted direction 
  float c = abs(dot(Incoming, Normal));
  float g = ((eta * eta) - 1.0) + (c * c);
  float result;
  if(g > 0.0){
    g = sqrt(g);
    float A = (g - c) / (g + c);
    float B = ((c * (g + c)) - 1.0) / ((c * (g - c)) + 1.0);
    result = (0.5 * A * A) * (1.0 + (B * B));
  }else{
    result = 1.0;  /* TIR (no refracted component) */
  }
  return result;
}

float getFresnel(vec3 incident, vec3 normal, float iorIn, float iorOut){
  vec2 cosit = vec2(clamp(dot(incident, normal), -1.0, 1.0), 0.0);
  vec2 etait = (cosit.x > 0.0) ? vec2(iorIn, iorOut) : vec2(iorOut, iorIn);
  float sint = (etait.x / etait.y) * sqrt(max(0.0, 1.0 - (cosit.x * cosit.x)));
  if(sint >= 1.0){
    return 1.0;
  }else{
    cosit = vec2(abs(cosit.x), sqrt(max(0.0, 1.0 - (sint * sint))));
    return length(vec2((etait.y * cosit.x) - (etait.x * cosit.y), (etait.x * cosit.x) - (etait.y * cosit.y)) / vec2((etait.y * cosit.x) + (etait.x * cosit.y), (etait.x * cosit.x) + (etait.y * cosit.y))) * 0.5;
  }
}

float HenyeyGreenstein(float mu, float inG){
  return (1.0 - (inG * inG)) / (pow((1.0 + (inG * inG)) - (2.0 * inG * mu), 1.5) * 12.5663706144);
}

#define PROCESSLIGHT processLight 

vec3 waterBaseColor = pow(vec3(0.555555, 0.777777, 1.0), vec3(2.5));//vec3(0.5, 0.7, 0.9); // default; overridden from planetData.waterBaseColorIORs in main()

vec3 waterDiffuseColor = vec3(0.0);
vec3 waterSpecularColor = vec3(0.0);

vec3 waterSubscattering = vec3(0.0);

// Downwelling irradiance reaching the water surface from direct (shadow-attenuated) lights.
// Accumulated in processLight and combined with IBL diffuse to modulate the deep-water
// scattering color so the volume stays dark at night / in shadow and bright at day.
vec3 waterDownwellingIrradiance = vec3(0.0);

vec3 waterColor; //vec3(0.090195, 0.115685, 0.12745);

float waterDepth;

void processLight(const in vec3 lightColor, 
                  const in vec3 lightLit, 
                  const in vec3 lightDirection){

  float mu = dot(lightDirection, -viewDirection);

  waterSubscattering += HenyeyGreenstein(mu, 0.5) * waterColor * lightColor * lightLit * (1.0 - clamp(exp(-waterDepth * 0.01), 0.0, 1.0));  

  // Downwelling irradiance onto the water surface from above (shadow/visibility-aware via
  // lightLit from the caller, which carries the per-light lightAttenuation including shadows).
  // Above/below water sign flipping is already handled by the caller via workNormal.
  waterDownwellingIrradiance += lightColor * lightLit * max(0.0, dot(workNormal, lightDirection));

//waterSubscattering += HenyeyGreenstein(mu, 0.5) * waterColor * lightColor * max(0.0, waterDepth * 0.01);

} 

// --- Shore foam helpers ----------------------------------------------------
// Uses the shared gradient-noise FBM from planet_noise.glsl so the foam pattern
// stays stable on the sphere surface while avoiding axis-aligned grid artefacts
// of naive value-noise.

#define SHORE_FOAM_LEGACY_VALUE_NOISE

#ifdef SHORE_FOAM_LEGACY_VALUE_NOISE
// Small, self-contained 3D value-noise FBM sampled in local-planet space so
// the foam pattern stays stable on the sphere surface while being cheap.
float shoreFoamHash(vec3 p){
  return hash44ChaCha20(vec4(p, 0.0)).x;
}

float shoreFoamNoise(vec3 p){
  vec3 i = floor(p);
  vec3 f = fract(p);
  vec3 u = f * f * (3.0 - (2.0 * f));
  float n000 = shoreFoamHash(i + vec3(0.0, 0.0, 0.0));
  float n100 = shoreFoamHash(i + vec3(1.0, 0.0, 0.0));
  float n010 = shoreFoamHash(i + vec3(0.0, 1.0, 0.0));
  float n110 = shoreFoamHash(i + vec3(1.0, 1.0, 0.0));
  float n001 = shoreFoamHash(i + vec3(0.0, 0.0, 1.0));
  float n101 = shoreFoamHash(i + vec3(1.0, 0.0, 1.0));
  float n011 = shoreFoamHash(i + vec3(0.0, 1.0, 1.0));
  float n111 = shoreFoamHash(i + vec3(1.0, 1.0, 1.0));
  return mix(mix(mix(n000, n100, u.x), mix(n010, n110, u.x), u.y),
             mix(mix(n001, n101, u.x), mix(n011, n111, u.x), u.y),
             u.z);
}

float shoreFoamFBM(vec3 p){
  float f = 0.0;
  float a = 0.5;
  for(int i = 0; i < 4; i++){
    f += shoreFoamNoise(p) * a;
    p = (p * 2.03) + vec3(17.13, 23.71, 29.17);
    a *= 0.5;
  }
  return f;
}
#endif

// Shared shore-foam overlay. Returns aBaseColor unchanged for waterDepth values above the foam
// range or when the foam is disabled; otherwise blends the configured foam color on top, using
// aPlanetSpacePos as the pattern domain so the foam stays locked to the planet surface.
// Foam is suppressed in small isolated water bodies (puddles) by sampling the downsampled
// water minimap to check the regional average water height.
vec3 applyShoreFoam(vec3 aBaseColor, vec3 aPlanetSpacePos, float aShoreDepth){
  vec3 result = aBaseColor;
  vec4 waterShoreFoam0 = vec4(unpackHalf2x16(planetData.waterShoreFoam.x), unpackHalf2x16(planetData.waterShoreFoam.y));
  vec4 waterShoreFoam1 = vec4(unpackHalf2x16(planetData.waterShoreFoam.z), unpackHalf2x16(planetData.waterShoreFoam.w));
  if(waterShoreFoam1.w > 0.0){
    float shoreMask = 1.0 - smoothstep(waterShoreFoam1.x, waterShoreFoam0.w, aShoreDepth);
    if(shoreMask > 0.0){
      // Suppress foam in puddles: sample the downsampled water minimap to get regional average
      // water height. Puddles have near-zero regional depth everywhere, so shoreMask would
      // otherwise equal 1.0 across the whole puddle. Scale down to ~0 when the regional
      // water height is below the puddle threshold.
      vec2 miniMapUV = octPlanetUnsignedEncode(normalize(aPlanetSpacePos));
      float regionalWaterHeight = texture(uPlanetTextures[PLANET_TEXTURE_WATERMAP_MINIMAP], miniMapUV).r;
      float puddleFactor = smoothstep(shoreFoamPuddleMinHeight, shoreFoamPuddleMaxHeight, regionalWaterHeight);
      shoreMask *= puddleFactor;
    }
    if(shoreMask > 0.0){
      vec3 foamUV = aPlanetSpacePos * waterShoreFoam1.y;
      float foamPhase = pushConstants.time * waterShoreFoam1.z;
#ifdef SHORE_FOAM_LEGACY_VALUE_NOISE
      float foamA = shoreFoamFBM(foamUV + vec3(0.0, 0.0, foamPhase));
      float foamB = shoreFoamFBM((foamUV * 1.73) + vec3(foamPhase * 0.7, -foamPhase * 0.5, 0.0));
      float foamPattern = clamp((foamA * 1.4) - (foamB * 0.6) - 0.25, 0.0, 1.0);
#else
      // Domain-warp via a cheap low-frequency offset noise to break up any
      // residual lattice regularity, then sample two decorrelated FBMs and
      // combine them with a soft smoothstep for an organic foam shape.
      vec3 warp = vec3(planetGradientNoise(foamUV * 0.5 + vec3(foamPhase, 0.0, 0.0)),
                       planetGradientNoise(foamUV * 0.5 + vec3(0.0, foamPhase, 0.0)),
                       planetGradientNoise(foamUV * 0.5 + vec3(0.0, 0.0, foamPhase))) * 0.35;
      float foamA = planetNoiseFBM((foamUV + warp) + vec3(0.0, 0.0, foamPhase));
      float foamB = planetNoiseFBM(((foamUV * 1.73) + warp) + vec3(foamPhase * 0.7, -foamPhase * 0.5, 0.0));
      float foamPattern = smoothstep(shoreFoamBreakupLow, shoreFoamBreakupHigh, foamA - (foamB * 0.4));
#endif
      float foamAmount = clamp(shoreMask * foamPattern * waterShoreFoam1.w, 0.0, 1.0);
      // Modulate the (typically white) foam color by ambient IBL + shadow-attenuated direct
      // downwelling irradiance so foam darkens at night / in shadow instead of glowing white.
      vec3 foamIrradiance = waterDiffuseAmbient((planetModelMatrix * vec4(aPlanetSpacePos, 1.0)).xyz, workNormal) + waterDownwellingIrradiance;
      vec3 foamLit = waterShoreFoam0.xyz * foamIrradiance;
      result = mix(result, foamLit, foamAmount);
    }
  }
  return result;
}

// Whitecap (breaking wave crest) mask: combines Gerstner wave-crest phase
// detection with an FBM breakup to produce ragged, animated foam patches at
// wave crests. Returns 0 when amplitude*steepness is below threshold.
float computeWhitecapMask(vec3 position){
  float globalCoverage = max(0.0, waveWhitecapFactor);
  if(globalCoverage <= 0.0){
    return 0.0;
  }
  // Whitecap is driven purely by the gradient of the water simulation heightmap in
  // sphere-correct (round-planet) tangent space — no wave-phase re-computation.
  // High water surface slope (steep wave face) => whitecap.
  vec3 n = normalize(position);
  vec2 octUV = octPlanetUnsignedEncode(n);
  const vec2 uvOfs = vec2(1.0 / 4096.0, 0.0);
  vec2 uv00 = wrapOctahedralCoordinates(octUV - uvOfs.xy);
  vec2 uv01 = wrapOctahedralCoordinates(octUV + uvOfs.xy);
  vec2 uv10 = wrapOctahedralCoordinates(octUV - uvOfs.yx);
  vec2 uv11 = wrapOctahedralCoordinates(octUV + uvOfs.yx);
  // Water simulation heights at neighbours (pure water height, no terrain offset needed for gradient).
  float wh00 = getWaterHeightData(uv00);
  float wh01 = getWaterHeightData(uv01);
  float wh10 = getWaterHeightData(uv10);
  float wh11 = getWaterHeightData(uv11);
  // Total surface heights for sphere-correct 3D distances (terrain + water).
  float h   = getSphereHeight(octUV);
  float h00 = getSphereHeightEx(uv00);
  float h01 = getSphereHeightEx(uv01);
  float h10 = getSphereHeightEx(uv10);
  float h11 = getSphereHeightEx(uv11);
  vec3 p    = n * h;
  vec3 p00  = octPlanetUnsignedDecode(uv00) * ((h00 > 0.0) ? h00 : h);
  vec3 p01  = octPlanetUnsignedDecode(uv01) * ((h01 > 0.0) ? h01 : h);
  vec3 p10  = octPlanetUnsignedDecode(uv10) * ((h10 > 0.0) ? h10 : h);
  vec3 p11  = octPlanetUnsignedDecode(uv11) * ((h11 > 0.0) ? h11 : h);
  // Sphere-correct 3D surface distances for gradient normalisation.
  float distU = max(1e-6, length(p01 - p00));
  float distV = max(1e-6, length(p11 - p10));
  // Water height gradient in heightmap tangent space (dimensionless, m/m).
  float gradU = (wh01 - wh00) / distU;
  float gradV = (wh11 - wh10) / distV;
  float gradMag = sqrt((gradU * gradU) + (gradV * gradV));
  // Threshold: scale steepness thresholds with wave amplitude so the whitecap
  // coverage adapts automatically when wave settings change.
  float slopeThreshLow  = whitecapSlopeThreshLow;
  float slopeThreshHigh = whitecapSlopeThreshHigh;
  float crest = smoothstep(slopeThreshLow, slopeThreshHigh, gradMag);
  // FBM breakup pattern: use own whitecap patternscale.
  vec3 foamUV    = position * whitecapPatternScale;
  float foamPhase = pushConstants.time * waveSpeed * 0.25;
  vec3 warp      = vec3(planetGradientNoise(foamUV * 0.5 + vec3(foamPhase,        0.0,          0.0        )),
                        planetGradientNoise(foamUV * 0.5 + vec3(0.0,              foamPhase,    0.0        )),
                        planetGradientNoise(foamUV * 0.5 + vec3(0.0,              0.0,          foamPhase  ))) * 0.35;
  float foamA    = planetNoiseFBM((foamUV + warp) + vec3(0.0, 0.0, foamPhase));
  float foamB    = planetNoiseFBM(((foamUV * 1.73) + warp) + vec3(foamPhase * 0.7, -foamPhase * 0.5, 0.0));
  float foamBreakup = smoothstep(whitecapBreakupLow, whitecapBreakupHigh, foamA - (foamB * 0.4));
  return clamp(globalCoverage * crest * foamBreakup, 0.0, 1.0);
}

// Apply whitecap foam to aBaseColor, lit by the same sky+sun irradiance as
// shore foam so whitecaps darken at night rather than glowing white.
// Guard uses waveWhitecapFactor (not waveAmplitude) so geometry displacement
// amplitude changes don't accidentally disable whitecaps.
vec3 applyWhitecaps(vec3 aBaseColor, vec3 aPlanetSpacePos){
  if(waveWhitecapFactor <= 0.0){
    return aBaseColor;
  }
  float mask = computeWhitecapMask(aPlanetSpacePos);
  if(mask <= 0.0){
    return aBaseColor;
  }
  vec3 foamIrradiance  = waterDiffuseAmbient((planetModelMatrix * vec4(aPlanetSpacePos, 1.0)).xyz, workNormal) + waterDownwellingIrradiance;
  vec3 foamLit         = whitecapColor * foamIrradiance;
  return mix(aBaseColor, foamLit, mask);
}

vec4 doShade(float opaqueDepth, float surfaceDepth, bool underWater){

  waterDepth = opaqueDepth - surfaceDepth;

  vec4 albedo = vec4(1.0);  
  vec3 baseColor = vec3(1.0);
  vec4 occlusionRoughnessMetallic = vec4(1.0, 0.0, 0.9, 0.0);

  // The blade normal is rotated slightly to the left or right depending on the x texture coordinate for
  // to fake roundness of the blade without real more complex geometry
  vec3 normal = workNormal;
 
  float NdotV;
  normal = getViewClampedNormal(normal, viewDirection, NdotV);
  NdotV = clamp(NdotV, 0.0, 1.0);

  float occlusion = clamp(occlusionRoughnessMetallic.x, 0.0, 1.0);
    
  vec2 metallicRoughness = clamp(occlusionRoughnessMetallic.zy, vec2(0.0, 1e-3), vec2(1.0));

  float metallic = metallicRoughness.x;

  vec4 diffuseColorAlpha = vec4(max(vec3(0.0), albedo.xyz * (1.0 - metallicRoughness.x)), albedo.w);

  //vec3 F0Dielectric = mix(vec3(waterF0), albedo.xyz, metallicRoughness.x);
  vec3 F0Dielectric = vec3(0.04);

  vec3 F90 = vec3(1.0);
  vec3 F90Dielectric = vec3(1.0);

  float transparency = 0.0;

  float refractiveAngle = 0.0;

  float perceptualRoughness = metallicRoughness.y;

  float kernelRoughness;
  {
    const float SIGMA2 = 0.15915494, KAPPA = 0.18;        
    vec3 dx = dFdx(workNormal), dy = dFdy(workNormal);
    kernelRoughness = min(KAPPA, (2.0 * SIGMA2) * (dot(dx, dx) + dot(dy, dy)));
    perceptualRoughness = sqrt(clamp((perceptualRoughness * perceptualRoughness) + kernelRoughness, 0.0, 1.0));
  }  

  float alphaRoughness = perceptualRoughness * perceptualRoughness;

  diffuseOcclusion = occlusion * ambientOcclusion;
  specularOcclusion = getSpecularOcclusion(clamp(dot(normal, viewDirection), 0.0, 1.0), diffuseOcclusion, alphaRoughness);

  // Horizon specular occlusion
  {
    vec3 reflectedVector = reflect(-viewDirection, normal);
    float horizon = min(1.0 + dot(reflectedVector, normal), 1.0);
    specularOcclusion *= horizon * horizon;         
  }

  const vec3 sheenColor = vec3(0.0);
  const float sheenRoughness = 0.0;

  const vec3 clearcoatF0 = vec3(0.04);
  const vec3 clearcoatF90 = vec3(0.0);
  vec3 clearcoatNormal = normal;
  const float clearcoatFactor = 1.0;
  const float clearcoatRoughness = 1.0;

  float litIntensity = 1.0;

  const float specularWeight = 1.0;//0.255;

  const float iblWeight = 1.0;

  vec3 triangleNormal = normal;

#if 0

  float ior = underWater ? 0.66 : 1.33;
  float eta = max(ior, 1e-5);
  
  float fresnel = clamp(fresnelDielectric(-viewDirection, normal, eta), 0.0, 1.0);
  //float fresnel = pow(1.0 - max(dot(normal, -viewDirection), 0.0), 3.0) * 1.0;

  vec4 color = vec2(0.0, 1.0).xxxy; 		

  vec3 reflection = vec3(0.1); 		
  
  vec3 refraction = getIBLVolumeRefraction(normal.xyz, 
                                           viewDirection,
                                                 clamp(waterDepth * 0.1, 0.0, 0.25),//perceptualRoughness,
                                                 vec3(1.0), //diffuseColorAlpha.xyz, 
                                                 //vec3(0.04), //F0, 
                                                 //vec3(1.0), //F90,
                                                 inWorldSpacePosition,
/*                                          perceptualRoughness,
                                           diffuseColorAlpha.xyz, F0, F90,
                                           inWorldSpacePosition,*/
                                           ior, 
                                           volumeThickness, 
                                           volumeAttenuationColor, 
                                           volumeAttenuationDistance,
                                           volumeDispersion);      

  color.xyz = mix(refraction, reflection, fresnel) * waterBaseColor;  

  return color;

#else

  //diffuseOutput = vec3(0.0);

  //vec3(0.015625) * edgeFactor() * fma(clamp(dot(normal, vec3(0.0, 1.0, 0.0)), 0.0, 1.0), 1.0, 0.0), 1.0);
  vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
  
  float fresnel = clamp(fresnelDielectric(-viewDirection, normal, underWater ? airIOR / waterIOR : waterIOR / airIOR), 0.0, 1.0);
  //float fresnel = pow(1.0 - max(dot(normal, viewDirection), 0.0), 3.0) * 1.0;

  //float fresnel = clamp(fresnelGet(max(0.0, dot(viewDirection, normal)), underWater ? airIOR / waterIOR : waterIOR / airIOR), 0.0, 1.0);
 /*float fresnel;
  {
    float ior = underWater ? airIOR / waterIOR : waterIOR / airIOR;
    float r0 = (1.0 - ior) / (1.0 + ior);
    float x = 1.0 - max(0.0, dot(viewDirection, normal));
    fresnel = mix(x * x * x, 1.0, r0 * r0);
  }*/
  //float fresnel = clamp(getFresnel(-viewDirection, normal, underWater ? airIOR : waterIOR, underWater ? waterIOR : airIOR), 0.0, 1.0);
  
/*if(underWater){
    
    vec3 r = textureLod(uPassTextures[1], vec3(inTexCoord, gl_ViewIndex), 1.0).xyz;
    color = vec4(r, 1.0);

  }else*/{

   /*vec4 hitPosition = vec4(viewDirection * hitTime, 1.0);
    hitPosition = inverseViewMatrix * hitPosition;
    hitPosition /= hitPosition.w;

    hitWaterDepth = underWater ? hitTime : distance(hitPosition.xyz, inWorldSpacePosition);

    waterDepth = getWaterHeightData(octPlanetUnsignedEncode(normalize(inWorldSpacePosition)));*/
    
    float waterHeight = getWaterHeightData(octPlanetUnsignedEncode(normalize(inWorldSpacePosition)));

// waterColor = pow(vec3(0.6862, 0.8823, 0.9411), vec3(2.2));//pow(waterBaseColor, vec3(mix(1.0, 2.0, clamp(waterDepth * 0.1, 0.0, 1.0))));
    waterColor = waterBaseColor;//pow(waterBaseColor, vec3(mix(1.0, 2.0, clamp(waterDepth * 0.1, 0.0, 1.0))));
    
#define LIGHTING_INITIALIZATION
#include "lighting.glsl"
#undef LIGHTING_INITIALIZATION

   const bool receiveShadows = true; 
   
#define LIGHTING_IMPLEMENTATION
#include "lighting.glsl"
#undef LIGHTING_IMPLEMENTATION

    vec3 iblDiffuse = waterDiffuseAmbient(inWorldSpacePosition, normal) * baseColor.xyz;
    vec3 iblSpecularMetal = getIBLRadianceGGX(normal, viewDirection, perceptualRoughness);
#if defined(WATER_DDGI) && defined(GI_DDGI_GLOSSY_RESIDUAL)
    // Probe-derived glossy, roughness-gated. Water is normally near-mirror (low roughness), so smoothstep(0.3,0.8) keeps this ~inert and
    // the sharp environment/SSR reflection wins (sharp water reflections are wanted — see waterDiffuseAmbient). It only kicks
    // in for rough/foamy water, where a broad probe reflection (with local colour bleed) is appropriate. Storage-agnostic
    // via ddgiSampleIrradiance (E(R)/pi ~ broad prefiltered radiance along the reflection vector).
    {
      float ddgiGlossySky;
      vec3 ddgiReflectionVector = normalize(reflect(-viewDirection, normal));
      vec3 ddgiGlossyRadiance = ddgiSampleIrradiance(inWorldSpacePosition, ddgiReflectionVector, viewDirection, ddgiGlossySky) * OneOverPI; // broad reflection
#if defined(GI_DDGI_GLOSSY_RADIANCE)
      // Sharp prefiltered-radiance atlas for low roughness, fading to the broad source toward HI.
      vec3 ddgiSharpGlossy = ddgiSampleGlossyRadiance(inWorldSpacePosition, normal, ddgiReflectionVector, viewDirection);
      ddgiGlossyRadiance = mix(ddgiSharpGlossy, ddgiGlossyRadiance, smoothstep(GI_DDGI_GLOSSY_ROUGHNESS_LO, GI_DDGI_GLOSSY_ROUGHNESS_HI, perceptualRoughness));
#endif
      iblSpecularMetal = mix(iblSpecularMetal, ddgiGlossyRadiance, smoothstep(0.3, 0.8, perceptualRoughness));
    }
#endif
    vec3 iblSpecularDielectric = iblSpecularMetal;
    vec3 iblMetalFresnel = getIBLGGXFresnel(normal, viewDirection, perceptualRoughness, baseColor.xyz, 1.0);
    vec3 iblMetalBRDF = iblMetalFresnel * iblSpecularMetal;
    vec3 iblDielectricFresnel = getIBLGGXFresnel(normal, viewDirection, perceptualRoughness, F0Dielectric, specularWeight);    
    vec3 iblDielectricBRDF = mix(iblDiffuse * diffuseOcclusion, iblSpecularDielectric * specularOcclusion, iblDielectricFresnel);
    vec3 iblResultColor = mix(iblDielectricBRDF, iblMetalBRDF * specularOcclusion, metallic); // Dielectric/metallic mix
    vec3 iblSpecular = iblResultColor;

//    vec3 iblSpecular = getIBLRadianceGGX(normal, perceptualRoughness, F0Dielectric, specularWeight, viewDirection, litIntensity, imageLightBasedLightDirection) * iblWeight;

    vec3 transmissionOutput = vec3(0.0);

#if defined(TRANSMISSION)

    transmissionOutput = getIBLVolumeRefraction(normal.xyz, 
                                                 viewDirection,
                                                 clamp(waterDepth * 0.01, 0.0, 1.0), //perceptualRoughness,
                                                 vec3(1.0), //diffuseColorAlpha.xyz, 
                                                 //vec3(waterF0), //F0Dielectric, 
                                                 //vec3(1.0), //F90,
                                                 inWorldSpacePosition,
                                                 waterIOR, 
                                                 volumeThickness, 
                                                 volumeAttenuationColor, 
                                                 volumeAttenuationDistance,
                                                 volumeDispersion);        

#endif

    vec4 screenSpaceReflection = underWater 
                                   ? vec4(0.0) 
                                   : vec4(iblSpecular, 1.0); //getScreenSpaceReflection(worldSpacePosition, normal, -viewDirection, 0.0, vec4(iblSpecular, 1.0));

    vec3 reflection = mix(screenSpaceReflection.xyz, screenSpaceReflection.xyz * albedo.xyz, screenSpaceReflection.w) + colorOutput;
 
  // reflection = vec3(0.1);

#if defined(TRANSMISSION) 
    vec3 refraction = transmissionOutput;
#else
    vec3 refraction = vec3(0.0);
#endif

    // Beer-Lambert per-channel absorption attenuating refraction across the vertical water column,
    // with the deep-water scattering color as the asymptotic floor for fully-attenuated light.
    // The deep-water color represents multiple-scattered downwelling irradiance, so it is
    // modulated by the sum of IBL diffuse (sky) and per-light shadow-attenuated downwelling
    // irradiance (waterDownwellingIrradiance accumulated in processLight) so the volume stays
    // lighting-consistent (dark at night / in shadow, bright at day).
    // waterAbsorption.w (IOR-based fade amount) blends the Beer-Lambert result toward the PBR-correct
    // mix(refraction, waterF0, 1-exp(-depth)) IOR-based water volume appearance.
    vec4 waterAbsorption = vec4(unpackHalf2x16(planetData.waterAbsorptionDeepColor.x), unpackHalf2x16(planetData.waterAbsorptionDeepColor.y));
    vec4 waterDeepColor = vec4(unpackHalf2x16(planetData.waterAbsorptionDeepColor.z), unpackHalf2x16(planetData.waterAbsorptionDeepColor.w));
    vec3 waterDeepIrradiance = waterDiffuseAmbient(inWorldSpacePosition, underWater ? -normal : normal) + waterDownwellingIrradiance;
    vec3 waterDeepLit = waterDeepColor.xyz * waterDeepIrradiance;
    refraction = mix(mix(refraction, waterDeepLit, clamp(vec3(1.0) - exp(-waterDepth * waterAbsorption.xyz), vec3(0.0), vec3(1.0))),
                     mix(refraction, vec3(waterF0), clamp(1.0 - exp(-waterDepth * 1.0), 0.0, 1.0)),
                     clamp(waterAbsorption.w, 0.0, 1.0));

    vec3 waterShade = mix(refraction * waterColor, reflection * waterColor, fresnel) + waterSubscattering;
#if defined(TESSELLATION)
    // Shore foam overlay: fades in where the water becomes shallow and saturates near the
    // waterline. Pattern is a cheap 3D FBM sampled in planet-space (see applyShoreFoam).
    waterShade = applyShoreFoam(waterShade, inBlock.position, waterDepth);
    // Whitecap foam on wave crests, driven by waveAmplitude*waveSteepness threshold.
    waterShade = applyWhitecaps(waterShade, inBlock.position);
#endif

    color.xyz = mix(
      texelFetch(uPassTextures[1], ivec3(gl_FragCoord.xy, gl_ViewIndex), 0).xyz,
      waterShade,
      clamp(1.0 - exp(-max(waterHeight, waterDepth) * 6.0), 0.0, 1.0)
      //clamp(1.0 - exp(-mix(waterHeight, waterDepth, max(0.0, dot(normal, viewDirection))) * 6.0), 0.0, 1.0)
    );

  //  color.xyz = vec3(waterDepth * 0.01);
    
   //color.xyz = max(vec3(0.0), refraction);

//    color.xyz = texelFetch(uPassTextures[1], ivec3(gl_FragCoord.xy, gl_ViewIndex), 0).xyz;

//  color.xyz = mix(refraction, mix(refraction, reflection + diffuse + specularOutput, fresnel), clamp(hitTime * 0.1, 0.0, 1.0));

  }

  //color.xyz = reflection;

  //color.xyz = waterBaseColor * max(0.0, dot(normal, vec3(0.0, 0.0, 1.0)));

  return color;
#endif

}


void main(){
  {
    // Unpack configurable water IORs, base color and (re-)derive waterF0 from waterIOR so the
    // whole shader picks up the per-planet values configured via TpvScene3DPlanet.
    vec4 baseColor4 = vec4(unpackHalf2x16(planetData.waterBaseColorIORs.x), unpackHalf2x16(planetData.waterBaseColorIORs.y));
    vec4 iors4 = vec4(unpackHalf2x16(planetData.waterBaseColorIORs.z), unpackHalf2x16(planetData.waterBaseColorIORs.w));
    waterBaseColor = baseColor4.xyz;
    waterIOR = (iors4.x > 0.0) ? iors4.x : 1.3325;
    airIOR = (iors4.y > 0.0) ? iors4.y : 1.0;
    float f0 = IOR_TO_F0(waterIOR);
    waterF0 = f0 * f0;
    ior = waterIOR / airIOR;
  }
  {
    // Unpack wave parameters for Gerstner swell displacement (tese/mesh + frag normal correction).
    // wp0: (windDirX, windDirY, windDirZ, waveAmplitude)
    // wp1: (waveFrequency, waveSteepness, waveSpeed, unused)
    vec4 wp0 = vec4(unpackHalf2x16(planetData.waterWaveParams.x), unpackHalf2x16(planetData.waterWaveParams.y));
    vec4 wp1 = vec4(unpackHalf2x16(planetData.waterWaveParams.z), unpackHalf2x16(planetData.waterWaveParams.w));
    float wdLen = length(wp0.xyz);
    waveWindDir = (wdLen > 1e-3) ? (wp0.xyz / wdLen) : vec3(1.0, 0.0, 0.0);
    waveAmplitude = wp0.w;
    waveFrequency = wp1.x;
    waveSteepness = wp1.y;
    waveSpeed = wp1.z;
    {
      // wp2: (unused, uvWaveFrequency, uvWaveSpeed, unused) — only freq/speed/scale used for UV chop
      // wp3: (unused, unused, uvWaveScale, unused)
      vec4 wp2 = vec4(unpackHalf2x16(planetData.waterUVWaveParams.x), unpackHalf2x16(planetData.waterUVWaveParams.y));
      vec4 wp3 = vec4(unpackHalf2x16(planetData.waterUVWaveParams.z), unpackHalf2x16(planetData.waterUVWaveParams.w));
      uvWaveFrequency = wp2.y;
      uvWaveSpeed = wp2.z;
      uvWaveScale = wp3.z;
      // dp0: (waveDisplaceAmplitude, displaceHeightLowThreshold, displaceHeightHighThreshold, displaceHeightFactor)
      vec4 dp0 = vec4(unpackHalf2x16(planetData.waterDisplaceParams.x), unpackHalf2x16(planetData.waterDisplaceParams.y));
      waveDisplaceAmplitude       = dp0.x;
      displaceHeightLowThreshold  = dp0.y;
      displaceHeightHighThreshold = dp0.z;
      displaceHeightFactor        = dp0.w;
    }
  }
  {
    // Unpack whitecap-specific parameters.
    // wcp0: (colorR, colorG, colorB, patternScale)
    // wcp1: (slopeThreshLow, slopeThreshHigh, breakupLow, breakupHigh)
    vec4 wcp0 = vec4(unpackHalf2x16(planetData.waterWhitecapParams.x), unpackHalf2x16(planetData.waterWhitecapParams.y));
    vec4 wcp1 = vec4(unpackHalf2x16(planetData.waterWhitecapParams.z), unpackHalf2x16(planetData.waterWhitecapParams.w));
    whitecapColor = wcp0.xyz;
    whitecapPatternScale = wcp0.w;
    whitecapSlopeThreshLow = wcp1.x;
    whitecapSlopeThreshHigh = wcp1.y;
    whitecapBreakupLow = wcp1.z;
    whitecapBreakupHigh = wcp1.w;
    waveWhitecapFactor = unpackHalf2x16(planetData.waterWhitecapParams2.x).x;
  }
  {
    // Unpack shore foam breakup thresholds.
    vec2 sfb = unpackHalf2x16(planetData.waterShoreFoamExtra.x);
    shoreFoamBreakupLow = sfb.x;
    shoreFoamBreakupHigh = sfb.y;
  }
  {
    // Unpack puddle foam suppression thresholds.
    vec2 sfp = unpackHalf2x16(planetData.waterShoreFoamExtra.y);
    shoreFoamPuddleMinHeight = sfp.x;
    shoreFoamPuddleMaxHeight = sfp.y;
  }

#if defined(TESSELLATION)
 
  workNormal = normalize((planetModelMatrix * vec4(getWaterNormal(inBlock.position), 0.0)).xyz) * ((inBlock.underWater > 0.0) ? -1.0 : 1.0);
//workNormal = normalize((planetModelMatrix * vec4(mapNormal(inBlock.localPosition), 0.0)).xyz) * ((inBlock.underWater > 0.0) ? -1.0 : 1.0);

  viewDirection = normalize(-inCameraRelativePosition);

  float opaqueDepth = texelFetch(uPassTextures[2], ivec3(gl_FragCoord.xy, gl_ViewIndex), 0).x;
  {
#if 0
    vec2 uv = (vec2(gl_FragCoord.xy) + vec2(0.5)) / vec2(textureSize(uPassTextures[2], 0).xy);
    vec4 opaqueViewSpace = inverseProjectionMatrix * vec4(fma(uv, vec2(2.0), vec2(-1.0)), opaqueDepth, 1.0);
    opaqueViewSpace /= opaqueViewSpace.w;
    opaqueDepth = -opaqueViewSpace.z; 
#else
    vec2 v = fma(inverseProjectionMatrix[2].zw, vec2(opaqueDepth), inverseProjectionMatrix[3].zw);
    opaqueDepth = -(v.x / v.y);
#endif
  }

  float surfaceDepth = -inBlock.viewSpacePosition.z;

  vec4 finalColor = vec4(0.0, 0.0, 0.0, 1.0);//doShade(abs(inBlock.viewSpacePosition.z), inBlock.underWater > 0.0);
  
  if((inBlock.underWater > 0.0) /*&& (inBlock.mapValue < 0.0)*/){
    finalColor = vec4(textureLod(uPassTextures[1], vec3((vec2(gl_FragCoord.xy) + vec2(0.5)) / vec2(float(uint(pushConstants.resolutionXY & 0xffffu)), float(uint(pushConstants.resolutionXY >> 16u))), gl_ViewIndex), 1.0).xyz * waterBaseColor * waterBaseColor, 1.0);
  }else{
    finalColor = doShade(opaqueDepth, surfaceDepth, inBlock.underWater > 0.0);
  }

  outFragColor = vec4(clamp(finalColor.xyz * finalColor.w, vec3(-65504.0), vec3(65504.0)), finalColor.w);

  if((inBlock.meshletID & 0x80000000u) != 0u) {
    outFragColor = vec4(meshletDebugColor(inBlock.meshletID & 0x7fffffffu), 1.0);
  }

#elif defined(UNDERWATER)

  vec4 finalColor = vec4(textureLod(uPassTextures[1], vec3(inBlock.texCoord, gl_ViewIndex), 1.0).xyz * waterBaseColor * waterBaseColor, 1.0);

  // Shore-foam overlay for the underwater fullscreen pass: reconstruct the ground geometry's
  // planet-space position from the opaque depth buffer and compare against the water surface
  // height at that sphere direction. Where the two are close, we are at a shallow shore spot and
  // applyShoreFoam tints the foam color on top of the underwater look.
  {
    float rawDepth = texelFetch(uPassTextures[2], ivec3(gl_FragCoord.xy, gl_ViewIndex), 0).x;
    vec4 clipPos = vec4(fma(inBlock.texCoord, vec2(2.0), vec2(-1.0)), rawDepth, 1.0);
    vec4 viewPos = inverseProjectionMatrix * clipPos;
    viewPos /= viewPos.w;
    vec3 worldPos = (inverseViewMatrix * viewPos).xyz;
    vec3 planetPos = (planetInverseModelMatrix * vec4(worldPos, 1.0)).xyz;
    float groundRadius = length(planetPos);
    if(groundRadius > 1e-3){
      vec3 sphereNormal = planetPos / groundRadius;
      float waterRadius = getSphereHeightEx(octPlanetUnsignedEncode(sphereNormal));
      if(waterRadius > 0.0){
        float shoreDepth = max(0.0, waterRadius - groundRadius);
        // The global workNormal/viewDirection are only set on the tessellated surface, not in this fullscreen pass, but
        // applyShoreFoam's ambient lookup (waterDiffuseAmbient -> IBL or DDGI) reads them. Use the world-space surface
        // up-normal at the shore point and the direction toward the camera so the DDGI/IBL diffuse stays well-defined.
        workNormal = normalize((planetModelMatrix * vec4(sphereNormal, 0.0)).xyz);
        viewDirection = normalize(inverseViewMatrix[3].xyz - worldPos);
        finalColor.xyz = applyShoreFoam(finalColor.xyz, planetPos, shoreDepth);
      }
    }
  }

  outFragColor = vec4(clamp(finalColor.xyz * finalColor.w, vec3(-65504.0), vec3(65504.0)), finalColor.w);

#elif defined(WATER_CAUSTICS)

  // Reconstruct the world-space terrain position from the opaque depth buffer.
  float rawDepth = texelFetch(uPassTextures[2], ivec3(gl_FragCoord.xy, gl_ViewIndex), 0).x;
  vec4 clipPos = vec4(fma(inBlock.texCoord, vec2(2.0), vec2(-1.0)), rawDepth, 1.0);
  vec4 viewPos = inverseProjectionMatrix * clipPos;
  viewPos /= viewPos.w;
  vec3 worldPos = (inverseViewMatrix * viewPos).xyz;
  vec3 planetPos = (planetInverseModelMatrix * vec4(worldPos, 1.0)).xyz;
  float groundRadius = length(planetPos);

  if(groundRadius > 1e-3){
    vec3 sphereNormal = planetPos / groundRadius;
    float waterRadius = getSphereHeightEx(octPlanetUnsignedEncode(sphereNormal));
    if(waterRadius > groundRadius){
      float waterDepth = waterRadius - groundRadius;
      vec2 cp0 = unpackHalf2x16(planetData.waterCausticParams.x);
      float causticIntensity = cp0.x;
      if(causticIntensity > 0.0){
        vec2 cp1 = unpackHalf2x16(planetData.waterCausticParams.y);
        vec2 cp2 = unpackHalf2x16(planetData.waterCausticParams.z);
        float causticScale = cp0.y;
        float causticFadeDepth = cp1.x;
        float causticSpeed = cp1.y;
        float time = pushConstants.time;
        float caustic = getCausticIntensity(planetPos, time, causticScale, causticSpeed, causticFadeDepth, waterDepth, cp2.x, cp2.y);
        // Additive caustic light; alpha=0 so we don't disturb the composite alpha.
        outFragColor = vec4(causticIntensity * caustic * vec3(unpackHalf2x16(planetData.waterCausticParams2.x), unpackHalf2x16(planetData.waterCausticParams2.y).x), 0.0); // caustic tint color
      } else {
        discard;
      }
    } else {
      discard;
    }
  } else {
    discard;
  }

#else
#ifdef MULTIVIEW
  vec3 texCoord = vec3(inTexCoord, float(gl_ViewIndex));
#else
  vec2 texCoord = inTexCoord;
#endif

#if defined(MSAA) && !defined(MSAA_FAST) 
  
  // With MSAA, this fullscreen water rendering pass per ray marching will be become SSAA actually effectively,
  // where each sample is processed separately.

  vec2 resolution = vec2(textureSize(uPassTextures[2], 0).xy);

  texCoord.xy += vec2(gl_SamplePosition.xy) / resolution;

#endif
  
  bool reversedZ = projectionMatrix[2][3] < -1e-7;
  
  //bool infiniteFarPlane = reversedZ && ((abs(projectionMatrix[2][2]) < 1e-7) && (abs(projectionMatrix[3][2]) > 1e-7));

  vec4 nearPlane = vec4(fma(texCoord.xy, vec2(2.0), vec2(-1.0)), reversedZ ? 1.0 : 0.0, 1.0);

  vec4 cameraPosition = vec4((inverseProjectionMatrix * nearPlane).xyz, 1.0); 
  cameraPosition /= cameraPosition.w;

  vec4 cameraDirection = vec4((inverseProjectionMatrix * nearPlane).xyz, 0.0); 
      
/*vec4 primaryRayOrigin = inverseViewProjectionMatrix * vec4(fma(texCoord.xy, vec2(2.0), vec2(-1.0)), reversedZ ? 1.0 : 0.0, 1.0);
  primaryRayOrigin /= primaryRayOrigin.w;*/

  vec3 rayOrigin = inverseViewMatrix[3].xyz;

  vec3 rayDirection = normalize((inverseViewMatrix * cameraDirection).xyz);
  
  // Transform world space ray origin and direction to planet space for simplicity, so that the planet is at the origin and 
  // correctly oriented. This is not strictly necessary, but it simplifies the math. 
  rayOrigin = (planetInverseModelMatrix * vec4(rayOrigin, 1.0)).xyz;
  rayDirection = (planetInverseModelMatrix * vec4(rayDirection, 0.0)).xyz;

  viewDirection = -rayDirection;

  float hitRayTime;
   
  bool hit = false;

  float hitDepth = 0.0;
  
  vec4 finalColor = vec4(0.0);

  // Pre-check if the ray intersects the planet's bounding sphere
  if(intersectRaySphere(vec4(planetCenter, planetTopRadius * 1.0), 
                        rayOrigin,
                        rayDirection,     
                        hitRayTime)){

    // Get the hit time from the lower resolution water prepass, so that the ray does not need to be traced if the ray does not hit the planet
    // and so that we can skip empty space as much as possible for faster ray marching. 
    float prepassTime = 0.0;//textureLod(uTextureWaterAcceleration, vec3(inTexCoord, gl_ViewIndex), 0.0).x;

    if(prepassTime > 0.0){ 
      hitRayTime = max(hitRayTime, prepassTime);
    }

    bool underWater = map(rayOrigin) <= 0.0;

#ifdef MSAA 
#if defined(MSAA_FAST)
    // In the MSAA_FAST case, the depth is fetched from the pre-resolved MSAA depth buffer, not from the actual MSAA depth buffer, since
    // the water is not multisampled here, even if the input is multisampled but also pre-resolved. 
    float opaqueDepth = texelFetch(uPassTextures[2], ivec3(gl_FragCoord.xy, gl_ViewIndex), 0).x;
#else
    // In the MSAA case, the depth is fetched from the actual MSAA depth buffer, since the water is multisampled here, or better said,
    // supersampled, since all fragment samples are processed separately, not just the geometric edges as like at MSAA otherwise with
    // geometry triangles.
    float opaqueDepth = subpassLoad(uOITImgDepth, gl_SampleID).x; 
#endif
#else
    // And without MSAA at all, the depth is just fetched from the non-MSAA depth buffer, since we are not multisampled here at all anyway.
    float opaqueDepth = subpassLoad(uOITImgDepth).x; 
#endif 

    float opaqueLinearDepth = -linearizeDepth(opaqueDepth);

    bool inside = length(rayOrigin - planetCenter) <= planetTopRadius;

    rayOrigin += (inside ? vec3(0.0) : (rayDirection * hitRayTime));

    float maxTime = min(
      opaqueLinearDepth,
      max(
        length((planetCenter - (rayDirection * planetBottomRadius)) - rayOrigin),
        length((planetCenter - (rayDirection * planetTopRadius)) - rayOrigin)
      )
    );

#ifndef ONLY_UNDERWATER
    float hitTime;

    vec3 hitPoint;

#if 0
    if((prepassTime >= 0.0) &&
      //acceleratedRayMarching(rayOrigin, rayDirection, 0.0, maxTime, 0.6, underWater ? 0.9 : 1.0, hitTime)
      standardRayMarching(rayOrigin, rayDirection, 0.0, maxTime, hitTime)
      )
#else
    if(planetRayMarching(rayOrigin, rayDirection, maxTime, hitTime))
#endif
    {

      hitPoint = rayOrigin + (rayDirection * hitTime); // in planet space

      worldSpacePosition = (planetModelMatrix * vec4(hitPoint, 1.0)).xyz;

      viewSpacePosition = (viewMatrix * vec4(worldSpacePosition, 1.0)).xyz;

      hit = opaqueLinearDepth >= -viewSpacePosition.z;    
      
    }

    if(hit){

      hitDepth = delinearizeDepth(viewSpacePosition.z);

      workNormal = normalize((planetModelMatrix * vec4(mapNormal(hitPoint), 0.0)).xyz) * (underWater ? -1.0 : 1.0);

      cameraRelativePosition = worldSpacePosition - cameraPosition.xyz;

      finalColor = doShade(maxTime, hitTime, underWater);

//    finalColor = vec4(workNormal.xyz * 0.1, 1.0);//doShade();
  
    }else 
#endif
    if(underWater){

      vec3 r = textureLod(uPassTextures[1], vec3(inTexCoord, gl_ViewIndex), 1.0).xyz;
      finalColor = vec4(r * waterBaseColor * waterBaseColor, 1.0);

      hitDepth = opaqueDepth;

      hit = true;

    }     
    
  }  

  if(!hit){
    // If the ray does not hit the planet, discard the fragment, since it is not visible. Use demote if available. 
#if defined(USEDEMOTE)
    demote;
#else 
    discard;
#endif
  }

  outFragColor = vec4(clamp(finalColor.xyz * finalColor.w, vec3(-65504.0), vec3(65504.0)), finalColor.w);
#endif
} 