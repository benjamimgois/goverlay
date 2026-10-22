## Context
See `proposal.md` for background motivation.
OptiScaler tab options are organized into 4 sub-cards within `FOsOptionsCard` in `optiscaler_tab.pas`. Sub-card 1 ("Main") hosts global engine settings including Hook DLL, Menu scale, OptiPatcher, and toggle buttons. Configuration is loaded via `overlay_config.LoadOptiScalerConfig` and serialized via `overlay_config.SaveOptiScalerConfigCore` into `OptiScaler.ini`.

## Goals / Non-Goals

**Goals:**
- Add `loglevelComboBox` with options `0 - Trace` through `4 - Error` inside Sub-card 1 ("Main").
- Display a descriptive tooltip explaining the verbosity levels and warning about performance impacts of Trace and Debug modes.
- Implement auto-save on `loglevelComboBox` change.
- Persist `LogLevel` under section `[Log]` in `OptiScaler.ini`.
- Fix OptiPatcher default initialization so `LoadAsiPlugins=auto` (and missing key) evaluates to `True`, while preserving explicit user deactivation (`LoadAsiPlugins=false`).

**Non-Goals:**
- Modifying other log parameters such as `LogToFile`, `LogToConsole`, or `LogFileName` which are managed automatically by `bgmod`.
- Adding log viewer UI or file inspection within GOverlay.

## Decisions

### Decision 1: Placement within Sub-card 1 ("Main")
Place `loglevelLabel` and `loglevelComboBox` directly below `menuscaleComboBox` (Y0 + 112 / Y0 + 130) before `FOptiPatcherToggle`.
- *Rationale*: Groups general engine dropdowns (Hook DLL, Menu scale, Log level) cleanly at the top of the card, preceding toggles and hotkey buttons.
- *Alternatives considered*: Placing at the bottom below DLSS-Enabler toggle button, which would fragment selector controls and leave large vertical gaps.

### Decision 2: Layout height expansion (`MinOptH`)
Increase `MinOptH` in `ReflowOptiScalerTabNew` from `315` to `365`.
- *Rationale*: Sub-card 1 contains 5 control groups. Expanding `MinOptH` ensures all controls fit with proper spacing without overlapping. `FOsScrollBox` automatically provides scrolling on small viewports.

### Decision 3: Auto-Save event handling
Implement `loglevelComboBoxChange` in `Tgoverlayform`:
```pascal
procedure Tgoverlayform.loglevelComboBoxChange(Sender: TObject);
begin
  if (Sender <> nil) and not FLoadingConfig then
    StartAutoSaveTimer;
end;
```
During `LoadOptiScalerConfig`, detach `loglevelComboBox.OnChange := nil` and restore it in the `finally` block, matching `fsrversionComboBox` and `optversionComboBox`.

### Decision 4: OptiPatcher default resolution
In `overlay_config.pas`:
```pascal
Value := OptiCfg.GetValue(OPTI_KEY_LOAD_ASI, '');
if SameText(Value, 'false') then
  Settings.OptipatcherChecked := False
else
  Settings.OptipatcherChecked := True;
```
- *Rationale*: Template files initialize with `LoadAsiPlugins=auto`. Evaluating `auto` as `True` enables OptiPatcher by default for new games, while `SameText(Value, 'false')` honors explicit user deactivation.

## Risks / Trade-offs

- [Risk] Layout clipping in low-resolution screens.
  → *Mitigation*: The entire tab is hosted in a scroll box (`FOsScrollBox`), which seamlessly scrolls when `TotalH` exceeds the viewport.
- [Risk] Unintended auto-save during tab navigation or config loading.
  → *Mitigation*: Guard with `(Sender <> nil) and not FLoadingConfig` and detach `OnChange` during load.
