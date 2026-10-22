## Why

When users configure Lossless Scaling (`lsfg-vk`) in GOverlay or open the configuration file from the hamburger menu ("Open config file"), the `lsfg.toml` file in `gameconfig/global/` or game profile directories may either contain the upstream sample template (which only defines `vkcube`, `benchmark`, and `Genshin`) or be opened without reflecting the current UI settings. Furthermore, if Lossless Scaling is disabled, `lsfg.toml` is deleted entirely rather than preserving the `pascube` configuration.

GOverlay uses `pascube` as its default Vulkan 3D preview and benchmark tool. When launching `pascube` for preview with frame generation, `lsfg-vk` requires an `exe = "pascube"` entry in the active `lsfg.toml` file.

## What Changes

- **Synchronize configuration before opening:** When clicking "Open config file" from the hamburger menu on the Lossless Scaling tab, ensure `SaveLosslessConfig` / `WriteLsfgTomlConfig` generates the current configuration before launching the external editor.
- **Ensure `pascube` and `vkcube` presence:** Guarantee that any generated `lsfg.toml` (and default templates copied or initialized) includes entries for both `pascube` and `vkcube`.
- **Non-destructive configuration management:** Ensure `lsfg.toml` remains valid and readable with `pascube` definitions without leaving blank or stale upstream templates.

## Capabilities

### New Capabilities
- `lossless-scaling-config`: Manages the generation, persistence, and synchronization of `lsfg.toml` configuration files for Lossless Scaling (`lsfg-vk`), ensuring `pascube` preview profiles and game executables are always properly configured.

### Modified Capabilities
<!-- None -->

## Impact

- `lossless_scaling_tab.pas`: `WriteLsfgTomlConfig`, `SaveLosslessConfig`, and initial template handling.
- `overlayunit.pas`: `openConfigFileMenuItemClick` handler when active tab is `losslessScalingTabSheet`.
