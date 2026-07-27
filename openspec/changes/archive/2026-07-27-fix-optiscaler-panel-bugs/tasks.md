## 1. Driver Control Enforcement

- [x] 1.1 Update `LoadOptiScalerConfig` in `optiscaler_tab.pas` and `optiscalerLabelClick` in `overlayunit.pas` to check `nvidiaRadioButton.Checked` and enforce `Enabled := False` for `spoofCheckBox` and `forcereflexCheckBox` when Nvidia is selected.

## 2. Seed `fakenvapi.ini` on Save

- [x] 2.1 Update `SaveOptiScalerConfigCore` in `overlay_config.pas` to check if `fakenvapi.ini` exists in the target gameconfig directory, and copy it from the cache folder (`optiscaler-stable` / `optiscaler-edge`) if missing before loading and updating `FakeCfg`.

## 3. Instant Global Profile Sync

- [x] 3.1 Update OptiScaler save flow to execute `InitializeGlobalConfigDirectory` when saving the global profile, ensuring DLLs and plugins are immediately synced to `~/.local/share/goverlay/gameconfig/global/`.

## 4. FakeNVAPI Download Fallback Resilience

- [x] 4.1 Update `optiscaler_update.pas` to preserve or restore existing `fakenvapi.dll` and `fakenvapi.ini` in the cache directory if downloading or extracting the latest FakeNVAPI from GitHub fails.

## 5. Testing and Verification

- [x] 5.1 Add unit/GUI test cases in `tests/gui/gui_test_cases.pas` to verify control state after switching tabs with Nvidia selected, `fakenvapi.ini` seeding when missing, and global profile DLL sync.
- [x] 5.2 Run `make test` to confirm all tests pass cleanly.
