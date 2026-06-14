## Why

The GOverlay codebase has accumulated unused units, outdated files, forms, and massive demo/example folders in the PasVulkan engine that are never compiled or used. This clutter increases repository size, slows down search/indexing tools, and complicates code navigation. A sanitization is needed to clean up the repository, reduce its footprint, and remove untracked or incorrectly tracked AI-agent-specific tooling files.

## What Changes

- **Codebase Sanitization / Removals**:
  - Delete unused Lazarus form units and their resources:
    - `logpathunit.pas` and `logpathunit.lfm`
    - `customeffectsunit.pas` and `customeffectsunit.lfm`
  - Delete unused code units:
    - `atstringproc_htmlcolor.pas`
    - `fgmod_resources.pas` (remnant of legacy bash-based launcher)
    - `gfxlaunch.pas`
  - Remove all demo projects, tests, tools, and unused external libraries from the Vulkan engine under `pascube_src/pasvulkan/`:
    - Delete unused external library directories: `flre`, `pasllm`, `pasriscv`, `pasterm`, `pinja`, `poca`
    - Delete unused projects: `projects/examples`, `projects/consoleexample`, `projects/gltfviewer`, `projects/physics2dtest`, `projects/pocaexample`, `projects/sdfmeshgen`, `projects/supercubi`, `projects/template`
    - Delete unused engine tools: `src/tools/`
    - Delete unused engine tests: `src/tests/`
- **Project Files Modification**:
  - Update `goverlay.lpi` to remove references to the deleted units (`logpathunit.pas`, `customeffectsunit.pas`, and `atstringproc_htmlcolor.pas`) and update the units count accordingly to keep it sequential and correct.
- **AI Agent Tooling Ignored / Untracked**:
  - Untrack `.agents/` and `.rtk/` directories from version control and ensure they are added to `.gitignore`.

## Capabilities

### New Capabilities

- `codebase-sanitization`: Clean up all unused forms, code files, Vulkan demos/unused libraries, and AI agent artifacts to minimize codebase footprint.

### Modified Capabilities

None.

## Impact

- **Affected Code**: `goverlay.lpi` project file.
- **Repository Size**: Significant reduction in git repository size and file count (removing over 1,700 unused Vulkan-related source and demo files).
- **Tooling**: AI-agent directories will be cleaned up and ignored, keeping the repository cleaner for future development.
