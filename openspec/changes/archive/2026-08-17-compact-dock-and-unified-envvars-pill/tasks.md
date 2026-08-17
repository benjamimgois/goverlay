## 1. Floating Action Dock Enhancements

- [x] 1.1 In `floating_dock.pas`, integrate `FAddBtn` (`+ Add`) and add `OnAddClick` event handler property.
- [x] 1.2 In `floating_dock.pas`, update `UpdateForTab(AShowPreview, AShowMenu, AShowAdd: Boolean)` to support contextual combinations.
- [x] 1.3 In `floating_dock.pas`, apply compact sizing scale (dock height `38px`, button height `30px`, compact button widths and padding).
- [x] 1.4 In `floating_dock.pas`, render accent cyan fill exclusively on the `✦ Finish` button with neutral dark styling on `+ Add`, `▶ Preview`, and `☰ Menu`.

## 2. EnvVars Integration & FAB Cleanup

- [x] 2.1 In `tweaks_md3.pas`, remove standalone `FTweaksFABBtn` control and obsolete paint handler.
- [x] 2.2 In `overlayunit.pas`, wire `FFADock.OnAddClick` to `TweaksMD3FABClick`.
- [x] 2.3 In `overlayunit.pas`, update all tab switch handlers to invoke `FFADock.UpdateForTab(Preview, Menu, Add)` with precise flags.

## 3. Overlay Compact Sizing & Visual Polish

- [x] 3.1 In `floating_overlay.pas`, adjust `TFloatingToast` to compact dimensions (`136 × 28px`).
- [x] 3.2 In `floating_overlay.pas`, scale down `TFloatingProgressBanner` for consistent compact geometry.

## 4. Testing & Verification

- [x] 4.1 Update GUI unit tests in `tests/gui/gui_test_cases.pas` to validate dock `+ Add` button and compact dimensions.
- [x] 4.2 Run test suite with `make test` and verify clean build with `make`.
