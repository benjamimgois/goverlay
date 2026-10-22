## Why

To align with the layout structure of the "OptiScaler" tab, the status information in the "Lossless Scaling" tab is reorganized into a dedicated "Software Status" card anchored at the base of the tab. Instead of squeezing controls into 50% horizontal columns, Lossless Scaling (top) and MAKO Renderer (below) are stacked vertically across the full card width, providing ample breathing room for paths, version indicators, action buttons, and the Target GPU selector.

## What Changes

- **Rename Card Title**: Change the card title to "Software Status", matching the naming convention used in the OptiScaler tab.
- **Card Repositioning**: Move the "Software Status" card to the base of the tab, following Frame Generation and Spatial Scaling cards.
- **Vertical Stacked Layout**:
  - **Lossless Scaling Section (Top)**: Full-width row with the 52x52 duck icon, DLL path edit, browse button `[📁]`, `[Inspect]` button, and status label (`● DLL file located`).
  - **MAKO Renderer Section (Middle)**: Full-width row with the 52x52 MAKO cyber shark icon (`assets/icons/mako_renderer.png`), path edit displaying the detected `.so` library (`libmako-render.so`), status label with version (`● MAKO Renderer: vX.Y.Z (Installed)`), and conditional action button (`[Install update]` / `[Install MAKO]`).
  - **Target GPU Device (Bottom)**: Target GPU dropdown positioned below MAKO.
- **Conditional MAKO Action Button**: Remove the static "Check Updates" button; background check runs on startup/tab load, displaying `[Install update]` only when an update is available, or `[Install MAKO]` when not installed.
- **MAKO Mascot Asset**: Add `assets/icons/mako_renderer.png` sourced from the pixel-art cyber shark artwork provided.

## Capabilities

### Modified Capabilities
- `mako-engine-management`: Update the Lossless Scaling tab UI specification to reflect the "Software Status" card anchored at the base of the tab, with full-width stacked rows for Lossless.dll and `libmako-render.so`, MAKO shark icon, and reactive "Install update" button behavior.

## Impact

- `lossless_scaling_tab.pas`: UI layout, card order in `ReflowLosslessScalingTab`, component creation (`FLsMakoLogoImage`, `FLsMakoPathEdit`), and button visibility in `UpdateEngineStatus`.
- `assets/icons/mako_renderer.png`: New icon asset added to the project.
- No breaking changes to existing config files (`bgmod.conf`, `conf.toml`) or command line behavior.
