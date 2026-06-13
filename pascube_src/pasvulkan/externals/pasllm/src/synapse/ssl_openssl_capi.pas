{==============================================================================|
| Project : Ararat Synapse                                       | 001.003.000 |
|==============================================================================|
| Content: SSL support by OpenSSL and the CAPI engine                          |
|==============================================================================|
| Copyright (c)2018, Pepak                                                     |
| All rights reserved.                                                         |
|                                                                              |
| Redistribution and use in source and binary forms, with or without           |
| modification, are permitted provided that the following conditions are met:  |
|                                                                              |
| Redistributions of source code must retain the above copyright notice, this  |
| list of conditions and the following disclaimer.                             |
|                                                                              |
| Redistributions in binary form must reproduce the above copyright notice,    |
| this list of conditions and the following disclaimer in the documentation    |
| and/or other materials provided with the distribution.                       |
|                                                                              |
| Neither the name of Lukas Gebauer nor the names of its contributors may      |
| be used to endorse or promote products derived from this software without    |
| specific prior written permission.                                           |
|                                                                              |
| THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"  |
| AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE    |
| IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE   |
| ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR  |
| ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL       |
| DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR   |
| SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER   |
| CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT           |
| LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY    |
| OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH  |
| DAMAGE.                                                                      |
|==============================================================================|
| The Initial Developer of the Original Code is Pepak (Czech Republic).        |
| Portions created by Pepak are Copyright (c)2018.                             |
| All Rights Reserved.                                                         |
|==============================================================================|
| Contributor(s):                                                              |
|==============================================================================|
| History: see HISTORY.HTM from distribution package                           |
|          (Found at URL: http://www.ararat.cz/synapse/)                       |
|==============================================================================}

//requires OpenSSL libraries, including the CAPI engine (capi.dll)!
//recommended source: Stunnel (https://www.stunnel.org)

{:@abstract(SSL plugin for OpenSSL and the CAPI engine)

Compatibility with OpenSSL versions:

1.0.2 works fine.

1.1.x does not work properly out of the box. I was never able to get CAPI
to work with pre-built binaries or binaries that I built myself, even in
third party applications such as STunnel. The only config which works for
me involves custom-building OpenSSL with engines statically compiled into
libcrypto:

   1) Install PERL (e.g. C:\PERL). Make sure the BIN subdirectory is in
      the PATH (SET PATH=%PATH%;C:\PERL\BIN).

   2) Download DMAKE ( https://metacpan.org/release/dmake ) and unpack it
      into the Perl directory (you will get C:\PERL\DMAKE\DMAKE.EXE and
      other files). Add the DMAKE directory to PATH as well.

   3) Start Visual Studio Development Prompt, either 32 or 64bit. All the
      following commands should be run in this prompt.

   4) Install the Text::Template module by running:
        cpan -i Text::Template

   5) Download and unpack the OpenSSL sources into e.g. C:\SOURCE\OPENSSL.

   6) Download and unpack the Zlib sources into e.g. C:\SOURCE\ZLIB.

   7) Go to the ZLIB directory and run:
        nmake -f win32/Makefile.msc

   8) Go to the OpenSSL directory and run:
        32bit:
          perl Configure shared enable-static-engine enable-zlib --with-zlib-include=C:\SOURCE\ZLIB --with-zlib-lib=C:\SOURCE\ZLIB\zlib.lib VC-WIN32
        64bit:
          perl Configure shared enable-static-engine enable-zlib --with-zlib-include=C:\SOURCE\ZLIB --with-zlib-lib=C:\SOURCE\ZLIB\zlib.lib VC-WIN64A
        Make sure to replace both instances of C:\SOURCE\ZLIB with the actual
        path to the Zlib library.

   9) If you want to build the OpenSSL DLLs without external dependencies
      (e.g. on the Visual Studio Runtime), edit the generated makefile:

      - Change the "/MD" flag in CNF_FLAGS to "/MT".
      - Add "/NODEFAULTLIB:MSVCRT" to CNF_LDFLAGS.

  10) In the OpenSSL directory, run:
        nmake

  11) When all is done, copy LIBCRYPTO-1_1*.DLL and LIBSSH-1_1*.DLL to
      your application's binary directory.


OpenSSL libraries are loaded dynamically - you do not need the librares even if
you compile your application with this unit. SSL just won't work if you don't
have the OpenSSL libraries.

The plugin is built on the standard OpenSSL plugin, giving it all the features
of it. In fact, if you do not have the CAPI engine, the plugin will behave in
exactly the same way as the original plugin - the CAPI engine is completely
optional, the plugin will work without it - obviously without the support for
Windows Certificate Stores.

The windows certificate stores are supported through the following properties:

@link(TSSLOpenSSLCapi.SigningCertificate) - expects pointer to the certificate
context of the signing certificate (PCCERT_CONTENT). @br

Note that due to the limitations of OpenSSL, it is not possible to switch
between different engines (e.g. CAPI and default) on the fly - the engine is
a global setting for the whole of OpenSSL. For that reason, once the engine
is enabled (either explicitly or by using a Windows certificate for a connection),
it will stay enabled and there is no method for disabling it.

}

{$INCLUDE 'jedi.inc'}
{$H+}

{$DEFINE USE_ENGINE_POOL}

unit ssl_openssl_capi;

interface

uses
  Windows, Crypt32, SysUtils, Classes, SyncObjs,
  blcksock, ssl_openssl, ssl_openssl_lib;

type
  PENGINE = Pointer;

type
  TWindowsCertStoreLocation = (
      wcslCurrentUser
    , wcslCurrentUserGroupPolicy
    , wcslUsers
    , wcslCurrentService
    , wcslServices
    , wcslLocalMachine
    , wcslLocalMachineGroupPolicy
    , wcslLocalMachineEnterprise
  );

type
  {:@abstract(class extending the OpenSSL SSL plugin with CAPI support.)
   Instance of this class will be created for each @link(TTCPBlockSocket).
   You not need to create instance of this class, all is done by Synapse itself!}
  TSSLOpenSSLCapi = class(TSSLOpenSSL)
  private
    FEngine: PENGINE;
    FEngineInitialized: boolean;
    FSigningCertificateLocation: TWindowsCertStoreLocation;
    FSigningCertificateStore: string;
    FSigningCertificateID: string;
    function GetEngine: PENGINE;
  protected
    {:Loads a certificate context into the CAPI engine for signing/decryption.}
    function LoadSigningCertificate: boolean;
    {:See @inherited}
    function SetSslKeys: boolean; override;
    {:See @inherited}
    function NeedSigningCertificate: boolean; override;
    {:Returns true if the signing certificate should be used.}
    function SigningCertificateSpecified: boolean;
    {:Provides a cryptographic engine for OpenSSL}
    property Engine: PENGINE read GetEngine;
  public
    {:See @inherited}
    constructor Create(const Value: TTCPBlockSocket); override;
    {:See @inherited}
    destructor Destroy; override;
    {:See @inherited}
    procedure Assign(const Value: TCustomSSL); override;
    {:Use this function to load the CAPI engine and/or verify that the engine
     is available. The plugin will load CAPI itself when it is needed, so you
     may skip this function completely, but it may be useful to perform a manual
     CAPI load early during the application startup to make sure all connection
     use the same cryptographic engine (and, as a result, behave the same way).}
    class function InitEngine: boolean;
    {:Location of the certificate store used for the communication.}
    property SigningCertificateLocation: TWindowsCertStoreLocation read FSigningCertificateLocation write FSigningCertificateLocation;
    {:Certificate store used for the communication. The most common is "MY",
     or the user's private certificates.}
    property SigningCertificateStore: string read FSigningCertificateStore write FSigningCertificateStore;
    {:ID of the certificate to use. For standard CAPI, this is the friendly name
     of the certificate. For the client-side SSL it is not really necessary, as
     long as it is non-empty (which signifies that the CAPI engine should be
     used). For the server side, it must be a substring of the SubjectName of
     the certificate. The first matching certificate will be used.}
    property SigningCertificateID: string read FSigningCertificateID write FSigningCertificateID;
  end;

implementation

{$IFDEF SUPPORTS_REGION}{$REGION 'Support and compatibility functions'}{$ENDIF}
{==============================================================================}
{Support and compatibility functions                                           }
{------------------------------------------------------------------------------}

function GetModuleFileNamePAS(Handle: THandle; out FileName: string): boolean;
var
  FN: string;
  n: integer;
begin
  Result := False;
  if Handle = 0 then
    Exit;
  SetLength(FN, MAX_PATH);
  n := GetModuleFileName(Handle, @FN[1], Length(FN));
  if (n > 0) and (GetLastError = ERROR_INSUFFICIENT_BUFFER) then
  begin
    SetLength(FN, n);
    n := GetModuleFileName(Handle, @FN[1], Length(FN));
  end;
  if (n > 0) and (GetLastError = ERROR_SUCCESS) then
  begin
    SetLength(FN, n);
    FileName := FN;
    Result := True;
  end;
end;

{$IFNDEF UNICODE}
type
  PPointer = ^Pointer;

procedure RaiseLastOSError;
begin
  RaiseLastWin32Error;
end;
{$ENDIF}

{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

{$IFDEF SUPPORTS_REGION}{$REGION 'Imported functions'}{$ENDIF}
{==============================================================================}
{Imported functions                                                            }
{------------------------------------------------------------------------------}

const
  CapiEngineID = 'capi';
  DLLCapiName = CapiEngineID + '.dll';

const
  SSL_CTRL_OPTIONS = 32;
  SSL_OP_NO_TLSv1_2 = $08000000;

const
  ENGINE_METHOD_ALL = $ffff;

type
  PPX509 = ^PX509;

var
  FEngineCS: TCriticalSection = nil;
  FEngineNeedsSHA2Workaround: boolean = False;

var
  FEngineInterfaceInitialized: boolean = False;
  FENGINE_cleanup: procedure; cdecl = nil;
  FENGINE_load_builtin_engines: procedure; cdecl = nil;
  FENGINE_by_id: function(id: PAnsiChar): PENGINE; cdecl = nil;
  FENGINE_ctrl_cmd_string: function(e: PENGINE; cmd_name, arg: PAnsiChar; cmd_optional: integer): integer; cdecl = nil;
  FENGINE_init: function(e: PENGINE): integer; cdecl = nil;
  FENGINE_finish: function(e: PENGINE): integer; cdecl = nil;
  FENGINE_free: function(e: PENGINE): integer; cdecl = nil;
  FENGINE_set_default: function(e: PENGINE; flags: DWORD): integer; cdecl = nil;
  FENGINE_load_private_key: function(e: PENGINE; key_id: PAnsiChar; ui_method: Pointer; callback_data: Pointer): EVP_PKEY; cdecl = nil;
  FSSL_CTX_set_client_cert_engine: function(ctx: PSSL_CTX; e: PENGINE): integer; cdecl = nil;
  Fd2i_X509: function(px: PPX509; data: PPointer; len: integer): PX509; cdecl = nil;

function InitEngineInterface: boolean;
var
  OpenSSLFileName: string;
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerHandle: DWORD;
  SpecVerInfo: PVsFixedFileInfo;
begin
  if FEngineInterfaceInitialized then
  begin
    Result := True;
    Exit;
  end;
  FEngineCS.Enter;
  try
    if FEngineInterfaceInitialized then
    begin
      Result := True;
      Exit;
    end;
    Result := False;
    if not InitSSLInterface then
      Exit;
    if SSLUtilHandle = 0 then
      Exit;
    if SSLLibHandle = 0 then
      Exit;
    FENGINE_cleanup := GetProcAddress(SSLUtilHandle, 'ENGINE_cleanup');
    FENGINE_load_builtin_engines := GetProcAddress(SSLUtilHandle, 'ENGINE_load_builtin_engines');
    FENGINE_by_id := GetProcAddress(SSLUtilHandle, 'ENGINE_by_id');
    FENGINE_ctrl_cmd_string := GetProcAddress(SSLUtilHandle, 'ENGINE_ctrl_cmd_string');
    FENGINE_init := GetProcAddress(SSLUtilHandle, 'ENGINE_init');
    FENGINE_finish := GetProcAddress(SSLUtilHandle, 'ENGINE_finish');
    FENGINE_free := GetProcAddress(SSLUtilHandle, 'ENGINE_free');
    FENGINE_set_default := GetProcAddress(SSLUtilHandle, 'ENGINE_set_default');
    FENGINE_load_private_key := GetProcAddress(SSLUtilHandle, 'ENGINE_load_private_key');
    FSSL_CTX_set_client_cert_engine := GetProcAddress(SSLLibHandle, 'SSL_CTX_set_client_cert_engine');
    Fd2i_X509 := GetProcAddress(SSLUtilHandle, 'd2i_X509');
    FEngineInterfaceInitialized := True;
    //---- Workaround for a CAPI engine bug ------------------------------------
    // https://www.stunnel.org/pipermail/stunnel-users/2017-February/005720.html
    //
    // The capi ENGINE in OpenSSL 1.0.2 and earlier uses the CSP attached
    // to the key for cryptographic operations. Unfortunately this means that
    // SHA2 algorithms are not supported for client authentication.
    //
    // OpenSSL 1.1.0 adds a workaround for this issue. If you disable TLS 1.2
    // in earlier versions of OpenSSL it will not use SHA2 for client auth so
    // that will also work.
    begin
      FEngineNeedsSHA2Workaround := False;
      if GetModuleFileNamePAS(SSLUtilHandle, OpenSSLFileName) then
      begin
        VerInfoSize := GetFileVersionInfoSize(PChar(OpenSSLFileName), VerHandle);
        if VerInfoSize > 0 then
        begin
          GetMem(VerInfo, VerInfoSize);
          try
            if GetFileVersionInfo(PChar(OpenSSLFileName), VerHandle, VerInfoSize, VerInfo) then
              if VerQueryValue(VerInfo, '\', Pointer(SpecVerInfo), VerInfoSize) then
              begin
                if SpecVerInfo^.dwFileVersionMS < (65536*1 + 1) then
                  FEngineNeedsSHA2Workaround := True;
              end;
          finally
            FreeMem(VerInfo);
          end;
        end;
      end;
    end;
    //---- Workaround end ------------------------------------------------------
    Result := True;
  finally
    FEngineCS.Leave;
  end;
end;

procedure DestroyEngineInterface;
begin
  FEngineCS.Enter;
  try
    if Assigned(FENGINE_cleanup) then
      FENGINE_cleanup;
    FENGINE_cleanup := nil;
    FENGINE_load_builtin_engines := nil;
    FENGINE_by_id := nil;
    FENGINE_ctrl_cmd_string := nil;
    FENGINE_init := nil;
    FENGINE_finish := nil;
    FENGINE_free := nil;
    FENGINE_set_default := nil;
    FENGINE_load_private_key := nil;
    FSSL_CTX_set_client_cert_engine := nil;
    Fd2i_X509 := nil;
    FEngineInterfaceInitialized := False;
  finally
    FEngineCS.Leave;
  end;
end;

procedure ENGINE_load_builtin_engines;
begin
  if InitEngineInterface and Assigned(FENGINE_load_builtin_engines) then
    FENGINE_load_builtin_engines;
end;

function ENGINE_by_id(id: PAnsiChar): PENGINE;
begin
  if InitEngineInterface and Assigned(FENGINE_by_id) then
    Result := FENGINE_by_id(id)
  else
    Result := nil;
end;

function ENGINE_ctrl_cmd_string(e: PENGINE; cmd_name, arg: PAnsiChar; cmd_optional: integer): integer;
begin
  if InitEngineInterface and Assigned(FENGINE_ctrl_cmd_string) then
    Result := FENGINE_ctrl_cmd_string(e, cmd_name, arg, cmd_optional)
  else
    Result := 0;
end;

function ENGINE_init(e: PENGINE): integer;
begin
  if InitEngineInterface and Assigned(FENGINE_init) then
    Result := FENGINE_init(e)
  else
    Result := 0;
end;

function ENGINE_finish(e: PENGINE): integer;
begin
  if InitEngineInterface and Assigned(FENGINE_finish) then
    Result := FENGINE_finish(e)
  else
    Result := 0;
end;

function ENGINE_free(e: PENGINE): integer;
begin
  if InitEngineInterface and Assigned(FENGINE_free) then
    Result := FENGINE_free(e)
  else
    Result := 0;
end;

function ENGINE_set_default(e: PENGINE; flags: DWORD): integer;
begin
  if InitEngineInterface and Assigned(FENGINE_set_default) then
    Result := FENGINE_set_default(e, flags)
  else
    Result := 0;
end;

function ENGINE_load_private_key(e: PENGINE; key_id: PAnsiChar; ui_method: Pointer; callback_data: Pointer): EVP_PKEY;
begin
  if InitEngineInterface and Assigned(FENGINE_load_private_key) then
    Result := FENGINE_load_private_key(e, key_id, ui_method, callback_data)
  else
    Result := nil;
end;

function SSL_CTX_set_client_cert_engine(ctx: PSSL_CTX; e: PENGINE): integer;
begin
  if InitEngineInterface and Assigned(FSSL_CTX_set_client_cert_engine) then
    Result := FSSL_CTX_set_client_cert_engine(ctx, e)
  else
    Result := 0;
end;

function d2i_X509(px: PPX509; data: PPointer; len: integer): PX509;
begin
  if InitEngineInterface and Assigned(Fd2i_X509) then
    Result := Fd2i_X509(px, data, len)
  else
    Result := nil;
end;

{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

{$IFDEF SUPPORTS_REGION}{$REGION 'CAPI engine support'}{$ENDIF}
{==============================================================================}
{CAPI engine support                                                           }
{------------------------------------------------------------------------------}

var
  FGlobalEngineInitialized: boolean = False;
  FGlobalEngine: PENGINE = nil;

function PrepareCapiEngine(out Engine: PENGINE): boolean;

  function LoadCapiEngine(Engine: PENGINE; const FileName: string): boolean;
  begin
    Result := False;
    if ENGINE_ctrl_cmd_string(Engine, 'SO_PATH', PAnsiChar(AnsiString(FileName)), 0) <> 0 then
      if ENGINE_ctrl_cmd_string(Engine, 'LOAD', nil, 0) <> 0 then
        Result := True;
  end;

  function LoadCapiEngineDynamic(out Engine: PENGINE): boolean;
  var
    OpenSSLFileName: string;
    TempEngine: PENGINE;
  begin
    Result := False;
    if not GetModuleFileNamePAS(SSLUtilHandle, OpenSSLFileName) then
      Exit;
    TempEngine := ENGINE_by_id('dynamic');
    try
      if TempEngine <> nil then
      begin
        if LoadCapiEngine(TempEngine, ExtractFilePath(OpenSSLFileName) + DLLCapiName) then // need a version match! Same dir suggests the versions could be the same
          if ENGINE_init(TempEngine) <> 0 then
          begin
            Engine := TempEngine;
            TempEngine := nil;
            Result := True;
          end;
      end;
    finally
      if TempEngine <> nil then
      begin
        ENGINE_free(TempEngine);
        //TempEngine := nil; // triggers a hint
      end;
    end;
  end;

  function LoadCapiEngineStatic(out Engine: PENGINE): boolean;
  var
    TempEngine: PENGINE;
  begin
    Result := False;
    TempEngine := ENGINE_by_id(CapiEngineID);
    try
      if TempEngine <> nil then
      begin
        if ENGINE_init(TempEngine) <> 0 then
        begin
          Engine := TempEngine;
          TempEngine := nil;
          Result := True;
        end;
      end;
    finally
      if TempEngine <> nil then
      begin
        ENGINE_free(TempEngine);
        //TempEngine := nil; // triggers a hint
      end;
    end;
  end;

begin
  Result := LoadCapiEngineStatic(Engine) or LoadCapiEngineDynamic(Engine);
end;

function InitCapiEngine: boolean;
var
  E: PENGINE;
begin
  Result := FGlobalEngine <> nil;
  if FGlobalEngineInitialized then
    Exit;
  FEngineCS.Enter;
  try
    if FGlobalEngineInitialized then
      Exit;
    ENGINE_load_builtin_engines();
    if PrepareCapiEngine(E) then
    begin
      if not Assigned(FSSL_CTX_set_client_cert_engine) then
      begin
        if ENGINE_set_default(E, ENGINE_METHOD_ALL) = 0 then
        begin
          ENGINE_finish(E);
          ENGINE_free(E);
          E := nil;
        end;
      end;
      FGlobalEngine := E;
    end;
    FGlobalEngineInitialized := True;
    Result := FGlobalEngine <> nil;
  finally
    FEngineCS.Leave;
  end;
end;

{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

{$IFDEF SUPPORTS_REGION}{$REGION 'Pool of engines'}{$ENDIF}
{==============================================================================}
{Pool of engines, to reduce the time to get a working connection               }
{------------------------------------------------------------------------------}

{$IFDEF USE_ENGINE_POOL}

type
  TEnginePool = class
  private
    fLock: TCriticalSection;
    fAvailableList: TList;
  protected
    procedure Lock;
    procedure Unlock;
  public
    constructor Create;
    destructor Destroy; override;
    function Acquire(out Engine: PENGINE): boolean;
    procedure Release(var Engine: PENGINE);
    procedure Clear;
  end;

var
  FEnginePool: TEnginePool  = nil;

{ TEnginePool }

function TEnginePool.Acquire(out Engine: PENGINE): boolean;
var
  n: integer;
begin
  if fAvailableList.Count > 0 then
  begin
    Lock;
    try
      for n := Pred(fAvailableList.Count) downto 0 do
      begin
        Engine := fAvailableList[n];
        if Engine <> nil then
        begin
          fAvailableList.Delete(n);
          Result := True;
          Exit;
        end;
      end;
    finally
      Unlock;
    end;
  end;
  Result := InitCapiEngine and PrepareCapiEngine(Engine);
end;

procedure TEnginePool.Clear;
var
  i: integer;
  E: PENGINE;
begin
  Lock;
  try
    for i := 0 to Pred(fAvailableList.Count) do
    begin
      E := fAvailableList[i];
      fAvailableList[i] := nil;
      if E <> nil then
      begin
        ENGINE_finish(E);
        ENGINE_free(E);
      end;
    end;
    fAvailableList.Clear;
  finally
    Unlock;
  end;
end;

constructor TEnginePool.Create;
begin
  inherited Create;
  fLock := TCriticalSection.Create;
  fAvailableList := TList.Create;
end;

destructor TEnginePool.Destroy;
begin
  Clear;
  FreeAndNil(fAvailableList);
  FreeAndNil(fLock);
  inherited;
end;

procedure TEnginePool.Lock;
begin
  fLock.Enter;
end;

procedure TEnginePool.Release(var Engine: PENGINE);
begin
  if Engine = nil then
    Exit;
  Lock;
  try
    fAvailableList.Add(Engine);
    Engine := nil;
  finally
    Unlock;
  end;
end;

procedure TEnginePool.Unlock;
begin
  fLock.Leave;
end;

{$ENDIF}

{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

{$IFDEF SUPPORTS_REGION}{$REGION 'The plugin'}{$ENDIF}
{==============================================================================}
{The plugin                                                                    }
{------------------------------------------------------------------------------}

{ TSSLOpenSSLCapi }

class function TSSLOpenSSLCapi.InitEngine: boolean;
begin
  Result := InitCapiEngine;
end;

procedure TSSLOpenSSLCapi.Assign(const Value: TCustomSSL);
var
  CAPIValue: TSSLOpenSSLCapi;
begin
  inherited;
  if (Value <> nil) and (Value is TSSLOpenSSLCapi) then
  begin
    CAPIValue := TSSLOpenSSLCapi(Value);
    Self.FSigningCertificateLocation := CAPIValue.FSigningCertificateLocation;
    Self.FSigningCertificateStore := CAPIValue.FSigningCertificateStore;
    Self.FSigningCertificateID := CAPIValue.FSigningCertificateID;
  end;
end;

constructor TSSLOpenSSLCapi.Create(const Value: TTCPBlockSocket);
begin
  inherited;
  FEngine := nil;
  FEngineInitialized := False;
  FSigningCertificateLocation := wcslCurrentUser;
  FSigningCertificateStore := 'MY';
  FSigningCertificateID := '';
end;

destructor TSSLOpenSSLCapi.Destroy;
begin
  if FEngine <> nil then
  begin
    {$IFDEF USE_ENGINE_POOL}
    FEnginePool.Release(FEngine);
    {$ELSE}
    ENGINE_finish(FEngine);
    ENGINE_free(FEngine);
    {$ENDIF}
    FEngineInitialized := False;
  end;
  inherited;
end;

function TSSLOpenSSLCapi.GetEngine: PENGINE;
begin
  if not FEngineInitialized then
  begin
    {$IFDEF USE_ENGINE_POOL}
    if not FEnginePool.Acquire(FEngine) then
      FEngine := nil;
    {$ELSE}
    if (not InitEngine) or (not PrepareCapiEngine(FEngine)) then
      FEngine := nil;
    {$ENDIF}
    FEngineInitialized := True;
  end;
  Result := FEngine;
end;

function TSSLOpenSSLCapi.LoadSigningCertificate: boolean;
var
  pkey: EVP_PKEY;
  pdata: Pointer;
  cert: PX509;
  store: HCERTSTORE;
  certctx: PCCERT_CONTEXT;
  flags: DWORD;
begin
  Result := False;
  if not SigningCertificateSpecified then
    Exit;
  if not InitEngine then
    Exit;
  if Engine = nil then
    Exit;
  if not Assigned(FSSL_CTX_set_client_cert_engine) then
    Exit;
  if SSL_CTX_set_client_cert_engine(Fctx, Engine) = 0 then
    Exit;
  if ENGINE_ctrl_cmd_string(Engine, 'store_name', PAnsiChar( {$IFDEF UNICODE} AnsiString {$ENDIF} (SigningCertificateStore)), 0) = 0 then
    Exit;
  if ENGINE_ctrl_cmd_string(Engine, 'lookup_method', '1', 0) = 0 then
    Exit;
  case SigningCertificateLocation of
    wcslCurrentUser:
      if ENGINE_ctrl_cmd_string(Engine, 'store_flags', '0', 0) = 0 then
        Exit;
    wcslLocalMachine:
      if ENGINE_ctrl_cmd_string(Engine, 'store_flags', '1', 0) = 0 then
        Exit;
    else
      Exit; // other store flags are not supported by the CAPI engine
  end;
  if Server then
  begin
    cert := nil;
    pkey := nil;
    try
      // Need to find the context and the store for the certificate. Unfortunately,
      // due to the CAPI engine limitations (see capi_load_privkey), I can only use
      // a very limited set of criteria for finding the certificate
      flags := 0;
      case SigningCertificateLocation of
        wcslCurrentUser:
          flags := flags or CERT_SYSTEM_STORE_CURRENT_USER;
        wcslLocalMachine:
          flags := flags or CERT_SYSTEM_STORE_LOCAL_MACHINE;
        else
          Exit; // other store flags are not supported by the CAPI engine
      end;
      store := CertOpenStore(CERT_STORE_PROV_SYSTEM_W, 0, 0, flags, PWideChar(WideString(SigningCertificateStore)));
      if store <> 0 then
      begin
        try
          certctx := CertFindCertificateInStore(store, X509_ASN_ENCODING, 0, CERT_FIND_SUBJECT_STR_A, PAnsiChar( {$IFDEF UNICODE} AnsiString {$ENDIF} (SigningCertificateID)), nil);
          if certctx = nil then
            Exit;
          pkey := ENGINE_load_private_key(Engine, PAnsiChar( {$IFDEF UNICODE} AnsiString {$ENDIF} (SigningCertificateID)), nil, nil);
          if pkey = nil then
            Exit;
          pdata := certctx.pbCertEncoded;
          cert := d2i_X509(nil, @pdata, certctx.cbCertEncoded);
          if cert = nil then
            Exit;
          if SSLCTXusecertificate(Fctx, cert) <= 0 then
            Exit;
          if SSLCTXusePrivateKey(Fctx, pkey) <= 0 then
            Exit;
          Result := True;
        finally
          CertCloseStore(store, 0);
        end;
      end;
    finally
      if pkey <> nil then
        EvpPkeyFree(pkey);
      if cert <> nil then
        X509free(cert);
    end;
  end
  else
  begin
    Result := True;
  end;
  if Result then
    if FEngineNeedsSHA2Workaround then
      SslCtxCtrl(Fctx, SSL_CTRL_OPTIONS, SslCtxCtrl(Fctx, SSL_CTRL_OPTIONS, 0, nil) or SSL_OP_NO_TLSv1_2, nil);
end;

function TSSLOpenSSLCapi.NeedSigningCertificate: boolean;
begin
  Result := SigningCertificateSpecified and inherited NeedSigningCertificate;
end;

function TSSLOpenSSLCapi.SetSslKeys: boolean;
begin
  Result := False;
  if not assigned(FCtx) then
    Exit;
  try
    if SigningCertificateSpecified and InitEngine then
    begin
      if not LoadSigningCertificate then
        Exit;
      Result := True;
    end;
    if inherited SetSslKeys then
      Result := True;
  finally
    SSLCheck;
  end;
end;

function TSSLOpenSSLCapi.SigningCertificateSpecified: boolean;
begin
  Result := (SigningCertificateID <> '');
end;

{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

{$IFDEF SUPPORTS_REGION}{$REGION 'Initialization and finalization'}{$ENDIF}
{==============================================================================}
{Initialization and finalization                                               }
{------------------------------------------------------------------------------}

initialization
begin
  FEngineCS := TCriticalSection.Create;
  if InitSSLInterface and ((SSLImplementation = TSSLNone) or (SSLImplementation = TSSLOpenSSL)) then
    SSLImplementation := TSSLOpenSSLCapi;
  {$IFDEF USE_ENGINE_POOL}
  FEnginePool := TEnginePool.Create;
  {$ENDIF}
end;

finalization
begin
  DestroyEngineInterface;
  {$IFDEF USE_ENGINE_POOL}
  FreeAndNil(FEnginePool);
  {$ENDIF}
  FreeAndNil(FEngineCS);
end;

{$IFDEF SUPPORTS_REGION}{$ENDREGION}{$ENDIF}

end.
