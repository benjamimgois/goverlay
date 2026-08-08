# Design: Boot Splash UI Redesign with Branding Banner & Terminal Details Window

## Context

The current boot splash displays a small 48x48 icon, a standard text label "Goverlay", a thin 12px progress bar, and separate status/percentage labels below. Users requested a sleeker layout using the GitHub branding image, embedded progress text in a thicker progress bar, and an interactive "Details" button to inspect live terminal logs during initialization.

## Technical Architecture

```
┌────────────────────────────────────────────────────────┐
│                                                        │
│       [ Goverlay Linux gaming tools, made easy ]       │  (FSplashBrandingImage)
│                                                        │
│   ┌──────────────────── 42% ──────────────────────┐    │  (24px Custom Progress Bar)
│   └───────────────────────────────────────────────┘    │
│                                                        │
│   Downloading DLSS-Enabler stable       [ >_ Details ] │  (Bottom bar & Terminal button)
└────────────────────────────────────────────────────────┘
                           │
                           ▼ (click)
┌────────────────────────────────────────────────────────┐
│  💻 Startup & Download Logs                        [X] │
├────────────────────────────────────────────────────────┤
│ [BGMOD] Checking for auto-migration...                 │
│ [AUTO-INSTALL] Checking OptiScaler stable...           │
│ [DLSS-ENABLER] Fetching builds via HTML...             │
│ [DLSS-ENABLER] Download completed, extracting...       │
└────────────────────────────────────────────────────────┘
```

## Detailed Design Components

### 1. Header Branding Image
- Replace `FSplashLogoImage` (48x48) and `FSplashTitleLabel` ("Goverlay") with `FSplashBrandingImage` (`TImage`).
- Asset path: `data/goverlay_branding.png` (with fallback to `GetIconFile` if missing).
- Position: Centered horizontally (`(SW - 320) div 2`), top: `32px`, width: `320px`, height: `90px`.
- Options: `Stretch := True`, `Proportional := True`, `Transparent := True`.

### 2. Thicker Progress Bar with Embedded Percentage Text
- Set progress bar bounds: `SetBounds(32, 230, SW - 64, 24)`.
- Use a custom paint procedure `OnPaint` / `OnPostPaint` or overlay label centered over the progress bar:
  - `FSplashPercentLabel` centered at `(32, 232, SW - 64, 20)`.
  - Alignment: `taCenter`.
  - Font: `Noto Sans`, 10pt Bold, Color: `clWhite` (high contrast over cyan progress fill).

### 3. Bottom Row: Status Text & Details Button
- **Status Text (`FSplashDetailLabel`)**: Left-aligned at `(32, 280, SW - 160, 24)`.
- **Details Button (`FSplashDetailsButton`)**:
  - Right-aligned at `(SW - 120, 275, 88, 30)`.
  - Caption: `>_ Details` or `Terminal`.
  - Dark button styling with cyan border/text.
  - OnClick: Toggles or opens `FSplashLogForm`.

### 4. Real-time Terminal Log Modal (`FSplashLogForm`)
- Single instance dark form `FSplashLogForm` (Width: 640, Height: 400, Caption: "Initialization Logs").
- Contains `TMemo` (`FSplashLogMemo`):
  - Read-only, `ScrollBars := ssVertical`.
  - Font: Monospace (`Courier New`, `DejaVu Sans Mono`, or `Consolas`), 9pt.
  - Colors: Background `#0A101C`, Text `#00FFC8` / `#D2DCEB`.
- Log Collector (`AddSplashLog(const AMsg: string)`):
  - Global thread-safe log buffer (`FSplashLogList: TStringList`).
  - Automatically appends logs from `WriteLn`, `UpdateStatus`, and `[AUTO-INSTALL]` output.
  - Immediately appends to `FSplashLogMemo.Lines` if form is created.
