# Tasks

## 1. Warning Banner Component & Dependency Evaluation

- [x] 1.1 Implement the warning banner factory helper in `overlayunit.pas` with theme styling, warning icon, environment-aware install instructions (Flatpak extension command vs native package manager), "View Status" button, and "Re-check" button
- [x] 1.2 Implement `UpdateToolMissingDependencyBanners` in `overlayunit.pas` to evaluate system presence of MangoHud, vkBasalt, vkSumi, Korthos low latency, and GameMode, and refresh UI state

## 2. Tab Integration & Control Deactivation

- [x] 2.1 Integrate MangoHud warning banner into the MangoHud view; disable MangoHud controls and the Save button when MangoHud is missing
- [x] 2.2 Integrate vkBasalt warning banner in `reshade_tab.pas` / `vkbasalt_tab.pas`; display banner and disable vkBasalt cards and Save button when `rmVkBasalt` is active without vkBasalt, and hide when switching to ReShade or None
- [x] 2.3 Integrate vkSumi warning banner in `vkbasalt_tab.pas`; display banner, shift cards downward, disable vkSumi cards and Save button when vkSumi is missing
- [x] 2.4 Integrate Tweaks on-hover banner in `overlayunit.pas` and `tweaks_md3.pas`; display warning banner dynamically only when hovering over missing dependency items (Korthos low latency, GameMode), dim missing toggles, and block click interactions

## 3. Test Verification

- [x] 3.1 Add automated GUI tests in `tests/gui/gui_test_cases.pas` verifying banner visibility, control disabling, method-switching reactivity, Tweaks on-hover banner behavior, and re-check actions for MangoHud, vkBasalt, vkSumi, and Tweaks
- [x] 3.2 Run `make test-gui`, `make test-logic`, and `make goverlay` to verify all tests pass (0 failures, 0 errors) and compilation succeeds without errors
