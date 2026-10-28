# Proposal

## Why

The MangoHud Visual tab in GOverlay currently suffers from visual fragmentation and cramped ergonomics: a monolithic card packs six micro-sections into a rigid 3x2 grid, forcing X/Y offset inputs directly on top of the screen placement monitor while isolating the HUD title and Active GPU selector into detached, orphaned bars. Redesigning the Visual tab into a balanced two-column modular architecture (Appearance & Typography alongside Position & Geometry, unified with a dedicated Display & Hardware action bar) modernizes the tab and aligns it with the clean visual language established on the Metrics and Extras tabs.

## What Changes

- **Balanced Two-Column Modular Layout (Option A)**:
  - **Left Column Card ("Aparência & Tipografia" / "Appearance & Typography")**:
    - Integrates custom HUD Title (`hudtitleEdit`) cleanly into the top of the card with dark input styling and placeholder hint.
    - Groups typography controls into a dedicated sub-module: Font family dropdown (`fontComboBox`), live Font Size slider (`fontsizeTrackBar`) with numeric accent value badge (`fontsizevalueLabel`), Font Color chip (`FontcolorButton`), and Text Outline toggle (`FtextoutlineToggle`).
    - Groups canvas and frame controls into a dedicated sub-module: Background Color chip (`hudbackgroundColorButton`), live Background Opacity slider (`transpTrackBar`) with numeric accent value badge (`alphavalueLabel`), and modern segmented dual-pills for Border Style (`[ Retos | Redondos ]` / `[ Square | Round ]`).
  - **Right Column Card ("Posicionamento & Layout" / "Position & Layout")**:
    - Dedicated screen placement sub-module with clean interactive monitor preview (`Image1`) and 9 anchor points (TL, TC, TR, ML, MR, BL, BC, BR).
    - Unclutters the monitor graphic by relocating fine-tuning X and Y offsets (`offsetxSpinEdit`, `offsetySpinEdit`) into dedicated, labeled inputs cleanly placed below the monitor display.
    - Groups flow and orientation controls into a dedicated sub-module: modern segmented dual-pills for HUD Orientation (`[ ↕ Vertical | ↔ Horizontal ]`), column count stepper (`[-] [ 3 colunas ] [+]`), and Horizontal Stretch toggle (`FhorizontalstrechToggle`).
  - **Bottom Full-Width Card ("Comportamento & Hardware" / "Behavior & Hardware")**:
    - Hotkey shortcut capture button (`FVisualCaptureBtn`) with keyboard glyph.
    - Quick display switches: Compact HUD (`FhudcompactToggle`) and Hide by Default (`FhidehudToggle`).
    - Integrates the Active GPU selector (`pcidevComboBox`) directly into the hardware section, eliminating the disconnected standalone bottom bar.
- **Segmented Dual-Pill Controls**: Replaces legacy LCL radio buttons and standalone images for Orientation and Border styles with styled, high-contrast segmented pill buttons matching `StyleBitBtnTheme`.
- **Responsive Dynamic Reflow**: Ensures smooth resizing across window dimensions with dynamic column balance, consistent padding, and integrated `TScrollBox` handling when required.

## Capabilities

### New Capabilities
- `mangohud-visual-modular-ui`: Defines the balanced two-column modular card architecture, uncluttered screen monitor layout with dedicated offset inputs, segmented dual-pills for orientation and borders, and integrated hardware bar on the MangoHud Visual tab.

### Modified Capabilities
<!-- None: Underlying MangoHud configuration keys and serialization routines remain 100% compatible. -->

## Impact

- Code: `mangohud_ui.pas` (`InitVisualTab`, `ReflowVisualTab`, `UpdateVisualCardTheme`), `overlayunit.pas`, and `overlayunit.lfm`.
- UI: MangoHud -> Visual tab.
- Dependencies: None.
