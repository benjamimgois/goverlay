# Capability Spec: Boot Splash UI Redesign

## MODIFIED Requirements

### Requirement: Boot Splash Branding Banner
- GOverlay SHALL render `data/goverlay_branding.png` as the main centered header image on the boot splash screen.
- GOverlay SHALL replace separate 48x48 icon and "Goverlay" text labels with the unified branding banner image.

#### Scenario: Displaying header branding banner
- **WHEN** GOverlay launches and displays the boot splash screen
- **THEN** the branding banner image `data/goverlay_branding.png` is displayed centered at the top of the splash window.

### Requirement: Embedded Percentage Progress Bar
- The splash screen progress bar SHALL have a height of at least 24px.
- GOverlay SHALL display the progress percentage readout (e.g. `42%`) centered directly inside the progress bar track.

#### Scenario: Progress update with embedded percentage
- **WHEN** download or initialization progress updates (e.g. `42%`)
- **THEN** the progress bar fills to 42% and the text `42%` is displayed centered inside the progress bar.

### Requirement: Interactive Terminal Log Details Window
- The splash screen SHALL render a "Details" button (`>_ Details`) at the bottom-right corner.
- WHEN the user clicks "Details", GOverlay SHALL display a dark-themed log modal window (`FSplashLogForm`) showing real-time initialization and download terminal logs.

#### Scenario: User opens log details modal
- **WHEN** the user clicks the "Details" button on the boot splash
- **THEN** a log window opens displaying all real-time startup log messages in a monospace dark text view.
