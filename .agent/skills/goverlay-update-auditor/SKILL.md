---
name: goverlay-update-auditor
description: >-
  Audits upstream GitHub repositories for tools integrated with Goverlay (MangoHud, vkBasalt, OptiScaler, MAKO, LSFG-VK, AFMF, ReShade, etc.).
  Identifies new versions, breaking changes, deprecated syntax, and new configuration options that require new UI controls or backend adjustments in Goverlay.
---

# Goverlay Upstream Update Auditor Skill

Use this skill whenever checking upstream repositories for updates, investigating new releases of tools bundled/configured by Goverlay, or reconciling Goverlay UI controls with new features in external tools.

## Objectives

1. **Monitor & Audit Upstream Repositories**:
   - Query GitHub releases, tags, commits, and release notes for all tools integrated with Goverlay.
2. **Detect New Configuration Options**:
   - Parse upstream sample configuration files (e.g. `data/MangoHud.conf`, `OptiScaler.ini`, `mako.toml`, etc.) and compare them against keys in `configkeys.pas` and Goverlay UI handlers.
3. **Identify Breaking Changes & Deprecations**:
   - Scan release notes for flags such as deprecated keys, changed syntax, renamed options, or requirements (e.g., Vulkan layers, Proton versions, Mesa requirements).
4. **Formulate Concrete Goverlay Implementation Steps**:
   - Determine which Pascal units (`mangohud_ui.pas`, `optiscaler_tab.pas`, `lossless_scaling_tab.pas`, `vkbasalt_tab.pas`, `tweaks_md3.pas`, `configkeys.pas`, etc.) need updates.
   - Propose UI widget types (e.g., `TToggleSwitch`, `TSpinEdit`, `TComboBox`, `TTrackBar`) and placement adhering to Goverlay's MD3 dark/light design system.

---

## Catalog of Integrated Tools

The repository catalog is defined in [`references/repositories.json`](./references/repositories.json):

| Tool ID | Tool Name | Upstream Repository | Goverlay Files |
| :--- | :--- | :--- | :--- |
| `mangohud` | MangoHud | `flightlessmango/MangoHud` | `mangohud_ui.pas`, `configkeys.pas`, `overlay_config.pas` |
| `optiscaler` | OptiScaler | `optiscaler/OptiScaler` | `optiscaler_tab.pas`, `optiscaler_update.pas`, `configkeys.pas` |
| `fakenvapi` | FakeNvapi | `optiscaler/fakenvapi` | `optiscaler_tab.pas`, `configkeys.pas` |
| `optipatcher` | OptiPatcher | `optiscaler/OptiPatcher` | `optiscaler_tab.pas`, `optiscaler_update.pas` |
| `mako` | MAKO | `eugeniosegala/MAKO` | `lossless_scaling_tab.pas`, `constants.pas` |
| `lsfg-vk` | LSFG-VK | `PancakeTAS/lsfg-vk` | `lossless_scaling_tab.pas`, `constants.pas` |
| `afmf-linux` | AFMF Linux | `serialexperimentslainnnn/afmf-linux` | `lossless_scaling_tab.pas`, `constants.pas` |
| `helixsr` | HelixSR | `lonewolf0622/HelixSR` | `optiscaler_tab.pas`, `helixsr_license_dialog.pas` |
| `vkbasalt` | vkBasalt | `DadSchoorse/vkBasalt` | `vkbasalt_tab.pas`, `configkeys.pas` |
| `vksumi` | vkSumi | `reakjra/vkSumi` | `vkbasalt_tab.pas`, `constants.pas` |
| `reshade` | ReShade | `crosire/reshade` | `reshade_tab.pas`, `constants.pas` |
| `gamemode` | GameMode | `FeralInteractive/gamemode` | `tweaks_md3.pas`, `configkeys.pas` |
| `protontricks`| Protontricks| `Matoking/protontricks` | `protontricksunit.pas`, `constants.pas` |
| `proton-cachyos`| Proton-CachyOS| `CachyOS/proton-cachyos` | `tweaks_md3.pas`, `configkeys.pas` |
| `proton-ge-custom`| Proton-GE| `GloriousEggroll/proton-ge-custom` | `tweaks_md3.pas`, `configkeys.pas` |
| `replaysorcery`| ReplaySorcery| `matanui159/ReplaySorcery` | `overlayunit.pas`, `constants.pas` |

---

## Workflow: How to Run the Audit

### Step 1: Run the Automated Audit Script

Execute the Python auditor helper to gather real-time intelligence from GitHub:

```bash
# Audit a single tool (e.g. MangoHud)
python3 .agent/skills/goverlay-update-auditor/scripts/audit_upstream.py --tool mangohud --format markdown

# Audit Proton release notes across the last 10 releases (grouped by env var prefix)
python3 .agent/skills/goverlay-update-auditor/scripts/audit_upstream.py --tool proton-cachyos --releases 10 --format markdown
python3 .agent/skills/goverlay-update-auditor/scripts/audit_upstream.py --tool proton-ge-custom --releases 5 --format markdown

# Audit all tools in compact mode
python3 .agent/skills/goverlay-update-auditor/scripts/audit_upstream.py --all --format compact

# Export complete markdown report
python3 .agent/skills/goverlay-update-auditor/scripts/audit_upstream.py --all --format markdown --output /tmp/goverlay_audit.md
```

### Step 2: Deep-Dive into Release Notes & Commits

For any tool reporting `ATTENTION_REQUIRED` or `NEW_OPTIONS_AVAILABLE`:
1. Use `gh api repos/<owner>/<repo>/releases/latest` to read the full markdown release notes.
2. Inspect the upstream sample config file or documentation to understand each new option's data type, valid range/enum values, and default behavior.
3. Cross-reference with Goverlay's current implementation in `configkeys.pas` and the respective UI tab unit.

### Step 3: Triage & Classify Findings

Classify each finding according to its impact:

- **Type A: Critical Breaking Changes / Compatibility Regressions**:
  - Deprecated syntax in config files (e.g., options dropped or renamed).
  - New DLL naming conventions or environment variables needed for Wine/Proton.
  - Action: Immediately update the config reader/writer in `configmanager.pas`, `overlay_config.pas`, or launch script generators (`bgmod.lpr` / `configkeys.pas`).

- **Type B: New Upstream Configuration Options**:
  - New metrics or graphs in MangoHud (e.g., `vulkan_present_mode`, `fps_sampling_period`).
  - New toggles in OptiScaler (e.g., `Fsr4ForceEnableInt8`, `Fsr4EnableWatermark`).
  - New scaling/framegen controls in MAKO or LSFG-VK.
  - New Proton/Wine/DXVK/VKD3D environment variables discovered in `proton-cachyos` or `proton-ge-custom` release notes (grouped into `PROTON_*`, `WINE_*`, `DXVK_*`, `VKD3D_*`, and `Other` blocks for selective addition to the Tweaks tab in `tweaks_md3.pas`, `configkeys.pas`, and `hintsunit.pas`).
  - Action:
    1. Define key constant in `configkeys.pas`.
    2. Add parsing and serialization in the respective config loader/saver.
    3. Add UI control (`TToggleSwitch`, `TComboBox`, `TSpinEdit`) following Goverlay's Material Design 3 guidelines.

- **Type C: Version Bumps & Download URLs**:
  - Upstream tarball URL changes or new release assets.
  - Action: Update `constants.pas` (e.g. `FALLBACK_RESHADE_VERSION`, `URL_*_TARBALL`).

---

## Guidelines for Implementing GUI Controls in Goverlay

When designing new controls for discovered options:
1. **LCL Qt5/Qt6 Compatibility**:
   - Ensure controls work identically under Qt5 and Qt6 interfaces.
   - Use `TToggleSwitch` for boolean toggles in modern MD3 sections.
   - Use `TComboBox` with `csDropDownList` for enumerated choices (e.g. preset modes, upscaler selection).
   - Use `TSpinEdit` with appropriate `MinValue`, `MaxValue`, and `Increment` for integer limits.
2. **Localization & Tooltips**:
   - Add tooltips via `hintsunit.pas` to explain the new option clearly to users.
   - Add user-facing strings to `goverlay_strings.pas` if applicable.
3. **OpenSpec Proposal**:
   - For multi-file changes or major feature additions, use the OpenSpec workflow (`opsx propose`) before applying modifications.
