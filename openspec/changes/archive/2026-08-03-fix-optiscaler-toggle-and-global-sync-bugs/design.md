# Design Document: OptiScaler Toggle and Global Sync Fixes

## Overview

This change resolves UI state anomalies and file synchronization gaps when toggling OptiScaler ON/OFF in GOverlay (Issue #247 comment 5172544430):
1. Re-enabling OptiScaler via sidebar toggle calls `SetControlTreeEnabled(optiscalertabsheet, True)`, enabling all child controls regardless of selected GPU driver (NVIDIA/MESA).
2. Initial toggle-ON with MESA selected by default does not apply recommended MESA Reflex settings.
3. Toggling OptiScaler ON in global mode (`FActiveGameName = ''`) fails to populate OptiScaler configuration files and DLLs into `gameconfig/global/` immediately.

## Technical Details

### 1. Re-enforcing Driver Constraints on Tool Enable State (`sidebar_nav.pas` & `optiscaler_tab.pas`)
- In `TSidebarNavHelper.ApplyToolEnabledState(2, AEnabled)`, when `AEnabled` is `True`:
  - Execute `FForm.SetControlTreeEnabled(FForm.optiscalertabsheet, True)`.
  - Immediately check if `FForm.nvidiaRadioButton.Checked` is `True`. If so, set `FForm.spoofCheckBox.Enabled := False`, `FForm.forcereflexCheckBox.Enabled := False`, and `FForm.reflexComboBox.Enabled := False`.
  - If `FForm.mesaRadioButton.Checked` is `True` and `forcereflexCheckBox` was not previously set up, trigger recommended MESA defaults (`forcereflexCheckBox.Checked := True`, `reflexComboBox.ItemIndex := 2`).

### 2. Immediate Global Profile OptiScaler File Sync (`sidebar_nav.pas`)
- In `TSidebarNavHelper.NavToolToggleClick(Sender: TObject)`:
  - Inside the `else` block (where `FForm.FActiveGameName = ''`):
    - When `Idx = 2` (OptiScaler) and `NewEnabled` is `True`, invoke global profile OptiScaler file population (`FForm.SyncOptiScalerToGlobalConfig` or `CopyOptiScalerGameFiles(FForm.GetGameConfigDir(''))`).
    - When `Idx = 2` and `NewEnabled` is `False`, delete/cleanup global OptiScaler configuration files if appropriate.

## User Review Required

> [!IMPORTANT]
> Global OptiScaler files will now be synced immediately upon flipping the OptiScaler sidebar toggle switch in global mode, making global behavior consistent with per-game mode.

## Verification Plan

### Automated Tests
- `lazbuild tests/gui/gui_tests.lpi --widgetset=qt6 && ./tests/gui/gui_tests`
- Add test case `TestOptiScalerToggleNvidiaReEnableState`: Select NVIDIA driver -> toggle OptiScaler OFF -> toggle OptiScaler ON -> assert `spoofCheckBox.Enabled` and `forcereflexCheckBox.Enabled` remain `False`.
- Add test case `TestGlobalOptiScalerToggleSync`: In global mode -> toggle OptiScaler ON -> assert `OptiScaler.ini` and DLLs exist in `gameconfig/global/`.

### Manual Verification
- Launch GOverlay, switch driver to NVIDIA, toggle OptiScaler OFF, toggle OptiScaler ON, verify `Spoof DLSS` and `Force Reflex` remain greyed out.
- Toggle OptiScaler ON in global mode, check `~/.local/share/goverlay/gameconfig/global/` to verify OptiScaler files are populated immediately.
