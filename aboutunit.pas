unit aboutunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,ExtCtrls, LCLProc, LCLIntf, urlutils, themeunit;

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
  OpenURLInBrowser('https://github.com/flightlessmango/MangoHud');
end;

procedure TaboutForm.schoorselinkLabelClick(Sender: TObject);
begin
  OpenURLInBrowser('https://github.com/DadSchoorse/vkBasalt');
end;

procedure TaboutForm.twitterlinkClick(Sender: TObject);
begin
  OpenURLInBrowser('https://twitter.com/benjamimgois');
end;


procedure TaboutForm.linkedinlinkClick(Sender: TObject);
begin
  OpenURLInBrowser('https://www.linkedin.com/in/benjamim-gois-37100155/');
end;

procedure TaboutForm.mangolink1Click(Sender: TObject);
begin

end;

procedure TaboutForm.Label1Click(Sender: TObject);
begin
  OpenURLInBrowser('https://github.com/matanui159/ReplaySorcery');
end;

procedure TaboutForm.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  //Set initial TAB
  aboutPageControl.ActivePage:=aboutTabsheet;

  //Centralize window
  CenterFormOnScreen(Self);

  // Force dark theme
  abouttabsheet.Color:= DarkBackgroundColor;
  ApplyDarkTheme(Self); //set all elements to dark tones

  // Adjust tab text color
  for i := 0 to aboutPageControl.PageCount - 1 do
  begin
    aboutPageControl.Pages[i].Font.Color := clBtnText;
  end;
end;

procedure TaboutForm.donateImageClick(Sender: TObject);
  begin
    try
     if not OpenURL('https://ko-fi.com/benjamimgois') then
       ShowMessage('Unable to open the link in the default web browser.');
   except
     on E: Exception do
       ShowMessage('Error opening the link: ' + E.Message);
   end;
end;

procedure TaboutForm.pascubelinkClick(Sender: TObject);
begin
  OpenURLInBrowser('https://github.com/benjamimgois/goverlay');
end;






end.



