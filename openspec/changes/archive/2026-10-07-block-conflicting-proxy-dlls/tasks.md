# Tasks: Block Conflicting Proxy DLLs Between ReShade and OptiScaler

## 1. Helper Properties and State Tracking

- [x] 1.1 Add helper methods (`IsOptiScalerActive`, `GetOptiScalerProxyDll`, `IsReshadeActive`, `GetReshadeProxyDll`) in `Tgoverlayform` and `TReshadeTabHelper`, and verify compilation with `make`.
- [x] 1.2 Track previous valid indices `FPreviousProxyIndex` in `TReshadeTabHelper` and `FPreviousFilenameIndex` in `Tgoverlayform` across initialization and config load.

## 2. ReShade and OptiScaler Mutual Exclusion

- [x] 2.1 Wire `filenameComboBox.OnChange` to `filenameComboBoxChange` in `overlayunit.pas` with collision detection against active ReShade, reversion on conflict, and English warning toast.
- [x] 2.2 Implement collision detection in `TReshadeTabHelper.OnProxyChange` with reversion and English warning toast when selecting a proxy DLL already used by active OptiScaler.
- [x] 2.3 Implement the `dxgi.dll` priority confirmation dialog (`MessageDlg`) when ReShade is configured with `dxgi.dll` while OptiScaler is active on `dxgi.dll`, allowing one-click migration of OptiScaler to `version.dll`.
- [x] 2.4 Update `optiscalerRadioButtonClick` in `overlayunit.pas` to default OptiScaler to `version.dll` if ReShade is active on `dxgi.dll`.

## 3. Automated Testing and Verification

- [x] 3.1 Add automated GUI test cases in `tests/gui/gui_test_cases.pas` covering:
  - ReShade blocking and reversion when selecting OptiScaler's active proxy DLL.
  - OptiScaler blocking and reversion when selecting ReShade's active proxy DLL.
  - Safe default to `version.dll` when activating OptiScaler with ReShade on `dxgi.dll`.
- [x] 3.2 Run test suite via `make test` and ensure all test cases pass cleanly with 0 failures and 0 errors.
