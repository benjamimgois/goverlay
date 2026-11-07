# pascube-community-insights Specification

## Purpose
Fetches, caches, and calculates community-wide benchmark statistics from PasCubeDB (normal distribution metrics, percentile position, hardware scaling multipliers, and distribution share by GPU) with guaranteed offline fallback resilience.

## Requirements

### Requirement: PasCubeDB Asynchronous Community Data Synchronization
The benchmark telemetry system SHALL retrieve community submission data from PasCubeDB in a non-blocking background thread, persist it to a local disk cache, hot-reload the parsed community insights when synchronization completes, and parse the full PasCubeDB column schema (including component scores, frequencies, power draw, temperatures, desktop environments, display servers, drivers, and kernels).

#### Scenario: Successful online community data retrieval
- **WHEN** PasCube launches or completes a benchmark run while an internet connection is available
- **THEN** a background synchronization thread queries PasCubeDB, downloads the latest 33-column CSV submission metrics to `~/.cache/goverlay/pascubedb_cache.csv`, and automatically refreshes the active in-memory community analytics without dropping Vulkan frame rate.

#### Scenario: Graceful offline cache fallback
- **WHEN** PasCube runs without an active internet connection or the remote query fails
- **THEN** the system loads the local cached dataset if present, or falls back to an embedded full-schema reference dataset compiled into PasCube without displaying network error popups.

### Requirement: Normal Distribution Curve and Percentile Ranking Computation
The benchmark analytics engine SHALL calculate the Gaussian distribution parameters (mean and standard deviation) and the exact percentile rank of the user's score against all recorded community scores.

#### Scenario: Computing percentile and community position
- **WHEN** a benchmark concludes with a valid main score
- **THEN** the analytics engine evaluates the user's score against the dataset, deriving the community average, standard deviation, and the exact percentile rank (e.g., "Top 22%" / "Supera 78% dos sistemas").

#### Scenario: Visual Gaussian bell curve plotting
- **WHEN** the community distribution slide is displayed
- **THEN** the interface renders an interpolated normal distribution bell curve with a highlighted indicator marking the user's position on the score axis.

### Requirement: Hardware Performance Scaling Multipliers
The analytics engine SHALL compute comparative performance tiers across the PasCubeDB dataset and render a unified full-width visual performance scaling ladder.

#### Scenario: Multiplier calculation against reference hardware
- **WHEN** the performance scaling slide (Slide 5) is active
- **THEN** the system renders a single full-width horizontal performance ladder of 6 ordered tiers (`PasCubeDB #1 Record`, the user's system dynamically positioned in score order, `PasCubeDB Desktop Average`, `Console / PS5 Tier`, `Handheld High Z1E`, and `Steam Deck`), displaying proportional bars, scores, and multiplier badges (`x FASTER` / `BASELINE` / `% OF RECORD`) without multi-line hardware specification walls or bottom verdict banners.

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
The benchmark analytics engine SHALL filter community benchmark submissions to isolate the user's actual detected GPU and CPU models using their respective component scores (`GPU Score` and `CPU Multi`), computing non-inflated model rank, model average, minimum bin, and record scores alongside a Top 4 Same-Silicon Leaderboard for both components side-by-side.

#### Scenario: Evaluating user GPU and CPU against identical silicon
- **WHEN** the silicon lottery slide (Slide 3) is rendered
- **THEN** the system calculates the user's true position among identical GPU and CPU model submissions without artificial record inflation, renders collision-free dispersion spectrum bars (`[YOU: Score]` pin above the bar and `Min`, `Avg`, `Max` below the bar), and fills the lower section of each column with a 4-row horizontal bar leaderboard of top PasCubeDB runs for that exact GPU and CPU model.

### Requirement: Dual GPU and CPU Thermal Headroom and Power Efficiency Analytics
The analytics engine SHALL compute points-per-watt efficiency based on peak power and evaluate thermal margins against hardware throttling limits for both GPU and CPU, presenting a clean visual comparison against PasCubeDB efficiency leaders without static filler telemetry boxes.

#### Scenario: Displaying thermal headroom and points per watt
- **WHEN** the efficiency slide (Slide 4) is active
- **THEN** the system displays a clean two-column layout (GPU Efficiency and CPU Efficiency) featuring a thermal headroom progress gauge (`Peak Temp`, `Headroom`, and `Peak Wattage`) at the top of each column followed by a spacious 5-row horizontal bar chart comparing the user's `pts/W` against real PasCubeDB GPU and CPU efficiency leaders, omitting static voltage/fan/cooler sub-tiles and bottom verdict bars.

### Requirement: Linux Ecosystem Software & Performance Statistics
The Distros slide SHALL display real community adoption shares and average scores from PasCubeDB for Linux distributions, desktop environments, display servers, and graphics stacks without hardcoded baseline delta explanations.

#### Scenario: Displaying Linux ecosystem software insights
- **WHEN** the distros slide (Slide 6) is rendered
- **THEN** the left column displays the top Linux distributions from PasCubeDB with popularity bars (`%`), real average scores, and a `YOUR DISTRO` highlight badge, while the right column renders two clean visual cards: a Desktop Environment popularity ranking (highlighting the user's DE) and segmented visual share bars for Display Server (`Wayland` vs `X11`) and Graphics Stack (`Mesa` vs `NVIDIA`) alongside a concise summary of the user's active software stack.
