# tab-ui-synchronization

## Purpose
Defines requirements for UI control state resetting, config file path assignment, and tab visual synchronization across GOverlay tabs.

## Requirements

### Requirement: Tweaks Control Reset on Missing Config File
GOverlay SHALL reset all Tweaks tab UI controls (general, graphics, performance checkboxes, antilag, RT, Proton Vkd3d LowLatency, and custom env lists) to unselected/empty states prior to checking `bgmod.conf` existence when loading Tweaks configuration.

#### Scenario: Loading Tweaks tab for a game profile with missing bgmod.conf
- **WHEN** the user switches to the Tweaks tab for a game profile that has no `bgmod.conf`
- **THEN** GOverlay SHALL clear all Tweaks checkboxes and custom env lists instead of preserving state from the previous profile.

### Requirement: vkBasalt and vkSumi Control Reset on Missing Config File
GOverlay SHALL reset vkBasalt active effect lists, trackbars, and MD3 labels, as well as vkSumi controls, prior to checking configuration file existence when loading configs.

#### Scenario: Loading vkBasalt tab for a profile with missing vkBasalt.conf
- **WHEN** the user switches to the vkBasalt tab for a profile that has no `vkBasalt.conf`
- **THEN** GOverlay SHALL clear `acteffectsListBox` and reset all trackbars and MD3 value labels to zero instead of preserving state from the previous profile.

### Requirement: Full Tool Config Path Synchronization on Game Card Selection
GOverlay SHALL update `MANGOHUDCFGFILE`, `VKBASALTCFGFILE`, `VKSUMICFGFILE`, and `FOptiscalerUpdate.FGModPath` to point to the active game's configuration directory immediately when a game card is selected.

#### Scenario: Selecting a game card on the Games tab
- **WHEN** the user clicks on a game card to activate game profile configuration
- **THEN** `VKBASALTCFGFILE` and `VKSUMICFGFILE` SHALL immediately be set to point to `vkBasalt.conf` and `vkSumi.conf` in the selected game's config directory without requiring a manual tab click.
