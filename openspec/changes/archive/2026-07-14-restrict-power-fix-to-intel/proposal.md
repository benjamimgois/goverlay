## Why

On non-Intel CPUs (such as AMD), the Intel-specific powercap driver features (RAPL compatibility layer exposing `/sys/class/powercap/intel-rapl:0/energy_uj`) might still exist, causing GOverlay's fix prompt and button to trigger/show incorrectly. The fix is meant for Genuine Intel CPUs and should not be offered on AMD platforms.

## What Changes

- Implement `IsIntelCPU: Boolean` in `Tgoverlayform` to detect GenuineIntel CPUs via `/proc/cpuinfo`.
- Hide the `intelpowerfixBitBtn` on non-Intel CPUs.
- Restrict `cpupowerCheckBoxClick`'s proactive check to run only on Intel CPUs.

## Capabilities

### New Capabilities
- `restrict-power-fix-to-intel`: Restricts Intel CPU power monitoring fix and visibility only to GenuineIntel CPUs.

### Modified Capabilities
- `proactive-intel-power-fix`
- `persistent-intel-power-fix`

## Impact

- Affected files: `overlayunit.pas`.
