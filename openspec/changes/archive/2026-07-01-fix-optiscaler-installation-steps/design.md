## Context

GOverlay manages OptiScaler installation and updates. However, four critical installation steps are currently missing or incorrect in `optiscaler_update.pas`:
1. **Subfolder Move**: Extracted release files are nested within an `OptiScaler` folder inside `.bgmod_original`. If not moved to the root, `bgmod` cannot find them.
2. **Auxiliary DLL**: The frame generation helper `dlssg_to_fsr3_amd_is_better.dll` is never downloaded, though `bgmod` expects it.
3. **FakeNVAPI**: The `fakenvapi` dependency is never fetched, preventing Reflex and other options from functioning.
4. **Dynamic Versions**: FSR and XeSS versions are hardcoded or missing in `goverlay.vars`.

## Goals / Non-Goals

**Goals:**
- Move all files from `.bgmod_original/OptiScaler/` to `.bgmod_original/` and delete the empty subfolder.
- Download `dlssg_to_fsr3_amd_is_better.dll` to `.bgmod_original/` during installation/update.
- Dynamically query, download, and extract the latest stable release of `fakenvapi`, and track its version in `goverlay.vars` under `FakeNvapiVersion`.
- Ensure `fakenvapi.ini` is synced/copied along with DLLs.
- Fetch `vars.txt` dynamically and write `fsrversion` and `xessversion` to `goverlay.vars` based on the channel (stable or edge).

**Non-Goals:**
- Modifying how `bgmod` itself copies files on game launch (it already copies `fakenvapi` and frame-generation helper files if present).
- Overwriting user custom configuration files during runtime sync.

## Decisions

### 1. Folder restructuring via shell process
- **Choice**: Execute a `sh` process to run `cp -rf .bgmod_original/OptiScaler/. .bgmod_original/ && rm -rf .bgmod_original/OptiScaler` immediately after extraction.
- **Rationale**: Reusing `TProcess` with a simple shell command is safer, cleaner, and less verbose in Pascal than implementing recursive directory listing, moving, and deletion.

### 2. Querying GitHub API for FakeNVAPI release dynamically
- **Choice**: Call the GitHub releases endpoint `https://api.github.com/repos/optiscaler/fakenvapi/releases/latest` using `curl` and parse with `GetJSON` to get the latest version tag and `.7z` download URL.
- **Rationale**: Ensures the user always gets the latest stable version of FakeNVAPI. We will strip the leading `v` from the tag name (e.g., `v1.4.1` -> `1.4.1`) for the version entry in `goverlay.vars`.

### 3. Syncing `fakenvapi.ini` to active path
- **Choice**: Add an explicit check and copy statement for `fakenvapi.ini` in the `UpdateButtonClick` sync shell script.
- **Rationale**: The sync script currently only copies `*.dll` and subdirectories (`plugins/`, `FSR4_LATEST/`, etc.). Since `fakenvapi.ini` is a `.ini` file, it must be explicitly copied to `FFGModPath`.

### 4. Dynamic parsing of FSR and XeSS versions
- **Choice**: Fetch `vars.txt` from the remote repository, parse line-by-line via `TStringList`, extract `fsrstable`, `fsredge`, `xessstable`, and `xessedge`, and use them to write `fsrversion` and `xessversion` to `goverlay.vars`.
- **Rationale**: Keeps the local `goverlay.vars` and UI labels in sync with the actual versions matching the downloaded stable or edge channel files. Fallbacks are hardcoded in case of network errors.

## Risks / Trade-offs

- `[Risk]`: GitHub API rate limiting due to unauthenticated requests.
  - *Mitigation*: GOverlay sets a custom User-Agent `Goverlay/1.6 (Linux; Flatpak-compatible)` for requests, and only performs the query on manual updates or first-time auto-installs.
- `[Risk]`: Network failures when retrieving `vars.txt` or FakeNVAPI releases.
  - *Mitigation*: Failures will be handled gracefully using try-except blocks, falling back to static/hardcoded defaults for versions without crashing the update process.
