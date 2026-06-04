#version 430 core

layout(lines) in;
layout(triangle_strip, max_vertices = 4) out;

layout(location = 0) in vec4 inColor[];
layout(location = 1) in vec2 inEdgeDistances[];

layout(location = 0) out vec4 outColor;
layout(location = 1) out vec2 outEdgeDistances;

/* clang-format off */
layout(push_constant) uniform PushConstants {
  uint viewBaseIndex;
  uint countViews;
  uint countAllViews;
  uint dummy;
  vec2 viewPortSize;
} pushConstants;

in gl_PerVertex {
	vec4 gl_Position;
	float gl_PointSize;  
  float gl_ClipDistance[];
};

/* clang-format on */

vec2 clipSpaceToScreenSpace(const vec2 clipSpace) {
  return fma(clipSpace, vec2(0.5), vec2(0.5)) * pushConstants.viewPortSize;
}

void main() {

  float thickness = 16.0;

	vec2 lineStart = gl_in[0].gl_Position.xy / gl_in[0].gl_Position.w;
  vec2 lineEnd = gl_in[1].gl_Position.xy / gl_in[1].gl_Position.w;

  vec2 screenSpaceLineStart = clipSpaceToScreenSpace(lineStart);
  vec2 screenSpaceLineEnd = clipSpaceToScreenSpace(lineEnd);

  vec2 dir = normalize(lineEnd - lineStart);  
  vec2 normal = normalize(vec2(-dir.y, dir.x)) * (thickness / pushConstants.viewPortSize) * 0.5;
  //dir *= (thickness / pushConstants.viewPortSize) * 0.5;
	
  // line start
  gl_Position = vec4((lineStart + normal) * gl_in[0].gl_Position.w, gl_in[0].gl_Position.zw); 
  outColor = inColor[0];
  outEdgeDistances = vec2(0.0, thickness);
	EmitVertex();

  gl_Position = vec4((lineStart - normal) * gl_in[0].gl_Position.w, gl_in[0].gl_Position.zw);
  outColor = inColor[0];
  outEdgeDistances = vec2(0.0, -thickness);  
	EmitVertex();
		
	 // line end
  gl_Position = vec4((lineEnd + normal) * gl_in[1].gl_Position.w, gl_in[1].gl_Position.zw);
  outColor = inColor[1];
  outEdgeDistances = vec2(0.0, thickness);
	EmitVertex();
		
  gl_Position = vec4((lineEnd - normal) * gl_in[1].gl_Position.w, gl_in[1].gl_Position.zw);
  outColor = inColor[1];
  outEdgeDistances = vec2(0.0, -thickness);
  EmitVertex();
    
  EndPrimitive();
  
}