## MODIFIED Requirements

### Requirement: Robust case and whitespace-insensitive INI key parsing
GOverlay's INI configuration parser SHALL match and update keys and section headers in `OptiScaler.ini` in a case-insensitive and whitespace-insensitive manner, supporting section names passed with or without surrounding brackets (`[SectionName]` or `SectionName`), and inserting new keys at the end of existing sections without appending unbracketed section headers or duplicate lines.

#### Scenario: Load key with different casing and spaces
- **WHEN** the `OptiScaler.ini` file contains `dxgi = false` and the parser looks for `'Dxgi='`
- **THEN** the parser successfully matches the line and reads the value as `false`.

#### Scenario: Update key with different casing and spaces
- **WHEN** GOverlay saves the settings and updates a key (like `Dxgi=`) in an `OptiScaler.ini` file containing `dxgi = false`
- **THEN** the parser overwrites the existing `dxgi = false` line instead of appending a new one.

#### Scenario: Update key in section passed with or without brackets
- **WHEN** GOverlay saves FrameGen settings to `OptiScaler.ini` by calling `SetValue` with section `FrameGen` or `[FrameGen]`
- **THEN** the parser locates the existing `[FrameGen]` section header, updates or appends the key within `[FrameGen]`, and does not append unbracketed `FrameGen` headers to the end of the file.

#### Scenario: Creating a missing section header
- **WHEN** GOverlay saves settings to an INI file for a section header that does not yet exist
- **THEN** the parser creates a new section header with proper brackets `[SectionName]` followed by the key-value pair.
