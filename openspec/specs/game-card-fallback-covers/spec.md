# game-card-fallback-covers Specification

## Purpose
Provides a consistent, modern branded visual placeholder for game cards in the Games tab when box art or cover images cannot be fetched from Steam or web searches.

## Requirements

### Requirement: Modern Fallback Cover Rendering
The system SHALL generate fallback cover images for games without artwork using the official GOverlay branding logo centered on a dark card background.

#### Scenario: Fallback cover generated for game without art
- **WHEN** a game card without a cover image triggers cover generation
- **THEN** the system generates a 150x215 JPEG image with the modern GOverlay logo centered on a dark `#20242C` background
- **THEN** a companion `.fallback` marker file is created in the cache directory alongside the image

### Requirement: Fallback Icon Resource Priority
The fallback cover generator SHALL prioritize local application resources when loading the GOverlay logo before falling back to system-wide directories.

#### Scenario: Local asset loaded first
- **WHEN** generating a fallback cover image
- **THEN** the system resolves the logo from the application `assets/icons/goverlay.png` or `data/icons/` before checking `/usr/share/icons/`

### Requirement: Refresh Legacy Cached Fallback Covers
The system SHALL support regenerating legacy fallback cover images when cached covers have a `.fallback` marker.

#### Scenario: Legacy fallback cover refreshed
- **WHEN** game cards are loaded and a cached cover has a `.fallback` companion file
- **THEN** the system ensures the rendered card displays the modern GOverlay logo
