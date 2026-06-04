#version 450

#pragma shader_stage(tese)

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable
#extension GL_EXT_nonuniform_qualifier : enable
#extension GL_EXT_control_flow_attributes : enable

layout(quads, equal_spacing, ccw) in;

layout(location = 0) patch in InBlock {
  vec4 v1;
  vec4 v2;
  vec3 bladeDirection;
  vec3 bladeUp;
} inBlock;

#if defined(RAYTRACING)

layout(location = 0) out vec3 outWorldSpacePosition;

layout(location = 1) out OutBlock {
  vec3 position;
  vec3 normal;
  vec2 texCoord;
  vec3 worldSpacePosition;
  vec3 viewSpacePosition;
  vec3 cameraRelativePosition;
  vec2 jitter;
#ifdef VELOCITY
  vec4 previousClipSpace;
  vec4 currentClipSpace;
#endif  
} outBlock;

#else

layout(location = 0) out OutBlock {
  vec3 position;
  vec3 normal;
  vec2 texCoord;
  vec3 worldSpacePosition;
  vec3 viewSpacePosition;
  vec3 cameraRelativePosition;
  vec2 jitter;
#ifdef VELOCITY
  vec4 previousClipSpace;
  vec4 currentClipSpace;
#endif  
} outBlock;
#endif

struct View {
  mat4 viewMatrix;
  mat4 projectionMatrix;
  mat4 inverseViewMatrix;
  mat4 inverseProjectionMatrix;
};

layout(set = 1, binding = 0, std140) uniform uboViews {
  View views[256];
} uView;

#define PLANETS
#include "globaldescriptorset.glsl"
#undef PLANETS

#include "planet_grass.glsl"

#include "octahedralmap.glsl"
#include "tangentspacebasis.glsl" 

uint viewIndex = pushConstants.viewBaseIndex + uint(gl_ViewIndex);
mat4 viewMatrix = uView.views[viewIndex].viewMatrix;
mat4 projectionMatrix = uView.views[viewIndex].projectionMatrix;
mat4 inverseViewMatrix = uView.views[viewIndex].inverseViewMatrix;

mat4 viewProjectionMatrix = projectionMatrix * viewMatrix;

vec3 cameraPosition = inverseViewMatrix[3].xyz;

vec2 halfScreenSize = vec2(1.0) / vec2(projectionMatrix[0][0], projectionMatrix[1][1]);

float shapeConstant = 0.0;

vec3 Quad(const in vec3 i1, const in vec3 i2, const in float u, const in float v, const in vec3 normal, const in float bladeWidth){
	shapeConstant = 1.0;
	return mix(i1, i2, u);
}

vec3 Triangle(const in vec3 i1, const in vec3 i2, const in float u, const in float v, const in vec3 normal, const in float bladeWidth){
	shapeConstant = 2.0;
	float omu = 1.0 - u;
	return mix(i1, i2, u + ((v * omu) - (v * u)) * 0.5);
}

vec3 Quadratic(const in vec3 i1, const in vec3 i2, const in float u, const in float v, const in vec3 normal, const in float bladeWidth){
	shapeConstant = 3.0;
	return mix(i1, i2, u - ((v * v) * u));
}

vec3 Quadratic3DShape(const in vec3 i1, const in vec3 i2, const in float u, const in float v, const in vec3 normal, const in float bladeWidth){
	shapeConstant = 4.0;
	vec3 translation = normal * bladeWidth * (0.5 - abs(u - 0.5)) * (1.0 - v); 
	return mix(i1, i2, u - ((v * v) * u)) + translation;
}

vec3 Quadratic3DShapeMinWidth(const in vec3 i1, const in vec3 i2, const in float u, const in float v, const in vec3 normal, const in float bladeWidth){
	shapeConstant = 5.0;
	vec4 i1V = viewProjectionMatrix * vec4(i1.xyz, 1.0);
	i1V = i1V / i1V.w;
	vec4 i2V = viewProjectionMatrix * vec4(i2.xyz, 1.0);
	i2V = i2V / i2V.w;
	vec4 widthV = i2V - i1V;
	widthV.x = widthV.x * halfScreenSize.x;
	widthV.y = widthV.y * halfScreenSize.y;
	float width = length(widthV.xy);
	float minWidth = 1.0;
	float widthSpan = 2.0;
	float widthF = 1.0 - min(max((width - minWidth) / widthSpan, 0.0), 1.0);
	vec3 position = mix(i1, i2, max(u - ((v * v) * u), widthF * u));
	position = position + normal * bladeWidth * (0.5 - abs(u - 0.5)) * (1.0 - v);
	return position;
}

vec3 TriangleTipMinWidth(const in vec3 i1, const in vec3 i2, const in float u, const in float v, const in vec3 normal, const in float bladeWidth){
	shapeConstant = 6.0;
	vec4 i1V = viewProjectionMatrix * vec4(i1.xyz, 1.0);
	i1V = i1V / i1V.w;
	vec4 i2V = viewProjectionMatrix * vec4(i2.xyz, 1.0);
	i2V = i2V / i2V.w;
	vec4 widthV = i2V - i1V;
	widthV.x = widthV.x * halfScreenSize.x;
	widthV.y = widthV.y * halfScreenSize.y;
	float width = length(widthV.xy);
	float minWidth = 1.0;
	float widthSpan = 2.0;
	float widthF = 1.0 - min(max((width - minWidth) / widthSpan, 0.0), 1.0);
	vec3 position = mix(i1, i2, 0.5 + (u - 0.5) * max(1.0 - (max(v - 0.5, 0.0) / (1.0 - 0.5)), widthF)); 
	position = position + normal * bladeWidth * (0.5 - abs(u - 0.5)) * (1.0 - (max(v - 0.5, 0.0) / (1.0 - 0.5))); 
	return position;
}

vec3 Dandelion(const in vec3 i1, const in vec3 i2, const in float u, const in float v, const in vec3 normal, const in float bladeWidth){
	shapeConstant = 7.0;
	float omv = 1.0 - v;
	float level = gl_TessLevelOuter[0];
	float piLevel = 3.14159265358979f * max(level / 8.0, 1.0);
	float piLevelOmv = piLevel * omv;
	return mix(i1, i2, 0.5 + (u - 0.5) * (sqrt(omv) * ((2.0 - omv) - sqrt(abs(sin(piLevelOmv)) * abs(cos(piLevelOmv))))));
}

void main(){
  
  float u = gl_TessCoord.x;
	float omu = 1.0 - u;
	float v = gl_TessCoord.y;
	float omv = 1.0 - v;

	vec3 off = inBlock.bladeDirection * inBlock.v2.w;
	vec3 off2 = off * 0.5;

	vec3 p0 = gl_in[0].gl_Position.xyz - off2;
	vec3 p1 = inBlock.v1.xyz - off2;
	vec3 p2 = inBlock.v2.xyz - off2;

	vec3 h1 = p0 + v * (p1 - p0);
	vec3 h2 = p1 + v * (p2 - p1);
	vec3 i1 = h1 + v * (h2 - h1);
	vec3 i2 = i1 + off;

	vec3 bitangent = inBlock.bladeDirection;

	vec3 h1h2 = h2 - h1;
	vec3 tangent = (dot(h1h2, h1h2) < 1e-3) ? inBlock.bladeUp : normalize(h1h2);
	
	vec2 uv = vec2(u, v);

	vec3 normal = normalize(cross(tangent, bitangent));

	vec3 position;

  int shape = 0;

  switch(shape){
    case 0:{
      position = Quad(i1, i2, u, v, normal, inBlock.v2.w);
      break;
    }
    case 1:{
      position = Triangle(i1, i2, u, v, normal, inBlock.v2.w);
      break;
    }
    case 2:{
      position = Quadratic(i1, i2, u, v, normal, inBlock.v2.w);
      break;
    }
    case 3:{
      position = Quadratic3DShape(i1, i2, u, v, normal, inBlock.v2.w);
      break;
    }
    case 4:{
      position = Quadratic3DShapeMinWidth(i1, i2, u, v, normal, inBlock.v2.w);
      break;
    }
    case 5:{
      position = TriangleTipMinWidth(i1, i2, u, v, normal, inBlock.v2.w);
      break;
    }
    case 6:{
      position = Dandelion(i1, i2, u, v, normal, inBlock.v2.w);
      break;
    }
    default:{
      position = Quad(i1, i2, u, v, normal, inBlock.v2.w);
      break;
    }
  }

/*if(dot(lightDirection, normal) > 0.0){
		normal = -normal;
  }*/

	gl_Position = viewProjectionMatrix * vec4(position, 1.0);

#if defined(RAYTRACING)
  outWorldSpacePosition = position;
#endif

  outBlock.position = position;
  outBlock.normal = normal;
  outBlock.texCoord = uv;
  outBlock.worldSpacePosition = position;
  outBlock.viewSpacePosition = (viewMatrix * vec4(position, 1.0)).xyz;
  outBlock.cameraRelativePosition = position - cameraPosition;
  outBlock.jitter = pushConstants.jitter;
#ifdef VELOCITY
  outBlock.currentClipSpace = viewProjectionMatrix * vec4(position, 1.0);
  outBlock.previousClipSpace = (uView.views[viewIndex + pushConstants.countAllViews].projectionMatrix * uView.views[viewIndex + pushConstants.countAllViews].viewMatrix) * vec4(position, 1.0);
#endif  
	
//position = vec4(position, 1.5f * abs(sin(shapeConstant * inBlock.v1.w)));

}
