unit aboutunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, ExtCtrls, LCLProc, LCLIntf, urlutils, themeunit, constants, goverlay_strings, apputils, bgmod_resources;

type

  { TaboutForm }

  TaboutForm = class(TForm)
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

  public

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
const
  NewDarkBg = $002E1E1A;
  ColorSkyBlue = $00F8BD38;
var
  LogoFile: string;
begin
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
  creditsLabel.Caption := 
    'FlightlessMango – MangoHud'#10 +
    'DadSchoorse – vkBasalt'#10 +
    'reakjra – vkSumi'#10 +
    'OptiScaler ecosystem: OptiScaler, fakenvapi, Decky-Framegen, fgmod, DLSS-Enabler'#10 +
    'THS – Lossless Scaling'#10 +
    'Pietruszka33 – lsfg-vk';
  linksHeaderLabel.Caption := 'Project links:';
  linksLabel.Caption := 'github.com/benjamimgois/goverlay';

  ApplyTheme(Self, CurrentTheme);

  if CurrentTheme = tmDark then
  begin
    Self.Color := NewDarkBg;
    aboutPageControl.Color := NewDarkBg;
    aboutTabSheet.Color := NewDarkBg;
    licenseTabSheet.Color := NewDarkBg;
    descLabel.Font.Color := $00F0E8E2;
    descLabel.Transparent := True;
    creditsHeaderLabel.Font.Color := ColorSkyBlue;
    creditsHeaderLabel.Transparent := True;
    creditsLabel.Font.Color := clWhite;
    creditsLabel.Transparent := True;
    linksHeaderLabel.Font.Color := ColorSkyBlue;
    linksHeaderLabel.Transparent := True;
    linksLabel.Font.Color := clWhite;
    linksLabel.Transparent := True;
    meLabel.Font.Color := clWhite;
    meLabel.Transparent := True;
    gplMemo.Color := NewDarkBg;
    gplMemo.Font.Color := clWhite;
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






end.



