unit blacklistUnit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  ExtCtrls, LCLType, themeunit, goverlay_strings, overlay_config, configmanager;

type

  { TblacklistForm }

  TblacklistForm = class(TForm)
    blackListBox: TListBox;
    blacklistEdit: TEdit;
    iconsImageList: TImageList;
    Image1: TImage;
    insertblacklistBitBtn: TBitBtn;
    blacklistLabel: TLabel;
    removeblacklistBitBtn: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure insertblacklistBitBtnClick(Sender: TObject);
    procedure removeblacklistBitBtnClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure blackListBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
    procedure blacklistEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure blackListBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure blackListBoxSelectionChange(Sender: TObject; User: Boolean);
    procedure CloseBtnClick(Sender: TObject);
  private
    FSubtitleLabel: TLabel;
    FCountLabel: TLabel;
    FCloseBtn: TBitBtn;
    FUiInitialized: Boolean;
    procedure BuildModernUI;
    procedure UpdateCount;
  public

  end;

var
  // ============================================================================
  // FORM INSTANCE
  // ============================================================================
  blacklistForm: TblacklistForm;        // Blacklist management form

  // ============================================================================
  // BLACKLIST CONFIGURATION
  // ============================================================================
  BlacklistFile: string;                // Path to blacklist configuration file
  FileLines: TStringList;               // Blacklist entries buffer
  SelectedIndex: Integer;               // Currently selected blacklist item index

implementation

{$R *.lfm}

{ TblacklistForm }

procedure TblacklistForm.BuildModernUI;
begin
  if FUiInitialized then
    Exit;

  ClientWidth := 460;
  ClientHeight := 520;
  Position := poMainFormCenter;
  KeyPreview := True;
  OnKeyDown := @FormKeyDown;

  Image1.Visible := False;

  blacklistLabel.Caption := 'Blacklisted Applications';
  blacklistLabel.Font.Size := 12;
  blacklistLabel.Font.Style := [fsBold];
  blacklistLabel.Top := 16;
  blacklistLabel.Left := 20;

  if FSubtitleLabel = nil then
  begin
    FSubtitleLabel := TLabel.Create(Self);
    FSubtitleLabel.Parent := Self;
  end;
  FSubtitleLabel.Top := 42;
  FSubtitleLabel.Left := 20;
  FSubtitleLabel.Caption := 'Applications ignored by MangoHud system-wide:';
  FSubtitleLabel.Font.Size := 9;

  blacklistEdit.Top := 72;
  blacklistEdit.Left := 20;
  blacklistEdit.Width := ClientWidth - 40 - 84;
  blacklistEdit.Height := 34;
  blacklistEdit.TextHint := 'Enter process name (e.g. discord)...';
  blacklistEdit.OnKeyDown := @blacklistEditKeyDown;

  insertblacklistBitBtn.Top := 72;
  insertblacklistBitBtn.Left := blacklistEdit.Left + blacklistEdit.Width + 8;
  insertblacklistBitBtn.Width := 76;
  insertblacklistBitBtn.Height := 34;
  insertblacklistBitBtn.Caption := 'Add';
  insertblacklistBitBtn.Glyph.Clear;
  insertblacklistBitBtn.ImageIndex := -1;

  blackListBox.Top := 118;
  blackListBox.Left := 20;
  blackListBox.Width := ClientWidth - 40;
  blackListBox.Height := ClientHeight - 118 - 60;
  blackListBox.Style := lbOwnerDrawFixed;
  blackListBox.ItemHeight := 32;
  blackListBox.OnDrawItem := @blackListBoxDrawItem;
  blackListBox.OnKeyDown := @blackListBoxKeyDown;
  blackListBox.OnSelectionChange := @blackListBoxSelectionChange;

  if FCountLabel = nil then
  begin
    FCountLabel := TLabel.Create(Self);
    FCountLabel.Parent := Self;
  end;
  FCountLabel.Top := ClientHeight - 44;
  FCountLabel.Left := 20;
  FCountLabel.Font.Size := 9;

  removeblacklistBitBtn.Top := ClientHeight - 46;
  removeblacklistBitBtn.Left := ClientWidth - 20 - 76 - 8 - 140;
  removeblacklistBitBtn.Width := 140;
  removeblacklistBitBtn.Height := 34;
  removeblacklistBitBtn.Caption := 'Remove Selected';
  removeblacklistBitBtn.Glyph.Clear;
  removeblacklistBitBtn.ImageIndex := -1;

  if FCloseBtn = nil then
  begin
    FCloseBtn := TBitBtn.Create(Self);
    FCloseBtn.Parent := Self;
    FCloseBtn.OnClick := @CloseBtnClick;
  end;
  FCloseBtn.Top := ClientHeight - 46;
  FCloseBtn.Left := ClientWidth - 20 - 76;
  FCloseBtn.Width := 76;
  FCloseBtn.Height := 34;
  FCloseBtn.Caption := 'Close';

  FUiInitialized := True;
end;

procedure TblacklistForm.UpdateCount;
begin
  if FCountLabel <> nil then
    FCountLabel.Caption := Format('%d applications blacklisted', [blackListBox.Items.Count]);
  if removeblacklistBitBtn <> nil then
    removeblacklistBitBtn.Enabled := blackListBox.ItemIndex >= 0;
end;

procedure TblacklistForm.blackListBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  LB: TListBox;
  BgColor, SelColor, TextColor, SepColor, DotColor: TColor;
  CenterY, TextY: Integer;
begin
  LB := Control as TListBox;
  if (Index < 0) or (Index >= LB.Items.Count) then
    Exit;

  if CurrentTheme = tmDark then
  begin
    BgColor := LB.Color;
    SelColor := RGBToColor(42, 54, 82);
    TextColor := clWhite;
    SepColor := RGBToColor(56, 48, 42);
    DotColor := RGBToColor(48, 190, 240);
  end
  else
  begin
    BgColor := LB.Color;
    SelColor := RGBToColor(220, 230, 248);
    TextColor := RGBToColor(32, 38, 46);
    SepColor := RGBToColor(226, 226, 226);
    DotColor := RGBToColor(0, 120, 215);
  end;

  if odSelected in State then
    LB.Canvas.Brush.Color := SelColor
  else
    LB.Canvas.Brush.Color := BgColor;
  LB.Canvas.FillRect(ARect);

  LB.Canvas.Pen.Color := SepColor;
  LB.Canvas.Line(ARect.Left, ARect.Bottom - 1, ARect.Right, ARect.Bottom - 1);

  CenterY := (ARect.Top + ARect.Bottom) div 2;
  LB.Canvas.Brush.Color := DotColor;
  LB.Canvas.Pen.Color := DotColor;
  LB.Canvas.Ellipse(ARect.Left + 12 - 3, CenterY - 3, ARect.Left + 12 + 3, CenterY + 3);

  LB.Canvas.Brush.Style := bsClear;
  LB.Canvas.Font.Assign(LB.Font);
  LB.Canvas.Font.Color := TextColor;
  if odSelected in State then
    LB.Canvas.Font.Style := [fsBold]
  else
    LB.Canvas.Font.Style := [];
  TextY := ARect.Top + ((ARect.Bottom - ARect.Top) - LB.Canvas.TextHeight('Ag')) div 2;
  LB.Canvas.TextOut(ARect.Left + 26, TextY, LB.Items[Index]);
end;

procedure TblacklistForm.blacklistEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    insertblacklistBitBtnClick(Sender);
  end;
end;

procedure TblacklistForm.blackListBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_DELETE) or (Key = VK_BACK) then
  begin
    Key := 0;
    removeblacklistBitBtnClick(Sender);
  end;
end;

procedure TblacklistForm.blackListBoxSelectionChange(Sender: TObject; User: Boolean);
begin
  UpdateCount;
end;

procedure TblacklistForm.CloseBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TblacklistForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TblacklistForm.insertblacklistBitBtnClick(Sender: TObject);
begin
  BlacklistFile := TConfigManager.GetBlacklistFile;

    // check if field is empty
  if Trim(blacklistedit.Text) = '' then
  begin
    ShowMessage(rsBlacklistNameRequired);
    Exit;
  end;

  // check for double values
  if blackListBox.Items.IndexOf(blacklistedit.Text) = -1 then
  begin
    blackListBox.Items.Add(blacklistedit.Text); // add to listbox
  end
  else
  begin
    ShowMessage(rsBlacklistDuplicate);
    Exit;
  end;

  // Save new file
  FileLines := TStringList.Create;
  try
    FileLines.Assign(blackListBox.Items);
    ForceDirectories(ExtractFilePath(BlacklistFile)); // make sure directory exists
    FileLines.SaveToFile(BlacklistFile); // save file
    SyncBlacklistToMangoHud(FileLines);
  finally
    FileLines.Free;
  end;

  // clean edit field
  blacklistedit.Clear;

  UpdateCount;
end;

procedure TblacklistForm.removeblacklistBitBtnClick(Sender: TObject);
begin
  BlacklistFile := TConfigManager.GetBlacklistFile;
  SelectedIndex := blackListBox.ItemIndex;

   // check if any item is selected
   if SelectedIndex = -1 then
   begin
     ShowMessage(rsBlacklistSelectToRemove);
     Exit;
   end;

   // Remove selected item
   blackListBox.Items.Delete(SelectedIndex);

   // save new list
   FileLines := TStringList.Create;
   try
     FileLines.Assign(blackListBox.Items);
     FileLines.SaveToFile(BlacklistFile);
     SyncBlacklistToMangoHud(FileLines);
   finally
     FileLines.Free;
   end;

   UpdateCount;
end;

procedure TblacklistForm.FormShow(Sender: TObject);
const
  NewDarkBg = $00281A16;
begin
  insertblacklistBitBtn.ModalResult := mrNone;
  removeblacklistBitBtn.ModalResult := mrNone;

  BuildModernUI;

  // Apply current theme
  ApplyTheme(Self, CurrentTheme);

  if CurrentTheme = tmDark then
  begin
    Self.Color := NewDarkBg;
    blacklistLabel.Font.Color := clWhite;
    FSubtitleLabel.Font.Color := $00998877;
    FCountLabel.Font.Color := $00998877;
    blackListBox.Color := $00201612;
    blackListBox.Font.Color := clWhite;
    blacklistEdit.Color := $002E2620;
    blacklistEdit.Font.Color := clWhite;
    StyleBitBtnTheme(insertblacklistBitBtn, clWhite, $003C2E24);
    StyleBitBtnTheme(removeblacklistBitBtn, clWhite, $003C2E24);
    StyleBitBtnTheme(FCloseBtn, clWhite, $003C2E24);
  end
  else
  begin
    Self.Color := $00F6F6F6;
    blacklistLabel.Font.Color := $0020262E;
    FSubtitleLabel.Font.Color := $00666666;
    FCountLabel.Font.Color := $00666666;
    blackListBox.Color := clWhite;
    blackListBox.Font.Color := $0020262E;
    blacklistEdit.Color := clWhite;
    blacklistEdit.Font.Color := clBlack;
    StyleBitBtnTheme(insertblacklistBitBtn, clBlack, clWhite);
    StyleBitBtnTheme(removeblacklistBitBtn, clBlack, clWhite);
    StyleBitBtnTheme(FCloseBtn, clBlack, clWhite);
  end;

  BlacklistFile := TConfigManager.GetBlacklistFile;
  FileLines := TStringList.Create;
  try
    if FileExists(BlacklistFile) then
    begin
      // If file exists, load file in listbox
      FileLines.LoadFromFile(BlacklistFile);
    end
    else
    begin
      // if file doesnt exist, create a new one
      ForceDirectories(ExtractFilePath(BlacklistFile)); // Ensure directory exists
      FileLines.Add('zenity');
      FileLines.Add('protonplus');
      FileLines.Add('lsfg-vk-ui');
      FileLines.Add('bazzar');
      FileLines.Add('gnome-calculator');
      FileLines.Add('pamac-manager');
      FileLines.Add('lact');
      FileLines.Add('ghb');
      FileLines.Add('bitwig-studio');
      FileLines.Add('ptyxis');
      FileLines.Add('yumex');
      FileLines.SaveToFile(BlacklistFile);
    end;

    // Add items to listbox
    blackListBox.Items.Assign(FileLines);
  finally
    FileLines.Free;
  end;

  UpdateCount;
  blackListBox.Invalidate;
end;


end.
