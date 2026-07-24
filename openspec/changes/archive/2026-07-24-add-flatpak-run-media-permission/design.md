## Context

Flatpak applications run in isolated sandboxes. Access to host filesystem paths outside `$HOME` requires explicit `--filesystem` declarations in `finish-args`.
Linux udisks2 mounts removable media (USB drives, SD cards, external NVMe drives) at `/run/media/$USER/<Label_or_UUID>`.

## Goals / Non-Goals

**Goals:**
- Include `- --filesystem=/run/media:ro` in both `flatpak/io.github.benjamimgois.goverlay.yml` and `flatpak/io.github.benjamimgois.goverlay.nightly.yml`.

**Non-Goals:**
- Granting write access to `/run/media`.

## Decisions

### Decision 1: Read-only access to `/run/media`
Read-only access (`:ro`) is sufficient for GOverlay to read game executables, Steam appmanifest files, and library directories without requesting broad write access to host external storage.
