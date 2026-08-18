## Context

See `proposal.md` for motivation. Currently GOverlay writes settings to `bgmod.conf` `[Config]` and then synthesizes `lsfg.toml`. Using `lsfg.toml` directly as the primary storage aligns with MangoHud (`MangoHud.conf`), vkBasalt (`vkBasalt.conf`), and OptiScaler (`OptiScaler.ini`).

## Goals / Non-Goals

**Goals:**
- Parse `lsfg.toml` directly when loading Lossless Scaling tab settings in `lossless_scaling_tab.pas`.
- Write `lsfg.toml` directly when saving Lossless Scaling tab settings.
- Write only `GOVERLAY_LOSSLESS=1` or `0` in `bgmod.conf` `[Config]`.
- Provide smooth backward compatibility for loading legacy `bgmod.conf` `[Config]` / `[Env]` keys if `lsfg.toml` does not yet exist.
- Update `bgmod.lpr` to parse `lsfg.toml` if it needs to update/verify `exe` profiles, while keeping `bgmod.conf` completely clean.

**Non-Goals:**
- Changing `liblsfg-vk.so` behavior or supported TOML keys.
- Changing MangoHud, vkBasalt, or OptiScaler configuration schemes.

## Decisions

1. **TOML Parser Helper in `lossless_scaling_tab.pas`**:
   - Parse key/value pairs from `[global]` and `[[game]]` sections of `lsfg.toml` (extracting `dll`, `multiplier`, `flow_scale`, `performance_mode`, `hdr_mode`, `experimental_present_mode`).
   - *Alternative considered*: Use a heavy external TOML parsing library. *Rejected*: Free Pascal standard `TStringList` parsing is lightweight, fast, and sufficient for the simple schema of `lsfg.toml`.

2. **Clean `bgmod.conf`**:
   - `bgmod.conf` only saves `GOVERLAY_LOSSLESS=1` or `0` under `[Config]`.
   - All `LS_*` and `LSFG_*` keys are pruned from `[Config]` and `[Env]`.

3. **Fallback Migration Strategy**:
   - When loading configuration, if `lsfg.toml` exists in the configuration folder, parse `lsfg.toml`.
   - If `lsfg.toml` does not exist, fall back to checking legacy `[Config]` (`LS_*`) and `[Env]` (`LSFG_*`) keys in `bgmod.conf`.

## Risks / Trade-offs

- **[Risk]** User has a customized `lsfg.toml` with multiple games.
  - **Mitigation**: When saving, preserve the global DLL and update/add profiles for the active game, `pascube`, and `vkcube`.
