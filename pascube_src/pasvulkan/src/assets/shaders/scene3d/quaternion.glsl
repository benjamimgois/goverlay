#ifndef QUATERNION_GLSL
#define QUATERNION_GLSL

vec4 matrixToQuaternion(const in mat3 m){  
  float t = m[0][0] + (m[1][1] + m[2][2]);
  vec4 q;
  if(t > 2.9999999){
    q = vec4(0.0, 0.0, 0.0, 1.0);
  }else if(t > 0.0000001){
    float s = sqrt(1.0 + t) * 2.0;
    q = vec4(vec3(m[1][2] - m[2][1], m[2][0] - m[0][2], m[0][1] - m[1][0]) / s, s * 0.25);
  }else if((m[0][0] > m[1][1]) && (m[0][0] > m[2][2])){
    float s = sqrt(1.0 + (m[0][0] - (m[1][1] + m[2][2]))) * 2.0;
    q = vec4(s * 0.25, vec3(m[1][0] + m[0][1], m[2][0] + m[0][2], m[1][2] - m[2][1]) / s);    
  }else if(m[1][1] > m[2][2]){
    float s = sqrt(1.0 + (m[1][1] - (m[0][0] + m[2][2]))) * 2.0;
    q = vec4(vec3(m[1][0] + m[0][1], m[2][1] + m[1][2], m[2][0] - m[0][2]) / s, s * 0.25).xwyz;
  }else{
    float s = sqrt(1.0 + (m[2][2] - (m[0][0] + m[1][1]))) * 2.0;
    q = vec4(vec3(m[2][0] + m[0][2], m[2][1] + m[1][2], m[0][1] - m[1][0]) / s, s * 0.25).xywz; 
  }
  return normalize(q); 
}

mat3 quaternionToMatrix(vec4 q){  
  q = normalize(q);
  float qx2 = q.x + q.x,
        qy2 = q.y + q.y,
        qz2 = q.z + q.z,
        qxqx2 = q.x * qx2,
        qxqy2 = q.x * qy2,
        qxqz2 = q.x * qz2,
        qxqw2 = q.w * qx2,
        qyqy2 = q.y * qy2,
        qyqz2 = q.y * qz2,
        qyqw2 = q.w * qy2,
        qzqz2 = q.z * qz2,
        qzqw2 = q.w * qz2;
  return mat3(1.0 - (qyqy2 + qzqz2), qxqy2 + qzqw2, qxqz2 - qyqw2,
              qxqy2 - qzqw2, 1.0 - (qxqx2 + qzqz2), qyqz2 + qxqw2,
              qxqz2 + qyqw2, qyqz2 - qxqw2, 1.0 - (qxqx2 + qyqy2));
}              

vec4 quaternionSlerp(vec4 q0, vec4 q1, float t){
  float co = dot(q0, q1), so, s0, s1, s2 = 1.0, Omega;
  if(co < 0.0){
    co = -co;
    s2 = -s2;
  };
  if((1.0 - co) > 1e-8){
    Omega = acos(co);
    so = sin(Omega);
    s0 = sin((1.0 - t) * Omega) / so;
    s1 = sin(t * Omega) / so;
  }else{
    s0 = 1.0 - t;
    s1 = t;
  }
  return (q0 * s0) + (q1 * (s1 * s2));
}

vec4 quaternionConjugate(vec4 q){
  return vec4(-q.xyz, q.w);
}

vec4 quaternionInverse(vec4 q){
  return vec4(-q.xyz, q.w) / length(q);
}

float quaternionLength(vec4 q){
  return length(q);
}

vec4 quaternionNormalize(vec4 q){
  return normalize(q);
}

vec4 quaternionMul(vec4 a, vec4 b){
 return vec4(cross(a.xyz, b.xyz) + (a.xyz * b.w) + (b.xyz * a.w), (a.w * b.w) - dot(a.xyz, b.xyz));
}

vec4 quaternionRotateByAngle(vec4 q, vec3 angle){
  float angleScalar = length(angle);
  return (angleScalar < 1e-5) ? q : quaternionMul(q, vec4(angle * (sin(angleScalar * 0.5) / angleScalar), cos(angleScalar * 0.5)));
}

vec3 transformVectorByQuaternion(vec3 v, vec4 q){
#if 0
  vec3 t = cross(q.xyz, v) * 2.0;
  return v + fma(t, vec3(q.w), cross(q.xyz, t));
#else
//return v + (2.0 * cross(q.xyz, cross(q.xyz, v) + (q.w * v)));
  return fma(cross(q.xyz, fma(v, vec3(q.w), cross(q.xyz, v))), vec3(2.0), v);
#endif 
}

vec4 transformVectorByQuaternion(vec4 v, vec4 q){
  return vec4(transformVectorByQuaternion(v.xyz, q), v.w);
}

vec4 quaternionFromToRotation(vec3 from, vec3 to){
  return vec4(cross(normalize(from), normalize(to)), sqrt(dot(from, from) * dot(to, to)) + dot(from, to));
}

vec4 quaternionFromAxisAngle(vec4 v){
  return normalize(vec4(vec4(v.xyz, 1.0) * sin(vec2(v.w * 0.5) + vec2(0.0, 1.5707963267948966)).xxxy));
}

vec4 quaternionToAxisAngle(vec4 q){
  q = normalize(q);
  float sinAngle = sqrt(1.0 - (q.w * q.w));
  return vec4(q.xyz / ((abs(sinAngle) < 1e-12) ? 1.0 : sinAngle), 2.0 * acos(q.w));
}
                         
// X = Pitch, Y = Yaw, Z = Roll              
vec4 quaternionFromEuler(vec3 pyr){
  // Order of rotations: Roll (Z), Pitch (X), Yaw (Y)
  vec2 psc = sin(vec2(pyr.x * 0.5) + vec2(0.0, 1.5707963267948966)); 
  vec2 ysc = sin(vec2(pyr.y * 0.5) + vec2(0.0, 1.5707963267948966)); 
  vec2 rsc = sin(vec2(pyr.z * 0.5) + vec2(0.0, 1.5707963267948966));   
  return normalize(vec4((psc.x * ysc.y * rsc.y) + (psc.y * ysc.x * rsc.x),
                        (psc.y * ysc.x * rsc.y) - (psc.x * ysc.y * rsc.x),
                        (psc.y * ysc.y * rsc.x) - (psc.x * ysc.x * rsc.y),
                        (psc.y * ysc.y * rsc.y) + (psc.x * ysc.x * rsc.x)));
}                                              

vec3 quaternionToEuler(vec4 q){
  q = normalize(q);
  float t = 2.0 * ((q.x * q.w) - (q.y * q.z));
  return (t < -0.995) 
           ? vec3(-1.5707963267948966, 
                  0.0, 
                  -atan(2.0 * ((q.x * q.z) - (q.y * q.w)), 1.0 - (2.0 * ((q.y * q.y) + (q.z * q.z)))))
           : ((t > 0.995)
                ? vec3(1.5707963267948966, 
                       0.0,  
                       atan(2.0 * ((q.x * q.z) - (q.y * q.w)), 1.0 - (2.0 * ((q.y * q.y) + (q.z * q.z)))))
                : vec3(asin(t), 
                       atan(2.0*((q.x * q.z) + (q.y * q.w)), 1.0 - (2.0 * ((q.x * q.x) + (q.y * q.y)))), 
                       atan(2.0*((q.x * q.y) + (q.z * q.w)), 1.0 - (2.0 * ((q.x * q.x) + (q.z * q.z)))))
             );
}

vec4 quaternionFromShortestArcRotation(vec3 from, vec3 to){
  from = normalize(from);
  to = normalize(to);
  return vec4(cross(from, to), dot(from, to));
}

vec4 packQuaternionToRGB10A2(vec4 q){
  vec4 qAbs = abs(q = normalize(q));
  int maxComponentIndex = (qAbs.x > qAbs.y) ? ((qAbs.x > qAbs.z) ? ((qAbs.x > qAbs.w) ? 0 : 3) : ((qAbs.z > qAbs.w) ? 2 : 3)) : ((qAbs.y > qAbs.z) ? ((qAbs.y > qAbs.w) ? 1 : 3) : ((qAbs.z > qAbs.w) ? 2 : 3)); 
  q = mix(q, -q, float(q[maxComponentIndex] < 0.0));
  q = vec4[4](q.yzwx, q.xzwy, q.xywz, q.xyzw)[maxComponentIndex]; 
  return vec4(fma(q.xyz * sign(q.w), vec3(0.7071067811865476),vec3(0.5)), float(maxComponentIndex) / 3.0);
}

vec4 unpackQuaternionFromRGB10A2(vec4 q){
  vec4 r = vec4(fma(q.xyz, vec3(1.4142135623730951), vec3(-0.7071067811865475)), 0.0);
  r.w = sqrt(1.0 - clamp(dot(r.xyz, r.xyz), 0.0, 1.0));
  return normalize(vec4[4](r.wxyz, r.xwyz, r.xywz, r.xyzw)[int(q.w * 3.0)]);
}

vec4 packQTangent(mat3 m, const in float threshold){
  //const float threshold = 1.0 / 127.0; 
  const float renormalization = sqrt(1.0 - (threshold * threshold));
  float t = m[0][0] + (m[1][1] + m[2][2]);
  vec4 q;
  if(t > 2.9999999){
    q = vec4(0.0, 0.0, 0.0, 1.0);
  }else if(t > 0.0000001){
    float s = sqrt(1.0 + t) * 2.0;
    q = vec4(vec3(m[1][2] - m[2][1], m[2][0] - m[0][2], m[0][1] - m[1][0]) / s, s * 0.25);
  }else if((m[0][0] > m[1][1]) && (m[0][0] > m[2][2])){
    float s = sqrt(1.0 + (m[0][0] - (m[1][1] + m[2][2]))) * 2.0;
    q = vec4(s * 0.25, vec3(m[1][0] + m[0][1], m[2][0] + m[0][2], m[1][2] - m[2][1]) / s);    
  }else if(m[1][1] > m[2][2]){
    float s = sqrt(1.0 + (m[1][1] - (m[0][0] + m[2][2]))) * 2.0;
    q = vec4(vec3(m[1][0] + m[0][1], m[2][1] + m[1][2], m[2][0] - m[0][2]) / s, s * 0.25).xwyz;
  }else{
    float s = sqrt(1.0 + (m[2][2] - (m[0][0] + m[1][1]))) * 2.0;
    q = vec4(vec3(m[2][0] + m[0][2], m[2][1] + m[1][2], m[0][1] - m[1][0]) / s, s * 0.25).xywz; 
  }
  q = normalize(q); 
  q = mix(q, -q, float(q.w < 0.0));
  q = mix(q, vec4(q.xyz * renormalization, threshold), float(q.w < threshold));
  return mix(q, -q, float(dot(cross(m[0], m[2]), m[1]) <= 0.0)); 
}

mat3 unpackQTangent(vec4 q){
  q = normalize(q); 
  float qx2 = q.x + q.x,
        qy2 = q.y + q.y,
        qz2 = q.z + q.z,
        qxqx2 = q.x * qx2,
        qxqy2 = q.x * qy2,
        qxqz2 = q.x * qz2,
        qxqw2 = q.w * qx2,
        qyqy2 = q.y * qy2,
        qyqz2 = q.y * qz2,
        qyqw2 = q.w * qy2,
        qzqz2 = q.z * qz2,
        qzqw2 = q.w * qz2;
  vec3 tangent = vec3(1.0 - (qyqy2 + qzqz2), qxqy2 + qzqw2, qxqz2 - qyqw2);
  vec3 normal = vec3(qxqz2 + qyqw2, qyqz2 - qxqw2, 1.0 - (qxqx2 + qyqy2));
  return mat3(tangent, cross(tangent, normal) * sign(q.w), normal);
} 


#endif