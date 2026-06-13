## 1. Core PasCube Screen Implementation

- [x] 1.1 Add the `GetBenchmarkResultsFilePath` function in `UnitPasCubeScreen.pas` to resolve writeable user config directory
- [x] 1.2 Update results saving in `SaveResultsJSON` to write to `GetBenchmarkResultsFilePath`
- [x] 1.3 Update results loading in `LoadResultsJSON` to read from `GetBenchmarkResultsFilePath`
- [x] 1.4 Update results deletion in `ClearBenchmarkResults` to remove `GetBenchmarkResultsFilePath`
- [x] 1.5 Replace hardcoded developer home path `/home/benjamim` with `/tmp` or fallback logic in directory helper functions
- [x] 1.6 Update Flatpak-compatible host OS release detection in `GetOSName` using `/run/host/etc/os-release` and `/run/host/usr/lib/os-release`
- [x] 1.7 Add `7za` as a fallback command in `T7ZipThread.Execute` CPU benchmark script when `7z`/`7zz` are missing

## 2. Compilation and Verification

- [x] 2.1 Compile the `pascube` binary locally
- [x] 2.2 Compile GOverlay and ensure it builds without warnings
- [x] 2.3 Verify saving, loading, and deletion of benchmark results in `~/.config/goverlay/benchmark_results.json`
- [x] 2.4 Test that OS detection properly resolves on Flatpak (or native fallback)
