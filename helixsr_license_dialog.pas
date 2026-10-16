unit helixsr_license_dialog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, ExtCtrls, StdCtrls,
  Buttons, LCLType, LCLIntf, themeunit;

type
  { THelixSRLicenseDialog }
  THelixSRLicenseDialog = class(TForm)
  private
    FHeaderPanel: TPanel;
    FTitleLabel: TLabel;
    FCloseIconLbl: TLabel;
    FMemo: TMemo;
    FFooterPanel: TPanel;
    FUrlBtn: TBitBtn;
    FCloseBtn: TBitBtn;
    FDragging: Boolean;
    FDragStart: TPoint;

    procedure HeaderMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure HeaderMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure HeaderMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CloseClick(Sender: TObject);
    procedure UrlClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormPaint(Sender: TObject);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    property Memo: TMemo read FMemo;
    property CloseBtn: TBitBtn read FCloseBtn;
    property UrlBtn: TBitBtn read FUrlBtn;
  end;

function GetHelixSRLicenseText: string;
procedure ShowHelixSRLicenseDialog(AOwner: TComponent);

implementation

const
  FORM_W = 660;
  FORM_H = 500;
  CLR_BG_DARK   = $00281A16; // RGB(22, 26, 40)
  CLR_MEMO_DARK = $002E2620; // RGB(32, 38, 46)
  CLR_TEXT_DARK = $00D4CDC7;
  CLR_BORDER    = $004A3E32; // RGB(50, 62, 74)

function GetHelixSRLicenseText: string;
begin
  Result :=
    'HelixSR Freeware License' + sLineBreak +
    'Copyright (c) 2026 lonewolf0622. All rights reserved.' + sLineBreak + sLineBreak +
    'This license covers the HelixSR software, the DLL and its documentation, as published in this repository and in its' + sLineBreak +
    'official releases ("HelixSR"), except the parts listed in section 6.' + sLineBreak + sLineBreak +
    '1. Use. You may use HelixSR free of charge, for any lawful purpose, on any number of your own computers.' + sLineBreak + sLineBreak +
    '2. Redistribution. You may redistribute HelixSR only (a) unmodified, (b) complete, as published in an official release' + sLineBreak +
    '   at https://github.com/lonewolf0622/HelixSR/releases, including this license and the notices, and (c) free of' + sLineBreak +
    '   charge. You may not sell, rent, sublicense or host HelixSR as part of a paid product or service.' + sLineBreak + sLineBreak +
    '3. No modification. You may not modify HelixSR, create derivative works of it, or reverse engineer, decompile or' + sLineBreak +
    '   disassemble its compiled parts, except to the extent that applicable law allows you to despite this restriction.' + sLineBreak +
    '   Changing settings through helixsr.ini is not modification.' + sLineBreak + sLineBreak +
    '4. NVIDIA material. HelixSR does not include NVIDIA''s DLSS software, neural network weights or code. The HelixSR setup' + sLineBreak +
    '   builds network files on your computer from NVIDIA''s DLSS DLL, which you obtain from NVIDIA under NVIDIA''s license.' + sLineBreak +
    '   Those files remain NVIDIA''s property, are not covered by this license, and must not be shared or redistributed.' + sLineBreak +
    '   HelixSR is an independent, unofficial project and is not affiliated with or endorsed by NVIDIA or AMD.' + sLineBreak + sLineBreak +
    '5. Third-party components. HelixSR contains AMD FidelityFX code under AMD''s MIT license; see THIRD_PARTY_NOTICES.md.' + sLineBreak +
    '   The setup downloads other tools from their own sources, under their own licenses.' + sLineBreak + sLineBreak +
    '6. Setup scripts and other parts. The setup scripts (helixsr-setup.*, helixsr-uninstall.* and the setup folder) are' + sLineBreak +
    '   part of HelixSR and covered by this license: you may read and run them, but sections 2 and 3 apply to them too.' + sLineBreak +
    '   Setup scripts in releases up to and including 1.8.1 remain under the license they were published with (Apache' + sLineBreak +
    '   License, Version 2.0). Third-party files keep their own licenses.' + sLineBreak + sLineBreak +
    '7. No warranty. HelixSR is provided "as is", without warranty of any kind, express or implied, including' + sLineBreak +
    '   merchantability, fitness for a particular purpose and non-infringement. To the maximum extent permitted by law, the' + sLineBreak +
    '   author is not liable for any claim, damages or other liability arising from the use of HelixSR, including damage to' + sLineBreak +
    '   games, accounts or hardware.' + sLineBreak + sLineBreak +
    '8. Termination. Your rights under this license end automatically if you breach it.';
end;

procedure ShowHelixSRLicenseDialog(AOwner: TComponent);
var
  Dlg: THelixSRLicenseDialog;
begin
  Dlg := THelixSRLicenseDialog.CreateNew(AOwner);
  try
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

{ THelixSRLicenseDialog }

constructor THelixSRLicenseDialog.CreateNew(AOwner: TComponent; Dummy: Integer);
var
  IsLight: Boolean;
  BgCol, MemoBg, TextCol: TColor;
begin
  inherited CreateNew(AOwner, Dummy);
  Caption := 'HelixSR Freeware License';
  Width := FORM_W;
  Height := FORM_H;
  Position := poOwnerFormCenter;
  BorderStyle := bsNone;
  FormStyle := fsStayOnTop;
  PopupMode := pmAuto;
  KeyPreview := True;

  IsLight := (CurrentTheme = tmLight);
  if IsLight then
  begin
    BgCol := LightBackgroundColor;
    MemoBg := clWhite;
    TextCol := LightTextColor;
  end
  else
  begin
    BgCol := CLR_BG_DARK;
    MemoBg := CLR_MEMO_DARK;
    TextCol := CLR_TEXT_DARK;
  end;

  Color := BgCol;
  OnPaint := @FormPaint;
  OnKeyDown := @FormKeyDown;

  // Header Panel
  FHeaderPanel := TPanel.Create(Self);
  FHeaderPanel.Parent := Self;
  FHeaderPanel.SetBounds(0, 0, Width, 50);
  FHeaderPanel.BevelOuter := bvNone;
  FHeaderPanel.BevelInner := bvNone;
  FHeaderPanel.Color := BgCol;
  FHeaderPanel.OnMouseDown := @HeaderMouseDown;
  FHeaderPanel.OnMouseMove := @HeaderMouseMove;
  FHeaderPanel.OnMouseUp := @HeaderMouseUp;

  // Title Label
  FTitleLabel := TLabel.Create(Self);
  FTitleLabel.Parent := FHeaderPanel;
  FTitleLabel.SetBounds(20, 14, Width - 60, 24);
  FTitleLabel.Font.Size := 11;
  FTitleLabel.Font.Style := [fsBold];
  FTitleLabel.Font.Color := TextCol;
  FTitleLabel.Caption := '⚖️  HelixSR Freeware License';
  FTitleLabel.OnMouseDown := @HeaderMouseDown;
  FTitleLabel.OnMouseMove := @HeaderMouseMove;
  FTitleLabel.OnMouseUp := @HeaderMouseUp;

  // Close "✕" button in header
  FCloseIconLbl := TLabel.Create(Self);
  FCloseIconLbl.Parent := FHeaderPanel;
  FCloseIconLbl.SetBounds(Width - 36, 14, 24, 24);
  FCloseIconLbl.Font.Size := 12;
  FCloseIconLbl.Font.Style := [fsBold];
  FCloseIconLbl.Font.Color := RGBToColor(160, 170, 190);
  FCloseIconLbl.Caption := '✕';
  FCloseIconLbl.Alignment := taCenter;
  FCloseIconLbl.Cursor := crHandPoint;
  FCloseIconLbl.OnClick := @CloseClick;

  // Footer Panel (Anchored to bottom)
  FFooterPanel := TPanel.Create(Self);
  FFooterPanel.Parent := Self;
  FFooterPanel.SetBounds(0, Height - 52, Width, 52);
  FFooterPanel.BevelOuter := bvNone;
  FFooterPanel.BevelInner := bvNone;
  FFooterPanel.Color := BgCol;

  // Open releases URL button
  FUrlBtn := TBitBtn.Create(Self);
  FUrlBtn.Parent := FFooterPanel;
  FUrlBtn.SetBounds(16, 10, 160, 32);
  FUrlBtn.Caption := 'GitHub Releases ↗';
  FUrlBtn.Cursor := crHandPoint;
  FUrlBtn.OnClick := @UrlClick;
  StyleBitBtnTheme(FUrlBtn, TextCol, BgCol);

  // Close button
  FCloseBtn := TBitBtn.Create(Self);
  FCloseBtn.Parent := FFooterPanel;
  FCloseBtn.SetBounds(Width - 116, 10, 100, 32);
  FCloseBtn.Caption := 'Close';
  FCloseBtn.Cursor := crHandPoint;
  FCloseBtn.ModalResult := mrOk;
  FCloseBtn.OnClick := @CloseClick;
  StyleBitBtnTheme(FCloseBtn, TextCol, BgCol);

  // Memo displaying license
  FMemo := TMemo.Create(Self);
  FMemo.Parent := Self;
  FMemo.SetBounds(16, 50, Width - 32, Height - 50 - 52);
  FMemo.ReadOnly := True;
  FMemo.WordWrap := True;
  FMemo.ScrollBars := ssAutoVertical;
  FMemo.Color := MemoBg;
  FMemo.Font.Color := TextCol;
  FMemo.Font.Size := 9;
  FMemo.BorderStyle := bsSingle;
  FMemo.Text := GetHelixSRLicenseText;
end;

procedure THelixSRLicenseDialog.FormPaint(Sender: TObject);
begin
  Canvas.Pen.Color := CLR_BORDER;
  Canvas.Pen.Width := 1;
  Canvas.Brush.Style := bsClear;
  Canvas.Rectangle(0, 0, Width, Height);
end;

procedure THelixSRLicenseDialog.HeaderMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FDragging := True;
    FDragStart := Mouse.CursorPos;
  end;
end;

procedure THelixSRLicenseDialog.HeaderMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  CurPos: TPoint;
begin
  if FDragging then
  begin
    CurPos := Mouse.CursorPos;
    Left := Left + (CurPos.X - FDragStart.X);
    Top := Top + (CurPos.Y - FDragStart.Y);
    FDragStart := CurPos;
  end;
end;

procedure THelixSRLicenseDialog.HeaderMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FDragging := False;
end;

procedure THelixSRLicenseDialog.CloseClick(Sender: TObject);
begin
  Close;
end;

procedure THelixSRLicenseDialog.UrlClick(Sender: TObject);
begin
  OpenURL('https://github.com/lonewolf0622/HelixSR/releases');
end;

procedure THelixSRLicenseDialog.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

end.
