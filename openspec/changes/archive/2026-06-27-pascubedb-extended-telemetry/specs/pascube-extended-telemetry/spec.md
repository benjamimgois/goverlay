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
