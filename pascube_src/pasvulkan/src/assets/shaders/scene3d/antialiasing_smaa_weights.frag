#version 450 core

#extension GL_EXT_multiview : enable
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable
#extension GL_GOOGLE_include_directive : enable

#include "antialiasing_smaa.glsl"
 
// Non-Configurable Defines
#define SMAA_AREATEX_MAX_DISTANCE 16
#define SMAA_AREATEX_MAX_DISTANCE_DIAG 20
#define SMAA_AREATEX_PIXEL_SIZE (1.0 / vec2(160.0, 560.0))
#define SMAA_AREATEX_SUBTEX_SIZE (1.0 / 7.0)
#define SMAA_SEARCHTEX_SIZE vec2(66.0, 33.0)
#define SMAA_SEARCHTEX_PACKED_SIZE vec2(64.0, 16.0)
#define SMAA_CORNER_ROUNDING_NORM (float(SMAA_CORNER_ROUNDING) / 100.0)

// Texture Access Defines
#ifndef SMAA_AREATEX_SELECT
#define SMAA_AREATEX_SELECT(sample) sample.xy
#endif

#ifndef SMAA_SEARCHTEX_SELECT
#define SMAA_SEARCHTEX_SELECT(sample) sample.x
#endif

layout(location = 0) in vec2 inTexCoord;
layout(location = 1) in vec2 inPixCoord;
layout(location = 2) in vec4 inOffset0;
layout(location = 3) in vec4 inOffset1;
layout(location = 4) in vec4 inOffset2;

layout(location = 0) out vec4 outFragOutput;

layout(set = 0, binding = 0) uniform sampler2DArray uEdgeTexture;
layout(set = 0, binding = 1) uniform sampler2D uAreaTexture;
layout(set = 0, binding = 2) uniform sampler2D uSearchTexture;

layout(push_constant) uniform PushConstants {
  vec4 metrics;  //
  vec4 subsampleIndices;  // Just pass zero for SMAA 1x, see @SUBSAMPLE_INDICES.
} pushConstants;

vec4 SMAA_RT_METRICS = pushConstants.metrics;

#define round(v) floor(v + 0.5)
#define SMAASampleLevelZeroOffset(tex, coord, offset) textureLod(tex, vec3(coord + offset * SMAA_RT_METRICS.xy, float(gl_ViewIndex)), 0)

/**
 * Conditional move:
 */
void SMAAMovc(bvec2 cond, inout vec2 variable, vec2 value) {
  if (cond.x) variable.x = value.x;
  if (cond.y) variable.y = value.y;
}

void SMAAMovc(bvec4 cond, inout vec4 variable, vec4 value) {
  SMAAMovc(cond.xy, variable.xy, value.xy);
  SMAAMovc(cond.zw, variable.zw, value.zw);
}

/**
 * Allows to decode two binary values from a bilinear-filtered access.
 */
vec2 SMAADecodeDiagBilinearAccess(vec2 e) {
  // Bilinear access for fetching 'e' have a 0.25 offset, and we are
  // interested in the R and G edges:
  //
  // +---G---+-------+
  // |   x o R   x   |
  // +-------+-------+
  //
  // Then, if one of these edge is enabled:
  //   Red:   (0.75 * X + 0.25 * 1) => 0.25 or 1.0
  //   Green: (0.75 * 1 + 0.25 * X) => 0.75 or 1.0
  //
  // This function will unpack the values (mad + mul + round):
  // wolframalpha.com: round(x * abs(5 * x - 5 * 0.75)) plot 0 to 1
  e.r = e.r * abs(5.0 * e.r - 5.0 * 0.75);
  return round(e);
}

vec4 SMAADecodeDiagBilinearAccess(vec4 e) {
  e.rb = e.rb * abs(5.0 * e.rb - 5.0 * 0.75);
  return round(e);
}

/**
 * These functions allows to perform diagonal pattern searches.
 */
vec2 SMAASearchDiag1(sampler2DArray edgeTexture, vec2 texcoord, vec2 dir, out vec2 e) {
  vec4 coord = vec4(texcoord, -1.0, 1.0);
  vec3 t = vec3(SMAA_RT_METRICS.xy, 1.0);

  for (int i = 0; i < SMAA_MAX_SEARCH_STEPS; i++) {
    if (!(coord.z < float(SMAA_MAX_SEARCH_STEPS_DIAG - 1) && coord.w > 0.9)) break;
    coord.xyz = fma(t, vec3(dir, 1.0), coord.xyz);
    e = textureLod(edgeTexture, vec3(coord.xy, float(gl_ViewIndex)), 0).xy;  // LinearSampler
    coord.w = dot(e, vec2(0.5, 0.5));
  }
  return coord.zw;
}

vec2 SMAASearchDiag2(sampler2DArray edgeTexture, vec2 texcoord, vec2 dir, out vec2 e) {
  vec4 coord = vec4(texcoord, -1.0, 1.0);
  coord.x += 0.25 * SMAA_RT_METRICS.x;  // See @SearchDiag2Optimization
  vec3 t = vec3(SMAA_RT_METRICS.xy, 1.0);

  for (int i = 0; i < SMAA_MAX_SEARCH_STEPS; i++) {
    if (!(coord.z < float(SMAA_MAX_SEARCH_STEPS_DIAG - 1) && coord.w > 0.9)) break;
    coord.xyz = fma(t, vec3(dir, 1.0), coord.xyz);

    // @SearchDiag2Optimization
    // Fetch both edges at once using bilinear filtering:
    e = textureLod(edgeTexture, vec3(coord.xy, float(gl_ViewIndex)), 0).xy;  // LinearSampler
    e = SMAADecodeDiagBilinearAccess(e);

    // Non-optimized version:
    // e.g = texture2D(uEdgeTexture, coord.xy).g; // LinearSampler
    // e.r = SMAASampleLevelZeroOffset(uEdgeTexture, coord.xy, vec2(1, 0)).r;

    coord.w = dot(e, vec2(0.5, 0.5));
  }
  return coord.zw;
}

/**
 * Similar to SMAAArea, this calculates the area corresponding to a certain
 * diagonal distance and crossing edges 'e'.
 */
vec2 SMAAAreaDiag(sampler2D areaTex, vec2 dist, vec2 e, float offset) {
  vec2 texcoord = fma(vec2(SMAA_AREATEX_MAX_DISTANCE_DIAG, SMAA_AREATEX_MAX_DISTANCE_DIAG), e, dist);

  // We do a scale and bias for mapping to texel space:
  texcoord = fma(SMAA_AREATEX_PIXEL_SIZE, texcoord, 0.5 * SMAA_AREATEX_PIXEL_SIZE);

  // Diagonal areas are on the second half of the texture:
  texcoord.x += 0.5;

  // Move to proper place, according to the subpixel offset:
  texcoord.y += SMAA_AREATEX_SUBTEX_SIZE * offset;

  // Do it!
  return SMAA_AREATEX_SELECT(textureLod(areaTex, texcoord, 0));  // LinearSampler
}

/**
 * This searches for diagonal patterns and returns the corresponding weights.
 */
vec2 SMAACalculateDiagWeights(sampler2DArray edgeTexture, sampler2D areaTex, vec2 texcoord, vec2 e, vec4 subsampleIndices) {
  vec2 weights = vec2(0.0, 0.0);

  // Search for the line ends:
  vec4 d;
  vec2 end;
  if (e.r > 0.0) {
    d.xz = SMAASearchDiag1(edgeTexture, texcoord, vec2(-1.0, 1.0), end);
    d.x += float(end.y > 0.9);
  } else
    d.xz = vec2(0.0, 0.0);
  d.yw = SMAASearchDiag1(edgeTexture, texcoord, vec2(1.0, -1.0), end);

  if (d.x + d.y > 2.0) {  // d.x + d.y + 1 > 3
    // Fetch the crossing edges:
    vec4 coords = fma(vec4(-d.x + 0.25, d.x, d.y, -d.y - 0.25), SMAA_RT_METRICS.xyxy, texcoord.xyxy);
    vec4 c;
    c.xy = SMAASampleLevelZeroOffset(edgeTexture, coords.xy, vec2(-1, 0)).rg;
    c.zw = SMAASampleLevelZeroOffset(edgeTexture, coords.zw, vec2(1, 0)).rg;
    c.yxwz = SMAADecodeDiagBilinearAccess(c.xyzw);

    // Non-optimized version:
    // vec4 coords = mad(vec4(-d.x, d.x, d.y, -d.y), SMAA_RT_METRICS.xyxy, texcoord.xyxy);
    // vec4 c;
    // c.x = SMAASampleLevelZeroOffset(uEdgeTexture, coords.xy, vec2(-1,  0)).g;
    // c.y = SMAASampleLevelZeroOffset(uEdgeTexture, coords.xy, vec2( 0,  0)).r;
    // c.z = SMAASampleLevelZeroOffset(uEdgeTexture, coords.zw, vec2( 1,  0)).g;
    // c.w = SMAASampleLevelZeroOffset(uEdgeTexture, coords.zw, vec2( 1, -1)).r;

    // Merge crossing edges at each side into a single value:
    vec2 cc = fma(vec2(2.0, 2.0), c.xz, c.yw);

    // Remove the crossing edge if we didn't found the end of the line:
    SMAAMovc(bvec2(step(0.9, d.zw)), cc, vec2(0.0, 0.0));

    // Fetch the areas for this line:
    weights += SMAAAreaDiag(areaTex, d.xy, cc, subsampleIndices.z);
  }

  // Search for the line ends:
  d.xz = SMAASearchDiag2(edgeTexture, texcoord, vec2(-1.0, -1.0), end);
  if (SMAASampleLevelZeroOffset(edgeTexture, texcoord, vec2(1, 0)).r > 0.0) {
    d.yw = SMAASearchDiag2(edgeTexture, texcoord, vec2(1.0, 1.0), end);
    d.y += float(end.y > 0.9);
  } else {
    d.yw = vec2(0.0, 0.0);
  }

  if (d.x + d.y > 2.0) {  // d.x + d.y + 1 > 3
    // Fetch the crossing edges:
    vec4 coords = fma(vec4(-d.x, -d.x, d.y, d.y), SMAA_RT_METRICS.xyxy, texcoord.xyxy);
    vec4 c;
    c.x = SMAASampleLevelZeroOffset(edgeTexture, coords.xy, vec2(-1, 0)).y;
    c.y = SMAASampleLevelZeroOffset(edgeTexture, coords.xy, vec2(0, -1)).x;
    c.zw = SMAASampleLevelZeroOffset(edgeTexture, coords.zw, vec2(1, 0)).yx;
    vec2 cc = fma(vec2(2.0, 2.0), c.xz, c.yw);

    // Remove the crossing edge if we didn't found the end of the line:
    SMAAMovc(bvec2(step(0.9, d.zw)), cc, vec2(0.0, 0.0));

    // Fetch the areas for this line:
    weights += SMAAAreaDiag(areaTex, d.xy, cc, subsampleIndices.w).gr;
  }

  return weights;
}

/**
 * This allows to determine how much length should we add in the last step
 * of the searches. It takes the bilinearly interpolated edge (see
 * @PSEUDO_GATHER4), and adds 0, 1 or 2, depending on which edges and
 * crossing edges are active.
 */
float SMAASearchLength(sampler2D searchTex, vec2 e, float offset) {
  // The texture is flipped vertically, with left and right cases taking half
  // of the space horizontally:
  vec2 scale = SMAA_SEARCHTEX_SIZE * vec2(0.5, -1.0);
  vec2 bias = SMAA_SEARCHTEX_SIZE * vec2(offset, 1.0);

  // Scale and bias to access texel centers:
  scale += vec2(-1.0, 1.0);
  bias += vec2(0.5, -0.5);

  // Convert from pixel coordinates to texcoords:
  // (We use SMAA_SEARCHTEX_PACKED_SIZE because the texture is cropped)
  scale *= 1.0 / SMAA_SEARCHTEX_PACKED_SIZE;
  bias *= 1.0 / SMAA_SEARCHTEX_PACKED_SIZE;

  // Lookup the search texture:
  return SMAA_SEARCHTEX_SELECT(textureLod(searchTex, fma(scale, e, bias), 0));  // LinearSampler
}

/**
 * Horizontal/vertical search functions for the 2nd pass.
 */
float SMAASearchXLeft(sampler2DArray edgeTexture, sampler2D searchTex, vec2 texcoord, float end) {
  /**
   * @PSEUDO_GATHER4
   * This texcoord has been offset by (-0.25, -0.125) in the vertex shader to
   * sample between edge, thus fetching four edges in a row.
   * Sampling with different offsets in each direction allows to disambiguate
   * which edges are active from the four fetched ones.
   */
  vec2 e = vec2(0.0, 1.0);
  for (int i = 0; i < SMAA_MAX_SEARCH_STEPS; i++) {
    if (!(texcoord.x > end && e.g > 0.8281 && e.r == 0.0)) break;
    e = textureLod(edgeTexture, vec3(texcoord, float(gl_ViewIndex)), 0).xy;  // LinearSampler
    texcoord = fma(-vec2(2.0, 0.0), SMAA_RT_METRICS.xy, texcoord);
  }

  float offset = fma(-(255.0 / 127.0), SMAASearchLength(searchTex, e, 0.0), 3.25);
  return fma(SMAA_RT_METRICS.x, offset, texcoord.x);

  // Non-optimized version:
  // We correct the previous (-0.25, -0.125) offset we applied:
  // texcoord.x += 0.25 * SMAA_RT_METRICS.x;

  // The searches are bias by 1, so adjust the coords accordingly:
  // texcoord.x += SMAA_RT_METRICS.x;

  // Disambiguate the length added by the last step:
  // texcoord.x += 2.0 * SMAA_RT_METRICS.x; // Undo last step
  // texcoord.x -= SMAA_RT_METRICS.x * (255.0 / 127.0) * SMAASearchLength(searchTex, e, 0.0);
  // return mad(SMAA_RT_METRICS.x, offset, texcoord.x);
}

float SMAASearchXRight(sampler2DArray edgeTexture, sampler2D searchTex, vec2 texcoord, float end) {
  vec2 e = vec2(0.0, 1.0);
  for (int i = 0; i < SMAA_MAX_SEARCH_STEPS; i++) {
    if (!(texcoord.x < end && e.g > 0.8281 && e.r == 0.0)) break;
    e = textureLod(edgeTexture, vec3(texcoord, float(gl_ViewIndex)), 0).xy;  // LinearSampler
    texcoord = fma(vec2(2.0, 0.0), SMAA_RT_METRICS.xy, texcoord);
  }
  float offset = fma(-(255.0 / 127.0), SMAASearchLength(searchTex, e, 0.5), 3.25);
  return fma(-SMAA_RT_METRICS.x, offset, texcoord.x);
}

float SMAASearchYUp(sampler2DArray edgeTexture, sampler2D searchTex, vec2 texcoord, float end) {
  vec2 e = vec2(1.0, 0.0);
  for (int i = 0; i < SMAA_MAX_SEARCH_STEPS; i++) {
    if (!(texcoord.y > end && e.r > 0.8281 && e.g == 0.0)) break;
    e = textureLod(edgeTexture, vec3(texcoord, float(gl_ViewIndex)), 0).xy;  // LinearSampler
    texcoord = fma(-vec2(0.0, 2.0), SMAA_RT_METRICS.xy, texcoord);
  }
  float offset = fma(-(255.0 / 127.0), SMAASearchLength(searchTex, e.gr, 0.0), 3.25);
  return fma(SMAA_RT_METRICS.y, offset, texcoord.y);
}

float SMAASearchYDown(sampler2DArray edgeTexture, sampler2D searchTex, vec2 texcoord, float end) {
  vec2 e = vec2(1.0, 0.0);
  for (int i = 0; i < SMAA_MAX_SEARCH_STEPS; i++) {
    if (!(texcoord.y < end && e.r > 0.8281 && e.g == 0.0)) break;
    e = textureLod(edgeTexture, vec3(texcoord, float(gl_ViewIndex)), 0).xy;  // LinearSampler
    texcoord = fma(vec2(0.0, 2.0), SMAA_RT_METRICS.xy, texcoord);
  }
  float offset = fma(-(255.0 / 127.0), SMAASearchLength(searchTex, e.gr, 0.5), 3.25);
  return fma(-SMAA_RT_METRICS.y, offset, texcoord.y);
}

/**
 * Ok, we have the distance and both crossing edges. So, what are the areas
 * at each side of current edge?
 */
vec2 SMAAArea(sampler2D areaTex, vec2 dist, float e1, float e2, float offset) {
  // Rounding prevents precision errors of bilinear filtering:
  vec2 texcoord = fma(vec2(SMAA_AREATEX_MAX_DISTANCE, SMAA_AREATEX_MAX_DISTANCE), round(4.0 * vec2(e1, e2)), dist);

  // We do a scale and bias for mapping to texel space:
  texcoord = fma(SMAA_AREATEX_PIXEL_SIZE, texcoord, 0.5 * SMAA_AREATEX_PIXEL_SIZE);

  // Move to proper place, according to the subpixel offset:
  texcoord.y = fma(SMAA_AREATEX_SUBTEX_SIZE, offset, texcoord.y);

  // Do it!
  return SMAA_AREATEX_SELECT(textureLod(areaTex, texcoord, 0));  // LinearSampler
}

// Corner Detection Functions
void SMAADetectHorizontalCornerPattern(sampler2DArray edgeTexture, inout vec2 weights, vec4 texcoord, vec2 d) {
#if !defined(SMAA_DISABLE_CORNER_DETECTION)
  vec2 leftRight = step(d.xy, d.yx);
  vec2 rounding = (1.0 - SMAA_CORNER_ROUNDING_NORM) * leftRight;

  rounding /= leftRight.x + leftRight.y;  // Reduce blending for pixels in the center of a line.

  vec2 factor = vec2(1.0, 1.0);
  factor.x -= rounding.x * SMAASampleLevelZeroOffset(edgeTexture, texcoord.xy, vec2(0, 1)).x;
  factor.x -= rounding.y * SMAASampleLevelZeroOffset(edgeTexture, texcoord.zw, vec2(1, 1)).x;
  factor.y -= rounding.x * SMAASampleLevelZeroOffset(edgeTexture, texcoord.xy, vec2(0, -2)).x;
  factor.y -= rounding.y * SMAASampleLevelZeroOffset(edgeTexture, texcoord.zw, vec2(1, -2)).x;

  weights *= clamp(factor, 0.0, 1.0);
#endif
}

void SMAADetectVerticalCornerPattern(sampler2DArray edgeTexture, inout vec2 weights, vec4 texcoord, vec2 d) {
#if !defined(SMAA_DISABLE_CORNER_DETECTION)
  vec2 leftRight = step(d.xy, d.yx);
  vec2 rounding = (1.0 - SMAA_CORNER_ROUNDING_NORM) * leftRight;

  rounding /= leftRight.x + leftRight.y;

  vec2 factor = vec2(1.0, 1.0);
  factor.x -= rounding.x * SMAASampleLevelZeroOffset(edgeTexture, texcoord.xy, vec2(1, 0)).y;
  factor.x -= rounding.y * SMAASampleLevelZeroOffset(edgeTexture, texcoord.zw, vec2(1, 1)).y;
  factor.y -= rounding.x * SMAASampleLevelZeroOffset(edgeTexture, texcoord.xy, vec2(-2, 0)).y;
  factor.y -= rounding.y * SMAASampleLevelZeroOffset(edgeTexture, texcoord.zw, vec2(-2, 1)).y;

  weights *= clamp(factor, 0.0, 1.0);
#endif
}

void main() {
  vec4 subsampleIndices = pushConstants.subsampleIndices;
  // subsampleIndices = vec4(1.0, 1.0, 1.0, 0.0);
  vec4 weights = vec4(0.0, 0.0, 0.0, 0.0);
  vec2 e = textureLod(uEdgeTexture, vec3(inTexCoord, float(gl_ViewIndex)), 0).xy;

  if (e.g > 0.0) {  // Edge at north

#if !defined(SMAA_DISABLE_DIAG_DETECTION)
    // Diagonals have both north and west edges, so searching for them in
    // one of the boundaries is enough.
    weights.xy = SMAACalculateDiagWeights(uEdgeTexture, uAreaTexture, inTexCoord, e, subsampleIndices);

    // We give priority to diagonals, so if we find a diagonal we skip
    // horizontal/vertical processing.
    if (weights.x == -weights.y) {  // weights.x + weights.y == 0.0
#endif

      vec2 d;

      // Find the distance to the left:
      vec3 coords;
      coords.x = SMAASearchXLeft(uEdgeTexture, uSearchTexture, inOffset0.xy, inOffset2.x);
      coords.y = inOffset1.y;  // vOffset[1].y = vTexCoord0.y - 0.25 * SMAA_RT_METRICS.y (@CROSSING_OFFSET)
      d.x = coords.x;

      // Now fetch the left crossing edges, two at a time using bilinear
      // filtering. Sampling at -0.25 (see @CROSSING_OFFSET) enables to
      // discern what value each edge has:
      float e1 = textureLod(uEdgeTexture, vec3(coords.xy, float(gl_ViewIndex)), 0).x;  // LinearSampler

      // Find the distance to the right:
      coords.z = SMAASearchXRight(uEdgeTexture, uSearchTexture, inOffset0.zw, inOffset2.y);
      d.y = coords.z;

      // We want the distances to be in pixel units (doing this here allow to
      // better interleave arithmetic and memory accesses):
      d = abs(round(fma(SMAA_RT_METRICS.zz, d, -inPixCoord.xx)));

      // SMAAArea below needs a sqrt, as the areas texture is compressed
      // quadratically:
      vec2 sqrt_d = sqrt(d);

      // Fetch the right crossing edges:
      float e2 = SMAASampleLevelZeroOffset(uEdgeTexture, coords.zy, vec2(1, 0)).r;

      // Ok, we know how this pattern looks like, now it is time for getting
      // the actual area:
      weights.xy = SMAAArea(uAreaTexture, sqrt_d, e1, e2, subsampleIndices.y);

      // Fix corners:
      coords.y = inTexCoord.y;
      SMAADetectHorizontalCornerPattern(uEdgeTexture, weights.xy, coords.xyzy, d);

#if !defined(SMAA_DISABLE_DIAG_DETECTION)
    } else
      e.r = 0.0;  // Skip vertical processing.
#endif
  }

  if (e.r > 0.0) {  // Edge at west
    vec2 d;

    // Find the distance to the top:
    vec3 coords;
    coords.y = SMAASearchYUp(uEdgeTexture, uSearchTexture, inOffset1.xy, inOffset2.z);
    coords.x = inOffset0.x;  // vOffset[1].x = vTexCoord0.x - 0.25 * SMAA_RT_METRICS.x;
    d.x = coords.y;

    // Fetch the top crossing edges:
    float e1 = textureLod(uEdgeTexture, vec3(coords.xy, float(gl_ViewIndex)), 0).y;  // LinearSampler

    // Find the distance to the bottom:
    coords.z = SMAASearchYDown(uEdgeTexture, uSearchTexture, inOffset1.zw, inOffset2.w);
    d.y = coords.z;

    // We want the distances to be in pixel units:
    d = abs(round(fma(SMAA_RT_METRICS.ww, d, -inPixCoord.yy)));

    // SMAAArea below needs a sqrt, as the areas texture is compressed
    // quadratically:
    vec2 sqrt_d = sqrt(d);

    // Fetch the bottom crossing edges:
    float e2 = SMAASampleLevelZeroOffset(uEdgeTexture, coords.xz, vec2(0, 1)).y;

    // Get the area for this direction:
    weights.ba = SMAAArea(uAreaTexture, sqrt_d, e1, e2, subsampleIndices.x);

    // Fix corners:
    coords.x = inTexCoord.x;
    SMAADetectVerticalCornerPattern(uEdgeTexture, weights.zw, coords.xyxz, d);
  }
  outFragOutput = weights;
}
