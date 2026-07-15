## Why

Special characters (such as trademarks `™`, registered marks `®`, copyright marks `©`, and non-ASCII/unicode characters) in game names are not sanitized by the current blacklist-based character check. This leads to directory creation issues, path mismatches between Linux and Wine/Proton/Steam environments, and duplicate game configuration directories under `goverlay/gameconfig/`.

## What Changes

- Redefine `SanitizeFileName` to use a strict whitelist of safe ASCII characters.
- Multi-byte UTF-8 and other unsafe characters will be replaced with underscores.
- Consecutive underscores will be collapsed into a single underscore to keep directory names clean.
- Trim trailing whitespace.

## Capabilities

### New Capabilities
- `game-name-sanitization`: Introduce a strict whitelist-based sanitization helper for game names used in cache files and game configuration directories.

### Modified Capabilities

## Impact

- Affected files: `overlayunit.pas` and `overlay_config.pas`.
- Game cover cache filenames and game configuration directory names will be cleaner and ASCII-only.
