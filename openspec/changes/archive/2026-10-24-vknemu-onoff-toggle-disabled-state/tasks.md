# Tasks

## 1. Declarations & Wiring
- [x] 1.1 Add `FVkNemuToggleBtn: TSpeedButton` to `Tgoverlayform` and declare `procedure VkNemuToggleClick(Sender: TObject)` in `overlayunit.pas`
- [x] 1.2 Implement `VkNemuToggleClick` in `overlayunit.pas` toggling `FVkNemuCheckBox.Checked` and calling `VkNemuToggleChange`

## 2. UI Creation & Reflow
- [x] 2.1 In `TMangoHudUiHelper.InitPerformanceTab` (`mangohud_ui.pas`):
  - Create `FVkNemuToggleBtn` as a flat `TSpeedButton` using `globalbuttonImageList`
  - Hide generic `FVkNemuToggle` (while keeping it assigned and synchronized for tests)
  - Ensure initial `VkNemuToggleChange(nil)` call on tab setup
- [x] 2.2 In `TMangoHudUiHelper.ReflowPerformanceTab` (`mangohud_ui.pas`):
  - Position `FVkNemuToggleBtn` at `(ClientWidth - 44 - 14, 5, 44, 24)`
  - Size `FVkNemuSectionLbl` to avoid overlapping the button

## 3. Disabling & Visual Dimming
- [x] 3.1 In `Tgoverlayform.VkNemuToggleChange` (`overlayunit.pas`):
  - Update `FVkNemuToggleBtn.ImageIndex := IfThen(AEnabled, 1, 0)`
  - Update font color of `FVkNemuIdleFpsLbl`, `FVkNemuTimeoutLbl`, `FVkNemuInputLbl`, `FVkNemuDelayLbl` to dimmed color when disabled
  - Disable input controls when `AEnabled` is False
  - Trigger `UpdateVkNemuFlowDiagram`
- [x] 3.2 In `TMangoHudUiHelper.VkNemuFlowCardPaint` (`mangohud_ui.pas`):
  - Check `IsEnabled` state
  - Paint flow diagram in dark/muted tones when disabled, and vibrant emerald/amber when enabled

## 4. Verification
- [x] 4.1 Compile cleanly with `lazbuild goverlay.lpi --bm=Release --ws=qt6`
