# Design: Upstream Features Sync

## Context
See `proposal.md` for motivation. Goverlay coordinates external Vulkan and Wine/Proton tools via their respective configuration formats (INI for OptiScaler/FakeNvapi/HelixSR, key-value for MangoHud, TOML for MAKO, and INI/conf for vkSumi). Each tool's UI tab in Goverlay builds controls dynamically or on top of Lazarus forms with Qt5/Qt6 wrappers and MD3 styling.

## Goals / Non-Goals

**Goals:**
- Provide intuitive, responsive UI controls matching Goverlay's MD3 styling (`TToggleSwitch`, `TComboBox`, `TTrackBar`).
- Maintain exact key/value compatibility with upstream configuration parsers.
- Ensure bidirectional round-trip serialization (loading from file -> reflecting in UI -> saving to file).
- Support fallback and default values when configuration keys are omitted in older configuration files.

**Non-Goals:**
- Modifying upstream tool binaries or compiling custom forks.
- Overhauling unrelated tabs or legacy deprecated tools (e.g. ReplaySorcery).

## Decisions

### Decision 1: UI Controls and Layout Placement
- **OptiScaler**: Place `Fsr4Preset` combo box alongside the FSR4 upgrade controls. Place `FGNvngxReplacement` combo box inside the FrameGen options card.
- **MangoHud**: Connect existing `dx_api` toggle. Place `text_outline` toggle inside the Visual Metrics section.
- **HelixSR**: Integrate `Sharpener` mode, `Sharpness` slider, and `WaveSize` inside the HelixSR options card in `optiscaler_tab.pas`.
- **vkSumi**: Add `Compare Mode` toggle and `Daltonize` combo box into `vkbasalt_tab.pas` within the vkSumi color grading sub-tab.

### Decision 2: Constants Centralization in `configkeys.pas`
- Centralize all new configuration strings in `configkeys.pas` to prevent hardcoded string duplication across UI and serializer units:
  ```pascal
  OPTI_KEY_FSR4_PRESET    = 'Fsr4Preset=';
  OPTI_KEY_FG_NVNGX       = 'FGNvngxReplacement=';
  MANGO_FLAG_DX_API       = 'dx_api';
  MANGO_FLAG_TEXT_OUTLINE = 'text_outline';
  HELIX_KEY_SHARPENER     = 'Sharpener=';
  HELIX_KEY_SHARPNESS     = 'Sharpness=';
  HELIX_KEY_WAVESIZE      = 'WaveSize=';
  VKSUMI_KEY_COMPARE      = 'compare=';
  VKSUMI_KEY_DALTONIZE    = 'daltonize=';
  ```

### Decision 3: Backward-Compatible Loading and Saving
- When loading configurations:
  - If a key is missing from the user's existing config file, UI controls default to disabled or 'Auto' / 'Default'.
  - When saving, only write active or explicitly overridden values to keep configuration files concise.

## Risks / Trade-offs

- **[Risk] Upstream enum value variations between tool versions** → Mitigation: Use standard lowercase identifiers matching upstream sample configs (`immediate`, `mailbox`, `fifo`, etc.) and fall back to omitting the key if 'Default' is selected.
- **[Risk] UI clutter on smaller screen resolutions** → Mitigation: Use existing responsive reflow logic (`ReflowOptiScalerTabNew`, `ReflowVkSumiTab`) and compact `TToggleSwitch` cards to preserve clean layout hierarchy.
