## Why

Current update checks call GH tags API → rate limits + complex parsing/sorting of tag arrays in Pascal. Static manifest JSON bypasses API limits, simplifies check logic, and decouples asset filenames.

## What Changes

- Fetch updates from static `versions.json` raw URL instead of GitHub `/tags` API.
- Simplify Pascal parser → read direct keys, remove regex tag sorting.
- Update `bgmod.conf` parsing/saving to align with manifest.

## Capabilities

### New Capabilities

- None

### Modified Capabilities

- `bgmod-update-optiscaler`: Update version detection requirement to use static JSON manifest instead of GitHub API tag list parsing.

## Impact

- `optiscaler_update.pas`: URL constants, HTTP fetch, JSON parsing logic.
