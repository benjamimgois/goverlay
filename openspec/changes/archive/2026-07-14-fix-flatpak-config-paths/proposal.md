## Why

Inside the Flatpak sandbox, GOverlay's configuration directories (such as `$XDG_CONFIG_HOME/MangoHud`, `$XDG_CONFIG_HOME/vkBasalt`, and `$XDG_CONFIG_HOME/vkSumi`) are mapped to the host's `~/.config/...` folders via Flatpak file permissions.
However, GOverlay explicitly bypasses `$XDG_CONFIG_HOME` when `IsRunningInFlatpak` is true and hardcodes `/home/user/.config/` instead.
Since the sandbox restricts write access to the host's `/home/user/.config/`, GOverlay's writes to it do not persist or reach the host, leading to "no configuration files located" warnings and global presets failing to save on Flatpak.

## What Changes

- Remove Flatpak-specific hardcoded overrides to `~/.config` in `GetHostConfigDir` inside `configmanager.pas`.
- Remove Flatpak-specific hardcoded overrides in `GetMangoHudConfigDir`, `GetVkBasaltConfigDir`, and `GetVkSumiConfigDir` inside `overlay_utils.pas`.
- Fallback to `$XDG_CONFIG_HOME` so Flatpak correctly routes path resolution to the persistent bind-mounted host configuration directories.

## Capabilities

### New Capabilities
- `flatpak-config-paths`: Resolve configuration directories inside the Flatpak sandbox using `$XDG_CONFIG_HOME` instead of sandboxed `~/.config` paths.

### Modified Capabilities

## Impact

- Affected files: `configmanager.pas` and `overlay_utils.pas`.
- Persists global MangoHud, vkBasalt, and vkSumi configurations on Flatpak restart and correctly updates them on the host.
