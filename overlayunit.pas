unit overlayunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  unix, StdCtrls, Spin, ComCtrls, Buttons, ColorBox, ActnList, Menus, aboutunit,
  ATStringProc_HtmlColor, crosshairUnit, customeffectsunit,LCLtype, FileUtil, Types;



type

  { Tgoverlayform }

  Tgoverlayform = class(TForm)
    aboutBitBtn: TBitBtn;
    acteffectsListBox: TListBox;
    addBitBtn: TBitBtn;
    alphavalueLabel: TLabel;
    backgroundGroupBox: TGroupBox;
    backgroundLabel: TLabel;
    borderGroupBox: TGroupBox;
    bottomcenterRadioButton: TRadioButton;
    colorthemeLabel: TLabel;
    gpudescEdit: TEdit;
    fontComboBox: TComboBox;
    fontcolorLabel: TLabel;
    fontsizevalueLabel: TLabel;
    archCheckBox: TCheckBox;
    autologSpinEdit: TSpinEdit;
    autologSpinEdit1: TSpinEdit;
    autologSpinEdit2: TSpinEdit;
    autologSpinEdit3: TSpinEdit;
    autostartLabel: TLabel;
    autostartLabel2: TLabel;
    autouploadCheckBox: TCheckBox;
    aveffectsListBox: TListBox;
    basaltgeSpeedButton: TSpeedButton;
    basaltGlobalenableLabel: TLabel;
    basaltrunBitBtn: TBitBtn;
    basaltsaveBitBtn: TBitBtn;
    batteryCheckBox: TCheckBox;
    batteryCheckBox1: TCheckBox;
    batteryCheckBox2: TCheckBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    compacthudBitBtn: TBitBtn;
    completehudBitBtn: TBitBtn;
    cpuavrloadCheckBox1: TCheckBox;
    cpuColorButton1: TColorButton;
    cpufreqCheckBox2: TCheckBox;
    cpuGroupBox: TGroupBox;
    cpuload1ColorButton1: TColorButton;
    cpuload2ColorButton1: TColorButton;
    cpuload3ColorButton1: TColorButton;
    cpuloadcolorCheckBox1: TCheckBox;
    cpuloadcoreCheckBox1: TCheckBox;
    cpunameEdit1: TEdit;
    cpupowerCheckBox1: TCheckBox;
    cputempCheckBox1: TCheckBox;
    customcommandEdit: TEdit;
    destfolderpathLabel: TLabel;
    diskioCheckBox1: TCheckBox;
    distroinfoCheckBox: TCheckBox;
    driverversionCheckBox1: TCheckBox;
    engineColorButton: TColorButton;
    engineversionCheckBox: TCheckBox;
    extrasTabSheet: TTabSheet;
    filtersSheet: TTabSheet;
    FontcolorButton: TColorButton;
    C: TComboBox;
    fpsCheckBox: TCheckBox;
    fpsCheckBox1: TCheckBox;
    fpsCheckBox2: TCheckBox;
    fpsCheckBox3: TCheckBox;
    fpslimComboBox: TComboBox;
    fpslimComboBox1: TComboBox;
    fpslimLabel: TLabel;
    fpslimLabel1: TLabel;
    fpslimLabel10: TLabel;
    fpslimLabel11: TLabel;
    fpslimLabel12: TLabel;
    fpslimLabel13: TLabel;
    fpslimLabel14: TLabel;
    fpslimLabel15: TLabel;
    fpslimLabel16: TLabel;
    fpslimLabel17: TLabel;
    fpslimLabel18: TLabel;
    fpslimLabel3: TLabel;
    fpslimLabel4: TLabel;
    fpslimLabel6: TLabel;
    fpslimLabel7: TLabel;
    fpslimLabel8: TLabel;
    fpslimLabel9: TLabel;
    fpslimtoggleComboBox: TComboBox;
    fpsonlyCheckBox: TCheckBox;
    fpsTrackBar: TTrackBar;
    framecountCheckBox: TCheckBox;
    framegraphRadioButton: TRadioButton;
    framehistogramRadioButton: TRadioButton;
    frametimegraphCheckBox: TCheckBox;
    frametimegraphColorButton: TColorButton;
    frametimegraphColorButton1: TColorButton;
    gamemodestatusCheckBox: TCheckBox;
    gamepadCheckBox: TCheckBox;
    geSpeedButton: TSpeedButton;
    GlobalenableLabel: TLabel;
    glvsyncComboBox: TComboBox;
    gpuavgloadCheckBox: TCheckBox;
    gpuColorButton: TColorButton;
    gpufreqCheckBox: TCheckBox;
    gpuGroupBox: TGroupBox;
    gpuload1ColorButton1: TColorButton;
    gpuload1ColorButton2: TColorButton;
    gpuload2ColorButton1: TColorButton;
    gpuload2ColorButton2: TColorButton;
    gpuload3ColorButton1: TColorButton;
    gpuload3ColorButton2: TColorButton;
    gpuloadcolorCheckBox: TCheckBox;
    gpumemfreqCheckBox: TCheckBox;
    gpumodelCheckBox1: TCheckBox;
    gpunameEdit1: TEdit;
    gpupowerCheckBox1: TCheckBox;
    gputempCheckBox: TCheckBox;
    gputempCheckBox5: TCheckBox;
    gputempCheckBox6: TCheckBox;
    gputempCheckBox7: TCheckBox;
    gputhrottlingCheckBox: TCheckBox;
    graphhudBitBtn: TBitBtn;
    GroupBox2: TGroupBox;
    hImage: TImage;
    horizontalRadioButton: TRadioButton;
    hudbackgroundColorButton: TColorButton;
    hudversionCheckBox: TCheckBox;
    Image1: TImage;
    Label5: TLabel;
    Label6: TLabel;
    layoutsGroupBox2: TGroupBox;
    logdurationLabel: TLabel;
    logdurationSpinEdit: TSpinEdit;
    logdurationtLabel3: TLabel;
    loggingComboBox: TComboBox;
    loggingGroupBox: TGroupBox;
    logpathBitBtn: TBitBtn;
    mediaCheckBox: TCheckBox;
    mediaColorButton: TColorButton;
    mediaComboBox: TComboBox;
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
    iordrwColorButton1: TColorButton;
    hudtoggleLabel: TLabel;
    layoutsGroupBox: TGroupBox;
    mangohudPageControl: TPageControl;
    mangohudPanel: TPanel;
    MenuItem4: TMenuItem;
    minimalhudBitBtn: TBitBtn;
    notificationLabel: TLabel;
    openglImage: TImage;
    PageControl2: TPageControl;
    pcidevComboBox: TComboBox;
    performanceGroupBox: TGroupBox;
    performanceTabSheet: TTabSheet;
    positionGroupBox: TGroupBox;
    Process1: TProcess;
    procmemCheckBox1: TCheckBox;
    ramColorButton1: TColorButton;
    ramusageCheckBox1: TCheckBox;
    reshadeLabel1: TLabel;
    reshadeLabel2: TLabel;
    reshadeProgressBar: TProgressBar;
    reshadesyncBitBtn: TBitBtn;
    resolutionCheckBox: TCheckBox;
    roundcornerTrackBar1: TTrackBar;
    roundcornerTrackBar2: TTrackBar;
    roundcornervalueLabel1: TLabel;
    roundcornervalueLabel2: TLabel;
    runsteamBitBtn: TBitBtn;
    runvkbasaltBitBtn: TBitBtn;
    saveBitBtn: TBitBtn;
    sessionCheckBox: TCheckBox;
    showfpslimCheckBox: TCheckBox;
    subBitBtn: TBitBtn;
    swapusageCheckBox1: TCheckBox;
    TabSheet8: TTabSheet;
    themesComboBox: TComboBox;
    timeCheckBox: TCheckBox;
    transparencyLabel: TLabel;
    transparencyLabel2: TLabel;
    transparencyLabel3: TLabel;
    transpTrackBar: TTrackBar;
    uploadlogComboBox: TComboBox;
    fontsGroupBox: TGroupBox;
    verticalRadioButton: TRadioButton;
    vImage: TImage;
    visualTabSheet: TTabSheet;
    vkbasaltPanel: TPanel;
    vkbasaltstatusCheckBox: TCheckBox;
    vkbasaltstatusCheckBox1: TCheckBox;
    vkbasaltstatusCheckBox2: TCheckBox;
    vkbasaltstatusCheckBox3: TCheckBox;
    vkbtogglekeyCombobox: TComboBox;
    vkcubegsMenuItem: TMenuItem;
    vkcubeMenuItem: TMenuItem;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    vkbasaltPopupMenu: TPopupMenu;
    steamMenuItem: TMenuItem;
    gamePopupMenu: TPopupMenu;
    iconsImageList: TImageList;
    positionImageList: TImageList;
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
    vramColorButton1: TColorButton;
    vramusageCheckBox: TCheckBox;
    vsyncComboBox: TComboBox;
    vsyncGroupBox: TGroupBox;
    vsyncGroupBox1: TGroupBox;
    vulkanImage: TImage;
    wineCheckBox: TCheckBox;
    wineColorButton: TColorButton;

    procedure fontsizeTrackBarChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure pcidevComboBoxChange(Sender: TObject);
    procedure saveBitBtnClick(Sender: TObject);
    procedure transpTrackBarChange(Sender: TObject);


  public


  end;

var
  goverlayform: Tgoverlayform;

  s: string;
  Color: string;

  //Boolean variables
  mangohudsel: boolean;
  vkbasaltsel: boolean;

  //Mangohud variables ##########################
  MANGOHUDCFGFILE: string;
  FONTFOLDER: string;
  fpslimVAR : string;
  fpslimtoggleVAR : string;
  vulkanvsyncVAR: string;


  //########################################
  GPUNUMBER: integer;
  GPUDESC: TStringList;

implementation

{$R *.lfm}


{ Tgoverlayform }


//Function to convert color codes to #RRGGBB format
function ColorToHTMLColor(const AColor: TColor): string;
var
  Red, Green, Blue: Byte;
begin
  Red := Byte(AColor); // Extrai o componente vermelho
  Green := Byte(AColor shr 8); // Extrai o componente verde
  Blue := Byte(AColor shr 16); // Extrai o componente azul

  Result := Format('%.2x%.2x%.2x', [Red, Green, Blue]); // Formata a string no formato HTML (#RRGGBB)
end;



//Function to find font files (*.ttf) in /usr/share/fonts
procedure ListarFontesNoDiretorio(Diretorio: string; ComboBox: TComboBox);
var
  Arquivos: TStringList;
  Arquivo: String;
begin
  //ComboBox.Clear; // Limpa o ComboBox antes de preenchê-lo

  Arquivos := FindAllFiles(Diretorio, '*.ttf'); // Procura por arquivos TTF no diretório

  try
    for Arquivo in Arquivos do
    begin
      ComboBox.Items.Add(ExtractFileName(Arquivo)); // Adiciona o nome do arquivo ao ComboBox
    end;
  finally
    Arquivos.Free; // Libera a memória alocada para a lista de arquivos
  end;
end;



procedure Tgoverlayform.FormCreate(Sender: TObject);

var
Process: TProcess;
AppHandle: THandle;
saida: TStringList;
i: integer;

begin
  //Centralize window
  Left:=(Screen.Width-Width)  div 2;
  Top:=(Screen.Height-Height) div 2;

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
  MANGOHUDCFGFILE:= '$HOME/.config/MangoHud/MangoHud.conf' ;
  FONTFOLDER := '/usr/share/fonts/TTF/';

  //Load avaiable text fonts in /usr/share/fonts
  ListarFontesNoDiretorio('/usr/share/fonts/TTF/', fontComboBox);

  //Detect system GPUs

  // Count the number of detected GPUs
    Process1 := TProcess.Create(nil);
    saida := TStringList.Create;

    Process1.Executable := 'sh';
    Process1.Parameters.Add('-c');
    Process1.Parameters.Add('lspci | grep -i "VGA\|video" | wc -l'); //Count the number of lines
    Process1.Options := [poUsePipes];
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
      Process1.Execute;

      saida.LoadFromStream(Process1.output);
      GPUDESC.Add(saida[0]);
      Process1.Free;
      saida.Free;

      i := i + 1; //increment "i"variable
    end; //while


  // Initial values
  alphavalueLabel.Caption:= FormatFloat('#0.0', transpTrackbar.Position/10);
  fontsizevalueLabel.Caption:=inttostr(fontsizeTrackbar.Position);
  fontcombobox.ItemIndex:=0;

end;

procedure Tgoverlayform.fontsizeTrackBarChange(Sender: TObject);
begin
  //Display new values and trackbar changes
  fontsizevalueLabel.Caption:= inttostr(fontsizeTrackbar.Position);
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


procedure Tgoverlayform.saveBitBtnClick(Sender: TObject);
var

  ORIENTATION, HUDTITLE, BORDERTYPE, HUDALPHA, HUDCOLOR, FONTTYPE, FONTPATH, FONTSIZE, FONTCOLOR, HUDPOSITION, TOGGLEHUD, HIDEHUD, PCIDEV: string; //visualtab
  GPUAVGLOAD, GPULOADCOLOR , GPULOADVALUE, VRAM, GPUFREQ: string;  //metrics tab
  LOCATEDFILE: TStringList;

  begin

  //Create directories
  RunCommand('bash -c ''mkdir -p $HOME/.config/MangoHud/''', s);


  // Delete old files if it exists
  RunCommand('bash -c ''rm $HOME/.config/MangoHud/MangoHud.conf''', s);
  RunCommand('bash -c ''rm $HOME/.config/goverlay/pcidev_save''', s);

  // Create a new file for GOverlay
  RunCommand('bash -c ''echo "################### File Generated by Goverlay ###################" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
  RunCommand('bash -c ''echo "legacy_layout=false" >> $HOME/.config/MangoHud/MangoHud.conf''', s);


  // Popup a notification
  RunCommand('bash -c ''notify-send -e -i /usr/share/icons/hicolor/128x128/apps/goverlay.png "MangoHud" "Configuration saved"''', s); //
  notificationlabel.Visible:=true;


    //###############################################################################################    VISUAL TAB


     // HUD Title - Config Variable

      // Only create title entry if title isn't blank and diferent of default title
      if (hudtitleEdit.text <> '') and (hudtitleEdit.text <> 'Title') then
      HUDTITLE:= 'custom_text_center=' + hudtitleEdit.text;

      //Orientation  - Config Variable

      if horizontalRadioButton.checked = true then
        ORIENTATION := 'horizontal';

      if verticalRadioButton.checked = true then
        ORIENTATION := '';


      //Borders - Config Variable

      if squareRadioButton.checked = true then
        BORDERTYPE := 'round_corners=0';

      if roundRadioButton.checked = true then
        BORDERTYPE := 'round_corners=10';

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

      if topleftRadioButton.checked = true then
        HUDPOSITION := 'position=top-left';

      if toprightRadioButton.checked = true then
        HUDPOSITION := 'position=top-right';

      if topcenterRadioButton.checked = true then
        HUDPOSITION := 'position=top-center';

      if bottomcenterRadioButton.checked = true then
        HUDPOSITION := 'position=bottom-center';

      if bottomleftRadioButton.checked = true then
        HUDPOSITION := 'position=bottom-left';

      if bottomrightRadioButton.checked = true then
        HUDPOSITION := 'position=bottom-right';

      if middleleftRadioButton.checked = true then
        HUDPOSITION := 'position=middle-left';

      if middlerightRadioButton.checked = true then
        HUDPOSITION := 'position=middle-right';


      //HUD Toggle ON/OFF   - Config Variable

      case hudonoffCombobox.ItemIndex of
        0:TOGGLEHUD := 'toggle_hud=Shift_R+F12' ;
        1:TOGGLEHUD := 'toggle_hud=Shift_R+F1' ;
        2:TOGGLEHUD := 'toggle_hud=Shift_R+F2' ;
        3:TOGGLEHUD := 'toggle_hud=Shift_R+F3' ;
        4:TOGGLEHUD := 'toggle_hud=Shift_R+F4' ;
        end;

      //Hide HUD by default  - Config Variable

      if hidehudCheckbox.checked = true then
         HIDEHUD := 'no_display';

      //GPU PCIDEV  - Config Variable

      if pcidevCombobox.ItemIndex <> -1 then  // Does not create pci_dev line if no GPU is selected
        PCIDEV := 'pci_dev=0:' + pcidevCombobox.Items[pcidevCombobox.ItemIndex] ;



      //###############################################################################################   METRICS TAB

      //GPU
        //AVG Load  - Config Variable
        if gpuavgloadCheckbox.checked = true then
          GPUAVGLOAD := 'gpu_stats';

        //AVG Load color  - Config Variable
        if gpuloadcolorCheckbox.checked = true then
          begin
             GPULOADCOLOR := 'gpu_load_change';
             GPULOADVALUE := 'gpu_load_value=50,90';
          end;

        //VRAM  - Config Variable
        if vramusageCheckbox.checked = true then
          VRAM := 'vram';

        //Core freq  - Config Variable
        if gpufreqCheckbox.checked = true then
          GPUFREQ := 'gpu_core_clock';

      //##################################################################################################################  Write config file


      //HUD Title - Write Config
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + HUDTITLE + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;

      //orientation - Write Config
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + ORIENTATION + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;


      //Border type - Write Config
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + BORDERTYPE + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;

      //HUD ALPHA (transparency) - Write Config
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + HUDALPHA + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;

      //HUD Color - Write Config
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + HUDCOLOR + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;


      //Font Type - Write Config

      if fontcomboBox.ItemIndex <> 0  then    //It doesnt apply for the DEFAULT font
      begin
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + FONTTYPE + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;
      end;

      //Font Size  - Write Config
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + FONTSIZE + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;


      //Font Color - Write Config
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + FONTCOLOR + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;

      //HUD Position  - Write Config
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + HUDPOSITION + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;

      //TOGGLE HUD - Write Config
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + TOGGLEHUD + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;

      //TOGGLE HUD - Write Config
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + HIDEHUD + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;

      //GPU PCIDEV  - Write Config
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + PCIDEV + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;



        //###############################################################################################   METRICS TAB

      //GPU AVG LOAD  - Write Config
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + GPUAVGLOAD + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;

      //GPU LOAD COLOR  - Write Config
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + GPULOADCOLOR + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;

      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + GPULOADVALUE + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;


      //VRAM  - Write Config
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + VRAM + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;

      //GPU CORE FREQ  - Write Config
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + GPUFREQ + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;

end; // ########################################      end save button click       ###############################################################################

procedure Tgoverlayform.transpTrackBarChange(Sender: TObject);
begin
  //Display new values and trackbar changes
  alphavalueLabel.Caption:= FormatFloat('#0.0', transpTrackbar.Position/10);
end;





end.

