## Context

The current CPU power reporting on Intel platforms inside MangoHud requires read permissions on `/sys/class/powercap/intel-rapl:0/energy_uj`. By default, modern Linux kernels restrict this file to root-only read access due to security concerns (side-channel attacks). GOverlay has a button to fix this temporarily for the current session, but the fix is lost on reboot, and the UI never displays the correct state on startup.

## Goals / Non-Goals

**Goals:**
- Provide a persistent fix via a custom udev rule `/etc/udev/rules.d/70-intel-rapl.rules`.
- Maintain the option for a temporary chmod-based fix.
- Auto-detect CPU RAPL support and readability of `energy_uj` at startup to configure the button visibility and color indicator.
- Support removing the persistent udev rule directly from the GOverlay UI.

**Non-Goals:**
- We do not support direct modification of `/sys` permissions without `pkexec` authorization.
- We do not support AMD Ryzen power fixes via this button (AMD users use drivers like `zenpower` which are configured differently).

## Decisions

- **Udev Rule Approach**: A custom udev rule is chosen as the most standard, clean, and reliable way to set persistent permissions on virtual sysfs powercap nodes.
- **Udev rule content**:
  ```udev
  ACTION=="add|change", SUBSYSTEM=="powercap", KERNEL=="intel-rapl*", RUN+="/bin/chmod o+r /sys/%p/energy_uj"
  ```
- **Readability Check**: Try opening `/sys/class/powercap/intel-rapl:0/energy_uj` with `TFileStream(..., fmOpenRead or fmShareDenyNone)` inside a try-except block to verify user-level readability.

## Risks / Trade-offs

- **Risk**: Setting read permissions on `energy_uj` exposes the system to side-channel CPU energy vulnerabilities (e.g., PLATYPUS).
  - *Mitigation*: GOverlay already warning dialog presents this security trade-off. We will keep this warning prominent.
- **Risk**: `pkexec` dialog is shown to the user.
  - *Mitigation*: Necessary for both temporary and permanent system-wide changes.
