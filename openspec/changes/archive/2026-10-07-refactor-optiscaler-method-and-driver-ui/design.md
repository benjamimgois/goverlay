# Design

## Context

In `optiscaler_tab.pas`, the tab layout is computed in `ReflowOptiScalerTabNew`. Currently, the top row is partitioned between `FOsUpscalerCard` (Left 50%) and `FOsGpuCard` (Right 50%).
In `lossless_scaling_tab.pas`, the corresponding Method card (`FLsMethodCard`) spans 100% of the content width (`CW`), while its former `FLsGpuCard` was hidden.
In `FOsMainSec` (the first column of `FOsOptionsCard`), controls are stacked vertically: `Proxy DLL`, `Menu scale`, `OptiPatcher`, and shortcut key. The lower portion of this column has unused vertical headroom.

## Goals / Non-Goals

**Goals:**
- Make `FOsUpscalerCard` span 100% horizontal width (`CW`) with 3 evenly spaced method slots (`None`, `OptiScaler`, `DLSS Enabler`).
- Hide `FOsGpuCard` and its large vendor graphics from the top row.
- Introduce `gpudriverComboBox` and `gpudriverLabel` inside `FOsMainSec` (Options > Main column).
- Maintain complete synchronization between `gpudriverComboBox` and backend routines (`mesaRadioButtonChange` / `nvidiaRadioButtonChange`, `SaveOptiScalerDriverPreference`, reflex toggles, DLSS spoofing).
- Preserve backwards compatibility with existing GUI test suites that interact with `mesaRadioButton` / `nvidiaRadioButton`.
- Ensure `FOsOptionsCard` and `FOsBgPanel` do not exceed client height or cause unwanted vertical scrolling.

**Non-Goals:**
- Altering the underlying OptiScaler configuration file generation or game launch routines.
- Changing options or layouts on other tabs (e.g. MangoHud, Frame Interpolation, Tweaks).

## Decisions

### 1. Full-Width Method Slot Layout
- In `ReflowOptiScalerTabNew`:
  ```pascal
  FOsUpscalerCard.SetBounds(MARGIN, MARGIN, CW, GPU_H);
  FOsGpuCard.Visible := False;
  ```
- Three slots calculated via `SlotW := (CW - 2 * PAD) div 3;`:
  - Slot 0: `None`
  - Slot 1: `OptiScaler`
  - Slot 2: `DLSS Enabler`
- Centers each radio button and logo image within its slot, consistent with `FLsMethodCard` in `lossless_scaling_tab.pas`.

### 2. GPU Driver Selector Placement in `FOsMainSec`
- Add `gpudriverLabel` and `gpudriverComboBox` to `FOsMainSec`.
- Vertical placement in `FOsMainSec`:
  - `filenameLabel` + `filenameComboBox` (Proxy DLL) at Y = 36 .. 64
  - `gpudriverLabel` + `gpudriverComboBox` (GPU Driver) at Y = 90 .. 118
  - `menuLabel` + `menuscaleComboBox` (Menu scale) at Y = 144 .. 172
  - `FOptiPatcherToggle` / `optipatcherCheckBox` at Y = 200 .. 222
  - `shortcutkeyLabel` + `FOsShortcutCaptureBtn` at Y = 230 .. 258
  - Total vertical extent is ~260px, which fits within the minimum `BoxH` of 240px–290px without vertical overflow.

### 3. Dropdown Item Structure and Hardware Indication
- Populate `gpudriverComboBox` with:
  - Index 0: `Mesa (AMD / Intel)`
  - Index 1: `NVIDIA (Proprietary)`
- If hardware detection (`IsNvidiaModuleLoaded`) detects NVIDIA and no preference has been saved, default index to 1; otherwise index 0.
- Append a subtle `(Auto Detected)` tag or maintain detection status so the user knows which driver was detected by the system.

### 4. Bridge to Existing Radio Handlers
- Keep `mesaRadioButton` and `nvidiaRadioButton` instantiated as shadow/bridge controls.
- When `gpudriverComboBox.OnChange` fires:
  - If Index 0: set `mesaRadioButton.Checked := True` (triggering `mesaRadioButtonChange`).
  - If Index 1: set `nvidiaRadioButton.Checked := True` (triggering `nvidiaRadioButtonChange`).
- When `mesaRadioButton.Checked` or `nvidiaRadioButton.Checked` is set programmatically (e.g., during startup or by test fixtures), update `gpudriverComboBox.ItemIndex` accordingly.
- This guarantees zero regressions for existing test cases and config persistence.

## Risks / Trade-offs

- **[Vertical space in Main column]** → Adding a dropdown might increase height requirements.
  *Mitigation*: Reposition existing items compactly within `FOsMainSec`. Total vertical stack remains under 270px, which comfortably fits standard 648px window heights without scrollbars.
- **[Test breakages relying on `mesaRadioButton`]** → Tests directly inspect `mesaRadioButton`.
  *Mitigation*: Keep `mesaRadioButton` and `nvidiaRadioButton` intact as components, syncing with `gpudriverComboBox`.
