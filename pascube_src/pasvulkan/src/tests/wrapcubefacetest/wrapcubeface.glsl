
const int FACE_POS_X = 0;
const int FACE_NEG_X = 1;
const int FACE_POS_Y = 2;
const int FACE_NEG_Y = 3;
const int FACE_POS_Z = 4;
const int FACE_NEG_Z = 5;

ivec3 wrapCubeFace(ivec3 uvw, int faceSize){

  // This function repeatedly adjusts the face [f] and the coordinates [x, y] until the coordinates [x, y] are 
  // within the bounds of the cube face [0, faceSize]. This approach naturally supports multiple successive folds 
  // across different faces, including diagonal transitions, without needing to handle diagonal transition cases 
  // separately.

  while(any(lessThan(uvw.xy, ivec2(0))) || any(greaterThanEqual(uvw.xy, ivec2(faceSize)))){
    
    ivec3 old = uvw;
    
    switch(uvw.z){
      case FACE_POS_X:{ // X+ face
        if(uvw.x < 0){ // Z+ - moved off the left edge of X+ → onto Z+’s left edge
          uvw.z = FACE_POS_Z;
          uvw.x += faceSize;   
        }else if(uvw.x >= faceSize){ // Z- - moved off the right edge of X+ → onto Z-’s right edge
          uvw.z = FACE_NEG_Z;
          uvw.x -= faceSize;
        }else if(uvw.y < 0){ // Y+ - moved off the top of X+ → onto Y+’s right edge
          uvw.z = FACE_POS_Y;
          uvw.x = faceSize + old.y;
          uvw.y = faceSize - (old.x + 1);
        }else if(uvw.y >= faceSize){ // Y- - moved off the bottom of X+ → onto Y-’s right edge
          uvw.z = FACE_NEG_Y;              
          uvw.x = faceSize - ((old.y - faceSize) + 1);
          uvw.y = old.x;  
        }
        break;
      }
      
      case FACE_NEG_X:{ // X- face
        if(uvw.x < 0){ // Z- - moved off the left of X- → onto Z-’s left edge
          uvw.z = FACE_NEG_Z;
          uvw.x += faceSize;
        }else if(uvw.x >= faceSize){ // Z+ - moved off the right of X- → onto Z+’s right edge
          uvw.z = FACE_POS_Z;   
          uvw.x -= faceSize;
        }else if(uvw.y < 0){ // Y+ - moved off the top of X- → onto Y+’s left edge
          uvw.z = FACE_POS_Y;   
          uvw.x = -(old.y + 1);
          uvw.y = old.x;
        }else if(uvw.y >= faceSize){ // Y- - moved off the bottom of X- → onto Y-’s left edge
          uvw.z = FACE_NEG_Y;  
          uvw.x = old.y - faceSize;
          uvw.y = faceSize - (old.x + 1);
        }
        break;
      }
      
      case FACE_POS_Y:{ // Y+ face
        if(uvw.x < 0){ // X- - moved off the left of Y+ → onto X-’s top edge
          uvw.z = FACE_NEG_X;   
          uvw.x = old.y;            
          uvw.y = -(old.x + 1);
        }else if(uvw.x >= faceSize){ // X+ - moved off the right of Y+ → onto X+’s top edge
          uvw.z = FACE_POS_X;   
          uvw.x = faceSize - (old.y + 1);
          uvw.y = old.x - faceSize;
        }else if(uvw.y < 0){ // Z- - moved off the top of Y+ → onto Z-’s top edge
          uvw.z = FACE_NEG_Z;   
          uvw.x = faceSize - (old.x + 1);
          uvw.y = -(old.y + 1);
        }else if(uvw.y >= faceSize){ // Z+ - moved off the bottom of Y+ → onto Z+’s top edge
          uvw.z = FACE_POS_Z;   
          uvw.y -= faceSize;
        }
        break;
      }
      
      case FACE_NEG_Y:{ // Y- face
        if(uvw.x < 0){ // X- - moved off the left of Y- → onto X-’s bottom edge
          uvw.z = FACE_NEG_X;  
          uvw.x = faceSize - (old.y + 1);
          uvw.y = faceSize + old.x;
        }else if(uvw.x >= faceSize){ // X+ - moved off the right of Y- → onto X+’s bottom edge
          uvw.z = FACE_POS_X;
          uvw.x = old.y;
          uvw.y = faceSize - ((old.x - faceSize) + 1);
        }else if(uvw.y < 0){ // Z+ - moved off the top of Y- → onto Z+’s bottom edge
          uvw.z = FACE_POS_Z; 
          uvw.y += faceSize;
        }else if(uvw.y >= faceSize){ // Z- - moved off the bottom of Y- → onto Z-’s bottom edge
          uvw.z = FACE_NEG_Z;
          uvw.x = faceSize - (old.x + 1);
          uvw.y = faceSize - ((old.y - faceSize) + 1);
        }
        break;
      }
      
      case FACE_POS_Z:{ // Z+ face
        if(uvw.x < 0){ // X- - moved off the left of Z+ → onto X-’s right edge
          uvw.z = FACE_NEG_X; 
          uvw.x += faceSize;
        }else if(uvw.x >= faceSize){ // X+ - moved off the right of Z+ → onto X+’s left edge
          uvw.z = FACE_POS_X;
          uvw.x -= faceSize;
        }else if(uvw.y < 0){ // Y+ - moved off the top of Z+ → onto Y+’s top edge
          uvw.z = FACE_POS_Y;  
          uvw.y += faceSize;
        }else if(uvw.y >= faceSize){ // Y- - moved off the bottom of Z+ → onto Y-’s top edge
          uvw.z = FACE_NEG_Y;  
          uvw.y -= faceSize;
        }
        break;
      }
      
      case FACE_NEG_Z:{ // Z- face
        if(uvw.x < 0){ // X+ - moved off the left of Z- → onto X-’s right edge
          uvw.z = FACE_POS_X; 
          uvw.x += faceSize;
        }else if(uvw.x >= faceSize){ // X- - moved off the right of Z- → onto X+’s left edge
          uvw.z = FACE_NEG_X;
          uvw.x -= faceSize;
        }else if(uvw.y < 0){ // Y+ - moved off the top of Z- → onto Y+’s bottom edge (flipped)
          uvw.z = FACE_POS_Y;
          uvw.x = faceSize - (old.x + 1);
          uvw.y = -(old.y + 1);
        }else if(uvw.y >= faceSize){ // Y- - moved off the bottom of Z- → onto Y-’s bottom edge (flipped)
          uvw.z = FACE_NEG_Y;
          uvw.x = faceSize - (old.x + 1);
          uvw.y = faceSize - ((old.y - faceSize) + 1);
        }
        break;
      } 

      default:{
        // This should never happen
        uvw.x = (((uvw.x % faceSize) + faceSize) % faceSize);
        uvw.y = (((uvw.y % faceSize) + faceSize) % faceSize);
        break;
      }

    }

  }

  return uvw;

}  

vec3 wrapCubeFace(vec3 uvw){

  // This function repeatedly adjusts the face [f] and the coordinates [x, y] until the coordinates [x, y] are 
  // within the bounds of the cube face [0, 1.0]. This approach naturally supports multiple successive folds 
  // across different faces, including diagonal transitions, without needing to handle diagonal transition cases 
  // separately.

  while(any(lessThan(uvw.xy, vec2(0.0))) || any(greaterThanEqual(uvw.xy, vec2(1.0)))){
    
    vec3 old = uvw;
    
    switch(uvw.z){
      case FACE_POS_X:{ // X+ face
        if(uvw.x < 0.0){ // Z+ - moved off the left edge of X+ → onto Z+’s left edge
          uvw.z = FACE_POS_Z;
          uvw.x += 1.0;   
        }else if(uvw.x >= 1.0){ // Z- - moved off the right edge of X+ → onto Z-’s right edge
          uvw.z = FACE_NEG_Z;
          uvw.x -= 1.0;
        }else if(uvw.y < 0.0){ // Y+ - moved off the top of X+ → onto Y+’s right edge
          uvw.z = FACE_POS_Y;
          uvw.x = 1.0 + old.y;
          uvw.y = 1.0 - old.x;
        }else if(uvw.y >= 1.0){ // Y- - moved off the bottom of X+ → onto Y-’s right edge
          uvw.z = FACE_NEG_Y;              
          uvw.x = 1.0 - (old.y - 1.0);
          uvw.y = old.x;  
        }
        break;
      }
      
      case FACE_NEG_X:{ // X- face
        if(uvw.x < 0.0){ // Z- - moved off the left of X- → onto Z-’s left edge
          uvw.z = FACE_NEG_Z;
          uvw.x += 1.0;
        }else if(uvw.x >= 1.0){ // Z+ - moved off the right of X- → onto Z+’s right edge
          uvw.z = FACE_POS_Z;   
          uvw.x -= 1.0;
        }else if(uvw.y < 0.0){ // Y+ - moved off the top of X- → onto Y+’s left edge
          uvw.z = FACE_POS_Y;   
          uvw.x = -old.y;
          uvw.y = old.x;
        }else if(uvw.y >= 1.0){ // Y- - moved off the bottom of X- → onto Y-’s left edge
          uvw.z = FACE_NEG_Y;  
          uvw.x = old.y - 1.0;
          uvw.y = 1.0 - old.x;
        }
        break;
      }
      
      case FACE_POS_Y:{ // Y+ face
        if(uvw.x < 0.0){ // X- - moved off the left of Y+ → onto X-’s top edge
          uvw.z = FACE_NEG_X;   
          uvw.x = old.y;            
          uvw.y = -old.x; // Updated to remove +1
        }else if(uvw.x >= 1.0){ // X+ - moved off the right of Y+ → onto X+’s top edge
          uvw.z = FACE_POS_X;   
          uvw.x = 1.0 - old.y;
          uvw.y = old.x - faceSize; // Updated to maintain consistency
        }else if(uvw.y < 0.0){ // Z- - moved off the top of Y+ → onto Z-’s top edge
          uvw.z = FACE_NEG_Z;   
          uvw.x = faceSize - old.x;
          uvw.y = -old.y;
        }else if(uvw.y >= 1.0){ // Z+ - moved off the bottom of Y+ → onto Z+’s top edge
          uvw.z = FACE_POS_Z;   
          uvw.y -= faceSize;
        }
        break;
      }
      
      case FACE_NEG_Y:{ // Y- face
        if(uvw.x < 0.0){ // X- - moved off the left of Y- → onto X-’s bottom edge
          uvw.z = FACE_NEG_X;  
          uvw.x = 1.0 - old.y;
          uvw.y = 1.0 + old.x;
        }else if(uvw.x >= 1.0){ // X+ - moved off the right of Y- → onto X+’s bottom edge
          uvw.z = FACE_POS_X;
          uvw.x = old.y;
          uvw.y = 1.0 - (old.x - 1.0);
        }else if(uvw.y < 0.0){ // Z+ - moved off the top of Y- → onto Z+’s bottom edge
          uvw.z = FACE_POS_Z; 
          uvw.y += faceSize;
        }else if(uvw.y >= 1.0){ // Z- - moved off the bottom of Y- → onto Z-’s bottom edge
          uvw.z = FACE_NEG_Z;
          uvw.x = 1.0 - old.x;
          uvw.y = 1.0 - (old.y - 1.0);
        }
        break;
      }
      
      case FACE_POS_Z:{ // Z+ face
        if(uvw.x < 0.0){ // X- - moved off the left of Z+ → onto X-’s right edge
          uvw.z = FACE_NEG_X; 
          uvw.x += 1.0;
        }else if(uvw.x >= 1.0){ // X+ - moved off the right of Z+ → onto X+’s left edge
          uvw.z = FACE_POS_X;
          uvw.x -= 1.0;
        }else if(uvw.y < 0.0){ // Y+ - moved off the top of Z+ → onto Y+’s top edge
          uvw.z = FACE_POS_Y;  
          uvw.y += 1.0;
        }else if(uvw.y >= 1.0){ // Y- - moved off the bottom of Z+ → onto Y-’s top edge
          uvw.z = FACE_NEG_Y;  
          uvw.y -= 1.0;
        }
        break;
      }
      
      case FACE_NEG_Z:{ // Z- face
        if(uvw.x < 0.0){ // X+ - moved off the left of Z- → onto X-’s right edge
          uvw.z = FACE_POS_X; 
          uvw.x += 1.0; 
        }else if(uvw.x >= 1.0){ // X- - moved off the right of Z- → onto X+’s left edge
          uvw.z = FACE_NEG_X;
          uvw.x -= 1.0;
        }else if(uvw.y < 0.0){ // Y+ - moved off the top of Z- → onto Y+’s bottom edge (flipped)
          uvw.z = FACE_POS_Y;
          uvw.x = 1.0 - old.x;
          uvw.y = -old.y;
        }else if(uvw.y >= 1.0){ // Y- - moved off the bottom of Z- → onto Y-’s bottom edge (flipped)
          uvw.z = FACE_NEG_Y;
          uvw.x = 1.0 - old.x;
          uvw.y = 1.0 - (old.y - 1.0);
        }
        break;
      } 

      default:{
        // This should never happen
        uvw.x = fract(fract(uvw.x) + 1.0);
        uvw.y = fract(fract(uvw.y) + 1.0);
        break;
      }

    }

  }

  return uvw;

}  

