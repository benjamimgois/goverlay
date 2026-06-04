#version 450

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout (location = 0) in vec2 inPosition;
layout (location = 1) in vec2 inTexCoord;

layout (location = 0) out vec2 outTexCoord;

out gl_PerVertex {
    vec4 gl_Position;   
};

void main() {
    outTexCoord = inTexCoord;
    gl_Position = vec4(inPosition, 0.0, 1.0);
}
