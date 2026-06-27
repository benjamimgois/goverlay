## Context

GOverlay executes benchmark runs and submits telemetry reports to PascubeDB. Currently, basic system metrics are reported. To enrich database analytics, 6 new telemetry parameters must be gathered in Linux user mode without root privileges: Display Server, Resolution & Refresh Rate, Desktop Environment, Storage Type, Vulkan Driver, and CPU/GPU Thermal Deltas.

## Goals / Non-Goals

**Goals:**
- Implement user-mode system inspection functions with zero root/sudo requirement.
- Provide graceful degradation with fallback `"N/D"` on missing utilities, permission limits, or container sandbox constraints.
- Measure thermal starting points before benchmark stress and sample peak temperatures during stress to calculate accurate thermal deltas.
- Format and attach telemetry parameters into JSON and CSV submission structures for PascubeDB.

**Non-Goals:**
- Kernel-level hardware probing or kernel module installations.
- Windows or macOS telemetry extensions (Linux user-mode focused).
- Real-time continuous thermal logging outside benchmark execution frames.

## Decisions

### Decision 1: Environment-Based and Tool-Fallback Detection for Display Metrics
- **Approach:** Inspect `$XDG_SESSION_TYPE`. On X11, execute `xrandr --current`. On Wayland, check compositor tools (`hyprctl`, `wlr-randr`) and sysfs `/sys/class/drm/*/modes`.
- **Rationale:** Wayland security policies restrict direct display querying across compositors. Multi-tool fallback guarantees reliable detection across GNOME, KDE, Hyprland, and sway.
- **Alternatives:** Hardcoding X11 queries only (fails on modern Wayland sessions).

### Decision 2: Sysfs and Utility Inspection for Primary Storage Classification
- **Approach:** Parse JSON output from `lsblk -d -o NAME,ROTA,TRAN -j` and fallback to `/sys/block/*/queue/rotational`.
- **Rationale:** `lsblk` user-mode execution provides transport (`TRAN`) and rotational (`ROTA`) flags reliably.
- **Alternatives:** Reading raw `/dev` blocks (requires root).

### Decision 3: Vulkan Implementation Resolution
- **Approach:** Parse `vulkaninfo --summary` driver details or match active dynamic libraries (`libvulkan_radeon`, `libvulkan_intel`, `nvidia_drv`).
- **Rationale:** Distinguishes open-source Mesa drivers (RADV, ANV, NVK) from proprietary stacks (AMDVLK, NVIDIA).
- **Alternatives:** Relying solely on PCI vendor IDs (doesn't distinguish RADV vs AMDVLK).

### Decision 4: Non-Blocking Asynchronous Thermal Sampling
- **Approach:** Record baseline CPU/GPU temperatures right before benchmark stress start. Spawn a lightweight polling sampler during the benchmark run to update `temp_max`. Compute `temp_delta` upon benchmark completion.
- **Rationale:** Prevents I/O polling overhead from interfering with benchmark execution metrics.
- **Alternatives:** Synchronous blocking reads per frame (causes stutter).

## Risks / Trade-offs

- **[Risk] Container Sandbox Isolation (Flatpak/AppImage)** → Mitigate by falling back to host sysfs mappings (`/run/host/sys`) or reporting `"N/D"` cleanly without crashing.
- **[Risk] Missing Sysfs Thermal Nodes** → Mitigate by searching all `/sys/class/hwmon/hwmon*` entries for valid `temp*_input` sensors and choosing primary package sensors.
