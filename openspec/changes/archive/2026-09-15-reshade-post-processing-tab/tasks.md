## 1. Startup Verification and ReShade Runtime Acquisition

- [x] 1.1 Implement `CheckAndInstallReShade` and download/extraction helpers to fetch the official ReShade setup executable (Add-on edition), extract `ReShade64.dll` and `ReShade32.dll` via 7z, and fetch the standard shaders archive into `~/.local/share/goverlay/reshade/`. Verify binary extraction and directory layout.
- [x] 1.2 Update `HasMissingMandatoryLibraries` and `TStartupDownloadThread.Execute` to verify and download ReShade runtime binaries and standard shaders on startup. Verify splash screen triggers and reports download progress when ReShade files are absent.

## 2. ReShade Tab UI Implementation

- [x] 2.1 Create `reshade_tab.pas` helper unit defining `TReshadeTabHelper`, implementing the tab cards: status/version card, shader collection manager card, configuration card, and "Open Shaders Directory" action. Verify the unit compiles without errors.
- [x] 2.2 Wire `reshadeTabSheet` into `overlayunit.pas` and `sidebar_nav.pas` such that clicking "Post processing" presents `[ ReShade ] [ vkBasalt ] [ vkSumi ]` with ReShade positioned first on the left and active by default. Verify tab layout and visibility transitions.
- [x] 2.3 Implement one-click shader collection management routines in `reshade_tab.pas` for SweetFX, qUINT, AstrayFX, and Prod80. Verify that downloading an optional pack extracts shaders and textures into the centralized repository and updates UI status.

## 3. Wine Path Translation, Configuration, and bgmod Integration

- [x] 3.1 Implement Wine path translation (`UnixPathToWinePath`) and template `ReShade.ini` generator mapping `EffectSearchPaths` and `TextureSearchPaths` to `Z:\...` drive notation. Verify generated INI structure and path syntax.
- [x] 3.2 Update `bgmod.lpr` to handle ReShade deployment when enabled for a game: deploy runtime DLL under selected proxy name, generate `ReShade.ini`, apply `WINEDLLOVERRIDES`, record `reshadeproxy=<dll>` in `goverlay.vars`, and handle OptiScaler co-existence. Verify proxy copying and environment overrides.
- [x] 3.3 Update uninstaller and game cleanup routines to safely remove only the GOverlay-recorded ReShade proxy DLL and restore clean state without clobbering foreign proxy files. Verify uninstallation preserves non-GOverlay files.

## 4. Testing and Verification

- [x] 4.1 Add automated test cases in `tests/` covering ReShade tab initialization, Post Processing tab order, Wine path conversion, and proxy tracking. Verify that `make test` runs and passes all test suites.
- [x] 4.2 Perform full application build (`make all`) and validate OpenSpec specifications with `openspec validate --change reshade-post-processing-tab`. Verify zero warnings or errors.
