# Capability: Auto-Save Configuration & Instant Persistence

## Purpose

Provides automatic configuration persistence and instant UI feedback across all GOverlay panels without requiring manual Save button clicks.

## Requirements

### Requirement: Automatic Configuration Persistence
GOverlay SHALL automatically save configuration changes to disk whenever the user modifies a UI control (checkbox, radio button, combobox, slider, text edit input, or color button) on any active tab.
GOverlay SHALL NOT require a manual "Save" button to persist configuration changes.

#### Scenario: Toggling a setting auto-saves
- **WHEN** user toggles a setting or selects a combobox option on any tab
- **THEN** GOverlay auto-saves the updated configuration to the active game or global profile immediately

#### Scenario: Dragging a slider or typing text uses debounced auto-save
- **WHEN** user drags a slider or types in any text edit box (`TCustomEdit`)
- **THEN** GOverlay debounces disk writes with a 300ms delay to prevent write thrashing

### Requirement: Loading Guard Flag
GOverlay SHALL set a loading guard flag (`FLoadingConfig`) while populating UI controls from configuration files to prevent UI updates from triggering auto-save during loading.

#### Scenario: Loading game or tab configuration does not trigger auto-save
- **WHEN** GOverlay loads configuration for a game or tab
- **THEN** UI change handlers ignore events while `FLoadingConfig` is true

### Requirement: Saved Status Indicator
GOverlay SHALL display a subtle status indicator ("✓ Saved") in English after auto-saving configuration changes.

#### Scenario: Displaying saved feedback
- **WHEN** an auto-save operation completes successfully
- **THEN** GOverlay updates the status indicator to "✓ Saved"
