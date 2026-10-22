# Spec Delta

## MODIFIED Requirements

### Requirement: Active modules checklist presentation
The splash window SHALL render the Goverlay logo, an informative title displaying the launched game profile name without corruption from environment variables, and a dynamic checklist detailing only the modules that are actively enabled for the launched game.

#### Scenario: Displaying only enabled modules
- **WHEN** the splash window renders
- **THEN** only modules configured as active (e.g. MangoHud, OptiScaler, Lossless Scaling, vkBasalt, ReShade, vkSumi, Tweaks/EnvVars) are displayed with a green checkmark indicator, omitting inactive modules.

#### Scenario: Displaying ReShade post-processing
- **WHEN** Post-Processing is enabled with Method set to ReShade (`GOVERLAY_RESHADE=1`)
- **THEN** the checklist includes "ReShade" with a green checkmark indicator.

#### Scenario: Displaying contextual details for active modules
- **WHEN** a module has specific mode or upscaler information (e.g. OptiScaler with target upscaler or Lossless Scaling with interpolation method)
- **THEN** the module item displays its active method or type alongside the name.

#### Scenario: Accurate game profile title display
- **WHEN** a game is launched from a per-game configuration profile
- **THEN** the splash window displays the exact game profile name without corruption from internal environment variables or configuration files.
