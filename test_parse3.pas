program test_parse3;
uses SysUtils;
var
  F: Text;
  Line: String;
  p1: Integer;
  VerStr, BuildStr, ResultStr: String;
  FoundSection: Boolean;
begin
  Assign(F, '/mnt/NVME/SteamLibrary/steamapps/compatdata/1903340/pfx/system.reg');
  Reset(F);
  FoundSection := False;
  VerStr := '';
  BuildStr := '';
  while not EOF(F) do
  begin
    ReadLn(F, Line);
    if Pos('[Software\\Microsoft\\Windows NT\\CurrentVersion]', Line) > 0 then
    begin
      FoundSection := True;
    end
    else if FoundSection and (Pos('[', Line) = 1) then
    begin
      Break;
    end
    else if FoundSection and (Pos('"CurrentVersion"=', Line) = 1) then
    begin
      p1 := Pos('=', Line);
      VerStr := Copy(Line, p1 + 1, Length(Line) - p1);
      VerStr := StringReplace(VerStr, '"', '', [rfReplaceAll]);
      VerStr := Trim(VerStr);
    end
    else if FoundSection and (Pos('"CurrentBuildNumber"=', Line) = 1) then
    begin
      p1 := Pos('=', Line);
      BuildStr := Copy(Line, p1 + 1, Length(Line) - p1);
      BuildStr := StringReplace(BuildStr, '"', '', [rfReplaceAll]);
      BuildStr := Trim(BuildStr);
    end
    else if FoundSection and (Trim(Line) = '') then
    begin
      // End of section, calculate version
      if (VerStr = '6.3') and (StrToIntDef(BuildStr, 0) >= 22000) then ResultStr := 'win11'
      else if (VerStr = '6.3') and (StrToIntDef(BuildStr, 0) >= 10240) then ResultStr := 'win10'
      else if (VerStr = '10.0') then ResultStr := 'win10'
      else if VerStr = '6.3' then ResultStr := 'win81'
      else if VerStr = '6.2' then ResultStr := 'win8'
      else if VerStr = '6.1' then ResultStr := 'win7'
      else if VerStr = '6.0' then ResultStr := 'winvista'
      else if VerStr = '5.1' then ResultStr := 'winxp'
      else if VerStr <> '' then ResultStr := VerStr;
      Break;
    end;
  end;
  Close(F);
  WriteLn('Result is: ', ResultStr);
end.
