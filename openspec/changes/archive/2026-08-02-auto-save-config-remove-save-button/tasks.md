# Tasks: Auto-Save Configuration & Remove Manual Save Button

- [x] 1. Add `FLoadingConfig: Boolean`, `autoSaveTimer: TTimer`, and `savedStatusLabel: TLabel` to `overlayunit.pas`.
- [x] 2. Wrap all `Load*Config` procedures in `overlayunit.pas`, `mangohud_ui.pas`, `optiscaler_tab.pas`, etc. with `FLoadingConfig` guard.
- [x] 3. Replace the manual Save button in `sidebar_nav.pas` with `savedStatusLabel` displaying `"✓ Saved"`.
- [x] 4. Implement auto-save triggers and 300ms debounce timer for sliders and text inputs across all tabs.
- [x] 5. Wire `savedStatusLabel` feedback to display `"✓ Saved"` when auto-save operations complete.
- [x] 6. Build and verify auto-save persistence, debouncing, loading guards, and status indicator.
