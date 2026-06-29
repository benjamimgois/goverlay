## Context

GOverlay updates are tracked via `GVERSION` (e.g. `1.8.5`). Users often skip reading release notes on GitHub releases. A first-launch dialog will display the summary directly inside GOverlay.

## Goals / Non-Goals

**Goals:**
- Detect first launch of `GVERSION` by comparing against `ChangelogSeenVersion` in `goverlay.ini`.
- Fetch release body asynchronously or upon startup from GitHub API (`https://api.github.com/repos/benjamimgois/goverlay/releases`).
- Display modal form with styled dark theme and dismiss button.
- Persist `ChangelogSeenVersion = GVERSION` on dismissal.

**Non-Goals:**
- Complex markdown/HTML rendering (plain text formatted release notes in a styled scrollable memo/label is sufficient).

## Decisions

### Decision 1: Async GitHub API Release Body Fetch
In `goverlay_system.pas`, implement `FetchReleaseNotes(const AVersion: string): string` using FPHTTPClient to query `https://api.github.com/repos/benjamimgois/goverlay/releases`. Fallback to generic highlights if offline or tag not found.

### Decision 2: Dedicated Form or Modal Component
Create `changelogunit.pas` (similar to `howto.pas`) styled with dark background, modern header, scrollable text area for release notes, and a "Continuar" action button.

## Risks / Trade-offs

- **Network Availability**: If offline on first launch, a friendly default message ("Confira as novidades no repositório do GOverlay") will be displayed so the dialog is still useful.
