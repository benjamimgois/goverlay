unit overlayunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, Forms, Controls, Graphics, Dialogs, ExtCtrls, Math,
  unix, BaseUnix, StdCtrls, Spin, ComCtrls, Buttons, ColorBox, ActnList, Menus, aboutunit, optiscaler_update, protontricksunit,
  ATStringProc_HtmlColor, blacklistUnit, customeffectsunit, LCLtype, CheckLst,Clipbrd, LCLIntf,
  FileUtil, StrUtils, gfxlaunch, Types,fpjson, jsonparser, git2pas, howto, themeunit, systemdetector, constants,
  fgmod_resources, hintsunit, qtwidgets;



type

  { Tgoverlayform }

  Tgoverlayform = class(TForm)
    acteffectsListBox: TListBox;
    activegpuLabel: TLabel;
    actprotonlogsCheckBox: TCheckBox;
    osversionLabel: TLabel;
    offsetySpinEdit: TSpinEdit;
    patcherlistLabel: TLabel;
    protontricksManagerButton: TBitBtn;
    optipatcherLabel: TLabel;
    optipatcherLabel1: TLabel;
    saveasMenuItem: TMenuItem;
    optipatcherCheckBox: TCheckBox;
    offsetxSpinEdit: TSpinEdit;
    stagememCheckBox: TCheckBox;
    addBitBtn: TBitBtn;
    afLabel: TLabel;
    afterburnercolorBitBtn1: TBitBtn;
    afterburnercolorLabel: TLabel;
    afTrackBar: TTrackBar;
    afvalueLabel: TLabel;
    alphavalueLabel: TLabel;
    archCheckBox: TCheckBox;
    autodetectmesaLabel: TLabel;
    autodetectnvLabel: TLabel;
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
    borderGroupBox: TGroupBox;
    bottomcenterRadioButton: TRadioButton;
    bottomleftRadioButton: TRadioButton;
    bottomrightRadioButton: TRadioButton;
    builtineffectsGroupBox: TGroupBox;
    casLabel: TLabel;
    casTrackBar: TTrackBar;
    casvalueLabel: TLabel;
    commandEdit: TEdit;
    emurtCheckBox: TCheckBox;
    enhdrCheckBox: TCheckBox;
    largeaddressCheckBox: TCheckBox;
    enwaylandCheckBox: TCheckBox;
    disablentsyncCheckBox: TCheckBox;
    fexstatsCheckBox: TCheckBox;
    forcenvapiCheckBox: TCheckBox;
    forcezinkCheckBox: TCheckBox;
    gamemodeCheckBox: TCheckBox;
    statusBar: TStatusBar;
    wow64CheckBox: TCheckBox;
    generalGroupBox: TGroupBox;
    performanceGroupBox: TGroupBox;
    graphicsGroupBox: TGroupBox;
    hidenvidiaCheckBox: TCheckBox;
    nofastclearsCheckBox: TCheckBox;
    ramtempCheckBox: TCheckBox;
    customenvEdit: TEdit;
    advancedGroupBox: TGroupBox;
    simdeckCheckBox: TCheckBox;
    highpriCheckBox: TCheckBox;
    tweaksImage: TImage;
    tweaksText: TStaticText;
    tweaksLabel: TLabel;
    tweaksShape: TShape;
    checkupdBitBtn: TBitBtn;
    colorthemeLabel: TLabel;
    columsGroupBox: TGroupBox;
    columShape: TShape;
    columShape1: TShape;
    columShape2: TShape;
    columShape3: TShape;
    columShape4: TShape;
    columShape5: TShape;
    columvalueLabel: TLabel;
    copyBitBtn: TBitBtn;
    coreloadtypeBitBtn: TBitBtn;
    cpuavgloadCheckBox: TCheckBox;
    cpuColorButton: TColorButton;
    cpucoretypeCheckBox: TCheckBox;
    cpuefficiencyCheckBox: TCheckBox;
    cpuframesjouleBitBtn: TBitBtn;
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
    displayserverCheckBox: TCheckBox;
    distroinfoCheckBox: TCheckBox;
    dlsLabel: TLabel;
    dlsTrackBar: TTrackBar;
    dlsvalueLabel: TLabel;
    durationTrackBar: TTrackBar;
    durationvalueLabel: TLabel;
    dxapiCheckBox: TCheckBox;
    emufp8CheckBox: TCheckBox;
    engineColorButton: TColorButton;
    engineshortCheckBox: TCheckBox;
    engineversionCheckBox: TCheckBox;
    extrasTabSheet: TTabSheet;
    fahrenheitCheckBox: TCheckBox;
    fakenvapi1: TLabel;
    fakenvapi2: TLabel;
    fakenvapiGroupBox: TGroupBox;
    fakenvapiLabel: TLabel;
    fcatCheckBox: TCheckBox;
    filenameComboBox: TComboBox;
    filenameLabel: TLabel;
    filterRadioGroup: TRadioGroup;
    filtersGroupBox: TGroupBox;
    FontcolorButton: TColorButton;
    fontcolorLabel: TLabel;
    fontComboBox: TComboBox;
    fontLabel: TLabel;
    fontsGroupBox: TGroupBox;
    fontsizeTrackBar: TTrackBar;
    fontsizevalueLabel: TLabel;
    forcelatencyflexCheckBox: TCheckBox;
    forcereflexCheckBox: TCheckBox;
    fpsavgBitBtn: TBitBtn;
    fpsavgCheckBox: TCheckBox;
    fpsCheckBox: TCheckBox;
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
    fsrLabel: TLabel;
    fsrLabel1: TLabel;
    fsrversionComboBox: TComboBox;
    fsrversionLabel: TLabel;
    ftraceCheckBox: TCheckBox;
    fullBitBtn: TBitBtn;
    fullLabel: TLabel;
    fxaaLabel: TLabel;
    fxaaTrackBar: TTrackBar;
    fxaavalueLabel: TLabel;
    gamemodestatusCheckBox: TCheckBox;
    geLabel: TLabel;
    geSpeedButton: TSpeedButton;
    glvsyncComboBox: TComboBox;
    goverlaybarPanel: TPanel;
    goverlayBitBtn: TBitBtn;
    goverlayPageControl: TPageControl;
    goverlayPanel: TPanel;
    gpuavgloadCheckBox: TCheckBox;
    gpuColorButton: TColorButton;
    gpudescEdit: TEdit;
    gpudriverGroupBox: TGroupBox;
    gpuefficiencyCheckBox: TCheckBox;
    gpufanCheckBox: TCheckBox;
    gpuframesjouleBitBtn: TBitBtn;
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
    gpupowerlimitCheckBox: TCheckBox;
    gputempCheckBox: TCheckBox;
    gputempLabel: TLabel;
    gputhrottlingCheckBox: TCheckBox;
    gputhrottlinggraphCheckBox: TCheckBox;
    gpuvoltageCheckBox: TCheckBox;
    basicGroupBox: TGroupBox;
    imgmenuGroupBox: TGroupBox;
    gupdateBitBtn: TBitBtn;
    donateMenuItem: TMenuItem;
    aboutMenuItem: TMenuItem;
    blacklistMenuItem: TMenuItem;
    globalenableMenuItem: TMenuItem;
    hdrCheckBox: TCheckBox;
    hidehudCheckBox: TCheckBox;
    hImage: TImage;
    horizontalRadioButton: TRadioButton;
    howtoBitBtn: TBitBtn;
    hudbackgroundColorButton: TColorButton;
    hudcompactCheckBox: TCheckBox;
    hudonoffComboBox: TComboBox;
    hudtitleEdit: TEdit;
    hudtoggleImage: TImage;
    hudtoggleLabel: TLabel;
    hudversionCheckBox: TCheckBox;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    intelpowerfixBitBtn: TBitBtn;
    intervalTrackBar: TTrackBar;
    intervalvalueLabel: TLabel;
    iordrwColorButton: TColorButton;
    mark1Label: TLabel;
    mark2Label: TLabel;
    latencyflexComboBox: TComboBox;
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
    mangocolorBitBtn: TBitBtn;
    mangocolorLabel: TLabel;
    mark3Label: TLabel;
    mediaCheckBox: TCheckBox;
    mediaColorButton: TColorButton;
    memLabel: TLabel;
    menuLabel: TLabel;
    menuscaleTrackBar: TTrackBar;
    menuscalevalueLabel: TLabel;
    mesaImage: TImage;
    mesaRadioButton: TRadioButton;
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
    nvidiaImage: TImage;
    nvidiaRadioButton: TRadioButton;
    offsetLabel: TLabel;
    offsetSpinEdit: TSpinEdit;
    openglImage: TImage;
    optionsGroupBox: TGroupBox;
    optionsLabel: TLabel;
    optiscalerGroupBox: TGroupBox;
    optiscalerTabSheet: TTabSheet;
    optLabel: TLabel;
    optLabel1: TLabel;
    optLabel2: TLabel;
    optversionComboBox: TComboBox;
    orientationGroupBox: TGroupBox;
    othersLabel: TLabel;
    overrideCheckBox: TCheckBox;
    pbarLabel: TLabel;
    pcidevComboBox: TComboBox;
    performanceTabSheet: TTabSheet;
    plusSpeedButton: TSpeedButton;
    popupBitBtn: TBitBtn;
    positionGroupBox: TGroupBox;
    presetTabSheet: TTabSheet;
    procmemCheckBox: TCheckBox;
    procvramCheckBox: TCheckBox;
    ramColorButton: TColorButton;
    ramusageCheckBox: TCheckBox;
    reflexComboBox: TComboBox;
    refreshrateCheckBox: TCheckBox;
    reshadeGroupBox: TGroupBox;
    reshadeLabel1: TLabel;
    reshadeLabel2: TLabel;
    reshaderefreshBitBtn: TBitBtn;
    resolutionCheckBox: TCheckBox;
    roundImage: TImage;
    roundRadioButton: TRadioButton;
    saveBitBtn: TBitBtn;
    searchEdit: TEdit;
    savecustomMenuItem: TMenuItem;
    deckpreset1MenuItem: TMenuItem;
    deckpreset2MenuItem: TMenuItem;
    deckpreset3MenuItem: TMenuItem;
    deckpreset4MenuItem: TMenuItem;
    Separator1: TMenuItem;
    shortcutImage: TImage;
    shortcutkeyComboBox: TComboBox;
    shortcutkeyLabel: TLabel;
    showfpslimCheckBox: TCheckBox;
    smaaLabel: TLabel;
    smaaTrackBar: TTrackBar;
    smaavalueLabel: TLabel;
    spoofCheckBox: TCheckBox;
    squareImage: TImage;
    squareRadioButton: TRadioButton;
    statusGroupBox: TGroupBox;
    subBitBtn: TBitBtn;
    swapusageCheckBox: TCheckBox;
    sysinfoImage: TImage;
    systemGroupBox: TGroupBox;
    systemLabel: TLabel;
    tweaksTabSheet: TTabSheet;
    themeToggleSpeedButton: TSpeedButton;
    timeCheckBox: TCheckBox;
    toggleImage: TImage;
    ToggleSpeedButton: TSpeedButton;
    runpascubetItem: TMenuItem;
    runvkcubeItem: TMenuItem;
    Timer: TTimer;
    saveoptionsItem: TMenuItem;
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
    topcenterRadioButton: TRadioButton;
    topleftRadioButton: TRadioButton;
    toprightRadioButton: TRadioButton;
    tracelogCheckBox: TCheckBox;
    transparencyLabel: TLabel;
    transpTrackBar: TTrackBar;
    tweaksText2: TStaticText;
    updateBitBtn: TBitBtn;
    updateProgressBar: TProgressBar;
    updatestatusLabel: TLabel;
    usercustomBitBtn: TBitBtn;
    usesdlCheckBox: TCheckBox;
    heapdelayCheckBox: TCheckBox;
    versioningCheckBox: TCheckBox;
    verticalRadioButton: TRadioButton;
    vImage: TImage;
    visualTabSheet: TTabSheet;
    vkbasaltLabel: TLabel;
    goverlayimage: TImage;
    mangohudShape: TShape;
    optiscalerLabel: TLabel;
    vkbasaltShape: TShape;
    optiscalerShape: TShape;
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
    wined3dCheckBox: TCheckBox;
    wineLabel: TLabel;
    winesyncCheckBox: TCheckBox;
    xessLabel: TLabel;
    xessLabel1: TLabel;
    dlssLabel: TLabel;
    dlssLabel1: TLabel;


    procedure aboutBitBtnClick(Sender: TObject);
    procedure aboutMenuItemClick(Sender: TObject);
    procedure addBitBtnClick(Sender: TObject);
    procedure afterburnercolorBitBtn1Click(Sender: TObject);
    procedure afTrackBarChange(Sender: TObject);
    procedure basicBitBtnClick(Sender: TObject);
    procedure basichorizontalBitBtnClick(Sender: TObject);
    procedure blacklistBitBtnClick(Sender: TObject);
    procedure blacklistMenuItemClick(Sender: TObject);
    procedure casTrackBarChange(Sender: TObject);
    procedure copyBitBtnClick(Sender: TObject);
    procedure delayTrackBarChange(Sender: TObject);
    procedure dlsTrackBarChange(Sender: TObject);
    procedure donateMenuItemClick(Sender: TObject);
    procedure patcherlistLabelClick(Sender: TObject);
    procedure protontricksManagerButtonClick(Sender: TObject);
    procedure durationTrackBarChange(Sender: TObject);
    procedure forcelatencyflexCheckBoxChange(Sender: TObject);
    procedure forcereflexCheckBoxChange(Sender: TObject);
    procedure fpsavgBitBtnClick(Sender: TObject);
    procedure fpsonlyBitBtnClick(Sender: TObject);
    procedure fullBitBtnClick(Sender: TObject);
    procedure fxaaTrackBarChange(Sender: TObject);
    procedure globalenableMenuItemClick(Sender: TObject);
    procedure gamemodeCheckBoxClick(Sender: TObject);
    procedure goverlayBitBtnClick(Sender: TObject);
    procedure gpuframesjouleBitBtnClick(Sender: TObject);
    procedure gupdateBitBtnClick(Sender: TObject);
    procedure howtoBitBtnClick(Sender: TObject);
    procedure intelpowerfixBitBtnClick(Sender: TObject);
    procedure intervalTrackBarChange(Sender: TObject);
    procedure logfolderBitBtnClick(Sender: TObject);
    procedure coreloadtypeBitBtnClick(Sender: TObject);
    procedure fontsizeTrackBarChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure frametimetypeBitBtnClick(Sender: TObject);
    procedure fsrversionComboBoxChange(Sender: TObject);
    procedure gputempCheckBoxChange(Sender: TObject);
    procedure cputempCheckBoxChange(Sender: TObject);
    procedure geSpeedButtonClick(Sender: TObject);
    procedure mangocolorBitBtnClick(Sender: TObject);
    procedure mangohudLabelClick(Sender: TObject);
    procedure menuscaleTrackBarChange(Sender: TObject);
    procedure mesaRadioButtonChange(Sender: TObject);
    procedure nvidiaRadioButtonChange(Sender: TObject);
    procedure optiscalerLabelClick(Sender: TObject);
    procedure reshaderefreshBitBtnClick(Sender: TObject);
    procedure runpascubetItemClick(Sender: TObject);
    procedure saveoptionsItemClick(Sender: TObject);
    procedure deckpreset1MenuItemClick(Sender: TObject);
    procedure deckpreset2MenuItemClick(Sender: TObject);
    procedure deckpreset3MenuItemClick(Sender: TObject);
    procedure deckpreset4MenuItemClick(Sender: TObject);
    procedure runvkcubeItemClick(Sender: TObject);
    procedure minusButtonClick(Sender: TObject);
    procedure mipmapTrackBarChange(Sender: TObject);
    procedure goverlayPaintBoxPaint(Sender: TObject);
    procedure pcidevComboBoxChange(Sender: TObject);
    procedure optversionComboBoxChange(Sender: TObject);
    procedure plusSpeedButtonClick(Sender: TObject);
    procedure popupBitBtnClick(Sender: TObject);
    procedure saveBitBtnClick(Sender: TObject);
    procedure savecustomMenuItemClick(Sender: TObject);
    procedure saveasMenuItemClick(Sender: TObject);
    procedure smaaTrackBarChange(Sender: TObject);
    procedure subBitBtnClick(Sender: TObject);
    procedure ToggleSpeedButtonClick(Sender: TObject);
    procedure themeToggleSpeedButtonClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure transpTrackBarChange(Sender: TObject);
    procedure SetAllCheckBoxesToFalse;
    procedure SetAllCheckBoxesToTrue;
    procedure checkupdBitBtnClick(Sender: TObject);
    procedure tweaksLabelClick(Sender: TObject);
    procedure updateBitBtnClick(Sender: TObject);
    procedure usercustomBitBtnClick(Sender: TObject);
    procedure vkbasaltLabelClick(Sender: TObject);
    procedure mangohudLabelMouseEnter(Sender: TObject);
    procedure mangohudLabelMouseLeave(Sender: TObject);
    procedure vkbasaltLabelMouseEnter(Sender: TObject);
    procedure vkbasaltLabelMouseLeave(Sender: TObject);
    procedure optiscalerLabelMouseEnter(Sender: TObject);
    procedure optiscalerLabelMouseLeave(Sender: TObject);
    procedure tweaksLabelMouseEnter(Sender: TObject);
    procedure tweaksLabelMouseLeave(Sender: TObject);
    procedure SearchEditChange(Sender: TObject);
    procedure whitecolorBitBtnClick(Sender: TObject);
    procedure LoadVkBasaltConfig;
    procedure LoadMangoHudConfig;
    procedure SaveMangoHudConfig;
    procedure SaveMangoHudPreset(PresetNumber: Integer);
    procedure LoadOptiScalerConfig;
    procedure LoadFakeNvapiConfig;
    procedure LoadFgmodConfig;

  private
    FStartTick: Cardinal;
    FOptiscalerUpdate: TOptiscalerTab;
    FReshadeProgressBar: TProgressBar;
    FReshadePhaseLabel: TLabel;
    FStatusTimer: TTimer;
    
    function GetGeneralCheckBox(Index: Integer): TCheckBox;
    function GetGraphicsCheckBox(Index: Integer): TCheckBox;
    function GetPerformanceCheckBox(Index: Integer): TCheckBox;
    procedure ReshadeGitProgress(APhase: string; APercent: Integer);
    procedure UpdateGeSpeedButtonState;
    procedure UpdateGlobalEnableMenuItemVisibility;
    procedure RemoveMangoHudFromFGMod;
    procedure LoadTweaksFromFGMod;
    function IsOptiScalerInstalled: Boolean;
    
    // Keyboard shortcuts
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    
    // Status bar and search
    procedure ShowStatusMessage(const AMessage: string; ADuration: Integer = 3000);
    procedure StatusTimerTick(Sender: TObject);
    procedure ClearSearchHighlights;
  public


  end;





var
  goverlayform: Tgoverlayform;

  // ============================================================================
  // DESIGN SYSTEM CONSTANTS
  // ============================================================================
const
  // Spacing
  PADDING_SMALL = 8;
  PADDING_MEDIUM = 12;
  PADDING_LARGE = 16;
  MARGIN_SMALL = 4;
  MARGIN_MEDIUM = 8;
  MARGIN_LARGE = 12;
  
  // Typography
  FONT_SIZE_TITLE = 12;
  FONT_SIZE_BODY = 10;
  FONT_SIZE_SMALL = 9;
  FONT_SIZE_HINT = 8;
  FONT_NAME_PRIMARY = 'Ubuntu';         // Primary font (Linux)
  FONT_NAME_FALLBACK = 'Segoe UI';      // Fallback font (Windows)

var
  // ============================================================================
  // APPLICATION STATE AND VERSION
  // ============================================================================
  GLatestVersion: string = '';          // Latest available Goverlay version from GitHub
  GVERSION: string;                     // Current Goverlay version
  GCHANNEL: string;                     // Release channel (stable/git)
  mangohudsel: boolean;                 // MangoHud tab selected
  vkbasaltsel: boolean;                 // vkBasalt tab selected
  Found: Boolean;                       // General search/find result flag

  // ============================================================================
  // CONFIGURATION FILE PATHS AND FOLDERS
  // ============================================================================
  MANGOHUDCFGFILE: string;              // Path to MangoHud.conf
  MANGOHUDFOLDER: string;               // MangoHud configuration folder
  CUSTOMCFGFILE: string;                // Path to custom.conf (MangoHud presets)
  VKBASALTFOLDER: string;               // vkBasalt configuration folder
  VKBASALTCFGFILE: string;              // Path to vkBasalt.conf
  GOVERLAYFOLDER: string;               // Goverlay configuration folder
  BLACKLISTFILE: string;                // Path to application blacklist
  DATADIRS: string;                     // XDG data directories

  // ============================================================================
  // GENERAL UTILITY VARIABLES
  // ============================================================================
  s: string;                            // General purpose string variable
  AUX: string;                          // Auxiliary string variable 1
  AUX2: string;                         // Auxiliary string variable 2
  Color: string;                        // Color value storage

  // ============================================================================
  // MANGOHUD CONFIGURATION - VISUAL SETTINGS
  // ============================================================================
  ORIENTATION, HUDTITLE, BORDERTYPE, HUDALPHA, HUDCOLOR, FONTTYPE, FONTPATH, FONTSIZE, FONTCOLOR, HUDPOSITION, TOGGLEHUD, HIDEHUD, HUDCOMPACT, PCIDEV, TABLECOLUMNS: string;
  OFFSET: string;                       // HUD offset from edge

  // ============================================================================
  // MANGOHUD CONFIGURATION - GPU METRICS
  // ============================================================================
  GPUTEXT, GPUCOLOR: string;            // GPU text label and color
  GPUAVGLOAD, GPULOADCHANGE, GPULOADCOLOR, GPULOADVALUE: string;  // GPU load metrics
  VRAM, VRAMCOLOR, IOCOLOR: string;     // VRAM and I/O settings
  GPUFREQ, GPUMEMFREQ: string;          // GPU frequencies
  GPUTEMP, GPUMEMTEMP, GPUJUNCTEMP: string;  // GPU temperatures
  GPUFAN: string;                       // GPU fan speed
  GPUPOWER: string;                     // GPU power consumption
  GPUTHR, GPUTHRG: string;              // GPU throttling
  GPUMODEL, VULKANDRIVER, GPUVOLTAGE: string;  // GPU info

  // ============================================================================
  // MANGOHUD CONFIGURATION - CPU METRICS
  // ============================================================================
  CPUTEXT, CPUCOLOR: string;            // CPU text label and color
  CPUAVGLOAD, CPULOADCORE: string;      // CPU load metrics
  CPULOADCHANGE, CPULOADCOLOR, CPULOADVALUE: string;  // CPU load display settings
  CPUCOREFREQ: string;                  // CPU core frequencies
  CPUTEMP: string;                      // CPU temperature
  CORELOADTYPE: string;                 // Core load display type
  CPUPOWER: string;                     // CPU power consumption
  RAM, RAMCOLOR: string;                // RAM usage and color
  IOSTATS, IOREAD, IOWRITE: string;     // I/O statistics
  SWAP: string;                         // Swap memory usage
  PROCMEM: string;                      // Process memory usage

  // ============================================================================
  // MANGOHUD CONFIGURATION - PERFORMANCE METRICS
  // ============================================================================
  FPS, FPSAVG: string;                  // FPS display
  FRAMETIMING: string;                  // Frame timing graph
  SHOWFPSLIM: string;                   // Show FPS limiter value
  FRAMECOUNT: string;                   // Frame count display
  FRAMETIMEC: string;                   // Frame time calculation
  HISTOGRAM: string;                    // Frame time histogram
  FPSLIM, FPSLIMMET: string;            // FPS limit value and method
  FPSCOLOR, FPSVALUE, FPSCHANGE: string;  // FPS color settings
  VSYNC, GLVSYNC: string;               // V-Sync settings
  FILTER, AFFILTER, MIPMAPFILTER: string;  // Texture filters
  FPSLIMTOGGLE: string;                 // FPS limiter toggle hotkey
  fpsArray: TStringArray;               // FPS value array for parsing

  // ============================================================================
  // MANGOHUD CONFIGURATION - SYSTEM INFORMATION
  // ============================================================================
  DISTROINFO1, DISTROINFO2, DISTROINFO3, DISTROINFO4: string;  // Distribution info lines
  DISTRONAME: string;                   // Linux distribution name
  ARCH: string;                         // System architecture
  RESOLUTION: string;                   // Screen resolution
  SESSION, SESSIONTXT, USERSESSION: string;  // Session type info
  TIME: string;                         // Time display
  WINE, WINECOLOR: string;              // Wine version and color
  ENGINE, ENGINECOLOR, ENGINESHORT: string;  // Rendering engine info
  HUDVERSION: string;                   // MangoHud version display
  GAMEMODE: string;                     // GameMode status

  // ============================================================================
  // MANGOHUD CONFIGURATION - EXTRA FEATURES
  // ============================================================================
  VKBASALT: string;                     // vkBasalt effects display
  FCAT: string;                         // Frame rate target monitor
  FSR: string;                          // FidelityFX Super Resolution
  HDR: string;                          // HDR setting
  WINESYNC: string;                     // Wine sync method
  VPS: string;                          // Variable Pre-scaled
  FTEMP: string;                        // Frame temperature
  REFRESHRATE: string;                  // Screen refresh rate
  BATTERY, BATTERYCOLOR: string;        // Battery status and color
  BATTERYWATT, BATTERYTIME: string;     // Battery wattage and time remaining
  DEVICE, DEVICEICON: string;           // Device name and icon
  MEDIA, MEDIACOLOR: string;            // Media player info and color
  CUSTOMCMD1, CUSTOMCMD2: string;       // Custom commands
  NETWORK: string;                      // Network interface

  // ============================================================================
  // MANGOHUD CONFIGURATION - LOGGING
  // ============================================================================
  LOGFOLDER: string;                    // Log output folder
  LOGDURATION: string;                  // Log duration
  LOGDELAY: string;                     // Log start delay
  LOGINTERVAL: string;                  // Log sampling interval
  LOGTOGGLE: string;                    // Log toggle hotkey
  LOGVER: string;                       // Log version/format
  LOGAUTO: string;                      // Automatic logging

  // ============================================================================
  // APPLICATION BLACKLIST AND REPOSITORY
  // ============================================================================
  BlacklistStr: string;                 // Blacklist string representation
  blacklistVAR: string;                 // Blacklist variable
  RepoDir: string;                      // ReShade shader repository directory

  // ============================================================================
  // SYSTEM DETECTION AND HARDWARE INFO
  // ============================================================================
  GPU0: string;                         // Primary GPU identifier
  LSPCI0: string;                       // lspci output cache
  GPUNUMBER: integer;                   // Selected GPU number
  GPUCOUNT: integer;                    // Total GPU count
  GPUDESC: TStringList;                 // GPU description list

  // ============================================================================
  // UI AND DISPLAY CONTROL
  // ============================================================================
  COLUMNS: integer;                     // UI column count
  maxValue: integer;                    // Maximum value for progress/range
  currentValue: integer;                // Current value for progress/range
  i: integer;                           // General loop counter

  // ============================================================================
  // DATA STRUCTURES AND COLLECTIONS
  // ============================================================================
  FONTS: TStringList;                   // Available system fonts
  FONTFOLDERS: TStringList;             // Font directory paths
  FILELINES: TStringList;               // File content buffer

  // ============================================================================
  // TEMPORARY PROCESSING VARIABLES (kept for compatibility)
  // ============================================================================
  ArquivoConfig: TextFile;              // Config file handle (Portuguese name kept)
  Linha: string;                        // Line buffer (Portuguese name kept)
  CaminhoArquivo: string;               // File path (Portuguese name kept)
  NomeCampo: string;                    // Field name (Portuguese name kept)
  ValorCampo: string;                   // Field value (Portuguese name kept)

  const
  DarkBackgroundColor = $0045403A; // dark panel color BGR
  DarkerBackgroundColor = $00232323;  // darker panel color BGR for unselected item
  DarkTextColor = clwhite;  // set light color
  clRADEON = TColor($241CED); // ou RGB(237,28,36)
implementation

procedure Tgoverlayform.protontricksManagerButtonClick(Sender: TObject);
begin
  if not Assigned(protontricksform) then
    Application.CreateForm(Tprotontricksform, protontricksform);
  protontricksform.ShowModal;
end;

//Function to compare version strings (e.g., "1.5.3" vs "1.6.0")
function CompareVersions(const Version1, Version2: string): Integer;
var
  V1Parts, V2Parts: TStringArray;
  i, Num1, Num2, MaxLen: Integer;
begin
  // Split versions by dot
  V1Parts := SplitString(Version1, '.');
  V2Parts := SplitString(Version2, '.');

  // Get the maximum length
  MaxLen := Max(Length(V1Parts), Length(V2Parts));

  // Compare each part
  for i := 0 to MaxLen - 1 do
  begin
    // Get numeric value (0 if part doesn't exist)
    if i < Length(V1Parts) then
      Num1 := StrToIntDef(V1Parts[i], 0)
    else
      Num1 := 0;

    if i < Length(V2Parts) then
      Num2 := StrToIntDef(V2Parts[i], 0)
    else
      Num2 := 0;

    // Compare this part
    if Num1 < Num2 then
      Exit(-1)  // Version1 is older
    else if Num1 > Num2 then
      Exit(1);  // Version1 is newer
  end;

  Result := 0;  // Versions are equal
end;

function GetLatestGoverlayVersion: string;
var
  Process: TProcess;
  OutputList: TStringList;
  Response: string;
  JSONData: TJSONData;
  JSONArray: TJSONArray;
  JSONObject: TJSONObject;
  TagName: string;
  i: Integer;
  MaxVersion: string;
  CurrentTag: string;
  ComparisonResult: Integer;
begin
  Result := '';
  MaxVersion := '';
  Process := TProcess.Create(nil);
  OutputList := TStringList.Create;
  try
    try
      // Fetch only the last 4 tags to avoid GitHub API rate limits
      // Tags are returned in reverse chronological order (most recent first)
      Process.Executable := 'curl';
      Process.Parameters.Add('-s');  // Silent mode
      Process.Parameters.Add('-L');  // Follow redirects
      Process.Parameters.Add('-H');
      Process.Parameters.Add('Accept: application/vnd.github.v3+json');
      Process.Parameters.Add('-H');
      Process.Parameters.Add('User-Agent: Mozilla/5.0');
      // Fetch only 3 tags to minimize API usage
      Process.Parameters.Add(URL_GOVERLAY_API_TAGS);
      Process.Options := [poWaitOnExit, poUsePipes];
      Process.Execute;

      // Read response from curl
      OutputList.LoadFromStream(Process.Output);
      Response := OutputList.Text;

      if (Process.ExitStatus = 0) and (Response <> '') then
      begin
        JSONData := GetJSON(Response);
        try
          if Assigned(JSONData) and (JSONData is TJSONArray) then
          begin
            JSONArray := TJSONArray(JSONData);

            // Iterate through all returned tags (up to 3)
            for i := 0 to JSONArray.Count - 1 do
            begin
              JSONObject := JSONArray.Objects[i];
              if Assigned(JSONObject) then
              begin
                TagName := JSONObject.Get('name', '');
                // Remove 'v' prefix if present (e.g., "v1.5.3" -> "1.5.3")
                if (TagName <> '') and (TagName[1] = 'v') then
                  Delete(TagName, 1, 1);

                // If this is the first valid tag, use it as initial max
                if MaxVersion = '' then
                begin
                  MaxVersion := TagName;
                end
                else
                begin
                  // Compare with current maximum version
                  ComparisonResult := CompareVersions(TagName, MaxVersion);
                  // If current tag is greater than max, update max
                  if ComparisonResult > 0 then
                    MaxVersion := TagName;
                end;
              end;
            end;

            Result := MaxVersion;
          end;
        finally
          JSONData.Free;
        end;
      end;
    except
      on E: Exception do
        Result := ''; // Keep silent behavior on error
    end;
  finally
    OutputList.Free;
    Process.Free;
  end;
end;




//procedure to Check for goverlay update
procedure CheckGoverlayUpdate(const CurrentVersion, Channel: string; UpdateButton: TBitBtn);
var
  LatestVersion: string;
  ComparisonResult: Integer;
begin
  // MODIFICATION 1: Never show button if channel is "git" (development mode)
  if LowerCase(Channel) = 'git' then
  begin
    if Assigned(UpdateButton) then
      UpdateButton.Visible := False;
    Exit;
  end;

  // Get latest version from GitHub
  LatestVersion := GetLatestGoverlayVersion;
  GLatestVersion := LatestVersion;

  // If we got a valid version from GitHub
  if LatestVersion <> '' then
  begin
    // Compare versions numerically
    ComparisonResult := CompareVersions(CurrentVersion, LatestVersion);

    // MODIFICATION 2: Only show button if LatestVersion is GREATER than CurrentVersion
    if ComparisonResult < 0 then
    begin
      if Assigned(UpdateButton) then
      begin
        UpdateButton.Caption := 'New Version ' + LatestVersion + ' available';
        UpdateButton.Visible := True;
      end;
    end
    else
    begin
      // If current version is equal or greater, hide the button
      if Assigned(UpdateButton) then
        UpdateButton.Visible := False;
    end;
  end
  else
  begin
    // If failed to get version from GitHub, hide the button
    if Assigned(UpdateButton) then
      UpdateButton.Visible := False;
  end;
end;


function IsNvidiaModuleLoaded: Boolean;
var
  Process: TProcess;
  OutputList: TStringList;
  Output: string;
begin
  Result := False;
  Process := TProcess.Create(nil);
  OutputList := TStringList.Create;
  try
    try
      // Use lsmod to check if nvidia module is loaded
      Process.Executable := 'lsmod';
      Process.Options := [poWaitOnExit, poUsePipes];
      Process.Execute;

      // Read output
      OutputList.LoadFromStream(Process.Output);
      Output := OutputList.Text;

      // Check if 'nvidia' appears in the output
      Result := Pos('nvidia', LowerCase(Output)) > 0;
    except
      on E: Exception do
        Result := False; // If error, assume not loaded
    end;
  finally
    OutputList.Free;
    Process.Free;
  end;
end;

{$R *.lfm}


{ Tgoverlayform }


//radeon theme
procedure ApplyRadeonTheme(AForm: TForm);
var
  i: Integer;
begin
  AForm.Color := clRADEON;  // cor de fundo do formul�rio ativo
  for i := 0 to AForm.ControlCount - 1 do
  begin
    if (AForm.Controls[i] is TButton) then
    begin
      (AForm.Controls[i] as TButton).Font.Color := clWhite;
      (AForm.Controls[i] as TButton).Color := clRADEON;
    end
    else if (AForm.Controls[i] is TLabel) then
      (AForm.Controls[i] as TLabel).Font.Color := clWhite;
  end;
end;



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

// Send desktop notification - works in both Flatpak and normal environments
// Uses D-Bus (modern and sandbox-compatible) with notify-send fallback
procedure SendNotification(const Title, Message: string; const IconPath: string = '');
var
  Process: TProcess;
  DBusCommand: string;
  UseDBus: Boolean;
begin
  // Try to use D-Bus notifications (works in both Flatpak and modern Linux)
  // D-Bus is preferred because:
  // - Works inside Flatpak sandbox
  // - More reliable and modern
  // - Direct communication with notification daemon
  UseDBus := True;

  if UseDBus then
  begin
    // Build D-Bus command for org.freedesktop.Notifications
    DBusCommand := 'gdbus call --session --dest org.freedesktop.Notifications ' +
                   '--object-path /org/freedesktop/Notifications ' +
                   '--method org.freedesktop.Notifications.Notify ' +
                   '"' + Title + '" 0 ';

    if IconPath <> '' then
      DBusCommand := DBusCommand + '"' + IconPath + '" '
    else
      DBusCommand := DBusCommand + '"" ';

    DBusCommand := DBusCommand + '"' + Title + '" "' + Message + '" ' +
                   '[] {} 5000';

    Process := TProcess.Create(nil);
    try
      Process.Executable := FindDefaultExecutablePath('sh');
      Process.Parameters.Add('-c');
      Process.Parameters.Add(DBusCommand);
      // Don't wait for notification to complete - send asynchronously for instant response
      Process.Options := [poUsePipes, poNoConsole];
      Process.Execute;
    finally
      Process.Free;
    end;
  end;

  // Fallback to notify-send if D-Bus is not available
  if not UseDBus then
  begin
    Process := TProcess.Create(nil);
    try
      Process.Executable := FindDefaultExecutablePath('sh');
      Process.Parameters.Add('-c');

      if IconPath <> '' then
        Process.Parameters.Add('notify-send -e -i "' + IconPath + '" "' + Title + '" "' + Message + '"')
      else
        Process.Parameters.Add('notify-send -e "' + Title + '" "' + Message + '"');

      Process.Options := [poUsePipes, poNoConsole];
      Process.Execute;
    finally
      Process.Free;
    end;
  end;
end;

// Function to get GOverlay log directory with proper XDG support
// Usage: ~/.local/share/goverlay/logs (Sandboxed in Flatpak)
function GetGOverlayLogPath(): String;
var
  DataHome: String;
begin
  // Standard XDG_DATA_HOME (maps to sandbox in Flatpak: ~/.var/app/.../data)
  DataHome := GetEnvironmentVariable('XDG_DATA_HOME');
  
  // Fallback to ~/.local/share
  if DataHome = '' then
    DataHome := GetUserDir + '.local/share';
  
  Result := IncludeTrailingPathDelimiter(DataHome) + 'goverlay' + PathDelim + 'logs';
end;

//Procedure to execute external GUI aps
procedure ExecuteGUICommand(const Command: string);
var
  Process: TProcess;
  LogPath: string;
  NohupLogFile: string;
begin
  Process := TProcess.Create(nil);
  try
    // Get XDG-compliant log directory path
    LogPath := GetGOverlayLogPath;
    
    // Create log directory if it doesn't exist
    if not DirectoryExists(LogPath) then
      ForceDirectories(LogPath);
    
    // Set nohup output file path
    NohupLogFile := IncludeTrailingPathDelimiter(LogPath) + 'nohup.out';
    
    Process.Executable := FindDefaultExecutablePath('sh');
    Process.Parameters.Add('-c');
    // Use nohup with sh -c to handle environment variables and detachment properly
    // We wrap the command in single quotes for the inner sh
    // Redirect both stdout and stderr to XDG-compliant log file
    Process.Parameters.Add('nohup sh -c ''' + Command + ''' >> "' + NohupLogFile + '" 2>&1 &');
    // Don't use poUsePipes - we're not reading the output and it causes
    // the child process to block when pipes fill up after multiple executions
    Process.Options := [];
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

// Function to get MangoHud config directory with proper XDG support
// For Flatpak, this uses HOST_XDG_CONFIG_HOME to access the real host location
function GetMangoHudConfigDir(): String;
var
  ConfigHome: String;
begin
  // For Flatpak, try HOST_XDG_CONFIG_HOME first to access the real host location
  ConfigHome := GetEnvironmentVariable('HOST_XDG_CONFIG_HOME');
  
  // Fall back to standard XDG_CONFIG_HOME
  if ConfigHome = '' then
    ConfigHome := GetEnvironmentVariable('XDG_CONFIG_HOME');
  
  // Final fallback to ~/.config
  if ConfigHome = '' then
    ConfigHome := GetUserDir + '.config';
  
  Result := IncludeTrailingPathDelimiter(ConfigHome) + 'MangoHud';
end;

// Function to get vkBasalt config directory with proper XDG support
// For Flatpak, this uses HOST_XDG_CONFIG_HOME to access the real host location
function GetVkBasaltConfigDir(): String;
var
  ConfigHome: String;
begin
  // When running in Flatpak, games run outside the sandbox and need to access
  // the host vkBasalt configuration. Always use the host .config directory.
  if IsRunningInFlatpak then
  begin
    // In Flatpak, always use the host's .config directory
    // because games run outside the sandbox and vkBasalt needs host paths
    ConfigHome := GetUserDir + '.config';
  end
  else
  begin
    // For native installations, use standard XDG paths
    ConfigHome := GetEnvironmentVariable('XDG_CONFIG_HOME');
    
    // Final fallback to ~/.config
    if ConfigHome = '' then
      ConfigHome := GetUserDir + '.config';
  end;
  
  Result := IncludeTrailingPathDelimiter(ConfigHome) + 'vkBasalt';
end;

// Function to get GOverlay config directory with proper XDG support
// For Flatpak, this uses HOST_XDG_CONFIG_HOME to access the real host location
function GetGOverlayConfigDir(): String;
var
  ConfigHome: String;
begin
  // For Flatpak, try HOST_XDG_CONFIG_HOME first to access the real host location
  ConfigHome := GetEnvironmentVariable('HOST_XDG_CONFIG_HOME');
  
  // Fall back to standard XDG_CONFIG_HOME
  if ConfigHome = '' then
    ConfigHome := GetEnvironmentVariable('XDG_CONFIG_HOME');
  
  // Final fallback to ~/.config
  if ConfigHome = '' then
    ConfigHome := GetUserDir + '.config';
  
  Result := IncludeTrailingPathDelimiter(ConfigHome) + 'goverlay';
end;

// Function to get GOverlay data directory with proper XDG support
// For Flatpak, this uses HOST_XDG_DATA_HOME to access the real host location
// For native, this uses XDG_DATA_HOME to follow XDG Base Directory specification
function GetGOverlayDataDir(): String;
var
  DataHome: String;
  UserName: String;
begin
  // For Flatpak, try HOST_XDG_DATA_HOME first to access the real host location
  DataHome := GetEnvironmentVariable('HOST_XDG_DATA_HOME');
  
  // If in Flatpak and HOST_XDG_DATA_HOME is not available, construct the host path manually
  if (DataHome = '') and IsRunningInFlatpak then
  begin
    UserName := GetEnvironmentVariable('USER');
    if UserName <> '' then
      DataHome := '/home/' + UserName + '/.local/share'
    else
      DataHome := GetUserDir + '.local/share';
  end;
  
  // Fall back to standard XDG_DATA_HOME for native installations
  if DataHome = '' then
    DataHome := GetEnvironmentVariable('XDG_DATA_HOME');
  
  // Final fallback to ~/.local/share
  if DataHome = '' then
    DataHome := GetUserDir + '.local/share';
  
  Result := IncludeTrailingPathDelimiter(DataHome) + 'goverlay';
end;

// Function to get environment.d config directory with proper XDG support
// For Flatpak, this uses HOST_XDG_CONFIG_HOME to access the real host location
// For native, this uses XDG_CONFIG_HOME to follow XDG Base Directory specification
// Returns: ~/.config/environment.d for both Flatpak and native installations
function GetEnvironmentDConfigDir(): String;
var
  ConfigHome: String;
begin
  // For Flatpak, try HOST_XDG_CONFIG_HOME first to access the real host location
  ConfigHome := GetEnvironmentVariable('HOST_XDG_CONFIG_HOME');
  
  // Fall back to standard XDG_CONFIG_HOME for native installations
  if ConfigHome = '' then
    ConfigHome := GetEnvironmentVariable('XDG_CONFIG_HOME');
  
  // Final fallback to ~/.config
  if ConfigHome = '' then
    ConfigHome := GetUserDir + '.config';
  
  Result := IncludeTrailingPathDelimiter(ConfigHome) + 'environment.d';
end;

// Function to check if MangoHud is globally enabled
function IsMangoHudGloballyEnabled(): Boolean;
var
  ConfigFile: String;
  FileContent: TStringList;
  i: Integer;
begin
  Result := False;
  ConfigFile := IncludeTrailingPathDelimiter(GetEnvironmentDConfigDir()) + 'mangohud.conf';
  
  if not FileExists(ConfigFile) then
    Exit;
  
  FileContent := TStringList.Create;
  try
    try
      FileContent.LoadFromFile(ConfigFile);
      // Check if the file contains MANGOHUD=1
      for i := 0 to FileContent.Count - 1 do
      begin
        if Trim(FileContent[i]) = 'MANGOHUD=1' then
        begin
          Result := True;
          Break;
        end;
      end;
    except
      Result := False;
    end;
  finally
    FileContent.Free;
  end;
end;

// Procedure to enable MangoHud globally
// Creates ~/.config/environment.d/mangohud.conf with MANGOHUD=1
procedure EnableMangoHudGlobally();
var
  ConfigDir, ConfigFile: String;
  FileContent: TStringList;
begin
  ConfigDir := GetEnvironmentDConfigDir();
  ConfigFile := IncludeTrailingPathDelimiter(ConfigDir) + 'mangohud.conf';
  
  // Create directory if it doesn't exist
  if not DirectoryExists(ConfigDir) then
    ForceDirectories(ConfigDir);
  
  // Create/overwrite file with MANGOHUD=1
  FileContent := TStringList.Create;
  try
    FileContent.Add('MANGOHUD=1');
    FileContent.SaveToFile(ConfigFile);
  finally
    FileContent.Free;
  end;
end;

// Procedure to disable MangoHud globally
// Deletes ~/.config/environment.d/mangohud.conf
procedure DisableMangoHudGlobally();
var
  ConfigFile: String;
begin
  ConfigFile := IncludeTrailingPathDelimiter(GetEnvironmentDConfigDir()) + 'mangohud.conf';
  
  if FileExists(ConfigFile) then
    DeleteFile(ConfigFile);
end;


// Procedure to execute session logout based on desktop environment
procedure ExecuteSessionLogout();
var
  DesktopEnv: String;
  UserName: String;
  LogoutCommand: String;
begin
  // Get current desktop environment from XDG_CURRENT_DESKTOP
  DesktopEnv := UpperCase(GetEnvironmentVariable('XDG_CURRENT_DESKTOP'));
  
  // If XDG_CURRENT_DESKTOP is empty, try DESKTOP_SESSION
  if DesktopEnv = '' then
    DesktopEnv := UpperCase(GetEnvironmentVariable('DESKTOP_SESSION'));
  
  // Determine logout command based on desktop environment
  if Pos('GNOME', DesktopEnv) > 0 then
  begin
    // GNOME desktop
    LogoutCommand := 'gnome-session-quit --logout --no-prompt';
  end
  else if Pos('KDE', DesktopEnv) > 0 then
  begin
    // KDE Plasma desktop
    // KDE Plasma 6 uses org.kde.Shutdown, older versions use org.kde.ksmserver
    if IsCommandAvailable('qdbus6') then
      LogoutCommand := 'qdbus6 org.kde.Shutdown /Shutdown logout'
    else if IsCommandAvailable('qdbus') then
      LogoutCommand := 'qdbus org.kde.ksmserver /KSMServer logout 0 0 0'
    else
    begin
      UserName := GetEnvironmentVariable('USER');
      LogoutCommand := 'loginctl terminate-user ' + UserName;
    end;
  end
  else if Pos('XFCE', DesktopEnv) > 0 then
  begin
    // XFCE desktop
    LogoutCommand := 'xfce4-session-logout --logout';
  end
  else if Pos('MATE', DesktopEnv) > 0 then
  begin
    // MATE desktop
    LogoutCommand := 'mate-session-save --logout';
  end
  else if Pos('CINNAMON', DesktopEnv) > 0 then
  begin
    // Cinnamon desktop
    LogoutCommand := 'cinnamon-session-quit --logout --no-prompt';
  end
  else
  begin
    // Generic fallback using loginctl (systemd)
    UserName := GetEnvironmentVariable('USER');
    LogoutCommand := 'loginctl terminate-user ' + UserName;
  end;
  
  // Execute the logout command
  ExecuteShellCommand(LogoutCommand);
end;

// Function to create directory ensuring it exists
// For Flatpak, the manifest must have :create permission on the parent directory
procedure CreateHostDirectory(const DirPath: String);
begin
  if not DirectoryExists(DirPath) then
    ForceDirectories(DirPath);
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
  TempList: TStringList;
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

  TempList := TStringList.Create;
  try
    Output.Position := 0; // Required to make sure all data is copied from the start
    TempList.LoadFromStream(Output);
    Valor.Text := StringReplace(TempList.Text, '\n', LineEnding, [rfReplaceAll, rfIgnoreCase]);
  finally
    TempList.Free;
  end;

  Output.Free;

  Result := Valor.Text <> ''; // Return true if value is located, false if not
end;


//Function to detect GPU vendor without lspci (Flatpak-compatible)
// NOTE: This function is deprecated - use systemdetector.DetectGPUVendor instead
function DetectGPUVendorFromSys: string;
var
  SearchRec: TSearchRec;
  VendorFile, DeviceClassFile: string;
  VendorID: string;
  DeviceClass: string;
  VendorText: TStringList;
begin
  Result := 'unknown';

  // Search for VGA devices in /sys/bus/pci/devices/
  if FindFirst('/sys/bus/pci/devices/*', faDirectory, SearchRec) = 0 then
  begin
    try
      repeat
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          DeviceClassFile := '/sys/bus/pci/devices/' + SearchRec.Name + '/class';
          VendorFile := '/sys/bus/pci/devices/' + SearchRec.Name + '/vendor';

          // Check if this is a VGA device (class 0x03xxxx)
          if FileExists(DeviceClassFile) and FileExists(VendorFile) then
          begin
            VendorText := TStringList.Create;
            try
              VendorText.LoadFromFile(DeviceClassFile);
              if VendorText.Count > 0 then
              begin
                DeviceClass := Trim(VendorText[0]);
                // VGA controller class starts with 0x03
                if (Length(DeviceClass) >= 4) and (Copy(DeviceClass, 1, 4) = '0x03') then
                begin
                  VendorText.Clear;
                  VendorText.LoadFromFile(VendorFile);
                  if VendorText.Count > 0 then
                  begin
                    VendorID := Trim(VendorText[0]);
                    // Check vendor IDs
                    case VendorID of
                      '0x1002': Result := 'AMD';      // AMD/ATI
                      '0x10de': Result := 'NVIDIA';   // NVIDIA
                      '0x8086': Result := 'Intel';    // Intel
                    end;

                    if Result <> 'unknown' then
                      Break; // Found a GPU, stop searching
                  end;
                end;
              end;
            finally
              VendorText.Free;
            end;
          end;
        end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end;

  // Note: In Flatpak, /sys/bus/pci should be accessible with proper permissions
  // If detection fails, the application will use default theme
end;


//Function to get network interfaces without ip command (Flatpak-compatible)
function GetNetworkInterfacesFromSys: TStringList;
var
  SearchRec: TSearchRec;
  InterfaceName: string;
begin
  Result := TStringList.Create;
  Result.Sorted := True;
  Result.Duplicates := dupIgnore;

  // Read directly from /sys/class/net/
  if FindFirst('/sys/class/net/*', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        InterfaceName := SearchRec.Name;
        // Filter out . and .. and loopback
        if (InterfaceName <> '.') and (InterfaceName <> '..') and (InterfaceName <> 'lo') then
        begin
          // Add common network interface types
          if (Pos('eth', InterfaceName) = 1) or
             (Pos('enp', InterfaceName) = 1) or
             (Pos('wlan', InterfaceName) = 1) or
             (Pos('wlp', InterfaceName) = 1) or
             (Pos('wlo', InterfaceName) = 1) then
          begin
            Result.Add(InterfaceName);
          end;
        end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end;
end;


//Function to get standard font directories for different distributions
function GetStandardFontDirectories: TStringList;
var
  Dir: String;
begin
  Result := TStringList.Create;
  Result.Duplicates := dupIgnore;
  Result.Sorted := True;

  // Standard Linux font directories
  Result.Add('/usr/share/fonts');
  Result.Add('/usr/local/share/fonts');
  Result.Add(GetUserConfigDir + '/../.local/share/fonts'); // ~/.local/share/fonts
  Result.Add(GetUserConfigDir + '/../.fonts'); // ~/.fonts

  // NixOS-specific directories
  Result.Add('/run/current-system/sw/share/fonts');
  Result.Add(GetEnvironmentVariable('HOME') + '/.nix-profile/share/fonts');

  // Flatpak font directories
  Result.Add('/var/lib/flatpak/exports/share/fonts');
  Result.Add(GetUserConfigDir + '/../.local/share/flatpak/exports/share/fonts');

  // Remove directories that don't exist
  for Dir in Result do
  begin
    if not DirectoryExists(Dir) then
      Result.Delete(Result.IndexOf(Dir));
  end;
end;


//Procedure to find font files (*.ttf)
procedure ListarFontesNoDiretorio(ComboBox: TComboBox);
var
  Arquivos, AllFonts, FontDirs: TStringList;
  Arquivo, FontDir: String;
begin
  AllFonts := TStringList.Create;
  AllFonts.Duplicates := dupIgnore;
  AllFonts.Sorted := True;

  // First, try to load from cache
  if LoadFont('fonts', FONTS) then
  begin
    for Arquivo in FONTS do
      AllFonts.Add(Arquivo);
  end
  else
  begin
    // If no cache, search in standard font directories
    FontDirs := GetStandardFontDirectories;
    try
      for FontDir in FontDirs do
      begin
        if DirectoryExists(FontDir) then
        begin
          Arquivos := FindAllFiles(FontDir, '*.ttf', True); // True for recursive search
          try
            for Arquivo in Arquivos do
              AllFonts.Add(Arquivo);
          finally
            Arquivos.Free;
          end;
        end;
      end;
    finally
      FontDirs.Free;
    end;
  end;

  try
    for Arquivo in AllFonts do
    begin
      ComboBox.Items.Add(ExtractFileName(Arquivo)); // Add filename into combobox
    end;
  finally
    AllFonts.Free; // Free memory
  end;
end;


//Procedure to find font directories
procedure ListFontDirectories(out Dirs: TStringList);
var
  Arquivos, FontDirs: TStringList;
  Arquivo, FontDir: String;
begin
  // First, try to load from cache
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
  end
  else
  begin
    // If no cache, use standard font directories
    FontDirs := GetStandardFontDirectories;
    try
      for FontDir in FontDirs do
      begin
        if DirectoryExists(FontDir) then
          Dirs.Add(FontDir);
      end;
    finally
      FontDirs.Free;
    end;
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
  i, j: Integer;
  ParentControl: TWinControl;
begin
  // List of MangoHud-related TabSheets where we want to select all checkboxes
  // Exclude optiscalertabsheet, vkbasalttabsheet, and tweakstabsheet
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TCheckBox then
    begin
      // Get the parent control hierarchy to check if this checkbox is in a MangoHud tab
      ParentControl := (Components[i] as TCheckBox).Parent;
      
      // Walk up the parent chain to find if it's in a TabSheet
      while Assigned(ParentControl) do
      begin
        // If we find one of the excluded tabs, skip this checkbox
        if (ParentControl = optiscalertabsheet) or 
           (ParentControl = vkbasalttabsheet) or 
           (ParentControl = tweakstabsheet) then
        begin
          Break; // Don't set this checkbox
        end;
        
        // If we're in one of the MangoHud tabs or reached the form, set the checkbox
        if (ParentControl = presetTabSheet) or
           (ParentControl = visualTabSheet) or
           (ParentControl = performanceTabSheet) or
           (ParentControl = metricsTabSheet) or
           (ParentControl = extrasTabSheet) then
        begin
          (Components[i] as TCheckBox).Checked := True;
          Break;
        end;
        
        // Move up the parent chain
        ParentControl := ParentControl.Parent;
      end;
    end;
  end;
end;

procedure Tgoverlayform.checkupdBitBtnClick(Sender: TObject);
var
  HasUpdates: Boolean;
begin
  if Assigned(FOptiscalerUpdate) then
  begin
    // Store the state before checking
    HasUpdates := False;

    // Check for updates
    FOptiscalerUpdate.CheckForUpdatesOnClick;

    // Check if any update is available after checking
    if Assigned(FOptiscalerUpdate.DeckyLabel2) and FOptiscalerUpdate.DeckyLabel2.Visible then
      HasUpdates := True;

    if Assigned(FOptiscalerUpdate.FakeNvapiLabel2) and FOptiscalerUpdate.FakeNvapiLabel2.Visible then
      HasUpdates := True;

    // Show notification if no updates available
    if not HasUpdates then
      SendNotification('Goverlay', 'No updates for OptiScaler available', GetIconFile);
  end;
end;

procedure Tgoverlayform.tweaksLabelClick(Sender: TObject);
begin
//Enable goverlay tabs
goverlayPageControl.ShowTabs:=false; //disable mangohud tab
vkbasalttabsheet.TabVisible:=false; //disable vkbasalt tab
optiscalertabsheet.TabVisible:=false; //disable optiscaler tab
tweakstabsheet.TabVisible:=true;

//unselect vkbasalt , optiscaler
mangohudLabel.Font.Color:=clgray;
mangohudShape.Brush.Color:= DarkerBackgroundColor;
vkbasaltLabel.Font.Color:=clgray;
vkbasaltShape.Brush.Color:= DarkerBackgroundColor;
optiscalerLabel.Font.Color:=clgray;
optiscalerShape.Brush.Color:= DarkerBackgroundColor;


// select mangohud
tweaksLabel.Font.Color:=clwhite;
tweaksShape.Brush.Color:= DarkBackgroundColor;
goverlayPageControl.ActivePage:=tweaksTabsheet;

//Hide notification messages
notificationLabel.Visible:=false;
commandEdit.Visible:=false;
copyBitbtn.Visible:=false;

//Show Global Enable controls for tweaks tabs (fgmod integration)
geSpeedButton.Visible:=true;
geLabel.Visible:=true;
UpdateGeSpeedButtonState;
UpdateGlobalEnableMenuItemVisibility;

end;

procedure Tgoverlayform.updateBitBtnClick(Sender: TObject);
begin
 updateProgressBar.Visible:=true;
 updatestatusLabel.Visible:=true;
 FOptiscalerUpdate.UpdateButtonClick(Sender);
 updateProgressBar.Visible:=false;
 updatestatusLabel.Visible:=false;
 // Re-enable controls after installation completes
 UpdateGeSpeedButtonState;
end;


//Function to check for dependencies


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

  //check if pascube is available (skip in Flatpak mode - no Flatpak version yet)
  if not IsRunningInFlatpak then
  begin
    if not IsCommandAvailable('pascube') then
       Missing.Add('pascube');
  end;

  // Check for Flatpak runtimes or native binaries
  if IsRunningInFlatpak then
  begin
    // Flatpak mode: check for .so files in container paths
    // MangoHud extension
    if not FileExists('/usr/lib/extensions/vulkan/MangoHud/lib/x86_64-linux-gnu/libMangoHud.so') and
       not FileExists('/usr/lib/extensions/vulkan/MangoHud/lib/i386-linux-gnu/libMangoHud.so') then
      Missing.Add('MangoHud runtime 25.08');

    // vkBasalt extension
    if not FileExists('/usr/lib/extensions/vulkan/vkBasalt/lib/x86_64-linux-gnu/vkbasalt/libvkbasalt.so') and
       not FileExists('/usr/lib/extensions/vulkan/vkBasalt/lib/i386-linux-gnu/vkbasalt/libvkbasalt.so') then
      Missing.Add('vkBasalt runtime 25.08');
  end
  else
  begin
    // Native mode: check for binaries normally
    if not IsCommandAvailable('mangohud') then
      Missing.Add('mangohud');

    // Traditional distros: check for libvkbasalt.so
    if not FileExists('/usr/share/vulkan/implicit_layer.d/vkBasalt.json') and
       not FileExists('/usr/lib/libvkbasalt.so') and
       not FileExists('/usr/lib64/libvkbasalt.so') and
       not FileExists('/usr/lib/x86_64-linux-gnu/libvkbasalt.so') then
      Missing.Add('vkbasalt');
  end;

  //check if vkcube is available
  if not IsCommandAvailable('vkcube') then
    Missing.Add('vkcube');

    //check if 7z is available
  if not IsCommandAvailable('7z') then
    Missing.Add('p7zip');

    //check if curl is available
  if not IsCommandAvailable('curl') then
    Missing.Add('curl');

    //check if git is available
  if not IsCommandAvailable('git') then
    Missing.Add('git');

  //check if gamemoderun is available (required for GameMode feature in Tweaks tab)
  // Skip check in Flatpak since gamemoderun is on the host and we can't reliably detect it
  if not IsRunningInFlatpak then
  begin
    if not IsCommandAvailable('gamemoderun') then
      Missing.Add('gamemode');
  end;

   //check if zenergy module is available
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

      // remove quotes
      DistroInfo := StringReplace(DistroInfo, '"', '', [rfReplaceAll]);
      VersionOrBuildID := StringReplace(VersionOrBuildID, '"', '', [rfReplaceAll]);
    finally
      SL.Free;
    end;
  end;

  KernelVersion := GetKernelVersion;

  // create config dir if needed (use ForceDirectories to create full path)
  if not DirectoryExists(SavePath) then
    ForceDirectories(SavePath);

  // save Distro
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

  // Update the config files path with proper XDG and Flatpak support
   CUSTOMCFGFILE := IncludeTrailingPathDelimiter(GetMangoHudConfigDir()) + 'custom.conf';
   MANGOHUDCFGFILE := IncludeTrailingPathDelimiter(GetMangoHudConfigDir()) + 'MangoHud.conf';




if not FileExists(CUSTOMCFGFILE) then
begin
  ShowMessage('You need to save a custom preset first. Click on the hamburger menu and click save as custom config.');
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

  SendNotification('MangoHud', 'Reloading custom user preset', GetIconFile);

  end;

procedure Tgoverlayform.vkbasaltLabelClick(Sender: TObject);
begin
  //Disable tabs
  goverlayPageControl.ShowTabs:=false;
  optiscalertabsheet.TabVisible:=false; //disable optiscaler tab
  tweakstabsheet.TabVisible:=false;

  //unselecte mangohud
  mangohudLabel.Font.Color:=clgray;
  mangohudShape.Brush.Color:= DarkerBackgroundColor;
  optiscalerLabel.Font.Color:=clgray;
  optiscalerShape.Brush.Color:= DarkerBackgroundColor;
  tweaksLabel.Font.Color:=clgray;
  tweaksShape.Brush.Color:= DarkerBackgroundColor;

  // select vkbasalt
  vkbasaltLabel.Font.Color:=clwhite;
  vkbasaltShape.Brush.Color:= DarkBackgroundColor;
  vkbasalttabsheet.TabVisible:=true;
  goverlayPageControl.ActivePage:=vkbasaltTabsheet;

  //Run vkcube with effects
  ExecuteGUICommand('killall vkcube');
  ExecuteGUICommand('killall pascube');
  SendNotification('Goverlay', 'Trying vkbasalt effects', GetIconFile);

  // In Flatpak, MangoHud works via environment variable, not as a wrapper command
  // In Flatpak, use vkcube-wayland binary instead of vkcube --wsi wayland
  if IsCommandAvailable('pascube') then
  begin
     ExecuteGUICommand('VKBASALT_LOG_FILE=' + VKBASALTFOLDER + '/' + 'vkBasalt.log ENABLE_VKBASALT=1 MANGOHUD=1 pascube &');
  end
  else
  begin
    SendNotification('Goverlay', 'PasCube was not located, using vkcube instead', GetIconFile);

      if IsRunningInFlatpak then
      begin
         // In Flatpak, use vkcube-wayland binary if available and on Wayland
         if (USERSESSION = 'wayland') and IsCommandAvailable('vkcube-wayland') then
            ExecuteGUICommand('VKBASALT_LOG_FILE=' + VKBASALTFOLDER + '/' + 'vkBasalt.log ENABLE_VKBASALT=1 MANGOHUD=1 vkcube-wayland &')
         else
            ExecuteGUICommand('VKBASALT_LOG_FILE=' + VKBASALTFOLDER + '/' + 'vkBasalt.log ENABLE_VKBASALT=1 MANGOHUD=1 vkcube &');
      end
    else
    begin
      if USERSESSION = 'wayland' then
        ExecuteGUICommand('VKBASALT_LOG_FILE=' + VKBASALTFOLDER + '/' + 'vkBasalt.log ENABLE_VKBASALT=1 mangohud vkcube --wsi wayland &')
      else
        ExecuteGUICommand('VKBASALT_LOG_FILE=' + VKBASALTFOLDER + '/' + 'vkBasalt.log ENABLE_VKBASALT=1 mangohud vkcube &');
    end;
  end;


  //Hide notification messages
  notificationLabel.Visible:=false;
  commandEdit.Visible:=false;
  copyBitbtn.Visible:=false;

  //Update geSpeedButton state for vkBasalt
  UpdateGeSpeedButtonState;
  UpdateGlobalEnableMenuItemVisibility;

end;

// Helper function to lighten a color by blending with white
function LightenColor(AColor: TColor; Amount: Byte): TColor;
var
  R, G, B: Byte;
begin
  R := Red(AColor);
  G := Green(AColor);
  B := Blue(AColor);
  R := R + (255 - R) * Amount div 255;
  G := G + (255 - G) * Amount div 255;
  B := B + (255 - B) * Amount div 255;
  Result := RGBToColor(R, G, B);
end;

procedure Tgoverlayform.mangohudLabelMouseEnter(Sender: TObject);
begin
  // Only lighten if not already selected (white)
  if mangohudLabel.Font.Color <> clWhite then
    mangohudLabel.Font.Color := LightenColor(mangohudLabel.Font.Color, 80);
end;

procedure Tgoverlayform.mangohudLabelMouseLeave(Sender: TObject);
begin
  // Restore to gray if not selected
  if mangohudLabel.Font.Color <> clWhite then
    mangohudLabel.Font.Color := clGray;
end;

procedure Tgoverlayform.vkbasaltLabelMouseEnter(Sender: TObject);
begin
  if vkbasaltLabel.Font.Color <> clWhite then
    vkbasaltLabel.Font.Color := LightenColor(vkbasaltLabel.Font.Color, 80);
end;

procedure Tgoverlayform.vkbasaltLabelMouseLeave(Sender: TObject);
begin
  if vkbasaltLabel.Font.Color <> clWhite then
    vkbasaltLabel.Font.Color := clGray;
end;

procedure Tgoverlayform.optiscalerLabelMouseEnter(Sender: TObject);
begin
  if optiscalerLabel.Font.Color <> clWhite then
    optiscalerLabel.Font.Color := LightenColor(optiscalerLabel.Font.Color, 80);
end;

procedure Tgoverlayform.optiscalerLabelMouseLeave(Sender: TObject);
begin
  if optiscalerLabel.Font.Color <> clWhite then
    optiscalerLabel.Font.Color := clGray;
end;

procedure Tgoverlayform.tweaksLabelMouseEnter(Sender: TObject);
begin
  if tweaksLabel.Font.Color <> clWhite then
    tweaksLabel.Font.Color := LightenColor(tweaksLabel.Font.Color, 80);
end;

procedure Tgoverlayform.tweaksLabelMouseLeave(Sender: TObject);
begin
  if tweaksLabel.Font.Color <> clWhite then
    tweaksLabel.Font.Color := clGray;
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
    Name.StartsWith('eth') or   // Traditional Ethernet
    Name.StartsWith('enp') or   // Ethernet with modern names
    Name.StartsWith('wlan') or  // Traditional Wi-Fi
    Name.StartsWith('wlp');     // Wi-Fi with modern names
end;


//Procedure to list network interfaces
procedure GetNetworkInterfaces(ComboBox: TComboBox);
var
  AProcess: TProcess;
  Output: TStringList;
  Line, InterfaceName: String;
  SepPos: Integer;
  i: Integer;
  Interfaces: TStringList;
begin
  ComboBox.Items.Clear;

  // Use systemdetector to get network interfaces (automatically chooses method)
  Interfaces := systemdetector.GetNetworkInterfaces;
  try
    for i := 0 to Interfaces.Count - 1 do
      ComboBox.Items.Add(Interfaces[i]);
  finally
    Interfaces.Free;
  end;
end;




// Procedure to search for values in a checkbox
procedure LoadCheckgroup(const ACheckGroup: TCheckGroup; const AString: string);
var
  Values: TStringDynArray;
  i, j: Integer;
begin
  // Split string into substrings using comma as delimiter
  Values := SplitString(AUX, ',');

  // Iterate through each value in the string
  for i := Low(Values) to High(Values) do
  begin
    // Remove excess whitespace before and after the value
    Values[i] := Trim(Values[i]);

    // Iterate through all items in TCheckGroup
    for j := 0 to ACheckGroup.Items.Count - 1 do
    begin
      // Check if substring value equals item value
      if Values[i] = ACheckGroup.Items[j] then
      begin
        // Mark corresponding checkbox
        ACheckGroup.Checked[j] := True;
        // Can exit inner loop as match was already found for this value
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

procedure Tgoverlayform.TimerTimer(Sender: TObject);
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
      OffsetX := Sin((X * 0.01) + TimeElapsed * 0.5) + Sin((Y * 0.015) + TimeElapsed * 0.6);
      OffsetY := Cos((X * 0.015) - TimeElapsed * 0.4) + Cos((Y * 0.01) - TimeElapsed * 0.45);

      Factor := 0.3 + 0.35 * (OffsetX + 1) + 0.35 * (OffsetY + 1);
      if Factor > 1.0 then Factor := 1.0;
      if Factor < 0.3 then Factor := 0.3;

      R := Round(BaseR * Factor);
      G := Round(BaseG * Factor);
      B := Round(BaseB * Factor);

      // Define block rectangle, taking care not to exceed limits
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

//Functions for shaders

// List files from BaseDir directory in ListBox, optionally filtering by extensions.
// Ex.: FilterExts = []  -> list everything
//      FilterExts = ['.fx', '.fxh'] -> list only ReShade effects
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
            // skip hidden folders (.git, .github, etc.) if desired
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
    // Sort at the end (optional)
    // Note: if you want to keep natural hierarchy, comment out the line below.
    ListBox.Sorted := True;
  finally
    ListBox.Items.EndUpdate;
  end;
end;

procedure Tgoverlayform.LoadOptiScalerConfig;
var
  ConfigLines: TStringList;
  Line, TrimmedLine, Key, Value: string;
  i, ColonPos: Integer;
  FloatValue: Double;
  FS: TFormatSettings;
  OptiScalerIniPath: string;
begin
  // Get OptiScaler.ini file path
  OptiScalerIniPath := GetOptiScalerInstallPath + PathDelim + 'OptiScaler.ini';

  if not FileExists(OptiScalerIniPath) then
    Exit;

  ConfigLines := TStringList.Create;
  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';

  try
    ConfigLines.LoadFromFile(OptiScalerIniPath);

    for i := 0 to ConfigLines.Count - 1 do
    begin
      Line := ConfigLines[i];
      TrimmedLine := Trim(Line);

      // Ignore comments and empty lines
      if (TrimmedLine = '') or (TrimmedLine[1] = '#') or (TrimmedLine[1] = ';') then
        Continue;

      ColonPos := Pos('=', TrimmedLine);
      if ColonPos = 0 then
        Continue;

      Key := Trim(Copy(TrimmedLine, 1, ColonPos - 1));
      Value := Trim(Copy(TrimmedLine, ColonPos + 1, Length(TrimmedLine)));

      // Process each key
      if SameText(Key, 'ShortcutKey') then
      begin
        if SameText(Value, 'auto') then
          shortcutkeyComboBox.ItemIndex := 0
        else if SameText(Value, '0x70') then
          shortcutkeyComboBox.ItemIndex := 1
        else if SameText(Value, '0x71') then
          shortcutkeyComboBox.ItemIndex := 2
        else if SameText(Value, '0x72') then
          shortcutkeyComboBox.ItemIndex := 3
        else if SameText(Value, '0x73') then
          shortcutkeyComboBox.ItemIndex := 4;
      end
      else if SameText(Key, 'Scale') then
      begin
        if TryStrToFloat(Value, FloatValue, FS) then
        begin
          // Convert 0.5..2.0 -> 5..20
          menuscaleTrackBar.Position := Round(FloatValue * 10);
          menuscalevalueLabel.Caption := FormatFloat('#0.0', menuscaleTrackBar.Position / 10);
        end;
      end
      else if SameText(Key, 'OverrideNvapiDll') then
      begin
        overrideCheckBox.Checked := SameText(Value, 'true');
      end
      else if SameText(Key, 'LoadAsiPlugins') then
      begin
        optipatcherCheckBox.Checked := SameText(Value, 'true');
      end;
    end;

  finally
    ConfigLines.Free;
  end;
end;

procedure Tgoverlayform.LoadFakeNvapiConfig;
var
  ConfigLines: TStringList;
  Line, TrimmedLine, Key, Value: string;
  i, ColonPos: Integer;
  FakeNvapiIniPath: string;
begin
  // Get fakenvapi.ini file path
  FakeNvapiIniPath := GetOptiScalerInstallPath + PathDelim + 'fakenvapi.ini';

  if not FileExists(FakeNvapiIniPath) then
    Exit;

  ConfigLines := TStringList.Create;

  try
    ConfigLines.LoadFromFile(FakeNvapiIniPath);

    for i := 0 to ConfigLines.Count - 1 do
    begin
      Line := ConfigLines[i];
      TrimmedLine := Trim(Line);

      // Ignore comments and empty lines
      if (TrimmedLine = '') or (TrimmedLine[1] = '#') or (TrimmedLine[1] = ';') then
        Continue;

      ColonPos := Pos('=', TrimmedLine);
      if ColonPos = 0 then
        Continue;

      Key := Trim(Copy(TrimmedLine, 1, ColonPos - 1));
      Value := Trim(Copy(TrimmedLine, ColonPos + 1, Length(TrimmedLine)));

      // Process each key
      if SameText(Key, 'force_reflex') then
      begin
        if Value = '0' then
        begin
          forcereflexCheckBox.Checked := False;
          reflexComboBox.ItemIndex := 0; // Follow game setting
        end
        else
        begin
          forcereflexCheckBox.Checked := True;
          case Value of
            '1': reflexComboBox.ItemIndex := 1; // Force disable
            '2': reflexComboBox.ItemIndex := 2; // Force enable
          else
            reflexComboBox.ItemIndex := 0;
          end;
        end;
        reflexComboBox.Enabled := forcereflexCheckBox.Checked;
      end
      else if SameText(Key, 'force_latencyflex') then
      begin
        forcelatencyflexCheckBox.Checked := (Value = '1');
        latencyflexComboBox.Enabled := forcelatencyflexCheckBox.Checked;
      end
      else if SameText(Key, 'latencyflex_mode') then
      begin
        if forcelatencyflexCheckBox.Checked then
        begin
          case Value of
            '0': latencyflexComboBox.ItemIndex := 0; // Conservative
            '1': latencyflexComboBox.ItemIndex := 1; // Agressive
            '2': latencyflexComboBox.ItemIndex := 2; // Use reflex ids
          else
            latencyflexComboBox.ItemIndex := 0;
          end;
        end;
      end
      else if SameText(Key, 'enable_trace_logs') then
      begin
        tracelogCheckBox.Checked := (Value = '1');
      end;
    end;

  finally
    ConfigLines.Free;
  end;
end;

procedure Tgoverlayform.LoadFgmodConfig;
var
  ConfigLines: TStringList;
  Line, TrimmedLine, DllName: string;
  i: Integer;
  FgmodPath: string;
  DxilSpirvFound: Boolean;
begin
  // Get fgmod file path
  FgmodPath := GetOptiScalerInstallPath + PathDelim + 'fgmod';

  if not FileExists(FgmodPath) then
    Exit;

  ConfigLines := TStringList.Create;
  DxilSpirvFound := False;

  try
    ConfigLines.LoadFromFile(FgmodPath);

    for i := 0 to ConfigLines.Count - 1 do
    begin
      Line := ConfigLines[i];
      TrimmedLine := Trim(Line);

      // Search for line dll_name="${DLL:-
      if Pos('dll_name="${DLL:-', TrimmedLine) > 0 then
      begin
        // Extract DLL name
        // Format: dll_name="${DLL:-dxgi.dll}"
        DllName := Copy(TrimmedLine, Pos(':-', TrimmedLine) + 2, Length(TrimmedLine));
        DllName := Copy(DllName, 1, Pos('}"', DllName) - 1);

        // Set combobox index based on DLL name
        if SameText(DllName, 'dxgi.dll') then
          filenameComboBox.ItemIndex := 0
        else if SameText(DllName, 'version.dll') then
          filenameComboBox.ItemIndex := 1
        else if SameText(DllName, 'dbghelp.dll') then
          filenameComboBox.ItemIndex := 2
        else if SameText(DllName, 'd3d12.dll') then
          filenameComboBox.ItemIndex := 3
        else if SameText(DllName, 'wininet.dll') then
          filenameComboBox.ItemIndex := 4
        else if SameText(DllName, 'winhttp.dll') then
          filenameComboBox.ItemIndex := 5
        else if SameText(DllName, 'winmm.dll') then
          filenameComboBox.ItemIndex := 6
        else if SameText(DllName, 'OptiScaler.asi') then
          filenameComboBox.ItemIndex := 7
        else
          filenameComboBox.ItemIndex := 0; // Default: dxgi.dll
      end;

      // Check for DXIL_SPIRV_CONFIG line (emufp8 workaround)
      if Pos('export DXIL_SPIRV_CONFIG="wmma_rdna3_workaround"', TrimmedLine) > 0 then
        DxilSpirvFound := True;
    end;

    // Set emufp8CheckBox based on whether the line was found
    emufp8CheckBox.Checked := DxilSpirvFound;

  finally
    ConfigLines.Free;
  end;
end;

procedure Tgoverlayform.LoadMangoHudConfig;
var
  ConfigLines: TStringList;
  Line, TrimmedLine, Key, Value: string;
  i, j, ColonPos: Integer;
  FloatValue: Double;
  IntValue: Integer;
begin
  if not FileExists(MANGOHUDCFGFILE) then
    Exit;

  ConfigLines := TStringList.Create;
  try
    ConfigLines.LoadFromFile(MANGOHUDCFGFILE);

    for i := 0 to ConfigLines.Count - 1 do
    begin
      Line := ConfigLines[i];
      TrimmedLine := Trim(Line);

      // Ignore empty lines
      if TrimmedLine = '' then
        Continue;

      // Handle special commented line #offset=
      if (Length(TrimmedLine) > 8) and (Copy(TrimmedLine, 1, 8) = '#offset=') then
      begin
        if TryStrToInt(Copy(TrimmedLine, 9, Length(TrimmedLine)), IntValue) then
          offsetSpinedit.Value := IntValue;
        Continue;
      end;

      // Ignore other comments
      if TrimmedLine[1] = '#' then
        Continue;

      ColonPos := Pos('=', TrimmedLine);

      // Keys without value (boolean flags)
      if ColonPos = 0 then
      begin
        // Checkboxes that are only flags (no value)
        if SameText(TrimmedLine, 'horizontal') then
          horizontalRadioButton.Checked := True
        else if SameText(TrimmedLine, 'no_display') then
          hidehudCheckBox.Checked := True
        else if SameText(TrimmedLine, 'hud_compact') then
          hudcompactCheckBox.Checked := True
        else if SameText(TrimmedLine, 'fps') then
          fpsCheckBox.Checked := True
        else if SameText(TrimmedLine, 'frame_timing') then
          frametimegraphCheckBox.Checked := True
        else if SameText(TrimmedLine, 'show_fps_limit') then
          showfpslimCheckBox.Checked := True
        else if SameText(TrimmedLine, 'frame_count') then
          framecountCheckBox.Checked := True
        else if SameText(TrimmedLine, 'histogram') then
        begin
          frametimetypeBitBtn.ImageIndex := 7;
          frametimetypeBitBtn.Caption := 'Histogram';
        end
        else if SameText(TrimmedLine, 'gpu_stats') then
          gpuavgloadCheckBox.Checked := True
        else if SameText(TrimmedLine, 'gpu_load_change') then
          gpuloadcolorCheckBox.Checked := True
        else if SameText(TrimmedLine, 'vram') then
          vramusageCheckBox.Checked := True
        else if SameText(TrimmedLine, 'gpu_core_clock') then
          gpufreqCheckBox.Checked := True
        else if SameText(TrimmedLine, 'gpu_mem_clock') then
          gpumemfreqCheckBox.Checked := True
        else if SameText(TrimmedLine, 'gpu_temp') then
          gputempCheckBox.Checked := True
        else if SameText(TrimmedLine, 'gpu_mem_temp') then
          gpumemtempCheckBox.Checked := True
        else if SameText(TrimmedLine, 'gpu_junction_temp') then
          gpujunctempCheckBox.Checked := True
        else if SameText(TrimmedLine, 'gpu_fan') then
          gpufanCheckBox.Checked := True
        else if SameText(TrimmedLine, 'gpu_power') then
          gpupowerCheckBox.Checked := True
        else if SameText(TrimmedLine, 'gpu_power_limit') then
          gpupowerlimitCheckBox.Checked := True
        else if SameText(TrimmedLine, 'gpu_efficiency') then
          gpuefficiencyCheckBox.Checked := True
        else if SameText(TrimmedLine, 'flip_efficiency') then
        begin
          gpuframesjouleBitBtn.Caption := 'Joules / Frame';
          cpuframesjouleBitBtn.Caption := 'Joules / Frame';
        end
        else if SameText(TrimmedLine, 'gpu_voltage') then
          gpuvoltageCheckBox.Checked := True
        else if SameText(TrimmedLine, 'throttling_status') then
          gputhrottlingCheckBox.Checked := True
        else if SameText(TrimmedLine, 'throttling_status_graph') then
          gputhrottlinggraphCheckBox.Checked := True
        else if SameText(TrimmedLine, 'gpu_name') then
          gpumodelCheckBox.Checked := True
        else if SameText(TrimmedLine, 'vulkan_driver') then
          vulkandriverCheckBox.Checked := True
        else if SameText(TrimmedLine, 'cpu_stats') then
          cpuavgloadCheckBox.Checked := True
        else if SameText(TrimmedLine, 'cpu_load_change') then
          cpuloadcolorCheckBox.Checked := True
        else if SameText(TrimmedLine, 'core_load') then
          cpuloadcoreCheckBox.Checked := True
        else if SameText(TrimmedLine, 'core_bars') then
        begin
          coreloadtypeBitBtn.ImageIndex := 7;
          coreloadtypeBitBtn.Caption := 'Graph';
        end
        else if SameText(TrimmedLine, 'cpu_mhz') then
          cpufreqCheckBox.Checked := True
        else if SameText(TrimmedLine, 'cpu_temp') then
          cputempCheckBox.Checked := True
        else if SameText(TrimmedLine, 'cpu_power') then
          cpupowerCheckBox.Checked := True
        else if SameText(TrimmedLine, 'cpu_efficiency') then
          cpuefficiencyCheckBox.Checked := True
        else if SameText(TrimmedLine, 'core_type') then
          cpucoretypeCheckBox.Checked := True
        else if SameText(TrimmedLine, 'ram') then
          ramusageCheckBox.Checked := True
        else if SameText(TrimmedLine, 'io_read') then
          diskioCheckBox.Checked := True
        else if SameText(TrimmedLine, 'io_write') then
          diskioCheckBox.Checked := True
        else if SameText(TrimmedLine, 'procmem') then
          procmemCheckBox.Checked := True
        else if SameText(TrimmedLine, 'proc_vram') then
          procvramCheckBox.Checked := True
        else if SameText(TrimmedLine, 'swap') then
          swapusageCheckBox.Checked := True
        else if SameText(TrimmedLine, 'ram_temp') then
          ramtempCheckBox.Checked := True
        else if SameText(TrimmedLine, 'arch') then
          archCheckBox.Checked := True
        else if SameText(TrimmedLine, 'resolution') then
          resolutionCheckBox.Checked := True
        else if SameText(TrimmedLine, 'wine') then
          wineCheckBox.Checked := True
        else if SameText(TrimmedLine, 'engine_version') then
          engineversionCheckBox.Checked := True
        else if SameText(TrimmedLine, 'engine_short_names') then
          engineshortCheckBox.Checked := True
        else if SameText(TrimmedLine, 'gamemode') then
          gamemodestatusCheckBox.Checked := True
        else if SameText(TrimmedLine, 'vkbasalt') then
          vkbasaltstatusCheckBox.Checked := True
        else if SameText(TrimmedLine, 'fcat') then
          fcatCheckBox.Checked := True
        else if SameText(TrimmedLine, 'fex_stats') then
          fexstatsCheckBox.Checked := True
        else if SameText(TrimmedLine, 'fsr') then
          fsrCheckBox.Checked := True
        else if SameText(TrimmedLine, 'hdr') then
          hdrCheckBox.Checked := True
        else if SameText(TrimmedLine, 'refresh_rate') then
          refreshrateCheckBox.Checked := True
        else if SameText(TrimmedLine, 'battery') then
          batteryCheckBox.Checked := True
        else if SameText(TrimmedLine, 'battery_watt') then
          batterywattCheckBox.Checked := True
        else if SameText(TrimmedLine, 'battery_time') then
          batterytimeCheckBox.Checked := True
        else if SameText(TrimmedLine, 'media_player') then
          mediaCheckBox.Checked := True
        else if SameText(TrimmedLine, 'temp_fahrenheit') then
          fahrenheitCheckBox.Checked := True
        else if SameText(TrimmedLine, 'winesync') then
          winesyncCheckBox.Checked := True
        else if SameText(TrimmedLine, 'present_mode') then
          vpsCheckBox.Checked := True
        else if SameText(TrimmedLine, 'log_versioning') then
          versioningCheckBox.Checked := True
        else if SameText(TrimmedLine, 'upload_logs') then
          autouploadCheckBox.Checked := True
        else if SameText(TrimmedLine, 'fps_color_change') then
          fpscolorCheckBox.Checked := True
        else if SameText(TrimmedLine, 'bicubic') then
          filterRadioGroup.ItemIndex := 1
        else if SameText(TrimmedLine, 'trilinear') then
          filterRadioGroup.ItemIndex := 2
        else if SameText(TrimmedLine, 'retro') then
          filterRadioGroup.ItemIndex := 3
        // Display server
        else if SameText(TrimmedLine, 'display_server') then
          displayserverCheckBox.Checked := True
        // Special flags with # suffix (disabled in config but should be detected)
        else if SameText(TrimmedLine, 'time') then
          timeCheckBox.Checked := True
        else if SameText(TrimmedLine, 'time#') then
          timeCheckBox.Checked := True
        else if SameText(TrimmedLine, 'version#') then
          hudversionCheckBox.Checked := True;

        Continue;
      end;

      // Keys with value
      Key := Trim(Copy(TrimmedLine, 1, ColonPos - 1));
      Value := Trim(Copy(TrimmedLine, ColonPos + 1, Length(TrimmedLine)));

      // Remove quotes if present
      if (Length(Value) > 0) and (Value[1] = '"') then
        Value := StringReplace(Value, '"', '', [rfReplaceAll]);

      // ============= VISUAL TAB =============
      if SameText(Key, 'custom_text_center') then
        hudtitleEdit.Text := Value
      else if SameText(Key, 'background_alpha') then
      begin
        if TryStrToFloat(Value, FloatValue) then
        begin
          transpTrackBar.Position := Round(FloatValue * 10);
          alphavalueLabel.Caption := FormatFloat('#0.0', FloatValue);
        end;
      end
      else if SameText(Key, 'round_corners') then
      begin
        if TryStrToInt(Value, IntValue) then
        begin
          if IntValue = 0 then
            squareRadioButton.Checked := True
          else
            roundRadioButton.Checked := True;
        end;
      end
      else if SameText(Key, 'background_color') then
        hudbackgroundColorButton.ButtonColor := HexToColor(Value)
      else if SameText(Key, 'font_size') then
      begin
        if TryStrToInt(Value, IntValue) then
        begin
          fontsizeTrackBar.Position := IntValue;
          fontsizevalueLabel.Caption := IntToStr(IntValue);
        end;
      end
      else if SameText(Key, 'text_color') then
        fontColorButton.ButtonColor := HexToColor(Value)
      else if SameText(Key, 'font_file') then
      begin
        // Extract just the filename from the full path
        // e.g., /usr/share/fonts/Adwaita/AdwaitaSans-Italic.ttf -> AdwaitaSans-Italic.ttf
        fontComboBox.Text := ExtractFileName(Value);
      end
      else if SameText(Key, 'position') then
      begin
        if SameText(Value, 'top-left') then
          topleftRadioButton.Checked := True
        else if SameText(Value, 'top-center') then
          topcenterRadioButton.Checked := True
        else if SameText(Value, 'top-right') then
          toprightRadioButton.Checked := True
        else if SameText(Value, 'middle-left') then
          middleleftRadioButton.Checked := True
        else if SameText(Value, 'middle-right') then
          middlerightRadioButton.Checked := True
        else if SameText(Value, 'bottom-left') then
          bottomleftRadioButton.Checked := True
        else if SameText(Value, 'bottom-center') then
          bottomcenterRadioButton.Checked := True
        else if SameText(Value, 'bottom-right') then
          bottomrightRadioButton.Checked := True;
      end
      else if SameText(Key, 'offset_x') then
      begin
        if TryStrToInt(Value, IntValue) then
          offsetxSpinEdit.Value := IntValue;
      end
      else if SameText(Key, 'offset_y') then
      begin
        if TryStrToInt(Value, IntValue) then
          offsetySpinEdit.Value := IntValue;
      end
      else if SameText(Key, 'toggle_hud') then
      begin
        if SameText(Value, 'Shift_R+F12') then
          hudonoffComboBox.ItemIndex := 0
        else if SameText(Value, 'Shift_R+F1') then
          hudonoffComboBox.ItemIndex := 1
        else if SameText(Value, 'Shift_R+F2') then
          hudonoffComboBox.ItemIndex := 2
        else if SameText(Value, 'Shift_R+F3') then
          hudonoffComboBox.ItemIndex := 3
        else if SameText(Value, 'Shift_R+F4') then
          hudonoffComboBox.ItemIndex := 4
        else
          hudonoffComboBox.ItemIndex := 5;
      end
      else if SameText(Key, 'table_columns') then
      begin
        if TryStrToInt(Value, IntValue) then
        begin
          columvalueLabel.Caption := Value;
          case IntValue of
            1: begin
              columShape.Visible := True;
              columShape1.Visible := False;
              columShape2.Visible := False;
              columShape3.Visible := False;
              columShape4.Visible := False;
              columShape5.Visible := False;
            end;
            2: begin
              columShape.Visible := True;
              columShape1.Visible := True;
              columShape2.Visible := False;
              columShape3.Visible := False;
              columShape4.Visible := False;
              columShape5.Visible := False;
            end;
            3: begin
              columShape.Visible := True;
              columShape1.Visible := True;
              columShape2.Visible := True;
              columShape3.Visible := False;
              columShape4.Visible := False;
              columShape5.Visible := False;
            end;
            4: begin
              columShape.Visible := True;
              columShape1.Visible := True;
              columShape2.Visible := True;
              columShape3.Visible := True;
              columShape4.Visible := False;
              columShape5.Visible := False;
            end;
            5: begin
              columShape.Visible := True;
              columShape1.Visible := True;
              columShape2.Visible := True;
              columShape3.Visible := True;
              columShape4.Visible := True;
              columShape5.Visible := False;
            end;
            6: begin
              columShape.Visible := True;
              columShape1.Visible := True;
              columShape2.Visible := True;
              columShape3.Visible := True;
              columShape4.Visible := True;
              columShape5.Visible := True;
            end;
          end;
        end;
      end

      // ============= METRICS TAB =============
      else if SameText(Key, 'gpu_text') then
        gpunameEdit.Text := Value
      else if SameText(Key, 'gpu_color') then
        gpuColorButton.ButtonColor := HexToColor(Value)
      else if SameText(Key, 'cpu_text') then
        cpunameEdit.Text := Value
      else if SameText(Key, 'cpu_color') then
        cpuColorButton.ButtonColor := HexToColor(Value)
      else if SameText(Key, 'vram_color') then
        vramColorButton.ButtonColor := HexToColor(Value)
      else if SameText(Key, 'ram_color') then
        ramColorButton.ButtonColor := HexToColor(Value)
      else if SameText(Key, 'io_color') then
        iordrwColorButton.ButtonColor := HexToColor(Value)
      else if SameText(Key, 'frametime_color') then
        frametimegraphColorButton.ButtonColor := HexToColor(Value)
      else if SameText(Key, 'gpu_load_value') then
        // Ignore for now, already handled by gpu_load_change
      else if SameText(Key, 'gpu_load_color') then
      begin
        // Parse comma-separated colors
        // Example: "00FF00,FFFF00,FF0000"
        // Simplified implementation
      end
      else if SameText(Key, 'cpu_load_value') then
        // Ignore for now
      else if SameText(Key, 'cpu_load_color') then
        // Ignore for now

      // ============= PERFORMANCE TAB =============
      else if SameText(Key, 'fps_limit_method') then
      begin
        if SameText(Value, 'late') then
          fpslimmetComboBox.ItemIndex := 0
        else if SameText(Value, 'early') then
          fpslimmetComboBox.ItemIndex := 1;
      end
      else if SameText(Key, 'toggle_fps_limit') then
      begin
        if SameText(Value, 'Shift_L+F1') then
          fpslimtoggleComboBox.ItemIndex := 0
        else if SameText(Value, 'Shift_L+F2') then
          fpslimtoggleComboBox.ItemIndex := 1
        else if SameText(Value, 'Shift_L+F3') then
          fpslimtoggleComboBox.ItemIndex := 2
        else if SameText(Value, 'Shift_L+F4') then
          fpslimtoggleComboBox.ItemIndex := 3
        else
          fpslimtoggleComboBox.ItemIndex := 4;
      end
      else if SameText(Key, 'vsync') then
      begin
        if TryStrToInt(Value, IntValue) then
          vsyncComboBox.ItemIndex := IntValue;
      end
      else if SameText(Key, 'gl_vsync') then
      begin
        if SameText(Value, '-1') then
          glvsyncComboBox.ItemIndex := 0
        else if SameText(Value, '0') then
          glvsyncComboBox.ItemIndex := 1
        else if SameText(Value, '1') then
          glvsyncComboBox.ItemIndex := 2
        else if SameText(Value, 'n') then
          glvsyncComboBox.ItemIndex := 3;
      end
      else if SameText(Key, 'af') then
      begin
        if TryStrToInt(Value, IntValue) then
        begin
          afTrackBar.Position := IntValue;
          afvalueLabel.Caption := IntToStr(IntValue);
        end;
      end
      else if SameText(Key, 'picmip') then
      begin
        if TryStrToInt(Value, IntValue) then
        begin
          mipmapTrackBar.Position := IntValue;
          mipmapvalueLabel.Caption := IntToStr(IntValue);
        end;
      end
      else if SameText(Key, 'fps_limit') then
      begin
        // Parse FPS limits (can be comma-separated list)
        // Simplified implementation - only shows if there's a limit
      end
      else if SameText(Key, 'fps_color_change') then
        fpscolorCheckBox.Checked := True
      else if SameText(Key, 'fps_color') then
        // Parse FPS colors (format: color1,color2,color3)
      else if SameText(Key, 'fps_value') then
        // Parse FPS threshold values

      // ============= EXTRAS TAB =============
      else if SameText(Key, 'wine_color') then
        wineColorButton.ButtonColor := HexToColor(Value)
      else if SameText(Key, 'engine_color') then
        engineColorButton.ButtonColor := HexToColor(Value)
      else if SameText(Key, 'battery_color') then
        batteryColorButton.ButtonColor := HexToColor(Value)
      else if SameText(Key, 'media_player_color') then
        mediaColorButton.ButtonColor := HexToColor(Value)
      else if SameText(Key, 'device_battery') then
        deviceCheckBox.Checked := True
      else if SameText(Key, 'output_folder') then
        logfolderEdit.Text := Value
      else if SameText(Key, 'log_duration') then
      begin
        if TryStrToInt(Value, IntValue) then
        begin
          durationTrackBar.Position := IntValue;
          durationvalueLabel.Caption := IntToStr(IntValue) + 's';
        end;
      end
      else if SameText(Key, 'autostart_log') then
      begin
        if TryStrToInt(Value, IntValue) then
        begin
          delayTrackBar.Position := IntValue;
          delayvalueLabel.Caption := IntToStr(IntValue) + 's';
        end;
      end
      else if SameText(Key, 'log_interval') then
      begin
        if TryStrToInt(Value, IntValue) then
        begin
          intervalTrackBar.Position := IntValue;
          intervalvalueLabel.Caption := IntToStr(IntValue) + 'ms';
        end;
      end
      else if SameText(Key, 'toggle_logging') then
      begin
        if SameText(Value, 'Shift_L+F2') then
          logtoggleComboBox.ItemIndex := 0
        else if SameText(Value, 'Shift_L+F3') then
          logtoggleComboBox.ItemIndex := 1
        else if SameText(Value, 'Shift_L+F4') then
          logtoggleComboBox.ItemIndex := 2
        else if SameText(Value, 'Shift_L+F5') then
          logtoggleComboBox.ItemIndex := 3
        else
          logtoggleComboBox.ItemIndex := 4;
      end
      else if SameText(Key, 'fps_metrics') then
      begin
        if Pos('0.01', Value) > 0 then
        begin
          fpsavgCheckBox.Checked := True;
          fpsavgBitBtn.ImageIndex := 9;
          fpsavgBitBtn.Caption := '1% low';
        end
        else if Pos('0.001', Value) > 0 then
        begin
          fpsavgCheckBox.Checked := True;
          fpsavgBitBtn.ImageIndex := 10;
          fpsavgBitBtn.Caption := '0.1% low';
        end;
      end
      // Network: network=<interface>
      else if SameText(Key, 'network') then
      begin
        networkCheckBox.Checked := True;
        // Also set the interface in the combo box if found
        if Value <> '' then
        begin
          // Reset ItemIndex before searching to ensure proper detection
          networkComboBox.ItemIndex := -1;
          for j := 0 to networkComboBox.Items.Count - 1 do
          begin
            if SameText(networkComboBox.Items[j], Value) then
            begin
              networkComboBox.ItemIndex := j;
              Break;
            end;
          end;
          // If not found in list, add it and select it
          if networkComboBox.ItemIndex = -1 then
          begin
            networkComboBox.Items.Add(Value);
            networkComboBox.ItemIndex := networkComboBox.Items.Count - 1;
          end;
        end;
      end;

      // Check exec= lines for distro patterns
      if SameText(Key, 'exec') then
      begin
        // Distro info: exec=cat .../goverlay/distro or exec=uname -r
        if (Pos('uname -r', Value) > 0) or (Pos('goverlay/distro', Value) > 0) then
          distroinfoCheckBox.Checked := True;
      end;
    end;

  finally
    ConfigLines.Free;
  end;
end;

procedure Tgoverlayform.SaveMangoHudConfig;
var
  ConfigLines: TStringList;
  ConfigDir, FontPath, FontDir, DistroFile: string;
  FlatpakSteamConfigDir, FlatpakMangoHudFile: string;
  SelectedValues: TStringList;
  i,TempFPS, MaxFPS: Integer;
  TempFiles, FontDirs: TStringList;
  TempFile: string;
  FS: TFormatSettings;

  // Helper procedure to add a line if checkbox is checked
  procedure AddIfChecked(ACheckBox: TCheckBox; const ALine: string);
  begin
    if ACheckBox.Checked then
      ConfigLines.Add(ALine);
  end;

  // Helper procedure to add a key=value line if checkbox is checked
  procedure AddValueIfChecked(ACheckBox: TCheckBox; const AKey, AValue: string);
  begin
    if ACheckBox.Checked then
      ConfigLines.Add(AKey + '=' + AValue);
  end;

begin
  // Use XDG-compliant path with proper Flatpak support (HOST_XDG_CONFIG_HOME)
  ConfigDir := GetMangoHudConfigDir();

  // Create directory if it doesn't exist (use CreateHostDirectory for Flatpak compatibility)
  if not DirectoryExists(ConfigDir) then
    CreateHostDirectory(ConfigDir);

  ConfigLines := TStringList.Create;
  try
    // File header
    ConfigLines.Add('################### File Generated by Goverlay ' + GVERSION + ' ' + GCHANNEL + ' ###################');
    ConfigLines.Add('legacy_layout=0');
    ConfigLines.Add('');

    // ============= VISUAL TAB =============

    // HUD Title
    if hudtitleEdit.Text <> '' then
      ConfigLines.Add('custom_text_center=' + hudtitleEdit.Text);

    // Orientation
    if horizontalRadioButton.Checked then
      ConfigLines.Add('horizontal');

    // Background alpha
    ConfigLines.Add('background_alpha=' + FormatFloat('0.0', transpTrackBar.Position / 10));

    // Border type (round corners)
    if roundRadioButton.Checked then
      ConfigLines.Add('round_corners=10')
    else
      ConfigLines.Add('round_corners=0');

    // Background color
    ConfigLines.Add('background_color=' + ColorToHTMLColor(hudbackgroundColorButton.ButtonColor));

    // Font file
    if fontComboBox.ItemIndex > 0 then
    begin
      // Search in all standard font directories (including Flatpak)
      FontDirs := GetStandardFontDirectories;
      try
        for FontDir in FontDirs do
        begin
          if DirectoryExists(FontDir) then
          begin
            // fontComboBox.Text already includes .ttf extension
            TempFiles := FindAllFiles(FontDir, fontComboBox.Text, True);
            try
              if TempFiles.Count > 0 then
              begin
                FontPath := TempFiles[0];
                ConfigLines.Add('font_file=' + FontPath);
                Break; // Found the font, stop searching
              end;
            finally
              TempFiles.Free;
            end;
          end;
        end;
      finally
        FontDirs.Free;
      end;
    end;

    // Font size
    ConfigLines.Add('font_size=' + IntToStr(fontsizeTrackBar.Position));

    // Font color
    ConfigLines.Add('text_color=' + ColorToHTMLColor(fontColorButton.ButtonColor));

    // Position
    if topleftRadioButton.Checked then
      ConfigLines.Add('position=top-left')
    else if topcenterRadioButton.Checked then
      ConfigLines.Add('position=top-center')
    else if toprightRadioButton.Checked then
      ConfigLines.Add('position=top-right')
    else if middleleftRadioButton.Checked then
      ConfigLines.Add('position=middle-left')
    else if middlerightRadioButton.Checked then
      ConfigLines.Add('position=middle-right')
    else if bottomleftRadioButton.Checked then
      ConfigLines.Add('position=bottom-left')
    else if bottomcenterRadioButton.Checked then
      ConfigLines.Add('position=bottom-center')
    else if bottomrightRadioButton.Checked then
      ConfigLines.Add('position=bottom-right');

    // Offset X / Y
    if offsetxSpinEdit.Value <> 0 then
      ConfigLines.Add('offset_x=' + IntToStr(offsetxSpinEdit.Value));
    if offsetySpinEdit.Value <> 0 then
      ConfigLines.Add('offset_y=' + IntToStr(offsetySpinEdit.Value));

    // Toggle HUD
    case hudonoffComboBox.ItemIndex of
      0: ConfigLines.Add('toggle_hud=Shift_R+F12');
      1: ConfigLines.Add('toggle_hud=Shift_R+F1');
      2: ConfigLines.Add('toggle_hud=Shift_R+F2');
      3: ConfigLines.Add('toggle_hud=Shift_R+F3');
      4: ConfigLines.Add('toggle_hud=Shift_R+F4');
      5: ConfigLines.Add('toggle_hud=none');
    end;

    // Hide HUD
    AddIfChecked(hidehudCheckBox, 'no_display');

    // HUD compact
    AddIfChecked(hudcompactCheckBox, 'hud_compact');

    // PCI device and GPU List logic
    if pcidevComboBox.ItemIndex <> -1 then
    begin
      // Check if "Use both GPUs" is selected
      if pcidevComboBox.Items[pcidevComboBox.ItemIndex] = 'Use both GPUs' then
      begin
        ConfigLines.Add('gpu_list=0,1');
      end
      else
      begin
        // Write gpu_list based on index (pci_dev is no longer needed)
        if pcidevComboBox.ItemIndex = 0 then
             ConfigLines.Add('gpu_list=0')
        else if pcidevComboBox.ItemIndex = 1 then
             ConfigLines.Add('gpu_list=1')
        else
             ConfigLines.Add('gpu_list=' + IntToStr(pcidevComboBox.ItemIndex));
      end;
    end;

    // Table columns
    ConfigLines.Add('table_columns=' + columvalueLabel.Caption);

    // ============= METRICS TAB - GPU =============

    // GPU text
    if gpunameEdit.Text <> '' then
      ConfigLines.Add('gpu_text=' + gpunameEdit.Text);

    // GPU stats
    AddIfChecked(gpuavgloadCheckBox, 'gpu_stats');

    // GPU load color change
    if gpuloadcolorCheckBox.Checked then
    begin
      ConfigLines.Add('gpu_load_change');
      ConfigLines.Add('gpu_load_value=50,90');
      ConfigLines.Add('gpu_load_color=' + ColorToHTMLColor(gpuload1ColorButton.ButtonColor) + ',' +
                      ColorToHTMLColor(gpuload2ColorButton.ButtonColor) + ',' +
                      ColorToHTMLColor(gpuload3ColorButton.ButtonColor));
    end;

    // VRAM
    AddIfChecked(vramusageCheckBox, 'vram');
    if vramusageCheckBox.Checked then
      ConfigLines.Add('vram_color=' + ColorToHTMLColor(vramColorButton.ButtonColor));

    // GPU frequency
    AddIfChecked(gpufreqCheckBox, 'gpu_core_clock');

    // GPU memory frequency
    AddIfChecked(gpumemfreqCheckBox, 'gpu_mem_clock');

    // GPU temperatures
    AddIfChecked(gputempCheckBox, 'gpu_temp');
    AddIfChecked(gpumemtempCheckBox, 'gpu_mem_temp');
    AddIfChecked(gpujunctempCheckBox, 'gpu_junction_temp');

    // GPU fan
    AddIfChecked(gpufanCheckBox, 'gpu_fan');

    // GPU power
    AddIfChecked(gpupowerCheckBox, 'gpu_power');

    // GPU power limit
    AddIfChecked(gpupowerlimitCheckBox, 'gpu_power_limit');

    // GPU efficiency
    AddIfChecked(gpuefficiencyCheckBox, 'gpu_efficiency');

    // Flip efficiency (Joules / Frame mode)
    if gpuframesjouleBitBtn.Caption = 'Joules / Frame' then
      ConfigLines.Add('flip_efficiency');

    // GPU voltage
    AddIfChecked(gpuvoltageCheckBox, 'gpu_voltage');

    // GPU throttling
    AddIfChecked(gputhrottlingCheckBox, 'throttling_status');
    AddIfChecked(gputhrottlinggraphCheckBox, 'throttling_status_graph');

    // GPU model
    AddIfChecked(gpumodelCheckBox, 'gpu_name');

    // Vulkan driver
    AddIfChecked(vulkandriverCheckBox, 'vulkan_driver');

    // GPU color
    if gpuavgloadCheckBox.Checked then
      ConfigLines.Add('gpu_color=' + ColorToHTMLColor(gpuColorButton.ButtonColor));

    // ============= METRICS TAB - CPU =============

    // CPU text
    if cpunameEdit.Text <> '' then
      ConfigLines.Add('cpu_text=' + cpunameEdit.Text);

    // CPU stats
    AddIfChecked(cpuavgloadCheckBox, 'cpu_stats');

    // CPU core load
    AddIfChecked(cpuloadcoreCheckBox, 'core_load');

    // Core load type (bars)
    if coreloadtypeBitBtn.Caption = 'Graph' then
      ConfigLines.Add('core_bars');

    // CPU load color change
    if cpuloadcolorCheckBox.Checked then
    begin
      ConfigLines.Add('cpu_load_change');
      ConfigLines.Add('cpu_load_value=50,90');
      ConfigLines.Add('cpu_load_color=' + ColorToHTMLColor(cpuload1ColorButton.ButtonColor) + ',' +
                      ColorToHTMLColor(cpuload2ColorButton.ButtonColor) + ',' +
                      ColorToHTMLColor(cpuload3ColorButton.ButtonColor));
    end;

    // CPU frequency
    AddIfChecked(cpufreqCheckBox, 'cpu_mhz');

    // CPU temperature
    AddIfChecked(cputempCheckBox, 'cpu_temp');

    // CPU power
    AddIfChecked(cpupowerCheckBox, 'cpu_power');

    // CPU efficiency
    AddIfChecked(cpuefficiencyCheckBox, 'cpu_efficiency');

    // CPU core type
    AddIfChecked(cpucoretypeCheckBox, 'core_type');

    // CPU color
    if cpuavgloadCheckBox.Checked then
      ConfigLines.Add('cpu_color=' + ColorToHTMLColor(cpuColorButton.ButtonColor));

    // ============= METRICS TAB - MEMORY/IO =============

    // I/O stats
    if diskioCheckBox.Checked then
    begin
      ConfigLines.Add('io_read');
      ConfigLines.Add('io_write');
      ConfigLines.Add('io_color=' + ColorToHTMLColor(iordrwColorButton.ButtonColor));
    end;

    // Swap
    AddIfChecked(swapusageCheckBox, 'swap');

    // RAM
    if ramusageCheckBox.Checked then
    begin
      ConfigLines.Add('ram');
      ConfigLines.Add('ram_color=' + ColorToHTMLColor(ramColorButton.ButtonColor));
    end;

    // RAM temperature
    AddIfChecked(ramtempCheckBox, 'ram_temp');

    // Process memory
    AddIfChecked(procmemCheckBox, 'procmem');

    // Process VRAM
    AddIfChecked(procvramCheckBox, 'proc_vram');

    // ============= METRICS TAB - OTHER =============

    // Battery
    if batteryCheckBox.Checked then
    begin
      ConfigLines.Add('battery');
      ConfigLines.Add('battery_color=' + ColorToHTMLColor(batteryColorButton.ButtonColor));
    end;
    AddIfChecked(batterywattCheckBox, 'battery_watt');
    AddIfChecked(batterytimeCheckBox, 'battery_time');

    // Device battery
    if deviceCheckBox.Checked then
    begin
      ConfigLines.Add('device_battery=gamepad');
      ConfigLines.Add('device_battery_icon');
    end;

    // FPS
    AddIfChecked(fpsCheckBox, 'fps');

    // FPS metrics (avg)
    if fpsavgCheckBox.Checked then
    begin
      if fpsavgBitBtn.Caption = '1% low' then
        ConfigLines.Add('fps_metrics=avg,0.01')
      else
        ConfigLines.Add('fps_metrics=avg,0.001');
    end;

    // Frame timing
    if frametimegraphCheckBox.Checked then
    begin
      ConfigLines.Add('frame_timing');
      ConfigLines.Add('frametime_color=' + ColorToHTMLColor(frametimegraphColorButton.ButtonColor));
    end;

    // Histogram
    if frametimetypeBitBtn.Caption = 'Histogram' then
      ConfigLines.Add('histogram');

    // Frame count
    AddIfChecked(framecountCheckBox, 'frame_count');

    // Engine
    if engineversionCheckBox.Checked then
    begin
      ConfigLines.Add('engine_version');
      ConfigLines.Add('engine_color=' + ColorToHTMLColor(engineColorButton.ButtonColor));
    end;
    AddIfChecked(engineshortCheckBox, 'engine_short_names');

    // Arch
    AddIfChecked(archCheckBox, 'arch');

    // Wine
    if wineCheckBox.Checked then
    begin
      ConfigLines.Add('wine');
      ConfigLines.Add('wine_color=' + ColorToHTMLColor(wineColorButton.ButtonColor));
    end;

    // Winesync
    AddIfChecked(winesyncCheckBox, 'winesync');

    // ============= PERFORMANCE TAB =============

    // Show FPS limit
    AddIfChecked(showfpslimCheckBox, 'show_fps_limit');

    // FPS limit method
    case fpslimmetComboBox.ItemIndex of
      0: ConfigLines.Add('fps_limit_method=late');
      1: ConfigLines.Add('fps_limit_method=early');
    end;

    // FPS limit toggle
    case fpslimtoggleComboBox.ItemIndex of
      0: ConfigLines.Add('toggle_fps_limit=Shift_L+F1');
      1: ConfigLines.Add('toggle_fps_limit=Shift_L+F2');
      2: ConfigLines.Add('toggle_fps_limit=Shift_L+F3');
      3: ConfigLines.Add('toggle_fps_limit=Shift_L+F4');
    end;

    // FPS limits (from checkgroup)
    SelectedValues := TStringList.Create;
    try
      MaxFPS := 0;
      for i := 0 to fpslimcheckgroup.Items.Count - 1 do
      begin
        if fpslimcheckgroup.Checked[i] then
        begin
          TempFPS := StrToIntDef(fpslimcheckgroup.Items[i], 0);
          if TempFPS <> 0 then
            TempFPS := TempFPS + offsetSpinedit.Value;
          SelectedValues.Add(IntToStr(TempFPS));
          if StrToIntDef(fpslimcheckgroup.Items[i], 0) > MaxFPS then
            MaxFPS := StrToIntDef(fpslimcheckgroup.Items[i], 0);
        end;
      end;
      if SelectedValues.Count > 0 then
        ConfigLines.Add('fps_limit=' + SelectedValues.CommaText)
      else
        ConfigLines.Add('fps_limit=0');
    finally
      SelectedValues.Free;
    end;

    // Offset
    ConfigLines.Add('#offset=' + IntToStr(offsetSpinedit.Value));

    // Resolution
    AddIfChecked(resolutionCheckBox, 'resolution');

    // Refresh rate
    AddIfChecked(refreshrateCheckBox, 'refresh_rate');

    // FCAT
    AddIfChecked(fcatCheckBox, 'fcat');

    // FEX Stats
    AddIfChecked(fexstatsCheckBox, 'fex_stats');

    // FSR
    AddIfChecked(fsrCheckBox, 'fsr');

    // HDR
    AddIfChecked(hdrCheckBox, 'hdr');

    // VPS (present mode)
    AddIfChecked(vpsCheckBox, 'present_mode');

    // Fahrenheit
    AddIfChecked(fahrenheitCheckBox, 'temp_fahrenheit');

    // Gamemode
    AddIfChecked(gamemodestatusCheckBox, 'gamemode');

    // vkBasalt status
    AddIfChecked(vkbasaltstatusCheckBox, 'vkbasalt');

    // VSync
    case vsyncComboBox.ItemIndex of
      0: ConfigLines.Add('vsync=0');
      1: ConfigLines.Add('vsync=1');
      2: ConfigLines.Add('vsync=2');
      3: ConfigLines.Add('vsync=3');
      4: ConfigLines.Add('vsync=4');
    end;

    // GL VSync
    case glvsyncComboBox.ItemIndex of
      0: ConfigLines.Add('gl_vsync=-1');
      1: ConfigLines.Add('gl_vsync=0');
      2: ConfigLines.Add('gl_vsync=1');
      3: ConfigLines.Add('gl_vsync=n');
    end;

    // Filters
    case filterRadioGroup.ItemIndex of
      1: ConfigLines.Add('bicubic');
      2: ConfigLines.Add('trilinear');
      3: ConfigLines.Add('retro');
    end;

    // AF filter
    if afTrackBar.Position > 0 then
      ConfigLines.Add('af=' + IntToStr(afTrackBar.Position));

    // Mipmap filter
    if mipmapTrackBar.Position > 0 then
      ConfigLines.Add('picmip=' + IntToStr(mipmapTrackBar.Position));

    // FPS color change
    if fpscolorCheckBox.Checked then
    begin
      ConfigLines.Add('fps_color_change');
      ConfigLines.Add('fps_color=' + ColorToHTMLColor(fpscolor1ColorButton.ButtonColor) + ',' +
                      ColorToHTMLColor(fpscolor2ColorButton.ButtonColor) + ',' +
                      ColorToHTMLColor(fpscolor3ColorButton.ButtonColor));
      ConfigLines.Add('fps_value=' + IntToStr(fpscolor2SpinEdit.Value) + ',' + IntToStr(fpscolor3SpinEdit.Value));
    end;

    // ============= EXTRAS TAB =============

    // Distro info
    if distroinfoCheckBox.Checked then
    begin
      DistroFile := GetUserConfigDir + '/goverlay/distro';
      ConfigLines.Add('custom_text=-');
      ConfigLines.Add('exec=cat ' + DistroFile);
      ConfigLines.Add('custom_text=-');
      ConfigLines.Add('exec=uname -r');
    end;

    // Display server
    AddIfChecked(displayserverCheckBox, 'display_server');

    // Time
    if timeCheckBox.Checked then
    begin
      ConfigLines.Add('time');
      ConfigLines.Add('time_no_label');
    end;

    // HUD version
    AddIfChecked(hudversionCheckBox, 'version#');

    // Media player
    if mediaCheckBox.Checked then
    begin
      ConfigLines.Add('media_player');
      ConfigLines.Add('media_player_color=' + ColorToHTMLColor(mediaColorButton.ButtonColor));
    end;

    // Network
    if networkCheckBox.Checked and (networkComboBox.ItemIndex <> -1) then
      ConfigLines.Add('network=' + networkComboBox.Items[networkComboBox.ItemIndex]);

    // Log folder (XDG-compliant data directory)
    if logfolderEdit.Text <> '' then
      ConfigLines.Add('output_folder=' + logfolderEdit.Text);

    // Log duration
    if durationTrackBar.Position > 0 then
      ConfigLines.Add('log_duration=' + IntToStr(durationTrackBar.Position));

    // Log delay (autostart)
    if delayTrackBar.Position > 0 then
      ConfigLines.Add('autostart_log=' + IntToStr(delayTrackBar.Position));

    // Log interval
    if intervalTrackBar.Position > 0 then
      ConfigLines.Add('log_interval=' + IntToStr(intervalTrackBar.Position));

    // Log toggle
    case logtoggleComboBox.ItemIndex of
      0: ConfigLines.Add('toggle_logging=Shift_L+F2');
      1: ConfigLines.Add('toggle_logging=Shift_L+F3');
      2: ConfigLines.Add('toggle_logging=Shift_L+F4');
      3: ConfigLines.Add('toggle_logging=Shift_L+F5');
      4: ConfigLines.Add('toggle_logging=');  // None - disable toggle key
    end;

    // Log versioning
    AddIfChecked(versioningCheckBox, 'log_versioning');

    // Auto upload
    AddIfChecked(autouploadCheckBox, 'upload_logs');

    // Save to native MangoHud config file
    ConfigLines.SaveToFile(MANGOHUDCFGFILE);

    // Also save to Steam Flatpak MangoHud config location
    // This ensures MangoHud works for both native and Flatpak Steam games
    try
      FlatpakSteamConfigDir := GetUserDir + '.var/app/com.valvesoftware.Steam/config/MangoHud';
      FlatpakMangoHudFile := FlatpakSteamConfigDir + '/MangoHud.conf';

      // Create Flatpak directory if it doesn't exist
      if not DirectoryExists(FlatpakSteamConfigDir) then
        ForceDirectories(FlatpakSteamConfigDir);

      // Save the same configuration to Flatpak location
      ConfigLines.SaveToFile(FlatpakMangoHudFile);
      WriteLn('[DEBUG] SaveMangoHudConfig: Configuration also saved to Steam Flatpak location: ', FlatpakMangoHudFile);
    except
      on E: Exception do
        WriteLn('[WARN] SaveMangoHudConfig: Could not save to Steam Flatpak location: ', E.Message);
    end;

  finally
    ConfigLines.Free;
  end;
end;

procedure Tgoverlayform.LoadVkBasaltConfig;
var
  ConfigLines: TStringList;
  Line, TrimmedLine, Key, Value, EffectsStr, FullEffectPath: string;
  EffectsList: TStringArray;
  i, j, k, ColonPos: Integer;
  FloatValue: Double;
  FS: TFormatSettings;
begin
  if not FileExists(VKBASALTCFGFILE) then
    Exit;

  ConfigLines := TStringList.Create;
  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';

  try
    ConfigLines.LoadFromFile(VKBASALTCFGFILE);

    // Clear active effects list
    acteffectsListBox.Items.Clear;

    for i := 0 to ConfigLines.Count - 1 do
    begin
      Line := ConfigLines[i];
      TrimmedLine := Trim(Line);

      // Ignore comments and empty lines
      if (TrimmedLine = '') or (TrimmedLine[1] = '#') then
        Continue;

      ColonPos := Pos('=', TrimmedLine);
      if ColonPos = 0 then
        Continue;

      Key := Trim(Copy(TrimmedLine, 1, ColonPos - 1));
      Value := Trim(Copy(TrimmedLine, ColonPos + 1, Length(TrimmedLine)));

      // Remove quotes if present
      if (Length(Value) > 0) and (Value[1] = '"') then
        Value := StringReplace(Value, '"', '', [rfReplaceAll]);

      // Process each key
      if SameText(Key, 'effects') then
      begin
        // Parse effects list (separated by :)
        EffectsStr := Value;
        EffectsList := SplitString(EffectsStr, ':');

        for j := Low(EffectsList) to High(EffectsList) do  // <-- Use j instead of i
        begin
          EffectsList[j] := Trim(EffectsList[j]);

          // CAS, FXAA, SMAA and DLS are handled by trackbars, not by the list
          if SameText(EffectsList[j], 'cas') then
          begin
            if casTrackBar.Position = 0 then
              casTrackBar.Position := 0; // default value
          end
          else if SameText(EffectsList[j], 'fxaa') then
          begin
            if fxaaTrackBar.Position = 0 then
              fxaaTrackBar.Position := 5; // default value
          end
          else if SameText(EffectsList[j], 'smaa') then
          begin
            if smaaTrackBar.Position = 0 then
              smaaTrackBar.Position := 5; // default value
          end
          else if SameText(EffectsList[j], 'dls') then
          begin
            if dlsTrackBar.Position = 0 then
              dlsTrackBar.Position := 5; // default value
          end
          else if EffectsList[j] <> '' then
          begin
            // It's a custom reshade effect
            // Find full path in aveffectsListbox (e.g., "ASCII" -> "Shaders/ASCII.fx")
            FullEffectPath := '';
            for k := 0 to aveffectsListbox.Items.Count - 1 do
            begin
              // Extract effect name from path (e.g., "Shaders/ASCII.fx" -> "ASCII")
              if SameText(ChangeFileExt(ExtractFileName(aveffectsListbox.Items[k]), ''), EffectsList[j]) then
              begin
                FullEffectPath := aveffectsListbox.Items[k];
                Break;
              end;
            end;
            // If found, use full path; otherwise use original name
            if FullEffectPath = '' then
              FullEffectPath := EffectsList[j];
            // Don't add duplicates
            if acteffectsListBox.Items.IndexOf(FullEffectPath) = -1 then
              acteffectsListBox.Items.Add(FullEffectPath);
          end;
        end;
      end
      else if SameText(Key, 'casSharpness') then
      begin
        if TryStrToFloat(Value, FloatValue, FS) then
        begin
          // Convert 0.1..1.0 -> 1..10
          casTrackBar.Position := Round(FloatValue * 10);
          casvalueLabel.Caption := IntToStr(casTrackBar.Position);
        end;
      end
      else if SameText(Key, 'fxaaQualitySubpix') then
      begin
        if TryStrToFloat(Value, FloatValue, FS) then
        begin
          // Convert 0.1..1.0 -> 1..10
          fxaaTrackBar.Position := Round(FloatValue * 10);
          fxaavalueLabel.Caption := IntToStr(fxaaTrackBar.Position);
        end;
      end
      else if SameText(Key, 'smaaCornerRounding') then
      begin
        if TryStrToFloat(Value, FloatValue, FS) then
        begin
          // Convert 0.0..1.0 -> 1..10
          smaaTrackBar.Position := Round(FloatValue * 9) + 1;
          smaavalueLabel.Caption := IntToStr(smaaTrackBar.Position);
        end;
      end
      else if SameText(Key, 'dlsSharpness') then
      begin
        if TryStrToFloat(Value, FloatValue, FS) then
        begin
          // Convert 0.0..1.0 -> 1..10
          dlsTrackBar.Position := Round(FloatValue * 9) + 1;
          dlsvalueLabel.Caption := IntToStr(dlsTrackBar.Position);
        end;
      end
      else if SameText(Key, 'toggleKey') then
      begin
        // Update toggle key combobox if it exists
        if Assigned(vkbtogglekeyCombobox) then
        begin
          case LowerCase(Value) of
            'home': vkbtogglekeyCombobox.ItemIndex := 0;
            'f1': vkbtogglekeyCombobox.ItemIndex := 1;
            'f2': vkbtogglekeyCombobox.ItemIndex := 2;
            'f3': vkbtogglekeyCombobox.ItemIndex := 3;
            'f4': vkbtogglekeyCombobox.ItemIndex := 4;
          end;
        end;
      end;
    end;

  finally
    ConfigLines.Free;
  end;
end;

// ============================================================================
// MODERN DESIGN SYSTEM HELPERS
// ============================================================================

procedure ApplyModernTypography(AControl: TWinControl);
var
  i: Integer;
begin
  // Set base font with antialiasing
  AControl.Font.Name := FONT_NAME_PRIMARY;
  AControl.Font.Size := FONT_SIZE_BODY;
  AControl.Font.Quality := fqAntialiased;
  
  // Apply to all child components
  for i := 0 to AControl.ControlCount - 1 do
  begin
    // GroupBox titles get larger, bold font
    if AControl.Controls[i] is TGroupBox then
    begin
      TGroupBox(AControl.Controls[i]).Font.Size := FONT_SIZE_TITLE;
      TGroupBox(AControl.Controls[i]).Font.Style := [fsBold];
      TGroupBox(AControl.Controls[i]).Font.Quality := fqAntialiased;
    end;
    
    // Buttons get medium font
    if AControl.Controls[i] is TButton then
    begin
      TButton(AControl.Controls[i]).Font.Size := FONT_SIZE_BODY;
      TButton(AControl.Controls[i]).Font.Quality := fqAntialiased;
    end;
    
    // Labels get body font
    if AControl.Controls[i] is TLabel then
    begin
      TLabel(AControl.Controls[i]).Font.Size := FONT_SIZE_BODY;
      TLabel(AControl.Controls[i]).Font.Quality := fqAntialiased;
    end;
    
    // Recursively apply to child controls
    if AControl.Controls[i] is TWinControl then
      ApplyModernTypography(TWinControl(AControl.Controls[i]));
  end;
end;

procedure ApplyModernSpacing(AControl: TWinControl);
var
  i: Integer;
  Checkbox: TCheckBox;
  PrevCheckbox: TCheckBox;
begin
  for i := 0 to AControl.ControlCount - 1 do
  begin
    // Add padding to GroupBoxes
    if AControl.Controls[i] is TGroupBox then
    begin
      with TGroupBox(AControl.Controls[i]) do
      begin
        BorderSpacing.Left := MARGIN_MEDIUM;
        BorderSpacing.Top := MARGIN_MEDIUM;
        BorderSpacing.Right := MARGIN_MEDIUM;
        BorderSpacing.Bottom := MARGIN_MEDIUM;
      end;
    end;
    
    // Increase spacing between checkboxes
    if AControl.Controls[i] is TCheckBox then
    begin
      Checkbox := TCheckBox(AControl.Controls[i]);
      
      // Find previous checkbox and add margin
      if i > 0 then
      begin
        if AControl.Controls[i-1] is TCheckBox then
        begin
          PrevCheckbox := TCheckBox(AControl.Controls[i-1]);
          // Increase vertical spacing
          if Checkbox.Top - (PrevCheckbox.Top + PrevCheckbox.Height) < MARGIN_MEDIUM then
            Checkbox.Top := PrevCheckbox.Top + PrevCheckbox.Height + MARGIN_MEDIUM;
        end;
      end;
    end;
    
    // Add spacing to buttons
    if AControl.Controls[i] is TButton then
    begin
      with TButton(AControl.Controls[i]) do
      begin
        BorderSpacing.Around := MARGIN_SMALL;
      end;
    end;
    
    // Recursively apply to child controls
    if AControl.Controls[i] is TWinControl then
      ApplyModernSpacing(TWinControl(AControl.Controls[i]));
  end;
end;

procedure ApplyIconsToButtons(AForm: TForm);
begin
  // Add Unicode icons to main action buttons
  // Note: This requires Unicode support in the font
  
  // Find and update common buttons by name
  if Assigned(AForm.FindComponent('copyBitBtn')) then
    TBitBtn(AForm.FindComponent('copyBitBtn')).Caption := '📋 ' + 'Copy';
    
  if Assigned(AForm.FindComponent('howtoBitBtn')) then
    TBitBtn(AForm.FindComponent('howtoBitBtn')).Caption := '❓ ' + 'How to Use';
    
  if Assigned(AForm.FindComponent('gupdateBitBtn')) then
    TBitBtn(AForm.FindComponent('gupdateBitBtn')).Caption := '🔄 ' + 'Update';
end;

// ============================================================================
// KEYBOARD SHORTCUTS HANDLER
// ============================================================================

procedure Tgoverlayform.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // Ctrl+S = Save configuration
  if (Shift = [ssCtrl]) and (Key = Ord('S')) then
  begin
    saveBitBtnClick(nil);
    ShowStatusMessage('⚙️ Configuration saved successfully!');
    Key := 0;  // Mark as handled
  end
  // Ctrl+C = Copy command
  else if (Shift = [ssCtrl]) and (Key = Ord('C')) then
  begin
    copyBitBtnClick(nil);
    ShowStatusMessage('📋 Command copied to clipboard!');
    Key := 0;
  end
  // Ctrl+F = Focus search field
  else if (Shift = [ssCtrl]) and (Key = Ord('F')) then
  begin
    if Assigned(searchEdit) then
    begin
      searchEdit.SetFocus;
      searchEdit.SelectAll;
      ShowStatusMessage('Type to search...');
    end;
    Key := 0;
  end
  // F1 = Help/How to use
  else if Key = VK_F1 then
  begin
    howtoBitBtnClick(nil);
    Key := 0;
  end;
end;

// ============================================================================
// STATUS BAR AND SEARCH HELPERS
// ============================================================================

procedure Tgoverlayform.ShowStatusMessage(const AMessage: string; ADuration: Integer = 3000);
begin
  if not Assigned(statusBar) then Exit;
  
  statusBar.SimpleText := AMessage;
  
  // Reset and start timer for auto-clear
  if Assigned(FStatusTimer) then
  begin
    FStatusTimer.Enabled := False;
    FStatusTimer.Interval := ADuration;
    FStatusTimer.Enabled := True;
  end;
end;

procedure Tgoverlayform.StatusTimerTick(Sender: TObject);
begin
  if Assigned(statusBar) then
    statusBar.SimpleText := '';
  
  if Assigned(FStatusTimer) then
    FStatusTimer.Enabled := False;
end;

procedure Tgoverlayform.ClearSearchHighlights;
var
  i, j, k: Integer;
  TabSheet: TTabSheet;
  Container: TWinControl;
  ThemeTextColor: TColor;
  ThemeBgColor: TColor;
begin
  // Use the current theme colors to restore controls properly
  if CurrentTheme = tmDark then
  begin
    ThemeTextColor := DarkTextColor;
    ThemeBgColor   := DarkBackgroundColor;
  end
  else
  begin
    ThemeTextColor := LightTextColor;
    ThemeBgColor   := LightBackgroundColor;
  end;

  for i := 0 to goverlayPageControl.PageCount - 1 do
  begin
    TabSheet := goverlayPageControl.Pages[i];

    for j := 0 to TabSheet.ControlCount - 1 do
    begin
      if TabSheet.Controls[j] is TCheckBox then
      begin
        TCheckBox(TabSheet.Controls[j]).Font.Style := [];
        TCheckBox(TabSheet.Controls[j]).Font.Color := ThemeTextColor;
        TCheckBox(TabSheet.Controls[j]).Color := ThemeBgColor;
      end
      else if TabSheet.Controls[j] is TGroupBox then
      begin
        TGroupBox(TabSheet.Controls[j]).Font.Style := [];
        TGroupBox(TabSheet.Controls[j]).Font.Color := ThemeTextColor;
      end
      else if TabSheet.Controls[j] is TLabel then
      begin
        TLabel(TabSheet.Controls[j]).Font.Style := [];
        TLabel(TabSheet.Controls[j]).Font.Color := ThemeTextColor;
        TLabel(TabSheet.Controls[j]).Transparent := True;
      end;

      if TabSheet.Controls[j] is TWinControl then
      begin
        Container := TWinControl(TabSheet.Controls[j]);
        for k := 0 to Container.ControlCount - 1 do
        begin
          if Container.Controls[k] is TCheckBox then
          begin
            TCheckBox(Container.Controls[k]).Font.Style := [];
            TCheckBox(Container.Controls[k]).Font.Color := ThemeTextColor;
            TCheckBox(Container.Controls[k]).Color := ThemeBgColor;
          end
          else if Container.Controls[k] is TGroupBox then
          begin
            TGroupBox(Container.Controls[k]).Font.Style := [];
            TGroupBox(Container.Controls[k]).Font.Color := ThemeTextColor;
          end
          else if Container.Controls[k] is TLabel then
          begin
            TLabel(Container.Controls[k]).Font.Style := [];
            TLabel(Container.Controls[k]).Font.Color := ThemeTextColor;
            TLabel(Container.Controls[k]).Transparent := True;
          end;
        end;
      end;
    end;
  end;
end;

procedure Tgoverlayform.SearchEditChange(Sender: TObject);
var
  i, j, k: Integer;
  TabSheet: TTabSheet;
  Container: TWinControl;
  Query: string;
  FoundAny: Boolean;
  MatchCount: Integer;
  
  procedure CheckControl(AControl: TControl);
  begin
    if AControl is TCheckBox then
    begin
      if Pos(Query, LowerCase(TCheckBox(AControl).Caption)) > 0 then
      begin
        TCheckBox(AControl).Font.Style := [fsBold];
        TCheckBox(AControl).Font.Color := clBlack;
        TCheckBox(AControl).Color := $00FFFF80;  // Light yellow background
        Inc(MatchCount);
        WriteLn('[SEARCH] Match (CheckBox): ', TCheckBox(AControl).Caption);
        if not FoundAny then
        begin
          goverlayPageControl.ActivePage := TabSheet;
          FoundAny := True;
        end;
      end;
    end
    else if AControl is TGroupBox then
    begin
      if Pos(Query, LowerCase(TGroupBox(AControl).Caption)) > 0 then
      begin
        TGroupBox(AControl).Font.Style := [fsBold];
        TGroupBox(AControl).Font.Color := $0000CCFF;  // Orange text (no background)
        Inc(MatchCount);
        WriteLn('[SEARCH] Match (GroupBox): ', TGroupBox(AControl).Caption);
        if not FoundAny then
        begin
          goverlayPageControl.ActivePage := TabSheet;
          FoundAny := True;
        end;
      end;
    end
    else if AControl is TLabel then
    begin
      if Pos(Query, LowerCase(TLabel(AControl).Caption)) > 0 then
      begin
        TLabel(AControl).Font.Style := [fsBold];
        TLabel(AControl).Font.Color := clBlack;
        TLabel(AControl).Color := $00FFFF80;  // Light yellow background
        TLabel(AControl).Transparent := False;
        Inc(MatchCount);
        if not FoundAny then
        begin
          goverlayPageControl.ActivePage := TabSheet;
          FoundAny := True;
        end;
      end;
    end;
  end;
  
begin
  Query := LowerCase(Trim(searchEdit.Text));
  
  // Clear if query is too short
  if Length(Query) < 2 then
  begin
    ClearSearchHighlights;
    if Length(Query) > 0 then
      ShowStatusMessage('Type at least 2 characters to search');
    Exit;
  end;
  
  ClearSearchHighlights;
  FoundAny := False;
  MatchCount := 0;
  
  // Search in all tabs
  for i := 0 to goverlayPageControl.PageCount - 1 do
  begin
    TabSheet := goverlayPageControl.Pages[i];
    // Check direct controls
    for j := 0 to TabSheet.ControlCount - 1 do
    begin
      CheckControl(TabSheet.Controls[j]);
      
      // Also search inside containers (GroupBox, Panel, etc)
      if TabSheet.Controls[j] is TWinControl then
      begin
        Container := TWinControl(TabSheet.Controls[j]);
        for k := 0 to Container.ControlCount - 1 do
        begin
          CheckControl(Container.Controls[k]);
        end;
      end;
    end;
  end;
  
  if FoundAny then
    ShowStatusMessage(Format('%d result(s) for: "%s"', [MatchCount, searchEdit.Text]))
  else
    ShowStatusMessage(Format('No results for: "%s"', [searchEdit.Text]));
end;

procedure Tgoverlayform.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  ExecuteGUICommand('killall pascube');
  ExecuteGUICommand('killall vkcube');
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

  SavedTheme: TThemeMode;

begin

  //Program Version
  GVERSION := '1.7.5';
  GCHANNEL := 'git'; //stable ou git

  // Initialize fgmod directory with embedded scripts
  // This ensures fgmod scripts are always available without downloading
  InitializeFGModDirectory;

  // Auto-install OptiScaler if not present in FGMOD directory
  // This prevents FGMOD from failing due to missing dependencies
  if IsFGModInitialized then
  begin
    if not IsFGModOptiScalerInstalled(GetFGModPath) then
    begin
      WriteLn('[GOVERLAY] OptiScaler not detected in FGMOD, starting automatic installation...');
      SendNotification('GOverlay', 'Installing OptiScaler', GetIconFile);
      CheckAndInstallOptiScaler(GetFGModPath);
    end;
  end;

  //Set Window caption
  if GCHANNEL = 'stable' then
  begin
    goverlayform.Caption:= 'Goverlay ' + GVERSION;
  end
  else
  begin
    goverlayform.Caption:= 'Goverlay ' + GVERSION + ' (git testing build)';
    // Add flatpak indicator for non-stable builds in Flatpak mode
    if IsRunningInFlatpak then
      goverlayform.Caption:= goverlayform.Caption + ' flatpak';
  end;

   // Check for Goverlay updates
  CheckGoverlayUpdate(GVERSION, GCHANNEL, gupdateBitBtn);

  //Set initial TAB
  goverlayPageControl.ActivePage:=presetTabsheet;

   // Initialize menu selections
  mangohudsel := true;
  goverlayPanel.Visible:=true;
  
  // Apply comprehensive tooltips to all components
  ApplyAllHints(Self);
  
  // Apply modern design system
  //ApplyModernTypography(Self);  // Disabled - user preference
  //ApplyModernSpacing(Self);  // Disabled - user preference
  ApplyIconsToButtons(Self);
  
  // Create components dynamically for now
  searchEdit := TEdit.Create(Self);
  searchEdit.Parent := Self;
  searchEdit.Top := 72;
  searchEdit.Left := 10;
  searchEdit.Width := 191;
  searchEdit.Height := 22;
  searchEdit.Font.Size := 9;
  searchEdit.TextHint := '🔍 Search... (Ctrl+F)';
  searchEdit.OnChange := @SearchEditChange;
  TQtWidget(searchEdit.Handle).StyleSheet :=
    'QLineEdit {' +
    '  background-color: rgba(255,255,255,25);' +
    '  border: 1px solid rgba(255,255,255,55);' +
    '  border-radius: 6px;' +
    '  color: rgba(255,255,255,210);' +
    '  padding: 1px 5px;' +
    '  selection-background-color: rgba(255,255,255,80);' +
    '}' +
    'QLineEdit:focus {' +
    '  border: 1px solid rgba(255,255,255,100);' +
    '  background-color: rgba(255,255,255,40);' +
    '}';

  statusBar := TStatusBar.Create(Self);
  statusBar.Parent := Self;
  statusBar.Align := alNone;
  statusBar.Top := 97;
  statusBar.Left := 10;
  statusBar.Width := 191;
  statusBar.Height := 14;
  statusBar.SimplePanel := True;
  statusBar.SimpleText := '';
  statusBar.Font.Size := 7;
  TQtWidget(statusBar.Handle).StyleSheet :=
    'QStatusBar {' +
    '  background: transparent;' +
    '  border: none;' +
    '  color: rgba(255,255,255,140);' +
    '}';
  
  // Create status timer
  FStatusTimer := TTimer.Create(Self);
  FStatusTimer.Enabled := False;
  FStatusTimer.OnTimer := @StatusTimerTick;
  
  // searchEdit is now defined in LFM file - no need to create dynamically
  
  // Enable keyboard shortcuts
  Self.KeyPreview := True;
  Self.OnKeyDown := @FormKeyDown;
  
  vkbasaltsel := false;


  // Load and apply saved theme
  SavedTheme := LoadThemePreference;
  ApplyTheme(Self, SavedTheme);

  // Update theme toggle button icon based on loaded theme
  if SavedTheme = tmLight then
    themeToggleSpeedButton.ImageIndex := 29   // sun icon (light theme)
  else
    themeToggleSpeedButton.ImageIndex := 28; // moon icon (dark theme)

  // Bring theme toggle button to front to ensure it's visible
  themeToggleSpeedButton.BringToFront;



  //Hide howto button until OptiScaler configuration is saved
  howtoBitBtn.Visible := False;

  // Update geSpeedButton state from fgmod file
  UpdateGeSpeedButtonState;

  // Load tweaks tab state from fgmod file
  LoadTweaksFromFGMod;

  //Turbulence animation start
  FStartTick := GetTickCount;
  Timer.Interval := 50; // 20 fps aprox
  Timer.Enabled := True;
  Timer.OnTimer := @TimerTimer;
  goverlayPaintBox.OnPaint := @goverlayPaintBoxPaint;


   // Ajust tab text color
//  for i := 0 to goverlayPageControl.PageCount - 1 do
//  begin
//    goverlayPageControl.Pages[i].Font.Color := clBtnText;
//  end;

  // fix for radiobutton wrong colors
 // topleftRadiobutton.Color:=clDefault;
 // topcenterRadiobutton.Color:=clDefault;
 // toprightRadiobutton.Color:=clDefault;
 // bottomleftRadiobutton.Color:=clDefault;
 // bottomrightRadiobutton.Color:=clDefault;
 // bottomcenterRadiobutton.Color:=clDefault;
 // middleleftRadiobutton.Color:=clDefault;
 // middlerightRadiobutton.Color:=clDefault;


  // Define important file paths with proper XDG and Flatpak support
  GOVERLAYFOLDER := IncludeTrailingPathDelimiter(GetGOverlayConfigDir());
  // Use XDG-compliant path with proper Flatpak support (HOST_XDG_CONFIG_HOME)
  // Games don't run in sandbox, so MangoHud needs configs in the real host location
  MANGOHUDFOLDER := IncludeTrailingPathDelimiter(GetMangoHudConfigDir());
  MANGOHUDCFGFILE := IncludeTrailingPathDelimiter(GetMangoHudConfigDir()) + 'MangoHud.conf';
  BLACKLISTFILE := IncludeTrailingPathDelimiter(GetGOverlayConfigDir()) + 'blacklist.conf';
  CUSTOMCFGFILE := IncludeTrailingPathDelimiter(GetMangoHudConfigDir()) + 'custom.conf';
  USERSESSION := GetEnvironmentVariable('XDG_SESSION_TYPE');
  // Use XDG-compliant path with proper Flatpak support (HOST_XDG_CONFIG_HOME)
  // This ensures ReShade shader paths are consistent across installation methods
  VKBASALTFOLDER := IncludeTrailingPathDelimiter(GetVkBasaltConfigDir());
  VKBASALTCFGFILE := IncludeTrailingPathDelimiter(GetVkBasaltConfigDir()) + 'vkBasalt.conf';
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
    
    // Disable gamemodeCheckBox if gamemode is missing
    if Missing.IndexOf('gamemode') >= 0 then
    begin
      gamemodeCheckBox.Enabled := False;
      gamemodeCheckBox.Hint := 'GameMode is not installed - install gamemode package to enable this feature';
      gamemodeCheckBox.ShowHint := True;
    end;
  end;
  Missing.Free;

  // Connect GameMode checkbox click event
  gamemodeCheckBox.OnClick := @gamemodeCheckBoxClick;



   //Check if mangohud file exists
   ConfigFilePath := MANGOHUDCFGFILE;
   ConfigDir := ExtractFilePath(ConfigFilePath);

   // check if directory exists (use CreateHostDirectory for Flatpak compatibility)
   if not DirectoryExists(ConfigDir) then
     CreateHostDirectory(ConfigDir);

   // check if files exists
   if not FileExists(ConfigFilePath) then
   begin


    // shot notification
    SendNotification('Goverlay', 'No configuration files located, creating files and folders.', GetIconFile);


  // default state
  aveffectsListbox.Enabled := False;
  addBitbtn.Enabled := False;
  subBitbtn.Enabled := False;




     // Create stock mangohud config
     DefaultConfigContent := TStringList.Create;
     try
       DefaultConfigContent.Text :=
         '################### File Generated by Goverlay ###################' + LineEnding +
         '' + LineEnding +
         'legacy_layout=0' + LineEnding +
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

  // Check vkbasalt directory with proper XDG and Flatpak support
  VKBASALTCFGFILE := IncludeTrailingPathDelimiter(GetVkBasaltConfigDir()) + 'vkBasalt.conf';

  // make sure directory exists - VKBASALT (use CreateHostDirectory for Flatpak compatibility)
  CreateHostDirectory(ExtractFilePath(VKBASALTCFGFILE));


    // Check if file exists and create default - VKBASALT
  if not FileExists(VKBASALTCFGFILE) then
  begin
    SendNotification('Goverlay', 'No configuration files located for vkbasalt, creating files and folders.', GetIconFile);
    FileLines := TStringList.Create;
    try
      FileLines.Add('################### File Generated by Goverlay ###################');
      FileLines.Add('effects = cas');
      FileLines.Add('toggleKey = ' + vkbtogglekeyCombobox.Text);
      FileLines.Add('enableOnLaunch = True');

      FileLines.SaveToFile(VKBASALTCFGFILE);
    finally
      FileLines.Free;
    end;
  end;



  //Load available text fonts
   ListarFontesNoDiretorio(fontComboBox);


  //Detect system GPUs

  // Count the number of detected GPUs
  //  Process := TProcess.Create(nil);
    saida := TStringList.Create;

    Process.Executable := FindDefaultExecutablePath('sh');
    Process.Parameters.Add('-c');
    Process.Parameters.Add('lspci | grep -i -e "VGA" -e "Display controller" -e "3D controller" -e "video" | wc -l'); //Count the number of lines
    Process.Options := [poUsePipes];
    Process.Execute;
    Process.WaitOnExit;

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
      Process.Parameters.Add('lspci | grep -i -e "VGA" -e "Display controller" -e "3D controller" -e "video" | sed -n "' + inttostr(i) + 'p" | cut -c 1-7');  //Pick just the "i" line
      Process.Options := [poUsePipes];
      Process.Execute;
      Process.WaitOnExit;

      saida.LoadFromStream(Process.output);
      pcidevComboBox.Items.Insert(i-1, saida[0]); //First position of combobox is 0, so we need i-1
      Process.Free;
      saida.Free;


      //Read GPU description
      Process := TProcess.Create(nil);
      saida := TStringList.Create;

      Process.Executable := FindDefaultExecutablePath('sh');
      Process.Parameters.Add('-c');
      Process.Parameters.Add('lspci | grep -i -e "VGA" -e "Display controller" -e "3D controller" -e "video" | sed -n "' + inttostr(i) + 'p" |cut -d" " -f3- | cut -d ":" -f2-'); //Pick just the first line
      Process.Options := [poUsePipes];
      Process.Execute;
      Process.WaitOnExit;

      saida.LoadFromStream(Process.output);
      GPUDESC.Add(saida[0]);
      Process.Free;
      saida.Free;

      i := i + 1; //increment "i"variable



    end; //while


    // Add "Use both GPUs" option if multiple GPUs are detected
    if GPUNUMBER > 1 then
    begin
      pcidevCombobox.Items.Add('Use both GPUs');
      GPUDESC.Add('All GPUs');
    end;


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



     //Select mangohud as initial option
     mangohudLabelClick(mangohudLabel);

     // Initial MANGOHUD STOCK values

     alphavalueLabel.Caption:= FormatFloat('#0.0', transpTrackbar.Position/10);
     fontsizevalueLabel.Caption:=inttostr(fontsizeTrackbar.Position);
     fontcombobox.ItemIndex:=0;
     afvalueLabel.Caption:= FormatFloat('#0', afTrackbar.Position);
     mipmapvalueLabel.Caption:= FormatFloat('#0', mipmapTrackbar.Position);
     // Set log folder path - use XDG-compliant data directory
     logfolderEdit.text := GetGOverlayDataDir();
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
              FPS := StrToIntDef(FPSNumbers[i], 0);
              if FPS <> 0 then
                FPS := FPS + Offset;
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



    //Read system GPUs
      Process := TProcess.Create(nil);
      saida := TStringList.Create;

      Process.Executable := FindDefaultExecutablePath('sh');
      Process.Parameters.Add('-c');
      Process.Parameters.Add('lspci | grep -i -e "VGA" -e "Display controller" -e "3D controller" -e "video" | sed -n 1p | cut -c 1-7');  //Pick just the "i" line
      Process.Options := [poUsePipes];
      Process.Execute;
      Process.WaitOnExit;

      saida.LoadFromStream(Process.output);
      LSPCI0 := Trim(saida.text); // store output um variable
      Writeln ('LSPCI0: ', LSPCI0);
      GPU0 :=  pcidevCombobox.Items[0]; //store first value in variable
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





    // Load Mangohud config file
    LoadMangoHudConfig;


    //Load vkbasalt configuration
    LoadVkBasaltConfig;

    //Load fgmod configuration
    LoadFgmodConfig;

    //Load OptiScaler configuration
    LoadOptiScalerConfig;

    //Load FakeNvapi configuration
    LoadFakeNvapiConfig;

    // Check NVIDIA module and configure controls
    if IsNvidiaModuleLoaded then
    begin
      // NVIDIA driver is loaded
      nvidiaRadioButton.Checked := True;
      spoofCheckBox.Checked := False;
      spoofCheckBox.Enabled := False;
      autodetectnvLabel.Visible:=true;
      autodetectnvLabel.Font.color:=clOlive;
      forcereflexCheckBox.Checked := false;
      forcereflexCheckBox.Enabled := false;
      reflexComboBox.Enabled:= false;
    end
    else
    begin
      // NVIDIA driver is NOT loaded (using Mesa/AMD/Intel)
      mesaRadioButton.Checked := True;
      spoofCheckBox.Checked := True;
      spoofCheckBox.Enabled := True;
      autodetectmesaLabel.Visible:=true;
      autodetectmesaLabel.Font.color:=clOlive;
//    forcereflexCheckBox.Checked := false;
      forcereflexCheckBox.Enabled := true;
      reflexComboBox.Enabled:= true;
  end;

    //Initiate optiscaler

    FOptiscalerUpdate := TOptiscalerTab.Create;

    FOptiscalerUpdate.FGModPath := GetOptiScalerInstallPath;
    FOptiscalerUpdate.UpdateBtn := updatebitBtn;
    FOptiscalerUpdate.CheckupdBtn := checkupdBitbtn;
    FOptiscalerUpdate.ProgressBar := updateProgressBar;
    FOptiscalerUpdate.StatusLabel := updatestatusLabel;
    FOptiscalerUpdate.OptiLabel := optlabel1;
    FOptiscalerUpdate.OptiLabel2 := optlabel2;
    FOptiscalerUpdate.FakeNvapiLabel := fakenvapi1;
    FOptiscalerUpdate.XessLabel := xessLabel1;
    FOptiscalerUpdate.FsrLabel := fsrlabel1;
    FOptiscalerUpdate.FsrVersionComboBox := fsrversionComboBox;
    FOptiscalerUpdate.OptVersionComboBox := optversionComboBox;
    FOptiscalerUpdate.FakeNvapiLabel2 := fakenvapi2;
    FOptiscalerUpdate.OptiPatcherLabel := optipatcherLabel1;
    FOptiscalerUpdate.NotificationLabel := notificationLabel;
    FOptiscalerUpdate.DlssLabel := dlssLabel1;

    // Connect OnChange event for OptiScaler channel selection
    optversionComboBox.OnChange := @optversionComboBoxChange;

    //Initialize tab
    FOptiscalerUpdate.InitializeTab;

    //Check for updates on startup
    if Assigned(FOptiscalerUpdate) then
      FOptiscalerUpdate.CheckForUpdatesOnClick;

    // Initialize global enable menu item checked state
    globalenableMenuItem.Checked := IsMangoHudGloballyEnabled();
    
    // Initialize globalenableMenuItem visibility based on active tab
    UpdateGlobalEnableMenuItemVisibility;

end; // form create

// Helper function to access generalGroupBox checkboxes by index (replaces generalCheckGroup)
function Tgoverlayform.GetGeneralCheckBox(Index: Integer): TCheckBox;
begin
  case Index of
    0: Result := simdeckCheckBox;        // Simulate Steam Deck
    1: Result := gamemodeCheckBox;       // Always use GameMode
    2: Result := enhdrCheckBox;          // Enable HDR
    3: Result := enwaylandCheckBox;      // Enable Wayland
    4: Result := actprotonlogsCheckBox;  // Active Proton Logs
    5: Result := usesdlCheckBox;         // Use SDL Input
  else
    raise Exception.Create('Invalid general checkbox index: ' + IntToStr(Index));
  end;
end;

// Helper function to access graphicsGroupBox checkboxes by index (replaces graphicsCheckGroup)
function Tgoverlayform.GetGraphicsCheckBox(Index: Integer): TCheckBox;
begin
  case Index of
    0: Result := emurtCheckBox;        // Emulate RT (old AMD)
    1: Result := hidenvidiaCheckBox;   // Hide Nvidia GPU
    2: Result := forcenvapiCheckBox;   // Force enable NVAPI
    3: Result := wined3dCheckBox;      // Use old WINED3D
    4: Result := forcezinkCheckBox;    // Force Zink
  else
    raise Exception.Create('Invalid graphics checkbox index: ' + IntToStr(Index));
  end;
end;

// Helper function to access performanceGroupBox checkboxes by index (replaces performanceCheckGroup)
function Tgoverlayform.GetPerformanceCheckBox(Index: Integer): TCheckBox;
begin
  case Index of
    0: Result := highpriCheckBox;        // Higher priority for games
    1: Result := wow64CheckBox;          // Use WOW64
    2: Result := largeaddressCheckBox;   // Large Address Aware
    3: Result := stagememCheckBox;       // Staging shared memory
    4: Result := disablentsyncCheckBox;  // Disable NTSYNC
    5: Result := heapdelayCheckBox;      // Heap Delay Free
  else
    raise Exception.Create('Invalid performance checkbox index: ' + IntToStr(Index));
  end;
end;


procedure Tgoverlayform.FormShow(Sender: TObject);
begin
  // Start pascube or vkcube (vulkan demo) only after the form is fully loaded
  if IsRunningInFlatpak then
  begin
      // FLATPAK MODE
      if IsCommandAvailable('pascube') then
         ExecuteGUICommand('MANGOHUD=1 pascube &')
      else if IsCommandAvailable('vkcube') then
      begin
         SendNotification('Goverlay', 'PasCube was not located, using vkcube instead', GetIconFile);
         if (USERSESSION = 'wayland') and IsCommandAvailable('vkcube-wayland') then
            ExecuteGUICommand('MANGOHUD=1 vkcube-wayland &')
         else
            ExecuteGUICommand('MANGOHUD=1 vkcube &');
      end
      else
         SendNotification('Goverlay', 'PasCube and VkCube were not located.', GetIconFile);
  end
  else
  begin
      // NATIVE MODE
      if IsCommandAvailable('pascube') then
         ExecuteGUICommand('MANGOHUD=1 pascube &')
      else if IsCommandAvailable('vkcube') then
      begin
        SendNotification('Goverlay', 'PasCube was not located, using vkcube instead', GetIconFile);
        if USERSESSION = 'wayland' then
          ExecuteGUICommand('MANGOHUD=1 vkcube --wsi wayland &')
        else
          ExecuteGUICommand('mangohud vkcube &');
      end
      else
         SendNotification('Goverlay', 'PasCube and VkCube were not located.', GetIconFile);
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
var
  FGModFilePath: string;
  FileLines: TStringList;
  i, SteamDeckLineIndex: Integer;
  TargetLineExists: Boolean;
  IsMangoHudTab, IsVkBasaltTab, IsOptiScalerTab, IsTweaksTab: Boolean;
  ExportLine, SearchPattern, NotifyTitle, NotifyMsgOn, NotifyMsgOff: string;
begin
  // Determine which tab is active
  IsMangoHudTab := (goverlayPageControl.ActivePage = presetTabSheet) or
                   (goverlayPageControl.ActivePage = visualTabSheet) or
                   (goverlayPageControl.ActivePage = performanceTabSheet) or
                   (goverlayPageControl.ActivePage = metricsTabSheet) or
                   (goverlayPageControl.ActivePage = extrasTabSheet);

  IsVkBasaltTab := (goverlayPageControl.ActivePage = vkbasaltTabSheet);
  IsOptiScalerTab := (goverlayPageControl.ActivePage = optiscalerTabSheet);
  IsTweaksTab := (goverlayPageControl.ActivePage = tweaksTabSheet);

  // Set the appropriate export line and messages based on active tab
  if IsMangoHudTab then
  begin
    ExportLine := '  export MANGOHUD=1';
    SearchPattern := 'export MANGOHUD=1';
    NotifyTitle := 'MangoHud';
    NotifyMsgOn := 'MangoHud will be activated in every application using fgmod';
    NotifyMsgOff := 'MangoHud deactivated in fgmod';
  end
  else if IsVkBasaltTab then
  begin
    ExportLine := '  export ENABLE_VKBASALT=1';
    SearchPattern := 'export ENABLE_VKBASALT=1';
    NotifyTitle := 'vkBasalt';
    NotifyMsgOn := 'vkBasalt will be activated in every application using fgmod';
    NotifyMsgOff := 'vkBasalt deactivated in fgmod';
  end
  else if IsOptiScalerTab then
  begin
    // Show warning when user tries to deactivate on OptiScaler tab
    if geSpeedButton.ImageIndex = 1 then
    begin
      ShowMessage('Warning: "Auto Enable" (fgmod) must be active for OptiScaler to work.' + LineEnding + LineEnding +
                  'Deactivating this option will completely disable OptiScaler.');
    end;
    ExportLine := '  export WINEDLLOVERRIDES=\"$WINEDLLOVERRIDES,dxgi=n,b\"';
    SearchPattern := 'export WINEDLLOVERRIDES=';
    NotifyTitle := 'OptiScaler';
    NotifyMsgOn := 'OptiScaler will be activated in every application using fgmod';
    NotifyMsgOff := 'OptiScaler deactivated from fgmod';
  end
  else if IsTweaksTab then
  begin
    // Tweaks tab: just toggle the button state, no specific export line
    // The actual tweaks are added when saving via saveBitBtnClick
    if geSpeedButton.ImageIndex = 0 then
    begin
      geSpeedButton.ImageIndex := 1;  // ON
      SendNotification('Tweaks', 'Tweaks will be saved to fgmod when you click Save', GetIconFile);
    end
    else
    begin
      geSpeedButton.ImageIndex := 0;  // OFF
      SendNotification('Tweaks', 'Tweaks mode disabled - commands will be shown for manual use', GetIconFile);
    end;
    Exit;  // Exit early for tweaks tab
  end
  else
    Exit;  // Not a supported tab

  // Get fgmod file path
  FGModFilePath := GetFGModPath + PathDelim + 'fgmod';

  // Check if fgmod file exists
  if not FileExists(FGModFilePath) then
  begin
    ShowMessage('fgmod file not found at: ' + FGModFilePath);
    Exit;
  end;

  FileLines := TStringList.Create;
  try
    FileLines.LoadFromFile(FGModFilePath);

    // Find the anchor line (# Execute the original command) and check if target line exists
    SteamDeckLineIndex := -1;
    TargetLineExists := False;

    for i := 0 to FileLines.Count - 1 do
    begin
      if Pos('# Execute the original command', FileLines[i]) > 0 then
        SteamDeckLineIndex := i;
      if Pos(SearchPattern, FileLines[i]) > 0 then
        TargetLineExists := True;
    end;

    if TargetLineExists then
    begin
      // Remove the target line
      for i := FileLines.Count - 1 downto 0 do
      begin
        if Pos(SearchPattern, FileLines[i]) > 0 then
        begin
          FileLines.Delete(i);
          Break;  // Only delete first occurrence
        end;
      end;
      geSpeedButton.ImageIndex := 0;  // OFF
      WriteLn('[FGMOD] Removed ', SearchPattern, ' from fgmod');
      SendNotification(NotifyTitle, NotifyMsgOff, GetIconFile);
    end
    else
    begin
      // Add the line after the anchor line
      if SteamDeckLineIndex >= 0 then
      begin
        FileLines.Insert(SteamDeckLineIndex + 1, ExportLine);
        geSpeedButton.ImageIndex := 1;  // ON
        WriteLn('[FGMOD] Added ', SearchPattern, ' to fgmod');
        SendNotification(NotifyTitle, NotifyMsgOn, GetIconFile);
      end
      else
      begin
        ShowMessage('Could not find "# Execute the original command" line in fgmod file');
        Exit;
      end;
    end;

    // Save the modified file
    FileLines.SaveToFile(FGModFilePath);

    // Make sure it's still executable
    fpChmod(FGModFilePath, &755);

  finally
    FileLines.Free;
  end;
end;

// Check if OptiScaler is installed by looking for goverlay.vars file
function Tgoverlayform.IsOptiScalerInstalled: Boolean;
var
  VarsFilePath: string;
begin
  VarsFilePath := GetOptiScalerInstallPath + PathDelim + 'goverlay.vars';
  Result := FileExists(VarsFilePath);
end;

procedure Tgoverlayform.UpdateGeSpeedButtonState;
var
  FGModFilePath: string;
  FileLines: TStringList;
  i: Integer;
  TargetEnabled: Boolean;
  IsMangoHudTab, IsVkBasaltTab, IsOptiScalerTab, IsTweaksTab: Boolean;
  SearchPattern: string;
  TweakFound: Boolean;
begin
  // Get fgmod file path
  FGModFilePath := GetFGModPath + PathDelim + 'fgmod';

  // Check if fgmod file exists
  if not FileExists(FGModFilePath) then
  begin
    geSpeedButton.ImageIndex := 0;  // Default to OFF
    Exit;
  end;

  // Determine which tab is active
  IsMangoHudTab := (goverlayPageControl.ActivePage = presetTabSheet) or
                   (goverlayPageControl.ActivePage = visualTabSheet) or
                   (goverlayPageControl.ActivePage = performanceTabSheet) or
                   (goverlayPageControl.ActivePage = metricsTabSheet) or
                   (goverlayPageControl.ActivePage = extrasTabSheet);

  IsVkBasaltTab := (goverlayPageControl.ActivePage = vkbasaltTabSheet);
  IsOptiScalerTab := (goverlayPageControl.ActivePage = optiscalerTabSheet);
  IsTweaksTab := (goverlayPageControl.ActivePage = tweaksTabSheet);

  // Set the search pattern and hint based on active tab
  if IsMangoHudTab then
  begin
    SearchPattern := 'export MANGOHUD=1';
    geSpeedButton.Hint := 'MangoHUD will be automatically enabled for applications running the launch command with FGMOD';
    // Only enable controls if global enable is not active
    // When global enable is active, UpdateGlobalEnableMenuItemVisibility will handle it
    if not IsMangoHudGloballyEnabled() then
    begin
      geSpeedButton.Enabled := True;
      saveBitBtn.Enabled := True;
    end;
  end
  else if IsVkBasaltTab then
  begin
    SearchPattern := 'export ENABLE_VKBASALT=1';
    geSpeedButton.Hint := 'vkBasalt will be automatically enabled for applications running the launch command with FGMOD';
    // Ensure controls are enabled for non-OptiScaler tabs
    geSpeedButton.Enabled := True;
    saveBitBtn.Enabled := True;
  end
  else if IsOptiScalerTab then
  begin
    SearchPattern := 'export WINEDLLOVERRIDES=';
    geSpeedButton.Hint := 'Optiscaler will be automatically enabled for applications running the launch command with FGMOD';
    
    // Disable controls if OptiScaler is not installed
    if not IsOptiScalerInstalled then
    begin
      geSpeedButton.Enabled := False;
      saveBitBtn.Enabled := False;
      geSpeedButton.ImageIndex := 0;  // OFF
      Exit;
    end
    else
    begin
      geSpeedButton.Enabled := True;
      saveBitBtn.Enabled := True;
    end;
  end
  else if IsTweaksTab then
  begin
    geSpeedButton.Hint := 'Tweaks will be activated in every application using fgmod';
    // Ensure controls are enabled for non-OptiScaler tabs
    geSpeedButton.Enabled := True;
    saveBitBtn.Enabled := True;

    // For tweaks tab, load the checkbox states from fgmod file
    FileLines := TStringList.Create;
    try
      FileLines.LoadFromFile(FGModFilePath);
      TweakFound := False;

      // Check each tweak and set checkbox accordingly
      for i := 0 to FileLines.Count - 1 do
      begin
        // Index 0: "Simulate Steam Deck" -> export SteamDeck=1
        if Pos('export SteamDeck=1', FileLines[i]) > 0 then
        begin
          GetGeneralCheckBox(0).Checked := True;
          TweakFound := True;
        end;

        // Index 2: "Enable HDR" -> export PROTON_ENABLE_HDR=1
        if Pos('export PROTON_ENABLE_HDR=1', FileLines[i]) > 0 then
        begin
          GetGeneralCheckBox(2).Checked := True;
          TweakFound := True;
        end;

        // Index 3: "Enable Wayland" -> export PROTON_ENABLE_WAYLAND=1
        if Pos('export PROTON_ENABLE_WAYLAND=1', FileLines[i]) > 0 then
        begin
          GetGeneralCheckBox(3).Checked := True;
          TweakFound := True;
        end;

        // Index 4: "Active Proton Logs" -> export PROTON_LOG=1
        if Pos('export PROTON_LOG=1', FileLines[i]) > 0 then
        begin
          GetGeneralCheckBox(4).Checked := True;
          TweakFound := True;
        end;

        // Index 5: "Use SDL Input" -> export PROTON_USE_SDL=1
        if Pos('export PROTON_USE_SDL=1', FileLines[i]) > 0 then
        begin
          GetGeneralCheckBox(5).Checked := True;
          TweakFound := True;
        end;

        // Index 1: "Always use GameMode" -> #gamemode comment
        if Pos('#gamemode', FileLines[i]) > 0 then
        begin
          GetGeneralCheckBox(1).Checked := True;
          TweakFound := True;
        end;

        // graphicsCheckGroup items
        // Index 0: "Emulate RT (old AMD)" -> export RADV_PERFTEST=rt,emulate_rt
        if Pos('export RADV_PERFTEST=rt,emulate_rt', FileLines[i]) > 0 then
        begin
          GetGraphicsCheckBox(0).Checked := True;
          TweakFound := True;
        end;

        // Index 1: "Hide Nvidia GPU" -> export PROTON_HIDE_NVIDIA_GPU=1
        if Pos('export PROTON_HIDE_NVIDIA_GPU=1', FileLines[i]) > 0 then
        begin
          GetGraphicsCheckBox(1).Checked := True;
          TweakFound := True;
        end;

        // Index 2: "Force enable NVAPI" -> export PROTON_ENABLE_NVAPI=1
        if Pos('export PROTON_ENABLE_NVAPI=1', FileLines[i]) > 0 then
        begin
          GetGraphicsCheckBox(2).Checked := True;
          TweakFound := True;
        end;

        // Index 3: "Use old WINED3D" -> export PROTON_USE_WINED3D=1
        if Pos('export PROTON_USE_WINED3D=1', FileLines[i]) > 0 then
        begin
          GetGraphicsCheckBox(3).Checked := True;
          TweakFound := True;
        end;

        // performanceCheckGroup items
        // Index 0: "Higher priority for games" -> export PROTON_PRIORITY_HIGH=1
        if Pos('export PROTON_PRIORITY_HIGH=1', FileLines[i]) > 0 then
        begin
          GetPerformanceCheckBox(0).Checked := True;
          TweakFound := True;
        end;

        // Index 1: "Use WOW64" -> export PROTON_USE_WOW64=1
        if Pos('export PROTON_USE_WOW64=1', FileLines[i]) > 0 then
        begin
          GetPerformanceCheckBox(1).Checked := True;
          TweakFound := True;
        end;

        // Index 2: "Large Address Aware" -> export PROTON_FORCE_LARGE_ADDRESS_AWARE=1
        if Pos('export PROTON_FORCE_LARGE_ADDRESS_AWARE=1', FileLines[i]) > 0 then
        begin
          GetPerformanceCheckBox(2).Checked := True;
          TweakFound := True;
        end;

        // Index 3: "Staging shared memory" -> export STAGING_SHARED_MEMORY=1
        if Pos('export STAGING_SHARED_MEMORY=1', FileLines[i]) > 0 then
        begin
          GetPerformanceCheckBox(3).Checked := True;
          TweakFound := True;
        end;

        // Index 4: "Disable NTSYNC" -> export PROTON_NO_NTSYNC=1
        if Pos('export PROTON_NO_NTSYNC=1', FileLines[i]) > 0 then
        begin
          GetPerformanceCheckBox(4).Checked := True;
          TweakFound := True;
        end;

        // Index 5: "Heap Delay Free" -> export PROTON_HEAP_DELAY_FREE=1
        if Pos('export PROTON_HEAP_DELAY_FREE=1', FileLines[i]) > 0 then
        begin
          GetPerformanceCheckBox(5).Checked := True;
          TweakFound := True;
        end;
      end;

      // Set geSpeedButton state based on whether any tweak was found
      if TweakFound then
        geSpeedButton.ImageIndex := 1  // ON
      else
        geSpeedButton.ImageIndex := 0; // OFF

    finally
      FileLines.Free;
    end;
    Exit;  // Exit early for tweaks tab
  end
  else
  begin
    geSpeedButton.ImageIndex := 0;  // Default to OFF for other tabs
    Exit;
  end;

  FileLines := TStringList.Create;
  try
    FileLines.LoadFromFile(FGModFilePath);

    // Check if target line exists
    TargetEnabled := False;
    for i := 0 to FileLines.Count - 1 do
    begin
      if Pos(SearchPattern, FileLines[i]) > 0 then
      begin
        TargetEnabled := True;
        Break;
      end;
    end;

    if TargetEnabled then
      geSpeedButton.ImageIndex := 1  // ON
    else
      geSpeedButton.ImageIndex := 0; // OFF

  finally
    FileLines.Free;
  end;
end;

procedure Tgoverlayform.UpdateGlobalEnableMenuItemVisibility;
var
  IsMangoHudTab: Boolean;
  IsGlobalEnableActive: Boolean;
begin
  // Determine if we are on a MangoHud tab
  IsMangoHudTab := (goverlayPageControl.ActivePage = presetTabSheet) or
                   (goverlayPageControl.ActivePage = visualTabSheet) or
                   (goverlayPageControl.ActivePage = performanceTabSheet) or
                   (goverlayPageControl.ActivePage = metricsTabSheet) or
                   (goverlayPageControl.ActivePage = extrasTabSheet);
  
  // Show the menu item only on MangoHud tabs
  // Also hide it if running in Flatpak as per user request (might change in future)
  globalenableMenuItem.Visible := IsMangoHudTab and (not IsRunningInFlatpak);
  
  // Get global enable status
  IsGlobalEnableActive := IsMangoHudGloballyEnabled();
  
  // On MangoHud tabs: when global enable is active, disable geSpeedButton, 
  // set it to ON state, and change geLabel caption to indicate global enable
  if IsMangoHudTab then
  begin
    if IsGlobalEnableActive then
    begin
      // Show controls but indicate global enable is active
      geSpeedButton.Visible := true;
      geSpeedButton.Enabled := false;
      geSpeedButton.ImageIndex := 1;  // ON state
      geLabel.Visible := true;
      geLabel.Caption := 'Global enable';
    end
    else
    begin
      // Normal state: enabled and restore default caption
      geSpeedButton.Visible := true;
      geSpeedButton.Enabled := true;
      geLabel.Visible := true;
      geLabel.Caption := 'Auto Enable';
    end;
  end
  else
  begin
    // On other tabs (vkBasalt, OptiScaler, Tweaks), always show and enable these controls
    geSpeedButton.Visible := true;
    geSpeedButton.Enabled := true;
    geLabel.Visible := true;
    geLabel.Caption := 'Auto Enable';
  end;
end;


procedure Tgoverlayform.LoadTweaksFromFGMod;
var
  FGModFilePath: string;
  FileLines: TStringList;
  i: Integer;
  TweakFound: Boolean;
  CustomEnvValue, Line: string;
  StartPos, EndPos: Integer;
begin
  // Get fgmod file path
  FGModFilePath := GetFGModPath + PathDelim + 'fgmod';

  // Check if fgmod file exists
  if not FileExists(FGModFilePath) then
    Exit;

  FileLines := TStringList.Create;
  try
    FileLines.LoadFromFile(FGModFilePath);
    TweakFound := False;

    // Reset all tweaks checkboxes first
    GetGeneralCheckBox(0).Checked := False;
    GetGeneralCheckBox(1).Checked := False;
    GetGeneralCheckBox(2).Checked := False;
    GetGeneralCheckBox(3).Checked := False;
    GetGeneralCheckBox(4).Checked := False;
    GetGeneralCheckBox(5).Checked := False;

    // Reset graphicsCheckGroup checkboxes
    GetGraphicsCheckBox(0).Checked := False;
    GetGraphicsCheckBox(1).Checked := False;
    GetGraphicsCheckBox(2).Checked := False;
    GetGraphicsCheckBox(3).Checked := False;
    GetGraphicsCheckBox(4).Checked := False;

    // Reset performanceCheckGroup checkboxes
    GetPerformanceCheckBox(0).Checked := False;
    GetPerformanceCheckBox(1).Checked := False;
    GetPerformanceCheckBox(2).Checked := False;
    GetPerformanceCheckBox(3).Checked := False;
    GetPerformanceCheckBox(4).Checked := False;
    GetPerformanceCheckBox(5).Checked := False;

    // Reset customenvEdit
    customenvEdit.Text := '';

    // Check each tweak and set checkbox accordingly
    for i := 0 to FileLines.Count - 1 do
    begin
      // Index 0: "Simulate Steam Deck" -> export SteamDeck=1
      if Pos('export SteamDeck=1', FileLines[i]) > 0 then
      begin
        GetGeneralCheckBox(0).Checked := True;
        TweakFound := True;
      end;

      // Index 2: "Enable HDR" -> export PROTON_ENABLE_HDR=1
      if Pos('export PROTON_ENABLE_HDR=1', FileLines[i]) > 0 then
      begin
        GetGeneralCheckBox(2).Checked := True;
        TweakFound := True;
      end;

      // Index 3: "Enable Wayland" -> export PROTON_ENABLE_WAYLAND=1
      if Pos('export PROTON_ENABLE_WAYLAND=1', FileLines[i]) > 0 then
      begin
        GetGeneralCheckBox(3).Checked := True;
        TweakFound := True;
      end;

      // Index 4: "Active Proton Logs" -> export PROTON_LOG=1
      if Pos('export PROTON_LOG=1', FileLines[i]) > 0 then
      begin
        GetGeneralCheckBox(4).Checked := True;
        TweakFound := True;
      end;

      // Index 5: "Use SDL Input" -> export PROTON_USE_SDL=1
      if Pos('export PROTON_USE_SDL=1', FileLines[i]) > 0 then
      begin
        GetGeneralCheckBox(5).Checked := True;
        TweakFound := True;
      end;

      // Index 1: "Always use GameMode" -> #gamemode comment
      if Pos('#gamemode', FileLines[i]) > 0 then
      begin
        GetGeneralCheckBox(1).Checked := True;
        TweakFound := True;
      end;

      // graphicsCheckGroup items
      // Index 0: "Emulate RT (old AMD)" -> export RADV_PERFTEST=rt,emulate_rt
      if Pos('export RADV_PERFTEST=rt,emulate_rt', FileLines[i]) > 0 then
      begin
        GetGraphicsCheckBox(0).Checked := True;
        TweakFound := True;
      end;

      // Index 1: "Hide Nvidia GPU" -> export PROTON_HIDE_NVIDIA_GPU=1
      if Pos('export PROTON_HIDE_NVIDIA_GPU=1', FileLines[i]) > 0 then
      begin
        GetGraphicsCheckBox(1).Checked := True;
        TweakFound := True;
      end;

      // Index 2: "Force enable NVAPI" -> export PROTON_ENABLE_NVAPI=1
      if Pos('export PROTON_ENABLE_NVAPI=1', FileLines[i]) > 0 then
      begin
        GetGraphicsCheckBox(2).Checked := True;
        TweakFound := True;
      end;

      // Index 3: "Use old WINED3D" -> export PROTON_USE_WINED3D=1
      if Pos('export PROTON_USE_WINED3D=1', FileLines[i]) > 0 then
      begin
        GetGraphicsCheckBox(3).Checked := True;
        TweakFound := True;
      end;

      // Index 4: "Force Zink" -> export MESA_LOADER_DRIVER_OVERRIDE=zink
      if Pos('export MESA_LOADER_DRIVER_OVERRIDE=zink', FileLines[i]) > 0 then
      begin
        GetGraphicsCheckBox(4).Checked := True;
        TweakFound := True;
      end;

      // performanceCheckGroup items
      // Index 0: "Higher priority for games" -> export PROTON_PRIORITY_HIGH=1
      if Pos('export PROTON_PRIORITY_HIGH=1', FileLines[i]) > 0 then
      begin
        GetPerformanceCheckBox(0).Checked := True;
        TweakFound := True;
      end;

      // Index 1: "Use WOW64" -> export PROTON_USE_WOW64=1
      if Pos('export PROTON_USE_WOW64=1', FileLines[i]) > 0 then
      begin
        GetPerformanceCheckBox(1).Checked := True;
        TweakFound := True;
      end;

      // Index 2: "Large Address Aware" -> export PROTON_FORCE_LARGE_ADDRESS_AWARE=1
      if Pos('export PROTON_FORCE_LARGE_ADDRESS_AWARE=1', FileLines[i]) > 0 then
      begin
        GetPerformanceCheckBox(2).Checked := True;
        TweakFound := True;
      end;

      // Index 3: "Staging shared memory" -> export STAGING_SHARED_MEMORY=1
      if Pos('export STAGING_SHARED_MEMORY=1', FileLines[i]) > 0 then
      begin
        GetPerformanceCheckBox(3).Checked := True;
        TweakFound := True;
      end;

      // Index 4: "Disable NTSYNC" -> export PROTON_NO_NTSYNC=1
      if Pos('export PROTON_NO_NTSYNC=1', FileLines[i]) > 0 then
      begin
        GetPerformanceCheckBox(4).Checked := True;
        TweakFound := True;
      end;

      // Index 5: "Heap Delay Free" -> export PROTON_HEAP_DELAY_FREE=1
      if Pos('export PROTON_HEAP_DELAY_FREE=1', FileLines[i]) > 0 then
      begin
        GetPerformanceCheckBox(5).Checked := True;
        TweakFound := True;
      end;

      // "No Fast Clears" -> export RADV_DEBUG=nofastclears
      if Pos('export RADV_DEBUG=nofastclears', FileLines[i]) > 0 then
      begin
        nofastclearsCheckBox.Checked := True;
        TweakFound := True;
      end;

      // Check for custom environment variable marker #customenv
      if Pos('#customenv', FileLines[i]) > 0 then
      begin
        Line := FileLines[i];
        // Extract value between 'export ' and ' #customenv'
        StartPos := Pos('export ', Line);
        EndPos := Pos(' #customenv', Line);
        if (StartPos > 0) and (EndPos > StartPos) then
        begin
          // Extract the custom env value (skip 'export ' prefix)
          CustomEnvValue := Copy(Line, StartPos + 7, EndPos - StartPos - 7);
          customenvEdit.Text := Trim(CustomEnvValue);
          TweakFound := True;
        end;
      end;
    end;

  finally
    FileLines.Free;
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
//Enable goverlay tabs
goverlayPageControl.ShowTabs:=true;
vkbasalttabsheet.TabVisible:=false; //disable vkbasalt tab
optiscalertabsheet.TabVisible:=false; //disable optiscaler tab
tweakstabsheet.TabVisible:=false;  //disable tweaks tab

//unselect vkbasalt , optiscaler
vkbasaltLabel.Font.Color:=clgray;
vkbasaltShape.Brush.Color:= DarkerBackgroundColor;
optiscalerLabel.Font.Color:=clgray;
optiscalerShape.Brush.Color:= DarkerBackgroundColor;
tweaksLabel.Font.Color:=clgray;
tweaksShape.Brush.Color:= DarkerBackgroundColor;

// select mangohud
mangohudLabel.Font.Color:=clwhite;
mangohudShape.Brush.Color:= DarkBackgroundColor;
goverlayPageControl.ActivePage:=presetTabsheet;

//Hide notification messages
notificationLabel.Visible:=false;
commandEdit.Visible:=false;
copyBitbtn.Visible:=false;

//Show Global Enable controls for MangoHud tabs (fgmod integration)
geSpeedButton.Visible:=true;
geLabel.Visible:=true;
UpdateGeSpeedButtonState;
UpdateGlobalEnableMenuItemVisibility;

end;

procedure Tgoverlayform.menuscaleTrackBarChange(Sender: TObject);
begin
  //Display new values and trackbar changes (divide by 10)
  menuscalevalueLabel.Caption := FormatFloat('#0.0', menuscaleTrackbar.Position / 10);
end;

procedure Tgoverlayform.mesaRadioButtonChange(Sender: TObject);
begin
      //Enable reflex options
      forcereflexCheckBox.Checked := true;
      forcereflexCheckBox.Enabled := true;
      reflexComboBox.Enabled:= true;
      reflexCombobox.ItemIndex:=2;
      spoofCheckBox.Enabled:=true;
      spoofCheckBox.Checked:=true;
end;

procedure Tgoverlayform.nvidiaRadioButtonChange(Sender: TObject);
begin
      //disable reflex options
      forcereflexCheckBox.Checked := false;
      forcereflexCheckBox.Enabled := false;
      reflexComboBox.Enabled:= false;
      reflexCombobox.ItemIndex:=0;
      spoofCheckBox.Enabled:=false;
      spoofCheckBox.Checked:=false;
end;


procedure Tgoverlayform.optiscalerLabelClick(Sender: TObject);
begin
//Disable tabs
  goverlayPageControl.ShowTabs:=false;
  vkbasalttabsheet.TabVisible:=false;
  tweakstabsheet.TabVisible:=false;


  //unselect mangohud
  mangohudLabel.Font.Color:=clgray;
  mangohudShape.Brush.Color:= DarkerBackgroundColor;
  vkbasaltLabel.Font.Color:=clgray;
  vkbasaltShape.Brush.Color:= DarkerBackgroundColor;
  tweaksLabel.Font.Color:=clgray;
  tweaksShape.Brush.Color:= DarkerBackgroundColor;


  // select optscaler
  optiscalerLabel.Font.Color:=clwhite;
  optiscalerShape.Brush.Color:= DarkBackgroundColor;
  optiscalertabsheet.TabVisible:=true;
  goverlayPageControl.ActivePage:= optiscalerTabsheet;

  //Hide notification messages
  notificationLabel.Visible:=false;
  commandEdit.Visible:=false;
  copyBitbtn.Visible:=false;

  //Update geSpeedButton state for OptiScaler
  UpdateGeSpeedButtonState;
  UpdateGlobalEnableMenuItemVisibility;
end;

procedure Tgoverlayform.ReshadeGitProgress(APhase: string; APercent: Integer);
begin
  if Assigned(FReshadeProgressBar) then
  begin
    if FReshadeProgressBar.Min <> 0 then FReshadeProgressBar.Min := 0;
    if FReshadeProgressBar.Max <> 100 then FReshadeProgressBar.Max := 100;
    FReshadeProgressBar.Position := APercent;
  end;

  if Assigned(FReshadePhaseLabel) then
  begin
    if APhase <> '' then
      FReshadePhaseLabel.Caption := Format('%s: %d%%', [APhase, APercent])
    else
      FReshadePhaseLabel.Caption := Format('%d%%', [APercent]);
  end;

  Application.ProcessMessages;
end;

procedure Tgoverlayform.reshaderefreshBitBtnClick(Sender: TObject);
var
  P: TProcess;
  Buf: array[0..8191] of byte;
  ReadCount: SizeInt;
  Chunk, Piece, S: string;
  Percent: Integer;
  Phase: string;
  GitHelper: TGit2Helper;
  Success: Boolean;



  function ExtractPercentAnywhere(const S: string; out Pct: Integer): Boolean;
  var
    i, j: Integer;
  begin
    // search for a number immediately before '%'
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
    if updateProgressBar.Min <> 0 then updateProgressBar.Min := 0;
    if updateProgressBar.Max <> 100 then updateProgressBar.Max := 100;
    updateProgressBar.Position := Pct;
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
    // split by CR (\r) and LF (\n); git uses \r heavily for progress
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
      // if it was CRLF, remove remaining LF
      if (pMin = 1) and (Length(C) > 0) and ((C[1] = #10) or (C[1] = #13)) then
        Delete(C, 1, 1);

      UpdatePhase(Piece);
      if ExtractPercentAnywhere(Piece, Percent) then
        ApplyPercent(Percent);
    end;

    // also try to extract percent from what's left (partial line)
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

    // merge stderr->stdout and use pipes
    P.Options := [poUsePipes, poStderrToOutPut, poNoConsole];

    // force immediate progress
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

  // Show progress bar
  updateProgressBar.Visible := True;
  updateProgressBar.Min := 0;
  updateProgressBar.Max := 100;
  updateProgressBar.Position := 0;
  pbarLabel.Caption := 'Starting...';
  Phase := '';
  Chunk := '';

  // Setup progress bar and label references for callback
  FReshadeProgressBar := updateProgressBar;
  FReshadePhaseLabel := pbarLabel;

  // Try libgit2 first (Flatpak-compatible), fallback to git command
  Success := False;
  if TGit2Helper.IsLibGit2Available then
  begin
    // Use libgit2 for git operations (no external dependencies)
    try
      GitHelper := TGit2Helper.Create;
      try
        // Setup progress callback
        GitHelper.OnProgress := @ReshadeGitProgress;

        // Clone or pull repository
        if DirectoryExists(RepoDir) then
        begin
          pbarLabel.Caption := 'Updating repository...';
          Success := GitHelper.Pull(RepoDir);
        end
        else
        begin
          pbarLabel.Caption := 'Cloning repository...';
          Success := GitHelper.Clone(URL_RESHADE_SHADERS_REPO, RepoDir);
        end;

        if Success then
        begin
          ApplyPercent(100);
          pbarLabel.Caption := 'Completed';
          SendNotification('Goverlay', 'Reshade shaders are ready', GetIconFile);
        end;

      finally
        GitHelper.Free;
      end;
    except
      on E: Exception do
      begin
        // libgit2 failed, will fallback to external git
        Success := False;
      end;
    end;
  end;

  // Fallback to external git command if libgit2 failed or unavailable
  if not Success then
  begin
    // Fallback to external git command
    try
      if DirectoryExists(RepoDir) then
        StartGit(['-C', 'reshade-shaders', 'pull', '--progress'], VKBASALTFOLDER)
      else
        //StartGit(['clone', '--progress', URL_RESHADE_SHADERS_CROSIRE], VKBASALTFOLDER);
        StartGit(['clone', '--progress', URL_RESHADE_SHADERS_REPO], VKBASALTFOLDER);
      while P.Running do
      begin
        PumpOutput;
        Application.ProcessMessages; // keep UI alive and repaint the bar
      end;

      // drain remaining output after exit
      PumpOutput;

      if P.ExitStatus = 0 then
      begin
        ApplyPercent(100);
        pbarLabel.Caption := 'Completed';
        SendNotification('Goverlay', 'Reshade shaders are ready', GetIconFile);
      end
      else
        ShowMessage('Error while synchronizing reshade repo. Code: ' + IntToStr(P.ExitStatus));
    finally
      if Assigned(P) then P.Free;
    end;
  end;

  // List ALL repository files:
  ListFilesToListBox(RepoDir, aveffectsListbox, ['.fx', '.fxh', '.h', '.glsl']);

  //Enable elements
   aveffectsListbox.Enabled:=true;
   acteffectsListbox.Enabled:=true;
   addBitbtn.Enabled:=true;
   subBitbtn.Enabled:=true;

  // Hide progress bar
  updateProgressBar.Visible := False;

  //Enable update button
  reshaderefreshBitbtn.Enabled:=true;
end;

procedure Tgoverlayform.runpascubetItemClick(Sender: TObject);
begin


  // Check if running in Flatpak
    if IsRunningInFlatpak then
    begin
        // FLATPAK MODE
        if IsCommandAvailable('pascube') then
        begin
           ExecuteGUICommand('MANGOHUD=1 pascube &');
        end
        else
         begin
           // None found
            SendNotification('Goverlay', 'PasCube not located.', GetIconFile);
         end;
    end
    else
    begin
        // NATIVE MODE
        if IsCommandAvailable('pascube') then
        begin
           ExecuteGUICommand('MANGOHUD=1 pascube &');
        end
        else
        begin
           SendNotification('Goverlay', 'PasCube not located.', GetIconFile);
        end;
    end;

end;

procedure Tgoverlayform.saveoptionsItemClick(Sender: TObject);
begin

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
      ShowMessage('vkcube is running!');
      Exit;
    end;
  finally
    Process.Free;
  end;

  // Start vkcube (vulkan demo) only if not already running
  // In Flatpak, MangoHud works via environment variable, not as a wrapper command
  // In Flatpak, use vkcube-wayland binary instead of vkcube --wsi wayland
  if IsRunningInFlatpak then
  begin
      // In Flatpak, vkcube auto-detects WSI
      if (USERSESSION = 'wayland') and IsCommandAvailable('vkcube-wayland') then
         ExecuteGUICommand('MANGOHUD=1 vkcube-wayland &')
      else
         ExecuteGUICommand('MANGOHUD=1 vkcube &');
  end
  else
  begin
    if USERSESSION = 'wayland' then
      ExecuteGUICommand('MANGOHUD=1 vkcube &');
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

end;

procedure Tgoverlayform.aboutMenuItemClick(Sender: TObject);
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
    ShowMessage('Select at least one effect in "available effects".');
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

  //Save button
  saveBitbtn.Click;
end;

procedure Tgoverlayform.blacklistBitBtnClick(Sender: TObject);
begin
  blacklistForm.ShowModal; // Form show as modal window
end;

procedure Tgoverlayform.blacklistMenuItemClick(Sender: TObject);
begin
   blacklistForm.ShowModal; // Form show as modal window
end;

procedure Tgoverlayform.casTrackBarChange(Sender: TObject);
begin
  casvaluelabel.Caption := inttostr(casTrackbar.Position);
end;

procedure Tgoverlayform.copyBitBtnClick(Sender: TObject);
begin
  // Copy the command label content to clipboard
  Clipboard.AsText := commandEdit.Text;

  // Show notification
  SendNotification('GOverlay', 'Command copied to clipboard', GetIconFile);
end;



procedure Tgoverlayform.delayTrackBarChange(Sender: TObject);
begin
    //Display new values and trackbar changes
  delayvalueLabel.Caption:= FormatFloat('#0', delayTrackbar.Position)+ 's';
end;

procedure Tgoverlayform.dlsTrackBarChange(Sender: TObject);
begin
   dlsvaluelabel.Caption := inttostr(dlsTrackbar.Position);
end;

procedure Tgoverlayform.donateMenuItemClick(Sender: TObject);
begin
  try
    if not OpenURL(URL_KOFI) then
      ShowMessage('Unable to open the link in the default web browser.');
  except
    on E: Exception do
      ShowMessage('Error opening the link: ' + E.Message);
  end;
end;

procedure Tgoverlayform.patcherlistLabelClick(Sender: TObject);
begin
  try
    if not OpenURL('https://github.com/optiscaler/OptiPatcher/blob/main/GameSupport.md') then
      ShowMessage('Unable to open the link in the default web browser.');
  except
    on E: Exception do
      ShowMessage('Error opening the link: ' + E.Message);
  end;
end;

procedure Tgoverlayform.durationTrackBarChange(Sender: TObject);
begin
  //Display new values and trackbar changes
  durationvalueLabel.Caption:= FormatFloat('#0', durationTrackbar.Position) + 's' ;
end;

procedure Tgoverlayform.forcelatencyflexCheckBoxChange(Sender: TObject);
begin
  // Enable/disable latencyflexComboBox based on forcelatencyflexCheckBox state
  latencyflexComboBox.Enabled := forcelatencyflexCheckBox.Checked;
end;

procedure Tgoverlayform.forcereflexCheckBoxChange(Sender: TObject);
begin
   // Enable/disable reflexComboBox based on forcereflexCheckBox state
  reflexComboBox.Enabled := forcereflexCheckBox.Checked;
end;

procedure Tgoverlayform.gputempCheckBoxChange(Sender: TObject);
begin
  // GPU temperature depends on GPU average load - automatically enable it when temp is checked
  if gputempCheckBox.Checked then
    gpuavgloadCheckBox.Checked := True;
end;

procedure Tgoverlayform.cputempCheckBoxChange(Sender: TObject);
begin
  // CPU temperature depends on CPU average load - automatically enable it when temp is checked
  if cputempCheckBox.Checked then
    cpuavgloadCheckBox.Checked := True;
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
var
  ConfigLines: TStringList;
begin

  //Set all checkboxes to false
  SetAllCheckBoxesToFalse;

  ConfigLines := TStringList.Create;
  try
    ConfigLines.Add('fps_only');
    ConfigLines.SaveToFile(MANGOHUDCFGFILE);
  finally
    ConfigLines.Free;
  end;

  // Popup a notification
  SendNotification('MangoHud', 'Configuration saved', GetIconFile);

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


  //Save button
  saveBitbtn.Click;


end;

procedure Tgoverlayform.fxaaTrackBarChange(Sender: TObject);
begin
  fxaavaluelabel.Caption := inttostr(fxaaTrackbar.Position);
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


//Detect GPU and set colors according to BRAND using systemdetector
GPUBrand := GPUVendorToString(DetectGPUVendor);

// Change button colors based on GPU brand
if Pos('AMD', GPUBrand) > 0 then
 begin
   gpuColorButton.ButtonColor := COLOR_AMD_RED;
   vramColorButton.ButtonColor := COLOR_AMD_RED;
 end
 else if Pos('NVIDIA', GPUBrand) > 0 then
 begin
   gpuColorButton.ButtonColor := COLOR_NVIDIA_GREEN;
   vramColorButton.ButtonColor := COLOR_NVIDIA_GREEN;
 end
 else if Pos('Intel', GPUBrand) > 0 then
 begin
   if Pos('ARC', GPUBrand) > 0 then
   begin
     gpuColorButton.ButtonColor := COLOR_INTEL_ARC_YELLOW;
     vramColorButton.ButtonColor := COLOR_INTEL_ARC_YELLOW;
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

procedure Tgoverlayform.gpuframesjouleBitBtnClick(Sender: TObject);
begin
  // Toggle caption between 'Frames / Joule' and 'Joules / Frame'
  // Both buttons share the same caption
  if gpuframesjouleBitBtn.Caption = 'Frames / Joule' then
  begin
    gpuframesjouleBitBtn.Caption := 'Joules / Frame';
    cpuframesjouleBitBtn.Caption := 'Joules / Frame';
  end
  else
  begin
    gpuframesjouleBitBtn.Caption := 'Frames / Joule';
    cpuframesjouleBitBtn.Caption := 'Frames / Joule';
  end;
end;

procedure Tgoverlayform.gupdateBitBtnClick(Sender: TObject);
  var
  ReleaseURL: string;
begin
  if GLatestVersion <> '' then
  begin
    ReleaseURL := URL_GOVERLAY_RELEASES + GLatestVersion;
    OpenURL(ReleaseURL);
  end;
end;

procedure Tgoverlayform.howtoBitBtnClick(Sender: TObject);
begin
  howtoform.showmodal;
end;



procedure Tgoverlayform.intelpowerfixBitBtnClick(Sender: TObject);
var
  Response: Integer;

begin
    // Check if running in Flatpak - cannot modify /sys permissions
    if IsRunningInFlatpak then
    begin
      ShowMessage('Intel CPU power monitoring fix is not available in Flatpak.' + LineEnding + LineEnding +
                  'Flatpak applications cannot modify system file permissions in /sys/.' + LineEnding + LineEnding +
                  'This fix must be applied from outside the Flatpak sandbox on the host system.');
      Exit;
    end;

    Response := MessageDlg('Due to a known vulnerability in Intel CPUs,  the corresponding energy_uj file has to be readable by corresponding user. Having the file readable may potentially be a security vulnerability persisting until system reboots.', mtConfirmation, [mbYes, mbNo], 0);

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

procedure Tgoverlayform.optversionComboBoxChange(Sender: TObject);
begin
  // When user changes the OptiScaler channel, automatically check for updates
  if Assigned(FOptiscalerUpdate) then
    FOptiscalerUpdate.CheckForUpdatesOnClick;
end;

procedure Tgoverlayform.fsrversionComboBoxChange(Sender: TObject);
begin
  // Disable emufp8CheckBox when "4.0.2 (INT8)" is selected (ItemIndex = 1)
  // Enable emufp8CheckBox when "Latest (FP8)" is selected (ItemIndex = 0)
  case fsrversionComboBox.ItemIndex of
    0: // Latest (FP8)
      begin
        emufp8CheckBox.Enabled := True;
      end;
    1: // 4.0.2 (INT8)
      begin
        emufp8CheckBox.Enabled := False;
        emufp8CheckBox.Checked := False;  // Also uncheck when disabled
      end;
  end;
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
  // Control menu item visibility based on active tab
  if goverlayPageControl.ActivePage = vkbasaltTabSheet then
  begin
    // vkBasalt tab: show save options and save as, hide MangoHud-specific items
    saveoptionsItem.Visible := True;
    saveasMenuItem.Visible := True;
    savecustomMenuItem.Visible := False;
    deckpreset1MenuItem.Visible := False;
    deckpreset2MenuItem.Visible := False;
    deckpreset3MenuItem.Visible := False;
    deckpreset4MenuItem.Visible := False;
    blacklistMenuItem.Visible := False;
    runvkcubeItem.Visible := True;
    runpascubetItem.Visible := True;
    donateMenuItem.Visible := True;
    aboutMenuItem.Visible := True;
  end
  else if (goverlayPageControl.ActivePage = optiscalerTabSheet) or
          (goverlayPageControl.ActivePage = tweaksTabSheet) then
  begin
    // OptiScaler and Tweaks tabs: show only donate and about options
    saveoptionsItem.Visible := False;
    saveasMenuItem.Visible := False;
    savecustomMenuItem.Visible := False;
    deckpreset1MenuItem.Visible := False;
    deckpreset2MenuItem.Visible := False;
    deckpreset3MenuItem.Visible := False;
    deckpreset4MenuItem.Visible := False;
    blacklistMenuItem.Visible := False;
    runvkcubeItem.Visible := False;
    runpascubetItem.Visible := False;
    donateMenuItem.Visible := True;
    aboutMenuItem.Visible := True;
  end
  else
  begin
    // MangoHud tab: show all options
    saveoptionsItem.Visible := True;
    saveasMenuItem.Visible := True;
    savecustomMenuItem.Visible := True;
    deckpreset1MenuItem.Visible := True;
    deckpreset2MenuItem.Visible := True;
    deckpreset3MenuItem.Visible := True;
    deckpreset4MenuItem.Visible := True;
    blacklistMenuItem.Visible := True;
    runvkcubeItem.Visible := True;
    runpascubetItem.Visible := True;
    donateMenuItem.Visible := True;
    aboutMenuItem.Visible := True;
  end;

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
  FONTDIR, TempFile: String;
  TempFiles: TStringList;

  //vkbasalt vars
  RepoDir, RelPath, EffectName, EffectKey, FullPath, EffectsLine: string;
  TexPath, IncPath: string;
  Lines: TStringList;
  Sharp: Double;
  FxaaQuality: Double;
  SmaaCorner: Double;
  DlsSharp: Double;
  FS: TFormatSettings;

  //OptiScaler vars
  FGModFilePath, SelectedDllName, DllNameWithoutExt: string;
  FGModPath, LaunchCommand, VarsFilePath: string;
  FGModLines: TStringList;
  LineIndex: Integer;
  LineFound, WineOverrideFound: Boolean;

  // OptiScaler.ini vars
  OptiScalerIniPath, SelectedShortcutKey, ScaleValue: string;
  OptiScalerIniLines: TStringList;
  ShortcutKeyFound, ScaleFound, InMenuSection: Boolean;
  ScaleFloat: Double;
  OverrideNvapiDllValue: string;
  OverrideNvapiDllFound: Boolean;
  DxgiValue: string;
  DxgiFound: Boolean;
  LoadAsiPluginsValue: string;
  LoadAsiPluginsFound: Boolean;

  // fakenvapi.ini vars
FakeNvapiIniPath: string;
FakeNvapiIniLines: TStringList;
ForceReflexValue: string;
ForceReflexFound: Boolean;
ForceLatencyFlexValue, LatencyFlexModeValue: string;
ForceLatencyFlexFound, LatencyFlexModeFound: Boolean;
EnableTraceLogsValue: string;
EnableTraceLogsFound: Boolean;

  procedure AddEffectToLine(const NameOnly: string);
   begin
     if EffectsLine = '' then
       EffectsLine := NameOnly
     else if Pos(':' + NameOnly + ':', ':' + EffectsLine + ':') = 0 then
       EffectsLine := EffectsLine + ':' + NameOnly;
   end;

  begin

  // ################### SAVE TWEAKS TAB SETTINGS

    // Check if we're on the Tweaks tab
    if goverlayPageControl.ActivePage = tweaksTabSheet then
    begin
      // Build the command line from checked items
      LaunchCommand := '';

      // Index 0: "Simulate Steam Deck" -> SteamDeck=1
      if GetGeneralCheckBox(0).Checked then
        LaunchCommand := LaunchCommand + 'SteamDeck=1 ';

      // Index 2: "Enable HDR" -> PROTON_ENABLE_HDR=1
      if GetGeneralCheckBox(2).Checked then
        LaunchCommand := LaunchCommand + 'PROTON_ENABLE_HDR=1 ';

      // Index 3: "Enable Wayland" -> PROTON_ENABLE_WAYLAND=1
      if GetGeneralCheckBox(3).Checked then
        LaunchCommand := LaunchCommand + 'PROTON_ENABLE_WAYLAND=1 ';

      // Index 4: "Active Proton Logs" -> PROTON_LOG=1
      if GetGeneralCheckBox(4).Checked then
        LaunchCommand := LaunchCommand + 'PROTON_LOG=1 ';

      // Index 5: "Use SDL Input" -> PROTON_USE_SDL=1
      if GetGeneralCheckBox(5).Checked then
        LaunchCommand := LaunchCommand + 'PROTON_USE_SDL=1 ';

      // graphicsCheckGroup items
      // Index 0: "Emulate RT (old AMD)" -> RADV_PERFTEST=rt,emulate_rt
      if GetGraphicsCheckBox(0).Checked then
        LaunchCommand := LaunchCommand + 'RADV_PERFTEST=rt,emulate_rt ';

      // Index 1: "Hide Nvidia GPU" -> PROTON_HIDE_NVIDIA_GPU=1
      if GetGraphicsCheckBox(1).Checked then
        LaunchCommand := LaunchCommand + 'PROTON_HIDE_NVIDIA_GPU=1 ';

      // Index 2: "Force enable NVAPI" -> PROTON_ENABLE_NVAPI=1
      if GetGraphicsCheckBox(2).Checked then
        LaunchCommand := LaunchCommand + 'PROTON_ENABLE_NVAPI=1 ';

      // Index 3: "Use old WINED3D" -> PROTON_USE_WINED3D=1
      if GetGraphicsCheckBox(3).Checked then
        LaunchCommand := LaunchCommand + 'PROTON_USE_WINED3D=1 ';

      // Index 4: "Force Zink" -> MESA_LOADER_DRIVER_OVERRIDE=zink (plus __GLX_VENDOR_LIBRARY_NAME for NVIDIA)
      if GetGraphicsCheckBox(4).Checked then
      begin
        if IsNvidiaModuleLoaded then
          LaunchCommand := LaunchCommand + '__GLX_VENDOR_LIBRARY_NAME=mesa MESA_LOADER_DRIVER_OVERRIDE=zink '
        else
          LaunchCommand := LaunchCommand + 'MESA_LOADER_DRIVER_OVERRIDE=zink ';
      end;

      // "No Fast Clears" -> RADV_DEBUG=nofastclears
      if nofastclearsCheckBox.Checked then
        LaunchCommand := LaunchCommand + 'RADV_DEBUG=nofastclears ';

      // performanceCheckGroup items
      // Index 0: "Higher priority for games" -> PROTON_PRIORITY_HIGH=1
      if GetPerformanceCheckBox(0).Checked then
        LaunchCommand := LaunchCommand + 'PROTON_PRIORITY_HIGH=1 ';

      // Index 1: "Use WOW64" -> PROTON_USE_WOW64=1
      if GetPerformanceCheckBox(1).Checked then
        LaunchCommand := LaunchCommand + 'PROTON_USE_WOW64=1 ';

      // Index 2: "Large Address Aware" -> PROTON_FORCE_LARGE_ADDRESS_AWARE=1
      if GetPerformanceCheckBox(2).Checked then
        LaunchCommand := LaunchCommand + 'PROTON_FORCE_LARGE_ADDRESS_AWARE=1 ';

      // Index 3: "Staging shared memory" -> STAGING_SHARED_MEMORY=1
      if GetPerformanceCheckBox(3).Checked then
        LaunchCommand := LaunchCommand + 'STAGING_SHARED_MEMORY=1 ';

      // Index 4: "Disable NTSYNC" -> PROTON_NO_NTSYNC=1
      if GetPerformanceCheckBox(4).Checked then
        LaunchCommand := LaunchCommand + 'PROTON_NO_NTSYNC=1 ';

      // Index 5: "Heap Delay Free" -> PROTON_HEAP_DELAY_FREE=1
      if GetPerformanceCheckBox(5).Checked then
        LaunchCommand := LaunchCommand + 'PROTON_HEAP_DELAY_FREE=1 ';

      // Index 1: "Always use GameMode" -> -- env gamemoderun (before %command%)
      if GetGeneralCheckBox(1).Checked then
        LaunchCommand := LaunchCommand + '-- env gamemoderun ';

      // Add custom environment variables from customenvEdit if not empty
      if Trim(customenvEdit.Text) <> '' then
        LaunchCommand := LaunchCommand + Trim(customenvEdit.Text) + ' ';

      // Always end with %command%
      LaunchCommand := LaunchCommand + '%command%';

      // Check if geSpeedButton is active (ImageIndex = 1)
      if geSpeedButton.ImageIndex = 1 then
      begin
        // geSpeedButton is ON - modify the fgmod file
        FGModFilePath := GetFGModPath + PathDelim + 'fgmod';

        if FileExists(FGModFilePath) then
        begin
          FGModLines := TStringList.Create;
          try
            // Load the fgmod file
            FGModLines.LoadFromFile(FGModFilePath);

            // First, remove any existing tweak export lines to avoid duplicates
            for LineIndex := FGModLines.Count - 1 downto 0 do
            begin
              if (Pos('export PROTON_ENABLE_HDR=1', FGModLines[LineIndex]) > 0) or
                 (Pos('export ENABLE_HDR_WSI=1', FGModLines[LineIndex]) > 0) or
                 (Pos('export PROTON_ENABLE_WAYLAND=1', FGModLines[LineIndex]) > 0) or
                 (Pos('export PROTON_LOG=1', FGModLines[LineIndex]) > 0) or
                 (Pos('export PROTON_USE_SDL=1', FGModLines[LineIndex]) > 0) or
                 (Pos('#gamemode', FGModLines[LineIndex]) > 0) or
                 // graphicsCheckGroup exports
                 (Pos('export RADV_PERFTEST=rt,emulate_rt', FGModLines[LineIndex]) > 0) or
                 (Pos('export PROTON_HIDE_NVIDIA_GPU=1', FGModLines[LineIndex]) > 0) or
                 (Pos('export PROTON_ENABLE_NVAPI=1', FGModLines[LineIndex]) > 0) or
                 (Pos('export PROTON_USE_WINED3D=1', FGModLines[LineIndex]) > 0) or
                 // Zink exports
                 (Pos('export MESA_LOADER_DRIVER_OVERRIDE=zink', FGModLines[LineIndex]) > 0) or
                 (Pos('export __GLX_VENDOR_LIBRARY_NAME=mesa', FGModLines[LineIndex]) > 0) or
                 (Pos('export RADV_DEBUG=nofastclears', FGModLines[LineIndex]) > 0) or
                 // performanceCheckGroup exports
                 (Pos('export PROTON_PRIORITY_HIGH=1', FGModLines[LineIndex]) > 0) or
                 (Pos('export PROTON_USE_WOW64=1', FGModLines[LineIndex]) > 0) or
                 (Pos('export PROTON_FORCE_LARGE_ADDRESS_AWARE=1', FGModLines[LineIndex]) > 0) or
                 (Pos('export STAGING_SHARED_MEMORY=1', FGModLines[LineIndex]) > 0) or
                 (Pos('export PROTON_NO_NTSYNC=1', FGModLines[LineIndex]) > 0) or
                 (Pos('export PROTON_HEAP_DELAY_FREE=1', FGModLines[LineIndex]) > 0) or
                 // Custom environment variable marker
                 (Pos('#customenv', FGModLines[LineIndex]) > 0) then
              begin
                FGModLines.Delete(LineIndex);
              end;
            end;

            // Find the "# Execute the original command" line and add enabled tweaks after it
            for LineIndex := 0 to FGModLines.Count - 1 do
            begin
              if Pos('# Execute the original command', FGModLines[LineIndex]) > 0 then
              begin
                // Insert lines in reverse order so they appear in correct order after insertion
                // Index 1: "Always use GameMode" -> #gamemode (comment marker)
                if GetGeneralCheckBox(1).Checked then
                  FGModLines.Insert(LineIndex + 1, '  #gamemode');

                // Index 5: "Use SDL Input" -> export PROTON_USE_SDL=1
                if GetGeneralCheckBox(5).Checked then
                  FGModLines.Insert(LineIndex + 1, '  export PROTON_USE_SDL=1');

                // Index 4: "Active Proton Logs" -> export PROTON_LOG=1
                if GetGeneralCheckBox(4).Checked then
                  FGModLines.Insert(LineIndex + 1, '  export PROTON_LOG=1');

                // Index 3: "Enable Wayland" -> export PROTON_ENABLE_WAYLAND=1
                if GetGeneralCheckBox(3).Checked then
                  FGModLines.Insert(LineIndex + 1, '  export PROTON_ENABLE_WAYLAND=1');

                // Index 2: "Enable HDR" -> export PROTON_ENABLE_HDR=1 and ENABLE_HDR_WSI=1
                if GetGeneralCheckBox(2).Checked then
                begin
                  FGModLines.Insert(LineIndex + 1, '  export ENABLE_HDR_WSI=1');
                  FGModLines.Insert(LineIndex + 1, '  export PROTON_ENABLE_HDR=1');
                end;

                // graphicsCheckGroup items (insert in reverse order)
                // Index 3: "Use old WINED3D" -> export PROTON_USE_WINED3D=1
                if GetGraphicsCheckBox(3).Checked then
                  FGModLines.Insert(LineIndex + 1, '  export PROTON_USE_WINED3D=1');

                // Index 2: "Force enable NVAPI" -> export PROTON_ENABLE_NVAPI=1
                if GetGraphicsCheckBox(2).Checked then
                  FGModLines.Insert(LineIndex + 1, '  export PROTON_ENABLE_NVAPI=1');

                // Index 1: "Hide Nvidia GPU" -> export PROTON_HIDE_NVIDIA_GPU=1
                if GetGraphicsCheckBox(1).Checked then
                  FGModLines.Insert(LineIndex + 1, '  export PROTON_HIDE_NVIDIA_GPU=1');

                if GetGraphicsCheckBox(0).Checked then
                  FGModLines.Insert(LineIndex + 1, '  export RADV_PERFTEST=rt,emulate_rt');

                // "No Fast Clears" -> export RADV_DEBUG=nofastclears
                if nofastclearsCheckBox.Checked then
                  FGModLines.Insert(LineIndex + 1, '  export RADV_DEBUG=nofastclears');

                // Index 4: "Force Zink" -> MESA_LOADER_DRIVER_OVERRIDE=zink (plus __GLX_VENDOR_LIBRARY_NAME for NVIDIA)
                if GetGraphicsCheckBox(4).Checked then
                begin
                  if IsNvidiaModuleLoaded then
                  begin
                    FGModLines.Insert(LineIndex + 1, '  export MESA_LOADER_DRIVER_OVERRIDE=zink');
                    FGModLines.Insert(LineIndex + 1, '  export __GLX_VENDOR_LIBRARY_NAME=mesa');
                  end
                  else
                  begin
                    FGModLines.Insert(LineIndex + 1, '  export MESA_LOADER_DRIVER_OVERRIDE=zink');
                  end;
                end;

                // performanceCheckGroup items (insert in reverse order)
                // Index 5: "Heap Delay Free" -> export PROTON_HEAP_DELAY_FREE=1
                if GetPerformanceCheckBox(5).Checked then
                  FGModLines.Insert(LineIndex + 1, '  export PROTON_HEAP_DELAY_FREE=1');

                // Index 4: "Disable NTSYNC" -> export PROTON_NO_NTSYNC=1
                if GetPerformanceCheckBox(4).Checked then
                  FGModLines.Insert(LineIndex + 1, '  export PROTON_NO_NTSYNC=1');

                // Index 3: "Staging shared memory" -> export STAGING_SHARED_MEMORY=1
                if GetPerformanceCheckBox(3).Checked then
                  FGModLines.Insert(LineIndex + 1, '  export STAGING_SHARED_MEMORY=1');

                // Index 2: "Large Address Aware" -> export PROTON_FORCE_LARGE_ADDRESS_AWARE=1
                if GetPerformanceCheckBox(2).Checked then
                  FGModLines.Insert(LineIndex + 1, '  export PROTON_FORCE_LARGE_ADDRESS_AWARE=1');

                // Index 1: "Use WOW64" -> export PROTON_USE_WOW64=1
                if GetPerformanceCheckBox(1).Checked then
                  FGModLines.Insert(LineIndex + 1, '  export PROTON_USE_WOW64=1');

                // Index 0: "Higher priority for games" -> export PROTON_PRIORITY_HIGH=1
                if GetPerformanceCheckBox(0).Checked then
                  FGModLines.Insert(LineIndex + 1, '  export PROTON_PRIORITY_HIGH=1');

                // Custom environment variables from customenvEdit
                if Trim(customenvEdit.Text) <> '' then
                  FGModLines.Insert(LineIndex + 1, '  export ' + Trim(customenvEdit.Text) + ' #customenv');

                Break;
              end;
            end;

            // Handle "Simulate Steam Deck" (index 0) - modifies existing SteamDeck line
            for LineIndex := 0 to FGModLines.Count - 1 do
            begin
              if Pos('export SteamDeck=', FGModLines[LineIndex]) > 0 then
              begin
                if GetGeneralCheckBox(0).Checked then
                  FGModLines[LineIndex] := '  export SteamDeck=1'
                else
                  FGModLines[LineIndex] := '  export SteamDeck=0';
                Break;
              end;
            end;

            // Save the modified file
            FGModLines.SaveToFile(FGModFilePath);

            // Show notification
            SendNotification('Tweaks', 'Configuration saved', GetIconFile);

            // Show the howto button after saving Tweaks configuration
            howtoBitBtn.Visible := True;

            // Build launch command with full absolute path for fgmod
            LaunchCommand := GetFGModPath + '/fgmod ';

            // Index 1: "Always use GameMode" -> -- env gamemoderun (before %command%)
            if GetGeneralCheckBox(1).Checked then
              LaunchCommand := LaunchCommand + '-- env gamemoderun ';

            // Always end with %command%
            LaunchCommand := LaunchCommand + '%command%';

          finally
            FGModLines.Free;
          end;
        end
        else
        begin
          ShowMessage('Error: fgmod file not found at: ' + FGModFilePath);
          Exit;
        end;
      end
      else
      begin
        // geSpeedButton is OFF - just show the command line without modifying fgmod
        SendNotification('Tweaks', 'Launch command generated', GetIconFile);
      end;

      // Update notificationLabel
      notificationLabel.Caption := 'Command :';
      notificationLabel.Font.Color := clOlive;
      notificationLabel.Font.Style := [fsBold];
      notificationLabel.Visible := True;

      // Update commandLabel with launch command
      commandEdit.Text := LaunchCommand;
      
      commandEdit.Visible := True;
      
      copyBitBtn.Visible := True;

      Exit; // Exit after saving Tweaks settings
    end;

  // ################### SAVE OPTISCALER SETTINGS

    // Check if we're on the OptiScaler tab
    if goverlayPageControl.ActivePage = optiscalerTabSheet then
    begin
      // If geSpeedButton is OFF, just show notification and exit - no fgmod modification needed
      if geSpeedButton.ImageIndex = 0 then
      begin
        SendNotification('OptiScaler', 'Configuration saved (Auto Enable disabled)', GetIconFile);
        Exit;
      end;

      // Get the fgmod file path
      FGModFilePath := GetOptiScalerInstallPath + PathDelim + 'fgmod';

      // Check if fgmod file exists
      if FileExists(FGModFilePath) then
      begin
        FGModLines := TStringList.Create;
        try
          // Load the fgmod file
          FGModLines.LoadFromFile(FGModFilePath);

          // Get selected DLL name from combobox
          case filenameComboBox.ItemIndex of
            0: SelectedDllName := 'dxgi.dll';
            1: SelectedDllName := 'version.dll';
            2: SelectedDllName := 'dbghelp.dll';
            3: SelectedDllName := 'd3d12.dll';
            4: SelectedDllName := 'wininet.dll';
            5: SelectedDllName := 'winhttp.dll';
            6: SelectedDllName := 'winmm.dll';
            7: SelectedDllName := 'OptiScaler.asi';
          else
            SelectedDllName := 'dxgi.dll'; // Default
          end;

          // Extract DLL name without extension
          DllNameWithoutExt := ChangeFileExt(SelectedDllName, '');

          // Search for the line containing dll_name="${DLL:-
          LineFound := False;
          for LineIndex := 0 to FGModLines.Count - 1 do
          begin
            if Pos('dll_name="${DLL:-', FGModLines[LineIndex]) > 0 then
            begin
              // Replace the line with the new DLL name
              FGModLines[LineIndex] := 'dll_name="${DLL:-' + SelectedDllName + '}"';
              LineFound := True;
              Break;
            end;
          end;

          // Search for the WINEDLLOVERRIDES line and update it, or add it if not found
          WineOverrideFound := False;
          if LineFound then
          begin
            for LineIndex := 0 to FGModLines.Count - 1 do
            begin
              if Pos('export WINEDLLOVERRIDES="$WINEDLLOVERRIDES,', FGModLines[LineIndex]) > 0 then
              begin
                // Replace the line with the new DLL name (without extension)
                FGModLines[LineIndex] := 'export WINEDLLOVERRIDES="$WINEDLLOVERRIDES,' + DllNameWithoutExt + '=n,b"';
                WineOverrideFound := True;
                Break;
              end;
            end;

            // If WINEDLLOVERRIDES line not found, add it after "# Execute the original command"
            if not WineOverrideFound then
            begin
              for LineIndex := 0 to FGModLines.Count - 1 do
              begin
                if Pos('# Execute the original command', FGModLines[LineIndex]) > 0 then
                begin
                  FGModLines.Insert(LineIndex + 1, '  export WINEDLLOVERRIDES="$WINEDLLOVERRIDES,' + DllNameWithoutExt + '=n,b"');
                  WineOverrideFound := True;
                  Break;
                end;
              end;
            end;
          end;

          // Handle emufp8CheckBox - add or remove DXIL_SPIRV_CONFIG line
          if WineOverrideFound then
          begin
            // First, find and remove any existing DXIL_SPIRV_CONFIG line
            for LineIndex := FGModLines.Count - 1 downto 0 do
            begin
              if Pos('export DXIL_SPIRV_CONFIG="wmma_rdna3_workaround"', FGModLines[LineIndex]) > 0 then
              begin
                FGModLines.Delete(LineIndex);
                Break; // Only one such line should exist
              end;
            end;

            // If checkbox is checked, add the line after WINEDLLOVERRIDES
            if emufp8CheckBox.Checked then
            begin
              for LineIndex := 0 to FGModLines.Count - 1 do
              begin
                if Pos('export WINEDLLOVERRIDES="$WINEDLLOVERRIDES,', FGModLines[LineIndex]) > 0 then
                begin
                  // Insert the DXIL_SPIRV_CONFIG line right after WINEDLLOVERRIDES
                  FGModLines.Insert(LineIndex + 1, '  export DXIL_SPIRV_CONFIG="wmma_rdna3_workaround"');
                  Break;
                end;
              end;
            end;
          end;

          if LineFound and WineOverrideFound then
          begin
            // Save the modified file
            FGModLines.SaveToFile(FGModFilePath);

                   // Get OptiScaler.ini file path
          OptiScalerIniPath := GetOptiScalerInstallPath + PathDelim + 'OptiScaler.ini';

          // Get selected ShortcutKey from shortcutkeyComboBox
          case shortcutkeyComboBox.ItemIndex of
            0: SelectedShortcutKey := 'auto';
            1: SelectedShortcutKey := '0x70';
            2: SelectedShortcutKey := '0x71';
            3: SelectedShortcutKey := '0x72';
            4: SelectedShortcutKey := '0x73';
          else
            SelectedShortcutKey := 'auto'; // Default
          end;


          // Calculate Scale value from menuscaleTrackBar (divide by 10)
          ScaleFloat := menuscaleTrackBar.Position / 10.0;
          // Format with dot as decimal separator
          FS := DefaultFormatSettings;
          FS.DecimalSeparator := '.';
          ScaleValue := FloatToStrF(ScaleFloat, ffFixed, 3, 1, FS);

          // Get OverrideNvapiDll value from overrideCheckBox
          if overrideCheckBox.Checked then
            OverrideNvapiDllValue := 'true' // Checkbox is checked, set to true
          else
            OverrideNvapiDllValue := 'auto'; // Checkbox is not checked, set to auto

          // Get Dxgi value from spoofCheckBox (Spoof DLSS inputs)
          if spoofCheckBox.Checked then
            DxgiValue := 'auto' // Checkbox is checked, set to auto
          else
            DxgiValue := 'false'; // Checkbox is not checked, set to false

          // Get LoadAsiPlugins value from optipatcherCheckBox
          if optipatcherCheckBox.Checked then
            LoadAsiPluginsValue := 'true'
          else
            LoadAsiPluginsValue := 'auto';

          // Check if OptiScaler.ini exists
              if FileExists(OptiScalerIniPath) then
              begin
                OptiScalerIniLines := TStringList.Create;
                try
                  // Load the OptiScaler.ini file
                  OptiScalerIniLines.LoadFromFile(OptiScalerIniPath);

                  // Search for the line containing ShortcutKey=
                  OverrideNvapiDllFound := False;
                  ShortcutKeyFound := False;
                  ScaleFound := False;
                  DxgiFound := False;
                  LoadAsiPluginsFound := False;
                  InMenuSection := False;

                  for LineIndex := 0 to OptiScalerIniLines.Count - 1 do
                  begin
                    if Trim(OptiScalerIniLines[LineIndex]) = '[Menu]' then
                      InMenuSection := True
                    else if (Length(Trim(OptiScalerIniLines[LineIndex])) > 0) and (Trim(OptiScalerIniLines[LineIndex])[1] = '[') then
                      InMenuSection := False;

                    // Check for ShortcutKey line
                    if (Pos('ShortcutKey=', OptiScalerIniLines[LineIndex]) > 0) and InMenuSection and not ShortcutKeyFound then
                    begin
                      // Replace the line with the new ShortcutKey value
                      OptiScalerIniLines[LineIndex] := 'ShortcutKey=' + SelectedShortcutKey;
                      ShortcutKeyFound := True;
                    end;

                    // Check for Scale line
                    if (Pos('Scale=', OptiScalerIniLines[LineIndex]) > 0) and InMenuSection and not ScaleFound then
                    begin
                      // Replace the line with the new Scale value
                      OptiScalerIniLines[LineIndex] := 'Scale=' + ScaleValue;
                      ScaleFound := True;
                    end;

                    // Check for OverrideNvapiDll line
                    if Pos('OverrideNvapiDll=', OptiScalerIniLines[LineIndex]) > 0 then
                    begin
                      // Replace the line with the new OverrideNvapiDll value
                      OptiScalerIniLines[LineIndex] := 'OverrideNvapiDll=' + OverrideNvapiDllValue;
                      OverrideNvapiDllFound := True;
                    end;

                    // Check for Dxgi line (Spoof DLSS inputs)
                    if Pos('Dxgi=', OptiScalerIniLines[LineIndex]) > 0 then
                    begin
                      // Replace the line with the new Dxgi value
                      OptiScalerIniLines[LineIndex] := 'Dxgi=' + DxgiValue;
                      DxgiFound := True;
                    end;

                    // Check for LoadAsiPlugins line
                    if Pos('LoadAsiPlugins=', OptiScalerIniLines[LineIndex]) > 0 then
                    begin
                      // Replace the line with the new LoadAsiPlugins value
                      OptiScalerIniLines[LineIndex] := 'LoadAsiPlugins=' + LoadAsiPluginsValue;
                      LoadAsiPluginsFound := True;
                    end;

                    // Exit loop if all found
                     if ShortcutKeyFound and ScaleFound and OverrideNvapiDllFound and DxgiFound and LoadAsiPluginsFound then
                       Break;
                  end;

                  if not LoadAsiPluginsFound then
                    OptiScalerIniLines.Add('LoadAsiPlugins=' + LoadAsiPluginsValue);

                  if ShortcutKeyFound and ScaleFound then
                  begin
                    // Save the modified OptiScaler.ini file
                    OptiScalerIniLines.SaveToFile(OptiScalerIniPath);
                  end
                  else
                  begin
                    if not ShortcutKeyFound then
                      ShowMessage('Warning: Could not find ShortcutKey line in OptiScaler.ini file');
                    if not ScaleFound then
                      ShowMessage('Warning: Could not find Scale line in OptiScaler.ini file');
                    if not OverrideNvapiDllFound then
                      ShowMessage('Warning: Could not find OverrideNvapiDll line in OptiScaler.ini file');
                    if not DxgiFound then
                      ShowMessage('Warning: Could not find Dxgi line in OptiScaler.ini file');
                  end;

            finally
              OptiScalerIniLines.Free;
            end;
          end;
          // Silently skip if OptiScaler.ini doesn't exist (OptiScaler not installed yet)

          // ##### Now modify fakenvapi.ini file #####

          // Always modify fakenvapi.ini file (set to 0 if checkbox not checked)
          begin
            // Get fakenvapi.ini file path
            FakeNvapiIniPath := GetOptiScalerInstallPath + PathDelim + 'fakenvapi.ini';

            // Initialize found flags
            ForceReflexFound := False;
            ForceLatencyFlexFound := False;
            LatencyFlexModeFound := False;
            EnableTraceLogsFound := False;

            // Get selected force_reflex value from reflexComboBox
            if forcereflexCheckBox.Checked then
            begin
              // Use reflexComboBox value (0, 1 or 2)
              case reflexComboBox.ItemIndex of
                0: ForceReflexValue := '0'; // Follow game setting
                1: ForceReflexValue := '1'; // Force disable
                2: ForceReflexValue := '2'; // Force enable
              end;
            end
            else
            begin
              ForceReflexValue := '0'; // Checkbox unchecked = 0 (ignore combobox)
            end;

            // Get force_latencyflex and latencyflex_mode values
                       if forcelatencyflexCheckBox.Checked then
                       begin
                         ForceLatencyFlexValue := '1'; // Checkbox is checked, set to 1

                         // Get latencyflex_mode from latencyflexComboBox
                         case latencyflexComboBox.ItemIndex of
                           0: LatencyFlexModeValue := '0'; // Conservative
                           1: LatencyFlexModeValue := '1'; // Agressive
                           2: LatencyFlexModeValue := '2'; // Use reflex ids
                         else
                           LatencyFlexModeValue := '0'; // Default
                         end;
                       end
                       else
                       begin
                         ForceLatencyFlexValue := '0'; // Checkbox is not checked, set to 0
                         LatencyFlexModeValue := '0'; // Also set mode to 0
                       end;

            // Get enable_trace_logs value from tracelogCheckBox
            if tracelogCheckBox.Checked then
              EnableTraceLogsValue := '1' // Checkbox is checked, set to 1
            else
              EnableTraceLogsValue := '0'; // Checkbox is not checked, set to 0

            // Check if fakenvapi.ini exists
            if FileExists(FakeNvapiIniPath) then
            begin
              FakeNvapiIniLines := TStringList.Create;
              try
                // Load the fakenvapi.ini file
                FakeNvapiIniLines.LoadFromFile(FakeNvapiIniPath);

                // Search and modify all relevant lines
                for LineIndex := 0 to FakeNvapiIniLines.Count - 1 do
                begin
                  // Check for force_reflex line (always modify)
                  if Pos('force_reflex=', FakeNvapiIniLines[LineIndex]) > 0 then
                  begin
                    FakeNvapiIniLines[LineIndex] := 'force_reflex=' + ForceReflexValue;
                    ForceReflexFound := True;
                  end;

                  // Check for force_latencyflex line (always modify)
                  if Pos('force_latencyflex=', FakeNvapiIniLines[LineIndex]) > 0 then
                  begin
                    FakeNvapiIniLines[LineIndex] := 'force_latencyflex=' + ForceLatencyFlexValue;
                    ForceLatencyFlexFound := True;
                  end;

                  // Check for latencyflex_mode line (always modify)
                  if Pos('latencyflex_mode=', FakeNvapiIniLines[LineIndex]) > 0 then
                  begin
                    FakeNvapiIniLines[LineIndex] := 'latencyflex_mode=' + LatencyFlexModeValue;
                    LatencyFlexModeFound := True;
                  end;

                  // Check for enable_trace_logs line (always modify)
                  if Pos('enable_trace_logs=', FakeNvapiIniLines[LineIndex]) > 0 then
                  begin
                    FakeNvapiIniLines[LineIndex] := 'enable_trace_logs=' + EnableTraceLogsValue;
                    EnableTraceLogsFound := True;
                  end;
                end;

                // Check if all expected lines were found and modified
                if (not forcereflexCheckBox.Checked or ForceReflexFound) and
                   (not forcelatencyflexCheckBox.Checked or (ForceLatencyFlexFound and LatencyFlexModeFound)) then
                begin
                  // Save the modified fakenvapi.ini file
                  FakeNvapiIniLines.SaveToFile(FakeNvapiIniPath);
                end
                else
                begin
                  if forcereflexCheckBox.Checked and not ForceReflexFound then
                    ShowMessage('Warning: Could not find force_reflex line in fakenvapi.ini file');
                  if forcelatencyflexCheckBox.Checked and not ForceLatencyFlexFound then
                    ShowMessage('Warning: Could not find force_latencyflex line in fakenvapi.ini file');
                  if forcelatencyflexCheckBox.Checked and not LatencyFlexModeFound then
                    ShowMessage('Warning: Could not find latencyflex_mode line in fakenvapi.ini file');
                end;

              finally
                FakeNvapiIniLines.Free;
              end;
            end;
            // Silently skip if fakenvapi.ini doesn't exist (OptiScaler not installed yet)
          end;

            // ##### Copy FSR4 DLL based on fsrversionCombobox selection #####
            try
              FGModPath := GetOptiScalerInstallPath;

              case fsrversionComboBox.ItemIndex of
                0: // Latest (FP8)
                  begin
                    // Copy amd_fidelityfx_upscaler_dx12.dll from FSR4_LATEST to fgmod root
                    if FileExists(IncludeTrailingPathDelimiter(FGModPath) + 'FSR4_LATEST' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll') then
                    begin
                      CopyFile(IncludeTrailingPathDelimiter(FGModPath) + 'FSR4_LATEST' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll',
                               IncludeTrailingPathDelimiter(FGModPath) + 'amd_fidelityfx_upscaler_dx12.dll');

                      // Add fsrversion=built in to goverlay.vars
                      VarsFilePath := IncludeTrailingPathDelimiter(FGModPath) + 'goverlay.vars';
                      if FileExists(VarsFilePath) then
                      begin
                        Lines := TStringList.Create;
                        try
                          Lines.LoadFromFile(VarsFilePath);

                          // Check if fsrversion line already exists and remove it
                          for i := Lines.Count - 1 downto 0 do
                          begin
                            if Pos('fsrversion=', Lines[i]) > 0 then
                              Lines.Delete(i);
                          end;

                          // Add fsrversion line at the end
                          Lines.Add('fsrversion=built in');

                          // Save the file
                          Lines.SaveToFile(VarsFilePath);
                        finally
                          Lines.Free;
                        end;
                      end;
                    end;
                    // Silently skip if FSR4_LATEST doesn't exist (OptiScaler not installed yet)
                  end;

                1: // 4.0.2 (INT8)
                  begin
                    // Copy amd_fidelityfx_upscaler_dx12.dll from FSR4_INT8 to fgmod root
                    if FileExists(IncludeTrailingPathDelimiter(FGModPath) + 'FSR4_INT8' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll') then
                    begin
                      CopyFile(IncludeTrailingPathDelimiter(FGModPath) + 'FSR4_INT8' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll',
                               IncludeTrailingPathDelimiter(FGModPath) + 'amd_fidelityfx_upscaler_dx12.dll');

                      // Add fsrversion line to goverlay.vars
                      VarsFilePath := IncludeTrailingPathDelimiter(FGModPath) + 'goverlay.vars';
                      if FileExists(VarsFilePath) then
                      begin
                        Lines := TStringList.Create;
                        try
                          Lines.LoadFromFile(VarsFilePath);

                          // Check if fsrversion line already exists and remove it
                          for i := Lines.Count - 1 downto 0 do
                          begin
                            if Pos('fsrversion=', Lines[i]) > 0 then
                              Lines.Delete(i);
                          end;

                          // Add fsrversion line at the end
                          Lines.Add('fsrversion=4.0.2 (INT8)');

                          // Save the file
                          Lines.SaveToFile(VarsFilePath);
                        finally
                          Lines.Free;
                        end;
                      end;
                    end;
                    // Silently skip if FSR4_INT8 doesn't exist (OptiScaler not installed yet)
                  end;
              end;
            except
              on E: Exception do
                ShowMessage('Warning: Could not copy FSR4 DLL: ' + E.Message);
            end;

            // Show notification
            SendNotification('OptiScaler', 'Configuration saved', GetIconFile);

            // Show the howto button after saving OptiScaler configuration
            howtoBitBtn.Visible := True;

            // Always use ~/fgmod path (simplified architecture)
            FGModPath := GetOptiScalerInstallPath;

            // Build launch command with full absolute path
            // Using absolute path ensures compatibility with all game launchers
            LaunchCommand := GetFGModPath + '/fgmod ';

            // Check if gamemode should be added (check fgmod file for #gamemode or generalCheckGroup)
            if GetGeneralCheckBox(1).Checked then
              LaunchCommand := LaunchCommand + '-- env gamemoderun ';

            LaunchCommand := LaunchCommand + '%command%';

            // Update notificationLabel
            notificationLabel.Caption := 'Command :';
            notificationLabel.Font.Color := clOlive;
            notificationLabel.Font.Style := [fsBold];
            notificationLabel.Visible := True;

            // Update commandLabel with launch command
            commandEdit.Text := LaunchCommand;
           // commandlabel.Font.Style := [fsBold];
            commandEdit.Visible := True;
            
            copyBitbtn.Visible:=true;
          end
          else
          begin
            if not LineFound then
              ShowMessage('Warning: Could not find dll_name line in fgmod file');
            if not WineOverrideFound then
              ShowMessage('Warning: Could not find WINEDLLOVERRIDES line in fgmod file');
          end;

        finally
          FGModLines.Free;
        end;
      end
      else
      begin
        ShowMessage('Error: fgmod file not found at: ' + FGModFilePath);
      end;

      Exit; // Exit after saving OptiScaler settings
    end;

  // ################### SAVE MANGOHUD

   if goverlayPageControl.ActivePage <> vkbasaltTabSheet then
   begin


  // Save MangoHud configuration
    SaveMangoHudConfig;

  // Popup a notification
    SendNotification('MangoHud', 'Configuration saved', GetIconFile);

  // If geSpeedButton is active (MangoHud enabled in fgmod), show the fgmod command
    // If global enable is active, show message instead of command
    if globalenableMenuItem.Checked then
    begin
      notificationLabel.Visible := False;
      copyBitBtn.Visible := False;
      howtoBitBtn.Visible := False;
      commandEdit.Visible := True;
      commandEdit.Text := 'MangoHud will be displayed in every vulkan application';
    end
    else if geSpeedButton.ImageIndex = 1 then
    begin
      // Build launch command with full absolute path
      LaunchCommand := GetFGModPath + '/fgmod ';

      // Check if gamemode should be added (check generalCheckGroup)
      if GetGeneralCheckBox(1).Checked then
        LaunchCommand := LaunchCommand + '-- env gamemoderun ';

      LaunchCommand := LaunchCommand + '%command%';

      // Update notificationLabel
      notificationLabel.Caption := 'Command :';
      notificationLabel.Font.Color := clOlive;
      notificationLabel.Font.Style := [fsBold];
      notificationLabel.Visible := True;

      // Update commandLabel with launch command
      commandEdit.Text := LaunchCommand;
      
      commandEdit.Visible := True;
      
      copyBitbtn.Visible := True;
      howtoBitBtn.Visible := True;
    end
    else
    begin
      // geSpeedButton is OFF - show environment variable command
      LaunchCommand := 'MANGOHUD=1 ';

      // Check if gamemode should be added
      if GetGeneralCheckBox(1).Checked then
        LaunchCommand := LaunchCommand + 'gamemoderun ';

      LaunchCommand := LaunchCommand + '%command%';

      // Update notificationLabel
      notificationLabel.Caption := 'Command :';
      notificationLabel.Font.Color := clOlive;
      notificationLabel.Font.Style := [fsBold];
      notificationLabel.Visible := True;

      // Update commandEdit with launch command
      commandEdit.Text := LaunchCommand;
      commandEdit.Visible := True;
      
      copyBitbtn.Visible := True;
    end;

    //########################################### SAVE BLACKLIST

  BLACKLISTFILE := GetUserConfigDir + '/goverlay/blacklist.conf';
  MANGOHUDCFGFILE := IncludeTrailingPathDelimiter(GetMangoHudConfigDir()) + 'MangoHud.conf';

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

    // make sure mangohud directory exists (use CreateHostDirectory for Flatpak compatibility)
    CreateHostDirectory(ExtractFilePath(MANGOHUDCFGFILE));

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
     Lines.Add('toggleKey = ' + vkbtogglekeyCombobox.Text);
     Lines.Add('enableOnLaunch = True');
     Lines.Add('');
     // --- create effects list" ---
     EffectsLine := '';
     // 1) CAS (if active)
     if casTrackBar.Position >= 1 then
       AddEffectToLine('cas');
     // 2) FXAA (if active)
     if fxaatrackbar.Position >= 1 then
       AddEffectToLine('fxaa');
     // 3) SMAA (if active)
     if smaatrackbar.Position >= 1 then
       AddEffectToLine('smaa');
     // 4) DLS (if active)
     if dlstrackbar.Position >= 1 then
       AddEffectToLine('dls');
     // 5) reshade effects on the list
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
     // --- FXAA adjustment if active ---
     if fxaatrackbar.Position >= 1 then
     begin
       // map 1..10 -> 0.1..1.0
       FxaaQuality := fxaatrackbar.Position / 10.0;
       // use dot for decimal value
       FS := DefaultFormatSettings;
       FS.DecimalSeparator := '.';
       Lines.Add('fxaaQualitySubpix = ' + FloatToStrF(FxaaQuality, ffFixed, 3, 1, FS));
     end;
     // --- SMAA adjustment if active ---
     if smaatrackbar.Position >= 1 then
     begin
       // map 1..10 -> 0.0..1.0
       SmaaCorner := (smaatrackbar.Position - 1) / 9.0;  // (1-1)/9=0, (10-1)/9=1
       // use dot for decimal value
       FS := DefaultFormatSettings;
       FS.DecimalSeparator := '.';
       Lines.Add('smaaCornerRounding = ' + FloatToStrF(SmaaCorner, ffFixed, 3, 1, FS));
       Lines.Add('smaaThreshold = 0.1');
       Lines.Add('smaaMaxSearchSteps = 16');
       Lines.Add('smaaMaxSearchStepsDiag = 8');
     end;
     // --- DLS adjustment if active ---
     if dlstrackbar.Position >= 1 then
     begin
       // map 1..10 -> 0.0..1.0
       DlsSharp := (dlstrackbar.Position - 1) / 9.0;  // (1-1)/9=0, (10-1)/9=1
       // use dot for decimal value
       FS := DefaultFormatSettings;
       FS.DecimalSeparator := '.';
       Lines.Add('dlsSharpness = ' + FloatToStrF(DlsSharp, ffFixed, 3, 1, FS));
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
     SendNotification('vkBasalt', 'configuration saved', GetIconFile);

     // If geSpeedButton is active (vkBasalt enabled in fgmod), show the fgmod command
     if geSpeedButton.ImageIndex = 1 then
     begin
       // Build launch command with full absolute path
       LaunchCommand := GetFGModPath + '/fgmod ';

       // Check if gamemode should be added (check generalCheckGroup)
       if GetGeneralCheckBox(1).Checked then
         LaunchCommand := LaunchCommand + '-- env gamemoderun ';

       LaunchCommand := LaunchCommand + '%command%';

       // Update notificationLabel
       notificationLabel.Caption := 'Command :';
       notificationLabel.Font.Color := clOlive;
       notificationLabel.Font.Style := [fsBold];
       notificationLabel.Visible := True;

       // Update commandLabel with launch command
       commandEdit.Text := LaunchCommand;
       
       commandEdit.Visible := True;
       
       copyBitbtn.Visible := True;
       howtoBitBtn.Visible := True;
     end
     else
     begin
       // geSpeedButton is OFF - show environment variable command
       LaunchCommand := 'ENABLE_VKBASALT=1 ';

       // Check if gamemode should be added
       if GetGeneralCheckBox(1).Checked then
         LaunchCommand := LaunchCommand + 'gamemoderun ';

       LaunchCommand := LaunchCommand + '%command%';

       // Update notificationLabel
       notificationLabel.Caption := 'Command :';
       notificationLabel.Font.Color := clOlive;
       notificationLabel.Font.Style := [fsBold];
       notificationLabel.Visible := True;

       // Update commandLabel with launch command
       commandEdit.Text := LaunchCommand;
       
       commandEdit.Visible := True;
       
       copyBitbtn.Visible := True;
     end;

   except
     on E: Exception do
       ShowMessage('Fail to save vkbasalt.conf: ' + E.Message);
   end;
   Lines.Free;
   //Restart VKcube with effects

   ExecuteGUICommand('killall vkcube');
   // Small delay to ensure vkcube is fully terminated before restarting
   Sleep(100);
   SendNotification('Goverlay', 'Trying vkbasalt effects', GetIconFile);

   // In Flatpak, MangoHud works via environment variable, not as a wrapper command
   // In Flatpak, use vkcube-wayland binary instead of vkcube --wsi wayland

   if IsCommandAvailable('pascube') then
   begin
      ExecuteGUICommand('VKBASALT_LOG_FILE=' + VKBASALTFOLDER + '/' + 'vkBasalt.log ENABLE_VKBASALT=1 MANGOHUD=1 pascube &');
   end
   else
   begin
     SendNotification('Goverlay', 'PasCube was not located, using vkcube instead', GetIconFile);

     if IsRunningInFlatpak then
     begin
       // In Flatpak, vkcube auto-detects WSI
       if (USERSESSION = 'wayland') and IsCommandAvailable('vkcube-wayland') then
          ExecuteGUICommand('VKBASALT_LOG_FILE=' + VKBASALTFOLDER + '/' + 'vkBasalt.log ENABLE_VKBASALT=1 MANGOHUD=1 vkcube-wayland &')
       else
          ExecuteGUICommand('VKBASALT_LOG_FILE=' + VKBASALTFOLDER + '/' + 'vkBasalt.log ENABLE_VKBASALT=1 MANGOHUD=1 vkcube &');
     end
     else
     begin
       if USERSESSION = 'wayland' then
         ExecuteGUICommand('VKBASALT_LOG_FILE=' + VKBASALTFOLDER + '/' + 'vkBasalt.log ENABLE_VKBASALT=1 mangohud vkcube --wsi wayland &')
       else
         ExecuteGUICommand('VKBASALT_LOG_FILE=' + VKBASALTFOLDER + '/' + 'vkBasalt.log ENABLE_VKBASALT=1 mangohud vkcube &');
     end;
   end;






end; // ########################################      end save button click       ###############################################################################

procedure Tgoverlayform.savecustomMenuItemClick(Sender: TObject);
begin
      // Save current config
    saveBitbtn.Click;

    // Copy Mangohud.conf file to custom.conf
    ExecuteShellCommand('cp '+ MANGOHUDCFGFILE + ' ' + CUSTOMCFGFILE);

    //Notification
    SendNotification('Goverlay', 'Settings saved as custom config', GetIconFile);
end;

procedure Tgoverlayform.saveasMenuItemClick(Sender: TObject);
var
  SelectedDirectory: string;
  DestinationFile: string;
  ConfigLines: TStringList;
  i: Integer;
  FS: TFormatSettings;
begin
  // Show directory selection dialog
  with TSelectDirectoryDialog.Create(Self) do
  begin
    try
      Title := 'Select directory to save configuration file';
      
      if Execute then
      begin
        SelectedDirectory := FileName;
        
        // Check if we're on MangoHud tab or vkBasalt tab
        if goverlayPageControl.ActivePage = vkbasaltTabSheet then
        begin
          // Export vkBasalt.conf
          DestinationFile := IncludeTrailingPathDelimiter(SelectedDirectory) + 'vkBasalt.conf';
          
          // Generate vkBasalt configuration
          ConfigLines := TStringList.Create;
          FS := DefaultFormatSettings;
          FS.DecimalSeparator := '.';
          
          try
            ConfigLines.Add('#effects is a colon separated list of effect to use');
            ConfigLines.Add('#e.g.: effects = fxaa:cas');
            ConfigLines.Add('#effects will be run in order from left to right');
            ConfigLines.Add('#one effect can be run multiple times e.g. smaa:smaa:cas');
            ConfigLines.Add('#cas    - Contrast Adaptive Sharpening');
            ConfigLines.Add('#dls    - Denoised Luma Sharpening');
            ConfigLines.Add('#fxaa   - Fast Approximate Anti-Aliasing');
            ConfigLines.Add('#smaa   - Enhanced Subpixel Morphological Anti-Aliasing');
            ConfigLines.Add('#');
            ConfigLines.Add('#reshade shaders should be defined like:');
            ConfigLines.Add('#effects = <shadername>:<shadername>:....');
            ConfigLines.Add('');
            
            // Build effects list
            if acteffectsListBox.Items.Count > 0 then
            begin
              ConfigLines.Add('effects = ' + acteffectsListBox.Items[0]);
              for i := 1 to acteffectsListBox.Items.Count - 1 do
                ConfigLines[ConfigLines.Count - 1] := ConfigLines[ConfigLines.Count - 1] + ':' + acteffectsListBox.Items[i];
            end
            else
              ConfigLines.Add('effects = ');
            
            ConfigLines.Add('');
            
            // Toggle key
            case vkbtogglekeyCombobox.ItemIndex of
              0: ConfigLines.Add('toggleKey = Home');
              1: ConfigLines.Add('toggleKey = End');
              2: ConfigLines.Add('toggleKey = Insert');
              3: ConfigLines.Add('toggleKey = Delete');
            end;
            
            ConfigLines.Add('');
            ConfigLines.Add('#casSharpness specifies the amount of sharpening in the CAS filter.');
            ConfigLines.Add('#0.0 less sharp, less artefacts, but not off');
            ConfigLines.Add('#1.0 maximum sharp, more artefacts');
            ConfigLines.Add('#Everything in between is possible');
            ConfigLines.Add('#negative values sharpen even less, up to -1.0');
            ConfigLines.Add('casSharpness = ' + StringReplace(Format('%.2f', [casTrackbar.Position / 10], FS), ',', '.', [rfReplaceAll]));
            ConfigLines.Add('');
            
            ConfigLines.Add('#dlsSharpness specified the amount of sharpening in the Denoised Luma Sharpening filter.');
            ConfigLines.Add('#0.0 less sharp');
            ConfigLines.Add('#1.0 maximum sharp');
            ConfigLines.Add('dlsSharpness = ' + StringReplace(Format('%.2f', [dlsTrackbar.Position / 10], FS), ',', '.', [rfReplaceAll]));
            ConfigLines.Add('');
            ConfigLines.Add('#dlsDenoise specifies the amount of denoising in the Denoised Luma Sharpening filter.');
            ConfigLines.Add('#0.0 less denoising');
            ConfigLines.Add('#1.0 maximum denoising');
            ConfigLines.Add('dlsDenoise = 0.17');
            ConfigLines.Add('');
            
            ConfigLines.Add('#fxaaQualitySubpix can effect sharpness.');
            ConfigLines.Add('#1.00 - upper limit (softer)');
            ConfigLines.Add('#0.75 - default amount of filtering');
            ConfigLines.Add('#0.50 - lower limit (sharper, less sub-pixel aliasing removal)');
            ConfigLines.Add('#0.25 - almost off');
            ConfigLines.Add('#0.00 - completely off');
            ConfigLines.Add('fxaaQualitySubpix = ' + StringReplace(Format('%.2f', [fxaaTrackbar.Position / 100], FS), ',', '.', [rfReplaceAll]));
            ConfigLines.Add('');
            
            ConfigLines.Add('#smaaEdgeDetection changes the type of edge detection');
            ConfigLines.Add('#luma  - default and faster');
            ConfigLines.Add('#color - might catch more edges but is slower');
            case filterRadioGroup.ItemIndex of
              0: ConfigLines.Add('smaaEdgeDetection = luma');
              1: ConfigLines.Add('smaaEdgeDetection = color');
            end;
            
            ConfigLines.Add('');
            ConfigLines.Add('#smaaThreshold specifies the threshold for edge detection');
            ConfigLines.Add('#0.05 - lower threshold (more edges, slower)');
            ConfigLines.Add('#0.10 - default');
            ConfigLines.Add('#0.15 - upper threshold (less edges but faster)');
            ConfigLines.Add('smaaThreshold = ' + StringReplace(Format('%.2f', [smaaTrackbar.Position / 100], FS), ',', '.', [rfReplaceAll]));
            ConfigLines.Add('');
            ConfigLines.Add('#smaaMaxSearchSteps specifies the maximum steps in edge pattern search');
            ConfigLines.Add('#For a bit better quality: 16');
            ConfigLines.Add('#Default good quality: 32');
            ConfigLines.Add('smaaMaxSearchSteps = 32');
            ConfigLines.Add('');
            ConfigLines.Add('#smaaMaxSearchStepsDiag specifies the maximum steps in diagonal pattern search');
            ConfigLines.Add('#Default value: 16');
            ConfigLines.Add('smaaMaxSearchStepsDiag = 16');
            ConfigLines.Add('');
            ConfigLines.Add('#smaaCornerRounding specifies how much to round sharp corners');
            ConfigLines.Add('#0   - no rounding');
            ConfigLines.Add('#100 - maximum rounding');
            ConfigLines.Add('smaaCornerRounding = 25');
            ConfigLines.Add('');
            
            ConfigLines.Add('#AF Anisotropic filtering');
            ConfigLines.Add('#0  - game choice');  
            ConfigLines.Add('#1  - off');
            ConfigLines.Add('#2  - 2x');
            ConfigLines.Add('#4  - 4x');
            ConfigLines.Add('#8  - 8x');
            ConfigLines.Add('#16 - 16x');
            case afTrackbar.Position of
              0: ConfigLines.Add('anisotropicFiltering = 0');
              1: ConfigLines.Add('anisotropicFiltering = 1');
              2: ConfigLines.Add('anisotropicFiltering = 2');
              3: ConfigLines.Add('anisotropicFiltering = 4');
              4: ConfigLines.Add('anisotropicFiltering = 8');
              5: ConfigLines.Add('anisotropicFiltering = 16');
            end;
            ConfigLines.Add('');
            
            ConfigLines.Add('#trilinearFiltering = true');
            ConfigLines.Add('');
            ConfigLines.Add('#forceBorderlessFullscreen = true');
            
            // Save to destination file
            ConfigLines.SaveToFile(DestinationFile);
            
            // Show notification
            SendNotification('vkBasalt', 'Configuration exported to: ' + DestinationFile, GetIconFile);
          finally
            ConfigLines.Free;
          end;
        end
        else
        begin
          // Export MangoHud.conf
          DestinationFile := IncludeTrailingPathDelimiter(SelectedDirectory) + 'MangoHud.conf';
          
          // First generate the current MangoHud config
          SaveMangoHudConfig;
          
          // Copy the generated config to destination
          if FileExists(MANGOHUDCFGFILE) then
          begin
            ExecuteShellCommand('cp ' + MANGOHUDCFGFILE + ' ' + DestinationFile);
            
            // Show notification
            SendNotification('MangoHud', 'Configuration exported to: ' + DestinationFile, GetIconFile);
          end
          else
          begin
            ShowMessage('Error: Could not find MangoHud configuration file.');
          end;
        end;
      end;
    finally
      Free;
    end;
  end;
end;

procedure Tgoverlayform.smaaTrackBarChange(Sender: TObject);
begin
   smaavaluelabel.Caption := inttostr(smaaTrackbar.Position);
end;




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
    ShowMessage('There are no active effects');
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

procedure Tgoverlayform.ToggleSpeedButtonClick(Sender: TObject);
begin
  // Original ToggleSpeedButton code (if any)
end;

procedure Tgoverlayform.themeToggleSpeedButtonClick(Sender: TObject);
var
  NewTheme: TThemeMode;
begin
  // Toggle between themes
  NewTheme := ToggleTheme(Self);

  // Update button icon
  if NewTheme = tmLight then
    themeToggleSpeedButton.ImageIndex := 29   // sun icon (light theme)
  else
    themeToggleSpeedButton.ImageIndex := 28; // moon icon (dark theme)

  // Theme notifications removed to prevent duplicate notifications
  // The theme change is visually obvious from the UI update

  // Re-apply transparent Qt stylesheet to status bar (theme change overrides it)
  TQtWidget(statusBar.Handle).StyleSheet :=
    'QStatusBar {' +
    '  background: transparent;' +
    '  border: none;' +
    '  color: rgba(255,255,255,140);' +
    '}';
end;

procedure Tgoverlayform.transpTrackBarChange(Sender: TObject);
begin
  //Display new values and trackbar changes
  alphavalueLabel.Caption:= FormatFloat('#0.0', transpTrackbar.Position/10);
end;

procedure Tgoverlayform.SaveMangoHudPreset(PresetNumber: Integer);
var
  ConfigLines: TStringList;
  ConfigDir, PresetsFilePath: string;
  PresetHeader: string;
  ExistingLines: TStringList;
  i: Integer;
  CurrentPresetNumber: Integer;
  InPresetSection: Boolean;
  PresetAlreadyExists: Boolean;
begin
  // Use XDG-compliant path with proper Flatpak support (HOST_XDG_CONFIG_HOME)
  ConfigDir := GetMangoHudConfigDir();
  PresetsFilePath := ConfigDir + '/presets.conf';

  // Create directory if it doesn't exist (use CreateHostDirectory for Flatpak compatibility)
  if not DirectoryExists(ConfigDir) then
    CreateHostDirectory(ConfigDir);

  ConfigLines := TStringList.Create;
  try
    // Generate current configuration using SaveMangoHudConfig logic
    // We'll reuse the same logic but save to a different file

    // First, call SaveMangoHudConfig to generate the configuration
    SaveMangoHudConfig;

    // Read the generated MangoHud.conf to get current settings
    ConfigLines.LoadFromFile(ConfigDir + '/MangoHud.conf');

    // Now we need to check if presets.conf exists and if this preset already exists
    PresetAlreadyExists := False;

    if FileExists(PresetsFilePath) then
    begin
      ExistingLines := TStringList.Create;
      try
        ExistingLines.LoadFromFile(PresetsFilePath);

        // Check if this preset number already exists
        for i := 0 to ExistingLines.Count - 1 do
        begin
          if Trim(ExistingLines[i]) = '[preset ' + IntToStr(PresetNumber) + ']' then
          begin
            PresetAlreadyExists := True;
            Break;
          end;
        end;

        if PresetAlreadyExists then
        begin
          // Remove existing preset section
          InPresetSection := False;
          i := 0;
          while i < ExistingLines.Count do
          begin
            if Trim(ExistingLines[i]) = '[preset ' + IntToStr(PresetNumber) + ']' then
            begin
              InPresetSection := True;
              ExistingLines.Delete(i);
              Continue;
            end;

            if InPresetSection then
            begin
              // Check if we hit another preset section
              if (Length(Trim(ExistingLines[i])) > 0) and
                 (Trim(ExistingLines[i])[1] = '[') and
                 (Pos('[preset ', Trim(ExistingLines[i])) = 1) then
              begin
                InPresetSection := False;
              end
              else
              begin
                ExistingLines.Delete(i);
                Continue;
              end;
            end;

            Inc(i);
          end;

          // Save existing lines (without the old preset)
          ExistingLines.SaveToFile(PresetsFilePath);
        end;

      finally
        ExistingLines.Free;
      end;
    end;

    // Prepare the preset content to append
    PresetHeader := '[preset ' + IntToStr(PresetNumber) + ']';

    // Create new preset content
    ExistingLines := TStringList.Create;
    try
      if FileExists(PresetsFilePath) then
        ExistingLines.LoadFromFile(PresetsFilePath);

      // Add blank line before new preset if file is not empty
      if ExistingLines.Count > 0 then
        ExistingLines.Add('');

      // Add preset header
      ExistingLines.Add(PresetHeader);

      // Add all configuration lines from ConfigLines
      for i := 0 to ConfigLines.Count - 1 do
        ExistingLines.Add(ConfigLines[i]);

      // Save the complete file
      ExistingLines.SaveToFile(PresetsFilePath);

      // Send notification via D-Bus
      SendNotification('GOverlay', 'Steam Deck Preset ' + IntToStr(PresetNumber) + ' saved successfully!');

    finally
      ExistingLines.Free;
    end;

  finally
    ConfigLines.Free;
  end;
end;

procedure Tgoverlayform.deckpreset1MenuItemClick(Sender: TObject);
begin
  SaveMangoHudPreset(1);
end;

procedure Tgoverlayform.deckpreset2MenuItemClick(Sender: TObject);
begin
  SaveMangoHudPreset(2);
end;

procedure Tgoverlayform.deckpreset3MenuItemClick(Sender: TObject);
begin
  SaveMangoHudPreset(3);
end;

procedure Tgoverlayform.deckpreset4MenuItemClick(Sender: TObject);
begin
  SaveMangoHudPreset(4);
end;

// Remove MANGOHUD=1 from fgmod file
procedure Tgoverlayform.RemoveMangoHudFromFGMod;
var
  FGModFilePath: string;
  FileLines: TStringList;
  i: Integer;
  LineRemoved: Boolean;
begin
  // Get fgmod file path
  FGModFilePath := GetFGModPath + PathDelim + 'fgmod';
  
  // Check if fgmod file exists
  if not FileExists(FGModFilePath) then
    Exit;
  
  FileLines := TStringList.Create;
  try
    FileLines.LoadFromFile(FGModFilePath);
    LineRemoved := False;
    
    // Find and remove lines containing MANGOHUD=1
    for i := FileLines.Count - 1 downto 0 do
    begin
      if Pos('export MANGOHUD=1', FileLines[i]) > 0 then
      begin
        FileLines.Delete(i);
        LineRemoved := True;
      end;
    end;
    
    // Save the modified file only if a line was removed
    if LineRemoved then
    begin
      FileLines.SaveToFile(FGModFilePath);
      // Make sure it's still executable
      fpChmod(FGModFilePath, &755);
      WriteLn('[FGMOD] Removed MANGOHUD=1 from fgmod (global enable is active)');
    end;
    
  finally
    FileLines.Free;
  end;
end;

// Event handler for Global Enable MangoHud menu item
procedure Tgoverlayform.globalenableMenuItemClick(Sender: TObject);
var
  DialogResult: Integer;
  IsCurrentlyEnabled: Boolean;
begin
  try
    // Check current state
    IsCurrentlyEnabled := IsMangoHudGloballyEnabled();
    
    if not IsCurrentlyEnabled then
    begin
      // Show warning dialog before enabling
      DialogResult := MessageDlg(
        'Enable MangoHud Globally',
        'Enabling MangoHud globally may cause unexpected issues in some applications and desktop environments. ' +
        'Make sure you know what you are doing.' + LineEnding + LineEnding +
        'Do you want to continue?',
        mtWarning,
        [mbYes, mbNo],
        0
      );
      
      // If user clicked No, abort
      if DialogResult = mrNo then
      begin
        globalenableMenuItem.Checked := False;
        Exit;
      end;
      
      // User clicked Yes, enable MangoHud globally
      EnableMangoHudGlobally();
      globalenableMenuItem.Checked := True;
      
      // Remove MANGOHUD=1 from fgmod to prevent double HUD loading
      RemoveMangoHudFromFGMod();
      
      // Update UI visibility
      UpdateGlobalEnableMenuItemVisibility();
      
      // Ask if user wants to restart session now
      DialogResult := MessageDlg(
        'Restart Session',
        'MangoHud has been enabled globally. A session restart is required for changes to take effect.' + LineEnding + LineEnding +
        'Do you want to restart your session now?',
        mtInformation,
        [mbYes, mbNo],
        0
      );
      
      if DialogResult = mrYes then
      begin
        // Execute logout command based on desktop environment
        ExecuteSessionLogout();
      end;
    end
    else
    begin
      // Disable MangoHud globally (no warning needed)
      DisableMangoHudGlobally();
      globalenableMenuItem.Checked := False;
      
      // Update UI visibility
      UpdateGlobalEnableMenuItemVisibility();
      
      // Ask if user wants to restart session now
      DialogResult := MessageDlg(
        'Restart Session',
        'MangoHud has been disabled globally. A session restart is required for changes to take effect.' + LineEnding + LineEnding +
        'Do you want to restart your session now?',
        mtInformation,
        [mbYes, mbNo],
        0
      );
      
      if DialogResult = mrYes then
      begin
        // Execute logout command based on desktop environment
        ExecuteSessionLogout();
      end;
    end;
  except
    on E: Exception do
    begin
      MessageDlg(
        'Error',
        'Failed to toggle MangoHud global enable: ' + E.Message,
        mtError,
        [mbOK],
        0
      );
      globalenableMenuItem.Checked := IsMangoHudGloballyEnabled();
    end;
  end;
end;

procedure Tgoverlayform.gamemodeCheckBoxClick(Sender: TObject);
var
  DialogResult: Integer;
begin
  // Only show warning in Flatpak when checkbox is being checked (enabled)
  if IsRunningInFlatpak and gamemodeCheckBox.Checked then
  begin
    DialogResult := MessageDlg(
      'GameMode Warning',
      'You are running GOverlay in Flatpak. GameMode must be installed on your host system for this feature to work.' + LineEnding + LineEnding +
      'If GameMode is not installed, games may fail to launch.' + LineEnding + LineEnding +
      'Do you want to continue?',
      mtWarning,
      [mbYes, mbNo],
      0
    );
    
    // If user clicked No, uncheck the checkbox
    if DialogResult = mrNo then
      gamemodeCheckBox.Checked := False;
  end;
end;

end.
