## Context

GOverlay provides configuration loaders for vkBasalt, OptiScaler, Tweaks, and MangoHud. The loaders for vkBasalt, OptiScaler, and Tweaks reset all UI control states before parsing their configuration files. However, the MangoHud configuration loader does not reset its UI controls (such as checkboxes, text boxes, and color buttons) before parsing. This causes any settings not explicitly specified in the newly loaded configuration file to retain the values from the previously loaded file.

## Goals / Non-Goals

**Goals:**
- Implement a method `ResetMangoHudControls` on the `TMangoHudUiHelper` class.
- Invoke this method inside `LoadMangoHudConfig` immediately before reading the file lines (right after the file existence check).
- Redefine all checkboxes, textboxes, comboboxes, trackbars, radio buttons, color buttons, spin edits, and special buttons (like `frametimetypeBitBtn`) to their baseline default values.

**Non-Goals:**
- Redefining the loaders for vkBasalt, OptiScaler, or Tweaks, which are already correct.

## Decisions

### Decision 1: Reset checkboxes dynamically by tab sheet hierarchy

To avoid maintaining a large, fragile list of individual checkboxes, we will iterate over all components on the form and set `Checked := False` for any `TCheckBox` whose parent hierarchy resides within one of the 5 MangoHud-related tab sheets (`presetTabSheet`, `visualTabSheet`, `performanceTabSheet`, `metricsTabSheet`, `extrasTabSheet`).

- **Option A (Chosen)**: Dynamic parent chain walking for checkboxes, combined with static resets for specific non-checkbox controls (like comboboxes, textboxes, trackbars, and color buttons). This is robust against new checkboxes being added to the tabs in the future.
- **Option B**: Hardcoding every checkbox reset individually. This is highly prone to errors and omission when new settings/checkboxes are added.

## Risks / Trade-offs

- **[Risk] Restoring defaults for games without a config** → If a game does not have a config file, calling `LoadMangoHudConfig` exits early before resetting, preserving the cloning of current UI values. This maintains the existing user expectations for new games.
