## ADDED Requirements

### Requirement: CPU and GPU Maximum Power Detection
The system MUST query the CPU and GPU maximum power usage in Watts (W) during the benchmark run.
- For CPU power: read from RAPL `/sys/class/powercap/intel-rapl/intel-rapl:0/energy_uj` by computing the difference over time, falling back to `/sys/class/hwmon/hwmon*/power1_input` or `power1_average`.
- For GPU power: query `/sys/class/hwmon/hwmon*/power1_average` for AMD/Intel, falling back to `nvidia-smi --query-gpu=power.draw` for NVIDIA.

#### Scenario: Successful CPU and GPU power collection
- **WHEN** the benchmark runs
- **THEN** the system monitors and records the peak power consumed by the CPU and GPU.

### Requirement: GOverlay Version Telemetry
The system MUST detect the GOverlay version passed to it via the `--version` command line parameter.

#### Scenario: Successful GOverlay version detection
- **WHEN** the benchmark starts with the `--version` argument
- **THEN** the system saves the version to submit it in the payload.


## MODIFIED Requirements

### Requirement: Display Frequencies in Submission Confirmation Dialog
The system MUST render the detected CPU and GPU maximum frequencies, maximum temperatures, temperature deltas, maximum power consumption, and GOverlay version in the confirmation overlay dialog presented to the user before submitting results.

#### Scenario: Rendering frequencies in confirmation dialog
- **WHEN** the submit confirmation dialog is active
- **THEN** it renders the CPU/GPU max frequencies, CPU/GPU max temperatures and deltas, CPU/GPU max powers, and GOverlay version before the confirmation buttons.
