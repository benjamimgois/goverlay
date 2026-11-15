# Design

## Context

See `proposal.md` for the root cause of issue #467.

In `bgmod.lpr:3197-3203`:
```pascal
SetLength(ReExecArgs, ParamCount + 2);
ReExecArgs[0] := PChar(ParamStr(0));
for k := 1 to ParamCount do
  ReExecArgs[k] := PChar(ParamStr(k));
ReExecArgs[ParamCount + 1] := nil;

execv(PChar(ParamStr(0)), @ReExecArgs[0]);
```
`ParamStr(k)` returns a temporary `AnsiString` per call. Casting it directly to `PChar(...)` and storing the pointer in `ReExecArgs` does not increment any reference count, so the temporary string is freed/reused on the next iteration and every `ReExecArgs[k]` ends up pointing to `ParamStr(ParamCount)`.

An audit of all other `PChar(...)` casts in `bgmod.lpr` confirmed that `SplashArgs` (line 3013), `EnvArgs` (line 4834), and `Args` (line 4925) already back their `PChar` arrays with live `TStringList` or `array of string` variables.

## Goals / Non-Goals

**Goals:**
- Keep all `ParamStr(0..ParamCount)` strings alive in a backing `array of string` until `execv` completes.
- Add an automated regression test that triggers `bgmod` self-update with multiple arguments and verifies all arguments arrive intact in the re-executed subprocess.

**Non-Goals:**
- Changing when `CheckBGModNeedsUpdate` triggers or changing `DISABLE_LSFGVK=1` behavior.

## Decisions

1. **Back `ReExecArgs` with a local `ReExecStrs: array of string`**:
   - Populate `ReExecStrs[0..ParamCount]` with `ParamStr(0..ParamCount)` first, then assign `ReExecArgs[k] := PChar(ReExecStrs[k])` and pass `PChar(ReExecStrs[0])` to `execv`.
   - *Rationale*: Matches the existing `ArgsStrings` pattern in `bgmod.lpr:4865-4925`, requires zero heap-management complexity beyond standard Pascal managed strings, and guarantees distinct, null-terminated buffers for every argument.

## Risks / Trade-offs

- None; this is a strictly scoped memory-lifetime fix in `bgmod.lpr`.
