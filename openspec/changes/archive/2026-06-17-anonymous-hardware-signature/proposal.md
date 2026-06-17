## Why

Benchmark submissions currently lack a reliable, privacy-preserving mechanism to uniquely identify different client machines. Introducing an anonymous and unique hardware signature (`machine_hash`) will help deduplicate and structure benchmark results on the server-side without requiring root privileges or user authentication.

## What Changes

- **Add hardware signature generation**: Retrieve unique GPU-based hardware identifiers (UUID for NVIDIA via `nvidia-smi`, `unique_id` for AMD via `/sys/class/drm/card0/device/unique_id`).
- **Implement fallback uuid**: Generate and persist a random UUID inside a `client-id` configuration file for Intel/other GPUs or when hardware identifiers cannot be retrieved.
- **SHA-256 Hashing**: Compute the SHA-256 hash of the hardware identifier to produce a fixed-length `machine_hash`.
- **Payload enrichment**: Include the computed `machine_hash` in the benchmark submission JSON payload.
- **Fail-safe execution**: Ensure that all hardware signature generation, hashing, and fallback steps handle missing commands, file permission/read errors, or empty inputs gracefully without breaking the benchmark submission.

## Capabilities

### New Capabilities
- `anonymous-hardware-signature`: Ability to retrieve unique hardware/client signatures, compute their SHA-256 hash, and include the resulting `machine_hash` in the benchmark JSON submission payload.

### Modified Capabilities

## Impact

- `pascube_src/src/UnitPasCubeScreen.pas`: Modify benchmark payload generation in `TPasCubeScreen.SubmitBenchmarkResults` to compute the hardware signature and include it as `machine_hash`.
- Configuration folder (e.g., `~/.config/goverlay/`): Persist the fallback `client-id` file.
