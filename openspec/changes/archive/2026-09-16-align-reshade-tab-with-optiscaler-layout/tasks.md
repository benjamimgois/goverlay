## 1. ReShade Tab Card Layout Reordering and Styling

- [x] 1.1 In `reshade_tab.pas`, update `BuildReShadeTab` to construct cards in the new hierarchy: `FConfigCard` ("Config") at the top, `FShadersCard` ("Shaders") in the middle, and `FStatusCard` ("Software status") at the bottom. Connect `OnPaint := @Tgoverlayform(FForm).SubCardPaint` and apply `StyleMainCard`. Verify compilation with `lazbuild goverlay.lpi`.
- [x] 1.2 In `reshade_tab.pas`, reparent `FOpenShadersBtn` into `FShadersCard` positioned at the top right of the card header, and update `ReflowReShadeTab` to dynamically compute its left offset and card widths upon window resizing. Verify tab layout reflows without overlapping.

## 2. Verification and Testing

- [x] 2.1 Update GUI test assertions in `tests/gui/gui_test_cases.pas` to test card hierarchy (`ConfigCard.Top < ShadersCard.Top < StatusCard.Top`), renamed titles, and `FOpenShadersBtn` parent assignment.
- [x] 2.2 Execute `make test` and `make all` to verify all test suites pass with 0 errors and all binaries build cleanly.
- [x] 2.3 Run `openspec validate align-reshade-tab-with-optiscaler-layout` and verify zero errors.

## 3. Config Card Interactive Key Capture and OptiScaler-style Dot Status Refinements

- [x] 3.1 Replace ReShade hotkey combobox with interactive "Toggle" capture button wired to `Tag = 7` in `CaptureFormKeyDown` (modal key capture with modifiers).
- [x] 3.2 Update "Software status" card to match OptiScaler pattern: status dot (green/gray), library name "ReShade" in bold, and version "6.4 (Add-on Edition)" in purple; remove Add-on notice and redundant DLL labels.
- [x] 3.3 Move OptiScaler co-existence notice to proxy DLL combobox hint, removing helper text labels to compact card height so the entire tab fits without scrolling.
- [x] 3.4 Add comprehensive GUI tests verifying ToggleBtn, StatDot, StatNameLbl, and StatVerLbl.
