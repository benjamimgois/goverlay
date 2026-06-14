## Context

The `pasvulkan` framework embedded inside GOverlay contains several third-party external dependencies in `pascube_src/pasvulkan/externals/` that are not compiled or referenced by `pascube`. Specifically, `kraft`, `pasgltf`, `rnl`, `pasterm`, and `pinja` are completely unused by the benchmark and occupy ~11.3MB of disk space.

## Goals / Non-Goals

**Goals:**
- Remove the unused external library source directories: `kraft/`, `pasgltf/`, `rnl/`, `pasterm/`, `pinja/`.
- Clean up the compiler search paths in `pascube_src/pascube.lpi` to remove references to the deleted libraries.
- Verify that GOverlay and PasCube compile successfully after these cleanups.

**Non-Goals:**
- Deleting the active, used external libraries: `pucu/`, `pasdblstrutils/`, `pasmp/`, and `pasjson/`.

## Decisions

### Decision 1: Delete the unused external folders
- **Rationale**: Smart compilation in Free Pascal naturally ignores these source files because no active application units import them. Deleting the directories frees up space without impact.

### Decision 2: Remove deleted search paths from `pascube_src/pascube.lpi`
- **Rationale**: Removing `pasvulkan/externals/kraft/src`, `pasvulkan/externals/rnl/src`, and `pasvulkan/externals/pasgltf/src` from the compiler search paths ensures the IDE and compiler don't complain about missing directories.

## Risks / Trade-offs

- **[Risk]** Missing search paths leading to build failures.
  - *Mitigation*: We've checked all compiled units in `pascube_src/lib/x86_64-linux/` and confirmed that none of these external libraries are compiled or referenced by units used in `pascube`. We'll verify with a full `make clean && make` check.
