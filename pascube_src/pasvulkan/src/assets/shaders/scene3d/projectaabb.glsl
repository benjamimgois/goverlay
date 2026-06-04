#ifndef PROJECTAABB_GLSL
#define PROJECTAABB_GLSL

bool projectAABB(vec3 aabbMin, vec3 aabbMax, const in float zNear, const in mat4 projectionMatrix, out vec4 aabb, bool zNearTest){
  
  vec2 minMaxZ = vec2(min(aabbMin.z, aabbMax.z), max(aabbMin.z, aabbMax.z));

  if(zNearTest && ((-minMaxZ.x) < zNear)){
  
    return false;

  }else{

    vec4 corners[8] = vec4[8](
      projectionMatrix * vec4(aabbMin.x, aabbMin.y, aabbMin.z, 1.0),
      projectionMatrix * vec4(aabbMin.x, aabbMin.y, aabbMax.z, 1.0),
      projectionMatrix * vec4(aabbMin.x, aabbMax.y, aabbMin.z, 1.0),
      projectionMatrix * vec4(aabbMin.x, aabbMax.y, aabbMax.z, 1.0),
      projectionMatrix * vec4(aabbMax.x, aabbMin.y, aabbMin.z, 1.0),
      projectionMatrix * vec4(aabbMax.x, aabbMin.y, aabbMax.z, 1.0),
      projectionMatrix * vec4(aabbMax.x, aabbMax.y, aabbMin.z, 1.0),
      projectionMatrix * vec4(aabbMax.x, aabbMax.y, aabbMax.z, 1.0)
    );

    corners[0] /= corners[0].w;
    corners[1] /= corners[1].w;
    corners[2] /= corners[2].w;
    corners[3] /= corners[3].w;
    corners[4] /= corners[4].w;
    corners[5] /= corners[5].w;
    corners[6] /= corners[6].w;
    corners[7] /= corners[7].w;

    vec3 minCoords = min(min(min(corners[0].xyz, corners[1].xyz), min(corners[2].xyz, corners[3].xyz)), min(min(corners[4].xyz, corners[5].xyz), min(corners[6].xyz, corners[7].xyz)));
    vec3 maxCoords = max(max(max(corners[0].xyz, corners[1].xyz), max(corners[2].xyz, corners[3].xyz)), max(max(corners[4].xyz, corners[5].xyz), max(corners[6].xyz, corners[7].xyz)));

    aabb = fma(
      vec4(
        min(minCoords.xy, maxCoords.xy),
        max(minCoords.xy, maxCoords.xy)
      ),
      vec4(0.5),
      vec4(0.5)
    );

    return true; //all(lessThanEqual(aabb.xy, vec2(1.0))) && all(greaterThanEqual(aabb.zw, vec2(0.0)));

  }

}

#endif