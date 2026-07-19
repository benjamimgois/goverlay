## Context

When clicking "What's New" in the GOverlay settings menu, the application runs `GetReleaseNotes` synchronously on the main GUI thread. This executes a synchronous `curl` process that blocks the user interface until the request completes (or times out).

## Goals / Non-Goals

**Goals:**
- Make the manual changelog retrieval ("What's New" click) asynchronous.
- Eliminate any GUI freezing/blocking when retrieving release notes.

**Non-Goals:**
- Alter the layout or styling of the changelog popup.
- Cache the release notes locally across different versions.

## Decisions

### Decision 1: Re-use `TChangelogFetchThread` for the menu item click

- **Approach**: Replace the synchronous call to `GetReleaseNotes` inside `whatsNewMenuItemClick` with instantiating and running `TChangelogFetchThread`.
- **Rationale**: `TChangelogFetchThread` is a pre-existing background thread class that was added to prevent startup deadlocks. Reusing this class minimizes code duplication and leverages the existing thread-safe LCL `Synchronize` mechanism to display the popup.

## Risks / Trade-offs

- **[Risk]**: If the user clicks the menu item multiple times while a request is pending, multiple threads could be spawned, potentially leading to multiple popup windows opening when they resolve.
- **[Mitigation]**: The network request completes fast under normal circumstances. Even if multiple threads run, LCL forms are safely instantiated sequentially on the main thread via `Synchronize`. We can also disable the menu item temporarily if we wanted, but simple asynchronous execution is a massive improvement over freezing the application.
