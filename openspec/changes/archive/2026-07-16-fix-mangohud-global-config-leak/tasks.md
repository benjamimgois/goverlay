## 1. MangoHud Tab Entry Optimization

- [x] 1.1 In `overlayunit.pas`, locate `mangohudLabelClick` and change the conditional `LoadMangoHudConfig` call so that it loads unconditionally when switching to the tab.

## 2. Verification

- [x] 2.1 Recompile and run GOverlay.
- [x] 2.2 Verify that navigating to global config mode and then entering the MangoHud tab correctly displays the global settings.
- [x] 2.3 Verify that navigating to a game config context and entering the MangoHud tab correctly displays the game's specific settings.
