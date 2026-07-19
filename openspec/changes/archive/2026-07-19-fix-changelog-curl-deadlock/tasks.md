## 1. Implementation

- [x] 1.1 Replace the manual `TProcess` execution logic in `GetReleaseNotes` (line 155) in `goverlay_system.pas` with `Process.RunCommand`

## 2. Verification

- [x] 2.1 Rebuild GOverlay to verify compile passes
- [x] 2.2 Run GOverlay with offscreen rendering and simulate/check that the release notes fetch completes successfully without deadlocking
