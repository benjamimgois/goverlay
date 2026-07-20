## Context

The OptiScaler stable channel manifest specifies versions with a `stable-` prefix (e.g. `stable-0.9.4`). During normalization in `optiscaler_update.pas` (`TOptiUpdateThread.SyncUpdateUI`), hifens are replaced with dots, transforming the tag into `stable.0.9.4`. 

Currently, GOverlay only strips the `edge.` prefix, leaving `stable.0.9.4` intact. When compared against a clean local version (e.g., `0.9.3.0`), the version comparison function parses the non-numeric "stable" text as `0`, matching the major version `0` of the local installation, and then incorrectly decides the remote version (`0` minor) is older than the installed version (`9` minor).

## Goals / Non-Goals

**Goals:**
- Strip the `stable.` prefix during version normalization in `optiscaler_update.pas`.
- Fix the stable channel update notification for OptiScaler.

**Non-Goals:**
- Changing how the remote manifest builds version tags.
- Modifying the generic `CompareVersions` function.

## Decisions

### Decision: Handle `stable.` prefix in `SyncUpdateUI` normalization
We will add checks for `stable.` prefix and strip it when normalizing `NormLatest` and `NormCurrent` version strings, identical to how `edge.` is handled.
- **Why**: Keep the comparison strictly numeric by removing non-numeric channel prefixes.
- **Alternative**: Change the manifest version names. Rejected because the remote repository manifest structure is outside of GOverlay's direct local scope and might be used by other installers.

## Risks / Trade-offs

- **Risk**: A future version starting with `stable.` or `edge.` might be parsed incorrectly if it's actually part of the version string (unlikely).
  - *Mitigation*: Ensure standard semantic versioning syntax (e.g., `X.Y.Z`) is always expected after stripping.
