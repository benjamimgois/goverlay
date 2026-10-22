## Context

GOverlay displays an Active GPU selector in the MangoHud Visual tab within `FVisualGpuBar`. Historically, `pcidevComboBox` was populated with raw 7-character PCI bus IDs (e.g. `3:00.0`) and paired with `gpudescEdit` to show the raw `lspci` string. Modern MangoHud only requires numeric zero-based GPU indices for `gpu_list`.

See `proposal.md` for motivation.

## Goals / Non-Goals

**Goals:**
- Provide a helper function `ExtractGpuMarketName` that cleans and extracts commercial GPU names from `lspci` output.
- Populate `pcidevComboBox` with items formatted as `GPU <index>: <Clean Market Name>` (e.g., `GPU 0: AMD Radeon RX 7900 XTX`).
- Expand `pcidevComboBox` across the full width of the `FVisualGpuBar` panel and hide `gpudescEdit`.
- Maintain seamless bidirectional serialization with MangoHud's `gpu_list=0`, `gpu_list=1`, and `gpu_list=0,1` ("Use both GPUs").

**Non-Goals:**
- Querying runtime GPU APIs (e.g. Vulkan/OpenGL extensions) at startup; `lspci` remains fast, reliable, and decoupled from display servers.

## Decisions

### 1. GPU Name Extraction Algorithm (`ExtractGpuMarketName`)
- Parse the raw `lspci` output:
  - Strip revision info `(rev XX)`.
  - Detect vendor (`AMD`, `NVIDIA`, `Intel`).
  - Extract the innermost bracketed name `[...]` (which typically contains the commercial chip/board name such as `[GeForce RTX 4070]` or `[Radeon RX 7900 XT/...]`).
  - Strip redundant vendor corporation prefixes and ensure the vendor name is prepended once.
  - Prefix with `GPU <i-1>: ` when adding to `pcidevComboBox`.

### 2. UI Adjustment in `mangohud_ui.pas`
- In `InitializeTab`:
  - `gpudescEdit.Visible := False;`
  - Set `pcidevComboBox.Anchors := [akLeft, akTop, akRight];`
  - Set `pcidevComboBox.Left := 11;`
- In `ReflowVisualTab`:
  - Adjust `pcidevComboBox.Width := FVisualGpuBar.ClientWidth - 22;`

### 3. Config Synchronization
- `overlay_config.pas` and `mangohud_ui.pas` already map `pcidevComboBox.ItemIndex` to `gpu_list=0`, `gpu_list=1`, and `gpu_list=0,1` (via `Tag`). No change to config key logic is required.

## Risks / Trade-offs

- **[Unusual or generic lspci output]** → `ExtractGpuMarketName` falls back gracefully to cleaned full string if bracket patterns are absent.
