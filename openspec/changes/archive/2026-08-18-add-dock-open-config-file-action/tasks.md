## 1. UI & Menu Additions

- [x] 1.1 In `overlayunit.lfm` and `overlayunit.pas`, declare and add `openConfigFileMenuItem: TMenuItem` as the top item of `popsaveMenu` with `Caption := 'Open config file'` and click handler `openConfigFileMenuItemClick`.
- [x] 1.2 In `overlayunit.pas` (`popupBitBtnClick`), ensure `openConfigFileMenuItem.Visible := True` across all configuration tabs.

## 2. Floating Dock Tab Configurations

- [x] 2.1 In `overlayunit.pas` (`optiscalerTabSheetShow`), configure `FFADock.UpdateForTab(False, True, False)` to show the hamburger menu.
- [x] 2.2 In `overlayunit.pas` (`losslessScalingTabSheetShow`), configure `FFADock.UpdateForTab(True, True, False)` to show the hamburger menu.
- [x] 2.3 In `overlayunit.pas` (`tweaksLabelClick`), configure `FFADock.UpdateForTab(False, True, True)` to show the hamburger menu alongside `+ Add`.

## 3. Config File Resolution & Opening Logic

- [x] 3.1 In `overlayunit.pas`, implement `openConfigFileMenuItemClick` to resolve the active tab and profile context to the correct target configuration file (`MangoHud.conf`, `vkBasalt.conf`, `vkSumi.conf`, `OptiScaler.ini`, `lsfg.toml`, or `bgmod.conf`).
- [x] 3.2 In `openConfigFileMenuItemClick`, ensure parent directories exist, trigger an active tab save if the file does not exist on disk, and execute `xdg-open` asynchronously.

## 4. Verification & Testing

- [x] 4.1 In `tests/gui/gui_test_cases.pas`, add GUI test cases verifying hamburger menu visibility across all tabs and correct config path resolution.
- [x] 4.2 Run test suites (`make test-logic`, `make test-gui`) and build release binary.
