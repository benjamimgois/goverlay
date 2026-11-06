# pascube-community-insights Specification

## Purpose
Fetches, caches, and calculates community-wide benchmark statistics from PasCubeDB (normal distribution metrics, percentile position, hardware scaling multipliers, and distribution share by GPU) with guaranteed offline fallback resilience.

## Requirements

### Requirement: PasCubeDB Asynchronous Community Data Synchronization
The benchmark telemetry system SHALL retrieve community submission data from PasCubeDB in a non-blocking background thread and persist it to a local disk cache.

#### Scenario: Successful online community data retrieval
- **WHEN** PasCube launches or completes a benchmark run while an internet connection is available
- **THEN** a background synchronization thread queries PasCubeDB, downloads latest submission metrics, and updates `~/.cache/goverlay/pascubedb_cache.csv` without dropping Vulkan frame rate.

#### Scenario: Graceful offline cache fallback
- **WHEN** PasCube runs without an active internet connection or the remote query fails
- **THEN** the system loads the local cached dataset if present, or falls back to an embedded reference dataset compiled into PasCube without displaying network error popups.

### Requirement: Normal Distribution Curve and Percentile Ranking Computation
The benchmark analytics engine SHALL calculate the Gaussian distribution parameters (mean and standard deviation) and the exact percentile rank of the user's score against all recorded community scores.

#### Scenario: Computing percentile and community position
- **WHEN** a benchmark concludes with a valid main score
- **THEN** the analytics engine evaluates the user's score against the dataset, deriving the community average, standard deviation, and the exact percentile rank (e.g., "Top 22%" / "Supera 78% dos sistemas").

#### Scenario: Visual Gaussian bell curve plotting
- **WHEN** the community distribution slide is displayed
- **THEN** the interface renders an interpolated normal distribution bell curve with a highlighted indicator marking the user's position on the score axis.

### Requirement: Hardware Performance Scaling Multipliers
The analytics engine SHALL compute comparative speedup multipliers relative to prominent mobile/handheld devices and relative to the highest-scoring enthusiast PC in the dataset.

#### Scenario: Multiplier calculation against reference hardware
- **WHEN** the performance scaling slide is active
- **THEN** the system calculates and displays the user's performance multiple compared to portable devices (Steam Deck, ROG Ally) and the performance fraction relative to the top #1 high-end system.

### Requirement: Distribution Share Breakdown by GPU
The analytics engine SHALL aggregate community submissions matching the user's detected GPU family to calculate the percentage share of each Linux distribution.

#### Scenario: Aggregating top distributions for current GPU
- **WHEN** the distribution breakdown slide is active
- **THEN** the system filters submissions matching the user's GPU model and renders a ranked horizontal bar chart of the most popular Linux distributions along with their average scores.
