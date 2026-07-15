## Context

Restrict the Intel CPU power fix options only to GenuineIntel CPUs to avoid false triggers on AMD systems.

## Goals / Non-Goals

**Goals:**
- Implement `IsIntelCPU: Boolean` in `Tgoverlayform`.
- Hide the `intelpowerfixBitBtn` if `IsIntelCPU` returns False.
- Stop the check inside `cpupowerCheckBoxClick` if `IsIntelCPU` returns False.

## Decisions

- **Detecting CPU brand**:
  Use `/proc/cpuinfo` parsing to look for the `vendor_id` line containing `GenuineIntel`.
  If found, return True; otherwise False.
- **Wiring**:
  Declare `function IsIntelCPU: Boolean;` in `Tgoverlayform`.
  Update `InitializeIntelPowerFixButton` and `cpupowerCheckBoxClick` to check `IsIntelCPU` first.
