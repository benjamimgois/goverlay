## Why

The current ReShade tab layout places version details and action buttons at the top, followed by shader collections in the middle, and configuration at the bottom. In contrast, the OptiScaler and Lossless Scaling tabs in GOverlay place primary configuration controls at the top, modular components in the center, and library/software version status at the bottom. Reorganizing the ReShade tab to match the OptiScaler tab structure and MD3 styling brings visual consistency and a predictable workflow across all post-processing and upscaling tools.

## What Changes

- Reorder the cards in the ReShade tab to place configuration at the top, shader management in the center, and runtime status at the bottom.
- Rename the configuration card to **"Config"** (previously "Configuration & Wine Integration").
- Rename the shader collections card to **"Shaders"** (previously "Shader Collections").
- Move the **"Open Shaders Directory"** button from the status card to the header of the **"Shaders"** card (Option A).
- Rename the status card to **"Software status"** (previously "ReShade Status") and anchor it to the bottom of the tab content.
- Align card styling with OptiScaler by applying `StyleMainCard` and `SubCardPaint` for consistent rounded corners, borders, and theme colors.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `reshade-post-processing`: Updates the visual layout and card hierarchy of the ReShade tab so that "Config" is first, "Shaders" is second with "Open Shaders Directory", and "Software status" is positioned at the base of the tab.

## Impact

- **UI Files**: `reshade_tab.pas` (`BuildReShadeTab`, `ReflowReShadeTab`).
- **Tests**: `tests/gui/gui_test_cases.pas` (verifying card layout, properties, and ordering).
