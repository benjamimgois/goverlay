## 1. Tooltip Hint Correction

- [x] 1.1 Update `vsyncComboBox` tooltip text in `hintsunit.pas` to match MangoHud Vulkan VSync spec (0 = Adaptive, 1 = Off, 2 = Mailbox mode, 3 = On).

## 2. Configuration Saving & Loading Logic

- [x] 2.1 Update `SaveMangoHudConfigCore` in `overlay_config.pas` so that index 4 ("Unset") for `VsyncItemIndex` and `GlvsyncItemIndex` omits `vsync` and `gl_vsync` from `MangoHud.conf`.
- [x] 2.2 Verify `mangohud_ui.pas` loads omitted VSync options as Unset (index 4) and maintains backward compatibility if `vsync=4` or `gl_vsync=4` is present in existing config files.

## 3. Test Verification

- [x] 3.1 Update unit and GUI tests in `tests/` to assert correct hint string for Vulkan VSync and verify "Unset" omission behavior in `MangoHud.conf`.
- [x] 3.2 Run test suite (`make test`) and ensure clean pass.
