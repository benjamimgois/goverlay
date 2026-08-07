# Design Document: Fix INI File Sync on Launch in bgmod

## Overview
This document details the technical design for ensuring user modifications to `OptiScaler.ini` and `fakenvapi.ini` in `ConfigDir` are reliably copied to `GameDir` whenever a game is launched via `bgmod`.

## Architecture & Data Flow

```
  ConfigDir (~/.local/share/goverlay/gameconfig/<game>/ or gameconfig/global/)
     ├── OptiScaler.ini (User configuration)
     └── fakenvapi.ini  (User configuration)
             │
             │ Game Launch (bgmod execution)
             ▼
  SyncOptiScalerIni / SyncFakeNvapiIni
             │
             │ Copies ConfigDir/*.ini -> GameDir/*.ini
             ▼
  Target Game Directory (GameDir)
     ├── OptiScaler.ini
     └── fakenvapi.ini
```

## Detailed Component Design

### 1. `SyncOptiScalerIni` (`bgmod.lpr`)
Update `SyncOptiScalerIni`:
```pascal
procedure SyncOptiScalerIni(const AConfigDir, AGameDir: string; APreserveIni: Boolean);
var
  ConfigIni, GameIni: string;
begin
  ConfigIni := IncludeTrailingPathDelimiter(AConfigDir) + 'OptiScaler.ini';
  GameIni := IncludeTrailingPathDelimiter(AGameDir) + 'OptiScaler.ini';

  if FileExists(ConfigIni) then
  begin
    Log('Syncing OptiScaler.ini from config directory to game directory...');
    SafeCopyFile(ConfigIni, GameIni);
  end;
end;
```

### 2. `SyncFakeNvapiIni` (`bgmod.lpr`)
Add `SyncFakeNvapiIni`:
```pascal
procedure SyncFakeNvapiIni(const AConfigDir, AGameDir: string);
var
  ConfigIni, GameIni: string;
begin
  ConfigIni := IncludeTrailingPathDelimiter(AConfigDir) + 'fakenvapi.ini';
  GameIni := IncludeTrailingPathDelimiter(AGameDir) + 'fakenvapi.ini';

  if FileExists(ConfigIni) then
  begin
    Log('Syncing fakenvapi.ini from config directory to game directory...');
    SafeCopyFile(ConfigIni, GameIni);
  end;
end;
```

### 3. DLSS Enabler Base Setup Adjustment (`bgmod.lpr`)
In section 5a of `bgmod.lpr`, remove `SafeCopyFile(OptiBaseDir + 'OptiScaler.ini', ...)` so it does not overwrite `GameDir/OptiScaler.ini` with the default template.
