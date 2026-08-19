## 1. OptiScaler Tab Event Handler and Form Wiring
- [x] 1.1 In `overlayunit.pas`, declare and implement `procedure optiscalerTabSheetShow(Sender: TObject)` to update `FFADock.UpdateForTab(False, False, False)`, refresh enabled states, load OptiScaler config, and reflow the tab.
- [x] 1.2 In `overlayunit.pas` (`FormCreate`), assign `optiscalerTabSheet.OnShow := @optiscalerTabSheetShow;`.

## 2. Navigation Handler Symmetrization
- [x] 2.1 In `overlayunit.pas` (`optiscalerLabelClick`), update logic to ensure `ActivePage` delegates cleanly to the active sub-tab's show handler.

## 3. Testing and Verification
- [x] 3.1 In `tests/gui/gui_test_cases.pas`, add or update tests to verify tab switching between OptiScaler and Lossless Scaling properly shows/hides the Preview dock button.
- [x] 3.2 Run test suites (`make test-logic`, `make test-gui`) and compile release binary.
