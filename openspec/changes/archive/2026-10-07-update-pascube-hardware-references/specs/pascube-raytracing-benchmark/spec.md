# Spec Delta

## ADDED Requirements

### Requirement: Calibrated Hardware Comparison Reference Scores
The benchmark results overlay SHALL present hardware comparison reference entries calibrated against verified database submissions for both primary benchmark scores and Ray Tracing scores.

#### Scenario: Displaying calibrated Entry Gamer PC reference scores
- **WHEN** the Hardware Comparison card renders the Entry Gamer PC reference item
- **THEN** the entry reflects 1,580 points for Main Score and 761 points for Ray Tracing score with specs indicating `i3 12100F` and `RX 6600 8GB`.

#### Scenario: Displaying calibrated Mid-Range Gamer PC reference scores
- **WHEN** the Hardware Comparison card renders the Mid-Range Gamer PC reference item
- **THEN** the entry reflects 2,751 points for Main Score and 1,713 points for Ray Tracing score with specs indicating `R5 7600` and `RTX 4060 Ti`.

#### Scenario: Displaying calibrated Steam Machine reference scores
- **WHEN** the Hardware Comparison card renders the Steam Machine reference item
- **THEN** the entry reflects 2,087 points for Main Score and 1,250 points for Ray Tracing score with specs indicating Zen 4 and RDNA3 28CU.

#### Scenario: Displaying calibrated Steam Deck reference scores
- **WHEN** the Hardware Comparison card renders the Steam Deck reference item
- **THEN** the entry reflects 818 points for Main Score and 174 points for Ray Tracing score with specs indicating Zen 2 and RDNA2 8CU.
