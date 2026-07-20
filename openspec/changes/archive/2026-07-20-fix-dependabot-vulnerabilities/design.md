## Context

The `tests/requirements.txt` file pins Python dependencies for the GOverlay integration test suite. Dependabot has flagged vulnerabilities in the currently pinned versions:
- `pillow==10.3.0` contains a high-severity out-of-bounds write in PSD loading (CVE-2026-25990) and a high-severity decompression bomb vulnerability in FITS (CVE-2026-40192).
- `pytest==8.2.2` contains a medium-severity temporary directory vulnerability (CVE-2025-71176).

## Goals / Non-Goals

**Goals:**
- Upgrade `pillow` dependency to `12.2.0` to resolve CVE-2026-25990 and CVE-2026-40192.
- Upgrade `pytest` dependency to `9.0.3` to resolve CVE-2025-71176.
- Ensure end-to-end integration tests execute successfully with the new package versions.

**Non-Goals:**
- Upgrading other python dependencies that do not have active security alerts.
- Making modifications to the Pascal codebase.

## Decisions

### Pinned vs Permissive Versioning
We will use exact pinned versions (`pytest==9.0.3` and `pillow==12.2.0`) in `tests/requirements.txt` rather than permissive version ranges. This ensures reproducible and predictable test runs in developer setups and CI environments.

## Risks / Trade-offs

### API Incompatibilities in `pytest` / `pillow`
- **Risk**: Upgrading `pytest` across a major version (8.x to 9.x) or `pillow` (10.x to 12.x) could introduce deprecations or API breakages in the integration test suite (`tests/run_e2e_tests.py`).
- **Mitigation**: Run the E2E integration test suite locally to verify tests run and pass without failures before finalizing the change.
