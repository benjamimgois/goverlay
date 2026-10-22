## Why

Currently, ReShade and vkBasalt are presented as separate top-level tabs under Post Processing (`[ ReShade ] [ vkBasalt ] [ vkSumi ]`), even though both serve as post-processing injector frameworks for games and are mutually exclusive in user workflows. Unifying them into a single tab with a "Method" card (similar to OptiScaler and Lossless Scaling tabs) creates a streamlined interface, eliminates redundant toggles, and provides a centralized Software status overview for both runtimes.

## What Changes

- Add a "Method" card at the top of the ReShade tab featuring three mutually exclusive options with clickable radio buttons and logos: **None** (`upscaler_none.png`), **ReShade** (official RGB circular logo with "ReShade" text), and **vkBasalt** (rendered typography text logo).
- Implement logo opacity dimming (35% opacity on unselected logos, 100% on active logo) matching the OptiScaler and Lossless Scaling tab visual standard.
- Dynamically toggle interface cards based on the selected method:
  - **ReShade selected**: Displays ReShade cards (Config, Shaders); sets `GOVERLAY_RESHADE=1` and `GOVERLAY_VKBASALT=0`.
  - **vkBasalt selected**: Displays vkBasalt cards (Toggle, Effect Pipeline, Built-in Effects, Reshade Effects); sets `GOVERLAY_RESHADE=0` and `GOVERLAY_VKBASALT=1`.
  - **None selected**: Hides effect configuration cards and displays a clean muted message; sets `GOVERLAY_RESHADE=0` and `GOVERLAY_VKBASALT=0`.
- Remove the redundant "Enable ReShade" checkbox from the ReShade Config card.
- Keep the "Software status" card always visible at the bottom of the tab, displaying dual status indicators:
  - ReShade presence dot (green/gray), name ("ReShade"), and version ("6.4 (Add-on Edition)").
  - vkBasalt presence dot (green/gray), name ("vkBasalt"), and detected version.
  - ReShade update button at the top-right of the card.
- Hide the standalone `vkbasaltTabSheet` tab from the tab bar (`TabVisible := False`), leaving `[ ReShade ] [ vkSumi ]` in the Post processing section.

## Capabilities

### Modified Capabilities
- `reshade-post-processing`: Update requirements to incorporate the Method card selector (`None`, `Reshade`, `vkbasalt`), dynamic card visibility switching between ReShade and vkBasalt, and dual-runtime Software status monitoring.

## Impact

- `reshade_tab.pas`: Add Method card with 3 radio options, logos, dimmed state management, card visibility switching, and vkBasalt status dot/version.
- `vkbasalt_tab.pas`: Integrate/reparent vkBasalt cards into the unified tab container when vkBasalt is active.
- `overlayunit.pas`: Update tab bar visibility to hide `vkbasaltTabSheet` while preserving tab switching and config synchronization.
- `assets/icons/`: Add `method_reshade.png` and `method_vkbasalt.png`.
- `tests/gui/gui_test_cases.pas`: Update GUI tests to reflect the unified Method card, tab visibility, and dual software status.
