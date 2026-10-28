# Proposal: Eliminate Action Bar and Integrate Controls into Visual Cards

## Why

The current full-width Action Bar (`FVisActionBar`) at the bottom of the MangoHud Visual tab creates a direct visual collision with GOverlay's global floating dock (`[☰] [👁 Preview] [✓ Finish]`) in the bottom-right corner, obscuring the Active GPU selector (`pcidevComboBox`) on standard resolutions. Furthermore, keeping a separate 46px horizontal bar at the bottom fragments the interface and consumes vertical space that would otherwise give the two main modular cards generous breathing room. 

Integrating these 4 controls directly into the primary cards (**Appearance & Typography** and **Position & Layout**) creates a cleaner, purely two-column layout, eliminates the dock collision completely, and reinforces logical semantic grouping.

## What Changes

- **Eliminate `FVisActionBar`**: Remove the bottom Action Bar container and expand both `FVisAppearanceCard` and `FVisLayoutCard` downward to utilize the full vertical tab height (+54px vertical space).
- **Integrate `Compact HUD` into Canvas & Frame**: Move `FVisCompactLbl` and `FhudcompactToggle` into `FVisCanvasSec` (Appearance card) alongside corner borders and opacity, where it logically belongs as a HUD frame density setting.
- **Integrate Hotkey, Silent Mode, and Active GPU into Position & Layout**: Add a cohesive "System & Hotkey" section inside `FVisLayoutCard` (or below Flow & Grid) containing:
  - `Active GPU:` (`FVisGpuBarLbl` + `pcidevComboBox`)
  - `HUD Toggle:` (`FVisShortcutLbl` + `FVisualCaptureBtn`)
  - `Hide HUD by default:` (`FVisHideLbl` + `FhidehudToggle`)
- **Dock Clearance**: The bottom-right area of the tab is freed from controls, ensuring the global floating dock never overlaps or clips any setting.
- **Responsive Reflow**: Update `ReflowVisualTab` to size the two main cards across the full vertical space without calculating or positioning an action bar.

## Capabilities

### Modified Capabilities
- `mangohud-visual-modular-ui`: Modify requirements to remove the bottom action bar and specify the integrated placement of Compact HUD in Appearance and System/Hotkey/GPU controls within Position & Layout.

## Impact

- **Affected Code**: `mangohud_ui.pas` (`InitVisualTab`, `ReflowVisualTab`, `UpdateVisualCardTheme`), `tests/gui/gui_test_cases.pas`.
- **UI Structure**: No changes to core backend configuration persistence or MangoHud configuration keys (`compact`, `no_display`, `pci_dev`, `toggle_hud`).
- **Tests**: Existing GUI test `TestMangoHudVisualCompactToggles` will be updated to verify the new parentage and clean layout bounds.
