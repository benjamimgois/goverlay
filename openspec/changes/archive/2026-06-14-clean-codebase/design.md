## Context

The GOverlay repository has accumulated a large number of files that are never compiled or referenced. 
- Several forms and helper units created during development are now obsolete:
  - `logpathunit` (logging path form)
  - `customeffectsunit` (vkBasalt custom effects form)
  - `atstringproc_htmlcolor` (string processing for html colors)
  - `fgmod_resources` (legacy launcher installer resource)
  - `gfxlaunch` (unused helper launcher)
- The integrated Vulkan benchmark/preview demo (`pascube`) depends on `pasvulkan` as a submodule-like source directory under `pascube_src/pasvulkan/`. However, `pasvulkan` contains multiple full game development examples, test projects, tools, and heavy libraries (like regular expression engines, RISC-V emulators, and LLM engines) that are completely unrelated to the simple colored spinning cubes benchmark rendering of `pascube`.
- Development helper directories used by LLM tooling (`.agents/`, `.rtk/`) are currently tracked in the repository instead of being ignored.

## Goals / Non-Goals

**Goals:**
- Delete the identified unused units (`logpathunit`, `customeffectsunit`, `atstringproc_htmlcolor`, `fgmod_resources`, `gfxlaunch`) and their associated resources (`.lfm`).
- Remove the unused Vulkan demo projects, tests, tools, and unused external libraries from the codebase.
- Untrack `.agents/` and `.rtk/` directories from Git and add them to `.gitignore`.
- Update the main project configuration `goverlay.lpi` to match the deleted units.
- Ensure the GOverlay application and the PasCube benchmark binary compile cleanly after cleanup.

**Non-Goals:**
- Refactoring the core codebase structure (`overlayunit.pas` monolithic file).
- Deleting core/used parts of the Vulkan engine (like `Vulkan.pas`, `PasVulkan.Framework.pas`, `PasVulkan.SDL2.pas`, etc.) which are required to build the `pascube` binary.
- Modifying any runtime GOverlay functionality or features.

## Decisions

### Decision 1: Complete deletion of unused files
Rather than keeping files commented out or archived in folders, we will completely delete unused units and Lazarus forms.
*Rationale:* Dead code clutter makes it harder for both humans and AI models to understand the codebase. Deletion is clean and easily reversible via Git history if ever needed.

### Decision 2: Remove unused PasVulkan subdirectories
We will delete unused engine subdirectories: `projects/`, `src/tests/`, `src/tools/`, and external library folders (`flre`, `pasllm`, `pasriscv`, `pasterm`, `pinja`, `poca`).
*Rationale:* These directories contain over 1,700 source files (amounting to megabytes of code) that are not included in the SearchPaths of `pascube.lpi` and are entirely unused.

### Decision 3: Clean up and shift unit declarations in `goverlay.lpi`
We will manually remove deleted units from `goverlay.lpi` and re-index the remaining units sequentially (`Unit0` to `Unit12`) to preserve the LCL project file structure.
*Rationale:* This prevents compile errors and keeps the project structure valid for future Lazarus IDE sessions.

### Decision 4: Untrack AI agent files from version control
We will run `git rm -r --cached` on `.agents/` and `.rtk/` and add them to the workspace-level `.gitignore`.
*Rationale:* These folders contain agent context and configurations that are only useful to the AI assistant in the local environment and do not belong in the public source repository.

## Risks / Trade-offs

- **Risk**: Deleting a dependency needed by PasCube.
  - *Mitigation*: The `SearchPaths` in `pascube.lpi` specify only: `src;pasvulkan/src` and specific subfolders of `pasvulkan/externals` (`pucu`, `pasdblstrutils`, `pasmp`, `pasjson`, `kraft`, `rnl`, `pasgltf`). We will preserve these folders and their contents while deleting everything else. We will also run a full compilation with `make` to verify that compiling `pascube` works correctly.
- **Risk**: Lazarus project XML corruption when editing `goverlay.lpi`.
  - *Mitigation*: We will perform a structured modification to keep the XML tags nested correctly and verify that GOverlay compiles cleanly.
