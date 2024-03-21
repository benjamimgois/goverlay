unit overlayunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  unix, StdCtrls, Spin, ComCtrls, Buttons, ColorBox, ActnList, Menus, aboutunit,
  ATStringProc_HtmlColor, crosshairUnit, customeffectsunit,LCLtype, FileUtil, StrUtils,Types;



type

  { Tgoverlayform }

  Tgoverlayform = class(TForm)
    aboutBitBtn: TBitBtn;
    acteffectsListBox: TListBox;
    addBitBtn: TBitBtn;
    alphavalueLabel: TLabel;
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
    colorthemeLabel: TLabel;
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
    intelpowerfixBitBtn1: TBitBtn;
    iordrwColorButton: TColorButton;
    hudtoggleLabel: TLabel;
    mangohudPageControl: TPageControl;
    mangohudPanel: TPanel;
    MenuItem4: TMenuItem;
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
    runsteamBitBtn: TBitBtn;
    runvkbasaltBitBtn: TBitBtn;
    saveBitBtn: TBitBtn;
    sessionCheckBox: TCheckBox;
    subBitBtn: TBitBtn;
    swapusageCheckBox: TCheckBox;
    TabSheet8: TTabSheet;
    themesComboBox: TComboBox;
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
    vkcubegsMenuItem: TMenuItem;
    vkcubeMenuItem: TMenuItem;
    steamMenuItem: TMenuItem;
    gamePopupMenu: TPopupMenu;
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

    procedure aboutBitBtnClick(Sender: TObject);
    procedure afTrackBarChange(Sender: TObject);
    procedure delayTrackBarChange(Sender: TObject);
    procedure durationTrackBarChange(Sender: TObject);
    procedure intervalTrackBarChange(Sender: TObject);
    procedure logfolderBitBtnClick(Sender: TObject);
    procedure coreloadtypeBitBtnClick(Sender: TObject);
    procedure fontsizeTrackBarChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure frametimetypeBitBtnClick(Sender: TObject);
    procedure geSpeedButtonClick(Sender: TObject);
    procedure minusButtonClick(Sender: TObject);
    procedure mipmapTrackBarChange(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure pcidevComboBoxChange(Sender: TObject);
    procedure plusSpeedButtonClick(Sender: TObject);
    procedure saveBitBtnClick(Sender: TObject);
    procedure transpTrackBarChange(Sender: TObject);


  public


  end;

var
  goverlayform: Tgoverlayform;

  s: string;
  Color: string;

  ORIENTATION, HUDTITLE, BORDERTYPE, HUDALPHA, HUDCOLOR, FONTTYPE, FONTPATH, FONTSIZE, FONTCOLOR, HUDPOSITION, TOGGLEHUD, HIDEHUD, PCIDEV, TABLECOLUMNS: string; //visualtab
GPUAVGLOAD, GPULOADCHANGE, GPULOADCOLOR , GPULOADVALUE, VRAM, VRAMCOLOR, GPUFREQ, GPUMEMFREQ, GPUTEMP, GPUMEMTEMP, GPUJUNCTEMP, GPUFAN, GPUPOWER, GPUTHR, GPUTHRG, GPUMODEL, VULKANDRIVER, GPUVOLTAGE: string;  //metrics tab - GPU
CPUAVGLOAD, CPULOADCORE, CPULOADCHANGE, CPULOADCOLOR, CPULOADVALUE, CPUCOREFREQ, CPUTEMP, CORELOADTYPE, CPUPOWER, GPUTEXT, CPUTEXT, RAM, RAMCOLOR, IOSTATS, IOREAD, IOWRITE, SWAP, PROCMEM: string; //metrics tab - CPU
FPS, FRAMETIMING, SHOWFPSLIM, FRAMECOUNT, FRAMETIMEC, HISTOGRAM, FPSLIM, FPSLIMMET, FPSCOLOR, FPSVALUE, FPSCHANGE, VSYNC, GLVSYNC, FILTER, AFFILTER, MIPMAPFILTER, FPSLIMTOGGLE: string; //performance tab
DISTROINFO1, DISTROINFO2, DISTROINFO3, DISTROINFO4, DISTRONAME, ARCH, RESOLUTION, SESSION, SESSIONTXT, TIME, WINE, WINECOLOR, ENGINE, ENGINECOLOR, ENGINESHORT, HUDVERSION,GAMEMODE: string; //extra tab
VKBASALT, FCAT, FSR, HDR, REFRESHRATE, BATTERY, BATTERYCOLOR, BATTERYWATT, BATTERYTIME, DEVICE, MEDIA, MEDIACOLOR, CUSTOMCMD1, CUSTOMCMD2, LOGFOLDER, LOGDURATION, LOGDELAY, LOGINTERVAL, LOGTOGGLE, LOGVER, LOGAUTO: string; //extratab


  //Boolean variables
  mangohudsel: boolean;
  vkbasaltsel: boolean;

  //Mangohud variables ##########################
  AUX, AUX2, MANGOHUDCFGFILE, MANGOHUDFOLDER, FONTFOLDER, HOMEPATH, USERHOME: string;

  //########################################
  i, GPUNUMBER, COLUMNS: integer;
  GPUDESC: TStringList;

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
saida: TStringList;
i: integer;
Output: TStringList;



begin
  //Centralize window
  Left:=(Screen.Width-Width)  div 2;
  Top:=(Screen.Height-Height) div 2;

  mangohudPageControl.ActivePage:=visualTabsheet; //Set initial TAB

   // Initialize menu selections
  mangohudsel := true;
  mangohudPanel.Visible:=true;
  vkbasaltsel := false;
  vkbasaltPanel.Visible:=false;

  // Start vkcube (vulkan demo)
  Process := TProcess.Create(nil);
  Process.Executable := 'sh';
  Process.Parameters.Add('-c');
  Process.Parameters.Add('mangohud vkcube');
  Process.Options := [poUsePipes];
  Process.Execute;

  // Define important file paths
  MANGOHUDFOLDER:= '$HOME/.config/MangoHud/' ;
  MANGOHUDCFGFILE:= '$HOME/.config/MangoHud/MangoHud.conf' ;
  FONTFOLDER := '/usr/share/fonts/';
  USERHOME :=  GetEnvironmentVariable('HOME') ;

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
    if LoadValue('fps_limit',AUX) then
      begin
      LoadCheckgroup(fpslimCheckGroup, '240, 120, 30');





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


    //toggle fps limit
    if LoadValue('toggle_fps_limit',AUX) then
      begin
        case AUX of
          'Shift_L+F1': fpslimtoggleCombobox.ItemIndex:=0;
          'Shift_L+F2': fpslimtoggleCombobox.ItemIndex:=1;
          'Shift_L+F3': fpslimtoggleCombobox.ItemIndex:=2;
          'Shift_L+F4': fpslimtoggleCombobox.ItemIndex:=3;
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
        end; //case

      end; //if

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
    if LoadName('lsb_release -a | grep Release | uniq | cut -c 10-26') then
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
    if LoadName('time') then
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
    if LoadName('engine') then
      engineversioncheckbox.Checked := True
    else
      engineversioncheckbox.Checked := false;


    // engine short
    if LoadName('engine_short_names') then
      engineshortcheckbox.Checked := True
    else
      engineshortcheckbox.Checked := false;



    // hud version
    if LoadName('version') then
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

    // battery time
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






    end;
    end;









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

       //RunCommand('bash -c ''echo "MANGOHUD=1" | pkexec tee -a /etc/environment''', s);  // Activate MANGOHUD globally for vulkan apps
       //RunCommand('bash -c ''notify-send -e -i /usr/share/icons/hicolor/128x128/apps/goverlay.png "VULKAN Global Enable Activated" "Every Vulkan application will have Mangohud Enabled now"''', s); // Popup a notification

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
       //RunCommand('bash -c ''pkexec sed -i -e "/MANGOHUD=1/d" /etc/environment''', s); // Remove lines containing MANGOHUD=1 from /etc/environment
       //RunCommand('bash -c ''notify-send -e -i /usr/share/icons/hicolor/128x128/apps/goverlay.png "Deactivated"''', s); // Popup a notification

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

procedure Tgoverlayform.afTrackBarChange(Sender: TObject);
begin
  //Display new values and trackbar changes
  afvalueLabel.Caption:= FormatFloat('#0', afTrackbar.Position);
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


procedure Tgoverlayform.saveBitBtnClick(Sender: TObject);
var


  ValorItem: string;
  LOCATEDFILE, FPSSEL: TStringList;
  i: integer;
  NOITEMCHECK: boolean;

  Process: TProcess;
  Output: TStringList;

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
        end;

      //Hide HUD by default  - Config Variable
      Savecheckbox (hidehudCheckbox, HIDEHUD, 'no_display');

      //GPU PCIDEV  - Config Variable

      if pcidevCombobox.ItemIndex <> -1 then  // Does not create pci_dev line if no GPU is selected
        PCIDEV := 'pci_dev=0:' + pcidevCombobox.Items[pcidevCombobox.ItemIndex] ;


      // Table Columns - - Config Variable
      COLUMNS :=  strtoint(columvalueLabel.Caption);
      TABLECOLUMNS := 'table_columns=' + inttostr(COLUMNS);


      //###############################################################################################   METRICS TAB

      //GPU
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

        ////RAM - Config Variable
       Savecheckbox (fpsCheckBox, FPS, 'fps');

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
            FPSSEL.Add(ValorItem);
            NOITEMCHECK := false; // Variable is become false
          end;
          end;

          if NOITEMCHECK = true then
             FPSLIM := 'fps_limit=0' //If no item is check fps_limit is unlimited
          else
              FPSLIM := 'fps_limit=' + FPSSEL.CommaText;
              FPSSEL.Free;




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

      AFFILTER := 'af=' + FormatFloat('#0', afTrackbar.Position);


       //MIPMAP Filter   - Config Variable

      MIPMAPFILTER := 'picmip=' + FormatFloat('#0', mipmapTrackbar.Position);


      //###############################################################################################   Extra TAB

      // Distro info - Config Variable
      Process := TProcess.Create(nil);
      Output := TStringList.Create;

      Process.Executable := '/bin/bash';
      Process.Parameters.Add('-c');
      Process.Parameters.Add('cat /usr/lib/os-release');

      Process.Options := [poUsePipes];
      Process.Execute;

      Output.LoadFromStream(Process.Output);
      DISTRONAME := Output.Values['NAME'];

      Savecheckbox (distroinfoCheckBox, DISTROINFO1, 'custom_text=' + DISTRONAME);
      Savecheckbox (distroinfoCheckBox, DISTROINFO2, '"exec=lsb_release -a | grep Release | uniq | cut -c 10-26"');


      Savecheckbox (distroinfoCheckBox, DISTROINFO3, 'custom_text=Kernel');
      Savecheckbox (distroinfoCheckBox, DISTROINFO4, '"exec=uname -r"');


      // Arch - Config Variable
      Savecheckbox (archCheckBox, ARCH, 'arch');

      // Resolution - Config Variable
      Savecheckbox (resolutionCheckBox, RESOLUTION, 'resolution');

      // Session - Config Variable
      Savecheckbox (sessionCheckBox, SESSIONTXT, 'custom_text=Session:');
      Savecheckbox (sessionCheckBox, SESSION, '"exec=echo \$XDG_SESSION_TYPE"');

      // Time - Config Variable
      Savecheckbox (timeCheckBox, TIME, 'time');

      // Wine - Config Variable
      Savecheckbox (wineCheckBox, WINE, 'wine');

      //Wine Color  - Config Variable

      WINECOLOR := 'wine_color=' + ColorToHTMLColor(wineColorButton.ButtonColor);


      // Engine - Config Variable
      Savecheckbox (engineversionCheckBox, ENGINE, 'engine');

      //Engine Color  - Config Variable

      ENGINECOLOR := 'engine_color=' + ColorToHTMLColor(engineColorButton.ButtonColor);


       //Engine Short  - Config Variable

      Savecheckbox (engineshortCheckBox, ENGINESHORT, 'engine_short_names');

       //HUD Version  - Config Variable

      Savecheckbox (hudversionCheckBox, HUDVERSION, 'version');

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

      //Battery time - Config Variable

      Savecheckbox (deviceCheckBox, DEVICE, 'device_battery');

      //Media player - Config Variable

      Savecheckbox (mediaCheckBox, MEDIA, 'media_player');

      //Media player Color  - Config Variable

      MEDIACOLOR := 'media_player_color=' + ColorToHTMLColor(mediaColorButton.ButtonColor);

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




    //Metrics - IO/ SWAP / VRAM / RAM
    WriteCheckboxConfig(diskioCheckBox,IOSTATS,MANGOHUDCFGFILE);
    WriteCheckboxConfig(diskioCheckBox,IOREAD,MANGOHUDCFGFILE);
    WriteCheckboxConfig(diskioCheckBox,IOWRITE,MANGOHUDCFGFILE);
    WriteCheckboxConfig(swapusageCheckBox,SWAP,MANGOHUDCFGFILE);

    WriteCheckboxConfig(vramusageCheckBox,VRAM,MANGOHUDCFGFILE);
    WriteCheckboxConfig(vramusageCheckBox,VRAMCOLOR,MANGOHUDCFGFILE);

    WriteCheckboxConfig(ramusageCheckBox,RAM,MANGOHUDCFGFILE);
    WriteCheckboxConfig(ramusageCheckBox,RAMCOLOR,MANGOHUDCFGFILE);

    // Metrocs - FPS / Engine / GPU model / Vulkan driver / Arch / Wine
    WriteCheckboxConfig(procmemCheckBox,PROCMEM,MANGOHUDCFGFILE);
    WriteCheckboxConfig(fpsCheckBox,FPS,MANGOHUDCFGFILE);

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
    WriteCheckboxConfig(sessionCheckBox,SESSIONTXT,MANGOHUDCFGFILE);
    WriteCheckboxConfig(sessionCheckBox,SESSION,MANGOHUDCFGFILE);
    WriteCheckboxConfig(resolutionCheckBox,RESOLUTION,MANGOHUDCFGFILE);
    WriteCheckboxConfig(fcatCheckBox,FCAT,MANGOHUDCFGFILE);
    WriteCheckboxConfig(fsrCheckBox,FSR,MANGOHUDCFGFILE);
    WriteCheckboxConfig(hdrCheckBox,HDR,MANGOHUDCFGFILE);
    WriteCheckboxConfig(refreshrateCheckBox,REFRESHRATE,MANGOHUDCFGFILE);
    WriteCheckboxConfig(gamemodestatusCheckBox,GAMEMODE,MANGOHUDCFGFILE);
    WriteCheckboxConfig(vkbasaltstatusCheckBox,VKBASALT,MANGOHUDCFGFILE);


    WriteCheckboxConfig(batteryCheckBox,BATTERY,MANGOHUDCFGFILE);
    WriteCheckboxConfig(batteryCheckBox,BATTERYCOLOR,MANGOHUDCFGFILE);

    WriteCheckboxConfig(batterywattCheckBox,BATTERYWATT,MANGOHUDCFGFILE);
    WriteCheckboxConfig(batterytimeCheckBox,BATTERYTIME,MANGOHUDCFGFILE);
    WriteCheckboxConfig(deviceCheckBox,DEVICE,MANGOHUDCFGFILE);
    WriteCheckboxConfig(distroinfoCheckBox,DISTROINFO1,MANGOHUDCFGFILE);
    WriteCheckboxConfig(distroinfoCheckBox,DISTROINFO2,MANGOHUDCFGFILE);
    WriteCheckboxConfig(distroinfoCheckBox,DISTROINFO3,MANGOHUDCFGFILE);
    WriteCheckboxConfig(distroinfoCheckBox,DISTROINFO4,MANGOHUDCFGFILE);

    WriteCheckboxConfig(fpscolorCheckBox,FPSCHANGE ,MANGOHUDCFGFILE);
    WriteCheckboxConfig(fpscolorCheckBox,FPSCOLOR ,MANGOHUDCFGFILE);
    WriteCheckboxConfig(fpscolorCheckBox,FPSVALUE ,MANGOHUDCFGFILE);

    WriteConfig(VSYNC ,MANGOHUDCFGFILE);
    WriteConfig(GLVSYNC ,MANGOHUDCFGFILE);
    WriteConfig(FILTER,MANGOHUDCFGFILE);
    WriteConfig(AFFILTER ,MANGOHUDCFGFILE);
    WriteConfig(MIPMAPFILTER ,MANGOHUDCFGFILE);

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

end; // ########################################      end save button click       ###############################################################################

procedure Tgoverlayform.transpTrackBarChange(Sender: TObject);
begin
  //Display new values and trackbar changes
  alphavalueLabel.Caption:= FormatFloat('#0.0', transpTrackbar.Position/10);
end;





end.

