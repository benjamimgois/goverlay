# Tasks

## 1. Load Guards for Upscaler Radio Buttons and Startup

- [x] 1.1 In `optiscaler_tab.pas` (`TOptiScalerTabHelper.LoadOptiScalerConfig`), save and nil `OnClick` handlers on `optiscalerRadioButton`, `dlssenablerRadioButton`, `noneUpscalerRadioButton`, `helixsrRadioButton`, and `dlssnrRadioButton` inside the `try ... finally` block so programmatic `.Checked := True` does not fire click handlers; verify by building the project.
- [x] 1.2 In `overlayunit.pas` (`Tgoverlayform.FormCreate`), wrap `LoadOptiScalerConfig` with `FLoadingConfig := True` / `try ... finally FLoadingConfig := False` and guard `*RadioButtonClick` handlers (`optiscalerRadioButtonClick`, `dlssenablerRadioButtonClick`, `noneUpscalerRadioButtonClick`, `helixsrRadioButtonClick`, `dlssnrRadioButtonClick`) with `if FLoadingConfig then Exit;` before saving; verify by running GUI tests or starting Goverlay with `OPT_CHANNEL=1` in `gameconfig/global/bgmod.conf` and confirming it remains `1`.

## 2. Force Reflex Persistence and Template Seeding

- [x] 2.1 In `sidebar_nav.pas` (`TSidebarNavHelper.CopyOptiScalerGameFiles`), only copy `fakenvapi.ini` from cache when `AGameCfgDir + 'fakenvapi.ini'` does not already exist; verify existing `fakenvapi.ini` values are preserved when toggling OptiScaler on via the sidebar.
- [x] 2.2 In `overlayunit.pas` (`Tgoverlayform.forcereflexCheckBoxChange`), when `forcereflexCheckBox.Checked` is `True`, `not FLoadingConfig`, and `reflexComboBox.ItemIndex <= 0`, set `reflexComboBox.ItemIndex := 2` (`Force enable`); verify toggling Force Reflex ON writes `force_reflex=2` to `fakenvapi.ini`.

## 3. Regression Tests & Verification

- [x] 3.1 Add automated logic/GUI tests in `tests/` verifying that (a) global `OPT_CHANNEL` in `gameconfig/global/bgmod.conf` is preserved across startup/reload, (b) enabling Force Reflex defaults to `Force enable` (`force_reflex=2`) and persists across reload, and (c) `CopyOptiScalerGameFiles` does not overwrite an existing `fakenvapi.ini`; run the test suite and confirm all tests pass.
