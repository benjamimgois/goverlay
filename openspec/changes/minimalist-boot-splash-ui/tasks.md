# Implementation Tasks: Minimalist Boot Splash UI

- [x] 1. Redesign Boot Splash Window Layout & Painting
  - [x] 1.1 In `overlayunit.pas`, update `ShowBootSplash` form dimensions to `560x360 px` and add custom gradient painting in `FSplashForm.OnPaint`.
  - [x] 1.2 Add header controls: 48x48 logo icon, bold white "Goverlay" title label, and "git testing build" subtitle label.

- [x] 2. Update Lower-Third Controls & Status Text Formatting
  - [x] 2.1 Create centered `FSplashActionLabel` above the progress bar for action phrases (`Ação: Extraindo core...`).
  - [x] 2.2 Style progress bar with slim 12px height and cyan accent color (`RGBToColor(56, 189, 201)`).
  - [x] 2.3 Align `FSplashDetailLabel` to the left and `FSplashPercentLabel` to the right below the progress bar.
  - [x] 2.4 Update `UpdateBootSplash` to format and sync action, detail, and percentage labels dynamically.

- [x] 3. Build & Verification
  - [x] 3.1 Rebuild project using `lazbuild -B goverlay.lpi`.
  - [x] 3.2 Verify splash screen appearance during startup pre-downloads against design mockup.
