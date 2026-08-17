## Why

The current GOverlay interface features a permanent 40px bottom bar (`goverlaybarPanel`) that occupies vertical screen real estate across all configuration tabs. This bar displays a static Steam launch command text box that users rarely need to inspect continuously, along with scattered action buttons. Furthermore, new users often struggle to understand how and where to apply the generated launch command in Steam or Heroic.

Replacing the fixed bottom bar with a modern, compact **Floating Action Dock** (Pill style), a dedicated **Finish Configuration Dialog** featuring lightweight custom step-by-step animations, and floating overlay notifications (auto-save toast and download progress banner) modernizes GOverlay's visual design, frees valuable vertical space for tab content, and creates a clear, user-friendly onboarding and launch setup experience.

## What Changes

- **Remove Legacy Bottom Bar**: Hide/deprecate `goverlaybarPanel` and its embedded static controls (`commandPanel`, `geSpeedButton`, `notificationLabel`, etc.), allowing tab content to utilize the full height of the main window.
- **Floating Action Dock (Pill)**: Introduce a sleek floating action pill dock anchored at the bottom-right of the interface:
  - `[ ▶ Preview ]`: Quick 3D preview button (pascube/vkcube) displayed dynamically on tabs with 3D overlay support (MangoHud, vkBasalt, vkSumi) and hidden on tabs without preview (OptiScaler, EnvVars).
  - `[ ☰ Menu ]`: Quick menu button triggering options/presets/blacklist popup.
  - `[ 🚀 Finish Config ]`: High-visibility primary action button available across all configuration tabs.
- **Finish Configuration Popup Dialog**: A dedicated, modern modal dialog that opens when clicking `Finish Config`:
  - Platform selector for **Steam** and **Heroic Games Launcher**.
  - Lightweight custom-rendered step-by-step animations showing exactly where to paste launch options.
  - Generated launch command box with a single-click `[ 📋 Copy Command ]` button and immediate `[ ✓ Copied! ]` visual feedback.
  - Clear step-by-step instructions in English.
- **Floating Auto-Save Toast**: Replace the static "✓ Saved" label with a discrete floating toast notification in the bottom-left corner that fades in and out automatically upon saving.
- **Floating Download Progress Banner**: Replace the embedded bottom progress bar with a temporary floating progress overlay banner that appears during component downloads (e.g. startup DLSS Enabler checks, shader updates) and hides upon completion.
- **English Localization**: Ensure all new notifications, dialog texts, tooltips, and instructions are exclusively in English.

## Capabilities

### New Capabilities
- `floating-action-dock`: Floating pill-style action bar hosting contextual Preview, Menu, and Finish Config action buttons across all configuration tabs.
- `finish-configuration-dialog`: Interactive modal dialog displaying platform-specific launch command instructions with custom visual animations, one-click copy, and launch setup guidance in English.
- `floating-status-and-progress-overlays`: Floating toast notification for automatic configuration save confirmation and floating progress banner for background downloads.

### Modified Capabilities
- `standardized-command-panel-width`: Replaces fixed bottom-bar anchoring with the floating action dock and modal dialog.

## Impact

- `overlayunit.pas` / `overlayunit.lfm`: Removal of `goverlaybarPanel` dependency, integration of floating dock, floating save toast, and floating download banner.
- `games_tab.pas`, `optiscaler_tab.pas`, `vkbasalt_tab.pas`, `tweaks_md3.pas`: Updates to tab bottom margins and preview button ownership.
- New unit(s) for the Finish Configuration Dialog and custom tutorial animation renderer.
- User experience: cleaner UI layout, increased vertical content area, and a streamlined finalization workflow.
