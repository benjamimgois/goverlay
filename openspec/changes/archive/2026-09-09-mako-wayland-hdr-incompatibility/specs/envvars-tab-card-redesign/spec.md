## ADDED Requirements

### Requirement: Disabled State Styling and Interaction Guard for Conflicting Toggles
The EnvVars tab SHALL visually represent disabled tweak toggles with dimmed/muted styling, block mouse interaction, and display explanatory tooltip feedback when hovered.

#### Scenario: Rendering disabled toggles
- **WHEN** a tweak toggle (such as "Enable Wayland" or "Enable HDR") is disabled due to MAKO being active
- **THEN** the toggle track and thumb are drawn in a dimmed gray style and item text is dimmed to clearly convey the disabled state.

#### Scenario: User attempts to click a disabled toggle
- **WHEN** user clicks on a disabled toggle item in the EnvVars tab
- **THEN** the click is ignored, the toggle state does not change, and the underlying configuration remains unchanged.

#### Scenario: User hovers over a disabled toggle
- **WHEN** user hovers the mouse cursor over a disabled toggle row
- **THEN** the tooltip or status bar displays an explanatory message indicating that the option is disabled due to MAKO incompatibility.
