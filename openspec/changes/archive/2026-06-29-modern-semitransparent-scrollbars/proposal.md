## Why

Default desktop widgetset scrollbars in Linux (Qt6/GTK) can appear wide, bulky, and visually outdated, consuming valuable screen real estate and clashing with GOverlay's modern MD3 dark UI aesthetic.

## What Changes

- Implement central QSS stylesheet styling for `QScrollBar` controls in `themeunit.pas`.
- Apply thin (8px), semitransparent, rounded pill scrollbars across all scrollable containers (`TScrollBox`, `TMemo`, `TListBox`, `TListView`) when themes are applied.

## Capabilities

### New Capabilities
- `modern-semitransparent-scrollbars`: Styles all application scrollbars with modern, narrow, semitransparent rounded pills.

### Modified Capabilities
<!-- None -->

## Impact

- `themeunit.pas`: Central theme procedure updated to apply QSS scrollbar styling to scrollable controls.
