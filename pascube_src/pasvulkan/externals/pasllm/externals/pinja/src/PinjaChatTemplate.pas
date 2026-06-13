(******************************************************************************
 *                                   Pinja                                    *
 ******************************************************************************
 *                        Version 2025-08-18-06-01-0000                       *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2025-2025, Benjamin Rosseaux (benjamin@rosseaux.de)          *
 *                                                                            *
 * This software is provided 'as-is', without any express or implied          *
 * warranty. In no event will the authors be held liable for any damages      *
 * arising from the use of this software.                                     *
 *                                                                            *
 * Permission is granted to anyone to use this software for any purpose,      *
 * including commercial applications, and to alter it and redistribute it     *
 * freely, subject to the following restrictions:                             *
 *                                                                            *
 * 1. The origin of this software must not be misrepresented; you must not    *
 *    claim that you wrote the original software. If you use this software    *
 *    in a product, an acknowledgement in the product documentation would be  *
 *    appreciated but is not required.                                        *
 * 2. Altered source versions must be plainly marked as such, and must not be *
 *    misrepresented as being the original software.                          *
 * 3. This notice may not be removed or altered from any source distribution. *
 *                                                                            *
 ******************************************************************************
 *                  General guidelines for code contributors                  *
 *============================================================================*
 *                                                                            *
 * 1. Make sure you are legally allowed to make a contribution under the zlib *
 *    license.                                                                *
 * 2. The zlib license header goes at the top of each source file, with       *
 *    appropriate copyright notice.                                           *
 * 3. After a pull request, check the status of your pull request on          *
      http://github.com/BeRo1985/palm                                         *
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
unit PinjaChatTemplate;
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
  {$define BIG_ENDIAN}
 {$endif}
{$else}
 {$realcompatibility off}
 {$localsymbols on}
 {$define LITTLE_ENDIAN}
 {$ifndef cpu64}
  {$define cpu32}
 {$endif}
{$endif}
{$if defined(Win32) or defined(Win64)}
 {$define Windows}
{$ifend}
{$rangechecks off}
{$extendedsyntax on}
{$writeableconst on}
{$hints off}
{$booleval off}
{$typedaddress off}
{$stackframes off}
{$varstringchecks on}
{$typeinfo on}
{$overflowchecks off}
{$longstrings on}
{$openstrings on}
{$scopedenums on}

interface

uses SysUtils,
     Classes,
     Pinja,
     PasJSON;

type TPinjaChatTemplateRawByteString=TPinjaRawByteString;
     TPinjaChatTemplateUTF8String=TPinjaRawByteString;

     TPinjaChatTemplateCapability=
      (
       SupportsTools,
       SupportsToolCalls,
       SupportsToolResponses,
       SupportsSystemRole,
       SupportsParallelToolCalls,
       SupportsToolCallId,
       RequiresObjectArguments,
       RequiresNonNullContent,
       RequiresTypedContent
      );
     TPinjaChatTemplateCapabilities=set of TPinjaChatTemplateCapability;

     TPinjaChatTemplateOption=
      (
       ApplyPolyfills,
       UseBosToken,
       UseEosToken,
       DefineStrftimeNow,
       PolyfillTools,
       PolyfillToolCallExamples,
       PolyfillToolCalls,
       PolyfillToolResponses,
       PolyfillSystemRole,
       PolyfillObjectArguments,
       PolyfillTypedContent
      );
     TPinjaChatTemplateOptions=set of TPinjaChatTemplateOption;

     TPinjaChatTemplateThinkMode=
      (
       Auto=0,
       Disable=1,
       Enable=2
      );

     TPinjaChatTemplateInputs=class
      private
       fMessages:TPasJSONItem;
       fAddGenerationPrompt:Boolean;
       fThinkMode:TPinjaChatTemplateThinkMode;
       fTools:TPasJSONItem;
       fExtraContext:TPasJSONItem;
       fBosToken:TPinjaChatTemplateRawByteString;
       fEosToken:TPinjaChatTemplateRawByteString;
       fNow:TDateTime;
      public
       constructor Create;
       destructor Destroy; override;
       
       property Messages:TPasJSONItem read fMessages write fMessages;
       property AddGenerationPrompt:Boolean read fAddGenerationPrompt write fAddGenerationPrompt;
       property ThinkMode:TPinjaChatTemplateThinkMode read fThinkMode write fThinkMode;
       property Tools:TPasJSONItem read fTools write fTools;
       property ExtraContext:TPasJSONItem read fExtraContext write fExtraContext;
       property BosToken:TPinjaChatTemplateRawByteString read fBosToken write fBosToken;
       property EosToken:TPinjaChatTemplateRawByteString read fEosToken write fEosToken;
       property Now:TDateTime read fNow write fNow;
     end;

     TPinjaChatTemplate=class
      private
       fTemplate:TPinjaRawByteString;
       fBosToken:TPinjaChatTemplateRawByteString;
       fEosToken:TPinjaChatTemplateRawByteString;
       fPinjaTemplate:TPinja.TTemplate;
       fOptions:TPinja.TOptions;
       fCapabilities:TPinjaChatTemplateCapabilities;
       fToolCallExample:TPinjaChatTemplateRawByteString;
       
       function TryRawRender(const aMessages,aTools:TPasJSONItem;aAddGenerationPrompt,aEnableThinking:Boolean;const aExtraContext:TPasJSONItem=nil):TPinjaChatTemplateRawByteString;
       procedure DetectCapabilities;
       function ApplyMessagePolyfills(const aMessage:TPasJSONItemObject;aPolyfillSystemRole,aPolyfillToolCalls,aPolyfillToolResponses,aPolyfillObjectArguments,aPolyfillTypedContent:Boolean;var aPendingSystem:TPinjaRawByteString):TPasJSONItem;
       function ScanNodeForMessagesLoop(const aNode:TPinja.TNodeStatement):Boolean;
      public
       constructor Create(const aTemplate:TPinjaChatTemplateRawByteString;
                          const aBosToken:TPinjaChatTemplateRawByteString='';
                          const aEosToken:TPinjaChatTemplateRawByteString='');
       destructor Destroy; override;
       
       function Apply(const aInputs:TPinjaChatTemplateInputs):TPinjaChatTemplateRawByteString; overload;
       function Apply(const aInputs:TPinjaChatTemplateInputs;const aOptions:TPinjaChatTemplateOptions):TPinjaChatTemplateRawByteString; overload;
       function CreateDefaultOptions:TPinjaChatTemplateOptions;
       function ContainsMessagesLoop:Boolean; // Check if template contains messages array processing
       
       // Utility functions
       class function AddSystem(const aMessages:TPasJSONItem;const aSystemPrompt:TPinjaChatTemplateRawByteString):TPasJSONItem; static;
       
       property Template:TPinjaRawByteString read fTemplate;
       property BosToken:TPinjaChatTemplateRawByteString read fBosToken;
       property EosToken:TPinjaChatTemplateRawByteString read fEosToken;
       property Caps:TPinjaChatTemplateCapabilities read fCapabilities;
       property ToolCallExample:TPinjaChatTemplateRawByteString read fToolCallExample;
     end;

implementation

function ConvertStrftimeFormat(const aStrftimeFormat:TPinjaRawByteString;const aDateTime:TDateTime):TPinjaRawByteString;
var PascalFormat:TPinjaRawByteString;
begin
 PascalFormat:=aStrftimeFormat;
 
 PascalFormat:=StringReplace(PascalFormat,'%Y','yyyy',[rfReplaceAll]);
 PascalFormat:=StringReplace(PascalFormat,'%y','yy',[rfReplaceAll]);
 PascalFormat:=StringReplace(PascalFormat,'%m','mm',[rfReplaceAll]);
 PascalFormat:=StringReplace(PascalFormat,'%d','dd',[rfReplaceAll]);
 PascalFormat:=StringReplace(PascalFormat,'%H','hh',[rfReplaceAll]);
 PascalFormat:=StringReplace(PascalFormat,'%M','nn',[rfReplaceAll]);
 PascalFormat:=StringReplace(PascalFormat,'%S','ss',[rfReplaceAll]);
 PascalFormat:=StringReplace(PascalFormat,'%A','dddd',[rfReplaceAll]);
 PascalFormat:=StringReplace(PascalFormat,'%a','ddd',[rfReplaceAll]);
 PascalFormat:=StringReplace(PascalFormat,'%B','mmmm',[rfReplaceAll]);
 PascalFormat:=StringReplace(PascalFormat,'%b','mmm',[rfReplaceAll]);
 
 try
  result:=FormatDateTime(PascalFormat,aDateTime);
 except
  result:=FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"',aDateTime);
 end;
end;

function StrftimeNowCallable(const aSelf:TPinja.TValue;const aPos:array of TPinja.TValue;var aKw:TPinja.TValue;const aContext:TPinja.TContext):TPinja.TValue;
var FormatStr:TPinjaRawByteString;
    CurrentTime:TDateTime;
    FormattedDateTime:TPinjaRawByteString;
begin
 CurrentTime:=Now;
 
 if Length(aPos)>0 then begin
  FormatStr:=aPos[0].AsString;
 end else begin
  FormatStr:='%Y-%m-%dT%H:%M:%SZ';
 end;
 
 FormattedDateTime:=ConvertStrftimeFormat(FormatStr,CurrentTime);
 
 result:=TPinja.TValue.From(FormattedDateTime);
end;

{ TPinjaChatTemplateInputs }

constructor TPinjaChatTemplateInputs.Create;
begin
 inherited Create;
 fMessages:=nil;
 fAddGenerationPrompt:=false;
 fThinkMode:=TPinjaChatTemplateThinkMode.Auto;
 fTools:=nil;
 fExtraContext:=nil;
 fBosToken:='';
 fEosToken:='';
 fNow:=Now;
end;

destructor TPinjaChatTemplateInputs.Destroy;
begin
 FreeAndNil(fMessages);
 FreeAndNil(fTools);
 FreeAndNil(fExtraContext);
 fBosToken:='';
 fEosToken:='';
 inherited Destroy;
end;

{ TPinjaChatTemplate }

constructor TPinjaChatTemplate.Create(const aTemplate:TPinjaChatTemplateRawByteString;
                                      const aBosToken:TPinjaChatTemplateRawByteString='';
                                      const aEosToken:TPinjaChatTemplateRawByteString='');
begin
 inherited Create;
 fTemplate:=aTemplate;
 fBosToken:=aBosToken;
 fEosToken:=aEosToken;
 fToolCallExample:='';
 
 // Initialize template capability structure with defaults
 fCapabilities:=[];
 
 // Initialize Pinja template options
 fOptions:=[]; //[TPinja.TOption.TrimBlocks,TPinja.TOption.LStripBlocks];
 
 // Create the Pinja template
 fPinjaTemplate:=TPinja.TTemplate.Create(fTemplate,fOptions);
 
 // Detect template capabilities
 DetectCapabilities;
end;

destructor TPinjaChatTemplate.Destroy;
begin
 FreeAndNil(fPinjaTemplate);
 fTemplate:='';
 fBosToken:='';
 fEosToken:='';
 fToolCallExample:='';
 inherited Destroy;
end;

function TPinjaChatTemplate.CreateDefaultOptions:TPinjaChatTemplateOptions;
begin
 result:=[TPinjaChatTemplateOption.ApplyPolyfills,
          TPinjaChatTemplateOption.UseBosToken,
          TPinjaChatTemplateOption.UseEosToken,
          TPinjaChatTemplateOption.DefineStrftimeNow,
          TPinjaChatTemplateOption.PolyfillTools,
          TPinjaChatTemplateOption.PolyfillToolCallExamples,
          TPinjaChatTemplateOption.PolyfillToolCalls,
          TPinjaChatTemplateOption.PolyfillToolResponses,
          TPinjaChatTemplateOption.PolyfillSystemRole,
          TPinjaChatTemplateOption.PolyfillObjectArguments,
          TPinjaChatTemplateOption.PolyfillTypedContent];
end;

function TPinjaChatTemplate.TryRawRender(const aMessages,aTools:TPasJSONItem;aAddGenerationPrompt,aEnableThinking:Boolean;const aExtraContext:TPasJSONItem=nil):TPinjaChatTemplateRawByteString;
var Context:TPinja.TContext;
    MessagesValue:TPinja.TValue;
    ToolsValue:TPinja.TValue;
    AddGenerationPromptValue:TPinja.TValue;
    EnableThinkingValue:TPinja.TValue;
    BosTokenValue:TPinja.TValue;
    EosTokenValue:TPinja.TValue;
    Index:TPinjaInt32;
    PropertyKey:TPasJSONUTF8String;
    PropertyValue:TPinja.TValue;
begin
 result:='';
 
 try
  Context:=TPinja.TContext.Create;
  try

   Context.RaiseExceptionAtUnknownCallables:=false;

   // Convert inputs to Pinja values
   if assigned(aMessages) then begin
    MessagesValue:=TPinja.TValue.From(aMessages);
    Context.SetVariable('messages',MessagesValue);
   end;
   
   if assigned(aTools) then begin
    ToolsValue:=TPinja.TValue.From(aTools);
    Context.SetVariable('tools',ToolsValue);
   end;
   
   AddGenerationPromptValue:=TPinja.TValue.From(aAddGenerationPrompt);
   Context.SetVariable('add_generation_prompt',AddGenerationPromptValue);

   EnableThinkingValue:=TPinja.TValue.From(aEnableThinking);
   Context.SetVariable('enable_thinking',EnableThinkingValue);

   BosTokenValue:=TPinja.TValue.From(fBosToken);
   Context.SetVariable('bos_token',BosTokenValue);
   
   EosTokenValue:=TPinja.TValue.From(fEosToken);
   Context.SetVariable('eos_token',EosTokenValue);

// Context.SetVariable('date_string',TPinja.TValue.From(ConvertStrftimeFormat('%d %b %Y',Now)));

   if assigned(aExtraContext) then begin
    // Add extra context variables - iterate through object properties
    if aExtraContext is TPasJSONItemObject then begin
     for Index:=0 to TPasJSONItemObject(aExtraContext).Count-1 do begin
      PropertyKey:=TPasJSONItemObject(aExtraContext).Keys[Index];
      PropertyValue:=TPinja.TValue.From(TPasJSONItemObject(aExtraContext).Values[Index]);
      Context.SetVariable(PropertyKey,PropertyValue);
     end;
    end;
   end;
   
   // Render the template
   result:=fPinjaTemplate.RenderToString(Context);
   
  finally
   FreeAndNil(Context);
  end;
 except
  // Return empty string on any error
  result:='';
 end;
end;

procedure TPinjaChatTemplate.DetectCapabilities;
const USER_NEEDLE='<User Needle>';
      SYS_NEEDLE='<System Needle>';
var DummyUserMsg:TPasJSONItemObject;
    DummyTypedUserMsg:TPasJSONItemObject;
    DummyUserMsgArray:TPasJSONItemArray;
    DummyTypedUserMsgArray:TPasJSONItemArray;
    NeedleSystemMsg:TPasJSONItemObject;
    TestMessages:TPasJSONItemArray;
    OutString:TPinjaRawByteString;
    TestTools:TPasJSONItemArray;
    TestTool:TPasJSONItemObject;
    TestToolFunction:TPasJSONItemObject;
    TestToolParams:TPasJSONItemObject;
    TestToolProperties:TPasJSONItemObject;
    TestToolArg:TPasJSONItemObject;
    TestToolRequired:TPasJSONItemArray;
    TestTypedContent:TPasJSONItemArray;
    TextContent:TPasJSONItemObject;
    AssistantMsg:TPasJSONItemObject;
    ToolCallsArray:TPasJSONItemArray;
    ToolCall1:TPasJSONItemObject;
    ToolCall2:TPasJSONItemObject;
    ToolCallFunc:TPasJSONItemObject;
    DummyArgs:TPasJSONItemObject;
    ToolResponseMsg:TPasJSONItemObject;
begin
 // Initialize all capabilities to false
 fCapabilities:=[];
 
 // Initialize all pointer variables to nil to avoid freeing uninitialized pointers
 DummyUserMsg:=nil;
 DummyTypedUserMsg:=nil;
 DummyUserMsgArray:=nil;
 DummyTypedUserMsgArray:=nil;
 NeedleSystemMsg:=nil;
 TestMessages:=nil;
 TestTools:=nil;
 TestTool:=nil;
 TestToolFunction:=nil;
 TestToolParams:=nil;
 TestToolProperties:=nil;
 TestToolArg:=nil;
 TestToolRequired:=nil;
 TestTypedContent:=nil;
 TextContent:=nil;
 AssistantMsg:=nil;
 ToolCallsArray:=nil;
 ToolCall1:=nil;
 ToolCall2:=nil;
 ToolCallFunc:=nil;
 DummyArgs:=nil;
 ToolResponseMsg:=nil;

 try
  try
   // Test for typed content requirement
   DummyUserMsg:=TPasJSONItemObject.Create;
   DummyUserMsg.Add('role',TPasJSONItemString.Create('user'));
   DummyUserMsg.Add('content',TPasJSONItemString.Create(USER_NEEDLE));
   
   DummyUserMsgArray:=TPasJSONItemArray.Create;
   try
    DummyUserMsgArray.Add(DummyUserMsg.Clone);
    
    OutString:=TryRawRender(DummyUserMsgArray,nil,false,false);
    if Pos(USER_NEEDLE,OutString)=0 then begin
     Include(fCapabilities,TPinjaChatTemplateCapability.RequiresTypedContent);
    end;
   finally
    FreeAndNil(DummyUserMsgArray);
   end;
   
   // Test with typed content
   if TPinjaChatTemplateCapability.RequiresTypedContent in fCapabilities then begin
    DummyTypedUserMsg:=TPasJSONItemObject.Create;
    DummyTypedUserMsg.Add('role',TPasJSONItemString.Create('user'));
    TestTypedContent:=TPasJSONItemArray.Create;
    TextContent:=TPasJSONItemObject.Create;
    TextContent.Add('type',TPasJSONItemString.Create('text'));
    TextContent.Add('text',TPasJSONItemString.Create(USER_NEEDLE));
    TestTypedContent.Add(TextContent.Clone);
    DummyTypedUserMsg.Add('content',TestTypedContent.Clone);
    
    DummyTypedUserMsgArray:=TPasJSONItemArray.Create;
    try
     DummyTypedUserMsgArray.Add(DummyTypedUserMsg.Clone);
     
     OutString:=TryRawRender(DummyTypedUserMsgArray,nil,false,false);
     if not (Pos(USER_NEEDLE,OutString)>0) then begin
      Exclude(fCapabilities,TPinjaChatTemplateCapability.RequiresTypedContent);
     end;
    finally
     FreeAndNil(DummyTypedUserMsgArray);
     FreeAndNil(DummyUserMsg); // Free the original simple user msg
    end;
    DummyUserMsg:=DummyTypedUserMsg; // Use the typed version
   end else begin
    DummyUserMsg:=TPasJSONItemObject.Create;
    DummyUserMsg.Add('role',TPasJSONItemString.Create('user'));
    DummyUserMsg.Add('content',TPasJSONItemString.Create(USER_NEEDLE));
   end;
  
  // Test system role support
  NeedleSystemMsg:=TPasJSONItemObject.Create;
  try
   NeedleSystemMsg.Add('role',TPasJSONItemString.Create('system'));
   if TPinjaChatTemplateCapability.RequiresTypedContent in fCapabilities then begin
    TestTypedContent:=TPasJSONItemArray.Create;
    try
     TextContent:=TPasJSONItemObject.Create;
     try
      TextContent.Add('type',TPasJSONItemString.Create('text'));
      TextContent.Add('text',TPasJSONItemString.Create(SYS_NEEDLE));
      TestTypedContent.Add(TextContent.Clone);
     finally
      FreeAndNil(TextContent);
     end;
     NeedleSystemMsg.Add('content',TestTypedContent.Clone);
    finally
     FreeAndNil(TestTypedContent);
    end;
   end else begin
    NeedleSystemMsg.Add('content',TPasJSONItemString.Create(SYS_NEEDLE));
   end;
   
   TestMessages:=TPasJSONItemArray.Create;
   try
    TestMessages.Add(NeedleSystemMsg.Clone);
    TestMessages.Add(DummyUserMsg.Clone);
    
    OutString:=TryRawRender(TestMessages,nil,false,false);
    if Pos(SYS_NEEDLE,OutString)>0 then begin
     Include(fCapabilities,TPinjaChatTemplateCapability.SupportsSystemRole);
    end;
   finally
    FreeAndNil(TestMessages);
   end;
  finally
   FreeAndNil(NeedleSystemMsg);
  end;
  
  // Test tool support
  TestTools:=TPasJSONItemArray.Create;
  TestTool:=TPasJSONItemObject.Create;
  TestTool.Add('name',TPasJSONItemString.Create('some_tool'));
  TestTool.Add('type',TPasJSONItemString.Create('function'));
  
  TestToolFunction:=TPasJSONItemObject.Create;
  TestToolFunction.Add('name',TPasJSONItemString.Create('some_tool'));
  TestToolFunction.Add('description',TPasJSONItemString.Create('Some tool.'));
  
  TestToolParams:=TPasJSONItemObject.Create;
  TestToolParams.Add('type',TPasJSONItemString.Create('object'));
  
  TestToolProperties:=TPasJSONItemObject.Create;
  TestToolArg:=TPasJSONItemObject.Create;
  TestToolArg.Add('type',TPasJSONItemString.Create('string'));
  TestToolArg.Add('description',TPasJSONItemString.Create('Some argument.'));
  TestToolProperties.Add('arg',TestToolArg.Clone);
  TestToolParams.Add('properties',TestToolProperties.Clone);
  
  TestToolRequired:=TPasJSONItemArray.Create;
  TestToolRequired.Add(TPasJSONItemString.Create('arg'));
  TestToolParams.Add('required',TestToolRequired.Clone);
  
  TestToolFunction.Add('parameters',TestToolParams.Clone);
  TestTool.Add('function',TestToolFunction.Clone);
  TestTools.Add(TestTool.Clone);
  
  DummyUserMsgArray:=TPasJSONItemArray.Create;
  DummyUserMsgArray.Add(DummyUserMsg.Clone);
  
  OutString:=TryRawRender(DummyUserMsgArray,TestTools,false,false);
  if Pos('some_tool',OutString)>0 then begin
   Include(fCapabilities,TPinjaChatTemplateCapability.SupportsTools);
  end;
  
  // Test requires_non_null_content
  AssistantMsg:=TPasJSONItemObject.Create;
  AssistantMsg.Add('role',TPasJSONItemString.Create('assistant'));
  AssistantMsg.Add('content',TPasJSONItemString.Create(''));
  
  TestMessages:=TPasJSONItemArray.Create;
  try
   TestMessages.Add(DummyUserMsg.Clone);
   TestMessages.Add(AssistantMsg.Clone);
   TestMessages.Add(DummyUserMsg.Clone);
   TestMessages.Add(AssistantMsg.Clone);
   
   OutString:=TryRawRender(TestMessages,nil,false,false);
   if Pos(USER_NEEDLE,OutString)>0 then begin
    Include(fCapabilities,TPinjaChatTemplateCapability.RequiresNonNullContent);
   end;
  finally
   FreeAndNil(TestMessages);
  end;
  
  // Test with null content
  AssistantMsg:=TPasJSONItemObject.Create;
  AssistantMsg.Add('role',TPasJSONItemString.Create('assistant'));
  // Don't add content field (null equivalent)
  
  TestMessages:=TPasJSONItemArray.Create;
  try
   TestMessages.Add(DummyUserMsg.Clone);
   TestMessages.Add(AssistantMsg.Clone);
   TestMessages.Add(DummyUserMsg.Clone);
   TestMessages.Add(AssistantMsg.Clone);
   
   OutString:=TryRawRender(TestMessages,nil,false,false);
   if not (Pos(USER_NEEDLE,OutString)=0) then begin
    Exclude(fCapabilities,TPinjaChatTemplateCapability.RequiresNonNullContent);
   end;
  finally
   FreeAndNil(TestMessages);
  end;
  
  // Test tool calls support
  DummyArgs:=TPasJSONItemObject.Create;
  try
   DummyArgs.Add('argument_needle',TPasJSONItemString.Create('print(''Hello, World!'')'));
   
   // Test with string arguments
   ToolCall1:=TPasJSONItemObject.Create;
   try
    ToolCall1.Add('id',TPasJSONItemString.Create('call_1___'));
    ToolCall1.Add('type',TPasJSONItemString.Create('function'));
    ToolCallFunc:=TPasJSONItemObject.Create;
    try
     ToolCallFunc.Add('name',TPasJSONItemString.Create('ipython'));
     ToolCallFunc.Add('arguments',TPasJSONItemString.Create('{"argument_needle":"print(''Hello, World'')"}'));
     ToolCall1.Add('function',ToolCallFunc.Clone);
    finally
     FreeAndNil(ToolCallFunc);
    end;
    
    ToolCallsArray:=TPasJSONItemArray.Create;
    try
     ToolCallsArray.Add(ToolCall1.Clone);
     
     AssistantMsg:=TPasJSONItemObject.Create;
     try
      AssistantMsg.Add('role',TPasJSONItemString.Create('assistant'));
      if TPinjaChatTemplateCapability.RequiresNonNullContent in fCapabilities then begin
       AssistantMsg.Add('content',TPasJSONItemString.Create(''));
      end;
      AssistantMsg.Add('tool_calls',ToolCallsArray.Clone);
      
      TestMessages:=TPasJSONItemArray.Create;
      try
       TestMessages.Add(DummyUserMsg.Clone);
       TestMessages.Add(AssistantMsg.Clone);
       
       OutString:=TryRawRender(TestMessages,nil,false,false);
       if Pos('argument_needle',OutString)>0 then begin
        Include(fCapabilities,TPinjaChatTemplateCapability.SupportsToolCalls);
       end;
      finally
       FreeAndNil(TestMessages);
      end;
     finally
      FreeAndNil(AssistantMsg);
     end;
    finally
     FreeAndNil(ToolCallsArray);
    end;
   finally
    FreeAndNil(ToolCall1);
   end;
  finally
   FreeAndNil(DummyArgs);
  end;
  
  // Test with object arguments if string didn't work
  if not (TPinjaChatTemplateCapability.SupportsToolCalls in fCapabilities) then begin
   DummyArgs:=TPasJSONItemObject.Create;
   try
    DummyArgs.Add('argument_needle',TPasJSONItemString.Create('print(''Hello, World!'')'));

    ToolCall1:=TPasJSONItemObject.Create;
    try
     ToolCall1.Add('id',TPasJSONItemString.Create('call_1___'));
     ToolCall1.Add('type',TPasJSONItemString.Create('function'));
     ToolCallFunc:=TPasJSONItemObject.Create;
     try
      ToolCallFunc.Add('name',TPasJSONItemString.Create('ipython'));
      ToolCallFunc.Add('arguments',DummyArgs.Clone);
      ToolCall1.Add('function',ToolCallFunc.Clone);
     finally
      FreeAndNil(ToolCallFunc);
     end;
     
     ToolCallsArray:=TPasJSONItemArray.Create;
     try
      ToolCallsArray.Add(ToolCall1.Clone);
      
      AssistantMsg:=TPasJSONItemObject.Create;
      try
       AssistantMsg.Add('role',TPasJSONItemString.Create('assistant'));
       if TPinjaChatTemplateCapability.RequiresNonNullContent in fCapabilities then begin
        AssistantMsg.Add('content',TPasJSONItemString.Create(''));
       end;
       AssistantMsg.Add('tool_calls',ToolCallsArray.Clone);
       
       TestMessages:=TPasJSONItemArray.Create;
       try
        TestMessages.Add(DummyUserMsg.Clone);
        TestMessages.Add(AssistantMsg.Clone);
        
        OutString:=TryRawRender(TestMessages,nil,false,false);
        if Pos('argument_needle',OutString)>0 then begin
         Include(fCapabilities,TPinjaChatTemplateCapability.SupportsToolCalls);
         Include(fCapabilities,TPinjaChatTemplateCapability.RequiresObjectArguments);
        end;
       finally
        FreeAndNil(TestMessages);
       end;
      finally
       FreeAndNil(AssistantMsg);
      end;
     finally
      FreeAndNil(ToolCallsArray);
     end;
    finally
     FreeAndNil(ToolCall1);
    end;
   finally
    FreeAndNil(DummyArgs);
   end;
  end;
  
  // Test parallel tool calls if tool calls are supported
  if TPinjaChatTemplateCapability.SupportsToolCalls in fCapabilities then begin
   DummyArgs:=TPasJSONItemObject.Create;
   try
    DummyArgs.Add('argument_needle',TPasJSONItemString.Create('print(''Hello, World!'')'));
    ToolCall1:=TPasJSONItemObject.Create;
    try
     ToolCall1.Add('id',TPasJSONItemString.Create('call_1___'));
     ToolCall1.Add('type',TPasJSONItemString.Create('function'));
     ToolCallFunc:=TPasJSONItemObject.Create;
     try
      ToolCallFunc.Add('name',TPasJSONItemString.Create('test_tool1'));
      if TPinjaChatTemplateCapability.RequiresObjectArguments in fCapabilities then begin
       ToolCallFunc.Add('arguments',DummyArgs.Clone);
      end else begin
       ToolCallFunc.Add('arguments',TPasJSONItemString.Create('{"argument_needle":"print(''Hello, World'')"}'));
      end;
      ToolCall1.Add('function',ToolCallFunc.Clone);
     finally
      FreeAndNil(ToolCallFunc);
     end;

     ToolCall2:=TPasJSONItemObject.Create;
     try
      ToolCall2.Add('id',TPasJSONItemString.Create('call_2___'));
      ToolCall2.Add('type',TPasJSONItemString.Create('function'));
      ToolCallFunc:=TPasJSONItemObject.Create;
      try
       ToolCallFunc.Add('name',TPasJSONItemString.Create('test_tool2'));
       if TPinjaChatTemplateCapability.RequiresObjectArguments in fCapabilities then begin
        ToolCallFunc.Add('arguments',DummyArgs.Clone);
       end else begin
        ToolCallFunc.Add('arguments',TPasJSONItemString.Create('{"argument_needle":"print(''Hello, World'')"}'));
       end;
       ToolCall2.Add('function',ToolCallFunc.Clone);
      finally
       FreeAndNil(ToolCallFunc);
      end;

      ToolCallsArray:=TPasJSONItemArray.Create;
      try
       ToolCallsArray.Add(ToolCall1.Clone);
       ToolCallsArray.Add(ToolCall2.Clone);

       AssistantMsg:=TPasJSONItemObject.Create;
       try
        AssistantMsg.Add('role',TPasJSONItemString.Create('assistant'));
        if TPinjaChatTemplateCapability.RequiresNonNullContent in fCapabilities then begin
         AssistantMsg.Add('content',TPasJSONItemString.Create(''));
        end;
        AssistantMsg.Add('tool_calls',ToolCallsArray.Clone);

        TestMessages:=TPasJSONItemArray.Create;
        try
         TestMessages.Add(DummyUserMsg.Clone);
         TestMessages.Add(AssistantMsg.Clone);

         OutString:=TryRawRender(TestMessages,nil,false,false);
         if (Pos('test_tool1',OutString)>0) and (Pos('test_tool2',OutString)>0) then begin
          Include(fCapabilities,TPinjaChatTemplateCapability.SupportsParallelToolCalls);
         end;
        finally
         FreeAndNil(TestMessages);
        end;

        // Test tool responses (while we still have ToolCall1 available)
        ToolResponseMsg:=TPasJSONItemObject.Create;
        try
         ToolResponseMsg.Add('role',TPasJSONItemString.Create('tool'));
         ToolResponseMsg.Add('name',TPasJSONItemString.Create('test_tool1'));
         ToolResponseMsg.Add('content',TPasJSONItemString.Create('Some response!'));
         ToolResponseMsg.Add('tool_call_id',TPasJSONItemString.Create('call_911_'));

         TestMessages:=TPasJSONItemArray.Create;
         try
          TestMessages.Add(DummyUserMsg.Clone);
          TestMessages.Add(ToolCall1.Clone);  // Clone the first tool call
          TestMessages.Add(ToolResponseMsg.Clone);

          OutString:=TryRawRender(TestMessages,nil,false,false);
          if Pos('Some response!',OutString)>0 then begin
           Include(fCapabilities,TPinjaChatTemplateCapability.SupportsToolResponses);
          end;
          if Pos('call_911_',OutString)>0 then begin
           Include(fCapabilities,TPinjaChatTemplateCapability.SupportsToolCallId);
          end;
         finally
          FreeAndNil(TestMessages);
         end;
        finally
         FreeAndNil(ToolResponseMsg);
        end;
       finally
        FreeAndNil(AssistantMsg);
       end;
      finally
       FreeAndNil(ToolCallsArray);
      end;
     finally
      FreeAndNil(ToolCall2);
     end;
    finally
     FreeAndNil(ToolCall1);
    end;
   finally
    FreeAndNil(DummyArgs);
   end;
  end;
  
  finally
   // Cleanup all created objects
   FreeAndNil(DummyUserMsgArray);
   FreeAndNil(TestTools);
   FreeAndNil(DummyUserMsg);
   FreeAndNil(DummyArgs);
   
   // Free all the TestTool related objects that were created
   FreeAndNil(TestTool);
   FreeAndNil(TestToolFunction);
   FreeAndNil(TestToolParams);
   FreeAndNil(TestToolProperties);
   FreeAndNil(TestToolArg);
   FreeAndNil(TestToolRequired);
   
   // Free typed content objects if they were created
   FreeAndNil(TestTypedContent);
   FreeAndNil(TextContent);
   
   // Free ToolCallFunc which is recreated multiple times
   FreeAndNil(ToolCallFunc);
   
   // Free ToolCallsArray which is recreated multiple times  
   FreeAndNil(ToolCallsArray);
  end;

 except
  // On any error, assume no capabilities are supported
  fCapabilities:=[];
 end;
end;

function TPinjaChatTemplate.Apply(const aInputs:TPinjaChatTemplateInputs):TPinjaChatTemplateRawByteString;
begin
 result:=Apply(aInputs,CreateDefaultOptions);
end;

function TPinjaChatTemplate.Apply(const aInputs:TPinjaChatTemplateInputs;const aOptions:TPinjaChatTemplateOptions):TPinjaChatTemplateRawByteString;
var Context:TPinja.TContext;
    MessagesValue:TPinja.TValue;
    ToolsValue:TPinja.TValue;
    AddGenerationPromptValue:TPinja.TValue;
    EnableThinkingValue:TPinja.TValue;
    BosTokenValue:TPinja.TValue;
    EosTokenValue:TPinja.TValue;
    ActualMessages:TPasJSONItem;
    Index:TPinjaInt32;
    PropertyKey:TPasJSONUTF8String;
    PropertyValue:TPinja.TValue;
    HasTools:Boolean;
    HasToolCalls:Boolean;
    HasToolResponses:Boolean;
    HasStringContent:Boolean;
    NeedsPolyfills:Boolean;
    PolyfillSystemRole:Boolean;
    PolyfillTools:Boolean;
    PolyfillToolCallExample:Boolean;
    PolyfillToolCalls:Boolean;
    PolyfillToolResponses:Boolean;
    PolyfillObjectArguments:Boolean;
    PolyfillTypedContent:Boolean;
    ProcessedMessages:TPasJSONItemArray;
    Message:TPasJSONItem;
    MessageObj:TPasJSONItemObject;
    PendingSystem:TPinjaRawByteString;
    SystemPrompt:TPinjaRawByteString;
begin
 result:='';
 
 if not assigned(aInputs) then begin
  exit;
 end;

 // Analyze input messages for polyfill requirements
 HasTools:=assigned(aInputs.Tools) and (aInputs.Tools is TPasJSONItemArray) and (TPasJSONItemArray(aInputs.Tools).Count>0);
 HasToolCalls:=false;
 HasToolResponses:=false;
 HasStringContent:=false;
 
 if assigned(aInputs.Messages) and (aInputs.Messages is TPasJSONItemArray) then begin
  for Index:=0 to TPasJSONItemArray(aInputs.Messages).Count-1 do begin
   Message:=TPasJSONItemArray(aInputs.Messages).Items[Index];
   if assigned(Message) and (Message is TPasJSONItemObject) then begin
    MessageObj:=TPasJSONItemObject(Message);
    if assigned(MessageObj.Properties['tool_calls']) and not (MessageObj.Properties['tool_calls'] is TPasJSONItemNull) then begin
     HasToolCalls:=true;
    end;
    if assigned(MessageObj.Properties['role']) and (MessageObj.Properties['role'] is TPasJSONItemString) and (TPasJSONItemString(MessageObj.Properties['role']).Value='tool') then begin
     HasToolResponses:=true;
    end;
    if assigned(MessageObj.Properties['content']) and (MessageObj.Properties['content'] is TPasJSONItemString) then begin
     HasStringContent:=true;
    end;
   end;
  end;
 end;
 
 // Determine which polyfills are needed
 PolyfillSystemRole:=(TPinjaChatTemplateOption.PolyfillSystemRole in aOptions) and not (TPinjaChatTemplateCapability.SupportsSystemRole in fCapabilities);
 PolyfillTools:=(TPinjaChatTemplateOption.PolyfillTools in aOptions) and HasTools and not (TPinjaChatTemplateCapability.SupportsTools in fCapabilities);
 PolyfillToolCallExample:=PolyfillTools and (TPinjaChatTemplateOption.PolyfillToolCallExamples in aOptions);
 PolyfillToolCalls:=(TPinjaChatTemplateOption.PolyfillToolCalls in aOptions) and HasToolCalls and not (TPinjaChatTemplateCapability.SupportsToolCalls in fCapabilities);
 PolyfillToolResponses:=(TPinjaChatTemplateOption.PolyfillToolResponses in aOptions) and HasToolResponses and not (TPinjaChatTemplateCapability.SupportsToolResponses in fCapabilities);
 PolyfillObjectArguments:=(TPinjaChatTemplateOption.PolyfillObjectArguments in aOptions) and HasToolCalls and (TPinjaChatTemplateCapability.RequiresObjectArguments in fCapabilities);
 PolyfillTypedContent:=(TPinjaChatTemplateOption.PolyfillTypedContent in aOptions) and HasStringContent and (TPinjaChatTemplateCapability.RequiresTypedContent in fCapabilities);
 
 NeedsPolyfills:=(TPinjaChatTemplateOption.ApplyPolyfills in aOptions) and (PolyfillSystemRole or PolyfillTools or PolyfillToolCalls or PolyfillToolResponses or PolyfillObjectArguments or PolyfillTypedContent);
 
 if NeedsPolyfills then begin
  // Apply polyfills - create processed message array
  ProcessedMessages:=TPasJSONItemArray.Create;
  try
   ActualMessages:=aInputs.Messages;
   
   // Add tools as system message if needed
   if PolyfillTools then begin
    SystemPrompt:='You can call any of the following tools to satisfy the user''s requests: '+TPinja.TValue.From(aInputs.Tools).AsString;
    if PolyfillToolCallExample and (fToolCallExample<>'') then begin
     SystemPrompt:=SystemPrompt+#13#10#13#10+'Example tool call syntax:'+#13#10#13#10+fToolCallExample+#13#10#13#10;
    end;
    ActualMessages:=AddSystem(ActualMessages,SystemPrompt);
   end;
   
   PendingSystem:='';
   
   // Process each message with polyfills
   if assigned(ActualMessages) and (ActualMessages is TPasJSONItemArray) then begin
    for Index:=0 to TPasJSONItemArray(ActualMessages).Count-1 do begin
     Message:=TPasJSONItemArray(ActualMessages).Items[Index];
     if assigned(Message) and (Message is TPasJSONItemObject) then begin
      MessageObj:=TPasJSONItemObject(Message);
      
      if assigned(MessageObj.Properties['role']) and (MessageObj.Properties['role'] is TPasJSONItemString) then begin
       // Apply message-specific polyfills
       Message:=ApplyMessagePolyfills(MessageObj,PolyfillSystemRole,PolyfillToolCalls,PolyfillToolResponses,PolyfillObjectArguments,PolyfillTypedContent,PendingSystem);
       if assigned(Message) then begin
        ProcessedMessages.Add(Message);
       end;
      end;
     end;
    end;
    
    // Flush any remaining system content
    if length(PendingSystem)<>0 then begin
     MessageObj:=TPasJSONItemObject.Create;
     MessageObj.Add('role',TPasJSONItemString.Create('user'));
     MessageObj.Add('content',TPasJSONItemString.Create(PendingSystem));
     ProcessedMessages.Add(MessageObj);
    end;
   end;
   
   ActualMessages:=ProcessedMessages;
   ProcessedMessages:=nil; // Transfer ownership
   
  except
   FreeAndNil(ProcessedMessages);
   raise;
  end;
 end else begin
  ActualMessages:=aInputs.Messages;
 end;
 
 Context:=TPinja.TContext.Create;
 try
  // Convert inputs to Pinja values
  if assigned(ActualMessages) then begin
   MessagesValue:=TPinja.TValue.From(ActualMessages);
   Context.SetVariable('messages',MessagesValue);
  end;
  
  if assigned(aInputs.Tools) then begin
   ToolsValue:=TPinja.TValue.From(aInputs.Tools);
   Context.SetVariable('tools',ToolsValue);
  end;
  
  AddGenerationPromptValue:=TPinja.TValue.From(aInputs.AddGenerationPrompt);
  Context.SetVariable('add_generation_prompt',AddGenerationPromptValue);

  case aInputs.ThinkMode of
   TPinjaChatTemplateThinkMode.Disable,
   TPinjaChatTemplateThinkMode.Enable:begin
    EnableThinkingValue:=TPinja.TValue.From(aInputs.ThinkMode=TPinjaChatTemplateThinkMode.Enable);
    Context.SetVariable('enable_thinking',EnableThinkingValue);
   end;
   else begin
   end;
  end;

  // Set token values - use inputs first, then template defaults
  if length(aInputs.BosToken)>0 then begin
   BosTokenValue:=TPinja.TValue.From(aInputs.BosToken);
  end else begin
   if TPinjaChatTemplateOption.UseBosToken in aOptions then begin
    BosTokenValue:=TPinja.TValue.From(fBosToken);
   end else begin
    BosTokenValue:=TPinja.TValue.From('');
   end;
  end;
  Context.SetVariable('bos_token',BosTokenValue);
  
  if length(aInputs.EosToken)>0 then begin
   EosTokenValue:=TPinja.TValue.From(aInputs.EosToken);
  end else begin
   if TPinjaChatTemplateOption.UseEosToken in aOptions then begin
    EosTokenValue:=TPinja.TValue.From(fEosToken);
   end else begin
    EosTokenValue:=TPinja.TValue.From('');
   end;
  end;
  Context.SetVariable('eos_token',EosTokenValue);

//Context.SetVariable('date_string',TPinja.TValue.From(ConvertStrftimeFormat('%d %b %Y',Now)));

  // Add extra context variables
  if assigned(aInputs.ExtraContext) then begin
   if aInputs.ExtraContext is TPasJSONItemObject then begin
    for Index:=0 to TPasJSONItemObject(aInputs.ExtraContext).Count-1 do begin
     PropertyKey:=TPasJSONItemObject(aInputs.ExtraContext).Keys[Index];
     PropertyValue:=TPinja.TValue.From(TPasJSONItemObject(aInputs.ExtraContext).Values[Index]);
     Context.SetVariable(PropertyKey,PropertyValue);
    end;
   end;
  end;
  
  // Define strftime_now function if requested
  if TPinjaChatTemplateOption.DefineStrftimeNow in aOptions then begin
   Context.RegisterCallable('strftime_now',@StrftimeNowCallable);
  end;
  
  // Render the template
  result:=fPinjaTemplate.RenderToString(Context);
  
 finally
  FreeAndNil(Context);
  // Only free ActualMessages if we created a new one via polyfills
  if NeedsPolyfills and assigned(ActualMessages) and (ActualMessages<>aInputs.Messages) then begin
   FreeAndNil(ActualMessages);
  end;
 end;
end;

function TPinjaChatTemplate.ApplyMessagePolyfills(const aMessage:TPasJSONItemObject;aPolyfillSystemRole,aPolyfillToolCalls,aPolyfillToolResponses,aPolyfillObjectArguments,aPolyfillTypedContent:Boolean;var aPendingSystem:TPinjaRawByteString):TPasJSONItem;
var ProcessedMessage:TPasJSONItemObject;
    MessageRole:TPinjaRawByteString;
    MessageContent:TPinjaRawByteString;
    ToolCalls:TPasJSONItemArray;
    ToolCall:TPasJSONItem;
    ToolCallObj:TPasJSONItemObject;
    ToolCallFunc:TPasJSONItemObject;
    Arguments:TPasJSONItem;
    ArgumentsStr:TPinjaRawByteString;
    ToolCallsContent:TPasJSONItemObject;
    ToolCallsArray:TPasJSONItemArray;
    ToolCallInfo:TPasJSONItemObject;
    ToolResponseContent:TPasJSONItemObject;
    TypedContentArray:TPasJSONItemArray;
    TextContentObj:TPasJSONItemObject;
    Index:TPinjaInt32;
begin

 if not assigned(aMessage) then begin
  result:=nil;
  exit;
 end;

 // If no polyfills are actually needed, just return a copy of the original message
 if not (aPolyfillSystemRole or aPolyfillToolCalls or aPolyfillToolResponses or aPolyfillObjectArguments or aPolyfillTypedContent) then begin
  result:=aMessage.Clone;
  exit;
 end;

 ProcessedMessage:=TPasJSONItemObject.Create;
 try
  // Copy basic message structure
  if assigned(aMessage.Properties['role']) and (aMessage.Properties['role'] is TPasJSONItemString) then begin
   MessageRole:=TPasJSONItemString(aMessage.Properties['role']).Value;
   ProcessedMessage.Add('role',TPasJSONItemString.Create(MessageRole));
  end else begin
   // Invalid message
   FreeAndNil(ProcessedMessage);
   exit;
  end;
  
  // Handle tool calls polyfill
  if assigned(aMessage.Properties['tool_calls']) and not (aMessage.Properties['tool_calls'] is TPasJSONItemNull) then begin
   if aPolyfillObjectArguments or aPolyfillToolCalls then begin
    ToolCalls:=TPasJSONItemArray(aMessage.Properties['tool_calls']);
    
    // Process tool calls to fix arguments format
    for Index:=0 to ToolCalls.Count-1 do begin
     ToolCall:=ToolCalls.Items[Index];
     if assigned(ToolCall) and (ToolCall is TPasJSONItemObject) then begin
      ToolCallObj:=TPasJSONItemObject(ToolCall);
      if assigned(ToolCallObj.Properties['function']) and (ToolCallObj.Properties['function'] is TPasJSONItemObject) then begin
       ToolCallFunc:=TPasJSONItemObject(ToolCallObj.Properties['function']);
       if assigned(ToolCallFunc.Properties['arguments']) then begin
        Arguments:=ToolCallFunc.Properties['arguments'];
        if (Arguments is TPasJSONItemString) and aPolyfillObjectArguments then begin
         // Convert string arguments to object
         ArgumentsStr:=TPasJSONItemString(Arguments).Value;
         try
          Arguments:=TPasJSON.Parse(ArgumentsStr);
          ToolCallFunc.Properties['arguments']:=Arguments;
         except
          // Keep as string if parsing fails
         end;
        end;
       end;
      end;
     end;
    end;
    
    if aPolyfillToolCalls then begin
     // Convert tool_calls to content string
     ToolCallsArray:=TPasJSONItemArray.Create;
     for Index:=0 to ToolCalls.Count-1 do begin
      ToolCall:=ToolCalls.Items[Index];
      if assigned(ToolCall) and (ToolCall is TPasJSONItemObject) then begin
       ToolCallObj:=TPasJSONItemObject(ToolCall);
       if assigned(ToolCallObj.Properties['type']) and (TPasJSONItemString(ToolCallObj.Properties['type']).Value='function') then begin
        if assigned(ToolCallObj.Properties['function']) and (ToolCallObj.Properties['function'] is TPasJSONItemObject) then begin
         ToolCallFunc:=TPasJSONItemObject(ToolCallObj.Properties['function']);
         ToolCallInfo:=TPasJSONItemObject.Create;
         if assigned(ToolCallFunc.Properties['name']) then begin
          ToolCallInfo.Add('name',ToolCallFunc.Properties['name'].Clone);
         end;
         if assigned(ToolCallFunc.Properties['arguments']) then begin
          ToolCallInfo.Add('arguments',ToolCallFunc.Properties['arguments'].Clone);
         end;
         if assigned(ToolCallObj.Properties['id']) then begin
          ToolCallInfo.Add('id',ToolCallObj.Properties['id'].Clone);
         end;
         ToolCallsArray.Add(ToolCallInfo);
        end;
       end;
      end;
     end;
     
     ToolCallsContent:=TPasJSONItemObject.Create;
     ToolCallsContent.Add('tool_calls',ToolCallsArray);
     
     // Add existing content if present
     if assigned(aMessage.Properties['content']) and not (aMessage.Properties['content'] is TPasJSONItemNull) then begin
      MessageContent:=TPinja.TValue.From(aMessage.Properties['content']).AsString;
      if MessageContent<>'' then begin
       ToolCallsContent.Add('content',TPasJSONItemString.Create(MessageContent));
      end;
     end;
     
     ProcessedMessage.Add('content',TPasJSONItemString.Create(TPinja.TValue.From(ToolCallsContent).AsString));
    end else begin
     // Keep tool_calls as-is
     ProcessedMessage.Add('tool_calls',aMessage.Properties['tool_calls'].Clone);
    end;
   end else begin
    // Keep tool_calls as-is
    ProcessedMessage.Add('tool_calls',aMessage.Properties['tool_calls'].Clone);
   end;
  end;
  
  // Handle tool response polyfill
  if aPolyfillToolResponses and (MessageRole='tool') then begin
   ProcessedMessage.Properties['role']:=TPasJSONItemString.Create('user');
   
   ToolResponseContent:=TPasJSONItemObject.Create;
   ToolResponseContent.Add('tool_response',TPasJSONItemObject.Create);
   
   if assigned(aMessage.Properties['name']) then begin
    TPasJSONItemObject(ToolResponseContent.Properties['tool_response']).Add('tool',aMessage.Properties['name'].Clone);
   end;
   if assigned(aMessage.Properties['content']) then begin
    TPasJSONItemObject(ToolResponseContent.Properties['tool_response']).Add('content',aMessage.Properties['content'].Clone);
   end;
   if assigned(aMessage.Properties['tool_call_id']) then begin
    TPasJSONItemObject(ToolResponseContent.Properties['tool_response']).Add('tool_call_id',aMessage.Properties['tool_call_id'].Clone);
   end;
   
   ProcessedMessage.Add('content',TPasJSONItemString.Create(TPinja.TValue.From(ToolResponseContent).AsString));
  end;
  
  // Handle content (if not already processed)
  if not assigned(ProcessedMessage.Properties['content']) and assigned(aMessage.Properties['content']) then begin
   if aPolyfillTypedContent and (aMessage.Properties['content'] is TPasJSONItemString) then begin
    // Convert string content to typed content array
    TypedContentArray:=TPasJSONItemArray.Create;
    try
     TextContentObj:=TPasJSONItemObject.Create;
     try
      TextContentObj.Add('type',TPasJSONItemString.Create('text'));
      TextContentObj.Add('text',aMessage.Properties['content'].Clone);
     finally
      TypedContentArray.Add(TextContentObj);
     end;
    finally
     ProcessedMessage.Add('content',TypedContentArray);
    end;
   end else begin
    ProcessedMessage.Add('content',aMessage.Properties['content'].Clone);
   end;
  end;
  
  // Handle system role polyfill
  if aPolyfillSystemRole and assigned(ProcessedMessage.Properties['content']) and not (ProcessedMessage.Properties['content'] is TPasJSONItemNull) then begin
   MessageContent:=TPinja.TValue.From(ProcessedMessage.Properties['content']).AsString;
   if MessageRole='system' then begin
    // Accumulate system content
    if aPendingSystem<>'' then begin
     aPendingSystem:=aPendingSystem+#13#10;
    end;
    aPendingSystem:=aPendingSystem+MessageContent;
    // Don't return this message
    FreeAndNil(ProcessedMessage);
    exit;
   end else begin
    if MessageRole='user' then begin
     // Prepend pending system content to user message
     if aPendingSystem<>'' then begin
      if MessageContent<>'' then begin
       ProcessedMessage.Properties['content']:=TPasJSONItemString.Create(aPendingSystem+#13#10+MessageContent);
      end else begin
       ProcessedMessage.Properties['content']:=TPasJSONItemString.Create(aPendingSystem);
      end;
      aPendingSystem:='';
     end;
    end else begin
     // Flush any pending system content as separate user message
     if aPendingSystem<>'' then begin
      // This is complex - we need to return the pending system message first
      // For now, just prepend to current message content
      ProcessedMessage.Properties['content']:=TPasJSONItemString.Create(aPendingSystem+#13#10+MessageContent);
      aPendingSystem:='';
     end;
    end;
   end;
  end;
  
  // Copy any remaining properties that weren't handled
  if assigned(aMessage.Properties['name']) and not assigned(ProcessedMessage.Properties['name']) then begin
   ProcessedMessage.Add('name',aMessage.Properties['name'].Clone);
  end;
  if assigned(aMessage.Properties['tool_call_id']) and not assigned(ProcessedMessage.Properties['tool_call_id']) then begin
   ProcessedMessage.Add('tool_call_id',aMessage.Properties['tool_call_id'].Clone);
  end;
  
  result:=ProcessedMessage;
  ProcessedMessage:=nil; // Transfer ownership
  
 except
  FreeAndNil(ProcessedMessage);
  raise;
 end;
end;

class function TPinjaChatTemplate.AddSystem(const aMessages:TPasJSONItem;const aSystemPrompt:TPinjaChatTemplateRawByteString):TPasJSONItem;
var MessagesArray:TPasJSONItemArray;
    SystemMsg:TPasJSONItemObject;
    ExistingSystemMsg:TPasJSONItemObject;
    ExistingContent:TPinjaRawByteString;
    Index:TPinjaInt32;
    CopiedMsg:TPasJSONItem;
begin
 result:=nil;
 
 if not (aMessages is TPasJSONItemArray) then begin
  exit;
 end;
 
 MessagesArray:=TPasJSONItemArray.Create;
 try
  // Check if first message is already a system message
  if (TPasJSONItemArray(aMessages).Count>0) and 
     (TPasJSONItemArray(aMessages).Items[0] is TPasJSONItemObject) then begin
   ExistingSystemMsg:=TPasJSONItemObject(TPasJSONItemArray(aMessages).Items[0]);
   if assigned(ExistingSystemMsg.Properties['role']) and
      (ExistingSystemMsg.Properties['role'] is TPasJSONItemString) and
      (TPasJSONItemString(ExistingSystemMsg.Properties['role']).Value='system') then begin
    // First message is system message - create new one with appended content
    SystemMsg:=TPasJSONItemObject.Create;
    try
     SystemMsg.Add('role',TPasJSONItemString.Create('system'));
     if assigned(ExistingSystemMsg.Properties['content']) and
        (ExistingSystemMsg.Properties['content'] is TPasJSONItemString) then begin
      ExistingContent:=TPasJSONItemString(ExistingSystemMsg.Properties['content']).Value;
      SystemMsg.Add('content',TPasJSONItemString.Create(ExistingContent+#13#10#13#10+aSystemPrompt));
     end else begin
      SystemMsg.Add('content',TPasJSONItemString.Create(aSystemPrompt));
     end;
    finally
     MessagesArray.Add(SystemMsg);
    end;

    // Copy remaining messages (skip first)
    for Index:=1 to TPasJSONItemArray(aMessages).Count-1 do begin
     CopiedMsg:=TPasJSONItemArray(aMessages).Items[Index].Clone;
     MessagesArray.Add(CopiedMsg);
    end;
   end else begin
    // First message is not system - insert new system message at beginning
    SystemMsg:=TPasJSONItemObject.Create;
    SystemMsg.Add('role',TPasJSONItemString.Create('system'));
    SystemMsg.Add('content',TPasJSONItemString.Create(aSystemPrompt));
    MessagesArray.Add(SystemMsg);
    
    // Copy all original messages
    for Index:=0 to TPasJSONItemArray(aMessages).Count-1 do begin
     CopiedMsg:=TPasJSONItemArray(aMessages).Items[Index].Clone;
     MessagesArray.Add(CopiedMsg);
    end;
   end;
  end else begin
   // No messages or first is not object - create new system message
   SystemMsg:=TPasJSONItemObject.Create;
   SystemMsg.Add('role',TPasJSONItemString.Create('system'));
   SystemMsg.Add('content',TPasJSONItemString.Create(aSystemPrompt));
   MessagesArray.Add(SystemMsg);
   
   // Copy all original messages
   for Index:=0 to TPasJSONItemArray(aMessages).Count-1 do begin
    CopiedMsg:=TPasJSONItemArray(aMessages).Items[Index].Clone;
    MessagesArray.Add(CopiedMsg);
   end;
  end;
  
  result:=MessagesArray;
 except
  FreeAndNil(MessagesArray);
  raise;
 end;
end;

function TPinjaChatTemplate.ContainsMessagesLoop:Boolean;
begin
 result:=false;
 
 if not assigned(fPinjaTemplate) then begin
  exit;
 end;
 
 // Access the AST root and scan for for-loops over 'messages'
 result:=ScanNodeForMessagesLoop(fPinjaTemplate.Root);
end;

function TPinjaChatTemplate.ScanNodeForMessagesLoop(const aNode:TPinja.TNodeStatement):Boolean;
var ForNode:TPinja.TNodeStatementFor;
    BlockNode:TPinja.TNodeStatementBlock;
    IfNode:TPinja.TNodeStatementIf;
    FilterNode:TPinja.TNodeStatementFilterBlock;
    MacroNode:TPinja.TNodeStatementMacroDefinition;
    CallNode:TPinja.TNodeStatementCall;
    GenerationNode:TPinja.TNodeStatementGeneration;
    SetBlockNode:TPinja.TNodeStatementSetBlock;
    Variable:TPinja.TNodeExpressionVariable;
    Index:TPinjaInt32;
    ChildNode:TPinja.TNodeStatement;
    ChildBlock:TPinja.TNodeStatementBlock;
begin
 result:=false;
 
 if not assigned(aNode) then begin
  exit;
 end;
 
 // Check if this node is a for-loop and scan for 'messages' iteration
 if aNode is TPinja.TNodeStatementFor then begin
  ForNode:=TPinja.TNodeStatementFor(aNode);
  // Check if the iterable is a variable named 'messages'
  if assigned(ForNode.Iterable) and (ForNode.Iterable is TPinja.TNodeExpressionVariable) then begin
   Variable:=TPinja.TNodeExpressionVariable(ForNode.Iterable);
   if Variable.Name='messages' then begin
    result:=true;
    exit;
   end;
  end;
  // Also scan the for-loop body for nested messages loops
  if assigned(ForNode.Body) and ScanNodeForMessagesLoop(ForNode.Body) then begin
   result:=true;
   exit;
  end;
 end else if aNode is TPinja.TNodeStatementBlock then begin
  // Scan block nodes (containers of multiple statements)
  BlockNode:=TPinja.TNodeStatementBlock(aNode);
  for Index:=0 to BlockNode.Items.Count-1 do begin
   ChildNode:=TPinja.TNodeStatement(BlockNode.Items.Items[Index]);
   if ScanNodeForMessagesLoop(ChildNode) then begin
    result:=true;
    exit;
   end;
  end;
 end else if aNode is TPinja.TNodeStatementIf then begin
  // Scan if/elif/else constructs
  IfNode:=TPinja.TNodeStatementIf(aNode);
  // Scan all if/elif branches
  for Index:=0 to IfNode.Bodies.Count-1 do begin
   ChildBlock:=TPinja.TNodeStatementBlock(IfNode.Bodies.Items[Index]);
   if assigned(ChildBlock) and ScanNodeForMessagesLoop(ChildBlock) then begin
    result:=true;
    exit;
   end;
  end;
  // Scan else branch
  if assigned(IfNode.ElseBody) and ScanNodeForMessagesLoop(IfNode.ElseBody) then begin
   result:=true;
   exit;
  end;
 end else if aNode is TPinja.TNodeStatementFilterBlock then begin
  // Scan filter blocks: {% filter ... %}...{% endfilter %}
  FilterNode:=TPinja.TNodeStatementFilterBlock(aNode);
  if assigned(FilterNode.Body) and ScanNodeForMessagesLoop(FilterNode.Body) then begin
   result:=true;
   exit;
  end;
 end else if aNode is TPinja.TNodeStatementMacroDefinition then begin
  // Scan macro definitions: {% macro ... %}...{% endmacro %}
  MacroNode:=TPinja.TNodeStatementMacroDefinition(aNode);
  if assigned(MacroNode.Body) and ScanNodeForMessagesLoop(MacroNode.Body) then begin
   result:=true;
   exit;
  end;
 end else if aNode is TPinja.TNodeStatementCall then begin
  // Scan call blocks: {% call ... %}...{% endcall %}
  CallNode:=TPinja.TNodeStatementCall(aNode);
  if assigned(CallNode.Body) and ScanNodeForMessagesLoop(CallNode.Body) then begin
   result:=true;
   exit;
  end;
 end else if aNode is TPinja.TNodeStatementGeneration then begin
  // Scan generation blocks: {% generation %}...{% endgeneration %}
  GenerationNode:=TPinja.TNodeStatementGeneration(aNode);
  if assigned(GenerationNode.Body) and ScanNodeForMessagesLoop(GenerationNode.Body) then begin
   result:=true;
   exit;
  end;
 end else if aNode is TPinja.TNodeStatementSetBlock then begin
  // Scan set blocks: {% set %}...{% endset %}
  SetBlockNode:=TPinja.TNodeStatementSetBlock(aNode);
  if assigned(SetBlockNode.Body) and ScanNodeForMessagesLoop(SetBlockNode.Body) then begin
   result:=true;
   exit;
  end;
 end;
 
 // Other node types (TNodeStatementText, TNodeStatementExpression, TNodeStatementSet, 
 // TNodeStatementBreak, TNodeStatementContinue) don't contain child blocks

end;

end.
