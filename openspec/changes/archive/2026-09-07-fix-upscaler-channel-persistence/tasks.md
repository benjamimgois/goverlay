## 1. Channel Persistence and UI Synchronization

- [x] 1.1 Wire `StartAutoSaveTimer` and `LoadVersionsFromFile` into `Tgoverlayform.optversionComboBoxChange` in `overlayunit.pas` and verify compilation succeeds
- [x] 1.2 Update `TOptiscalerTab.InitializeTab` in `optiscaler_update.pas` to resolve the active game profile name instead of hardcoding `''` and verify compilation succeeds
- [x] 1.3 Update fallback cache paths in `LoadVersionsFromFile` in `optiscaler_update.pas` to respect `FOptVersionComboBox.ItemIndex` and verify compilation succeeds
- [x] 1.4 Pass `IsStable` in `TSidebarNavHelper.CopyOptiScalerGameFiles` in `sidebar_nav.pas` when calling `GetDlssEnablerPath(IsStable)` and verify compilation succeeds

## 2. Automated Tests & Verification

- [x] 2.1 Add automated GUI tests in `tests/gui/gui_test_cases.pas` covering per-game channel selection persistence (`OPT_CHANNEL=1`) across profile loads and in-card version label synchronization
- [x] 2.2 Run `make test-logic` and `make test-gui` to verify 100% pass with zero failures
