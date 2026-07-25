# Window Geometry and Resizing Specification

## Purpose
Enables GOverlay's main window to be resized and maximized, ensures fluid layout reflow for controls across all MangoHud tabs without clipping, and persists window geometry across user sessions.

## Requirements

### Requirement: Window Resizing and Maximization
GOverlay SHALL configure the main window `Tgoverlayform` to be resizable and maximizable by setting `BorderStyle = bsSizeable` and enforcing a minimum width of 1045 pixels and minimum height of 683 pixels.

#### Scenario: User resizes window
- **WHEN** the user drags the main window border or clicks the maximize button
- **THEN** the window resizes or maximizes without going below 1045x683 pixels, and all child UI cards reflow dynamically.

### Requirement: Fluid Inner Control Spacing across Tabs
GOverlay SHALL dynamically calculate and distribute column and row positions for inner controls (checkboxes, color buttons, spin edits) and card heights across expanded window width and height in `Metrics`, `Extras`, `Performance`, and `Visual` tabs when the window is resized or maximized.

#### Scenario: User expands window width and height
- **WHEN** the main window dimensions increase beyond 1045x683 pixels
- **THEN** cards and checkboxes inside `Metrics`, `Extras`, `Performance`, and `Visual` tabs scale and spread proportionally across available width and height instead of leaving empty space at the bottom or sides.

### Requirement: Window Geometry Persistence
GOverlay SHALL save the window dimensions (`Width`, `Height`) and state (`Maximized`) into `goverlay.ini` under the `[Window]` section upon application close, and restore them upon application launch.

#### Scenario: Window state restored on launch
- **WHEN** GOverlay launches with previously saved window dimensions or maximized state in `goverlay.ini`
- **THEN** `Tgoverlayform` initializes using the saved width, height, and maximized state.
