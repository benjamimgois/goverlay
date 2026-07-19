## Context

GOverlay queries `https://api.github.com/repos/benjamimgois/goverlay/releases?per_page=5` to fetch the latest release notes. This payload is ~81KB.
Using `TProcess` with `poWaitOnExit` and `poUsePipes` causes a deadlock when the child process writes more than the default OS pipe buffer size (64KB on Linux) because the child blocks waiting for the parent to read, but the parent blocks waiting for the child to exit.

## Goals / Non-Goals

**Goals:**
- Fix the I/O deadlock during the changelog fetch.
- Enable successful display of the changelog popup when triggered.

**Non-Goals:**
- Implement a custom HTTP client in Pascal (we will continue to use `curl` as it is reliable and already present).

## Decisions

### Decision 1: Use `Process.RunCommand` in `GetReleaseNotes`

- **Approach**: Replace the manual `TProcess` creation and execution inside `GetReleaseNotes` in `goverlay_system.pas` with FreePascal's built-in `Process.RunCommand` utility.
- **Alternatives Considered**:
  - *Reading the stream dynamically in a custom loop*: This is exactly what `Process.RunCommand` does under the hood. Using the standard library utility is cleaner, less error-prone, and enxuga a lot of boilerplate code.
- **Rationale**: `Process.RunCommand` is deadlock-free because it reads from the process output pipe in a loop while the process is executing, preventing the pipe buffer from getting full and blocking the child process.

## Risks / Trade-offs

- **[Risk]**: `Process.RunCommand` requires the `Process` unit (which is already in the uses list of `goverlay_system.pas`).
- **[Mitigation]**: Checked, the `Process` unit is already in the `uses` clause, and `Process.RunCommand` is a standard helper in modern FreePascal (FPC 3.0.0+).
