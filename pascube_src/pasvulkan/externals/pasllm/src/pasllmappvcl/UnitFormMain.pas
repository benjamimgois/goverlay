unit UnitFormMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, PasLLM, PasLLMChatControl, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TFormMain = class(TForm)
    PanelLeft: TPanel;
    PanelChat: TPanel;
    StatusBar1: TStatusBar;
    PanelLeftTop: TPanel;
    PanelLeftBottom: TPanel;
    Splitter1: TSplitter;
    ButtonNewSession: TButton;
    ListBoxSessions: TListBox;
    EditSessionName: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EditSessionNameExit(Sender: TObject);
    procedure EditSessionNameKeyPress(Sender: TObject; var Key: Char);
    procedure ListBoxSessionsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListBoxSessionsDblClick(Sender: TObject);
    procedure ListBoxSessionsClick(Sender: TObject);
    procedure ButtonNewSessionClick(Sender: TObject);
  private
    { Private declarations }
    procedure ChatControlRequestModelList(aSender:TObject;var aModels:TPasLLMChatControl.TPasLLMModels);
  public
    { Public declarations }
    fChatControl:TPasLLMChatControl;
    // Session management methods
    procedure RefreshSessionsList;
    procedure LoadSelectedSession;
    procedure DeleteSelectedSession;
    procedure CreateNewSession;
    procedure SaveCurrentSession;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.EditSessionNameExit(Sender: TObject);
begin
 if assigned(fChatControl) then begin
  fChatControl.UpdateCurrentSessionTitle(EditSessionName.Text);
  fChatControl.PopulateSessionsList(ListBoxSessions);
 end;
end;

procedure TFormMain.EditSessionNameKeyPress(Sender: TObject; var Key: Char);
begin
 if (Key=#13) and assigned(fChatControl) then begin // Enter
  // Update session title and auto-save
  fChatControl.UpdateCurrentSessionTitle(Trim(EditSessionName.Text));
  Key:=#0;
 end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
 // Create chat control (custom component must be created in code)
 fChatControl:=TPasLLMChatControl.Create(PanelChat);
 fChatControl.Parent:=PanelChat;
 fChatControl.Align:=alClient;
 fChatControl.StatusBar:=StatusBar1;
 fChatControl.EditSessionName:=EditSessionName;
{fChatControl.OnSendPrompt:=ChatControlSendPrompt;
 fChatControl.OnModelChanged:=ChatControlModelChanged;}
// fChatControl.OnRequestModelList:=ChatControlRequestModelList;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
 {}
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
 fChatControl.PopulateModelCombo;
 // Initial session list refresh
 RefreshSessionsList;
 fChatControl.PopulateSessionsList(ListBoxSessions);
end;

procedure TFormMain.ChatControlRequestModelList(aSender:TObject;var aModels:TPasLLMChatControl.TPasLLMModels);
var SearchRec:TSearchRec;
    ModelDir:TPasLLMUTF8String;
    Count:TPasLLMInt32;
begin
 // Scan for models in the executable directory
 ModelDir:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'models');
 Count:=0;

 if FindFirst(ModelDir+'*.safetensors',faAnyFile,SearchRec)=0 then begin
  try
   repeat
    inc(Count);
    SetLength(aModels,Count);
    aModels[Count-1]:=SearchRec.Name;
   until FindNext(SearchRec)<>0;
  finally
   FindClose(SearchRec);
  end;
 end;

 // If no models found, provide some example names
 if Count=0 then begin
  SetLength(aModels,3);
  aModels[0]:='qwen2.5_0.5b_instruct_q40nl.safetensors';
  aModels[1]:='llama32_1b_instruct_q40nl.safetensors';
  aModels[2]:='smollm2_1.7b_instruct_q40nl.safetensors';
 end;
end;

procedure TFormMain.RefreshSessionsList;
begin
 if assigned(fChatControl) then begin
  fChatControl.PopulateSessionsList(ListBoxSessions);
 end;
end;

procedure TFormMain.ListBoxSessionsClick(Sender: TObject);
begin
 if assigned(fChatControl) then begin
  fChatControl.OnSessionSelected(ListBoxSessions.ItemIndex);
 end;
end;

procedure TFormMain.ListBoxSessionsDblClick(Sender: TObject);
begin
 if assigned(fChatControl) then begin
  fChatControl.LoadSession('',ListBoxSessions.ItemIndex);
 end;
end;

procedure TFormMain.ListBoxSessionsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if assigned(fChatControl) then begin
  case Key of
   VK_RETURN:begin // Enter
    fChatControl.LoadSession('',ListBoxSessions.ItemIndex);
    Key:=0;
   end;
   VK_DELETE:begin // Delete
    if ssCtrl in Shift then begin
     fChatControl.DeleteSelectedSession(ListBoxSessions.ItemIndex);
     Key:=0;
    end;
   end;
  end;
 end;
end;

procedure TFormMain.LoadSelectedSession;
begin
 if assigned(fChatControl) then begin
  fChatControl.LoadSession('',ListBoxSessions.ItemIndex);
 end;
end;

procedure TFormMain.DeleteSelectedSession;
begin
 if assigned(fChatControl) then begin
  fChatControl.DeleteSelectedSession(ListBoxSessions.ItemIndex);
 end;
end;

procedure TFormMain.ButtonNewSessionClick(Sender: TObject);
begin
 CreateNewSession;
end;

procedure TFormMain.CreateNewSession;
begin
 if assigned(fChatControl) then begin
  fChatControl.NewChatSession;
  fChatControl.RefreshSessionsList;
  fChatControl.PopulateSessionsList(ListBoxSessions);
 end;
end;

procedure TFormMain.SaveCurrentSession;
begin
 // Remove this method - auto-save handles everything
 // Keep for backward compatibility but make it do nothing
end;

end.
