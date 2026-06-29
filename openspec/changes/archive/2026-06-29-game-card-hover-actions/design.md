## Context

Currently in `games_tab.pas`, game management operations (`Open install folder`, `Open prefix folder`, `Uninstall changes`) are only available via a right-click `TPopupMenu` (`FGameCardMenu`). Many users fail to notice right-click context menus, leading to feature requests for capabilities that already exist.

This design introduces a hover action overlay bar at the bottom of game card panels for both Steam and non-Steam games.

## Goals / Non-Goals

**Goals:**
- Provide clear, immediate 1-click access to game management actions on mouse hover.
- Maintain a clean card grid visual layout when cards are not hovered.
- Ensure smooth event propagation across child controls so the hover bar remains stable while interacting with action buttons.

**Non-Goals:**
- Removing the existing right-click context menu (both access methods will coexist).
- Altering game card dimensions (`CARD_W = 150`, `CARD_H = 215`).

## Decisions

### 1. Action Overlay Panel Construction (`ActionPanel`)
- **Choice**: Create a child `TPanel` (`ActionPanel`) at the bottom of each game card panel (`SetBounds(0, CARD_H - 30, CARD_W, 30)`).
- **Rationale**: Using a child panel container tagged with `Tag := 9990` allows cleanly grouping action buttons, styling a dark translucent background (`Color := $1F1F1F`), and toggling visibility as a single unit.

### 2. Button Layout and Tooltips
- **Choice**: Add 3 action buttons (e.g. `TSpeedButton` or `TImage` buttons) spaced evenly inside `ActionPanel`:
  1. 📁 Folder icon (`Hint := 'Open install folder'`)
  2. 🍷 Wine glass icon (`Hint := 'Open prefix folder'`)
  3. 🗑️ Trash / Reset icon (`Hint := 'Uninstall / Reset changes'`)
- **Rationale**: Using standard hints (`ShowHint := True`) provides instant clarity when hovering each action icon without cluttering the compact 150px card width.

### 3. Mouse Event Handling & Stability
- **Choice**: Wire `OnMouseEnter` and `OnMouseLeave` of `ActionPanel` and all action buttons to `@GameCardMouseEnter` and `@GameCardMouseLeave`.
- **Rationale**: In Lazarus / LCL components, moving the cursor over child controls triggers `OnMouseLeave` on parent controls. Binding all card components to the common mouse handlers ensures the hover bar remains visible continuously while hovering anywhere over the card or its buttons.

### 4. Integration with Non-Steam Title Label
- **Choice**: When a non-Steam game uses a fallback icon (and displays the text title label `Tag = 9991`), `ActionPanel` overlays cleanly above the title label or temporarily hides it on hover.
- **Rationale**: Ensures actions remain functional regardless of cover art availability.

## Risks / Trade-offs

- **[Risk]** Mouse hover flicker when moving cursor rapidly between buttons.
  - **Mitigation**: Standardize parent resolution in `GameCardMouseEnter` / `GameCardMouseLeave` to identify the root `CardPanel` via `Tag` checks (`9999` or `9997`).
