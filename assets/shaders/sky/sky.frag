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

    // Use raw sRGB-like linear base colors to match the look of the reference gradient
    vec3 skyTopColor = vec3(0.125, 0.129, 0.141);      // #202124 (dark top)
    vec3 maxColor = vec3(0.270, 0.275, 0.290);         // #3a3b3f (brighter studio light peak)

    // Smooth vertical spotlight gradient peaking around y = 0.78 (simulating studio floor horizon)
    float yFactor = 1.0 - pow(uv.y - 0.78, 2.0) * 1.55;
    yFactor = clamp(yFactor, 0.0, 1.0);
    vec3 color = mix(skyTopColor, maxColor, yFactor);

    // Subtle 3D perspective floor grid below the horizon (uv.y >= 0.51)
    if (uv.y >= 0.51) {
        float z = 0.08 / (uv.y - 0.50);
        float x = (uv.x - 0.5) * z * 1.6;
        
        float dx = fwidth(x);
        float dz = fwidth(z);
        
        // Anti-aliased grid lines using fwidth (thicker lines)
        float gridLineX = smoothstep(2.2 * dx, 0.0, abs(fract(x / 0.20 + 0.5) - 0.5) * 0.20);
        float gridLineZ = smoothstep(2.2 * dz, 0.0, abs(fract(z / 0.20 + 0.5) - 0.5) * 0.20);
        
        // Fade out grid lines near the horizon to avoid aliasing and moire
        float fade = smoothstep(0.51, 0.68, uv.y);
        
        float grid = max(gridLineX, gridLineZ) * fade;
        
        // Blend in a subtle, dark graphite grid color for an engraved look
        vec3 gridColor = vec3(0.11, 0.11, 0.12); 
        color = mix(color, gridColor, grid * 0.35);
    }

    // Studio vignette to darken the left and right edges smoothly
    float dist = distance(uv, vec2(0.5, 0.5));
    float vignette = smoothstep(0.0, 0.9, dist);
    color = mix(color, vec3(0.08, 0.08, 0.09), vignette * 0.22);

    // Extract angle from push constants
    float angle = pushConsts.angles.x * 6.28318530718;

    // Soft contact shadow underneath the floating central cube
    float xOffset = sin(angle) * 0.022;
    float yOffset = cos(angle * 2.0) * 0.007;
    float scaleFactor = 1.0 + sin(angle * 2.0) * 0.06;

    vec2 shadowCenter = vec2(0.5 + xOffset, 0.72 + yOffset);
    vec2 diff = (uv - shadowCenter) / (vec2(0.24, 0.065) * scaleFactor);
    float shadowDist = length(diff);
    float shadowIntensity = pow(1.0 - smoothstep(0.0, 1.0, shadowDist), 1.5);

    // Apply soft drop shadow (dark gray contact shadow)
    color = mix(color, vec3(0.04, 0.04, 0.05), shadowIntensity * 0.60);

    // Dithering to prevent color banding
    float ditherVal = fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453) - 0.5;
    vec3 dither = vec3(ditherVal) * (1.0 / 255.0);
    color += dither;

    outColor = vec4(color, 1.0);
}
