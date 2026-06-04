unit UnitOpenGLShader;
{$ifdef fpc}
 {$mode delphi}
 {$ifdef cpui386}
  {$define cpu386}
 {$endif}
 {$ifdef cpuamd64}
  {$define cpux86_64}
 {$endif}
 {$ifdef cpu386}
  {$define cpux86}
  {$define cpu32}
  {$asmmode intel}
 {$endif}
 {$ifdef cpux86_64}
  {$define cpux64}
  {$define cpu64}
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
 {$define caninline}
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
 {$if declared(RawByteString)}
  {$define HAS_TYPE_RAWBYTESTRING}
 {$else}
  {$undef HAS_TYPE_RAWBYTESTRING}
 {$ifend}
 {$if declared(UTF8String)}
  {$define HAS_TYPE_UTF8STRING}
 {$else}
  {$undef HAS_TYPE_UTF8STRING}
 {$ifend}
{$else}
 {$realcompatibility off}
 {$localsymbols on}
 {$define LITTLE_ENDIAN}
 {$ifndef cpu64}
  {$define cpu32}
 {$endif}
 {$ifdef cpux64}
  {$define cpux86_64}
  {$define cpu64}
 {$else}
  {$ifdef cpu386}
   {$define cpux86}
   {$define cpu32}
  {$endif}
 {$endif}
 {$define HAS_TYPE_EXTENDED}
 {$define HAS_TYPE_DOUBLE}
 {$ifdef conditionalexpressions}
  {$if declared(RawByteString)}
   {$define HAS_TYPE_RAWBYTESTRING}
  {$else}
   {$undef HAS_TYPE_RAWBYTESTRING}
  {$ifend}
  {$if declared(UTF8String)}
   {$define HAS_TYPE_UTF8STRING}
  {$else}
   {$undef HAS_TYPE_UTF8STRING}
  {$ifend}
 {$else}
  {$undef HAS_TYPE_RAWBYTESTRING}
  {$undef HAS_TYPE_UTF8STRING}
 {$endif}
{$endif}
{$ifdef win32}
 {$define windows}
{$endif}
{$ifdef win64}
 {$define windows}
{$endif}
{$ifdef wince}
 {$define windows}
{$endif}
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

interface

uses SysUtils,Classes,{$ifdef fpcgl}gl,glext{$else}dglOpenGL{$endif};

type EShaderException=class(Exception);

     TShader=class
      public
       ProgramHandle:glInt;
       FragmentShaderHandle:glInt;
       VertexShaderHandle:glInt;
       FragmentShader:RawByteString;
       VertexShader:RawByteString;
       constructor Create(const AVertexShader,AFragmentShader:RawByteString);
       destructor Destroy; override;
       procedure BindAttributes; virtual;
       procedure BindVariables; virtual;
       procedure BindLocations; virtual;
       procedure Bind; virtual;
       procedure Unbind; virtual;
     end;

implementation

constructor TShader.Create(const AVertexShader,AFragmentShader:RawByteString);
var Source:pointer;
    CompiledOrLinked,LogLength:glInt;
    LogString:RawByteString;
begin
 inherited Create;
 LogString:='';
 ProgramHandle:=-1;
 FragmentShaderHandle:=-1;
 VertexShaderHandle:=-1;
 try
  try

   FragmentShader:=AFragmentShader;
   VertexShader:=AVertexShader;

   Source:=@FragmentShader[1];
   FragmentShaderHandle:=glCreateShader(GL_FRAGMENT_SHADER);
   glShaderSource(FragmentShaderHandle,1,@Source,nil);
   glCompileShader(FragmentShaderHandle);
   glGetShaderiv(FragmentShaderHandle,GL_COMPILE_STATUS,@CompiledOrLinked);
   if CompiledOrLinked=0 then begin
    begin
     glGetShaderiv(FragmentShaderHandle,GL_INFO_LOG_LENGTH,@LogLength);
     SetLength(LogString,LogLength);
     glGetShaderInfoLog(FragmentShaderHandle,LogLength,@LogLength,@LogString[1]);
     if length(LogString)<>0 then begin
//      DoLog('Unable to compile fragment shader program: '+LogString);
//      Log.LogError(String('Unable to compile fragment shader program: '+LogString),'Main');
      raise EShaderException.Create(String('Unable to compile fragment shader program: '+LogString));
     end;
    end;
//    DoLog('Unable to compile fragment shader program: ');
    raise EShaderException.Create('Unable to compile fragment shader program');
   end;

   Source:=@VertexShader[1];
   VertexShaderHandle:=glCreateShader(GL_VERTEX_SHADER);
   glShaderSource(VertexShaderHandle,1,@Source,nil);
   glCompileShader(VertexShaderHandle);
   glGetShaderiv(VertexShaderHandle,GL_COMPILE_STATUS,@CompiledOrLinked);
   if CompiledOrLinked=0 then begin
    begin
     glGetShaderiv(VertexShaderHandle,GL_INFO_LOG_LENGTH,@LogLength);
     SetLength(LogString,LogLength);
     glGetShaderInfoLog(VertexShaderHandle,LogLength,@LogLength,@LogString[1]);
     if length(LogString)<>0 then begin
///      DoLog('Unable to compile vertex shader program: '+LogString);
//      Log.LogError(String('Unable to compile vertex shader program: '+LogString),'Main');
      raise EShaderException.Create(String('Unable to compile vertex shader program: '+LogString));
     end;
    end;
//    DoLog('Unable to compile vertex shader program');
    raise EShaderException.Create('Unable to compile vertex shader program');
   end;

   ProgramHandle:=glCreateProgram;
   glAttachShader(ProgramHandle,FragmentShaderHandle);
   glAttachShader(ProgramHandle,VertexShaderHandle);

   BindAttributes;

   glLinkProgram(ProgramHandle);
   glGetProgramiv(ProgramHandle,GL_LINK_STATUS,@CompiledOrLinked);
   if CompiledOrLinked=0 then begin
    begin
     glGetProgramiv(ProgramHandle,GL_INFO_LOG_LENGTH,@LogLength);
     SetLength(LogString,LogLength);
     glGetProgramInfoLog(ProgramHandle,LogLength,@LogLength,@LogString[1]);
     if length(LogString)<>0 then begin
///      DoLog('Unable to link shader: '+LogString);
//     Log.LogError(String('Unable to link shader: '+LogString),'Main');
      raise EShaderException.Create(String('Unable to link shader: '+LogString));
     end;
    end;
//    DoLog('Unable to link shader');
    raise EShaderException.Create('Unable to link shader');
   end;

   glUseProgram(ProgramHandle);
   BindVariables;
   BindLocations;
   glUseProgram(0);

  except
   FragmentShader:='';
   VertexShader:='';
   if ProgramHandle>=0 then begin
    glDeleteProgram(ProgramHandle);
    ProgramHandle:=-1;
   end;
   if VertexShaderHandle>=0 then begin
    glDeleteShader(VertexShaderHandle);
    VertexShaderHandle:=-1;
   end;
   if FragmentShaderHandle>=0 then begin
    glDeleteShader(FragmentShaderHandle);
    FragmentShaderHandle:=-1;
   end;
   raise;
  end;
 finally
  LogString:='';
 end;
end;

destructor TShader.Destroy;
begin
 FragmentShader:='';
 VertexShader:='';
 if ProgramHandle>=0 then begin
  glDeleteProgram(ProgramHandle);
  ProgramHandle:=-1;
 end;
 if VertexShaderHandle>=0 then begin
  glDeleteShader(VertexShaderHandle);
  VertexShaderHandle:=-1;
 end;
 if FragmentShaderHandle>=0 then begin
  glDeleteShader(FragmentShaderHandle);
  FragmentShaderHandle:=-1;
 end;
 inherited Destroy;
end;

procedure TShader.BindAttributes;
begin
end;

procedure TShader.BindVariables;
begin
end;

procedure TShader.BindLocations;
begin
end;

procedure TShader.Bind;
begin
 glUseProgram(ProgramHandle);
end;

procedure TShader.Unbind;
begin
 glUseProgram(0);
end;

end.

