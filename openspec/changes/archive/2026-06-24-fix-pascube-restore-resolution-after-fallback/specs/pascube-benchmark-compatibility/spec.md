## ADDED Requirements

### Requirement: Restore render resolution after GPU fallback
When the GPU benchmark falls back to 360p resolution due to low framerate, the system MUST restore the internal render resolution (`fRenderWidth`/`fRenderHeight`) to 1920x1080 after the GPU benchmark phase completes and before entering the results screen phase.

#### Scenario: Resolution restored after 360p fallback
- **WHEN** the GPU benchmark completes at 360p fallback resolution and transitions to the results phase
- **THEN** the render viewport is set to 1920x1080, rendering the results screen at the standard resolution.
