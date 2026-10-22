# Tasks

## 1. Pre-compilation Cleanup and Wine Validation

- [x] 1.1 Implement proactive removal of `~/.local/share/HelixSR/wineprefix` in `CompileHelixSR` in `optiscaler_update.pas` before starting compilation, verifying stale prefixes are purged.
- [x] 1.2 Implement Wine/Proton candidate validation and prioritization in `optiscaler_update.pas` ensuring working runtimes (native `/usr/bin/wine` or functional Proton builds) are validated before shader compilation.

## 2. Diagnostics and User Feedback

- [x] 2.1 Enhance stdout/stderr parsing in `CompileHelixSR` to detect Wine/DXC failure patterns (e.g. `c0000135`, kernel32, or DXC errors) and record specific failure causes.
- [x] 2.2 Update the compilation failure toast in `overlayunit.pas` to present actionable diagnostics advising the user on system Wine or Proton availability.

## 3. Testing and Verification

- [x] 3.1 Add test cases to `tests/gui/gui_test_cases.pas` covering HelixSR pre-compilation cleanup, Wine candidate validation, and error detection.
- [x] 3.2 Compile GOverlay and run test suite using `lazbuild` to ensure all tests pass cleanly.
