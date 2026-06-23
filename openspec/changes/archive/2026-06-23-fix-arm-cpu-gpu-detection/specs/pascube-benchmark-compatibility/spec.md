## ADDED Requirements

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
