## Why

The Pascube benchmark telemetry currently lacks critical hardware performance and versioning details when submitting benchmarks. Specifically, CPU maximum temperature, CPU temperature delta, CPU maximum power consumption, GPU maximum power consumption, and the active GOverlay version are not reported. Gathering and displaying these metrics before submission will provide richer database telemetry for hardware comparison and improve user confidence by showing exactly what metrics are sent.

## What Changes

- **Collect CPU Maximum Temperature & Delta**: Retrieve CPU peak thermal values and calculate delta compared to benchmark start, similar to GPU thermals.
- **Collect CPU and GPU Max Power**: Dynamically monitor and record peak power usage in Watts (W) for both CPU and GPU.
- **Track GOverlay Version**: Retrieve the current GOverlay version from the launching environment parameters.
- **JSON Telemetry Payload Extension**: Update the benchmark submit API payload to include the new keys: `cpu_max_temp`, `cpu_temp_max`, `cpu_temp_delta`, `cpu_delta_temp`, `cpumaxpower`, `gpumaxpower`, and `goverlayversion`.
- **Submit Confirmation UI Update**: Enhance the confirmation dialog layout (dialog height and vertical text placements) to display these 5 new telemetry values to the user before they click "Yes" to submit.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `pascube-extended-telemetry`: Extended to collect and display CPU maximum temperature, CPU temperature delta, CPU maximum power, GPU maximum power, and GOverlay version in the submit process and confirmation dialog.

## Impact

- **Affected Code**: `pascube_src/src/UnitPasCubeScreen.pas` (telemetry parsing, draw loop monitoring, confirmation UI drawing, button collision handling, local results history load/save).
- **External Tools**: `nvidia-smi` (for GPU power), sysfs RAPL and hwmon paths (for CPU power and CPU temperature).
