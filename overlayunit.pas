unit overlayunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, Forms, Controls, Graphics, Dialogs, ExtCtrls, Math,
  unix, BaseUnix, StdCtrls, Spin, ComCtrls, Buttons, ActnList, Menus, aboutunit, optiscaler_update, protontricksunit,
  blacklistUnit, LCLtype, Clipbrd, LCLIntf, IniFiles,
  FileUtil, StrUtils, Types, fpjson, jsonparser, git2pas, howto, themeunit, systemdetector, constants,
  bgmod_resources, hintsunit, qt6, qtwidgets, fpreadjpeg, configmanager, IntfGraphics, Grids,
  configkeys, configfile, uihelpers, apputils, overlay_config;



type
  TParamDef = record
    Name: string;
    Min, Max, Default: Integer;
    IsDeg: Boolean;
  end;

const
  PARAMS: array[0..14] of TParamDef = (
    (Name: 'Brightness';  Min: 0; Max: 200; Default: 100; IsDeg: False),
    (Name: 'Contrast';    Min: 0; Max: 200; Default: 100; IsDeg: False),
    (Name: 'Exposure';    Min: 0; Max: 600; Default: 300; IsDeg: False),
    (Name: 'Gamma';       Min: 0; Max: 200; Default: 100; IsDeg: False),
    (Name: 'Saturation';  Min: 0; Max: 200; Default: 100; IsDeg: False),
    (Name: 'Vibrance';    Min: 0; Max: 200; Default: 100; IsDeg: False),
    (Name: 'Hue';         Min: 0; Max: 360; Default: 180; IsDeg: True),
    (Name: 'Temperature'; Min: 0; Max: 200; Default: 100; IsDeg: False),
    (Name: 'Tint';        Min: 0; Max: 200; Default: 100; IsDeg: False),
    (Name: 'Red Gain';    Min: 0; Max: 200; Default: 100; IsDeg: False),
    (Name: 'Green Gain';  Min: 0; Max: 200; Default: 100; IsDeg: False),
    (Name: 'Blue Gain';   Min: 0; Max: 200; Default: 100; IsDeg: False),
    (Name: 'Shadows';     Min: 0; Max: 200; Default: 100; IsDeg: False),
    (Name: 'Midtones';    Min: 0; Max: 200; Default: 100; IsDeg: False),
    (Name: 'Highlights';  Min: 0; Max: 200; Default: 100; IsDeg: False)
  );

  PARAM_HINTS: array[0..14] of string = (
    'Adjusts the overall lightness or darkness of the image.',
    'Adjusts the difference between the brightest and darkest areas.',
    'Adjusts the amount of light in the image.',
    'Adjusts the luminance of the mid-tones.',
    'Adjusts the overall intensity and richness of all colors.',
    'Intelligently boosts the saturation of muted colors.',
    'Shifts the overall color spectrum (hue) of the image.',
    'Adjusts the color warmth (cool blue to warm orange).',
    'Adjusts the balance between green and magenta.',
    'Adjusts the intensity of the red color channel.',
    'Adjusts the intensity of the green color channel.',
    'Adjusts the intensity of the blue color channel.',
    'Adjusts the brightness of the darkest areas (shadows).',
    'Adjusts the brightness of the middle gray tones.',
    'Adjusts the brightness of the brightest areas (highlights).'
  );



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
    commandPanel: TPanel;
    commandPaintBox: TPaintBox;
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
    gamesTabSheet: TTabSheet;
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
    blacklistMenuItem: TMenuItem;
    globalenableMenuItem: TMenuItem;
    hdrCheckBox: TCheckBox;
    hidehudCheckBox: TCheckBox;
    hImage: TImage;
    horizontalRadioButton: TRadioButton;
    horizontalstrechCheckBox: TCheckBox;
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
    settingsSpeedButton: TSpeedButton;
    settingsMenu: TPopupMenu;
    themeMenuItem: TMenuItem;
    settingsDonateMenuItem: TMenuItem;
    settingsAboutMenuItem: TMenuItem;
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
    vksumiTabSheet: TTabSheet;
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
    procedure commandPaintBoxClick(Sender: TObject);
    procedure commandPaintBoxPaint(Sender: TObject);
    procedure ResetCopyFeedback(Sender: TObject);
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
    procedure gamesLabelClick(Sender: TObject);
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
    procedure settingsSpeedButtonClick(Sender: TObject);
    procedure themeMenuItemClick(Sender: TObject);
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
    procedure vkbasaltTabSheetShow(Sender: TObject);
    procedure vkSumiTabSheetShow(Sender: TObject);
    procedure performanceTabSheetShow(Sender: TObject);
    procedure visualTabSheetShow(Sender: TObject);
    procedure metricsTabSheetShow(Sender: TObject);
    procedure LoadMangoHudConfig;
    procedure SaveMangoHudConfig;
    procedure SaveMangoHudPreset(PresetNumber: Integer);
    procedure LoadOptiScalerConfig;

  private
    FCommandCopiedTime: QWord;
    // Moved to public:
    {     FLaunchCommand: string;
    FOptiscalerUpdate: TOptiscalerTab; }
    // Moved to public:
    {     FReshadeProgressBar: TProgressBar;
    FReshadePhaseLabel: TLabel;
    FReshadeDownloadedOnFirstShow: Boolean;
    FAutoDownloadingReshade: Boolean; }
    FStatusTimer: TTimer;
    FGamesHelper:     TObject;  // cached badge icon for OptiScaler
    FBasaltHelper:    TObject;
    FMangoHelper:     TObject;

    // Nav rail
    FNavItems:       array of TPanel;    // item panels
    FNavIndicators:  array of TShape;    // left indicator bars
    FNavIcons:       array of TLabel;    // unicode icon labels
    FNavLabels:      array of TLabel;    // caption labels
    FNavActive:      Integer;            // index of active item (-1 = none)
    FNavHoveredIdx:  Integer;            // index of hovered item (-1 = none)
    FNavClickCBs:    array of TNotifyEvent; // click callbacks per item
    FNavCollapsed:   Boolean;            // sidebar collapsed state
    // Moved to public:
    {     FPresetsBgBox:   TPaintBox;          // full-width navy paintbox background for Presets tab
    FPresetsWrapper: TPanel;             // centered wrapper for the Presets tab content }
    FNavToggleBtn:   TSpeedButton;       // collapse/expand button
    FNavSmallIcon:   TImage;             // small app icon shown when collapsed
    FOptiScalerImg:  TImage;             // custom image for optiscaler icon
    FMangoHudImg:    TImage;             // custom image for mangohud icon
    FNavAnimTimer:   TTimer;             // sidebar animation timer
    FNavAnimTarget:  Integer;            // animation target width
    FNavAnimCurrent: Integer;            // animation current width (fixed-point *10)

    // Settings button (bottom of sidebar)
    FSettingsIconLbl: TLabel;
    FDepsMenuItem:       TMenuItem;  // dependency status item inside settingsMenu
    FCubeAutoLaunchItem: TMenuItem;  // settings menu toggle for auto-launch of cube
    FHowToMenuItem:      TMenuItem;  // "How to Use" shortcut inside settings menu
    FCubeAutoLaunch:     Boolean;    // whether to auto-launch pascube/vkcube

    // Moved to public:
    {     // vkBasalt tab redesign
    FVkReshadeCard:  TPanel;
    FVkBuiltinCard:  TPanel;
    FVkToggleCard:   TPanel;
    FVkAvHdrLbl:     TLabel;
    FVkActHdrLbl:    TLabel;
    // Fresh value labels (avoid LFM reparenting issues)
    FVkCasValLbl:    TLabel;
    FVkFxaaValLbl:   TLabel;
    FVkSmaaValLbl:   TLabel;
    FVkDlsValLbl:    TLabel;
    // Custom icons for built-in effects
    FVkCasIcon:      TImage;
    FVkFxaaIcon:     TImage;
    FVkSmaaIcon:     TImage;
    FVkDlsIcon:      TImage;
    // vkBasalt Reshade effects MD3 list (replaces dual listboxes)
    FVkReshadePB:    TPaintBox;
    FVkReshadeSB:    TScrollBar;
    FVkReshadeScrollPos: Integer;
    FVkReshadeHoverIdx:  Integer; }
    // Moved to public:
    {     FOsScrollBox:    TScrollBox;
    FOsBgPanel:      TPanel;     // inner panel — paints BG color reliably in Qt6
    FOsGpuCard:      TPanel;
    FOsOptionsCard:  TPanel;
    FOsStatusCard:   TPanel;
    FOsOptiSec:      TPanel;   // replaces optiscalerGroupBox as visual container
    FOsImgSec:       TPanel;   // replaces imgmenuGroupBox
    FOsFakeSec:      TPanel; }

    // Moved to public:
    {     // Metrics tab card redesign
    FMtScrollBox:    TScrollBox;
    FMtBgPanel:      TPanel;
    FMtGpuCard:      TPanel;
    FMtCpuCard:      TPanel; }

    // Custom env groupbox (Tweaks tab)
    FTweaksHelper:    TObject;
    FOptiScalerHelper: TObject;
    FHomeHelper:       TObject;

    // Moved to public:
    {     FOsStatDots:     array[0..5] of TShape;   // 0=OptiScaler 1=FakeNVAPI 2=FSR 3=XeSS 4=DLSS 5=OptiPatcher
    FOsStatNameLbls: array[0..5] of TLabel;
    FOsStatVerLbls:  array[0..5] of TLabel; }

    // Per-tool enable toggles (game mode only) — indices 0=MangoHud 1=vkBasalt 2=OptiScaler 3=Tweaks
    FNavToolBtns:    array[0..3] of TSpeedButton;
    FNavToolEnabled: array[0..3] of Boolean;
    FNavToolImgListSmall: TImageList;  // smaller ON/OFF icons for collapsed nav

    // Moved to public:
    {     // FPS Limit custom input (replaces chip grid)
    FFpsLimitEdit:   TEdit;              // comma-separated FPS values
    FFpsLimitTitleLbl: TLabel;
    FFpsLimitHintLbl:  TLabel; }

    // Moved to public:
    {     // Home tab
    FHomeTabSheet:     TTabSheet;
    FHomeModDots:      array[0..3] of TShape;   // status dots: MangoHud, vkBasalt, OptiScaler, vkSumi
    FHomeModVerLbls:   array[0..3] of TLabel;   // version text
    FHomeOptiLbls:     array[0..4] of TLabel;   // library version labels: FakeNvAPI, Optipatcher, FSR, XeSS, DLSS
    FHomeLibDots:      array[0..4] of TShape;   // library status dots
    FHomeDepDots:      array[0..7] of TShape;
    FHomeDepLbls:      array[0..7] of TLabel;
    FHomeGlobalBtn:    TPanel;
    FHomeBtnRow:       TPanel;
    FClearConfigBtn:   TPanel;    // Clear configuration button in Home/System card }

    // Moved to public:
    {     // Preset tab code-generated cards
    FPresetLayoutCards:   array[0..4] of TPanel;
    FPresetColorCards:    array[0..3] of TPanel;
    FPresetLayoutSelBars: array[0..4] of TPanel;
    FPresetColorSelBars:  array[0..3] of TPanel;
    FActiveLayoutCard:    Integer;   // -1 = none selected
    FActiveColorCard:     Integer;   // -1 = none selected
    FHoveredPresetCard:   TPanel;    // nil = none hovered }

    // Moved to public:
    {     // Visual tab code-generated cards (2-card layout: [0]=Appearance, [1]=Layout)
    FVisualCards:   array[0..5] of TPanel;
    FVisualGpuBar:  TPanel;
    FVisualHudBar:  TPanel;
    // Visual tab inner section panels (GroupBox-style) within FVisualCards[0]
    // [0]=Orientation [1]=Borders [2]=Background [3]=Fonts [4]=Position [5]=Columns
    FVisualSections: array[0..5] of TPanel;
    FVisualHudSep:   TPanel;  // horizontal separator above HUD row within main card }
    
    // Key capture references — each button shows the captured shortcut in its caption
    FCaptureBtn:        TBitBtn;  // button currently being captured
    // Moved to public:
    {     FVisualCaptureBtn:  TBitBtn;
    FLimitCaptureBtn:   TBitBtn;
    FLoggingCaptureBtn: TBitBtn; }
    // Moved to public:
    {     FVkToggleCaptureBtn:    TBitBtn;
    FVkToggleTitleLbl:      TLabel; }
    // Moved to public:
    {     FOsShortcutCaptureBtn:  TBitBtn; }
    FCaptureForm:       TForm;

    // Moved to public:
    {     // Extras tab code-generated layout
    FExtScrollBox:  TScrollBox;
    FExtBgPanel:    TPanel;
    FExtSysCard:    TPanel;   // wrapper card for systemGroupBox
    FExtLogCard:    TPanel;   // wrapper card for loggingGroupBox }

    // Moved to public:
    {     // vkSumi tab controls
    FVsCards:       array[0..2] of TPanel;
    FVsEnabledCB:   TCheckBox;
    FVsToggleEdit:  TEdit;
    FVsRestoreBtn:      TBitBtn;
    FVsToggleCaptureBtn: TBitBtn;
    FVsToggleTitleLbl:  TLabel;
    FVsLuminanceTitleLbl: TLabel;
    FVsChrominanceTitleLbl: TLabel;
    FVsTrackbars:   array[0..14] of TTrackBar;
    FVsValLabels:   array[0..14] of TLabel;
    FVsNameLabels:  array[0..14] of TLabel;
    FVsScrollBox:   TScrollBox;
    FVsBgPanel:     TPanel; }

    // Moved to public:
    {     // Performance tab code-generated cards
    FPerfCards:   array[0..3] of TPanel;
    FPerfLeftLbl: array[0..1] of TLabel;  // left-section title labels
    FPerfRightLbl:array[0..1] of TLabel;  // right-section title labels
    FVsyncRows:   array[0..1] of TPanel;  // Vulkan/OpenGL row chips
    FPerfInfoSec: TPanel;
    FPerfVsyncSec: TPanel;
    FPerfLimitSec: TPanel;
    FPerfFiltersSec: TPanel; }



    procedure BuildNavRail;
    procedure BuildPresetsWrapper;
    procedure AddNavyBgToTab(ATab: TTabSheet);
    procedure StyleGroupBoxNavy(GB: TGroupBox);
    // Exposed: procedure PresetsBgBoxPaint(Sender: TObject);
    // Exposed: procedure PresetsWrapperPaint(Sender: TObject);
    procedure PresetCardPaint(Sender: TObject);
    procedure PresetCardClick(Sender: TObject);
    procedure PresetCardMouseEnter(Sender: TObject);
    procedure PresetCardMouseLeave(Sender: TObject);
    function  FindPresetCard(ASender: TObject): TPanel;
    procedure UpdatePresetCardVisuals;
    procedure BuildSettingsButton;
    procedure RestoreNavRailColors;
    procedure SettingsBtnMouseEnter(Sender: TObject);
    procedure SettingsBtnMouseLeave(Sender: TObject);
    procedure SettingsBtnClick(Sender: TObject);
    procedure CubeAutoLaunchMenuItemClick(Sender: TObject);
    procedure BuildNavToolToggles;
    procedure BuildSmallToggleImages;
    procedure NavToolToggleClick(Sender: TObject);
    procedure UpdateNavToolToggleVisibility(AShowLabels: Boolean);
    // Exposed: procedure LoadGameToggleStates;
    function  GetGameToolEnabled(const AGameName: string; AToolIdx: Integer): Boolean;
    procedure SetGameToolEnabled(const AGameName: string; AToolIdx: Integer; AEnabled: Boolean);
    procedure ApplyToolEnabledState(AToolIdx: Integer; AEnabled: Boolean);
    function  ActiveToolIndex: Integer;
    procedure SetSaveBtnEnabled(AEnabled: Boolean);
    procedure SetControlTreeEnabled(ACtrl: TWinControl; AEnabled: Boolean);
    procedure PatchGameFGModWineDllOverrides(const AFGModFile: string; AEnabled: Boolean);
    procedure PatchGameFGModConditionalExport(const AFGModFile, AConditionalLine, ASearchKey: string);
    procedure BuildVkSumiTab;
    procedure VkSumiSliderChange(Sender: TObject);
    procedure LoadVkSumiConfig;
    procedure VsRestoreBtnClick(Sender: TObject);
    procedure PatchGameFGModConfigPath(const AFGModFile, AEnvVar, AConfigPath: string);
    procedure RemoveTweaksFromGameFGMod(const AFGModFile: string);
    procedure RemoveOptiScalerGameFiles(const AGameCfgDir: string);
    procedure CopyOptiScalerGameFiles(const AGameCfgDir: string);
    // Exposed: procedure EnsureGameFGModOptiScalerConditional(const AFGModFile: string);
    procedure NavItemClick(Sender: TObject);
    procedure NavItemMouseEnter(Sender: TObject);
    procedure NavItemMouseLeave(Sender: TObject);
    procedure NavItemPaint(Sender: TObject);
    // Exposed: procedure SetNavActive(AIndex: Integer);
    procedure NavToggleClick(Sender: TObject);
    procedure NavAnimTick(Sender: TObject);
    procedure ApplyNavWidth(AWidth: Integer);
    procedure ApplyNavCollapsed;
    procedure FormResize(Sender: TObject);
    procedure ReflowPresetTab(AContentW: Integer);
    procedure ReflowVisualTab(AContentW: Integer);
    procedure InitVisualTab;
    procedure VisualCardPaint(Sender: TObject);
    procedure PerfCardPaint(Sender: TObject);
    // Exposing: procedure SubCardPaint(Sender: TObject);
    procedure UpdateVisualCardTheme;
    // Exposing: procedure CaptureBtnClick(Sender: TObject);
    procedure CaptureFormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure InitPerformanceTab;
    procedure InitExtrasTab;
    procedure InitOptiScalerTab;
    procedure BuildFpsLimitEdit;
    procedure UpdatePerfCardTheme;
    // Exposing: procedure UpdateGenericCardTheme(Card: TPanel);
    procedure UpdateExtrasCardTheme;
    procedure ReflowPerformanceTab(AContentW: Integer);
    procedure ReflowOptiScalerTab(AContentW: Integer);
    procedure ReflowOptiScalerTabNew(AContentW: Integer);
    procedure RefreshOsStatusDots;
    procedure InitMetricsTab;
    procedure ReflowMetricsTab(AContentW: Integer);
    procedure ReflowExtrasTab(AContentW: Integer);
    procedure InitVkBasaltTab;
    procedure InitTweaksCards;
    procedure ReflowVkBasaltTab(AContentW: Integer);
    procedure ReflowVkSumiTab(AContentW: Integer);
    // Exposing: procedure ReflowSliderInSection(ASec: TPanel; AIndex: Integer);

    procedure StartCube;
    procedure StopCube;

    procedure InitGamesTab;
    procedure LoadSteamGames;
    procedure RefreshGameCards;
    procedure ReflowGamesGrid;
    procedure GamesScrollBoxResize(Sender: TObject);
    procedure GamesEmptySpaceClick(Sender: TObject);
    procedure GameCardMouseEnter(Sender: TObject);
    procedure GameCardMouseLeave(Sender: TObject);
    procedure GameCardClick(Sender: TObject);
    procedure GameCardMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure GameCardOpenFolderClick(Sender: TObject);
    procedure GameCardOpenPrefixClick(Sender: TObject);
    procedure GameCardUninstallClick(Sender: TObject);
    procedure AddNonSteamFolderClick(Sender: TObject);
    // Exposed: procedure ShowRemoveFoldersMenu(Sender: TObject; X, Y: Integer);
    procedure RemoveFolderMenuItemClick(Sender: TObject);
    procedure LoadNonSteamFolders(var ACardIndex: Integer; const ACardsPerRow, ARowMargin: Integer);
    // Exposed: procedure CoverThreadTerminated(Sender: TObject);
    procedure DrawCardRibbon(Bmp: TBitmap; BadgeMask: Integer);
    // Exposed: function  SearchSteamStoreGame(const AGameName: string; out AAppId: string): Boolean;
    // Exposed: function  DownloadSteamCover(const AAppId, ACachePath: string): Boolean;
    // Exposed: function  CleanGameNameForSearch(const AName: string): string;
    function  InsertSpacesInUppercase(const AName: string): string;
    // Exposed: function  SearchWebCover(const AGameName, ACachePath: string): Boolean;
    function  GetGameConfigDir(const AGameName: string): string;
    function  SanitizeFileName(const AName: string): string;
    // Exposed: function  FindFileInDir(const ADir, AFileName: string): string;
    procedure RunFGModUninstallCommands(const ATargetDir: string);
    procedure CheckAndUpdateConfigVersion;
    procedure RefreshGameCardsAsync(Data: PtrInt);
    function  GetMangoHudConfigEnvPrefix: string;
    function  GetMangoHudLaunchEnv: string;
    function  GetVkBasaltConfigEnvPrefix: string;
    function  GetVkSumiConfigEnvPrefix: string;
    function  GetVkBasaltLaunchEnv: string;
    function  GetVkSumiLaunchEnv: string;
    // Exposed: procedure UpdateGameContextLabel;
    // Exposed: procedure PreviewBtnClick(Sender: TObject);
    procedure LoadGlobalThumb;
    procedure ShowGameThumb(ACard: TPanel);
    // Exposed: procedure HideGameThumb;
    // Exposed: procedure ApplyCardBrightness(ACard: TPanel; BrightFactor: Integer);
    procedure ApplyAllCardsDim;
    // Exposed: procedure HoverTimerTick(Sender: TObject);
    // Exposed: function ParseAcfValue(const AContent, AKey: string): string;
    // Exposed: procedure GetSteamLibraries(Libraries: TStringList);
    // Exposed: function GetAppBaseDir: string;
    // Moved to public:
    {     function GetGeneralCheckBox(Index: Integer): TCheckBox;
    function GetGraphicsCheckBox(Index: Integer): TCheckBox;
    function GetPerformanceCheckBox(Index: Integer): TCheckBox;
    function OsHexToKeyStr(const HexStr: string): string; }
    // Exposing: procedure ReshadeGitProgress(APhase: string; APercent: Integer);
    // Exposed: procedure UpdateGeSpeedButtonState;
    // Exposed: procedure UpdateGlobalEnableMenuItemVisibility;
    procedure RemoveMangoHudFromFGMod;
    procedure LoadTweaksFromFGMod;
    procedure InitCustomEnvGroupBox;
    procedure ApplyCustomEnvTheme;
    procedure CustomEnvAddClick(Sender: TObject);
    procedure CustomEnvRemoveClick(Sender: TObject);
    procedure TweaksCheckChange(Sender: TObject);
    procedure UpdateTweaksVarListBox;
    procedure TweaksVarRemoveClick(Sender: TObject);
    procedure TweaksGridPrepareCanvas(sender: TObject; aCol, aRow: Integer; aState: TGridDrawState);
    procedure TweaksGridDrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
    procedure TweaksGridMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TweaksGridResize(Sender: TObject);
    procedure SyncTweaksGridFromCheckBoxes;

    // MD3-style tweaks list (replaces grid)
    procedure InitTweaksMD3;
    procedure TweaksMD3Paint(Sender: TObject);
    procedure TweaksMD3MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure TweaksMD3MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TweaksMD3MouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure TweaksMD3ScrollChange(Sender: TObject);
    procedure TweaksMD3BuildItems;
    procedure TweaksMD3ToggleItem(Index: Integer);
    procedure TweaksMD3FABClick(Sender: TObject);
    procedure TweaksMD3FABPaint(Sender: TObject);

    // MD3-style reshade effects list (vkBasalt tab)
    procedure VkReshadeMD3Paint(Sender: TObject);
    procedure VkReshadeMD3MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure VkReshadeMD3MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure VkReshadeMD3MouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure VkReshadeMD3ScrollChange(Sender: TObject);
    function TweaksMD3ItemHeight: Integer;
    function TweaksMD3HeaderHeight: Integer;
    procedure ApplyImageAntialiasing;
    
    // Home tab
    procedure InitHomeTab;
    procedure ShowHomeTab(Sender: TObject = nil);
    procedure RefreshHomeModuleStatus;
    procedure RefreshHomeOptiStatus;
    procedure RefreshHomeDeps;
    procedure HomeDiagramPaint(Sender: TObject);
    procedure HomeBtnRowResize(Sender: TObject);
    procedure HomeGlobalBtnClick(Sender: TObject);
    procedure HomeGameBtnClick(Sender: TObject);
    procedure HomeGlobalBtnEnter(Sender: TObject);
    procedure HomeGlobalBtnLeave(Sender: TObject);
    procedure HomeGameBtnEnter(Sender: TObject);
    procedure HomeGameBtnLeave(Sender: TObject);
    procedure ClearConfigBtnClick(Sender: TObject);
    procedure ClearConfigBtnEnter(Sender: TObject);
    procedure ClearConfigBtnLeave(Sender: TObject);
    procedure HomeChannelComboChange(Sender: TObject);
    function  GetMangoHudVersion: string;
    function  GetVkBasaltVersion: string;
    function  GetVkSumiVersion: string;
    function  FindBinPath(const BinName: string): string;
    function  FindLibPath(const LibName: string): string;

    // Keyboard shortcuts
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    
    // Status bar and search
    procedure StatusTimerTick(Sender: TObject);
    procedure ClearSearchHighlights;

    // Navigation label hover helpers
    procedure DoNavLabelMouseEnter(ALabel: TLabel);
    procedure DoNavLabelMouseLeave(ALabel: TLabel);

    // Layout helper
    procedure UnanchorControl(Ctrl: TControl);

    // Save helpers (extracted from saveBitBtnClick)
    procedure SaveTweaksConfig;
    procedure SaveOptiScalerConfig;
    procedure SaveVkBasaltConfig;
    // Exposing: procedure SaveVkSumiConfig;

    // MangoHud config loading helpers
    procedure LoadMangoHudBoolFlag(const ATrimmedLine: string);
    procedure LoadMangoHudKeyValue(const AKey, AValue: string);
  public
    // OptiScaler fields (moved from private)
    FOsScrollBox:    TScrollBox;
    FOsBgPanel:      TPanel;
    FOsGpuCard:      TPanel;
    FOsOptionsCard:  TPanel;
    FOsStatusCard:   TPanel;
    FOsOptiSec:      TPanel;
    FOsImgSec:       TPanel;
    FOsFakeSec:      TPanel;
    FOsStatDots:     array[0..5] of TShape;
    FOsStatNameLbls: array[0..5] of TLabel;
    FOsStatVerLbls:  array[0..5] of TLabel;
    FOsShortcutCaptureBtn:  TBitBtn;
    FLaunchCommand: string;
    FOptiscalerUpdate: TOptiscalerTab;
    FActiveGameName: string;
    FActiveGameIsNonSteam: Boolean;

    // Home tab fields (moved from private)
    FHomeTabSheet:     TTabSheet;
    FHomeModDots:      array[0..3] of TShape;   // status dots: MangoHud, vkBasalt, OptiScaler, vkSumi
    FHomeModVerLbls:   array[0..3] of TLabel;   // version text
    FHomeOptiLbls:     array[0..4] of TLabel;   // library version labels: FakeNvAPI, Optipatcher, FSR, XeSS, DLSS
    FHomeLibDots:      array[0..4] of TShape;   // library status dots
    FHomeDepDots:      array[0..7] of TShape;
    FHomeDepLbls:      array[0..7] of TLabel;
    FHomeGlobalBtn:    TPanel;
    FHomeBtnRow:       TPanel;
    FClearConfigBtn:   TPanel;    // Clear configuration button in Home/System card

    // vkBasalt/Reshade/Sumi fields (moved from private)
    // MangoHud UI helper fields (moved from private)
    FPresetsBgBox:   TPaintBox;          // full-width navy paintbox background for Presets tab
    FPresetsWrapper: TPanel;             // centered wrapper for the Presets tab content
    // Preset tab code-generated cards
    FPresetLayoutCards:   array[0..4] of TPanel;
    FPresetColorCards:    array[0..3] of TPanel;
    FPresetLayoutSelBars: array[0..4] of TPanel;
    FPresetColorSelBars:  array[0..3] of TPanel;
    FActiveLayoutCard:    Integer;   // -1 = none selected
    FActiveColorCard:     Integer;   // -1 = none selected
    FHoveredPresetCard:   TPanel;    // nil = none hovered
    // Visual tab code-generated cards (2-card layout: [0]=Appearance, [1]=Layout)
    FVisualCards:   array[0..5] of TPanel;
    FVisualGpuBar:  TPanel;
    FVisualHudBar:  TPanel;
    // Visual tab inner section panels (GroupBox-style) within FVisualCards[0]
    // [0]=Orientation [1]=Borders [2]=Background [3]=Fonts [4]=Position [5]=Columns
    FVisualSections: array[0..5] of TPanel;
    FVisualHudSep:   TPanel;  // horizontal separator above HUD row within main card
    FVisualCaptureBtn:  TBitBtn;
    FLimitCaptureBtn:   TBitBtn;
    FLoggingCaptureBtn: TBitBtn;
    // Extras tab code-generated layout
    FExtScrollBox:  TScrollBox;
    FExtBgPanel:    TPanel;
    FExtSysCard:    TPanel;   // wrapper card for systemGroupBox
    FExtLogCard:    TPanel;   // wrapper card for loggingGroupBox
    // Performance tab code-generated cards
    FPerfCards:   array[0..3] of TPanel;
    FPerfLeftLbl: array[0..1] of TLabel;  // left-section title labels
    FPerfRightLbl:array[0..1] of TLabel;  // right-section title labels
    FVsyncRows:   array[0..1] of TPanel;  // Vulkan/OpenGL row chips
    FPerfInfoSec: TPanel;
    FPerfVsyncSec: TPanel;
    FPerfLimitSec: TPanel;
    FPerfFiltersSec: TPanel;
    // FPS Limit custom input (replaces chip grid)
    FFpsLimitEdit:   TEdit;              // comma-separated FPS values
    FFpsLimitTitleLbl: TLabel;
    FFpsLimitHintLbl:  TLabel;
    // Metrics tab card redesign
    FMtScrollBox:    TScrollBox;
    FMtBgPanel:      TPanel;
    FMtGpuCard:      TPanel;
    FMtCpuCard:      TPanel;
    // vkBasalt tab redesign
    FVkReshadeCard:  TPanel;
    FVkBuiltinCard:  TPanel;
    FVkToggleCard:   TPanel;
    FVkAvHdrLbl:     TLabel;
    FVkActHdrLbl:    TLabel;
    // Fresh value labels (avoid LFM reparenting issues)
    FVkCasValLbl:    TLabel;
    FVkFxaaValLbl:   TLabel;
    FVkSmaaValLbl:   TLabel;
    FVkDlsValLbl:    TLabel;
    // Custom icons for built-in effects
    FVkCasIcon:      TImage;
    FVkFxaaIcon:     TImage;
    FVkSmaaIcon:     TImage;
    FVkDlsIcon:      TImage;
    // vkBasalt Reshade effects MD3 list (replaces dual listboxes)
    FVkReshadePB:    TPaintBox;
    FVkReshadeSB:    TScrollBar;
    FVkReshadeScrollPos: Integer;
    FVkReshadeHoverIdx:  Integer;
    // vkSumi tab controls
    FVsCards:       array[0..2] of TPanel;
    FVsEnabledCB:   TCheckBox;
    FVsToggleEdit:  TEdit;
    FVsRestoreBtn:      TBitBtn;
    FVsToggleCaptureBtn: TBitBtn;
    FVsToggleTitleLbl:  TLabel;
    FVsLuminanceTitleLbl: TLabel;
    FVsChrominanceTitleLbl: TLabel;
    FVsTrackbars:   array[0..14] of TTrackBar;
    FVsValLabels:   array[0..14] of TLabel;
    FVsNameLabels:  array[0..14] of TLabel;
    FVsScrollBox:   TScrollBox;
    FVsBgPanel:     TPanel;
    FVkReshadeSyncBtn:      TBitBtn;  // Sync/update reshade shaders button
    FVkToggleCaptureBtn:    TBitBtn;
    FVkToggleTitleLbl:      TLabel;
    FReshadeProgressBar: TProgressBar;
    FReshadePhaseLabel: TLabel;
    FReshadeDownloadedOnFirstShow: Boolean;
    FAutoDownloadingReshade: Boolean;
    FCustomSec:       TPanel;
    FCustomListBox:   TListBox;
    FTweaksVarListBox: TListBox;
    FTweaksGrid:       TStringGrid;

    // Tweaks tab MD3-style custom list (replaces TStringGrid)
    FTweaksPaintBox:   TPaintBox;
    FTweaksScrollBar:  TScrollBar;
    FTweaksScrollPos:  Integer;
    FTweaksHoverIdx:   Integer;
    FTweaksFABBtn:     TSpeedButton;
    FTweaksCatExpanded: array[0..3] of Boolean; // General, Graphics, Performance, Latency reduction
    FAntilagCheckBox:  TCheckBox;  // ENABLE_LAYER_MESA_ANTI_LAG=1
    FFSR4UpgradeCheckBox: TCheckBox;   // PROTON_FSR4_UPGRADE=1
    FDLSSUpgradeCheckBox: TCheckBox;   // PROTON_DLSS_UPGRADE=1
    FXeSSUpgradeCheckBox: TCheckBox;   // PROTON_XESS_UPGRADE=1
    FReEngineRTCheckBox: TCheckBox;    // RE Engine RT workaround
    FLowLatencyCheckBox: TCheckBox;
    FLowLatencyReflexCheckBox: TCheckBox;
    FLowLatencySpoofNvidiaCheckBox: TCheckBox;
    FLowLatencyHideAmdGpuCheckBox: TCheckBox;

    FGamesScrollBox: TScrollBox;
    FGamesPanel: TPanel;
    FGamesLoaded: Boolean;
    FCoverThread: TThread;
  FClosing: Boolean;  // true when form is closing — threads check this
    FHoveredCard:    TPanel;    // card currently under mouse
    FHoverBrightness: Integer; // 0..100 (0=35% dim, 100=full bright)
    FHoverDir:       Integer;  // +1 brightening, -1 dimming
    FHoverTimer:     TTimer;   // drives hover brightness animation
    FHoverBaseLeft:  Integer;  // original Left of hovered card before expansion
    FHoverBaseTop:   Integer;  // original Top of hovered card before expansion
    FInReflow:       Boolean;  // true while ReflowGamesGrid is running
    FReflowCount:    Integer;  // debug: how many reflows in a row
    FCardPanels:  TList;    // ordered list of game card TPanels
    FOrigCovers:  TList;    // parallel list of TLazIntfImage originals (owned)
    FNonSteamCoverThread: TThread;  // background thread for non-Steam cover downloads
    // Moved to public:
    {     FActiveGameName:    string;   // non-empty when editing a game-specific config
    FActiveGameIsNonSteam: Boolean; } // true when editing a non-steam game config
    FPreviewBtn:        TBitBtn;  // bottom-bar quick preview button (pascube/vkcube)
    FGameThumbBmp:      TBitmap;              // game cover drawn on the sidebar paintbox
    FGlobalThumbPng:    TPortableNetworkGraphic; // global-config icon (white, transparent)
    FGameCardMenu: TPopupMenu;      // right-click context menu for game cards
    FRemoveFoldersMenu: TPopupMenu;  // right-click context menu for Add Non-Steam Folder card
    FOpenPrefixMenuItem: TMenuItem;  // hidden for non-Steam cards
    FRightClickedCard: TPanel;      // card that triggered the context menu
    FGameMenuImgList: TImageList;   // icons for the game card context menu
    FMangoIconGfx: TPortableNetworkGraphic;  // cached badge icon for MangoHud
    FOptiIconGfx:  TPortableNetworkGraphic;
  public
    function IsOptiScalerInstalled: Boolean;
    procedure ShowStatusMessage(const AMessage: string; ADuration: Integer = 3000);
    function GetGeneralCheckBox(Index: Integer): TCheckBox;
    function GetGraphicsCheckBox(Index: Integer): TCheckBox;
    function GetPerformanceCheckBox(Index: Integer): TCheckBox;
    function OsHexToKeyStr(const HexStr: string): string;
    procedure PresetsBgBoxPaint(Sender: TObject);
    procedure PresetsWrapperPaint(Sender: TObject);
    procedure LoadGameToggleStates;
    procedure EnsureGameFGModOptiScalerConditional(const AFGModFile: string);
    procedure SetNavActive(AIndex: Integer);
    procedure ShowRemoveFoldersMenu(Sender: TObject; X, Y: Integer);
    procedure CoverThreadTerminated(Sender: TObject);
    function  SearchSteamStoreGame(const AGameName: string; out AAppId: string): Boolean;
    function  DownloadSteamCover(const AAppId, ACachePath: string): Boolean;
    function  CleanGameNameForSearch(const AName: string): string;
    function  SearchWebCover(const AGameName, ACachePath: string): Boolean;
    function  FindFileInDir(const ADir, AFileName: string): string;
    procedure UpdateGameContextLabel;
    procedure PreviewBtnClick(Sender: TObject);
    procedure HideGameThumb;
    procedure ApplyCardBrightness(ACard: TPanel; BrightFactor: Integer);
    procedure HoverTimerTick(Sender: TObject);
    function ParseAcfValue(const AContent, AKey: string): string;
    procedure GetSteamLibraries(Libraries: TStringList);
    function GetAppBaseDir: string;
    procedure UpdateGeSpeedButtonState;
    procedure UpdateGlobalEnableMenuItemVisibility;

    // Exposed vkBasalt/Reshade/Sumi methods
    procedure SubCardPaint(Sender: TObject);
    procedure CaptureBtnClick(Sender: TObject);
    procedure SaveVkSumiConfig;
    procedure ReflowSliderInSection(ASec: TPanel; AIndex: Integer);
    procedure UpdateGenericCardTheme(Card: TPanel);
    procedure ReshadeGitProgress(APhase: string; APercent: Integer);
  end;





function GetMangoHudConfigDir(): String;
function GetVkBasaltConfigDir(): String;
function GetVkSumiConfigDir(): String;
procedure ListFilesToListBox(const BaseDir: string; ListBox: TListBox; const FilterExts: array of string; const Recursive: Boolean = True; const SkipDotDirs: Boolean = True);

var
  goverlayform: Tgoverlayform;

  // ============================================================================
  // DESIGN SYSTEM CONSTANTS
  // ============================================================================
var
  // ============================================================================
  // APPLICATION STATE AND VERSION
  // ============================================================================
  GVERSION: string;                     // Current Goverlay version
  GCHANNEL: string;                     // Release channel (stable/git)
  mangohudsel: boolean;                 // MangoHud tab selected
  vkbasaltsel: boolean;                 // vkBasalt tab selected

  // ============================================================================
  // CONFIGURATION FILE PATHS AND FOLDERS
  // ============================================================================
  MANGOHUDCFGFILE: string;              // Path to MangoHud.conf
  MANGOHUDFOLDER: string;               // MangoHud configuration folder
  CUSTOMCFGFILE: string;                // Path to custom.conf (MangoHud presets)
  VKBASALTFOLDER: string;               // vkBasalt configuration folder
  VKBASALTCFGFILE: string;              // Path to vkBasalt.conf
  VKSUMIFOLDER: string;                 // vkSumi configuration folder
  VKSUMICFGFILE: string;                // Path to vkSumi.conf
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

  // Nav rail
  NAV_ITEM_H      = 64;   // height of each nav item
  NAV_ITEM_W      = 211;  // width (same as sidebar)
  NAV_INDICATOR_W = 3;    // active indicator bar width
  NAV_ICON_SIZE   = 28;   // icon area size
  NAV_COLOR_BG        = $00281A16; // item bg — matches sidebar body (R=22,G=26,B=40)
  NAV_COLOR_HOVER     = $003A2820; // item hover (R=32,G=40,B=58)
  NAV_COLOR_ACTIVE    = $004C3830; // item active (R=48,G=56,B=76)
  NAV_COLOR_INDICATOR = clHighlight; // active indicator — system accent/selection color
  NAV_IND_GAMES = $0000A5FF;  // amber (R=255,G=165,B=0)  — Games category accent
  NAV_IND_TOOLS = clHighlight; // tools keep the system accent colour
  // Light theme nav colors
  NAV_LIGHT_BG        = $00E8E8E8;
  NAV_LIGHT_HOVER     = $00D0D0D0;
  NAV_LIGHT_ACTIVE    = $00C0C0C0;
  NAV_W_EXPANDED  = 211;
  NAV_W_COLLAPSED = 60;
implementation

uses
  xlib, x, tweaks_md3, games_tab, vkbasalt_tab, mangohud_ui, goverlay_system, optiscaler_tab, home_tab;

// Shared constants for game card dimensions — used by LoadSteamGames,
// ReflowGamesGrid, ApplyCardBrightness, and the cover download thread.
const
  CARD_W      = 150;
  CARD_H      = 215;
  CARD_IMG_H  = 215;
  GRAD_H      = 55;
  CARD_MARGIN = 8;
  SEL_EXPAND  = 3;  // px expansion per side for hover scale-up (~1.03×)

// Forward declaration — defined later in the file


// ============================================================================
// Debug logger — writes timestamped lines to stderr
// ============================================================================
var
  GDbgT0: QWord = 0;

procedure DbgLog(const Msg: string);
var
  T: QWord;
begin
  T := GetTickCount64;
  if GDbgT0 = 0 then GDbgT0 := T;
  WriteLn(StdErr, Format('[%6d ms] %s', [T - GDbgT0, Msg]));
end;

// ============================================================================
// Background thread: downloads missing Steam cover images via Steam CDN
// ============================================================================


// ============================================================================
// Background thread: downloads non-Steam cover images (Steam Store + web search)
// ============================================================================


procedure Tgoverlayform.CoverThreadTerminated(Sender: TObject);
begin
  TGamesTabHelper(FGamesHelper).CoverThreadTerminated(Sender);
end;
procedure Tgoverlayform.protontricksManagerButtonClick(Sender: TObject);
begin
  if not Assigned(protontricksform) then
    Application.CreateForm(Tprotontricksform, protontricksform);
  protontricksform.ShowModal;
end;



{$R *.lfm}


{ Tgoverlayform }


//radeon theme
// Send desktop notification - works in both Flatpak and normal environments
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

function GetMangoHudConfigDir(): String;
var
  ConfigHome: String;
begin
  // When running in Flatpak, games run outside the sandbox and need to access
  // the host MangoHud configuration. Always use the host .config directory.
  if IsRunningInFlatpak then
  begin
    ConfigHome := GetUserDir + '.config';
  end
  else
  begin
    // For Flatpak, try HOST_XDG_CONFIG_HOME first to access the real host location
    ConfigHome := GetEnvironmentVariable('HOST_XDG_CONFIG_HOME');
    
    // Fall back to standard XDG_CONFIG_HOME
    if ConfigHome = '' then
      ConfigHome := GetEnvironmentVariable('XDG_CONFIG_HOME');
    
    // Final fallback to ~/.config
    if ConfigHome = '' then
      ConfigHome := GetUserDir + '.config';
  end;
  
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

// Function to get vkSumi config directory with proper XDG support
function GetVkSumiConfigDir(): String;
var
  ConfigHome: String;
begin
  if IsRunningInFlatpak then
  begin
    ConfigHome := GetUserDir + '.config';
  end
  else
  begin
    ConfigHome := GetEnvironmentVariable('XDG_CONFIG_HOME');
    if ConfigHome = '' then
      ConfigHome := GetUserDir + '.config';
  end;
  Result := IncludeTrailingPathDelimiter(ConfigHome) + 'vkSumi';
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

    // Refresh status dots so the new version tag appears next to the installed version
    RefreshOsStatusDots;
  end;
end;

procedure Tgoverlayform.tweaksLabelClick(Sender: TObject);
begin
  DbgLog('>> tweaksLabelClick BEGIN');
  SetNavActive(4);

//Enable goverlay tabs
goverlayPageControl.ShowTabs:=false; //disable mangohud tab
vkbasalttabsheet.TabVisible:=false; //disable vkbasalt tab
vksumiTabSheet.TabVisible:=false;   //disable vksumi tab
optiscalertabsheet.TabVisible:=false; //disable optiscaler tab
gamesTabSheet.TabVisible:=false; //disable games tab
tweakstabsheet.TabVisible:=true;

goverlayPageControl.ActivePage:=tweaksTabsheet;

//Hide notification messages
notificationLabel.Visible:=false;
commandPanel.Visible:=false;


//Show Global Enable controls and bottom bar for tweaks tabs

goverlaybarPanel.Visible:=true;
popupBitBtn.Visible := False;
FPreviewBtn.Visible  := False;
UpdateGeSpeedButtonState;
UpdateGlobalEnableMenuItemVisibility;
// Re-apply per-game tool enabled state for Tweaks
if FActiveGameName <> '' then
begin
  ApplyToolEnabledState(3, FNavToolEnabled[3]);
  SetSaveBtnEnabled(FNavToolEnabled[3]);
end;

// Reload tweak checkboxes from the correct fgmod (game-specific or global)
// depending on the current context. Without this, the UI always shows the
// global state loaded at startup, even when a game is selected.
LoadTweaksFromFGMod;

end;

procedure Tgoverlayform.updateBitBtnClick(Sender: TObject);
begin
  updateProgressBar.Visible := True;
  updatestatusLabel.Visible := True;
  FOptiscalerUpdate.UpdateButtonClick(Sender);
  updateProgressBar.Visible := False;
  updatestatusLabel.Visible := False;
  // Re-enable controls after installation completes
  UpdateGeSpeedButtonState;
  // Reload installed versions and refresh the Software Status card immediately
  if Assigned(FOptiscalerUpdate) then
    FOptiscalerUpdate.LoadVersionsFromFile;
  RefreshOsStatusDots;
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
var
  GameCfgDir: string;
begin
  DbgLog('>> vkbasaltLabelClick BEGIN');

  // In game mode, point vkBasalt config to the game-specific folder
  if FActiveGameName <> '' then
  begin
    GameCfgDir := GetGameConfigDir(FActiveGameName);
    if not DirectoryExists(GameCfgDir) then
      ForceDirectories(GameCfgDir);
    VKBASALTCFGFILE := GameCfgDir + 'vkBasalt.conf';
    VKSUMICFGFILE := GameCfgDir + 'vkSumi.conf';
  end;

  // Reload UI from the correct config file (VKBASALTCFGFILE was just updated above)
  LoadVkBasaltConfig;
  LoadVkSumiConfig;

  SetNavActive(2);

  //Show only vkBasalt and vkSumi tabs
  goverlayPageControl.ShowTabs:=true;
  presetTabSheet.TabVisible:=false;
  visualTabSheet.TabVisible:=false;
  performanceTabSheet.TabVisible:=false;
  metricsTabSheet.TabVisible:=false;
  extrasTabSheet.TabVisible:=false;
  optiscalertabsheet.TabVisible:=false;
  tweakstabsheet.TabVisible:=false;
  gamesTabSheet.TabVisible:=false;
  FHomeTabSheet.TabVisible:=false;

  vkbasalttabsheet.TabVisible:=true;
  vksumiTabSheet.TabVisible:= not IsRunningInFlatpak;
  goverlayPageControl.ActivePage:=vkbasaltTabsheet;

  // Stop any running cube instances when entering vkBasalt tab
  ExecuteGUICommand('killall vkcube 2>/dev/null; killall pascube 2>/dev/null; true');


  //Hide notification messages
  notificationLabel.Visible:=false;
  commandPanel.Visible:=false;


  //Restore bottom bar
  goverlaybarPanel.Visible:=true;
  popupBitBtn.Visible := True;
  FPreviewBtn.Visible  := True;
  //Update geSpeedButton state for vkBasalt
  UpdateGeSpeedButtonState;
  UpdateGlobalEnableMenuItemVisibility;
  // Re-apply per-game tool enabled state (overrides UpdateGeSpeedButtonState if tool is disabled)
  if FActiveGameName <> '' then
  begin
    ApplyToolEnabledState(1, FNavToolEnabled[1]);
    SetSaveBtnEnabled(FNavToolEnabled[1]);
  end;

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

procedure Tgoverlayform.DoNavLabelMouseEnter(ALabel: TLabel);
begin
  if ALabel.Font.Color <> clWhite then
    ALabel.Font.Color := LightenColor(ALabel.Font.Color, 80);
end;

procedure Tgoverlayform.DoNavLabelMouseLeave(ALabel: TLabel);
begin
  if ALabel.Font.Color <> clWhite then
    ALabel.Font.Color := clGray;
end;

procedure Tgoverlayform.mangohudLabelMouseEnter(Sender: TObject);
begin
  DoNavLabelMouseEnter(mangohudLabel);
end;

procedure Tgoverlayform.mangohudLabelMouseLeave(Sender: TObject);
begin
  DoNavLabelMouseLeave(mangohudLabel);
end;

procedure Tgoverlayform.vkbasaltLabelMouseEnter(Sender: TObject);
begin
  DoNavLabelMouseEnter(vkbasaltLabel);
end;

procedure Tgoverlayform.vkbasaltLabelMouseLeave(Sender: TObject);
begin
  DoNavLabelMouseLeave(vkbasaltLabel);
end;

procedure Tgoverlayform.optiscalerLabelMouseEnter(Sender: TObject);
begin
  DoNavLabelMouseEnter(optiscalerLabel);
end;

procedure Tgoverlayform.optiscalerLabelMouseLeave(Sender: TObject);
begin
  DoNavLabelMouseLeave(optiscalerLabel);
end;

procedure Tgoverlayform.tweaksLabelMouseEnter(Sender: TObject);
begin
  DoNavLabelMouseEnter(tweaksLabel);
end;

procedure Tgoverlayform.tweaksLabelMouseLeave(Sender: TObject);
begin
  DoNavLabelMouseLeave(tweaksLabel);
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

procedure Tgoverlayform.AddNavyBgToTab(ATab: TTabSheet);
var
  BgBox: TPaintBox;
begin
  BgBox := TPaintBox.Create(Self);
  BgBox.Parent  := ATab;
  BgBox.Align   := alClient;
  BgBox.OnPaint := @PresetsBgBoxPaint;
end;

procedure Tgoverlayform.StyleGroupBoxNavy(GB: TGroupBox);
var
  SS: WideString;
begin
  if CurrentTheme = tmLight then
    SS := 'background-color: rgb(240,240,240); border: 1px solid rgb(200,200,200); color: black;'
  else
    SS := 'background-color: rgb(26,30,46); border: 1px solid rgb(36,40,62); color: white;';
  QWidget_setStyleSheet(TQtWidget(GB.Handle).Widget, @SS);
end;

procedure Tgoverlayform.PresetsBgBoxPaint(Sender: TObject);
var
  PB: TPaintBox;
begin
  PB := TPaintBox(Sender);
  if CurrentTheme = tmLight then
    PB.Canvas.Brush.Color := LighterBackgroundColor
  else
    PB.Canvas.Brush.Color := RGBToColor(22, 26, 40);
  PB.Canvas.FillRect(Rect(0, 0, PB.Width, PB.Height));
end;

procedure Tgoverlayform.PresetsWrapperPaint(Sender: TObject);
var
  P: TPanel;
begin
  P := TPanel(Sender);
  if CurrentTheme = tmLight then
    P.Canvas.Brush.Color := LighterBackgroundColor
  else
    P.Canvas.Brush.Color := RGBToColor(22, 26, 40);
  P.Canvas.FillRect(Rect(0, 0, P.Width, P.Height));
end;

procedure Tgoverlayform.goverlayPaintBoxPaint(Sender: TObject);
const
  THUMB_MARGIN = 8;
  THUMB_GAP    = 12;
var
  TWidth, THeight: Integer;
  OffBmp: TBitmap;
  ThumbY, ThumbW, ThumbH: Integer;
  ThumbDst: TRect;
  AvailH, IconTop: Integer;
begin
  TWidth  := goverlayPaintBox.Width;
  THeight := goverlayPaintBox.Height;

  // --- Glassmorphism simulation: single solid deep-navy fill + subtle borders ---
  OffBmp := TBitmap.Create;
  try
    OffBmp.SetSize(TWidth, THeight);

    // Body — theme-aware background
    if CurrentTheme = tmLight then
      OffBmp.Canvas.Brush.Color := RGBToColor(238, 238, 238)
    else
      OffBmp.Canvas.Brush.Color := RGBToColor(22, 26, 40);
    OffBmp.Canvas.FillRect(Rect(0, 0, TWidth, THeight));

    // Left specular — subtle edge highlight
    if CurrentTheme = tmLight then
      OffBmp.Canvas.Pen.Color := RGBToColor(200, 200, 200)
    else
      OffBmp.Canvas.Pen.Color := RGBToColor(55, 64, 95);
    OffBmp.Canvas.Line(0, 0, 0, THeight);

    // No right separator — content area uses same navy background, seamless join

    goverlayPaintBox.Canvas.Draw(0, 0, OffBmp);
  finally
    OffBmp.Free;
  end;

  // Draw thumbnail/icon in the gap between the last nav item and the settings button.
  if (Length(FNavItems) > 0) and
     (Assigned(FGameThumbBmp) or Assigned(FGlobalThumbPng)) then
  begin
    // Top boundary: just below the last nav item (in paintbox coordinates)
    ThumbY := (FNavItems[High(FNavItems)].Top - goverlayPaintBox.Top)
              + FNavItems[High(FNavItems)].Height + THUMB_GAP;

    // Bottom boundary: settings button area ≈ 52px from paintbox bottom
    ThumbH := (THeight - 52) - ThumbY - THUMB_GAP;
    if ThumbH < 4 then ThumbH := 4;

    // Width fills the sidebar minus margins
    ThumbW := TWidth - THUMB_MARGIN * 2;
    if ThumbW < 4 then ThumbW := 4;

    if Assigned(FGameThumbBmp) and (FGameThumbBmp.Width > 0) then
    begin
      // Game cover: preserve aspect ratio, scale to fit
      if ThumbW * FGameThumbBmp.Height div FGameThumbBmp.Width > ThumbH then
        ThumbW := ThumbH * FGameThumbBmp.Width div FGameThumbBmp.Height;
      ThumbH := ThumbW * FGameThumbBmp.Height div FGameThumbBmp.Width;
      // Vertically center within available slot
      AvailH := (THeight - 52) - ThumbY - THUMB_GAP;
      IconTop := ThumbY + (AvailH - ThumbH) div 2;
      if IconTop < ThumbY then IconTop := ThumbY;
      ThumbDst := Rect(
        (TWidth - ThumbW) div 2, IconTop,
        (TWidth - ThumbW) div 2 + ThumbW, IconTop + ThumbH);
      goverlayPaintBox.Canvas.StretchDraw(ThumbDst, FGameThumbBmp);
    end
    else if Assigned(FGlobalThumbPng) and (FGlobalThumbPng.Width > 0)
         and (FNavActive > 0) then
    begin
      // Collapsed: icon at 75%, font 7, short label; expanded: 50%, font 9, full label
      if ThumbW > ThumbH then ThumbW := ThumbH
      else ThumbH := ThumbW;
      if FNavCollapsed then
      begin
        ThumbW := ThumbW * 3 div 4;
        ThumbH := ThumbH * 3 div 4;
        goverlayPaintBox.Canvas.Font.Size := 7;
      end
      else
      begin
        ThumbW := ThumbW div 2;
        ThumbH := ThumbH div 2;
        goverlayPaintBox.Canvas.Font.Size := 9;
      end;
      goverlayPaintBox.Canvas.Font.Style := [];

      // Vertically center icon+gap+label within the available slot
      AvailH := (THeight - 52) - ThumbY - THUMB_GAP;
      IconTop := ThumbY + (AvailH - ThumbH - 6 - 16) div 2;
      if IconTop < ThumbY then IconTop := ThumbY;

      ThumbDst := Rect(
        (TWidth - ThumbW) div 2, IconTop,
        (TWidth - ThumbW) div 2 + ThumbW, IconTop + ThumbH);
      goverlayPaintBox.Canvas.StretchDraw(ThumbDst, FGlobalThumbPng);

      // Label: "Global" when collapsed, "Global config" when expanded
      if CurrentTheme = tmLight then
        goverlayPaintBox.Canvas.Font.Color := clBlack
      else
        goverlayPaintBox.Canvas.Font.Color  := clWhite;
      goverlayPaintBox.Canvas.Brush.Style := bsClear;
      if FNavCollapsed then
      begin
        goverlayPaintBox.Canvas.TextOut(
          (TWidth - goverlayPaintBox.Canvas.TextWidth('Global')) div 2,
          IconTop + ThumbH + 6, 'Global');
      end
      else
      begin
        goverlayPaintBox.Canvas.TextOut(
          (TWidth - goverlayPaintBox.Canvas.TextWidth('Global config')) div 2,
          IconTop + ThumbH + 6, 'Global config');
      end;
    end;
  end;
end;

//Functions for shaders

// List files from BaseDir directory in ListBox, optionally filtering by extensions.
// Ex.: FilterExts = []  -> list everything
//      FilterExts = ['.fx', '.fxh'] -> list only ReShade effects
procedure ListFilesToListBox(const BaseDir: string; ListBox: TListBox;
  const FilterExts: array of string; const Recursive: Boolean;
  const SkipDotDirs: Boolean);

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
begin
  TOptiScalerTabHelper(FOptiScalerHelper).LoadOptiScalerConfig;
end;

procedure Tgoverlayform.LoadMangoHudConfig;
begin
  TMangoHudUiHelper(FMangoHelper).LoadMangoHudConfig;
end;



procedure Tgoverlayform.LoadMangoHudBoolFlag(const ATrimmedLine: string);
begin
  TMangoHudUiHelper(FMangoHelper).LoadMangoHudBoolFlag(ATrimmedLine);
end;

procedure Tgoverlayform.LoadMangoHudKeyValue(const AKey, AValue: string);
begin
  TMangoHudUiHelper(FMangoHelper).LoadMangoHudKeyValue(AKey, AValue);
end;

procedure Tgoverlayform.SaveMangoHudConfig;
begin
  TMangoHudUiHelper(FMangoHelper).SaveMangoHudConfig;
end;

procedure Tgoverlayform.LoadVkBasaltConfig;
var
  Settings: TVkBasaltSettings;
begin
  if not FileExists(VKBASALTCFGFILE) then
    Exit;

  // Reset all controls before loading so stale values from a previous config
  // do not bleed into the newly loaded one.
  acteffectsListBox.Items.Clear;
  casTrackBar.Position  := 0;
  fxaaTrackBar.Position := 0;
  smaaTrackBar.Position := 0;
  dlsTrackBar.Position  := 0;
  casvalueLabel.Caption  := '0';
  fxaavalueLabel.Caption := '0';
  smaavalueLabel.Caption := '0';
  dlsvalueLabel.Caption  := '0';

  if not overlay_config.LoadVkBasaltConfig(VKBASALTCFGFILE, aveffectsListbox.Items, acteffectsListBox.Items, Settings) then
    Exit;

  // Map settings back to controls
  casTrackBar.Position := Settings.CasPosition;
  casvalueLabel.Caption := IntToStr(casTrackBar.Position);
  if Assigned(FVkCasValLbl) then FVkCasValLbl.Caption := casvalueLabel.Caption;

  fxaaTrackBar.Position := Settings.FxaaPosition;
  fxaavalueLabel.Caption := IntToStr(fxaaTrackBar.Position);
  if Assigned(FVkFxaaValLbl) then FVkFxaaValLbl.Caption := fxaavalueLabel.Caption;

  smaaTrackBar.Position := Settings.SmaaPosition;
  smaavalueLabel.Caption := IntToStr(smaaTrackBar.Position);
  if Assigned(FVkSmaaValLbl) then FVkSmaaValLbl.Caption := smaavalueLabel.Caption;

  dlsTrackBar.Position := Settings.DlsPosition;
  dlsvalueLabel.Caption := IntToStr(dlsTrackBar.Position);
  if Assigned(FVkDlsValLbl) then FVkDlsValLbl.Caption := dlsvalueLabel.Caption;

  if Settings.ToggleKey <> '' then
  begin
    vkbtogglekeyCombobox.Text := Settings.ToggleKey;
    if Assigned(FVkToggleCaptureBtn) then
      FVkToggleCaptureBtn.Caption := '⌨ ' + Settings.ToggleKey;
  end;

  if Assigned(FVkReshadePB) then FVkReshadePB.Invalidate;
end;

procedure Tgoverlayform.vkbasaltTabSheetShow(Sender: TObject);
var
  RepoDir: string;
begin
  // Reload vkBasalt config whenever the tab becomes visible so that
  // changes saved from another context (or another tab switch) are reflected
  // in the UI. This fixes the issue where switching away and back to vkBasalt
  // would show stale/reset values even though the file was saved correctly.
  LoadVkBasaltConfig;

  if not FReshadeDownloadedOnFirstShow then
  begin
    FReshadeDownloadedOnFirstShow := True;
    RepoDir := IncludeTrailingPathDelimiter(VKBASALTFOLDER) + 'reshade-shaders';
    if not DirectoryExists(RepoDir) then
    begin
      FAutoDownloadingReshade := True;
      try
        reshaderefreshBitBtnClick(nil);
      finally
        FAutoDownloadingReshade := False;
      end;
    end;
  end;
end;

procedure Tgoverlayform.vkSumiTabSheetShow(Sender: TObject);
var
  ContentW: Integer;
  Card: TPanel;
  ci, gi: Integer;
  Sec: TPanel;
begin
  LoadVkSumiConfig;
  // Reflow vkSumi tab with correct width when tab becomes visible
  if Assigned(FVsScrollBox) then
    ContentW := FVsScrollBox.ClientWidth
  else
    ContentW := vksumiTabSheet.ClientWidth;
  if ContentW < 400 then ContentW := 400;
  ReflowVkSumiTab(ContentW);

  // Force section repaint
  for ci := 1 to 2 do
  begin
    Card := FVsCards[ci];
    if Assigned(Card) then
      for gi := 0 to Card.ControlCount - 1 do
        if Card.Controls[gi] is TPanel then
          TPanel(Card.Controls[gi]).Invalidate;
  end;
end;

procedure Tgoverlayform.performanceTabSheetShow(Sender: TObject);
var
  ContentW: Integer;
begin
  ContentW := Max(1, Self.ClientWidth - goverlayPaintBox.Width);
  ReflowPerformanceTab(ContentW);
  UpdatePerfCardTheme;
end;

procedure Tgoverlayform.visualTabSheetShow(Sender: TObject);
begin
  UpdateVisualCardTheme;
end;

procedure Tgoverlayform.metricsTabSheetShow(Sender: TObject);
begin
  UpdateGenericCardTheme(FMtGpuCard);
  UpdateGenericCardTheme(FMtCpuCard);
end;

// ============================================================================
// MODERN DESIGN SYSTEM HELPERS
// ============================================================================
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
    commandPaintBoxClick(nil);
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
var
  k: Integer;
begin
  FClosing := True;
  if Assigned(FCoverThread) then
  begin
    FCoverThread.Terminate;
    FCoverThread := nil; // thread frees itself (FreeOnTerminate = True)
  end;
  if Assigned(FNonSteamCoverThread) then
  begin
    FNonSteamCoverThread.Terminate;
    FNonSteamCoverThread := nil; // thread frees itself (FreeOnTerminate = True)
  end;
  if Assigned(FOrigCovers) then
  begin
    for k := 0 to FOrigCovers.Count - 1 do
      if FOrigCovers[k] <> nil then
        TLazIntfImage(FOrigCovers[k]).Free;
    FreeAndNil(FOrigCovers);
  end;
  FreeAndNil(FCardPanels);
  FreeAndNil(FGlobalThumbPng);
  FreeAndNil(FMangoIconGfx);
  FreeAndNil(FOptiIconGfx);
  FreeAndNil(FOptiScalerHelper);
  FreeAndNil(FHomeHelper);
  FreeAndNil(FTweaksHelper);
  FreeAndNil(FGamesHelper);
  FreeAndNil(FBasaltHelper);
  FreeAndNil(FMangoHelper);
  ExecuteGUICommand('killall pascube');
  ExecuteGUICommand('killall vkcube');
end;

procedure Tgoverlayform.UnanchorControl(Ctrl: TControl);
begin
  if Ctrl is TWinControl then
  begin
    TWinControl(Ctrl).AnchorSideLeft.Control := nil;
    TWinControl(Ctrl).AnchorSideRight.Control := nil;
    TWinControl(Ctrl).AnchorSideTop.Control := nil;
    TWinControl(Ctrl).AnchorSideBottom.Control := nil;
  end;
  Ctrl.Anchors := [akTop, akLeft];
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
   SavedDriver: string;

begin
  FGamesHelper := TGamesTabHelper.Create(Self);
  FTweaksHelper := TTweaksMD3Helper.Create(Self);
  FBasaltHelper := TVkBasaltTabHelper.Create(Self);
  FMangoHelper := TMangoHudUiHelper.Create(Self);
  FOptiScalerHelper := TOptiScalerTabHelper.Create(Self);
  FHomeHelper := THomeTabHelper.Create(Self);
  FReshadeDownloadedOnFirstShow := False;
  FAutoDownloadingReshade := False;

  //Program Version
  GVERSION := '1.8.3';
  GCHANNEL := 'git'; //stable ou git

  // Initialize bgmod directory with embedded scripts
  // This ensures bgmod scripts are always available without downloading
  InitializeBGModDirectory;

  // Auto-install OptiScaler if not present in BGMOD directory
  // This prevents BGMOD from failing due to missing dependencies
  if IsBGModInitialized then
  begin
    if not IsBGModOptiScalerInstalled(GetFGModPath) then
    begin
      WriteLn('[GOVERLAY] OptiScaler not detected in BGMOD, starting automatic installation...');
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

  // Check and update config version, potentially prompting for a config clear
  CheckAndUpdateConfigVersion;

  //Set initial TAB
  goverlayPageControl.ActivePage:=gamesTabsheet;

   // Initialize menu selections
  mangohudsel := true;
  goverlayPanel.Visible:=true;
  goverlayPanel.BorderStyle := bsNone;
  goverlayPanel.Color := RGBToColor(22, 26, 40);
  goverlayPanel.ParentColor := False;
  goverlayPanel.OnPaint := @PresetsWrapperPaint;
  goverlayPageControl.Style := tsTabs;
  
  // Apply comprehensive tooltips to all components
  ApplyAllHints(Self);
  
  // Prevent maximizing — layout is fixed-width and doesn't benefit from it
  BorderIcons := BorderIcons - [biMaximize];

  // Apply modern design system
  //ApplyModernTypography(Self);  // Disabled - user preference
  //ApplyModernSpacing(Self);  // Disabled - user preference
  ApplyIconsToButtons(Self);
  BuildNavRail;
  BuildPresetsWrapper;
  BuildSettingsButton;

  // Apply navy background to remaining tabs (vkBasalt, OptiScaler, Tweaks)
  // Games tab handled separately via FGamesScrollBox/FGamesPanel
  AddNavyBgToTab(vkbasaltTabSheet);
  AddNavyBgToTab(optiscalerTabSheet);

  // Create vkSumi tab sheet (must exist before BuildVkSumiTab)
  vksumiTabSheet := TTabSheet.Create(goverlayPageControl);
  vksumiTabSheet.PageControl := goverlayPageControl;
  vksumiTabSheet.Caption     := 'vkSumi';
  vksumiTabSheet.TabVisible  := False;
  vksumiTabSheet.PageIndex   := vkbasaltTabSheet.PageIndex + 1;

  BuildVkSumiTab;
  InitTweaksCards;

  // Detach all anchor-side control references for every groupbox we reflow
  // manually (Visual + Performance tabs). Without this the LCL anchor engine
  // keeps repositioning them even when Anchors = [akTop, akLeft].
  UnanchorControl(orientationGroupBox);
  UnanchorControl(borderGroupBox);
  UnanchorControl(backgroundGroupBox);
  UnanchorControl(fontsGroupBox);
  UnanchorControl(positionGroupBox);
  UnanchorControl(columsGroupBox);
  UnanchorControl(vsyncGroupBox);
  UnanchorControl(filtersGroupBox);

  // Detach anchor-side control references for Tweaks tab inner groupboxes
  UnanchorControl(generalGroupBox);
  UnanchorControl(graphicsGroupBox);
  UnanchorControl(performanceGroupBox);

  customenvEdit.Anchors := [akTop, akLeft];

  InitCustomEnvGroupBox;

  // Detach anchor-side control references for OptiScaler tab inner groupboxes
  UnanchorControl(optiscalerGroupBox);
  UnanchorControl(imgmenuGroupBox);
  UnanchorControl(fakenvapiGroupBox);

  // Mark controls that should preserve their custom colors during theme changes.
  // This replaces the hardcoded name blacklist in themeunit.pas.
  saveBitBtn.Tag := 9999;
  notificationLabel.Tag := 9999;
  dependenciesLabel.Tag := 9999;
  vkbasaltLabel.Tag := 9999;

  optLabel1.Tag := 9999;
  optLabel2.Tag := 9999;
  fakenvapi1.Tag := 9999;
  fakenvapi2.Tag := 9999;
  fsrLabel1.Tag := 9999;
  xessLabel1.Tag := 9999;
  gupdateBitBtn.Tag := 9999;
  updateBitBtn.Tag := 9999;
  mangohudLabel.Tag := 9999;
  optiscalerLabel.Tag := 9999;
  mangohudShape.Tag := 9999;
  vkbasaltShape.Tag := 9999;
  optiscalerShape.Tag := 9999;
  tweaksLabel.Tag := 9999;
  tweaksShape.Tag := 9999;
  autodetectnvLabel.Tag := 9999;
  autodetectmesaLabel.Tag := 9999;
  topleftRadioButton.Tag := 9999;
  topcenterRadioButton.Tag := 9999;
  toprightRadioButton.Tag := 9999;
  bottomleftRadioButton.Tag := 9999;
  bottomrightRadioButton.Tag := 9999;
  bottomcenterRadioButton.Tag := 9999;
  middleleftRadioButton.Tag := 9999;
  middlerightRadioButton.Tag := 9999;
  patcherlistLabel.Tag := 9999;
  optipatcherLabel1.Tag := 9999;
  dlssLabel1.Tag := 9999;

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
  searchEdit.Visible := False;
  searchEdit.Tag := 9999;
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
  statusBar.Visible := False;
  statusBar.Tag := 9999;
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

  // Initialize Games tab container (games are loaded on FormShow)
  InitGamesTab;
  FGamesLoaded := False;

  // Initialize Visual tab card layout
  InitVisualTab;

  // Initialize Performance tab card layout
  InitPerformanceTab;

  // Initialize Metrics tab card layout
  InitMetricsTab;

  // Initialize OptiScaler tab card layout
  InitOptiScalerTab;

  // Initialize vkBasalt tab modern UI
  InitVkBasaltTab;
  vkbasaltTabSheet.OnShow := @vkbasaltTabSheetShow;

  // Initialize vkSumi tab
  vksumiTabSheet.OnShow := @vkSumiTabSheetShow;
  performanceTabSheet.OnShow := @performanceTabSheetShow;
  visualTabSheet.OnShow := @visualTabSheetShow;
  metricsTabSheet.OnShow := @metricsTabSheetShow;

  // Initialize Extras tab
  InitExtrasTab;

  // Initialize Home tab
  InitHomeTab;

  // Enable keyboard shortcuts
  Self.KeyPreview := True;
  Self.OnKeyDown  := @FormKeyDown;
  Self.OnResize   := @FormResize;
  
  vkbasaltsel := false;


  // Load and apply saved theme
  SavedTheme := LoadThemePreference;
  ApplyTheme(Self, SavedTheme);

  // Restore nav rail dark colors (theme engine overwrites the dynamic panels)
  RestoreNavRailColors;

  // Apply per-control theme overrides for dynamically created controls
  ApplyCustomEnvTheme;

  themeMenuItem.Visible := False;

  // Bring settings button to front to ensure it's visible
  settingsSpeedButton.BringToFront;



  // Disable Protontricks button in Flatpak (requires permissions not approved by Flathub)
  if IsRunningInFlatpak then
  begin
    protontricksManagerButton.Enabled := False;
    protontricksManagerButton.Hint := 'Protontricks integration is not available in the Flatpak version.';
  end;

  // Global Enable button and label are hidden — FGMOD is always used
  geSpeedButton.Visible := False;
  geLabel.Visible       := False;

  // Update geSpeedButton state from fgmod file (kept for internal state tracking)
  UpdateGeSpeedButtonState;

  // Load tweaks tab state from fgmod file
  LoadTweaksFromFGMod;

  Timer.Enabled := False;  // no animated repaint — static glassmorphism
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
  if Assigned(FVkReshadePB) then FVkReshadePB.Invalidate;

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


  // Dependencies are shown in the settings menu; hide sidebar widgets
  dependencieSpeedButton.Visible := False;
  dependenciesLabel.Visible      := False;

  //Check for dependencies
   if CheckDependencies(Missing) then
   begin
    dependencieSpeedbutton.ImageIndex := 0 ; //green icon
    dependenciesLabel.Caption := 'Status' ;
    if Assigned(FDepsMenuItem) then
    begin
      FDepsMenuItem.Caption := 'Status';
      FDepsMenuItem.ImageIndex := 0; // green icon
    end;
   end
  else
  begin
    dependencieSpeedbutton.ImageIndex := 1 ;  //red icon
    dependenciesLabel.Caption := ('Missing: ' + LineEnding + Missing.Text);
    if Assigned(FDepsMenuItem) then
    begin
      FDepsMenuItem.Caption := 'Status';
      FDepsMenuItem.ImageIndex := 1; // red icon
    end;
    
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
      FileLines.Add('toggleKey = ' + vkbtogglekeyCombobox.Text);
      FileLines.Add('enableOnLaunch = True');

      FileLines.SaveToFile(VKBASALTCFGFILE);
    finally
      FileLines.Free;
    end;
  end;

  // Check vkSumi directory with proper XDG and Flatpak support
  VKSUMIFOLDER := IncludeTrailingPathDelimiter(GetVkSumiConfigDir());
  VKSUMICFGFILE := VKSUMIFOLDER + 'vkSumi.conf';

  // make sure directory exists - VKSUMI
  CreateHostDirectory(VKSUMIFOLDER);

  // Check if file exists and create default - VKSUMI
  if not FileExists(VKSUMICFGFILE) then
  begin
    FileLines := TStringList.Create;
    try
      FileLines.Add('################### File Generated by Goverlay ' + GVERSION + ' ' + GCHANNEL + ' ###################');
      FileLines.Add('# vkSumi color grading');
      FileLines.Add('#');
      FileLines.Add('enabled     = true');
      FileLines.Add('toggle_keys = Shift_R+F9    # in-game hotkey, X11 + XWayland (Wine/Proton)');
      FileLines.Add('');
      FileLines.Add('PER_GAME_CONFIG_CREATION = false');
      FileLines.Add('');
      FileLines.Add('# tone');
      FileLines.Add('brightness = 0.0');
      FileLines.Add('contrast   = 0.0');
      FileLines.Add('exposure   = 0.0');
      FileLines.Add('gamma      = 0.0');
      FileLines.Add('');
      FileLines.Add('# color');
      FileLines.Add('saturation = 0.0');
      FileLines.Add('vibrance   = 0.0');
      FileLines.Add('hue_deg    = 0.0');
      FileLines.Add('temperature = 0.0');
      FileLines.Add('tint       = 0.0');
      FileLines.Add('');
      FileLines.Add('# per-channel gain');
      FileLines.Add('red_gain   = 0.0');
      FileLines.Add('green_gain = 0.0');
      FileLines.Add('blue_gain  = 0.0');
      FileLines.Add('');
      FileLines.Add('# 3-band');
      FileLines.Add('shadows    = 0.0');
      FileLines.Add('midtones   = 0.0');
      FileLines.Add('highlights = 0.0');
      FileLines.SaveToFile(VKSUMICFGFILE);
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
     else
     Process.Free;
     saida.Free;
     
     //Select games as initial option
     gamesLabelClick(nil);

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

     // FPS limits — read raw comma-separated value into the edit
     MaxFPS := 0;
     FoundFPSLimit := False;
     FPSValues := '';

     if FileExists(MANGOHUDCFGFILE) then
     begin
       ConfigFile := TStringList.Create;
       try
         ConfigFile.LoadFromFile(MANGOHUDCFGFILE);
         for Line in ConfigFile do
           if StartsText('fps_limit=', Line) then
           begin
             FPSValues := Copy(Line, Pos('=', Line) + 1, Length(Line));
             FoundFPSLimit := True;
             Break;
           end;
       finally
         ConfigFile.Free;
       end;
     end;

     if FoundFPSLimit then
     begin
       if Assigned(FFpsLimitEdit) then
         FFpsLimitEdit.Text := FPSValues;
       // Derive max FPS for colour thresholds
       FPSNumbers := TStringList.Create;
       try
         FPSNumbers.Delimiter := ',';
         FPSNumbers.DelimitedText := FPSValues;
         for i := 0 to FPSNumbers.Count - 1 do
         begin
           FPS := StrToIntDef(FPSNumbers[i], 0);
           if FPS > MaxFPS then
             MaxFPS := FPS;
         end;
       finally
         FPSNumbers.Free;
       end;
     end
     else if Assigned(FFpsLimitEdit) then
       FFpsLimitEdit.Text := '0';

     if MaxFPS = 0 then
       MaxFPS := 60;
     fpscolor3spinedit.Value := MaxFPS;
     fpscolor2spinedit.Value := Round(MaxFPS / 2);



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
    LoadVkSumiConfig;


    // Check NVIDIA module and configure controls
    // On first run auto-detect; afterwards restore the user's last choice.
    autodetectnvLabel.Visible := False;
    autodetectmesaLabel.Visible := False;
    SavedDriver := LoadOptiScalerDriverPreference;
    if SameText(SavedDriver, 'nvidia') then
      nvidiaRadioButton.Checked := True
    else if SameText(SavedDriver, 'mesa') then
      mesaRadioButton.Checked := True
    else
    begin
      // First launch (no preference saved yet): run auto-detection
      if IsNvidiaModuleLoaded then
      begin
        nvidiaRadioButton.Checked := True;
        autodetectnvLabel.Visible := True;
        autodetectnvLabel.Font.Color := clOlive;
      end
      else
      begin
        mesaRadioButton.Checked := True;
        autodetectmesaLabel.Visible := True;
        autodetectmesaLabel.Font.Color := clOlive;
      end;
    end;

    // Load all OptiScaler configs (combines fgmod, fake-nvapi, and OptiScaler.ini settings)
    LoadOptiScalerConfig;

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

    // Populate Home tab and OptiScaler status card after update check
    RefreshHomeOptiStatus;
    RefreshOsStatusDots;

    // Initialize global enable menu item checked state
    globalenableMenuItem.Checked := IsMangoHudGloballyEnabled();
    
    // Initialize globalenableMenuItem visibility based on active tab
    UpdateGlobalEnableMenuItemVisibility;

end; // form create

// ---------------------------------------------------------------------------
// Tweaks grid mapping
// ---------------------------------------------------------------------------
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


function Tgoverlayform.OsHexToKeyStr(const HexStr: string): string;
begin
  Result := optiscaler_tab.OsHexToKeyStr(HexStr);
end;

procedure Tgoverlayform.TweaksCheckChange(Sender: TObject);
begin
  // Listbox reflects the saved fgmod file; updated after Save
end;

procedure Tgoverlayform.UpdateTweaksVarListBox;
var
  FGModFilePath: string;
  FileLines: TStringList;
  i: Integer;
  Line, DisplayLine: string;
  MarkerPos: Integer;
begin
  if not Assigned(FTweaksVarListBox) then Exit;
  FTweaksVarListBox.Items.BeginUpdate;
  try
    FTweaksVarListBox.Items.Clear;
    if FActiveGameName <> '' then
      FGModFilePath := GetGameConfigDir(FActiveGameName) + 'fgmod'
    else
      FGModFilePath := GetFGModPath + PathDelim + 'fgmod';
    if not FileExists(FGModFilePath) then Exit;
    FileLines := TStringList.Create;
    try
      FileLines.LoadFromFile(FGModFilePath);
      for i := 0 to FileLines.Count - 1 do
      begin
        Line := Trim(FileLines[i]);
        if (Copy(Line, 1, 7) = 'export ') or (Line = '#gamemode') then
        begin
          MarkerPos := Pos(' #customenv', Line);
          if MarkerPos > 0 then
            DisplayLine := Copy(Line, 1, MarkerPos - 1)
          else
            DisplayLine := Line;
          FTweaksVarListBox.Items.Add(DisplayLine);
        end;
      end;
    finally
      FileLines.Free;
    end;
  finally
    FTweaksVarListBox.Items.EndUpdate;
  end;
end;

procedure Tgoverlayform.TweaksVarRemoveClick(Sender: TObject);
var
  Selected, CustomVal: string;
  Idx: Integer;
begin
  if not Assigned(FTweaksVarListBox) then Exit;
  if FTweaksVarListBox.ItemIndex < 0 then Exit;
  Selected := FTweaksVarListBox.Items[FTweaksVarListBox.ItemIndex];
  if Copy(Selected, 1, 7) = 'export ' then
    CustomVal := Copy(Selected, 8, MaxInt)
  else
    Exit;
  if not Assigned(FCustomListBox) then Exit;
  Idx := FCustomListBox.Items.IndexOf(CustomVal);
  if Idx >= 0 then
  begin
    FCustomListBox.Items.Delete(Idx);
    // Remove directly from listbox (file not saved yet, can't re-read from it)
    FTweaksVarListBox.Items.Delete(FTweaksVarListBox.ItemIndex);
  end;
end;

// ---------------------------------------------------------------------------
// Tweaks grid event handlers
// ---------------------------------------------------------------------------

procedure Tgoverlayform.TweaksGridPrepareCanvas(sender: TObject; aCol, aRow: Integer; aState: TGridDrawState);
var
  Grid: TStringGrid;
  Cat: string;
begin
  Grid := Sender as TStringGrid;

  // Header styling
  if aRow < Grid.FixedRows then
  begin
    Grid.Canvas.Brush.Color := $00303040;
    Grid.Canvas.Font.Color  := $00CCAAAA;
    Grid.Canvas.Font.Style  := [fsBold];
    Exit;
  end;

  // Zebra + checked-row styling
  if Grid.Cells[0, aRow] = '1' then
  begin
    Grid.Canvas.Brush.Color := $00384858;
    Grid.Canvas.Font.Color  := clWhite;
  end
  else if (aRow - Grid.FixedRows) mod 2 = 1 then
  begin
    Grid.Canvas.Brush.Color := $00282838;
    Grid.Canvas.Font.Color  := $00CCCCCC;
  end
  else
  begin
    Grid.Canvas.Brush.Color := $002E1E1A;
    Grid.Canvas.Font.Color  := $00AAAAAA;
  end;

  // Category colour
  if aCol = 1 then
  begin
    Cat := Grid.Cells[1, aRow];
    if Cat = 'General'    then Grid.Canvas.Font.Color := $00E8E8E8;
    if Cat = 'Graphics'   then Grid.Canvas.Font.Color := $00F0A860;
    if Cat = 'Performance'then Grid.Canvas.Font.Color := $0040D8F0;
    if Cat = 'Custom'     then Grid.Canvas.Font.Color := $00B0B0B0;
  end;

  // Monospace for variable column
  if aCol = 2 then
    Grid.Canvas.Font.Name := 'DejaVu Sans Mono';
end;

procedure Tgoverlayform.TweaksGridDrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
var
  Grid: TStringGrid;
  BoxRect: TRect;
  TxtRect: TRect;
  Txt: string;
const
  BOX_SIZE = 14;
  PAD = 8;
begin
  Grid := Sender as TStringGrid;

  // Checkbox column (0)
  if (aCol = 0) and (aRow >= Grid.FixedRows) then
  begin
    Grid.Canvas.FillRect(aRect);

    BoxRect.Left   := aRect.Left + (Grid.ColWidths[0] - BOX_SIZE) div 2;
    BoxRect.Top    := aRect.Top + (aRect.Height - BOX_SIZE) div 2;
    BoxRect.Right  := BoxRect.Left + BOX_SIZE;
    BoxRect.Bottom := BoxRect.Top + BOX_SIZE;

    Grid.Canvas.Brush.Color := $002E1E1A;
    Grid.Canvas.Pen.Color   := $00AAAAAA;
    Grid.Canvas.Rectangle(BoxRect);

    if Grid.Cells[0, aRow] = '1' then
    begin
      Grid.Canvas.Brush.Color := $00F0BE30; // accent cyan
      Grid.Canvas.Pen.Color   := $00F0BE30;
      InflateRect(BoxRect, -3, -3);
      Grid.Canvas.FillRect(BoxRect);
      // White checkmark
      Grid.Canvas.Font.Name  := 'DejaVu Sans';
      Grid.Canvas.Font.Size  := 8;
      Grid.Canvas.Font.Style := [fsBold];
      Grid.Canvas.Font.Color := clWhite;
      Grid.Canvas.TextOut(BoxRect.Left - 1, BoxRect.Top - 3, '✓');
    end;
    Exit;
  end;

  // Text columns — draw with horizontal padding
  if (aCol > 0) and (aRow >= Grid.FixedRows) then
  begin
    Txt := Grid.Cells[aCol, aRow];
    TxtRect := aRect;
    InflateRect(TxtRect, -PAD, 0);
    Grid.Canvas.FillRect(aRect);
    Grid.Canvas.TextRect(TxtRect, TxtRect.Left, TxtRect.Top + (TxtRect.Height - Grid.Canvas.TextHeight(Txt)) div 2, Txt);
  end;
end;

procedure Tgoverlayform.TweaksGridMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Grid: TStringGrid;
  Col, Row: Integer;
  Chk: TCheckBox;
begin
  Grid := Sender as TStringGrid;
  Grid.MouseToCell(X, Y, Col, Row);
  if (Button <> mbLeft) or (Col <> 0) or (Row < Grid.FixedRows) then Exit;

  // Toggle cell value
  if Grid.Cells[Col, Row] = '1' then
    Grid.Cells[Col, Row] := '0'
  else
    Grid.Cells[Col, Row] := '1';

  // Sync hidden checkbox for predefined rows
  if Row - Grid.FixedRows < TWEAK_ROW_COUNT then
  begin
    Chk := GetTweakRowCheckBox(Self, Row - Grid.FixedRows);
    if Assigned(Chk) then
      Chk.Checked := Grid.Cells[0, Row] = '1';
  end;

  Grid.InvalidateCell(Col, Row);
end;

procedure Tgoverlayform.TweaksGridResize(Sender: TObject);
var
  Grid: TStringGrid;
  UsedW: Integer;
const
  SCROLLBAR_PAD = 4;
begin
  Grid := Sender as TStringGrid;
  UsedW := Grid.ColWidths[0] + Grid.ColWidths[1] + Grid.ColWidths[2] + SCROLLBAR_PAD;
  if Grid.ClientWidth > UsedW then
    Grid.ColWidths[3] := Grid.ClientWidth - UsedW
  else
    Grid.ColWidths[3] := 120; // minimum fallback
end;

procedure Tgoverlayform.SyncTweaksGridFromCheckBoxes;
var
  i: Integer;
  Chk: TCheckBox;
begin
  if Assigned(FTweaksGrid) then
  begin
    for i := 0 to TWEAK_ROW_COUNT - 1 do
    begin
      Chk := GetTweakRowCheckBox(Self, i);
      if Assigned(Chk) then
      begin
        if Chk.Checked then
          FTweaksGrid.Cells[0, i + 1] := '1'
        else
          FTweaksGrid.Cells[0, i + 1] := '0';
        FTweaksGrid.Cells[1, i + 1] := TWEAK_ROWS[i].Category;
        FTweaksGrid.Cells[2, i + 1] := TWEAK_ROWS[i].VarName;
        FTweaksGrid.Cells[3, i + 1] := TWEAK_ROWS[i].Description;
      end;
    end;
  end;
  // Also refresh MD3 view if active
  if Assigned(FTweaksPaintBox) then
    FTweaksPaintBox.Invalidate;
end;

// ============================================================================
// TWEAKS TAB — MD3-style custom painted list
// ============================================================================

function Tgoverlayform.TweaksMD3ItemHeight: Integer;
begin
  Result := 44;
end;

function Tgoverlayform.TweaksMD3HeaderHeight: Integer;
begin
  Result := 36;
end;

procedure Tgoverlayform.InitTweaksMD3;
begin
  TTweaksMD3Helper(FTweaksHelper).InitTweaksMD3;
end;
procedure Tgoverlayform.TweaksMD3FABPaint(Sender: TObject);
begin
  TTweaksMD3Helper(FTweaksHelper).FABPaint(Sender);
end;
procedure Tgoverlayform.TweaksMD3BuildItems;
// Virtual — items are rendered on-the-fly in paint event using checkboxes + custom list
begin
  // No persistent list needed; paint event reads directly from checkboxes + grid custom rows
end;

procedure Tgoverlayform.TweaksMD3Paint(Sender: TObject);
begin
  TTweaksMD3Helper(FTweaksHelper).Paint(Sender);
end;
procedure Tgoverlayform.TweaksMD3MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  TTweaksMD3Helper(FTweaksHelper).MouseMove(Sender, Shift, X, Y);
end;
procedure Tgoverlayform.TweaksMD3MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  TTweaksMD3Helper(FTweaksHelper).MouseDown(Sender, Button, Shift, X, Y);
end;
procedure Tgoverlayform.TweaksMD3MouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  TTweaksMD3Helper(FTweaksHelper).MouseWheel(Sender, Shift, WheelDelta, MousePos, Handled);
end;
procedure Tgoverlayform.TweaksMD3ScrollChange(Sender: TObject);
begin
  TTweaksMD3Helper(FTweaksHelper).ScrollChange(Sender);
end;
procedure Tgoverlayform.TweaksMD3ToggleItem(Index: Integer);
begin
  // Not used directly — mouse down handles toggling via checkbox
end;

procedure Tgoverlayform.TweaksMD3FABClick(Sender: TObject);
begin
  TTweaksMD3Helper(FTweaksHelper).FABClick(Sender);
end;
procedure Tgoverlayform.ApplyImageAntialiasing;
  procedure ScanImages(AParent: TWinControl);
  var
    i: Integer;
    C: TControl;
  begin
    for i := 0 to AParent.ControlCount - 1 do
    begin
      C := AParent.Controls[i];
      if C is TImage then
      begin
        TImage(C).AntialiasingMode := amOn;
        TImage(C).Invalidate;
      end
      else if C is TWinControl then
        ScanImages(TWinControl(C));
    end;
  end;
begin
  ScanImages(Self);
end;

procedure Tgoverlayform.StartCube;
begin
  if not FCubeAutoLaunch then Exit;
  StopCube; // Prevent duplicates

  if IsRunningInFlatpak then
  begin
      // FLATPAK MODE
      if IsCommandAvailable('pascube') then
         ExecuteGUICommand(GetMangoHudConfigEnvPrefix + 'MANGOHUD=1 pascube &')
      else if IsCommandAvailable('vkcube') then
      begin
         SendNotification('Goverlay', 'PasCube was not located, using vkcube instead', GetIconFile);
         if (USERSESSION = 'wayland') and IsCommandAvailable('vkcube-wayland') then
            ExecuteGUICommand(GetMangoHudConfigEnvPrefix + 'MANGOHUD=1 vkcube-wayland &')
         else
            ExecuteGUICommand(GetMangoHudConfigEnvPrefix + 'MANGOHUD=1 vkcube &');
      end
      else
         SendNotification('Goverlay', 'PasCube and VkCube were not located.', GetIconFile);
  end
  else
  begin
      // NATIVE MODE
      if IsCommandAvailable('pascube') then
         ExecuteGUICommand(GetMangoHudConfigEnvPrefix + 'MANGOHUD=1 pascube &')
      else if IsCommandAvailable('vkcube') then
      begin
        SendNotification('Goverlay', 'PasCube was not located, using vkcube instead', GetIconFile);
        if USERSESSION = 'wayland' then
          ExecuteGUICommand(GetMangoHudConfigEnvPrefix + 'MANGOHUD=1 vkcube --wsi wayland &')
        else
          ExecuteGUICommand(GetMangoHudConfigEnvPrefix + 'mangohud vkcube &');
      end
      else
         SendNotification('Goverlay', 'PasCube and VkCube were not located.', GetIconFile);
  end;
end;

procedure Tgoverlayform.StopCube;
var
  Proc: TProcess;
begin
  // Kill cube processes without the 200ms GUI-wait sleep used by ExecuteGUICommand
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FindDefaultExecutablePath('sh');
    Proc.Parameters.Add('-c');
    Proc.Parameters.Add('killall pascube vkcube vkcube-wayland 2>/dev/null; true');
    Proc.Options := [poNoConsole];
    Proc.Execute;
  finally
    Proc.Free;
  end;
end;


procedure Tgoverlayform.FormShow(Sender: TObject);
var
  InitW: Integer;
  TabSS: WideString;
  TabWidget: QWidgetH;
  TabBar: QTabBarH;
  PanelWidget: QWidgetH;
begin
  // Load Steam games grid once, after the form has its final dimensions
  if not FGamesLoaded then
  begin
    FGamesLoaded := True;
    LoadSteamGames;
  end;

  // Initial reflow now that the form has real dimensions
  InitW := Max(1, Self.ClientWidth - goverlayPaintBox.Width);
  ReflowPresetTab(InitW);
  ReflowVisualTab(InitW);
  ReflowPerformanceTab(InitW);
  ReflowMetricsTab(InitW);
  ReflowExtrasTab(InitW);
  ReflowOptiScalerTab(InitW);
  ReflowOptiScalerTabNew(InitW);
  ReflowVkBasaltTab(InitW);
  ReflowVkSumiTab(InitW);

  // Enable smooth rendering for all TImage controls
  ApplyImageAntialiasing;

  // Remove goverlayPanel QFrame border (Qt6 ignores LCL BorderStyle := bsNone at runtime)
  PanelWidget := TQtWidget(goverlayPanel.Handle).Widget;
  QFrame_setFrameStyle(QFrameH(PanelWidget), 0);  // QFrame::NoFrame = 0

  // Style tab bar to match navy UI
  TabWidget := TQtWidget(goverlayPageControl.Handle).Widget;
  TabSS := 'QTabBar { background: rgb(22,26,40); } ' +
            'QTabBar::tab { background: rgb(22,26,40); color: rgb(130,140,165); ' +
            'padding: 8px 16px; border: none; ' +
            'border-bottom: 2px solid transparent; ' +
            'font-size: 12px; font-weight: bold; } ' +
            'QTabBar::tab:selected { color: rgb(220,230,255); border-bottom: 2px solid rgb(48,190,240); } ' +
            'QTabBar::tab:hover:!selected { background: rgb(30,36,58); color: rgb(180,192,215); } ' +
            'QTabWidget::pane { border: none; background: rgb(22,26,40); }';
  QWidget_setStyleSheet(TabWidget, @TabSS);

  // Make tabs stretch to fill the full tab bar width (eliminates gray strip to the right)
  TabBar := QTabWidget_tabBar(QTabWidgetH(TabWidget));
  QTabBar_setExpanding(TabBar, True);

  // Start pascube or vkcube (vulkan demo) is now moved to SetNavActive (MangoHud tab)
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
  // Obsolete: global enable button is no longer used
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
begin
  // Obsolete: global enable button is no longer used
end;

procedure Tgoverlayform.UpdateGlobalEnableMenuItemVisibility;
var
  IsMangoHudTab: Boolean;
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
end;


procedure Tgoverlayform.ApplyCustomEnvTheme;
var
  i: Integer;
begin
  if not Assigned(FCustomListBox) then Exit;
  if CurrentTheme = tmLight then
    FCustomListBox.Color := $00D8D8D8   // light gray for light theme
  else
    FCustomListBox.Color := clDefault;  // revert to system default for dark theme

  // Update Visual tab card colors for the new theme
  UpdateVisualCardTheme;

  // Update Performance tab card colors for the new theme
  UpdatePerfCardTheme;

  // Update Extras tab card colors
  UpdateExtrasCardTheme;

  // Update Metrics tab cards
  UpdateGenericCardTheme(FMtGpuCard);
  UpdateGenericCardTheme(FMtCpuCard);

  // Update OptiScaler tab cards
  UpdateGenericCardTheme(FOsGpuCard);
  UpdateGenericCardTheme(FOsOptionsCard);
  UpdateGenericCardTheme(FOsStatusCard);

  // Update vkBasalt tab cards
  UpdateGenericCardTheme(FVkReshadeCard);
  UpdateGenericCardTheme(FVkBuiltinCard);
  UpdateGenericCardTheme(FVkToggleCard);

  // Update vkSumi tab cards
  for i := 0 to 2 do
    UpdateGenericCardTheme(FVsCards[i]);

  // Update vkSumi tab background and scrollbox colors
  if Assigned(vksumiTabSheet) then
  begin
    if CurrentTheme = tmLight then
      vksumiTabSheet.Color := $00F0F0F0
    else
      vksumiTabSheet.Color := RGBToColor(22, 25, 37);
  end;

  if Assigned(FVsScrollBox) then
  begin
    if CurrentTheme = tmLight then
      FVsScrollBox.Color := $00F0F0F0
    else
      FVsScrollBox.Color := RGBToColor(22, 25, 37);
  end;

  if Assigned(FVsBgPanel) then
  begin
    if CurrentTheme = tmLight then
      FVsBgPanel.Color := $00F0F0F0
    else
      FVsBgPanel.Color := RGBToColor(22, 25, 37);
    FVsBgPanel.Invalidate;
  end;

  // Invalidate painted backgrounds so custom paint handlers repaint with new theme
  if Assigned(FPresetsBgBox)      then FPresetsBgBox.Invalidate;
  if Assigned(FPresetsWrapper)    then FPresetsWrapper.Invalidate;
  if Assigned(FExtBgPanel)        then FExtBgPanel.Invalidate;
  if Assigned(FOsBgPanel)         then FOsBgPanel.Invalidate;
  if Assigned(FMtBgPanel)         then FMtBgPanel.Invalidate;
  if Assigned(FGamesPanel)        then FGamesPanel.Invalidate;
  if Assigned(goverlayPaintBox)   then goverlayPaintBox.Invalidate;
  if Assigned(goverlayPanel)      then goverlayPanel.Invalidate;
  if Assigned(goverlaybarPanel)   then goverlaybarPanel.Invalidate;
  // Invalidate all TTabSheets to repaint BgBox children
  for i := 0 to goverlayPageControl.PageCount - 1 do
    goverlayPageControl.Pages[i].Invalidate;
end;

procedure Tgoverlayform.InitCustomEnvGroupBox;
begin
  // Bottom bar and its child controls are no longer visible —
  // custom vars are managed inside the grid via a floating "+" button.
  // Only create the hidden legacy listbox for minimal compatibility.
  FCustomListBox := TListBox.Create(Self);
  FCustomListBox.Parent  := Self;
  FCustomListBox.Visible := False;
end;

procedure Tgoverlayform.CustomEnvAddClick(Sender: TObject);
var
  Val: string;
  Row: Integer;
begin
  Val := Trim(InputBox('Custom Environment Variable',
                       'Enter the variable (e.g. MY_VAR=1):', ''));
  if Val = '' then Exit;

  // Add as a new row in the grid (after predefined rows)
  if Assigned(FTweaksGrid) then
  begin
    Row := FTweaksGrid.RowCount;
    FTweaksGrid.RowCount := Row + 1;
    FTweaksGrid.Cells[0, Row] := '1';         // checked by default
    FTweaksGrid.Cells[1, Row] := 'Custom';
    FTweaksGrid.Cells[2, Row] := Val;
    FTweaksGrid.Cells[3, Row] := '';
  end;
end;

procedure Tgoverlayform.CustomEnvRemoveClick(Sender: TObject);
var
  Row: Integer;
begin
  if not Assigned(FTweaksGrid) then Exit;
  Row := FTweaksGrid.Row;
  // Only allow deleting custom rows (below predefined)
  if Row > TWEAK_ROW_COUNT then
  begin
    FTweaksGrid.DeleteRow(Row);
    // Keep row selection valid
    if FTweaksGrid.RowCount > 1 then
      FTweaksGrid.Row := FTweaksGrid.RowCount - 1;
  end;
end;

procedure Tgoverlayform.LoadTweaksFromFGMod;
var
  ConfigPath: string;
  Ini: TIniFile;
  EnvList: TStringList;
  i, Row: Integer;
  Key, Val: string;
begin
  // Get bgmod config path
  if FActiveGameName <> '' then
    ConfigPath := GetGameConfigDir(FActiveGameName) + 'bgmod.conf'
  else
    ConfigPath := GetFGModPath + PathDelim + 'bgmod.conf';

  // Check if bgmod.conf exists
  if not FileExists(ConfigPath) then
    Exit;

  Ini := TIniFile.Create(ConfigPath);
  EnvList := TStringList.Create;
  try
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
    FAntilagCheckBox.Checked := False;
    FFSR4UpgradeCheckBox.Checked := False;
    FDLSSUpgradeCheckBox.Checked := False;
    FXeSSUpgradeCheckBox.Checked := False;
    FReEngineRTCheckBox.Checked := False;
    FLowLatencyCheckBox.Checked := False;
    FLowLatencyReflexCheckBox.Checked := False;
    FLowLatencySpoofNvidiaCheckBox.Checked := False;
    FLowLatencyHideAmdGpuCheckBox.Checked := False;

    // Reset custom env list
    customenvEdit.Text := '';
    FCustomListBox.Items.Clear;

    // Reset grid to predefined rows only (discard previous custom rows)
    if Assigned(FTweaksGrid) then
      FTweaksGrid.RowCount := 1 + TWEAK_ROW_COUNT;

    // Load gamemode state from Config
    GetGeneralCheckBox(1).Checked := Ini.ReadString('Config', 'gamemode', '0') = '1';

    // Load winedetectionenable state from Config
    FReEngineRTCheckBox.Checked := Ini.ReadString('Config', 'winedetectionenable', '1') = '0';

    // Load environment variables from Env section
    Ini.ReadSectionValues('Env', EnvList);
    for i := 0 to EnvList.Count - 1 do
    begin
      Key := EnvList.Names[i];
      Val := EnvList.ValueFromIndex[i];

      // Handle predefined keys
      if SameText(Key, 'SteamDeck') then
        GetGeneralCheckBox(0).Checked := Val = '1'
      else if SameText(Key, 'PROTON_ENABLE_HDR') then
        GetGeneralCheckBox(2).Checked := Val = '1'
      else if SameText(Key, 'PROTON_ENABLE_WAYLAND') then
        GetGeneralCheckBox(3).Checked := Val = '1'
      else if SameText(Key, 'PROTON_LOG') then
        GetGeneralCheckBox(4).Checked := Val = '1'
      else if SameText(Key, 'PROTON_USE_SDL') then
        GetGeneralCheckBox(5).Checked := Val = '1'
      else if SameText(Key, 'RADV_PERFTEST') and (Pos('rt', Val) > 0) then
        GetGraphicsCheckBox(0).Checked := True
      else if SameText(Key, 'PROTON_HIDE_NVIDIA_GPU') then
        GetGraphicsCheckBox(1).Checked := Val = '1'
      else if SameText(Key, 'PROTON_ENABLE_NVAPI') then
        GetGraphicsCheckBox(2).Checked := Val = '1'
      else if SameText(Key, 'PROTON_USE_WINED3D') then
        GetGraphicsCheckBox(3).Checked := Val = '1'
      else if SameText(Key, 'MESA_LOADER_DRIVER_OVERRIDE') and SameText(Val, 'zink') then
        GetGraphicsCheckBox(4).Checked := True
      else if SameText(Key, 'PROTON_FSR4_UPGRADE') then
        FFSR4UpgradeCheckBox.Checked := Val = '1'
      else if SameText(Key, 'PROTON_DLSS_UPGRADE') then
        FDLSSUpgradeCheckBox.Checked := Val = '1'
      else if SameText(Key, 'PROTON_XESS_UPGRADE') then
        FXeSSUpgradeCheckBox.Checked := Val = '1'
      else if SameText(Key, 'PROTON_PRIORITY_HIGH') then
        GetPerformanceCheckBox(0).Checked := Val = '1'
      else if SameText(Key, 'PROTON_USE_WOW64') then
        GetPerformanceCheckBox(1).Checked := Val = '1'
      else if SameText(Key, 'PROTON_FORCE_LARGE_ADDRESS_AWARE') then
        GetPerformanceCheckBox(2).Checked := Val = '1'
      else if SameText(Key, 'STAGING_SHARED_MEMORY') then
        GetPerformanceCheckBox(3).Checked := Val = '1'
      else if SameText(Key, 'PROTON_NO_NTSYNC') then
        GetPerformanceCheckBox(4).Checked := Val = '1'
      else if SameText(Key, 'PROTON_HEAP_DELAY_FREE') then
        GetPerformanceCheckBox(5).Checked := Val = '1'
      else if SameText(Key, 'ENABLE_LAYER_MESA_ANTI_LAG') then
        FAntilagCheckBox.Checked := Val = '1'
      else if SameText(Key, 'RADV_DEBUG') and SameText(Val, 'nofastclears') then
        nofastclearsCheckBox.Checked := True
      else if SameText(Key, 'LOW_LATENCY_LAYER') then
        FLowLatencyCheckBox.Checked := Val = '1'
      else if SameText(Key, 'LOW_LATENCY_LAYER_REFLEX') then
        FLowLatencyReflexCheckBox.Checked := Val = '1'
      else if SameText(Key, 'LOW_LATENCY_LAYER_SPOOF_NVIDIA') then
        FLowLatencySpoofNvidiaCheckBox.Checked := Val = '1'
      else if SameText(Key, 'DXVK_CONFIG') and (Pos('hideAmdGpu', Val) > 0) then
        FLowLatencyHideAmdGpuCheckBox.Checked := True
      else if not SameText(Key, 'ENABLE_HDR_WSI') and not SameText(Key, '__GLX_VENDOR_LIBRARY_NAME') then
      begin
        // Treat as custom environment variable
        FCustomListBox.Items.Add(Key + '=' + Val);
        if Assigned(FTweaksGrid) then
        begin
          Row := FTweaksGrid.RowCount;
          FTweaksGrid.RowCount := Row + 1;
          FTweaksGrid.Cells[0, Row] := '1';
          FTweaksGrid.Cells[1, Row] := 'Custom';
          FTweaksGrid.Cells[2, Row] := Key + '=' + Val;
          FTweaksGrid.Cells[3, Row] := '';
        end;
      end;
    end;
  finally
    EnvList.Free;
    Ini.Free;
  end;
  SyncTweaksGridFromCheckBoxes;
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

procedure Tgoverlayform.gamesLabelClick(Sender: TObject);
var
  WasInGameMode: Boolean;
begin
  WasInGameMode := FActiveGameName <> '';

  // Clicking the logo always returns to global config mode
  if WasInGameMode then
  begin
    FActiveGameName := '';
    MANGOHUDCFGFILE := IncludeTrailingPathDelimiter(GetMangoHudConfigDir()) + 'MangoHud.conf';
    VKBASALTCFGFILE := IncludeTrailingPathDelimiter(GetVkBasaltConfigDir()) + 'vkBasalt.conf';
    VKSUMICFGFILE := IncludeTrailingPathDelimiter(GetVkSumiConfigDir()) + 'vkSumi.conf';
    UpdateGameContextLabel;
    HideGameThumb;
    LoadGameToggleStates;  // reset all tools to enabled, hide toggles
    SetSaveBtnEnabled(True);
  end;

  SetNavActive(0);

  //Disable tabs
  goverlayPageControl.ShowTabs:=false;
  vkbasalttabsheet.TabVisible:=false;
  vksumiTabSheet.TabVisible:=false;
  optiscalertabsheet.TabVisible:=false;
  tweakstabsheet.TabVisible:=false;

  gamesTabSheet.TabVisible:=true;
  goverlayPageControl.ActivePage:=gamesTabSheet;

  // Only rebuild cards when returning from game config — badges may have changed.
  // Skipped on startup calls (FGamesLoaded=False) and when just re-entering the
  // games tab from global mode (no per-game config was touched).
  if WasInGameMode and FGamesLoaded then
    RefreshGameCards;

  //Hide notification messages
  notificationLabel.Visible:=false;
  commandPanel.Visible:=false;


  //Hide Global Enable controls and bottom bar for games tab
  goverlaybarPanel.Visible:=false;
end;

procedure Tgoverlayform.mangohudLabelClick(Sender: TObject);
var
  GameCfgDir: string;
begin
  DbgLog('>> mangohudLabelClick BEGIN');

  // In game mode, point MangoHud config to the game-specific folder
  if FActiveGameName <> '' then
  begin
    GameCfgDir := GetGameConfigDir(FActiveGameName);
    if not DirectoryExists(GameCfgDir) then
      ForceDirectories(GameCfgDir);
    MANGOHUDCFGFILE := GameCfgDir + 'MangoHud.conf';
  end;

  SetNavActive(1);

//Enable goverlay tabs
goverlayPageControl.ShowTabs:=true;
presetTabSheet.TabVisible:=true;
visualTabSheet.TabVisible:=true;
performanceTabSheet.TabVisible:=true;
metricsTabSheet.TabVisible:=true;
extrasTabSheet.TabVisible:=true;

vkbasalttabsheet.TabVisible:=false; //disable vkbasalt tab
vksumiTabSheet.TabVisible:=false;   //disable vksumi tab
optiscalertabsheet.TabVisible:=false; //disable optiscaler tab
tweakstabsheet.TabVisible:=false;  //disable tweaks tab
gamesTabSheet.TabVisible:=false; //disable games tab
FHomeTabSheet.TabVisible:=false; //hide home tab when switching to mangohud

goverlayPageControl.ActivePage:=presetTabsheet;

//Hide notification messages
notificationLabel.Visible:=false;
commandPanel.Visible:=false;


//Show Global Enable controls and bottom bar for MangoHud tabs


goverlaybarPanel.Visible:=true;
popupBitBtn.Visible := True;
FPreviewBtn.Visible  := True;
UpdateGeSpeedButtonState;
UpdateGlobalEnableMenuItemVisibility;

// Reload config when entering the MangoHud tab (global or game-specific)
if FActiveGameName <> '' then
  LoadMangoHudConfig;
// Re-apply per-game tool enabled state (overrides UpdateGeSpeedButtonState if tool is disabled)
if FActiveGameName <> '' then
begin
  ApplyToolEnabledState(0, FNavToolEnabled[0]);
  SetSaveBtnEnabled(FNavToolEnabled[0]);
end;

DbgLog('<< mangohudLabelClick END');
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
      SaveOptiScalerDriverPreference('mesa');
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
      SaveOptiScalerDriverPreference('nvidia');
end;


procedure Tgoverlayform.optiscalerLabelClick(Sender: TObject);
begin
  DbgLog('>> optiscalerLabelClick BEGIN');
  SetNavActive(3);

//Disable tabs
  goverlayPageControl.ShowTabs:=false;
  vkbasalttabsheet.TabVisible:=false;
  vksumiTabSheet.TabVisible:=false;
  tweakstabsheet.TabVisible:=false;
  gamesTabSheet.TabVisible:=false; //disable games tab

  optiscalertabsheet.TabVisible:=true;
  goverlayPageControl.ActivePage:= optiscalerTabsheet;

  //Hide notification messages
  notificationLabel.Visible:=false;
  commandPanel.Visible:=false;


  //Restore bottom bar
  goverlaybarPanel.Visible:=true;
  popupBitBtn.Visible := False;
  FPreviewBtn.Visible  := False;
  //Update geSpeedButton state for OptiScaler
  UpdateGeSpeedButtonState;
  UpdateGlobalEnableMenuItemVisibility;
  // Re-apply per-game tool enabled state (overrides UpdateGeSpeedButtonState if tool is disabled)
  if FActiveGameName <> '' then
  begin
    ApplyToolEnabledState(2, FNavToolEnabled[2]);
    SetSaveBtnEnabled(FNavToolEnabled[2]);
  end;
  // Reload all OptiScaler configs (combines fgmod, fake-nvapi, and OptiScaler.ini settings)
  LoadOptiScalerConfig;
  // Sync emufp8CheckBox enabled state with the current fsrversionComboBox selection
  fsrversionComboBoxChange(nil);
  DbgLog('<< optiscalerLabelClick END');
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
    if FAutoDownloadingReshade then
      FReshadePhaseLabel.Caption := Format('Downloading reshade shaders: %d%%', [APercent])
    else if APhase <> '' then
      FReshadePhaseLabel.Caption := Format('%s: %d%%', [APhase, APercent])
    else
      FReshadePhaseLabel.Caption := Format('%d%%', [APercent]);
  end;

  Application.ProcessMessages;
end;

procedure Tgoverlayform.reshaderefreshBitBtnClick(Sender: TObject);
begin
  TVkBasaltTabHelper(FBasaltHelper).reshaderefreshBitBtnClick(Sender);
end;

procedure Tgoverlayform.runpascubetItemClick(Sender: TObject);
begin


  if IsCommandAvailable('pascube') then
    ExecuteGUICommand(GetMangoHudLaunchEnv + GetVkBasaltLaunchEnv + GetVkSumiLaunchEnv + 'pascube &')
  else
    SendNotification('Goverlay', 'PasCube not located.', GetIconFile);

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
      // No poUsePipes: we only need ExitStatus, and unread stdout/stderr
      // can deadlock the child if the pipe buffer fills up.
      Process.Options := [poWaitOnExit];
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
    if (USERSESSION = 'wayland') and IsCommandAvailable('vkcube-wayland') then
      ExecuteGUICommand(GetMangoHudLaunchEnv + GetVkBasaltLaunchEnv + GetVkSumiLaunchEnv + 'vkcube-wayland &')
    else
      ExecuteGUICommand(GetMangoHudLaunchEnv + GetVkBasaltLaunchEnv + GetVkSumiLaunchEnv + 'vkcube &');
  end
  else
  begin
    if USERSESSION = 'wayland' then
      ExecuteGUICommand(GetMangoHudLaunchEnv + GetVkBasaltLaunchEnv + GetVkSumiLaunchEnv + 'vkcube &')
    else
      ExecuteGUICommand(GetMangoHudLaunchEnv + GetVkBasaltLaunchEnv + GetVkSumiLaunchEnv + 'vkcube &');
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
  if Assigned(FVkCasValLbl) then FVkCasValLbl.Caption := casvaluelabel.Caption;
end;

procedure Tgoverlayform.delayTrackBarChange(Sender: TObject);
begin
    //Display new values and trackbar changes
  delayvalueLabel.Caption:= FormatFloat('#0', delayTrackbar.Position)+ 's';
end;

procedure Tgoverlayform.dlsTrackBarChange(Sender: TObject);
begin
  dlsvaluelabel.Caption := inttostr(dlsTrackbar.Position);
  if Assigned(FVkDlsValLbl) then FVkDlsValLbl.Caption := dlsvaluelabel.Caption;
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
  if Assigned(FVkFxaaValLbl) then FVkFxaaValLbl.Caption := fxaavaluelabel.Caption;
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
    ramColorButton.ButtonColor := $00ff5500; // Change color for RAM button
    frametimegraphColorButton.ButtonColor := $00ff5500; // Change color for Frame Time Graph
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
  // and refresh the status dots so any new version tag is shown immediately.
  if Assigned(FOptiscalerUpdate) then
  begin
    FOptiscalerUpdate.CheckForUpdatesOnClick;
    RefreshOsStatusDots;
  end;
end;

procedure Tgoverlayform.fsrversionComboBoxChange(Sender: TObject);
begin
  // Disable emufp8CheckBox when "4.0.2c (INT8)" is selected (ItemIndex = 1)
  // Enable emufp8CheckBox when "Latest (FP8)" is selected (ItemIndex = 0)
  case fsrversionComboBox.ItemIndex of
    0: // Latest (FP8)
      begin
        emufp8CheckBox.Enabled := True;
      end;
    1: // 4.0.2c (INT8)
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
  if (goverlayPageControl.ActivePage = vkbasaltTabSheet) or
     (goverlayPageControl.ActivePage = vksumiTabSheet) then
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
  end
  else if (goverlayPageControl.ActivePage = optiscalerTabSheet) or
          (goverlayPageControl.ActivePage = tweaksTabSheet) then
  begin
    // OptiScaler and Tweaks tabs: show only global enable
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
  end;

  popsaveMenu.PopUp;
end;


procedure Tgoverlayform.SaveTweaksConfig;
var
  LaunchCommand: string;
  ConfigPath: string;
  Ini: TIniFile;
  i: Integer;
  HasTweaks: Boolean;
  DSpirvVal: string;
  CustomLine: string;
  CustomKey, CustomVal: string;
  p: Integer;
begin
  // Check if any tweaks are active
  HasTweaks := GetGeneralCheckBox(0).Checked or GetGeneralCheckBox(1).Checked or
               GetGeneralCheckBox(2).Checked or GetGeneralCheckBox(3).Checked or
               GetGeneralCheckBox(4).Checked or GetGeneralCheckBox(5).Checked or
               GetGraphicsCheckBox(0).Checked or GetGraphicsCheckBox(1).Checked or
               GetGraphicsCheckBox(2).Checked or GetGraphicsCheckBox(3).Checked or
               GetGraphicsCheckBox(4).Checked or
               nofastclearsCheckBox.Checked or
               GetPerformanceCheckBox(0).Checked or GetPerformanceCheckBox(1).Checked or
               GetPerformanceCheckBox(2).Checked or GetPerformanceCheckBox(3).Checked or
               GetPerformanceCheckBox(4).Checked or GetPerformanceCheckBox(5).Checked or
               FAntilagCheckBox.Checked or
               FLowLatencyCheckBox.Checked or
               FLowLatencyReflexCheckBox.Checked or
               FLowLatencySpoofNvidiaCheckBox.Checked or
               FLowLatencyHideAmdGpuCheckBox.Checked or
               FFSR4UpgradeCheckBox.Checked or
               FDLSSUpgradeCheckBox.Checked or
               FXeSSUpgradeCheckBox.Checked or
               FReEngineRTCheckBox.Checked or
               (Assigned(FTweaksGrid) and (FTweaksGrid.RowCount > 1 + TWEAK_ROW_COUNT));

  // Determine the bgmod.conf path
  if FActiveGameName <> '' then
    ConfigPath := GetGameConfigDir(FActiveGameName) + 'bgmod.conf'
  else
    ConfigPath := GetFGModPath + PathDelim + 'bgmod.conf';

  ForceDirectories(ExtractFilePath(ConfigPath));
  Ini := TIniFile.Create(ConfigPath);
  try
    // 1. Write Config section
    Ini.WriteString('Config', 'GOVERLAY_TWEAKS', '1');
    if GetGeneralCheckBox(1).Checked then
      Ini.WriteString('Config', 'gamemode', '1')
    else
      Ini.WriteString('Config', 'gamemode', '0');

    if FReEngineRTCheckBox.Checked then
      Ini.WriteString('Config', 'winedetectionenable', '0')
    else
      Ini.WriteString('Config', 'winedetectionenable', '1');

    // 2. Erase Env section but preserve DXIL_SPIRV_CONFIG
    DSpirvVal := Ini.ReadString('Env', 'DXIL_SPIRV_CONFIG', '');
    Ini.EraseSection('Env');
    if DSpirvVal <> '' then
      Ini.WriteString('Env', 'DXIL_SPIRV_CONFIG', DSpirvVal);

    // 3. Write active tweaks to Env
    if GetGeneralCheckBox(0).Checked then
      Ini.WriteString('Env', 'SteamDeck', '1');

    if GetGeneralCheckBox(2).Checked then
    begin
      Ini.WriteString('Env', 'PROTON_ENABLE_HDR', '1');
      Ini.WriteString('Env', 'ENABLE_HDR_WSI', '1');
    end;

    if GetGeneralCheckBox(3).Checked then
      Ini.WriteString('Env', 'PROTON_ENABLE_WAYLAND', '1');

    if GetGeneralCheckBox(4).Checked then
      Ini.WriteString('Env', 'PROTON_LOG', '1');

    if GetGeneralCheckBox(5).Checked then
      Ini.WriteString('Env', 'PROTON_USE_SDL', '1');

    if GetGraphicsCheckBox(0).Checked then
      Ini.WriteString('Env', 'RADV_PERFTEST', 'rt,emulate_rt');

    if GetGraphicsCheckBox(1).Checked then
      Ini.WriteString('Env', 'PROTON_HIDE_NVIDIA_GPU', '1');

    if GetGraphicsCheckBox(2).Checked then
      Ini.WriteString('Env', 'PROTON_ENABLE_NVAPI', '1');

    if GetGraphicsCheckBox(3).Checked then
      Ini.WriteString('Env', 'PROTON_USE_WINED3D', '1');

    if GetGraphicsCheckBox(4).Checked then
    begin
      Ini.WriteString('Env', 'MESA_LOADER_DRIVER_OVERRIDE', 'zink');
      if IsNvidiaModuleLoaded then
        Ini.WriteString('Env', '__GLX_VENDOR_LIBRARY_NAME', 'mesa');
    end;

    if nofastclearsCheckBox.Checked then
      Ini.WriteString('Env', 'RADV_DEBUG', 'nofastclears');

    if FFSR4UpgradeCheckBox.Checked then
      Ini.WriteString('Env', 'PROTON_FSR4_UPGRADE', '1');

    if FDLSSUpgradeCheckBox.Checked then
      Ini.WriteString('Env', 'PROTON_DLSS_UPGRADE', '1');

    if FXeSSUpgradeCheckBox.Checked then
      Ini.WriteString('Env', 'PROTON_XESS_UPGRADE', '1');

    if GetPerformanceCheckBox(0).Checked then
      Ini.WriteString('Env', 'PROTON_PRIORITY_HIGH', '1');

    if GetPerformanceCheckBox(1).Checked then
      Ini.WriteString('Env', 'PROTON_USE_WOW64', '1');

    if GetPerformanceCheckBox(2).Checked then
      Ini.WriteString('Env', 'PROTON_FORCE_LARGE_ADDRESS_AWARE', '1');

    if GetPerformanceCheckBox(3).Checked then
      Ini.WriteString('Env', 'STAGING_SHARED_MEMORY', '1');

    if GetPerformanceCheckBox(4).Checked then
      Ini.WriteString('Env', 'PROTON_NO_NTSYNC', '1');

    if GetPerformanceCheckBox(5).Checked then
      Ini.WriteString('Env', 'PROTON_HEAP_DELAY_FREE', '1');

    if FAntilagCheckBox.Checked then
      Ini.WriteString('Env', 'ENABLE_LAYER_MESA_ANTI_LAG', '1');

    if FLowLatencyCheckBox.Checked then
      Ini.WriteString('Env', 'LOW_LATENCY_LAYER', '1');

    if FLowLatencyReflexCheckBox.Checked then
      Ini.WriteString('Env', 'LOW_LATENCY_LAYER_REFLEX', '1');

    if FLowLatencySpoofNvidiaCheckBox.Checked then
      Ini.WriteString('Env', 'LOW_LATENCY_LAYER_SPOOF_NVIDIA', '1');

    if FLowLatencyHideAmdGpuCheckBox.Checked then
      Ini.WriteString('Env', 'DXVK_CONFIG', 'dxgi.customDeviceDescription=10de:2204,dxgi.hideAmdGpu=True');

    // 4. Custom environment variables from grid
    if Assigned(FTweaksGrid) then
    begin
      for i := 1 + TWEAK_ROW_COUNT to FTweaksGrid.RowCount - 1 do
      begin
        if (FTweaksGrid.Cells[0, i] = '1') and (Trim(FTweaksGrid.Cells[2, i]) <> '') then
        begin
          CustomLine := Trim(FTweaksGrid.Cells[2, i]);
          p := Pos('#customenv', CustomLine);
          if p > 0 then
            CustomLine := Trim(Copy(CustomLine, 1, p - 1));
          p := Pos('=', CustomLine);
          if p > 0 then
          begin
            CustomKey := Trim(Copy(CustomLine, 1, p - 1));
            CustomVal := Trim(Copy(CustomLine, p + 1, MaxInt));
            Ini.WriteString('Env', CustomKey, CustomVal);
          end;
        end;
      end;
    end;

    // Refresh grid to reflect saved state
    SyncTweaksGridFromCheckBoxes;

    // Show notification
    SendNotification('Tweaks', 'Configuration saved', GetIconFile);

  finally
    Ini.Free;
  end;

  // Build the Launch Command to display/use
  if FActiveGameName <> '' then
  begin
    if FActiveGameIsNonSteam then
      LaunchCommand := GetGameConfigDir(FActiveGameName) + 'bgmod '
    else
      LaunchCommand := '"' + GetGameConfigDir(FActiveGameName) + 'bgmod" ';
  end
  else
    LaunchCommand := '"' + GetFGModPath + '/bgmod" ';

  // Check if gamemode should be added
  if GetGeneralCheckBox(1).Checked then
    LaunchCommand := LaunchCommand + ENV_GAMEMODERUN + ' ';

  // Always end with %command%
  if not ( (FActiveGameName <> '') and FActiveGameIsNonSteam ) then
    LaunchCommand := LaunchCommand + LAUNCH_COMMAND_SUFFIX;

  // RE Engine RT workaround suffix (after %command%)
  if FReEngineRTCheckBox.Checked then
    LaunchCommand := LaunchCommand + LAUNCH_SUFFIX_WINE_DETECTION;

  notificationLabel.Visible := False;
  FLaunchCommand := LaunchCommand;
  commandPaintBox.Invalidate;
  commandPanel.Visible := True;
end;

procedure Tgoverlayform.SaveOptiScalerConfig;
begin
  TOptiScalerTabHelper(FOptiScalerHelper).SaveOptiScalerConfig;
end;

procedure Tgoverlayform.SaveVkSumiConfig;
var
  Settings: TVkSumiSettings;
  ErrMsg: string;
  LaunchCommand: string;
  i: Integer;
begin
  Settings.SumiFolder := VKSUMIFOLDER;
  Settings.SumiCfgFile := VKSUMICFGFILE;
  Settings.Version := GVERSION;
  Settings.Channel := GCHANNEL;
  if Assigned(FVsEnabledCB) then
    Settings.Enabled := FVsEnabledCB.Checked
  else
    Settings.Enabled := True;

  if Assigned(FVsToggleEdit) and (Trim(FVsToggleEdit.Text) <> '') then
    Settings.ToggleKeys := FVsToggleEdit.Text
  else
    Settings.ToggleKeys := 'Shift_R+F9';

  for i := 0 to 14 do
  begin
    if Assigned(FVsTrackbars[i]) then
      Settings.TrackbarPositions[i] := FVsTrackbars[i].Position
    else
      Settings.TrackbarPositions[i] := 100;
  end;
  Settings.ActiveGameName := FActiveGameName;

  if not overlay_config.SaveVkSumiConfig(Settings, ErrMsg) then
  begin
    if ErrMsg <> '' then
      ShowMessage(ErrMsg);
    Exit;
  end;

  // In game-specific mode: inject VKSUMI_CONFIG_FILE into the game bgmod
  // so the launcher can locate the per-game config at runtime.
  if FActiveGameName <> '' then
    PatchGameFGModConfigPath(
      GetGameConfigDir(FActiveGameName) + 'bgmod',
      'VKSUMI_CONFIG_FILE',
      VKSUMICFGFILE);

  SendNotification('vkSumi', 'Configuration saved to ' + VKSUMICFGFILE, GetIconFile);

  // Always show the bgmod command — use game-specific bgmod copy when in game mode
  if FActiveGameName <> '' then
  begin
    if FActiveGameIsNonSteam then
      LaunchCommand := GetGameConfigDir(FActiveGameName) + 'bgmod '
    else
      LaunchCommand := '"' + GetGameConfigDir(FActiveGameName) + 'bgmod" ';
  end
  else
    LaunchCommand := '"' + GetFGModPath + '/bgmod" ';

  // Check if gamemode should be added (check generalCheckGroup)
  if GetGeneralCheckBox(1).Checked then
    LaunchCommand := LaunchCommand + ENV_GAMEMODERUN + ' ';

  if not ( (FActiveGameName <> '') and FActiveGameIsNonSteam ) then
    LaunchCommand := LaunchCommand + LAUNCH_COMMAND_SUFFIX;

  notificationLabel.Visible := False;
  FLaunchCommand := LaunchCommand;
  commandPaintBox.Invalidate;
  commandPanel.Visible := True;
end;

procedure Tgoverlayform.LoadVkSumiConfig;
var
  Settings: TVkSumiSettings;
  i: Integer;
begin
  if not overlay_config.LoadVkSumiConfig(VKSUMICFGFILE, Settings) then
    Exit;

  if Assigned(FVsEnabledCB) then
    FVsEnabledCB.Checked := Settings.Enabled;

  if Assigned(FVsToggleEdit) then
    FVsToggleEdit.Text := Settings.ToggleKeys;

  if Assigned(FVsToggleCaptureBtn) and Assigned(FVsToggleEdit) then
    FVsToggleCaptureBtn.Caption := '⌨ ' + FVsToggleEdit.Text;

  for i := 0 to 14 do
  begin
    if Assigned(FVsTrackbars[i]) then
      FVsTrackbars[i].Position := Settings.TrackbarPositions[i];
  end;
end;

procedure Tgoverlayform.VsRestoreBtnClick(Sender: TObject);
begin
  TVkBasaltTabHelper(FBasaltHelper).VsRestoreBtnClick(Sender);
end;

procedure Tgoverlayform.SaveVkBasaltConfig;
var
  Settings: TVkBasaltSettings;
  ErrMsg: string;
  LaunchCommand: string;
begin
  if VKBASALTFOLDER = '' then
  begin
    ShowMessage('vkBasalt directory not found');
    Exit;
  end;

  Settings.BasaltFolder := VKBASALTFOLDER;
  Settings.BasaltCfgFile := VKBASALTCFGFILE;
  Settings.Version := GVERSION;
  Settings.Channel := GCHANNEL;
  Settings.ToggleKey := vkbtogglekeyCombobox.Text;
  Settings.CasPosition := casTrackBar.Position;
  Settings.FxaaPosition := fxaatrackbar.Position;
  Settings.SmaaPosition := smaatrackbar.Position;
  Settings.DlsPosition := dlstrackbar.Position;
  Settings.ReshadeEffects := acteffectsListbox.Items;
  Settings.ActiveGameName := FActiveGameName;

  if not overlay_config.SaveVkBasaltConfig(Settings, ErrMsg) then
  begin
    if ErrMsg <> '' then
      ShowMessage(ErrMsg);
    Exit;
  end;

  // In game-specific mode: inject VKBASALT_CONFIG_FILE into the game bgmod
  if FActiveGameName <> '' then
    PatchGameFGModConfigPath(
      GetGameConfigDir(FActiveGameName) + 'bgmod',
      'VKBASALT_CONFIG_FILE',
      VKBASALTCFGFILE);

  SendNotification('vkBasalt', 'configuration saved', GetIconFile);

  // Always show the bgmod command — use game-specific bgmod copy when in game mode
  if FActiveGameName <> '' then
  begin
    if FActiveGameIsNonSteam then
      LaunchCommand := GetGameConfigDir(FActiveGameName) + 'bgmod '
    else
      LaunchCommand := '"' + GetGameConfigDir(FActiveGameName) + 'bgmod" ';
  end
  else
    LaunchCommand := '"' + GetFGModPath + '/bgmod" ';

  // Check if gamemode should be added (check generalCheckGroup)
  if GetGeneralCheckBox(1).Checked then
    LaunchCommand := LaunchCommand + ENV_GAMEMODERUN + ' ';

  if not ( (FActiveGameName <> '') and FActiveGameIsNonSteam ) then
    LaunchCommand := LaunchCommand + LAUNCH_COMMAND_SUFFIX;

  notificationLabel.Visible := False;
  FLaunchCommand := LaunchCommand;
  commandPaintBox.Invalidate;
  commandPanel.Visible := True;
end;

procedure Tgoverlayform.saveBitBtnClick(Sender: TObject);
var
  LaunchCommand: string;
  FileLines: TStringList;
  i: Integer;
  GlobalMangoHudFile: string;  // Global MangoHud config path (for blacklist — never game-specific)
  BlacklistCfg: TConfigFile;
begin

  // ################### SAVE TWEAKS TAB SETTINGS
  if goverlayPageControl.ActivePage = tweaksTabSheet then
  begin
    SaveTweaksConfig;
    Exit;
  end;

  // ################### SAVE OPTISCALER SETTINGS
  if goverlayPageControl.ActivePage = optiscalerTabSheet then
  begin
    SaveOptiScalerConfig;
    Exit;
  end;

  // ################### SAVE MANGOHUD

   if (goverlayPageControl.ActivePage <> vkbasaltTabSheet) and
      (goverlayPageControl.ActivePage <> vksumiTabSheet) then
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
      commandPanel.Visible := True;
      FLaunchCommand := 'MangoHud will be displayed in every vulkan application';
      commandPaintBox.Invalidate;
    end
    else
    begin
      // Build launch command — use the game-specific fgmod copy when in game
      // mode so that MangoHud.conf is picked up from the game config directory.
      // Quoted to handle spaces in game names / paths.
      if FActiveGameName <> '' then
      begin
        if FActiveGameIsNonSteam then
          LaunchCommand := GetGameConfigDir(FActiveGameName) + 'bgmod '
        else
          LaunchCommand := '"' + GetGameConfigDir(FActiveGameName) + 'bgmod" ';
      end
      else
        LaunchCommand := '"' + GetFGModPath + '/bgmod" ';

      // Check if gamemode should be added (check generalCheckGroup)
      if GetGeneralCheckBox(1).Checked then
        LaunchCommand := LaunchCommand + ENV_GAMEMODERUN + ' ';

      if not ( (FActiveGameName <> '') and FActiveGameIsNonSteam ) then
        LaunchCommand := LaunchCommand + LAUNCH_COMMAND_SUFFIX;

      notificationLabel.Visible := False;
      FLaunchCommand := LaunchCommand;
      commandPaintBox.Invalidate;
      commandPanel.Visible := True;
    end;

    //########################################### SAVE BLACKLIST
    // The blacklist is always applied to the global MangoHud.conf (it filters
    // process names system-wide). Use a local variable so that MANGOHUDCFGFILE
    // continues to point to the game-specific path when in game mode.

    BLACKLISTFILE := GetUserConfigDir + '/goverlay/blacklist.conf';
    GlobalMangoHudFile := IncludeTrailingPathDelimiter(GetMangoHudConfigDir()) + 'MangoHud.conf';

    FileLines := TStringList.Create;
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

      // Build blacklist=... string
      blacklistVAR := 'blacklist=' + FileLines[0];
      for i := 1 to FileLines.Count - 1 do
        blacklistVAR := blacklistVAR + ',' + FileLines[i];
    finally
      FileLines.Free;
    end;

    // Ensure global MangoHud.conf has the blacklist line (idempotent)
    BlacklistCfg := TConfigFile.Create;
    try
      if BlacklistCfg.Load(GlobalMangoHudFile) then
      begin
        if not BlacklistCfg.HasKey('blacklist=') then
          BlacklistCfg.AddRaw(blacklistVAR);
      end
      else
      begin
        BlacklistCfg.AddRaw(blacklistVAR);
      end;
      CreateHostDirectory(ExtractFilePath(GlobalMangoHudFile));
      BlacklistCfg.Save;
    finally
      BlacklistCfg.Free;
    end;

end;  //  ################### END - SAVE MANGOHUD




    // ################### START - SAVE VKBASALT
    if goverlayPageControl.ActivePage = vkbasaltTabSheet then
    begin
      SaveVkBasaltConfig;
      Exit;
    end;

    // ################### START - SAVE VKSUMI
    if goverlayPageControl.ActivePage = vksumiTabSheet then
    begin
      SaveVkSumiConfig;
      Exit;
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
        if (goverlayPageControl.ActivePage = vkbasaltTabSheet) or
           (goverlayPageControl.ActivePage = vksumiTabSheet) then
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
            if Trim(vkbtogglekeyCombobox.Text) <> '' then
              ConfigLines.Add('toggleKey = ' + Trim(vkbtogglekeyCombobox.Text));
            
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
            
            // SMAA parameters — only written when trackbar > 0
            if smaaTrackBar.Position >= 1 then
            begin
              ConfigLines.Add('');
              ConfigLines.Add('#smaaThreshold specifies the threshold for edge detection');
              ConfigLines.Add('smaaThreshold = ' + StringReplace(Format('%.2f', [0.1 - 0.05 * (smaaTrackbar.Position - 1) / 9.0], FS), ',', '.', [rfReplaceAll]));
              ConfigLines.Add('');
              ConfigLines.Add('#smaaMaxSearchSteps specifies the maximum steps in edge pattern search');
              ConfigLines.Add('smaaMaxSearchSteps = ' + IntToStr(Round(16 + 16 * (smaaTrackbar.Position - 1) / 9.0)));
              ConfigLines.Add('');
              ConfigLines.Add('#smaaMaxSearchStepsDiag specifies the maximum steps in diagonal pattern search');
              ConfigLines.Add('smaaMaxSearchStepsDiag = ' + IntToStr(Round(8 + 8 * (smaaTrackbar.Position - 1) / 9.0)));
              ConfigLines.Add('');
              ConfigLines.Add('#smaaCornerRounding specifies how much to round sharp corners');
              ConfigLines.Add('smaaCornerRounding = ' + StringReplace(Format('%.1f', [25.0 * (smaaTrackbar.Position - 1) / 9.0], FS), ',', '.', [rfReplaceAll]));
              ConfigLines.Add('');
            end;
            
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
  if Assigned(FVkSmaaValLbl) then FVkSmaaValLbl.Caption := smaavaluelabel.Caption;
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

procedure Tgoverlayform.settingsSpeedButtonClick(Sender: TObject);
begin
  settingsMenu.PopUp;
end;

procedure Tgoverlayform.themeMenuItemClick(Sender: TObject);
var
  NewTheme: TThemeMode;
begin
  // Toggle between themes
  NewTheme := ToggleTheme(Self);

  // Update settings menu theme item caption
  if NewTheme = tmLight then
    themeMenuItem.Caption := 'Switch to Dark theme'
  else
    themeMenuItem.Caption := 'Switch to Light theme';

  // Restore nav rail colors (theme engine overwrites the dynamic panels)
  RestoreNavRailColors;

  // Apply per-control theme overrides for dynamically created controls
  ApplyCustomEnvTheme;

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
  ConfigPath: string;
  Ini: TIniFile;
begin
  if FActiveGameName <> '' then
    ConfigPath := GetGameConfigDir(FActiveGameName) + 'bgmod.conf'
  else
    ConfigPath := GetFGModPath + PathDelim + 'bgmod.conf';

  if FileExists(ConfigPath) then
  begin
    Ini := TIniFile.Create(ConfigPath);
    try
      Ini.WriteString('Config', 'GOVERLAY_MANGOHUD', '0');
    finally
      Ini.Free;
    end;
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

// ============================================================================
// PRESETS — modern card-grid UI
// ============================================================================

procedure Tgoverlayform.BuildPresetsWrapper;
begin
  TMangoHudUiHelper(FMangoHelper).BuildPresetsWrapper;
end;

function Tgoverlayform.FindPresetCard(ASender: TObject): TPanel;
begin
  Result := TMangoHudUiHelper(FMangoHelper).FindPresetCard(ASender);
end;

procedure Tgoverlayform.UpdatePresetCardVisuals;
begin
  TMangoHudUiHelper(FMangoHelper).UpdatePresetCardVisuals;
end;

procedure Tgoverlayform.PresetCardPaint(Sender: TObject);
begin
  TMangoHudUiHelper(FMangoHelper).PresetCardPaint(Sender);
end;

procedure Tgoverlayform.PresetCardClick(Sender: TObject);
begin
  TMangoHudUiHelper(FMangoHelper).PresetCardClick(Sender);
end;

procedure Tgoverlayform.PresetCardMouseEnter(Sender: TObject);
begin
  TMangoHudUiHelper(FMangoHelper).PresetCardMouseEnter(Sender);
end;

procedure Tgoverlayform.PresetCardMouseLeave(Sender: TObject);
begin
  TMangoHudUiHelper(FMangoHelper).PresetCardMouseLeave(Sender);
end;

procedure Tgoverlayform.BuildNavRail;
const
  // Item definitions: (unicode icon, caption, top offset)
  ITEMS: array[0..4] of record Icon, Caption: string; end = (
    (Icon: '󰊴'; Caption: 'Games'),
    (Icon: '󱁥'; Caption: 'MangoHud'),
    (Icon: '󰏘'; Caption: 'Post processing'),
    (Icon: '󰋮'; Caption: 'OptiScaler'),
    (Icon: '󰒓'; Caption: 'EnvVars')
  );
  TOP_START = 108;
var
  i: Integer;
  Item: TPanel;
  Indicator: TShape;
  IconPath: string;
  IconLbl: TLabel;
  CaptionLbl: TLabel;
  TopY: Integer;
  UIStateFile: string;
  SL: TStringList;
begin
  // Hide legacy shape+label widgets
  mangohudShape.Visible  := False;  mangohudLabel.Visible  := False;
  vkbasaltShape.Visible  := False;  vkbasaltLabel.Visible  := False;
  optiscalerShape.Visible := False; optiscalerLabel.Visible := False;
  tweaksShape.Visible    := False;  tweaksLabel.Visible    := False;

  SetLength(FNavItems,      Length(ITEMS));
  SetLength(FNavIndicators, Length(ITEMS));
  SetLength(FNavIcons,      Length(ITEMS));
  SetLength(FNavLabels,     Length(ITEMS));
  SetLength(FNavClickCBs,   Length(ITEMS));

  FNavClickCBs[0] := @gamesLabelClick;
  FNavClickCBs[1] := @mangohudLabelClick;
  FNavClickCBs[2] := @vkbasaltLabelClick;
  FNavClickCBs[3] := @optiscalerLabelClick;
  FNavClickCBs[4] := @tweaksLabelClick;

  FNavActive     := -1;
  FNavHoveredIdx := -1;
  FNavCollapsed    := False;
  FCubeAutoLaunch  := False;  // disabled by default

  // Restore sidebar collapsed state from previous session
  UIStateFile := IncludeTrailingPathDelimiter(TConfigManager.GetGoverlayFolder) + 'ui_state';
  if FileExists(UIStateFile) then
  begin
    SL := TStringList.Create;
    try
      SL.LoadFromFile(UIStateFile);
      if (SL.Count > 0) and (SL[0] = '1') then
        FNavCollapsed := True;
      if (SL.Count > 1) and (SL[1] = '1') then
        FCubeAutoLaunch := True;
    finally
      SL.Free;
    end;
  end;

  FNavAnimCurrent := IfThen(FNavCollapsed, NAV_W_COLLAPSED, NAV_W_EXPANDED) * 10;
  FNavAnimTarget  := IfThen(FNavCollapsed, NAV_W_COLLAPSED, NAV_W_EXPANDED);

  FNavAnimTimer := TTimer.Create(Self);
  FNavAnimTimer.Interval := 12;  // ~80fps
  FNavAnimTimer.Enabled  := False;
  FNavAnimTimer.OnTimer  := @NavAnimTick;

  // Toggle button — small discrete arrow, bottom-right of logo area
  FNavToggleBtn := TSpeedButton.Create(Self);
  FNavToggleBtn.Parent  := Self;
  FNavToggleBtn.SetBounds(NAV_W_EXPANDED - 28, 53, 24, 24);
  FNavToggleBtn.Caption    := '«';
  FNavToggleBtn.Font.Size  := 11;
  FNavToggleBtn.Font.Color := $00666666;
  FNavToggleBtn.Flat    := True;
  FNavToggleBtn.Cursor  := crHandPoint;
  FNavToggleBtn.Color   := $00221F1E;
  FNavToggleBtn.OnClick := @NavToggleClick;

  // Small app icon shown in collapsed state instead of the full logo
  FNavSmallIcon := TImage.Create(Self);
  FNavSmallIcon.Parent  := Self;
  FNavSmallIcon.SetBounds((NAV_W_COLLAPSED - 40) div 2, 8, 40, 40);
  FNavSmallIcon.Stretch      := True;
  FNavSmallIcon.Proportional := True;
  FNavSmallIcon.Center       := True;
  FNavSmallIcon.Visible      := False;
  // Load icon — try installed path first, then local data dir
  IconPath := GetIconFile();
  if not FileExists(IconPath) then
    IconPath := GetAppBaseDir + 'data/icons/128x128/goverlay.png';
  if FileExists(IconPath) then
    try FNavSmallIcon.Picture.LoadFromFile(IconPath); except end;


  for i := 0 to High(ITEMS) do
  begin
    TopY := TOP_START + i * (NAV_ITEM_H + 4);

    // --- Item panel ---
    Item := TPanel.Create(Self);
    Item.Parent  := Self;
    Item.SetBounds(goverlayPaintBox.Left, goverlayPaintBox.Top + TopY, NAV_ITEM_W, NAV_ITEM_H);
    Item.BevelOuter := bvNone;
    Item.Caption := '';
    Item.Color   := NAV_COLOR_BG;
    Item.Cursor  := crHandPoint;
    Item.Tag     := i;
    Item.OnClick      := @NavItemClick;
    Item.OnMouseEnter := @NavItemMouseEnter;
    Item.OnMouseLeave := @NavItemMouseLeave;
    Item.OnPaint      := @NavItemPaint;

    // --- Active indicator bar (left edge) ---
    Indicator := TShape.Create(Self);
    Indicator.Parent := Item;
    Indicator.SetBounds(0, 12, NAV_INDICATOR_W, NAV_ITEM_H - 24);
    Indicator.Brush.Color := NAV_COLOR_INDICATOR;
    Indicator.Pen.Color   := NAV_COLOR_INDICATOR;
    Indicator.Shape   := stRoundRect;
    Indicator.Visible := False;

    // --- Icon label (Nerd Font / Unicode) ---
    IconLbl := TLabel.Create(Self);
    IconLbl.Parent := Item;
    IconLbl.SetBounds(16, (NAV_ITEM_H - NAV_ICON_SIZE) div 2, NAV_ICON_SIZE, NAV_ICON_SIZE);

    if i = 3 then
    begin
      IconLbl.Caption := ''; // Clear text

      FOptiScalerImg := TImage.Create(Self);
      FOptiScalerImg.Parent := Item;
      FOptiScalerImg.SetBounds(18, (NAV_ITEM_H - 24) div 2, 24, 24);
      FOptiScalerImg.Stretch := True;
      FOptiScalerImg.Proportional := True;
      FOptiScalerImg.Center := True;
      FOptiScalerImg.Cursor := crHandPoint;
      FOptiScalerImg.Tag := i;
      FOptiScalerImg.OnClick      := @NavItemClick;
      FOptiScalerImg.OnMouseEnter := @NavItemMouseEnter;
      FOptiScalerImg.OnMouseLeave := @NavItemMouseLeave;

      IconPath := GetAppBaseDir + 'assets/icons/scale-up2.png';
      WriteLn(StdErr, '[NavIcon] scale-up2 path="', IconPath, '" exists=', FileExists(IconPath));
      if FileExists(IconPath) then
        try FOptiScalerImg.Picture.LoadFromFile(IconPath); except on E: Exception do WriteLn(StdErr, '[NavIcon] scale-up2 load error: ', E.Message); end;
    end
    else if i = 1 then
    begin
      IconLbl.Caption := ''; // Clear text

      FMangoHudImg := TImage.Create(Self);
      FMangoHudImg.Parent := Item;
      FMangoHudImg.SetBounds(18, (NAV_ITEM_H - 24) div 2, 24, 24);
      FMangoHudImg.Stretch := True;
      FMangoHudImg.Proportional := True;
      FMangoHudImg.Center := True;
      FMangoHudImg.Cursor := crHandPoint;
      FMangoHudImg.Tag := i;
      FMangoHudImg.OnClick      := @NavItemClick;
      FMangoHudImg.OnMouseEnter := @NavItemMouseEnter;
      FMangoHudImg.OnMouseLeave := @NavItemMouseLeave;

      IconPath := GetAppBaseDir + 'assets/icons/mango-inactive.png';
      WriteLn(StdErr, '[NavIcon] mango-inactive path="', IconPath, '" exists=', FileExists(IconPath));
      if FileExists(IconPath) then
        try FMangoHudImg.Picture.LoadFromFile(IconPath); except on E: Exception do WriteLn(StdErr, '[NavIcon] mango-inactive load error: ', E.Message); end;
    end
    else
    begin
      IconLbl.Caption   := ITEMS[i].Icon;
    end;
    IconLbl.Font.Size := 18;
    IconLbl.Font.Color := $00AAAAAA;
    IconLbl.Font.Name  := 'Noto Sans';
    IconLbl.Transparent := True;
    IconLbl.Cursor := crHandPoint;
    IconLbl.Tag    := i;
    IconLbl.OnClick      := @NavItemClick;
    IconLbl.OnMouseEnter := @NavItemMouseEnter;
    IconLbl.OnMouseLeave := @NavItemMouseLeave;

    // --- Caption label ---
    CaptionLbl := TLabel.Create(Self);
    CaptionLbl.Parent := Item;
    CaptionLbl.SetBounds(52, (NAV_ITEM_H - 16) div 2, NAV_ITEM_W - 60, 20);
    CaptionLbl.Caption   := ITEMS[i].Caption;
    CaptionLbl.Font.Size := 9;
    CaptionLbl.Font.Color := $00AAAAAA;
    CaptionLbl.Font.Name  := 'Noto Sans';
    CaptionLbl.Font.Style := [fsBold];
    CaptionLbl.Transparent := True;
    CaptionLbl.Cursor := crHandPoint;
    CaptionLbl.Tag    := i;
    CaptionLbl.OnClick      := @NavItemClick;
    CaptionLbl.OnMouseEnter := @NavItemMouseEnter;
    CaptionLbl.OnMouseLeave := @NavItemMouseLeave;

    FNavItems[i]      := Item;
    FNavIndicators[i] := Indicator;
    FNavIcons[i]      := IconLbl;
    FNavLabels[i]     := CaptionLbl;
  end;

  // Build per-tool toggle buttons (game mode only)
  BuildNavToolToggles;
  BuildSmallToggleImages;

  // Apply persisted collapsed state (no animation on startup)
  if FNavCollapsed then
    ApplyNavCollapsed;

  LoadGlobalThumb;
end;

procedure Tgoverlayform.BuildSettingsButton;
const
  BTN_SIZE       = 40;
  BTN_BOTTOM_PAD = 12;
var
  Sep: TMenuItem;
begin
  // Transparent label — no background, just the gear icon over the sidebar gradient
  FSettingsIconLbl := TLabel.Create(Self);
  FSettingsIconLbl.Parent       := Self;
  FSettingsIconLbl.Caption      := '⚙';
  FSettingsIconLbl.Font.Color   := $00AAAAAA;  // dimmed like inactive nav items
  FSettingsIconLbl.Font.Height  := -24;
  FSettingsIconLbl.Font.Quality := fqAntialiased;
  FSettingsIconLbl.Transparent  := True;
  FSettingsIconLbl.Cursor       := crHandPoint;
  FSettingsIconLbl.AutoSize     := False;
  FSettingsIconLbl.Width        := BTN_SIZE;
  FSettingsIconLbl.Height       := BTN_SIZE;
  FSettingsIconLbl.Alignment    := taCenter;

  // Center horizontally inside the sidebar, fixed distance from bottom
  FSettingsIconLbl.AnchorSideLeft.Control := goverlayPaintBox;
  FSettingsIconLbl.AnchorSideLeft.Side    := asrCenter;
  FSettingsIconLbl.AnchorSideBottom.Control := Self;
  FSettingsIconLbl.AnchorSideBottom.Side    := asrBottom;
  FSettingsIconLbl.BorderSpacing.Bottom     := BTN_BOTTOM_PAD;
  FSettingsIconLbl.Anchors := [akLeft, akBottom];

  FSettingsIconLbl.OnMouseEnter := @SettingsBtnMouseEnter;
  FSettingsIconLbl.OnMouseLeave := @SettingsBtnMouseLeave;
  FSettingsIconLbl.OnClick      := @SettingsBtnClick;

  // Dependencies status item at the top of the settings menu
  FDepsMenuItem := TMenuItem.Create(settingsMenu);
  FDepsMenuItem.Caption := 'Status';
  FDepsMenuItem.ImageIndex := 0;
  FDepsMenuItem.Enabled := True;
  FDepsMenuItem.OnClick := @ShowHomeTab;
  settingsMenu.Items.Insert(0, FDepsMenuItem);

  // Separator after deps item
  Sep := TMenuItem.Create(settingsMenu);
  Sep.Caption := '-';
  settingsMenu.Items.Insert(1, Sep);

  // Auto-launch cube toggle
  FCubeAutoLaunchItem := TMenuItem.Create(settingsMenu);
  FCubeAutoLaunchItem.Caption := 'Auto launch PasCube';
  FCubeAutoLaunchItem.ImageIndex := 4;
  FCubeAutoLaunchItem.Checked := FCubeAutoLaunch;
  FCubeAutoLaunchItem.OnClick := @CubeAutoLaunchMenuItemClick;
  settingsMenu.Items.Insert(2, FCubeAutoLaunchItem);

  Sep := TMenuItem.Create(settingsMenu);
  Sep.Caption := '-';
  settingsMenu.Items.Insert(3, Sep);

  // How to Use — now available via popup menu only
  FHowToMenuItem := TMenuItem.Create(settingsMenu);
  FHowToMenuItem.Caption := 'How to use FGMOD';
  FHowToMenuItem.ImageIndex := 18;
  FHowToMenuItem.OnClick := @howtoBitBtnClick;
  settingsMenu.Items.Insert(4, FHowToMenuItem);

  Sep := TMenuItem.Create(settingsMenu);
  Sep.Caption := '-';
  settingsMenu.Items.Insert(5, Sep);
end;

procedure Tgoverlayform.SettingsBtnMouseEnter(Sender: TObject);
begin
  if Assigned(FSettingsIconLbl) then
    FSettingsIconLbl.Font.Color := IfThen(CurrentTheme = tmLight, clBlack, clWhite);
end;

procedure Tgoverlayform.SettingsBtnMouseLeave(Sender: TObject);
begin
  if Assigned(FSettingsIconLbl) then
    FSettingsIconLbl.Font.Color := IfThen(CurrentTheme = tmLight, $00555555, $00AAAAAA);
end;

procedure Tgoverlayform.SettingsBtnClick(Sender: TObject);
begin
  settingsMenu.PopUp;
end;

procedure Tgoverlayform.CubeAutoLaunchMenuItemClick(Sender: TObject);
var
  UIStateFile: string;
  SL: TStringList;
begin
  FCubeAutoLaunch := not FCubeAutoLaunch;
  FCubeAutoLaunchItem.Checked := FCubeAutoLaunch;

  UIStateFile := IncludeTrailingPathDelimiter(TConfigManager.GetGoverlayFolder) + 'ui_state';
  SL := TStringList.Create;
  try
    SL.Add(IfThen(FNavCollapsed, '1', '0'));
    SL.Add(IfThen(FCubeAutoLaunch, '1', '0'));
    SL.SaveToFile(UIStateFile);
  finally
    SL.Free;
  end;
end;

// ============================================================================
// PER-TOOL TOGGLE BUTTONS (game mode only)
// ============================================================================

procedure Tgoverlayform.BuildNavToolToggles;
const
  BTN_SIZE = 32;
var
  i: Integer;
  Btn: TSpeedButton;
begin
  for i := 0 to 3 do
  begin
    FNavToolEnabled[i] := True;
    Btn := TSpeedButton.Create(Self);
    Btn.Parent    := FNavItems[i + 1];  // offset by 1: Games is at index 0
    Btn.SetBounds(NAV_ITEM_W - BTN_SIZE - 6, (NAV_ITEM_H - BTN_SIZE) div 2, BTN_SIZE, BTN_SIZE);
    Btn.Flat      := True;
    Btn.Caption   := '';
    Btn.Images    := globalbuttonImageList;
    Btn.ImageIndex := 1;  // 1 = ON
    Btn.Cursor    := crHandPoint;
    Btn.Tag       := i;
    Btn.OnClick   := @NavToolToggleClick;
    Btn.Visible   := False;
    FNavToolBtns[i] := Btn;
  end;
end;

procedure Tgoverlayform.BuildSmallToggleImages;
var
  SrcBmp, DstBmp: TBitmap;
  i: Integer;
begin
  if Assigned(FNavToolImgListSmall) then
    FreeAndNil(FNavToolImgListSmall);

  FNavToolImgListSmall := TImageList.Create(Self);
  FNavToolImgListSmall.Width  := 20;
  FNavToolImgListSmall.Height := 9;

  for i := 0 to 1 do
  begin
    SrcBmp := TBitmap.Create;
    try
      SrcBmp.Width  := globalbuttonImageList.Width;
      SrcBmp.Height := globalbuttonImageList.Height;
      SrcBmp.Canvas.Brush.Color := clFuchsia;
      SrcBmp.Canvas.FillRect(0, 0, SrcBmp.Width, SrcBmp.Height);
      globalbuttonImageList.Draw(SrcBmp.Canvas, 0, 0, i);

      DstBmp := TBitmap.Create;
      try
        DstBmp.Width  := 20;
        DstBmp.Height := 9;
        DstBmp.Canvas.Brush.Color := clFuchsia;
        DstBmp.Canvas.FillRect(0, 0, DstBmp.Width, DstBmp.Height);
        DstBmp.Canvas.StretchDraw(Rect(0, 0, 20, 9), SrcBmp);
        FNavToolImgListSmall.AddMasked(DstBmp, clFuchsia);
      finally
        DstBmp.Free;
      end;
    finally
      SrcBmp.Free;
    end;
  end;
end;

procedure Tgoverlayform.NavToolToggleClick(Sender: TObject);
var
  Idx: Integer;
  NewEnabled: Boolean;
  GameCfgDir: string;
  ConfigFiles: array[0..2] of string;
begin
  Idx        := (Sender as TSpeedButton).Tag;
  NewEnabled := not FNavToolEnabled[Idx];
  FNavToolEnabled[Idx] := NewEnabled;
  // ImageIndex 1 = ON (green), 0 = OFF (red)
  FNavToolBtns[Idx].ImageIndex := IfThen(NewEnabled, 1, 0);
  if FActiveGameName <> '' then
  begin
    SetGameToolEnabled(FActiveGameName, Idx, NewEnabled);
    GameCfgDir := GetGameConfigDir(FActiveGameName);
    if not NewEnabled then
    begin
      // Delete the tool's config file when disabling (indices 0-2 only)
      ConfigFiles[0] := GameCfgDir + 'MangoHud.conf';
      ConfigFiles[1] := GameCfgDir + 'vkBasalt.conf';
      ConfigFiles[2] := GameCfgDir + 'OptiScaler.ini';
      if (Idx <= 2) and FileExists(ConfigFiles[Idx]) then
        DeleteFile(ConfigFiles[Idx]);
      if (Idx = 1) and FileExists(GameCfgDir + 'vkSumi.conf') then
        DeleteFile(GameCfgDir + 'vkSumi.conf');
      // Tweaks: remove all tweak export lines from the game's fgmod
      if Idx = 3 then
        RemoveTweaksFromGameFGMod(GameCfgDir + 'fgmod');
    end;
    // Ensure conditional export lines exist in the fgmod for tools that need them.
    // The GOVERLAY_X flag (set above) controls whether each line actually runs.
    if Idx = 0 then
      PatchGameFGModConditionalExport(GameCfgDir + 'fgmod',
        '[[ "$GOVERLAY_MANGOHUD" == "1" ]] && export MANGOHUD=1',
        'MANGOHUD=1');
    if Idx = 1 then
    begin
      PatchGameFGModConditionalExport(GameCfgDir + 'fgmod',
        '[[ "$GOVERLAY_VKBASALT" == "1" ]] && export ENABLE_VKBASALT=1',
        'ENABLE_VKBASALT=1');
      PatchGameFGModConditionalExport(GameCfgDir + 'fgmod',
        '[[ "$GOVERLAY_VKBASALT" == "1" ]] && export ENABLE_VKSUMI=1',
        'ENABLE_VKSUMI=1');
    end;
    // OptiScaler toggle copies/removes all OptiScaler files and patches fgmod
    if Idx = 2 then
    begin
      PatchGameFGModWineDllOverrides(GameCfgDir + 'fgmod', NewEnabled);
      if NewEnabled then
        CopyOptiScalerGameFiles(GameCfgDir)
      else
        RemoveOptiScalerGameFiles(GameCfgDir);
    end;
  end;
  ApplyToolEnabledState(Idx, NewEnabled);
end;

procedure Tgoverlayform.UpdateNavToolToggleVisibility(AShowLabels: Boolean);
const
  BTN_FULL   = 32;  // button size in expanded mode
  BTN_SMALL  = 20;  // button size in collapsed mode
  ICON_TOP_C = 8;   // icon top offset in collapsed mode (shifted up to make room)
var
  i: Integer;
  ShouldShow: Boolean;
  BtnLeft, BtnTop, BtnW: Integer;
begin
  ShouldShow := FActiveGameName <> '';
  for i := 0 to 3 do
    if Assigned(FNavToolBtns[i]) then
    begin
      if ShouldShow then
      begin
        if AShowLabels then
        begin
          // Expanded: full-size button on the right side of the nav item
          BtnW    := BTN_FULL;
          BtnLeft := NAV_ITEM_W - BtnW - 6;
          BtnTop  := (NAV_ITEM_H - BtnW) div 2;
          FNavToolBtns[i].Images := globalbuttonImageList;
        end
        else
        begin
          // Collapsed: small button below the icon, horizontally centred
          BtnW    := BTN_SMALL;
          BtnLeft := (NAV_W_COLLAPSED - BtnW) div 2;
          BtnTop  := ICON_TOP_C + NAV_ICON_SIZE + 4;
          if Assigned(FNavToolImgListSmall) then
            FNavToolBtns[i].Images := FNavToolImgListSmall;
        end;
        FNavToolBtns[i].SetBounds(BtnLeft, BtnTop, BtnW, BtnW);
      end;
      FNavToolBtns[i].Visible := ShouldShow;
    end;
end;

procedure Tgoverlayform.LoadGameToggleStates;
var
  i: Integer;
  ToolOn: Boolean;
begin
  if FActiveGameName = '' then
  begin
    // Global mode: all tools enabled, hide toggles
    for i := 0 to 3 do
    begin
      FNavToolEnabled[i] := True;
      if Assigned(FNavToolBtns[i]) then
      begin
        FNavToolBtns[i].Visible    := False;
        FNavToolBtns[i].ImageIndex := 1;  // ON
      end;
      ApplyToolEnabledState(i, True);
    end;
    Exit;
  end;
  for i := 0 to 3 do
  begin
    ToolOn := GetGameToolEnabled(FActiveGameName, i);
    FNavToolEnabled[i] := ToolOn;
    if Assigned(FNavToolBtns[i]) then
      FNavToolBtns[i].ImageIndex := IfThen(ToolOn, 1, 0);
    ApplyToolEnabledState(i, ToolOn);
  end;
  // Update visibility, button size/position, and icon vertical position
  ApplyNavWidth(IfThen(FNavCollapsed, NAV_W_COLLAPSED, NAV_W_EXPANDED));
end;

function Tgoverlayform.GetGameToolEnabled(const AGameName: string; AToolIdx: Integer): Boolean;
const
  FLAGS: array[0..3] of string = ('GOVERLAY_MANGOHUD', 'GOVERLAY_VKBASALT', 'GOVERLAY_OPTISCALER', 'GOVERLAY_TWEAKS');
var
  ConfigPath: string;
  Ini: TIniFile;
begin
  Result := False;
  ConfigPath := GetGameConfigDir(AGameName) + 'bgmod.conf';
  if not FileExists(ConfigPath) then Exit;
  Ini := TIniFile.Create(ConfigPath);
  try
    Result := Ini.ReadString('Config', FLAGS[AToolIdx], '0') = '1';
  finally
    Ini.Free;
  end;
end;

procedure Tgoverlayform.SetGameToolEnabled(const AGameName: string; AToolIdx: Integer; AEnabled: Boolean);
const
  FLAGS: array[0..3] of string = ('GOVERLAY_MANGOHUD', 'GOVERLAY_VKBASALT', 'GOVERLAY_OPTISCALER', 'GOVERLAY_TWEAKS');
var
  ConfigPath: string;
  Ini: TIniFile;
begin
  ConfigPath := GetGameConfigDir(AGameName) + 'bgmod.conf';
  ForceDirectories(ExtractFilePath(ConfigPath));
  Ini := TIniFile.Create(ConfigPath);
  try
    if AEnabled then
      Ini.WriteString('Config', FLAGS[AToolIdx], '1')
    else
      Ini.WriteString('Config', FLAGS[AToolIdx], '0');
  finally
    Ini.Free;
  end;
end;

procedure Tgoverlayform.ApplyToolEnabledState(AToolIdx: Integer; AEnabled: Boolean);
begin
  case AToolIdx of
    0: // MangoHud spans several tab sheets
    begin
      SetControlTreeEnabled(presetTabSheet,       AEnabled);
      SetControlTreeEnabled(visualTabSheet,        AEnabled);
      SetControlTreeEnabled(performanceTabSheet,   AEnabled);
      SetControlTreeEnabled(metricsTabSheet,       AEnabled);
      SetControlTreeEnabled(extrasTabSheet,        AEnabled);
    end;
    1:
    begin
      SetControlTreeEnabled(vkbasaltTabsheet,    AEnabled);
      SetControlTreeEnabled(vksumiTabSheet,      AEnabled);
    end;
    2: SetControlTreeEnabled(optiscalertabsheet,  AEnabled);
    3: SetControlTreeEnabled(tweaksTabSheet,      AEnabled);
  end;
  // Disable Save when the toggled tool owns the currently visible tab
  if ActiveToolIndex = AToolIdx then
    SetSaveBtnEnabled(AEnabled);
end;

// Returns the tool index (0=MangoHud, 1=vkBasalt, 2=OptiScaler, -1=other)
// for the currently active page control tab.
function Tgoverlayform.ActiveToolIndex: Integer;
var
  P: TTabSheet;
begin
  P := goverlayPageControl.ActivePage;
  if (P = presetTabSheet) or (P = visualTabSheet) or
     (P = performanceTabSheet) or (P = metricsTabSheet) or (P = extrasTabSheet) then
    Result := 0
  else if (P = vkbasaltTabsheet) or (P = vksumiTabSheet) then
    Result := 1
  else if P = optiscalertabsheet then
    Result := 2
  else if P = tweaksTabSheet then
    Result := 3
  else
    Result := -1;
end;

procedure Tgoverlayform.SetSaveBtnEnabled(AEnabled: Boolean);
begin
  saveBitBtn.Enabled := AEnabled;
  if AEnabled then
    saveBitBtn.Color := $008300   // original green
  else
    saveBitBtn.Color := $00666666; // grey when disabled
end;

procedure Tgoverlayform.SetControlTreeEnabled(ACtrl: TWinControl; AEnabled: Boolean);
var
  i: Integer;
  Child: TControl;
begin
  ACtrl.Enabled := AEnabled;
  for i := 0 to ACtrl.ControlCount - 1 do
  begin
    Child := ACtrl.Controls[i];
    Child.Enabled := AEnabled;
    if Child is TWinControl then
      SetControlTreeEnabled(TWinControl(Child), AEnabled);
  end;
end;

procedure Tgoverlayform.RemoveTweaksFromGameFGMod(const AFGModFile: string);
var
  ConfigPath: string;
  Ini: TIniFile;
  DSpirvVal: string;
begin
  ConfigPath := ExtractFilePath(AFGModFile) + 'bgmod.conf';
  if not FileExists(ConfigPath) then Exit;
  Ini := TIniFile.Create(ConfigPath);
  try
    Ini.WriteString('Config', 'GOVERLAY_TWEAKS', '0');
    DSpirvVal := Ini.ReadString('Env', 'DXIL_SPIRV_CONFIG', '');
    Ini.EraseSection('Env');
    if DSpirvVal <> '' then
      Ini.WriteString('Env', 'DXIL_SPIRV_CONFIG', DSpirvVal);
  finally
    Ini.Free;
  end;
end;

procedure Tgoverlayform.EnsureGameFGModOptiScalerConditional(const AFGModFile: string);
begin
  // Obsolete: bgmod binary manages OptiScaler conditional logic natively.
end;

procedure Tgoverlayform.RemoveOptiScalerGameFiles(const AGameCfgDir: string);
var
  Dir: string;
begin
  Dir := IncludeTrailingPathDelimiter(AGameCfgDir);
  ExecuteShellCommand(
    'rm -f ' +
    QuotedStr(Dir + 'OptiScaler.dll') + ' ' +
    QuotedStr(Dir + 'OptiScaler.ini') + ' ' +
    QuotedStr(Dir + 'fakenvapi.dll') + ' ' +
    QuotedStr(Dir + 'fakenvapi.ini') + ' ' +
    QuotedStr(Dir + 'amd_fidelityfx_framegeneration_dx12.dll') + ' ' +
    QuotedStr(Dir + 'amd_fidelityfx_upscaler_dx12.dll') + ' ' +
    QuotedStr(Dir + 'amd_fidelityfx_vk.dll') + ' ' +
    QuotedStr(Dir + 'amd_fidelityfx_dx12.dll') + ' ' +
    QuotedStr(Dir + 'dlssg_to_fsr3_amd_is_better.dll') + ' ' +
    QuotedStr(Dir + 'libxess.dll') + ' ' +
    QuotedStr(Dir + 'libxess_dx11.dll') + ' ' +
    QuotedStr(Dir + 'libxess_fg.dll') + ' ' +
    QuotedStr(Dir + 'libxell.dll') + ' ' +
    QuotedStr(Dir + 'nvngx.dll') + ' ' +
    QuotedStr(Dir + 'nvngx_dlss.dll') + ' ' +
    QuotedStr(Dir + 'nvngx_dlssd.dll') + ' ' +
    QuotedStr(Dir + 'nvngx_dlssg.dll') + ' ' +
    QuotedStr(Dir + 'setup_linux.sh') + ' ' +
    QuotedStr(Dir + 'setup_windows.bat') + ' ' +
    QuotedStr(Dir + '!! README_EXTRACT ALL FILES TO GAME FOLDER !!.txt') + ' 2>/dev/null');
  ExecuteShellCommand(
    'rm -rf ' +
    QuotedStr(Dir + 'D3D12_OptiScaler') + ' ' +
    QuotedStr(Dir + 'Licenses') + ' ' +
    QuotedStr(Dir + 'plugins') + ' 2>/dev/null');
end;

procedure Tgoverlayform.CopyOptiScalerGameFiles(const AGameCfgDir: string);
begin
  // Copy all files from .fgmod_original (no-clobber for scripts already present)
  ExecuteShellCommand('cp -rn ' + QuotedStr(GetFGModOriginalPath) + '/. ' +
    QuotedStr(AGameCfgDir) + ' 2>/dev/null');
end;

procedure Tgoverlayform.PatchGameFGModWineDllOverrides(const AFGModFile: string; AEnabled: Boolean);
begin
  // Obsolete: bgmod handles OptiScaler overrides natively
end;

procedure Tgoverlayform.PatchGameFGModConditionalExport(
  const AFGModFile, AConditionalLine, ASearchKey: string);
begin
  // Obsolete: bgmod handles tool conditionals natively
end;

procedure Tgoverlayform.PatchGameFGModConfigPath(
  const AFGModFile, AEnvVar, AConfigPath: string);
var
  ConfigPath: string;
  Ini: TIniFile;
begin
  ConfigPath := ExtractFilePath(AFGModFile) + 'bgmod.conf';
  ForceDirectories(ExtractFilePath(ConfigPath));
  Ini := TIniFile.Create(ConfigPath);
  try
    Ini.WriteString('Env', AEnvVar, AConfigPath);
  finally
    Ini.Free;
  end;
end;

procedure Tgoverlayform.RestoreNavRailColors;
var
  i: Integer;
  IsLight: Boolean;
  BgActive, BgNormal, TextActive, TextInactive, ToggleColor: TColor;
begin
  if Length(FNavItems) = 0 then Exit;
  IsLight := CurrentTheme = tmLight;
  if IsLight then
  begin
    BgActive    := NAV_LIGHT_ACTIVE;
    BgNormal    := NAV_LIGHT_BG;
    TextActive  := clBlack;
    TextInactive := $00555555;
    ToggleColor := NAV_LIGHT_BG;
  end
  else
  begin
    BgActive    := NAV_COLOR_ACTIVE;
    BgNormal    := NAV_COLOR_BG;
    TextActive  := clWhite;
    TextInactive := $00AAAAAA;
    ToggleColor := $00221F1E;
  end;

  for i := 0 to High(FNavItems) do
  begin
    if i = FNavActive then
    begin
      FNavItems[i].Color       := BgActive;
      FNavIcons[i].Font.Color  := TextActive;
      FNavLabels[i].Font.Color := TextActive;
    end
    else
    begin
      FNavItems[i].Color       := BgNormal;
      FNavIcons[i].Font.Color  := TextInactive;
      FNavLabels[i].Font.Color := TextInactive;
    end;
    FNavItems[i].Invalidate;
  end;
  if Assigned(FNavToggleBtn) then
    FNavToggleBtn.Color := ToggleColor;
  if Assigned(FSettingsIconLbl) then
    FSettingsIconLbl.Font.Color := TextInactive;
end;

procedure Tgoverlayform.SetNavActive(AIndex: Integer);
var
  i: Integer;
  IconPath: string;
begin
  DbgLog(Format('  SetNavActive(%d) BEGIN', [AIndex]));
  FNavActive := AIndex;
  for i := 0 to High(FNavItems) do
  begin
    if i = AIndex then
    begin
      FNavIndicators[i].Visible     := True;
      FNavIndicators[i].Brush.Color := IfThen(i = 0, NAV_IND_GAMES, NAV_IND_TOOLS);
      FNavIndicators[i].Pen.Color   := IfThen(i = 0, NAV_IND_GAMES, NAV_IND_TOOLS);
      FNavIcons[i].Font.Color   := IfThen(CurrentTheme = tmLight, clBlack, clWhite);
      FNavLabels[i].Font.Color  := IfThen(CurrentTheme = tmLight, clBlack, clWhite);
      if (i = 3) and Assigned(FOptiScalerImg) then
      begin
        IconPath := GetAppBaseDir + 'assets/icons/scale-up2-active.png';
        if FileExists(IconPath) then
          try FOptiScalerImg.Picture.LoadFromFile(IconPath); except end;
      end;
      if (i = 1) and Assigned(FMangoHudImg) then
      begin
        IconPath := GetAppBaseDir + 'assets/icons/mango-active.png';
        if FileExists(IconPath) then
          try FMangoHudImg.Picture.LoadFromFile(IconPath); except end;
      end;
    end
    else
    begin
      FNavIndicators[i].Visible := False;
      FNavIcons[i].Font.Color   := IfThen(CurrentTheme = tmLight, $00555555, $00AAAAAA);
      FNavLabels[i].Font.Color  := IfThen(CurrentTheme = tmLight, $00555555, $00AAAAAA);
      if (i = 3) and Assigned(FOptiScalerImg) then
      begin
        IconPath := GetAppBaseDir + 'assets/icons/scale-up2.png';
        if FileExists(IconPath) then
          try FOptiScalerImg.Picture.LoadFromFile(IconPath); except end;
      end;
      if (i = 1) and Assigned(FMangoHudImg) then
      begin
        IconPath := GetAppBaseDir + 'assets/icons/mango-inactive.png';
        if FileExists(IconPath) then
          try FMangoHudImg.Picture.LoadFromFile(IconPath); except end;
      end;
    end;
    FNavItems[i].Invalidate;
  end;

  if FNavActive = 1 then
    StartCube
  else
    StopCube;
  DbgLog(Format('  SetNavActive(%d) END', [AIndex]));
end;

procedure Tgoverlayform.NavItemClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := (Sender as TControl).Tag;
  if Assigned(FNavClickCBs[Idx]) then
    FNavClickCBs[Idx](FNavItems[Idx]);
end;

procedure Tgoverlayform.NavItemMouseEnter(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := (Sender as TControl).Tag;
  FNavHoveredIdx := Idx;
  FNavItems[Idx].Invalidate;
end;

procedure Tgoverlayform.NavItemMouseLeave(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := (Sender as TControl).Tag;
  FNavHoveredIdx := -1;
  FNavItems[Idx].Invalidate;
end;

procedure Tgoverlayform.NavItemPaint(Sender: TObject);
var
  P: TPanel;
  Idx: Integer;
  BgColor: TColor;
begin
  P   := TPanel(Sender);
  Idx := P.Tag;
  if CurrentTheme = tmLight then
  begin
    if Idx = FNavActive then      BgColor := NAV_LIGHT_ACTIVE
    else if Idx = FNavHoveredIdx then BgColor := NAV_LIGHT_HOVER
    else                              BgColor := NAV_LIGHT_BG;
  end
  else
  begin
    if Idx = FNavActive then      BgColor := NAV_COLOR_ACTIVE
    else if Idx = FNavHoveredIdx then BgColor := NAV_COLOR_HOVER
    else                              BgColor := NAV_COLOR_BG;
  end;
  P.Canvas.Brush.Color := BgColor;
  P.Canvas.Brush.Style := bsSolid;
  P.Canvas.FillRect(P.ClientRect);
end;

procedure Tgoverlayform.ApplyNavCollapsed;
var
  NavW: Integer;
begin
  NavW := IfThen(FNavCollapsed, NAV_W_COLLAPSED, NAV_W_EXPANDED);
  FNavAnimCurrent := NavW * 10;
  ApplyNavWidth(NavW);

  if FNavCollapsed then
    FNavToggleBtn.Caption := '»'
  else
    FNavToggleBtn.Caption := '«';
end;

procedure Tgoverlayform.NavToggleClick(Sender: TObject);
var
  UIStateFile: string;
  SL: TStringList;
begin
  FNavCollapsed  := not FNavCollapsed;
  FNavAnimTarget := IfThen(FNavCollapsed, NAV_W_COLLAPSED, NAV_W_EXPANDED);
  FNavAnimTimer.Enabled := True;

  // Persist state for next session
  UIStateFile := IncludeTrailingPathDelimiter(TConfigManager.GetGoverlayFolder) + 'ui_state';
  SL := TStringList.Create;
  try
    SL.Add(IfThen(FNavCollapsed, '1', '0'));
    SL.Add(IfThen(FCubeAutoLaunch, '1', '0'));
    SL.SaveToFile(UIStateFile);
  finally
    SL.Free;
  end;
end;

procedure Tgoverlayform.NavAnimTick(Sender: TObject);
const
  EASE = 0.22; // fraction of remaining distance per tick (ease-out)
var
  PrevW, NextW: Integer;
begin
  PrevW := FNavAnimCurrent div 10;

  // Ease-out: move a fraction of remaining distance each tick
  FNavAnimCurrent := FNavAnimCurrent +
    Round((FNavAnimTarget * 10 - FNavAnimCurrent) * EASE);

  NextW := FNavAnimCurrent div 10;

  // Snap to target when close enough
  if Abs(NextW - FNavAnimTarget) <= 1 then
  begin
    FNavAnimCurrent := FNavAnimTarget * 10;
    FNavAnimTimer.Enabled := False;
    ApplyNavCollapsed;  // final state: show/hide labels etc.
    Exit;
  end;

  if NextW <> PrevW then
  begin
    DbgLog(Format('NavAnimTick: width %d -> %d', [PrevW, NextW]));
    ApplyNavWidth(NextW);
  end;
end;

procedure Tgoverlayform.ApplyNavWidth(AWidth: Integer);
var
  i, PanelLeft, ContentW: Integer;
  ShowLabels: Boolean;
begin
  DbgLog(Format('ApplyNavWidth(%d)', [AWidth]));
  PanelLeft  := AWidth;
  ShowLabels := AWidth > (NAV_W_COLLAPSED + NAV_W_EXPANDED) div 2;

  goverlayPaintBox.Width := AWidth;
  goverlayPanel.Left     := PanelLeft;
  goverlayPanel.Width    := Max(1, Self.ClientWidth - PanelLeft);

  for i := 0 to High(FNavItems) do
  begin
    FNavItems[i].Width   := AWidth;
    FNavIcons[i].Left    := IfThen(ShowLabels, 16, (AWidth - NAV_ICON_SIZE) div 2);
    // In collapsed+game mode the button sits below the icon, so shift icon up
    FNavIcons[i].Top     := IfThen(ShowLabels or (FActiveGameName = ''),
                              (NAV_ITEM_H - NAV_ICON_SIZE) div 2, 8);
    FNavLabels[i].Visible := ShowLabels;
  end;

  // Show/hide the Games↔Tools separator section

  UpdateNavToolToggleVisibility(ShowLabels);

  if Assigned(FMangoHudImg) then
  begin
    FMangoHudImg.Left := IfThen(ShowLabels, 18, (AWidth - 24) div 2);
    FMangoHudImg.Top  := IfThen(ShowLabels or (FActiveGameName = ''),
                           (NAV_ITEM_H - 24) div 2, 8);
  end;
  if Assigned(FOptiScalerImg) then
  begin
    FOptiScalerImg.Left := IfThen(ShowLabels, 18, (AWidth - 24) div 2);
    FOptiScalerImg.Top  := IfThen(ShowLabels or (FActiveGameName = ''),
                             (NAV_ITEM_H - 24) div 2, 8);
  end;

  FNavToggleBtn.Left := IfThen(ShowLabels, AWidth - 28, AWidth - 26);

  goverlayimage.Visible  := ShowLabels;
  FNavSmallIcon.Visible  := not ShowLabels;
  FNavSmallIcon.Left     := (AWidth - 40) div 2;

  // dependenciesLabel and dependencieSpeedButton are permanently hidden;
  // dependency status is shown in the settings menu instead.

  // Reflow all content tabs whenever the sidebar width changes
  ContentW := Max(1, Self.ClientWidth - AWidth);
  ReflowPresetTab(ContentW);
  ReflowVisualTab(ContentW);
  ReflowPerformanceTab(ContentW);
  ReflowMetricsTab(ContentW);
  ReflowExtrasTab(ContentW);
  ReflowOptiScalerTab(ContentW);
  ReflowOptiScalerTabNew(ContentW);
  ReflowVkBasaltTab(ContentW);
  ReflowVkSumiTab(ContentW);
  if FGamesLoaded then
    ReflowGamesGrid;

  // Repaint sidebar so the thumbnail scales with the nav width
  goverlayPaintBox.Invalidate;
end;

procedure Tgoverlayform.FormResize(Sender: TObject);
var
  NavW, ContentW: Integer;
begin
  DbgLog('  FormResize BEGIN');
  NavW     := goverlayPaintBox.Width;
  ContentW := Max(1, Self.ClientWidth - NavW);

  goverlayPanel.Left  := NavW;
  goverlayPanel.Width := ContentW;

  if Length(FNavItems) > 0 then
    ApplyNavWidth(NavW);

  ReflowPresetTab(ContentW);
  ReflowVisualTab(ContentW);
  ReflowPerformanceTab(ContentW);
  ReflowMetricsTab(ContentW);
  ReflowExtrasTab(ContentW);
  ReflowOptiScalerTab(ContentW);
  ReflowOptiScalerTabNew(ContentW);
  ReflowVkBasaltTab(ContentW);
  ReflowVkSumiTab(ContentW);

  if FGamesLoaded then
    ReflowGamesGrid;
end;

// ============================================================================
// TAB REFLOW — redistribute controls when the window is resized
// ============================================================================

procedure Tgoverlayform.ReflowPresetTab(AContentW: Integer);
const
  WRAPPER_W  = 829;
  PC_W       = 130;
  PC_H       = 140;
  PC_MIN_GAP = 8;
  HDR_H      = 24;    // approximate section header height
  CARD_PAD_T = 16;    // gap between header bottom and card row
  SEC_GAP    = 32;    // gap between card row bottom and next header
  CONTENT_H  = HDR_H + CARD_PAD_T + PC_H + SEC_GAP + HDR_H + CARD_PAD_T + PC_H; // 392
  MIN_TOP_PAD = 20;
var
  W, Gap5, StartX5, Gap4, StartX4, X, i: Integer;
  LayoutTop, ColorHdrTop, ColorTop, TopPad: Integer;
begin
  // Centre the fixed-width wrapper
  if Assigned(FPresetsWrapper) then
  begin
    FPresetsWrapper.Left   := Max(0, (AContentW - WRAPPER_W) div 2);
    FPresetsWrapper.Height := presetTabSheet.ClientHeight;
  end;

  if not Assigned(FPresetLayoutCards[0]) then Exit;

  W := WRAPPER_W;

  // Vertically centre the content block in the tab
  TopPad := Max(MIN_TOP_PAD, (presetTabSheet.ClientHeight - CONTENT_H) div 2 - 40);

  // ── Section 1: Layouts ───────────────────────────────────────────────────
  layoutsLabel.Left := 20;
  layoutsLabel.Top  := TopPad;
  LayoutTop         := TopPad + HDR_H + CARD_PAD_T;

  Gap5    := Max(PC_MIN_GAP, (W - 5 * PC_W) div 6);
  StartX5 := (W - 5 * PC_W - 4 * Gap5) div 2;
  for i := 0 to 4 do
  begin
    X := StartX5 + i * (PC_W + Gap5);
    FPresetLayoutCards[i].SetBounds(X, LayoutTop, PC_W, PC_H);
    FPresetLayoutSelBars[i].SetBounds(0, PC_H - 3, PC_W, 3);
  end;

  // ── Section 2: Color Theme ───────────────────────────────────────────────
  ColorHdrTop := LayoutTop + PC_H + SEC_GAP;
  colorthemeLabel.Left := 20;
  colorthemeLabel.Top  := ColorHdrTop;
  ColorTop := ColorHdrTop + HDR_H + CARD_PAD_T;

  Gap4    := Max(PC_MIN_GAP, (W - 4 * PC_W) div 5);
  StartX4 := (W - 4 * PC_W - 3 * Gap4) div 2;
  for i := 0 to 3 do
  begin
    X := StartX4 + i * (PC_W + Gap4);
    FPresetColorCards[i].SetBounds(X, ColorTop, PC_W, PC_H);
    FPresetColorSelBars[i].SetBounds(0, PC_H - 3, PC_W, 3);
  end;

  // Section headers adapt to the active theme; card label colors are fixed
  // inside PresetCardPaint since cards have their own painted background.
  if CurrentTheme = tmLight then
  begin
    layoutsLabel.Font.Color    := LightTextColor;
    colorthemeLabel.Font.Color := LightTextColor;
  end
  else
  begin
    layoutsLabel.Font.Color    := DarkTextColor;
    colorthemeLabel.Font.Color := DarkTextColor;
  end;

  // Refresh card visuals (colours + selection bars) for the current theme
  UpdatePresetCardVisuals;
end;

// ============================================================================
// VISUAL TAB — card redesign
// ============================================================================

procedure Tgoverlayform.VisualCardPaint(Sender: TObject);
const
  // Dark theme
  DARK_BG     = $00362E2E;   // RGB( 46, 46, 54) dark panel
  DARK_BRD    = $005A5050;   // RGB( 80, 80, 90)
  // Light theme
  LIGHT_BG    = $00FFFFFF;   // pure white
  LIGHT_BRD   = $00C8C0C0;   // RGB(192,192,200)
var
  Card: TPanel;
  BgColor, BorderColor: TColor;
begin
  if not (Sender is TPanel) then Exit;
  Card := TPanel(Sender);

  if CurrentTheme = tmLight then
  begin
    BgColor     := LIGHT_BG;
    BorderColor := LIGHT_BRD;
  end
  else
  begin
    BgColor     := DARK_BG;
    BorderColor := DARK_BRD;
  end;

  Card.Canvas.Brush.Color := BgColor;
  Card.Canvas.Brush.Style := bsSolid;
  Card.Canvas.FillRect(Card.ClientRect);

  Card.Canvas.Brush.Style := bsClear;
  Card.Canvas.Pen.Color   := BorderColor;
  Card.Canvas.Pen.Width   := 1;
  Card.Canvas.Rectangle(0, 0, Card.Width, Card.Height);
end;

procedure Tgoverlayform.PerfCardPaint(Sender: TObject);
// Option B card style: elevated blue-gray fill + subtle blue border + cyan top accent
const
  DARK_BG   = $002E1E1A;  // rgb(26, 30, 46)
  DARK_BRD  = $003E2824;  // rgb(36, 40, 62)
  LIGHT_BG  = $00F0F0F0;  // rgb(240, 240, 240)
  LIGHT_BRD = $00D0D0D0;  // rgb(208, 208, 208)
  CYAN_H    = 2;
  CYAN_CLR  = $00F0BE30;  // rgb(48, 190, 240)
var
  Card: TPanel;
  CardBg, CardBrd: TColor;
begin
  if not (Sender is TPanel) then Exit;
  Card := TPanel(Sender);
  if CurrentTheme = tmLight then
  begin
    CardBg  := LIGHT_BG;
    CardBrd := LIGHT_BRD;
  end
  else
  begin
    CardBg  := DARK_BG;
    CardBrd := DARK_BRD;
  end;

  // Fill background
  Card.Canvas.Brush.Color := CardBg;
  Card.Canvas.Brush.Style := bsSolid;
  Card.Canvas.FillRect(Card.ClientRect);

  // Border (all four sides)
  Card.Canvas.Brush.Style := bsClear;
  Card.Canvas.Pen.Color   := CardBrd;
  Card.Canvas.Pen.Width   := 1;
  Card.Canvas.Rectangle(0, 0, Card.Width, Card.Height);

  // Cyan top accent stripe
  Card.Canvas.Brush.Color := CYAN_CLR;
  Card.Canvas.Brush.Style := bsSolid;
  Card.Canvas.Pen.Style   := psClear;
  Card.Canvas.FillRect(Rect(0, 0, Card.Width, CYAN_H));
  Card.Canvas.Pen.Style   := psSolid;
end;

procedure Tgoverlayform.SubCardPaint(Sender: TObject);
// Sub-section style: same blue-gray fill + very subtle border, no cyan accent.
const
  DARK_BG   = $002E1E1A;  // rgb(26, 30, 46)
  DARK_BRD  = $00342620;  // rgb(32, 38, 52)
  LIGHT_BG  = $00F0F0F0;  // rgb(240, 240, 240)
  LIGHT_BRD = $00E0E0E0;  // rgb(224, 224, 224)
var
  P: TPanel;
  Bg, Brd: TColor;
begin
  if not (Sender is TPanel) then Exit;
  P := TPanel(Sender);
  if CurrentTheme = tmLight then
  begin
    Bg  := LIGHT_BG;
    Brd := LIGHT_BRD;
  end
  else
  begin
    Bg  := DARK_BG;
    Brd := DARK_BRD;
  end;
  P.Canvas.Brush.Color := Bg;
  P.Canvas.Brush.Style := bsSolid;
  P.Canvas.FillRect(P.ClientRect);
  P.Canvas.Brush.Style := bsClear;
  P.Canvas.Pen.Color   := Brd;
  P.Canvas.Pen.Width   := 1;
  P.Canvas.Rectangle(0, 0, P.Width, P.Height);
end;

procedure Tgoverlayform.UpdateVisualCardTheme;
begin
  TMangoHudUiHelper(FMangoHelper).UpdateVisualCardTheme;
end;

function IsX11ModifierPressed(Keysym: LongWord): Boolean;
var
  d: PDisplay;
  keys: array[0..31] of Char;
  keycode: Byte;
begin
  Result := False;
  FillChar(keys, SizeOf(keys), 0);
  d := XOpenDisplay(nil);
  if d <> nil then
  begin
    keycode := XKeysymToKeycode(d, Keysym);
    if keycode <> 0 then
    begin
      XQueryKeymap(d, keys);
      Result := (Byte(keys[keycode div 8]) and (1 shl (keycode mod 8))) <> 0;
    end;
    XCloseDisplay(d);
  end;
end;

// ============================================================================
// KEYBIND CAPTURE
// ============================================================================

procedure Tgoverlayform.CaptureFormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  KeyStr, ModStr, FinalStr: string;
begin
  KeyStr := '';
  ModStr := '';

  if Key = VK_ESCAPE then
  begin
    if Assigned(FCaptureForm) then
      FCaptureForm.ModalResult := mrCancel;
    Key := 0;
    Exit;
  end;

  // Ignore pure modifier presses until a real key is pressed
  if (Key = VK_SHIFT) or (Key = VK_CONTROL) or (Key = VK_MENU) or (Key = VK_LWIN) or (Key = VK_RWIN) then
    Exit;

  // ── OptiScaler path (tag=5): store Windows VK hex directly, bypass X11 naming
  if Assigned(FCaptureBtn) and (FCaptureBtn.Tag = 5) then
  begin
    shortcutkeyComboBox.Text  := Format('0x%.2x', [Key]);
    FCaptureBtn.Caption       := '⌨ ' + OsHexToKeyStr(shortcutkeyComboBox.Text);
    if Assigned(FCaptureForm) then
      FCaptureForm.ModalResult := mrOk;
    Key := 0;
    Exit;
  end;

  // ── MangoHud / vkBasalt path: X11 Keysym format with optional modifiers
  if ssShift in Shift then
  begin
    if IsX11ModifierPressed($FFE2) then
      ModStr := ModStr + 'Shift_R+'
    else
      ModStr := ModStr + 'Shift_L+';
  end;
  if ssCtrl  in Shift then
  begin
    if IsX11ModifierPressed($FFE4) then
      ModStr := ModStr + 'Control_R+'
    else
      ModStr := ModStr + 'Control_L+';
  end;
  if ssAlt   in Shift then
  begin
    if IsX11ModifierPressed($FFEa) or IsX11ModifierPressed($FE03) then
      ModStr := ModStr + 'Alt_R+'
    else
      ModStr := ModStr + 'Alt_L+';
  end;
  if ssSuper in Shift then
  begin
    if IsX11ModifierPressed($FFEC) then
      ModStr := ModStr + 'Super_R+'
    else
      ModStr := ModStr + 'Super_L+';
  end;

  if (Key >= VK_A) and (Key <= VK_Z) then
    KeyStr := Chr(Key)
  else if (Key >= VK_0) and (Key <= VK_9) then
    KeyStr := Chr(Key)
  else if (Key >= VK_NUMPAD0) and (Key <= VK_NUMPAD9) then
    KeyStr := 'KP_' + IntToStr(Key - VK_NUMPAD0)
  else if (Key >= VK_F1) and (Key <= VK_F24) then
    KeyStr := 'F' + IntToStr(Key - VK_F1 + 1)
  else
  begin
    case Key of
      VK_SPACE:  KeyStr := 'space';
      VK_RETURN: KeyStr := 'Return';
      VK_TAB:    KeyStr := 'Tab';
      VK_INSERT: KeyStr := 'Insert';
      VK_DELETE: KeyStr := 'Delete';
      VK_HOME:   KeyStr := 'Home';
      VK_END:    KeyStr := 'End';
      VK_PRIOR:  KeyStr := 'Page_Up';
      VK_NEXT:   KeyStr := 'Page_Down';
      VK_UP:     KeyStr := 'Up';
      VK_DOWN:   KeyStr := 'Down';
      VK_LEFT:   KeyStr := 'Left';
      VK_RIGHT:  KeyStr := 'Right';
      186:       KeyStr := 'semicolon';
      188:       KeyStr := 'comma';
      190:       KeyStr := 'period';
    else
      Exit;
    end;
  end;

  FinalStr := ModStr + KeyStr;

  if Assigned(FCaptureBtn) then
  begin
    FCaptureBtn.Caption := '⌨ ' + FinalStr;
    if FCaptureBtn.Tag = 1 then hudonoffComboBox.Text      := FinalStr
    else if FCaptureBtn.Tag = 2 then fpslimtoggleComboBox.Text := FinalStr
    else if FCaptureBtn.Tag = 3 then logtoggleComboBox.Text    := FinalStr
    else if FCaptureBtn.Tag = 4 then vkbtogglekeyCombobox.Text := FinalStr
    else if FCaptureBtn.Tag = 6 then FVsToggleEdit.Text        := FinalStr;
  end;

  if Assigned(FCaptureForm) then
    FCaptureForm.ModalResult := mrOk;
  
  Key := 0; // Mark as handled
end;

procedure Tgoverlayform.CaptureBtnClick(Sender: TObject);
var
  Lbl: TLabel;
begin
  if not Assigned(Sender) then Exit;
  
  // The clicked button is both the trigger and the display target
  FCaptureBtn := TBitBtn(Sender);

  FCaptureForm := TForm.Create(Self);
  try
    FCaptureForm.Position := poMainFormCenter;
    FCaptureForm.Width := 340;
    FCaptureForm.Height := 100;
    FCaptureForm.BorderStyle := bsSingle;
    FCaptureForm.BorderIcons := [biSystemMenu];
    FCaptureForm.Caption := 'Capture Key';
    FCaptureForm.Color := IfThen(CurrentTheme = tmLight, clWhite, $00362E2E);
    FCaptureForm.KeyPreview := True;
    FCaptureForm.OnKeyDown := @CaptureFormKeyDown;

    Lbl := TLabel.Create(FCaptureForm);
    Lbl.Parent := FCaptureForm;
    Lbl.AutoSize := False;
    Lbl.Align := alClient;
    Lbl.Alignment := taCenter;
    Lbl.Layout := tlCenter;
    Lbl.WordWrap := True;
    Lbl.Font.Name := 'Noto Sans';
    Lbl.Font.Size := 10;
    Lbl.Font.Color := IfThen(CurrentTheme = tmLight, LightTextColor, DarkTextColor);
    Lbl.Caption := 'Press the key combination you want to use as shortcut.' + sLineBreak + '(Press ESC to cancel)';

    FCaptureForm.ShowModal;
  finally
    FCaptureForm.Free;
    FCaptureForm := nil;
  end;
end;

procedure Tgoverlayform.InitVisualTab;
begin
  TMangoHudUiHelper(FMangoHelper).InitVisualTab;
end;

procedure Tgoverlayform.ReflowVisualTab(AContentW: Integer);
begin
  TMangoHudUiHelper(FMangoHelper).ReflowVisualTab(AContentW);
end;

procedure Tgoverlayform.BuildFpsLimitEdit;
begin
  TMangoHudUiHelper(FMangoHelper).BuildFpsLimitEdit;
end;

procedure Tgoverlayform.InitPerformanceTab;
begin
  TMangoHudUiHelper(FMangoHelper).InitPerformanceTab;
end;

procedure Tgoverlayform.InitExtrasTab;
begin
  TMangoHudUiHelper(FMangoHelper).InitExtrasTab;
end;

procedure Tgoverlayform.UpdatePerfCardTheme;
begin
  TMangoHudUiHelper(FMangoHelper).UpdatePerfCardTheme;
end;

procedure Tgoverlayform.UpdateGenericCardTheme(Card: TPanel);
const
  DARK_BG   = $002E1E1A;  // matches SubCardPaint / PerfCardPaint dark fill
  LIGHT_BG  = $00F0F0F0;  // matches SubCardPaint / PerfCardPaint light fill
var
  j: Integer;
  CardBg, TextColor: TColor;
  SS: WideString;
begin
  if not Assigned(Card) then Exit;

  if CurrentTheme = tmLight then
  begin
    CardBg    := LIGHT_BG;
    TextColor := LightTextColor;
  end
  else
  begin
    CardBg    := DARK_BG;
    TextColor := DarkTextColor;
  end;

  Card.Color := CardBg;
  Card.Invalidate;
  for j := 0 to Card.ControlCount - 1 do
  begin
    if Card.Controls[j] is TLabel then
    begin
      TLabel(Card.Controls[j]).Font.Color := TextColor;
    end
    else if Card.Controls[j] is TCheckBox then
    begin
      TCheckBox(Card.Controls[j]).ParentColor := True;
      TCheckBox(Card.Controls[j]).Font.Color := TextColor;
    end
    else if Card.Controls[j] is TRadioButton then
    begin
      TRadioButton(Card.Controls[j]).ParentColor := True;
      TRadioButton(Card.Controls[j]).Font.Color := TextColor;
    end
    else if Card.Controls[j] is TComboBox then
    begin
      TComboBox(Card.Controls[j]).Font.Color := TextColor;
      if CurrentTheme = tmLight then
        TComboBox(Card.Controls[j]).Color := LighterBackgroundColor
      else
        TComboBox(Card.Controls[j]).Color := RGBToColor(34, 38, 52);
    end
    else if Card.Controls[j] is TEdit then
    begin
      TEdit(Card.Controls[j]).Font.Color := TextColor;
      if CurrentTheme = tmLight then
      begin
        TEdit(Card.Controls[j]).Color := LighterBackgroundColor;
        SS := 'QLineEdit { background-color: rgb(245,245,245); color: rgb(0,0,0); border: 1px solid rgb(210,210,210); border-radius: 4px; padding: 2px; }';
      end
      else
      begin
        TEdit(Card.Controls[j]).Color := RGBToColor(46, 46, 46);
        SS := 'QLineEdit { background-color: rgb(46,46,46); color: rgb(255,255,255); border: 1px solid rgb(80,80,80); border-radius: 4px; padding: 2px; }';
      end;
      QWidget_setStyleSheet(TQtWidget(TEdit(Card.Controls[j]).Handle).Widget, @SS);
    end
    else if Card.Controls[j] is TGroupBox then
    begin
      TGroupBox(Card.Controls[j]).Color      := CardBg;
      TGroupBox(Card.Controls[j]).Font.Color := TextColor;
    end;
  end;

  // Force QCheckBox background transparent via Qt stylesheet
  if CurrentTheme = tmLight then
    SS := 'QCheckBox { color: rgb(0,0,0); background-color: transparent; }'
  else
    SS := 'QCheckBox { color: rgb(255,255,255); background-color: transparent; }';
  QWidget_setStyleSheet(TQtWidget(Card.Handle).Widget, @SS);
end;

procedure Tgoverlayform.UpdateExtrasCardTheme;
begin
  TMangoHudUiHelper(FMangoHelper).UpdateExtrasCardTheme;
end;

procedure Tgoverlayform.ReflowPerformanceTab(AContentW: Integer);
begin
  TMangoHudUiHelper(FMangoHelper).ReflowPerformanceTab(AContentW);
end;

procedure Tgoverlayform.ReflowOptiScalerTab(AContentW: Integer);
const
  // Lateral boxes have fixed widths; ImGUI Menu fills the center.
  // At base AContentW=828 the ImGUI center (410px) coincides with the
  // optionsGroupBox center (820/2=410), so we use that as the anchor.
  W1      = 252;   // optiscalerGroupBox — fixed width, left-anchored
  // Note: when the card redesign is active (FOsScrollBox assigned) this
  // procedure is called from ReflowOptiScalerTabNew with the card's inner
  // width, so the guard below is not needed — it's a no-op safety net.
  W3      = 252;   // fakenvapiGroupBox  — fixed width, right-anchored
  W2_BASE = 300;   // imgmenuGroupBox    — grows with available space
  BOX_H   = 251;
  BOX_TOP = 6;
  MARGIN  = 4;
  GAP     = 4;
  MIN_W2  = 180;
var
  InnerW, Center, W2, X1, X2, X3: Integer;
begin
  // When card redesign is active, ReflowOptiScalerTabNew drives the
  // inner layout directly — skip this call to avoid double-positioning.
  if Assigned(FOsScrollBox) then Exit;

  // optionsGroupBox ClientWidth ≈ AContentW - 8
  InnerW := AContentW - 8;
  Center := InnerW div 2;

  // Position imgmenu centered on the content area; expand symmetrically outward
  W2 := Max(MIN_W2, InnerW - MARGIN - W1 - GAP - W3 - MARGIN - GAP);
  X2 := Center - W2 div 2;

  // If centering would clip the left box, fall back to left-flush layout
  if X2 - GAP - W1 < MARGIN then
    X2 := MARGIN + W1 + GAP;

  X1 := X2 - GAP - W1;
  X3 := X2 + W2 + GAP;

  optiscalerGroupBox.SetBounds(X1, BOX_TOP, W1, BOX_H);
  imgmenuGroupBox.SetBounds(X2, BOX_TOP, W2, BOX_H);
  fakenvapiGroupBox.SetBounds(X3, BOX_TOP, W3, BOX_H);
end;

// ============================================================================
// OPTISCALER TAB — card redesign (GroupBox-level reparenting)
// ============================================================================

procedure Tgoverlayform.InitOptiScalerTab;
begin
  TOptiScalerTabHelper(FOptiScalerHelper).InitOptiScalerTab;
end;

procedure Tgoverlayform.RefreshOsStatusDots;
begin
  TOptiScalerTabHelper(FOptiScalerHelper).RefreshOsStatusDots;
end;

procedure Tgoverlayform.ReflowOptiScalerTabNew(AContentW: Integer);
begin
  TOptiScalerTabHelper(FOptiScalerHelper).ReflowOptiScalerTabNew(AContentW);
end;


// ============================================================================
// METRICS TAB — modern card redesign
// ============================================================================

procedure Tgoverlayform.InitMetricsTab;
begin
  TMangoHudUiHelper(FMangoHelper).InitMetricsTab;
end;

procedure Tgoverlayform.ReflowMetricsTab(AContentW: Integer);
begin
  TMangoHudUiHelper(FMangoHelper).ReflowMetricsTab(AContentW);
end;

procedure Tgoverlayform.ReflowExtrasTab(AContentW: Integer);
begin
  TMangoHudUiHelper(FMangoHelper).ReflowExtrasTab(AContentW);
end;

procedure Tgoverlayform.InitTweaksCards;
const
  BG   = $002E1E1A;
  HDR  = 35;   // accent bar (3) + title area
  SHDR = 22;   // section-title height offset added to each reparented control
  GAP  = 4;
var
  BgBox: TPaintBox;
  BasicCard, AdvCard: TPanel;
  GenSec, GfxSec, PerfSec: TPanel;
  Bar: TPanel;
  Lbl: TLabel;
  HalfW: Integer;
  i: Integer;
  procedure MakeBar(ACard: TPanel);
  begin
    Bar := TPanel.Create(ACard);
    Bar.Parent     := ACard;
    Bar.BevelOuter := bvNone;
    Bar.Caption    := '';
    Bar.Color      := RGBToColor(48, 190, 240);
    Bar.SetBounds(0, 0, ACard.Width, 3);
    Bar.Anchors    := [akLeft, akRight, akTop];
  end;
  procedure MakeLbl(ACard: TPanel; const ACaption: string);
  begin
    Lbl := TLabel.Create(ACard);
    Lbl.Parent      := ACard;
    Lbl.Caption     := ACaption;
    Lbl.Font.Color  := clWhite;
    Lbl.Font.Size   := 10;
    Lbl.Font.Style  := [fsBold];
    Lbl.AutoSize    := True;
    Lbl.SetBounds(12, 8, 250, 22);
    Lbl.Transparent := True;
  end;
  function MakeSec(ACard: TPanel; const ATitle: string;
                   ALeft, ATop, AWidth, AHeight: Integer): TPanel;
  var SLbl: TLabel;
  begin
    Result := TPanel.Create(ACard);
    Result.Parent      := ACard;
    Result.BevelOuter  := bvNone;
    Result.BorderStyle := bsNone;
    Result.Caption     := '';
    Result.Color       := BG;
    Result.OnPaint     := @SubCardPaint;
    Result.SetBounds(ALeft, ATop, AWidth, AHeight);
    Result.Anchors     := [akLeft, akTop, akRight, akBottom];
    SLbl := TLabel.Create(Result);
    SLbl.Parent      := Result;
    SLbl.Caption     := ATitle;
    SLbl.Font.Color  := $00CCAAAA;
    SLbl.Font.Style  := [fsBold];
    SLbl.Font.Size   := 8;
    SLbl.Left        := 6;
    SLbl.Top         := 4;
    SLbl.Transparent := True;
    SLbl.AutoSize    := True;
  end;
  procedure ReparentTo(C: TControl; APanel: TPanel);
  begin
    C.AnchorSideLeft.Control   := nil;
    C.AnchorSideTop.Control    := nil;
    C.AnchorSideRight.Control  := nil;
    C.AnchorSideBottom.Control := nil;
    C.Anchors := [akLeft, akTop];
    C.Top     := C.Top + SHDR;
    C.Parent  := APanel;
  end;
  procedure DarkChk(C: TCheckBox);
  begin
    C.ParentColor := False; C.Color := BG; C.Font.Color := clWhite; C.Font.Size := 9;
  end;
begin
  BgBox := TPaintBox.Create(Self);
  BgBox.Parent  := tweaksTabSheet;
  BgBox.Align   := alClient;
  BgBox.OnPaint := @PresetsBgBoxPaint;

  // ── Basic Tweaks card ──
  BasicCard := TPanel.Create(Self);
  BasicCard.Parent     := tweaksTabSheet;
  BasicCard.BevelOuter := bvNone;
  BasicCard.Caption    := '';
  BasicCard.Color      := BG;
  BasicCard.OnPaint    := @PerfCardPaint;
  BasicCard.SetBounds(2, 2, tweaksTabSheet.ClientWidth - 4, 182);
  BasicCard.Anchors    := [akLeft, akTop, akRight];
  MakeBar(BasicCard);
  MakeLbl(BasicCard, 'Basic Tweaks');

  HalfW  := (BasicCard.Width - 12) div 2;
  GenSec := MakeSec(BasicCard, 'General',  4,            HDR + GAP, HalfW, 182 - HDR - GAP - 4);
  GfxSec := MakeSec(BasicCard, 'Graphics', 4 + HalfW + 4, HDR + GAP, HalfW, 182 - HDR - GAP - 4);

  // General controls → GenSec
  ReparentTo(simdeckCheckBox,       GenSec); DarkChk(simdeckCheckBox);       simdeckCheckBox.OnChange       := @TweaksCheckChange;
  ReparentTo(enhdrCheckBox,         GenSec); DarkChk(enhdrCheckBox);         enhdrCheckBox.OnChange         := @TweaksCheckChange;
  ReparentTo(actprotonlogsCheckBox, GenSec); DarkChk(actprotonlogsCheckBox); actprotonlogsCheckBox.OnChange := @TweaksCheckChange;
  ReparentTo(gamemodeCheckBox,      GenSec); DarkChk(gamemodeCheckBox);      gamemodeCheckBox.OnChange      := @TweaksCheckChange;
  ReparentTo(enwaylandCheckBox,     GenSec); DarkChk(enwaylandCheckBox);     enwaylandCheckBox.OnChange     := @TweaksCheckChange;
  ReparentTo(usesdlCheckBox,        GenSec); DarkChk(usesdlCheckBox);        usesdlCheckBox.OnChange        := @TweaksCheckChange;

  // Graphics controls → GfxSec
  ReparentTo(emurtCheckBox,         GfxSec); DarkChk(emurtCheckBox);         emurtCheckBox.OnChange         := @TweaksCheckChange;
  ReparentTo(forcenvapiCheckBox,    GfxSec); DarkChk(forcenvapiCheckBox);    forcenvapiCheckBox.OnChange    := @TweaksCheckChange;
  ReparentTo(forcezinkCheckBox,     GfxSec); DarkChk(forcezinkCheckBox);     forcezinkCheckBox.OnChange     := @TweaksCheckChange;
  ReparentTo(hidenvidiaCheckBox,    GfxSec); DarkChk(hidenvidiaCheckBox);    hidenvidiaCheckBox.OnChange    := @TweaksCheckChange;
  ReparentTo(wined3dCheckBox,       GfxSec); DarkChk(wined3dCheckBox);       wined3dCheckBox.OnChange       := @TweaksCheckChange;
  ReparentTo(nofastclearsCheckBox,  GfxSec); DarkChk(nofastclearsCheckBox);  nofastclearsCheckBox.OnChange  := @TweaksCheckChange;

  basicGroupBox.Visible := False;

  // ── Advanced Tweaks card ──
  AdvCard := TPanel.Create(Self);
  AdvCard.Parent     := tweaksTabSheet;
  AdvCard.BevelOuter := bvNone;
  AdvCard.Caption    := '';
  AdvCard.Color      := BG;
  AdvCard.OnPaint    := @PerfCardPaint;
  AdvCard.SetBounds(2, 189, tweaksTabSheet.ClientWidth - 4, 184);
  AdvCard.Anchors    := [akLeft, akTop, akRight];
  MakeBar(AdvCard);
  MakeLbl(AdvCard, 'Advanced Tweaks');

  HalfW   := (AdvCard.Width - 12) div 2;
  PerfSec := MakeSec(AdvCard, 'Performance', 4,             HDR + GAP, HalfW, 184 - HDR - GAP - 4);
  FCustomSec := MakeSec(AdvCard, 'Custom',   4 + HalfW + 4, HDR + GAP,
                         AdvCard.Width - HalfW - 16, 184 - HDR - GAP - 4);

  // Performance controls → PerfSec
  ReparentTo(highpriCheckBox,       PerfSec); DarkChk(highpriCheckBox);       highpriCheckBox.OnChange       := @TweaksCheckChange;
  ReparentTo(largeaddressCheckBox,  PerfSec); DarkChk(largeaddressCheckBox);  largeaddressCheckBox.OnChange  := @TweaksCheckChange;
  ReparentTo(stagememCheckBox,      PerfSec); DarkChk(stagememCheckBox);       stagememCheckBox.OnChange      := @TweaksCheckChange;
  ReparentTo(wow64CheckBox,         PerfSec); DarkChk(wow64CheckBox);          wow64CheckBox.OnChange         := @TweaksCheckChange;
  ReparentTo(disablentsyncCheckBox, PerfSec); DarkChk(disablentsyncCheckBox);  disablentsyncCheckBox.OnChange := @TweaksCheckChange;
  ReparentTo(heapdelayCheckBox,     PerfSec); DarkChk(heapdelayCheckBox);      heapdelayCheckBox.OnChange     := @TweaksCheckChange;

  advancedGroupBox.Visible := False;

  // Hide old cards — grid will replace them
  BasicCard.Visible := False;
  AdvCard.Visible   := False;
  FCustomSec.Visible := False;

  // ── MD3-style custom tweaks list ──
  InitTweaksMD3;
end;

procedure Tgoverlayform.InitVkBasaltTab;
begin
  TVkBasaltTabHelper(FBasaltHelper).InitVkBasaltTab;
end;

procedure Tgoverlayform.ReflowVkBasaltTab(AContentW: Integer);
begin
  TVkBasaltTabHelper(FBasaltHelper).ReflowVkBasaltTab(AContentW);
end;

procedure Tgoverlayform.ReflowVkSumiTab(AContentW: Integer);
begin
  TVkBasaltTabHelper(FBasaltHelper).ReflowVkSumiTab(AContentW);
end;

procedure Tgoverlayform.ReflowSliderInSection(ASec: TPanel; AIndex: Integer);
const
  SEC_PAD = 8;
  LBL_W   = 100;
var
  AvailW: Integer;
begin
  if not Assigned(FVsTrackbars[AIndex]) then Exit;
  AvailW := ASec.Width - 2 * SEC_PAD;
  FVsTrackbars[AIndex].Left  := SEC_PAD + LBL_W;
  if Assigned(FVsValLabels[AIndex]) then
  begin
    FVsValLabels[AIndex].Left  := AvailW - 40;
    FVsTrackbars[AIndex].Width := FVsValLabels[AIndex].Left - FVsTrackbars[AIndex].Left - 8;
  end;
end;

// ============================================================================
// GAMES TAB — Steam installed games grid
// ============================================================================
// VKBASALT RESHADE EFFECTS — MD3-style owner-drawn list with toggles
// ============================================================================

procedure Tgoverlayform.VkReshadeMD3Paint(Sender: TObject);
begin
  TVkBasaltTabHelper(FBasaltHelper).VkReshadeMD3Paint(Sender);
end;

procedure Tgoverlayform.VkReshadeMD3MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  TVkBasaltTabHelper(FBasaltHelper).VkReshadeMD3MouseMove(Sender, Shift, X, Y);
end;

procedure Tgoverlayform.VkReshadeMD3MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  TVkBasaltTabHelper(FBasaltHelper).VkReshadeMD3MouseDown(Sender, Button, Shift, X, Y);
end;

procedure Tgoverlayform.VkReshadeMD3MouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  TVkBasaltTabHelper(FBasaltHelper).VkReshadeMD3MouseWheel(Sender, Shift, WheelDelta, MousePos, Handled);
end;

procedure Tgoverlayform.VkReshadeMD3ScrollChange(Sender: TObject);
begin
  TVkBasaltTabHelper(FBasaltHelper).VkReshadeMD3ScrollChange(Sender);
end;

procedure Tgoverlayform.InitGamesTab;
begin
  TGamesTabHelper(FGamesHelper).InitGamesTab;
end;
function Tgoverlayform.GetAppBaseDir: string;
var
  AppDir, BinaryDir: string;
begin
  AppDir := GetEnvironmentVariable('APPDIR');
  if AppDir <> '' then
    Result := IncludeTrailingPathDelimiter(AppDir) + 'bin/'
  else
  begin
    BinaryDir := ExtractFilePath(Application.ExeName);
    if DirectoryExists(BinaryDir + 'assets') then
      Result := BinaryDir
    else
      Result := ExtractFilePath(ExtractFileDir(Application.ExeName)) + 'share/goverlay/';
  end;
end;

procedure Tgoverlayform.GetSteamLibraries(Libraries: TStringList);
var
  HomeDir, VdfPath, LibPath, Line: string;
  VdfFile: TStringList;
  i, p1, p2, p3, p4: Integer;

  procedure AddLibrary(const APath: string);
  var
    Info, ExistingInfo: BaseUnix.Stat;
    j: Integer;
    ExistingPath: string;
  begin
    if not DirectoryExists(APath) then
      Exit;
    if BaseUnix.fpStat(APath, Info) <> 0 then
      Exit;
    // Check against already-added libraries using (st_dev, st_ino)
    for j := 0 to Libraries.Count - 1 do
    begin
      ExistingPath := Libraries[j];
      if (BaseUnix.fpStat(ExistingPath, ExistingInfo) = 0) and
         (Info.st_dev = ExistingInfo.st_dev) and
         (Info.st_ino = ExistingInfo.st_ino) then
        Exit; // same physical directory
    end;
    Libraries.Add(APath);
  end;

begin
  if IsRunningInFlatpak then
    HomeDir := IncludeTrailingPathDelimiter(GetUserDir)  // real user home via getpwuid
  else
    HomeDir := IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME'));

  // Native Steam
  AddLibrary(HomeDir + '.local/share/Steam/steamapps');

  // Flatpak Steam
  AddLibrary(HomeDir + '.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps');

  // Parse libraryfolders.vdf for additional library paths
  VdfPath := HomeDir + '.local/share/Steam/steamapps/libraryfolders.vdf';
  if not FileExists(VdfPath) then
    VdfPath := HomeDir + '.steam/steam/steamapps/libraryfolders.vdf';
  if not FileExists(VdfPath) then
    Exit;

  VdfFile := TStringList.Create;
  try
    VdfFile.LoadFromFile(VdfPath);
    for i := 0 to VdfFile.Count - 1 do
    begin
      Line := Trim(VdfFile[i]);
      if Copy(LowerCase(Line), 1, 6) = '"path"' then
      begin
        // Format: "path"    "/some/path"
        p1 := Pos('"', Line);
        p2 := PosEx('"', Line, p1 + 1);
        p3 := PosEx('"', Line, p2 + 1);
        p4 := PosEx('"', Line, p3 + 1);
        if (p3 > 0) and (p4 > p3) then
        begin
          LibPath := Copy(Line, p3 + 1, p4 - p3 - 1) + '/steamapps';
          AddLibrary(LibPath);
        end;
      end;
    end;
  finally
    VdfFile.Free;
  end;
end;

function Tgoverlayform.ParseAcfValue(const AContent, AKey: string): string;
var
  Lines: TStringList;
  Line, Pattern: string;
  i, p1, p2: Integer;
begin
  Result := '';
  Pattern := LowerCase('"' + AKey + '"');
  Lines := TStringList.Create;
  try
    Lines.Text := AContent;
    for i := 0 to Lines.Count - 1 do
    begin
      Line := Trim(Lines[i]);
      if Copy(LowerCase(Line), 1, Length(Pattern)) = Pattern then
      begin
        // Extract the second quoted value on this line
        p1 := Pos('"', Line);
        p2 := PosEx('"', Line, p1 + 1);
        p1 := PosEx('"', Line, p2 + 1);
        p2 := PosEx('"', Line, p1 + 1);
        if (p1 > 0) and (p2 > p1) then
        begin
          Result := Copy(Line, p1 + 1, p2 - p1 - 1);
          Exit;
        end;
      end;
    end;
  finally
    Lines.Free;
  end;
end;

// Applies the bottom gradient to a cover bitmap (raw byte access for speed).
function BreakGameName(const Name: string): string;
const
  MAX_CH = 19;
var
  Words: TStringList;
  Line, W: string;
  i: Integer;
begin
  Words := TStringList.Create;
  try
    Words.Delimiter := ' ';
    Words.StrictDelimiter := True;
    Words.DelimitedText := Name;
    Result := '';
    Line   := '';
    for i := 0 to Words.Count - 1 do
    begin
      W := Words[i];
      if Line = '' then
        Line := W
      else if Length(Line) + 1 + Length(W) <= MAX_CH then
        Line := Line + ' ' + W
      else
      begin
        if Result <> '' then Result := Result + LineEnding;
        Result := Result + Line;
        Line := W;
      end;
    end;
    if Line <> '' then
    begin
      if Result <> '' then Result := Result + LineEnding;
      Result := Result + Line;
    end;
  finally
    Words.Free;
  end;
end;

procedure Tgoverlayform.DrawCardRibbon(Bmp: TBitmap; BadgeMask: Integer);
begin
  TGamesTabHelper(FGamesHelper).DrawCardRibbon(Bmp, BadgeMask);
end;
procedure Tgoverlayform.LoadSteamGames;
begin
  TGamesTabHelper(FGamesHelper).LoadSteamGames;
end;
procedure Tgoverlayform.RefreshGameCards;
begin
  TGamesTabHelper(FGamesHelper).RefreshGameCards;
end;
function Tgoverlayform.GetMangoHudVersion: string;
begin
  Result := THomeTabHelper(FHomeHelper).GetMangoHudVersion;
end;

function Tgoverlayform.GetVkBasaltVersion: string;
begin
  Result := THomeTabHelper(FHomeHelper).GetVkBasaltVersion;
end;

function Tgoverlayform.GetVkSumiVersion: string;
begin
  Result := THomeTabHelper(FHomeHelper).GetVkSumiVersion;
end;

function Tgoverlayform.FindBinPath(const BinName: string): string;
begin
  Result := THomeTabHelper(FHomeHelper).FindBinPath(BinName);
end;

function Tgoverlayform.FindLibPath(const LibName: string): string;
begin
  Result := THomeTabHelper(FHomeHelper).FindLibPath(LibName);
end;

procedure Tgoverlayform.HomeDiagramPaint(Sender: TObject);
begin
  THomeTabHelper(FHomeHelper).HomeDiagramPaint(Sender);
end;

procedure Tgoverlayform.HomeBtnRowResize(Sender: TObject);
begin
  THomeTabHelper(FHomeHelper).HomeBtnRowResize(Sender);
end;

procedure Tgoverlayform.HomeGlobalBtnClick(Sender: TObject);
begin
  THomeTabHelper(FHomeHelper).HomeGlobalBtnClick(Sender);
end;

procedure Tgoverlayform.HomeGameBtnClick(Sender: TObject);
begin
  THomeTabHelper(FHomeHelper).HomeGameBtnClick(Sender);
end;

procedure Tgoverlayform.HomeGlobalBtnEnter(Sender: TObject);
begin
  THomeTabHelper(FHomeHelper).HomeGlobalBtnEnter(Sender);
end;

procedure Tgoverlayform.HomeGlobalBtnLeave(Sender: TObject);
begin
  THomeTabHelper(FHomeHelper).HomeGlobalBtnLeave(Sender);
end;

procedure Tgoverlayform.HomeGameBtnEnter(Sender: TObject);
begin
  THomeTabHelper(FHomeHelper).HomeGameBtnEnter(Sender);
end;

procedure Tgoverlayform.HomeGameBtnLeave(Sender: TObject);
begin
  THomeTabHelper(FHomeHelper).HomeGameBtnLeave(Sender);
end;

procedure Tgoverlayform.ClearConfigBtnClick(Sender: TObject);
begin
  THomeTabHelper(FHomeHelper).ClearConfigBtnClick(Sender);
end;

procedure Tgoverlayform.ClearConfigBtnEnter(Sender: TObject);
begin
  THomeTabHelper(FHomeHelper).ClearConfigBtnEnter(Sender);
end;

procedure Tgoverlayform.ClearConfigBtnLeave(Sender: TObject);
begin
  THomeTabHelper(FHomeHelper).ClearConfigBtnLeave(Sender);
end;

procedure Tgoverlayform.HomeChannelComboChange(Sender: TObject);
begin
  THomeTabHelper(FHomeHelper).HomeChannelComboChange(Sender);
end;

procedure Tgoverlayform.RefreshHomeModuleStatus;
begin
  THomeTabHelper(FHomeHelper).RefreshHomeModuleStatus;
end;

procedure Tgoverlayform.RefreshHomeOptiStatus;
begin
  THomeTabHelper(FHomeHelper).RefreshHomeOptiStatus;
end;

procedure Tgoverlayform.RefreshHomeDeps;
begin
  THomeTabHelper(FHomeHelper).RefreshHomeDeps;
end;

procedure Tgoverlayform.BuildVkSumiTab;
begin
  TVkBasaltTabHelper(FBasaltHelper).BuildVkSumiTab;
end;

procedure Tgoverlayform.VkSumiSliderChange(Sender: TObject);
begin
  TVkBasaltTabHelper(FBasaltHelper).VkSumiSliderChange(Sender);
end;

procedure Tgoverlayform.InitHomeTab;
begin
  THomeTabHelper(FHomeHelper).InitHomeTab;
end;

procedure Tgoverlayform.ShowHomeTab(Sender: TObject);
begin
  THomeTabHelper(FHomeHelper).ShowHomeTab(Sender);
end;

procedure Tgoverlayform.ReflowGamesGrid;
begin
  TGamesTabHelper(FGamesHelper).ReflowGamesGrid;
end;
procedure Tgoverlayform.GamesScrollBoxResize(Sender: TObject);
begin
  TGamesTabHelper(FGamesHelper).GamesScrollBoxResize(Sender);
end;
procedure Tgoverlayform.GamesEmptySpaceClick(Sender: TObject);
begin
  TGamesTabHelper(FGamesHelper).GamesEmptySpaceClick(Sender);
end;
procedure Tgoverlayform.GameCardMouseEnter(Sender: TObject);
begin
  TGamesTabHelper(FGamesHelper).GameCardMouseEnter(Sender);
end;
procedure Tgoverlayform.GameCardMouseLeave(Sender: TObject);
begin
  TGamesTabHelper(FGamesHelper).GameCardMouseLeave(Sender);
end;
procedure Tgoverlayform.GameCardClick(Sender: TObject);
begin
  TGamesTabHelper(FGamesHelper).GameCardClick(Sender);
end;
procedure Tgoverlayform.GameCardMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  TGamesTabHelper(FGamesHelper).GameCardMouseUp(Sender, Button, Shift, X, Y);
end;
procedure Tgoverlayform.GameCardOpenFolderClick(Sender: TObject);
begin
  TGamesTabHelper(FGamesHelper).GameCardOpenFolderClick(Sender);
end;
procedure Tgoverlayform.GameCardOpenPrefixClick(Sender: TObject);
begin
  TGamesTabHelper(FGamesHelper).GameCardOpenPrefixClick(Sender);
end;
procedure Tgoverlayform.GameCardUninstallClick(Sender: TObject);
begin
  TGamesTabHelper(FGamesHelper).GameCardUninstallClick(Sender);
end;
procedure Tgoverlayform.AddNonSteamFolderClick(Sender: TObject);
begin
  TGamesTabHelper(FGamesHelper).AddNonSteamFolderClick(Sender);
end;
procedure Tgoverlayform.ShowRemoveFoldersMenu(Sender: TObject; X, Y: Integer);
begin
  TGamesTabHelper(FGamesHelper).ShowRemoveFoldersMenu(Sender, X, Y);
end;
procedure Tgoverlayform.RemoveFolderMenuItemClick(Sender: TObject);
begin
  TGamesTabHelper(FGamesHelper).RemoveFolderMenuItemClick(Sender);
end;
procedure Tgoverlayform.LoadNonSteamFolders(var ACardIndex: Integer;
  const ACardsPerRow, ARowMargin: Integer);
begin
  TGamesTabHelper(FGamesHelper).LoadNonSteamFolders(ACardIndex, ACardsPerRow, ARowMargin);
end;
function Tgoverlayform.SanitizeFileName(const AName: string): string;
var
  i: Integer;
begin
  Result := AName;
  for i := 1 to Length(Result) do
    if Result[i] in ['/', '\', ':', '*', '?', '"', '<', '>', '|', ''''] then
      Result[i] := '_';
end;

procedure Tgoverlayform.RunFGModUninstallCommands(const ATargetDir: string);
begin
  TGamesTabHelper(FGamesHelper).RunFGModUninstallCommands(ATargetDir);
end;
function Tgoverlayform.CleanGameNameForSearch(const AName: string): string;
var
  i: Integer;
begin
  Result := AName;

  // Replace underscores and hyphens with spaces
  Result := StringReplace(Result, '_', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '-', ' - ', [rfReplaceAll]);

  // Insert spaces in CamelCase / PascalCase
  // e.g. "HorizonChaseTurbo" -> "Horizon Chase Turbo"
  i := 2;
  while i <= Length(Result) do
  begin
    if (Result[i] in ['A'..'Z']) and (Result[i-1] in ['a'..'z']) then
    begin
      // Lowercase followed by uppercase: e.g. "HorizonC" -> "Horizon C"
      Insert(' ', Result, i);
      Inc(i, 2);
    end
    else if (Result[i] in ['A'..'Z']) and (i > 1) and
            (Result[i-1] in ['A'..'Z']) and
            (i < Length(Result)) and (Result[i+1] in ['a'..'z']) then
    begin
      // Insert space before last capital in a run followed by lowercase
      // e.g. "HOTWHEELSUnleashed" -> "HOTWHEELS Unleashed"
      Insert(' ', Result, i);
      Inc(i, 2);
    end
    else
      Inc(i);
  end;

  // All-uppercase long names: try common game-title words
  // e.g. "HOTWHEELSUNLEASHED" -> "HOT WHEELS UNLEASHED"
  if (Length(Result) > 8) and (Result = UpperCase(Result)) then
  begin
    Result := InsertSpacesInUppercase(Result);
  end;

  // Expand common abbreviations (longer matches must come first)
  Result := StringReplace(Result, 'GTAV', 'Grand Theft Auto V', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'GTA', 'Grand Theft Auto', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'RDR2', 'Red Dead Redemption 2', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'RDR', 'Red Dead Redemption', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'COD', 'Call of Duty', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'NFS', 'Need for Speed', [rfReplaceAll, rfIgnoreCase]);

  // Clean up multiple spaces
  while Pos('  ', Result) > 0 do
    Result := StringReplace(Result, '  ', ' ', [rfReplaceAll]);

  Result := Trim(Result);
end;

function Tgoverlayform.InsertSpacesInUppercase(const AName: string): string;
const
  COMMON_WORDS: array[0..88] of string = (
    'HOT','WHEELS','UNLEASHED','WHEEL','GRAND','THEFT','AUTO',
    'ENHANCED','DEFINITIVE','EDITION','REMASTERED','REMAKE','DELUXE',
    'ULTIMATE','COMPLETE','COLLECTION','GAME','YEAR','STANDARD',
    'SPECIAL','LEGENDARY','BATTLE','FIELD','MODERN','WARFARE',
    'KNIGHT','ARKHAM','CITY','ASYLUM','ORIGINS','ORIGIN',
    'REVENGE','REVOLUTION','EVOLUTION','INFAMOUS','SECOND',
    'SON','INFINITE','ADVANCED','BLACK','GATE','FRONTIER',
    'DEVELOPER','STUDIO','INTERACTIVE','SOFTWARE','DARK',
    'SOULS','BLOOD','BORNE','SEKIRO','ELDEN','RING',
    'HORIZON','CHASE','TURBO','ZERO','DAWN','FORBIDDEN',
    'WEST','GHOST','RUNNER','LOOP','HERO','CONTROL',
    'RETURNAL','SPIDER','MAN','MILES','MORALES','RATCHET',
    'CLANK','DEMON','SLAYER','DOOM','ETERNAL','WOLFENSTEIN',
    'YOUNG','BLOOD','NEW','ORDER','COLOSSUS','SHADOW',
    'TOMB','RAIDER','LAST','US','PART','UNCHARTED'
  );
var
  i, w, WordLen: Integer;
  Found: Boolean;
begin
  Result := AName;
  i := 1;
  while i <= Length(Result) do
  begin
    Found := False;
    // Try longest words first
    for w := Low(COMMON_WORDS) to High(COMMON_WORDS) do
    begin
      WordLen := Length(COMMON_WORDS[w]);
      if (i + WordLen - 1 <= Length(Result)) and
         (Copy(Result, i, WordLen) = COMMON_WORDS[w]) then
      begin
        if (i > 1) and (Result[i-1] <> ' ') then
        begin
          Insert(' ', Result, i);
          Inc(i);
        end;
        Inc(i, WordLen);
        Found := True;
        Break;
      end;
    end;
    if not Found then
      Inc(i);
  end;
  Result := Trim(Result);
end;

// ============================================================================
// Web image search fallback (Bing, no API key required)
// ============================================================================

function Tgoverlayform.SearchWebCover(const AGameName, ACachePath: string): Boolean;
begin
  Result := TGamesTabHelper(FGamesHelper).SearchWebCover(AGameName, ACachePath);
end;
function Tgoverlayform.SearchSteamStoreGame(const AGameName: string; out AAppId: string): Boolean;
begin
  Result := TGamesTabHelper(FGamesHelper).SearchSteamStoreGame(AGameName, AAppId);
end;
function Tgoverlayform.DownloadSteamCover(const AAppId, ACachePath: string): Boolean;
begin
  Result := TGamesTabHelper(FGamesHelper).DownloadSteamCover(AAppId, ACachePath);
end;
function Tgoverlayform.GetGameConfigDir(const AGameName: string): string;
begin
  // Use the centralized Flatpak-aware helper so game configs are stored in
  // the same location whether GOverlay is running natively or as Flatpak.
  Result := IncludeTrailingPathDelimiter(TConfigManager.GetHostDataDir) +
            'goverlay/gameconfig/' + SanitizeFileName(AGameName) + '/';
end;

function Tgoverlayform.FindFileInDir(const ADir, AFileName: string): string;
var
  Files: TStringList;
begin
  Result := '';
  if not DirectoryExists(ADir) then Exit;
  Files := FindAllFiles(ADir, AFileName, True);
  try
    if Files.Count > 0 then
      Result := Files[0];
  finally
    Files.Free;
  end;
end;

// Returns 'MANGOHUD_CONFIGFILE=<game_config>/MangoHud.conf ' when a game is
// selected so that vkcube/pascube previews use the game-specific config.
// Returns an empty string in global mode.
function Tgoverlayform.GetMangoHudConfigEnvPrefix: string;
begin
  if FActiveGameName <> '' then
    Result := 'MANGOHUD_CONFIGFILE="' + GetGameConfigDir(FActiveGameName) + 'MangoHud.conf" '
  else
    Result := '';
end;

// Returns MANGOHUD_CONFIGFILE + MANGOHUD=1 only when MangoHud is enabled.
// In global mode MangoHud is always considered active.
// In game mode, returns empty when the MangoHud toggle is OFF.
function Tgoverlayform.GetMangoHudLaunchEnv: string;
begin
  if (FActiveGameName <> '') and not FNavToolEnabled[0] then
    Result := ''  // MangoHud disabled for this game
  else
    Result := GetMangoHudConfigEnvPrefix + 'MANGOHUD=1 ';
end;

// Returns VKBASALT_CONFIG_FILE + ENABLE_VKBASALT=1 only when vkBasalt is enabled.
function Tgoverlayform.GetVkBasaltLaunchEnv: string;
begin
  if (FActiveGameName <> '') and not FNavToolEnabled[1] then
    Result := ''  // vkBasalt disabled for this game
  else
    Result := GetVkBasaltConfigEnvPrefix + 'ENABLE_VKBASALT=1 ';
end;

// Returns VKSUMI_CONFIG_FILE + ENABLE_VKSUMI=1 (always, independent of vkBasalt state).
function Tgoverlayform.GetVkSumiLaunchEnv: string;
begin
  Result := GetVkSumiConfigEnvPrefix + 'ENABLE_VKSUMI=1 ';
end;

function Tgoverlayform.GetVkBasaltConfigEnvPrefix: string;
begin
  if FActiveGameName <> '' then
    Result := 'VKBASALT_CONFIG_FILE="' + GetGameConfigDir(FActiveGameName) + 'vkBasalt.conf" '
  else
    Result := '';
end;

function Tgoverlayform.GetVkSumiConfigEnvPrefix: string;
begin
  if FActiveGameName <> '' then
    Result := 'VKSUMI_CONFIG_FILE="' + GetGameConfigDir(FActiveGameName) + 'vkSumi.conf" '
  else
    Result := '';
end;

procedure Tgoverlayform.UpdateGameContextLabel;
begin
  // Game context label removed — active game is shown in the sidebar thumb instead
end;

procedure Tgoverlayform.PreviewBtnClick(Sender: TObject);
begin
  if IsCommandAvailable('pascube') then
    ExecuteGUICommand(GetMangoHudLaunchEnv + GetVkBasaltLaunchEnv + GetVkSumiLaunchEnv + 'pascube &')
  else if IsCommandAvailable('vkcube') then
    ExecuteGUICommand(GetMangoHudLaunchEnv + GetVkBasaltLaunchEnv + GetVkSumiLaunchEnv + 'vkcube &')
  else
    SendNotification('Goverlay', 'PasCube and VkCube not found.', GetIconFile);
end;

procedure Tgoverlayform.ShowGameThumb(ACard: TPanel);
begin
  TGamesTabHelper(FGamesHelper).ShowGameThumb(ACard);
end;
procedure Tgoverlayform.LoadGlobalThumb;
begin
  TGamesTabHelper(FGamesHelper).LoadGlobalThumb;
end;
procedure Tgoverlayform.HideGameThumb;
begin
  LoadGlobalThumb;
end;

// ============================================================================
// Card hover brightness animation
// ============================================================================

procedure Tgoverlayform.ApplyCardBrightness(ACard: TPanel; BrightFactor: Integer);
begin
  TGamesTabHelper(FGamesHelper).ApplyCardBrightness(ACard, BrightFactor);
end;
procedure Tgoverlayform.ApplyAllCardsDim;
begin
  TGamesTabHelper(FGamesHelper).ApplyAllCardsDim;
end;
procedure Tgoverlayform.HoverTimerTick(Sender: TObject);
const
  STEP = 10;  // ~10 steps × 16 ms ≈ 160 ms full transition
var
  Brightness: Integer;
  Expand: Integer;
begin
  if not Assigned(FHoveredCard) then
  begin
    DbgLog('HoverTimerTick: no hovered card, stopping timer');
    FHoverTimer.Enabled := False;
    Exit;
  end;

  // Skip animation tick if a reflow is currently running (avoids ChangeBounds loops)
  if FInReflow then
  begin
    DbgLog('HoverTimerTick: reflow active, skipping');
    Exit;
  end;

  FHoverBrightness := FHoverBrightness + FHoverDir * STEP;

  // Interpolate card size smoothly using brightness as a 0..1 factor
  Expand := Round(SEL_EXPAND * FHoverBrightness / 100.0);
  FHoveredCard.SetBounds(
    FHoverBaseLeft - Expand,
    FHoverBaseTop  - Expand,
    CARD_W + 2 * Expand,
    CARD_H + 2 * Expand);
  if (FHoveredCard.ControlCount > 0) and (FHoveredCard.Controls[0] is TImage) then
    TImage(FHoveredCard.Controls[0]).SetBounds(0, 0, CARD_W + 2 * Expand, CARD_H + 2 * Expand);

  if FHoverBrightness <= 0 then
  begin
    FHoverBrightness := 0;
    FHoverTimer.Enabled := False;
    ApplyCardBrightness(FHoveredCard, 100);
    FHoveredCard := nil;
  end
  else if FHoverBrightness >= 100 then
  begin
    FHoverBrightness := 100;
    FHoverTimer.Enabled := False;
    ApplyCardBrightness(FHoveredCard, 100);
  end
  else
  begin
    Brightness := 100;
    ApplyCardBrightness(FHoveredCard, Brightness);
  end;
end;
procedure Tgoverlayform.ResetCopyFeedback(Sender: TObject);
begin
  if Sender is TTimer then
  begin
    TTimer(Sender).Enabled := False;
    TTimer(Sender).Free;
  end;
  if Assigned(commandPaintBox) then
    commandPaintBox.Invalidate;
end;

procedure Tgoverlayform.commandPaintBoxClick(Sender: TObject);
var
  T: TTimer;
begin
  Clipboard.AsText := FLaunchCommand;
  FCommandCopiedTime := GetTickCount64;
  commandPaintBox.Invalidate;
  
  T := TTimer.Create(Self);
  T.Interval := 2000;
  T.OnTimer := @ResetCopyFeedback;
  T.Enabled := True;
end;

procedure Tgoverlayform.commandPaintBoxPaint(Sender: TObject);
const
  // GitHub Dark inspired palette
  CLR_BG         = $22161B;  // #161b22
  CLR_BORDER     = $FFA658;  // #58a6ff
  CLR_PATH       = $87E77E;  // #7ee787
  CLR_COMMAND    = $727BFF;  // #ff7b72
  CLR_ENVVAR     = $FFC079;  // #79c0ff
  CLR_KEYWORD    = $FFA8D2;  // #d2a8ff
  CLR_DEFAULT    = $D9D1C9;  // #c9d1d9
var
  PB: TPaintBox;
  R: TRect;
  S, Token: string;
  X, Y, i: Integer;
  IsCommandCopied: Boolean;
  CColor: TColor;
begin
  PB := TPaintBox(Sender);
  R := PB.ClientRect;

  // Background
  PB.Canvas.Brush.Color := CLR_BG;
  PB.Canvas.FillRect(R);

  // Border
  PB.Canvas.Pen.Color := CLR_BORDER;
  PB.Canvas.Rectangle(R);

  // Command text uses the full available height, vertically centered
  PB.Canvas.Font.Name  := 'DejaVu Sans Mono';
  PB.Canvas.Font.Size  := 9;
  PB.Canvas.Font.Style := [];

  S := FLaunchCommand;
  if S = '' then S := 'envvars %command%';

  // Shrink font until the command fits (reserve 40 px for copy icon + margins)
  while (PB.Canvas.Font.Size > 7) and (PB.Canvas.TextWidth(S) > (R.Right - 40)) do
    PB.Canvas.Font.Size := PB.Canvas.Font.Size - 1;

  X := 10;
  Y := (PB.Height - PB.Canvas.TextHeight('A')) div 2;
  i := 1;
  while i <= Length(S) do
  begin
    while (i <= Length(S)) and (S[i] = ' ') do
    begin
      X := X + PB.Canvas.TextWidth(' ');
      Inc(i);
    end;
    if i > Length(S) then Break;

    Token := '';
    if S[i] = '"' then
    begin
      Token := '"';
      Inc(i);
      while (i <= Length(S)) and (S[i] <> '"') do
      begin
        Token := Token + S[i];
        Inc(i);
      end;
      if (i <= Length(S)) and (S[i] = '"') then
      begin
        Token := Token + '"';
        Inc(i);
      end;
      CColor := CLR_PATH; // green for quoted paths
    end
    else
    begin
      while (i <= Length(S)) and (S[i] <> ' ') do
      begin
        Token := Token + S[i];
        Inc(i);
      end;

      if Token = '%command%' then
        CColor := CLR_COMMAND          // coral for %command%
      else if Pos('=', Token) > 0 then
        CColor := CLR_ENVVAR           // blue for env vars
      else if (Token = '--') or (Token = 'env') or (Token = 'gamemoderun') then
        CColor := CLR_KEYWORD          // purple for keywords
      else
        CColor := CLR_DEFAULT;         // light gray for the rest
    end;

    PB.Canvas.Font.Color := CColor;
    PB.Canvas.TextOut(X, Y, Token);
    X := X + PB.Canvas.TextWidth(Token);
  end;

  // Copy feedback
  IsCommandCopied := (GetTickCount64 - FCommandCopiedTime) < 2000;

  if IsCommandCopied then
  begin
    PB.Canvas.Font.Color := clLime;
    PB.Canvas.Font.Style := [fsBold];
    PB.Canvas.TextOut(R.Right - PB.Canvas.TextWidth('Copied! ✓') - 10, Y, 'Copied! ✓');
    PB.Canvas.Font.Style := [];
  end
  else
  begin
    if Assigned(iconsImageList) then
      iconsImageList.Draw(PB.Canvas, R.Right - 24, (PB.Height - 16) div 2, 22);
  end;
end;

procedure Tgoverlayform.CheckAndUpdateConfigVersion;
var
  IniFile: TIniFile;
  ConfigPath, ConfigDir, SavedVersion: string;
begin
  try
    ConfigPath := GetConfigFilePath;
    ConfigDir := ExtractFilePath(ConfigPath);

    if not DirectoryExists(ConfigDir) then
      ForceDirectories(ConfigDir);

    IniFile := TIniFile.Create(ConfigPath);
    try
      SavedVersion := IniFile.ReadString('General', 'Version', '');
      
      // If version exists and is older than GVERSION
      if (SavedVersion <> '') and (CompareVersions(SavedVersion, GVERSION) < 0) then
      begin
        if MessageDlg('Old Configuration',
                      'GOverlay detected that your configuration was generated by an older version (' + SavedVersion + ').' + sLineBreak +
                      'This may cause issues with old fgmod versions or outdated scripts.' + sLineBreak + sLineBreak +
                      'Would you like to do a "Clear Configuration" now? (Recommended)',
                      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        begin
          ClearConfigBtnClick(nil);
        end;
      end;
      
      // Always update config with the current version
      IniFile.WriteString('General', 'Version', GVERSION);
    finally
      IniFile.Free;
    end;
  except
    // Fail silently so startup isn't aborted
  end;
end;

procedure Tgoverlayform.RefreshGameCardsAsync(Data: PtrInt);
begin
  TGamesTabHelper(FGamesHelper).RefreshGameCardsAsync(Data);
end;


end.