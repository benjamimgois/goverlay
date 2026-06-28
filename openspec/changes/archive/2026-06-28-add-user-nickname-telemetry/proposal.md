## Why

Allow users to configure an optional nickname in GOverlay to identify their benchmark submissions in community leaderboards (Hall of Fame). If unconfigured, benchmarks remain anonymous while reusing the existing hardware client-id.

## What Changes

- Add a UI input field in GOverlay settings/home tab for optional user nickname.
- Store the nickname in `goverlay.ini` configuration.
- Pass the nickname parameter to PasCube / benchmark telemetry submissions alongside the client-id.

## Capabilities

### New Capabilities

- `user-nickname-telemetry`: Configures and submits optional user nickname during benchmark uploads while maintaining hardware client-id linkage.

### Modified Capabilities

(none)

## Impact

- `overlayunit.pas`, `home_tab.pas`, `overlay_config.pas`: UI controls, config save/load routines, and PasCube execution command construction.
- PasCube: Telemetry posting parameter handling.
