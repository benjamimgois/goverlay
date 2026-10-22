# Spec Delta

## MODIFIED Requirements

### Requirement: ReShade Post Processing Tab Layout
The system SHALL display the ReShade tab as the primary post-processing interface under the Post Processing sidebar navigation item, with the standalone vkBasalt tab hidden from the tab bar (`[ ReShade ] [ vkSumi ]`). The ReShade tab interface SHALL feature a full-width "Method" card at the top allowing selection between "None", "ReShade", and "vkBasalt", an area below displaying the active tool's controls, and a persistent "Software status" card at the base of the tab. All cards in the tab SHALL use standard 4px outer margins (`MARGIN = 4`) and expand across nearly the full horizontal width (`Width = ClientWidth - 8`), matching the layout geometry of OptiScaler, and SHALL automatically reflow on scrollbox resize:
1. **Method Card** (top card): contains radio buttons and clickable logos for None, ReShade (official circular RGB logo and "ReShade" text), and vkBasalt (rendered typography logo), with visual dimming for inactive options. Occupies the full horizontal width of the tab (`Left = 4`, `Width = ClientWidth - 8`), distributing the three options symmetrically across three equal columns/slots.
2. **Options Card** (compact horizontal row below Method):
   - When **ReShade** is selected: displays a full-width compact card (`Height` ~56px) containing hotkey Toggle capture button and default proxy DLL combobox arranged side-by-side in a single row.
   - When **vkBasalt** is selected: the Options/Toggle card is completely hidden and omitted from the layout.
   - When **None** is selected: the Options/Toggle card is hidden.
3. **Dynamic Content Area** (middle area):
   - When **ReShade** is selected: displays "Options" (compact full-width bar) and "Shaders" (shader collection packages and Open Shaders Directory button); sets `GOVERLAY_RESHADE=1` and `GOVERLAY_VKBASALT=0`. The Shaders card spans `Left = 4` to `Right = ClientWidth - 4`.
   - When **vkBasalt** is selected: displays vkBasalt configuration cards (Reshade Effects positioned directly below the Method card with expanded vertical height, Built-in Effects, and Effect Pipeline), each spanning `Left = 4` to `Right = ClientWidth - 4`; sets `GOVERLAY_RESHADE=0` and `GOVERLAY_VKBASALT=1`.
   - When **None** is selected: hides effect configuration cards and displays a message indicating post-processing is disabled; sets `GOVERLAY_RESHADE=0` and `GOVERLAY_VKBASALT=0`.
4. **Software status** (bottom card, visible in ReShade and None modes): contains status dot and dynamically detected version information for ReShade (green/gray dot, "ReShade", `<version> (Add-on Edition)`) and vkBasalt (green/gray dot, "vkBasalt", detected version string), alongside the ReShade update action button, spanning `Left = 4` to `Right = ClientWidth - 4`.

#### Scenario: User navigates to Post processing
- **WHEN** the user clicks the "Post processing" item in the sidebar navigation rail
- **THEN** the system displays the ReShade tab with the Method card spanning full width (`ClientWidth - 8`), the compact Options card directly beneath it spanning full width, the Shaders card, and the dual-runtime Software status card at the base showing the dynamically detected ReShade version, with a uniform 4px outer margin on both sides.

#### Scenario: Selecting vkBasalt method
- **WHEN** the user selects the "vkBasalt" option in the Method card
- **THEN** the system displays the Method card spanning full width, completely hides the Options card, positions the Reshade Effects card directly below the Method card with expanded vertical height, followed by Built-in Effects and Effect Pipeline spanning full width (`ClientWidth - 8`), dims the None and ReShade logos, and sets `GOVERLAY_VKBASALT=1` and `GOVERLAY_RESHADE=0` in `bgmod.conf`.

#### Scenario: Selecting None method
- **WHEN** the user selects the "None" option in the Method card
- **THEN** the system displays the Method card spanning full width, hides the Options card and all effect cards, dims the ReShade and vkBasalt logos, sets `GOVERLAY_RESHADE=0` and `GOVERLAY_VKBASALT=0` in `bgmod.conf`, and keeps the Software status card visible at the base.

#### Scenario: Resizing window with ReShade tab active
- **WHEN** the application window is resized or maximized while the ReShade tab is displayed
- **THEN** the scrollbox resize event triggers tab reflow, recalculating card bounds to maintain 4px outer margins and full horizontal span for the Method card and visible content cards without clipping or dead space.
