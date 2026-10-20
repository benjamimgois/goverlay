unit goverlay_strings;

{$mode objfpc}{$H+}

// Text Goverlay shows in message boxes.
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
  rsClearConfigPrompt = 'All files and settings will be removed and Goverlay '
    + 'will return to its initial configuration. Original game backup files will be preserved.' + sLineBreak + sLineBreak
    + 'Do you want to continue?';
  rsClearConfigDone = 'Configuration cleared successfully.' + sLineBreak
    + 'Please restart Goverlay.';
  rsClearConfigPartial = 'Some configuration folders could not be removed.'
    + sLineBreak + 'Please check file permissions and restart Goverlay.';

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
    + '1. Customize your desired elements and colors in Goverlay.' + LineEnding
    + '2. Click the menu button in the bottom bar.' + LineEnding
    + '3. Select "Save Options" -> "Save as Custom Config".' + LineEnding + LineEnding
    + 'Once created, click "Custom" anytime to apply your preset!';

  // Intel CPU power fix
  rsIntelFixTitle = 'Intel CPU Power Fix';
  rsIntelFixNoFlatpak = 'Intel CPU power monitoring fix is not available directly inside Flatpak.'
    + LineEnding + LineEnding
    + 'Flatpak applications cannot modify system file permissions in /sys/.'
    + LineEnding + LineEnding
    + 'To apply this fix, run the following command in a terminal on your host system:'
    + LineEnding + LineEnding
    + 'echo ''ACTION==\"add|change\", SUBSYSTEM==\"powercap\", KERNEL==\"intel-rapl*\", RUN+=\"/bin/chmod o+r /sys/%p/energy_uj\"'' | sudo tee /etc/udev/rules.d/70-intel-rapl.rules && sudo udevadm control --reload-rules && sudo udevadm trigger';
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
  rsGameModeFlatpakPrompt = 'You are running Goverlay in Flatpak. GameMode must be '
    + 'installed on your host system for this feature to work.' + LineEnding + LineEnding
    + 'If GameMode is not installed, games may fail to launch.' + LineEnding + LineEnding
    + 'Do you want to continue?';

  // Steam shortcut
  rsSteamShortcutFlatpakInfo = 'To add Goverlay to your Steam Library in Desktop Mode:' + LineEnding + LineEnding
    + 'Method 1 (Application Menu):' + LineEnding
    + '1. Open the Application Launcher (bottom-left corner).' + LineEnding
    + '2. Locate Goverlay under System, Utilities, or Games.' + LineEnding
    + '3. Right-click on Goverlay and select "Add to Steam".' + LineEnding + LineEnding
    + 'Method 2 (Steam Client):' + LineEnding
    + '1. In Steam, click "Games" in the top menu.' + LineEnding
    + '2. Select "Add a Non-Steam Game to My Library...".' + LineEnding
    + '3. Choose Goverlay from the list and click "Add Selected Programs".';
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

  // Startup downloads and integrity verification
  rsStartupDownloadFailedDetails = 'Could not download required libraries: %s. Check your internet connection.';
  rsStartupDownloadFailedSummary = 'Could not download %d required libraries. Check your internet connection.';

  // ---- Runtime-created widgets (translated on request) ----
  // aboutunit.pas
  rsOpenSourceToolProvidingAUnified = 'Open-source tool providing a unified interface to configure different gaming tools';
  rsCredits = 'Credits:';
  rsProjectLinks = 'Project links:';

  // changelogunit.pas
  rsWhatSNewInGoverlay = '🚀 What''s New in Goverlay';
  rsLoadingImage = '⏳ Loading image...';
  rsWhatSNewInGoverlay2 = '🚀 What''s New in Goverlay ';

  // finish_dialog.pas
  rsFinishConfiguration = 'Finish Configuration';
  rsApplyTheGeneratedLaunchCommandTo = 'Apply the generated launch command to your game launcher';
  rsLaunchCommand = 'Launch command:';
  rsCopy = '  Copy';
  rsCopied = '  Copied!';

  // floating_dock.pas
  rsOptionsPresetsMenu = 'Options & presets menu';
  rsStop3DPreviewPasCubeRunningIn = 'Stop 3D preview (PasCube running in live sync)';
  rsLaunchAQuick3DPreviewPasCube = 'Launch a quick 3D preview (PasCube / vkcube)';
  rsAddAction = 'Add action';
  rsGetYourSteamHeroicLaunchCommand = 'Get your Steam / Heroic launch command';

  // games_tab.pas
  rsOpenInstallFolder = 'Open install folder';
  rsOpenPrefixFolder = 'Open prefix folder';
  rsCloneGlobalConfigs = 'Clone global configs';
  rsUninstallChanges = 'Uninstall changes';
  rsLaunchAQuickPreviewCubePascube = 'Launch a quick preview cube (pascube / vkcube)';
  rsCopyThisCommandAndPasteIt = 'Copy this command and paste it into the game''s Launch Options in Steam.';
  rsSteamGame = 'Steam Game';
  rsChangesUninstalledFor = 'Changes uninstalled for ';
  rsGameOptions = 'Game options';
  rsGlobalConfigurationsClonedFor = 'Global configurations cloned for ';
  rsSelectANonSteamGameFolder = 'Select a non-Steam game folder';
  rsAddGameFolder = 'Add game folder...';
  rsRemoveGameFolder = 'Remove game folder';
  rsNoCustomFoldersAdded = '(No custom folders added)';
  rsRefreshGameLibrary = 'Refresh game library';
  rsRemove = 'Remove: ';
  rsNoNonSteamFoldersAdded = '(No non-Steam folders added)';

  // goverlay_system.pas
  rsNewVersion = 'New Version ';
  rsAvailable = ' available';

  // home_tab.pas
  rsHome = 'Home';
  rsClearConfiguration = 'Clear configuration';
  rsOSKernel = 'OS / Kernel';
  rsDriver = 'Driver';
  rsInstallation = 'Installation';
  rsClientID = 'Client ID: ';
  rsClientID2 = 'Client ID';
  rsPascubeNickname = 'Pascube nickname: ';
  rsClickToEdit = '  [click to edit]';
  rsPascubeNicknameAnonymousClickToSet = 'Pascube nickname: Anonymous  [click to set]';
  rsClickToSetDisplayNicknameFor = 'Click to set display nickname for leaderboards';
  rsAddOnEdition = ' (Add-on Edition)';
  rsDLSSNRIsInstalledAndNeural = 'DLSS-NR is installed and neural weights are ready';
  rsDLSSNRRuntimeIsInstalledBut = 'DLSS-NR runtime is installed, but neural model weights need extraction';
  rsDLSSNRIsNotInstalled = 'DLSS-NR is not installed';

  // howto.pas
  rsWatchTutorial = '▶  Watch Tutorial';
  rsStopVideo = '✕  Stop Video';

  // lossless_scaling_tab.pas
  rsInstallUpdate = 'Install update';
  rsMAKO = '● MAKO ';
  rsIsUpToDate = ' is up to date';
  rsFrameInterpolationConflict = 'Frame Interpolation Conflict';
  rsFPS = ' FPS';
  rsPathToLsfgVkDllE = 'Path to lsfg-vk.dll (e.g. ~/.local/share/Steam/steamapps/common/Lossless Scaling/lsfg-vk.dll)';
  rsBrowseForLsfgVkDll = 'Browse for lsfg-vk.dll';
  rsPathToLosslessDllEG = 'Path to Lossless.dll (e.g. ~/.local/share/Steam/steamapps/common/Lossless Scaling/Lossless.dll)';
  rsBrowseForLosslessDll = 'Browse for Lossless.dll';
  rs1xDisabled = '1x (Disabled)';
  rs1xBypass = '1x (Bypass)';
  rsXFPS = 'x FPS';
  rsInstalled = 'Installed';
  rsNotInstalled = 'Not installed';
  rsInstallRuntime = 'Install runtime';
  rsLsfgVk20MigrationHazards = 'lsfg-vk 2.0 Migration Hazards Detected';
  rsSteamBetaBranchMissingLsfgVk = 'Steam beta branch missing (lsfg-vk.dll) or legacy 1.x files found.';
  rsMigrationAssistant = 'Migration Assistant';
  rsDisableFrameGenerationAndInterpolation = 'Disable frame generation and interpolation';
  rsNone = 'None';
  rsOpenSourceVulkanLayerForLossless = 'Open-source Vulkan layer for Lossless Scaling Frame Generation (LSFG) with wide game compatibility';
  rsHighPerformanceFrameGenerationAndSpatial = 'High-performance frame generation and spatial upscaling engine with adaptive framerate modes';
  rsAMDFluidMotionFramesDriverLevel = 'AMD Fluid Motion Frames driver-level optical flow frame interpolation for Vulkan applications';
  rsTargetGPUDevice = 'Target GPU Device';
  rsTargetGPUDeviceToUseFor = 'Target GPU device to use for frame generation and upscaling';
  rsFrameGenerationIsDisabledSelectAn = 'Frame generation is disabled. Select an interpolation engine above (lsfg-vk or MAKO) to enable and configure settings.';
  rsFrameGenerationMode = 'Frame Generation Mode';
  rsChooseBetweenFixedMultiplier2x5x = 'Choose between Fixed Multiplier (2x-5x) or Adaptive Frame Generation';
  rsMultiplier = 'Multiplier';
  rsFrameGenerationMultiplier1xDisabled2x = 'Frame generation multiplier: 1x (disabled), 2x, 3x, 4x, 5x';
  rsTargetFPS = 'Target FPS';
  rsDynamicMultiplierTargetsThisFramerateBased = 'Dynamic multiplier targets this framerate based on input FPS (30 - 240 FPS)';
  rsDynamicMultiplierTargetsThisFramerateBased2 = 'Dynamic multiplier targets this framerate based on input FPS';
  rsMaxMultiplierCeiling = 'Max Multiplier Ceiling';
  rsMaximumMultiplierAllowedInAdaptiveMode = 'Maximum multiplier allowed in adaptive mode';
  rsSteady2xBaseFPSCap = 'Steady 2x Base FPS Cap';
  rsPreventsMultiplierChurningBetween1xAnd = 'Prevents multiplier churning between 1x and 2x by enforcing target/2 base cap';
  rsSmoothCadence = 'Smooth Cadence';
  rsSmoothTransitionsDuringMultiplierSwitching = 'Smooth transitions during multiplier switching';
  rsFlowScale = 'Flow Scale';
  rsMotionEstimationResolutionScaleDefault90 = 'Motion estimation resolution scale (default 90% recommended by MAKO)';
  rsMotionEstimationResolutionScale = 'Motion estimation resolution scale';
  rsBaseFPSCap = 'Base FPS Cap';
  rsLimitsTheGameSNativeBase = 'Limits the game''s native base framerate before interpolation to maintain steady pacing and GPU headroom (0 = Disabled / Uncapped)';
  rsDisabled = 'Disabled';
  rsRefreshThreshold = 'Refresh Threshold';
  rsMinimumDisplayRefreshRateHzRequired = 'Minimum display refresh rate (Hz) required to engage frame generation. Automatically bypasses frame generation if your monitor refresh rate is below this threshold (0 = Disabled / Always active)';
  rsLiveFGSwitch = 'Live FG Switch';
  rsToggleFrameGenerationRuntimeActivation = 'Toggle frame generation runtime activation';
  rsFP16Acceleration = 'FP16 Acceleration';
  rsUses16BitHalfPrecisionMath = 'Uses 16-bit half-precision math for frame generation. Recommended ON for AMD GPUs (significant performance uplift), but recommended OFF for NVIDIA GPUs.';
  rsPerformanceMode = 'Performance Mode';
  rsSwitchesToTheLighterLSFGNeural = 'Switches to the lighter LSFG neural network model, reducing GPU render time by 30-40% with minimal image quality loss. Recommended if the game is GPU-bound.';
  rsUltraPerformance = 'Ultra Performance';
  rsAggressiveVulkanComputeOptimizationsDownsamp = 'Aggressive Vulkan compute optimizations (downsamples optical flow vectors and skips high-precision passes). Maximizes FPS on low-end GPUs or handhelds, but may introduce visual artifacts.';
  rsHDRMode = 'HDR Mode';
  rsDisableFP16HalfPrecision = 'Disable FP16 / Half-Precision';
  rsHasAGiantPerformanceUpliftOn = 'Has a giant performance uplift on AMD GPUs.';
  rsOverridePresentMode = 'Override Present Mode';
  rsForcesThePresentationEngineToUse = 'Forces the presentation engine to use the selected pacing mode. Recommended: On (upstream default).';
  rsPreserveSwapchainCount = 'Preserve Swapchain Count';
  rsPreservesTheApplicationSwapchainImageCount = 'Preserves the application swapchain image count. May resolve issues with games sensitive to swapchain resizing. Recommended: Off (upstream default).';
  rsPacingMode = 'Pacing Mode';
  rsFramePacingModeToUse = 'Frame pacing mode to use';
  rsFramePacingSynchronizationModeVsyncOr = 'Frame pacing synchronization mode (vsync or none)';
  rsEnableSpatialScaling = 'Enable Spatial Scaling';
  rsUpscaleTheGameResolutionBeforeFrame = 'Upscale the game resolution before frame generation';
  rsScalingMethod = 'Scaling Method';
  rsUpscalingAlgorithmLS1RequiresLosslessDll = 'Upscaling algorithm (LS1 requires Lossless.dll)';
  rsScalingFactor = 'Scaling Factor';
  rsResolutionScaleFactor100xTo = 'Resolution scale factor: 1.00x to 2.00x';
  rsScaleFactor100xTo2 = 'Scale factor: 1.00x to 2.00x';
  rsPostUpscaleSharpeningAmount000 = 'Post-upscale sharpening amount (0.00 to 1.00)';
  rsSharpnessAmount = 'Sharpness amount';
  rsQualitySupersampling = 'Quality Supersampling';
  rsEnhanceEdgeAntiAliasingDuringUpscaling = 'Enhance edge anti-aliasing during upscaling';
  rsTogglesOpticalFlowPerformanceAndQuality = 'Toggles optical flow performance and quality balance (AFMF_PERFORMANCE_MODE)';
  rsOpticalFlowTradeOffBetweenSpeed = 'Optical flow trade-off between speed and visual fidelity';
  rsSearchMode = 'Search Mode';
  rsSearchRadiusForMotionVectorsAFMF = 'Search radius for motion vectors (AFMF_SEARCH_MODE)';
  rsMotionVectorSearchRadius = 'Motion vector search radius';
  rsFastMotionFallback = 'Fast Motion Fallback';
  rsBehaviorDuringFastCameraPansAFMF = 'Behavior during fast camera pans (AFMF_FAST_MOTION_RESPONSE)';
  rsFallbackStrategyWhenMotionIsToo = 'Fallback strategy when motion is too rapid for vector calculation';
  rsFramePacing = 'Frame Pacing';
  rsSmoothsFramePresentationTimingAFMFPACING = 'Smooths frame presentation timing (AFMF_PACING)';
  rsGPUGovernor = 'GPU Governor';
  rsAllowsGPUClockGovernorToThrottle = 'Allows GPU clock governor to throttle for power efficiency (AFMF_GOVERNOR)';
  rsPresentMode = 'Present Mode';
  rsSwapchainPresentationModeAFMFPRESENTMODE = 'Swapchain presentation mode (AFMF_PRESENT_MODE)';
  rsControlsWhetherPresentationModeIsAutomatical = 'Controls whether presentation mode is automatically adjusted';
  rsMinimumFPSFloor = 'Minimum FPS Floor';
  rsBypassesFrameInterpolationIfGameFPS = 'Bypasses frame interpolation if game FPS drops below this floor (AFMF_MIN_FPS)';
  rsMinimumBaseFramerateRequiredForAFMF = 'Minimum base framerate required for AFMF interpolation (0 = Uncapped)';
  rsHUDDetection = 'HUD Detection';
  rsExcludesStaticUserInterfaceAndText = 'Excludes static user interface and text elements from motion estimation (AFMF_HUD_DETECT)';
  rsGamescopeCompatibility = 'Gamescope Compatibility';
  rsAllocatesExtraSwapchainImagesForGamescope = 'Allocates extra swapchain images for Gamescope compositors (AFMF_GAMESCOPE)';
  rsDirectIngest = 'Direct Ingest';
  rsBypassesIntermediateColorCopiesDuringOptical = 'Bypasses intermediate color copies during optical flow ingest (AFMF_DIRECT_INGEST)';
  rsDirectOutput = 'Direct Output';
  rsWritesGeneratedFramesDirectlyToSwapchain = 'Writes generated frames directly to swapchain render targets (AFMF_DIRECT_OUTPUT)';
  rsAsyncComputeQueue = 'Async Compute Queue';
  rsExecutesOpticalFlowShadersOnAsynchronous = 'Executes optical flow shaders on asynchronous compute queue (AFMF_ASYNC)';
  rsStaticBlockSADThreshold = 'Static Block SAD Threshold';
  rsSumOfAbsoluteDifferencesThresholdFor = 'Sum of Absolute Differences threshold for stationary blocks (AFMF_STATIC_BLOCK_SAD)';
  rsSensitivityForDetectingStationaryBlocks0 = 'Sensitivity for detecting stationary blocks (0 = Auto/Disabled)';
  rsAuto = 'Auto';
  rsLoggingVerbosity = 'Logging Verbosity';
  rsControlsAFMFLayerStdoutStderrDebug = 'Controls AFMF layer stdout/stderr debug output (AFMF_LOG)';
  rsDiagnosticLogLevel = 'Diagnostic log level';
  rsProfilingTimers = 'Profiling Timers';
  rsMeasuresOpticalFlowShaderExecutionTimes = 'Measures optical flow shader execution times (AFMF_PROFILE)';
  rsDLLFileLocated = '● DLL file located';
  rsCheckingMAKO = '● Checking MAKO...';
  rsIncompatibleWithWaylandAndHDR = '(Incompatible with Wayland and HDR)';
  rsCheckUpdates = 'Check Updates';
  rsInstallMAKO = 'Install MAKO';
  rsCheckingLsfgVkLayer = '● Checking lsfg-vk layer...';
  rsLsfgVkAssistant = 'lsfg-vk Assistant';
  rsOpenTheLsfgVkAssistantAnd = 'Open the lsfg-vk assistant and troubleshooting dialog';
  rsCheckingAFMFLayer = '● Checking AFMF layer...';
  rsSwitchLosslessScalingToLsfgVk = '● Switch Lossless Scaling to lsfg-vk beta branch in Steam';
  rsInstallLosslessScalingOnSteamOr = '● Install Lossless scaling on steam or point the correct file path';
  rsCouldNotCheckForUpdatesGitHub = '● Could not check for updates (GitHub offline/rate-limited)';
  rsLatestReleaseIs = '● Latest release is ';
  rsClickInstall = ' (Click Install)';
  rsStartingMAKOInstallation = 'Starting MAKO installation...';
  rsStartingLsfgVkInstallation = 'Starting lsfg-vk installation...';
  rsSelectLsfgVkDll = 'Select lsfg-vk.dll';
  rsSelectLosslessDll = 'Select Lossless.dll';

  // lsfg_migration_dialog.pas
  rsLsfgVk20MigrationHealth = 'lsfg-vk 2.0 Migration & Health Assistant';
  rsFollowTheGuidedStepsBelowTo = 'Follow the guided steps below to ensure Lossless Scaling is configured for the 2.0 Vulkan pipeline.';
  rsRefreshChecks = 'Refresh Checks';
  rsClose = 'Close';
  rsStep1SwitchLosslessScalingTo = 'Step 1: Switch Lossless Scaling to the "lsfg-vk" Beta Branch';
  rsCheckingSteamInstallation = 'Checking Steam installation...';
  rsUpstreamLsfgVk20Requires = 'Upstream lsfg-vk 2.0 requires the native Vulkan bindless shaders in lsfg-vk.dll.';
  rsClickToViewSteamBetasGuide = 'Click to view Steam Betas guide';
  rsSteamGuide = 'Steam Guide';
  rsOpenSteamFolder = 'Open Steam Folder';
  rsStep2CleanConflicting1X = 'Step 2: Clean Conflicting 1.x System Layers (Root Required)';
  rsCheckingForLegacy1XFiles = 'Checking for legacy 1.x files...';
  rsLegacy1XImplicitLayersHook = 'Legacy 1.x implicit layers hook games automatically and cause parse or crash errors with 2.0.';
  rsCleanLegacyFilesRoot = 'Clean Legacy Files (Root)';
  rsStep3RemoveDeprecatedDistroPackages = 'Step 3: Remove Deprecated Distro Packages';
  rsIfYouInstalledLsfgVkFrom = 'If you installed lsfg-vk from AUR or a package manager (e.g. lsfg-vk-git), we recommend uninstalling it:';
  rsCheckingUserConfigurationSchema = 'Checking user configuration schema...';
  rsLsfgVk20ExpectsVersion = 'lsfg-vk 2.0 expects version = 2 and [[profile]] syntax. Legacy 1.x configurations will trigger schema parse errors.';
  rsUpdateConfiguration = 'Update Configuration';
  rsLegacyFilesRemovedSuccessfully = 'Legacy files removed successfully!';
  rsCleanupCanceledOrFailedCode = 'Cleanup canceled or failed (code ';
  rsExecutionError = 'Execution error: ';
  rsBackupCreated = 'Backup created (';
  rsAndV2Written = ') and v2 written!';
  rsDefaultV2ConfigGeneratedSuccessfully = 'Default v2 config generated successfully!';
  rsFailedToUpdateConfiguration = 'Failed to update configuration';
  rsLsfgVkDllIsInstalledAnd = '● lsfg-vk.dll is installed and detected.';
  rsLsfgVkDllMissingSteamBeta = '● lsfg-vk.dll missing! Steam beta branch required.';
  rsLosslessScalingFolderNotFoundOr = '● Lossless Scaling folder not found or lsfg-vk.dll missing.';
  rsLegacy1XLayerFileS = ' legacy 1.x layer file(s) found in system!';
  rsNoLegacy1XLayersDetected = '● No legacy 1.x layers detected in system.';
  rsOutdatedV1ConfigurationSyntaxDetected = '● Outdated v1 configuration syntax detected.';
  rsConfigurationIsUpToDateVersion = '● Configuration is up to date (version = 2).';

  // lsfg_steam_beta_dialog.pas
  rsSteamBetaBranchRequiredForLsfg = 'Steam Beta Branch Required for lsfg-vk 2.0';
  rsLosslessScalingMustBeConfiguredIn = 'Lossless Scaling must be configured in Steam to download the required Vulkan shaders (lsfg-vk.dll).';
  rsDoNotShowThisNoticeAgain = 'Do not show this notice again';
  rsGotIt = 'Got It';
  rsSteamLibraryLosslessScalingRightClick = 'Steam > Library > Lossless Scaling (Right Click) > Properties... > Game Versions && Betas > Select "lsfg-vk"';
  rsFollowTheseStepsInSteam = 'Follow these steps in Steam:';
  rs1OpenSteamFindLosslessScaling = '1. Open Steam, find "Lossless Scaling" in your Library, and right-click it.';
  rs2ClickPropertiesFromTheContext = '2. Click "Properties..." from the context menu.';
  rs3NavigateToBetasGameVersions = '3. Navigate to "Betas" (Game Versions && Betas) on the left sidebar.';
  rs4SelectTheLsfgVkBranch = '4. Select the "lsfg-vk" branch (Required files for lsfg-vk) and wait for Steam to update.';

  // mangohud_ui.pas
  rsTimeFormatConfiguration = 'Time Format Configuration';
  rsSelectAPresetOrCustomizeThe = 'Select a preset or customize the std::put_time / strftime format string.';
  rsPreset = 'Preset:';
  rsFormatString = 'Format string:';
  rsPreview = 'Preview:';
  rsStdPutTimeReferenceTHH = 'std::put_time reference: %T (HH:MM:SS), %R (HH:MM), %p (AM/PM), %d (day), %m (month), %Y (year)';
  rsEmpty = '(empty)';
  rsActiveGPU = 'Active GPU';
  rsHorizontalStrech = 'Horizontal Strech';
  rsTextOutline = 'Text outline';
  rsRendersHighContrastOutlineAroundText = 'Renders high-contrast outline around text';
  rsFPSLimit = '⚡ FPS Limit';
  rsEG30601200 = 'e.g. 30,60,120,0 — 0 to unlimited';
  rsFrameTime = 'Frame Time +';
  rsShowDetailedFrameTimingBreakdown = 'Show detailed frame timing breakdown';
  rsConfigureTimeFormat = 'Configure time format';
  rsLoggingToggle = 'Logging toggle';
  rsBenchmarkViewer = 'Benchmark viewer';
  rs0Off = '0 (Off)';

  // optiscaler_tab.pas
  rsDLSSNRWeightsExtractedAndReady = 'DLSS-NR weights extracted and ready. Click to re-select nvngx_dlssnr.dll';
  rsSelectNvngxDlssnrDll = 'Select nvngx_dlssnr.dll...';
  rsSelectNvngxDlssnrDllOrArchive = 'Select nvngx_dlssnr.dll or archive to extract neural rendering model weights';
  rsDLSSNRRequiresNvngxDlssnrDll = 'DLSS-NR requires nvngx_dlssnr.dll';
  rsNvngxDlssnrDllIsRequiredTo = 'nvngx_dlssnr.dll is required to use the DLSS-NR method. Select the DLL to extract model weights.';
  rsSelectDLL = 'Select DLL...';
  rsSelectNvngxDlssnrDllOrArchive2 = 'Select nvngx_dlssnr.dll or archive';
  rsPreparingDLSSNRModelExtraction = 'Preparing DLSS-NR model extraction...';
  rsUniversalUpscalerMiddlewareTranslatingDLSSXe = 'Universal upscaler middleware translating DLSS/XeSS/FSR inputs to modern upscaling and frame generation backends';
  rsOptiscalerMultiFrameGenerationInDirectX = 'Optiscaler + Multi-Frame Generation in DirectX 12 games, Ghostbuster, Phazed HUD and Screen-Space Ray-Traced Global Illumination';
  rsDLSSModelENeuralUpscalerFor = 'DLSS Model E neural upscaler for AMD Radeon GPUs running on Direct3D 12 compute shaders';
  rsDLSS5NeuralRenderingDLSSNR = 'DLSS 5 Neural Rendering (DLSS-NR) for AMD Radeon GPUs';
  rsDisableUpscalingMiddlewareAndRunGames = 'Disable upscaling middleware and run games with native rendering';
  rsProxyDLL = 'Proxy DLL';
  rsGPUDriver = 'GPU Driver';
  rsGPUDriverBackendForOptiScalerDLSS = 'GPU driver backend for OptiScaler (DLSS spoofing, Reflex, and LatencyFlex)';
  rsMenuScale = 'Menu scale';
  rsLogLevel = 'Log level';
  rsVerbosityLevelOfOptiScalerLogsHigher = 'Verbosity level of OptiScaler logs. Higher verbosity (Trace / Debug) may impact gameplay performance. Default is 2 (Info).';
  rsGamesSupported = 'Games supported';
  rsOptiscalerToggle = 'Optiscaler toggle';
  rsDLSSEnablerToggle = 'DLSS-Enabler toggle';
  rsDLSSNRMenu = 'DLSS-NR menu';
  rsInGameShortcutToToggleThe = 'In-game shortcut to toggle the DLSS-NR menu';
  rsFSRVersion = 'FSR Version';
  rsForceFSR4I8 = 'Force FSR4-i8';
  rsForceINT8ModelOnUnsupportedGPUs = 'Force INT8 model on unsupported GPUs';
  rsNativeDLSSExp = 'Native DLSS (Exp.)';
  rsNativeDLSSExperimental = 'Native DLSS (Experimental)';
  rsBypassOptiScalerUsingDirectDLSSLoader = 'Bypass OptiScaler using direct DLSS loader (Single-player only, anti-cheat ban risk)';
  rsWaveSize = 'Wave size';
  rsGPUComputeSubgroupWaveSizeFor = 'GPU compute subgroup/wave size for neural shader execution. Auto chooses the recommended wave size for your GPU (Wave32 on RDNA/NVIDIA, Wave64 on GCN).';
  rsNetworkResolution = 'Network resolution';
  rsNeuralModelReconstructionResolutionFastUses = 'Neural model reconstruction resolution. Fast uses 2x Lanczos upsampling for higher FPS; Full runs inference at native screen resolution for maximum sharpness.';
  rsINT8Acceleration = 'INT8 acceleration';
  rsHardwareAcceleratedINT8QuantizationForNeural = 'Hardware-accelerated INT8 quantization for neural shaders. On boosts FPS on modern GPUs; Off uses FP16 full precision.';
  rsFrameGeneration = 'Frame generation';
  rsDLSSFrameGenerationModelPresetLight = 'DLSS Frame Generation model preset. Light uses preset c for lower latency and higher performance; Full uses DLSS FG 310.3 for maximum visual smoothness.';
  rsArchitecture = 'Architecture';
  rsTargetGPUArchitectureForTheDLSS = 'Target GPU architecture for the DLSS-NR runtime';
  rsRoute = 'Route';
  rsInjectionRouteUsedToFeedThe = 'Injection route used to feed the DLSS-NR pipeline';
  rsModelVersion = 'Model Version';
  rsNeuralNetworkModelVersionUsedBy = 'Neural network model version used by DLSS-NR';
  rsModelScale = 'Model Scale';
  rsNeuralModelResolutionScaleLowerIs = 'Neural model resolution scale (lower is faster, essential on RDNA3)';
  rsPasses = 'Passes';
  rsNumberOfNeuralReconstructionPasses = 'Number of neural reconstruction passes';
  rsFGInput = 'FG Input';
  rsFGOutput = 'FG Output';
  rsForceMLFGInRDNA3 = 'Force MLFG in RDNA3';
  rsEmulateFP8ToActiveMLFG = 'Emulate FP8 to active MLFG';
  rsModelWeights = 'Model Weights';
  rsCheckingWeights = 'Checking weights...';
  rsInt4MixedPrecision = 'Int4 Mixed Precision';
  rsEnableInt4QuantizationForLowerVRAM = 'Enable Int4 quantization for lower VRAM and higher throughput';
  rsRenoDXColorStyle = 'RenoDX Color Style';
  rsApplyHDRColorSpaceHandlingTuned = 'Apply HDR color space handling tuned for RenoDX shaders';
  rsPreprocessAutoExposure = 'Preprocess Auto-exposure';
  rsAutoExposurePreprocessingBeforeNeuralReconst = 'Auto-exposure preprocessing before neural reconstruction';
  rsRunBeforeSR = 'Run before SR';
  rsExecuteDLSSNRDenoisingPassBefore = 'Execute DLSS-NR denoising pass before spatial super-resolution';
  rsAdvancedSettings = '⚙ Advanced Settings...';
  rsAdvancedDLSSNRPipelineParametersRoute = 'Advanced DLSS-NR pipeline parameters (route, color style, filters)';
  rsInGameMenuConfigurationOnly = 'In-game menu configuration only';
  rsDoNotOverwriteOptiScalerIniFrom = 'Do not overwrite OptiScaler.ini from Goverlay (configure in-game instead)';
  rsMissingCompanionLibrariesInheritedFromStable = '* Missing companion libraries inherited from stable cache';
  rsUpdate = 'Update';
  rsLicense = 'License';
  rsUpscaler = 'Upscaler';
  rsReflexAntilag = 'Reflex / Antilag';
  rsUpscalerIsConfiguredViaInGame = 'Upscaler is configured via in-game menu (unmanaged mode)';
  rsSelectedFGInputSource = 'Selected FG Input/Source:';
  rsSelectedFGOutput = 'Selected FG Output:';

  // optiscaler_update.pas
  rsUpdateAvailable = 'Update Available ';
  rsUpdateAvailable2 = ' Update available ';
  rsSelectCustomOptiScalerFolderContainingOptiSc = 'Select Custom OptiScaler Folder (containing OptiScaler.dll)';
  rsSelectFolder = 'Select Folder...';
  rsChooseLocalFolderWithCustomOptiScaler = 'Choose local folder with custom OptiScaler build';
  rsCheckUpdates2 = 'Check updates';
  rsCheckForOptiScalerUpdates = 'Check for OptiScaler updates';
  rsSearchingForUpdates = 'Searching for updates...';
  rsInstallOptiScaler = 'Install OptiScaler';

  // overlay_config.pas
  rsNoConfigurationFilesLocatedCreatingFiles = 'No configuration files located, creating files and folders.';
  rsNoConfigurationFilesLocatedForVkbasalt = 'No configuration files located for vkbasalt, creating files and folders.';

  // overlayunit.pas
  rsNoUpdatesForOptiScalerAvailable = 'No updates for OptiScaler available';
  rsReloadingCustomUserPreset = 'Reloading custom user preset';
  rsInitializationDownloadLogs = 'Initialization & Download Logs';
  rsGoverlayInitializationLogs = '  💻 Goverlay Initialization Logs';
  rsDetails = '>_ Details';
  rsColorGrading = 'Color Grading';
  rsFrameInterpolation = 'Frame Interpolation';
  rsEnvVars = 'EnvVars';
  rsArguments = 'Arguments';
  rsOpenConfigFolder = 'Open config folder';
  rsOpenLogFolder = 'Open log folder';
  rsSaved = '✓ Saved';
  rsSearchCtrlF = '🔍 Search... (Ctrl+F)';
  rsProtontricksIntegrationIsNotAvailableIn = 'Protontricks integration is not available in the Flatpak version.';
  rsSaveACustomConfFileLoad = 'Save a custom.conf file load the custom config';
  rsStatus = 'Status';
  rsMissing = 'Missing: ';
  rsGameModeIsNotInstalledInstallGamemode = 'GameMode is not installed - install gamemode package to enable this feature';
  rsPasCubeWasNotLocatedUsingVkcube = 'PasCube was not located, using vkcube instead';
  rsPasCubeAndVkCubeWereNotLocated = 'PasCube and VkCube were not located.';
  rsUseHistogramForFrametimeInformation = 'Use histogram for frametime information';
  rsUseRegularCurveForFrametimeInformation = 'Use regular curve for frametime information';
  rsIsNotInstalled = ' is not installed';
  rsMissingFlatpakExtensionRun = 'Missing Flatpak extension. Run:  ';
  rsSystemPackageNotFoundPleaseInstall = 'System package not found. Please install ''';
  rsUsingYourPackageManager = ''' using your package manager.';
  rsReCheck = 'Re-check';
  rsAllRequiredDependenciesDetected = 'All required dependencies detected.';
  rsPreparingHelixSRNeuralCompilation = 'Preparing HelixSR neural compilation...';
  rsDownloadingReshadeShadersD = 'Downloading reshade shaders: %d%%';
  rsUseVerticalBarsForCoreLoad = 'Use vertical bars for core load';
  rsUsePercentageNumbersForCoreLoad = 'Use percentage numbers for core load';
  rsDisplay01LowFps = 'Display 0.1% low fps';
  rsDisplay1LowFps = 'Display 1% low fps';
  rsSettingsSavedAsCustomConfig = 'Settings saved as custom config';
  rsConfigurationLoadedSuccessfully = ' configuration loaded successfully';
  rsConfigurationExportedTo = 'Configuration exported to: ';
  rsSwitchToDarkTheme = 'Switch to Dark theme';
  rsSwitchToLightTheme = 'Switch to Light theme';
  rsSteamDeckPreset = 'Steam Deck Preset ';
  rsSavedSuccessfully = ' saved successfully!';
  rsCaptureKey = 'Capture Key';
  rsPressTheKeyCombinationYouWant = 'Press the key combination you want to use as shortcut.';
  rsPressESCToCancel = '(Press ESC to cancel)';
  rsGlobalConfigurationsClonedSuccessfullyFor = 'Global configurations cloned successfully for ';
  rsPasCubeAndVkCubeNotFound = 'PasCube and VkCube not found.';

  // protontricksunit.pas
  rsApplyingWindowsVersion = 'Applying Windows version ';
  rsTo = ' to ';
  rsApplied = '✓ Applied ';
  rsSuccessfully = ' successfully!';
  rsProtontricksExitedWithCode = '✗ protontricks exited with code ';
  rsGamesOnExternalDrivesShowUnknown = '⚠ Games on external drives show "unknown". Grant access via Flatseal → Filesystem.';

  // reshade_tab.pas
  rsPostProcessingIsDisabledSelectReShade = 'Post-processing is disabled. Select ReShade or vkBasalt above to configure effects.';
  rsToggle = 'Toggle:';
  rsProxyDLL2 = 'Proxy DLL:';
  rsOptiScalerCoExistenceReShadeAndOptiScaler = 'OptiScaler Co-existence: ReShade and OptiScaler cannot share the same Proxy DLL. Choose a different DLL (e.g. d3d11.dll or version.dll).';
  rsOpenShadersDirectory = 'Open Shaders Directory';
  rsChecking = 'Checking...';
  rsInstall = 'Install';
  rsOptions = 'Options';
  rsInstalled2 = '✔ Installed';
  rsReInstall = 'Re-install';
  rsDownloading = 'Downloading...';
  rsUpdating = 'Updating...';
  rsProxyDLLConflict = 'Proxy DLL Conflict';

  // sidebar_nav.pas
  rsWinePrefix = 'Wine Prefix';
  rsAutoLaunchPasCube = 'Auto launch PasCube';
  rsCreateSteamShortcut = 'Create Steam shortcut';
  rsShowLaunchSplashScreen = 'Show launch splash screen';
  rsVideoTutorial = 'Video tutorial';

  // tweaks_md3.pas
  rsEnableAMDAntiLag2 = 'Enable AMD Anti-Lag 2';
  rsAutomaticallyUpgradeFSRToTheLatest = 'Automatically upgrade FSR to the latest version';
  rsAutomaticallyUpgradeDLSSToTheLatest = 'Automatically upgrade DLSS to the latest version';
  rsAutomaticallyUpgradeXeSSToTheLatest = 'Automatically upgrade XeSS to the latest version';
  rsEnableREEngineRayTracingWorkaround = 'Enable RE Engine Ray Tracing workaround';
  rsExposeToEnableTheLayer = 'Expose to enable the layer';
  rsExposeReflexSupport = 'Expose Reflex support';
  rsExposeReflexSupportVKNVLow = 'Expose Reflex support (VK_NV_low_latency2) instead of AMD Anti-Lag 2 (Needs Korthos low latency)';
  rsReportDeviceAsNVIDIAGPU = 'Report device as NVIDIA GPU';
  rsReportDeviceAsNVIDIAGPUBreaks = 'Report device as NVIDIA GPU (breaks FSR4 upgrade path) (Needs Korthos low latency)';
  rsAlsoHideAMDGPU = 'Also hide AMD GPU';
  rsAlsoHideAMDGPUButIt = 'Also hide AMD GPU, but it''s safer than SPOOF_NVIDIA (Needs Korthos low latency)';
  rsEnablePROTONVKD3DLOWLATENCYPROTONDXVK = 'Enable PROTON_VKD3D_LOWLATENCY / PROTON_DXVK_LOWLATENCY';
  rsEnablePROTONLOCALSHADERCACHE = 'Enable PROTON_LOCAL_SHADER_CACHE';
  rsEnablePROTONDISCORDBRIDGE = 'Enable PROTON_DISCORD_BRIDGE';
  rsEnableVKD3DCONFIGDescriptorHeap = 'Enable VKD3D_CONFIG=descriptor_heap';
  rsEnableNGXDLSSRROVERRIDE = 'Enable NGX_DLSS_RR_OVERRIDE';
  rsEnableVKD3DRTASSIZEMULT = 'Enable VKD3D_RTAS_SIZE_MULT';
  rsVulkanLowLatencyLayerIsNot = 'vulkan-low-latency-layer is not installed. Please install Korthos low latency layer first.';
  rsGamemodeIsNotInstalledPleaseInstall = 'gamemode is not installed. Please install the gamemode package first.';
  rsInvalidLaunchArgumentMustStartWith = 'Invalid launch argument. Must start with "-", "--", or "+".';

  // vkbasalt_tab.pas
  rsReshadeEffects = 'Reshade Effects';
  rsBuiltInEffects = 'Built-in Effects';
  rsColorLUT = 'Color LUT';
  rsBrowse = 'Browse...';
  rsEffectPipeline = 'Effect Pipeline';
  rsRestoreDefaults = 'Restore Defaults';
  rsResetAllVkBasaltSlidersAndActive = 'Reset all vkBasalt sliders and active effects';
  rsSplitCompare = 'Split compare';
  rsSplitCompareAB = 'Split compare (A/B)';
  rsSplitsScreenComparingOriginalImageLeft = 'Splits screen comparing original image (left) with color-graded image (right)';
  rsColorBlindness = 'Color blindness:';
  rsColorBlindnessCompensationDaltonize = 'Color blindness compensation (Daltonize)';
  rsToggleKey = 'Toggle key:';
  rsRestoreDefault = 'Restore default';
  rsSelect3DLUTFile = 'Select 3D LUT File';
  rsDownloadingReshadeShaders = 'Downloading reshade shaders...';
  rsStarting = 'Starting...';
  rsUpdatingRepository = 'Updating repository...';
  rsCloningRepository = 'Cloning repository...';
  rsCompleted = 'Completed';
  rsReshadeShadersAreReady = 'Reshade shaders are ready';

  { tweaks_md3 - the Tweaks tab draws these from runtime tables }
  rsActivateVulkanCaptureForOBSStudio = 'Activate Vulkan capture for OBS Studio';
  rsActiveProtonLogs = 'Active Proton Logs';
  rsAdvancedTweaks = 'Advanced Tweaks';
  rsAllows32BitGamesToUse = 'Allows 32-bit games to use more than 2GB RAM';
  rsAlternativeDescriptorHeap = 'Alternative descriptor heap';
  rsBasicTweaks = 'Basic Tweaks';
  rsCachyosSetsCPUGovernorToPerformance = '[cachyos] Sets CPU governor to performance';
  rsCustom = 'Custom';
  rsDelayInHeapAllocationWine = 'Delay in heap allocation (Wine)';
  rsDisableJoystickSubsystem = 'Disable joystick subsystem';
  rsDisableNTSYNC = 'Disable NTSYNC';
  rsDisablesFastClearOptimizationAMD = 'Disables fast clear optimization (AMD)';
  rsEmulatesRTOnOlderAMDGPUs = 'Emulates RT on older AMD GPUs';
  rsEnableHDR = 'Enable HDR';
  rsEnableWayland = 'Enable Wayland';
  rsExperimental = 'Experimental';
  rsForceDirectX11Backend = 'Force DirectX 11 backend';
  rsForceDirectX12Backend = 'Force DirectX 12 backend';
  rsForceEnableNVAPI = 'Force enable NVAPI';
  rsForceNativeVulkanRenderer = 'Force native Vulkan renderer';
  rsGeneral = 'General';
  rsGraphics = 'Graphics';
  rsHideNvidiaGPU = 'Hide Nvidia GPU';
  rsLatencyReduction = 'Latency reduction';
  rsLaunchArguments = 'Launch Arguments';
  rsLowLatencyLayerAlsoHideAMD = '[low_latency_layer] Also hide AMD GPU';
  rsLowLatencyLayerExposeReflexSupport = '[low_latency_layer] Expose Reflex support';
  rsLowLatencyLayerExposeToEnable = '[low_latency_layer] Expose to enable the layer';
  rsLowLatencyLayerReportDeviceAs = '[low_latency_layer] Report device as NVIDIA GPU';
  rsMESAEnableAMDAntiLag2 = '[MESA] Enable AMD Anti-Lag 2';
  rsMESAUsesOpenGLOverVulkanTranslation = '[MESA] Uses OpenGL over Vulkan translation (ZINK)';
  rsMemoryOptimizationForAMDGPUs = 'Memory optimization for AMD GPUs';
  rsMultiplierForRayTracingAccelerationStructure = 'Multiplier for Ray Tracing Acceleration Structures size';
  rsNvidiaActivatesRayReconstruction = '[nvidia] Activates Ray Reconstruction';
  rsPerformance = 'Performance';
  rsProtonCachyosEnableDiscordSRich = '[proton-cachyos] Enable Discord''s Rich Presence.';
  rsProtonCachyosEnablePerGameShader = '[proton-cachyos] Enable per-game shader cache';
  rsProtonCachyosLowLatencyFramePacing = '[proton-cachyos] low-latency frame pacing (DX11 & DX12)';
  rsSimulateSteamDeckHardware = 'Simulate Steam Deck hardware';
  rsSkipIntroVideosAndLogos = 'Skip intro videos and logos';
  rsUseFeralGamemodeSetOfOptimisations = 'Use Feral Gamemode set of optimisations';
  rsUseOldWINED3D = 'Use old WINED3D';
  rsUseSDLInputInsteadSteamInput = 'Use SDL input instead steam input';
  rsWindows64BitCompatibility = 'Windows 64-bit compatibility';
  { tweaks_md3 - hint panel and dialogs }
  rsActive = ' active';
  rsAddEnvironmentVariable = 'Add Environment Variable';
  rsAddLaunchArgument = 'Add Launch Argument';
  rsAlternativeDescriptorHeapForD3D12Fixes = 'Alternative descriptor heap for D3D12. Fixes ray tracing in Control Resonant and similar titles, but may decrease performance or crash in other games.';
  rsCustomArguments = 'Custom Arguments';
  rsCustomEnvironmentVariable = 'Custom environment variable';
  rsCustomItemsAddedInGlobalMode = 'Custom items added in Global mode are cataloged and can be toggled per game.';
  rsCustomLaunchArgument = 'Custom launch argument';
  rsDisablesWineDetectionInREEngine = 'Disables Wine detection in RE Engine games to avoid crashes or black screens.';
  rsEnterLaunchArgumentArgOrArg = 'Enter launch argument (-arg or +arg):';
  rsEnterMultiplierForRayTracingAcceleration = 'Enter multiplier for Ray Tracing Acceleration Structures size:';
  rsExperimentalOptionsCanCauseInstabilityOr = 'Experimental options can cause instability or crashes. Use with caution.';
  rsForcesNVIDIADLSSRayReconstructionOn = 'Forces NVIDIA DLSS Ray Reconstruction on supported hardware and titles.';
  rsForcesOpenGLToRunOverVulkan = 'Forces OpenGL to run over Vulkan via Mesa Zink driver (experimental).';
  rsGameModeIsNotInstalled = 'GameMode is not installed';
  rsGameSpecificCustomVariable = 'Game-specific custom variable';
  rsGameSpecificLaunchArgument = 'Game-specific launch argument';
  rsGlobalCatalogArgument = 'Global catalog argument';
  rsGlobalCatalogItemsAreListedBelow = 'Global catalog items are listed below. Toggling applies only to this game.';
  rsGlobalCatalogPreset = 'Global catalog preset';
  rsKorthosLowLatencyIsNotInstalled = 'Korthos Low Latency is not installed';
  rsMultipliesRayTracingAccelerationStructuresBu = 'Multiplies Ray Tracing Acceleration Structures buffer size by 8 to prevent RT out-of-memory crashes.';
  rsNeedsKorthosLowLatency = 'Needs Korthos low latency';
  rsNoCustomArgumentsAddedYetClick = '＋ No custom arguments added yet. Click the + button to create one.';
  rsNoCustomVariablesAddedYetClick = '＋ No custom variables added yet. Click the + button to create one.';
  rsPredefinedArguments = 'Predefined Arguments';
  rsSystemPackageNotFoundPleaseInstall2 = 'System package not found. Please install ''vulkan-low-latency-layer'' using your package manager.';
  rsSystemPackageNotFoundPleaseInstall3 = 'System package not found. Please install ''gamemode'' using your package manager.';
  rsVKD3DRTASSizeMultiplier = 'VKD3D RTAS Size Multiplier';
  rsVariables = ' Variables';
  rsWorksOnlyWithCachyOS = 'Works only with CachyOS';

implementation

end.
