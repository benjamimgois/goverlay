# Specification: pascube-benchmark-compatibility

## Purpose

Define compatibility requirements for the PasCube Vulkan-based benchmark, ensuring reliable operation across different Linux distributions (including Ubuntu, Bazzite, NixOS) and container environments (Flatpak).

## Requirements

### Requirement: Save and Load Benchmark Results from User Writeable Config Directory
The system MUST save and load the benchmark history to and from the user's config directory (fallback to `/tmp` if `HOME` is empty), ensuring compatibility with read-only installations (AppImage, Flatpak, NixOS read-only store, and system `/usr/` paths).

#### Scenario: Saving results
- **WHEN** the benchmark finishes execution
- **THEN** the system saves `benchmark_results.json` into the writeable config folder.

#### Scenario: Loading results
- **WHEN** the benchmark screen initializes
- **THEN** the system loads the history from `benchmark_results.json` in the writeable config folder.

### Requirement: Query Host OS Name inside Flatpak Sandbox
When executing inside Flatpak, the system MUST retrieve the host OS name by reading `/run/host/etc/os-release` or `/run/host/usr/lib/os-release`.

#### Scenario: Distro detection in flatpak
- **WHEN** queried for OS Name inside Flatpak
- **THEN** the system parses the host OS PRETTY_NAME from the host files.

### Requirement: Safe fallback for config paths
The system MUST NOT hardcode user home paths as default fallbacks when finding directories, utilizing `/tmp` instead.

#### Scenario: Empty HOME environment
- **WHEN** resolving the config directory path and `HOME` environment variable is not defined
- **THEN** the system defaults to `/tmp`.

### Requirement: Fallback validation for 7-Zip commands
The system MUST verify if `7z`, `7zz`, or `7za` is available on the system during CPU benchmarking.

#### Scenario: Spawning compression benchmark
- **WHEN** spawning the CPU benchmark
- **THEN** the system attempts to execute `7z`, falling back to `7zz` and then `7za` depending on system availability.

### Requirement: GPU Signature Acquisition and Fallback
The system MUST retrieve a unique hardware signature based on the primary GPU or fall back to a persistent, randomly generated client-id UUID if GPU information is unavailable.

#### Scenario: NVIDIA GPU with proprietary driver
- **WHEN** executing on a system with an NVIDIA GPU and proprietary drivers installed
- **THEN** the system executes `nvidia-smi --query-gpu=uuid --format=csv,noheader` and retrieves the printed GPU UUID.

#### Scenario: AMD GPU
- **WHEN** executing on a system with an AMD GPU and the file `/sys/class/drm/card0/device/unique_id` exists
- **THEN** the system reads the content of that file to retrieve the GPU unique ID.

#### Scenario: Fallback to persistent client-id UUID
- **WHEN** the primary GPU is Intel/other or retrieving GPU signature fails, and the `client-id` file does not exist in the Goverlay configuration directory
- **THEN** the system generates a random UUID, saves it to the `client-id` file in the Goverlay config directory, and uses it as the hardware signature.

#### Scenario: Using existing persistent client-id UUID
- **WHEN** the primary GPU is Intel/other or retrieving GPU signature fails, and the `client-id` file exists in the Goverlay configuration directory
- **THEN** the system reads the content of the `client-id` file and uses it as the hardware signature.

### Requirement: SHA-256 Hashing of Signature
The system MUST compute the SHA-256 hash of the retrieved hardware signature to produce a unique, anonymous, fixed-length machine hash string.

#### Scenario: Compute machine hash
- **WHEN** a unique hardware signature string is obtained
- **THEN** the system hashes it using the SHA-256 algorithm to generate a 64-character hexadecimal `machine_hash` string.

### Requirement: Enriching Benchmark Submission Payload
The system MUST include the generated `machine_hash` in the benchmark submission JSON payload.

#### Scenario: Submit results with machine hash
- **WHEN** preparing the JSON benchmark submission payload
- **THEN** the system adds the key `"machine_hash"` with the computed SHA-256 hash value to the JSON object before spawning the submission thread.

### Requirement: Display Environment and Runtime Metadata in Submission Confirmation Dialog
The system MUST display the processor architecture, the GOverlay package type, and the total benchmark duration in seconds in the submission confirmation dialog before sending the benchmark results.

#### Scenario: Render confirmation dialog
- **WHEN** the user initiates benchmark result submission
- **THEN** the system displays a confirmation dialog containing CPU architecture, packaging type, and benchmark duration.

### Requirement: Record and Submit Processor Architecture, Packaging Type, and Duration
The system MUST record the CPU architecture, the GOverlay packaging type, and the total duration of the benchmark run in seconds, and transmit these details under the keys `"architecture"`, `"package"`, and `"timer"` in the benchmark results JSON payload during submission.

#### Scenario: Prepare submission payload
- **WHEN** the submission payload is generated after a benchmark run
- **THEN** the system serializes CPU architecture, package type, and timer in seconds into the JSON payload with keys `"architecture"`, `"package"`, and `"timer"`.

### Requirement: ARM CPU name detection fallback
The system MUST fall back to reading the `Processor` field in `/proc/cpuinfo` or executing `lscpu` to search for `Model name:` if the standard `/proc/cpuinfo` `model name` field is missing.

#### Scenario: fallback CPU detection
- **WHEN** `/proc/cpuinfo` lacks a `model name` line
- **THEN** the system parses the `Processor` field or runs `lscpu` to extract the CPU model.

### Requirement: Override environment variable for Mali Bifrost v7 GPU driver
The system MUST set the environment variable `PAN_I_WANT_A_BROKEN_VULKAN_DRIVER=1` at startup to allow the Mali Bifrost v7 driver to load instead of falling back to software `llvmpipe` rendering.

#### Scenario: Mali driver loading override
- **WHEN** the PasCube binary initializes
- **THEN** it sets `PAN_I_WANT_A_BROKEN_VULKAN_DRIVER` to `1` in the environment before Vulkan initialization.

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

### Requirement: Restore render resolution after GPU fallback
When the GPU benchmark falls back to 360p resolution due to low framerate, the system MUST restore the internal render resolution (`fRenderWidth`/`fRenderHeight`) to 1920x1080 after the GPU benchmark phase completes and before entering the results screen phase.

#### Scenario: Resolution restored after 360p fallback
- **WHEN** the GPU benchmark completes at 360p fallback resolution and transitions to the results phase
- **THEN** the render viewport is set to 1920x1080, rendering the results screen at the standard resolution.

