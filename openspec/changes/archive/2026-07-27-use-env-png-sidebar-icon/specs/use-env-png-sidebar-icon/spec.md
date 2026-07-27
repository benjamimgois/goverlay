# Specification: Use `env.png` for EnvVars Sidebar Icon (`use-env-png-sidebar-icon`)

## Requirements

### Requirement 1: Updated EnvVars Icon Artwork
The EnvVars sidebar menu item SHALL render `envvars-active.png` (white `#FFFFFF`) when active and `envvars-inactive.png` (muted gray `#AAAAAA`) when inactive, generated from `assets/icons/env.png`.

#### Scenario: Displaying EnvVars icon
- **WHEN** the EnvVars sidebar menu item is displayed in active or inactive state
- **THEN** it SHALL display the 32x32 anti-aliased icon generated from `env.png`.
