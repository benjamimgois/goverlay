## ADDED Requirements

### Requirement: Persist OptiScaler channel selection
The GOverlay OptiScaler tab SHALL save the user's channel selection (Stable or Bleeding‑edge) to the per‑game OptiScaler configuration and SHALL restore it on application startup or game switch, before falling back to the installed version tag heuristic.

#### Scenario: User selects Bleeding‑edge, restarts app
- **WHEN** the user selects "Bleeding‑edge" in the OptiScaler channel combobox, saves the configuration, and restarts the application
- **THEN** the combobox displays "Bleeding‑edge" (not "Stable‑channel").

#### Scenario: No saved preference (first run)
- **WHEN** no prior channel selection has been saved
- **THEN** the combobox falls back to the installed version tag (edge- prefix → Bleeding, otherwise Stable).
