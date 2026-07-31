## 1. UI & Menu Layout

- [x] 1.1 In `overlayunit.lfm`, add `loadconfigMenuItem` (`TMenuItem`) to `popsaveMenu` above `saveoptionsItem`.
- [x] 1.2 In `overlayunit.pas`, declare `loadconfigMenuItem: TMenuItem` and method `procedure loadconfigMenuItemClick(Sender: TObject);`.

## 2. Menu Item Logic & Config Loading

- [x] 2.1 In `popupBitBtnClick` (`overlayunit.pas`), set `loadconfigMenuItem.Visible := True` for MangoHud, vkBasalt, and vkSumi tabs, and `loadconfigMenuItem.Visible := False` for OptiScaler and Tweaks tabs.
- [x] 2.2 Implement `loadconfigMenuItemClick` in `overlayunit.pas` to open `TOpenDialog`, copy selected `.conf` file to the active tool's target configuration path, and call `LoadMangoHudConfig`, `LoadVkBasaltConfig`, or `LoadVkSumiConfig`.

## 3. Verification

- [x] 3.1 Verify building GOverlay with `make`.
