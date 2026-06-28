## Why

Clicking the "Custom" preset card under the MangoHud presets tab copies `custom.conf` to `MangoHud.conf`, but fails to synchronize the GOverlay UI controls with the loaded settings. As a result, subsequent config saves overwrite `MangoHud.conf` with stale UI state, breaking the custom preset functionality (issue #336).

## What Changes

- Update `usercustomBitBtnClick` to invoke `LoadMangoHudConfig` after copying `custom.conf` so UI elements immediately reflect custom preset settings.
- Check `custom.conf` existence when interacting with or rendering the Custom preset card in the modern preset grid UI (`mangohud_ui.pas`).
- Ensure visual selection indicators correctly update on preset selection.

## Capabilities

### New Capabilities

- `mangohud-custom-preset`: Manages user-defined custom MangoHud presets, file copying, and UI synchronization.

### Modified Capabilities

(none)

## Impact

- `overlayunit.pas`: `usercustomBitBtnClick` procedure updated to trigger UI reload.
- `mangohud_ui.pas`: Custom preset card click handler and visual states updated.
