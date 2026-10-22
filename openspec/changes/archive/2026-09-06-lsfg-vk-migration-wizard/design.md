## Context

Following the migration to `lsfg-vk` 2.0 (see `proposal.md`), users with previous `lsfg-vk 1.x` installs or default Steam branch configurations experience runtime crashes due to incompatible layers and missing `lsfg-vk.dll`. GOverlay needs a dedicated, resilient health inspection system and an interactive UI wizard to guide users to a functioning setup.

## Goals / Non-Goals

**Goals:**
- Provide instant, non-blocking inspection of the 3 key migration points: Steam beta branch, legacy system files, and user config.
- Display a clear, non-intrusive alert card on the Lossless Scaling tab when issues exist.
- Offer an interactive migration dialog with actionable guidance, folder opening, and one-click elevated cleanup via `pkexec`.
- Ensure all texts, labels, and explanations are strictly in English.

**Non-Goals:**
- Automatically modifying Steam's cloud/manifest settings without user participation (Steam controls beta branch switching via its own client).
- Removing distro packages directly via package managers (recommends commands instead of executing `pacman`/`apt`/`dnf` directly).

## Decisions

### 1. File-based Health Inspection vs CLI healthcheck
- **Decision**: Perform health checks directly via Pascal filesystem calls (`FileExists`, reading first few lines of `~/.config/lsfg-vk/conf.toml`) instead of executing `lsfg-vk-cli healthcheck`.
- **Rationale**: External process execution on the GUI thread can cause micro-stutters or fail in containerized/Flatpak environments. Direct file presence checks take < 1ms.
- **Alternatives considered**: Calling `lsfg-vk-cli healthcheck` in a background thread. Rejected because direct file checks are faster, simpler, and equally authoritative for the specific files in question.

### 2. Dialog Modularization (`lsfg_migration_dialog.pas`)
- **Decision**: Implement the assistant in a dedicated unit `lsfg_migration_dialog.pas` inheriting from `TForm`, styled consistently with GOverlay's theme (dark surface colors, SVG/canvas indicators, responsive layout).
- **Rationale**: Isolating the dialog code keeps `lossless_scaling_tab.pas` focused on overlay and profile configuration while allowing the dialog to be reused or summoned on-demand.
- **Alternatives considered**: Inlining an expandable panel in `lossless_scaling_tab.pas`. Rejected because modal guidance prevents user confusion while executing elevated commands or waiting for Steam updates.

### 3. Elevated Cleanup Command Architecture
- **Decision**: Use `pkexec` with a targeted list of legacy files:
  ```bash
  pkexec rm -f \
    /etc/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json \
    /usr/lib/liblsfg-vk.so \
    /usr/lib64/liblsfg-vk.so \
    /usr/bin/lsfg-vk-ui \
    /usr/share/applications/lsfg-vk-ui.desktop
  ```
- **Rationale**: Standard Linux desktop authorization protocol. Does not require hardcoding `sudo` or launching a terminal emulator.

### 4. Dynamic DLL Display and Validation in Software Status Card
- **Decision**: Dynamically switch the path and validation in `FLsDllPathEdit` between `lsfg-vk.dll` (for `imLsfg`) and `Lossless.dll` (for `imMako`). When switching methods in `SetInterpolationMethod`, automatically update the filename in `FLsDllPathEdit` (preserving the folder path), update `TextHint`, adjust `TOpenDialog` filter and title, and refresh styling via `StyleLosslessScalingDllPath` and status dots via `UpdateStatusCard`.
- **Rationale**: Upstream `lsfg-vk 2.0` strictly requires `lsfg-vk.dll` (which contains Vulkan bindless SPIR-V shaders) and fails if configured with `Lossless.dll`. Conversely, `MAKO` requires `Lossless.dll`. Displaying `Lossless.dll` while `lsfg-vk` is selected confuses users and masks whether the required Steam beta DLL exists.

## Risks / Trade-offs

- **[Risk] User cancels Polkit password prompt in pkexec** → **Mitigation**: Handle non-zero exit codes gracefully without crashing, display "Cleanup canceled or failed" in the status label, and keep the dialog open.
- **[Risk] Steam library on secondary drive** → **Mitigation**: Detect `lsfg-vk.dll` using the configured Lossless.dll directory, which already handles custom Steam library folders.
