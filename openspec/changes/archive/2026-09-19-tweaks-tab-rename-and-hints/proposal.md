# Proposal

## Why

With the addition of launch arguments, custom options, and performance command wrappers alongside environment variables, labeling the navigation tab "EnvVars" is overly narrow and technically inaccurate. Returning to the original name "Tweaks" accurately communicates the tab's multi-faceted game and runtime configuration capabilities. Additionally, users need clear, non-intrusive guidance explaining how custom variables and launch arguments configured in Global mode populate into individual game profiles for per-game activation.

## What Changes

- Restore the sidebar navigation rail tab caption from `'EnvVars'` back to `'Tweaks'`.
- Add a discreet, contextual Info Chip banner right before the Custom Variables and Launch Arguments cards:
  - In **Global mode**: display *"Custom items added in Global mode are cataloged and can be toggled per game."*
  - In **Per-Game profile mode**: display *"Global catalog items are listed below. Toggling applies only to this game."*
- Maintain standard card header styling (`CARD_HDR_H = 32`) across all cards while seamlessly offsetting custom card hit-testing and scrolling by the banner height.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `envvars-tab-card-redesign`: Updates tab naming to Tweaks and introduces a contextual info chip banner explaining global catalog inheritance for custom variables and launch arguments.

## Impact

- `sidebar_nav.pas`: Update sidebar navigation item caption to `'Tweaks'`.
- `tweaks_md3.pas`: Render contextual subtitle hint notes in Custom Variables and Launch Arguments card headers, adjusting card height offsets accordingly.
- `tests/gui/gui_test_cases.pas`: Update GUI test assertions referencing tab captions and card layouts.
