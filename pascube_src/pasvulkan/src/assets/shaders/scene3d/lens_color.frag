#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout(location = 0) in vec2 inTexCoord;

layout(location = 0) out vec4 outFragColor;

vec4 getLensColor(float x){
  // color gradient values from http://vserver.rosseaux.net/stuff/lenscolor.png
  // you can try to curve-fitting it, my own tries weren't optically better (and smaller) than the multiple mix+smoothstep solution 
  return vec4(vec3(mix(mix(mix(mix(mix(mix(mix(mix(mix(mix(mix(mix(mix(mix(mix(vec3(1.0, 1.0, 1.0),
                                                                               vec3(0.914, 0.871, 0.914), smoothstep(0.0, 0.063, x)),
                                                                           vec3(0.714, 0.588, 0.773), smoothstep(0.063, 0.125, x)),
                                                                       vec3(0.384, 0.545, 0.631), smoothstep(0.125, 0.188, x)),
                                                                   vec3(0.588, 0.431, 0.616), smoothstep(0.188, 0.227, x)),
                                                               vec3(0.31, 0.204, 0.537), smoothstep(0.227, 0.251, x)),
                                                           vec3(0.192, 0.106, 0.286), smoothstep(0.251, 0.314, x)),
                                                       vec3(0.102, 0.008, 0.341), smoothstep(0.314, 0.392, x)),
                                                   vec3(0.086, 0.0, 0.141), smoothstep(0.392, 0.502, x)),
                                               vec3(1.0, 0.31, 0.0), smoothstep(0.502, 0.604, x)),
                                           vec3(1.0, 0.49, 0.0), smoothstep(0.604, 0.643, x)),
                                       vec3(1.0, 0.929, 0.0), smoothstep(0.643, 0.761, x)),
                                   vec3(1.0, 0.086, 0.424), smoothstep(0.761, 0.847, x)),
                               vec3(1.0, 0.49, 0.0), smoothstep(0.847, 0.89, x)),
                           vec3(0.945, 0.275, 0.475), smoothstep(0.89, 0.941, x)),
                       vec3(0.251, 0.275, 0.796), smoothstep(0.941, 1.0, x))),
                    1.0);
}

void main(){
  outFragColor = getLensColor(inTexCoord.x);
}
