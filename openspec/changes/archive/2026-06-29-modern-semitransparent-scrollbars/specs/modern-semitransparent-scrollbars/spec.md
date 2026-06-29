# Capability: modern-semitransparent-scrollbars

Styles all application scrollbars with modern, narrow, semitransparent rounded pills.

## ADDED Requirements

### Requirement: Modern semitransparent scrollbar styling
GOverlay SHALL style scrollbars across all scrollable controls (`TScrollBox`, `TMemo`, `TListBox`, `TListView`) using narrow, semitransparent QSS rules.

#### Scenario: Scrolling in any tab or control
- **WHEN** user interacts with or views a scrollable container in GOverlay
- **THEN** the scrollbar appears as a narrow (8px) semitransparent rounded pill without arrow buttons, highlighting smoothly on hover.
