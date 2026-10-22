# Design

## Context

The vkNemu Idle Limiter controls are created and laid out within `FPerfLimitSec` in `mangohud_ui.pas`. Event handlers and state serialization are handled by `overlayunit.pas` (`VkNemuControlChange`).

See `proposal.md` for problem context and motivation.

## Goals / Non-Goals

**Goals:**
- Add an interactive visual state transition card (`FVkNemuFlowCard`) directly in the upper section of the Idle Limiter block.
- Visually illustrate the 3 phases of idle limitation: Active (Max FPS) -> Standby (Idle FPS) -> Resume (Delay).
- Dynamically update the diagram text values in real time upon any spin edit or combobox change.
- Format all labels, captions, and descriptions in clear, professional English.
- Reflow the layout responsively with proper padding and hierarchy.

**Non-Goals:**
- Modifying how vkNemu environment variables or MangoHud wrapper invocations are serialized.

## Decisions

### 1. Flow Diagram Component Structure
- Use a dedicated sub-panel `FVkNemuFlowCard` painted with `SubCardPaint` containing 5 aligned labels (Active Node, Transition Arrow 1, Standby Node, Transition Arrow 2, Resume Node).
- Update procedure: `TMangoHudUiHelper.UpdateVkNemuFlowDiagram` reads the current control values and updates the labels instantly.

### 2. Event Hooking
- Call `UpdateVkNemuFlowDiagram` inside `Tgoverlayform.VkNemuControlChange` and `ReflowPerformanceTab`.

## Risks / Trade-offs

- **[Risk] Narrow container width:** On narrow sizes, long arrow strings could clip.
  - **Mitigation:** Use concise text format (`--[ 2s Idle ]-->`) and adapt sizes during `ReflowPerformanceTab`.
