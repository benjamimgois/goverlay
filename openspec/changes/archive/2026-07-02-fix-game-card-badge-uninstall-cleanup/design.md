## Context

`GameCardUninstallClick` (games_tab.pas:2258-2272) removes badge controls from the card panel after a successful uninstall. The current loop deletes every `TImage` with `Proportional=True`, which matches both the Steam/Wine platform icon (created at card init time, `TImage.Proportional := True`, positioned at top-left via `SetBounds(4, 4, 16, 16)`) and the GOverlay settings badge (created only when `BadgeCount > 0`, `Proportional := True`, positioned at top-right via `Anchors = [akTop, akRight]`).

Both badges lack a distinguishing property at creation time, so the cleanup loop cannot target the GOverlay badge alone.

## Goals / Non-Goals

**Goals:**
- Remove only the GOverlay badge during "Uninstall changes", preserving the platform icon.
- Make the distinction at badge creation time so it is available to any future cleanup or redraw context.

**Non-Goals:**
- Changing the visual appearance, position, or rendering logic of either badge.
- Changing the binary build pipeline (GOverlay recompilation only).

## Decisions

1. **Tag-based distinction.** At badge creation, set `Tag := 1` on the Steam/Wine platform badge and `Tag := 2` on the GOverlay badge. The existing `Tag` property on `TImage` is unused for both badges (the card `Panel.Tag` holds the bitmask, not the image tags). This is the simplest non-breaking change.

2. **Cleanup filter.** In `GameCardUninstallClick`, replace the `Proportional` filter with `Panel.Controls[i].Tag = 2`. The `TShape` and `TLabel` branch is unaffected (uninstall action panel controls should still be removed).

3. **No design.md needed beyond this note** — the fix is a one-line change in each of three locations.
