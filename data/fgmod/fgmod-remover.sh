#!/usr/bin/env bash

# Remove ~/fgmod directory if it exists
if [[ -d "$HOME/fgmod" ]]; then
    rm -rf "$HOME/fgmod"
fi

echo "FGmod removed"