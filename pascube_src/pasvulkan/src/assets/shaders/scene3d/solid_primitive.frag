#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable

#include "solid_primitive.glsl"

layout(location = 0) in vec4 inColor;
layout(location = 1) in vec2 inPosition;
layout(location = 2) in vec2 inPosition0;
layout(location = 3) in vec2 inPosition1;
layout(location = 4) in vec2 inPosition2;
layout(location = 5) in vec2 inPosition3;
layout(location = 6) in float inLineThicknessOrPointSize;
layout(location = 7) in float inInnerRadius;
layout(location = 8) flat in uint inPrimitiveTopology;

layout(location = 0) out vec4 outFragColor;

layout(push_constant) uniform PushConstants {
  uint viewBaseIndex;
  uint countViews;
  uint countAllViews;
  uint dummy;
  vec2 viewPortSize;
} pushConstants;

void main(){
  
  vec4 outputColor = vec4(0.0);
  
  switch(inPrimitiveTopology){

    case PRIMITIVE_TOPOLOGY_POINT:{

      float d = distance(inPosition, inPosition0) - inLineThicknessOrPointSize;
      
      float alpha = 1.0 - clamp(d / fwidth(d), 0.0, 1.0);

      outputColor = vec4(inColor.xyzw) * alpha; // Premultiplied alpha

      break;

    }

    case PRIMITIVE_TOPOLOGY_POINT_WIREFRAME:{

      float d = distance(inPosition, inPosition0);
      d = max(d - inLineThicknessOrPointSize, inInnerRadius - d);

      float alpha = 1.0 - clamp(d / fwidth(d), 0.0, 1.0);

      outputColor = vec4(inColor.xyzw) * alpha; // Premultiplied alpha

      break;

    }

    case PRIMITIVE_TOPOLOGY_LINE:{
      
      vec2 p = inPosition, a = inPosition0, b = inPosition1;

#if 0
      // Rounded line
      vec2 pa = p - a, ba = b - a;
      float d = length(pa - (ba * (clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0)))) - (inLineThicknessOrPointSize * 0.5);
#else
      // Line with square ends 
      float l = length(b - a);
      vec2 c = (b - a) / l, q = (p - ((a + b) * 0.5));
      q = abs(mat2(c.x, -c.y, c.y, c.x) * q) - vec2(l, inLineThicknessOrPointSize) * 0.5;
      float d = length(max(q, 0.0)) + min(max(q.x, q.y),0.0);          
#endif

      float alpha = 1.0 - clamp(d / fwidth(d), 0.0, 1.0);

      outputColor = vec4(inColor.xyzw) * alpha; // Premultiplied alpha

      break;

    }

    case PRIMITIVE_TOPOLOGY_TRIANGLE:{

      vec2 p = inPosition, p0 = inPosition0, p1 = inPosition1, p2 = inPosition2;

      vec2 e0 = p1 - p0, e1 = p2 - p1, e2 = p0 - p2;
      vec2 v0 = p - p0, v1 = p - p1, v2 = p - p2;
      vec2 pq0 = v0 - (e0 * clamp(dot(v0, e0) / dot(e0, e0), 0.0, 1.0));
      vec2 pq1 = v1 - (e1 * clamp(dot(v1, e1) / dot(e1, e1), 0.0, 1.0));
      vec2 pq2 = v2 - (e2 * clamp(dot(v2, e2) / dot(e2, e2), 0.0, 1.0));
      float s = sign((e0.x * e2.y) - (e0.y *e2.x));
      vec2 t = min(min(vec2(dot(pq0, pq0), s * ((v0.x * e0.y) - (v0.y * e0.x))),
                       vec2(dot(pq1, pq1), s * ((v1.x * e1.y) - (v1.y * e1.x)))),
                       vec2(dot(pq2, pq2), s * ((v2.x * e2.y) - (v2.y * e2.x))));
      float d = -sqrt(t.x)*sign(t.y);

      float alpha = 1.0 - clamp(d / fwidth(d), 0.0, 1.0);

      outputColor = vec4(inColor.xyzw) * alpha; // Premultiplied alpha

      break;

    }

    case PRIMITIVE_TOPOLOGY_TRIANGLE_WIREFRAME:{

      vec2 p = inPosition, p0 = inPosition0, p1 = inPosition1, p2 = inPosition2;

      float d = uintBitsToFloat(0x7f800000u); // +inf

      // Edge 0 line
      {

        vec2 a = p0, b = p1;

        vec2 pa = p - a, ba = b - a;

        d = min(d, length(pa - (ba * (clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0)))) - (inLineThicknessOrPointSize * 0.5));

      }

      // Edge 1 line
      {

        vec2 a = p1, b = p2;

        vec2 pa = p - a, ba = b - a;

        d = min(d, length(pa - (ba * (clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0)))) - (inLineThicknessOrPointSize * 0.5));

      }

      // Edge 2 line
      {
        vec2 a = p2, b = p0;

        vec2 pa = p - a, ba = b - a;

        d = min(d, length(pa - (ba * (clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0)))) - (inLineThicknessOrPointSize * 0.5));

      }

      float alpha = 1.0 - clamp(d / fwidth(d), 0.0, 1.0);

      outputColor = vec4(inColor.xyzw) * alpha; // Premultiplied alpha

      break;

    }

    case PRIMITIVE_TOPOLOGY_QUAD:{

      // Two triangles

      vec2 p = inPosition;
      
      float d;

      {
        
        vec2 p0 = inPosition0, p1 = inPosition1, p2 = inPosition2;

        vec2 e0 = p1 - p0, e1 = p2 - p1, e2 = p0 - p2;
        vec2 v0 = p - p0, v1 = p - p1, v2 = p - p2;
        vec2 pq0 = v0 - (e0 * clamp(dot(v0, e0) / dot(e0, e0), 0.0, 1.0));
        vec2 pq1 = v1 - (e1 * clamp(dot(v1, e1) / dot(e1, e1), 0.0, 1.0));
        vec2 pq2 = v2 - (e2 * clamp(dot(v2, e2) / dot(e2, e2), 0.0, 1.0));
        float s = sign((e0.x * e2.y) - (e0.y *e2.x));
        vec2 t = min(min(vec2(dot(pq0, pq0), s * ((v0.x * e0.y) - (v0.y * e0.x))),
                        vec2(dot(pq1, pq1), s * ((v1.x * e1.y) - (v1.y * e1.x)))),
                        vec2(dot(pq2, pq2), s * ((v2.x * e2.y) - (v2.y * e2.x))));
        d = -sqrt(t.x)*sign(t.y);
        
      } 

      {

        vec2 p0 = inPosition2, p1 = inPosition3, p2 = inPosition0;

        vec2 e0 = p1 - p0, e1 = p2 - p1, e2 = p0 - p2;
        vec2 v0 = p - p0, v1 = p - p1, v2 = p - p2;
        vec2 pq0 = v0 - (e0 * clamp(dot(v0, e0) / dot(e0, e0), 0.0, 1.0));
        vec2 pq1 = v1 - (e1 * clamp(dot(v1, e1) / dot(e1, e1), 0.0, 1.0));
        vec2 pq2 = v2 - (e2 * clamp(dot(v2, e2) / dot(e2, e2), 0.0, 1.0));
        float s = sign((e0.x * e2.y) - (e0.y *e2.x));
        vec2 t = min(min(vec2(dot(pq0, pq0), s * ((v0.x * e0.y) - (v0.y * e0.x))),
                        vec2(dot(pq1, pq1), s * ((v1.x * e1.y) - (v1.y * e1.x)))),
                        vec2(dot(pq2, pq2), s * ((v2.x * e2.y) - (v2.y * e2.x))));
        d = min(d, -sqrt(t.x)*sign(t.y));

      }

      float alpha = 1.0 - clamp(d / fwidth(d), 0.0, 1.0);

      outputColor = vec4(inColor.xyzw) * alpha; // Premultiplied alpha

      break;

    }

    case PRIMITIVE_TOPOLOGY_QUAD_WIREFRAME:{

      vec2 p = inPosition, p0 = inPosition0, p1 = inPosition1, p2 = inPosition2, p3 = inPosition3;

      float d = uintBitsToFloat(0x7f800000u); // +inf

      // Edge 0 line
      {

        vec2 a = p0, b = p1;

        vec2 pa = p - a, ba = b - a;

        d = min(d, length(pa - (ba * (clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0)))) - (inLineThicknessOrPointSize * 0.5));

      }

      // Edge 1 line
      {

        vec2 a = p1, b = p2;

        vec2 pa = p - a, ba = b - a;

        d = min(d, length(pa - (ba * (clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0)))) - (inLineThicknessOrPointSize * 0.5));

      }

      // Edge 2 line
      {

        vec2 a = p2, b = p3;

        vec2 pa = p - a, ba = b - a;

        d = min(d, length(pa - (ba * (clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0)))) - (inLineThicknessOrPointSize * 0.5));

      }

      // Edge 3 line
      {

        vec2 a = p3, b = p0;

        vec2 pa = p - a, ba = b - a;

        d = min(d, length(pa - (ba * (clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0)))) - (inLineThicknessOrPointSize * 0.5));

      }

      float alpha = 1.0 - clamp(d / fwidth(d), 0.0, 1.0);

      outputColor = vec4(inColor.xyzw) * alpha; // Premultiplied alpha

      break;

    }

    default:{

      outputColor = inColor;

      break;

    }

  }

  outFragColor = outputColor;

}
