## Context

See `proposal.md` for motivation. Currently, `reshade_tab.pas` controls the ReShade tab interface and `vkbasalt_tab.pas` controls the vkBasalt and vkSumi tabs. Both are separate tabs under the "Post processing" sidebar navigation rail. This design unifies the user experience by introducing a "Method" card in the ReShade tab to select between None, ReShade, and vkBasalt, while hosting the respective controls in a single scrolling container and maintaining a persistent dual Software status card at the base.

## Goals / Non-Goals

**Goals:**
- Provide a standardized "Method" card with 3 radio options (None, ReShade, vkBasalt) and clickable logos with 35% dimming for inactive options.
- Dynamically toggle interface cards based on the selected method without page reload.
- Remove redundant "Enable ReShade" checkbox from the Config card.
- Keep the "Software status" card visible at the base in all states, reporting presence and version for both ReShade and vkBasalt.
- Maintain mutual exclusion between `GOVERLAY_RESHADE` and `GOVERLAY_VKBASALT` in `bgmod.conf`.
- Hide `vkbasaltTabSheet` from the top tab bar so only `[ ReShade ] [ vkSumi ]` are visible under Post processing.

**Non-Goals:**
- Modifying the vkSumi tab layout or functionality.
- Changing ReShade shader format, proxy DLL injection logic, or bgmod execution mechanisms.
- Changing vkBasalt config file parsing or effect pipeline serialization.

## Decisions

### Decision 1: Method Card Structure & Visual Standard
- **Choice**: Construct `FMethodCard` as a 70px card at `Top: 10` using `StyleMainCard`. Inside, place three radio buttons paired with `TImage` logos:
  - None: `assets/icons/upscaler_none.png`
  - ReShade: `assets/icons/method_reshade.png` (official circular ring + "ReShade" text)
  - vkBasalt: `assets/icons/method_vkbasalt.png` (rendered typography logo)
- **Rationale**: Follows the identical visual design established in `optiscaler_tab.pas` and `lossless_scaling_tab.pas`. Clicking either the radio button or logo activates the selection and updates opacity via `CreateDimmedPng(..., 35)`.
- **Alternatives considered**: Simple dropdown/combobox selector (rejected: does not align with OptiScaler and Lossless Scaling visual style).

### Decision 2: Unified Container & Dynamic Visibility Switching
- **Choice**: Keep `reshade_tab.pas`'s `FScrollBox -> FBgPanel` as the unified host container.
  - When **ReShade** is selected: show `FConfigCard` and `FShadersCard`; hide vkBasalt cards.
  - When **vkBasalt** is selected: reparent/show vkBasalt cards (`FVkToggleCard`, `FVkPipelineCard`, `FVkBuiltinCard`, `FVkReshadeCard`) below `FMethodCard`; hide ReShade cards.
  - When **None** is selected: hide both sets of effect cards; show an informational label indicating post-processing is disabled.
  - In all states: `FStatusCard` is positioned at the base of the content.
- **Rationale**: Provides smooth, immediate switching without altering the tab sheet index or creating flicker.

### Decision 3: Persistent Dual Software Status Card
- **Choice**: Extend `FStatusCard` to display two status indicators side-by-side or stacked:
  - Column 1: `FStatDot` (green/gray), `FStatNameLbl` ("ReShade"), `FStatVerLbl` ("6.4 (Add-on Edition)" or "—").
  - Column 2: `FVkStatDot` (green/gray), `FVkStatNameLbl` ("vkBasalt"), `FVkStatVerLbl` (detected via `GetVkBasaltVersion` or "—").
  - Header action: `FUpdateBtn` ("Check / Update ReShade") positioned at top-right.
- **Rationale**: Fulfills the user requirement for persistent software visibility regardless of whether ReShade, vkBasalt, or None is currently active for the game.

### Decision 4: Configuration Persistence & Mutual Exclusion
- **Choice**: In `SaveConfig` and `LoadConfig`:
  - Selecting ReShade writes `GOVERLAY_RESHADE=1` and `GOVERLAY_VKBASALT=0` to `bgmod.conf`.
  - Selecting vkBasalt writes `GOVERLAY_RESHADE=0` and `GOVERLAY_VKBASALT=1` to `bgmod.conf`.
  - Selecting None writes `GOVERLAY_RESHADE=0` and `GOVERLAY_VKBASALT=0` to `bgmod.conf`.
  - Loading checks `GOVERLAY_RESHADE` and `GOVERLAY_VKBASALT` and selects the appropriate radio button.

### Decision 5: Tab Bar Navigation
- **Choice**: In `overlayunit.pas`, set `vkbasaltTabSheet.TabVisible := False` whenever the Post Processing rail item is active, leaving `reshadeTabSheet` (caption "ReShade") and `vksumiTabSheet` visible.
- **Rationale**: Removes visual clutter from having two tabs for the same category, while keeping vkSumi accessible as a standalone utility.

## Risks / Trade-offs

- **[Risk]** Existing GUI tests expect `vkbasaltTabSheet.TabVisible = True`.
  - *Mitigation*: Update GUI tests to assert `vkbasaltTabSheet.TabVisible = False` and verify vkBasalt options via the unified Method selector on `reshadeTabSheet`.
- **[Risk]** vkBasalt card height reflow when placed inside the scrolling background panel.
  - *Mitigation*: Dynamically calculate `FBgPanel.Height` in `ReflowReShadeTab` based on the active method's card heights plus the persistent `FStatusCard`.
