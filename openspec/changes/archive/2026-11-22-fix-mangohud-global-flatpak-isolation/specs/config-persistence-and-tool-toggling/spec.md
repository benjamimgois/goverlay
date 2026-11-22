# Spec Delta

## MODIFIED Requirements

### Requirement: Profile context synchronization across tool helpers
The system SHALL synchronize the active configuration of all singleton tab helpers (including `FLosslessScalingHelper`, `FOptiScalerHelper`, and `FMangoHelper`) whenever the active profile context changes (`FActiveGameName`), cancelling any pending auto-save timer before switching and reloading saved configuration from the target profile to prevent in-memory state leakage.

#### Scenario: Switching from global AFMF to clean game profile
- **WHEN** user activates AFMF in the global profile, navigates to a game profile where frame interpolation is disabled or unconfigured, and selects OptiScaler in the UI
- **THEN** system reloads frame interpolation settings from the active game profile
- **THEN** system detects no active AFMF in the game profile and activates OptiScaler without presenting an AFMF conflict prompt

#### Scenario: Returning from game profile to global mode prevents MangoHud state leakage
- **WHEN** user edits MangoHud settings in a game profile and returns to global mode before the auto-save debounce expires or before opening the MangoHud tab
- **THEN** system cancels any pending auto-save timer prior to updating `FActiveGameName` and `MANGOHUDCFGFILE`
- **THEN** system reloads MangoHud controls from the global `MangoHud.conf` so the previous game's `output_folder` and UI state cannot be written to global `MangoHud.conf`
