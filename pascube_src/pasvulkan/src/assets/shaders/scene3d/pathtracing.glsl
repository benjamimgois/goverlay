#ifndef PATHTRACING_GLSL
#define PATHTRACING_GLSL

struct Ray { 
	vec3 origin; 
	vec3 direction; 
};

struct BsdfSample {
	vec3 bsdfDir; 
	float pdf; 
};


struct RayPayload {
	Ray ray;
	BsdfSample bsdf;
	vec3 radiance;
	vec3 absorption;
	vec3 beta;
	vec3 position;
	vec3 normal;
	vec3 ffnormal;
	uint depth;
	bool stop;
	float eta;
};

#ifdef PATHTRACING_PUSHCONSTANTS
layout (push_constant) uniform PushConstants {
  uint viewBaseIndex;
  uint countViews;
  uint countAllViews;
  uint frameIndex;
  vec4 jitter;
  uvec4 timeSecondsTimeFractionalSecondWidthHeight; // x = timeSeconds (uint), y = timeFractionalSecond (float), z = width, w = height
  uvec4 samplesPerPixelsMaxDepth; // x = samples per pixel, y = max depth, zw = unused
} pushConstants;
#endif

#endif