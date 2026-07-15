## Why

To enhance UX, checking the "CPU Power" checkbox should automatically offer to fix Intel RAPL energy file permissions if they are not readable and RAPL is supported on the CPU. This removes the need for manual discovery of the fix button.

## What Changes

- Register an `OnClick` handler for `cpupowerCheckBox` (`cpupowerCheckBoxClick`).
- In `cpupowerCheckBoxClick`, check if the checkbox is checked, if RAPL is supported (file exists), and if the file is readable.
- If the file is not readable, trigger the Intel power fix configuration flow (dialogs) immediately.

## Capabilities

### New Capabilities
- `proactive-intel-power-fix`: Proactive execution of the Intel power fix configuration upon checking CPU Power display option.

### Modified Capabilities
- `persistent-intel-power-fix`

## Impact

- Affected files: `overlayunit.pas`, `overlayunit.lfm`.
