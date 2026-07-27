# Design: Use `env.png` for EnvVars Sidebar Icon (`use-env-png-sidebar-icon`)

## Processing Pipeline

1. **Source Asset**:
   - `assets/icons/env.png` (512x512 RGBA)

2. **Supersampling & Color Tinting**:
   - **Active State (`envvars-active.png`)**:
     - Extract content bounding box, resize to 26x26 inner box inside 32x32 canvas at 8x supersampling (256x256), apply pure white `#FFFFFF` tint with smooth alpha gradient, downsample using `LANCZOS` filter to 32x32.
   - **Inactive State (`envvars-inactive.png`)**:
     - Extract content bounding box, resize to 26x26 inner box inside 32x32 canvas at 8x supersampling (256x256), apply muted gray `#AAAAAA` tint (55% alpha scale), downsample using `LANCZOS` filter to 32x32.

3. **Runtime Integration**:
   - `sidebar_nav.pas` already loads `envvars-active.png` when active and `envvars-inactive.png` when inactive. Overwriting these files updates the UI automatically.

## Verification Plan
- Run `make test` to verify all 41 GUI tests pass cleanly.
