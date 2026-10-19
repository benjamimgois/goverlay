unit dlssnr_advanced_dialog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, ExtCtrls, StdCtrls,
  Buttons, LCLType, LCLIntf, themeunit, overlay_config, toggle_switch;

type
  { TDlssNrAdvancedDialog }
  TDlssNrAdvancedDialog = class(TForm)
  private
    FHeaderPanel: TPanel;
    FTitleLabel: TLabel;
    FCloseBtn: TBitBtn;
    FContentPanel: TPanel;
    FFooterPanel: TPanel;
    FSaveBtn: TBitBtn;
    FCancelBtn: TBitBtn;

    FRouteLabel: TLabel;
    FRouteComboBox: TComboBox;
    FFinishedPicToggle: TToggleSwitch;
    FRenoDxToggle: TToggleSwitch;
    FPreprocessToggle: TToggleSwitch;
    FSkinProtectionToggle: TToggleSwitch;

    FDragging: Boolean;
    FDragStart: TPoint;

    procedure HeaderMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure HeaderMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure HeaderMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CloseClick(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormPaint(Sender: TObject);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
  end;

function ShowDlssNrAdvancedDialog(AOwner: TComponent; var Settings: TOptiScalerSettings): Boolean;

implementation

const
  FORM_W = 480;
  FORM_H = 370;
  CLR_BG_DARK    = $00281A16; // RGB(22, 26, 40)
  CLR_PANEL_DARK = $002E2620; // RGB(32, 38, 46)
  CLR_TEXT_DARK  = $00D4CDC7;
  CLR_BORDER     = $004A3E32; // RGB(50, 62, 74)

function ShowDlssNrAdvancedDialog(AOwner: TComponent; var Settings: TOptiScalerSettings): Boolean;
var
  Dlg: TDlssNrAdvancedDialog;
begin
  Result := False;
  Dlg := TDlssNrAdvancedDialog.CreateNew(AOwner);
  try
    // Populate controls from current Settings
    if (Settings.DlssNrRouteIndex >= 0) and (Settings.DlssNrRouteIndex < Dlg.FRouteComboBox.Items.Count) then
      Dlg.FRouteComboBox.ItemIndex := Settings.DlssNrRouteIndex
    else
      Dlg.FRouteComboBox.ItemIndex := 0;

    Dlg.FFinishedPicToggle.Checked := Settings.DlssNrFinishedPictureChecked;
    Dlg.FRenoDxToggle.Checked := Settings.DlssNrRenoDxChecked;
    Dlg.FPreprocessToggle.Checked := Settings.DlssNrPreprocessChecked;
    Dlg.FSkinProtectionToggle.Checked := Settings.DlssNrSkinProtectionChecked;

    if Dlg.ShowModal = mrOk then
    begin
      Settings.DlssNrRouteIndex := Dlg.FRouteComboBox.ItemIndex;
      Settings.DlssNrFinishedPictureChecked := Dlg.FFinishedPicToggle.Checked;
      Settings.DlssNrRenoDxChecked := Dlg.FRenoDxToggle.Checked;
      Settings.DlssNrPreprocessChecked := Dlg.FPreprocessToggle.Checked;
      Settings.DlssNrSkinProtectionChecked := Dlg.FSkinProtectionToggle.Checked;
      Result := True;
    end;
  finally
    Dlg.Free;
  end;
end;

{ TDlssNrAdvancedDialog }

constructor TDlssNrAdvancedDialog.CreateNew(AOwner: TComponent; Dummy: Integer);
var
  IsLight: Boolean;
  BgCol, PanelBg, TextCol: TColor;
  Y: Integer;
begin
  inherited CreateNew(AOwner, Dummy);

  IsLight := (CurrentTheme = tmLight);
  if IsLight then
  begin
    BgCol   := LightBackgroundColor;
    PanelBg := LighterBackgroundColor;
    TextCol := LightTextColor;
  end
  else
  begin
    BgCol   := CLR_BG_DARK;
    PanelBg := CLR_PANEL_DARK;
    TextCol := CLR_TEXT_DARK;
  end;

  BorderStyle     := bsNone;
  Position        := poOwnerFormCenter;
  Width           := FORM_W;
  Height          := FORM_H;
  Color           := BgCol;
  KeyPreview      := True;
  OnKeyDown       := @FormKeyDown;
  OnPaint         := @FormPaint;
  DoubleBuffered  := True;

  // Header panel
  FHeaderPanel := TPanel.Create(Self);
  FHeaderPanel.Parent      := Self;
  FHeaderPanel.SetBounds(0, 0, FORM_W, 42);
  FHeaderPanel.BevelOuter  := bvNone;
  FHeaderPanel.BevelInner  := bvNone;
  FHeaderPanel.ParentBackground := False;
  FHeaderPanel.Color       := PanelBg;
  FHeaderPanel.OnMouseDown := @HeaderMouseDown;
  FHeaderPanel.OnMouseMove := @HeaderMouseMove;
  FHeaderPanel.OnMouseUp   := @HeaderMouseUp;

  FTitleLabel := TLabel.Create(Self);
  FTitleLabel.Parent      := FHeaderPanel;
  FTitleLabel.SetBounds(16, 12, FORM_W - 60, 20);
  FTitleLabel.Caption     := '⚙ DLSS-NR Advanced Settings';
  FTitleLabel.Font.Style  := [fsBold];
  FTitleLabel.Font.Size   := 10;
  FTitleLabel.Font.Color  := TextCol;
  FTitleLabel.OnMouseDown := @HeaderMouseDown;
  FTitleLabel.OnMouseMove := @HeaderMouseMove;
  FTitleLabel.OnMouseUp   := @HeaderMouseUp;

  FCloseBtn := TBitBtn.Create(Self);
  FCloseBtn.Parent  := FHeaderPanel;
  FCloseBtn.SetBounds(FORM_W - 36, 8, 26, 26);
  FCloseBtn.Caption := '✕';
  FCloseBtn.Font.Size := 9;
  FCloseBtn.Font.Style := [fsBold];
  FCloseBtn.Cursor  := crHandPoint;
  FCloseBtn.OnClick := @CloseClick;
  if IsLight then
    StyleBitBtnTheme(FCloseBtn, LightTextColor, PanelBg)
  else
    StyleBitBtnTheme(FCloseBtn, clWhite, PanelBg);

  // Footer panel (created before content panel)
  FFooterPanel := TPanel.Create(Self);
  FFooterPanel.Parent     := Self;
  FFooterPanel.SetBounds(0, FORM_H - 50, FORM_W, 50);
  FFooterPanel.BevelOuter := bvNone;
  FFooterPanel.BevelInner := bvNone;
  FFooterPanel.ParentBackground := False;
  FFooterPanel.Color      := PanelBg;

  FSaveBtn := TBitBtn.Create(Self);
  FSaveBtn.Parent   := FFooterPanel;
  FSaveBtn.SetBounds(FORM_W - 190, 10, 85, 30);
  FSaveBtn.Caption  := 'Save';
  FSaveBtn.Cursor   := crHandPoint;
  FSaveBtn.OnClick  := @SaveClick;
  if IsLight then
    StyleBitBtnTheme(FSaveBtn, LightTextColor, PanelBg)
  else
    StyleBitBtnTheme(FSaveBtn, clWhite, PanelBg);

  FCancelBtn := TBitBtn.Create(Self);
  FCancelBtn.Parent  := FFooterPanel;
  FCancelBtn.SetBounds(FORM_W - 95, 10, 85, 30);
  FCancelBtn.Caption := 'Cancel';
  FCancelBtn.Cursor  := crHandPoint;
  FCancelBtn.OnClick := @CloseClick;
  if IsLight then
    StyleBitBtnTheme(FCancelBtn, LightTextColor, PanelBg)
  else
    StyleBitBtnTheme(FCancelBtn, clWhite, PanelBg);

  // Content panel
  FContentPanel := TPanel.Create(Self);
  FContentPanel.Parent     := Self;
  FContentPanel.SetBounds(0, 42, FORM_W, FORM_H - 42 - 50);
  FContentPanel.BevelOuter := bvNone;
  FContentPanel.BevelInner := bvNone;
  FContentPanel.ParentBackground := False;
  FContentPanel.Color      := BgCol;

  Y := 16;

  // Injection Route
  FRouteLabel := TLabel.Create(Self);
  FRouteLabel.Parent     := FContentPanel;
  FRouteLabel.SetBounds(24, Y, FORM_W - 48, 16);
  FRouteLabel.Caption    := 'Injection Route:';
  FRouteLabel.Font.Style := [fsBold];
  FRouteLabel.Font.Color := TextCol;

  FRouteComboBox := TComboBox.Create(Self);
  FRouteComboBox.Parent := FContentPanel;
  FRouteComboBox.Style  := csDropDownList;
  FRouteComboBox.Items.Add('OptiScaler');
  FRouteComboBox.Items.Add('ReShade');
  FRouteComboBox.Items.Add('Vulkan');
  FRouteComboBox.Items.Add('DX9');
  FRouteComboBox.SetBounds(24, Y + 22, FORM_W - 48, 26);
  StyleInputControl(FRouteComboBox);

  Y := Y + 60;

  // Finished Picture toggle
  FFinishedPicToggle := TToggleSwitch.Create(Self);
  FFinishedPicToggle.Parent  := FContentPanel;
  FFinishedPicToggle.Caption := 'Apply to Finished Picture (DirectX 12)';
  FFinishedPicToggle.Hint    := 'Applies neural rendering after game post-processing and tone-mapping';
  FFinishedPicToggle.ShowHint:= True;
  FFinishedPicToggle.SetBounds(24, Y, FORM_W - 48, 24);

  Y := Y + 34;

  // RenoDX Color Style toggle
  FRenoDxToggle := TToggleSwitch.Create(Self);
  FRenoDxToggle.Parent  := FContentPanel;
  FRenoDxToggle.Caption := 'RenoDX Color Style';
  FRenoDxToggle.Hint    := 'Applies HDR color space handling tuned for RenoDX shaders';
  FRenoDxToggle.ShowHint:= True;
  FRenoDxToggle.SetBounds(24, Y, FORM_W - 48, 24);

  Y := Y + 34;

  // Preprocess Auto-exposure toggle
  FPreprocessToggle := TToggleSwitch.Create(Self);
  FPreprocessToggle.Parent  := FContentPanel;
  FPreprocessToggle.Caption := 'Preprocess Auto-exposure';
  FPreprocessToggle.Hint    := 'Auto-exposure preprocessing pass before neural reconstruction';
  FPreprocessToggle.ShowHint:= True;
  FPreprocessToggle.SetBounds(24, Y, FORM_W - 48, 24);

  Y := Y + 34;

  // Skin Protection toggle
  FSkinProtectionToggle := TToggleSwitch.Create(Self);
  FSkinProtectionToggle.Parent  := FContentPanel;
  FSkinProtectionToggle.Caption := 'Skin Protection Filter';
  FSkinProtectionToggle.Hint    := 'Color-based protection filter for human skin and character faces';
  FSkinProtectionToggle.ShowHint:= True;
  FSkinProtectionToggle.SetBounds(24, Y, FORM_W - 48, 24);
end;

procedure TDlssNrAdvancedDialog.HeaderMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FDragging  := True;
    FDragStart := Point(X, Y);
  end;
end;

procedure TDlssNrAdvancedDialog.HeaderMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if FDragging then
  begin
    Left := Left + (X - FDragStart.X);
    Top  := Top  + (Y - FDragStart.Y);
  end;
end;

procedure TDlssNrAdvancedDialog.HeaderMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FDragging := False;
end;

procedure TDlssNrAdvancedDialog.CloseClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TDlssNrAdvancedDialog.SaveClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TDlssNrAdvancedDialog.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    ModalResult := mrCancel;
  end;
end;

procedure TDlssNrAdvancedDialog.FormPaint(Sender: TObject);
begin
  Canvas.Brush.Color := Color;
  Canvas.Brush.Style := bsSolid;
  Canvas.Pen.Style   := psClear;
  Canvas.FillRect(ClientRect);
end;

end.
