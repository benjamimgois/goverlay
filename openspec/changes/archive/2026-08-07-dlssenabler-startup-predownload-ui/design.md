# Design Document: DLSS Enabler Bleeding-Edge Startup Pre-download & Progress UI

## Overview
This document details the technical design for pre-downloading both DLSS Enabler stable and bleeding-edge releases during application startup and displaying progress bar UI feedback ("Downloading files...").

## Architecture & Data Flow

```
  Application Startup (overlayunit.pas)
              │
              ▼
  Check Asset Cache Existence:
  - OptiScaler stable
  - dlssenabler-stable/
  - dlssenabler-edge/
              │
              ├───── Asset Missing? ─────────────┐
              │                                  │
              ▼ YES                              ▼ NO
  Show Progress UI:                       Continue Startup
  - updateProgressBar.Visible := True
  - updatestatusLabel.Caption := 'Downloading files...'
              │
              ▼
  Execute Pre-downloads:
  - CheckAndInstallDlssEnabler(True, False)
  - CheckAndInstallDlssEnabler(False, False)
              │
              ▼
  Hide Progress UI
```

## Detailed Component Design

### 1. Startup Pre-download (`overlayunit.pas`)
Add check and pre-download execution for both DLSS Enabler channels:
```pascal
CheckAndInstallDlssEnabler(True, False);
CheckAndInstallDlssEnabler(False, False);
```

### 2. Progress UI (`overlayunit.pas`)
Show progress controls before download and hide in a `try...finally` block:
```pascal
updateProgressBar.Visible := True;
updatestatusLabel.Caption := 'Downloading files...';
updatestatusLabel.Visible := True;
```
