## Context

See proposal.md. Users with existing `.conf` files need a convenient way inside GOverlay to load/import external configuration files for MangoHud, vkBasalt, and vkSumi.

## Goals / Non-Goals

**Goals:**
- Add `loadconfigMenuItem` ("Load config") to `popsaveMenu` in `overlayunit.lfm`, positioned right above `saveoptionsItem`.
- Control `loadconfigMenuItem.Visible` in `popupBitBtnClick` (visible for MangoHud, vkBasalt, vkSumi; hidden for OptiScaler, Tweaks).
- Implement `loadconfigMenuItemClick` using `TOpenDialog` to select a `.conf` file and copy it to the active configuration target, then invoke the respective `Load*Config` procedure to refresh UI controls.

**Non-Goals:**
- Creating a full preset management database or profile dropdown selector.
- Supporting config loading for OptiScaler or Tweaks (which use distinct `.ini` structures and settings helpers).

## Decisions

### Decision 1: Placement of "Load config" item
- **Choice**: Insert `loadconfigMenuItem` as the top-level first item in `popsaveMenu` above `saveoptionsItem`.
- **Rationale**: Places the import action right next to export ("Save as" / "Save options") for intuitive access.

### Decision 2: Config file import workflow
- **Choice**: Prompt `TOpenDialog` with filter `'Configuration files (*.conf)|*.conf|All files (*.*)|*.*'`. Copy the selected file to the active tool's target configuration path (`MANGOHUDCFGFILE`, `VKBASALTCFGFILE`, or `VKSUMICFGFILE`) and invoke `LoadMangoHudConfig`, `LoadVkBasaltConfig`, or `LoadVkSumiConfig`.
- **Rationale**: Reuses the tested, existing config loader methods in `overlayunit.pas` to parse the file and synchronize all UI controls.

## Risks / Trade-offs

- [Risk] User selects an invalid or malformed `.conf` file.
  - Mitigation: Handled gracefully by existing config parsers (which set defaults for unparsed options) and displays notification upon completion.
