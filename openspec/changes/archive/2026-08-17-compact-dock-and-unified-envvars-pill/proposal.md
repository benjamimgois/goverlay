## Why

On the EnvVars (Tweaks) tab, the interface currently renders two separate floating pills: an upper `+ Add` custom variable button and the bottom-right `✦ Finish` action dock. This creates visual clutter and redundant floating elements. Additionally, the floating dock and overlay badges are slightly oversized for compact desktop displays. Integrating the `+ Add` button directly into the unified floating action dock and reducing dimensions across all pill controls will create a cleaner, more compact, and consistent UI.

## What Changes

- **Integrated EnvVars Add Button**: Add a contextual `+ Add` secondary button inside `TFloatingActionDock`, visible exclusively on the EnvVars tab, and deprecate the standalone floating button (`FTweaksFABBtn`) in `tweaks_md3.pas`.
- **Accent Color Hierarchy**: Ensure the cyan accent highlight is always applied to the primary `✦ Finish` action on the right, while `+ Add`, `▶ Preview`, and `☰ Menu` retain the neutral dark button styling.
- **Compact Geometry**:
  - Reduce floating dock height from `48px` to `38px` (button height `30px`, vertical padding `4px`).
  - Reduce button widths: `Finish` to `84px`, `Preview` to `88px`, `+ Add` to `76px`, `Menu` to `34px`.
  - Reduce window corner margins to `16px` right / `14px` bottom.
  - Reduce auto-save floating toast dimensions to `136 × 28px`.
- **Update Tab Visibility API**: Update `TFloatingActionDock.UpdateForTab(AShowPreview, AShowMenu, AShowAdd)` to configure button combinations cleanly per tab.

## Capabilities

### New Capabilities

- `compact-floating-action-dock`: Unified compact floating action dock hosting contextual actions (`▶ Preview`, `☰ Menu`, `+ Add`) alongside the accented primary `✦ Finish` button with compact dimensions.

## Impact

- `floating_dock.pas`: Introduce `FAddBtn`, compact geometry constants, and `OnAddClick` event.
- `tweaks_md3.pas`: Remove `FTweaksFABBtn` and forward custom variable creation to the dock's `OnAddClick`.
- `overlayunit.pas`: Wire `FFADock.OnAddClick` to `TweaksMD3FABClick` and update `UpdateForTab` tab triggers.
- `floating_overlay.pas`: Reduce dimensions for `TFloatingToast` and `TFloatingProgressBanner`.
- `tests/gui/gui_test_cases.pas`: Update GUI test coverage for the unified dock and compact layout.
