# Design: Cleanup Orphaned Fields and Dead Stubs

## Architectural Decisions

### 1. Orphaned Fields and Controls
- `casTrackBar2: TTrackBar;` in `overlayunit.pas` has zero references outside its declaration. It will be removed from `Tgoverlayform`.
- `ToggleSpeedButton: TSpeedButton;` in `overlayunit.pas` is absent from `overlayunit.lfm`. Its declaration, the empty stub `ToggleSpeedButtonClick`, and the hint registered in `hintsunit.pas` (`SetHint('themeToggleSpeedButton', ...)`) will be purged.
- `FTweaksVarListBox: TListBox;` is a private field in `overlayunit.pas` that is never created. All references in `UpdateTweaksVarListBox` and `TweaksVarRemoveClick` are guarded by `if not Assigned(FTweaksVarListBox) then Exit;`. Both methods and the field will be removed.

### 2. Dead Procedures and Stubs
- `aboutBitBtnClick`: Empty procedure in `overlayunit.pas`, declared on `Tgoverlayform`. The `aboutBitBtn` control was previously replaced by the Settings menu and does not exist in `overlayunit.lfm`. Remove declaration and implementation.
- `TweaksMD3BuildItems` and `TweaksMD3ToggleItem`: Stubs with single comments left over from prototype iterations. The modern tweaks grid in `tweaks_md3.pas` handles its own items directly. Remove declaration and implementation.

### 3. Noise and Comment Cleanup
- Remove 77 occurrences of `// Exposed: procedure ...` comments in `overlayunit.pas`.
- Remove commented out lines in `FormCreate` (`topleftRadiobutton.Color := ...`).

### 4. Unused Units Cleanup
- `apputils.pas`: remove `configmanager` from interface uses.
- `overlay_utils.pas`: remove `constants`, `configmanager` from interface uses.
- `overlay_config.pas`: remove `Types`, `optiscaler_update` from interface uses.
- `tweaks_md3.pas`: remove `bgmod_resources`, `configkeys` from interface uses, and `qtwidgets` from implementation uses.
