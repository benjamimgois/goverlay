program pocarun;
{$ifdef fpc}
 {$mode delphi}
{$endif}
{$ifdef win32}
 {$apptype console}
{$endif}
{$ifdef win64}
 {$apptype console}
{$endif}

uses
{$ifdef fpc}
{$ifdef unix}
  cmem,
  cthreads,
{$endif}
{$endif}
  PasMP in '../externals/pasmp/src/PasMP.pas',
  PUCU in '../externals/pucu/src/PUCU.pas',
  PasDblStrUtils in '../externals/pasdblstrutils/src/PasDblStrUtils.pas',
  PasJSON in '../externals/pasjson/src/PasJSON.pas',
  FLRE in '../externals/flre/src/FLRE.pas',
  POCA in 'POCA.pas',
  POCARunCore in 'POCARunCore.pas';

begin
 try
  MainProc;
 except
  on e:EPOCAError do begin
   halt(1);
  end;
 end;
 halt(0);
end.
