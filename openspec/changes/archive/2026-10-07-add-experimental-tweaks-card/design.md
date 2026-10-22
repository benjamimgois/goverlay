# Design

## Context

See `proposal.md` for motivation. Currently, `tweaks_md3.pas` divides tweaks into 4 predefined categories (`General`, `Graphics`, `Performance`, `Latency reduction`), followed by `Custom Variables` and `Launch Arguments`. Some experimental tweaks (Zink, RE Engine workaround) are currently mixed into `Graphics`, while cutting-edge DX12/RT workarounds (such as `VKD3D_CONFIG=descriptor_heap`, `NGX_DLSS_RR_OVERRIDE=on`, `VKD3D_RTAS_SIZE_MULT=8`) are missing entirely.

## Goals / Non-Goals

**Goals:**
- Provide a dedicated, clearly delineated `Experimental` category card in the Tweaks tab.
- Visually warn users about potential instability through a top warning banner and amber header styling.
- Bundle `VKD3D_CONFIG=descriptor_heap` and `PROTON_VKD3D_HEAP=1` under a single toggle for seamless DX12 descriptor heap configuration.
- Support `NGX_DLSS_RR_OVERRIDE=on` (Ray Reconstruction) with an `[NVIDIA]` badge chip and `VKD3D_RTAS_SIZE_MULT=8` for RT buffer expansion.
- Migrate Zink and RE Engine workaround from Graphics to Experimental.
- Prevent any of these predefined keys from leaking into `[CustomVariables]`.

**Non-Goals:**
- Interrupting users with disruptive modal dialogs on every toggle click (Option A: card banner + hover hints was selected).
- Modifying how `bgmod` executes games (since `bgmod` already exports all keys from `[Env]`).

## Decisions

### Decision 1: Add `TWEAK_CAT_EXPERIMENTAL = 4` to Category Enum
Expand the category enumeration:
- `TWEAK_CAT_GENERAL = 0`
- `TWEAK_CAT_GRAPHICS = 1`
- `TWEAK_CAT_PERF = 2`
- `TWEAK_CAT_LATENCY = 3`
- `TWEAK_CAT_EXPERIMENTAL = 4`
- `TWEAK_CAT_CUSTOM = 5`
- `TWEAK_CAT_ARGS = 6`

The category loop in `Paint` and `MouseDown` / `MouseMove` updates from `for CatIdx := 0 to 3` to `for CatIdx := 0 to 4`. `TweakCategoryName` maps `TWEAK_CAT_EXPERIMENTAL` to `'Experimental'`.

### Decision 2: Experimental Card Layout & Top Warning Banner
For `CatIdx = 4` (Experimental), the card header renders with amber warning text (`⚠ Experimental`).
Directly below the header (`Y + CARD_HDR_H`), an inline warning banner is drawn:
- Height: `INFO_BANNER_H = 34`
- Background: Dark amber `RGBToColor(48, 36, 16)`
- Border: Amber `RGBToColor(180, 130, 30)`
- Text: Light amber `RGBToColor(255, 210, 110)`
- Message: `"⚠ Experimental tweaks may cause instability. Use only if required by a specific game."`
The item rows start below the banner (`Y + CARD_HDR_H + INFO_BANNER_H + CARD_PAD_BOTTOM`). Total card height is adjusted accordingly.

### Decision 3: Descriptor Heap Dual-Variable Bundling
Similar to the recent DXVK/VKD3D low latency bundling:
- Save: When `FProtonVkd3dHeapCheckBox.Checked`, writes both `VKD3D_CONFIG=descriptor_heap` and `PROTON_VKD3D_HEAP=1` into `[Env]`.
- Load: In `ProcessPredefinedEnv`, checks if `SameText(K, 'PROTON_VKD3D_HEAP')` or `(SameText(K, 'VKD3D_CONFIG') and (Pos('descriptor_heap', V) > 0))` is active (`V = '1'` or `V = 'descriptor_heap'`).
- Filter: In `IsPredefinedEnvVar`, registers both keys so neither leaks into custom variables.

### Decision 4: New Checkbox Instances in `overlayunit.pas`
Define three new private/public checkboxes on `Tgoverlayform`:
- `FProtonVkd3dHeapCheckBox: TCheckBox;`
- `FNvidiaDlssRROverrideCheckBox: TCheckBox;`
- `FVkd3dRtasSizeMultCheckBox: TCheckBox;`
These are instantiated and assigned to `TWEAK_ROWS` via `GetTweakRowCheckBox`.

## Risks / Trade-offs

- **[Risk]** Additional height on Tweaks tab causes more scrolling.
  → **Mitigation:** The Experimental card contains 5 items. In a 2-column layout, it occupies only 3 item rows plus banner (~220px), easily accommodated by existing scroll handling.
- **[Risk]** `VKD3D_CONFIG` might be used for other custom settings by advanced users.
  → **Mitigation:** If a user specifies custom `VKD3D_CONFIG` values other than `descriptor_heap`, `IsPredefinedEnvVar` only filters out `descriptor_heap`, preserving arbitrary custom configs in `CustomVariables`.
