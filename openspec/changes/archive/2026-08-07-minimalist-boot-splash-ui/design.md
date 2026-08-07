# Design Document: Minimalist Boot Splash UI

## Context & Requirements
The user requested a sleek, modern redesign of the startup boot splash window to match an attached reference mockup (`media__1786110376856.png`). The redesign requires a 2D vector dark-navy gradient background, top branding ("Goverlay" + "git testing build"), clean open middle space, and lower-third elements: centered action label (`Ação: Extraindo core...`), cyan progress bar, left-aligned component detail (`OptiScaler (Edge): Extraindo core...`), and right-aligned percentage (`41%`).

## Architectural Decisions

### 1. Form Canvas and Custom Gradient Painting
- Set `FSplashForm.Width := 560` and `FSplashForm.Height := 360`.
- Assign `FSplashForm.OnPaint` handler to fill the background with a smooth vertical dark navy gradient from `RGBToColor(14, 24, 42)` at the top to `RGBToColor(6, 10, 20)` at the bottom.

### 2. Header Branding
- **Logo Image**: 48x48 px `TImage`, positioned at `(SW - 48) div 2, 28`.
- **Title Label**: `TLabel` positioned below logo with `Font.Size := 22`, `Font.Style := [fsBold]`, `Font.Color := clWhite`, `Alignment := taCenter`.
- **Subtitle Label**: `TLabel` positioned below title with `Font.Size := 10`, `Font.Color := RGBToColor(160, 175, 200)`, `Alignment := taCenter`, `Caption := 'git testing build'`.

### 3. Lower-Third Controls Layout
- **Action Label (`FSplashActionLabel`)**: Centered above progress bar with `Font.Size := 10`, `Font.Color := RGBToColor(200, 210, 225)`, `Alignment := taCenter`.
- **Progress Bar (`FSplashProgressBar`)**: Height `12 px`, cyan/teal accent color.
- **Detail Label (`FSplashDetailLabel`)**: Left-aligned below progress bar with `Font.Size := 10`, `Font.Color := RGBToColor(210, 220, 235)`.
- **Percentage Label (`FSplashPercentLabel`)**: Right-aligned below progress bar with `Font.Size := 10`, `Font.Color := RGBToColor(56, 189, 201)`.

### 4. Status Text Parsing
- Update `UpdateBootSplash` to extract action verb phrase for `FSplashActionLabel` and component detail for `FSplashDetailLabel`.
