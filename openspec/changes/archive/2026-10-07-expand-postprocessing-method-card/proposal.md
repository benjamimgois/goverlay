# Proposal

## Why

In the Post Processing tab, the "Method" card is currently restricted to the left half of the top row (50% width), sharing horizontal space with an "Options" card. Expanding "Method" to 100% width aligns the tab with the clean, spacious design established in the OptiScaler tab. For ReShade, moving options into a compact, full-width horizontal bar provides a clean separation of concerns. For vkBasalt, eliminating the Options card entirely reclaims significant vertical space for the effects list and streamlines the configuration interface.

## What Changes

- **Method Card (Full Width)**: Expand `FMethodCard` to span 100% of the available content width (`CW`), distributing the three selection options (**None**, **ReShade**, and **vkBasalt**) symmetrically across three columns/slots, matching the OptiScaler Method card design.
- **ReShade Options Card**: Reposition `FConfigCard` ("Options") directly beneath the Method card as a compact horizontal bar (~54–58px height) spanning full width (`CW`). Position `Toggle: [ ⌨ Home ]` and `Proxy DLL: [ dxgi.dll... ▾ ]` side-by-side in a single row.
- **vkBasalt Options Card Elimination**: Completely hide/eliminate `FVkToggleCard` in vkBasalt mode (`rmVkBasalt`). Remove the `Toggle` key capture button and `Restore Defaults` button from the vkBasalt graphical interface (retaining default key mapping in config), allowing `Reshade Effects` to start directly below the Method card and take full advantage of available vertical space.
- **Dynamic Reflow & Sizing**: Update `ReflowReShadeTab` and related layout calculations to account for full-width cards, single-row options in ReShade, and expanded height for vkBasalt effects.

## Capabilities

### New Capabilities
None.

### Modified Capabilities
- `reshade-post-processing`: Updates the top-row layout specifications so the Method card occupies full width, the ReShade Options card becomes a full-width compact row below it, and the vkBasalt Options card is removed in favor of expanded effects view.

## Impact
- Code: `reshade_tab.pas` (layout building, reflow, method selection logic), `vkbasalt_tab.pas` (toggle card visibility and parenting).
- GUI tests: Updates to any test cases checking bounds or presence of `FVkToggleCard` in the unified post-processing view.
