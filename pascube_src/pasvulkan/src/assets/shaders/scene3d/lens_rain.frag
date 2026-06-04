#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outFragColor;

layout(push_constant) uniform PushConstants {
  float factor;
  float time;  
} pushConstants;

layout(set = 0, binding = 0) uniform sampler2DArray uInputTexture;

uint pcgHash11(const in uint v){
  uint s = (v * 747796405u) + 2891336453u;
  uint w = ((s >> ((s >> 28u) + 4u)) ^ s) * 277803737u;
  return (w >> 22u) ^ w;
}

uint pcgHash21(const in uvec2 v){
  return pcgHash11(v.x + pcgHash11(v.y));
}

uint pcgHash31(const in uvec3 v){
  return pcgHash11(v.x + pcgHash11(v.y + pcgHash11(v.z)));
}

uvec2 pcgHash22(uvec2 v){
  v = (v * 1664525u) + 1013904223u;
  v.x += v.y * 1664525u;
  v.y += v.x * 1664525u;
  v = v ^ (v>>16u);
  v.x += v.y * 1664525u;
  v.y += v.x * 1664525u;
  v = v ^ (v>>16u);
  return v;
}

uvec3 pcgHash33(uvec3 v){
  v = (v * 1664525u) + 1013904223u;
  v.x += v.y * v.z;
  v.y += v.z * v.x;
  v.z += v.x * v.y;
  v = v ^ (v >> 16u);
  v.x += v.y * v.z;
  v.y += v.z * v.x;
  v.z += v.x * v.y;
  return v;
}

float pcgHash11(const in float p){
  return uintBitsToFloat(((pcgHash11(floatBitsToUint(p)) >> 9u) & 0x007fffffu) | 0x3f800000u) - 1.0;
}
      
float pcgHash21(const in vec2 p){
  return uintBitsToFloat(((pcgHash21(floatBitsToUint(p)) >> 9u) & 0x007fffffu) | 0x3f800000u) - 1.0;
}             

float pcgHash31(const in vec3 p){
  return uintBitsToFloat(((pcgHash31(floatBitsToUint(p)) >> 9u) & 0x007fffffu) | 0x3f800000u) - 1.0;
}

vec2 pcgHash22(const in vec2 p){
  return uintBitsToFloat(((pcgHash22(floatBitsToUint(p)) >> uvec2(9u)) & uvec2(0x007fffffu)) | uvec2(0x3f800000u)) - vec2(1.0);
}

vec3 pcgHash33(const in vec3 p){
  return uintBitsToFloat(((pcgHash33(floatBitsToUint(p)) >> uvec3(9u)) & uvec3(0x007fffffu)) | uvec3(0x3f800000u)) - vec3(1.0);
}

vec3 pcgHash23(const in vec2 p){
   return pcgHash33(vec3(p.xyx));
}

float noise31(vec3 p){
  vec3 i = floor(p);
  vec3 f = fract(p);
  f = f * f * (f * ((f * 6.0) - vec3(15.0)) + vec3(10.0));
  return mix(mix(mix(pcgHash31(i + vec3(0.0, 0.0, 0.0)), pcgHash31(i + vec3(1.0, 0.0, 0.0)), f.x), 
                 mix(pcgHash31(i + vec3(0.0, 1.0, 0.0)), pcgHash31(i + vec3(1.0, 1.0, 0.0)), f.x), f.y), 
             mix(mix(pcgHash31(i + vec3(0.0, 0.0, 1.0)), pcgHash31(i + vec3(1.0, 0.0, 1.0)), f.x), 
                 mix(pcgHash31(i + vec3(0.0, 1.0, 1.0)), pcgHash31(i + vec3(1.0, 1.0, 1.0)), f.x), f.y), f.z);
}

float sdEgg(in vec2 p, in float ra, in float rb){
  const float k = sqrt(3.0);
  p.x = abs(p.x);
  float r = ra - rb;
  return ((p.y < 0.0) ? (length(vec2(p)) - r) : ((k * (p.x + r)) < p.y) ? length(vec2(p.x, p.y - (k * r))) : (length(vec2(p.x + r , p.y)) - (2.0 * r))) - rb;
}

float time = pushConstants.time;

vec3 layerFactors = smoothstep(vec3(-0.5, 0.25, 0.0), vec3(1.0, 0.75, 0.5), vec3(pushConstants.factor)) * vec2(2.0, 1.0).xyy;

vec2 getSample(vec2 uv){

  uv *= 0.5;

  vec2 layerUV = (uv * 24.0) + vec2(0.0, time * 0.1); 
  vec2 rand = vec2(pcgHash22(floor(layerUV) * vec2(96.57, 2341.823)));
  float f = fract((time * 0.1) + noise31(vec3(rand, time * 0.1)));
  vec3 heights = vec2(
   smoothstep(
     mix(0.125, 0.3275, pcgHash21(rand * vec2(14.2183, 5.7319))), 
     0.0, 
     length((fract(layerUV) - vec2(0.5)) - (mix(vec2(-0.375), vec2(0.375), rand.xy)).xy)) * 
     smoothstep(0.0, 0.1, f) * smoothstep(1.0, 0.1, f) * 
     fract(rand.x * 23.0),
   0.0
  ).xyy;                 
 
  const vec2 scale = vec2(0.946713, 1.746235);
  const vec2 offset = vec2(-0.897361, 0.724913);
  
  // 1) Grid setup & per‐column randomness
  vec4 uvCoord = fma(uv.xyxy, scale.xxyy, offset.xxyy);
  vec4 originalUV = uvCoord;
  vec4 dropScale = vec2(8.0, 1.5).xyxy;
  vec4 gridSize = dropScale * 2.0;
  vec4 cellCoord = floor(uvCoord * gridSize);
  vec2 columnRandom = vec2(pcgHash11(cellCoord.x), pcgHash11(cellCoord.z));
  vec2 fallSpeed = fma(columnRandom, vec2(0.3333333), vec2(0.5));

  // 2) Single vertical shift before tiling
  uvCoord.yw += vec2(((time * fallSpeed) / vec2(dropScale.yw)) + columnRandom);

  // 3) One calc of cell + local coords
  vec4 gridUV = uvCoord * gridSize;
  cellCoord = floor(gridUV);
  vec4 cellUV = fract(gridUV) - (vec2(0.5, 0.0).xyxy);

  // 4) Drop randomness
  vec3 randomValues[2] = vec3[2](pcgHash23(cellCoord.xy), pcgHash23(cellCoord.zw));

  // 5) Compute drop center X with ripple and drop Y
  vec2 phase = fract(time * (fallSpeed + vec2(0.1)) + vec2(randomValues[0].z, randomValues[1].z));
  const vec2 slowStartThreshold = vec2(0.75);
  vec4 drop = vec4(
    vec2(randomValues[0].x, randomValues[1].x) - vec2(0.5), 
    fma((smoothstep(vec2(0.0), slowStartThreshold, phase) * smoothstep(vec2(1.0), slowStartThreshold, phase)) - vec2(0.5), vec2(0.9), vec2(0.5))
  ).xzyw;
  drop.xz = (drop.xz + (sin((originalUV.yw * 32.0) + sin((originalUV.yw * 32.0) + sin(originalUV.yw * 32.0))) * (vec2(0.5) - abs(drop.xz)) * (vec2(randomValues[0].z, randomValues[1].z) - vec2(0.5)))) * vec2(0.75);

  // 7) Main drop mask
#if 1
  vec2 dist = vec2(
    sdEgg((cellUV.xy - drop.xy) * dropScale.yx, 0.0, (time > slowStartThreshold.x) ? fma(sin(6.283185307179586 * time / (1.0 - slowStartThreshold.x)), -0.5, -0.5) : 0.0),
    sdEgg((cellUV.zw - drop.zw) * dropScale.wz, 0.0, (time > slowStartThreshold.y) ? fma(sin(6.283185307179586 * time / (1.0 - slowStartThreshold.y)), -0.5, -0.5) : 0.0)
  );
#else
  vec2 dist = vec2(
    length((cellUV.xy - drop.xy) * dropScale.yx), 
    length((cellUV.zw - drop.zw) * dropScale.wz)
  );
#endif
  vec2 dropDiameter = fma(vec2(randomValues[0].z, randomValues[1].z), vec2(0.14285714), vec2(0.2));
  vec2 mainDropMask = smoothstep(dropDiameter * 0.666666, vec2(0.0), dist);

  // 8) Broad “wake” trail behind drop
  vec2 verticalBlend = smoothstep(vec2(1.0), drop.yw, cellUV.yw);
  vec2 verticalBlendSqrt = sqrt(verticalBlend);
  vec2 horizontalDistance = abs(cellUV.xz - drop.xz);
  vec2 trailThickness = dropDiameter * vec2(0.9275);
  vec2 trailFrontMask = smoothstep(vec2(-0.015625), vec2(0.015625), cellUV.yw - drop.yw);
  vec2 trailMask = smoothstep(trailThickness * verticalBlendSqrt, vec2(0.0), horizontalDistance) * verticalBlend * trailFrontMask * vec2(0.5);

  // 9) Micro‐droplets along the trail
  vec2 trail2Mask = smoothstep(
    (trailThickness - vec2(0.125)) * verticalBlendSqrt, 
    vec2(0.0), 
    horizontalDistance
  ) * trailFrontMask * vec2(randomValues[0].z, randomValues[1].z);
  
  vec2 dropletsMask = smoothstep(
    trail2Mask + fma(
      vec2(pcgHash11(cellUV.y), pcgHash11(cellUV.w)), 
      vec2(0.0025), 
      vec2(0.05)
    ), 
    vec2(0.0), 
    vec2(
      length(cellUV.xy - vec2(drop.x, fract(originalUV.y * fma(pcgHash11(cellCoord.x), 0.6666, 0.5) * 7.0) + (cellUV.y - 0.5))), 
      length(cellUV.zw - vec2(drop.z, fract(originalUV.w * fma(pcgHash11(cellCoord.z), 0.6666, 0.5) * 7.0) + (cellUV.w - 0.5)))
    )
  );

  // 10) Combine main drop + micro‐droplets
  heights.yz = mainDropMask + (dropletsMask * verticalBlendSqrt * trailFrontMask);
  
  return vec2(smoothstep(0.25, 1.0, dot(heights * layerFactors, vec3(1.0))), max(trailMask.x * layerFactors.y, trailMask.y * layerFactors.z));
}

void main(){

  if(pushConstants.factor > 1e-7){

    vec2 inputTextureSize = textureSize(uInputTexture, 0).xy;

    vec2 uv = fma(inTexCoord, vec2(-2.0), vec2(1.0)) * vec2(1.0, inputTextureSize.y / inputTextureSize.x); 
      
    vec2 center = getSample(uv);

    vec3 e = vec2(1.0, 0.0).xxy / vec3(inputTextureSize, 1.0);

    float blur = mix(1.0 - center.y, 0.0, smoothstep(0.1, 0.2, center.x)) * smoothstep(0.0, 0.5, pushConstants.factor) * 0.75;
    
    vec4 blurredColor = vec4(0.0);
    if(blur > 1e-4){      
      // TODO
    }  
      
    outFragColor = mix(
      textureLod(
        uInputTexture, 
        vec3(inTexCoord + ((vec2(getSample(uv + e.xz).x, getSample(uv + e.zy).x) - center.xx) * smoothstep(0.0, 0.1, pushConstants.factor)), float(gl_ViewIndex)),     
        0.0
      ),
      blurredColor,
      clamp(blur, 0.0, 1.0)*0.0
    );

  }else{

  //outFragColor = textureLod(uInputTexture, vec3(inTexCoord, float(gl_ViewIndex)), 0.0);
    outFragColor = texelFetch(uInputTexture, ivec3(gl_FragCoord.xy, gl_ViewIndex), 0);

  }
      
}