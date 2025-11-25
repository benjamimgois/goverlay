unit urlutils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LazHelpHTML, UTF8Process, LCLProc;

/// <summary>
/// Opens a URL in the system's default web browser
/// </summary>
/// <param name="URL">The URL to open (e.g., 'https://github.com/example')</param>
/// <returns>True if successful, False otherwise</returns>
function OpenURLInBrowser(const URL: string): Boolean;

implementation

function OpenURLInBrowser(const URL: string): Boolean;
var
  v: THTMLBrowserHelpViewer;
  BrowserPath, BrowserParams: string;
  p: LongInt;
  BrowserProcess: TProcessUTF8;
begin
  Result := False;
  v := THTMLBrowserHelpViewer.Create(nil);
  try
    try
      v.FindDefaultBrowser(BrowserPath, BrowserParams);
      debugln(['Browser Path=', BrowserPath, ' Params=', BrowserParams]);

      // Replace %s placeholder with actual URL
      p := System.Pos('%s', BrowserParams);
      if p > 0 then
      begin
        System.Delete(BrowserParams, p, 2);
        System.Insert(URL, BrowserParams, p);
      end;

      // Launch browser
      BrowserProcess := TProcessUTF8.Create(nil);
      try
        BrowserProcess.CommandLine := BrowserPath + ' ' + BrowserParams;
        BrowserProcess.Execute;
        Result := True;
      finally
        BrowserProcess.Free;
      end;
    except
      on E: Exception do
      begin
        debugln(['Error opening URL: ', E.Message]);
        Result := False;
      end;
    end;
  finally
    v.Free;
  end;
end;

end.
