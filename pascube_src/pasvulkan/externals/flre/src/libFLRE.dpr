library libFLRE;
{$ifdef fpc}
 {$mode delphi}
{$endif}

{$ifndef fpc}
{ FastMM4 in 'FastMM4.pas',
  FastMove in 'FastMove.pas',
  FastcodeCPUID in 'FastcodeCPUID.pas',
  FastMM4Messages in 'FastMM4Messages.pas',}
{$endif}

uses
  SysUtils,
  Classes,
  FLRE in 'FLRE.pas',
  PUCU in 'PUCU.pas';

exports FLREGetVersion name 'FLREGetVersion',
        FLREGetVersionString name 'FLREGetVersionString',
        FLRECreate name 'FLRECreate',
        FLREDestroy name 'FLREDestroy',
        FLREAlloc name 'FLREAlloc',
        FLREFree name 'FLREFree',
        FLREGetCountCaptures name 'FLREGetCountCaptures',
        FLREGetNamedGroupIndex name 'FLREGetNamedGroupIndex',
        FLREGetPrefilterExpression name 'FLREGetPrefilterExpression',
        FLREGetPrefilterShortExpression name 'FLREGetPrefilterShortExpression',
        FLREGetPrefilterSQLBooleanFullTextExpression name 'FLREGetPrefilterSQLBooleanFullTextExpression',
        FLREGetPrefilterSQLExpression name 'FLREGetPrefilterSQLExpression',
        FLREGetRange name 'FLREGetRange',
        FLREMatch name 'FLREMatch',
        FLREMatchNext name 'FLREMatchNext',
        FLREMatchAll name 'FLREMatchAll',
        FLREReplaceAll name 'FLREReplaceAll',
        FLREReplaceCallback name 'FLREReplaceCallback',
        FLRESplit name 'FLRESplit',
        FLRETest name 'FLRETest',
        FLRETestAll name 'FLRETestAll',
        FLREFind name 'FLREFind';

begin
 InitializeFLRE;
end.
