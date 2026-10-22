# Proposal: Block Conflicting Proxy DLLs Between ReShade and OptiScaler

## Why
When both ReShade and OptiScaler are configured to use `dxgi.dll` concurrently, ReShade fails to activate in-game due to hook collision and override precedence. Furthermore, `dxgi.dll` provides critical versatility for ReShade because it hooks both DirectX 11 and DirectX 12 games, whereas other ReShade proxies (`d3d11.dll`, `d3d12.dll`) are restricted to a single API. OptiScaler, conversely, operates universally across DirectX 11, 12, and Vulkan when configured with `version.dll`.

Currently, GOverlay does not enforce mutual exclusion between ReShade's proxy DLL and OptiScaler's proxy DLL in the UI, allowing colliding selections that break runtime functionality.

## What Changes
- Enforce mutual exclusion between ReShade and OptiScaler proxy DLLs:
  - In the ReShade tab, prevent selecting a Proxy DLL that is currently in use by an active OptiScaler instance.
  - In the OptiScaler tab, prevent selecting a Proxy DLL that is currently in use by an active ReShade instance.
  - Revert combobox selection and display a warning toast (`ntWarning`) in English when a conflict is attempted.
- Intelligent resolution and priority for `dxgi.dll`:
  - When activating ReShade (or selecting `dxgi.dll` in ReShade) while OptiScaler is active with `dxgi.dll`, prompt the user with a confirmation dialog (`MessageDlg`) explaining that ReShade benefits most from `dxgi.dll` (DX11/DX12 coverage) and proposing to automatically reassign OptiScaler to `version.dll`.
  - If accepted, reassign OptiScaler to `version.dll`, persist OptiScaler's configuration, and set ReShade to `dxgi.dll` with an informative toast (`ntSuccess`).
  - If declined, revert ReShade's proxy or assign an alternative (`d3d11.dll`) with an explanatory toast (`ntWarning`).
- When switching OptiScaler on while ReShade is already using `dxgi.dll`, automatically default OptiScaler to `version.dll` instead of forcing a collision on `dxgi.dll`.
- All toast and dialog texts are in English.

## Capabilities

### Modified Capabilities
- `proxy-dll-management`: Add requirements for mutual exclusion between ReShade and OptiScaler proxy DLLs, conflict prevention blocking with toast notifications, and guided `dxgi.dll` priority resolution dialog.

## Impact
- `reshade_tab.pas`: Validation on `FProxyComboBox.OnChange` and `ApplyMethodSelection`.
- `overlayunit.pas`: Wire `filenameComboBox.OnChange` with collision checking against active ReShade; update `optiscalerRadioButtonClick` default proxy assignment.
- `optiscaler_tab.pas`: Preserve `filenameComboBox.OnChange` across configuration loading.
- `tests/gui/gui_test_cases.pas`: Automated unit tests verifying conflict blocking, combobox reversion, toast notifications, and resolution dialog logic.
