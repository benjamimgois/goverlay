# Tasks

## 1. Configuration & Module State Management

- [x] 1.1 Add module configuration keys and loader/saver helpers (`IsModuleEnabled`, `SetModuleEnabled`) reading/writing `[Modules]` in `goverlay.conf`. Verify that module settings serialize and deserialize correctly.
- [x] 1.2 Implement automatic migration for existing installations in `CheckAndUpdateConfigVersion` so users with pre-existing configurations or libraries have `FirstRunWizardCompleted` set to true without an unexpected first-run prompt. Verify logic test confirms migration behavior.

## 2. Scoped Startup Verification & Download Thread

- [x] 2.1 Refactor `HasMissingMandatoryLibraries` in `optiscaler_update.pas` to audit libraries only for currently active modules. Verify with tests that missing files for disabled modules return false and do not trigger downloads.
- [x] 2.2 Update `TStartupDownloadThread.Execute` to conditionally run downloads and installers only for active modules, and suppress/clean up unsolicited `.desktop` files generated in `~/.local/share/applications`. Verify with tests that disabled modules are not installed.

## 3. First-Run Onboarding Dialog & Settings Menu Integration

- [x] 3.1 Implement `TFirstRunSetupDialog` matching Goverlay's dark navy UI theme, featuring module toggle cards, explanations, and "Confirm & Continue" / "Keep MangoHud Only" actions. Verify the dialog opens on fresh launches and writes selections to `goverlay.conf`.
- [x] 3.2 Add a "Manage Integrations / Modules" option to the settings popup menu in `sidebar_nav.pas` that allows users to reopen the module manager dialog anytime. Verify the menu item opens the dialog and updates module state.

## 4. On-Demand Tab Placeholder Cards & Activation Flow

- [x] 4.1 Implement themed placeholder cards for disabled modules on the Upscalers, Frame Interpolation, and Post-processing tabs, showing feature descriptions and an "Enable & Download Components" button while hiding underlying options. Verify tab switches show the placeholder card when disabled.
- [x] 4.2 Connect the "Enable & Download Components" button to enable the module, trigger the download/setup progress asynchronously, and unhide the full tab controls once ready. Verify activation transitions smoothly without application restart.

## 5. Automated Tests & Verification

- [x] 5.1 Add test cases in `tests/logic/` and `tests/gui/` covering first-run dialog state, module persistence, scoped startup integrity checking, and on-demand card activation. Verify both `logic_tests` and `gui_tests` pass cleanly.
