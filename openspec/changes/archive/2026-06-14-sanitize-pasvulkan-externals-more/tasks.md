## 1. Remove Unused External Library Directories

- [x] 1.1 Delete directory `pascube_src/pasvulkan/externals/kraft/`
- [x] 1.2 Delete directory `pascube_src/pasvulkan/externals/pasgltf/`
- [x] 1.3 Delete directory `pascube_src/pasvulkan/externals/rnl/`
- [x] 1.4 Delete directory `pascube_src/pasvulkan/externals/pasterm/`
- [x] 1.5 Delete directory `pascube_src/pasvulkan/externals/pinja/`

## 2. Update Search Paths

- [x] 2.1 Edit `pascube_src/pascube.lpi` to remove the deleted search paths (`kraft/src`, `rnl/src`, and `pasgltf/src`)

## 3. Verification

- [x] 3.1 Run `make clean && make` to verify GOverlay and PasCube build successfully on Linux
- [x] 3.2 Run `./pascube --version` to verify the benchmark launches and runs correctly without any issues
