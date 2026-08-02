## Purpose

Provides consistent visual styling and interactive focus state feedback across all text edit fields (`QLineEdit`) and numeric spin boxes (`QSpinBox`) in the GOverlay interface using the Slate Navy design palette.

## ADDED Requirements

### Requirement: Slate Navy Theme for Edit and SpinBox Controls
The application SHALL apply the Slate Navy theme (`rgb(38,46,72)` background, `rgb(55,70,108)` border, `rgb(255,255,255)` text color) globally to all `QLineEdit` and `QSpinBox` controls.

#### Scenario: Rendering Edit and SpinBox controls
- **WHEN** any tab containing `QLineEdit` or `QSpinBox` controls is rendered
- **THEN** the inputs display a Slate Navy background (`rgb(38,46,72)`) with a subtle border (`rgb(55,70,108)`) and white text

### Requirement: Active Focus Visual Feedback for Input Controls
The application SHALL display a cyan accent border (`rgb(48,190,240)`) when a `QLineEdit` or `QSpinBox` control receives keyboard or mouse focus (`:focus`).

#### Scenario: User focuses on an edit field or spin box
- **WHEN** the user clicks or tabs into a `QLineEdit` or `QSpinBox` control
- **THEN** the control border changes to cyan (`rgb(48,190,240)`) to indicate active focus state

### Requirement: Disabled State Styling for Input Controls
The application SHALL render disabled `QLineEdit` and `QSpinBox` controls (`:disabled`) with a darker background (`rgb(28,34,54)`) and dimmed text (`rgb(100,110,130)`).

#### Scenario: Input control is disabled by application logic
- **WHEN** a `QLineEdit` or `QSpinBox` control is set to disabled
- **THEN** the background darkens to `rgb(28,34,54)` and the text color changes to `rgb(100,110,130)`
