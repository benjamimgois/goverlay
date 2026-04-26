unit configfile;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  /// <summary>
  /// Lightweight wrapper around a TStringList for INI/key-value config files.
  /// Provides section-aware Get/Set/Delete operations without the overhead
  /// of TIniFile (which requires a section) and works with plain key=value
  /// files like MangoHud.conf, vkBasalt.conf, OptiScaler.ini, etc.
  /// </summary>
  TConfigFile = class
  private
    FLines: TStringList;
    FFilePath: string;
    FModified: Boolean;
    function FindLineIndex(const AKeyPrefix: string; AStartIndex: Integer = 0): Integer;
    function FindLineIndexInSection(const AKeyPrefix, ASection: string): Integer;
    function IsSectionHeader(const ALine: string; out ASectionName: string): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>Load config from disk. Returns False if file does not exist.</summary>
    function Load(const AFilePath: string): Boolean;

    /// <summary>Save config back to disk (only if modified). Creates dirs if needed.</summary>
    function Save: Boolean;

    /// <summary>Access the raw TStringList for advanced operations.</summary>
    property Lines: TStringList read FLines;

    /// <summary>Full path of the loaded file.</summary>
    property FilePath: string read FFilePath;

    /// <summary>True if any Set* or Delete* was called since last Load/Save.</summary>
    property Modified: Boolean read FModified;

    // -----------------------------------------------------------------------
    // String values (key=value)
    // -----------------------------------------------------------------------

    /// <summary>
    /// Get the value for a key. Returns Default if key not found.
    /// KeyPrefix should include the trailing '=' (e.g. 'ShortcutKey=').
    /// </summary>
    function GetValue(const AKeyPrefix, ADefault: string): string;

    /// <summary>
    /// Set a key=value line. Creates or updates the line.
    /// If ASection is provided, the key is searched/added within that section.
    /// </summary>
    procedure SetValue(const AKeyPrefix, AValue: string; const ASection: string = '');

    /// <summary>
    /// Delete the first line matching the key prefix. Returns True if deleted.
    /// </summary>
    function DeleteKey(const AKeyPrefix: string): Boolean;

    // -----------------------------------------------------------------------
    // Boolean values (key=true/false/1/0 or standalone flags)
    // -----------------------------------------------------------------------

    /// <summary>
    /// Check if a boolean flag is present and enabled.
    /// Supports 'true', '1', 'yes', 'on' as True; anything else or missing as False.
    /// For standalone flags (no value), use HasKey.
    /// </summary>
    function GetBool(const AKeyPrefix: string; ADefault: Boolean = False): Boolean;

    /// <summary>
    /// Set a boolean key=value. Writes 'true' or 'false'.</summary>
    procedure SetBool(const AKeyPrefix: string; AValue: Boolean; const ASection: string = '');

    // -----------------------------------------------------------------------
    // Integer values
    // -----------------------------------------------------------------------

    /// <summary>Get integer value. Returns Default if not found or not numeric.</summary>
    function GetInt(const AKeyPrefix: string; ADefault: Integer): Integer;

    /// <summary>Set integer value.</summary>
    procedure SetInt(const AKeyPrefix: string; AValue: Integer; const ASection: string = '');

    // -----------------------------------------------------------------------
    // Presence checks
    // -----------------------------------------------------------------------

    /// <summary>True if any line starts with the given prefix.</summary>
    function HasKey(const AKeyPrefix: string): Boolean;

    /// <summary>True if the given section header exists.</summary>
    function HasSection(const ASection: string): Boolean;

    // -----------------------------------------------------------------------
    // Batch / advanced
    // -----------------------------------------------------------------------

    /// <summary>Clear all lines and mark as modified.</summary>
    procedure Clear;

    /// <summary>Add a raw line at the end.</summary>
    procedure AddRaw(const ALine: string);

    /// <summary>Remove all lines whose content contains ASubstring.</summary>
    function DeleteLinesContaining(const ASubstring: string): Integer;
  end;

implementation

uses
  StrUtils;

constructor TConfigFile.Create;
begin
  inherited;
  FLines := TStringList.Create;
end;

destructor TConfigFile.Destroy;
begin
  FLines.Free;
  inherited;
end;

function TConfigFile.Load(const AFilePath: string): Boolean;
begin
  FFilePath := AFilePath;
  FModified := False;
  FLines.Clear;
  Result := FileExists(AFilePath);
  if Result then
    FLines.LoadFromFile(AFilePath);
end;

function TConfigFile.Save: Boolean;
var
  Dir: string;
begin
  Result := False;
  if not FModified then Exit;
  if FFilePath = '' then Exit;

  Dir := ExtractFilePath(FFilePath);
  if (Dir <> '') and not DirectoryExists(Dir) then
    ForceDirectories(Dir);

  FLines.SaveToFile(FFilePath);
  FModified := False;
  Result := True;
end;

function TConfigFile.IsSectionHeader(const ALine: string; out ASectionName: string): Boolean;
var
  Trimmed: string;
begin
  Trimmed := Trim(ALine);
  Result := (Length(Trimmed) > 2) and (Trimmed[1] = '[') and (Trimmed[Length(Trimmed)] = ']');
  if Result then
    ASectionName := Trimmed;
end;

function TConfigFile.FindLineIndex(const AKeyPrefix: string; AStartIndex: Integer = 0): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := AStartIndex to FLines.Count - 1 do
    if Pos(AKeyPrefix, FLines[i]) > 0 then
    begin
      Result := i;
      Exit;
    end;
end;

function TConfigFile.FindLineIndexInSection(const AKeyPrefix, ASection: string): Integer;
var
  i: Integer;
  InSection: Boolean;
  SectionName: string;
  Trimmed: string;
begin
  Result := -1;
  InSection := (ASection = '');

  for i := 0 to FLines.Count - 1 do
  begin
    Trimmed := Trim(FLines[i]);

    if IsSectionHeader(Trimmed, SectionName) then
    begin
      if InSection and (SectionName <> ASection) then
        Exit; // left the target section without finding the key
      InSection := (SectionName = ASection);
      Continue;
    end;

    if InSection and (Pos(AKeyPrefix, FLines[i]) > 0) then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

function TConfigFile.GetValue(const AKeyPrefix, ADefault: string): string;
var
  idx: Integer;
  s: string;
begin
  idx := FindLineIndex(AKeyPrefix);
  if idx < 0 then
  begin
    Result := ADefault;
    Exit;
  end;

  s := FLines[idx];
  // strip everything before and including the first '=' after the key prefix
  idx := Pos('=', s);
  if idx > 0 then
    Result := Trim(Copy(s, idx + 1, MaxInt))
  else
    Result := ADefault;
end;

procedure TConfigFile.SetValue(const AKeyPrefix, AValue: string; const ASection: string = '');
var
  idx: Integer;
  KeyName: string;
begin
  if ASection <> '' then
    idx := FindLineIndexInSection(AKeyPrefix, ASection)
  else
    idx := FindLineIndex(AKeyPrefix);

  if idx >= 0 then
  begin
    FLines[idx] := AKeyPrefix + AValue;
  end
  else
  begin
    // Key not found — append at end (or after section if specified)
    if ASection <> '' then
    begin
      idx := FindLineIndex(ASection);
      if idx >= 0 then
      begin
        // Insert after section header (or at end of section)
        FLines.Insert(idx + 1, AKeyPrefix + AValue);
        FModified := True;
        Exit;
      end;
      // Section not found — add section header + key
      FLines.Add(ASection);
    end;
    FLines.Add(AKeyPrefix + AValue);
  end;
  FModified := True;
end;

function TConfigFile.DeleteKey(const AKeyPrefix: string): Boolean;
var
  idx: Integer;
begin
  idx := FindLineIndex(AKeyPrefix);
  Result := idx >= 0;
  if Result then
  begin
    FLines.Delete(idx);
    FModified := True;
  end;
end;

function TConfigFile.GetBool(const AKeyPrefix: string; ADefault: Boolean): Boolean;
var
  v: string;
begin
  v := LowerCase(Trim(GetValue(AKeyPrefix, '')));
  if v = '' then
    Result := ADefault
  else
    Result := (v = 'true') or (v = '1') or (v = 'yes') or (v = 'on');
end;

procedure TConfigFile.SetBool(const AKeyPrefix: string; AValue: Boolean; const ASection: string = '');
begin
  if AValue then
    SetValue(AKeyPrefix, 'true', ASection)
  else
    SetValue(AKeyPrefix, 'false', ASection);
end;

function TConfigFile.GetInt(const AKeyPrefix: string; ADefault: Integer): Integer;
var
  v: string;
  i: Integer;
begin
  v := Trim(GetValue(AKeyPrefix, ''));
  if TryStrToInt(v, i) then
    Result := i
  else
    Result := ADefault;
end;

procedure TConfigFile.SetInt(const AKeyPrefix: string; AValue: Integer; const ASection: string = '');
begin
  SetValue(AKeyPrefix, IntToStr(AValue), ASection);
end;

function TConfigFile.HasKey(const AKeyPrefix: string): Boolean;
begin
  Result := FindLineIndex(AKeyPrefix) >= 0;
end;

function TConfigFile.HasSection(const ASection: string): Boolean;
var
  i: Integer;
  SectionName: string;
begin
  Result := False;
  for i := 0 to FLines.Count - 1 do
    if IsSectionHeader(Trim(FLines[i]), SectionName) and (SectionName = ASection) then
    begin
      Result := True;
      Exit;
    end;
end;

procedure TConfigFile.Clear;
begin
  FLines.Clear;
  FModified := True;
end;

procedure TConfigFile.AddRaw(const ALine: string);
begin
  FLines.Add(ALine);
  FModified := True;
end;

function TConfigFile.DeleteLinesContaining(const ASubstring: string): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := FLines.Count - 1 downto 0 do
    if Pos(ASubstring, FLines[i]) > 0 then
    begin
      FLines.Delete(i);
      Inc(Result);
      FModified := True;
    end;
end;

end.
