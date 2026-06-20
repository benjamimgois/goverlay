## Context

Currently, the `bgmod` tool copies OptiScaler files on every game run, which can be slow and causes unnecessary disk writes. Furthermore, when the user updates OptiScaler inside GOverlay, existing games that have already had OptiScaler enabled are left with old DLL versions because GOverlay only updates the central/global directory and does not propagate files to individual game folders or config directories.

## Goals / Non-Goals

**Goals:**
- Detect when a central update of OptiScaler occurs and dynamically sync the new DLLs/resources to the game's local configuration folder on game launch.
- Skip copying files to the game directory on run if the files already exist and match the version specified in the local configuration folder.
- Maintain existing user customizations (specifically preserving `bgmod.conf` and `OptiScaler.ini`).

**Non-Goals:**
- Changing GOverlay's update process to iterate and write to all games' directories.
- Storing version numbers in a central database; we will use standard `goverlay.vars` text files.

## Decisions

### 1. Compare versions via `goverlay.vars`
- **Choice**: Read and compare the text content of `goverlay.vars` between directories.
- **Alternatives**:
  - Compare file timestamps: File modification times can be unreliable when files are extracted or copied across different filesystems or package managers.
  - Compare file sizes: Two different versions of a DLL could hypothetically have the exact same size.
- **Rationale**: `goverlay.vars` contains version information (like `optiScalerVersion=vX.Y.Z`) written during updates. If the file is missing or its content differs, we know an update has occurred.

### 2. Auto-sync global files to local game config directory in `bgmod`
- **Choice**: On game execution, `bgmod` checks the global path and syncs files if needed.
- **Alternatives**:
  - Update all game directories during GOverlay update: This requires GOverlay to keep track of all game directories and write to them simultaneously, which is complex and could fail if GOverlay is closed abruptly.
- **Rationale**: Having `bgmod` handle this dynamically makes the process self-healing and completely decentralized.

### 3. Copy everything except config files during sync
- **Choice**: Copy all files/folders from the global directory to the game config directory except `bgmod.conf` and `OptiScaler.ini`.
- **Rationale**: This ensures that any new DLLs or folders added to future OptiScaler releases are automatically supported without changing `bgmod.lpr`'s code, while preserving the user's custom settings.

## Risks / Trade-offs

- **[Risk]** Overwriting a running `bgmod` executable during sync might cause a "Text file busy" error.
  - *Mitigation*: We delete the destination file before copying, which on Linux performs an `unlink` and allows replacing a running binary without error.
