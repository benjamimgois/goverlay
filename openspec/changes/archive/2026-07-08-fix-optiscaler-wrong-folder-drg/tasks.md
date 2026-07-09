## 1. Implementation

- [x] 1.1 Update `FindUEShippingExe` in `bgmod.lpr` to ignore `BUGREPORTCLIENT` and `CRASHREPORTCLIENT` case-insensitively
- [x] 1.2 Update `FindUEShippingExe` in `bgmod-uninstaller.lpr` to ignore `BUGREPORTCLIENT` and `CRASHREPORTCLIENT` case-insensitively

## 2. Build & Verification

- [x] 2.1 Compile `bgmod` and `bgmod-uninstaller` using Free Pascal Compiler (`fpc -O3`)
- [x] 2.2 Rebuild GOverlay using `lazbuild` to ensure all components compile without error
- [x] 2.3 Verify the folder resolution logic using a simulated directory structure mimicking "Deep Rock Galactic: Rogue Core"
