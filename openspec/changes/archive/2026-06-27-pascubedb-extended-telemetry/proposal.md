## Why

PascubeDB requires deeper hardware and system context from benchmark reports to analyze performance accurately across Linux setups. Capturing display server type, native resolution/refresh rate, desktop environment, storage type, Vulkan driver implementation, and CPU/GPU thermal deltas provides critical telemetry without requiring root/sudo privileges.

## What Changes

- Add user-mode collection for 6 system telemetry variables: Display Server, Resolution & Refresh Rate, Desktop Environment / Window Manager, Main Storage Type, Vulkan Driver, and CPU/GPU Thermal Deltas.
- Implement robust fallback handling to return `"N/D"` when any telemetry item is inaccessible or fails to collect.
- Integrate initial thermal snapshot before benchmark stress and peak thermal sampling during benchmark run to compute CPU and GPU temperature deltas.
- Attach formatted telemetry fields to the benchmark report (JSON/CSV) sent to PascubeDB.

## Capabilities

### New Capabilities
- `pascube-extended-telemetry`: Extended user-mode telemetry collection (display, storage, Vulkan driver, thermal deltas) formatted for PascubeDB reports.

### Modified Capabilities
- `pascube-benchmark-compatibility`: Modify benchmark payload structure to include the new telemetry fields.

## Impact

- `goverlay` core telemetry / benchmark reporting module.
- Benchmark report output schema (JSON/CSV payload sent to PascubeDB).
- System execution dependencies checked at runtime (`xrandr`, `lsblk`, `vulkaninfo`, sysfs `/sys/class/hwmon` & `/sys/class/drm`).
