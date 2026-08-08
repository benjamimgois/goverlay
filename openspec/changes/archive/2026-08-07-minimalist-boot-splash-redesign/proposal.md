# Proposal: Boot Splash UI Redesign with Branding Banner & Terminal Details Window

## Summary

Redesign the GOverlay boot splash screen by replacing the small 48x48 icon and text with the GitHub branding banner image (`data/goverlay_branding.png`), embedding progress percentage directly inside a thicker progress bar, and adding a bottom-right "Details" terminal button that opens a real-time initialization and download log modal window.

## Motivation

Users need visually clear feedback and troubleshooting capability during startup downloads (e.g. OptiScaler, DLSS Enabler, Streamline SDK). A modern splash screen with a prominent GitHub branding logo, integrated percentage readout, and a clickable Terminal log window enables users to diagnose download or environment issues immediately without cluttering the main splash UI.

## Proposed Changes

- **Asset Addition**:
  - Add `data/goverlay_branding.png` (GitHub branding banner with "Goverlay - Linux gaming tools, made easy").

- **`overlayunit.pas` Boot Splash Redesign**:
  - **Header Branding**: Replace `FSplashLogoImage` (48x48) and `FSplashTitleLabel` ("Goverlay") with a single `FSplashBrandingImage` displaying `data/goverlay_branding.png` centered at top.
  - **Embedded Percentage Progress Bar**: Increase progress bar height to 24px and render progress percentage text (e.g., `42%`) centered directly inside the progress bar track.
  - **Details Button**: Add a bottom-right button `FSplashDetailsButton` with caption `>_ Details` or terminal icon.
  - **Real-time Terminal Log Window (`FSplashLogForm`)**:
    - Add real-time log collection (`AddSplashLog`) to record all startup initialization and download log messages.
    - When `FSplashDetailsButton` is clicked, display a dark-themed log form (`FSplashLogForm`) with a monospace `TMemo` showing live logs.

## Scope

- Modifies `overlayunit.pas` and `optiscaler_update.pas`.
- Adds `data/goverlay_branding.png`.
