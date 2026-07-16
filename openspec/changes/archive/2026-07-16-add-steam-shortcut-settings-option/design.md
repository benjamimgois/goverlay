## Context

GOverlay users (especially on Steam Deck or using Steam Big Picture mode) want to launch GOverlay directly from Steam's Game Mode. Steam stores custom/non-Steam game shortcuts in a binary, proprietary KeyValues file format (`shortcuts.vdf`) inside each local Steam user's directory. Manipulating this binary structure directly in Pascal is complex and risky.

## Goals / Non-Goals

**Goals:**
- Provide a clean menu item under GOverlay Settings to create/refresh a Steam shortcut for GOverlay.
- Handle different installation formats (Native vs. Flatpak) automatically.
- Safely parse, update, and serialize the binary `shortcuts.vdf` files.
- Detect active Steam instances and prompt the user to avoid state conflicts.

**Non-Goals:**
- Force-closing Steam automatically (we only notify/warn the user).
- Syncing or managing shortcut play time/launch states inside Steam.

## Decisions

### Decision 1: Use a pure Python helper script for shortcuts.vdf manipulation
- **Rationale**: Python is pre-installed on all target environments (including SteamOS) and provides native support for struct unpacking and CRC32 checks via standard libraries (`struct`, `binascii`). This avoids writing a complex binary VDF parser in Pascal.
- **Alternatives**:
  - *Implementing VDF parsing in Pascal*: Discarded due to complexity, lack of standard library support, and maintenance overhead.
  - *Using external tool like SteamTinkerLaunch*: Discarded to avoid introducing external runtime dependencies.

### Decision 2: Location of Python helper script
- **Rationale**: The script will be placed at `assets/goverlay-steam-shortcut.py`. GOverlay's build system and Makefile copy the contents of the `assets/` folder to the target systems' installation directory automatically, ensuring the script is bundled correctly.

### Decision 3: Execution under Flatpak
- **Rationale**: If GOverlay detects it is running in Flatpak (e.g. by checking `/.flatpak-info` or env `FLATPAK_ID`), the shortcut command in Steam will be set to `flatpak run io.github.benjamimgois.goverlay` rather than the absolute path of the sandboxed binary, ensuring it starts correctly.

## Risks / Trade-offs

- **Risk**: Steam overwriting `shortcuts.vdf` on exit.
  - *Mitigation*: The helper script checks if the `steam` process is active. GOverlay displays a modal warning telling the user to close Steam for changes to take effect reliably.
- **Risk**: Flatpak filesystem permissions.
  - *Mitigation*: GOverlay Flatpak sandbox has write permissions to `~/.var/app/com.valvesoftware.Steam/.local/share/Steam/` but read-only access to host Steam paths. The script will skip directories for which it lacks write access and output a warning/error that GOverlay can display to the user.
