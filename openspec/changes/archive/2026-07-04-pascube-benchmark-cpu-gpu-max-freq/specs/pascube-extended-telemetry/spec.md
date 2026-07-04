## ADDED Requirements

### Requirement: CPU Maximum Frequency Detection
The system MUST detect the CPU maximum frequency on Linux by scanning sysfs paths (`/sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq` or `/sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq`) and converting the retrieved value from kHz to MHz (dividing by 1000).

#### Scenario: Successful CPU maximum frequency detection
- **WHEN** the benchmark initializes and scans sysfs for CPU maximum frequency
- **THEN** the system resolves the value in MHz as a non-zero integer.

#### Scenario: Fallback when sysfs is unavailable
- **WHEN** the CPU frequency sysfs paths are not accessible or do not exist
- **THEN** the system returns `0` as the default CPU maximum frequency.

### Requirement: GPU Maximum Frequency Detection
The system MUST query the GPU maximum graphics frequency in MHz depending on the active GPU vendor:
- For Intel GPUs: read `/sys/class/drm/card*/device/gt_max_freq_mhz` or `/sys/class/drm/card*/device/gt/gt0/max_freq_mhz`.
- For AMD GPUs: read `/sys/class/drm/card*/device/pp_dpm_sclk` and extract the maximum frequency value.
- For NVIDIA GPUs: run `nvidia-smi` to extract the max graphics clock.

#### Scenario: Intel GPU maximum frequency detection
- **WHEN** running on an Intel GPU and the sysfs max frequency file exists
- **THEN** the system parses the value in MHz.

#### Scenario: AMD GPU maximum frequency detection
- **WHEN** running on an AMD GPU and `pp_dpm_sclk` is present
- **THEN** the system parses the clock options and extracts the maximum MHz value.

#### Scenario: NVIDIA GPU maximum frequency detection
- **WHEN** running on an NVIDIA GPU and `nvidia-smi` is available
- **THEN** the system queries `nvidia-smi --query-gpu=clocks.max.gr --format=csv,noheader,nounits` to get the frequency in MHz.

#### Scenario: Fallback when GPU frequency cannot be determined
- **WHEN** all vendor-specific detection methods fail or are not applicable
- **THEN** the system returns `0` as the default GPU maximum frequency.

### Requirement: Display Frequencies in Submission Confirmation Dialog
The system MUST render the detected CPU and GPU maximum frequencies in the confirmation overlay dialog presented to the user before submitting results.

#### Scenario: Rendering frequencies in confirmation dialog
- **WHEN** the submit confirmation dialog is active
- **THEN** it renders "CPU Max Freq: [value] MHz" and "GPU Max Freq: [value] MHz" before the confirmation buttons.
