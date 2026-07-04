# Extended Telemetry Specification

Collection of user-mode system variables and metrics for PascubeDB reporting.

## ADDED Requirements

### Requirement: User-Mode Display Server Detection
The system MUST detect the active display server type in Linux user-mode by inspecting the `$XDG_SESSION_TYPE` environment variable without requiring elevated permissions. If empty or inaccessible, the system SHALL fall back to `"N/D"`.

#### Scenario: Wayland environment
- **WHEN** `$XDG_SESSION_TYPE` is set to `"wayland"`
- **THEN** the system records `"wayland"` as the display server type.

#### Scenario: X11 environment
- **WHEN** `$XDG_SESSION_TYPE` is set to `"x11"`
- **THEN** the system records `"x11"` as the display server type.

#### Scenario: Missing environment variable
- **WHEN** `$XDG_SESSION_TYPE` is unset or empty
- **THEN** the system records `"N/D"` as the display server type.

### Requirement: Native Resolution and Refresh Rate Acquisition
The system MUST query the active output native resolution and refresh rate in user mode, utilizing environment-appropriate tools (`xrandr` on X11, DRM `/sys/class/drm/*/modes` or compositor utilities on Wayland). If querying fails, the system SHALL record `"N/D"`.

#### Scenario: X11 resolution extraction
- **WHEN** running under X11 and `xrandr --current` is executed
- **THEN** the system extracts the resolution and refresh rate marked with `*` (e.g., `resolution: "1920x1080"`, `refresh_rate: 144`).

#### Scenario: Wayland resolution extraction via sysfs/compositor
- **WHEN** running under Wayland
- **THEN** the system inspects `/sys/class/drm/*/modes` or active compositor CLI tools (`hyprctl`, `wlr-randr`) to parse native resolution and refresh rate.

#### Scenario: Display query failure
- **WHEN** resolution tools or sysfs paths are unavailable
- **THEN** the system sets resolution and refresh rate fields to `"N/D"`.

### Requirement: Desktop Environment and Window Manager Normalization
The system MUST inspect `$XDG_CURRENT_DESKTOP` or `$DESKTOP_SESSION` and normalize the value into standardized desktop names (e.g., `"KDE Plasma"`, `"GNOME"`, `"Hyprland"`, `"XFCE"`). If undetermined, the system SHALL return `"N/D"`.

#### Scenario: KDE detection
- **WHEN** `$XDG_CURRENT_DESKTOP` contains `"KDE"`
- **THEN** the system normalizes the value to `"KDE Plasma"`.

#### Scenario: Unrecognized desktop
- **WHEN** desktop environment variables are missing
- **THEN** the system sets the desktop environment field to `"N/D"`.

### Requirement: Primary Storage Type Classification
The system MUST classify the primary drive storage type using user-mode utilities (`lsblk -d -o NAME,ROTA,TRAN -j`) or sysfs queue rotational attributes (`/sys/block/*/queue/rotational`).

#### Scenario: NVMe SSD detection
- **WHEN** rotational indicator is `0` and transport protocol is `"nvme"`
- **THEN** the system classifies the storage type as `"NVMe SSD"`.

#### Scenario: SATA SSD detection
- **WHEN** rotational indicator is `0` and transport protocol is not `"nvme"`
- **THEN** the system classifies the storage type as `"SATA SSD"`.

#### Scenario: HDD detection
- **WHEN** rotational indicator is `1`
- **THEN** the system classifies the storage type as `"HDD"`.

### Requirement: Active Vulkan Driver Identification
The system MUST identify the active Vulkan driver implementation (e.g., `"RADV"`, `"ANV"`, `"NVK"`, `"NVIDIA Proprietary"`, `"AMDVLK"`) by executing `vulkaninfo --summary` or inspecting active graphics runtime libraries.

#### Scenario: RADV driver detection
- **WHEN** Vulkan implementation query reveals Mesa RADV driver
- **THEN** the system sets driver implementation to `"RADV"`.

#### Scenario: Vulkan detection failure
- **WHEN** Vulkan information tools fail to return driver details
- **THEN** the system records `"N/D"`.

### Requirement: CPU and GPU Thermal Delta Monitoring
The system MUST sample CPU and GPU temperatures from sysfs hardware monitor paths (`/sys/class/hwmon/hwmon*/temp*_input` or `/sys/class/thermal/thermal_zone*/temp`) to calculate thermal deltas across the benchmark lifecycle.

#### Scenario: Thermal sampling sequence
- **WHEN** benchmark stress starts, runs, and completes
- **THEN** the system records initial temperatures (`temp_start`), tracks peak temperatures (`temp_max`), and computes `temp_delta = temp_max - temp_start` for both CPU and GPU.

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
