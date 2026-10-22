## MODIFIED Requirements

### Requirement: Multi-Engine Interpolation Method Selection
The system SHALL provide a Method selector allowing the user to select between "None", "lsfg-vk", and "MAKO" engines via radio buttons and adjacent clickable rectangular banner images, persisting the selection in `bgmod.conf`. The "lsfg-vk" and "MAKO" methods SHALL use self-contained rectangular banner images integrating squircle rounded icons with uniform white bold typography. The active method logo SHALL display at 100% full brightness, and unselected method logos SHALL display visibly dimmed to approximately 35% RGB brightness with preserved alpha transparency without separate text labels.

#### Scenario: User selects None method
- **WHEN** user selects the "None" method
- **THEN** system sets `GOVERLAY_LOSSLESS=0`, adjusts the multiplier to 1x, displays the None logo at 100% full brightness, dims the "lsfg-vk" and "MAKO" banner images to approximately 35% brightness, and disables frame generation injection flags.

#### Scenario: User selects lsfg-vk method
- **WHEN** user selects the "lsfg-vk" method via its radio button or its rectangular banner image
- **THEN** system sets `GOVERLAY_LOSSLESS=1`, sets `INTERPOLATION_METHOD=lsfg` in `bgmod.conf`, displays the "lsfg-vk" banner at 100% full brightness while dimming the None and MAKO images to approximately 35% brightness, and switches the middle UI to the streamlined lsfg-vk controls.

#### Scenario: User selects MAKO method
- **WHEN** user selects the "MAKO" method via its radio button or its rectangular banner image
- **THEN** system sets `GOVERLAY_LOSSLESS=1`, sets `INTERPOLATION_METHOD=mako` in `bgmod.conf`, displays the "MAKO" banner at 100% full brightness while dimming the None and lsfg-vk images to approximately 35% brightness, and displays the full MAKO configuration suite.
