# Spec Delta: reshade-post-processing

## MODIFIED Requirements

### Requirement: ReShade Post Processing Tab Layout
The system SHALL display the ReShade tab as the primary post-processing interface under the Post Processing sidebar navigation item, with the standalone vkBasalt tab hidden from the tab bar (`[ ReShade ] [ vkSumi ]`). The ReShade tab interface SHALL feature a "Method" card at the top allowing selection between "None", "ReShade", and "vkBasalt", an area below displaying the active tool's controls, and a persistent "Software status" card at the base of the tab. All cards in the tab SHALL use standard 4px outer margins (`MARGIN = 4`) and expand across nearly the full horizontal width (`Width = ClientWidth - 8`), matching the layout geometry of Lossless Scaling, and SHALL automatically reflow on scrollbox resize:
1. **Method Card** (top card): contains radio buttons and clickable logos for None, ReShade (official circular RGB logo and "ReShade" text), and vkBasalt (rendered typography logo), with visual dimming for inactive options. Occupies the left half of the top row (`Left = 4`, `Width = (CW - GAP) div 2`).
2. **Config Card / Toggle Card** (top right card): occupies the remaining right half of the top row, ending at `ClientWidth - 4`.
3. **Dynamic Content Area** (middle area):
   - When **ReShade** is selected: displays "Config" (hotkey Toggle capture button, default proxy DLL combobox) and "Shaders" (shader collection packages and Open Shaders Directory button); sets `GOVERLAY_RESHADE=1` and `GOVERLAY_VKBASALT=0`. The Shaders card spans `Left = 4` to `Right = ClientWidth - 4`.
   - When **vkBasalt** is selected: displays vkBasalt configuration cards (Toggle, Effect Pipeline, Built-in Effects, and Reshade Effects), each spanning `Left = 4` to `Right = ClientWidth - 4`; sets `GOVERLAY_RESHADE=0` and `GOVERLAY_VKBASALT=1`.
   - When **None** is selected: hides effect configuration cards and displays a message indicating post-processing is disabled; sets `GOVERLAY_RESHADE=0` and `GOVERLAY_VKBASALT=0`.
4. **Software status** (bottom card, always visible): contains status dot and version information for both ReShade (green/gray dot, "ReShade", "6.4 (Add-on Edition)") and vkBasalt (green/gray dot, "vkBasalt", detected version string), alongside the ReShade update action button, spanning `Left = 4` to `Right = ClientWidth - 4`.

#### Scenario: User navigates to Post processing
- **WHEN** the user clicks the "Post processing" item in the sidebar navigation rail
- **THEN** the system displays the ReShade tab with the Method card at the top left, the active method's cards spanning full width (`ClientWidth - 8`), and the dual-runtime Software status card at the base, with a uniform 4px outer margin on both sides.

#### Scenario: Selecting vkBasalt method
- **WHEN** the user selects the "vkBasalt" option in the Method card
- **THEN** the system displays the vkBasalt configuration cards spanning full width (`ClientWidth - 8`), dims the None and ReShade logos, sets `GOVERLAY_VKBASALT=1` and `GOVERLAY_RESHADE=0` in `bgmod.conf`, and keeps the dual Software status card visible at the base.

#### Scenario: Selecting None method
- **WHEN** the user selects the "None" option in the Method card
- **THEN** the system hides both ReShade and vkBasalt configuration cards, dims the ReShade and vkBasalt logos, sets `GOVERLAY_RESHADE=0` and `GOVERLAY_VKBASALT=0` in `bgmod.conf`, and keeps the Software status card visible at the base.

#### Scenario: Resizing window with ReShade tab active
- **WHEN** the application window is resized or maximized while the ReShade tab is displayed
- **THEN** the scrollbox resize event triggers tab reflow, recalculating card bounds to maintain 4px outer margins and full horizontal span without clipping or dead space.
