# Capability Spec: Minimalist Boot Splash UI

## Purpose

Provides a sleek, modern, dark-navy gradient boot splash UI with clean typography, centered action labels, cyan progress bar, and component detail & percentage status labels during startup downloads.

## ADDED Requirements

### Requirement: Dark Navy Gradient Splash Canvas
- WHEN GOverlay displays the boot splash window:
  - GOverlay SHALL render a 560x360 px borderless `TForm` (`bsNone`, `fsStayOnTop`, `poScreenCenter`).
  - GOverlay SHALL paint a smooth dark navy gradient background on the form canvas (`RGBToColor(12, 18, 32)` to `RGBToColor(24, 38, 62)`).

#### Scenario: Gradient background renders on boot splash
- **WHEN** boot splash is shown during startup
- **THEN** the window displays a smooth dark blue gradient canvas without window borders or title bar

### Requirement: Header Branding and Subtitle
- WHEN GOverlay renders the boot splash header:
  - GOverlay SHALL display the program icon (`48x48 px`) centered near the top.
  - GOverlay SHALL display the main title `"Goverlay"` in bold white sans-serif font below the icon.
  - GOverlay SHALL display the subtitle `"git testing build"` in small light gray font below the title.

#### Scenario: Header branding displayed
- **WHEN** boot splash is visible
- **THEN** top center displays logo icon, bold white "Goverlay" text, and "git testing build" subtitle

### Requirement: Action, Progress, and Detail Status Layout
- WHEN GOverlay updates download progress on the boot splash:
  - GOverlay SHALL display a centered action label above the progress bar formatted as `"Ação: <action>"` (e.g. `Ação: Extraindo core...`).
  - GOverlay SHALL display a sleek cyan/teal progress bar (`RGBToColor(56, 189, 201)`).
  - GOverlay SHALL display component detail status aligned to the left below the progress bar (e.g., `OptiScaler (Edge): Extraindo core...`).
  - GOverlay SHALL display current percentage text aligned to the right below the progress bar (e.g., `41%`).

#### Scenario: Lower third displays action, progress bar, component detail, and percentage
- **WHEN** progress updates are received during startup downloads
- **THEN** action label above progress bar, cyan progress bar, left-aligned component detail, and right-aligned percentage update synchronously
