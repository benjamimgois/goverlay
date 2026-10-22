# Design

## Context

The EnvVars tab (`tweaks_md3.pas`) organizes system tweaks and environment variables into Material Design 3 cards. Currently, `TWEAK_ROWS` defines 31 predefined environment options across 4 categories (`General`, `Graphics`, `Performance`, and `Latency reduction`), followed by user-defined custom environment variables (`TWEAK_CAT_CUSTOM = 4`) rendered in a "Custom Variables" card.

Launch arguments (`-novid`, `-vulkan`, `-dx11`, `-dx12`, `-nojoy`, etc.) represent command-line flags passed directly to the game binary in `argv`, rather than process environment variables exported via `envp`. The `bgmod` supervisor binary acts as the wrapper process executing the game via `execvpe(Args[0], @Args[0], @EnvArgs[0])`.

See `proposal.md` for user motivation and problem statement.

## Goals / Non-Goals

**Goals:**
- Add a dedicated "Launch Arguments" card rendered below the "Custom Variables" card in the EnvVars tab.
- Include built-in, curated toggles for standard Linux/Proton launch arguments (`-novid`, `-vulkan`, `-dx11`, `-dx12`, `-nojoy`).
- Support adding arbitrary custom launch arguments.
- Provide automatic classification in the `+ Add` button based on input prefix (`-`, `--`, `+` vs variable assignments).
- Persist active arguments in `[Args]` in `bgmod.conf`.
- Persist global custom arguments in `[CustomArguments]`, automatically inheriting them into game profiles with toggle switch OFF by default.
- Inject active arguments into `bgmod`'s argument array prior to game execution via `execvpe`.
- Preserve existing styling, 4px margins, responsiveness, and floating action dock integration.

**Non-Goals:**
- Editing Steam's internal VDF files directly.
- Modifying how existing environment variables are handled.

## Decisions

### 1. In-Memory Data Model in `FTweaksGrid`
- Introduce a new category identifier: `TWEAK_CAT_ARGS = 5;`.
- Add curated predefined argument entries (e.g. `PREDEFINED_ARG_ROWS`) or incorporate them into `TWEAK_ROWS` / dedicated array.
- Rows in `FTweaksGrid` use:
  - Column 0: Toggle state (`'1'` or `'0'`).
  - Column 1: Category caption (`'Launch Arguments'`).
  - Column 2: Argument string (e.g. `-novid`, `-vulkan`, `+fps_max 0`).
  - Column 3: Origin (`'Predefined'`, `'Global'`, or `'Local'`).
- *Alternative considered*: Storing arguments in a separate grid or string list.
  - *Rationale*: Reusing `FTweaksGrid` keeps grid geometry, sorting, and event delegation consistent without extra controls or duplicate painting logic.

### 2. Rendering Two Distinct Cards
- In `TTweaksMD3Helper.Paint`, render the "Custom Variables" card (category `TWEAK_CAT_CUSTOM`) followed by the "Launch Arguments" card (category `TWEAK_CAT_ARGS`).
- Both cards adhere to the exact same 4px outer margins, rounded rectangle backgrounds, item height (50px), toggle switches, and active item counters.
- *Alternative considered*: Merging arguments and variables into a single card with `[Env]` and `[Arg]` chips.
  - *Rationale*: As confirmed during exploration, separate cards provide cleaner visual demarcation between process environment variables and binary invocation arguments.

### 3. Automatic Input Routing in `+ Add`
- In `CustomEnvAddClick` and `FABClick`:
  - Inspect the trimmed string submitted by the user.
  - If it begins with `'-'`, `'--'`, or `'+'`:
    - Row is created with category `TWEAK_CAT_ARGS`.
  - Otherwise:
    - Row is created with category `TWEAK_CAT_CUSTOM`.
- *Alternative considered*: Prompting the user with a selection dialog ("Add Variable" vs "Add Argument").
  - *Rationale*: Automatic prefix detection completely eliminates prompt fatigue and feels instantaneous.

### 4. Configuration Storage in `bgmod.conf`
- **Active Arguments**: Stored in section `[Args]` as `argument=1`.
- **Global Catalog**: In Global mode, all custom arguments (enabled or disabled) are preserved in `[CustomArguments]` as `argument=value`.
- **Game Profile Mode**: Game profile saves write only active arguments to the game's `[Args]` section. The global `[CustomArguments]` section is never touched by game profile saves.
- *Alternative considered*: Appending arguments directly to the launch command string in the GUI.
  - *Rationale*: Saving in `bgmod.conf` allows the user to configure Steam once (`bgmod %command%`) and adjust arguments dynamically in GOverlay without ever re-editing Steam Launch Options.

### 5. Argument Injection in `bgmod`
- In `bgmod.lpr`:
  - Parse the `[Args]` section of `bgmod.conf`.
  - For each entry with value `'1'`:
    - Add to a launch arguments list.
  - When constructing `ArgsStrings`:
    - Insert the active arguments immediately following the game executable (and wrapper if applicable), preceding any trailing Steam arguments.
    - Example: `execvpe(game_exe, [game_exe, -novid, -vulkan, ...steam_args], envp)`.

## Risks / Trade-offs

- **[Risk] Arguments with spaces or values (e.g. `+fps_max 0` or `-width 1920`)**
  → *Mitigation*: In `bgmod.conf`, lines are read via `ReadSectionValues`. In `bgmod.lpr`, arguments are split into individual tokens if they contain spaces or preserved as distinct `argv` parameters, ensuring correct parameter parsing by the game engine.
- **[Risk] Conflicts between arguments (e.g. `-dx11` and `-dx12` simultaneously)**
  → *Mitigation*: The toggle switch UI allows users to easily turn one off when enabling the other. In `tweaks_md3.pas`, mutual exclusivity can also be gently handled if both are selected.
