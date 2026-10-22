## MODIFIED Requirements

### Requirement: ReShade Post Processing Tab Layout
The system SHALL display the ReShade tab as the first, leftmost tab under the Post Processing sidebar navigation item, positioned before vkBasalt and vkSumi. The ReShade tab interface SHALL be organized into three cards aligned with the OptiScaler tab layout:
1. **Config** (top card): contains ReShade toggle, interactive key capture button ("Toggle") with modal key capture, and default proxy DLL selection with OptiScaler co-existence tooltip hint.
2. **Shaders** (middle card): contains the "Open Shaders Directory" action button in the card header and the collection of shader packs.
3. **Software status** (bottom card): contains library presence dot indicator (green when installed, gray when absent), library name ("ReShade"), version ("6.4 (Add-on Edition)"), and the update/check action button.

#### Scenario: User navigates to Post processing
- **WHEN** the user clicks the "Post processing" item in the sidebar navigation rail
- **THEN** the system displays the Post Processing tab sheets with ReShade active by default in the leftmost position (`[ ReShade ] [ vkBasalt ] [ vkSumi ]`) structured into "Config", "Shaders", and "Software status" cards.

### Requirement: Shader Package Management
The system SHALL provide an interface inside the "Shaders" card to install, update, and remove shader collections (Standard Effects, SweetFX, qUINT, AstrayFX, Prod80) and provide a button in the header of the "Shaders" card to open the local shaders directory in the system file manager.

#### Scenario: Installing optional shader pack
- **WHEN** the user clicks "Install" for an optional shader collection (such as SweetFX or qUINT)
- **THEN** the system downloads the archive, extracts its shaders and textures into the centralized ReShade shaders directory, and updates the collection status to installed.

#### Scenario: Opening shaders directory
- **WHEN** the user clicks the "Open Shaders Directory" button in the "Shaders" card
- **THEN** the system opens the file manager at `~/.local/share/goverlay/reshade/shaders/`.
