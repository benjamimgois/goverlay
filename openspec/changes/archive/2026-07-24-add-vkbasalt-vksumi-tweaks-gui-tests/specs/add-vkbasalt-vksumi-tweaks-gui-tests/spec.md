## ADDED Requirements

### Requirement: vkBasalt round-trip GUI verification
The GUI test suite SHALL modify vkBasalt controls, save configuration, invoke `LoadVkBasaltConfig`, and assert that reloaded UI controls match expected settings.

#### Scenario: vkBasalt settings reload
- **WHEN** GUI test cases modify vkBasalt effect trackbars or shortcuts and execute Save
- **THEN** test procedure calls `LoadVkBasaltConfig` and asserts UI controls retain saved values

### Requirement: vkSumi round-trip GUI verification
The GUI test suite SHALL modify vkSumi trackbars, save configuration, invoke `LoadVkSumiConfig`, and assert that reloaded UI trackbars match expected settings.

#### Scenario: vkSumi settings reload
- **WHEN** GUI test cases modify vkSumi contrast/brightness/saturation trackbars and execute Save
- **THEN** test procedure calls `LoadVkSumiConfig` and asserts trackbar positions match saved values

### Requirement: Tweaks tab round-trip GUI verification
The GUI test suite SHALL navigate to the Tweaks tab, modify tweak controls, save configuration, invoke `LoadTweaksConfig`, and assert that reloaded UI controls match expected settings.

#### Scenario: Tweaks settings reload
- **WHEN** GUI test cases navigate to the Tweaks tab, toggle settings, and execute Save
- **THEN** test procedure calls `LoadTweaksConfig` and asserts UI controls retain saved values
