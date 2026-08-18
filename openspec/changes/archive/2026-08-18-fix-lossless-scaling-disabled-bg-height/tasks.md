# Tasks: Fix Background Height and Viewport Gap on Lossless Scaling Tab

## 1. Background Panel Viewport Expansion
- [x] 1.1 In `lossless_scaling_tab.pas`, add `Math` to the interface `uses` clause if needed.
- [x] 1.2 In `lossless_scaling_tab.pas` (`ReflowLosslessScalingTab`), update `FLsBgPanel` height using `FLsBgPanel.SetBounds(0, 0, W, Max(FLsScrollBox.ClientHeight, CurY))`.

## 2. Window Resize Integration
- [x] 2.1 In `overlayunit.pas` (`FormResize`), add `ReflowLosslessScalingTab(ContentW)` after `ReflowOptiScalerTabNew`.

## 3. Verification & Testing
- [x] 3.1 Build GOverlay with `lazbuild --build-mode=Release goverlay.lpi`.
- [x] 3.2 Run test suites (`make test-logic`, `make test-gui`).
