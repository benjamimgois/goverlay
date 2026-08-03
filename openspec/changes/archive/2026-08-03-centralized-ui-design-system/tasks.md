# Tasks: Centralized UI Design System in themeunit

- [x] 1. Design System Tokens & API (`themeunit.pas`)
  - [x] 1.1 Add color, typography, and metric tokens to `themeunit.pas`.
  - [x] 1.2 Implement `TUiLabelRole` enum and `StyleLabel` procedure.
  - [x] 1.3 Implement `StyleMainCard`, `StyleSubCard`, `StyleInputControl`, `StyleToggleControl`, and `StyleActionButton` in `themeunit.pas`.

- [x] 2. Refactor OptiScaler Tab (`optiscaler_tab.pas`)
  - [x] 2.1 Replace local `DarkCombo`, `DarkCheck`, `DarkRadio`, `DarkLbl` with `themeunit` helpers.
  - [x] 2.2 Verify card and sub-card styling using `StyleMainCard` and `StyleSubCard`.

- [x] 3. Refactor vkBasalt Tab (`vkbasalt_tab.pas`)
  - [x] 3.1 Remove hardcoded `'Noto Sans'` font family assignment.
  - [x] 3.2 Update card headers and controls to use `themeunit` styling helpers.

- [x] 4. Refactor MangoHud Tab (`mangohud_ui.pas`)
  - [x] 4.1 Update `MakeCard` and sub-card styling to consume `themeunit` tokens.
  - [x] 4.2 Standardize control font sizes and row height baselines.

- [x] 5. Verification & Build Validation
  - [x] 5.1 Build project with `lazbuild goverlay.lpi --bm=Release --widgetset=qt6`.
  - [x] 5.2 Verify clean compilation and visual uniformity across all tabs.
