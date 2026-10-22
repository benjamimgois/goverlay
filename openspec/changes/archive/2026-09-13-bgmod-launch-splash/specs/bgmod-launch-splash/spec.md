## Purpose

Provides immediate visual confirmation upon game startup that GOverlay configurations and mods were applied, presenting a clean checklist of active modules without delaying game execution.

## ADDED Requirements

### Requirement: Non-blocking launch splash display
The system SHALL display an asynchronous, centered, frameless splash window when `bgmod` launches a game, executing concurrently without delaying the game process.

#### Scenario: Game launched with splash enabled and active modules
- **WHEN** user launches a game configured with `bgmod`, launch splash is enabled, and one or more modules or custom configurations are active
- **THEN** system spawns the splash window in the background and immediately proceeds to execute the game binary without waiting.

#### Scenario: Splash auto-dismissal after timeout
- **WHEN** the splash window has been visible for 2.5 seconds
- **THEN** the splash window automatically closes and terminates its process.

#### Scenario: Immediate user dismissal via input
- **WHEN** the user clicks on the splash window or presses a key (such as Escape or Space)
- **THEN** the splash window closes immediately without waiting for the timeout.

### Requirement: Active modules checklist presentation
The splash window SHALL render the GOverlay logo, an informative title, and a dynamic checklist detailing only the modules that are actively enabled for the launched game.

#### Scenario: Displaying only enabled modules
- **WHEN** the splash window renders
- **THEN** only modules configured as active (e.g. MangoHud, OptiScaler, Lossless Scaling, vkBasalt, Tweaks/EnvVars) are displayed with a green checkmark indicator, omitting inactive modules.

#### Scenario: Displaying contextual details for active modules
- **WHEN** a module has specific mode or upscaler information (e.g. OptiScaler with target upscaler or Lossless Scaling with interpolation method)
- **THEN** the module item displays its active method or type alongside the name.

### Requirement: User preference toggle in settings menu
The system SHALL provide a toggle in GOverlay's Settings Menu to enable or disable the game launch splash screen.

#### Scenario: Settings menu toggle placement
- **WHEN** user opens GOverlay's settings menu (gear icon)
- **THEN** a checkable menu item labeled "Show launch splash screen" is displayed directly below the "Create Steam shortcut" item.

#### Scenario: Default preference state
- **WHEN** GOverlay runs without an existing splash preference configured
- **THEN** the launch splash option defaults to enabled (`Checked = True`).

#### Scenario: Persisting preference across sessions
- **WHEN** user toggles the launch splash setting in the settings menu
- **THEN** the preference is persisted to `goverlay.conf` and synchronized to `bgmod.conf` as `SHOW_LAUNCH_SPLASH`.

#### Scenario: Game launch when splash disabled
- **WHEN** user launches a game with `SHOW_LAUNCH_SPLASH=0`
- **THEN** `bgmod` bypasses spawning the splash window and directly executes the game binary.
