unit aboutunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, ExtCtrls, LCLProc, LCLIntf, urlutils, themeunit, constants, goverlay_strings, apputils, bgmod_resources;

type

  { TaboutForm }

  TaboutForm = class(TForm)
    sponsorImage: TImage;
    donateImage: TImage;
    paypalDonateImage: TImage;
    meImage: TImage;
    creditsHeaderLabel: TLabel;
    creditsLabel: TLabel;
    linksHeaderLabel: TLabel;
    linksLabel: TLabel;
    logoImage: TImage;
    meLabel: TLabel;
    descLabel: TLabel;
    gplMemo: TMemo;
    twitterlink: TImage;
    linkedinlink: TImage;
    aboutPageControl: TPageControl;
    aboutTabSheet: TTabSheet;
    licenseTabSheet: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure sponsorImageClick(Sender: TObject);
    procedure donateImageClick(Sender: TObject);
    procedure paypalDonateImageClick(Sender: TObject);
    procedure linksLabelClick(Sender: TObject);
    procedure pascubelinkClick(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure linkedinlinkClick(Sender: TObject);
    procedure mangolink1Click(Sender: TObject);
    procedure mangolinkClick(Sender: TObject);
    procedure schoorselinkLabelClick(Sender: TObject);
    procedure twitterlinkClick(Sender: TObject);
  private
    FCreditsPanel: TPanel;
    FCreditLinkLabels: array of TLabel;
    FCreditTextLabels: array of TLabel;
    FCreditUrls: array of string;
    procedure BuildCreditsRows;
    procedure ApplyCreditsTheme(IsDark: Boolean);
    procedure CreditLinkClick(Sender: TObject);
    procedure CreditLinkMouseEnter(Sender: TObject);
    procedure CreditLinkMouseLeave(Sender: TObject);
  public
    function CreditLinkCount: Integer;
    function GetCreditLinkLabel(AIndex: Integer): TLabel;
    function GetCreditLinkUrl(AIndex: Integer): string;
  end;

var
  // ============================================================================
  // FORM INSTANCE
  // ============================================================================
  aboutForm: TaboutForm;                // About dialog form

implementation

{$R *.lfm}

{ TaboutForm }


procedure TaboutForm.mangolinkClick(Sender: TObject);
begin
  OpenURLInBrowser(URL_MANGOHUD_REPO);
end;

procedure TaboutForm.schoorselinkLabelClick(Sender: TObject);
begin
  OpenURLInBrowser(URL_VKBASALT_REPO);
end;

procedure TaboutForm.twitterlinkClick(Sender: TObject);
begin
  OpenURLInBrowser(URL_TWITTER);
end;


procedure TaboutForm.linkedinlinkClick(Sender: TObject);
begin
  OpenURLInBrowser(URL_LINKEDIN);
end;

procedure TaboutForm.mangolink1Click(Sender: TObject);
begin

end;

procedure TaboutForm.Label1Click(Sender: TObject);
begin
  OpenURLInBrowser(URL_REPLAYSORCERY_REPO);
end;

procedure TaboutForm.linksLabelClick(Sender: TObject);
begin
  OpenURLInBrowser(URL_GOVERLAY_REPO);
end;

procedure TaboutForm.FormCreate(Sender: TObject);
var
  LogoFile: string;
  NewDarkBg: TColor;
begin
  NewDarkBg := RGBToColor(22, 26, 40);

  //Set initial TAB
  aboutPageControl.ActivePage:=aboutTabsheet;

  //Centralize window
  CenterFormOnScreen(Self);

  // Load logo dynamically if available
  LogoFile := GetAppBaseDir + 'data/goverlay_logo_about.png';
  if not FileExists(LogoFile) then
    LogoFile := 'data/goverlay_logo_about.png';
  if not FileExists(LogoFile) then
    LogoFile := GetAppBaseDir + 'data/goverlay_logo.png';
  if not FileExists(LogoFile) then
    LogoFile := 'data/goverlay_logo.png';
  if FileExists(LogoFile) then
  begin
    try
      logoImage.Picture.LoadFromFile(LogoFile);
    except
    end;
  end;

  // Load GitHub Sponsor donate image dynamically if available
  LogoFile := GetAppBaseDir + 'data/github_sponsor.png';
  if not FileExists(LogoFile) then
    LogoFile := 'data/github_sponsor.png';
  if FileExists(LogoFile) then
  begin
    try
      sponsorImage.Picture.LoadFromFile(LogoFile);
    except
    end;
  end;

  // Load Ko-fi donate image dynamically if available
  LogoFile := GetAppBaseDir + 'data/kofi_donate.png';
  if not FileExists(LogoFile) then
    LogoFile := 'data/kofi_donate.png';
  if FileExists(LogoFile) then
  begin
    try
      donateImage.Picture.LoadFromFile(LogoFile);
    except
    end;
  end;

  // Load PayPal donate image dynamically if available
  LogoFile := GetAppBaseDir + 'data/paypal_donate.png';
  if not FileExists(LogoFile) then
    LogoFile := 'data/paypal_donate.png';
  if FileExists(LogoFile) then
  begin
    try
      paypalDonateImage.Picture.LoadFromFile(LogoFile);
    except
    end;
  end;

  // Load avatar photo dynamically if available
  LogoFile := GetAppBaseDir + 'data/me.png';
  if not FileExists(LogoFile) then
    LogoFile := 'data/me.png';
  if not FileExists(LogoFile) then
    LogoFile := GetAppBaseDir + 'data/me.jpg';
  if not FileExists(LogoFile) then
    LogoFile := 'data/me.jpg';
  if FileExists(LogoFile) then
  begin
    try
      meImage.Picture.LoadFromFile(LogoFile);
    except
    end;
  end;

  // Load social icons dynamically if available
  LogoFile := GetAppBaseDir + 'data/icons/linkedin.png';
  if not FileExists(LogoFile) then
    LogoFile := 'data/icons/linkedin.png';
  if FileExists(LogoFile) then
  begin
    try
      linkedinlink.Picture.LoadFromFile(LogoFile);
    except
    end;
  end;

  LogoFile := GetAppBaseDir + 'data/icons/twitter.png';
  if not FileExists(LogoFile) then
    LogoFile := 'data/icons/twitter.png';
  if FileExists(LogoFile) then
  begin
    try
      twitterlink.Picture.LoadFromFile(LogoFile);
    except
    end;
  end;

  // Update description and credits captions dynamically at runtime
  descLabel.Caption := 'Open-source tool providing a unified interface to configure different gaming tools';
  creditsHeaderLabel.Caption := 'Credits:';
  creditsLabel.Height := 220;
  creditsLabel.Caption := 
    'FlightlessMango – MangoHud'#10 +
    'DadSchoorse – vkBasalt'#10 +
    'reakjra – vkSumi, vkNemu'#10 +
    'lonewolf0622 – HelixSR'#10 +
    'mochizuki0323 – DLSS-NR (RDNA4)'#10 +
    'saaaaaaaaaaaaaaaaaas – DLSS-NR (RDNA3)'#10 +
    'OptiScaler ecosystem: OptiScaler, fakenvapi, Decky-Framegen, fgmod, DLSS-Enabler'#10 +
    'THS – Lossless Scaling'#10 +
    'PancakeTAS – lsfg-vk'#10 +
    'eugeniosegala – MAKO'#10 +
    'serialexperimentslainnnn – afmf-linux';
  creditsLabel.Visible := False;
  BuildCreditsRows;
  linksHeaderLabel.Caption := 'Project links:';
  linksLabel.Caption := 'github.com/benjamimgois/goverlay';

  ApplyTheme(Self, CurrentTheme);
  ApplyTabBarStyleSheet(aboutPageControl, CurrentTheme = tmDark);

  if CurrentTheme = tmDark then
  begin
    Self.Color := NewDarkBg;
    aboutPageControl.Color := NewDarkBg;
    aboutTabSheet.Color := NewDarkBg;
    aboutTabSheet.Font.Color := clWhite;
    licenseTabSheet.Color := NewDarkBg;
    descLabel.Font.Color := RGBToColor(200, 208, 224);
    descLabel.Transparent := True;
    creditsHeaderLabel.Font.Color := clWhite;
    creditsHeaderLabel.Font.Style := [fsBold];
    creditsHeaderLabel.Transparent := True;
    creditsLabel.Font.Color := RGBToColor(220, 226, 238);
    creditsLabel.Transparent := True;
    ApplyCreditsTheme(True);
    linksHeaderLabel.Font.Color := clWhite;
    linksHeaderLabel.Font.Style := [fsBold];
    linksHeaderLabel.Transparent := True;
    linksLabel.Font.Color := $0044AAFF;
    linksLabel.Cursor := crHandPoint;
    linksLabel.Transparent := True;
    meLabel.Font.Color := clWhite;
    meLabel.Font.Style := [fsBold];
    meLabel.Transparent := True;
    gplMemo.Color := RGBToColor(27, 32, 46);
    gplMemo.Font.Color := clWhite;
  end
  else if CurrentTheme = tmLight then
  begin
    Self.Color := LightBackgroundColor;
    aboutPageControl.Color := LightBackgroundColor;
    aboutTabSheet.Color := LightBackgroundColor;
    aboutTabSheet.Font.Color := clBlack;
    licenseTabSheet.Color := LightBackgroundColor;
    descLabel.Font.Color := RGBToColor(70, 75, 85);
    descLabel.Transparent := True;
    creditsHeaderLabel.Font.Color := clBlack;
    creditsHeaderLabel.Font.Style := [fsBold];
    creditsHeaderLabel.Transparent := True;
    creditsLabel.Font.Color := RGBToColor(40, 45, 55);
    creditsLabel.Transparent := True;
    ApplyCreditsTheme(False);
    linksHeaderLabel.Font.Color := clBlack;
    linksHeaderLabel.Font.Style := [fsBold];
    linksHeaderLabel.Transparent := True;
    linksLabel.Font.Color := $00CC6600;
    linksLabel.Cursor := crHandPoint;
    linksLabel.Transparent := True;
    meLabel.Font.Color := clBlack;
    meLabel.Font.Style := [fsBold];
    meLabel.Transparent := True;
    gplMemo.Color := RGBToColor(245, 246, 248);
    gplMemo.Font.Color := clBlack;
  end;
end;

procedure TaboutForm.sponsorImageClick(Sender: TObject);
begin
  try
    if not OpenURL(URL_GITHUB_SPONSORS) then
      ShowMessage(rsLinkOpenFailed);
  except
    on E: Exception do
      ShowMessage(Format(rsLinkOpenError, [E.Message]));
  end;
end;

procedure TaboutForm.donateImageClick(Sender: TObject);
begin
  try
    if not OpenURL(URL_KOFI) then
      ShowMessage(rsLinkOpenFailed);
  except
    on E: Exception do
      ShowMessage(Format(rsLinkOpenError, [E.Message]));
  end;
end;

procedure TaboutForm.paypalDonateImageClick(Sender: TObject);
begin
  try
    if not OpenURL(URL_PAYPAL) then
      ShowMessage(rsLinkOpenFailed);
  except
    on E: Exception do
      ShowMessage(Format(rsLinkOpenError, [E.Message]));
  end;
end;

procedure TaboutForm.pascubelinkClick(Sender: TObject);
begin
  OpenURLInBrowser(URL_GOVERLAY_REPO);
end;

procedure TaboutForm.BuildCreditsRows;
var
  PrevRowFirst, RowFirst, LastInRow: TLabel;

  function CreateCreditLabel(const ACaption: string): TLabel;
  begin
    Result := TLabel.Create(FCreditsPanel);
    Result.Parent := FCreditsPanel;
    Result.AutoSize := True;
    Result.Transparent := True;
    Result.Caption := ACaption;
    Result.Font.Name := 'Noto Sans';
    Result.Font.Height := -13;
    Result.Font.Quality := fqAntialiased;
  end;

  procedure AppendSegment(const AText: string; const AUrl: string = '');
  var
    Lbl: TLabel;
    Idx: Integer;
  begin
    Lbl := CreateCreditLabel(AText);
    if LastInRow = nil then
    begin
      RowFirst := Lbl;
      Lbl.AnchorSideLeft.Control := FCreditsPanel;
      Lbl.AnchorSideLeft.Side := asrLeft;
      if PrevRowFirst = nil then
      begin
        Lbl.AnchorSideTop.Control := FCreditsPanel;
        Lbl.AnchorSideTop.Side := asrTop;
      end
      else
      begin
        Lbl.AnchorSideTop.Control := PrevRowFirst;
        Lbl.AnchorSideTop.Side := asrBottom;
        Lbl.BorderSpacing.Top := 2;
      end;
    end
    else
    begin
      Lbl.AnchorSideLeft.Control := LastInRow;
      Lbl.AnchorSideLeft.Side := asrRight;
      Lbl.AnchorSideTop.Control := RowFirst;
      Lbl.AnchorSideTop.Side := asrTop;
    end;
    LastInRow := Lbl;

    if AUrl <> '' then
    begin
      Idx := Length(FCreditLinkLabels);
      SetLength(FCreditLinkLabels, Idx + 1);
      SetLength(FCreditUrls, Idx + 1);
      FCreditLinkLabels[Idx] := Lbl;
      FCreditUrls[Idx] := AUrl;
      Lbl.Tag := Idx;
      Lbl.Cursor := crHandPoint;
      Lbl.OnClick := @CreditLinkClick;
      Lbl.OnMouseEnter := @CreditLinkMouseEnter;
      Lbl.OnMouseLeave := @CreditLinkMouseLeave;
    end
    else
    begin
      Idx := Length(FCreditTextLabels);
      SetLength(FCreditTextLabels, Idx + 1);
      FCreditTextLabels[Idx] := Lbl;
    end;
  end;

  procedure FinishRow;
  begin
    PrevRowFirst := RowFirst;
    RowFirst := nil;
    LastInRow := nil;
  end;

begin
  FCreditsPanel := TPanel.Create(Self);
  FCreditsPanel.Parent := aboutTabSheet;
  FCreditsPanel.BevelOuter := bvNone;
  FCreditsPanel.BorderStyle := bsNone;
  FCreditsPanel.Caption := '';
  FCreditsPanel.ParentBackground := False;
  FCreditsPanel.AutoSize := True;
  FCreditsPanel.AnchorSideLeft.Control := aboutTabSheet;
  FCreditsPanel.AnchorSideLeft.Side := asrLeft;
  FCreditsPanel.AnchorSideTop.Control := creditsHeaderLabel;
  FCreditsPanel.AnchorSideTop.Side := asrBottom;
  FCreditsPanel.AnchorSideRight.Control := aboutTabSheet;
  FCreditsPanel.AnchorSideRight.Side := asrBottom;
  FCreditsPanel.Anchors := [akTop, akLeft, akRight];
  FCreditsPanel.BorderSpacing.Left := 24;
  FCreditsPanel.BorderSpacing.Top := 4;
  FCreditsPanel.BorderSpacing.Right := 24;

  linksHeaderLabel.AnchorSideTop.Control := FCreditsPanel;
  linksHeaderLabel.AnchorSideTop.Side := asrBottom;
  linksHeaderLabel.BorderSpacing.Top := 10;

  PrevRowFirst := nil;
  RowFirst := nil;
  LastInRow := nil;

  AppendSegment('FlightlessMango – '); AppendSegment('MangoHud', URL_MANGOHUD_REPO); FinishRow;
  AppendSegment('DadSchoorse – '); AppendSegment('vkBasalt', URL_VKBASALT_REPO); FinishRow;
  AppendSegment('reakjra – '); AppendSegment('vkSumi', URL_VKSUMI_REPO); AppendSegment(', '); AppendSegment('vkNemu', URL_VKNEMU_REPO); FinishRow;
  AppendSegment('lonewolf0622 – '); AppendSegment('HelixSR', URL_HELIXSR_REPO); FinishRow;
  AppendSegment('mochizuki0323 – '); AppendSegment('DLSS-NR (RDNA4)', URL_DLSSNR_RDNA4_REPO); FinishRow;
  AppendSegment('saaaaaaaaaaaaaaaaaas – '); AppendSegment('DLSS-NR (RDNA3)', URL_DLSSNR_RDNA3_REPO); FinishRow;
  AppendSegment('OptiScaler ecosystem: ');
    AppendSegment('OptiScaler', URL_OPTISCALER_REPO); AppendSegment(', ');
    AppendSegment('fakenvapi', URL_FAKENVAPI_GITHUB); AppendSegment(', ');
    AppendSegment('Decky-Framegen', URL_DECKY_FRAMEGEN_GITHUB); AppendSegment(', ');
    AppendSegment('fgmod', URL_FGMOD_REPO); AppendSegment(', ');
    AppendSegment('DLSS-Enabler', URL_DLSS_ENABLER_REPO);
    FinishRow;
  AppendSegment('THS – Lossless Scaling'); FinishRow;
  AppendSegment('PancakeTAS – '); AppendSegment('lsfg-vk', URL_LSFGVK_REPO); FinishRow;
  AppendSegment('eugeniosegala – '); AppendSegment('MAKO', URL_MAKO_REPO); FinishRow;
  AppendSegment('serialexperimentslainnnn – '); AppendSegment('afmf-linux', URL_AFMF_REPO); FinishRow;
end;

procedure TaboutForm.ApplyCreditsTheme(IsDark: Boolean);
var
  i: Integer;
  TextColor, LinkColor, BgColor: TColor;
begin
  if IsDark then
  begin
    BgColor := RGBToColor(22, 26, 40);
    TextColor := RGBToColor(220, 226, 238);
    LinkColor := $0044AAFF;
  end
  else
  begin
    BgColor := LightBackgroundColor;
    TextColor := RGBToColor(40, 45, 55);
    LinkColor := $00CC6600;
  end;

  if Assigned(FCreditsPanel) then
    FCreditsPanel.Color := BgColor;
  for i := 0 to High(FCreditTextLabels) do
    FCreditTextLabels[i].Font.Color := TextColor;
  for i := 0 to High(FCreditLinkLabels) do
    FCreditLinkLabels[i].Font.Color := LinkColor;
end;

procedure TaboutForm.CreditLinkClick(Sender: TObject);
var
  Idx: Integer;
begin
  if Sender is TLabel then
  begin
    Idx := TLabel(Sender).Tag;
    if (Idx >= 0) and (Idx < Length(FCreditUrls)) and (FCreditUrls[Idx] <> '') then
      OpenURLInBrowser(FCreditUrls[Idx]);
  end;
end;

procedure TaboutForm.CreditLinkMouseEnter(Sender: TObject);
begin
  if Sender is TLabel then
    TLabel(Sender).Font.Style := TLabel(Sender).Font.Style + [fsUnderline];
end;

procedure TaboutForm.CreditLinkMouseLeave(Sender: TObject);
begin
  if Sender is TLabel then
    TLabel(Sender).Font.Style := TLabel(Sender).Font.Style - [fsUnderline];
end;

function TaboutForm.CreditLinkCount: Integer;
begin
  Result := Length(FCreditLinkLabels);
end;

function TaboutForm.GetCreditLinkLabel(AIndex: Integer): TLabel;
begin
  if (AIndex >= 0) and (AIndex < Length(FCreditLinkLabels)) then
    Result := FCreditLinkLabels[AIndex]
  else
    Result := nil;
end;

function TaboutForm.GetCreditLinkUrl(AIndex: Integer): string;
begin
  if (AIndex >= 0) and (AIndex < Length(FCreditUrls)) then
    Result := FCreditUrls[AIndex]
  else
    Result := '';
end;






end.



