# upstream-proton-env-audit Specification

## Purpose
Audits recent GitHub release notes of upstream Proton repositories (`CachyOS/proton-cachyos` and `GloriousEggroll/proton-ge-custom`) to detect unmapped environment variables and present them grouped into selectable blocks for Goverlay's Tweaks section.

## Requirements

### Requirement: Proton repositories are registered for release-notes auditing
The auditor catalog SHALL include `proton-cachyos` (`CachyOS/proton-cachyos`) and `proton-ge-custom` (`GloriousEggroll/proton-ge-custom`) configured to audit release notes against `tweaks_md3.pas` and `configkeys.pas`.

#### Scenario: Auditing a Proton tool individually
- **WHEN** the user runs the auditor with `--tool proton-cachyos` or `--tool proton-ge-custom`
- **THEN** the auditor queries the corresponding GitHub repository and compares discovered environment variables against `tweaks_md3.pas` and `configkeys.pas`

### Requirement: Multi-release scanning window for release-notes tools
For tools configured with release-notes environment variable auditing, the auditor SHALL inspect the most recent N releases (defaulting to 5, overridable via `--releases`) instead of only `releases/latest`.

#### Scenario: Hotfix release follows a feature release
- **WHEN** the latest release is a small bugfix and an environment variable such as `PROTON_ZLUDA=1` was introduced in an immediately preceding release within the N-release window
- **THEN** the auditor still detects and reports that environment variable along with the release tag where it appeared

### Requirement: Extraction of all environment variables with context
The auditor SHALL scan release note bodies for uppercase environment variables (matching patterns such as `PROTON_*`, `WINE_*`, `DXVK_*`, `VKD3D_*`, and other `*_` environment variables with optional `=value` assignments) and capture the surrounding line or bullet text as context.

#### Scenario: Release note mentions an environment variable in a bullet point
- **WHEN** a release note contains a bullet such as ``These games now default to `PROTON_SONY_WINDOWS_DEVICE_NAMES=1` ``
- **THEN** the auditor extracts `PROTON_SONY_WINDOWS_DEVICE_NAMES` (and its example value) together with the bullet line as context

### Requirement: Normalization against existing Goverlay Tweaks keys
When comparing extracted environment variables against `tweaks_md3.pas` and `configkeys.pas`, the auditor SHALL normalize `VAR=value` and `VAR` to the base variable name (case-insensitively) so variables already implemented in Goverlay are not reported as missing.

#### Scenario: Variable already exists in Tweaks with `=1`
- **WHEN** a release note mentions `PROTON_LOCAL_SHADER_CACHE=1` or `PROTON_LOCAL_SHADER_CACHE` and `tweaks_md3.pas` already defines `'PROTON_LOCAL_SHADER_CACHE=1'`
- **THEN** the auditor treats `PROTON_LOCAL_SHADER_CACHE` as already supported and excludes it from missing variables

### Requirement: Grouped block presentation for user selection
In Markdown output, the auditor SHALL group unmapped environment variables into distinct prefix blocks (`PROTON_*`, `WINE_*`, `DXVK_*`, `VKD3D_*`, and `Other`) showing the variable, release tag, and context so the user can selectively choose which ones to add to Tweaks.

#### Scenario: Rendering unmapped variables across multiple prefixes
- **WHEN** the auditor finds unmapped variables across `PROTON_*` and `DXVK_*` prefixes
- **THEN** the Markdown report renders separate subsections/tables for each non-empty block rather than mixing all variables into a single flat list
