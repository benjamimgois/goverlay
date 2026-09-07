unit lsfg_migration_dialog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, ExtCtrls, StdCtrls,
  Buttons, LCLIntf, Process;

type
  { TLSFGVkMigrationDialog }
  TLSFGVkMigrationDialog = class(TForm)
  private
    FTabHelper: TObject;

    // Custom Chrome / Header
    FHeaderPanel: TPanel;
    FTitleLabel: TLabel;
    FSubtitleLabel: TLabel;

    // Content container
    FScrollBox: TScrollBox;

    // Step 1: Steam Beta
    FStep1Panel: TPanel;
    FStep1Title: TLabel;
    FStep1Dot: TShape;
    FStep1Status: TLabel;
    FStep1Desc: TLabel;
    FStep1OpenBtn: TBitBtn;

    // Step 2: Legacy Clean
    FStep2Panel: TPanel;
    FStep2Title: TLabel;
    FStep2Dot: TShape;
    FStep2Status: TLabel;
    FStep2Desc: TLabel;
    FStep2CleanBtn: TBitBtn;
    FStep2ResultLbl: TLabel;

    // Step 3: Package Manager
    FStep3Panel: TPanel;
    FStep3Title: TLabel;
    FStep3Desc: TLabel;

    // Step 4: Config Modernization
    FStep4Panel: TPanel;
    FStep4Title: TLabel;
    FStep4Dot: TShape;
    FStep4Status: TLabel;
    FStep4Desc: TLabel;
    FStep4UpdateBtn: TBitBtn;
    FStep4ResultLbl: TLabel;

    // Bottom bar
    FBottomPanel: TPanel;
    FRefreshBtn: TBitBtn;
    FCloseBtn: TBitBtn;

    procedure BuildUI;
    procedure CardPaint(Sender: TObject);
    procedure OpenFolderClick(Sender: TObject);
    procedure CleanLegacyClick(Sender: TObject);
    procedure UpdateConfigClick(Sender: TObject);
    procedure RefreshClick(Sender: TObject);
    procedure CloseClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    constructor Create(AOwner: TComponent; ATabHelper: TObject = nil); reintroduce;
    destructor Destroy; override;
    procedure RefreshAllChecks;
    
    // Properties for testing
    property Step1Dot: TShape read FStep1Dot;
    property Step1Status: TLabel read FStep1Status;
    property Step1OpenBtn: TBitBtn read FStep1OpenBtn;
    property Step2Dot: TShape read FStep2Dot;
    property Step2Status: TLabel read FStep2Status;
    property Step2CleanBtn: TBitBtn read FStep2CleanBtn;
    property Step2ResultLbl: TLabel read FStep2ResultLbl;
    property Step4Dot: TShape read FStep4Dot;
    property Step4Status: TLabel read FStep4Status;
    property Step4UpdateBtn: TBitBtn read FStep4UpdateBtn;
    property Step4ResultLbl: TLabel read FStep4ResultLbl;
    property RefreshBtn: TBitBtn read FRefreshBtn;
    property CloseBtn: TBitBtn read FCloseBtn;
  end;

procedure ShowLsfgMigrationDialog(AOwner: TComponent; ATabHelper: TObject = nil);

implementation

uses
  lossless_scaling_tab;

const
  CLR_BG       = $00281A16; // #161A28 (Dark theme background)
  CLR_SURFACE  = $002E2620; // #20262E (SubCard background)
  CLR_BORDER   = $004A3E32; // #323E4A (SubCard border)
  CLR_OK       = $0044BB44; // Green
  CLR_WARN     = $000B9EF5; // Amber / Orange
  CLR_FAIL     = $005F5AFF; // Red
  CLR_TEXT     = $00D4CDC7; // Text light
  CLR_MUTED    = $00998877; // Text muted

procedure ShowLsfgMigrationDialog(AOwner: TComponent; ATabHelper: TObject);
var
  Dlg: TLSFGVkMigrationDialog;
begin
  Dlg := TLSFGVkMigrationDialog.Create(AOwner, ATabHelper);
  try
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

constructor TLSFGVkMigrationDialog.Create(AOwner: TComponent; ATabHelper: TObject);
begin
  inherited CreateNew(AOwner);
  FTabHelper := ATabHelper;
  BuildUI;
  RefreshAllChecks;
end;

destructor TLSFGVkMigrationDialog.Destroy;
begin
  if Assigned(FTabHelper) and (FTabHelper is TLosslessScalingTabHelper) then
  begin
    TLosslessScalingTabHelper(FTabHelper).UpdateMigrationAlertState;
    TLosslessScalingTabHelper(FTabHelper).UpdateStatusCard;
  end;
  inherited Destroy;
end;

procedure TLSFGVkMigrationDialog.CardPaint(Sender: TObject);
var
  P: TPanel;
begin
  if not (Sender is TPanel) then Exit;
  P := TPanel(Sender);
  P.Canvas.Brush.Color := P.Color;
  P.Canvas.Pen.Color := CLR_BORDER;
  P.Canvas.Pen.Width := 1;
  P.Canvas.RoundRect(0, 0, P.Width - 1, P.Height - 1, 8, 8);
end;

procedure TLSFGVkMigrationDialog.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 27 then // Escape
    Close;
end;

procedure TLSFGVkMigrationDialog.BuildUI;
const
  DLG_W = 680;
  DLG_H = 620;
  PAD   = 16;
  CARD_W = DLG_W - 2 * PAD - 18; // account for scrollbar
var
  CurY: Integer;
begin
  Caption := 'lsfg-vk 2.0 Migration & Health Assistant';
  Width := DLG_W;
  Height := DLG_H;
  Position := poMainFormCenter;
  Color := CLR_BG;
  KeyPreview := True;
  OnKeyDown := @FormKeyDown;

  // --- Header ---
  FHeaderPanel := TPanel.Create(Self);
  FHeaderPanel.Parent := Self;
  FHeaderPanel.SetBounds(0, 0, DLG_W, 64);
  FHeaderPanel.BevelOuter := bvNone;
  FHeaderPanel.Color := CLR_BG;

  FTitleLabel := TLabel.Create(Self);
  FTitleLabel.Parent := FHeaderPanel;
  FTitleLabel.Caption := 'lsfg-vk 2.0 Migration & Health Assistant';
  FTitleLabel.Font.Size := 13;
  FTitleLabel.Font.Style := [fsBold];
  FTitleLabel.Font.Color := clWhite;
  FTitleLabel.SetBounds(PAD, 12, DLG_W - 2 * PAD, 22);

  FSubtitleLabel := TLabel.Create(Self);
  FSubtitleLabel.Parent := FHeaderPanel;
  FSubtitleLabel.Caption := 'Follow the guided steps below to ensure Lossless Scaling is configured for the 2.0 Vulkan pipeline.';
  FSubtitleLabel.Font.Size := 9;
  FSubtitleLabel.Font.Color := CLR_TEXT;
  FSubtitleLabel.SetBounds(PAD, 36, DLG_W - 2 * PAD, 18);

  // --- Bottom Panel ---
  FBottomPanel := TPanel.Create(Self);
  FBottomPanel.Parent := Self;
  FBottomPanel.SetBounds(0, DLG_H - 52, DLG_W, 52);
  FBottomPanel.BevelOuter := bvNone;
  FBottomPanel.Color := CLR_BG;

  FRefreshBtn := TBitBtn.Create(Self);
  FRefreshBtn.Parent := FBottomPanel;
  FRefreshBtn.Caption := 'Refresh Checks';
  FRefreshBtn.Cursor := crHandPoint;
  FRefreshBtn.SetBounds(PAD, 10, 140, 32);
  FRefreshBtn.OnClick := @RefreshClick;

  FCloseBtn := TBitBtn.Create(Self);
  FCloseBtn.Parent := FBottomPanel;
  FCloseBtn.Caption := 'Close';
  FCloseBtn.Cursor := crHandPoint;
  FCloseBtn.SetBounds(DLG_W - PAD - 100, 10, 100, 32);
  FCloseBtn.OnClick := @CloseClick;

  // --- ScrollBox for steps ---
  FScrollBox := TScrollBox.Create(Self);
  FScrollBox.Parent := Self;
  FScrollBox.SetBounds(0, 64, DLG_W, DLG_H - 64 - 52);
  FScrollBox.BorderStyle := bsNone;
  FScrollBox.Color := CLR_BG;
  FScrollBox.AutoScroll := True;

  CurY := 6;

  // ── Step 1: Steam Beta Branch ──────────────────────────────────────────
  FStep1Panel := TPanel.Create(FScrollBox);
  FStep1Panel.Parent := FScrollBox;
  FStep1Panel.SetBounds(PAD, CurY, CARD_W, 134);
  FStep1Panel.BevelOuter := bvNone;
  FStep1Panel.Color := CLR_SURFACE;
  FStep1Panel.OnPaint := @CardPaint;

  FStep1Dot := TShape.Create(FStep1Panel);
  FStep1Dot.Parent := FStep1Panel;
  FStep1Dot.Shape := stEllipse;
  FStep1Dot.Brush.Color := CLR_WARN;
  FStep1Dot.Pen.Style := psClear;
  FStep1Dot.SetBounds(14, 14, 12, 12);

  FStep1Title := TLabel.Create(FStep1Panel);
  FStep1Title.Parent := FStep1Panel;
  FStep1Title.Caption := 'Step 1: Switch Lossless Scaling to the "lsfg-vk" Beta Branch';
  FStep1Title.Font.Size := 10;
  FStep1Title.Font.Style := [fsBold];
  FStep1Title.Font.Color := clWhite;
  FStep1Title.SetBounds(34, 11, CARD_W - 50, 20);

  FStep1Status := TLabel.Create(FStep1Panel);
  FStep1Status.Parent := FStep1Panel;
  FStep1Status.Caption := 'Checking Steam installation...';
  FStep1Status.Font.Size := 9;
  FStep1Status.Font.Style := [fsBold];
  FStep1Status.Font.Color := CLR_WARN;
  FStep1Status.SetBounds(34, 34, CARD_W - 50, 18);

  FStep1Desc := TLabel.Create(FStep1Panel);
  FStep1Desc.Parent := FStep1Panel;
  FStep1Desc.Caption := 'Upstream lsfg-vk 2.0 requires the native Vulkan bindless shaders in lsfg-vk.dll.' + LineEnding +
                        'In Steam: Library -> Right-click "Lossless Scaling" -> Properties... -> Betas -> select "lsfg-vk - beta".';
  FStep1Desc.Font.Size := 8;
  FStep1Desc.Font.Color := CLR_TEXT;
  FStep1Desc.WordWrap := True;
  FStep1Desc.SetBounds(34, 54, CARD_W - 200, 40);

  FStep1OpenBtn := TBitBtn.Create(FStep1Panel);
  FStep1OpenBtn.Parent := FStep1Panel;
  FStep1OpenBtn.Caption := 'Open Steam Folder';
  FStep1OpenBtn.Cursor := crHandPoint;
  FStep1OpenBtn.SetBounds(CARD_W - 160, 90, 146, 30);
  FStep1OpenBtn.OnClick := @OpenFolderClick;

  CurY := CurY + 134 + 10;

  // ── Step 2: Legacy 1.x Layers Cleanup ──────────────────────────────────
  FStep2Panel := TPanel.Create(FScrollBox);
  FStep2Panel.Parent := FScrollBox;
  FStep2Panel.SetBounds(PAD, CurY, CARD_W, 144);
  FStep2Panel.BevelOuter := bvNone;
  FStep2Panel.Color := CLR_SURFACE;
  FStep2Panel.OnPaint := @CardPaint;

  FStep2Dot := TShape.Create(FStep2Panel);
  FStep2Dot.Parent := FStep2Panel;
  FStep2Dot.Shape := stEllipse;
  FStep2Dot.Brush.Color := CLR_WARN;
  FStep2Dot.Pen.Style := psClear;
  FStep2Dot.SetBounds(14, 14, 12, 12);

  FStep2Title := TLabel.Create(FStep2Panel);
  FStep2Title.Parent := FStep2Panel;
  FStep2Title.Caption := 'Step 2: Clean Conflicting 1.x System Layers (Root Required)';
  FStep2Title.Font.Size := 10;
  FStep2Title.Font.Style := [fsBold];
  FStep2Title.Font.Color := clWhite;
  FStep2Title.SetBounds(34, 11, CARD_W - 50, 20);

  FStep2Status := TLabel.Create(FStep2Panel);
  FStep2Status.Parent := FStep2Panel;
  FStep2Status.Caption := 'Checking for legacy 1.x files...';
  FStep2Status.Font.Size := 9;
  FStep2Status.Font.Style := [fsBold];
  FStep2Status.Font.Color := CLR_WARN;
  FStep2Status.SetBounds(34, 34, CARD_W - 50, 18);

  FStep2Desc := TLabel.Create(FStep2Panel);
  FStep2Desc.Parent := FStep2Panel;
  FStep2Desc.Caption := 'Legacy 1.x implicit layers hook games automatically and cause parse or crash errors with 2.0.' + LineEnding +
                        'Click below to remove legacy layer files (/etc/vulkan, /usr/lib64) via pkexec.';
  FStep2Desc.Font.Size := 8;
  FStep2Desc.Font.Color := CLR_TEXT;
  FStep2Desc.WordWrap := True;
  FStep2Desc.SetBounds(34, 54, CARD_W - 200, 36);

  FStep2CleanBtn := TBitBtn.Create(FStep2Panel);
  FStep2CleanBtn.Parent := FStep2Panel;
  FStep2CleanBtn.Caption := 'Clean Legacy Files (Root)';
  FStep2CleanBtn.Cursor := crHandPoint;
  FStep2CleanBtn.SetBounds(CARD_W - 190, 96, 176, 30);
  FStep2CleanBtn.OnClick := @CleanLegacyClick;

  FStep2ResultLbl := TLabel.Create(FStep2Panel);
  FStep2ResultLbl.Parent := FStep2Panel;
  FStep2ResultLbl.Caption := '';
  FStep2ResultLbl.Font.Size := 8;
  FStep2ResultLbl.Font.Style := [fsBold];
  FStep2ResultLbl.SetBounds(34, 102, CARD_W - 240, 20);

  CurY := CurY + 144 + 10;

  // ── Step 3: Distro Package Recommendation ─────────────────────────────
  FStep3Panel := TPanel.Create(FScrollBox);
  FStep3Panel.Parent := FScrollBox;
  FStep3Panel.SetBounds(PAD, CurY, CARD_W, 90);
  FStep3Panel.BevelOuter := bvNone;
  FStep3Panel.Color := CLR_SURFACE;
  FStep3Panel.OnPaint := @CardPaint;

  FStep3Title := TLabel.Create(FStep3Panel);
  FStep3Title.Parent := FStep3Panel;
  FStep3Title.Caption := 'Step 3: Remove Deprecated Distro Packages';
  FStep3Title.Font.Size := 10;
  FStep3Title.Font.Style := [fsBold];
  FStep3Title.Font.Color := clWhite;
  FStep3Title.SetBounds(14, 11, CARD_W - 30, 20);

  FStep3Desc := TLabel.Create(FStep3Panel);
  FStep3Desc.Parent := FStep3Panel;
  FStep3Desc.Caption := 'If you installed lsfg-vk from AUR or a package manager (e.g. lsfg-vk-git), we recommend uninstalling it:' + LineEnding +
                        '  Arch / Manjaro: sudo pacman -R lsfg-vk-git   or   yay -R lsfg-vk-git' + LineEnding +
                        'GOverlay manages the 2.0 layer automatically in ~/.local/share/vulkan.';
  FStep3Desc.Font.Size := 8;
  FStep3Desc.Font.Color := CLR_TEXT;
  FStep3Desc.WordWrap := True;
  FStep3Desc.SetBounds(14, 34, CARD_W - 30, 50);

  CurY := CurY + 90 + 10;

  // ── Step 4: Configuration Modernization ─────────────────────────────────
  FStep4Panel := TPanel.Create(FScrollBox);
  FStep4Panel.Parent := FScrollBox;
  FStep4Panel.SetBounds(PAD, CurY, CARD_W, 134);
  FStep4Panel.BevelOuter := bvNone;
  FStep4Panel.Color := CLR_SURFACE;
  FStep4Panel.OnPaint := @CardPaint;

  FStep4Dot := TShape.Create(FStep4Panel);
  FStep4Dot.Parent := FStep4Panel;
  FStep4Dot.Shape := stEllipse;
  FStep4Dot.Brush.Color := CLR_WARN;
  FStep4Dot.Pen.Style := psClear;
  FStep4Dot.SetBounds(14, 14, 12, 12);

  FStep4Title := TLabel.Create(FStep4Panel);
  FStep4Title.Parent := FStep4Panel;
  FStep4Title.Caption := 'Step 4: Modernize User Configuration (~/.config/lsfg-vk/conf.toml)';
  FStep4Title.Font.Size := 10;
  FStep4Title.Font.Style := [fsBold];
  FStep4Title.Font.Color := clWhite;
  FStep4Title.SetBounds(34, 11, CARD_W - 50, 20);

  FStep4Status := TLabel.Create(FStep4Panel);
  FStep4Status.Parent := FStep4Panel;
  FStep4Status.Caption := 'Checking user configuration schema...';
  FStep4Status.Font.Size := 9;
  FStep4Status.Font.Style := [fsBold];
  FStep4Status.Font.Color := CLR_WARN;
  FStep4Status.SetBounds(34, 34, CARD_W - 50, 18);

  FStep4Desc := TLabel.Create(FStep4Panel);
  FStep4Desc.Parent := FStep4Panel;
  FStep4Desc.Caption := 'lsfg-vk 2.0 expects version = 2 and [[profile]] syntax. Legacy 1.x configurations will trigger schema parse errors.' + LineEnding +
                        'Click below to back up the legacy file to conf.toml.v1.bak and create a valid 2.0 template.';
  FStep4Desc.Font.Size := 8;
  FStep4Desc.Font.Color := CLR_TEXT;
  FStep4Desc.WordWrap := True;
  FStep4Desc.SetBounds(34, 54, CARD_W - 200, 36);

  FStep4UpdateBtn := TBitBtn.Create(FStep4Panel);
  FStep4UpdateBtn.Parent := FStep4Panel;
  FStep4UpdateBtn.Caption := 'Update Configuration';
  FStep4UpdateBtn.Cursor := crHandPoint;
  FStep4UpdateBtn.SetBounds(CARD_W - 170, 90, 156, 30);
  FStep4UpdateBtn.OnClick := @UpdateConfigClick;

  FStep4ResultLbl := TLabel.Create(FStep4Panel);
  FStep4ResultLbl.Parent := FStep4Panel;
  FStep4ResultLbl.Caption := '';
  FStep4ResultLbl.Font.Size := 8;
  FStep4ResultLbl.Font.Style := [fsBold];
  FStep4ResultLbl.SetBounds(34, 96, CARD_W - 220, 20);
end;

procedure TLSFGVkMigrationDialog.OpenFolderClick(Sender: TObject);
var
  Helper: TLosslessScalingTabHelper;
  Path, Dir: string;
begin
  Dir := '';
  if Assigned(FTabHelper) and (FTabHelper is TLosslessScalingTabHelper) then
  begin
    Helper := TLosslessScalingTabHelper(FTabHelper);
    if Assigned(Helper.DllPathEdit) then
      Path := Trim(Helper.DllPathEdit.Text)
    else
      Path := '';
    if Path = '' then
      Path := Helper.DetectSteamLosslessDll(False);
    if Path <> '' then
      Dir := ExtractFilePath(Path);
  end;

  if (Dir = '') or not DirectoryExists(Dir) then
    Dir := IncludeTrailingPathDelimiter(GetUserDir) + '.local/share/Steam/steamapps/common/Lossless Scaling';

  if DirectoryExists(Dir) then
    OpenDocument(Dir)
  else
    OpenDocument(GetUserDir);
end;

procedure TLSFGVkMigrationDialog.CleanLegacyClick(Sender: TObject);
var
  Proc: TProcess;
begin
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := 'pkexec';
    Proc.Parameters.Add('rm');
    Proc.Parameters.Add('-f');
    Proc.Parameters.Add('/etc/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json');
    Proc.Parameters.Add('/usr/lib/liblsfg-vk.so');
    Proc.Parameters.Add('/usr/lib64/liblsfg-vk.so');
    Proc.Parameters.Add('/usr/bin/lsfg-vk-ui');
    Proc.Parameters.Add('/usr/share/applications/lsfg-vk-ui.desktop');
    Proc.Parameters.Add(IncludeTrailingPathDelimiter(GetUserDir) + '.local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json');
    Proc.Options := [poWaitOnExit];
    try
      Proc.Execute;
      if Proc.ExitCode = 0 then
      begin
        FStep2ResultLbl.Caption := 'Legacy files removed successfully!';
        FStep2ResultLbl.Font.Color := CLR_OK;
      end
      else
      begin
        FStep2ResultLbl.Caption := 'Cleanup canceled or failed (code ' + IntToStr(Proc.ExitCode) + ')';
        FStep2ResultLbl.Font.Color := CLR_FAIL;
      end;
    except
      on E: Exception do
      begin
        FStep2ResultLbl.Caption := 'Execution error: ' + E.Message;
        FStep2ResultLbl.Font.Color := CLR_FAIL;
      end;
    end;
  finally
    Proc.Free;
  end;
  RefreshAllChecks;
end;

procedure TLSFGVkMigrationDialog.UpdateConfigClick(Sender: TObject);
var
  Helper: TLosslessScalingTabHelper;
  BakPath: string;
begin
  if Assigned(FTabHelper) and (FTabHelper is TLosslessScalingTabHelper) then
  begin
    Helper := TLosslessScalingTabHelper(FTabHelper);
    if Helper.ModernizeUserConfig(BakPath) then
    begin
      if BakPath <> '' then
        FStep4ResultLbl.Caption := 'Backup created (' + ExtractFileName(BakPath) + ') and v2 written!'
      else
        FStep4ResultLbl.Caption := 'Default v2 config generated successfully!';
      FStep4ResultLbl.Font.Color := CLR_OK;
    end
    else
    begin
      FStep4ResultLbl.Caption := 'Failed to update configuration';
      FStep4ResultLbl.Font.Color := CLR_FAIL;
    end;
  end;
  RefreshAllChecks;
end;

procedure TLSFGVkMigrationDialog.RefreshClick(Sender: TObject);
begin
  RefreshAllChecks;
end;

procedure TLSFGVkMigrationDialog.CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TLSFGVkMigrationDialog.RefreshAllChecks;
var
  Helper: TLosslessScalingTabHelper;
  BetaDllPath, CfgPath: string;
  HasBetaIssue, HasConfigIssue: Boolean;
  LegacyList: TStringList;
begin
  if not Assigned(FTabHelper) or not (FTabHelper is TLosslessScalingTabHelper) then Exit;
  Helper := TLosslessScalingTabHelper(FTabHelper);

  // 1. Steam Beta DLL
  HasBetaIssue := Helper.CheckSteamBetaDllHealth(BetaDllPath);
  if (BetaDllPath <> '') and FileExists(BetaDllPath) then
  begin
    FStep1Dot.Brush.Color := CLR_OK;
    FStep1Status.Caption := '● lsfg-vk.dll is installed and detected.';
    FStep1Status.Font.Color := CLR_OK;
  end
  else if HasBetaIssue then
  begin
    FStep1Dot.Brush.Color := CLR_FAIL;
    FStep1Status.Caption := '● lsfg-vk.dll missing! Steam beta branch required.';
    FStep1Status.Font.Color := CLR_FAIL;
  end
  else
  begin
    FStep1Dot.Brush.Color := CLR_WARN;
    FStep1Status.Caption := '● Lossless Scaling folder not found or lsfg-vk.dll missing.';
    FStep1Status.Font.Color := CLR_WARN;
  end;

  // 2. Legacy System Files
  LegacyList := TStringList.Create;
  try
    if Helper.CheckLegacySystemLayersHealth(LegacyList) then
    begin
      FStep2Dot.Brush.Color := CLR_FAIL;
      FStep2Status.Caption := '● ' + IntToStr(LegacyList.Count) + ' legacy 1.x layer file(s) found in system!';
      FStep2Status.Font.Color := CLR_FAIL;
    end
    else
    begin
      FStep2Dot.Brush.Color := CLR_OK;
      FStep2Status.Caption := '● No legacy 1.x layers detected in system.';
      FStep2Status.Font.Color := CLR_OK;
    end;
  finally
    LegacyList.Free;
  end;

  // 4. User Config
  HasConfigIssue := Helper.CheckUserConfigHealth(CfgPath);
  if HasConfigIssue then
  begin
    FStep4Dot.Brush.Color := CLR_FAIL;
    FStep4Status.Caption := '● Outdated v1 configuration syntax detected.';
    FStep4Status.Font.Color := CLR_FAIL;
  end
  else
  begin
    FStep4Dot.Brush.Color := CLR_OK;
    FStep4Status.Caption := '● Configuration is up to date (version = 2).';
    FStep4Status.Font.Color := CLR_OK;
  end;

  Helper.UpdateMigrationAlertState;
  Helper.UpdateStatusCard;
end;

end.
