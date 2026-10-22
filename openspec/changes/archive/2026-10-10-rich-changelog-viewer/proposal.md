# Proposal

## Why

Currently, the "What's New in Goverlay" changelog popup uses a standard plain-text `TMemo` control to display release notes fetched from the GitHub API. GitHub release notes contain Markdown headers, bullet lists, and embedded HTML image tags (`<img src="..." />`). Because `TMemo` does not interpret markup or load remote media, users see unrendered tags and raw markdown syntax, resulting in a degraded visual experience. Replacing this with a formatted, block-based native viewer with asynchronous image loading will significantly improve presentation while maintaining Goverlay's dark MD3 aesthetic.

## What Changes

- Replace the `TMemo` in `TChangelogForm` (`changelogunit.pas`) with a native scrollable container (`TScrollBox`).
- Increase the changelog window fixed size to approximately 680x520 to comfortably accommodate release text and images without horizontal clipping.
- Implement a parser that segments release notes into structured blocks:
  - Header blocks (`###`, `##`): rendered with styled, prominent typography matching Goverlay's theme.
  - List items / bullet points (`- `, `* `): rendered with clean bullet markers and word-wrapped text.
  - Image blocks (`<img ... src="..." />` and `![alt](url)`): rendered as responsive `TImage` controls embedded within card containers.
- Implement background asynchronous downloading of release images using `curl` with local disk caching (`~/.cache/goverlay/changelog/`), avoiding GUI freezes and instantly displaying placeholders that update once images load.
- Maintain proportional aspect ratio scaling for images to fit within the container width.

## Capabilities

### New Capabilities

- `rich-changelog-display`: Displays GitHub release changelogs using structured typography, bulleted lists, and asynchronously loaded images inside a styled native modal.

### Modified Capabilities

*(None)*

## Impact

- Affected files: `changelogunit.pas`, optionally `overlayunit.pas` or `themeunit.pas`.
- Dependencies: Relies on existing system dependencies (`curl`, LCL standard controls, `Graphics`/`FPReadPNG`/`FPReadJPEG`). No new third-party packages or C libraries required.
- Compatibility: Flatpak, AppImage, AUR, and distro packages are fully compatible without modification.
