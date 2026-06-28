## Context

GOverlay currently identifies client benchmark submissions using a SHA-256 hash of the system hardware signature (`GetGoverlayClientID`). To enable leaderboards/Hall of Fame features, users need a way to attach an optional display name (`nickname`) to their telemetry submissions.

## Goals / Non-Goals

**Goals:**
- Provide a simple UI setting in GOverlay to set/update a user nickname.
- Store `nickname` in `goverlay.ini` and reload it on application launch.
- Pass `--nickname "<user_nickname>"` to PasCube / benchmark processes when auto-launching or running benchmarks.

**Non-Goals:**
- Mandatory user registration or cloud authentication.

## Decisions

### Decision 1: Reuse `GetGoverlayClientID` as Primary Identifier
- **Choice**: Keep `client_id` as the unique hardware key and pass `nickname` as an optional display metadata field.
- **Rationale**: Preserves retroactive linkage of past benchmarks submitted by the same system without requiring user migrations.

### Decision 2: Local Storage in `goverlay.ini`
- **Choice**: Store `Nickname` in `goverlay.ini` under `[Global]` section.
- **Rationale**: Follows existing configuration management pattern in `overlay_config.pas`.

## Risks / Trade-offs

- **[Risk] Profanity or long nicknames** → Mitigated by truncating nickname length (max 32 chars) in UI control.
