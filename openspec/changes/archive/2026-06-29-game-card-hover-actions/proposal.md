## Why

Currently, useful game management actions ("Open install folder", "Open prefix folder", "Uninstall changes") are buried inside a right-click context menu on game cards. Many users fail to discover these options and open issues requesting features that already exist. Introducing an interactive action overlay bar that appears when hovering over a game card will significantly improve discoverability and reduce user friction.

## What Changes

- Add a dark translucent action bar panel (`TPanel` / buttons) at the bottom of both Steam and non-Steam game cards.
- Control action bar visibility dynamically via `OnMouseEnter` and `OnMouseLeave` events on card components.
- Include quick action buttons with clean tooltips for:
  1. 📁 **Open install folder**
  2. 🍷 **Open Wine/Proton prefix folder**
  3. 🗑️ **Uninstall / Reset overlay configurations**
- Maintain compatibility with non-Steam game title fallback labels when no cover art is available.

## Capabilities

### New Capabilities
- `game-card-hover-actions`: Interactive hover action bar on game cards for quick access to frequent card actions.

### Modified Capabilities

## Impact

- `games_tab.pas`: Modifies game card panel construction (`CardPanel`), adds action panel/button controls, wires hover events (`GameCardMouseEnter` / `GameCardMouseLeave`), and routes button clicks to existing click handlers.
