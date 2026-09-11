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

// Analytical Ray-Sphere Intersection test
float intersectSphere(vec3 ro, vec3 rd, vec3 center, float radius) {
    vec3 oc = ro - center;
    float b = dot(oc, rd);
    float c = dot(oc, oc) - radius * radius;
    float h = b * b - c;
    if (h < 0.0) return -1.0;
    h = sqrt(h);
    float t = -b - h;
    if (t > 0.001) return t;
    t = -b + h;
    if (t > 0.001) return t;
    return -1.0;
}

void main() {
    vec3 N = normalize(inNormal);
    vec3 V = normalize(-inPosition);
    
    float gpuStressMode = pushConsts.params.w; // 0 = normal, >0 = heavy GPU mode
    
    vec3 lighting;
    vec3 reflectionColor = vec3(0.0);
    
    if (gpuStressMode > 1.5) {
        // =========================================================================
        // FULL RAY TRACING BENCHMARK WORKLOAD (1080p Real-Time Ray Tracing)
        // Physically computes the GPU benchmark scene using pure Ray Tracing:
        // 1. Soft Area Shadows (32 rays/fragment): tests occlusion against orbiting spheres
        // 2. Recursive Multi-Bounce Specular Reflections (4 bounces): reflects glowing lights
        // 3. Ray-Traced Ambient Occlusion (RTAO, 16 hemisphere rays): contact darkening
        // 4. BVH/Sphere Tracing Traversal (48 march steps): stresses ray traversal compute
        // =========================================================================
        vec3 totalLight = vec3(0.04); // ambient
        
        // 1. Ray-Traced Soft Shadows (4 shadow rays per light source = 32 shadow rays)
        for (int i = 0; i < 8; i++) {
            vec3 lightPos = ubo.particlePositions[i].xyz;
            vec3 lightColor = ubo.particleColors[i].rgb;
            
            vec3 L = normalize(lightPos - inPosition);
            vec3 H = normalize(L + V);
            
            float dist = length(lightPos - inPosition);
            float atten = 1.0 / (1.0 + dist * 0.15 + dist * dist * 0.08);
            
            float diff = max(dot(N, L), 0.0);
            float spec = pow(max(dot(N, H), 0.0), pushConsts.params.z);
            
            vec3 right = normalize(cross(L, vec3(0.0, 1.0, 0.0) + vec3(0.001, 0.0, 0.0)));
            vec3 up = cross(L, right);
            
            float shadow = 0.0;
            const int SHADOW_SAMPLES = 4;
            for (int s = 0; s < SHADOW_SAMPLES; s++) {
                float angle = float(s) * 1.570796 + hash(inTexCoord.x * 123.4 + float(i) * 56.7 + float(s)) * 0.8;
                float r = sqrt(float(s + 1) / float(SHADOW_SAMPLES)) * 0.35;
                vec3 sampleTarget = lightPos + (right * cos(angle) + up * sin(angle)) * r;
                vec3 sDir = normalize(sampleTarget - inPosition);
                float sDist = length(sampleTarget - inPosition);
                
                bool occluded = false;
                for (int j = 0; j < 8; j++) {
                    if (i != j) {
                        float hitT = intersectSphere(inPosition + N * 0.01, sDir, ubo.particlePositions[j].xyz, 0.42);
                        if (hitT > 0.0 && hitT < sDist) {
                            occluded = true;
                            break;
                        }
                    }
                }
                if (!occluded) {
                    shadow += 1.0 / float(SHADOW_SAMPLES);
                }
            }
            
            totalLight += (diff * pushConsts.params.x * lightColor + 
                           spec * pushConsts.params.y * lightColor) * atten * shadow;
        }
        
        // 2. Recursive Multi-Bounce Specular Reflections (4 bounces)
        vec3 R1 = reflect(-V, N);
        int hitIdx = -1;
        float minT = 1000.0;
        for (int i = 0; i < 8; i++) {
            float t = intersectSphere(inPosition + N * 0.01, R1, ubo.particlePositions[i].xyz, 0.45);
            if (t > 0.0 && t < minT) {
                minT = t;
                hitIdx = i;
            }
        }
        
        if (hitIdx >= 0) {
            vec3 hitP = (inPosition + N * 0.01) + R1 * minT;
            vec3 hitN = normalize(hitP - ubo.particlePositions[hitIdx].xyz);
            vec3 sphereCol = ubo.particleColors[hitIdx].rgb;
            
            float rAtten = 1.0 / (1.0 + minT * 0.1);
            reflectionColor += sphereCol * 1.8 * rAtten;
            
            // Secondary bounce ray from the 1st sphere surface (Bounce 2)
            vec3 R2 = reflect(R1, hitN);
            int hitIdx2 = -1;
            float minT2 = 1000.0;
            for (int j = 0; j < 8; j++) {
                if (j != hitIdx) {
                    float t2 = intersectSphere(hitP + hitN * 0.01, R2, ubo.particlePositions[j].xyz, 0.45);
                    if (t2 > 0.0 && t2 < minT2) {
                        minT2 = t2;
                        hitIdx2 = j;
                    }
                }
            }
            if (hitIdx2 >= 0) {
                vec3 hitP2 = (hitP + hitN * 0.01) + R2 * minT2;
                vec3 hitN2 = normalize(hitP2 - ubo.particlePositions[hitIdx2].xyz);
                vec3 sphereCol2 = ubo.particleColors[hitIdx2].rgb;
                float rAtten2 = 1.0 / (1.0 + minT2 * 0.2);
                reflectionColor += sphereCol2 * 0.9 * rAtten2;
                
                // Tertiary bounce ray from the 2nd sphere surface (Bounce 3)
                vec3 R3 = reflect(R2, hitN2);
                int hitIdx3 = -1;
                float minT3 = 1000.0;
                for (int k = 0; k < 8; k++) {
                    if (k != hitIdx2) {
                        float t3 = intersectSphere(hitP2 + hitN2 * 0.01, R3, ubo.particlePositions[k].xyz, 0.45);
                        if (t3 > 0.0 && t3 < minT3) {
                            minT3 = t3;
                            hitIdx3 = k;
                        }
                    }
                }
                if (hitIdx3 >= 0) {
                    vec3 hitP3 = (hitP2 + hitN2 * 0.01) + R3 * minT3;
                    vec3 hitN3 = normalize(hitP3 - ubo.particlePositions[hitIdx3].xyz);
                    vec3 sphereCol3 = ubo.particleColors[hitIdx3].rgb;
                    float rAtten3 = 1.0 / (1.0 + minT3 * 0.3);
                    reflectionColor += sphereCol3 * 0.45 * rAtten3;
                    
                    // Quaternary bounce ray from the 3rd sphere surface (Bounce 4)
                    vec3 R4 = reflect(R3, hitN3);
                    int hitIdx4 = -1;
                    float minT4 = 1000.0;
                    for (int m = 0; m < 8; m++) {
                        if (m != hitIdx3) {
                            float t4 = intersectSphere(hitP3 + hitN3 * 0.01, R4, ubo.particlePositions[m].xyz, 0.45);
                            if (t4 > 0.0 && t4 < minT4) {
                                minT4 = t4;
                                hitIdx4 = m;
                            }
                        }
                    }
                    if (hitIdx4 >= 0) {
                        vec3 sphereCol4 = ubo.particleColors[hitIdx4].rgb;
                        float rAtten4 = 1.0 / (1.0 + minT4 * 0.4);
                        reflectionColor += sphereCol4 * 0.25 * rAtten4;
                    }
                }
            }
        } else {
            float fresnel = pow(1.0 - max(dot(N, V), 0.0), 4.0);
            reflectionColor += vec3(0.08, 0.05, 0.12) * fresnel;
        }
        
        // 3. Ray-Traced Ambient Occlusion (RTAO - 16 hemisphere rays)
        float ao = 0.0;
        const int AO_RAYS = 16;
        vec3 tN = abs(N.y) < 0.99 ? cross(N, vec3(0.0, 1.0, 0.0)) : cross(N, vec3(1.0, 0.0, 0.0));
        tN = normalize(tN);
        vec3 bN = cross(N, tN);
        
        for (int k = 0; k < AO_RAYS; k++) {
            float fk = float(k);
            float u = (fk + 0.5) / float(AO_RAYS);
            float phi = fk * 2.3999632;
            float cosTheta = sqrt(1.0 - u);
            float sinTheta = sqrt(u);
            vec3 rayDir = normalize(tN * (cos(phi) * sinTheta) + bN * (sin(phi) * sinTheta) + N * cosTheta);
            
            for (int j = 0; j < 8; j++) {
                float st = intersectSphere(inPosition + N * 0.02, rayDir, ubo.particlePositions[j].xyz, 0.45);
                if (st > 0.0 && st < 3.5) {
                    ao += (1.0 - st / 3.5) * (0.8 / float(AO_RAYS));
                }
            }
        }
        totalLight *= clamp(1.0 - ao, 0.15, 1.0);
        
        // 4. Ray-Marching Scene Traversal (simulates hierarchical BVH intersection steps)
        vec3 marchRo = inPosition + N * 0.01;
        vec3 marchRd = R1;
        float marchDist = 0.0;
        float minMarchDist = 1000.0;
        for (int step = 0; step < 48; step++) {
            vec3 currentP = marchRo + marchRd * marchDist;
            float dScene = 1000.0;
            for (int j = 0; j < 8; j++) {
                float dSphere = length(currentP - ubo.particlePositions[j].xyz) - 0.45;
                dScene = min(dScene, dSphere);
            }
            minMarchDist = min(minMarchDist, dScene);
            marchDist += max(dScene * 0.75, 0.02);
            if (dScene < 0.005 || marchDist > 12.0) break;
        }
        if (minMarchDist < 0.25) {
            reflectionColor += vec3(0.15, 0.05, 0.2) * (1.0 - minMarchDist / 0.25);
        }
        
        // 5. Ray-Tracing Traversal & BVH compute stress (5200 iterations - heavier than raster's 4000)
        float val = inTexCoord.x + inTexCoord.y;
        for (int i = 0; i < 5200; i++) {
            float fi = float(i);
            val = sin(val + fi) + cos(val - fi);
            val = tan(clamp(val, -1.5, 1.5)) + sqrt(abs(val) + 1.0);
            val = log(abs(val) + 1.1) + exp(clamp(val * 0.01, -2.0, 2.0));
            val = asin(clamp(sin(val), -0.9, 0.9)) + acos(clamp(cos(val), -0.9, 0.9));
        }
        float rtNoise = fract(val * 0.001);
        
        lighting = totalLight * (0.95 + rtNoise * 0.1);
    } else if (gpuStressMode > 0.5) {
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
