# Spec Delta

## ADDED Requirements

### Requirement: Mutual exclusion between ReShade and OptiScaler proxy DLLs
The system SHALL prevent ReShade and OptiScaler from concurrently using the same proxy DLL. If a user attempts to select a proxy DLL in either interface that is already in use by the other active tool, the selection SHALL be reverted to its previous valid index and a warning toast notification in English SHALL be displayed.

#### Scenario: User attempts to select conflicting proxy DLL in ReShade
- **WHEN** OptiScaler is active and using a proxy DLL (such as `dxgi.dll` or `d3d12.dll`), and the user selects the identical proxy DLL in the ReShade tab combobox
- **THEN** the system blocks the change, reverts the ReShade proxy combobox to its previous selection, does not save the configuration, and displays a warning toast indicating the DLL is already in use by OptiScaler.

#### Scenario: User attempts to select conflicting proxy DLL in OptiScaler
- **WHEN** ReShade is active and using a proxy DLL (such as `dxgi.dll` or `d3d12.dll`), and the user selects the identical proxy DLL in the OptiScaler tab combobox
- **THEN** the system blocks the change, reverts the OptiScaler proxy combobox to its previous selection, does not save the configuration, and displays a warning toast indicating the DLL is already in use by ReShade.

#### Scenario: Non-conflicting proxy selection
- **WHEN** OptiScaler is active on `version.dll` and the user selects `dxgi.dll` for ReShade
- **THEN** the selection is accepted, saved, and auto-saved without blocking.

### Requirement: Priority resolution dialog for dxgi proxy DLL
Because `dxgi.dll` supports both DirectX 11 and DirectX 12 games in ReShade while OptiScaler functions reliably with `version.dll`, when ReShade is activated or configured with `dxgi.dll` while OptiScaler is active on `dxgi.dll`, the system SHALL prompt the user with a confirmation dialog offering to switch OptiScaler to `version.dll`.

#### Scenario: User confirms switching OptiScaler to version.dll
- **WHEN** OptiScaler is active with `dxgi.dll`, the user activates ReShade or selects `dxgi.dll` in ReShade, and confirms the dialog prompt
- **THEN** OptiScaler is automatically reconfigured to `version.dll`, OptiScaler's configuration is saved, ReShade is configured with `dxgi.dll`, and a success toast is displayed.

#### Scenario: User declines switching OptiScaler to version.dll
- **WHEN** OptiScaler is active with `dxgi.dll`, the user activates ReShade or selects `dxgi.dll` in ReShade, and declines the dialog prompt
- **THEN** OptiScaler remains on `dxgi.dll`, ReShade's proxy reverts to its previous setting or fallback `d3d11.dll`, and a warning toast explains that ReShade cannot use `dxgi.dll`.

#### Scenario: Activating OptiScaler when ReShade is already on dxgi.dll
- **WHEN** ReShade is active with `dxgi.dll` and the user activates OptiScaler via the method selector
- **THEN** OptiScaler defaults to `version.dll` instead of `dxgi.dll` to prevent collision, and an informative toast notification is displayed.
