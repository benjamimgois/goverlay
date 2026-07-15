## Context

The current `SanitizeFileName` implementation uses a blacklist to replace a few ASCII characters with underscores. Non-ASCII/Unicode/multibyte symbols (like `™`, `®`, `©`) are not caught by this blacklist. Because different parts of the system or running layers (Wine, Proton, Steam API, native Linux) might parse, transfer, or normalize unicode characters differently, this can cause path mismatches when looking up game config folders, leading to duplicate directory creation under `goverlay/gameconfig/` and cache files.

## Goals / Non-Goals

**Goals:**
- Implement a robust whitelist-based character sanitization strategy in `SanitizeFileName` to ensure clean ASCII-only filenames.
- Support spaces, dashes, periods, plus signs, brackets, and parentheses.
- Collapse multiple consecutive underscores into a single underscore for aesthetics.
- Maintain consistent sanitization behavior across both native code and Flatpak configs by modifying both `overlayunit.pas` and `overlay_config.pas`.

**Non-Goals:**
- We do not aim to map accented characters to their closest ASCII equivalents (e.g. `é` to `e`), but rather will simplify all non-safe characters to `_`.
- We will not automatically rename existing configuration directories, as the duplication is minor and future runs will cleanly use the new sanitized directory.

## Decisions

- **Whitelist vs. Blacklist**: A whitelist approach is used because it guarantees that no unexpected unicode character, symbol, control character, or platform-specific separator will bypass sanitization.
- **Collapsing Underscores**: Since multi-byte characters will result in multiple consecutive invalid bytes being replaced by `_` (e.g., `™` consists of 3 bytes), collapsing consecutive underscores is necessary to prevent directory names like `GameName___`.
- **Trimming and Fallback**: The result is trimmed. If the entire string is sanitized to empty, a fallback string `"game"` is used to avoid directory creation errors.

## Risks / Trade-offs

- **Risk**: Game names with only special/non-ASCII characters might collision on `"game"`.
  - *Mitigation*: This is extremely rare for Steam/non-Steam games, but using the generic fallback `"game"` ensures the application does not crash.
- **Risk**: Accent characters (e.g., `é`) are replaced by `_` rather than converted (e.g., `e`).
  - *Mitigation*: This is standard for simple sanitization in GOverlay and keeps dependencies minimal without needing a complex transliteration library.
