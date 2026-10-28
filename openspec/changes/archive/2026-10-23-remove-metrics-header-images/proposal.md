# Change: Remove Legacy Hardware Icons from Metrics Card Headers

## Why
The legacy circuit/schematic line-art icons in the top-right corner of the GPU Metrics (`gpuImage`) and CPU / Memory Metrics (`cpuImage`) cards were asymmetrical (55x55px vs 35x35px), had low contrast against the dark background, and clashed with Goverlay's modern UI aesthetic. The user chose Option 1 (complete removal) for a clean, minimalist layout consistent with the rest of the application. Additionally, `FStorageLabel` was rendering as `Storage _Disk IO` due to missing `ShowAccelChar := False`.

## What Changes
- Hide `gpuImage` and `cpuImage` on the Metrics tab (`Visible := False`), eliminating the legacy icons from the card headers.
- Set `FStorageLabel.ShowAccelChar := False` so that `Storage & Disk IO` displays the ampersand correctly without an accelerator underscore.

## Impact
- Card headers achieve complete visual cleanliness and distraction-free symmetry.
- Storage sub-card label is displayed properly as `Storage & Disk IO`.
- Zero test regressions.
