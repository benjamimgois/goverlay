# fix-nonsteam-remove-folders-popup-crash Specification

## Purpose
Ensure crash-free non-Steam folders popup menu execution and allow direct top-level removal of non-Steam folders.

## Requirements

### Requirement: Crash-free non-Steam folders popup menu
The GOverlay interface SHALL display the non-Steam folders removal popup menu without memory allocation crashes (SIGSEGV) when the 3-dots action button on the "Add non-Steam folder" card is clicked.

#### Scenario: Opening non-Steam folders menu multiple times
- **WHEN** user repeatedly opens and clears the non-Steam remove folders menu
- **THEN** GOverlay builds and clears `FRemoveFoldersMenu` without memory double-free crashes or application termination

### Requirement: Direct top-level menu layout for non-Steam folder removal
The non-Steam folders removal popup menu SHALL display configured folders directly as top-level menu items.

#### Scenario: Displaying non-Steam folder paths
- **WHEN** user clicks the 3-dots action button on the "Add non-Steam folder" card
- **THEN** popup menu lists all configured non-Steam folders directly as menu items formatted as `Remove: /path/to/folder`

#### Scenario: Removing unreadable or inaccessible folders
- **WHEN** a folder path in `nonsteam_folders.txt` is inaccessible or non-existent (e.g., due to sandbox permissions)
- **THEN** popup menu still lists the folder path and permits the user to remove it from `nonsteam_folders.txt`
