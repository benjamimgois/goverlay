## Context

Non-Steam game cards render a small greyscale icon in the top-left corner using `iconsImageList[index]`. Currently uses index 37. User wants index 38.

## Decisions

- **Choice**: Replace all occurrences of `37` with `38` on lines 553-561.
- **Rationale**: Trivial index change — no logic affected. Same icon list, different icon.
