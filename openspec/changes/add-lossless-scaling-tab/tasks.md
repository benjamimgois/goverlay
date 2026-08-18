# Tasks: Add Lossless Scaling Tab under Upscalers

## Implementation Steps

- [x] 1. **Tab Navigation & Form Structure Setup**:
  - [x] 1.1 Declare `losslessScalingTabSheet: TTabSheet` and helper references in `overlayunit.pas`.
  - [x] 1.2 In `Tgoverlayform.FormCreate`, instantiate `losslessScalingTabSheet` as a child of `goverlayPageControl`.
  - [x] 1.3 Update `optiscalerLabelClick` in `overlayunit.pas` to show top tabs (`ShowTabs := True`) with both `optiscalerTabSheet` and `losslessScalingTabSheet`.
  - [x] 1.4 Update all other tab transitions in `overlayunit.pas` (`mangohudLabelClick`, `vkbasaltLabelClick`, `tweaksLabelClick`, `gamesLabelClick`, `homeLabelClick`) to hide `losslessScalingTabSheet`.

- [x] 2. **Lossless Scaling UI Unit (`lossless_scaling_tab.pas`)**:
  - [x] 2.1 Create new unit `lossless_scaling_tab.pas` with class `TLosslessScalingTabHelper`.
  - [x] 2.2 Build **General & DLL Setup Card**:
    - Add `dllPathEdit`, `browseDllBtn`, `autoDetectDllBtn`, and `dllStatusLabel`.
    - Implement Steam library path auto-detection algorithm.
  - [x] 2.3 Build **Frame Generation Card**:
    - Add Multiplier selector (`2x`, `3x`, `4x`), Flow Scale slider / trackbar (25% - 100%), and Performance Mode toggle.
  - [x] 2.4 Build **Hardware & Pacing Card**:
    - Add Disable FP16 toggle, Pacing mode ComboBox, and GPU device ComboBox populated with real system GPU names.
  - [x] 2.5 Build **Environment Preview Card**:
    - Add live preview memo box and Copy Command button.
  - [x] 2.6 Implement responsive reflow logic (`ReflowLosslessScalingTab`) to dynamically adapt cards to window resize.

- [x] 3. **Settings Persistence & Variable Serialization**:
  - [x] 3.1 Implement `LoadLosslessConfig` to read from `~/.config/goverlay/lossless_scaling.ini` (or fallback to defaults).
  - [x] 3.2 Implement `SaveLosslessConfig` to persist changes upon control interaction.
  - [x] 3.3 Implement `GenerateLosslessEnvVars` to format and return the active `LSFGVK_*` environment variable string.

- [x] 4. **Per-Game Integration & Game Profiles**:
  - [x] 4.1 Update `games_tab.pas` / `bgmod` configuration writers to serialize `LSFGVK_*` environment variables when Lossless Scaling is enabled for a game.
  - [x] 4.2 Update game card launch option generator to include Lossless Scaling variables.

- [x] 5. **Build, Verify & Test**:
  - [x] 5.1 Compile with `lazbuild --build-mode=Release goverlay.lpi`.
  - [x] 5.2 Verify tab switching between OptiScaler and Lossless Scaling under Upscalers.
  - [x] 5.3 Verify Steam path auto-detection, real GPU enumeration, and live command preview updates.
  - [x] 5.4 Verify settings persistence across application restarts.
