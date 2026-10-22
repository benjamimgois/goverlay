# Design: Block Conflicting Proxy DLLs Between ReShade and OptiScaler

## Context
See `proposal.md` for background and motivation.
Currently, `TReshadeTabHelper.FProxyComboBox` in `reshade_tab.pas` allows selecting from 5 DLL options (`dxgi.dll`, `d3d11.dll`, `d3d12.dll`, `d3d9.dll`, `opengl32.dll`), and `Tgoverlayform.filenameComboBox` in `overlayunit.pas` provides proxy DLL options for OptiScaler (`dxgi.dll`, `version.dll`, `dbghelp.dll`, `d3d12.dll`, etc.). Neither component verifies if the chosen DLL is concurrently used by the other active module.

## Goals / Non-Goals

**Goals:**
- Provide bidirectional collision detection between ReShade and OptiScaler proxy DLL comboboxes.
- Block conflicting selections by reverting combobox `ItemIndex` and displaying an informative warning toast in English.
- Implement priority resolution for `dxgi.dll`: offer a one-click confirmation dialog (`MessageDlg`) when activating ReShade or choosing `dxgi.dll` in ReShade to switch OptiScaler to `version.dll`.
- Ensure clean decoupling and persistence so config files remain consistent and auto-save timers are triggered appropriately.

**Non-Goals:**
- Dynamically removing or hiding items from dropdown menus (which disorients users and breaks fixed-index mappings).
- Handling third-party external injectors installed outside GOverlay (already handled by `bgmod`).

## Decisions

### Decision 1: Blocking selection with combobox reversion and Toast over hiding items
- *Rationale*: Hiding items dynamically makes the dropdown inconsistent and confusing across tab visits. Keeping all items visible but rejecting collisions with an explicit toast explains clearly to the user why a selection cannot be made.
- *Alternatives considered*: Disabling or removing colliding items from the dropdown list. Discarded because item indexes in LFM and config loading rely on static item ordering.

### Decision 2: Prioritizing dxgi.dll for ReShade with an interactive confirmation dialog
- *Rationale*: ReShade relies heavily on `dxgi.dll` to cover both DirectX 11 and 12 without user intervention. OptiScaler works equally well on `version.dll`. When a conflict occurs on `dxgi.dll` in ReShade, offering an interactive confirmation dialog (`MessageDlg(..., mtConfirmation, [mbYes, mbNo], 0)`) lets the user resolve the conflict in a single click without manually switching tabs.
- *Alternatives considered*: Silently forcing ReShade to `d3d11.dll`. Discarded because games running on DirectX 12 would fail to load ReShade unless the user noticed and changed it manually.

### Decision 3: Defaulting OptiScaler to version.dll when ReShade is already active on dxgi.dll
- *Rationale*: In `optiscalerRadioButtonClick`, GOverlay previously hardcoded `filenameComboBox.ItemIndex := IndexOf('dxgi.dll')`. If ReShade is already active on `dxgi.dll`, defaulting OptiScaler to `version.dll` prevents creating an immediate collision.

## Risks / Trade-offs

- **[Risk] Headless/automated test execution blocked by MessageDlg**  
  *Mitigation*: Ensure the confirmation dialog is invoked during user-driven UI events and can be bypassed or programmatically asserted in test suites without hanging test runs (or guarded when running in test harnesses if needed).
- **[Risk] State desync during configuration file loading**  
  *Mitigation*: Collision checks and prompt dialogs must be strictly skipped when `FLoading` or `FLoadingConfig` is true.

## Migration Plan
No schema or filesystem migrations needed; this is a pure UI validation and workflow enhancement.
