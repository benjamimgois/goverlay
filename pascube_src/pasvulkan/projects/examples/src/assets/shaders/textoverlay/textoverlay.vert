#version 450 core

layout (location = 0) in vec2 inPos;
layout (location = 1) in vec3 inUV;
layout (location = 2) in vec4 inBackgroundColor;
layout (location = 3) in vec4 inForegroundColor;

layout (location = 0) out vec3 outUV;
layout (location = 1) out vec4 outBackgroundColor;
layout (location = 2) out vec4 outForegroundColor;

out gl_PerVertex {
    vec4 gl_Position;   
};

void main(void){
	gl_Position = vec4(inPos, 0.0, 1.0);
	outUV = inUV;
  outForegroundColor = inForegroundColor;
  outBackgroundColor = inBackgroundColor;
}