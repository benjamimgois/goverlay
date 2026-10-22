# Proposal: Split Tweaks into EnvVars and Arguments Sub-tabs

## Why
The Tweaks tab currently hosts both environment variables and launch arguments on a single long scrolling canvas, forcing users to scroll past multiple variable categories to reach launch arguments. Separating these distinct concerns into dedicated "EnvVars" and "Arguments" sub-tabs improves navigation ergonomics, declutters the interface, and provides dedicated cards for predefined vs custom launch arguments.

## What Changes
- Enable sub-tab navigation (`goverlayPageControl.ShowTabs := true`) when selecting Tweaks from the sidebar.
- Rename the primary Tweaks tab sheet to "EnvVars", containing the environment variable cards (General, Graphics, Performance, Latency reduction, Experimental, and Custom Environment Variables).
- Introduce a dedicated "Arguments" sub-tab (`launchArgsTabSheet`) containing two separate cards:
  - **Predefined Arguments**: Curated common launch flags (`-novid`, `-vulkan`, `-dx11`, `-dx12`, `-nojoy`).
  - **Custom Arguments**: User-defined arguments with per-game toggle states, catalog info chip, and global/game badge chip styling.
- Refactor the floating Add button (`+` / FAB) to act contextually based on the active sub-tab:
  - When on the `EnvVars` tab, prompts for an environment variable, pre-focused with `KEY=VALUE` placeholder/validation.
  - When on the `Arguments` tab, prompts for a launch argument, pre-focused with launch option syntax (`-arg` / `+arg`).

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `envvars-tab-card-redesign`: Updates the Tweaks view from a single scrolling canvas to two dedicated sub-tabs (`EnvVars` and `Arguments`), splits Launch Arguments into distinct "Predefined Arguments" and "Custom Arguments" cards, and modifies the Add action to open contextually focused based on the active sub-tab.

## Impact
- **UI Components**: `overlayunit.pas`, `overlayunit.lfm`, `sidebar_nav.pas`, `tweaks_md3.pas`.
- **Rendering & Events**: Split paintbox rendering between `FTweaksPB` (EnvVars) and a new `FArgsPaintBox` (Arguments), wiring mouse click/move/wheel events for the Arguments tab.
- **Configuration & Backend**: Retains existing `bgmod.conf` sections (`[Env]`, `[CustomVariables]`, `[Args]`, `[CustomArguments]`) without breaking data compatibility.
- **Automated Tests**: Updates GUI test cases in `tests/gui/gui_test_cases.pas` to test both sub-tabs and contextual Add dialog routing.
