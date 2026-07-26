## Context

In GOverlay, MangoHud's Vulkan VSync (`vsync`) and OpenGL VSync (`gl_vsync`) settings are saved by `SaveMangoHudConfigCore` in `overlay_config.pas` and loaded back into UI controls via `LoadMangoHudKeyValue` in `mangohud_ui.pas`. 

Currently:
1. `hintsunit.pas` defines a tooltip hint for `vsyncComboBox` as `0 = Off`, `1 = On`, `2 = Mailbox mode`, `3 = Adaptive`. However, MangoHud defines Vulkan VSync as `0 = Adaptive`, `1 = Off`, `2 = Mailbox`, `3 = On`. GOverlay's saved values (`vsync=0`, `vsync=1`, `vsync=2`, `vsync=3`) match MangoHud, but the hint string misinforms the user.
2. In `overlay_config.pas`, selecting index `4` ("Unset") writes `vsync=4` or `gl_vsync=4` into `MangoHud.conf`. For OpenGL VSync, `4` sets swap interval 4 rather than unsetting the option. For Vulkan VSync, `4` is an unrecognized option. In MangoHud, unsetting an option means omitting the key from the configuration file.

## Goals / Non-Goals

**Goals:**
- Correct `vsyncComboBox` tooltip hint in `hintsunit.pas` to accurately state MangoHud's Vulkan VSync definitions (`0 = Adaptive`, `1 = Off`, `2 = Mailbox mode`, `3 = On`).
- Update `SaveMangoHudConfigCore` in `overlay_config.pas` so that selecting index `4` ("Unset") omits `vsync` and `gl_vsync` lines from `MangoHud.conf`.
- Ensure `ResetMangoHudControls` in `mangohud_ui.pas` sets `vsyncComboBox.ItemIndex` and `glvsyncComboBox.ItemIndex` to `4` ("Unset") by default so omitted keys preserve the "Unset" state upon configuration load.
- Update GUI test cases in `tests/gui/gui_test_cases.pas` to test omitted VSync keys for "Unset" and verify roundtrips.

**Non-Goals:**
- Changing the Vulkan or OpenGL VSync dropdown items or index order in `overlayunit.lfm`.

## Decisions

### Decision 1: Update hint text in `hintsunit.pas`
Change `SetHint('vsyncComboBox', ...)` in `hintsunit.pas` to:
```pascal
  SetHint('vsyncComboBox', 'VSync (Vulkan)' + LineEnding +
    '0 = Adaptive' + LineEnding +
    '1 = Off' + LineEnding +
    '2 = Mailbox mode' + LineEnding +
    '3 = On');
```

### Decision 2: Omitting VSync keys when Unset is selected
In `overlay_config.pas`:
- For `Settings.VsyncItemIndex`: only output `vsync=0`, `vsync=1`, `vsync=2`, or `vsync=3` for indices 0..3. Do not output anything for index 4 ("Unset").
- For `Settings.GlvsyncItemIndex`: only output `gl_vsync=-1`, `gl_vsync=0`, `gl_vsync=n`, or `gl_vsync=1` for indices 0..3. Do not output anything for index 4 ("Unset").

In `mangohud_ui.pas`:
- `ResetMangoHudControls` sets `vsyncComboBox.ItemIndex := 4` and `glvsyncComboBox.ItemIndex := 4`.
- When loading `MangoHud.conf`, if `vsync` or `gl_vsync` keys are present, their specific values set the respective `ItemIndex` (0..3). If absent, the controls remain at `ItemIndex := 4` ("Unset").

## Risks / Trade-offs

- [Risk] Existing `MangoHud.conf` files with `gl_vsync=4` or `vsync=4` legacy lines from previous GOverlay saves. → Mitigation: Ignore `gl_vsync=4` or `vsync=4` during load or map them to `ItemIndex := 4` ("Unset") if encountered for backward compatibility.
