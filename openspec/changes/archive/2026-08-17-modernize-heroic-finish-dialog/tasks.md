# Tasks: Modernize Heroic Finish Dialog Guide

## 1. Finish Dialog Modern Heroic Redesign

- [x] 1.1 Implement modern Heroic window Canvas renderer in `PaintAnimHeroic` in `finish_dialog.pas`:
  - Draw dark window frame (`#0C1015`) with title `<GameTitle> (Settings)` and close `✕` icon.
  - Draw horizontal tab strip (`WINE | OTHER | ADVANCED | CLOUD SAVES | GAMESCOPE | LEGACY`) with `ADVANCED` highlighted in Heroic cyan (`#55EBD8`) and solid cyan underline.
  - Draw vertical scrollbar track and thumb on the right indicating scrolled-down state on `ADVANCED` tab.
  - Draw `Wrapper Command:` header, `Wrapper` and `Arguments` subheaders in cyan, dual input boxes, and green/teal `[+]` add button (`#00C9B7`).
  - Animate pulsing cyan border glow, blinking cursor, and animated guide arrow pointing to the `Wrapper` input box.
- [x] 1.2 Update Heroic step-by-step instruction text in `UpdateForPlatform` in `finish_dialog.pas` to reference `Settings › Advanced › scroll down to "Wrapper Command"`.

## 2. Testing and Validation

- [x] 2.1 Update GUI automated test in `tests/gui/gui_test_cases.pas` to verify Heroic rendering and updated step instructions.
- [x] 2.2 Run full test suite (`make test` and `make test-logic`) and verify clean release build.
