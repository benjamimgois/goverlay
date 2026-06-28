## 1. Local Steam Cover Detection

- [x] 1.1 Expand local librarycache search paths in `games_tab.pas` (`~/.steam/steam`, `~/.steam/root`, `~/.steam/debian-installation`, `~/.var/app/com.valvesoftware.Steam/data/Steam`).

## 2. Steam CDN & Network Fallback Cascade

- [x] 2.1 Update `TCoverDownloadThread.Execute` in `games_tab.pas` to iterate through modern Steam CDN endpoints (`shared.akamai`, `cdn.cloudflare`, `cdn.akamai`) and asset variants (`library_600x900`, `header`).
- [x] 2.2 Add Steam Store API JSON query fallback (`https://store.steampowered.com/api/appdetails?appids=<AppID>`) when direct CDN URLs fail.
- [x] 2.3 Verify compilation and test cover resolution for Steam games.
