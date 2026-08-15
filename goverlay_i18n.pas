unit goverlay_i18n;

{$mode objfpc}{$H+}

// Interface language support.
//
// The project has i18n turned on in goverlay.lpi, so the Lazarus IDE keeps
// languages/goverlay.pot in sync with the form captions and the resource
// strings on every build. A translation is a copy of that file named
// goverlay.<lang>.po living next to it.
//
// Nothing here changes the interface as long as no translated catalogue is
// installed: without a matching .po the LCL translator hands every caption
// straight back.

interface

// Picks the interface language and installs the LCL translator.
//
// Must run before the first form is created: the translator replaces captions
// while the forms are streamed in, and forms created earlier would keep the
// English ones.
//
// The language is taken from --lang=<code> when it is on the command line and
// from the locale environment otherwise, which is what every LCL program does.
procedure InitTranslation;

// Directory the catalogues are read from, or '' when this build ships none.
function GetLanguagesDir: string;

implementation

uses
  SysUtils, LCLTranslator, bgmod_resources;

const
  // Base name of the catalogues: goverlay.pot for the template that the IDE
  // regenerates, goverlay.<lang>.po for a translation.
  LOCALE_FILE_NAME = 'goverlay';

function GetLanguagesDir: string;
begin
  // GetAppBaseDir already knows where GOverlay keeps its shipped data in every
  // layout we support: the source tree, an AppImage, and an installed prefix
  // where the binary sits in libexec/ and the data in share/goverlay/.
  Result := GetAppBaseDir + 'languages';
  if not DirectoryExists(Result) then
    Result := '';
end;

procedure InitTranslation;
var
  Dir: string;
begin
  Dir := GetLanguagesDir;
  if Dir = '' then
    Exit;

  // ForceUpdate is False because no form exists yet, so there is nothing to
  // walk over and re-translate; the translator installed here does the work
  // while the forms are being streamed in.
  SetDefaultLang('', Dir, LOCALE_FILE_NAME, False);
end;

end.
