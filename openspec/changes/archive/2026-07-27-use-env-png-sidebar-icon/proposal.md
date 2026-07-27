# Change Proposal: Use `env.png` for EnvVars Sidebar Icon (`use-env-png-sidebar-icon`)

## Overview
Replace the source icon for the "EnvVars" sidebar menu item with the new high-resolution `assets/icons/env.png` (512x512) asset. Process this asset using our 32x32 1:1 supersampling and color-tinting pipeline to generate `envvars-active.png` and `envvars-inactive.png` with uniform visual weight and tone.

## User Impact
- **Visual Consistency**: The EnvVars menu item will use the updated icon artwork matching the high quality, 32x32 size, and `#AAAAAA` gray tone of the other sidebar icons.

## Affected Files
- `assets/icons/envvars-active.png`: Generated active icon (white `#FFFFFF`)
- `assets/icons/envvars-inactive.png`: Generated inactive icon (muted gray `#AAAAAA`)
- `assets/icons/env.png`: Source high-resolution artwork (512x512)
