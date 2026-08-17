# Proposal: Modernize Steam Finish Dialog Guide

## Why

The Finish Configuration popup currently displays an outdated 2012-era Steam properties dialog mockup (brown horizontal tab bar with "General | DLC | Updates" and red close button). Modern Steam features a completely redesigned dark sidebar interface with "General" selected, toggle switches, and a dedicated "Launch Options" section with helper text. Updating the mockup to faithfully replicate current Steam ensures users immediately recognize where to paste their launch options without confusion.

## What Changes

- Redesign the custom Canvas animation in `finish_dialog.pas` for the Steam platform to match modern Steam's Properties UI:
  - Add dark left sidebar (`#131922`) featuring the game title in Steam cyan (`#1A9FFF`) and vertical navigation list (`General` active with `#2B3947` pill highlight, inactive items like `Compatibility`, `Updates`, `Installed Files`, `Controller`).
  - Add right content panel (`#171D25`) with `General` title, modern toggle switch for `Enable the Steam Overlay while in-game`, and `Launch Options` section with helper text `Advanced users may choose to enter modifications to their launch options.`.
  - Style modern window controls (`— □ ✕`) on the top right.
  - Dynamically display the actual selected game title (or `GLOBAL OVERLAY` / `MY GAME` if no game selected) in the sidebar header.
  - Animate an interactive cyan pulsing border and blinking cursor in the Launch Options input field with a bouncing guide indicator.
  - Increase dialog height slightly if needed (from 540px to 560px) to provide ample breathing room for the modern Steam layout.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `finish-configuration-dialog`: Update animated walkthrough requirement to depict modern Steam Properties UI layout with left sidebar, game title, General section, and Launch Options input box.

## Impact

- `finish_dialog.pas`: Updated `PaintAnimSteam` routine and constructor/helper to optionally accept the active game title.
- `tests/gui/gui_test_cases.pas`: Regression tests for Finish Configuration dialog painting and platform switching.
