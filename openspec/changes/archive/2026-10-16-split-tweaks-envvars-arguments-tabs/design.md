# Design: Split Tweaks into EnvVars and Arguments Sub-tabs

## Context
See `proposal.md` for motivation.
Currently, GOverlay's sidebar navigation displays a single "Tweaks" tab. When selected, `goverlayPageControl.ShowTabs` is set to `False`, rendering `tweakstabsheet` containing `FTweaksPB: TPaintBox` with seven stacked sections: General, Graphics, Performance, Latency reduction, Experimental, Custom Variables, and Launch Arguments.
Other sidebar sections (MangoHud, OptiScaler, vkBasalt) utilize `goverlayPageControl.ShowTabs := True` with multiple `TTabSheet` child pages.

## Goals / Non-Goals

**Goals:**
- Enable sub-tab navigation for Tweaks with two tabs: `EnvVars` and `Arguments`.
- Isolate environment variable cards (categories 0..5) to the `EnvVars` paintbox.
- Render launch arguments on the `Arguments` sub-tab separated into two distinct cards: `Predefined Arguments` and `Custom Arguments`.
- Contextually route the floating action button (`+ Add`) based on whether `EnvVars` or `Arguments` is the active page.
- Maintain full backwards compatibility with existing `bgmod.conf` sections (`[Env]`, `[CustomVariables]`, `[Args]`, `[CustomArguments]`).

**Non-Goals:**
- Modifying `bgmod` wrapper binary argument execution logic (`execvpe`).
- Altering the appearance or behavior of non-Tweaks tabs (Home, MangoHud, OptiScaler, vkBasalt, etc.).

## Decisions

### 1. PageControl Sub-Tab Architecture
- **Decision**: Update `tweaksTabSheet.Caption := 'EnvVars'` and dynamically (or via LFM) add `launchArgsTabSheet: TTabSheet` with `Caption := 'Arguments'`.
- **Navigation Behavior**: In `overlayunit.pas` (`tweaksLabelClick`), set `goverlayPageControl.ShowTabs := True;`. When switching sidebar sections away from Tweaks, sub-tab visibility is handled by the respective section's handler (e.g., MangoHud shows its own tabs, Home hides tabs).
- **Alternative considered**: Implementing a custom tab bar widget inside `tweakstabsheet`. *Rejected*: Standard LCL `TPageControl` already handles theming, accessibility, tab styling, and keyboard navigation consistently across MangoHud, OptiScaler, and vkBasalt.

### 2. Rendering Separation in `tweaks_md3.pas`
- **Decision**: Keep rendering logic inside `tweaks_md3.pas`, adding support for a second `TPaintBox` (`FArgsPaintBox`) or parameterized target mode:
  - `RenderEnvVars(Canvas, Width, Height)`: Draws General, Graphics, Performance, Latency, Experimental, and Custom Variables cards.
  - `RenderLaunchArgs(Canvas, Width, Height)`: Draws the `Predefined Arguments` card (containing the curated flags `-novid`, `-vulkan`, `-dx11`, `-dx12`, `-nojoy`) and the `Custom Arguments` card (containing catalog banner, user-defined arguments, `[Global]` / `[Game]` chips, and delete buttons).
- **Event Dispatching**: Register mouse click, hover/move, and wheel scroll handlers for `FArgsPaintBox` parallel to `FTweaksPB`.
- **Alternative considered**: Creating a separate unit `launchargs_md3.pas`. *Rejected*: Both tabs share identical card drawing primitives, Material Design 3 palettes, badge chip geometry, toggle switch logic, and tooltip handling. Keeping them unified in `tweaks_md3.pas` prevents code duplication.

### 3. Contextual `+ Add` Action Routing
- **Decision**: In `overlayunit.pas` (`AddCustomVarBtnClick`), inspect `goverlayPageControl.ActivePage`:
  - If `ActivePage = launchArgsTabSheet`: display an input dialog titled "Add Launch Argument" with hint/placeholder `-arg or +arg`, and validate that the entry starts with `-`, `--`, or `+`.
  - Otherwise (`ActivePage = tweakstabsheet`): display an input dialog titled "Add Environment Variable" with hint/placeholder `KEY=VALUE`, and validate that the entry conforms to environment variable syntax (`KEY=VALUE`).
- **Alternative considered**: Always opening a dialog with a combo box or radio buttons to pick the type. *Rejected*: Knowing the active tab eliminates unnecessary friction; the user is already on the exact sub-tab where they want to add an item.

## Risks / Trade-offs

- **[Risk] Mouse hit testing offset across two paintboxes**: If hit test coordinates rely on shared global Y offsets, scrolling one tab could corrupt click targets on the other.
  - *Mitigation*: Maintain separate scroll positions (`FEnvVarsScrollY` and `FArgsScrollY`) and separate hit-box lists (`FEnvVarsHitBoxes` and `FArgsHitBoxes`) in `tweaks_md3.pas`.
- **[Risk] Tab switching tab order / focus loss**: Switching sidebar items and returning to Tweaks might leave the PageControl on an unexpected tab sheet.
  - *Mitigation*: Ensure `tweaksLabelClick` preserves the active Tweaks sub-tab or defaults predictably to `tweakstabsheet` (`EnvVars`).

## Migration Plan
No configuration migration required; existing `[Env]`, `[CustomVariables]`, `[Args]`, and `[CustomArguments]` sections in `bgmod.conf` remain identical.
