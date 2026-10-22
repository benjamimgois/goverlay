## Context

See `proposal.md` for motivation. The MangoHud Metrics tab (`InitMetricsTab` in `mangohud_ui.pas`) currently reparents multiple standard `TCheckBox` controls to `FMtGpuCard` and `FMtCpuCard`. Standard checkboxes have fixed OS widget styling that is difficult to theme cleanly in dark mode and occupies wide bounding boxes.

## Goals / Non-Goals

**Goals:**
- Implement a reusable, self-contained `TToggleSwitch` component (`TCustomControl`) that paints crisp antialiased pills and responds to click interactions.
- Use a compact scale (`28 × 16 px`) suited for dense multi-column metric layouts.
- Integrate `TToggleSwitch` into `FMtGpuCard` and `FMtCpuCard` on the Metrics tab.
- Maintain transparent synchronization with existing configuration load/save procedures and existing test assertions.

**Non-Goals:**
- Modifying other tabs (Visual, Performance, Extras, OptiScaler) in this initial test change.
- Altering the underlying MangoHud configuration keys or parser mechanics.

## Decisions

### Decision 1: `TToggleSwitch` as a `TCustomControl`
- **Choice**: Implement `TToggleSwitch = class(TCustomControl)` with custom `Paint`, `MouseDown`, and `Click` handling.
- **Rationale**: Provides native Pascal control integration, accurate double-buffered antialiased rendering via LCL Canvas (`RoundRect`, `Ellipse`, `TextOut`), and automatic tooltip (`Hint`) and parent theme inheritance.
- **Alternatives Considered**: Using static `TImage` strips (cumbersome to resize dynamically) or custom owner-drawn `TCheckBox` (unreliable across Qt6/GTK2 LCL widgetsets).

### Decision 2: Compact Sizing Parameters
- **Track**: Width = 28px, Height = 16px, Corner Radius = 8px.
- **Thumb**: Diameter = 10px, Margin (`PAD`) = 3px.
- **Colors**:
  - Active: Track `#34AF5A`, Border `#2A964B`, Thumb `#FFFFFF`.
  - Inactive: Track `#2C3244`, Border `#3A4258`, Thumb `#C8CDD7`.
  - Drop shadow: 1px subtle dark shadow under the thumb.

### Decision 3: Bi-directional Synchronization Wrapper
- **Choice**: Allow `TToggleSwitch` to link to an underlying `TCheckBox` or manage its own state while notifying `OnChange`.
- **Rationale**: Keeps existing backend save/load routines in `overlay_config.pas` and `mangohud_ui.pas` 100% stable while giving an immediate visual transformation.

## Risks / Trade-offs

- **[Risk]** Text clipping if toggle + label exceeds column width.
  - *Mitigation*: The compact 28x16px track requires less horizontal width than a standard `TCheckBox` + margin, and `ReflowMetricsTab` column bounds have ample space (>105px per column).
