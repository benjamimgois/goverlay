## 1. Floating Action Dock Implementation

- [x] 1.1 Create `TFloatingActionDock` component/helper with pill geometry, dark translucent styling, and elevation shadow.
- [x] 1.2 Implement dynamic action buttons inside the dock: `FPreviewBtn` (`▶ Preview`), `FMenuBtn` (`☰`), and `FFinishBtn` (`✦ Finish Config`).
- [x] 1.3 Wire tab change events to update floating dock button visibility (show preview button on MangoHud/vkBasalt/vkSumi; hide on OptiScaler/EnvVars/Games).
- [x] 1.4 Deprecate/hide `goverlaybarPanel` — hidden permanently on all tabs; dock replaces it.

## 2. Finish Configuration Modal Dialog

- [x] 2.1 Create `finish_dialog.pas` unit and `TFinishDialogForm` with modern dark theme layout.
- [x] 2.2 Implement platform switcher for Steam and Heroic Games Launcher.
- [x] 2.3 Implement custom-rendered step-by-step procedural canvas animations for Steam and Heroic launch options setup.
- [x] 2.4 Implement syntax-styled launch command display box with `[ Copy ]` button and `[ Copied! ]` feedback.
- [x] 2.5 Wire `FFinishBtn` in the floating action dock to open `TFinishDialogForm`.

## 3. Floating Overlays (Auto-Save Toast & Download Progress)

- [x] 3.1 Implement floating auto-save toast notification in bottom-left corner with auto-fadeout in English (`✓ Settings saved`).
- [x] 3.2 Implement floating download progress banner at the top of the window with percentage and English status message.
- [x] 3.3 Connect background download tasks (DLSS Enabler startup, shaders) to the new floating progress banner.

## 4. Testing, Cleanup & Verification

- [x] 4.1 Update and adapt GUI unit tests in `tests/gui/` to validate the floating action dock and finish dialog.
- [x] 4.2 Verify project compilation and run test suite with `make`.
