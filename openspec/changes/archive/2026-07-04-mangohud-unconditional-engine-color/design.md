## Context

Currently, the `engine_color` setting is written inside the `if Settings.EngineVersion then` conditional block. Since color themes set the button colors but don't enable `EngineVersion` (which is a metric setting, not a color setting), the `engine_color` is omitted from the saved MangoHUD configuration unless the user has also checked `engineversionCheckBox`. 

## Goals / Non-Goals

**Goals:**
- Unconditionally write `engine_color` to the `MangoHud.conf` output configuration file so that it is always set to the themed color.

**Non-Goals:**
- Changing other metric colors (like `gpu_color`, `cpu_color`, etc.) to be unconditional.

## Decisions

### Decision 1: Write `engine_color` outside the `Settings.EngineVersion` block in `overlay_config.pas`
- **Choice**: Separate the `engine_color` line from the `Settings.EngineVersion` conditional check, similar to `text_color` and `background_color`.
- **Alternatives**:
  - *Keep conditional, but add check for `Settings.EngineShort`*: Rejected because it does not resolve the issue if both are unchecked but the user has engine settings overridden/configured globally.
  - *Unconditional write*: Accepted because writing the setting is harmless if MangoHUD is not configured to show the engine version, and guarantees correct theming when it is displayed.

## Risks / Trade-offs

- **[Risk] Unused key in config file** → MangoHUD ignores unused color keys if the corresponding metrics are disabled. This has no performance or visual impact.
