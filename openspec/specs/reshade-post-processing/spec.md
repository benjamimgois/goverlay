## Purpose

Provides native ReShade management, shader collection downloads, UI controls, and Proton/Wine game injection via bgmod on Linux and SteamOS.

## Requirements

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

### Requirement: Official ReShade Runtime Installation with Add-on Support
The system SHALL discover the latest ReShade Add-on release dynamically at runtime, download the corresponding official ReShade setup executable with Add-on support, extract `ReShade64.dll` and `ReShade32.dll` using 7z, persist the installed version in `version.txt` under the ReShade root, and store binaries in the centralized ReShade binary directory.

#### Scenario: Automated runtime extraction during startup
- **WHEN** the startup download thread detects missing ReShade binaries
- **THEN** it resolves the latest available ReShade Add-on version, downloads the official installer executable, extracts `ReShade64.dll` and `ReShade32.dll` via 7z into `~/.local/share/goverlay/reshade/bin/`, records the version in `~/.local/share/goverlay/reshade/version.txt`, and reports progress to the splash screen.

#### Scenario: On-demand update via Check updates button
- **WHEN** the user clicks the "Check updates" button in the ReShade tab
- **THEN** the system queries the latest remote ReShade release tag or download URL, downloads and extracts the newest Add-on setup executable if an update is available or forced, updates `version.txt`, flushes console output with explicit success messages, and refreshes the Software status card with the new version.

### Requirement: Shader Package Management
The system SHALL provide an interface inside the "Shaders" card to install, update, and remove shader collections (Standard Effects, SweetFX, qUINT, AstrayFX, Prod80) and provide a button in the header of the "Shaders" card to open the local shaders directory in the system file manager.

#### Scenario: Installing optional shader pack
- **WHEN** the user clicks "Install" for an optional shader collection (such as SweetFX or qUINT)
- **THEN** the system downloads the archive, extracts its shaders and textures into the centralized ReShade shaders directory, and updates the collection status to installed.

#### Scenario: Opening shaders directory
- **WHEN** the user clicks the "Open Shaders Directory" button in the "Shaders" card
- **THEN** the system opens the file manager at `~/.local/share/goverlay/reshade/shaders/`.

### Requirement: Wine and Proton Path Translation in ReShade Configuration
The system SHALL generate and maintain `ReShade.ini` referencing centralized shader and texture directories using Wine drive notation (`Z:\...`).

#### Scenario: Generating ReShade configuration for a game
- **WHEN** ReShade is deployed for a game
- **THEN** the system writes a `ReShade.ini` file in the game directory where `EffectSearchPaths` and `TextureSearchPaths` point to the centralized shaders path converted with `Z:\` and backslashes.

### Requirement: Game-Level Injection and Proxy DLL Deployment via bgmod
The system SHALL allow enabling ReShade per game, deploying the runtime DLL under a user-selected proxy filename (`dxgi.dll`, `d3d11.dll`, `d3d12.dll`, `d3d9.dll`, `opengl32.dll`), configuring `WINEDLLOVERRIDES`, and recording the deployed proxy in `goverlay.vars`.

#### Scenario: Launching game with ReShade enabled
- **WHEN** a game configured with ReShade launches via bgmod
- **THEN** bgmod copies the ReShade runtime DLL to the target proxy name, copies or generates `ReShade.ini`, sets the corresponding `WINEDLLOVERRIDES`, and records `reshadeproxy=<name>` in `goverlay.vars`.

#### Scenario: Safe cleanup of ReShade proxy
- **WHEN** ReShade is disabled for a game or uninstalled
- **THEN** the system removes only the proxy DLL recorded in `goverlay.vars` under `reshadeproxy`, leaving all non-GOverlay files intact.
