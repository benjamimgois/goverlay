## 1. Action Bar UI Construction

- [x] 1.1 Create helper method or code block in `games_tab.pas` to construct the hover `ActionPanel` (tagged `9990`) with buttons for install folder, prefix folder, and uninstall.
- [x] 1.2 Add `ActionPanel` construction to Steam game card creation loop in `games_tab.pas`.
- [x] 1.3 Add `ActionPanel` construction to non-Steam game card creation loop in `games_tab.pas`.

## 2. Event Handling & Action Routing

- [x] 2.1 Update `GameCardMouseEnter` and `GameCardMouseLeave` handlers to toggle `ActionPanel.Visible` for the hovered card.
- [x] 2.2 Wire action button `OnClick` events to `GameCardOpenFolderClick`, `GameCardOpenPrefixClick`, and `GameCardUninstallClick`.

## 3. Verification & Testing

- [x] 3.1 Verify hover action bar appears on mouse enter and disappears on mouse leave for Steam cards.
- [x] 3.2 Verify hover action bar appears on mouse enter and disappears on mouse leave for non-Steam cards.
- [x] 3.3 Verify clicking each action button executes the expected folder/uninstall operation.
