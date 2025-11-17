# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Goverlay** is a graphical user interface (GUI) for managing Vulkan and OpenGL overlays on Linux. It provides configuration management for:
- **MangoHud** - Performance overlay for games
- **vkBasalt** - Post-processing effects for Vulkan applications
- **OptiScaler** - Frame generation and upscaling tools
- **ReShade shaders** - Custom visual effects

The application is written in **Object Pascal** using the **Lazarus IDE** and **Free Pascal Compiler (FPC)**, with Qt6 bindings for the GUI.

## Building and Running

### Build Commands

```bash
# Build the project
make

# Build with custom lazbuild options
make LAZBUILDOPTS="--cpu=x86_64"

# Run locally (creates start_goverlay.sh)
./start_goverlay.sh

# Clean build artifacts
make clean

# Install to system (default: /usr/local)
sudo make install

# Install to custom prefix
sudo make install prefix=/usr

# Uninstall
sudo make uninstall

# Run validation tests (requires appstreamcli and desktop-file-validate)
make tests

# Create distribution tarball
make tarball VERSION=1.6.1
```

### Running the Binary Directly

```bash
# After building
./goverlay
```

### Development Prerequisites

- **Lazarus IDE** - Primary development environment
- **Free Pascal Compiler (FPC)**
- **lazbuild** - Command-line build tool from Lazarus
- **qt6pas** - Qt6 bindings for Free Pascal

## Architecture

### Unit Structure

The application follows a form-based architecture with each major feature in its own unit:

**Core Units:**
- `overlayunit.pas` - Main application form (`Tgoverlayform`)
  - Contains the primary UI with tabbed interface for MangoHud, vkBasalt, and OptiScaler
  - Handles configuration file reading/writing for all overlay tools
  - Manages system detection (GPU, network interfaces, fonts)
  - Coordinates updates and git operations for ReShade shaders

**Feature Units:**
- `aboutunit.pas` - About dialog with credits and links
- `blacklistunit.pas` - Application blacklist management
- `optiscaler_update.pas` - OptiScaler installation and update management
- `customeffectsunit.pas` - Custom vkBasalt effects configuration
- `crosshairunit.pas` - Crosshair size configuration
- `logpathunit.pas` - MangoHud logging path configuration

**Helper Units:**
- `gfxlaunch.pas` - Launches pascube (OpenGL demo) with appropriate driver settings
- `atstringproc_htmlcolor.pas` - HTML color conversion utilities

### Configuration File Management

The application manages multiple configuration files:

1. **MangoHud** (`~/.config/MangoHud/MangoHud.conf`)
   - Main configuration loaded via `LoadMangoHudConfig()`
   - Custom presets stored in `custom.conf`
   - Uses key=value format with boolean flags

2. **vkBasalt** (`~/.config/vkBasalt/vkBasalt.conf`)
   - Effects list format: `effects=cas:fxaa:smaa`
   - Loaded via `LoadVkBasaltConfig()`
   - ReShade shader integration

3. **OptiScaler/fgmod** (`~/fgmod/`)
   - `fgmod` - Main script configuration
   - `OptiScaler.ini` - Upscaling and frame generation settings
   - `fakenvapi.ini` - NVIDIA API override settings
   - `goverlay.vars` - Version tracking file

### GPU and System Detection

**GPU Detection:**
- Uses `lspci` to detect GPU hardware
- Checks for NVIDIA driver via `lsmod | grep nvidia`
- Automatically sets color schemes based on GPU vendor (AMD red, NVIDIA green, Intel blue)

**Network Interface Detection:**
- Parses `ip link` output to enumerate network interfaces
- Filters for relevant types (eth*, enp*, wlan*, wlp*)
- Used for MangoHud network monitoring configuration

**Session Detection:**
- Determines X11 vs Wayland via environment variables
- Adjusts vkcube launch parameters accordingly

### Update and Installation System

**Goverlay Self-Update:**
- Checks GitHub API for latest release tag
- Compares semantic versions (handles v prefix)
- Only shows update button if remote version is newer
- Development builds (channel="git") never show updates

**OptiScaler Installation:**
- Downloads Decky-Framegen release from GitHub
- Extracts and reorganizes directory structure
- Downloads and integrates FakeNvapi
- Creates version tracking file (`goverlay.vars`)
- Progress tracking via `TProgressBar` with percentage display

**ReShade Shader Management:**
- Clones `benjamimgois/reshade-shaders` repository via git
- Real-time progress parsing from git output
- Recursive file listing with extension filtering

### Dark Theme Implementation

The application forces a dark theme on all UI elements:
- `SetDarkColorsRecursively()` in `aboutunit.pas` and `overlayunit.pas`
- Dark background color: `$0045403A` (BGR format)
- Applies to labels, checkboxes, groupboxes, etc.

### Color Management

Colors are handled in multiple formats:
- **TColor** (Delphi/Lazarus native)
- **HTML hex format** (`#RRGGBB`) via `SColorToHtmlColor()`
- **BGR format** for system colors
- `HexToColor()` converts hex strings to TColor

### Key Pascal/Lazarus Patterns

**String Handling:**
```pascal
// Use FPC string functions
SplitString(str, delimiter)  // Returns TStringDynArray
Trim(), Pos(), Copy()
SameText()  // Case-insensitive comparison
```

**Process Execution:**
```pascal
// Use TProcess for external commands
Process := TProcess.Create(nil);
Process.Executable := 'command';
Process.Parameters.Add('arg');
Process.Options := [poWaitOnExit, poUsePipes];
Process.Execute;
```

**File I/O:**
```pascal
// Use TStringList for file operations
Lines := TStringList.Create;
Lines.LoadFromFile(path);
Lines.SaveToFile(path);
```

## Code Comments

All code comments are in **English**. This is a recent standardization - older Portuguese comments have been translated.

## Testing

The `make tests` target validates:
- AppStream metadata (`io.github.benjamimgois.goverlay.metainfo.xml`)
- Desktop entry file (`io.github.benjamimgois.goverlay.desktop`)

No automated unit tests exist. Testing is primarily manual via the running application.

## Dependencies

**Runtime:**
- mangohud
- mesa-demos (provides vkcube for testing)
- vulkan-tools
- vkBasalt (optional, for post-processing)
- git (for ReShade shader cloning)
- qt6pas
- zenergy (optional, for AMD CPU metrics)
- pascube (spinning cube demo)
- wget (for downloads)
- 7z (for archive extraction)
- curl (for API requests)

## Configuration Paths

```
~/.config/MangoHud/MangoHud.conf      # MangoHud configuration
~/.config/MangoHud/custom.conf        # Custom preset
~/.config/goverlay/blacklist.conf     # Application blacklist
~/.config/goverlay/distro             # Distro detection cache
~/.config/vkBasalt/vkBasalt.conf      # vkBasalt configuration
~/fgmod/                               # OptiScaler installation
```

## Build Artifacts

The build process generates:
- `goverlay` - Main executable binary
- `start_goverlay.sh` - Local launcher script
- `lib/` - Compiled units and object files
- `backup/` - Lazarus backup files
- `goverlay.res` - Compiled resources
- `data/goverlay.sh` - System launcher script (install target)
