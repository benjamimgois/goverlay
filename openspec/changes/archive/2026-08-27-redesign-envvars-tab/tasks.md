## 1. Card Container & Layout Modernization

- [x] 1.1 Update `TTweaksMD3Helper.Paint` in `tweaks_md3.pas` to render category containers as rounded dark cards with subtle borders (`DARK_CARD_BG`, `DARK_CARD_BORDER`) and clean headers (`Sans Bold 10pt`), removing full-width blue stripes and emoji glyphs; verify visual appearance of all category cards.
- [x] 1.2 Update item grid layout within cards (responsive 2-column and 1-column modes) with proper inner card margins, padding, and subtle item separators; verify correct layout in wide and narrow window sizes.

## 2. Controls and Badge Styling

- [x] 2.1 Refactor `DrawToggle` in `tweaks_md3.pas` with modernized switch dimensions (38x20px), smoother track palettes, and clean white thumb; verify visual appearance across enabled and disabled states.
- [x] 2.2 Implement compact rounded badge chip rendering for special prefixes (`[CachyOS]`, `[MESA]`, `[low_latency_layer]`); verify badges render cleanly next to option descriptions without text clutter.

## 3. Hit-Testing, Interaction & Scroll Padding

- [x] 3.1 Update `MouseMove`, `MouseDown`, and tooltip hit-testing coordinates in `tweaks_md3.pas` to match the new card and item geometry; verify clicking on an item or switch toggles the setting reliably.
- [x] 3.2 Add bottom scroll margin for floating action dock (`TFloatingActionDock`) and verify all custom variable items remain accessible when scrolled to the end.

## 4. Build and Verification

- [x] 4.1 Compile GOverlay (`lazbuild goverlay.lpi` or `make`) and verify zero compilation errors and complete visual harmony with other tabs.
