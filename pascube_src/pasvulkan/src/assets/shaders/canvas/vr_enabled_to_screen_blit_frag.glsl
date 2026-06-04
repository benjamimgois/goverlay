#version 450 core

layout(location = 0) in vec2 inTexCoord;

layout (location = 1) flat in int inCountLayers;

layout(location = 0) out vec4 outColor;

layout(set = 0, binding = 0) uniform sampler2DArray uTexture;

const float alpha = 0.2;
	
void main(){
  int texLayer = int(floor(inTexCoord.x * float(inCountLayers)));
  vec2 p = fma(vec2(mix(1.0, fract(inTexCoord.x * float(inCountLayers)), float(texLayer < inCountLayers)), inTexCoord.y), vec2(2.0), vec2(-1.0));
  outColor = textureLod(uTexture, vec3(fma((p / (1.0 - (alpha * length(p)))) * (1.0 - alpha), vec2(0.5), vec2(0.5)), float(texLayer)), 0.0);
} 