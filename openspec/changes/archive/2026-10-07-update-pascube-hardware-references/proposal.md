# Proposal

## Why

The Hardware Comparison card in PasCube currently displays initial estimated Ray Tracing scores and older main score references that predate widespread community submissions. Now that the benchmark database contains thousands of verified submissions (including hundreds with Vulkan Ray Tracing), these reference scores can be calibrated against real-world benchmark data to provide accurate comparisons for end users.

## What Changes

- Calibrate `Entry Gamer PC` (RX 6600): update Ray Tracing score from estimated `520` to empirical `761` points based on real database runs (range 726–792).
- Calibrate `Mid-Range Gamer PC` (RTX 4060 Ti + R5 7600): update Main Score from `2898` (which was an R5 9600X run) to `2751` points (matching the R5 7600 run in the database) and calibrate Ray Tracing score from estimated `2100` to empirical `1713` points (matching real RTX 4060 Ti RT runs).
- Calibrate `Steam Machine` (Zen 4 + RDNA3 28CU): update Ray Tracing score from estimated `920` to architectural baseline `1250` points (proportionate to desktop RX 7600 32CU delivering 1,452 points).
- Calibrate `Steam Deck` (Van Gogh / APU 0405): update Ray Tracing score from estimated `180` to empirical peak `174` points.

## Capabilities

### Modified Capabilities
- `pascube-raytracing-benchmark`: Add requirement for calibrated hardware reference baseline scores in the benchmark comparison interface.

## Impact

- `pascube_src/src/UnitPasCubeScreen.pas`: Updates reference values in `GetHardwareReferences`.
- No impact on scoring formulas, database schemas, or submission payloads.
