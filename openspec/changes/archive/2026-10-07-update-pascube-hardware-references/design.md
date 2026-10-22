# Design

## Context

In `pascube_src/src/UnitPasCubeScreen.pas`, the procedure `GetHardwareReferences(out aRefs: THardwareRefArray)` populates 11 static reference hardware entries and the user's `Current System`, subsequently sorting the array descending by `Score`.
Initial Ray Tracing scores (`RTScore`) assigned during the implementation of the RT benchmark were theoretical estimates. Now that over 260 real-world benchmark submissions with Vulkan Ray Tracing exist in the public Pascube database, these static reference scores can be aligned with empirical data.

## Goals / Non-Goals

**Goals:**
- Update `Entry Gamer PC` RTScore to 761 (mean of real RX 6600 benchmark runs).
- Update `Mid-Range Gamer PC` Main Score to 2,751 and RTScore to 1,713 (matching real R5 7600 + RTX 4060 Ti runs).
- Update `Steam Machine` RTScore to 1,250 (calibrated against RDNA3 28CU compute scaling relative to desktop RX 7600 at 1,452 pts).
- Update `Steam Deck` RTScore to 174 (peak verified run in the database).

**Non-Goals:**
- Altering the array sorting order algorithm or visual accordion mechanics.
- Modifying the underlying benchmark scoring calculations or online telemetry payloads.

## Decisions

### 1. Mid-Range Gamer PC Score Alignment with R5 7600
- **Choice:** Maintain `CPU: R5 7600` and adjust `Score` from 2,898 to 2,751.
- **Rationale:** The historical 2,898 score came from a run with a Ryzen 5 9600X. The verified submission with an actual Ryzen 5 7600 + RTX 4060 Ti scored 2,751 points. This keeps the specification text accurate while reflecting genuine test results.
- **Alternatives considered:** Retaining 2,898 and updating the spec string to `R5 9600X`, which was rejected in favor of keeping the representative R5 7600 baseline.

### 2. Empirical Calibration of RX 6600 and RTX 4060 Ti Ray Tracing Scores
- **Choice:** Set RX 6600 RT to 761 points and RTX 4060 Ti RT to 1,713 points.
- **Rationale:** Six verified database runs for RX 6600 show RT scores between 726 and 792 (average: 761.3). Database submissions for RTX 4060 Ti show RT scores of 1,712 and 1,713. The previous estimate for the 4060 Ti (2,100) belonged to an RTX 4070 class card, and the RX 6600 (520) was severely underestimated.

### 3. Architecture-Proportional Calibration for Steam Machine
- **Choice:** Set Steam Machine RT to 1,250 points.
- **Rationale:** A desktop RX 7600 (RDNA3 32CU) achieves 1,452 points in PasCube RT. A 28CU RDNA3 configuration at 2.45GHz scales to approximately 87.5% throughput (~1,270 points). Setting 1,250 points represents a realistic console-class RDNA3 target.

## Risks / Trade-offs

- **[Relative bar width visual impact]** → *Mitigation:* Because `MaxRTScore` is derived from the highest entry (typically RTX 5090 at 7,450 or a high-end current system), increasing the RX 6600 and Steam Machine bars while lowering the 4060 Ti bar produces an accordion visualization that matches real-world relative performance.
