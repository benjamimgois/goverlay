## Context

Issue #402 requests visual control over the vkBasalt shader execution order. In vkBasalt, shader execution sequence is governed by the colon-delimited list in `effects = effect1:effect2:...`.

## Architecture & UI Design

### 1. Card Placement and Layout
- `FVkPipelineCard` is inserted on `vkbasaltTabSheet` between `FVkBuiltinCard` and `FVkToggleCard`.
- Heights:
  - `FVkReshadeCard`: Dynamic remaining height (`RSHD_H`)
  - `FVkBuiltinCard`: 145px
  - `FVkPipelineCard`: 65px
  - `FVkToggleCard`: 75px
- `FVkPipelinePB: TPaintBox` handles custom rendering inside `FVkPipelineCard`.

### 2. Chip Visual Representation
- **Category Colors**:
  - Green (`#10B981`): Anti-aliasing (`SMAA`, `FXAA`)
  - Blue/Cyan (`#06B6D4`): Sharpening (`CAS`, `DLS`)
  - Purple (`#8B5CF6`): ReShade Shaders
- **Elements per Chip**:
  - `◀` Move Left button (when index > 0)
  - Category indicator glyph / dot
  - Effect Name
  - `▶` Move Right button (when index < count - 1)
  - `✕` Remove button
  - Connector arrow `──▶` linking adjacent chips.
- Empty state: Displays helpful message `"No active effects. Enable built-in sliders or ReShade shaders above to build the pipeline."`

### 3. Mouse Interaction
- `MouseDown`: Detect click targets (Move Left, Move Right, Close, or start drag).
- `MouseMove`: If dragging, update drag position, calculate target slot, and draw insertion guide line.
- `MouseUp`: Commit reordering to `FPipelineEffects`, reset drag state, and trigger auto-save.

### 4. Configuration Model (`overlay_config.pas`)
- Add `PipelineEffects: TStrings` to `TVkBasaltSettings`.
- `SaveVkBasaltConfig`: Output `effects = ...` by iterating `Settings.PipelineEffects`.
- `LoadVkBasaltConfig`: Parse `effects = ...` into `Settings.PipelineEffects` and map to controls.
