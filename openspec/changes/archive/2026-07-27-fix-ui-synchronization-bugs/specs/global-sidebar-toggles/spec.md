# global-sidebar-toggles

## Purpose
Implements ON/OFF toggles in the navigation sidebar and ensures configuration file paths are correctly assigned for global and game-specific profiles.

## ADDED Requirements

### Requirement: Explicit Target Config Path Assignment on Sidebar Tab Navigation
GOverlay SHALL explicitly set `MANGOHUDCFGFILE`, `VKBASALTCFGFILE`, and `VKSUMICFGFILE` to global profile directory paths when navigating to sidebar tabs in global mode (`FActiveGameName = ''`).

#### Scenario: Navigating to MangoHud or vkBasalt tab in global mode
- **WHEN** `FActiveGameName` is empty and the user clicks on the MangoHud or vkBasalt sidebar tab
- **THEN** GOverlay SHALL assign `MANGOHUDCFGFILE`, `VKBASALTCFGFILE`, and `VKSUMICFGFILE` to their respective global config paths before reloading tab settings.
