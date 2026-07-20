## Why

Multiple security vulnerabilities have been identified in the Python packages (`pillow` and `pytest`) used by the GOverlay E2E integration test suite, triggering several high and medium severity GitHub Dependabot alerts. Updating these dependencies mitigates security risks in our test runner environment and resolves the alerts.

## What Changes

- Update `pillow` from version `10.3.0` to `12.2.0` in `tests/requirements.txt` to fix vulnerabilities `CVE-2026-25990` and `CVE-2026-40192`.
- Update `pytest` from version `8.2.2` to `9.0.3` in `tests/requirements.txt` to fix vulnerability `CVE-2025-71176`.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- e2e-gui-testing: Added requirement for secure Python testing dependencies.

## Impact

This is a developer-facing change targeting test environment dependencies. The core GOverlay Pascal application and production builds are completely unaffected. End-to-end integration tests (`tests/run_e2e_tests.py`) will run using the updated package versions.
