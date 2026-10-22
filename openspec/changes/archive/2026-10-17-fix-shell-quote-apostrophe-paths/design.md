# Design

## Context

See [proposal.md](file:///mnt/NVME/Software/goverlay/openspec/changes/fix-shell-quote-apostrophe-paths/proposal.md) for motivation.

GOverlay interacts with external tools and processes primarily through `ExecuteShellCommand(Cmd)` in `apputils.pas`, which executes `/bin/sh -c Cmd`. When building command strings, path parameters and environment variable assignments were quoted using Free Pascal's standard library function `QuotedStr(S)`.

`QuotedStr` wraps a string in single quotes and replaces single quotes with pairs of single quotes (`'No Man''s Sky'`). While standard in Pascal source code and SQL dialects, POSIX shell syntax (`/bin/sh`) does not interpret `''` as an escaped single quote. Instead, the first quote ends the single-quoted string literal, the second quote starts a new single-quoted string literal, and the adjacent character is evaluated outside quotes. As a result:
`'No Man''s Sky'` -> evaluated by `/bin/sh` as `'No Man'` + `''` + `'s Sky'` = `No Mans Sky`.

When uninstalling mods for games such as *No Man's Sky*, the command executed is:
`STEAM_COMPAT_INSTALL_PATH='.../No Man''s Sky' ... bgmod-uninstaller`
The uninstaller receives `STEAM_COMPAT_INSTALL_PATH` as `.../No Mans Sky`, fails to find the directory, prints `Resolved game directory does not exist: .../No Mans Sky/`, and aborts.

Similarly, clicking "Open Folder" or "Open Prefix" executes:
`xdg-open '.../No Man''s Sky'`
which fails or does nothing because `xdg-open` attempts to open the nonexistent path `.../No Mans Sky`.

## Goals / Non-Goals

**Goals:**
- Provide a robust, reusable `ShellQuote(const S: string): string` helper in `apputils.pas` adhering to POSIX shell escaping conventions.
- Replace `QuotedStr` with `ShellQuote` in all shell execution paths in `games_tab.pas` (uninstaller execution, `xdg-open` folder launches, environment variable values).
- Provide defensive fallback in `bgmod-uninstaller.lpr` (and `bgmod.lpr`): if an environment variable provides a directory that does not exist on disk, discard it and read the persisted directory from `bgmod.conf`.
- Validate POSIX escaping through unit tests in `tests/test_logic.pas`.

**Non-Goals:**
- Replacing `ExecuteShellCommand` with a multi-argument process launcher across all of GOverlay (this would require substantial refactoring across hundreds of legacy call sites).
- Modifying config file parser logic in `bgmod.conf` where standard key-value parsing already handles spaces and apostrophes cleanly.

## Decisions

### Decision 1: POSIX Single-Quote Wrapping (`'...'`) with `'\'''` Escaping
- **Rationale**: In POSIX shell, wrapping a string in single quotes disables all parameter expansion, globbing, command substitution, and backslash interpretation (`$`, `` ` ``, `\`, `"`, `*`, `?`). The only character that cannot appear inside single quotes is the single quote itself. The standard and safest POSIX escaping idiom is to terminate the single quote, insert an escaped single quote, and resume the single quote:
  `Result := '''' + StringReplace(S, '''', '''\''''', [rfReplaceAll]) + '''';`
  For example, `No Man's Sky` becomes `'No Man'\''s Sky'`.
- **Alternatives Considered**:
  - *Double-quote wrapping with backslash escaping (`"..."`)*: Double quotes allow parameter substitution (`$VAR`), command substitution (`$(...)`), and backslash escapes (`\"`), requiring complex and error-prone escaping of multiple characters.
  - *Free Pascal `QuoteString` or `fpSystem`*: Does not uniformly solve `/bin/sh -c` string interpolation used across `ExecuteShellCommand`.

### Decision 2: Defensive Path Validation in `bgmod-uninstaller`
- **Rationale**: Even if external callers pass a corrupted or misquoted path via `STEAM_COMPAT_INSTALL_PATH`, `bgmod-uninstaller` has access to `bgmod.conf` in its config directory. Adding a check:
  ```pascal
  if (GameDir <> '') and (not DirectoryExists(GameDir)) then
  begin
    // Log warning and reset GameDir to empty so it reads GAME_DIR from config
    GameDir := '';
  end;
  ```
  ensures resilience against any unexpected path distortion.
- **Alternatives Considered**:
  - *Immediately aborting on invalid env var*: Less resilient; causes uninstallation to fail when valid configuration already exists locally on disk.

## Risks / Trade-offs

- **[Risk]** Overlooked call sites still using `QuotedStr` for shell commands.
  - **Mitigation**: Search the codebase for `QuotedStr` usage combined with `ExecuteShellCommand` and replace them in `games_tab.pas` and related game launching/opening logic.
- **[Risk]** Performance impact of `StringReplace` in `ShellQuote`.
  - **Mitigation**: Path strings are short (typically < 256 bytes) and executed on user actions (uninstallation, opening folder), making string allocation cost negligible (< 1 microsecond).
