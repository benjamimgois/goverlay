# Design: Notify and Allow User Update for DLSS Enabler Rolling Releases

## Architecture & Data Flow

```
[ User Active on OptiScaler Tab with DLSS Enabler Selected ]
                          │
                          ▼
             [ Background Update Check ]
  GET https://api.github.com/repos/bygalacos/OptiScalerBuilder/releases/latest
                          │
                          ▼
             [ Compare Full Tag Strings ]
  `RemoteTag` (from tag_name) vs `LocalTag` (from `dlssenabler-stable/goverlay.vars`)
                          │
         ┌────────────────┴────────────────┐
         ▼                                 ▼
[ LocalTag == RemoteTag ]        [ LocalTag <> RemoteTag ]
         │                                 │
         ▼                                 ▼
   (Status: OK / Green)          1. Software Status dot -> Yellow
                                 2. Toast: "DLSS Enabler update available!"
                                 3. Show & highlight [Update] button
                                           │
                                           ▼ (User Clicks Update)
                                 4. Download `OptiScaler_*.7z`
                                 5. Extract into `dlssenabler-stable/`
                                 6. Save `dlssenablerversion=<RemoteTag>` in `goverlay.vars`
                                 7. Update UI status label & dot -> Green
```

## UI & Tag Formatting
- **Full Tag Comparison**: Exact string matching on full GitHub `tag_name` (e.g. `OptiScaler_v0.10.0-pre1_7233fc0c_...`).
- **UI Label Display**: Truncate/format label to clean display string (e.g. `v0.10.0-pre1`) so it fits gracefully within the Software Status card boundaries without text overflow.
