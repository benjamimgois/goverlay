# Spec Delta

## ADDED Requirements

### Requirement: Robust shell quoting for opening game and prefix folders
The system SHALL use POSIX-compliant single-quote escaping when invoking external file managers to open game install and wine prefix directories.

#### Scenario: Opening folder for game with apostrophes in directory name
- **WHEN** the user clicks "Open Folder" or "Open Prefix" for a game whose directory path contains an apostrophe or single quote
- **THEN** the path passed to `xdg-open` is escaped with POSIX single-quote escaping (`'\''`) so that the file manager correctly receives and opens the target directory.
