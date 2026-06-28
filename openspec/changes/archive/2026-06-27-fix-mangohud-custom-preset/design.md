## Context

The MangoHud presets tab features 5 layout options. Preset cards 0-3 (Full, Basic, Basic Horizontal, FPS Only) modify UI checkboxes directly and trigger `saveBitBtnClick` to write `MangoHud.conf`. Option 4 (Custom) copies `custom.conf` to `MangoHud.conf` using shell execution (`cp`). However, because GOverlay's internal state is not re-synchronized after copying, any subsequent user action triggers an auto-save that overwrites `MangoHud.conf` with stale UI control state.

## Goals / Non-Goals

**Goals:**
- Re-synchronize GOverlay UI controls with `MangoHud.conf` immediately after copying `custom.conf` in `usercustomBitBtnClick`.
- Ensure custom preset visual indicators update accurately on the new modern card UI (`mangohud_ui.pas`).
- Provide clear feedback if `custom.conf` does not exist when clicking the Custom card.

**Non-Goals:**
- Altering how `custom.conf` files are created or saved via the hamburger menu.

## Decisions

### Decision 1: Invoke `TMangoHudUiHelper.LoadMangoHudConfig` in `usercustomBitBtnClick`
- **Choice**: After successfully copying `custom.conf` to `MangoHud.conf` in `usercustomBitBtnClick`, call `FMangoHudHelper.LoadMangoHudConfig`.
- **Rationale**: Re-parsing `MangoHud.conf` populates all checkboxes, trackbars, color buttons, and position dropdowns with the settings from `custom.conf`, preventing stale UI state from overwriting the config.

### Decision 2: Handle missing `custom.conf` gracefully in Modern Card UI
- **Choice**: When `usercustomBitBtnClick` is triggered and `custom.conf` does not exist, show an informational message and do not mark card 4 as active.
- **Rationale**: Keeps card interaction robust and intuitive across both legacy and modern UI representations.

## Risks / Trade-offs

- **[Risk] Heavy UI refresh on custom preset load** → Mitigated by calling existing `LoadMangoHudConfig` helper which efficiently updates controls.
