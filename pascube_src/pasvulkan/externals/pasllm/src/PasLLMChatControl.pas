(******************************************************************************
 *                         Chat Control for PasLLM                            *
 ******************************************************************************
 *                        Version 2025-08-28-00-00-0000                       *
 ******************************************************************************
 *                                   License                                  *
 *============================================================================*
 *                                                                            *
 * It is dual-licensed under the terms of the AGPL 3.0 license and            *
 * a commercial license for proprietary use. See the license.txt file in the  *
 * project root for details.                                                  *
 *                                                                            *
 ******************************************************************************
 *                               AGPL 3.0 license                             *
 *============================================================================*
 *                                                                            *
 * PasLLM - A LLM interference engine                                         *
 * Copyright (C) 2025-2025, Benjamin Rosseaux (benjamin@rosseaux.com)         *
 *                                                                            *
 *  This program is free software: you can redistribute it and/or modify      *
 *  it under the terms of the GNU Affero General Public License as published  *
 *  by the Free Software Foundation, either version 3 of the License, or      *
 *  (at your option) any later version.                                       *
 *                                                                            *
 *  This program is distributed in the hope that it will be useful,           *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of            *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             *
 *  GNU Affero General Public License for more details.                       *
 *                                                                            *
 *  You should have received a copy of the GNU Affero General Public License  *
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.    *
 *                                                                            *
 ******************************************************************************
 *                              Commercial license                            *
 *============================================================================*
 *                                                                            *
 * Contact the author (benjamin@rosseaux.com) for details, as it is custom    *
 * for every use case.                                                        *
 *                                                                            *
 ******************************************************************************
 *                  General guidelines for code contributors                  *
 *============================================================================*
 *                                                                            *
 * 1. Make sure you are legally allowed to make a contribution under the same *
 *    license(s).                                                             *
 * 2. The license headers goes at the top of each source file, with           *
 *    appropriate copyright notice.                                           *
 * 3. After a pull request, check the status of your pull request on          *
      http://github.com/BeRo1985/PasLLM                                       *
 * 4. Write code, which is compatible with Delphi >=11.2 and FreePascal       *
 *    >= 3.3.1                                                                *
 * 5. Don't use Delphi-only, FreePascal-only or Lazarus-only libraries/units, *
 *    but if needed, make it out-ifdef-able.                                  *
 * 6. No use of third-party libraries/units as possible, but if needed, make  *
 *    it out-ifdef-able.                                                      *
 * 7. Try to use const when possible.                                         *
 * 8. Make sure to comment out writeln, used while debugging.                 *
 * 9. Make sure the code compiles on 32-bit and 64-bit platforms (x86-32,     *
 *    x86-64, ARM, ARM64, etc.).                                              *
 * 10. Make sure the code runs on platforms with weak and strong memory       *
 *     models without any issues.                                             *
 *                                                                            *
 ******************************************************************************)
unit PasLLMChatControl;
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
{$overflowchecks off}
{$rangechecks off}
{$ifdef Win32}
 {$define Windows}
{$endif}
{$ifdef Win64}
 {$define Windows}
{$endif}
{$ifdef PasHTMLDownCanvasRendererFMX}
 {$define FMX}
{$else}
 {$undef FMX}
{$endif}

interface

uses {$if defined(Unix)}
      BaseUnix,
      Unix,
      UnixType,
      {$ifdef linux}
       linux,
      {$endif}
      ctypes,
     {$elseif defined(Windows)}
      Windows,
      {$ifdef fpc}jwawinbase,{$endif}
      {$if not (defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless))}Messages,{$ifend}
      MMSystem,
      Registry,
      {$if not (defined(PasVulkanUseSDL2) and not defined(PasVulkanHeadless))}MultiMon,ShellAPI,{$ifend}
     {$ifend}
     {$ifdef POSIX}
     Posix.Stdlib,
    {$endif}
     PasJSON,
     SyncObjs,
     Classes,SysUtils,
{$ifdef FMX}
     System.Types,
     System.UITypes,
     FMX.Types,
     FMX.Forms,
     FMX.Graphics,
     FMX.Controls,
     FMX.StdCtrls,
     FMX.Menus,
     FMX.ListBox,
     FMX.Edit,
     FMX.Memo,
     FMX.Dialogs,
     FMX.Pickers,
     FMX.Clipboard,
     FMX.Platform,
     FMX.Layouts,
{$else}
     Forms,Controls,Graphics,Dialogs,StdCtrls,ExtCtrls,
     ComCtrls,Menus,
     ClipBrd,
{$endif}
     {$ifdef fpc}
     LCLType,LCLIntf,LMessages,
     LCLVersion,LResources,
     {$endif}
     Generics.Collections,{$ifndef FMX}Types,{$endif}Math,
     PasMP,PasLLM,
     PasHTMLDown,PasHTMLDownCanvasRenderer,
     httpsend,
     ssl_openssl;

type { TPasLLMChatControl }
     TPasLLMChatControl=class({$ifdef FMX}FMX.Controls.TControl{$else}{$ifdef fpc}TCustomControl{$else}TCustomControl{$endif}{$endif})
      public

       // Constants
       const {$ifndef FMX}WM_THROTTLED_REPAINT={$ifdef fpc}LM_USER{$else}WM_USER{$endif}+100;{$endif}

             // RGB color palette
             // Cyan-Blue Azure #4092bf
             // Medium Sky Blue #7fdcf4
             // Ateneo Blue #103e61
             // Light Slate Gray #6c8c9c
             // Light Silver #d2d9e2
             // Queen Blue #446484

{$ifdef FMX}
             // Default colors (ARGB)
             DEF_COLOR_BACKGROUND=TAlphaColor($ff313235);
             DEF_COLOR_USER=TAlphaColor($ff4092bf);
             DEF_COLOR_ASSISTANT=TAlphaColor($ff446484);
             DEF_COLOR_SYSTEM=TAlphaColor($ffd2d9e2);
             DEF_COLOR_TOOL=TAlphaColor($ff103e61);
             DEF_COLOR_SCROLL_BUTTON=TAlphaColor($ff505050); // Dark gray
             DEF_COLOR_SCROLL_BUTTON_HOVER=TAlphaColor($ff808080); // Bright gray
             DEF_COLOR_SCROLL_BUTTON_ICON=TAlphaColor($ffffffff);
{$else}
             // Default colors (BGR)
             DEF_COLOR_BACKGROUND=$353231;
             DEF_COLOR_USER=$bf9240;
             DEF_COLOR_ASSISTANT=$846444;
             DEF_COLOR_SYSTEM=$e2d9d2;
             DEF_COLOR_TOOL=$613e10;
             DEF_COLOR_SCROLL_BUTTON=$505050; // Dark gray
             DEF_COLOR_SCROLL_BUTTON_HOVER=$808080; // Bright gray
             DEF_COLOR_SCROLL_BUTTON_ICON=clWhite;
{$endif}

             MaxHeightString='AgIEi!|';

       // Scoped enums
       type TChatRole=(System_,User,Assistant,Tool);

            // Nested types
            TPasLLMModels=array of TPasLLMUTF8String;

            TModel=record
             FileName:TPasLLMUTF8String;
            end;
            PModel=^TModel;
            TModels=array of TModel;

            // Session database types
            TSessionDatabaseEntry=class
             private
              fTitle:TPasLLMUTF8String;
              fDateTime:TDateTime;
              fFileName:TPasLLMUTF8String;
              fModelInfo:TPasLLMUTF8String;
             public
              constructor Create;
              destructor Destroy; override;
              property Title:TPasLLMUTF8String read fTitle write fTitle;
              property DateTime:TDateTime read fDateTime write fDateTime;
              property FileName:TPasLLMUTF8String read fFileName write fFileName;
              property ModelInfo:TPasLLMUTF8String read fModelInfo write fModelInfo; // Model used in this session
            end;
            
            TSessionDatabaseEntries=array of TSessionDatabaseEntry;

            TSessionDatabase=class
             private
              fEntries:TSessionDatabaseEntries;
              fCountEntries:TPasLLMInt32;
              fDatabaseFile:TPasLLMUTF8String;
              fModified:Boolean;
             public
              constructor Create(const aDatabaseFile:TPasLLMUTF8String);
              destructor Destroy; override;
              procedure LoadFromFile;
              procedure SaveToFile;
              procedure AddEntry(const aTitle,aFileName,aModelInfo:TPasLLMUTF8String;const aDateTime:TDateTime);
              procedure UpdateEntry(const aFileName,aTitle,aModelInfo:TPasLLMUTF8String;const aDateTime:TDateTime);
              procedure DeleteEntry(const aFileName:TPasLLMUTF8String);
              function FindEntry(const aFileName:TPasLLMUTF8String):TPasLLMInt32;
              function GetEntry(const aIndex:TPasLLMInt32):TSessionDatabaseEntry;
              function GetCount:TPasLLMInt32;
              procedure Clear(const aSaveToFile:Boolean=true);
              procedure SortByDateTime;
              property Modified:Boolean read fModified;
            end;

            { TChatMessage }

            TChatMessage=class
             private
              fChatControl:TPasLLMChatControl;
              fRole:TChatRole;
              fText:TPasLLMUTF8String;
              fNewText:Boolean;
              fTimeUTC:TDateTime;
              fLayoutRect:{$ifdef FMX}TRectF{$else}TRect{$endif};
              fStreaming:boolean;
              fSelected:boolean;
              fMarkDownRender:TMarkDownRenderer;
              fHoveredURL:TPasLLMUTF8String;
              fLastHitTestX,fLastHitTestY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
             public
              constructor Create(const aChatControl:TPasLLMChatControl;const aRole:TChatRole;const aText:TPasLLMUTF8String='');
              destructor Destroy; override;
              procedure WordWrap(const aCanvas:TCanvas;const aText:TPasLLMUTF8String;const aMaxWidth:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};var aLines:TPasLLMModels;var aLineCount:TPasLLMInt32);
              procedure CalculateLayout(const aCanvas:TCanvas;const aViewPortRect:{$ifdef FMX}TRectF{$else}TRect{$endif};var aY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aMaxWidth,aLineHeight:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif});
              procedure DrawTypingIndicator(const aCanvas:TCanvas;const aRect:{$ifdef FMX}TRectF{$else}TRect{$endif});
              procedure Draw(const aCanvas:TCanvas;const aRect:{$ifdef FMX}TRectF{$else}TRect{$endif});
              function HitTestLink(const aX,aY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};out aLink:TPasLLMUTF8String):Boolean;
              procedure HandleMouseMove(const aX,aY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif});
              function HandleMouseClick(const aX,aY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif}):Boolean;
             published
              property ChatControl:TPasLLMChatControl read fChatControl;
              property Role:TChatRole read fRole;
              property Text:TPasLLMUTF8String read fText write fText;
              property NewText:Boolean read fNewText write fNewText;
             public
              property TimeUTC:TDateTime read fTimeUTC;
              property LayoutRect:{$ifdef FMX}TRectF{$else}TRect{$endif} read fLayoutRect write fLayoutRect;
             published
              property Streaming:boolean read fStreaming write fStreaming;
              property Selected:boolean read fSelected write fSelected;
            end;

            TChatMessages=TObjectList<TChatMessage>;

            // Nested message area control

            { TChatMessageAreaControl }

            TChatMessageAreaControl=class({$ifdef FMX}FMX.Controls.TControl{$else}TCustomControl{$endif})
             private

              // Reference to the parent chat control
              fChatControl:TPasLLMChatControl;

              fScrollBar:TScrollBar;
              fIsScrollOnBottom:boolean;

              // Scroll to bottom button
              fScrollToBottomButtonHover:boolean;
              fBottomScrollButtonRect:{$ifdef FMX}TRectF{$else}TRect{$endif};

              // Local viewport rect cached from ClientRect
              fViewPortRect:{$ifdef FMX}TRectF{$else}TRect{$endif};

              // Scrolling
              fScrollY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
              fAutoScrollMaxScrollY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
              fMaxScrollY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};

              // Font
              fFontSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};

              // Selection
              fSelectionStart:{$ifdef FMX}TPointF{$else}TPoint{$endif};
              fSelectionEnd:{$ifdef FMX}TPointF{$else}TPoint{$endif};
              fSelecting:boolean;
              fSelectedText:TPasLLMUTF8String;

              // Popup menu
              fPopupMenu:TPopupMenu;
              fPopupMenuItemSelect:TMenuItem;
              fPopupMenuItemUnselect:TMenuItem;
              fPopupMenuItemSeparator1:TMenuItem;
              fPopupMenuItemSelectAll:TMenuItem;
              fPopupMenuItemUnselectAll:TMenuItem;
              fPopupMenuItemSeparator2:TMenuItem;
              fPopupMenuItemCopy:TMenuItem;
              fPopupMenuItemSeparator3:TMenuItem;
              fPopupMenuItemClear:TMenuItem;

{$ifndef fmx}
{$ifndef fpc}
              fBitmap:TBitmap;
              procedure WMEraseBkGnd(var Message:TMessage); message WM_ERASEBKGND;
{$endif}
{$endif}

{$ifdef FMX}
              procedure ScrollBarOnChange(Sender:TObject);
{$else}
              procedure ScrollBarOnScroll(Sender:TObject;ScrollCode:TScrollCode;var ScrollPos:Integer);
{$endif}

             protected

              // Mouse events
              procedure MouseDown(aButton:TMouseButton;aShift:TShiftState;aX,aY:{$ifdef FMX}Single{$else}Integer{$endif}); override;
              procedure MouseMove(aShift:TShiftState;aX,aY:{$ifdef FMX}Single{$else}Integer{$endif}); override;
              procedure MouseUp(aButton:TMouseButton;aShift:TShiftState;aX,aY:{$ifdef FMX}Single{$else}Integer{$endif}); override;
{$ifdef FMX}
              procedure DoMouseLeave; override;
{$else}
{$ifdef fpc}
              procedure MouseLeave; override;
{$endif}
{$endif}

              // Keyboard events
              procedure KeyDown(var aKey:Word;{$ifdef FMX}var aKeyChar:WideChar;{$endif}aShift:TShiftState); override;

              // Mouse wheel events
{$ifdef FMX}
              procedure MouseWheel(Shift:TShiftState;WheelDelta:Integer;var Handled:Boolean); override;
{$else}
              function DoMouseWheelDown(aShift:TShiftState;aMousePos:TPoint):boolean; override;
              function DoMouseWheelUp(aShift:TShiftState;aMousePos:TPoint):boolean; override;
{$endif}

              // General events
              procedure Paint; override;
              procedure Resize; override;
{$ifdef FMX}
              procedure Invalidate;
              procedure DoRealign; override;
{$else}
              procedure CreateWnd; override;
{$endif}

              // Layout and rendering
              procedure CalculateLayout;
              procedure UpdateScrollBounds;

              procedure DrawSelectionHighlight(const aCanvas:TCanvas);

              function GetMessageRectByIndex(const aIndex:TPasLLMInt32):{$ifdef FMX}TRectF{$else}TRect{$endif};

              procedure UpdateScrollToBottomButtonRect;

              // Scrolling
              procedure ScrollTo(const aY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif});
              procedure ScrollToBottom;
              procedure AutoScrollToBottom;
              procedure EnsureVisible(const aRect:{$ifdef FMX}TRectF{$else}TRect{$endif});

              // Selection and interaction
              function MessageAtPoint(const aX,aY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif}):TPasLLMInt32;
              procedure SelectMarkedMessages;

              // Utility
              procedure Clear;

              // Popup menu handlers
              procedure OnMenuSelectClick(aSender:TObject);
              procedure OnMenuUnselectClick(aSender:TObject);
              procedure OnMenuSelectAllClick(aSender:TObject);
              procedure OnMenuUnselectAllClick(aSender:TObject);
              procedure OnMenuCopyClick(aSender:TObject);
              procedure OnMenuClearClick(aSender:TObject);
              procedure CreatePopupMenu;
             public
              constructor Create(aOwner:TComponent;aChatControl:TPasLLMChatControl); reintroduce;
              destructor Destroy; override;
              property SelectedText:TPasLLMUTF8String read fSelectedText;
            end;

            // Event types
            TLinkClickEvent=procedure(aSender:TObject;const aURL:TPasLLMUTF8String) of object;
            TLinkHoverEvent=procedure(aSender:TObject;const aURL:TPasLLMUTF8String;const aHovering:Boolean) of object;
            TSendPromptEvent=procedure(aSender:TObject;const aPrompt:TPasLLMUTF8String) of object;
            TModelChangedEvent=procedure(aSender:TObject;const aModel:TPasLLMUTF8String) of object;
            TRequestModelListEvent=procedure(aSender:TObject;var aModels:TPasLLMModels) of object;
            TLoadToolConfigurationEvent=procedure(aSender:TObject;const aSession:TPasLLMModelInferenceInstance.TChatSession) of object;

            // Threading types
            TStringQueue=TPasMPUnboundedQueue<TPasLLMUTF8String>;

            { TChatThread }

            TChatThread=class(TPasMPThread)
             public
              const ActionNone=0;
                    ActionNewModel=1;
                    ActionLoadSession=2;
                    ActionNewSession=3;
                    ActionAborted=4;
                    ActionToolsChanged=5;
                    ActionTerminated=6;
             private
              fChatControl:TPasLLMChatControl;
              fInputQueue:TStringQueue;
              fOutputQueue:TStringQueue;
              fOutputQueueLock:TPasMPCriticalSection;
              fEvent:TPasMPEvent;
              fActionDoneEvent:TPasMPEvent; // Event signaled when action is complete
              fAction:TPasMPInt32; // Atomic action flag
              fProcessing:TPasMPBool32;
              fActiveModel:TPasLLMInt32;
              fModel:TPasMPInt32;
              fSessionToLoad:TPasLLMUTF8String; // Session filename for ActionLoadSession
              fChatSession:TPasLLMModelInferenceInstance.TChatSession;
              // State change synchronization
              fCachedSender:TPasLLMModelInferenceInstance.TChatSession;
              fCachedOldState:TPasLLMModelInferenceInstance.TChatSession.TState;
              fCachedNewState:TPasLLMModelInferenceInstance.TChatSession.TState;
              // Message synchronization
              fCachedMessage:TPasLLMModelInferenceInstance.TChatSession.TMessage;
              // Token synchronization
              fCachedToken:TPasLLMUTF8String;
              // Model index synchronization
              fCachedModelIndex:TPasLLMInt32;
              function OnInputHook(const aSender:TPasLLMModelInferenceInstance.TChatSession;const aPrompt:TPasLLMUTF8String):TPasLLMUTF8String;
              procedure OnOutputHook(const aSender:TPasLLMModelInferenceInstance.TChatSession;const aOutput:TPasLLMUTF8String);
              function OnCheckTerminatedHook(const aSender:TPasLLMModelInferenceInstance.TChatSession):boolean;
              function OnCheckAbortHook(const aSender:TPasLLMModelInferenceInstance.TChatSession):boolean;
              procedure OnSideTurnHook(const aSender:TPasLLMModelInferenceInstance.TChatSession;const aSide:TPasLLMUTF8String);
              procedure SessionOnStateChange(const aSender:TPasLLMModelInferenceInstance.TChatSession;const aOldState,aNewState:TPasLLMModelInferenceInstance.TChatSession.TState);
              procedure SynchronizedSessionOnStateChange;
              procedure SynchronizedSessionOnUserSide;
              procedure SynchronizedSessionOnAssistantSide;
              procedure SynchronizedSessionOnToolSide;
              procedure SessionOnMessage(const aSender:TPasLLMModelInferenceInstance.TChatSession;const aMessage:TPasLLMModelInferenceInstance.TChatSession.TMessage);
              procedure SynchronizedSessionOnMessage;
              procedure SessionOnTokenGenerated(const aSender:TPasLLMModelInferenceInstance.TChatSession;const aToken:TPasLLMUTF8String);
              procedure SynchronizedSessionOnTokenGenerated;
              procedure SynchronizedSetToolsEnabled;
              procedure SynchronizedSetModelIndex;
              procedure SynchronizedSetMemoInputFocus;
              procedure SetSessionFromThread;
              procedure AddDefaultTools;
             protected
              procedure Execute; override;
             public
              constructor Create(const aChatControl:TPasLLMChatControl); reintroduce;
              destructor Destroy; override;
              property ChatSession:TPasLLMModelInferenceInstance.TChatSession read fChatSession;
            end;

      private

       // Data
       fMessages:TChatMessages;
       fSession:TPasLLMModelInferenceInstance.TChatSession;
       fCurrentStreamingIndex:TPasLLMInt32;
       fAutoScroll:boolean;
       fSelectedModel:TPasLLMUTF8String;
       fModels:TModels;

       // Threading
       fChatThread:TChatThread;
       fProcessing:TPasMPBool32;

       // Visual properties
       fMessagePadding:TPasLLMInt32;
       fMessageMargin:TPasLLMInt32;
       fLineSpacing:TPasLLMInt32;
       fMaxInputHeight:TPasLLMInt32;
       fWrapWidthPercent:TPasLLMInt32;
       fScrollButtonHorizontalPosition:TPasLLMFloat; // 0.0=left, 0.5=center, 1.0=right

       // Colors
       fColorBackground:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
       fColorUser:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
       fColorAssistant:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
       fColorSystem:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
       fColorTool:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
       fColorScrollButton:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
       fColorScrollButtonHover:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
       fColorScrollButtonIcon:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};

       // UI components
       fMessageArea:TChatMessageAreaControl;
       fStatusBar:TStatusBar;
{$ifdef FMX}
       fStatusBarLabel1:TLabel;
       fStatusBarLabel2:TLabel;
       fStatusBarLabel3:TLabel;
       fStatusBarLabel4:TLabel;
{$endif}
       fPanelInput:TPanel;
       fPanelButtons:TPanel;
{$ifdef FMX}
       fGridPanelLayout:TGridPanelLayout;
{$else}
{$ifndef fpc}
       fPanelChat:TPanel;
{$endif}
{$endif}
       fComboBoxModel:TComboBox;
       fMemoInput:TMemo;
       fButtonSend:TButton;
       fButtonStop:TButton;
       fButtonClear:TButton;
       fButtonCopyLast:TButton;
       fCheckBoxTools:TCheckBox;
       fTimerOutput:TTimer;

       // Rendering
       fViewportRect:TRect;
       fTypingStartTime:TPasLLMUInt64;
       fLastRepaintTime:TPasLLMUInt64;
       fRepaintPending:boolean;

       // Prompt history
       fPromptHistory:TPasLLMModels;
       fPromptHistoryCount:TPasLLMInt32;
       fHistoryIndex:TPasLLMInt32;

       // State tracking
       fIsWorking:boolean;
       fPendingTokens:TPasLLMUTF8String;

       // Events
       fOnLinkClick:TLinkClickEvent;
       fOnLinkHover:TLinkHoverEvent;
       fOnSendPrompt:TSendPromptEvent;
       fOnModelChanged:TModelChangedEvent;
       fOnRequestModelList:TRequestModelListEvent;
       fOnLoadToolConfigurationEvent:TLoadToolConfigurationEvent;

       // DPI
       fPPI:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};

       fOldWidth:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
       fOldHeight:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};

       fTavilyKey:TPasLLMUTF8String;

       fStorageDirectory:TPasLLMUTF8String;

       fModelDirectory:TPasLLMUTF8String;

       // Link tracking
       fCurrentHoveredURL:TPasLLMUTF8String;
       fOriginalCursor:TCursor;
       fCursorOverLink:Boolean;

       // Session management
       fCurrentSessionFileName:TPasLLMUTF8String;
       fSessionsDirectory:TPasLLMUTF8String;
       fSessionDatabase:TSessionDatabase; // JSON-based session database
       fUIListBox:TListBox; // Reference to UI listbox for session management
       fEditSessionName:TEdit; // Reference to UI edit box for session name
       fSessionListPopupMenu:TPopupMenu; // Context menu for session list

       fInLoadSession:Boolean;

       fToolsEnabled:Boolean;

       fLastTypingAnimationPhase:TPasLLMInt32;

       function GetTypingAnimationPhase:TPasLLMInt32;

       procedure SetToolsEnabled(const aToolsEnabled:Boolean);
       procedure DefaultLoadToolConfigurationEvent(aSender:TObject;const aSession:TPasLLMModelInferenceInstance.TChatSession);

       // Internal helpers
       function RoleToString(const aRole:TChatRole):TPasLLMUTF8String;
       function StringToRole(const aString:TPasLLMUTF8String):TChatRole;
       function GetRoleColor(const aRole:TChatRole):{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
       function GetRoleAlignment(const aRole:TChatRole):TAlignment;

       // Layout and rendering - moved to message area
       procedure CalculateLayout;

       // Input auto-grow
       procedure OnMemoInputChange(aSender:TObject);
//     function EstimateMemoContentHeightPx:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};

       // Scrolling
       procedure ScrollTo(const aY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif});
       procedure ScrollToBottom;
       procedure AutoScrollToBottom;
       procedure EnsureVisible(const aRect:{$ifdef FMX}TRectF{$else}TRect{$endif});

       // Input handling
       procedure SetupInputArea;
       procedure SetupMessageArea;
       procedure ScanForModels;
       procedure OnComboModelChangeClear;
       procedure OnComboModelChange(aSender:TObject);
       procedure OnMemoInputKeyDown(aSender:TObject;var aKey:Word;{$ifdef FMX}var aKeyChar:WideChar;{$endif}aShift:TShiftState);
       procedure OnButtonSendClick(aSender:TObject);
       procedure OnButtonStopClick(aSender:TObject);
       procedure OnButtonClearClick(aSender:TObject);
       procedure OnButtonCopyLastClick(aSender:TObject);
       procedure OnCheckBoxToolsClick(aSender:TObject);
       procedure OnTimerOutput(aSender:TObject);
       procedure UpdateInputState;

       // Link hover management
       procedure ClearLinkHoverState;

       // Session handling
       procedure SessionOnMessage(const aSender:TPasLLMModelInferenceInstance.TChatSession;const aMessage:TPasLLMModelInferenceInstance.TChatSession.TMessage);
       procedure SessionOnStateChange(const aSender:TPasLLMModelInferenceInstance.TChatSession;const aOldState,aNewState:TPasLLMModelInferenceInstance.TChatSession.TState);
       procedure SessionOnTokenGenerated(const aSender:TPasLLMModelInferenceInstance.TChatSession;const aToken:TPasLLMUTF8String);

       // Model info callbacks for session save/load
       function SessionOnGetModelInfo(const aSender:TPasLLMModelInferenceInstance.TChatSession):TPasLLMUTF8String;

       // Threading support
       procedure StartChatThread;
       procedure StopChatThread;
       procedure Process;
       procedure QueueRepaint;
{$ifndef fmx}
       procedure ProcessThrottledRepaint(var aMessage:{$ifdef fpc}TLMessage{$else}TMessage{$endif}); message TPasLLMChatControl.WM_THROTTLED_REPAINT;
{$endif}

       // Threading helpers
       function WaitForActionDoneEvent(const aTimeOut:TPasLLMUInt32):TWaitResult;

       // Prompt history management
       procedure AddToPromptHistory(const aPrompt:TPasLLMUTF8String);
       procedure ClearPromptHistory;

       // Property accessors
       procedure SetAutoScroll(const aValue:boolean);
       procedure SetSession(const aValue:TPasLLMModelInferenceInstance.TChatSession);
       procedure SetSelectedModel(const aValue:TPasLLMUTF8String);

       // DPI helpers
       function GetCurrentPPI:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
       function DIP(const aValue:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif}):{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};

{$ifdef fpc}
       procedure DoAutoAdjustLayout(const aMode:TLayoutAdjustmentPolicy;const aNewPPI,aOldPPI:Integer);
{$else}
{$ifndef FMX}
      protected
{$ifdef fpc}
       procedure ChangeScale(aM,aD:Integer;aIsDpiChange:Boolean); override;
{$endif}
{$endif}
{$endif}

      protected

       procedure Resize; override;
{$ifndef FMX}
       procedure CreateWnd; override;
{$endif}

      public

       constructor Create(aOwner:TComponent); override;
       destructor Destroy; override;

{$ifndef fmx}
{$ifndef fpc}
///    procedure WMEraseBkGnd(var Message:TMessage); message WM_ERASEBKGND;
{$endif}
{$endif}

       // Core API
       procedure Clear;
       procedure NewSession;
       function AddMessage(const aRole:TChatRole;const aText:TPasLLMUTF8String='';const aScrollToBottom:Boolean=false):TPasLLMInt32;
       procedure Append(const aIndex:TPasLLMInt32;const aDelta:TPasLLMUTF8String);
       procedure EndStream(const aIndex:TPasLLMInt32);
       procedure BindToSession(const aSession:TPasLLMModelInferenceInstance.TChatSession);
       procedure SetSystemPrompt(const aPrompt:TPasLLMUTF8String);

       // Model management
       procedure SetModels(const aModels:TPasLLMModels;const aCount:TPasLLMInt32);

       // Session management
       procedure NewChatSession(const aTitle:TPasLLMUTF8String='');
       procedure SaveCurrentSession;
       procedure SaveSessionAs(const aFileName:TPasLLMUTF8String);
       procedure DeleteSession(const aFileName:TPasLLMUTF8String);
       function GetSessionsList:TPasLLMModels;
       function GetSessionsDirectory:TPasLLMUTF8String;
       procedure EnsureSessionsDirectory;
       function GenerateSessionFileName(const aTitle:TPasLLMUTF8String):TPasLLMUTF8String;
       function GetCurrentSessionFileName:TPasLLMUTF8String;

       procedure PopulateModelCombo;

       // Context menu handlers
       procedure OnSessionListMenuDelete(aSender:TObject);

       // UI Session management helpers
       procedure PopulateSessionsList(const aListBox:TListBox);
       procedure OnSessionSelected(const aIndex:TPasLLMInt32);
       procedure LoadSession(const aFileName:TPasLLMUTF8String;const aIndex:TPasLLMInt32);
       procedure DeleteSelectedSession(const aIndex:TPasLLMInt32);
       procedure RefreshSessionsList;
       procedure SaveCurrentSessionWithTitle(const aTitle:TPasLLMUTF8String);
       procedure MarkCurrentSessionInList;
       procedure UpdateCurrentSessionTitle(const aTitle:TPasLLMUTF8String);
       procedure UpdateEditBoxWithCurrentSession;
       procedure CreateSessionListContextMenu;
       procedure AutoSaveCurrentSession;

       // Selection/clipboard
       procedure CopyLastAssistantMessage;
       procedure SelectAll;

       // Message selection
       procedure SelectMessage(const aIndex:TPasLLMInt32);
       procedure UnselectMessage(const aIndex:TPasLLMInt32);
       procedure SelectAllMessages;
       procedure UnselectAllMessages;
       procedure SelectMarkedMessages;
       procedure CopySelectedMessages;

       // Properties
       property Messages:TChatMessages read fMessages;
       property Session:TPasLLMModelInferenceInstance.TChatSession read fSession write SetSession;
       property SelectedModel:TPasLLMUTF8String read fSelectedModel write SetSelectedModel;
       property AutoScroll:boolean read fAutoScroll write SetAutoScroll default true;

       property TavilyKey:TPasLLMUTF8String read fTavilyKey write fTavilyKey;

      published

       property StatusBar:TStatusBar read fStatusBar write fStatusBar;
{$ifdef FMX}
       property StatusBarLabel1:TLabel read fStatusBarLabel1 write fStatusBarLabel1;
       property StatusBarLabel2:TLabel read fStatusBarLabel2 write fStatusBarLabel2;
       property StatusBarLabel3:TLabel read fStatusBarLabel3 write fStatusBarLabel3;
       property StatusBarLabel4:TLabel read fStatusBarLabel4 write fStatusBarLabel4;
{$endif}
       property EditSessionName:TEdit read fEditSessionName write fEditSessionName;

       property StorageDirectory:TPasLLMUTF8String read fStorageDirectory write fStorageDirectory;

       property ModelDirectory:TPasLLMUTF8String read fModelDirectory write fModelDirectory;

       // Visual properties
       property MessagePadding:TPasLLMInt32 read fMessagePadding write fMessagePadding default 8;
       property MessageMargin:TPasLLMInt32 read fMessageMargin write fMessageMargin default 4;
       property LineSpacing:TPasLLMInt32 read fLineSpacing write fLineSpacing default 4;
       property MaxInputHeight:TPasLLMInt32 read fMaxInputHeight write fMaxInputHeight default 100;
       property WrapWidthPercent:TPasLLMInt32 read fWrapWidthPercent write fWrapWidthPercent default 75;
       property ScrollButtonHorizontalPosition:TPasLLMFloat read fScrollButtonHorizontalPosition write fScrollButtonHorizontalPosition; // 0.0=left, 0.5=center, 1.0=right

       // Colors
       property ColorBackground:{$ifdef FMX}TAlphaColor{$else}TColor{$endif} read fColorBackground write fColorBackground {$ifndef FMX}default TPasLLMChatControl.DEF_COLOR_BACKGROUND{$endif};
       property ColorUser:{$ifdef FMX}TAlphaColor{$else}TColor{$endif} read fColorUser write fColorUser {$ifndef FMX}default TPasLLMChatControl.DEF_COLOR_USER{$endif};
       property ColorAssistant:{$ifdef FMX}TAlphaColor{$else}TColor{$endif} read fColorAssistant write fColorAssistant {$ifndef FMX}default TPasLLMChatControl.DEF_COLOR_ASSISTANT{$endif};
       property ColorSystem:{$ifdef FMX}TAlphaColor{$else}TColor{$endif} read fColorSystem write fColorSystem {$ifndef FMX}default TPasLLMChatControl.DEF_COLOR_SYSTEM{$endif};
       property ColorTool:{$ifdef FMX}TAlphaColor{$else}TColor{$endif} read fColorTool write fColorTool {$ifndef FMX}default TPasLLMChatControl.DEF_COLOR_TOOL{$endif};
       property ColorScrollButton:{$ifdef FMX}TAlphaColor{$else}TColor{$endif} read fColorScrollButton write fColorScrollButton {$ifndef FMX}default TPasLLMChatControl.DEF_COLOR_SCROLL_BUTTON{$endif};
       property ColorScrollButtonHover:{$ifdef FMX}TAlphaColor{$else}TColor{$endif} read fColorScrollButtonHover write fColorScrollButtonHover {$ifndef FMX}default TPasLLMChatControl.DEF_COLOR_SCROLL_BUTTON_HOVER{$endif};
       property ColorScrollButtonIcon:{$ifdef FMX}TAlphaColor{$else}TColor{$endif} read fColorScrollButtonIcon write fColorScrollButtonIcon {$ifndef FMX}default TPasLLMChatControl.DEF_COLOR_SCROLL_BUTTON_ICON{$endif};

       // Events
       property OnLinkClick:TLinkClickEvent read fOnLinkClick write fOnLinkClick;
       property OnLinkHover:TLinkHoverEvent read fOnLinkHover write fOnLinkHover;
       property OnSendPrompt:TSendPromptEvent read fOnSendPrompt write fOnSendPrompt;
       property OnModelChanged:TModelChangedEvent read fOnModelChanged write fOnModelChanged;
       property OnRequestModelList:TRequestModelListEvent read fOnRequestModelList write fOnRequestModelList;
       property OnLoadToolConfigurationEvent:TLoadToolConfigurationEvent read fOnLoadToolConfigurationEvent write fOnLoadToolConfigurationEvent;

       property ToolsEnabled:Boolean read fToolsEnabled write SetToolsEnabled;

       // Standard properties
       property Align;
       property Anchors;
       {$ifndef FMX}property Color default clWindow;{$endif}
       {$ifndef FMX}property Constraints;{$endif}
       property Enabled;
       {$ifndef FMX}property Font;{$endif}
       {$ifndef FMX}property ParentColor default false;{$endif}
       {$ifndef FMX}property ParentFont;{$endif}
       property ParentShowHint;
       property PopupMenu;
       property ShowHint;
       property TabOrder;
       property TabStop default true;
       property Visible;

       // Standard events
       property OnClick;
       {$ifndef FMX}property OnContextPopup;{$endif}
       property OnDblClick;
       property OnEnter;
       property OnExit;
       property OnKeyDown;
       {$ifndef FMX}property OnKeyPress;{$endif}
       property OnKeyUp;
       property OnMouseDown;
       property OnMouseMove;
       property OnMouseUp;
       property OnResize;

     end;

procedure Register;

implementation

procedure Register;
begin
 RegisterComponents('Chat/AI',[TPasLLMChatControl]);
end;

{$if not declared(OpenURL)}
procedure OpenURL(const aCommand:string);
begin
{$ifdef Windows}
 ShellExecute(0, 'OPEN',PChar(aCommand),'','',SW_SHOWNORMAL);
{$else}
  _system(PAnsiChar('open '+AnsiString(aCommand)));
{$endif}
end;
{$ifend}

{ TPasLLMChatControl.TSessionDatabaseEntry }

constructor TPasLLMChatControl.TSessionDatabaseEntry.Create;
begin
 inherited Create;
 fTitle:='';
 fFileName:='';
 fModelInfo:='';
 fDateTime:=0;
end;

destructor TPasLLMChatControl.TSessionDatabaseEntry.Destroy;
begin
 fTitle:='';
 fFileName:='';
 fModelInfo:='';
 inherited Destroy;
end;

{ TPasLLMChatControl.TSessionDatabase }

constructor TPasLLMChatControl.TSessionDatabase.Create(const aDatabaseFile:TPasLLMUTF8String);
begin
 inherited Create;
 fDatabaseFile:=aDatabaseFile;
 fEntries:=nil;
 fCountEntries:=0;
 fModified:=false;
 LoadFromFile;
end;

destructor TPasLLMChatControl.TSessionDatabase.Destroy;
var Index:TPasLLMInt32;
begin
 if fModified then begin
  SaveToFile;
 end;
 // Free all entry objects
 for Index:=0 to length(fEntries)-1 do begin
  FreeAndNil(fEntries[Index]);
 end;
 fEntries:=nil;
 inherited Destroy;
end;

procedure TPasLLMChatControl.TSessionDatabase.LoadFromFile;
var Stream:TMemoryStream;
    JSON:TPasJSONItem;
    JSONObject:TPasJSONItemObject;
    JSONArray:TPasJSONItemArray;
    JSONEntry:TPasJSONItemObject;
    Index:TPasLLMInt32;
    Entry:TSessionDatabaseEntry;
begin
 Clear(false); // Clear without saving to file
 fModified:=false;
 
 if not FileExists(fDatabaseFile) then begin
  exit; // No database file yet
 end;
 
 try
  Stream:=TMemoryStream.Create;
  try
   Stream.LoadFromFile(fDatabaseFile);
   Stream.Seek(0,soBeginning);
   JSON:=TPasJSON.Parse(Stream);
   try
    if assigned(JSON) and (JSON is TPasJSONItemObject) then begin
     JSONObject:=TPasJSONItemObject(JSON);
     if assigned(JSONObject.Properties['sessions']) and (JSONObject.Properties['sessions'] is TPasJSONItemArray) then begin
      JSONArray:=TPasJSONItemArray(JSONObject.Properties['sessions']);
      SetLength(fEntries,JSONArray.Count);
      fCountEntries:=JSONArray.Count;
      
      for Index:=0 to JSONArray.Count-1 do begin
       if JSONArray.Items[Index] is TPasJSONItemObject then begin
        JSONEntry:=TPasJSONItemObject(JSONArray.Items[Index]);
        Entry:=TSessionDatabaseEntry.Create;
        Entry.Title:=TPasJSON.GetString(JSONEntry.Properties['title'],'');
        Entry.FileName:=TPasJSON.GetString(JSONEntry.Properties['filename'],'');
        Entry.ModelInfo:=TPasJSON.GetString(JSONEntry.Properties['model'],'');
        Entry.DateTime:=TPasJSON.GetNumber(JSONEntry.Properties['datetime'],Now);
        fEntries[Index]:=Entry;
       end;
      end;
     end;
    end;
   finally
    FreeAndNil(JSON);
   end;
  finally
   FreeAndNil(Stream);
  end;
  SortByDateTime;
 except
  // Handle JSON parsing errors silently
  Clear(false); // Clear without saving to file
 end;
end;

procedure TPasLLMChatControl.TSessionDatabase.SaveToFile;
var Stream:TMemoryStream;
    JSON:TPasJSONItemObject;
    JSONArray:TPasJSONItemArray;
    JSONEntry:TPasJSONItemObject;
    Index:TPasLLMInt32;
begin
 SortByDateTime;
 JSON:=TPasJSONItemObject.Create;
 try
  JSONArray:=TPasJSONItemArray.Create;
  JSON.Add('sessions',JSONArray);
  
  for Index:=0 to fCountEntries-1 do begin
   JSONEntry:=TPasJSONItemObject.Create;
   JSONEntry.Add('title',TPasJSONItemString.Create(fEntries[Index].Title));
   JSONEntry.Add('filename',TPasJSONItemString.Create(fEntries[Index].FileName));
   JSONEntry.Add('model',TPasJSONItemString.Create(fEntries[Index].ModelInfo));
   JSONEntry.Add('datetime',TPasJSONItemNumber.Create(fEntries[Index].DateTime));
   JSONArray.Add(JSONEntry);
  end;
  
  Stream:=TMemoryStream.Create;
  try
   TPasJSON.StringifyToStream(Stream,JSON,true); // true for formatting
   Stream.SaveToFile(fDatabaseFile);
  finally
   FreeAndNil(Stream);
  end;
  // Keep fModified flag for tracking purposes
 finally
  FreeAndNil(JSON);
 end;
end;

procedure TPasLLMChatControl.TSessionDatabase.AddEntry(const aTitle,aFileName,aModelInfo:TPasLLMUTF8String;const aDateTime:TDateTime);
var Index:TPasLLMInt32;
    Entry:TSessionDatabaseEntry;
begin

 // Check if entry already exists
 Index:=FindEntry(aFileName);
 if Index>=0 then begin
  // Update existing entry
  UpdateEntry(aFileName,aTitle,aModelInfo,aDateTime);
  exit;
 end;
 
 // Add new entry
 Entry:=TSessionDatabaseEntry.Create;
 Entry.Title:=aTitle;
 Entry.FileName:=aFileName;
 Entry.ModelInfo:=aModelInfo;
 Entry.DateTime:=aDateTime;
 
 Index:=fCountEntries;
 inc(fCountEntries);
 if length(fEntries)<fCountEntries then begin
  SetLength(fEntries,fCountEntries*2);
 end;
 fEntries[Index]:=Entry;
 fModified:=true;
 SortByDateTime;
 SaveToFile; // Immediately save to disk
end;

procedure TPasLLMChatControl.TSessionDatabase.UpdateEntry(const aFileName,aTitle,aModelInfo:TPasLLMUTF8String;const aDateTime:TDateTime);
var Index:TPasLLMInt32;
    Entry:TSessionDatabaseEntry;
begin
 Index:=FindEntry(aFileName);
 if Index>=0 then begin
  Entry:=fEntries[Index];
  Entry.Title:=aTitle;
  Entry.ModelInfo:=aModelInfo;
  Entry.DateTime:=aDateTime;
  fModified:=true;
  SaveToFile; // Immediately save to disk
 end;
end;

procedure TPasLLMChatControl.TSessionDatabase.DeleteEntry(const aFileName:TPasLLMUTF8String);
var Index,IndexMove:TPasLLMInt32;
begin
 Index:=FindEntry(aFileName);
 if Index>=0 then begin
  // Free the object
  FreeAndNil(fEntries[Index]);
  // Move entries down
  for IndexMove:=Index to fCountEntries-2 do begin
   fEntries[IndexMove]:=fEntries[IndexMove+1];
  end;
  dec(fCountEntries);
  fModified:=true;
  SaveToFile; // Immediately save to disk
 end;
end;

function TPasLLMChatControl.TSessionDatabase.FindEntry(const aFileName:TPasLLMUTF8String):TPasLLMInt32;
var Index:TPasLLMInt32;
begin
 result:=-1;
 for Index:=0 to fCountEntries-1 do begin
  if fEntries[Index].FileName=aFileName then begin
   result:=Index;
   exit;
  end;
 end;
end;

function TPasLLMChatControl.TSessionDatabase.GetEntry(const aIndex:TPasLLMInt32):TSessionDatabaseEntry;
begin
 if (aIndex>=0) and (aIndex<fCountEntries) then begin
  result:=fEntries[aIndex];
 end else begin
  result:=nil;
 end;
end;

function TPasLLMChatControl.TSessionDatabase.GetCount:TPasLLMInt32;
begin
 result:=fCountEntries;
end;

procedure TPasLLMChatControl.TSessionDatabase.Clear(const aSaveToFile:Boolean=true);
var Index:TPasLLMInt32;
begin
 // Free all entry objects
 for Index:=0 to fCountEntries-1 do begin
  FreeAndNil(fEntries[Index]);
 end;
 fEntries:=nil;
 fCountEntries:=0;
 fModified:=true;
 if aSaveToFile then begin
  SaveToFile; // Immediately save to disk
 end;
end;

procedure TPasLLMChatControl.TSessionDatabase.SortByDateTime;
var Index:TPasLLMInt32;
    TempEntry:TSessionDatabaseEntry;
begin
 // Simple bubble sort implementation - sufficient for typical session counts
 // Sort from newest to oldest (descending order)
 Index:=0;
 while (Index+1)<fCountEntries do begin
  if fEntries[Index].DateTime<fEntries[Index+1].DateTime then begin
   TempEntry:=fEntries[Index];
   fEntries[Index]:=fEntries[Index+1];
   fEntries[Index+1]:=TempEntry;
   fModified:=true;
   if Index>0 then begin
    dec(Index);
   end else begin
    inc(Index);
   end;
  end else begin
   inc(Index);
  end;
 end;
end;

{ TPasLLMChatControl.TChatMessage }

constructor TPasLLMChatControl.TChatMessage.Create(const aChatControl:TPasLLMChatControl;const aRole:TChatRole;const aText:TPasLLMUTF8String);
{$ifdef FMX}
var SystemFontService:IFMXSystemFontService;
{$endif}
begin
 inherited Create;
 fChatControl:=aChatControl;
 fRole:=aRole;
 fText:=aText;
 fNewText:=true;
 fTimeUTC:=Now;
 fLayoutRect:=Rect(0,0,0,0);
 fStreaming:=false;
 fSelected:=false;
 fHoveredURL:='';
 fLastHitTestX:=-1;
 fLastHitTestY:=-1;
 fMarkDownRender:=TMarkDownRenderer.Create;
{$ifdef FMX}
 if TPlatformServices.Current.SupportsPlatformService(IFMXSystemFontService,SystemFontService) then begin
  fMarkDownRender.FontName:=SystemFontService.GetDefaultFontFamilyName;
 end;
{$else}
{$ifdef fpc}
 if assigned(Screen) and assigned(Screen.SystemFont) then begin
  fMarkDownRender.FontName:=Screen.SystemFont.Name;
 end;
{$endif}
{$endif}
end;

destructor TPasLLMChatControl.TChatMessage.Destroy;
begin
 FreeAndNil(fMarkDownRender);
 inherited Destroy;
end;

procedure TPasLLMChatControl.TChatMessage.WordWrap(const aCanvas:TCanvas;const aText:TPasLLMUTF8String;const aMaxWidth:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};var aLines:TPasLLMModels;var aLineCount:TPasLLMInt32);
var CharIndex,FromIndex,ToIndex,WordStartIndex:TPasLLMInt32;
    CurrentLine,WordText,Candidate,PendingSpaces:TPasLLMUTF8String;

 procedure AddLine(const aLine:TPasLLMUTF8String);
 var Index:TPasLLMInt32;
 begin
  Index:=aLineCount;
  inc(aLineCount);
  if length(aLines)<aLineCount then begin
   SetLength(aLines,aLineCount*2);
  end;
  aLines[Index]:=aLine;
 end;

 function IsCRLFAt(const aCharIndex:TPasLLMInt32):boolean;
 begin
  result:=(aCharIndex<=ToIndex) and (aText[aCharIndex] in [#10,#13]);
 end;

 procedure SkipCRLF(var aCharIndex:TPasLLMInt32);
 begin
  if (aCharIndex<=ToIndex) and (aText[aCharIndex]=#13) then begin
   inc(aCharIndex);
   if (aCharIndex<=ToIndex) and (aText[aCharIndex]=#10) then begin
    inc(aCharIndex);
   end;
  end else if (aCharIndex<=ToIndex) and (aText[aCharIndex]=#10) then begin
   inc(aCharIndex);
  end;
 end;

 function NextUTF8CharLenAt(const aString:TPasLLMUTF8String;const aPosition:TPasLLMInt32):TPasLLMInt32;
 var ByteValue:TPasLLMUInt8;
 begin
  if (aPosition<1) or (aPosition>length(aString)) then begin
   result:=0;
   exit;
  end;
  ByteValue:=TPasLLMUInt8(aString[aPosition]);
  if ByteValue<$80 then begin
   result:=1;
  end else if (ByteValue and $e0)=$c0 then begin
   result:=2;
  end else if (ByteValue and $f0)=$e0 then begin
   result:=3;
  end else begin
   result:=4;
  end;
 end;

 function RTrimSpaces(const aStr:TPasLLMUTF8String):TPasLLMUTF8String;
 var i:TPasLLMInt32;
 begin
  i:=length(aStr);
  while (i>0) and (aStr[i] in [#9,#32]) do begin
   dec(i);
  end;
  if i<length(aStr) then begin
   result:=Copy(aStr,1,i);
  end else begin
   result:=aStr;
  end;
 end;

 procedure EmitHardWrappedWord(const aWord:TPasLLMUTF8String);
 var CharPos,WordLen,CodePointLen:TPasLLMInt32;
     Chunk:TPasLLMUTF8String;
 begin
  CharPos:=1;
  WordLen:=length(aWord);
  while CharPos<=WordLen do begin
   Chunk:='';
   while CharPos<=WordLen do begin
    CodePointLen:=NextUTF8CharLenAt(aWord,CharPos);
    if CodePointLen<=0 then begin
     break;
    end;
    if aCanvas.TextWidth(Chunk+Copy(aWord,CharPos,CodePointLen))<=aMaxWidth then begin
     Chunk:=Chunk+Copy(aWord,CharPos,CodePointLen);
     inc(CharPos,CodePointLen);
    end else begin
     break;
    end;
   end;
   if length(Chunk)=0 then begin
    // Force progress by taking a single codepoint
    CodePointLen:=NextUTF8CharLenAt(aWord,CharPos);
    if CodePointLen<=0 then begin
     break;
    end;
    Chunk:=Copy(aWord,CharPos,CodePointLen);
    inc(CharPos,CodePointLen);
   end;
   AddLine(RTrimSpaces(Chunk));
  end;
 end;

begin

 aLines:=nil;
 aLineCount:=0;
 try

  // Trim leading and trailing whitespace (global exception)
  FromIndex:=1;
  ToIndex:=length(aText);
  while (FromIndex<=ToIndex) and (aText[FromIndex]<=#32) do begin
   inc(FromIndex);
  end;
  while (ToIndex>=FromIndex) and (aText[ToIndex]<=#32) do begin
   dec(ToIndex);
  end;

  if FromIndex>ToIndex then begin

   AddLine('');

  end else begin

   CurrentLine:='';
   PendingSpaces:='';
   CharIndex:=FromIndex;
   while CharIndex<=ToIndex do begin

    // Handle explicit line breaks
    if IsCRLFAt(CharIndex) then begin
     AddLine(RTrimSpaces(CurrentLine));
     CurrentLine:='';
     PendingSpaces:='';
     SkipCRLF(CharIndex);
     continue;
    end;

    // Collect spaces/tabs (preserve run length)
    if (aText[CharIndex] in [#9,#32]) then begin
     while (CharIndex<=ToIndex) and (aText[CharIndex] in [#9,#32]) do begin
      PendingSpaces:=PendingSpaces+aText[CharIndex];
      inc(CharIndex);
     end;
     continue;
    end;

    if CharIndex>ToIndex then begin
     break;
    end;
    if IsCRLFAt(CharIndex) then begin
     continue; // handled at top of loop
    end;

    // Capture next word (sequence of non-control, non-space characters)
    WordStartIndex:=CharIndex;
    while (CharIndex<=ToIndex) and not (aText[CharIndex]<=#32) do begin
     inc(CharIndex);
    end;
    WordText:=Copy(aText,WordStartIndex,CharIndex-WordStartIndex);
    if length(WordText)=0 then begin
     continue;
    end;

    // Decide using preserved spaces
    if length(CurrentLine)<>0 then begin
     Candidate:=CurrentLine+PendingSpaces+WordText;
    end else begin
     Candidate:=PendingSpaces+WordText; // allow leading spaces
    end;

    if aCanvas.TextWidth(Candidate)<=aMaxWidth then begin
     CurrentLine:=Candidate;
     PendingSpaces:='';
    end else begin
     if length(CurrentLine)<>0 then begin
      // Push current line and try on a fresh line
      AddLine(RTrimSpaces(CurrentLine));
      CurrentLine:='';
     end;

     // On empty line, handle excessive pending spaces first
     if (length(PendingSpaces)<>0) and (aCanvas.TextWidth(PendingSpaces)>aMaxWidth) then begin
      EmitHardWrappedWord(PendingSpaces);
      PendingSpaces:='';
     end;

     if aCanvas.TextWidth(PendingSpaces+WordText)<=aMaxWidth then begin
      CurrentLine:=PendingSpaces+WordText;
      PendingSpaces:='';
     end else begin
      if length(PendingSpaces)<>0 then begin
       if aCanvas.TextWidth(PendingSpaces)<=aMaxWidth then begin
        AddLine(RTrimSpaces(PendingSpaces));
        PendingSpaces:='';
       end else begin
        EmitHardWrappedWord(PendingSpaces);
        PendingSpaces:='';
       end;
      end;
      if aCanvas.TextWidth(WordText)<=aMaxWidth then begin
       CurrentLine:=WordText;
      end else begin
       // Word itself doesn't fit -> hard-wrap it into chunks
       EmitHardWrappedWord(WordText);
       CurrentLine:='';
      end;
     end;
    end;

   end;

   // Flush remainder
   AddLine(RTrimSpaces(CurrentLine));

  end;

 finally
  SetLength(aLines,aLineCount);
 end;

end;

{procedure TPasLLMChatControl.TChatMessage.WordWrap(const aCanvas:TCanvas;const aText:TPasLLMUTF8String;const aMaxWidth:TPasLLMInt32;var aLines:TPasLLMModels;var aLineCount:TPasLLMInt32);
var Index,FromIndex,ToIndex,LineStartIndex,WordStartIndex:TPasLLMInt32;
    CharIndex,WordBreakStart,WordBreakEnd:TPasLLMInt32;
    CurrentLine,WordStr,Candidate:TPasLLMUTF8String;
    ch:AnsiChar;
 function IsSpace(const c:AnsiChar):boolean;
 begin
  result:=(c=' ') or (c=#9);
 end;
 procedure AddLine(const aLine:TPasLLMUTF8String);
 var Index:TPasLLMInt32;
 begin
  Index:=aLineCount;
  inc(aLineCount);
  if Length(aLines)<aLineCount then begin
   SetLength(aLines,aLineCount*2);
  end;
  aLines[Index]:=aLine;
 end;
begin

 aLines:=nil;
 aLineCount:=0;
 try

  // Trim leading and trailing whitespace/control
  FromIndex:=1;
  ToIndex:=Length(aText);
  while (FromIndex<=ToIndex) and (aText[FromIndex]<#32) do begin
   inc(FromIndex);
  end;
  while (ToIndex>=FromIndex) and (aText[ToIndex]<#32) do begin
   dec(ToIndex);
  end;

  if FromIndex>ToIndex then begin
   AddLine('');
  end else begin
   CurrentLine:='';
   CharIndex:=FromIndex;
   while CharIndex<=ToIndex do begin
    ch:=aText[CharIndex];
    // Handle explicit newlines (CR/LF)
    if (ch=#13) or (ch=#10) then begin
     AddLine(CurrentLine);
     CurrentLine:='';
     // Treat CRLF as single newline
     if (ch=#13) and (CharIndex<ToIndex) and (aText[CharIndex+1]=#10) then begin
      inc(CharIndex);
     end;
     inc(CharIndex);
     continue;
    end;

    // Skip and collapse consecutive spaces/tabs
    if IsSpace(ch) then begin
     while (CharIndex<=ToIndex) and IsSpace(aText[CharIndex]) do begin
      inc(CharIndex);
     end;
     // We'll insert a single space implicitly when appending next word (if any and not at line start)
     continue;
    end;

    // Extract next word until whitespace or newline
    WordStartIndex:=CharIndex;
    while (CharIndex<=ToIndex) and not IsSpace(aText[CharIndex]) and (aText[CharIndex]<>#10) and (aText[CharIndex]<>#13) do begin
     inc(CharIndex);
    end;
    WordStr:=Copy(aText,WordStartIndex,(CharIndex-WordStartIndex));
    if Length(WordStr)=0 then begin
     continue;
    end;

    // Try to append word to current line
    if CurrentLine='' then begin
     Candidate:=WordStr;
    end else begin
     Candidate:=CurrentLine+' '+WordStr;
    end;

    if aCanvas.TextWidth(Candidate)<=aMaxWidth then begin
     CurrentLine:=Candidate;
    end else begin
     // Current line can't fit the word
     if CurrentLine<>'' then begin
      AddLine(CurrentLine);
      CurrentLine:='';
     end;

     // If the word itself doesn't fit on an empty line, hard-break it
     if aCanvas.TextWidth(WordStr)>aMaxWidth then begin
      WordBreakStart:=1;
      while WordBreakStart<=Length(WordStr) do begin
       // Build the largest chunk starting at WordBreakStart that fits into aMaxWidth
       Candidate:='';
       WordBreakEnd:=WordBreakStart;
       while (WordBreakEnd<=Length(WordStr)) and (aCanvas.TextWidth(Candidate+WordStr[WordBreakEnd])<=aMaxWidth) do begin
        Candidate:=Candidate+WordStr[WordBreakEnd];
        inc(WordBreakEnd);
       end;
       if Candidate='' then begin
        // Fallback: force at least one byte to avoid infinite loop
        Candidate:=WordStr[WordBreakStart];
        WordBreakEnd:=WordBreakStart+1;
       end;
       AddLine(Candidate);
       WordBreakStart:=WordBreakEnd;
      end;
     end else begin
      // Start a new line with the word
      CurrentLine:=WordStr;
     end;
    end;
   end; // while CharIndex<=ToIndex

   // Flush last line if any, or ensure at least one line
   if CurrentLine<>'' then begin
    AddLine(CurrentLine);
   end else if aLineCount=0 then begin
    AddLine('');
   end;
  end;

 finally
  SetLength(aLines,aLineCount);
 end;

end;}

{procedure TPasLLMChatControl.TChatMessage.WordWrap(const aCanvas:TCanvas;const aText:TPasLLMUTF8String;const aMaxWidth:TPasLLMInt32;var aLines:TPasLLMModels;var aLineCount:TPasLLMInt32);
var Words:TPasLLMModels;
    CountWords:TPasLLMInt32;
    CurrentLine,CurrentTextLine:TPasLLMUTF8String;
    CurrentWord:TPasLLMUTF8String;
    Index:TPasLLMInt32;
    StartPosition:TPasLLMInt32;
    TextLines:TPasLLMUTF8StringDynamicArray;
    TextLineIndex:TPasLLMInt32;
    CountTextLines:TPasLLMInt32;
 procedure AddLine(const aLine:TPasLLMUTF8String);
 var Index:TPasLLMInt32;
 begin
  Index:=aLineCount;
  inc(aLineCount);
  if Length(aLines)<aLineCount then begin
   SetLength(aLines,aLineCount*2);
  end;
  aLines[Index]:=aLine;
 end;
 procedure AddTextLine(const aLine:TPasLLMUTF8String);
 var Index:TPasLLMInt32;
 begin
  Index:=CountTextLines;
  inc(CountTextLines);
  if Length(TextLines)<CountTextLines then begin
   SetLength(TextLines,CountTextLines*2);
  end;
  TextLines[Index]:=aLine;
 end;
 procedure AddWord(const aWord:TPasLLMUTF8String);
 var Index:TPasLLMInt32;
 begin
  Index:=CountWords;
  inc(CountWords);
  if Length(Words)<CountWords then begin
   SetLength(Words,CountWords*2);
  end;
  Words[Index]:=aWord;
 end;
begin

  // Font
 aCanvas.Font.Size:=fChatControl.fMessageArea.fFontSize;

 aLines:=nil;
 aLineCount:=0;
 try

  if Length(aText)=0 then begin

   AddLine('');

  end else begin

   // First split by line breaks (CR/LF)
   TextLines:=nil;
   CountTextLines:=0;
   try

    Index:=1;
    while Index<=Length(aText) do begin
     case aText[Index] of
      #0..#32:begin
       inc(Index);
      end;
      else begin
       break;
      end;
     end;
    end;

    StartPosition:=1;
    while Index<=Length(aText) do begin
     case aText[Index] of
      #10,#13:begin
       inc(CountTextLines);
       SetLength(TextLines,CountTextLines);
       if Index>StartPosition then begin
        AddTextLine(Copy(aText,StartPosition,Index-StartPosition));
       end else begin
        AddTextLine(''); // Empty line
       end;

       // Skip CR+LF combination
       if (Index<Length(aText)) and (aText[Index]=#13) and (aText[Index+1]=#10) then begin
        inc(Index);
       end;
       StartPosition:=Index+1;
      end;
      else begin
      end;
     end;
     inc(Index);
    end;
    if StartPosition<=Length(aText) then begin
     AddTextLine(Copy(aText,StartPosition,(Length(aText)-StartPosition)+1));
    end;

    // Now CurrentWord wrap each line separately
    for TextLineIndex:=0 to CountTextLines-1 do begin
     CurrentTextLine:=TextLines[TextLineIndex];
     if Length(CurrentTextLine)=0 then begin
      // Empty line
      AddLine('');
     end else begin
      // CurrentWord split this line
      Words:=nil;
      CountWords:=0;
      StartPosition:=1;
      for Index:=1 to Length(CurrentTextLine) do begin
       if CurrentTextLine[Index]=#32 then begin
        if Index>StartPosition then begin
         AddWord(Copy(CurrentTextLine,StartPosition,Index-StartPosition));
        end;
        StartPosition:=Index+1;
       end;
      end;
      if StartPosition<=Length(CurrentTextLine) then begin
       AddWord(Copy(CurrentTextLine,StartPosition,(Length(CurrentTextLine)-StartPosition)+1));
      end;

      // CurrentWord wrap this line
      CurrentLine:='';
      for Index:=0 to CountWords-1 do begin
       CurrentWord:=Words[Index];

       if length(CurrentLine)=0 then begin
        CurrentLine:=CurrentWord;
       end else begin
        if aCanvas.TextWidth(CurrentLine+' '+CurrentWord)<=aMaxWidth then begin
         CurrentLine:=CurrentLine+' '+CurrentWord;
        end else begin
         AddLine(CurrentLine);
         CurrentLine:=CurrentWord;
        end;
       end;
      end;

      if length(CurrentLine)>0 then begin
       AddLine(CurrentLine);
      end;

     end;
    end;

    if aLineCount=0 then begin
     AddLine('');
    end;

   finally
    TextLines:=nil;
   end;

  end;

 finally
  SetLength(aLines,aLineCount);
 end;

end;}

procedure TPasLLMChatControl.TChatMessage.CalculateLayout(const aCanvas:TCanvas;const aViewPortRect:{$ifdef FMX}TRectF{$else}TRect{$endif};var aY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};const aMaxWidth,aLineHeight:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif});
var Lines:TPasLLMModels;
    LineCount:TPasLLMInt32;
{$ifdef FMX}
    MessageRect:TRectF;
    TextRect:TRectF;
{$else}
    MessageRect:TRect;
    TextRect:TRect;
{$endif}
    Alignment:TAlignment;
    Offset,ContentWidth,ContentHeight:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
begin

 // Word wrap the text
 Lines:=nil;
 LineCount:=0;

 // Calculate message rect first
 MessageRect.Left:=0;
 MessageRect.Top:=aY;
 MessageRect.Right:=aMaxWidth;
 MessageRect.Bottom:=aY+100; // Temporary height, will be recalculated

 // Adjust for alignment
{Alignment:=fChatControl.GetRoleAlignment(fRole);
 case Alignment of
  taRightJustify:begin
   Offset:=aViewPortRect.Width-MessageRect.Right;
   OffsetRect(MessageRect,Offset,0);
  end;
  taCenter:begin
   Offset:=(aViewPortRect.Width-MessageRect.Right) div 2;
   OffsetRect(MessageRect,Offset,0);
  end;
  else begin
   // taLeftJustify: no offset needed
  end;
 end;}

{$ifdef FMX}
 begin
  Offset:=(aViewPortRect.Width-MessageRect.Right)*0.5;
  OffsetRect(MessageRect,Offset,0);
 end;
{$else}
 begin
  Offset:=(aViewPortRect.Width-MessageRect.Right) div 2;
  OffsetRect(MessageRect,Offset,0);
 end;
{$endif}

 // Adjust for margin
 MessageRect.Left:=MessageRect.Left+fChatControl.DIP(4);
 MessageRect.Right:=MessageRect.Right-fChatControl.DIP(4);

 // Calculate text area (same as TChatMessage.Draw)
 TextRect:=MessageRect;
 InflateRect(TextRect,-fChatControl.DIP(fChatControl.fMessagePadding),-fChatControl.DIP(fChatControl.fMessagePadding));

 if fNewText then begin
  fNewText:=false;
  fMarkDownRender.Parse(fText,false);
 end;

 fMarkDownRender.BaseFontSize:=fChatControl.fMessageArea.fFontSize;
 fMarkDownRender.Calculate(aCanvas,TextRect.Width,ContentWidth,ContentHeight);
 // Recalculate message height based on wrapped lines
 MessageRect.Bottom:=MessageRect.Top+ContentHeight+(2*fChatControl.DIP(fChatControl.fMessagePadding));
 fLayoutRect:=MessageRect;
 aY:=MessageRect.Bottom+fChatControl.DIP(fChatControl.fMessageMargin);

{// Word wrap using actual text width (consistent with TChatMessage.Draw)
 WordWrap(aCanvas,fText,TextRect.Width,Lines,LineCount);
 try

  // Recalculate message height based on wrapped lines
  MessageRect.Bottom:=MessageRect.Top+(LineCount*aLineHeight)+(2*fChatControl.DIP(fChatControl.fMessagePadding));

  fLayoutRect:=MessageRect;
  aY:=MessageRect.Bottom+fChatControl.DIP(fChatControl.fMessageMargin);

 finally
  Lines:=nil;
 end;}

end;

procedure TPasLLMChatControl.TChatMessage.DrawTypingIndicator(const aCanvas:TCanvas;const aRect:{$ifdef FMX}TRectF{$else}TRect{$endif});
var DotSize,x,y:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
    Index,TypingAnimationPhase:TPasLLMInt32;
begin
 DotSize:=fChatControl.DIP(4);
 X:=aRect.Right-((DotSize+fChatControl.DIP(2))*3);
 Y:=aRect.Top+(aRect.Height-DotSize);

{$ifdef FMX}
 aCanvas.Fill.Color:=TAlphaColorRec.White;
 aCanvas.Stroke.Color:=TAlphaColorRec.Gray;
{$else}
 aCanvas.Brush.Color:=clWhite;
 aCanvas.Pen.Color:=clGray;
{$endif} 

 TypingAnimationPhase:=fChatControl.GetTypingAnimationPhase;

 fChatControl.fLastTypingAnimationPhase:=TypingAnimationPhase;

 for Index:=0 to 2 do begin
  if TypingAnimationPhase=Index then begin
{$ifdef FMX}
   aCanvas.Fill.Color:=TAlphaColorRec.Black;
{$else}
   aCanvas.Brush.Color:=clBlack;
{$endif}
  end else begin
{$ifdef FMX}    
   aCanvas.Fill.Color:=TAlphaColorRec.White;
{$else}
   aCanvas.Brush.Color:=clWhite;
{$endif}
  end;

{$ifdef FMX}
  aCanvas.FillEllipse(RectF(X,Y,X+DotSize,Y+DotSize),1);
{$else}
  aCanvas.Ellipse(X,Y,X+DotSize,Y+DotSize);
{$endif}

  X:=X+(DotSize+fChatControl.DIP(2));
 end;
end;

{$ifdef FMX}
function Darken(const aColor:TAlphaColor;const aFactor:Single):TAlphaColor;
var ColorF:TAlphaColorF;
begin
 ColorF:=TAlphaColorF.Create(aColor);
 ColorF.r:=ColorF.r*aFactor;
 ColorF.g:=ColorF.g*aFactor;
 ColorF.b:=ColorF.b*aFactor;
 if ColorF.r>1.0 then begin
  ColorF.r:=1.0;
 end;
 if ColorF.g>1.0 then begin
  ColorF.g:=1.0;
 end;
 if ColorF.b>1.0 then begin
  ColorF.b:=1.0;
 end;   
 result:=ColorF.ToAlphaColor;
end;
{$endif}

procedure TPasLLMChatControl.TChatMessage.Draw(const aCanvas:TCanvas;const aRect:{$ifdef FMX}TRectF{$else}TRect{$endif});
var BackgroundColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
    BorderColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
    TextColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
    TextQuoteColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
    TextThinkColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
    Lines:TPasLLMModels;
    LineCount:TPasLLMInt32;
    Index:TPasLLMInt32;
    LineHeight:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
    TextRect:{$ifdef FMX}TRectF{$else}TRect{$endif};
    Y:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
    s:string;
begin

 // Font
 aCanvas.Font.Size:=fChatControl.fMessageArea.fFontSize;

 // Determine colors
 BackgroundColor:=fChatControl.GetRoleColor(fRole);

 // Darken color if message is selected
 if fSelected then begin
{$ifdef FMX}
  BackgroundColor:=Darken(BackgroundColor,0.75);
{$else}
  BackgroundColor:=RGB(
   (GetRValue(BackgroundColor)*3) div 4,
   (GetGValue(BackgroundColor)*3) div 4,
   (GetBValue(BackgroundColor)*3) div 4
  );
{$endif}
 end;

 // Darken color for border
{$ifdef FMX}
 BorderColor:=Darken(BackgroundColor,0.5);
{$else}
 BorderColor:=RGB(
  (GetRValue(BackgroundColor)*2) div 4,
  (GetGValue(BackgroundColor)*2) div 4,
  (GetBValue(BackgroundColor)*2) div 4
 );
{$endif}

 // Auto-adjust text color for contrast
{$ifdef FMX}
 if (TAlphaColorRec(BackgroundColor).R+TAlphaColorRec(BackgroundColor).G+TAlphaColorRec(BackgroundColor).B)>384 then begin
  TextColor:=TAlphaColorRec.Black;
  TextQuoteColor:=$ff444444;
  TextThinkColor:=$ff666666;
 end else begin
  TextColor:=TAlphaColorRec.White;
  TextQuoteColor:=$ffcccccc;
  TextThinkColor:=$ffaaaaaa;
 end;
{$else}
 if (GetRValue(BackgroundColor)+GetGValue(BackgroundColor)+GetBValue(BackgroundColor))>384 then begin
  TextColor:=clBlack;
  TextQuoteColor:=$444444;
  TextThinkColor:=$666666;
 end else begin
  TextColor:=clWhite;
  TextQuoteColor:=$cccccc;
  TextThinkColor:=$aaaaaa;
 end;
{$endif}

 // Draw message background
{$ifdef FMX}
 aCanvas.Fill.Color:=BackgroundColor;
 aCanvas.Stroke.Color:=BorderColor;
 aCanvas.Stroke.Thickness:=1;
 aCanvas.Stroke.Kind:=TBrushKind.Solid;
 aCanvas.Stroke.Dash:=TStrokeDash.Solid;
 aCanvas.FillRect(aRect,fChatControl.DIP(16),fChatControl.DIP(16),[TCorner.TopLeft,TCorner.TopRight,TCorner.BottomLeft,TCorner.BottomRight],1.0,TCornerType.Round);
 aCanvas.DrawRect(aRect,fChatControl.DIP(16),fChatControl.DIP(16),[TCorner.TopLeft,TCorner.TopRight,TCorner.BottomLeft,TCorner.BottomRight],1.0,TCornerType.Round);
{$else}
 aCanvas.Brush.Color:=BackgroundColor;
 aCanvas.Pen.Color:=BorderColor;
 aCanvas.RoundRect(aRect,fChatControl.DIP(16),fChatControl.DIP(16));
{$endif}

 // Draw selection border if selected
 if fSelected then begin
{$ifdef FMX}
  aCanvas.Stroke.Thickness:=fChatControl.DIP(2);
  aCanvas.Stroke.Kind:=TBrushKind.Solid;
  aCanvas.Stroke.Dash:=TStrokeDash.Dot;
  aCanvas.Stroke.Color:=TAlphaColorRec.Black;
  aCanvas.FillRect(aRect,fChatControl.DIP(16),fChatControl.DIP(16),[TCorner.TopLeft,TCorner.TopRight,TCorner.BottomLeft,TCorner.BottomRight],1.0,TCornerType.Round);
  aCanvas.DrawRect(aRect,fChatControl.DIP(16),fChatControl.DIP(16),[TCorner.TopLeft,TCorner.TopRight,TCorner.BottomLeft,TCorner.BottomRight],1.0,TCornerType.Round);
{$else}
  aCanvas.Brush.Style:=bsClear;  
  aCanvas.Pen.Style:=psDot;
  aCanvas.Pen.Color:=clBlack;
  aCanvas.Pen.Width:=fChatControl.DIP(2);
  aCanvas.RoundRect(aRect,fChatControl.DIP(16),fChatControl.DIP(16));
  aCanvas.Pen.Width:=1;
  aCanvas.Pen.Style:=psSolid;
{$endif}  
 end;

 // Setup text area
 TextRect:=aRect;
 InflateRect(TextRect,-fChatControl.DIP(fChatControl.fMessagePadding),-fChatControl.DIP(fChatControl.fMessagePadding));

 try

{$ifdef FMX}
  aCanvas.Fill.Color:=TextColor;
{$else}
  aCanvas.Brush.Style:=bsClear;
  aCanvas.Font.Color:=TextColor;
{$endif}

  fMarkDownRender.BGColor:=BackgroundColor;
  fMarkDownRender.BGThinkColor:=BackgroundColor;
  fMarkDownRender.FontColor:=TextColor;
  fMarkDownRender.FontQuoteColor:=TextQuoteColor;
  fMarkDownRender.FontThinkColor:=TextThinkColor;

{$ifdef FMX}
  fMarkDownRender.BGCodeColor:=TAlphaColorRec.Black;
  fMarkDownRender.FontCodeColor:=TAlphaColorRec.White;
{$else}
  fMarkDownRender.BGCodeColor:=clBlack;
  fMarkDownRender.FontCodeColor:=clWhite;
{$endif}

  fMarkDownRender.BaseFontSize:=fChatControl.fMessageArea.fFontSize;
  fMarkDownRender.Render(aCanvas,TextRect.Left,TextRect.Top);

  y:=TextRect.Bottom;

  // Draw typing indicator if streaming
  if fStreaming then begin
   DrawTypingIndicator(aCanvas,{$ifdef FMX}RectF{$else}Rect{$endif}(TextRect.Left,Y-32,TextRect.Right,Y));
  end;

 finally
  Lines:=nil;
 {$ifdef FMX}
  aCanvas.Fill.Kind:=TBrushKind.Solid;
 {$else} 
  aCanvas.Brush.Style:=bsSolid;
 {$endif}
 end;

{ // Word wrap and draw text
 Lines:=nil;
 LineCount:=0;
 WordWrap(aCanvas,fText,TextRect.Width,Lines,LineCount);
 try
  aCanvas.Brush.Style:=bsClear;
  aCanvas.Font.Color:=TextColor;

  LineHeight:=aCanvas.TextHeight(MaxHeightString)+fChatControl.DIP(fChatControl.fLineSpacing);
  Y:=TextRect.Top;

  for Index:=0 to LineCount-1 do begin
   s:=Lines[Index];
   aCanvas.TextOut(TextRect.Left,Y,s);
   inc(Y,LineHeight);
  end;

  // Draw typing indicator if streaming
  if fStreaming then begin
   DrawTypingIndicator(aCanvas,Rect(TextRect.Left,Y-LineHeight,TextRect.Right,Y));
  end;

 finally
  Lines:=nil;
  aCanvas.Brush.Style:=bsSolid;
 end;}

end;

function TPasLLMChatControl.TChatMessage.HitTestLink(const aX,aY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};out aLink:TPasLLMUTF8String):Boolean;
var RelativeX,RelativeY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
    TextRect:{$ifdef FMX}TRectF{$else}TRect{$endif};
begin

 result:=false;
 aLink:='';
 
 // Check if point is within message bounds
 if not PtInRect(fLayoutRect,{$ifdef FMX}PointF{$else}Point{$endif}(aX,aY)) then begin
  exit;
 end;
 
 // Calculate relative coordinates within the text area
 TextRect:=fLayoutRect;
 InflateRect(TextRect,-fChatControl.DIP(fChatControl.fMessagePadding),-fChatControl.DIP(fChatControl.fMessagePadding));

 RelativeX:=aX-TextRect.Left;
 RelativeY:=aY-TextRect.Top;
 
 // Use TMarkDownRenderer.HitTestLink to check for links
 if assigned(fMarkDownRender) then begin
  result:=fMarkDownRender.HitTestLink(RelativeX,RelativeY,aLink);
 end;
end;

procedure TPasLLMChatControl.TChatMessage.HandleMouseMove(const aX,aY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif});
var NewHoveredURL:TPasLLMUTF8String;
    TargetCursor:TCursor;
    DoSetCursor:Boolean;
begin

 DoSetCursor:=false;

 TargetCursor:=crDefault;

 // Only perform hit test if mouse position changed
 if (aX<>fLastHitTestX) or (aY<>fLastHitTestY) then begin
  fLastHitTestX:=aX;
  fLastHitTestY:=aY;
  
  if not HitTestLink(aX,aY,NewHoveredURL) then begin
   NewHoveredURL:='';
  end;
  
  // Check if hover state changed
  if NewHoveredURL<>fHoveredURL then begin

   // Fire hover end event for previous URL
   if length(fHoveredURL)>0 then begin
    if assigned(fChatControl.fOnLinkHover) then begin
     fChatControl.fOnLinkHover(fChatControl,fHoveredURL,false);
    end else begin
     // Reset cursor when not over link
     if fChatControl.fCursorOverLink then begin
      DoSetCursor:=true;
      TargetCursor:=crDefault;// fChatControl.fOriginalCursor;
      fChatControl.fMessageArea.Hint:='';
      fChatControl.fMessageArea.ShowHint:=false;
      fChatControl.fCursorOverLink:=false;
     end;
    end;
   end;

   fHoveredURL:=NewHoveredURL;
   
   // Fire hover start event for new URL
   if length(fHoveredURL)>0 then begin
    if assigned(fChatControl.fOnLinkHover) then begin
     fChatControl.fOnLinkHover(fChatControl,fHoveredURL,true);
    end else begin
     // Set hand cursor for link
     if not fChatControl.fCursorOverLink then begin
      DoSetCursor:=true;
      fChatControl.fOriginalCursor:=fChatControl.fMessageArea.Cursor;
      fChatControl.fMessageArea.Hint:=fHoveredURL;
      fChatControl.fMessageArea.ShowHint:=true;
      TargetCursor:=crHandPoint;
      fChatControl.fCursorOverLink:=true;
     end; 
    end;
   end;

  end;

 end;

 if DoSetCursor then begin
  fChatControl.fMessageArea.Cursor:=TargetCursor;
 end;

end;

function TPasLLMChatControl.TChatMessage.HandleMouseClick(const aX,aY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif}):Boolean;
var ClickedURL:TPasLLMUTF8String;
begin
 result:=false;
 if HitTestLink(aX,aY,ClickedURL) then begin
  if assigned(fChatControl.fOnLinkClick) then begin
   fChatControl.fOnLinkClick(fChatControl,ClickedURL);
  end else begin
{$ifdef FMX}
   if MessageDlg('Open link in default browser?'+#10#13+ClickedURL,TMsgDlgType.mtConfirmation,[TMsgDlgBtn.mbYes,TMsgDlgBtn.mbNo],0)=mrYes then begin
    // Open URL in default browser
    OpenURL(ClickedURL);
   end;
{$else}
   if MessageDlg('Open link in default browser?'+#10#13+ClickedURL,mtConfirmation,[mbYes,mbNo],0)=mrYes then begin
    // Open URL in default browser
    OpenURL(ClickedURL);
   end;
{$endif}
  end;
  result:=true;
 end;
end;

{ TPasLLMChatControl.TChatMessageAreaControl }

constructor TPasLLMChatControl.TChatMessageAreaControl.Create(aOwner:TComponent;aChatControl:TPasLLMChatControl);
begin

 inherited Create(aOwner);

 fChatControl:=aChatControl;

{$ifndef fmx}
{$ifndef fpc}
 fBitmap:=TBitmap.Create;
{$endif}
{$endif}

{$ifdef FMX}
 HitTest:=true;
 TabStop:=true;
 CanFocus:=true;
 Opacity:=1.0;
{$endif}

 // Set properties
{$ifndef FMX}
 Color:=fChatControl.fColorBackground;
 ParentColor:=false;
{$ifdef fpc}
 DoubleBuffered:=true;
{$else}
 DoubleBuffered:=false;
{$endif}
{$endif}

 fScrollY:=0;
 fAutoScrollMaxScrollY:=0;
 fMaxScrollY:=0;

 fFontSize:=12;

 fSelecting:=false;
 fSelectedText:='';
 fSelectionStart:={$ifdef FMX}PointF{$else}Point{$endif}(0,0);
 fSelectionEnd:={$ifdef FMX}PointF{$else}Point{$endif}(0,0);

{$ifdef FMX}
 fScrollBar:=TScrollBar.Create(self);
 fScrollBar.Parent:=self;
 fScrollBar.Align:=TAlignLayout.Right;
 fScrollBar.Orientation:=TOrientation.Vertical;
 fScrollBar.Visible:=false;
 fScrollBar.Width:=18;
 fScrollBar.OnChange:=ScrollBarOnChange;
{$else}
{$ifdef fpc}
 fScrollBar:=TScrollBar.Create(self);
 fScrollBar.Parent:=self;
{$else}
 fScrollBar:=TScrollBar.Create(fChatControl.fPanelChat);
 fScrollBar.Parent:=fChatControl.fPanelChat;
{$endif}
 fScrollBar.Align:=alRight;
 fScrollBar.Kind:=sbVertical;
 fScrollBar.SmallChange:=1;
 fScrollBar.LargeChange:=10;
 fScrollBar.Visible:=false;
 fScrollBar.OnScroll:=ScrollBarOnScroll;
{$endif}

 fIsScrollOnBottom:=true;

 fScrollToBottomButtonHover:=false;

 // Create popup menu
 CreatePopupMenu;
end;

destructor TPasLLMChatControl.TChatMessageAreaControl.Destroy;
begin
{$ifndef fmx}
{$ifndef fpc}
 FreeAndNil(fBitmap);
{$endif}
{$endif}
 inherited Destroy;
end;

{$ifndef fmx}
{$ifndef fpc}
procedure TPasLLMChatControl.TChatMessageAreaControl.WMEraseBkGnd(var Message:TMessage);
begin
 Message.Result:=1;
end;
{$endif}
{$endif}

{$ifdef FMX}
procedure TPasLLMChatControl.TChatMessageAreaControl.ScrollBarOnChange(Sender:TObject);
begin

 // Update our internal scroll position from scrollbar
 fScrollY:=fScrollBar.Value;

 // Clamp to valid range
 fScrollY:=Max(0,Min(fScrollY,fMaxScrollY));

 // Check if it is on bottom
 fIsScrollOnBottom:=fScrollY>=fAutoScrollMaxScrollY;

 // Update scrollbar position in case we clamped
 if fScrollBar.Value<>fScrollY then begin
  fScrollBar.Value:=fScrollY;
 end;

 Repaint;
end;
{$else}
procedure TPasLLMChatControl.TChatMessageAreaControl.ScrollBarOnScroll(Sender:TObject;ScrollCode:TScrollCode;var ScrollPos:Integer);
begin
 // Update our internal scroll position from scrollbar
 fScrollY:=ScrollPos;

 // Clamp to valid range
 fScrollY:=Max(0,Min(fScrollY,fMaxScrollY));

 // Check if it is on bottom
 fIsScrollOnBottom:=fScrollY>=fAutoScrollMaxScrollY;

 // Update scrollbar position in case we clamped
 if fScrollBar.Position<>fScrollY then begin
  fScrollBar.Position:=fScrollY;
 end;

 // Repaint to show new scroll position
 Invalidate;
end;
{$endif}

procedure TPasLLMChatControl.TChatMessageAreaControl.MouseDown(aButton:TMouseButton;aShift:TShiftState;aX,aY:{$ifdef FMX}Single{$else}Integer{$endif});
var MessageIndex:TPasLLMInt32;
    Message:TChatMessage;
    ScrolledY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
    ClickedURL:TPasLLMUTF8String;
begin
 inherited MouseDown(aButton,aShift,aX,aY);

 if aButton={$ifdef FMX}TMouseButton.mbLeft{$else}mbLeft{$endif} then begin

  // Check if clicking on scroll to bottom button
  if not fIsScrollOnBottom then begin
{$ifdef FMX}
   if (aX>=fBottomScrollButtonRect.Left) and (aX<=fBottomScrollButtonRect.Right) and
      (aY>=fBottomScrollButtonRect.Top) and (aY<=fBottomScrollButtonRect.Bottom) then begin
{$else}
   if PtInRect(fBottomScrollButtonRect,Point(Round(aX),Round(aY))) then begin
{$endif}
    ScrollToBottom;
    exit;
   end;
  end;

  // Adjust coordinates for scrolling
  ScrolledY:=aY+fScrollY;

  // Check if clicking on a message
  MessageIndex:=MessageAtPoint(aX,ScrolledY);

  if MessageIndex>=0 then begin
   Message:=fChatControl.fMessages[MessageIndex];
   
   // Handle link click
   if Message.HandleMouseClick(aX,ScrolledY) then begin

    exit;

   end else begin

    // Handle message selection if not clicking on a link
    if Message.fSelected then begin
     fChatControl.UnselectMessage(MessageIndex);
    end else begin
     // If holding Ctrl, unselect all others first
    if (aShift*[ssCtrl,ssAlt,ssShift])=[ssCtrl] then begin
      fChatControl.UnselectAllMessages;
     end;
     fChatControl.SelectMessage(MessageIndex);
    end;

   end;

  end else begin
   // Clicking on empty space - unselect all
   fChatControl.UnselectAllMessages;
  end;

  // Original text selection logic
  fSelectionStart:={$ifdef FMX}PointF{$else}Point{$endif}(aX,ScrolledY);
  fSelectionEnd:=fSelectionStart;
  fSelecting:=true;
{$ifndef FMX}
  SetFocus;
{$endif}
 end;
end;

procedure TPasLLMChatControl.TChatMessageAreaControl.MouseMove(aShift:TShiftState;aX,aY:{$ifdef FMX}Single{$else}Integer{$endif});
var MessageIndex:TPasLLMInt32;
    Message:TChatMessage;
    ScrolledY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
    OldHover:boolean;
begin
 inherited MouseMove(aShift,aX,aY);

 // Check if hovering over scroll to bottom button
 OldHover:=fScrollToBottomButtonHover;
 fScrollToBottomButtonHover:=false;
 if not fIsScrollOnBottom then begin
{$ifdef FMX}
  if (aX>=fBottomScrollButtonRect.Left) and (aX<=fBottomScrollButtonRect.Right) and
     (aY>=fBottomScrollButtonRect.Top) and (aY<=fBottomScrollButtonRect.Bottom) then begin
   fScrollToBottomButtonHover:=true;
  end;
{$else}
  if PtInRect(fBottomScrollButtonRect,Point(Round(aX),Round(aY))) then begin
   fScrollToBottomButtonHover:=true;
  end;
{$endif}
 end;

 // Repaint if hover state changed
 if OldHover<>fScrollToBottomButtonHover then begin
{$ifdef FMX}
  Invalidate;
{$else}
  Invalidate;
{$endif}
 end;

 // Adjust coordinates for scrolling
 ScrolledY:=aY+fScrollY;
 
 // Find message at this position and handle link detection
 MessageIndex:=MessageAtPoint(aX,ScrolledY);
 if (MessageIndex>=0) and (MessageIndex<fChatControl.fMessages.Count) then begin
  Message:=fChatControl.fMessages[MessageIndex];
  Message.HandleMouseMove(aX,ScrolledY);
 end;

 if fSelecting then begin
  fSelectionEnd:={$ifdef FMX}PointF{$else}Point{$endif}(aX,ScrolledY);
{$ifdef FMX}
  Invalidate;
{$else}
  fChatControl.fMessageArea.Invalidate;
{$endif}
 end;
end;

procedure TPasLLMChatControl.TChatMessageAreaControl.MouseUp(aButton:TMouseButton;aShift:TShiftState;aX,aY:{$ifdef FMX}Single{$else}Integer{$endif});
begin
 inherited MouseUp(aButton,aShift,aX,aY);

 if aButton={$ifdef FMX}TMouseButton.mbLeft{$else}mbLeft{$endif} then begin

  fSelecting:=false;

{$ifdef FMX}
  Invalidate;
{$else}
  Invalidate;
{$endif}

  SelectMarkedMessages;

 end;

end;

{$ifdef FMX}
procedure TPasLLMChatControl.TChatMessageAreaControl.DoMouseLeave;
begin
 inherited DoMouseLeave;

 // Clear any link hover states when mouse leaves the control
 fChatControl.ClearLinkHoverState;
end;
{$else}
{$ifdef fpc}
procedure TPasLLMChatControl.TChatMessageAreaControl.MouseLeave;
begin
 inherited MouseLeave;

 // Clear any link hover states when mouse leaves the control
 fChatControl.ClearLinkHoverState;
end;
{$endif}
{$endif}

procedure TPasLLMChatControl.TChatMessageAreaControl.KeyDown(var aKey:Word;{$ifdef FMX}var aKeyChar:WideChar;{$endif}aShift:TShiftState);
begin
 case aKey of

  {$ifdef FMX}vkPrior{$else}VK_PRIOR{$endif}:begin // Page Up
   ScrollTo(fScrollY-{$ifdef FMX}(fViewPortRect.Height*0.5){$else}(fViewPortRect.Height div 2){$endif});
   aKey:=0;
{$ifdef FMX}
   aKeyChar:=#0;
{$endif}
  end;

  {$ifdef FMX}vkNext{$else}VK_NEXT{$endif}:begin // Page Down
   ScrollTo(fScrollY+{$ifdef FMX}(fViewPortRect.Height*0.5){$else}(fViewPortRect.Height div 2){$endif});
   aKey:=0;
{$ifdef FMX}
   aKeyChar:=#0;
{$endif}
  end;

  {$ifdef FMX}vkHome{$else}VK_HOME{$endif}:begin
   if (aShift*[ssCtrl,ssAlt,ssShift])=[ssCtrl] then begin
    ScrollTo(0);
   end;
   aKey:=0;
{$ifdef FMX}
   aKeyChar:=#0;
{$endif}
  end;

  {$ifdef FMX}vkEnd{$else}VK_END{$endif}:begin
   if (aShift*[ssCtrl,ssAlt,ssShift])=[ssCtrl] then begin
    AutoScrollToBottom;
   end;
   aKey:=0;
{$ifdef FMX}
   aKeyChar:=#0;
{$endif}
  end;

  {$ifdef FMX}vkUp{$else}VK_UP{$endif}:begin
   ScrollTo(fScrollY-Canvas.TextHeight(MaxHeightString));
   aKey:=0;
{$ifdef FMX}
   aKeyChar:=#0;
{$endif}
  end;

  {$ifdef FMX}vkDown{$else}VK_DOWN{$endif}:begin
   ScrollTo(fScrollY+Canvas.TextHeight(MaxHeightString));
   aKey:=0;
{$ifdef FMX}
   aKeyChar:=#0;
{$endif}
  end;

  {$ifdef FMX}vkC{$else}Ord('C'){$endif}:begin
   if (aShift*[ssCtrl,ssAlt,ssShift])=[ssCtrl,ssShift] then begin
    fChatControl.CopySelectedMessages;
    aKey:=0;
{$ifdef FMX}
    aKeyChar:=#0;
{$endif}
   end;
  end;

  {$ifdef FMX}vkA{$else}Ord('A'){$endif}:begin
   if (aShift*[ssCtrl,ssAlt,ssShift])=[ssCtrl,ssShift] then begin
    fChatControl.SelectAllMessages;
    aKey:=0;
{$ifdef FMX}
    aKeyChar:=#0;
{$endif}
   end;
  end;

  {$ifdef FMX}vkAdd{$else}VK_ADD,VK_OEM_PLUS,Ord('+'),Ord('='){$endif}:begin
   if (aShift*[ssCtrl,ssAlt,ssShift])=[ssCtrl] then begin
    fFontSize:=Max(1,fFontSize+1);
    CalculateLayout;
{$ifndef FMX}
    Invalidate;
{$endif}
    aKey:=0;
{$ifdef FMX}
    aKeyChar:=#0;
{$endif}
   end;
  end;

  {$ifdef FMX}vkSubtract{$else}VK_SUBTRACT,VK_OEM_MINUS,Ord('-'){$endif}:begin
   if (aShift*[ssCtrl,ssAlt,ssShift])=[ssCtrl] then begin
    fFontSize:=Max(1,fFontSize-1);
    CalculateLayout;
{$ifndef FMX}
    Invalidate;
{$endif}
    aKey:=0;
{$ifdef FMX}
    aKeyChar:=#0;
{$endif}
   end;
  end;

  {$ifdef FMX}vkNumpad0,vk0{$else}VK_NUMPAD0,Ord('0'){$endif}:begin
   if (aShift*[ssCtrl,ssAlt,ssShift])=[ssCtrl] then begin
    fFontSize:=12;
    CalculateLayout;
{$ifndef FMX}
    Invalidate;
{$endif}
    aKey:=0;
{$ifdef FMX}
    aKeyChar:=#0;
{$endif}
   end;
  end;

 end;

 inherited KeyDown(aKey,{$ifdef FMX}aKeyChar,{$endif}aShift);

end;

{$ifdef FMX}
procedure TPasLLMChatControl.TChatMessageAreaControl.MouseWheel(Shift:TShiftState;WheelDelta:Integer;var Handled:Boolean);
begin
 WheelDelta:=Max(1,Min(1,abs(WheelDelta)))*Sign(WheelDelta);
 if (Shift*[ssCtrl,ssAlt,ssShift])=[ssCtrl] then begin
  fFontSize:=Max(1,fFontSize+WheelDelta);
  CalculateLayout;
  Repaint;
 end else begin
  ScrollTo(fScrollY-(Canvas.TextHeight(MaxHeightString)*WheelDelta*3));
 end;
 Handled:=true;
end;
{$else}
function TPasLLMChatControl.TChatMessageAreaControl.DoMouseWheelDown(aShift:TShiftState;aMousePos:TPoint):boolean;
begin
 if (aShift*[ssCtrl,ssAlt,ssShift])=[ssCtrl] then begin
  fFontSize:=Max(1,fFontSize-1);
  CalculateLayout;
  Invalidate;
 end else begin
  ScrollTo(fScrollY+(Canvas.TextHeight(MaxHeightString)*3));
 end;
 result:=true;
end;

function TPasLLMChatControl.TChatMessageAreaControl.DoMouseWheelUp(aShift:TShiftState;aMousePos:TPoint):boolean;
begin
 if (aShift*[ssCtrl,ssAlt,ssShift])=[ssCtrl] then begin
  fFontSize:=Max(1,fFontSize+1);
  CalculateLayout;
  Invalidate;
 end else begin
  ScrollTo(fScrollY-(Canvas.TextHeight(MaxHeightString)*3));
 end;
 result:=true;
end;
{$endif}

procedure TPasLLMChatControl.TChatMessageAreaControl.Paint;
var Index:TPasLLMInt32;
    Message:TChatMessage;
    {$ifdef FMX}ClipRect,{$endif}MessageRect,VisibleRect:{$ifdef FMX}TRectF{$else}TRect{$endif};
    ButtonRect:{$ifdef FMX}TRectF{$else}TRect{$endif};
    ButtonColor:{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
    CenterX,CenterY,Radius:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
    ArrowSize:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
{$ifndef FMX}
{$ifndef fpc}
    Canvas:TCanvas;
{$endif}
{$endif}
begin
 inherited Paint;

{$ifdef FMX}
//Canvas.BeginScene;

 ClipRect:=GetClipRect;

 Opacity:=1.0;
{$else}
{$ifndef fpc}

 if fBitmap.HandleType<>bmDIB then begin
  fBitmap.HandleType:=bmDIB;
 end;
 if fBitmap.PixelFormat<>pf32bit then begin
  fBitmap.PixelFormat:=pf32bit;
 end;

 if (fBitmap.Width<>ClientWidth) or (fBitmap.Height<>ClientHeight) then begin
  fBitmap.SetSize(ClientWidth,ClientHeight);
 end;

 Canvas:=fBitmap.Canvas;

{$endif}
{$endif}

 // Clear background
{$ifdef FMX}
 Canvas.ClearRect(ClipRect,fChatControl.fColorBackground);
{Canvas.Fill.Color:=fChatControl.fColorBackground;
 Canvas.Fill.Kind:=TBrushKind.Solid;
 Canvas.FillRect(ClipRect,1.0);}
{$else}
 Canvas.Brush.Color:=Color;
 Canvas.FillRect(ClientRect);
{$endif}

 // Setup visible area using local viewport rect
 VisibleRect:=fViewPortRect;
 OffsetRect(VisibleRect,0,fScrollY);

 // Draw messages
 for Index:=0 to fChatControl.fMessages.Count-1 do begin
  Message:=fChatControl.fMessages[Index];
  MessageRect:=Message.fLayoutRect;
  OffsetRect(MessageRect,0,-fScrollY);

  // Only draw visible messages using local viewport rect
  if (MessageRect.Bottom>=fViewPortRect.Top) and (MessageRect.Top<=fViewPortRect.Bottom) then begin
   Message.Draw(Canvas,MessageRect);
  end;

 end;

 // Draw selection highlight
 DrawSelectionHighlight(Canvas);

 // Draw scroll to bottom button if not at bottom
 if (fChatControl.fMessages.Count>0) and not fIsScrollOnBottom then begin
  UpdateScrollToBottomButtonRect;
{$ifdef FMX}
  CenterX:=(fBottomScrollButtonRect.Left+fBottomScrollButtonRect.Right)*0.5;
  CenterY:=(fBottomScrollButtonRect.Top+fBottomScrollButtonRect.Bottom)*0.5;
  Radius:=(fBottomScrollButtonRect.Right-fBottomScrollButtonRect.Left)*0.5;
{$else}
  CenterX:=(fBottomScrollButtonRect.Left+fBottomScrollButtonRect.Right) div 2;
  CenterY:=(fBottomScrollButtonRect.Top+fBottomScrollButtonRect.Bottom) div 2;
  Radius:=(fBottomScrollButtonRect.Right-fBottomScrollButtonRect.Left) div 2;
{$endif}

  // Set button color based on hover state
  if fScrollToBottomButtonHover then begin
   ButtonColor:=fChatControl.fColorScrollButtonHover;
  end else begin
   ButtonColor:=fChatControl.fColorScrollButton;
  end;

  // Draw circle background
{$ifdef FMX}
  Canvas.Fill.Color:=ButtonColor;
  Canvas.Fill.Kind:=TBrushKind.Solid;
  Canvas.FillEllipse(fBottomScrollButtonRect,1.0);
{$else}
  Canvas.Brush.Color:=ButtonColor;
  Canvas.Pen.Color:=ButtonColor;
  Canvas.Ellipse(fBottomScrollButtonRect);
{$endif}

  // Draw white border around circle
{$ifdef FMX}
  Canvas.Stroke.Color:=fChatControl.fColorScrollButtonIcon;
  Canvas.Stroke.Kind:=TBrushKind.Solid;
  Canvas.Stroke.Thickness:=fChatControl.DIP(1);
  Canvas.DrawEllipse(fBottomScrollButtonRect,1.0);
{$else}
  Canvas.Pen.Color:=fChatControl.fColorScrollButtonIcon;
  Canvas.Pen.Width:=fChatControl.DIP(1);
  Canvas.Brush.Style:=bsClear;
  Canvas.Ellipse(fBottomScrollButtonRect);
  Canvas.Brush.Style:=bsSolid;
{$endif}

  // Draw down arrow (V shape)
  ArrowSize:=fChatControl.DIP(10);
{$ifdef FMX}
  Canvas.Stroke.Color:=fChatControl.fColorScrollButtonIcon;
  Canvas.Stroke.Thickness:=fChatControl.DIP(1);
  Canvas.DrawLine(PointF(CenterX-ArrowSize,CenterY-ArrowSize*0.5),PointF(CenterX,CenterY+ArrowSize*0.5),1.0);
  Canvas.DrawLine(PointF(CenterX,CenterY+ArrowSize*0.5),PointF(CenterX+ArrowSize,CenterY-ArrowSize*0.5),1.0);
{$else}
  Canvas.Pen.Color:=fChatControl.fColorScrollButtonIcon;
  Canvas.Pen.Width:=fChatControl.DIP(1);
  Canvas.MoveTo(CenterX-ArrowSize,CenterY-Round(ArrowSize*0.5));
  Canvas.LineTo(CenterX,CenterY+Round(ArrowSize*0.5));
  Canvas.LineTo(CenterX+ArrowSize,CenterY-Round(ArrowSize*0.5));
{$endif}
 end;

{$ifdef FMX}
//Canvas.EndScene;
{$else}
{$ifndef fpc}
 self.Canvas.Draw(0,0,fBitmap);
{$endif}
{$endif}

end;

procedure TPasLLMChatControl.TChatMessageAreaControl.Resize;
begin
 inherited Resize;
 CalculateLayout;
 UpdateScrollToBottomButtonRect;
end;

{$ifdef FMX}
procedure TPasLLMChatControl.TChatMessageAreaControl.Invalidate;
begin
 InvalidateRect(GetLocalRect);
end;

procedure TPasLLMChatControl.TChatMessageAreaControl.DoRealign;
begin
 inherited DoRealign;
 CalculateLayout;
end;
{$else}
procedure TPasLLMChatControl.TChatMessageAreaControl.CreateWnd;
begin
 inherited CreateWnd;
 CalculateLayout;
end;
{$endif}

// ============================================================================
// Layout and rendering
// ============================================================================

procedure TPasLLMChatControl.TChatMessageAreaControl.CalculateLayout;
var MaxWidth,LineHeight,Y,ScrollBarWidth,AvailableWidth:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
    Index:TPasLLMInt32;
begin

 if (fChatControl.fMessages.Count=0) {$ifndef FMX}or (ClientRect.Width<=0) or (ClientRect.Height<=0){$endif} then begin
  exit;
 end;

 // Cache ClientRect in local viewport rect
 fViewPortRect:={$ifdef FMX}GetClipRect{$else}ClientRect{$endif};

 // Calculate available width (subtract scrollbar width if visible)
 AvailableWidth:=fViewPortRect.Width;
{$if (defined(fpc) or defined(fmx))}
 if fScrollBar.Visible then begin
  ScrollBarWidth:=fScrollBar.Width;
  AvailableWidth:=AvailableWidth-ScrollBarWidth;
  // Also adjust viewport rect for accurate calculations
  fViewPortRect.Right:=fViewPortRect.Right-ScrollBarWidth;
 end;
{$ifend}

{$ifdef FMX}
 MaxWidth:=(AvailableWidth*fChatControl.fWrapWidthPercent)*0.01;
{$else}
 MaxWidth:=(AvailableWidth*fChatControl.fWrapWidthPercent) div 100;
{$endif}

 // Layout messages
 Y:=fChatControl.DIP(fChatControl.fMessageMargin);
 LineHeight:=Canvas.TextHeight(MaxHeightString)+fChatControl.DIP(fChatControl.fLineSpacing);

 for Index:=0 to fChatControl.fMessages.Count-1 do begin
  fChatControl.fMessages[Index].CalculateLayout(Canvas,fViewPortRect,Y,MaxWidth,LineHeight);
 end;

 UpdateScrollBounds;

end;

procedure TPasLLMChatControl.TChatMessageAreaControl.UpdateScrollBounds;
var TotalHeight,ViewPortHeight:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
    ScrollBarVisible:boolean;
    OldScrollBarVisible:boolean;
    WasAtBottom:boolean;
begin

 // Remember if we were at bottom before updating
 WasAtBottom:=fIsScrollOnBottom;

 // Calculate total height of all messages
 if fChatControl.fMessages.Count>0 then begin
  TotalHeight:=fChatControl.fMessages[fChatControl.fMessages.Count-1].fLayoutRect.Bottom+fChatControl.DIP(fChatControl.fMessageMargin);
 end else begin
  TotalHeight:=0;
 end;

 ViewPortHeight:=fViewPortRect.Height;

 // Calculate maximum scrollablearea
{$ifdef FMX}
 fMaxScrollY:=Max(0.0,TotalHeight-ViewPortHeight);
{$else}
 fMaxScrollY:=Max(0,TotalHeight-ViewPortHeight);
{$endif}

 fAutoScrollMaxScrollY:=Max(0,fMaxScrollY-fChatControl.DIP(20));

 // Determine if scrollbar should be visible
 ScrollBarVisible:=fMaxScrollY>0;
 OldScrollBarVisible:=fScrollBar.Visible;

 // If we were at bottom and currently generating, stay at bottom (for auto-scroll during streaming)
 if WasAtBottom and fChatControl.fIsWorking then begin
  fScrollY:=fMaxScrollY;
  fIsScrollOnBottom:=true;
 end else begin
  // Clamp current scroll position
  fScrollY:=Min(Max(fScrollY,0),fMaxScrollY);
  // Check if it is on bottom
  fIsScrollOnBottom:=fScrollY>=fAutoScrollMaxScrollY;
  if not fIsScrollOnBottom then begin
   fIsScrollOnBottom:=fScrollY>=fAutoScrollMaxScrollY;
  end;
 end;

 // Update scrollbar visibility and configuration
 if ScrollBarVisible<>OldScrollBarVisible then begin
  fScrollBar.Visible:=ScrollBarVisible;
  // Recalculate layout if scrollbar visibility changed and scrollbar is now visible
  if ScrollBarVisible and not OldScrollBarVisible then begin
   // Scrollbar now visible - recalculate with reduced width
   CalculateLayout;
   exit; // CalculateLayout will call UpdateScrollBounds again
  end;
 end;

 if ScrollBarVisible and (fViewPortRect.Height>0) then begin

  // Configure scrollbar range and position
{$ifdef FMX}
  fScrollBar.Min:=0.0;
  fScrollBar.Max:=Max(0.0,fMaxScrollY-1);
//fScrollBar.SmallChange:=Canvas.TextHeight(MaxHeightString);

  // Update scrollbar position to match current scroll
  if fScrollBar.Value<>fScrollY then begin
   fScrollBar.Value:=fScrollY;
  end;
{$else}
  fScrollBar.PageSize:=fViewPortRect.Height;
  fScrollBar.Min:=0;
  fScrollBar.Max:=(fMaxScrollY+fScrollBar.PageSize)-1;
  fScrollBar.LargeChange:=fViewPortRect.Height div 2;
  fScrollBar.SmallChange:=Canvas.TextHeight(MaxHeightString);

  // Update scrollbar position to match current scroll
  if fScrollBar.Position<>fScrollY then begin
   fScrollBar.Position:=fScrollY;
  end;
{$endif}

 end;

 if fChatControl.fCurrentStreamingIndex>=0 then begin
  AutoScrollToBottom;
 end;

end;

procedure TPasLLMChatControl.TChatMessageAreaControl.DrawSelectionHighlight(const aCanvas:TCanvas);
var SelectionRect:{$ifdef FMX}TRectF{$else}TRect{$endif};
    StartX,StartY,EndX,EndY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
begin
 if (not fSelecting) or
    ((fSelectionStart.X=fSelectionEnd.X) and (fSelectionStart.Y=fSelectionEnd.Y)) then begin
  exit;
 end;

 // Normalize selection coordinates
 StartX:=Min(fSelectionStart.X,fSelectionEnd.X);
 StartY:=Min(fSelectionStart.Y,fSelectionEnd.Y);
 EndX:=Max(fSelectionStart.X,fSelectionEnd.X);
 EndY:=Max(fSelectionStart.Y,fSelectionEnd.Y);

 // Draw selection rectangle
 SelectionRect:={$ifdef FMX}RectF{$else}Rect{$endif}(StartX,StartY-fScrollY,EndX,EndY-fScrollY);
{$ifdef FMX}
 aCanvas.Fill.Color:=$40ffff00;
 aCanvas.Fill.Kind:=TBrushKind.Solid;
 aCanvas.FillRect(SelectionRect,0,0,[],1.0);
{$else}   
 aCanvas.Brush.Color:=clHighlight;
 aCanvas.Brush.Style:=bsSolid;
 aCanvas.Pen.Style:=psClear;
 aCanvas.FillRect(SelectionRect);
{$endif}

 // Draw selection border
{$ifdef FMX}
 aCanvas.Fill.Kind:=TBrushKind.None;
 aCanvas.Stroke.Thickness:=1;
 aCanvas.Stroke.Kind:=TBrushKind.Solid;
 aCanvas.Stroke.Dash:=TStrokeDash.Dot;
 aCanvas.Stroke.Color:=TAlphaColorRec.Antiquewhite;
 aCanvas.DrawRect(SelectionRect,0,0,[],1.0);

 aCanvas.Stroke.Thickness:=1;
 aCanvas.Stroke.Dash:=TStrokeDash.Solid;
{$else} 
 aCanvas.Brush.Style:=bsClear;
 aCanvas.Pen.Style:=psDot;
 aCanvas.Pen.Color:=clHighlightText;
 aCanvas.Rectangle(SelectionRect);

 aCanvas.Pen.Style:=psSolid;
{$endif}

end;

procedure TPasLLMChatControl.TChatMessageAreaControl.CreatePopupMenu;
begin
 fPopupMenu:=TPopupMenu.Create(Self);

 // Select
 fPopupMenuItemSelect:=TMenuItem.Create(fPopupMenu);
 {$ifdef FMX}fPopupMenuItemSelect.Text{$else}fPopupMenuItemSelect.Caption{$endif}:='Select';
 fPopupMenuItemSelect.OnClick:=OnMenuSelectClick;
 {$ifndef FMX}fPopupMenu.Items.Add(fPopupMenuItemSelect);{$endif}

 // Unselect
 fPopupMenuItemUnselect:=TMenuItem.Create(fPopupMenu);
 {$ifdef FMX}fPopupMenuItemUnselect.Text{$else}fPopupMenuItemUnselect.Caption{$endif}:='Unselect';
 fPopupMenuItemUnselect.OnClick:=OnMenuUnselectClick;
 {$ifndef FMX}fPopupMenu.Items.Add(fPopupMenuItemUnselect);{$endif}

 // Separator 1
 fPopupMenuItemSeparator1:=TMenuItem.Create(fPopupMenu);
 {$ifdef FMX}fPopupMenuItemSeparator1.Text{$else}fPopupMenuItemSeparator1.Caption{$endif}:='-';
 {$ifndef FMX} fPopupMenu.Items.Add(fPopupMenuItemSeparator1);{$endif}

 // Select All
 fPopupMenuItemSelectAll:=TMenuItem.Create(fPopupMenu);
 {$ifdef FMX}fPopupMenuItemSelectAll.Text{$else}fPopupMenuItemSelectAll.Caption{$endif}:='Select All';
 fPopupMenuItemSelectAll.OnClick:=OnMenuSelectAllClick;
 {$ifndef FMX}fPopupMenu.Items.Add(fPopupMenuItemSelectAll);{$endif}

 // Unselect All
 fPopupMenuItemUnselectAll:=TMenuItem.Create(fPopupMenu);
 {$ifdef FMX}fPopupMenuItemUnselectAll.Text{$else}fPopupMenuItemUnselectAll.Caption{$endif}:='Unselect All';
 fPopupMenuItemUnselectAll.OnClick:=OnMenuUnselectAllClick;
 {$ifndef FMX}fPopupMenu.Items.Add(fPopupMenuItemUnselectAll);{$endif}

 // Separator 2
 fPopupMenuItemSeparator2:=TMenuItem.Create(fPopupMenu);
 {$ifdef FMX}fPopupMenuItemSeparator2.Text{$else}fPopupMenuItemSeparator2.Caption{$endif}:='-';
 {$ifndef FMX}fPopupMenu.Items.Add(fPopupMenuItemSeparator2);{$endif}

 // Copy
 fPopupMenuItemCopy:=TMenuItem.Create(fPopupMenu);
 {$ifdef FMX}fPopupMenuItemCopy.Text{$else}fPopupMenuItemCopy.Caption{$endif}:='Copy';
 fPopupMenuItemCopy.OnClick:=OnMenuCopyClick;
 {$ifndef FMX}fPopupMenu.Items.Add(fPopupMenuItemCopy);{$endif}

 // Separator 3
 fPopupMenuItemSeparator3:=TMenuItem.Create(fPopupMenu);
 {$ifdef FMX}fPopupMenuItemSeparator3.Text{$else}fPopupMenuItemSeparator3.Caption{$endif}:='-';
 {$ifndef FMX}fPopupMenu.Items.Add(fPopupMenuItemSeparator3);{$endif}

 // Clear
 fPopupMenuItemClear:=TMenuItem.Create(fPopupMenu);
 {$ifdef FMX}fPopupMenuItemClear.Text{$else}fPopupMenuItemClear.Caption{$endif}:='Clear';
 fPopupMenuItemClear.OnClick:=OnMenuClearClick;
 {$ifndef FMX}fPopupMenu.Items.Add(fPopupMenuItemClear);{$endif}

 PopupMenu:=fPopupMenu;
end;

procedure TPasLLMChatControl.TChatMessageAreaControl.OnMenuSelectClick(aSender:TObject);
var MessageIndex:TPasLLMInt32;
begin
 // Get message at last clicked position
 MessageIndex:=MessageAtPoint(fSelectionStart.X,fSelectionStart.Y);
 if MessageIndex>=0 then begin
  fChatControl.SelectMessage(MessageIndex);
 end;
end;

procedure TPasLLMChatControl.TChatMessageAreaControl.OnMenuUnselectClick(aSender:TObject);
var MessageIndex:TPasLLMInt32;
begin
 // Get message at last clicked position
 MessageIndex:=MessageAtPoint(fSelectionStart.X,fSelectionStart.Y);
 if MessageIndex>=0 then begin
  fChatControl.UnselectMessage(MessageIndex);
 end;
end;

procedure TPasLLMChatControl.TChatMessageAreaControl.OnMenuSelectAllClick(aSender:TObject);
begin
 fChatControl.SelectAllMessages;
end;

procedure TPasLLMChatControl.TChatMessageAreaControl.OnMenuUnselectAllClick(aSender:TObject);
begin
 fChatControl.UnselectAllMessages;
end;

procedure TPasLLMChatControl.TChatMessageAreaControl.OnMenuCopyClick(aSender:TObject);
begin
 fChatControl.CopySelectedMessages;
end;

procedure TPasLLMChatControl.TChatMessageAreaControl.OnMenuClearClick(aSender:TObject);
begin
 fChatControl.Clear;
end;

function TPasLLMChatControl.TChatMessageAreaControl.GetMessageRectByIndex(const aIndex:TPasLLMInt32):{$ifdef FMX}TRectF{$else}TRect{$endif};
begin
 if (aIndex>=0) and (aIndex<fChatControl.fMessages.Count) then begin
  result:=fChatControl.fMessages[aIndex].fLayoutRect;
 end else begin
  result:={$ifdef FMX}RectF{$else}Rect{$endif}(0,0,0,0);
 end;
end;

procedure TPasLLMChatControl.TChatMessageAreaControl.UpdateScrollToBottomButtonRect;
var ButtonSize,CenterX,BottomY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
begin
 ButtonSize:=fChatControl.DIP(40);
{$ifdef FMX}
 CenterX:=fViewPortRect.Left+((fViewPortRect.Right-fViewPortRect.Left)*fChatControl.fScrollButtonHorizontalPosition);
{$else}
 CenterX:=fViewPortRect.Left+Round((fViewPortRect.Right-fViewPortRect.Left)*fChatControl.fScrollButtonHorizontalPosition);
{$endif}
 BottomY:=fViewPortRect.Bottom-fChatControl.DIP(16);
 fBottomScrollButtonRect:={$ifdef FMX}RectF{$else}Rect{$endif}(
  CenterX-({$ifdef FMX}ButtonSize*0.5{$else}ButtonSize div 2{$endif}),
  BottomY-ButtonSize,
  CenterX+({$ifdef FMX}ButtonSize*0.5{$else}ButtonSize div 2{$endif}),
  BottomY
 );
end;

// ============================================================================
// Scrolling
// ============================================================================

procedure TPasLLMChatControl.TChatMessageAreaControl.ScrollTo(const aY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif});
begin

 fScrollY:=Max(0,Min(aY,fMaxScrollY));

 // Check if it is on bottom
 fIsScrollOnBottom:=fScrollY>=fAutoScrollMaxScrollY;

 // Sync scrollbar position if visible
{$ifdef FMX}
 if fScrollBar.Visible and (not fScrollBar.IsFocused) and (fScrollBar.Value<>fScrollY) then begin
  fScrollBar.Value:=fScrollY;
 end;

 Repaint;
{$else}
 if fScrollBar.Visible and (not fScrollBar.Focused) and (fScrollBar.Position<>fScrollY) then begin
  fScrollBar.Position:=fScrollY;
 end;

 Invalidate;
{$endif}

end;

procedure TPasLLMChatControl.TChatMessageAreaControl.ScrollToBottom;
begin
 ScrollTo(fMaxScrollY);
end;

procedure TPasLLMChatControl.TChatMessageAreaControl.AutoScrollToBottom;
begin
 if fChatControl.fAutoScroll then begin
  if fIsScrollOnBottom then begin
   ScrollToBottom;
  end;
 end;
end;

procedure TPasLLMChatControl.TChatMessageAreaControl.EnsureVisible(const aRect:{$ifdef FMX}TRectF{$else}TRect{$endif});
var VisibleTop,VisibleBottom,MessageTop,MessageBottom:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
begin

 VisibleTop:=fScrollY;
 VisibleBottom:=fScrollY+fViewPortRect.Height;

 MessageTop:=aRect.Top;
 MessageBottom:=aRect.Bottom;

 if MessageTop<VisibleTop then begin
  ScrollTo(MessageTop);
 end else if MessageBottom>VisibleBottom then begin
  ScrollTo(MessageBottom-fViewPortRect.Height);
 end;

end;

// ============================================================================
// Selection and interaction
// ============================================================================

function TPasLLMChatControl.TChatMessageAreaControl.MessageAtPoint(const aX,aY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif}):TPasLLMInt32;
var Index:TPasLLMInt32;
    MessageRect:{$ifdef FMX}TRectF{$else}TRect{$endif};
begin
 result:=-1;
 for Index:=0 to fChatControl.fMessages.Count-1 do begin
  MessageRect:=fChatControl.fMessages[Index].fLayoutRect;
  if (aY>=MessageRect.Top) and (aY<=MessageRect.Bottom) and
     (aX>=MessageRect.Left) and (aX<=MessageRect.Right) then begin
   result:=Index;
   break;
  end;
 end;
end;

procedure TPasLLMChatControl.TChatMessageAreaControl.SelectMarkedMessages;
var Index:TPasLLMInt32;
    MessageRect:{$ifdef FMX}TRectF{$else}TRect{$endif};
    SelectionRect:{$ifdef FMX}TRectF{$else}TRect{$endif};
begin
 // Calculate selection rectangle
 SelectionRect:={$ifdef FMX}RectF{$else}Rect{$endif}(
  Min(fSelectionStart.X,fSelectionEnd.X),
  Min(fSelectionStart.Y,fSelectionEnd.Y),
  Max(fSelectionStart.X,fSelectionEnd.X),
  Max(fSelectionStart.Y,fSelectionEnd.Y)
 );

 // Only process if selection has some size
 if (Abs(fSelectionEnd.X-fSelectionStart.X)>3) or (Abs(fSelectionEnd.Y-fSelectionStart.Y)>3) then begin

  // Check which messages intersect with selection rectangle
  for Index:=0 to fChatControl.fMessages.Count-1 do begin

   MessageRect:=fChatControl.fMessages[Index].fLayoutRect;

   // Select message if it intersects with selection rectangle
   if (MessageRect.Bottom>=SelectionRect.Top) and
      (MessageRect.Top<=SelectionRect.Bottom) and
      (MessageRect.Right>=SelectionRect.Left) and
      (MessageRect.Left<=SelectionRect.Right) then begin
    fChatControl.fMessages[Index].fSelected:=true;
   end;
  end;

{$ifdef FMX}
  Invalidate;
{$else}
  Invalidate;
{$endif}

 end;
end;

// ============================================================================
// Utility
// ============================================================================

procedure TPasLLMChatControl.TChatMessageAreaControl.Clear;
begin
 fScrollY:=0;
 fAutoScrollMaxScrollY:=0;
 fMaxScrollY:=0;
 fSelecting:=false;
 fSelectedText:='';
 fSelectionStart:={$ifdef FMX}PointF{$else}Point{$endif}(0,0);
 fSelectionEnd:={$ifdef FMX}PointF{$else}Point{$endif}(0,0);
{$ifdef FMX}
 Invalidate;
{$else}
 Invalidate;
{$endif}
end;

// ============================================================================
// Popup menu handlers
// ============================================================================

{ TPasLLMChatControl.TChatThread }

constructor TPasLLMChatControl.TChatThread.Create(const aChatControl:TPasLLMChatControl);
begin
 fChatControl:=aChatControl;
 fInputQueue:=TStringQueue.Create;
 fOutputQueue:=TStringQueue.Create;
 fOutputQueueLock:=TPasMPCriticalSection.Create;
 fEvent:=TPasMPEvent.Create(nil,false,false,'');
 fActionDoneEvent:=TPasMPEvent.Create(nil,false,false,'');
 fActiveModel:=-1;
 fModel:=0;
 fSessionToLoad:='';
 fAction:=ActionNone;
 inherited Create(false);
end;

destructor TPasLLMChatControl.TChatThread.Destroy;
begin
 FreeAndNil(fInputQueue);
 FreeAndNil(fOutputQueue);
 FreeAndNil(fOutputQueueLock);
 FreeAndNil(fEvent);
 FreeAndNil(fActionDoneEvent);
 inherited Destroy;
end;

function TPasLLMChatControl.TChatThread.OnInputHook(const aSender:TPasLLMModelInferenceInstance.TChatSession;const aPrompt:TPasLLMUTF8String):TPasLLMUTF8String;
var Input:TPasLLMUTF8String;
begin

 fProcessing:=false;

 Synchronize(fChatControl.Process);

 // Check for abort before waiting
 if OnCheckAbortHook(fChatSession) then begin
  result:='';
  exit;
 end;

 // Set focus to memo input via synchronization
 Synchronize(SynchronizedSetMemoInputFocus);

 // Wait for event, but it will be signaled on abort too
 fEvent.WaitFor;

 // Check for abort after waiting - this is the key check
 if OnCheckAbortHook(fChatSession) then begin
  result:='';
  exit;
 end;

 result:='';
 while fInputQueue.Dequeue(Input) do begin
  result:=result+Input;
 end;

 fProcessing:=true;

 Synchronize(fChatControl.Process);

end;

procedure TPasLLMChatControl.TChatThread.OnOutputHook(const aSender:TPasLLMModelInferenceInstance.TChatSession;const aOutput:TPasLLMUTF8String);
begin
 fOutputQueueLock.Acquire;
 try
  fOutputQueue.Enqueue(aOutput);
 finally
  fOutputQueueLock.Release;
 end;
 Synchronize(fChatControl.Process);
end;

function TPasLLMChatControl.TChatThread.OnCheckTerminatedHook(const aSender:TPasLLMModelInferenceInstance.TChatSession):boolean;
begin
 result:=Terminated;
 if not result then begin
  case TPasMPInterlocked.Read(fAction) of
   ActionNewModel:begin
    result:=true;
   end;
   ActionNewSession:begin
    result:=true;
   end;
   ActionLoadSession:begin
    result:=true;
   end;
   ActionAborted:begin
   end;
   ActionToolsChanged:begin
   end;
   ActionTerminated:begin
    result:=true;
   end;
   else begin
    result:=false;
   end;
  end;
 end;
end;

function TPasLLMChatControl.TChatThread.OnCheckAbortHook(const aSender:TPasLLMModelInferenceInstance.TChatSession):boolean;
begin
 case TPasMPInterlocked.Read(fAction) of
  ActionNewModel:begin
   result:=true;
  end;
  ActionNewSession:begin
   result:=true;
  end;
  ActionLoadSession:begin
   result:=true;
  end;
  ActionAborted:begin
   result:=true;
  end;
  ActionToolsChanged:begin
   result:=true;
  end;
  ActionTerminated:begin
   result:=true;
  end;
  else begin
   result:=false;
  end;
 end;
end;

procedure TPasLLMChatControl.TChatThread.OnSideTurnHook(const aSender:TPasLLMModelInferenceInstance.TChatSession;const aSide:TPasLLMUTF8String);
begin
 Synchronize(fChatControl.Process);
 // Empty procedure to suppress 'user:' and 'assistant:' prefixes
 // By doing nothing here, we prevent the role prefixes from being output
 if aSide='User' then begin
  Synchronize(SynchronizedSessionOnUserSide);
 end else if aSide='Assistant' then begin
  Synchronize(SynchronizedSessionOnAssistantSide);
 end else if aSide='Tool' then begin
  Synchronize(SynchronizedSessionOnToolSide);
 end;
end;

procedure TPasLLMChatControl.TChatThread.SessionOnStateChange(const aSender:TPasLLMModelInferenceInstance.TChatSession;const aOldState,aNewState:TPasLLMModelInferenceInstance.TChatSession.TState);
begin
 Synchronize(fChatControl.Process);
 // Cache the parameters and synchronize
 fCachedSender:=aSender;
 fCachedOldState:=aOldState;
 fCachedNewState:=aNewState;
 Synchronize(SynchronizedSessionOnStateChange);
end;

procedure TPasLLMChatControl.TChatThread.SynchronizedSessionOnStateChange;
begin
 // Call the main control's state change handler from main thread
 if assigned(fChatControl) then begin
  fChatControl.SessionOnStateChange(fCachedSender,fCachedOldState,fCachedNewState);
 end;
end;

procedure TPasLLMChatControl.TChatThread.SynchronizedSessionOnUserSide;
var ChatMessage:TChatMessage;
begin

 if assigned(fChatControl) then begin

  if (fChatControl.fCurrentStreamingIndex>=0) and (fChatControl.fCurrentStreamingIndex<fChatControl.fMessages.Count) then begin
   ChatMessage:=fChatControl.fMessages[fChatControl.fCurrentStreamingIndex];
  end else if fChatControl.fMessages.Count>0 then begin
   ChatMessage:=fChatControl.fMessages[fChatControl.fMessages.Count-1];
  end else begin
   ChatMessage:=nil;
  end;

  if assigned(ChatMessage) then begin
   if (ChatMessage.fRole=TChatRole.Assistant) or (ChatMessage.fRole=TChatRole.Tool) then begin
    ChatMessage.fStreaming:=false;
   end;
  end;

  fChatControl.fCurrentStreamingIndex:=-1;

  fChatControl.CalculateLayout;
{$ifdef FMX}
  fChatControl.InvalidateRect(fChatControl.GetLocalRect);
{$else}
  fChatControl.fMessageArea.Invalidate;
{$endif}
  fChatControl.AutoScrollToBottom;

 end;

end;

procedure TPasLLMChatControl.TChatThread.SynchronizedSessionOnAssistantSide;
var ChatMessage:TChatMessage;
    MustAdd:Boolean;
begin
 if assigned(fChatControl) then begin

  if (fChatControl.fCurrentStreamingIndex>=0) and (fChatControl.fCurrentStreamingIndex<fChatControl.fMessages.Count) then begin
   ChatMessage:=fChatControl.fMessages[fChatControl.fCurrentStreamingIndex];
   if ChatMessage.fRole=TChatRole.Tool then begin
    ChatMessage.Streaming:=false;
    ChatMessage:=nil;
   end;
  end else if fChatControl.fMessages.Count>0 then begin
   ChatMessage:=fChatControl.fMessages[fChatControl.fMessages.Count-1];
   if ChatMessage.fRole=TChatRole.Assistant then begin
    fChatControl.fCurrentStreamingIndex:=fChatControl.fMessages.Count-1;
    ChatMessage.Streaming:=true;
   end else if ChatMessage.fRole=TChatRole.Tool then begin
    ChatMessage.Streaming:=false;
   end;
  end else begin
   ChatMessage:=nil;
  end;

  if assigned(ChatMessage) then begin
   if ChatMessage.fRole=TChatRole.Assistant then begin
    MustAdd:=false;
   end else begin
    MustAdd:=true;
   end;
  end else begin
   MustAdd:=true;
  end;

  if MustAdd then begin

   fChatControl.fCurrentStreamingIndex:=fChatControl.AddMessage(TChatRole.Assistant,'');
   if (fChatControl.fCurrentStreamingIndex>=0) and (fChatControl.fCurrentStreamingIndex<fChatControl.fMessages.Count) then begin
    ChatMessage:=fChatControl.fMessages[fChatControl.fCurrentStreamingIndex];
    ChatMessage.Streaming:=true;
    fChatControl.fTypingStartTime:=GetTickCount64;
    fChatControl.fLastTypingAnimationPhase:=-1;
   end;
   fChatControl.fIsWorking:=true;
   fChatControl.UpdateInputState;

   fChatControl.CalculateLayout;
{$ifdef FMX}
   fChatControl.InvalidateRect(fChatControl.GetLocalRect);
{$else}
   fChatControl.fMessageArea.Invalidate;
{$endif}
   fChatControl.AutoScrollToBottom;

  end;

 end;

end;

procedure TPasLLMChatControl.TChatThread.SynchronizedSessionOnToolSide;
var ChatMessage:TChatMessage;
    MustAdd:Boolean;
begin
 if assigned(fChatControl) then begin

  if (fChatControl.fCurrentStreamingIndex>=0) and (fChatControl.fCurrentStreamingIndex<fChatControl.fMessages.Count) then begin
   ChatMessage:=fChatControl.fMessages[fChatControl.fCurrentStreamingIndex];
   if ChatMessage.fRole=TChatRole.Assistant then begin
    ChatMessage.Streaming:=false;
    ChatMessage:=nil;
   end;
  end else if fChatControl.fMessages.Count>0 then begin
   ChatMessage:=fChatControl.fMessages[fChatControl.fMessages.Count-1];
   if ChatMessage.fRole=TChatRole.Tool then begin
    fChatControl.fCurrentStreamingIndex:=fChatControl.fMessages.Count-1;
    ChatMessage.Streaming:=true;
   end else if ChatMessage.fRole=TChatRole.Assistant then begin
    ChatMessage.Streaming:=false;
   end;
  end else begin
   ChatMessage:=nil;
  end;

{ if assigned(ChatMessage) then begin
   if ChatMessage.fRole=TChatRole.Tool then begin
    MustAdd:=false;
   end else begin
    MustAdd:=true;
   end;
  end else begin
   MustAdd:=true;
  end;}

  MustAdd:=true;

  if MustAdd then begin

   fChatControl.fCurrentStreamingIndex:=fChatControl.AddMessage(TChatRole.Tool,'');
   if (fChatControl.fCurrentStreamingIndex>=0) and (fChatControl.fCurrentStreamingIndex<fChatControl.fMessages.Count) then begin
    ChatMessage:=fChatControl.fMessages[fChatControl.fCurrentStreamingIndex];
    ChatMessage.Streaming:=true;
    fChatControl.fTypingStartTime:=GetTickCount64;
    fChatControl.fLastTypingAnimationPhase:=-1;
   end;
   fChatControl.fIsWorking:=true;
   fChatControl.UpdateInputState;

   fChatControl.CalculateLayout;
{$ifdef FMX}
   fChatControl.InvalidateRect(fChatControl.GetLocalRect);
{$else}
   fChatControl.fMessageArea.Invalidate;
{$endif}
   fChatControl.AutoScrollToBottom;

  end;

 end;

end;

procedure TPasLLMChatControl.TChatThread.SessionOnMessage(const aSender:TPasLLMModelInferenceInstance.TChatSession;const aMessage:TPasLLMModelInferenceInstance.TChatSession.TMessage);
begin
 // Cache the parameters and synchronize
 fCachedSender:=aSender;
 fCachedMessage:=aMessage;
 Synchronize(SynchronizedSessionOnMessage);
end;

procedure TPasLLMChatControl.TChatThread.SynchronizedSessionOnMessage;
begin
 // Call the main control's message handler from main thread
 if assigned(fChatControl) then begin
  fChatControl.SessionOnMessage(fCachedSender,fCachedMessage);
 end;
end;

procedure TPasLLMChatControl.TChatThread.SessionOnTokenGenerated(const aSender:TPasLLMModelInferenceInstance.TChatSession;const aToken:TPasLLMUTF8String);
begin
 // Cache the parameters and synchronize
 fCachedSender:=aSender;
 fCachedToken:=aToken;
 Synchronize(SynchronizedSessionOnTokenGenerated);
end;

procedure TPasLLMChatControl.TChatThread.SynchronizedSessionOnTokenGenerated;
begin
 // Call the main control's token handler from main thread
 if assigned(fChatControl) then begin
  fChatControl.SessionOnTokenGenerated(fCachedSender,fCachedToken);
 end;
end;

procedure TPasLLMChatControl.TChatThread.SynchronizedSetToolsEnabled;
begin
 if assigned(fChatControl) then begin
  if fChatControl.ToolsEnabled<>fChatSession.ToolsEnabled then begin
   fChatControl.ToolsEnabled:=fChatSession.ToolsEnabled;
  end;
 end;
end;

procedure TPasLLMChatControl.TChatThread.SynchronizedSetModelIndex;
begin
 // Set the model combobox item index from main thread
 if assigned(fChatControl) and assigned(fChatControl.fComboBoxModel) then begin
  if (fCachedModelIndex>=0) and (fCachedModelIndex<fChatControl.fComboBoxModel.Items.Count) then begin
   if fChatControl.fComboBoxModel.ItemIndex<>fCachedModelIndex then begin
    fChatControl.fComboBoxModel.ItemIndex:=fCachedModelIndex;
   end;
  end;
 end;
end;

procedure TPasLLMChatControl.TChatThread.SynchronizedSetMemoInputFocus;
begin
 // Set focus to memo input from main thread
 if assigned(self) and assigned(fChatControl) and assigned(fChatControl.fMemoInput) then begin
{$ifndef FMX}
  fChatControl.fMemoInput.SetFocus;
{$endif}
 end;
end;

procedure TPasLLMChatControl.TChatThread.SetSessionFromThread;
begin
 if assigned(self) and assigned(fChatControl) then begin
  fChatControl.fSession:=fChatSession;
  if assigned(fChatControl.fSession) then begin
   fChatControl.fSession.OnStateChange:=SessionOnStateChange;
   fChatControl.fSession.OnGetModelInfo:=fChatControl.SessionOnGetModelInfo;
  end;
 end;
end;

procedure TPasLLMChatControl.TChatThread.AddDefaultTools;
begin
end;

procedure TPasLLMChatControl.TChatThread.Execute;
var Index,ModelIndex,Action:TPasLLMInt32;
    PasMPInstance:TPasMP;
    PasLLMInstance:TPasLLM;
    PasLLMModel:TPasLLMModel;
    PasLLMModelInferenceInstance:TPasLLMModelInferenceInstance;
    Path,ModelFileName,ModelInfo:TPasLLMUTF8String;
    First:Boolean;
begin
 Path:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'models');

 fProcessing:=false;
 PasMPInstance:=TPasMP.CreateGlobalInstance;
 fActiveModel:=-1;
 fModel:=0;
 TPasMPInterlocked.Write(fAction,ActionNone);
 PasLLMInstance:=TPasLLM.Create(PasMPInstance);
 try

  repeat

   First:=true;

   fProcessing:=true;

   Action:=TPasMPInterlocked.Exchange(fAction,ActionNone);

   // Handle model selection for ActionLoadSession before loading model
   case Action of
    ActionLoadSession:begin
     // For session loading, we need to read the session file first to get model info
     if length(fSessionToLoad)>0 then begin
      try
       // Create temporary session to read model info
       fChatSession:=TPasLLMModelInferenceInstance.TChatSession.Create(nil);
       try
        fChatSession.ToolsEnabled:=true;
        if assigned(fChatControl.fOnLoadToolConfigurationEvent) then begin
         fChatControl.fOnLoadToolConfigurationEvent(fChatControl,fChatSession);
        end;
        fChatSession.TavilyKey:=fChatControl.fTavilyKey;
        fChatSession.AddDefaultTools;
        AddDefaultTools;
        // Load model info directly without callbacks
        if fChatSession.LoadSessionModelInfoFromJSONFile(fSessionToLoad,ModelInfo) then begin
         // Find model index for this model info and set fModel directly
         ModelIndex:=-1;
         for Index:=0 to length(fChatControl.fModels)-1 do begin
          if fChatControl.fModels[Index].FileName=ModelInfo then begin
           ModelIndex:=Index;
           break;
          end;
         end;
         if ModelIndex>=0 then begin
          fModel:=ModelIndex;
          // Cache model index and synchronize to update UI
          fCachedModelIndex:=ModelIndex;
          Synchronize(SynchronizedSetModelIndex);
         end;
         Synchronize(SynchronizedSetToolsEnabled);
        end;
       finally
        FreeAndNil(fChatSession);
       end;
      except
       // Handle load error silently or log
      end;
     end;
    end;
    ActionTerminated:begin
     break; // Exit the main loop and terminate thread
    end;
    else begin
     // For other actions, use fModel as is
    end;
   end;

   fActiveModel:=fModel;

   // Use model from fModels array
   if (fActiveModel>=0) and (fActiveModel<length(fChatControl.fModels)) then begin
    ModelFileName:=fChatControl.fModels[fActiveModel].FileName;
   end else begin
    ModelFileName:='';
   end;

   ModelFileName:=Path+ModelFileName;

   if (Length(ModelFileName)>0) and FileExists(ModelFileName) then begin

    PasLLMModel:=TPasLLMModel.Create(PasLLMInstance,ModelFileName,4096);
    try

     // Optional configuration
     // PasLLMModel.Configuration.PenaltyLastN:=256;
     // PasLLMModel.Configuration.PenaltyRepeat:=1.18;

     PasLLMModelInferenceInstance:=TPasLLMModelInferenceInstance.Create(PasLLMModel);
     try

      repeat

       fChatSession:=PasLLMModelInferenceInstance.CreateChatSession;
       Synchronize(SetSessionFromThread);

       try

        fChatSession.ToolsEnabled:=fChatControl.ToolsEnabled;
        if assigned(fChatControl.fOnLoadToolConfigurationEvent) then begin
         fChatControl.fOnLoadToolConfigurationEvent(fChatControl,fChatSession);
        end;
        fChatSession.TavilyKey:=fChatControl.fTavilyKey;
        fChatSession.AddDefaultTools;
        AddDefaultTools;

        fChatSession.OnInput:=OnInputHook;
        fChatSession.OnOutput:=OnOutputHook;
        fChatSession.OnCheckTerminated:=OnCheckTerminatedHook;
        fChatSession.OnCheckAbort:=OnCheckAbortHook;
        fChatSession.OnSideTurn:=OnSideTurnHook;
        fChatSession.State:=TPasLLMModelInferenceInstance.TChatSession.TState.UserInput;

        // Handle actions
        case Action of
         ActionNewSession:begin
          // Start fresh session
          fChatSession.Reset;
          TPasMPInterlocked.Write(fAction,ActionNone);
         end;
         ActionLoadSession:begin
          // Load the actual session content (model was already loaded above)
          if length(fSessionToLoad)>0 then begin
           try
            // Load content without triggering model info callback
            fChatSession.LoadSessionContentFromJSONFile(fSessionToLoad);
           except
            // Handle load error silently or log
           end;
          end;
          TPasMPInterlocked.Write(fAction,ActionNone);
         end;
         else begin
         end;
        end;

        fProcessing:=false;

        if First then begin
         First:=false;
         fActionDoneEvent.SetEvent; // Signal that action is complete
        end;

        repeat
         ChatSession.Run;
         Action:=TPasMPInterlocked.Read(fAction);
         case Action of
          ActionAborted:begin
           // Reset action and abort current session processing
           TPasMPInterlocked.Write(fAction,ActionNone);
           ChatSession.State:=TPasLLMModelInferenceInstance.TChatSession.TState.UserInput;
           fChatSession.ToolsEnabled:=fChatControl.ToolsEnabled;
          end;
          ActionToolsChanged:begin
           fChatSession.ToolsEnabled:=fChatControl.ToolsEnabled;
          end;
          else begin
           break;
          end;
         end;
        until Terminated;

       finally
        FreeAndNil(fChatSession);
        Synchronize(SetSessionFromThread);
       end;

       Action:=TPasMPInterlocked.Read(fAction);
       case Action of
        ActionNewSession:begin
         First:=true;
        end;
        ActionNewModel,ActionLoadSession:begin
         break;
        end;
        else begin
        end;
       end;

      until Terminated;

     finally
      FreeAndNil(PasLLMModelInferenceInstance);
     end;

    finally
     FreeAndNil(PasLLMModel);
    end;

   end else begin
    // No model file found, wait a bit and retry
    Sleep(100);
    fActionDoneEvent.SetEvent; // Signal that action is complete
   end;

  until Terminated;

  fActionDoneEvent.SetEvent; // Signal that action is complete

 finally
  FreeAndNil(PasLLMInstance);
 end;
end;

{$ifdef Windows}
function GetAppDataLocalStoragePath(Postfix:string):string;
type TSHGetFolderPath=function(hwndOwner:hwnd;nFolder:TPasLLMInt32;nToken:Windows.THandle;dwFlags:TPasLLMInt32;lpszPath:PWideChar):hresult; stdcall;
const CSIDL_LOCALAPPDATA=$001c;
var SHGetFolderPath:TSHGetFolderPath;
    FilePath:PWideChar;
    LibHandle:Windows.THandle;
    Reg:TRegistry;
begin
 result:='';
 try
  // First try over the SHFOLDER.DLL from MSIE >= 5.0 on Win9x or from Windows >= 2000
  LibHandle:=LoadLibrary('SHFOLDER.DLL');
  if LibHandle<>0 then begin
   try
    SHGetFolderPath:=GetProcAddress(LibHandle,'SHGetFolderPathW');
    GetMem(FilePath,4096*2);
    FillChar(FilePath^,4096*2,ansichar(#0));
    try
     if SHGetFolderPath(0,CSIDL_LOCALAPPDATA,0,0,FilePath)=0 then begin
      result:=String(WideString(FilePath));
     end;
    finally
     FreeMem(FilePath);
    end;
   finally
    FreeLibrary(LibHandle);
   end;
  end;
 except
  result:='';
 end;
 if length(result)=0 then begin
   // Other try over the %localappdata% enviroment variable
  result:=String(GetEnvironmentVariable('localappdata'));
  if length(result)=0 then begin
   try
    // Again ather try over the windows registry
    Reg:=TRegistry.Create;
    try
     Reg.RootKey:=HKEY_CURRENT_USER;
     if Reg.OpenKeyReadOnly('Volatile Environment') then begin
      try
       try
        result:=Reg.ReadString('LOCALAPPDATA');
       except
        result:='';
       end;
      finally
       Reg.CloseKey;
      end;
     end;
    finally
     Reg.Free;
    end;
   except
    result:='';
   end;
   if length(result)=0 then begin
    // Fallback for Win9x without SHFOLDER.DLL from MSIE >= 5.0
    result:=String(GetEnvironmentVariable('windir'));
    if length(result)>0 then begin
     // For german Win9x installations
     result:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(String(result))+'Lokale Einstellungen')+'Anwendungsdaten';
     if not DirectoryExists(String(result)) then begin
      // For all other language Win9x installations
      result:=IncludeTrailingPathDelimiter(String(result))+'Local Settings';
      if not DirectoryExists(String(result)) then begin
       result:=IncludeTrailingPathDelimiter(String(result))+'Engine Data';
       if not DirectoryExists(String(result)) then begin
        CreateDir(String(result));
       end;
      end;
     end;
    end else begin
     // Oops!!! So use simply our own program directory then!
     result:=ExtractFilePath(ParamStr(0));
    end;
   end;
  end;
 end;
 if length(Postfix)>0 then begin
  result:=String(IncludeTrailingPathDelimiter(String(result))+String(Postfix));
  if not DirectoryExists(String(result)) then begin
   CreateDir(String(result));
  end;
 end;
 result:=IncludeTrailingPathDelimiter(String(result));
end;
{$else}
function GetAppDataLocalStoragePath(Postfix:TPasLLMUTF8String):TPasLLMUTF8String;
{$ifdef darwin}
var TruePath:TPasLLMUTF8String;
{$endif}
begin
{$ifdef darwin}
{$ifdef darwinsandbox}
 if DirectoryExists(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'))+'Library')+'Containers') then begin
  if length(Postfix)>0 then begin
   TruePath:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'))+'Library')+'Containers')+Postfix;
   if not DirectoryExists(TruePath) then begin
    CreateDir(TruePath);
   end;
   result:=TruePath;
  end else begin
   result:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'))+'Library')+'Containers';
  end;
 end else{$endif} begin
  if length(Postfix)>0 then begin
   result:=IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'))+'.'+Postfix;
   if not DirectoryExists(result) then begin
    TruePath:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'))+'Library')+'Engine Support')+Postfix;
    if not DirectoryExists(TruePath) then begin
     CreateDir(TruePath);
    end;
    if DirectoryExists(TruePath) then begin
     fpSymLink(PAnsiChar(TruePath),PAnsiChar(result));
    end else begin
     TruePath:=result;
    end;
    if not DirectoryExists(result) then begin
     CreateDir(result);
    end;
   end;
  end else begin
   result:=GetEnvironmentVariable('HOME');
   if DirectoryExists(result) then begin
    TruePath:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(result)+'Library')+'Application Support';
    if DirectoryExists(TruePath) then begin
     result:=TruePath;
    end;
   end;
  end;
 end;
 result:=IncludeTrailingPathDelimiter(result)+'local';
 if not DirectoryExists(result) then begin
  CreateDir(result);
 end;
{$else}
 result:=GetEnvironmentVariable('XDG_DATA_HOME');
 if (length(result)=0) or not DirectoryExists(result) then begin
  result:=GetEnvironmentVariable('HOME');
  if not DirectoryExists(result) then begin
   CreateDir(result);
  end;
  result:=IncludeTrailingPathDelimiter(result)+'.local';
  if not DirectoryExists(result) then begin
   CreateDir(result);
  end;
  result:=IncludeTrailingPathDelimiter(result)+'share';
  if not DirectoryExists(result) then begin
   CreateDir(result);
  end;
 end;
 if length(Postfix)>0 then begin
  result:=IncludeTrailingPathDelimiter(result)+Postfix;
  if not DirectoryExists(result) then begin
   CreateDir(result);
  end;
 end;
{$endif}
 result:=IncludeTrailingPathDelimiter(result);
end;
{$endif}

{ TPasLLMChatControl }

constructor TPasLLMChatControl.Create(aOwner:TComponent);
begin

 inherited Create(aOwner);

 fTavilyKey:='';

 fStorageDirectory:=GetAppDataLocalStoragePath(ChangeFileExt(ExtractFileName(ParamStr(0)),''));
 if not DirectoryExists(fStorageDirectory) then begin
  MkDir(fStorageDirectory);
 end;

 fModelDirectory:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'models');

 fOnLoadToolConfigurationEvent:=DefaultLoadToolConfigurationEvent;

 // Initialize session database
 EnsureSessionsDirectory;
 fSessionDatabase:=TSessionDatabase.Create(IncludeTrailingPathDelimiter(fSessionsDirectory)+'sessions.json');

 fInLoadSession:=false;

 // Initialize per-monitor DPI once
 fPPI:=GetCurrentPPI;

 fOldWidth:=-1;
 fOldHeight:=-1;

 // Initialize data
 fMessages:=TChatMessages.Create(true);
 fSession:=nil;
 fCurrentStreamingIndex:=-1;
 fAutoScroll:=true;

 fSelectedModel:='';
 fModels:=nil;

 // Threading
 fChatThread:=nil;
 fProcessing:=false;

 // Visual defaults
 fMessagePadding:=8;
 fMessageMargin:=4;
 fLineSpacing:=4;
 fMaxInputHeight:=100;
 fWrapWidthPercent:=75;
 fScrollButtonHorizontalPosition:=0.5; // Center

 // Color defaults
 fColorBackground:=TPasLLMChatControl.DEF_COLOR_BACKGROUND;
 fColorUser:=TPasLLMChatControl.DEF_COLOR_USER;
 fColorAssistant:=TPasLLMChatControl.DEF_COLOR_ASSISTANT;
 fColorSystem:=TPasLLMChatControl.DEF_COLOR_SYSTEM;
 fColorTool:=TPasLLMChatControl.DEF_COLOR_TOOL;
 fColorScrollButton:=TPasLLMChatControl.DEF_COLOR_SCROLL_BUTTON;
 fColorScrollButtonHover:=TPasLLMChatControl.DEF_COLOR_SCROLL_BUTTON_HOVER;
 fColorScrollButtonIcon:=TPasLLMChatControl.DEF_COLOR_SCROLL_BUTTON_ICON;

 // Initialize state
 fTypingStartTime:=0;
 fLastRepaintTime:=0;
 fRepaintPending:=false;
 fIsWorking:=false;
 fLastTypingAnimationPhase:=-1;
 fPendingTokens:='';

 // Create prompt history
 fPromptHistory:=nil;
 fPromptHistoryCount:=0;
 fHistoryIndex:=-1;

 // Control properties
{$ifndef FMX}
//Color:=clWindow;
 ParentColor:=true;
 TabStop:=true;
{$ifdef fpc}
 DoubleBuffered:=true;
{$else}
 DoubleBuffered:=false;
{$endif}
{$endif}

{$ifdef FMX}
 ClipChildren:=true;
{$endif}

 fToolsEnabled:=false;

 // Set up input area
 SetupInputArea;

 // Set up input area
 SetupMessageArea;

 // Start chat thread
 StartChatThread;

end;

destructor TPasLLMChatControl.Destroy;
begin
 StopChatThread;
 fMessages.Free;
 fPromptHistory:=nil;
 fModels:=nil;
 FreeAndNil(fSessionDatabase);
 FreeAndNil(fSessionListPopupMenu);
 inherited Destroy;
end;

{$ifndef fmx}
{$ifndef fpc}
{procedure TPasLLMChatControl.WMEraseBkGnd(var Message:TMessage);
begin
 Message.Result:=1;
end;}
{$endif}
{$endif}

function TPasLLMChatControl.GetCurrentPPI:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
{$ifdef FMX}
begin
 result:=96;
end;
{$else}
var Form:TCustomForm;
begin
 Form:=GetParentForm(Self);
 if Assigned(Form) and (Form.PixelsPerInch>0) then begin
  result:=Form.PixelsPerInch;
 end else if Screen.PixelsPerInch>0 then begin
  result:=Screen.PixelsPerInch;
 end else begin
  result:=96;
 end;
end;
{$endif}

function TPasLLMChatControl.DIP(const aValue:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif}):{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
begin
{$ifdef FMX}
 result:=aValue*(fPPI/96.0);
{$else}
 result:=MulDiv(aValue,fPPI,96);
{$endif}
end;

function TPasLLMChatControl.GetTypingAnimationPhase:TPasLLMInt32;
begin
 result:=2-(((fTypingStartTime-GetTickCount64) div 300) mod 3);
end;

procedure TPasLLMChatControl.SetToolsEnabled(const aToolsEnabled:Boolean);
begin
 if fToolsEnabled<>aToolsEnabled then begin
  fToolsEnabled:=aToolsEnabled;
  if assigned(fCheckBoxTools) then begin
{$ifdef FMX}
   fCheckBoxTools.IsChecked:=fToolsEnabled;
{$else}
   fCheckBoxTools.Checked:=fToolsEnabled;
{$endif}
  end;
  if assigned(fChatThread) and fIsWorking then begin
   TPasMPInterlocked.CompareExchange(fChatThread.fAction,TChatThread.ActionToolsChanged,TChatThread.ActionNone);
  end;
 end;
end;

procedure TPasLLMChatControl.DefaultLoadToolConfigurationEvent(aSender:TObject;const aSession:TPasLLMModelInferenceInstance.TChatSession);
var JSONFileName:TPasLLMUTF8String;
    JSONStream:TMemoryStream;
    JSONContentItem,JSONItem:TPasJSONItem;
begin
 JSONFileName:=IncludeTrailingPathDelimiter(ExtractFilePath(ChangeFileExt(ParamStr(0),'')))+'tools.json';
 if not FileExists(JSONFileName) then begin
  JSONFileName:=GetAppDataLocalStoragePath(ChangeFileExt(ParamStr(0),''))+'tools.json';
 end;
 if FileExists(JSONFileName) then begin
  JSONStream:=TMemoryStream.Create;
  try
   JSONStream.LoadFromFile(JSONFileName);
   JSONStream.Seek(0,soBeginning);
   JSONContentItem:=TPasJSON.Parse(JSONStream);
   if assigned(JSONContentItem) then begin
    try
     if JSONContentItem is TPasJSONItemObject then begin
      JSONItem:=TPasJSONItemObject(JSONContentItem).Properties['tavily_key'];
      if assigned(JSONItem) then begin
       fTavilyKey:=TPasJSON.GetString(JSONItem,fTavilyKey);
      end;
      JSONItem:=TPasJSONItemObject(JSONContentItem).Properties['mcp'];
      if assigned(JSONItem) then begin
       aSession.LoadMCPServersFromJSON(JSONItem);
      end;
     end;
    finally
     FreeAndNil(JSONContentItem);
    end;
   end;
  finally
   FreeAndNil(JSONStream);
  end;
 end;
end;

function TPasLLMChatControl.RoleToString(const aRole:TChatRole):TPasLLMUTF8String;
begin
 case aRole of
  TChatRole.System_:begin
   result:='system';
  end;
  TChatRole.User:begin
   result:='user';
  end;
  TChatRole.Assistant:begin
   result:='assistant';
  end;
  TChatRole.Tool:begin
   result:='tool';
  end;
  else begin
   result:='unknown';
  end;
 end;
end;

function TPasLLMChatControl.StringToRole(const aString:TPasLLMUTF8String):TChatRole;
begin
 if aString='system' then begin
  result:=TChatRole.System_;
 end else if aString='user' then begin
  result:=TChatRole.User;
 end else if aString='assistant' then begin
  result:=TChatRole.Assistant;
 end else if aString='tool' then begin
  result:=TChatRole.Tool;
 end else begin
  result:=TChatRole.User; // Default
 end;
end;

function TPasLLMChatControl.GetRoleColor(const aRole:TChatRole):{$ifdef FMX}TAlphaColor{$else}TColor{$endif};
begin
 case aRole of
  TChatRole.User:begin
   result:=fColorUser;
  end;
  TChatRole.Assistant:begin
   result:=fColorAssistant;
  end;
  TChatRole.System_:begin
   result:=fColorSystem;
  end;
  TChatRole.Tool:begin
   result:=fColorTool;
  end;
  else begin
   result:={$ifdef FMX}TAlphaColorRec.Black{$else}clWindow{$endif};
  end;
 end;
end;

function TPasLLMChatControl.GetRoleAlignment(const aRole:TChatRole):TAlignment;
begin
 case aRole of
  TChatRole.User:begin
   result:=taRightJustify;
  end;
  else begin
   result:=taLeftJustify;
  end;
 end;
end;

procedure TPasLLMChatControl.SetupInputArea;
var ButtonWidth,ButtonHeight:TPasLLMInt32;
    Models:TPasLLMModels;
begin

 ButtonWidth:=80;
 ButtonHeight:=25;

{fStatusBar:=TStatusBar.Create(Self);
 fStatusBar.Parent:=Self;
 fStatusBar.AnchorSide[akBottom].Side:=asrBottom;
 fStatusBar.AnchorSide[akBottom].Control:=Self;
 fStatusBar.AnchorSide[akLeft].Side:=asrLeft;
 fStatusBar.AnchorSide[akLeft].Control:=Self;
 fStatusBar.AnchorSide[akRight].Side:=asrRight;
 fStatusBar.AnchorSide[akRight].Control:=Self;
 fStatusBar.Anchors:=[akBottom,akLeft,akRight];
 fStatusBar.SimplePanel:=true;
 fStatusBar.SimpleText:='Ready';}

 // Create input panel
{$ifdef FMX}
 fPanelInput:=TPanel.Create(Self);
 fPanelInput.Parent:=Self;
 fPanelInput.Align:=TAlignLayout.Bottom;
{$else}
 fPanelInput:=TPanel.Create(Self);
 fPanelInput.Parent:=Self;
{$ifdef fpc}
 fPanelInput.AnchorSide[akBottom].Side:=asrBottom;
 fPanelInput.AnchorSide[akBottom].Control:=self;
 fPanelInput.AnchorSide[akLeft].Side:=asrLeft;
 fPanelInput.AnchorSide[akLeft].Control:=self;
 fPanelInput.AnchorSide[akRight].Side:=asrRight;
 fPanelInput.AnchorSide[akRight].Control:=self;
 fPanelInput.Anchors:=[akBottom,akLeft,akRight];
 fPanelInput.AutoSize:=true;
{$else}
 fPanelInput.Align:=TAlign.alBottom;
 fPanelInput.Height:=200;
 fPanelInput.AutoSize:=true;
{$endif}
{$endif}

 // Model combo
{$ifdef FMX}
 fComboBoxModel:=TComboBox.Create(fPanelInput);
 fComboBoxModel.Parent:=fPanelInput;
 fComboBoxModel.Align:=TAlignLayout.Top;
//fComboBoxModel.DropDownKind:=TDropDownKind.Native;
 fComboBoxModel.OnChange:=OnComboModelChange;
{$else}
 fComboBoxModel:=TComboBox.Create(fPanelInput);
 fComboBoxModel.Parent:=fPanelInput;
 fComboBoxModel.Style:=csDropDownList;
 fComboBoxModel.OnChange:=OnComboModelChange;
{$ifdef fpc}
 fComboBoxModel.BorderSpacing.Left:=DIP(8);
 fComboBoxModel.BorderSpacing.Top:=DIP(8);
 fComboBoxModel.BorderSpacing.Bottom:=DIP(4);
 fComboBoxModel.BorderSpacing.Right:=DIP(4);
 fComboBoxModel.AnchorSide[akLeft].Side:=asrLeft;
 fComboBoxModel.AnchorSide[akLeft].Control:=fPanelInput;
 fComboBoxModel.AnchorSide[akTop].Side:=asrTop;
 fComboBoxModel.AnchorSide[akTop].Control:=fPanelInput;
 fComboBoxModel.AnchorSide[akRight].Side:=asrRight;
 fComboBoxModel.AnchorSide[akRight].Control:=fPanelInput;
 fComboBoxModel.Anchors:=[akLeft,akRight,akTop];
{$else}
 fComboBoxModel.Align:=TAlign.alTop;
{$endif}
{$endif}

{$ifdef FMX}
 fPanelButtons:=TPanel.Create(fPanelInput);
 fPanelButtons.Parent:=fPanelInput;
 fPanelButtons.Align:=TAlignLayout.Right;

 fGridPanelLayout:=TGridPanelLayout.Create(fPanelButtons);
 fGridPanelLayout.Parent:=fPanelButtons;
 fGridPanelLayout.Align:=TAlignLayout.Client;
 fGridPanelLayout.BeginUpdate;
 try
  fGridPanelLayout.ColumnCollection.Clear;
  fGridPanelLayout.RowCollection.Clear;
  fGridPanelLayout.ColumnCollection.Add;
  fGridPanelLayout.RowCollection.Add;
  fGridPanelLayout.RowCollection.Add;
  fGridPanelLayout.RowCollection.Add;
  fGridPanelLayout.RowCollection.Add;
  fGridPanelLayout.RowCollection.Add;
  fGridPanelLayout.ColumnCollection[0].Value:=100.0;
  fGridPanelLayout.RowCollection[0].Value:=20;
  fGridPanelLayout.RowCollection[1].Value:=20;
  fGridPanelLayout.RowCollection[2].Value:=20;
  fGridPanelLayout.RowCollection[3].Value:=20;
  fGridPanelLayout.RowCollection[4].Value:=20;
 finally
  fGridPanelLayout.EndUpdate;
 end;
{$else}
 fPanelButtons:=TPanel.Create(fPanelInput);
 fPanelButtons.Parent:=fPanelInput;
{$ifdef fpc}
 fPanelButtons.BorderSpacing.Left:=DIP(4);
 fPanelButtons.BorderSpacing.Right:=DIP(8);
 fPanelButtons.BorderSpacing.Top:=DIP(8);
 fPanelButtons.BorderSpacing.Bottom:=DIP(4);
 fPanelButtons.AnchorSide[akRight].Side:=asrRight;
 fPanelButtons.AnchorSide[akRight].Control:=fPanelInput;
 fPanelButtons.AnchorSide[akTop].Side:=asrBottom;
 fPanelButtons.AnchorSide[akTop].Control:=fComboBoxModel;
 fPanelButtons.AnchorSide[akBottom].Side:=asrBottom;
 fPanelButtons.AnchorSide[akBottom].Control:=fPanelInput;
 fPanelButtons.Anchors:=[akTop,akRight,akBottom];
{$else}
 fPanelButtons.Align:=TAlign.alRight;
 fPanelButtons.Padding.Left:=DIP(4);
 fPanelButtons.Padding.Right:=DIP(4);
 fPanelButtons.Padding.Top:=DIP(4);
 fPanelButtons.Padding.Bottom:=DIP(4);
{$endif}
 fPanelButtons.BevelInner:=TPanelBevel.bvNone;
 fPanelButtons.BevelOuter:=TPanelBevel.bvLowered;
 fPanelButtons.AutoSize:=true;
{$endif}

 // Buttons
{$ifdef FMX}
 fButtonSend:=TButton.Create(fGridPanelLayout);
 fButtonSend.Parent:=fGridPanelLayout;
 fButtonSend.Align:=TAlignLayout.Client;
 fButtonSend.Text:='&Send';
 fButtonSend.OnClick:=OnButtonSendClick;
 fButtonSend.Default:=true;
{$else}
 fButtonSend:=TButton.Create(fPanelButtons);
 fButtonSend.Parent:=fPanelButtons;
 fButtonSend.Width:=DIP(ButtonWidth);
 fButtonSend.Height:=DIP(ButtonHeight);
{$ifdef fpc}
 fButtonSend.BorderSpacing.Left:=DIP(4);
 fButtonSend.BorderSpacing.Right:=DIP(4);
 fButtonSend.BorderSpacing.Top:=DIP(4);
 fButtonSend.BorderSpacing.Bottom:=DIP(4);
 fButtonSend.AnchorSide[akRight].Side:=asrRight;
 fButtonSend.AnchorSide[akRight].Control:=fPanelButtons;
 fButtonSend.AnchorSide[akTop].Side:=asrTop;
 fButtonSend.AnchorSide[akTop].Control:=fPanelButtons;
 fButtonSend.Anchors:=[akTop,akRight];
{$else}
 fButtonSend.Align:=TAlign.alTop;
{$endif}
 fButtonSend.Caption:='&Send';
 fButtonSend.OnClick:=OnButtonSendClick;
 fButtonSend.Default:=true;
{$endif}

{$ifdef FMX}
 fButtonStop:=TButton.Create(fGridPanelLayout);
 fButtonStop.Parent:=fGridPanelLayout;
 fButtonStop.Align:=TAlignLayout.Client;
 fButtonStop.Text:='St&op';
 fButtonStop.OnClick:=OnButtonStopClick;
 fButtonStop.Enabled:=false;
{$else}
 fButtonStop:=TButton.Create(fPanelButtons);
 fButtonStop.Parent:=fPanelButtons;
 fButtonStop.Width:=DIP(ButtonWidth);
 fButtonStop.Height:=DIP(ButtonHeight);
{$ifdef fpc}
 fButtonStop.BorderSpacing.Left:=DIP(4);
 fButtonStop.BorderSpacing.Right:=DIP(4);
 fButtonStop.BorderSpacing.Top:=DIP(4);
 fButtonStop.BorderSpacing.Bottom:=DIP(4);
 fButtonStop.AnchorSide[akRight].Side:=asrRight;
 fButtonStop.AnchorSide[akRight].Control:=fPanelButtons;
 fButtonStop.AnchorSide[akTop].Side:=asrBottom;
 fButtonStop.AnchorSide[akTop].Control:=fButtonSend;
 fButtonStop.Anchors:=[akTop,akRight];
{$else}
 fButtonStop.Align:=TAlign.alTop;
{$endif}
 fButtonStop.Caption:='St&op';
 fButtonStop.OnClick:=OnButtonStopClick;
 fButtonStop.Enabled:=false;
{$endif}

{$ifdef FMX}
 fButtonClear:=TButton.Create(fGridPanelLayout);
 fButtonClear.Parent:=fGridPanelLayout;
 fButtonClear.Align:=TAlignLayout.Client;
 fButtonClear.Text:='&Clear';
 fButtonClear.OnClick:=OnButtonClearClick;
{$else}
 fButtonClear:=TButton.Create(fPanelButtons);
 fButtonClear.Parent:=fPanelButtons;
 fButtonClear.Width:=DIP(ButtonWidth);
 fButtonClear.Height:=DIP(ButtonHeight);
{$ifdef fpc}
 fButtonClear.BorderSpacing.Left:=DIP(4);
 fButtonClear.BorderSpacing.Right:=DIP(4);
 fButtonClear.BorderSpacing.Top:=DIP(4);
 fButtonClear.BorderSpacing.Bottom:=DIP(4);
 fButtonClear.AnchorSide[akRight].Side:=asrRight;
 fButtonClear.AnchorSide[akRight].Control:=fPanelButtons;
 fButtonClear.AnchorSide[akTop].Side:=asrBottom;
 fButtonClear.AnchorSide[akTop].Control:=fButtonStop;
 fButtonClear.Anchors:=[akTop,akRight];
{$else}
 fButtonClear.Align:=TAlign.alTop;
{$endif}
 fButtonClear.Caption:='&Clear';
 fButtonClear.OnClick:=OnButtonClearClick;
{$endif}

{$ifdef FMX}
 fButtonCopyLast:=TButton.Create(fGridPanelLayout);
 fButtonCopyLast.Parent:=fGridPanelLayout;
 fButtonCopyLast.Align:=TAlignLayout.Client;
 fButtonCopyLast.Text:='Copy &Last';
 fButtonCopyLast.OnClick:=OnButtonCopyLastClick;
{$else}
 fButtonCopyLast:=TButton.Create(fPanelButtons);
 fButtonCopyLast.Parent:=fPanelButtons;
 fButtonCopyLast.Width:=DIP(ButtonWidth);
 fButtonCopyLast.Height:=DIP(ButtonHeight);
{$ifdef fpc}
 fButtonCopyLast.BorderSpacing.Left:=DIP(4);
 fButtonCopyLast.BorderSpacing.Right:=DIP(4);
 fButtonCopyLast.BorderSpacing.Top:=DIP(4);
 fButtonCopyLast.BorderSpacing.Bottom:=DIP(4);
 fButtonCopyLast.AnchorSide[akRight].Side:=asrRight;
 fButtonCopyLast.AnchorSide[akRight].Control:=fPanelButtons;
 fButtonCopyLast.AnchorSide[akTop].Side:=asrBottom;
 fButtonCopyLast.AnchorSide[akTop].Control:=fButtonClear;
 fButtonCopyLast.Anchors:=[akTop,akRight];
{$else}
 fButtonCopyLast.Align:=TAlign.alTop;
{$endif}
 fButtonCopyLast.Caption:='Copy &Last';
 fButtonCopyLast.OnClick:=OnButtonCopyLastClick;
{$endif}

{$ifdef FMX}
 fCheckBoxTools:=TCheckBox.Create(fGridPanelLayout);
 fCheckBoxTools.Parent:=fGridPanelLayout;
 fCheckBoxTools.Align:=TAlignLayout.Client;
 fCheckBoxTools.Text:='Tools';
 fCheckBoxTools.OnChange:=OnCheckBoxToolsClick;
{$else}
 fCheckBoxTools:=TCheckBox.Create(fPanelButtons);
 fCheckBoxTools.Parent:=fPanelButtons;
 fCheckBoxTools.Width:=DIP(ButtonWidth);
 fCheckBoxTools.Height:=DIP(ButtonHeight);
{$ifdef fpc}
 fCheckBoxTools.BorderSpacing.Left:=DIP(4);
 fCheckBoxTools.BorderSpacing.Right:=DIP(4);
 fCheckBoxTools.BorderSpacing.Top:=DIP(4);
 fCheckBoxTools.BorderSpacing.Bottom:=DIP(4);
 fCheckBoxTools.AnchorSide[akLeft].Side:=asrLeft;
 fCheckBoxTools.AnchorSide[akLeft].Control:=fPanelButtons;
 fCheckBoxTools.AnchorSide[akRight].Side:=asrRight;
 fCheckBoxTools.AnchorSide[akRight].Control:=fPanelButtons;
 fCheckBoxTools.AnchorSide[akTop].Side:=asrBottom;
 fCheckBoxTools.AnchorSide[akTop].Control:=fButtonCopyLast;
 fCheckBoxTools.Anchors:=[akTop,akLeft,akRight];
{$else}
 fCheckBoxTools.Align:=TAlign.alTop;
{$endif}
 fCheckBoxTools.Caption:='Tools';
 fCheckBoxTools.OnClick:=OnCheckBoxToolsClick;
{$endif}
{$ifdef FMX}
 fCheckBoxTools.IsChecked:=fToolsEnabled;
{$else}
 fCheckBoxTools.Checked:=fToolsEnabled;
{$endif}

 // Input memo
{$ifdef FMX}
 fMemoInput:=TMemo.Create(fPanelInput);
 fMemoInput.Parent:=fPanelInput;
 fMemoInput.Align:=TAlignLayout.Client;
 fMemoInput.Margins.Left:=DIP(8);
 fMemoInput.Margins.Right:=DIP(8);
 fMemoInput.Margins.Top:=DIP(8);
 fMemoInput.Margins.Bottom:=DIP(8);
 fMemoInput.OnKeyDown:=OnMemoInputKeyDown;
 fMemoInput.OnChange:=OnMemoInputChange;
 fMemoInput.Font.Size:=12;
 fMemoInput.TextSettings.HorzAlign:=TTextAlign.Leading;
 fMemoInput.TextSettings.VertAlign:=TTextAlign.Leading;
 fMemoInput.TextSettings.WordWrap:=true;
//fMemoInput.TextSettings.Trimming:=TTextTrimming.None;
 fMemoInput.ShowScrollBars:=true;
 fMemoInput.TabStop:=true;
{$else}
 fMemoInput:=TMemo.Create(fPanelInput);
 fMemoInput.Parent:=fPanelInput;
{$ifdef fpc}
 fMemoInput.BorderSpacing.Left:=DIP(8);
 fMemoInput.BorderSpacing.Right:=DIP(8);
 fMemoInput.BorderSpacing.Top:=DIP(8);
 fMemoInput.BorderSpacing.Bottom:=DIP(8);
 fMemoInput.AnchorSide[akLeft].Side:=asrLeft;
 fMemoInput.AnchorSide[akLeft].Control:=fPanelInput;
 fMemoInput.AnchorSide[akTop].Side:=asrBottom;
 fMemoInput.AnchorSide[akTop].Control:=fComboBoxModel;
 fMemoInput.AnchorSide[akRight].Side:=asrLeft;
 fMemoInput.AnchorSide[akRight].Control:=fPanelButtons;
 fMemoInput.AnchorSide[akBottom].Side:=asrBottom;
 fMemoInput.AnchorSide[akBottom].Control:=fPanelInput;
 fMemoInput.Anchors:=[akLeft,akTop,akRight,akBottom];
{$else}
 fMemoInput.Align:=TAlign.alClient;
{$endif}
 fMemoInput.Constraints.MinHeight:=DIP(75);
 fMemoInput.Constraints.MaxHeight:=DIP(250);
 fMemoInput.ScrollBars:=ssVertical;
 fMemoInput.WantTabs:=true;
 fMemoInput.WantReturns:=true;
 fMemoInput.WordWrap:=true;
 fMemoInput.OnKeyDown:=OnMemoInputKeyDown;
 fMemoInput.OnChange:=OnMemoInputChange;
 fMemoInput.Font.Size:=12;
{$endif} 

 // Create output processing timer
 fTimerOutput:=TTimer.Create(fPanelInput);
 fTimerOutput.Interval:=50; // 20 FPS
 fTimerOutput.OnTimer:=OnTimerOutput;
 fTimerOutput.Enabled:=false;

{$if defined(fpc) or defined(fmx)}
 // Populate combo box with scanned models
 PopulateModelCombo;
{$ifend}

//OnMemoInputChange(nil); // initialize memo height once

end;

procedure TPasLLMChatControl.SetupMessageArea;
begin
{$ifdef FMX}
 fMessageArea:=TChatMessageAreaControl.Create(self,self);
 fMessageArea.Parent:=self;
 fMessageArea.Align:=TAlignLayout.Client;
 fMessageArea.Opacity:=1.0;
 fMessageArea.Visible:=true;
 fMessageArea.Margins.Left:=DIP(8);
 fMessageArea.Margins.Right:=DIP(8);
 fMessageArea.Margins.Top:=DIP(8);
 fMessageArea.Margins.Bottom:=DIP(8);
{fMessageArea.Left:=20;
 fMessageArea.Top:=20;
 fMessageArea.Width:=400;
 fMessageArea.Height:=400;
 fMessageArea.Visible:=true;}
 fMessageArea.SendToBack;
{$else}
{$ifndef fpc}
 fPanelChat:=TPanel.Create(self);
 fPanelChat.Parent:=self;
 fPanelChat.Align:=TAlign.alClient;
 fMessageArea:=TChatMessageAreaControl.Create(fPanelChat,self);
 fMessageArea.Parent:=fPanelChat;
{$else}
 fMessageArea:=TChatMessageAreaControl.Create(self,self);
 fMessageArea.Parent:=self;
{$endif}
{$ifdef fpc}
 fMessageArea.BorderSpacing.Left:=DIP(8);
 fMessageArea.BorderSpacing.Right:=DIP(8);
 fMessageArea.BorderSpacing.Top:=DIP(8);
 fMessageArea.BorderSpacing.Bottom:=DIP(8);
 fMessageArea.AnchorSide[akLeft].Side:=asrLeft;
 fMessageArea.AnchorSide[akLeft].Control:=self;
 fMessageArea.AnchorSide[akTop].Side:=asrTop;
 fMessageArea.AnchorSide[akTop].Control:=self;
 fMessageArea.AnchorSide[akRight].Side:=asrRight;
 fMessageArea.AnchorSide[akRight].Control:=self;
 fMessageArea.AnchorSide[akBottom].Side:=asrTop;
 fMessageArea.AnchorSide[akBottom].Control:=fPanelInput;
 fMessageArea.Anchors:=[akLeft,akTop,akRight,akBottom];
{$else}
 fMessageArea.Align:=TAlign.alClient;
{$endif}
 fMessageArea.SendToBack; // Make sure input panel stays on top
{$endif}
end;

(*
function TPasLLMChatControl.EstimateMemoContentHeightPx:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
var Index,VisualLineCount:TPasLLMInt32;
    WrapWidth,LineHeight,PixelWidth:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif};
    Line:TPasLLMUTF8String;
begin
 // Estimate visual line count using current memo width and font
 Canvas.Font.Assign(fMemoInput.Font);

 // Available text width inside the memo (subtract a small padding)
 WrapWidth:=Max(1,{$ifdef FMX}fMemoInput.Width{$else}fMemoInput.ClientWidth{$endif}-DIP(8));
 LineHeight:=Canvas.TextHeight('Ag');
 VisualLineCount:=0;

 if fMemoInput.Lines.Count=0 then begin
  VisualLineCount:=1; // at least one visual line when empty
 end else begin
  for Index:=0 to fMemoInput.Lines.Count-1 do begin
   Line:=fMemoInput.Lines[Index];
   PixelWidth:=Canvas.TextWidth(Line);
   // Number of wrapped lines for this logical line
{$ifdef FMX}
   inc(VisualLineCount,Ceil(Max(1,(PixelWidth+WrapWidth)-1)/WrapWidth));
{$else}
   inc(VisualLineCount,Max(1,((PixelWidth+WrapWidth)-1) div WrapWidth));
{$endif}
  end;
 end;

 // Height in pixels + small vertical padding
 result:=(VisualLineCount*LineHeight)+DIP(4);
end;
*)

procedure TPasLLMChatControl.OnMemoInputChange(aSender:TObject);
//var NeededPixels,LimitPixels,MinPixels:Integer;
begin

{if assigned(Parent) and HandleAllocated and assigned(fMemoInput) and fMemoInput.HandleAllocated then begin

  // Compute desired memo height (pixels) based on content
  NeededPixels:=EstimateMemoContentHeightPx;

  // Clamp: keep a minimum height and cap at MaxInputHeight (DIP -> pixels)
  MinPixels:=DIP(60);
  LimitPixels:=DIP(fMaxInputHeight);

  if NeededPixels<MinPixels then begin
   NeededPixels:=MinPixels;
  end else if NeededPixels>LimitPixels then begin
   NeededPixels:=LimitPixels;
  end;

  // Apply; anchors keep the right-side button column aligned
  if fMemoInput.Height<>NeededPixels then begin
   fMemoInput.Height:=NeededPixels;
  end;

 end; }

end;

procedure TPasLLMChatControl.ScanForModels;
var Index,Count:TPasLLMInt32;
    SearchRec:TSearchRec;
    ModelFileName:TPasLLMUTF8String;
    Model:PModel;
    TemporaryModel:TModel;
begin
 fModels:=nil;
 Count:=0;
 if FindFirst(fModelDirectory+'*.safetensors',faAnyFile,SearchRec)=0 then begin
  try
   repeat
    ModelFileName:=SearchRec.Name;
    if length(fModels)<=Count then begin
     SetLength(fModels,(Count+1)+((Count+2) shr 1)); // Increase size by 50% to avoid frequent reallocations
    end;
    Model:=@fModels[Count];
    Model^.FileName:=ModelFileName;
    inc(Count);
   until FindNext(SearchRec)<>0;
   FindClose(SearchRec);
  finally
   // Ensure the array is exactly the right size
   SetLength(fModels,Count);
  end;
 end;

 // Sort the models by file name
 if Count>1 then begin
  Index:=0;
  while (Index+1)<Count do begin
   if fModels[Index].FileName>fModels[Index+1].FileName then begin
    // Swap the models
    TemporaryModel:=fModels[Index];
    fModels[Index]:=fModels[Index+1];
    fModels[Index+1]:=TemporaryModel;
    if Index>0 then begin
     dec(Index);
    end else begin
     inc(Index);
    end;
   end else begin
    inc(Index);
   end;
  end;
 end;
end;

procedure TPasLLMChatControl.PopulateModelCombo;
var Index:TPasLLMInt32;
    ModelFileName:TPasLLMUTF8String;
    Models:TPasLLMModels;
begin
 fComboBoxModel.Items.BeginUpdate;
 try
  fComboBoxModel.Clear;

  // First try OnRequestModelList event if assigned
  if assigned(fOnRequestModelList) then begin
   Models:=nil;
   fOnRequestModelList(Self,Models);
   if length(Models)>0 then begin
    for Index:=0 to length(Models)-1 do begin
     if length(Models[Index])>0 then begin
      fComboBoxModel.Items.Add(Models[Index]);
     end;
    end;
   end;
  end;

  // If no models from event, scan for local models
  if fComboBoxModel.Items.Count=0 then begin
   ScanForModels;
   for Index:=0 to length(fModels)-1 do begin
    ModelFileName:=fModels[Index].FileName;
    if length(ModelFileName)>0 then begin
     fComboBoxModel.Items.Add(ModelFileName);
    end;
   end;
  end;
 finally
  fComboBoxModel.Items.EndUpdate;
 end;

 // Select first model if available
 if fComboBoxModel.Items.Count>0 then begin
  fComboBoxModel.ItemIndex:=0;
  fSelectedModel:=fComboBoxModel.Items[0];
 end;
end;

{$ifndef FMX}
procedure TPasLLMChatControl.CreateWnd;
begin
 inherited CreateWnd;
{$ifdef fpc}
 fPPI:=GetCurrentPPI;
 if assigned(fPanelInput) and not fPanelInput.HandleAllocated then begin
  fPanelInput.HandleNeeded;
 end;
 if assigned(fMemoInput) and not fMemoInput.HandleAllocated then begin
  fMemoInput.HandleNeeded;
 end;
 if assigned(fMemoInput) then begin
  OnMemoInputChange(fMemoInput);
 end;
 CalculateLayout;
 Invalidate;
{$endif}
end;
{$endif}

{$ifdef fpc}
procedure TPasLLMChatControl.DoAutoAdjustLayout(const aMode:TLayoutAdjustmentPolicy;const aNewPPI,aOldPPI:Integer);
begin
 inherited DoAutoAdjustLayout(aMode,aNewPPI,aOldPPI);
 if (aOldPPI<>0) and (aNewPPI<>aOldPPI) then begin
  fPPI:=aNewPPI;
  CalculateLayout;
  Invalidate;
 end;
end;
{$else}
{$ifndef FMX}
{$ifdef fpc}
procedure TControlChat.ChangeScale(aM,aD:Integer;aIsDpiChange:Boolean);
begin
 inherited ChangeScale(aM,aD,aIsDpiChange);
 if aIsDpiChange and (aD<>0) then begin
  fPPI:=(fPPI*aM) div aD;
  CalculateLayout;
  Invalidate;
 end;
end;
{$endif}
{$endif}
{$endif}

procedure TPasLLMChatControl.Resize;
begin
 inherited Resize;
 if (fOldWidth<>Width) or (fOldHeight<>Height) then begin
  fOldWidth:=Width;
  fOldHeight:=Height;
  CalculateLayout;
{$ifdef FMX}
  InvalidateRect(GetLocalRect);
{$else}
  if assigned(fMessageArea) then begin
   fMessageArea.Invalidate;
  end;
{$endif}
 end;
end;

procedure TPasLLMChatControl.CalculateLayout;
begin
 if assigned(fMessageArea) then begin
  fMessageArea.CalculateLayout;
 end;
end;

procedure TPasLLMChatControl.ScrollTo(const aY:{$ifdef FMX}TMarkDownRendererFloat{$else}TMarkDownRendererInt32{$endif});
begin
 if assigned(fMessageArea) then begin
  fMessageArea.ScrollTo(aY);
 end;
end;

procedure TPasLLMChatControl.ScrollToBottom;
begin
 if assigned(fMessageArea) then begin
  fMessageArea.ScrollToBottom;
 end;
end;

procedure TPasLLMChatControl.AutoScrollToBottom;
begin
 if assigned(fMessageArea) then begin
  fMessageArea.AutoScrollToBottom;
 end;
end;

procedure TPasLLMChatControl.EnsureVisible(const aRect:{$ifdef FMX}TRectF{$else}TRect{$endif});
begin
 if assigned(fMessageArea) then begin
  fMessageArea.EnsureVisible(aRect);
 end;
end;

procedure TPasLLMChatControl.QueueRepaint;
var CurrentTime:TPasLLMUInt64;
begin

 CurrentTime:=GetTickCount64;

 // Throttle repaints to ~60 FPS
 if (CurrentTime-fLastRepaintTime)>=16 then begin
  fLastRepaintTime:=CurrentTime;
{$ifdef FMX}
  InvalidateRect(GetLocalRect);
{$else}
  fMessageArea.Invalidate;
{$endif}
 end else if not fRepaintPending then begin
  fRepaintPending:=true;
{$ifndef FMX}
  PostMessage(Handle,TPasLLMChatControl.WM_THROTTLED_REPAINT,0,0);
{$endif}
 end;

end;

{$ifndef FMX}
procedure TPasLLMChatControl.ProcessThrottledRepaint(var aMessage:{$ifdef fpc}TLMessage{$else}TMessage{$endif});
begin
 fRepaintPending:=false;
 fLastRepaintTime:=GetTickCount64;
 fMessageArea.Invalidate;
end;
{$endif}

function TPasLLMChatControl.WaitForActionDoneEvent(const aTimeOut:TPasLLMUInt32):TWaitResult;
var StartTime:TPasLLMUInt64;
    ElapsedTime:TPasLLMUInt64;
begin

 result:=wrTimeout;
 
 if assigned(fChatThread) and assigned(fChatThread.fActionDoneEvent) then begin

  StartTime:=GetTickCount64;

  repeat

   // Check if event is signaled
   if fChatThread.fActionDoneEvent.WaitFor(10)=wrSignaled then begin
    result:=wrSignaled;
    exit;
   end;

   // Check timeout
   ElapsedTime:=GetTickCount64-StartTime;
   if ElapsedTime>=aTimeOut then begin
    result:=wrTimeout;
    exit;
   end;

   // Process messages to keep UI responsive
{$ifdef FMX}
   Application.ProcessMessages;
{$else}
   Application.ProcessMessages;
{$endif}

  until false;

 end else begin

  result:=wrError;

 end;

end;

// Input event handlers

procedure TPasLLMChatControl.OnComboModelChangeClear;
begin

 Clear;

 fSelectedModel:=fComboBoxModel.Items[fComboBoxModel.ItemIndex];

 // Notify thread about model change
 fChatThread.fActionDoneEvent.ResetEvent;
 fChatThread.fModel:=fComboBoxModel.ItemIndex;
 TPasMPInterlocked.Write(fChatThread.fAction,TChatThread.ActionNewModel);
 fChatThread.fInputQueue.Enqueue(#0);
 fChatThread.fEvent.SetEvent;

 if WaitForActionDoneEvent(300000)=wrSignaled then begin

  if Assigned(fOnModelChanged) then begin
   fOnModelChanged(Self,fSelectedModel);
  end;

 end;

end;

procedure TPasLLMChatControl.OnComboModelChange(aSender:TObject);
begin

 if assigned(fChatThread) then begin

  if fComboBoxModel.ItemIndex>=0 then begin

   if fChatThread.fModel<>fComboBoxModel.ItemIndex then begin
{$ifdef FMX}
    if fMessages.Count>0 then begin
     MessageDlg('Are you to sure to change the model? It will clear the session!',
                TMsgDlgType.mtConfirmation,
                [TMsgDlgBtn.mbYes,TMsgDlgBtn.mbNo],
                0,
                procedure(const aResult:TModalResult)
                begin
                 if aResult=mrYes then begin
                  OnComboModelChangeClear;
                 end;
                end
               );
     exit;
    end;
{$else}
    if (fMessages.Count>0) and
{$ifdef fpc}
       (MessageDlg('Sure?',
                   'Are you to sure to change the model? It will clear the session!',
                   TMsgDlgType.mtConfirmation,
                   [TMsgDlgBtn.mbYes,TMsgDlgBtn.mbNo],
                   -1,
                   TMsgDlgBtn.mbNo)=mrNo)
{$else}
       (MessageDlg('Are you to sure to change the model? It will clear the session!',
                   TMsgDlgType.mtConfirmation,
                   [TMsgDlgBtn.mbYes,TMsgDlgBtn.mbNo],
                   -1,
                   TMsgDlgBtn.mbNo)=mrNo)
{$endif}
                   then begin
     fComboBoxModel.ItemIndex:=fChatThread.fModel;
     exit;
    end;
{$endif}

    OnComboModelChangeClear;

   end;

  end;

 end;

end;

procedure TPasLLMChatControl.OnMemoInputKeyDown(aSender:TObject;var aKey:Word;{$ifdef FMX}var aKeyChar:WideChar;{$endif}aShift:TShiftState);
begin

 case aKey of

  {$ifdef FMX}vkReturn{$else}VK_RETURN{$endif}:begin
   if aShift=[] then begin
    // Enter = Send
    OnButtonSendClick(nil);
    aKey:=0;
{$ifdef FMX}
    aKeyChar:=#0;
{$endif}
   end;
   // Shift+Enter = newline (default behavior)
  end;

  {$ifdef FMX}vkEscape{$else}VK_ESCAPE{$endif}:begin
   // Esc = Stop
   if fIsWorking then begin
    OnButtonStopClick(nil);
   end;
   aKey:=0;
{$ifdef FMX}
   aKeyChar:=#0;
{$endif}
  end;

  {$ifdef FMX}vkUp{$else}VK_UP{$endif}:begin
   if (aShift=[]) and (fPromptHistoryCount>0) then begin
    if fHistoryIndex<fPromptHistoryCount-1 then begin
     inc(fHistoryIndex);
     fMemoInput.Text:=fPromptHistory[fPromptHistoryCount-1-fHistoryIndex];
    end;
    aKey:=0;
{$ifdef FMX}
    aKeyChar:=#0;
{$endif}
   end;
  end;

  {$ifdef FMX}vkDown{$else}VK_DOWN{$endif}:begin
   if (aShift=[]) and (fHistoryIndex>=0) then begin
    dec(fHistoryIndex);
    if fHistoryIndex>=0 then begin
     fMemoInput.Text:=fPromptHistory[fPromptHistoryCount-1-fHistoryIndex];
    end else begin
     fMemoInput.Text:='';
    end;
    aKey:=0;
{$ifdef FMX}
    aKeyChar:=#0;
{$endif}
   end;
  end;

  {$ifdef FMX}vkA{$else}Ord('A'){$endif}:begin
   if (aShift*[ssCtrl,ssAlt,ssShift])=[ssCtrl] then begin
    // Ctrl+A = Select All
    fMemoInput.SelectAll;
    aKey:=0;
{$ifdef FMX}
    aKeyChar:=#0;
{$endif}
   end;
  end;

  {$ifdef FMX}vkC{$else}Ord('C'){$endif}:begin
   if (aShift*[ssCtrl,ssAlt,ssShift])=[ssCtrl] then begin
    // Ctrl+C = Copy
    fMemoInput.CopyToClipboard;
    aKey:=0;
{$ifdef FMX}
    aKeyChar:=#0;
{$endif}
   end;
  end;

  {$ifdef FMX}vkAdd{$else}VK_ADD,VK_OEM_PLUS,Ord('+'),Ord('='){$endif}:begin
   if (aShift*[ssCtrl,ssAlt,ssShift])=[ssCtrl] then begin
    fMemoInput.Font.Size:=Max(1,fMemoInput.Font.Size+1);
{$ifndef FMX}
    fMemoInput.Invalidate;
{$endif}
    aKey:=0;
{$ifdef FMX}
    aKeyChar:=#0;
{$endif}
   end;
  end;

  {$ifdef FMX}vkSubtract{$else}VK_SUBTRACT,VK_OEM_MINUS,Ord('-'){$endif}:begin
   if (aShift*[ssCtrl,ssAlt,ssShift])=[ssCtrl] then begin
    fMemoInput.Font.Size:=Max(1,fMemoInput.Font.Size-1);
{$ifndef FMX}
    fMemoInput.Invalidate;
{$endif}
    aKey:=0;
   end;
  end;

  {$ifdef FMX}vkNumpad0,vk0{$else}VK_NUMPAD0,Ord('0'){$endif}:begin
   if (aShift*[ssCtrl,ssAlt,ssShift])=[ssCtrl] then begin
    fMemoInput.Font.Size:=12;
{$ifndef FMX}
    fMemoInput.Invalidate;
{$endif}
    aKey:=0;
{$ifdef FMX}
    aKeyChar:=#0;
{$endif}
   end;
  end;

  else begin
  end;

 end;

end;

procedure TPasLLMChatControl.OnButtonSendClick(aSender:TObject);
var Prompt:TPasLLMUTF8String;
begin

 if fIsWorking then begin
  exit;
 end;

 if not assigned(fSession) then begin
  NewChatSession;
 end;

{$ifdef FMX}
 Prompt:=UTF8Encode(Trim(fMemoInput.Text));
{$else}
 Prompt:=Trim(fMemoInput.Text);
{$endif}
 if Length(Prompt)=0 then begin
  exit;
 end;

 // Add to history
 AddToPromptHistory(Prompt);
 fHistoryIndex:=-1;

 // Update working state
 fIsWorking:=true;

 // Add user message
 AddMessage(TChatRole.User,Prompt,true);

 // Clear input
 fMemoInput.Text:='';

 // Fire event
 if assigned(fOnSendPrompt) then begin
  fOnSendPrompt(Self,Prompt);
 end;

 // Send input to thread
 if assigned(fChatThread) then begin
  fChatThread.fInputQueue.Enqueue(Prompt);
  fChatThread.fEvent.SetEvent;
 end;

 // Start assistant response
 fCurrentStreamingIndex:=AddMessage(TChatRole.Assistant,'');
 if (fCurrentStreamingIndex>=0) and (fCurrentStreamingIndex<fMessages.Count) then begin
  fMessages[fCurrentStreamingIndex].fStreaming:=true;
  fTypingStartTime:=GetTickCount64;
  fLastTypingAnimationPhase:=-1;
 end;

 // Update input state
 fTypingStartTime:=GetTickCount64;
 fLastTypingAnimationPhase:=-1;
 fIsWorking:=true;
 UpdateInputState;

 CalculateLayout;
 AutoScrollToBottom;

end;

procedure TPasLLMChatControl.OnButtonStopClick(aSender:TObject);
begin
 if assigned(fChatThread) and fIsWorking then begin
  TPasMPInterlocked.CompareExchange(fChatThread.fAction,TChatThread.ActionAborted,TChatThread.ActionNone);
 end;
end;

procedure TPasLLMChatControl.OnButtonClearClick(aSender:TObject);
begin
 NewSession;
end;

procedure TPasLLMChatControl.OnButtonCopyLastClick(aSender:TObject);
begin
 CopyLastAssistantMessage;
end;

procedure TPasLLMChatControl.OnCheckBoxToolsClick(aSender:TObject);
begin
{$ifdef FMX}
 if fToolsEnabled<>fCheckBoxTools.IsChecked then begin
  fToolsEnabled:=fCheckBoxTools.IsChecked;
  if assigned(fChatThread) and assigned(fChatThread.fChatSession) then begin
   fChatThread.fChatSession.ToolsEnabled:=fToolsEnabled;
   if assigned(fChatThread) and fIsWorking then begin
    TPasMPInterlocked.CompareExchange(fChatThread.fAction,TChatThread.ActionAborted,TChatThread.ActionToolsChanged);
   end;
  end;
 end;
{$else}
 if fToolsEnabled<>fCheckBoxTools.Checked then begin
  fToolsEnabled:=fCheckBoxTools.Checked;
  if assigned(fChatThread) and assigned(fChatThread.fChatSession) then begin
   fChatThread.fChatSession.ToolsEnabled:=fToolsEnabled;
   if assigned(fChatThread) and fIsWorking then begin
    TPasMPInterlocked.CompareExchange(fChatThread.fAction,TChatThread.ActionAborted,TChatThread.ActionToolsChanged);
   end;
  end;
 end;
{$endif}
end;

procedure TPasLLMChatControl.OnTimerOutput(aSender:TObject);
begin
 Process;
 UpdateInputState;
 if fLastTypingAnimationPhase<>GetTypingAnimationPhase then begin
  QueueRepaint;
 end;
end;

procedure TPasLLMChatControl.UpdateInputState;
var s:String;
begin
 fButtonSend.Enabled:=not fIsWorking;
 fButtonStop.Enabled:=fIsWorking;
 fComboBoxModel.Enabled:=not fIsWorking;
 fMemoInput.Enabled:=not fIsWorking;

{$ifdef FMX}
 if fIsWorking then begin
  //fButtonSend.Text:='&Stop';
  if assigned(fStatusBar) then begin
{  fStatusBar.Panels[0].Text:='Working...';
   str(fSession.GetPromptTokensPerSecond:7:5,s);
   fStatusBar.Panels[1].Text:=s+' prompt tokens/second';
   str(fSession.GetOutputTokensPerSecond:7:5,s);
   fStatusBar.Panels[2].Text:=s+' output tokens/second';
   str(fSession.GetTokensPerSecond:7:5,s);
   fStatusBar.Panels[3].Text:=s+' total tokens/second';}
  end;
  if assigned(fStatusBarLabel1) then begin
   fStatusBarLabel1.Text:='Working...';
  end;
  if assigned(fStatusBarLabel2) then begin
   str(fSession.GetPromptTokensPerSecond:7:5,s);
   fStatusBarLabel2.Text:=s+' prompt tokens/second';
  end;
  if assigned(fStatusBarLabel3) then begin
   str(fSession.GetOutputTokensPerSecond:7:5,s);
   fStatusBarLabel3.Text:=s+' output tokens/second';
  end;
  if assigned(fStatusBarLabel4) then begin
   str(fSession.GetTokensPerSecond:7:5,s);
   fStatusBarLabel4.Text:=s+' total tokens/second';
  end;
  fTimerOutput.Enabled:=true;
 end else begin
  //fButtonSend.Text:='&Send';
  if assigned(fStatusBar) then begin
{  fStatusBar.Panels[0].Text:='Ready';
   str(fSession.GetPromptTokensPerSecond:7:5,s);
   fStatusBar.Panels[1].Text:=s+' prompt tokens/second';
   str(fSession.GetOutputTokensPerSecond:7:5,s);
   fStatusBar.Panels[2].Text:=s+' output tokens/second';
   str(fSession.GetTokensPerSecond:7:5,s);
   fStatusBar.Panels[3].Text:=s+' total tokens/second';}
  end;
  if assigned(fStatusBarLabel1) then begin
   fStatusBarLabel1.Text:='Ready';
  end;
  if assigned(fStatusBarLabel2) then begin
   str(fSession.GetPromptTokensPerSecond:7:5,s);
   fStatusBarLabel2.Text:=s+' prompt tokens/second';
  end;
  if assigned(fStatusBarLabel3) then begin
   str(fSession.GetOutputTokensPerSecond:7:5,s);
   fStatusBarLabel3.Text:=s+' output tokens/second';
  end;
  if assigned(fStatusBarLabel4) then begin
   str(fSession.GetTokensPerSecond:7:5,s);
   fStatusBarLabel4.Text:=s+' total tokens/second';
  end;
  fTimerOutput.Enabled:=false;
 end; 
{$else}
 if fIsWorking then begin
  fButtonSend.Caption:='&Stop';
  if assigned(fStatusBar) then begin
   fStatusBar.Panels[0].Text:='Working...';
   str(fSession.GetPromptTokensPerSecond:7:5,s);
   fStatusBar.Panels[1].Text:=s+' prompt tokens/second';
   str(fSession.GetOutputTokensPerSecond:7:5,s);
   fStatusBar.Panels[2].Text:=s+' output tokens/second';
   str(fSession.GetTokensPerSecond:7:5,s);
   fStatusBar.Panels[3].Text:=s+' total tokens/second';
  end;
  fTimerOutput.Enabled:=true;
 end else begin
  fButtonSend.Caption:='&Send';
  if assigned(fStatusBar) then begin
   fStatusBar.Panels[0].Text:='Ready';
   str(fSession.GetPromptTokensPerSecond:7:5,s);
   fStatusBar.Panels[1].Text:=s+' prompt tokens/second';
   str(fSession.GetOutputTokensPerSecond:7:5,s);
   fStatusBar.Panels[2].Text:=s+' output tokens/second';
   str(fSession.GetTokensPerSecond:7:5,s);
   fStatusBar.Panels[3].Text:=s+' total tokens/second';
  end;
  fTimerOutput.Enabled:=false;
 end;
{$endif}

end;

procedure TPasLLMChatControl.ClearLinkHoverState;
var Index:TPasLLMInt32;
    Message:TChatMessage;
begin
 // Clear hover state for all messages
 for Index:=0 to fMessages.Count-1 do begin
  Message:=fMessages[Index];
  if length(Message.fHoveredURL)>0 then begin
   // Fire hover end event
   if assigned(fOnLinkHover) then begin
    fOnLinkHover(Self,Message.fHoveredURL,false);
   end;
   Message.fHoveredURL:='';
  end;
 end;
 
 // Reset cursor and tracking state
 if fCursorOverLink then begin
  if assigned(fMessageArea) then begin
   fMessageArea.Cursor:=crDefault;// fOriginalCursor;
   fMessageArea.Hint:='';
   fMessageArea.ShowHint:=false;
  end;
  fCursorOverLink:=false;
  fCurrentHoveredURL:='';
 end;
end;

// Threading support

procedure TPasLLMChatControl.StartChatThread;
begin
 if not assigned(fChatThread) then begin
  fChatThread:=TChatThread.Create(Self);
 end;
end;

procedure TPasLLMChatControl.StopChatThread;
begin
 if assigned(fChatThread) then begin
  try
   fChatThread.fChatControl:=nil;
   fChatThread.fActionDoneEvent.ResetEvent;
   TPasMPInterlocked.Write(fChatThread.fAction,TChatThread.ActionTerminated);
   fChatThread.Terminate;
   fChatThread.fInputQueue.Enqueue(#0);
   fChatThread.fEvent.SetEvent;
   fChatThread.WaitFor;
  finally
   FreeAndNil(fChatThread);
  end;
 end;
end;

procedure TPasLLMChatControl.Process;
var Output:TPasLLMUTF8String;
    OK,ToQueueRepaint:Boolean;
begin
 ToQueueRepaint:=false;
 if assigned(self) and assigned(fChatThread) and not fChatThread.Terminated then begin

  Output:='';
  repeat
   fChatThread.fOutputQueueLock.Acquire;
   try
    OK:=fChatThread.fOutputQueue.Dequeue(Output);
   finally
    fChatThread.fOutputQueueLock.Release;
   end;
   if OK and (length(Output)>0) then begin
    if fCurrentStreamingIndex>=0 then begin
     Append(fCurrentStreamingIndex,Output);
     ToQueueRepaint:=true;
    end;
   end;
  until not OK;
  if ToQueueRepaint then begin
   QueueRepaint;
  end;

  fIsWorking:=fProcessing or (assigned(fChatThread.fChatSession) and ((fChatThread.fChatSession.State<>TPasLLMModelInferenceInstance.TChatSession.TState.Initial) and
                                                                      (fChatThread.fChatSession.State<>TPasLLMModelInferenceInstance.TChatSession.TState.SystemPromptInput) and
                                                                      (fChatThread.fChatSession.State<>TPasLLMModelInferenceInstance.TChatSession.TState.UserInput)));

  UpdateInputState;

 end;
end;

// Session event handlers

procedure TPasLLMChatControl.SessionOnMessage(const aSender:TPasLLMModelInferenceInstance.TChatSession;const aMessage:TPasLLMModelInferenceInstance.TChatSession.TMessage);
var Role:TChatRole;
    MessageIndex:TPasLLMInt32;
begin

 Role:=StringToRole(aMessage.Role);
 MessageIndex:=AddMessage(Role,aMessage.Content);

 if Role=TChatRole.Assistant then begin
  fCurrentStreamingIndex:=MessageIndex;
  fMessages[MessageIndex].fStreaming:=true;
  fTypingStartTime:=GetTickCount64;
  fLastTypingAnimationPhase:=-1;
 end;

 CalculateLayout;
 AutoScrollToBottom;
end;

procedure TPasLLMChatControl.SessionOnStateChange(const aSender:TPasLLMModelInferenceInstance.TChatSession;const aOldState,aNewState:TPasLLMModelInferenceInstance.TChatSession.TState);
begin
 case aNewState of
  TPasLLMModelInferenceInstance.TChatSession.TState.GeneratingAssistantAnswer:begin
   fIsWorking:=true;
  end;

  TPasLLMModelInferenceInstance.TChatSession.TState.UserInput,
  TPasLLMModelInferenceInstance.TChatSession.TState.Terminated:begin
   if fCurrentStreamingIndex>=0 then begin
    EndStream(fCurrentStreamingIndex);
   end;
   fIsWorking:=false;
   fCurrentStreamingIndex:=-1;
  end;
 end;

 Process;

end;

procedure TPasLLMChatControl.SessionOnTokenGenerated(const aSender:TPasLLMModelInferenceInstance.TChatSession;const aToken:TPasLLMUTF8String);
begin
 // Use message posting instead of TThread.Queue
 if fCurrentStreamingIndex>=0 then begin
  Append(fCurrentStreamingIndex,aToken);
  QueueRepaint; // Throttled repaint
 end;
end;

function TPasLLMChatControl.SessionOnGetModelInfo(const aSender:TPasLLMModelInferenceInstance.TChatSession):TPasLLMUTF8String;
begin
 // Return the filename of the currently active model based on model index
 if assigned(fChatThread) and (fChatThread.fActiveModel>=0) and (fChatThread.fActiveModel<length(fModels)) then begin
  result:=fModels[fChatThread.fActiveModel].FileName;
 end else begin
  result:='';
 end;
end;

// Prompt history management

procedure TPasLLMChatControl.AddToPromptHistory(const aPrompt:TPasLLMUTF8String);
begin
 inc(fPromptHistoryCount);
if length(fPromptHistory)<fPromptHistoryCount then begin
  SetLength(fPromptHistory,fPromptHistoryCount*2);
 end;
 fPromptHistory[fPromptHistoryCount-1]:=aPrompt;
end;

procedure TPasLLMChatControl.ClearPromptHistory;
begin
 fPromptHistory:=nil;
 fPromptHistoryCount:=0;
 fHistoryIndex:=-1;
end;

// Property accessors

procedure TPasLLMChatControl.SetAutoScroll(const aValue:boolean);
begin
 if fAutoScroll<>aValue then begin
  fAutoScroll:=aValue;
  if fCurrentStreamingIndex>=0 then begin
   AutoScrollToBottom;
  end;
 end;
end;

procedure TPasLLMChatControl.SetSession(const aValue:TPasLLMModelInferenceInstance.TChatSession);
begin

 if fSession<>aValue then begin

  fSession:=aValue;

  // Setup model info callbacks when session is assigned
  if assigned(fSession) then begin
   fSession.OnGetModelInfo:=SessionOnGetModelInfo;
  end;

  // Restart thread when session changes
  StopChatThread;
  if assigned(fSession) then begin
   StartChatThread;
  end;

 end;

end;

procedure TPasLLMChatControl.SetSelectedModel(const aValue:TPasLLMUTF8String);
var Index:TPasLLMInt32;
begin
 if fSelectedModel<>aValue then begin
  fSelectedModel:=aValue;

  // Update combo box
  Index:=fComboBoxModel.Items.IndexOf(aValue);
  if Index>=0 then begin
   fComboBoxModel.ItemIndex:=Index;
  end;
 end;
end;

// Public API

procedure TPasLLMChatControl.Clear;
begin
 fMessages.Clear;
 fCurrentStreamingIndex:=-1;
 fIsWorking:=false;
 if assigned(fMessageArea) then begin
  fMessageArea.Clear;
 end;
 Process;
{$ifdef FMX}
 InvalidateRect(GetLocalRect);
{$else}
 if assigned(fMessageArea) then begin
  fMessageArea.Invalidate;
 end;
{$endif}
end;

procedure TPasLLMChatControl.NewSession;
begin
 if assigned(fChatThread) then begin
  fChatThread.fActionDoneEvent.ResetEvent;
  TPasMPInterlocked.Write(fChatThread.fAction,TChatThread.ActionNewSession);
  fChatThread.fInputQueue.Enqueue(#0);
  fChatThread.fEvent.SetEvent;
  WaitForActionDoneEvent(300000);
 end;
 Clear;
end;

function TPasLLMChatControl.AddMessage(const aRole:TChatRole;const aText:TPasLLMUTF8String;const aScrollToBottom:Boolean):TPasLLMInt32;
var Message:TChatMessage;
begin
 Message:=TChatMessage.Create(self,aRole,aText);
 result:=fMessages.Add(Message);
 CalculateLayout;

 // Force scroll to bottom if requested and it's a user message
 if aScrollToBottom and (aRole=TChatRole.User) then begin
  ScrollToBottom;
 end;

 // Auto-save on every message change
 AutoSaveCurrentSession;
end;

procedure TPasLLMChatControl.Append(const aIndex:TPasLLMInt32;const aDelta:TPasLLMUTF8String);
begin
 if (aIndex>=0) and (aIndex<fMessages.Count) then begin
  fMessages[aIndex].fText:=fMessages[aIndex].fText+aDelta;
  fMessages[aIndex].fNewText:=true;
  CalculateLayout;
  AutoScrollToBottom;
  // No auto-save here to avoid I/O spamming during streaming
 end;
end;

procedure TPasLLMChatControl.EndStream(const aIndex:TPasLLMInt32);
begin
 if (aIndex>=0) and (aIndex<fMessages.Count) then begin
  fMessages[aIndex].fStreaming:=false;
  if aIndex=fCurrentStreamingIndex then begin
   fCurrentStreamingIndex:=-1;
  end;
  CalculateLayout;
{$ifdef FMX}
  InvalidateRect(GetLocalRect);
{$else}
  if assigned(fMessageArea) then begin
   fMessageArea.Invalidate;
  end;
{$endif}

  // Auto-save when streaming ends (complete message)
  AutoSaveCurrentSession;
 end;
end;

procedure TPasLLMChatControl.BindToSession(const aSession:TPasLLMModelInferenceInstance.TChatSession);
begin
 SetSession(aSession);
end;

procedure TPasLLMChatControl.SetSystemPrompt(const aPrompt:TPasLLMUTF8String);
begin
 if assigned(fSession) then begin
  fSession.SetSystemPrompt(aPrompt);
 end;
end;

procedure TPasLLMChatControl.SetModels(const aModels:TPasLLMModels;const aCount:TPasLLMInt32);
var Index:TPasLLMInt32;
begin
 fComboBoxModel.Items.Clear;
 for Index:=0 to aCount-1 do begin
  fComboBoxModel.Items.Add(aModels[Index]);
 end;
 if fComboBoxModel.Items.Count>0 then begin
  fComboBoxModel.ItemIndex:=0;
 end;
end;

procedure TPasLLMChatControl.CopyLastAssistantMessage;
{$ifdef FMX}
var Index:TPasLLMInt32;
    ClipBoard:IFMXClipboardService;
begin
 if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService,ClipBoard) then begin
  for Index:=fMessages.Count-1 downto 0 do begin
   if fMessages[Index].fRole=TChatRole.Assistant then begin
    Clipboard.SetClipboard(fMessages[Index].fText);
    break;
   end;
  end;
 end;
end;
{$else}
var Index:TPasLLMInt32;
begin
 for Index:=fMessages.Count-1 downto 0 do begin
  if fMessages[Index].fRole=TChatRole.Assistant then begin
   Clipboard.AsText:=fMessages[Index].fText;
   break;
  end;
 end;
end;
{$endif}

procedure TPasLLMChatControl.SelectAll;
var Index:TPasLLMInt32;
    AllText:TPasLLMUTF8String;
{$ifdef FMX}
    ClipBoard:IFMXClipboardService;
{$endif}
begin

 // Build all text from all messages
 AllText:='';
 for Index:=0 to fMessages.Count-1 do begin
  if Index>0 then begin
   AllText:=AllText+#13#10#13#10; // Double newline between messages
  end;
  AllText:=AllText+'['+RoleToString(fMessages[Index].fRole)+'] '+fMessages[Index].fText;
 end;

 // Set as selected text and copy to clipboard
 if Length(AllText)>0 then begin
{$ifdef FMX}
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService,ClipBoard) then begin
   Clipboard.SetClipboard(AllText);
  end;
{$else}
  Clipboard.AsText:=AllText;
{$endif}
 end;

 // Visual feedback - could add selection highlighting here
{$ifdef FMX}
 InvalidateRect(GetLocalRect);
{$else}
 if assigned(fMessageArea) then begin
  fMessageArea.Invalidate;
 end;
{$endif}
end;

procedure TPasLLMChatControl.SelectMessage(const aIndex:TPasLLMInt32);
begin
 if (aIndex>=0) and (aIndex<fMessages.Count) then begin
  fMessages[aIndex].fSelected:=true;
{$ifdef FMX}
  InvalidateRect(GetLocalRect);
{$else}
 if assigned(fMessageArea) then begin
  fMessageArea.Invalidate;
 end;
{$endif}
 end;
end;

procedure TPasLLMChatControl.UnselectMessage(const aIndex:TPasLLMInt32);
begin
 if (aIndex>=0) and (aIndex<fMessages.Count) then begin
  fMessages[aIndex].fSelected:=false;
{$ifdef FMX}
  InvalidateRect(GetLocalRect);
{$else}
 if assigned(fMessageArea) then begin
  fMessageArea.Invalidate;
 end;
{$endif}
 end;
end;

procedure TPasLLMChatControl.SelectAllMessages;
var Index:TPasLLMInt32;
begin
 for Index:=0 to fMessages.Count-1 do begin
  fMessages[Index].fSelected:=true;
 end;
{$ifdef FMX}
 InvalidateRect(GetLocalRect);
{$else}
 if assigned(fMessageArea) then begin
  fMessageArea.Invalidate;
 end;
{$endif}
end;

procedure TPasLLMChatControl.UnselectAllMessages;
var Index:TPasLLMInt32;
begin
 for Index:=0 to fMessages.Count-1 do begin
  fMessages[Index].fSelected:=false;
 end;
{$ifdef FMX}
 InvalidateRect(GetLocalRect);
{$else}
 if assigned(fMessageArea) then begin
  fMessageArea.Invalidate;
 end;
{$endif}
end;

procedure TPasLLMChatControl.SelectMarkedMessages;
begin
 if assigned(fMessageArea) then begin
  fMessageArea.SelectMarkedMessages;
 end;
end;

procedure TPasLLMChatControl.CopySelectedMessages;
var Index:TPasLLMInt32;
    ClipboardText:TPasLLMUTF8String;
{$ifdef FMX}
    ClipBoard:IFMXClipboardService;
{$endif}
begin

 ClipboardText:='';

 for Index:=0 to fMessages.Count-1 do begin

  if fMessages[Index].fSelected then begin

   // Add double newline between messages
   if length(ClipboardText)>0 then begin
    ClipboardText:=ClipboardText+#13#10#13#10;
   end;

   // Use same format as SelectAll: [Role] MessageText
   ClipboardText:=ClipboardText+'['+RoleToString(fMessages[Index].fRole)+'] '+fMessages[Index].fText;

  end;

 end;

 // Copy to clipboard if we have selected messages
 if ClipboardText<>'' then begin
{$ifdef FMX}
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService,ClipBoard) then begin
   Clipboard.SetClipboard(ClipboardText);
  end;
{$else}
  Clipboard.AsText:=ClipboardText;
{$endif}
 end;

end;

// Session management implementations

procedure TPasLLMChatControl.NewChatSession(const aTitle:TPasLLMUTF8String='');
var SessionTitle:TPasLLMUTF8String;
begin

 if aTitle<>'' then begin
  SessionTitle:=aTitle;
 end else begin
  SessionTitle:='Chat '+FormatDateTime('yyyy-mm-dd hh:nn:ss',Now);
 end;

 if assigned(fChatThread) then begin
  fChatThread.fActionDoneEvent.ResetEvent;
  TPasMPInterlocked.Write(fChatThread.fAction,TChatThread.ActionNewSession);
  fChatThread.fInputQueue.Enqueue(#0);
  fChatThread.fEvent.SetEvent;

  // Wait for action to complete
  if WaitForActionDoneEvent(300000)=wrSignaled then begin
  end;
 end;

 // Clear current session
 Clear;
 fCurrentSessionFileName:='';

 // Create new session if we have one assigned
 if assigned(fSession) then begin
  fSession.Reset;
  fSession.Title:=SessionTitle;
  fSession.TimeStamp:=Now;
  
  // Generate filename and save new session
  fCurrentSessionFileName:=GenerateSessionFileName(SessionTitle);
  SaveSessionAs(fCurrentSessionFileName);
  
  // Add to database
  if assigned(fSessionDatabase) then begin
   fSessionDatabase.AddEntry(SessionTitle,fCurrentSessionFileName,fSelectedModel,Now);
  end;

  Process;

 end;
end;

procedure TPasLLMChatControl.SaveCurrentSession;
begin
 if length(fCurrentSessionFileName)<>0 then begin
  SaveSessionAs(fCurrentSessionFileName);
 end else if assigned(fSession) and (length(fSession.Title)>0) then begin
  SaveSessionAs(GenerateSessionFileName(fSession.Title));
 end else begin
  SaveSessionAs(GenerateSessionFileName('Untitled Session'));
 end;
end;

procedure TPasLLMChatControl.SaveSessionAs(const aFileName:TPasLLMUTF8String);
var FullPath:TPasLLMUTF8String;
begin
 if assigned(fSession) then begin
  EnsureSessionsDirectory;
  FullPath:=IncludeTrailingPathDelimiter(fSessionsDirectory)+aFileName;

  try
   // Update session timestamp
   fSession.TimeStamp:=Now;

   // Use PasLLM's built-in file save API
   fSession.SaveToJSONFile(FullPath);

   // Add/update entry in session database
   if assigned(fSessionDatabase) then begin
    fSessionDatabase.AddEntry(fSession.Title,aFileName,fSelectedModel,fSession.TimeStamp);
   end;

   fCurrentSessionFileName:=aFileName;

  except
   on E:Exception do begin
    // Handle save error - could show message dialog here
    // For now, silently fail
   end;
  end;
 end;
end;

procedure TPasLLMChatControl.DeleteSession(const aFileName:TPasLLMUTF8String);
var FullPath:TPasLLMUTF8String;
begin
 FullPath:=IncludeTrailingPathDelimiter(fSessionsDirectory)+aFileName;
 if FileExists(FullPath) then begin
  try
   SysUtils.DeleteFile(FullPath);
   
   // Remove from session database
   if assigned(fSessionDatabase) then begin
    fSessionDatabase.DeleteEntry(aFileName);
   end;
  except
   // Silently handle delete errors
  end;
 end;
end;

function TPasLLMChatControl.GetSessionsList:TPasLLMModels;
var Index:TPasLLMInt32;
    Entry:TSessionDatabaseEntry;
begin
 SetLength(result,0);
 
 if assigned(fSessionDatabase) then begin
  SetLength(result,fSessionDatabase.GetCount);
  for Index:=0 to fSessionDatabase.GetCount-1 do begin
   Entry:=fSessionDatabase.GetEntry(Index);
   if assigned(Entry) then begin
    result[Index]:=Entry.FileName;
   end else begin
    result[Index]:='';
   end;
  end;
 end;
end;

function TPasLLMChatControl.GetSessionsDirectory:TPasLLMUTF8String;
begin
 if length(fStorageDirectory)>0 then begin
  result:=IncludeTrailingPathDelimiter(fStorageDirectory)+'sessions';
 end else begin
  result:=IncludeTrailingPathDelimiter(GetCurrentDir)+'sessions';
 end;
 result:=IncludeTrailingPathDelimiter(result);
end;

procedure TPasLLMChatControl.EnsureSessionsDirectory;
begin
 fSessionsDirectory:=GetSessionsDirectory;
 if not DirectoryExists(fSessionsDirectory) then begin
  try
   ForceDirectories(fSessionsDirectory);
  except
   // Handle directory creation error
  end;
 end;
end;

function TPasLLMChatControl.GenerateSessionFileName(const aTitle:TPasLLMUTF8String):TPasLLMUTF8String;
var TimeStamp:TPasLLMUTF8String;
begin
 // Add timestamp to make unique
 TimeStamp:=FormatDateTime('yyyymmdd_hhnnsszzzz',Now);
 result:=TimeStamp+'.json';
end;

function TPasLLMChatControl.GetCurrentSessionFileName:TPasLLMUTF8String;
begin
 result:=fCurrentSessionFileName;
end;

// UI Session management implementations

procedure TPasLLMChatControl.PopulateSessionsList(const aListBox:TListBox);
var Index:TPasLLMInt32;
    DisplayName:TPasLLMUTF8String;
    Entry:TSessionDatabaseEntry;
begin
 if assigned(aListBox) and assigned(fSessionDatabase) then begin
  fUIListBox:=aListBox; // Store reference for later use
  aListBox.Items.Clear;

  // Populate listbox directly from database showing titles
  for Index:=0 to fSessionDatabase.GetCount-1 do begin
   Entry:=fSessionDatabase.GetEntry(Index);
   
   // Use title from database, or simple fallback
   if assigned(Entry) and (length(Entry.Title)>0) then begin
    DisplayName:=Entry.Title;
   end else begin
    DisplayName:='Untitled Session';
   end;
   
   aListBox.Items.Add(DisplayName);
  end;  
  
  // Create context menu for right-click delete
  if not assigned(aListBox.PopupMenu) then begin
   CreateSessionListContextMenu;
   aListBox.PopupMenu:=fSessionListPopupMenu;
  end;

  // Mark current session automatically
  MarkCurrentSessionInList;

 end;
end;

procedure TPasLLMChatControl.OnSessionSelected(const aIndex:TPasLLMInt32);
begin
 if assigned(fUIListBox) and (aIndex>=0) and (aIndex<fUIListBox.Items.Count) then begin
  LoadSession('',aIndex);
 end;
end;

procedure TPasLLMChatControl.LoadSession(const aFileName:TPasLLMUTF8String;const aIndex:TPasLLMInt32);
var FileName:TPasLLMUTF8String;
    DisplayName:TPasLLMUTF8String;
    Entry:TSessionDatabaseEntry;
    Loaded:Boolean;
    FullPath:TPasLLMUTF8String;
    Index:TPasLLMInt32;
    ChatRole:TChatRole;
begin

 if not fInLoadSession then begin

  fInLoadSession:=true;
  try

   if assigned(fSessionDatabase) and ((length(aFileName)>0) or ((aIndex>=0) and (aIndex<fSessionDatabase.GetCount))) then begin

    if length(aFileName)>0 then begin

     Entry:=nil;
     FileName:=aFileName;

     DisplayName:='';

    end else begin

     Entry:=fSessionDatabase.GetEntry(aIndex);
     if assigned(Entry) then begin
      FileName:=Entry.FileName;
     end else begin
      FileName:='';
     end;

     DisplayName:='';
     if assigned(fUIListBox) and (aIndex<fUIListBox.Items.Count) then begin
      DisplayName:=fUIListBox.Items[aIndex];
     end;

    end;

    Loaded:=false;

    try
     FullPath:=IncludeTrailingPathDelimiter(fSessionsDirectory)+FileName;
     if FileExists(FullPath) then begin
      try

       // Clear current session and load using new action-based system
       Clear;

       // Set session file to load and trigger ActionLoadSession
       if assigned(fChatThread) then begin
        fChatThread.fSessionToLoad:=FullPath;
        fChatThread.fActionDoneEvent.ResetEvent;
        TPasMPInterlocked.Write(fChatThread.fAction,TChatThread.ActionLoadSession);
        fChatThread.fInputQueue.Enqueue(#0);
        fChatThread.fEvent.SetEvent;

        // Wait for action to complete
        if WaitForActionDoneEvent(300000)=wrSignaled then begin
         // Session loaded successfully
         fCurrentSessionFileName:=FileName;
        end;
       end;

       // Rebuild UI messages from session messages
       for Index:=0 to fSession.Messages.Count-1 do begin
        ChatRole:=StringToRole(fSession.Messages[Index].Role);
        AddMessage(ChatRole,fSession.Messages[Index].Content);
       end;

       // Recalculate layout and scroll to bottom
       CalculateLayout;
       ScrollToBottom;
{$ifdef FMX}
       InvalidateRect(GetLocalRect);
{$else}
       if assigned(fMessageArea) then begin
        fMessageArea.Invalidate;
       end;
{$endif}

       Loaded:=true;

      except
       on E:Exception do begin
        // Handle load error
        Loaded:=false;
       end;
      end;
     end;
    finally
    end;

    if Loaded then begin
     MarkCurrentSessionInList; // Keep the loaded session marked
     if assigned(fStatusBar) then begin
{$ifndef FMX}
      fStatusBar.Panels[0].Text:='Loaded session: '+DisplayName;
{$endif}
     end;
    end else begin
     if assigned(fStatusBar) then begin
{$ifndef FMX}
      fStatusBar.Panels[0].Text:='Failed to load session';
{$endif}
     end;
    end;

    UpdateEditBoxWithCurrentSession;

   end;

  finally
   fInLoadSession:=false;
  end;

 end;
end;

procedure TPasLLMChatControl.DeleteSelectedSession(const aIndex:TPasLLMInt32);
var FileName:TPasLLMUTF8String;
    DisplayName:TPasLLMUTF8String;
    Entry:TSessionDatabaseEntry;
    IsCurrentSession:Boolean;
begin
 if assigned(fSessionDatabase) and (aIndex>=0) and (aIndex<fSessionDatabase.GetCount) and assigned(fUIListBox) and (aIndex<fUIListBox.Items.Count) then begin
  Entry:=fSessionDatabase.GetEntry(aIndex);
  if assigned(Entry) then begin
   FileName:=Entry.FileName;
  end else begin
   FileName:='';
  end;
  DisplayName:=fUIListBox.Items[aIndex];

  // Show confirmation dialog
{$ifdef FMX}
  MessageDlg(
   'Delete session "'+DisplayName+'"?',
   TMsgDlgType.mtConfirmation,
   [TMsgDlgBtn.mbYes,TMsgDlgBtn.mbNo],
   0,
   procedure(const aResult:TModalResult)
   begin
    if aResult=mrYes then begin
{$else}
  if
{$ifdef fpc}
   MessageDlg('Delete Session','Delete session "'+DisplayName+'"?',mtConfirmation,[mbYes,mbNo],0)=mrYes
{$else}
   MessageDlg('Delete session "'+DisplayName+'"?',mtConfirmation,[mbYes,mbNo],0)=mrYes
{$endif}
   then begin
{$endif}
     // Check and remember if we're deleting the current session
     IsCurrentSession:=fCurrentSessionFileName=FileName;

     DeleteSession(FileName);

     RefreshSessionsList;

     if assigned(fStatusBar) then begin
{$ifndef FMX}
      fStatusBar.Panels[0].Text:='Deleted session: '+DisplayName;
{$endif}
     end;

     // Clear if we deleted the current session
     if IsCurrentSession then begin
      Clear; // Clear the current chat
      fCurrentSessionFileName:=''; // Reset current session filename
      fSession:=nil; // Unbind session
     end;

    end;

{$ifdef FMX}
  end);
{$else}
{$endif}

 end;

end;

procedure TPasLLMChatControl.RefreshSessionsList;
begin
 if assigned(fUIListBox) then begin
  PopulateSessionsList(fUIListBox);
 end;
end;

procedure TPasLLMChatControl.SaveCurrentSessionWithTitle(const aTitle:TPasLLMUTF8String);
var SessionTitle:TPasLLMUTF8String;
begin

 SessionTitle:=Trim(aTitle);

 if length(SessionTitle)<>0 then begin
  // Update session title if changed
  if assigned(fSession) then begin
   fSession.Title:=SessionTitle;
  end;
 end;

 SaveCurrentSession; // Call the original method
 RefreshSessionsList;

 if assigned(fStatusBar) then begin
{$ifndef FMX}
  fStatusBar.Panels[0].Text:='Saved current session';
{$endif}
 end;
end;

procedure TPasLLMChatControl.MarkCurrentSessionInList;
var Index:TPasLLMInt32;
    CurrentFileName:TPasLLMUTF8String;
    Entry:TSessionDatabaseEntry;
begin
 if assigned(fUIListBox) and assigned(fSessionDatabase) then begin
  CurrentFileName:=GetCurrentSessionFileName;
  if length(CurrentFileName)<>0 then begin
   for Index:=0 to fSessionDatabase.GetCount-1 do begin
    Entry:=fSessionDatabase.GetEntry(Index);
    if assigned(Entry) and (Entry.FileName=CurrentFileName) then begin
     fUIListBox.ItemIndex:=Index;
     break;
    end;
   end;
  end;
 end;
end;

procedure TPasLLMChatControl.UpdateCurrentSessionTitle(const aTitle:TPasLLMUTF8String);
begin
 if assigned(fSession) then begin
  fSession.Title:=Trim(aTitle);
  AutoSaveCurrentSession;
 end;
end;

procedure TPasLLMChatControl.UpdateEditBoxWithCurrentSession;
begin
 if assigned(fEditSessionName) then begin
  if assigned(fSession) then begin
   if length(fSession.Title)<>0 then begin
    fEditSessionName.Text:=fSession.Title;
   end else begin
    fEditSessionName.Text:='';
   end;
  end else begin
   fEditSessionName.Text:='';
  end;
 end;
end;

procedure TPasLLMChatControl.CreateSessionListContextMenu;
var MenuItemDelete:TMenuItem;
begin

 if assigned(fSessionListPopupMenu) then begin
  FreeAndNil(fSessionListPopupMenu);
 end;

 fSessionListPopupMenu:=TPopupMenu.Create(Self);

 MenuItemDelete:=TMenuItem.Create(fSessionListPopupMenu);
 {$ifdef FMX}MenuItemDelete.Text{$else}MenuItemDelete.Caption{$endif}:='Delete Session';
 MenuItemDelete.OnClick:=OnSessionListMenuDelete;
 {$ifndef FMX}fSessionListPopupMenu.Items.Add(MenuItemDelete);{$endif}
end;

procedure TPasLLMChatControl.AutoSaveCurrentSession;
begin
 if assigned(fSession) and (fSession.GetMessageCount>0) then begin
  if length(fSession.Title)=0 then begin
   fSession.Title:='Chat '+FormatDateTime('yyyy-mm-dd hh:nn:ss',Now);
  end;
  SaveCurrentSession;
  UpdateEditBoxWithCurrentSession;
  RefreshSessionsList;
 end;
end;

// Context menu handler
procedure TPasLLMChatControl.OnSessionListMenuDelete(aSender:TObject);
begin
 if assigned(fUIListBox) and (fUIListBox.ItemIndex>=0) then begin
  DeleteSelectedSession(fUIListBox.ItemIndex);
 end;
end;

end.

