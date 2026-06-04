#ifndef PROJECTSPHERE_GLSL
#define PROJECTSPHERE_GLSL

//#define fma(a, b, c) ((a) * (b) + (c))

#define PROJECTSPHERE_VARIANT 3

#if PROJECTSPHERE_VARIANT == 0

// Mara & Morgan 2013, "2D Polyhedral Bounds of a Clipped, Perspective-Projected 3D Sphere" 

vec2 projectSphereAxis(vec2 xz, float r, float scale){
	float t = sqrt(dot(xz, xz)- (r * r));
#if 1 
  vec2 ab = vec2(t * xz.y) + (vec2(r, -r) * xz.x);
	return (((vec2(t * xz.x) + (vec2(-r, r) * xz.y)) * ab.yx) * scale) / (ab.x * ab.y);
#else
  return ((vec2(t * xz.x) + (vec2(-r, r) * xz.y)) / (vec2(t * xz.y) + (vec2(r, -r) * xz.x))) * scale;
#endif  
}

vec4 projectSphereToScreenRect(vec3 center, float radius, mat4 projectionMatrix){
  return vec4(
    projectSphereAxis(center.xz, radius, projectionMatrix[0][0]) + projectionMatrix[2][0],
    projectSphereAxis(center.yz, radius, projectionMatrix[1][1]) + projectionMatrix[2][1]
  ).xzyw;
} 

vec2 projectSphereAxisNearClip(vec2 xz, float radius, float scale, float zNear){
  float xz2 = dot(xz, xz), t2 = xz2 - (radius * radius), t = sqrt(t2), h = zNear - xz.y, d = sqrt((radius * radius) - (h * h));
	vec2 cs = vec2(t2, radius * t);
	vec4 TB = vec4(
    ((t2 < 0.0) || (((cs.y * xz.x) + (cs.x * xz.y)) < (zNear * xz2))) ? vec2(xz.x - d, zNear) : vec2((cs.x * xz.x) - (cs.y * xz.y), (cs.y * xz.x) + (cs.x * xz.y)),
	  ((t2 < 0.0) || (((cs.x * xz.y) - (cs.y * xz.x)) < (zNear * xz2))) ? vec2(xz.x + d, zNear) : vec2((cs.x * xz.x) + (cs.y * xz.y), (cs.x * xz.y) - (cs.y * xz.x))
  );  	
	return (TB.xz / TB.yw) * scale;
}

vec4 projectSphereToScreenRectNearClip(vec3 center, float radius, mat4 projectionMatrix, float zNear){
  return vec4(
    projectSphereAxisNearClip(center.xz, radius, projectionMatrix[0][0], zNear) + projectionMatrix[2][0],
    projectSphereAxisNearClip(center.yz, radius, projectionMatrix[1][1], zNear) + projectionMatrix[2][1]
  ).xzyw;
} 

vec4 projectSphereToScreenRectOrtho(vec3 center, float radius, mat4 projectionMatrix){
  return fma(
    vec4(center.xxyy) + vec2(-radius, radius).xyxy,
    vec2(projectionMatrix[0][0], projectionMatrix[1][1]).xxyy,
    vec2(projectionMatrix[2][0], projectionMatrix[2][1]).xxyy
  ).xzyw;
} 

bool projectSphere(vec3 center, const in float radius, const in float zNear, const in mat4 projectionMatrix, out vec4 aabb, bool zNearTest){
  if(zNearTest && (((-center.z) - radius) < zNear)){
    return false;
  }else{
//  float depth;
    if(projectionMatrix[3][3] >= 1.0){
      aabb = projectSphereToScreenRectOrtho(center, radius, projectionMatrix);
//    depth = fma(sphereMinMaxZ.x, projectionMatrix[2][2], projectionMatrix[3][2]);
    }else if((((-center.z) + radius) < zNear){
      aabb = projectSphereToScreenRectNearClip(center, radius, projectionMatrix, zNear);
//    depth = (projectionMatrix[3][2] / center.z) + projectionMatrix[2][2];
    }else{
      aabb = projectSphereToScreenRect(center, radius, projectionMatrix);
//    depth = (projectionMatrix[3][2] / center.z) + projectionMatrix[2][2];
    } 
    aabb = fma(aabb, vec4(0.5), vec4(0.5));
    return all(lessThanEqual(aabb.xy, vec2(1.0))) && all(greaterThanEqual(aabb.zw, vec2(0.0)));
  }
}

#elif PROJECTSPHERE_VARIANT == 1

// Further optimized variant of: 2D Polyhedral Bounds of a Clipped, Perspective-Projected 3D Sphere. Michael Mara, Morgan McGuire. 2013
bool projectSphere(vec3 center, const in float radius, const in float zNear, const in mat4 projectionMatrix, out vec4 aabb){

  if(((-center.z) - radius) < zNear){

    return false;

  }else{

    vec3 cxy = center.xyz;
    vec3 vxy = vec3(sqrt(vec2(dot(cxy.xz, cxy.xz), dot(cxy.yz, cxy.yz)) - vec2(radius * radius)), radius);
    vec2 minx = mat2(vxy.x, vxy.z, -vxy.z, vxy.x) * cxy.xz;
    vec2 maxx = mat2(vxy.x, -vxy.z, vxy.z, vxy.x) * cxy.xz;
    vec2 miny = mat2(vxy.y, vxy.z, -vxy.z, vxy.y) * cxy.yz;
    vec2 maxy = mat2(vxy.y, -vxy.z, vxy.z, vxy.y) * cxy.yz;

    aabb = fma(vec4((vec4(minx.x, miny.x, maxx.x, maxy.x) / vec4(minx.y, miny.y, maxx.y, maxy.y)) * vec2(projectionMatrix[0][0], projectionMatrix[1][1]).xyxy), vec4(0.5), vec4(0.5)); 

    return true;

  }  

}

#elif PROJECTSPHERE_VARIANT == 2

bool projectSphere(const in vec3 center, const in float radius, const in float zNear, const in mat4 projectionMatrix, out vec4 aabb, bool zNearTest){
  
  if(zNearTest && (((-center.z) - radius) < zNear)){

    return false;

  }else{

    vec3 right = (projectionMatrix * vec4(vec3(-center.z, 0.0, center.x) * (radius / sqrt(dot(center, center) - (radius * radius))), 0.0)).xyw;
    vec3 up = (projectionMatrix * vec2(0.0, radius).xyxx).xyw;

    vec3 anchorCenter = (projectionMatrix * vec4(center, 1.0)).xyw;

    vec2 leftAnchor = (anchorCenter.xy - right.xy) / (anchorCenter.z - right.z);
    vec2 rightAnchor = (anchorCenter.xy + right.xy) / (anchorCenter.z + right.z);
    vec2 downAnchor = (anchorCenter.xy - up.xy) / (anchorCenter.z - up.z);
    vec2 upAnchor = (anchorCenter.xy + up.xy) / (anchorCenter.z + up.z);

    aabb = fma(
      vec4(
        min(min(min(leftAnchor, rightAnchor), downAnchor), upAnchor),
        max(max(max(leftAnchor, rightAnchor), downAnchor), upAnchor)
      ),
      vec4(0.5),
      vec4(0.5)
    );

    return true;

  }

}

#else // PROJECTSPHERE_VARIANT == 3

// This variant appears to be the most robust, although it may not be the fastest. It prioritizes robustness and avoiding false negatives 
// over speed to avoid false negatives at the culling. 

bool projectSphere(vec3 center, const in float radius, const in float zNear, const in mat4 projectionMatrix, out vec4 aabb, bool zNearTest){
  
  // center is in view space with negative z pointing into the screen, therefore the sphere center is after the near plane if
  // (center.z + radius) < -zNear or ((-center.z) - radius) > zNear

  if(zNearTest && (((-center.z) - radius) < zNear)){
  
    return false;

  }else{

    // This following is just for ensure that it is just conservative enough to avoid false negatives.
    center.z = min(-zNear, center.z); // clamp center to near plane
//  center.z = min(-zNear, center.z + radius); // move towards the near plane and clamp center to near plane when necessary

    vec3 screenMin = (projectionMatrix * vec4(center - vec2(radius, 0.0).xxy, 1.0)).xyw;
    screenMin.xy /= screenMin.z;

    vec3 screenMax = (projectionMatrix * vec4(center + vec2(radius, 0.0).xxy, 1.0)).xyw;
    screenMax.xy /= screenMax.z;
    
    aabb = fma(
      vec4(
        min(screenMin.xy, screenMax.xy),
        max(screenMin.xy, screenMax.xy)
      ),
      vec4(0.5),
      vec4(0.5)
    );
    
    return true; //all(lessThanEqual(aabb.xy, vec2(1.0))) && all(greaterThanEqual(aabb.zw, vec2(0.0)));

  }

}

#endif

#endif //PROJECTSPHERE_GLSL