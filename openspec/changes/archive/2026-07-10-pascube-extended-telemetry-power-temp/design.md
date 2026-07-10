## Context

The Pascube benchmark submissions lack CPU maximum temperature tracking during stress phases, CPU maximum power consumption, GPU maximum power consumption, and GOverlay version telemetry. We need to implement robust, user-mode detection of these performance metrics on Linux and present them in the submission confirmation overlay before sending the payload to the Google Apps Script spreadsheet backend.

## Goals / Non-Goals

**Goals:**
- Natively retrieve CPU maximum temperature during benchmark stress phases.
- Retrieve CPU maximum power consumption (W) using RAPL or hwmon.
- Retrieve GPU maximum power consumption (W) using sysfs or nvidia-smi.
- Capture the GOverlay version from the launch arguments.
- Show all these metrics in the submit confirmation dialog and send them in the JSON payload.

**Non-Goals:**
- Real-time power graphing (only peak/max values are submitted).
- Supporting Windows-specific power/thermal metrics.

## Decisions

### Decision 1: CPU Max Temperature Update Frequency
- **Choice**: Query `GetCPUTemperature` every 100ms in the draw loop rather than every frame.
- **Alternative**: Querying every frame.
- **Rationale**: File access every frame (e.g. 60-144 FPS) generates high system overhead and causes stutters. A 100ms polling interval is sufficient to capture peak temperature while minimizing CPU overhead.

### Decision 2: CPU Maximum Power Source
- **Choice**: Read `/sys/class/powercap/intel-rapl/intel-rapl:0/energy_uj` over time and calculate wattage (microjoules difference / time difference / 1,000,000), falling back to `/sys/class/hwmon/hwmon*/power1_input` (microwatts).
- **Alternative**: Running external tools like `turbostat` or `powerstat`.
- **Rationale**: RAPL and hwmon files are readable by non-root users in Linux user-mode, avoiding any root/sudo requirements or external dependencies.

### Decision 3: GPU Maximum Power Source
- **Choice**: Read `/sys/class/hwmon/hwmon*/power1_average` for AMD/Intel cards, and run `nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits` for NVIDIA cards.
- **Alternative**: Reading GPU PCIe power registers directly (requires root).
- **Rationale**: Standard non-root interfaces in sysfs and nvidia-smi are stable and safe to read inside the benchmark loop.

### Decision 4: Confirmation UI Layout Height
- **Choice**: Increase the confirmation dialog height (`boxH`) from `36.0 * charHeight` to `42.0 * charHeight` and adjust `IsSubmitConfirmButtonHovered` to match the exact collision box.
- **Alternative**: Adding horizontal scrollbars or making text smaller.
- **Rationale**: Making the box taller is cleaner, preserves readability, and keeps the button collision code aligned.

## Risks / Trade-offs

- **[Risk] Sandbox restrictions (Flatpak)** → May block access to `/sys/class/powercap/` or `/sys/class/hwmon/`.
  - *Mitigation*: Fallback to `'N/D'` cleanly if file reads or queries fail, preventing application crashes.
- **[Risk] Nvidia-smi execution overhead** → Running `nvidia-smi` every 100ms inside the loop could affect benchmark score.
  - *Mitigation*: Limit nvidia-smi execution to at most once per 200ms or query it asynchronously. Since we use `poUsePipes` and `nvidia-smi` is fast, a 100ms interval has negligible impact, but we will monitor it.
