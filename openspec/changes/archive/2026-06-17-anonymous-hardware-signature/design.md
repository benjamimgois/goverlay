## Context

Currently, benchmark submissions to the Google Sheets backend cannot be distinguished or deduplicated. This change adds an anonymous and unique hardware signature (`machine_hash`) based on the system's primary GPU, or a persistent fallback UUID generated on first run.

## Goals / Non-Goals

**Goals:**
- Uniquely and anonymously identify machines submitting benchmark results.
- Implement primary GPU identification for NVIDIA (using `nvidia-smi`) and AMD (reading `/sys/class/drm/card0/device/unique_id`).
- Implement persistent fallback to a random UUID stored in the Goverlay configuration directory.
- Perform SHA-256 hashing on the retrieved signature to hide the original raw identifier.
- Maintain error/exception boundary safety so that benchmark submission never breaks.

**Non-Goals:**
- Implementing user authentication, registration, or login.
- Requesting root/sudo access or using kernel-level hooks.

## Decisions

### GPU Identifier Extraction
- **NVIDIA**: Execute `nvidia-smi --query-gpu=uuid --format=csv,noheader` via `TProcess`.
- **AMD**: Read `/sys/class/drm/card0/device/unique_id` directly using `TStringList` or file read functions.
- **Intel / Other / Fallback**: Store a randomly generated UUID in `GetAppConfigDir(false) + '/client-id'`.

### SHA-256 Hashing
- Run `sha256sum` via `TProcess` using the standard input stream to pass the signature and capture the computed hash from standard output.
- Fallback: If `sha256sum` execution fails, return a fallback value or the original string to ensure the payload is still populated.

## Risks / Trade-offs

- **Risk**: Missing dependencies (e.g. `nvidia-smi` or `sha256sum` not present).
  - *Mitigation*: Run all subprocesses inside `try-except` blocks. If any command fails, fall back to the next method (AMD file, then UUID file, and finally a default hash).
- **Risk**: Flatpak sandbox path restrictions when accessing host GPU paths or `GetAppConfigDir`.
  - *Mitigation*: Goverlay and PasCube run with access to home/config paths. The `/sys/class` path is standard for GPU access and typically accessible inside Flatpaks.
