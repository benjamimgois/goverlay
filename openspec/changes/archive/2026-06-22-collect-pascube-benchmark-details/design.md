## Context

The PasCube benchmark submits a JSON payload to a public Google Apps Script macro URL when the user chooses to submit results. We want to enhance this payload with CPU architecture, the packaging type (native, appimage, flatpak), and the total benchmark duration, and show these details in the confirmation dialog.

## Goals / Non-Goals

**Goals:**
- Implement runtime processor architecture detection using `uname -m` inside PasCube.
- Detect GOverlay package format (native, appimage, flatpak) and pass it from GOverlay to PasCube.
- Track total benchmark duration in seconds.
- Modify the confirmation dialog layout in PasCube to display these three new pieces of metadata.
- Include these new fields in the local results JSON serialization/deserialization and in the HTTP submission payload.

**Non-Goals:**
- Changing the benchmark physics simulation or scoring logic.
- Modifying the Google Sheets destination script or changing the spreadsheet schema itself.

## Decisions

### 1. Retrieve CPU Architecture
- **Approach**: Execute `uname -m` via a new helper `GetCPUArchitecture: string` inside `UnitPasCubeScreen.pas`. We will clean the process environment and run the process using `TProcess` to obtain the system's architecture (e.g. `x86_64` or `aarch64`).
- **Alternatives Considered**: Using compiler directives (e.g., `{$IFDEF CPUX86_64}`) which would only capture compile-time target architecture, whereas running `uname -m` retrieves the actual runtime host system architecture.

### 2. Determine GOverlay Packaging Type
- **Approach**: Prepend the `GOVERLAY_PACKAGE_TYPE` environment variable to the PasCube execution command in `overlayunit.pas` based on GOverlay's existing `GetGOverlayInstallationType` helper. Inside PasCube (`UnitPasCubeScreen.pas`), retrieve this variable, with fallbacks checking standard sandbox environment variables (`FLATPAK_ID` and `APPIMAGE`).
- **Alternatives Considered**: Reading the GOverlay config file to pass the package type, but environment variables are much simpler, standard, and robust for spawned subprocesses.

### 3. Track Benchmark Duration
- **Approach**: Store the value of `fBenchmarkTimer` at the end of the benchmark run (before entering the results screen) into a new `BenchmarkDuration: Double` field in `TBenchmarkResult`. This value stops accumulating when exiting the active benchmark phases.
- **Alternatives Considered**: Measuring time by checking system wall clock time difference, but `fBenchmarkTimer` already accurately accumulates frame delta times during the active benchmark phases.

### 4. Dialog Box Height Adjustments
- **Approach**: Increase the confirmation box height `boxH` from `34.0 * charHeight` to `38.0 * charHeight` in both `IsSubmitConfirmButtonHovered` and the drawing logic in `UnitPasCubeScreen.pas` to prevent UI overlap. Draw the new fields sequentially below "Client ID".

## Risks / Trade-offs

- **[Risk]** Process execution overhead when querying `uname -m`.
  - *Mitigation*: Query the architecture once when results are being prepared or on submission, and keep a timeout of 1 second on the process.
