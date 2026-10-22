# Design

## Context

MangoHud's `time` metric toggles local clock display, and `time_format` sets the formatting string evaluated by MangoHud via `std::put_time`.
GOverlay's "Extras" tab presents system metrics inside `FExtSysCard` across a 6-column reflowable grid. Column 4 contains `FtimeToggle` (wrapping `timeCheckBox`). Adding standalone text controls into this dense grid would disrupt alignment and waste vertical space across the other 5 columns.

See `proposal.md` for user motivation and problem definition.
See `specs/mangohud-time-format/spec.md` for requirement specifications.

## Goals / Non-Goals

**Goals:**
- Provide a clean, non-intrusive UI configuration path via a dedicated settings button (`⚙`) next to `FtimeToggle`.
- Offer popular presets covering 24-hour, 12-hour AM/PM, and date combinations, while permitting arbitrary custom format strings.
- Provide a live preview of the current time formatted with the selected format string.
- Support full round-trip loading and saving of `time_format=<value>` in MangoHud configuration files.
- Maintain theme consistency across dark and light themes.

**Non-Goals:**
- Support non-local timezone calculations (MangoHud respects the application's runtime environment, e.g. `TZ`).
- Changing other time-related flags such as `time_no_label` (which remains in sync with `time`).

## Decisions

### Decision 1: Dedicated Settings Button (`⚙`) Beside `FtimeToggle`
- **Choice**: Place a 22x20 button directly to the right of `FtimeToggle` in `FExtSysCard`.
- **Behavior**: Enabled and interactable only when `timeCheckBox.Checked = True`. When unchecked, the button is visually disabled.
- **Reflow**: During `ReflowExtrasTab`, `FTimeConfigBtn.Left` tracks `FtimeToggle.Left + FtimeToggle.Width + 4`, ensuring zero grid disruption regardless of window scaling.
- **Alternatives Considered**:
  - *Inline combobox below toggle*: Ruled out due to vertical asymmetry and requiring an extra ~26px row shift across the whole card.
  - *Putting control in "Others" section*: Ruled out due to poor spatial cohesion with the Time toggle.

### Decision 2: Self-Contained Modal Dialog with Live Preview and Instant Apply
- **Choice**: Implement a lightweight dialog dynamically styled according to `CurrentTheme`.
- **Components**:
  - Preset dropdown (`TComboBox`) with common formats plus "Custom...".
  - Edit box (`TEdit`) displaying and allowing editing of the format string.
  - Preview label (`TLabel`) dynamically formatted with current date/time using libc `strftime`.
  - Hint text with a reference to `std::put_time` specifiers.
- **Instant Apply & Streamlined UX**:
  - No "Cancel" or "Apply" buttons: selecting an option in the dropdown immediately saves configuration, reloads the preview (PasCube) if running, and displays a toast notification.
  - Custom format strings apply on Enter or focus lost (`OnEditingDone`).
  - Users dismiss or close the dialog at any time via the window close button (`[X]`) or `ESC`.
- **Preview Engine**: Use libc `strftime` to format local time in real time as the user selects presets or edits the format string.

### Decision 3: Configuration State and Serialization
- **Choice**: Add `TimeFormat: string` to `TMangoHudSettings` in `overlay_config.pas` and keep an in-memory field `FTimeFormat: string` in `TMangoHudUiHelper`.
- **Default Value**: `'%T'`.
- **Parser (`LoadMangoHudKeyValue`)**: Recognize key `time_format` and assign to `FTimeFormat`.
- **Writer (`SaveMangoHudConfig`)**: When `Settings.Time` is `True`, write `time`, `time_no_label`, and `time_format=<format>`. When empty or whitespace, fall back to `%T`.

## Risks / Trade-offs

- **[Risk] Format Specifier Incompatibility**: Users might type invalid `strftime` / `std::put_time` tokens.
  - *Mitigation*: The dialog preview parses and renders common tokens; empty format falls back to `%T`. MangoHud itself tolerates unknown format specifiers safely.
- **[Risk] Window Resizing / Theme Changes**: The button or dialog might look misplaced on dynamic theme switch.
  - *Mitigation*: `FTimeConfigBtn` is updated in `ReflowExtrasTab` and `UpdateExtrasCardTheme`, adopting `CurrentTheme` colors.
