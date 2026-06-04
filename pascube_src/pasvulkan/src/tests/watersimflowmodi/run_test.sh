#!/bin/bash

# Compile and run the water simulation flow modes test
gcc -std=c99 -Wall -Wextra -O2 -lm watersimflowmodi.c -o watersimflowmodi

if [ $? -eq 0 ]; then
    echo "Compilation successful, running test..."
    echo
    ./watersimflowmodi
else
    echo "Compilation failed!"
    exit 1
fi
