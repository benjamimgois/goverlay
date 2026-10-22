## 1. Migration Health Detection Logic

- [x] 1.1 Implement migration health check routines in `lossless_scaling_tab.pas` checking for Steam beta DLL presence (`lsfg-vk.dll` vs `Lossless.dll`), legacy 1.x files (`/etc/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json`, `/usr/lib/liblsfg-vk.so`, `/usr/lib64/liblsfg-vk.so`), and outdated `conf.toml` syntax, and verify detection output.
- [x] 1.2 Implement legacy configuration backup and modernization helper in `lossless_scaling_tab.pas` to migrate `~/.config/lsfg-vk/conf.toml` to v2, verifying backup file creation.

## 2. Interactive Assistant Dialog

- [x] 2.1 Create `lsfg_migration_dialog.pas` modal form implementing the 4 guided steps with status indicators, instructions, and dark theme styling.
- [x] 2.2 Wire "Open Folder" button in `lsfg_migration_dialog.pas` using `OpenDocument` to reveal the Lossless Scaling Steam folder, verifying file manager launch.
- [x] 2.3 Implement elevated cleanup in `lsfg_migration_dialog.pas` using `pkexec rm -f` targeting known legacy 1.x system files, verifying error handling and status refresh.
- [x] 2.4 Wire "Update Config" button in `lsfg_migration_dialog.pas` to execute configuration modernization and refresh state.

## 3. Dynamic DLL Display and Tab Integration

- [x] 3.1 Implement dynamic DLL path swapping and validation in `lossless_scaling_tab.pas` for `FLsDllPathEdit`, file browse dialog, and status dot (`lsfg-vk.dll` when `imLsfg` is selected vs `Lossless.dll` when `imMako` is selected).
- [x] 3.2 Add `FLsMigrationAlertCard` with warning accent and "Migration Assistant" / "Fix Issues" button at the top of `lossless_scaling_tab.pas`.
- [x] 3.3 Integrate migration health check into tab initialization, method change events, and profile change events, dynamically showing or hiding `FLsMigrationAlertCard`.
- [x] 3.4 Connect `FLsMigrationAlertCard` action button to open `TLSFGVkMigrationDialog`.
- [x] 3.5 Add "lsfg-vk Migration Assistant" item to hamburger popup menu (`popsaveMenu`) directly below "Open log file", showing it when `lsfg-vk` is selected on Lossless Scaling tab and hiding it otherwise.

## 4. Testing and Verification

- [x] 4.1 Add automated test cases in `tests/gui/gui_test_cases.pas` verifying detection states, alert banner visibility, and dialog actions.
- [x] 4.2 Run `make test-logic` and `make test-gui` and verify all tests pass.
- [x] 4.3 Verify compilation with `lazbuild goverlay.lpi --widgetset=qt6`.
