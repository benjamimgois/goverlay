# Spec Delta

## ADDED Requirements

### Requirement: 32-bit Runtime Download
The system SHALL download the i686 package of the selected DLSS-NR architecture into `dlss-nr-<arch>-i686` next to the 64-bit runtime. It SHALL take the newest release that has one, and SHALL skip checksum files and 64-bit packages. The download SHALL be best effort: a failure SHALL NOT fail model extraction or block startup.

#### Scenario: Downloading the 32-bit runtime with the model
- **WHEN** the user extracts the DLSS-NR model and the i686 runtime of that architecture is not installed
- **THEN** the system downloads the i686 package (`*-i686-rdna3.tar.gz` for RDNA3, `*-i686.tar.gz` for RDNA4) into `dlss-nr-<arch>-i686`
- **AND** records its release tag in that folder's `goverlay.vars`.

#### Scenario: Existing DLSS-NR install without the 32-bit runtime
- **WHEN** GOverlay starts with the DLSS-NR model extracted and an architecture runtime installed, but without its i686 runtime
- **THEN** the system downloads the i686 runtime for that architecture without showing a failure notice when it cannot.

### Requirement: ReShade Route for 32-bit DirectX 8/9 Games
When DLSS-NR is selected for a 32-bit (i386) Windows game that draws with Direct3D 8 or 9, the launcher SHALL deploy DLSSNR-AMD's ReShade route from the i686 runtime instead of the OptiScaler route. Direct3D SHALL be detected from the executable's imports or, when it imports none, from a DLL next to the executable or one folder below. The deployment SHALL copy files directly, as the package installer's dx9 route does, and SHALL list them in `dlssnr-amd-install.txt`.

#### Scenario: Deploying to a Direct3D 8 game
- **WHEN** a 32-bit game whose renderer module imports `d3d8.dll` is launched with DLSS-NR selected through a Proton build that ships DXVK's 32-bit `d3d8.dll`
- **THEN** the launcher copies the runtime folder, the extracted models, ReShade32 with its Vulkan loader and layer manifest, the D3D9 ReShade preset as `ReShadePreset.ini`, the int4 add-on, and DXVK's `d3d8.dll` into the game folder
- **AND** does not copy OptiScaler or the reshade-feeder `dxgi.dll`
- **AND** writes `dlssnr-amd.ini` from the package's add-on ini with GOverlay's DLSS-NR settings applied
- **AND** exports `winevulkan=n,b`, `vulkan-1=n,b` and `d3d8=n,b` in `WINEDLLOVERRIDES` and `renderer=gdi` in `WINE_D3D_CONFIG`.

#### Scenario: Deploying to a Direct3D 9 game
- **WHEN** a 32-bit game whose executable imports `d3d9.dll` is launched with DLSS-NR selected
- **THEN** the launcher deploys the same route without `d3d8.dll` and exports only `winevulkan=n,b` and `vulkan-1=n,b`
- **AND** appends `renderer=gdi` to a `WINE_D3D_CONFIG` the user set without a renderer.

#### Scenario: Route already installed
- **WHEN** the route is installed from the current runtime and models
- **THEN** the launcher copies nothing again, keeps settings changed in game, and applies only GOverlay settings saved after the game's `dlssnr-amd.ini` was written.

#### Scenario: DXVK d3d8.dll outside the launch
- **WHEN** a 32-bit Direct3D 8 game is launched with DLSS-NR selected without a Proton build in the launch arguments
- **THEN** the launcher copies DXVK's 32-bit `d3d8.dll` from the Proton build in `PROTONPATH` or `STEAM_COMPAT_TOOL_PATHS`, or else from the newest installed Proton or DXVK build of Steam, Lutris or Heroic
- **AND** ignores 64-bit `d3d8.dll` files and folders in Steam libraries that are not Proton builds.

#### Scenario: Proton updated
- **WHEN** the route is installed and the DXVK `d3d8.dll` found at launch differs from the copy GOverlay made
- **THEN** the launcher replaces the copy with the one found.

#### Scenario: Route cannot work
- **WHEN** DLSS-NR is selected for a 32-bit Direct3D 8/9 game launched with `PROTON_USE_WINED3D=1`, or for a Direct3D 8 game with no DXVK `d3d8.dll` in the game folder or on the system
- **THEN** the launcher installs nothing, removes an installed route, exports no DLSS-NR environment, and logs why.

#### Scenario: 32-bit runtime missing
- **WHEN** DLSS-NR is selected for a 32-bit Direct3D 8/9 game and no i686 runtime is installed
- **THEN** the launcher installs neither route, exports no DLSS-NR environment, and logs that the 32-bit runtime is missing.

#### Scenario: Earlier installs in the game folder
- **WHEN** the game folder holds an install made by the package's installer, a GOverlay OptiScaler install, or a GOverlay ReShade proxy
- **THEN** the launcher removes the installer's files by their manifest, purges the OptiScaler install, and removes the ReShade proxy before deploying the route
- **AND** skips GOverlay's own ReShade deployment while the route is installed.

### Requirement: ReShade Route Removal
The launcher and `bgmod-uninstaller` SHALL remove a ReShade route that GOverlay installed (`dlssnrroute=reshade-dx9` in `goverlay.vars`) by its manifest. They SHALL ignore manifest entries outside the game folder.

#### Scenario: DLSS-NR turned off
- **WHEN** a game with the route installed is launched with OptiScaler/DLSS-NR disabled
- **THEN** every file and folder in its manifest is removed, the game's own files are kept, and no DLSS-NR environment is exported.

#### Scenario: Uninstalling
- **WHEN** `bgmod-uninstaller` runs for a game with the route installed
- **THEN** it removes every file and folder in the manifest, including ReShade32, the Vulkan loader and `vk-override/`.

## MODIFIED Requirements

### Requirement: Central Runtime Download and Storage
The system SHALL download and cache the appropriate DLSS-NR release package into a central data directory for the selected architecture, recognizing both legacy and `0.0.9` runtime layouts. The system SHALL prevent redundant re-downloads when the current release is already cached and SHALL download the runtime matching the target architecture. The 64-bit runtime download SHALL NOT select an `i686` package.

#### Scenario: Downloading DLSS-NR release package
- **WHEN** DLSS-NR is selected and the required architecture runtime package is not present in central storage
- **THEN** the system downloads the latest release archive from the corresponding repository (RDNA4 from `mochizuki0323/DLSSNR-AMD` on GitLab into `dlss-nr-rdna4` or RDNA3 from `saaaaaaaaaaaaaaaaaas/DLSSNR-RDNA3` on GitHub into `dlss-nr-rdna3`)
- **AND** unpacks the binaries and support tools into the central DLSS-NR directory while updating the cached version string.

#### Scenario: RDNA3 release with an i686 package
- **WHEN** the RDNA3 release lists both its 64-bit package and its `i686-rdna3` package
- **THEN** the system downloads the 64-bit package into `dlss-nr-rdna3`.

#### Scenario: Recognizing cached 0.0.9 runtime layout
- **WHEN** the central DLSS-NR directory already contains `optiscaler/release/OptiScaler.dll` or `optiscaler/asi/dlssnr-amd.asi`
- **THEN** the system treats the runtime cache as present and skips redundant re-downloads unless forced.
