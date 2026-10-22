## Why

Currently, several tools executed via GOverlay (such as OptiScaler, DLSS Enabler, MangoHud, and bgmod-uninstaller) either write their logs directly into the game directory or emit diagnostics to standard streams without being captured in GOverlay's central logging directory (`~/.local/share/goverlay/logs/<GameDirName>/`). This causes central logs to be empty, truncated, or missing entirely, making troubleshooting and issue diagnosis difficult for users.

## What Changes

- Add comprehensive case-insensitive log synchronization between the game directory and the central log directory for Proton/Wine DLL logs (`optiscaler.log`, `dlss-enabler.log`, `fakenvapi.log`, `bgmod-uninstaller.log`).
- Add MangoHud diagnostic output capture (`mangohud.log`) into both the central log directory and the game directory within `RunSubprocessLogger`.
- Initialize and route DLSS Enabler logs (`dlss-enabler.log` and `fakenvapi.log`) when DLSS Enabler is the active upscaler.
- Update GOverlay GUI (`overlayunit.pas` `GetActiveTabLogFile`) to distinguish between OptiScaler and DLSS Enabler in the Upscaler tab and open `dlss-enabler.log` when DLSS Enabler is selected, as well as correctly resolving `mangohud.log`.
- Ensure synchronized logs are updated both at process completion and available for inspection.

## Capabilities

### New Capabilities
- `centralized-tools-logging`: Comprehensive capture, collection, and synchronization of logs from all GOverlay-managed tools (OptiScaler, DLSS Enabler, vkSumi, MangoHud, lsfg-vk, mako, bgmod, and bgmod-uninstaller) into `~/.local/share/goverlay/logs/<GameDirName>/`.

### Modified Capabilities
<!-- None -->

## Impact

- `bgmod.lpr`: Expands `RunSubprocessLogger` to support MangoHud stderr logs; adds file-based log synchronization routine `SyncGameDirLogsToCentral` handling OptiScaler, DLSS Enabler, FakeNVAPI, and other tool logs case-insensitively; fixes case-sensitivity mismatch on `optiscaler.log`.
- `overlayunit.pas`: Updates `GetActiveTabLogFile` to resolve `dlss-enabler.log` when DLSS Enabler is chosen on the Upscaler tab, and ensures `mangohud.log` resolution.
- `bgmod-uninstaller.lpr`: Ensures uninstallation logs are mirrored to `CentralLogDir` when available.
