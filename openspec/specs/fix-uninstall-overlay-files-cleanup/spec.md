# Capability: fix-uninstall-overlay-files-cleanup

Explicitly removes `bgmod.log`, `goverlay.vars`, `MangoHud.conf`, `vkBasalt.conf`, and `vkSumi.conf` from target game directories during uninstallation.

## Requirements

### Requirement: Removal of log and overlay config files during uninstall
GOverlay SHALL explicitly delete `bgmod.log`, `goverlay.vars`, `MangoHud.conf`, `vkBasalt.conf`, and `vkSumi.conf` from target game directories during the "Uninstall changes" process.

#### Scenario: Executing Uninstall changes on a game directory
- **WHEN** user clicks "Uninstall changes" on a game card
- **THEN** GOverlay deletes `bgmod.log`, `goverlay.vars`, `MangoHud.conf`, `vkBasalt.conf`, and `vkSumi.conf` alongside other wrapper files in all matched game target directories.
