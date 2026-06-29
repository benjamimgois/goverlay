unit changelogunit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Buttons, LCLIntf, LCLType;

type
  TChangelogForm = class(TForm)
  private
    FTitleLabel: TLabel;
    FCloseIconLbl: TLabel;
    FMemo: TMemo;
    FCloseBtn: TBitBtn;
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
  Height := 460;
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

  // Memo for Changelog
  FMemo := TMemo.Create(Self);
  FMemo.Parent := Self;
  FMemo.SetBounds(20, 56, 560, 330);
  FMemo.ReadOnly := True;
  FMemo.ScrollBars := ssVertical;
  FMemo.Color := RGBToColor(30, 36, 54);
  FMemo.Font.Color := RGBToColor(230, 235, 245);
  FMemo.Font.Size := 10;
  FMemo.Font.Name := 'DejaVu Sans';
  FMemo.BorderStyle := bsNone;

  // Apply modern scrollbar QSS
  ApplyModernScrollBarStylesheet(FMemo);

  // Close Button ("Continue")
  FCloseBtn := TBitBtn.Create(Self);
  FCloseBtn.Parent := Self;
  FCloseBtn.SetBounds(460, 404, 120, 36);
  FCloseBtn.Caption := 'Continue';
  FCloseBtn.Kind := bkOK;
  FCloseBtn.OnClick := @CloseBtnClick;
  FCloseBtn.Cursor := crHandPoint;
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
begin
  FTitleLabel.Caption := '🚀 What''s New in GOverlay ' + AVersion;
  FMemo.Text := AText;
  FMemo.SelStart := 0;
  FMemo.SelLength := 0;
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
