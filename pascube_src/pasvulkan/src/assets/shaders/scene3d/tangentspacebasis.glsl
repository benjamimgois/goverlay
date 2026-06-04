#ifndef TANGENTSPACEBASIS_GLSL
#define TANGENTSPACEBASIS_GLSL

vec3 getPerpendicularVector(in vec3 v){
#if 1
  uvec3 uyxzxzy = uvec3(ivec3(abs(v.xxy) - abs(v.yzz))) >> 31u;
  uvec3 xmymzm = uvec2(uyxzxzy.x & uyxzxzy.y, 0u).xyy;
  xmymzm.y = (1u ^ xmymzm.x) & uyxzxzy.z;
  xmymzm.z = 1u ^ (xmymzm.x & xmymzm.y);
  return (v.yzx * vec3(xmymzm.zxy)) - (v.zxy * vec3(xmymzm.yzx));
#else
  vec3 absV = abs(v);
  return (all(lessThan(absV.xx, absV.yz))) ? vec3(0.0, v.z, -v.y) : ((all(lessThan(absV.yy, absV.xz))) ? vec3(-v.z, 0.0, v.x) : vec3(v.y, -v.x, 0.0));
#endif
}

mat3x3 getSimpleTangentSpaceBasisFromNormal(in vec3 n){
  // A simple method to get a tangent space basis from a normal without any sudden changes in the basis, as it can be the case with other
  // on-first-sight more better methods.
  vec3 t = n.yzx - n.zxy, b = normalize(cross(n, t = normalize(t - dot(t, n))));
  return mat3x3(t, b, n); 
}

#define TBN_METHOD 1
void getTangentSpaceBasisFromNormal(in vec3 n, out vec3 t, out vec3 b){
#if TBN_METHOD == 0
  // Not the fastest, but it is a stable as well as a pretty simple method
  b = normalize(cross(n, t = normalize(n.zxy - dot(n.zxy, n))));
  t = normalize(cross(b, n));
#elif TBN_METHOD == 1
  // Revised frisvad, https://jcgt.org/published/0006/01/02/paper.pdf
  const double dthreshold = -0.9999999999776;
  const float rthreshold = -0.7;
  if(n.z >= rthreshold){
#if 1
    // Optimized version, by reducing to two products ( http://marc-b-reynolds.github.io/quaternions/2016/07/06/Orthonormal.html ) 
    float a = n.y / (1.0 + n.z),
          d = n.y * a,
          c = -n.x * a;
    t = normalize(vec3(n.z + d, c, -n.x));
    b = normalize(vec3(c, 1.0 - d, -n.y));
#else
    float a = 1.0 / (1.0 + n.z),
          c = -(n.x * n.y * a);
    t = normalize(vec3(1.0 - ((n.x * n.x) * a), c, -n.x));
    b = normalize(vec3(c, 1.0 - ((n.y * n.y) * a), -n.y));	
#endif
  }else{
    dvec3 dn = normalize(dvec3(n));
    if(dn.z >= dthreshold){
#if 1
    // Optimized version, by reducing to two products ( http://marc-b-reynolds.github.io/quaternions/2016/07/06/Orthonormal.html ) 
      double a = dn.y / (1.0 + dn.z),
             d = dn.y * a,
             c = -dn.x * a;
      t = vec3(dvec3(normalize(dvec3(dn.z + d, c, -dn.x))));
      b = vec3(dvec3(normalize(dvec3(c, 1.0 - d, -dn.y))));
#else
      float a = 1.0 / (1.0 + n.z),
            c = -(n.x * n.y * a);
      t = vec3(dvec3(normalize(vec3(1.0 - ((dn.x * dn.x) * a), c, -dn.x))));
      b = vec3(dvec3(normalize(vec3(c, 1.0 - ((dn.y * dn.y) * a), -dn.y))));	
#endif
    }else{
      // Handle the singularity case at n.z is near -1.0       
      // When n.z is almost -1.0, the Wolfram Language computation is as follows:
      // n = {0.0, 0.0, -1.0}; (since n.z is set to max(-0.999999, n.z))
      // n[[3]] = Max[-0.999999, n[[3]]];
      // a = n[[2]] / (1.0 + n[[3]]);
      // d = n[[2]] * a;
      // c = -n[[1]] * a;
      // t = Normalize[{n[[3]] + d, c, -n[[1]]}]; -> t = {-1.0, 0.0, 0.0};
      // b = Normalize[{c, 1.0 - d, -n[[2]]}]; -> b = {0.0, 1.0, 0.0};
      t = vec3(-1.0, 0.0, 0.0);
      b = vec3(0.0, 1.0, 0.0);
    }
  }    
#elif TBN_METHOD == 2
  // frisvad, http://orbit.dtu.dk/fedora/objects/orbit:113874/datastreams/file_75b66578-222e-4c7d-abdf-f7e255100209/
  // No sudden changes in the tangent space basis, but it has a singularity case at n.z is near -1.0
  if(n.z < -0.999805696){
    // Handle the singularity case at n.z is near -1.0 
    // When n.z is almost -1.0, the Wolfram Language computation is as follows:
    // n = {0.0, 0.0, -1.0}; (since n.z is set to max(-0.999999, n.z))
    // n[[3]] = Max[-0.999999, n[[3]]];
    // a = n[[2]] / (1.0 + n[[3]]);
    // d = n[[2]] * a;
    // c = -n[[1]] * a;
    // t = Normalize[{n[[3]] + d, c, -n[[1]]}]; -> t = {-1.0, 0.0, 0.0};
    // b = Normalize[{c, 1.0 - d, -n[[2]]}]; -> b = {0.0, 1.0, 0.0};
    t = vec2(-1.0, 0.0).xyy;
    b = vec2(0.0, 1.0).xyx;
  }else{
#if 1
    // Optimized version, by reducing to two products ( http://marc-b-reynolds.github.io/quaternions/2016/07/06/Orthonormal.html ) 
    float a = n.y / (1.0 + n.z),
          d = n.y * a,
          c = -n.x * a;
    t = normalize(vec3(n.z + d, c, -n.x));
    b = normalize(vec3(c, 1.0 - d, -n.y));
#else
    float a = 1.0 / (1.0 + n.z),
    c = -(n.x * n.y * a);
    t = normalize(vec3(1.0 - ((n.x * n.x) * a), c, -n.x));
    b = normalize(vec3(c, 1.0 - ((n.y * n.y) * a), -n.y));	
#endif
  }
#elif TBN_METHOD == 3
  // https://graphics.pixar.com/library/OrthonormalB/paper.pdf good, but it has sudden changes in the tangent space basis because of
  // the sign function, so it is not so good usable in my opinion as the paper authors claim, since I do need smooth transitions
  // between all input neuighboor normals, and that isn't the case with this method. 
  float s = (n.z >= 0.0) ? 1.0 : -1.0,
        a = -1.0 / (s + n.z),
        c = (n.x * n.y) * a;
  t = vec3((((s * (n.x * n.x))) * a) + 1.0, s * c, (-s) * n.x);
  b = vec3(c, ((n.y * n.y) * a) + s, -n.y);  
#elif TBN_METHOD == 4
  // No sudden changes as well, but computatlionally expensive because of the trigonometric functions as a argument against using this method
  //
  // The tangent and bitangent vectors are derived from the surface normal using spherical coordinates.
  //
  // The surface normal is assumed to be normalized and represented as 'normal', where its components are (x, y, z).
  // The spherical coordinates (theta, phi) are derived from the normal.
  // Theta is the angle from the z-axis, calculated using asin(normal.y).
  // Phi is the angle from the x-axis in the xy-plane, calculated using atan(normal.z, normal.x).
  // To get the tangent (T), we calculate the partial derivative of P with respect to phi (∂P/∂phi),
  // which, after simplification (ignoring the radius r), gives us T = (-sin(phi), 0, cos(phi)).
  // For the bitangent (B), we calculate the partial derivative of P with respect to theta (∂P/∂theta),
  // which simplifies to B = (cos(theta)cos(phi), -sin(theta), cos(theta)sin(phi)).
  //
  // Or more in detail:
  //
  // The tangent (T) and bitangent (B) are calculated using the derivatives of spherical coordinates.
  //
  // For a point P on a sphere, expressed in spherical coordinates (r, theta, phi), where:
  // Px = r * cos(theta) * cos(phi)
  // Py = r * sin(theta)
  // Pz = r * cos(theta) * sin(phi)
  //
  // The tangent T is obtained by differentiating P with respect to phi:
  // T = ∂P/∂phi = vec3(-r * cos(theta) * sin(phi), 0, r * cos(theta) * cos(phi))
  // After normalizing and ignoring the radius r (since it cancels out), we have:
  // T = vec3(-sin(phi), 0, cos(phi))
  //
  // Similarly, the bitangent B is obtained by differentiating P with respect to theta:
  // B = ∂P/∂theta = vec3(-r * sin(theta) * cos(phi), r * cos(theta), -r * sin(theta) * sin(phi))
  // Again, normalizing and ignoring r gives us:
  // B = vec3(-sin(theta) * cos(phi), cos(theta), -sin(theta) * sin(phi))
  //
#if 1
  // Optimized variant
  vec4 sinCosThetaPhi = sin(vec4(vec2(atan(n.z, n.x), asin(n.y)).xxyy + vec2(0.0, 1.5707963267948966).xyxy));
  t = normalize(vec3(sinCosThetaPhi.x * sinCosThetaPhi.w, 0.0, -sinCosThetaPhi.y * sinCosThetaPhi.w));
  b = normalize(vec3(sinCosThetaPhi.y * sinCosThetaPhi.z, -sinCosThetaPhi.w, sinCosThetaPhi.x * sinCosThetaPhi.z));
#else
  // Readable variant 
  float theta = atan(n.z, n.x), phi = asin(n.y);
  t = normalize(vec3(sin(theta) * cos(phi),
                     0.0,
                     -cos(theta) * cos(phi)));
  b = normalize(vec3(cos(theta) * sin(phi),
                     -cos(phi),
                     sin(theta) * sin(phi)));
#endif
//t = normalize(cross(normalize(b - (dot(b, n) * n)), n));
//b = normalize(cross(n, t));
#elif TBN_METHOD == 5
  // This alternative method calculates the tangent and bitangent vectors without using trigonometry,
  // which is a common technique in real-time graphics to avoid costly computations.
  // The cross product is used to generate vectors that are perpendicular to each other and the original normal.
  // First, the tangent vector is found by crossing the 'up' vector of the world (0, 1, 0) with the normal.
  // This gives a vector that is perpendicular to both the 'up' vector and the normal, lying in the plane of the surface.
  // This operation assumes that the normal is not parallel to the 'up' vector; if it is, the cross product will be zero,
  // and another non-parallel vector should be chosen as the 'up' vector, for example (0, 0, 1).
  // After finding the tangent, the bitangent is calculated as the cross product of the normal and the tangent.
  // This produces a vector that is perpendicular to both the normal and the tangent, completing the orthogonal triad.
  // The resulting tangent and bitangent are then normalized to ensure they are unit vectors.
  // This method ensures that the tangent, bitangent, and normal are all orthogonal to each other,
  // which is necessary for correct per-pixel lighting and texture mapping in shading languages.
  // Note that this method assumes a right-handed coordinate system.
  // If a left-handed system is used, the order of the cross product should be reversed to maintain the handedness.
  t = normalize(cross((abs(n.y) < 0.999999) ? vec3(0.0, 1.0, 0.0) : vec3(0.0, 0.0, 1.0), n));
  b = normalize(cross(n, t));
#else 
  #error "TBN_METHOD not defined"
#endif
}

mat3 getTangentSpaceFromNormal(vec3 n){
  n = normalize(n);
  vec3 t, b;
  getTangentSpaceBasisFromNormal(n, t, b);
  return mat3(t, b, n);
}  

#endif
