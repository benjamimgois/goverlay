unit aboutunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,ExtCtrls, LCLProc, LazHelpHTML, UTF8Process, LCLIntf;

type

  { TaboutForm }

  TaboutForm = class(TForm)
    donateImage: TImage;
    goverlaylink: TLabel;
    meImage: TImage;
    titleLabel: TLabel;
    meLabel: TLabel;
    textLabel: TLabel;
    pascubelink: TLabel;
    schoorselinkLabel: TLabel;
    gplMemo: TMemo;
    twitterlink: TImage;
    linkedinlink: TImage;
    mangolink: TLabel;
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
  aboutForm: TaboutForm;

implementation

{$R *.lfm}

{ TaboutForm }

//Procedure to force dark theme on elements
const
  DarkBackgroundColor = $0045403A; // dark panel color BGR
  DarkTextColor = clwhite;  // set light color

procedure SetDarkColorsRecursively(AControl: TWinControl);
var
  i: Integer;
  ctrl: TControl;
begin


  for i := 0 to AControl.ControlCount - 1 do
  begin
    ctrl := AControl.Controls[i];
     if ctrl is TMemo then
      TMemo(ctrl).Font.Color := DarkTextColor;
    if ctrl is TLabel then
      TLabel(ctrl).Font.Color := DarkTextColor
    else if ctrl is TCheckBox then
      TCheckBox(ctrl).Font.Color := DarkTextColor
    else if ctrl is TGroupBox then
    begin
      TGroupBox(ctrl).Font.Color := DarkTextColor;
      TGroupBox(ctrl).Color := DarkBackgroundColor;
      if TGroupBox(ctrl) is TWinControl then
        SetDarkColorsRecursively(TWinControl(ctrl));
    end
    else if ctrl is TCheckGroup then
    begin
      TCheckGroup(ctrl).Font.Color := DarkTextColor;
      TCheckGroup(ctrl).Color := DarkBackgroundColor;
      if TCheckGroup(ctrl) is TWinControl then
        SetDarkColorsRecursively(TWinControl(ctrl));
    end
    else if ctrl is TRadioGroup then
    begin
      TRadioGroup(ctrl).Font.Color := DarkTextColor;
      TRadioGroup(ctrl).Color := DarkBackgroundColor;
    end

    else if ctrl is TColorButton then
      TColorButton(ctrl).Color := DarkBackgroundColor
    else if ctrl is TWinControl then
      SetDarkColorsRecursively(TWinControl(ctrl))

  end;
end;


procedure TaboutForm.mangolinkClick(Sender: TObject);


  var
  v: THTMLBrowserHelpViewer;
  BrowserPath, BrowserParams: string;
  p: LongInt;
  URL: String;
  BrowserProcess: TProcessUTF8;
begin
  v:=THTMLBrowserHelpViewer.Create(nil);
  try
    v.FindDefaultBrowser(BrowserPath,BrowserParams);
    debugln(['Path=',BrowserPath,' Params=',BrowserParams]);

    URL:='https://github.com/flightlessmango/MangoHud';
    p:=System.Pos('%s', BrowserParams);
    System.Delete(BrowserParams,p,2);
    System.Insert(URL,BrowserParams,p);

    // start browser
    BrowserProcess:=TProcessUTF8.Create(nil);
    try
      BrowserProcess.CommandLine:=BrowserPath+' '+BrowserParams;
      BrowserProcess.Execute;
    finally
      BrowserProcess.Free;
    end;
  finally
    v.Free;
  end;
end;

procedure TaboutForm.schoorselinkLabelClick(Sender: TObject);



    var
  v: THTMLBrowserHelpViewer;
  BrowserPath, BrowserParams: string;
  p: LongInt;
  URL: String;
  BrowserProcess: TProcessUTF8;

begin
  v:=THTMLBrowserHelpViewer.Create(nil);
  try
    v.FindDefaultBrowser(BrowserPath,BrowserParams);
    debugln(['Path=',BrowserPath,' Params=',BrowserParams]);

    URL:='https://github.com/DadSchoorse/vkBasalt';
    p:=System.Pos('%s', BrowserParams);
    System.Delete(BrowserParams,p,2);
    System.Insert(URL,BrowserParams,p);

    // start browser
    BrowserProcess:=TProcessUTF8.Create(nil);
    try
      BrowserProcess.CommandLine:=BrowserPath+' '+BrowserParams;
      BrowserProcess.Execute;
    finally
      BrowserProcess.Free;
    end;
  finally
    v.Free;
  end;

end;

procedure TaboutForm.twitterlinkClick(Sender: TObject);

   var
   v: THTMLBrowserHelpViewer;
   BrowserPath, BrowserParams: string;
   p: LongInt;
   URL: String;
   BrowserProcess: TProcessUTF8;
 begin
   v:=THTMLBrowserHelpViewer.Create(nil);
   try
     v.FindDefaultBrowser(BrowserPath,BrowserParams);
     debugln(['Path=',BrowserPath,' Params=',BrowserParams]);

     URL:='https://twitter.com/benjamimgois';
     p:=System.Pos('%s', BrowserParams);
     System.Delete(BrowserParams,p,2);
     System.Insert(URL,BrowserParams,p);

     // start browser
     BrowserProcess:=TProcessUTF8.Create(nil);
     try
       BrowserProcess.CommandLine:=BrowserPath+' '+BrowserParams;
       BrowserProcess.Execute;
     finally
       BrowserProcess.Free;
     end;
   finally
     v.Free;
   end;
 end;


procedure TaboutForm.linkedinlinkClick(Sender: TObject);
  var
   v: THTMLBrowserHelpViewer;
   BrowserPath, BrowserParams: string;
   p: LongInt;
   URL: String;
   BrowserProcess: TProcessUTF8;
 begin
   v:=THTMLBrowserHelpViewer.Create(nil);
   try
     v.FindDefaultBrowser(BrowserPath,BrowserParams);
     debugln(['Path=',BrowserPath,' Params=',BrowserParams]);

     URL:='https://www.linkedin.com/in/benjamim-gois-37100155/';
     p:=System.Pos('%s', BrowserParams);
     System.Delete(BrowserParams,p,2);
     System.Insert(URL,BrowserParams,p);

     // start browser
     BrowserProcess:=TProcessUTF8.Create(nil);
     try
       BrowserProcess.CommandLine:=BrowserPath+' '+BrowserParams;
       BrowserProcess.Execute;
     finally
       BrowserProcess.Free;
     end;
   finally
     v.Free;
   end;
 end;

procedure TaboutForm.mangolink1Click(Sender: TObject);
begin

end;

procedure TaboutForm.Label1Click(Sender: TObject);


  var
  v: THTMLBrowserHelpViewer;
  BrowserPath, BrowserParams: string;
  p: LongInt;
  URL: String;
  BrowserProcess: TProcessUTF8;
  i: Integer;
begin
  v:=THTMLBrowserHelpViewer.Create(nil);
  try
    v.FindDefaultBrowser(BrowserPath,BrowserParams);
    debugln(['Path=',BrowserPath,' Params=',BrowserParams]);

    URL:='https://github.com/matanui159/ReplaySorcery';
    p:=System.Pos('%s', BrowserParams);
    System.Delete(BrowserParams,p,2);
    System.Insert(URL,BrowserParams,p);

    // start browser
    BrowserProcess:=TProcessUTF8.Create(nil);
    try
      BrowserProcess.CommandLine:=BrowserPath+' '+BrowserParams;
      BrowserProcess.Execute;
    finally
      BrowserProcess.Free;
    end;
  finally
    v.Free;
  end;
end;

procedure TaboutForm.FormCreate(Sender: TObject);
  var
   i: Integer;
begin
  //Set initial TAB
  aboutPageControl.ActivePage:=aboutTabsheet;

  //Centralize window
  Left:=(Screen.Width-Width)  div 2;
  Top:=(Screen.Height-Height) div 2;

   // Force dark theme
   abouttabsheet.Color:= DarkBackgroundColor;
   SetDarkColorsRecursively(Self); //set all elements to dark tones

  // Ajust tab text color
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

    var
  v: THTMLBrowserHelpViewer;
  BrowserPath, BrowserParams: string;
  p: LongInt;
  URL: String;
  BrowserProcess: TProcessUTF8;
begin
  v:=THTMLBrowserHelpViewer.Create(nil);
  try
    v.FindDefaultBrowser(BrowserPath,BrowserParams);
    debugln(['Path=',BrowserPath,' Params=',BrowserParams]);

    URL:='https://github.com/benjamimgois/goverlay';
    p:=System.Pos('%s', BrowserParams);
    System.Delete(BrowserParams,p,2);
    System.Insert(URL,BrowserParams,p);

    // start browser
    BrowserProcess:=TProcessUTF8.Create(nil);
    try
      BrowserProcess.CommandLine:=BrowserPath+' '+BrowserParams;
      BrowserProcess.Execute;
    finally
      BrowserProcess.Free;
    end;
  finally
    v.Free;
  end;
end;






end.



