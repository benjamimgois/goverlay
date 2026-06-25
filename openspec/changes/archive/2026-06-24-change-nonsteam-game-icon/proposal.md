## Why

Non-Steam game covers display a small icon in the top corner using index 37 from the `iconsImageList`. The icon at index 37 is not the intended one — index 38 is the correct icon for non-Steam games.

## What Changes

- Change icon index from 37 to 38 in `games_tab.pas` when drawing the non-Steam game overlay icon.

## Capabilities

*(None — trivial cosmetic change)*

## Impact

- `games_tab.pas`: Two occurrences of index 37 → 38 (comment at line 553, Draw call at line 561, and guard condition at line 554)
