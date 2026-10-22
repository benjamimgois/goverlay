# Proposal

## Why

Many users do not check the "Home / Status" screen (which is now in the settings menu since GOverlay defaults to the MangoHud Presets tab) and do not realize that required system packages or Vulkan layer runtimes (such as MangoHud or vkBasalt) are not installed on their system. When they configure settings and launch a game, the overlays do not appear, leading users to mistakenly believe GOverlay is malfunctioning.

Displaying prominent, actionable warning banners on tool tabs when their required system runtime or library is missing—while disabling their configuration controls and Save button—prevents user confusion, provides clear installation commands (for both Flatpak and native package managers), and allows users to jump to the status screen or re-check dependencies directly.

## What Changes

- **Missing Dependency Warning Banner**: Introduce a reusable, theme-aware warning banner component on tool pages when required libraries or Vulkan runtimes are missing.
  - **MangoHud Tab**: Display a warning banner at the top of MangoHud pages if `mangohud` (native binary) or `DEP_MANGOHUD_RUNTIME` (Flatpak extension) is missing. Disable MangoHud controls (`SetControlTreeEnabled`) and disable the Save button.
  - **Post Processing Tab (vkBasalt)**: When the selected method is `vkBasalt`, display a warning banner if `vkbasalt` / Vulkan layer is missing. Disable the vkBasalt configuration cards and disable the Save button. When switched to `ReShade` or `None`, hide the vkBasalt warning banner.
  - **Actionable Guidance**: The banner informs the user whether they are on Flatpak (showing the exact `flatpak install org.freedesktop.Platform.VulkanLayer...` command) or on native Linux (showing the package manager instruction), and provides a "View Status" button (navigating to the Home/Status screen) and a "Re-check" button.
- **Sidebar Navigation Visual Cue**: Nav items for tools with missing required runtimes display a subtle visual indicator (or tooltip hint) so users can immediately notice missing dependencies while retaining the ability to click and open the tab.

## Capabilities

### New Capabilities
- `missing-dependency-warning-banners`: Warning banners and control deactivation on tool tabs when required system runtimes or packages are not installed.

### Modified Capabilities
<!-- None: existing spec requirements remain intact -->

## Impact

- `overlayunit.pas`: Integration of the banner on MangoHud tabs and coordinating control disabling / Save button states.
- `reshade_tab.pas` / `vkbasalt_tab.pas`: Method-dependent warning banner display and card deactivation when `rmVkBasalt` is selected without vkBasalt installed.
- `sidebar_nav.pas`: Sidebar navigation updates for indicator/state awareness and control enabling/disabling.
- `goverlay_system.pas` / `home_tab.pas`: Reusable dependency checking integration and status navigation.
- `tests/gui/gui_test_cases.pas`: Automated GUI tests verifying banner visibility, control disabled state, method-switching reactivity, and re-check behavior.
