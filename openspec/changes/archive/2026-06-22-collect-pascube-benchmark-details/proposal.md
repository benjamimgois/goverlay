## Why

The PasCube benchmark system needs to collect and transmit additional environment and runtime metadata (CPU architecture, packaging type, and benchmark duration) when submitting benchmark results. This ensures more comprehensive analytics on the public dashboard and allows the user to review all collected data transparently in the confirmation dialog before submission.

## What Changes

- Add CPU architecture detection (e.g., `x86_64`) and include it in the benchmark results JSON payload under the key `"architecture"`.
- Determine the GOverlay package format (native, appimage, flatpak) and include it in the benchmark results JSON payload under the key `"package"`.
- Track the total duration of the benchmark run (in seconds) and include it in the benchmark results JSON payload under the key `"timer"`.
- Display the CPU architecture, package type, and benchmark duration in the submission confirmation dialog.

## Capabilities

### New Capabilities

### Modified Capabilities

- `pascube-benchmark-compatibility`: Add CPU architecture, GOverlay package type, and total benchmark duration requirements to the benchmark results, serialization format, and submission payload, and display these fields in the submission confirmation dialog.

## Impact

- Affected files: `pascube_src/src/UnitPasCubeScreen.pas` (results tracking, rendering, and submission payload), `overlayunit.pas` (passing the packaging environment variable to the PasCube binary).
- Planning: Modifies the `pascube-benchmark-compatibility` spec with a delta spec.
