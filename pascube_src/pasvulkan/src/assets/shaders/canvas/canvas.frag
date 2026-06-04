#version 450 core

// Copyright (C) 2017, Benjamin 'BeRo' Rosseaux (benjamin@rosseaux.de)
// License: zlib 

// The PasVulkan canvas is designed for frame buffers and textures, which contains values in linear color space and not
// in the sRGB color space, for correct linear space blending, so keep it in mind, while you are reading this code.

// and therefore, you should use sRGB framebuffer and texture Vulkan TVkFormat formats, if you are using sRGB textures, 
// and sRGB displays, because the GPU itself does the sRGB=>linear (at texel fetches) and linear=>sRGB (at pixel writes)
// conversions then.  

#define FILLTYPE_NO_TEXTURE 0
#define FILLTYPE_TEXTURE 1
#define FILLTYPE_ATLAS_TEXTURE 2
#define FILLTYPE_VECTOR_PATH 3

#ifndef FILLTYPE
  #define FILLTYPE FILLTYPE_NO_TEXTURE
#endif

#define SIGNEDDISTANCEDFIELD

layout(early_fragment_tests) in;

layout(location = 0) in vec2 inOriginalPosition; // 2D position
layout(location = 1) in vec2 inPosition; // 2D position
layout(location = 2) in vec4 inColor;    // RGBA Color (in linear space, NOT in sRGB non-linear color space!)
#if (FILLTYPE == FILLTYPE_TEXTURE) || (FILLTYPE == FILLTYPE_ATLAS_TEXTURE) || (FILLTYPE == FILLTYPE_VECTOR_PATH) || defined(GUI_ELEMENTS) 
layout(location = 3) in vec3 inTexCoord; // 2D texture coordinate with array texture layer index inside the z component
#endif
layout(location = 4) flat in ivec4 inState; // x = Rendering mode, y = object type, z = not used yet, w = not used yet
layout(location = 5) in vec4 inMetaInfo; // Various stuff
layout(location = 6) in vec4 inMetaInfo2; // Various stuff
layout(location = 7) in vec2 inClipSpacePosition;  // xy
#if !USECLIPDISTANCE
layout(location = 8) in vec4 inClipRect; // xy = Left Top, zw = Right Bottom
#endif

#if FILLTYPE == FILLTYPE_ATLAS_TEXTURE 
layout(set = 0, binding = 0) uniform sampler2DArray uTexture;
#elif FILLTYPE == FILLTYPE_TEXTURE
layout(set = 0, binding = 0) uniform sampler2D uTexture;
#endif

#define MASKING 1

#if MASKING
layout(set = 0, binding = 1) uniform sampler2D uTextureMask;
#endif

#if FILLTYPE == FILLTYPE_VECTOR_PATH

struct VectorPathGPUSegment {
  uvec4 typeWindingPoint0;
  vec4 point1Point2;
};

#define VectorPathGPUIndirectSegment uint

#define VectorPathGPUGridCell uvec2

struct VectorPathGPUShape {
  vec4 minMax;
  uvec4 flagsStartGridCellIndexGridSize;
};

layout(std430, set = 1, binding = 0) buffer VectorPathGPUSegments {
  VectorPathGPUSegment vectorPathGPUSegments[];
};

layout(std430, set = 1, binding = 1) buffer VectorPathGPUIndirectSegments {
  VectorPathGPUIndirectSegment vectorPathGPUIndirectSegments[];
};

layout(std430, set = 1, binding = 2) buffer VectorPathGPUGridCells {
  VectorPathGPUGridCell vectorPathGPUGridCells[];
};

layout(std430, set = 1, binding = 3) buffer VectorPathGPUShapes {
  VectorPathGPUShape vectorPathGPUShapes[];
};

#endif

layout(location = 0) out vec4 outFragColor;

layout(push_constant) uniform PushConstants {
  layout(offset = 0) uvec4 data[8];
} pushConstants;

#if 0
void main(){
  outFragColor = vec4(1.0);
}
#else
// Some facts about a sRGB non-linear frame-buffer from the Vulkan specification:
//   If the numeric format of a framebuffer attachment uses sRGB encoding, the R, G, and B destination color values 
//   (after conversion from fixed-point to floating-point) are considered to be encoded for the sRGB color space and 
//   hence are linearized prior to their use in blending. Each R, G, and B component is converted from nonlinear to 
//   linear as described in the "KHR_DF_TRANSFER_SRGB" section of the Khronos Data Format Specification. If the format 
//   is not sRGB, no linearization is performed.
//   If the numeric format of a framebuffer attachment uses sRGB encoding, then the final R, G and B values are converted 
//   into the nonlinear sRGB representation before being written to the framebuffer attachment as described in the 
//   "KHR_DF_TRANSFER_SRGB" section of the Khronos Data Format Specification.
//   If the framebuffer color attachment numeric format is not sRGB encoded then the resulting cscs values for R, G and B 
//   are unmodified. The value of A is never sRGB encoded. That is, the alpha component is always stored in memory as linear.
// and:
//   If the image format is sRGB, the color components are first converted as if they are UNORM, and then sRGB to linear 
//   conversion is applied to the R, G, and B components as described in the "KHR_DF_TRANSFER_SRGB" section of the Khronos
//   Data Format Specification. The A component, if present, is unchanged.

// Define our own linearstep function for to map distance coverage, when we doing our calculations in the linear color space. 
// Smoothstep's nonlinear response is actually doing some fake-gamma, so it ends up over-correcting when the output is already gamma-correct.
#define TEMPLATE_LINEARSTEP(DATATYPE) \
  DATATYPE linearstep(DATATYPE edge0, DATATYPE edge1, DATATYPE value){ \
    return clamp((value - edge0) / (edge1 - edge0), DATATYPE(0.0), DATATYPE(1.0)); \
  }
TEMPLATE_LINEARSTEP(float)  
TEMPLATE_LINEARSTEP(vec2)  
TEMPLATE_LINEARSTEP(vec3)  
TEMPLATE_LINEARSTEP(vec4)  

vec4 blend(vec4 a, vec4 b){
  return mix(a, b, b.a); 
}           

#ifdef GUI_ELEMENTS

#define GUI_ELEMENT_WINDOW_HEADER 1
#define GUI_ELEMENT_WINDOW_FILL 2
#define GUI_ELEMENT_WINDOW_DROPSHADOW 3
#define GUI_ELEMENT_BUTTON_UNFOCUSED 4
#define GUI_ELEMENT_BUTTON_FOCUSED 5
#define GUI_ELEMENT_BUTTON_PUSHED 6
#define GUI_ELEMENT_BUTTON_DISABLED 7
#define GUI_ELEMENT_FOCUSED 8
#define GUI_ELEMENT_HOVERED 9
#define GUI_ELEMENT_BOX_UNFOCUSED 10
#define GUI_ELEMENT_BOX_FOCUSED 11
#define GUI_ELEMENT_BOX_DISABLED 12  
#define GUI_ELEMENT_BOX_DARK_UNFOCUSED 13
#define GUI_ELEMENT_BOX_DARK_FOCUSED 14
#define GUI_ELEMENT_BOX_DARK_DISABLED 15  
#define GUI_ELEMENT_PANEL_ENABLED 16
#define GUI_ELEMENT_PANEL_DISABLED 17
#define GUI_ELEMENT_TAB_BUTTON_UNFOCUSED 18
#define GUI_ELEMENT_TAB_BUTTON_FOCUSED 19
#define GUI_ELEMENT_TAB_BUTTON_PUSHED 20
#define GUI_ELEMENT_TAB_BUTTON_DISABLED 21
#define GUI_ELEMENT_COLOR_WHEEL_UNFOCUSED 22
#define GUI_ELEMENT_COLOR_WHEEL_FOCUSED 23
#define GUI_ELEMENT_COLOR_WHEEL_DISABLED 24
#define GUI_ELEMENT_MOUSE_CURSOR_ARROW 64
#define GUI_ELEMENT_MOUSE_CURSOR_BEAM 65
#define GUI_ELEMENT_MOUSE_CURSOR_BUSY 66
#define GUI_ELEMENT_MOUSE_CURSOR_CROSS 67
#define GUI_ELEMENT_MOUSE_CURSOR_EW 68
#define GUI_ELEMENT_MOUSE_CURSOR_HELP 69
#define GUI_ELEMENT_MOUSE_CURSOR_LINK 70
#define GUI_ELEMENT_MOUSE_CURSOR_MOVE 71
#define GUI_ELEMENT_MOUSE_CURSOR_NESW 72
#define GUI_ELEMENT_MOUSE_CURSOR_NS 73
#define GUI_ELEMENT_MOUSE_CURSOR_NWSE 74
#define GUI_ELEMENT_MOUSE_CURSOR_PEN 75
#define GUI_ELEMENT_MOUSE_CURSOR_UNAVAILABLE 76
#define GUI_ELEMENT_MOUSE_CURSOR_UP 77     
#define GUI_ELEMENT_HIDDEN 96

const float uWindowCornerRadius = 2.0;
const float uWindowHeaderHeight = 32.0;
const float uWindowHeaderCornerRadius = 2.0;
const float uWindowDropShadowSize = 10.0;
const float uButtonCornerRadius = 2.0;
const float uTabBorderWidth = 0.75;
const float uTabInnerMargin = 5.0;
const float uTabMinButtonWidth = 20.0;
const float uTabMaxButtonWidth = 160.0;
const float uTabControlWidth = 20.0;
const float uTabButtonHorizontalPadding = 10.0;
const float uTabButtonVerticalPadding = 2.0; 

#define MAKE_GRAY_COLOR(a, b) vec4(vec3(pow((a) / 255.0, 2.2)), (b) / 255.0)

#define MAKE_COLOR(r, g, b, a) vec4(vec3(pow(vec3(r, g, b) / 255.0, vec3(2.2))), (a) / 255.0)

const vec4 uDropShadow = MAKE_GRAY_COLOR(0.0, 128.0);
const vec4 uTransparent = MAKE_GRAY_COLOR(0.0, 0.0);
const vec4 uBorderDark = MAKE_GRAY_COLOR(29.0, 255.0);
const vec4 uBorderLight = MAKE_GRAY_COLOR(92.0, 255.0);
const vec4 uBorderMedium = MAKE_GRAY_COLOR(35.0, 255.0);
const vec4 uTextColor = MAKE_GRAY_COLOR(255.0, 160.0);
const vec4 uDisabledTextColor = MAKE_GRAY_COLOR(255.0, 80.0);
const vec4 uTextColorShadow = MAKE_GRAY_COLOR(0.0, 160.0);
const vec4 uIconColor = MAKE_GRAY_COLOR(255.0, 160.0);

const vec4 uUnfocusedButtonGradientTop = MAKE_GRAY_COLOR(74.0, 255.0);
const vec4 uUnfocusedButtonGradientBottom = MAKE_GRAY_COLOR(58.0, 255.0);
const vec4 uFocusedButtonGradientTop = MAKE_GRAY_COLOR(64.0, 255.0);
const vec4 uFocusedButtonGradientBottom = MAKE_GRAY_COLOR(48.0, 255.0);
const vec4 uPushedButtonGradientTop = MAKE_GRAY_COLOR(29.0, 255.0);
const vec4 uPushedButtonGradientBottom = MAKE_GRAY_COLOR(41.0, 255.0);
const vec4 uDisabledButtonGradientTop = MAKE_GRAY_COLOR(96.0, 255.0);
const vec4 uDisabledButtonGradientBottom = MAKE_GRAY_COLOR(74.0, 255.0);

const vec4 uUnfocusedBoxGradientTop = MAKE_GRAY_COLOR(74.0, 255.0);
const vec4 uUnfocusedBoxGradientBottom = MAKE_GRAY_COLOR(70.0, 255.0);
const vec4 uFocusedBoxGradientTop = MAKE_GRAY_COLOR(64.0, 255.0);
const vec4 uFocusedBoxGradientBottom = MAKE_GRAY_COLOR(68.0, 255.0);
const vec4 uDisabledBoxGradientTop = MAKE_GRAY_COLOR(94.0, 255.0);
const vec4 uDisabledBoxGradientBottom = MAKE_GRAY_COLOR(98.0, 255.0);   
const vec4 uUnfocusedBoxDarkGradientTop = MAKE_GRAY_COLOR(42.0, 255.0);
const vec4 uUnfocusedBoxDarkGradientBottom = MAKE_GRAY_COLOR(40.0, 255.0);
const vec4 uFocusedBoxDarkGradientTop = MAKE_GRAY_COLOR(38.0, 255.0);
const vec4 uFocusedBoxDarkGradientBottom = MAKE_GRAY_COLOR(32.0, 255.0);
const vec4 uDisabledBoxDarkGradientTop = MAKE_GRAY_COLOR(94.0, 255.0);
const vec4 uDisabledBoxDarkGradientBottom = MAKE_GRAY_COLOR(98.0, 255.0);

const vec4 uEnabledPanelGradientTop = MAKE_GRAY_COLOR(58.0, 255.0);
const vec4 uEnabledPanelGradientBottom = MAKE_GRAY_COLOR(54.0, 255.0);
const vec4 uDisabledPanelGradientTop = MAKE_GRAY_COLOR(96.0, 255.0);
const vec4 uDisabledPanelGradientBottom = MAKE_GRAY_COLOR(74.0, 255.0);

const vec4 uFocused = MAKE_COLOR(255.0, 192.0, 64.0, 255.0);

const vec4 uHovered = MAKE_COLOR(64.0, 192.0, 255.0, 255.0);

const vec4 uUnfocusedWindowFill = MAKE_GRAY_COLOR(43.0, 255.0);
const vec4 uFocusedWindowFill = MAKE_GRAY_COLOR(45.0, 255.0);

const vec4 uUnfocusedWindowFillBorder = MAKE_GRAY_COLOR(21.5, 255.0);
const vec4 uFocusedWindowFillBorder = MAKE_GRAY_COLOR(22.5, 255.0);

const vec4 uUnfocusedWindowTitle = MAKE_GRAY_COLOR(220.0, 160.0);
const vec4 uFocusedWindowTitle = MAKE_GRAY_COLOR(255.0, 190.0);

const vec4 uUnfocusedWindowHeaderGradientTop = MAKE_GRAY_COLOR(64.0, 255.0);
const vec4 uUnfocusedWindowHeaderGradientBottom = MAKE_GRAY_COLOR(48.0, 255.0);

const vec4 uFocusedWindowHeaderGradientTop = MAKE_GRAY_COLOR(74.0, 255.0);
const vec4 uFocusedWindowHeaderGradientBottom = MAKE_GRAY_COLOR(58.0, 255.0);

const vec4 uUnfocusedWindowHeaderBorderGradientTop = MAKE_GRAY_COLOR(54.0, 255.0);
const vec4 uUnfocusedWindowHeaderBorderGradientBottom = MAKE_GRAY_COLOR(38.0, 255.0);

const vec4 uFocusedWindowHeaderBorderGradientTop = MAKE_GRAY_COLOR(64.0, 255.0);
const vec4 uFocusedWindowHeaderBorderGradientBottom = MAKE_GRAY_COLOR(48.0, 255.0);

const vec4 uUnfocusedWindowHeaderSeperatorTop = MAKE_GRAY_COLOR(92.0, 255.0);
const vec4 uUnfocusedWindowHeaderSeperatorBottom = MAKE_GRAY_COLOR(29.0, 255.0);

const vec4 uFocusedWindowHeaderSeperatorTop = MAKE_GRAY_COLOR(92.0, 255.0);
const vec4 uFocusedWindowHeaderSeperatorBottom = MAKE_GRAY_COLOR(29.0, 255.0);

const vec4 uUnfocusedWindowDropShadow = MAKE_GRAY_COLOR(0.0, 128.0);
const vec4 uFocusedWindowDropShadow = MAKE_GRAY_COLOR(0.0, 128.0);

const float uUnfocusedWindowDropShadowSize = 16.0;
const float uFocusedWindowDropShadowSize = 16.0;

const vec4 uWindowPopup = MAKE_GRAY_COLOR(50.0, 255.0);
const vec4 uWindowPopupTransparent = MAKE_GRAY_COLOR(50.0, 0.0); 

#endif
                                  
const float SQRT_0_DOT_5 = sqrt(0.5);

#ifdef SIGNEDDISTANCEDFIELD
float sdEllipse(vec2 p, in vec2 ab){
  float d;
  if(ab.x == ab.y){
    d = length(p) - ab.x;
  }else{  
    // iq's ellipse distance function in a reformatted form
    p = abs(p); 
    if(p.x > p.y){
      p = p.yx; 
      ab = ab.yx; 
    }	
    float l = (ab.y * ab.y) - (ab.x * ab.x), m = (ab.x * p.x) / l, n = (ab.y * p.y) / l, m2 = m * m, n2 = n * n, 
          c = ((m2 + n2) - 1.0) / 3.0, c3 = c * c  * c, q = c3 + ((m2 * n2) * 2.0), d = c3 + (m2 * n2), g = m + (m * n2),
          co;
    if(d < 0.0){
      float p = acos(q / c3) / 3.0, s = cos(p), t = sin(p) * sqrt(3.0), rx = sqrt((-(c*(s + t + 2.0))) + m2), ry = sqrt((-(c * ((s - t) + 2.0))) + m2);
      co = (((ry + (sign(l) * rx)) + (abs(g) / (rx * ry))) - m) * 0.5;
    }else{
      float h = 2.0 * m * n * sqrt(d), s = sign(q + h) * pow(abs(q + h), 1.0/3.0), u = sign(q - h) * pow(abs(q-h), 1.0 / 3.0), 
            rx = (((-s) - u) - (c * 4.0)) + (2.0 * m2), ry = (s - u) * sqrt(3.0), rm = length(vec2(rx, ry)), p = ry / sqrt(rm - rx);
      co = ((p + ((2.0*g) / rm)) - m) * 0.5;
    }
    vec2 r = vec2(ab.x * co, ab.y * sqrt(1.0 - co*co));
    d = length(r - p) * sign(p.y - r.y);
  }
  return d;
}

float sdOrientedBox(const in vec2 p, const in vec2 a, const in vec2 b, const in float th){
   float l = length(b-a);
   vec2 d = (b - a) / l;
   vec2 q = p - ((a + b) * 0.5);
   q = mat2(d.x,-d.y, d.y, d.x) * q;
   q = abs(q) - (vec2(l, th) * 0.5);
   return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);    
 }
                                                  
float sdCircleArcRingSegment(vec2 p, float innerRadius, float outerRadius, float startAngle, float endAngle, float gapThickness){
  vec2 op = p;
  const vec4 s = sin(
    vec4(0.0, 1.57079632679, 3.14159265359, 4.71238898038) +
    vec2(
     mix(startAngle, endAngle, 0.5), 
     abs(endAngle - startAngle) * -0.5
    ).xxyy
  );
  p = mat2(-s.x, -s.y, s.y, -s.x) * p;
  p.x = abs(p.x);
  float l = length(p);
  p = mat2(-s.w, s.z, s.z, s.w) * p;
  p = vec2(
    ((p.y > 0.0) || (p.x > 0.0)) ? p.x : (l * sign(-s.w)),
    (p.x > 0.0) ? p.y : l 
  );
  p = vec2(p.x, abs(p.y - mix(innerRadius, outerRadius, 0.5)) - (abs(outerRadius - innerRadius) * 0.5));
  float d = length(max(p, 0.0)) + min(0.0, max(p.x, p.y));
  if(gapThickness > 1e-6){
    const vec4 startEndSinCos = sin(vec2(startAngle, endAngle).xxyy + vec2(0.0, 1.57079632679).xyxy); 
    d = max(d, -sdOrientedBox(op, vec2(0.0), vec2(startEndSinCos.yx) * (outerRadius * 2.0), gapThickness)); 
    d = max(d, -sdOrientedBox(op, vec2(0.0), vec2(startEndSinCos.wz) * (outerRadius * 2.0), gapThickness)); 
  }
  return d;
}      
#endif

#ifdef GUI_ELEMENTS
float sdRoundedRect(vec2 p, vec2 b, float r){
  b -= vec2(r);
  vec2 d = abs(p) - b;
  return min(max(d.x, d.y), 0.0) + length(max(abs(p) - b, 0.0)) - r;
}

float sdTabButton(vec2 p, vec2 b, float r){
  // Chrome-style tab button with about 26.565051 angle slope tab shape
#if 1
  // with corner roundness 
  return sdRoundedRect(p, b - vec2((b.y - p.y) * 0.5, 0.0), r);
#else
  const vec2 n = vec2(-0.894427190999914, 0.447213595499961); // vec2(sin(vec2(1.570796326794895, 0.0) + radians(180.0 - 26.565051177078010077161700198))); 
#if 1
  // with corner roundness 
  return sdRoundedRect(p, b - vec2((p.y - b.y) * (n.y / n.x), 0.0), r);
#else
  // without corner roundness 
  return max(abs(p.y) - b.y, -(dot(vec2(abs(p.x) - b.x, p.y - b.y), n)));  
#endif
#endif
}

float sdTriangle(in vec2 p0, in vec2 p1, in vec2 p2, in vec2 p){  
  vec2 e0 = p1 - p0, e1 = p2 - p1, e2 = p0 - p2,
       v0 = p - p0, v1 = p - p1, v2 = p - p2,
       pq0 = v0 - (e0 * clamp(dot(v0, e0) / dot(e0, e0), 0.0, 1.0)),
       pq1 = v1 - (e1 * clamp(dot(v1, e1) / dot(e1, e1), 0.0, 1.0)),
       pq2 = v2 - (e2 * clamp(dot(v2, e2) / dot(e2, e2), 0.0, 1.0)),
       d = min(min(vec2(dot(pq0, pq0), (v0.x * e0.y) - (v0.y * e0.x)),  
                   vec2(dot(pq1, pq1), (v1.x * e1.y) - (v1.y * e1.x))),  
                   vec2(dot(pq2, pq2), (v2.x * e2.y) - (v2.y * e2.x)));  
  return -sqrt(d.x) * sign(d.y);  
}  

vec3 barycentricTriangle(in vec2 p0, in vec2 p1, in vec2 p2, in vec2 p){
  vec2 v0 = p1 - p0, v1 = p2 - p0, v2 = p - p0;
  float d00 = dot(v0, v0), d01 = dot(v0, v1), d11 = dot(v1, v1), d20 = dot(v2, v0),
        d21 = dot(v2, v1), d = (d00 * d11) - (d01 * d01);
  vec2 vw = vec2((d11 * d20) - (d01 * d21), (d00 * d21) - (d01 * d20)) / d;
  return vec3(1.0 - (vw.x + vw.y), vw);
}
                      
vec2 rotate(vec2 v, float a){
  vec2 s = sin(vec2(a) + vec2(0.0, 1.57079633));
  return mat2(s.y, -s.x, s.x, s.y) * v;
}                               

vec3 rgb2hsv(vec3 c){
  vec4 k = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0),
       p = mix(vec4(c.bg, k.wz), vec4(c.gb, k.xy), step(c.b, c.g)),
       q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
  float d = q.x - min(q.w, q.y),
        e = 1.0e-10;
  return clamp(vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x), vec3(0.0), vec3(1.0));
}

vec3 hsv2rgb(vec3 c){
    vec4 k = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs((fract(c.xxx + k.xyz) * 6.0) - k.www);
    return clamp(c.z * mix(k.xxx, clamp(p - k.xxx, 0.0, 1.0), c.y), vec3(0.0), vec3(1.0));
}

vec3 convertLinearRGBToSRGB(vec3 c){
  return mix((pow(c, vec3(1.0 / 2.4)) * vec3(1.055)) - vec3(5.5e-2), 
             c * vec3(12.92),     
             lessThan(c, vec3(3.1308e-3)));
}

vec3 convertSRGBToLinearRGB(vec3 c){
  return mix(pow((c + vec3(5.5e-2)) / vec3(1.055), vec3(2.4)),
             c / vec3(12.92),
             lessThan(c, vec3(4.045e-2)));
}

vec3 colorWheelConditionalConvertSRGBToLinearRGB(vec3 c){
  return mix(c,
             mix(pow((c + vec3(5.5e-2)) / vec3(1.055), vec3(2.4)),
                 c / vec3(12.92),
                 lessThan(c, vec3(4.045e-2))),
            step(0.5, inTexCoord.z));
}

#endif

#if (FILLTYPE == FILLTYPE_ATLAS_TEXTURE) || (FILLTYPE == FILLTYPE_VECTOR_PATH)
  #define ADJUST_TEXCOORD(uv) vec3(uv, texCoord.z)
  #define TVEC vec3
#else
  #define ADJUST_TEXCOORD(uv) uv
  #define TVEC vec2
#endif

#if ((FILLTYPE == FILLTYPE_TEXTURE) || (FILLTYPE == FILLTYPE_ATLAS_TEXTURE))

// In the best case effectively 5x (4+1) multisampled mono-SDF, otherwise just 1x in the worst case, depending on the texCoord gradient derivatives 
float multiSampleSDF(const in TVEC texCoord){
  const float HALF_BY_SQRT_TWO = 0.5 / sqrt(2.0), ONE_BY_THREE = 1.0 / 3.0, PI = 3.14159, ONE_OVER_PI = 1.0 / 3.14159;     
  float center = textureLod(uTexture, texCoord, 0.0).w;
#ifdef SIMPLE_SIGNED_DISTANCE_FIELD_WIDTH_CALCULATION
  vec2 width = vec2(0.5) + (vec2(-SQRT_0_DOT_5, SQRT_0_DOT_5) * length(vec2(dFdx(center), dFdy(center))));
#else
  // Based on: https://www.essentialmath.com/blog/?p=151 but with Adreno issue compensation, which likes to drop tiles on division by zero
  const float NORMALIZATION_THICKNESS_SCALE = SQRT_0_DOT_5 * (0.5 / 4.0); 
  vec2 centerGradient = vec2(dFdx(center), dFdy(center));
  float centerGradientSquaredLength = dot(centerGradient, centerGradient);
  if(centerGradientSquaredLength < 1e-4){
    centerGradient = vec2(SQRT_0_DOT_5); 
  }else{
    centerGradient *= inversesqrt(centerGradientSquaredLength); 
  }
  vec2 Juv = texCoord.xy * textureSize(uTexture, 0).xy,       
        Jdx = dFdx(Juv), 
        Jdy = dFdy(Juv),
        jacobianGradient = vec2((centerGradient.x * Jdx.x) + (centerGradient.y * Jdy.x), 
                                (centerGradient.x * Jdx.y) + (centerGradient.y * Jdy.y));
  vec2 width = vec2(0.5) + (vec2(-1.0, 1.0) * min(length(jacobianGradient) * NORMALIZATION_THICKNESS_SCALE, 0.5));
#endif
  vec4 buv = texCoord.xyxy + (vec2((dFdx(texCoord.xy) + dFdy(texCoord.xy)) * HALF_BY_SQRT_TWO).xyxy * vec2(-1.0, 1.0).xxyy);
  return  clamp((linearstep(width.x, width.y, center) + 
          dot(linearstep(width.xxxx, 
                         width.yyyy,
                         vec4(textureLod(uTexture, ADJUST_TEXCOORD(buv.xy), 0.0).w,
                              textureLod(uTexture, ADJUST_TEXCOORD(buv.zw), 0.0).w,
                              textureLod(uTexture, ADJUST_TEXCOORD(buv.xw), 0.0).w,
                              textureLod(uTexture, ADJUST_TEXCOORD(buv.zy), 0.0).w)), vec4(0.5))) * ONE_BY_THREE, 0.0, 1.0);
}

// 4x multisampled 4-rook/RGSS SDF with a single texture lookup of four SDF values in the RGBA color channels 
float sampleSSAASDF(const in TVEC texCoord){
  const float HALF_BY_SQRT_TWO = 0.5 / sqrt(2.0), 
              ONE_BY_THREE = 1.0 / 3.0, 
              NORMALIZATION_THICKNESS_SCALE = SQRT_0_DOT_5 * (0.5 / 4.0);     
  vec4 texel = textureLod(uTexture, texCoord, 0.0);
  vec4 gradientX = dFdx(texel);
  vec4 gradientY = dFdy(texel);
  vec2 gradients[4] = vec2[4](
    vec2(gradientX.x, gradientY.x),
    vec2(gradientX.y, gradientY.y),
    vec2(gradientX.z, gradientY.z),
    vec2(gradientX.w, gradientY.w)
  );
  vec4 gradientSquaredLengths = vec4(dot(gradients[0], gradients[0]), 
                                     dot(gradients[1], gradients[1]), 
                                     dot(gradients[2], gradients[2]), 
                                     dot(gradients[3], gradients[3]));
  gradients[0] = (gradientSquaredLengths[0] < 1e-4) ? vec2(SQRT_0_DOT_5) : (gradients[0] * inversesqrt(max(gradientSquaredLengths[0], 1e-4)));
  gradients[1] = (gradientSquaredLengths[1] < 1e-4) ? vec2(SQRT_0_DOT_5) : (gradients[1] * inversesqrt(max(gradientSquaredLengths[1], 1e-4)));
  gradients[2] = (gradientSquaredLengths[2] < 1e-4) ? vec2(SQRT_0_DOT_5) : (gradients[2] * inversesqrt(max(gradientSquaredLengths[2], 1e-4)));
  gradients[3] = (gradientSquaredLengths[3] < 1e-4) ? vec2(SQRT_0_DOT_5) : (gradients[3] * inversesqrt(max(gradientSquaredLengths[3], 1e-4)));
  vec2 texTexelCoord = texCoord.xy * textureSize(uTexture, 0).xy;
  vec2 Juv[4] = vec2[4](
    vec2(texTexelCoord + vec2(0.125, 0.375)),
    vec2(texTexelCoord + vec2(-0.125, -0.375)),
    vec2(texTexelCoord + vec2(0.375, -0.125)),
    vec2(texTexelCoord + vec2(-0.375, 0.125))
  );
  vec4 Jdxdy[4] = vec4[4](
    vec4(dFdx(Juv[0]), dFdy(Juv[0])),
    vec4(dFdx(Juv[1]), dFdy(Juv[1])),
    vec4(dFdx(Juv[2]), dFdy(Juv[2])),
    vec4(dFdx(Juv[3]), dFdy(Juv[3]))
  );
  vec2 jacobianGradients[4] = vec2[4](
#if 0
    vec2(mat2(gradients[0], gradients[0]) * mat2(Jdxdy[0].xy, Jdxdy[0].zw)),
    vec2(mat2(gradients[1], gradients[1]) * mat2(Jdxdy[1].xy, Jdxdy[1].zw)),
    vec2(mat2(gradients[2], gradients[2]) * mat2(Jdxdy[2].xy, Jdxdy[2].zw)),
    vec2(mat2(gradients[3], gradients[3]) * mat2(Jdxdy[3].xy, Jdxdy[3].zw))
#else
    vec2((gradients[0].x * Jdxdy[0].x) + (gradients[0].y * Jdxdy[0].z), (gradients[0].x * Jdxdy[0].y) + (gradients[0].y * Jdxdy[0].w)),
    vec2((gradients[1].x * Jdxdy[1].x) + (gradients[1].y * Jdxdy[1].z), (gradients[1].x * Jdxdy[1].y) + (gradients[1].y * Jdxdy[1].w)),
    vec2((gradients[2].x * Jdxdy[2].x) + (gradients[2].y * Jdxdy[2].z), (gradients[2].x * Jdxdy[2].y) + (gradients[2].y * Jdxdy[2].w)),
    vec2((gradients[3].x * Jdxdy[3].x) + (gradients[3].y * Jdxdy[3].z), (gradients[3].x * Jdxdy[3].y) + (gradients[3].y * Jdxdy[3].w))
#endif
  );
  vec4 widths = min(vec4(length(jacobianGradients[0]), 
                         length(jacobianGradients[1]), 
                         length(jacobianGradients[2]), 
                         length(jacobianGradients[3])) * NORMALIZATION_THICKNESS_SCALE, vec4(0.5));
  return dot(linearstep(vec4(0.5) - widths, vec4(0.5) + widths, texel), vec4(0.25)); 
}

// In the best case effectively 16x multisampled SDF, otherwise just 4x in the worst case, depending on the texCoord gradient derivatives 
float multiSampleSSAASDF(const in TVEC texCoord){
  const float HALF_BY_SQRT_TWO = 0.5 / sqrt(2.0);
  vec4 buv = texCoord.xyxy + (vec2((dFdx(texCoord.xy) + dFdy(texCoord.xy)) * HALF_BY_SQRT_TWO).xyxy * vec2(-1.0, 1.0).xxyy);
  return dot(vec4(sampleSSAASDF(ADJUST_TEXCOORD(buv.xy)), sampleSSAASDF(ADJUST_TEXCOORD(buv.zy)), sampleSSAASDF(ADJUST_TEXCOORD(buv.xw)), sampleSSAASDF(ADJUST_TEXCOORD(buv.zw))), vec4(0.25));
}

// In the best case effectively 16x multisampled gradient SDF, otherwise just 4x in the worst case, depending on the texCoord gradient derivatives 
float multiSampleGSDF(const in TVEC texCoord){
  const float HALF_BY_SQRT_TWO = 0.5 / sqrt(2.0), ONE_BY_THREE = 1.0 / 3.0, PI = 3.14159, ONE_OVER_PI = 1.0 / 3.14159;     
  vec4 centerTexel = textureLod(uTexture, texCoord, 0.0) - vec2(0.0, 0.5).xyyx;
  float center = centerTexel.w;
#ifdef SIMPLE_SIGNED_DISTANCE_FIELD_WIDTH_CALCULATION
  vec2 width = vec2(0.5) + (vec2(-SQRT_0_DOT_5, SQRT_0_DOT_5) * length(vec2(dFdx(center), dFdy(center))));
#else
  // Based on: https://www.essentialmath.com/blog/?p=151 but with Adreno issue compensation, which likes to drop tiles on division by zero
  const float NORMALIZATION_THICKNESS_SCALE = SQRT_0_DOT_5 * (0.5 / 4.0); 
  vec2 centerGradient = vec2(dFdx(center), dFdy(center));
  float centerGradientSquaredLength = dot(centerGradient, centerGradient);
  if(centerGradientSquaredLength < 1e-4){
    centerGradient = vec2(SQRT_0_DOT_5); 
  }else{
    centerGradient *= inversesqrt(centerGradientSquaredLength); 
  }
  vec2 Juv = texCoord.xy * textureSize(uTexture, 0).xy,       
        Jdx = dFdx(Juv), 
        Jdy = dFdy(Juv),
        jacobianGradient = vec2((centerGradient.x * Jdx.x) + (centerGradient.y * Jdy.x), 
                                (centerGradient.x * Jdx.y) + (centerGradient.y * Jdy.y));
  vec2 width = vec2(0.5) + (vec2(-1.0, 1.0) * min(length(jacobianGradient) * NORMALIZATION_THICKNESS_SCALE, 0.5));
#endif
  vec4 buv = texCoord.xyxy + (vec2((dFdx(texCoord.xy) + dFdy(texCoord.xy)) * HALF_BY_SQRT_TWO).xyxy * vec2(-1.0, 1.0).xxyy);
  vec4 t00 = textureLod(uTexture, ADJUST_TEXCOORD(buv.xy), 0.0) - vec2(0.0, 0.5).xyyx;
  vec4 t01 = textureLod(uTexture, ADJUST_TEXCOORD(buv.zy), 0.0) - vec2(0.0, 0.5).xyyx;
  vec4 t10 = textureLod(uTexture, ADJUST_TEXCOORD(buv.xw), 0.0) - vec2(0.0, 0.5).xyyx;
  vec4 t11 = textureLod(uTexture, ADJUST_TEXCOORD(buv.zw), 0.0) - vec2(0.0, 0.5).xyyx;
  return clamp(((linearstep(width.x, width.y, center) * (1.0 - abs(atan(centerTexel.z, centerTexel.y) * ONE_OVER_PI))) + 
                dot(vec4(linearstep(width.xxxx, width.yyyy, vec4(t00.x, t01.x, t10.x, t11.x)) * 
                        vec4(vec4(1.0) - abs(vec4(atan(t00.z, t00.y), atan(t01.z, t01.y), atan(t10.z, t10.y), atan(t11.z, t11.y)) * ONE_OVER_PI))), 
                  vec4(0.5))) * ONE_BY_THREE, 0.0, 1.0);
}

float sampleMSDF(const in TVEC texCoord){
  vec4 centerTexel = textureLod(uTexture, texCoord, 0.0);
  float center = max(min(centerTexel.x, centerTexel.y), min(max(centerTexel.x, centerTexel.y), centerTexel.z)); // median
#ifdef SIMPLE_SIGNED_DISTANCE_FIELD_WIDTH_CALCULATION
  vec2 width = vec2(0.5) + (vec2(-SQRT_0_DOT_5, SQRT_0_DOT_5) * length(vec2(dFdx(center), dFdy(center))));
#else
  // Based on: https://www.essentialmath.com/blog/?p=151 but with Adreno issue compensation, which likes to drop tiles on division by zero
  const float NORMALIZATION_THICKNESS_SCALE = SQRT_0_DOT_5 * (0.5 / 4.0); 
  vec2 centerGradient = vec2(dFdx(center), dFdy(center));
  float centerGradientSquaredLength = dot(centerGradient, centerGradient);
  if(centerGradientSquaredLength < 1e-4){
    centerGradient = vec2(SQRT_0_DOT_5); 
  }else{
    centerGradient *= inversesqrt(centerGradientSquaredLength); 
  }
  vec2 Juv = texCoord.xy * textureSize(uTexture, 0).xy,       
       Jdx = dFdx(Juv), 
       Jdy = dFdy(Juv),
       jacobianGradient = vec2((centerGradient.x * Jdx.x) + (centerGradient.y * Jdy.x), 
                               (centerGradient.x * Jdx.y) + (centerGradient.y * Jdy.y));
  vec2 width = vec2(0.5) + (vec2(-1.0, 1.0) * min(length(jacobianGradient) * NORMALIZATION_THICKNESS_SCALE, 0.5));
#endif
  return linearstep(width.x, width.y, center); 
}

// In the best case effectively 4x multisampled gradient SDF, otherwise just 1x in the worst case, depending on the texCoord gradient derivatives 
float multiSampleMSDF(const in TVEC texCoord){
  const float HALF_BY_SQRT_TWO = 0.5 / sqrt(2.0);
  vec4 buv = texCoord.xyxy + (vec2((dFdx(texCoord.xy) + dFdy(texCoord.xy)) * HALF_BY_SQRT_TWO).xyxy * vec2(-1.0, 1.0).xxyy);
  return dot(vec4(sampleMSDF(ADJUST_TEXCOORD(buv.xy)), sampleMSDF(ADJUST_TEXCOORD(buv.zy)), sampleMSDF(ADJUST_TEXCOORD(buv.xw)), sampleMSDF(ADJUST_TEXCOORD(buv.zw))), vec4(0.25));
}

#endif

#if FILLTYPE == FILLTYPE_VECTOR_PATH

bool lineHorziontalLineIntersect(vec2 p0, vec2 p1, float y0, float y1) {
  if(p0.x == p1.x ){  // Line is vertical
    return y0 <= max(p0.y, p1.y) && y1 >= min(p0.y, p1.y);   
  }else if (p0.y == p1.y) {  // line is not vertical and lines are parallel
    return false;
  }else{ // Line is not vertical
    // Calculate intersection point
    float x = (((y1 - y0) * (p1.x - p0.x)) / (p1.y - p0.y)) + p0.x;
    return (x >= min(p0.x, p1.x)) &&  (x <= max(p0.x, p1.x)) && (y0 <= max(p0.y, p1.y)) && (y1 >= min(p0.y, p1.y));
  }
}

float getLineDistanceAndUpdateWinding(in vec2 pos, in vec2 A, in vec2 B, inout int winding) {   

  vec2 lineSegment = B - A;

  // The following code calculates the winding number of a point (pos) relative to a
  // line segment formed by two points A and B. It does so by simulating a horizontal line 
  // at the y-coordinate of the point (pos) and checking whether this line intersects the 
  // line segment. If the intersection occurs within the limits of the line segment, it
  // increments or decrements the winding number by 1, depending on the orientation of
  // the line segment. The winding number can be used to determine whether the point is 
  // inside or outside a polygon. If the line intersects the polygon an even number of times,
  // the winding number is 0, indicating that the point is outside the polygon. If the line 
  // intersects the polygon an odd number of times, the winding number is either 1 (if the 
  // polygon is oriented counter-clockwise) or -1 (if the polygon is oriented clockwise).  
  if(abs(lineSegment.y) > 1e-8){
    float t = -(A.y - pos.y) / lineSegment.y;
    winding += ((t >= 0.0) && (t <= 1.0) && (mix(A.x, B.x, t) <= pos.x)) ?
                 ((B.y < A.y) ? -1 : 1) :
                 0;
  }   

  // Distance
  vec2 pSubA = pos - A;
  float squaredLineLength = dot(lineSegment, lineSegment);
  vec2 nearestPoint = mix(A, B, clamp(dot(pSubA, lineSegment) / squaredLineLength, 0.0, 1.0));
  vec2 nearestVector = nearestPoint - pos; 
  return length(nearestVector); 

}

float getQuadraticCurveDistanceAndUpdateWinding(in vec2 pos, in vec2 A, in vec2 B, in vec2 C, inout int winding){
  
  // This following code calculates the winding number of a quadratic bezier curve at 
  // a given point. The winding number is a measure of how many times a curve wraps 
  // around a given point, and it is used in the implementation of the even-odd or 
  // non-zero rule for determining whether a point is inside or outside of a path. 
  // It does so by simulating a horizontal line at the y-coordinate of the point (pos) 
  // and checking whether this horizontal line intersects the quadratic curve. 
  // The code first calculates the coefficients of a quadratic equation in the form 
  // "at^2 + bt + c = y", where "y" is the y-coordinate of the given point, and "t" is a 
  // value that varies between 0 and 1. The coefficients are then used to solve the equation 
  // using the quadratic formula, which gives the values of "t" at which the curve intersects
  // the given y-coordinate. These values of "t" are then used to calculate the x-coordinates
  // of the intersections, and the winding number is incremented or decremented by 1,
  // depending on the orientation of the quadratic curve by evaluating the quadratic curve 
  // tangents for the x-axis coordinates.
  // Overall, the code is well-written and easy to understand. It effectively uses the quadratic 
  // formula to find the intersections of the curve with a given y-coordinate, and then checks with
  // help of quadratic tangents at time "t" on which side of the given point these intersections are 
  // to determine the winding number.
  { 
    float a = (A.y - (2.0 * B.y)) + C.y;
    float b = (-2.0 * A.y) + (2.0 * B.y);
    float d = (b * b) - (4.0 * a * (A.y - pos.y));
    if (d > 0.0) {
      vec2 t = (vec2(-b) + (vec2(-1.0, 1.0) * sqrt(d))) / (2.0 * a);
      vec2 h = mix(mix(A.xx, B.xx, t), mix(B.xx, C.xx, t), t);  
      winding += (((t.x >= 0.0) && (t.x <= 1.0)) && (h.x <= pos.x)) ?
                   (((mix(B.y, C.y, t.x) - mix(A.y, B.y, t.x)) < 0.0) ? -1 : 1) : 
                   0;
      winding += (((t.y >= 0.0) && (t.y <= 1.0)) && (h.y <= pos.x)) ? 
                   (((mix(B.y, C.y, t.y) - mix(A.y, B.y, t.y)) < 0.0) ? -1 : 1) : 
                   0;
    }          
  } 

  // Distance
  vec2 a = B - A;
  vec2 b = A - 2.0 * B + C;
  vec2 c = a * 2.0;
  vec2 d = A - pos;

  float kk = 1.0 / dot(b, b);
  float kx = kk * dot(a, b);
  float ky = kk * (2.0 * dot(a, a) + dot(d, b)) / 3.0;
  float kz = kk * dot(d, a);

  float result = 0.0;
  
  float p  = ky - kx * kx;
  float q  = kx * (2.0 * kx * kx - 3.0 * ky) + kz;
  float p3 = p * p * p;
  float q2 = q * q;
  float h  = q2 + 4.0 * p3;

  if(h >= 0.0) { // 1 root
    h = sqrt(h);
    vec2 x = (vec2(h, -h) - q) / 2.0;

    // When p≈0 and p<0, h - q has catastrophic cancelation. So, we do
    // h=√(q² + 4p³)=q·√(1 + 4p³/q²)=q·√(1 + w) instead. Now we approximate
    // √ by a linear Taylor expansion into h≈q(1 + ½w) so that the q's
    // cancel each other in h - q. Expanding and simplifying further we
    // get x=vec2(p³/q, -p³/q - q). And using a second degree Taylor
    // expansion instead: x=vec2(k, -k - q) with k=(1 - p³/q²)·p³/q
    if(abs(abs(h/q) - 1.0) < 0.0001) {
      float k = (1.0 - p3 / q2) * p3 / q;  // quadratic approx
      x = vec2(k, -k - q);
    }

    vec2 uv = sign(x) * pow(abs(x), vec2(1.0/3.0));
    float t = clamp(uv.x + uv.y - kx, 0.0, 1.0);
    return length(d + (c + b * t) * t);
  } else { // 3 roots
    float z = sqrt(-p);
    float v = acos(q / (p * z * 2.0)) / 3.0;
    float m = cos(v);
    float n = sin(v) * 1.732050808;
    vec3 t = clamp(vec3(m + m, -n - m, n - m) * z - kx, 0.0, 1.0);
    vec2 qx = d + (c + b * t.x) * t.x;
    vec2 qy = d + (c + b * t.y) * t.y;
    return sqrt(min(dot(qx, qx), dot(qy, qy)));    
  }

} 

// This code is a function to calculate a pixel value by using a signed distance field for a path described by a series of lines,
// quadratic curves, and winding setting meta lines. The signed distance field can be used to determine whether a given point is
// inside or outside of the path, and if it is inside, by how much. The input to the function is a 3D shapeCoord vector, where the
// x and y components describe a point in 2D space and the z component is an integer index into an array of vectorPathGPUShapes. 
// The function returns a single float value representing the signed distance of the point described by shapeCoord from the path.
//
// The function starts by initializing a variable called signedDistance to a very large value, then it retrieves the 
// vectorPathGPUShape at the index specified by the z component of shapeCoord. It calculates the dimensions of a grid in which 
// the path is divided and the indices of the grid cell that shapeCoord falls into. To avoid numerical accuracy problems regarding 
// grid cell boundaries, these grid cells are actually always a bit larger where the border is slightly outward. If shapeCoord falls 
// within the grid, the function retrieves the corresponding vectorPathGPUGridCell and iterates through a series of vectorPathGPUSegments
// contained within the grid cell, updating the signedDistance and winding values as it goes. The signedDistance value is updated by 
// calling one of two functions depending on the type of segment: getLineDistanceAndUpdateWinding for line segments and 
// getQuadraticCurveDistanceAndUpdateWinding for quadratic curve segments.
// 
// The winding value is an integer that keeps track of the number of times the path crosses the horizontal line that shapeCoord 
// lies on. The winding value is used to determine whether the point is inside or outside of the path based on the fill rule 
// specified by the flagsStartGridCellIndexGridSize.x field of the vectorPathGPUShape. If the fill rule is the even-odd rule, the 
// point is considered inside if the winding value is odd, and outside if it is even. If the fill rule is the non-zero rule, the 
// point is considered inside if the winding value is non-zero, and outside if it is zero. The final signedDistance value is then 
// multiplied by -1 if the point is inside the path according to the fill rule and 1 if it is outside. Finally, the function 
// returns the result of a linear step function applied to the signedDistance value, which smooths out the transition between 
// inside and outside values.
// 
// In this context, a "winding setting meta line" is a special type of line segment that is used to set the winding value for a 
// particular simulated virtual scanline. The winding value is an integer that keeps track of the number of times the path 
// crosses the horizontal line that a given point lies on. The winding value is used to determine whether the point is inside 
// or outside of the path based on the fill rule specified by the flagsStartGridCellIndexGridSize.x field of the 
// vectorPathGPUShape. If the fill rule is the even-odd rule, the point is considered inside if the winding value is odd, and 
// outside if it is even. If the fill rule is the non-zero rule, the point is considered inside if the winding value is 
// non-zero, and outside if it is zero.
// 
// The purpose of the winding setting meta line is to ensure that the winding value is correctly initialized for a particular 
// simulated virtual scanline. This is important because the winding value can change as the simulated virtual scanline moves 
// across the path in a grid cell, and it is necessary to know the initial winding value in order to correctly determine whether 
// a point on the simulated virtual scanline is inside or outside the path. The winding setting meta line works by adding a fixed 
// value to the winding value whenever the scanline passes through it. This allows the code to accurately track the winding value 
// as the simulated virtual scanline moves across the path in a grid cell, even in a random access manner.
float sampleVectorPathShape(const vec3 shapeCoord){
  float signedDistance = 1e+32; 
  VectorPathGPUShape vectorPathGPUShape = vectorPathGPUShapes[int(shapeCoord.z + 0.5)];
  uvec2 gridCellDims = uvec2(vectorPathGPUShape.flagsStartGridCellIndexGridSize.zw);
  uvec2 gridCellIndices = uvec2(ivec2(floor(vec2(((shapeCoord.xy - vectorPathGPUShape.minMax.xy) * vec2(ivec2(gridCellDims))) / vectorPathGPUShape.minMax.zw))));
  if(all(greaterThanEqual(gridCellIndices, uvec2(0))) && all(lessThan(gridCellIndices, uvec2(gridCellDims)))){
    VectorPathGPUGridCell vectorPathGPUGridCell = vectorPathGPUGridCells[vectorPathGPUShape.flagsStartGridCellIndexGridSize.y + ((gridCellIndices.y * gridCellDims.x) + gridCellIndices.x)];
    uint countIndirectSegments = vectorPathGPUGridCell.y;
    if(countIndirectSegments > 0u){
      int winding = 0;
      for(uint indirectSegmentIndex = vectorPathGPUGridCell.x, untilIndirectSegmentIndex = vectorPathGPUGridCell.x + (countIndirectSegments - 1u);
          indirectSegmentIndex < untilIndirectSegmentIndex; 
          indirectSegmentIndex++){
        VectorPathGPUSegment vectorPathGPUSegment = vectorPathGPUSegments[vectorPathGPUIndirectSegments[indirectSegmentIndex]];
        switch(vectorPathGPUSegment.typeWindingPoint0.x){
          case 0u:{
            // Unknown 
            break;
          }
          case 1u:{
            // Line
            signedDistance = min(signedDistance, getLineDistanceAndUpdateWinding(shapeCoord.xy, uintBitsToFloat(vectorPathGPUSegment.typeWindingPoint0.zw), vectorPathGPUSegment.point1Point2.xy, winding));
            break;
          }
          case 2u:{
            // Quadratic curve
            signedDistance = min(signedDistance, getQuadraticCurveDistanceAndUpdateWinding(shapeCoord.xy, uintBitsToFloat(vectorPathGPUSegment.typeWindingPoint0.zw), vectorPathGPUSegment.point1Point2.xy, vectorPathGPUSegment.point1Point2.zw, winding));
            break;
          }
          case 3u:{
            // Meta winding setting line (winding only)
            vec2 p0 = uintBitsToFloat(vectorPathGPUSegment.typeWindingPoint0.zw);
            vec2 p1 = vectorPathGPUSegment.point1Point2.xy;
            if((shapeCoord.y >= min(p0.y, p1.y)) && (shapeCoord.y < max(p0.y, p1.y))){
              winding += int(vectorPathGPUSegment.typeWindingPoint0.y);              
            }
            break;
          }
          default:{
            break;
          }
        }                         
      }
      signedDistance *= (((vectorPathGPUShape.flagsStartGridCellIndexGridSize.x & 1) != 0) ?
                         ((winding & 1) != 0) /* even odd rule */ : 
                         (winding != 0) /* non-zero rule */
                        ) ? -1.0 : 1.0;      
    }       
  }
  float d = fwidth(signedDistance);
  return linearstep(-d, d, signedDistance);
}
#endif

void main(void){
  vec4 color;
#ifndef GUI_ELEMENTS
#if (FILLTYPE == FILLTYPE_NO_TEXTURE) || (FILLTYPE == FILLTYPE_TEXTURE)
  const mat4 fillMatrix = mat4(
    uintBitsToFloat(uvec4(pushConstants.data[2].yzw, 0u)),
    uintBitsToFloat(uvec4(pushConstants.data[3].xyz, 0u)),
    uintBitsToFloat(uvec4(pushConstants.data[3].w, pushConstants.data[4].xyz)),
    uintBitsToFloat(uvec4(pushConstants.data[4].w, pushConstants.data[5].xyz))
  );
  const mat3x2 fillTransformMatrix = mat3x2(
    fillMatrix[0].xy, 
    fillMatrix[1].xy, 
    vec2(fillMatrix[0].z, fillMatrix[1].z)
  );
#endif
#if !((FILLTYPE == FILLTYPE_TEXTURE) || (FILLTYPE == FILLTYPE_ATLAS_TEXTURE) || (FILLTYPE == FILLTYPE_VECTOR_PATH))
  color = inColor;
#else 
#if (FILLTYPE == FILLTYPE_ATLAS_TEXTURE) || (FILLTYPE == FILLTYPE_VECTOR_PATH)
  #define texCoord inTexCoord
#else
  vec2 texCoord = ((inState.z & 0x03) == 0x01) ? (fillTransformMatrix * vec3(inPosition, 1.0)).xy : inTexCoord.xy;
#endif
#if FILLTYPE == FILLTYPE_VECTOR_PATH
  color = vec2(1.0, sampleVectorPathShape(texCoord)).xxxy * inColor;  
#else
  switch(inState.x){ 
    case 1:{
      switch(inState.w & 0xf){ 
        case 0:{
          // Mono SDF
          color = vec2(1.0, multiSampleSDF(texCoord)).xxxy;
          break;
        }
        case 1:{
          // Supersampling Antialiased SDF
          color = vec2(1.0, multiSampleSSAASDF(texCoord)).xxxy;
          break;
        }
        case 2:{
          // Gradient SDF
          color = vec2(1.0, multiSampleGSDF(texCoord)).xxxy;
          break;
        }
        case 3:{
          // Multi Channel SDF
          color = vec2(1.0, multiSampleMSDF(texCoord)).xxxy;
          break;
        }
        default:{
          color = vec4(0.0);
          break;
        }
      }      
      break;
    }
    default:{
      color = texture(uTexture, texCoord);
      break;
    }
  }
  color *= inColor; 
#endif
#endif
#if FILLTYPE == FILLTYPE_NO_TEXTURE
  if((inState.z & 0x03) >= 0x02){
    vec2 gradientPosition = (fillTransformMatrix * vec3(inPosition, 1.0)).xy;      
    float gradientTime = 0.0;
    switch(inState.z & 0x03){
      case 0x02:{
        // Linear gradient
        gradientTime = gradientPosition.x;
        break;
      }
      case 0x03:{
        // Radial gradient
        gradientTime = length(gradientPosition);
        break;
      }
    }
    switch((inState.z >> 2) & 0x03){
      case 0x01:{
        // Repeat
        gradientTime = fract(gradientTime);
        break;
      }
      case 0x02:{
        // Mirrored repeat
        gradientTime = 1.0 - abs(mod(gradientTime, 2.0) - 1.0);
        break;
      }
    }
    color *= mix(fillMatrix[2], fillMatrix[3], clamp(gradientTime, 0.0, 1.0));
  }
#endif
#ifdef SIGNEDDISTANCEDFIELD
  if(inState.y != 0){
    float threshold = length(abs(dFdx(inOriginalPosition.xy)) + abs(dFdy(inOriginalPosition.xy))) * SQRT_0_DOT_5;
    switch(inState.y){
      case 0x01:{
        // Distance to line edge
        color.a *= min(linearstep(0.0, -threshold, -(inMetaInfo.z - abs(inMetaInfo.x))),  // To the line edges left and right
                       linearstep(0.0, -threshold, -(inMetaInfo.w - abs(inMetaInfo.y)))); // To the line ends
        break;      
      }
      case 0x02:{
        // Distance to line round cap circle       
        color.a *= linearstep(0.0, -threshold, length(inOriginalPosition.xy - inMetaInfo.xy) - inMetaInfo.z);
        break;      
      }
      case 0x03:{
        // Distance to round line (polygon edge) 
        vec2 pa = inOriginalPosition.xy - inMetaInfo.xy, ba = inMetaInfo.zw - inMetaInfo.xy;
        color.a *= linearstep(0.0, -threshold, length(pa - (ba * (clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0)))) - threshold);
        break;      
      }
      case 0x04:{
        // Distance to circle       
        color.a *= linearstep(0.0, -threshold, length(inOriginalPosition.xy - inMetaInfo.xy) - inMetaInfo.z);
        break;      
      }
      case 0x05:{
        // Distance to ellipse
        color.a *= linearstep(0.0, -threshold, sdEllipse(inOriginalPosition.xy - inMetaInfo.xy, inMetaInfo.zw));
        break;      
      }
      case 0x06:{
        // Distance to rectangle
        vec2 d = abs(inOriginalPosition.xy - inMetaInfo.xy) - inMetaInfo.zw;
        color.a *= linearstep(0.0, -threshold, min(max(d.x, d.y), 0.0) + length(max(d, 0.0)));
        break;      
      }
      case 0x07:{
        // Distance to rounded rectangle
        vec2 d = abs(inOriginalPosition.xy - inMetaInfo.xy) - inMetaInfo.zw;
        color.a *= linearstep(0.0, -threshold, (min(max(d.x, d.y), 0.0) + length(max(d, 0.0))) - inMetaInfo2.x);
        break;      
      }
      case 0x08:{
        // Distance to circle arc ring segment
        float d = sdCircleArcRingSegment(
          inOriginalPosition.xy - inMetaInfo.xy, // p
          inMetaInfo.z, // innerRadius 
          inMetaInfo.w, // outerRadius
          inMetaInfo2.x, // startAngle
          inMetaInfo2.y, // endAngle
          inMetaInfo2.z  // gapThickness
        );
        color.a *= linearstep(0.0, -threshold, d);        
        break;      
      } 
    }
  }
#endif
#endif
#ifdef GUI_ELEMENTS
  {    
    color = vec4(0.0);
    int guiElementIndex = inState.y;
    vec2 pa = inMetaInfo.xy, pb = inMetaInfo.zw, size = pb - pa;
    vec2 p = inOriginalPosition.xy - pa;
    float t = length(abs(dFdx(inOriginalPosition.xy)) + abs(dFdy(inOriginalPosition.xy))) * SQRT_0_DOT_5;   
    float focused = ((guiElementIndex & 0x80) != 0) ? 1.0 : 0.0;
    guiElementIndex &= 0x7f;
    switch(guiElementIndex){
      case GUI_ELEMENT_WINDOW_HEADER:{      
        float fy = linearstep(0.0, size.y, p.y),
              cr = mix(uWindowHeaderCornerRadius, 0.0, step(size.y * 0.5, p.y)), 
              d0 = sdRoundedRect(p - (size * 0.5), size * 0.5, cr),
              d1 = sdRoundedRect(p - (size * 0.5), (size * 0.5) - vec2(1.0), cr);      
        color = blend(color, 
                      mix(mix(mix(mix(mix(uUnfocusedWindowHeaderGradientTop, 
                                          uFocusedWindowHeaderGradientTop, 
                                          focused),
                                      mix(uUnfocusedWindowHeaderGradientBottom, 
                                          uFocusedWindowHeaderGradientBottom, 
                                          focused),
                                      fy),
                                mix(mix(uUnfocusedWindowHeaderBorderGradientTop, 
                                        uFocusedWindowHeaderBorderGradientTop, 
                                         focused),
                                    mix(uUnfocusedWindowHeaderBorderGradientBottom, 
                                        uFocusedWindowHeaderBorderGradientBottom, 
                                        focused),
                                        fy),
                                linearstep(-t, t, d1)),
                              uUnfocusedWindowHeaderSeperatorTop, linearstep(1.0 + t, 0.0, p.y)),
                          uUnfocusedWindowHeaderSeperatorBottom, linearstep(size.y - (1.0 + t), size.y, p.y)) *
                      vec2(1.0, linearstep(t, -t, d0)).xxxy);                      
        if(inMetaInfo2.x < 0.5){
          color.w = 1.0; // Opaque
        }                    
        break;
      }
      case GUI_ELEMENT_WINDOW_FILL:{
        float cr = uWindowCornerRadius, 
              d0 = sdRoundedRect(p - (size * 0.5), size * 0.5, cr),
              d1 = sdRoundedRect(p - (size * 0.5), (size * 0.5) - vec2(1.0), cr);      
        color = blend(color, 
                      mix(mix(uUnfocusedWindowFill, 
                              uFocusedWindowFill, 
                               focused),
                          mix(uUnfocusedWindowFillBorder, 
                              uFocusedWindowFillBorder, 
                              focused),
                          linearstep(-t, t, d1)) *
                      vec2(1.0, linearstep(t, -t, d0)).xxxy);                      
        if(inMetaInfo2.x < 0.5){
          color.w = 1.0; // Opaque
        }                    
        break;
      }
      case GUI_ELEMENT_WINDOW_DROPSHADOW:{
        float d = sdRoundedRect(p - (size * 0.5), 
                                size * 0.5, 
                                mix(uWindowHeaderCornerRadius, uWindowCornerRadius, step(size.y * 0.5, p.y)));      
        color = blend(color,
                      mix(uUnfocusedWindowDropShadow, 
                          uFocusedWindowDropShadow, 
                          focused) * 
                      vec2(1.0, linearstep(mix(uUnfocusedWindowDropShadowSize, 
                                               uFocusedWindowDropShadowSize, 
                                               focused), 
                                           0.0, 
                                           d) * 
                                           linearstep(-t * 2.0, 0.0, d)).xxxy);
        break;
      }
      case GUI_ELEMENT_BUTTON_UNFOCUSED:
      case GUI_ELEMENT_BUTTON_FOCUSED:
      case GUI_ELEMENT_BUTTON_PUSHED:
      case GUI_ELEMENT_BUTTON_DISABLED:{
        float d0 = sdRoundedRect(p - (size * 0.5), size * 0.5, uButtonCornerRadius),
              d1 = sdRoundedRect(p - (size * 0.5), (size * 0.5) - vec2(1.0), uButtonCornerRadius),      
              d2 = sdRoundedRect(p - (size * 0.5), (size * 0.5) - vec2(2.0), uButtonCornerRadius),      
              d3 = sdRoundedRect(p - (size * 0.5), (size * 0.5) - vec2(3.0), uButtonCornerRadius);      
        vec4 gradientTop,
             gradientBottom,
             borderTowardsLight,
             borderAwayFromLight;
        switch(guiElementIndex){
          case GUI_ELEMENT_BUTTON_UNFOCUSED:{
            gradientTop = uUnfocusedButtonGradientTop;
            gradientBottom = uUnfocusedButtonGradientBottom;
            borderTowardsLight = uBorderLight;
            borderAwayFromLight = uBorderDark;
            break;
          }
          case GUI_ELEMENT_BUTTON_FOCUSED:{
            gradientTop = uFocusedButtonGradientTop;
            gradientBottom = uFocusedButtonGradientBottom;
            borderTowardsLight = uBorderLight;
            borderAwayFromLight = uBorderDark;
            break;
          }
          case GUI_ELEMENT_BUTTON_PUSHED:{
            gradientTop = uPushedButtonGradientTop;
            gradientBottom = uPushedButtonGradientBottom;
            borderTowardsLight = uBorderDark;
            borderAwayFromLight = uBorderLight;
            break;
          }
          case GUI_ELEMENT_BUTTON_DISABLED:{
            gradientTop = uDisabledButtonGradientTop;
            gradientBottom = uDisabledButtonGradientBottom;
            borderTowardsLight = uBorderLight;
            borderAwayFromLight = uBorderDark;
            break;
          }
        }
        color = blend(color, 
                      mix(mix(mix(mix((guiElementIndex == GUI_ELEMENT_BUTTON_PUSHED) ?
                                        mix(gradientTop * 0.5f,
                                            gradientTop,  
                                            linearstep(0.0, 6.0, p.y)) :
                                        gradientTop,
                                      gradientBottom, 
                                      linearstep(0.0, size.y, p.y)),
                                  mix(mix(borderTowardsLight, 
                                          uBorderMedium, 
                                          linearstep(0.0, t, p.y - 3.0)), 
                                      borderAwayFromLight, 
                                      linearstep(0.0, t, p.y - (size.y - 3.0))),
                                  linearstep(-t, t, d3)),
                              uBorderMedium, 
                              linearstep(-t, t, d2)),
                            mix(uBorderMedium,
                                uBorderLight,
                                linearstep(-t, t, p.y - (size.y - 1.0))), 
                            linearstep(-t, t, d1)) *
                      vec2(1.0, linearstep(t, -t, d0)).xxxy);                      
        if(inMetaInfo2.x < 0.5){
          color.w = 1.0; // Opaque
        }                    
        break;
      }
      case GUI_ELEMENT_FOCUSED:{
        float d0 = sdRoundedRect(p - (size * 0.5), size * 0.5, 0.0);      
        float d1 = sdRoundedRect(p - (size * 0.5), (size * 0.5) - 2.0, 0.0);      
        color = blend(color,
                      uFocused * 
                      vec2(1.0, linearstep(t, -t, max(d0, -d1))).xxxy);
        if(inMetaInfo2.x < 0.5){
          color.w = 1.0; // Opaque
        }                    
        break;
      }
      case GUI_ELEMENT_HOVERED:{
        float d0 = sdRoundedRect(p - (size * 0.5), size * 0.5, 0.0);      
        float d1 = sdRoundedRect(p - (size * 0.5), (size * 0.5) - 2.0, 0.0);      
        color = blend(color,
                      uHovered * 
                      vec2(1.0, linearstep(t, -t, max(d0, -d1))).xxxy);
        if(inMetaInfo2.x < 0.5){
          color.w = 1.0; // Opaque
        }                    
        break;
      }
      case GUI_ELEMENT_BOX_UNFOCUSED:  
      case GUI_ELEMENT_BOX_FOCUSED:
      case GUI_ELEMENT_BOX_DISABLED:
      case GUI_ELEMENT_BOX_DARK_UNFOCUSED:  
      case GUI_ELEMENT_BOX_DARK_FOCUSED:
      case GUI_ELEMENT_BOX_DARK_DISABLED:{
        float d0 = sdRoundedRect(p - (size * 0.5), size * 0.5, uButtonCornerRadius),
              d1 = sdRoundedRect(p - (size * 0.5), (size * 0.5) - vec2(0.5), uButtonCornerRadius),      
              d2 = sdRoundedRect(p - (size * 0.5), (size * 0.5) - vec2(1.0), uButtonCornerRadius),      
              d3 = sdRoundedRect(p - (size * 0.5), (size * 0.5) - vec2(2.0), uButtonCornerRadius);      
        vec4 gradientTop,
             gradientBottom,
             borderTowardsLight,
             borderAwayFromLight;
        switch(guiElementIndex){
          case GUI_ELEMENT_BOX_UNFOCUSED:{
            gradientTop = uUnfocusedBoxGradientTop;
            gradientBottom = uUnfocusedBoxGradientBottom;
            borderTowardsLight = uBorderDark; 
            borderAwayFromLight = uBorderMedium;
            break;
          }
          case GUI_ELEMENT_BOX_FOCUSED:{
            gradientTop = uFocusedBoxGradientTop;
            gradientBottom = uFocusedBoxGradientBottom;
            borderTowardsLight = uBorderDark; 
            borderAwayFromLight = uBorderMedium;
            break;
          }
          case GUI_ELEMENT_BOX_DISABLED:{
            gradientTop = uDisabledBoxGradientTop;
            gradientBottom = uDisabledBoxGradientBottom;
            borderTowardsLight = uBorderDark; 
            borderAwayFromLight = uBorderMedium;
            break;
          }
          case GUI_ELEMENT_BOX_DARK_UNFOCUSED:{
            gradientTop = uUnfocusedBoxDarkGradientTop;
            gradientBottom = uUnfocusedBoxDarkGradientBottom;
            borderTowardsLight = uBorderDark; 
            borderAwayFromLight = uBorderMedium;
            break;
          }
          case GUI_ELEMENT_BOX_DARK_FOCUSED:{
            gradientTop = uFocusedBoxDarkGradientTop;
            gradientBottom = uFocusedBoxDarkGradientBottom;
            borderTowardsLight = uBorderDark; 
            borderAwayFromLight = uBorderMedium;
            break;
          }
          case GUI_ELEMENT_BOX_DARK_DISABLED:{
            gradientTop = uDisabledBoxDarkGradientTop;
            gradientBottom = uDisabledBoxDarkGradientBottom;
            borderTowardsLight = uBorderDark; 
            borderAwayFromLight = uBorderMedium;
            break;
          }
        }
        color = blend(color, 
                      mix(mix(mix(mix(mix(gradientTop * 0.5f,
                                          gradientTop,  
                                          linearstep(0.0, 6.0, p.y)),
                                      gradientBottom, 
                                      linearstep(0.0, size.y, p.y)),
                                  mix(mix(borderTowardsLight, 
                                          uBorderMedium, 
                                          linearstep(0.0, t, p.y - 3.0)), 
                                      borderAwayFromLight, 
                                      linearstep(0.0, t, p.y - (size.y - 3.0))),
                                  linearstep(-t, t, d3)),
                              uBorderMedium, 
                              linearstep(-t, t, d2)),
                            mix(uBorderMedium,
                                uBorderLight,
                                linearstep(-t, t, p.y - (size.y - 1.0))), 
                            linearstep(-t, t, d1)) *
                      vec2(1.0, linearstep(t, -t, d0)).xxxy);  
        if(inMetaInfo2.x < 0.5){
          color.w = 1.0; // Opaque
        }                    
        break;
      }
      case GUI_ELEMENT_PANEL_ENABLED:
      case GUI_ELEMENT_PANEL_DISABLED:{
        float d0 = sdRoundedRect(p - (size * 0.5), size * 0.5, uButtonCornerRadius),
              d1 = sdRoundedRect(p - (size * 0.5), (size * 0.5) - vec2(1.0), uButtonCornerRadius),      
              d2 = sdRoundedRect(p - (size * 0.5), (size * 0.5) - vec2(2.0), uButtonCornerRadius),      
              d3 = sdRoundedRect(p - (size * 0.5), (size * 0.5) - vec2(3.0), uButtonCornerRadius);      
        vec4 gradientTop,
             gradientBottom,
             borderTowardsLight,
             borderAwayFromLight;
        switch(guiElementIndex){
          case GUI_ELEMENT_PANEL_ENABLED:{
            gradientTop = uEnabledPanelGradientTop;
            gradientBottom = uEnabledPanelGradientBottom;
            borderTowardsLight = uBorderLight;
            borderAwayFromLight = uBorderDark;
            break;
          }
          case GUI_ELEMENT_PANEL_DISABLED:{
            gradientTop = uDisabledPanelGradientTop;
            gradientBottom = uDisabledPanelGradientBottom;
            borderTowardsLight = uBorderLight;
            borderAwayFromLight = uBorderDark;
            break;
          }
        }
        color = blend(color, 
                      mix(mix(mix(mix(gradientTop,
                                      gradientBottom, 
                                      linearstep(0.0, size.y, p.y)),
                                  mix(mix(borderTowardsLight, 
                                          uBorderMedium, 
                                          linearstep(0.0, t, p.y - 3.0)), 
                                      borderAwayFromLight, 
                                      linearstep(0.0, t, p.y - (size.y - 3.0))),
                                  linearstep(-t, t, d3)),
                              uBorderMedium, 
                              linearstep(-t, t, d2)),
                            mix(uBorderMedium,
                                uBorderLight,
                                linearstep(-t, t, p.y - (size.y - 1.0))), 
                            linearstep(-t, t, d1)) *
                      vec2(1.0, linearstep(t, -t, d0)).xxxy);                      
        if(inMetaInfo2.x < 0.5){
          color.w = 1.0; // Opaque
        }                    
        break;
      }      
      case GUI_ELEMENT_TAB_BUTTON_UNFOCUSED:
      case GUI_ELEMENT_TAB_BUTTON_FOCUSED:
      case GUI_ELEMENT_TAB_BUTTON_PUSHED:
      case GUI_ELEMENT_TAB_BUTTON_DISABLED:{
        float d0 = sdTabButton(p - (size * 0.5), size * 0.5, uButtonCornerRadius),
              d1 = sdTabButton(p - (size * 0.5), (size * 0.5) - vec2(1.0), uButtonCornerRadius),      
              d2 = sdTabButton(p - (size * 0.5), (size * 0.5) - vec2(2.0), uButtonCornerRadius),      
              d3 = sdTabButton(p - (size * 0.5), (size * 0.5) - vec2(3.0), uButtonCornerRadius);      
        vec4 gradientTop,
             gradientBottom,
             borderTowardsLight,
             borderAwayFromLight;
        switch(guiElementIndex){
          case GUI_ELEMENT_TAB_BUTTON_UNFOCUSED:{
            gradientTop = uUnfocusedButtonGradientTop;
            gradientBottom = uUnfocusedButtonGradientBottom;
            borderTowardsLight = uBorderLight;
            borderAwayFromLight = uBorderDark;
            break;
          }
          case GUI_ELEMENT_TAB_BUTTON_FOCUSED:{
            gradientTop = uFocusedButtonGradientTop;
            gradientBottom = uFocusedButtonGradientBottom;
            borderTowardsLight = uBorderLight;
            borderAwayFromLight = uBorderDark;
            break;
          }
          case GUI_ELEMENT_TAB_BUTTON_PUSHED:{
            gradientTop = uPushedButtonGradientTop;
            gradientBottom = uPushedButtonGradientBottom;
            borderTowardsLight = uBorderDark;
            borderAwayFromLight = uBorderLight;
            break;
          }
          case GUI_ELEMENT_TAB_BUTTON_DISABLED:{
            gradientTop = uDisabledButtonGradientTop;
            gradientBottom = uDisabledButtonGradientBottom;
            borderTowardsLight = uBorderLight;
            borderAwayFromLight = uBorderDark;
            break;
          }
        }
        color = blend(color, 
                      mix(mix(mix(mix((guiElementIndex == GUI_ELEMENT_TAB_BUTTON_PUSHED) ?
                                        mix(gradientTop * 0.5f,
                                            gradientTop,  
                                            linearstep(0.0, 6.0, p.y)) :
                                        gradientTop,
                                      gradientBottom, 
                                      linearstep(0.0, size.y, p.y)),
                                  mix(mix(borderTowardsLight, 
                                          uBorderMedium, 
                                          linearstep(0.0, t, p.y - 3.0)), 
                                      borderAwayFromLight, 
                                      linearstep(0.0, t, p.y - (size.y - 3.0))),
                                  linearstep(-t, t, d3)),
                              uBorderMedium, 
                              linearstep(-t, t, d2)),
                            mix(uBorderMedium,
                                uBorderLight,
                                linearstep(-t, t, p.y - (size.y - 1.0))), 
                            linearstep(-t, t, d1)) *
                      vec2(1.0, linearstep(t, -t, d0)).xxxy);                      
        if(inMetaInfo2.x < 0.5){
          color.w = 1.0; // Opaque
        }                    
        break;
      }
      case GUI_ELEMENT_MOUSE_CURSOR_ARROW:
      case GUI_ELEMENT_MOUSE_CURSOR_HELP:{
        float a = dot(p, normalize(vec2(-1.0, 0.0)));
        float b = dot(p, normalize(vec2(0.0, 1.0)));
        float c = dot(p, normalize(vec2(1.0, 1.0))) - (size.x * 0.5);
        float e = dot(p, normalize(vec2(-0.707, 0.707)));
        float d = max(min(max(max(a, -b), c), 
                          max(max(max(a, -b), b - (size.y * 0.5)), (-a) - (size.x * 0.707))),
                          -e);
        e = dot(p, normalize(vec2(-0.5, 0.25)));
        d = min(d, max(max((e - (size.x * 0.1)), -(e - (size.x * -0.05))), -min(b - (size.y * 0.25), -a)));
        e = dot(p, normalize(vec2(0.25, 0.5)));
        d = max(d, e - (size.y * 0.8));
        if(guiElementIndex == GUI_ELEMENT_MOUSE_CURSOR_HELP){
          d = min(d, length(p + (size * vec2(-0.85, -0.75))) - (length(size) * 0.08));
          d = min(d, max(length(p + (size * vec2(-0.75, -0.2))) - (length(size) * 0.25),
                         -(length(p + (size * vec2(-0.55, -0.35))) - (length(size) * 0.2))));
        }        
        if(focused > 0.5){ 
          color = blend(color,
                        vec4(vec3(mix(0.0, 1.0, linearstep(-1.0, -(1.0 + (t * 1.0)), d))), 1.0) * 
                        vec2(1.0, linearstep(t, -t, d)).xxxy);
        }else{
          color = blend(color,
                        vec4(vec3(0.0), 0.95) * 
                        vec2(1.0, linearstep(t, -((length(size) * SQRT_0_DOT_5) * 0.125) + t, d)).xxxy);
        }
        break;
      }
      case GUI_ELEMENT_MOUSE_CURSOR_BEAM:{
        float d = sdRoundedRect(p - (size * 0.5), vec2(size.x * 0.08, size.y * 0.5), 0.0); 
        d = min(d, sdRoundedRect((p - (size * 0.5)) + vec2(0.0, size.y * 0.4), vec2(size.x * 0.16, size.y * 0.09), 0.0)); 
        d = min(d, sdRoundedRect((p - (size * 0.5)) - vec2(0.0, size.y * 0.4), vec2(size.x * 0.16, size.y * 0.08), 0.0)); 
        d = max(d, -sdRoundedRect((p - (size * 0.5)) - vec2(0.0, size.y * 0.55), vec2(size.x * 0.025, size.y * 0.125), 0.0)); 
        d = max(d, -sdRoundedRect((p - (size * 0.5)) + vec2(0.0, size.y * 0.55), vec2(size.x * 0.025, size.y * 0.125), 0.0)); 
        if(focused > 0.5){ 
          color = blend(color,
                        vec4(vec3(mix(0.0, 1.0, linearstep(-1.0, -(1.0 + (t * 1.0)), d))), 1.0) * 
                        vec2(1.0, linearstep(t, -t, d)).xxxy);
        }else{
          color = blend(color,
                        vec4(vec3(0.0), 0.95) * 
                        vec2(1.0, linearstep(t, -((length(size) * SQRT_0_DOT_5) * 0.125) + t, d)).xxxy);
        }
        break;
      }
      case GUI_ELEMENT_MOUSE_CURSOR_BUSY:{
        vec2 o = p - (size * 0.5); 
        float d = max(length(p - (size * 0.5)) - length(size * 0.5),
                      -(length(p - (size * 0.5)) - length(size * 0.25))); 
        if(focused > 0.5){ 
          float a = atan(o.y, o.x) - inTexCoord.z;
          color = blend(color,
                        vec4(mix(vec3(0.0), 
                                 mix(vec3(0.0, 1.0, 1.0), 
                                     vec3(0.0, 0.125, 1.0), 
                                     (sin(a) * 0.5) + 0.5), 
                                 linearstep(0.0, -(t * 2.0), d)), 1.0) * 
                        vec2(1.0, linearstep(t, -t, d)).xxxy);        
        }else{
          color = blend(color,
                        vec4(vec3(0.0), 0.95) * 
                        vec2(1.0, linearstep(t, -((length(size) * SQRT_0_DOT_5) * 0.125) + t, d)).xxxy);
        }

        break;
      }
      case GUI_ELEMENT_MOUSE_CURSOR_CROSS:{
        float d = sdRoundedRect(p - (size * 0.5), vec2(size.x * 0.08, size.y * 0.5), 0.0); 
        d = min(d, sdRoundedRect(p - (size * 0.5), vec2(size.x * 0.5, size.y * 0.08), 0.0)); 
        d = max(d, -sdRoundedRect(p - (size * 0.5), vec2(size.x * 0.08, size.y * 0.08), 0.0)); 
        if(focused > 0.5){ 
          color = blend(color,
                        vec4(vec3(mix(0.0, 1.0, linearstep(-1.0, -(1.0 + (t * 1.0)), d))), 1.0) * 
                        vec2(1.0, linearstep(t, -t, d)).xxxy);
        }else{
          color = blend(color,
                        vec4(vec3(0.0), 0.95) * 
                        vec2(1.0, linearstep(t, -((length(size) * SQRT_0_DOT_5) * 0.125) + t, d)).xxxy);
        }
        break;
      }
      case GUI_ELEMENT_MOUSE_CURSOR_EW:
      case GUI_ELEMENT_MOUSE_CURSOR_NESW:
      case GUI_ELEMENT_MOUSE_CURSOR_NS:
      case GUI_ELEMENT_MOUSE_CURSOR_NWSE:{
        p -= (size * 0.5);
        switch(guiElementIndex){
          case GUI_ELEMENT_MOUSE_CURSOR_EW:{
            break;
          }                                        
          case GUI_ELEMENT_MOUSE_CURSOR_NESW:{
            p.xy = vec2((p.x * SQRT_0_DOT_5) - (p.y * SQRT_0_DOT_5), (p.x * SQRT_0_DOT_5) + (p.y * SQRT_0_DOT_5)); 
            break;
          }                                        
          case GUI_ELEMENT_MOUSE_CURSOR_NS:{
            p.xy = p.yx;
            break;
          }                                                
          case GUI_ELEMENT_MOUSE_CURSOR_NWSE:{
            p.xy = vec2((p.x * SQRT_0_DOT_5) + (p.y * SQRT_0_DOT_5), (p.x * SQRT_0_DOT_5) - (p.y * SQRT_0_DOT_5)); 
            break;
          }                                        
        }               
        float d = sdRoundedRect(p, vec2(size.x * 0.375, size.y * 0.08), 0.0); 
        d = min(d, sdTriangle((size * 0.5) + vec2(-size.x * 0.25, size.y * 0.25),
                              (size * 0.5) + vec2(-size.x * 0.25, -size.y * 0.25),   
                              (size * 0.5) + vec2(-size.x * 0.5, size.y * 0.0),
                              p + (size * 0.5)));     
        d = min(d, sdTriangle((size * 0.5) + vec2(size.x * 0.25, size.y * 0.25),
                              (size * 0.5) + vec2(size.x * 0.5, size.y * 0.0),
                              (size * 0.5) + vec2(size.x * 0.25, -size.y * 0.25),   
                              p + (size * 0.5)));     
        if(focused > 0.5){ 
          color = blend(color,
                        vec4(vec3(mix(0.0, 1.0, linearstep(-1.0, -(1.0 + (t * 1.0)), d))), 1.0) * 
                        vec2(1.0, linearstep(t, -t, d)).xxxy);
        }else{
          color = blend(color,
                        vec4(vec3(0.0), 0.95) * 
                        vec2(1.0, linearstep(t, -((length(size) * SQRT_0_DOT_5) * 0.125) + t, d)).xxxy);
        }
        break;
      }
      case GUI_ELEMENT_MOUSE_CURSOR_LINK:{
        p += vec2(size.x * -0.5, size.y * -0.5);
        float d = sdRoundedRect(p + vec2(size.x * 0.5, 0.0), vec2(size.x * 0.125, size.y * 0.5), length(size) * 0.1); 
        d = min(d, sdRoundedRect(p + vec2(size.x * 0.25,  size.y * -0.25), vec2(size.x * 0.125, size.y * 0.5), length(size) * 0.1)); 
        d = min(d, sdRoundedRect(p + vec2(size.x * 0.0,  size.y * -0.35), vec2(size.x * 0.125, size.y * 0.5), length(size) * 0.1)); 
        d = min(d, sdRoundedRect(p + vec2(size.x * -0.25, size.y * -0.45), vec2(size.x * 0.125, size.y * 0.5), length(size) * 0.1)); 
        d = min(d, sdRoundedRect(p + vec2(size.x * 0.125, size.y * -0.625), vec2(size.x * 0.525, size.y * 0.5), length(size) * 0.3)); 
        p += vec2(size.x * 0.625, size.y * -0.625);
        p.xy = vec2((p.x * SQRT_0_DOT_5) + (p.y * SQRT_0_DOT_5), (p.x * SQRT_0_DOT_5) - (p.y * SQRT_0_DOT_5));       
        d = min(d, sdRoundedRect(p, vec2(size.x * 0.5, size.y * 0.15), length(size) * 0.1)); 
        if(focused > 0.5){ 
          color = blend(color,
                        vec4(vec3(mix(0.0, 1.0, linearstep(-1.0, -(1.0 + (t * 1.0)), d))), 1.0) * 
                        vec2(1.0, linearstep(t, -t, d)).xxxy);
        }else{
          color = blend(color,
                        vec4(vec3(0.0), 0.95) * 
                        vec2(1.0, linearstep(t, -((length(size) * SQRT_0_DOT_5) * 0.125) + t, d)).xxxy);
        }
        break;
      }
      case GUI_ELEMENT_MOUSE_CURSOR_MOVE:{
        p -= (size * 0.5);
        float d = sdRoundedRect(p, vec2(size.x * 0.375, size.y * 0.08), 0.0); 
        d = min(d, sdTriangle((size * 0.5) + vec2(-size.x * 0.25, size.y * 0.25),
                              (size * 0.5) + vec2(-size.x * 0.25, -size.y * 0.25),   
                              (size * 0.5) + vec2(-size.x * 0.5, size.y * 0.0),
                              p + (size * 0.5)));     
        d = min(d, sdTriangle((size * 0.5) + vec2(size.x * 0.25, size.y * 0.25),
                              (size * 0.5) + vec2(size.x * 0.5, size.y * 0.0),
                              (size * 0.5) + vec2(size.x * 0.25, -size.y * 0.25),   
                              p + (size * 0.5)));     
        p = p.yx;                      
        d = min(d, sdRoundedRect(p, vec2(size.x * 0.375, size.y * 0.08), 0.0)); 
        d = min(d, sdTriangle((size * 0.5) + vec2(-size.x * 0.25, size.y * 0.25),
                              (size * 0.5) + vec2(-size.x * 0.25, -size.y * 0.25),   
                              (size * 0.5) + vec2(-size.x * 0.5, size.y * 0.0),
                              p + (size * 0.5)));     
        d = min(d, sdTriangle((size * 0.5) + vec2(size.x * 0.25, size.y * 0.25),
                              (size * 0.5) + vec2(size.x * 0.5, size.y * 0.0),
                              (size * 0.5) + vec2(size.x * 0.25, -size.y * 0.25),   
                              p + (size * 0.5)));     
        if(focused > 0.5){ 
          color = blend(color,
                        vec4(vec3(mix(0.0, 1.0, linearstep(-1.0, -(1.0 + (t * 1.0)), d))), 1.0) * 
                        vec2(1.0, linearstep(t, -t, d)).xxxy);
        }else{
          color = blend(color,
                        vec4(vec3(0.0), 0.95) * 
                        vec2(1.0, linearstep(t, -((length(size) * SQRT_0_DOT_5) * 0.125) + t, d)).xxxy);
        }
        break;
      }
      case GUI_ELEMENT_MOUSE_CURSOR_PEN:{
        p -= (size * 0.5);
        p.xy = vec2((p.x * SQRT_0_DOT_5) + (p.y * SQRT_0_DOT_5), (p.x * SQRT_0_DOT_5) - (p.y * SQRT_0_DOT_5)); 
        float d =  sdRoundedRect(p, vec2(size.x * 0.8, size.y * 0.15), size.x * mix(0.8, 0.2, linearstep(0.0, size.x * 0.5, p.x)));
        if(focused > 0.5){ 
          color = blend(color,
                        vec4(vec3(mix(0.0, 1.0, linearstep(-1.0, -(1.0 + (t * 1.0)), d))), 1.0) * 
                        vec2(1.0, linearstep(t, -t, d)).xxxy);
        }else{
          color = blend(color,
                        vec4(vec3(0.0), 0.95) * 
                        vec2(1.0, linearstep(t, -((length(size) * SQRT_0_DOT_5) * 0.125) + t, d)).xxxy);
        }
        break;    
      }
      case GUI_ELEMENT_MOUSE_CURSOR_UNAVAILABLE:{
        p -= (size * 0.5);
        if(focused > 0.5){ 
          color = blend(color,
                        vec4(mix(vec3(1.0, 0.0, 0.0), 
                                 vec3(1.0, 1.0, 1.0), 
                                 linearstep(-t, 
                                            t, 
                                            min(max(length(p) - length(size), -(length(p) - length(size * 0.3))),
                                                sdRoundedRect(vec2((p.x * SQRT_0_DOT_5) - (p.y * SQRT_0_DOT_5), (p.x * SQRT_0_DOT_5) + (p.y * SQRT_0_DOT_5)),
                                                              vec2(size.x * 0.625, size.y * 0.175), 0.0)))), 1.0) * 
                        vec2(1.0, 
                             linearstep(t, 
                                        -t, 
                                        length(p) - length(size * 0.5))).xxxy);
        }else{
          color = blend(color,
                        vec4(vec3(0.0), 0.95) * 
                        vec2(1.0, linearstep(t, -((length(size) * SQRT_0_DOT_5) * 0.125) + t, length(p) - length(size * 0.5))).xxxy);
        }
        break;
      }
      case GUI_ELEMENT_MOUSE_CURSOR_UP:{
        p -= (size * 0.5);
        p = p.yx;                      
        float d = sdRoundedRect(p, vec2(size.x * 0.375, size.y * 0.08), 0.0); 
        d = min(d, sdTriangle((size * 0.5) + vec2(-size.x * 0.25, size.y * 0.25),
                              (size * 0.5) + vec2(-size.x * 0.25, -size.y * 0.25),   
                              (size * 0.5) + vec2(-size.x * 0.5, size.y * 0.0),
                              p + (size * 0.5)));     
        if(focused > 0.5){ 
          color = blend(color,
                        vec4(vec3(mix(0.0, 1.0, linearstep(-1.0, -(1.0 + (t * 1.0)), d))), 1.0) * 
                        vec2(1.0, linearstep(t, -t, d)).xxxy);
        }else{
          color = blend(color,
                        vec4(vec3(0.0), 0.95) * 
                        vec2(1.0, linearstep(t, -((length(size) * SQRT_0_DOT_5) * 0.125) + t, d)).xxxy);
        }
        break;
      }
      case GUI_ELEMENT_HIDDEN:{
        color = vec4(0.0);
        break;        
      }
      case GUI_ELEMENT_COLOR_WHEEL_UNFOCUSED:
      case GUI_ELEMENT_COLOR_WHEEL_FOCUSED:
      case GUI_ELEMENT_COLOR_WHEEL_DISABLED:{
        float v = 1.0, w = 0.0; 
        switch(guiElementIndex){
          case GUI_ELEMENT_COLOR_WHEEL_UNFOCUSED:{
            break;
          }                                     
          case GUI_ELEMENT_COLOR_WHEEL_FOCUSED:{
            w = 1.0;
            break;
          }                                     
          case GUI_ELEMENT_COLOR_WHEEL_DISABLED:{
            v = 0.75; 
            break;
          }                                     
        }
        vec3 hsv = inColor.xyz;
        p -= (size * 0.5);
        vec2 size2 = vec2(min(size.x, size.y)) * SQRT_0_DOT_5 * 0.95,
             p2 = rotate(p, hsv.x * 6.28318531) + (size2 * 0.5);
        float r = length(size2) * 0.5, 
              r2 = r * SQRT_0_DOT_5,
              pa = atan(p.y, p.x) / 6.28318531,
              pad = fract((pa - fract(hsv.x + 0.495)) + 0.5) - 0.5; 
        vec2 tv0 = (size2 * 0.5) + rotate(vec2(r2, 0.0), radians(0.0)),
             tv1 = (size2 * 0.5) + rotate(vec2(r2, 0.0), radians(120.0)),             
             tv2 = (size2 * 0.5) + rotate(vec2(r2, 0.0), radians(-120.0)),
             tv = tv2 + ((tv1 - tv2) * hsv.z) + ((tv0 - tv1) * (hsv.y * hsv.z));
        float d0 = max(length(p) - r, -(length(p) - (r * 0.75))),
              d1 = sdTriangle(tv0, tv1, tv2, p2),
              d2 = length(tv - p2),
              d3 = max(d2 - (r * 0.08), -(d2 - (r * 0.04))),
              d4 = d2 - (r * mix(0.04, 0.08, 0.5)),
              d5 = d2 - (r * 0.07),
              d6 = max(sdRoundedRect(p2 - vec2(size2.x * 1.118, size2.y * 0.5), vec2(r * 0.13725, r * 0.04), 1e-4), 
                       -sdRoundedRect(p2 - vec2(size2.x * 1.118, size2.y * 0.5), vec2(r * 0.1, r * 0.01), 1e-4));
        vec3 b = clamp(barycentricTriangle(tv0, tv1, tv2, p2), vec3(0.0), vec3(1.0));
//      color = blend(color, vec4(1.0) * linearstep(t, -t, sdRoundedRect(p, size * 0.5, 1e-4))); 
        color = blend(blend(blend(blend(blend(color,    
                                              vec4(colorWheelConditionalConvertSRGBToLinearRGB((hsv2rgb(vec3(hsv.x, 1.0, 1.0)) * b.x) + (vec3(1.0) * b.y) + (vec3(0.0) * b.z)), 1.0) * linearstep(t, -t, d1) * v),
                                        vec4(colorWheelConditionalConvertSRGBToLinearRGB(hsv2rgb(vec3(pa, 1.0, 1.0))), 1.0) * linearstep(t, -t, d0) * v),
                                  vec4(vec3(w), mix(1.0, 0.95, w)) * linearstep(t, -t, d6) * v),
                            vec4(colorWheelConditionalConvertSRGBToLinearRGB(hsv2rgb(hsv)), 1.0) *  linearstep(t, -t, d5) * v),
                       vec4(colorWheelConditionalConvertSRGBToLinearRGB(vec3(mix(1.0 - b.z, b.z, linearstep(t, -t, d4)))), 1.0) * linearstep(t, -t, d3) * 0.5 * v);
        break;
      }
    } 
  }
#endif
#if MASKING
  if((pushConstants.data[7].w & (1u << 0)) != 0u){
    // Construct a 4x4 matrix from the push constants data from a 3x2 matrix  
    const mat4 maskMatrix = mat4(
      vec4(uintBitsToFloat(uvec2(pushConstants.data[5].w, pushConstants.data[6].x)), 0.0, 0.0),
      vec4(uintBitsToFloat(uvec2(pushConstants.data[6].yz)), 0.0, 0.0),
      vec4(0.0, 0.0, 0.0, 0.0),
      vec4(uintBitsToFloat(uvec2(pushConstants.data[6].w, pushConstants.data[7].x)), 0.0, 1.0)
    );  
    vec2 maskPosition = (inverse(maskMatrix) * vec4(inClipSpacePosition.xy, 0.0, 1.0)).xy;
    if(all(greaterThanEqual(maskPosition, vec2(0.0))) && all(lessThanEqual(maskPosition, vec2(1.0)))){
      color *= texture(uTextureMask, maskPosition).x;
    }else{
      discard;
    }
  } 
#endif
#if !USECLIPDISTANCE
#if BLENDING 
  color *= step(inClipRect.x, inClipSpacePosition.x) * step(inClipRect.y, inClipSpacePosition.y) * step(inClipSpacePosition.x, inClipRect.z) * step(inClipSpacePosition.y, inClipRect.w);
#elif !USENODISCARD
//if(step(inClipRect.x, inClipSpacePosition.x) * step(inClipRect.y, inClipSpacePosition.y) * step(inClipSpacePosition.x, inClipRect.z) * step(inClipSpacePosition.y, inClipRect.w)) < 0.5){
  if(any(lessThan(inClipSpacePosition.xy, inClipRect.xy)) || 
     any(greaterThan(inClipSpacePosition.xy, inClipRect.zw))){
    discard;
  }
#endif  
#endif  
  outFragColor = color;
}
#endif
