# Design: Add DLSS-Enabler Toggle Key Display

## Context

On the Upscalers tab, the Main sub-card displays controls for File name, Menu scale, OptiPatcher, and a shortcut capture button. Currently, the shortcut key label is titled "Toggle key". When DLSS Enabler is enabled, DLSS Enabler uses a fixed toggle key (` ` ` / grave accent), but GOverlay does not display it, leading to user confusion over which toggle key belongs to which component.

## Design Decisions

### 1. Rename `shortcutkeyLabel` Caption
Set `shortcutkeyLabel.Caption := 'Optiscaler toggle'`.

### 2. Instantiate `dlssenablerToggleLabel` and `dlssenablerToggleBtn`
In `overlayunit.pas`, declare:
- `dlssenablerToggleLabel: TLabel;`
- `dlssenablerToggleBtn: TBitBtn;`

In `optiscaler_tab.pas` (`Init` / `ReflowOptiScalerTab`):
- `dlssenablerToggleLabel`: `Caption := 'DLSS-Enabler toggle'`, parent `FOsMainSec`.
- `dlssenablerToggleBtn`: `Caption := '⌨ ` '`, `Enabled := False`, parent `FOsMainSec`.

### 3. Conditional Visibility
In `TOptiScalerTabHelper.UpdateFrameGenOptionsUI` (and `ReflowOptiScalerTab`):
```pascal
IsDlssEnabler := Assigned(FForm.dlssenablerRadioButton) and FForm.dlssenablerRadioButton.Checked;
if Assigned(FForm.dlssenablerToggleLabel) then
  FForm.dlssenablerToggleLabel.Visible := IsDlssEnabler;
if Assigned(FForm.dlssenablerToggleBtn) then
  FForm.dlssenablerToggleBtn.Visible := IsDlssEnabler;
```

### 4. Layout Positioning inside `FOsMainSec`
In `ReflowOptiScalerTab`:
- `shortcutkeyLabel`: Y = `Y0 + 166` (Caption: `'Optiscaler toggle'`)
- `FOsShortcutCaptureBtn`: Y = `Y0 + 184`, H = 28
- `dlssenablerToggleLabel`: Y = `Y0 + 218`
- `dlssenablerToggleBtn`: Y = `Y0 + 236`, H = 28
- Increase `MinOptH` from 265 to 315 to ensure the options card has sufficient height when DLSS Enabler toggle is visible.

## Migration / Compatibility

No changes to config file format (`OptiScaler.ini` / `bgmod.conf`). Visually distinguishes the OptiScaler toggle key from DLSS Enabler's fixed toggle key.
