unit splash_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, ExtCtrls, StdCtrls, Math;

type
  TSplashForm = class(TForm)
  private
    FGameTitle: string;
    FItems: TStringList;
    FDurationMs: Integer;
    FAutoTimer: TTimer;
    FLogoImage: TImage;
    FTitleLabel: TLabel;
    FSubLabel: TLabel;
    FGameLabel: TLabel;
    FFooterLabel: TLabel;
    FItemControls: array of TControl;
    procedure FormPaint(Sender: TObject);
    procedure HandleDismiss(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure AutoTimerTick(Sender: TObject);
    procedure FindAndLoadLogo;
  public
    constructor CreateNew(AOwner: TComponent; Num: Integer = 0); override;
    destructor Destroy; override;
    procedure InitAndReflow;
    property GameTitle: string read FGameTitle write FGameTitle;
    property Items: TStringList read FItems;
    property DurationMs: Integer read FDurationMs write FDurationMs;
  end;

implementation

constructor TSplashForm.CreateNew(AOwner: TComponent; Num: Integer);
begin
  inherited CreateNew(AOwner, Num);
  FItems := TStringList.Create;
  FDurationMs := 2500;
  SetLength(FItemControls, 0);

  BorderStyle := bsNone;
  Position := poScreenCenter;
  FormStyle := fsStayOnTop;
  Color := RGBToColor(22, 26, 38);
  Width := 460;
  Height := 240;

  OnPaint := @FormPaint;
  OnClick := @HandleDismiss;
  OnKeyDown := @FormKeyDown;
  KeyPreview := True;

  FAutoTimer := TTimer.Create(Self);
  FAutoTimer.Enabled := False;
  FAutoTimer.OnTimer := @AutoTimerTick;
end;

destructor TSplashForm.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TSplashForm.HandleDismiss(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TSplashForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Application.Terminate;
end;

procedure TSplashForm.AutoTimerTick(Sender: TObject);
begin
  FAutoTimer.Enabled := False;
  Application.Terminate;
end;

procedure TSplashForm.FormPaint(Sender: TObject);
begin
  Canvas.Brush.Style := bsClear;
  Canvas.Pen.Color := RGBToColor(55, 70, 108);
  Canvas.Pen.Width := 1;
  Canvas.RoundRect(0, 0, Width - 1, Height - 1, 14, 14);

  // Subtle accent line under header
  Canvas.Pen.Color := RGBToColor(40, 48, 75);
  Canvas.Line(24, 88, Width - 24, 88);
end;

procedure TSplashForm.FindAndLoadLogo;
var
  Paths: array[0..5] of string;
  P, AppDir: string;
  i: Integer;
begin
  AppDir := ExtractFilePath(ParamStr(0));
  Paths[0] := '/usr/share/icons/hicolor/256x256/apps/io.github.benjamimgois.goverlay.png';
  Paths[1] := '/usr/local/share/icons/hicolor/256x256/apps/io.github.benjamimgois.goverlay.png';
  Paths[2] := AppDir + '../share/icons/hicolor/256x256/apps/io.github.benjamimgois.goverlay.png';
  Paths[3] := AppDir + 'data/icons/256x256/goverlay.png';
  Paths[4] := AppDir + '../data/icons/256x256/goverlay.png';
  Paths[5] := AppDir + 'goverlay.png';

  for i := 0 to High(Paths) do
  begin
    P := Paths[i];
    if FileExists(P) then
    begin
      try
        FLogoImage.Picture.LoadFromFile(P);
        Exit;
      except
      end;
    end;
  end;
end;

procedure TSplashForm.InitAndReflow;
var
  i, CurY, BoxH, ListH: Integer;
  IconLbl, TextLbl: TLabel;
  ItemStr, ModName, ModDetail: string;
  SepPos: Integer;
begin
  // Logo image (left-aligned)
  if not Assigned(FLogoImage) then
  begin
    FLogoImage := TImage.Create(Self);
    FLogoImage.Parent := Self;
    FLogoImage.SetBounds(24, 20, 52, 52);
    FLogoImage.Stretch := True;
    FLogoImage.Proportional := True;
    FLogoImage.OnClick := @HandleDismiss;
    FindAndLoadLogo;
  end;

  // Title
  if not Assigned(FTitleLabel) then
  begin
    FTitleLabel := TLabel.Create(Self);
    FTitleLabel.Parent := Self;
    FTitleLabel.Caption := 'GOverlay';
    FTitleLabel.Font.Color := clWhite;
    FTitleLabel.Font.Size := 15;
    FTitleLabel.Font.Style := [fsBold];
    FTitleLabel.SetBounds(88, 20, 340, 24);
    FTitleLabel.OnClick := @HandleDismiss;
  end;

  // Subtitle
  if not Assigned(FSubLabel) then
  begin
    FSubLabel := TLabel.Create(Self);
    FSubLabel.Parent := Self;
    FSubLabel.Caption := 'Applying game configurations';
    FSubLabel.Font.Color := RGBToColor(160, 175, 210);
    FSubLabel.Font.Size := 10;
    FSubLabel.SetBounds(88, 44, 340, 18);
    FSubLabel.OnClick := @HandleDismiss;
  end;

  // Game name if provided
  if not Assigned(FGameLabel) then
  begin
    FGameLabel := TLabel.Create(Self);
    FGameLabel.Parent := Self;
    if FGameTitle <> '' then
      FGameLabel.Caption := 'Game: ' + FGameTitle
    else
      FGameLabel.Caption := '';
    FGameLabel.Font.Color := RGBToColor(120, 185, 255);
    FGameLabel.Font.Size := 9;
    FGameLabel.SetBounds(88, 64, 340, 16);
    FGameLabel.Visible := (FGameTitle <> '');
    FGameLabel.OnClick := @HandleDismiss;
  end;

  // Render checklist items
  CurY := 102;
  if FItems.Count = 0 then
    FItems.Add('Configurations active');

  for i := 0 to FItems.Count - 1 do
  begin
    ItemStr := Trim(FItems[i]);
    ModName := ItemStr;
    ModDetail := '';
    SepPos := Pos('::', ItemStr);
    if SepPos > 0 then
    begin
      ModName := Trim(Copy(ItemStr, 1, SepPos - 1));
      ModDetail := Trim(Copy(ItemStr, SepPos + 2, Length(ItemStr)));
    end;

    // Green checkmark
    IconLbl := TLabel.Create(Self);
    IconLbl.Parent := Self;
    IconLbl.Caption := '✔';
    IconLbl.Font.Color := RGBToColor(46, 204, 113); // Vibrant emerald green
    IconLbl.Font.Size := 12;
    IconLbl.Font.Style := [fsBold];
    IconLbl.SetBounds(32, CurY, 22, 22);
    IconLbl.OnClick := @HandleDismiss;

    // Item label
    TextLbl := TLabel.Create(Self);
    TextLbl.Parent := Self;
    if ModDetail <> '' then
      TextLbl.Caption := ModName + '  (' + ModDetail + ')'
    else
      TextLbl.Caption := ModName;
    TextLbl.Font.Color := RGBToColor(230, 235, 245);
    TextLbl.Font.Size := 10;
    TextLbl.SetBounds(58, CurY + 2, 370, 20);
    TextLbl.OnClick := @HandleDismiss;

    CurY := CurY + 26;
  end;

  // Footer label
  if not Assigned(FFooterLabel) then
  begin
    FFooterLabel := TLabel.Create(Self);
    FFooterLabel.Parent := Self;
    FFooterLabel.Caption := 'Launching game...';
    FFooterLabel.Font.Color := RGBToColor(110, 120, 145);
    FFooterLabel.Font.Size := 8;
    FFooterLabel.SetBounds(32, CurY + 10, 390, 16);
    FFooterLabel.OnClick := @HandleDismiss;
  end
  else
    FFooterLabel.SetBounds(32, CurY + 10, 390, 16);

  BoxH := CurY + 36;
  Height := Max(190, BoxH);
  Width := 460;

  // Center on screen
  Left := (Screen.Width - Width) div 2;
  Top := (Screen.Height - Height) div 2;

  // Start auto-close timer
  FAutoTimer.Interval := FDurationMs;
  FAutoTimer.Enabled := True;
end;

end.
