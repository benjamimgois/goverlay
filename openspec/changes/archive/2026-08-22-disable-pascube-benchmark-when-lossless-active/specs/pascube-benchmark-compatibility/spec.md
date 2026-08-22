## ADDED Requirements

### Requirement: Disallow Benchmark When Lossless Scaling Is Active
When PasCube detects that Lossless Scaling (LSFG-VK) is active (via `--lossless-scaling` / `--lsfg-active` parameter or `LSFG_CONFIG` / `ENABLE_LSFGVK` environment variables):
1. PasCube SHALL disable the "Start benchmark" button on the main idle menu, rendering it in a dimmed non-interactive state.
2. PasCube SHALL display an explanatory notification banner on the idle menu informing the user that benchmarks are disabled because Lossless Scaling is active.
3. PasCube SHALL reject any attempt to start a benchmark run via mouse click, keypress, or shortcut.
4. PasCube SHALL refuse to save or submit benchmark results if Lossless Scaling frame generation is detected.
5. PasCube SHALL continue rendering the 3D rotating cubes preview and allow viewing previous benchmark results history.

#### Scenario: PasCube launched with Lossless Scaling active
- **WHEN** PasCube is executed with `--lossless-scaling` or with `LSFG_CONFIG` set in the environment
- **THEN** the "Start benchmark" button is disabled and visually dimmed
- **AND** a warning banner is displayed explaining that benchmarks cannot run while Lossless Scaling is enabled
- **AND** clicking the "Start benchmark" button has no effect.

#### Scenario: Accessing previous benchmark results while Lossless Scaling is active
- **WHEN** PasCube is executed with Lossless Scaling active and historical benchmark results exist in `benchmark_results.json`
- **THEN** the "View results" button remains enabled and clickable
- **AND** the user can browse previous benchmark scores and hardware telemetry.
