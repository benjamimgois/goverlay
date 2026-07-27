# optiscaler-persistence

## Purpose
Ensures that OptiScaler configurations, specifically `fakenvapi.ini` and `OptiScaler.ini`, are persistent and not overwritten by GOverlay on launch or update, and are parsed correctly.

## ADDED Requirements

### Requirement: Seed fakenvapi.ini Template on Save if Absent
GOverlay SHALL copy the template `fakenvapi.ini` from the cache folder to the game configuration directory prior to updating keys when saving OptiScaler settings if `fakenvapi.ini` does not exist in the target directory.

#### Scenario: Saving OptiScaler settings when fakenvapi.ini is missing
- **WHEN** GOverlay saves OptiScaler settings and `fakenvapi.ini` does not exist in the active gameconfig directory
- **THEN** GOverlay seeds `fakenvapi.ini` from the cache folder before parsing and writing `force_reflex` or latency settings.
