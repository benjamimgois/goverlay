# Tasks

## 1. bgmod Launcher Resolution and Wine Overrides Delimiter

- [x] 1.1 Update `ResolveGameDirectory` in `bgmod.lpr` and `bgmod-uninstaller.lpr` to compare `CleanKey` and `TargetSub` against `Arg` case-insensitively using lowercase strings, and verify matching on lowercase launcher binaries.
- [x] 1.2 Update `WINEDLLOVERRIDES` concatenation in `bgmod.lpr` to use semicolon (`;`) delimiters instead of commas (`,`), and verify that combined overrides (such as `d3dcompiler_47=n,b;dxgi=n,b`) format correctly.

## 2. Active OptiScaler Validation in Proxy Conflict Handling

- [x] 2.1 Update `Tgoverlayform.IsOptiScalerActive` in `overlayunit.pas` to verify that the upscaler tool toggle is enabled for the active game profile (`GetGameToolEnabled`), ensuring disabled upscaler states return `False`.
- [x] 2.2 Verify that selecting `dxgi.dll` in the ReShade tab (`reshade_tab.pas`) does not prompt for proxy conflicts or re-enable OptiScaler when OptiScaler is toggled off in the current profile.

## 3. Diagnostic Logging Argument Redaction

- [x] 3.1 Implement `RedactSensitiveParam` helper function in `bgmod.lpr` to replace sensitive values for `-AUTH_PASSWORD=`, `-AUTH_LOGIN=`, `-epicuserid=`, and `-epicpassword=` with `[REDACTED]`.
- [x] 3.2 Apply `RedactSensitiveParam` when logging command arguments to `/tmp/bgmod.log` and central logs in `bgmod.lpr`, and verify that sensitive arguments are redacted while regular flags are preserved.

## 4. Verification and Regression Testing

- [x] 4.1 Add automated test cases covering launcher case-insensitivity, `WINEDLLOVERRIDES` formatting, `IsOptiScalerActive` toggle awareness, and argument redaction.
- [x] 4.2 Run the test suite and verify all test cases pass without regressions.
