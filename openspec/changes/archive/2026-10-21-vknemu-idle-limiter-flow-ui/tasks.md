# Tasks

## 1. Visual Flow Components Creation

- [x] 1.1 Create `FVkNemuFlowCard` and its sub-labels (`FVkNemuFlowActiveTitle`, `FVkNemuFlowActiveSub`, `FVkNemuFlowArrow1`, `FVkNemuFlowStandbyTitle`, `FVkNemuFlowStandbySub`, `FVkNemuFlowArrow2`, `FVkNemuFlowResumeTitle`, `FVkNemuFlowResumeSub`) in `InitPerformanceTab` within `mangohud_ui.pas`.
- [x] 1.2 Implement `UpdateVkNemuFlowDiagram` in `mangohud_ui.pas` to dynamically reflect current `Idle FPS`, `Timeout`, `Wake Input`, and `Delay` values.
- [x] 1.3 Hook `UpdateVkNemuFlowDiagram` into `VkNemuControlChange` in `overlayunit.pas`.

## 2. Layout Geometry & Reflow

- [x] 2.1 Reposition `FVkNemuDivider`, section header with icon (`🌙 Idle Limiter (vkNemu)`), and `FVkNemuFlowCard` in `ReflowPerformanceTab`.
- [x] 2.2 Reposition the 2x2 parameter controls and `Cap on window unfocus` toggle beneath the flow diagram with balanced vertical spacing.

## 3. Build & Integration Verification

- [x] 3.1 Compile Goverlay with `lazbuild -B goverlay.lpi` and verify successful build with 0 errors.
- [x] 3.2 Verify real-time reflection of spin edit changes in the flow diagram.
