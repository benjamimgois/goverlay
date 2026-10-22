## ADDED Requirements

### Requirement: Proactive Steam beta branch modal notice
The system SHALL display an informative modal notice with visual instructions whenever the user selects `lsfg-vk` as the interpolation method and `lsfg-vk.dll` is not detected in the Steam installation directory.

#### Scenario: User selects lsfg-vk with missing beta DLL and notice not suppressed
- **WHEN** user clicks or selects `lsfg-vk` in the Lossless Scaling tab, `lsfg-vk.dll` is not found, and the user has not checked "Do not show again"
- **THEN** the system displays a modal notice dialog presenting the Steam Betas configuration screenshot, instructions on selecting the `lsfg-vk` beta branch, an action button to open the Steam folder, and a "Do not show again" option.

#### Scenario: User selects lsfg-vk when beta DLL is already installed
- **WHEN** user clicks or selects `lsfg-vk` and `lsfg-vk.dll` is already detected in the Steam folder
- **THEN** the system does not display the modal notice dialog and applies the selection normally.

#### Scenario: User selects lsfg-vk with notice suppressed
- **WHEN** user clicks or selects `lsfg-vk` with missing `lsfg-vk.dll`, but has previously checked "Do not show again"
- **THEN** the system suppresses the modal notice dialog and updates the inline alert banner without interrupting the user.

#### Scenario: User suppresses notice from the modal dialog
- **WHEN** user checks "Do not show again" and closes or confirms the modal notice dialog
- **THEN** the system saves this preference to configuration and avoids displaying the modal notice on future selections.

## MODIFIED Requirements

### Requirement: Interactive Migration and Health Assistant dialog
The system SHALL present an interactive dialog explaining the migration steps, guiding the user through Steam beta selection with visual reference material, elevated cleanup, and configuration reset.

#### Scenario: User clicks Fix Issues
- **WHEN** user clicks the "Fix Issues" button in the migration alert banner
- **THEN** system opens the Migration and Health Assistant dialog displaying real-time status indicators (Pass/Warning/Fail) for Steam branch, legacy system files, user configuration, and distro package recommendations.

#### Scenario: Visual Steam beta reference guide in assistant
- **WHEN** user views Step 1 in the Migration and Health Assistant dialog
- **THEN** system displays the visual screenshot or interface reference illustrating the Steam Betas menu with the `lsfg-vk` branch selected.

#### Scenario: User opens Lossless Scaling Steam folder
- **WHEN** user clicks "Open Folder" in the Steam Branch section of the dialog
- **THEN** system opens the Lossless Scaling installation folder in the system default file manager.
