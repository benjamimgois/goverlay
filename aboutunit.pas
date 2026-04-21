unit aboutunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,ExtCtrls, LCLProc, LCLIntf, urlutils, themeunit, constants;

type

  { TaboutForm }

  TaboutForm = class(TForm)
    donateImage: TImage;
    meImage: TImage;
    creditsLabel: TLabel;
    titleLabel: TLabel;
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

procedure TaboutForm.FormCreate(Sender: TObject);
const
  NewDarkBg = $002E1E1A;
var
  i: Integer;
begin
  //Set initial TAB
  aboutPageControl.ActivePage:=aboutTabsheet;

  //Centralize window
  CenterFormOnScreen(Self);

  ApplyTheme(Self, CurrentTheme);

  if CurrentTheme = tmDark then
  begin
    Self.Color := NewDarkBg;
    aboutPageControl.Color := NewDarkBg;
    aboutTabSheet.Color := NewDarkBg;
    licenseTabSheet.Color := NewDarkBg;
    titleLabel.Font.Color := clWhite;
    titleLabel.Transparent := True;
    meLabel.Font.Color := clWhite;
    meLabel.Transparent := True;
    descLabel.Font.Color := clWhite;
    descLabel.Transparent := True;
    creditsLabel.Font.Color := clWhite;
    creditsLabel.Transparent := True;
    gplMemo.Color := NewDarkBg;
    gplMemo.Font.Color := clWhite;
  end;
end;

procedure TaboutForm.donateImageClick(Sender: TObject);
begin
  try
    if not OpenURL(URL_KOFI) then
      ShowMessage('Unable to open the link in the default web browser.');
  except
    on E: Exception do
      ShowMessage('Error opening the link: ' + E.Message);
  end;
end;

procedure TaboutForm.pascubelinkClick(Sender: TObject);
begin
  OpenURLInBrowser(URL_GOVERLAY_REPO);
end;






end.



