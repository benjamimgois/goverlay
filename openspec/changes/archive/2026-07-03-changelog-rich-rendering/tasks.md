## 1. Fetch HTML body from GitHub API

- [x] 1.1 In `goverlay_system.pas` `GetReleaseNotes`, add `-H 'Accept: application/vnd.github.v3.html'` to the curl parameters so GitHub returns `body_html` alongside `body`.
- [x] 1.2 Change the body read: try `BodyText := JSONObject.Get('body_html', '');` first, fall back to `BodyText := JSONObject.Get('body', '');` if `body_html` is empty. Keep the existing `body` read as the fallback so the popup never shows blank content.

## 2. Replace TMemo with TIpHtmlPanel

- [x] 2.1 In `changelogunit.pas`, add `IpHtmlPanel` (or the required TurboPower unit) to the `uses` clause.
- [x] 2.2 In `TChangelogForm`, replace `FMemo: TMemo;` with `FHtmlPanel: TIpHtmlPanel;`.
- [x] 2.3 In `CreateNew`, replace the FMemo creation block with:
  ```
  FHtmlPanel := TIpHtmlPanel.Create(Self);
  FHtmlPanel.Parent := Self;
  FHtmlPanel.SetBounds(20, 56, 560, 380);
  ```
  Remove `ApplyModernScrollBarStylesheet(FMemo)` (TIpHtmlPanel has native scrollbars).
- [x] 2.4 Change `SetChangelogText` to call `FHtmlPanel.SetHtmlFromStr(AText);` instead of `FMemo.Text := AText;`.
- [x] 2.5 Bump form `Height` from 460 to 520 for comfortable HTML rendering.

## 3. Build and verify

- [x] 3.1 Build goverlay with `lazbuild goverlay.lpi` and confirm no compile errors (ensure `turbopower_ipro` package is available).
- [ ] 3.2 Open the "What's New" popup and verify formatted text (bold, lists, headers) renders correctly.
- [ ] 3.3 Verify images embedded in the release notes (if any present in the official release body) render inline in the popup.