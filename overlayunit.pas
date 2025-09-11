unit overlayunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, Forms, Controls, Graphics, Dialogs, ExtCtrls, Math,
  unix, StdCtrls, Spin, ComCtrls, Buttons, ColorBox, ActnList, Menus, aboutunit,
  ATStringProc_HtmlColor, blacklistUnit, customeffectsunit, LCLtype, CheckLst,
  FileUtil, StrUtils, gfxlaunch, Types;



type

  { Tgoverlayform }

  Tgoverlayform = class(TForm)
    aboutBitBtn: TBitBtn;
    acteffectsListBox: TListBox;
    addBitBtn: TBitBtn;
    afLabel: TLabel;
    afterburnercolorBitBtn1: TBitBtn;
    afterburnercolorLabel: TLabel;
    afTrackBar: TTrackBar;
    afvalueLabel: TLabel;
    alphavalueLabel: TLabel;
    archCheckBox: TCheckBox;
    autouploadCheckBox: TCheckBox;
    aveffectsListBox: TListBox;
    backgroundGroupBox: TGroupBox;
    backgroundLabel: TLabel;
    basicBitBtn: TBitBtn;
    basichorizontalBitBtn: TBitBtn;
    basichorizontalLabel: TLabel;
    basicLabel: TLabel;
    batteryCheckBox: TCheckBox;
    batteryColorButton: TColorButton;
    batteryLabel: TLabel;
    batterytimeCheckBox: TCheckBox;
    batterywattCheckBox: TCheckBox;
    blacklistBitBtn: TBitBtn;
    borderGroupBox: TGroupBox;
    bottomcenterRadioButton: TRadioButton;
    bottomleftRadioButton: TRadioButton;
    bottomrightRadioButton: TRadioButton;
    casLabel: TLabel;
    casTrackBar: TTrackBar;
    casvalueLabel: TLabel;
    colorthemeLabel: TLabel;
    columsGroupBox: TGroupBox;
    columShape: TShape;
    columShape1: TShape;
    columShape2: TShape;
    columShape3: TShape;
    columShape4: TShape;
    columShape5: TShape;
    columvalueLabel: TLabel;
    coreloadtypeBitBtn: TBitBtn;
    cpuavgloadCheckBox: TCheckBox;
    cpuColorButton: TColorButton;
    cpufreqCheckBox: TCheckBox;
    cpuGroupBox: TGroupBox;
    cpuImage: TImage;
    cpuload1ColorButton: TColorButton;
    cpuload2ColorButton: TColorButton;
    cpuload3ColorButton: TColorButton;
    cpuloadcolorCheckBox: TCheckBox;
    cpuloadcoreCheckBox: TCheckBox;
    cpumainmetricsLabel: TLabel;
    cpunameEdit: TEdit;
    cpupowerCheckBox: TCheckBox;
    cputempCheckBox: TCheckBox;
    cputempLabel: TLabel;
    customcommandEdit: TEdit;
    customLabel: TLabel;
    customolorLabel: TLabel;
    delayTrackBar: TTrackBar;
    delayvalueLabel: TLabel;
    deviceCheckBox: TCheckBox;
    diskioCheckBox: TCheckBox;
    distroinfoCheckBox: TCheckBox;
    durationTrackBar: TTrackBar;
    durationvalueLabel: TLabel;
    engineColorButton: TColorButton;
    engineshortCheckBox: TCheckBox;
    engineversionCheckBox: TCheckBox;
    extrasTabSheet: TTabSheet;
    fahrenheitCheckBox: TCheckBox;
    fcatCheckBox: TCheckBox;
    filterRadioGroup: TRadioGroup;
    filtersGroupBox: TGroupBox;
    FontcolorButton: TColorButton;
    fontcolorLabel: TLabel;
    fontComboBox: TComboBox;
    fontLabel: TLabel;
    fontsGroupBox: TGroupBox;
    fontsizeTrackBar: TTrackBar;
    fontsizevalueLabel: TLabel;
    fpsavgBitBtn: TBitBtn;
    fpsavgCheckBox: TCheckBox;
    fpsCheckBox: TCheckBox;
    fxaaCheckBox: TCheckBox;
    smaaCheckBox: TCheckBox;
    dlsCheckBox: TCheckBox;
    lutCheckBox: TCheckBox;
    fpscolor1ColorButton: TColorButton;
    fpscolor2ColorButton: TColorButton;
    fpscolor2SpinEdit: TSpinEdit;
    fpscolor3ColorButton: TColorButton;
    fpscolor3SpinEdit: TSpinEdit;
    fpscolorCheckBox: TCheckBox;
    fpsGroupBox: TGroupBox;
    fpslimCheckGroup: TCheckGroup;
    fpslimiterGroupBox: TGroupBox;
    fpslimLabel: TLabel;
    fpslimmetComboBox: TComboBox;
    fpslimtoggleComboBox: TComboBox;
    fpsonlyBitBtn: TBitBtn;
    fpsonlyLabel: TLabel;
    fpstoggleImage: TImage;
    framecountCheckBox: TCheckBox;
    frametimegraphCheckBox: TCheckBox;
    frametimegraphColorButton: TColorButton;
    frametimetypeBitBtn: TBitBtn;
    fsrCheckBox: TCheckBox;
    fullBitBtn: TBitBtn;
    fullLabel: TLabel;
    gamemodestatusCheckBox: TCheckBox;
    geSpeedButton: TSpeedButton;
    GlobalenableLabel: TLabel;
    glvsyncComboBox: TComboBox;
    goverlayBitBtn: TBitBtn;
    goverlayPageControl: TPageControl;
    gpuavgloadCheckBox: TCheckBox;
    gpuColorButton: TColorButton;
    gpudescEdit: TEdit;
    gpufanCheckBox: TCheckBox;
    gpufreqCheckBox: TCheckBox;
    gpuGroupBox: TGroupBox;
    gpuImage: TImage;
    gpuinfoLabel: TLabel;
    gpujunctempCheckBox: TCheckBox;
    gpuload1ColorButton: TColorButton;
    gpuload2ColorButton: TColorButton;
    gpuload3ColorButton: TColorButton;
    gpuloadcolorCheckBox: TCheckBox;
    gpumemfreqCheckBox: TCheckBox;
    gpumemtempCheckBox: TCheckBox;
    gpumodelCheckBox: TCheckBox;
    gpunameEdit: TEdit;
    gpupowerCheckBox: TCheckBox;
    gpupowerLabel: TLabel;
    gputempCheckBox: TCheckBox;
    gputempLabel: TLabel;
    gputhrottlingCheckBox: TCheckBox;
    gputhrottlinggraphCheckBox: TCheckBox;
    gpuvoltageCheckBox: TCheckBox;
    builtineffectsGroupBox: TGroupBox;
    reshadeGroupBox: TGroupBox;
    hdrCheckBox: TCheckBox;
    hidehudCheckBox: TCheckBox;
    hImage: TImage;
    horizontalRadioButton: TRadioButton;
    hudbackgroundColorButton: TColorButton;
    hudcompactCheckBox: TCheckBox;
    hudonoffComboBox: TComboBox;
    hudtitleEdit: TEdit;
    hudtoggleImage: TImage;
    hudtoggleLabel: TLabel;
    hudversionCheckBox: TCheckBox;
    Image1: TImage;
    Image2: TImage;
    intelpowerfixBitBtn: TBitBtn;
    intervalTrackBar: TTrackBar;
    intervalvalueLabel: TLabel;
    iordrwColorButton: TColorButton;
    layoutsLabel: TLabel;
    limtoggleLabel: TLabel;
    logdelayLabel: TLabel;
    logdurationLabel: TLabel;
    logfolderBitBtn: TBitBtn;
    logfolderEdit: TEdit;
    logfolderLabel: TLabel;
    loggingGroupBox: TGroupBox;
    logintervalLabel: TLabel;
    logtoggleComboBox: TComboBox;
    logtoggleImage: TImage;
    logtoggleLabel: TLabel;
    mainmetricLabel: TLabel;
    mangobarPanel: TPanel;
    mangocolorBitBtn: TBitBtn;
    mangocolorLabel: TLabel;
    mangohudPanel: TPanel;
    mediaCheckBox: TCheckBox;
    mediaColorButton: TColorButton;
    memLabel: TLabel;
    methodLabel: TLabel;
    metricsTabSheet: TTabSheet;
    middleleftRadioButton: TRadioButton;
    middlerightRadioButton: TRadioButton;
    minusButton: TSpeedButton;
    mipmapLabel: TLabel;
    mipmapTrackBar: TTrackBar;
    mipmapvalueLabel: TLabel;
    networkCheckBox: TCheckBox;
    networkComboBox: TComboBox;
    notificationLabel: TLabel;
    offsetLabel: TLabel;
    offsetSpinEdit: TSpinEdit;
    openglImage: TImage;
    optionsLabel: TLabel;
    orientationGroupBox: TGroupBox;
    othersLabel: TLabel;
    pbarLabel: TLabel;
    pcidevComboBox: TComboBox;
    performanceTabSheet: TTabSheet;
    plusSpeedButton: TSpeedButton;
    popupBitBtn: TBitBtn;
    positionGroupBox: TGroupBox;
    presetTabSheet: TTabSheet;
    procmemCheckBox: TCheckBox;
    ramColorButton: TColorButton;
    ramusageCheckBox: TCheckBox;
    refreshrateCheckBox: TCheckBox;
    reshadeLabel1: TLabel;
    reshadeLabel2: TLabel;
    reshadeProgressBar: TProgressBar;
    reshaderefreshBitBtn: TBitBtn;
    resolutionCheckBox: TCheckBox;
    roundImage: TImage;
    roundRadioButton: TRadioButton;
    runvkbasaltItem: TMenuItem;
    runvkcubeItem: TMenuItem;
    saveBitBtn: TBitBtn;
    sessionCheckBox: TCheckBox;
    showfpslimCheckBox: TCheckBox;
    squareImage: TImage;
    squareRadioButton: TRadioButton;
    subBitBtn: TBitBtn;
    swapusageCheckBox: TCheckBox;
    sysinfoImage: TImage;
    systemGroupBox: TGroupBox;
    systemLabel: TLabel;
    timeCheckBox: TCheckBox;
    Timer1: TTimer;
    savecustomItem: TMenuItem;
    layoutImageList: TImageList;
    popsaveMenu: TPopupMenu;
    C: TComboBox;
    goverlayPaintBox: TPaintBox;
    Process: TProcess;
    iconsImageList: TImageList;
    columImageList: TImageList;
    dependencieSpeedButton: TSpeedButton;
    casTrackBar2: TTrackBar;
    globalbuttonImageList: TImageList;
    mangohudLabel: TLabel;
    dependenciesLabel: TLabel;
    toggleImage: TImage;
    topcenterRadioButton: TRadioButton;
    topleftRadioButton: TRadioButton;
    toprightRadioButton: TRadioButton;
    transparencyLabel: TLabel;
    transpTrackBar: TTrackBar;
    usercustomBitBtn: TBitBtn;
    versioningCheckBox: TCheckBox;
    verticalRadioButton: TRadioButton;
    vImage: TImage;
    visualTabSheet: TTabSheet;
    vkbasaltLabel: TLabel;
    goverlayimage: TImage;
    mangohudShape: TShape;
    vkbasaltShape: TShape;
    vkbasaltstatusCheckBox: TCheckBox;
    vkbasaltTabSheet: TTabSheet;
    vkbtogglekeyCombobox: TComboBox;
    vktoggleLabel: TLabel;
    vpsCheckBox: TCheckBox;
    vramColorButton: TColorButton;
    vramusageCheckBox: TCheckBox;
    vsyncComboBox: TComboBox;
    vsyncGroupBox: TGroupBox;
    vulkandriverCheckBox: TCheckBox;
    vulkanImage: TImage;
    whitecolorBitBtn: TBitBtn;
    whitecolorLabel: TLabel;
    wineCheckBox: TCheckBox;
    wineColorButton: TColorButton;
    wineLabel: TLabel;
    winesyncCheckBox: TCheckBox;


    procedure aboutBitBtnClick(Sender: TObject);
    procedure addBitBtnClick(Sender: TObject);
    procedure afterburnercolorBitBtn1Click(Sender: TObject);
    procedure afTrackBarChange(Sender: TObject);
    procedure basicBitBtnClick(Sender: TObject);
    procedure basichorizontalBitBtnClick(Sender: TObject);
    procedure blacklistBitBtnClick(Sender: TObject);
    procedure casTrackBarChange(Sender: TObject);
    procedure delayTrackBarChange(Sender: TObject);
    procedure durationTrackBarChange(Sender: TObject);
    procedure fpsavgBitBtnClick(Sender: TObject);
    procedure fpsonlyBitBtnClick(Sender: TObject);
    procedure fullBitBtnClick(Sender: TObject);
    procedure goverlayBitBtnClick(Sender: TObject);
    procedure intelpowerfixBitBtnClick(Sender: TObject);
    procedure intervalTrackBarChange(Sender: TObject);
    procedure logfolderBitBtnClick(Sender: TObject);
    procedure coreloadtypeBitBtnClick(Sender: TObject);
    procedure fontsizeTrackBarChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure frametimetypeBitBtnClick(Sender: TObject);
    procedure geSpeedButtonClick(Sender: TObject);
    procedure mangocolorBitBtnClick(Sender: TObject);
    procedure mangohudLabelClick(Sender: TObject);
    procedure reshaderefreshBitBtnClick(Sender: TObject);
    procedure runvkbasaltItemClick(Sender: TObject);
    procedure savecustomItemClick(Sender: TObject);
    procedure runvkcubeItemClick(Sender: TObject);
    procedure minusButtonClick(Sender: TObject);
    procedure mipmapTrackBarChange(Sender: TObject);
    procedure goverlayPaintBoxPaint(Sender: TObject);
    procedure pcidevComboBoxChange(Sender: TObject);
    procedure plusSpeedButtonClick(Sender: TObject);
    procedure popupBitBtnClick(Sender: TObject);
    procedure saveBitBtnClick(Sender: TObject);
    procedure subBitBtnClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure transpTrackBarChange(Sender: TObject);
    procedure SetAllCheckBoxesToFalse;
    procedure SetAllCheckBoxesToTrue;
    procedure usercustomBitBtnClick(Sender: TObject);
    procedure vkbasaltLabelClick(Sender: TObject);
    procedure whitecolorBitBtnClick(Sender: TObject);


  private
    FStartTick: Cardinal;
  public


  end;



var
  goverlayform: Tgoverlayform;

  s: string;
  Color: string;

  ORIENTATION, HUDTITLE, BORDERTYPE, HUDALPHA, HUDCOLOR, FONTTYPE, FONTPATH, FONTSIZE, FONTCOLOR, HUDPOSITION, TOGGLEHUD, HIDEHUD, HUDCOMPACT, PCIDEV, TABLECOLUMNS: string; //visualtab
GPUAVGLOAD, GPULOADCHANGE, GPULOADCOLOR , GPULOADVALUE, VRAM, VRAMCOLOR, IOCOLOR, GPUFREQ, GPUMEMFREQ, GPUTEMP, GPUMEMTEMP, GPUJUNCTEMP, GPUFAN, GPUPOWER, GPUTHR, GPUTHRG, GPUMODEL, VULKANDRIVER, GPUVOLTAGE: string;  //metrics tab - GPU
CPUAVGLOAD, CPULOADCORE, CPULOADCHANGE, CPUCOLOR, CPULOADCOLOR, CPULOADVALUE, CPUCOREFREQ, CPUTEMP, CORELOADTYPE, CPUPOWER, GPUTEXT, GPUCOLOR, CPUTEXT, RAM, RAMCOLOR, IOSTATS, IOREAD, IOWRITE, SWAP, PROCMEM: string; //metrics tab - CPU
FPS, FPSAVG,FRAMETIMING, SHOWFPSLIM, FRAMECOUNT, FRAMETIMEC, HISTOGRAM, FPSLIM, FPSLIMMET, FPSCOLOR, FPSVALUE, FPSCHANGE, VSYNC, GLVSYNC, FILTER, AFFILTER, MIPMAPFILTER, FPSLIMTOGGLE, OFFSET: string; //performance tab
DISTROINFO1, DISTROINFO2, DISTROINFO3, DISTROINFO4, DISTRONAME, ARCH, RESOLUTION, SESSION, SESSIONTXT, USERSESSION, TIME, WINE, WINECOLOR, ENGINE, ENGINECOLOR, ENGINESHORT, HUDVERSION,GAMEMODE: string; //extra tab
VKBASALT, FCAT, FSR, HDR, WINESYNC, VPS, FTEMP, REFRESHRATE, BATTERY, BATTERYCOLOR, BATTERYWATT, BATTERYTIME, DEVICE,DEVICEICON, MEDIA, MEDIACOLOR, CUSTOMCMD1, CUSTOMCMD2, LOGFOLDER, LOGDURATION, LOGDELAY, LOGINTERVAL, LOGTOGGLE, LOGVER, LOGAUTO, NETWORK: string; //extratab
BlacklistStr, blacklistVAR, RepoDir: string;





  //Boolean variables
  mangohudsel: boolean;
  vkbasaltsel: boolean;
  Found: Boolean;

  //Mangohud variables ##########################
  AUX, AUX2, MANGOHUDCFGFILE, MANGOHUDFOLDER, CUSTOMCFGFILE, BLACKLISTFILE, DATADIRS, GOVERLAYFOLDER, GPU0, LSPCI0: string;
  FONTS, FONTFOLDERS: TStringList;


  //vkbasalt variable
  VKBASALTFOLDER, VKBASALTCFGFILE : string;

  //########################################
  i, GPUNUMBER, GPUCOUNT, COLUMNS, maxValue, currentValue: integer;
  FILELINES, GPUDESC: TStringList;

  ArquivoConfig: TextFile;
  Linha: string;
  CaminhoArquivo, NomeCampo, ValorCampo: string;

  fpsArray: TStringArray;

  const
  DarkBackgroundColor = $0045403A; // dark panel color BGR
  DarkerBackgroundColor = $00232323;  // darker panel color BGR for unselected item
  DarkTextColor = clwhite;  // set light color

implementation

{$R *.lfm}


{ Tgoverlayform }






//Procedure to execute external shell commands
procedure ExecuteShellCommand(const Command: string);
var
  Process: TProcess;
  Output: TStringList;
  begin
    Process := TProcess.Create(nil);
    try
      Process.Executable := FindDefaultExecutablePath('sh');
      Process.Parameters.Add('-c');
      Process.Parameters.Add(Command);
      Process.Options := [poUsePipes];
      Process.Execute;
    finally
      Process.Free;
    end;
  end;



//Procedure to execute external GUI aps
procedure ExecuteGUICommand(const Command: string);
var
  Process: TProcess;
begin
  Process := TProcess.Create(nil);
  try
    Process.Executable := FindDefaultExecutablePath('sh');
    Process.Parameters.Add('-c');
    Process.Parameters.Add(Command);
    Process.Options := [poUsePipes];
    Process.Execute;
    sleep(200); //wait 0.2sec for GUI to initiate
  finally
    Process.Free;
  end;
end;

//Function to convert color codes to #RRGGBB format
function ColorToHTMLColor(const AColor: TColor): string;
var
  Red, Green, Blue: Byte;
begin
  Red := Byte(AColor); // Red component
  Green := Byte(AColor shr 8); // green component
  Blue := Byte(AColor shr 16); // blue component

  Result := Format('%.2x%.2x%.2x', [Red, Green, Blue]); // Formata a string no formato HTML (#RRGGBB)
end;


//Function to get user config directory
function GetUserConfigDir(): String;
var
  UserConfig: String;
begin;
  UserConfig := GetEnvironmentVariable('XDG_CONFIG_HOME');
  if not DirectoryExists(UserConfig) then
  begin
    UserConfig := GetUserDir + '.config';
  end;
  Result := UserConfig;
end;


//Function to get icon file
function GetIconFile(): String;
var
    Dirs: TStringDynArray;
    IconFile: String;
begin;
    DATADIRS := GetEnvironmentVariable('XDG_DATA_DIRS');
    IconFile := '/usr/share/icons/hicolor/128x128/apps/goverlay.png';
    if Length(DATADIRS) > 0 then
    begin
        Dirs := SplitString(DATADIRS, ':');
        for i := Low(Dirs) to High(Dirs) do
        begin
            IconFile := Dirs[i] + '/icons/hicolor/128x128/apps/goverlay.png';
            if FileExists(IconFile) then
            begin
                Break;
            end;
        end;
    end;
    Result := IconFile;
end;


//Function to load strings from fc-list
function LoadFont(const Parametro: string; out Valor: TStringList): Boolean;
const
  BUF_SIZE = 2048;
var
  Process: TProcess;
  Output: TStream;
  BytesRead: longint;
  Buffer: array[1..BUF_SIZE] of byte;
begin
  Process := TProcess.Create(nil);
  Output := TMemoryStream.Create;
  Valor := TStringList.Create;
  Valor.Sorted := True;
  Valor.Duplicates := dupIgnore;

  Process.Executable := FindDefaultExecutablePath('sh');
  Process.Parameters.Add('-c');
  Process.Parameters.Add('fc-list -f "%{file}\n" :lang=en:fontformat=TrueType');
  Process.Options := [poUsePipes];
  Process.Execute;

  repeat
    BytesRead := Process.Output.Read(Buffer, BUF_SIZE);

    Output.Write(Buffer, BytesRead)

  until BytesRead = 0;  // Stop if no more data is available

  Process.Free;

  with TStringList.Create do
  begin
    Output.Position := 0; // Required to make sure all data is copied from the start
    LoadFromStream(Output);
    Valor.Text := StringReplace(Text, '\n', LineEnding, [rfReplaceAll, rfIgnoreCase]);
    Free
  end;

  Output.Free;

  Result := Valor.Text <> ''; // Return true if value is located, false if not
end;


//Procedure to find font files (*.ttf)
procedure ListarFontesNoDiretorio(ComboBox: TComboBox);
var
  Arquivos: TStringList;
  Arquivo: String;
begin
  Arquivos := TStringList.Create;

  if LoadFont('fonts', FONTS) then
  begin
    Arquivos := FONTS;
  end
  else
  begin
    Arquivos := FindAllFiles('/usr/share/fonts', '*.ttf');
  end;

  try
    for Arquivo in Arquivos do
    begin
      ComboBox.Items.Add(ExtractFileName(Arquivo)); // Add filename into combobox
    end;
  finally
    Arquivos.Free; // Free memory
  end;
end;


//Procedure to find font directories
procedure ListFontDirectories(out Dirs: TStringList);
var
  Arquivos: TStringList;
  Arquivo: String;
begin
  Arquivos := TStringList.Create;

  if LoadFont('fonts', FONTS) then
  begin
    Arquivos := FONTS;
    try
      for Arquivo in Arquivos do
      begin
        Dirs.Add(ExtractFileDir(Arquivo));
      end;
    finally
      Arquivos.Free; // Free memory
    end;
  end;
end;


//Procedure to WriteConfig to file
Procedure WriteConfig(PARAMETRO, FILEPATH: string);
var
  Process: TProcess;
begin
   ExecuteShellCommand('echo "' + PARAMETRO + '" >> "' + FILEPATH + '"');
end;


//Procedure to WriteConfig to file if checkbox is checked
Procedure WriteCheckboxConfig(CHECKBOXNAME: TCheckbox; PARAMETRO, FILEPATH: string);
var
  Process: TProcess;
begin

    if CHECKBOXNAME.checked = true then
    begin
    Process := TProcess.Create(nil);
    Process.Executable := FindDefaultExecutablePath('sh');
    Process.Parameters.Add('-c');
    Process.Parameters.Add('echo ' + PARAMETRO + ' >> ' + FILEPATH);
    Process.Options := [poWaitOnExit, poUsePipes];
    Process.Execute;
    Process.Free;
    end;

  end;


//Procedure to store info from checkboxes
procedure SaveCheckbox(CHECKBOXNAME: TCheckbox; var VARNAME: string; const VALUE: string);

begin
    if CHECKBOXNAME.checked = true then
      VARNAME := VALUE;
end;

//Procedure to store info from Radiobuttons
procedure SaveRadioButton(RADIOBUTTONNAME: TRadioButton; var VARNAME: string; const VALUE: string);

begin
    if RADIOBUTTONNAME.checked = true then
      VARNAME := VALUE;
end;





// ########   Function Load strings with values from mangohud variables
function LoadValue(const Parametro: string; out Valor: string): Boolean;
var
  Process: TProcess;
  Output: TStringList;
  CaminhoArquivo: string;
begin
  Process := TProcess.Create(nil);
  Output := TStringList.Create;

  CaminhoArquivo := GetUserConfigDir + '/MangoHud/MangoHud.conf';

  Process.Executable := FindDefaultExecutablePath('sh');
  Process.Parameters.Add('-c');
  Process.Parameters.Add('cat ' +  CaminhoArquivo);
  Process.Options := [poUsePipes];
  Process.Execute;

  Output.LoadFromStream(Process.Output);

  Valor := Output.Values[Parametro];

   // Debug
  WriteLn('Parametro: ', Parametro);
  WriteLn('Value: ', Valor);


Result := Valor <> ''; // Retorna verdadeiro se o valor foi encontrado, falso caso contrário
end;


// ########   Function to Load strings from mangohud variables
function LoadName(const AParametro: string): Boolean;
var
  Lines: TStringList;
  RawLine, KeyName: string;
  SepPos, i: Integer;
  ConfigPath: string;
begin
  ConfigPath := IncludeTrailingPathDelimiter(GetUserConfigDir) +
                'MangoHud/MangoHud.conf';

  Result := False;
  if not FileExists(ConfigPath) then
    Exit;

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(ConfigPath);

    for i := 0 to Lines.Count - 1 do
    begin
      RawLine := Trim(Lines[i]);

      // só ignora linhas vazias
      if RawLine = '' then
        Continue;

      // separa chave/valor ou considera toda a linha como chave
      SepPos := Pos('=', RawLine);
      if SepPos > 0 then
        KeyName := Trim(Copy(RawLine, 1, SepPos-1))
      else
        KeyName := RawLine;

      // compara chave exata (case‑insensitive)
      if SameText(KeyName, AParametro) then
      begin
        Result := True;
        Exit;
      end;
    end;
  finally
    Lines.Free;
  end;
end;





//Function to convert hexadecimal to TColor
function HexToColor(const HexValue: string): TColor;
begin
  Result := RGBToColor(StrToInt('$' + Copy(HexValue, 1, 2)),
                       StrToInt('$' + Copy(HexValue, 3, 2)),
                       StrToInt('$' + Copy(HexValue, 5, 2)));
end;


//Procedure to uncheck all checkboxes
procedure Tgoverlayform.SetAllCheckBoxesToFalse;
var
  i: Integer;
begin
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TCheckBox then
      (Components[i] as TCheckBox).Checked := False;
  end;
end;


//Procedure to check all checkboxes
procedure Tgoverlayform.SetAllCheckBoxesToTrue;
var
  i: Integer;
begin
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TCheckBox then
      (Components[i] as TCheckBox).Checked := True;
  end;
end;


//Function to check for dependencies
function IsCommandAvailable(const Cmd: string): Boolean;
begin
  Result := FindDefaultExecutablePath(Cmd) <> '';
end;

function LibraryExists(const LibName: string): Boolean;
const
  SearchPaths: array[0..2] of string = (
    '/usr/lib/',
    '/usr/lib64/',
    '/usr/local/lib/'
  );
var
  Path: string;
begin
  Result := False;
  for Path in SearchPaths do
    if FileExists(Path + LibName) then
      Exit(True);
end;


// Function to check for kernel modules
function IsKernelModuleAvailable(const ModuleName: string): Boolean;
var
  AProcess: TProcess;
  OutputLines: TStringList;
begin
  Result := False;
  AProcess := TProcess.Create(nil);
  OutputLines := TStringList.Create;
  try
    AProcess.Executable := FindDefaultExecutablePath('lsmod');
    AProcess.Options := [poUsePipes];
    AProcess.Execute;
    OutputLines.LoadFromStream(AProcess.Output);
    Result := OutputLines.Text.Contains(ModuleName);
  finally
    AProcess.Free;
    OutputLines.Free;
  end;
end;


//Function to check for dependencies
function CheckDependencies(out Missing: TStringList): Boolean;
begin
  Missing := TStringList.Create;

  //check if mangohud if avaiable
  if not IsCommandAvailable('mangohud') then
    Missing.Add('mangohud');

  //check if vkcube is avaiable
  if not IsCommandAvailable('vkcube') then
    Missing.Add('vkcube');

   //check if zenergy module is avaiable
  //if not IsKernelModuleAvailable('zenergy') then
  //  Missing.Add('- zenergy kernel module');

  Result := Missing.Count = 0;
end;


//Function to get kernel version
function GetKernelVersion: string;
var
  Output: TStringList;
  AProcess: TProcess;
begin
  Result := '';
  AProcess := TProcess.Create(nil);
  Output := TStringList.Create;
  try
    AProcess.Executable := FindDefaultExecutablePath('uname');
    AProcess.Parameters.Add('-r');
    AProcess.Options := [poWaitOnExit, poUsePipes];
    AProcess.Execute;

    Output.LoadFromStream(AProcess.Output);
    if Output.Count > 0 then
      Result := Trim(Output[0]);  // Remove spaces
  finally
    Output.Free;
    AProcess.Free;
  end;
end;


procedure SaveDistroInfo;
var
  DistroInfo, VersionOrBuildID, KernelVersion, Line: string;
  SL: TStringList;
  SavePath: string;
  OutputSL: TStringList;
begin
  DistroInfo := '';
  VersionOrBuildID := '';
  SavePath := GetUserConfigDir + '/goverlay';

  // check if /etc/os-release exists
  if FileExists('/etc/os-release') then
  begin
    SL := TStringList.Create;
    try
      SL.LoadFromFile('/etc/os-release');

      for Line in SL do
      begin
        if Pos('PRETTY_NAME=', Line) = 1 then
          DistroInfo := StringReplace(Line, 'PRETTY_NAME=', '', []);
        if Pos('VERSION_ID=', Line) = 1 then
          VersionOrBuildID := StringReplace(Line, 'VERSION_ID=', '', []);
        if (Pos('BUILD_ID=', Line) = 1) and (VersionOrBuildID = '') then
          VersionOrBuildID := StringReplace(Line, 'BUILD_ID=', '', []);
      end;

      // remove aspas
      DistroInfo := StringReplace(DistroInfo, '"', '', [rfReplaceAll]);
      VersionOrBuildID := StringReplace(VersionOrBuildID, '"', '', [rfReplaceAll]);
    finally
      SL.Free;
    end;
  end;

  KernelVersion := GetKernelVersion;

  // create config dir if needed
  if not DirectoryExists(SavePath) then
    CreateDir(SavePath);

  // salvar Distro
  OutputSL := TStringList.Create;
  try
    OutputSL.Text := DistroInfo + ' (' + VersionOrBuildID + ')';
    OutputSL.SaveToFile(SavePath + '/distro');

    OutputSL.Text := KernelVersion;
    OutputSL.SaveToFile(SavePath + '/kernel');
  finally
    OutputSL.Free;
  end;
end;








procedure Tgoverlayform.usercustomBitBtnClick(Sender: TObject);
begin

  // Update the config files path
   CUSTOMCFGFILE := GetUserConfigDir + '/MangoHud/custom.conf';
   MANGOHUDCFGFILE := GetUserConfigDir + '/MangoHud/MangoHud.conf';




if not FileExists(CUSTOMCFGFILE) then
begin
  ShowMessage('You need to save a custom preset first. Click on the hamburguer menu and click save as custom config.');
end

else
begin
  ExecuteShellcommand('cp ' + CUSTOMCFGFILE + ' ' + MANGOHUDCFGFILE);
end;

  // Change button color
  fullBitbtn.Color:=clDefault;
  basicBitbtn.Color:=clDefault;
  basichorizontalBitbtn.Color:=clDefault;
  fpsonlyBitbtn.Color:=clDefault;
  usercustomBitbtn.Color:=$007F5500;

  ExecuteShellcommand('notify-send -e -i ' + GetIconFile + ' "MangoHud" "Reloading custom user preset"');

  end;

procedure Tgoverlayform.vkbasaltLabelClick(Sender: TObject);
begin
  //Disable tabs
  goverlayPageControl.ShowTabs:=false;

  //unselecte mangohud
  mangohudLabel.Font.Color:=clgray;
  mangohudShape.Brush.Color:= DarkerBackgroundColor;

  // select vkbasalt
  vkbasaltLabel.Font.Color:=clwhite;
  vkbasaltShape.Brush.Color:= DarkBackgroundColor;
  vkbasalttabsheet.TabVisible:=true;
  goverlayPageControl.ActivePage:=vkbasaltTabsheet;


  //Activate vkbasalt effects
  ExecuteGUICommand('killall pascube');
  ExecuteShellCommand('notify-send -e -i ' + GetIconFile + ' "Goverlay" "Activating vkbasalt effects"');
  ExecuteGUICommand('VKBASALT_LOG_FILE=' + VKBASALTFOLDER + '/' + 'vkBasalt.log ENABLE_VKBASALT=1 MESA_LOADER_DRIVER_OVERRIDE=zink mangohud QT_QPA_PLATFORM=xcb ./pascube &');
  //ExecuteGUICommand('VKBASALT_LOG_FILE=' + VKBASALTFOLDER + '/' + 'vkBasalt.log ENABLE_VKBASALT=1' + RunPasCube ');

end;

procedure Tgoverlayform.whitecolorBitBtnClick(Sender: TObject);
begin
  //Set mangohud colors
hudbackgroundColorButton.ButtonColor:= clblack;

fontColorButton.ButtonColor := clwhite;
gpuload1ColorButton.ButtonColor:=fontColorButton.ButtonColor;
cpuload1ColorButton.ButtonColor:=fontColorButton.ButtonColor;

gpuColorButton.ButtonColor:=clwhite;
cpuColorButton.ButtonColor:=clwhite;
vramColorButton.ButtonColor:=clwhite;
ramColorButton.ButtonColor:=clwhite;
iordrwColorButton.ButtonColor:=clwhite;
wineColorButton.ButtonColor:=clwhite;
engineColorButton.ButtonColor:=clwhite;
batteryColorButton.ButtonColor:= clwhite;
mediaColorButton.ButtonColor:= clwhite;
frametimegraphColorButton.ButtonColor:= clwhite;


//Save button
saveBitbtn.Click;
end;


//Function for allowed interface types
function IsInterfaceAllowed(const Name: String): Boolean;
begin
  Result :=
    Name.StartsWith('eth') or   // Ethernet tradicional
    Name.StartsWith('enp') or   // Ethernet com nomes modernos
    Name.StartsWith('wlan') or  // Wi-Fi tradicional
    Name.StartsWith('wlp');     // Wi-Fi com nomes modernos
end;


//Procedure to list network interfaces
procedure GetNetworkInterfaces(ComboBox: TComboBox);
var
  AProcess: TProcess;
  Output: TStringList;
  Line, InterfaceName: String;
  SepPos: Integer;
  i: Integer;
begin
  AProcess := TProcess.Create(nil);
  Output := TStringList.Create;
  try
    AProcess.Executable := FindDefaultExecutablePath('ip');
    AProcess.Parameters.Add('link');
    AProcess.Options := [poUsePipes, poWaitOnExit, poNoConsole];
    AProcess.Execute;

    Output.LoadFromStream(AProcess.Output);

    ComboBox.Items.Clear;

    for i := 0 to Output.Count - 1 do
    begin
      Line := Trim(Output[i]);

      // Verifica se a linha inicia com número + ": "
      if (Line <> '') and (CharInSet(Line[1], ['0'..'9'])) then
      begin
        SepPos := Pos(': ', Line);
        if SepPos > 0 then
        begin
          InterfaceName := Copy(Line, SepPos + 2, Pos(':', Line, SepPos + 2) - SepPos - 2);

          if IsInterfaceAllowed(InterfaceName) then
            ComboBox.Items.Add(InterfaceName);
        end;
      end;
    end;
  finally
    Output.Free;
    AProcess.Free;
  end;
end;




// Procedure to search for values in a checkbox
procedure LoadCheckgroup(const ACheckGroup: TCheckGroup; const AString: string);
var
  Values: TStringDynArray;
  i, j: Integer;
begin
  // Divide a string em substrings usando a vírgula como delimitador
  Values := SplitString(AUX, ',');

  // Percorre cada valor na string
  for i := Low(Values) to High(Values) do
  begin
    // Remove espaços em branco em excesso antes e depois do valor
    Values[i] := Trim(Values[i]);

    // Percorre todos os itens do TCheckGroup
    for j := 0 to ACheckGroup.Items.Count - 1 do
    begin
      // Verifica se o valor da substring é igual ao valor do item
      if Values[i] = ACheckGroup.Items[j] then
      begin
        // Marca o checkbox correspondente
        ACheckGroup.Checked[j] := True;
        // Pode sair do loop interno, pois já encontrou correspondência para este valor
        Break;
      end;
    end;
  end;
end;


function GetTickCount: Cardinal;
var
  tv: TTimeVal;
begin
  FpGettimeofday(@tv, nil);
  Result := (tv.tv_sec * 1000) + (tv.tv_usec div 1000);
end;

procedure Tgoverlayform.Timer1Timer(Sender: TObject);
begin
  goverlayPaintBox.Invalidate;
end;

procedure Tgoverlayform.goverlayPaintBoxPaint(Sender: TObject);
const
  BlockSize = 4; // block size in pixels
var
  X, Y, TWidth, THeight: Integer;
  BaseR, BaseG, BaseB: Byte;
  Factor, OffsetX, OffsetY: Single;
  R, G, B: Byte;
  TimeElapsed: Single;
  RectRight, RectBottom: Integer;
begin
//Blueish
BaseR := 36;  // 0x24
BaseG := 50;  // 0x32
BaseB := 70;  // 0x46


  TWidth := goverlayPaintBox.Width;
  THeight := goverlayPaintBox.Height;

  TimeElapsed := (GetTickCount - FStartTick) / 1000;

  Y := 0;
  while Y < Height do
  begin
    X := 0;
    while X < Width do
    begin
      // Smaller coeeficients in X and Y gets bigger effects
      // Smaller timeelapsed get slower speeds
    //  OffsetX := Sin((X * 0.01) + TimeElapsed * 0.5) + Sin((Y * 0.02) + TimeElapsed * 0.65);
    //  OffsetY := Cos((X * 0.015) - TimeElapsed * 0.4) + Cos((Y * 0.01) - TimeElapsed * 0.5);
      OffsetX := Sin((X * 0.01) + TimeElapsed * 0.5) + Sin((Y * 0.015) + TimeElapsed * 0.6);
      OffsetY := Cos((X * 0.015) - TimeElapsed * 0.4) + Cos((Y * 0.01) - TimeElapsed * 0.45);

      Factor := 0.3 + 0.35 * (OffsetX + 1) + 0.35 * (OffsetY + 1);
      if Factor > 1.0 then Factor := 1.0;
      if Factor < 0.3 then Factor := 0.3;

      R := Round(BaseR * Factor);
      G := Round(BaseG * Factor);
      B := Round(BaseB * Factor);

      // Define o retângulo do bloco, tomando cuidado para não ultrapassar os limites
      RectRight := X + BlockSize - 1;
      if RectRight >= Width then
        RectRight := Width - 1;

      RectBottom := Y + BlockSize - 1;
      if RectBottom >= Height then
        RectBottom := Height - 1;

      goverlayPaintBox.Canvas.Brush.Color := RGBToColor(R, G, B);
      goverlayPaintBox.Canvas.FillRect(Rect(X, Y, RectRight + 1, RectBottom + 1));

      Inc(X, BlockSize);
    end;
    Inc(Y, BlockSize);
  end;
end;



//Procedure to force dark theme on elements



procedure SetDarkColorsRecursively(AControl: TWinControl);
var
  i: Integer;
  ctrl: TControl;
begin


  for i := 0 to AControl.ControlCount - 1 do
  begin
    ctrl := AControl.Controls[i];

    if ctrl is TLabel then
      TLabel(ctrl).Font.Color := DarkTextColor
    else if ctrl is TCheckBox then
      TCheckBox(ctrl).Font.Color := DarkTextColor
    else if ctrl is TGroupBox then
    begin
      TGroupBox(ctrl).Font.Color := DarkTextColor;
      TGroupBox(ctrl).Color := DarkBackgroundColor;
      if TGroupBox(ctrl) is TWinControl then
        SetDarkColorsRecursively(TWinControl(ctrl));
    end
    else if ctrl is TCheckGroup then
    begin
      TCheckGroup(ctrl).Font.Color := DarkTextColor;
      TCheckGroup(ctrl).Color := DarkBackgroundColor;
      if TCheckGroup(ctrl) is TWinControl then
        SetDarkColorsRecursively(TWinControl(ctrl));
    end
    else if ctrl is TRadioGroup then
    begin
      TRadioGroup(ctrl).Font.Color := DarkTextColor;
      TRadioGroup(ctrl).Color := DarkBackgroundColor;
    end
    else if ctrl is TBitBtn then
    begin
      TBitBtn(ctrl).Font.Color := DarkTextColor;
      TBitBtn(ctrl).Color := DarkBackgroundColor;
    end
    else if ctrl is TColorButton then
      TColorButton(ctrl).Color := DarkBackgroundColor
    else if ctrl is TWinControl then
      SetDarkColorsRecursively(TWinControl(ctrl))

  end;
end;

//Functions for shaders

// Lista arquivos do diretório BaseDir no ListBox, opcionalmente filtrando por extensões.
// Ex.: FilterExts = []  -> lista tudo
//      FilterExts = ['.fx', '.fxh'] -> lista apenas efeitos ReShade
procedure ListFilesToListBox(const BaseDir: string; ListBox: TListBox;
  const FilterExts: array of string; const Recursive: Boolean = True;
  const SkipDotDirs: Boolean = True);

  function HasAllowedExt(const FileName: string): Boolean;
  var
    i: Integer;
    E: String;
  begin
    if Length(FilterExts) = 0 then
      Exit(True);
    E := LowerCase(ExtractFileExt(FileName));
    for i := 0 to High(FilterExts) do
      if E = LowerCase(FilterExts[i]) then
        Exit(True);
    Result := False;
  end;

  function RelativeToBase(const FullPath, Base: string): string;
  var
    A, B: String;
  begin
    A := ExpandFileName(FullPath);
    B := IncludeTrailingPathDelimiter(ExpandFileName(Base));
    Result := A;
    if Pos(B, A) = 1 then
      Delete(Result, 1, Length(B));
  end;

  procedure Scan(const Dir: string);
  var
    SR: TSearchRec;
    Path, Child: String;
  begin
    Path := IncludeTrailingPathDelimiter(Dir);
    if FindFirst(Path + '*', faAnyFile, SR) = 0 then
    begin
      try
        repeat
          if (SR.Name = '.') or (SR.Name = '..') then
            Continue;

          Child := Path + SR.Name;

          if (SR.Attr and faDirectory) <> 0 then
          begin
            // pula pastas ocultas (.git, .github, etc.) se desejado
            if SkipDotDirs and (Length(SR.Name) > 0) and (SR.Name[1] = '.') then
              Continue;
            if Recursive then
              Scan(Child);
          end
          else
          begin
            if HasAllowedExt(SR.Name) then
              ListBox.Items.Add(RelativeToBase(Child, BaseDir));
          end;
        until FindNext(SR) <> 0;
      finally
        FindClose(SR);
      end;
    end;
  end;

begin
  ListBox.Items.BeginUpdate;
  try
    ListBox.Items.Clear;
    Scan(BaseDir);
    // Ordena no final (opcional)
    // Obs.: se você quiser manter a hierarquia natural, comente a linha abaixo.
    ListBox.Sorted := True;
  finally
    ListBox.Items.EndUpdate;
  end;
end;

procedure Tgoverlayform.FormCreate(Sender: TObject);

var
 // Process: TProcess;
  AppHandle: THandle;
  saida, Output, FileLines, DefaultConfigContent: TStringList;
  i: Integer;
  ConfigFilePath,ConfigFileBlacklistPath, ConfigDir,ConfigBlacklistDir: string;

  FPSList: TStringList;
  ConfigFile: TStringList;
  Line, FPSValues, OffsetValue: string;
  Offset, FPS, MaxFPS: Integer;
  FPSNumbers: TStringList;
  FoundFPSLimit: Boolean;
  Missing: TStringList;
  OSFile: TextFile;


begin

  //Set initial TAB
  goverlayPageControl.ActivePage:=presetTabsheet;

   // Initialize menu selections
  mangohudsel := true;
  mangohudPanel.Visible:=true;
  vkbasaltsel := false;


  // Force dark theme
  presettabsheet.Color:= DarkBackgroundColor;
  SetDarkColorsRecursively(Self); //set all elements to dark tones
  saveBitbtn.Color:=$00008300; //Save button color exception
  notificationLabel.Font.color:=clyellow; //color exception
  vkbasaltLabel.Font.Color:=clgray;

  //Turbulence animation start
  FStartTick := GetTickCount;
  Timer1.Interval := 50; // 20 fps aprox
  Timer1.Enabled := True;
  Timer1.OnTimer := @Timer1Timer;
  goverlayPaintBox.OnPaint := @goverlayPaintBoxPaint;


   // Ajust tab text color
  for i := 0 to goverlayPageControl.PageCount - 1 do
  begin
    goverlayPageControl.Pages[i].Font.Color := clBtnText;
  end;

  // fix for radiobutton wrong colors
  topleftRadiobutton.Color:=clDefault;
  topcenterRadiobutton.Color:=clDefault;
  toprightRadiobutton.Color:=clDefault;
  bottomleftRadiobutton.Color:=clDefault;
  bottomrightRadiobutton.Color:=clDefault;
  bottomcenterRadiobutton.Color:=clDefault;
  middleleftRadiobutton.Color:=clDefault;
  middlerightRadiobutton.Color:=clDefault;


  // Define important file paths
  GOVERLAYFOLDER := GetUserConfigDir + '/goverlay/';
  MANGOHUDFOLDER := GetUserConfigDir + '/MangoHud/';
  MANGOHUDCFGFILE := GetUserConfigDir + '/MangoHud/MangoHud.conf';
  BLACKLISTFILE := GetUserConfigDir + '/goverlay/blacklist.conf';
  CUSTOMCFGFILE := GetUserConfigDir + '/MangoHud/custom.conf';
  USERSESSION := GetEnvironmentVariable('XDG_SESSION_TYPE');

  VKBASALTFOLDER := GetUserConfigDir + '/vkBasalt/';
  VKBASALTCFGFILE := GetUserConfigDir + '/vkBasalt/vkBasalt.conf';
  RepoDir := IncludeTrailingPathDelimiter(VKBASALTFOLDER) + 'reshade-shaders';


  //if reshade dir exists just load the files and enable fields
  if DirectoryExists(RepoDir) then
  begin
   //ShowMessage('diretorio existe".');
  ListFilesToListBox(RepoDir, aveffectsListbox, ['.fx', '.fxh', '.h', '.glsl']);

  //Enable elements
   aveffectsListbox.Enabled:=true;
   acteffectsListbox.Enabled:=true;
   addBitbtn.Enabled:=true;
   subBitbtn.Enabled:=true;

  //Enable update button
  reshaderefreshBitbtn.Enabled:=true;
  end;

  //Disable custom theme button if file doesnt exist
  if not FileExists(CUSTOMCFGFILE) then
  begin
    usercustomBitbtn.Enabled:=false;
    usercustomBitbtn.Hint:='Save a custom.conf file load the custom config';
  end;


  //Get distro information
  SaveDistroInfo;


  //Check for dependencies
   if CheckDependencies(Missing) then
   begin
    dependencieSpeedbutton.ImageIndex := 0 ; //green icon
    dependenciesLabel.Caption := 'All dependencies OK' ;
   end
  else
  begin
    dependencieSpeedbutton.ImageIndex := 1 ;  //red icon
    dependenciesLabel.Caption := ('Missing: ' + LineEnding + Missing.Text);
  end;
  Missing.Free;


   //Check if mangohud file exists
   ConfigFilePath := MANGOHUDCFGFILE;
   ConfigDir := ExtractFilePath(ConfigFilePath);

   // check if directory exists
   if not DirectoryExists(ConfigDir) then
     CreateDir(ConfigDir);

   // check if files exists
   if not FileExists(ConfigFilePath) then
   begin


    // shot notification
    ExecuteShellCommand('notify-send -e -i ' + GetIconFile + ' "Goverlay" "No configuration files located, creating files and folders."');


  // estado padrão ao iniciar
  aveffectsListbox.Enabled := False;
  addBitbtn.Enabled := False;
  subBitbtn.Enabled := False;




     // Create stock mangohud config
     DefaultConfigContent := TStringList.Create;
     try
       DefaultConfigContent.Text :=
         '################### File Generated by Goverlay ###################' + LineEnding +
         '' + LineEnding +
         'legacy_layout=false' + LineEnding +
         'background_alpha=0.6' + LineEnding +
         'round_corners=0' + LineEnding +
         'background_color=000000' + LineEnding +
         'font_size=24' + LineEnding +
         'text_color=FFFFFF' + LineEnding +
         'position=top-left' + LineEnding +
         'table_columns=3' + LineEnding +
         'gpu_text=GPU' + LineEnding +
         'gpu_stats' + LineEnding +
         'gpu_core_clock' + LineEnding +
         'gpu_mem_clock' + LineEnding +
         'gpu_temp' + LineEnding +
         'gpu_power' + LineEnding +
         'gpu_color=2E9762' + LineEnding +
         'cpu_text=CPU' + LineEnding +
         'cpu_stats' + LineEnding +
         'cpu_mhz' + LineEnding +
         'cpu_temp' + LineEnding +
         'cpu_power' + LineEnding +
         'cpu_color=2E97CB' + LineEnding +
         'vram' + LineEnding +
         'vram_color=AD64C1' + LineEnding +
         'ram' + LineEnding +
         'ram_color=C26693' + LineEnding +
         'battery' + LineEnding +
         'battery_color=00FF00' + LineEnding +
         'fps' + LineEnding +
         'frame_timing' + LineEnding +
         'frametime_color=00FF00' + LineEnding +
         'fps_limit_method=late' + LineEnding +
         'fps_limit=0' + LineEnding +
         'log_duration=30' + LineEnding +
         'autostart_log=0' + LineEnding +
         'log_interval=100';

       // save file content
       DefaultConfigContent.SaveToFile(ConfigFilePath);
     finally
       DefaultConfigContent.Free;
     end;
   end;


  // Check directory  -  BLACKLIST
  BLACKLISTFILE := GetUserConfigDir + '/goverlay/blacklist.conf';

  // make sure directory exists -  BLACKLIST
  ForceDirectories(ExtractFilePath(BLACKLISTFILE));

  // Check if file exists and create default - BLACKLIST
  if not FileExists(BLACKLISTFILE) then
  begin
    FileLines := TStringList.Create;
    try
      FileLines.Add('zenity');
      FileLines.Add('protonplus');
      FileLines.Add('lsfg-vk-ui');
      FileLines.Add('bazzar');
      FileLines.Add('gnome-calculator');
      FileLines.Add('pamac-manager');
      FileLines.Add('lact');
      FileLines.Add('ghb');
      FileLines.Add('bitwig-studio');
      FileLines.Add('ptyxis');
      FileLines.Add('yumex');
      FileLines.SaveToFile(BLACKLISTFILE);
    finally
      FileLines.Free;
    end;
  end;

  // Check vkbasalt directory
  VKBASALTCFGFILE := GetUserConfigDir + '/vkBasalt/vkBasalt.conf';

  // make sure directory exists - VKBASALT
  ForceDirectories(ExtractFilePath(VKBASALTCFGFILE));


    // Check if file exists and create default - VKBASALT
  if not FileExists(VKBASALTCFGFILE) then
  begin
    ExecuteShellCommand('notify-send -e -i ' + GetIconFile + ' "Goverlay" "No configuration files located for vkbasalt, creating files and folders."');
    FileLines := TStringList.Create;
    try
      FileLines.Add('################### File Generated by Goverlay ###################');
      FileLines.Add('effects = cas');
      FileLines.Add('casSharpness = 0.8');
      FileLines.Add('toggleKey = Home');
      FileLines.Add('enableOnLaunch = True');

      FileLines.SaveToFile(VKBASALTCFGFILE);
    finally
      FileLines.Free;
    end;
  end;



  // Start vkcube (vulkan demo)
 // if USERSESSION = 'wayland' then
 //   ExecuteGUICommand('mangohud vkcube --wsi wayland &')
 // else
 //   ExecuteGUICommand('mangohud vkcube &');

   // Start pasCube
   RunPasCube;

  //Load avaiable text fonts
   ListarFontesNoDiretorio(fontComboBox);


  //Detect system GPUs

  // Count the number of detected GPUs
  //  Process := TProcess.Create(nil);
    saida := TStringList.Create;

    Process.Executable := FindDefaultExecutablePath('sh');
    Process.Parameters.Add('-c');
    Process.Parameters.Add('lspci | grep -i "VGA\|video" | wc -l'); //Count the number of lines
    Process.Options := [poUsePipes];
    Process.WaitOnExit;
    Process.Execute;

    saida.LoadFromStream(Process.output);
    GPUNUMBER:= strtoint(saida[0]);
    Process.Free;
    saida.Free;



    i := 1; // Integer variable to the while loop
    GPUDESC := TStringList.Create;  // List variable for GPU descriptions

    while i <= GPUNUMBER do
    begin
      //Read GPU0 pcidev
      Process := TProcess.Create(nil);
      saida := TStringList.Create;

      Process.Executable := FindDefaultExecutablePath('sh');
      Process.Parameters.Add('-c');
      Process.Parameters.Add('lspci | grep -i "VGA\|video" | sed -n "' + inttostr(i) + 'p" | cut -c 1-7');  //Pick just the "i" line
      Process.Options := [poUsePipes];
      Process.WaitOnExit;
      Process.Execute;

      saida.LoadFromStream(Process.output);
      pcidevComboBox.Items.Insert(i-1, saida[0]); //First position of combobox is 0, so we need i-1
      Process.Free;
      saida.Free;


      //Read GPU description
      Process := TProcess.Create(nil);
      saida := TStringList.Create;

      Process.Executable := FindDefaultExecutablePath('sh');
      Process.Parameters.Add('-c');
      Process.Parameters.Add('lspci | grep -i "VGA\|video" | sed -n "' + inttostr(i) + 'p" |cut -d" " -f3- | cut -d ":" -f2-'); //Pick just the first line
      Process.Options := [poUsePipes];
      Process.WaitOnExit;
      Process.Execute;

      saida.LoadFromStream(Process.output);
      GPUDESC.Add(saida[0]);
      Process.Free;
      saida.Free;

      i := i + 1; //increment "i"variable



    end; //while


   //Detect network devices on startup
   GetNetworkInterfaces(networkcombobox);


     //Determine toggle position - MangoHUD
     Process := TProcess.Create(nil);
     saida := TStringList.Create;

     Process.Executable := FindDefaultExecutablePath('sh');
     Process.Parameters.Add('-c');
     Process.Parameters.Add('cat /etc/environment | grep MANGOHUD=1');
     Process.Options := [poUsePipes];
     Process.Execute;
     Process.WaitOnExit;
     saida.LoadFromStream(Process.output);


     if saida.Count > 0 then    // Count will prevent the out of bound error, case the string doesn't exist
       geSpeedbutton.ImageIndex := 1
     else
       geSpeedbutton.ImageIndex := 0;

     Process.Free;
     saida.Free;



     // Initial MANGOHUD STOCK values

     alphavalueLabel.Caption:= FormatFloat('#0.0', transpTrackbar.Position/10);
     fontsizevalueLabel.Caption:=inttostr(fontsizeTrackbar.Position);
     fontcombobox.ItemIndex:=0;
     afvalueLabel.Caption:= FormatFloat('#0', afTrackbar.Position);
     mipmapvalueLabel.Caption:= FormatFloat('#0', mipmapTrackbar.Position);
     logfolderEdit.text := GetUserDir;
     durationvalueLabel.Caption:=FormatFloat('#0', durationTrackbar.Position) +'s';
     delayvalueLabel.Caption:=FormatFloat('#0', delayTrackbar.Position) + 's' ;
     intervalvalueLabel.Caption:=FormatFloat('#0', intervalTrackbar.Position) + 'ms' ;
     columvalueLabel.Caption:='3';
     columShape.Visible:=true;
     columShape1.Visible:=true;
     columShape2.Visible:=true;
     columShape3.Visible:=false;
     columShape4.Visible:=false;
     columShape5.Visible:=false;


    // Load Mangohud config file

    //#################################################    EDITs

    //HUD TILE
    if LoadValue('custom_text_center',AUX) then
      hudtitleEdit.Text:= AUX;

    //GPU Text
    if LoadValue('gpu_text',AUX) then
      gpunameEdit.Text:= AUX;

    //CPU Text
    if LoadValue('cpu_text',AUX) then
      cpunameEdit.Text:= AUX;

    //Log folder
    if LoadValue('output_folder',AUX) then
      logfolderEdit.Text:= AUX;

     //#################################################    Trackbars

    //Background alpha
    if LoadValue('background_alpha',AUX) then
      transpTrackbar.Position :=  Round(StrToFloat(AUX) * 10);

    //Font size
    if LoadValue('font_size',AUX) then
      fontsizeTrackbar.Position :=  Round(StrToFloat(AUX));

    //AF
    if LoadValue('af',AUX) then
      afTrackbar.Position :=  Round(StrToFloat(AUX));


    //Mipmap
    if LoadValue('picmip',AUX) then
      mipmapTrackbar.Position :=  Round(StrToFloat(AUX));

    //Log duration
    if LoadValue('log_duration',AUX) then
      durationTrackbar.Position :=  Round(StrToFloat(AUX));

    //Log delay
    if LoadValue('autostart_log',AUX) then
      delayTrackbar.Position :=  Round(StrToFloat(AUX));

    //Log interval
    if LoadValue('log_interval',AUX) then
      intervalTrackbar.Position :=  Round(StrToFloat(AUX));


    //#################################################    Spinedit

    //offet
    if LoadValue('#offset',AUX) then
      offsetSpinedit.value :=  Round(StrToint(AUX) );

     //#################################################    Radio buttons

    //Orientation
    if LoadName('horizontal') then
      horizontalRadiobutton.Checked := True
    else
      verticalRadiobutton.Checked := True;

    //Round corners
    if LoadValue('round_corners',AUX) then
      begin
        if strtoint(AUX) = 0 then
          squareRadiobutton.Checked:=true
        else
          roundRadiobutton.Checked:=true;
      end;

    //Position
    if LoadValue('position',AUX) then
      begin
        case AUX of
          'top-left': topleftRadiobutton.Checked:=true;
          'top-center': topcenterRadiobutton.Checked:=true;
          'top-right': toprightRadiobutton.Checked:=true;
          'middle-right': middlerightRadiobutton.Checked:=true;
          'middle-left': middleleftRadiobutton.Checked:=true;
          'bottom-left': bottomleftRadiobutton.Checked:=true;
          'bottom-center': bottomcenterRadiobutton.Checked:=true;
          'bottom-right': bottomrightRadiobutton.Checked:=true;
        end; //case

      end; //if


     //#################################################    Checkgroups

    //FPS limits

    FPSList := TStringList.Create;
      ConfigFile := TStringList.Create;
      FPSNumbers := TStringList.Create;
      try
        MaxFPS := 0;
        FoundFPSLimit := False;

        if FileExists(MANGOHUDCFGFILE) then
        begin
          ConfigFile.LoadFromFile(MANGOHUDCFGFILE);

          // Searching for fps_limit and offset lines
          FPSValues := '';
          OffsetValue := '0';
          for Line in ConfigFile do
          begin
            if StartsText('fps_limit=', Line) then
            begin
              FPSValues := Copy(Line, Pos('=', Line) + 1, Length(Line));
              FoundFPSLimit := True;
            end;
            if StartsText('#offset=', Line) then
              OffsetValue := Copy(Line, Pos('=', Line) + 1, Length(Line));
          end;

          // Converting offset to an integer
          Offset := Abs(StrToIntDef(OffsetValue, 0));

          if FoundFPSLimit and (Trim(FPSValues) <> '0') then
          begin
            // Processing FPS values
            FPSNumbers.DelimitedText := FPSValues;
            FPSNumbers.Delimiter := ',';

            for i := 0 to FPSNumbers.Count - 1 do
            begin
              FPS := StrToIntDef(FPSNumbers[i], 0) + Offset;
              FPSList.Add(IntToStr(FPS));
              if FPS > MaxFPS then
                MaxFPS := FPS;
            end;

            // Marking values in the CheckGroup
            for i := 0 to fpslimcheckgroup.Items.Count - 1 do
            begin
              if FPSList.IndexOf(fpslimcheckgroup.Items[i]) <> -1 then
                fpslimcheckgroup.Checked[i] := True
              else
                fpslimcheckgroup.Checked[i] := False;
            end;
          end;
        end;

        // Setting values for the SpinEdits
        if (MaxFPS = 0) or (not FoundFPSLimit) then
          MaxFPS := 60;

        fpscolor3spinedit.Value := MaxFPS;
        fpscolor2spinedit.Value := Round(MaxFPS / 2);

      finally
        FPSList.Free;
        ConfigFile.Free;
        FPSNumbers.Free;
      end;


      //#################################################    Radiogroups

    //Filters
    if LoadName('bicubic') then
     filterRadiogroup.ItemIndex:=1;
    if LoadName('trilinear') then
     filterRadiogroup.ItemIndex:=2;
    if LoadName('retro') then
     filterRadiogroup.ItemIndex:=3;

     //#################################################    Comboboxes

    //Method
    if LoadValue('fps_limit_method',AUX) then
      begin
        case AUX of
          'late': fpslimmetCombobox.ItemIndex:=0;
          'early': fpslimmetCombobox.ItemIndex:=1;
        end; //case

      end; //if


    //toggle hud
    if LoadValue('toggle_hud',AUX) then
      begin
        case AUX of
          'Shift_R+F12': hudonoffCombobox.ItemIndex:=0;
          'Shift_R+F1': hudonoffCombobox.ItemIndex:=1;
          'Shift_R+F2': hudonoffCombobox.ItemIndex:=2;
          'Shift_R+F3': hudonoffCombobox.ItemIndex:=3;
          'Shift_R+F4': hudonoffCombobox.ItemIndex:=4;
          else
          hudonoffCombobox.ItemIndex:=5;

        end; //case

      end; //if


    //toggle fps limit
    if LoadValue('toggle_fps_limit',AUX) then
      begin
        case AUX of
          'Shift_L+F1': fpslimtoggleCombobox.ItemIndex:=0;
          'Shift_L+F2': fpslimtoggleCombobox.ItemIndex:=1;
          'Shift_L+F3': fpslimtoggleCombobox.ItemIndex:=2;
          'Shift_L+F4': fpslimtoggleCombobox.ItemIndex:=3;
          else
          fpslimtoggleCombobox.ItemIndex:=4;
        end; //case

      end; //if


    //vulkan vsync
    if LoadValue('vsync',AUX) then
      begin
        case AUX of
          '0': vsyncCombobox.ItemIndex:=0;
          '1': vsyncCombobox.ItemIndex:=1;
          '2': vsyncCombobox.ItemIndex:=2;
          '3': vsyncCombobox.ItemIndex:=3;
          '4': vsyncCombobox.ItemIndex:=4;
        end; //case

      end; //if

    //GL vsync
    if LoadValue('gl_vsync',AUX) then
      begin
        case AUX of
          '-1': glvsyncCombobox.ItemIndex:=0;
          '0': glvsyncCombobox.ItemIndex:=1;
          '1': glvsyncCombobox.ItemIndex:=2;
          'n': glvsyncCombobox.ItemIndex:=3;
          '3': glvsyncCombobox.ItemIndex:=4;
        end; //case

      end; //if

    //toggle logging
    if LoadValue('toggle_logging',AUX) then
      begin
        case AUX of
          'Shift_L+F2': logtoggleCombobox.ItemIndex:=0;
          'Shift_L+F3': logtoggleCombobox.ItemIndex:=1;
          'Shift_L+F4': logtoggleCombobox.ItemIndex:=2;
          'Shift_L+F5': logtoggleCombobox.ItemIndex:=3;
           else
          logtoggleCombobox.ItemIndex:=4;
        end; //case

      end; //if

    //Read system GPUs
      Process := TProcess.Create(nil);
      saida := TStringList.Create;

      Process.Executable := FindDefaultExecutablePath('sh');
      Process.Parameters.Add('-c');
      Process.Parameters.Add('lspci | grep -i "VGA\|video" | sed -n 1p | cut -c 1-7');  //Pick just the "i" line
      Process.Options := [poUsePipes];
      Process.WaitOnExit;
      Process.Execute;

      saida.LoadFromStream(Process.output);
      LSPCI0 := Trim(saida.text); // store output um variable
      GPU0 :=  pcidevCombobox.Items[0]; //store first value in variable

      Writeln ('LSPCI0: ', LSPCI0);
      Writeln ('GPU0: ', GPU0);

      if LSPCI0 = GPU0 then
       begin
        pcidevCombobox.ItemIndex:=0;
        gpudescEdit.Text:=GPUDESC[pcidevCombobox.ItemIndex];
       end
       else
        begin
          pcidevCombobox.ItemIndex:=1;
          gpudescEdit.Text:=GPUDESC[pcidevCombobox.ItemIndex];
        end;


   //#################################################    Bitbtns

    //Frametime type
    if LoadName('histogram') then
     begin
      frametimetypeBitBtn.ImageIndex:=7;
      frametimetypeBitBtn.Caption:= 'Histogram';
      frametimetypeBitBtn.Hint:='Use histogram for frametime information';
     end
    else
      begin
      frametimetypeBitBtn.ImageIndex:=8;
      frametimetypeBitBtn.Caption:= 'Curve';
      frametimetypeBitBtn.Hint:='Use regular curve for frametime information';
      end;

    //coreload type
    if LoadName('core_bars') then
     begin
      coreloadtypeBitBtn.ImageIndex:=7;
      coreloadtypeBitBtn.Caption:= 'Graph';
      coreloadtypeBitBtn.Hint:='Use vertical bars for core load';
     end
    else
      begin
      coreloadtypeBitBtn.ImageIndex:=6;
      coreloadtypeBitBtn.Caption:= 'Percent';
      coreloadtypeBitBtn.Hint:='Use percentage numbers for core load';
      end;


    //FPS avg
    if LoadName('fps_metrics=avg,0.01') then
     begin
      fpsavgCheckbox.checked:=true;
      fpsavgBitBtn.Caption:= '1% low';
      fpsavgBitBtn.Hint:='Display 1% low fps';
     end;

    if LoadName('fps_metrics=avg,0.001') then
      begin
      fpsavgCheckbox.checked:=true;
      fpsavgBitBtn.Caption:= '0.1% low';
      fpsavgBitBtn.Hint:='Display 0.1% low fps';
      end;


    //#################################################    others

    //table Columns
    if LoadValue('table_columns',AUX) then
      begin
      //showmessage ('o valor de AUX é: ' + AUX);
      case AUX of
            '1':begin
              columShape.Visible:=true;
              columShape1.Visible:=false;
              columShape2.Visible:=false;
              columShape3.Visible:=false;
              columShape4.Visible:=false;
              columShape5.Visible:=false;
              columvalueLabel.Caption:= AUX;
            end;
            '2':begin
              columShape.Visible:=true;
              columShape1.Visible:=true;
              columShape2.Visible:=false;
              columShape3.Visible:=false;
              columShape4.Visible:=false;
              columShape5.Visible:=false;
              columvalueLabel.Caption:= AUX;
            end;
            '3':begin
              columShape.Visible:=true;
              columShape1.Visible:=true;
              columShape2.Visible:=true;
              columShape3.Visible:=false;
              columShape4.Visible:=false;
              columShape5.Visible:=false;
              columvalueLabel.Caption:= AUX;
            end;
            '4':begin
              columShape.Visible:=true;
              columShape1.Visible:=true;
              columShape2.Visible:=true;
              columShape3.Visible:=true;
              columShape4.Visible:=false;
              columShape5.Visible:=false;
              columvalueLabel.Caption:= AUX;
            end;
            '5':begin
              columShape.Visible:=true;
              columShape1.Visible:=true;
              columShape2.Visible:=true;
              columShape3.Visible:=true;
              columShape4.Visible:=true;
              columShape5.Visible:=false;
              columvalueLabel.Caption:= AUX;
            end;
            '6':begin
              columShape.Visible:=true;
              columShape1.Visible:=true;
              columShape2.Visible:=true;
              columShape3.Visible:=true;
              columShape4.Visible:=true;
              columShape5.Visible:=true;
              columvalueLabel.Caption:= AUX;
            end;
          end;



      end; //if

    //#################################################    Color buttons

      //Background color button
      if LoadValue('background_color',AUX) then
        begin
          hudbackgroundColorbutton.ButtonColor:=  HexToColor(AUX);
        end;

      //Text color button
      if LoadValue('text_color',AUX) then
        begin
          FontColorbutton.ButtonColor:=  HexToColor(AUX);
        end;

      //Frametime color  button
      if LoadValue('frametime_color',AUX) then
        begin
          FrametimegraphColorbutton.ButtonColor:=  HexToColor(AUX);
        end;

      //GPU color  button
      if LoadValue('gpu_color',AUX) then
        begin
          gpuColorbutton.ButtonColor:=  HexToColor(AUX);
        end;

      //CPU color  button
      if LoadValue('cpu_color',AUX) then
        begin
          cpuColorbutton.ButtonColor:=  HexToColor(AUX);
        end;

      //VRAM color  button

      if LoadValue('vram_color',AUX) then
      vramColorbutton.ButtonColor:=  HexToColor(AUX);

       //IO color  button

      if LoadValue('io_color',AUX) then
      iordrwColorButton.ButtonColor:=  HexToColor(AUX);



      //RAM color  button
      if LoadValue('ram_color',AUX) then
        begin
          ramColorbutton.ButtonColor:=  HexToColor(AUX);
        end;

      //IO color  button
      if LoadValue('io_color',AUX) then
        begin
          iordrwColorbutton.ButtonColor:=  HexToColor(AUX);
        end;

      //Wine color  button
      if LoadValue('wine_color',AUX) then
        begin
          wineColorbutton.ButtonColor:=  HexToColor(AUX);
        end;

      //Engine color  button
      if LoadValue('engine_color',AUX) then
        begin
          engineColorbutton.ButtonColor:=  HexToColor(AUX);
        end;

      //battery color  button
      if LoadValue('battery_color',AUX) then
        begin
          batteryColorbutton.ButtonColor:=  HexToColor(AUX);
        end;

      //media player color  button
      if LoadValue('media_player_color',AUX) then
        begin
          mediaColorbutton.ButtonColor:=  HexToColor(AUX);
        end;

      //#################################################    Checkboxes

    //hide hud
    if LoadName('no_display') then
      hidehudcheckbox.Checked := True
    else
      hidehudcheckbox.Checked := false;

    //hud compact
    if LoadName('hud_compact') then
     hudcompactcheckbox.Checked := True
    else
      hudcompactcheckbox.Checked := false;

    //fps
    if LoadName('fps') then
      fpscheckbox.Checked := True
    else
      fpscheckbox.Checked := false;

    //frame time
    if LoadName('frame_timing') then
      frametimegraphcheckbox.Checked := True
    else
      frametimegraphcheckbox.Checked := false;

    //fps limit
    if LoadName('show_fps_limit') then
      showfpslimcheckbox.Checked := True
    else
      showfpslimcheckbox.Checked := false;


    //frame count
    if LoadName('frame_count') then
      framecountcheckbox.Checked := True
    else
      framecountcheckbox.Checked := false;

    //gpu load
    if LoadName('gpu_stats') then
      gpuavgloadcheckbox.Checked := True
    else
      gpuavgloadcheckbox.Checked := false;

    //gpu load change
    if LoadName('gpu_load_change') then
      gpuloadcolorcheckbox.Checked := True
    else
      gpuloadcolorcheckbox.Checked := false;




    //vram
    if LoadName('vram') then
      vramusagecheckbox.Checked := True
    else
      vramusagecheckbox.Checked := false;

    //gpu core clock
    if LoadName('gpu_core_clock') then
      gpufreqcheckbox.Checked := True
    else
      gpufreqcheckbox.Checked := false;

    //gpu mem clock
    if LoadName('gpu_mem_clock') then
      gpumemfreqCheckBox.Checked := True
    else
      gpumemfreqCheckBox.Checked := false;


    //gpu temperature  core
    if LoadName('gpu_temp') then
      gputempCheckBox.Checked := True
    else
      gputempCheckBox.Checked := false;


    //gpu temperature   mem
    if LoadName('gpu_mem_temp') then
      gpumemtempCheckBox.Checked := True
    else
      gpumemtempCheckBox.Checked := false;


    //gpu temperature   junction
    if LoadName('gpu_junction_temp') then
      gpujunctempCheckBox.Checked := True
    else
      gpujunctempCheckBox.Checked := false;


    //gpu fan
    if LoadName('gpu_fan') then
      gpufanCheckBox.Checked := True
    else
      gpufanCheckBox.Checked := false;


    //gpu power
    if LoadName('gpu_power') then
      gpupowerCheckBox.Checked := True
    else
      gpupowerCheckBox.Checked := false;

    //gpu voltage
    if LoadName('gpu_voltage') then
      gpuvoltageCheckBox.Checked := True
    else
      gpuvoltageCheckBox.Checked := false;

    //gpu throttling
    if LoadName('throttling_status') then
      gputhrottlingCheckBox.Checked := True
    else
      gputhrottlingCheckBox.Checked := false;

    //gpu throttling  graph
    if LoadName('throttling_status_graph') then
      gputhrottlinggraphCheckBox.Checked := True
    else
      gputhrottlinggraphCheckBox.Checked := false;


    //gpu name
    if LoadName('gpu_name') then
      gpumodelCheckBox.Checked := True
    else
      gpumodelCheckBox.Checked := false;


    //vulkan driver
    if LoadName('vulkan_driver') then
     vulkandriverCheckBox.Checked := True
    else
      vulkandriverCheckBox.Checked := false;



     //cpu load
    if LoadName('cpu_stats') then
      cpuavgloadcheckbox.Checked := True
    else
      cpuavgloadcheckbox.Checked := false;

    //cpu load change
    if LoadName('cpu_load_change') then
      cpuloadcolorcheckbox.Checked := True
    else
      cpuloadcolorcheckbox.Checked := false;

    //cpu core load
    if LoadName('core_load') then
      cpuloadcorecheckbox.Checked := True
    else
      cpuloadcorecheckbox.Checked := false;


    //cpu core freq
    if LoadName('cpu_mhz') then
      cpufreqcheckbox.Checked := True
    else
      cpufreqcheckbox.Checked := false;

     //cpu temp
    if LoadName('cpu_temp') then
      cputempcheckbox.Checked := True
    else
      cputempcheckbox.Checked := false;

    //cpu power
    if LoadName('cpu_power') then
      cpupowercheckbox.Checked := True
    else
      cpupowercheckbox.Checked := false;


    //ram
    if LoadName('ram') then
      ramusagecheckbox.Checked := True
    else
      ramusagecheckbox.Checked := false;


    //disk
    if LoadName('io_read') then
      diskiocheckbox.Checked := True
    else
      diskiocheckbox.Checked := false;

    //procmem
    if LoadName('procmem') then
      procmemcheckbox.Checked := True
    else
      procmemcheckbox.Checked := false;

    //swap
    if LoadName('swap') then
      swapusagecheckbox.Checked := True
    else
      swapusagecheckbox.Checked := false;


    // Distro info
    if LoadName('uname -r') then
      distroinfocheckbox.Checked := True
    else
      distroinfocheckbox.Checked := false;

    // refresh rate
    if LoadName('refresh_rate') then
      refreshratecheckbox.Checked := True
    else
      refreshratecheckbox.Checked := false;

    // resolution
    if LoadName('resolution') then
      resolutioncheckbox.Checked := True
    else
      resolutioncheckbox.Checked := false;

    // session
    if LoadName('SESSION_TYPE') then
      sessioncheckbox.Checked := True
    else
      sessioncheckbox.Checked := false;



    // time
    if LoadName('time#') then
      timecheckbox.Checked := True
    else
      timecheckbox.Checked := false;

    // arch
    if LoadName('arch') then
      archcheckbox.Checked := True
    else
      archcheckbox.Checked := false;

    // wine
    if LoadName('wine') then
      winecheckbox.Checked := True
    else
      winecheckbox.Checked := false;

    // engine
    if LoadName('engine_version') then
      engineversioncheckbox.Checked := True
    else
      engineversioncheckbox.Checked := false;


    // engine short
    if LoadName('engine_short_names') then
      engineshortcheckbox.Checked := True
    else
      engineshortcheckbox.Checked := false;



    // hud version
    if LoadName('version#') then
     hudversioncheckbox.Checked := True
    else
      hudversioncheckbox.Checked := false;

    // game mode
    if LoadName('gamemode') then
     gamemodestatuscheckbox.Checked := True
    else
      gamemodestatuscheckbox.Checked := false;

    // vkbasalt
    if LoadName('vkbasalt') then
     vkbasaltstatuscheckbox.Checked := True
    else
      vkbasaltstatuscheckbox.Checked := false;


    // fcat
    if LoadName('fcat') then
     fcatcheckbox.Checked := True
    else
      fcatcheckbox.Checked := false;


    // fsr
    if LoadName('fsr') then
     fsrcheckbox.Checked := True
    else
      fsrcheckbox.Checked := false;

    // hdr
    if LoadName('hdr') then
     hdrcheckbox.Checked := True
    else
      hdrcheckbox.Checked := false;

    // battery
    if LoadName('battery') then
     batterycheckbox.Checked := True
    else
     batterycheckbox.Checked := false;

    // battery watt
    if LoadName('battery_watt') then
     batterywattcheckbox.Checked := True
    else
     batterywattcheckbox.Checked := false;

    // battery time
    if LoadName('battery_time') then
     batterytimecheckbox.Checked := True
    else
     batterytimecheckbox.Checked := false;

    // device battery
    if LoadName('device_battery') then
     devicecheckbox.Checked := True
    else
     devicecheckbox.Checked := false;

    // media player
    if LoadName('media_player') then
     mediacheckbox.Checked := True
    else
     mediacheckbox.Checked := false;


    // log versioning
    if LoadName('log_versioning') then
     versioningcheckbox.Checked := True
    else
     versioningcheckbox.Checked := false;

    // auto upload
    if LoadName('upload_logs') then
     autouploadcheckbox.Checked := True
    else
     autouploadcheckbox.Checked := false;



    // fps color change
    if LoadName('fps_color_change') then
     fpscolorcheckbox.Checked := True
    else
     fpscolorcheckbox.Checked := false;


    // Fahrenheit
    if LoadName('temp_fahrenheit') then
     fahrenheitcheckbox.Checked := True
    else
      fahrenheitcheckbox.Checked := false;


    // winesync
    if LoadName('winesync') then
     winesynccheckbox.Checked := True
    else
      winesynccheckbox.Checked := false;

    // VPS - vulkan present mode
    if LoadName('present_mode') then
     vpscheckbox.Checked := True
    else
      vpscheckbox.Checked := false;

    // Network
    if LoadName('network=') then
     networkcheckbox.Checked := True
    else
      networkcheckbox.Checked := false;




end; // form create



procedure Tgoverlayform.frametimetypeBitBtnClick(Sender: TObject);
begin
     //Change icon and hint on click
  case frametimetypeBitBtn.ImageIndex of
    8: begin
      frametimetypeBitBtn.ImageIndex:=7;
      frametimetypeBitBtn.Caption:= 'Histogram';
      frametimetypeBitBtn.Hint:='Use histogram for frametime information';
    end;
    7: begin
      frametimetypeBitBtn.ImageIndex:=8;
      frametimetypeBitBtn.Caption:= 'Curve';
      frametimetypeBitBtn.Hint:='Use regular curve for frametime information';
    end;
 end;
end;

procedure Tgoverlayform.geSpeedButtonClick(Sender: TObject);
begin
    case geSpeedButton.imageIndex of
       0: begin
         geSpeedButton.ImageIndex:=1; //switch button position to ON
         ExecuteShellCommand('echo MANGOHUD=1 | pkexec tee -a /etc/environment');
         ExecuteShellCommand('notify-send -e -i ' + GetIconFile + ' "VULKAN Global Enable Activated" "Every Vulkan application will have Mangohud Enabled now"');
         showmessage ('Restart your system to take effect');
    end;

     1: begin
       geSpeedButton.ImageIndex:=0; ////switch button position to OFF
       ExecuteShellCommand('pkexec sed -i -e "/MANGOHUD=1/d" /etc/environment');
       ExecuteShellCommand('notify-send -e -i ' + GetIconFile + ' "Deactivated"');
       showmessage ('Restart your system to take effect');
    end;
end;

end;

procedure Tgoverlayform.mangocolorBitBtnClick(Sender: TObject);
begin

//Set mangohud colors
hudbackgroundColorButton.ButtonColor:= clblack;

fontColorButton.ButtonColor := clwhite;
gpuload1ColorButton.ButtonColor:=fontColorButton.ButtonColor;
cpuload1ColorButton.ButtonColor:=fontColorButton.ButtonColor;

gpuColorButton.ButtonColor:=$0062972E;
cpuColorButton.ButtonColor:=$00CB972E;
vramColorButton.ButtonColor:=$00C164AD;
ramColorButton.ButtonColor:=$009366C2;
iordrwColorButton.ButtonColor:=$00D391A4;
wineColorButton.ButtonColor:=$005B5BEB;
engineColorButton.ButtonColor:=$005B5BEB;
batteryColorButton.ButtonColor:= clLime;
mediaColorButton.ButtonColor:= clYellow;


//Save button
saveBitbtn.Click;
end;

procedure Tgoverlayform.mangohudLabelClick(Sender: TObject);
begin
  //Enable tabs
  goverlayPageControl.ShowTabs:=true;
  vkbasalttabsheet.TabVisible:=false; //disable vkbasalt tab

  //unselect vkbasalt
  vkbasaltLabel.Font.Color:=clgray;
  vkbasaltShape.Brush.Color:= DarkerBackgroundColor;


  // select mangohud
  mangohudLabel.Font.Color:=clwhite;
  mangohudShape.Brush.Color:= DarkBackgroundColor;
  goverlayPageControl.ActivePage:=presetTabsheet;
end;

procedure Tgoverlayform.reshaderefreshBitBtnClick(Sender: TObject);
var
  P: TProcess;
  Buf: array[0..8191] of byte;
  ReadCount: SizeInt;
  Chunk, Piece, S: string;
  Percent: Integer;
  Phase: string;



  function ExtractPercentAnywhere(const S: string; out Pct: Integer): Boolean;
  var
    i, j: Integer;
  begin
    // procura um número imediatamente antes de '%'
    Result := False;
    Pct := -1;
    for i := 1 to Length(S) do
      if S[i] = '%' then
      begin
        j := i - 1;
        while (j >= 1) and (S[j] in ['0'..'9']) do Dec(j);
        Inc(j);
        if (j <= i - 1) and TryStrToInt(Copy(S, j, i - j), Pct) then
        begin
          if Pct < 0 then Pct := 0;
          if Pct > 100 then Pct := 100;
          Exit(True);
        end;
      end;
  end;

  procedure UpdatePhase(const S: string);
  begin
    if Pos('Receiving objects', S) > 0 then Phase := 'Downloading';
    if Pos('Resolving deltas',   S) > 0 then Phase := 'Installing';
    if Pos('Checking out files', S) > 0 then Phase := 'Checking files';
  end;

  procedure ApplyPercent(Pct: Integer);
  begin
    if reshadeProgressbar.Min <> 0 then reshadeProgressbar.Min := 0;
    if reshadeProgressbar.Max <> 100 then reshadeProgressbar.Max := 100;
    reshadeProgressbar.Position := Pct;
    if Phase <> '' then
      pbarLabel.Caption := Format('%s: %d%%', [Phase, Pct])
    else
      pbarLabel.Caption := Format('%d%%', [Pct]);
    Application.ProcessMessages; // garante pintura imediata
  end;

  procedure ProcessPiecesFromChunk(var C: string);
  var
    pCR, pLF, pMin: SizeInt;
  begin
    // quebra por CR (\r) e LF (\n); git usa muito \r em progresso
    while True do
    begin
      pCR := Pos(#13, C);
      pLF := Pos(#10, C);
      if (pCR = 0) and (pLF = 0) then Break;

      if (pCR = 0) then pMin := pLF
      else if (pLF = 0) then pMin := pCR
      else pMin := IfThen(pCR < pLF, pCR, pLF);

      Piece := Copy(C, 1, pMin - 1);
      Delete(C, 1, pMin);
      // se era CRLF, remove o LF remanescente
      if (pMin = 1) and (Length(C) > 0) and ((C[1] = #10) or (C[1] = #13)) then
        Delete(C, 1, 1);

      UpdatePhase(Piece);
      if ExtractPercentAnywhere(Piece, Percent) then
        ApplyPercent(Percent);
    end;

    // também tenta extrair percent do que sobrou (linha parcial)
    if (C <> '') and ExtractPercentAnywhere(C, Percent) then
      ApplyPercent(Percent);
  end;

  procedure StartGit(const AParams: array of string; const AWorkDir: string);
  var
    i: Integer;
  begin
    P := TProcess.Create(nil);
    P.Executable := FindDefaultExecutablePath('git');
    for i := 0 to High(AParams) do
      P.Parameters.Add(AParams[i]);
    P.CurrentDirectory := AWorkDir;

    // junta stderr->stdout e usa pipes
    P.Options := [poUsePipes, poStderrToOutPut, poNoConsole];

    // força progresso imediato
    P.Environment.Add('GIT_PROGRESS_DELAY=0');
    P.Environment.Add('GIT_FLUSH=1');

    P.Execute;
  end;

  procedure PumpOutput;
  begin
    if P.Output.NumBytesAvailable > 0 then
    begin
      ReadCount := P.Output.Read(Buf{%H-}, SizeOf(Buf));
      if ReadCount > 0 then
      begin
        SetString(S, PChar(@Buf[0]), ReadCount);
        Chunk := Chunk + S;
        ProcessPiecesFromChunk(Chunk);
      end;
    end;
  end;

begin

  //Disable update button
  reshaderefreshBitbtn.Enabled:=false;

  if VKBASALTFOLDER = '' then
  begin
    ShowMessage('vkBasalt directory not found');
    Exit;
  end;

  RepoDir := IncludeTrailingPathDelimiter(VKBASALTFOLDER) + 'reshade-shaders';

  reshadeProgressbar.Min := 0;
  reshadeProgressbar.Max := 100;
  reshadeProgressbar.Position := 0;
  pbarLabel.Caption := 'Starting...';
  Phase := '';
  Chunk := '';

  try
    if DirectoryExists(RepoDir) then
      StartGit(['-C', 'reshade-shaders', 'pull', '--progress'], VKBASALTFOLDER)
    else
      //StartGit(['clone', '--progress', 'https://github.com/crosire/reshade-shaders.git'], VKBASALTFOLDER);
      StartGit(['clone', '--progress', 'https://github.com/benjamimgois/reshade-shaders.git'], VKBASALTFOLDER);
    while P.Running do
    begin
      PumpOutput;
      Application.ProcessMessages; // mantém UI viva e repinta a barra
    end;

    // drena restos após sair
    PumpOutput;

    if P.ExitStatus = 0 then
    begin
      ApplyPercent(100);
      pbarLabel.Caption := 'Completed';
      ExecuteShellCommand('notify-send -e -i ' + GetIconFile +
        ' "Goverlay" "Reshade shaders are ready"');
    end
    else
      ShowMessage('Error while synchronizing reshade repo. Code: ' + IntToStr(P.ExitStatus));

  finally
    if Assigned(P) then P.Free;
  end;

  // Listar TODOS os arquivos do repo:
  ListFilesToListBox(RepoDir, aveffectsListbox, ['.fx', '.fxh', '.h', '.glsl']);

  //Enable elements
   aveffectsListbox.Enabled:=true;
   acteffectsListbox.Enabled:=true;
   addBitbtn.Enabled:=true;
   subBitbtn.Enabled:=true;

  //Enable update button
  reshaderefreshBitbtn.Enabled:=true;
end;

procedure Tgoverlayform.runvkbasaltItemClick(Sender: TObject);
begin
//ExecuteGUICommand('killall vkcube');
//ExecuteShellCommand('notify-send -e -i ' + GetIconFile + ' "Goverlay" "Trying vkbasalt effects"');
//ExecuteGUICommand('VKBASALT_LOG_FILE=' + VKBASALTFOLDER + '/' + 'vkBasalt.log ENABLE_VKBASALT=1 vkcube &');

ExecuteGUICommand('killall pascube');
ExecuteShellCommand('notify-send -e -i ' + GetIconFile + ' "Goverlay" "Trying vkbasalt effects"');
// Start pasCube
ExecuteGUICommand('VKBASALT_LOG_FILE=' + VKBASALTFOLDER + '/' + 'vkBasalt.log ENABLE_VKBASALT=1 MESA_LOADER_DRIVER_OVERRIDE=zink mangohud QT_QPA_PLATFORM=xcb ./pascube &');


end;

procedure Tgoverlayform.savecustomItemClick(Sender: TObject);
begin
     // Save current config
    saveBitbtn.Click;

    // Copy Mangohud.conf file to custom.conf
    ExecuteShellCommand('cp '+ MANGOHUDCFGFILE + ' ' + CUSTOMCFGFILE);

    //Notification
    ExecuteShellCommand('notify-send -e -i ' + GetIconFile + ' "Goverlay" "Settings saved as custom config"');
end;

procedure Tgoverlayform.runvkcubeItemClick(Sender: TObject);
begin
  // check if vkcube is running
  Process := TProcess.Create(nil);
  try
    Process.CommandLine := 'pgrep -x vkcube';
    Process.Options := Process.Options + [poWaitOnExit, poUsePipes];
    Process.Execute;

    // if output is 0, process is running, show message and stop
    if Process.ExitStatus = 0 then
    begin
      ShowMessage('vkcube is running !');
      Exit;
    end;
  finally
    Process.Free;
  end;

  // Start vkcube (vulkan demo) apenas se não estiver em execução
  if USERSESSION = 'wayland' then
    ExecuteGUICommand('mangohud vkcube --wsi wayland &')
  else
    ExecuteGUICommand('mangohud vkcube &');
end;


procedure Tgoverlayform.minusButtonClick(Sender: TObject);
begin
   COLUMNS := COLUMNS-1;
   if COLUMNS <= 1 then
     COLUMNS:=1;

   columvalueLabel.Caption:=inttostr(COLUMNS);

     case COLUMNS of
       1:begin
         columShape.Visible:=true;
         columShape1.Visible:=false;
         columShape2.Visible:=false;
         columShape3.Visible:=false;
         columShape4.Visible:=false;
         columShape5.Visible:=false;
       end;
       2:begin
         columShape.Visible:=true;
         columShape1.Visible:=true;
         columShape2.Visible:=false;
         columShape3.Visible:=false;
         columShape4.Visible:=false;
         columShape5.Visible:=false;
       end;
       3:begin
         columShape.Visible:=true;
         columShape1.Visible:=true;
         columShape2.Visible:=true;
         columShape3.Visible:=false;
         columShape4.Visible:=false;
         columShape5.Visible:=false;
       end;
       4:begin
         columShape.Visible:=true;
         columShape1.Visible:=true;
         columShape2.Visible:=true;
         columShape3.Visible:=true;
         columShape4.Visible:=false;
         columShape5.Visible:=false;
       end;
       5:begin
         columShape.Visible:=true;
         columShape1.Visible:=true;
         columShape2.Visible:=true;
         columShape3.Visible:=true;
         columShape4.Visible:=true;
         columShape5.Visible:=false;
       end;
       6:begin
         columShape.Visible:=true;
         columShape1.Visible:=true;
         columShape2.Visible:=true;
         columShape3.Visible:=true;
         columShape4.Visible:=true;
         columShape5.Visible:=true;
       end;
     end;
end;

procedure Tgoverlayform.mipmapTrackBarChange(Sender: TObject);
begin
  //Display new values and trackbar changes
  mipmapvalueLabel.Caption:= FormatFloat('#0', mipmapTrackbar.Position);
end;


procedure Tgoverlayform.fontsizeTrackBarChange(Sender: TObject);
begin
  //Display new values and trackbar changes
  fontsizevalueLabel.Caption:= inttostr(fontsizeTrackbar.Position);
end;

procedure Tgoverlayform.coreloadtypeBitBtnClick(Sender: TObject);
begin

  //Change icon and hint on click
  case coreloadtypeBitBtn.ImageIndex of
    6: begin
      coreloadtypeBitBtn.ImageIndex:=7;
      coreloadtypeBitBtn.Caption:= 'Graph';
      coreloadtypeBitBtn.Hint:='Use vertical bars for core load';
    end;
    7: begin
      coreloadtypeBitBtn.ImageIndex:=6;
      coreloadtypeBitBtn.Caption:= 'Percent';
      coreloadtypeBitBtn.Hint:='Use percentage numbers for core load';

    end;
 end;

end;

procedure Tgoverlayform.aboutBitBtnClick(Sender: TObject);
begin
   aboutForm.ShowModal;
end;

procedure Tgoverlayform.addBitBtnClick(Sender: TObject);
  var
  i, added: Integer;
  S: string;

  function AnySelected(LB: TListBox): Boolean;
  var
    j: Integer;
  begin
    if LB.MultiSelect then
    begin
      for j := 0 to LB.Items.Count - 1 do
        if LB.Selected[j] then Exit(True);
      Result := False;
    end
    else
      Result := LB.ItemIndex >= 0;
  end;

begin
  // check selection
  if not AnySelected(aveffectsListbox) then
  begin
    ShowMessage('Select at least one effect in "Avaiable effects".');
    Exit;
  end;

  added := 0;

  if aveffectsListbox.MultiSelect then
  begin
    // Add all elements
    for i := 0 to aveffectsListbox.Items.Count - 1 do
      if aveffectsListbox.Selected[i] then
      begin
        S := aveffectsListbox.Items[i];
        if acteffectsListbox.Items.IndexOf(S) = -1 then
        begin
          acteffectsListbox.Items.Add(S);
          Inc(added);
        end;
      end;
  end
  else
  begin
    // Add unique item
    S := aveffectsListbox.Items[aveffectsListbox.ItemIndex];
    if acteffectsListbox.Items.IndexOf(S) = -1 then
    begin
      acteffectsListbox.Items.Add(S);
      Inc(added);
    end
    else
      ShowMessage('This effect is already active');
  end;

  // select the last selected:
  if added > 0 then
    acteffectsListbox.ItemIndex := acteffectsListbox.Items.Count - 1;

end;

procedure Tgoverlayform.afterburnercolorBitBtn1Click(Sender: TObject);
begin
//Set afterburner colors
hudbackgroundColorButton.ButtonColor:= clblack;

fontColorButton.ButtonColor := clFuchsia;
gpuload1ColorButton.ButtonColor:=fontColorButton.ButtonColor;
cpuload1ColorButton.ButtonColor:=fontColorButton.ButtonColor;

gpuColorButton.ButtonColor:=clFuchsia;
cpuColorButton.ButtonColor:=clFuchsia;
vramColorButton.ButtonColor:=clFuchsia;
ramColorButton.ButtonColor:=clFuchsia;
iordrwColorButton.ButtonColor:=clFuchsia;
wineColorButton.ButtonColor:=clFuchsia;
engineColorButton.ButtonColor:=clFuchsia;
batteryColorButton.ButtonColor:= clFuchsia;
mediaColorButton.ButtonColor:= clFuchsia;


//Save button
saveBitbtn.Click;
end;

procedure Tgoverlayform.afTrackBarChange(Sender: TObject);
begin
  //Display new values and trackbar changes
  afvalueLabel.Caption:= FormatFloat('#0', afTrackbar.Position);
end;

procedure Tgoverlayform.basicBitBtnClick(Sender: TObject);
begin
    //Set all checkboxes to false
  SetAllCheckBoxesToFalse;

    //Set vertical orientation
  verticalRadioButton.Checked:=true;

  //Check basic options
    //fps
    fpsCheckbox.Checked:=true;
    frametimegraphCheckbox.Checked:=true;
    engineversionCheckbox.Checked:=true;
    fpscolorCheckbox.Checked:=true;
    //gpu
    gpuavgloadCheckbox.Checked:=true;
    vramusageCheckbox.Checked:=true;
    gputempCheckbox.Checked:=true;
    gpufreqCheckbox.Checked:=true;
    gpupowerCheckbox.Checked:=true;
    gpumemfreqCheckbox.Checked:=true;
    gpuloadcolorCheckbox.Checked:=true;
    //cpu
    cpuavgloadCheckbox.Checked:=true;
    cpufreqCheckbox.Checked:=true;
    cputempCheckbox.Checked:=true;
    cpupowerCheckbox.Checked:=true;
    ramusageCheckbox.Checked:=true;
    cpuloadcolorCheckbox.Checked:=true;
    //battery
    batteryCheckbox.Checked:=true;
    // Change button color
    fullBitbtn.Color:=clDefault;
    basicBitbtn.Color:=$007F5500;
    basichorizontalBitbtn.Color:=clDefault;
    fpsonlyBitbtn.Color:=clDefault;
    usercustomBitbtn.Color:=clDefault;
  //Save button
  saveBitbtn.Click;
end;

procedure Tgoverlayform.basichorizontalBitBtnClick(Sender: TObject);
begin
   //Set all checkboxes to false
  SetAllCheckBoxesToFalse;

  //Set horizontal orientation
  horizontalRadioButton.Checked:=true;

  //Check basic options
    //fps
    fpsCheckbox.Checked:=true;
    frametimegraphCheckbox.Checked:=true;
    engineversionCheckbox.Checked:=true;
    fpscolorCheckbox.Checked:=true;
    //gpu
    gpuavgloadCheckbox.Checked:=true;
    vramusageCheckbox.Checked:=true;
    gpupowerCheckbox.Checked:=true;
    gpuloadcolorCheckbox.Checked:=true;
    //cpu
    cpuavgloadCheckbox.Checked:=true;
    cpupowerCheckbox.Checked:=true;
    ramusageCheckbox.Checked:=true;
    cpuloadcolorCheckbox.Checked:=true;
    //battery
    batteryCheckbox.Checked:=true;
    // Change button color
    fullBitbtn.Color:=clDefault;
    basicBitbtn.Color:=clDefault;
    basichorizontalBitbtn.Color:=$007F5500;
    fpsonlyBitbtn.Color:=clDefault;
    usercustomBitbtn.Color:=clDefault;
  //Save button
  saveBitbtn.Click;
end;

procedure Tgoverlayform.blacklistBitBtnClick(Sender: TObject);
begin
  blacklistForm.ShowModal; // Form show as modal window
end;

procedure Tgoverlayform.casTrackBarChange(Sender: TObject);
begin
  casvaluelabel.Caption := inttostr(casTrackbar.Position);
end;



procedure Tgoverlayform.delayTrackBarChange(Sender: TObject);
begin
    //Display new values and trackbar changes
  delayvalueLabel.Caption:= FormatFloat('#0', delayTrackbar.Position)+ 's';
end;

procedure Tgoverlayform.durationTrackBarChange(Sender: TObject);
begin
  //Display new values and trackbar changes
  durationvalueLabel.Caption:= FormatFloat('#0', durationTrackbar.Position) + 's' ;
end;

procedure Tgoverlayform.fpsavgBitBtnClick(Sender: TObject);
begin
       //Change caption and hint on click
  case fpsavgBitBtn.ImageIndex of
    9: begin
      fpsavgBitBtn.ImageIndex:=10;
      fpsavgBitBtn.Caption:= '0.1% low';
      fpsavgBitBtn.Hint:='Display 0.1% low fps';
    end;
    10: begin
      fpsavgBitBtn.ImageIndex:=9;
      fpsavgBitBtn.Caption:= '1% low';
      fpsavgBitBtn.Hint:='Display 1% low fps';
    end;
 end;
end;

procedure Tgoverlayform.fpsonlyBitBtnClick(Sender: TObject);
begin

  //Set all checkboxes to false
  SetAllCheckBoxesToFalse;

  //Set vertical orientation
  verticalRadioButton.Checked:=true;

  //Check FPS  only
  fpsCheckbox.Checked:=true;
  fpscolorCheckbox.Checked:=true;

  // Change button color
    fullBitbtn.Color:=clDefault;
    basicBitbtn.Color:=clDefault;
    basichorizontalBitbtn.Color:=clDefault;
    fpsonlyBitbtn.Color:=$007F5500;
    usercustomBitbtn.Color:=clDefault;

  //Save button
  saveBitbtn.Click;

end;

procedure Tgoverlayform.fullBitBtnClick(Sender: TObject);
begin
    //Set all checkboxes to true
  SetAllCheckBoxesToTrue;

  //Set vertical orientation
  verticalRadioButton.Checked:=true;

  //uncheck specific ones
  hidehudCheckbox.Checked:=false;
  engineshortCheckbox.Checked:=false;
  fcatcheckbox.Checked:=false;
  fahrenheitCheckBox.Checked:=false;
  versioningCheckbox.Checked:=false;
  autouploadCheckbox.Checked:=false;

  // Change button color
  fullBitbtn.Color:=$007F5500;
  basicBitbtn.Color:=clDefault;
  basichorizontalBitbtn.Color:=clDefault;
  fpsonlyBitbtn.Color:=clDefault;
  usercustomBitbtn.Color:=clDefault;

  //Save button
  saveBitbtn.Click;


end;

procedure Tgoverlayform.goverlayBitBtnClick(Sender: TObject);
var
GPUInfo: TStringList;
AProcess: TProcess;
I: Integer;
GPUBrand: string;
CPUInfo: TStringList;
CPUBrand: string;

begin
//Set common colors
hudbackgroundColorButton.ButtonColor:= clblack;

fontColorButton.ButtonColor := clSilver;
gpuload1ColorButton.ButtonColor:=fontColorButton.ButtonColor ;
cpuload1ColorButton.ButtonColor:=fontColorButton.ButtonColor;

engineColorButton.ButtonColor:=clSilver;
wineColorButton.ButtonColor:=clyellow;
batteryColorButton.ButtonColor:= clSilver;
mediaColorButton.ButtonColor:= clSilver;
iordrwColorButton.ButtonColor:=clSilver;


//Detect GPU and set colors according to BRAND
GPUBrand := '';
 AProcess := TProcess.Create(nil);
 GPUInfo := TStringList.Create;
 try
   // Execute the command lspci to list PCI devices
   AProcess.Executable := FindDefaultExecutablePath('lspci');
   AProcess.Parameters.Add('-nn');
   AProcess.Options := [poWaitOnExit, poUsePipes];
   AProcess.Execute;

   GPUInfo.LoadFromStream(AProcess.Output);

   // Look for a line that contains "VGA" (video card)
   for I := 0 to GPUInfo.Count - 1 do
   begin
     if Pos('VGA', GPUInfo[I]) > 0 then
     begin
       GPUBrand := GPUInfo[I];
       Break;
     end;
   end;
 finally
   GPUInfo.Free;
   AProcess.Free;
 end;

 // Change button colors based on GPU brand
 if Pos('AMD', GPUBrand) > 0 then
 begin
   gpuColorButton.ButtonColor := $003B00F1;
   vramColorButton.ButtonColor := $003B00F1;
 end
 else if Pos('NVIDIA', GPUBrand) > 0 then
 begin
   gpuColorButton.ButtonColor := $0000B875;
   vramColorButton.ButtonColor := $0000B875;
 end
 else if Pos('Intel', GPUBrand) > 0 then
 begin
   if Pos('ARC', GPUBrand) > 0 then
   begin
     gpuColorButton.ButtonColor := $00FEC601;
     vramColorButton.ButtonColor := $00FEC601;
   end;
 end;



  //Detect CPU and set colors according to BRAND
  CPUBrand := '';
  CPUInfo := TStringList.Create;
  try
    // Load CPU information from /proc/cpuinfo
    CPUInfo.LoadFromFile('/proc/cpuinfo');

    // Look for the line that contains "vendor_id" (CPU brand)
    for I := 0 to CPUInfo.Count - 1 do
    begin
      if Pos('vendor_id', CPUInfo[I]) > 0 then
      begin
        CPUBrand := Trim(Copy(CPUInfo[I], Pos(':', CPUInfo[I]) + 1, MaxInt));
        Break;
      end;
    end;
  finally
    CPUInfo.Free;
  end;

  // Change button colors based on CPU brand
  if Pos('AuthenticAMD', CPUBrand) > 0 then
  begin
     cpuColorButton.ButtonColor := $000080FA; // Change color for AMD
     ramColorButton.ButtonColor := $000080FA; // Change color for RAM button
     frametimegraphColorButton.ButtonColor := $000080FA; // Change color for Frame Time Graph
  end
  else if Pos('GenuineIntel', CPUBrand) > 0 then
  begin
    cpuColorButton.ButtonColor := $00ff5500; // Example color for Intel
    ramColorButton.ButtonColor := $00ff5500; // Example color for RAM button
    frametimegraphColorButton.ButtonColor := $00ff5500; // Example color for Frame Time Graph
  end;




//Save button
saveBitbtn.Click;
end;


procedure Tgoverlayform.intelpowerfixBitBtnClick(Sender: TObject);
var
  Response: Integer;

begin

    Response := MessageDlg('Due to a known vulnerability in intel cpus,  the corresponding energy_uj file has to be readable by corresponding user. Having the file readable may potentially be a security vulnerability persisting until system reboots.', mtConfirmation, [mbYes, mbNo], 0);

      if Response = mrYes then
      begin
      ExecuteShellCommand('pkexec chmod o+r /sys/class/powercap/intel-rapl\:0/energy_uj');
      //Change button color
      intelpowerfixBitBtn.ImageIndex:=0;
      Application.ProcessMessages; // update interface
      end

      else

      //Show cancel message
      ShowMessage('Action aborted by user');
       //Change button color
      intelpowerfixBitBtn.ImageIndex:=1;
      Application.ProcessMessages; // update interface
end;

procedure Tgoverlayform.intervalTrackBarChange(Sender: TObject);
begin
   //Display new values and trackbar changes
  intervalvalueLabel.Caption:= FormatFloat('#0', intervalTrackbar.Position) + 'ms';
end;

procedure Tgoverlayform.logfolderBitBtnClick(Sender: TObject);
var
  selectedFolder: string;

  begin
    // Dialog to select folder
    with TSelectDirectoryDialog.Create(Self) do
    begin
      try
        // Configurations
        Title := 'Select folder for logs';


        // if folder is selected
        if Execute then
        begin
          // store path in variable
          selectedFolder := FileName;

          // display path in edit
          logfolderEdit.Text := selectedFolder;

        end;
      finally
        Free;
      end;
    end;
  end;





procedure Tgoverlayform.pcidevComboBoxChange(Sender: TObject);
begin
  //gpudesclabel.Caption:=GPUDESC[pcidevCombobox.ItemIndex];
  gpudescEdit.Text:=GPUDESC[pcidevCombobox.ItemIndex];
end;

procedure Tgoverlayform.plusSpeedButtonClick(Sender: TObject);
begin
   COLUMNS := COLUMNS+1;
   if COLUMNS >= 6 then
     COLUMNS:=6;

   columvalueLabel.Caption:=inttostr(COLUMNS);

     case COLUMNS of
       1:begin
         columShape.Visible:=true;
         columShape1.Visible:=false;
         columShape2.Visible:=false;
         columShape3.Visible:=false;
         columShape4.Visible:=false;
         columShape5.Visible:=false;
       end;
       2:begin
         columShape.Visible:=true;
         columShape1.Visible:=true;
         columShape2.Visible:=false;
         columShape3.Visible:=false;
         columShape4.Visible:=false;
         columShape5.Visible:=false;
       end;
       3:begin
         columShape.Visible:=true;
         columShape1.Visible:=true;
         columShape2.Visible:=true;
         columShape3.Visible:=false;
         columShape4.Visible:=false;
         columShape5.Visible:=false;
       end;
       4:begin
         columShape.Visible:=true;
         columShape1.Visible:=true;
         columShape2.Visible:=true;
         columShape3.Visible:=true;
         columShape4.Visible:=false;
         columShape5.Visible:=false;
       end;
       5:begin
         columShape.Visible:=true;
         columShape1.Visible:=true;
         columShape2.Visible:=true;
         columShape3.Visible:=true;
         columShape4.Visible:=true;
         columShape5.Visible:=false;
       end;
       6:begin
         columShape.Visible:=true;
         columShape1.Visible:=true;
         columShape2.Visible:=true;
         columShape3.Visible:=true;
         columShape4.Visible:=true;
         columShape5.Visible:=true;
       end;
     end;
end;

procedure Tgoverlayform.popupBitBtnClick(Sender: TObject);
begin

popsaveMenu.PopUp;

end;


procedure Tgoverlayform.saveBitBtnClick(Sender: TObject);
var

  //Mango vars
  ValorItem: string;
  LOCATEDFILE, FPSSEL, FPSSELOFF: TStringList;
  FoundIndex,i: integer;
  NOITEMCHECK: boolean;
  Output,FileLines, ConfigLines: TStringList;
  MaxFPS, SelectedFPS: Integer;
  SelectedValues: TStringList;

  //vkbasalt vars
  RepoDir, RelPath, EffectName, EffectKey, FullPath, EffectsLine: string;
  TexPath, IncPath: string;
  Lines: TStringList;
  Sharp: Double;
  FS: TFormatSettings;

  procedure AddEffectToLine(const NameOnly: string);
   begin
     if EffectsLine = '' then
       EffectsLine := NameOnly
     else if Pos(':' + NameOnly + ':', ':' + EffectsLine + ':') = 0 then
       EffectsLine := EffectsLine + ':' + NameOnly;
   end;

  begin

  // ################### SAVE MANGOHUD

   if goverlayPageControl.ActivePage <> vkbasaltTabSheet then
   begin


  //Create directories

    if not DirectoryExists(ExtractFileDir(MANGOHUDCFGFILE)) then
      ForceDirectories(ExtractFileDir(MANGOHUDCFGFILE));

  // Delete old files if it exists

     if FileExists(MANGOHUDCFGFILE) then
      DeleteFile(MANGOHUDCFGFILE);


  // Create a new file for GOverlay
  ExecuteShellCommand('echo "################### File Generated by Goverlay ###################" >> '+ MANGOHUDCFGFILE);
  ExecuteShellCommand('echo "legacy_layout=false" >> '+ MANGOHUDCFGFILE);

  // Popup a notification

    ExecuteShellCommand('notify-send -e -i ' + GetIconFile + ' "MangoHud" "Configuration saved"');
    notificationlabel.Visible:=true;


    //###############################################################################################    VISUAL TAB


     // HUD Title - Config Variable

      // Only create title entry if title isn't blank and diferent of default title
      if (hudtitleEdit.text <> '') and (hudtitleEdit.text <> 'Title') then
      HUDTITLE:= 'custom_text_center=' + hudtitleEdit.text;

      //Orientation  - Config Variable

      SaveRadioButton (horizontalRadioButton, ORIENTATION, 'horizontal');
      SaveRadioButton (verticalRadioButton, ORIENTATION, '');

      //Borders - Config Variable

      SaveRadioButton (squareRadioButton, BORDERTYPE, 'round_corners=0');
      SaveRadioButton (roundRadioButton, BORDERTYPE, 'round_corners=10');

      //HUD Alpha (transparency)   - Config Variable

      HUDALPHA := 'background_alpha=' + FormatFloat('#0.0', transpTrackbar.Position/10);

      //HUD Color  - Config Variable

      HUDCOLOR := 'background_color=' + ColorToHTMLColor(hudbackgroundColorButton.ButtonColor);


      //Font type  - Config Variable

      if fontCombobox.ItemIndex <> 0 then  //It doesnt apply for the DEFAULT font
      begin
        LOCATEDFILE := FindAllFiles('/usr/share/fonts', fontCombobox.Text); //Locate specific folder for selected font
        try
            FONTFOLDERS := TStringList.Create;
            FONTFOLDERS.Sorted := True;
            FONTFOLDERS.Duplicates := dupIgnore;
            FONTFOLDERS.Delimiter := ';';
            ListFontDirectories(FONTFOLDERS);
            LOCATEDFILE := FindAllFiles(FONTFOLDERS.DelimitedText, fontCombobox.Text);
        finally
            FONTFOLDERS.Free;
        end;
        FONTPATH := LOCATEDFILE[0];
        FONTTYPE := 'font_file=' + FONTPATH; //Use the correct path to point the font file
      end
      else
      begin
        FONTTYPE := '';
      end;


      //Font size  - Config Variable

      FONTSIZE := 'font_size=' + inttostr(fontsizeTrackbar.Position);

      //Font Color  - Config Variable

      FONTCOLOR := 'text_color=' + ColorToHTMLColor(fontColorButton.ButtonColor);


      //Position  - Config Variable

      SaveRadioButton (topleftRadioButton, HUDPOSITION, 'position=top-left');
      SaveRadioButton (toprightRadioButton, HUDPOSITION, 'position=top-right');
      SaveRadioButton (topcenterRadioButton, HUDPOSITION, 'position=top-center');
      SaveRadioButton (bottomcenterRadioButton, HUDPOSITION, 'position=bottom-center');
      SaveRadioButton (bottomleftRadioButton, HUDPOSITION, 'position=bottom-left');
      SaveRadioButton (bottomrightRadioButton, HUDPOSITION, 'position=bottom-right');
      SaveRadioButton (middleleftRadioButton, HUDPOSITION, 'position=middle-left');
      SaveRadioButton (middlerightRadioButton, HUDPOSITION, 'position=middle-right');

     //HUD Toggle ON/OFF   - Config Variable

      case hudonoffCombobox.ItemIndex of
        0:TOGGLEHUD := 'toggle_hud=Shift_R+F12' ;
        1:TOGGLEHUD := 'toggle_hud=Shift_R+F1' ;
        2:TOGGLEHUD := 'toggle_hud=Shift_R+F2' ;
        3:TOGGLEHUD := 'toggle_hud=Shift_R+F3' ;
        4:TOGGLEHUD := 'toggle_hud=Shift_R+F4' ;
        5:TOGGLEHUD := 'toggle_hud=none' ;
        end;

      //Hide HUD by default  - Config Variable
      Savecheckbox (hidehudCheckbox, HIDEHUD, 'no_display');

      //HUD compact - Config Variable
      Savecheckbox (hudcompactCheckbox, HUDCOMPACT, 'hud_compact');

      //GPU PCIDEV  - Config Variable

      if pcidevCombobox.ItemIndex <> -1 then  // Does not create pci_dev line if no GPU is selected
        PCIDEV := 'pci_dev=0:' + pcidevCombobox.Items[pcidevCombobox.ItemIndex] ;


       //Network interface  - Config Variable

      if (networkCombobox.ItemIndex <> -1) and (networkCheckbox.Checked = true) then  // Does not create network line if interface is selected
        NETWORK := 'network=' + networkCombobox.Items[networkCombobox.ItemIndex] ;

      // Table Columns - - Config Variable
      COLUMNS :=  strtoint(columvalueLabel.Caption);
      TABLECOLUMNS := 'table_columns=' + inttostr(COLUMNS);


      //###############################################################################################   METRICS TAB

      //GPU

        //GPU Color
        GPUCOLOR := 'gpu_color='+ ColorToHTMLColor(gpuColorButton.ButtonColor) ;

        //AVG Load  - Config Variable
       Savecheckbox (gpuavgloadCheckbox, GPUAVGLOAD, 'gpu_stats');

        //AVG Load color  - Config Variable
        if gpuloadcolorCheckbox.checked = true then
          begin
             GPULOADCHANGE := 'gpu_load_change';
             GPULOADVALUE := 'gpu_load_value=50,90';
             GPULOADCOLOR := 'gpu_load_color='+ ColorToHTMLColor(gpuload1ColorButton.ButtonColor) + ',' + ColorToHTMLColor(gpuload2ColorButton.ButtonColor) + ',' + ColorToHTMLColor(gpuload3ColorButton.ButtonColor);
          end;


        //VRAM  - Config Variable
        Savecheckbox (vramusageCheckbox, VRAM, 'vram');

        //VRAM Color
        VRAMCOLOR := 'vram_color='+ ColorToHTMLColor(vramColorButton.ButtonColor) ;

        //IO Color
        IOCOLOR := 'io_color='+ ColorToHTMLColor(iordrwColorButton.ButtonColor) ;

        //Core freq  - Config Variable
        Savecheckbox (gpufreqCheckbox, GPUFREQ, 'gpu_core_clock');

        //Mem Freq  - Config Variable
        Savecheckbox (gpumemfreqCheckbox, GPUMEMFREQ, 'gpu_mem_clock');


        //GPU Temp  - Config Variable
        Savecheckbox (gputempCheckbox, GPUTEMP, 'gpu_temp');

        //GPU mem Temp  - Config Variable
        Savecheckbox (gpumemtempCheckbox, GPUMEMTEMP, 'gpu_mem_temp');

        //GPU Junction Temp  - Config Variable
        Savecheckbox (gpujunctempCheckbox, GPUJUNCTEMP, 'gpu_junction_temp');

        //GPU FAN  - Config Variable
        Savecheckbox (gpupowerCheckbox, GPUFAN, 'gpu_fan');

        //GPU POWER  - Config Variable
        Savecheckbox (gpupowerCheckbox, GPUPOWER, 'gpu_power');

        //GPU THROTTLING   - Config Variable
       Savecheckbox (gputhrottlingCheckbox, GPUTHR, 'throttling_status');

        //GPU THROTTLING GRAPH   - Config Variable

        Savecheckbox (gputhrottlinggraphCheckbox, GPUTHRG, 'throttling_status_graph');

        //GPU MODEL   - Config Variable
        Savecheckbox (gpumodelCheckbox, GPUMODEL, 'gpu_name');

        //VULKAN DRIVER   - Config Variable
        Savecheckbox (vulkandriverCheckbox, VULKANDRIVER, 'vulkan_driver');

        //GPU VOLTAGE   - Config Variable
         Savecheckbox (gpuvoltageCheckbox, GPUVOLTAGE, 'gpu_voltage');


        //GPU TEXT
        GPUTEXT := 'gpu_text=' + gpunameEdit.Text;




        //CPU

        //GPU Color
        CPUCOLOR := 'cpu_color='+ ColorToHTMLColor(cpuColorButton.ButtonColor) ;

       //GPU TEXT - Config Variable
        CPUTEXT := 'cpu_text=' + cpunameEdit.Text;


       //AVG Load  - Config Variable
        Savecheckbox (cpuavgloadCheckbox, CPUAVGLOAD, 'cpu_stats');

       //Load by core  - Config Variable
        Savecheckbox (cpuloadcoreCheckbox, CPULOADCORE, 'core_load');

       //Load by core type - Config Variable
        if coreloadtypeBitbtn.ImageIndex = 7 then
          CORELOADTYPE := 'core_bars';


       //CPU Load color  - Config Variable
        if cpuloadcolorCheckbox.checked = true then
          begin
             CPULOADCHANGE := 'cpu_load_change';
             CPULOADVALUE := 'cpu_load_value=50,90';
             CPULOADCOLOR := 'cpu_load_color='+ ColorToHTMLColor(cpuload1ColorButton.ButtonColor) + ',' + ColorToHTMLColor(cpuload2ColorButton.ButtonColor) + ',' + ColorToHTMLColor(cpuload3ColorButton.ButtonColor);
          end;


        //   CPUCOREFREQ := 'cpu_mhz';
       Savecheckbox (cpufreqCheckbox, CPUCOREFREQ, 'cpu_mhz');

       ////CPU TEMP - Config Variable
       Savecheckbox (cputempCheckbox, CPUTEMP, 'cpu_temp');

        ////CPU Power - Config Variable
       Savecheckbox (cpupowerCheckbox, CPUPOWER, 'cpu_power');

       ////RAM - Config Variable
       Savecheckbox (ramusageCheckBox, RAM, 'ram');

       //Disk IO  - Config Variable
        if diskioCheckbox.checked = true then
          begin
          // IOSTATS := 'io_stats';
             IOREAD := 'io_read';
             IOWRITE := 'io_write';
          end;

        ////FPS - Config Variable
       Savecheckbox (fpsCheckBox, FPS, 'fps');



        //FPS AVG - Config Variable
        if fpsavgBitbtn.ImageIndex = 9 then
          FPSAVG := 'fps_metrics=avg,0.01'
        else
          FPSAVG := 'fps_metrics=avg,0.001';


        //VRAM Color
        RAMCOLOR := 'ram_color='+ ColorToHTMLColor(ramColorButton.ButtonColor) ;

        //###############################################################################################   Performance TAB

         ////PROCMEM - Config Variable
       Savecheckbox (procmemCheckBox, PROCMEM, 'procmem');

        ////SWAP - Config Variable
       Savecheckbox (swapusageCheckBox, SWAP, 'swap');



       ////Frame time - Config Variable
       Savecheckbox (frametimegraphCheckBox, FRAMETIMING, 'frame_timing');

       //Frame time Color - Config Variable
       FRAMETIMEC := 'frametime_color=' + ColorToHTMLColor(frametimegraphColorButton.ButtonColor);

        ////Show fps limit - Config Variable
       Savecheckbox (showfpslimCheckBox, SHOWFPSLIM, 'show_fps_limit');




       ////Show fps limit - Config Variable
       Savecheckbox (framecountCheckBox, FRAMECOUNT, 'frame_count');

      //Wine Sync - Config Variable
      Savecheckbox (winesyncCheckBox, WINESYNC, 'winesync');

      //VPS - Config Variable
      Savecheckbox (vpsCheckBox, VPS, 'present_mode');

      //Histogram - Config Variable
        if frametimetypeBitbtn.ImageIndex = 7 then
          HISTOGRAM := 'histogram';



        // FPS limit - Config Variable

        FPSSEL := TStringList.Create; //store selected options here
        NOITEMCHECK := True; // Variable is true if no item is checked



        // Check fpslimCheckgroup items
        for i := 0 to fpslimCheckgroup.Items.Count - 1 do
          begin
          // check if item is checked
          if fpslimCheckgroup.Checked[i] then
            begin
              // Add item value to stringlist
              ValorItem := fpslimCheckgroup.Items[i];
              FPSSEL.Add(inttostr(strtoint(ValorItem) + offsetSpinEdit.Value));
              NOITEMCHECK := false; // Variable is become false
            end;
          end;

          if NOITEMCHECK = true then
             FPSLIM := 'fps_limit=0' //If no item is check fps_limit is unlimited
          else
              FPSLIM := 'fps_limit=' + FPSSEL.CommaText;
              FPSSEL.Free;



      //OFFSET Value
      OFFSET := '"#offset="' + inttostr(offsetspinedit.Value);
      Writeln(OFFSET); // debug



      // Ajust FPS color limits
       SelectedValues := TStringList.Create;
  try
    MaxFPS := 0;

    // Reading selected values from the CheckGroup
    for i := 0 to fpslimcheckgroup.Items.Count - 1 do
    begin
      if fpslimcheckgroup.Checked[i] then
      begin
        SelectedFPS := StrToIntDef(fpslimcheckgroup.Items[i], 0);
        SelectedValues.Add(IntToStr(SelectedFPS));
        if SelectedFPS > MaxFPS then
          MaxFPS := SelectedFPS;
      end;
    end;

    // Setting values for the SpinEdits
    if SelectedValues.Count = 0 then
      MaxFPS := 60;

    fpscolor3spinedit.Value := MaxFPS;
    fpscolor2spinedit.Value := Round(MaxFPS / 2);

  finally
    SelectedValues.Free;
  end;

      //FPS Limit method - Config Variable

      case fpslimmetComboBox.ItemIndex of
        0:FPSLIMMET := 'fps_limit_method=late' ;
        1:FPSLIMMET := 'fps_limit_method=early' ;
      end;


      //FPS toggle key - Config Variable

      case fpslimtoggleComboBox.ItemIndex of
        0:FPSLIMTOGGLE := 'toggle_fps_limit=Shift_L+F1' ;
        1:FPSLIMTOGGLE := 'toggle_fps_limit=Shift_L+F2' ;
        2:FPSLIMTOGGLE := 'toggle_fps_limit=Shift_L+F3' ;
        3:FPSLIMTOGGLE := 'toggle_fps_limit=Shift_L+F4' ;
        4:FPSLIMTOGGLE := 'toggle_fps_limit=none' ;
      end;


        ////FPS color - Config Variable

        if fpscolorCheckbox.checked = true then
        begin
          FPSCHANGE:= 'fps_color_change';
          FPSCOLOR := 'fps_color='+ ColorToHTMLColor(fpscolor1ColorButton.ButtonColor) + ',' + ColorToHTMLColor(fpscolor2ColorButton.ButtonColor) + ',' + ColorToHTMLColor(fpscolor3ColorButton.ButtonColor);
          FPSVALUE := 'fps_value='+ inttostr(fpscolor2SpinEdit.Value)+ ',' + inttostr(fpscolor3SpinEdit.Value)
        end;

      //VULKAN VSync   - Config Variable

      case vsyncComboBox.ItemIndex of
        0:VSYNC := 'vsync=0' ;
        1:VSYNC := 'vsync=1' ;
        2:VSYNC := 'vsync=2' ;
        3:VSYNC := 'vsync=3' ;
      end;

      //GL VSync   - Config Variable

      case glvsyncComboBox.ItemIndex of
        0:GLVSYNC := 'gl_vsync=-1' ;
        1:GLVSYNC := 'gl_vsync=0' ;
        2:GLVSYNC := 'gl_vsync=1' ;
        3:GLVSYNC := 'gl_vsync=n' ;
      end;


     // Filters - Config Variable

      case filterRadiogroup.ItemIndex of
        0:FILTER := '' ;
        1:FILTER := 'bicubic' ;
        2:FILTER := 'trilinear' ;
        3:FILTER := 'retro' ;
      end;



       //AF Filter   - Config Variable

      if afTrackbar.Position <> 0 then
      AFFILTER := 'af=' + FormatFloat('#0', afTrackbar.Position);


       //MIPMAP Filter   - Config Variable
      if mipmapTrackbar.Position <> 0 then
      MIPMAPFILTER := 'picmip=' + FormatFloat('#0', mipmapTrackbar.Position);


      //###############################################################################################   Extra TAB

      // Distro info - Config Variable


      Savecheckbox (distroinfoCheckBox, DISTROINFO1, 'custom_text=-');
      Savecheckbox (distroinfoCheckBox, DISTROINFO2, '"exec=cat ' + GetUserConfigDir + '/goverlay/distro"');


      Savecheckbox (distroinfoCheckBox, DISTROINFO3, 'custom_text=-');
      Savecheckbox (distroinfoCheckBox, DISTROINFO4, '"exec=uname -r"');


      // Arch - Config Variable
      Savecheckbox (archCheckBox, ARCH, 'arch');

      // Resolution - Config Variable
      Savecheckbox (resolutionCheckBox, RESOLUTION, 'resolution');



      // Time - Config Variable
      Savecheckbox (timeCheckBox, TIME, 'time#');

      // Wine - Config Variable
      Savecheckbox (wineCheckBox, WINE, 'wine');

      //Wine Color  - Config Variable

      WINECOLOR := 'wine_color=' + ColorToHTMLColor(wineColorButton.ButtonColor);


      // Engine - Config Variable
      Savecheckbox (engineversionCheckBox, ENGINE, 'engine_version');

      //Engine Color  - Config Variable

      ENGINECOLOR := 'engine_color=' + ColorToHTMLColor(engineColorButton.ButtonColor);


       //Engine Short  - Config Variable

      Savecheckbox (engineshortCheckBox, ENGINESHORT, 'engine_short_names');

       //HUD Version  - Config Variable

      Savecheckbox (hudversionCheckBox, HUDVERSION, 'version#');

      //GAMEMODE  - Config Variable

      Savecheckbox (gamemodestatusCheckBox, GAMEMODE, 'gamemode');

      //VKBASALT - Config Variable

      Savecheckbox (vkbasaltstatusCheckBox, VKBASALT, 'vkbasalt');

      //FCAT - Config Variable

      Savecheckbox (fcatCheckBox, FCAT, 'fcat');

      //FSR - Config Variable

      Savecheckbox (fsrCheckBox, FSR, 'fsr');

       //HDR - Config Variable

      Savecheckbox (hdrCheckBox, HDR, 'hdr');

      //Refresh Rate - Config Variable

      Savecheckbox (refreshrateCheckBox, REFRESHRATE, 'refresh_rate');

      //Battery percent - Config Variable

      Savecheckbox (batteryCheckBox, BATTERY, 'battery');

      //Battery Color  - Config Variable

      BATTERYCOLOR := 'battery_color=' + ColorToHTMLColor(batteryColorButton.ButtonColor);

       //Battery wattage - Config Variable

      Savecheckbox (batterywattCheckBox, BATTERYWATT, 'battery_watt');

      //Battery time - Config Variable

      Savecheckbox (batterytimeCheckBox, BATTERYTIME, 'battery_time');

      //device Battery - Config Variable

      Savecheckbox (deviceCheckBox, DEVICE, 'device_battery=gamepad,mouse');
      Savecheckbox (deviceCheckBox, DEVICEICON, 'device_battery_icon');

      //Media player - Config Variable

      Savecheckbox (mediaCheckBox, MEDIA, 'media_player');

      //Media player Color  - Config Variable

      MEDIACOLOR := 'media_player_color=' + ColorToHTMLColor(mediaColorButton.ButtonColor);

      // Session - Config Variable
      Savecheckbox (sessionCheckBox, SESSIONTXT, 'custom_text=Session:');
      Savecheckbox (sessionCheckBox, SESSION, '"exec=echo \$XDG_SESSION_TYPE"');

      // Fahrenheit - Config Variable

      Savecheckbox (fahrenheitCheckBox, FTEMP, 'temp_fahrenheit');


      //Custom command  - Config Variable

      if (customcommandEdit.Text <> '') and (customcommandEdit.Text <> 'Custom command') then
      begin
           CUSTOMCMD1 := 'custom_text=Custom';
           CUSTOMCMD2 := 'exec=' + customcommandEdit.Text;
      end;





      // Logging

      //Store logfolder in variable
      LOGFOLDER := 'output_folder='+ logfolderEdit.Text;

     //Log duration, delay and interval  - Config Variable

     LOGDURATION := 'log_duration=' + FormatFloat('#0', durationTrackbar.Position);
     LOGDELAY := 'autostart_log=' + FormatFloat('#0', delayTrackbar.Position);
     LOGINTERVAL := 'log_interval=' + FormatFloat('#0', intervalTrackbar.Position);

     //Toggle logging



      case logtoggleComboBox.ItemIndex of
        0:LOGTOGGLE := 'toggle_logging=Shift_L+F2' ;
        1:LOGTOGGLE := 'toggle_logging=Shift_L+F3' ;
        2:LOGTOGGLE := 'toggle_logging=Shift_L+F4' ;
        3:LOGTOGGLE := 'toggle_logging=Shift_L+F5' ;
        4:LOGTOGGLE := 'toggle_logging=none' ;
      end;

       //Log versioning  - Config Variable

       Savecheckbox (versioningCheckBox, LOGVER, 'log_versioning');

       //Log versioning  - Config Variable

       Savecheckbox (autouploadCheckBox, LOGAUTO, 'upload_logs');

    //##################################################################################################################  END -  Write config file


    //Visual Tab
    WriteConfig(HUDTITLE,MANGOHUDCFGFILE);
    WriteConfig(ORIENTATION,MANGOHUDCFGFILE);
    WriteConfig(HUDALPHA,MANGOHUDCFGFILE);
    WriteConfig(BORDERTYPE,MANGOHUDCFGFILE);
    WriteConfig(HUDALPHA,MANGOHUDCFGFILE);
    WriteConfig(HUDCOLOR,MANGOHUDCFGFILE);
    WriteConfig(FONTTYPE,MANGOHUDCFGFILE);
    WriteConfig(FONTSIZE,MANGOHUDCFGFILE);
    WriteConfig(FONTCOLOR,MANGOHUDCFGFILE);
    WriteConfig(HUDPOSITION,MANGOHUDCFGFILE);
    WriteConfig(TOGGLEHUD,MANGOHUDCFGFILE);
    WriteCheckboxConfig(hidehudCheckbox,HIDEHUD,MANGOHUDCFGFILE);
    WriteCheckboxConfig(hudcompactCheckbox,HUDCOMPACT,MANGOHUDCFGFILE);
    WriteConfig(PCIDEV,MANGOHUDCFGFILE);
    WriteConfig(TABLECOLUMNS,MANGOHUDCFGFILE);


    //Metrics - GPU
    WriteConfig(GPUTEXT,MANGOHUDCFGFILE);
    WriteCheckboxConfig(gpuavgloadCheckBox,GPUAVGLOAD,MANGOHUDCFGFILE);
    WriteCheckboxConfig(gpuloadcolorCheckBox,GPULOADCHANGE,MANGOHUDCFGFILE);
    WriteCheckboxConfig(gpuloadcolorCheckBox,GPULOADVALUE,MANGOHUDCFGFILE);
    WriteCheckboxConfig(gpuloadcolorCheckBox,GPULOADCOLOR,MANGOHUDCFGFILE);
    WriteCheckboxConfig(gpuvoltageCheckBox,GPUVOLTAGE,MANGOHUDCFGFILE);
    WriteCheckboxConfig(gputhrottlingCheckBox,GPUTHR,MANGOHUDCFGFILE);
    WriteCheckboxConfig(gpufreqCheckBox,GPUFREQ,MANGOHUDCFGFILE);
    WriteCheckboxConfig(gpumemfreqCheckBox,GPUMEMFREQ,MANGOHUDCFGFILE);
    WriteCheckboxConfig(gputempCheckBox,GPUTEMP,MANGOHUDCFGFILE);
    WriteCheckboxConfig(gpumemtempCheckBox,GPUMEMTEMP,MANGOHUDCFGFILE);
    WriteCheckboxConfig(gpujunctempCheckBox,GPUJUNCTEMP,MANGOHUDCFGFILE);
    WriteCheckboxConfig(gpufanCheckBox,GPUFAN,MANGOHUDCFGFILE);
    WriteCheckboxConfig(gpupowerCheckBox,GPUPOWER,MANGOHUDCFGFILE);
    WriteCheckboxConfig(gpuavgloadCheckBox,GPUCOLOR,MANGOHUDCFGFILE);



    //Metrics - CPU / MEM
    WriteConfig(CPUTEXT,MANGOHUDCFGFILE);
    WriteCheckboxConfig(cpuavgloadCheckBox,CPUAVGLOAD,MANGOHUDCFGFILE);
    WriteCheckboxConfig(cpuloadcoreCheckBox,CPULOADCORE,MANGOHUDCFGFILE);
    WriteConfig(CORELOADTYPE,MANGOHUDCFGFILE);
    WriteCheckboxConfig(cpuloadcolorCheckBox,CPULOADCHANGE,MANGOHUDCFGFILE);
    WriteCheckboxConfig(cpuloadcolorCheckBox,CPULOADVALUE,MANGOHUDCFGFILE);
    WriteCheckboxConfig(cpuloadcolorCheckBox,CPULOADCOLOR,MANGOHUDCFGFILE);
    WriteCheckboxConfig(cpufreqCheckBox,CPUCOREFREQ,MANGOHUDCFGFILE);
    WriteCheckboxConfig(cputempCheckBox,CPUTEMP,MANGOHUDCFGFILE);
    WriteCheckboxConfig(cpupowerCheckBox,CPUPOWER,MANGOHUDCFGFILE);
    WriteCheckboxConfig(cpuavgloadCheckBox,CPUCOLOR,MANGOHUDCFGFILE);



    //Metrics - IO/ SWAP / VRAM / RAM
  //WriteCheckboxConfig(diskioCheckBox,IOSTATS,MANGOHUDCFGFILE);
    WriteCheckboxConfig(diskioCheckBox,IOREAD,MANGOHUDCFGFILE);
    WriteCheckboxConfig(diskioCheckBox,IOWRITE,MANGOHUDCFGFILE);
    WriteCheckboxConfig(diskioCheckBox,IOCOLOR,MANGOHUDCFGFILE);
    WriteCheckboxConfig(swapusageCheckBox,SWAP,MANGOHUDCFGFILE);
    WriteCheckboxConfig(vramusageCheckBox,VRAM,MANGOHUDCFGFILE);
    WriteCheckboxConfig(vramusageCheckBox,VRAMCOLOR,MANGOHUDCFGFILE);
    WriteCheckboxConfig(vramusageCheckBox,VRAMCOLOR,MANGOHUDCFGFILE);
    WriteCheckboxConfig(ramusageCheckBox,RAM,MANGOHUDCFGFILE);
    WriteCheckboxConfig(ramusageCheckBox,RAMCOLOR,MANGOHUDCFGFILE);

    // Metrics - FPS / Engine / GPU model / Vulkan driver / Arch / Wine
    WriteCheckboxConfig(procmemCheckBox,PROCMEM,MANGOHUDCFGFILE);
    WriteCheckboxConfig(batteryCheckBox,BATTERY,MANGOHUDCFGFILE);
    WriteCheckboxConfig(batteryCheckBox,BATTERYCOLOR,MANGOHUDCFGFILE);
    WriteCheckboxConfig(batterywattCheckBox,BATTERYWATT,MANGOHUDCFGFILE);
    WriteCheckboxConfig(batterytimeCheckBox,BATTERYTIME,MANGOHUDCFGFILE);
    WriteCheckboxConfig(fpsCheckBox,FPS,MANGOHUDCFGFILE);
    WriteCheckboxConfig(fpsavgCheckBox,FPSAVG,MANGOHUDCFGFILE);
    WriteCheckboxConfig(engineversionCheckBox,ENGINE,MANGOHUDCFGFILE);
    WriteCheckboxConfig(engineversionCheckBox,ENGINECOLOR,MANGOHUDCFGFILE);
    WriteCheckboxConfig(engineshortCheckBox,ENGINESHORT,MANGOHUDCFGFILE);
    WriteCheckboxConfig(gpumodelCheckBox,GPUMODEL,MANGOHUDCFGFILE);
    WriteCheckboxConfig(vulkandriverCheckBox,VULKANDRIVER,MANGOHUDCFGFILE);
    WriteCheckboxConfig(archCheckBox,ARCH,MANGOHUDCFGFILE);
    WriteCheckboxConfig(wineCheckBox,WINE,MANGOHUDCFGFILE);
    WriteCheckboxConfig(wineCheckBox,WINECOLOR,MANGOHUDCFGFILE);
    WriteCheckboxConfig(frametimegraphCheckBox,FRAMETIMING,MANGOHUDCFGFILE);
    WriteCheckboxConfig(frametimegraphCheckBox,FRAMETIMEC,MANGOHUDCFGFILE);
    WriteCheckboxConfig(gputhrottlinggraphCheckBox,GPUTHRG,MANGOHUDCFGFILE);
    WriteCheckboxConfig(framecountCheckBox,FRAMECOUNT,MANGOHUDCFGFILE);
    WriteConfig(FPSLIMMET,MANGOHUDCFGFILE);
    WriteConfig(FPSLIMTOGGLE,MANGOHUDCFGFILE);

    //Performance


    WriteCheckboxConfig(showfpslimCheckBox,SHOWFPSLIM,MANGOHUDCFGFILE);
    WriteConfig(HISTOGRAM,MANGOHUDCFGFILE);
    WriteConfig(FPSLIM,MANGOHUDCFGFILE);
    WriteCheckboxConfig(resolutionCheckBox,RESOLUTION,MANGOHUDCFGFILE);
    WriteCheckboxConfig(fcatCheckBox,FCAT,MANGOHUDCFGFILE);
    WriteCheckboxConfig(fsrCheckBox,FSR,MANGOHUDCFGFILE);
    WriteCheckboxConfig(hdrCheckBox,HDR,MANGOHUDCFGFILE);
    WriteCheckboxConfig(winesyncCheckBox,WINESYNC,MANGOHUDCFGFILE);
    WriteCheckboxConfig(vpsCheckBox,VPS,MANGOHUDCFGFILE);
    WriteCheckboxConfig(fahrenheitCheckBox,FTEMP,MANGOHUDCFGFILE);
    WriteCheckboxConfig(refreshrateCheckBox,REFRESHRATE,MANGOHUDCFGFILE);
    WriteCheckboxConfig(gamemodestatusCheckBox,GAMEMODE,MANGOHUDCFGFILE);
    WriteCheckboxConfig(vkbasaltstatusCheckBox,VKBASALT,MANGOHUDCFGFILE);
    WriteCheckboxConfig(deviceCheckBox,DEVICE,MANGOHUDCFGFILE);
    WriteCheckboxConfig(deviceCheckBox,DEVICEICON,MANGOHUDCFGFILE);
    WriteCheckboxConfig(distroinfoCheckBox,DISTROINFO1,MANGOHUDCFGFILE);
    WriteCheckboxConfig(distroinfoCheckBox,DISTROINFO2,MANGOHUDCFGFILE);
    WriteCheckboxConfig(distroinfoCheckBox,DISTROINFO3,MANGOHUDCFGFILE);
    WriteCheckboxConfig(distroinfoCheckBox,DISTROINFO4,MANGOHUDCFGFILE);
    WriteCheckboxConfig(sessionCheckBox,SESSIONTXT,MANGOHUDCFGFILE);
    WriteCheckboxConfig(sessionCheckBox,SESSION,MANGOHUDCFGFILE);
    WriteCheckboxConfig(fpscolorCheckBox,FPSCHANGE ,MANGOHUDCFGFILE);
    WriteCheckboxConfig(fpscolorCheckBox,FPSCOLOR ,MANGOHUDCFGFILE);
    WriteCheckboxConfig(fpscolorCheckBox,FPSVALUE ,MANGOHUDCFGFILE);
    WriteConfig(OFFSET,MANGOHUDCFGFILE);
    WriteConfig(VSYNC,MANGOHUDCFGFILE);
    WriteConfig(GLVSYNC,MANGOHUDCFGFILE);
    WriteConfig(FILTER,MANGOHUDCFGFILE);
    WriteConfig(AFFILTER,MANGOHUDCFGFILE);
    WriteConfig(MIPMAPFILTER,MANGOHUDCFGFILE);


    //Extra

    WriteCheckboxConfig(timeCheckBox,TIME,MANGOHUDCFGFILE);
    WriteCheckboxConfig(hudversionCheckBox,HUDVERSION,MANGOHUDCFGFILE);
    WriteCheckboxConfig(mediaCheckBox,MEDIA,MANGOHUDCFGFILE);
    WriteCheckboxConfig(mediaCheckBox,MEDIACOLOR,MANGOHUDCFGFILE);
    WriteConfig(CUSTOMCMD1,MANGOHUDCFGFILE);
    WriteConfig(CUSTOMCMD2,MANGOHUDCFGFILE);
    WriteConfig(LOGFOLDER,MANGOHUDCFGFILE);
    WriteConfig(LOGDURATION,MANGOHUDCFGFILE);
    WriteConfig(LOGDELAY,MANGOHUDCFGFILE);
    WriteConfig(LOGINTERVAL,MANGOHUDCFGFILE);
    WriteConfig(LOGTOGGLE,MANGOHUDCFGFILE);
    WriteCheckboxConfig(versioningCheckBox,LOGVER,MANGOHUDCFGFILE);
    WriteCheckboxConfig(autouploadCheckBox,LOGAUTO,MANGOHUDCFGFILE);
    WriteConfig(NETWORK,MANGOHUDCFGFILE);

    //########################################### SAVE BLACKLIST

  BLACKLISTFILE := GetUserConfigDir + '/goverlay/blacklist.conf';
  MANGOHUDCFGFILE := GetUserConfigDir + '/MangoHud/MangoHud.conf';

  FileLines := TStringList.Create;
  ConfigLines := TStringList.Create;
  try
    // if blacklist.conf dont exist, create a stock one
    if not FileExists(BLACKLISTFILE) then
    begin
      FileLines.Add('pamac-manager');
      FileLines.Add('lact');
      FileLines.Add('ghb');
      FileLines.Add('bitwig-studio');
      FileLines.Add('ptyxis');
      FileLines.Add('yumex');
      ForceDirectories(ExtractFilePath(BLACKLISTFILE)); // create directory
      FileLines.SaveToFile(BLACKLISTFILE);
    end
    else
      FileLines.LoadFromFile(BLACKLISTFILE);  // load file


    // create string blacklistVAR with correct format
    blacklistVAR := 'blacklist=' + FileLines[0];
    for i := 1 to FileLines.Count - 1 do
      blacklistVAR := blacklistVAR + ',' + FileLines[i];

    // load mangohud config file
    if FileExists(MANGOHUDCFGFILE) then
      ConfigLines.LoadFromFile(MANGOHUDCFGFILE);


    // if there's no blacklist, add it to the end of file
    if not Found then
    begin
      ConfigLines.Add(blacklistVAR);
    end;

    // make sure mangohud directory exists
    ForceDirectories(ExtractFilePath(MANGOHUDCFGFILE));

    // Save changes to mangohud file
    ConfigLines.SaveToFile(MANGOHUDCFGFILE);


  finally
    FileLines.Free;
    ConfigLines.Free;
  end;

end;  //  ################### END - SAVE MANGOHUD




   // ################### START - SAVE VKBASALT

  //Save only if active page is vkbasalt tab
  if goverlayPageControl.ActivePage <> vkbasaltTabSheet then Exit;



  if VKBASALTFOLDER = '' then
  begin
    ShowMessage('vkBasalt directory not found');
    Exit;
  end;

  RepoDir := IncludeTrailingPathDelimiter(VKBASALTFOLDER) + 'reshade-shaders';

  Lines := TStringList.Create;
  try
    Lines.Add('################### File Generated by Goverlay ###################');
    Lines.Add('toggleKey = Home');
    Lines.Add('enableOnLaunch = True');
    Lines.Add('');

    // --- create effects list" ---
    EffectsLine := '';

    // 1) CAS (if active)
    if casTrackBar.Position >= 1 then
      AddEffectToLine('cas');

    // 2) reshade effects on the list
    for i := 0 to acteffectsListbox.Items.Count - 1 do
    begin
      RelPath := acteffectsListbox.Items[i];                       // ex: "Shaders/LUT.fx"
      EffectName := ChangeFileExt(ExtractFileName(RelPath), '');   // "LUT"
      AddEffectToLine(EffectName);
    end;

    // nothing to save ?
    if EffectsLine = '' then
    begin
      ShowMessage('No active effects');
      Exit;
    end;

    Lines.Add('effects = ' + EffectsLine);
    Lines.Add('');

    // --- CAS ajustment if active ---
    if casTrackBar.Position >= 1 then
    begin
      // map 1..10 -> 0.1..1.0
      Sharp := casTrackBar.Position / 10.0;

      // use dot for decimal value
      FS := DefaultFormatSettings;
      FS.DecimalSeparator := '.';

      Lines.Add('casSharpness = ' + FloatToStrF(Sharp, ffFixed, 3, 1, FS));
    end;

    // --- Map reshade effects ---
    for i := 0 to acteffectsListbox.Items.Count - 1 do
    begin
      RelPath := acteffectsListbox.Items[i];                       // "Shaders/Colorfulness.fx"
      EffectName := ChangeFileExt(ExtractFileName(RelPath), '');   // "Colorfulness"
      EffectKey := (EffectName);
      FullPath := IncludeTrailingPathDelimiter(RepoDir) + RelPath; // ".../reshade-shaders/Shaders/Colorfulness.fx"
      Lines.Add(EffectKey + ' = ' + FullPath);
    end;


    Lines.Add('');
    TexPath := IncludeTrailingPathDelimiter(RepoDir) + 'Textures';
    IncPath := IncludeTrailingPathDelimiter(RepoDir) + 'Shaders';
    Lines.Add('reshadeTexturePath = ' + TexPath);
    Lines.Add('reshadeIncludePath = ' + IncPath);

    // --- Save ---
    if not DirectoryExists(ExtractFileDir(VKBASALTCFGFILE)) then
      ForceDirectories(ExtractFileDir(VKBASALTCFGFILE));
    if FileExists(VKBASALTCFGFILE) then
      DeleteFile(VKBASALTCFGFILE);

    Lines.SaveToFile(VKBASALTCFGFILE);
    ExecuteShellCommand('notify-send -e -i ' + GetIconFile + ' "Goverlay" "vkBasalt configuration saved"');

  except
    on E: Exception do
      ShowMessage('Fail to save vkbasalt.conf: ' + E.Message);
  end;

  Lines.Free;



end; // ########################################      end save button click       ###############################################################################




procedure Tgoverlayform.subBitBtnClick(Sender: TObject);
  var
  i, idx, removed: Integer;

  function AnySelected(LB: TListBox): Boolean;
  var
    j: Integer;
  begin
    if LB.MultiSelect then
    begin
      for j := 0 to LB.Items.Count - 1 do
        if LB.Selected[j] then Exit(True);
      Result := False;
    end
    else
      Result := LB.ItemIndex >= 0;
  end;

begin
  if acteffectsListbox.Items.Count = 0 then
  begin
    ShowMessage('There is no active effects');
    Exit;
  end;

  if not AnySelected(acteffectsListbox) then
  begin
    ShowMessage('Select at least one effect to remove');
    Exit;
  end;

  removed := 0;

  if acteffectsListbox.MultiSelect then
  begin
    // Remove last to first
    acteffectsListbox.Items.BeginUpdate;
    try
      for i := acteffectsListbox.Items.Count - 1 downto 0 do
        if acteffectsListbox.Selected[i] then
        begin
          acteffectsListbox.Items.Delete(i);
          Inc(removed);
        end;
    finally
      acteffectsListbox.Items.EndUpdate;
    end;
    // clean selection
    acteffectsListbox.ItemIndex := -1;
  end
  else
  begin
    idx := acteffectsListbox.ItemIndex;
    acteffectsListbox.Items.Delete(idx);
    Inc(removed);
    // Select next neighbor item if exists
    if acteffectsListbox.Items.Count > 0 then
    begin
      if idx >= acteffectsListbox.Items.Count then
        idx := acteffectsListbox.Items.Count - 1;
      acteffectsListbox.ItemIndex := idx;
    end
    else
      acteffectsListbox.ItemIndex := -1;
  end;
end;

procedure Tgoverlayform.transpTrackBarChange(Sender: TObject);
begin
  //Display new values and trackbar changes
  alphavalueLabel.Caption:= FormatFloat('#0.0', transpTrackbar.Position/10);
end;





end.
