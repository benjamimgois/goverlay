## 1. Lossless Scaling Configuration & Template Generation

- [x] 1.1 Update `WriteLsfgTomlConfig` and `SaveLosslessConfig` in `lossless_scaling_tab.pas` to ensure complete TOML structure with `pascube` and `vkcube` entries is reliably generated, and verify with unit tests.
- [x] 1.2 Update `openConfigFileMenuItemClick` in `overlayunit.pas` to synchronize active Lossless Scaling GUI options to `lsfg.toml` before opening in the external editor, and verify behavior.

## 2. Verification & Testing

- [x] 2.1 Add automated test cases in `tests/gui/gui_test_cases.pas` asserting `pascube` presence in generated `lsfg.toml` and verify `openConfigFileMenuItem` synchronizes before launch.
- [x] 2.2 Build project and run test suite to verify all checks pass cleanly.
