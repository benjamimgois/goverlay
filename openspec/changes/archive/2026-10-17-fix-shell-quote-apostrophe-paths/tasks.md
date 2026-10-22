# Tasks

## 1. Shell Quoting Implementation & Unit Tests

- [x] 1.1 Implement `ShellQuote(const S: string): string` in `apputils.pas` interface and implementation, and verify compilation with `make build`
- [x] 1.2 Add unit test cases in `tests/logic/logic_test_cases.pas` covering `ShellQuote` with plain paths, spaces, apostrophes, double quotes, dollar signs, and empty strings, and verify with `make test-logic`

## 2. Uninstaller and Path Invocation Updates

- [x] 2.1 Replace `QuotedStr` with `ShellQuote` in `games_tab.pas` for uninstaller environment variables (`STEAM_COMPAT_INSTALL_PATH`, `BGMOD_CONFIG_DIR`, `BGMOD_BACKUPS_DIR`) and `UninstallerBin`, and verify uninstaller command construction
- [x] 2.2 Replace `QuotedStr` with `ShellQuote` in `games_tab.pas` for `xdg-open` directory launching (`GameCardOpenFolderClick`, `GameCardOpenPrefixClick`)
- [x] 2.3 Add defensive non-existent directory fallback in `bgmod-uninstaller.lpr` and `bgmod.lpr` to fall back to `bgmod.conf`, and verify compilation with `make build`

## 3. Integration Verification

- [x] 3.1 Run full regression test suites with `make test-gui` and `make test-logic` to verify 100% pass rate
- [x] 3.2 Verify shell evaluation of `ShellQuote('.../No Man''s Sky')` with `/bin/sh -c` to confirm the exact uncorrupted path is printed

## Workflow follow-up

- Archive the change after review and implementation.
- Commit and push changes.
