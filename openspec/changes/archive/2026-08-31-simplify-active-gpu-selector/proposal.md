## Why

In the Visual tab, the "Active GPU" section currently displays two separate controls: a narrow ComboBox showing raw PCI IDs (e.g. `3:00.0`) and a wide read-only Edit box showing raw unformatted `lspci` output. This layout is a legacy from early MangoHud versions that required PCI ID strings. Modern MangoHud selects GPUs strictly by device index in `gpu_list` (`0`, `1`, `0,1`). Replacing the redundant controls with a single, full-width ComboBox displaying cleaned market names with GPU index prefixes simplifies the UI and makes GPU selection intuitive.

## What Changes

- Replace the two-component layout (PCI ID combobox + raw description edit box) with a single full-width ComboBox displaying cleaned commercial GPU names with index prefixes (e.g., `GPU 0: AMD Radeon RX 7900 XTX`, `GPU 1: Intel UHD Graphics 770`).
- Implement an `lspci` string sanitation helper in Pascal that extracts commercial vendor and model names, stripping revision tags and internal motherboard codes.
- Map the selected ComboBox index directly to MangoHud's `gpu_list` configuration (`gpu_list=0`, `gpu_list=1`), preserving the "Use both GPUs" option (`gpu_list=0,1`) when multiple GPUs are detected.
- Hide `gpudescEdit` and expand `pcidevComboBox` to occupy the full width of the `FVisualGpuBar` card.

## Capabilities

### New Capabilities
- `mangohud-active-gpu-selector`: Simplified Active GPU selector with clean market names, GPU index prefixes, and direct mapping to MangoHud `gpu_list`.

### Modified Capabilities
<!-- None -->

## Impact

- `overlayunit.pas`: GPU detection loop sanitized to populate clean market names with `GPU <index>:` prefixes into the ComboBox.
- `mangohud_ui.pas`: `FVisualGpuBar` layout adjusted to span the ComboBox across full card width and hide `gpudescEdit`.
- `overlay_config.pas`: `gpu_list` config serialization verified to map seamlessly from the ComboBox index.
