## Why

The "What's New" changelog popup displays plain unformatted markdown text in a `TMemo`. GitHub release bodies contain formatting (bold, italic, headers, lists, tables, images) that improve readability significantly. Displaying the HTML-rendered version from GitHub's API makes the popup more readable and visually appealing.

## What Changes

- In `goverlay_system.pas`, the `GetReleaseNotes` curl request adds `Accept: application/vnd.github.v3.html` to receive the release body pre-rendered as HTML from GitHub. The function now reads `body_html` (falling back to `body` markdown if absent).
- In `changelogunit.pas`, the `TMemo` is replaced with `TIpHtmlPanel` from TurboPower Internet Professional (available in Lazarus). The form renders the HTML content with text formatting, images, and hyperlinks.
- Form height increases to ~520 to accommodate the richer content comfortably.

## Capabilities

### New Capabilities

- `changelog-rich-rendering`: the "What's New" popup renders release notes as formatted HTML including images.

### Modified Capabilities

_None._

## Impact

- **Affected files**: `goverlay_system.pas` (API call), `changelogunit.pas` (form UI).
- **Dependency**: `turbopower_ipro` package (already installed in Lazarus, used via `IpHtmlPanel` unit).
- **No runtime dependencies**: GitHub does the markdown→HTML conversion server-side.
- **Compatibility**: the old `ShowChangelogPopup(version, text)` signature stays the same; only the internal rendering changes.