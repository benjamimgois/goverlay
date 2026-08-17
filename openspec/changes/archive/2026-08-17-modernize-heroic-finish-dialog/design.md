# Design: Modernize Heroic Finish Dialog Guide

## Context

`finish_dialog.pas` provides `TFinishDialogForm` which renders custom walkthrough animations for Steam and Heroic. See `proposal.md` for motivation.

## Goals / Non-Goals

**Goals:**
- Replicate modern Heroic Games Launcher settings UI within `PaintAnimHeroic` in pure native `TCanvas`.
- Structure the visual mockup with:
  - Top title bar showing `<GameTitle> (Settings)` (or `GLOBAL OVERLAY (Settings)`) and top-right close `✕` icon.
  - Horizontal tab navigation (`WINE | OTHER | ADVANCED | CLOUD SAVES | GAMESCOPE | LEGACY`) with `ADVANCED` highlighted in Heroic cyan/teal (`#55EBD8`) with a solid underline bar.
  - Vertical scrollbar track on the right showing a scrolled-down state on the `ADVANCED` tab.
  - `Wrapper Command:` section with `Wrapper` and `Arguments` column subheaders, two input fields, and the green/teal `[+]` add button (`#00C9B7`).
  - Pulsing highlight border on the `Wrapper` input box with blinking cursor and animated guide arrow.
- Update the step-by-step instruction text to guide users to `Settings › Advanced › scroll down to "Wrapper Command"`.

**Non-Goals:**
- External webviews or static bitmap assets (rely purely on FreePascal LCL `TCanvas` procedural primitives).

## Decisions

### Decision 1: Procedural TCanvas Recreation of Modern Heroic
- **Choice**: Draw all elements (dark window frame, horizontal tabs, active tab underline, scrollbar, subheader columns, dual input fields, add button, and glow effects) using `TCanvas` primitives.
- **Rationale**: Retains crisp rendering, fast rendering performance, zero external image assets, and seamless synchronization with live animation ticks.

### Decision 2: Scrollbar Representation
- **Choice**: Draw a discrete scrollbar track along the right edge of the content area with the thumb positioned toward the bottom.
- **Rationale**: Graphically conveys the requirement that the user needs to scroll down inside the `Advanced` tab to locate the `Wrapper Command` section.

### Decision 3: Updated Instruction Copy
- **Choice**: Replace outdated "Other" references with explicit directions to open "Advanced", scroll down to "Wrapper Command", paste into "Wrapper", and click "+".

## Risks / Trade-offs

- **Risk**: Horizontal space constraints for dual input boxes + add button.
  - **Mitigation**: Calculate proportional widths for `Wrapper` field (~50% width), `Arguments` field (~35% width), and `[+]` button (20px width) within the right panel space.
