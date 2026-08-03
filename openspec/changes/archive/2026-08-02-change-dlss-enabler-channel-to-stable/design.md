# Design Document: Change DLSS Enabler Channel to Stable

## Overview
This document outlines the changes required to switch DLSS Enabler from channel "Bleeding-edge" (`dlssenabler-edge`) to "Stable Channel" (`dlssenabler-stable`).

## Implementation Details

### 1. Resource & Directory Helper (`bgmod_resources.pas`)
- Update `GetDlssEnablerPath` to return `GetGOverlayDataPath + 'dlssenabler-stable'`.

### 2. Game Synchronizer (`bgmod.lpr`)
- Update `ChannelFolder` assignment for `UpscalerType = '1'` to `'dlssenabler-stable'`.

### 3. Uninstaller (`bgmod-uninstaller.lpr`)
- In global uninstall block, remove `dlssenabler-stable` directory (and clean up legacy `dlssenabler-edge` if present).

### 4. DLSS Enabler Downloader & Updater (`optiscaler_update.pas`)
- Update `DownloadAndExtractDlssEnabler` and `TOptiUpdateThread` to target `dlssenabler-stable`.

### 5. UI & Config Sync (`optiscaler_tab.pas` & `overlayunit.pas`)
- When `UpscalerTypeItemIndex = 1` or `dlssenablerRadioButton` is checked, set `optversionComboBox.ItemIndex := 0` (Stable Channel).
