#version 450

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout (location = 0) in vec3 inNormal;
layout (location = 1) in vec2 inTexCoord;

layout (binding = 1) uniform sampler2D samplerColor;

layout (push_constant) uniform PushConsts {
	vec4 vector;
	vec4 params;
} pushConsts;

layout (location = 0) out vec4 outColor;

// Hash for pseudo-random
float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

void main() {
    vec3 N = normalize(inNormal);
    vec3 V = vec3(0.0, 0.0, 1.0);
    
    float gpuStressMode = pushConsts.params.w; // 0 = normal, >0 = heavy GPU mode
    
    vec3 lighting;
    
    if (gpuStressMode > 0.5) {
        // GPU HEAVY MODE: 8 procedural orbiting lights
        vec3 totalLight = vec3(0.05); // ambient
        float time = gpuStressMode;
        
        for (int i = 0; i < 8; i++) {
            float fi = float(i);
            vec3 lightPos = vec3(
                sin(time * (0.5 + fi * 0.1) + fi * 0.8) * 5.0,
                cos(time * (0.3 + fi * 0.05) + fi * 1.2) * 3.0 + 1.0,
                sin(time * (0.4 + fi * 0.07) + fi * 2.0) * 4.0
            );
            
            vec3 L = normalize(lightPos);
            vec3 H = normalize(L + V);
            
            // Distance attenuation
            float dist = length(lightPos);
            float atten = 1.0 / (1.0 + dist * 0.1 + dist * dist * 0.01);
            
            // Smooth Diffuse
            float diff = max(dot(N, L), 0.0);
            
            // Smooth Specular
            float spec = pow(max(dot(N, H), 0.0), pushConsts.params.z);
            
            // Light color variation
            vec3 lightColor = vec3(
                0.7 + sin(fi * 2.1) * 0.3,
                0.7 + sin(fi * 3.7) * 0.3,
                0.7 + sin(fi * 5.3) * 0.3
            );
            
            totalLight += (diff * pushConsts.params.x * lightColor + 
                           spec * pushConsts.params.y * vec3(1.0)) * atten;
        }
        
        // Extra noise stress
        float noise = 0.0;
        for (int i = 0; i < 16; i++) {
            float fi = float(i);
            noise += hash(inTexCoord.x * 100.0 + fi) * hash(inTexCoord.y * 100.0 + fi + 50.0);
        }
        noise = noise / 16.0;
        
        lighting = totalLight * (0.95 + noise * 0.1);
    } else {
        // NORMAL MODE: directional light from top-left-front
        vec3 L = normalize(vec3(-1.0, 1.5, 1.0));
        
        // Lambertian diffuse shading
        float diff = max(dot(N, L), 0.0);
        
        // Matte ambient (0.2) + diffuse (0.7) for high 3D contrast
        vec3 ambient = vec3(0.20);
        vec3 diffuseColor = diff * vec3(0.70);
        
        lighting = ambient + diffuseColor;
    }
    
    // Base color: premium matte light-grey/white
    vec3 baseColor = vec3(0.9) * pushConsts.vector.rgb;
    vec3 finalColor = lighting * baseColor;
    
    outColor = vec4(finalColor, pushConsts.vector.a);
}
