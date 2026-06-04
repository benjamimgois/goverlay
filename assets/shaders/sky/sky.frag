#version 450

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout (location = 0) in vec2 inUV;

layout (location = 0) out vec4 outColor;

layout (push_constant) uniform PushConsts {
    vec2 angles;
} pushConsts;

void main() {
    vec2 uv = inUV;
    
    // Studio Matte lighting: centered radial gradient
    vec3 centerColor = vec3(0.227, 0.231, 0.247); // #3a3b3f (brighter industrial gray)
    vec3 edgeColor = vec3(0.125, 0.129, 0.141);   // #202124 (darker industrial gray)
    
    // Radial gradient centered at the screen center (0.5, 0.5)
    float dist = distance(uv, vec2(0.5, 0.5));
    vec3 color = mix(centerColor, edgeColor, smoothstep(0.0, 0.85, dist));
    
    // Extract angle from push constants (AnglePhases[1])
    float angle = pushConsts.angles.x * 6.28318530718;
    
    // Soft contact shadow underneath the floating central cube
    // It oscillates and scales subtly in sync with the cube's rotation to feel grounded and alive
    float xOffset = sin(angle) * 0.022;
    float yOffset = cos(angle * 2.0) * 0.007;
    float scaleFactor = 1.0 + sin(angle * 2.0) * 0.06;
    
    vec2 shadowCenter = vec2(0.5 + xOffset, 0.72 + yOffset);
    vec2 diff = (uv - shadowCenter) / (vec2(0.24, 0.065) * scaleFactor);
    float shadowDist = length(diff);
    float shadowIntensity = pow(1.0 - smoothstep(0.0, 1.0, shadowDist), 1.5);
    
    // Apply soft drop shadow (dark gray occlusion)
    color = mix(color, vec3(0.06, 0.06, 0.07), shadowIntensity * 0.52);
    
    outColor = vec4(color, 1.0);
}
