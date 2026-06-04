#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outFragColor;

layout(push_constant) uniform PushConstants {
  uint viewBaseIndex;
  float focalLength;
  float focalPlaneDistance; 
  float fNumber;
  float sensorSizeY;
  uint mode; // 0 = off, 1 = on (manual-focus), 2 = on (auto-focus)  
} pushConstants;

struct View {
  mat4 viewMatrix;
  mat4 projectionMatrix;
  mat4 inverseViewMatrix;
  mat4 inverseProjectionMatrix;
};

layout(input_attachment_index = 0, set = 0, binding = 0) uniform subpassInput uSubpassColor;

layout(set = 0, binding = 1) uniform sampler2DArray uTextureDepth;

layout(std140, set = 0, binding = 2) uniform uboViews {
  View views[256];
} uView;

layout(std430, set = 0, binding = 3) readonly buffer AutoFocusDepth {
  float autoFocusDepth;
};

mat4 inverseProjectionMatrix = uView.views[pushConstants.viewBaseIndex + uint(gl_ViewIndex)].inverseProjectionMatrix;

float linearizeDepth(float z) {
#if 0
  vec2 v = (inverseProjectionMatrix * vec4(vec3(fma(inTexCoord, vec2(2.0), vec2(-1.0)), z), 1.0)).zw;
#else
  vec2 v = fma(inverseProjectionMatrix[2].zw, vec2(z), inverseProjectionMatrix[3].zw);
#endif
  return -(v.x / v.y);
}

void main(){
  
  vec4 color = subpassLoad(uSubpassColor);
  color.xyz = clamp(color.xyz, vec3(0.0), vec3(65504.0));
  
  float rawDepth = texelFetch(uTextureDepth, ivec3(gl_FragCoord.xy, gl_ViewIndex), 0).x;
  
  float depth = clamp(linearizeDepth(rawDepth), 0.0, 4096.0);

#if 0
  {
    float luminance = dot(color.xyz, vec3(0.299, 0.587, 0.114));
    float luminanceThreshold = 0.5;
    if(luminance > luminanceThreshold){
      float f = max(0.0, pow((luminance - luminanceThreshold) / (1.0 - luminanceThreshold), 2.0));
      color.xyz *= isinf(depth) ? 1.0 : max(0.0, (1.0 - f) + (f * 2.0)); 
    }
  }
#endif
  
  if(pushConstants.mode == 0u){
    
    // DoF is off
    
    outFragColor = vec4(color.xyz, 0.0);

  }else{  

    // DoF is on

    // f = Focal length (where light starts getting in focus)
    // d0 = Focus distance (aka as plane in focus or camera focal distance) 
    // z = Distance from the lens to the object
    // D = Aperture diameter  
    //
    // original formula source: http://research.tri-ace.com/Data/S2015/05_ImplementationBokeh-S2015.pptx
    //
    //             d0 * f      z * f       D * ( z - f ) 
    // CoC(z) = ( ======== - ======== ) * ===============
    //             d0 - f      z - f            z * f
    //
    // but which can be simplified to:
    //
    //           D * f * ( z - d0 ) 
    // CoC(z) = ====================
    //             z * ( d0 - f ) 
    //
    float z = depth * 1000.0, // distance in mm
          d0 = (pushConstants.mode == 2u) ? (autoFocusDepth * 1000.0) : pushConstants.focalPlaneDistance, // focal plane in mm 
          f = pushConstants.focalLength, // focal length in mm
          D = f / pushConstants.fNumber, // Aperture diameter in mm
#if 1         
          CoC = ((D * f) * (z - d0)) / (z * (d0 - f));
#else
          CoC = (((d0 * f) / (d0 - f)) - ((z * f) / (z - f))) * (D * ((z - f) / (z * f)));
#endif
    
    outFragColor = vec4(color.xyz, clamp(CoC / pushConstants.sensorSizeY, -1.0, 1.0));

  }

}
