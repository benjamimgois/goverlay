#!/usr/bin/env bash

# Determine the correct bgmod path using XDG directories
if [ -n "$XDG_DATA_HOME" ]; then
    BGMOD_PATH="$XDG_DATA_HOME/goverlay/bgmod"
else
    BGMOD_PATH="$HOME/.local/share/goverlay/bgmod"
fi

# Remove bgmod directory if it exists
if [[ -d "$BGMOD_PATH" ]]; then
    rm -rf "$BGMOD_PATH"
    echo "BGmod removed from $BGMOD_PATH"
else
    echo "BGmod directory not found at $BGMOD_PATH"
fi