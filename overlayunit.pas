unit overlayunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  unix, StdCtrls, Spin, ComCtrls, Buttons, ColorBox, ActnList, Menus, aboutunit,
  ATStringProc_HtmlColor, blacklistUnit, customeffectsunit, LCLtype, CheckLst,
  FileUtil, StrUtils, Types;



type

  { Tgoverlayform }

  Tgoverlayform = class(TForm)
    aboutBitBtn: TBitBtn;
    acteffectsListBox: TListBox;
    addBitBtn: TBitBtn;
    blacklistBitBtn: TBitBtn;
    goverlayBitBtn: TBitBtn;
    alphavalueLabel: TLabel;
    mangocolorLabel: TLabel;
    mangocolorBitBtn: TBitBtn;
    whitecolorLabel: TLabel;
    whitecolorBitBtn: TBitBtn;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    MenuItem1: TMenuItem;
    offsetSpinEdit: TSpinEdit;
    fpsonlyBitBtn: TBitBtn;
    fullBitBtn: TBitBtn;
    basicBitBtn: TBitBtn;
    basichorizontalBitBtn: TBitBtn;
    fullLabel: TLabel;
    basicLabel: TLabel;
    basichorizontalLabel: TLabel;
    fpsonlyLabel: TLabel;
    customLabel: TLabel;
    layoutImageList: TImageList;
    popsaveMenu: TPopupMenu;
    usercustomBitBtn: TBitBtn;
    colorthemeLabel: TLabel;
    hudcompactCheckBox: TCheckBox;
    layoutsLabel: TLabel;
    presetTabSheet: TTabSheet;
    afterburnercolorBitBtn1: TBitBtn;
    afterburnercolorLabel: TLabel;
    customolorLabel: TLabel;
    winesyncCheckBox: TCheckBox;
    fpsavgCheckBox: TCheckBox;
    fpsavgBitBtn: TBitBtn;
    fahrenheitCheckBox: TCheckBox;
    networkComboBox: TComboBox;
    networkCheckBox: TCheckBox;
    versioningCheckBox: TCheckBox;
    backgroundGroupBox: TGroupBox;
    backgroundLabel: TLabel;
    logfolderBitBtn: TBitBtn;
    columShape1: TShape;
    columShape2: TShape;
    columShape3: TShape;
    columShape4: TShape;
    columShape5: TShape;
    columsGroupBox: TGroupBox;
    logfolderEdit: TEdit;
    fpscolor2ColorButton: TColorButton;
    fpslimCheckGroup: TCheckGroup;
    coreloadtypeBitBtn: TBitBtn;
    borderGroupBox: TGroupBox;
    bottomcenterRadioButton: TRadioButton;
    logtoggleImage: TImage;
    frametimetypeBitBtn: TBitBtn;
    fpsCheckBox: TCheckBox;
    gpudescEdit: TEdit;
    fontComboBox: TComboBox;
    fontcolorLabel: TLabel;
    fontsizevalueLabel: TLabel;
    archCheckBox: TCheckBox;
    fpscolor2SpinEdit: TSpinEdit;
    fpscolor3SpinEdit: TSpinEdit;
    autouploadCheckBox: TCheckBox;
    aveffectsListBox: TListBox;
    basaltgeSpeedButton: TSpeedButton;
    basaltGlobalenableLabel: TLabel;
    basaltrunBitBtn: TBitBtn;
    basaltsaveBitBtn: TBitBtn;
    batteryCheckBox: TCheckBox;
    batterywattCheckBox: TCheckBox;
    batterytimeCheckBox: TCheckBox;
    fpscolorCheckBox: TCheckBox;
    engineshortCheckBox: TCheckBox;
    cpuavgloadCheckBox: TCheckBox;
    cpuColorButton: TColorButton;
    cpufreqCheckBox: TCheckBox;
    cpuGroupBox: TGroupBox;
    cpuload1ColorButton: TColorButton;
    cpuload2ColorButton: TColorButton;
    cpuload3ColorButton: TColorButton;
    cpuloadcolorCheckBox: TCheckBox;
    cpuloadcoreCheckBox: TCheckBox;
    cpunameEdit: TEdit;
    cpupowerCheckBox: TCheckBox;
    cputempCheckBox: TCheckBox;
    customcommandEdit: TEdit;
    diskioCheckBox: TCheckBox;
    distroinfoCheckBox: TCheckBox;
    cpuImage: TImage;
    gpuvoltageCheckBox: TCheckBox;
    gpuImage: TImage;
    fpstoggleImage: TImage;
    hudtoggleImage: TImage;
    filterRadioGroup: TRadioGroup;
    columShape: TShape;
    columvalueLabel: TLabel;
    Image2: TImage;
    durationvalueLabel: TLabel;
    delayvalueLabel: TLabel;
    intervalvalueLabel: TLabel;
    logtoggleLabel: TLabel;
    logdurationLabel: TLabel;
    logintervalLabel: TLabel;
    logdelayLabel: TLabel;
    logfolderLabel: TLabel;
    sysinfoImage: TImage;
    refreshrateCheckBox: TCheckBox;
    showfpslimCheckBox: TCheckBox;
    plusSpeedButton: TSpeedButton;
    minusButton: TSpeedButton;
    durationTrackBar: TTrackBar;
    delayTrackBar: TTrackBar;
    intervalTrackBar: TTrackBar;
    vulkandriverCheckBox: TCheckBox;
    engineColorButton: TColorButton;
    engineversionCheckBox: TCheckBox;
    extrasTabSheet: TTabSheet;
    metricsSheet: TTabSheet;
    FontcolorButton: TColorButton;
    C: TComboBox;
    fpslimmetComboBox: TComboBox;
    fpslimLabel1: TLabel;
    cpumainmetricsLabel: TLabel;
    cputempLabel: TLabel;
    memLabel: TLabel;
    systemLabel: TLabel;
    wineLabel: TLabel;
    optionsLabel: TLabel;
    batteryLabel: TLabel;
    othersLabel: TLabel;
    fpslimLabel3: TLabel;
    mainmetricLabel: TLabel;
    gputempLabel: TLabel;
    gpupowerLabel: TLabel;
    gpuinfoLabel: TLabel;
    fpslimtoggleComboBox: TComboBox;
    framecountCheckBox: TCheckBox;
    frametimegraphCheckBox: TCheckBox;
    frametimegraphColorButton: TColorButton;
    batteryColorButton: TColorButton;
    gamemodestatusCheckBox: TCheckBox;
    deviceCheckBox: TCheckBox;
    geSpeedButton: TSpeedButton;
    GlobalenableLabel: TLabel;
    glvsyncComboBox: TComboBox;
    gpuavgloadCheckBox: TCheckBox;
    gpuColorButton: TColorButton;
    gpufreqCheckBox: TCheckBox;
    gpuGroupBox: TGroupBox;
    fpscolor1ColorButton: TColorButton;
    gpuload1ColorButton: TColorButton;
    gpuload2ColorButton: TColorButton;
    fpscolor3ColorButton: TColorButton;
    gpuload3ColorButton: TColorButton;
    gpuloadcolorCheckBox: TCheckBox;
    gpumemfreqCheckBox: TCheckBox;
    gpumodelCheckBox: TCheckBox;
    gpunameEdit: TEdit;
    gpupowerCheckBox: TCheckBox;
    gputempCheckBox: TCheckBox;
    gpujunctempCheckBox: TCheckBox;
    gpumemtempCheckBox: TCheckBox;
    gpufanCheckBox: TCheckBox;
    gputhrottlingCheckBox: TCheckBox;
    gputhrottlinggraphCheckBox: TCheckBox;
    fpsGroupBox: TGroupBox;
    hImage: TImage;
    horizontalRadioButton: TRadioButton;
    hudbackgroundColorButton: TColorButton;
    hudversionCheckBox: TCheckBox;
    Image1: TImage;
    systemGroupBox: TGroupBox;
    logtoggleComboBox: TComboBox;
    loggingGroupBox: TGroupBox;
    mediaCheckBox: TCheckBox;
    mediaColorButton: TColorButton;
    hidehudCheckBox: TCheckBox;
    hudonoffComboBox: TComboBox;
    hudtitleEdit: TEdit;
    orientationGroupBox: TGroupBox;
    PaintBox1: TPaintBox;
    fontLabel: TLabel;
    fontsizeTrackBar: TTrackBar;
    roundImage: TImage;
    roundRadioButton: TRadioButton;
    squareImage: TImage;
    squareRadioButton: TRadioButton;
    topleftRadioButton: TRadioButton;
    topcenterRadioButton: TRadioButton;
    bottomleftRadioButton: TRadioButton;
    middleleftRadioButton: TRadioButton;
    toprightRadioButton: TRadioButton;
    bottomrightRadioButton: TRadioButton;
    middlerightRadioButton: TRadioButton;
    intelpowerfixBitBtn: TBitBtn;
    iordrwColorButton: TColorButton;
    hudtoggleLabel: TLabel;
    mangohudPageControl: TPageControl;
    mangohudPanel: TPanel;
    notificationLabel: TLabel;
    openglImage: TImage;
    PageControl2: TPageControl;
    pcidevComboBox: TComboBox;
    fpslimiterGroupBox: TGroupBox;
    performanceTabSheet: TTabSheet;
    positionGroupBox: TGroupBox;
    Process1: TProcess;
    procmemCheckBox: TCheckBox;
    ramColorButton: TColorButton;
    ramusageCheckBox: TCheckBox;
    reshadeLabel1: TLabel;
    reshadeLabel2: TLabel;
    reshadeProgressBar: TProgressBar;
    reshadesyncBitBtn: TBitBtn;
    resolutionCheckBox: TCheckBox;
    afTrackBar: TTrackBar;
    mipmapTrackBar: TTrackBar;
    mipmapvalueLabel: TLabel;
    afvalueLabel: TLabel;
    popupBitBtn: TBitBtn;
    runvkbasaltBitBtn: TBitBtn;
    saveBitBtn: TBitBtn;
    sessionCheckBox: TCheckBox;
    subBitBtn: TBitBtn;
    swapusageCheckBox: TCheckBox;
    TabSheet8: TTabSheet;
    timeCheckBox: TCheckBox;
    transparencyLabel: TLabel;
    afLabel: TLabel;
    mipmapLabel: TLabel;
    transpTrackBar: TTrackBar;
    fontsGroupBox: TGroupBox;
    verticalRadioButton: TRadioButton;
    vImage: TImage;
    visualTabSheet: TTabSheet;
    vkbasaltPanel: TPanel;
    vkbasaltstatusCheckBox: TCheckBox;
    fsrCheckBox: TCheckBox;
    hdrCheckBox: TCheckBox;
    fcatCheckBox: TCheckBox;
    vkbtogglekeyCombobox: TComboBox;
    iconsImageList: TImageList;
    columImageList: TImageList;
    dependencieSpeedButton: TSpeedButton;
    casTrackBar2: TTrackBar;
    globalbuttonImageList: TImageList;
    mangohudLabel: TLabel;
    dependenciesLabel: TLabel;
    vkbasaltLabel: TLabel;
    goverlayimage: TImage;
    mangohudShape: TShape;
    vkbasaltShape: TShape;
    vktoggleLabel: TLabel;
    vramColorButton: TColorButton;
    vramusageCheckBox: TCheckBox;
    vsyncComboBox: TComboBox;
    vsyncGroupBox: TGroupBox;
    filtersGroupBox: TGroupBox;
    vulkanImage: TImage;
    wineCheckBox: TCheckBox;
    wineColorButton: TColorButton;
    vpsCheckBox: TCheckBox;

    procedure aboutBitBtnClick(Sender: TObject);
    procedure afterburnercolorBitBtn1Click(Sender: TObject);
    procedure afTrackBarChange(Sender: TObject);
    procedure basicBitBtnClick(Sender: TObject);
    procedure basichorizontalBitBtnClick(Sender: TObject);
    procedure blacklistBitBtnClick(Sender: TObject);
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
    procedure MenuItem1Click(Sender: TObject);
    procedure minusButtonClick(Sender: TObject);
    procedure mipmapTrackBarChange(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure pcidevComboBoxChange(Sender: TObject);
    procedure plusSpeedButtonClick(Sender: TObject);
    procedure popupBitBtnClick(Sender: TObject);
    procedure saveBitBtnClick(Sender: TObject);
    procedure transpTrackBarChange(Sender: TObject);
    procedure SetAllCheckBoxesToFalse;
    procedure SetAllCheckBoxesToTrue;
    procedure usercustomBitBtnClick(Sender: TObject);
    procedure whitecolorBitBtnClick(Sender: TObject);

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
BlacklistStr, blacklistVAR: string;



  //Boolean variables
  mangohudsel: boolean;
  vkbasaltsel: boolean;
  Found: Boolean;

  //Mangohud variables ##########################
  AUX, AUX2, MANGOHUDCFGFILE, MANGOHUDFOLDER, CUSTOMCFGFILE, BLACKLISTFILE, FONTFOLDER, HOMEPATH, USERHOME, GOVERLAYFOLDER, GPU0, LSPCI0: string;

  //########################################
  i, GPUNUMBER, GPUCOUNT, COLUMNS, maxValue, currentValue: integer;
  FILELINES, GPUDESC: TStringList;

  ArquivoConfig: TextFile;
  Linha: string;
  CaminhoArquivo, NomeCampo, ValorCampo: string;

  fpsArray: TStringArray;

implementation

{$R *.lfm}


{ Tgoverlayform }


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



//Function to find font files (*.ttf) in /usr/share/fonts
procedure ListarFontesNoDiretorio(Diretorio: string; ComboBox: TComboBox);
var
  Arquivos: TStringList;
  Arquivo: String;
begin

  Arquivos := FindAllFiles(Diretorio, '*.ttf'); // Locate TTF files in Diretorio

  try
    for Arquivo in Arquivos do
    begin
      ComboBox.Items.Add(ExtractFileName(Arquivo)); // Add filename into combobox
    end;
  finally
    Arquivos.Free; // Free memory
  end;
end;


//Procedure to WriteConfig to file
Procedure WriteConfig(PARAMETRO, FILEPATH: string);
var
  Process1: TProcess;
begin
    Process1 := TProcess.Create(nil);
    Process1.Executable := 'sh';
    Process1.Parameters.Add('-c');
    Process1.Parameters.Add('echo ' + PARAMETRO + ' >> ' + FILEPATH);
    Process1.Options := [poWaitOnExit, poUsePipes];
    Process1.Execute;
    Process1.Free;
end;


//Procedure to WriteConfig to file if checkbox is checked
Procedure WriteCheckboxConfig(CHECKBOXNAME: TCheckbox; PARAMETRO, FILEPATH: string);
var
  Process1: TProcess;
begin

    if CHECKBOXNAME.checked = true then
    begin
    Process1 := TProcess.Create(nil);
    Process1.Executable := 'sh';
    Process1.Parameters.Add('-c');
    Process1.Parameters.Add('echo ' + PARAMETRO + ' >> ' + FILEPATH);
    Process1.Options := [poWaitOnExit, poUsePipes];
    Process1.Execute;
    Process1.Free;
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

  CaminhoArquivo := GetEnvironmentVariable('HOME') + '/.config/MangoHud/MangoHud.conf';

  Process.Executable := '/bin/bash';
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
function LoadName(const Parametro: string): Boolean;
var
  Process: TProcess;
  Output: TStringList;
  CaminhoArquivo: string;
  variavel: string;
begin
  Process := TProcess.Create(nil);
  Output := TStringList.Create;

  CaminhoArquivo := GetEnvironmentVariable('HOME') + '/.config/MangoHud/MangoHud.conf';

  Process.Executable := '/bin/bash';
  Process.Parameters.Add('-c');
  Process.Parameters.Add('cat ' +  CaminhoArquivo + ' | grep ' + Parametro);
  Process.Options := [poUsePipes];
  Process.Execute;

  Output.LoadFromStream(Process.Output);


  // debug
  WriteLn('Parametro: ', Parametro);


  if output.Count > 0 then
    Result := true
    else
    Result := false;    // Retorna verdadeiro se o valor foi encontrado, falso caso contrário
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





function GetKernelVersion: string;
var
  Output: TStringList;
  AProcess: TProcess;
begin
  Result := '';
  AProcess := TProcess.Create(nil);
  Output := TStringList.Create;
  try
    AProcess.Executable := '/bin/uname';
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
  F: TextFile;
  SL: TStringList;
  I: Integer;
begin
  DistroInfo := '';
  VersionOrBuildID := '';

  // check if /etc/os-release exists
  if FileExists('/etc/os-release') then
  begin
    SL := TStringList.Create;
    try
      SL.LoadFromFile('/etc/os-release');

      for I := 0 to SL.Count - 1 do
      begin
        Line := SL[I];

        if Pos('PRETTY_NAME=', Line) = 1 then
        begin
          // Remove "PRETTY_NAME=" e as aspas
          DistroInfo := Copy(Line, 13, Length(Line) - 12);
          DistroInfo := StringReplace(DistroInfo, '"', '', [rfReplaceAll]);
        end
        else if Pos('VERSION_ID=', Line) = 1 then
        begin
          // Remove "VERSION_ID=" e as aspas
          VersionOrBuildID := Copy(Line, 12, Length(Line) - 11);
          VersionOrBuildID := StringReplace(VersionOrBuildID, '"', '', [rfReplaceAll]);
        end
        else if (Pos('BUILD_ID=', Line) = 1) and (VersionOrBuildID = '') then
        begin
          // Se VERSION_ID no foi encontrado, usa BUILD_ID
          VersionOrBuildID := Copy(Line, 10, Length(Line) - 9);
          VersionOrBuildID := StringReplace(VersionOrBuildID, '"', '', [rfReplaceAll]);
        end;
      end;
    finally
      SL.Free;
    end;
  end;

  // Got kernel version
  KernelVersion := GetKernelVersion;

  // create directory
  if not DirectoryExists(GetUserDir + '.config/goverlay') then
    CreateDir(GetUserDir + '.config/goverlay');

  // storing distro name
  AssignFile(F, GetUserDir + '.config/goverlay/distro');
  try
    Rewrite(F);
    WriteLn(F, DistroInfo + ' (' + VersionOrBuildID + ')');
  finally
    CloseFile(F);
  end;

  // storing kernel version
  AssignFile(F, GetUserDir + '.config/goverlay/kernel');
  try
    Rewrite(F);
    WriteLn(F, KernelVersion);
  finally
    CloseFile(F);
  end;
end;






procedure Tgoverlayform.usercustomBitBtnClick(Sender: TObject);
begin

  // Update the config files path
   CUSTOMCFGFILE := GetEnvironmentVariable('HOME') + '/.config/MangoHud/custom.conf';
   MANGOHUDCFGFILE := GetEnvironmentVariable('HOME') + '/.config/MangoHud/MangoHud.conf';




if not FileExists(CUSTOMCFGFILE) then
begin
  ShowMessage('You need to save a custom preset first. Click on the hamburguer menu and click save as custom config.');
end
else
begin
  Process1 := TProcess.Create(nil);
  try
    Process1.Executable := 'sh';
    Process1.Parameters.Add('-c');
    Process1.Parameters.Add('cp ' + CUSTOMCFGFILE + ' ' + MANGOHUDCFGFILE);
    Process1.Options := [poWaitOnExit, poUsePipes];
    Process1.Execute;
    Process1.WaitOnExit;
  finally
    Process1.Free;
  end;
end;

  // Change button color
  fullBitbtn.Color:=clDefault;
  basicBitbtn.Color:=clDefault;
  basichorizontalBitbtn.Color:=clDefault;
  fpsonlyBitbtn.Color:=clDefault;
  usercustomBitbtn.Color:=$007F5500;

  Process1 := TProcess.Create(nil);
  Process1.Executable := 'sh';
  Process1.Parameters.Add('-c');
  Process1.Parameters.Add('notify-send -e -i /usr/share/icons/hicolor/128x128/apps/goverlay.png "MangoHud" "Reloading custom user preset"');
  Process1.Options := [poUsePipes];
  Process1.Execute;
  Process1.WaitOnExit;
  Process1.Free;

  end;

procedure Tgoverlayform.whitecolorBitBtnClick(Sender: TObject);
begin
  //Set mangohud colors
hudbackgroundColorButton.ButtonColor:= clblack;
fontColorButton.ButtonColor := clwhite;
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

//Procedure to list network interfaces
procedure GetNetworkInterfaces(ComboBox: TComboBox);
var
  AProcess: TProcess;
  AStringList: TStringList;
  OutputLine, InterfaceName: String;
  i: Integer;
begin
  // Inicializa o TProcess
  AProcess := TProcess.Create(nil);
  AStringList := TStringList.Create;
  try
    // Configura o processo para executar o comando 'ip link'
    AProcess.Executable := '/sbin/ip';
    AProcess.Parameters.Add('link');
    AProcess.Options := AProcess.Options + [poWaitOnExit, poUsePipes];

    // Executa o comando
    AProcess.Execute;

    // Lê a saída do comando
    AStringList.LoadFromStream(AProcess.Output);

    // Limpa o ComboBox
    ComboBox.Items.Clear;

    // Processa a saída para obter os nomes das interfaces
    for i := 0 to AStringList.Count - 1 do
    begin
      OutputLine := AStringList[i];
      if Pos(': ', OutputLine) > 0 then
      begin
        // Extrai o nome da interface (parte entre ": " e ":")
        InterfaceName := Trim(Copy(OutputLine, Pos(': ', OutputLine) + 2, Pos(':', OutputLine, Pos(': ', OutputLine) + 2) - Pos(': ', OutputLine) - 2));
        // Adiciona o nome da interface ao ComboBox
        ComboBox.Items.Add(InterfaceName);
      end;
    end;
  finally
    AStringList.Free;
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






procedure Tgoverlayform.FormCreate(Sender: TObject);

var
  Process: TProcess;
  AppHandle: THandle;
  saida, Output, FileLines, DefaultConfigContent: TStringList;
  i: Integer;
  ConfigFilePath,ConfigFileBlacklistPath, ConfigDir,ConfigBlacklistDir, BlacklistFile: string;

  FPSList: TStringList;
  ConfigFile: TStringList;
  Line, FPSValues, OffsetValue: string;
  Offset, FPS, MaxFPS: Integer;
  FPSNumbers: TStringList;
  FoundFPSLimit: Boolean;

  OSFile: TextFile;
begin

  //Set initial TAB
  mangohudPageControl.ActivePage:=presetTabsheet;

   // Initialize menu selections
  mangohudsel := true;
  mangohudPanel.Visible:=true;
  vkbasaltsel := false;
  vkbasaltPanel.Visible:=false;



  // Define important file paths

  GOVERLAYFOLDER := GetEnvironmentVariable('HOME') + '/.config/goverlay/';
  MANGOHUDFOLDER := GetEnvironmentVariable('HOME') + '/.config/MangoHud/';
  MANGOHUDCFGFILE := GetEnvironmentVariable('HOME') + '/.config/MangoHud/MangoHud.conf';
  BlacklistFile := GetEnvironmentVariable('HOME') + '/.config/goverlay/blacklist.conf';
  CUSTOMCFGFILE := GetEnvironmentVariable('HOME') + '/.config/MangoHud/custom.conf';
  FONTFOLDER := '/usr/share/fonts/';
  USERHOME := GetEnvironmentVariable('HOME');
  USERSESSION := GetEnvironmentVariable('XDG_SESSION_TYPE');

  //Get distro information
  SaveDistroInfo;

  //Check for bazzite
   if FileExists('/etc/os-release') then
  begin
    AssignFile(OSFile, '/etc/os-release');
    try
      Reset(OSFile);

      while not EOF(OSFile) do
      begin
        ReadLn(OSFile, Line);

        // Verifica se a linha contém "PRETTY_NAME="
        if Pos('PRETTY_NAME=', Line) = 1 then
        begin
          // Remove "PRETTY_NAME=" e aspas extras
          Delete(Line, 1, Length('PRETTY_NAME='));
          Line := StringReplace(Line, '"', '', [rfReplaceAll]);

          // Converte para minúsculas e verifica se contém "bazzite"
          if Pos('bazzite', LowerCase(Line)) > 0 then
          begin
            if Assigned(gespeedbutton) then
            begin
              gespeedbutton.Visible := False; // Oculta o botão
              GlobalenableLabel.Caption:='Global enable is not avaiable in Bazzite';
            end;
          end;
          Break; // Já encontramos a informação necessária, saímos do loop
        end;
      end;
    finally
      CloseFile(OSFile);
    end;
  end;


// Start vkcube (vulkan demo)


  if USERSESSION = 'wayland' then
  begin
     Process := TProcess.Create(nil);
     Process.Executable := 'sh';
     Process.Parameters.Add('-c');
     //Process.Parameters.Add('mangohud vkcube-wayland');  //deprecated ??
     Process.Parameters.Add('mangohud vkcube --wsi wayland');
     Process.Options := [poUsePipes];
     Process.Execute;
  end
      else
    begin
     Process := TProcess.Create(nil);
     Process.Executable := 'sh';
     Process.Parameters.Add('-c');
     Process.Parameters.Add('mangohud vkcube');
     Process.Options := [poUsePipes];
     Process.Execute;
  end;


  // Substitui $HOME pelo caminho real do diretório do usuário
   ConfigFilePath := StringReplace(MANGOHUDCFGFILE, '$HOME', GetEnvironmentVariable('HOME'), [rfReplaceAll]);
   ConfigDir := ExtractFilePath(ConfigFilePath);

   // Verifica se o diretório existe, se não, cria
   if not DirectoryExists(ConfigDir) then
     CreateDir(ConfigDir);

   // Verifica se o arquivo existe
   if not FileExists(ConfigFilePath) then
   begin


    // Exibe notificacao
    Process1 := TProcess.Create(nil);
    Process1.Executable := 'sh';
    Process1.Parameters.Add('-c');
    Process1.Parameters.Add('notify-send -e -i /usr/share/icons/hicolor/128x128/apps/goverlay.png "Goverlay" "No configuration files located, creating files and folders."');
    Process1.Options := [poUsePipes];
    Process1.Execute;
    Process1.WaitOnExit;
    Process1.Free;

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


   // Check blacklist directory
  BlacklistFile := GetEnvironmentVariable('HOME') + '/.config/goverlay/blacklist.conf';

  // make sure directory exists
  ForceDirectories(ExtractFilePath(BlacklistFile));

  // Check if file exists and create default
  if not FileExists(BlacklistFile) then
  begin
    FileLines := TStringList.Create;
    try
      FileLines.Add('pamac-manager');
      FileLines.Add('lact');
      FileLines.Add('ghb');
      FileLines.Add('bitwig-studio');
      FileLines.Add('ptyxis');
      FileLines.Add('yumex');
      FileLines.SaveToFile(BlacklistFile);
    finally
      FileLines.Free;
    end;
  end;




  //Load avaiable text fonts in /usr/share/fonts
   ListarFontesNoDiretorio('/usr/share/fonts/', fontComboBox);



  //Detect system GPUs

  // Count the number of detected GPUs
    Process1 := TProcess.Create(nil);
    saida := TStringList.Create;

    Process1.Executable := 'sh';
    Process1.Parameters.Add('-c');
    Process1.Parameters.Add('lspci | grep -i "VGA\|video" | wc -l'); //Count the number of lines
    Process1.Options := [poUsePipes];
    Process1.WaitOnExit;
    Process1.Execute;

    saida.LoadFromStream(Process1.output);
    GPUNUMBER:= strtoint(saida[0]);
    Process1.Free;
    saida.Free;



    i := 1; // Integer variable to the while loop
    GPUDESC := TStringList.Create;  // List variable for GPU descriptions

    while i <= GPUNUMBER do
    begin
      //Read GPU0 pcidev
      Process1 := TProcess.Create(nil);
      saida := TStringList.Create;

      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('lspci | grep -i "VGA\|video" | sed -n "' + inttostr(i) + 'p" | cut -c 1-7');  //Pick just the "i" line
      Process1.Options := [poUsePipes];
      Process1.WaitOnExit;
      Process1.Execute;

      saida.LoadFromStream(Process1.output);
      pcidevComboBox.Items.Insert(i-1, saida[0]); //First position of combobox is 0, so we need i-1
      Process1.Free;
      saida.Free;


      //Read GPU description
      Process1 := TProcess.Create(nil);
      saida := TStringList.Create;

      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('lspci | grep -i "VGA\|video" | sed -n "' + inttostr(i) + 'p" |cut -d" " -f3- | cut -d ":" -f2-'); //Pick just the first line
      Process1.Options := [poUsePipes];
      Process1.WaitOnExit;
      Process1.Execute;

      saida.LoadFromStream(Process1.output);
      GPUDESC.Add(saida[0]);
      Process1.Free;
      saida.Free;

      i := i + 1; //increment "i"variable



    end; //while


   //Detect network devices on startup
   GetNetworkInterfaces(networkcombobox);


     //Determine toggle position - MangoHUD
     Process1 := TProcess.Create(nil);
     saida := TStringList.Create;

     Process1.Executable := 'sh';
     Process1.Parameters.Add('-c');
     Process1.Parameters.Add('cat /etc/environment | grep MANGOHUD=1');
     Process1.Options := [poUsePipes];
     Process1.Execute;
     Process1.WaitOnExit;
     saida.LoadFromStream(Process1.output);


     if saida.Count > 0 then    // Count will prevent the out of bound error, case the string doesn't exist
       geSpeedbutton.ImageIndex := 1
     else
       geSpeedbutton.ImageIndex := 0;

     Process1.Free;
     saida.Free;



     // Initial STOCK values

     alphavalueLabel.Caption:= FormatFloat('#0.0', transpTrackbar.Position/10);
     fontsizevalueLabel.Caption:=inttostr(fontsizeTrackbar.Position);
     fontcombobox.ItemIndex:=0;
     afvalueLabel.Caption:= FormatFloat('#0', afTrackbar.Position);
     mipmapvalueLabel.Caption:= FormatFloat('#0', mipmapTrackbar.Position);
     logfolderEdit.text := USERHOME;
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
      Process1 := TProcess.Create(nil);
      saida := TStringList.Create;

      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('lspci | grep -i "VGA\|video" | sed -n 1p | cut -c 1-7');  //Pick just the "i" line
      Process1.Options := [poUsePipes];
      Process1.WaitOnExit;
      Process1.Execute;

      saida.LoadFromStream(Process1.output);
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
    if LoadName('io_stats') then
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



         Process1 := TProcess.Create(nil);
         Process1.Executable := 'sh';
         Process1.Parameters.Add('-c');
         Process1.Parameters.Add('echo MANGOHUD=1 | pkexec tee -a /etc/environment');
         Process1.Options := [poUsePipes];
         Process1.Execute;
         Process1.WaitOnExit;
         Process1.Free;

         Process1 := TProcess.Create(nil);
         Process1.Executable := 'sh';
         Process1.Parameters.Add('-c');
         Process1.Parameters.Add('notify-send -e -i /usr/share/icons/hicolor/128x128/apps/goverlay.png "VULKAN Global Enable Activated" "Every Vulkan application will have Mangohud Enabled now"');
         Process1.Options := [poUsePipes];
         Process1.Execute;
         Process1.WaitOnExit;
         Process1.Free;


      showmessage ('Restart your system to take effect');
    end;

     1: begin
       geSpeedButton.ImageIndex:=0; ////switch button position to OFF



         Process1 := TProcess.Create(nil);
         Process1.Executable := 'sh';
         Process1.Parameters.Add('-c');
         Process1.Parameters.Add('pkexec sed -i -e "/MANGOHUD=1/d" /etc/environment');
         Process1.Options := [poWaitOnExit, poUsePipes];
         Process1.Execute;
         Process1.Free;

         Process1 := TProcess.Create(nil);
         Process1.Executable := 'sh';
         Process1.Parameters.Add('-c');
         Process1.Parameters.Add('notify-send -e -i /usr/share/icons/hicolor/128x128/apps/goverlay.png "Deactivated"');
         Process1.Options := [poWaitOnExit, poUsePipes];
         Process1.Execute;
         Process1.Free;


       showmessage ('Restart your system to take effect');
    end;
end;

end;

procedure Tgoverlayform.mangocolorBitBtnClick(Sender: TObject);
begin

//Set mangohud colors
hudbackgroundColorButton.ButtonColor:= clblack;
fontColorButton.ButtonColor := clwhite;
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

procedure Tgoverlayform.MenuItem1Click(Sender: TObject);
begin
     // Save current config
    saveBitbtn.Click;

    // Copy Mangohud.conf file to custom.conf

    Process1 := TProcess.Create(nil);
    Process1.Executable := 'sh';
    Process1.Parameters.Add('-c');
    Process1.Parameters.Add('cp '+ MANGOHUDCFGFILE + ' ' + CUSTOMCFGFILE);
    Process1.Options := [poWaitOnExit, poUsePipes];
    Process1.Execute;
    Process1.WaitOnExit;
    Process1.Free;

    //Notification
    Process1 := TProcess.Create(nil);
    Process1.Executable := 'sh';
    Process1.Parameters.Add('-c');
    Process1.Parameters.Add('notify-send -e -i /usr/share/icons/hicolor/128x128/apps/goverlay.png "Goverlay" "Settings saved as custom config"');
    Process1.Options := [poWaitOnExit, poUsePipes];
    Process1.Execute;
    Process1.WaitOnExit;
    Process1.Free;
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
   aboutForm.show;
end;

procedure Tgoverlayform.afterburnercolorBitBtn1Click(Sender: TObject);
begin
//Set afterburner colors
hudbackgroundColorButton.ButtonColor:= clblack;
fontColorButton.ButtonColor := clFuchsia;
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
  blacklistForm.Show;
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
   AProcess.Executable := '/usr/bin/lspci';
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
    cpuColorButton.ButtonColor := $007D3926; // Example color for Intel
    ramColorButton.ButtonColor := $007D3926; // Example color for RAM button
    frametimegraphColorButton.ButtonColor := $007D3926; // Example color for Frame Time Graph
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
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('pkexec chmod o+r /sys/class/powercap/intel-rapl\:0/energy_uj');
      Process1.Options := [poUsePipes];
      Process1.Execute;
      Process1.WaitOnExit;
      Process1.Free;

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

procedure Tgoverlayform.PaintBox1Paint(Sender: TObject);
var
  i: Integer;

  //Gradient color of main menu
  begin
  for i := 0 to PaintBox1.Height do
  begin
    // Calcula um valor entre 97 (#616161) e 0 (#000000) para cada componente RGB
    // na faixa da parte superior para a inferior do PaintBox1
    PaintBox1.Canvas.Pen.Color := RGBToColor(Round(i / PaintBox1.Height * 97),
                                             Round(i / PaintBox1.Height * 97),
                                             Round(i / PaintBox1.Height * 97));
    PaintBox1.Canvas.Brush.Color := PaintBox1.Canvas.Pen.Color;
    PaintBox1.Canvas.Line(0, i, PaintBox1.Width, i);
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


  ValorItem: string;
  LOCATEDFILE, FPSSEL, FPSSELOFF: TStringList;
  FoundIndex,i: integer;
  NOITEMCHECK: boolean;
  Process: TProcess;
  Output,FileLines, ConfigLines: TStringList;

  MaxFPS, SelectedFPS: Integer;
  SelectedValues: TStringList;

  begin

  //Create directories

    Process1 := TProcess.Create(nil);
    Process1.Executable := 'sh';
    Process1.Parameters.Add('-c');
    Process1.Parameters.Add('mkdir -p '+ MANGOHUDFOLDER);
    Process1.Options := [poUsePipes];
    Process1.Execute;
    Process1.WaitOnExit;
    Process1.Free;

  // Delete old files if it exists

    Process1 := TProcess.Create(nil);
    Process1.Executable := 'sh';
    Process1.Parameters.Add('-c');
    Process1.Parameters.Add('rm '+ MANGOHUDCFGFILE);
    Process1.Options := [poUsePipes];
    Process1.Execute;
    Process1.WaitOnExit;
    Process1.Free;

  // Create a new file for GOverlay

    Process1 := TProcess.Create(nil);
    Process1.Executable := 'sh';
    Process1.Parameters.Add('-c');
    Process1.Parameters.Add('echo "################### File Generated by Goverlay ###################" >> '+ MANGOHUDCFGFILE);
    Process1.Options := [poUsePipes];
    Process1.Execute;
    Process1.WaitOnExit;
    Process1.Free;



    Process1 := TProcess.Create(nil);
    Process1.Executable := 'sh';
    Process1.Parameters.Add('-c');
    Process1.Parameters.Add('echo "legacy_layout=false" >> '+ MANGOHUDCFGFILE);
    Process1.Options := [poUsePipes];
    Process1.Execute;
    Process1.WaitOnExit;
    Process1.Free;


  // Popup a notification


    Process1 := TProcess.Create(nil);
    Process1.Executable := 'sh';
    Process1.Parameters.Add('-c');
    Process1.Parameters.Add('notify-send -e -i /usr/share/icons/hicolor/128x128/apps/goverlay.png "MangoHud" "Configuration saved"');
    Process1.Options := [poUsePipes];
    Process1.Execute;
    Process1.WaitOnExit;
    Process1.Free;

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
          LOCATEDFILE := FindAllFiles(FONTFOLDER, fontCombobox.Text);  //Locate specific folder for selected font
          FONTPATH := LOCATEDFILE[0];
          FONTTYPE := 'font_file=' + FONTPATH; //Use the correct path to point the font file
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
             IOSTATS := 'io_stats';
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
      Savecheckbox (distroinfoCheckBox, DISTROINFO2, '"exec=cat $HOME/.config/goverlay/distro"');


      Savecheckbox (distroinfoCheckBox, DISTROINFO3, 'custom_text=-');
      //Savecheckbox (distroinfoCheckBox, DISTROINFO4, '"exec=cat $HOME/.config/goverlay/kernel"');
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
    WriteCheckboxConfig(diskioCheckBox,IOSTATS,MANGOHUDCFGFILE);
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

  BlacklistFile := GetEnvironmentVariable('HOME') + '/.config/goverlay/blacklist.conf';
  MANGOHUDCFGFILE := GetEnvironmentVariable('HOME') + '/.config/MangoHud/MangoHud.conf';

  FileLines := TStringList.Create;
  ConfigLines := TStringList.Create;
  try
    // if blacklist.conf dont exist, create a stock one
    if not FileExists(BlacklistFile) then
    begin
      FileLines.Add('pamac-manager');
      FileLines.Add('lact');
      FileLines.Add('ghb');
      FileLines.Add('bitwig-studio');
      FileLines.Add('ptyxis');
      FileLines.Add('yumex');
      ForceDirectories(ExtractFilePath(BlacklistFile)); // create directory
      FileLines.SaveToFile(BlacklistFile);
    end
    else
      FileLines.LoadFromFile(BlacklistFile);  // load file


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


end; // ########################################      end save button click       ###############################################################################

procedure Tgoverlayform.transpTrackBarChange(Sender: TObject);
begin
  //Display new values and trackbar changes
  alphavalueLabel.Caption:= FormatFloat('#0.0', transpTrackbar.Position/10);
end;





end.

