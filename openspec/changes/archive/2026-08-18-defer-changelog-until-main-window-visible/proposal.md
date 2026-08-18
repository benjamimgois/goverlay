# Proposal: Defer Changelog Popup Until Main Window Is Visible

## Problem Statement

When GOverlay launches and requires initial file downloads (such as downloading/extracting OptiScaler or DLSS Enabler DLLs), `StartupDownloadsAsync` hides the main window (`Self.Hide`) and displays the boot splash screen (`ShowBootSplash`).

Currently, `FormShow` queues `ShowChangelogAsync` concurrently with `StartupDownloadsAsync`. `TChangelogFetchThread` fetches GitHub release notes in the background and calls `Synchronize(@DoShowChangelog)`. Because the startup download loop continually pumps events via `Application.ProcessMessages` to refresh the progress bar, `@DoShowChangelog` executes immediately, causing the "What's New in GOverlay" dialog to render on top of the splash screen while the main application window is hidden.

## Proposed Solution

1. **Sequential Startup Flow**:
   - In `FormShow`, remove the immediate invocation of `ShowChangelogAsync`.
   - In `StartupDownloadsAsync`:
     - If downloads are needed: execute downloads with the splash screen, close the splash (`HideBootSplash`), make the main window visible (`Self.Show`), and then queue `ShowChangelogAsync`.
     - If no downloads are needed: immediately queue `ShowChangelogAsync`.
   - If `StartupDownloadsAsync` is not scheduled (e.g. `TestMode` or `not IsBGModInitialized`), queue `ShowChangelogAsync` directly from `FormShow`.

2. **Defensive Guard in `TChangelogFetchThread.DoShowChangelog`**:
   - Before calling `ShowChangelogPopup`, check whether `goverlayform` is assigned and visible (`goverlayform.Visible`) and that no splash screen is active (`not Assigned(goverlayform.FSplashForm)`).
   - If the main window is not yet visible or splash is active, defer presentation by re-queueing `ShowChangelogAsync`.

## Capabilities

### Modified Capabilities
- `release-changelog-popup`: Ensures the changelog popup is only presented when the main window is visible and fully initialized, never over the boot splash screen.

## Impact

- Clean, professional startup experience where "What's New" only appears once the main GOverlay interface is visible.
- Zero risk of modal dialogs blocking or conflicting with the boot splash download loop.
