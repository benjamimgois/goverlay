#version 450

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout (location = 0) in vec3 inNormal;
layout (location = 1) in vec2 inTexCoord;
layout (location = 2) in vec3 inPosition;

layout (binding = 1) uniform sampler2D samplerColor;

struct ModelMatrixInfo {
	mat4 modelViewProjectionMatrix;
	mat4 modelViewMatrix;
	mat4 modelViewNormalMatrix;
};

layout (binding = 0) uniform UBO {
	ModelMatrixInfo instances[256];
	vec4 particlePositions[8];
	vec4 particleColors[8];
} ubo;

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
    vec3 V = normalize(-inPosition);
    
    float gpuStressMode = pushConsts.params.w; // 0 = normal, >0 = heavy GPU mode
    
    vec3 lighting;
    vec3 reflectionColor = vec3(0.0);
    
    if (gpuStressMode > 0.5) {
        // GPU HEAVY MODE: 8 actual orbiting particles lighting + reflection
        vec3 totalLight = vec3(0.05); // ambient
        
        for (int i = 0; i < 8; i++) {
            vec3 lightPos = ubo.particlePositions[i].xyz;
            vec3 lightColor = ubo.particleColors[i].rgb;
            
            vec3 L = normalize(lightPos - inPosition);
            vec3 H = normalize(L + V);
            
            // Distance attenuation
            float dist = length(lightPos - inPosition);
            float atten = 1.0 / (1.0 + dist * 0.2 + dist * dist * 0.1);
            
            // Smooth Diffuse
            float diff = max(dot(N, L), 0.0);
            
            // Smooth Specular
            float spec = pow(max(dot(N, H), 0.0), pushConsts.params.z);
            
            totalLight += (diff * pushConsts.params.x * lightColor + 
                           spec * pushConsts.params.y * lightColor) * atten;
        }
        
        // Extra noise stress
        float val = inTexCoord.x + inTexCoord.y;
        for (int i = 0; i < 4000; i++) {
            float fi = float(i);
            val = sin(val + fi) + cos(val - fi);
            val = tan(clamp(val, -1.5, 1.5)) + sqrt(abs(val) + 1.0);
            val = log(abs(val) + 1.1) + exp(clamp(val * 0.01, -2.0, 2.0));
            val = asin(clamp(sin(val), -0.9, 0.9)) + acos(clamp(cos(val), -0.9, 0.9));
        }
        float noise = fract(val * 0.001);
        
        lighting = totalLight * (0.95 + noise * 0.1);

        // Colored Specular reflections of the particles on the cube surface
        vec3 R = reflect(-V, N);
        for (int i = 0; i < 8; i++) {
            vec3 P = ubo.particlePositions[i].xyz;
            vec3 C = ubo.particleColors[i].rgb;
            
            vec3 D = P - inPosition;
            float t = dot(D, R);
            if (t > 0.0) {
                float distSq = dot(D, D) - t * t;
                // Soft glow reflection
                float reflectionIntensity = exp(-distSq * 25.0) * (1.0 / (1.0 + t * 0.15));
                reflectionColor += C * reflectionIntensity * 1.5;
            }
        }
    } else {
        // NORMAL MODE: directional light from top-front
        vec3 L = normalize(vec3(0.2, 0.95, 0.4));
        
        // Lambertian diffuse shading
        float diff = max(dot(N, L), 0.0);
        
        // Matte ambient + diffuse with no specular highlight for maximum tridimensionality
        vec3 ambient = vec3(0.18);
        vec3 diffuseColor = diff * vec3(0.82);
        
        lighting = ambient + diffuseColor;
    }
    
    // Base color: premium matte light-grey/white
    vec3 baseColor = vec3(0.9) * pushConsts.vector.rgb;
    vec3 finalColor = lighting * baseColor + reflectionColor;
    
    outColor = vec4(finalColor, pushConsts.vector.a);
}
