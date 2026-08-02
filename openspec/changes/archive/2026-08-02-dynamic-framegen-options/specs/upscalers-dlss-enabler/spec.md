# Capability: Upscalers Tab & Frame Generation Options

## MODIFIED Requirements

### Requirement: Dynamic Frame Generation Options based on Selected Upscaler Mode
GOverlay SHALL update the items and tooltip descriptions of the `FG Input` (`fgInputComboBox`) and `FG Output` (`fgOutputComboBox`) comboboxes dynamically when the user switches between OptiScaler (`optiscalerRadioButton`) and DLSS-Enabler (`dlssenablerRadioButton`).

#### Scenario: OptiScaler mode selected
- **WHEN** user selects the OptiScaler mode radio button
- **THEN** `FG Input` combobox items SHALL be `['auto', 'nofg', 'dlssg', 'nukems', 'fsrfg', 'upscaler', 'fsrfg30']`
- **AND** `FG Output` combobox items SHALL be `['auto', 'nofg', 'fsrfg', 'xefg', 'nukems']`
- **AND** tooltips SHALL display OptiScaler-specific backend descriptions (`nukems` options).

#### Scenario: DLSS-Enabler mode selected
- **WHEN** user selects the DLSS-Enabler mode radio button
- **THEN** `FG Input` combobox items SHALL be `['auto', 'nofg', 'dlssg', 'nvngxfg', 'fsrfg', 'upscaler', 'fsrfg30']`
- **AND** `FG Output` combobox items SHALL be `['auto', 'nofg', 'fsrfg', 'xefg', 'nvngxfg', 'dlssg', 'dlssgwithnvngx']`
- **AND** tooltips SHALL display DLSS-Enabler-specific backend descriptions (`nvngxfg`, `dlssg`, `dlssgwithnvngx` options).
