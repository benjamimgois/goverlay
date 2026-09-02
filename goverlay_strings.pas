unit goverlay_strings;

{$mode objfpc}{$H+}

// Text GOverlay shows in message boxes.
//
// These live in a resourcestring section so the Lazarus IDE picks them up into
// languages/goverlay.pot the same way it picks up the form captions; a plain
// string constant in the middle of the code cannot be translated.
//
// Rules of thumb when adding one:
//   * keep the whole sentence in one string — translators need the context and
//     word order changes between languages, so never glue fragments together
//     at the call site;
//   * pass values in with Format and %s / %d instead of concatenating them.

interface

resourcestring
  // Opening links and video tutorials
  rsLinkOpenFailed = 'Unable to open the link in the default web browser.';
  rsLinkOpenError = 'Error opening the link: %s';
  rsVideoTutorialMissing = 'Video tutorial not found.';
  rsVideoPlayerMissing = 'Could not open video tutorial. Please install a media player.';

  // Blacklist window
  rsBlacklistNameRequired = 'Insert a program name';
  rsBlacklistDuplicate = 'This program is already on the blacklist.';
  rsBlacklistSelectToRemove = 'Select an item to remove.';

  // Games tab
  rsFolderAlreadyAdded = 'This folder has already been added.';
  rsRemoveFolderTitle = 'Remove non-Steam folder';
  rsRemoveFolderPrompt = 'Are you sure you want to remove the folder "%s" from Goverlay?';
  rsUninstallChangesTitle = 'Uninstall changes';
  rsUninstallChangesPrompt = 'Are you sure you want to uninstall all changes for "%s"?';

  // Home tab: clearing the configuration
  rsClearConfigTitle = 'Clear Configuration';
  rsClearConfigPrompt = 'All files and settings will be removed and GOverlay '
    + 'will return to its initial configuration. Original game backup files will be preserved.' + sLineBreak + sLineBreak
    + 'Do you want to continue?';
  rsClearConfigDone = 'Configuration cleared successfully.' + sLineBreak
    + 'Please restart GOverlay.';
  rsClearConfigPartial = 'Some configuration folders could not be removed.'
    + sLineBreak + 'Please check file permissions and restart GOverlay.';

  // Effects
  rsEffectSelectAvailable = 'Select at least one effect in "available effects".';
  rsEffectAlreadyActive = 'This effect is already active';
  rsEffectNoneActive = 'There are no active effects';
  rsEffectSelectToRemove = 'Select at least one effect to remove';
  rsVkBasaltDirMissing = 'vkBasalt directory not found';
  rsReshadeSyncFailed = 'Error while synchronizing reshade repo. Code: %d';

  // Custom preset
  rsCustomPresetTitle = 'Custom Preset Required';
  rsCustomPresetPrompt = 'No custom configuration was found to load.' + LineEnding + LineEnding
    + 'To create your custom preset:' + LineEnding
    + '1. Customize your desired elements and colors in GOverlay.' + LineEnding
    + '2. Click the menu button in the bottom bar.' + LineEnding
    + '3. Select "Save Options" -> "Save as Custom Config".' + LineEnding + LineEnding
    + 'Once created, click "Custom" anytime to apply your preset!';

  // Intel CPU power fix
  rsIntelFixTitle = 'Intel CPU Power Fix';
  rsIntelFixNoFlatpak = 'Intel CPU power monitoring fix is not available in Flatpak.'
    + LineEnding + LineEnding
    + 'Flatpak applications cannot modify system file permissions in /sys/.'
    + LineEnding + LineEnding
    + 'This fix must be applied from outside the Flatpak sandbox on the host system.';
  rsIntelFixRemovePrompt = 'The persistent udev rule fix is currently active.'
    + LineEnding + LineEnding + 'Do you want to disable and remove it?';
  rsIntelFixRemoved = 'Persistent udev rule removed. Please reboot to restore default permissions.';
  rsIntelFixApplyPrompt = 'Due to a known vulnerability in Intel CPUs, the energy_uj file '
    + 'has to be readable by your user.' + LineEnding
    + 'Having the file readable may potentially be a security vulnerability.'
    + LineEnding + LineEnding
    + 'How would you like to apply the fix?' + LineEnding + LineEnding
    + '- Yes: Apply PERMANENTLY (creates persistent udev rule).' + LineEnding
    + '- No: Apply TEMPORARILY for this session only (resets on reboot).' + LineEnding
    + '- Cancel: Abort changes.';
  rsActionAborted = 'Action aborted by user';

  // MangoHud
  rsVkCubeRunning = 'vkcube is running!';
  rsMangoHudConfigMissing = 'Error: Could not find MangoHud configuration file.';
  rsMangoHudGlobalTitle = 'Enable MangoHud Globally';
  rsMangoHudGlobalPrompt = 'Enabling MangoHud globally may cause unexpected issues in '
    + 'some applications and desktop environments. Make sure you know what you are doing.'
    + LineEnding + LineEnding + 'Do you want to continue?';
  rsRestartSessionTitle = 'Restart Session';
  rsMangoHudEnabledPrompt = 'MangoHud has been enabled globally. A session restart is '
    + 'required for changes to take effect.' + LineEnding + LineEnding
    + 'Do you want to restart your session now?';
  rsMangoHudDisabledPrompt = 'MangoHud has been disabled globally. A session restart is '
    + 'required for changes to take effect.' + LineEnding + LineEnding
    + 'Do you want to restart your session now?';
  rsErrorTitle = 'Error';
  rsMangoHudGlobalFailed = 'Failed to toggle MangoHud global enable: %s';

  // GameMode
  rsGameModeTitle = 'GameMode Warning';
  rsGameModeFlatpakPrompt = 'You are running GOverlay in Flatpak. GameMode must be '
    + 'installed on your host system for this feature to work.' + LineEnding + LineEnding
    + 'If GameMode is not installed, games may fail to launch.' + LineEnding + LineEnding
    + 'Do you want to continue?';

  // Steam shortcut
  rsSteamShortcutFlatpakInfo = 'To add GOverlay to your Steam Library in Desktop Mode:' + LineEnding + LineEnding
    + 'Method 1 (Application Menu):' + LineEnding
    + '1. Open the Application Launcher (bottom-left corner).' + LineEnding
    + '2. Locate GOverlay under System, Utilities, or Games.' + LineEnding
    + '3. Right-click on GOverlay and select "Add to Steam".' + LineEnding + LineEnding
    + 'Method 2 (Steam Client):' + LineEnding
    + '1. In Steam, click "Games" in the top menu.' + LineEnding
    + '2. Select "Add a Non-Steam Game to My Library...".' + LineEnding
    + '3. Choose GOverlay from the list and click "Add Selected Programs".';
  rsSteamRunning = 'Steam is currently running. Please close Steam completely '
    + '(Steam -> Exit) before creating the shortcut, as Steam will overwrite and '
    + 'discard any changes when it exits.';
  rsSteamHelperMissing = 'Steam shortcut helper script not found: %s';
  rsPython3Missing = 'python3 is not installed or not in PATH.';
  rsSteamShortcutFailed = 'Error (Code %d):' + LineEnding + '%s';

  // Tweaks tab
  rsAntiLagBlockedByKorthos = 'You cannot enable AMD Anti-Lag 2 [MESA] while any '
    + 'Korthos low latency layer option is active.';
  rsKorthosBlockedByAntiLag = 'You cannot enable any Korthos low latency layer option '
    + 'while AMD Anti-Lag 2 [MESA] is active.';
  rsSpoofBlockedByHideAmdGpu = 'You cannot enable both ''LOW_LATENCY_LAYER_SPOOF_NVIDIA'' '
    + 'and ''DXVK_CONFIG="dxgi.hideAmdGpu = True"'' at the same time.';

  // Wine prefix manager
  rsProtontricksFailed = 'Error: protontricks exited with code %d. '
    + 'Make sure protontricks is installed.';
  rsProtontricksError = 'Error executing protontricks: %s';

  // OptiScaler downloads and updates
  rsReleaseFetchFailed = 'Error getting latest release: %s' + sLineBreak
    + 'Check your internet connection and if curl is installed.';
  rsManifestFetchFailed = 'Error getting OptiScaler manifest: %s';
  rsDownloadCurlFailed = 'Error downloading file: curl exited with code %d' + sLineBreak
    + 'URL: %s' + sLineBreak
    + 'Check your internet connection and if curl is installed.';
  rsDownloadMissingFile = 'Error: Downloaded file does not exist.' + sLineBreak + 'URL: %s';
  rsDownloadFailed = 'Error downloading file: %s' + sLineBreak + 'URL: %s' + sLineBreak
    + 'Check your internet connection and if curl is installed.';
  rsZipExtractFailed = 'Error extracting ZIP: %s';
  rsSevenZipMissing = 'Error: 7z file not found at: %s';
  rsSevenZipFailed = 'Error extracting 7z file. Exit code: %d' + sLineBreak + sLineBreak
    + 'Check terminal output for details.' + sLineBreak + 'File: %s';
  rsSevenZipError = 'Error executing 7z: %s';
  rsCopyFileFailed = 'Error copying file: %s';
  rsUpdateCheckFailed = 'Error checking for updates: %s';
  rsOptiScalerChannelInvalid = 'Please select a valid OptiScaler channel.';
  rsOptiScalerChannelMissing = 'OptiScaler channel not configured.';
  rsCacheCleanFailed = 'Error: Could not clean cache directory.' + sLineBreak + '%s';
  rsVarsReadFailed = 'Warning: Could not read goverlay.vars: %s';

implementation

end.
