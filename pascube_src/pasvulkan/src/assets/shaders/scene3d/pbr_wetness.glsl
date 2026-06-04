#ifndef PBR_WETNESS_GLSL
#define PBR_WETNESS_GLSL

float pbrWetnessTextureHash11(uint q){
	uvec2 n = q * uvec2(1597334673U, 3812015801U);
	q = (n.x ^ n.y) * 1597334673U;
  return ((uintBitsToFloat(uint(uint(((q >> 9u) & uint(0x007fffffu)) | uint(0x3f800000u))))) - 1.0);
}

float pbrWetnessTextureHash11(float p){
	uvec2 n = uint(int(p)) * uvec2(1597334673U, 3812015801U);
	uint q = (n.x ^ n.y) * 1597334673U;
  return ((uintBitsToFloat(uint(uint(((q >> 9u) & uint(0x007fffffu)) | uint(0x3f800000u))))) - 1.0);
}

float pbrWetnessTextureHash12(uvec2 q){
	q *= uvec2(1597334673U, 3812015801U);
	uint n = (q.x ^ q.y) * 1597334673U;
  return ((uintBitsToFloat(uint(uint(((n >> 9u) & uint(0x007fffffu)) | uint(0x3f800000u))))) - 1.0);
}

float pbrWetnessTextureHash12(vec2 p){
	uvec2 q = uvec2(ivec2(p)) * uvec2(1597334673U, 3812015801U);
	uint n = (q.x ^ q.y) * 1597334673U;
  return ((uintBitsToFloat(uint(uint(((n >> 9u) & uint(0x007fffffu)) | uint(0x3f800000u))))) - 1.0);
}

vec2 pbrWetnessTextureHash22(uvec2 q){
  q *= uvec2(1597334673U, 3812015801U);
  q = (q.x ^ q.y) * uvec2(1597334673U, 3812015801U);
  return vec2(vec2(uintBitsToFloat(uvec2(uvec2(((q >> 9u) & uvec2(0x007fffffu)) | uvec2(0x3f800000u))))) - vec2(1.0));
}

vec2 pbrWetnessTextureHash22(vec2 p){
  uvec2 q = uvec2(ivec2(p)) * uvec2(1597334673U, 3812015801U);
  q = (q.x ^ q.y) * uvec2(1597334673U, 3812015801U);
  return vec2(vec2(uintBitsToFloat(uvec2(uvec2(((q >> 9u) & uvec2(0x007fffffu)) | uvec2(0x3f800000u))))) - vec2(1.0));
}

float pbrWetnessTextureNoise11(float p){
  float f = fract(p);
  p -= f;
  f = (f * f) * (3.0 - (2.0 * f));
  return mix(pbrWetnessTextureHash11(p + 0.0), pbrWetnessTextureHash11(p + 1.0), f); 
}

float pbrWetnessTextureNoise12(vec2 p){
  vec2 f = fract(p);
  p -= f;
  f = (f * f) * (3.0 - (2.0 * f));
  vec2 n = vec2(0.0, 1.0);
  return mix(mix(pbrWetnessTextureHash12(p + n.xx), pbrWetnessTextureHash12(p + n.yx), f.x),
             mix(pbrWetnessTextureHash12(p + n.xy), pbrWetnessTextureHash12(p + n.yy), f.x), f.y);
}

vec2 pbrWetnessTextureNoise22(vec2 p){
  vec2 f = fract(p);
  p -= f;
  f = (f * f) * (3.0 - (2.0 * f));
  vec2 n = vec2(0.0, 1.0);
  return mix(mix(pbrWetnessTextureHash22(p + n.xx), pbrWetnessTextureHash22(p + n.yx), f.x),
             mix(pbrWetnessTextureHash22(p + n.xy), pbrWetnessTextureHash22(p + n.yy), f.x), f.y);
  
}

vec4 pbrWetnessTextureNoTile(const in sampler2D tex, in vec2 uv, const in vec2 duvdx, const in vec2 duvdy){
#if 1
  return textureGrad(tex, uv, duvdx, duvdy);
#else

  // sample variation pattern   
  float k = clamp(pbrWetnessTextureNoise12(uv), 0.0, 1.0); // low-frequency noise lookup per hash function
    
  // compute index for 8 variation patterns in total  
  float l = k * 8.0;
  float ia = floor(l);
  float f = l - ia;
  float ib = ia + 1.0;
    
  // offsets for the different virtual patterns      
#if 1
  vec2 offa = fma(pbrWetnessTextureNoise22(vec2(13.0, 17.0) * ia), vec2(2.0), vec2(-1.0));
  vec2 offb = fma(pbrWetnessTextureNoise22(vec2(13.0, 17.0) * ib), vec2(2.0), vec2(-1.0));
#else 
  vec2 offa = sin(vec2(3.0, 7.0) * ia); // can replace with any other hash
  vec2 offb = sin(vec2(3.0, 7.0) * ib); // can replace with any other hash 
#endif

  // sample the two closest virtual patterns   
  vec4 cola = textureGrad(tex, uv + offa, duvdx, duvdy);
  vec4 colb = textureGrad(tex, uv + offb, duvdx, duvdy);
    
  // interpolate between the two virtual patterns  
  return mix(cola, colb, smoothstep(0.2, 0.8, f - (0.1 * dot(cola - colb, vec4(1.0)))));
#endif
}

vec4 pbrWetnessTextureNoTile(const in sampler2D tex, in vec2 uv){
  // Calculate the derivatives for texture gradients
  vec2 dpdx = dFdx(uv), dpdy = dFdy(uv);
  
  // Sample the texture without tiling
  return pbrWetnessTextureNoTile(tex, uv, dpdx, dpdy);
}

// Wetness for PBR materials

void applyPBRWetness(
  const in vec4 wetness, // x = wetness factor, yzw = normal from planet ground
  const in vec3 position, // world space position for triplanar mapping
  const in mat3 tangentSpaceBasis, // tangent space basis matrix (tangent, bitangent, normal)
  inout vec3 albedo, // albedo color
  out vec4 normal, // output normal vector for normal mapping, w = weight for normal mapping
  inout float metallic, // metallic value 
  inout float roughness, // roughness value
  inout float occlusion, // occlusion value
  const in sampler2D rainTexture, // texture for rain effect
  const in sampler2D rainNormalTexture, // texture for rain normal mapping
  const in sampler2D rainStreakNormalTexture, // texture for rain normal mapping
  const in float rainTime,
  const in float rainSpeed,
  const in bool extended // whether extended effects should be applied or not, as dynamic objects should not recieve bi-/triplanar mapping effects,                          
){                       // since they are not static in the world, where they would have artefact-like effects, which is not desired

  normal = vec4(0.0, 0.0, 1.0, 0.0); // Initialize output normal

  // Not optimal yet, just the foundation for wetness application in PBR as first version.
  if(wetness.x > 0.0){

    float rain;

    vec3 up = normalize(wetness.yzw);

    float normalDotUp = dot(tangentSpaceBasis[2], up); // Dot product with ground normal to determine wetness effect on normal

    float underRoof = smoothstep(-0.3, 0.0, normalDotUp); // Determine if the object is under a roof based on the normal dot product with the up vector

    if(extended){ // Apply wetness effects only for selected objects, dynamic objects should not recieve bi-/triplanar mapping effects

      // Calculate the scaled position and its derivatives for triplanar mapping
      vec3 scaledPosition = position * 1.0; // Scale position for triplanar mapping
      vec3 dpdx = dFdx(scaledPosition), dpdy = dFdy(scaledPosition); // Calculate derivatives for texture gradients

      // Calculate the tangent space basis from the wetness normal
      // wetness.yzw is the normal from the ground, we need to calculate the tangent and bitangent vectors
      // to create a tangent space basis for triplanar mapping
#if 0 // Not used for now     
      vec3 n = up, t = n.yzx - n.zxy, b = normalize(cross(n, t = normalize(t - dot(t, n))));
      mat3 tbn = mat3x3(t, b, n); 
#endif

  #define USE_PBR_WETNESS_BIPLANAR 1 // Set to 1 to use biplanar mapping, 0 for triplanar mapping    
  #if USE_PBR_WETNESS_BIPLANAR
      vec3 absNormal = abs(up);
      ivec3 majorAxis = ((absNormal.x > absNormal.y) && (absNormal.x > absNormal.z)) ? ivec3(0, 1, 2) : ((absNormal.y > absNormal.z) ? ivec3(1, 2, 0) : ivec3(2, 0, 1));
      ivec3 minorAxis = ((absNormal.x < absNormal.y) && (absNormal.x < absNormal.z)) ? ivec3(0, 1, 2) : ((absNormal.y < absNormal.z) ? ivec3(1, 2, 0) : ivec3(2, 0, 1));
      ivec3 medianAxis = (ivec3(3) - minorAxis) - majorAxis;
      vec2 biplanarWeights = pow(clamp((vec2(absNormal[majorAxis.x], absNormal[medianAxis.x]) - vec2(0.5773)) / vec2(1.0 - 0.5773), vec2(0.0), vec2(1.0)), vec2(8.0 * 0.125));
      float totalWeight = biplanarWeights.x + biplanarWeights.y;
      if(totalWeight > 0.0){
        biplanarWeights /= totalWeight; // Normalize the weights
      } else {
        biplanarWeights = vec2(1.0 / 2.0); // Default weights if total weight is zero
      }
      #define PBR_WETNESS_FETCH_TEXTURE(source, pos) \
        ( \
          (textureGrad(source, vec2(pos[majorAxis.y], pos[majorAxis.z]), vec2(dpdx[majorAxis.y], dpdx[majorAxis.z]), vec2(dpdy[majorAxis.y], dpdy[majorAxis.z])) * biplanarWeights.x) + \
          (textureGrad(source, vec2(pos[medianAxis.y], pos[medianAxis.z]), vec2(dpdx[medianAxis.y], dpdx[medianAxis.z]), vec2(dpdy[medianAxis.y],dpdy[medianAxis.z])) * biplanarWeights.y) \
        ) 
      #define PBR_WETNESS_FETCH_TEXTURE_CHANNEL(source, pos, c) \
        dot( \
          vec2( \
            textureGrad(source, vec2(pos[majorAxis.y], pos[majorAxis.z]), vec2(dpdx[majorAxis.y], dpdx[majorAxis.z]), vec2(dpdy[majorAxis.y], dpdy[majorAxis.z]))[c], \
            textureGrad(source, vec2(pos[medianAxis.y], pos[medianAxis.z]), vec2(dpdx[medianAxis.y], dpdx[medianAxis.z]), vec2(dpdy[medianAxis.y],dpdy[medianAxis.z]))[c] \
          ), \
          biplanarWeights \
        )
  #else
      // Calculate the triplanar weights based on the tangent space basis
      vec3 triplanarWeights = abs(up);
      {
        // pow(triplanarWeights, vec3(8.0) => 3x sq 
        triplanarWeights *= triplanarWeights; 
        triplanarWeights *= triplanarWeights; 
        triplanarWeights *= triplanarWeights; 
      }
      float totalWeight = dot(triplanarWeights, vec3(1.0));
      if(totalWeight > 0.0){
        triplanarWeights /= totalWeight; // Normalize the weights
      } else {
        triplanarWeights = vec3(1.0 / 3.0); // Default weights if total weight is zero
      }
      #define PBR_WETNESS_FETCH_TEXTURE(source, pos) \
        ( \
          (textureGrad(source, pos.yz, dpdx.yz, dpdy.yz).xyz * triplanarWeights.x) + \
          (textureGrad(source, pos.zx, dpdx.zx, dpdy.zx).xyz * triplanarWeights.y) + \
          (textureGrad(source, pos.xy, dpdx.xy, dpdy.xy).xyz * triplanarWeights.z) \
        )
      #define PBR_WETNESS_FETCH_TEXTURE_CHANNEL(source, pos, c) \
        dot( \
          vec3( \
            textureGrad(source, pos.yz, dpdx.yz, dpdy.yz)[c], \
            textureGrad(source, pos.zx, dpdx.zx, dpdy.zx)[c], \
            textureGrad(source, pos.xy, dpdx.xy, dpdy.xy)[c] \
          ), \
          triplanarWeights \
        )
  #endif

      // UV mapping for puddles effect
      vec2 puddlesUV = vec2(
        dot(tangentSpaceBasis[0], position), 
        dot(tangentSpaceBasis[1], position)
      ) * 0.25;

      // Calculate fractional time for puddles effect
      vec2 fracPuddleTimes = fract(vec2(vec2(rainTime * rainSpeed) + vec2(0.0, 0.5))); // Offset for staggered puddles effect

      // Puddles effect based on rain texture
      vec2 puddleValues = vec2( 
        pbrWetnessTextureNoTile(rainTexture, puddlesUV.xy).x,  
        pbrWetnessTextureNoTile(rainTexture, puddlesUV.yx).x) - (vec2(1.0) - fracPuddleTimes); 
      puddleValues =
        clamp(
          (vec2(1.0) - vec2(
              distance(vec2(puddleValues.x), vec2(0.1)) / 0.1, 
              distance(vec2(puddleValues.y), vec2(0.1)) / 0.1
            )
          ) * abs(sin(fracPuddleTimes * 3.14159)), vec2(0.0), vec2(1.0));
      vec4 puddles = vec4(
          mix(
            vec3(0.0, 0.0, 1.0),
            fma(pbrWetnessTextureNoTile(rainNormalTexture, puddlesUV).xyz, vec3(2.0), vec3(-1.0)),
            max(puddleValues.x, puddleValues.y)
          ),
          max(puddleValues.x, puddleValues.y)
        ) * 
        smoothstep(0.8, 1.0, normalDotUp) * // Puddles only on top 
        wetness.x; // Apply wetness factor to puddles, no rain, no puddles 

      // Calculate the rain streaks effect
      float streaks = PBR_WETNESS_FETCH_TEXTURE_CHANNEL(rainTexture, scaledPosition, 1) * // Get rain streaks from the texture
                      smoothstep(0.97, 0.9, normalDotUp) *  // Streaks not on top, only on sides 
                      wetness.x; // Apply wetness factor to streaks, no rain, no streaks
      vec3 offsetedPosition = scaledPosition + (up * (rainTime * rainSpeed * 0.2));
      streaks = smoothstep(
        0.0,
        0.1,
        streaks * 
        clamp(
          PBR_WETNESS_FETCH_TEXTURE_CHANNEL(rainTexture, offsetedPosition, 2) - 0.5, // Adjust the threshold for rain streaks   
          0.0,
          1.0
        )
      ) *
      underRoof; // When normal is facing downwards, no rain flow

      // Calculate the final normal vector based on puddles and streaks
      vec3 rainNormal = 
        mix(
          mix(
            vec3(0.0, 0.0, 1.0), // Default normal
            puddles.xyz,
            puddles.w // Apply puddles effect
          ),
          fma(PBR_WETNESS_FETCH_TEXTURE(rainStreakNormalTexture, scaledPosition).xyz, vec3(2.0), vec3(-1.0)), // Normal from rain texture
          streaks // Apply streaks effect
        );           
      normal = vec4(rainNormal, 1.0); // Set the normal vector for normal mapping

      // Calculate the rain factor
      rain = clamp(puddles.w + streaks, 0.0, 1.0); // Get the maximum effect of puddles and streaks
      
      #undef PBR_WETNESS_FETCH_TEXTURE      
      #undef PBR_WETNESS_FETCH_TEXTURE_CHANNEL

    }else{

      // For other objects, we do not apply rain effects, since they are not static in the world
      // This is to avoid artefact-like effects, which is not desired
      
      rain = 0.0;

    }
    
    // Calculate the wetness factor
    float wet = 1.0 - (clamp(wetness.x, 0.0, 1.0) * 0.66); 

    // Calculate the color based on wetness and metallic factor
    albedo.xyz = mix( 
      albedo.xyz, // Dry albedo color
      mix(albedo.xyz * wet, albedo.xyz, metallic), // Wet albedo color, darken the albedo color based on wetness, if not metallic, keep the original color
      underRoof // If not under roof, apply wetness effect
    );

    // Apply wetness to metallic and roughness
    metallic = mix(metallic, 0.0, rain); // Decrease metallic based on rain and wetness
    roughness = mix(roughness * wet, 0.0, rain); // Apply wetness to roughness based on rain effect

#if 0
    albedo.xyz = vec3(rainNormal.xyz);
    metallic = 0.0;
    roughness = 1.0;
    occlusion = 1.0;
#endif

  }

} 

#endif