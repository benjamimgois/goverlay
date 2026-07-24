## 1. Update Flatpak Manifests

- [x] 1.1 Add `- --filesystem=/run/media:ro` to `flatpak/io.github.benjamimgois.goverlay.yml` under `finish-args`.
- [x] 1.2 Add `- --filesystem=/run/media:ro` to `flatpak/io.github.benjamimgois.goverlay.nightly.yml` under `finish-args`.

## 2. Verification

- [x] 2.1 Verify YAML syntax of both manifest files.
- [x] 2.2 Run `make test` to ensure build environment and tests pass.
