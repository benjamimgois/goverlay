## Context

Currently, the "Wine prefix" configuration button is placed on the OptiScaler tab. By moving it to GOverlay's global configuration settings panel (which handles other system parameters), we align the configuration workflow and make space on the OptiScaler tab for a "Preferred upscaler" dropdown box.

## Goals / Non-Goals

**Goals:**
- Move "Wine prefix" button and associated click/change handlers to the global settings panel.
- Add a new `TComboBox` named `optiscalerPreferredUpscaler` to the OptiScaler tab.
- Update `OptiScaler.ini` keys (`Dx11Upscaler`, `Dx12Upscaler`, `VulkanUpscaler`) on combobox change.
- Handle `"fsr4"` -> `"fsr31"` translation.

**Non-Goals:**
- Do not modify or restructure other settings or tabs.

## Decisions

### Decision 1: Relocate Wine Prefix button to Settings Form
We will move the Wine prefix button component definition from the OptiScaler tab definition in `overlayunit.lfm` / `overlayunit.pas` to the gear settings panel, directly below the "Status" control area, adding a divider line.
- **Alternatives Considered**: Keeping it on the main panel but at the bottom. **Rejected**: Makes the UI cluttered.

### Decision 2: Add TComboBox to OptiScaler Tab
We will insert a `TComboBox` in place of the Wine Prefix button. Its options will be populated statically. When the user changes the selection, GOverlay will parse/modify the game's `OptiScaler.ini` keys.
- **Mapping logic**:
  - `auto` -> `auto`
  - `xess` -> `xess`
  - `fsr21` -> `fsr21`
  - `fsr22` -> `fsr22`
  - `fsr4` -> `fsr31` (special case)
  - `dlss` -> `dlss`

## Risks / Trade-offs

- **[Risk]**: OptiScaler config directory not matching the selected game.
  - **Mitigation**: Reuse existing OptiScaler config directory resolving logic (using prefix/game directory path lookup).
