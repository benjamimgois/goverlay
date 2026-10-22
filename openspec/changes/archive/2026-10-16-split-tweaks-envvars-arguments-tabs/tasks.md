# Tasks: Split Tweaks into EnvVars and Arguments Sub-tabs

## 1. UI Structure & Sub-Tabs in Form and Navigation

- [x] 1.1 Update `tweaksTabSheet` caption to `'EnvVars'` and instantiate `launchArgsTabSheet: TTabSheet` with caption `'Arguments'` in `goverlayPageControl`. Verify tabs are present in `goverlayPageControl`.
- [x] 1.2 Update navigation logic in `sidebar_nav.pas` and `overlayunit.pas` (`tweaksLabelClick`) to set `goverlayPageControl.ShowTabs := True` when selecting Tweaks, and manage switching between EnvVars and Arguments. Verify sidebar navigation correctly displays sub-tabs.

## 2. Arguments Tab UI & MD3 Card Rendering

- [x] 2.1 Create `argsScrollBox: TScrollBox` and `FArgsPaintBox: TPaintBox` on `launchArgsTabSheet` matching the geometry and layout of `tweaksScrollBox`. Verify paintbox mounts and scales on window resize.
- [x] 2.2 Update `tweaks_md3.pas` rendering: restrict `FTweaksPB` to environment variable categories (General, Graphics, Performance, Latency, Experimental, Custom Variables), and implement two distinct cards on `FArgsPaintBox` ("Predefined Arguments" and "Custom Arguments"). Verify visual rendering of both tabs.
- [x] 2.3 Implement separate hit-testing, mouse events (MouseDown, MouseMove, MouseWheel), and scroll handling for `FArgsPaintBox` in `tweaks_md3.pas`. Verify argument toggles and custom argument deletion work correctly.

## 3. Contextual Add Action (+ / FAB)

- [x] 3.1 Refactor `AddCustomVarBtnClick` in `overlayunit.pas` to route contextually based on `goverlayPageControl.ActivePage`: prompt and validate for `KEY=VALUE` when on `EnvVars`, and prompt and validate for `-...` / `+...` when on `Arguments`. Verify adding entries to each tab via the floating button.

## 4. Verification and Automated Tests

- [x] 4.1 Update GUI test cases in `tests/gui/gui_test_cases.pas` covering Tweaks sub-tabs, Arguments card rendering, and contextual Add action routing. Verify all tests pass with `make test`.

## Workflow follow-up

- Archive the change after user review and testing (`openspec archive`).
- Commit and push changes following Conventional Commits.
