#version 450 core

// This shader should be really the last shader in the pipeline, since it converts the linear sRGB framebuffer to the target color space,
// and it applies optional dithering for reducing banding artifacts for the 8-bit sRGB framebuffer cases, with pseudo blue noise dithering.

// For simplicity, we assume that the framebuffer is always in linear sRGB, either directly from a linear sRGB texture or from a sRGB texture.

// Also, we assume that the output is always in linear sRGB, either SDR or HDR per extended linear sRGB, so that 2D menus, 2D HUDs and so on can be
// still rendered in linear sRGB without extra handling.

// In addition according to https://vulkan.gpuinfo.org/listsurfaceformats.php EXTENDED_SRGB_LINEAR_EXT is even the currently most common supported
// HDR-capable format, so that we can assume just this format for HDR. HDR10_ST2084 and HDR10_HLG could be supported in the future, but currently
// it would be too much additional work for too little benefit outside of the 3D capabilities, since EXTENDED_SRGB_LINEAR_EXT is already supported 
// by the most HDR-capable GPUs.

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable
#extension GL_EXT_control_flow_attributes : enable

layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outFragColor;

layout(input_attachment_index = 0, set = 0, binding = 0) uniform subpassInput uSubpassInput;

//layout(set = 0, binding = 0) uniform sampler2DArray uTexture;

const uint COLOR_SPACE_SRGB_NONLINEAR_SDR = 0u;
const uint COLOR_SPACE_EXTENDED_SRGB_LINEAR = 1u; 

layout(push_constant) uniform PushConstants {
  uint colorSpace;
  uint frameCounter; // frame counter (for animated noise variation)
} pushConstants;

#define FRAGMENT_SHADER

#include "srgb.glsl"

#include "dithering.glsl"

void main(){
  // Input format: 
  //   When using a sRGB texture: 
  //     VK_FORMAT_R8G8B8A8_SRGB or VK_FORMAT_B8G8R8A8_SRGB
  //   When using a linear sRGB texture:
  //     VK_FORMAT_R16G16B16A16_SFLOAT, VK_FORMAT_E5B9G9R9_UFLOAT_PACK32, VK_FORMAT_B10G11R11_UFLOAT_PACK32 or VK_FORMAT_R32G32B32A32_SFLOAT
  // But the input is always linear sRGB, either directly from a linear sRGB texture or from a sRGB texture, since the GPU automatically converts
  // the sRGB texture to linear sRGB through the hardware sampler.
  vec4 color = subpassLoad(uSubpassInput);
//vec4 Color = textureLod(uTexture, vec3(inTexCoord, float(gl_ViewIndex)), 0.0);
  switch(pushConstants.colorSpace){
    case COLOR_SPACE_EXTENDED_SRGB_LINEAR:{
      // Target format: VK_FORMAT_R16G16B16A16_SFLOAT
      // Nothing to do, since the input is already linear sRGB
      break;
    }
    default:{ //case COLOR_SPACE_SRGB_NONLINEAR_SDR:
      // Target format: VK_FORMAT_R8G8B8A8_SRGB or VK_FORMAT_B8G8R8A8_SRGB (depends on the swapchain format)
      color.xyz = clamp(ditherSRGB(clamp(color.xyz, vec3(0.0), vec3(1.0)), ivec2(gl_FragCoord.xy), int(pushConstants.frameCounter)), vec3(0.0), vec3(1.0)); 
      break;                
    }
  }
  outFragColor = color;
}