## ADDED Requirements

### Requirement: Copy plugins folder during manual update
When GOverlay updates OptiScaler files during a manual update, it SHALL copy the `plugins` folder (if it exists) from the pristine `.bgmod_original` folder to the global `bgmod` configuration folder.

#### Scenario: Update copies plugins folder successfully
- **WHEN** GOverlay performs a manual update and `.bgmod_original/plugins` directory exists
- **THEN** GOverlay copies `.bgmod_original/plugins` directory recursively to the global `bgmod` directory.
