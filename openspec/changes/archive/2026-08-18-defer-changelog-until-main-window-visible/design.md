# Design: Defer Changelog Popup Until Main Window Is Visible

## Context

GOverlay displays a "What's New" release notes modal dialog (`ShowChangelogPopup`) on the first run of a new version.
Separately, if required DLLs (OptiScaler / DLSS Enabler) are missing, `StartupDownloadsAsync` hides the main window and displays a minimal boot splash dialog (`ShowBootSplash`).

Because both were scheduled concurrently via `QueueAsyncCall` in `FormShow`, the release notes fetch thread would synchronize its GUI presentation while `StartupDownloadsAsync` was running its event-pump download loop, rendering the changelog dialog directly over the splash screen.

## Goals / Non-Goals

**Goals:**
- Guarantee that `ShowChangelogPopup` only displays after the boot splash has closed and the main `goverlayform` is fully visible.
- Prevent any background changelog thread synchronization from popping up while `FSplashForm` is active or `goverlayform` is hidden.

**Non-Goals:**
- Changing the content or appearance of the changelog popup dialog itself.
- Altering the download logic in `StartupDownloadsAsync`.

## Decisions

### 1. Chain Changelog Check to the End of Startup Sequence
- In `overlayunit.pas` (`FormShow`):
  - Do not call `Application.QueueAsyncCall(@ShowChangelogAsync, 0)` unconditionally.
  - If `(not TestMode) and IsBGModInitialized`, call `Application.QueueAsyncCall(@StartupDownloadsAsync, 0)`.
  - Otherwise, call `Application.QueueAsyncCall(@ShowChangelogAsync, 0)`.
- In `StartupDownloadsAsync`:
  - If `not NeedsDownload`: call `Application.QueueAsyncCall(@ShowChangelogAsync, 0)` and `Exit`.
  - If `NeedsDownload`: execute downloads with splash, call `HideBootSplash`, `Self.Show`, `RefreshOsStatusDots`, and then call `Application.QueueAsyncCall(@ShowChangelogAsync, 0)`.

### 2. Defensive Guard in `TChangelogFetchThread.DoShowChangelog`
- In `DoShowChangelog`:
  ```pascal
  procedure TChangelogFetchThread.DoShowChangelog;
  begin
    if Assigned(goverlayform) and ((not goverlayform.Visible) or Assigned(goverlayform.FSplashForm)) then
    begin
      // Re-queue to show once main form is visible and splash is dismissed
      Application.QueueAsyncCall(@goverlayform.ShowChangelogAsync, 0);
      Exit;
    end;
    ShowChangelogPopup(FVersion, FReleaseNotes);
  end;
  ```
- **Rationale**: Provides defense-in-depth in case any other async call or manual trigger attempts to show the dialog while the window is hidden or splash is active.

## Risks / Trade-offs

- **Risk**: Delaying changelog check until after downloads might add a brief delay on slow network connections if downloads take time.
  - **Mitigation**: This is the intended user experience: user first sees files downloading with progress bar, then lands on the main application interface where the "What's New" highlights appear.
