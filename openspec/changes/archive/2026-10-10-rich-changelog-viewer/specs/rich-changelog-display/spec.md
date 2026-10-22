# Spec Delta

## Purpose

Provides a rich visual presentation for Goverlay release changelogs, displaying formatted headers, bulleted lists, and embedded images within a dedicated modal dialog.

## ADDED Requirements

### Requirement: Rich changelog presentation
The system SHALL parse release changelog text and render headers, bullet points, and plain text as visually distinct formatted elements instead of raw Markdown or unrendered HTML markup.

#### Scenario: Render Markdown headers and bullet lists
- **WHEN** the changelog contains Markdown headers (e.g. `###`) and list items (e.g. `- `)
- **THEN** the system displays headers with prominent font styling and list items with clean bullet markers and automatic line wrapping.

#### Scenario: Hide raw HTML image markup from text stream
- **WHEN** the changelog text contains HTML image tags such as `<img ... src="..." />`
- **THEN** the raw markup is omitted from the textual display and converted into visual image components.

### Requirement: Asynchronous image loading and caching
The system SHALL load changelog images asynchronously in the background and cache downloaded image assets locally so the dialog opens immediately without UI freezes.

#### Scenario: Display placeholder before image completes
- **WHEN** a changelog with remote images is opened
- **THEN** the dialog displays instantly with placeholder boxes for pending images while downloads proceed in the background.

#### Scenario: Image display upon successful download
- **WHEN** an image finishes downloading
- **THEN** the system replaces the placeholder with the rendered image scaled proportionally to fit the container width.

#### Scenario: Image caching for subsequent opens
- **WHEN** an image has already been downloaded for a version changelog
- **THEN** the system loads the cached image from disk without performing redundant network requests.

### Requirement: Dialog sizing and layout
The system SHALL display the changelog popup in a fixed window dimension of approximately 680x520 pixels with smooth vertical scrolling for content exceeding the viewport.

#### Scenario: Viewing long changelog content
- **WHEN** the rendered changelog height exceeds the dialog viewport
- **THEN** the dialog provides a vertical scrollbar matching Goverlay's dark theme styling, allowing the user to smoothly scroll through all sections and images.
