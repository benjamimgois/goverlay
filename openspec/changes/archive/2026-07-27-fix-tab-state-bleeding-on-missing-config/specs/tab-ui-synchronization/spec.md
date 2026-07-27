# tab-ui-synchronization

## Purpose
Defines requirements for UI control state resetting when loading vkBasalt and vkSumi configurations.

## ADDED Requirements

### Requirement: vkBasalt and vkSumi Control Reset on Missing Config File
GOverlay SHALL reset vkBasalt active effect lists, trackbars, and MD3 labels, as well as vkSumi controls, prior to checking configuration file existence when loading configs.

#### Scenario: Loading vkBasalt tab for a profile with missing vkBasalt.conf
- **WHEN** the user switches to the vkBasalt tab for a profile that has no `vkBasalt.conf`
- **THEN** GOverlay SHALL clear `acteffectsListBox` and reset all trackbars and MD3 value labels to zero instead of preserving state from the previous profile.
