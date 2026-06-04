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
            
            // Diffuse
            float diff = max(dot(N, L), 0.0);
            if (diff > 0.75) diff = 1.0;
            else if (diff > 0.35) diff = 0.55;
            else diff = 0.2;
            
            // Specular
            float specRaw = pow(max(dot(N, H), 0.0), pushConsts.params.z);
            float spec = (specRaw > 0.6) ? 1.0 : 0.0;
            
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
        // NORMAL MODE: single light
        vec3 L = normalize(vec3(0.5, 0.7, 1.0));
        vec3 H = normalize(L + V);
        
        float diffRaw = max(dot(N, L), 0.0);
        float diff;
        if (diffRaw > 0.75) diff = 1.0;
        else if (diffRaw > 0.35) diff = 0.55;
        else diff = 0.2;
        
        float specRaw = pow(max(dot(N, H), 0.0), pushConsts.params.z);
        float spec = (specRaw > 0.6) ? 1.0 : 0.0;
        
        vec3 ambient = vec3(0.15);
        vec3 diffuse = diff * pushConsts.params.x * vec3(1.0);
        vec3 specular = spec * pushConsts.params.y * vec3(1.0);
        
        lighting = ambient + diffuse + specular;
    }
    
    // Texture / material
    vec4 texColor = texture(samplerColor, inTexCoord);
    float brush = sin(inTexCoord.y * 60.0) * 0.02 + 0.98;
    vec3 tintedTex = texColor.rgb * pushConsts.vector.rgb * brush;
    vec3 materialColor = lighting * tintedTex;
    
    // Edge detection
    float edgeThickness = 0.018;
    float edgeX = min(inTexCoord.x, 1.0 - inTexCoord.x);
    float edgeY = min(inTexCoord.y, 1.0 - inTexCoord.y);
    float edgeDist = min(edgeX, edgeY);
    float edgeFactor = smoothstep(0.0, edgeThickness, edgeDist);
    vec3 edgeColor = vec3(0.04, 0.04, 0.06);
    vec3 finalColor = mix(edgeColor, materialColor, edgeFactor);
    
    outColor = vec4(finalColor, pushConsts.vector.a);
}
