# game-library-sorting Specification

## Purpose
Provides unified, deterministic alphabetical sorting for Steam and non-Steam game cards displayed in the Games tab library.

## Requirements

### Requirement: Unified alphabetical game card ordering
The system SHALL display all discovered Steam and non-Steam game cards in unified alphabetical order (A-Z) within the Games tab.

#### Scenario: Interleaved Steam and non-Steam games
- **WHEN** user views the Games tab with both Steam and non-Steam games installed
- **THEN** games from both sources are ordered together alphabetically by title, rather than displaying non-Steam games appended at the end

### Requirement: Deterministic sorting rules
The system SHALL sort game titles in a case-insensitive manner, placing symbols and numbers before letters, and preserving strict article titles (such as those starting with "The") under their starting letter.

#### Scenario: Titles with numbers and symbols
- **WHEN** the library contains games starting with digits or special characters alongside games starting with letters
- **THEN** games starting with digits or symbols are displayed before alphabetical letters in the grid

#### Scenario: Case-insensitive ordering
- **WHEN** the library contains games with mixed uppercase and lowercase titles
- **THEN** game titles are sorted without case bias (e.g. "half-life" and "Half-Life 2" sort adjacent to each other)

#### Scenario: Titles starting with "The"
- **WHEN** the library contains games whose titles begin with "The" (e.g., "The Witcher 3")
- **THEN** the game is positioned under the letter "T" in strict alphabetical order
