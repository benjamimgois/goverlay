# Design

## Context

See `proposal.md` for motivation.

In GOverlay, the list of available ReShade effects for vkBasalt is populated by `ListFilesToListBox(RepoDir, aveffectsListbox, ['.fx', '.fxh', '.h', '.glsl'])` in `overlayunit.pas` and `vkbasalt_tab.pas`.

When rendered in `VkReshadeMD3Paint`, each item is displayed by its base name:
```pascal
EffectName := ChangeFileExt(ExtractFileName(aveffectsListBox.Items[i]), '');
```

Because `.fxh` and `.h` were allowed extensions, pairs like `FXAA.fx` + `FXAA.fxh` or `UIDetect.fx` + `UIDetect.fxh` produce duplicate entries with the exact same display name. Furthermore, standalone header files (`ReShade.fxh`, `DrawText.fxh`, etc.) are shown as effects even though they are non-executable C/HLSL include headers.

Finally, `FXAA`, `SMAA`, and `LUT` have superior native implementations in the "Built-in Effects" card, so listing ReShade shader versions of them creates redundant options and potential configuration conflicts.

## Goals / Non-Goals

**Goals:**
- Eliminate duplicate effect names in the "Reshade effects" list so every effect appears at most once.
- Prevent non-executable header files (`.fxh`, `.h`) from being scanned into `aveffectsListbox`.
- Remove built-in effects (`FXAA`, `SMAA`, `LUT`) from the "Reshade effects" list in favor of the "Built-in Effects" controls.
- Maintain existing sorting and selection mechanisms.

**Non-Goals:**
- Changing how other tabs (like native ReShade for Windows games via Wine) download or manage shaders.
- Modifying vkBasalt's native configuration saving (which already treats built-in effects via `IsVkBasaltBuiltInEffect`).

## Decisions

### Decision: Scan Only Executable Shader Extensions
- Callers in `overlayunit.pas` and `vkbasalt_tab.pas` will pass `['.fx', '.glsl']` instead of `['.fx', '.fxh', '.h', '.glsl']`.
- Rationale: `.fxh` and `.h` are include headers and cannot be executed as vkBasalt effects.

### Decision: Reuse `IsVkBasaltBuiltInEffect` for Built-in Exclusions
- Expose `function IsVkBasaltBuiltInEffect(const AName: string): Boolean;` in `overlay_config.pas` interface.
- In `ListFilesToListBox`:
  1. Check extension against allowed extensions.
  2. Extract `BaseName := ChangeFileExt(SR.Name, '')`.
  3. If `IsVkBasaltBuiltInEffect(BaseName)`, skip. This cleanly excludes `cas`, `fxaa`, `smaa`, `dls`, and `lut`.
  4. If `SeenNames.IndexOf(BaseName) >= 0`, skip.
  5. Add `BaseName` to `SeenNames` and `RelativeToBase(Child, BaseDir)` to `ListBox.Items`.
- Rationale: Single source of truth for all built-in effects, ensuring consistency across configuration serialization and UI listing.

## Risks / Trade-offs

- **[Risk]** Two completely different shaders sharing the same filename in different subfolders.
  - **Mitigation**: ReShade shaders rely on unique technique/file names to avoid include and compilation collisions in ReShade and vkBasalt; keeping the first discovered instance is standard and prevents confusing UI duplicates.
