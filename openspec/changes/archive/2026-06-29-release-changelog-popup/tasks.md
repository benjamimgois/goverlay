## 1. Implementation

- [x] 1.1 Create `changelogunit.pas` form with dark theme styling, title, release notes text area, and action button.
- [x] 1.2 Add `GetReleaseNotes` helper in `goverlay_system.pas` to query GitHub API for release body.
- [x] 1.3 Implement first-launch version check in `overlayunit.pas` (`CheckAndShowChangelog`) to check and write `ChangelogSeenVersion` in `goverlay.ini`.

## 2. Verification

- [x] 2.1 Compile with `lazbuild goverlay.lpi` and verify first-launch popup behavior by toggling version in config.
