unit PasLLMApp.FormMain;

interface

uses System.SysUtils,
     System.Types,
     System.UITypes,
     System.Classes,
     System.Variants,
     System.Generics.Collections,
     System.Math,
     FMX.Types,
     FMX.Controls,
     FMX.Forms,
     FMX.Graphics,
     FMX.Dialogs,
     FMX.Objects,
     FMX.StdCtrls,
     FMX.Layouts,
     FMX.Controls.Presentation,
     FMX.Effects,
     FMX.Edit,
     FMX.ListBox,
     PasLLM,
     PasHTMLDown,
     PasHTMLDownCanvasRenderer,
     PasLLMChatControl,
     PasMP, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo;

type TStringQueue=TPasMPUnboundedQueue<TPasLLMRawByteString>;

     { TFormMain }
     TFormMain = class(TForm)
       MaterialOxfordBlueSB:TStyleBook;
       ToolBar1:TToolBar;
       ShadowEffect4:TShadowEffect;
       Label1:TLabel;
    PanelLeft: TPanel;
    PanelLeftTop: TPanel;
    PanelLeftBottom: TPanel;
    ListBoxSessions: TListBox;
    EditSessionName: TEdit;
    ButtonNewSession: TButton;
    StatusBar1: TStatusBar;
    GridPanelLayout1: TGridPanelLayout;
    StatusBarLabel1: TLabel;
    StatusBarLabel2: TLabel;
    StatusBarLabel3: TLabel;
    StatusBarLabel4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure EditSessionNameExit(Sender: TObject);
    procedure ListBoxSessionsClick(Sender: TObject);
    procedure ListBoxSessionsDblClick(Sender: TObject);
    procedure ListBoxSessionsKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure EditSessionNameKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
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

var FormMain:TFormMain;

implementation

{$R *.fmx}

{ TFormMain }

procedure TFormMain.EditSessionNameExit(Sender: TObject);
begin
 if assigned(fChatControl) then begin
  fChatControl.UpdateCurrentSessionTitle(EditSessionName.Text);
  fChatControl.PopulateSessionsList(ListBoxSessions);
 end;
end;

procedure TFormMain.EditSessionNameKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
 if (Key=13) and assigned(fChatControl) then begin // Enter
  // Update session title and auto-save
  fChatControl.UpdateCurrentSessionTitle(Trim(EditSessionName.Text));
  Key:=0;
  KeyChar:=#0;
 end;
end;

procedure TFormMain.ButtonNewSessionClick(Sender: TObject);
begin
 CreateNewSession;
end;

procedure TFormMain.ChatControlRequestModelList(aSender:TObject;var aModels:TPasLLMChatControl.TPasLLMModels);
var SearchRec:TSearchRec;
    ModelDir:TPasLLMUTF8String;
    Count:TPasLLMInt32;
begin
 // Scan for models in the executable directory
 ModelDir:=IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
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


procedure TFormMain.FormCreate(Sender:TObject);
begin

{BorderStyle := TFmxFormBorderStyle.Single;

 Transparency := False; }

 fChatControl:=TPasLLMChatControl.Create(self);
 fChatControl.Parent:=self;
 fChatControl.Align:=TAlignLayout.Client;
 fChatControl.EditSessionName:=EditSessionName;
 fChatControl.OnRequestModelList:=ChatControlRequestModelList;
 fChatControl.StatusBarLabel1:=StatusBarLabel1;
 fChatControl.StatusBarLabel2:=StatusBarLabel2;
 fChatControl.StatusBarLabel3:=StatusBarLabel3;
 fChatControl.StatusBarLabel4:=StatusBarLabel4;

 // Initial session list refresh
 RefreshSessionsList;

 fChatControl.PopulateSessionsList(ListBoxSessions);

(*
 fChatControl.AddMessage(TPasLLMChatControl.TChatRole.Assistant,
   'Here is a comparison table between the US Dollar (USD) and the Euro (EUR):'+#13#10+
   ''+#13#10+
   '**Note:** The exchange rates provided are subject to change and may not reflect the current exchange rates. For the most up-to-date and accurate rates, please check the current exchange rates on a reliable source such as XE.com or a financial institution.'+#13#10+
   ''+#13#10+
   '| **Category** | **US Dollar (USD)** | **Euro (EUR)** |'+#13#10+
   '| --- | --- | --- |'+#13#10+
   '| **1. Currency** | $100 = 1 EUR |  100 = 1 EUR |'+#13#10+
   '| **2. Units** | 1 USD = 100 EUR | 1 EUR = 100 USD |'+#13#10+
   '| **3. Exchanges** | Bank deposits, ATMs, Currency exchange offices | Bank deposits, ATMs, Currency exchange offices |'+#13#10+
   '| **4. Withdrawals** | Withdraw from a bank or ATM in the US | Withdraw from a bank or ATM in the Eurozone |'+#13#10+
   '| **5. Deposits** | Deposit cash, cashier''s checks | Deposit cash, cashier''s checks |'+#13#10+
   '| **6. Minimums** | No minimums | No minimums |'+#13#10+
   '| **7. Maximums** | No maximums | No maximums |'+#13#10+
   '| **8. Taxes** | No taxes | 0% |'+#13#10+
   '| **9. Fees** | No fees | 0% |'+#13#10+
   '| **10. Currency Controls** | No currency controls | No currency controls |'+#13#10+
   '| **11. International Trade** | All international trade transactions are in USD | All international trade transactions are in EUR |'+#13#10+
   '| **12. Travel** | All travel transactions are in USD | All travel transactions are in EUR |'+#13#10+
   '| **13. Currency and Credit Card Transactions** | All transactions are subject to US Dollar and Euro currency and credit card regulations | All transactions are subject to US Dollar and Euro currency and credit card regulations |'+#13#10+
   '| **14. Online Purchases** | All online purchases are subject to US Dollar and Euro currency and credit card regulations | All online purchases are subject to US Dollar and Euro currency and credit card regulations |'+#13#10+
   '| **15. Currency and Credit Card Regulations** | All currency and credit card transactions are subject to the regulations of both the US and the Eurozone | All currency and credit card transactions are subject to the regulations of the US and the Eurozone |'+#13#10+
   ''+#13#10+
   '**Disclaimer:** This comparison table is for informational purposes only and is not intended to be a comprehensive or definitive guide to the use of the US Dollar and the Euro. The use of the US Dollar and the Euro for international transactions is subject to the laws and regulations of both the US and the Eurozone, and users are encouraged to consult with a qualified professional before making any decisions.'#13#10);
*)
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
 {}
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
  var KeyChar: WideChar; Shift: TShiftState);
begin
 if assigned(fChatControl) then begin
  case Key of
   vkReturn:begin // Enter
    fChatControl.LoadSession('',ListBoxSessions.ItemIndex);
    Key:=0;
    KeyChar:=#0;
   end;
   vkDelete:begin // Delete
    if ssCtrl in Shift then begin
     fChatControl.DeleteSelectedSession(ListBoxSessions.ItemIndex);
     Key:=0;
     KeyChar:=#0;
    end;
   end;
  end;
 end;
end;

procedure TFormMain.RefreshSessionsList;
begin
 if assigned(fChatControl) then begin
  fChatControl.PopulateSessionsList(ListBoxSessions);
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
