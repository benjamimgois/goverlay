## Purpose

Defines visual asset requirements, vector definitions, and multi-resolution rendering fidelity for the GOverlay application icon and branding identity.

## ADDED Requirements

### Requirement: Modernized Slate-Navy and Cyan HUD Icon
The system SHALL provide a modernized official GOverlay application icon featuring a centered HUD display visor with a diagonal Slate Navy to Cyan gradient (`#141B23` to `#3CD0F6`) and four corner framing brackets in vibrant Neon Cyan (`#30BEF0`).

#### Scenario: Displaying application icon in system launcher and desktop environments
- **WHEN** GOverlay is launched or displayed in desktop environments (GNOME, KDE Plasma, XFCE, Steam Deck)
- **THEN** the icon displays the clean, symmetrical HUD visor and glowing cyan framing brackets with high contrast on both dark and light desktop themes.

### Requirement: Multi-Resolution Icon Hierarchy
The system SHALL provide pre-rendered PNG icon assets across standard desktop resolutions (`128x128`, `256x256`, `512x512`, and button/tray sizes) along with a scalable SVG master asset.

#### Scenario: Installing and packaging desktop assets
- **WHEN** GOverlay is packaged or installed (DEB, RPM, Flatpak, AppImage)
- **THEN** the standard icon directory hierarchy (`data/icons/`) contains crisp multi-resolution PNG files and the master SVG asset.

### Requirement: Visual Consistency Across Branding Assets
The system SHALL synchronize the updated Slate Navy & Cyan HUD symbol across header logo and splash screen assets (`goverlay_logo.png`, `goverlay_splash_small.png`).

#### Scenario: Displaying splash screen and window header branding
- **WHEN** the application starts up or displays the main form header
- **THEN** the brand logo matches the updated icon palette and geometric styling.
