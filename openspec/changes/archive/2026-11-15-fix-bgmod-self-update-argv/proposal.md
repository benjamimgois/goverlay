# Proposal

## Why

Users report in issue #467 that Proton games launched via `bgmod` fail to start because every command-line argument passed by Steam (`Arg 0` through `Arg N`) is replaced with the last argument (the game `.exe` path), causing `bgmod` to launch the Windows `.exe` directly instead of the Steam/Proton wrapper chain.

When `bgmod` detects a newer or differently sized master binary and performs its runtime self-update (`bgmod.lpr:3197-3203`), it populates `ReExecArgs` via `ReExecArgs[k] := PChar(ParamStr(k))`. Because `ParamStr(k)` returns a temporary `AnsiString` in Free Pascal, each loop iteration frees/reuses the temporary string buffer, leaving every `PChar` in `ReExecArgs` pointing to the final `ParamStr(ParamCount)` value when `execv` is invoked.

## What Changes

- Store `ParamStr(0)` through `ParamStr(ParamCount)` in a backing `array of string` (`ReExecStrs`) before taking `PChar` pointers for `ReExecArgs` and `execv`, keeping every argument string alive until `execv` replaces the process image.
- Add an automated regression test verifying that `bgmod` preserves all command-line arguments (`Arg 0..N`) intact across a runtime self-update `execv` re-execution.

## Capabilities

### New Capabilities

### Modified Capabilities
- `game-wrapper-binary-sync`: Ensure `bgmod` self-update re-execution (`execv`) preserves every original command-line argument (`ParamStr(0..ParamCount)`) without dangling `PChar` references to temporary `ParamStr` strings.

## Impact

- `bgmod.lpr`: Runtime self-update `execv` argument array construction (`ReExecStrs` backing array).
- `tests/`: Automated test covering `bgmod` self-update re-execution with multiple arguments.
