# Technical Design: Fix Intel CPU Power Monitoring Flatpak Loop

## Context

In Lazarus LCL, assigning `TCheckBox.Checked := True` invokes `OnClick`. While GOverlay maintains an `FLoadingConfig` boolean flag across configuration load sequences (such as `LoadMangoHudConfig`), `cpupowerCheckBoxClick` and `gamemodeCheckBoxClick` were implemented without inspecting `FLoadingConfig`.

When `cpu_power` is active in `MangoHud.conf` (which is present in the default template), launching GOverlay or switching tabs in Flatpak triggers `intelpowerfixBitBtnClick` immediately, which calls `ShowMessage(rsIntelFixNoFlatpak)` in a loop.

## Goals / Non-Goals

**Goals:**
- Completely prevent modal popup loops during application launch, tab switching, and preset loading.
- Guard `cpupowerCheckBoxClick` and `gamemodeCheckBoxClick` against running during `FLoadingConfig`.
- Bypass proactive Intel power fix triggers when running inside Flatpak.
- Provide actionable copy-paste terminal instructions when the user manually clicks `intelpowerfixBitBtn` in Flatpak.
- Add regression test coverage for config load suppression and Flatpak bypass logic.

**Non-Goals:**
- Do not attempt to modify host `/sys` or `/etc` from within the Flatpak sandbox.
- Do not alter the native execution flow of `intelpowerfixBitBtnClick` for native installations (which use `pkexec`).

## Decisions

### Decision 1: Guard Event Handlers with `FLoadingConfig`
- **Choice**: Place `if FLoadingConfig then Exit;` as the first statement in `cpupowerCheckBoxClick` and `gamemodeCheckBoxClick`.
- **Rationale**: Follows the standard pattern used across GOverlay's controls. Prevents any programmatic state updates during startup or config parsing from executing interactive logic.
- **Alternatives considered**: Detaching and reattaching `.OnClick` handlers around config loading. Rejected because `FLoadingConfig` is already standard, thread-safe, and less error-prone.

### Decision 2: Bypass Proactive Prompt in Flatpak Sandbox
- **Choice**: In `cpupowerCheckBoxClick`, add `if IsRunningInFlatpak then Exit;` before checking `/sys/class/powercap/intel-rapl:0/energy_uj` accessibility.
- **Rationale**: Since Flatpak cannot run `pkexec` or write to host udev rules, automatically interrupting the user with a modal dialog whenever they toggle the CPU power metric is disruptive and unhelpful. The status icon (`intelpowerfixBitBtn`) remains accessible if they want to investigate.

### Decision 3: Actionable Instructions in Flatpak Manual Dialog
- **Choice**: Enhance `rsIntelFixNoFlatpak` in `goverlay_strings.pas` to include the host shell command for applying the persistent udev rule:
  ```bash
  echo 'ACTION=="add|change", SUBSYSTEM=="powercap", KERNEL=="intel-rapl*", RUN+="/bin/chmod o+r /sys/%p/energy_uj"' | sudo tee /etc/udev/rules.d/70-intel-rapl.rules && sudo udevadm control --reload-rules && sudo udevadm trigger
  ```
- **Rationale**: Gives users running Bazzite, SteamOS, or Fedora Silverblue a clear, working one-liner to run in a host terminal.

## Risks / Trade-offs

- **[Risk]** Test runner runs on AMD hardware (`IsIntelCPU = False`), which historically allowed this bug to pass unnoticed.
  - **Mitigation**: Introduce a dedicated GUI/unit test that simulates `cpupowerCheckBoxClick` with `FLoadingConfig = True` and mocks `IsRunningInFlatpak` conditions to verify no modal popups or external processes are invoked.
