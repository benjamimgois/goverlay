# Spec Delta

## MODIFIED Requirements

### Requirement: Card-Based Grouped Layout for EnvVars
The EnvVars tab SHALL organize environment variables and tweaks into distinct themed cards (`General`, `Graphics`, `Performance`, `Latency reduction`, `Experimental`, and `Custom Variables`) using standard GOverlay card background and border styling. All category cards SHALL span across nearly the entire horizontal client width with a 4px margin on both sides (`Left = 4`, `Right = ClientWidth - 4`), matching the standard geometry of Lossless Scaling.

#### Scenario: Viewing EnvVars tab categories
- **WHEN** the user navigates to the EnvVars tab
- **THEN** the settings are displayed within structured dark cards with clear category headers, including `General`, `Graphics`, `Performance`, `Latency reduction`, and `Experimental`, spanning from `Left = 4` to `Right = ClientWidth - 4` with uniform 4px side margins.

#### Scenario: Resizing window with EnvVars tab active
- **WHEN** the user resizes the application window
- **THEN** the EnvVars category cards and their two-column item layouts dynamically adapt to fill the available width while maintaining the 4px side margins.

## ADDED Requirements

### Requirement: Dedicated Experimental Tweaks Card with Warning Banner
The EnvVars tab SHALL render a dedicated "Experimental" category card containing cutting-edge compatibility tweaks. The card header SHALL render in prominent amber/gold styling with a warning icon (`⚠ Experimental`), and a prominent warning banner SHALL render inside the card above its toggles, stating that experimental options may cause instability or visual artifacts and should only be enabled when required by specific titles.

#### Scenario: Viewing the Experimental card
- **WHEN** the user scrolls to the Experimental card in the Tweaks tab
- **THEN** the card renders with an amber header, active count badge, and a top-anchored amber warning banner explaining that experimental tweaks are intended for bleeding-edge game compatibility and may cause instability.

#### Scenario: Hovering over an experimental tweak toggle
- **WHEN** the user hovers over any toggle row inside the Experimental card
- **THEN** the tooltip displays the option's specific function alongside an explicit experimental warning note.

### Requirement: Bleeding-Edge Compatibility Variables in Experimental Card
The Experimental card SHALL provide toggles for cutting-edge DirectX 12 and Ray Tracing Proton/Wine compatibility options, specifically:
- **Descriptor Heap**: bundles `VKD3D_CONFIG=descriptor_heap` and `PROTON_VKD3D_HEAP=1` under a single toggle switch to fix crashes and freezes in titles requiring alternative descriptor heap paths (such as *Control Resonant*).
- **Ray Reconstruction**: sets `NGX_DLSS_RR_OVERRIDE=on` to force DLSS Ray Reconstruction on supported Nvidia titles, rendered with a green `[NVIDIA]` badge chip.
- **RT Acceleration Structures Multiplier**: sets `VKD3D_RTAS_SIZE_MULT=8` to expand RT acceleration structure buffer allocations.
- **Zink Renderer**: sets `MESA_LOADER_DRIVER_OVERRIDE=zink`, migrated from the Graphics card with a `[MESA]` badge chip.
- **RE Engine RT Workaround**: sets `#winedetectionenable=false`, migrated from the Graphics card.

All five options SHALL be recognized by the predefined environment variable classifier so that none of them leak into the Custom Variables list.

#### Scenario: Toggling Descriptor Heap support
- **WHEN** the user enables the Descriptor Heap toggle in the Experimental card and saves
- **THEN** both `VKD3D_CONFIG=descriptor_heap` and `PROTON_VKD3D_HEAP=1` are written to the `[Env]` section of `bgmod.conf`.

#### Scenario: Toggling Ray Reconstruction override
- **WHEN** the user enables the Ray Reconstruction toggle and saves
- **THEN** `NGX_DLSS_RR_OVERRIDE=on` is written to `[Env]` in `bgmod.conf` and the item displays a green `[NVIDIA]` badge chip.

#### Scenario: Toggling RTAS size multiplier
- **WHEN** the user enables the RTAS multiplier toggle and saves
- **THEN** `VKD3D_RTAS_SIZE_MULT=8` is written to `[Env]` in `bgmod.conf`.

#### Scenario: Loading existing experimental configuration
- **WHEN** `bgmod.conf` contains any of the experimental variables
- **THEN** the corresponding toggle switches in the Experimental card are restored to ON without generating duplicate entries in the Custom Variables card.
