## Why

When pushing the new version of GOverlay to Flathub, the build pipeline fails because the manifest now requests access to the `xdg-config/vkSumi` folder (introduced to support vkSumi). Flathub's linter flags this as an unauthorized directory access until an exception is officially added to `flatpak-builder-lint`'s `exceptions.json`.

## What Changes

- Request a linter exception in the upstream `flathub-infra/flatpak-builder-lint` repository to allow GOverlay (`io.github.benjamimgois.goverlay`) to access the `xdg-config/vkSumi` directory in read-write mode.
- Update documentation and specs to guide the user on how to submit the exception request to Flathub.

## Capabilities

### New Capabilities

*None*

### Modified Capabilities

- `vksumi-flatpak`: Update the flatpak specifications and configuration documentation to outline the required Flathub exception for `xdg-config/vkSumi` filesystem access.

## Impact

- No direct impact on the GOverlay codebase itself, but it resolves the CI/CD pipeline blocker on Flathub's side when deploying releases.
