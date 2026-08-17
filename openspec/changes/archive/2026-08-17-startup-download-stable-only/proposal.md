# Proposal: Download Only Stable OptiScaler and DLSS Enabler on Startup

## Why

Currently on initial startup or when local caches are absent, GOverlay downloads and extracts all four channels sequentially (OptiScaler Stable, OptiScaler Edge, DLSS Enabler Stable, DLSS Enabler Edge). Because the vast majority of users rely on stable releases, pre-downloading bleeding-edge packages during boot splash creates unnecessary startup delay and network bandwidth consumption. Downloading only the stable channels on startup speeds up the first-run experience significantly, while allowing bleeding-edge packages to be downloaded on-demand/manually directly from the UI when requested.

## What Changes

- In `overlayunit.pas`:
  - Update `StartupDownloadsAsync` to only check for stable assets (`optiscaler-stable/OptiScaler.dll` and `dlssenabler-stable/version.dll`).
  - Update `TStartupDownloadThread.Execute` to only download OptiScaler Stable (0%–50%) and DLSS Enabler Stable (50%–95%), skipping bleeding-edge channels.
- In `optiscaler_update.pas`:
  - Adjust progress reporting ranges for `CheckAndInstallOptiScaler` and `CheckAndInstallDlssEnabler` to 0%–50% and 50%–95% respectively during stable downloads.
  - In `TOptiUpdateThread.SyncUpdateUI`, ensure that when the user switches to Bleeding-edge and the edge cache is not yet downloaded (`CurrentVersion = ''` or `'—'`), the UI recognizes that a download/install is available (`HasUpdates := True;`, label indicates available version, and `FUpdateBtn` is displayed).
- Update capability spec `startup-asset-predownload` to reflect stable-only startup pre-downloading and on-demand bleeding-edge downloads.

## Capabilities

### Modified Capabilities
- `startup-asset-predownload`: Change startup pre-download requirements to download only stable OptiScaler and DLSS Enabler releases, with bleeding-edge downloads deferred to on-demand UI actions.

## Impact

- `overlayunit.pas`: Faster boot splash startup, reduced startup downloads.
- `optiscaler_update.pas`: Streamlined progress ranges and seamless on-demand download prompt for bleeding-edge channels.
