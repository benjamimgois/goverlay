# Proposal

## Why

When installing or checking updates for `lsfg-vk`, GOverlay requests `https://builds.lsfg-vk.dev/` with `User-Agent: goverlay`. The upstream server (nginx) explicitly rejects all requests containing `goverlay` in the User-Agent with `HTTP 403 Forbidden`. Consequently, remote version discovery fails and the download tarball is never fetched, causing runtime installation to fail with `[AUTO-INSTALL] ERROR: lsfg-vk layer not detected after installation`.

## What Changes

- Update `GetLsfgVkLatestRemoteVersion` in `optiscaler_update.pas` to use a neutral standard browser User-Agent (`Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36`) or omit the custom header, preventing HTTP 403 Forbidden rejections from `builds.lsfg-vk.dev`.
- Update `RunCurlWithProgress` in `optiscaler_update.pas` (or provide an option to override/neutralize the User-Agent) so file downloads from build servers or third-party CDNs that block application-specific headers succeed.
- Enhance download and extraction error logging in `CheckAndInstallLsfgVk`: explicitly check curl's exit code and report download failures (such as HTTP errors) before attempting extraction, providing clear diagnostic logs instead of a misleading layer detection failure.

## Capabilities

### Modified Capabilities
- `lsfg-vk-auto-install`: Update remote discovery and download requirements to use a compatible User-Agent that avoids HTTP 403 blocks from `builds.lsfg-vk.dev`, and report download failures distinctly from layer detection issues.

## Impact

- `optiscaler_update.pas`: `GetLsfgVkLatestRemoteVersion`, `RunCurlWithProgress`, and `CheckAndInstallLsfgVk`.
- Resolves runtime auto-installation and manual "Install runtime" failures for `lsfg-vk`.
