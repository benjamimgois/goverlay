# Spec Delta

## MODIFIED Requirements

### Requirement: Non-destructive tool toggle state persistence
The system SHALL control tool activation by writing `GOVERLAY_MANGOHUD`, `GOVERLAY_VKBASALT`, `GOVERLAY_VKSUMI`, `GOVERLAY_OPTISCALER`, and `GOVERLAY_TWEAKS` flags into `bgmod.conf` without deleting configuration files (`MangoHud.conf`, `vkBasalt.conf`, `vkSumi.conf`, `OptiScaler.ini`) or clearing `[Env]` variables. Navigating between tool tabs while a tool is disabled SHALL NOT trigger saving or alter existing disabled toggle flags in `bgmod.conf`. When launching 3D preview, the system SHALL only inject environment variables and activation flags for tools that are currently enabled in the active profile (global or game-specific). When toggling on the Upscalers tool, the system SHALL only set `GOVERLAY_OPTISCALER=1` if an active upscaler method is configured (`UPSCALER_TYPE <> 2`), and SHALL only set `GOVERLAY_LOSSLESS=1` if a frame interpolation method is configured (`INTERPOLATION_METHOD <> 'none'`). Clean profiles without a `bgmod.conf` file SHALL default to inactive upscaler state (`UPSCALER_TYPE=2`).

#### Scenario: User disables MangoHud globally
- **WHEN** user toggles off MangoHud in the sidebar navigation rail
- **THEN** system sets `GOVERLAY_MANGOHUD=0` in `bgmod.conf`
- **THEN** system preserves `MangoHud.conf` on disk so user customization remains intact

#### Scenario: User disables Tweaks globally
- **WHEN** user toggles off Tweaks in the sidebar navigation rail
- **THEN** system sets `GOVERLAY_TWEAKS=0` in `bgmod.conf`
- **THEN** system preserves all key-value entries in the `[Env]` section of `bgmod.conf`

#### Scenario: Application restart preserves disabled tool states
- **WHEN** user restarts GOverlay after disabling tools in global mode
- **THEN** system reads tool states from `bgmod.conf` and keeps those tools disabled
- **THEN** system does not overwrite existing configuration files with default templates

#### Scenario: Accessing MangoHud tab when disabled preserves toggle state
- **WHEN** MangoHud is disabled (`GOVERLAY_MANGOHUD=0` in `bgmod.conf`) and user accesses the MangoHud tab
- **THEN** system populates controls without firing AutoSave events
- **THEN** system preserves `GOVERLAY_MANGOHUD=0` in `bgmod.conf`

#### Scenario: Preview launch respects disabled tool toggles
- **WHEN** an overlay tool (MangoHud, vkBasalt, vkSumi, Lossless Scaling, or EnvVars) is disabled in the active profile (global or game) and user clicks Preview
- **THEN** system does not inject the activation environment variables for the disabled tool when launching `pascube` or `vkcube`

#### Scenario: Toggling on Upscalers with method set to None
- **WHEN** user toggles on Upscalers in the sidebar for a profile where no upscaler (`UPSCALER_TYPE=2`) and no frame interpolation (`INTERPOLATION_METHOD=none`) are selected
- **THEN** system persists `GOVERLAY_OPTISCALER=0` and `GOVERLAY_LOSSLESS=0` in `bgmod.conf`
- **THEN** system does not deploy proxy DLL overrides when the game is launched

#### Scenario: Clean game profile defaults upscaler to None
- **WHEN** user creates or opens a clean game profile where `bgmod.conf` is missing
- **THEN** system initializes `Settings.UpscalerTypeItemIndex` to `2` (None)
- **THEN** the OptiScaler tab reflects upscaler as disabled

## ADDED Requirements

### Requirement: Profile context synchronization across tool helpers
The system SHALL synchronize the active configuration of all singleton tab helpers (including `FLosslessScalingHelper` and `FOptiScalerHelper`) whenever the active profile context changes (`FActiveGameName`), reloading saved configuration from the target profile to prevent in-memory state leakage.

#### Scenario: Switching from global AFMF to clean game profile
- **WHEN** user activates AFMF in the global profile, navigates to a game profile where frame interpolation is disabled or unconfigured, and selects OptiScaler in the UI
- **THEN** system reloads frame interpolation settings from the active game profile
- **THEN** system detects no active AFMF in the game profile and activates OptiScaler without presenting an AFMF conflict prompt
