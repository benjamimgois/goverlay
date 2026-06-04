#version 450

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout (location = 0) in vec2 inUV;

layout (location = 0) out vec4 outColor;

void main() {
    vec2 uv = inUV;
    
    // Sun position (upper right)
    vec2 sunPos = vec2(0.75, 0.25);
    vec2 toSun = sunPos - uv;
    float distToSun = length(toSun);
    
    // Sun disc
    float sunRadius = 0.03;
    float sunDisc = 1.0 - smoothstep(0.0, sunRadius, distToSun);
    
    // Sun halo/glow (multiple falloffs)
    float halo1 = exp(-distToSun * 8.0) * 0.4;
    float halo2 = exp(-distToSun * 3.0) * 0.15;
    float halo3 = exp(-distToSun * 1.0) * 0.06;
    float sunGlow = halo1 + halo2 + halo3;
    
    // Sun color: warm white/yellow
    vec3 sunColor = vec3(1.0, 0.95, 0.8);
    vec3 sunGlowColor = vec3(1.0, 0.85, 0.6);
    
    // Atmosphere gradient (Rayleigh-like)
    // Horizon: lighter blue, Top: deeper blue
    vec3 horizonColor = vec3(0.35, 0.55, 0.85);
    vec3 zenithColor  = vec3(0.05, 0.15, 0.45);
    
    // Height-based sky gradient
    float height = uv.y;
    vec3 skyColor = mix(horizonColor, zenithColor, smoothstep(0.0, 0.6, height));
    
    // Horizon haze (light scattering near horizon)
    float haze = exp(-height * 4.0) * 0.3;
    vec3 hazeColor = vec3(0.7, 0.8, 1.0);
    skyColor = mix(skyColor, hazeColor, haze * 0.5);
    
    // Apply sun and glow
    vec3 color = skyColor;
    color += sunGlowColor * sunGlow;
    color += sunColor * sunDisc;
    
    // Tonemapping / clamp
    color = color / (1.0 + color * 0.3);
    
    outColor = vec4(color, 1.0);
}
