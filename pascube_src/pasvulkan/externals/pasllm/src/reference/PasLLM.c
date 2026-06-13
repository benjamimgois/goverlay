// Q40NL POCA LUT generation code:
//   let f(x)=>((x*Math.abs(x))+x)*0.5;let a=[];foreach(let i in [0..15]){a.push(Math.round(f(Math.min(Math.max((i-8)/7,-1.0),1.0))*127)|0);};a;

// Q41NL POCA LUT generation code:
//   let f(x)=>x*Math.abs(x);let a=[];foreach(let i in [0..15]){a.push(Math.round(f(Math.min(Math.max((i-8)/7,-1.0),1.0))*127)|0);};a;

//  -O4 -mavx2 -fno-builtin-memset -ffast-math

#include "stdint.h"
#include "math.h"

// AVX2
#include <immintrin.h>

/* yes I know, the top of this file is quite ugly */
# define ALIGN32_BEG
# define ALIGN32_END __attribute__((aligned(32)))

/* __m128 is ugly to write */
typedef __m256  v8sf; // vector of 8 float (avx)
typedef __m256i v8si; // vector of 8 int   (avx)
typedef __m128i v4si; // vector of 8 int   (avx)

#define _PI32AVX_CONST(Name, Val)                                            \
  static const ALIGN32_BEG int _pi32avx_##Name[4] ALIGN32_END = { Val, Val, Val, Val }

_PI32AVX_CONST(1, 1);
_PI32AVX_CONST(inv1, ~1);
_PI32AVX_CONST(2, 2);
_PI32AVX_CONST(4, 4);


/* declare some AVX constants -- why can't I figure a better way to do that? */
#define _PS256_CONST(Name, Val)                                            \
  static const ALIGN32_BEG float _ps256_##Name[8] ALIGN32_END = { Val, Val, Val, Val, Val, Val, Val, Val }
#define _PI32_CONST256(Name, Val)                                            \
  static const ALIGN32_BEG int _pi32_256_##Name[8] ALIGN32_END = { Val, Val, Val, Val, Val, Val, Val, Val }
#define _PS256_CONST_TYPE(Name, Type, Val)                                 \
  static const ALIGN32_BEG Type _ps256_##Name[8] ALIGN32_END = { Val, Val, Val, Val, Val, Val, Val, Val }

#define avx2_mm256_slli_epi32 _mm256_slli_epi32
#define avx2_mm256_srli_epi32 _mm256_srli_epi32
#define avx2_mm256_and_si256 _mm256_and_si256
#define avx2_mm256_andnot_si256 _mm256_andnot_si256
#define avx2_mm256_cmpeq_epi32 _mm256_cmpeq_epi32
#define avx2_mm256_sub_epi32 _mm256_sub_epi32
#define avx2_mm256_add_epi32 _mm256_add_epi32

_PS256_CONST(1  , 1.0f);
_PS256_CONST(0p5, 0.5f);
/* the smallest non denormalized float number */
_PS256_CONST_TYPE(min_norm_pos, int, 0x00800000);
_PS256_CONST_TYPE(mant_mask, int, 0x7f800000);
_PS256_CONST_TYPE(inv_mant_mask, int, ~0x7f800000);

_PS256_CONST_TYPE(sign_mask, int, (int)0x80000000);
_PS256_CONST_TYPE(inv_sign_mask, int, ~0x80000000);

_PI32_CONST256(0, 0);
_PI32_CONST256(1, 1);
_PI32_CONST256(inv1, ~1);
_PI32_CONST256(2, 2);
_PI32_CONST256(4, 4);
_PI32_CONST256(0x7f, 0x7f);

_PS256_CONST(exp_hi,	88.3762626647949f);
_PS256_CONST(exp_lo,	-88.3762626647949f);

_PS256_CONST(cephes_LOG2EF, 1.44269504088896341);
_PS256_CONST(cephes_exp_C1, 0.693359375);
_PS256_CONST(cephes_exp_C2, -2.12194440e-4);

_PS256_CONST(cephes_exp_p0, 1.9875691500E-4);
_PS256_CONST(cephes_exp_p1, 1.3981999507E-3);
_PS256_CONST(cephes_exp_p2, 8.3334519073E-3);
_PS256_CONST(cephes_exp_p3, 4.1665795894E-2);
_PS256_CONST(cephes_exp_p4, 1.6666665459E-1);
_PS256_CONST(cephes_exp_p5, 5.0000001201E-1);

v8sf exp256_ps(v8sf x) {
  v8sf tmp = _mm256_setzero_ps(), fx;
  v8si imm0;
  v8sf one = *(v8sf*)_ps256_1;

  x = _mm256_min_ps(x, *(v8sf*)_ps256_exp_hi);
  x = _mm256_max_ps(x, *(v8sf*)_ps256_exp_lo);

  /* express exp(x) as exp(g + n*log(2)) */
  fx = _mm256_mul_ps(x, *(v8sf*)_ps256_cephes_LOG2EF);
  fx = _mm256_add_ps(fx, *(v8sf*)_ps256_0p5);

  /* how to perform a floorf with SSE: just below */
  //imm0 = _mm256_cvttps_epi32(fx);
  //tmp  = _mm256_cvtepi32_ps(imm0);
  
  tmp = _mm256_floor_ps(fx);

  /* if greater, substract 1 */
  //v8sf mask = _mm256_cmpgt_ps(tmp, fx);    
  v8sf mask = _mm256_cmp_ps(tmp, fx, _CMP_GT_OS);    
  mask = _mm256_and_ps(mask, one);
  fx = _mm256_sub_ps(tmp, mask);

  tmp = _mm256_mul_ps(fx, *(v8sf*)_ps256_cephes_exp_C1);
  v8sf z = _mm256_mul_ps(fx, *(v8sf*)_ps256_cephes_exp_C2);
  x = _mm256_sub_ps(x, tmp);
  x = _mm256_sub_ps(x, z);

  z = _mm256_mul_ps(x,x);
  
  v8sf y = *(v8sf*)_ps256_cephes_exp_p0;
  y = _mm256_mul_ps(y, x);
  y = _mm256_add_ps(y, *(v8sf*)_ps256_cephes_exp_p1);
  y = _mm256_mul_ps(y, x);
  y = _mm256_add_ps(y, *(v8sf*)_ps256_cephes_exp_p2);
  y = _mm256_mul_ps(y, x);
  y = _mm256_add_ps(y, *(v8sf*)_ps256_cephes_exp_p3);
  y = _mm256_mul_ps(y, x);
  y = _mm256_add_ps(y, *(v8sf*)_ps256_cephes_exp_p4);
  y = _mm256_mul_ps(y, x);
  y = _mm256_add_ps(y, *(v8sf*)_ps256_cephes_exp_p5);
  y = _mm256_mul_ps(y, z);
  y = _mm256_add_ps(y, x);
  y = _mm256_add_ps(y, one);

  /* build 2^n */
  imm0 = _mm256_cvttps_epi32(fx);
  // another two AVX2 instructions
  imm0 = avx2_mm256_add_epi32(imm0, *(v8si*)_pi32_256_0x7f);
  imm0 = avx2_mm256_slli_epi32(imm0, 23);
  v8sf pow2n = _mm256_castsi256_ps(imm0);
  y = _mm256_mul_ps(y, pow2n);
  return y;
}

__m256 avxexp2(__m256 x)
{
    __m256 t, f, p, r;
    __m256i i, j;

    const __m256 l2e = _mm256_set1_ps (1.442695041f); /* log2(e) */
    const __m256 l2h = _mm256_set1_ps (-6.93145752e-1f); /* -log(2)_hi */
    const __m256 l2l = _mm256_set1_ps (-1.42860677e-6f); /* -log(2)_lo */
    /* coefficients for core approximation to exp() in [-log(2)/2, log(2)/2] */
/*  const __m256 c0 =  _mm256_set1_ps (0.041944388f);
    const __m256 c1 =  _mm256_set1_ps (0.168006673f);
    const __m256 c2 =  _mm256_set1_ps (0.499999940f);
    const __m256 c3 =  _mm256_set1_ps (0.999956906f);
    const __m256 c4 =  _mm256_set1_ps (0.999999642f);*/
    const __m256 c0 =  _mm256_set1_ps (0.008301110f);
    const __m256 c1 =  _mm256_set1_ps (0.041906696f);
    const __m256 c2 =  _mm256_set1_ps (0.166674897f);
    const __m256 c3 =  _mm256_set1_ps (0.499990642f);
    const __m256 c4 =  _mm256_set1_ps (0.999999762f);
    const __m256 c5 =  _mm256_set1_ps (1.000000000f);    

    /* exp(x) = 2^i * e^f; i = rint (log2(e) * x), f = x - log(2) * i */
    t = _mm256_mul_ps (x, l2e);      /* t = log2(e) * x */
    r = _mm256_round_ps (t, _MM_FROUND_TO_NEAREST_INT | _MM_FROUND_NO_EXC); /* r = rint (t) */

#if USE_FMA
    f = _mm256_fmadd_ps (r, l2h, x); /* x - log(2)_hi * r */
    f = _mm256_fmadd_ps (r, l2l, f); /* f = x - log(2)_hi * r - log(2)_lo * r */
#else // USE_FMA
    p = _mm256_mul_ps (r, l2h);      /* log(2)_hi * r */
    f = _mm256_add_ps (x, p);        /* x - log(2)_hi * r */
    p = _mm256_mul_ps (r, l2l);      /* log(2)_lo * r */
    f = _mm256_add_ps (f, p);        /* f = x - log(2)_hi * r - log(2)_lo * r */
#endif // USE_FMA

    i = _mm256_cvtps_epi32(t);       /* i = (int)rint(t) */

    /* p ~= exp (f), -log(2)/2 <= f <= log(2)/2 */
    p = c0;                          /* c0 */
#if USE_FMA
    p = _mm256_fmadd_ps (p, f, c1);  /* c0*f+c1 */
    p = _mm256_fmadd_ps (p, f, c2);  /* (c0*f+c1)*f+c2 */
    p = _mm256_fmadd_ps (p, f, c3);  /* ((c0*f+c1)*f+c2)*f+c3 */
    p = _mm256_fmadd_ps (p, f, c4);  /* (((c0*f+c1)*f+c2)*f+c3)*f+c4 */
    p = _mm256_fmadd_ps (p, f, c5);  /* ((((c0*f+c1)*f+c2)*f+c3)*f+c4)*f+c5) ~= exp(f) */
#else // USE_FMA
    p = _mm256_mul_ps (p, f);        /* c0*f */
    p = _mm256_add_ps (p, c1);       /* c0*f+c1 */
    p = _mm256_mul_ps (p, f);        /* (c0*f+c1)*f */
    p = _mm256_add_ps (p, c2);       /* (c0*f+c1)*f+c2 */
    p = _mm256_mul_ps (p, f);        /* ((c0*f+c1)*f+c2)*f */
    p = _mm256_add_ps (p, c3);       /* ((c0*f+c1)*f+c2)*f+c3 */
    p = _mm256_mul_ps (p, f);        /* (((c0*f+c1)*f+c2)*f+c3)*f */
    p = _mm256_add_ps (p, c4);       /* (((c0*f+c1)*f+c2)*f+c3)*f+c4 */
    p = _mm256_mul_ps (p, f);        /* ((((c0*f+c1)*f+c2)*f+c3)*f+c4)*f */
    p = _mm256_add_ps (p, c5);       /* ((((c0*f+c1)*f+c2)*f+c3)*f+c4)*f+c5) ~= exp(f) */
#endif // USE_FMA

    /* exp(x) = 2^i * p */
    j = _mm256_slli_epi32 (i, 23); /* i << 23 */
    r = _mm256_castsi256_ps (_mm256_add_epi32 (j, _mm256_castps_si256 (p))); /* r = p * 2^i */

    return r;
}

//__attribute__((noinline))  __attribute__((ms_abi)) 
float expEx(float f){
  __m256 x = _mm256_set1_ps(f); // Load f into an AVX2 register
  __m256 result = avxexp2(x); // Call the AVX2 exp function
  return _mm256_cvtss_f32(result); // Convert the result to float and return it
  //return expf(f);
}

__attribute__((ms_abi)) void softmax(float* x, int size) {
  // find max value (for numerical stability)
  float max_val = x[0];
  for (int i = 1; i < size; i++) {
    if (x[i] > max_val) {
      max_val = x[i];
    }
  }
  // exp and sum
  float sum = 0.0f;
  for (int i = 0; i < size; i++) {
    x[i] = expEx(x[i] - max_val);
    sum += x[i];
  }
  // normalize
  for (int i = 0; i < size; i++) {
    x[i] /= sum;
  }
}

__attribute__((ms_abi)) void rmsnorm(float* o, float* x, float* weight, int size, float norm_eps) {
  // calculate sum of squares
  float ss = 0.0f;
  for (int j = 0; j < size; j++) {
    ss += x[j] * x[j];
  }
  ss /= size;
  ss += norm_eps;
  ss = 1.0f / sqrtf(ss);
  // normalize and scale
  for (int j = 0; j < size; j++) {
    o[j] = weight[j] * (ss * x[j]);
  }
}

__attribute__((ms_abi)) void rmsnormnoweights(float* o, float* x, int size, float norm_eps) {
  // calculate sum of squares
  float ss = 0.0f;
  for (int j = 0; j < size; j++) {
    ss += x[j] * x[j];
  }
  ss /= size;
  ss += norm_eps;
  ss = 1.0f / sqrtf(ss);
  // normalize and scale
  for (int j = 0; j < size; j++) {
    o[j] = ss * x[j];
  }
}

__attribute__((ms_abi)) void clipFloats(float* x, int32_t size, float min, float max){
  for(int i = 0; i < size; i++){
    const float value = x[i];
    if(value < min){
      x[i] = min; // Clip to minimum if below threshold
    } else if (value > max){
      x[i] = max; // Clip to maximum if above threshold
    }
  }
}

__attribute__((ms_abi)) void addFloats(float* x, float* y, int32_t size){
  for(int i = 0; i < size; i++){
    x[i] += y[i]; // Add y to x element-wise
  }
}

__attribute__((ms_abi)) void addFloatsWithFactor(float* x, float* y, int32_t size, float factor){
  for(int i = 0; i < size; i++){
    x[i] += y[i] * factor; // Add y to x element-wise with factor
  }
}

__attribute__((ms_abi)) void quantizedMatMul(float* xout, int8_t *xq,  float *xs, int8_t *wq, float *ws, int n, int d, int GS) {
  // W (d,n) @ x (n,) -> xout (d,)
  // by far the most amount of time is spent inside this little function
  // inputs to this function are both quantized
  
  int i;
  #pragma omp parallel for private(i)
  for (i = 0; i < d; i++) {
    
    float val = 0.0f;
    int32_t ival = 0;
    int in = i * n;
    
    // do the matmul in groups of GS
    int j;
    for (j = 0; j <= n - GS; j += GS) {
      for (int k = 0; k < GS; k++) {
        ival += ((int32_t) xq[j + k]) * ((int32_t) wq[in + j + k]);
      }
      val += ((float) ival) * ws[(in + j) / GS] * xs[j / GS];
      ival = 0;
    }
    
    xout[i] = val;
  }
}

__attribute__((ms_abi)) void quantizedPartMatMul(float* xout, int8_t *xq,  float *xs, int8_t *wq, float *ws, int n, int a, int b, int GS) {
  // W (d,n) @ x (n,) -> xout (d,)
  // by far the most amount of time is spent inside this little function
  // inputs to this function are both quantized
  
  for (int i = a; i <= b; i++) {
    
    float val = 0.0f;
    int32_t ival = 0;
    int in = i * n;
    
    // do the matmul in groups of GS
    int j;
    for (j = 0; j <= n - GS; j += GS) {
      for (int k = 0; k < GS; k++) {
        ival += ((int32_t) xq[j + k]) * ((int32_t) wq[in + j + k]);
      }
      val += ((float) ival) * ws[(in + j) / GS] * xs[j / GS];
      ival = 0;
    }
    
    xout[i] = val;
  }
}

__attribute__((ms_abi)) void quantizedPartMatMul2(float* xout, int8_t *xq,  float *xs, int8_t *wq, float *ws, int n, int a, int b, int GS) {
  // W (d,n) @ x (n,) -> xout (d,)
  // by far the most amount of time is spent inside this little function
  // inputs to this function are both quantized
  
  for (int i = a; i <= b; i++) {
    
    float val = 0.0f;
    int32_t ival = 0;
    int in = i * n;
    
    // do the matmul in groups of GS
    int j;
    for (j = 0; j <= n - GS; j += GS) {
      int8_t* xqp = &xq[j];
      int8_t* wqp = &wq[in + j];
      #pragma omp simd reduction(+ : ival) simdlen(32)
      for (int k = 0; k < GS; k++) {
        ival += ((int32_t) xqp[k]) * ((int32_t) wqp[k]);
      }
      val += ((float) ival) * ws[(in + j) / GS] * xs[j / GS];
      ival = 0;
    }
    
    xout[i] = val;
  }
}

// multiply int8_t, add results pairwise twice and return as float vector
static inline __m256 mul_sum_i8_pairs_float(const __m256i x, const __m256i y) {
  // Get absolute values of x vectors
  const __m256i ax = _mm256_sign_epi8(x, x);
  // Sign the values of the y vectors
  const __m256i sy = _mm256_sign_epi8(y, x);
  // Perform multiplication and create 16-bit values
  const __m256i dot = _mm256_maddubs_epi16(ax, sy);
  const __m256i ones = _mm256_set1_epi16(1);
  const __m256i summed_pairs = _mm256_madd_epi16(ones, dot);
  return _mm256_cvtepi32_ps(summed_pairs);
}

static inline float dotprod_int8_int8_old(int8_t* x, int8_t* w, int size, float scale) {
  // dot product of two int8 vectors
  // x and w are quantized, o is unquantized
  // size is the number of elements in each vector
  
  // Initialize accumulator with zeros
  __m256 acc = _mm256_setzero_ps();

  // Scale factor for the quantized values
  __m256 d = _mm256_set1_ps(scale);
  
  // First 32 byte wise loop
  int i = 0;
  for (; (i + 32) < size; i += 32) {
    
    // Load 32 int8 values from x and w
    __m256i qx = _mm256_loadu_si256((__m256i*)&x[i]);
    __m256i qy = _mm256_loadu_si256((__m256i*)&w[i]);
    
    const __m256 q = mul_sum_i8_pairs_float(qx, qy);
    
    // Multiply q with scale and accumulate
    acc = _mm256_fmadd_ps(d, q, acc);

  }

  // Handle remaining elements
  for (; i < size; i++) {
    // For the remaining elements, we can use a scalar operation
    acc = _mm256_add_ps(acc, _mm256_set1_ps(((float)x[i] * (float)w[i]) * scale));
  }

  // Reduce the accumulator to a single float value
  __m128 res = _mm256_extractf128_ps(acc, 1);
  res = _mm_add_ps(res, _mm256_castps256_ps128(acc));
  res = _mm_add_ps(res, _mm_movehl_ps(res, res));
  res = _mm_add_ss(res, _mm_movehdup_ps(res));
  return _mm_cvtss_f32(res);  

}

static inline int32_t dotprod_int8_int8(int8_t* x, int8_t* w, int size) {

  // Initialize integer accumulator with zeros
  __m256i accumulator = _mm256_setzero_si256();

  // Set start index for the loop
  int i = 0;

  // Check if size is large enough for 64 byte wise loop 
  if(size >= 64){ 
    
    // 64 byte wise loop
    for(; (i + 63) < size; i += 64){

      // Load first 32 int8 values from x and w
      __m256i qx0 = _mm256_loadu_si256((__m256i*)&x[i]);
      __m256i qy0 = _mm256_loadu_si256((__m256i*)&w[i]);

      // Load second 32 int8 values from x and w
      __m256i qx1 = _mm256_loadu_si256((__m256i*)&x[i + 32]);
      __m256i qy1 = _mm256_loadu_si256((__m256i*)&w[i + 32]);

    // Sign-extend bytes → 16-bit lanes for both chunks
      __m128i qx0_lo_128 = _mm256_castsi256_si128(qx0);
      __m128i qx0_hi_128 = _mm256_extracti128_si256(qx0, 1);
      __m128i qx1_lo_128 = _mm256_castsi256_si128(qx1);
      __m128i qx1_hi_128 = _mm256_extracti128_si256(qx1, 1);

      __m128i qy0_lo_128 = _mm256_castsi256_si128(qy0);
      __m128i qy0_hi_128 = _mm256_extracti128_si256(qy0, 1);
      __m128i qy1_lo_128 = _mm256_castsi256_si128(qy1);
      __m128i qy1_hi_128 = _mm256_extracti128_si256(qy1, 1);

      __m256i qx0_lo = _mm256_cvtepi8_epi16(qx0_lo_128);
      __m256i qx0_hi = _mm256_cvtepi8_epi16(qx0_hi_128);
      __m256i qx1_lo = _mm256_cvtepi8_epi16(qx1_lo_128);
      __m256i qx1_hi = _mm256_cvtepi8_epi16(qx1_hi_128);

      __m256i qy0_lo = _mm256_cvtepi8_epi16(qy0_lo_128);
      __m256i qy0_hi = _mm256_cvtepi8_epi16(qy0_hi_128);
      __m256i qy1_lo = _mm256_cvtepi8_epi16(qy1_lo_128);
      __m256i qy1_hi = _mm256_cvtepi8_epi16(qy1_hi_128);

      // Multiply and add block 0
      accumulator = _mm256_add_epi32(accumulator, _mm256_madd_epi16(qx0_lo, qy0_lo));
      accumulator = _mm256_add_epi32(accumulator, _mm256_madd_epi16(qx0_hi, qy0_hi));

      // Multiply and add block 1
      accumulator = _mm256_add_epi32(accumulator, _mm256_madd_epi16(qx1_lo, qy1_lo));
      accumulator = _mm256_add_epi32(accumulator, _mm256_madd_epi16(qx1_hi, qy1_hi));
    
    }

  }else{  

    // 32 byte wise loop
    for(; (i + 31) < size; i += 32){

      // Load 32 int8 values from x and w
      __m256i qx = _mm256_loadu_si256((__m256i*)&x[i]);
      __m256i qy = _mm256_loadu_si256((__m256i*)&w[i]);

      // Split 256 => 2x128 bits and sign-extend each byte to 16-bit lanes
      __m128i qx_lo_128 = _mm256_castsi256_si128(qx);
      __m128i qx_hi_128 = _mm256_extracti128_si256(qx, 1);
      __m128i qy_lo_128 = _mm256_castsi256_si128(qy);
      __m128i qy_hi_128 = _mm256_extracti128_si256(qy, 1);

      __m256i qx_lo = _mm256_cvtepi8_epi16(qx_lo_128);
      __m256i qx_hi = _mm256_cvtepi8_epi16(qx_hi_128);
      __m256i qy_lo = _mm256_cvtepi8_epi16(qy_lo_128);
      __m256i qy_hi = _mm256_cvtepi8_epi16(qy_hi_128);

      // Multiply and add pairs of 16-bit lanes => accumulate 32-bit results
      accumulator = _mm256_add_epi32(accumulator, _mm256_madd_epi16(qx_lo, qy_lo));
      accumulator = _mm256_add_epi32(accumulator, _mm256_madd_epi16(qx_hi, qy_hi));
    }

  }

  // Horizontally sum the 32-bit integers in accumulator
 __m128i lo128  = _mm256_castsi256_si128(accumulator);
 __m128i hi128  = _mm256_extracti128_si256(accumulator, 1);
 __m128i sum128 = _mm_add_epi32(lo128, hi128);           // [a0+a4, a1+a5, a2+a6, a3+a7]
 sum128 = _mm_hadd_epi32(sum128, sum128);                // [a0+...+a3+a5, ..., ..., ...]
 sum128 = _mm_hadd_epi32(sum128, sum128);                // [total, ..., ..., ...]
 int32_t res = _mm_cvtsi128_si32(sum128);

  // Handle any remaining elements scalar-wise without any SIMD
  for(; i < size; i++){
    res += ((int32_t)x[i]) * ((int32_t)w[i]);
  }

  return res;
}

__attribute__((ms_abi)) void quantizedPartlyMatMul(float* xout, int8_t *xq, float *xs, int8_t *wq, float *ws, int n, int a, int b, int GS){
  // W (d,n) @ x (n,) -> xout (d,)
  // by far the most amount of time is spent inside this little function
  // inputs to this function are both quantized 
  for(int i = a; i <= b; i++){
    float val = 0.0f;
    for(int j = 0, k = n - GS, in = i * n; j <= k; j += GS){
      val += (float)dotprod_int8_int8(&xq[j], &wq[in + j], GS) * (ws[(in + j) / GS] * xs[j / GS]);
    }    
    xout[i] = val;
  }
}

__attribute__((ms_abi)) void quantizedPartlyMatMulQ80_Q80(float* xout, int8_t *xq, float *xs, int8_t *wq, float *ws, int n, int a, int b, int GS){
  // W (d,n) @ x (n,) -> xout (d,)
  // by far the most amount of time is spent inside this little function
  // inputs to this function are both quantized
  
  for(int i = a; i <= b; i++){
    
    float val = 0.0f;
    int32_t ival = 0;
    int in = i * n;
    
    // do the matmul in groups of GS
    int j;
    for(j = 0; j <= n - GS; j += GS){
      int8_t* xqp = &xq[j];
      int8_t* wqp = &wq[in + j];
      for (int k = 0; k < GS; k++) {
        ival += ((int32_t) xqp[k]) * ((int32_t) wqp[k]);
      }
      val += ((float) ival) * ws[(in + j) / GS] * xs[j / GS];
      ival = 0;
    }
    
    xout[i] = val;
  }
}

__attribute__((ms_abi)) void quantizedPartlyMatMulQ80_Q80_Q80(int8_t* xout, float* xsout, int8_t *xq, float *xs, int8_t *wq, float *ws, int n, int a, int b, int GS){
  // W (d,n) @ x (n,) -> xout (d,) for quantized output and xsout (d,) for scaling
  // by far the most amount of time is spent inside this little function
  // inputs to this function are both quantized, as well as the output

  int32_t countGroups = n / GS; // Number of groups

  float values[GS]; // Temporary storage for values

  for(int32_t outputGroup = a; outputGroup < b; outputGroup++){

    int32_t outputBaseIndex = outputGroup * GS; // Base index for the output group

    float maxValue = 0.0f;

    for(int32_t outputRelativeIndex = 0; outputRelativeIndex < GS; outputRelativeIndex++){

      int32_t outputIndex = outputBaseIndex + outputRelativeIndex; // Calculate the output index

      int32_t inputBaseIndex = outputIndex * n; // Base index for the input group

      float value = 0.0f;
      for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){
        int32_t inputGroupBaseIndex = groupIndex * GS; // Base index for the input group
        int8_t* xqp = &xq[inputGroupBaseIndex]; // Pointer to the input quantized vector
        int8_t* wqp = &wq[inputBaseIndex + inputGroupBaseIndex]; // Pointer to the weight quantized vector
        int32_t valueInt = 0;
        for(int index = 0; index < GS; index++){
          valueInt += ((int32_t) xqp[index]) * ((int32_t) wqp[index]);
        }
        value += ((float) valueInt) * ws[(inputBaseIndex + inputGroupBaseIndex) / GS] * xs[inputGroupBaseIndex];
      }

      values[outputRelativeIndex] = value; // Store the value for this output relative index

      value = fabsf(value); // Calculate the absolute value for comparison
      if(maxValue < value){
        maxValue = value; // Update the maximum value if the current value is larger
      }
      
    }

    if(maxValue > 0.0f){
      const float Q_MAX = 127.0f; // Maximum value for quantized int8
      const float scale = maxValue / Q_MAX;
      // If the maximum value exceeds the threshold, scale down the values
      for(int32_t outputRelativeIndex = 0; outputRelativeIndex < GS; outputRelativeIndex++){
        xout[outputBaseIndex + outputRelativeIndex] = (int8_t)roundf(values[outputRelativeIndex] / scale); // Quantize the value
      }
      xsout[outputGroup] = maxValue; // Store the maximum value for this output group
    }else{  
      // If the maximum value is zero, set all quantized values to zero
      for(int32_t outputRelativeIndex = 0; outputRelativeIndex < GS; outputRelativeIndex++){
        xout[outputBaseIndex + outputRelativeIndex] = 0; // Set to zero
      }
      xsout[outputGroup] = 0.0f; // Store zero for the maximum value 
    }
  
  }

}

__attribute__((ms_abi)) void quantizedPartlyMatMulQ40_Q80(float* xout, int8_t *xq, float *xs, uint8_t *wq, float *ws, int n, int a, int b, int GS){
  // W (d,n) @ x (n,) -> xout (d,)
  // by far the most amount of time is spent inside this little function
  // inputs to this function are both quantized

  // assume GS is always divisible by 2
  int32_t countGroups = n / GS; // number of groups
  int32_t halfGroupSize = GS >> 1; // half group size for 4-bit quantization

  for(int i = a; i <= b; i++){
    
    float val = 0.0f;
    int32_t in = i * n;
    
    for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){
      uint8_t* wqp = &wq[(in + (groupIndex * GS)) >> 1];
      int8_t* xqp = &xq[groupIndex * GS];
      int32_t ival = 0;
      //#pragma omp simd reduction(+ : ival) simdlen(32)
      for (int k = 0; k < halfGroupSize; k++){
        uint8_t wqv = *wqp++;
        ival += ((int32_t)(*xqp++)) * (((int32_t)(wqv & 0x0f)) - 8);
        ival += ((int32_t)(*xqp++)) * (((int32_t)(wqv >> 4)) - 8);
      }    
      val += ((float)ival) * ws[(in + (groupIndex * GS)) / GS] * xs[groupIndex];
    }

    xout[i] = val;
  }
}

/*
__attribute__((ms_abi)) void quantizedPartlyMatMulQ40_Q80(float* xout, int8_t *xq, float *xs, uint8_t *wq, float *ws, int n, int a, int b, int GS){
  // W (d,n) @ x (n,) -> xout (d,)
  // by far the most amount of time is spent inside this little function
  // inputs to this function are both quantized
    
  for(int i = a; i <= b; i++){
    
    float val = 0.0f;
    int32_t ival = 0;
    int32_t in = i * n;
    
    // do the matmul in groups of GS
    int32_t j;
    for(j = 0; j <= n - GS; j += GS){
      int8_t* xqp = &xq[j];
      int32_t wqi = in + j;
      for (int k = 0; (k + 1) < GS; k += 2) {
        uint8_t wqv = wq[(wqi + k) >> 1];
        ival += ((int32_t) xqp[k]) * (((int32_t)(wqv & 0x0f)) - 8);
        ival += ((int32_t) xqp[k + 1]) * (((int32_t)(wqv >> 4)) - 8);
      }
      val += ((float) ival) * ws[(in + j) / GS] * xs[j / GS];
      ival = 0;
    }
    
    xout[i] = val;
  }
}
*/

__attribute__((ms_abi)) void quantizedPartlyMatMulQ40_Q40(float* xout, uint8_t *xq, float *xs, uint8_t *wq, float *ws, int n, int a, int b, int GS){
  // W (d,n) @ x (n,) -> xout (d,)
  // by far the most amount of time is spent inside this little function
  // inputs to this function are both quantized
  
  for(int i = a; i <= b; i++){
    
    float val = 0.0f;
    int32_t ival = 0;
    int32_t in = i * n;
    
    // do the matmul in groups of GS
    int32_t j;
    for(j = 0; j <= n - GS; j += GS){
      int8_t* xqp = &xq[j];
      int32_t xqi = j;
      int32_t wqi = in + j;
      for (int k = 0; (k + 1) < GS; k += 2) {
        uint8_t xqv = xqp[(xqi + k) >> 1];
        uint8_t wqv = wq[(wqi + k) >> 1];
        ival += (((int32_t)(xqv & 0x0f)) - 8) * (((int32_t)(wqv & 0x0f)) - 8);
        ival += (((int32_t)(xqv >> 4)) - 8) * (((int32_t)(wqv >> 4)) - 8);
      }
      val += ((float) ival) * ws[(in + j) / GS] * xs[j / GS];
      ival = 0;
    }
    
    xout[i] = val;
  }
}


// Quantize a float vector into Q80 format (int8 values with grouped scaling factors)
__attribute__((ms_abi)) void quantizeq80(float *x, int8_t *q, float *s, const int32_t count, const int32_t groupSize){
  const float Q_MAX = 127.0f; // max value for int8_t
  const int countGroups = count / groupSize; // number of groups
  for(int groupIndex = 0; groupIndex < countGroups; groupIndex++){

    // Calculate the base index for the current group
    int baseIndex = groupIndex * groupSize;

    // find the max absolute value in the current group
    float maxValue = 0.0f;
    for(int index = 0; index < groupSize; index++){
      const float value = fabsf(x[baseIndex + index]);
      if(maxValue < value){
        maxValue = value;
      }
    }
    
    // calculate the scaling factor
    const float scale = maxValue / Q_MAX;
    
    // calculate and write the quantized values and the scaling factor
    if(scale < 1e-6f){
      // If the scale is too small, set all values to zero
      s[groupIndex] = 0.0;
      for(int index = 0; index < groupSize; index++){
        q[baseIndex + index] = 0; // Set to zero if scale is too small
      }
    }else{
      s[groupIndex] = scale;
      for(int index = 0; index < groupSize; index++){
        q[baseIndex + index] = (int8_t)roundf(x[baseIndex + index] / scale); // round and clamp
      }
    }
      
  }

}

// Dequantize a Q80 format vector (int8 values with grouped scaling factors) into a float vector
__attribute__((ms_abi)) void dequantizeq80(float *x, int8_t *q, float *s, const int32_t count, const int32_t groupSize){
  const int countGroups = count / groupSize; // number of groups
  for (int groupIndex = 0; groupIndex < countGroups; groupIndex++){
    // Calculate the base index for the current group
    int baseIndex = groupIndex * groupSize;
    // Get the scale for this group
    float scale = s[groupIndex];
    // Dequantize each value in the group
    for (int index = 0; index < groupSize; index++) {
      x[baseIndex + index] = q[baseIndex + index] * scale;
    }
  }
}

// Quantize a float vector into Q40 format (int8 values with grouped scaling factors)
__attribute__((ms_abi)) void quantizeq40(float *x, uint8_t *q, float *s, const int32_t count, const int32_t groupSize){
  const float Q_MAX = 7.0f; // max value for 4-bit quantization
  const int countGroups = count / groupSize; // number of groups
  for(int groupIndex = 0; groupIndex < countGroups; groupIndex++){

    // Calculate the base index for the current group
    int baseIndex = groupIndex * groupSize;

    // find the max absolute value in the current group
    float maxValue = 0.0f;
    for(int index = 0; index < groupSize; index++){
      const float value = fabsf(x[baseIndex + index]);
      if(maxValue < value){
        maxValue = value;
      }
    }
    
    // calculate the scaling factor
    const float scale = maxValue / Q_MAX;
    
    // calculate and write the quantized values and the scaling factor
    if(scale < 1e-6f){
      // If the scale is too small, set all values to zero
      s[groupIndex] = 0.0;
      for(int index = 0; index < groupSize; index += 2){
        q[(baseIndex + index) >> 1] = 0; // Set to zero if scale is too small
      }
    }else{
      s[groupIndex] = scale;
      for(int index = 0; (index + 1) < groupSize; index += 2){
        // Two 4-bit values are packed into one byte
        q[(baseIndex + index) >> 1] = (((uint8_t)((int8_t)roundf(x[baseIndex + index + 0] / scale) + 8) & 0x0f) << 0) |
                                      (((uint8_t)((int8_t)roundf(x[baseIndex + index + 1] / scale) + 8) & 0x0f) << 4);
        
      }
    }

  }

}

// Dequantize a Q40 format vector (4-bit integer values with grouped scaling factors) into a float vector
__attribute__((ms_abi)) void dequantizeq40(float *x, uint8_t *q, float *s, const int32_t count, const int32_t groupSize){
  const int countGroups = count / groupSize;
  for (int groupIndex = 0; groupIndex < countGroups; groupIndex++){
    int baseIndex = groupIndex * groupSize;
    float scale = s[groupIndex];
    for (int index = 0; (index + 1) < groupSize; index += 2) {
      x[baseIndex + index + 0] = ((int8_t)(q[(baseIndex + index) >> 1] & 0x0f) - 8) * scale;
      x[baseIndex + index + 1] = ((int8_t)(q[(baseIndex + index) >> 1] >> 4) - 8) * scale;
    }
  }
}

///

__attribute__((always_inline)) inline float FP8E5M2ToFP32(uint8_t v){
  union {
    uint16_t u;
    _Float16 f;
  } u;
  u.u = v << 8;
  return u.f;
}

__attribute__((always_inline)) inline uint8_t FP32ToFP8E5M2(float v){
  union {
    uint16_t u;
    _Float16 f;
  } u;
  u.f = v;
  return u.u >> 8;
}

__attribute__((always_inline)) inline float BF16ToFP32(uint16_t v){
  union {
    uint32_t u;
    float f;
  } u;
  u.u = (uint32_t)v << 16; // Shift to the left to convert BF16 to FP32
  return u.f;
}

__attribute__((always_inline)) inline uint16_t FP32ToBF16(float v){
  union {
    uint32_t u;
    float f;
  } u;
  u.f = v;
  return u.u >> 16; // Shift to the right to convert FP32 to BF16
}

__attribute__((always_inline)) inline uint32_t encodeQ3F8(float v0, 
                                                          float v1, 
                                                          float v2, 
                                                          float v3, 
                                                          float v4,
                                                          float v5, 
                                                          float v6, 
                                                          float v7){ 

  // First, find the maximum absolute value
  float maxValue = fabsf(v0);
  maxValue = fmaxf(maxValue, fabsf(v1));
  maxValue = fmaxf(maxValue, fabsf(v2));
  maxValue = fmaxf(maxValue, fabsf(v3));
  maxValue = fmaxf(maxValue, fabsf(v4));
  maxValue = fmaxf(maxValue, fabsf(v5));
  maxValue = fmaxf(maxValue, fabsf(v6));  
  maxValue = fmaxf(maxValue, fabsf(v7));

  // Then ensuring that the maximum value has the right rounded quantization range by converting it to FP8E5M2 and back to Float32 
  maxValue = FP8E5M2ToFP32(FP32ToFP8E5M2(maxValue));

  // If the maximum value is zero, we return zero in order to avoid division by zero 
  if(maxValue < 0.00001f){
    return 0; // all values are zero
  }

  // Normalize the values by the maximum value
  v0 /= maxValue;
  v1 /= maxValue;
  v2 /= maxValue;
  v3 /= maxValue;
  v4 /= maxValue;
  v5 /= maxValue;
  v6 /= maxValue;
  v7 /= maxValue;

  // Encode the Q3F8 32-bit value
  uint32_t result = (FP32ToFP8E5M2(maxValue) & 0xff) | // Store the scale factor in the lowest byte as fp8e5m2
                    ((uint32_t)((uint32_t)roundf(fminf(fmaxf(4.0f - (v0 * 4.0f), 0.0f), 7.0f)) & 0x07) << 8) | // Store the values as a 3-bit signed integers, quantized to the range -4 to 3
                    ((uint32_t)((uint32_t)roundf(fminf(fmaxf(4.0f - (v1 * 4.0f), 0.0f), 7.0f)) & 0x07) << 11) |
                    ((uint32_t)((uint32_t)roundf(fminf(fmaxf(4.0f - (v2 * 4.0f), 0.0f), 7.0f)) & 0x07) << 14) |
                    ((uint32_t)((uint32_t)roundf(fminf(fmaxf(4.0f - (v3 * 4.0f), 0.0f), 7.0f)) & 0x07) << 17) |
                    ((uint32_t)((uint32_t)roundf(fminf(fmaxf(4.0f - (v4 * 4.0f), 0.0f), 7.0f)) & 0x07) << 20) |
                    ((uint32_t)((uint32_t)roundf(fminf(fmaxf(4.0f - (v5 * 4.0f), 0.0f), 7.0f)) & 0x07) << 23) |
                    ((uint32_t)((uint32_t)roundf(fminf(fmaxf(4.0f - (v6 * 4.0f), 0.0f), 7.0f)) & 0x07) << 26) |
                    ((uint32_t)((uint32_t)roundf(fminf(fmaxf(4.0f - (v7 * 4.0f), 0.0f), 7.0f)) & 0x07) << 29);

  return result;
}

__attribute__((always_inline)) inline void decodeQ3F8(uint32_t v,
                                                      float *v0, 
                                                      float *v1, 
                                                      float *v2, 
                                                      float *v3, 
                                                      float *v4, 
                                                      float *v5, 
                                                      float *v6, 
                                                      float *v7) {
  // Extract the scale factor from the lowest byte
  float scale = FP8E5M2ToFP32(v & 0xff) * -0.25f; // Convert to float and scale
  // Extract the quantized values and convert them to floats
  *v0 = ((int)((v >> 8) & 7) - 4) * scale;
  *v1 = ((int)((v >> 11) & 7) - 4) * scale;
  *v2 = ((int)((v >> 14) & 7) - 4) * scale;
  *v3 = ((int)((v >> 17) & 7) - 4) * scale;
  *v4 = ((int)((v >> 20) & 7) - 4) * scale;
  *v5 = ((int)((v >> 23) & 7) - 4) * scale;
  *v6 = ((int)((v >> 26) & 7) - 4) * scale;
  *v7 = ((int)((v >> 29) & 7) - 4) * scale;
}

// Quantize a float vector into Q3F8 format
__attribute__((ms_abi)) void quantizeQ3F8(float *x, uint32_t *q, const int32_t count){
  int i = 0, j = 0;
  for(; (i + 7) < count; i += 8) {
    // Encode 8 floats into a single Q3F8 value
    uint32_t encodedValue = encodeQ3F8(x[i], x[i + 1], x[i + 2], x[i + 3], x[i + 4], x[i + 5], x[i + 6], x[i + 7]);
    // Store the encoded value in the output array
    q[j++] = encodedValue;
  }
  // Handle remaining values if count is not a multiple of 8
  if (i < count) {
    // Encode the remaining values, padding with zeros if necessary
    uint32_t encodedValue = encodeQ3F8(
      (i < count ? x[i] : 0.0f), 
      ((i + 1) < count ? x[i + 1] : 0.0f),
      ((i + 2) < count ? x[i + 2] : 0.0f), 
      ((i + 3) < count ? x[i + 3] : 0.0f), 
      ((i + 4) < count ? x[i + 4] : 0.0f), 
      ((i + 5) < count ? x[i + 5] : 0.0f), 
      ((i + 6) < count ? x[i + 6] : 0.0f), 
      ((i + 7) < count ? x[i + 7] : 0.0f));
    // Store the encoded value in the output array
    q[j++] = encodedValue;
  }
  // Fill the rest of the output array with zeros if necessary
  int m = (count + 7) / 8; // Calculate the number of 32-bit integers needed
  for (; j < m; j++) {
    q[j] = 0; // Fill with zero if there are not enough values to encode
  }
}

// Dequantize a float vector from Q3F8 format
__attribute__((ms_abi)) void dequantizeQ3F8(float *x, uint32_t *q, const int32_t count){

  for (int i = 0; i < count; i += 8) {
    // Decode 8 Q3F8 values into floats
    uint32_t encodedValue = q[i >> 3];
    decodeQ3F8(
      encodedValue, 
      &x[i], 
      &x[i + 1], 
      &x[i + 2], 
      &x[i + 3], 
      &x[i + 4], 
      &x[i + 5], 
      &x[i + 6], 
      &x[i + 7]
    );
  }

}

__attribute__((always_inline)) inline uint64_t encodeQ7F8(float v0, 
                                                          float v1, 
                                                          float v2, 
                                                          float v3, 
                                                          float v4,
                                                          float v5, 
                                                          float v6, 
                                                          float v7){ 

  // First, find the maximum absolute value
  float maxValue = fabsf(v0);
  maxValue = fmaxf(maxValue, fabsf(v1));
  maxValue = fmaxf(maxValue, fabsf(v2));
  maxValue = fmaxf(maxValue, fabsf(v3));
  maxValue = fmaxf(maxValue, fabsf(v4));
  maxValue = fmaxf(maxValue, fabsf(v5));
  maxValue = fmaxf(maxValue, fabsf(v6));  
  maxValue = fmaxf(maxValue, fabsf(v7));

  // Then ensuring that the maximum value has the right rounded quantization range by converting it to FP8E5M2 and back to Float32 
  maxValue = FP8E5M2ToFP32(FP32ToFP8E5M2(maxValue));

  // If the maximum value is zero, we return zero in order to avoid division by zero 
  if(maxValue < 0.00001f){
    return 0; // all values are zero
  }

  // Normalize the values by the maximum value
  v0 /= maxValue;
  v1 /= maxValue;
  v2 /= maxValue;
  v3 /= maxValue;
  v4 /= maxValue;
  v5 /= maxValue;
  v6 /= maxValue;
  v7 /= maxValue;

  // Encode the Q7F8 32-bit value
  uint64_t result = (FP32ToFP8E5M2(maxValue) & 0xff) | // Store the scale factor in the lowest byte as fp8e5m2
                    ((uint64_t)((uint64_t)roundf(fminf(fmaxf(64.0f - (v0 * 64.0f), 0.0f), 127.0f)) & 0x7f) << (8 + (0 * 7))) | // Store the values as a 7-bit signed integers, quantized to the range -4 to 3
                    ((uint64_t)((uint64_t)roundf(fminf(fmaxf(64.0f - (v1 * 64.0f), 0.0f), 127.0f)) & 0x7f) << (8 + (1 * 7))) |
                    ((uint64_t)((uint64_t)roundf(fminf(fmaxf(64.0f - (v2 * 64.0f), 0.0f), 127.0f)) & 0x7f) << (8 + (2 * 7))) |
                    ((uint64_t)((uint64_t)roundf(fminf(fmaxf(64.0f - (v3 * 64.0f), 0.0f), 127.0f)) & 0x7f) << (8 + (3 * 7))) |
                    ((uint64_t)((uint64_t)roundf(fminf(fmaxf(64.0f - (v4 * 64.0f), 0.0f), 127.0f)) & 0x7f) << (8 + (4 * 7))) |
                    ((uint64_t)((uint64_t)roundf(fminf(fmaxf(64.0f - (v5 * 64.0f), 0.0f), 127.0f)) & 0x7f) << (8 + (5 * 7))) |
                    ((uint64_t)((uint64_t)roundf(fminf(fmaxf(64.0f - (v6 * 64.0f), 0.0f), 127.0f)) & 0x7f) << (8 + (6 * 7))) |
                    ((uint64_t)((uint64_t)roundf(fminf(fmaxf(64.0f - (v7 * 64.0f), 0.0f), 127.0f)) & 0x7f) << (8 + (7 * 7)));

  return result;
}

__attribute__((always_inline)) inline void decodeQ7F8(uint64_t v,
                                                      float *v0, 
                                                      float *v1, 
                                                      float *v2, 
                                                      float *v3, 
                                                      float *v4, 
                                                      float *v5, 
                                                      float *v6, 
                                                      float *v7) {
  // Extract the scale factor from the lowest byte
  float scale = FP8E5M2ToFP32(v & 0xff) * -0.015625f; // Convert to float and scale
  // Extract the quantized values and convert them to floats
  *v0 = ((int32_t)((v >> (8 + (0 * 7))) & 127) - 64) * scale;
  *v1 = ((int32_t)((v >> (8 + (1 * 7))) & 127) - 64) * scale;
  *v2 = ((int32_t)((v >> (8 + (2 * 7))) & 127) - 64) * scale;
  *v3 = ((int32_t)((v >> (8 + (3 * 7))) & 127) - 64) * scale;
  *v4 = ((int32_t)((v >> (8 + (4 * 7))) & 127) - 64) * scale;
  *v5 = ((int32_t)((v >> (8 + (5 * 7))) & 127) - 64) * scale;
  *v6 = ((int32_t)((v >> (8 + (6 * 7))) & 127) - 64) * scale;
  *v7 = ((int32_t)((v >> (8 + (7 * 7))) & 127) - 64) * scale;
}

// Quantize a float vector into Q7F8 format
__attribute__((ms_abi)) void quantizeQ7F8(float *x, uint64_t *q, const int32_t count){
  int i = 0, j = 0;
  for(; (i + 7) < count; i += 8) {
    // Encode 8 floats into a single Q7F8 value
    uint64_t encodedValue = encodeQ7F8(x[i], x[i + 1], x[i + 2], x[i + 3], x[i + 4], x[i + 5], x[i + 6], x[i + 7]);
    // Store the encoded value in the output array
    q[j++] = encodedValue;
  }
  // Handle remaining values if count is not a multiple of 8
  if (i < count) {
    // Encode the remaining values, padding with zeros if necessary
    uint64_t encodedValue = encodeQ7F8(
      (i < count ? x[i] : 0.0f), 
      ((i + 1) < count ? x[i + 1] : 0.0f),
      ((i + 2) < count ? x[i + 2] : 0.0f), 
      ((i + 3) < count ? x[i + 3] : 0.0f), 
      ((i + 4) < count ? x[i + 4] : 0.0f), 
      ((i + 5) < count ? x[i + 5] : 0.0f), 
      ((i + 6) < count ? x[i + 6] : 0.0f), 
      ((i + 7) < count ? x[i + 7] : 0.0f));
    // Store the encoded value in the output array
    q[j++] = encodedValue;
  }
  // Fill the rest of the output array with zeros if necessary
  int m = (count + 7) / 8; // Calculate the number of 32-bit integers needed
  for (; j < m; j++) {
    q[j] = 0; // Fill with zero if there are not enough values to encode
  }
}

// Dequantize a float vector from Q7F8 format
__attribute__((ms_abi)) void dequantizeQ7F8(float *x, uint64_t *q, const int32_t count){

  for (int i = 0; i < count; i += 8) {
    // Decode 8 Q7F8 values into floats
    uint64_t encodedValue = q[i >> 3];
    decodeQ7F8(
      encodedValue, 
      &x[i], 
      &x[i + 1], 
      &x[i + 2], 
      &x[i + 3], 
      &x[i + 4], 
      &x[i + 5], 
      &x[i + 6], 
      &x[i + 7]
    );
  }

}

__attribute__((ms_abi)) void quantizedPartlyMatMulQ3F8_F8E5M2(float* xout, uint8_t *xq, uint32_t *wq, int n, int a, int b, int GS){
  // W (d,n) @ x (n,) -> xout (d,)
  // by far the most amount of time is spent inside this little function
  // inputs to this function are both quantized

  // assume GS is always divisible by 8
  int32_t countGroups = n / GS; // number of groups
  int32_t Q3F8GroupSize = GS >> 3; // group size for Q3F8 quantization (8 floats per 32-bit value)

  for(int i = a; i <= b; i++){
    
    float val = 0.0f;
    int32_t in = i * n;
    
    for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){
      uint32_t* wqp = &wq[(in + (groupIndex * GS)) >> 3];
      uint8_t* xqp = &xq[groupIndex * GS];
      float fval = 0.0f;
      //#pragma omp simd reduction(+ : fval) simdlen(32)
      for (int k = 0; k < Q3F8GroupSize; k++){
        uint32_t wqv = *wqp++;
        fval += (
          (FP8E5M2ToFP32(xqp[0]) * ((float)(((wqv >> (8 + (0 * 3))) & 7) - 4))) +
          (FP8E5M2ToFP32(xqp[1]) * ((float)(((wqv >> (8 + (1 * 3))) & 7) - 4))) +
          (FP8E5M2ToFP32(xqp[2]) * ((float)(((wqv >> (8 + (2 * 3))) & 7) - 4))) +
          (FP8E5M2ToFP32(xqp[3]) * ((float)(((wqv >> (8 + (3 * 3))) & 7) - 4))) +
          (FP8E5M2ToFP32(xqp[4]) * ((float)(((wqv >> (8 + (4 * 3))) & 7) - 4))) +
          (FP8E5M2ToFP32(xqp[5]) * ((float)(((wqv >> (8 + (5 * 3))) & 7) - 4))) +
          (FP8E5M2ToFP32(xqp[6]) * ((float)(((wqv >> (8 + (6 * 3))) & 7) - 4))) +
          (FP8E5M2ToFP32(xqp[7]) * ((float)(((wqv >> (8 + (7 * 3))) & 7) - 4)))
        ) * (FP8E5M2ToFP32(wqv & 0xff) * -0.25f); // Apply the scale factor
        xqp += 8; // Move to the next 8 elements
      }
      val += fval;
    }  
     
    xout[i] = val;
  }
}

__attribute__((ms_abi)) void quantizedPartlyMatMulQ3F8_Q80_Reference(float* xout, int8_t *xq, float *xs, uint32_t *wq, int n, int a, int b, int GS){
  // W (d,n) @ x (n,) -> xout (d,)
  // by far the most amount of time is spent inside this little function
  // inputs to this function are both quantized

  // assume GS is always divisible by 8
  int32_t countGroups = n / GS; // number of groups
  int32_t Q3F8GroupSize = GS >> 3; // group size for Q3F8 quantization (8 floats per 32-bit value)

  for(int i = a; i <= b; i++){
    
    float val = 0.0f;
    int32_t in = i * n;
    
    for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){
      uint32_t* wqp = &wq[(in + (groupIndex * GS)) >> 3];
      int8_t* xqp = &xq[groupIndex * GS];
      float fval = 0.0f;
      #pragma omp simd reduction(+ : fval) simdlen(32)
      for (int k = 0; k < Q3F8GroupSize; k++){
        uint32_t wqv = *wqp++;
        int32_t wi[8] = {
          (((wqv >> (8 + (0 * 3))) & 7) - 4),
          (((wqv >> (8 + (1 * 3))) & 7) - 4),
          (((wqv >> (8 + (2 * 3))) & 7) - 4),
          (((wqv >> (8 + (3 * 3))) & 7) - 4),
          (((wqv >> (8 + (4 * 3))) & 7) - 4),
          (((wqv >> (8 + (5 * 3))) & 7) - 4),
          (((wqv >> (8 + (6 * 3))) & 7) - 4),
          (((wqv >> (8 + (7 * 3))) & 7) - 4)
        };

        // --- SIMD: Load 8 int8s and extend to int32 ---
        __m128i xq_vals_i8 = _mm_loadl_epi64((const __m128i*)xqp); // Loads 8 int8_t
        __m256i xq_vals_i32 = _mm256_cvtepi8_epi32(xq_vals_i8);

        // --- SIMD: Load wi into vector ---
        __m256i wi_vec = _mm256_loadu_si256((const __m256i*)wi);

        // --- SIMD: Multiply ---
        __m256i mul = _mm256_mullo_epi32(xq_vals_i32, wi_vec);

        // --- SIMD: Horizontal sum ---
        __m128i sum128 = _mm_add_epi32(_mm256_extracti128_si256(mul, 0), _mm256_extracti128_si256(mul, 1));
        // Two 128-bit halves, sum 8 ints
        sum128 = _mm_add_epi32(sum128, _mm_shuffle_epi32(sum128, _MM_SHUFFLE(2, 3, 0, 1)));
        sum128 = _mm_add_epi32(sum128, _mm_shuffle_epi32(sum128, _MM_SHUFFLE(1, 0, 3, 2)));
        int ival = _mm_cvtsi128_si32(sum128);

        // --- Scalar: decode scale (FP8E5M2) ---
        fval += (float)ival * FP8E5M2ToFP32(wqv & 0xff) * -0.25f;        

        xqp += 8; // Move to the next 8 elements
      }        
      val += fval * xs[groupIndex];
    }

    xout[i] = val;
  }
}

__attribute__((always_inline)) inline float dotprod_q3f8_q80(const uint32_t* w, const int8_t* xq, const float* xs, int32_t n, int32_t i, int32_t GS) {
    // w: Q3F8 weights, xq: Q80 input vector, xs: Q80 per-group scale, n: input length (must be multiple of 32), i: output row
    const uint32_t* r = w + ((i * n) >> 3); // Q3F8 block pointer
    __m256 acc0 = _mm256_setzero_ps(), acc1 = _mm256_setzero_ps();

    // assuming group size = 32
    for (int32_t j = 0; j < n; j += 32) {

        // Load xq in 4x8 blocks (8 int8 each), convert to float32 and apply scale
        __m128i xq0_i8 = _mm_loadl_epi64((const __m128i*)&xq[j +  0]);
        __m128i xq1_i8 = _mm_loadl_epi64((const __m128i*)&xq[j +  8]);
        __m128i xq2_i8 = _mm_loadl_epi64((const __m128i*)&xq[j + 16]);
        __m128i xq3_i8 = _mm_loadl_epi64((const __m128i*)&xq[j + 24]);

        // Dequantize xq[32] -> float, scale by xs[group]
        __m256 xscale = _mm256_set1_ps(xs[j / GS]);

        __m256 x0 = _mm256_mul_ps(_mm256_cvtepi32_ps(_mm256_cvtepi8_epi32(xq0_i8)), xscale);
        __m256 x1 = _mm256_mul_ps(_mm256_cvtepi32_ps(_mm256_cvtepi8_epi32(xq1_i8)), xscale);
        __m256 x2 = _mm256_mul_ps(_mm256_cvtepi32_ps(_mm256_cvtepi8_epi32(xq2_i8)), xscale);
        __m256 x3 = _mm256_mul_ps(_mm256_cvtepi32_ps(_mm256_cvtepi8_epi32(xq3_i8)), xscale);

        // Now Q3F8 weights
        __m128i wg = _mm_loadu_si128((const __m128i*)&r[j / 8]);
        // Extract FP8E5M2 scale (as before)
        const __m128i wgfm = _mm_setr_epi8(-1, 0, -1, 4, -1, 8, -1, 12, -1, -1, -1, -1, -1, -1, -1, -1);
        __m128 wgf = _mm_cvtph_ps(_mm_shuffle_epi8(wg, wgfm)); // 4 floats (one per 8-Q3F8 block)
        __m256 wgfp = _mm256_castsi256_ps(_mm256_broadcastsi128_si256(_mm_castps_si128(wgf)));
        // Bit-slice to 4x8 weights, exactly as in your code:
        __m256i wgp = _mm256_broadcastsi128_si256(wg);
        const __m256i wgbits = _mm256_setr_epi32(8, 11, 14, 17, 20, 23, 26, 29);
        const __m256 wgtab = _mm256_setr_ps(-4 / -4.f, -3 / -4.f, -2 / -4.f, -1 / -4.f, 0 / -4.f, 1 / -4.f, 2 / -4.f, 3 / -4.f);

        __m256 w0 = _mm256_permutevar8x32_ps(wgtab, _mm256_srlv_epi32(_mm256_shuffle_epi32(wgp, 0x00), wgbits));
        __m256 w1 = _mm256_permutevar8x32_ps(wgtab, _mm256_srlv_epi32(_mm256_shuffle_epi32(wgp, 0x55), wgbits));
        __m256 w2 = _mm256_permutevar8x32_ps(wgtab, _mm256_srlv_epi32(_mm256_shuffle_epi32(wgp, 0xaa), wgbits));
        __m256 w3 = _mm256_permutevar8x32_ps(wgtab, _mm256_srlv_epi32(_mm256_shuffle_epi32(wgp, 0xff), wgbits));

        // Apply the FP8E5M2 scale to weights (note: *per 8 elements, needs correct broadcasting)
        __m256 ws0 = _mm256_mul_ps(w0, _mm256_shuffle_ps(wgfp, wgfp, 0x00));
        __m256 ws1 = _mm256_mul_ps(w1, _mm256_shuffle_ps(wgfp, wgfp, 0x55));
        __m256 ws2 = _mm256_mul_ps(w2, _mm256_shuffle_ps(wgfp, wgfp, 0xaa));
        __m256 ws3 = _mm256_mul_ps(w3, _mm256_shuffle_ps(wgfp, wgfp, 0xff));

        // Fused dot-product accumulate
        acc0 = _mm256_add_ps(acc0, _mm256_mul_ps(ws0, x0));
        acc1 = _mm256_add_ps(acc1, _mm256_mul_ps(ws1, x1));
        acc0 = _mm256_add_ps(acc0, _mm256_mul_ps(ws2, x2));
        acc1 = _mm256_add_ps(acc1, _mm256_mul_ps(ws3, x3));
    }
    __m256 acc8 = _mm256_add_ps(acc0, acc1);
    __m128 acc4 = _mm_add_ps(_mm256_castps256_ps128(acc8), _mm256_extractf128_ps(acc8, 1));
    __m128 accf = _mm_dp_ps(acc4, _mm_set1_ps(1.0f), 0xf1);
    return _mm_cvtss_f32(accf);
}

__attribute__((ms_abi)) void quantizedPartlyMatMulQ3F8_Q80_Optimized(float* xout, int8_t *xq, float *xs, uint32_t *wq, int32_t n, int32_t a, int32_t b, int32_t GS) {

  // W (d,n) @ x (n,) -> xout (d,)
  // by far the most amount of time is spent inside this little function
  // inputs to this function are both quantized

  // Q3F8 is a quantization format where each 32-bit value contains 8 quantized float values, each represented by 3 bits, 
  // and a scale factor in the lowest byte as FP8E5M2 (= upper byte of FP16E5M11, so a 8-bit truncated 16-bit half float).

  // Q80 is a quantization format where each 8-bit value is a quantized float value with a FP32 scale factor in a separate array.

  // assume GS is always divisible by 32

  int32_t countGroups = n / GS; // number of groups
  int32_t Q3F8GroupSize = GS >> 5; 

  for(int32_t i = a; i <= b; i++){
   xout[i] = dotprod_q3f8_q80(wq, xq, xs, n, i, GS);
  }

}

__attribute__((ms_abi)) void quantizedPartlyMatMulF8E5M2_Q80(float* xout, uint8_t *xq, float *xs, int8_t *wq, int n, int a, int b, int GS){
  // W (d,n) @ x (n,) -> xout (d,)
  // by far the most amount of time is spent inside this little function
  // inputs to this function are both quantized
  
  for(int i = a; i <= b; i++){
    
    float val = 0.0f;
    int in = i * n;
    
    // do the matmul in groups of GS
    int j;
    for(j = 0; j <= n - GS; j += GS){
      int8_t* xqp = &xq[j];
      uint8_t* wqp = &wq[in + j];
      float sum = 0.0f;
      for (int k = 0; k < GS; k++) {
        sum += (float)(xqp[k]) * FP8E5M2ToFP32(wqp[k]); // Multiply and accumulate
      }
      val += sum * xs[j / GS];
    }
    
    xout[i] = val;
  }
}


__attribute__((ms_abi)) void quantizedPartlyMatMulF8E5M2_F8E5M2(float* xout, uint8_t *xq, uint8_t *wq, int n, int a, int b, int GS){
  // W (d,n) @ x (n,) -> xout (d,)
  // by far the most amount of time is spent inside this little function
  // inputs to this function are both quantized
  
  for(int i = a; i <= b; i++){
    
    float val = 0.0f;
    int in = i * n;
    
    // do the matmul in groups of GS
    int j;
    for(j = 0; j <= n - GS; j += GS){
      uint8_t* xqp = &xq[j];
      uint8_t* wqp = &wq[in + j];
      float sum = 0.0f;
      for (int k = 0; k < GS; k++) {
        sum += FP8E5M2ToFP32(xqp[k]) * FP8E5M2ToFP32(wqp[k]); // Multiply and accumulate
      }
      val += sum;
    }
    
    xout[i] = val;
  }
}

__attribute__((ms_abi)) void quantizedPartlyMatMulBF16_BF16(float* xout, uint16_t *xq, uint16_t *wq, int n, int a, int b, int GS){
  // W (d,n) @ x (n,) -> xout (d,)
  // by far the most amount of time is spent inside this little function
  // inputs to this function are both quantized
  
  for(int i = a; i <= b; i++){
    
    float val = 0.0f;
    int in = i * n;
    
    // do the matmul in groups of GS
    int j;
    for(j = 0; j <= n - GS; j += GS){
      uint16_t* xqp = &xq[j];
      uint16_t* wqp = &wq[in + j];
      float sum = 0.0f;
      for (int k = 0; k < GS; k++) {
        sum += BF16ToFP32(xqp[k]) * BF16ToFP32(wqp[k]); // Multiply and accumulate
      }
      val += sum;
    }
    
    xout[i] = val;
  }
}

__attribute__((ms_abi)) void quantizedPartlyMatMulF16_F16(float* xout, _Float16 *xq, _Float16 *wq, int n, int a, int b, int GS){
  // W (d,n) @ x (n,) -> xout (d,)
  // by far the most amount of time is spent inside this little function
  // inputs to this function are both quantized
  
  for(int i = a; i <= b; i++){
    
    float val = 0.0f;
    int in = i * n;
    
    // do the matmul in groups of GS
    int j;
    for(j = 0; j <= n - GS; j += GS){
      _Float16* xqp = &xq[j];
      _Float16* wqp = &wq[in + j];
      float sum = 0.0f;
      for (int k = 0; k < GS; k++) {
        sum += ((float)xqp[k]) * ((float)wqp[k]); // Multiply and accumulate
      }
      val += sum;
    }
    
    xout[i] = val;
  }
}

// Quantize a float vector into F8E5M2 format (8-bit values with FP8E5M2 scaling)
__attribute__((ms_abi)) void quantizeF8E5M2(float *x, uint8_t *q, const int32_t count, const int32_t groupSize){
  for(int32_t i = 0; i < count; i++){
    // Convert each float to F8E5M2 format
    q[i] = FP32ToFP8E5M2(x[i]);
  }
}

// Dequantize a F8E5M2 format vector (8-bit values)
__attribute__((ms_abi)) void dequantizeF8E5M2(float *x, uint8_t *q, const int32_t count, const int32_t groupSize){
  for(int32_t i = 0; i < count; i++){
    // Convert each F8E5M2 value back to float
    x[i] = FP8E5M2ToFP32(q[i]);
  }
}

__attribute__((ms_abi)) void quantizeBF16(float *x, uint16_t *q, const int32_t count, const int32_t groupSize){
  for(int32_t i = 0; i < count; i++){
    // Convert each float to BF16 format
    q[i] = FP32ToBF16(x[i]);
  }
}

__attribute__((ms_abi)) void dequantizeBF16(float *x, uint16_t *q, const int32_t count, const int32_t groupSize){
  for(int32_t i = 0; i < count; i++){
    // Convert each BF16 value back to float
    x[i] = BF16ToFP32(q[i]);  
  }
}

__attribute__((ms_abi)) void quantizeF16(float *x, _Float16 *q, const int32_t count, const int32_t groupSize){
  for(int32_t i = 0; i < count; i++){
    // Convert each float to F16 format
    q[i] = x[i];
  }
}

__attribute__((ms_abi)) void dequantizeF16(float *x, _Float16 *q, const int32_t count, const int32_t groupSize){
  for(int32_t i = 0; i < count; i++){
    // Convert each F16 value back to float
    x[i] = q[i];
  }
}

// Apply Rotary Positional Encoding (RoPE) to a single head vector, either interleaved or non-interleaved
__attribute__((ms_abi)) void cachedRoPESingleHeadInterleaved(float* aVector, float* aRoPECache, int32_t aHeadDim, int32_t aRotaryDim){
  // Loop through the vector in steps of 2 to apply the rotary positional encoding
  for(int32_t index = 0; index < aHeadDim; index += 2){
    // Get the sine and cosine values from the RoPE cache
    float sinus = aRoPECache[index];
    float cosinus = aRoPECache[index + 1];

    // Get the next two values from the vector
    float v0 = aVector[index];
    float v1 = aVector[index + 1];

    // Rotate the vector using the sine and cosine values and store the results back in the vector
    aVector[index] = (v0 * cosinus) - (v1 * sinus);
    aVector[index + 1] = (v0 * sinus) + (v1 * cosinus);
  }
}

__attribute__((ms_abi)) void cachedRoPESingleHeadNonInterleaved(float* aVector, float* aRoPECache, int32_t aHeadDim, int32_t aRotaryDim){
  // Loop through the vector in steps of 2 to apply the rotary positional encoding
  int32_t halfDim = aHeadDim >> 1; // Calculate the half dimension for non-interleaved RoPE
  for(int32_t index = 0; index < halfDim; index++){
    // Calculate the rotary index based on the current index
    int32_t rotaryIndex = index << 1;

    // Get the sine and cosine values from the RoPE cache
    float sinus = aRoPECache[rotaryIndex];
    float cosinus = aRoPECache[rotaryIndex + 1];

    // Get the next two values from the vector
    float v0 = aVector[index];
    float v1 = aVector[index + halfDim];

    // Rotate the vector using the sine and cosine values and store the results back in the vector
    aVector[index] = (v0 * cosinus) - (v1 * sinus);
    aVector[index + halfDim] = (v0 * sinus) + (v1 * cosinus);
  }
}

__attribute__((ms_abi)) void attention(float* aXOut, float* aAttH, const float* aQH, const float* aKH, const float* aVH, int32_t aHeadDim, int32_t aKVDim, int32_t aKVLen){
 
//const uint32_t float32NegInfinity = 0xff800000; // Define the representation of positive infinity in IEEE 754 format

  float scoreMax = -INFINITY; // Initialize the maximum score to negative infinity  
  for(int32_t timeIndex = 0; timeIndex < aKVLen; timeIndex++){ // Loop through the key/value length
    float score = 0.0f; // Initialize the score for this time step
    for(int32_t headIndex = 0; headIndex < aHeadDim; headIndex++){ // Loop through the head dimension
      score += aQH[headIndex] * aKH[(timeIndex * aKVDim) + headIndex]; // Calculate the dot product of query and key
    }
    aAttH[timeIndex] = (score /= sqrtf((float)aHeadDim)); // Scale the score by the square root of the head dimension and store it in the attention array
    if(scoreMax < score){
      scoreMax = score; // Update the maximum score if the current score is greater
    }
  }

#if defined(__AVX2__)
  // Use AVX2 for faster exponentiation and summation
  __m256 scoreMaxVec = _mm256_set1_ps(scoreMax); // Broadcast the maximum score to an AVX vector
  __m256 scoreSumVec = _mm256_setzero_ps(); // Initialize the sum of scores to zero in an AVX vector
  int32_t timeIndex = 0;
  for(; timeIndex < aKVLen; timeIndex += 8){ // Loop through the key/value length in chunks of 8
    __m256 scoreVec = _mm256_loadu_ps(&aAttH[timeIndex]); // Load the scores into an AVX vector
    scoreVec = _mm256_sub_ps(scoreVec, scoreMaxVec); // Subtract the maximum score for numerical stability
    scoreVec = exp256_ps(scoreVec); // Exponentiate the scores
    _mm256_storeu_ps(&aAttH[timeIndex], scoreVec); // Store the exponentiated scores back into the attention array
    scoreSumVec = _mm256_add_ps(scoreSumVec, scoreVec); // Add the exponentiated scores to the sum
  }

  // Handle any remaining scores if aKVLen is not a multiple of 8, but using __mm256_exp_ps
  if(timeIndex < aKVLen){ 
    float attentionArray[8]; // Temporary array to hold the remaining scores
    int32_t i = 0;
    for(; (i < 8) && ((timeIndex + i) < aKVLen); i++){ // Copy the remaining scores into the temporary array
      attentionArray[i] = aAttH[timeIndex + i]; // Copy the remaining scores into the temporary array
    }
    for(; i < 8; i++){ // Pad the remaining scores with zeros if necessary
      attentionArray[i] = 0.0f;
    }
    __m256 scoreVec = _mm256_loadu_ps(attentionArray); // Load the remaining scores into an AVX vector
    scoreVec = _mm256_sub_ps(scoreVec, scoreMaxVec); // Subtract the maximum score for numerical stability
    scoreVec = exp256_ps(scoreVec); // Exponentiate the remaining scores
    _mm256_storeu_ps(attentionArray, scoreVec); // Store the exponentiated scores back into the temporary array
    scoreSumVec = _mm256_add_ps(scoreSumVec, scoreVec); // Add the exponentiated scores to the sum
    for(i = 0; (i < 8) && ((timeIndex + i) < aKVLen); i++){ // Copy the exponentiated scores back into the attention array
      aAttH[timeIndex + i] = attentionArray[i]; // Copy the exponentiated scores back into the attention array
    }
  }
  
  // Horizontal sum of the AVX vector to get the total score sum
  float scoreSumArray[8];
  _mm256_storeu_ps(scoreSumArray, scoreSumVec); // Store the AVX vector into an array
  float scoreSum = scoreSumArray[0] + scoreSumArray[1] + scoreSumArray[2] + scoreSumArray[3] +
                   scoreSumArray[4] + scoreSumArray[5] + scoreSumArray[6] + scoreSumArray[7]; // Sum the elements of the array
#else
  // Fallback to scalar implementation if AVX2 is not available
  float scoreSum = 0.0f; // Initialize the sum of scores to zero
  for(int32_t timeIndex = 0; timeIndex < aKVLen; timeIndex++){
    scoreSum += (aAttH[timeIndex] = expEx(aAttH[timeIndex] - scoreMax)); // Exponentiate the score minus the maximum score for numerical stability and add to the sum
  }
#endif

  for(int32_t timeIndex = 0; timeIndex < aKVLen; timeIndex++){ // Loop through the key/value length
    aAttH[timeIndex] /= scoreSum; // Normalize the attention weights by dividing by the sum of scores
  }

  for(int32_t headIndex = 0; headIndex < aHeadDim; headIndex++){ // Loop through the head dimension
    float res = 0.0f; // Initialize the result for this head
    for(int32_t timeIndex = 0; timeIndex < aKVLen; timeIndex++){ // Loop through the key/value length
      res += aAttH[timeIndex] * aVH[(timeIndex * aKVDim) + headIndex]; // Mix the value with the attention weight
    }
    aXOut[headIndex] = res; // Store the result in the output array
  }

}

//__attribute__((ms_abi))
static __attribute__((always_inline)) float dotproductQ3F8Q80(const uint32_t *w, const void *x, const int32_t count){
  
  const int32_t groupSize = 32; // Q3F8 group size
  
  // w: Q3F8 weights, xq: Q80 input vector, xs: Q80 per-group scale, n: input length (must be multiple of 32), i: output row
  const uint32_t* r = w; // Q3F8 block pointer
  __m256 acc0 = _mm256_setzero_ps(), acc1 = _mm256_setzero_ps();
  
  uint8_t* xp = (uint8_t*)x; // Cast input to uint8_t pointer for Q80
  for (int32_t j = 0; j < count; j += groupSize) {
    
    // Load xq in 4x8 blocks (8 int8 each), convert to float32 and apply scale
    __m128i xq0_i8 = _mm_loadl_epi64((const __m128i*)&xp[0]);
    __m128i xq1_i8 = _mm_loadl_epi64((const __m128i*)&xp[8]);
    __m128i xq2_i8 = _mm_loadl_epi64((const __m128i*)&xp[16]);
    __m128i xq3_i8 = _mm_loadl_epi64((const __m128i*)&xp[24]);
    
    // Dequantize xp[32] -> float16
    // Fetch 16-bit scale factor from the end of the Q80 block
    _Float16 xscale_f16 = *((_Float16*)&xp[32]); // Load the scale factor as _Float16
    __m256 xscale = _mm256_set1_ps((float)xscale_f16); // Convert to float32 and broadcast
    
    __m256 x0 = _mm256_mul_ps(_mm256_cvtepi32_ps(_mm256_cvtepi8_epi32(xq0_i8)), xscale);
    __m256 x1 = _mm256_mul_ps(_mm256_cvtepi32_ps(_mm256_cvtepi8_epi32(xq1_i8)), xscale);
    __m256 x2 = _mm256_mul_ps(_mm256_cvtepi32_ps(_mm256_cvtepi8_epi32(xq2_i8)), xscale);
    __m256 x3 = _mm256_mul_ps(_mm256_cvtepi32_ps(_mm256_cvtepi8_epi32(xq3_i8)), xscale);
    
    // Now Q3F8 weights
    __m128i wg = _mm_loadu_si128((const __m128i*)&r[j / 8]);
    // Extract FP8E5M2 scale (as before)
    const __m128i wgfm = _mm_setr_epi8(-1, 0, -1, 4, -1, 8, -1, 12, -1, -1, -1, -1, -1, -1, -1, -1);
    __m128 wgf = _mm_cvtph_ps(_mm_shuffle_epi8(wg, wgfm)); // 4 floats (one per 8-Q3F8 block)
    __m256 wgfp = _mm256_castsi256_ps(_mm256_broadcastsi128_si256(_mm_castps_si128(wgf)));
    // Bit-slice to 4x8 weights, exactly as in your code:
    __m256i wgp = _mm256_broadcastsi128_si256(wg);
    const __m256i wgbits = _mm256_setr_epi32(8, 11, 14, 17, 20, 23, 26, 29);
    const __m256 wgtab = _mm256_setr_ps(-4 / -4.f, -3 / -4.f, -2 / -4.f, -1 / -4.f, 0 / -4.f, 1 / -4.f, 2 / -4.f, 3 / -4.f);
    
    __m256 w0 = _mm256_permutevar8x32_ps(wgtab, _mm256_srlv_epi32(_mm256_shuffle_epi32(wgp, 0x00), wgbits));
    __m256 w1 = _mm256_permutevar8x32_ps(wgtab, _mm256_srlv_epi32(_mm256_shuffle_epi32(wgp, 0x55), wgbits));
    __m256 w2 = _mm256_permutevar8x32_ps(wgtab, _mm256_srlv_epi32(_mm256_shuffle_epi32(wgp, 0xaa), wgbits));
    __m256 w3 = _mm256_permutevar8x32_ps(wgtab, _mm256_srlv_epi32(_mm256_shuffle_epi32(wgp, 0xff), wgbits));
    
    // Apply the FP8E5M2 scale to weights (note: *per 8 elements, needs correct broadcasting)
    __m256 ws0 = _mm256_mul_ps(w0, _mm256_shuffle_ps(wgfp, wgfp, 0x00));
    __m256 ws1 = _mm256_mul_ps(w1, _mm256_shuffle_ps(wgfp, wgfp, 0x55));
    __m256 ws2 = _mm256_mul_ps(w2, _mm256_shuffle_ps(wgfp, wgfp, 0xaa));
    __m256 ws3 = _mm256_mul_ps(w3, _mm256_shuffle_ps(wgfp, wgfp, 0xff));
    
    // Fused dot-product accumulate
    acc0 = _mm256_add_ps(acc0, _mm256_mul_ps(ws0, x0));
    acc1 = _mm256_add_ps(acc1, _mm256_mul_ps(ws1, x1));
    acc0 = _mm256_add_ps(acc0, _mm256_mul_ps(ws2, x2));
    acc1 = _mm256_add_ps(acc1, _mm256_mul_ps(ws3, x3));
    
    xp += 34; // Move to the next 32 elements (32 int8 + 1xfloat16 scale)
    
  }
  __m256 acc8 = _mm256_add_ps(acc0, acc1);
  __m128 acc4 = _mm_add_ps(_mm256_castps256_ps128(acc8), _mm256_extractf128_ps(acc8, 1));
  __m128 accf = _mm_dp_ps(acc4, _mm_set1_ps(1.0f), 0xf1);
  return _mm_cvtss_f32(accf);
}

__attribute__((ms_abi)) void matMulQ3F8Q80(float* xout, const uint8_t *x, const uint8_t *w, const int32_t n, const int32_t a, const int32_t b){
  const int32_t m = (n / 8) * 4;
  for(int i = a; i <= b; i++){
    xout[i] = dotproductQ3F8Q80((const void*)&w[i * m], &x[0], n); 
  }
}

__attribute__((ms_abi)) float dotproductQ3F8Q80Ex(const void *w, const void *x, const int32_t count){
  const int32_t groupSize = 32; // Group size for quantization
  int32_t countGroups = count / groupSize; // Number of groups
  float result = 0.0f; // Initialize the result to zero
  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){
    uint32_t *wGroup = (uint32_t*)&((uint8_t*)w)[groupIndex * (groupSize >> 1)]; // Pointer to the current group in w (Q3F8)
    int8_t *xGroup = &((int8_t*)x)[groupIndex * (groupSize + 2)]; // Pointer to the current group in x (Q80)
    float sum = 0.0; // Initialize the sum for this group
    for(int32_t groupRelativeIndex = 0; groupRelativeIndex < groupSize; groupRelativeIndex += 32){
      // Q3F8 is quantized in groups of 8, so we process 4 groups of 8 values at a time
      for(int32_t q3f8GroupRelativeIndex = 0; q3f8GroupRelativeIndex < 4; q3f8GroupRelativeIndex++){
        // Calculate the dot product for the current group
        const uint32_t wValue = *wGroup++; // Get the next 32-bit value from w
        const int32_t wValues[8] = {
          (((int32_t)((wValue >> (8 + (0 * 3))) & 7)) - 4),
          (((int32_t)((wValue >> (8 + (1 * 3))) & 7)) - 4),
          (((int32_t)((wValue >> (8 + (2 * 3))) & 7)) - 4),
          (((int32_t)((wValue >> (8 + (3 * 3))) & 7)) - 4),
          (((int32_t)((wValue >> (8 + (4 * 3))) & 7)) - 4),
          (((int32_t)((wValue >> (8 + (5 * 3))) & 7)) - 4),
          (((int32_t)((wValue >> (8 + (6 * 3))) & 7)) - 4),
          (((int32_t)((wValue >> (8 + (7 * 3))) & 7)) - 4)
        };
#if defined(__AVX2__)
//      __m256i xGroupVector = _mm256_cvtepi8_epi32(mm_loadl_epi64((const __m128i*)xGroup)); // Loads 8 int8_t and extends to 8 int32_t
        __m256i xGroupVector = _mm256_cvtepi8_epi32(_mm_loadu_si128((const __m128i*)xGroup)); // Loads 8 int8_t and extends to 8 int32_t
        __m256i wValueVector = _mm256_loadu_si256((const __m256i*)wValues);
        __m256i mul = _mm256_mullo_epi32(xGroupVector, wValueVector);
        __m128i sum128 = _mm_add_epi32(_mm256_extracti128_si256(mul, 0), _mm256_extracti128_si256(mul, 1));
        sum128 = _mm_add_epi32(sum128, _mm_shuffle_epi32(sum128, _MM_SHUFFLE(2, 3, 0, 1)));
        sum128 = _mm_add_epi32(sum128, _mm_shuffle_epi32(sum128, _MM_SHUFFLE(1, 0, 3, 2)));
        sum += _mm_cvtsi128_si32(sum128) * (FP8E5M2ToFP32(wValue & 0xff) * -0.25f); // Convert the sum to float and apply the scale factor         
#else
        // Apply the scale factor and accumulate the result
        sum += (
          (wValues[0] * ((int32_t)(xGroup[0]))) +
          (wValues[1] * ((int32_t)(xGroup[1]))) +
          (wValues[2] * ((int32_t)(xGroup[2]))) +
          (wValues[3] * ((int32_t)(xGroup[3]))) +
          (wValues[4] * ((int32_t)(xGroup[4]))) +
          (wValues[5] * ((int32_t)(xGroup[5]))) +
          (wValues[6] * ((int32_t)(xGroup[6]))) +
          (wValues[7] * ((int32_t)(xGroup[7])))
        ) * (FP8E5M2ToFP32(wValue & 0xff) * -0.25f);
#endif
        xGroup += 8; // Move to the next 8 elements
      }
    }
    result += sum * (*((_Float16*)xGroup)); // Scale the sum and add it to the result
  }
  return result;
} 

__attribute__((ms_abi))
//static __attribute__((always_inline)) 
float dotproductQ3F8F8E5M2(const uint32_t *w, const uint8_t *x, const int32_t count){
  
  const int32_t groupSize = 32; // Q3F8 group size
  
  // w: Q3F8 weights, x: F8E5M2 input vector, count: input length (must be multiple of 32)
  
  const uint32_t* r = w; // Q3F8 block pointer
  __m256 acc0 = _mm256_setzero_ps(), acc1 = _mm256_setzero_ps(), acc2 = _mm256_setzero_ps(), acc3 = _mm256_setzero_ps();
  
  uint8_t* xp = (uint8_t*)x; // Cast input to uint8_t pointer for Q80
  for (int32_t j = 0; j < count; j += groupSize) {
    
    // Dequantize x (F8E5M2) to floats
    
    #if 1
    __m256i xb    = _mm256_loadu_si256((const __m256i*)xp);                 // 32 bytes
    __m256i u16lo = _mm256_cvtepu8_epi16(_mm256_castsi256_si128(xb));       // 16 u16
    __m256i u16hi = _mm256_cvtepu8_epi16(_mm256_extracti128_si256(xb, 1));  // 16 u16
    u16lo = _mm256_slli_epi16(u16lo, 8);                                    // fp8 -> fp16 bits
    u16hi = _mm256_slli_epi16(u16hi, 8);
    
    __m256 x0 = _mm256_cvtph_ps(_mm256_castsi256_si128(u16lo));             // 8 f32
    __m256 x1 = _mm256_cvtph_ps(_mm256_extracti128_si256(u16lo, 1));        // 8 f32
    __m256 x2 = _mm256_cvtph_ps(_mm256_castsi256_si128(u16hi));             // 8 f32
    __m256 x3 = _mm256_cvtph_ps(_mm256_extracti128_si256(u16hi, 1));        // 8 f32
    #else 
    // Load 32 F8E5M2 values (32 bytes) and convert them to 32 float32 values.
    // Process in two 16-byte chunks.
    
    // Chunk 1: Dequantize the first 16 bytes (x[0] to x[15])
    __m128i xq_u8_0 = _mm_loadu_si128((const __m128i*)&xp[0]); // Load 16x uint8_t
    __m256i xq_u16_0 = _mm256_cvtepu8_epi16(xq_u8_0); // Extend to 16x uint16_t
    __m256i xq_fp16_bits_0 = _mm256_slli_epi16(xq_u16_0, 8); // Shift to _Float16 format
    
    // Convert the 16 _Float16 values to 16 float32 values (in two registers)
    __m256 x0 = _mm256_cvtph_ps(_mm256_castsi256_si128(xq_fp16_bits_0));
    __m256 x1 = _mm256_cvtph_ps(_mm256_extracti128_si256(xq_fp16_bits_0, 1));
    
    // Chunk 2: Dequantize the next 16 bytes (x[16] to x[31])
    __m128i xq_u8_1 = _mm_loadu_si128((const __m128i*)&xp[16]); // Load 16x uint8_t
    __m256i xq_u16_1 = _mm256_cvtepu8_epi16(xq_u8_1); // Extend to 16x uint16_t
    __m256i xq_fp16_bits_1 = _mm256_slli_epi16(xq_u16_1, 8); // Shift to _Float16 format
    
    // Convert the 16 _Float16 values to 16 float32 values (in two registers)
    __m256 x2 = _mm256_cvtph_ps(_mm256_castsi256_si128(xq_fp16_bits_1));
    __m256 x3 = _mm256_cvtph_ps(_mm256_extracti128_si256(xq_fp16_bits_1, 1));
    #endif        
    
    // Now Q3F8 weights
    __m128i wg = _mm_loadu_si128((const __m128i*)&r[j / 8]);
    // Extract FP8E5M2 scale (as before)
    const __m128i wgfm = _mm_setr_epi8(-1, 0, -1, 4, -1, 8, -1, 12, -1, -1, -1, -1, -1, -1, -1, -1);
    __m128 wgf = _mm_cvtph_ps(_mm_shuffle_epi8(wg, wgfm)); // 4 floats (one per 8-Q3F8 block)
    __m256 wgfp = _mm256_castsi256_ps(_mm256_broadcastsi128_si256(_mm_castps_si128(wgf)));
    // Bit-slice to 4x8 weights, exactly as in your code:
    __m256i wgp = _mm256_broadcastsi128_si256(wg);
    const __m256i wgbits = _mm256_setr_epi32(8, 11, 14, 17, 20, 23, 26, 29);
    const __m256 wgtab = _mm256_setr_ps(-4 / -4.f, -3 / -4.f, -2 / -4.f, -1 / -4.f, 0 / -4.f, 1 / -4.f, 2 / -4.f, 3 / -4.f);
    
    __m256 w0 = _mm256_permutevar8x32_ps(wgtab, _mm256_srlv_epi32(_mm256_shuffle_epi32(wgp, 0x00), wgbits));
    __m256 w1 = _mm256_permutevar8x32_ps(wgtab, _mm256_srlv_epi32(_mm256_shuffle_epi32(wgp, 0x55), wgbits));
    __m256 w2 = _mm256_permutevar8x32_ps(wgtab, _mm256_srlv_epi32(_mm256_shuffle_epi32(wgp, 0xaa), wgbits));
    __m256 w3 = _mm256_permutevar8x32_ps(wgtab, _mm256_srlv_epi32(_mm256_shuffle_epi32(wgp, 0xff), wgbits));
    
    // Apply the FP8E5M2 scale to weights (note: *per 8 elements, needs correct broadcasting)
    __m256 ws0 = _mm256_mul_ps(w0, _mm256_shuffle_ps(wgfp, wgfp, 0x00));
    __m256 ws1 = _mm256_mul_ps(w1, _mm256_shuffle_ps(wgfp, wgfp, 0x55));
    __m256 ws2 = _mm256_mul_ps(w2, _mm256_shuffle_ps(wgfp, wgfp, 0xaa));
    __m256 ws3 = _mm256_mul_ps(w3, _mm256_shuffle_ps(wgfp, wgfp, 0xff));
    
    // Fused dot-product accumulate
    acc0 = _mm256_fmadd_ps(ws0, x0, acc0);
    acc1 = _mm256_fmadd_ps(ws1, x1, acc1);
    acc2 = _mm256_fmadd_ps(ws2, x2, acc2);
    acc3 = _mm256_fmadd_ps(ws3, x3, acc3);
    
    xp += 32; // Move to the next 32 elements (32 F8E5M2 values)
    
  }
  __m256 acc8 = _mm256_add_ps(_mm256_add_ps(_mm256_add_ps(acc0, acc1), acc2), acc3);
  __m128 acc4 = _mm_add_ps(_mm256_castps256_ps128(acc8), _mm256_extractf128_ps(acc8, 1));
  __m128 accf = _mm_dp_ps(acc4, _mm_set1_ps(1.0f), 0xf1);
  return _mm_cvtss_f32(accf);
}

__attribute__((ms_abi)) void matMulQ3F8F8E5M2(float* xout, const uint8_t *x, const uint8_t *w, const int32_t n, const int32_t a, const int32_t b){
  const int32_t m = (n / 8) * 4;
  for(int i = a; i <= b; i++){
    xout[i] = dotproductQ3F8F8E5M2((const void*)&w[i * m], &x[0], n);
  }
}

__attribute__((ms_abi)) float dotproductQ7F8Q80(const void *w, const void *x, const int32_t count){
  const int32_t groupSize = 32; // Group size for quantization
  int32_t countGroups = count / groupSize; // Number of groups
  float result = 0.0f; // Initialize the result to zero
  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){
    uint64_t *wGroup = (uint64_t*)&((uint8_t*)w)[groupIndex * groupSize]; // Pointer to the current group in w (Q3F8)
    int8_t *xGroup = &((int8_t*)x)[groupIndex * (groupSize + 2)]; // Pointer to the current group in x (Q80)
    float sum = 0.0; // Initialize the sum for this group
    for(int32_t groupRelativeIndex = 0; groupRelativeIndex < groupSize; groupRelativeIndex += 32){
      // Q3F8 is quantized in groups of 8, so we process 4 groups of 8 values at a time
      for(int32_t q3f8GroupRelativeIndex = 0; q3f8GroupRelativeIndex < 4; q3f8GroupRelativeIndex++){
        // Calculate the dot product for the current group
        const uint64_t wValue = *wGroup++; // Get the next 32-bit value from w
        const int32_t wValues[8] = {
          (((int32_t)((wValue >> (8 + (0 * 7))) & 127)) - 64),
          (((int32_t)((wValue >> (8 + (1 * 7))) & 127)) - 64),
          (((int32_t)((wValue >> (8 + (2 * 7))) & 127)) - 64),
          (((int32_t)((wValue >> (8 + (3 * 7))) & 127)) - 64),
          (((int32_t)((wValue >> (8 + (4 * 7))) & 127)) - 64),
          (((int32_t)((wValue >> (8 + (5 * 7))) & 127)) - 64),
          (((int32_t)((wValue >> (8 + (6 * 7))) & 127)) - 64),
          (((int32_t)((wValue >> (8 + (7 * 7))) & 127)) - 64)
        };
#if defined(__AVX2__)
//      __m256i xGroupVector = _mm256_cvtepi8_epi32(mm_loadl_epi64((const __m128i*)xGroup)); // Loads 8 int8_t and extends to 8 int32_t
        __m256i xGroupVector = _mm256_cvtepi8_epi32(_mm_loadu_si128((const __m128i*)xGroup)); // Loads 8 int8_t and extends to 8 int32_t
        __m256i wValueVector = _mm256_loadu_si256((const __m256i*)wValues);
        __m256i mul = _mm256_mullo_epi32(xGroupVector, wValueVector);
        __m128i sum128 = _mm_add_epi32(_mm256_extracti128_si256(mul, 0), _mm256_extracti128_si256(mul, 1));
        sum128 = _mm_add_epi32(sum128, _mm_shuffle_epi32(sum128, _MM_SHUFFLE(2, 3, 0, 1)));
        sum128 = _mm_add_epi32(sum128, _mm_shuffle_epi32(sum128, _MM_SHUFFLE(1, 0, 3, 2)));
        sum += _mm_cvtsi128_si32(sum128) * (FP8E5M2ToFP32(wValue & 0xff) * -0.015625f); // Convert the sum to float and apply the scale factor         
#else
        // Apply the scale factor and accumulate the result
        sum += (
          (wValues[0] * ((int32_t)(xGroup[0]))) +
          (wValues[1] * ((int32_t)(xGroup[1]))) +
          (wValues[2] * ((int32_t)(xGroup[2]))) +
          (wValues[3] * ((int32_t)(xGroup[3]))) +
          (wValues[4] * ((int32_t)(xGroup[4]))) +
          (wValues[5] * ((int32_t)(xGroup[5]))) +
          (wValues[6] * ((int32_t)(xGroup[6]))) +
          (wValues[7] * ((int32_t)(xGroup[7])))
        ) * (FP8E5M2ToFP32(wValue & 0xff) * -0.015625f);
#endif
        xGroup += 8; // Move to the next 8 elements
      }
    }
    result += sum * (*((_Float16*)xGroup)); // Scale the sum and add it to the result
  }
  return result;
} 

//__attribute__((ms_abi))
static __attribute__((always_inline)) float dotproductQ40Q80(const void *w, const void *x, const int32_t count){
  const int32_t groupSize = 32; // Group size for quantization
  const int32_t halfGroupSize = groupSize >> 1; // Half group size for Q40
  int32_t countGroups = count / groupSize; // Number of groups
  float result = 0.0f; // Initialize the result to zero
  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){
    uint8_t *wGroup = &((int8_t*)w)[groupIndex * ((groupSize >> 1) + 2)]; // Pointer to the current group in w (Q40)
    int8_t *xGroup = &((int8_t*)x)[groupIndex * (groupSize + 2)]; // Pointer to the current group in x (Q80)
    int32_t sum = 0; // Initialize the sum for this group
    //#pragma omp simd reduction(+ : sum) simdlen(32)
    for(int32_t halfGroupRelativeIndex = 0; halfGroupRelativeIndex < halfGroupSize; halfGroupRelativeIndex++){
      // Calculate the dot product for the current group
      uint8_t wValue = *wGroup++; // Get the next 8-bit value from w
      sum += (((int32_t)(wValue & 0x0f)) - 8) * ((int32_t)(*xGroup++));
      sum += (((int32_t)(wValue >> 4)) - 8) * ((int32_t)(*xGroup++));
    }
    float scale = (*((_Float16*)wGroup)) * (*((_Float16*)xGroup)); // Get the scale factors from the end of the groups
    result += sum * scale; // Scale the sum and add it to the result
  }
  return result;
}

__attribute__((ms_abi)) void matMulQ40Q80(float* xout, const uint8_t *x, const uint8_t *w, const int32_t n, const int32_t a, const int32_t b){
  const int32_t m = (n / 32) * 18;
  for(int i = a; i <= b; i++){
    xout[i] = dotproductQ40Q80(&w[i * m], &x[0], n); 
  }
}

//__attribute__((ms_abi))
static __attribute__((always_inline)) 
float dotproductQ80Q80(const void *w, const void *x, const int32_t count){
#if defined(__AVX2__)

  const int32_t groupSize = 32; // Q80 group size

  // w: Q80 weights, xq: Q80 input vector, xs: Q80 per-group scale, n: input length (must be multiple of 32), i: output row

  __m256 acc = _mm256_setzero_ps();

  const __m256i oneWordVector = _mm256_set1_epi16(1);

  uint8_t* wp = (uint8_t*)w;
  uint8_t* xp = (uint8_t*)x;
  for (int32_t j = 0; j < count; j += groupSize) {
    
    // Load 32 bytes from each vector
    __m256i xBytes = _mm256_loadu_si256((const __m256i *)(xp));
    __m256i wBytes = _mm256_loadu_si256((const __m256i *)(wp));    

    // i32 → f32 and accumulate: acc += combinedScale * pairSumFloat
    acc = _mm256_fmadd_ps(
      // Convert the 32x i8 to 32x f32 for the dot product
      _mm256_cvtepi32_ps(
         // Pairwise byte mul-add => i16, then sum adjacent => i32
         _mm256_madd_epi16(
            // Make signed * signed via sign trick
            _mm256_maddubs_epi16(
               _mm256_sign_epi8(xBytes, xBytes), // abs(x)
               _mm256_sign_epi8(wBytes, xBytes)  // w * sign(x)
            ), 
            oneWordVector
        )
      ), 
      // Load the 16-bit scale factors from the end of the groups and calculate the combined scale once per group 
      _mm256_set1_ps((float)(*(_Float16 *)(xp + 32)) * (float)(*(_Float16 *)(wp + 32))), 
      acc
    );

    xp += 34;
    wp += 34;
        
  }

  // Horizontal sum of the 8x f32 in acc
  __m128 sum4 = _mm_add_ps(_mm256_castps256_ps128(acc), _mm256_extractf128_ps(acc, 1));
  sum4 = _mm_hadd_ps(sum4, sum4);
  sum4 = _mm_hadd_ps(sum4, sum4);
  return _mm_cvtss_f32(sum4);
#else
  const int32_t groupSize = 32; // Group size for quantization
  int32_t countGroups = count / groupSize; // Number of groups
  float result = 0.0f; // Initialize the result to zero
  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){
    int32_t groupBaseIndex = groupIndex * (groupSize + 2); // Calculate the offset for the current group
    int8_t *wGroup = &((int8_t*)w)[groupBaseIndex]; // Pointer to the current group in w
    int8_t *xGroup = &((int8_t*)x)[groupBaseIndex]; // Pointer to the current group in x
    int32_t sum = 0; // Initialize the sum for this group
    //#pragma omp simd reduction(+ : sum) simdlen(32)
    for(int32_t groupRelativeIndex = 0; groupRelativeIndex < groupSize; groupRelativeIndex++){
      // Calculate the dot product for the current group
      sum += ((int32_t)wGroup[groupRelativeIndex]) * ((int32_t)xGroup[groupRelativeIndex]);
    }
    float scale = (*((_Float16*)&wGroup[groupSize])) * (*((_Float16*)&xGroup[groupSize])); // Get the scale factors from the end of the groups
    result += sum * scale; // Scale the sum and add it to the result
  }
  return result;
#endif
}

__attribute__((ms_abi)) void matMulQ80Q80(float* xout, const uint8_t *x, const uint8_t *w, const int32_t n, const int32_t a, const int32_t b){
  const int32_t m = (n / 32) * 34;
  //_Pragma("clang loop unroll(disable) vectorize(disable)")
  for(int i = a; i <= b; i++){
    xout[i] = dotproductQ80Q80(&w[i * m], &x[0], n); 
  }
}

__attribute__((ms_abi)) float dotproductF8E5M2Q80(const void *w, const void *x, const int32_t count){
  const int32_t groupSize = 32; // Group size for quantization
  int32_t countGroups = count / groupSize; // Number of groups
  float result = 0.0f; // Initialize the result to zero
  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){
    uint8_t *wGroup = &((uint8_t*)w)[groupIndex * groupSize]; // Pointer to the current group in w
    int8_t *xGroup = &((int8_t*)x)[groupIndex * (groupSize + 2)]; // Pointer to the current group in x
    float sum = 0.0f; // Initialize the sum for this group
    #pragma omp simd reduction(+ : sum) simdlen(32)
    for(int32_t groupRelativeIndex = 0; groupRelativeIndex < groupSize; groupRelativeIndex++){
      // Calculate the dot product for the current group
      sum += FP8E5M2ToFP32(wGroup[groupRelativeIndex]) * ((int32_t)xGroup[groupRelativeIndex]);
    }
    result += sum * (*((_Float16*)&xGroup[groupSize])); // Scale the sum and add it to the result
  }
  return result;
}

__attribute__((ms_abi)) 
//static __attribute__((always_inline)) 
float dotproductF8E5M2F8E5M2(const void *w, const void *x, const int32_t count){
#if defined(__AVX2__)

  const int32_t groupSize = 32; // Q3F8 group size

  // w: Q3F8 weights, x: F8E5M2 input vector, count: input length (must be multiple of 32)
  __m256 acc0 = _mm256_setzero_ps(), acc1 = _mm256_setzero_ps(), acc2 = _mm256_setzero_ps(), acc3 = _mm256_setzero_ps();

  uint8_t* wp = (uint8_t*)w;
  uint8_t* xp = (uint8_t*)x;
  for (int32_t j = 0; j < count; j += groupSize) {
    
    // Dequantize x (F8E5M2) to floats
    
    __m256i xb    = _mm256_loadu_si256((const __m256i*)xp);                  // 32 bytes
    __m256i xu16lo = _mm256_cvtepu8_epi16(_mm256_castsi256_si128(xb));       // 16 u16
    __m256i xu16hi = _mm256_cvtepu8_epi16(_mm256_extracti128_si256(xb, 1));  // 16 u16
    xu16lo = _mm256_slli_epi16(xu16lo, 8);                                   // fp8 -> fp16 bits
    xu16hi = _mm256_slli_epi16(xu16hi, 8);
    
    __m256 x0 = _mm256_cvtph_ps(_mm256_castsi256_si128(xu16lo));             // 8 f32
    __m256 x1 = _mm256_cvtph_ps(_mm256_extracti128_si256(xu16lo, 1));        // 8 f32
    __m256 x2 = _mm256_cvtph_ps(_mm256_castsi256_si128(xu16hi));             // 8 f32
    __m256 x3 = _mm256_cvtph_ps(_mm256_extracti128_si256(xu16hi, 1));        // 8 f32
    
    // Dequantize w (F8E5M2) to floats
    
    __m256i wb       = _mm256_loadu_si256((const __m256i*)wp);                // 32 bytes
    __m256i wu16lo  = _mm256_cvtepu8_epi16(_mm256_castsi256_si128(wb));       // 16 u16
    __m256i wu16hi  = _mm256_cvtepu8_epi16(_mm256_extracti128_si256(wb, 1));  // 16 u16
    wu16lo = _mm256_slli_epi16(wu16lo, 8);                                    // fp8 -> fp16 bits
    wu16hi = _mm256_slli_epi16(wu16hi, 8);  
    
    __m256 w0 = _mm256_cvtph_ps(_mm256_castsi256_si128(wu16lo));             // 8 f32
    __m256 w1 = _mm256_cvtph_ps(_mm256_extracti128_si256(wu16lo, 1));        // 8 f32
    __m256 w2 = _mm256_cvtph_ps(_mm256_castsi256_si128(wu16hi));             // 8 f32
    __m256 w3 = _mm256_cvtph_ps(_mm256_extracti128_si256(wu16hi, 1));        // 8 f32
    
    // Fused dot-product accumulate
    acc0 = _mm256_fmadd_ps(w0, x0, acc0);
    acc1 = _mm256_fmadd_ps(w1, x1, acc1);
    acc2 = _mm256_fmadd_ps(w2, x2, acc2);
    acc3 = _mm256_fmadd_ps(w3, x3, acc3);
    
    wp += 32; 
    xp += 32;
    
  }
  __m256 acc8 = _mm256_add_ps(_mm256_add_ps(_mm256_add_ps(acc0, acc1), acc2), acc3);
  __m128 acc4 = _mm_add_ps(_mm256_castps256_ps128(acc8), _mm256_extractf128_ps(acc8, 1));
  __m128 accf = _mm_dp_ps(acc4, _mm_set1_ps(1.0f), 0xf1);
  return _mm_cvtss_f32(accf);
#else
  const int32_t groupSize = 32; // Group size for quantization
  int32_t countGroups = count / groupSize; // Number of groups
  float result = 0.0f; // Initialize the result to zero
  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){
    int32_t groupBaseIndex = groupIndex * groupSize; // Calculate the offset for the current group
    uint8_t *wGroup = &((uint8_t*)w)[groupBaseIndex]; // Pointer to the current group in w
    uint8_t *xGroup = &((uint8_t*)x)[groupBaseIndex]; // Pointer to the current group in x
    float sum = 0.0f; // Initialize the sum for this group
    #pragma omp simd reduction(+ : sum) simdlen(32)
    for(int32_t groupRelativeIndex = 0; groupRelativeIndex < groupSize; groupRelativeIndex++){
      // Calculate the dot product for the current group
      sum += FP8E5M2ToFP32(wGroup[groupRelativeIndex]) * FP8E5M2ToFP32(xGroup[groupRelativeIndex]);
    }
    result += sum; // Scale the sum and add it to the result
  }
  return result;
#endif
}

__attribute__((ms_abi)) void matMulF8E5M2F8E5M2(float* xout, const uint8_t *x, const uint8_t *w, const int32_t n, const int32_t a, const int32_t b){
  const int32_t m = n; // (n / 32) * 32;
  for(int i = a; i <= b; i++){
    xout[i] = dotproductF8E5M2F8E5M2(&w[i * m], &x[0], n); 
  }
}

__attribute__((ms_abi)) float dotproductBF16Q80(const void *w, const void *x, const int32_t count){
  const int32_t groupSize = 32; // Group size for quantization
  int32_t countGroups = count / groupSize; // Number of groups
  float result = 0.0f; // Initialize the result to zero
  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){
    uint16_t *wGroup = (uint16_t*)&((uint8_t*)w)[groupIndex * (groupSize * 2)]; // Pointer to the current group in w
    int8_t *xGroup = &((int8_t*)x)[groupIndex * (groupSize + 2)]; // Pointer to the current group in x
    float sum = 0.0f; // Initialize the sum for this group
    //#pragma omp simd reduction(+ : sum) simdlen(32)
    for(int32_t groupRelativeIndex = 0; groupRelativeIndex < groupSize; groupRelativeIndex++){
      // Calculate the dot product for the current group
      sum += BF16ToFP32(wGroup[groupRelativeIndex]) * ((int32_t)xGroup[groupRelativeIndex]);
    }
    result += sum * (*((_Float16*)&xGroup[groupSize])); // Scale the sum and add it to the result
  }
  return result;
}

__attribute__((ms_abi)) float dotproductF16Q80(const void *w, const void *x, const int32_t count){
  const int32_t groupSize = 32; // Group size for quantization
  int32_t countGroups = count / groupSize; // Number of groups
  float result = 0.0f; // Initialize the result to zero
  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){
    _Float16 *wGroup = (_Float16*)&((uint8_t*)w)[groupIndex * (groupSize * 2)]; // Pointer to the current group in w
    int8_t *xGroup = &((int8_t*)x)[groupIndex * (groupSize + 2)]; // Pointer to the current group in x
    float sum = 0.0f; // Initialize the sum for this group
    //#pragma omp simd reduction(+ : sum) simdlen(32)
    for(int32_t groupRelativeIndex = 0; groupRelativeIndex < groupSize; groupRelativeIndex++){
      // Calculate the dot product for the current group
      sum += ((float)(wGroup[groupRelativeIndex])) * ((int32_t)xGroup[groupRelativeIndex]);
    }
    result += sum * (*((_Float16*)&xGroup[groupSize])); // Scale the sum and add it to the result
  }
  return result;
}

__attribute__((ms_abi)) float dotproductF32Q80(const void *w, const void *x, const int32_t count){
  const int32_t groupSize = 32; // Group size for quantization
  int32_t countGroups = count / groupSize; // Number of groups
  float result = 0.0f; // Initialize the result to zero
  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){
    float *wGroup = (float*)&((uint8_t*)w)[groupIndex * (groupSize * 4)]; // Pointer to the current group in w
    int8_t *xGroup = &((int8_t*)x)[groupIndex * (groupSize + 2)]; // Pointer to the current group in x
    float sum = 0.0f; // Initialize the sum for this group
    //#pragma omp simd reduction(+ : sum) simdlen(32)
    for(int32_t groupRelativeIndex = 0; groupRelativeIndex < groupSize; groupRelativeIndex++){
      // Calculate the dot product for the current group
      sum += ((float)(wGroup[groupRelativeIndex])) * ((int32_t)xGroup[groupRelativeIndex]);
    }
    result += sum * (*((_Float16*)&xGroup[groupSize])); // Scale the sum and add it to the result
  }
  return result;
}

// Dot product function type for quantized inputs
typedef __attribute__((ms_abi)) float (*DotProductFunction)(const void *w, const void *x, const int32_t count);

__attribute__((ms_abi)) void matMul(float* xout, const void *w, const void *x, int32_t xGroupBytes, int32_t count, int32_t a, int32_t b, DotProductFunction dotProductFunc){
  for(int32_t i = a; i <= b; i++){
    xout[i] = dotProductFunc(w, &((uint8_t*)x)[i * xGroupBytes], count); 
  }
}

__attribute__((ms_abi)) void clearNaNBlock(float *x, const int32_t count){
  const __m256 vZero = _mm256_setzero_ps();
  for(int32_t i = 0; i < count; i += 8){
    __m256 v = _mm256_loadu_ps(&x[i]);
    __m256 m = _mm256_cmp_ps(v, v, _CMP_ORD_Q); // mask = ordered(x, x)  (true for finite or infinite, false for NaN)
    v = _mm256_blendv_ps(vZero, v, m); // NaNs become zero
    _mm256_storeu_ps(&x[i], v);
  }
}

// Quantize a float vector into Q80 format (int8 values with grouped scaling factors)
__attribute__((ms_abi)) void quantizeBlockQ80(float *x, uint8_t *q, const int32_t count){

  const int32_t groupSize = 32; // Group size for quantization
  const int32_t countGroups = count / groupSize; // number of groups

  const __m256 vHalf = _mm256_set1_ps(0.5f);
  const __m256 vZero = _mm256_setzero_ps();
  const __m256 signBit = _mm256_set1_ps(-0.0f);

  // Largest FP16 value
  const float fp16_max = 65504.0f;

  // To keep d representable as FP16: d = max/127 <= 65504 => max <= 65504*127
  const float max_allowed = fp16_max * 127.0f;
  const __m256 vMaxAllowed = _mm256_set1_ps(max_allowed);

  // For final clipping of scaled values before conversion to int
  const __m256 vNeg128 = _mm256_set1_ps(-128.0f);
  const __m256 vPos127 = _mm256_set1_ps(127.0f);

  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){

    // Load elements for the current group
    __m256 v0 = _mm256_loadu_ps(x);
    __m256 v1 = _mm256_loadu_ps(x + 8);
    __m256 v2 = _mm256_loadu_ps(x + 16);
    __m256 v3 = _mm256_loadu_ps(x + 24);
    x += 32;

    // --- sanitize: NaN -> 0; ±Inf / huge -> clamp to finite bound ---
    // mask = ordered(x, x)  (true for finite or infinite, false for NaN)
    __m256 m0 = _mm256_cmp_ps(v0, v0, _CMP_ORD_Q);
    __m256 m1 = _mm256_cmp_ps(v1, v1, _CMP_ORD_Q);
    __m256 m2 = _mm256_cmp_ps(v2, v2, _CMP_ORD_Q);
    __m256 m3 = _mm256_cmp_ps(v3, v3, _CMP_ORD_Q);

    // NaNs become zero
    v0 = _mm256_blendv_ps(vZero, v0, m0);
    v1 = _mm256_blendv_ps(vZero, v1, m1);
    v2 = _mm256_blendv_ps(vZero, v2, m2);
    v3 = _mm256_blendv_ps(vZero, v3, m3);

#if 0
    // Clamp to +/-max_allowed (this also converts +/-Inf to a big finite)     
    v0 = _mm256_max_ps(_mm256_min_ps(v0, vMaxAllowed), _mm256_sub_ps(vZero, vMaxAllowed));
    v1 = _mm256_max_ps(_mm256_min_ps(v1, vMaxAllowed), _mm256_sub_ps(vZero, vMaxAllowed));
    v2 = _mm256_max_ps(_mm256_min_ps(v2, vMaxAllowed), _mm256_sub_ps(vZero, vMaxAllowed));
    v3 = _mm256_max_ps(_mm256_min_ps(v3, vMaxAllowed), _mm256_sub_ps(vZero, vMaxAllowed));
#endif    
        
    // Compute max(abs(e)) for the block
    __m256 maxAbs = _mm256_andnot_ps(signBit, v0);
    maxAbs = _mm256_max_ps(maxAbs, _mm256_andnot_ps(signBit, v1));
    maxAbs = _mm256_max_ps(maxAbs, _mm256_andnot_ps(signBit, v2));
    maxAbs = _mm256_max_ps(maxAbs, _mm256_andnot_ps(signBit, v3));

    __m128 max4 = _mm_max_ps(_mm256_extractf128_ps(maxAbs, 1), _mm256_castps256_ps128(maxAbs));
    max4 = _mm_max_ps(max4, _mm_movehl_ps(max4, max4));
    max4 = _mm_max_ss(max4, _mm_movehdup_ps(max4));
    const float maxScalar = _mm_cvtss_f32(max4);

    // Quantize these floats
    const float d = maxScalar / 127.0f;
    
    // Store the scale factor as FP16 right after the 32 quantized bytes and check for zero
    if(d < 1e-6f){

      // If the scale is zero, all values must be zero

      // Store the empty quantized values 
      _mm256_storeu_si256((__m256i *)q, _mm256_setzero_si256());

      // Store the scale factor
      *((_Float16*)&q[groupSize]) = 0.0f;

    }else{

      const float id = (maxScalar != 0.0f) ? 127.f / maxScalar : 0.0f;
      const __m256 mul = _mm256_set1_ps(id);

      // Apply the multiplier
      v0 = _mm256_mul_ps(v0, mul);
      v1 = _mm256_mul_ps(v1, mul);
      v2 = _mm256_mul_ps(v2, mul);
      v3 = _mm256_mul_ps(v3, mul);

#if 0
      // Round to nearest integer (match roundf: half away from zero)
      __m256 rm0 = _mm256_cmp_ps(v0, vZero, _CMP_GE_OQ);
      __m256 rm1 = _mm256_cmp_ps(v1, vZero, _CMP_GE_OQ);
      __m256 rm2 = _mm256_cmp_ps(v2, vZero, _CMP_GE_OQ);
      __m256 rm3 = _mm256_cmp_ps(v3, vZero, _CMP_GE_OQ);

      __m256 v0b = _mm256_blendv_ps(_mm256_sub_ps(v0, vHalf), _mm256_add_ps(v0, vHalf), rm0);
      __m256 v1b = _mm256_blendv_ps(_mm256_sub_ps(v1, vHalf), _mm256_add_ps(v1, vHalf), rm1);
      __m256 v2b = _mm256_blendv_ps(_mm256_sub_ps(v2, vHalf), _mm256_add_ps(v2, vHalf), rm2);
      __m256 v3b = _mm256_blendv_ps(_mm256_sub_ps(v3, vHalf), _mm256_add_ps(v3, vHalf), rm3);

      v0 = _mm256_round_ps(v0b, _MM_FROUND_TO_ZERO | _MM_FROUND_NO_EXC);
      v1 = _mm256_round_ps(v1b, _MM_FROUND_TO_ZERO | _MM_FROUND_NO_EXC);
      v2 = _mm256_round_ps(v2b, _MM_FROUND_TO_ZERO | _MM_FROUND_NO_EXC);
      v3 = _mm256_round_ps(v3b, _MM_FROUND_TO_ZERO | _MM_FROUND_NO_EXC);
#else
      // Round to nearest integer
      v0 = _mm256_round_ps(v0, _MM_ROUND_NEAREST);
      v1 = _mm256_round_ps(v1, _MM_ROUND_NEAREST);
      v2 = _mm256_round_ps(v2, _MM_ROUND_NEAREST);
      v3 = _mm256_round_ps(v3, _MM_ROUND_NEAREST);
#endif

#if 0
      // Clip to [-128,127] to avoid overflow before int conversion/packing
      v0 = _mm256_min_ps(_mm256_max_ps(v0, vNeg128), vPos127);
      v1 = _mm256_min_ps(_mm256_max_ps(v1, vNeg128), vPos127);
      v2 = _mm256_min_ps(_mm256_max_ps(v2, vNeg128), vPos127);
      v3 = _mm256_min_ps(_mm256_max_ps(v3, vNeg128), vPos127);
#endif

      // Convert floats to integers
      __m256i i0 = _mm256_cvtps_epi32(v0);
      __m256i i1 = _mm256_cvtps_epi32(v1);
      __m256i i2 = _mm256_cvtps_epi32(v2);
      __m256i i3 = _mm256_cvtps_epi32(v3);

      // Convert int32 to int16
      i0 = _mm256_packs_epi32(i0, i1);	// 0, 1, 2, 3, 8, 9, 10, 11, 4, 5, 6, 7, 12, 13, 14, 15
      i2 = _mm256_packs_epi32(i2, i3);	// 16, 17, 18, 19, 24, 25, 26, 27, 20, 21, 22, 23, 28, 29, 30, 31

      // Convert int16 to int8
      i0 = _mm256_packs_epi16(i0, i2);	// 0, 1, 2, 3, 8, 9, 10, 11, 16, 17, 18, 19, 24, 25, 26, 27, 4, 5, 6, 7, 12, 13, 14, 15, 20, 21, 22, 23, 28, 29, 30, 31

      // We got our precious signed bytes, but the order is now wrong
      // These AVX2 pack instructions process 16-byte pieces independently
      // The following instruction is fixing the order
      const __m256i perm = _mm256_setr_epi32(0, 4, 1, 5, 2, 6, 3, 7);
      i0 = _mm256_permutevar8x32_epi32(i0, perm);

      // Store the result
      _mm256_storeu_si256((__m256i *)q, i0);

      // Store the scale factor
      *((_Float16*)&q[groupSize]) = d;

    }

    // Move to the next group
    q += 34;

  }

}

__attribute__((ms_abi)) void quantizeBlockQ80Ref(float *x, uint8_t *q, const int32_t count){

  const float Q_MAX = 127.0f; // max value for int8_t
  const int32_t groupSize = 32; // Group size for quantization
  const int32_t countGroups = count / groupSize; // number of groups
  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){

    // Calculate the base index for the current group
    int32_t baseIndex = groupIndex * groupSize;
    
    // find the max absolute value in the current group
    float maxValue = 0.0f;
    for(int32_t index = 0; index < groupSize; index++){
      const float value = fabsf(x[baseIndex + index]);
      if(maxValue < value){
        maxValue = value;
      }
    }
    
    // calculate the scaling factor
    const float scale = maxValue / Q_MAX;
    
    // calculate and write the quantized values and the scaling factor
    uint8_t *qGroup = &q[groupIndex * (groupSize + 2)]; // Pointer to the current group in q
    if(scale < 1e-6f){      
      // If the scale is too small, set all values to zero
      for(int32_t index = 0; index < groupSize; index++){
        qGroup[index] = 0; // Set to zero if scale is too small
      }
      *((_Float16*)&qGroup[groupSize]) = 0.0f; // Set the scale factor to zero
    }else{
      for(int32_t index = 0; index < groupSize; index++){
        qGroup[index] = (int8_t)roundf(x[baseIndex + index] / scale); // round and clamp
      }
      *((_Float16*)&qGroup[groupSize]) = scale; // Store the scale factor in the last two bytes
    }
      
  }

}

// Quantize a float vector into Q40 format
__attribute__((ms_abi)) void quantizeBlockQ40(float *x, uint8_t *q, const int32_t count){
  const float Q_MAX = 127.0f; // max value for int8_t
  const int32_t groupSize = 32; // Group size for quantization
  const int32_t halfGroupSize = groupSize >> 1; // Half group size for Q40
  const int32_t countGroups = count / groupSize; // number of groups
  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){

    // Calculate the base index for the current group
    int32_t baseIndex = groupIndex * groupSize;

    // find the max absolute value in the current group
    float maxValue = 0.0f;
    for(int32_t index = 0; index < groupSize; index++){
      const float value = fabsf(x[baseIndex + index]);
      if(maxValue < value){
        maxValue = value;
      }
    }
    
    // calculate the scaling factor
    const float scale = maxValue / Q_MAX;
    
    // calculate and write the quantized values and the scaling factor
    uint8_t *qGroup = &q[groupIndex * ((groupSize >> 1) + 2)]; // Pointer to the current group in q
    if(scale < 1e-6f){      
      // If the scale is too small, set all values to zero
      for(int32_t index = 0; index < halfGroupSize; index++){
        qGroup[index] = 0; // Set to zero if scale is too small
      }
      *((_Float16*)&qGroup[halfGroupSize]) = 0.0f; // Set the scale factor to zero
    }else{
      for(int32_t index = 0; index < halfGroupSize; index++){
        qGroup[index] = (((uint8_t)((int8_t)roundf(x[baseIndex + (index * 2) + 0] / scale) + 8) & 0x0f) << 0) |
                        (((uint8_t)((int8_t)roundf(x[baseIndex + (index * 2) + 1] / scale) + 8) & 0x0f) << 4); // round and clamp
      }
      *((_Float16*)&qGroup[halfGroupSize]) = scale; // Store the scale factor in the last two bytes
    }
      
  }

}

__attribute__((ms_abi)) void dequantizeBlockQ80(float *x, uint8_t *q, const int32_t count){
  const int32_t groupSize = 32; 
  const int32_t countGroups = count / groupSize; 
  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){
    int8_t *qGroup = &q[groupIndex * (groupSize + 2)];
    float scale = *((_Float16*)&qGroup[groupSize]); 
    float* xGroup = &x[groupIndex * groupSize];    
    for(int32_t index = 0; index < groupSize; index++){
      xGroup[index] = ((float)(qGroup[index])) * scale; 
    }      
  }
}

__attribute__((ms_abi)) void dequantizeBlockQ40(float *x, uint8_t *q, const int32_t count){
  const int32_t groupSize = 32; 
  const int32_t halfGroupSize = groupSize >> 1;
  const int32_t countGroups = count / groupSize; 
  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){
    uint8_t *qGroup = &q[groupIndex * (halfGroupSize + 2)];
    float scale = *((_Float16*)&qGroup[halfGroupSize]);
    float* xGroup = &x[groupIndex * groupSize];    
    for(int32_t index = 0; index < halfGroupSize; index++){
      uint8_t qValue = qGroup[index];
      *xGroup++ = (((int8_t)(qValue & 0x0f)) - 8) * scale; 
      *xGroup++ = (((int8_t)(qValue >> 4)) - 8) * scale; 
    }
  }
}


static inline __m256 sum_i16_pairs_float(const __m256i x) {
    const __m256i ones = _mm256_set1_epi16(1);
    const __m256i summed_pairs = _mm256_madd_epi16(ones, x);
    return _mm256_cvtepi32_ps(summed_pairs);
}

static inline __m256 mul_sum_us8_pairs_float(const __m256i ax, const __m256i sy) {
    // Perform multiplication and create 16-bit values
    const __m256i dot = _mm256_maddubs_epi16(ax, sy);
    return sum_i16_pairs_float(dot);
}

// multiply int8_t, add results pairwise twice and return as float vector
static inline __m256 mul_sum_i8_pairs_float(const __m256i x, const __m256i y) {
    // Get absolute values of x vectors
    const __m256i ax = _mm256_sign_epi8(x, x);
    // Sign the values of the y vectors
    const __m256i sy = _mm256_sign_epi8(y, x);
    return mul_sum_us8_pairs_float(ax, sy);
}

static inline float hsum_float_8(const __m256 x) {
    __m128 res = _mm256_extractf128_ps(x, 1);
    res = _mm_add_ps(res, _mm256_castps256_ps128(x));
    res = _mm_add_ps(res, _mm_movehl_ps(res, res));
    res = _mm_add_ss(res, _mm_movehdup_ps(res));
    return _mm_cvtss_f32(res);
}

__attribute__((ms_abi)) float dotproductQ80Q80ex(const void *w, const void *x, const int32_t count){
  const int32_t groupSize = 32; // Group size for quantization
  int32_t countGroups = count / groupSize; // Number of groups
   // Initialize accumulator with zeros
  __m256 acc = _mm256_setzero_ps();
  uint8_t* wp = (void*)w; 
  uint8_t* xp = (void*)x; 
  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){
    _Float16 ws = *((_Float16*)((void*)&wp[32]));
    _Float16 xs = *((_Float16*)((void*)&xp[32]));
     const __m256 d = _mm256_set1_ps((float)(ws * xs));
     __m256i qw = _mm256_loadu_si256((const __m256i *)wp);
     __m256i qx = _mm256_loadu_si256((const __m256i *)xp);
     const __m256 q = mul_sum_i8_pairs_float(qw, qx);
     acc = _mm256_fmadd_ps( d, q, acc );
     wp += 34;
     xp += 34;
  }
  return hsum_float_8(acc);
}

#if 0
    // Initialize accumulator with zeros
    __m256 acc = _mm256_setzero_ps();

    // Main loop
    for (; ib < nb; ++ib) {
        /* Compute combined scale for the block */
        const __m256 d = _mm256_set1_ps( GGML_FP16_TO_FP32(x[ib].d) * GGML_FP16_TO_FP32(y[ib].d) );

        __m256i qx = bytes_from_nibbles_32(x[ib].qs);

        // Now we have a vector with bytes in [ 0 .. 15 ] interval. Offset them into [ -8 .. +7 ] interval.
        const __m256i off = _mm256_set1_epi8( 8 );
        qx = _mm256_sub_epi8( qx, off );

        __m256i qy = _mm256_loadu_si256((const __m256i *)y[ib].qs);

        const __m256 q = mul_sum_i8_pairs_float(qx, qy);

        /* Multiply q with scale and accumulate */
        acc = _mm256_fmadd_ps( d, q, acc );
    }

    sumf = hsum_float_8(acc);
#endif

#define MM256_SET_M128I(a, b) _mm256_insertf128_si256(_mm256_castsi128_si256(b), (a), 1)

#if 0
// Unpack 32 4-bit fields into 32 bytes
// The output vector contains 32 bytes, each one in [ 0 .. 15 ] interval
static inline __m256i bytes_from_nibbles_32(const uint8_t * rsi){

  // Load 16 input bytes
  const __m128i tmp = _mm_loadu_si128((const __m128i *)rsi);

  // Build a 256-bit vector:
  //   upper 128 = tmp >> 4  (high nibbles of each input byte)
  //   lower 128 = tmp       (original bytes)
  const __m256i bytes = MM256_SET_M128I(_mm_srli_epi16(tmp, 4), tmp);

  // Keep only the low 4 bits of every byte
  const __m256i lowMask = _mm256_set1_epi8(0xf);
  const __m256i nibbles = _mm256_and_si256(bytes, lowMask);                                            // [L0..L15 | H0..H15]

  // Now we de-interleave the nibbles to get them into the right order
  // The nibbles are in the order: L0, L1, ..., L7, H0, H1, ..., H7
  // We want to swap them to: L0, H0, L1, H1, ..., L7, H7

   // Swap 128-bit lanes so we can interleave within each lane
  const __m256i swapped = _mm256_permute2x128_si256(nibbles, nibbles, 0x01);                           // [H | L]

  // Interleave within each 128-bit lane:
  const __m256i lowerInterleaved = _mm256_unpacklo_epi8(nibbles, swapped);                             // lane0: L0,H0,...,L7,H7
  const __m256i upperInterleaved = _mm256_unpackhi_epi8(nibbles, swapped);                             // lane0: L8,H8,...,L15,H15

  // Stitch the two interleaved halves together:
  // result = L0,H0, L1,H1, ..., L15,H15
  // Now value[i] is the low nibble and value[i+1] is the matching high nibble.  
  const __m256i nibblesShuffled = _mm256_permute2x128_si256(lowerInterleaved, upperInterleaved, 0x20); // take lane0 of each

  // The final result is a 256-bit vector with 32 bytes, each byte in [ 0 .. 15 ] interval
  return nibblesShuffled;
}
#endif

// Unpack 32 4-bit fields into 32 bytes
// The output vector contains 32 bytes, each one in [ 0 .. 15 ] interval
static inline __m256i bytes_from_nibbles_32(const uint8_t * rsi) {
  // load 16 packed bytes
  const __m128i tmp = _mm_loadu_si128((const __m128i*)rsi);

  // low nibbles: low = tmp & 0x0F
  const __m128i lowMask = _mm_set1_epi8(0x0F);
  const __m128i low     = _mm_and_si128(tmp, lowMask);

  // high nibbles shifted down: high = (tmp >> 4) & 0x0F
  // (shift per 16-bit lane avoids cross-byte contamination; mask keeps only the 4 low bits)
  const __m128i high    = _mm_and_si128(_mm_srli_epi16(tmp, 4), lowMask);

  // interleave within 128-bit lanes to get [low0,high0, low1,high1, ..., low7,high7]
  const __m128i lowerInterleaved = _mm_unpacklo_epi8(low,  high);  // bytes  0..15
  const __m128i upperInterleaved = _mm_unpackhi_epi8(low,  high);  // bytes 16..31

  // combine into 256-bit result: lower 128 = lowerInterleaved, upper 128 = upperInterleaved
  const __m256i nibblesShuffled = _mm256_set_m128i(upperInterleaved, lowerInterleaved);
  return nibblesShuffled;
}

__attribute__((ms_abi)) float dotproductQ40Q80(const void *w, const void *x, const int32_t count){
  const int32_t groupSize = 32; // Group size for quantization
  int32_t countGroups = count / groupSize; // Number of groups
  __m256 acc = _mm256_setzero_ps();
  uint8_t* wp = (void*)w;
  uint8_t* xp = (void*)x;
  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){
    __m256i qw = _mm256_sub_epi8(bytes_from_nibbles_32(wp), _mm256_set1_epi8(8)); // Offset into [-8, +7]
    __m256i qx = _mm256_loadu_si256((const __m256i *)xp);
    const __m256 d = _mm256_set1_ps(((float)(*((_Float16*)((void*)&wp[16])))) * ((float)(*((_Float16*)((void*)&xp[32])))));
    const __m256 q = mul_sum_i8_pairs_float(qw, qx);
    acc = _mm256_fmadd_ps(d, q, acc);
    wp += 18;
    xp += 34;
  }
  return hsum_float_8(acc);
}

__attribute__((ms_abi))
static float dotproductQ40NLQ80(const void *w, const void *x, const int32_t count){
  
  const int32_t groupSize = 32;
  const int32_t countGroups = count / groupSize;

  // The LUT for converting 4-bit non-linear nibbles to signed bytes in [-127, +127] range
  const __m256i lut = _mm256_setr_epi8(
    (int8_t)-127,(int8_t)-127,(int8_t)-101,(int8_t)-78,(int8_t)-57,(int8_t)-39,(int8_t)-23,(int8_t)-10,
    (int8_t)   0,(int8_t)   10,(int8_t)   23,(int8_t)  39,(int8_t)  57,(int8_t)  78,(int8_t) 101,(int8_t) 127,
    (int8_t)-127,(int8_t)-127,(int8_t)-101,(int8_t)-78,(int8_t)-57,(int8_t)-39,(int8_t)-23,(int8_t)-10,
    (int8_t)   0,(int8_t)   10,(int8_t)   23,(int8_t)  39,(int8_t)  57,(int8_t)  78,(int8_t) 101,(int8_t) 127
  );

  // The inverse of 127.0f
  const __m256 inv127 = _mm256_set1_ps(1.0f / 127.0f);

  // Initialize accumulator with zeros
  __m256 acc = _mm256_setzero_ps();

  // Pointers to the weight and activation vectors
  const uint8_t* wp = (const uint8_t*)w;
  const uint8_t* xp = (const uint8_t*)x;

  for (int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){

    // Load the 32 4-bit nibbles from the weight vector and convert them to bytes
    const __m256i idx = bytes_from_nibbles_32(wp);      // 32 bytes in [0..15]

    // Convert the 32 bytes to signed bytes in [-127, +127] range using the LUT
    const __m256i qw_nl = _mm256_shuffle_epi8(lut, idx);// ~127*f((q-8)/7) (with -8 clamped to -7 in LUT)

    // Load the activation vector values
    const __m256i qx = _mm256_loadu_si256((const __m256i *)xp);

    // Scale factor: d = scale(w) * scale(x)
    // where scale(w) = ((float)(*((_Float16*)((void*)(&wp[16]))))) * ((float)(*((_Float16*)((void*)(&xp[32]))))))
    // and scale(x) = 1/127
    const __m256 d = _mm256_mul_ps(
      _mm256_set1_ps(
        ((float)(*((_Float16*)((void*)(&wp[16]))))) * ((float)(*((_Float16*)((void*)(&xp[32])))))
      ), 
      inv127
    );

    // Calculate the dot product
    acc = _mm256_fmadd_ps(
      mul_sum_i8_pairs_float(qw_nl, qx), // multiply and sum pairs of int8_t values 
      d, // scale by the combined scale factor
      acc
    );

    wp += 18; 
    xp += 34;

  }

  return hsum_float_8(acc);

}

#if 1
__attribute__((ms_abi))
void dequantizeBlockQ40NL(float *x, const uint8_t *q, const int32_t count){

  // The LUT for converting 4-bit non-linear nibbles to signed bytes in [-127, +127] range
  static const int8_t  q40nlKValues[16] = { -127, -127, -101, -78, -57, -39, -23, -10, 0, 10, 23, 39, 57, 78, 101, 127 };

  const int32_t groupSize = 32; // Group size for quantization
  const int32_t halfGroupSize = groupSize >> 1;   // 16
  const int32_t countGroups = count / groupSize; // number of groups

  const __m128i lut  = _mm_loadu_si128((const __m128i*)q40nlKValues); // Load the LUT for non-linear nibbles into 128-bit vector

  const __m128i mask = _mm_set1_epi8(0x0f); // mask for low/high nibbles

  const float inv127 = 1.0f / 127.0f; // Inverse of 127.0f

  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){

    uint8_t *qGroup = &q[groupIndex * (halfGroupSize + 2)];   // 16 nibble bytes + 2B fp16 scale
    float *xGroup = &x[groupIndex * groupSize]; // 32 float outputs

    // scale = fp16 * (1/127)
    __m256 scale = _mm256_set1_ps(*((_Float16*)&qGroup[halfGroupSize]) * inv127);

    // Load 16 packed nibbles
    __m128i v      = _mm_loadu_si128((const __m128i*)qGroup);
    __m128i lo_idx = _mm_and_si128(v, mask);                       // low nibbles  (0..15)
    __m128i hi_idx = _mm_and_si128(_mm_srli_epi16(v, 4), mask);    // high nibbles (0..15)

    // LUT map (byte-wise): indices -> signed int8 values in [-127..127]
    __m128i lo_i8  = _mm_shuffle_epi8(lut, lo_idx);
    __m128i hi_i8  = _mm_shuffle_epi8(lut, hi_idx);

    // Interleave to keep scalar order: [lo0,hi0, lo1,hi1, ..., lo15,hi15]
    __m128i inter0 = _mm_unpacklo_epi8(lo_i8, hi_i8);  // 16 bytes -> first 16 outputs
    __m128i inter1 = _mm_unpackhi_epi8(lo_i8, hi_i8);  // 16 bytes -> next 16 outputs

    // i8 -> i16 (16 lanes each)
    __m256i i16_0  = _mm256_cvtepi8_epi16(inter0);
    __m256i i16_1  = _mm256_cvtepi8_epi16(inter1);

    // Split each 16x i16 into 2×(8x i32) and convert to float
    __m128i a0 = _mm256_castsi256_si128(i16_0);
    __m128i a1 = _mm256_extracti128_si256(i16_0, 1);
    __m128i b0 = _mm256_castsi256_si128(i16_1);
    __m128i b1 = _mm256_extracti128_si256(i16_1, 1);

    __m256 f0 = _mm256_cvtepi32_ps(_mm256_cvtepi16_epi32(a0));
    __m256 f1 = _mm256_cvtepi32_ps(_mm256_cvtepi16_epi32(a1));
    __m256 f2 = _mm256_cvtepi32_ps(_mm256_cvtepi16_epi32(b0));
    __m256 f3 = _mm256_cvtepi32_ps(_mm256_cvtepi16_epi32(b1));

    // Scale and store 32 floats in-order
    _mm256_storeu_ps(&xGroup[0], _mm256_mul_ps(f0, scale));
    _mm256_storeu_ps(&xGroup[8], _mm256_mul_ps(f1, scale));
    _mm256_storeu_ps(&xGroup[16], _mm256_mul_ps(f2, scale));
    _mm256_storeu_ps(&xGroup[24], _mm256_mul_ps(f3, scale));
  }
  
}
#else
__attribute__((ms_abi)) void dequantizeBlockQ40NL(float *x, uint8_t *q, const int32_t count){
  const int8_t q40nlKValues[16] = { -127, -127, -101, -78, -57, -39, -23, -10, 0, 10, 23, 39, 57, 78, 101, 127 };
  const float inv127 = 1.0f / 127.0f; // Inverse of 127.0f
  const int32_t groupSize = 32; 
  const int32_t halfGroupSize = groupSize >> 1;
  const int32_t countGroups = count / groupSize; 
  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){
    uint8_t *qGroup = &q[groupIndex * (halfGroupSize + 2)];
    float scale = *((_Float16*)&qGroup[halfGroupSize]) * inv127;
    float* xGroup = &x[groupIndex * groupSize];    
    for(int32_t index = 0; index < halfGroupSize; index++){
      uint8_t qValue = qGroup[index];
      *xGroup++ = q40nlKValues[qValue & 0x0f] * scale; 
      *xGroup++ = q40nlKValues[qValue >> 4] * scale; 
    }
  }
}
#endif

static inline uint8_t floatToQ40NLNibble(float value) {
  // Convert float to Q40NL nibble in range [-8, +7]
  value = (sqrtf(fabsf(value) * 8.0f + 1.0f) - 1.0f) * copysignf(0.5f, value);
  int8_t q = (int8_t)lrintf((value * 7.0f) + 8.0f); // Scale to [-8, +7] range
  q = ((q < -7) ? -7 : ((q > 7) ? 7 : q)) + 8; // Clamp to [-7, +7] and offset to [0, 15]
  return (uint8_t)q; // Return as unsigned byte
}

// Quantize a float vector into Q40NL format
__attribute__((ms_abi)) void quantizeBlockQ40NL(float *x, uint8_t *q, const int32_t count){
  const int32_t groupSize = 32; // Group size for quantization
  const int32_t halfGroupSize = groupSize >> 1; // Half group size for Q40
  const int32_t countGroups = count / groupSize; // number of groups
  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){

    // Calculate the base index for the current group
    int32_t baseIndex = groupIndex * groupSize;

    // find the max absolute value in the current group
    float maxValue = 0.0f;
    for(int32_t index = 0; index < groupSize; index++){
      const float value = fabsf(x[baseIndex + index]);
      if(maxValue < value){
        maxValue = value;
      }
    }
    
    // calculate the scaling factor
    const float scale = maxValue;
    
    // calculate and write the quantized values and the scaling factor
    uint8_t *qGroup = &q[groupIndex * ((groupSize >> 1) + 2)]; // Pointer to the current group in q
    if(scale < 1e-6f){      
      // If the scale is too small, set all values to zero
      for(int32_t index = 0; index < halfGroupSize; index++){
        qGroup[index] = 0; // Set to zero if scale is too small
      }
      *((_Float16*)&qGroup[halfGroupSize]) = 0.0f; // Set the scale factor to zero
    }else{
      for(int32_t index = 0; index < halfGroupSize; index++){
        qGroup[index] = ((uint8_t)(floatToQ40NLNibble(x[baseIndex + (index * 2) + 0] / scale) & 0x0f) << 0) |
                        ((uint8_t)(floatToQ40NLNibble(x[baseIndex + (index * 2) + 1] / scale) & 0x0f) << 4); // round and clamp
      }
      *((_Float16*)&qGroup[halfGroupSize]) = scale; // Store the scale factor in the last two bytes
    }
      
  }

}

static inline uint8_t floatToQ41NLNibble(float value) {
  // Convert float to Q41NL nibble in range [-8, +7]
  value = copysignf(sqrtf(fabsf(value)), value);
  int8_t q = (int8_t)lrintf((value * 7.0f) + 8.0f); // Scale to [-8, +7] range
  q = ((q < -7) ? -7 : ((q > 7) ? 7 : q)) + 8; // Clamp to [-7, +7] and offset to [0, 15]
  return (uint8_t)q; // Return as unsigned byte
}

// Quantize a float vector into Q41NL format
__attribute__((ms_abi)) void quantizeBlockQ41NL(float *x, uint8_t *q, const int32_t count){
  const int32_t groupSize = 32; // Group size for quantization
  const int32_t halfGroupSize = groupSize >> 1; // Half group size for Q41NL
  const int32_t countGroups = count / groupSize; // number of groups
  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){

    // Calculate the base index for the current group
    int32_t baseIndex = groupIndex * groupSize;

    // find the max absolute value in the current group
    float maxValue = 0.0f;
    for(int32_t index = 0; index < groupSize; index++){
      const float value = fabsf(x[baseIndex + index]);
      if(maxValue < value){
        maxValue = value;
      }
    }
    
    // calculate the scaling factor
    const float scale = maxValue;
    
    // calculate and write the quantized values and the scaling factor
    uint8_t *qGroup = &q[groupIndex * ((groupSize >> 1) + 2)]; // Pointer to the current group in q
    if(scale < 1e-6f){      
      // If the scale is too small, set all values to zero
      for(int32_t index = 0; index < halfGroupSize; index++){
        qGroup[index] = 0; // Set to zero if scale is too small
      }
      *((_Float16*)&qGroup[halfGroupSize]) = 0.0f; // Set the scale factor to zero
    }else{
      for(int32_t index = 0; index < halfGroupSize; index++){
        qGroup[index] = ((uint8_t)(floatToQ41NLNibble(x[baseIndex + (index * 2) + 0] / scale) & 0x0f) << 0) |
                        ((uint8_t)(floatToQ41NLNibble(x[baseIndex + (index * 2) + 1] / scale) & 0x0f) << 4); // round and clamp
      }
      *((_Float16*)&qGroup[halfGroupSize]) = scale; // Store the scale factor in the last two bytes
    }
      
  }

}

__attribute__((ms_abi))
static float dotproductQ41NLQ80(const void *w, const void *x, const int32_t count){
  
  const int32_t groupSize = 32;
  const int32_t countGroups = count / groupSize;

  // The LUT for converting 4-bit non-linear nibbles to signed bytes in [-127, +127] range
  const __m256i lut = _mm256_setr_epi8(
    (int8_t)-127, (int8_t)-127, (int8_t)-93, (int8_t)-65, (int8_t)-41, -(int8_t)23, (int8_t)-10, (int8_t)-3, 
    (int8_t)0, (int8_t)3, (int8_t)10, (int8_t)23, (int8_t)41, (int8_t)65, (int8_t)93, (int8_t)127,
    (int8_t)-127, (int8_t)-127, (int8_t)-93, (int8_t)-65, (int8_t)-41, -(int8_t)23, (int8_t)-10, (int8_t)-3, 
    (int8_t)0, (int8_t)3, (int8_t)10, (int8_t)23, (int8_t)41, (int8_t)65, (int8_t)93, (int8_t)127
  );

  // The inverse of 127.0f
  const __m256 inv127 = _mm256_set1_ps(1.0f / 127.0f);

  // Initialize accumulator with zeros
  __m256 acc = _mm256_setzero_ps();

  // Pointers to the weight and activation vectors
  const uint8_t* wp = (const uint8_t*)w;
  const uint8_t* xp = (const uint8_t*)x;

  for (int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){

    // Load the 32 4-bit nibbles from the weight vector and convert them to bytes
    const __m256i idx = bytes_from_nibbles_32(wp);      // 32 bytes in [0..15]

    // Convert the 32 bytes to signed bytes in [-127, +127] range using the LUT
    const __m256i qw_nl = _mm256_shuffle_epi8(lut, idx);// ~127*f((q-8)/7) (with -8 clamped to -7 in LUT)

    // Load the activation vector values
    const __m256i qx = _mm256_loadu_si256((const __m256i *)xp);

    // Scale factor: d = scale(w) * scale(x)
    // where scale(w) = ((float)(*((_Float16*)((void*)(&wp[16]))))) * ((float)(*((_Float16*)((void*)(&xp[32]))))))
    // and scale(x) = 1/127
    const __m256 d = _mm256_mul_ps(
      _mm256_set1_ps(
        ((float)(*((_Float16*)((void*)(&wp[16]))))) * ((float)(*((_Float16*)((void*)(&xp[32])))))
      ), 
      inv127
    );

    // Calculate the dot product
    acc = _mm256_fmadd_ps(
      mul_sum_i8_pairs_float(qw_nl, qx), // multiply and sum pairs of int8_t values 
      d, // scale by the combined scale factor
      acc
    );

    wp += 18; 
    xp += 34;

  }

  return hsum_float_8(acc);

}

#if 1
__attribute__((ms_abi))
void dequantizeBlockQ41NL(float *x, const uint8_t *q, const int32_t count){

  // The LUT for converting 4-bit non-linear nibbles to signed bytes in [-127, +127] range
  static const int8_t  q41nlKValues[16] = { -127, -127, -93, -65, -41, -23, -10, -3, 0, 3, 10, 23, 41, 65, 93, 127 };

  const int32_t groupSize = 32; // Group size for quantization
  const int32_t halfGroupSize = groupSize >> 1;   // 16
  const int32_t countGroups = count / groupSize; // number of groups

  const __m128i lut  = _mm_loadu_si128((const __m128i*)q41nlKValues); // Load the LUT for non-linear nibbles into 128-bit vector

  const __m128i mask = _mm_set1_epi8(0x0f); // mask for low/high nibbles

  const float inv127 = 1.0f / 127.0f; // Inverse of 127.0f

  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){

    uint8_t *qGroup = &q[groupIndex * (halfGroupSize + 2)];   // 16 nibble bytes + 2B fp16 scale
    float *xGroup = &x[groupIndex * groupSize]; // 32 float outputs

    // scale = fp16 * (1/127)
    __m256 scale = _mm256_set1_ps(*((_Float16*)&qGroup[halfGroupSize]) * inv127);

    // Load 16 packed nibbles
    __m128i v      = _mm_loadu_si128((const __m128i*)qGroup);
    __m128i lo_idx = _mm_and_si128(v, mask);                       // low nibbles  (0..15)
    __m128i hi_idx = _mm_and_si128(_mm_srli_epi16(v, 4), mask);    // high nibbles (0..15)

    // LUT map (byte-wise): indices -> signed int8 values in [-127..127]
    __m128i lo_i8  = _mm_shuffle_epi8(lut, lo_idx);
    __m128i hi_i8  = _mm_shuffle_epi8(lut, hi_idx);

    // Interleave to keep scalar order: [lo0,hi0, lo1,hi1, ..., lo15,hi15]
    __m128i inter0 = _mm_unpacklo_epi8(lo_i8, hi_i8);  // 16 bytes -> first 16 outputs
    __m128i inter1 = _mm_unpackhi_epi8(lo_i8, hi_i8);  // 16 bytes -> next 16 outputs

    // i8 -> i16 (16 lanes each)
    __m256i i16_0  = _mm256_cvtepi8_epi16(inter0);
    __m256i i16_1  = _mm256_cvtepi8_epi16(inter1);

    // Split each 16x i16 into 2×(8x i32) and convert to float
    __m128i a0 = _mm256_castsi256_si128(i16_0);
    __m128i a1 = _mm256_extracti128_si256(i16_0, 1);
    __m128i b0 = _mm256_castsi256_si128(i16_1);
    __m128i b1 = _mm256_extracti128_si256(i16_1, 1);

    __m256 f0 = _mm256_cvtepi32_ps(_mm256_cvtepi16_epi32(a0));
    __m256 f1 = _mm256_cvtepi32_ps(_mm256_cvtepi16_epi32(a1));
    __m256 f2 = _mm256_cvtepi32_ps(_mm256_cvtepi16_epi32(b0));
    __m256 f3 = _mm256_cvtepi32_ps(_mm256_cvtepi16_epi32(b1));

    // Scale and store 32 floats in-order
    _mm256_storeu_ps(&xGroup[0], _mm256_mul_ps(f0, scale));
    _mm256_storeu_ps(&xGroup[8], _mm256_mul_ps(f1, scale));
    _mm256_storeu_ps(&xGroup[16], _mm256_mul_ps(f2, scale));
    _mm256_storeu_ps(&xGroup[24], _mm256_mul_ps(f3, scale));
  }
  
}
#else
__attribute__((ms_abi)) void dequantizeBlockQ41NL(float *x, uint8_t *q, const int32_t count){
  const int8_t q41nlKValues[16] = { -127, -127, -93, -65, -41, -23, -10, -3, 0, 3, 10, 23, 41, 65, 93, 127 };
  const float inv127 = 1.0f / 127.0f; // Inverse of 127.0f
  const int32_t groupSize = 32; 
  const int32_t halfGroupSize = groupSize >> 1;
  const int32_t countGroups = count / groupSize; 
  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){
    uint8_t *qGroup = &q[groupIndex * (halfGroupSize + 2)];
    float scale = *((_Float16*)&qGroup[halfGroupSize]) * inv127;
    float* xGroup = &x[groupIndex * groupSize];    
    for(int32_t index = 0; index < halfGroupSize; index++){
      uint8_t qValue = qGroup[index];
      *xGroup++ = q41nlKValues[qValue & 0x0f] * scale; 
      *xGroup++ = q41nlKValues[qValue >> 4] * scale; 
    }
  }
}
#endif

static inline float e8m0ToHalfFP32(uint8_t x){
  union {
    uint32_t bits;
    float f;
  } u;
  u.bits = (x < 2) ? (0x00200000 << x) : ((uint32_t)((x - 1) << 23u));
  return u.f;
}

static int8_t mxfp4KValues[16] = {  0, 1, 2, 3, 4, 6, 8, 12, 0, -1, -2, -3, -4, -6, -8, -12 };

static inline int bestIndexMXFP4(float x, float e) {
  int bestIndex = 0;
  float bestError = fabsf((mxfp4KValues[0] * e) - x);
  for (int index = 1; index < 16; index++) {
    float error = fabsf((mxfp4KValues[index] * e) - x);
    if (error < bestError) {
      bestIndex = index;
      bestError = error;
    }
  }  
  return bestIndex;
}

__attribute__((ms_abi)) void quantizeBlockMXFP4(float *x, uint8_t *q, const int32_t count){
  const int32_t groupSize = 32; // Group size for quantization
  const int32_t halfGroupSize = groupSize >> 1; // Half group size for MXFP4
  const int32_t countGroups = count / groupSize; // number of groups
  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){
    // Calculate the base index for the current group
    int32_t baseIndex = groupIndex * groupSize;
    
    // find the max absolute value in the current group
    float maxValue = 0.0f;
    for(int32_t index = 0; index < groupSize; index++){
      const float value = fabsf(x[baseIndex + index]);
      if(maxValue < value){
        maxValue = value;
      }
    }
    
    // Calculate the exponent
    uint8_t exponent = (maxValue > 0.0f) ? (uint8_t)(floorf(log2f(maxValue)) + (127 - 2)) : 0; 

    // Calculate the scaling factor
    const float scale = e8m0ToHalfFP32(exponent);

    // Calculate and write the quantized values and the scaling factor
    uint8_t *qGroup = &q[groupIndex * (groupSize + 1)]; // Pointer to the current group in q    
    for(int32_t index = 0; index < halfGroupSize; index++){
      int32_t valueBaseIndex = baseIndex + (index << 1);
      qGroup[index] = (uint8_t)((bestIndexMXFP4(x[valueBaseIndex + 0], scale) & 0x0f) | ((bestIndexMXFP4(x[valueBaseIndex + 1], scale) & 0x0f) << 4));
    }

    // Store the exponent in the last byte
    qGroup[halfGroupSize] = exponent; // Store the exponent in the last byte    
      
  }

}

__attribute__((ms_abi)) void dequantizeBlockMXFP4(const uint8_t *q, float *x, const int32_t count){
  const int32_t groupSize = 32; // Group size for quantization
  const int32_t halfGroupSize = groupSize >> 1; // Half group size for MXFP4
  const int32_t countGroups = count / groupSize; // number of groups
  const uint8_t *qGroup = &q[0]; 
  float* xGroup = &x[0];    
  for(int32_t groupIndex = 0; groupIndex < countGroups; groupIndex++){
    float scale = e8m0ToHalfFP32(qGroup[halfGroupSize]); // Get the exponent from the last byte
    for(int32_t index = 0; index < halfGroupSize; index++){
      uint8_t qValue = qGroup[index];
      *xGroup++ = mxfp4KValues[qValue & 0x0f] * scale; 
      *xGroup++ = mxfp4KValues[qValue >> 4] * scale; 
    }
    qGroup += (halfGroupSize + 1);
  }
}

#ifdef __FMA__
#define MADD128(x, y, z) _mm_fmadd_ps(x, y, z)
#define NMADD128(x, y, z) _mm_fnmadd_ps(x, y, z)
#define MADD256(x, y, z) _mm256_fmadd_ps(x, y, z)
#define NMADD256(x, y, z) _mm256_fnmadd_ps(x, y, z)
#else
#define MADD128(x, y, z) _mm_add_ps(_mm_mul_ps(x, y), z)
#define NMADD128(x, y, z) _mm_sub_ps(z, _mm_mul_ps(x, y))
#define MADD256(x, y, z) _mm256_add_ps(_mm256_mul_ps(x, y), z)
#define NMADD256(x, y, z) _mm256_sub_ps(z, _mm256_mul_ps(x, y))
#endif

static const float GELU_COEF_A = .044715f;
static const float GELU_QUICK_COEF = -1.702f;
static const float SQRT_2_OVER_PI = .79788456080286535587989211986876f;

inline static float  gelu(float x) {
    return .5f*x*(1.f + tanhf(SQRT_2_OVER_PI*x*(1.0f + GELU_COEF_A*x*x)));
}


inline static __m256 vtanhf(__m256 x)
{
    const __m256 abs_mask = _mm256_castsi256_ps(_mm256_set1_epi32(0x7FFFFFFF));
    const __m256 one = _mm256_set1_ps(1);
    const __m256 two = _mm256_set1_ps(2);
    const __m256 ax = _mm256_and_ps(x, abs_mask);
    const __m256 sign = _mm256_and_ps(x, _mm256_set1_ps(-0.f));
    const __m256 is_boring =
      _mm256_cmp_ps(ax, _mm256_set1_ps(0x1.205966p+3), _CMP_GT_OQ);
    const __m256 boring = _mm256_or_ps(sign, one);
    const __m256 ex = _mm256_mul_ps(x, two);
    const __m256 j = MADD256(ex, _mm256_set1_ps(0x1.715476p+0f), _mm256_set1_ps(0x1.8p23f));
    const __m256 jj = _mm256_sub_ps(j, _mm256_set1_ps(0x1.8p23f));
    const __m256i i = _mm256_cvttps_epi32(jj);
    const __m256 f = NMADD256(_mm256_set1_ps(0x1.62e4p-1f), jj, ex);
    const __m256 f1 = NMADD256(_mm256_set1_ps(0x1.7f7d1cp-20f), jj, f);
    const __m256 f2 = _mm256_mul_ps(f1, f1);
    const __m256 f4 = _mm256_mul_ps(f2, f2);
    const __m256 p01 = MADD256(f1, _mm256_set1_ps(0x1.5554aep-3), _mm256_set1_ps(0x1.fffffep-2));
    const __m256 p23 = MADD256(f1, _mm256_set1_ps(0x1.12287cp-7), _mm256_set1_ps(0x1.555736p-5));
    const __m256 p03 = MADD256(f2, p23, p01);
    const __m256 p = MADD256(f4, _mm256_set1_ps(0x1.6b55a2p-10), p03);
    const __m256 p2 = MADD256(f2, p, f1);
    const __m256i u = _mm256_add_epi32(_mm256_slli_epi32(i, 23), _mm256_set1_epi32(0x3f800000));
    const __m256 t = _mm256_castsi256_ps(u);
    const __m256 q = MADD256(p2, t, _mm256_sub_ps(t, one));
    const __m256 y = _mm256_div_ps(q, _mm256_add_ps(q, two));
    return _mm256_or_ps(_mm256_and_ps(is_boring, boring), _mm256_andnot_ps(is_boring, y));
}

inline static __m256 vgeluf(__m256 x)
{
    const __m256 one = _mm256_set1_ps(1);
    const __m256 half = _mm256_set1_ps(.5);
    const __m256 coef_a = _mm256_set1_ps(GELU_COEF_A);
    const __m256 sqrt_2_over_pi = _mm256_set1_ps(SQRT_2_OVER_PI);
    const __m256 x_squared = _mm256_mul_ps(x, x);
    const __m256 ax2 = _mm256_mul_ps(coef_a, x_squared);
    const __m256 one_plus_ax2 = _mm256_add_ps(one, ax2);
    const __m256 inner =
      _mm256_mul_ps(_mm256_mul_ps(sqrt_2_over_pi, x), one_plus_ax2);
    const __m256 tanh_inner = vtanhf(inner);
    const __m256 one_plus_tanh = _mm256_add_ps(one, tanh_inner);
    return _mm256_mul_ps(_mm256_mul_ps(half, x), one_plus_tanh);
}

__attribute__((ms_abi)) void doGELU(float* o, float* a, float *b, int size) {
  int i = 0;
  for (; (i + 7) < size; i += 8) {
    _mm256_storeu_ps(&o[i], _mm256_mul_ps(vgeluf(_mm256_loadu_ps(&a[i])), _mm256_loadu_ps(&b[i])));
  }
  if(i < size){
    __m256i mask = _mm256_setr_epi32((i + 0) < size ? -1 : 0, (i + 1) < size ? -1 : 0, (i + 2) < size ? -1 : 0, (i + 3) < size ? -1 : 0, (i + 4) < size ? -1 : 0, (i + 5) < size ? -1 : 0, (i + 6) < size ? -1 : 0, (i + 7) < size ? -1 : 0);
    _mm256_maskstore_ps(&o[i], mask, _mm256_mul_ps(vgeluf(_mm256_maskload_ps(&a[i], mask)), _mm256_maskload_ps(&b[i], mask)));
  }
}

inline static __m256 v_expf(__m256 x) {
  const __m256 r = _mm256_set1_ps(0x1.8p23f);
  const __m256 z = _mm256_fmadd_ps(x, _mm256_set1_ps(0x1.715476p+0f), r);
  const __m256 n = _mm256_sub_ps(z, r);
  const __m256 b = _mm256_fnmadd_ps(n, _mm256_set1_ps(0x1.7f7d1cp-20f),
                                    _mm256_fnmadd_ps(n, _mm256_set1_ps(0x1.62e4p-1f), x));
  const __m256i e = _mm256_slli_epi32(_mm256_castps_si256(z), 23);
  const __m256 k = _mm256_castsi256_ps(
      _mm256_add_epi32(e, _mm256_castps_si256(_mm256_set1_ps(1))));
  const __m256i c = _mm256_castps_si256(
      _mm256_cmp_ps(_mm256_andnot_ps(_mm256_set1_ps(-0.f), n),
                    _mm256_set1_ps(126), _CMP_GT_OQ));
  const __m256 u = _mm256_mul_ps(b, b);
  const __m256 j = _mm256_fmadd_ps(_mm256_fmadd_ps(_mm256_fmadd_ps(_mm256_set1_ps(0x1.0e4020p-7f), b,
                                                                   _mm256_set1_ps(0x1.573e2ep-5f)), u,
                                                   _mm256_fmadd_ps(_mm256_set1_ps(0x1.555e66p-3f), b,
                                                                   _mm256_set1_ps(0x1.fffdb6p-2f))),
                                   u, _mm256_mul_ps(_mm256_set1_ps(0x1.ffffecp-1f), b));
  if (!_mm256_movemask_ps(_mm256_castsi256_ps(c)))
    return _mm256_fmadd_ps(j, k, k);
  const __m256i g = _mm256_and_si256(
      _mm256_castps_si256(_mm256_cmp_ps(n, _mm256_setzero_ps(), _CMP_LE_OQ)),
      _mm256_set1_epi32(0x82000000u));
  const __m256 s1 =
      _mm256_castsi256_ps(_mm256_add_epi32(g, _mm256_set1_epi32(0x7f000000u)));
  const __m256 s2 = _mm256_castsi256_ps(_mm256_sub_epi32(e, g));
  const __m256i d = _mm256_castps_si256(
      _mm256_cmp_ps(_mm256_andnot_ps(_mm256_set1_ps(-0.f), n),
                    _mm256_set1_ps(192), _CMP_GT_OQ));
  return _mm256_or_ps(
      _mm256_and_ps(_mm256_castsi256_ps(d), _mm256_mul_ps(s1, s1)),
      _mm256_andnot_ps(
          _mm256_castsi256_ps(d),
          _mm256_or_ps(
              _mm256_and_ps(_mm256_castsi256_ps(c),
                            _mm256_mul_ps(_mm256_fmadd_ps(s2, j, s2), s1)),
              _mm256_andnot_ps(_mm256_castsi256_ps(c), _mm256_fmadd_ps(k, j, k)))));
}

// computes silu x/(1+exp(-x)) in single precision vector
inline static __m256 v_siluf(__m256 x) {
    const __m256 one = _mm256_set1_ps(1);
    const __m256 zero = _mm256_setzero_ps();
    const __m256 neg_x = _mm256_sub_ps(zero, x);
    const __m256 exp_neg_x = v_expf(neg_x);
    const __m256 one_plus_exp_neg_x = _mm256_add_ps(one, exp_neg_x);
    return _mm256_div_ps(x, one_plus_exp_neg_x);
}

__attribute__((ms_abi)) void doSILU(float* o, float* a, float *b, int size) {
  int i = 0;
  for (; (i + 7) < size; i += 8) {
    _mm256_storeu_ps(&o[i], _mm256_mul_ps(v_siluf(_mm256_loadu_ps(&a[i])), _mm256_loadu_ps(&b[i])));
  }
  if(i < size){
    __m256i mask = _mm256_setr_epi32((i + 0) < size ? -1 : 0, (i + 1) < size ? -1 : 0, (i + 2) < size ? -1 : 0, (i + 3) < size ? -1 : 0, (i + 4) < size ? -1 : 0, (i + 5) < size ? -1 : 0, (i + 6) < size ? -1 : 0, (i + 7) < size ? -1 : 0);
    _mm256_maskstore_ps(&o[i], mask, _mm256_mul_ps(v_siluf(_mm256_maskload_ps(&a[i], mask)), _mm256_maskload_ps(&b[i], mask)));
  }
}

