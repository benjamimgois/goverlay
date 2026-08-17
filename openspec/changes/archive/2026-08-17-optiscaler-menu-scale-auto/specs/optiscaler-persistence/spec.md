## ADDED Requirements

### Requirement: OptiScaler Menu Scale auto default option and persistence
GOverlay SHALL provide `auto` as the first and default option in the `Menu scale` combobox on the Upscalers tab, write `Scale=auto` to the `[Menu]` section of `OptiScaler.ini` when `auto` is selected, and parse `Scale=auto` or missing/empty scale values as `auto` upon loading.

#### Scenario: Default Menu scale selection
- **WHEN** GOverlay loads default OptiScaler settings or creates a new configuration
- **THEN** the `Menu scale` combobox SHALL have `auto` selected by default.

#### Scenario: Saving OptiScaler settings with auto Menu scale selected
- **WHEN** user saves OptiScaler settings with `auto` selected in the `Menu scale` combobox
- **THEN** GOverlay SHALL write `Scale=auto` to the `[Menu]` section of `OptiScaler.ini`.

#### Scenario: Saving OptiScaler settings with numeric Menu scale selected
- **WHEN** user saves OptiScaler settings with `1.5` selected in the `Menu scale` combobox
- **THEN** GOverlay SHALL write `Scale=1.5` to the `[Menu]` section of `OptiScaler.ini`.

#### Scenario: Loading OptiScaler settings with Scale=auto
- **WHEN** GOverlay loads an `OptiScaler.ini` file containing `Scale=auto` or no `Scale` key
- **THEN** GOverlay SHALL select `auto` (index 0) in the `Menu scale` combobox.
