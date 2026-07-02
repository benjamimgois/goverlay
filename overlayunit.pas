unit overlayunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, Forms, Controls, Graphics, Dialogs, ExtCtrls, Math,
  unix, BaseUnix, StdCtrls, Spin, ComCtrls, Buttons, ActnList, Menus, aboutunit, optiscaler_update, protontricksunit,
  blacklistUnit, LCLtype, Clipbrd, LCLIntf, IniFiles,
  FileUtil, StrUtils, Types, fpjson, jsonparser, git2pas, howto, themeunit, systemdetector, constants,
  bgmod_resources, hintsunit,
  {$IFDEF LCLqt6}
  qt6,
  {$ELSE}
  qt5,
  {$ENDIF}
  qtwidgets, fpreadjpeg, configmanager, IntfGraphics, Grids,
  configkeys, configfile, uihelpers, apputils, overlay_config, overlay_utils;



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
    obs_vkcaptureCheckBox: TCheckBox;
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
    settingsWhatsNewMenuItem: TMenuItem;
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
    procedure whatsNewMenuItemClick(Sender: TObject);
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
    procedure howtoSteamClick(Sender: TObject);
    procedure howtoHeroicClick(Sender: TObject);
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
    procedure tweaksTabSheetShow(Sender: TObject);
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

    // Moved to public:
    {     FNavItems:       array of TPanel;    // item panels
    FNavIndicators:  array of TShape;    // left indicator bars
    FNavIcons:       array of TLabel;    // unicode icon labels
    FNavLabels:      array of TLabel;    // caption labels
    FNavActive:      Integer;            // index of active item (-1 = none)
    FNavHoveredIdx:  Integer;            // index of hovered item (-1 = none)
    FNavClickCBs:    array of TNotifyEvent; // click callbacks per item
    FNavCollapsed:   Boolean;            // sidebar collapsed state
    FPresetsBgBox:   TPaintBox;          // full-width navy paintbox background for Presets tab
    FPresetsWrapper: TPanel;             // centered wrapper for the Presets tab content
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
    FCubeAutoLaunch:     Boolean;    // whether to auto-launch pascube/vkcube }

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

    // Moved to public:
    {     FNavToolBtns:    array[0..3] of TSpeedButton;
    FNavToolEnabled: array[0..3] of Boolean;
    FNavToolImgListSmall: TImageList; }  // smaller ON/OFF icons for collapsed nav

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



    // Exposed: procedure BuildNavRail;
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
    // Exposed: procedure BuildSettingsButton;
    // Exposed: procedure RestoreNavRailColors;
    // Exposed: procedure SettingsBtnMouseEnter(Sender: TObject);
    // Exposed: procedure SettingsBtnMouseLeave(Sender: TObject);
    // Exposed: procedure SettingsBtnClick(Sender: TObject);
    // Exposed: procedure CubeAutoLaunchMenuItemClick(Sender: TObject);
    // Exposed: procedure BuildNavToolToggles;
    // Exposed: procedure BuildSmallToggleImages;
    // Exposed: procedure NavToolToggleClick(Sender: TObject);
    // Exposed: procedure UpdateNavToolToggleVisibility(AShowLabels: Boolean);
    // Exposed: procedure LoadGameToggleStates;
    // Exposed: function  GetGameToolEnabled(const AGameName: string; AToolIdx: Integer): Boolean;
    // Exposed: procedure SetGameToolEnabled(const AGameName: string; AToolIdx: Integer; AEnabled: Boolean);
    // Exposed: procedure ApplyToolEnabledState(AToolIdx: Integer; AEnabled: Boolean);
    // Exposed: function  ActiveToolIndex: Integer;
    // Exposed: procedure SetSaveBtnEnabled(AEnabled: Boolean);
    // Exposed: procedure SetControlTreeEnabled(ACtrl: TWinControl; AEnabled: Boolean);
    // Exposed: procedure PatchGameFGModWineDllOverrides(const AFGModFile: string; AEnabled: Boolean);
    // Exposed: procedure PatchGameFGModConditionalExport(const AFGModFile, AConditionalLine, ASearchKey: string);
    procedure BuildVkSumiTab;
    procedure VkSumiSliderChange(Sender: TObject);
    procedure LoadVkSumiConfig;
    procedure VsRestoreBtnClick(Sender: TObject);
    // Exposed: procedure PatchGameFGModConfigPath(const AFGModFile, AEnvVar, AConfigPath: string);
    // Exposed: procedure RemoveTweaksFromGameFGMod(const AFGModFile: string);
    // Exposed: procedure RemoveOptiScalerGameFiles(const AGameCfgDir: string);
    // Exposed: procedure CopyOptiScalerGameFiles(const AGameCfgDir: string);
    // Exposed: procedure EnsureGameFGModOptiScalerConditional(const AFGModFile: string);
    // Exposed: procedure NavItemClick(Sender: TObject);
    // Exposed: procedure NavItemMouseEnter(Sender: TObject);
    // Exposed: procedure NavItemMouseLeave(Sender: TObject);
    // Exposed: procedure NavItemPaint(Sender: TObject);
    // Exposed: procedure SetNavActive(AIndex: Integer);
    // Exposed: procedure NavToggleClick(Sender: TObject);
    // Exposed: procedure NavAnimTick(Sender: TObject);
    // Exposed: procedure ApplyNavWidth(AWidth: Integer);
    // Exposed: procedure ApplyNavCollapsed;
    procedure FormResize(Sender: TObject);
    // Exposed: procedure ReflowPresetTab(AContentW: Integer);
    // Exposed: procedure ReflowVisualTab(AContentW: Integer);
    procedure InitVisualTab;
    procedure VisualCardPaint(Sender: TObject);
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
    // Exposed: procedure ReflowPerformanceTab(AContentW: Integer);
    // Exposed: procedure ReflowOptiScalerTab(AContentW: Integer);
    // Exposed: procedure ReflowOptiScalerTabNew(AContentW: Integer);
    procedure InitMetricsTab;
    // Exposed: procedure ReflowMetricsTab(AContentW: Integer);
    // Exposed: procedure ReflowExtrasTab(AContentW: Integer);
    procedure InitVkBasaltTab;
    procedure InitTweaksCards;
    // Exposed: procedure ReflowVkBasaltTab(AContentW: Integer);
    // Exposed: procedure ReflowVkSumiTab(AContentW: Integer);
    // Exposing: procedure ReflowSliderInSection(ASec: TPanel; AIndex: Integer);

    // Exposed: procedure StartCube;
    // Exposed: procedure StopCube;

    procedure InitGamesTab;
    procedure LoadSteamGames;
    procedure RefreshGameCards;
    // Exposed: procedure ReflowGamesGrid;
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
    // Exposed: function  GetGameConfigDir(const AGameName: string): string;
    function  SanitizeFileName(const AName: string): string;
    // Exposed: function  FindFileInDir(const ADir, AFileName: string): string;
    procedure CheckAndUpdateConfigVersion;
    procedure CheckAndShowChangelog;
    procedure ShowChangelogAsync(Data: PtrInt);
    procedure RefreshGameCardsAsync(Data: PtrInt);
    function  GetMangoHudConfigEnvPrefix: string;
    function  GetMangoHudLaunchEnv: string;
    function  GetVkBasaltConfigEnvPrefix: string;
    function  GetVkSumiConfigEnvPrefix: string;
    function  GetVkBasaltLaunchEnv: string;
    function  GetVkSumiLaunchEnv: string;
    // Exposed: procedure UpdateGameContextLabel;
    // Exposed: procedure PreviewBtnClick(Sender: TObject);
    // Exposed: procedure LoadGlobalThumb;
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
    procedure UpdateTweaksVarListBox;
    procedure TweaksVarRemoveClick(Sender: TObject);
    procedure TweaksGridPrepareCanvas(sender: TObject; aCol, aRow: Integer; aState: TGridDrawState);
    procedure TweaksGridDrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
    procedure TweaksGridMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TweaksGridResize(Sender: TObject);



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
    // Exposed: procedure ShowHomeTab(Sender: TObject = nil);
    procedure RefreshHomeModuleStatus;
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
    procedure RestoreIfMaximized;
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
    FBenchmarkTimer: TTimer;
    FBenchmarkWasRunning: Boolean;
    FBenchmarkStarted: Boolean;
    FBenchmarkStartTicks: Integer;
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

    // Navigation rail fields (moved from private)
    FNavItems:       array of TPanel;    // item panels
    FNavIndicators:  array of TShape;    // left indicator bars
    FNavIcons:       array of TLabel;    // unicode icon labels
    FNavLabels:      array of TLabel;    // caption labels
    FNavActive:      Integer;            // index of active item (-1 = none)
    FNavHoveredIdx:  Integer;            // index of hovered item (-1 = none)
    FNavClickCBs:    array of TNotifyEvent; // click callbacks per item
    FNavCollapsed:   Boolean;            // sidebar collapsed state
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

    FNavToolBtns:    array[0..3] of TSpeedButton;
    FNavToolEnabled: array[0..3] of Boolean;
    FNavToolImgListSmall: TImageList;  // smaller ON/OFF icons for collapsed nav
    FNavHelper:      TObject;            // cached sidebar nav helper

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
    FUninstallMenuItem: TMenuItem;
    FRightClickedCard: TPanel;      // card that triggered the context menu
    FGameMenuImgList: TImageList;   // icons for the game card context menu
    FMangoIconGfx: TPortableNetworkGraphic;  // cached badge icon for MangoHud
    FOptiIconGfx:  TPortableNetworkGraphic;
  public
    procedure RefreshOsStatusDots;
    procedure RefreshHomeOptiStatus;
    procedure PerfCardPaint(Sender: TObject);
    procedure TweaksCheckChange(Sender: TObject);
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

    function IsOptiScalerInstalled: Boolean;
    procedure ShowStatusMessage(const AMessage: string; ADuration: Integer = 3000);
    function GetGeneralCheckBox(Index: Integer): TCheckBox;
    function GetGraphicsCheckBox(Index: Integer): TCheckBox;
    function GetPerformanceCheckBox(Index: Integer): TCheckBox;
    function OsHexToKeyStr(const HexStr: string): string;
    procedure PresetsBgBoxPaint(Sender: TObject);
    procedure PresetsWrapperPaint(Sender: TObject);
    procedure BuildNavRail;
    procedure BuildSettingsButton;
    procedure RestoreNavRailColors;
    procedure SettingsBtnMouseEnter(Sender: TObject);
    procedure SettingsBtnMouseLeave(Sender: TObject);
    procedure SettingsBtnClick(Sender: TObject);
    procedure CubeAutoLaunchMenuItemClick(Sender: TObject);
     procedure BenchmarkTimerTick(Sender: TObject);
     procedure CopyPasCubeLogs;
     procedure BuildNavToolToggles;
    procedure BuildSmallToggleImages;
    procedure NavToolToggleClick(Sender: TObject);
    procedure UpdateNavToolToggleVisibility(AShowLabels: Boolean);
    function  GetGameToolEnabled(const AGameName: string; AToolIdx: Integer): Boolean;
    procedure SetGameToolEnabled(const AGameName: string; AToolIdx: Integer; AEnabled: Boolean);
    procedure ApplyToolEnabledState(AToolIdx: Integer; AEnabled: Boolean);
    function  ActiveToolIndex: Integer;
    procedure SetSaveBtnEnabled(AEnabled: Boolean);
    procedure SetControlTreeEnabled(ACtrl: TWinControl; AEnabled: Boolean);
    procedure PatchGameFGModWineDllOverrides(const AFGModFile: string; AEnabled: Boolean);
    procedure PatchGameFGModConditionalExport(const AFGModFile, AConditionalLine, ASearchKey: string);
    procedure PatchGameFGModConfigPath(const AFGModFile, AEnvVar, AConfigPath: string);
    procedure RemoveTweaksFromGameFGMod(const AFGModFile: string);
    procedure RemoveOptiScalerGameFiles(const AGameCfgDir: string);
    procedure CopyOptiScalerGameFiles(const AGameCfgDir: string);
    procedure NavItemClick(Sender: TObject);
    procedure NavItemMouseEnter(Sender: TObject);
    procedure NavItemMouseLeave(Sender: TObject);
    procedure NavItemPaint(Sender: TObject);
    procedure NavToggleClick(Sender: TObject);
    procedure NavAnimTick(Sender: TObject);
    procedure ApplyNavWidth(AWidth: Integer);
    procedure ApplyNavCollapsed;
    function  GetGameConfigDir(const AGameName: string): string;
    function  GetActiveCustomConfigFile: string;
    function  GetTargetCustomConfigFile: string;
    procedure LoadGameToggleStates;
    procedure ReflowPresetTab(AContentW: Integer);
    procedure ReflowVisualTab(AContentW: Integer);
    procedure ReflowPerformanceTab(AContentW: Integer);
    procedure ReflowOptiScalerTab(AContentW: Integer);
    procedure ReflowOptiScalerTabNew(AContentW: Integer);
    procedure ReflowMetricsTab(AContentW: Integer);
    procedure ReflowExtrasTab(AContentW: Integer);
    procedure ReflowVkBasaltTab(AContentW: Integer);
    procedure ReflowVkSumiTab(AContentW: Integer);
    procedure StartCube;
    procedure StopCube;
    procedure ReflowGamesGrid;
    procedure LoadGlobalThumb;
    procedure ShowHomeTab(Sender: TObject = nil);
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
  xlib, x, tweaks_md3, games_tab, vkbasalt_tab, mangohud_ui, goverlay_system, optiscaler_tab, home_tab, sidebar_nav, changelogunit;

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
  LogPath: string;
  F: TextFile;
begin
  T := GetTickCount64;
  if GDbgT0 = 0 then GDbgT0 := T;
  WriteLn(StdErr, Format('[%6d ms] %s', [T - GDbgT0, Msg]));
  try
    LogPath := IncludeTrailingPathDelimiter(TConfigManager.GetGoverlayFolder) + 'benchmark_debug.log';
    TConfigManager.EnsureDirectoryExists(TConfigManager.GetGoverlayFolder);
    AssignFile(F, LogPath);
    if FileExists(LogPath) then
      Append(F)
    else
      Rewrite(F);
    WriteLn(F, Format('[%6d ms] %s', [T - GDbgT0, Msg]));
    CloseFile(F);
  except
    // ignore
  end;
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
  optversionComboBox.Visible := False;
  updateBitBtn.Visible := False;
  checkupdBitBtn.Visible := False;
  updateProgressBar.Visible := True;
  updatestatusLabel.Visible := True;
  try
    FOptiscalerUpdate.UpdateButtonClick(Sender);
  finally
    updateProgressBar.Visible := False;
    updatestatusLabel.Visible := False;
    optversionComboBox.Visible := True;
    updateBitBtn.Visible := True;
    checkupdBitBtn.Visible := True;
  end;
  // Re-enable controls after installation completes
  UpdateGeSpeedButtonState;
  // Reload installed versions and refresh the Software Status card immediately.
  // UpdateButtonClick internally reassigns FGModPath to the global pristine
  // (bgmod/) for asset sync purposes; restore it to the active game/global
  // config dir so the status card reflects the freshly installed versions
  // (gameconfig/<game>/ when a game is active, gameconfig/global/ otherwise).
  if Assigned(FOptiscalerUpdate) then
  begin
    FOptiscalerUpdate.FGModPath := GetGameConfigDir(FActiveGameName);
    FOptiscalerUpdate.LoadVersionsFromFile;
  end;
  RefreshOsStatusDots;
end;











procedure Tgoverlayform.usercustomBitBtnClick(Sender: TObject);
var
  GameCfgDir: string;
begin
  CUSTOMCFGFILE := GetActiveCustomConfigFile;

  if FActiveGameName <> '' then
  begin
    GameCfgDir := GetGameConfigDir(FActiveGameName);
    if not DirectoryExists(GameCfgDir) then
      ForceDirectories(GameCfgDir);
    MANGOHUDCFGFILE := GameCfgDir + 'MangoHud.conf';
  end
  else
  begin
    MANGOHUDCFGFILE := IncludeTrailingPathDelimiter(GetMangoHudConfigDir()) + 'MangoHud.conf';
  end;

  if not FileExists(CUSTOMCFGFILE) then
  begin
    MessageDlg(
      'Custom Preset Required',
      'No custom configuration was found to load.' + LineEnding + LineEnding +
      'To create your custom preset:' + LineEnding +
      '1. Customize your desired elements and colors in GOverlay.' + LineEnding +
      '2. Click the menu button in the bottom bar.' + LineEnding +
      '3. Select "Save Options" -> "Save as Custom Config".' + LineEnding + LineEnding +
      'Once created, click "Custom" anytime to apply your preset!',
      mtInformation,
      [mbOK],
      0
    );
    Exit;
  end;

  ExecuteShellcommand('cp ' + QuotedStr(CUSTOMCFGFILE) + ' ' + QuotedStr(MANGOHUDCFGFILE));
  LoadMangoHudConfig;

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
  vksumiTabSheet.TabVisible:=true;
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

procedure Tgoverlayform.tweaksTabSheetShow(Sender: TObject);
begin
  LoadTweaksFromFGMod;
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
  FreeAndNil(FNavHelper);
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
   i, FoundIndex: Integer;
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
  FNavHelper := TSidebarNavHelper.Create(Self);
  FReshadeDownloadedOnFirstShow := False;
  FAutoDownloadingReshade := False;

  //Program Version
  GVERSION := '1.8.5';
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

  // Initialize the isolated global profile directory after bgmod/ has been
  // populated (either from bundled templates or from the auto-install above).
  InitializeGlobalConfigDirectory;

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

  // Check and update config version
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

  FBenchmarkTimer := TTimer.Create(Self);
  FBenchmarkTimer.Enabled := False;
  FBenchmarkTimer.Interval := 1000;
  FBenchmarkTimer.OnTimer := @BenchmarkTimerTick;
  FBenchmarkWasRunning := False;

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
   tweaksTabSheet.OnShow := @tweaksTabSheetShow;

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
  VKBASALTFOLDER := IncludeTrailingPathDelimiter(GetVkBasaltConfigDir());
  VKBASALTCFGFILE := IncludeTrailingPathDelimiter(GetVkBasaltConfigDir()) + 'vkBasalt.conf';
  RepoDir := IncludeTrailingPathDelimiter(VKBASALTFOLDER) + 'reshade-shaders';
  VKSUMIFOLDER := IncludeTrailingPathDelimiter(GetVkSumiConfigDir());
  VKSUMICFGFILE := VKSUMIFOLDER + 'vkSumi.conf';


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



   // Ensure default configurations are created
   EnsureDefaultConfigFiles(GVERSION, GCHANNEL, vkbtogglekeyCombobox.Text);

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

      if pcidevCombobox.Items.Count > 0 then
      begin
        GPU0 := pcidevCombobox.Items[0]; //store first value in variable
        Writeln ('GPU0: ', GPU0);

        FoundIndex := pcidevCombobox.Items.IndexOf(LSPCI0);
        if FoundIndex <> -1 then
          pcidevCombobox.ItemIndex := FoundIndex
        else if pcidevCombobox.Items.Count > 1 then
          pcidevCombobox.ItemIndex := 1
        else
          pcidevCombobox.ItemIndex := 0;

        if (pcidevCombobox.ItemIndex >= 0) and (pcidevCombobox.ItemIndex < GPUDESC.Count) then
          gpudescEdit.Text := GPUDESC[pcidevCombobox.ItemIndex]
        else
          gpudescEdit.Text := '';
      end
      else
      begin
        pcidevCombobox.ItemIndex := -1;
        gpudescEdit.Text := '';
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
    1: Result := enhdrCheckBox;          // Enable HDR
    2: Result := enwaylandCheckBox;      // Enable Wayland
    3: Result := actprotonlogsCheckBox;  // Active Proton Logs
    4: Result := usesdlCheckBox;         // Use SDL Input
    5: Result := obs_vkcaptureCheckBox;  // OBS Vulkan Capture
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
    0: Result := gamemodeCheckBox;       // Always use GameMode
    1: Result := highpriCheckBox;        // Higher priority for games
    2: Result := wow64CheckBox;          // Use WOW64
    3: Result := largeaddressCheckBox;   // Large Address Aware
    4: Result := stagememCheckBox;       // Staging shared memory
    5: Result := disablentsyncCheckBox;  // Disable NTSYNC
    6: Result := heapdelayCheckBox;      // Heap Delay Free
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

procedure Tgoverlayform.RestoreIfMaximized;
begin
  if WindowState = wsMaximized then
  begin
    WindowState := wsNormal;
    Application.ProcessMessages;
  end;
end;

procedure Tgoverlayform.StartCube;
begin
  if not FCubeAutoLaunch then Exit;
  StopCube; // Prevent duplicates
  RestoreIfMaximized;

  if IsRunningInFlatpak then
  begin
      // FLATPAK MODE
      if IsPasCubeAvailable then
         ExecuteGUICommand(GetMangoHudConfigEnvPrefix + 'MANGOHUD=1 ' + GetGOverlayPackageEnv + GetPasCubeCommand + ' --version "' + GVERSION + '"' + GetPasCubeNicknameParam + ' &')
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
      if IsPasCubeAvailable then
         ExecuteGUICommand(GetMangoHudConfigEnvPrefix + 'MANGOHUD=1 ' + GetGOverlayPackageEnv + GetPasCubeCommand + ' --version "' + GVERSION + '"' + GetPasCubeNicknameParam + ' &')
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

  // Check and display changelog popup after form is loaded and mapped
  Application.QueueAsyncCall(@ShowChangelogAsync, 0);
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

  // Apply modern scrollbar stylesheet to dynamic tab scrollboxes and standalone scrollbars
  if Assigned(FGamesScrollBox)  then ApplyModernScrollBarStylesheet(FGamesScrollBox);
  if Assigned(FMtScrollBox)      then ApplyModernScrollBarStylesheet(FMtScrollBox);
  if Assigned(FExtScrollBox)     then ApplyModernScrollBarStylesheet(FExtScrollBox);
  if Assigned(FOsScrollBox)      then ApplyModernScrollBarStylesheet(FOsScrollBox);
  if Assigned(FVsScrollBox)      then ApplyModernScrollBarStylesheet(FVsScrollBox);
  if Assigned(FTweaksScrollBar)  then ApplyModernScrollBarStylesheet(FTweaksScrollBar);
  if Assigned(FVkReshadeSB)      then ApplyModernScrollBarStylesheet(FVkReshadeSB);

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
begin
  TTweaksMD3Helper(FTweaksHelper).LoadTweaksFromFGMod;
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

    // Re-point the OptiScaler tab at the global config dir and reload versions
    // so Software status reflects gameconfig/global/ instead of the last game.
    if Assigned(FOptiscalerUpdate) then
    begin
      FOptiscalerUpdate.FGModPath := GetGameConfigDir('');
      try
        FOptiscalerUpdate.LoadVersionsFromFile;
        FOptiscalerUpdate.InitializeTab;
        RefreshOsStatusDots;
      except
        on E: Exception do
          WriteLn('[WARN] gamesLabelClick: could not reload OptiScaler status - ', E.Message);
      end;
    end;
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


  if IsPasCubeAvailable then
  begin
    try
      DeleteFile(IncludeTrailingPathDelimiter(TConfigManager.GetGoverlayFolder) + 'benchmark_debug.log');
    except
    end;
    DbgLog('*** RUN PASCUBE MENU CLICK - RUNNING PASCUBE ***');
    RestoreIfMaximized;
    ExecuteGUICommand(GetMangoHudLaunchEnv + GetVkBasaltLaunchEnv + GetVkSumiLaunchEnv + GetGOverlayPackageEnv + GetPasCubeCommand + ' --version "' + GVERSION + '"' + GetPasCubeNicknameParam + ' &');
    FBenchmarkWasRunning := True;
    FBenchmarkStarted := False;
    FBenchmarkStartTicks := 0;
    FBenchmarkTimer.Enabled := True;
  end
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
  RestoreIfMaximized;
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

procedure Tgoverlayform.howtoSteamClick(Sender: TObject);
var
  VideoPath: String;
begin
  VideoPath := GetAppBaseDir + 'assets/video/bgmod-steam.mp4';
  if not FileExists(VideoPath) then
  begin
    ShowMessage('Video tutorial not found.');
    Exit;
  end;

  if not OpenURL('file://' + VideoPath) then
    ShowMessage('Could not open video tutorial. Please install a media player.');
end;

procedure Tgoverlayform.howtoHeroicClick(Sender: TObject);
var
  VideoPath: String;
begin
  VideoPath := GetAppBaseDir + 'assets/video/bgmod-heroic.mp4';
  if not FileExists(VideoPath) then
  begin
    ShowMessage('Video tutorial not found.');
    Exit;
  end;

  if not OpenURL('file://' + VideoPath) then
    ShowMessage('Could not open video tutorial. Please install a media player.');
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
  if (pcidevCombobox.ItemIndex >= 0) and (pcidevCombobox.ItemIndex < GPUDESC.Count) then
    gpudescEdit.Text:=GPUDESC[pcidevCombobox.ItemIndex]
  else
    gpudescEdit.Text:='';
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
  // Sync emufp8CheckBox enabled state with the current optversionComboBox selection
  fsrversionComboBoxChange(nil);
end;

procedure Tgoverlayform.fsrversionComboBoxChange(Sender: TObject);
begin
  // Disable emufp8CheckBox when "4.0.2c (INT8)" is selected (ItemIndex = 1)
  // or when using bleeding-edge channel (optversionComboBox.ItemIndex = 1).
  // It only remains available for use when both are "Latest" and "Stable".
  if (fsrversionComboBox.ItemIndex = 0) and (optversionComboBox.ItemIndex = 0) then
  begin
    emufp8CheckBox.Enabled := True;
  end
  else
  begin
    emufp8CheckBox.Enabled := False;
    emufp8CheckBox.Checked := False;  // Also uncheck when disabled
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
begin
  TTweaksMD3Helper(FTweaksHelper).SaveTweaksConfig;
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
  if GetPerformanceCheckBox(0).Checked then
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
  if GetPerformanceCheckBox(0).Checked then
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

  // Check if gamemode should be added (check performanceCheckGroup)
  if GetPerformanceCheckBox(0).Checked then
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

  CUSTOMCFGFILE := GetTargetCustomConfigFile;
  if FActiveGameName <> '' then
    MANGOHUDCFGFILE := GetGameConfigDir(FActiveGameName) + 'MangoHud.conf'
  else
    MANGOHUDCFGFILE := IncludeTrailingPathDelimiter(GetMangoHudConfigDir()) + 'MangoHud.conf';

  // Copy Mangohud.conf file to custom.conf
  ExecuteShellCommand('cp ' + QuotedStr(MANGOHUDCFGFILE) + ' ' + QuotedStr(CUSTOMCFGFILE));

  // Update preset card visuals so the Custom card instantly activates
  UpdatePresetCardVisuals;

  // Notification
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
begin
  TSidebarNavHelper(FNavHelper).BuildNavRail;
end;

procedure Tgoverlayform.BuildSettingsButton;
begin
  TSidebarNavHelper(FNavHelper).BuildSettingsButton;
end;

procedure Tgoverlayform.SettingsBtnMouseEnter(Sender: TObject);
begin
  TSidebarNavHelper(FNavHelper).SettingsBtnMouseEnter(Sender);
end;

procedure Tgoverlayform.SettingsBtnMouseLeave(Sender: TObject);
begin
  TSidebarNavHelper(FNavHelper).SettingsBtnMouseLeave(Sender);
end;

procedure Tgoverlayform.SettingsBtnClick(Sender: TObject);
begin
  TSidebarNavHelper(FNavHelper).SettingsBtnClick(Sender);
end;

procedure Tgoverlayform.CubeAutoLaunchMenuItemClick(Sender: TObject);
begin
  TSidebarNavHelper(FNavHelper).CubeAutoLaunchMenuItemClick(Sender);
end;

procedure Tgoverlayform.BuildNavToolToggles;
begin
  TSidebarNavHelper(FNavHelper).BuildNavToolToggles;
end;

procedure Tgoverlayform.BuildSmallToggleImages;
begin
  TSidebarNavHelper(FNavHelper).BuildSmallToggleImages;
end;

procedure Tgoverlayform.NavToolToggleClick(Sender: TObject);
begin
  TSidebarNavHelper(FNavHelper).NavToolToggleClick(Sender);
end;

procedure Tgoverlayform.UpdateNavToolToggleVisibility(AShowLabels: Boolean);
begin
  TSidebarNavHelper(FNavHelper).UpdateNavToolToggleVisibility(AShowLabels);
end;

procedure Tgoverlayform.LoadGameToggleStates;
begin
  TSidebarNavHelper(FNavHelper).LoadGameToggleStates;
end;

function Tgoverlayform.GetGameToolEnabled(const AGameName: string; AToolIdx: Integer): Boolean;
begin
  Result := TSidebarNavHelper(FNavHelper).GetGameToolEnabled(AGameName, AToolIdx);
end;

procedure Tgoverlayform.SetGameToolEnabled(const AGameName: string; AToolIdx: Integer; AEnabled: Boolean);
begin
  TSidebarNavHelper(FNavHelper).SetGameToolEnabled(AGameName, AToolIdx, AEnabled);
end;

procedure Tgoverlayform.ApplyToolEnabledState(AToolIdx: Integer; AEnabled: Boolean);
begin
  TSidebarNavHelper(FNavHelper).ApplyToolEnabledState(AToolIdx, AEnabled);
end;

function Tgoverlayform.ActiveToolIndex: Integer;
begin
  Result := TSidebarNavHelper(FNavHelper).ActiveToolIndex;
end;

procedure Tgoverlayform.SetSaveBtnEnabled(AEnabled: Boolean);
begin
  TSidebarNavHelper(FNavHelper).SetSaveBtnEnabled(AEnabled);
end;

procedure Tgoverlayform.SetControlTreeEnabled(ACtrl: TWinControl; AEnabled: Boolean);
begin
  TSidebarNavHelper(FNavHelper).SetControlTreeEnabled(ACtrl, AEnabled);
end;

procedure Tgoverlayform.RemoveTweaksFromGameFGMod(const AFGModFile: string);
begin
  TSidebarNavHelper(FNavHelper).RemoveTweaksFromGameFGMod(AFGModFile);
end;

procedure Tgoverlayform.RemoveOptiScalerGameFiles(const AGameCfgDir: string);
begin
  TSidebarNavHelper(FNavHelper).RemoveOptiScalerGameFiles(AGameCfgDir);
end;

procedure Tgoverlayform.CopyOptiScalerGameFiles(const AGameCfgDir: string);
begin
  TSidebarNavHelper(FNavHelper).CopyOptiScalerGameFiles(AGameCfgDir);
end;

procedure Tgoverlayform.RestoreNavRailColors;
begin
  TSidebarNavHelper(FNavHelper).RestoreNavRailColors;
end;

procedure Tgoverlayform.SetNavActive(AIndex: Integer);
begin
  TSidebarNavHelper(FNavHelper).SetNavActive(AIndex);
end;

procedure Tgoverlayform.NavItemClick(Sender: TObject);
begin
  TSidebarNavHelper(FNavHelper).NavItemClick(Sender);
end;

procedure Tgoverlayform.NavItemMouseEnter(Sender: TObject);
begin
  TSidebarNavHelper(FNavHelper).NavItemMouseEnter(Sender);
end;

procedure Tgoverlayform.NavItemMouseLeave(Sender: TObject);
begin
  TSidebarNavHelper(FNavHelper).NavItemMouseLeave(Sender);
end;

procedure Tgoverlayform.NavItemPaint(Sender: TObject);
begin
  TSidebarNavHelper(FNavHelper).NavItemPaint(Sender);
end;

procedure Tgoverlayform.ApplyNavCollapsed;
begin
  TSidebarNavHelper(FNavHelper).ApplyNavCollapsed;
end;

procedure Tgoverlayform.NavToggleClick(Sender: TObject);
begin
  TSidebarNavHelper(FNavHelper).NavToggleClick(Sender);
end;

procedure Tgoverlayform.NavAnimTick(Sender: TObject);
begin
  TSidebarNavHelper(FNavHelper).NavAnimTick(Sender);
end;

procedure Tgoverlayform.ApplyNavWidth(AWidth: Integer);
begin
  TSidebarNavHelper(FNavHelper).ApplyNavWidth(AWidth);
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
begin
  TTweaksMD3Helper(FTweaksHelper).InitTweaksCards;
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
var
  GameDirName: string;
begin
  if AGameName = '' then
    GameDirName := 'global'
  else
    GameDirName := SanitizeFileName(AGameName);

  // Use the centralized Flatpak-aware helper so game configs are stored in
  // the same location whether GOverlay is running natively or as Flatpak.
  Result := IncludeTrailingPathDelimiter(TConfigManager.GetHostDataDir) +
            'goverlay/gameconfig/' + GameDirName + '/';
end;

function Tgoverlayform.GetTargetCustomConfigFile: string;
var
  GameCfgDir: string;
begin
  if FActiveGameName <> '' then
  begin
    GameCfgDir := GetGameConfigDir(FActiveGameName);
    if not DirectoryExists(GameCfgDir) then
      ForceDirectories(GameCfgDir);
    Result := GameCfgDir + 'custom.conf';
  end
  else
  begin
    Result := IncludeTrailingPathDelimiter(GetMangoHudConfigDir()) + 'custom.conf';
  end;
end;

function Tgoverlayform.GetActiveCustomConfigFile: string;
var
  GameCfgDir, GameCustom: string;
begin
  if FActiveGameName <> '' then
  begin
    GameCfgDir := GetGameConfigDir(FActiveGameName);
    GameCustom := GameCfgDir + 'custom.conf';
    if FileExists(GameCustom) then
      Exit(GameCustom);
  end;
  Result := IncludeTrailingPathDelimiter(GetMangoHudConfigDir()) + 'custom.conf';
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
  if IsPasCubeAvailable then
  begin
    try
      DeleteFile(IncludeTrailingPathDelimiter(TConfigManager.GetGoverlayFolder) + 'benchmark_debug.log');
    except
    end;
    DbgLog('*** PREVIEW BUTTON CLICK - RUNNING PASCUBE ***');
    RestoreIfMaximized;
    ExecuteGUICommand(GetMangoHudLaunchEnv + GetVkBasaltLaunchEnv + GetVkSumiLaunchEnv + GetGOverlayPackageEnv + GetPasCubeCommand + ' --version "' + GVERSION + '"' + GetPasCubeNicknameParam + ' &');
    FBenchmarkWasRunning := True;
    FBenchmarkStarted := False;
    FBenchmarkStartTicks := 0;
    FBenchmarkTimer.Enabled := True;
  end
  else if IsCommandAvailable('vkcube') then
  begin
    RestoreIfMaximized;
    ExecuteGUICommand(GetMangoHudLaunchEnv + GetVkBasaltLaunchEnv + GetVkSumiLaunchEnv + 'vkcube &');
  end
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
  Expand, ExpandIdx: Integer;
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
  for ExpandIdx := 0 to FHoveredCard.ControlCount - 1 do
    if (FHoveredCard.Controls[ExpandIdx] is TImage) and (FHoveredCard.Controls[ExpandIdx].Tag <> 9990) then
    begin
      TImage(FHoveredCard.Controls[ExpandIdx]).SetBounds(0, 0, CARD_W + 2 * Expand, CARD_H + 2 * Expand);
      if FHoveredCard.Controls[ExpandIdx].Tag = 9995 then Break;
    end;

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
  ConfigPath, ConfigDir: string;
begin
  try
    ConfigPath := GetConfigFilePath;
    ConfigDir := ExtractFilePath(ConfigPath);

    if not DirectoryExists(ConfigDir) then
      ForceDirectories(ConfigDir);

    IniFile := TIniFile.Create(ConfigPath);
    try
      // Always update config with the current version
      IniFile.WriteString('General', 'Version', GVERSION);
    finally
      IniFile.Free;
    end;
  except
    // Fail silently so startup isn't aborted
  end;
end;

procedure Tgoverlayform.CheckAndShowChangelog;
var
  IniFile: TIniFile;
  ConfigPath, ConfigDir, SeenVer, ReleaseNotesText: string;
begin
  try
    ConfigPath := GetConfigFilePath;
    ConfigDir := ExtractFilePath(ConfigPath);
    if not DirectoryExists(ConfigDir) then
      ForceDirectories(ConfigDir);

    IniFile := TIniFile.Create(ConfigPath);
    try
      SeenVer := IniFile.ReadString('General', 'ChangelogSeenVersion', '');
      if SeenVer <> GVERSION then
      begin
        ReleaseNotesText := GetReleaseNotes(GVERSION);
        ShowChangelogPopup(GVERSION, ReleaseNotesText);
        IniFile.WriteString('General', 'ChangelogSeenVersion', GVERSION);
      end;
    finally
      IniFile.Free;
    end;
  except
    // Fail silently so startup isn't aborted
  end;
end;

procedure Tgoverlayform.ShowChangelogAsync(Data: PtrInt);
begin
  CheckAndShowChangelog;
end;

procedure Tgoverlayform.whatsNewMenuItemClick(Sender: TObject);
var
  ReleaseNotesText: string;
begin
  ReleaseNotesText := GetReleaseNotes(GVERSION);
  ShowChangelogPopup(GVERSION, ReleaseNotesText);
end;

procedure Tgoverlayform.RefreshGameCardsAsync(Data: PtrInt);
begin
  TGamesTabHelper(FGamesHelper).RefreshGameCardsAsync(Data);
end;

procedure Tgoverlayform.PatchGameFGModWineDllOverrides(const AFGModFile: string; AEnabled: Boolean);
begin
  // Obsolete: bgmod handles OptiScaler overrides natively
end;

procedure Tgoverlayform.PatchGameFGModConditionalExport(const AFGModFile, AConditionalLine, ASearchKey: string);
begin
  // Obsolete: bgmod handles tool conditionals natively
end;

procedure Tgoverlayform.PatchGameFGModConfigPath(const AFGModFile, AEnvVar, AConfigPath: string);
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

procedure Tgoverlayform.EnsureGameFGModOptiScalerConditional(const AFGModFile: string);
begin
  // Obsolete: bgmod binary manages OptiScaler conditional logic natively.
end;

function IsProcessRunningPure(const ProcName: string): Boolean;
var
  SR: TSearchRec;
  Pid: Integer;
  CommPath, Name: string;
  SL: TStringList;
begin
  Result := False;
  if FindFirst('/proc/*', faDirectory, SR) = 0 then
  begin
    try
      repeat
        if (SR.Attr and faDirectory = faDirectory) and TryStrToInt(SR.Name, Pid) then
        begin
          CommPath := '/proc/' + SR.Name + '/comm';
          if FileExists(CommPath) then
          begin
            SL := TStringList.Create;
            try
              SL.LoadFromFile(CommPath);
              if SL.Count > 0 then
              begin
                Name := Trim(SL[0]);
                if Name = ProcName then
                begin
                  Result := True;
                  Break;
                end;
              end;
            finally
              SL.Free;
            end;
          end;
        end;
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
  end;
end;

procedure Tgoverlayform.BenchmarkTimerTick(Sender: TObject);
var
  ProcCheck: TProcess;
  IsRunning: Boolean;
  ExitCode: Integer;
begin
  DbgLog(Format('BenchmarkTimerTick: WasRunning=%d Started=%d StartTicks=%d', 
    [Ord(FBenchmarkWasRunning), Ord(FBenchmarkStarted), FBenchmarkStartTicks]));

  if not FBenchmarkWasRunning then
  begin
    FBenchmarkTimer.Enabled := False;
    DbgLog('BenchmarkTimerTick: FBenchmarkWasRunning is False. Disabling timer.');
    Exit;
  end;

  // Primary check: Pure Pascal proc search
  IsRunning := IsProcessRunningPure('pascube');
  DbgLog(Format('BenchmarkTimerTick: IsProcessRunningPure = %d', [Ord(IsRunning)]));

  if not IsRunning then
  begin
    // Fallback: pgrep check
    ProcCheck := TProcess.Create(nil);
    try
      ProcCheck.CommandLine := 'pgrep -x pascube';
      ProcCheck.Options := [poWaitOnExit];
      ProcCheck.Execute;
      ExitCode := ProcCheck.ExitStatus;
      DbgLog(Format('BenchmarkTimerTick: pgrep fallback exit code = %d', [ExitCode]));
      if ExitCode = 0 then
        IsRunning := True;
    except
      on E: Exception do
      begin
        DbgLog('BenchmarkTimerTick: Exception during pgrep execute: ' + E.Message);
      end;
    end;
    ProcCheck.Free;
  end;

  DbgLog(Format('BenchmarkTimerTick: Final IsRunning=%d', [Ord(IsRunning)]));

  if IsRunning then
  begin
    if not FBenchmarkStarted then
    begin
      FBenchmarkStarted := True;
      DbgLog('BenchmarkTimerTick: pascube started successfully in process table.');
    end;
  end
  else
  begin
     if FBenchmarkStarted then
     begin
       FBenchmarkTimer.Enabled := False;
       FBenchmarkWasRunning := False;
       DbgLog('BenchmarkTimerTick: pascube terminated. Results shown in PasCube overlay.');
       CopyPasCubeLogs;
     end
     else
     begin
       Inc(FBenchmarkStartTicks);
       if FBenchmarkStartTicks > 15 then
       begin
         FBenchmarkTimer.Enabled := False;
         FBenchmarkWasRunning := False;
         DbgLog('BenchmarkTimerTick: pascube failed to start within 15 seconds. Aborting.');
       end;
     end;
   end;
 end;

procedure Tgoverlayform.CopyPasCubeLogs;
var
  PasCubeDir, LogsDir, SrcDebug, SrcThread, DestDebug, DestThread: string;
  PasCubeCmd: string;
begin
  try
    LogsDir := TConfigManager.GetGoverlayLogsDir;
    TConfigManager.EnsureDirectoryExists(LogsDir);

    PasCubeCmd := GetPasCubeCommand;
    PasCubeDir := ExtractFilePath(PasCubeCmd);
    if PasCubeDir = '' then
      PasCubeDir := ExtractFilePath(ParamStr(0));

    SrcDebug := IncludeTrailingPathDelimiter(PasCubeDir) + 'pascube_debug.log';
    SrcThread := IncludeTrailingPathDelimiter(PasCubeDir) + 'pascube_thread.log';
    DestDebug := IncludeTrailingPathDelimiter(LogsDir) + 'pascube_debug.log';
    DestThread := IncludeTrailingPathDelimiter(LogsDir) + 'pascube_thread.log';

    if FileExists(SrcDebug) then
    begin
      CopyFile(SrcDebug, DestDebug);
      DbgLog('CopyPasCubeLogs: copied pascube_debug.log to ' + DestDebug);
    end
    else
      DbgLog('CopyPasCubeLogs: pascube_debug.log not found at ' + SrcDebug);

    if FileExists(SrcThread) then
    begin
      CopyFile(SrcThread, DestThread);
      DbgLog('CopyPasCubeLogs: copied pascube_thread.log to ' + DestThread);
    end
    else
      DbgLog('CopyPasCubeLogs: pascube_thread.log not found at ' + SrcThread);
  except
    on E: Exception do
      DbgLog('CopyPasCubeLogs: exception: ' + E.Message);
  end;
end;

end.
