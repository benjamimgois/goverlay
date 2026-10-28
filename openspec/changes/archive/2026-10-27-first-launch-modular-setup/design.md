# Design

## Context

See `proposal.md` for background and motivation.
Currently, Goverlay's `StartupDownloadsAsync` unconditionally triggers `HasMissingMandatoryLibraries` on every application start, verifying and downloading binaries, shaders, and Vulkan layers for OptiScaler, DLSS Enabler, FSR4, HelixSR, vkSumi, vkNemu, MAKO, lsfg-vk, AFMF, and ReShade. Goverlay stores general preferences in `~/.config/goverlay/goverlay.conf` using FreePascal's `TIniFile`.

## Goals / Non-Goals

**Goals:**
- Provide a clean, dark-navy themed `TFirstRunSetupDialog` on first launch with toggle cards and explanations for each optional module.
- Persist module enablement flags in `goverlay.conf` (`[Modules]` section).
- Update `HasMissingMandatoryLibraries` and `TStartupDownloadThread.Execute` to only check and download files for enabled modules.
- Maintain full visibility of all tabs in the navigation rail, showing an on-demand activation placeholder card with an "Enable & Download Components" button when navigating to a disabled module tab.
- Add an entry in the settings popup menu (☰) to re-open the module manager dialog.
- Automatically migrate existing users so existing installations do not suffer disruptive resets or unexpected first-run popups.

**Non-Goals:**
- Removing or deprecating any tool: all existing integrations (OptiScaler, Lossless Scaling, ReShade, etc.) remain fully functional when their module is enabled.
- Modifying game profile configuration logic: only the global availability/download of components is made modular.

## Decisions

### 1. Configuration Schema in `goverlay.conf`
- **Decision**: Store module flags under `[Modules]` in `goverlay.conf`:
  ```ini
  [General]
  FirstRunWizardCompleted=1

  [Modules]
  PostProcessing=1
  Upscalers=1
  FrameGeneration=1
  ```
- **Rationale**: Keeps module configurations isolated from tool-specific sections, clean to read and parse via `TIniFile`.
- **Alternatives considered**: Storing flags in `bgmod.conf` or `goverlay.vars` — rejected because `goverlay.conf` is Goverlay's authoritative GUI configuration file.

### 2. First-Run Setup Dialog (`TFirstRunSetupDialog`)
- **Decision**: Implement a dedicated dialog form `TFirstRunSetupDialog` adhering to Goverlay's slate-navy styling (`RGBToColor(22, 26, 40)`), rounded cards, toggle checkboxes, and clear descriptions.
  - Contains toggles for:
    1. **Post-Processing & Shaders** (vkBasalt, ReShade, vkSumi)
    2. **Upscaling Ecosystem** (OptiScaler, DLSS Enabler, HelixSR, FSR4)
    3. **Frame Generation & Interpolation** (lsfg-vk, MAKO, AFMF)
  - Bottom actions: "Confirm & Continue" and "Keep MangoHud Only".
- **Rationale**: A modal dialog on first start is standard, intuitive, and prevents background downloads before the user expresses their intent.

### 3. Existing User Migration
- **Decision**: In `CheckAndUpdateConfigVersion`, if `FirstRunWizardCompleted` is not present:
  - Check if any non-core components exist (e.g. `bgmod` directory, OptiScaler DLLs, ReShade, etc.).
  - If existing components or active game profiles exist, mark `FirstRunWizardCompleted=1` and enable all modules whose files already exist.
  - If no prior configuration exists (fresh install), leave `FirstRunWizardCompleted=0` so the onboarding wizard triggers.
- **Rationale**: Avoids presenting the first-run dialog to long-time users while correctly welcoming new users.

### 4. Scoped Startup Integrity Checks
- **Decision**: In `optiscaler_update.pas`:
  - Pass the active module configuration into `HasMissingMandatoryLibraries`.
  - Only audit OptiScaler/DLSS/FSR4 when `Upscalers=1`.
  - Only audit ReShade/vkBasalt/vkSumi when `PostProcessing=1`.
  - Only audit MAKO/lsfg-vk/afmf when `FrameGeneration=1`.
  - In `TStartupDownloadThread.Execute`, conditionally call `CheckAndInstall*` only for active modules.
- **Rationale**: Guarantees fast, silent startups with zero unwanted network activity or disk writes for users who only want MangoHud.

### 5. On-Demand Tab Placeholder Cards
- **Decision**: For disabled tabs (e.g. `optiscalertabsheet`, `losslessScalingTabSheet`, `vkbasaltTabSheet` / `reshadeTabSheet`):
  - When the tab is shown, if its module is disabled, show a centered modern placeholder card and hide the underlying settings controls.
  - The card features the tool logo/icon, a descriptive explanation of what the tool provides, and an **"Enable & Download Components"** button.
  - Clicking the button enables the module in `goverlay.conf`, invokes the download splash or progress runner, and reveals the controls upon completion.
- **Rationale**: Matches the user's explicit preference ("continuar visível exibindo um card para ativação") and avoids confusing empty tabs.

### 6. Settings Menu Integration
- **Decision**: Add `TMenuItem` "Manage Integrations / Modules" to `settingsMenu` in `sidebar_nav.pas`.
- **Rationale**: Gives users an effortless way to adjust their installed modules at any time without having to edit config files manually.

## Risks / Trade-offs

- **[Risk]** User enables a module via the on-demand card while offline.
  - **Mitigation**: Downloads run through `TStartupDownloadThread` with standard network failure handling and error notification toasts.
- **[Risk]** Test suite regressions if automated tests assume all tabs have active controls immediately.
  - **Mitigation**: In test mode (`GOVERLAY_TEST=1`), either enable all modules by default or add specific unit tests for both enabled and disabled module states.
- **[Risk]** MAKO or other installers polluting application menus.
  - **Mitigation**: Suppress or remove unsolicited `.desktop` files in `~/.local/share/applications` when installing optional components.
