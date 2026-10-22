## 1. Flatpak Manifest Updates

- [x] 1.1 Add `mkdir -p /app/lib/extensions/vulkan/lsfgvk` to `flatpak/io.github.benjamimgois.goverlay.nightly.yml` and verify syntax
- [x] 1.2 Add `mkdir -p /app/lib/extensions/vulkan/lsfgvk` to `flatpak/io.github.benjamimgois.goverlay.yml` and verify syntax

## 2. Verification

- [x] 2.1 Verify all extension entries in `add-extensions` have corresponding `mkdir -p` mount points created in both manifests
- [x] 2.2 Run test suite to verify no regressions
