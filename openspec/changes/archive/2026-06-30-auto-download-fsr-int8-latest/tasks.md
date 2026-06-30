## 1. Directory and File Copying Logic

- [x] 1.1 Implement FSR4_LATEST directory creation and amd_fidelityfx_upscaler_dx12.dll copy inside TOptiscalerTab.UpdateButtonClick (in optiscaler_update.pas)
- [x] 1.2 Implement FSR4_INT8 directory creation and download logic inside TOptiscalerTab.UpdateButtonClick (in optiscaler_update.pas)
- [x] 1.3 Modify the sync bash script in TOptiscalerTab.UpdateButtonClick to copy the FSR4_INT8 and FSR4_LATEST directories to bgmod/

## 2. Headless Auto-Installer Updates

- [x] 2.1 Implement FSR4_LATEST directory creation and copy inside AutoInstallOptiScaler (in optiscaler_update.pas)
- [x] 2.2 Implement FSR4_INT8 directory creation and curl download inside AutoInstallOptiScaler (in optiscaler_update.pas)

## 3. Verification and Compilation

- [x] 3.1 Verify compilation of the project using make
- [x] 3.2 Verify directory structures are correctly created on update/install
