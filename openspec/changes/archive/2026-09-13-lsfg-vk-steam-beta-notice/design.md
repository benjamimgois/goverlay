## Context

In `lossless_scaling_tab.pas`, GOverlay allows selecting between frame generation interpolation engines (`None`, `lsfg-vk`, `MAKO`). Upstream `lsfg-vk 2.0` requires `lsfg-vk.dll`, which is delivered exclusively via Steam's "lsfg-vk" beta branch for the Lossless Scaling Steam app.

When users select `lsfg-vk`, `CheckSteamBetaDllHealth` detects whether `Lossless.dll` is present while `lsfg-vk.dll` is absent. Currently, this condition only illuminates an inline alert card at the top of the tab and sets an item in `lsfg_migration_dialog.pas`. However, many users miss these subtle cues and report that `lsfg-vk` does not function.

## Goals / Non-Goals

**Goals:**
- Provide immediate, high-visibility guidance the moment a user selects `lsfg-vk` when `lsfg-vk.dll` is missing from the Steam installation.
- Display a clear screenshot illustrating the Steam Properties → Betas window with the `lsfg-vk` branch highlighted.
- Offer actionable controls: "Open Steam Folder", "Migration Assistant", "Close", and a persistent "Do not show this again" checkbox.
- Update Step 1 in `lsfg_migration_dialog.pas` to include the same visual reference image.

**Non-Goals:**
- Programmatically altering Steam's internal beta branch (Steam does not provide an external API or CLI to switch beta branches of games without user intervention).
- Emulating the entire Steam client window using custom synthetic Lazarus controls when an authentic screenshot is cleaner, more faithful, and less brittle.

## Decisions

### Decision 1: Authentic Screenshot Image vs Simulated Steam UI
- **Chosen:** Ship an optimized screenshot asset (`assets/images/steam_lsfg_beta.png`) loaded into a `TImage` with `Proportional := True` and antialiasing enabled.
- **Rationale:** Simulating Steam's UI via Delphi/Lazarus shapes and labels would require significant custom widget code, would quickly look synthetic or outdated when Steam updates its client theme, and adds maintenance complexity. A clean screenshot is immediately recognized by users, matching their exact Steam desktop experience.
- **Alternatives Considered:** Constructing custom dark panels and fake radio buttons to imitate the Steam client. Rejected due to excessive code complexity, scaling artifacts across different desktop DPIs, and visual dissonance.

### Decision 2: Trigger Conditions for the Modal Notice
- **Chosen:** Trigger the notice dialog exclusively when:
  1. The user explicitly clicks the `lsfg-vk` method (`MethodLsfgClick`).
  2. `Tgoverlayform(FForm).FLoadingConfig` is `False` (never during background startup or config loading).
  3. `CheckSteamBetaDllHealth` returns `True` (meaning Steam is detected, but `lsfg-vk.dll` is missing).
  4. The persistent user preference `HideSteamBetaNotice` is not set to `1`.
- **Rationale:** Ensures zero annoyance for users who already have the branch installed, and never interrupts the user on application launch.

### Decision 3: Preference Persistence
- **Chosen:** Save `HideSteamBetaNotice=0` or `1` in `goverlay.ini` (under `[LosslessScaling]`).
- **Rationale:** Aligns with GOverlay's existing configuration patterns and respects user choice.

### Decision 4: Architecture and UI Placement
- **Chosen:** Implement `TLSFGVkSteamBetaNoticeDialog` in `lsfg_steam_beta_dialog.pas`.
- **UI Structure:**
  - Header with title and brief explanation.
  - Centered preview panel holding the Steam screenshot (`assets/images/steam_lsfg_beta.png`).
  - Step-by-step guidance list (1. Open Steam Properties, 2. Betas, 3. Select `lsfg-vk`, 4. Wait for download).
  - Bottom action bar:
    - CheckBox: "Do not show this notice again"
    - Button: "Open Steam Folder"
    - Button: "Migration Assistant"
    - Button: "Got it" / "Close"

## Risks / Trade-offs

- **[Risk] Missing asset path in Flatpak or packaged environments** →
  *Mitigation:* Use `Tgoverlayform(FForm).GetAppBaseDir + 'assets/images/steam_lsfg_beta.png'` with fallback to relative paths, and ensure `Makefile` and packaging scripts include `assets/images/`.
- **[Risk] Window size constraints on small displays (e.g. 720p / Steam Deck in Desktop mode)** →
  *Mitigation:* Size dialog responsively (e.g., width 640px, height 560px), keep image proportional within a fixed aspect container, and enable scrolling if necessary.
