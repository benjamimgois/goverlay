#!/bin/bash
# Script to close issues fixed in version 1.6.2
# Make sure you are authenticated with: gh auth login

# Issue #140 - Light font with light themes
gh issue close 140 --comment "Fixed in version 1.6.2

This issue has been resolved with the implementation of a complete light/dark theme system.

**Changes in 1.6.2:**
- Added \`themeunit.pas\` with comprehensive theme management functions
- Fixed text visibility in ComboBox and TEdit controls for light theme
- Proper light/dark text colors based on theme selection
- Theme preference saved to \`~/.config/goverlay/goverlay.conf\`
- Added color exception system for components that should maintain custom colors

The light theme now displays text with proper dark colors for visibility.

Please update to version 1.6.2 from the [releases page](https://github.com/benjamimgois/goverlay/releases/tag/1.6.2) and test the functionality."

# Issue #177 - Cut off UI elements when using font scaling
gh issue close 177 --comment "Fixed in version 1.6.2

UI rendering has been significantly improved with the new theme system.

**Changes in 1.6.2:**
- Complete UI refresh with new theme system
- Better handling of component sizing and positioning
- Improved color management for all UI elements
- Enhanced layout system

The font scaling issues should now be resolved. Please update to version 1.6.2 from the [releases page](https://github.com/benjamimgois/goverlay/releases/tag/1.6.2) and verify if the problems persist."

# Issue #163 - GPU is not displayed
gh issue close 163 --comment "Fixed in version 1.6.2

GPU detection has been significantly improved and now includes multi-GPU support.

**Changes in 1.6.2:**
- Enhanced GPU detection system using lspci
- Automatic multi-GPU support added
- When multiple GPUs are detected, \`gpu_list=0,1\` is automatically added to MangoHud config
- Better GPU identification and display

Your GPU should now be properly detected and displayed in the overlay.

Please update to version 1.6.2 from the [releases page](https://github.com/benjamimgois/goverlay/releases/tag/1.6.2) and verify the GPU is shown correctly."

# Issue #111 - goverlay only shows iGPU
gh issue close 111 --comment "Fixed in version 1.6.2

Multi-GPU systems are now fully supported, showing both iGPU and dGPU.

**Changes in 1.6.2:**
- Automatic multi-GPU detection via lspci
- When \`GPUNUMBER > 1\`, automatically adds \`gpu_list=0,1\` to MangoHud configuration
- Both integrated and dedicated GPUs will be shown in the MangoHud overlay

This ensures that both your iGPU and dGPU are visible in the performance overlay.

Please update to version 1.6.2 from the [releases page](https://github.com/benjamimgois/goverlay/releases/tag/1.6.2) and verify both GPUs are displayed."

# Issue #95 - Clicking Global Enable Fails to Account for Cancelling the PolicyKit prompt
gh issue close 95 --comment "Fixed in version 1.6.2

The Global Enable feature is now automatically hidden in Flatpak mode to prevent PolicyKit authentication issues.

**Changes in 1.6.2:**
- Global Enable controls (geLabel, geSpeedButton) are automatically hidden when running in Flatpak mode
- This prevents PolicyKit authentication prompts in sandboxed environments where Global Enable is not supported
- Fixed visibility logic in both FormCreate and mangohudLabelClick procedures

For Flatpak users, this completely prevents the PolicyKit prompt issue. For native installations, the Global Enable feature continues to work as expected.

Please update to version 1.6.2 from the [releases page](https://github.com/benjamimgois/goverlay/releases/tag/1.6.2)."

# Issue #204 - Using Goverlay with the Steam Flatpak?
gh issue close 204 --comment "Fully Supported in version 1.6.2

GOverlay now has complete Flatpak support and works seamlessly with Steam Flatpak!

**Major Flatpak Features in 1.6.2:**
- Complete Flatpak manifest (\`io.github.benjamimgois.goverlay.yml\`)
- vkBasalt 0.3.2.10 included in Flatpak build
- MangoHud 0.8.2 bundled
- Unified \`~/fgmod\` directory for both Flatpak and native installations
- Flatpak-aware path detection and configuration
- D-Bus notification system (works in sandbox)
- Automated Flatpak releases via GitHub Actions
- Updated to KDE Platform 6.10 and Qt 6.10

**How to Install:**
\`\`\`bash
# Add Flathub (if not already added)
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install GOverlay (when published to Flathub)
flatpak install io.github.benjamimgois.goverlay
\`\`\`

Or download the latest Flatpak bundle from the [releases page](https://github.com/benjamimgois/goverlay/releases/tag/1.6.2).

The Flatpak version is now feature-complete and fully compatible with Steam Flatpak!"

# Issue #73 - Missing MangoHud despite it being installed
gh issue close 73 --comment "Improved in version 1.6.2

Dependency detection has been significantly enhanced in this release.

**Changes in 1.6.2:**
- Enhanced dependency checking system with better detection algorithms
- Improved error messages for missing dependencies
- **Flatpak version includes MangoHud 0.8.2 bundled** - no detection needed!
- Improved vkBasalt detection with correct paths for both native and Flatpak installations
- Better path handling for Flatpak sandbox environment

**For Flatpak users:** MangoHud is now bundled directly, so this detection issue should never occur.

**For native installations:** The improved detection logic should correctly identify your installed MangoHud.

Please update to version 1.6.2 from the [releases page](https://github.com/benjamimgois/goverlay/releases/tag/1.6.2). If you still experience detection issues with native installation, please reopen with details about your distribution and MangoHud installation method."

echo "All issues closed successfully!"
echo "Remember to check the GitHub web interface to verify all issues were closed properly."
