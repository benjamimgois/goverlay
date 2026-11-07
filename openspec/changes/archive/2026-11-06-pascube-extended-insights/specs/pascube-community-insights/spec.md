# Spec Delta

## MODIFIED Requirements

### Requirement: Hardware Performance Scaling Multipliers
The analytics engine SHALL compute comparative speedup multipliers relative to prominent mobile/handheld devices and relative to prominent desktop tiers and console baselines (High-End Gamer PC, Mid-Range Gamer PC, and PlayStation 5 Base).

#### Scenario: Multiplier calculation against reference hardware
- **WHEN** the performance scaling slide is active
- **THEN** the system calculates and displays the user's performance speedup multipliers compared to handhelds (Steam Deck, ROG Ally X, Nintendo Switch 2) and comparative fractions/multipliers against High-End Gamer PC, Mid-Range Gamer PC, and PlayStation 5 Base console.

## ADDED Requirements

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
