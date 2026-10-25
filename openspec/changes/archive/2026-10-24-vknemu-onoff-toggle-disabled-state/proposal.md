# Proposal: vkNemu ON/OFF Toggle and Disabled Visual State

## Summary
Replace the generic slide toggle in the "Idle Limiter (vkNemu)" card with the sidebar's ON/OFF pill toggle (`TSpeedButton` using `globalbuttonImageList`). When vkNemu is disabled (which is the default), all child controls within the card (inputs, labels, unfocused toggle) must be disabled and visibly dimmed/darkened, and the interactive flow diagram (`FVkNemuFlowCard`) must render in a darkened, muted dormant state.

## Motivation
- The generic toggle switch does not clearly communicate state compared to the explicit `[ ON ]` (green) and `[ OFF ]` (gray) pill buttons used in the application sidebar.
- vkNemu defaults to disabled (`AEnabled := False`), but child controls previously remained brightly colored and visually active, causing confusion as to whether vkNemu was running or required activation.
- Disabling and dimming all controls when vkNemu is off provides immediate visual feedback that the section is dormant until toggled ON.

## Scope of Changes
1. **Toggle Component Replacement**:
   - Introduce `FVkNemuToggleBtn: TSpeedButton` in `overlayunit.pas` / `mangohud_ui.pas`.
   - Wire `FVkNemuToggleBtn.Images := FForm.globalbuttonImageList;` with `ImageIndex := 1` (ON) and `0` (OFF).
   - Keep `FVkNemuToggle` synchronized so automated tests and legacy event handlers remain 100% functional.
2. **Visual Dimming & Disabling**:
   - In `Tgoverlayform.VkNemuToggleChange`, when disabled:
     - Disable `FVkNemuIdleFpsSpin`, `FVkNemuTimeoutSpin`, `FVkNemuInputCombo`, `FVkNemuDelaySpin`, `FVkNemuUnfocusedToggle`.
     - Dim labels (`FVkNemuIdleFpsLbl`, `FVkNemuTimeoutLbl`, `FVkNemuInputLbl`, `FVkNemuDelayLbl`) to muted gray/slate.
     - Call `UpdateVkNemuFlowDiagram`.
   - In `TMangoHudUiHelper.VkNemuFlowCardPaint`:
     - When disabled, paint nodes, arrows, and card surface using dark, low-contrast muted tones instead of vibrant emerald green and amber.
3. **Initialization**:
   - Ensure `VkNemuToggleChange(nil)` is triggered on startup during `InitPerformanceTab` so the disabled state is rendered immediately on first paint.
