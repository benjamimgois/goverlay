program test_parse_w11;
uses SysUtils;
var
  F: Text;
  Line: String;
  p1: Integer;
  VerStr: String;
  FoundSection: Boolean;
begin
  Assign(F, '/mnt/NVME/SteamLibrary/steamapps/compatdata/1903340/pfx/system.reg');
  Reset(F);
  FoundSection := False;
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
      WriteLn('CurrentVersion is: ', VerStr);
    end
    else if FoundSection and (Pos('"CurrentBuildNumber"=', Line) = 1) then
    begin
      p1 := Pos('=', Line);
      VerStr := Copy(Line, p1 + 1, Length(Line) - p1);
      VerStr := StringReplace(VerStr, '"', '', [rfReplaceAll]);
      VerStr := Trim(VerStr);
      WriteLn('CurrentBuildNumber is: ', VerStr);
    end;
  end;
  Close(F);
end.
