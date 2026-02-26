program test_parse2;
uses SysUtils;
var
  F: Text;
  Line: String;
begin
  Assign(F, '/mnt/NVME/SteamLibrary/steamapps/compatdata/1903340/pfx/system.reg');
  Reset(F);
  while not EOF(F) do
  begin
    ReadLn(F, Line);
    if Pos('[Software\\Microsoft\\Windows NT\\CurrentVersion]', Line) > 0 then
      WriteLn('FOUND WITH DOUBLE SLASH');
  end;
  Close(F);
end.
