#ifndef FRUSTUM_GLSL
#define FRUSTUM_GLSL

const int FrustumLeft = 0;
const int FrustumRight = 1;
const int FrustumBottom = 2;
const int FrustumTop = 3;
const int FrustumNear = 4;
const int FrustumFar = 5;

struct Frustum {
	vec4 planes[6];
  int maximumPlaneSide;
};

void frustumSetup(out Frustum frustum, mat4 m){
  // Only for 0.0 .. 1.0 depth range projection matrices
  bool reverseZ = m[2][3] < -1e-7;
  bool infiniteFarPlane = reverseZ && ((abs(m[2][2]) < 1e-7) && (abs(m[3][2]) > 1e-7));
  frustum.maximumPlaneSide = infiniteFarPlane ? FrustumNear : FrustumFar; // Avoid far plane culling for infinite far plane frustums
  mat4 t = transpose(m);
  frustum.planes[FrustumLeft] = normalize(t[3] + t[0]);
  frustum.planes[FrustumRight] = normalize(t[3] - t[0]);
  frustum.planes[FrustumBottom] = normalize(t[3] + t[1]);
  frustum.planes[FrustumTop] = normalize(t[3] - t[1]);
  if(reverseZ){
    frustum.planes[FrustumNear] = normalize(t[3] - t[2]);
    frustum.planes[FrustumFar] = normalize(/*t[3] +*/ t[2]);
  }else{
    frustum.planes[FrustumNear] = normalize(/*t[3] +*/ t[2]);
    frustum.planes[FrustumFar] = normalize(t[3] - t[2]);
  } 
}

bool frustumCullingAABBTest(const in Frustum frustum, vec3 aabbMin, vec3 aabbMax){
	[[unroll]] for(int frustumPlaneIndex = 0; frustumPlaneIndex <= frustum.maximumPlaneSide; frustumPlaneIndex++){
    if(dot(vec4(mix(aabbMin, aabbMax, vec3(greaterThan(frustum.planes[frustumPlaneIndex].xyz, vec3(0.0)))), 1.0), frustum.planes[frustumPlaneIndex]) < 0.0){
      return false;
    }
	}
	return true;
}

bool frustumCullingSphereTest(const in Frustum frustum, vec4 sphere){
  [[unroll]] for(int frustumPlaneIndex = 0; frustumPlaneIndex <= frustum.maximumPlaneSide; frustumPlaneIndex++){
    if(dot(vec4(sphere.xyz, 1.0), frustum.planes[frustumPlaneIndex]) < -sphere.w){
      return false;
    }
  }
  return true;
}

bool clipLineToFrustum(in Frustum frustum, inout vec3 start, inout vec3 end){

  // Iterate over the relevant frustum planes
  for(int planeIndex = 0; planeIndex <= frustum.maximumPlaneSide; planeIndex++){
    vec4 plane = frustum.planes[planeIndex];

    // Compute distances of the line's endpoints to the current plane
    float distStart = dot(vec4(start, 1.0), plane);
    float distEnd = dot(vec4(end, 1.0), plane);

    // If both points are inside, skip to the next plane
    if((distStart >= 0.0) && (distEnd >= 0.0)){
        continue;
    }

    // If the line is fully outside this plane, truncate it to empty
    if((distStart < 0.0) && (distEnd < 0.0)){
        start = vec3(0.0); // Set to invalid or sentinel value
        end = vec3(0.0);
        return false;
    }

    // Otherwise, compute the intersection point
    float t = distStart / (distStart - distEnd);
    vec3 intersection = mix(start, end, t);

    // Replace the point outside with the intersection
    if(distStart < 0.0){
      start = intersection;
    }else{
      end = intersection;
    }

  }

  return true;
}

#endif