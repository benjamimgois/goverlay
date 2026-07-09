## ADDED Requirements

### Requirement: Unreal Engine game folder resolution in bgmod
The `bgmod` launcher wrapper and `bgmod-uninstaller` SHALL resolve the game's binaries directory for Unreal Engine games by searching for subfolders containing `Binaries/Win64` while ignoring standard engine/system utility folders named `ENGINE`, `BUGREPORTCLIENT`, and `CRASHREPORTCLIENT` (case-insensitively).

#### Scenario: Game directory resolved with utility folders present
- **WHEN** the game directory contains subfolders named `BugReportClient`, `Engine`, and `RogueCore`, and `RogueCore` has a `Binaries/Win64` subfolder containing the game executable
- **THEN** the system ignores `BugReportClient` and `Engine`, recursively enters `RogueCore`, and resolves the target game directory as `RogueCore/Binaries/Win64`.
