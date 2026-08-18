# Design: Lossless Scaling Tab Integration

## 1. UI Architecture & Layout

### Tab Hierarchy (`goverlayPageControl`)
Inside `overlayunit.pas`, `losslessScalingTabSheet: TTabSheet` will be instantiated as a child of `goverlayPageControl`:
- `losslessScalingTabSheet.Caption := 'Lossless Scaling';`
- `losslessScalingTabSheet.TabVisible := False;` (initially)

### Navigation Handler (`optiscalerLabelClick` in `overlayunit.pas` / `sidebar_nav.pas`)
When "Upscalers" is clicked:
```pascal
procedure Tgoverlayform.optiscalerLabelClick(Sender: TObject);
begin
  SetNavActive(3);
  
  // Show tabs in top navigation
  goverlayPageControl.ShowTabs := True;
  vkbasalttabsheet.TabVisible  := False;
  vksumiTabSheet.TabVisible    := False;
  tweakstabsheet.TabVisible    := False;
  gamesTabSheet.TabVisible     := False;
  FHomeTabSheet.TabVisible     := False;
  
  // Expose both Upscalers tabs
  optiscalertabsheet.TabVisible      := True;
  losslessScalingTabSheet.TabVisible := True;
  
  // Default to optiscalerTabSheet if not already on lossless
  if goverlayPageControl.ActivePage <> losslessScalingTabSheet then
    goverlayPageControl.ActivePage := optiscalerTabSheet;
    
  ...
end;
```

---

## 2. Component Design (`lossless_scaling_tab.pas`)

### Visual Wireframe & Card Structure
```
┌─────────────────────────────────────────────────────────────────────────────┐
│ ┌─ General & DLL Setup ───────────────────────────────────────────────────┐ │
│ │ Path to Lossless.dll:                                                   │ │
│ │ [ ~/.local/share/Steam/steamapps/.../Lossless.dll ] [ 📁 ] [ 🔍 Auto ]  │ │
│ │ ● DLL Status: Valid Lossless.dll detected                               │ │
│ └─────────────────────────────────────────────────────────────────────────┘ │
│ ┌─ Frame Generation ──────────────────────────────────────────────────────┐ │
│ │ Multiplier:       (● 2x)   (○ 3x)   (○ 4x)                              │ │
│ │ Flow Scale:       [═══════════════════●] 100% (Default)                 │ │
│ │                   "Lower internal motion estimation for higher speed"   │ │
│ │ Performance Mode: [■ Enable Performance Mode]                           │ │
│ │                   "Massively improves performance at slight quality loss│ │
│ └─────────────────────────────────────────────────────────────────────────┘ │
│ ┌─ Hardware & Pacing ─────────────────────────────────────────────────────┐ │
│ │ Precision:        [ ] Disable FP16 (Half-Precision)                     │ │
│ │ Pacing Mode:      [ VSync / FIFO (Default)                           ▼] │ │
│ │ Target GPU:       [ Auto (Primary Display GPU)                       ▼] │ │
│ └─────────────────────────────────────────────────────────────────────────┘ │
│ ┌─ Launch Options & Environment Preview ──────────────────────────────────┐ │
│ │ LSFGVK_ENV=1 LSFGVK_DLL_PATH="..." LSFGVK_MULTIPLIER=2 %command%        │ │
│ │                                                          [ 📋 Copy ]    │ │
│ └─────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Layout Tokens & Theming
- Base Dark Theme: `DARK_TAB_BG` (`#161A28`), `DARK_CARD_BG` (`#1A1E2E`), `DARK_CARD_BORDER` (`#202634`).
- Main Cards styled via `StyleMainCard(CardPanel, TitleLabel, Caption)`.
- Input fields styled via `StyleInputControl(Edit / ComboBox)`.
- Toggles styled via `StyleToggleControl(CheckBox / RadioButton)`.
- Action buttons styled via `StyleActionButton(Button)`.

---

## 3. Data Flow & Variable Serialization

### Environment Variables Mapping
1. **Base Variable**:
   - `LSFGVK_ENV=1` (Always emitted when layer is active).
2. **DLL Path**:
   - `LSFGVK_DLL_PATH=<PathToDll>`
3. **Multiplier**:
   - `LSFGVK_MULTIPLIER=2|3|4`
4. **Flow Scale**:
   - `LSFGVK_FLOW_SCALE=0.25`..`1.0` (TrackBar value / 100).
5. **Performance Mode**:
   - `LSFGVK_PERFORMANCE_MODE=1` (if enabled; omitted or `0` if disabled).
6. **FP16 Override**:
   - `LSFGVK_NO_FP16=1` (if disabled; omitted if half-precision enabled).
7. **Pacing Mode**:
   - `LSFGVK_PACING=default|vsync|mailbox|immediate|none`
8. **GPU Selection**:
   - `LSFGVK_GPU=<Index|Auto>`

### Global Persistence (`~/.config/goverlay/lossless_scaling.ini`)
```ini
[LosslessScaling]
DllPath=~/.local/share/Steam/steamapps/common/Lossless Scaling/Lossless.dll
Multiplier=2
FlowScale=100
PerformanceMode=0
NoFp16=0
Pacing=default
GpuIndex=0
```

### Per-Game Integration (`bgmod` & `games_tab.pas`)
In per-game configuration:
- In `bgmod.conf`: under `[Env]`, write active `LSFGVK_*` variables when enabled for the selected game profile.
- In custom launch options string generation: inject `LSFGVK_ENV=1 ... %command%`.

---

## 4. Hardware & Steam Detection Algorithms

### Steam Path Resolution
```pascal
function DetectSteamLosslessDll: string;
const
  RelativeSubPath = 'steamapps/common/Lossless Scaling/Lossless.dll';
var
  Candidate: string;
begin
  Result := '';
  // Standard Native Steam path
  Candidate := GetUserDir + '.local/share/Steam/' + RelativeSubPath;
  if FileExists(Candidate) then Exit(Candidate);
  
  // Legacy .steam path
  Candidate := GetUserDir + '.steam/steam/' + RelativeSubPath;
  if FileExists(Candidate) then Exit(Candidate);
  
  // Flatpak Steam path
  Candidate := GetUserDir + '.var/app/com.valvesoftware.Steam/.local/share/Steam/' + RelativeSubPath;
  if FileExists(Candidate) then Exit(Candidate);
end;
```

### Real GPU Device Enumeration
Using `TSystemDetector` / `vulkaninfo`:
- Query detected GPUs and populate dropdown items with human-readable descriptions (e.g. `0: AMD Radeon 780M (Integrated)`, `1: NVIDIA GeForce RTX 4070 (Discrete)`).
- Map dropdown index to `LSFGVK_GPU` value.
