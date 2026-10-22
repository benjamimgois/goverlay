# Spec Delta: intel-cpu-power-monitoring-fix

## Purpose

Provides reliable verification and guidance for Intel CPU RAPL energy reading permissions without triggering false-positive modal popups or entering loop cycles during configuration loads and inside containerized Flatpak environments.

## ADDED Requirements

### Requirement: Config Load Suppression
The system SHALL suppress proactive Intel CPU power fix checks and interactive dialogs during programmatic configuration loading.

#### Scenario: Application startup with cpu_power enabled
- **WHEN** GOverlay launches and loads a MangoHud configuration containing `cpu_power` on an Intel CPU
- **THEN** the CPU power toggle state is updated without displaying any modal warning or fix prompt

#### Scenario: Tab navigation and preset switching
- **WHEN** user switches between sidebar tabs or loads a preset while `cpu_power` is active
- **THEN** the MangoHud configuration is reloaded without triggering the Intel CPU power fix dialog

### Requirement: Flatpak Proactive Check Bypass
The system SHALL NOT automatically trigger the Intel CPU power fix dialog when the CPU power metric toggle is enabled inside a Flatpak sandbox.

#### Scenario: User toggles CPU power in Flatpak
- **WHEN** a user running GOverlay inside Flatpak clicks the CPU Power toggle switch
- **THEN** the toggle state is updated in configuration without triggering a modal error popup

### Requirement: Actionable Flatpak Guidance on Manual Fix Click
The system SHALL provide actionable host terminal instructions when a user explicitly clicks the Intel power fix button inside Flatpak.

#### Scenario: User clicks fix button inside Flatpak
- **WHEN** a user running GOverlay inside Flatpak explicitly clicks the Intel power fix button
- **THEN** the system displays an informational message explaining that Flatpak cannot modify host system permissions directly and provides the host command to apply the udev rule
