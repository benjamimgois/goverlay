# Tasks

## 1. Captions & Semantic Palette Updates

- [x] 1.1 In `mangohud_ui.pas` (`InitMetricsTab`), update captions for all 8 sub-card labels to use `▌ ` accent badges instead of emojis.
- [x] 1.2 In `mangohud_ui.pas` (`UpdateMetricsCardTheme`), assign subsystem-specific accent colors for Core, Thermals, Power, Hardware, Memory, and Storage (with high-contrast dark and light theme values).

## 2. Verification

- [x] 2.1 Compile the project with `lazbuild goverlay.lpi` and verify zero errors.
- [x] 2.2 Run the GUI test suite (`./tests/gui/gui_tests --all`) and confirm all tests pass without regressions.
