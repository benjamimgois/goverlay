# low-latency-dependency Specification

## Purpose
Verifies the presence and displays the status of the Vulkan input latency reduction layer (vulkan-low-latency-layer).
## Requirements
### Requirement: Low Latency Layer Detection
The system MUST check for the presence of the Vulkan low latency layer on the host system to determine if the dependency is met.

#### Scenario: Layer config file exists in system path
- **WHEN** `/usr/share/vulkan/implicit_layer.d/low_latency_layer.json` exists on disk
- **THEN** the low latency layer dependency check passes.

#### Scenario: Layer config file exists in etc path
- **WHEN** `/etc/vulkan/implicit_layer.d/low_latency_layer.json` exists on disk
- **THEN** the low latency layer dependency check passes.

#### Scenario: Layer config file exists in user local path
- **WHEN** the user's local directory `~/.local/share/vulkan/implicit_layer.d/low_latency_layer.json` exists on disk
- **THEN** the low latency layer dependency check passes.

#### Scenario: Layer shared library is available
- **WHEN** the shared library `libVkLayer_KORTHOS_LowLatency` is loaded or available on the library search path
- **THEN** the low latency layer dependency check passes.

#### Scenario: Dependency is missing
- **WHEN** none of the JSON configuration files or the shared library can be located
- **THEN** the dependency is marked as missing.

### Requirement: Home Tab Dependency Presentation
The system MUST render the status of the Vulkan low latency layer on the Home page.

#### Scenario: Rendering the dependency on Home page
- **WHEN** the Home tab is created and updated
- **THEN** it renders a status dot and the name "Korthos low latency" at index 6 of the dependency list in a 3x3 grid layout with the hint "Vulkan Low Latency layer — latency reduction layer".

