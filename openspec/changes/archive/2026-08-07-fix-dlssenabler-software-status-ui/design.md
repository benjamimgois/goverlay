# Design Document: Fix DLSS Enabler Software Status UI

## Overview
This document details the technical design for fixing version label loading and layout positioning within the Software Status card in `optiscaler_tab.pas` and `optiscaler_update.pas`.

## Architecture & Layout Flow

```
  Software Status Grid
  Col 0:                                      Col 1:
  ┌─────────────────────────────────────┐     ┌──────────────────────────────────┐
  │ ● OptiScaler: 0.9.4                 │     │ ● DLSS Enabler: 4.8.12           │
  │ ● Streamline SDK: 2.12.0            │     │ ● FakeNVAPI: 1.4.1               │
  │ ● DLSS / FSR / XeSS: 3.7 / 4.1 / 3.0│     │ ● OptiPatcher: rolling-2026...   │
  └─────────────────────────────────────┘     └──────────────────────────────────┘
```

## Detailed Component Design

### 1. `optiscaler_update.pas` Version Resolution
- In `CheckAndInstallDlssEnabler`, omit `optiScalerVersion` key addition to DLSS Enabler `goverlay.vars`.
- In `LoadVersionsFromFile`, maintain `OptiVer` as the actual OptiScaler version tag (reading `optiscaler-stable/goverlay.vars` if `OptiVer` is empty).

### 2. `optiscaler_tab.pas` Label Instantiation & Layout
- In `InitOptiScalerTab`:
  ```pascal
  streamlineVersionLabel := TLabel.Create(FForm);
  streamlineVersionLabel.Parent := FOsUpscalerCard;
  streamlineVersionLabel.Visible := False;
  ```
- In `ReflowOptiScalerTabNew`:
  ```pascal
  FOsStatVerLbls[i].Left := FOsStatNameLbls[i].Left + FOsStatNameLbls[i].Width + 8;
  ```
