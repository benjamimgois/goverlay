# Change Proposal: Minimalist Boot Splash UI

## Problem Statement
The current boot splash screen uses a basic dark box layout. A refined, modern, dark-blue gradient splash UI with clean typography, clear visual hierarchy, sub-captions ("git testing build"), centered action verbs above a cyan progress bar, and left/right aligned detail & percentage labels is needed to elevate GOverlay's visual identity.

## Proposed Solution
Redesign the boot splash window (`FSplashForm`) with a modern, flat dark-navy gradient background canvas, header branding with logo, title ("Goverlay"), subtitle ("git testing build"), centered action label (`Ação: Extraindo core...`), sleek cyan/teal progress bar, and bottom left/right status labels for component detail and percentage.

## Capabilities
- `minimalist-boot-splash`: Minimalist boot splash window with dark blue gradient background, header branding, centered action label, cyan progress bar, and component detail & percentage status labels.

## User Experience
- When GOverlay performs startup downloads:
  - Displays a 560x360 px borderless dark-navy gradient splash window centered on screen.
  - Header shows 2D logo, bold "Goverlay" title, and "git testing build" sub-caption.
  - Middle space remains clean and open.
  - Lower third shows centered action text above a cyan progress bar, with component details (left) and percentage (right) below the bar.
  - Smoothly hides when startup downloads complete to reveal main application UI.
