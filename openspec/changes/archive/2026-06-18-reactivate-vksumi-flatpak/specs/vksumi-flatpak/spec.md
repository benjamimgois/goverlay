## ADDED Requirements

### Requirement: vkSumi Flatpak Detection
The system SHALL detect if the vkSumi Vulkan layer is installed in Flatpak mode. It SHALL search for `/usr/lib/extensions/vulkan/vkSumi/lib/x86_64-linux-gnu/libVkLayer_vksumi.so` or `/usr/lib/extensions/vulkan/vkSumi/lib/i386-linux-gnu/libVkLayer_vksumi.so`.

#### Scenario: vkSumi Flatpak is installed
- **WHEN** GOverlay runs in Flatpak mode and the vkSumi extension file exists at `/usr/lib/extensions/vulkan/vkSumi/lib/x86_64-linux-gnu/libVkLayer_vksumi.so`
- **THEN** GOverlay SHALL NOT add "vkSumi runtime" to the missing dependencies list

#### Scenario: vkSumi Flatpak is not installed
- **WHEN** GOverlay runs in Flatpak mode and no vkSumi extension files exist
- **THEN** GOverlay SHALL add "vkSumi runtime" to the missing dependencies list

### Requirement: vkSumi Flatpak Tab Sheet Visibility
The system SHALL show the vkSumi configuration tab sheet under the vkBasalt navigation item even when running in Flatpak mode.

#### Scenario: Accessing vkBasalt/vkSumi settings in Flatpak
- **WHEN** GOverlay runs in Flatpak mode and the user clicks on the vkBasalt navigation item
- **THEN** GOverlay SHALL make both `vkbasaltTabSheet` and `vksumiTabSheet` visible

### Requirement: vkSumi Flatpak Home Tab Status
The system SHALL show the correct status and version indication for vkSumi on the Home tab when running in Flatpak mode.

#### Scenario: Home tab shows vkSumi status
- **WHEN** GOverlay is in Flatpak mode and vkSumi is detected
- **THEN** the Home tab status dot for vkSumi SHALL be green, and the version label SHALL display "installed"
