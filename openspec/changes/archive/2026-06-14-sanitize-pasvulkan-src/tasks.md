## 1. Remove Unused Directories

- [x] 1.1 Delete directory `pascube_src/pasvulkan/src/tools/`
- [x] 1.2 Delete directory `pascube_src/pasvulkan/src/old/`

## 2. Remove Unused Scene3D Files

- [x] 2.1 Delete all `PasVulkan.Scene3D*` files under `pascube_src/pasvulkan/src/`

## 3. Remove Other Unused Feature Files

- [x] 3.1 Delete unused VR, RISC-V, FileFormats, and other individual units (OpenVR, RISCVEmulator, FileFormats.*, simple job executor, etc.) from `pascube_src/pasvulkan/src/`

## 4. Verification

- [x] 4.1 Run `make clean && make` to verify GOverlay and PasCube build successfully on Linux
- [x] 4.2 Run `./pascube --version` to verify the benchmark launches and runs correctly without any issues
