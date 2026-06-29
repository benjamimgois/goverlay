## 1. Game Card Construction Updates

- [x] 1.1 Tag the non-Steam game card title label (`BdgLbl`) with a unique tag identifier (e.g. `Tag := 9991`) in `games_tab.pas`.
- [x] 1.2 Set initial visibility of `BdgLbl` based on cache status (`BdgLbl.Visible := not HasCover`) during non-Steam card creation.

## 2. Asynchronous Cover Download Synchronization

- [x] 2.1 Update `TNonSteamCoverThread` structures to track `IsFallback: Boolean` for downloaded/generated covers.
- [x] 2.2 Update `DoUpdateImage` in `games_tab.pas` to locate the tagged title label on `CardPanel` and set its visibility to `IsFallback`.

## 3. Verification & Testing

- [x] 3.1 Verify non-Steam cards with existing cached covers do not display title text.
- [x] 3.2 Verify non-Steam cards that use the GOverlay fallback icon display title text.
