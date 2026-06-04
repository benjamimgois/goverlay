#ifndef TEXTUREUTILS_GLSL
#define TEXTUREUTILS_GLSL

vec4 textureBicubicCoefficents(const in float v){
  vec4 n = vec4(1.0, 2.0, 3.0, 4.0) - v, s = n * n * n;
  vec3 t = vec3(s.x, s.y - (4.0 * s.x), (s.z - (4.0 * s.y)) + (6.0 * s.x));
  return vec4(t, 6.0 - dot(t, vec3(1.0))) * (1.0 / 6.0);
}

vec4 textureBicubic(const in sampler2D tex, in vec2 uv, const in int lod){
  vec2 texSize = textureSize(tex, lod);
  uv = fma(uv, texSize, vec2(-0.5));
  vec2 fuv = fract(uv);
  vec4 xCoefficients = textureBicubicCoefficents(fuv.x),
       yCoefficients = textureBicubicCoefficents(fuv.y),
       sums = vec4(xCoefficients.xz + xCoefficients.yw, yCoefficients.xz + yCoefficients.yw),
       samplePositions = (((uv - fuv).xxyy + vec2(-0.5, +1.5).xyxy) + (vec4(xCoefficients.yw, yCoefficients.yw) / sums)) / texSize.xxyy;
  vec3 f = vec3(sums.x / (sums.x + sums.y), sums.z / (sums.z + sums.w), float(lod));
  return mix(mix(textureLod(tex, samplePositions.yw, f.z), textureLod(tex, samplePositions.xw, f.z), f.x), 
             mix(textureLod(tex, samplePositions.yz, f.z), textureLod(tex, samplePositions.xz, f.z), f.x), f.y);
}           

vec4 textureCatmullRomCoefficents(const in float v){
  float t = v, tt = t * t, ttt = tt * t;
  return vec4((tt - (ttt * 0.5)) - (0.5 * t), ((ttt * 1.5) - (tt * 2.5)) + 1.0, ((tt * 2.0) - (ttt * 1.5)) + (t * 0.5), (ttt * 0.5) - (tt * 0.5));  
}

vec4 textureCatmullRom(const in sampler2DArray tex, const in vec3 uvw, const in float lod){
  vec2 texSize = textureSize(tex, int(lod)).xy;
  vec2 uv = uvw.xy;
  vec2 samplePos = uv * texSize;
  vec2 p11 = floor(samplePos - vec2(0.5)) + vec2(0.5);
  vec2 t = samplePos - p11, tt = t * t, ttt = tt * t;
  vec2 w0 = (tt - (ttt * 0.5)) - (0.5 * t);
  vec2 w1 = ((ttt * 1.5) - (tt * 2.5)) + vec2(1.0);
  vec2 w2 = ((tt * 2.0) - (ttt * 1.5)) + (t * 0.5);
  vec2 w3 = (ttt * 0.5) - (tt * 0.5);  
  vec2 w4 = w1 + w2;
  vec2 p00 = (p11 - vec2(1.0)) / texSize;
  vec2 p33 = (p11 + vec2(2.0)) / texSize;
  vec2 p12 = (p11 + (w2 / w4)) / texSize;
  return (((textureLod(tex, vec3(vec2(p00.x,  p00.y), uvw.z), float(lod)) * w0.x) +
           (textureLod(tex, vec3(vec2(p12.x, p00.y), uvw.z), float(lod)) * w4.x) +
           (textureLod(tex, vec3(vec2(p33.x,  p00.y), uvw.z), float(lod)) * w3.x)) * w0.y) +
         (((textureLod(tex, vec3(vec2(p00.x,  p12.y), uvw.z), float(lod)) * w0.x) +
           (textureLod(tex, vec3(vec2(p12.x, p12.y), uvw.z), float(lod)) * w4.x) +
           (textureLod(tex, vec3(vec2(p33.x,  p12.y), uvw.z), float(lod)) * w3.x)) * w4.y) +
         (((textureLod(tex, vec3(vec2(p00.x,  p33.y), uvw.z), float(lod)) * w0.x) +
           (textureLod(tex, vec3(vec2(p12.x, p33.y), uvw.z), float(lod)) * w4.x) +
           (textureLod(tex, vec3(vec2(p33.x,  p33.y), uvw.z), float(lod)) * w3.x)) * w3.y);
}

/*
vec4 textureCatmullRom(sampler2DArray sourceTexture, vec3 uvw, float lod){
  vec2 texSize = vec2(textureSize(sourceTexture, int(lod)).xy),
       xy = uvw.xy * texSize,
       p1 = floor(xy - vec2(0.5)) + vec2(0.5),
       f = xy - p1, 
       f2 = f * f,
       w0 = f * fma(f, fma(f, vec2(-0.5), vec2(1.0)), vec2(-0.5)),
       w1 = fma(f2, fma(f, vec2(1.5), vec2(-2.5)), vec2(1.0)),
       w2 = f * fma(f, fma(f, vec2(-1.5), vec2(2.0)), vec2(0.5)),
       w3 = f2 * fma(f, vec2(0.5), vec2(-0.5)),
       w12 = w1 + w2,
       p0 = (p1 - vec2(1.0)) / texSize, 
       p2 = (p1 + vec2(2.0)) / texSize, 
       p3 = (p1 + (w2 / (w1 + w2))) / texSize;
	return
    (
     (((textureLod(sourceTexture, vec3(p0.x, p0.y, uvw.z), float(lod)) * w0.x) +
       (textureLod(sourceTexture, vec3(p3.x, p0.y, uvw.z), float(lod)) * w12.x) +
       (textureLod(sourceTexture, vec3(p2.x, p0.y, uvw.z), float(lod)) * w3.x)) * w0.y) +
     (((textureLod(sourceTexture, vec3(p0.x, p3.y, uvw.z), float(lod)) * w0.x) +
       (textureLod(sourceTexture, vec3(p3.x, p3.y, uvw.z), float(lod)) * w12.x) +
       (textureLod(sourceTexture, vec3(p2.x, p3.y, uvw.z), float(lod)) * w3.x)) * w12.y) +
     (((textureLod(sourceTexture, vec3(p0.x, p2.y, uvw.z), float(lod)) * w0.x) +
       (textureLod(sourceTexture, vec3(p3.x, p2.y, uvw.z), float(lod)) * w12.x) +
       (textureLod(sourceTexture, vec3(p2.x, p2.y, uvw.z), float(lod)) * w3.x)) * w3.y)
    );
}
*/

#if 1
#if 1
// Catmull-Rom in 9 samples - the most correct one in comparison to the others visually 
vec4 textureCatmullRom(const in sampler2D tex, const in vec2 uv, const in int lod){
  vec2 texSize = textureSize(tex, lod);
  vec2 samplePos = uv * texSize;
  vec2 p11 = floor(samplePos - vec2(0.5)) + vec2(0.5);
  vec2 t = samplePos - p11, tt = t * t, ttt = tt * t;
  vec2 w0 = (tt - (ttt * 0.5)) - (0.5 * t);
  vec2 w1 = ((ttt * 1.5) - (tt * 2.5)) + vec2(1.0);
  vec2 w2 = ((tt * 2.0) - (ttt * 1.5)) + (t * 0.5);
  vec2 w3 = (ttt * 0.5) - (tt * 0.5);  
  vec2 w4 = w1 + w2;
  vec2 p00 = (p11 - vec2(1.0)) / texSize;
  vec2 p33 = (p11 + vec2(2.0)) / texSize;
  vec2 p12 = (p11 + (w2 / w4)) / texSize;
  return (((textureLod(tex, vec2(p00.x,  p00.y), float(lod)) * w0.x) +
           (textureLod(tex, vec2(p12.x, p00.y), float(lod)) * w4.x) +
           (textureLod(tex, vec2(p33.x,  p00.y), float(lod)) * w3.x)) * w0.y) +
         (((textureLod(tex, vec2(p00.x,  p12.y), float(lod)) * w0.x) +
           (textureLod(tex, vec2(p12.x, p12.y), float(lod)) * w4.x) +
           (textureLod(tex, vec2(p33.x,  p12.y), float(lod)) * w3.x)) * w4.y) +
         (((textureLod(tex, vec2(p00.x,  p33.y), float(lod)) * w0.x) +
           (textureLod(tex, vec2(p12.x, p33.y), float(lod)) * w4.x) +
           (textureLod(tex, vec2(p33.x,  p33.y), float(lod)) * w3.x)) * w3.y);
}
#else
// Catmull-Rom in 4 samples
vec4 textureCatmullRom(const in sampler2D tex, in vec2 uv, const in int lod){
  vec2 texSize = textureSize(tex, lod);
  uv = fma(uv, texSize, vec2(-0.5));
  vec2 fuv = fract(uv);
  vec4 xCoefficients = textureCatmullRomCoefficents(fuv.x),
       yCoefficients = textureCatmullRomCoefficents(fuv.y),
       sums = vec4(xCoefficients.xz + xCoefficients.yw, yCoefficients.xz + yCoefficients.yw),
       samplePositions = (((uv - fuv).xxyy + vec2(-0.5, +1.5).xyxy) + (vec4(xCoefficients.yw, yCoefficients.yw) / sums)) / texSize.xxyy;
  vec3 f = vec3(sums.x / (sums.x + sums.y), sums.z / (sums.z + sums.w), float(lod));
  return mix(mix(textureLod(tex, samplePositions.yw, f.z), textureLod(tex, samplePositions.xw, f.z), f.x), 
             mix(textureLod(tex, samplePositions.yz, f.z), textureLod(tex, samplePositions.xz, f.z), f.x), f.y);
}
#endif
#else
// based on: https://www.decarpentier.nl/2d-catmull-rom-in-4-samples - but is buggy
vec4 textureCatmullRom(const in sampler2D tex, const in vec2 uv, const in int lod){
  vec2 texSize = textureSize(tex, lod);
  vec2 h = fma(fract(fma(uv, texSize * 0.5, vec2(-0.25))), vec2(2.0), vec2(-1.0));
  vec2 f = fract(h);
  vec2 s1 = fma(f, vec2(0.5), vec2(-0.5)) * f;
  vec2 s12 = fma(f, fma(f, vec2(-2.0), vec2(1.5)), vec2(1.0));
  vec2 s34 = fma(f, fma(f, vec2(2.0), vec2(-2.5)), vec2(-0.5));
  vec4 p = vec4((s1 - (f * s12)) / (texSize * s12), ((s1 + s34) - (f * s34)) / (texSize * s34)) + uv.xyxy;
  float s = ((h.x * h.y) > 0.0) ? 1.0 : -1.0;
  vec4 w  = vec4(s12 - (f * s12), s34 * f);
  w = vec4(w.xz * (w.y * s), w.xz * (w.w * s));
  return (textureLod(tex, p.xy, float(lod)) * w.x) + (textureLod(tex, p.zy, float(lod)) * w.y) +
         (textureLod(tex, p.xw, float(lod)) * w.z) + (textureLod(tex, p.zw, float(lod)) * w.w);
}
#endif

vec4 textureTriplanar(const in sampler2D t, const in vec3 p, const in vec3 n, const in float k, const in vec3 gx, const in vec3 gy){
//vec2 r = textureSize(t, 0);
  vec3 m = pow(abs(n), vec3(k));
  return ((textureGrad(t, p.yz, gx.yz, gy.yz) * m.x) + 
          (textureGrad(t, p.zx, gx.zx, gy.zx) * m.y) + 
          (textureGrad(t, p.xy, gx.xy, gy.xy) * m.z)) / (m.x + m.y + m.z);
}           

vec2 getNiceTextureUV(vec2 uv, vec2 textureResolution){
  uv = fma(uv, textureResolution, vec2(0.5));
  vec2 iuv = floor(uv);
  vec2 fuv = fract(uv);
  uv = iuv + ((fuv * fuv) * fma(fuv, vec2(-2.0), vec2(3.0)));
  uv = (uv - vec2(0.5)) / textureResolution;
  return uv;
}

vec3 getNiceTextureUVW(vec3 uvw, vec3 textureResolution){
  uvw = fma(uvw, textureResolution, vec3(0.5));
  vec3 iuvw = floor(uvw);
  vec3 fuvw = fract(uvw);
  uvw = iuvw + ((fuvw * fuvw) * fma(fuvw, vec3(-2.0), vec3(3.0)));
  uvw = (uvw - vec3(0.5)) / textureResolution;
  return uvw;
}

vec4 textureNice(const sampler2D t, vec2 uv, float lod){
  vec2 textureResolution = vec2(textureSize(t, int(lod)).xy);
  uv = fma(uv, textureResolution, vec2(0.5));
  vec2 iuv = floor(uv);
  vec2 fuv = fract(uv);
  uv = iuv + ((fuv * fuv) * fma(fuv, vec2(-2.0), vec2(3.0)));
  uv = (uv - vec2(0.5)) / textureResolution;
  return textureLod(t, uv, lod);
}

#endif
