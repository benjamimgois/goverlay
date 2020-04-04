unit aboutunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,ExtCtrls, LCLProc, LazHelpHTML, UTF8Process;

type

  { TaboutForm }

  TaboutForm = class(TForm)
    Image1: TImage;
    donateImage: TImage;
    schoorselinkLabel: TLabel;
    schoorseMemo: TMemo;
    Memo3: TMemo;
    mangoMemo: TMemo;
    twitterlink: TImage;
    linkedinlink: TImage;
    linux4elink: TLabel;
    mangolink: TLabel;
    descriptionMemo: TMemo;
    jasonMemo: TMemo;
    Memo2: TMemo;
    PageControl1: TPageControl;
    GoverlayText: TStaticText;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure donateImageClick(Sender: TObject);
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
begin
  v:=THTMLBrowserHelpViewer.Create(nil);
  try
    v.FindDefaultBrowser(BrowserPath,BrowserParams);
    debugln(['Path=',BrowserPath,' Params=',BrowserParams]);

    URL:='https://www.linux4everyone.com/';
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
begin
  //Centralize window
  Left:=(Screen.Width-Width)  div 2;
  Top:=(Screen.Height-Height) div 2;
end;

procedure TaboutForm.donateImageClick(Sender: TObject);

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

    URL:='https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=Q5EYYEJ5NSJAU&source=url';
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



