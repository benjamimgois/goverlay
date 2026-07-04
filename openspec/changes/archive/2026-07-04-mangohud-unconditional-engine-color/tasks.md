## 1. MangoHUD Config Core Changes

- [x] 1.1 Extract `engine_color` from the `if Settings.EngineVersion then` block in `SaveMangoHudConfigCore` inside `overlay_config.pas`.
- [x] 1.2 Write `engine_color` unconditionally in `SaveMangoHudConfigCore`.

## 2. Verification

- [x] 2.1 Recompile the GOverlay application.
- [x] 2.2 Verify that `engine_color` is always written to `MangoHud.conf` when color presets are applied.
