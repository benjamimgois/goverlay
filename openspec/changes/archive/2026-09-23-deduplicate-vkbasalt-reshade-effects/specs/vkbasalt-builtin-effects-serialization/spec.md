# Spec Delta

## ADDED Requirements

### Requirement: Available ReShade Effects Filtering and Deduplication
The system SHALL populate the available ReShade effects list (`aveffectsListBox`) exclusively with unique, runnable shader files, excluding header files (`.fxh`, `.h`), duplicate effect names, and built-in effects that have dedicated native controls (`FXAA`, `SMAA`, `LUT`, `CAS`, `DLS`).

#### Scenario: Scanning shader repository with header and duplicate files
- **WHEN** the system scans the vkBasalt shader repository containing `.fx` files, header files (`.fxh`, `.h`), and multiple files sharing the same base effect name
- **THEN** only files with executable shader extensions (`.fx`, `.glsl`) are considered.
- **AND** header files such as `FXAA.fxh`, `SMAA.fxh`, `UIDetect.fxh`, `ReShade.fxh`, and `DrawText.fxh` are not added to `aveffectsListBox`.
- **AND** if multiple files share the same base effect name (case-insensitive), only the first encountered file is added to `aveffectsListBox`.

#### Scenario: Excluding built-in effects from ReShade effects list
- **WHEN** the system discovers `FXAA.fx`, `SMAA.fx`, or `LUT.fx` in the shader repository
- **THEN** they are excluded from `aveffectsListBox`, ensuring FXAA, SMAA, and LUT are only configured through the dedicated Built-in Effects controls.
