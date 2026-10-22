## 1. Config Serialization & Data Model

- [x] 1.1 Update `TVkBasaltSettings` in `overlay_config.pas` to include `PipelineEffects: TStrings`
- [x] 1.2 Update `SaveVkBasaltConfig` in `overlay_config.pas` to serialize `effects = ...` using `PipelineEffects`
- [x] 1.3 Update `LoadVkBasaltConfig` in `overlay_config.pas` to parse `effects = ...` into `Settings.PipelineEffects`

## 2. Pipeline UI Component & Interactions

- [x] 2.1 Create `FVkPipelineCard`, `FVkPipelinePB`, and `FPipelineEffects` list in `vkbasalt_tab.pas`
- [x] 2.2 Implement custom chip painting (`VkPipelineCardPaint`) with category colors, connectors, and move/close buttons in `vkbasalt_tab.pas`
- [x] 2.3 Implement mouse event handlers (`MouseDown`, `MouseMove`, `MouseUp`) for drag & drop and button clicks in `vkbasalt_tab.pas`
- [x] 2.4 Integrate pipeline synchronization with slider changes (CAS, FXAA, SMAA, DLS) and ReShade toggle clicks in `vkbasalt_tab.pas` and `overlayunit.pas`
- [x] 2.5 Update `ReflowVkBasaltTab` in `vkbasalt_tab.pas` to position `FVkPipelineCard` smoothly between `FVkBuiltinCard` and `FVkToggleCard`

## 3. Testing and Verification

- [x] 3.1 Add logic tests in `tests/logic/logic_test_cases.pas` verifying pipeline serialization and round-trip order
- [x] 3.2 Add GUI tests in `tests/gui/gui_test_cases.pas` verifying pipeline chip creation, reordering, and slider/toggle sync
- [x] 3.3 Run test suites (`make test-logic` and `make test-gui`) to ensure zero errors and zero regressions

