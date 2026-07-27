## 1. Asset Creation & Preparation

- [x] 1.1 Generate crisp 48x48 PNG icon assets for Games (`games-inactive.png` and `games-active.png`) in `assets/icons/`
- [x] 1.2 Generate crisp 48x48 PNG icon assets for Post processing (`postprocessing-inactive.png` and `postprocessing-active.png`) in `assets/icons/`
- [x] 1.3 Generate crisp 48x48 PNG icon assets for EnvVars (`envvars-inactive.png` and `envvars-active.png`) in `assets/icons/`

## 2. Sidebar Navigation Refactoring

- [x] 2.1 Refactor `BuildNavRail` in `sidebar_nav.pas` to create `TImage` instances for all sidebar items instead of text labels
- [x] 2.2 Update `SetNavActive` in `sidebar_nav.pas` to switch active/inactive PNG image sources for all 5 sidebar items
- [x] 2.3 Verify hover, click, and animation handlers function identically for image controls

## 3. Verification & Testing

- [x] 3.1 Run `make test` to ensure GUI and logic test suites pass completely
- [x] 3.2 Verify visual appearance on offscreen/Qt6 platform build
