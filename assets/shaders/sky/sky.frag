#version 450

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

precision highp float;

layout (location = 0) in vec2 inUV;

layout (location = 0) out vec4 outColor;

layout (push_constant) uniform PushConsts {
    vec2 angles;
} pushConsts;

void main() {
    vec2 uv = inUV;
    
    // Convert target sRGB colors to linear space to correct for automatic GPU/swapchain sRGB conversion
    vec3 centerColor = pow(vec3(0.227, 0.231, 0.247), vec3(2.2)); // #3a3b3f in sRGB
    vec3 edgeColor = pow(vec3(0.125, 0.129, 0.141), vec3(2.2));   // #202124 in sRGB
    vec3 shadowColor = pow(vec3(0.04, 0.04, 0.05), vec3(2.2));    // darker contact shadow
    
    // Correct UV for aspect ratio (1280/720 = 1.7777778) to keep the radial gradient circular in pixel space
    vec2 aspectCorrectedUV = (uv - vec2(0.5, 0.5)) * vec2(1.7777778, 1.0);
    float dist = length(aspectCorrectedUV);
    
    // Radial gradient vignette
    vec3 color = mix(centerColor, edgeColor, smoothstep(0.0, 0.88, dist));
    
    // Extract angle from push constants (AnglePhases[1])
    float angle = pushConsts.angles.x * 6.28318530718;
    
    // Soft contact shadow underneath the floating central cube (closer to the base at y = 0.695)
    // Oscillates and scales subtly in sync with the cube's rotation
    float xOffset = sin(angle) * 0.022;
    float yOffset = cos(angle * 2.0) * 0.007;
    float scaleFactor = 1.0 + sin(angle * 2.0) * 0.06;
    
    vec2 shadowCenter = vec2(0.5 + xOffset, 0.695 + yOffset);
    vec2 diff = (uv - shadowCenter) * vec2(1.7777778, 1.0) / (vec2(0.38, 0.055) * scaleFactor);
    float shadowDist = length(diff);
    float shadowIntensity = pow(1.0 - smoothstep(0.0, 1.0, shadowDist), 1.2);
    
    // Apply soft drop shadow (ambient occlusion on the invisible studio floor, increased opacity to 0.72)
    color = mix(color, shadowColor, shadowIntensity * 0.72);
    
    // Simple dithering to eliminate color banding
    float ditherVal = fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453) - 0.5;
    vec3 dither = vec3(ditherVal) * (1.0 / 255.0);
    color += dither;
    
    outColor = vec4(color, 1.0);
}
