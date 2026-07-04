## Context

The Pascube benchmark submissions lack clock frequency specifications for the CPU and GPU. This design outlines how we gather these maximum frequencies natively on Linux (without requiring root/sudo permissions) and submit them with the benchmark payload to a Google Apps Script spreadsheet backend.

## Goals / Non-Goals

**Goals:**
- Natively retrieve maximum CPU clock frequency in MHz.
- Natively retrieve maximum GPU clock frequency in MHz for Intel, AMD, and NVIDIA hardware.
- Persist these values to local JSON history file.
- Send these values as `cpumaxfreq` and `gpumaxfreq` in the API upload payload.

**Non-Goals:**
- Real-time/dynamic frequency tracking during the benchmark phases.
- Supporting Windows-specific frequency retrieval since Pascube is a Linux Vulkan benchmark.

## Decisions

### Decision 1: CPU Max Frequency Source
- **Choice**: Read `/sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq` (falling back to `scaling_max_freq`).
- **Alternative Considered**: Parsing `/proc/cpuinfo`.
- **Rationale**: `/proc/cpuinfo` only shows the current frequency at the exact moment of reading, which might be lower due to idle scaling. `/sys` paths show the actual maximum hardware clock rate. We scan through cpu0 up to cpu127 to find the first valid directory.

### Decision 2: GPU Max Frequency Source
- **Choice**: Scan sysfs paths for Intel and AMD, and fallback to `nvidia-smi` CLI query for NVIDIA.
- **Intel Rationale**: `/sys/class/drm/card*/device/gt_max_freq_mhz` (or `gt/gt0/max_freq_mhz`) exposes the maximum GT core frequency directly as a string integer.
- **AMD Rationale**: `/sys/class/drm/card*/device/pp_dpm_sclk` displays clock levels and current state. Parse and retrieve the highest MHz value listed.
- **NVIDIA Rationale**: Execute `nvidia-smi --query-gpu=clocks.max.gr --format=csv,noheader,nounits` to get maximum core graphics clock.

### Decision 3: Submission Payload Integration
- **Choice**: Add `"cpumaxfreq"` and `"gpumaxfreq"` directly to the JSON payload prepared in `SubmitBenchmarkResults` of `UnitPasCubeScreen.pas`.
- **Rationale**: Matches the column names specified for the spreadsheet.

### Decision 4: Displaying Frequencies in Confirmation UI
- **Choice**: Display `CPU Max Freq` and `GPU Max Freq` as new lines in the confirmation overlay. Increase the dialog height (`boxH`) from `46.0 * charHeight` to `49.0 * charHeight` to fit the two new rows.
- **Rationale**: Keeps confirmation UI aligned with the exact payload submitted. Button coordinates scale dynamically with `boxH`.

## Risks / Trade-offs

- **[Risk] Sandbox restrictions in Flatpak** → The app may not have direct access to `/sys/devices/` or `/sys/class/drm/`.
  - *Mitigation*: Fallback default to `0` instead of crashing. Flatpaks with standard permissions typically have read-only access to `/sys` directories, and `nvidia-smi` works if GPU access is granted.
- **[Risk] Multiple GPUs or CPUs** → Systems with multiple CPUs/GPUs might report frequency for the first device.
  - *Mitigation*: For CPU, `cpu0` is standard. For GPU, we scan `card0` up to `card8` and return the first matched non-zero frequency.
