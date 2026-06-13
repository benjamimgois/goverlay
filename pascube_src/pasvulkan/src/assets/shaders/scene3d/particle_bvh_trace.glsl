#ifndef PARTICLE_BVH_TRACE_GLSL
#define PARTICLE_BVH_TRACE_GLSL

// Descriptor-FREE software traversal of the per-frame GPU particle LBVH, used to inject particles (not in the hardware
// ray-tracing BLAS) into a renderer's lighting. Technique-neutral: a consumer only needs the two buffer device addresses + the
// particle count (however it obtains them — push constant, UBO, a master buffer). No shared descriptor set/binding contract,
// so the DDGI trace (now) and a pure-path-tracing path (later) reuse the exact same code. Requires GL_EXT_buffer_reference(+
// _uvec2) and the structs from particle_bvh.glsl (included WITHOUT PARTICLE_BVH_BINDINGS).

layout(buffer_reference, std430, buffer_reference_align = 16) readonly buffer ParticleBVHEmitterRef {
  ParticleEmitter emitters[];
};
layout(buffer_reference, std430, buffer_reference_align = 16) readonly buffer ParticleBVHNodeRef {
  ParticleBVHNode nodes[];
};

// Ray-sphere (rd assumed normalized): outputs the near intersection distance; true if the sphere overlaps [tMin, tMax].
bool particleBVHRaySphere(vec3 ro, vec3 rd, vec3 c, float r, float tMin, float tMax, out float tNear){
  vec3 oc = ro - c;
  float b = dot(oc, rd);
  float cc = dot(oc, oc) - (r * r);
  float disc = (b * b) - cc;
  if(disc < 0.0){
    tNear = tMax;
    return false;
  }else{
    float sq = sqrt(disc);
    float t0 = -b - sq;
    float t1 = -b + sq;
    tNear = t0;
    return (t1 >= tMin) && (t0 <= tMax);
  }
}

bool particleBVHRayAABB(vec3 ro, vec3 invRd, vec3 bmin, vec3 bmax, float tMin, float tMax){
  vec3 ta = (bmin - ro) * invRd;
  vec3 tb = (bmax - ro) * invRd;
  vec3 tsmall = min(ta, tb);
  vec3 tbig = max(ta, tb);
  float tn = max(max(tsmall.x, tsmall.y), max(tsmall.z, tMin));
  float tf = min(min(tbig.x, tbig.y), min(tbig.z, tMax));
  return tn <= tf;
}

// Nearest opaque-particle hit distance in [tMin, tMaxIn]; returns tMaxIn (and zero emission) if none is hit.
float particleBVHClosestOpaque(ParticleBVHNodeRef nodeRef, ParticleBVHEmitterRef emitterRef,
                               vec3 ro, vec3 rd, float tMin, float tMaxIn, uint n, out vec3 emission){
  emission = vec3(0.0);
  float best = tMaxIn;
  if(n == 0u){
    return best;
  }
  vec3 invRd = vec3(1.0) / rd;
  uint stack[64];
  int sp = 0;
  stack[sp++] = 0u;
  while(sp > 0){
    uint ni = stack[--sp];
    ParticleBVHNode node = nodeRef.nodes[ni];
    if(ni >= (n - 1u)){
      uint prim = floatBitsToUint(node.aabbMin.w);
      ParticleEmitter e = emitterRef.emitters[prim];
      if(e.emissionType.w > 0.5){ // opaque
        float tn;
        if(particleBVHRaySphere(ro, rd, e.positionRadius.xyz, e.positionRadius.w, tMin, best, tn)){
          float t = max(tn, tMin);
          if(t < best){
            best = t;
            emission = e.emissionType.xyz;
          }
        }
      }
    }else{
      if(particleBVHRayAABB(ro, invRd, node.aabbMin.xyz, node.aabbMax.xyz, tMin, best)){
        if(sp < 63){ stack[sp++] = floatBitsToUint(node.aabbMin.w); }
        if(sp < 63){ stack[sp++] = floatBitsToUint(node.aabbMax.w); }
      }
    }
  }
  return best;
}

// Sum of additive (transparent) particle emission over [tMin, tMax] (no occlusion among them).
vec3 particleBVHAdditiveEmission(ParticleBVHNodeRef nodeRef, ParticleBVHEmitterRef emitterRef,
                                 vec3 ro, vec3 rd, float tMin, float tMax, uint n){
  vec3 sum = vec3(0.0);
  if(n == 0u){
    return sum;
  }
  vec3 invRd = vec3(1.0) / rd;
  uint stack[64];
  int sp = 0;
  stack[sp++] = 0u;
  while(sp > 0){
    uint ni = stack[--sp];
    ParticleBVHNode node = nodeRef.nodes[ni];
    if(ni >= (n - 1u)){
      uint prim = floatBitsToUint(node.aabbMin.w);
      ParticleEmitter e = emitterRef.emitters[prim];
      if(e.emissionType.w <= 0.5){ // additive
        float tn;
        if(particleBVHRaySphere(ro, rd, e.positionRadius.xyz, e.positionRadius.w, tMin, tMax, tn)){
          sum += e.emissionType.xyz;
        }
      }
    }else{
      if(particleBVHRayAABB(ro, invRd, node.aabbMin.xyz, node.aabbMax.xyz, tMin, tMax)){
        if(sp < 63){
          stack[sp++] = floatBitsToUint(node.aabbMin.w);
        }
        if(sp < 63){
          stack[sp++] = floatBitsToUint(node.aabbMax.w);
        }
      }
    }
  }
  return sum;
}

#endif // PARTICLE_BVH_TRACE_GLSL
