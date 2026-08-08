# Implementation Tasks: Boot Splash UI Redesign

- [x] 1. Branding Asset & Splash Header Update
  - [x] 1.1 Add `data/goverlay_branding.png` to repository assets.
  - [x] 1.2 In `overlayunit.pas` (`ShowBootSplash`), replace `FSplashLogoImage` (48x48) and `FSplashTitleLabel` with `FSplashBrandingImage` loading `data/goverlay_branding.png`.

- [x] 2. Thicker Progress Bar with Embedded Percentage Text
  - [x] 2.1 In `overlayunit.pas` (`ShowBootSplash`), update `FSplashProgressBar` height to 24px (`SetBounds(32, 205, SW - 64, 24)`).
  - [x] 2.2 Re-position `FSplashPercentLabel` centered directly over `FSplashProgressBar` (`taCenter`, 10pt bold white font).

- [x] 3. Terminal Log Details Modal Window
  - [x] 3.1 In `overlayunit.pas`, implement `AddSplashLog(const AMsg: string)` and thread-safe log buffer `FSplashLogList`.
  - [x] 3.2 In `overlayunit.pas`, create `FSplashDetailsButton` (`>_ Details`) at bottom right of splash screen.
  - [x] 3.3 Create `FSplashLogForm` dark modal window with monospace `TMemo` to show live startup logs on button click.
  - [x] 3.4 Hook log messages from `UpdateBootSplash` and startup procedures into `AddSplashLog`.

- [x] 4. Build & Verification
  - [x] 4.1 Rebuild GOverlay with `lazbuild`.
  - [x] 4.2 Run `./goverlay` and test splash UI branding, progress bar percentage overlay, and terminal details window.
