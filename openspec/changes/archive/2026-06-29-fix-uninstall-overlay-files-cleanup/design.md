## Context

When running "Uninstall changes", users noted `bgmod.log` and `MangoHud.conf` (as well as `vkBasalt.conf` and `vkSumi.conf`) remained in the game directory. We need explicit deletion calls for these files across GUI and helper binaries.

## Goals / Non-Goals

**Goals:**
- In `games_tab.pas` (`RunFGModUninstallCommands`), add explicit deletion check and logging for `bgmod.log`, `MangoHud.conf`, `vkBasalt.conf`, and `vkSumi.conf`.
- In `bgmod-uninstaller.lpr` and `bgmod.lpr`, add explicit `SafeDeleteFile` calls for these four files.

**Non-Goals:**
- Modifying global system config locations.

## Decisions

### Decision 1: Explicit deletion and logging in GUI and wrappers
In `games_tab.pas`:
```pascal
if FileExists(Dir + 'MangoHud.conf') then begin DeleteFile(Dir + 'MangoHud.conf'); Log('Cleaned up file: ' + Dir + 'MangoHud.conf'); end;
if FileExists(Dir + 'vkBasalt.conf') then begin DeleteFile(Dir + 'vkBasalt.conf'); Log('Cleaned up file: ' + Dir + 'vkBasalt.conf'); end;
if FileExists(Dir + 'vkSumi.conf') then begin DeleteFile(Dir + 'vkSumi.conf'); Log('Cleaned up file: ' + Dir + 'vkSumi.conf'); end;
```

## Risks / Trade-offs

- None identified.
