#version 450 core

//#define SHADERDEBUG

#extension GL_EXT_multiview : enable

#if defined(SHADERDEBUG)
#extension GL_EXT_debug_printf : enable
#endif

layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outColor;

layout(input_attachment_index = 0, set = 0, binding = 0) uniform subpassInput uSubpassInput;

layout (set = 0, binding = 1, std430) buffer HistogramLuminanceBuffer {
  float histogramLuminance;
  float luminanceFactor; 
} histogramLuminanceBuffer;

#if 1
const mat3 RGB2XYZ = mat3(
  0.4124564, 0.2126729, 0.0193339,
  0.3575761, 0.7151522, 0.1191920,
  0.1804375, 0.0721750, 0.9503041
);

const mat3 XYZ2RGB = mat3(
  3.2404542, -0.9692660, 0.0556434,
 -1.5371385, 1.8760108, -0.2040259,
 -0.4985314, 0.0415560, 1.0572252
);
#else
const mat3 RGB2XYZ = mat3(
  0.4124564, 0.3575761, 0.1804375,
  0.2126729, 0.7151522, 0.0721750,
  0.0193339, 0.1191920, 0.9503041
);

const mat3 XYZ2RGB = mat3(
  3.2404542, -1.5371385, -0.4985314,
 -0.9692660, 1.8760108, 0.0415560,
  0.0556434, -0.2040259, 1.0572252
);
#endif

vec3 convertRGB2Yxy(vec3 c){
  vec3 XYZ = RGB2XYZ * c;
  return vec3(XYZ.y, XYZ.xy / dot(XYZ, vec3(1.0)));
}

vec3 convertYxy2RGB(vec3 c){
  return XYZ2RGB * (vec3(c.yx, ((1.0 - c.y) - c.z)) * vec2(c.x / c.z, 1.0).xyx);
}

void main() {
#if 1
  vec4 c = subpassLoad(uSubpassInput);
  c.xyz = max(convertYxy2RGB(convertRGB2Yxy(max(c.xyz, vec3(0.0))) * vec2(histogramLuminanceBuffer.luminanceFactor, 1.0).xyy), vec3(0.0));
  outColor = vec4(max(vec3(0.0), c.xyz), c.w);
#else
  outColor = vec4(1.0);
#endif
}