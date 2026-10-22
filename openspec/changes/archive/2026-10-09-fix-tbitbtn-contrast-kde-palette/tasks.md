# Tasks

## 1. Core Button Palette Helper & Generic Cards

- [x] 1.1 Implement `StyleBitBtnTheme(ABtn: TBitBtn; ATextColor: TColor; ABgColor: TColor)` in `themeunit.pas` with Qt Palette (`QPaletteButtonText` and `QPaletteWindowText`) and QSS stylesheet synchronization, and verify compilation with `lazbuild`.
- [x] 1.2 Update `UpdateGenericCardTheme` in `overlayunit.pas` to apply `StyleBitBtnTheme` for all `TBitBtn` controls inside cards, ensuring Metrics tab controls (`gpuframesjouleBitBtn`, `coreloadtypeBitBtn`, `cpuframesjouleBitBtn`, `intelpowerfixBitBtn`) receive palette styling.

## 2. MangoHud Tabs Specific Buttons

- [x] 2.1 In `mangohud_ui.pas` (`InitVisualTab` and `UpdateVisualCardTheme`), style `FColumnsMinusBtn`, `FColumnsPlusBtn`, and `FVisualCaptureBtn` using `StyleBitBtnTheme`.
- [x] 2.2 In `mangohud_ui.pas` (`InitPerformanceTab` and `UpdatePerfCardTheme`), style `fpsavgBitBtn`, `frametimetypeBitBtn`, and `FLimitCaptureBtn` using `StyleBitBtnTheme`.
- [x] 2.3 In `mangohud_ui.pas` (`InitExtrasTab` and `UpdateExtrasCardTheme`), style `FTimeConfigBtn`, `logfolderBitBtn`, and `FLoggingCaptureBtn` using `StyleBitBtnTheme`.

## 3. Build & System Verification

- [x] 3.1 Compile GOverlay via `make` (`LAZBUILDOPTS="--ws=qt6"`) and verify clean build with 0 errors.
