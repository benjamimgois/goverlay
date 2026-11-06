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
The analytics engine SHALL compute comparative speedup multipliers relative to prominent mobile/handheld devices and relative to prominent desktop tiers and console baselines (High-End Gamer PC, Mid-Range Gamer PC, and PlayStation 5 Base).

#### Scenario: Multiplier calculation against reference hardware
- **WHEN** the performance scaling slide is active
- **THEN** the system calculates and displays the user's performance speedup multipliers compared to handhelds (Steam Deck, ROG Ally X, Nintendo Switch 2) and comparative fractions/multipliers against High-End Gamer PC, Mid-Range Gamer PC, and PlayStation 5 Base console.

### Requirement: Distribution Share Breakdown by GPU
The analytics engine SHALL aggregate community submissions matching the user's detected GPU family to calculate the percentage share of each Linux distribution.

#### Scenario: Aggregating top distributions for current GPU
- **WHEN** the distribution breakdown slide is active
- **THEN** the system filters submissions matching the user's GPU model and renders a ranked horizontal bar chart of the most popular Linux distributions along with their average scores.

### Requirement: Results Carousel Navigation
The PasCube user interface SHALL present results in a six-slide carousel in the exact order: Overview, Curve, Silicon, Efficiency, Scaling, Distros, with compact pill navigation and pause-on-hover autoplay.

#### Scenario: Navigating through six results slides
- **WHEN** the user views the benchmark results screen
- **THEN** the interface provides 6 navigation pills (1. Overview, 2. Curve, 3. Silicon, 4. Efficiency, 5. Scaling, 6. Distros), supports smooth transitions, advances every 6 seconds on autoplay, pauses autoplay on mouse hover, and supports keyboard and side arrow navigation.

### Requirement: Dual GPU and CPU Silicon Lottery Dispersion and Ranking
The benchmark analytics engine SHALL filter community benchmark submissions to isolate the user's identical GPU and CPU models, computing model rank, model average, minimum bin, and record overclock scores for both components side-by-side.

#### Scenario: Evaluating user GPU and CPU against identical silicon
- **WHEN** the silicon lottery slide is rendered
- **THEN** the system calculates the user's position among identical GPU and CPU model submissions, displaying side-by-side continuous dispersion spectrum bars (Min, Avg, User Die, Record) and silicon quality verdict boxes without text overflow.

### Requirement: Dual GPU and CPU Thermal Headroom and Power Efficiency Analytics
The analytics engine SHALL compute points-per-watt efficiency based on peak board power and evaluate thermal margins against hardware throttling limits for both GPU and CPU.

#### Scenario: Displaying thermal headroom and points per watt
- **WHEN** the efficiency slide is active
- **THEN** the system displays overall and component Power Efficiency Indexes (GPU pts/W, CPU pts/W), calculates GPU thermal headroom before throttle (90°C), calculates CPU thermal headroom before TjMax (95°C), and presents power spectrum comparison bars.

### Requirement: Linux Ecosystem Software & Performance Statistics
The Distros slide SHALL display distribution adoption metrics with brand badges alongside 3 deep software statistical cards: Desktop Environment popularity, Graphics Driver / Vulkan Stack performance delta, and Kernel vs CPU Performance delta.

#### Scenario: Displaying Linux ecosystem software insights
- **WHEN** the distros slide is rendered
- **THEN** the interface displays the most popular Linux distributions with brand badges (`[CY]`, `[AR]`, `[FD]`, `[UB]`) and renders 3 software comparison cards: Desktop Environment popularity bar chart, Graphics Driver/Mesa version delta, and Kernel version vs CPU architecture performance delta.
