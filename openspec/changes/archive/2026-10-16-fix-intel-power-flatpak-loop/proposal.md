# Proposal: Fix Intel CPU Power Monitoring Flatpak Popup Loop

## Why

On systems with Intel CPUs running GOverlay inside Flatpak (such as Bazzite / SteamOS / Fedora Silverblue), launching the application or switching tabs causes an infinite loop of modal error popups stating *"Intel CPU power monitoring fix is not available in Flatpak."* This happens because programmatic updates to `cpupowerCheckBox.Checked` during config loading trigger LCL `OnClick` events without checking `FLoadingConfig`, and the proactive fix prompt does not check whether GOverlay is sandboxed inside Flatpak.

## What Changes

- **Guards in Event Handlers**: Add `if FLoadingConfig then Exit;` to `cpupowerCheckBoxClick` and `gamemodeCheckBoxClick` in `overlayunit.pas` so that programmatic config loads (startup, tab changes, preset loading) never trigger interactive fix prompts or warning dialogs.
- **Flatpak Proactive Check Bypass**: In `cpupowerCheckBoxClick`, skip the automatic invocation of `intelpowerfixBitBtnClick` when running inside Flatpak (`if IsRunningInFlatpak then Exit;`), as Flatpak cannot modify host permissions or run `pkexec` anyway.
- **Actionable Manual Flatpak Guidance**: When the user explicitly clicks `intelpowerfixBitBtn` inside Flatpak, provide the exact host shell command required to apply the udev rule / permissions on their host system (e.g. Bazzite/Fedora/Ubuntu), rather than just a dead-end message.
- **Unit and GUI Testing**: Add automated test cases covering `cpupowerCheckBoxClick` and `gamemodeCheckBoxClick` under simulated Intel CPU and Flatpak conditions, verifying that config loads never trigger modal dialogs.

## Capabilities

### New Capabilities
- `intel-cpu-power-monitoring-fix`: Reliable handling of Intel CPU power monitoring verification and user prompts, preventing automated popup loops during configuration loading and sandboxed execution.

### Modified Capabilities
<!-- None -->

## Impact

- **Affected files**:
  - `overlayunit.pas`: Add `FLoadingConfig` and `IsRunningInFlatpak` guards to `cpupowerCheckBoxClick`, add `FLoadingConfig` guard to `gamemodeCheckBoxClick`.
  - `goverlay_strings.pas`: Update `rsIntelFixNoFlatpak` with host shell instructions.
  - `languages/*.po` / `languages/goverlay.pot`: String catalog update for updated message.
  - `tests/gui/gui_test_cases.pas`: Add test cases for Intel power fix suppression during config load and Flatpak environments.
