# Design: Native Linux Game Support for bgmod

## Context

See [proposal.md](proposal.md) for background and motivation. `bgmod` serves as a high-performance wrapper written in Free Pascal, injected via Steam launch options (`bgmod %command%`). Currently, `bgmod` assumes all games run through Wine/Proton and only searches for `.exe` arguments.

## Goals / Non-Goals

**Goals:**
- Reliably detect native Linux game executables (ELF binaries and executable scripts) across Steam native launches, container runtimes (Steam Linux Runtime / pressure-vessel), and helper wrappers (`gamemoderun`).
- Dynamically populate `conf.toml` with the native executable name for `lsfg-vk` and `mako` frame generation.
- Safely bypass Windows PE DLL injection (OptiScaler, ReShade) when running native Linux games while maintaining native Vulkan layers (`MangoHud`, `vkBasalt`, `vkSumi`, `lsfg-vk`).
- Persist detected executable names in `bgmod.conf` for GUI synchronization.
- Maintain full backward compatibility with Windows/Proton games.

**Non-Goals:**
- Creating native Linux ports of Windows-only upscalers (OptiScaler remains Windows/Proton-only).
- Managing Steam library installations directly from `bgmod`.

## Decisions

### 1. Two-Phase Executable Resolution in `ResolveGameDirectory`

Maintain the existing `.exe` check as Phase 1 to ensure zero regression for Proton games:
```pascal
// Phase 1: Proton / Wine .exe detection (unchanged)
for i := 1 to ParamCount do
  if LowerCase(ExtractFileExt(ParamStr(i))) = '.exe' then ...

// Phase 2: Native Linux executable detection
if TargetExeName = '' then
  ResolveNativeLinuxExecutable;
```

*Alternatives considered:*
- Combining detection into a single loop: Rejected because Proton command lines contain both native Linux runtimes (`proton`, `python3`) and target Windows `.exe` files; checking `.exe` first avoids false positives on Proton helper tools.

### 2. Wrapper Filtering and Container Boundary Detection

Steam executes games through varied wrapper topologies:
- Direct: `bgmod /path/to/game/bin/linux_x64/eurotrucks2 -rdevice vk`
- With gamemoderun: `bgmod -- env gamemoderun /path/to/eurotrucks2`
- With Steam Linux Runtime: `bgmod .../_v2-entry-point --verb=... -- /path/to/eurotrucks2 -rdevice vk`

**Resolution strategy:**
1. Check for the container delimiter `--`. If present (and not the leading `-- env gamemoderun` wrapper), inspect arguments after the last `--` first, as container runtimes place the game command after `--`.
2. Skip tokens starting with `-` (flags/options).
3. Skip known wrappers and interpreters:
   `_v2-entry-point`, `pressure-vessel-wrap`, `steam-runtime-launch-client`, `steam-launch-wrapper`, `gamemoderun`, `mangohud`, `vkbasalt`, `optirun`, `primrun`, `prime-run`, `env`, `sh`, `bash`, `zsh`, `python`, `python3`, `perl`, `flatpak-spawn`, `steam`.
4. Validate candidate file:
   - Must exist on disk (`FileExists`) and not be a directory (`not DirectoryExists`).
   - Must have execute permissions (`fpAccess(PChar(Cand), X_OK) = 0`).
   - Must match ELF binary magic (`$7F, 'E', 'L', 'F'`) or an executable script/binary extension (`.x86_64`, `.x86`, `.bin`, `.sh`).

### 3. ELF Magic Verification Helper

Implement a lightweight `IsElfBinary(const AFilePath: string): Boolean` function that reads the first 4 bytes of the candidate file. This distinguishes true Linux executables from arbitrary files or config arguments that happen to exist.

### 4. Handling Script Launchers (`.sh`)

If the detected candidate is an executable shell script (e.g., `start.sh` or `run.sh`):
1. Set `TargetExeName := 'start.sh'`.
2. Scan `GameDir` for ELF binaries (e.g. `Game.x86_64`).
3. Add both the script name and any discovered ELF binary names to `active_in` in `conf.toml`.

### 5. Windows DLL Bypass Guard

Introduce a helper `IsNativeExecutable(const AExeName: string): Boolean`:
```pascal
function IsNativeExecutable(const AExeName: string): Boolean;
begin
  Result := (AExeName <> '') and (LowerCase(ExtractFileExt(AExeName)) <> '.exe');
end;
```
If `IsNativeExecutable(TargetExeName)` is true:
- Skip `GOverlayOptiscaler` DLL copying and OptiScaler INI sync.
- Skip `GOverlayReshade` Windows DLL copying.
- Log: `Log('Native Linux executable detected (' + TargetExeName + '). Skipping Windows upscaler/ReShade DLL deployment.');`
- Still execute: `MangoHud`, `vkBasalt`, `vkSumi`, `Lossless Scaling` (`lsfg-vk` and `mako`), and environment tweaks.

### 6. Caching in `bgmod.conf` & GUI Integration

When `bgmod` resolves `TargetExeName`, update `bgmod.conf`:
- `TARGET_EXE = <TargetExeName>`
- `GAME_DIR = <GameDir>`

In `lossless_scaling_tab.pas`, when saving `conf.toml`, read `TARGET_EXE` from `bgmod.conf` if present so the GUI-generated `conf.toml` is populated with the exact binary name even before the first launch.

### 7. Parity in `bgmod-uninstaller.lpr`

Port the identical `ResolveGameDirectory` enhancement into `bgmod-uninstaller.lpr` to ensure clean uninstallation and log cleanup for native games.

## Risks / Trade-offs

- **[Complex multi-wrapper commands]** → *Mitigation:* Explicit list of known wrappers combined with `--` container delimiter prioritization and ELF header verification prevents picking wrappers as game targets.
- **[Game directory with subfolder binary (`bin/linux_x64/`)]** → *Mitigation:* `GameDir` is set to `ExtractFilePath(Arg)` (`.../bin/linux_x64/`), matching where `MangoHud.conf` and working logs reside. `lsfg-vk` relies on `LSFGVK_CONFIG` env var and process name matching, so it works regardless of subfolder depth.
