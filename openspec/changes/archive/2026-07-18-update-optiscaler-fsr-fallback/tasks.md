## 1. Update FSR stable fallback in optiscaler_update.pas

- [x] 1.1 Update `FsrStableVal := '4.1';` to `FsrStableVal := '4.1.1';` in the interactive update block (`UpdateButtonClick`) of `optiscaler_update.pas`
- [x] 1.2 Update `FsrStableVal := '4.1';` to `FsrStableVal := '4.1.1';` in the auto-install block of `optiscaler_update.pas`

## 2. Verification

- [x] 2.1 Build the GOverlay application to verify it compiles successfully
- [x] 2.2 Verify that the application launches successfully headlessly
