program pasllmapplcl;

{$mode delphi}

uses
 {$IFDEF UNIX}
 cmem,
 cthreads,
 {$ENDIF}
 {$IFDEF HASAMIGA}
 athreads,
 {$ENDIF}
 Interfaces, // this includes the LCL widgetset
 Forms, PasLLM, Pinja, PinjaChatTemplate, PasLLMChatControl, PasDblStrUtils,
 PasHTMLDown, PasHTMLDownCanvasRenderer, PasJSON, PasMP, UnitFormMain
 { you can add units after this };

{$R *.res}

begin
 RequireDerivedFormResource:=True;
 Application.Title:='PasLLM App';
 Application.Scaled:=True;
 Application.Initialize;
 Application.CreateForm(TFormMain, FormMain);
 Application.Run;
end.

