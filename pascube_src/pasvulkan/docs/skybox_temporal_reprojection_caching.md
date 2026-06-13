# Skybox Temporal Reprojection Caching

## Overview

The skybox temporal reprojection caching system is an optimization for expensive procedural sky rendering (primarily the `getStarlight()` function for starfield rendering). Instead of computing the full starlight calculation for every pixel every frame, we cache the results and reuse them across frames via reprojection.

## How It Works

### Core Concept

1. **Render to history buffer**: Each frame, the skybox shader writes its computed sky color to a per-frame history image (`fHistoryImages[aInFlightFrameIndex]`).

2. **Reproject from previous frame**: Before computing new values, the shader attempts to reproject the current pixel's world direction into the previous frame's clip space to sample the cached result.

3. **Selective recomputation**: Only pixels that fail reprojection (moved off-screen, hidden, or stochastically selected for refresh) are fully recomputed.

### Shader Flow (Fragment Shader)

```
1. Get current world direction from vertex shader
2. Compute previous frame's clip-space position (passed from vertex shader)
3. Convert to UV coordinates in previous frame's history buffer
4. Check if UV is valid (within [0,1] range)
5. If valid:
   - Sample previous frame's cached color
   - Check if pixel was written (alpha != 0 for RGBA16F, or non-zero for RGB9E5)
   - If valid cached value exists, use it (with optional stochastic refresh)
6. If invalid or needs refresh:
   - Compute fresh starlight value
   - Store to current frame's history buffer
```

### Vertex Shader Changes

The cached variant of the vertex shader (`skybox_cached_vert.spv`) computes and outputs an additional varying:

- `outPreviousClipSpacePosition`: The vertex position transformed using the **previous frame's view/projection matrix** and **previous frame's skybox orientation quaternion**

This allows the fragment shader to know where each pixel "was" in the previous frame.

## Push Constants

The system uses additional push constant fields for the cached mode:

| Field | Type | Purpose |
|-------|------|---------|
| `currentOrientation` | vec4 | Current frame's skybox orientation (quaternion) |
| `previousOrientation` | vec4 | Previous frame's skybox orientation (quaternion) |
| `countAllViews` | uint | Total view count, used to index previous frame's views |
| `frameIndex` | uint | Frame counter for stochastic refresh patterns |

## History Buffer Format

Two formats are supported, selected automatically based on GPU capabilities:

1. **RGB9E5** (preferred): 
   - Uses `VK_FORMAT_E5B9G9R9_UFLOAT_PACK32` with `R32_UINT` alias for imageStore
   - More memory efficient (4 bytes/pixel)
   - Zero value used as "unwritten pixel" sentinel
   - Requires GPU support for RGB9E5 storage images

2. **RGBA16F** (fallback):
   - Uses `VK_FORMAT_R16G16B16A16_SFLOAT`
   - Alpha channel = 0.0 indicates unwritten pixel
   - Alpha channel = 1.0 indicates valid cached value
   - 8 bytes/pixel

## Image Layout Tracking

The system maintains explicit layout tracking via `fHistoryImageLayouts[]` array to handle the complex transitions:

### Per-Frame Transitions (in ForwardComputePass)

```
Frame N:
  1. Current image [N]: Any → TRANSFER_DST → clear → GENERAL (for shader write)
  2. Previous image [N-1]: Any → SHADER_READ_ONLY (for shader read)
```

The system tracks layouts to set correct `srcAccessMask` and `oldLayout` for each transition:

| Previous Layout | srcAccessMask |
|-----------------|---------------|
| `SHADER_READ_ONLY_OPTIMAL` | `VK_ACCESS_SHADER_READ_BIT` |
| `GENERAL` | `VK_ACCESS_SHADER_READ_BIT \| VK_ACCESS_SHADER_WRITE_BIT` |
| `UNDEFINED` | 0 |

## When Cache Is Invalidated

The cache is **partially invalidated** (stochastic refresh) continuously, but **fully invalidated** in these cases:

1. **Resolution change**: When `fWidth`, `fHeight`, or `fCountSurfaceViews` change, all history images are recreated.

2. **First frame**: No previous history exists, all pixels must be computed fresh.

3. **Large orientation change**: If `PreviousOrientation.DistanceTo(CurrentOrientation) > 0.1`, the previous orientation is snapped to current (forcing fresh computation for all pixels, as reprojection would fail anyway).

## Reprojection Validation

Before using a cached value, the shader performs several validation checks:

### 1. Screen Bounds Check

```glsl
vec2 margin = 1.0 / vec2(screenSize);
bool isValid = all(greaterThanEqual(previousUV, margin)) && 
               all(lessThanEqual(previousUV, vec2(1.0) - margin));
```

- Checks if the reprojected UV is within the screen (with 1-pixel margin to avoid edge artifacts)
- Pixels that were off-screen in the previous frame are recomputed

### 2. Behind Camera Check

```glsl
isValid = isValid && (previousClip.w > 0.0);
```

- For skybox direction vectors, `clip.w` corresponds to the view-space Z direction
- Positive `w` means the direction was forward-facing in the previous frame
- Rejects directions that were behind the camera

### 3. Motion Vector Rejection

```glsl
vec2 motionVector = abs(previousUV - currentUV);
bool tooMuchMotion = any(greaterThan(motionVector, vec2(0.15)));
isValid = isValid && !tooMuchMotion;
```

- Rejects reprojection if the pixel moved more than **15% of screen size**
- Prevents feedback loop artifacts during rapid camera rotation
- Large motion indicates the reprojection is unreliable (interpolation errors accumulate)

### Why 15%?

The 15% threshold balances two concerns:
- **Too low**: Rejects valid reprojections during normal camera movement, wasting computation
- **Too high**: Allows unreliable reprojections that may cause visible artifacts or ghosting

At 60 FPS with smooth camera rotation, 15% per frame corresponds to roughly 9 full rotations per second before rejection kicks in.

## Stochastic Refresh

To prevent the cache from becoming stale and to avoid floating-point precision drift over time, pixels are stochastically selected for forced recomputation:

```glsl
uvec2 pixelCoord = uvec2(currentUV * vec2(screenSize));
uint refreshPattern = (pixelCoord.x ^ pixelCoord.y ^ pushConstants.frameIndex) & 0x3fu;
bool forceRefresh = (refreshPattern == 0u);
```

### How It Works

1. **XOR pattern**: Combines pixel X, pixel Y, and frame index with XOR
2. **Mask with 0x3F (63)**: Limits the pattern to 6 bits (values 0-63)
3. **Force refresh when zero**: Triggers recomputation when pattern equals 0

### Result

- Each pixel is forced to recompute approximately **every 64 frames**
- The XOR pattern ensures neighboring pixels refresh at different frames (no visible "block" artifacts)
- Over 64 frames, every pixel will have been refreshed at least once
- At any given frame, roughly **1/64th (1.56%)** of pixels are forcibly recomputed

### Why This Matters

Even with perfect reprojection, repeatedly sampling and rewriting cached values can accumulate floating-point errors. The stochastic refresh ensures:

- No pixel relies on indefinitely old cached data
- Animated/time-varying effects eventually update everywhere
- Numerical stability is maintained over long sessions

## Hidden Pixel Detection

When a pixel is reprojected but the sampled history value is invalid (the pixel wasn't visible in the previous frame), it must be detected and recomputed.

### Sentinel Values

The history buffer is cleared to zero before each frame. The shader detects unwritten pixels by checking for sentinel values:

**RGBA16F format:**
```glsl
if(historySample.a < 0.5){
  // Pixel was not rendered in previous frame, recompute
}
```
- Alpha = 0.0 means unwritten (cleared state)
- Alpha = 1.0 means valid cached value

**RGB9E5 format:**
```glsl
if(all(equal(historySample.rgb, vec3(0.0)))){
  // Pixel was not rendered in previous frame, recompute  
}
```
- Pure black (0,0,0) is the sentinel
- This works because pure black is physically impossible for a starfield sky

### Debug Mode

When `SKYBOX_CACHED_REPROJECTION_DEBUG` is defined, cached pixels have their red/green channels zeroed to visualize cache usage (cached pixels appear blue/dark, freshly computed pixels appear normal).

## When Caching Is Effectively Used

**Important**: The temporal reprojection caching is only **effectively active** in **realtime starlight mode** (`pushConstants.mode == 1`).

```glsl
switch(pushConstants.mode){
  case 1u:{
    // Realtime starlight - CACHING IS EFFECTIVE HERE
    // Uses reprojectStarlight() to reuse previous frame's expensive computation
    ...
  }
  default:{
    // Cube map mode - CACHING FULLY INACTIVE
    // Simply reads from cubemap texture (already fast)
    // No reprojection, no history read/write
    ...
  }
}
```

### Why?

- **Starlight mode**: The `getStarlight()` function is computationally expensive (procedural star generation, atmospheric scattering, etc.). Caching provides significant speedup.
- **Cubemap mode**: Reading from a cubemap texture is already very fast. The reprojection overhead would exceed any savings, so caching is completely bypassed.

## Descriptor Set Bindings (Cached Mode)

| Binding | Type | Content |
|---------|------|---------|
| 0 | Uniform Buffer | View matrices (current + previous frames) |
| 1 | Combined Image Sampler | Sky cubemap texture |
| 2 | Combined Image Sampler | Previous frame's history (for reading) |
| 3 | Storage Image | Current frame's history (for writing) |

## Performance Considerations

- **GPU Memory**: 2 history buffers (one per in-flight frame) at screen resolution
- **Bandwidth**: Reading previous + writing current history per pixel
- **ALU**: Significant reduction when cache hits (skips expensive starlight computation)
- **Best case**: Static camera = nearly 100% cache hits
- **Worst case**: Rapid rotation = mostly cache misses (but still writes to history for next frame)

## Files Involved

### Pascal Source
- `PasVulkan.Scene3D.Renderer.SkyBox.pas` - Main Pascal implementation

### Shader Sources
- `skybox.vert` - Vertex shader source (handles both modes via preprocessor)
- `skybox.frag` - Fragment shader source (handles both modes via preprocessor)
- `skybox.glsl` - Shared definitions and push constants

### Compiled Shader Variants (Vertex)
- `skybox_vert.spv` - Standard vertex shader (no reprojection)
- `skybox_cached_vert.spv` - Cached variant with previous clip-space position output

### Compiled Shader Variants (Fragment)
- `skybox_frag.spv` - Standard fragment shader (no caching)
- `skybox_cached_rgba16f_frag.spv` - Cached variant using RGBA16F history buffer
- `skybox_cached_rgb9e5_frag.spv` - Cached variant using RGB9E5 history buffer

## Enabling/Disabling

The caching is controlled by the `SkyBoxCaching` property on `TpvScene3D`:

```pascal
Scene3D.SkyBoxCaching := true;  // Enable caching
Scene3D.SkyBoxCaching := false; // Disable caching (default)
```

This property is read by `TpvScene3DRendererPassesForwardRenderPass` when creating the skybox renderer and passed to `TpvScene3DRendererSkyBox.Create()` as the `aCached` parameter.

**Note**: The skybox in `PasVulkan.Scene3D.Renderer.Passes.ReflectionProbeRenderPass.pas` always uses non-cached mode for simplicity, as reflection probes are rendered infrequently and at lower resolution.
