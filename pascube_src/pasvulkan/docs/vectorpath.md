
# PasVulkan Vector Path Rendering

## Overview

This document provides technical documentation for PasVulkan's vector path rendering capabilities, covering both the existing SDF-based approach and the work-in-progress Pathfinder-like on-GPU vector shape rendering feature.

PasVulkan provides multiple rendering algorithms for vector graphics:

1. **SDF-Based Rendering** (Current, Production) - Using `TpvSignedDistanceField2D` for font rendering and pre-rasterized vector shapes
2. **CPU-Tessellated Direct Rendering** (Current, Production) - CPU tessellates vector paths into triangles with SDF-based edge anti-aliasing in fragment shader, optimized for opaque shapes where overdraw is minimal
3. **Coverage-Mask-then-Cover Approach** (Current, Production) - Two-pass transparent shape rendering (four passes including barriers) using a coverage buffer to handle overlapping transparent shapes correctly
4. **Direct Spatial Grid GPU Vector Rendering** (WIP) - Direct GPU-based vector path rasterization using `TpvVectorPathGPUShape`

These algorithms are **complementary** rendering modes, allowing users to choose the best approach for their specific use case.

---

## 1. Architecture Overview

### 1.1 Core Types and Structures

#### Host-Side (Pascal)

**Basic Vector Types:**
- `TpvVectorPathVector` - 2D vector with double precision (x, y) - with automatic implicit and explicit conversion to/from `TpvVector2` (single precision) and `TpvVector2D` (double precision)
- `TpvVectorPathVectors` - Dynamic array of vectors
- `TpvVectorPathBoundingBox` - AABB with MinMax[0..1] structure

**Segment Types:**
- `TpvVectorPathSegment` (abstract base class)
- `TpvVectorPathSegmentLine` - Linear segments
- `TpvVectorPathSegmentQuadraticCurve` - Quadratic Bézier curves
- `TpvVectorPathSegmentCubicCurve` - Cubic Bézier curves (converted to quadratic for GPU rendering to keep complexity manageable)
- `TpvVectorPathSegmentMetaWindingSettingLine` - Special winding control segments

**Shape Representation:**
- `TpvVectorPathContour` - Collection of connected segments (open or closed)
- `TpvVectorPathShape` - Collection of contours with fill rule (`EvenOdd` or `NonZero`)
- `TpvVectorPath` - Command-based path builder (SVG-like interface with all SVG path commands)

**GPU Shape Acceleration:**
- `TpvVectorPathGPUShape` - Main GPU-accelerated shape container
- `TpvVectorPathGPUShape.TGridCell` - Spatial subdivision cell

#### GPU-Side (GLSL)

**GPU Data Structures** (defined in both Pascal and GLSL):

```glsl
// Segment data: 32 bytes per segment
struct VectorPathGPUSegment {
  uvec4 typeWindingPoint0;  // [Type, Winding, Point0.x, Point0.y] as uints
  vec4 point1Point2;         // [Point1.x, Point1.y, Point2.x, Point2.y]
};

// Indirect segment: 4 bytes
#define VectorPathGPUIndirectSegment uint  // Index into segment buffer

// Grid cell: 8 bytes
#define VectorPathGPUGridCell uvec2  // [startIndex, count]

// Shape metadata: 32 bytes
struct VectorPathGPUShape {
  vec4 minMax;                        // [min.x, min.y, max.x, max.y]
  uvec4 flagsStartGridCellIndexGridSize;  // [flags, startGridCell, gridSizeX, gridSizeY]
};
```

**Segment Type Constants:**
- `TypeUnknown = 0` - Invalid/uninitialized
- `TypeLine = 1` - Line segment
- `TypeQuadraticCurve = 2` - Quadratic Bézier curve
- `TypeMetaWindingSettingLine = 3` - Winding initialization segment

**Flags:**
- Bit 0: Fill rule (1 = Even-Odd, 0 = Non-Zero)

---

## 2. Rendering Approaches

### 2.1 SDF-Based Rendering (Production)

**Used by:** Font rendering (`TpvFont`, and `TpvFont` is used by `TpvTrueTypeFont` as well for vector glyph rendering of TrueType and OpenType fonts), pre-processed shapes

**Location:** `PasVulkan.SignedDistanceField2D.pas`, `PasVulkan.Font.pas`

**Approach:**
- Pre-compute signed distance field textures from vector shapes
- Supports SDF, SSAASDF (4x multisampled 4-rook/RGSS SDF with 4 samples per pixel per RGBA channel), MSDF (Multi-channel SDF), and MTSDF variants
- GPU fragment shader samples pre-computed texture
- Uses `linearstep()` for smooth anti-aliasing, not smoothstep, needed for correct SDF evaluation on a linear color space (not gamma-corrected one!)

**Advantages:**
- Very fast at runtime (single texture lookup)
- High quality anti-aliasing
- Efficient for repeated rendering (glyphs)

**Disadvantages:**
- Requires pre-processing step
- Memory overhead for texture storage
- Limited resolution scalability

### 2.2 CPU-Tessellated Direct Rendering (Production)

**Used by:** Default Canvas path rendering (when Coverage mode is disabled, fTransparentShapes=false) in `TpvCanvas`

**Location:** `PasVulkan.Canvas.pas` (`TpvCanvasShape`, `TpvCanvasPath`)

**Approach:**
- CPU tessellates arbitrary vector paths into triangles (`TpvCanvasShape.FillFromPath` / `StrokeFromPath`)
- CPU-side triangulation supports full fill rules (Non-Zero, Even-Odd)
- Curves are adaptively flattened to line segments based on tessellation tolerance
- Resulting triangles encode signed distance field evaluation in vertex metadata
- Fragment shader evaluates analytical SDFs for smooth anti-aliasing at triangle edges
- Single-pass rendering with standard alpha blending
- Automatic batching of geometry into indexed triangle lists

**Path Processing Flow:**
```
TpvCanvasPath (MoveTo, LineTo, Curves, etc.)
       ↓
TpvCanvasShape.FillFromPath() / StrokeFromPath()
       ↓
CPU tessellation:
  ├─ Flatten curves to line segments (adaptive tolerance)
  ├─ Build segment list with BVH for intersection tests
  ├─ Triangulate using scanline algorithm
  ├─ Encode SDF parameters in vertex MetaInfo
  └─ Generate indexed triangle mesh
       ↓
DrawShape() → GPU rendering with SDF anti-aliasing
```

**Fragment Shader Distance Functions:**
- `pcvvaomLineEdge` (0x01) - Line segments with thickness (stroking)
- `pcvvaomRoundLineCapCircle` (0x02) - Rounded line caps
- `pcvvaomRoundLine` (0x03) - Rounded lines (polygon edges)
- `pcvvaomCircle` (0x04) - Circles (filled primitives)
- `pcvvaomEllipse` (0x05) - Ellipses
- `pcvvaomRectangle` (0x06) - Axis-aligned rectangles
- `pcvvaomRoundedRectangle` (0x07) - Rounded rectangles
- `pcvvaomCircleArcRingSegment` (0x08) - Arc ring segments

**GUI Element Mode:**

Canvas supports a specialized GUI element rendering mode via `DrawGUIElement()` with shader define `GUI_ELEMENTS`:

- Theme-aware procedural UI elements (windows, buttons, panels, etc.)
- Focused/unfocused state visualization
- Complex SDF combinations (rounded rectangles, drop shadows, gradients)
- Configurable via uniform buffer colors and parameters
- Supports both opaque and transparent rendering

**GUI Element Types:**
- `GUI_ELEMENT_WINDOW_HEADER` - Window title bars with gradients
- `GUI_ELEMENT_WINDOW_FILL` - Window body backgrounds
- `GUI_ELEMENT_WINDOW_DROPSHADOW` - Drop shadow effects
- `GUI_ELEMENT_BUTTON_*` - Buttons (unfocused, focused, pushed, disabled states)
- `GUI_ELEMENT_PANEL_*` - Various panel types
- `GUI_ELEMENT_CHECKBOX_*` - Checkboxes and radio buttons
- `GUI_ELEMENT_SCROLLBAR_*` - Scrollbar components
- `GUI_ELEMENT_TAB_BUTTON_*` - Chrome-style tab buttons
- `GUI_ELEMENT_SLIDER_*` - Slider tracks and knobs
- `GUI_ELEMENT_PROGRESSBAR_*` - Progress bar components
- And many more specialized UI elements

**GUI SDF Helper Functions:**
- `sdRoundedRect()` - Rounded rectangle distance
- `sdTabButton()` - Chrome-style angled tab shape
- `sdTriangle()` - Triangle distance with barycentric coords
- Color space conversions (RGB↔HSV) for dynamic theming

**Shape Caching for Performance:**

To avoid CPU tessellation/triangulation overhead on repeated rendering, shapes can be pre-tessellated and cached:

```pascal
// Cache the tessellated shape once
var CachedFillShape:TpvCanvasShape;
begin
 CachedFillShape:=Canvas.GetFillShape;  // Tessellate once
 try
  // Render multiple times without re-tessellation
  Canvas.DrawShape(CachedFillShape);
  // ... change transforms, colors, etc.
  Canvas.DrawShape(CachedFillShape);
 finally
  CachedFillShape.Free;
 end;
end;
```

**Shape Caching Methods:**
- `GetFillShape()` - Returns cached tessellation of current path as filled shape
- `GetStrokeShape()` - Returns cached tessellation of current path as stroked shape
- `DrawShape(aShape)` - Renders a pre-tessellated shape directly

**Benefits:**
- Amortize tessellation cost across multiple frames
- Render same shape with different transforms/colors efficiently
- Useful for animated or repeatedly drawn elements
- No re-tessellation when only visual properties change

**Advantages:**
- Supports arbitrary vector paths (full SVG-like path API)
- CPU tessellation handles complex fill rules correctly
- Automatic batching reduces draw calls
- SDF-based anti-aliasing provides smooth edges
- No buffer uploads beyond standard vertex/index data
- Works with standard blending
- Shape caching eliminates re-tessellation overhead for repeated rendering
- Efficient rendering of same shape with different transforms/colors via cached shapes

**Disadvantages:**
- Overdraw artifacts with transparent overlapping shapes (alpha blending issues)
- CPU tessellation cost for complex paths
- Manual Z-ordering required for proper transparency
- Tessellation granularity affects quality vs performance
- Higher vertex count for curved paths

**Best Use Cases:**
- Opaque vector graphics (UI elements, diagrams)
- Simple to moderately complex paths without heavy overlap
- Scenarios where CPU tessellation cost is acceptable
- Applications needing full path API support

**When to Avoid:**
- Complex transparent overlapping shapes → Use Coverage-Mask-then-Cover
- Very large, complex paths requiring spatial optimization → Use Direct Spatial Grid GPU Vector Rendering
- Scenes with many small, repeated shapes → Use SDF pre-baking

### 2.3 Coverage-Mask-then-Cover (Production)

**Used by:** Transparent shape rendering in Canvas

**Location:** `canvas.frag` with `COVERAGE_MASK_PASS` and `COVERAGE_COVER_PASS` defines

**Shader Defines:**
- `COVERAGE_MASK_PASS` - First pass: write coverage
- `COVERAGE_COVER_PASS` - Second pass: resolve and composite

**GPU Resources:**
- Coverage buffer: `R32_UINT` format image (set 1, binding 0)
- Format: `[24-bit stamp | 8-bit coverage]`

**Note on Terminology:** In this context, "pass" refers to a logical stage of the algorithm. The barrier stages are synchronization points between render passes, not rendering passes themselves. Two-pass rendering (Mask + Cover) with two synchronization barriers (one after mask, one after cover), so four logical stages total, hence "Four-Pass Algorithm".

**Four-Pass Algorithm:**

**Pass 1 - Mask (Coverage Writing):**
```glsl
uint shapeStamp = pushConstants.data[7].y;
uint coverage8 = uint((clamp(color.a, 0.0, 1.0) * 255.0) + 0.5);
uint packed = (shapeStamp << 8) | coverage8;
imageAtomicMax(uCoverageBuffer, pixelPosition, packed);
```

where the highest 24 bits are the shape stamp (unique per shape group) and the lowest 8 bits are the coverage value (0-255), and where the highest value wins (atomic max) for the current pixel.

**Pass 2 - MaskBarrier:**

- Memory barrier to ensure mask pass writes are visible to cover pass reads

**Pass 3 - Cover (Compositing):**
```glsl
uint packed = imageLoad(uCoverageBuffer, pixelPosition).r;
uint storedStamp = packed >> 8;
uint storedCoverage8 = packed & 0xFFu;
if ((storedStamp == shapeStamp) && (storedCoverage8 > 0u)) {
  float coverage = float(storedCoverage8) / 255.0;
  outFragColor = vec4(color.xyz * coverage, coverage);
}
```

with a quad covering the transparent shape's bounding box (not the entire viewport!), reading the coverage buffer and compositing the color based on coverage. **Note:** No per-pixel clearing is performed—the coverage buffer retains previous shape data until stamp exhaustion forces a full clear. 

**Pass 4 - CoverBarrier:**

- Memory barrier after cover pass to avoid race conditions on overlapped shapes
- Ensures all cover pass writes to framebuffer are visible before next shape's operations

**Algorithm Repeatability and Stamp Management:**

- **Shape Stamping:** Each transparent shape group receives a unique 24-bit stamp ID, enabling correct order-independent rendering of overlapping transparent shapes, group order still defines compositing order
- **Four-Pass Cycle:** The algorithm repeats (Mask → MaskBarrier → Cover → CoverBarrier) for each shape group with incrementing stamp IDs until the 24-bit stamp space (16,777,216 unique IDs) is exhausted, at which point the coverage buffer is cleared and stamps wrap back to zero
- **Deferred Buffer Clearing:** Coverage buffer is not cleared between shape groups to maximize performance; clearing only occurs on stamp exhaustion
- **Renderpass Restart Requirement:** Due to Vulkan renderpass barrier limitations, each Mask → MaskBarrier → Cover → CoverBarrier cycle requires renderpass restarts, which is architecturally necessary but impacts performance on TBDR mobile GPUs
  - **Subpass Limitation:** Vulkan subpasses with internal dependencies cannot be used here due to the repeatable nature of the algorithm—subpasses are designed for linear sequencing (subpass 0 → 1 → 2 → 3), but this algorithm requires a cyclical pattern (Mask → MaskBarrier → Cover → CoverBarrier → Mask → MaskBarrier → Cover → CoverBarrier...) that necessitates full renderpass restarts
  - **TBDR Impact:** Tile-Based Deferred Rendering architectures suffer performance degradation from renderpass interruptions because they must flush on-chip tile memory to main memory when the renderpass is suspended, then reload it on restart—this defeats the core TBDR optimization of keeping tile data on-chip throughout the renderpass

**Advantages:**
- Order-independent transparency, group order still defines compositing order
- Handles overlapping transparent shapes correctly
- Analytical SDF anti-aliasing (high quality)
- No geometry sorting required
- Memory efficient compared to alternatives: R32_UINT per pixel (4 bytes) vs MSAA (16-32 bytes/pixel), A-Buffer (variable/large), or Depth Peeling (multiple full buffers)

**Disadvantages:**
- Four passes per transparent shape group with two rendering passes and two barrier passes per shape
- Coverage buffer memory overhead (requires additional R32_UINT image)
- Atomic operations may have performance cost
- Requires renderpass suspend/resume (restart) due to barrier limitations inside renderpasses
   - Mask => MaskBarrier => Cover => CoverBarrier requires renderpass restarts for each transparent shape group
   - Subpasses with internal dependencies cannot be used due to the repeatable nature of the algorithm here
- Problematic for TBDR (Tile-Based Deferred Rendering) mobile GPUs due to renderpass interruptions

### 2.4 Direct Spatial Grid GPU Vector Rendering (WIP)

**Used by:** Direct vector path rendering (planned)

**Location:** `PasVulkan.VectorPath.pas`, `canvas.frag` with `FILLTYPE_VECTOR_PATH`

**Shader Mode:** `FILLTYPE == FILLTYPE_VECTOR_PATH`

**GPU Resources:**
- Segment buffer (set 2, binding 0) - `VectorPathGPUSegments[]`
- Indirect segment buffer (set 2, binding 1) - `VectorPathGPUIndirectSegments[]`
- Grid cell buffer (set 2, binding 2) - `VectorPathGPUGridCells[]`
- Shape buffer (set 2, binding 3) - `VectorPathGPUShapes[]`

**Algorithm Overview:**

The approach uses spatial subdivision and per-pixel ray-casting:

1. **Preprocessing (CPU):**
   - Subdivide shape bounding box into N×N grid cells
   - For each grid cell, collect intersecting segments
   - Build indirect segment lists per cell
   - Insert winding meta-lines for scanline initialization

2. **Runtime (GPU Fragment Shader):**
   - Determine which grid cell the pixel falls into
   - Iterate segments in that cell
   - Compute distance to each segment
   - Update winding number using horizontal ray test
   - Apply fill rule (Even-Odd or Non-Zero)
   - Output smooth anti-aliased coverage

**Key CPU-Side Classes:**

```pascal
TpvVectorPathGPUShape=class
 const CoordinateExtents=1.41421356237; // sqrt(2.0) - grid cell padding
 type TGridCell=class
       private
        fBoundingBox:TpvVectorPathBoundingBox;
        fExtendedBoundingBox:TpvVectorPathBoundingBox; // Padded by CoordinateExtents
        fSegments:TpvVectorPathSegments; // Segments intersecting this cell
      end;
 private
  fVectorPathShape:TpvVectorPathShape;
  fResolution:TpvInt32; // Grid resolution (N×N)
  fSegments:TpvVectorPathSegments; // All segments
  fSegmentDynamicAABBTree:TpvVectorPathBVHDynamicAABBTree; // Spatial acceleration
  fGridCells:TGridCells; // Grid subdivision
end;
```

**Key GPU-Side Function:**

```glsl
float sampleVectorPathShape(const vec3 shapeCoord) {
  // shapeCoord.xy = position, shapeCoord.z = shape index
  
  float signedDistance = 1e+32;
  VectorPathGPUShape shape = vectorPathGPUShapes[int(shapeCoord.z + 0.5)];
  
  // Determine grid cell
  uvec2 gridCellIndices = uvec2(floor(
    ((shapeCoord.xy - shape.minMax.xy) * vec2(shape.flagsStartGridCellIndexGridSize.zw)) 
    / shape.minMax.zw
  ));
  
  if (all(greaterThanEqual(gridCellIndices, uvec2(0))) && 
      all(lessThan(gridCellIndices, shape.flagsStartGridCellIndexGridSize.zw))) {
    
    VectorPathGPUGridCell cell = vectorPathGPUGridCells[
      shape.flagsStartGridCellIndexGridSize.y + 
      (gridCellIndices.y * shape.flagsStartGridCellIndexGridSize.z) + 
      gridCellIndices.x
    ];
    
    int winding = 0;
    
    // Iterate segments in cell
    for (uint i = cell.x; i < cell.x + cell.y; i++) {
      VectorPathGPUSegment seg = vectorPathGPUSegments[vectorPathGPUIndirectSegments[i]];
      
      switch (seg.typeWindingPoint0.x) {
        case 1u:{ // Line
          signedDistance = min(signedDistance, 
            getLineDistanceAndUpdateWinding(shapeCoord.xy, 
              uintBitsToFloat(seg.typeWindingPoint0.zw), 
              seg.point1Point2.xy, winding));
          break;
        }
          
        case 2u:{  // Quadratic curve
          signedDistance = min(signedDistance, 
            getQuadraticCurveDistanceAndUpdateWinding(shapeCoord.xy, 
              uintBitsToFloat(seg.typeWindingPoint0.zw), 
              seg.point1Point2.xy, seg.point1Point2.zw, winding));
          break;
        }
          
        case 3u:{  // Meta winding line
          vec2 p0 = uintBitsToFloat(seg.typeWindingPoint0.zw);
          vec2 p1 = seg.point1Point2.xy;
          if ((shapeCoord.y >= min(p0.y, p1.y)) && 
              (shapeCoord.y < max(p0.y, p1.y))) {
            winding += int(seg.typeWindingPoint0.y);
          }
          break;
        }

      }
    }
    
    // Apply fill rule
    bool inside = ((shape.flagsStartGridCellIndexGridSize.x & 1) != 0) 
                  ? ((winding & 1) != 0)  // Even-Odd
                  : (winding != 0);       // Non-Zero
    signedDistance *= inside ? -1.0 : 1.0;
  }
  
  float d = fwidth(signedDistance);
  return linearstep(-d, d, signedDistance);
}
```

**Meta Winding Lines:**

Meta winding lines are virtual segments inserted between Y-coordinate bands within each grid cell to initialize the winding number for scanline-based evaluation. They solve a fundamental challenge: when a fragment shader evaluates a pixel, it needs to know the correct winding number, but the pixel's horizontal ray may not intersect any actual path segments (e.g., when the pixel is deep inside a closed shape).

**Why Meta Winding Lines?**

Without proper initialization, pixels in grid cells that don't contain segment intersections would have incorrect winding values. Alternative approaches have significant drawbacks:

- **Prefix sums:** Precompute winding for every cell, but this is complex to implement and requires global dependencies, making random access inefficient on GPUs
- **Per-pixel full traversal:** Trace from negative infinity to every pixel, but this is prohibitively expensive for complex shapes with many segments
- **Stencil-based methods:** Require additional passes and stencil buffer manipulation

**How Meta Winding Lines Work:**

1. During preprocessing, identify Y-coordinate bands where path segments intersect grid cell boundaries
2. Insert meta winding lines at these boundaries, encoding the cumulative winding contribution from segments below
3. At runtime, the fragment shader reads the meta winding line for the pixel's Y-coordinate to get the base winding value
4. Then incrementally update winding as it processes actual segments in the cell

This approach provides **efficient random access** (any pixel can query its grid cell independently) while maintaining **correct winding semantics** with minimal computational overhead.

**Winding Number Calculation:**

The winding number is computed using a horizontal ray cast from negative infinity to the pixel position:

- **Line segments:** Check if horizontal ray intersects, update winding based on edge orientation
- **Quadratic curves:** Solve quadratic equation for y-intersection, check x-coordinates
- **Meta winding lines:** Initialize winding for scanline based on previous row's state

**Fill Rules:**
- **Even-Odd:** Inside if `(winding & 1) != 0`
- **Non-Zero:** Inside if `winding != 0`

**Advantages:**
- No pre-processing or texture atlas required
- Dynamic, arbitrary resolution rendering
- Memory efficient for large/complex shapes
- Direct control over quality vs performance

**Disadvantages (Current WIP Status):**
- Higher per-pixel computational cost
- Requires buffer storage for segments/grid
- More complex shader code

---

## 3. Data Flow and Integration

### 3.1 Path Creation

```
User API (TpvVectorPath)
  ├─ MoveTo / LineTo / QuadraticCurveTo / CubicCurveTo
  ├─ Arc / Circle / Rectangle / RoundedRectangle
  └─ Close
       ↓
TpvVectorPath.GetShape
       ↓
TpvVectorPathShape
  ├─ Contours: TpvVectorPathContours
  ├─ FillRule: EvenOdd / NonZero
  └─ ConvertCubicCurvesToQuadraticCurves (optional)
```

### 3.2 GPU Shape Generation

```
TpvVectorPathShape
       ↓
TpvVectorPathGPUShape.Create(shape, resolution, boundingBoxExtent)
       ↓
  ├─ Build segment list from contours
  ├─ Create BVH acceleration structure (TpvVectorPathBVHDynamicAABBTree)
  ├─ Subdivide into N×N grid cells
  ├─ For each grid cell:
  │    ├─ Compute extended bounding box (padding = CoordinateExtents)
  │    ├─ Query intersecting segments via BVH
  │    ├─ Compute segment intersection points
  │    ├─ Sort Y-coordinates
  │    └─ Insert meta winding lines between Y-bands
  └─ Generate GPU buffers:
       ├─ TpvVectorPathGPUSegmentData[]
       ├─ TpvVectorPathGPUIndirectSegmentData[]
       ├─ TpvVectorPathGPUGridCellData[]
       └─ TpvVectorPathGPUShapeData
```

### 3.3 Rendering Pipeline

```
TpvCanvas.DrawVectorPath (or similar)
       ↓
Upload GPU buffers (if not cached)
       ↓
Bind descriptor sets:
  ├─ Set 0: Textures & mask
  ├─ Set 1: Coverage buffer (if coverage mode)
  └─ Set 2: Vector path GPU buffers
       ↓
Draw call with push constants:
  ├─ Transform matrices
  ├─ Color
  ├─ Shape stamp (for coverage mode)
  └─ Flags (fill rule, premultiplied alpha, etc.)
       ↓
Fragment Shader:
  ├─ Determine shape coordinates (inTexCoord.z = shape index)
  ├─ Call sampleVectorPathShape(shapeCoord)
  ├─ Apply color and blending
  └─ Output final color
```

---

## 4. Current Implementation Status

### 4.1 Completed (✓)

- [x] Core vector path types and API (`TpvVectorPath`, `TpvVectorPathShape`)
- [x] Segment types (Line, Quadratic, Cubic, Meta winding)
- [x] Bounding box and intersection calculations
- [x] Grid cell subdivision algorithm
- [x] GPU data structure definitions (Pascal and GLSL)
- [x] BVH spatial acceleration structure
- [x] Meta winding line insertion logic
- [x] Fragment shader implementation (distance + winding calculation)
- [x] Quadratic curve distance calculation (analytical solution)
- [x] Line segment distance calculation
- [x] Fill rule support (Even-Odd and Non-Zero)
- [x] Anti-aliasing via `fwidth()` and `linearstep()`
- [x] SDF-based rendering (production, for fonts)
- [x] Coverage-Mask-then-Cover rendering (production)

### 4.2 Work In Progress (WIP)

- [ ] CPU→GPU buffer upload integration
- [ ] Canvas API integration for `FILLTYPE_VECTOR_PATH`
- [ ] Descriptor set management for vector path buffers
- [ ] Pipeline creation for vector path rendering mode
- [ ] Caching and buffer reuse strategies
- [ ] Performance profiling and optimization
- [ ] Memory management for large shape sets

### 4.3 Planned Enhancements in Future

- [ ] Stroke rendering support
- [ ] Gradient fills integration
- [ ] Texture mapping on vector paths
- [ ] Transform caching
- [ ] Multi-shape batching
- [ ] LOD (Level of Detail) system
- [ ] Cubic curve support (direct, without conversion, but quadratic is sufficient for most cases, even with from-cubic-to-quadratic conversion)
- [ ] GPU-side shape preprocessing (compute shaders)
- [ ] Tessellation shader alternative approach

---

## 5. TODO: Completion Steps for Direct Spatial Grid GPU Vector Rendering

### Phase 1: Buffer Management and Upload

**Priority:** HIGH  
**Estimated Effort:** 2-3 days

- [ ] **TODO-1.1:** Implement `TpvCanvas` methods for vector path buffer management
  - [ ] Add buffer pools for segments, indirect segments, grid cells, shapes
  - [ ] Implement buffer allocation and deallocation strategies
  - [ ] Add buffer growth and shrinking logic
  
- [ ] **TODO-1.2:** Create GPU buffer upload mechanism
  - [ ] Implement `TpvVectorPathGPUShape.UploadToGPU()` method
  - [ ] Handle staging buffers for large uploads
  - [ ] Add synchronization primitives (fences/semaphores)
  
- [ ] **TODO-1.3:** Implement shape handle system
  - [ ] Create `TpvCanvasVectorPathHandle` type
  - [ ] Implement handle→buffer mapping
  - [ ] Add reference counting for automatic cleanup

### Phase 2: Descriptor Set Integration

**Priority:** HIGH  
**Estimated Effort:** 2 days

- [ ] **TODO-2.1:** Create descriptor set layout for vector path buffers (set 2)
  - [ ] Binding 0: Segment buffer (SSBO)
  - [ ] Binding 1: Indirect segment buffer (SSBO)
  - [ ] Binding 2: Grid cell buffer (SSBO)
  - [ ] Binding 3: Shape buffer (SSBO)
  
- [ ] **TODO-2.2:** Implement descriptor set allocation and updates
  - [ ] Add descriptor pool management
  - [ ] Implement `UpdateVectorPathDescriptorSet()` method
  - [ ] Handle dynamic buffer binding (for multi-shape scenarios)
  
- [ ] **TODO-2.3:** Integrate with existing Canvas descriptor sets
  - [ ] Ensure compatibility with set 0 (textures) and set 1 (coverage)
  - [ ] Update pipeline layout creation

### Phase 3: Pipeline Creation

**Priority:** HIGH  
**Estimated Effort:** 1-2 days

- [ ] **TODO-3.1:** Compile shader variants with `FILLTYPE_VECTOR_PATH`
  - [ ] Update shader compilation system
  - [ ] Create shader module for vector path fragment shader
  - [ ] Handle shader permutations (with/without coverage, with/without textures)
  
- [ ] **TODO-3.2:** Create graphics pipeline for vector path rendering
  - [ ] Configure vertex input state
  - [ ] Configure blend state (premultiplied alpha)
  - [ ] Configure depth/stencil state
  - [ ] Set up dynamic state (viewport, scissor)
  
- [ ] **TODO-3.3:** Add pipeline caching
  - [ ] Implement pipeline variant selection logic
  - [ ] Add pipeline cache serialization

### Phase 4: Canvas API Integration

**Priority:** MEDIUM  
**Estimated Effort:** 3-4 days

- [ ] **TODO-4.1:** Extend `TpvCanvas` with vector path methods
  ```pascal
  function DrawVectorPathDirect(const aVectorPathGPUShape:TpvVectorPathGPUShape;
                                const aTransform:TpvMatrix4x4;
                                const aColor:TpvVector4):TpvCanvas;
  
  function FillPath(const aPath:TpvVectorPath;
                    const aRenderMode:TpvCanvasVectorPathRenderMode):TpvCanvas;
  // aRenderMode: DirectSpatialGridGPU, Coverage, SDF
  ```
  
- [ ] **TODO-4.2:** Implement render mode selection
  - [ ] Add `TpvCanvasVectorPathRenderMode` enum
  - [ ] Implement mode switching logic
  - [ ] Add configuration hints (quality vs performance)
  
- [ ] **TODO-4.3:** Add stroke support (future)
  - [ ] Implement stroke expansion to segments
  - [ ] Support line caps and joins
  - [ ] Integrate with direct rendering path

### Phase 5: Optimization and Caching

**Priority:** MEDIUM  
**Estimated Effort:** 2-3 days

- [ ] **TODO-5.1:** Implement shape caching
  - [ ] Add shape hash calculation
  - [ ] Create cache lookup mechanism
  - [ ] Implement LRU eviction policy
  
- [ ] **TODO-5.2:** Add transform-aware caching
  - [ ] Separate shape data from transform
  - [ ] Support transform matrices via push constants
  - [ ] Avoid re-upload for transformed instances
  
- [ ] **TODO-5.3:** Optimize grid cell generation
  - [ ] Profile grid cell intersection tests
  - [ ] Consider compute shader preprocessing (future)
  - [ ] Implement adaptive grid resolution

### Phase 6: Multi-Shape Batching

**Priority:** LOW  
**Estimated Effort:** 3-5 days

- [ ] **TODO-6.1:** Implement shape atlas/array system
  - [ ] Pack multiple shapes into single buffer set
  - [ ] Use shape index in texture coordinates (z component)
  - [ ] Update shader to support shape array
  
- [ ] **TODO-6.2:** Add batching logic
  - [ ] Group draw calls by material/state
  - [ ] Implement instancing for identical shapes
  - [ ] Sort by depth/transparency
  
- [ ] **TODO-6.3:** Optimize draw call submission
  - [ ] Reduce pipeline binds
  - [ ] Merge compatible shapes
  - [ ] Add batching statistics

### Phase 7: Testing and Validation

**Priority:** HIGH (before release)  
**Estimated Effort:** 2-3 days

- [ ] **TODO-7.1:** Create test suite
  - [ ] Unit tests for winding number calculation
  - [ ] Visual regression tests (compare with SDF/coverage modes)
  - [ ] Performance benchmarks
  
- [ ] **TODO-7.2:** Test edge cases
  - [ ] Self-intersecting paths
  - [ ] Degenerate segments (zero-length)
  - [ ] Very large/small shapes
  - [ ] Complex paths (thousands of segments)
  
- [ ] **TODO-7.3:** Validate correctness
  - [ ] Compare with reference rasterizer
  - [ ] Test both fill rules thoroughly
  - [ ] Verify anti-aliasing quality

### Phase 8: Documentation and Examples

**Priority:** MEDIUM  
**Estimated Effort:** 1-2 days

- [ ] **TODO-8.1:** Update API documentation
  - [ ] Document new Canvas methods
  - [ ] Add usage examples
  - [ ] Explain render mode trade-offs
  
- [ ] **TODO-8.2:** Create sample projects
  - [ ] Basic vector path rendering demo
  - [ ] Performance comparison (Direct vs SDF vs Coverage)
  - [ ] Complex scene demo (UI elements, icons)
  
- [ ] **TODO-8.3:** Write performance guidelines
  - [ ] When to use each rendering mode
  - [ ] Grid resolution recommendations
  - [ ] Memory usage estimates

---

## 6. Technical Design Decisions

### 6.1 Why Quadratic Curves Only?

- Simpler intersection calculations
- Lower polynomial degree in fragment shader
- Cubic curves are converted using adaptive subdivision
- Quality loss is negligible at typical resolutions

### 6.2 Why Meta Winding Lines?

- Grid cells may have incomplete path coverage
- Winding number needs initialization for interior cells
- Meta lines provide correct winding "state" for random access
- Alternative would be prefix-sum approach (more complex)

### 6.3 Why Grid Subdivision?

- Reduces per-pixel segment iteration count
- Spatial coherence: nearby pixels hit same cell
- Scalable: adjust resolution for performance/quality trade-off
- Enables efficient culling of distant segments

### 6.4 Why Multiple Rendering Modes?

- **SDF:** Best for small, repeated shapes (fonts, icons)
- **CPU-Tessellated Direct Rendering:** Best for opaque shapes with full path support, where artifacts from overdraw are minimal or almost non-existent, and for sprite rendering and similar use cases
- **Coverage:** Best for transparent, order-dependent scenes
- **Direct Spatial Grid GPU vector rendering:** Best for dynamic, high-resolution, memory-constrained scenarios
- No single approach is optimal for all use cases

---

## 7. Performance Considerations

### 7.1 Grid Resolution Trade-offs

| Resolution | Segment/Cell | Quality | Memory | Performance |
|------------|--------------|---------|--------|-------------|
| 4×4        | High         | Lower   | Low    | Fast        |
| 8×8        | Medium       | Medium  | Medium | Moderate    |
| 16×16      | Low          | High    | High   | Slower      |
| 32×32      | Very Low     | Very High | Very High | Slowest |

**Recommendation:** Start with 8×8, adjust based on profiling.

### 7.2 Bottlenecks

**CPU-Side:**
- Grid cell intersection tests (mitigated by BVH)
- Segment intersection point calculation
- Y-coordinate sorting

**GPU-Side:**
- Fragment shader complexity (per-pixel segment iteration)
- Distance calculation (analytical curve solution)
- Atomic operations (coverage mode)

### 7.3 Optimization Strategies

- Use compute shaders for grid generation (future)
- Implement hierarchical grid (quadtree/octree)
- Cache transformed shapes
- Batch shapes with identical topology

---

## 8. References and Related Work

### 8.1 Pathfinder

- **Project:** [Pathfinder](https://github.com/servo/pathfinder) 
- **Papers:** "Fast GPU-Based Vector Graphics" (2017)
- **Approach:** Similar grid-based rasterization with compute shaders

### 8.2 Loop-Blinn Algorithm

- **Paper:** "Resolution Independent Curve Rendering using Programmable Graphics Hardware" (2005)
- **Approach:** Implicit curve representation using texture coordinates
- **Difference:** We use distance fields + winding, not implicit forms

### 8.3 Slug Library

- **Project:** [Slug](https://www.sluglibrary.com)
- **Approach:** Analytical fragment shader evaluation
- **Similarity:** Direct evaluation without tessellation

## 8.4 Vello (piet-gpu)

- **Project:** [Vello](https://github.com/linebender/vello)
- **Approach:** GPU-accelerated vector rendering with prefix sums
- **Difference:** Uses prefix sum algorithms

## 8.5 Skia

- **Project:** [Skia Graphics Library](https://skia.org/)
- **Approach:** Multiple rendering backends (Ganesh/Graphite GPU backends, CPU rasterization)
  - Tessellation-based path rendering
  - Stencil-then-cover approach (based on NV_path_rendering)
  - MSAA and MSAA-based anti-aliasing
  - Distance fields for text rendering only
- **Difference:** Uses tessellation and stencil approaches rather than per-pixel analytical evaluation; no analytical SDF evaluation for general vector paths (only for text)

---

## 9. Known Issues and Limitations (WIP Status)

### 9.1 Current Limitations

- Stroke rendering not yet implemented - will be emulated by converting strokes to filled outline shapes (simplifies implementation and leverages existing fill infrastructure)
- Cubic Bézier curves converted to quadratic curves during preprocessing (quadratic approximation is sufficient for visual quality at typical resolutions, with lower computational cost than direct cubic evaluation)
- Grid resolution is fixed per shape (no adaptive subdivision)
- No GPU-side preprocessing

### 9.2 Potential Issues

- High segment count per cell may cause performance degradation
- Very small features may be lost in grid subdivision
- Numerical precision issues with extreme scale factors

### 9.3 Future Improvements

- Adaptive grid resolution based on curvature
- GPU-based grid generation (compute shader)
- Stroke path support with proper joins/caps
- Hierarchical culling for complex scenes

---

## 10. API Usage Examples (Future)

### 10.1 Basic Direct Rendering

```pascal
var Path:TpvVectorPath;
    Shape:TpvVectorPathShape;
    GPUShape:TpvVectorPathGPUShape;
begin
 Path:=TpvVectorPath.Create;
 try
  // Build path
  Path.MoveTo(100,100)
      .LineTo(200,100)
      .LineTo(150,200)
      .Close;
  // Convert to shape
  Shape:=Path.GetShape;
  try
   Shape.FillRule:=TpvVectorPathFillRule.NonZero;
   // Create GPU shape
   GPUShape:=TpvVectorPathGPUShape.Create(Shape,8); // 8 = grid resolution
   try
    // Render using Canvas
    Canvas.FillPath(GPUShape,TpvCanvasVectorPathRenderMode.Direct)
          .Color(TpvVector4.Create(1,0,0,1));
   finally
    GPUShape.Free;
   end;
  finally
   Shape.Free;
  end;
 finally
  Path.Free;
 end;
end;
```

### 10.2 Mode Comparison

```pascal
// Mode 1: SDF (for small, cached shapes like fonts)
Canvas.FillPath(IconPath,TpvCanvasVectorPathRenderMode.SDF);

// Mode 2: Coverage (for transparent overlapping shapes)
Canvas.FillPath(TransparentShape,TpvCanvasVectorPathRenderMode.Coverage);

// Mode 3: Direct Spatial Grid GPU vector rendering (for dynamic high-resolution rendering)
Canvas.FillPath(DynamicPath,TpvCanvasVectorPathRenderMode.DirectSpatialGridGPU);
```

---

## 11. Contribution Guidelines

When working on the Pathfinder-like rendering feature:

1. **Maintain Compatibility:** Do not break existing SDF or Coverage rendering modes
2. **Add Tests:** Include unit tests for new functionality
3. **Profile:** Measure performance impact before and after changes
4. **Document:** Update this document with significant changes
5. **Code Style:** Follow existing PasVulkan conventions

---

## 12. Glossary

- **AABB:** Axis-Aligned Bounding Box
- **BVH:** Bounding Volume Hierarchy
- **Coverage Buffer:** GPU buffer storing per-pixel coverage masks
- **Even-Odd Rule:** Fill rule where regions are filled based on odd crossing count
- **Grid Cell:** Spatial subdivision unit containing segment references
- **Meta Winding Line:** Virtual segment used to initialize winding state
- **Non-Zero Rule:** Fill rule where regions are filled based on non-zero winding
- **SDF:** Signed Distance Field
- **SSBO:** Shader Storage Buffer Object
- **Winding Number:** Count of path crossings, determines inside/outside

---

**End of Document**