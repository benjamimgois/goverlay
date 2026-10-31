# Proposal: Cleanup Orphaned Fields and Dead Stubs

## Why
After removing legacy containers and groupboxes across Goverlay, an analysis of compiler diagnostics and symbol references revealed residual dead code:
1. Orphaned form and private fields (`casTrackBar2`, `ToggleSpeedButton`, `FTweaksVarListBox`) that have no visual representation in LFM and are never instantiated or used.
2. Dead procedures and empty stubs (`aboutBitBtnClick`, `ToggleSpeedButtonClick`, `TweaksMD3BuildItems`, `TweaksMD3ToggleItem`, `UpdateTweaksVarListBox`, `TweaksVarRemoveClick`).
3. Outdated comments and noisy `// Exposed:` markers left behind after modular helper refactoring.
4. Unused imported units in `uses` clauses across several modules producing compiler hints (`apputils.pas`, `overlay_utils.pas`, `overlay_config.pas`, `tweaks_md3.pas`).

Purging these improves code hygiene, speeds up builds, and eliminates dead weight without changing runtime behavior.

## What
- Remove `casTrackBar2` and `ToggleSpeedButton` from `overlayunit.pas` and `hintsunit.pas`.
- Remove `FTweaksVarListBox`, `UpdateTweaksVarListBox`, and `TweaksVarRemoveClick` from `overlayunit.pas`.
- Remove empty stubs `aboutBitBtnClick`, `ToggleSpeedButtonClick`, `TweaksMD3BuildItems`, and `TweaksMD3ToggleItem`.
- Clean up noisy `// Exposed: procedure ...` comment blocks and obsolete commented-out lines in `overlayunit.pas`.
- Remove unused units from `uses` clauses in `apputils.pas`, `overlay_utils.pas`, `overlay_config.pas`, and `tweaks_md3.pas`.
- Validate with `make test-logic` and `make test-gui`.
