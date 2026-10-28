# Spec Delta

## ADDED Requirements

### Requirement: Sensitive launch argument redaction in diagnostic logs
The `bgmod` wrapper SHALL detect and redact sensitive arguments (including authentication passwords, login tokens, exchange codes, and account IDs) before writing launch arguments to `/tmp/bgmod.log` and central log files.

#### Scenario: Epic Games launch with exchange code and auth password
- **WHEN** a game is launched with parameters containing `-AUTH_PASSWORD=<secret>` or `-epicuserid=<id>`
- **THEN** `bgmod` logs the argument with the sensitive value replaced by `[REDACTED]` (e.g. `Arg X: -AUTH_PASSWORD=[REDACTED]`), ensuring plaintext credentials are not written to `/tmp/bgmod.log` or central log files.

#### Scenario: General parameters preserved intact
- **WHEN** a game is launched with standard non-sensitive flags and paths (such as `-dx12`, `-novid`, `-high`, or executable paths)
- **THEN** `bgmod` logs these arguments verbatim without modification.
