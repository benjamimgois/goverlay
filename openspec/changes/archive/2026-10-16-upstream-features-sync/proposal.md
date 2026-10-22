# Proposal: Upstream Features Sync

## Why
External gaming tools managed by Goverlay (OptiScaler, MangoHud, HelixSR, vkSumi, MAKO) have released new versions with critical new parameters and configuration capabilities. Integrating these options into Goverlay's UI gives users access to new graphics features (such as FSR4 watermark detection, Vulkan present modes, DX API reporting, and color grading compare modes) and ensures ongoing configuration compatibility.

## What Changes
- **OptiScaler**:
  - Add dropdown for `Fsr4Preset` selection (Auto, Native, Quality, Balanced, Performance, Ultra Performance, DRS).
  - Add dropdown for `FGNvngxReplacement` (Auto, None, Nukems, Arturs, FFX, Combo).
- **MangoHud**:
  - Wire up existing `dxapiCheckBox` in Extras tab to serialize `dx_api` in `MangoHud.conf`.
  - Add UI toggle for `text_outline` (black outline around text metrics).
  - Add spin control / input for `fps_sampling_period`.
- **HelixSR**:
  - Add dropdown for `Sharpener` mode (Off, NVIDIA, RCAS).
  - Add trackbar for `Sharpness` intensity (0.00 to 1.00).
  - Add dropdown for `WaveSize` compute shader execution width (Auto, 32, 64).
- **vkSumi**:
  - Add toggle for `compare` mode (split-screen A/B comparison).
  - Add dropdown for `daltonize` color blindness correction (Off, Protanopia, Deuteranopia, Tritanopia).
  - Add trackbar for `vignette` intensity.
- **MAKO**:
  - Add UI toggle for `disable_steam_overlay` in MAKO frame generation settings.

## Capabilities

### New Capabilities
- `upstream-features-sync`: Introduces GUI controls and INI/conf serialization for newly released upstream features across OptiScaler, MangoHud, HelixSR, vkSumi, and MAKO.

### Modified Capabilities
*(None - existing spec requirements remain preserved while new controls extend functionality)*

## Impact
- **Codebase Units**:
  - `configkeys.pas`: New constant keys for OptiScaler, MangoHud, HelixSR, vkSumi, and MAKO.
  - `optiscaler_tab.pas`: New controls for FSR4 presets, FG Nvngx, and HelixSR sharpening/wavesize.
  - `mangohud_ui.pas`: Serialization for `dx_api` and new control for `text_outline`.
  - `vkbasalt_tab.pas`: New controls for vkSumi A/B comparison, vignette, and daltonize.
  - `lossless_scaling_tab.pas`: New toggle for MAKO Steam overlay suppression.
  - `hintsunit.pas` and `goverlay_strings.pas`: Tooltips and localized descriptive strings.
- **Dependencies**: No external binary additions required; communicates with existing upstream layers.
