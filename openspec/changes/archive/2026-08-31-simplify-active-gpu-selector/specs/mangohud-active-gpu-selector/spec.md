## Purpose

Provides a clean, unified Active GPU dropdown in the MangoHud Visual tab that displays commercial GPU names with index prefixes and directly maps selections to the `gpu_list` configuration.

## ADDED Requirements

### Requirement: Formatted GPU Item Display
The system SHALL display detected GPUs in a single full-width ComboBox formatted with `GPU <index>: <Clean Market Name>` (e.g. `GPU 0: AMD Radeon RX 7900 XTX`), hiding the raw PCI bus ID and redundant description text box.

#### Scenario: Single GPU detected
- **WHEN** GOverlay initializes on a system with one GPU
- **THEN** the Active GPU ComboBox contains a single entry formatted as `GPU 0: <Clean Market Name>`.

#### Scenario: Multiple GPUs detected
- **WHEN** GOverlay initializes on a system with multiple GPUs
- **THEN** the ComboBox lists all detected GPUs with sequential `GPU <index>:` prefixes, plus a trailing "Use both GPUs" option.

### Requirement: Direct Config Mapping to gpu_list
The system SHALL map the selected GPU ComboBox item directly to the MangoHud `gpu_list` configuration parameter upon saving and accurately restore the selection when reading `gpu_list` on load.

#### Scenario: Single GPU selected
- **WHEN** the user selects `GPU 0` or `GPU 1` from the Active GPU dropdown
- **THEN** the configuration writes `gpu_list=0` or `gpu_list=1` respectively.

#### Scenario: Both GPUs selected
- **WHEN** the user selects the "Use both GPUs" option
- **THEN** the configuration writes `gpu_list=0,1`.

#### Scenario: Configuration loaded
- **WHEN** a MangoHud configuration containing `gpu_list=X` or `gpu_list=0,1` is loaded
- **THEN** the ComboBox automatically selects the matching GPU entry.
