# tab-ui-synchronization

## Purpose
Defines requirements for UI control state resetting, config file path assignment, and tab visual synchronization across GOverlay tabs.

## Requirements

### Requirement: Tweaks Control Reset on Missing Config File
GOverlay SHALL reset all Tweaks tab UI controls (general, graphics, performance checkboxes, antilag, RT, Proton Vkd3d LowLatency, and custom env lists) to unselected/empty states prior to checking `bgmod.conf` existence when loading Tweaks configuration.

#### Scenario: Loading Tweaks tab for a game profile with missing bgmod.conf
- **WHEN** the user switches to the Tweaks tab for a game profile that has no `bgmod.conf`
- **THEN** GOverlay SHALL clear all Tweaks checkboxes and custom env lists instead of preserving state from the previous profile.
