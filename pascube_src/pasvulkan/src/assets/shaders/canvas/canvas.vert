#version 450 core

// Copyright (C) 2017, Benjamin 'BeRo' Rosseaux (benjamin@rosseaux.de)
// License: zlib 

layout(location = 0) in vec2 inOriginalPosition;
layout(location = 1) in vec3 inPosition; 
layout(location = 2) in vec4 inColor;    
#if USETEXTURE
layout(location = 3) in vec3 inTexCoord; 
#endif
layout(location = 4) in uint inState;    
layout(location = 5) in vec4 inClipRect; 
layout(location = 6) in vec4 inMetaInfo; 
layout(location = 7) in vec4 inMetaInfo2; 

layout(location = 0) out vec2 outOriginalPosition;
layout(location = 1) out vec2 outPosition;
layout(location = 2) out vec4 outColor;
#if USETEXTURE
layout(location = 3) out vec3 outTexCoord;
#endif
layout(location = 4) flat out ivec4 outState;    
layout(location = 5) out vec4 outMetaInfo; 
layout(location = 6) out vec4 outMetaInfo2; 
layout(location = 7) out vec2 outClipSpacePosition; 
#if !USECLIPDISTANCE
layout(location = 8) out vec4 outClipRect; 
#endif

layout(push_constant, std140) uniform PushConstants {
  // three matrices in a packed form to avoid alignment issues, since the std140 layout is only 
  // supported for push constants in the most cases, and push constants are limited in size (max. 
  // 128 bytes in the most cases)
  uvec4 data[8]; // 8 uvec4s = 128 bytes, which fits within typical push constant limits
} pushConstants;

/*
mat3 transformMatrix = mat3(
  uintBitsToFloat(uvec3(pushConstants.data[0].xyz)),                         
  uintBitsToFloat(uvec3(pushConstants.data[0].w, pushConstants.data[1].xy)),
  uintBitsToFloat(Uvec3(pushConstants.data[1].zw, pushConstants.data[2].x))
);

mat4 fillMatrix = mat4(
  uintBitsToFloat(uvec4(pushConstants.data[2].yzw, 0.0)),
  uintBitsToFloat(uvec4(pushConstants.data[3].xyz, 0.0)),
  uintBitsToFloat(uvec4(pushConstants.data[3].w, pushConstants.data[4].xyz)),
  uintBitsToFloat(uvec4(pushConstants.data[4].w, pushConstants.data[5].xyz))
);

mat3x2 maskMatrix = mat3x2(
  uintBitsToFloat(uvec2(pushConstants.data[5].w, pushConstants.data[6].x)),
  uintBitsToFloat(uvec2(pushConstants.data[6].yz)),
  uintBitsToFloat(uvec2(pushConstants.data[6].w, pushConstants.data[7].x))
);
*/

out gl_PerVertex {
  vec4 gl_Position;
#if USECLIPDISTANCE
  float gl_ClipDistance[];  
#endif
};

void main(void){
  outOriginalPosition = inOriginalPosition;
  outPosition = inPosition.xy;
  outColor = inColor;
#if USETEXTURE
  outTexCoord = inTexCoord;
#endif
  outState = ivec4(uvec4((inState >> 0u) & 0x3u,
                         (inState >> 2u) & 0xffu,                         
                         (inState >> 10u) & 0xfu,                         
                         (inState >> 14u) & 0xfu));
#if !USECLIPDISTANCE
  outClipRect = inClipRect;
#endif
  outMetaInfo = inMetaInfo;
  outMetaInfo2 = inMetaInfo2;
  const mat3 transformMatrix = mat3(
    uintBitsToFloat(uvec3(pushConstants.data[0].xyz)),  
    uintBitsToFloat(uvec3(pushConstants.data[0].w, pushConstants.data[1].xy)),
    uintBitsToFloat(uvec3(pushConstants.data[1].zw, pushConstants.data[2].x))
  );
  vec3 p = transformMatrix * vec3(inPosition.xy, 1.0);
  vec2 clipSpacePosition = outClipSpacePosition = p.xy / p.z;
  gl_Position = vec4(clipSpacePosition, 1.0 - inPosition.z, 1.0);
#if USECLIPDISTANCE
  gl_ClipDistance[0] = clipSpacePosition.x - inClipRect.x;
  gl_ClipDistance[1] = clipSpacePosition.y - inClipRect.y;
  gl_ClipDistance[2] = inClipRect.z - clipSpacePosition.x;
  gl_ClipDistance[3] = inClipRect.w - clipSpacePosition.y;
#endif
}