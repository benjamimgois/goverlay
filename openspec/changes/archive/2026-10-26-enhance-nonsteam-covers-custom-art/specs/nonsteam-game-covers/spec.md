# Spec Delta

## Purpose

Provides resilient discovery, multi-format loading, local provider integration (Heroic, Lutris, game folder), proportional rendering, and custom artwork assignment for non-Steam game covers in GOverlay.

## ADDED Requirements

### Requirement: Multi-Source Local Cover Discovery
The system SHALL search local artwork sources before performing remote queries for non-Steam games, checking the GOverlay cache, game installation folder, Heroic Games Launcher libraries, and Lutris coverart.

#### Scenario: Existing local game directory cover found
- **WHEN** discovering artwork for a non-Steam game
- **THEN** the system checks `<SubPath>` for `cover`, `poster`, or `folder` image files before remote network search

#### Scenario: Heroic cover found by directory or title
- **WHEN** discovering artwork for a non-Steam game
- **THEN** the system queries Heroic installation configs and maps the game to its cached icon in `~/.config/heroic/icons/` or Flatpak equivalent

#### Scenario: Lutris cover found by slug
- **WHEN** discovering artwork for a non-Steam game
- **THEN** the system derives the game slug and checks for artwork in `~/.local/share/lutris/coverart/` or Flatpak equivalent

### Requirement: Multi-Format Image Support
The system SHALL support loading and caching non-Steam game covers in `.png`, `.jpg`, and `.jpeg` formats.

#### Scenario: PNG cover loaded from cache or local library
- **WHEN** a non-Steam game has a `.png` cover in the cache, Heroic, or game folder
- **THEN** the system loads and renders the PNG graphic onto the game card

### Requirement: Aspect-Ratio Preserving Scaling
The system SHALL scale non-portrait and non-standard aspect ratio cover art onto the 2:3 portrait game card using a proportional center-crop fill without stretching or squishing.

#### Scenario: Square or wide cover image rendered
- **WHEN** rendering a cover image with a non-2:3 aspect ratio (such as 1:1 or 16:9)
- **THEN** the system crops the excess dimensions centered and draws the image filled across the card bounds preserving original proportions

### Requirement: Resilient Remote Download and Cache Purge
The system SHALL validate remote cover downloads with `--fail` using temporary files, purge corrupt or truncated files ($\le 2048$ bytes), and retry or yield to fallback rendering.

#### Scenario: Failed download yields to retry or fallback
- **WHEN** a remote cover download returns an HTTP error or file size $\le 2048$ bytes
- **THEN** the temporary file is discarded, no corrupt cache file is retained, and fallback rendering is triggered

### Requirement: Custom Cover Selection and Reset
The system SHALL provide menu actions in the game card popup menu to allow users to select custom artwork from disk or reset cached cover art.

#### Scenario: User sets custom cover
- **WHEN** the user selects "Set custom cover..." from the game card menu and chooses an image file
- **THEN** the system copies the image to the non-Steam cover cache and refreshes the card and per-game preview immediately

#### Scenario: User resets cover
- **WHEN** the user selects "Reset cover art" from the game card menu
- **THEN** the system deletes the cached cover and fallback files for the game and re-evaluates cover discovery
