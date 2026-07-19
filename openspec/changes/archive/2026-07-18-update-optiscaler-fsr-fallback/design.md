## Context

When GOverlay initializes or updates OptiScaler, it retrieves version information from the remote `vars.txt` file. If the network call fails, or during initial setup, it falls back to hardcoded version strings. The current fallback for FSR Stable is still set to "4.1" in the Pascal source code, but the latest stable release (v0.9.4) ships with FSR version 4.1.1.

## Goals / Non-Goals

**Goals:**
- Update the FSR stable version fallback from `'4.1'` to `'4.1.1'` in the source code.

**Non-Goals:**
- Removing the remote `vars.txt` dynamic checking entirely.

## Decisions

### Decision 1: Update hardcoded FSR stable version fallbacks
- **Choice**: Replace `FsrStableVal := '4.1';` with `FsrStableVal := '4.1.1';` in the update and auto-install paths inside `optiscaler_update.pas`.
- **Rationale**: Having the default fallback match the actual shipped version (4.1.1) prevents displaying incorrect status values if the remote configuration check fails or is delayed.
