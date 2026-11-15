# Design

## Context

See `proposal.md` for the user-reported problem in issue #463.

In Goverlay's current startup and profile-loading flow:
1. `Tgoverlayform.FormCreate` (`overlayunit.pas`) calls `LoadOptiScalerConfig` while `FLoadingConfig` is `False` and before `FOptiscalerUpdate` (`TOptiscalerTab`) is instantiated.
2. `TOptiScalerTabHelper.LoadOptiScalerConfig` (`optiscaler_tab.pas`) suppresses `OnChange` on five comboboxes, but does not suppress `OnClick` on the upscaler radio buttons (`optiscalerRadioButton`, `dlssenablerRadioButton`, `noneUpscalerRadioButton`, `helixsrRadioButton`, `dlssnrRadioButton`).
3. In LCL, changing `TRadioButton.Checked` from `False` to `True` fires `OnClick`. On startup, `optiscalerRadioButton.Checked` transitions from `False` to `True`, invoking `optiscalerRadioButtonClick` (`overlayunit.pas`), which derives `optversionComboBox.ItemIndex` from the still-unpopulated `optlabel1.Caption` (defaulting to `0`) and immediately calls `SaveOptiScalerConfig(True)` — overwriting `OPT_CHANNEL=0` in `gameconfig/global/bgmod.conf` before `FOptiscalerUpdate.InitializeTab` runs.
4. Separately, `TSidebarNavHelper.CopyOptiScalerGameFiles` (`sidebar_nav.pas`) unconditionally copies `fakenvapi.ini` from cache, overwriting existing user settings, and `forcereflexCheckBoxChange` (`overlayunit.pas`) leaves `reflexComboBox.ItemIndex` at `0` (`Follow game setting`) when toggled on, which serializes `force_reflex=0` and reloads as unchecked per `optiscaler-reflex-persistence`.

## Goals / Non-Goals

**Goals:**
- Prevent programmatic UI loading (`FormCreate` and `LoadOptiScalerConfig`) from firing upscaler radio-button click handlers or triggering `SaveOptiScalerConfig`.
- Ensure `fakenvapi.ini` in `gameconfig/global/` and `gameconfig/<game>/` is not overwritten when already present during `CopyOptiScalerGameFiles`.
- Ensure enabling the Force Reflex toggle without touching `reflexComboBox` selects `Force enable` (`2`) so the user's intent persists across restarts.

**Non-Goals:**
- Changing the `optiscaler-reflex-persistence` contract where `force_reflex=0` maps to unchecked on load.
- Refactoring the entire `FormCreate` initialization order beyond what is needed to keep config loading side-effect free.

## Decisions

1. **Dual load-guard (suppress `OnClick` + check `FLoadingConfig`)**:
   - In `TOptiScalerTabHelper.LoadOptiScalerConfig`, save and nil `OnClick` on all five upscaler radio buttons inside the existing `try ... finally` block alongside the combobox `OnChange` handlers.
   - In `Tgoverlayform.FormCreate`, wrap `LoadOptiScalerConfig` (and sibling startup config loads or specifically `LoadOptiScalerConfig`) with `FLoadingConfig := True` / `try ... finally FLoadingConfig := False`, and guard `*RadioButtonClick` handlers with `if FLoadingConfig then Exit;` before calling `SaveOptiScalerConfig(True)`.
   - *Rationale*: Silencing `OnClick` during `LoadOptiScalerConfig` prevents LCL from running UI-click side effects during any profile load (startup or game switch), while `FLoadingConfig` provides defense-in-depth for any other startup event propagation.
   - *Alternative considered*: Only reordering `FOptiscalerUpdate.InitializeTab` before `LoadOptiScalerConfig`. Rejected because switching between profiles with different `UPSCALER_TYPE` values would still trigger `SaveOptiScalerConfig(True)` mid-load.

2. **Seed `fakenvapi.ini` only when missing in `CopyOptiScalerGameFiles`**:
   - Guard both `CopyFile(..., 'fakenvapi.ini')` branches in `TSidebarNavHelper.CopyOptiScalerGameFiles` (`sidebar_nav.pas`) with `if not FileExists(IncludeTrailingPathDelimiter(AGameCfgDir) + 'fakenvapi.ini') then` (matching `bgmod_resources.pas` and `optiscaler_update.pas`).
   - *Rationale*: `fakenvapi.ini` is a user-editable config file; asset sync should seed it only if missing.

3. **Auto-select `Force enable` (`2`) when toggling Force Reflex ON from index `0`**:
   - In `Tgoverlayform.forcereflexCheckBoxChange`, when `forcereflexCheckBox.Checked` is `True` and `reflexComboBox.ItemIndex <= 0` (and not `FLoadingConfig`), set `reflexComboBox.ItemIndex := 2` (`Force enable`).
   - *Rationale*: Matches the control's own hint ("The recommended setting is 'Force enable'") and avoids the silent reset caused by saving `force_reflex=0` when the user only clicks the toggle.

## Risks / Trade-offs

- [Suppressing `OnClick` on upscaler radio buttons skips `UpdateUpscalerImageOpacity`, `UpdateFrameGenOptionsUI`, `ReflowOptiScalerTabNew`, and `RefreshOsStatusDots` inside those handlers] → Mitigation: `LoadOptiScalerConfig` already calls `UpdateUpscalerImageOpacity`, `UpdateFrameGenOptionsUI`, and `ReflowOptiScalerTabNew(0)` at lines 3561–3580, and `FormCreate` calls `RefreshOsStatusDots` at line 4517.
- [Auto-selecting `Force enable` (`2`) on toggle-on assumes users turning on the Force Reflex switch do not want `Follow game setting` (`0`)] → Mitigation: `Follow game setting` is the unforced state represented by the toggle being OFF; if the user explicitly picks `Follow game setting` in the dropdown afterwards, it still works as before.
