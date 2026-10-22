# Tasks

## 1. Full-Width Method Card Refactor

- [x] 1.1 In `optiscaler_tab.pas`, update `ReflowOptiScalerTabNew` to set `FOsUpscalerCard` width to `CW`, hide `FOsGpuCard`, and evenly distribute the three method slots (`None`, `OptiScaler`, `DLSS Enabler`) across `SlotW := (CW - 2 * PAD) div 3`.
- [x] 1.2 Verify that the three method radio buttons and logo images are properly centered within each slot.

## 2. GPU Driver Selector in Options Main Column

- [x] 2.1 In `optiscaler_tab.pas`, instantiate `gpudriverLabel` and `gpudriverComboBox` inside `FOsMainSec` (Options > Main column) with items for Mesa (AMD/Intel) and NVIDIA.
- [x] 2.2 In `overlayunit.pas`, wire `gpudriverComboBox.OnChange` to bridge to `mesaRadioButtonChange` / `nvidiaRadioButtonChange`, and initialize its selection from hardware detection (`IsNvidiaModuleLoaded`) or saved preferences (`LoadOptiScalerDriverPreference`).
- [x] 2.3 Reflow the vertical bounds inside `FOsMainSec` for Proxy DLL, GPU Driver, Menu scale, OptiPatcher, and shortcut key, ensuring all controls fit within the sub-card height.

## 3. Verification and Regression Testing

- [x] 3.1 Run the test suite (`./tests/test_runner`) and verify that all OptiScaler GUI and logic tests pass.
- [x] 3.2 Verify layout height on `FOsScrollBox` ensuring no unwanted vertical scrollbar appears at standard window dimensions.
