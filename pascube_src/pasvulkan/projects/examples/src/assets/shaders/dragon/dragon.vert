#version 450

#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout (location = 0) in vec3 inPosition;
layout (location = 1) in vec4 inQTangent;
layout (location = 2) in vec2 inTexCoord;
layout (location = 3) in uint inMaterial;

layout (binding = 0) uniform UBO {
	mat4 modelViewMatrix;
	mat4 modelViewProjectionMatrix;
	mat4 modelViewNormalMatrix; // actually mat3, but it would have then a mat3x4 alignment, according to https://www.khronos.org/registry/vulkan/specs/1.0/html/vkspec.html#interfaces-resources-layout
} ubo;

layout (location = 0) out vec3 outViewSpacePosition;
layout (location = 1) out vec3 outTangent;
layout (location = 2) out vec3 outBitangent;
layout (location = 3) out vec3 outNormal;
layout (location = 4) out vec2 outTexCoord;
layout (location = 5) flat out uint outMaterial;

out gl_PerVertex {
    vec4 gl_Position;   
};

mat3 QTangentToMatrix(vec4 q){  
  q = normalize(q);
  float qx2 = q.x + q.x,
        qy2 = q.y + q.y,
        qz2 = q.z + q.z,
        qxqx2 = q.x * qx2,
        qxqy2 = q.x * qy2,
        qxqz2 = q.x * qz2,
        qxqw2 = q.w * qx2,
        qyqy2 = q.y * qy2,
        qyqz2 = q.y * qz2,
        qyqw2 = q.w * qy2,
        qzqz2 = q.z * qz2,
        qzqw2 = q.w * qz2;
  mat3 m = mat3(1.0 - (qyqy2 + qzqz2), qxqy2 + qzqw2, qxqz2 - qyqw2,
                qxqy2 - qzqw2, 1.0 - (qxqx2 + qzqz2), qyqz2 + qxqw2,
                qxqz2 + qyqw2, qyqz2 - qxqw2, 1.0 - (qxqx2 + qyqy2));
  m[2] = normalize(cross(m[0], m[1])) * ((q.w < 0.0) ? -1.0 : 1.0);
  return m;
}                    

void main() {
  outViewSpacePosition = (ubo.modelViewMatrix * vec4(inPosition, 1.0)).xyz;
  mat3 tangentSpace = mat3(ubo.modelViewNormalMatrix) * QTangentToMatrix(inQTangent);
  outTangent = tangentSpace[0];
  outBitangent = tangentSpace[1];
  outNormal = tangentSpace[2];
  outTexCoord = inTexCoord;
  outMaterial = inMaterial;
	gl_Position = ubo.modelViewProjectionMatrix * vec4(inPosition, 1.0);
}
