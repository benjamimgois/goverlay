## Context

`ExecuteShellCommand` in `apputils.pas` is used across GOverlay for executing shell operations (e.g. copying files, template deployment, symlinking, permissions modification). It creates a `TProcess` and executes `sh -c "<Command>"`. Currently, `Process.Options` is set to `[poNoConsole]`, which launches the process asynchronously without waiting for it to finish.

This causes a race condition whenever callers expect the file system operation to be finished upon function return (such as `sidebar_nav.pas` `CopyOptiScalerGameFiles` copying `OptiScaler.ini` and subsequent code immediately checking `FileExists`).

## Goals / Non-Goals

**Goals:**
- Update `ExecuteShellCommand` in `apputils.pas` to set `Process.Options := [poNoConsole, poWaitOnExit];`.
- Ensure all callers of `ExecuteShellCommand` receive synchronous completion semantics.

**Non-Goals:**
- Modifying `ExecuteGUICommand`, which is explicitly intended for launching long-running background GUI processes (e.g., MangoHud preview, vkBasalt cube) using `nohup ... &`.

## Decisions

### 1. Add `poWaitOnExit` to `ExecuteShellCommand`
- **Choice**: Change `Process.Options := [poNoConsole];` to `Process.Options := [poNoConsole, poWaitOnExit];` in `ExecuteShellCommand`.
- **Rationale**: All call sites of `ExecuteShellCommand` perform quick utility actions (`cp`, `ln`, `chmod`, `pkexec`, `rm`) where synchronous execution is required to prevent data races.

## Risks / Trade-offs

- None identified; commands executed through `ExecuteShellCommand` are short-lived shell commands.
