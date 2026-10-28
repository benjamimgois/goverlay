# Design

## Context

Issue #363 highlighted two distinct regressions causing settings to revert to defaults or toggle unexpectedly:
1. FakeNVAPI's template seeds `force_reflex=0` by default ("Follow in-game setting"). In `overlay_config.pas`, `LoadOptiScalerConfig` checked `FakeCfg.HasKey(FAKE_KEY_FORCE_REFLEX)` and set `ForceReflexChecked := True`, interpreting any presence of the key as enabled.
2. In `mangohud_ui.pas`, `HexToColor` invoked `StrToInt` on raw substrings. Any `#` prefix (e.g. `#FF0000`), whitespace, or non-standard format caused an unhandled `EConvertError` during `LoadMangoHudConfig`, aborting the loading loop mid-stream and leaving subsequent options (such as VSync, subsequent colors, and toggles) in reset default states.

See `proposal.md` for full motivation.

## Goals / Non-Goals

**Goals:**
- Correctly synchronize FakeNVAPI's `force_reflex` setting so that `0` (or absent key) represents unforced/unchecked, and `1` or `2` represents forced/checked.
- Ensure saving with Force Reflex disabled persists `force_reflex=0` (or leaves it unforced) without triggering ghost toggles on reload.
- Make `HexToColor` robust against `#` prefixes, whitespace, and invalid hex inputs via `TryStrToInt` and fallback colors.
- Isolate per-line parsing in `LoadMangoHudConfig` with `try ... except` guards so that a malformed line does not abort processing subsequent settings.

**Non-Goals:**
- Redesigning the OptiScaler or MangoHud settings tab layout.
- Changing FakeNVAPI or MangoHud syntax or external file schemas.

## Decisions

### Decision 1: OptiScaler `force_reflex` State Mapping
- **Approach**: In `LoadOptiScalerConfig`:
  - Read `Value := FakeCfg.GetValue(FAKE_KEY_FORCE_REFLEX, '0')`.
  - Set `Settings.ForceReflexChecked := (Value = '1') or (Value = '2')`.
  - Set `Settings.ReflexItemIndex := StrToIntDef(Value, 0)`.
  In `SaveOptiScalerConfigCore`:
  - When `Settings.ForceReflexChecked` is True, write the selected mode (`'1'` or `'2'`).
  - When `Settings.ForceReflexChecked` is False, write `'0'` explicitly (`FakeCfg.SetValue(FAKE_KEY_FORCE_REFLEX, '0')`).
- **Rationale**: Setting `0` when unchecked ensures the template's setting matches FakeNVAPI's native "Follow in-game setting" semantics. Even if the template is re-seeded with `force_reflex=0`, `LoadOptiScalerConfig` will correctly interpret `0` as unchecked (`ForceReflexChecked := False`).
- **Alternative considered**: Deleting the key on save. Rejected because template seeding or fresh installs introduce `force_reflex=0`, which would immediately re-trigger the bug if presence equaled checked.

### Decision 2: Sanitized and Safe Hex Color Parsing
- **Approach**: Update `HexToColor(const HexValue: string; const DefaultColor: TColor = clWhite): TColor` in `mangohud_ui.pas`:
  - Trim whitespace and strip any leading `#` characters.
  - Expand 3-character hex shorthand (`#RGB` -> `RRGGBB`) if encountered.
  - Validate length (>= 6) and parse R, G, B channels using `TryStrToInt('$' + ...)`.
  - Return `DefaultColor` if any channel fails to parse.
- **Rationale**: Avoids `EConvertError` exceptions while accepting both standard MangoHud hex strings (`RRGGBB` and `#RRGGBB`).
- **Alternative considered**: Requiring strict format without `#`. Rejected because MangoHud supports `#` prefixes and users often paste hex colors from web color pickers with `#`.

### Decision 3: Per-Line Exception Isolation in `LoadMangoHudConfig`
- **Approach**: Wrap calls to `LoadMangoHudKeyValue` and `LoadMangoHudBoolFlag` inside individual `try ... except` blocks in the line iteration loop of `LoadMangoHudConfig`. Log a non-fatal warning on exception.
- **Rationale**: A corrupted or unexpected line in `MangoHud.conf` must never abort configuration loading for the remainder of the file.

## Risks / Trade-offs

- **[Risk] Existing configurations with `force_reflex=0`**:
  → **Mitigation**: With the new logic, `force_reflex=0` is loaded as unchecked, which accurately represents the unforced state. If a user previously intended reflex to be forced, they would have selected mode 1 or 2.
- **[Risk] Unrecognized color strings reverting to fallback without notification**:
  → **Mitigation**: A warning is emitted to the debug log, and the fallback color keeps the UI functional rather than crashing.
