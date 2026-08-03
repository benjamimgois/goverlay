# Tasks: Change DLSS Enabler Channel to Stable

- [x] 1. Update `GetDlssEnablerPath` in `bgmod_resources.pas` to return `dlssenabler-stable`.
- [x] 2. Update `bgmod.lpr` to use `dlssenabler-stable` when `UpscalerType = '1'`.
- [x] 3. Update `bgmod-uninstaller.lpr` to clean `dlssenabler-stable` (and legacy `dlssenabler-edge`) on global uninstall.
- [x] 4. Update `optiscaler_update.pas` download, extraction, and update checking routines to target `dlssenabler-stable`.
- [x] 5. Update `optiscaler_tab.pas` and `overlayunit.pas` to select `optversionComboBox.ItemIndex := 0` ("Stable Channel") when DLSS Enabler is active.
- [x] 6. Verify DLSS Enabler download, UI channel display, and file deployment.
