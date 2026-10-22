# Tasks

## 1. Sidebar Navigation Rail Updates

- [x] 1.1 Update navigation item caption in `sidebar_nav.pas` from `'EnvVars'` to `'Tweaks'`, verifying correct sidebar label rendering.

## 2. Info Chip Banner & Card Layout

- [x] 2.1 Implement dedicated Info Chip banner rendering (`BANNER_H = 34`) in `tweaks_md3.pas` with contextual text and cyan info icon before the custom cards section.
- [x] 2.2 Revert Custom Variables and Launch Arguments card headers to standard single-line `CARD_HDR_H = 32`, and update `MouseMove` / `MouseDown` hit-testing to offset for `BANNER_H + CARD_GAP`.

## 3. Verification and Regression Testing

- [x] 3.1 Update GUI test assertions in `tests/gui/gui_test_cases.pas` to verify `'Tweaks'` tab navigation and banner rendering in Global and per-game modes.
- [x] 3.2 Run full test suite (`make test-logic` and `make test-gui`) and ensure all tests pass cleanly.
