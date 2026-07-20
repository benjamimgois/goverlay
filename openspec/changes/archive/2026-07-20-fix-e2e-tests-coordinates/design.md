## Context

Simulating clicks on window coordinates inside fractional scaled sessions or environments with custom title bars leads to mouse clicks landing slightly offset from targets (buttons/checkboxes). We need to calculate window scaling factors dynamically and employ click sweep patterns for vital actions.

## Goals / Non-Goals

**Goals:**
- Dynamically parse the actual window width and height to calculate width/height scale factors relative to 1045x683.
- Implement a Y-axis click sweep mechanism for driver toggle events so the runner tests several vertical offsets until the save is successful.

**Non-Goals:**
- Completely remove coordinate-based clicking (which remains necessary since GOverlay layout is defined by fixed-width panels).

## Decisions

### 1. Dynamic Window Geometry Detection

**Decision:** Parse `xdotool getwindowgeometry <id>` in Python to fetch current dimensions `W` and `H`.

**Rationale:** The KDE Wayland display session scales Xwayland window dimensions by factors like 1.25 or 1.5. Scaling coordinates by `W/1045` and `H/683` maps the click to the exact visual location regardless of host display settings.

### 2. Vertical click sweep for GPU driver toggles

**Decision:** Iterate through a list of candidate Y-axis offsets (e.g., [52, 92, 122, 142]) when attempting to click Mesa/Nvidia. Verify if the target file (`OptiScaler.ini`) was created and updated between click sweeps.

**Rationale:** Title bars (window decorations) vary by window manager. A vertical click sweep guarantees that at least one coordinate hits the button, and checking file-system persistence ensures that the runner doesn't proceed unless the click successfully triggered GOverlay's auto-save logic.
