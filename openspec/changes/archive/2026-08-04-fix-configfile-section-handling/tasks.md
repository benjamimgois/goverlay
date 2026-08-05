## 1. TConfigFile Section Normalization

- [x] 1.1 Implement `CleanSectionName` helper function in `configfile.pas`.
- [x] 1.2 Update `FindLineIndexInSection`, `HasSection`, and `FindSectionIndex` in `configfile.pas` to use `CleanSectionName`.
- [x] 1.3 Update `SetValue` in `configfile.pas` to insert new keys at section end and write bracketed section headers `[SectionName]` when creating missing sections.

## 2. OptiScaler Config Constants & FrameGen Serialization

- [x] 2.1 Declare `OPTI_INI_SECTION_FRAMEGEN = '[FrameGen]'` in `configkeys.pas`.
- [x] 2.2 Update `SaveOptiScalerConfigCore` and `LoadOptiScalerConfig` in `overlay_config.pas` to use `OPTI_INI_SECTION_FRAMEGEN`.

## 3. Verification & Testing

- [x] 3.1 Add unit tests in `tests/gui/gui_test_cases.pas` to verify section matching with and without brackets and verify section header creation.
- [x] 3.2 Run test suite (`lazbuild -B goverlay.lpi --bm=Release && make test`) and verify 50/50 tests pass.
