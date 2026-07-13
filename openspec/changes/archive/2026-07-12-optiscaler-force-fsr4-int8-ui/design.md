## Context

When utilizing the bleeding-edge channel of OptiScaler, the "Emulate FP8" checkbox is irrelevant and needs to be replaced by a "Force FSR4-i8" checkbox that toggles the `Fsr4ForceEnableInt8` parameter under `OptiScaler.ini`. Since GOverlay is a Pascal/Lazarus application, modifying form layout files (`.lfm`) manually is highly error-prone. Therefore, the new checkbox should be instantiated dynamically at runtime and mapped in place of the hidden "Emulate FP8" checkbox.

## Goals / Non-Goals

**Goals:**
- Dynamically display the new checkbox "Force FSR4-i8" instead of "Emulate FP8" on the bleeding-edge update channel.
- Persist the checked state of "Force FSR4-i8" to `OptiScaler.ini` via the `Fsr4ForceEnableInt8=` key.
- Maintain a clean user interface by toggling visibility based on the selected update channel.

**Non-Goals:**
- We do not modify the main `.lfm` layout file to add the checkbox component.
- We do not modify other files like `MangoHud.conf` or `vkBasalt.conf`.

## Decisions

### Decision 1: Dynamic Checkbox Creation
Instantiate `forceFsr4Int8CheckBox` dynamically at runtime inside the `InitOptiScalerTab` procedure (in `optiscaler_tab.pas`) rather than adding it to the form designer (`.lfm`).
- **Rationale**: Form files in Lazarus contain binary or structured text declarations that are brittle to manual editing. Instantiating it in code guarantees safety and maintains clean separation.
- **Alternatives**: Declaring it in `overlayunit.lfm` was considered but rejected to avoid potential layout file corruption.

### Decision 2: Location and Placement
Position the new checkbox at the exact same location as the hidden `emufp8CheckBox` (`Left := 134`, `Top := 142`, `Parent := FOsOptiSec`).
- **Rationale**: Reusing the same space maintains UI alignment and visual symmetry.

### Decision 3: Use of fsrversionComboBoxChange for Visibility Toggling
Re-use `fsrversionComboBoxChange` to handle the visibility changes for both checkboxes.
- **Rationale**: `fsrversionComboBoxChange` is already hooked up as the change event for the version dropdowns, and is explicitly triggered at the end of the config loading sequence, making it the perfect single point of synchronization.

### Decision 4: TOptiScalerSettings Extension
Extend the `TOptiScalerSettings` record in `overlay_config.pas` to include `ForceFsr4Int8Checked`.
- **Rationale**: Seamlessly integrates the checkbox value with the existing loader and writer functions (`LoadOptiScalerConfig` and `SaveOptiScalerConfigCore`).

## Risks / Trade-offs

- **[Risk]** The `OptiScaler.ini` file might not exist yet when saving the configuration.
  - *Mitigation*: The wrapper class `TConfigFile` handles file loading/creation. If the file is missing, it will automatically create it.
- **[Risk]** Users switching channels back and forth might lose unsaved state.
  - *Mitigation*: We clear the inactive checkbox state and keep the active checkbox state updated in the record. The UI updates visibility immediately.
