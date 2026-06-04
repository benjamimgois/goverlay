#ifndef BUFFERREFERENCE_DEFINITIONS_GLSL
#define BUFFERREFERENCE_DEFINITIONS_GLSL

#if defined(RAYTRACING)
  #define USE_BUFFER_REFERENCE // Explicitly enable this, ray tracing needs buffer reference support anyway.
  #define USE_MATERIAL_BUFFER_REFERENCE // Explicitly enable this, ray tracing needs buffer reference support anyway. 
  #define USE_INT64 // Enable 64-bit integers for on GPU with hardware ray tracing for simplicity. Therefore, GPUs with hardware ray tracing that do not support 64-bit integers are plain and simple not supported for the sake of simplicity. 
#endif

#if defined(USE_MATERIAL_BUFFER_REFERENCE) 
 #define USE_BUFFER_REFERENCE
#endif

#if defined(USE_BUFFER_REFERENCE) 
  #extension GL_EXT_shader_explicit_arithmetic_types_int64 : enable 
  //#extension GL_EXT_buffer_reference : enable 
  #extension GL_EXT_buffer_reference2 : enable 
  #ifdef USE_INT64
    //#extension GL_ARB_gpu_shader_int64 : enable
  #else
    #extension GL_EXT_buffer_reference_uvec2 : enable 
  #endif
  #define sizeof(Type) (uint64_t(Type(uint64_t(0))+1))
#endif

#endif // BUFFERREFERENCE_DEFINITIONS_GLSL