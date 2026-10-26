# Spec Delta

## MODIFIED Requirements

### Requirement: Modern Fallback Cover Rendering
The system SHALL generate fallback cover images for games without artwork or with failed/corrupted cover cache files using the official GOverlay branding logo centered on a dark card background.

#### Scenario: Fallback cover generated for game without art
- **WHEN** a game card without a cover image triggers cover generation
- **THEN** the system generates a 150x215 JPEG image with the modern GOverlay logo centered on a dark `#20242C` background
- **THEN** a companion `.fallback` marker file is created in the cache directory alongside the image

#### Scenario: Fallback cover generated when cached file is corrupt
- **WHEN** a game card has an empty or corrupt cached cover file
- **THEN** the system purges the invalid file and generates a fallback cover with the GOverlay branding logo
