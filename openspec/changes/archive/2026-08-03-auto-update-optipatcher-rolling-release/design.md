# Design: Auto-Update OptiPatcher Rolling Release on OptiScaler Tab Open

## Architecture & Data Flow

```
[ User Switches to OptiScaler Tab ]
                 │
                 ▼
    [ OptiScaler Tab Shown Immediately ]
                 │
                 ▼ (Background Thread)
    [ Query GitHub API: optiscaler/OptiPatcher ]
                 │
                 ├─▶ Get latest commit date/sha
                 │
                 ▼
    [ Compare Remote Date vs Local `optipatcher=rolling-YYYY.MM.DD` in goverlay.vars ]
                 │
      ┌──────────┴──────────┐
      ▼                     ▼
[ Local is Up to Date ]   [ Remote is Newer ]
      │                     │
      ▼                     ▼
 (No action needed)       1. Download `OptiPatcher.asi` via curl
                          2. Sync to:
                             - `~/.local/share/goverlay/optiscaler/plugins/`
                             - `.bgmod_original/plugins/`
                             - active `bgmod/plugins/`
                          3. Update `goverlay.vars` to `optipatcher=rolling-YYYY.MM.DD`
                          4. Update Software Status UI label & Toast notification
```

## Detailed Specifications

### 1. Version Tracking
- Store key: `optipatcher=rolling-YYYY.MM.DD` in `goverlay.vars`.
- Compare date strings (e.g. `rolling-2026.07.31` vs `rolling-2026.08.03`).

### 2. Asynchronous Thread Execution
- Uses a background `TThread` or non-blocking `TProcess` to query `https://api.github.com/repos/optiscaler/OptiPatcher/commits/main`.
- Prevents UI freezing when navigating to the OptiScaler tab.

### 3. Target Directories
- `~/.local/share/goverlay/optiscaler/plugins/OptiPatcher.asi`
- `~/.local/share/goverlay/gameconfig/global/.bgmod_original/plugins/OptiPatcher.asi`
- `~/.local/share/goverlay/gameconfig/<active_game>/bgmod/plugins/OptiPatcher.asi`
