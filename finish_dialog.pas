unit finish_dialog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, ExtCtrls, StdCtrls,
  Buttons, LCLIntf, LCLType, Clipbrd, Math;

type

  TFinishPlatform = (fpSteam, fpHeroic);

  { TFinishDialogForm }
  TFinishDialogForm = class(TForm)
  private
    FPlatform:        TFinishPlatform;
    FLaunchCommand:   string;
    FGameTitle:       string;
    FAnimTimer:       TTimer;
    FAnimTick:        Integer;
    FCopiedTick:      Integer;

    // Platform switcher
    FSteamBtn:        TSpeedButton;
    FHeroicBtn:       TSpeedButton;

    // Animation area
    FAnimBox:         TPaintBox;

    // Command area
    FCmdPanel:        TPanel;
    FCmdLabel:        TLabel;    // shows the command text
    FCopyBtn:         TSpeedButton;

    // Instructions
    FStepsLabel:      TLabel;

    // Close
    FCloseBtn:        TSpeedButton;

    // Section divider panels (for custom paint)
    FDivider1:        TPaintBox;
    FDivider2:        TPaintBox;

    procedure BuildUI;
    procedure AnimTimerTick(Sender: TObject);
    procedure AnimBoxPaint(Sender: TObject);
    procedure CopyBtnClick(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure PaintDivider(Sender: TObject);
    procedure UpdateForPlatform;
    procedure ResetCopyBtn;
    function  BuildHeroicCommand: string;
  public
    constructor Create(AOwner: TComponent; const ALaunchCommand: string; const AGameTitle: string = ''); reintroduce;
    destructor Destroy; override;
    procedure PaintAnimSteam(ACanvas: TCanvas; AW, AH: Integer);
    procedure PaintAnimHeroic(ACanvas: TCanvas; AW, AH: Integer);
    procedure SteamBtnClick(Sender: TObject);
    procedure HeroicBtnClick(Sender: TObject);
  end;

procedure ShowFinishDialog(AOwner: TComponent; const ALaunchCommand: string; const AGameTitle: string = '');

implementation

// ---------------------------------------------------------------------------
// Theme colours (match GOverlay dark palette)
// ---------------------------------------------------------------------------
const
  CLR_BG       = $221A16;   // #161822
  CLR_SURFACE  = $2E2620;   // #20262E
  CLR_BORDER   = $4A3E32;   // #323E4A
  CLR_ACCENT   = $F0BE30;   // #30BEF0 — cyan accent
  CLR_ACCENT2  = $5AC824;   // #24C85A — green (Heroic)
  CLR_TEXT     = $D4CDC7;   // #C7CDD4
  CLR_MUTED    = $7A726A;   // #6A727A
  CLR_BTN_BG   = $3D332A;   // #2A333D
  CLR_BTN_HV   = $503F30;   // #303F50

// ---------------------------------------------------------------------------
// ShowFinishDialog helper
// ---------------------------------------------------------------------------

procedure ShowFinishDialog(AOwner: TComponent; const ALaunchCommand: string; const AGameTitle: string = '');
var
  Dlg: TFinishDialogForm;
begin
  Dlg := TFinishDialogForm.Create(AOwner, ALaunchCommand, AGameTitle);
  try
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

// ---------------------------------------------------------------------------
// Constructor / Destructor
// ---------------------------------------------------------------------------

constructor TFinishDialogForm.Create(AOwner: TComponent; const ALaunchCommand: string; const AGameTitle: string = '');
begin
  inherited CreateNew(AOwner);
  FLaunchCommand := ALaunchCommand;
  FGameTitle     := AGameTitle;
  FPlatform      := fpSteam;
  FAnimTick      := 0;
  FCopiedTick    := 0;
  BuildUI;
end;

destructor TFinishDialogForm.Destroy;
begin
  if Assigned(FAnimTimer) then
    FAnimTimer.Enabled := False;
  inherited;
end;

// ---------------------------------------------------------------------------
// BuildUI
// ---------------------------------------------------------------------------

procedure TFinishDialogForm.BuildUI;
const
  DLG_W  = 540;
  DLG_H  = 560;
  PAD    = 18;
  BTN_H  = 34;
  RAD    = 8;
var
  Y: Integer;
  TitleLbl, Subtitle: TLabel;
begin
  // --- Form base style ---
  Caption      := 'Finish Configuration';
  BorderStyle  := bsSingle;
  BorderIcons  := [biSystemMenu];
  Width        := DLG_W;
  Height       := DLG_H;
  Color        := RGBToColor(22, 24, 34);
  Position     := poMainFormCenter;
  KeyPreview   := True;
  OnKeyDown    := nil;

  Y := PAD;

  // --- Title ---
  TitleLbl           := TLabel.Create(Self);
  TitleLbl.Parent    := Self;
  TitleLbl.Caption   := 'Finish Configuration';
  TitleLbl.Font.Name := 'Noto Sans';
  TitleLbl.Font.Size := 14;
  TitleLbl.Font.Style := [fsBold];
  TitleLbl.Font.Color := clWhite;
  TitleLbl.Left := PAD;
  TitleLbl.Top  := Y;
  TitleLbl.AutoSize := True;

  Subtitle           := TLabel.Create(Self);
  Subtitle.Parent    := Self;
  Subtitle.Caption   := 'Apply the generated launch command to your game launcher';
  Subtitle.Font.Name := 'Noto Sans';
  Subtitle.Font.Size := 9;
  Subtitle.Font.Color := RGBToColor(107, 114, 128);
  Subtitle.Left := PAD;
  Subtitle.Top  := Y + 24;
  Subtitle.AutoSize := True;

  Inc(Y, 56);

  // --- Platform switcher ---
  FSteamBtn             := TSpeedButton.Create(Self);
  FSteamBtn.Parent      := Self;
  FSteamBtn.Caption     := '  Steam';
  FSteamBtn.Font.Name   := 'Noto Sans';
  FSteamBtn.Font.Size   := 10;
  FSteamBtn.Font.Style  := [fsBold];
  FSteamBtn.Font.Color  := clWhite;
  FSteamBtn.Left        := PAD;
  FSteamBtn.Top         := Y;
  FSteamBtn.Width       := 110;
  FSteamBtn.Height      := BTN_H;
  FSteamBtn.Flat        := True;
  FSteamBtn.GroupIndex  := 1;
  FSteamBtn.Down        := True;
  FSteamBtn.OnClick     := @SteamBtnClick;

  FHeroicBtn            := TSpeedButton.Create(Self);
  FHeroicBtn.Parent     := Self;
  FHeroicBtn.Caption    := '  Heroic';
  FHeroicBtn.Font.Name  := 'Noto Sans';
  FHeroicBtn.Font.Size  := 10;
  FHeroicBtn.Font.Style := [fsBold];
  FHeroicBtn.Font.Color := RGBToColor(107, 114, 128);
  FHeroicBtn.Left       := PAD + 116;
  FHeroicBtn.Top        := Y;
  FHeroicBtn.Width      := 110;
  FHeroicBtn.Height     := BTN_H;
  FHeroicBtn.Flat       := True;
  FHeroicBtn.GroupIndex := 1;
  FHeroicBtn.Down       := False;
  FHeroicBtn.OnClick    := @HeroicBtnClick;

  Inc(Y, BTN_H + 12);

  // --- Animation box ---
  FAnimBox           := TPaintBox.Create(Self);
  FAnimBox.Parent    := Self;
  FAnimBox.Left      := PAD;
  FAnimBox.Top       := Y;
  FAnimBox.Width     := DLG_W - PAD * 2;
  FAnimBox.Height    := 175;
  FAnimBox.OnPaint   := @AnimBoxPaint;

  Inc(Y, 175 + 14);

  // --- Section divider ---
  FDivider1          := TPaintBox.Create(Self);
  FDivider1.Parent   := Self;
  FDivider1.Left     := PAD;
  FDivider1.Top      := Y;
  FDivider1.Width    := DLG_W - PAD * 2;
  FDivider1.Height   := 1;
  FDivider1.OnPaint  := @PaintDivider;

  Inc(Y, 10);

  // --- Launch command label ---
  FCmdLabel            := TLabel.Create(Self);
  FCmdLabel.Parent     := Self;
  FCmdLabel.Caption    := 'Launch command:';
  FCmdLabel.Font.Name  := 'Noto Sans';
  FCmdLabel.Font.Size  := 9;
  FCmdLabel.Font.Color := RGBToColor(156, 163, 175);
  FCmdLabel.Left       := PAD;
  FCmdLabel.Top        := Y;
  FCmdLabel.AutoSize   := True;

  Inc(Y, 20);

  // --- Command panel ---
  FCmdPanel              := TPanel.Create(Self);
  FCmdPanel.Parent       := Self;
  FCmdPanel.Left         := PAD;
  FCmdPanel.Top          := Y;
  FCmdPanel.Width        := DLG_W - PAD * 2;
  FCmdPanel.Height       := 44;
  FCmdPanel.Color        := RGBToColor(20, 24, 36);
  FCmdPanel.BevelOuter   := bvNone;
  FCmdPanel.BevelInner   := bvNone;

  // Command text inside panel
  with TLabel.Create(Self) do
  begin
    Parent     := FCmdPanel;
    Name       := 'CmdTextLbl';
    Font.Name  := 'DejaVu Sans Mono';
    Font.Size  := 8;
    Font.Color := RGBToColor(48, 190, 240);
    Left       := 10;
    Top        := 0;
    Width      := FCmdPanel.Width - 110;
    Height     := FCmdPanel.Height;
    Caption    := FLaunchCommand;
    Layout     := tlCenter;
    AutoSize   := False;
    WordWrap   := False;
  end;

  // Copy button
  FCopyBtn            := TSpeedButton.Create(Self);
  FCopyBtn.Parent     := FCmdPanel;
  FCopyBtn.Caption    := '  Copy';
  FCopyBtn.Font.Name  := 'Noto Sans';
  FCopyBtn.Font.Size  := 9;
  FCopyBtn.Font.Style := [fsBold];
  FCopyBtn.Font.Color := clWhite;
  FCopyBtn.Left       := FCmdPanel.Width - 90;
  FCopyBtn.Top        := 7;
  FCopyBtn.Width      := 80;
  FCopyBtn.Height     := 30;
  FCopyBtn.Flat       := True;
  FCopyBtn.OnClick    := @CopyBtnClick;

  Inc(Y, 44 + 14);

  // --- Steps label ---
  FStepsLabel            := TLabel.Create(Self);
  FStepsLabel.Parent     := Self;
  FStepsLabel.Font.Name  := 'Noto Sans';
  FStepsLabel.Font.Size  := 9;
  FStepsLabel.Font.Color := RGBToColor(156, 163, 175);
  FStepsLabel.Left       := PAD;
  FStepsLabel.Top        := Y;
  FStepsLabel.Width      := DLG_W - PAD * 2;
  FStepsLabel.AutoSize   := False;
  FStepsLabel.WordWrap   := True;
  FStepsLabel.Height     := 60;

  Inc(Y, 64);

  // --- Close button ---
  FCloseBtn            := TSpeedButton.Create(Self);
  FCloseBtn.Parent     := Self;
  FCloseBtn.Caption    := '  Done';
  FCloseBtn.Font.Name  := 'Noto Sans';
  FCloseBtn.Font.Size  := 10;
  FCloseBtn.Font.Style := [fsBold];
  FCloseBtn.Font.Color := clWhite;
  FCloseBtn.Left       := DLG_W - PAD - 110;
  FCloseBtn.Top        := Y;
  FCloseBtn.Width      := 110;
  FCloseBtn.Height     := BTN_H;
  FCloseBtn.Flat       := True;
  FCloseBtn.OnClick    := @CloseBtnClick;

  // --- Animation timer ---
  FAnimTimer          := TTimer.Create(Self);
  FAnimTimer.Interval := 33;   // ~30 fps
  FAnimTimer.OnTimer  := @AnimTimerTick;
  FAnimTimer.Enabled  := True;

  // Apply initial text
  UpdateForPlatform;
end;

// ---------------------------------------------------------------------------
// Platform helpers
// ---------------------------------------------------------------------------

function TFinishDialogForm.BuildHeroicCommand: string;
begin
  // Heroic uses the same wrapper binary but the command is placed in the
  // "Wrapper command" field, not as a launch option suffix.
  Result := FLaunchCommand;
end;

procedure TFinishDialogForm.UpdateForPlatform;
begin
  case FPlatform of
    fpSteam:
    begin
      FStepsLabel.Caption :=
        '1. Click "Copy" above to copy the launch command.' + LineEnding +
        '2. In Steam, right-click your game › Properties › General.' + LineEnding +
        '3. Paste the command into the "Launch Options" field and close the dialog.';
      FSteamBtn.Font.Color := clWhite;
      FHeroicBtn.Font.Color := RGBToColor(107, 114, 128);
      // Update command display
      TLabel(FCmdPanel.FindChildControl('CmdTextLbl')).Caption := FLaunchCommand;
    end;
    fpHeroic:
    begin
      FStepsLabel.Caption :=
        '1. Click "Copy" above to copy the wrapper command.' + LineEnding +
        '2. In Heroic, open game Settings › Other › "Wrapper command".' + LineEnding +
        '3. Paste the command and save. The game will now launch with GOverlay.';
      FSteamBtn.Font.Color := RGBToColor(107, 114, 128);
      FHeroicBtn.Font.Color := clWhite;
      // Update command display
      TLabel(FCmdPanel.FindChildControl('CmdTextLbl')).Caption := BuildHeroicCommand;
    end;
  end;
  FAnimBox.Invalidate;
  ResetCopyBtn;
end;

// ---------------------------------------------------------------------------
// Button handlers
// ---------------------------------------------------------------------------

procedure TFinishDialogForm.SteamBtnClick(Sender: TObject);
begin
  FPlatform := fpSteam;
  UpdateForPlatform;
end;

procedure TFinishDialogForm.HeroicBtnClick(Sender: TObject);
begin
  FPlatform := fpHeroic;
  UpdateForPlatform;
end;

procedure TFinishDialogForm.CloseBtnClick(Sender: TObject);
begin
  FAnimTimer.Enabled := False;
  ModalResult := mrOK;
end;

procedure TFinishDialogForm.CopyBtnClick(Sender: TObject);
var
  CmdText: string;
begin
  case FPlatform of
    fpSteam:   CmdText := FLaunchCommand;
    fpHeroic:  CmdText := BuildHeroicCommand;
  end;
  Clipboard.AsText := CmdText;
  FCopiedTick := 90;  // show feedback for ~3 s at 30fps
  FCopyBtn.Caption    := '  Copied!';
  FCopyBtn.Font.Color := RGBToColor(48, 220, 120);
end;

procedure TFinishDialogForm.ResetCopyBtn;
begin
  FCopiedTick := 0;
  FCopyBtn.Caption    := '  Copy';
  FCopyBtn.Font.Color := clWhite;
end;

// ---------------------------------------------------------------------------
// Animation tick
// ---------------------------------------------------------------------------

procedure TFinishDialogForm.AnimTimerTick(Sender: TObject);
begin
  Inc(FAnimTick);
  if FAnimTick > 10000 then FAnimTick := 0;

  if FCopiedTick > 0 then
  begin
    Dec(FCopiedTick);
    if FCopiedTick = 0 then
      ResetCopyBtn;
  end;

  FAnimBox.Invalidate;
end;

// ---------------------------------------------------------------------------
// Animation paint
// ---------------------------------------------------------------------------

procedure TFinishDialogForm.AnimBoxPaint(Sender: TObject);
begin
  case FPlatform of
    fpSteam:  PaintAnimSteam(FAnimBox.Canvas, FAnimBox.Width, FAnimBox.Height);
    fpHeroic: PaintAnimHeroic(FAnimBox.Canvas, FAnimBox.Width, FAnimBox.Height);
  end;
end;

// Draw modern Steam Properties dialog walkthrough animation
procedure TFinishDialogForm.PaintAnimSteam(ACanvas: TCanvas; AW, AH: Integer);
var
  Phase, FadeAlpha: Integer;
  WW, WH, WL, WT, WR, WB: Integer;
  SidebarW: Integer;
  GameTitleStr, CmdPreview: string;
  InputR, CursorR: TRect;
  ArrowX, ArrowY, BounceOff: Integer;
  ToggleL, ToggleT, ToggleW, ToggleH: Integer;
begin
  // Outer background
  ACanvas.Brush.Color := RGBToColor(14, 16, 24);
  ACanvas.Pen.Color   := RGBToColor(14, 16, 24);
  ACanvas.FillRect(Rect(0, 0, AW, AH));

  // --- Modern Steam Properties Window Frame ---
  WW := AW - 24;
  WH := AH - 14;
  WL := (AW - WW) div 2;
  WT := (AH - WH) div 2;
  WR := WL + WW;
  WB := WT + WH;

  // Window Shadow
  ACanvas.Brush.Color := RGBToColor(0, 0, 0);
  ACanvas.Pen.Color   := RGBToColor(0, 0, 0);
  ACanvas.FillRect(Rect(WL + 4, WT + 4, WR + 4, WB + 4));

  // Window main background (Right content panel)
  ACanvas.Brush.Color := RGBToColor(23, 29, 37);
  ACanvas.Pen.Color   := RGBToColor(43, 53, 66);
  ACanvas.Rectangle(WL, WT, WR, WB);

  // Top-right window controls (— □ ✕)
  ACanvas.Font.Name  := 'DejaVu Sans';
  ACanvas.Font.Size  := 7;
  ACanvas.Font.Style := [];
  ACanvas.Font.Color := RGBToColor(143, 152, 160);
  ACanvas.Brush.Style := bsClear;
  ACanvas.TextOut(WR - 38, WT + 4, '—  □  ✕');

  // Left Sidebar
  SidebarW := 125;
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := RGBToColor(19, 25, 34);
  ACanvas.Pen.Color   := RGBToColor(35, 43, 54);
  ACanvas.Rectangle(WL, WT, WL + SidebarW, WB);

  // Game Title at Top of Sidebar
  if Trim(FGameTitle) <> '' then
    GameTitleStr := UpperCase(Trim(FGameTitle))
  else
    GameTitleStr := 'GLOBAL OVERLAY';

  if Length(GameTitleStr) > 16 then
    GameTitleStr := Copy(GameTitleStr, 1, 14) + '..';

  ACanvas.Font.Name  := 'DejaVu Sans';
  ACanvas.Font.Size  := 7;
  ACanvas.Font.Style := [fsBold];
  ACanvas.Font.Color := RGBToColor(26, 159, 255); // Steam Cyan
  ACanvas.Brush.Style := bsClear;
  ACanvas.TextOut(WL + 8, WT + 8, GameTitleStr);

  // Active Menu Item ("General")
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := RGBToColor(43, 57, 71);
  ACanvas.Pen.Color   := RGBToColor(55, 72, 90);
  ACanvas.RoundRect(WL + 6, WT + 25, WL + SidebarW - 6, WT + 43, 4, 4);

  ACanvas.Font.Color := clWhite;
  ACanvas.Font.Size  := 7;
  ACanvas.Font.Style := [fsBold];
  ACanvas.Brush.Style := bsClear;
  ACanvas.TextOut(WL + 12, WT + 28, 'General');

  // Inactive Menu Items
  ACanvas.Font.Style := [];
  ACanvas.Font.Size  := 7;
  ACanvas.Font.Color := RGBToColor(143, 152, 160);
  ACanvas.TextOut(WL + 12, WT + 48, 'Compatibility');
  ACanvas.TextOut(WL + 12, WT + 66, 'Updates');
  ACanvas.TextOut(WL + 12, WT + 84, 'Installed Files');
  ACanvas.TextOut(WL + 12, WT + 102, 'Controller');
  ACanvas.TextOut(WL + 12, WT + 120, 'Privacy');

  // Right Content Area: "General" Title
  ACanvas.Font.Size  := 8;
  ACanvas.Font.Style := [fsBold];
  ACanvas.Font.Color := clWhite;
  ACanvas.TextOut(WL + SidebarW + 12, WT + 8, 'General');

  // Steam Overlay row
  ACanvas.Font.Size  := 7;
  ACanvas.Font.Style := [];
  ACanvas.Font.Color := RGBToColor(215, 222, 228);
  ACanvas.TextOut(WL + SidebarW + 12, WT + 28, 'Enable the Steam Overlay while in-game');

  // Overlay Toggle Switch (Blue active pill)
  ToggleL := WR - 36;
  ToggleT := WT + 28;
  ToggleW := 24;
  ToggleH := 13;
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := RGBToColor(26, 159, 255);
  ACanvas.Pen.Color   := RGBToColor(26, 159, 255);
  ACanvas.RoundRect(ToggleL, ToggleT, ToggleL + ToggleW, ToggleT + ToggleH, 10, 10);

  // Toggle knob (white circle)
  ACanvas.Brush.Color := clWhite;
  ACanvas.Pen.Color   := clWhite;
  ACanvas.Ellipse(ToggleL + 12, ToggleT + 1, ToggleL + 23, ToggleT + 12);

  // Launch Options section
  ACanvas.Font.Size  := 7;
  ACanvas.Font.Style := [fsBold];
  ACanvas.Font.Color := RGBToColor(225, 231, 236);
  ACanvas.Brush.Style := bsClear;
  ACanvas.TextOut(WL + SidebarW + 12, WT + 52, 'Launch Options');

  ACanvas.Font.Size  := 6;
  ACanvas.Font.Style := [];
  ACanvas.Font.Color := RGBToColor(143, 152, 160);
  ACanvas.TextOut(WL + SidebarW + 12, WT + 68, 'Advanced users may choose to enter modifications to their launch options.');

  // Input Box
  InputR := Rect(WL + SidebarW + 12, WT + 84, WR - 14, WT + 110);
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := RGBToColor(14, 20, 27);
  ACanvas.Pen.Color   := RGBToColor(43, 53, 66);
  ACanvas.RoundRect(InputR.Left, InputR.Top, InputR.Right, InputR.Bottom, 4, 4);

  // Pulsing highlight border
  Phase := (FAnimTick mod 90);
  if Phase < 45 then
    FadeAlpha := Phase * 5
  else
    FadeAlpha := (90 - Phase) * 5;
  FadeAlpha := Max(40, Min(220, FadeAlpha));

  ACanvas.Brush.Style := bsClear;
  ACanvas.Pen.Color := RGBToColor(
    26 + (FadeAlpha * (255 - 26)) div 255,
    159 + (FadeAlpha * (255 - 159)) div 510,
    255);
  ACanvas.Pen.Width := 2;
  ACanvas.RoundRect(InputR.Left, InputR.Top, InputR.Right, InputR.Bottom, 4, 4);
  ACanvas.Pen.Width := 1;

  // Truncated command preview inside input box
  CmdPreview := FLaunchCommand;
  if CmdPreview = '' then
    CmdPreview := '"/home/user/.local/share/goverlay/bgmod" %command%';
  if Length(CmdPreview) > 40 then
    CmdPreview := Copy(CmdPreview, 1, 37) + '...';

  ACanvas.Font.Name  := 'DejaVu Sans Mono';
  ACanvas.Font.Size  := 6;
  ACanvas.Font.Style := [];
  ACanvas.Font.Color := RGBToColor(78, 195, 252);
  ACanvas.Brush.Style := bsClear;
  ACanvas.TextOut(InputR.Left + 8, InputR.Top + 7, CmdPreview);

  // Blinking cursor in input box
  if (FAnimTick mod 30) < 18 then
  begin
    CursorR.Left   := InputR.Left + 8 + ACanvas.TextWidth(CmdPreview) + 2;
    CursorR.Top    := InputR.Top + 6;
    CursorR.Right  := CursorR.Left + 2;
    CursorR.Bottom := InputR.Bottom - 6;
    if CursorR.Right < InputR.Right - 4 then
    begin
      ACanvas.Brush.Style := bsSolid;
      ACanvas.Brush.Color := RGBToColor(26, 159, 255);
      ACanvas.Pen.Color   := RGBToColor(26, 159, 255);
      ACanvas.FillRect(CursorR);
    end;
  end;

  // Bouncing guide arrow
  BounceOff := Round(3 * Sin(FAnimTick * 0.12));
  ArrowX := InputR.Left - 10 + BounceOff;
  ArrowY := (InputR.Top + InputR.Bottom) div 2 - 5;
  ACanvas.Font.Name  := 'DejaVu Sans';
  ACanvas.Font.Size  := 10;
  ACanvas.Font.Color := RGBToColor(26, 159, 255);
  ACanvas.Font.Style := [fsBold];
  ACanvas.Brush.Style := bsClear;
  ACanvas.TextOut(ArrowX, ArrowY, '>');
end;

// Draw a simplified Heroic "Settings" dialog walkthrough animation
procedure TFinishDialogForm.PaintAnimHeroic(ACanvas: TCanvas; AW, AH: Integer);
var
  Phase, FadeAlpha: Integer;
  WL, WT, WR, WB, WW, WH: Integer;
  InputR, TitleR: TRect;
  BounceOff, ArrowX, ArrowY: Integer;
begin
  // Background
  ACanvas.Brush.Color := RGBToColor(14, 16, 24);
  ACanvas.Pen.Color   := RGBToColor(14, 16, 24);
  ACanvas.FillRect(Rect(0, 0, AW, AH));

  // --- Fake Heroic Settings Panel ---
  WW := Round(AW * 0.82);
  WH := Round(AH * 0.84);
  WL := (AW - WW) div 2;
  WT := (AH - WH) div 2;
  WR := WL + WW;
  WB := WT + WH;

  // Shadow
  ACanvas.Brush.Color := RGBToColor(0, 0, 0);
  ACanvas.Pen.Color   := RGBToColor(0, 0, 0);
  ACanvas.FillRect(Rect(WL + 4, WT + 4, WR + 4, WB + 4));

  // Window bg
  ACanvas.Brush.Color := RGBToColor(26, 28, 38);
  ACanvas.Pen.Color   := RGBToColor(50, 55, 80);
  ACanvas.Rectangle(WL, WT, WR, WB);

  // Header bar
  TitleR := Rect(WL + 1, WT + 1, WR - 1, WT + 36);
  ACanvas.Brush.Color := RGBToColor(36, 38, 54);
  ACanvas.Pen.Color   := RGBToColor(36, 38, 54);
  ACanvas.FillRect(TitleR);

  ACanvas.Font.Name  := 'DejaVu Sans';
  ACanvas.Font.Size  := 9;
  ACanvas.Font.Style := [fsBold];
  ACanvas.Font.Color := RGBToColor(200, 200, 220);
  ACanvas.Brush.Style := bsClear;
  ACanvas.TextOut(WL + 12, WT + 10, 'Game Settings — Other');
  ACanvas.Brush.Style := bsSolid;

  // Sidebar-style section chips
  ACanvas.Font.Size  := 8;
  ACanvas.Font.Style := [];
  ACanvas.Font.Color := RGBToColor(100, 110, 150);
  ACanvas.TextOut(WL + 10, WT + 48, 'General');
  ACanvas.TextOut(WL + 10, WT + 68, 'Display');

  // "Other" highlighted
  ACanvas.Brush.Color := RGBToColor(36, 44, 70);
  ACanvas.Pen.Color   := RGBToColor(70, 100, 200);
  ACanvas.Rectangle(WL + 6, WT + 84, WL + 64, WT + 100);
  ACanvas.Font.Color  := clWhite;
  ACanvas.Font.Style  := [fsBold];
  ACanvas.Brush.Style := bsClear;
  ACanvas.TextOut(WL + 10, WT + 88, 'Other');
  ACanvas.Brush.Style := bsSolid;

  // "Wrapper command" label
  ACanvas.Font.Name  := 'DejaVu Sans';
  ACanvas.Font.Size  := 8;
  ACanvas.Font.Style := [fsBold];
  ACanvas.Font.Color := RGBToColor(180, 185, 210);
  ACanvas.Brush.Style := bsClear;
  ACanvas.TextOut(WL + 80, WB - 78, 'WRAPPER COMMAND');
  ACanvas.Brush.Style := bsSolid;

  // Input
  InputR := Rect(WL + 80, WB - 60, WR - 16, WB - 30);
  ACanvas.Brush.Color := RGBToColor(18, 20, 32);
  ACanvas.Pen.Color   := RGBToColor(60, 65, 100);
  ACanvas.Rectangle(InputR);

  // Pulsing highlight
  Phase := (FAnimTick mod 90);
  if Phase < 45 then FadeAlpha := Phase * 5
  else FadeAlpha := (90 - Phase) * 5;
  FadeAlpha := Max(40, Min(220, FadeAlpha));

  ACanvas.Pen.Color := RGBToColor(
    36 + FadeAlpha div 6,
    60 + FadeAlpha div 3,
    190 + FadeAlpha div 10);
  ACanvas.Pen.Width := 2;
  ACanvas.Rectangle(InputR);
  ACanvas.Pen.Width := 1;

  ACanvas.Font.Name  := 'DejaVu Sans Mono';
  ACanvas.Font.Size  := 7;
  ACanvas.Font.Style := [];
  ACanvas.Font.Color := RGBToColor(36, 200, 100);
  ACanvas.Brush.Style := bsClear;
  ACanvas.TextOut(InputR.Left + 6, InputR.Top + 8, '/home/user/.local/share/goverlay/bgmod');
  ACanvas.Brush.Style := bsSolid;

  // Cursor blink
  if (FAnimTick mod 30) < 18 then
  begin
    ACanvas.Brush.Color := RGBToColor(36, 200, 100);
    ACanvas.Pen.Color   := RGBToColor(36, 200, 100);
    ACanvas.FillRect(Rect(InputR.Left + 6, InputR.Top + 6,
                          InputR.Left + 8, InputR.Bottom - 8));
  end;

  // Bouncing arrow
  BounceOff := Round(3 * Sin(FAnimTick * 0.12));
  ArrowX := WL + 60 + BounceOff;
  ArrowY := (InputR.Top + InputR.Bottom) div 2 - 6;
  ACanvas.Font.Name  := 'DejaVu Sans';
  ACanvas.Font.Size  := 12;
  ACanvas.Font.Color := RGBToColor(36, 200, 100);
  ACanvas.Font.Style := [fsBold];
  ACanvas.Brush.Style := bsClear;
  ACanvas.TextOut(ArrowX, ArrowY, '>');
  ACanvas.Brush.Style := bsSolid;
end;

// ---------------------------------------------------------------------------
// Divider painter
// ---------------------------------------------------------------------------

procedure TFinishDialogForm.PaintDivider(Sender: TObject);
var
  PB: TPaintBox;
begin
  PB := Sender as TPaintBox;
  PB.Canvas.Pen.Color := RGBToColor(46, 52, 74);
  PB.Canvas.MoveTo(0, 0);
  PB.Canvas.LineTo(PB.Width, 0);
end;

end.
