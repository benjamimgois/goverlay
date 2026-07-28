## 1. Free Pascal Memory & Threading Setup

- [x] 1.1 Add `cmem` to `goverlay.lpr` under `{$IFDEF UNIX}` before `cthreads`
- [x] 1.2 Wrap `TOptiUpdateThread.Create` in `optiscaler_update.pas` with `try ... except` error protection
- [x] 1.3 Verify build and run `make test` locally to ensure no regressions
