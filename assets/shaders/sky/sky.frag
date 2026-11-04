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

    // Angles from push constants (rotation around Y and X/Z)
    float rotY = pushConsts.angles.x * 6.28318530718;
    float rotX = pushConsts.angles.y * 6.28318530718;

    // Floating cube physical motion offsets
    float xOffset = sin(rotY) * 0.015;
    float yOffset = cos(rotY * 2.0) * 0.006;

    // ----------------------------------------------------
    // CYBER DARK STUDIO (Deep Obsidian in Vulkan sRGB space)
    // ----------------------------------------------------
    // In Vulkan with VK_FORMAT_B8G8R8A8_SRGB, outColor is converted to sRGB: C_screen = C_linear^(1/2.2).
    // To achieve true obsidian black (#080a10), linear colors must be deep (~0.002 - 0.006).
    vec3 bgDeep = vec3(0.0020, 0.0025, 0.0040); // #080a10 top obsidian
    vec3 bgMid  = vec3(0.0040, 0.0055, 0.0090); // #0e121a horizon transition

    // Focused, atmospheric studio backlight centered behind the floating cube
    vec2 spotCenter = vec2(0.5 + xOffset, 0.46 + yOffset);
    vec2 spotDiff = vec2(uv.x - spotCenter.x, (uv.y - spotCenter.y) * 1.6);
    float spotDistSq = dot(spotDiff, spotDiff);
    float spotGlow = exp(-spotDistSq * 16.0);
    vec3 spotColor = vec3(0.007, 0.022, 0.050); // Elegant deep cyan rim halo

    vec3 color = mix(bgDeep, bgMid, clamp(uv.y / 0.51, 0.0, 1.0)) + spotColor * spotGlow;

    // ----------------------------------------------------
    // Polished dark obsidian floor with refined perspective grid (uv.y >= 0.51)
    // ----------------------------------------------------
    if (uv.y >= 0.51) {
        float z = 0.08 / max(uv.y - 0.50, 0.001);
        float x = (uv.x - 0.5) * z * 1.6;

        float dx = fwidth(x);
        float dz = fwidth(z);

        // Anti-aliased perspective grid lines
        float gridLineX = smoothstep(2.0 * dx, 0.0, abs(fract(x / 0.20 + 0.5) - 0.5) * 0.20);
        float gridLineZ = smoothstep(2.0 * dz, 0.0, abs(fract(z / 0.20 + 0.5) - 0.5) * 0.20);

        float fade = smoothstep(0.51, 0.69, uv.y);
        float grid = max(gridLineX, gridLineZ) * fade;

        // Polished obsidian dark floor tone
        vec3 darkFloor = vec3(0.0025, 0.0032, 0.0050);
        color = mix(color, darkFloor, 0.88);

        // Fine cyber blue floor grid trace
        vec3 gridColor = vec3(0.003, 0.012, 0.025);
        color += gridColor * grid;
    }

    // ----------------------------------------------------
    // True Anisotropic Glossy Floor Reflection (Underneath Floating Cube)
    // ----------------------------------------------------
    float contactY = 0.69 + yOffset;
    float centerX = 0.50 + xOffset;

    if (uv.y >= contactY) {
        float dy = uv.y - contactY;
        float dx = uv.x - centerX;

        // Realistic anisotropic reflection: stretches vertically and softly diffuses horizontally
        float spread = 0.05 + dy * 0.20;
        float vertDecay = exp(-dy * 10.0);
        float horizMask = exp(-(dx * dx) / (spread * spread * 3.5));
        float totalReflMask = vertDecay * horizMask;

        // 3D synced neon reflections mirroring the rotating cube's edges
        float cyanX = centerX - cos(rotY) * 0.055;
        float violetX = centerX + cos(rotY) * 0.055;

        float cyanDx = uv.x - (cyanX + sin(rotY) * 0.01 * (1.0 - dy * 0.4));
        float cyanWidth = 0.020 + dy * 0.05;
        float cyanStreak = exp(-(cyanDx * cyanDx) / (cyanWidth * cyanWidth * 2.8)) * totalReflMask;

        float violetDx = uv.x - (violetX - sin(rotY) * 0.01 * (1.0 - dy * 0.4));
        float violetWidth = 0.020 + dy * 0.05;
        float violetStreak = exp(-(violetDx * violetDx) / (violetWidth * violetWidth * 2.8)) * totalReflMask;

        // Center brushed metallic specular highlight
        float centerWidth = 0.018 + dy * 0.04;
        float centerSpec = exp(-(dx * dx) / (centerWidth * centerWidth * 3.2)) * totalReflMask;

        vec3 reflCyan = vec3(0.025, 0.35, 0.60);
        vec3 reflViolet = vec3(0.45, 0.03, 0.60);
        vec3 reflSpec = vec3(0.04, 0.05, 0.07);

        vec3 glossyReflection = reflCyan * cyanStreak +
                               reflViolet * violetStreak +
                               reflSpec * centerSpec;

        color += glossyReflection;
    }

    // ----------------------------------------------------
    // Tight Ambient Occlusion Contact Shadow
    // ----------------------------------------------------
    vec2 shadowCenter = vec2(centerX, 0.70 + yOffset);
    vec2 shadowDiff = (uv - shadowCenter) / vec2(0.16, 0.035);
    float shadowDist = length(shadowDiff);
    float shadowIntensity = pow(1.0 - smoothstep(0.0, 1.0, shadowDist), 1.8);
    color *= (1.0 - shadowIntensity * 0.85);

    // ----------------------------------------------------
    // Elegant Studio Corner Vignette
    // ----------------------------------------------------
    float cornerDist = distance(uv, vec2(0.5, 0.5));
    float vignette = smoothstep(0.35, 1.0, cornerDist);
    color *= (1.0 - vignette * 0.50);

    // Subtle dithering to eliminate banding on 8-bit displays
    float ditherVal = fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453) - 0.5;
    vec3 dither = vec3(ditherVal) * (0.5 / 255.0);
    color = max(vec3(0.0), color + dither);

    outColor = vec4(color, 1.0);
}
