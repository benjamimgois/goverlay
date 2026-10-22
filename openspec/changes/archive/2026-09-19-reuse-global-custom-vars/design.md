# Design

## Context

In GOverlay, environment variable tweaks are managed in the Tweaks (EnvVars) tab and backed by `bgmod.conf`. The runner script/binary (`bgmod`) reads the `[Env]` section of `bgmod.conf` at launch time to export variables to the target game.

Currently:
- Custom environment variables are stored only in `[Env]`.
- Variables toggled OFF (`0`) are excluded from `[Env]` when saving, meaning inactive custom variables are lost upon reload.
- Game profiles only read their own `bgmod.conf`. When a user navigates to a game profile, the custom variables list is empty unless manually recreated for that specific game.

See `proposal.md` for motivation and user problem statement.

## Goals / Non-Goals

**Goals:**
- Persist custom environment variables in Global mode across enabled (`1`) and disabled (`0`) states.
- Automatically expose all Global custom variables in per-game profiles with their toggle initially OFF (unless already enabled for that game).
- Allow one-click activation/deactivation of global custom variables within any game profile.
- Visually indicate global vs local origin with an MD3-styled `[Global]` badge chip.
- Prevent accidental deletion of global catalog entries from within game profiles by omitting the delete (`×`) action for global entries in game context.

**Non-Goals:**
- Synchronizing toggle state changes across games (each game profile maintains independent toggle states).
- In-place editing of variable expressions (the existing add/delete workflow remains).
- Altering the `bgmod` runner execution binary or modifying how it parses `[Env]`.

## Decisions

### Decision 1: Persistent INI storage via `[CustomVariables]` section
To preserve custom variables even when toggled OFF, `bgmod.conf` in Global mode will store all defined custom variable entries in a dedicated section:
```ini
[CustomVariables]
DXVK_ASYNC=1=1
MESA_VK_WSI_PRESENT_MODE=mailbox=0
```
or keyed by variable expression:
```ini
[CustomVariables]
DXVK_ASYNC=1
MESA_VK_WSI_PRESENT_MODE=mailbox
```
Active variables are simultaneously written to `[Env]` for consumption by `bgmod`. When a variable is toggled OFF in Global mode, it is removed from `[Env]` but retained in `[CustomVariables]`.

*Rationale*: The `bgmod` compiled executable only inspects `Ini.ReadSectionValues('Env', EnvList)` and ignores unknown sections. Placing catalog metadata in `[CustomVariables]` is 100% transparent to the runner and backwards compatible.

### Decision 2: In-memory tagging using `FTweaksGrid` column 3
`FTweaksGrid` currently stores:
- `Col 0`: Toggle state (`'1'` or `'0'`)
- `Col 1`: Category (`'Custom'`)
- `Col 2`: Variable text (`KEY=VAL`)
- `Col 3`: Description (empty for custom rows)

We will use `Col 3` for custom rows to store the variable's origin: `'Global'` or `'Local'`.

*Rationale*: Avoids introducing additional parallel data structures or modifying grid geometry. `Col 3` is already allocated and unused for custom rows.

### Decision 3: Profile Load & Save Lifecycle
- **Loading Global mode (`FActiveGameName = ''`)**:
  1. Read global `bgmod.conf` section `[CustomVariables]`. If missing, fall back to any custom lines in `[Env]`.
  2. For each variable, determine toggle state based on presence in global `[Env]`.
  3. Mark all rows as `'Global'`.
- **Loading Game Profile mode (`FActiveGameName <> ''`)**:
  1. Load global custom variables from `GetGameConfigDir('') + 'bgmod.conf'`.
  2. Load game's active custom variables from `GetGameConfigDir(FActiveGameName) + 'bgmod.conf'` `[Env]`.
  3. For each global variable: if present in game's `[Env]`, toggle is `'1'`, otherwise `'0'`. Tag as `'Global'`.
  4. For any variable in the game's `[Env]` not present in the global catalog: add to grid with toggle `'1'`. Tag as `'Local'`.
- **Saving Game Profile mode**:
  1. Write only rows with toggle `'1'` to the game's `[Env]`.
  2. Do not modify the global catalog when saving a game profile.
- **Saving Global mode**:
  1. Write all rows with toggle `'1'` to `[Env]`.
  2. Write all custom rows (both `'1'` and `'0'`) to `[CustomVariables]`.

### Decision 4: UI Painting & Deletion Protection
In `TTweaksMD3Helper.Paint`:
- For rows tagged `'Global'` in a game profile:
  - Render an MD3 badge `[Global]` using `DrawBadge` (slate/indigo tint).
  - Do not render the red delete glyph (`×`). Align the variable text cleanly without delete offset.
- For rows tagged `'Local'` (or in Global mode):
  - Render the red delete glyph (`×`).
- In `TTweaksMD3Helper.MouseDown`:
  - When in a game profile and clicking a `'Global'` row, ignore clicks on the delete zone (left 28px) so only the toggle switch responds.

## Risks / Trade-offs

- **[Risk] Accidental deletion of global variables from a game profile**
  → *Mitigation*: The delete button (`×`) is completely hidden and disabled for global variables when viewing a game profile. Users can only toggle them on or off in game profiles. Deletion from the catalog must be done in Global mode.
- **[Risk] Clutter if a user defines many global custom variables**
  → *Mitigation*: The Tweaks tab already utilizes responsive 2-column layout and scrollable cards with bottom padding.
- **[Risk] Performance on switching profiles**
  → *Mitigation*: Reading the small global `bgmod.conf` INI file takes < 1ms and is done in-memory without noticeable overhead.
