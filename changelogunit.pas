unit changelogunit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Buttons,
  LCLIntf, LCLType, Process, md5, StrUtils, FileUtil;

type
  TChangelogBlockType = (cbtHeader, cbtBullet, cbtParagraph, cbtImage);

  TChangelogBlock = class
    BlockType: TChangelogBlockType;
    TextContent: string;
    ImageUrl: string;
    Panel: TPanel;
    TitleLbl: TLabel;
    TextLbl: TLabel;
    StatusLbl: TLabel;
    ImageCtrl: TImage;
  end;

  TChangelogImageThread = class;

  TChangelogForm = class(TForm)
  private
    FHeaderPanel: TPanel;
    FTitleLabel: TLabel;
    FCloseIconLbl: TLabel;
    FScrollBox: TScrollBox;
    FBlocks: TFPList;
    FActiveThreads: TFPList;
    FDragging: Boolean;
    FDragStart: TPoint;
    FClosing: Boolean;
    procedure FormPaint(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure HeaderMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure HeaderMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure HeaderMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CloseBtnClick(Sender: TObject);
    procedure ImageCardPaint(Sender: TObject);
    procedure ClearBlocks;
    procedure Relayout;
    procedure AddHeader(const AText: string);
    procedure AddBullet(const AText: string);
    procedure AddParagraph(const AText: string);
    procedure AddImage(const AUrl: string);
    function GetCacheFilePath(const AUrl: string): string;
    procedure StartImageDownload(ABlock: TChangelogBlock);
    procedure OnImageDownloaded(ABlock: TChangelogBlock; const AFilePath: string);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    destructor Destroy; override;
    procedure SetChangelogText(const AVersion, AText: string);
    property ScrollBox: TScrollBox read FScrollBox;
    property Blocks: TFPList read FBlocks;
  end;

  TChangelogImageThread = class(TThread)
  private
    FOwnerForm: TChangelogForm;
    FBlock: TChangelogBlock;
    FUrl: string;
    FCachePath: string;
    FSuccess: Boolean;
    procedure SyncNotify;
  protected
    procedure Execute; override;
  public
    constructor Create(AForm: TChangelogForm; ABlock: TChangelogBlock; const AUrl, ACachePath: string);
  end;

procedure ShowChangelogPopup(const AVersion, AText: string);

implementation

uses
  themeunit;

const
  FORM_W = 680;
  FORM_H = 520;

function DetectImageExtension(const AFilePath: string): string;
var
  F: File;
  Buf: array[0..11] of Byte;
  BytesRead: Integer;
begin
  Result := '.png';
  if not FileExists(AFilePath) then Exit;
  AssignFile(F, AFilePath);
  {$I-}
  Reset(F, 1);
  {$I+}
  if IOResult <> 0 then Exit;
  try
    BlockRead(F, Buf, SizeOf(Buf), BytesRead);
    if BytesRead >= 4 then
    begin
      // PNG magic: 89 50 4E 47
      if (Buf[0] = $89) and (Buf[1] = $50) and (Buf[2] = $4E) and (Buf[3] = $47) then
        Result := '.png'
      // JPEG magic: FF D8 FF
      else if (Buf[0] = $FF) and (Buf[1] = $D8) and (Buf[2] = $FF) then
        Result := '.jpg'
      // GIF magic: 47 49 46
      else if (Buf[0] = $47) and (Buf[1] = $49) and (Buf[2] = $46) then
        Result := '.gif'
      // BMP magic: 42 4D
      else if (Buf[0] = $42) and (Buf[1] = $4D) then
        Result := '.bmp';
    end;
  finally
    CloseFile(F);
  end;
end;

function CleanMarkdownLinks(const S: string): string;
var
  pOpen, pClose, pParenOpen, pParenClose: Integer;
  LinkText, Res: string;
begin
  Res := S;
  while True do
  begin
    pOpen := Pos('[', Res);
    if pOpen = 0 then Break;
    pClose := PosEx(']', Res, pOpen);
    if pClose = 0 then Break;
    pParenOpen := pClose + 1;
    if (pParenOpen <= Length(Res)) and (Res[pParenOpen] = '(') then
    begin
      pParenClose := PosEx(')', Res, pParenOpen);
      if pParenClose > 0 then
      begin
        LinkText := Copy(Res, pOpen + 1, pClose - pOpen - 1);
        Res := Copy(Res, 1, pOpen - 1) + LinkText + Copy(Res, pParenClose + 1, MaxInt);
        Continue;
      end;
    end;
    Break;
  end;
  Result := Res;
end;

function CleanMarkdownText(const S: string): string;
begin
  Result := CleanMarkdownLinks(S);
  Result := StringReplace(Result, '**', '', [rfReplaceAll]);
  Result := StringReplace(Result, '__', '', [rfReplaceAll]);
  Result := StringReplace(Result, '`', '', [rfReplaceAll]);
end;

function ExtractImgTagSrc(const S: string): string;
var
  pSrc, pStart, pEnd: Integer;
  QuoteChar: Char;
begin
  Result := '';
  pSrc := Pos('src=', LowerCase(S));
  if pSrc = 0 then Exit;
  pStart := pSrc + 4;
  if pStart > Length(S) then Exit;
  QuoteChar := S[pStart];
  if (QuoteChar = '"') or (QuoteChar = '''') then
  begin
    Inc(pStart);
    pEnd := PosEx(QuoteChar, S, pStart);
    if pEnd > pStart then
      Result := Copy(S, pStart, pEnd - pStart);
  end
  else
  begin
    pEnd := PosEx(' ', S, pStart);
    if pEnd = 0 then
      pEnd := PosEx('>', S, pStart);
    if pEnd > pStart then
      Result := Copy(S, pStart, pEnd - pStart);
  end;
end;

function ExtractMarkdownImgUrl(const S: string): string;
var
  pBang, pClose: Integer;
begin
  Result := '';
  pBang := Pos('![', S);
  if pBang = 0 then Exit;
  pClose := PosEx('](', S, pBang);
  if pClose = 0 then Exit;
  pBang := pClose + 2;
  pClose := PosEx(')', S, pBang);
  if pClose > pBang then
    Result := Copy(S, pBang, pClose - pBang);
end;

{ TChangelogImageThread }

constructor TChangelogImageThread.Create(AForm: TChangelogForm; ABlock: TChangelogBlock; const AUrl, ACachePath: string);
begin
  inherited Create(True);
  FOwnerForm := AForm;
  FBlock := ABlock;
  FUrl := AUrl;
  FCachePath := ACachePath;
  FSuccess := False;
  FreeOnTerminate := True;
end;

procedure TChangelogImageThread.SyncNotify;
begin
  if Assigned(FOwnerForm) and (not FOwnerForm.FClosing) then
  begin
    FOwnerForm.FActiveThreads.Remove(Self);
    if FSuccess then
      FOwnerForm.OnImageDownloaded(FBlock, FCachePath);
  end;
end;

procedure TChangelogImageThread.Execute;
var
  Proc: TProcess;
  TempFile, ActualExt, FinalPath: string;
begin
  FSuccess := False;
  TempFile := FCachePath + '.tmp_' + IntToStr(GetProcessID) + '_' + IntToStr(PtrUInt(Self));
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := 'curl';
    Proc.Parameters.Add('-s');
    Proc.Parameters.Add('-L');
    Proc.Parameters.Add('--connect-timeout');
    Proc.Parameters.Add('5');
    Proc.Parameters.Add('--max-time');
    Proc.Parameters.Add('15');
    Proc.Parameters.Add('-o');
    Proc.Parameters.Add(TempFile);
    Proc.Parameters.Add(FUrl);
    Proc.Options := [poWaitOnExit, poNoConsole];
    try
      Proc.Execute;
    except
    end;
  finally
    Proc.Free;
  end;

  if FileExists(TempFile) and (FileSize(TempFile) > 0) then
  begin
    ActualExt := DetectImageExtension(TempFile);
    FinalPath := ChangeFileExt(FCachePath, ActualExt);
    if FileExists(FinalPath) then
      DeleteFile(FinalPath);
    if RenameFile(TempFile, FinalPath) then
    begin
      FCachePath := FinalPath;
      FSuccess := True;
    end;
  end;

  if FileExists(TempFile) then
    DeleteFile(TempFile);

  if not Terminated then
    Synchronize(@SyncNotify);
end;

{ TChangelogForm }

constructor TChangelogForm.CreateNew(AOwner: TComponent; Dummy: Integer = 0);
begin
  inherited CreateNew(AOwner, Dummy);
  Caption := 'What''s New in Goverlay';
  Width := FORM_W;
  Height := FORM_H;
  Position := poOwnerFormCenter;
  BorderStyle := bsNone;
  FormStyle := fsStayOnTop;
  PopupMode := pmAuto;
  Color := RGBToColor(22, 26, 40); // Goverlay background navy blue
  FClosing := False;
  FBlocks := TFPList.Create;
  FActiveThreads := TFPList.Create;

  OnPaint := @FormPaint;
  OnClose := @FormClose;
  OnDestroy := @FormDestroy;
  OnMouseDown := @HeaderMouseDown;
  OnMouseMove := @HeaderMouseMove;
  OnMouseUp := @HeaderMouseUp;

  // Header Panel
  FHeaderPanel := TPanel.Create(Self);
  FHeaderPanel.Parent := Self;
  FHeaderPanel.SetBounds(0, 0, Width, 52);
  FHeaderPanel.BevelOuter := bvNone;
  FHeaderPanel.BevelInner := bvNone;
  FHeaderPanel.Color := Color;
  FHeaderPanel.OnMouseDown := @HeaderMouseDown;
  FHeaderPanel.OnMouseMove := @HeaderMouseMove;
  FHeaderPanel.OnMouseUp := @HeaderMouseUp;

  // Title Label
  FTitleLabel := TLabel.Create(Self);
  FTitleLabel.Parent := FHeaderPanel;
  FTitleLabel.SetBounds(20, 14, Width - 60, 26);
  FTitleLabel.Font.Size := 12;
  FTitleLabel.Font.Style := [fsBold];
  FTitleLabel.Font.Color := clWhite;
  FTitleLabel.Caption := '🚀 What''s New in Goverlay';
  FTitleLabel.OnMouseDown := @HeaderMouseDown;
  FTitleLabel.OnMouseMove := @HeaderMouseMove;
  FTitleLabel.OnMouseUp := @HeaderMouseUp;

  // Close "X" button
  FCloseIconLbl := TLabel.Create(Self);
  FCloseIconLbl.Parent := FHeaderPanel;
  FCloseIconLbl.SetBounds(Width - 36, 14, 24, 24);
  FCloseIconLbl.Font.Size := 12;
  FCloseIconLbl.Font.Style := [fsBold];
  FCloseIconLbl.Font.Color := RGBToColor(160, 170, 190);
  FCloseIconLbl.Caption := '✕';
  FCloseIconLbl.Alignment := taCenter;
  FCloseIconLbl.Cursor := crHandPoint;
  FCloseIconLbl.OnClick := @CloseBtnClick;

  // ScrollBox for Rich Changelog
  FScrollBox := TScrollBox.Create(Self);
  FScrollBox.Parent := Self;
  FScrollBox.SetBounds(16, 52, Width - 32, Height - 52 - 16);
  FScrollBox.BorderStyle := bsNone;
  FScrollBox.Color := Color;
  FScrollBox.AutoScroll := True;

  ApplyModernScrollBarStylesheet(FScrollBox);
end;

destructor TChangelogForm.Destroy;
begin
  inherited Destroy;
end;

procedure TChangelogForm.FormDestroy(Sender: TObject);
var
  i: Integer;
  Th: TChangelogImageThread;
begin
  FClosing := True;
  for i := 0 to FActiveThreads.Count - 1 do
  begin
    Th := TChangelogImageThread(FActiveThreads[i]);
    Th.FOwnerForm := nil;
  end;
  FActiveThreads.Clear;
  FreeAndNil(FActiveThreads);

  ClearBlocks;
  FreeAndNil(FBlocks);
end;

procedure TChangelogForm.FormPaint(Sender: TObject);
begin
  Canvas.Brush.Style := bsClear;
  Canvas.Pen.Color := RGBToColor(45, 55, 80);
  Canvas.Pen.Width := 2;
  Canvas.Rectangle(0, 0, Width, Height);
end;

procedure TChangelogForm.ImageCardPaint(Sender: TObject);
var
  P: TPanel;
begin
  if not (Sender is TPanel) then Exit;
  P := TPanel(Sender);
  P.Canvas.Brush.Style := bsClear;
  P.Canvas.Pen.Color := RGBToColor(42, 50, 72);
  P.Canvas.Pen.Width := 1;
  P.Canvas.Rectangle(0, 0, P.Width, P.Height);
end;

procedure TChangelogForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  FClosing := True;
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

procedure TChangelogForm.ClearBlocks;
var
  i: Integer;
  Block: TChangelogBlock;
begin
  if not Assigned(FBlocks) then Exit;
  for i := 0 to FBlocks.Count - 1 do
  begin
    Block := TChangelogBlock(FBlocks[i]);
    if Assigned(Block.Panel) then
      Block.Panel.Free;
    Block.Free;
  end;
  FBlocks.Clear;
end;

procedure TChangelogForm.AddHeader(const AText: string);
var
  Block: TChangelogBlock;
begin
  Block := TChangelogBlock.Create;
  Block.BlockType := cbtHeader;
  Block.TextContent := AText;

  Block.Panel := TPanel.Create(FScrollBox);
  Block.Panel.Parent := FScrollBox;
  Block.Panel.BevelOuter := bvNone;
  Block.Panel.Color := Color;

  Block.TitleLbl := TLabel.Create(Block.Panel);
  Block.TitleLbl.Parent := Block.Panel;
  Block.TitleLbl.Left := 0;
  Block.TitleLbl.Top := 6;
  Block.TitleLbl.Font.Size := 11;
  Block.TitleLbl.Font.Style := [fsBold];
  Block.TitleLbl.Font.Color := RGBToColor(120, 180, 255);
  Block.TitleLbl.WordWrap := True;
  Block.TitleLbl.AutoSize := True;
  Block.TitleLbl.Caption := AText;

  Block.Panel.Height := Block.TitleLbl.Height + 12;
  FBlocks.Add(Block);
end;

procedure TChangelogForm.AddBullet(const AText: string);
var
  Block: TChangelogBlock;
  Dot: TLabel;
begin
  Block := TChangelogBlock.Create;
  Block.BlockType := cbtBullet;
  Block.TextContent := AText;

  Block.Panel := TPanel.Create(FScrollBox);
  Block.Panel.Parent := FScrollBox;
  Block.Panel.BevelOuter := bvNone;
  Block.Panel.Color := Color;

  Dot := TLabel.Create(Block.Panel);
  Dot.Parent := Block.Panel;
  Dot.Left := 4;
  Dot.Top := 2;
  Dot.Font.Size := 10;
  Dot.Font.Color := RGBToColor(90, 165, 250);
  Dot.Caption := '•';

  Block.TextLbl := TLabel.Create(Block.Panel);
  Block.TextLbl.Parent := Block.Panel;
  Block.TextLbl.Left := 20;
  Block.TextLbl.Top := 2;
  Block.TextLbl.Font.Size := 10;
  Block.TextLbl.Font.Color := RGBToColor(225, 232, 245);
  Block.TextLbl.WordWrap := True;
  Block.TextLbl.AutoSize := True;
  Block.TextLbl.Caption := AText;

  if Block.TextLbl.Height < 18 then
    Block.Panel.Height := 20
  else
    Block.Panel.Height := Block.TextLbl.Height + 4;

  FBlocks.Add(Block);
end;

procedure TChangelogForm.AddParagraph(const AText: string);
var
  Block: TChangelogBlock;
begin
  Block := TChangelogBlock.Create;
  Block.BlockType := cbtParagraph;
  Block.TextContent := AText;

  Block.Panel := TPanel.Create(FScrollBox);
  Block.Panel.Parent := FScrollBox;
  Block.Panel.BevelOuter := bvNone;
  Block.Panel.Color := Color;

  Block.TextLbl := TLabel.Create(Block.Panel);
  Block.TextLbl.Parent := Block.Panel;
  Block.TextLbl.Left := 4;
  Block.TextLbl.Top := 2;
  Block.TextLbl.Font.Size := 10;
  Block.TextLbl.Font.Color := RGBToColor(200, 210, 225);
  Block.TextLbl.WordWrap := True;
  Block.TextLbl.AutoSize := True;
  Block.TextLbl.Caption := AText;

  Block.Panel.Height := Block.TextLbl.Height + 4;
  FBlocks.Add(Block);
end;

procedure TChangelogForm.AddImage(const AUrl: string);
var
  Block: TChangelogBlock;
begin
  Block := TChangelogBlock.Create;
  Block.BlockType := cbtImage;
  Block.ImageUrl := AUrl;

  Block.Panel := TPanel.Create(FScrollBox);
  Block.Panel.Parent := FScrollBox;
  Block.Panel.BevelOuter := bvNone;
  Block.Panel.Color := RGBToColor(28, 33, 48);
  Block.Panel.Height := 100;
  Block.Panel.OnPaint := @ImageCardPaint;

  Block.StatusLbl := TLabel.Create(Block.Panel);
  Block.StatusLbl.Parent := Block.Panel;
  Block.StatusLbl.Align := alClient;
  Block.StatusLbl.Alignment := taCenter;
  Block.StatusLbl.Layout := tlCenter;
  Block.StatusLbl.Font.Size := 9;
  Block.StatusLbl.Font.Color := RGBToColor(140, 155, 180);
  Block.StatusLbl.Caption := '⏳ Loading image...';

  Block.ImageCtrl := TImage.Create(Block.Panel);
  Block.ImageCtrl.Parent := Block.Panel;
  Block.ImageCtrl.Visible := False;
  Block.ImageCtrl.AntialiasingMode := amOn;
  Block.ImageCtrl.Proportional := True;
  Block.ImageCtrl.Stretch := True;

  FBlocks.Add(Block);
  StartImageDownload(Block);
end;

function TChangelogForm.GetCacheFilePath(const AUrl: string): string;
var
  CacheDir, HashStr, BasePath: string;
  Exts: array[0..3] of string = ('.png', '.jpg', '.jpeg', '.gif');
  i: Integer;
begin
  CacheDir := GetEnvironmentVariable('XDG_CACHE_HOME');
  if CacheDir = '' then
    CacheDir := GetEnvironmentVariable('HOME') + '/.cache';
  CacheDir := IncludeTrailingPathDelimiter(CacheDir) + 'goverlay' + DirectorySeparator + 'changelog';
  if not DirectoryExists(CacheDir) then
    ForceDirectories(CacheDir);

  HashStr := MD5Print(MD5String(AUrl));
  BasePath := IncludeTrailingPathDelimiter(CacheDir) + HashStr;

  for i := 0 to High(Exts) do
  begin
    if FileExists(BasePath + Exts[i]) and (FileSize(BasePath + Exts[i]) > 0) then
      Exit(BasePath + Exts[i]);
  end;

  Result := BasePath + '.png';
end;

procedure TChangelogForm.StartImageDownload(ABlock: TChangelogBlock);
var
  CachePath: string;
  Th: TChangelogImageThread;
begin
  CachePath := GetCacheFilePath(ABlock.ImageUrl);
  if FileExists(CachePath) and (FileSize(CachePath) > 0) then
  begin
    OnImageDownloaded(ABlock, CachePath);
    Exit;
  end;

  Th := TChangelogImageThread.Create(Self, ABlock, ABlock.ImageUrl, CachePath);
  FActiveThreads.Add(Th);
  Th.Start;
end;

procedure TChangelogForm.OnImageDownloaded(ABlock: TChangelogBlock; const AFilePath: string);
var
  OrigW, OrigH, MaxW, DispW, DispH: Integer;
begin
  if FClosing or (not Assigned(ABlock)) or (not Assigned(ABlock.Panel)) then Exit;

  try
    ABlock.ImageCtrl.Picture.LoadFromFile(AFilePath);
    OrigW := ABlock.ImageCtrl.Picture.Width;
    OrigH := ABlock.ImageCtrl.Picture.Height;

    if (OrigW > 0) and (OrigH > 0) then
    begin
      MaxW := FScrollBox.ClientWidth - 36;
      if MaxW < 300 then MaxW := FORM_W - 80;

      if OrigW > MaxW then
      begin
        DispW := MaxW;
        DispH := Round(OrigH * (MaxW / OrigW));
      end
      else
      begin
        DispW := OrigW;
        DispH := OrigH;
      end;

      ABlock.ImageCtrl.SetBounds((ABlock.Panel.Width - DispW) div 2, 8, DispW, DispH);
      ABlock.Panel.Height := DispH + 16;
      ABlock.ImageCtrl.Visible := True;
      if Assigned(ABlock.StatusLbl) then
        ABlock.StatusLbl.Visible := False;
    end
    else
    begin
      ABlock.Panel.Visible := False;
    end;
  except
    on E: Exception do
    begin
      ABlock.Panel.Visible := False;
    end;
  end;

  Relayout;
end;

procedure TChangelogForm.Relayout;
var
  i, CurY, ContentW: Integer;
  Block: TChangelogBlock;
begin
  CurY := 10;
  ContentW := FScrollBox.ClientWidth - 24;
  if ContentW < 400 then ContentW := FORM_W - 60;

  for i := 0 to FBlocks.Count - 1 do
  begin
    Block := TChangelogBlock(FBlocks[i]);
    if not Block.Panel.Visible then Continue;

    Block.Panel.Left := 4;
    Block.Panel.Top := CurY;
    Block.Panel.Width := ContentW;

    case Block.BlockType of
      cbtHeader:
        begin
          if Assigned(Block.TitleLbl) then
          begin
            Block.TitleLbl.Width := ContentW;
            Block.Panel.Height := Block.TitleLbl.Height + 10;
          end;
        end;
      cbtBullet:
        begin
          if Assigned(Block.TextLbl) then
          begin
            Block.TextLbl.Width := ContentW - 24;
            if Block.TextLbl.Height < 18 then
              Block.Panel.Height := 20
            else
              Block.Panel.Height := Block.TextLbl.Height + 4;
          end;
        end;
      cbtParagraph:
        begin
          if Assigned(Block.TextLbl) then
          begin
            Block.TextLbl.Width := ContentW - 8;
            Block.Panel.Height := Block.TextLbl.Height + 4;
          end;
        end;
      cbtImage:
        begin
          if Assigned(Block.ImageCtrl) and Block.ImageCtrl.Visible then
          begin
            Block.ImageCtrl.Left := (ContentW - Block.ImageCtrl.Width) div 2;
            if Block.ImageCtrl.Left < 0 then Block.ImageCtrl.Left := 0;
          end;
        end;
    end;

    CurY := CurY + Block.Panel.Height + 6;
  end;
end;

procedure TChangelogForm.SetChangelogText(const AVersion, AText: string);
var
  Lines: TStringList;
  i: Integer;
  Line, Trimmed, ImgUrl, CurHeader: string;
begin
  FTitleLabel.Caption := '🚀 What''s New in Goverlay ' + AVersion;
  ClearBlocks;

  if Trim(AText) = '' then
  begin
    AddParagraph('No release notes available for this version.');
    Relayout;
    Exit;
  end;

  Lines := TStringList.Create;
  try
    Lines.Text := AText;
    for i := 0 to Lines.Count - 1 do
    begin
      Line := Lines[i];
      Trimmed := Trim(Line);
      if Trimmed = '' then Continue;

      // Detect HTML image tag <img ... src="..." /> or Markdown ![alt](url)
      ImgUrl := '';
      if Pos('<img', LowerCase(Trimmed)) > 0 then
        ImgUrl := ExtractImgTagSrc(Trimmed)
      else if (Pos('![', Trimmed) > 0) and (Pos('](', Trimmed) > 0) then
        ImgUrl := ExtractMarkdownImgUrl(Trimmed);

      if ImgUrl <> '' then
      begin
        AddImage(ImgUrl);
        Continue;
      end;

      // Detect Markdown headers: ###, ##, #
      if (Copy(Trimmed, 1, 3) = '###') or (Copy(Trimmed, 1, 2) = '##') or (Copy(Trimmed, 1, 1) = '#') then
      begin
        CurHeader := Trimmed;
        while (Length(CurHeader) > 0) and (CurHeader[1] = '#') do
          Delete(CurHeader, 1, 1);
        AddHeader(CleanMarkdownText(Trim(CurHeader)));
        Continue;
      end;

      // Detect bullet points: - or *
      if (Copy(Trimmed, 1, 2) = '- ') or (Copy(Trimmed, 1, 2) = '* ') then
      begin
        AddBullet(CleanMarkdownText(Trim(Copy(Trimmed, 3, MaxInt))));
        Continue;
      end;

      // Detect indented bullet points (e.g. "  - ")
      if (Pos('- ', Trimmed) = 1) or (Pos('* ', Trimmed) = 1) then
      begin
        AddBullet(CleanMarkdownText(Trim(Copy(Trimmed, 3, MaxInt))));
        Continue;
      end;

      // Regular paragraph
      AddParagraph(CleanMarkdownText(Trimmed));
    end;
  finally
    Lines.Free;
  end;

  Relayout;
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
