## Why

Currently, on/off toggles in the navigation sidebar are only displayed for game-specific configurations. The global configuration mode always activates all configurations implicitly, which is not always desired and prevents users from disabling a tool globally or having a consistent visual experience between global and per-game editing.

## What Changes

- Enable the navigation sidebar tool toggles in global mode.
- Hide the tool toggles when the user is on the "Games" tab to keep the landing page clean.
- When a tool is toggled OFF globally, disable (grey out) its tab inputs and delete its global configuration file (matching the behavior of the per-game tool toggles).
- When a tool is toggled ON globally, enable its tab inputs and allow the configuration file to be saved.

## Capabilities

### New Capabilities
- `global-sidebar-toggles`: Supports sidebar-integrated ON/OFF toggles for MangoHud, vkBasalt, OptiScaler, and Tweaks configurations in global mode.

### Modified Capabilities

## Impact

- `sidebar_nav.pas`: Update toggle visibility and toggle click actions to handle global configurations.
- `overlayunit.pas`: Apply tool toggles state when entering global configuration tabs.
