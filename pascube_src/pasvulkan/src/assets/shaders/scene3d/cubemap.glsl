#ifndef CUBEMAP_GLSL
#define CUBEMAP_GLSL

vec3 getCubeMapDirection(in vec2 uv,
                         in int faceIndex){                        
  vec3 zDir = vec3(ivec3((faceIndex <= 1) ? 1 : 0,
                         (faceIndex & 2) >> 1,
                         (faceIndex & 4) >> 2)) *
             (((faceIndex & 1) == 1) ? -1.0 : 1.0),
       yDir = (faceIndex == 2)
                ? vec3(0.0, 0.0, 1.0)
                : ((faceIndex == 3)
                     ? vec3(0.0, 0.0, -1.0)
                     : vec3(0.0, -1.0, 0.0)),
       xDir = cross(zDir, yDir);
  return normalize((mix(-1.0, 1.0, uv.x) * xDir) +
                   (mix(-1.0, 1.0, uv.y) * yDir) +
                   zDir);
}

vec2 getCubeMapTexCoordAndFaceIndex(in vec3 direction, 
                                    out int faceIndex){
  vec3 absoluteDirection = abs(direction);
	float magnitude;
	vec2 uv;
	if(all(greaterThanEqual(absoluteDirection.zz, absoluteDirection.xy))){
		faceIndex = (direction.z < 0.0) ? 5 : 4;
		uv = vec2((direction.z < 0.0) ? -direction.x : direction.x, -direction.y);
		magnitude = absoluteDirection.z;
	}else if(absoluteDirection.y >= absoluteDirection.x){
		faceIndex = (direction.y < 0.0) ? 3 : 2;
		uv = vec2(direction.x, (direction.y < 0.0) ? -direction.z : direction.z);
		magnitude = absoluteDirection.y;
	}else{
		faceIndex = (direction.x < 0.0) ? 1 : 0;
		uv = vec2((direction.x < 0.0) ? direction.z : -direction.z, -direction.y);
		magnitude = absoluteDirection.x;
	}       
	return ((0.5 / magnitude) * uv) + vec2(0.5);
}

vec3 fixCubeMapLookup(in vec3 direction,
                      in float lod, 
                      in int cubeSize) {
  float magnitude = max(max(abs(direction.x), abs(direction.y)), abs(direction.z)),
        scale = 1.0 - (exp2(lod) / float(cubeSize)); // float(cubeSize - 1) / float(cubeSize);
  return direction *
         vec3((abs(direction.x) != magnitude) ? scale : 1.0, 
              (abs(direction.y) != magnitude) ? scale : 1.0, 
              (abs(direction.z) != magnitude) ? scale : 1.0);
}

ivec3 seamlessCubeMapUVWWrap(in ivec3 uvw, in int cubeSize) {
  // UV = face uv, W = face index
#if 1
  const int side = (uvw.x < 0) ? 0 : ((uvw.x >= cubeSize) ? 1 : ((uvw.y < 0) ? 2 : ((uvw.y >= cubeSize) ? 3 : -1)));
  if(side >= 0){
    const int maxCoord = cubeSize - 1;
    uvw.y = any(equal(ivec2(side), ivec2(0, 1))) ? clamp(uvw.y, 0, cubeSize - 1) : uvw.y;
    const ivec4 seamlessCubeMapArray[6] = ivec4[6]( 
      ivec4(4, 5, 2, 3), // +X
      ivec4(5, 4, 2, 3), // -X
      ivec4(1, 0, 5, 4), // +Y
      ivec4(1, 0, 4, 5), // -Y
      ivec4(1, 0, 2, 3), // +Z
      ivec4(0, 1, 2, 3)  // -Z
    );
    ivec3 newUVW = ivec3(uvw.xy, seamlessCubeMapArray[uvw.z][side]);
    if(((uvw.z == 0) && (side != 1)) || (((uvw.z == 1) || (uvw.z == 4) || (uvw.z == 5)) && (side == 0))){
      newUVW.x = maxCoord;
    }else if(((uvw.z == 1) && (side != 0)) || (((uvw.z == 0) || (uvw.z == 4) || (uvw.z == 5)) && (side == 1))){
      newUVW.x = 0;
    }else if(((uvw.z == 4) && (side >= 2)) || ((uvw.z == 2) && (side == 3)) || ((uvw.z == 3) && (side == 2))){
      newUVW.x = uvw.x;
    }else if(((uvw.z == 5) && (side >= 2)) || ((uvw.z == 2) && (side == 2)) || ((uvw.z == 3) && (side == 3))){
      newUVW.x = maxCoord - uvw.x;
    }else if(((uvw.z == 2) && (side == 0)) || ((uvw.z == 3) && (side == 1))){
      newUVW.x = uvw.y;
    }else if(((uvw.z == 2) && (side == 1)) || ((uvw.z == 3) && (side == 0))){
      newUVW.x = maxCoord - uvw.y;
    }else{
      newUVW.x = 0; // Should never happen
    }
    if((side <= 1) && ((uvw.z <= 1) || (uvw.z >= 4))){
      newUVW.y = uvw.y;
    }else if((uvw.z == 2) || ((uvw.z == 4) && (side == 3)) || ((uvw.z == 5) && (side == 2))){
      newUVW.y = 0;
    }else if((uvw.z == 3) || ((uvw.z == 4) && (side == 2)) || ((uvw.z == 5) && (side == 3))){
      newUVW.y = maxCoord;
    }else if(((uvw.z == 0) && (side == 3)) || ((uvw.z == 1) && (side == 2))){
      newUVW.y = uvw.x;
    }else if(((uvw.z == 0) && (side == 2)) || ((uvw.z == 1) && (side == 3))){
      newUVW.y = maxCoord - uvw.x;
    }else{
      newUVW.y = 0; // Should never happen
    }
    return newUVW; 
  }
  return uvw;
#else
  // TODO: Check if this is correct
  const int PX = 0, NX = 1, PY = 2, NY = 3, PZ = 4, NZ = 5; 
  //       +----+
  //       | PY |
  //  +----+----+----+----+
  //  | NX | PZ | PX | NZ |
  //  +----+----+----+----+
  //       | NY |
  //       +----+
  switch(uvw.z) {
    case 0:{
      // +X
      if(uv.x < 0){
        if(uv.y < 0){
          return ivec3(cubeSize - (uvw.y + 1), cubeSize - (uvw.x + 1), PY);
        }else if(uv.y >= cubeSize){
          return ivec3(uvw.y - cubeSize, cubeSize - (uvw.x + 1), NY);
        }else{
          return ivec3(cubeSize - (uvw.x + 1), uvw.y, PZ);
        }        
      }else if(uv.x >= cubeSize){
        if(uv.y < 0){
          return ivec3(cubeSize - (uvw.y + 1), uvw.x - cubeSize, PY);
        }else if(uv.y >= cubeSize){
          return ivec3(uvw.y - cubeSize, uvw.x - cubeSize, NY);
        }else{
          return ivec3(uvw.x - cubeSize, uvw.y, NZ);
        }
      }else{
        if(uv.y < 0){
          return ivec3(cubeSize - (uvw.y + 1), uvw.x, PY);
        }else if(uv.y >= cubeSize){
          return ivec3(uvw.y - cubeSize, uvw.x, NY);
        }else{
          return ivec3(uvw.x, uvw.y, PX);
        }
      }
    }
    case 1:{
      // -X
      if(uv.x < 0){
        if(uv.y < 0){
          return ivec3(cubeSize - (uvw.y + 1),uvw.x + cubeSize, PY);
        }else if(uv.y >= cubeSize){
          return ivec3(uvw.y - cubeSize, uvw.x + cubeSize, NY);
        }else{
          return ivec3(uvw.x + cubeSize, uvw.y, NZ);
        }        
      }else if(uv.x >= cubeSize){
        if(uv.y < 0){
          return ivec3(cubeSize - (uvw.y + 1), cubeSize - (uvw.x + 1), PY);
        }else if(uv.y >= cubeSize){
          return ivec3(uvw.y - cubeSize, cubeSize - (uvw.x + 1), NY);
        }else{
          return ivec3(cubeSize - (uvw.x + 1), uvw.y, PZ);
        }
      }else{
        if(uv.y < 0){
          return ivec3(cubeSize - (uvw.y + 1), uvw.x, PY);
        }else if(uv.y >= cubeSize){
          return ivec3(uvw.y - cubeSize, uvw.x, NY);
        }else{
          return ivec3(uvw.x, uvw.y, NX);
        }
      }
    }
    case 2:{
      // +Y
      if(uv.x < 0){
        if(uv.y < 0){
          return ivec3(cubeSize - (uvw.x + 1), cubeSize - (uvw.y + 1), PZ);
        }else if(uv.y >= cubeSize){
          return ivec3(cubeSize - (uvw.x + 1), uvw.y - cubeSize, NZ);
        }else{
          return ivec3(cubeSize - (uvw.x + 1), uvw.y, NX);
        }        
      }else if(uv.x >= cubeSize){
        if(uv.y < 0){
          return ivec3(uvw.x - cubeSize, cubeSize - (uvw.y + 1), PZ);
        }else if(uv.y >= cubeSize){
          return ivec3(uvw.x - cubeSize, uvw.y - cubeSize, NZ);
        }else{
          return ivec3(uvw.x - cubeSize, uvw.y, PX);
        }
      }else{
        if(uv.y < 0){
          return ivec3(uvw.x, cubeSize - (uvw.y + 1), PZ);
        }else if(uv.y >= cubeSize){
          return ivec3(uvw.x, uvw.y - cubeSize, NZ);
        }else{
          return ivec3(uvw.x, uvw.y, PY);
        }
      }
    }
    case 3:{
      // -Y
      if(uv.x < 0){
        if(uv.y < 0){
          return ivec3(cubeSize - (uvw.x + 1), cubeSize - (uvw.y + 1), NZ);
        }else if(uv.y >= cubeSize){
          return ivec3(cubeSize - (uvw.x + 1), uvw.y - cubeSize, PZ);
        }else{
          return ivec3(cubeSize - (uvw.x + 1), uvw.y, NX);
        }        
      }else if(uv.x >= cubeSize){
        if(uv.y < 0){
          return ivec3(uvw.x - cubeSize, cubeSize - (uvw.y + 1), NZ);
        }else if(uv.y >= cubeSize){
          return ivec3(uvw.x - cubeSize, uvw.y - cubeSize, PZ);
        }else{
          return ivec3(uvw.x - cubeSize, uvw.y, PX);
        }
      }else{
        if(uv.y < 0){
          return ivec3(uvw.x, cubeSize - (uvw.y + 1), NZ);
        }else if(uv.y >= cubeSize){
          return ivec3(uvw.x, uvw.y - cubeSize, PZ);
        }else{
          return ivec3(uvw.x, uvw.y, NY);
        }
      }
    }
    case 4:{
      // +Z
      if(uv.x < 0){
        if(uv.y < 0){
          return ivec3(cubeSize - (uvw.x + 1), cubeSize - (uvw.y + 1), PY);
        }else if(uv.y >= cubeSize){
          return ivec3(cubeSize - (uvw.x + 1), uvw.y - cubeSize, NY);
        }else{
          return ivec3(cubeSize - (uvw.x + 1), uvw.y, NX);
        }        
      }else if(uv.x >= cubeSize){
        if(uv.y < 0){
          return ivec3(uvw.x - cubeSize, cubeSize - (uvw.y + 1), PY);
        }else if(uv.y >= cubeSize){
          return ivec3(uvw.x - cubeSize, uvw.y - cubeSize, NY);
        }else{
          return ivec3(uvw.x - cubeSize, uvw.y, PX);
        }
      }else{
        if(uv.y < 0){
          return ivec3(uvw.x, cubeSize - (uvw.y + 1), PY);
        }else if(uv.y >= cubeSize){
          return ivec3(uvw.x, uvw.y - cubeSize, NY);
        }else{
          return ivec3(uvw.x, uvw.y, PZ);
        }
      }
    }
    case 5:{
      // -Z
      if(uv.x < 0){
        if(uv.y < 0){
          return ivec3(cubeSize - (uvw.x + 1), cubeSize - (uvw.y + 1), NY);
        }else if(uv.y >= cubeSize){
          return ivec3(cubeSize - (uvw.x + 1), uvw.y - cubeSize, PY);
        }else{
          return ivec3(cubeSize - (uvw.x + 1), uvw.y, NX);
        }        
      }else if(uv.x >= cubeSize){
        if(uv.y < 0){
          return ivec3(uvw.x - cubeSize, cubeSize - (uvw.y + 1), NY);
        }else if(uv.y >= cubeSize){
          return ivec3(uvw.x - cubeSize, uvw.y - cubeSize, PY);
        }else{
          return ivec3(uvw.x - cubeSize, uvw.y, PX);
        }
      }else{
        if(uv.y < 0){
          return ivec3(uvw.x, cubeSize - (uvw.y + 1), NY);
        }else if(uv.y >= cubeSize){
          return ivec3(uvw.x, uvw.y - cubeSize, PY);
        }else{
          return ivec3(uvw.x, uvw.y, NZ);
        }
      }
    }
    default:{
      return uvw; // Should never happen
    }
  }
#endif
}

vec4 textureManualBilinearCubeMap(in sampler2DArray tex,
                                  in vec3 direction,
                                  in float lod,
                                  in int cubeSize) {
  int faceIndex;
  vec2 uv = getCubeMapTexCoordAndFaceIndex(direction, faceIndex);
  uv *= float(cubeSize);
  ivec3 uvw00 = ivec3(floor(uv), faceIndex),
        uvw10 = seamlessCubeMapUVWWrap(uvw00 + ivec3(1, 0, 0), cubeSize),
        uvw01 = seamlessCubeMapUVWWrap(uvw00 + ivec3(0, 1, 0), cubeSize),
        uvw11 = seamlessCubeMapUVWWrap(uvw00 + ivec3(1, 1, 0), cubeSize);
  vec2 fuv = uv - vec2(uvw00.xy);
  return mix(mix(textureLod(tex, vec3(uvw00), lod),
                 textureLod(tex, vec3(uvw10), lod),
                 fuv.x),
             mix(textureLod(tex, vec3(uvw01), lod),
                 textureLod(tex, vec3(uvw11), lod),
                 fuv.x),
             fuv.y);
}

#endif