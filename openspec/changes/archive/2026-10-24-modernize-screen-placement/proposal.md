# Proposal: Modernize Screen Placement Monitor (Option 1)

## Why

The current screen placement selector on the MangoHud Visual tab relies on a legacy bitmap image (`monitor.png`) overlaid with 8 tiny standard `TRadioButton`s. This legacy widget has cramped click targets, does not show how or where the HUD will actually appear inside the game screen, and lacks modern theme contrast. Modernizing to Option 1 (Modern Vector Monitor with Live HUD Anchor) delivers an intuitive, tactile interface where users can click anywhere on screen anchors and see a live mini-HUD preview positioned immediately at the active anchor.

## What Changes

- Implement a custom vector-rendered modern monitor widget (`TPaintBox` or interactive canvas) in `mangohud_ui.pas` within the Position & Layout section.
- Render 8 interactive anchor zones (`Top-Left`, `Top-Center`, `Top-Right`, `Middle-Left`, `Middle-Right`, `Bottom-Left`, `Bottom-Center`, `Bottom-Right`) with hover glow and accent selection styling.
- Render a live mini-HUD chip/preview inside the screen that moves smoothly to the active anchor position, displaying the current layout orientation and position badge.
- Synchronize two-way interactions with the existing background `TRadioButton` controls (`topleftRadioButton`, `topcenterRadioButton`, `toprightRadioButton`, `middleleftRadioButton`, `middlerightRadioButton`, `bottomleftRadioButton`, `bottomcenterRadioButton`, `bottomrightRadioButton`) and trigger `GenericControlChange` for automatic configuration persistence.
- Hide or phase out legacy bitmap `monitor.png` and raw radio buttons while keeping their logic and event triggers intact for seamless backward compatibility and test stability.
- Align dedicated `Offset X` and `Offset Y` inputs neatly below the monitor display with clear labels.

## Capabilities

### Modified Capabilities
- `mangohud-visual-modular-ui`: Update screen placement requirements to mandate the modern vector monitor with live HUD anchor indicator (Option 1) and full bidirectional synchronization.

## Impact
- Files modified: `mangohud_ui.pas`, `overlayunit.pas` (if needed for painting or event dispatch).
- No breaking changes to MangoHud config file format or test contracts (`TestMangoHudVisualCompactToggles`, `TestMangoHudAllRadioGroups`, etc.).
