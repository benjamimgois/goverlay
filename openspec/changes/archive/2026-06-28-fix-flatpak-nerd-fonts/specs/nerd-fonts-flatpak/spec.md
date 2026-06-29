## MODIFIED Requirements

### Requirement: Nerd Font bundled in Flatpak
The Flatpak build manifest SHALL include the Nerd Font Symbols typeface (`SymbolsNerdFont-Regular.ttf`) as a bundled module, installed to `/app/share/fonts/TTF/` during build, and SHALL NOT include a cleanup pattern that purges the installed font file.

#### Scenario: Font included in Flatpak image
- **WHEN** the Flatpak is built
- **THEN** `SymbolsNerdFont-Regular.ttf` is present at `/app/share/fonts/TTF/SymbolsNerdFont-Regular.ttf` inside the sandbox after build completion.

### Requirement: Nerd Font activated at startup
The GOverlay Flatpak launcher script SHALL detect if a Nerd Font is already registered in fontconfig. If not, it SHALL copy `SymbolsNerdFont-Regular.ttf` from `/app/share/fonts/TTF/` to the user's font directory and rebuild the font cache synchronously before the application GUI executable starts.

#### Scenario: Startup font activation
- **WHEN** GOverlay Flatpak starts and no Nerd Font is registered
- **THEN** the launcher copies the font file to `~/.local/share/fonts/`, runs `fc-cache -f` synchronously, and the font is registered before the GUI starts.
