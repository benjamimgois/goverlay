# Change Proposal: Dynamic Frame Generation Options per Upscaler Mode

## Why
OptiScaler (traditional standalone) and DLSS-Enabler support different Frame Generation (FG) backends and inputs. For example:
- `nukems` exists only in traditional OptiScaler (for both FG Input and FG Output).
- `nvngxfg`, `dlssg`, and `dlssgwithnvngx` exist only in DLSS-Enabler (specifically in FG Output, with `nvngxfg` replacing `nukems` in FG Input).

Currently, GOverlay shows a static list of combobox items regardless of whether the user selects OptiScaler or DLSS-Enabler. This leads to invalid options being shown for the selected upscaler mode and incorrect tooltip descriptions.

## What
- Dynamically update the items and hints of `fgInputComboBox` ("FG Input") and `fgOutputComboBox` ("FG Output") based on whether OptiScaler or DLSS-Enabler radio button is selected (`optiscalerRadioButton` vs `dlssenablerRadioButton`).
- For **OptiScaler**:
  - `FGInput`: `auto`, `nofg`, `dlssg`, `nukems`, `fsrfg`, `upscaler`, `fsrfg30`
  - `FGOutput`: `auto`, `nofg`, `fsrfg`, `xefg`, `nukems`
  - Hints reflect OptiScaler documentation (`nukems` descriptions).
- For **DLSS-Enabler**:
  - `FGInput`: `auto`, `nofg`, `dlssg`, `nvngxfg`, `fsrfg`, `upscaler`, `fsrfg30`
  - `FGOutput`: `auto`, `nofg`, `fsrfg`, `xefg`, `nvngxfg`, `dlssg`, `dlssgwithnvngx`
  - Hints reflect DLSS-Enabler documentation (`nvngxfg`, `dlssg`, `dlssgwithnvngx` descriptions).
- Seamlessly preserve user selections or map equivalent options (e.g. `nukems` <-> `nvngxfg`) when toggling between modes.
- Update `SaveOptiScalerConfigCore` and `LoadOptiScalerConfig` in `overlay_config.pas` to persist mode-appropriate strings to `OptiScaler.ini`.
