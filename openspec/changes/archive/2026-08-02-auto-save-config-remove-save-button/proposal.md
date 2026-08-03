# Change Proposal: Auto-Save Configuration & Remove Manual Save Button

## Why
Modern desktop applications auto-persist user settings instantly without requiring manual "Save" button clicks. Removing the manual Save button in GOverlay streamlines the UX, prevents lost settings when switching tabs or closing the app, and frees up visual space in the navigation sidebar.

## What
- Remove the manual "Save" button (`saveBitBtn` / `SaveBtn`) from `sidebar_nav.pas` and `overlayunit.pas`.
- Add a subtle status indicator ("✓ Saved") in English that provides visual confirmation whenever settings are auto-persisted.
- Implement auto-save triggers across all tabs (MangoHud, OptiScaler, VkBasalt, EnvVars, Presets) on control state changes.
- Add a `FLoadingConfig` guard flag to ensure UI population from disk during tab or game switches does not fire auto-save.
- Implement a 300ms debounce timer for sliders and text input fields to prevent high-frequency disk writes while typing or dragging sliders.
