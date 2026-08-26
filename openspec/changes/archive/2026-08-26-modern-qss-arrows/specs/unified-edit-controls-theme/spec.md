## ADDED Requirements

### Requirement: Modern Pure QSS Vector Arrows for Dropdown and Stepper Controls
The application SHALL render dropdown indicators (`QComboBox::down-arrow`) and numeric stepper buttons (`QSpinBox::up-button`, `QSpinBox::down-button`, `QSpinBox::up-arrow`, `QSpinBox::down-arrow`) using pure QSS geometric shapes in bright slate-silver (`rgb(220, 230, 245)`) that highlight in cyan (`rgb(48, 190, 240)`) on hover and focus without relying on external image files.

#### Scenario: Rendering dropdown and stepper arrows
- **WHEN** any ComboBox or SpinBox control is rendered in the interface
- **THEN** dropdown and stepper arrows display crisp, high-contrast geometric indicators integrated with the Slate Navy theme

#### Scenario: Hover feedback on dropdown and stepper controls
- **WHEN** the user hovers over a ComboBox or clicks/hovers a SpinBox stepper button
- **THEN** the stepper background subtly highlights (`rgb(50, 62, 96)`) and the arrow switches to bright cyan accent (`rgb(48, 190, 240)`)
