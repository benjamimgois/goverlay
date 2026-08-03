# Tasks: Separate OptiScaler Options into 4 Independent Sub-Cards

- [x] 1. Data Structures & Sub-Card Initialization
  - [x] 1.1 Declare `FOsMainSec`, `FOsSpatialSec`, `FOsTemporalSec` panels in `overlayunit.pas` (or `optiscaler_tab.pas`).
  - [x] 1.2 Initialize sub-card panels in `TOptiScalerTabHelper.InitOptiScalerTab` with `SubCardPaint`.
  - [x] 1.3 Reparent controls to `FOsMainSec`, `FOsSpatialSec`, `FOsTemporalSec`, and `FOsFakeSec`.

- [x] 2. Reflow & Layout Updates
  - [x] 2.1 Update `TOptiScalerTabHelper.ReflowOptiScalerTabNew` to calculate 4 equal sub-card widths (`ColW`).
  - [x] 2.2 Position `FOsMainSec`, `FOsSpatialSec`, `FOsTemporalSec`, and `FOsFakeSec` across the Options card.
  - [x] 2.3 Adjust local relative positions for controls inside each sub-card.

- [x] 3. Cleanup & Verification
  - [x] 3.1 Remove `FOsOptiDiv1` / `FOsOptiDiv2` line divider fields and `SubCardPaint` divider drawing code.
  - [x] 3.2 Build and verify visual alignment and theme consistency in Qt6.
