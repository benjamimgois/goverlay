## ADDED Requirements

### Requirement: vkSumi Flathub Sandbox Exception
The Flatpak packaging configuration SHALL document and request the required permission exception in the official Flathub linter repository (`flathub-infra/flatpak-builder-lint`) to authorize read-write access to the `xdg-config/vkSumi` directory.

#### Scenario: Flathub build pipeline validation
- **WHEN** the Flathub build pipeline runs validation on the GOverlay Flatpak manifest
- **THEN** the linter error `finish-args-unnecessary-xdg-config-vkSumi-rw-access` SHALL be successfully bypassed by matching the registered exception entry in `exceptions.json`.
