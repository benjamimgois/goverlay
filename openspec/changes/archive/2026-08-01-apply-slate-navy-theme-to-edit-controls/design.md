## Context

See `proposal.md` for motivation. On Qt6/Linux, desktop themes like KDE Breeze override LCL's native `Color` and `Font.Color` properties for `TEdit` (`QLineEdit`) and `TSpinEdit` (`QSpinBox`) controls.

To enforce dark theme styling consistently across all tabs, GOverlay applies Qt stylesheets via `QApplication_setStyleSheet` globally or via `QWidget_setStyleSheet` on individual containers.

## Goals / Non-Goals

**Goals:**
- Extend the global `QApplication` stylesheet in `overlayunit.pas` to cover `QLineEdit` and `QSpinBox` widgets with Slate Navy (`rgb(38,46,72)`) background and focus outlines (`rgb(48,190,240)`).
- Update container-level helpers (`UpdateGenericCardTheme` in `overlayunit.pas` and MangoHud helpers in `mangohud_ui.pas`) so local overrides match the global Slate Navy theme.

**Non-Goals:**
- Changing structural layout or placement of any edit fields or spin boxes.
- Altering validation rules, text change handlers, or underlying data bindings for input fields.

## Decisions

### Decision 1: Application-level QSS for `QLineEdit` and `QSpinBox`
- **Choice**: Add rules for `QLineEdit` and `QSpinBox` to the global `GlobalSS` string passed to `QApplication_setStyleSheet` during `FormShow` in `overlayunit.pas`.
- **Rationale**: Application-level stylesheets override system widget styles (e.g., KDE Breeze) across all forms, tabs, and dynamically created or nested controls without having to attach stylesheets to every single widget manually.
- **Alternatives Considered**: Attaching stylesheets individually in each tab unit — rejected because it leads to inconsistent styling when new controls or sub-panels are added.

### Decision 2: Focus State Styling (`:focus`)
- **Choice**: Style `QLineEdit:focus` and `QSpinBox:focus` with a cyan border (`rgb(48,190,240)`).
- **Rationale**: The cyan accent color is used across GOverlay for tab indicators and active toggles, providing an intuitive cue for active text entry.

## Risks / Trade-offs

- **[Risk]** Specific custom `TEdit` controls with specialized inline styles might have their borders or backgrounds overridden by global QSS.
- **Mitigation**: Ensure container-level theme updaters (`UpdateGenericCardTheme`) explicitly supply compatible styles when theme toggles (light/dark mode) occur.
