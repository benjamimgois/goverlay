## Why

Currently, GOverlay persists Lossless Scaling settings across two places: the `[Config]` section of `bgmod.conf` (master flag and options) and dynamically generated `lsfg.toml` files. To align Lossless Scaling with the architectural pattern used by MangoHud (`MangoHud.conf`), vkBasalt (`vkBasalt.conf`), and OptiScaler (`OptiScaler.ini`), GOverlay should load and save detailed configuration directly to/from `lsfg.toml`, leaving `bgmod.conf` with only the master toggle `GOVERLAY_LOSSLESS=1/0`.

## What Changes

- **Lossless Scaling Tab Loading**: Load all UI configuration directly by parsing `lsfg.toml` (with fallback to legacy `[Config]` / `[Env]` keys in `bgmod.conf` during transition).
- **Lossless Scaling Tab Saving**: Write all detailed options (`dll`, `multiplier`, `flow_scale`, `performance_mode`, `hdr_mode`, `experimental_present_mode`, etc.) directly to `lsfg.toml`.
- **bgmod.conf Cleanliness**: Write only `GOVERLAY_LOSSLESS=1` (or `0`) in `[Config]`, keeping `bgmod.conf` completely free of duplicate Lossless Scaling settings.
- **bgmod & Preview Execution**: Read `GOVERLAY_LOSSLESS` from `bgmod.conf`, ensure the corresponding `lsfg.toml` exists with the active process executable registered, and pass `LSFG_CONFIG=".../lsfg.toml"`.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `lossless-scaling-tab`: Configuration persistence is unified so that `lsfg.toml` is the single source of truth for all frame generation settings, while `bgmod.conf` only holds `GOVERLAY_LOSSLESS`.

## Impact

- `lossless_scaling_tab.pas`: `LoadLosslessConfig` and `SaveLosslessConfig` parse and write `lsfg.toml`.
- `bgmod.lpr`: Reads `lsfg.toml` and `bgmod.conf` `GOVERLAY_LOSSLESS`.
- `tests/gui/gui_test_cases.pas`: Updates GUI test cases to verify roundtrip through `lsfg.toml`.
