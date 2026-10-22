# vkbasalt-effect-pipeline Specification

## Purpose
Provides a visual pipeline card on the vkBasalt tab that dynamically displays active post-processing effects and allows users to reorder the execution pipeline via drag-and-drop or move buttons, saving the resulting order into `vkBasalt.conf`.

## Requirements

### Requirement: Dynamic Pipeline Representation
The system SHALL display an "Effect Pipeline" card on the vkBasalt tab containing interactive chips for all currently active built-in and ReShade effects.

#### Scenario: Activating an effect
- **WHEN** user enables a built-in slider (CAS, FXAA, SMAA, DLS > 0) or toggles on a ReShade shader
- **THEN** a corresponding chip is appended to the pipeline card.

#### Scenario: Deactivating an effect
- **WHEN** user sets a built-in slider to 0 or toggles off a ReShade shader
- **THEN** the corresponding chip is removed from the pipeline card.

#### Scenario: Deactivating from pipeline chip
- **WHEN** user clicks the `✕` close button on a pipeline chip
- **THEN** the chip is removed from the pipeline and the corresponding slider is reset to 0 or ReShade toggle is switched off.

### Requirement: Effect Reordering
The system SHALL allow users to reorder chips in the pipeline using mouse drag-and-drop or move buttons.

#### Scenario: Moving an effect left or right
- **WHEN** user clicks the `◀` or `▶` button on a pipeline chip
- **THEN** the chip moves to the preceding or succeeding position in the pipeline sequence.

#### Scenario: Dragging an effect
- **WHEN** user clicks and drags a chip to a new slot in the pipeline
- **THEN** the pipeline chips reorder to reflect the new sequence.

### Requirement: Configuration Serialization and Persistence
The system SHALL write and read `effects = effect1:effect2:...` in `vkBasalt.conf` respecting the exact sequence shown in the pipeline card.

#### Scenario: Saving configuration with custom order
- **GIVEN** active pipeline containing `smaa`, `cas`, and `Bloom` in that order
- **WHEN** configuration is saved
- **THEN** `vkBasalt.conf` contains `effects = smaa:cas:Bloom`.

#### Scenario: Loading existing configuration
- **GIVEN** `vkBasalt.conf` with `effects = fxaa:dls:Clarity`
- **WHEN** configuration is loaded in GOverlay
- **THEN** FXAA, DLS, and Clarity are marked active with their pipeline chips displayed in that exact order (`FXAA` ➔ `DLS` ➔ `Clarity`).
