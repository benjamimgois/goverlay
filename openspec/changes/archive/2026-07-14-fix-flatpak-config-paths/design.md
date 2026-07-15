## Context

Inside the Flatpak container, `$XDG_CONFIG_HOME` resolves to `/home/user/.var/app/io.github.benjamimgois.goverlay/config/`, which is where persistent configuration directories like `MangoHud/` are mapped/bind-mounted to the host's `~/.config/`.
However, GOverlay's code currently has checks that explicitly override paths to `/home/user/.config/` when running inside Flatpak. Since GOverlay has no permission to write to host `~/.config/` directly, this results in non-persistent/broken config writes.

## Goals / Non-Goals

**Goals:**
- Enable persistent configuration saving on Flatpak by ensuring GOverlay uses Flatpak-provided `$XDG_CONFIG_HOME`.
- Align config path resolution logic between `configmanager.pas` and `overlay_utils.pas`.

**Non-Goals:**
- We are not changing game-specific config directories (which use `GetHostDataDir` / `XDG_DATA_HOME` and are already working).
- We are not modifying Flatpak permissions in the manifest, as the current permissions (`xdg-config/MangoHud:rw`, etc.) are sufficient when files are read/written from the correct path.

## Decisions

- **Remove IsRunningInFlatpak overrides**: Rather than special-casing Flatpak to use a hardcoded `/home/user/.config`, we will remove the conditional overrides and let Flatpak environments natively use `$XDG_CONFIG_HOME` like normal XDG environments.
- **Path Resolution Priority**:
  Check `HOST_XDG_CONFIG_HOME` (useful if we want to run on host filesystem outside Flatpak mappings via wrapper scripts) -> check `XDG_CONFIG_HOME` -> fallback to `GetUserDir + '.config'`.

## Risks / Trade-offs

- **Risk**: Some user setups might not have `XDG_CONFIG_HOME` set inside custom Flatpak runners.
  - *Mitigation*: The fallback `GetUserDir + '.config'` remains in place as the last priority.
