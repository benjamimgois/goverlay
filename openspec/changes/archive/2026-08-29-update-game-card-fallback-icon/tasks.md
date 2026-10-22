## 1. Core Fallback Generator Update

- [x] 1.1 Update `GenerateFallbackCover` in `games_tab.pas` to resolve high-res modern logo (`assets/icons/goverlay.png`, `data/icons/256x256/goverlay.png`) and render centered with `#20242C` background
- [x] 1.2 Update card cover loading in `games_tab.pas` to refresh legacy cached covers that have `.fallback` markers

## 2. Testing and Validation

- [x] 2.1 Add automated GUI test in `tests/gui/gui_test_cases.pas` to verify fallback cover generation and visual dimensions
- [x] 2.2 Run `make test-gui` and `make test-logic` to verify test suite passes
- [x] 2.3 Build release binary with `make goverlay`
