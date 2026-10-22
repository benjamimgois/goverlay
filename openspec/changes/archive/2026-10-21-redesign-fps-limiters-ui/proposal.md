# Proposal

## Why

In the Performance tab, the MangoHud Limiters section currently stacks six levels of controls vertically into a tight ~220px vertical span directly above the vkNemu Idle Limiter. This vertical stacking causes visual clutter: the FPS limit entry box is oversized, the toggle switch floats alone, the three color buttons leave an asymmetrical blank space under the low-color block, and the method and toggle key controls are crowded against the bottom divider.

Redesigning this section into a clean horizontal layout with an integrated segmented color ruler creates visual balance, makes the color threshold breakpoints intuitive, and recovers ~80px of vertical breathing room in the card.

## What Changes

- Consolidate the FPS Limit title, input field, method selector (`fpslimmetComboBox`), and toggle key button (`FLimitCaptureBtn`) into an integrated upper row with a subtitle hint.
- Replace the oversized centered FPS Limit edit box with a compact, proportionate input.
- Reorganize the "Change FPS colors" section into a segmented continuous color ruler where the breakpoint spin edits (`fpscolor2SpinEdit` and `fpscolor3SpinEdit`) are geometrically aligned directly beneath the transition boundaries between color segments (Low-to-Mid and Mid-to-High).
- Update the layout reflow calculations in `TMangoHudUiHelper.ReflowPerformanceTab` in `mangohud_ui.pas` to apply the new bounds, spacing, and responsive positioning.

## Capabilities

### New Capabilities
- `mangohud-limiters-ui`: Defines the visual layout and ergonomic positioning of the MangoHud FPS Limiter controls and continuous color threshold ruler on the Performance tab.

### Modified Capabilities
<!-- None: mangohud-fps-colors requirements on configuration persistence and values remain unchanged. -->

## Impact

- Code: `mangohud_ui.pas` (`TMangoHudUiHelper.ReflowPerformanceTab` and associated control creation/setup in `InitPerformanceTab`).
- UI: Performance tab -> Limiters card -> MangoHud Limiter sub-card.
- Dependencies: None. No breaking changes or configuration file format changes.
