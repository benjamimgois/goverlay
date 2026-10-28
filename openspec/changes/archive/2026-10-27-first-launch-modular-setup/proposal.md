# Proposal

## Why

Currently, Goverlay automatically downloads, installs, and verifies a monolithic set of over 15 companion tools, Vulkan layers, and runtimes (OptiScaler, DLSS Enabler, FSR4, HelixSR, vkSumi, vkNemu, MAKO, lsfg-vk, AFMF, ReShade, and shaders) on every application launch. Users who only use Goverlay to configure MangoHud experience long boot-splash downloads, hundreds of megabytes of unwanted disk usage, unexpected system application menu shortcuts (such as MAKO `.desktop` files), and unnecessary implicit Vulkan layers. Users in issue #454 requested an opt-in experience on first launch to select which modules to enable, keeping unselected tabs available with on-demand activation cards.

## What Changes

- **First-Launch Modular Onboarding Dialog**:
  - When Goverlay starts for the first time (`FirstRunWizardCompleted=False` in `goverlay.conf`), present a sleek, themed dialog with toggle cards for optional functional modules:
    - **MangoHud (Core)**: Always available by default (system package overlay/benchmarking, no heavy external downloads).
    - **Post-Processing & Shaders**: vkBasalt shaders repo, ReShade runtime DLLs & default shaders, vkSumi color grading.
    - **Upscaling Ecosystem**: OptiScaler core, DLSS Enabler, HelixSR runtime, central FSR4 builds, and OptiPatcher.
    - **Frame Generation & Interpolation**: Lossless Scaling (lsfg-vk), MAKO Renderer, and afmf-linux.
  - Clear descriptions for each module explaining its capabilities, disk/download footprint, and system touch points.
  - Buttons to "Confirm & Continue" or "Keep MangoHud Only".
- **Module Preference Persistence**:
  - Store module preferences under `[Modules]` in `goverlay.conf` (`PostProcessing=0|1`, `Upscalers=0|1`, `FrameGeneration=0|1`, `FirstRunWizardCompleted=1`).
  - Automatically migrate existing users who already have configurations or downloaded libraries so their workflow is not interrupted.
- **Scaped Startup Verification**:
  - Update `HasMissingMandatoryLibraries` and `TStartupDownloadThread` so they only audit and download libraries corresponding to user-enabled modules.
  - If only MangoHud is active, bypass startup downloads completely and boot instantaneously.
- **On-Demand Activation Cards on Tabs**:
  - Keep all navigation rail tabs visible in the sidebar.
  - When the user navigates to a tab whose corresponding module is disabled (e.g., Upscalers or Frame Interpolation), display an attractive themed empty-state card explaining the feature with an **"Enable & Download Components"** button.
- **Settings Menu Module Manager**:
  - Provide a menu entry in the settings dropdown (☰) titled "Manage Integrations / Modules" allowing users to toggle modules and trigger downloads or cleanups at any time.

## Capabilities

### New Capabilities
- `first-launch-modular-setup`: Manages the first-run onboarding modal, persistence of enabled module flags, the settings menu module manager, and the on-demand activation placeholder cards on disabled tabs.

### Modified Capabilities
- `startup-libraries-verification`: Scopes mandatory startup library checks and self-healing downloads exclusively to currently enabled modules rather than checking all libraries unconditionally.

## Impact

- `overlayunit.pas`: Integration of first-run check, onboarding dialog invocation, on-demand tab placeholder rendering, settings menu entry, and scoping of `StartupDownloadsAsync`.
- `optiscaler_update.pas`: Refactoring `HasMissingMandatoryLibraries` and `TStartupDownloadThread.Execute` to inspect module state before auditing/downloading files.
- `sidebar_nav.pas`: Adding the module manager menu item to the settings popup menu.
- `goverlay.conf`: Adds section `[Modules]` with boolean keys for optional components.
- Automated tests: GUI and logic test suites in `tests/gui/` and `tests/logic/` updated to verify modular startup behavior and first-run dialog state transitions.
