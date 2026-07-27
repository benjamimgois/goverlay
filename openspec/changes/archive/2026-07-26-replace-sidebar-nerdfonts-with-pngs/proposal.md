## Why

When Nerd Fonts are not installed on a user's system, GOverlay's sidebar navigation icons (`Games`, `Post processing`, `EnvVars`) fail to render and display blank placeholder rectangles `[ ]` instead of graphical icons.
Replacing unicode font glyphs with high-quality dedicated PNG image assets ensures a consistent, crisp visual interface across all Linux desktop environments without requiring external font dependencies.

## What Changes

- Create high-resolution PNG icon assets (`games-inactive.png`, `games-active.png`, `postprocessing-inactive.png`, `postprocessing-active.png`, `envvars-inactive.png`, `envvars-active.png`) in `assets/icons/`.
- Refactor `sidebar_nav.pas` to load `TImage` icons for all sidebar navigation items (`Games`, `MangoHud`, `Post processing`, `OptiScaler`, `EnvVars`) instead of mixing unicode font labels (`TLabel`) and images.
- Update icon active/inactive toggle state logic in `SetNavActive` to switch PNG image sources seamlessly when navigating tabs.
- Update installation scripts / Makefile assets packaging to include the new PNG icon files.

## Capabilities

### New Capabilities
- `sidebar-png-navigation-icons`: Renders all sidebar menu icons using bundled PNG image assets to ensure dependency-free display across Linux environments.

### Modified Capabilities

## Impact

- `sidebar_nav.pas`: Refactors sidebar rail creation and active item image source switching.
- `assets/icons/`: Adds 6 new PNG icon assets for active and inactive sidebar states.
- System dependencies: Completely removes runtime dependency on Nerd Fonts / Noto font glyph fallbacks for sidebar navigation.
