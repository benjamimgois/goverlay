# Proposal

## Why

When paths or environment variables containing single quotes/apostrophes (e.g., `No Man's Sky`, `Baldur's Gate 3`, `Assassin's Creed`) are passed to shell commands via `ExecuteShellCommand` in GOverlay, Free Pascal's standard `QuotedStr` function escapes single quotes by doubling them (`'No Man''s Sky'`). In POSIX shells (`/bin/sh`), adjacent single quotes close and reopen string literals, stripping the quote completely (`No Mans Sky`). This causes `bgmod-uninstaller` to fail with "Resolved game directory does not exist" and causes the "Open Folder" / "Open Prefix" card actions to fail silently.

## What Changes

- Introduce a canonical POSIX shell escaping function (`ShellQuote`) in `apputils.pas` that wraps arguments in single quotes and safely escapes existing single quotes using `'\''` (e.g., `'No Man'\''s Sky'`).
- Replace `QuotedStr` with `ShellQuote` across `games_tab.pas` for shell execution, specifically for `STEAM_COMPAT_INSTALL_PATH`, `BGMOD_CONFIG_DIR`, `BGMOD_BACKUPS_DIR`, `UninstallerBin`, and `xdg-open` targets.
- Implement defensive validation in `bgmod-uninstaller.lpr` (and `bgmod.lpr`): if `STEAM_COMPAT_INSTALL_PATH` is passed via environment variable but `DirectoryExists(GameDir)` is false, reset `GameDir` so the uninstaller falls back to reading `GAME_DIR` from the saved `bgmod.conf`.
- Add comprehensive logic unit tests for `ShellQuote` to verify paths with apostrophes, spaces, double quotes, dollar signs, and backslashes.

## Capabilities

### Modified Capabilities
- `safe-uninstall-backup-restore`: Ensure uninstaller execution and environment variable propagation safely preserve directory paths containing apostrophes/single quotes, and add defensive game directory validation before uninstallation.
- `games-tab-navigation`: Ensure game card folder and prefix directory launching via `xdg-open` correctly handles paths with apostrophes and special characters.

## Impact

- `apputils.pas`: Adds `ShellQuote(const S: string): string` to interface and implementation.
- `games_tab.pas`: Updates uninstaller invocation and folder opening handlers to use `ShellQuote`.
- `bgmod-uninstaller.lpr`: Adds defensive fallback to `bgmod.conf` when the passed game directory does not exist on disk.
- `tests/test_logic.pas`: Adds test cases validating POSIX shell escaping behavior.
- No breaking API changes; fully backward-compatible.
