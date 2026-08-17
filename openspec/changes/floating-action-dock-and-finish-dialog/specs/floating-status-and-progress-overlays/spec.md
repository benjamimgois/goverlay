## Purpose

Provides unobtrusive floating toast notifications for automatic configuration saves and temporary floating progress overlays for background downloads.

## ADDED Requirements

### Requirement: Floating Auto-Save Toast Notification
The system SHALL display a discrete floating toast notification in the bottom-left corner of the window whenever configuration changes are automatically saved.

#### Scenario: Automatic save triggered
- **WHEN** user modifies any overlay or tweak setting triggering an automatic background save
- **THEN** GOverlay SHALL show a temporary toast notification stating `Settings saved` in English, which automatically fades out after 1.5 to 2 seconds.

### Requirement: Floating Download Progress Overlay
The system SHALL display a temporary floating progress banner during background component downloads and automatically dismiss it upon completion.

#### Scenario: Background component download starts
- **WHEN** a background download commences (such as DLSS Enabler pre-download or shader pack download)
- **THEN** GOverlay SHALL render a floating progress banner displaying percentage progress and status message in English.

#### Scenario: Background component download finishes
- **WHEN** all background downloads finish successfully
- **THEN** GOverlay SHALL hide the floating progress banner.
