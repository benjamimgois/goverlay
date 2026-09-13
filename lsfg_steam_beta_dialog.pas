unit lsfg_steam_beta_dialog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, ExtCtrls, StdCtrls,
  Buttons, LCLIntf;

type
  { TLSFGVkSteamBetaNoticeDialog }
  TLSFGVkSteamBetaNoticeDialog = class(TForm)
  private
    FTabHelper: TObject;

    // Header
    FHeaderPanel: TPanel;
    FTitleLabel: TLabel;
    FSubtitleLabel: TLabel;

    // Content container
    FScrollBox: TScrollBox;

    // Image Card
    FImageCard: TPanel;
    FSteamImage: TImage;
    FImageCaption: TLabel;

    // Steps Card
    FStepsCard: TPanel;
    FStepsTitle: TLabel;
    FStep1Lbl: TLabel;
    FStep2Lbl: TLabel;
    FStep3Lbl: TLabel;
    FStep4Lbl: TLabel;

    // Bottom bar
    FBottomPanel: TPanel;
    FDoNotShowAgainCheck: TCheckBox;
    FOpenFolderBtn: TBitBtn;
    FMigrationBtn: TBitBtn;
    FCloseBtn: TBitBtn;

    procedure BuildUI;
    procedure CardPaint(Sender: TObject);
    procedure OpenFolderClick(Sender: TObject);
    procedure MigrationAssistantClick(Sender: TObject);
    procedure CloseClick(Sender: TObject);
    procedure DoNotShowAgainChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    constructor Create(AOwner: TComponent; ATabHelper: TObject = nil); reintroduce;
    destructor Destroy; override;

    // Properties for testing
    property DoNotShowAgainCheck: TCheckBox read FDoNotShowAgainCheck;
    property OpenFolderBtn: TBitBtn read FOpenFolderBtn;
    property MigrationBtn: TBitBtn read FMigrationBtn;
    property CloseBtn: TBitBtn read FCloseBtn;
    property SteamImage: TImage read FSteamImage;
  end;

function ShowLsfgSteamBetaNoticeDialog(AOwner: TComponent; ATabHelper: TObject = nil): Boolean;
function GetSteamBetaImagePath: string;

implementation

uses
  lossless_scaling_tab, lsfg_migration_dialog, themeunit;

const
  CLR_BG       = $00281A16; // #161A28 (Dark theme background)
  CLR_SURFACE  = $002E2620; // #20262E (SubCard background)
  CLR_BORDER   = $004A3E32; // #323E4A (SubCard border)
  CLR_OK       = $0044BB44; // Green
  CLR_WARN     = $000B9EF5; // Amber / Orange
  CLR_TEXT     = $00D4CDC7; // Text light
  CLR_MUTED    = $00998877; // Text muted

function GetSteamBetaImagePath: string;
var
  BaseDir, AppDir, BinaryDir: string;
begin
  Result := '';
  AppDir := GetEnvironmentVariable('APPDIR');
  if AppDir <> '' then
    BaseDir := IncludeTrailingPathDelimiter(AppDir) + 'bin/'
  else
  begin
    BinaryDir := ExtractFilePath(Application.ExeName);
    if DirectoryExists(BinaryDir + 'assets') then
      BaseDir := BinaryDir
    else
      BaseDir := ExtractFilePath(ExtractFileDir(Application.ExeName)) + 'share/goverlay/';
  end;

  if FileExists(BaseDir + 'assets/images/steam_lsfg_beta.png') then
    Exit(BaseDir + 'assets/images/steam_lsfg_beta.png');
  if FileExists('assets/images/steam_lsfg_beta.png') then
    Exit('assets/images/steam_lsfg_beta.png');
  if FileExists('/usr/share/goverlay/assets/images/steam_lsfg_beta.png') then
    Exit('/usr/share/goverlay/assets/images/steam_lsfg_beta.png');
end;

function ShowLsfgSteamBetaNoticeDialog(AOwner: TComponent; ATabHelper: TObject): Boolean;
var
  Dlg: TLSFGVkSteamBetaNoticeDialog;
begin
  Dlg := TLSFGVkSteamBetaNoticeDialog.Create(AOwner, ATabHelper);
  try
    Result := (Dlg.ShowModal = mrOk);
  finally
    Dlg.Free;
  end;
end;

constructor TLSFGVkSteamBetaNoticeDialog.Create(AOwner: TComponent; ATabHelper: TObject);
begin
  inherited CreateNew(AOwner);
  FTabHelper := ATabHelper;
  BuildUI;
end;

destructor TLSFGVkSteamBetaNoticeDialog.Destroy;
begin
  inherited Destroy;
end;

procedure TLSFGVkSteamBetaNoticeDialog.CardPaint(Sender: TObject);
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

procedure TLSFGVkSteamBetaNoticeDialog.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 27 then // Escape
    CloseClick(Sender);
end;

procedure TLSFGVkSteamBetaNoticeDialog.OpenFolderClick(Sender: TObject);
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

procedure TLSFGVkSteamBetaNoticeDialog.MigrationAssistantClick(Sender: TObject);
var
  OwnerComp: TComponent;
  HelperObj: TObject;
begin
  OwnerComp := Self.Owner;
  HelperObj := FTabHelper;
  Close;
  ShowLsfgMigrationDialog(OwnerComp, HelperObj);
end;

procedure TLSFGVkSteamBetaNoticeDialog.DoNotShowAgainChange(Sender: TObject);
begin
  if Assigned(FTabHelper) and (FTabHelper is TLosslessScalingTabHelper) then
    TLosslessScalingTabHelper(FTabHelper).HideSteamBetaNotice := FDoNotShowAgainCheck.Checked;
end;

procedure TLSFGVkSteamBetaNoticeDialog.CloseClick(Sender: TObject);
begin
  if Assigned(FDoNotShowAgainCheck) and FDoNotShowAgainCheck.Checked then
  begin
    if Assigned(FTabHelper) and (FTabHelper is TLosslessScalingTabHelper) then
      TLosslessScalingTabHelper(FTabHelper).HideSteamBetaNotice := True;
  end;
  ModalResult := mrOk;
  Close;
end;

procedure TLSFGVkSteamBetaNoticeDialog.BuildUI;
const
  DLG_W = 780;
  DLG_H = 720;
  PAD   = 16;
  CARD_W = DLG_W - 2 * PAD - 18; // account for scrollbar
  IMG_H  = 370;
var
  CurY: Integer;
  ImgPath: string;
  Helper: TLosslessScalingTabHelper;
begin
  Caption := 'lsfg-vk 2.0: Steam Beta Branch Required';
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
  FTitleLabel.Caption := 'Steam Beta Branch Required for lsfg-vk 2.0';
  FTitleLabel.Font.Size := 13;
  FTitleLabel.Font.Style := [fsBold];
  FTitleLabel.Font.Color := clWhite;
  FTitleLabel.SetBounds(PAD, 12, DLG_W - 2 * PAD, 22);

  FSubtitleLabel := TLabel.Create(Self);
  FSubtitleLabel.Parent := FHeaderPanel;
  FSubtitleLabel.Caption := 'Lossless Scaling must be configured in Steam to download the required Vulkan shaders (lsfg-vk.dll).';
  FSubtitleLabel.Font.Size := 9;
  FSubtitleLabel.Font.Color := CLR_TEXT;
  FSubtitleLabel.SetBounds(PAD, 36, DLG_W - 2 * PAD, 18);

  // --- Bottom Panel ---
  FBottomPanel := TPanel.Create(Self);
  FBottomPanel.Parent := Self;
  FBottomPanel.SetBounds(0, DLG_H - 58, DLG_W, 58);
  FBottomPanel.BevelOuter := bvNone;
  FBottomPanel.Color := CLR_BG;

  FDoNotShowAgainCheck := TCheckBox.Create(Self);
  FDoNotShowAgainCheck.Parent := FBottomPanel;
  FDoNotShowAgainCheck.Caption := 'Do not show this notice again';
  FDoNotShowAgainCheck.Font.Size := 9;
  FDoNotShowAgainCheck.Font.Color := CLR_TEXT;
  FDoNotShowAgainCheck.SetBounds(PAD, 18, 250, 24);
  FDoNotShowAgainCheck.OnChange := @DoNotShowAgainChange;
  if Assigned(FTabHelper) and (FTabHelper is TLosslessScalingTabHelper) then
  begin
    Helper := TLosslessScalingTabHelper(FTabHelper);
    FDoNotShowAgainCheck.Checked := Helper.HideSteamBetaNotice;
  end;

  FMigrationBtn := TBitBtn.Create(Self);
  FMigrationBtn.Parent := FBottomPanel;
  FMigrationBtn.Caption := 'Migration Assistant';
  FMigrationBtn.Cursor := crHandPoint;
  FMigrationBtn.SetBounds(DLG_W - PAD - 410, 14, 150, 32);
  FMigrationBtn.OnClick := @MigrationAssistantClick;

  FOpenFolderBtn := TBitBtn.Create(Self);
  FOpenFolderBtn.Parent := FBottomPanel;
  FOpenFolderBtn.Caption := 'Open Steam Folder';
  FOpenFolderBtn.Cursor := crHandPoint;
  FOpenFolderBtn.SetBounds(DLG_W - PAD - 250, 14, 150, 32);
  FOpenFolderBtn.OnClick := @OpenFolderClick;

  FCloseBtn := TBitBtn.Create(Self);
  FCloseBtn.Parent := FBottomPanel;
  FCloseBtn.Caption := 'Got It';
  FCloseBtn.Cursor := crHandPoint;
  FCloseBtn.SetBounds(DLG_W - PAD - 90, 14, 90, 32);
  FCloseBtn.OnClick := @CloseClick;

  // --- ScrollBox for content ---
  FScrollBox := TScrollBox.Create(Self);
  FScrollBox.Parent := Self;
  FScrollBox.SetBounds(0, 64, DLG_W, DLG_H - 64 - 58);
  FScrollBox.BorderStyle := bsNone;
  FScrollBox.Color := CLR_BG;
  FScrollBox.AutoScroll := True;

  CurY := 6;

  // ── Card 1: Steam Screenshot ──────────────────────────────────────────
  FImageCard := TPanel.Create(FScrollBox);
  FImageCard.Parent := FScrollBox;
  FImageCard.SetBounds(PAD, CurY, CARD_W, IMG_H + 42);
  FImageCard.BevelOuter := bvNone;
  FImageCard.Color := CLR_SURFACE;
  FImageCard.OnPaint := @CardPaint;

  FSteamImage := TImage.Create(FImageCard);
  FSteamImage.Parent := FImageCard;
  FSteamImage.SetBounds(12, 10, CARD_W - 24, IMG_H);
  FSteamImage.Proportional := True;
  FSteamImage.Stretch := True;
  FSteamImage.Center := True;
  FSteamImage.AntialiasingMode := amOn;

  ImgPath := GetSteamBetaImagePath;
  if (ImgPath <> '') and FileExists(ImgPath) then
  begin
    try
      FSteamImage.Picture.LoadFromFile(ImgPath);
    except
    end;
  end;

  FImageCaption := TLabel.Create(FImageCard);
  FImageCaption.Parent := FImageCard;
  FImageCaption.Caption := 'Steam > Library > Lossless Scaling (Right Click) > Properties... > Game Versions && Betas > Select "lsfg-vk"';
  FImageCaption.Font.Size := 9;
  FImageCaption.Font.Style := [fsBold];
  FImageCaption.Font.Color := CLR_WARN;
  FImageCaption.Alignment := taCenter;
  FImageCaption.SetBounds(12, IMG_H + 16, CARD_W - 24, 20);

  CurY := CurY + (IMG_H + 42) + 10;

  // ── Card 2: Step-by-Step Instructions ──────────────────────────────────
  FStepsCard := TPanel.Create(FScrollBox);
  FStepsCard.Parent := FScrollBox;
  FStepsCard.SetBounds(PAD, CurY, CARD_W, 160);
  FStepsCard.BevelOuter := bvNone;
  FStepsCard.Color := CLR_SURFACE;
  FStepsCard.OnPaint := @CardPaint;

  FStepsTitle := TLabel.Create(FStepsCard);
  FStepsTitle.Parent := FStepsCard;
  FStepsTitle.Caption := 'Follow these steps in Steam:';
  FStepsTitle.Font.Size := 10;
  FStepsTitle.Font.Style := [fsBold];
  FStepsTitle.Font.Color := clWhite;
  FStepsTitle.SetBounds(16, 12, CARD_W - 32, 20);

  FStep1Lbl := TLabel.Create(FStepsCard);
  FStep1Lbl.Parent := FStepsCard;
  FStep1Lbl.Caption := '1. Open Steam, find "Lossless Scaling" in your Library, and right-click it.';
  FStep1Lbl.Font.Size := 9;
  FStep1Lbl.Font.Color := CLR_TEXT;
  FStep1Lbl.SetBounds(16, 38, CARD_W - 32, 18);

  FStep2Lbl := TLabel.Create(FStepsCard);
  FStep2Lbl.Parent := FStepsCard;
  FStep2Lbl.Caption := '2. Click "Properties..." from the context menu.';
  FStep2Lbl.Font.Size := 9;
  FStep2Lbl.Font.Color := CLR_TEXT;
  FStep2Lbl.SetBounds(16, 62, CARD_W - 32, 18);

  FStep3Lbl := TLabel.Create(FStepsCard);
  FStep3Lbl.Parent := FStepsCard;
  FStep3Lbl.Caption := '3. Navigate to "Betas" (Game Versions && Betas) on the left sidebar.';
  FStep3Lbl.Font.Size := 9;
  FStep3Lbl.Font.Color := CLR_TEXT;
  FStep3Lbl.SetBounds(16, 86, CARD_W - 32, 18);

  FStep4Lbl := TLabel.Create(FStepsCard);
  FStep4Lbl.Parent := FStepsCard;
  FStep4Lbl.Caption := '4. Select the "lsfg-vk" branch (Required files for lsfg-vk) and wait for Steam to update.';
  FStep4Lbl.Font.Size := 9;
  FStep4Lbl.Font.Color := CLR_TEXT;
  FStep4Lbl.SetBounds(16, 110, CARD_W - 32, 18);
end;

end.
