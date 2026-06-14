## Context

The `pasvulkan` framework inside GOverlay includes 255 unused Pascal source files in `pascube_src/pasvulkan/src/` that are not compiled or referenced by `pascube` (such as the entire `Scene3D` renderer, RISC-V emulator, command-line tools, and deprecated ECS systems). Removing them clean up the codebase and reduces repository size.

## Goals / Non-Goals

**Goals:**
- Delete all 255 unused Pascal files.
- Verify that GOverlay and PasCube build successfully after these deletions.

**Non-Goals:**
- Deleting any used/compiled files, such as `PasVulkan.Framework.pas`, `PasVulkan.Application.pas`, `PasVulkan.Canvas.pas`, etc.

## Decisions

### Decision 1: Delete all unused source files and directories
- **Rationale**: Smart compilation in Free Pascal naturally ignores these files because no active application units import them. Deleting the directories and files frees up space without impact.
- **Directories to delete**:
  - `pascube_src/pasvulkan/src/tools/`
  - `pascube_src/pasvulkan/src/old/`
- **Files/patterns to delete**:
  - `pascube_src/pasvulkan/src/PasVulkan.Scene3D*`
  - `pascube_src/pasvulkan/src/PasVulkan.FileFormats*`
  - `pascube_src/pasvulkan/src/PasVulkan.VirtualReality*`
  - `pascube_src/pasvulkan/src/PasVulkan.Audio.FlexibleWavelet*`
  - `pascube_src/pasvulkan/src/PasVulkan.BVH*`
  - `pascube_src/pasvulkan/src/PasVulkan.Geometry*`
  - `pascube_src/pasvulkan/src/PasVulkan.Hash*`
  - Other individual unused units listed in tasks.md.

## Risks / Trade-offs

- **[Risk]** Build failures due to missing units.
  - *Mitigation*: We've checked all compiled units in `pascube_src/lib/x86_64-linux/` and confirmed that none of these files are compiled or referenced by units used in `pascube`. We'll verify with a full `make clean && make` check.
