# Design

## Context

See `proposal.md` for motivation and background.

In the current codebase:
- `ResolveGameDirectory` in `bgmod.lpr` (L2423-L2428) and `bgmod-uninstaller.lpr` (L336-L341) uses `Pos(CleanKey, Arg)` and `Pos(TargetSub, Arg)` which are case-sensitive. When runners like Heroic invoke executables in lowercase (e.g. `redprelauncher.exe`), substitution fails.
- `bgmod.lpr` (L3935, L3975) joins entries in `WINEDLLOVERRIDES` with `,` instead of `;`. Wine specification requires `;` between distinct DLL override declarations; commas are reserved for load order modes (e.g. `n,b`).
- `Tgoverlayform.IsOptiScalerActive` in `overlayunit.pas` (L7584-L7587) only checks `not noneUpscalerRadioButton.Checked`. In new profiles or profiles where Upscalers are toggled off in the sidebar, this returns `True`, triggering `PromptDxgiResolution` in `reshade_tab.pas` which erroneously switches and turns on `GOVERLAY_OPTISCALER=1`.
- `bgmod.lpr` (L4526, L4540) logs every launch argument to `/tmp/bgmod.log` and the central log file without filtering, exposing Epic authentication credentials (`-AUTH_PASSWORD`, `-AUTH_LOGIN`, `-epicuserid`).

## Goals / Non-Goals

**Goals:**
- Make launcher executable detection in `bgmod` and `bgmod-uninstaller` case-insensitive.
- Format `WINEDLLOVERRIDES` with `;` delimiters between separate DLL definitions.
- Ensure `IsOptiScalerActive` reflects whether OptiScaler is truly active in the profile before evaluating proxy DLL conflicts.
- Redact sensitive authentication credentials from diagnostic logs in `bgmod`.

**Non-Goals:**
- ReShade standard vs add-on binary selection toggle (deferred to a separate feature proposal).
- Overhauling launcher substitution configuration syntax or storage.

## Decisions

### 1. Case-insensitive launcher matching in ResolveGameDirectory
- **Decision**: In `bgmod.lpr` and `bgmod-uninstaller.lpr`, convert both the candidate `Arg` and target tokens (`CleanKey`, `TargetSub`) to lowercase when checking with `Pos()`:
  ```pascal
  Pos(LowerCase(CleanKey), LowerCase(Arg)) > 0
  ```
  Continue using `StringReplace` with `[rfReplaceAll, rfIgnoreCase]`.
- **Alternatives considered**: Using `ContainsText` from `StrUtils`. Both approaches work, but `Pos(LowerCase(...), LowerCase(...))` avoids new unit dependencies in minimal wrapper binaries.

### 2. Semicolon delimiter in WINEDLLOVERRIDES
- **Decision**: When appending to `CurrentOverrides` in `bgmod.lpr`:
  ```pascal
  if CurrentOverrides <> '' then
    NewOverrides := CurrentOverrides + ';' + DllBase + '=n,b'
  else
    NewOverrides := DllBase + '=n,b';
  ```
  Apply this consistently across both OptiScaler and ReShade override blocks.
- **Rationale**: Adheres to the official Wine specification where entries are separated by semicolons.

### 3. Active state verification in IsOptiScalerActive
- **Decision**: In `overlayunit.pas`, verify both that `noneUpscalerRadioButton` is not checked AND that the upscaler tool switch is active for the current game:
  ```pascal
  function Tgoverlayform.IsOptiScalerActive: Boolean;
  begin
    Result := Assigned(noneUpscalerRadioButton) and 
              not noneUpscalerRadioButton.Checked and 
              GetGameToolEnabled(FSelectedGame, 2);
  end;
  ```
- **Rationale**: Prevents ReShade proxy selection from checking conflicts against an upscaler method that is disabled in the profile.

### 4. Redaction helper for launch arguments
- **Decision**: Add a helper function `RedactSensitiveParam(const Param: string): string` in `bgmod.lpr`.
  - Checks if `Param` begins with known sensitive flags:
    - `-AUTH_PASSWORD=`
    - `-AUTH_LOGIN=`
    - `-epicuserid=`
    - `-epicpassword=`
    - `-token=`
  - If matched, outputs the flag prefix followed by `[REDACTED]`.
  - Also handle two-argument formats (where flag is followed by a separate value in the next param) if encountered, redacting the value.
- **Rationale**: Keeps diagnostic logs valuable for troubleshooting while removing confidential user tokens.

## Risks / Trade-offs

- **[Risk]** Over-redacting useful debug parameters → **Mitigation**: Restrict redaction to exact sensitive prefixes (`-AUTH_PASSWORD=`, `-AUTH_LOGIN=`, `-epicuserid=`, `-epicpassword=`).
- **[Risk]** Unintended case-insensitive substring false positives in launcher rules → **Mitigation**: Retain existing `CleanKey` check matching game title or folder before replacing `TargetSub`.
