## Why

The EnvVars tab currently stretches items horizontally across the entire width of the window, placing toggle switches far from their text descriptions (over 1000px on wide screens). This causes visual scanning fatigue and forces extensive vertical scrolling to browse through the 28+ environment variable tweaks. Reorganizing the EnvVars list into a 2-column responsive grid layout reduces vertical height by ~50% and keeps toggle controls immediately next to their descriptions.

## What Changes

- Redesign the custom-painted EnvVars (tweaks) grid in `tweaks_md3.pas` to support a responsive 2-column layout when window width is sufficiently wide (e.g. `>= 700px`), falling back to a single column on narrower windows.
- Update mouse hit testing (`MouseMove`, `MouseDown`, `MouseWheel`) and drawing routines (`Paint`, `DrawItem`, `DrawHeader`) to support two side-by-side columns per category.
- Keep category headers spanning full width across both columns for visual organization.

## Capabilities

### New Capabilities
- `envvars-layout`: Responsive 2-column grid layout for the EnvVars tab reducing vertical scrolling and improving toggle control proximity.

### Modified Capabilities

## Impact

- `tweaks_md3.pas`: Item positioning, header painting, scroll height calculation, and mouse hit testing for 2-column layout.
