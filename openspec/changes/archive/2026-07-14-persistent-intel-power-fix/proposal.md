## Why

The current "Intel CPU Power monitoring fix" button (`intelpowerfixBitBtn`) inside GOverlay applies a temporary permissions fix (`chmod o+r /sys/class/powercap/intel-rapl:0/energy_uj`) that is lost on system reboot.
Furthermore, the button does not check the status of the file on startup, meaning the button indicator is always showing as unapplied. AMD/non-Intel users are also shown the button unnecessarily.

## What Changes

- Hide or disable `intelpowerfixBitBtn` on non-Intel or systems lacking `/sys/class/powercap/intel-rapl:0/energy_uj`.
- Initialize `intelpowerfixBitBtn`'s state indicator (ImageIndex) at startup by checking if the target file is currently readable.
- Implement a persistent fix option using a custom udev rule (`/etc/udev/rules.d/70-intel-rapl.rules`) that survives reboots.
- Provide a prompt allowing the user to choose between a Permanent fix, a Temporary fix, or canceling.
- Allow the user to disable and remove the persistent udev rule if it is already active.

## Capabilities

### New Capabilities
- `persistent-intel-power-fix`: A permanent, udev-based fix configuration system for Intel CPU power monitoring.

### Modified Capabilities

## Impact

- Affected files: `overlayunit.pas`.
- Requires root authorization (`pkexec`) to create/remove the udev rule.
