# Design: Purge Remaining Legacy Containers

## Architecture & Reparenting Principles
Modern tabs in GOverlay create runtime panels (`TPanel`) styled with MD3 / dark card themes and reparent controls from the LFM.
When removing legacy `TGroupBox` containers:
- **Do not introduce `Visible = False` on active controls**: Functional controls (`TCheckBox`, `TComboBox`, `TTrackBar`, `TSpinEdit`, `TColorButton`, `TEdit`, `TRadioButton`, `TLabel`) must retain natural visibility so that when reparented into modern cards, they render seamlessly.
- **Clear Anchors**: Reparented controls receive `Anchors = []` in LFM to avoid invalid anchor references to deleted containers.
- **Clean Pascal References**: Groupbox field declarations in `overlayunit.pas` and code that references them (`UnanchorControl`, `.Visible := False`, manual bounding calculations) are removed.

## Scope of Changes

### 1. vkBasalt Tab
- **LFM Elements to Remove**:
  - `reshadeGroupBox: TGroupBox`
  - `builtineffectsGroupBox: TGroupBox`
- **Controls Reparented**:
  - ReShade effect checkboxes and edit controls reparented to `vkbasaltTabSheet`.
  - Built-in effect checkboxes and edit controls reparented to `vkbasaltTabSheet`.
- **Pascal Cleanup**:
  - In `overlayunit.pas`: remove `reshadeGroupBox`, `builtineffectsGroupBox`.
  - In `vkbasalt_tab.pas`: remove `reshadeGroupBox.Visible := False;` and `builtineffectsGroupBox.Visible := False;`.

### 2. OptiScaler Tab
- **LFM Elements to Remove**:
  - `gpudriverGroupBox: TGroupBox`
  - `optionsGroupBox: TGroupBox` (outer)
  - `optiscalerGroupBox: TGroupBox` (inner)
  - `fakenvapiGroupBox: TGroupBox` (inner)
  - `imgmenuGroupBox: TGroupBox` (inner)
  - `statusGroupBox: TGroupBox`
- **Controls Reparented**:
  - `nvidiaRadioButton`, `mesaRadioButton`, `driverLabel`, proxy DLL combos, upscaler controls, reflex options, etc., reparented to `optiscalerTabSheet`.
- **Pascal Cleanup**:
  - In `overlayunit.pas`: remove groupbox fields, remove `UnanchorControl` calls, remove obsolete layout block at lines ~9876-9878.
  - In `optiscaler_tab.pas`: remove lines setting `.Visible := False` on these groupboxes.

### 3. Tweaks Tab
- **LFM Elements to Remove**:
  - `basicGroupBox: TGroupBox` (outer)
  - `generalGroupBox: TGroupBox` (inner)
  - `graphicsGroupBox: TGroupBox` (inner)
  - `advancedGroupBox: TGroupBox` (outer)
  - `performanceGroupBox: TGroupBox` (inner)
- **Controls Reparented**:
  - General tweaks checkboxes, graphics checkboxes, performance checkboxes reparented to `tweaksTabSheet`.
- **Pascal Cleanup**:
  - In `overlayunit.pas`: remove groupbox fields and `UnanchorControl` calls.
  - In `tweaks_md3.pas`: remove lines setting `basicGroupBox.Visible := False` and `advancedGroupBox.Visible := False`.
