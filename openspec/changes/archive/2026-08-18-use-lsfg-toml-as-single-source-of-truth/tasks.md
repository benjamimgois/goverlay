## 1. TOML Parsing and Loading in Lossless Scaling Tab
- [x] 1.1 In `lossless_scaling_tab.pas`, implement `LoadLosslessConfig` to parse `lsfg.toml` directly (extracting `dll`, `multiplier`, `flow_scale`, `performance_mode`, `hdr_mode`, `experimental_present_mode`).
- [x] 1.2 In `lossless_scaling_tab.pas`, support fallback migration from legacy `[Config]` / `[Env]` keys in `bgmod.conf` if `lsfg.toml` does not exist.

## 2. TOML Saving and Clean bgmod.conf
- [x] 2.1 In `lossless_scaling_tab.pas`, implement `SaveLosslessConfig` to write all configuration directly to `lsfg.toml`.
- [x] 2.2 In `lossless_scaling_tab.pas`, write only `GOVERLAY_LOSSLESS=1` (or `0`) to `bgmod.conf` `[Config]`, pruning all `LS_*` and `LSFG_*` keys from `bgmod.conf`.
- [x] 2.3 In `lossless_scaling_tab.pas`, delete `lsfg.toml` when Lossless Scaling is disabled (or multiplier 1x).

## 3. Wrapper (bgmod) and Preview Integration
- [x] 3.1 In `bgmod.lpr`, check `GOVERLAY_LOSSLESS=1` in `bgmod.conf`, read `lsfg.toml` (or ensure `exe` entry is populated for target game), and export `LSFG_CONFIG="<dir>/lsfg.toml"`.
- [x] 3.2 Recompile and deploy `bgmod`.

## 4. Testing and Validation
- [x] 4.1 Update GUI test cases in `tests/gui/gui_test_cases.pas` to test `lsfg.toml` reading, saving, and `bgmod.conf` cleanup.
- [x] 4.2 Run test suites (`make test-logic`, `make test-gui`).
