#!/bin/bash
# GOverlay Steam Launcher
# Clears Steam Runtime environment variables before launching GOverlay,
# preventing conflicts with the Steam Overlay and Runtime libraries.
exec env -u LD_LIBRARY_PATH -u LD_PRELOAD "$@"
