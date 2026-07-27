# tab-ui-synchronization

## Purpose
Defines requirements for UI control state resetting, config file path assignment, and tab visual synchronization across GOverlay tabs.

## ADDED Requirements

### Requirement: Full Tool Config Path Synchronization on Game Card Selection
GOverlay SHALL update `MANGOHUDCFGFILE`, `VKBASALTCFGFILE`, `VKSUMICFGFILE`, and `FOptiscalerUpdate.FGModPath` to point to the active game's configuration directory immediately when a game card is selected.

#### Scenario: Selecting a game card on the Games tab
- **WHEN** the user clicks on a game card to activate game profile configuration
- **THEN** `VKBASALTCFGFILE` and `VKSUMICFGFILE` SHALL immediately be set to point to `vkBasalt.conf` and `vkSumi.conf` in the selected game's config directory without requiring a manual tab click.
