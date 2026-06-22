## Context

On startup, GOverlay initializes the UI tabs. As part of this, the OptiScaler tab's initialization calls `CheckForUpdatesOnClick` synchronously. This function performs up to two HTTP API requests (by spawning synchronous curl processes) to fetch the latest release tag for OptiScaler and the fgmod script. Depending on the internet connection and GitHub API response time, this blocking process blocks the UI main thread for 2 to 10 seconds.

## Goals / Non-Goals

**Goals:**
- Offload the update checking network requests to a background thread to prevent UI freezing on startup.
- Provide visual feedback ("Searching for updates...") on the OptiScaler tab version area while checking.
- Ensure thread-safe updates to LCL controls upon thread completion.
- Keep the design simple and robust.

**Non-Goals:**
- Modifying the download/update installation process (`UpdateButtonClick`), which already handles GUI progress and interactivity.
- Changing how tags are compared or parsed.

## Decisions

### Decision 1: Use `TThread` subclass to perform tag fetching in the background
We will define `TOptiUpdateThread = class(TThread)` in `optiscaler_update.pas`. This thread will execute the curl processes and return the latest version tags to the main thread.
- *Alternatives considered:* Non-blocking asynchronous TProcess execution. This was rejected because parsing JSON responses and chaining multiple async processes in Pascal requires excessive event-driven boilerplate. Using a dedicated background thread is cleaner and maps directly to the existing synchronous retrieval logic.

### Decision 2: Add thread-safety parameters to tag fetching functions
Functions like `GetOptiScalerStableTag`, `GetOptiScalerPreReleaseTag`, and `GetLatestReleaseTag` show modal dialogs (`ShowMessage`) on exception. Since LCL GUI calls are unsafe in background threads, we will add an optional `ASilent: Boolean = False` parameter to these methods. When set to `True`, exceptions will be logged or captured without invoking LCL dialogs.

### Decision 3: Use `Synchronize` for UI updates
Once the thread fetches the tags, it will invoke a synchronized method (`SyncUpdateUI`) to apply the results to the UI labels, toggle buttons, and refresh the status dots on the Home tab.

## Risks / Trade-offs

- **Risk:** Concurrent update checks if the user changes the OptiScaler channel dropdown or clicks "Check for updates" repeatedly while a background check is running.
- **Mitigation:** Disable the check button (`FCheckupdBtn`) during the check. In `CheckForUpdatesOnClick`, verify if a background thread is already active; if so, skip spawning a new one. Store the thread reference in `TOptiscalerTab.FUpdateThread` and clean it up on termination.
