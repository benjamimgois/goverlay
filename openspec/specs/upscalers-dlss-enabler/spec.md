# Capability: Upscalers Tab & DLSS Enabler Support

## Purpose

Provides integrated configuration, management, version tracking, and automated file deployment for OptiScaler and DLSS Enabler upscaling mods within GOverlay.

## Requirements

### Requirement: Tab Renaming and Card Layout Reorganization
The sidebar navigation item SHALL display the caption "Upscalers" instead of "OptiScaler".
The top section of the Upscalers tab SHALL render two 50% width cards side-by-side: "Upscaler" on the left and "GPU Driver" on the right.

### Requirement: Mutually Exclusive Image Checkboxes
The "Upscaler" card SHALL contain two mutually exclusive options: "OptiScaler" (selected by default) and "DLSS Enabler".
Each option SHALL be represented by an image logo.
The active option's image SHALL be displayed with full opacity (100%), and the inactive option's image SHALL be displayed with reduced opacity (40%).
When selecting "DLSS Enabler", if no custom proxy DLL is previously configured for the active game, `version.dll` SHALL be automatically pre-selected as the proxy DLL.

### Requirement: DLSS Enabler Downloading and Version Tracking
GOverlay SHALL download and extract the latest DLSS Enabler release from `https://github.com/bygalacos/OptiScalerBuilder` into `~/.local/share/goverlay/dlssenabler-edge`.
A `goverlay.vars` marker file containing `dlssenablerversion=<version>` SHALL be written inside the `dlssenabler-edge` directory.
The Software Status section on the Upscalers tab SHALL display the installed version of DLSS Enabler.

### Requirement: Game Directory File Synchronization
When launching a game with DLSS Enabler active, `bgmod` SHALL copy `OptiScaler.ini`, the `OptiScaler/` directory, and copy root `OptiScaler.dll` renamed to the target proxy DLL (default `version.dll`) into the game executable directory.
`OptiScaler.ini` and `fakenvapi.ini` values SHALL be generated using the same configuration parameters as standard OptiScaler.
