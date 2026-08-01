## 1. Release Parsing & goverlay.vars Updates

- [x] 1.1 In `optiscaler_update.pas` (`DownloadAndExtractDlssEnabler`), parse the release body from `bygalacos/OptiScalerBuilder` to extract `DLSS Enabler` version (`4.8.10.11`) and integrated `OptiScaler` version (`v0.10.0-pre1`).
- [x] 1.2 Write `dlssenablerversion` and `optiscalerversion` to `dlssenabler-edge/goverlay.vars`.

## 2. Software Status & Targeted Update Checking

- [x] 2.1 Update `TOptiUpdateThread.Execute` and `SyncUpdateUI` in `optiscaler_update.pas` to check `bygalacos/OptiScalerBuilder` when DLSS Enabler is enabled (`UPSCALER_TYPE=1`), displaying update status for DLSS Enabler instead of OptiScaler.
- [x] 2.2 Update `UpdateButtonClick` in `optiscaler_update.pas` to execute DLSS Enabler update (`DownloadAndExtractDlssEnabler`) when DLSS Enabler is selected.
- [x] 2.3 Verify `LoadVersionsFromFile` in `optiscaler_update.pas` populates `OptiScaler` and `DLSS Enabler` labels accurately when DLSS Enabler is active.

## 3. Verification & Testing

- [x] 3.1 Build `goverlay` and verify compilation.
- [x] 3.2 Verify Software Status card labels and update button behavior with DLSS Enabler enabled.
