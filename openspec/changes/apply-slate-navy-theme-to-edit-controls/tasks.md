## 1. Global Application Stylesheet Update

- [x] 1.1 Update `GlobalSS` in `overlayunit.pas` (`FormShow`) to add rules for `QLineEdit` and `QSpinBox` with Slate Navy background (`rgb(38,46,72)`), subtle border (`rgb(55,70,108)`), focus border (`rgb(48,190,240)`), and disabled styling (`rgb(28,34,54)`).

## 2. Container Theme Helper Synchronization

- [x] 2.1 Update `UpdateGenericCardTheme` in `overlayunit.pas` for `TEdit` controls to match the Slate Navy palette.
- [x] 2.2 Update `mangohud_ui.pas` helper functions (`gpudescEdit`, `hudtitleEdit`, `FFpsLimitEdit`, `fpscolor2SpinEdit`, `fpscolor3SpinEdit`) to ensure local QSS definitions align with the Slate Navy theme.

## 3. Build & Verification

- [x] 3.1 Compile GOverlay with `lazbuild --build-mode=Release` to verify zero build warnings or syntax errors.
- [x] 3.2 Verify visual appearance of `QLineEdit` and `QSpinBox` controls across tabs (MangoHud, OptiScaler, EnvVars).
