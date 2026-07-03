unit changelogunit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Buttons, LCLIntf, LCLType, IpHtml;

type
  TChangelogForm = class(TForm)
  private
    FTitleLabel: TLabel;
    FCloseIconLbl: TLabel;
    FHtmlPanel: TIpHtmlPanel;
    FDragging: Boolean;
    FDragStart: TPoint;
    procedure FormPaint(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure HeaderMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure HeaderMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure HeaderMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CloseBtnClick(Sender: TObject);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    procedure SetChangelogText(const AVersion, AText: string);
  end;

procedure ShowChangelogPopup(const AVersion, AText: string);

implementation

uses
  themeunit;

constructor TChangelogForm.CreateNew(AOwner: TComponent; Dummy: Integer = 0);
begin
  inherited CreateNew(AOwner, Dummy);
  Caption := 'What''s New in GOverlay';
  Width := 600;
  Height := 520;
  Position := poOwnerFormCenter;
  BorderStyle := bsNone;
  FormStyle := fsStayOnTop;
  PopupMode := pmAuto;
  Color := RGBToColor(22, 26, 40); // GOverlay background navy blue
  OnPaint := @FormPaint;
  OnClose := @FormClose;
  OnMouseDown := @HeaderMouseDown;
  OnMouseMove := @HeaderMouseMove;
  OnMouseUp := @HeaderMouseUp;

  // Title Label (Header)
  FTitleLabel := TLabel.Create(Self);
  FTitleLabel.Parent := Self;
  FTitleLabel.SetBounds(20, 16, 520, 28);
  FTitleLabel.Font.Size := 12;
  FTitleLabel.Font.Style := [fsBold];
  FTitleLabel.Font.Color := clWhite;
  FTitleLabel.Caption := '🚀 What''s New in GOverlay';
  FTitleLabel.OnMouseDown := @HeaderMouseDown;
  FTitleLabel.OnMouseMove := @HeaderMouseMove;
  FTitleLabel.OnMouseUp := @HeaderMouseUp;

  // Close "X" icon in top right
  FCloseIconLbl := TLabel.Create(Self);
  FCloseIconLbl.Parent := Self;
  FCloseIconLbl.SetBounds(Width - 36, 14, 24, 24);
  FCloseIconLbl.Font.Size := 12;
  FCloseIconLbl.Font.Style := [fsBold];
  FCloseIconLbl.Font.Color := RGBToColor(160, 170, 190);
  FCloseIconLbl.Caption := '✕';
  FCloseIconLbl.Alignment := taCenter;
  FCloseIconLbl.Cursor := crHandPoint;
  FCloseIconLbl.OnClick := @CloseBtnClick;

  // HTML panel for formatted changelog with images
  FHtmlPanel := TIpHtmlPanel.Create(Self);
  FHtmlPanel.Parent := Self;
  FHtmlPanel.SetBounds(20, 56, 560, 390);
  FHtmlPanel.Anchors := [akLeft, akTop, akRight, akBottom];
  FHtmlPanel.BorderStyle := bsNone;

  end;

procedure TChangelogForm.FormPaint(Sender: TObject);
begin
  // Draw custom border matching GOverlay styling
  Canvas.Brush.Style := bsClear;
  Canvas.Pen.Color := RGBToColor(45, 55, 80);
  Canvas.Pen.Width := 2;
  Canvas.Rectangle(0, 0, Width, Height);
end;

procedure TChangelogForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
end;

procedure TChangelogForm.HeaderMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FDragging := True;
    FDragStart := Mouse.CursorPos;
  end;
end;

procedure TChangelogForm.HeaderMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
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

procedure TChangelogForm.HeaderMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    FDragging := False;
end;

procedure TChangelogForm.CloseBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TChangelogForm.SetChangelogText(const AVersion, AText: string);
var
  Html: string;
  P, CloseP: Integer;
begin
  FTitleLabel.Caption := '🚀 What''s New in GOverlay ' + AVersion;

  // Strip <img> tags to avoid UI freeze when TIpHtmlPanel tries to fetch
  // HTTPS images from GitHub. The HTML formatting (bold, headers, lists,
  // links) is fully preserved.
  Html := AText;
  P := Pos('<img', Html);
  while P > 0 do
  begin
    CloseP := Pos('>', Html, P);
    if CloseP > 0 then
      Delete(Html, P, CloseP - P + 1)
    else
      Break;
    P := Pos('<img', Html);
  end;

  FHtmlPanel.SetHtmlFromStr('<html><body style="background-color:#1e2436; color:#e6ebf5; font-family:DejaVu Sans,sans-serif; font-size:13px; padding:8px;">' + Html + '</body></html>');
end;

procedure ShowChangelogPopup(const AVersion, AText: string);
var
  Dlg: TChangelogForm;
begin
  Dlg := TChangelogForm.CreateNew(Application.MainForm);
  if Assigned(Application.MainForm) then
  begin
    Dlg.PopupParent := Application.MainForm;
    Dlg.PopupMode := pmExplicit;
  end;
  Dlg.SetChangelogText(AVersion, AText);
  Dlg.Show;
  Dlg.BringToFront;
end;

end.
