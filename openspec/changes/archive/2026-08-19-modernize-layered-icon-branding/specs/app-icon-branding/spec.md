## MODIFIED Requirements

### Requirement: Modernized Slate-Navy and Cyan HUD Icon
The system SHALL provide a modernized official GOverlay application icon featuring a primary screen visor with a diagonal Slate Navy to Sapphire Blue gradient (`#0F172A` to `#38BDF8`), an outer Sapphire Blue neon stroke with crisp white core highlight, and two cascading offset neon overlay layer frames (`#4895EF` and `#2563EB`) representing stacked screen overlays.

#### Scenario: Displaying application icon in system launcher and desktop environments
- **WHEN** GOverlay is launched or displayed in desktop environments (GNOME, KDE Plasma, XFCE, Steam Deck)
- **THEN** the icon displays the layered cascading overlay geometry with vivid contrast on both dark and light desktop themes.

### Requirement: Visual Consistency Across Branding Assets
The system SHALL synchronize the modernized layered overlay symbol across header logo and splash screen assets (`goverlay_logo.png`, `goverlay_splash.png`, `goverlay_splash_small.png`).

#### Scenario: Displaying splash screen and window header branding
- **WHEN** the application starts up or displays the main form header
- **THEN** the brand logo displays the modernized layered 'O' matching the official application icon.
