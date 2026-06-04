program swizzlegenerator;
{$ifdef fpc}
 {$mode delphi}
{$endif}
{$APPTYPE CONSOLE}

uses
  SysUtils,Classes,Math;

procedure DoItFor(const VecID:longint;const DataType:ansistring);
var slMainDefinitions,slMainPropertyDefinitions,slMainImplementations,
    slHelperDefinitions,slHelperPropertyDefinitions,slHelperImplementations:TStringList;
 procedure Generate(const Chars,Chars2:ansistring);
  procedure OutputIt(const c,TargetDataType:ansistring);
  var CanWrite:boolean;
      i,j:longint;
      slDefinitions,slPropertyDefinitions,slImplementations:TStringList;
      NameSuffix:ansistring;
  begin
   if length(c)<=VecID then begin
    slDefinitions:=slMainDefinitions;
    slPropertyDefinitions:=slMainPropertyDefinitions;
    slImplementations:=slMainImplementations;
    NameSuffix:='';
   end else begin
    slDefinitions:=slHelperDefinitions;
    slPropertyDefinitions:=slHelperPropertyDefinitions;
    slImplementations:=slHelperImplementations;
    NameSuffix:='Helper';
   end;
{  if ((DataType='TpvVector3') or (DataType='TpvVector4')) and (c='xy') then begin
    exit;
   end;
   if (DataType='TpvVector4') and (c='xyz') then begin
    exit;
   end;{}
   CanWrite:=true;
   for i:=1 to length(c) do begin
    for j:=1 to i-1 do begin
     if c[i]=c[j] then begin
      CanWrite:=false;
      break;
     end;
    end;
    if not CanWrite then begin
     break;
    end;
   end;
   slImplementations.Add('function '+DataType+NameSuffix+'.Get'+UpperCase(c)+':'+TargetDataType+';');
   slImplementations.Add('begin');
   for i:=1 to length(c) do begin
    slImplementations.Add(' result.'+Chars2[i]+':='+c[i]+';');
   end;
   slImplementations.Add('end;');
   if CanWrite then begin
    slImplementations.Add('procedure '+DataType+NameSuffix+'.Set'+UpperCase(c)+'(const pValue:'+TargetDataType+');');
    slImplementations.Add('begin');
    for i:=1 to length(c) do begin
     slImplementations.Add(' '+c[i]+':=pValue.'+Chars2[i]+';');
    end;
    slImplementations.Add('end;');
    slDefinitions.Add('function Get'+UpperCase(c)+':'+TargetDataType+'; {$ifdef CAN_INLINE}inline;{$endif}');
    slDefinitions.Add('procedure Set'+UpperCase(c)+'(const pValue:'+TargetDataType+'); {$ifdef CAN_INLINE}inline;{$endif}');
    slPropertyDefinitions.Add('property '+c+':'+TargetDataType+' read Get'+UpperCase(c)+' write Set'+UpperCase(c)+';');
   end else begin
    slDefinitions.Add('function Get'+UpperCase(c)+':'+TargetDataType+'; {$ifdef CAN_INLINE}inline;{$endif}');
    slPropertyDefinitions.Add('property '+c+':'+TargetDataType+' read Get'+UpperCase(c)+';');
   end;
  end;
 var a,b,c,d:longint;
 begin
  for a:=1 to length(Chars) do begin
   for b:=1 to length(Chars) do begin
    OutputIt(Chars[a]+Chars[b],'TpvVector2');
    for c:=1 to length(Chars) do begin
     OutputIt(Chars[a]+Chars[b]+Chars[c],'TpvVector3');
     for d:=1 to length(Chars) do begin
      OutputIt(Chars[a]+Chars[b]+Chars[c]+Chars[d],'TpvVector4');
     end;
    end;
   end;
  end;
 end;
begin
 slMainDefinitions:=TStringList.Create;
 slMainPropertyDefinitions:=TStringList.Create;
 slMainImplementations:=TStringList.Create;
 slHelperDefinitions:=TStringList.Create;
 slHelperPropertyDefinitions:=TStringList.Create;
 slHelperImplementations:=TStringList.Create;
 try
  case VecID of
   2:begin
    Generate('xy','xyzw');
    Generate('rg','rgba');
    Generate('st','stpq');
   end;
   3:begin
    Generate('xyz','xyzw');
    Generate('rgb','rgba');
    Generate('stp','stpq');
   end;
   4:begin
    Generate('xyzw','xyzw');
    Generate('rgba','rgba');
    Generate('stpq','stpq');
   end;
  end;
  begin
   slMainDefinitions.Sort;
   slMainPropertyDefinitions.Sort;
   slMainDefinitions.Insert(0,'private');
   slMainDefinitions.Add('public');
   slMainDefinitions.AddStrings(slMainPropertyDefinitions);
   slMainDefinitions.SaveToFile('..\..\PasVulkan.Math.'+DataType+'.Swizzle.Definitions.inc');
   slMainImplementations.SaveToFile('..\..\PasVulkan.Math.'+DataType+'.Swizzle.Implementations.inc');
  end;
  begin
   slHelperDefinitions.Sort;
   slHelperPropertyDefinitions.Sort;
   slHelperDefinitions.Insert(0,'private');
   slHelperDefinitions.Add('public');
   slHelperDefinitions.AddStrings(slHelperPropertyDefinitions);
   slHelperDefinitions.SaveToFile('..\..\PasVulkan.Math.'+DataType+'Helper.Swizzle.Definitions.inc');
   slHelperImplementations.SaveToFile('..\..\PasVulkan.Math.'+DataType+'Helper.Swizzle.Implementations.inc');
  end;
 finally
  slMainDefinitions.Free;
  slMainPropertyDefinitions.Free;
  slMainImplementations.Free;
  slHelperDefinitions.Free;
  slHelperPropertyDefinitions.Free;
  slHelperImplementations.Free;
 end;
end;

begin
 DoItFor(2,'TpvVector2');
 DoItFor(3,'TpvVector3');
 DoItFor(4,'TpvVector4');
end.
