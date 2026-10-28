# Spec Delta

## MODIFIED Requirements

### Requirement: Priority resolution dialog for dxgi proxy DLL
Because `dxgi.dll` supports both DirectX 11 and DirectX 12 games in ReShade while OptiScaler functions reliably with `version.dll`, when ReShade is activated or configured with `dxgi.dll` while OptiScaler is active on `dxgi.dll`, the system SHALL prompt the user with a confirmation dialog offering to switch OptiScaler to `version.dll`. OptiScaler SHALL only be considered active if its master feature toggle is enabled for the current profile.

#### Scenario: User confirms switching OptiScaler to version.dll
- **WHEN** OptiScaler is active with `dxgi.dll`, the user activates ReShade or selects `dxgi.dll` in ReShade, and confirms the dialog prompt
- **THEN** OptiScaler is automatically reconfigured to `version.dll`, OptiScaler's configuration is saved, ReShade is configured with `dxgi.dll`, and a success toast is displayed.

#### Scenario: User declines switching OptiScaler to version.dll
- **WHEN** OptiScaler is active with `dxgi.dll`, the user activates ReShade or selects `dxgi.dll` in ReShade, and declines the dialog prompt
- **THEN** OptiScaler remains on `dxgi.dll`, ReShade's proxy reverts to its previous setting or fallback `d3d11.dll`, and a warning toast explains that ReShade cannot use `dxgi.dll`.

#### Scenario: Activating OptiScaler when ReShade is already on dxgi.dll
- **WHEN** ReShade is active with `dxgi.dll` and the user activates OptiScaler via the method selector
- **THEN** OptiScaler defaults to `version.dll` instead of `dxgi.dll` to prevent collision, and an informative toast notification is displayed.

#### Scenario: ReShade configured with dxgi.dll while OptiScaler is disabled
- **WHEN** OptiScaler's master switch is disabled for the game, but the OptiScaler filename dropdown was previously set to `dxgi.dll`
- **AND** the user activates ReShade or selects `dxgi.dll` in the ReShade tab
- **THEN** the system accepts `dxgi.dll` for ReShade without displaying the proxy conflict resolution dialog, and does NOT enable or reconfigure OptiScaler.
