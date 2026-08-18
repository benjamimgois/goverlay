# Proposal: Add Preview Pill and LSFG-VK Environment to 3D Preview on Lossless Scaling Tab

## Problem Statement

When navigating to the "Lossless Scaling" tab under the "Upscalers" category, the floating action dock currently hides the Preview button (`FFADock.UpdateForTab(False, False, False)`). Consequently, users cannot trigger a quick 3D demo (such as `pascube` or `vkcube`) directly from the Lossless Scaling tab to test and verify their `lsfg-vk` frame generation settings.
Furthermore, the `PreviewBtnClick`, `runpascubetItemClick`, and `runvkcubeItemClick` execution helpers in `overlayunit.pas` do not include `LSFGVK_*` environment variables, meaning even when `pascube` is launched, Lossless Scaling frame generation is not active during the preview.

## Proposed Solution

1. **Enable Preview Pill on Lossless Scaling Tab**:
   - In `overlayunit.pas` (`losslessScalingTabSheetShow`), configure `FFADock` via `FFADock.UpdateForTab(True, False, False)` to show `[ 👁 Preview ]` and `[ ✓ Finish ]`.
   - In `overlayunit.pas` (`optiscalerLabelClick`), if `losslessScalingTabSheet` is active, update `FFADock` accordingly.

2. **Synthesize LSFG-VK Launch Environment (`GetLosslessScalingLaunchEnv`)**:
   - Declare and implement `GetLosslessScalingLaunchEnv: string;` in `overlayunit.pas`.
   - Query `TLosslessScalingTabHelper.BuildEnvLine` when Lossless Scaling is enabled and configured (`FNavToolEnabled[2] = True`, valid `Lossless.dll` path, multiplier >= 2x).
   - Inject `GetLosslessScalingLaunchEnv` into `PreviewBtnClick`, `runpascubetItemClick`, and `runvkcubeItemClick` so `pascube` and `vkcube` run with `lsfg-vk` frame generation enabled.

## Capabilities

### Modified Capabilities
- `lossless-scaling-tab`: Adds preview pill support to the floating action dock and integrates LSFG-VK environment variables into the 3D preview runner.

## Impact

- Users can click the floating `Preview` button directly on the Lossless Scaling tab to launch `pascube` and visually verify frame generation multiplier, pacing, and flow scale settings in real time.
