## Context

See `proposal.md` for motivation. Currently `DownloadAndExtractDlssEnabler` in `optiscaler_update.pas` writes the full GitHub tag string (e.g. `OptiScaler_v0.10.0-pre1_7233fc0c_...`) into `dlssenablerversion` in `goverlay.vars`. Update checking routines in `optiscaler_update.pas` (`TOptiUpdateThread`, `UpdateButtonClick`) check OptiScaler channels even when DLSS Enabler is active.

## Goals / Non-Goals

**Goals:**
- Parse the release body JSON from `bygalacos/OptiScalerBuilder` to extract `DLSS Enabler` version (`4.8.10.11`) and integrated `OptiScaler` version (`v0.10.0-pre1`).
- Write both `dlssenablerversion=4.8.10.11` and `optiscalerversion=v0.10.0-pre1` to `goverlay.vars`.
- Direct update checks and update button actions to `bygalacos/OptiScalerBuilder` when `UPSCALER_TYPE=1` (DLSS Enabler is enabled).
- Ensure Software Status labels correctly display `DLSS Enabler` version and integrated `OptiScaler` version.

**Non-Goals:**
- Changing standard OptiScaler stable/edge release checking when DLSS Enabler is disabled.

## Decisions

### 1. Markdown Table Parsing from GitHub Release Body
- **Choice**: Extract component versions from `ReleaseJson` `body` by searching for `| DLSS Enabler | <version> |` and `| OptiScaler | <version> |`.
- **Rationale**: `bygalacos/OptiScalerBuilder` releases embed structured markdown tables in the body containing the exact component versions.

### 2. Selective Update Thread Execution
- **Choice**: In `TOptiUpdateThread.Execute` and `SyncUpdateUI`, if `dlssenablerRadioButton.Checked` / `UPSCALER_TYPE=1`, query `bygalacos/OptiScalerBuilder` releases instead of OptiScaler stable/edge tags, and set `FDlssEnablerLabel` update indicator accordingly.
- **Rationale**: Prevents false OptiScaler channel update notifications when DLSS Enabler is the chosen upscaler.

## Risks / Trade-offs

- **[Risk]** GitHub API rate limits or fallback when body format changes.  
  **Mitigation**: Fallback to release tag name if markdown table parsing yields an empty string.
