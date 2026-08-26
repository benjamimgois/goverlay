# Design: Modern Pure QSS Vector Arrows for ComboBox and SpinBox Controls

## Context
GOverlay runs on Qt6/Qt5 via the Lazarus LCL interface. Input controls (`QComboBox`, `QSpinBox`, `QDoubleSpinBox`) use stylesheets to maintain a dark Slate Navy theme overriding OS themes. Relying on external image assets caused scaling and visibility issues (tiny dot appearance). Pure QSS border geometry creates high-contrast vector arrows rendered directly by Qt with zero asset file dependencies.

## Goals / Non-Goals

**Goals:**
- Implement pure QSS CSS border triangles for `QComboBox::down-arrow`, `QSpinBox::up-arrow`, and `QSpinBox::down-arrow`.
- Provide high contrast (`rgb(220, 230, 245)`) and interactive cyan highlights (`rgb(48, 190, 240)`).
- Ensure consistent rendering across all ComboBoxes and SpinBoxes in the application.

**Non-Goals:**
- Modify standard push buttons or slider styles.
- Support non-Qt widgetsets.

## Decisions

### Decision 1: Pure CSS border geometry vs image files
- **Chosen**: Pure CSS border triangles (`border-top: 5px solid ...; border-left: 4px solid transparent; ...`).
- **Rationale**: Rendered natively and cleanly by Qt's QSS engine at any DPI with zero latency, no asset file paths or missing icon risks, and native hover pseudo-class color transitions.
- **Alternative considered**: PNG/SVG icons in `assets/icons/`. Rejected due to DPI downscaling padding artifacts causing tiny dots.

## Risks / Trade-offs

- **[Risk] Qt subcontrol positioning offset**: Arrow may appear slightly misaligned on certain widget themes.
  - **Mitigation**: Use explicit `subcontrol-origin`, `subcontrol-position`, and standard pixel dimensions (`width: 0; height: 0` with defined borders).
