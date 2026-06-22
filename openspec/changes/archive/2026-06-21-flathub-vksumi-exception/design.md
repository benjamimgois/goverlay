## Context

To run vkSumi in the GOverlay Flatpak sandbox environment, the manifest configuration requests read-write access to the host's `xdg-config/vkSumi` directory:
```yaml
finish-args:
  - --filesystem=xdg-config/vkSumi:rw
```

However, Flathub's automated build linter (`flatpak-builder-lint`) rejects the manifest during deployment verification, returning:
`Error: 'finish-args-unnecessary-xdg-config-vkSumi-rw-access' error found in linter manifest check.`

To allow the build to pass, GOverlay's App ID (`io.github.benjamimgois.goverlay`) needs a linter exception registered in the official Flathub linter repository.

## Goals / Non-Goals

**Goals:**
- Provide a clear, actionable guide and the exact JSON snippet needed to submit the exception request to the official Flathub linter repository.
- Verify the exception configuration using the official schema.

**Non-Goals:**
- Submitting the PR directly to the upstream Flathub repository (since the agent runs in a local environment and cannot log into the user's GitHub to automate pull requests on external repositories).

## Decisions

### Decision 1: Register Exception in flatpak-builder-lint upstream
We will document the exact modification required in the upstream repository `flathub-infra/flatpak-builder-lint` under `flatpak_builder_lint/staticfiles/exceptions.json`.

**Alternatives considered:**
- *Remove vkSumi config access:* This would break vkSumi integration on Flatpak, rendering it unable to read/write settings.
- *Use a local exception file in CI:* Local exceptions only work for local builds and do not bypass Flathub's main build linter when building the release for the Flathub repository.

**Selected Approach:**
Submit a Pull Request to `flathub-infra/flatpak-builder-lint` adding the following entry under `"io.github.benjamimgois.goverlay"` -> `"stable"`:
```json
"finish-args-unnecessary-xdg-config-vkSumi-rw-access": "Needed for reading vkSumi config files"
```

## Risks / Trade-offs

- **Risk:** The Flathub maintainers might reject the exception if they believe the folder is unnecessary or can be handled through another mechanism.
  - **Mitigation:** vkSumi config folder is strictly required for the utility to read/write config files, exactly like MangoHud and vkBasalt, which already have this exception.
