## 1. Floating Dock Refactor

- [x] 1.1 Update `TFloatingActionDock` in `floating_dock.pas` to use unified single-surface rendering on `FPillBox`, eliminating separate child `TPaintBox` widgets and removing hard `(0, 0, 0)` drop shadow
- [x] 1.2 Implement precise semicircular corner radius `Rad := PB.Height div 2` (19px) and dynamic background filling with `FParent.Color` (`#161A28` / `#F5F5F5`)
- [x] 1.3 Implement coordinate-based hit-testing (`GetButtonAt`) and state handling for Menu, Preview, Add, and Finish buttons

## 2. Verification

- [x] 2.1 Rebuild GUI test suite and run all test cases with `lazbuild --ws=qt6 tests/gui/gui_tests.lpi && ./tests/gui/gui_tests --all`
- [x] 2.2 Rebuild main application binary with `lazbuild --ws=qt6 goverlay.lpi` and verify clean execution
