# Unified Edit Controls Theme

## Purpose

Provides consistent visual styling and interactive focus state feedback across all text edit fields (`QLineEdit`) and numeric spin boxes (`QSpinBox`) in the GOverlay interface using the Slate Navy design palette.

## Requirements

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

### Requirement: Modern Pure QSS Vector Arrows for Dropdown and Stepper Controls
The application SHALL render dropdown indicators (`QComboBox::down-arrow`) and numeric stepper buttons (`QSpinBox::up-button`, `QSpinBox::down-button`, `QSpinBox::up-arrow`, `QSpinBox::down-arrow`) using pure QSS geometric shapes in bright slate-silver (`rgb(220, 230, 245)`) that highlight in cyan (`rgb(48, 190, 240)`) on hover and focus without relying on external image files.

#### Scenario: Rendering dropdown and stepper arrows
- **WHEN** any ComboBox or SpinBox control is rendered in the interface
- **THEN** dropdown and stepper arrows display crisp, high-contrast geometric indicators integrated with the Slate Navy theme

#### Scenario: Hover feedback on dropdown and stepper controls
- **WHEN** the user hovers over a ComboBox or clicks/hovers a SpinBox stepper button
- **THEN** the stepper background subtly highlights (`rgb(50, 62, 96)`) and the arrow switches to bright cyan accent (`rgb(48, 190, 240)`)
