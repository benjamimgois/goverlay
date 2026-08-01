## 1. Upscaler Type Tracking in goverlay.vars

- [x] 1.1 Update `goverlay.vars` generation in `optiscaler_update.pas` and `bgmod.lpr` to write `upscalertype=0` for OptiScaler and `upscalertype=1` for DLSS Enabler.

## 2. Upscaler Switch Detection & Cleanup in bgmod

- [x] 2.1 Implement `GetInstalledUpscalerType` function in `bgmod.lpr` to read the installed upscaler type from `goverlay.vars` in `GameDir` (checking `upscalertype`, `dlssenablerversion`, or `optiscalerversion`).
- [x] 2.2 Add upscaler switch detection logic in `bgmod.lpr` before the copy/update block.
- [x] 2.3 Implement clean upscaler purge procedure in `bgmod.lpr` when a switch is detected: remove old proxy DLLs, upscaler files, logs, and subdirectories (`OptiScaler/`, `D3D12_OptiScaler/`, `plugins/`) without deleting original game backups in `BackupsDir`.

## 3. Verification & Testing

- [x] 3.1 Build `bgmod` executable and verify build success.
- [x] 3.2 Test upscaler switching scenarios (OptiScaler -> DLSS Enabler and DLSS Enabler -> OptiScaler) to verify game directory cleanliness and backup integrity.
