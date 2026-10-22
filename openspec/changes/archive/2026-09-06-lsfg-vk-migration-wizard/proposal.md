## Why

The transition to `lsfg-vk` 2.0 introduces breaking runtime requirements: upstream dropped legacy DirectX shader bytecode in favor of a native Vulkan bindless pipeline, requiring users to switch the Lossless Scaling Steam application to the `lsfg-vk` beta branch to obtain `lsfg-vk.dll`, and deprecated the `lsfg-vk 1.x` layer. Users upgrading to 2.0 frequently experience silent launch failures and log errors ("The specified shader DLL does not exist" and "Configuration file version is not supported, expected 1") caused by lingering system-level 1.x implicit layers and unmigrated Steam installations. GOverlay needs an automated health check and interactive migration assistant to guide users through these steps and clean up legacy system artifacts seamlessly.

## What Changes

- Add automated, non-blocking health checks to detect:
  - Missing `lsfg-vk.dll` when only `Lossless.dll` is present in the Lossless Scaling Steam folder (indicating the user has not switched to the `lsfg-vk` beta branch).
  - Legacy `lsfg-vk 1.x` system files (`/etc/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json`, `/usr/lib/liblsfg-vk.so`, `/usr/lib64/liblsfg-vk.so`, `/usr/bin/lsfg-vk-ui`, and related desktop shortcuts).
  - Outdated user configuration (`~/.config/lsfg-vk/conf.toml` using `version = 1` or `[[game]]` schema).
- Add an alert banner/card on the Lossless Scaling tab when migration issues or conflicts are detected, offering a "Fix Issues" / "Migration Assistant" action.
- Implement an interactive **lsfg-vk 2.0 Migration & Health Assistant** dialog displaying:
  - Step 1: Clear step-by-step instructions on switching to the `lsfg-vk` beta branch in Steam Properties, with a button to open the installation folder.
  - Step 2: An action button to remove legacy 1.x system layers and libraries using elevated root permissions (`pkexec`), with real-time status update.
  - Step 3: Recommendation to remove legacy package manager packages (e.g., `lsfg-vk-git` via AUR/distro package managers).
  - Step 4: Automatic backup and reset of legacy user `conf.toml` to prevent layer schema parsing errors.
- Dynamically adapt the Lossless Scaling DLL path and status indicator in the Software Status card: display and validate `lsfg-vk.dll` when the `lsfg-vk` method is active, and display and validate `Lossless.dll` when the `MAKO` method is active.

## Capabilities

### New Capabilities
- `lsfg-vk-migration-assistant`: Automated detection of legacy `lsfg-vk 1.x` layer files, Steam beta branch missing binaries (`lsfg-vk.dll`), and outdated user configuration, coupled with an interactive Migration & Health Assistant dialog with Steam guidance, elevated cleanup (`pkexec`), and config migration.

### Modified Capabilities
- `lossless-scaling-config`: Dynamically display and validate `lsfg-vk.dll` or `Lossless.dll` in the Software Status card according to the active interpolation method.

## Impact

- `lossless_scaling_tab.pas`: Integration of non-blocking health check routine, warning alert card, and invocation of the migration dialog.
- `lsfg_migration_dialog.pas`: New dialog window presenting the step-by-step migration guide, interactive cleanup execution, and status feedback.
- `goverlay_system.pas`: Execution helper for safe elevated file cleanup via `pkexec`.
- GUI tests: Automated test coverage for health detection, alert state transitions, and config migration.
