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
    bottomleftSpeedButton: TSpeedButton;
    bottomrightSpeedButton: TSpeedButton;
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
    fontsizeComboBox: TComboBox;
    fontsizeLabel: TLabel;
    fontsizeLabel1: TLabel;
    fontsizeSpinEdit: TSpinEdit;
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
    vImage: TImage;
    hImage: TImage;
    squareImage: TImage;
    roundImage: TImage;
    intelpowerfixBitBtn1: TBitBtn;
    iordrwColorButton1: TColorButton;
    hudtoggleLabel: TLabel;
    colorthemeLabel: TLabel;
    layoutsGroupBox: TGroupBox;
    mangohudPageControl: TPageControl;
    mangohudPanel: TPanel;
    middleleftSpeedButton: TSpeedButton;
    middlerightSpeedButton: TSpeedButton;
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
    topcenterSpeedButton: TSpeedButton;
    topcenterSpeedButton1: TSpeedButton;
    topleftSpeedButton: TSpeedButton;
    toprightSpeedButton: TSpeedButton;
    transparencyLabel: TLabel;
    transparencyLabel2: TLabel;
    transparencyLabel3: TLabel;
    transpTrackBar: TTrackBar;
    uploadlogComboBox: TComboBox;
    verticalRadioButton: TRadioButton;
    visualGroupBox: TGroupBox;
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

    procedure FormCreate(Sender: TObject);


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
  fpslimVAR : string;
  fpslimtoggleVAR : string;
  vulkanvsyncVAR: string;

  //########################################


implementation

{$R *.lfm}


{ Tgoverlayform }

// Reference to logpathunit so the homepath can be aquired from overlayUnit


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

end;

end.

