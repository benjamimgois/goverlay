# Tasks: Grant Flatpak Write Permission for Steam Shortcuts and Deduplicate Paths

## 1. Flatpak Manifest Updates
- [x] 1.1 In `flatpak/io.github.benjamimgois.goverlay.yml`, change `~/.local/share/Steam:ro` to `~/.local/share/Steam:rw` and `~/.steam:ro` to `~/.steam:rw`.
- [x] 1.2 In `flatpak/io.github.benjamimgois.goverlay.nightly.yml`, change `~/.local/share/Steam:ro` to `~/.local/share/Steam:rw` and `~/.steam:ro` to `~/.steam:rw`.

## 2. Python Shortcut Path Deduplication
- [x] 2.1 In `assets/goverlay-steam-shortcut.py`, resolve canonical paths via `os.path.realpath` when gathering `shortcuts.vdf` files.

## 3. Verification & Testing
- [x] 3.1 Verify python shortcut helper logic and syntax.
- [x] 3.2 Run test suites (`make test-logic`, `make test-gui`).
