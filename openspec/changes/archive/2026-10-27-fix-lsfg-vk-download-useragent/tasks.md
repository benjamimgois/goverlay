# Tasks

## 1. User-Agent Neutralization

- [x] 1.1 In `optiscaler_update.pas`, update `GetLsfgVkLatestRemoteVersion` to send a neutral browser User-Agent (`Mozilla/5.0 (X11; Linux x86_64)`) instead of `User-Agent: goverlay`, verifying with a test curl command that `builds.lsfg-vk.dev` responds with HTTP 200 rather than HTTP 403.
- [x] 1.2 In `optiscaler_update.pas`, update `RunCurlWithProgress` to use a neutral browser User-Agent (`Mozilla/5.0 (X11; Linux x86_64)`) instead of `User-Agent: goverlay`, verifying downloads from `builds.lsfg-vk.dev` succeed without triggering 403 Forbidden.

## 2. Download Diagnostics & Error Handling

- [x] 2.1 In `optiscaler_update.pas`, update `CheckAndInstallLsfgVk` to capture the exit code of `RunCurlWithProgress` and log explicit error details if download fails, preventing silent failures and false missing-layer errors.

## 3. Verification & Build

- [x] 3.1 Verify compilation of GOverlay with `lazbuild` or build script.
- [x] 3.2 Run test suite to verify no regressions in remote scraping or update parsing.
