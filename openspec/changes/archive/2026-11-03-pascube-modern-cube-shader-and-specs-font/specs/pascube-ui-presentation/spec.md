# Delta Specification: pascube-ui-presentation

## MODIFIED Requirements

### Requirement: System Specifications Summary Pill
The benchmark interface SHALL render a system specifications summary badge displaying the active CPU model, GPU model, Vulkan API version, and resolution preset across both the idle menu and the results overlay with high-legibility typography.

#### Scenario: Display on idle menu
- **WHEN** PasCube enters the idle menu state (`bpIdleMenu`)
- **THEN** the interface renders a centered pill card with font scale `1.30` and height `52.0px`, rendering the CPU, GPU, Vulkan version, and resolution preset (1080p) in high-contrast text.

#### Scenario: Display on results overlay
- **WHEN** PasCube renders the final results screen (`bpResults`)
- **THEN** the specifications summary badge is rendered at the top of the interface providing hardware context for the recorded scores.
