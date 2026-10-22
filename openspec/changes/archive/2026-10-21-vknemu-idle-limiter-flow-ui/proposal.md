# Proposal

## Why

The Idle Limiter (vkNemu) section on the Goverlay Performance tab currently presents four plain spin edits/comboboxes arranged in a rigid 2x2 grid. Without contextual cues, units, or visual feedback, the interface feels bland and uninspired, leaving users uncertain about how timeout and wake parameters interact during game execution.

Transforming this section with an interactive visual flow timeline and clear iconography connects the configuration values to game states (`Active Game` -> `Standby` -> `Resume`), making the feature visually engaging and self-explanatory.

## What Changes

- Introduce an interactive behavior flow diagram (timeline card) directly inside the Idle Limiter section showing the state progression:
  `Active Game (Max FPS) ──[ Xs Idle ]──▶ Standby (Y FPS) ──[ Wake Input ]──▶ Resume (Zs Delay)`.
- Connect the flow diagram labels to live control change events so adjusting `Idle FPS`, `Timeout`, `Wake Input`, or `Delay` immediately updates the diagram in real time.
- Enhance the section header with an icon (`🌙 Idle Limiter (vkNemu)`) and add explicit unit suffixes (`FPS`, `s`).
- Reorganize the fine-tuning parameter controls beneath the flow diagram with balanced vertical spacing.

## Capabilities

### New Capabilities
- `vknemu-flow-diagram-ui`: Defines the visual state transition diagram and dynamic parameter reflection for the vkNemu Idle Limiter on the Performance tab.

### Modified Capabilities
<!-- None: Core vkNemu configuration persistence and parameters remain unchanged. -->

## Impact

- Code: `mangohud_ui.pas` (`TMangoHudUiHelper`), `overlayunit.pas` (`VkNemuControlChange`).
- UI: Performance tab -> Limiters card -> vkNemu sub-section.
- Dependencies: None.
