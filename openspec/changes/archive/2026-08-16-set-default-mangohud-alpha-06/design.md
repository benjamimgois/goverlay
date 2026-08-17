## Context

See `proposal.md` for motivation.
`ResetMangoHudControls` in `mangohud_ui.pas` sets default values for all MangoHud controls before loading a configuration.
Currently `transpTrackBar.Position` is set to `10` and `alphavalueLabel.Caption` is set to `'1.0'`.

## Goals / Non-Goals

**Goals:**
- Update `ResetMangoHudControls` in `mangohud_ui.pas` to set `transpTrackBar.Position := 6` and `alphavalueLabel.Caption := '0.6'`.
- Ensure new game configurations and global defaults initialize `background_alpha` to 0.6.

**Non-Goals:**
- Changing behavior of existing configurations that explicitly specify a different `background_alpha` value.

## Decisions

- **Trackbar Position:** Setting `Position := 6` maps directly to `0.6` when divided by 10 (since `transpTrackBar.Min = 0` and `transpTrackBar.Max = 10`).

## Risks / Trade-offs

- None identified; `overlay_config.pas` and `overlayunit.lfm` already use 0.6 / 6 as default.
