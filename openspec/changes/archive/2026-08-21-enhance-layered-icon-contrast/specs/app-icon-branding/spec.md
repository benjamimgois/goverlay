## MODIFIED Requirements

### Requirement: Modernized Slate-Navy and Cyan HUD Icon
The system SHALL provide a modernized official GOverlay application icon featuring a primary screen visor with a diagonal Slate Navy to Sapphire Blue gradient (`#111822` to `#4895EF`), an outer solid white frame with subtle inner slate accent, and two high-contrast cascading offset neon overlay layer frames in Sky Blue (`#38BDF8`) and Light Sapphire (`#60A5FA`).

#### Scenario: Displaying application icon in system launcher and desktop environments
- **WHEN** GOverlay is launched or displayed in desktop environments (GNOME, KDE Plasma, XFCE, Steam Deck)
- **THEN** the icon displays the layered cascading overlay geometry with luminous contrast across both dark and light desktop themes.

### Requirement: Visual Consistency Across Branding Assets
The system SHALL synchronize the Sky Blue and Light Sapphire cascading overlay symbols across header logo and splash screen assets (`goverlay_logo.png`, `goverlay_splash.png`, `goverlay_splash_small.png`) while maintaining exact calibrated image dimensions.

#### Scenario: Displaying splash screen and window header branding
- **WHEN** the application starts up or displays the main form header
- **THEN** the brand logo displays the modernized layered 'O' with high-contrast Sky Blue and Light Sapphire layers matching the official application icon.
