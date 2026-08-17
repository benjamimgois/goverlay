## Context

See `proposal.md` for background. The floating action dock currently renders `▶ Preview`, `☰ Menu`, and `✦ Finish` with large geometry (`48px` total height), while custom environment variables on the EnvVars tab use a separate floating button (`FTweaksFABBtn`).

## Goals / Non-Goals

**Goals:**
- Integrate `+ Add` button directly into `TFloatingActionDock` for the EnvVars tab.
- Deprecate and remove the separate floating button in `tweaks_md3.pas`.
- Scale down dock and overlay dimensions across the board (~38px height, compact button widths).
- Maintain consistent visual theme and color hierarchy (cyan accent on Finish button, dark neutral on secondary buttons).

**Non-Goals:**
- Changing custom environment variable creation logic or dialog flow.
- Modifying other tab configurations or profile persistence.

## Decisions

### 1. Unified Multi-State Action Dock
- **Decision**: Add `FAddBtn: TSpeedButton` to `TFloatingActionDock` and update method signature to:
  ```pascal
  procedure UpdateForTab(AShowPreview, AShowMenu, AShowAdd: Boolean);
  ```
- **Rationale**: Keeps dock logic centralized in a single component. Tab switch handlers specify exactly which secondary buttons to display alongside `✦ Finish`.

### 2. Compact Sizing Scale
- Button Height: `30px`
- Inner Vertical Padding: `4px` (Total dock height = `38px`)
- Button Widths: `Finish = 84px`, `Preview = 88px`, `+ Add = 76px`, `Menu = 34px`
- Button Gap: `3px`, Inner Horizontal Padding: `6px`
- Window Margins: `Right = 16px`, `Bottom = 14px`
- Auto-save badge: `136 × 28px`

### 3. Removal of Standalone FAB
- **Decision**: Remove `FTweaksFABBtn` from `tweaks_md3.pas` and `overlayunit.pas`.
- **Wiring**: Wire `FFADock.OnAddClick` to `TweaksMD3FABClick` in `overlayunit.pas`.

## Risks / Trade-offs

- **[Risk]** Compact buttons might have reduced click targets.
  - *Mitigation*: 30px height and >=34px width are well within standard desktop clickable guidelines (standard buttons in GOverlay are 28-30px).
