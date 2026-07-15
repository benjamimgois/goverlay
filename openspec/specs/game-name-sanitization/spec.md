# Game Name Sanitization

## Purpose
Sanitize game names to keep only safe ASCII characters.

## Requirements

### Requirement: Sanitize Game Names
The system SHALL sanitize game names to keep only safe ASCII characters: letters, digits, underscores, hyphens, spaces, periods, plus signs, parentheses, and brackets. All other bytes, including non-ASCII and multi-byte UTF-8 symbols, MUST be replaced by underscores. Consecutive underscores MUST be collapsed into a single underscore, and the result MUST be trimmed. If the final output is empty, it MUST fallback to `game`.

#### Scenario: Sanitize string with special characters
- **WHEN** the game name is "Half-Life: Counter-Strike"
- **THEN** the sanitized name is "Half-Life_ Counter-Strike"

#### Scenario: Sanitize string with unicode trademark symbols
- **WHEN** the game name is "Super Game™"
- **THEN** the sanitized name is "Super Game_"

#### Scenario: Collapse consecutive underscores
- **WHEN** the game name is "Game!!!Name"
- **THEN** the sanitized name is "Game_Name"

#### Scenario: Fallback for empty output
- **WHEN** the game name is "™" or contains only spaces and unsafe characters
- **THEN** the sanitized name is "game"
