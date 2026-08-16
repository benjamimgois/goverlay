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
  Classes, SysUtils, TypInfo, LResources, LCLTranslator, bgmod_resources;

const
  // Base name of the catalogues: goverlay.pot for the template that the IDE
  // regenerates, goverlay.<lang>.po for a translation.
  LOCALE_FILE_NAME = 'goverlay';

  // Published property that carries a value rather than a label. See
  // TValueSafeTranslator.
  VALUE_PROPERTY = 'Text';

type

  { TValueSafeTranslator }

  // Wraps the translator the LCL installs and keeps the Text property out of
  // its reach.
  //
  // Text on an edit or a combo box is not something the user reads, it is
  // something the program writes down: vkbtogglekeyCombobox.Text ends up as
  // "toggleKey = Home" in vkBasalt.conf, filenameComboBox.Text as OptiScaler's
  // DLL name, hudonoffComboBox.Text as MangoHud's "toggle_hud = Shift_R+F12",
  // shortcutkeyComboBox.Text as a raw key code. Every one of those defaults is
  // also an entry of the Items list next to it, and Items are not translated at
  // all, so a translated Text can only end up disagreeing with the list it was
  // picked from and putting a word MangoHud and vkBasalt do not know into a
  // configuration file.
  //
  // Captions, hints and TextHint - the placeholder property meant for prompts -
  // are passed straight through.
  TValueSafeTranslator = class(TAbstractTranslator)
  private
    FInner: TAbstractTranslator;
  public
    constructor Create(AInner: TAbstractTranslator);
    destructor Destroy; override;
    procedure TranslateStringProperty(Sender: TObject; const Instance: TPersistent;
      PropInfo: PPropInfo; var Content: string); override;
  end;

constructor TValueSafeTranslator.Create(AInner: TAbstractTranslator);
begin
  inherited Create;
  // Takes ownership: LCLTranslator frees whatever LRSTranslator points at.
  FInner := AInner;
end;

destructor TValueSafeTranslator.Destroy;
begin
  FreeAndNil(FInner);
  inherited Destroy;
end;

procedure TValueSafeTranslator.TranslateStringProperty(Sender: TObject;
  const Instance: TPersistent; PropInfo: PPropInfo; var Content: string);
begin
  if (PropInfo = nil) or (FInner = nil) then
    Exit;
  // Leaving Content alone keeps the value the form was streamed with.
  if SameText(PropInfo^.Name, VALUE_PROPERTY) then
    Exit;
  FInner.TranslateStringProperty(Sender, Instance, PropInfo, Content);
end;

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

  // SetDefaultLang leaves its translator in LRSTranslator. Wrap it before the
  // first form is streamed so that no catalogue, in any language, can rewrite a
  // Text property into a configuration file.
  if LRSTranslator <> nil then
    LRSTranslator := TValueSafeTranslator.Create(LRSTranslator);
end;

end.
