## ADDED Requirements

### Requirement: Dynamic GPU resolution fallback on low framerates
The system MUST monitor the average framerate during the GPU benchmark. If the average framerate falls below 10 FPS, the system MUST restart the GPU benchmark phase at a reduced resolution of 360p to prevent hitting the 4 FPS motor engine clamping limit.

#### Scenario: GPU benchmark falls back to 360p
- **WHEN** the average GPU benchmark framerate is determined to be below 10 FPS
- **THEN** the system resets the current GPU benchmark phase, changes the target resolution option to 360p, and restarts the GPU stress phase.

### Requirement: Scale 360p GPU score to equivalent 1080p score
When the GPU benchmark runs at 360p due to fallback, the system MUST scale the final average FPS and score down to reflect an estimated 1080p performance level. This scaled score SHALL allow scores below 100 without hitting the engine's clamping limitations.

#### Scenario: Score calculation with 360p fallback
- **WHEN** the GPU benchmark finishes execution at 360p resolution
- **THEN** the system divides the calculated average FPS and score by a pre-determined scaling factor (e.g. 5.0) to output the final equivalent 1080p score.
