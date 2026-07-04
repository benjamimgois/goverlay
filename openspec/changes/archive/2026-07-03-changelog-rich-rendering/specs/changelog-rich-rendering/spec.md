## ADDED Requirements

### Requirement: Changelog popup renders formatted HTML with images
The "What's New" changelog popup SHALL render the release notes as formatted HTML, including text formatting (bold, italic, headers, lists, links) and embedded images, instead of displaying raw markdown plain text. The HTML content SHALL be obtained server-side from GitHub via the `Accept: application/vnd.github.v3.html` API header, and rendered via `TIpHtmlPanel`.

#### Scenario: Viewing the latest official release changelog
- **WHEN** the user clicks the "What's New" menu item or the changelog auto-triggers on first launch after an update
- **THEN** the popup displays the release body with formatted text and images, not raw markdown.

#### Scenario: Fallback when body_html is unavailable
- **WHEN** the GitHub API returns a release without a `body_html` field (e.g. legacy release or API change)
- **THEN** the popup falls back to displaying the plain `body` markdown text in the HTML panel, preserving basic readability.
