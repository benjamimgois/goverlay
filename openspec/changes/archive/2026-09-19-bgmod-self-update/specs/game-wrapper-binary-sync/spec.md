# Spec Delta: game-wrapper-binary-sync

## ADDED Requirements

### Requirement: Runtime Wrapper Binary Self-Update
The `bgmod` wrapper executable SHALL inspect candidate master binary directories upon game launch and automatically synchronize local wrapper executables (`bgmod`, `bgmod-uninstaller`, `bgmod-splash`) in the active game configuration folder when a newer or modified master binary is detected.

#### Scenario: Self-update when newer system master binary exists
- **WHEN** `bgmod` is executed from a game configuration folder and a system master binary (`/usr/libexec/goverlay/bgmod`, `/usr/lib/goverlay/bgmod`, `/usr/local/libexec/goverlay/bgmod`, or Flatpak host path) exists with a newer modification time or differing file size compared to `ParamStr(0)`
- **THEN** `bgmod` replaces its own binary, `bgmod-uninstaller`, and `bgmod-splash` with the master copies and sets execution permissions (`0755`)

#### Scenario: Self-update when user template cache is newer
- **WHEN** no newer system master is found, but the user template cache `~/.local/share/goverlay/bgmod/bgmod` exists and has a newer modification time or differing size than the active game wrapper
- **THEN** `bgmod` updates the game configuration binaries from the user template cache

#### Scenario: Bypass update when wrapper is up to date
- **WHEN** the running `bgmod` matches the modification time and size of the master binary (or no master candidate is found)
- **THEN** `bgmod` skips the update process and proceeds directly with game execution

### Requirement: Atomic Replacement and Seamless Re-Execution
The system SHALL replace executing wrapper binaries atomically using temporary files and filesystem renaming to prevent `ETXTBSY` ("Text file busy") errors, and SHALL immediately re-execute the updated `bgmod` binary with the original command-line arguments.

#### Scenario: Atomic file update prevents text file busy errors
- **WHEN** `bgmod` replaces a running binary
- **THEN** it copies the master binary to `<binary>.tmp`, sets permissions (`0755`), and renames `<binary>.tmp` over the target binary

#### Scenario: Immediate re-execution with recursion protection
- **WHEN** `bgmod` successfully self-updates before launching the game
- **THEN** it sets an environment variable guard (`BGMOD_UPDATED=1`) and invokes `fpexecv` on `ParamStr(0)` with the original arguments so the game immediately runs under the updated binary without recursion loops
