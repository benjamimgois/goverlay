## 1. Remove Unused GOverlay Units and Forms

- [x] 1.1 Delete obsolete units: `logpathunit.pas`, `logpathunit.lfm`, `customeffectsunit.pas`, `customeffectsunit.lfm`, `fgmod_resources.pas`, `gfxlaunch.pas`, and `atstringproc_htmlcolor.pas`

## 2. Update Project Configuration File

- [x] 2.1 Update `<Units>` list in `goverlay.lpi` to remove deleted units and re-sequence unit entries (`Unit0` to `Unit12`)

## 3. Clean Unused Vulkan Engine Components

- [x] 3.1 Delete unused Vulkan projects under `pascube_src/pasvulkan/projects/`
- [x] 3.2 Delete unused Vulkan tools under `pascube_src/pasvulkan/src/tools/`
- [x] 3.3 Delete unused Vulkan tests under `pascube_src/pasvulkan/src/tests/`
- [x] 3.4 Delete unused Vulkan external libraries: `flre`, `pasllm`, `pasriscv`, `pasterm`, `pinja`, and `poca` under `pascube_src/pasvulkan/externals/`

## 4. AI Agent Configuration Cleanup

- [x] 4.1 Untrack `.agents/` and `.rtk/` directories from version control
- [x] 4.2 Update `.gitignore` to explicitly ignore `.agents/` and `.rtk/`

## 5. Verification and Compilation

- [x] 5.1 Run `make clean && make` to verify that both GOverlay and PasCube build successfully without errors
- [x] 5.2 Verify that the application starts up and that the benchmark (PasCube) launches and runs successfully
