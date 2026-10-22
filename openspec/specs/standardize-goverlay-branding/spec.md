# standardize-goverlay-branding Specification

## Purpose
Standardizes user-facing branding and application name references across the interface, dialogs, desktop notifications, splash screens, tooltips, Steam shortcuts, packaging, and documentation to use the canonical "Goverlay" casing.

## Requirements

### Requirement: User interface and dialog brand presentation
The system SHALL display the application name as "Goverlay" (capitalizing only the initial letter "G") across all user-facing dialog messages, confirmation prompts, desktop notifications, tooltips, hints, and changelog window titles.

#### Scenario: Confirmation and notification dialogs display standardized branding
- **WHEN** the application prompts the user to clear configuration, warns about Flatpak GameMode permissions, displays Steam shortcut guidance, or dispatches desktop notifications
- **THEN** all rendered titles and prompt messages use "Goverlay" instead of legacy "GOverlay".

#### Scenario: Tooltips and hints display standardized branding
- **WHEN** the user inspects tooltips in the Games tab, Version check, OptiScaler tab, or Lossless Scaling migration assistant
- **THEN** all hints and tooltips display "Goverlay" (e.g. `Enabled Goverlay Tools:`).

### Requirement: Launch splash screen brand presentation
The `bgmod-splash` executable SHALL display "Goverlay" as its main header title on the launch splash window.

#### Scenario: Splash screen title rendering
- **WHEN** `bgmod-splash` renders upon game execution
- **THEN** the title label displays "Goverlay" centered alongside the application logo.

### Requirement: Steam shortcut integration brand consistency
The Steam shortcut script SHALL register shortcuts using `AppName: 'Goverlay'` and SHALL match and cleanly manage shortcuts named either legacy `'GOverlay'` or standardized `'Goverlay'`.

#### Scenario: Registering new Steam shortcut
- **WHEN** the user creates a Steam shortcut for Goverlay
- **THEN** the generated shortcut entry is named "Goverlay" in `shortcuts.vdf`.

#### Scenario: Clean replacement of existing shortcuts
- **WHEN** the user updates or creates a Steam shortcut on a system that already has a legacy "GOverlay" shortcut
- **THEN** the script matches either "GOverlay" or "Goverlay" and updates the shortcut without creating duplicate entries.

### Requirement: Documentation and packaging metadata brand consistency
Application metainfo files, manual pages, packaging specifications (Debian and RPM), and repository guides SHALL consistently refer to the project as "Goverlay" in all descriptive texts and titles.

#### Scenario: Reviewing packaging and documentation metadata
- **WHEN** inspecting `goverlay.metainfo.xml`, `goverlay.1`, Debian `control`, RPM `goverlay.spec`, `README.md`, or `CONTRIBUTING.md`
- **THEN** all user-visible references to the project name read "Goverlay".
