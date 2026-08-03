# Change Proposal: Change DLSS Enabler Channel to Stable

## Why
DLSS Enabler is currently downloaded and cached into `~/.local/share/goverlay/dlssenabler-edge/`, and when selected in the GOverlay UI, the channel dropdown (`optversionComboBox`) displays "Bleeding-edge" (index 1). The DLSS Enabler build should be considered the "Stable Channel" (index 0) instead, downloading to `~/.local/share/goverlay/dlssenabler-stable/`.

## What
- Update DLSS Enabler cache directory from `dlssenabler-edge` to `dlssenabler-stable` in `bgmod_resources.pas`, `optiscaler_update.pas`, `bgmod.lpr`, and `bgmod-uninstaller.lpr`.
- Update `optversionComboBox.ItemIndex` to `0` ("Stable Channel") when DLSS Enabler is active in `optiscaler_tab.pas` and `overlayunit.pas`.
- Ensure `bgmod-uninstaller` cleans up `dlssenabler-stable` (and legacy `dlssenabler-edge` if present) during global uninstallation.
- Update main specs in `openspec/specs/upscalers-dlss-enabler/spec.md`.
