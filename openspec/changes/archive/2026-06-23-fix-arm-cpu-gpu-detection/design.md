## Context

Mesa's `panvk` Vulkan driver for ARM Mali Bifrost v7 GPUs requires the environment variable `PAN_I_WANT_A_BROKEN_VULKAN_DRIVER=1` to load, otherwise falling back to CPU software rasterization (`llvmpipe`). Additionally, ARM processors do not always present a `model name` line in `/proc/cpuinfo`, resulting in "Unknown CPU".

## Goals / Non-Goals

**Goals:**
- Provide a robust fallback sequence for CPU name detection in PasCube.
- Set the required Mali Bifrost v7 Mesa environment variable at PasCube startup.

**Non-Goals:**
- Porting GOverlay itself to display Mali temperature or thermal stats.

## Decisions

### 1. Robust CPU Name Detection Fallback
- **Approach**: Modify `TPasCubeScreen.GetCPUName` to search for `model name`, then search for `processor`, and then execute `lscpu` to search for `Model name:` case-insensitively using `TProcess`.
- **Alternatives Considered**: Querying device tree files, but `lscpu` is highly standardized across all standard Linux distributions and already handles vendor and part mappings.

### 2. Environment Override for Mesa Mali driver
- **Approach**: Set `PAN_I_WANT_A_BROKEN_VULKAN_DRIVER=1` using `SetEnvironmentVariable` at the top of the main block in `pascube.lpr`.
- **Alternatives Considered**: Prepending it to the execution prefix in GOverlay, but setting it inside `pascube.lpr` ensures that the benchmark binary works correctly whether launched from GOverlay or run standalone.

## Risks / Trade-offs

- **[Risk]** The env var might cause instabilties on broken Mali drivers.
  - *Mitigation*: The warning from Mesa indicates `panvk` is not well-tested on v7, but loading the hardware driver is required to run a GPU stress benchmark instead of using CPU software emulation.
