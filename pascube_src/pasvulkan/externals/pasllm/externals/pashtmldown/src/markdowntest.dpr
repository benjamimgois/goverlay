program markdowntest;
{$ifdef fpc}
 {$mode delphi}
{$endif}
{$apptype console}

uses
  Classes,
  SysUtils,
  PasHTMLDown in 'PasHTMLDown.pas';

var sl:TStringList;
    HTML:THTML;
begin
 sl:=TStringList.Create;
 try
  sl.LoadFromFile('input.md');
  sl.Text:='<!DOCTYPE html><html><head><title>bla</title></head><body>'+MarkDownToHTML(sl.Text)+'<body></html>';
  sl.SaveToFile('output.htm');
  HTML:=THTML.Create(sl.Text);
  try
   sl.Text:=HTML.GetMarkDown;
  finally
   HTML.Free;
  end;
  sl.SaveToFile('output.md');
 finally
  sl.Free;
 end;
end.
