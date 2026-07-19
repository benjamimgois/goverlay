## Why

When fetching release notes from GitHub, GOverlay uses `TProcess` with `poWaitOnExit` and `poUsePipes` to execute `curl`. Because the release payload from the GitHub API is ~81KB (which exceeds the default 64KB Linux pipe buffer), the child `curl` process blocks forever writing to the full pipe. Meanwhile, GOverlay is blocked waiting for `curl` to exit, resulting in a permanent deadlock that prevents the release notes popup from appearing.

## What Changes

- Modify `GetReleaseNotes` in `goverlay_system.pas` to use `Process.RunCommand` instead of a manual synchronous `TProcess` execution. `Process.RunCommand` reads the output buffer dynamically while the process is running, preventing deadlock.

## Capabilities

### New Capabilities

### Modified Capabilities

- `release-changelog-popup`: Specify that the process of fetching the release notes from the GitHub API must be deadlock-free and handle arbitrary response sizes.

## Impact

- **Affected Files**: `goverlay_system.pas`
- **Dependencies/APIs**: Reuses FreePascal's built-in `Process.RunCommand` in the `Process` unit.
