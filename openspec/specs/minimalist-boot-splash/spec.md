# Capability Spec: Minimalist Boot Splash UI

## Purpose

Provides a sleek, modern, dark-navy gradient boot splash UI with clean typography, cyan progress bar, and concise component channel & sub-item status labels during startup downloads.

## Requirements

### Requirement: Dark Navy Gradient Splash Canvas
- WHEN GOverlay displays the boot splash window:
  - GOverlay SHALL render a 560x360 px borderless `TForm` (`bsNone`, `fsStayOnTop`, `poScreenCenter`).
  - GOverlay SHALL paint a smooth dark navy gradient background on the form canvas (`RGBToColor(14, 24, 42)` to `RGBToColor(6, 10, 20)`).

#### Scenario: Gradient background renders on boot splash
- **WHEN** boot splash is shown during startup
- **THEN** the window displays a smooth dark blue gradient canvas without window borders or title bar

### Requirement: Header Branding
- WHEN GOverlay renders the boot splash header:
  - GOverlay SHALL display the program icon (`48x48 px`) centered near the top.
  - GOverlay SHALL display the main title `"Goverlay"` in bold white sans-serif font below the icon.

#### Scenario: Header branding displayed
- **WHEN** boot splash is visible
- **THEN** top center displays logo icon and bold white "Goverlay" title text

### Requirement: Concise Progress and Status Layout
- WHEN GOverlay updates download progress on the boot splash:
  - GOverlay SHALL display a sleek cyan/teal progress bar (`RGBToColor(56, 189, 201)`).
  - GOverlay SHALL display concise status text aligned to the left below the progress bar specifying channel and sub-item (e.g. `Downloading Optiscaler stable (nvidia dlss)`).
  - GOverlay SHALL display current percentage text aligned to the right below the progress bar (e.g. `41%`).

#### Scenario: Lower third displays progress bar, concise component status, and percentage
- **WHEN** progress updates are received during startup downloads
- **THEN** cyan progress bar, left-aligned concise component status with parenthetical sub-item, and right-aligned percentage update synchronously
