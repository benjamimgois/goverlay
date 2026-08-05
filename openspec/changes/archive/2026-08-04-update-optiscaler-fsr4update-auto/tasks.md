## 1. Implementation

- [x] 1.1 In `overlay_config.pas` (`SaveOptiScalerConfig`), update `Fsr4UpdateValue := 'auto'` for Latest FSR version selection.
- [x] 1.2 In `overlay_config.pas` (`LoadOptiScalerConfig`), update `OptiCfg.GetValue(OPTI_KEY_FSR4_UPDATE, '')` to accept both `'auto'` and `'true'` when selecting Latest FSR version.
- [x] 1.3 In `overlayunit.lfm`, update the `fsrversionComboBox` hint to specify `Fsr4Update=auto`.

## 2. Verification & Testing

- [x] 2.1 In `tests/gui/gui_test_cases.pas`, update `TestOptiFsrVersionPinnedToLatest` assertion to verify `Fsr4Update=auto`.
- [x] 2.2 Run GUI test suite to verify all OptiScaler tests pass.
