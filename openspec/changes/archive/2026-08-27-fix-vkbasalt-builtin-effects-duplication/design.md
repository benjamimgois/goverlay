## Context

vkBasalt supports both built-in effects (`cas`, `fxaa`, `smaa`, `dls`) and external ReShade shaders specified in `reshade-shaders/`. Built-in effects are tuned with dedicated keys (e.g. `casSharpness`, `fxaaQualitySubpix`), while external ReShade shaders require explicit file path mappings (`<effect_name> = <path_to_fx_file>`).

## Goals / Non-Goals

**Goals:**
- Prevent duplicate entries of built-in effects in `effects = ...`.
- Prevent spurious path mappings like `cas = .../reshade-shaders/cas`.
- Maintain clean separation between built-in effect trackbars and the ReShade active shader list.

**Non-Goals:**
- Altering the mathematical formulas used to calculate sharpness or AA quality levels.
- Changing how ReShade shaders are downloaded or mapped.

## Decisions

### Decision 1: Remove built-in effect injection from trackbar change handlers
- In `overlayunit.pas`, remove the logic in `casTrackBarChange`, `fxaaTrackBarChange`, `smaaTrackBarChange`, and `dlsTrackBarChange` that inserts or removes `'cas'`, `'fxaa'`, `'smaa'`, or `'dls'` into `acteffectsListbox.Items`.
- Rationale: Built-in effects are represented and saved via `TVkBasaltSettings.CasPosition`, `FxaaPosition`, `SmaaPosition`, and `DlsPosition`. `acteffectsListbox` is intended solely for external ReShade shaders.

### Decision 2: Defensive filtering in `SaveVkBasaltConfig`
- In `overlay_config.pas`, define a helper `function IsVkBasaltBuiltInEffect(const AName: string): Boolean` returning `True` for `cas`, `fxaa`, `smaa`, `dls`.
- When constructing `EffectsLine` from `Settings.ReshadeEffects`, skip any item matching `IsVkBasaltBuiltInEffect`.
- When generating ReShade path mappings (`<EffectKey> = <FullPath>`), skip any item matching `IsVkBasaltBuiltInEffect`.
- Rationale: Ensures complete resilience even if an old configuration file or legacy import contained built-in effect names in the active effects list.

## Risks / Trade-offs

- **[Risk] Existing configuration files with duplicated `cas:cas`**: When loaded via `LoadVkBasaltConfig`, `LoadVkBasaltConfig` already correctly recognizes `'cas'` and sets `CasPosition` without adding `'cas'` to `ActEffectsList`.
  - **Mitigation**: When saved again, the configuration will automatically be cleaned up to a single `cas` entry.
