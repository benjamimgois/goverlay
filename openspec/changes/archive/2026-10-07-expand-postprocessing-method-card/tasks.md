# Tasks

## 1. Method and Options Card Initialization

- [x] 1.1 Update `FMethodCard` and `FConfigCard` styling in `reshade_tab.pas` to prepare for full-width layout and compact single-row options
- [x] 1.2 Update `ApplyMethodSelection` in `reshade_tab.pas` to ensure `FVkToggleCard` remains hidden (`Visible := False`) when `rmVkBasalt` is selected

## 2. Reflow Layout Implementation

- [x] 2.1 Implement 3-slot symmetrical layout for `FMethodCard` in `ReflowReShadeTab` spanning full content width (`CW`)
- [x] 2.2 Implement compact horizontal layout for `FConfigCard` (`OPTIONS_H = 72`) spanning full width below `FMethodCard` in `rmReshade`
- [x] 2.3 Implement vkBasalt reflow in `rmVkBasalt` positioning `FVkReshadeCard` directly beneath `FMethodCard` with expanded vertical space and no `FVkToggleCard`
- [x] 2.4 Verify `rmNone` layout correctly positions notice label and software status card below full-width `FMethodCard`

## 3. Testing and Verification

- [x] 3.1 Update GUI test assertions in `tests/gui/gui_test_cases.pas` to reflect the new layout and verify `make test` passes without regression
- [x] 3.2 Build and verify Goverlay application visually or via headless tests
