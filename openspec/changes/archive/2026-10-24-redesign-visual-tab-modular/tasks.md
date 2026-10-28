# Tasks

## 1. Container Scaffolding & Control Reparenting

- [x] 1.1 Restructure `InitVisualTab` in `mangohud_ui.pas` to create `FVisAppearanceCard`, `FVisLayoutCard`, and `FVisActionBar` using `SubCardPaint`, and verify containers build cleanly.
- [x] 1.2 Reparent `hudtitleEdit` into `FVisAppearanceCard` and `pcidevComboBox` into `FVisActionBar`, deprecating the standalone `FVisualGpuBar` and verifying controls are visible.

## 2. Sub-Modules & Modern Controls

- [x] 2.1 Create styled segmented dual-pills (`TBitBtn`) for HUD Orientation and Border Style, link their click events to underlying settings, and verify pill active highlight state in cyan.
- [x] 2.2 Restructure the screen placement area by keeping the 9 anchor points on `Image1` and relocating `offsetxSpinEdit` and `offsetySpinEdit` to dedicated labeled inputs below the monitor canvas.
- [x] 2.3 Organize typography and background sub-panels with aligned sliders, bold accent value labels, and 20x20 color swatches.

## 3. Responsive Reflow & Theming

- [x] 3.1 Rewrite `ReflowVisualTab` to calculate balanced two-column widths, responsive sub-card vertical expansion, and action bar positioning.
- [x] 3.2 Implement `SyncVisualPills` and update `UpdateVisualCardTheme` for theme switching, verifying the project compiles cleanly with `lazbuild -B goverlay.lpi`.

## 4. UI Polish & Visual Simulation Alignment

- [x] 4.1 Eliminate overlapping legacy `columShape` bars by hiding them and keeping clean +/- column count controls.
- [x] 4.2 Fix title ampersand escaping (`ShowAccelChar := False` or `&&`) across all card and sub-card titles (`Appearance & Typography`, `Position & Layout`, `Canvas & Frame`, `Flow & Grid`).
- [x] 4.3 Remove redundant duplicate toggle labels on `FtextoutlineToggle`, `FhorizontalstrechToggle`, `FhidehudToggle`, `FhudcompactToggle`, preventing text clipping.
- [x] 4.4 Position `pcidevComboBox` and `FVisualCaptureBtn` cleanly in the UI, and improve offsets and padding of sliders, labels, and monitor graphic in `ReflowVisualTab`.
- [x] 4.5 Implement Opção 1 (HUD Mini-Bars) columns visual indicator alongside +/- stepper with dynamic accent highlight and subtle divider.
- [x] 4.6 Verify clean compilation with `lazbuild -B goverlay.lpi` and pass full test suites (`make test-logic` and `./tests/gui/gui_tests`).
