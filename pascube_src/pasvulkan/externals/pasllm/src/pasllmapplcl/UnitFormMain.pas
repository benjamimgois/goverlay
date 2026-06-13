unit UnitFormMain;
{$ifdef fpc}
 {$mode delphi}
 {$ifdef cpui386}
  {$define cpu386}
 {$endif}
 {$ifdef cpu386}
  {$asmmode intel}
 {$endif}
 {$ifdef cpuamd64}
  {$asmmode intel}
 {$endif}
 {$ifdef FPC_LITTLE_ENDIAN}
  {$define LITTLE_ENDIAN}
 {$else}
  {$ifdef FPC_BIG_ENDIAN}
   {$define BIG_ENDIAN}
  {$endif}
 {$endif}
 {-$pic off}
 {$ifdef fpc_has_internal_sar}
  {$define HasSAR}
 {$endif}
 {$ifdef FPC_HAS_TYPE_EXTENDED}
  {$define HAS_TYPE_EXTENDED}
 {$else}
  {$undef HAS_TYPE_EXTENDED}
 {$endif}
 {$ifdef FPC_HAS_TYPE_DOUBLE}
  {$define HAS_TYPE_DOUBLE}
 {$else}
  {$undef HAS_TYPE_DOUBLE}
 {$endif}
 {$ifdef FPC_HAS_TYPE_SINGLE}
  {$define HAS_TYPE_SINGLE}
 {$else}
  {$undef HAS_TYPE_SINGLE}
 {$endif}
 {$define CAN_INLINE}
 {$define HAS_ADVANCED_RECORDS}
{$else}
 {$realcompatibility off}
 {$localsymbols on}
 {$define LITTLE_ENDIAN}
 {$ifndef cpu64}
  {$define cpu32}
 {$endif}
 {$define HAS_TYPE_EXTENDED}
 {$define HAS_TYPE_DOUBLE}
 {$define HAS_TYPE_SINGLE}
 {$undef CAN_INLINE}
 {$undef HAS_ADVANCED_RECORDS}
{$endif}

interface

uses Classes,SysUtils,Forms,Controls,Graphics,Dialogs,StdCtrls,ExtCtrls,
     ComCtrls,Menus,
     {$ifdef fpc}
     LCLType,LCLIntf,
     LCLVersion,LResources, PairSplitter,
     {$endif}
     PasLLM,PasLLMChatControl;

type { TFormMain }
     TFormMain=class(TForm)
      ButtonNew: TButton;
      EditSessionName: TEdit;

       // UI components
       fChatControl:TPasLLMChatControl;
       FlowPanel1: TFlowPanel;
       ListBoxSessions: TListBox;
       MenuEditSeparator: TMenuItem;
       PanelLeftBottom: TPanel;
       PanelSessions: TPanel;
       PanelLeftTop: TPanel;
       PanelBottom: TPanel;
       PanelLeft: TPanel;
       PanelChat: TPanel;
       PanelTop:TPanel;
       MainMenu:TMainMenu;
       MenuFile:TMenuItem;
       MenuFileExit:TMenuItem;
       MenuEdit:TMenuItem;
       MenuEditClear:TMenuItem;
       MenuEditCopy:TMenuItem;
       MenuEditSelectAll:TMenuItem;
       MenuHelp:TMenuItem;
       MenuHelpAbout:TMenuItem;
       Splitter1: TSplitter;
       StatusBar1: TStatusBar;

       // Event handlers
       procedure EditSessionNameChange(Sender: TObject);
       procedure EditSessionNameExit(Sender: TObject);
       procedure FormCreate(aSender:TObject);
       procedure FormDestroy(aSender:TObject);
       procedure FormResize(aSender:TObject);
       procedure ButtonRefreshClick(aSender:TObject);
       procedure ComboModelChange(aSender:TObject);
       
       // Session management event handlers
       procedure ButtonNewClick(aSender:TObject);
       procedure ListBoxSessionsClick(aSender:TObject);
       procedure ListBoxSessionsDblClick(aSender:TObject);
       procedure ListBoxSessionsKeyDown(aSender:TObject;var aKey:Word;aShift:TShiftState);
       procedure EditSessionNameKeyPress(aSender:TObject;var aKey:char);
       
       procedure ChatControlSendPrompt(aSender:TObject;const aPrompt:TPasLLMUTF8String);
       procedure ChatControlModelChanged(aSender:TObject;const aModel:TPasLLMUTF8String);
       procedure ChatControlRequestModelList(aSender:TObject;var aModels:TPasLLMChatControl.TPasLLMModels);
       procedure MenuFileExitClick(aSender:TObject);
       procedure MenuEditClearClick(aSender:TObject);
       procedure MenuEditCopyClick(aSender:TObject);
       procedure MenuEditSelectAllClick(aSender:TObject);
       procedure MenuHelpAboutClick(aSender:TObject);

     public

       // Internal methods
       procedure SetupUI;
       procedure UpdateModelCombo;
       procedure AddDemoMessages;
       
       // Session management methods
       procedure RefreshSessionsList;
       procedure LoadSelectedSession;
       procedure DeleteSelectedSession;
       procedure CreateNewSession;
       procedure SaveCurrentSession;

     end;

var FormMain:TFormMain;

implementation

{$R *.lfm}

{ TFormMain }

procedure TFormMain.FormCreate(aSender:TObject);
begin

 WindowState:=wsMaximized;

 // Setup UI
 SetupUI;
 
 // Update model list
 UpdateModelCombo;

 // Add some demo messages to show the chat control
 AddDemoMessages;

end;

procedure TFormMain.EditSessionNameChange(Sender: TObject);
begin
end;

procedure TFormMain.EditSessionNameExit(Sender: TObject);
begin
 if assigned(fChatControl) then begin
  fChatControl.UpdateCurrentSessionTitle(EditSessionName.Text);
  fChatControl.PopulateSessionsList(ListBoxSessions);
 end;
end;

procedure TFormMain.FormDestroy(aSender:TObject);
begin
 // Nothing to clean up - TPasLLMChatControl handles its own resources
end;

procedure TFormMain.FormResize(aSender:TObject);
begin
 // Chat control automatically resizes due to Align=alClient
end;

procedure TFormMain.SetupUI;
begin
 // Create chat control (custom component must be created in code)
 fChatControl:=TPasLLMChatControl.Create(Self);
 fChatControl.Parent:=PanelChat;
 fChatControl.Align:=alClient;
 fChatControl.StatusBar:=StatusBar1;
 fChatControl.EditSessionName:=EditSessionName;
 fChatControl.OnSendPrompt:=ChatControlSendPrompt;
 fChatControl.OnModelChanged:=ChatControlModelChanged;
 fChatControl.OnRequestModelList:=ChatControlRequestModelList;
 
 // Wire up session management UI events
 ButtonNew.OnClick:=ButtonNewClick;
 ListBoxSessions.OnClick:=ListBoxSessionsClick;
 ListBoxSessions.OnDblClick:=ListBoxSessionsDblClick;
 ListBoxSessions.OnKeyDown:=ListBoxSessionsKeyDown;
 EditSessionName.OnKeyPress:=EditSessionNameKeyPress;
 
 // Initial session list refresh
 RefreshSessionsList;

 fChatControl.PopulateSessionsList(ListBoxSessions);

end;

procedure TFormMain.ButtonRefreshClick(aSender:TObject);
begin
 UpdateModelCombo;
end;

procedure TFormMain.ComboModelChange(aSender:TObject);
begin
{if ComboModel.ItemIndex>=0 then begin
  fChatControl.SelectedModel:=ComboModel.Items[ComboModel.ItemIndex];
 end;}
end;

procedure TFormMain.ChatControlSendPrompt(aSender:TObject;const aPrompt:TPasLLMUTF8String);
begin
 // The chat control handles everything automatically via its internal threading
 // Auto-save is handled by TPasLLMChatControl on every message change
end;

procedure TFormMain.ChatControlModelChanged(aSender:TObject;const aModel:TPasLLMUTF8String);
begin
 // Update our combo box to match the chat control's selection
//ComboModel.ItemIndex:=ComboModel.Items.IndexOf(aModel);
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

procedure TFormMain.MenuFileExitClick(aSender:TObject);
begin
 Close;
end;

procedure TFormMain.MenuEditClearClick(aSender:TObject);
begin
 fChatControl.Clear;
end;

procedure TFormMain.MenuEditCopyClick(aSender:TObject);
begin
 fChatControl.CopyLastAssistantMessage;
end;

procedure TFormMain.MenuEditSelectAllClick(aSender:TObject);
begin
 fChatControl.SelectAll;
end;

procedure TFormMain.MenuHelpAboutClick(aSender:TObject);
begin
 ShowMessage('PasLLM Chat Control Demo'+#13#10+
             'Demonstrates the TControlChat component'+#13#10+
             'for PasLLM (Pascal AI Language Model)'+#13#10#13#10+
             'Copyright (C) 2025 Benjamin Rosseaux');
end;

procedure TFormMain.UpdateModelCombo;
{var Models:TPasLLMChatControl.TPasLLMModels;
    Index:TPasLLMInt32;}
begin
 // Get model list from chat control
//ChatControlRequestModelList(fChatControl,Models);
 
{ComboModel.Items.BeginUpdate;
 try
  ComboModel.Clear;
  for Index:=0 to Length(Models)-1 do begin
   ComboModel.Items.Add(Models[Index]);
  end;
  
  // Select first model if available
  if ComboModel.Items.Count>0 then begin
   ComboModel.ItemIndex:=0;
   ComboModelChange(ComboModel);
  end;
 finally
  ComboModel.Items.EndUpdate;
 end;}
end;

procedure TFormMain.AddDemoMessages;
begin
 // Add some demo messages to show the chat control functionality
 exit;
 fChatControl.AddMessage(TPasLLMChatControl.TChatRole.Assistant,
   '|**A**|**B**|**C**|'+#13#10+
   '|---|---|---|'+#13#10+
   '| D | E | F<br>G<br>H |'+#13#10+
   '| D | E<br>F<br>G | H |'+#13#10+
   '| D<br>E<br>F | G | H |'+#13#10+
   ''+#13#10+#13#10);
 fChatControl.AddMessage(TPasLLMChatControl.TChatRole.Assistant,'[Hello World](uuu');
 fChatControl.AddMessage(TPasLLMChatControl.TChatRole.Assistant,'**2 + 2 = 4** 6 + 6 = 12');
 fChatControl.AddMessage(TPasLLMChatControl.TChatRole.Assistant,'6^2');
 fChatControl.AddMessage(TPasLLMChatControl.TChatRole.Assistant,'6+6=12');
 fChatControl.AddMessage(TPasLLMChatControl.TChatRole.Assistant,
   ''+#10+
   '* | *a*|*b* | *c*|'+#10+
   '  |----|----|----|'+#10+
   '  |  d |  e |  f |'+#10+
   ''+#10);
 fChatControl.AddMessage(TPasLLMChatControl.TChatRole.Assistant,
   ''+#10+
   'Hello! Yes, absolutely — here are some practical and realistic ideas for making money, depending on your skills, time, location, and goals. Whether you''re looking for side income, a full-time job, or passive income, here’s a mix of options:'+#10+
   ''+#10+
   '---'+#10+
   ''+#10+
   '### 💡 **Side Hustles (Low Time, Low Risk)**'+#10+
   '1. **Freelancing**'+#10+
   '   - Offer services like writing, graphic design, copywriting, video editing, or translation.'+#10+
   '   - Platforms: Fiverr, Upwork, Freelancer, or LinkedIn.'+#10+
   ''+#10+
   '2. **Teaching or Tutoring**'+#10+
   '   - Teach languages, math, or music online via Zoom or in person.'+#10+
   '   - Great for students or teachers.'+#10+
   ''+#10);
 fChatControl.AddMessage(TPasLLMChatControl.TChatRole.Assistant,
   ''+#10+
   'A **HTML renderer** is a software component or system that takes raw HTML (HyperText Markup Language) code and converts it into a visual, interactive web page that can be displayed in a web browser or other viewing environment.'+#10+
   ''+#10+
{  '### Key Responsibilities of an HTML Renderer:'+#10+
   '1. **Parsing HTML**: Reads the raw HTML text and constructs a **Document Object Model (DOM)** tree from the markup.'+#10+
   '2. **Cascading Style Sheets (CSS) Processing**: Applies styles from CSS files or inline styles to elements in the DOM.'+#10+
   '3. **Layout (or Reflow)**: Calculates the position, size, and spacing of all elements on the page based on the DOM and CSS.'+#10+
   '4. **Painting**: Converts the layout into visual pixels by drawing elements (text, borders, backgrounds, etc.) onto a canvas.'+#10+
   '5. **Compositing**: Combines multiple layers (e.g., from animations, transparency, or scrollable regions) into a final image displayed on screen.'+#10+
   '6. **Handling Interactivity**: Processes user events (like clicks, scrolls, and keyboard input) and updates the DOM and visual output accordingly.'+#10+
   ''+#10+}
   '### Examples of HTML Renderers:'+#10+
   '- **Web Browsers**:'+#10+
   '  - **Blink** (used in Chrome and Edge)'+#10+
   '  - **WebKit** (used in Safari)'+#10+
   '  - **Gecko** (used in Firefox)'+#10+
   ''+#10+
   '- **Headless Renderers**:'+#10+
   ''+#10+
   '  - **Puppeteer** (Node.js library using Chromium’s renderer)'+#10+
   ''+#10+
   '  - **Playwright**, **Webkit**, **Cypress** (for testing and automation)'+#10+
   ''+#10+
   '- **Server-side Renderers**:'+#10+
   '  - **Next.js (SSR/SSG)** using React with a renderer on the server'+#10+
   '  - **Nuxt.js** with Vue.js'+#10+
   '- **Native Apps**:'+#10+
   '  - **WebView components** in Android (Android WebView), iOS (WKWebView), and React Native (React Native WebView)'+#10+
   ''+#10+
   '### Why HTML Renderers Matter:'+#10+
   '- They bridge the gap between **structured HTML/CSS/JS** and **user-facing visual content**.'+#10+
   '- Enable responsive, dynamic, and interactive web experiences.'+#10+
   '- Allow developers to write declarative markup and rely on the renderer to handle the visual presentation efficiently.'+#10+
   ''+#10+
   '### Summary:'+#10+
   '> An HTML renderer is the engine that transforms HTML, CSS, and JavaScript into a fully rendered, interactive webpage—turning code into what users see and interact with in their browsers.'+#10+
   ''+#10+
   'Here are some code blocks for you:'+#10+
   ''+#10+
   '**Basic Code Blocks**'+#10+
   ''+#10+
   '*   **Hello World**'+#10+
   '```python'+#10+
   'print("Hello, World!")'+#10+
   '```'+#10+
   '*   **Basic Calculator**'+#10+
   '```python'+#10+
   'def calculate_area(length, width):'+#10+
   '    return length * width'+#10+
   ''+#10+
   'length = 5'+#10+
   'width = 3'+#10+
   'print(calculate_area(length, width))'+#10+
   '```'+#10+
   ''+#10+
   '```md'+#10+
   '```js'+#10+
   'var a=1;'+#10+
   'var a=1;'+#10+
   '```'+#10#10+
   '```js'+#10+
   'var a=1;'+#10+
   'var a=1;'+#10+
   '```'+#10+
   '```'+#10+
   '');
 exit;
 fChatControl.AddMessage(TPasLLMChatControl.TChatRole.Assistant,
   '```javascript'+#13#10+
   'Hello this is a test'+#13#10+#13#10+
   ' Hello this is a test'+#13#10+#13#10+
   '  Hello this is a test'+#13#10+
   '   Hello this is a test'+#13#10+
   '    Hello this is a test'+#13#10+
   '```'+#13#10+#13#10);
 fChatControl.AddMessage(TPasLLMChatControl.TChatRole.System_,'Welcome to the **PasLLM** Chat Control Demo! It''s a good day for to live. Hello, how does this chat control work?');
 fChatControl.AddMessage(TPasLLMChatControl.TChatRole.Assistant,
   'Here is a comparison table between the US Dollar (USD) and the Euro (EUR):'+#13#10+
   ''+#13#10+
   '**Note:** The exchange rates provided are subject to change and may not reflect the current exchange rates. For the most up-to-date and accurate rates, please check the current exchange rates on a reliable source such as XE.com or a financial institution.'+#13#10+
   ''+#13#10+
   '| **Category** | **US Dollar (USD)** | **Euro (EUR)** |'+#13#10+
   '| --- | --- | --- |'+#13#10+
   '| **1. Currency** | $100 = 1 EUR | €100 = 1 EUR |'+#13#10+
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
 {fChatControl.AddMessage(TPasLLMChatControl.TChatRole.System_,'Welcome to the PasLLM Chat Control Demo!');
 fChatControl.AddMessage(TPasLLMChatControl.TChatRole.User,'Hello, how does this chat control work?');
 fChatControl.AddMessage(TPasLLMChatControl.TChatRole.Assistant,
  'This is the TControlChat component for PasLLM. It provides:'+#13#10+
  '• Message bubbles with role-based colors and alignment'+#13#10+
  '• Real-time token streaming during generation'+#13#10+
  '• Model selection dropdown'+#13#10+
  '• Prompt history with up/down arrow navigation'+#13#10+
  '• Copy and selection features'+#13#10+
  '• Keyboard shortcuts and mouse interaction'+#13#10#13#10+
  'Select a model from the dropdown above and start chatting!');
 fChatControl.AddMessage(TPasLLMChatControl.TChatRole.User,'What keyboard shortcuts are available?');
 fChatControl.AddMessage(TPasLLMChatControl.TChatRole.Assistant,
  'Available keyboard shortcuts:'+#13#10+
  '• Enter: Send message'+#13#10+
  '• Shift+Enter: New line in input'+#13#10+
  '• Escape: Stop generation'+#13#10+
  '• Up/Down arrows: Navigate prompt history'+#13#10+
  '• Ctrl+A: Select all chat content'+#13#10+
  '• Ctrl+C: Copy selection'+#13#10+
  '• Page Up/Down: Scroll chat'+#13#10+
  '• Ctrl+Home/End: Jump to top/bottom'); //}
end;

// Session management implementations

procedure TFormMain.ButtonNewClick(aSender:TObject);
begin
 CreateNewSession;
end;

procedure TFormMain.ListBoxSessionsClick(aSender:TObject);
begin
 if assigned(fChatControl) then begin
  fChatControl.OnSessionSelected(ListBoxSessions.ItemIndex);
 end;
end;

procedure TFormMain.ListBoxSessionsDblClick(aSender:TObject);
begin
 if assigned(fChatControl) then begin
  fChatControl.LoadSession('',ListBoxSessions.ItemIndex);
 end;
end;

procedure TFormMain.ListBoxSessionsKeyDown(aSender:TObject;var aKey:Word;aShift:TShiftState);
begin
 if assigned(fChatControl) then begin
  case aKey of
   VK_RETURN:begin // Enter
    fChatControl.LoadSession('',ListBoxSessions.ItemIndex);
    aKey:=0;
   end;
   VK_DELETE:begin // Delete
    if ssCtrl in aShift then begin
     fChatControl.DeleteSelectedSession(ListBoxSessions.ItemIndex);
     aKey:=0;
    end;
   end;
  end;
 end;
end;

procedure TFormMain.EditSessionNameKeyPress(aSender:TObject;var aKey:char);
begin
 if (aKey=#13) and assigned(fChatControl) then begin // Enter
  // Update session title and auto-save
  fChatControl.UpdateCurrentSessionTitle(Trim(EditSessionName.Text));
  aKey:=#0;
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
