#ifndef TANGENTSPACE_GLSL
#define TANGENTSPACE_GLSL

// Copyright 2024, Benjamin 'BeRo' Rosseaux - zlib licensed

/*
** Encoding and decoding functions from tangent space vectors to a single 32-bit unsigned integer (four bytes) in
** RGB10A2_SNORM format and back.
** 
** These functions are used to encode and decode tangent space vectors into a single 32-bit unsigned integer.
** The encoding is done using the RGB10A2 snorm format, which allows to store the tangent space in a single integer.
** The encoding is lossy, but the loss is very small and the precision is enough for most use cases.
** 
** The encoding is done as follows:
** 1. The normal is projected onto the octahedron, which is a 2D shape that represents the normal in a more efficient way.
** 2. The tangent is projected onto the canonical diamond space, which is a 2D space that is aligned with the normal.
** 3. The tangent is projected onto the tangent diamond, which is a 1D space that represents the tangent in a more efficient way.
** 4. The bitangent sign is stored in signed 2 bits as -1.0 or 1.0.
** 5. The values are packed into a single 32-bit unsigned integer using the RGB10A2 snorm format.
** 
** The decoding is done as follows:
** 1. The values are unpacked from the RGB10A2 snorm format.
** 2. The normal is decoded from the octahedron.
** 3. The canonical directions are found.
** 4. The tangent diamond is decoded.
** 5. The tangent is found using the canonical directions and the tangent diamond.
** 6. The bitangent is found using the normal, the tangent and the bitangent sign. 
** 
** Idea based on https://www.jeremyong.com/graphics/2023/01/09/tangent-spaces-and-diamond-encoding/ but with improvements for
** packing into RGB10A2 snorm to a 32-bit unsigned integer.
**
**/

#ifdef WEBGL
uint packSnorm4x8(vec4 v){
  uvec4 e = (uvec4(ivec4(round(clamp(v, -1.0, 1.0) * 127.0))) & uvec4(0xffu)) << uvec4(0u, 8u, 16u, 24u);
  return e.x | e.y | e.z | e.w;
}

vec4 unpackSnorm4x8(uint v){
  ivec4 e = ivec4(
    int(uint(v << 24u)) >> 24,
    int(uint(v << 16u)) >> 24,
    int(uint(v << 8u)) >> 24,
    int(uint(v)) >> 24
  );
  return vec4(e) / 127.0;
}
#endif

mat2x3 getCanonicalSpaceFromNormal(in vec3 n){
  vec3 t = n.yzx - n.zxy, b = normalize(cross(n, t = normalize(t - dot(t, n))));
  return mat2x3(t, b); 
}

mat3 decodeTangentSpaceFromRGB10A2SNorm(const in uint encodedTangentSpace){

  // Unpack the values from RGB10A2 snorm
  ivec4 encodedTangentSpaceUnpacked = ivec4(
    int(uint(encodedTangentSpace << 22u)) >> 22,
    int(uint(encodedTangentSpace << 12u)) >> 22,
    int(uint(encodedTangentSpace << 2u)) >> 22,
    int(uint(encodedTangentSpace << 0u)) >> 30
  );

  // Decode the tangent space
  vec2 octahedronalNormal = vec2(encodedTangentSpaceUnpacked.xy) / 511.0;
  vec3 normal = vec3(octahedronalNormal, 1.0 - (abs(octahedronalNormal.x) + abs(octahedronalNormal.y)));
  normal = normalize((normal.z < 0.0) ? vec3((1.0 - abs(normal.yx)) * fma(step(vec2(0.0), normal.xy), vec2(2.0), vec2(-1.0)), normal.z) : normal);

  // Find the canonical space
  mat2x3 canonicalSpace = getCanonicalSpaceFromNormal(normal);
  
  // Decode the tangent diamond direction
  float tangentDiamond = float(encodedTangentSpaceUnpacked.z) / 511.0;
  float tangentDiamondSign = (tangentDiamond < 0.0) ? -1.0 : 1.0; // No sign() because for 0.0 in => 1.0 out
  vec2 tangentInCanonicalSpace;
  tangentInCanonicalSpace.x = 1.0 - (tangentDiamond * tangentDiamondSign * 2.0);
  tangentInCanonicalSpace.y = tangentDiamondSign * (1.0 - abs(tangentInCanonicalSpace.x));
  tangentInCanonicalSpace = normalize(tangentInCanonicalSpace);
  
  // Decode the tangent
  vec3 tangent = normalize(canonicalSpace * tangentInCanonicalSpace);

  // Decode the bitangent
  vec3 bitangent = normalize(cross(normal, tangent) * float(encodedTangentSpaceUnpacked.w));

  return mat3(tangent, bitangent, normal);

}

uint encodeTangentSpaceAsRGB10A2SNorm(mat3 tbn){

  // Normalize tangent space vectors, just for the sake of clarity and for to be sure
  tbn[0] = normalize(tbn[0]);
  tbn[1] = normalize(tbn[1]);
  tbn[2] = normalize(tbn[2]);

  // Get the octahedron normal
  vec3 normal = tbn[2];
  vec2 octahedronalNormal = normal.xy / (abs(normal.x) + abs(normal.y) + abs(normal.z)); 
  octahedronalNormal = (normal.z < 0.0) ? ((1.0 - abs(octahedronalNormal.yx)) * fma(step(vec2(0.0), octahedronalNormal.xy), vec2(2.0), vec2(-1.0))) : octahedronalNormal;
  
  // Find the canonical space
  mat2x3 canonicalSpace = getCanonicalSpaceFromNormal(normal);

  // Project the tangent into the canonical space 
  vec2 tangentInCanonicalSpace = vec2(dot(tbn[0], canonicalSpace[0]), dot(tbn[0], canonicalSpace[1]));
  
  // Find the tangent diamond direction (a diamond is more or less the 2D equivalent of the 3D octahedron here in this case)
  float tangentDiamond = (1.0 - (tangentInCanonicalSpace.x / (abs(tangentInCanonicalSpace.x) + abs(tangentInCanonicalSpace.y)))) * ((tangentInCanonicalSpace.y < 0.0) ? -1.0 : 1.0) * 0.5;

  // Find the bitangent sign
  float bittangentSign = (dot(cross(tbn[0], tbn[1]), tbn[2]) < 0.0) ? -1.0 : 1.0; 

  // Encode the tangent space as signed values
  ivec4 encodedTangentSpace = ivec4(
    ivec2(clamp(octahedronalNormal, vec2(-1.0), vec2(1.0)) * 511.0), // 10 bits including sign
    int(clamp(tangentDiamond, -1.0, 1.0) * 511.0), // 10 bits including sign
    int(clamp(bittangentSign, -1.0, 1.0)) // 2 bits
  );
  
  // Pack the values into RGB10A2 snorm
  uint t = ((uint(encodedTangentSpace.x) & 0x3ffu) << 0u) | 
           ((uint(encodedTangentSpace.y) & 0x3ffu) << 10u) | 
           ((uint(encodedTangentSpace.z) & 0x3ffu) << 20u) | 
           ((uint(encodedTangentSpace.w) & 0x3u) << 30u);
     
#if 1
  // Optional step for ensure that the bitangent sign is correct 
  if(dot(decodeTangentSpaceFromRGB10A2SNorm(t)[1], tbn[1]) < 0.0){
     t = (t & 0x3fffffffu) | ((uint(int(-encodedTangentSpace.w)) & 0x3u) << 30u);
  }
#endif
  
  return t;

}

// 10bit 10bit 9bit for the 3 smaller components of the quaternion and 1bit for the sign of the bitangent and 2bit for the 
// largest component index for the reconstruction of the largest component of the quaternion.
// Since the three smallest components of a quaternion are between -1/sqrt(2) and 1/sqrt(2), we can rescale them to -1 .. 1
// while encoding, and then rescale them back to -1/sqrt(2) .. 1/sqrt(2) while decoding, for a better precision.
uint encodeQTangentUI32(mat3 m){
  float r = (determinant(m) < 0.0) ? -1.0 : 1.0; // Reflection matrix handling 
  m[2] *= r;
#if 0
  // When the input matrix is always a valid orthogonal tangent space matrix, we can simplify the quaternion calculation to just this:  
  vec4 q = vec4(m[1][2] - m[2][1], m[2][0] - m[0][2], m[0][1] - m[1][0], 1.0 + m[0][0] + m[1][1] + m[2][2]);
#else  
  // Otherwise we have to handle all other possible cases as well.
  float t = m[0][0] + (m[1][1] + m[2][2]);
  vec4 q;
  if(t > 2.9999999){
    q = vec4(0.0, 0.0, 0.0, 1.0);
  }else if(t > 0.0000001){
    float s = sqrt(1.0 + t) * 2.0;
    q = vec4(vec3(m[1][2] - m[2][1], m[2][0] - m[0][2], m[0][1] - m[1][0]) / s, s * 0.25);
  }else if((m[0][0] > m[1][1]) && (m[0][0] > m[2][2])){
    float s = sqrt(1.0 + (m[0][0] - (m[1][1] + m[2][2]))) * 2.0;
    q = vec4(s * 0.25, vec3(m[1][0] + m[0][1], m[2][0] + m[0][2], m[1][2] - m[2][1]) / s);    
  }else if(m[1][1] > m[2][2]){
    float s = sqrt(1.0 + (m[1][1] - (m[0][0] + m[2][2]))) * 2.0;
    q = vec4(vec3(m[1][0] + m[0][1], m[2][1] + m[1][2], m[2][0] - m[0][2]) / s, s * 0.25).xwyz;
  }else{
    float s = sqrt(1.0 + (m[2][2] - (m[0][0] + m[1][1]))) * 2.0;
    q = vec4(vec3(m[2][0] + m[0][2], m[2][1] + m[1][2], m[0][1] - m[1][0]) / s, s * 0.25).xywz; 
  }
#endif  
  vec4 qAbs = abs(q = normalize(q));
  int maxComponentIndex = (qAbs.x > qAbs.y) ? ((qAbs.x > qAbs.z) ? ((qAbs.x > qAbs.w) ? 0 : 3) : ((qAbs.z > qAbs.w) ? 2 : 3)) : ((qAbs.y > qAbs.z) ? ((qAbs.y > qAbs.w) ? 1 : 3) : ((qAbs.z > qAbs.w) ? 2 : 3)); 
  q.xyz = vec3[4](q.yzw, q.xzw, q.xyw, q.xyz)[maxComponentIndex] * ((q[maxComponentIndex] < 0.0) ? -1.0 : 1.0) * 1.4142135623730951;
  return ((uint(round(clamp(q.x * 511.0, -511.0, 511.0) + 512.0)) & 0x3ffu) << 0u) | 
         ((uint(round(clamp(q.y * 511.0, -511.0, 511.0) + 512.0)) & 0x3ffu) << 10u) | 
         ((uint(round(clamp(q.z * 255.0, -255.0, 255.0) + 256.0)) & 0x1ffu) << 20u) |
         ((uint(((dot(cross(m[0], m[2]), m[1]) * r) < 0.0) ? 1u : 0u) & 0x1u) << 29u) | 
         ((uint(maxComponentIndex) & 0x3u) << 30u);
}

mat3 decodeQTangentUI32(uint v){
  vec4 q = vec4(((vec3(ivec3(uvec3((uvec3(v) >> uvec3(0u, 10u, 20u)) & uvec2(0x3ffu, 0x1ffu).xxy)) - ivec2(512, 256).xxy)) / vec2(511.0, 255.0).xxy) * 0.7071067811865475, 0.0);
  q.w = sqrt(1.0 - clamp(dot(q.xyz, q.xyz), 0.0, 1.0)); 
  q = normalize(vec4[4](q.wxyz, q.xwyz, q.xywz, q.xyzw)[uint((v >> 30u) & 0x3u)]);
  vec3 t2 = q.xyz * 2.0, tx = q.xxx * t2.xyz, ty = q.yyy * t2.xyz, tz = q.www * t2.xyz;
  vec3 tangent = vec3(1.0 - (ty.y + (q.z * t2.z)), tx.y + tz.z, tx.z - tz.y);
  vec3 normal = vec3(tx.z + tz.y, ty.z - tz.x, 1.0 - (tx.x + ty.y));
  return mat3(tangent, cross(tangent, normal) * (((v & (1u << 29u)) != 0u) ? -1.0 : 1.0), normal);
}

// Decodes the UI32 encoded qtangent into a unpacked qtangent for further processing like vertex interpolation and so on
vec4 decodeQTangentUI32Raw(uint v){
  vec4 q = vec4(((vec3(ivec3(uvec3((uvec3(v) >> uvec3(0u, 10u, 20u)) & uvec2(0x3ffu, 0x1ffu).xxy)) - ivec2(512, 256).xxy)) / vec2(511.0, 255.0).xxy) * 0.7071067811865475, 0.0);
  q.w = sqrt(1.0 - clamp(dot(q.xyz, q.xyz), 0.0, 1.0)); 
  return normalize(vec4[4](q.wxyz, q.xwyz, q.xywz, q.xyzw)[uint((v >> 30u) & 0x3u)]) * (((v & (1u << 29u)) != 0u) ? -1.0 : 1.0);
}

// Constructs a TBN matrix from a unpacked qtangent for example for after vertex interpolation in the fragment shader
mat3 constructTBNFromQTangent(vec4 q){
  q = normalize(q); // Ensure that the quaternion is normalized in case it is not, for example after interpolation and so on 
  vec3 t2 = q.xyz * 2.0, tx = q.xxx * t2.xyz, ty = q.yyy * t2.xyz, tz = q.www * t2.xyz;
  vec3 tangent = vec3(1.0 - (ty.y + (q.z * t2.z)), tx.y + tz.z, tx.z - tz.y);
  vec3 normal = vec3(tx.z + tz.y, ty.z - tz.x, 1.0 - (tx.x + ty.y));
  return mat3(tangent, cross(tangent, normal) * ((q.w < 0.0) ? -1.0 : 1.0), normal);
}

// Just 8bit per component of the quaternion and sign of the bitangent is stored in the sign of the quaternion in the w component
uint encodeQTangentRGBA8(mat3 m){
  const float threshold = 1.0 / 127.0; 
  const float renormalization = sqrt(1.0 - (threshold * threshold));
  float r = (determinant(m) < 0.0) ? -1.0 : 1.0; // Reflection matrix handling 
  m[2] *= r;
  float t = m[0][0] + (m[1][1] + m[2][2]);
  vec4 q;
  if(t > 2.9999999){
    q = vec4(0.0, 0.0, 0.0, 1.0);
  }else if(t > 0.0000001){
    float s = sqrt(1.0 + t) * 2.0;
    q = vec4(vec3(m[1][2] - m[2][1], m[2][0] - m[0][2], m[0][1] - m[1][0]) / s, s * 0.25);
  }else if((m[0][0] > m[1][1]) && (m[0][0] > m[2][2])){
    float s = sqrt(1.0 + (m[0][0] - (m[1][1] + m[2][2]))) * 2.0;
    q = vec4(s * 0.25, vec3(m[1][0] + m[0][1], m[2][0] + m[0][2], m[1][2] - m[2][1]) / s);    
  }else if(m[1][1] > m[2][2]){
    float s = sqrt(1.0 + (m[1][1] - (m[0][0] + m[2][2]))) * 2.0;
    q = vec4(vec3(m[1][0] + m[0][1], m[2][1] + m[1][2], m[2][0] - m[0][2]) / s, s * 0.25).xwyz;
  }else{
    float s = sqrt(1.0 + (m[2][2] - (m[0][0] + m[1][1]))) * 2.0;
    q = vec4(vec3(m[2][0] + m[0][2], m[2][1] + m[1][2], m[0][1] - m[1][0]) / s, s * 0.25).xywz; 
  }
  q = normalize(q); 
  q = mix(q, -q, float(q.w < 0.0));
  q = mix(q, vec4(q.xyz * renormalization, threshold), float(q.w < threshold));
  return packSnorm4x8(mix(q, -q, float((dot(cross(m[0], m[2]), m[1]) * r) <= 0.0)));
}

mat3 decodeQTangentRGBA8(uint v){
  vec4 q = normalize(unpackSnorm4x8(v)); 
  vec3 t2 = q.xyz * 2.0, tx = q.xxx * t2.xyz, ty = q.yyy * t2.xyz, tz = q.www * t2.xyz;
  vec3 tangent = vec3(1.0 - (ty.y + (q.z * t2.z)), tx.y + tz.z, tx.z - tz.y);
  vec3 normal = vec3(tx.z + tz.y, ty.z - tz.x, 1.0 - (tx.x + ty.y));
  return mat3(tangent, cross(tangent, normal) * sign(q.w), normal);
} 

#endif