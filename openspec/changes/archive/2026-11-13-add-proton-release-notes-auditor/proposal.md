# Proposal

## Why

Upstream Proton forks (`CachyOS/proton-cachyos` and `GloriousEggroll/proton-ge-custom`) regularly introduce useful environment variables—such as `PROTON_ZLUDA=1` (PhysX support on AMD) and `PROTON_SONY_WINDOWS_DEVICE_NAMES=1`—directly in their GitHub release notes rather than in sample configuration files. Currently, the `goverlay-update-auditor` skill only parses sample config files and checks `releases/latest`, which misses environment variables announced in release notes or in immediately preceding releases when a hotfix is published.

## What Changes

- Register `proton-cachyos` (`CachyOS/proton-cachyos`) and `proton-ge-custom` (`GloriousEggroll/proton-ge-custom`) in `.agent/skills/goverlay-update-auditor/references/repositories.json`, mapped to `tweaks_md3.pas` and `configkeys.pas`.
- Extend `.agent/skills/goverlay-update-auditor/scripts/audit_upstream.py` to support auditing recent GitHub release notes (`releases?per_page=N`, configurable via `--releases`) for tools configured with release-notes environment variable scanning.
- Extract all uppercase environment variables (`PROTON_*`, `WINE_*`, `DXVK_*`, `VKD3D_*`, and other `*_` variables) from release note bodies along with their source release tag and surrounding bullet/line context.
- Normalize `VAR=value` vs `VAR` when comparing extracted variables against `tweaks_md3.pas` and `configkeys.pas` so variables already present in Goverlay's Tweaks section are excluded.
- Render discovered environment variables separated into categorized blocks (`PROTON_*`, `WINE_*`, `DXVK_*`, `VKD3D_*`, and `Other`) in the audit report so the user can review and select which ones to add to the Tweaks section.
- Update `.agent/skills/goverlay-update-auditor/SKILL.md` to document the Proton repositories and the Tweaks triage workflow.

## Capabilities

### New Capabilities
- `upstream-proton-env-audit`: Automated scanning of recent upstream Proton release notes to surface unmapped environment variables grouped into selectable blocks for the Tweaks section.

### Modified Capabilities
<!-- None: existing Goverlay runtime behavior is unchanged; this change extends the upstream update auditor tooling. -->

## Impact

- `.agent/skills/goverlay-update-auditor/references/repositories.json`
- `.agent/skills/goverlay-update-auditor/scripts/audit_upstream.py`
- `.agent/skills/goverlay-update-auditor/SKILL.md`
- No Pascal source files (`*.pas`) are modified by this change; selected variables will be added to Tweaks separately after running the auditor.
