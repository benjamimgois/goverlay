## 1. Remove Unused Testdata and Demos

- [x] 1.1 Delete testdata under `pascube_src/pasvulkan/externals/pasdblstrutils/testdata/`
- [x] 1.2 Delete Delphi/FPC projects and binaries under `pascube_src/pasvulkan/externals/pasgltf/` (specifically `bin/`, `src/viewer/`, `src/combineanimations/`, and `src/smartcombineanimations/`)

## 2. Remove Non-Linux-64 Platform Libraries

- [x] 2.1 Delete Windows, macOS, Android, and Linux 32-bit library directories under `pascube_src/pasvulkan/libs/` (specifically all folders except `libktxlinux64` and `sdl20linux64`)

## 3. Clean Leftover Filesystem Remnants

- [x] 3.1 Completely delete leftover local untracked directories `flre/`, `pasllm/`, and `poca/` from `pascube_src/pasvulkan/externals/`

## 4. Verification

- [x] 4.1 Run `make clean && make` to verify that both GOverlay and PasCube build successfully on Linux
- [x] 4.2 Run `./pascube --version` to verify the benchmark launches and runs correctly
