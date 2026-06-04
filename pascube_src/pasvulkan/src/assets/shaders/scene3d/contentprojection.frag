#version 450 core

#extension GL_EXT_multiview : enable

layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outColor;

/* clang-format off */
layout (push_constant) uniform PushConstants {
  uint viewBaseIndex;
  uint countViews;
  uint countAllViews;
  uint frameIndex;
  vec4 jitter;
} pushConstants;

// Global descriptor set

struct View {
  mat4 viewMatrix;
  mat4 projectionMatrix;
  mat4 inverseViewMatrix;
  mat4 inverseProjectionMatrix;
};

layout(set = 0, binding = 0, std140) uniform uboViews {
  View views[256]; // 65536 / (64 * 4) = 256
} uView;

layout(set = 0, binding = 1, input_attachment_index = 0) uniform subpassInput uTextureBackground;
layout(set = 0, binding = 2) uniform sampler2D uTextureContent;

uint viewIndex = pushConstants.viewBaseIndex + uint(gl_ViewIndex);
View view = uView.views[viewIndex];
mat4 inverseViewProjectionMatrix = inverse(view.projectionMatrix * view.viewMatrix);

const float PI = 3.141592653589793238462643383;

#if 1
const vec3 luma = vec3(0.2126, 0.7152, 0.0722);
#else
const vec3 luma = vec3(0.2989, 0.587, 0.114);
#endif                   

float flipSign = 1.0;

mat2 rotate2D(float t) {
  return mat2(cos(t), sin(t), -sin(t), cos(t));
}

float linearstep(float a, float b, float c){
  return clamp((c - a) / (b - a), 0.0, 1.0);  
}

vec2 safenormalize(vec2 v){
  float l = length(v);
  return (l > 1e-6) ? (v / l) : v;   
}

vec4 alphaBlend(vec4 a, vec4 b){
  return mix(a, b, b.w);
}

vec3 sunPosition = normalize(vec3(0.0, 0.0, -1.0));

vec3 getRayDirection(){
  vec2 ndcUV = fma(clamp(inTexCoord, 
                         vec2(0.0), 
                         vec2(1.0)), 
                   vec2(2.0), 
                   vec2(-1.0));
#ifdef REVERSEDZ
  vec4 n = inverseViewProjectionMatrix * vec4(ndcUV, -1.0, 1.0),
       f = inverseViewProjectionMatrix * vec4(ndcUV, 1.0, 1.0);
#else
  vec4 n = inverseViewProjectionMatrix * vec4(ndcUV, 1.0, 1.0),
       f = inverseViewProjectionMatrix * vec4(ndcUV, -1.0, 1.0);
#endif
  return normalize((f.xyz / f.w) - (n.xyz / n.w)); 
}  

bool intersectPlane(vec3 rayOrigin, vec3 rayDirection, vec4 plane, inout float t){
	bool hit = false;
	float d = dot(rayDirection, plane.xyz);
	if(abs(d) > 1e-5){
		d = -dot(plane, vec4(rayOrigin, 1.0)) / d;
		if((d > 0.0) && ((d < t) || (t > 65536.0))){
		  t = d;
			hit = true;
		}
	}
	return hit;
}

bool intersectQuad(vec3 rayOrigin, vec3 rayDirection, vec3 position, vec3 dir1, vec3 dir2, inout float distance, inout vec2 uv) {
  vec3 normal = -normalize(cross(dir1, dir2));
  float t = dot(normal, position - rayOrigin) / dot(normal, rayDirection);
  if (t <= 0.0) {
    return false;
  }else{
    vec3 offsetedIntersectionPoint = fma(rayDirection, vec3(t), rayOrigin) - position;
    vec2 sizeSquared = vec2(dot(dir1, dir1), dot(dir2, dir2));
    vec2 p = vec2(dot(offsetedIntersectionPoint, dir1), dot(offsetedIntersectionPoint, dir2));
    bool intersected = all(greaterThan(p, vec2(-1e-6))) && all(lessThanEqual(p, sizeSquared));
    if (intersected && (t <= distance)) {
      distance = t;
      uv = p / sizeSquared;
    }
    return intersected;
  }
}

void main(){
  
  vec4 c = subpassLoad(uTextureBackground);

  if(pushConstants.countViews > 0){

    // VR => Reprojection into 3D space
  
    vec3 rayOrigin,
        rayDirection,
        relativeSunPosition;
    {
  #ifdef REVERSEDZ 
      vec4 t = inverseViewProjectionMatrix * vec4(fma(inTexCoord, vec2(2.0), vec2(-1.0)), -1.0, 1.0);
  #else
      vec4 t = inverseViewProjectionMatrix * vec4(fma(inTexCoord, vec2(2.0), vec2(-1.0)), 1.0, 1.0);
  #endif
      rayOrigin = t.xyz / t.w;  
    }
    rayDirection = getRayDirection();

    {
      float time = 1e+16;
      vec2 uv = vec2(0.0); 
      if(intersectQuad(rayOrigin,
                      rayDirection, 
                      vec3(-1.0, -1.0, -2.0), 
                      vec3(2.0, 0.0, 0.0), 
                      vec3(0.0, 2.0, 0.0), 
                      time, 
                      uv)){
        uv.y = 1.0 - uv.y; // Flip Y coordinate
        vec2 texSize = vec2(textureSize(uTextureContent, 0));  
        uv = fma(uv, vec2(2.0), vec2(-1.0)); 
        vec2 aspectCorrect = (texSize.x > texSize.y) ? vec2(1.0, texSize.x / texSize.y) : vec2(texSize.y / texSize.x, 1.0);
        uv = uv * aspectCorrect;
        uv = fma(uv, vec2(0.5), vec2(0.5));
        vec4 s = texture(uTextureContent, uv);
        c = (c * (1.0 - s.w)) + s; // Pre-multiplied alpha blending
      }
    }

    //c.xyz = rayDirection.xyz;
  }else{

    // Non-VR => No reprojection into 3D space
  
    vec4 s = texture(uTextureContent, inTexCoord);

    c = (c * (1.0 - s.w)) + s; // Pre-multiplied alpha blending

  }  

	outColor = c;
                             
}
