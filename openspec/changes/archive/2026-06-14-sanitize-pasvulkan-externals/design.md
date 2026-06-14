## Context

After removing the main unused Vulkan engine folders, several subfolders and platform-specific precompiled binaries still remain in active dependency directories.
- `pasdblstrutils` contains a large `testdata/` folder (262MB) used for float conversion testing in upstream development.
- `pasgltf` contains precompiled Windows binaries (`bin/`), as well as test viewer projects (`combineanimations`, `smartcombineanimations`, `viewer`).
- `libs/` has precompiled static and dynamic libraries for Windows, macOS, Android, and Linux 32-bit platforms, none of which are used since GOverlay only builds on Linux 64-bit.
- Deleted directories (`flre/`, `pasllm/`, `poca/`) still exist as local untracked directory structures containing compiled artifacts.

## Goals / Non-Goals

**Goals:**
- Completely remove the `pasdblstrutils/testdata/` folder.
- Remove Delphi/FPC projects and compiled viewers from `pasgltf/` (`bin/`, `src/viewer/`, `src/combineanimations/`, `src/smartcombineanimations/`).
- Clean up all platform precompiled libraries under `libs/` except `libktxlinux64` and `sdl20linux64`.
- Delete leftover untracked local directories of deleted libraries (`flre/`, `pasllm/`, `poca/`).
- Ensure both GOverlay and PasCube build successfully and execute on Linux.

**Non-Goals:**
- Removing core source files of active dependencies (e.g., `PasGLTF.pas` or `PasJSON.pas`).
- Changing search paths or compiler configurations in GOverlay/PasCube.

## Decisions

### Decision 1: Safe deletion of testdata and demos
We will completely delete testdata and demo/viewer folders.
*Rationale:* These files are not referenced by any search paths in `pascube.lpi` or unit imports of the active application.

### Decision 2: Retain only Linux 64-bit precompiled libraries
We will delete `libktxwin64/`, `libpngandroid/`, `sdl20android*/`, `sdl20linux32/`, `sdl20macosx*/`, `sdl20win*/` under `libs/`.
*Rationale:* The application is built specifically for Linux 64-bit (x86_64). Keeping binary libs for Windows, macOS, and Android contributes to repository bloat without any purpose.

## Risks / Trade-offs

- **Risk**: Deleting precompiled libraries might break compilation if another target is built.
  - *Mitigation*: GOverlay only targets x86_64 Linux. We will preserve `libktxlinux64/` and `sdl20linux64/`, which are the only ones compiled/linked in this environment. We will verify compile and run tests.
