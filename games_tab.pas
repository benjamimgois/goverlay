unit games_tab;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, Forms, Controls, Graphics, Dialogs, ExtCtrls, Math,
  unix, BaseUnix, StdCtrls, Spin, ComCtrls, Buttons, ActnList, Menus,
  LCLtype, Clipbrd, LCLIntf, IniFiles, FileUtil, StrUtils, Types, fpjson,
  jsonparser, themeunit, systemdetector, constants, bgmod_resources, hintsunit,
  configmanager, IntfGraphics, Grids, overlayunit, overlay_config, apputils, overlay_utils;

const
  CARD_W      = 150;
  CARD_H      = 215;
  CARD_IMG_H  = 215;
  GRAD_H      = 55;
  CARD_MARGIN = 8;
  SEL_EXPAND  = 3;

type
  TNonSteamCoverItem = record
    GameName:  string;
    CachePath: string;
    CardIndex: Integer;
  end;

  TCoverDownloadThread = class(TThread)
  private
    FAppIDs:   TStringList;
    FImages:   TList;
    FCacheDir: string;
    FForm:     Tgoverlayform;
    FCurrentImage: TImage;
    FCurrentPath:  string;
    procedure DoUpdateImage;
  protected
    procedure Execute; override;
  public
    constructor Create(AAppIDs: TStringList; AImages: TList;
                       const ACacheDir: string; AForm: Tgoverlayform);
    destructor Destroy; override;
  end;

  TNonSteamCoverThread = class(TThread)
  private
    FItems:     array of TNonSteamCoverItem;
    FForm:      Tgoverlayform;
    FCurrentCardIdx: Integer;
    FCurrentPath:    string;
    FCurrentIsFallback: Boolean;
    procedure DoUpdateImage;
  protected
    procedure Execute; override;
  public
    constructor Create(const AItems: array of TNonSteamCoverItem;
                       AForm: Tgoverlayform);
  end;

  TGamesTabHelper = class
  private
    FForm: Tgoverlayform;
  public
    constructor Create(AForm: Tgoverlayform);
    
    procedure InitGamesTab;
    procedure LoadSteamGames;
    procedure LoadNonSteamFolders(var ACardIndex: Integer; const ACardsPerRow, ARowMargin: Integer);
    procedure CoverThreadTerminated(Sender: TObject);
    procedure DrawCardRibbon(Bmp: TBitmap; BadgeMask: Integer);
    function  SearchSteamStoreGame(const AGameName: string; out AAppId: string): Boolean;
    function  DownloadSteamCover(const AAppId, ACachePath: string): Boolean;
    function  SearchWebCover(const AGameName, ACachePath: string): Boolean;
    procedure RunFGModUninstallCommands(const ATargetDir, AGameName: string);
    procedure RefreshGameCardsAsync(Data: PtrInt);
    procedure LoadGlobalThumb;
    procedure ShowGameThumb(ACard: TPanel);
    procedure ApplyCardBrightness(ACard: TPanel; BrightFactor: Integer);
    procedure ApplyAllCardsDim;
    procedure GameCardClick(Sender: TObject);
    procedure GameCardUninstallClick(Sender: TObject);
    procedure GameCardMouseEnter(Sender: TObject);
    procedure GameCardMouseLeave(Sender: TObject);
    procedure GameCardMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ActionPanelPaint(Sender: TObject);
    procedure ActionPanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ActionPanelClick(Sender: TObject);
    function  GetCardPanel(AControl: TControl): TPanel;
    procedure CreateActionPanel(CardPanel: TPanel);
    procedure GameHoverFolderClick(Sender: TObject);
    procedure GameHoverPrefixClick(Sender: TObject);
    procedure GameHoverUninstallClick(Sender: TObject);
    procedure GameCardOpenFolderClick(Sender: TObject);
    procedure GameCardOpenPrefixClick(Sender: TObject);
    procedure AddNonSteamFolderClick(Sender: TObject);
    procedure RemoveFolderMenuItemClick(Sender: TObject);
    procedure ShowRemoveFoldersMenu(Sender: TObject; X, Y: Integer);
    procedure GamesScrollBoxResize(Sender: TObject);
    procedure GamesEmptySpaceClick(Sender: TObject);
    procedure RefreshGameCards;
    procedure ReflowGamesGrid;
  end;

procedure ProcessCoverBitmap(Bmp: TBitmap; GradH: Integer);
procedure GenerateFallbackCover(const APath: string; AForm: Tgoverlayform);

implementation

constructor TGamesTabHelper.Create(AForm: Tgoverlayform);
begin
  FForm := AForm;
end;


constructor TCoverDownloadThread.Create(AAppIDs: TStringList; AImages: TList;
  const ACacheDir: string; AForm: Tgoverlayform);
begin
  inherited Create(True);
  FAppIDs   := AAppIDs;
  FImages   := AImages;
  FCacheDir := ACacheDir;
  FForm     := AForm;
  FreeOnTerminate := True;
  OnTerminate := @FForm.CoverThreadTerminated;
end;



destructor TCoverDownloadThread.Destroy;
begin
  FAppIDs.Free;
  FImages.Free;
  inherited;
end;



procedure TCoverDownloadThread.DoUpdateImage;
var
  ScaledBmp: TBitmap;
  CardPanel: TPanel;
  CardIdx: Integer;
begin
  if not Assigned(FForm) or (FForm.FCoverThread <> Self) then Exit;
  if not Assigned(FCurrentImage) or not FileExists(FCurrentPath) then Exit;
  // Safety: verify the image's parent panel is still in the active card list
  if not Assigned(FCurrentImage.Parent) or not (FCurrentImage.Parent is TPanel) then Exit;
  if Assigned(FForm) and Assigned(FForm.FCardPanels) and
     (FForm.FCardPanels.IndexOf(FCurrentImage.Parent) < 0) then Exit;
  try
    FCurrentImage.Picture.LoadFromFile(FCurrentPath);
    if (FCurrentImage.Picture.Graphic = nil) or
       (FCurrentImage.Picture.Graphic.Width = 0) then Exit;
    ScaledBmp := TBitmap.Create;
    try
      ScaledBmp.SetSize(CARD_W, CARD_H);
      ScaledBmp.Canvas.StretchDraw(
        Rect(0, 0, CARD_W, CARD_H), FCurrentImage.Picture.Graphic);
      ProcessCoverBitmap(ScaledBmp, GRAD_H);
      FCurrentImage.Picture.Bitmap.Assign(ScaledBmp);
      // Update FOrigCovers so hover brightness uses the processed image
      if Assigned(FForm) and Assigned(FForm.FCardPanels) and
         Assigned(FForm.FOrigCovers) and (FCurrentImage.Parent is TPanel) then
      begin
        CardPanel := TPanel(FCurrentImage.Parent);
        CardIdx := FForm.FCardPanels.IndexOf(CardPanel);
        if (CardIdx >= 0) and (CardIdx < FForm.FOrigCovers.Count) then
        begin
          if FForm.FOrigCovers[CardIdx] <> nil then
            TLazIntfImage(FForm.FOrigCovers[CardIdx]).Free;
          FForm.FOrigCovers[CardIdx] := ScaledBmp.CreateIntfImage;
        end;
      end;
    finally
      ScaledBmp.Free;
    end;
    // Dim cover to match the default un-hovered state
    if Assigned(FForm) and (FCurrentImage.Parent is TPanel) then
      FForm.ApplyCardBrightness(TPanel(FCurrentImage.Parent), 100);
  except
  end;
end;



procedure GenerateFallbackCover(const APath: string; AForm: Tgoverlayform);
var
  Bmp: TBitmap;
  Png: TPortableNetworkGraphic;
  IconPath: string;
  DestRect: TRect;
  IconSize: Integer;
begin
  if not Assigned(AForm) then Exit;
  IconPath := AForm.GetAppBaseDir + 'data/icons/128x128/goverlay.png';
  if not FileExists(IconPath) then
    IconPath := '/usr/share/icons/hicolor/128x128/apps/goverlay.png';
  if not FileExists(IconPath) then
    IconPath := '/usr/share/icons/hicolor/128x128/apps/io.github.benjamimgois.goverlay.png';

  WriteLn(StdErr, '[CoverThread] GenerateFallbackCover APath="', APath, '" IconPath="', IconPath, '" exists=', FileExists(IconPath));

  Bmp := TBitmap.Create;
  try
    Bmp.SetSize(CARD_W, CARD_H);
    Bmp.Canvas.Brush.Color := $252525; // Dark background
    Bmp.Canvas.FillRect(Rect(0, 0, CARD_W, CARD_H));

    if FileExists(IconPath) then
    begin
      Png := TPortableNetworkGraphic.Create;
      try
        Png.LoadFromFile(IconPath);
        IconSize := 96; // 96x96 centered inside 150x215
        DestRect := Rect(
          (CARD_W - IconSize) div 2,
          (CARD_H - IconSize) div 2,
          (CARD_W - IconSize) div 2 + IconSize,
          (CARD_H - IconSize) div 2 + IconSize
        );
        Bmp.Canvas.StretchDraw(DestRect, Png);
      finally
        Png.Free;
      end;
    end;

    with TJPEGImage.Create do
    try
      Assign(Bmp);
      SaveToFile(APath);
      with TStringList.Create do
      try
        SaveToFile(APath + '.fallback');
      finally
        Free;
      end;
      WriteLn(StdErr, '[CoverThread] GenerateFallbackCover saved successfully to ', APath);
    except
      on E: Exception do
        WriteLn(StdErr, '[CoverThread] Error saving fallback cover: ', E.Message);
    end;
  finally
    Bmp.Free;
  end;
end;



procedure TCoverDownloadThread.Execute;
var
  i, j, k, m, n: Integer;
  AppID, GameName, OutPath, Url, TmpFile, JsonStr: string;
  Proc: TProcess;
  CdnUrls, S: TStringList;
begin
  ForceDirectories(FCacheDir);
  WriteLn(StdErr, '[CoverThread] Execute started. FAppIDs.Count=', FAppIDs.Count);
  for i := 0 to FAppIDs.Count - 1 do
  begin
    if Terminated then Break;

    AppID := FAppIDs.Names[i];
    GameName := FAppIDs.ValueFromIndex[i];
    if AppID = '' then
    begin
      AppID := FAppIDs[i];
      GameName := '';
    end;

    OutPath := FCacheDir + AppID + '.jpg';
    WriteLn(StdErr, '[CoverThread] AppID=', AppID, ' GameName="', GameName, '" OutPath="', OutPath, '"');

    if FileExists(OutPath) and (FileSize(OutPath) > 0) then
    begin
      WriteLn(StdErr, '[CoverThread] Cached file exists, using it');
      FCurrentImage := TImage(FImages[i]);
      FCurrentPath  := OutPath;
      Synchronize(@DoUpdateImage);
      Continue;
    end;

    // Try multi-CDN candidate URLs
    CdnUrls := TStringList.Create;
    try
      CdnUrls.Add('https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/' + AppID + '/library_600x900.jpg');
      CdnUrls.Add('https://cdn.cloudflare.steamstatic.com/steam/apps/' + AppID + '/library_600x900.jpg');
      CdnUrls.Add('https://cdn.akamai.steamstatic.com/steam/apps/' + AppID + '/library_600x900.jpg');
      CdnUrls.Add('https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/' + AppID + '/header.jpg');
      CdnUrls.Add('https://cdn.cloudflare.steamstatic.com/steam/apps/' + AppID + '/header.jpg');
      CdnUrls.Add('https://cdn.akamai.steamstatic.com/steam/apps/' + AppID + '/header.jpg');

      for j := 0 to CdnUrls.Count - 1 do
      begin
        Url := CdnUrls[j];
        Proc := TProcess.Create(nil);
        try
          Proc.Executable := 'curl';
          Proc.Parameters.Add('-s');
          Proc.Parameters.Add('-L');
          Proc.Parameters.Add('--connect-timeout');
          Proc.Parameters.Add('3');
          Proc.Parameters.Add('--max-time');
          Proc.Parameters.Add('6');
          Proc.Parameters.Add('--fail');
          Proc.Parameters.Add('-o');
          Proc.Parameters.Add(OutPath);
          Proc.Parameters.Add(Url);
          Proc.Options := [poWaitOnExit, poNoConsole];
          try Proc.Execute; except end;
        finally
          Proc.Free;
        end;

        if FileExists(OutPath) and (FileSize(OutPath) > 0) then
        begin
          WriteLn(StdErr, '[CoverThread] CDN download successful from ', Url);
          Break;
        end
        else
          DeleteFile(OutPath);
      end;
    finally
      CdnUrls.Free;
    end;

    // Fallback to Steam Store API details if direct CDN URLs failed
    if (not FileExists(OutPath)) or (FileSize(OutPath) = 0) then
    begin
      TmpFile := GetTempDir + 'goverlay_steam_api_' + AppID + '_' + IntToStr(GetProcessID) + '.json';
      Proc := TProcess.Create(nil);
      try
        Proc.Executable := 'curl';
        Proc.Parameters.Add('-s');
        Proc.Parameters.Add('-L');
        Proc.Parameters.Add('--connect-timeout');
        Proc.Parameters.Add('3');
        Proc.Parameters.Add('--max-time');
        Proc.Parameters.Add('6');
        Proc.Parameters.Add('-o');
        Proc.Parameters.Add(TmpFile);
        Proc.Parameters.Add('https://store.steampowered.com/api/appdetails?appids=' + AppID);
        Proc.Options := [poWaitOnExit, poNoConsole];
        try Proc.Execute; except end;
      finally
        Proc.Free;
      end;

      if FileExists(TmpFile) then
      begin
        JsonStr := '';
        S := TStringList.Create;
        try
          S.LoadFromFile(TmpFile);
          JsonStr := S.Text;
        finally
          S.Free;
          DeleteFile(TmpFile);
        end;

        k := Pos('"header_image":"', JsonStr);
        if k = 0 then k := Pos('"capsule_image":"', JsonStr);
        if k > 0 then
        begin
          m := PosEx('http', JsonStr, k);
          if m > 0 then
          begin
            n := m;
            while (n <= Length(JsonStr)) and (JsonStr[n] <> '"') do Inc(n);
            Url := Copy(JsonStr, m, n - m);
            Url := StringReplace(Url, '\/', '/', [rfReplaceAll]);
            if Url <> '' then
            begin
              Proc := TProcess.Create(nil);
              try
                Proc.Executable := 'curl';
                Proc.Parameters.Add('-s');
                Proc.Parameters.Add('-L');
                Proc.Parameters.Add('--max-time');
                Proc.Parameters.Add('10');
                Proc.Parameters.Add('--fail');
                Proc.Parameters.Add('-o');
                Proc.Parameters.Add(OutPath);
                Proc.Parameters.Add(Url);
                Proc.Options := [poWaitOnExit, poNoConsole];
                try Proc.Execute; except end;
              finally
                Proc.Free;
              end;
            end;
          end;
        end;
      end;
    end;

    // Fallback to Web search if Steam CDN fails
    if (not FileExists(OutPath)) or (FileSize(OutPath) = 0) then
    begin
      WriteLn(StdErr, '[CoverThread] CDN failed. Web search fallback for GameName="', GameName, '"');
      if GameName <> '' then
      begin
        DeleteFile(OutPath);
        FForm.SearchWebCover(GameName, OutPath);
        WriteLn(StdErr, '[CoverThread] Web search result exists=', FileExists(OutPath));
      end;
    end;

    // Fallback to GOverlay Icon on dark background if web search also fails
    if (not FileExists(OutPath)) or (FileSize(OutPath) = 0) then
    begin
      WriteLn(StdErr, '[CoverThread] CDN & Web search failed. Generating GOverlay fallback');
      DeleteFile(OutPath);
      GenerateFallbackCover(OutPath, FForm);
      WriteLn(StdErr, '[CoverThread] Fallback cover exists=', FileExists(OutPath));
    end;

    if FileExists(OutPath) and (FileSize(OutPath) > 0) then
    begin
      FCurrentImage := TImage(FImages[i]);
      FCurrentPath  := OutPath;
      Synchronize(@DoUpdateImage);
    end;
  end;
end;

// ============================================================================
// TNonSteamCoverThread implementation
// ============================================================================



constructor TNonSteamCoverThread.Create(
  const AItems: array of TNonSteamCoverItem; AForm: Tgoverlayform);
var
  i: Integer;
begin
  inherited Create(True);
  SetLength(FItems, Length(AItems));
  for i := 0 to High(AItems) do
    FItems[i] := AItems[i];
  FForm := AForm;
  FreeOnTerminate := True;
  OnTerminate := @FForm.CoverThreadTerminated;
end;

// ============================================================================
// Cover check timer: polls for downloaded covers and updates UI from main thread
// ============================================================================



procedure TNonSteamCoverThread.DoUpdateImage;
var
  ScaledBmp: TBitmap;
  CardPanel: TPanel;
  CardImage: TImage;
  j: Integer;
begin
  if not Assigned(FForm) or (FForm.FNonSteamCoverThread <> Self) then Exit;
  if not Assigned(FForm.FCardPanels) or not Assigned(FForm.FOrigCovers) then Exit;
  if not FileExists(FCurrentPath) then Exit;
  if (FCurrentCardIdx < 0) or (FCurrentCardIdx >= FForm.FCardPanels.Count) then Exit;

  CardPanel := TPanel(FForm.FCardPanels[FCurrentCardIdx]);
  CardImage := nil;
  for j := 0 to CardPanel.ControlCount - 1 do
    if CardPanel.Controls[j] is TImage then
    begin
      CardImage := TImage(CardPanel.Controls[j]);
      Break;
    end;
  if not Assigned(CardImage) then Exit;

  try
    CardImage.Picture.LoadFromFile(FCurrentPath);
    ScaledBmp := TBitmap.Create;
    try
      ScaledBmp.SetSize(CARD_W, CARD_H);
      ScaledBmp.Canvas.StretchDraw(
        Rect(0, 0, CARD_W, CARD_H), CardImage.Picture.Graphic);
      ProcessCoverBitmap(ScaledBmp, GRAD_H);
      CardImage.Picture.Bitmap.Assign(ScaledBmp);
      if (FCurrentCardIdx >= 0) and (FCurrentCardIdx < FForm.FOrigCovers.Count) then
      begin
        if FForm.FOrigCovers[FCurrentCardIdx] <> nil then
          TLazIntfImage(FForm.FOrigCovers[FCurrentCardIdx]).Free;
        FForm.FOrigCovers[FCurrentCardIdx] := ScaledBmp.CreateIntfImage;
      end;
    finally
      ScaledBmp.Free;
    end;
    for j := 0 to CardPanel.ControlCount - 1 do
      if (CardPanel.Controls[j] is TLabel) and (CardPanel.Controls[j].Tag = 9991) then
      begin
        CardPanel.Controls[j].Visible := FCurrentIsFallback;
        Break;
      end;
    FForm.ApplyCardBrightness(CardPanel, 100);
  except
  end;
end;



procedure TNonSteamCoverThread.Execute;
var
  i: Integer;
  AppId: string;
  GotCover, IsFallbackCover: Boolean;
begin
  for i := 0 to High(FItems) do
  begin
    if Terminated then Break;

    // Already cached?
    if FileExists(FItems[i].CachePath) then
    begin
      FCurrentCardIdx := FItems[i].CardIndex;
      FCurrentPath := FItems[i].CachePath;
      FCurrentIsFallback := FileExists(FItems[i].CachePath + '.fallback');
      Synchronize(@DoUpdateImage);
      Continue;
    end;

    WriteLn(StdErr, '[NonSteamCoverThread] Processing GameName="', FItems[i].GameName, '" CachePath="', FItems[i].CachePath, '"');

    GotCover := False;
    IsFallbackCover := False;

    // 1st attempt: Steam Store API
    if Assigned(FForm) and not FForm.FClosing then
      if FForm.SearchSteamStoreGame(FItems[i].GameName, AppId) then
        if FForm.DownloadSteamCover(AppId, FItems[i].CachePath) then
        begin
          GotCover := True;
          DeleteFile(FItems[i].CachePath + '.fallback');
        end;

    // 2nd attempt: Web image search
    if not GotCover and Assigned(FForm) and not FForm.FClosing then
      if FForm.SearchWebCover(FItems[i].GameName, FItems[i].CachePath) then
      begin
        GotCover := True;
        DeleteFile(FItems[i].CachePath + '.fallback');
      end;

    // 3rd attempt: GOverlay Icon fallback
    if not GotCover and (not FileExists(FItems[i].CachePath) or (FileSize(FItems[i].CachePath) = 0)) then
    begin
      WriteLn(StdErr, '[NonSteamCoverThread] CDN & Web search failed. Generating GOverlay fallback');
      DeleteFile(FItems[i].CachePath);
      GenerateFallbackCover(FItems[i].CachePath, FForm);
      GotCover := True;
      IsFallbackCover := True;
    end;

    if GotCover or FileExists(FItems[i].CachePath) then
    begin
      WriteLn(StdErr, '[NonSteamCoverThread] Updating image card index=', FItems[i].CardIndex, ' path=', FItems[i].CachePath);
      FCurrentCardIdx := FItems[i].CardIndex;
      FCurrentPath := FItems[i].CachePath;
      FCurrentIsFallback := IsFallbackCover or FileExists(FItems[i].CachePath + '.fallback');
      Synchronize(@DoUpdateImage);
    end;
  end;
end;



procedure ProcessCoverBitmap(Bmp: TBitmap; GradH: Integer);
var
  IntfImg: TLazIntfImage;
  ResultBmp: TBitmap;
  Stride, BPP, W, H: Integer;
  Row: PByte;
  x, y, px, DimPct, Bright: Integer;
begin
  W := Bmp.Width;
  H := Bmp.Height;
  if (W = 0) or (H = 0) then Exit;
  IntfImg := TLazIntfImage.Create(W, H);
  try
    IntfImg.LoadFromBitmap(Bmp.Handle, 0);
    Stride := IntfImg.DataDescription.BytesPerLine;
    BPP    := IntfImg.DataDescription.BitsPerPixel div 8;
    if BPP < 3 then Exit;

    for y := 0 to H - 1 do
    begin
      if y < H - GradH then Continue;
      DimPct := Round((y - (H - GradH)) / GradH * 88);
      if DimPct <= 0 then Continue;
      Row := IntfImg.PixelData + PtrUInt(y * Stride);
      for x := 0 to W - 1 do
      begin
        px := x * BPP;
        Row[px]   := Byte(Integer(Row[px])   * (100 - DimPct) div 100);
        Row[px+1] := Byte(Integer(Row[px+1]) * (100 - DimPct) div 100);
        Row[px+2] := Byte(Integer(Row[px+2]) * (100 - DimPct) div 100);
      end;
    end;

    ResultBmp := TBitmap.Create;
    try
      ResultBmp.LoadFromIntfImage(IntfImg);
      Bmp.Assign(ResultBmp);
    finally
      ResultBmp.Free;
    end;
  finally
    IntfImg.Free;
  end;
end;



procedure TGamesTabHelper.InitGamesTab;
var
  OpenFolderItem: TMenuItem;
  UninstallItem: TMenuItem;
  GamesBgPB: TPaintBox;
  IconPath: string;
  Bmp: TBitmap;
  IconColor: TColor;
  x, y: Integer;
  Clr: TColor;
  Gray: Byte;
begin
  with FForm do
  begin
  FCardPanels := TList.Create;
  FOrigCovers := TList.Create;

  // Right-click context menu for game cards
  FGameCardMenu := TPopupMenu.Create(FForm);

  // Dedicated 16x16 image list for the menu — drawn in greyscale
  FGameMenuImgList := TImageList.Create(FForm);
  FGameMenuImgList.Width := 16;
  FGameMenuImgList.Height := 16;

  IconColor := RGBToColor(180, 180, 180);

  // --- Icon 0: Folder (greyscale) ---
  Bmp := TBitmap.Create;
  try
    Bmp.SetSize(16, 16);
    Bmp.Canvas.Brush.Color := clFuchsia;
    Bmp.Canvas.FillRect(0, 0, 16, 16);
    Bmp.Canvas.Pen.Color := IconColor;
    Bmp.Canvas.Brush.Color := IconColor;
    Bmp.Canvas.Rectangle(2, 3, 8, 6);   // tab
    Bmp.Canvas.Rectangle(2, 5, 14, 13); // body
    FGameMenuImgList.AddMasked(Bmp, clFuchsia);
  finally
    Bmp.Free;
  end;

  // --- Icon 1: Wine prefix (greyscale copy of iconsImageList[38]) ---
  if Assigned(iconsImageList) and (iconsImageList.Count > 38) then
  begin
    Bmp := TBitmap.Create;
    try
      Bmp.SetSize(16, 16);
      Bmp.Canvas.Brush.Color := clFuchsia;
      Bmp.Canvas.FillRect(0, 0, 16, 16);
      iconsImageList.Draw(Bmp.Canvas, 0, 0, 38);
      // Convert every non-mask pixel to greyscale
      for y := 0 to 15 do
        for x := 0 to 15 do
        begin
          Clr := Bmp.Canvas.Pixels[x, y];
          if Clr <> clFuchsia then
          begin
            Gray := (Red(Clr) + Green(Clr) + Blue(Clr)) div 3;
            Bmp.Canvas.Pixels[x, y] := RGBToColor(Gray, Gray, Gray);
          end;
        end;
      FGameMenuImgList.AddMasked(Bmp, clFuchsia);
    finally
      Bmp.Free;
    end;
  end
  else
  begin
    // Fallback: simple wine-glass silhouette
    Bmp := TBitmap.Create;
    try
      Bmp.SetSize(16, 16);
      Bmp.Canvas.Brush.Color := clFuchsia;
      Bmp.Canvas.FillRect(0, 0, 16, 16);
      Bmp.Canvas.Pen.Color := IconColor;
      Bmp.Canvas.Brush.Color := IconColor;
      Bmp.Canvas.RoundRect(4, 2, 12, 7, 6, 6); // bowl
      Bmp.Canvas.Rectangle(7, 7, 9, 12);       // stem
      Bmp.Canvas.Rectangle(4, 12, 12, 14);     // base
      FGameMenuImgList.AddMasked(Bmp, clFuchsia);
    finally
      Bmp.Free;
    end;
  end;

  // --- Icon 2: Trash / Uninstall (greyscale) ---
  Bmp := TBitmap.Create;
  try
    Bmp.SetSize(16, 16);
    Bmp.Canvas.Brush.Color := clFuchsia;
    Bmp.Canvas.FillRect(0, 0, 16, 16);
    Bmp.Canvas.Pen.Color := IconColor;
    Bmp.Canvas.Brush.Color := IconColor;
    Bmp.Canvas.Rectangle(3, 2, 13, 4);  // lid
    Bmp.Canvas.Rectangle(4, 4, 12, 14); // body
    Bmp.Canvas.Pen.Color := clFuchsia;
    Bmp.Canvas.MoveTo(6, 6); Bmp.Canvas.LineTo(6, 12);
    Bmp.Canvas.MoveTo(9, 6); Bmp.Canvas.LineTo(9, 12);
    FGameMenuImgList.AddMasked(Bmp, clFuchsia);
  finally
    Bmp.Free;
  end;

  FGameCardMenu.Images := FGameMenuImgList;

  OpenFolderItem := TMenuItem.Create(FGameCardMenu);
  OpenFolderItem.Caption := 'Open install folder';
  OpenFolderItem.ImageIndex := 0;
  OpenFolderItem.OnClick := @GameCardOpenFolderClick;
  FGameCardMenu.Items.Add(OpenFolderItem);

  FOpenPrefixMenuItem := TMenuItem.Create(FGameCardMenu);
  FOpenPrefixMenuItem.Caption := 'Open prefix folder';
  FOpenPrefixMenuItem.ImageIndex := 1;
  FOpenPrefixMenuItem.OnClick := @GameCardOpenPrefixClick;
  FGameCardMenu.Items.Add(FOpenPrefixMenuItem);

  UninstallItem := TMenuItem.Create(FGameCardMenu);
  UninstallItem.Caption := 'Uninstall changes';
  UninstallItem.ImageIndex := 2;
  UninstallItem.OnClick := @GameCardUninstallClick;
  FGameCardMenu.Items.Add(UninstallItem);

  FGamesScrollBox := TScrollBox.Create(FForm);
  FGamesScrollBox.Parent := gamesTabSheet;
  FGamesScrollBox.Align := alClient;
  FGamesScrollBox.AutoScroll := True;
  FGamesScrollBox.BorderStyle := bsNone;
  FGamesScrollBox.HorzScrollBar.Visible := False;
  FGamesScrollBox.Color := RGBToColor(22, 26, 40);
  FGamesScrollBox.ParentColor := False;
  FGamesScrollBox.OnResize := @GamesScrollBoxResize;

  // Navy background paintbox — created before FGamesPanel so it sits behind the cards
  GamesBgPB := TPaintBox.Create(FForm);
  GamesBgPB.Parent  := FGamesScrollBox;
  GamesBgPB.Align   := alClient;
  GamesBgPB.OnPaint := @PresetsBgBoxPaint;

  FGamesPanel := TPanel.Create(FForm);
  FGamesPanel.Parent := FGamesScrollBox;
  FGamesPanel.Caption := '';
  FGamesPanel.BevelOuter := bvNone;
  FGamesPanel.Color := RGBToColor(22, 26, 40);
  FGamesPanel.Left := 0;
  FGamesPanel.Top := 0;
  FGamesPanel.Width := 800;
  FGamesPanel.Height := 100;
  FGamesPanel.OnPaint := @PresetsWrapperPaint;
  FGamesPanel.OnClick := @GamesEmptySpaceClick;
  FGamesScrollBox.OnClick := @GamesEmptySpaceClick;

  // Cache badge icons for corner ribbon (loaded once, reused per card)
  FMangoIconGfx := TPortableNetworkGraphic.Create;
  IconPath := GetAppBaseDir + 'assets/icons/mango-active.png';
  if FileExists(IconPath) then try FMangoIconGfx.LoadFromFile(IconPath); except end;

  FOptiIconGfx := TPortableNetworkGraphic.Create;
  IconPath := GetAppBaseDir + 'assets/icons/scale-up2-active.png';
  if FileExists(IconPath) then try FOptiIconGfx.LoadFromFile(IconPath); except end;

  // Navy background for the bottom bar
  goverlaybarPanel.OnPaint := @PresetsWrapperPaint;

  // Quick preview button — icon-only, sits immediately left of popupBitBtn.
  FPreviewBtn := TBitBtn.Create(FForm);
  FPreviewBtn.Parent      := goverlaybarPanel;
  // Align height (30) and vertical position (5) with the rest of the bar
  FPreviewBtn.SetBounds(684, 5, 28, 30);
  FPreviewBtn.Anchors     := [akRight, akBottom];
  FPreviewBtn.Caption     := '▶';
  FPreviewBtn.Color       := $00445566;
  FPreviewBtn.Font.Color  := clWhite;
  FPreviewBtn.Font.Size   := 10;
  FPreviewBtn.Font.Style  := [fsBold];
  FPreviewBtn.Font.Name   := 'Noto Sans';
  FPreviewBtn.Hint        := 'Launch a quick preview cube (pascube / vkcube)';
  FPreviewBtn.ShowHint    := True;
  FPreviewBtn.OnClick     := @PreviewBtnClick;

  // Re-anchor commandPanel so it stops at the left edge of FPreviewBtn,
  // preventing the panel from drawing over the preview button.
  commandPanel.AnchorSideRight.Control := FPreviewBtn;
  commandPanel.AnchorSideRight.Side    := asrLeft;

  // Informative hint for the launch-command box
  commandPanel.Hint := 'Copy this command and paste it into the game''s Launch Options in Steam.';
  commandPanel.ShowHint := True;

  end;
end;



procedure TGamesTabHelper.LoadSteamGames;
const
  // bit0=Mango(PNG), bit1=vkBasalt(glyph), bit2=OptiScaler(PNG), bit3=Tweaks(glyph)
  BADGE_GLYPHS: array[0..3] of string = ('', '󰏘', '', '󰒓');
  BDG_SZ    = 18;   // icon cell size
  BDG_GAP   = 5;    // vertical gap between icons
  BDG_PAD_V = 6;    // top/bottom padding inside strip
  BDG_FONT  = 13;   // glyph font size
  BDG_W     = 26;   // strip width (right edge)
var
  Libraries: TStringList;
  PendingIDs: TStringList;
  PendingImages: TList;
  CacheDir: string;
  i, j, CardX, CardY, CardsPerRow, TotalRows, RowMargin: Integer;
  LibPath, AcfContent, AppID, GameName, ImagePath, HomeDir, InstallDir, IconPath: string;
  SR: TSearchRec;
  AcfFile: TStringList;
  CardPanel: TPanel;
  CardImage: TImage;
  BdgLbl: TLabel;
  BdgImg: TImage;
  BdgBg:  TShape;
  NoGamesLabel: TLabel;
  LowerName, GameCfgDir: string;
  ScaledBmp: TBitmap;
  HasMango, HasVkBasalt, HasOptiScaler, HasTweaks: Boolean;
  TweakLines: TStringList;
  k, BadgeCount, BdgBit, BdgSlot, BdgX, BdgY: Integer;
  BdgHint: string;
begin
  with FForm do
  begin
  if not Assigned(FGamesScrollBox) or not Assigned(FGamesPanel) then
    Exit;

  if IsRunningInFlatpak then
    HomeDir := IncludeTrailingPathDelimiter(GetUserDir)
  else
    HomeDir := IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'));
  CacheDir := HomeDir + '.cache/goverlay/covers/';
  ForceDirectories(CacheDir);

  Libraries     := TStringList.Create;
  PendingIDs    := TStringList.Create;
  PendingImages := TList.Create;
  try
    GetSteamLibraries(Libraries);

    if Libraries.Count = 0 then
    begin
      NoGamesLabel := TLabel.Create(FForm);
      NoGamesLabel.Parent := FGamesPanel;
      NoGamesLabel.Caption := 'Steam not found or no libraries detected.';
      NoGamesLabel.Font.Color := clSilver;
      NoGamesLabel.Font.Size := 10;
      NoGamesLabel.Left := 16;
      NoGamesLabel.Top := 16;
      Exit;
    end;

    CardsPerRow := Max(1, FGamesScrollBox.Width div (CARD_W + CARD_MARGIN));
    RowMargin := (FGamesScrollBox.Width - CardsPerRow * CARD_W) div (CardsPerRow + 1);
    if RowMargin < 4 then RowMargin := 4;
    j := 0;

    for i := 0 to Libraries.Count - 1 do
    begin
      LibPath := Libraries[i];
      if FindFirst(LibPath + '/appmanifest_*.acf', faAnyFile, SR) = 0 then
      begin
        repeat
          AcfFile := TStringList.Create;
          try
            AcfFile.LoadFromFile(LibPath + '/' + SR.Name);
            AcfContent := AcfFile.Text;
          finally
            AcfFile.Free;
          end;

          AppID      := ParseAcfValue(AcfContent, 'appid');
          GameName   := ParseAcfValue(AcfContent, 'name');
          InstallDir := ParseAcfValue(AcfContent, 'installdir');
          if (AppID = '') or (GameName = '') then
            Continue;

          // Skip non-game Steam entries (runtimes, tools, redistributables)
          LowerName := LowerCase(GameName);
          if (Pos('proton', LowerName) > 0) or
             (Pos('steamworks', LowerName) > 0) or
             (Pos('steam linux runtime', LowerName) > 0) or
             (Pos('redistributable', LowerName) > 0) or
             (Pos('steam sdk', LowerName) > 0) then
            Continue;

          // Look for local cover; if absent, queue for CDN download
          ImagePath := HomeDir + '.steam/steam/appcache/librarycache/' + AppID + '/library_600x900.jpg';
          if not FileExists(ImagePath) then
            ImagePath := HomeDir + '.steam/steam/appcache/librarycache/' + AppID + '/header.jpg';
          if not FileExists(ImagePath) then
            ImagePath := HomeDir + '.steam/root/appcache/librarycache/' + AppID + '/library_600x900.jpg';
          if not FileExists(ImagePath) then
            ImagePath := HomeDir + '.steam/root/appcache/librarycache/' + AppID + '/header.jpg';
          if not FileExists(ImagePath) then
            ImagePath := HomeDir + '.steam/debian-installation/appcache/librarycache/' + AppID + '/library_600x900.jpg';
          if not FileExists(ImagePath) then
            ImagePath := HomeDir + '.steam/debian-installation/appcache/librarycache/' + AppID + '/header.jpg';
          if not FileExists(ImagePath) then
            ImagePath := HomeDir + '.local/share/Steam/appcache/librarycache/' + AppID + '/library_600x900.jpg';
          if not FileExists(ImagePath) then
            ImagePath := HomeDir + '.local/share/Steam/appcache/librarycache/' + AppID + '/header.jpg';
          if not FileExists(ImagePath) then
            ImagePath := HomeDir + '.var/app/com.valvesoftware.Steam/data/Steam/appcache/librarycache/' + AppID + '/library_600x900.jpg';
          if not FileExists(ImagePath) then
            ImagePath := HomeDir + '.var/app/com.valvesoftware.Steam/data/Steam/appcache/librarycache/' + AppID + '/header.jpg';
          if not FileExists(ImagePath) then
            ImagePath := HomeDir + '.var/app/com.valvesoftware.Steam/.local/share/Steam/appcache/librarycache/' + AppID + '/library_600x900.jpg';
          if not FileExists(ImagePath) then
            ImagePath := HomeDir + '.var/app/com.valvesoftware.Steam/.local/share/Steam/appcache/librarycache/' + AppID + '/header.jpg';
          // Also check the persistent cache from previous downloads
          if not FileExists(ImagePath) then
            ImagePath := CacheDir + AppID + '.jpg';

          // Card position (dynamic margin distributes leftover space evenly)
          CardX := RowMargin + (j mod CardsPerRow) * (CARD_W + RowMargin);
          CardY := RowMargin + (j div CardsPerRow) * (CARD_H + RowMargin);

          CardPanel := TPanel.Create(FForm);
          CardPanel.Parent := FGamesPanel;
          CardPanel.SetBounds(CardX, CardY, CARD_W, CARD_H);
          CardPanel.BevelOuter := bvNone;
          CardPanel.BevelInner := bvNone;
          CardPanel.BorderWidth := 0;
          CardPanel.Caption := '';
          CardPanel.Tag := 9999;  // marker: game card — excluded from theme color override
          CardPanel.Color := $303030;  // slightly lighter than the navy bg for contrast
          CardPanel.Hint := '(' + AppID + ') ' + GameName + LineEnding + LibPath + '/common/' + InstallDir;
          CardPanel.ShowHint := True;
          CardPanel.OnMouseEnter := @GameCardMouseEnter;
          CardPanel.OnMouseLeave := @GameCardMouseLeave;
          CardPanel.OnClick := @GameCardClick;
          CardPanel.OnMouseUp := @GameCardMouseUp;

          CardImage := TImage.Create(CardPanel);
          CardImage.Parent := CardPanel;
          CardImage.Tag := 9995;
          CardImage.SetBounds(0, 0, CARD_W, CARD_H);
          CardImage.Stretch := True;
          CardImage.Proportional := False;
          CardImage.Center := False;
          CardImage.Hint := '(' + AppID + ') ' + GameName + LineEnding + LibPath + '/common/' + InstallDir;
          CardImage.ShowHint := True;
          CardImage.OnMouseEnter := @GameCardMouseEnter;
          CardImage.OnMouseLeave := @GameCardMouseLeave;
          CardImage.OnClick := @GameCardClick;
          CardImage.OnMouseUp := @GameCardMouseUp;

          // Steam icon badge (top-left corner, light gray)
          BdgImg := TImage.Create(CardPanel);
          BdgImg.Parent      := CardPanel;
          BdgImg.AutoSize    := False;
          BdgImg.SetBounds(4, 4, 16, 16);
          BdgImg.Stretch     := True;
          BdgImg.Proportional := True;
          BdgImg.Center      := True;
          BdgImg.Transparent := True;
          IconPath := GetAppBaseDir + 'assets/icons/steam-icon.png';
          if FileExists(IconPath) then
            try BdgImg.Picture.LoadFromFile(IconPath); except end;
          BdgImg.BringToFront;
          BdgImg.OnMouseEnter := @GameCardMouseEnter;
          BdgImg.OnMouseLeave := @GameCardMouseLeave;
          BdgImg.OnClick      := @GameCardClick;
          BdgImg.OnMouseUp    := @GameCardMouseUp;

          // Load local image or queue for CDN download
          if FileExists(ImagePath) and (FileSize(ImagePath) > 0) then
          begin
            try
              CardImage.Picture.LoadFromFile(ImagePath);
            except
            end;
          end
          else
          begin
            // No local image — will be downloaded by background thread
            PendingIDs.Add(AppID + '=' + GameName);
            PendingImages.Add(CardImage);
          end;

          // Compute badge bitmask and store in Tag for use by download thread
          GameCfgDir := GetGameConfigDir(GameName);
          HasMango      := FileExists(GameCfgDir + 'MangoHud.conf');
          HasVkBasalt   := FileExists(GameCfgDir + 'vkBasalt.conf') or FileExists(GameCfgDir + 'vkSumi.conf');
          HasOptiScaler := FileExists(GameCfgDir + 'OptiScaler.ini');
          HasTweaks := False;
          if FileExists(GameCfgDir + 'bgmod.conf') then
          begin
            TweakLines := TStringList.Create;
            try
              TweakLines.LoadFromFile(GameCfgDir + 'bgmod.conf');
              for k := 0 to TweakLines.Count - 1 do
                if Pos('GOVERLAY_TWEAKS=1', StringReplace(TweakLines[k], ' ', '', [rfReplaceAll])) > 0 then
                begin
                  HasTweaks := True;
                  Break;
                end;
            finally
              TweakLines.Free;
            end;
          end;
          // Badges — PNG for MangoHud/OptiScaler (matches nav rail), glyph for vkBasalt/Tweaks
          BadgeCount := 0;
          if HasMango      then Inc(BadgeCount, 1);
          if HasVkBasalt   then Inc(BadgeCount, 2);
          if HasOptiScaler then Inc(BadgeCount, 4);
          if HasTweaks     then Inc(BadgeCount, 8);
          CardPanel.Tag := BadgeCount;

          if BadgeCount > 0 then
          begin
            BdgImg := TImage.Create(CardPanel);
            BdgImg.Parent      := CardPanel;
            BdgImg.AutoSize    := False;
            BdgImg.SetBounds(CARD_W - 20, 4, 16, 16);
            BdgImg.BorderSpacing.Right := 4;
            BdgImg.BorderSpacing.Top   := 4;
            BdgImg.AnchorSide[akRight].Control := CardPanel;
            BdgImg.AnchorSide[akRight].Side    := asrBottom;
            BdgImg.AnchorSide[akTop].Control   := CardPanel;
            BdgImg.AnchorSide[akTop].Side      := asrTop;
            BdgImg.Anchors                     := [akTop, akRight];
            BdgImg.Stretch     := True;
            BdgImg.Proportional := True;
            BdgImg.Center      := True;
            BdgImg.Transparent := True;

            IconPath := GetAppBaseDir + 'assets/icons/goverlay.png';
            if not FileExists(IconPath) then
              IconPath := GetAppBaseDir + 'data/icons/128x128/goverlay.png';
            if not FileExists(IconPath) then
              IconPath := GetIconFile();

            WriteLn(StdErr, '[GOverlayBadge] Steam Game="', GameName, '" IconPath="', IconPath, '" exists=', FileExists(IconPath));
            if FileExists(IconPath) then
              try BdgImg.Picture.LoadFromFile(IconPath); except on E: Exception do WriteLn(StdErr, '[GOverlayBadge] Load error: ', E.Message); end;

            BdgHint := 'Configurações personalizadas ativas:';
            if HasMango then BdgHint := BdgHint + LineEnding + '• MangoHud';
            if HasVkBasalt then BdgHint := BdgHint + LineEnding + '• vkBasalt';
            if HasOptiScaler then BdgHint := BdgHint + LineEnding + '• OptiScaler';
            if HasTweaks then BdgHint := BdgHint + LineEnding + '• Tweaks';

            BdgImg.Hint := BdgHint;
            BdgImg.ShowHint := True;

            BdgImg.BringToFront;
            BdgImg.OnMouseEnter := @GameCardMouseEnter;
            BdgImg.OnMouseLeave := @GameCardMouseLeave;
            BdgImg.OnClick      := @GameCardClick;
            BdgImg.OnMouseUp    := @GameCardMouseUp;
          end;

          // Store card and original image; apply gradient
          FCardPanels.Add(CardPanel);
          if (CardImage.Picture.Graphic <> nil) and
             (CardImage.Picture.Graphic.Width > 0) then
          begin
            ScaledBmp := TBitmap.Create;
            try
              ScaledBmp.SetSize(CARD_W, CARD_H);
              ScaledBmp.Canvas.StretchDraw(
                Rect(0, 0, CARD_W, CARD_H), CardImage.Picture.Graphic);
              ProcessCoverBitmap(ScaledBmp, GRAD_H);
              CardImage.Picture.Bitmap.Assign(ScaledBmp);
              FOrigCovers.Add(ScaledBmp.CreateIntfImage);
            finally
              ScaledBmp.Free;
            end;
            ApplyCardBrightness(CardPanel, 100);
          end
          else
            FOrigCovers.Add(nil);

          CreateActionPanel(CardPanel);
          Inc(j);
        until FindNext(SR) <> 0;
        FindClose(SR);
      end;
    end;

    // Load non-Steam game folders and append their cards
    LoadNonSteamFolders(j, CardsPerRow, RowMargin);

    // ── "Add non-Steam folder" card (always last) ──
    CardX := RowMargin + (j mod CardsPerRow) * (CARD_W + RowMargin);
    CardY := RowMargin + (j div CardsPerRow) * (CARD_H + RowMargin);

    CardPanel := TPanel.Create(FForm);
    CardPanel.Parent := FGamesPanel;
    CardPanel.SetBounds(CardX, CardY, CARD_W, CARD_H);
    CardPanel.BevelOuter := bvNone;
    CardPanel.Caption := '';
    CardPanel.Tag := 9998;  // marker: add-folder card
    CardPanel.Color := RGBToColor(40, 44, 52);
    CardPanel.Hint := 'Click to add a non-Steam game folder';
    CardPanel.ShowHint := True;
    CardPanel.Cursor := crHandPoint;
    CardPanel.OnMouseEnter := @GameCardMouseEnter;
    CardPanel.OnMouseLeave := @GameCardMouseLeave;
    CardPanel.OnClick := @AddNonSteamFolderClick;
    CardPanel.OnMouseUp := @GameCardMouseUp;

    CardImage := TImage.Create(CardPanel);
    CardImage.Parent := CardPanel;
    CardImage.SetBounds(0, 0, CARD_W, CARD_H);
    CardImage.Stretch := True;
    CardImage.Proportional := False;
    CardImage.Center := False;
    CardImage.Cursor := crHandPoint;
    CardImage.OnMouseEnter := @GameCardMouseEnter;
    CardImage.OnMouseLeave := @GameCardMouseLeave;
    CardImage.OnClick := @AddNonSteamFolderClick;
    CardImage.OnMouseUp := @GameCardMouseUp;

    // Big "+" sign in centre
    BdgLbl := TLabel.Create(CardPanel);
    BdgLbl.Parent := CardPanel;
    BdgLbl.AutoSize := False;
    BdgLbl.SetBounds((CARD_W - 64) div 2, (CARD_H - 100) div 2, 64, 64);
    BdgLbl.Caption := '+';
    BdgLbl.Font.Color := clSilver;
    BdgLbl.Font.Size := 48;
    BdgLbl.Font.Style := [];
    BdgLbl.Alignment := taCenter;
    BdgLbl.Layout := tlCenter;
    BdgLbl.Transparent := True;
    BdgLbl.Cursor := crHandPoint;
    BdgLbl.OnMouseEnter := @GameCardMouseEnter;
    BdgLbl.OnMouseLeave := @GameCardMouseLeave;
    BdgLbl.OnClick := @AddNonSteamFolderClick;
    BdgLbl.OnMouseUp := @GameCardMouseUp;

    // Label below icon
    BdgLbl := TLabel.Create(CardPanel);
    BdgLbl.Parent := CardPanel;
    BdgLbl.AutoSize := False;
    BdgLbl.SetBounds(8, CARD_H - 56, CARD_W - 16, 40);
    BdgLbl.Caption := 'Add nonsteam folder';
    BdgLbl.Font.Color := clSilver;
    BdgLbl.Font.Size := 9;
    BdgLbl.Font.Style := [fsBold];
    BdgLbl.Alignment := taCenter;
    BdgLbl.Layout := tlCenter;
    BdgLbl.WordWrap := True;
    BdgLbl.Transparent := True;
    BdgLbl.Cursor := crHandPoint;
    BdgLbl.OnMouseEnter := @GameCardMouseEnter;
    BdgLbl.OnMouseLeave := @GameCardMouseLeave;
    BdgLbl.OnClick := @AddNonSteamFolderClick;
    BdgLbl.OnMouseUp := @GameCardMouseUp;

    FCardPanels.Add(CardPanel);
    FOrigCovers.Add(nil);
    Inc(j);

    // Recalculate panel size including non-Steam and add-folder cards
    TotalRows := (j + CardsPerRow - 1) div CardsPerRow;
    FGamesPanel.Width := FGamesScrollBox.Width;
    FGamesPanel.Height := RowMargin + TotalRows * (CARD_H + RowMargin);

    // Launch background thread to download missing covers from Steam CDN
    if PendingIDs.Count > 0 then
    begin
      if Assigned(FCoverThread) then
      begin
        FCoverThread.Terminate;
        FCoverThread := nil;
      end;
      // Thread takes ownership of PendingIDs and PendingImages
      FCoverThread := TCoverDownloadThread.Create(
        PendingIDs, PendingImages, CacheDir, FForm);
      PendingIDs    := nil;
      PendingImages := nil;
      FCoverThread.Start;
    end;

  finally
    Libraries.Free;
    PendingIDs.Free;
    PendingImages.Free;
  end;
  end;
end;



procedure TGamesTabHelper.LoadNonSteamFolders(var ACardIndex: Integer;
  const ACardsPerRow, ARowMargin: Integer);
var
  NonSteamFile: string;
  Lines: TStringList;
  I, CardX, CardY: Integer;
  FolderPath, GameName, SubPath: string;
  CardPanel: TPanel;
  CardImage: TImage;
  BdgImg: TImage;
  BdgLbl: TLabel;
  ScaledBmp: TBitmap;
  GameCfgDir: string;
  HasMango, HasVkBasalt, HasOptiScaler, HasTweaks: Boolean;
  BadgeCount, BdgBit, BdgSlot, BdgX, BdgY: Integer;
  BdgHint, IconPath: string;
  BdgBg: TShape;
  TweakLines: TStringList;
  k: Integer;
  SubSR: TSearchRec;
  LowerSubName: string;
  ShouldSkip: Boolean;
  CacheDir, CachePath: string;
  HasCover: Boolean;
  PendingItems: array of TNonSteamCoverItem;
  PendingCount: Integer;
const
  BDG_SZ    = 18;
  BDG_GAP   = 5;
  BDG_PAD_V = 6;
  BDG_FONT  = 13;
  BDG_W     = 26;
  BADGE_GLYPHS: array[0..3] of string = ('', '󰏘', '', '󰒓');
  SKIP_NAMES: array[0..6] of string = ('prefixes', 'common', 'compatdata', 'shadercache', 'downloads', 'tmp', 'temp');
begin
  with FForm do
  begin
  PendingCount := 0;
  NonSteamFile := GetUserDir + '.config/goverlay/nonsteam_folders.txt';
  if not FileExists(NonSteamFile) then Exit;

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(NonSteamFile);
    for I := 0 to Lines.Count - 1 do
    begin
      FolderPath := Trim(Lines[I]);
      if (FolderPath = '') or not DirectoryExists(FolderPath) then
        Continue;

      // Scan sub-folders inside the selected directory — each one is a game
      if FindFirst(IncludeTrailingPathDelimiter(FolderPath) + '*', faDirectory, SubSR) = 0 then
      begin
        try
          repeat
            if (SubSR.Name = '.') or (SubSR.Name = '..') then Continue;
            if (SubSR.Attr and faDirectory) = 0 then Continue;

            LowerSubName := LowerCase(SubSR.Name);
            // Skip known non-game directories
            ShouldSkip := False;
            for k := Low(SKIP_NAMES) to High(SKIP_NAMES) do
              if LowerSubName = SKIP_NAMES[k] then
              begin
                ShouldSkip := True;
                Break;
              end;
            if ShouldSkip then Continue;

            SubPath := IncludeTrailingPathDelimiter(FolderPath) + SubSR.Name;
            GameName := SubSR.Name;
            if GameName = '' then Continue;

      CardX := ARowMargin + (ACardIndex mod ACardsPerRow) * (CARD_W + ARowMargin);
      CardY := ARowMargin + (ACardIndex div ACardsPerRow) * (CARD_H + ARowMargin);

      CardPanel := TPanel.Create(FForm);
      CardPanel.Parent := FGamesPanel;
      CardPanel.SetBounds(CardX, CardY, CARD_W, CARD_H);
      CardPanel.BevelOuter := bvNone;
      CardPanel.BevelInner := bvNone;
      CardPanel.BorderWidth := 0;
      CardPanel.Caption := '';
      CardPanel.Tag := 9997;  // marker: non-Steam card
      CardPanel.Color := $303030;
      CardPanel.Hint := GameName + LineEnding + SubPath;
      CardPanel.ShowHint := True;
      CardPanel.OnMouseEnter := @GameCardMouseEnter;
      CardPanel.OnMouseLeave := @GameCardMouseLeave;
      CardPanel.OnClick := @GameCardClick;
      CardPanel.OnMouseUp := @GameCardMouseUp;

      CardImage := TImage.Create(CardPanel);
      CardImage.Parent := CardPanel;
      CardImage.Tag := 9995;
      CardImage.SetBounds(0, 0, CARD_W, CARD_H);
      CardImage.Stretch := True;
      CardImage.Proportional := False;
      CardImage.Center := False;
      CardImage.Hint := CardPanel.Hint;
      CardImage.ShowHint := True;
      CardImage.OnMouseEnter := @GameCardMouseEnter;
      CardImage.OnMouseLeave := @GameCardMouseLeave;
      CardImage.OnClick := @GameCardClick;
      CardImage.OnMouseUp := @GameCardMouseUp;

      // Wine icon badge (top-left corner)
      if Assigned(iconsImageList) then
      begin
        BdgImg := TImage.Create(CardPanel);
        BdgImg.Parent      := CardPanel;
        BdgImg.AutoSize    := False;
        BdgImg.SetBounds(4, 4, 16, 16);
        BdgImg.Stretch     := True;
        BdgImg.Proportional := True;
        BdgImg.Center      := True;
        BdgImg.Transparent := True;
        iconsImageList.GetBitmap(38, BdgImg.Picture.Bitmap);
        BdgImg.BringToFront;
        BdgImg.OnMouseEnter := @GameCardMouseEnter;
        BdgImg.OnMouseLeave := @GameCardMouseLeave;
        BdgImg.OnClick      := @GameCardClick;
        BdgImg.OnMouseUp    := @GameCardMouseUp;
      end;

      // Game name label at bottom
      BdgLbl := TLabel.Create(CardPanel);
      BdgLbl.Parent := CardPanel;
      BdgLbl.AutoSize := False;
      BdgLbl.SetBounds(4, CARD_H - 40, CARD_W - 8, 36);
      BdgLbl.Caption := GameName;
      BdgLbl.Font.Color := clWhite;
      BdgLbl.Font.Size := 9;
      BdgLbl.Font.Style := [fsBold];
      BdgLbl.Alignment := taCenter;
      BdgLbl.Layout := tlCenter;
      BdgLbl.WordWrap := True;
      BdgLbl.Transparent := True;
      BdgLbl.OnMouseEnter := @GameCardMouseEnter;
      BdgLbl.OnMouseLeave := @GameCardMouseLeave;
      BdgLbl.OnClick := @GameCardClick;
      BdgLbl.OnMouseUp := @GameCardMouseUp;
      BdgLbl.Tag := 9991;  // marker: non-Steam card title label

      // Compute badges from game-specific config dir (if user configured it)
      GameCfgDir := GetGameConfigDir(GameName);
      HasMango      := FileExists(GameCfgDir + 'MangoHud.conf');
      HasVkBasalt   := FileExists(GameCfgDir + 'vkBasalt.conf') or FileExists(GameCfgDir + 'vkSumi.conf');
      HasOptiScaler := FileExists(GameCfgDir + 'OptiScaler.ini');
      HasTweaks := False;
      if FileExists(GameCfgDir + 'bgmod.conf') then
      begin
        TweakLines := TStringList.Create;
        try
          TweakLines.LoadFromFile(GameCfgDir + 'bgmod.conf');
          for k := 0 to TweakLines.Count - 1 do
            if Pos('GOVERLAY_TWEAKS=1', StringReplace(TweakLines[k], ' ', '', [rfReplaceAll])) > 0 then
            begin
              HasTweaks := True;
              Break;
            end;
        finally
          TweakLines.Free;
        end;
      end;
      BadgeCount := 0;
      if HasMango      then Inc(BadgeCount, 1);
      if HasVkBasalt   then Inc(BadgeCount, 2);
      if HasOptiScaler then Inc(BadgeCount, 4);
      if HasTweaks     then Inc(BadgeCount, 8);
      CardPanel.Tag := BadgeCount;

      if BadgeCount > 0 then
      begin
        BdgImg := TImage.Create(CardPanel);
        BdgImg.Parent      := CardPanel;
        BdgImg.AutoSize    := False;
        BdgImg.SetBounds(CARD_W - 20, 4, 16, 16);
        BdgImg.BorderSpacing.Right := 4;
        BdgImg.BorderSpacing.Top   := 4;
        BdgImg.AnchorSide[akRight].Control := CardPanel;
        BdgImg.AnchorSide[akRight].Side    := asrBottom;
        BdgImg.AnchorSide[akTop].Control   := CardPanel;
        BdgImg.AnchorSide[akTop].Side      := asrTop;
        BdgImg.Anchors                     := [akTop, akRight];
        BdgImg.Stretch     := True;
        BdgImg.Proportional := True;
        BdgImg.Center      := True;
        BdgImg.Transparent := True;

        IconPath := GetAppBaseDir + 'assets/icons/goverlay.png';
        if not FileExists(IconPath) then
          IconPath := GetAppBaseDir + 'data/icons/128x128/goverlay.png';
        if not FileExists(IconPath) then
          IconPath := GetIconFile();

        WriteLn(StdErr, '[GOverlayBadge] NonSteam Game="', GameName, '" IconPath="', IconPath, '" exists=', FileExists(IconPath));
        if FileExists(IconPath) then
          try BdgImg.Picture.LoadFromFile(IconPath); except on E: Exception do WriteLn(StdErr, '[GOverlayBadge] Load error: ', E.Message); end;

        BdgHint := 'Configurações personalizadas ativas:';
        if HasMango then BdgHint := BdgHint + LineEnding + '• MangoHud';
        if HasVkBasalt then BdgHint := BdgHint + LineEnding + '• vkBasalt';
        if HasOptiScaler then BdgHint := BdgHint + LineEnding + '• OptiScaler';
        if HasTweaks then BdgHint := BdgHint + LineEnding + '• Tweaks';

        BdgImg.Hint := BdgHint;
        BdgImg.ShowHint := True;

        BdgImg.BringToFront;
        BdgImg.OnMouseEnter := @GameCardMouseEnter;
        BdgImg.OnMouseLeave := @GameCardMouseLeave;
        BdgImg.OnClick      := @GameCardClick;
        BdgImg.OnMouseUp    := @GameCardMouseUp;
      end;

            // Try to load cached cover; if missing queue async download
            CacheDir := GetUserDir + '.cache/goverlay/nonsteam_covers/';
            ForceDirectories(CacheDir);
            CachePath := CacheDir + SanitizeFileName(GameName) + '.jpg';
            HasCover := False;

            if FileExists(CachePath) and (FileSize(CachePath) > 0) then
            begin
              try
                CardImage.Picture.LoadFromFile(CachePath);
                HasCover := True;
              except
                HasCover := False;
              end;
            end;

            FCardPanels.Add(CardPanel);
            for k := 0 to CardPanel.ControlCount - 1 do
              if (CardPanel.Controls[k] is TLabel) and (CardPanel.Controls[k].Tag = 9991) then
              begin
                CardPanel.Controls[k].Visible := not (HasCover and not FileExists(CachePath + '.fallback'));
                Break;
              end;
            if HasCover then
            begin
              ScaledBmp := TBitmap.Create;
              try
                ScaledBmp.SetSize(CARD_W, CARD_H);
                ScaledBmp.Canvas.StretchDraw(Rect(0, 0, CARD_W, CARD_H), CardImage.Picture.Graphic);
                ProcessCoverBitmap(ScaledBmp, GRAD_H);
                CardImage.Picture.Bitmap.Assign(ScaledBmp);
                FOrigCovers.Add(ScaledBmp.CreateIntfImage);
              finally
                ScaledBmp.Free;
              end;
            end
            else
            begin
              // Solid-colour fallback immediately so UI stays responsive
              ScaledBmp := TBitmap.Create;
              try
                ScaledBmp.SetSize(CARD_W, CARD_H);
                ScaledBmp.Canvas.Brush.Color := $303030;
                ScaledBmp.Canvas.FillRect(Rect(0, 0, CARD_W, CARD_H));
                ProcessCoverBitmap(ScaledBmp, GRAD_H);
                CardImage.Picture.Bitmap.Assign(ScaledBmp);
                FOrigCovers.Add(ScaledBmp.CreateIntfImage);
              finally
                ScaledBmp.Free;
              end;
              // Queue for background cover download thread
              SetLength(PendingItems, PendingCount + 1);
              PendingItems[PendingCount].GameName  := GameName;
              PendingItems[PendingCount].CachePath := CachePath;
              PendingItems[PendingCount].CardIndex := FCardPanels.Count - 1;
              Inc(PendingCount);
            end;
            ApplyCardBrightness(CardPanel, 100);
            CreateActionPanel(CardPanel);

            Inc(ACardIndex);
          until FindNext(SubSR) <> 0;
        finally
          FindClose(SubSR);
        end;
      end;
    end;

    // Launch background thread to download missing non-Steam covers
    if PendingCount > 0 then
    begin
      if Assigned(FNonSteamCoverThread) then
      begin
        FNonSteamCoverThread.Terminate;
        FNonSteamCoverThread := nil;
      end;
      FNonSteamCoverThread := TNonSteamCoverThread.Create(PendingItems, FForm);
      FNonSteamCoverThread.Start;
    end;
  finally
    Lines.Free;
  end;
  end;
end;

// ============================================================================
// Game-specific config helpers
// ============================================================================



function TGamesTabHelper.SearchWebCover(const AGameName, ACachePath: string): Boolean;
var
  SearchName, Url, Html, ImgUrl: string;
  P: TProcess;
  S: TStringList;
  i, j, k: Integer;
  Candidates: TStringList;
  SearchRec: TSearchRec;
  TmpFile: string;
begin
  with FForm do
  begin
  Result := False;

  SearchName := StringReplace(AGameName, ' ', '+', [rfReplaceAll]);
  SearchName := StringReplace(SearchName, '&', '%26', [rfReplaceAll]);

  // Bing image search for game cover art
  Url := 'https://www.bing.com/images/search?q=' + SearchName +
         '+video+game+cover+art+600x900+jpg&form=HDRSC2&first=1';

  TmpFile := GetTempDir + 'goverlay_bing_' + IntToStr(GetProcessID) + '.html';

  P := TProcess.Create(nil);
  try
    P.Executable := 'curl';
    P.Parameters.Add('-s');
    P.Parameters.Add('-L');
    P.Parameters.Add('--connect-timeout');
    P.Parameters.Add('5');
    P.Parameters.Add('--max-time');
    P.Parameters.Add('10');
    P.Parameters.Add('-H');
    P.Parameters.Add('User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36');
    P.Parameters.Add('-o');
    P.Parameters.Add(TmpFile);
    P.Parameters.Add(Url);
    P.Options := [poWaitOnExit, poNoConsole];
    try
      P.Execute;
    except
      Exit;
    end;
  finally
    P.Free;
  end;

  if not FileExists(TmpFile) then Exit;

  S := TStringList.Create;
  try
    S.LoadFromFile(TmpFile);
    Html := S.Text;
  finally
    S.Free;
    DeleteFile(TmpFile);
  end;

  if Html = '' then Exit;

  // Parse HTML for image URLs
  // Bing embeds image data in "murl":"..." patterns
  Candidates := TStringList.Create;
  try
    // Look for "murl":"https://..." pattern
    i := Pos('"murl":"', Html);
    while i > 0 do
    begin
      j := i + Length('"murl":"');
      k := j;
      while (k <= Length(Html)) and (Html[k] <> '"') do
        Inc(k);
      ImgUrl := Copy(Html, j, k - j);
      // Unescape common sequences
      ImgUrl := StringReplace(ImgUrl, '\/', '/', [rfReplaceAll]);
      ImgUrl := StringReplace(ImgUrl, '\u0026', '&', [rfReplaceAll]);
      if (Pos('http', ImgUrl) = 1) and (Candidates.IndexOf(ImgUrl) < 0) then
        Candidates.Add(ImgUrl);
      if Candidates.Count >= 5 then Break;
      i := PosEx('"murl":"', Html, k);
    end;

    // Also try &murl= pattern as fallback
    if Candidates.Count = 0 then
    begin
      i := Pos('murl=http', Html);
      while i > 0 do
      begin
        j := i + Length('murl=');
        k := j;
        while (k <= Length(Html)) and not (Html[k] in ['&', '"', '''', ' ']) do
          Inc(k);
        ImgUrl := Copy(Html, j, k - j);
        // Basic URL decode
        ImgUrl := StringReplace(ImgUrl, '%3A', ':', [rfReplaceAll]);
        ImgUrl := StringReplace(ImgUrl, '%2F', '/', [rfReplaceAll]);
        ImgUrl := StringReplace(ImgUrl, '%3F', '?', [rfReplaceAll]);
        ImgUrl := StringReplace(ImgUrl, '%3D', '=', [rfReplaceAll]);
        ImgUrl := StringReplace(ImgUrl, '%26', '&', [rfReplaceAll]);
        if (Pos('http', ImgUrl) = 1) and (Candidates.IndexOf(ImgUrl) < 0) then
          Candidates.Add(ImgUrl);
        if Candidates.Count >= 5 then Break;
        i := PosEx('murl=http', Html, k);
      end;
    end;

    // Try downloading each candidate until one works
    for i := 0 to Candidates.Count - 1 do
    begin
      ImgUrl := Candidates[i];

      // Skip obviously wrong formats
      if (Pos('.svg', LowerCase(ImgUrl)) > 0) or
         (Pos('.gif', LowerCase(ImgUrl)) > 0) then
        Continue;

      P := TProcess.Create(nil);
      try
        P.Executable := 'curl';
        P.Parameters.Add('-s');
        P.Parameters.Add('-L');
        P.Parameters.Add('--connect-timeout');
        P.Parameters.Add('5');
        P.Parameters.Add('--max-time');
        P.Parameters.Add('10');
        P.Parameters.Add('-o');
        P.Parameters.Add(ACachePath);
        P.Parameters.Add(ImgUrl);
        P.Options := [poWaitOnExit];
        try
          P.Execute;
          if (P.ExitStatus = 0) and FileExists(ACachePath) then
          begin
            // Verify it's a real image by checking file size (> 2KB)
            if FindFirst(ACachePath, faAnyFile, SearchRec) = 0 then
            begin
              if SearchRec.Size > 2048 then
              begin
                Result := True;
                FindClose(SearchRec);
                Break;
              end;
              FindClose(SearchRec);
            end;
          end;
        except
        end;
      finally
        P.Free;
      end;
    end;
  finally
    Candidates.Free;
  end;
  end;
end;

// ============================================================================
// Steam Store API cover lookup (no authentication required)
// ============================================================================



function TGamesTabHelper.SearchSteamStoreGame(const AGameName: string; out AAppId: string): Boolean;

  function TrySingleSearch(const Term: string; out FoundId: string): Boolean;
  var
    Url, JsonStr: string;
    P: TProcess;
    S: TStringList;
    JData: TJSONData;
    JArray: TJSONArray;
    i: Integer;
    ItemObj: TJSONObject;
  begin
    Result := False;
    FoundId := '';

    Url := 'https://store.steampowered.com/api/storesearch/?term=' +
           StringReplace(Term, ' ', '%20', [rfReplaceAll]) +
           '&l=english&cc=US';

    P := TProcess.Create(nil);
    S := TStringList.Create;
    try
      P.Executable := 'curl';
      P.Parameters.Add('-s');
      P.Parameters.Add('-L');
      P.Parameters.Add('--connect-timeout');
      P.Parameters.Add('5');
      P.Parameters.Add('--max-time');
      P.Parameters.Add('10');
      P.Parameters.Add('-H');
      P.Parameters.Add('Accept: application/json');
      P.Parameters.Add(Url);
      P.Options := [poUsePipes, poWaitOnExit];
      try
        P.Execute;
        S.LoadFromStream(P.Output);
        JsonStr := S.Text;
      except
        Exit;
      end;
    finally
      P.Free;
      S.Free;
    end;

    if JsonStr = '' then Exit;

    try
      JData := GetJSON(JsonStr);
      try
        if not (JData is TJSONObject) then Exit;
        JArray := TJSONArray(JData.FindPath('items'));
        if not Assigned(JArray) or (JArray.Count = 0) then Exit;

        for i := 0 to JArray.Count - 1 do
        begin
          if JArray.Items[i] is TJSONObject then
          begin
            ItemObj := TJSONObject(JArray.Items[i]);
            FoundId := IntToStr(ItemObj.Get('id', 0));
            if FoundId <> '0' then
            begin
              Result := True;
              Break;
            end;
          end;
        end;
      finally
        JData.Free;
      end;
    except
      Exit;
    end;
  end;

var
  CleanName, TryName: string;
  Names: TStringList;
  i, p: Integer;
begin
  with FForm do
  begin
  Result := False;
  AAppId := '';

  Names := TStringList.Create;
  try
    // 1. Original name (exact folder name)
    Names.Add(AGameName);

    // 2. Cleaned name (CamelCase -> spaces, etc.)
    CleanName := CleanGameNameForSearch(AGameName);
    if Names.IndexOf(CleanName) < 0 then
      Names.Add(CleanName);

    // 3. Without common edition/suffix markers
    TryName := CleanName;
    TryName := StringReplace(TryName, 'Enhanced', '', [rfReplaceAll, rfIgnoreCase]);
    TryName := StringReplace(TryName, 'Definitive Edition', '', [rfReplaceAll, rfIgnoreCase]);
    TryName := StringReplace(TryName, 'Remastered', '', [rfReplaceAll, rfIgnoreCase]);
    TryName := StringReplace(TryName, 'Remake', '', [rfReplaceAll, rfIgnoreCase]);
    TryName := StringReplace(TryName, 'GOTY', '', [rfReplaceAll, rfIgnoreCase]);
    TryName := StringReplace(TryName, 'Game of the Year', '', [rfReplaceAll, rfIgnoreCase]);
    TryName := StringReplace(TryName, 'Deluxe', '', [rfReplaceAll, rfIgnoreCase]);
    TryName := StringReplace(TryName, 'Standard', '', [rfReplaceAll, rfIgnoreCase]);
    TryName := StringReplace(TryName, 'Complete', '', [rfReplaceAll, rfIgnoreCase]);
    TryName := StringReplace(TryName, 'Ultimate', '', [rfReplaceAll, rfIgnoreCase]);
    TryName := Trim(TryName);
    if (TryName <> '') and (TryName <> CleanName) and (Names.IndexOf(TryName) < 0) then
      Names.Add(TryName);

    // 4. Without subtitle (after " - " or ": ")
    p := Pos(' - ', CleanName);
    if p > 0 then
    begin
      TryName := Trim(Copy(CleanName, 1, p - 1));
      if (TryName <> '') and (Names.IndexOf(TryName) < 0) then
        Names.Add(TryName);
    end;
    p := Pos(': ', CleanName);
    if p > 0 then
    begin
      TryName := Trim(Copy(CleanName, 1, p - 1));
      if (TryName <> '') and (Names.IndexOf(TryName) < 0) then
        Names.Add(TryName);
    end;

    // 5. First significant word (for very long concatenated names)
    if Length(CleanName) > 20 then
    begin
      p := Pos(' ', CleanName);
      if (p > 3) and (p < 15) then
      begin
        TryName := Trim(Copy(CleanName, 1, p - 1));
        if (TryName <> '') and (Names.IndexOf(TryName) < 0) then
          Names.Add(TryName);
      end;
    end;

    // Try each variant until one succeeds
    for i := 0 to Names.Count - 1 do
    begin
      if TrySingleSearch(Names[i], AAppId) then
      begin
        Result := True;
        Exit;
      end;
    end;
  finally
    Names.Free;
  end;
  end;
end;



function TGamesTabHelper.DownloadSteamCover(const AAppId, ACachePath: string): Boolean;
var
  ImgUrl: string;
  P: TProcess;
begin
  with FForm do
  begin
  Result := False;
  if AAppId = '' then Exit;

  ImgUrl := 'https://steamcdn-a.akamaihd.net/steam/apps/' + AAppId + '/library_600x900.jpg';

  ForceDirectories(ExtractFilePath(ACachePath));
  P := TProcess.Create(nil);
  try
    P.Executable := 'curl';
    P.Parameters.Add('-s');
    P.Parameters.Add('-L');
    P.Parameters.Add('--connect-timeout');
    P.Parameters.Add('5');
    P.Parameters.Add('--max-time');
    P.Parameters.Add('10');
    P.Parameters.Add('-o');
    P.Parameters.Add(ACachePath);
    P.Parameters.Add(ImgUrl);
    P.Options := [poWaitOnExit];
    try
      P.Execute;
      Result := (P.ExitStatus = 0) and FileExists(ACachePath);
    except
      Result := False;
    end;
  finally
    P.Free;
  end;
  end;
end;



procedure TGamesTabHelper.ShowGameThumb(ACard: TPanel);
var
  i: Integer;
  Img: TImage;
  Bmp: TBitmap;
begin
  with FForm do
  begin
  if ACard = nil then Exit;

  // Find the TImage child of the selected game card
  Img := nil;
  for i := 0 to ACard.ControlCount - 1 do
    if ACard.Controls[i] is TImage then
    begin
      Img := TImage(ACard.Controls[i]);
      Break;
    end;

  FreeAndNil(FGameThumbBmp);

  if Assigned(Img) and Assigned(Img.Picture.Graphic) and
     (Img.Picture.Graphic.Width > 0) then
  begin
    Bmp := TBitmap.Create;
    try
      Bmp.SetSize(Img.Picture.Graphic.Width, Img.Picture.Graphic.Height);
      Bmp.Canvas.Draw(0, 0, Img.Picture.Graphic);
      FGameThumbBmp := Bmp;
    except
      Bmp.Free;
    end;
  end;

  goverlayPaintBox.Invalidate;
  end;
end;



procedure TGamesTabHelper.LoadGlobalThumb;
var
  ImgPath: string;
begin
  with FForm do
  begin
  FreeAndNil(FGameThumbBmp);
  // Load global icon only once
  if not Assigned(FGlobalThumbPng) then
  begin
    ImgPath := GetAppBaseDir + 'assets/icons/global-white.png';
    if FileExists(ImgPath) then
    begin
      FGlobalThumbPng := TPortableNetworkGraphic.Create;
      try
        FGlobalThumbPng.LoadFromFile(ImgPath);
      except
        FreeAndNil(FGlobalThumbPng);
      end;
    end;
  end;
  goverlayPaintBox.Invalidate;
  end;
end;



procedure TGamesTabHelper.ApplyCardBrightness(ACard: TPanel; BrightFactor: Integer);
var
  CardIdx, CtrlIdx: Integer;
  OrigIntf, DimIntf: TLazIntfImage;
  Img: TImage;
  DimBmp: TBitmap;
  SrcRow, DstRow: PByte;
  W, H, Stride, BPP, x, y, px: Integer;
begin
  with FForm do
  begin
  if not Assigned(FCardPanels) or not Assigned(FOrigCovers) then Exit;
  CardIdx := FCardPanels.IndexOf(ACard);
  if (CardIdx < 0) or (CardIdx >= FOrigCovers.Count) then Exit;
  OrigIntf := TLazIntfImage(FOrigCovers[CardIdx]);
  if OrigIntf = nil then Exit;
  if (ACard.ControlCount = 0) then Exit;
  Img := nil;
  for CtrlIdx := 0 to ACard.ControlCount - 1 do
    if (ACard.Controls[CtrlIdx] is TImage) and (ACard.Controls[CtrlIdx].Tag = 9995) then
    begin
      Img := TImage(ACard.Controls[CtrlIdx]);
      Break;
    end;
  if Img = nil then
  begin
    for CtrlIdx := 0 to ACard.ControlCount - 1 do
      if (ACard.Controls[CtrlIdx] is TImage) and (ACard.Controls[CtrlIdx].Tag <> 9990) then
      begin
        Img := TImage(ACard.Controls[CtrlIdx]);
        Break;
      end;
  end;
  if Img = nil then Exit;

  W      := OrigIntf.Width;
  H      := OrigIntf.Height;
  Stride := OrigIntf.DataDescription.BytesPerLine;
  BPP    := OrigIntf.DataDescription.BitsPerPixel div 8;

  DimIntf := TLazIntfImage.Create(W, H);
  DimIntf.DataDescription := OrigIntf.DataDescription;
  DimIntf.CreateData;
  try
    for y := 0 to H - 1 do
    begin
      SrcRow := OrigIntf.PixelData + PtrUInt(y * Stride);
      DstRow := DimIntf.PixelData  + PtrUInt(y * Stride);
      for x := 0 to W - 1 do
      begin
        px := x * BPP;
        DstRow[px]   := Byte(Integer(SrcRow[px])   * BrightFactor div 100);
        DstRow[px+1] := Byte(Integer(SrcRow[px+1]) * BrightFactor div 100);
        DstRow[px+2] := Byte(Integer(SrcRow[px+2]) * BrightFactor div 100);
        if BPP >= 4 then
          DstRow[px+3] := SrcRow[px+3];
      end;
    end;
    DimBmp := TBitmap.Create;
    try
      DimBmp.LoadFromIntfImage(DimIntf);
      Img.Picture.Bitmap.Assign(DimBmp);
      Img.Invalidate;
    finally
      DimBmp.Free;
    end;
  finally
    DimIntf.Free;
  end;
  end;
end;



procedure TGamesTabHelper.ApplyAllCardsDim;
var
  i: Integer;
begin
  with FForm do
  begin
  if not Assigned(FCardPanels) then Exit;
  for i := 0 to FCardPanels.Count - 1 do
    ApplyCardBrightness(TPanel(FCardPanels[i]), 100);
  FHoveredCard     := nil;
  FHoverBrightness := 0;
  end;
end;



procedure TGamesTabHelper.GameCardClick(Sender: TObject);
var
  Panel: TPanel;
  GameName, GameCfgDir, FGOrig: string;
  Lines: TStringList;
  p: Integer;
begin
  with FForm do
  begin
  if Sender is TPanel then Panel := TPanel(Sender)
  else if Sender is TImage then Panel := TPanel(TImage(Sender).Parent)
  else if Sender is TLabel then Panel := TPanel(TLabel(Sender).Parent)
  else Exit;

  // Extract game name from card hint
  Lines := TStringList.Create;
  try
    Lines.Text := Panel.Hint;
    if Lines.Count < 1 then Exit;
    GameName := Lines[0];
  finally
    Lines.Free;
  end;

  FActiveGameIsNonSteam := False;
  if (Length(GameName) > 0) and (GameName[1] = '(') then
  begin
    p := Pos(') ', GameName);
    if p > 0 then
      GameName := Copy(GameName, p + 2, Length(GameName));
  end
  else
    FActiveGameIsNonSteam := True;

  FActiveGameName := GameName;
  ShowGameThumb(Panel);
  LoadGameToggleStates;

  // Navigate directly to MangoHud game config
  GameCfgDir := GetGameConfigDir(GameName);
  if not DirectoryExists(GameCfgDir) then
    ForceDirectories(GameCfgDir);
  // Copy only the launch scripts — OptiScaler files are copied only when the
  // OptiScaler toggle is explicitly enabled for this game.
  // Copy scripts without overwriting — user config lives inside fgmod.
  // Then patch the script body for OptiScaler conditional if needed.
  FGOrig := IncludeTrailingPathDelimiter(GetFGModOriginalPath);
  ExecuteShellCommand('cp -f ' + QuotedStr(FGOrig + 'bgmod') + ' ' +
    QuotedStr(GameCfgDir + 'bgmod') + ' 2>/dev/null && chmod 755 ' +
    QuotedStr(GameCfgDir + 'bgmod'));
  ExecuteShellCommand('cp -f ' + QuotedStr(FGOrig + 'bgmod-uninstaller') + ' ' +
    QuotedStr(GameCfgDir + 'bgmod-uninstaller') + ' 2>/dev/null && chmod 755 ' +
    QuotedStr(GameCfgDir + 'bgmod-uninstaller'));
  ExecuteShellCommand('ln -sf bgmod ' + QuotedStr(GameCfgDir + 'fgmod') + ' 2>/dev/null');
  EnsureGameFGModOptiScalerConditional(GameCfgDir + 'bgmod');
  MANGOHUDCFGFILE := GameCfgDir + 'MangoHud.conf';
  UpdateGameContextLabel;
  SetNavActive(1);
  goverlayPageControl.ShowTabs := True;
  vkbasalttabsheet.TabVisible  := False;
  optiscalertabsheet.TabVisible := False;
  tweakstabsheet.TabVisible    := False;
  gamesTabSheet.TabVisible     := False;
  goverlayPageControl.ActivePage := presetTabsheet;
  notificationLabel.Visible := False;
  commandPanel.Visible       := False;

  goverlaybarPanel.Visible  := True;
  popupBitBtn.Visible := True;
  FPreviewBtn.Visible  := True;
  UpdateGeSpeedButtonState;
  UpdateGlobalEnableMenuItemVisibility;
  LoadMangoHudConfig;
  end;
end;



procedure TGamesTabHelper.GameCardUninstallClick(Sender: TObject);
var
  Panel: TPanel;
  GameName, GameCfgDir, GamePath, UninstallerPath: string;
  Lines: TStringList;
  i: Integer;
begin
  with FForm do
  begin
  Panel := FRightClickedCard;
  if Panel = nil then Exit;

  // Extract game name and install path from Hint:
  // '(AppID) GameName' + LineEnding + 'LibPath/common/InstallDir'
  Lines := TStringList.Create;
  try
    if Panel.Hint = '' then Exit;
    Lines.Text := Panel.Hint;
    if Lines.Count < 2 then Exit;
    i := Pos(') ', Lines[0]);
    if i > 0 then
      GameName := Copy(Lines[0], i + 2, MaxInt)
    else
      GameName := Lines[0];
    GamePath := Lines[1];
  finally
    Lines.Free;
  end;

  if GameName = '' then Exit;

  GameCfgDir := GetGameConfigDir(GameName);

  // Recursively delete the GOverlay game config directory
  if DirectoryExists(GameCfgDir) then
    DeleteDirectory(GameCfgDir, False);

  // Remove all OptiScaler/FGMod files from the game's install directory.
  // The fgmod-uninstaller.sh script is copied to the game's exe folder on first
  // launch. We locate it to discover the correct target directory, then perform
  // the same cleanup the script would do (but directly, since the script expects
  // to be invoked by Steam with the game's exe as argument).
  if (GamePath <> '') and DirectoryExists(GamePath) then
  begin
    GamePath := IncludeTrailingPathDelimiter(GamePath);
    UninstallerPath := FindFileInDir(GamePath, 'bgmod-uninstaller');
    if UninstallerPath = '' then
      UninstallerPath := FindFileInDir(GamePath, 'bgmod-uninstaller.sh');
    if UninstallerPath = '' then
      UninstallerPath := FindFileInDir(GamePath, 'fgmod-uninstaller.sh');
    if UninstallerPath <> '' then
      RunFGModUninstallCommands(ExtractFilePath(UninstallerPath), GameName)
    else
      RunFGModUninstallCommands(GamePath, GameName);
  end;

  // Remove badge controls from the card panel.
  // Cover image has Proportional=False; badge images have Proportional=True.
  for i := Panel.ControlCount - 1 downto 0 do
  begin
    if Panel.Controls[i] is TImage then
    begin
      if TImage(Panel.Controls[i]).Proportional then
        Panel.Controls[i].Free;
    end
    else if (Panel.Controls[i] is TShape) or (Panel.Controls[i] is TLabel) then
      Panel.Controls[i].Free;
  end;

  // Reset badge mask
  Panel.Tag := 0;

  SendNotification('Goverlay', 'Changes uninstalled for ' + GameName, GetIconFile);
  end;
end;



procedure TGamesTabHelper.GameCardMouseEnter(Sender: TObject);
var
  Panel: TPanel;
  j: Integer;
begin
  with FForm do
  begin
  DbgLog('GameCardMouseEnter: ' + TControl(Sender).Name);
  Panel := GetCardPanel(TControl(Sender));
  if Panel = nil then Exit;

  if Sender is TControl then
    TControl(Sender).Cursor := crHandPoint;

  if Panel = FHoveredCard then
  begin
    // Re-entering same card (e.g. from child control): ensure brightening
    FHoverDir := 1;
    if Assigned(FHoverTimer) and not FHoverTimer.Enabled then
      FHoverTimer.Enabled := True;
    Exit;
  end;

  // Snap previous hovered card back to dim and restore its size instantly.
  if Assigned(FHoveredCard) then
  begin
    ApplyCardBrightness(FHoveredCard, 100);
    for j := 0 to FHoveredCard.ControlCount - 1 do
      if FHoveredCard.Controls[j].Tag = 9990 then
      begin
        FHoveredCard.Controls[j].Visible := False;
        Break;
      end;
    FHoveredCard.SetBounds(
      FHoveredCard.Left + (FHoveredCard.Width - CARD_W) div 2,
      FHoveredCard.Top  + (FHoveredCard.Height - CARD_H) div 2,
      CARD_W, CARD_H);
    for j := 0 to FHoveredCard.ControlCount - 1 do
      if (FHoveredCard.Controls[j] is TImage) and (FHoveredCard.Controls[j].Tag <> 9990) then
      begin
        TImage(FHoveredCard.Controls[j]).SetBounds(0, 0, CARD_W, CARD_H);
        if FHoveredCard.Controls[j].Tag = 9995 then Break;
      end;
  end;

  FHoveredCard     := Panel;
  FHoverBrightness := 0;
  FHoverDir        := 1;
  FHoverBaseLeft   := Panel.Left;
  FHoverBaseTop    := Panel.Top;

  if Panel.Tag <> 9998 then
    for j := 0 to Panel.ControlCount - 1 do
      if Panel.Controls[j].Tag = 9990 then
      begin
        Panel.Controls[j].Visible := True;
        Panel.Controls[j].BringToFront;
        Break;
      end;

  // Smooth scale-up is driven by HoverTimerTick; just bring to front now
  Panel.BringToFront;

  if not Assigned(FHoverTimer) then
  begin
    FHoverTimer          := TTimer.Create(FForm);
    FHoverTimer.Interval := 16;
    FHoverTimer.OnTimer  := @HoverTimerTick;
  end;
  FHoverTimer.Enabled := True;
  end;
end;



procedure TGamesTabHelper.GameCardMouseLeave(Sender: TObject);
var
  Panel: TPanel;
  j: Integer;
  Pt: TPoint;
begin
  with FForm do
  begin
  DbgLog('GameCardMouseLeave: ' + TControl(Sender).Name);
  Panel := GetCardPanel(TControl(Sender));
  if Panel = nil then Exit;

  if Panel <> FHoveredCard then
  begin
    DbgLog('GameCardMouseLeave: not hovered card, ignoring');
    Exit;
  end;

  if Assigned(FHoveredCard) then
  begin
    Pt := FHoveredCard.ScreenToClient(Mouse.CursorPos);
    if (Pt.X >= 0) and (Pt.Y >= 0) and (Pt.X < FHoveredCard.Width) and (Pt.Y < FHoveredCard.Height) then
      Exit;
  end;

  for j := 0 to Panel.ControlCount - 1 do
    if Panel.Controls[j].Tag = 9990 then
    begin
      Panel.Controls[j].Visible := False;
      Break;
    end;

  // Smooth shrink-back is driven by HoverTimerTick
  FHoverDir := -1;
  if Assigned(FHoverTimer) then
    FHoverTimer.Enabled := True;
  end;
end;



procedure TGamesTabHelper.GameCardMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Panel: TPanel;
begin
  with FForm do
  begin
  if Button <> mbRight then Exit;

  if Sender is TPanel then
    Panel := TPanel(Sender)
  else if Sender is TImage then
    Panel := TPanel(TImage(Sender).Parent)
  else if Sender is TLabel then
    Panel := TPanel(TLabel(Sender).Parent)
  else
    Exit;

  FRightClickedCard := Panel;

  if Panel.Tag = 9998 then
  begin
    ShowRemoveFoldersMenu(Sender, X, Y);
    Exit;
  end;

  // Context menu on right-click is disabled; all actions are accessed exclusively via the floating button.
  end;
end;



function TGamesTabHelper.GetCardPanel(AControl: TControl): TPanel;
var
  Curr: TControl;
begin
  Result := nil;
  Curr := AControl;
  while Assigned(Curr) do
  begin
    if (Curr is TPanel) and Assigned(FForm.FGamesPanel) and (Curr.Parent = FForm.FGamesPanel) then
    begin
      Result := TPanel(Curr);
      Exit;
    end;
    Curr := Curr.Parent;
  end;
end;


procedure TGamesTabHelper.ActionPanelPaint(Sender: TObject);
var
  Panel: TPanel;
  cx, cy: Integer;
begin
  if not (Sender is TPanel) then Exit;
  Panel := TPanel(Sender);
  cx := Panel.Width div 2;
  cy := Panel.Height div 2;

  with Panel.Canvas do
  begin
    // Drop shadow (black) for contrast against cover art
    Brush.Color := clBlack;
    Brush.Style := bsSolid;
    Pen.Style := psClear;
    Rectangle(cx, cy - 5, cx + 3, cy - 2);
    Rectangle(cx, cy, cx + 3, cy + 3);
    Rectangle(cx, cy + 5, cx + 3, cy + 8);

    // White dots
    Brush.Color := clWhite;
    Rectangle(cx - 1, cy - 6, cx + 2, cy - 3);
    Rectangle(cx - 1, cy - 1, cx + 2, cy + 2);
    Rectangle(cx - 1, cy + 4, cx + 2, cy + 7);
  end;
end;


procedure TGamesTabHelper.ActionPanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  Panel: TPanel;
begin
  if not (Sender is TPanel) then Exit;
  Panel := TPanel(Sender);
  Panel.Hint := 'Opções do jogo';
  Panel.ShowHint := True;
end;


procedure TGamesTabHelper.ActionPanelClick(Sender: TObject);
var
  Panel, CardPanel: TPanel;
  Pt: TPoint;
begin
  if not (Sender is TPanel) then Exit;
  Panel := TPanel(Sender);
  CardPanel := GetCardPanel(Panel);
  if not Assigned(CardPanel) then Exit;

  with FForm do
  begin
    FRightClickedCard := CardPanel;
    if Assigned(FOpenPrefixMenuItem) then
      FOpenPrefixMenuItem.Visible :=
        (CardPanel.Hint <> '') and (CardPanel.Hint[1] = '(');

    Pt := Panel.ClientToScreen(Point(Panel.Width div 2, Panel.Height div 2));
    FGameCardMenu.PopUp(Pt.X, Pt.Y);
  end;
end;


procedure TGamesTabHelper.CreateActionPanel(CardPanel: TPanel);
var
  ActionPanel: TPanel;
  j: Integer;
begin
  with FForm do
  begin
  if not Assigned(CardPanel) then Exit;

  ActionPanel := TPanel.Create(CardPanel);
  ActionPanel.Parent := CardPanel;
  ActionPanel.SetBounds(CARD_W - 32, CARD_H - 32, 26, 26);
  ActionPanel.BevelOuter := bvNone;
  ActionPanel.BevelInner := bvNone;
  ActionPanel.BorderWidth := 0;
  ActionPanel.ParentColor := True;
  ActionPanel.ParentBackground := True;
  ActionPanel.Tag := 9990;
  ActionPanel.Visible := False;
  ActionPanel.OnPaint := @ActionPanelPaint;
  ActionPanel.OnMouseMove := @ActionPanelMouseMove;
  ActionPanel.OnClick := @ActionPanelClick;
  ActionPanel.OnMouseEnter := @GameCardMouseEnter;
  ActionPanel.OnMouseLeave := @GameCardMouseLeave;

  for j := 0 to CardPanel.ControlCount - 1 do
    if (CardPanel.Controls[j] is TImage) and (CardPanel.Controls[j].Tag = 9995) then
    begin
      TImage(CardPanel.Controls[j]).SendToBack;
      Break;
    end;
  end;
end;


procedure TGamesTabHelper.GameHoverFolderClick(Sender: TObject);
var
  Panel: TPanel;
begin
  Panel := GetCardPanel(TControl(Sender));
  if Assigned(Panel) then
  begin
    FForm.FRightClickedCard := Panel;
    GameCardOpenFolderClick(Sender);
  end;
end;


procedure TGamesTabHelper.GameHoverPrefixClick(Sender: TObject);
var
  Panel: TPanel;
begin
  Panel := GetCardPanel(TControl(Sender));
  if Assigned(Panel) then
  begin
    FForm.FRightClickedCard := Panel;
    GameCardOpenPrefixClick(Sender);
  end;
end;


procedure TGamesTabHelper.GameHoverUninstallClick(Sender: TObject);
var
  Panel: TPanel;
begin
  Panel := GetCardPanel(TControl(Sender));
  if Assigned(Panel) then
  begin
    FForm.FRightClickedCard := Panel;
    GameCardUninstallClick(Sender);
  end;
end;


procedure TGamesTabHelper.GameCardOpenFolderClick(Sender: TObject);
var
  Panel: TPanel;
  GamePath: string;
  Lines: TStringList;
begin
  with FForm do
  begin
  Panel := FRightClickedCard;
  if Panel = nil then Exit;

  Lines := TStringList.Create;
  try
    Lines.Text := Panel.Hint;
    if Lines.Count >= 2 then
      GamePath := Lines[1]
    else
      Exit;
  finally
    Lines.Free;
  end;

  if DirectoryExists(GamePath) then
    ExecuteShellCommand('xdg-open ' + QuotedStr(GamePath));
  end;
end;



procedure TGamesTabHelper.GameCardOpenPrefixClick(Sender: TObject);
var
  Panel: TPanel;
  GamePath: string;
  PrefixPath: string;
  Lines: TStringList;
  AppID: string;
  p: Integer;
begin
  with FForm do
  begin
  Panel := FRightClickedCard;
  if Panel = nil then Exit;

  Lines := TStringList.Create;
  try
    Lines.Text := Panel.Hint;
    if Lines.Count >= 2 then
    begin
      AppID := '';
      if (Length(Lines[0]) > 0) and (Lines[0][1] = '(') then
      begin
        p := Pos(') ', Lines[0]);
        if p > 0 then
          AppID := Copy(Lines[0], 2, p - 2);
      end;
      
      GamePath := Lines[1];
    end
    else
      Exit;
  finally
    Lines.Free;
  end;

  if AppID <> '' then
  begin
    p := Pos('/common/', GamePath);
    if p > 0 then
    begin
      PrefixPath := Copy(GamePath, 1, p - 1) + '/compatdata/' + AppID + '/pfx';
      if DirectoryExists(PrefixPath) then
        ExecuteShellCommand('xdg-open ' + QuotedStr(PrefixPath));
    end;
  end;
  end;
end;



procedure TGamesTabHelper.AddNonSteamFolderClick(Sender: TObject);
var
  FolderDlg: TSelectDirectoryDialog;
  NonSteamFile, SelectedDir: string;
  Lines: TStringList;
  I: Integer;
begin
  with FForm do
  begin
  NonSteamFile := GetUserDir + '.config/goverlay/nonsteam_folders.txt';

  FolderDlg := TSelectDirectoryDialog.Create(FForm);
  try
    FolderDlg.Title := 'Select a non-Steam game folder';
    if not FolderDlg.Execute then Exit;
    SelectedDir := FolderDlg.FileName;
  finally
    FolderDlg.Free;
  end;

  // Prevent duplicates
  if FileExists(NonSteamFile) then
  begin
    Lines := TStringList.Create;
    try
      Lines.LoadFromFile(NonSteamFile);
      for I := 0 to Lines.Count - 1 do
        if Trim(Lines[I]) = SelectedDir then
        begin
          ShowMessage('This folder has already been added.');
          Exit;
        end;
    finally
      Lines.Free;
    end;
  end;

  // Append to list
  ForceDirectories(ExtractFilePath(NonSteamFile));
  Lines := TStringList.Create;
  try
    if FileExists(NonSteamFile) then
      Lines.LoadFromFile(NonSteamFile);
    Lines.Add(SelectedDir);
    Lines.SaveToFile(NonSteamFile);
  finally
    Lines.Free;
  end;

  Application.QueueAsyncCall(@RefreshGameCardsAsync, 0);
  end;
end;



procedure TGamesTabHelper.RemoveFolderMenuItemClick(Sender: TObject);
var
  FolderPath: string;
  NonSteamFile: string;
  Lines: TStringList;
  I: Integer;
begin
  with FForm do
  begin
  if not (Sender is TMenuItem) then Exit;
  FolderPath := TMenuItem(Sender).Caption;
  if FolderPath = '' then Exit;

  // Ask user if they want to remove that folder
  if MessageDlg('Remove non-Steam folder', 
                'Are you sure you want to remove the folder "' + FolderPath + '" from Goverlay?', 
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    NonSteamFile := GetUserDir + '.config/goverlay/nonsteam_folders.txt';
    Lines := TStringList.Create;
    try
      if FileExists(NonSteamFile) then
      begin
        Lines.LoadFromFile(NonSteamFile);
        for I := Lines.Count - 1 downto 0 do
        begin
          if Trim(Lines[I]) = FolderPath then
            Lines.Delete(I);
        end;
        Lines.SaveToFile(NonSteamFile);
      end;
    finally
      Lines.Free;
    end;

    // Refresh the game cards grid immediately!
    RefreshGameCards;
  end;
  end;
end;



procedure TGamesTabHelper.ShowRemoveFoldersMenu(Sender: TObject; X, Y: Integer);
var
  Pt: TPoint;
  NonSteamFile: string;
  Lines: TStringList;
  I: Integer;
  RemoveParent: TMenuItem;
  SubItem: TMenuItem;
  FolderPath: string;
begin
  with FForm do
  begin
  if not Assigned(FRemoveFoldersMenu) then
    FRemoveFoldersMenu := TPopupMenu.Create(FForm)
  else
    FRemoveFoldersMenu.Items.Clear;

  NonSteamFile := GetUserDir + '.config/goverlay/nonsteam_folders.txt';
  Lines := TStringList.Create;
  try
    if FileExists(NonSteamFile) then
      Lines.LoadFromFile(NonSteamFile);

    // Parent item: "Remove nonsteam folders"
    RemoveParent := TMenuItem.Create(FRemoveFoldersMenu);
    RemoveParent.Caption := 'Remove nonsteam folders';
    FRemoveFoldersMenu.Items.Add(RemoveParent);

    // Check if there are any folders to remove
    if Lines.Count = 0 then
    begin
      SubItem := TMenuItem.Create(FRemoveFoldersMenu);
      SubItem.Caption := '(No folders found)';
      SubItem.Enabled := False;
      RemoveParent.Add(SubItem);
    end
    else
    begin
      for I := 0 to Lines.Count - 1 do
      begin
        FolderPath := Trim(Lines[I]);
        if FolderPath = '' then Continue;
        
        SubItem := TMenuItem.Create(FRemoveFoldersMenu);
        SubItem.Caption := FolderPath;
        SubItem.OnClick := @RemoveFolderMenuItemClick;
        RemoveParent.Add(SubItem);
      end;
    end;
  finally
    Lines.Free;
  end;

  Pt := TControl(Sender).ClientToScreen(Point(X, Y));
  FRemoveFoldersMenu.PopUp(Pt.X, Pt.Y);
  end;
end;



procedure TGamesTabHelper.GamesScrollBoxResize(Sender: TObject);
begin
  with FForm do
  begin
  if FGamesLoaded then
    ReflowGamesGrid;
  end;
end;



procedure TGamesTabHelper.GamesEmptySpaceClick(Sender: TObject);
begin
  with FForm do
  begin
  // Clicking empty space in the games grid
  if FActiveGameName <> '' then
  begin
    FActiveGameName := '';
    MANGOHUDCFGFILE := IncludeTrailingPathDelimiter(GetMangoHudConfigDir()) + 'MangoHud.conf';
    VKBASALTCFGFILE := IncludeTrailingPathDelimiter(GetVkBasaltConfigDir()) + 'vkBasalt.conf';
    VKSUMICFGFILE := IncludeTrailingPathDelimiter(GetVkSumiConfigDir()) + 'vkSumi.conf';
    UpdateGameContextLabel;
    HideGameThumb;
    LoadGameToggleStates;  // reset all tools to enabled, hide toggles
  end;
  end;
end;



procedure TGamesTabHelper.RunFGModUninstallCommands(const ATargetDir, AGameName: string);
var
  Dir: string;
  LogDir, LogFile: string;

  procedure Log(const Msg: string);
  var
    F: TextFile;
    LogMsg: string;
  begin
    LogMsg := FormatDateTime('yyyy-MM-dd hh:nn:ss', Now) + ' - ' + Msg;
    DbgLog('bgmod-uninstaller: ' + Msg);

    // 1. Write to /tmp/bgmod-uninstaller.log
    try
      AssignFile(F, '/tmp/bgmod-uninstaller.log');
      if FileExists('/tmp/bgmod-uninstaller.log') then Append(F) else Rewrite(F);
      WriteLn(F, LogMsg);
      CloseFile(F);
    except
    end;

    // 2. Write to Game directory bgmod-uninstaller.log
    if Dir <> '' then
    begin
      try
        AssignFile(F, Dir + 'bgmod-uninstaller.log');
        if FileExists(Dir + 'bgmod-uninstaller.log') then Append(F) else Rewrite(F);
        WriteLn(F, LogMsg);
        CloseFile(F);
      except
      end;
    end;

    // 3. Write to central GOverlay logs directory
    if LogFile <> '' then
    begin
      try
        if not DirectoryExists(LogDir) then
          ForceDirectories(LogDir);
        AssignFile(F, LogFile);
        if FileExists(LogFile) then Append(F) else Rewrite(F);
        WriteLn(F, LogMsg);
        CloseFile(F);
      except
      end;
    end;
  end;

  procedure SafeCleanOrRestore(const FileName: string; IsOriginalGameFile: Boolean);
  var
    FullFile, FullBackup: string;
  begin
    FullFile := Dir + FileName;
    FullBackup := FullFile + '.b';
    
    if FileExists(FullBackup) then
    begin
      try
        if FileExists(FullFile) then
          DeleteFile(FullFile);
        if RenameFile(FullBackup, FullFile) then
          Log('Restored original ' + FileName)
        else
          Log('Failed to restore ' + FileName);
      except
        on E: Exception do
          Log('Exception restoring ' + FileName + ': ' + E.Message);
      end;
    end
    else if not IsOriginalGameFile then
    begin
      if FileExists(FullFile) then
      begin
        try
          if DeleteFile(FullFile) then
            Log('Cleaned up file: ' + FullFile)
          else
            Log('Failed to delete file: ' + FullFile);
        except
          on E: Exception do
            Log('Exception deleting ' + FullFile + ': ' + E.Message);
        end;
      end;
    end;
  end;

var
  DataHome: string;
begin
  with FForm do
  begin
    Dir := IncludeTrailingPathDelimiter(ATargetDir);

    // Resolve central GOverlay logs directory
    LogDir := '';
    LogFile := '';
    if AGameName <> '' then
    begin
      DataHome := GetEnvironmentVariable('HOST_XDG_DATA_HOME');
      if DataHome = '' then DataHome := GetEnvironmentVariable('XDG_DATA_HOME');
      if DataHome = '' then DataHome := GetUserDir + '.local/share';
      LogDir := IncludeTrailingPathDelimiter(DataHome) + 'goverlay' + PathDelim + 'logs' + PathDelim + AGameName;
      LogFile := IncludeTrailingPathDelimiter(LogDir) + 'bgmod-uninstaller.log';
    end;

    Log('========================= bgmod GUI uninstaller initialization =========================');
    Log('Uninstaller location: ' + Dir);
    Log('Game name: ' + AGameName);

    // 1. Original game files: only restore if backup exists, NEVER delete if no backup
    SafeCleanOrRestore('d3dcompiler_47.dll', True);
    SafeCleanOrRestore('amd_fidelityfx_dx12.dll', True);
    SafeCleanOrRestore('amd_fidelityfx_framegeneration_dx12.dll', True);
    SafeCleanOrRestore('amd_fidelityfx_upscaler_dx12.dll', True);
    SafeCleanOrRestore('amd_fidelityfx_vk.dll', True);
    SafeCleanOrRestore('libxess.dll', True);
    SafeCleanOrRestore('libxess_dx11.dll', True);
    SafeCleanOrRestore('libxess_fg.dll', True);
    SafeCleanOrRestore('libxell.dll', True);
    SafeCleanOrRestore('nvngx.dll', True);
    SafeCleanOrRestore('nvngx_dlss.dll', True);
    SafeCleanOrRestore('nvngx_dlssd.dll', True);
    SafeCleanOrRestore('nvngx_dlssg.dll', True);

    // 2. Proxy / custom / wrapper files: safely delete if no backup, restore if backup exists
    SafeCleanOrRestore('OptiScaler.dll', False);
    SafeCleanOrRestore('dxgi.dll', False);
    SafeCleanOrRestore('winmm.dll', False);
    SafeCleanOrRestore('dbghelp.dll', False);
    SafeCleanOrRestore('version.dll', False);
    SafeCleanOrRestore('wininet.dll', False);
    SafeCleanOrRestore('winhttp.dll', False);
    SafeCleanOrRestore('OptiScaler.ini', False);
    SafeCleanOrRestore('OptiScaler.log', False);
    SafeCleanOrRestore('OptiScaler.asi', False);
    SafeCleanOrRestore('dlssg_to_fsr3_amd_is_better.dll', False);
    SafeCleanOrRestore('dlssg_to_fsr3.ini', False);
    SafeCleanOrRestore('dlssg_to_fsr3.log', False);
    SafeCleanOrRestore('nvapi64.dll', False);
    SafeCleanOrRestore('fakenvapi.ini', False);
    SafeCleanOrRestore('fakenvapi.log', False);
    SafeCleanOrRestore('fakenvapi.dll', False);
    SafeCleanOrRestore('nvngx.ini', False);
    SafeCleanOrRestore('dlss-enabler.dll', False);
    SafeCleanOrRestore('dlss-enabler-upscaler.dll', False);
    SafeCleanOrRestore('dlss-enabler.log', False);
    SafeCleanOrRestore('nvngx-wrapper.dll', False);
    SafeCleanOrRestore('_nvngx.dll', False);
    SafeCleanOrRestore('dlssg_to_fsr3_amd_is_better-3.0.dll', False);
    SafeCleanOrRestore('bgmod-uninstaller', False);
    SafeCleanOrRestore('MangoHud.conf', False);
    SafeCleanOrRestore('vkBasalt.conf', False);
    SafeCleanOrRestore('vkSumi.conf', False);

    // 3. Remove plugins folder
    if DirectoryExists(Dir + 'plugins') then
    begin
      DeleteDirectory(Dir + 'plugins', False);
      Log('Removed directory: ' + Dir + 'plugins');
    end;

    // 4. Remove wrappers and script configs
    if FileExists(Dir + 'bgmod') then begin DeleteFile(Dir + 'bgmod'); Log('Cleaned up file: ' + Dir + 'bgmod'); end;
    if FileExists(Dir + 'fgmod') then begin DeleteFile(Dir + 'fgmod'); Log('Cleaned up file: ' + Dir + 'fgmod'); end;
    if FileExists(Dir + 'bgmod-uninstaller.sh') then begin DeleteFile(Dir + 'bgmod-uninstaller.sh'); Log('Cleaned up file: ' + Dir + 'bgmod-uninstaller.sh'); end;
    if FileExists(Dir + 'bgmod-remover.sh') then begin DeleteFile(Dir + 'bgmod-remover.sh'); Log('Cleaned up file: ' + Dir + 'bgmod-remover.sh'); end;
    if FileExists(Dir + 'bgmod.conf') then begin DeleteFile(Dir + 'bgmod.conf'); Log('Cleaned up file: ' + Dir + 'bgmod.conf'); end;
    if FileExists(Dir + 'bgmod.log') then begin DeleteFile(Dir + 'bgmod.log'); Log('Cleaned up file: ' + Dir + 'bgmod.log'); end;

    Log('bgmod GUI uninstaller done.');
    
    // Note: bgmod-uninstaller.log is deleted last so it matches bgmod-uninstaller binary cleanup in target game folder
    if FileExists(Dir + 'bgmod-uninstaller.log') then DeleteFile(Dir + 'bgmod-uninstaller.log');
  end;
end;

// ============================================================================
// Game name cleaning for better store search matches
// ============================================================================



procedure TGamesTabHelper.CoverThreadTerminated(Sender: TObject);
begin
  with FForm do
  begin
  if Sender = FCoverThread then
    FCoverThread := nil;
  if Sender = FNonSteamCoverThread then
    FNonSteamCoverThread := nil;
  end;
end;



procedure TGamesTabHelper.RefreshGameCards;
var
  i: Integer;
begin
  with FForm do
  begin
  // Stop any running cover download thread (don't WaitFor — blocks UI)
  if Assigned(FCoverThread) then
  begin
    FCoverThread.Terminate;
    FCoverThread := nil;
  end;
  // Stop non-Steam cover download thread (don't WaitFor — blocks UI)
  if Assigned(FNonSteamCoverThread) then
  begin
    FNonSteamCoverThread.Terminate;
    FNonSteamCoverThread := nil;
  end;
  // Kill hover animation — FHoveredCard will point to a destroyed panel after
  // we free the card list, so we must clear it first to prevent a dangling-ptr crash.
  if Assigned(FHoverTimer) then
    FHoverTimer.Enabled := False;
  FHoveredCard     := nil;
  FHoverBrightness := 0;
  FHoverDir        := 0;
  // Flush any pending Synchronize calls before freeing panels
  CheckSynchronize;
  // Free all card panels — they own their children (CardImage, CardLabel, badges)
  // so a single Free call cleans up each card and all its sub-controls.
  if Assigned(FCardPanels) then
  begin
    for i := 0 to FCardPanels.Count - 1 do
      TPanel(FCardPanels[i]).Free;
    FCardPanels.Clear;
  end;
  // Free cached cover bitmaps
  if Assigned(FOrigCovers) then
  begin
    for i := 0 to FOrigCovers.Count - 1 do
      if FOrigCovers[i] <> nil then
        TLazIntfImage(FOrigCovers[i]).Free;
    FOrigCovers.Clear;
  end;
  // Rebuild the grid with up-to-date badge states
  LoadSteamGames;
  end;
end;

// ============================================================================
// Home tab
// ============================================================================



procedure TGamesTabHelper.RefreshGameCardsAsync(Data: PtrInt);
begin
  with FForm do
  begin
  RefreshGameCards;
  end;
end;


procedure TGamesTabHelper.ReflowGamesGrid;
var
  CardCount, CardsPerRow, TotalRows, i, CardX, CardY, RowMargin: Integer;
  Ctrl: TControl;
  WasHovered: TPanel;
begin
  with FForm do
  begin
  if not Assigned(FGamesScrollBox) or not Assigned(FGamesPanel) then
    Exit;
  // Skip reflow while games tab is not visible — avoids N×SetBounds on every tab switch
  if not gamesTabSheet.TabVisible then
  begin
    DbgLog('  ReflowGamesGrid SKIPPED (tab not visible)');
    Exit;
  end;

  Inc(FReflowCount);
  DbgLog(Format('  ReflowGamesGrid BEGIN #%d scrollW=%d', [FReflowCount, FGamesScrollBox.Width]));

  CardsPerRow := Max(1, FGamesScrollBox.Width div (CARD_W + CARD_MARGIN));
  RowMargin := (FGamesScrollBox.Width - CardsPerRow * CARD_W) div (CardsPerRow + 1);
  if RowMargin < 4 then RowMargin := 4;
  CardCount   := 0;

  // Completely clear hover state before reflow — prevents ChangeBounds loops
  WasHovered := FHoveredCard;
  FHoveredCard := nil;
  FHoverBrightness := 0;
  FHoverDir := 0;
  if Assigned(FHoverTimer) then
    FHoverTimer.Enabled := False;

  // Prevent LCL alignment loops while manually repositioning every card
  FInReflow := True;
  FGamesPanel.DisableAlign;
  try
    for i := 0 to FCardPanels.Count - 1 do
    begin
      Ctrl := TControl(FCardPanels[i]);
      if not (Ctrl is TPanel) then
        Continue;
      CardX := RowMargin + (CardCount mod CardsPerRow) * (CARD_W + RowMargin);
      CardY := RowMargin + (CardCount div CardsPerRow) * (CARD_H + RowMargin);
      // Only SetBounds if position actually changed (reduces LCL churn)
      if (Ctrl.Left <> CardX) or (Ctrl.Top <> CardY) or
         (Ctrl.Width <> CARD_W) or (Ctrl.Height <> CARD_H) then
      begin
        Ctrl.SetBounds(CardX, CardY, CARD_W, CARD_H);
        if (TPanel(Ctrl).ControlCount > 0) and (TPanel(Ctrl).Controls[0] is TImage) then
          TImage(TPanel(Ctrl).Controls[0]).SetBounds(0, 0, CARD_W, CARD_H);
      end;
      Inc(CardCount);
    end;

    if CardCount > 0 then
    begin
      TotalRows := (CardCount + CardsPerRow - 1) div CardsPerRow;
      // Use Width (not ClientWidth) so scrollbar appearance doesn't trigger a loop
      FGamesPanel.Width  := FGamesScrollBox.Width;
      FGamesPanel.Height := RowMargin + TotalRows * (CARD_H + RowMargin);
    end;
  finally
    FInReflow := False;
    FGamesPanel.EnableAlign;
    DbgLog(Format('  ReflowGamesGrid END   #%d', [FReflowCount]));
  end;

  end;
end;



procedure TGamesTabHelper.DrawCardRibbon(Bmp: TBitmap; BadgeMask: Integer);
const
  // Nerd Font glyphs — same as nav rail (rendered via 'Noto Sans' on this system)
  GLYPHS: array[0..3] of string = ('󱁥', '󰏘', '󰋮', '⚙');
  ICN_SZ  = 16;  // icon cell size
  ICN_GAP = 6;   // vertical gap between icons
  PAD_R   = 6;   // right margin from card edge
  PAD_T   = 5;   // top margin from card edge
  FONT_SZ = 13;  // glyph font size
var
  BC: TCanvas;
  BitIdx, Slot, IcoX, IcoY, DX, DY: Integer;
  G: string;
begin
  with FForm do
  begin
  BC := Bmp.Canvas;
  BC.Font.Name  := 'Noto Sans';
  BC.Font.Size  := FONT_SZ;
  BC.Font.Style := [];
  BC.Brush.Style := bsClear;

  IcoX := CARD_W - ICN_SZ - PAD_R;

  Slot := 0;
  for BitIdx := 0 to 3 do
  begin
    if (BadgeMask and (1 shl BitIdx)) = 0 then Continue;
    G    := GLYPHS[BitIdx];
    IcoY := PAD_T + Slot * (ICN_SZ + ICN_GAP);

    // Drop shadow (+2 offset, black)
    BC.Font.Color := clBlack;
    BC.TextOut(IcoX + 2, IcoY + 2, G);

    // 1px black outline — 8 directions
    for DX := -1 to 1 do
      for DY := -1 to 1 do
        if (DX <> 0) or (DY <> 0) then
          BC.TextOut(IcoX + DX, IcoY + DY, G);

    // White icon on top
    BC.Font.Color := clWhite;
    BC.TextOut(IcoX, IcoY, G);

    Inc(Slot);
  end;
  end;
end;



end.
