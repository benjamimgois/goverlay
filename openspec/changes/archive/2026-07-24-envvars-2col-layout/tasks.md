## 1. Responsive 2-Column Layout Implementation

- [x] 1.1 Update `Paint` routine in `tweaks_md3.pas` to render items in 2 columns when `PB.Width >= 700`.
- [x] 1.2 Update `MouseDown` hit-testing in `tweaks_md3.pas` to resolve column and row indices correctly for 2-column mode.
- [x] 1.3 Update `MouseMove` hover-index detection in `tweaks_md3.pas` for 2-column mode.
- [x] 1.4 Update total scroll height calculation in `tweaks_md3.pas` to account for halved item rows per category.

## 2. Verification & Testing

- [x] 2.1 Verify `make test` headless unit/GUI test suite passes.
- [x] 2.2 Verify item toggles, custom envvar deletion ('×'), and category expand/collapse work in 2-column mode.
