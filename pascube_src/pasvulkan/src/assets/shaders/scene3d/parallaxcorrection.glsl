#ifndef PARALLAXCORRECTION_GLSL
#define PARALLAXCORRECTION_GLSL

vec3 getParallaxCorrectedRayDirectionMethod0(vec3 rayDirection, vec3 fragmentWorldPosition, vec3 cameraWorldPosition){
  return rayDirection;
}

vec3 getParallaxCorrectedRayDirectionMethod1(vec3 rayDirection, vec3 fragmentWorldPosition, vec3 cameraWorldPosition){
    
  // The most straightforward way to do parallax correction is to adjust the reflection vector based on the relative positions of the 
  // fragment and the camera. This adjustment will be based on how the view direction intersects with the virtual "bounding box" of the cubemap.
  // Given that a cubemap is, conceptually, a bounding box surrounding the scene, we can think of the parallax correction as finding the intersection 
  // of the view direction with this bounding box and using that point to adjust the reflection vector. Here's an approach to do this:

  // Calculate the normalized view direction, which is the direction from the camera to the fragment.
  vec3 viewDirection = normalize(fragmentWorldPosition - cameraWorldPosition);
  
  // Compute the offset between the view direction and the original reflection direction.
  // This offset represents how much the reflection direction should be adjusted to account for the viewer's position.
  vec3 offset = viewDirection - rayDirection;
  
  // Apply the offset to the original reflection direction to get the parallax-corrected reflection direction.
  vec3 parallaxCorrectedRayDirection = rayDirection + offset;

  return normalize(parallaxCorrectedRayDirection);

}

vec3 getParallaxCorrectedRayDirectionMethod2(vec3 rayDirection, vec3 fragmentWorldPosition, vec3 cameraWorldPosition){

  // Another approach to parallax correction is to compute the reflection direction as usual and then adjust it based on the relative positions of the
  // fragment and the camera. This adjustment will be based on how the reflection direction intersects with the virtual "bounding box" of the cubemap.
  // Given just the fragment position, camera position, and reflection direction, we can only apply a general parallax correction, assuming a virtual 
  // "bounding box" around the scene. Here's an approach to do this:

  // Normalize the input reflection direction
  vec3 normalizedRayDirection = normalize(rayDirection);

  // Compute the view direction, which is the direction from the camera to the fragment
  vec3 viewDirection = fragmentWorldPosition - cameraWorldPosition;
  
  // Create a vector perpendicular to the reflection direction and the view direction.
  vec3 perpendicularVector = cross(normalizedRayDirection, viewDirection);
  
  // Create another vector perpendicular to the reflection direction and the first perpendicular vector.
  vec3 correctionVector = cross(perpendicularVector, normalizedRayDirection);
  
  // Use the magnitude of the view direction to apply the parallax correction.
  float parallaxMagnitude = length(viewDirection) * 0.5;  // The scale factor (0.5) can be adjusted.
  
  // Apply the parallax correction to the reflection direction.
  // The reflection direction is shifted by a fraction of the parallax-reflected direction.
  vec3 parallaxCorrectedRayDirection = normalizedRayDirection + (correctionVector * parallaxMagnitude);

  return normalize(parallaxCorrectedRayDirection);

}

vec3 getParallaxCorrectedRayDirectionMethod3(vec3 rayDirection, vec3 fragmentWorldPosition, vec3 cameraWorldPosition, vec3 localSurfaceNormal){
  
  // Normalize the input reflection direction
  vec3 normalizedRayDirection = normalize(rayDirection);
  
  // Compute the view direction, which is the direction from the camera to the fragment
  vec3 viewDirection = fragmentWorldPosition - cameraWorldPosition;
  
  // Calculate the halfway vector between the view direction and the reflection direction.
  // This is often used in shading models, especially for specular reflections.
  vec3 halfwayVector = normalize(viewDirection + normalizedRayDirection);
  
  // Compute the reflection of the view direction about the local surface normal.
  // This would be the reflection vector if the surface was a perfect mirror.
  vec3 parallaxRayDirection = reflect(viewDirection, localSurfaceNormal);
  
  // Compute a scale factor based on the angle between the halfway vector and the local surface normal.
  // The dot product here effectively measures the cosine of the angle between the two vectors.
  // This factor will be used to adjust the reflection direction based on the viewer's position.
  float parallaxScaleFactor = 0.5 * dot(halfwayVector, localSurfaceNormal);
  
  // Apply the parallax correction to the reflection direction.
  // The reflection direction is shifted by a fraction of the parallax-reflected direction.
  vec3 parallaxCorrectedRayDirection = normalizedRayDirection + (parallaxRayDirection * parallaxScaleFactor);
  
  // Return the normalized parallax-corrected reflection direction.
  return normalize(parallaxCorrectedRayDirection);

}

vec3 getCubeParallaxCorrectedRayDirection(const in vec3 rayDirection, const in vec3 fragmentWorldPosition, const in vec3 probeAABBMin, const in vec3 probeAABBMax){
  vec3 furthestPlane = max(
    (probeAABBMin - fragmentWorldPosition) / rayDirection, 
    (probeAABBMax - fragmentWorldPosition) / rayDirection
  );
  return normalize(fma(rayDirection, vec3(min(furthestPlane.x, min(furthestPlane.y, furthestPlane.z))), fragmentWorldPosition) - mix(probeAABBMin, probeAABBMax, 0.5));
}

vec3 getUnitSphereParallaxCorrectedRayDirection(const in vec3 rayDirection, const in vec3 fragmentWorldPosition, const in vec4 probeSphere){
  vec3 v = fragmentWorldPosition - probeSphere.xyz;
  float a = dot(rayDirection, rayDirection), 
        b = dot(rayDirection, v),
        c = dot(v, v) - (probeSphere.w * probeSphere.w),
        determinant = (b * b) - (a * c),
        dist = (determinant >= 0.0) ? ((sqrt(determinant) - b) / a) : 1e15;
  return normalize(fma(rayDirection, vec3(dist), fragmentWorldPosition) - probeSphere.xyz);
}

#endif