# Tasks

## 1. Container Architecture & Tab Initialization

- [x] 1.1 Add `FPerfScrollBox: TScrollBox` and `FPerfBgPanel: TPanel` to `performanceTabSheet` in `mangohud_ui.pas` and verify clean background painting without Qt6 GroupBox border artifacts
- [x] 1.2 Implement `MakePerfCard` and create the 3 thematic master cards (`Rate Control & Synchronization`, `Telemetry & HUD Graphics`, `Energy Saving & Visual Optimization`) with 6 symmetrical sub-cards
- [x] 1.3 Update `overlayunit.pas` / `overlayunit.lfm` references to ensure all legacy GroupBoxes (`fpslimiterGroupBox`, `vsyncGroupBox`, `fpsGroupBox`, `filtersGroupBox`) are hidden and their controls reparented to sub-cards

## 2. Card 1: Rate Control & Synchronization

- [x] 2.1 Reparent MangoHud FPS Limiter controls to Card 1 Left sub-card and add quick-preset chips (`60`, `120`, `144`, `Off`) that inject into `FFpsLimitEdit`
- [x] 2.2 Rebuild the dynamic FPS color thresholds into an inline horizontal bar with interactive swatches (`fpscolor1..3ColorButton`) and integrated breakpoint spin edits (`fpscolor2..3SpinEdit`)
- [x] 2.3 Reparent and style Vulkan and OpenGL VSYNC rows in Card 1 Right sub-card with modern API badges and descriptive mode labels

## 3. Card 2: Telemetry & HUD Graphics

- [x] 3.1 Reparent Frame Rate Display controls (`fps`, `fpsavg`, `showfpslim`, `framecount`, `vps`) to Card 2 Left sub-card and configure the `1% Low` / `0.1% Low` segmented dual-pill
- [x] 3.2 Reparent Frametime controls to Card 2 Right sub-card, integrating the `frametimegraphColorButton` swatch, `Curve | Histogram` segmented dual-pill, detailed frametime `+`, and `ftrace` toggle

## 4. Card 3: Energy Saving & Visual Optimization

- [x] 4.1 Reparent and layout vkNemu controls in Card 3 Left sub-card, providing clean spacing for `FVkNemuFlowCard` (state transition diagram), the 2x2 sensitivity parameter grid, and window unfocus cap toggle
- [x] 4.2 Reparent Texture Filtering and Mipmap LOD controls to Card 3 Right sub-card, updating mode selectors to segmented pills and adding dynamic live badges for Anisotropic Filtering (0-16x) and Mipmap LOD Bias (-4.0 to +4.0)

## 5. Dynamic Reflow & Build Verification

- [x] 5.1 Implement `ReflowPerformanceTab` in `mangohud_ui.pas` to dynamically balance sub-card widths (`SecW := (CardW - 2 * IMARGIN - IGAP) div 2`), adjust card vertical offsets, and set `FPerfBgPanel.Height`
- [x] 5.2 Build the Goverlay project with `lazbuild` to verify clean compilation with zero warnings or errors
- [x] 5.3 Test the Performance tab in Goverlay, confirming responsive reflow on window resize and proper save/load persistence of all settings

## 6. Layout Refinement: Row-Based Settings & Stacked vkNemu Grid

- [x] 6.1 Convert `FPerfInfoSec` (Frame Rate) to full-width row layout with labels left, segmented dual-pill inline, and toggles anchored right
- [x] 6.2 Convert `FPerfFrametimeSec` (Frame Timing) to full-width row layout with color swatch and segmented dual-pill inline, toggles right
- [x] 6.3 Convert `FVkNemuSec` (Idle Limiter) parameter grid to stacked layout (labels above inputs, inputs filling column width, comfortable vertical spacing)
- [x] 6.4 Verify with `lazbuild goverlay.lpi --bm=Release --ws=qt6`

## 7. Vertical Rhythm Optimization & Dock Clearance

- [x] 7.1 Compact card heights (`CARD0_H = 175`, `CARD1_H = 160`, `CARD2_H = 240`) to pull Card 2 and vkNemu upward and eliminate dead vertical space
- [x] 7.2 Add `Plot style:` label (`FframetimetypeLbl`) beside `Curve | Histogram` pill in Frame Timing
- [x] 7.3 Align vkNemu stacked grid and ensure `FVkNemuUnfocusedToggle` fits within Card 2 with bottom breathing room
- [x] 7.4 Account for vertical scrollbar width in `CardW` calculation to eliminate edge clipping
- [x] 7.5 Compile with `lazbuild` and verify zero clipping and full dock clearance

## 8. Expand Vertical Space & Unify Color Swatch

- [x] 8.1 Expand card heights to occupy vertical space without cutting (`CARD0_H = 190`, `CARD1_H = 190`, `CARD2_H = 250`)
- [x] 8.2 Reposition `FvpsToggle` in `FPerfInfoSec` with comfortable bottom padding so it never cuts
- [x] 8.3 Change `frametimegraphColorButton` to 22x22 square swatch positioned directly right of `FframetimegraphToggle` (matching CPU Metrics pattern)
- [x] 8.4 Preserve upper positions of `Filters & LOD` sliders so they do not overlap the floating dock pill
- [x] 8.5 Compile with `lazbuild` and verify cleanly

## 9. Alignment Harmony & Discrete Header Presets

- [x] 9.1 Align `Curve | Histogram` pill to the right on the `Frame Time` row (symmetrical with `1% low | 0.1% low` on `FPS Average`)
- [x] 9.2 Prevent right-edge clipping on segmented pills by using dynamic width `Max(128, Glyph.Width + 24)` and sufficient right margin
- [x] 9.3 Move FPS limit presets (`60, 120, 144, Off`) to discrete compact chips in the upper-right corner of the section header (replicating the simulation)
- [x] 9.4 Compile with `lazbuild` and verify clean layout
