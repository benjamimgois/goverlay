#ifndef RGB10A2_GLSL
#define RGB10A2_GLSL

vec4 decodeRGB10A2_UNORM(in uint x){
	return vec4((uvec4(x) >> uvec4(0u, 10u, 20u, 30u)) & uvec2(0x3ffu, 0x3u).xxxy) / vec4(vec3(uvec3(0x3ffu)), 3.0);
}

vec4 decodeRGB10A2_SNORM(in uint x){
	const ivec4 s = ivec4(uvec4(uvec4(uvec4(x) >> uvec4(0u, 10u, 20u, 30u)) & uvec2(0x3ffu, 0x3u).xxxy));
	return max(vec4((-(s & ivec2(0x200u, 0x2u).xxxy)) | (s & ivec2(0x1ffu, 0x1u).xxxy)) / vec4(ivec2(0x1ffu, 0x1u).xxxy), vec4(-1.0));
}

uint encodeRGB10A2_UNORM(in vec4 v){
	uvec4 r = (uvec4(clamp(v,vec4(0.0),vec4(1.0)) * vec4(vec3(uvec3(0x3ffu)), 3.0)) & uvec2(0x3ffu, 0x3u).xxxy) << uvec4(0u, 10u, 20u, 30u);
	return r.x | r.y | r.z | r.w;
}

uint encodeRGB10A2_SNORM(in vec4 v){
	v = clamp(v, vec4(-1.0), vec4(1.0));
	uvec4 r = (uvec4(ivec4(v.xyz * vec3(uvec3(0x1ffu)), int(v.w))) & uvec2(0x3ffu, 0x3u).xxxy) << uvec4(0u, 10u, 20u, 30u);
	return r.x | r.y | r.z | r.w;
}

#endif