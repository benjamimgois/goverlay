### Requirement: Dynamic Profile-Aware Launch Command Resolution

GOverlay SHALL dynamically compute the launch command at the time the Finish Configuration dialog is invoked, reflecting the active game profile context, non-Steam launcher state, and enabled performance flags rather than relying on a static or cached command string.

#### Scenario: Opening Finish Configuration dialog in Game Profile mode
- **WHEN** a game is active (`FActiveGameName <> ''`) and the user clicks the Finish button on the floating action dock
- **THEN** GOverlay SHALL pass the dynamically resolved game launch command pointing to `GetGameConfigDir(FActiveGameName) + 'bgmod'` (e.g. `"/home/user/.local/share/goverlay/gameconfig/<game>/bgmod" %command%` for Steam or `/home/user/.local/share/goverlay/gameconfig/<game>/bgmod` for Non-Steam) to the Finish Configuration dialog.

#### Scenario: Opening Finish Configuration dialog in Global Profile mode
- **WHEN** no game is active (`FActiveGameName = ''`) and the user clicks the Finish button on the floating action dock
- **THEN** GOverlay SHALL pass the dynamically resolved global launch command pointing to `GetGameConfigDir('') + 'bgmod'` (e.g. `"/home/user/.local/share/goverlay/gameconfig/global/bgmod" %command%`) to the Finish Configuration dialog.
