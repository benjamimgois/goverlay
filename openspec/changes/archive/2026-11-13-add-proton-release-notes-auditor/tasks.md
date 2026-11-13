# Tasks

## 1. Catalog Registration

- [x] 1.1 Add `proton-cachyos` (`CachyOS/proton-cachyos`) and `proton-ge-custom` (`GloriousEggroll/proton-ge-custom`) entries with `"audit_mode": "release_notes_env"` and `goverlay_files` (`tweaks_md3.pas`, `configkeys.pas`) to `.agent/skills/goverlay-update-auditor/references/repositories.json`, and verify valid JSON with `python3 -m json.tool`.

## 2. Release-Notes Env Var Auditing

- [x] 2.1 Add multi-release fetching (`repos/{repo}/releases?per_page={N}`) and CLI flag `--releases` (default `5`) to `.agent/skills/goverlay-update-auditor/scripts/audit_upstream.py`, verifying that `audit_upstream.py --tool proton-cachyos --releases 5 --format json` returns recent releases.
- [x] 2.2 Implement release-notes environment variable extraction (capturing `PROTON_*`, `WINE_*`, `DXVK_*`, `VKD3D_*`, and other `*_` env vars with source release tag and bullet/line context, filtering known non-env constants) and normalized matching (`VAR=value` -> `VAR`) against `extract_goverlay_keys`, verifying that already-supported variables like `PROTON_LOCAL_SHADER_CACHE` are excluded while unmapped ones like `PROTON_SONY_WINDOWS_DEVICE_NAMES` or `PROTON_ZLUDA` are detected.
- [x] 2.3 Update Markdown rendering in `audit_upstream.py` to separate discovered unmapped environment variables into categorized blocks (`PROTON_*`, `WINE_*`, `DXVK_*`, `VKD3D_*`, `Other`) and verify output readability via `python3 .agent/skills/goverlay-update-auditor/scripts/audit_upstream.py --tool proton-cachyos --format markdown` and `--tool proton-ge-custom --format markdown`.

## 3. Skill Documentation & End-to-End Check

- [x] 3.1 Update `.agent/skills/goverlay-update-auditor/SKILL.md` to list `proton-cachyos` and `proton-ge-custom` in the Catalog table and document the Tweaks environment variable triage workflow, verifying all referenced paths and example commands match the implemented script.
- [x] 3.2 Run `python3 .agent/skills/goverlay-update-auditor/scripts/audit_upstream.py --all --format compact` to verify existing config-file tools remain unaffected alongside the new Proton tools.
