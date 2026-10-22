# bgmod-launch-splash Specification

## Purpose
Provides immediate visual confirmation upon game startup that Goverlay configurations and mods were applied, presenting a clean checklist of active modules without delaying game execution.

## Requirements

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
The splash window SHALL render the Goverlay logo, an informative title displaying the launched game profile name without corruption from environment variables, and a dynamic checklist detailing only the modules that are actively enabled for the launched game.

#### Scenario: Displaying only enabled modules
- **WHEN** the splash window renders
- **THEN** only modules configured as active (e.g. MangoHud, OptiScaler, Lossless Scaling, vkBasalt, ReShade, vkSumi, Tweaks/EnvVars) are displayed with a green checkmark indicator, omitting inactive modules.

#### Scenario: Displaying ReShade post-processing
- **WHEN** Post-Processing is enabled with Method set to ReShade (`GOVERLAY_RESHADE=1`)
- **THEN** the checklist includes "ReShade" with a green checkmark indicator.

#### Scenario: Displaying contextual details for active modules
- **WHEN** a module has specific mode or upscaler information (e.g. OptiScaler with target upscaler or Lossless Scaling with interpolation method)
- **THEN** the module item displays its active method or type alongside the name.

#### Scenario: Accurate game profile title display
- **WHEN** a game is launched from a per-game configuration profile
- **THEN** the splash window displays the exact game profile name without corruption from internal environment variables or configuration files.

### Requirement: User preference toggle in settings menu
The system SHALL provide a toggle in Goverlay's Settings Menu to enable or disable the game launch splash screen.

#### Scenario: Settings menu toggle placement
- **WHEN** user opens Goverlay's settings menu (gear icon)
- **THEN** a checkable menu item labeled "Show launch splash screen" is displayed directly below the "Create Steam shortcut" item.

#### Scenario: Default preference state
- **WHEN** Goverlay runs without an existing splash preference configured
- **THEN** the launch splash option defaults to enabled (`Checked = True`).

#### Scenario: Persisting preference across sessions
- **WHEN** user toggles the launch splash setting in the settings menu
- **THEN** the preference is persisted to `goverlay.conf` and synchronized to `bgmod.conf` as `SHOW_LAUNCH_SPLASH`.

#### Scenario: Game launch when splash disabled
- **WHEN** user launches a game with `SHOW_LAUNCH_SPLASH=0`
- **THEN** `bgmod` bypasses spawning the splash window and directly executes the game binary.

### Requirement: Distribution packaging and bundling of launch splash binary
The system packaging targets (including RPM specifications and AppImage bundling scripts) SHALL include the `bgmod-splash` binary in the expected library directory (`libexecdir` / `AppDir/lib`) and SHALL NOT leave unpackaged or misplaced ELF binaries in data directories.

#### Scenario: RPM package file list coverage
- **WHEN** the Goverlay RPM package is built via `rpmbuild`
- **THEN** `%{_prefix}/lib/bgmod-splash` is packaged in `%files`, satisfying the buildroot unpackaged file check without error.

#### Scenario: Removal of duplicate binary from data directory
- **WHEN** `make install` is executed
- **THEN** the `bgmod-splash` binary is pruned from `$(datadir)/goverlay/bgmod/`, preventing duplicate ELF binaries under `/usr/share`.

#### Scenario: AppImage bundling of launch splash
- **WHEN** the Goverlay AppImage is assembled via `goverlay-appimage.sh`
- **THEN** `bgmod-splash` is copied into `./AppDir/lib/bgmod-splash`, enabling runtime extraction and execution inside AppImage environments.

### Requirement: Launch Splash Wrapper Update Notification
The launch splash window SHALL display an informational notification item (`"BGMod updated"`) in English when `bgmod` has performed a self-update during the current game launch.

#### Scenario: Display update notification on splash screen
- **WHEN** launch splash is enabled and `bgmod` has performed a self-update on the current launch
- **THEN** the splash screen checklist includes `"BGMod updated"` alongside other enabled modules

#### Scenario: No update notification on regular launches
- **WHEN** `bgmod` starts without performing a self-update
- **THEN** the splash screen displays only the standard enabled modules checklist without `"BGMod updated"`
