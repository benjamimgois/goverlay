# Tasks: Modern Action Buttons and Clean Hero Layout in PasCube

## 1. Idle Menu Cleanup & Modern Start Buttons

- [x] 1.1 Remove hardware specifications pill card rendering in `DrawMenuOverlay` within `pascube_src/src/UnitPasCubeScreen.pas` and verify the bottom viewport has clean visual clearance.
- [x] 1.2 Implement Cyber-Accent Goverlay styles for "Start benchmark" (primary CTA with Goverlay Cyan `#30BEF0` and glyph `▶`) and "View results" (secondary Ghost with glyph `≡`) in `DrawMenuOverlay`.
- [x] 1.3 Update idle menu hit-testing logic in `IsStartButtonHovered` and `IsViewResultsButtonHovered` to match new button dimensions, padding, and labels.

## 2. Results Screen Action Buttons Modernization

- [x] 2.1 Update "Return to Menu" in `DrawResultsOverlay` to use primary CTA Goverlay Cyan styling with glyph `◀`.
- [x] 2.2 Update "Submit results" in `DrawResultsOverlay` to use secondary Ghost Goverlay styling with glyph `↑` while preserving submission status state tints (submitting, submitted, error).
- [x] 2.3 Update "Clear results" in `DrawResultsOverlay` to use refined Goverlay dark danger styling (subtle crimson border, deep red tinted fill, glyph `✕`).
- [x] 2.4 Synchronize hit-testing functions `IsReturnButtonHovered`, `IsSubmitButtonHovered`, and `IsClearButtonHovered` with the new labels and geometry.

## 3. Build & Visual Verification

- [x] 3.1 Compile PasCube via `lazbuild` in `pascube_src/` and verify compilation succeeds without errors.
- [x] 3.2 Verify interactive hover behavior, hitboxes, and visual aesthetics of both screens in PasCube.
