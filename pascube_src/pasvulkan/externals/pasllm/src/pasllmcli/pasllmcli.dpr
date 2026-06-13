program pasllmcli;
{$ifdef fpc}
 {$mode delphi}
{$endif}
{$ifdef win32}
 {$apptype console}
{$endif}
{$ifdef win64}
 {$apptype console}
{$endif}
{$scopedenums on}

uses
{$ifdef fpc}
{$ifdef unix}
  cmem,
  cthreads,
{$endif}
{$endif}
  SysUtils,
  Classes,
  PasMP,
  PasJSON,
  PasLLM,
  Pinja;

type { TPasLLMCLIInstance }
     TPasLLMCLIInstance=class
      public
       type TArgument=record
             Name:TPasLLMUTF8String;
             Value:TPasLLMUTF8String;
            end;
            PArgument=^TArgument;
            TArguments=array of TArgument;
            TMode=
             (
              None,
              Chat,
              Generate,
              Study
             );
      private
       fArguments:TArguments;
       fPasMPInstance:TPasMP;
       fPasLLMInstance:TPasLLM;  
       fPasLLMModel:TPasLLMModel;
       fPasLLMModelInferenceInstance:TPasLLMModelInferenceInstance;
       fChatSession:TPasLLMModelInferenceInstance.TChatSession;
       fMode:TMode;
       fTavilyKey:TPasLLMUTF8String;
       fModel:TPasLLMUTF8String;
       fSystemPrompt:TPasLLMUTF8String;
       fPrompt:TPasLLMUTF8String;
       fQuitAfterPrompt:Boolean;
       fTools:Boolean;
       fTemperature:TPasLLMDouble;
       fTopP:TPasLLMDouble;
       fSeed:TPasLLMUInt64;
       fPenaltyLastN:TPasLLMSizeInt;
       fPenaltyRepeat:TPasLLMDouble;
       fPenaltyFrequency:TPasLLMDouble;
       fPenaltyPresence:TPasLLMDouble;
       fPath:TPasLLMUTF8String;
       fSteps:TPasLLMSizeInt;
       fContextSize:TPasLLMSizeInt;
       function DefaultOnInput(const aSender:TPasLLMModelInferenceInstance.TChatSession;const aPrompt:TPasLLMUTF8String):TPasLLMUTF8String;
       procedure DefaultOnSideTurn(const aSender:TPasLLMModelInferenceInstance.TChatSession;const aSide:TPasLLMUTF8String);
       procedure ParseArguments;
       procedure LoadToolConfiguration;
      public
       constructor Create;
       destructor Destroy; override;
       procedure Run;
     end;

constructor TPasLLMCLIInstance.Create;
var TestModel:TPasLLMUTF8String;
begin
 inherited Create;
 fPasMPInstance:=TPasMP.CreateGlobalInstance;
 fMode:=TMode.None;
 fTavilyKey:='';
 fModel:='';
 fSystemPrompt:='';
 fPrompt:='';
 fQuitAfterPrompt:=false;
 fTools:=false;
 fTemperature:=0.6;
 fTopP:=0.9;
 fSeed:=0;
 fPenaltyLastN:=0;
 fPenaltyRepeat:=1.0;
 fPenaltyFrequency:=0.0;
 fPenaltyPresence:=0.0;
 fPath:='';
 fSteps:=0;
 fContextSize:=4096;
 ParseArguments;
 if length(fModel)=0 then begin
// fModel:='qwen2.5_0.5b_instruct_q80.safetensors';
  fModel:='llama32_1b_instruct_abliterated_q40nl.safetensors';
//fModel:='qwen3_4b_instruct_q40nl.safetensors';
 end;
 if not FileExists(fModel) then begin
  TestModel:=IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+fModel;
  if FileExists(TestModel) then begin
   fModel:=TestModel;
  end else begin
   TestModel:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'models')+fModel;
   if FileExists(TestModel) then begin
    fModel:=TestModel;
   end else begin
    raise Exception.Create('Model file not found: '+ExtractFileName(fModel));
   end;
  end;
 end;
 if fSteps<=0 then begin
  fSteps:=0;
 end;
 if fMode=TMode.None then begin
  fMode:=TMode.Chat;
 end;
end;

destructor TPasLLMCLIInstance.Destroy;
begin
 inherited Destroy;
end;

procedure TPasLLMCLIInstance.ParseArguments;
var Index,Count,ArgumentIndex,SplitterPosition:TPasLLMSizeInt;
    Code:TPasLLMInt32;
    Argument:PArgument;
    ArgumentString,Name,Value:TPasLLMUTF8String;
    StringList,OtherStringList:TStringList;
begin

 // Read arguments from command line, files or standard input
 Count:=0;
 fArguments:=nil;
 try
  StringList:=TStringList.Create;
  try
   Index:=1;
   while Index<=ParamCount do begin
    ArgumentString:=Trim(ParamStr(Index));
    if length(ArgumentString)>0 then begin
     if (ArgumentString[1]='@') then begin
      ArgumentString:=Copy(ArgumentString,2,length(ArgumentString)-1);
      if (ArgumentString='-') or FileExists(ArgumentString) then begin
       OtherStringList:=TStringList.Create;
       try
        if ArgumentString='-'  then begin         
         // Load arguments from standard input until empty line or EOF
         while not EOF do begin
          ReadLn(ArgumentString);
          ArgumentString:=Trim(ArgumentString);
          if length(ArgumentString)=0 then begin
           break;
          end;
          OtherStringList.Add(ArgumentString);
         end;
        end else begin 
         // Load arguments from file
         OtherStringList.LoadFromFile(ArgumentString);
        end;
        StringList.AddStrings(OtherStringList);
       finally
        FreeAndNil(OtherStringList);
       end;
      end;
     end else begin
      StringList.Add(ArgumentString);
     end;
    end;
    inc(Index);
   end;
 { StringList.TextLineBreakStyle:=tlbsLF;
   StringList.StrictDelimiter:=true;
   StringList.Delimiter:=' ';}
   for Index:=0 to StringList.Count-1 do begin
    ArgumentString:=Trim(StringList[Index]);
    if length(ArgumentString)>0 then begin
     if (ArgumentString[1]='-') or (ArgumentString[1]='/') then begin
      ArgumentString:=Copy(ArgumentString,2,length(ArgumentString)-1);
      if (ArgumentString[1]='-') or (ArgumentString[1]='/') then begin
       ArgumentString:=Copy(ArgumentString,2,length(ArgumentString)-1);
      end;
      SplitterPosition:=Pos('=',ArgumentString);
      if SplitterPosition>0 then begin
       Name:=Trim(Copy(ArgumentString,1,SplitterPosition-1));
       Value:=Trim(Copy(ArgumentString,SplitterPosition+1,length(ArgumentString)-SplitterPosition));
       if (length(Value)>1) and (Value[1]='"') and (Value[length(Value)]='"') then begin
        Value:=Trim(Copy(Value,2,length(Value)-2));
       end;
      end else begin
       Name:=Trim(ArgumentString);
       Value:='';
      end;
      ArgumentIndex:=Count;
      inc(Count);
      if length(fArguments)<Count then begin
       SetLength(fArguments,Count*2);
      end;
      Argument:=@fArguments[ArgumentIndex];
      Argument^.Name:=Name;
      Argument^.Value:=Value;
     end else begin
      if fMode=TMode.None then begin
       // Mode
       Name:=LowerCase(ArgumentString);
       if Name='chat' then begin
        fMode:=TMode.Chat;
       end else if Name='generate' then begin
        fMode:=TMode.Generate;
       end else if Name='study' then begin
        fMode:=TMode.Study;
       end else begin
        fMode:=TMode.Chat; // Default to chat
       end;
      end else begin
       // Prompt
       if length(fPrompt)>0 then begin
        fPrompt:=fPrompt+' '+ArgumentString;
       end else begin
        fPrompt:=ArgumentString;
       end;
      end;
     end;
    end;
   end;
  finally
   FreeAndNil(StringList);
  end;
 finally
  SetLength(fArguments,Count);
 end;

 // Process arguments
 for Index:=0 to Count-1 do begin
  Argument:=@fArguments[Index];
  if Argument^.Name='model' then begin
   fModel:=Argument^.Value;
  end else if Argument^.Name='steps' then begin
   fSteps:=StrToIntDef(Argument^.Value,0);
  end else if Argument^.Name='context-size' then begin
   fContextSize:=StrToIntDef(Argument^.Value,4096); 
  end else if Argument^.Name='tavily-key' then begin
   fTavilyKey:=Argument^.Value;
  end else if Argument^.Name='system-prompt' then begin
   fSystemPrompt:=Argument^.Value;
  end else if Argument^.Name='prompt' then begin
   fPrompt:=Argument^.Value;
  end else if Argument^.Name='quit-after-prompt' then begin
   fQuitAfterPrompt:=(Argument^.Value='1') or (LowerCase(Argument^.Value)='true') or (length(Argument^.Value)=0);
  end else if Argument^.Name='tools' then begin
   fTools:=(Argument^.Value='1') or (LowerCase(Argument^.Value)='true') or (length(Argument^.Value)=0); 
  end else if Argument^.Name='temperature' then begin
   Val(Argument^.Value,fTemperature,Code);
   if Code=0 then begin
    if fTemperature<0 then begin
     fTemperature:=0;
    end else if fTemperature>1 then begin
     fTemperature:=1;
    end;
   end else begin
    fTemperature:=0.6;
   end;
  end else if Argument^.Name='top-p' then begin
   Val(Argument^.Value,fTopP,Code);
   if Code=0 then begin
    if fTopP<0 then begin
     fTopP:=0;
    end else if fTopP>1 then begin
     fTopP:=1;
    end;
   end else begin
    fTopP:=0.9;
   end;
  end else if Argument^.Name='seed' then begin
   fSeed:=StrToUInt64Def(Argument^.Value,0); 
  end else if Argument^.Name='penalty-last-n' then begin
   fPenaltyLastN:=StrToIntDef(Argument^.Value,0);
   if fPenaltyLastN<0 then begin
    fPenaltyLastN:=0;
   end;
  end else if Argument^.Name='penalty-repeat' then begin
   Val(Argument^.Value,fPenaltyRepeat,Code);
   if Code<>0 then begin
    fPenaltyRepeat:=1.0;
   end;
   if fPenaltyRepeat<0.0 then begin
    fPenaltyRepeat:=0.0;
   end;
  end else if Argument^.Name='penalty-frequency' then begin
   Val(Argument^.Value,fPenaltyFrequency,Code);
   if Code<>0 then begin
    fPenaltyFrequency:=0.0;
   end;
   if fPenaltyFrequency<0.0 then begin
    fPenaltyFrequency:=0.0;
   end;
  end else if Argument^.Name='penalty-presence' then begin 
   Val(Argument^.Value,fPenaltyPresence,Code);
   if Code<>0 then begin
    fPenaltyPresence:=0.0;
   end;
   if fPenaltyPresence<0.0 then begin
    fPenaltyPresence:=0.0;
   end;
  end else if Argument^.Name='path' then begin
   fPath:=Argument^.Value;
  end else if (Argument^.Name='help') or (Argument^.Name='h') or (Argument^.Name='?') then begin
   Writeln('PasLLM Command Line Interface');
   Writeln('Usage: pasllmcli [options] [mode] ([prompt])');
   Writeln('Modes:');
   Writeln('  chat                      Start an interactive chat session (default)');
   Writeln('  generate                  Generate text from a prompt');
   Writeln('  study                     Study text files in a directory');
   Writeln('Options:');
   Writeln('  -model=FILE               Model file to use');
   Writeln('  -steps=N                  Number of steps/tokens to generate (default: 0 = until end)');
   Writeln('  -context-size=N           Context size in tokens (default: 4096)');
   Writeln('  -tavily-key=KEY           Tavily API key for web search tool');
   Writeln('  -system-prompt=TEXT       System prompt for chat mode (default: "You are a helpful assistant.")');
   Writeln('  -prompt=TEXT              Prompt for generate mode or initial prompt for chat mode');
   Writeln('  -quit-after-prompt        Quit after initial prompt in chat mode');
   Writeln('  -tools                    Enable tools in chat mode (default: disabled, when enabled, tools.json is used if present)');
   Writeln('  -temperature=FLOAT        Sampling temperature (0.0 to 1.0, default: 0.6)');
   Writeln('  -top-p=FLOAT              Top-p sampling (0.0 to 1.0, default: 0.9)');
   Writeln('  -seed=N                   Random seed (default: 0 = random)');
   Writeln('  -penalty-last-n=N         Penalty last N tokens (default: 0 = disabled)');
   Writeln('  -penalty-repeat=FLOAT     Penalty repeat factor (default: 1.0)');
   Writeln('  -penalty-frequency=FLOAT  Penalty frequency factor (default: 0.0)');
   Writeln('  -penalty-presence=FLOAT   Penalty presence factor (default: 0.0)');
   Writeln('  -path=DIR                 File path for study mode');
   Writeln('  -help / -h / -?           Show this help message');
   Halt(0);
  end;
  // Add more arguments here as needed
 end;

end;
 
procedure TPasLLMCLIInstance.LoadToolConfiguration;
var JSONFileName:TPasLLMUTF8String;
    JSONStream:TMemoryStream;
    JSONContentItem,JSONItem:TPasJSONItem;
begin
 JSONFileName:=IncludeTrailingPathDelimiter(ExtractFilePath(ChangeFileExt(ParamStr(0),'')))+'tools.json';
{if not FileExists(JSONFileName) then begin
  JSONFileName:=GetAppDataLocalStoragePath(ChangeFileExt(ParamStr(0),''))+'tools.json';
 end;}
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
       fChatSession.LoadMCPServersFromJSON(JSONItem);
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

function TPasLLMCLIInstance.DefaultOnInput(const aSender:TPasLLMModelInferenceInstance.TChatSession;const aPrompt:TPasLLMUTF8String):TPasLLMUTF8String;
begin
 if length(fPrompt)>0 then begin
  result:=fPrompt;
  fPrompt:='';
 end else if fQuitAfterPrompt then begin
  result:='/quit';
 end else begin
  Write(aPrompt);
  ReadLn(result);
 end;
end;

procedure TPasLLMCLIInstance.DefaultOnSideTurn(const aSender:TPasLLMModelInferenceInstance.TChatSession;const aSide:TPasLLMUTF8String);
begin

end;

procedure TPasLLMCLIInstance.Run;
begin
 fPasLLMInstance:=TPasLLM.Create(fPasMPInstance);
 try

  if fContextSize=0 then begin
   fContextSize:=High(TPasLLMInt32);
  end;

  fPasLLMModel:=TPasLLMModel.Create(fPasLLMInstance,fModel,fContextSize);
  try

   fPasLLMModel.Configuration.PenaltyLastN:=fPenaltyLastN;
   fPasLLMModel.Configuration.PenaltyRepeat:=fPenaltyRepeat;
   fPasLLMModel.Configuration.PenaltyFrequency:=fPenaltyFrequency;
   fPasLLMModel.Configuration.PenaltyPresence:=fPenaltyPresence;

   fPasLLMModelInferenceInstance:=TPasLLMModelInferenceInstance.Create(fPasLLMModel,fSeed);
   try

    fPasLLMModelInferenceInstance.Temperature:=fTemperature;
    fPasLLMModelInferenceInstance.TopP:=fTopP;

    case fMode of
     TMode.Chat:begin

      fChatSession:=fPasLLMModelInferenceInstance.CreateChatSession;
      try
       fChatSession.OnInput:=DefaultOnInput;
       fChatSession.ToolsEnabled:=fTools;
       if fChatSession.ToolsEnabled then begin
        LoadToolConfiguration;
        fChatSession.TavilyKey:=fTavilyKey;
        fChatSession.AddDefaultTools;
       end;
       fChatSession.State:=TPasLLMModelInferenceInstance.TChatSession.TState.UserInput;
       if length(fSystemPrompt)>0 then begin
        fChatSession.SetSystemPrompt(fSystemPrompt);
        fChatSession.State:=TPasLLMModelInferenceInstance.TChatSession.TState.Initial;
       end;
       if fQuitAfterPrompt and (length(fPrompt)>0) then begin
        fChatSession.OnSideTurn:=DefaultOnSideTurn;
       end;
       fChatSession.Run;
      finally
       FreeAndNil(fChatSession);
      end;

     end;
     TMode.Generate:begin
      if length(fPrompt)=0 then begin
       ReadLn(fPrompt);
      end;
      fPrompt:=Trim(fPrompt);
      if length(fPrompt)>0 then begin
       fPasLLMModelInferenceInstance.Generate(fPrompt,fSteps);
      end;
     end;
     TMode.Study:begin
      fPath:=Trim(fPath);
      if length(fPath)>0 then begin
       fPasLLMModelInferenceInstance.Study(fPath,fSteps);
      end;
     end;
     else begin
      raise Exception.Create('Invalid mode');
     end;
    end;

   finally
    FreeAndNil(fPasLLMModelInferenceInstance);
   end;

  finally
   FreeAndNil(fPasLLMModel);
  end;

 finally
  FreeAndNil(fPasLLMInstance);
 end;
end;

var PasLLMCLIInstance:TPasLLMCLIInstance;
begin

 PasLLMCLIInstance:=TPasLLMCLIInstance.Create;
 try
  PasLLMCLIInstance.Run;
 finally
  FreeAndNil(PasLLMCLIInstance);
 end;

end.
