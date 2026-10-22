## Context

The `bgmod` wrapper binary (`bgmod.lpr`) prepares and synchronizes dependencies and configuration files in the game's directory before invoking `execvpe` to launch the game.

Currently, `SyncOptiScalerIni` in `bgmod.lpr` unconditionally overwrites `GameDir/OptiScaler.ini` with `ConfigDir/OptiScaler.ini` on every execution, discarding any settings modified by the user in-game.

## Goals / Non-Goals

**Goals:**
- Implement bidirectional synchronization in `SyncOptiScalerIni` comparing `FileAge` modification times.
- Synchronize in-game modifications (`GameDir/OptiScaler.ini`) back to `ConfigDir/OptiScaler.ini` when `AgeGame > AgeConfig`.
- Synchronize GOverlay GUI modifications (`ConfigDir/OptiScaler.ini`) to `GameDir/OptiScaler.ini` when `AgeConfig > AgeGame`.
- Preserve exact file modification times (`FileSetDate` / `utimbuf` or `fpUtime`) upon copy so subsequent game runs do not trigger ping-pong copies.
- Respect `PRESERVE_INI` configuration flag when set to `false`.
- Ensure clean compilation of `bgmod` with `fpc`.

**Non-Goals:**
- Parsing or merging individual INI sections line-by-line.
- Altering the GOverlay GUI controls or `overlay_config.pas` serialization.

## Decisions

### Decision 1: Timestamp-based bidirectional copy helper
- Use `FileAge` (from `SysUtils`) to compare modification dates of `ConfigIni` and `GameIni`.
- When `AgeGame > AgeConfig`, copy `GameIni -> ConfigIni` and preserve timestamp.
- When `AgeConfig > AgeGame`, copy `ConfigIni -> GameIni` and preserve timestamp.
- When one file is missing, copy the existing one to the missing location and preserve timestamp.
- Rationale: This guarantees that adjustments made in either GOverlay or in-game are always preserved and propagated to the other location.

### Decision 2: Modification time preservation (`PreserveFileTime`)
- After calling `CopyFile(Src, Dest)`, set the destination file's modification time to match the source file's modification time using `FileSetDate` or `fpUtime`.
- Rationale: Standard file copy operations in Free Pascal assign `now()` to the created destination file. Without explicit timestamp preservation, the destination file would become newer than the source, causing an unnecessary sync on the next launch.

### Decision 3: Integration with `PRESERVE_INI`
- If `PRESERVE_INI` is `false` (in `bgmod.conf`), skip bidirectional logic and unconditionally copy `ConfigDir -> GameDir`.
- Default behavior remains `PRESERVE_INI=true`.

## Risks / Trade-offs

- **[Risk] Filesystem timestamp resolution differences**: FAT/NTFS filesystems (e.g. Proton prefixes on external drives) or network shares might have 2-second timestamp resolution.
  - **Mitigation**: Comparing `AgeA > AgeB` with a small tolerance or checking for equality after `FileSetDate` ensures robust handling across filesystems.
