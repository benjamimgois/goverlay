## ADDED Requirements

### Requirement: Remove unused forms and code files
The system SHALL not contain the unused Lazarus units `logpathunit.pas`, `logpathunit.lfm`, `customeffectsunit.pas`, `customeffectsunit.lfm`, `fgmod_resources.pas`, `gfxlaunch.pas`, and `atstringproc_htmlcolor.pas`.

#### Scenario: Verify files deletion
- **WHEN** checking the repository filesystem
- **THEN** the specified unused units, code files, and form files MUST NOT exist.

### Requirement: Remove unused Vulkan engine components
The system SHALL not contain unused Vulkan engine demo projects, tools, tests, or unused external libraries under `pascube_src/pasvulkan/`.

#### Scenario: Verify Vulkan engine cleanup
- **WHEN** checking folders inside `pascube_src/pasvulkan/`
- **THEN** the directories `projects/`, `src/tests/`, `src/tools/`, and external library folders `externals/flre`, `externals/pasllm`, `externals/pasriscv`, `externals/pasterm`, `externals/pinja`, and `externals/poca` MUST NOT exist.

### Requirement: Clean project units configuration
The main Lazarus project file `goverlay.lpi` SHALL NOT list the deleted units `logpathunit.pas`, `customeffectsunit.pas`, and `atstringproc_htmlcolor.pas` in its `<Units>` section.

#### Scenario: Verify project file clean compilation
- **WHEN** compiling the project with `make`
- **THEN** the compilation MUST complete successfully without missing unit errors.

### Requirement: Keep AI agent artifacts out of repository
The system SHALL ignore `.agents/` and `.rtk/` directories in `.gitignore`, and they SHALL NOT be tracked in Git.

#### Scenario: Verify agent files ignored
- **WHEN** running `git ls-files` or `git status`
- **THEN** files under `.agents/` and `.rtk/` MUST NOT be tracked by version control or listed as untracked files.
