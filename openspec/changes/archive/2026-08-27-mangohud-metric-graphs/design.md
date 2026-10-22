## Context

See `proposal.md` for motivation.
`TToggleSwitch` in `toggle_switch.pas` is used throughout the Metrics tab for all GPU and CPU/memory metric options.
MangoHud config parses `graphs=item1,item2,...` where valid graph metrics are `gpu_load`, `vram`, `gpu_core_clock`, `gpu_mem_clock`, `gpu_temp`, `cpu_load`, `cpu_temp`, and `ram`.

## Goals / Non-Goals

**Goals:**
- Extend `TToggleSwitch` to optionally host an integrated graph button icon without adding separate orphaned button controls.
- Maintain crisp, anti-aliased rendering of the graph button icon across dark and light themes.
- Provide click handling for the graph button that toggles graph mode and triggers auto-save without interfering with the toggle switch's main on/off click handler.
- Extend `TMangoHudSettings` and configuration serialization/deserialization to cleanly persist and load `graphs=...`.

**Non-Goals:**
- Custom graph sizing/styling per metric (MangoHud global graph parameters handle dimensions).
- Adding graph buttons to non-supported metrics (e.g. Vulkan driver, GPU model, disk IO).

## Decisions

### Decision 1: Integrated Graph Button in `TToggleSwitch`
- **Approach**: Add `HasGraphButton: Boolean`, `GraphActive: Boolean`, `OnGraphClick: TNotifyEvent`, and `GraphRect: TRect` properties to `TToggleSwitch`.
- **Rationale**: Keeps layout calculations, font scaling, hover hit-testing, and theme styling fully encapsulated inside `TToggleSwitch`. Avoids having to create and align 8 external `TSpeedButton` or `TBitBtn` controls in `mangohud_ui.pas`.
- **Alternative Considered**: Separate `TBitBtn` controls beside each toggle. Rejected due to visual misalignment across dynamic reflow column widths and unnecessary control overhead.

### Decision 2: Visual States for the Graph Button
- **When Parent Toggle is OFF**: Graph button is rendered with low alpha / dimmed (`#404B60`), unclickable.
- **When Parent Toggle is ON & Graph is OFF**: Subdued dark border (`#2E3A50`), muted icon (`#8898B0`), cursor handpoint on hover.
- **When Parent Toggle is ON & Graph is ON**: Illuminated cyan/mint border (`#30BEF0` / `#38D9A9`), glowing background tint (`rgba(48, 190, 240, 0.15)`), active icon.

### Decision 3: Configuration Serialization in `overlay_config.pas`
- In `SaveMangoHudConfigCore`, collect all active graph flags whose parent metric is enabled into a comma-delimited `graphs=...` line.
- In `LoadMangoHudConfigCore` / `LoadMangoHudConfig`, parse the comma-delimited tokens in `graphs=` and set the corresponding `Graph*` properties on `TMangoHudSettings` and `TToggleSwitch` instances.

## Risks / Trade-offs

- **[Risk] Width overflow in narrow column layouts**: If columns are narrow, the extra width of the graph button (~20px) could overlap with adjacent controls.
  → *Mitigation*: Adjust `GetOptimalWidth` to include `GraphButtonWidth` when `HasGraphButton` is true, and verify in `ReflowMetricsTab` that `ColW` has adequate space.
