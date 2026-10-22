# Proposal: Dim Unselected Method Logos in OptiScaler and Lossless Scaling Tabs

## Why

In the OptiScaler and Lossless Scaling tabs, the "Method" selection card presents choices through radio buttons with adjacent brand/engine logos (None, OptiScaler, DLSS Enabler in OptiScaler; None, LSFG-VK, MAKO in Lossless Scaling).

Currently, all logos remain at 100% full brightness regardless of which radio button is active because setting `TImage.Enabled := False` in LCL Qt6 does not visually alter rendered PNG pixels. Consequently, users can only differentiate the active method via the small radio indicator dot. Dimming unselected method logos creates a prominent visual hierarchy where the active engine stands out clearly at 100% brightness while inactive options are subdued at ~35% brightness.

## What Changes

- Add a shared utility function `CreateDimmedPng` that creates a dimmed copy of a `TPortableNetworkGraphic` using `TLazIntfImage`, scaling RGB color channels (e.g. 35% brightness) while preserving full alpha transparency.
- Pre-generate dimmed versions of the method logos on tab initialization:
  - OptiScaler tab: `None`, `OptiScaler`, `DLSS Enabler`.
  - Lossless Scaling tab: `None`, `LSFG-VK`, `MAKO`.
- Update `UpdateUpscalerImageOpacity` (`overlayunit.pas`) and `UpdateMethodImageOpacity` (`lossless_scaling_tab.pas`) to assign the full 100% brightness PNG to the selected radio button's `TImage`, and the pre-computed dimmed PNG to the unselected radio buttons.
- Ensure clicking the dimmed logos still selects their corresponding radio button.
- Memory management: ensure all dynamically created dimmed `TPortableNetworkGraphic` instances are properly freed during destruction / cleanup.

## Capabilities

### New Capabilities
- `optiscaler-method-selector`: Defines the Method card selection behavior in the OptiScaler tab, including None, OptiScaler, and DLSS Enabler radio buttons with visual brightness dimming of unselected logos.

### Modified Capabilities
- `lossless-scaling-config`: Update Requirement 5 to explicitly specify pixel-level brightness dimming (35% brightness with preserved alpha channel) for unselected engine logos in the Lossless Scaling Method card.

## Impact

- `overlayunit.pas`: update `UpdateUpscalerImageOpacity` and form fields/destruction.
- `optiscaler_tab.pas`: pre-create dimmed PNGs during tab setup and free them in helper destructor.
- `lossless_scaling_tab.pas`: pre-create dimmed PNGs during method card initialization, update `UpdateMethodImageOpacity`, and free dimmed PNGs in destructor.
- No impact on configuration files (`bgmod.conf`, `conf.toml`) or backend execution logic.
