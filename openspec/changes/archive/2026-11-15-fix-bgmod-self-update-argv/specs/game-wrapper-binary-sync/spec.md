# Spec Delta

## MODIFIED Requirements

### Requirement: Atomic Replacement and Seamless Re-Execution
The system SHALL replace executing wrapper binaries atomically using temporary files and filesystem renaming to prevent `ETXTBSY` ("Text file busy") errors, and SHALL immediately re-execute the updated `bgmod` binary with all original command-line arguments preserved intact.

#### Scenario: Atomic file update prevents text file busy errors
- **WHEN** `bgmod` replaces a running binary
- **THEN** it copies the master binary to `<binary>.tmp`, sets permissions (`0755`), and renames `<binary>.tmp` over the target binary

#### Scenario: Immediate re-execution with recursion protection
- **WHEN** `bgmod` successfully self-updates before launching the game
- **THEN** it sets an environment variable guard (`BGMOD_UPDATED=1`) and invokes `execv` on `ParamStr(0)` with the original arguments so the game immediately runs under the updated binary without recursion loops

#### Scenario: Multi-argument command line preserved across self-update re-execution
- **WHEN** `bgmod` self-updates while invoked with multiple arguments (such as Steam's `%command%` wrapper chain ending in a `.exe` path)
- **THEN** the re-executed `bgmod` process SHALL receive the exact original `Arg 0` through `Arg N` in order, without any argument being overwritten by the final argument
