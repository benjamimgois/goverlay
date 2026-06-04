#ifndef DSFP_GLSL
#define DSFP_GLSL

// Double-single floating point, emulating double precision with two floats.

#define dsfp vec2 // x = high, y = low 

dsfp floatToDSFP(float f){
  dsfp result;
  result.x = f;
  result.y = f - result.x;
  return result;
}

float dsfpToFloat(dsfp a){
  return a.x + a.y;
}

dsfp dsfpAdd(dsfp a, dsfp b){
  dsfp result;
  float s = a.x + b.x;
  float v = s - a.x;
  float t = (((b.x - v) + (a.x - (s - v))) + a.y) + b.y;
  result.x = s + t;
  result.y = t - (result.x - s);
  return result;
}

dsfp dsfpSub(dsfp a, dsfp b){
  dsfp result;
  float s = a.x - b.x;
  float v = s - a.x;
  float t = ((((-b.x) - v) + (a.x - (s - v))) + a.y) - b.y;
  result.x = s + t;
  result.y = t - (result.x - s);
  return result;
}

dsfp dsfpMul(dsfp a, dsfp b){
  dsfp result;
  float c11 = a.x * b.x;
  float c21 = a.x * b.y;
  float c2 = a.y * b.x;
  float c3 = a.y * b.y;
  float t1 = c11;
  float t2 = c21 + c2;
  float t3 = c3;
  float t4 = t2 + t3;
  float t5 = t1 + t4;
  result.x = t5;
  result.y = t4 - (t5 - t1);
  return result;
}

dsfp dsfpDiv(dsfp a, dsfp b) {
  dsfp result;
  float q1 = a.x / b.x;
  dsfp bq1 = dsfpMul(b, dsfp(q1, 0.0));
  dsfp r = dsfpSub(a, bq1);
  float q2 = r.x / b.x;
  result.x = q1 + q2;
  result.y = r.x - (result.x * b.x);
  return result;
}

bool dfspEqual(dsfp a, dsfp b){
  return all(equal(a, b));
}

bool dfspNotEqual(dsfp a, dsfp b){
  return any(notEqual(a, b));
}

bool dfspLessThan(dsfp a, dsfp b){
  if(a.x < b.x){
    return true;
  } else if(a.x > b.x){
    return false;
  } else {
    return a.y < b.y;
  }
}

bool dfspLessThanEqual(dsfp a, dsfp b){
  if(a.x < b.x){
    return true;
  } else if(a.x > b.x){
    return false;
  } else {
    return a.y <= b.y;
  }
}

bool dfspGreaterThan(dsfp a, dsfp b){
  if(a.x > b.x){
    return true;
  } else if(a.x < b.x){
    return false;
  } else {
    return a.y > b.y;
  }
}

bool dfspGreaterThanEqual(dsfp a, dsfp b){
  if(a.x > b.x){
    return true;
  } else if(a.x < b.x){
    return false;
  } else {
    return a.y >= b.y;
  }
}

vec3 dsfpVec3FastTwoSum(vec3 hi, vec3 lo, out vec3 o){
  vec3 s = hi + lo;
  o = lo - (s - hi);
  return s;
}

vec3 dsfpVec3TwoSum(vec3 hi, vec3 lo, out vec3 o){
  vec3 s = hi + lo;
  vec3 v = s - hi;
  o = (hi - (s - v)) + (lo - v);
  return s;
}

vec3 dsfpVec3PreciseSum(vec3 ah, vec3 al, vec3 bh, vec3 bl){
  vec3 dh, dl;
  vec3 ch = dsfpVec3TwoSum(ah, bh, dh);
  vec3 cl = dsfpVec3TwoSum(al, bl, dl);
  vec3 chcldh = ch + (cl + dh);
  vec3 e = (cl + dh) - (chcldh - ch);
  return chcldh + (dl + e);
}

vec3 dsfpVec3PreciseSum(vec3 ah, vec3 al, vec3 bh, vec3 bl, out vec3 o){
  vec3 se, te;
  vec3 s = dsfpVec3TwoSum(ah, bh, se);
  vec3 t = dsfpVec3TwoSum(al, bl, te); 
  s = dsfpVec3FastTwoSum(s, se + t, se);
  return dsfpVec3FastTwoSum(s, se + te, o);
}

/* 

The packed matrix is a 4x4 matrix with the following layout:

affineXX, affineXY, affineXZ, fineX
affineYX, affineYY, affineYZ, fineY
affineZX, affineZY, affineZZ, fineZ
 coarseX,  coarseY,  coarseZ, 1.0
 
*/

vec4 dsfpTransformPosition(mat4 matrixPacked, vec4 vertexPosition){

  // [3][3] signals if the matrix is a normal matrix or a packed matrix.
  
  if(matrixPacked[3].w > 0.0){

    // When [3][3] are positive, we have normal matrices, so we can use the standard approach. 
    return matrixPacked * vertexPosition;  

  }else{

    // When [3][3] are negative, we have the packed matrices for double-single floating point matrices, so we 
    // need to use the precise sum approach. 

#if 0  

    // Reference slow 64-bit implementation for comparison.  

    dmat4 dMatrixPacked = dmat4(
      dvec4(matrixPacked[0].xyz, 0.0),
      dvec4(matrixPacked[1].xyz, 0.0),
      dvec4(matrixPacked[2].xyz, 0.0),
      dvec4(matrixPacked[3].xyz + dvec3(matrixPacked[0].w, matrixPacked[1].w, matrixPacked[2].w), 1.0)
    );
    dvec4 dVertexPosition = dvec4(vertexPosition);
    return vec4(dMatrixPacked * dVertexPosition);

#else
    
    // Faster 32-bit implementation using double-single floating point numbers.

    // Compute the affine (3x3) contribution.
    vec3 matrixAffine = (vertexPosition.x * matrixPacked[0].xyz) + (vertexPosition.y * matrixPacked[1].xyz) + (vertexPosition.z * matrixPacked[2].xyz);

    // The DSFP translation is split into two parts:
    //   - The coarse (high) part from the 4th row.
    //   - The fine (low) part from the 4th column of rows 0–2.
    vec3 matrixCoarse = vertexPosition.w * matrixPacked[3].xyz, matrixFine = vertexPosition.w * vec3(matrixPacked[0].w, matrixPacked[1].w, matrixPacked[2].w);

    // Compute the DSFP sum for the matrix transform.
    // Here, the DSFP number is represented as a high part (matrixHigh) and a low part (matrixLow).
    vec3 matrixLow, matrixHigh = dsfpVec3PreciseSum(matrixAffine, vec3(0.0), matrixCoarse, matrixFine, matrixLow);

    // --- Final Combination ---
    // Recombine the DSFP high and low parts into a single vec3.
    // (At this point you could also continue carrying both parts if your pipeline supports DSFP.)
    vec3 finalPosition = dsfpVec3FastTwoSum(matrixHigh, matrixLow, matrixLow); // final error is not propagated further

    return vec4(finalPosition, 1.0);

#endif

  }

} 

vec4 dsfpTransformPosition(mat4 modelPacked, mat4 viewPacked, vec4 vertexPosition){

  // [3][3] signals if the matrix is a normal matrix or a packed matrix.
  
  if((modelPacked[3].w > 0.0) && (viewPacked[3].w > 0.0)){

    // When [3][3] are positive, we have normal matrices, so we can use the standard approach. 
    return (viewPacked * modelPacked) * vertexPosition;  

  }else{

    // When [3][3] are negative, we have the packed matrices for double-single floating point matrices, so we 
    // need to use the precise sum approach. 

#if 0  

    // Reference slow 64-bit implementation for comparison.  

    dmat4 dModelPacked = dmat4(
      dvec4(modelPacked[0].xyz, 0.0),
      dvec4(modelPacked[1].xyz, 0.0),
      dvec4(modelPacked[2].xyz, 0.0),
      dvec4(modelPacked[3].xyz + dvec3(modelPacked[0].w, modelPacked[1].w, modelPacked[2].w), 1.0)
    );
    dmat4 dViewPacked = dmat4(
      dvec4(viewPacked[0].xyz, 0.0),
      dvec4(viewPacked[1].xyz, 0.0),
      dvec4(viewPacked[2].xyz, 0.0),
      dvec4(viewPacked[3].xyz + dvec3(viewPacked[0].w, viewPacked[1].w, viewPacked[2].w), 1.0)
    );
    dvec4 dVertexPosition = dvec4(vertexPosition);
    dmat4 dModelView = dViewPacked * dModelPacked;
    return vec4(dModelView * dVertexPosition);

#else
    
    // Faster 32-bit implementation using double-single floating point numbers.

    // Compute the affine (3x3) contribution.
    vec3 modelAffine = (vertexPosition.x * modelPacked[0].xyz) + (vertexPosition.y * modelPacked[1].xyz) + (vertexPosition.z * modelPacked[2].xyz);

    // The DSFP translation is split into two parts:
    //   - The coarse (high) part from the 4th row.
    //   - The fine (low) part from the 4th column of rows 0–2.
    vec3 modelCoarse = vertexPosition.w * modelPacked[3].xyz, modelFine = vertexPosition.w * vec3(modelPacked[0].w, modelPacked[1].w, modelPacked[2].w);

    // Compute the DSFP sum for the model transform.
    // Here, the DSFP number is represented as a high part (modelHigh) and a low part (modelLow).
    vec3 modelLow, modelHigh = dsfpVec3PreciseSum(modelAffine, vec3(0.0), modelCoarse, modelFine, modelLow);

    // --- View Transformation ---

    // Transform both the high and low parts through the view's 3x3 (affine) portion.
    vec3 viewAffineHigh = (modelHigh.x * viewPacked[0].xyz) + (modelHigh.y * viewPacked[1].xyz) + (modelHigh.z * viewPacked[2].xyz);
    vec3 viewAffineLow = (modelLow.x * viewPacked[0].xyz) + (modelLow.y * viewPacked[1].xyz) + (modelLow.z * viewPacked[2].xyz);

    // The view translation is similarly split into a coarse and fine part.
    vec3 viewCoarse = viewPacked[3].xyz, viewFine = vec3(viewPacked[0].w, viewPacked[1].w, viewPacked[2].w);

    // Combine the affine-transformed high and low parts with the view translation.
    vec3 viewLow, viewHigh = dsfpVec3PreciseSum(viewAffineHigh, viewAffineLow, viewCoarse, viewFine, viewLow);

    // --- Final Combination ---
    // Recombine the DSFP high and low parts into a single vec3.
    // (At this point you could also continue carrying both parts if your pipeline supports DSFP.)
    vec3 finalPosition = dsfpVec3FastTwoSum(viewHigh, viewLow, viewLow); // final error is not propagated further

    return vec4(finalPosition, 1.0);

#endif

  }

} 

// Clean the 4x4 matrix by removing the fine components, for direct usage after it.
mat4 dsfpMatrixClean(mat4 m){
  return mat4(vec4(m[0].xyz, 0.0), vec4(m[1].xyz, 0.0), vec4(m[2].xyz, 0.0), vec4(m[3].xyz, abs(m[3].w)));
}

#endif
