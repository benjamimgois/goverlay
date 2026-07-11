## Context

GOverlay manages OptiScaler configuration by writing keys to `OptiScaler.ini` and `fakenvapi.ini`. During startup, a template `fakenvapi.ini` is unconditionally copied over the user's config. Additionally, GOverlay parses the `OptiScaler.ini` case-sensitively and space-sensitively, failing to read keys formatted with spaces or different casing, and creating duplicates.

## Goals / Non-Goals

**Goals:**
- Implement conditional copying of `fakenvapi.ini` during startup initialization and manual updates.
- Refactor the `TConfigFile` key-value matching logic to be case-insensitive and whitespace-insensitive.

**Non-Goals:**
- We are not changing the structure of `goverlay.vars`, `bgmod.conf`, `OptiScaler.ini`, or `fakenvapi.ini`.
- We are not modifying OptiScaler itself or adding new options to the UI.

## Decisions

### Decision 1: Conditional copy of `fakenvapi.ini` in Shell Scripts
In `bgmod_resources.pas` (`InitializeGlobalConfigDirectory`) and `optiscaler_update.pas` (`SyncPristineAssetsTo`), change:
`cp -f "$Source"fakenvapi.ini "$Target"`
to a conditional statement that checks if the file exists at the target location first:
`if [ ! -f "$Target"fakenvapi.ini ]; then cp "$Source"fakenvapi.ini "$Target"; fi` (preserving quoting appropriately).
- **Alternatives Considered**: Using `cp -n` (no-clobber). However, `cp -n` behaves slightly differently on different platforms or versions of `cp`, while standard `[ ! -f ... ]` shell checks are highly portable and reliable.

### Decision 2: Normalize and match keys in `TConfigFile`
In `configfile.pas`, introduce a private helper method `CleanKeyLine` to normalize keys and lines before comparison:
- Strip all whitespaces and tabs.
- Convert characters to lowercase.
Then, in `FindLineIndex` and `FindLineIndexInSection`, compare the normalized line with the normalized prefix.
- **Alternatives Considered**: Regular expressions. Regular expressions would be overkill, slow down parsing, and introduce unnecessary complexity. The proposed custom string stripping function is performant and robust for key-value pair lines.

## Risks / Trade-offs

- **[Risk]** Template updates to `fakenvapi.ini` won't be pushed automatically if the file already exists.
  - *Mitigation*: The user can clean configurations or toggle the OptiScaler option to reset files if needed. The keys used by GOverlay are stable, so templates rarely change.
- **[Risk]** In-place modification of existing key lines in `OptiScaler.ini` might alter formatting of lines written manually by the user.
  - *Mitigation*: GOverlay already overwrites keys when saving, so modifying in-place actually preserves the rest of the file layout better than appending duplicates at the end.
