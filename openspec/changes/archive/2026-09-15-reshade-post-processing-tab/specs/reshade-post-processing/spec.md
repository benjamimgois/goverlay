## Purpose

Provides native ReShade management, shader collection downloads, UI controls, and Proton/Wine game injection via bgmod on Linux and SteamOS.

## ADDED Requirements

### Requirement: ReShade Post Processing Tab Layout
The system SHALL display the ReShade tab as the first, leftmost tab under the Post Processing sidebar navigation item, positioned before vkBasalt and vkSumi.

#### Scenario: User navigates to Post processing
- **WHEN** the user clicks the "Post processing" item in the sidebar navigation rail
- **THEN** the system displays the Post Processing tab sheets with ReShade active by default in the leftmost position (`[ ReShade ] [ vkBasalt ] [ vkSumi ]`).

### Requirement: Official ReShade Runtime Installation with Add-on Support
The system SHALL download the official ReShade setup executable with Add-on support at runtime, extract `ReShade64.dll` and `ReShade32.dll` using 7z, and store them in the centralized ReShade binary directory.

#### Scenario: Automated runtime extraction during startup
- **WHEN** the startup download thread detects missing ReShade binaries
- **THEN** it downloads the official ReShade Add-on installer, extracts `ReShade64.dll` and `ReShade32.dll` via 7z into `~/.local/share/goverlay/reshade/bin/`, and reports progress to the splash screen.

### Requirement: Shader Package Management
The system SHALL provide an interface to install, update, and remove shader collections (Standard Effects, SweetFX, qUINT, AstrayFX, Prod80) and open the local shaders directory in the system file manager.

#### Scenario: Installing optional shader pack
- **WHEN** the user clicks "Install" for an optional shader collection (such as SweetFX or qUINT)
- **THEN** the system downloads the archive, extracts its shaders and textures into the centralized ReShade shaders directory, and updates the collection status to installed.

#### Scenario: Opening shaders directory
- **WHEN** the user clicks the "Open Shaders Directory" button
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
