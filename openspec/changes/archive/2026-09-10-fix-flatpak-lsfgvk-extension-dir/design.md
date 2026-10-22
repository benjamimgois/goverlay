## Context

See `proposal.md` for motivation. In Flatpak, when an extension point is declared in `add-extensions`, Bubblewrap mounts the extension at the declared directory path under `/app/` at container startup. Because `/app` is mounted read-only inside the container sandbox, Bubblewrap cannot create non-existent directories on the fly. As established for `MangoHud`, `vkBasalt`, and `vkSumi`, each extension mount point under `/app/lib/extensions/vulkan/` must be pre-created during the package build step.

## Goals / Non-Goals

**Goals:**
- Ensure `/app/lib/extensions/vulkan/lsfgvk` is created during the build of the `goverlay` Flatpak module in both `io.github.benjamimgois.goverlay.nightly.yml` and `io.github.benjamimgois.goverlay.yml`.
- Prevent Bubblewrap `EROFS` failure (`bwrap: Can't mkdir /app/lib/extensions/vulkan/lsfgvk: Read-only file system`) and subsequent `ldconfig` exit code 256.

**Non-Goals:**
- Modifying Pascal source code (already expects `/app/lib/extensions/vulkan/lsfgvk/`).
- Altering the extension point declaration schema or version.

## Decisions

### Decision: Pre-create the directory in `goverlay` build-commands
- **Choice**: Add `mkdir -p /app/lib/extensions/vulkan/lsfgvk` in the build-commands block alongside `MangoHud`, `vkBasalt`, and `vkSumi`.
- **Rationale**: Follows the identical pattern used for other Vulkan layer extensions in the Flatpak manifests.
- **Alternatives Considered**: 
  - Mounting to `/var` or runtime extensions: Rejected because app-scoped Vulkan layers in GOverlay are mounted under `/app/lib/extensions/vulkan/`.

## Risks / Trade-offs

- [Risk: Inconsistency between stable and nightly manifests] → **Mitigation**: Update both `flatpak/io.github.benjamimgois.goverlay.nightly.yml` and `flatpak/io.github.benjamimgois.goverlay.yml` in lockstep.
