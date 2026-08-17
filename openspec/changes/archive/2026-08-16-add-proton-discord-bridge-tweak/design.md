## Context

See `proposal.md` for motivation.
GOverlay's EnvVars tab displays tweak rows defined in `TWEAK_ROWS` inside `tweaks_md3.pas`.
Each tweak row is backed by a `TCheckBox` component on `Tgoverlayform`, mapped in `GetTweakRowCheckBox`.
The user requested placing `PROTON_DISCORD_BRIDGE=1` under the **General** category (`TWEAK_CAT_GENERAL`).

## Goals / Non-Goals

**Goals:**
- Add `PROTON_DISCORD_BRIDGE=1` to `TWEAK_ROWS` in `tweaks_md3.pas` with `TWEAK_CAT_GENERAL`.
- Declare `FProtonDiscordBridgeCheckBox` on `Tgoverlayform` in `overlayunit.pas`.
- Map `FProtonDiscordBridgeCheckBox` in `GetTweakRowCheckBox` and instantiate it in `InitTweaksCards`.
- Provide tooltip `"Works only with proton-cachyos"` in `MouseMove` handler.
- Integrate into `SaveTweaksConfig`, `HasTweaksEnabled`, and `LoadTweaksFromFGMod`.
- Add test coverage in `tests/gui/gui_test_cases.pas`.

**Non-Goals:**
- Custom Discord Rich Presence IPC configuration or client discovery logic outside Proton's built-in bridge mechanism.

## Decisions

- **Placement in Category:** Use `TWEAK_CAT_GENERAL` as requested by the user.
- **Prefix Highlighting:** Use `[proton-cachyos]` prefix which is automatically rendered in purple by the MD3 custom renderer in `tweaks_md3.pas`.
- **Backing Component:** Use dynamically instantiated `TCheckBox` (`FProtonDiscordBridgeCheckBox`) created in `InitTweaksCards`, consistent with other proton-cachyos tweaks.

## Risks / Trade-offs

- [Risk] Index misalignment between `TWEAK_ROWS` and `GetTweakRowCheckBox` → Ensure `TWEAK_ROW_COUNT` is incremented to 31 and the index in `GetTweakRowCheckBox` (case 30) matches the row position.
