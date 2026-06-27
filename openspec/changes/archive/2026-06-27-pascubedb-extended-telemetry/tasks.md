## 1. Environment & Telemetry Collectors

- [x] 1.1 Implement user-mode display server and resolution collector (`XDG_SESSION_TYPE`, `xrandr`, sysfs `/sys/class/drm/*/modes`).
- [x] 1.2 Implement desktop environment detection and normalization (`XDG_CURRENT_DESKTOP`, `DESKTOP_SESSION`).
- [x] 1.3 Implement storage classification using `lsblk` and rotational sysfs queues.
- [x] 1.4 Implement Vulkan driver implementation resolver (`vulkaninfo --summary`, driver libraries).

## 2. Thermal Monitoring & Lifecycle

- [x] 2.1 Implement sysfs thermal monitor baseline acquisition (`temp_start`).
- [x] 2.2 Implement sampling during benchmark stress to record `temp_max` and compute `temp_delta`.

## 3. Payload Integration & Formatting

- [x] 3.1 Format telemetry output structure with `"N/D"` fallbacks for all fields.
- [x] 3.2 Integrate extended telemetry fields into PascubeDB submission JSON and CSV payloads.
