# Design

## Context

See `proposal.md` for motivation.
In `optiscaler_tab.pas`, `ReflowOptiScalerTabNew` arranges controls within `FOsSpatialSec`. When `IsHelixSrActive` is evaluated as true, it hides the OptiScaler-specific spatial controls, including `FSpoofToggle` / `spoofCheckBox`.
However, standard HelixSR execution relies on OptiScaler as the injector backend. Titles without native FSR rely on DLSS spoofing so that the in-game settings enable DLSS, which is then intercepted and routed into HelixSR.

## Goals / Non-Goals

**Goals:**
- Ensure `FSpoofToggle` / `spoofCheckBox` remains visible and interactive when `helixsrRadioButton` is checked and standard HelixSR mode is active.
- Reflow `FOsSpatialSec` layout in HelixSR mode so that all controls (Sharpener, Sharpness Trackbar, Wave Size, Spoof DLSS, and Native DLSS) fit cleanly within `BoxH` (minimum 240px) without overlapping or clipping.
- Automatically disable or hide the "Spoof DLSS" toggle when "Native DLSS (Exp.)" is active, as native DLSS bypasses OptiScaler.

**Non-Goals:**
- Modifying how OptiScaler or HelixSR handles DLSS spoofing under the hood (the backend logic in `bgmod` and `OptiScaler.ini` already properly supports spoofing).
- Adding Vulkan support to HelixSR (HelixSR is architecturally Direct3D 12 compute shaders).

## Decisions

### Decision 1: Position Spoof DLSS toggle alongside Native DLSS toggle in FOsSpatialSec
- **Choice**: Place `FSpoofToggle` at `Y0 + 172` and `FHelixSrNativeDlssToggle` at `Y0 + 198` (or vice-versa), while slightly compacting label-to-control gaps for Sharpener, Sharpness, and Wave Size.
- **Alternatives considered**:
  - *Moving Spoof DLSS to Main sub-card (`FOsMainSec`)*: Rejected because Spoof DLSS has always been located in the Spatial Upscaler column, and `FOsMainSec` already hosts GPU driver, filename proxy, OptiPatcher, and shortcut key.
  - *Leaving Spoof DLSS at its default position and moving HelixSR controls down*: Would push controls past the 240px card boundary on smaller resolutions.

### Decision 2: State synchronization between Native DLSS and Spoof DLSS
- **Choice**: When Native DLSS is checked (`helixsrNativeDlssCheckBox.Checked = True`), disable or hide `FSpoofToggle` and dim its appearance, because the native loader directly replaces `nvngx.dll` without OptiScaler's DXGI/fakenvapi spoofing mechanism.
- **Alternatives considered**:
  - *Always keeping Spoof DLSS enabled regardless of Native DLSS*: Could confuse users since OptiScaler.ini is bypassed in Native DLSS mode.

## Risks / Trade-offs

- **[Risk]**: Layout vertical height overflow on compact window sizes (< 640px height).
  - **Mitigation**: Standardize control row heights: Sharpener (Y0..Y0+44), Sharpness (Y0+48..Y0+88), WaveSize (Y0+92..Y0+136), Spoof DLSS (Y0+144), Native DLSS (Y0+172). Total height is < 210px, leaving ample margin within the 240px minimum container.
