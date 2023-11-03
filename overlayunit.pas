unit overlayunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  unix, StdCtrls, Spin, ComCtrls, Buttons, ColorBox, ActnList, Menus, aboutunit,
  ATStringProc_HtmlColor, crosshairUnit, customeffectsunit,LCLtype;



type

  { Tgoverlayform }

  Tgoverlayform = class(TForm)
    aboutBitBtn: TBitBtn;
    acteffectsListBox: TListBox;
    addBitBtn: TBitBtn;
    bottomcenterRadioButton: TRadioButton;
    colorthemeLabel: TLabel;
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
    backgroundLabel: TLabel;
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
    cpuGroupBox1: TGroupBox;
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
    fonttypeComboBox: TComboBox;
    fonttypeLabel: TLabel;
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
    gpuavrloadCheckBox1: TCheckBox;
    gpuColorButton1: TColorButton;
    gpudescLabel: TLabel;
    gpufreqCheckBox1: TCheckBox;
    gpuGroupBox1: TGroupBox;
    gpuload1ColorButton1: TColorButton;
    gpuload1ColorButton2: TColorButton;
    gpuload2ColorButton1: TColorButton;
    gpuload2ColorButton2: TColorButton;
    gpuload3ColorButton1: TColorButton;
    gpuload3ColorButton2: TColorButton;
    gpuloadcolorCheckBox1: TCheckBox;
    gpumemfreqCheckBox1: TCheckBox;
    gpumodelCheckBox1: TCheckBox;
    gpunameEdit1: TEdit;
    gpupowerCheckBox1: TCheckBox;
    gputempCheckBox4: TCheckBox;
    gputempCheckBox5: TCheckBox;
    gputempCheckBox6: TCheckBox;
    gputempCheckBox7: TCheckBox;
    gputhrottlingCheckBox1: TCheckBox;
    graphhudBitBtn: TBitBtn;
    borderGroupBox: TGroupBox;
    GroupBox2: TGroupBox;
    hudversionCheckBox: TCheckBox;
    alphavalueLabel: TLabel;
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
    orientationGroupBox: TGroupBox;
    backgroundGroupBox: TGroupBox;
    hidehudCheckBox: TCheckBox;
    horizontalRadioButton: TRadioButton;
    hudbackgroundColorButton: TColorButton;
    hudonoffComboBox: TComboBox;
    hudonoffComboBox1: TComboBox;
    hudtitleEdit: TEdit;
    PaintBox1: TPaintBox;
    fontLabel: TLabel;
    fontsizeTrackBar: TTrackBar;
    topleftRadioButton: TRadioButton;
    topcenterRadioButton: TRadioButton;
    bottomleftRadioButton: TRadioButton;
    middleleftRadioButton: TRadioButton;
    toprightRadioButton: TRadioButton;
    bottomrightRadioButton: TRadioButton;
    middlerightRadioButton: TRadioButton;
    vImage: TImage;
    hImage: TImage;
    squareImage: TImage;
    roundImage: TImage;
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
    huddesignGroupBox: TGroupBox;
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
    roundRadioButton: TRadioButton;
    runsteamBitBtn: TBitBtn;
    runvkbasaltBitBtn: TBitBtn;
    saveBitBtn: TBitBtn;
    sessionCheckBox: TCheckBox;
    showfpslimCheckBox: TCheckBox;
    squareRadioButton: TRadioButton;
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
    verticalRadioButton: TRadioButton;
    fontsGroupBox: TGroupBox;
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
    vramusageCheckBox1: TCheckBox;
    vsyncComboBox: TComboBox;
    vsyncGroupBox: TGroupBox;
    vsyncGroupBox1: TGroupBox;
    vulkanImage: TImage;
    wineCheckBox: TCheckBox;
    wineColorButton: TColorButton;

    procedure fontsizeTrackBarChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
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
  fpslimVAR : string;
  fpslimtoggleVAR : string;
  vulkanvsyncVAR: string;

  //########################################



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



procedure Tgoverlayform.FormCreate(Sender: TObject);

var
Process: TProcess;
AppHandle: THandle;


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

  // Define mangohud config file path
  MANGOHUDCFGFILE:= '$HOME/.config/MangoHud/MangoHud.conf' ;

  // Initial values
  alphavalueLabel.Caption:= FormatFloat('#0.0', transpTrackbar.Position/10);
  fontsizevalueLabel.Caption:=inttostr(fontsizeTrackbar.Position);
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

procedure Tgoverlayform.saveBitBtnClick(Sender: TObject);
var

  ORIENTATION, HUDTITLE, BORDERTYPE, HUDALPHA, HUDCOLOR, FONTSIZE, FONTCOLOR, HUDPOSITION: string;


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


     // HUD Title

      // Only create title entry if title isn't blank and diferent of default title
      if (hudtitleEdit.text <> '') and (hudtitleEdit.text <> 'Title') then
      HUDTITLE:= 'custom_text_center=' + hudtitleEdit.text;

    //Orientation

      if horizontalRadioButton.checked = true then
        ORIENTATION := 'horizontal';

      if verticalRadioButton.checked = true then
        ORIENTATION := '';


      //Borders

      if squareRadioButton.checked = true then
        BORDERTYPE := 'round_corners=0';

      if roundRadioButton.checked = true then
        BORDERTYPE := 'round_corners=10';

       //HUD Alpha (transparency)

      HUDALPHA := 'background_alpha=' + FormatFloat('#0.0', transpTrackbar.Position/10);

       //HUD Color

      HUDCOLOR := 'background_color=' + ColorToHTMLColor(hudbackgroundColorButton.ButtonColor);


       //Font size

      FONTSIZE := 'font_size=' + inttostr(fontsizeTrackbar.Position);

       //Font Color

      FONTCOLOR := 'text_color=' + ColorToHTMLColor(fontColorButton.ButtonColor);

      //Position

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

      //##################################################################################################################  Write config file

      //HUD Title
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + HUDTITLE + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;

      //orientation
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + ORIENTATION + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;


      //Border type
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + BORDERTYPE + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;

      //HUD ALPHA (transparency)
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + HUDALPHA + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;

      //HUD Color
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + HUDCOLOR + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;


      //Font Size
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + FONTSIZE + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;


      //Font Color
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + FONTCOLOR + ' >> ' + MANGOHUDCFGFILE );
      Process1.Options := [poWaitOnExit, poUsePipes];
      Process1.Execute;
      Process1.Free;

      //Position
      Process1 := TProcess.Create(nil);
      Process1.Executable := 'sh';
      Process1.Parameters.Add('-c');
      Process1.Parameters.Add('echo ' + HUDPOSITION + ' >> ' + MANGOHUDCFGFILE );
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

