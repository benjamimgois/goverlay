program bin2pas;
{$ifdef fpc}
 {$mode delphi}
{$endif}
{$apptype console}

uses SysUtils,
     Classes,
     Math;

function ByteToHex(Value:byte):string;
const HexNumbers:array[0..$f] of char='0123456789abcdef';
begin
 result:=HexNumbers[Value shr 4]+HexNumbers[Value and $f];
end;

var f:file;
    t:text;
    b:byte;
    i:integer;
    s:string;
begin
 s:=changefileext(extractfilename(paramstr(1)),'');
 assignfile(t,changefileext(paramstr(1),'.pas'));
 rewrite(t);
 writeln(t,'unit '+s+';');
 writeln(t,'{$ifdef fpc}');
 writeln(t,' {$mode delphi}');
 writeln(t,'{$endif}');
 writeln(t,'');
 writeln(t,'interface');
 writeln(t,'');
 assignfile(f,paramstr(1));
 reset(f,1);
 i:=0;
 writeln(t,'type T'+S+'Data=array[0..',filesize(f)-1,'] of byte;');
 writeln(t,'');
 write(t,'const '+S+'Data:T'+S+'Data=(');
 while not eof(f) do begin
  blockread(f,b,1);
  write(t,'$',ByteToHex(b));
  if not eof(f) then begin
   write(t,',');
   inc(i);
   if i>=16 then begin
    writeln(t);
    i:=0;
    write(t,'                        ');
   end;
  end;
 end;
 closefile(f);
 writeln(t,');');
 writeln(t,'');
 writeln(t,'implementation');
 writeln(t,'');
 writeln(t,'end.');
 closefile(t);
end.