## Context

See `proposal.md` for motivation. In `overlayunit.pas`, `saveBitBtnClick` contained a legacy conditional check on `globalenableMenuItem.Checked` which assigned `'MangoHud will be displayed in every vulkan application'` to `FLaunchCommand`.

With GOverlay's modern architecture using `bgmod` for multi-tool overlay coordination (MangoHud, vkBasalt, vkSumi, OptiScaler, Tweaks, Gamescope, Gamemode), the launch command should always remain the actual `bgmod` wrapper path, ensuring consistency across all tabs, dialogs, and launch methods.

## Goals / Non-Goals

**Goals:**
- Unify launch command assignment in `saveBitBtnClick` to always use `GetLaunchCommand`.
- Remove legacy descriptive string assignment that breaks launch command copying.
- Ensure automated test suite covers launch command generation when `globalenableMenuItem` is enabled.

**Non-Goals:**
- Modifying how `EnableMangoHudGlobally` or `DisableMangoHudGlobally` operate on system environment files.

## Decisions

### Decision 1: Always assign `FLaunchCommand := GetLaunchCommand` in `saveBitBtnClick`
- **Rationale**: `GetLaunchCommand` is already centralized and dynamic. By calling `GetLaunchCommand` unconditionally in `saveBitBtnClick`, `FLaunchCommand` will consistently hold the valid executable command for the active profile and platform.
- **Alternatives considered**:
  - *Keep descriptive string only for bottom paintbox*: Rejected because bottom paintbox is obsolete and having inconsistent strings in `FLaunchCommand` causes bugs when read by dialogs or properties.

## Risks / Trade-offs

- [Risk] Old users expecting the legacy text message on save → [Mitigation] Modern GOverlay uses floating docks and the Finish Configuration dialog which clearly explains platform launch setup without ambiguous text replacement.
