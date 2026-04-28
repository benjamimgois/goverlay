unit overlayunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, Forms, Controls, Graphics, Dialogs, ExtCtrls, Math,
  unix, BaseUnix, StdCtrls, Spin, ComCtrls, Buttons, ActnList, Menus, aboutunit, optiscaler_update, protontricksunit,
  blacklistUnit, LCLtype, Clipbrd, LCLIntf,
  FileUtil, StrUtils, Types, fpjson, jsonparser, git2pas, howto, themeunit, systemdetector, constants,
  fgmod_resources, hintsunit, qt6, qtwidgets, fpreadjpeg, configmanager, IntfGraphics, Grids,
  configkeys, configfile, uihelpers, apputils;



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
    procedure LoadMangoHudConfig;
    procedure SaveMangoHudConfig;
    procedure SaveMangoHudPreset(PresetNumber: Integer);
    procedure LoadOptiScalerConfig;
    procedure LoadFakeNvapiConfig;
    procedure LoadFgmodConfig;

  private
    FLaunchCommand: string;
    FCommandCopiedTime: QWord;
    FOptiscalerUpdate: TOptiscalerTab;
    FReshadeProgressBar: TProgressBar;
    FReshadePhaseLabel: TLabel;
    FStatusTimer: TTimer;
    FGamesScrollBox: TScrollBox;
    FGamesPanel: TPanel;
    FGamesLoaded: Boolean;
    FCoverThread: TThread;
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
    FActiveGameName:    string;   // non-empty when editing a game-specific config
    FPreviewBtn:        TBitBtn;  // bottom-bar quick preview button (pascube/vkcube)
    FGameThumbBmp:      TBitmap;              // game cover drawn on the sidebar paintbox
    FGlobalThumbPng:    TPortableNetworkGraphic; // global-config icon (white, transparent)
    FGameCardMenu: TPopupMenu;      // right-click context menu for game cards
    FRightClickedCard: TPanel;      // card that triggered the context menu
    FMangoIconGfx: TPortableNetworkGraphic;  // cached badge icon for MangoHud
    FOptiIconGfx:  TPortableNetworkGraphic;  // cached badge icon for OptiScaler

    // Nav rail
    FNavItems:       array of TPanel;    // item panels
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
    FCubeAutoLaunch:     Boolean;    // whether to auto-launch pascube/vkcube

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

    // OptiScaler tab card redesign (GroupBox-level reparenting)
    FOsScrollBox:    TScrollBox;
    FOsBgPanel:      TPanel;     // inner panel — paints BG color reliably in Qt6
    FOsGpuCard:      TPanel;
    FOsOptionsCard:  TPanel;
    FOsStatusCard:   TPanel;
    FOsOptiSec:      TPanel;   // replaces optiscalerGroupBox as visual container
    FOsImgSec:       TPanel;   // replaces imgmenuGroupBox
    FOsFakeSec:      TPanel;   // replaces fakenvapiGroupBox

    // Metrics tab card redesign
    FMtScrollBox:    TScrollBox;
    FMtBgPanel:      TPanel;
    FMtGpuCard:      TPanel;
    FMtCpuCard:      TPanel;

    // Custom env groupbox (Tweaks tab)
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
    FTweaksCatExpanded: array[0..2] of Boolean; // General, Graphics, Performance
    FAntilagCheckBox:  TCheckBox;  // ENABLE_LAYER_MESA_ANTI_LAG=1
    FFSR4UpgradeCheckBox: TCheckBox;   // PROTON_FSR4_UPGRADE=1
    FDLSSUpgradeCheckBox: TCheckBox;   // PROTON_DLSS_UPGRADE=1
    FXeSSUpgradeCheckBox: TCheckBox;   // PROTON_XESS_UPGRADE=1
    FReEngineRTCheckBox: TCheckBox;    // RE Engine RT workaround

    // Software Status visual indicators (fresh controls; source labels stay hidden)
    FOsStatDots:     array[0..5] of TShape;   // 0=OptiScaler 1=FakeNVAPI 2=FSR 3=XeSS 4=DLSS 5=OptiPatcher
    FOsStatNameLbls: array[0..5] of TLabel;
    FOsStatVerLbls:  array[0..5] of TLabel;

    // Per-tool enable toggles (game mode only) — indices 0=MangoHud 1=vkBasalt 2=OptiScaler 3=Tweaks
    FNavToolBtns:    array[0..3] of TSpeedButton;
    FNavToolEnabled: array[0..3] of Boolean;
    FNavToolImgListSmall: TImageList;  // smaller ON/OFF icons for collapsed nav

    // FPS Limit custom input (replaces chip grid)
    FFpsLimitEdit:   TEdit;              // comma-separated FPS values

    // Home tab
    FHomeTabSheet:     TTabSheet;
    FHomeModDots:      array[0..2] of TShape;   // status dots: MangoHud, vkBasalt, OptiScaler
    FHomeModVerLbls:   array[0..2] of TLabel;   // version text
    FHomeOptiLbls:     array[0..4] of TLabel;   // library version labels: FakeNvAPI, Optipatcher, FSR, XeSS, DLSS
    FHomeLibDots:      array[0..4] of TShape;   // library status dots
    FHomeDepDots:      array[0..6] of TShape;
    FHomeDepLbls:      array[0..6] of TLabel;
    FHomeGlobalBtn:    TPanel;
    FHomeBtnRow:       TPanel;

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
    
    // Key capture references — each button shows the captured shortcut in its caption
    FCaptureBtn:        TBitBtn;  // button currently being captured
    FVisualCaptureBtn:  TBitBtn;
    FLimitCaptureBtn:   TBitBtn;
    FLoggingCaptureBtn: TBitBtn;
    FVkToggleCaptureBtn:    TBitBtn;
    FOsShortcutCaptureBtn:  TBitBtn;
    FCaptureForm:       TForm;

    // Extras tab code-generated layout
    FExtScrollBox:  TScrollBox;
    FExtBgPanel:    TPanel;
    FExtSysCard:    TPanel;   // wrapper card for systemGroupBox
    FExtLogCard:    TPanel;   // wrapper card for loggingGroupBox

    // Performance tab code-generated cards
    FPerfCards:   array[0..3] of TPanel;
    FPerfRightLbl:array[0..1] of TLabel;  // right-section title labels
    FVsyncRows:   array[0..1] of TPanel;  // Vulkan/OpenGL row chips



    procedure BuildNavRail;
    procedure BuildPresetsWrapper;
    procedure AddNavyBgToTab(ATab: TTabSheet);
    procedure StyleGroupBoxNavy(GB: TGroupBox);
    procedure PresetsBgBoxPaint(Sender: TObject);
    procedure PresetsWrapperPaint(Sender: TObject);
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
    procedure LoadGameToggleStates;
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
    procedure EnsureGameFGModOptiScalerConditional(const AFGModFile: string);
    procedure NavItemClick(Sender: TObject);
    procedure NavItemMouseEnter(Sender: TObject);
    procedure NavItemMouseLeave(Sender: TObject);
    procedure NavItemPaint(Sender: TObject);
    procedure SetNavActive(AIndex: Integer);
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
    procedure SubCardPaint(Sender: TObject);
    procedure UpdateVisualCardTheme;
    procedure CaptureBtnClick(Sender: TObject);
    procedure CaptureFormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure InitPerformanceTab;
    procedure InitExtrasTab;
    procedure InitOptiScalerTab;
    procedure BuildFpsLimitEdit;
    procedure UpdatePerfCardTheme;
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
    procedure DrawCardRibbon(Bmp: TBitmap; BadgeMask: Integer);
    function  GetGameConfigDir(const AGameName: string): string;
    function  SanitizeFileName(const AName: string): string;
    function  GetMangoHudConfigEnvPrefix: string;
    function  GetMangoHudLaunchEnv: string;
    function  GetVkBasaltConfigEnvPrefix: string;
    function  GetVkBasaltLaunchEnv: string;
    procedure UpdateGameContextLabel;
    procedure PreviewBtnClick(Sender: TObject);
    procedure LoadGlobalThumb;
    procedure ShowGameThumb(ACard: TPanel);
    procedure HideGameThumb;
    procedure ApplyCardBrightness(ACard: TPanel; BrightFactor: Integer);
    procedure ApplyAllCardsDim;
    procedure HoverTimerTick(Sender: TObject);
    function ParseAcfValue(const AContent, AKey: string): string;
    procedure GetSteamLibraries(Libraries: TStringList);

    function GetGeneralCheckBox(Index: Integer): TCheckBox;
    function GetGraphicsCheckBox(Index: Integer): TCheckBox;
    function GetPerformanceCheckBox(Index: Integer): TCheckBox;
    function OsHexToKeyStr(const HexStr: string): string;
    procedure ReshadeGitProgress(APhase: string; APercent: Integer);
    procedure UpdateGeSpeedButtonState;
    procedure UpdateGlobalEnableMenuItemVisibility;
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
    function TweaksMD3ItemHeight: Integer;
    function TweaksMD3HeaderHeight: Integer;
    procedure ApplyImageAntialiasing;
    function IsOptiScalerInstalled: Boolean;
    
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
    procedure HomeChannelComboChange(Sender: TObject);
    function  GetMangoHudVersion: string;
    function  GetVkBasaltVersion: string;
    function  FindBinPath(const BinName: string): string;
    function  FindLibPath(const LibName: string): string;

    // Keyboard shortcuts
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    
    // Status bar and search
    procedure ShowStatusMessage(const AMessage: string; ADuration: Integer = 3000);
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

    // MangoHud config loading helpers
    procedure LoadMangoHudBoolFlag(const ATrimmedLine: string);
    procedure LoadMangoHudKeyValue(const AKey, AValue: string);
  public


  end;





var
  goverlayform: Tgoverlayform;

  // ============================================================================
  // DESIGN SYSTEM CONSTANTS
  // ============================================================================
var
  // ============================================================================
  // APPLICATION STATE AND VERSION
  // ============================================================================
  GLatestVersion: string = '';          // Latest available Goverlay version from GitHub
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
procedure ProcessCoverBitmap(Bmp: TBitmap; GradH: Integer); forward;

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
type
  TCoverDownloadThread = class(TThread)
  private
    FAppIDs:   TStringList;
    FImages:   TList;
    FCacheDir: string;
    FForm:     Tgoverlayform;
    FCurrentImage: TImage;
    FCurrentPath:  string;
    procedure DoUpdateImage;
  protected
    procedure Execute; override;
  public
    constructor Create(AAppIDs: TStringList; AImages: TList;
                       const ACacheDir: string; AForm: Tgoverlayform);
    destructor Destroy; override;
  end;

constructor TCoverDownloadThread.Create(AAppIDs: TStringList; AImages: TList;
  const ACacheDir: string; AForm: Tgoverlayform);
begin
  inherited Create(True);
  FAppIDs   := AAppIDs;
  FImages   := AImages;
  FCacheDir := ACacheDir;
  FForm     := AForm;
  FreeOnTerminate := False;
end;

destructor TCoverDownloadThread.Destroy;
begin
  FAppIDs.Free;
  FImages.Free;
  inherited;
end;

procedure TCoverDownloadThread.DoUpdateImage;
var
  ScaledBmp: TBitmap;
  CardPanel: TPanel;
  CardIdx: Integer;
begin
  if not Assigned(FCurrentImage) or not FileExists(FCurrentPath) then Exit;
  try
    FCurrentImage.Picture.LoadFromFile(FCurrentPath);
    if (FCurrentImage.Picture.Graphic = nil) or
       (FCurrentImage.Picture.Graphic.Width = 0) then Exit;
    ScaledBmp := TBitmap.Create;
    try
      ScaledBmp.SetSize(CARD_W, CARD_H);
      ScaledBmp.Canvas.StretchDraw(
        Rect(0, 0, CARD_W, CARD_H), FCurrentImage.Picture.Graphic);
      ProcessCoverBitmap(ScaledBmp, GRAD_H);
      FCurrentImage.Picture.Bitmap.Assign(ScaledBmp);
      // Update FOrigCovers so hover brightness uses the processed image
      if Assigned(FForm) and Assigned(FForm.FCardPanels) and
         Assigned(FForm.FOrigCovers) and (FCurrentImage.Parent is TPanel) then
      begin
        CardPanel := TPanel(FCurrentImage.Parent);
        CardIdx := FForm.FCardPanels.IndexOf(CardPanel);
        if (CardIdx >= 0) and (CardIdx < FForm.FOrigCovers.Count) then
        begin
          if FForm.FOrigCovers[CardIdx] <> nil then
            TLazIntfImage(FForm.FOrigCovers[CardIdx]).Free;
          FForm.FOrigCovers[CardIdx] := ScaledBmp.CreateIntfImage;
        end;
      end;
    finally
      ScaledBmp.Free;
    end;
    // Dim cover to match the default un-hovered state
    if Assigned(FForm) and (FCurrentImage.Parent is TPanel) then
      FForm.ApplyCardBrightness(TPanel(FCurrentImage.Parent), 100);
  except
  end;
end;

procedure TCoverDownloadThread.Execute;
var
  i: Integer;
  AppID, OutPath, Url: string;
  Proc: TProcess;
begin
  ForceDirectories(FCacheDir);
  for i := 0 to FAppIDs.Count - 1 do
  begin
    if Terminated then Break;

    AppID   := FAppIDs[i];
    OutPath := FCacheDir + AppID + '.jpg';

    if FileExists(OutPath) then
    begin
      FCurrentImage := TImage(FImages[i]);
      FCurrentPath  := OutPath;
      Synchronize(@DoUpdateImage);
      Continue;
    end;

    // Try portrait cover first, then header
    Url := 'https://cdn.akamai.steamstatic.com/steam/apps/' + AppID + '/library_600x900.jpg';
    Proc := TProcess.Create(nil);
    try
      Proc.Executable := 'curl';
      Proc.Parameters.Add('-s');
      Proc.Parameters.Add('-L');
      Proc.Parameters.Add('--max-time');
      Proc.Parameters.Add('15');
      Proc.Parameters.Add('--fail');
      Proc.Parameters.Add('-o');
      Proc.Parameters.Add(OutPath);
      Proc.Parameters.Add(Url);
      Proc.Options := [poWaitOnExit, poNoConsole];
      Proc.Execute;
      if not FileExists(OutPath) or (Proc.ExitCode <> 0) then
      begin
        // Fallback to header image
        DeleteFile(OutPath);
        Proc.Parameters.Clear;
        Url := 'https://cdn.akamai.steamstatic.com/steam/apps/' + AppID + '/header.jpg';
        Proc.Parameters.Add('-s');
        Proc.Parameters.Add('-L');
        Proc.Parameters.Add('--max-time');
        Proc.Parameters.Add('15');
        Proc.Parameters.Add('--fail');
        Proc.Parameters.Add('-o');
        Proc.Parameters.Add(OutPath);
        Proc.Parameters.Add(Url);
        Proc.Execute;
      end;
    finally
      Proc.Free;
    end;

    if FileExists(OutPath) and (FileSize(OutPath) > 0) then
    begin
      FCurrentImage := TImage(FImages[i]);
      FCurrentPath  := OutPath;
      Synchronize(@DoUpdateImage);
    end;
  end;
end;

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
    // Native: mangohud binary (all distros install it to PATH)
    if not IsCommandAvailable('mangohud') then
      Missing.Add('mangohud');

    // vkBasalt: check Vulkan layer JSON (distro-agnostic) then fall back to library scan
    if not FileExists('/usr/share/vulkan/implicit_layer.d/vkBasalt.json') and
       not FileExists('/etc/vulkan/implicit_layer.d/vkBasalt.json') and
       not IsLibraryAvailable('libvkbasalt') then
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

  //check if protontricks is available
  // Skip check in Flatpak since we fallback to com.github.Matoking.protontricks Flatpak
  if not IsRunningInFlatpak then
  begin
    if not IsCommandAvailable('protontricks') then
      Missing.Add('protontricks');
  end;

  //check if gamemoderun is available (required for GameMode feature in Tweaks tab)
  // Skip check in Flatpak since gamemoderun is on the host and we can't reliably detect it
  if not IsRunningInFlatpak then
  begin
    if not IsCommandAvailable('gamemoderun') then
      Missing.Add('gamemode');
  end;

  // Check for libqt6pas (Qt6 Pascal bindings — required for Goverlay GUI).
  // Arch installs it as libQt6Pas.so; other distros use libqt6pas.so.
  // IsLibraryAvailable checks both via case-insensitive ldconfig + path scan.
  if not IsLibraryAvailable('libQt6Pas') then
    Missing.Add('libqt6pas');

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
  end;

  // Reload UI from the correct config file (VKBASALTCFGFILE was just updated above)
  LoadVkBasaltConfig;

  SetNavActive(2);

  //Disable tabs
  goverlayPageControl.ShowTabs:=false;
  optiscalertabsheet.TabVisible:=false; //disable optiscaler tab
  tweakstabsheet.TabVisible:=false;
  gamesTabSheet.TabVisible:=false; //disable games tab

  vkbasalttabsheet.TabVisible:=true;
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
  SS := 'background-color: rgb(26,30,46); border: 1px solid rgb(36,40,62); color: white;';
  QWidget_setStyleSheet(TQtWidget(GB.Handle).Widget, @SS);
end;

procedure Tgoverlayform.PresetsBgBoxPaint(Sender: TObject);
var
  PB: TPaintBox;
begin
  PB := TPaintBox(Sender);
  PB.Canvas.Brush.Color := RGBToColor(22, 26, 40);
  PB.Canvas.FillRect(Rect(0, 0, PB.Width, PB.Height));
end;

procedure Tgoverlayform.PresetsWrapperPaint(Sender: TObject);
var
  P: TPanel;
begin
  P := TPanel(Sender);
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

    // Body: R=22, G=26, B=40 — cool dark navy, like reference images
    OffBmp.Canvas.Brush.Color := RGBToColor(22, 26, 40);
    OffBmp.Canvas.FillRect(Rect(0, 0, TWidth, THeight));

    // Left specular — 1px white-ish (frosted-glass edge)
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
  OptiCfg: TConfigFile;
  OptiScalerIniPath: string;
  Value: string;
  FloatValue: Double;
  FS: TFormatSettings;
begin
  if FActiveGameName <> '' then
    OptiScalerIniPath := GetGameConfigDir(FActiveGameName) + 'OptiScaler.ini'
  else
    OptiScalerIniPath := GetOptiScalerInstallPath + PathDelim + 'OptiScaler.ini';

  if not FileExists(OptiScalerIniPath) then
    Exit;

  OptiCfg := TConfigFile.Create;
  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';
  try
    if not OptiCfg.Load(OptiScalerIniPath) then
      Exit;

    Value := OptiCfg.GetValue(OPTI_KEY_SHORTCUT, '');
    if SameText(Value, 'auto') or (Value = '') then
      shortcutkeyComboBox.Text := '0x2d'
    else
      shortcutkeyComboBox.Text := Value;
    if Assigned(FOsShortcutCaptureBtn) then
      FOsShortcutCaptureBtn.Caption := '⌨ ' + OsHexToKeyStr(shortcutkeyComboBox.Text);

    Value := OptiCfg.GetValue(OPTI_KEY_SCALE, '');
    if TryStrToFloat(Value, FloatValue, FS) then
    begin
      menuscaleTrackBar.Position := Round(FloatValue * 10);
      menuscalevalueLabel.Caption := FormatFloat('#0.0', menuscaleTrackBar.Position / 10);
    end;

    overrideCheckBox.Checked := SameText(OptiCfg.GetValue(OPTI_KEY_OVERRIDE_NVAPI, ''), 'true');
    optipatcherCheckBox.Checked := SameText(OptiCfg.GetValue(OPTI_KEY_LOAD_ASI, ''), 'true');

    if SameText(OptiCfg.GetValue(OPTI_KEY_FSR4_UPDATE, ''), 'true') then
      fsrversionComboBox.ItemIndex := 0;

    spoofCheckBox.Checked := SameText(OptiCfg.GetValue(OPTI_KEY_DXGI, ''), 'auto');
  finally
    OptiCfg.Free;
  end;
end;

procedure Tgoverlayform.LoadFakeNvapiConfig;
var
  FakeCfg: TConfigFile;
  FakeNvapiIniPath: string;
  Value: string;
begin
  if FActiveGameName <> '' then
    FakeNvapiIniPath := GetGameConfigDir(FActiveGameName) + 'fakenvapi.ini'
  else
    FakeNvapiIniPath := GetOptiScalerInstallPath + PathDelim + 'fakenvapi.ini';

  if not FileExists(FakeNvapiIniPath) then
    Exit;

  FakeCfg := TConfigFile.Create;
  try
    if not FakeCfg.Load(FakeNvapiIniPath) then
      Exit;

    Value := FakeCfg.GetValue(FAKE_KEY_FORCE_REFLEX, '0');
    if Value = '0' then
    begin
      forcereflexCheckBox.Checked := False;
      reflexComboBox.ItemIndex := 0;
    end
    else
    begin
      forcereflexCheckBox.Checked := True;
      case Value of
        '1': reflexComboBox.ItemIndex := 1;
        '2': reflexComboBox.ItemIndex := 2;
      else
        reflexComboBox.ItemIndex := 0;
      end;
    end;
    reflexComboBox.Enabled := forcereflexCheckBox.Checked;

    forcelatencyflexCheckBox.Checked := (FakeCfg.GetValue(FAKE_KEY_FORCE_LATENCY, '0') = '1');
    latencyflexComboBox.Enabled := forcelatencyflexCheckBox.Checked;

    if forcelatencyflexCheckBox.Checked then
    begin
      case FakeCfg.GetValue(FAKE_KEY_LATENCY_MODE, '0') of
        '0': latencyflexComboBox.ItemIndex := 0;
        '1': latencyflexComboBox.ItemIndex := 1;
        '2': latencyflexComboBox.ItemIndex := 2;
      else
        latencyflexComboBox.ItemIndex := 0;
      end;
    end;

    tracelogCheckBox.Checked := (FakeCfg.GetValue(FAKE_KEY_TRACE_LOGS, '0') = '1');
  finally
    FakeCfg.Free;
  end;
end;

procedure Tgoverlayform.LoadFgmodConfig;
var
  ConfigLines: TStringList;
  Line, TrimmedLine, DllName, Key, Value, VarsPath, FsrVer: string;
  i, SepPos: Integer;
  FgmodPath: string;
  DxilSpirvFound: Boolean;
begin
  // Get fgmod file path
  if FActiveGameName <> '' then
    FgmodPath := GetGameConfigDir(FActiveGameName) + 'fgmod'
  else
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

  // Restore fsrversionComboBox from goverlay.vars (game-specific or global)
  if FActiveGameName <> '' then
    VarsPath := IncludeTrailingPathDelimiter(GetGameConfigDir(FActiveGameName)) + 'goverlay.vars'
  else
    VarsPath := IncludeTrailingPathDelimiter(GetOptiScalerInstallPath) + 'goverlay.vars';

  if FileExists(VarsPath) then
  begin
    ConfigLines := TStringList.Create;
    try
      ConfigLines.LoadFromFile(VarsPath);
      FsrVer := '';
      for i := 0 to ConfigLines.Count - 1 do
      begin
        TrimmedLine := Trim(ConfigLines[i]);
        SepPos := Pos('=', TrimmedLine);
        if SepPos > 0 then
        begin
          Key   := Copy(TrimmedLine, 1, SepPos - 1);
          Value := Copy(TrimmedLine, SepPos + 1, Length(TrimmedLine));
          if SameText(Key, 'fsrversion') then
          begin
            FsrVer := Value;
            Break;
          end;
        end;
      end;
      if FsrVer = '4.0.2c (INT8)' then
        fsrversionComboBox.ItemIndex := 1
      else
        fsrversionComboBox.ItemIndex := 0; // Latest (FP8) is the default
    finally
      ConfigLines.Free;
    end;
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
      if (Length(TrimmedLine) > 8) and (Copy(TrimmedLine, 1, 8) = MANGO_COMMENT_OFFSET) then
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
        LoadMangoHudBoolFlag(TrimmedLine);
        Continue;
      end;

      // Keys with value
      Key := Trim(Copy(TrimmedLine, 1, ColonPos - 1));
      Value := Trim(Copy(TrimmedLine, ColonPos + 1, Length(TrimmedLine)));

      // Remove quotes if present
      if (Length(Value) > 0) and (Value[1] = '"') then
        Value := StringReplace(Value, '"', '', [rfReplaceAll]);

      LoadMangoHudKeyValue(Key, Value);
    end;

  finally
    ConfigLines.Free;
  end;

  // Sync FPS chip visuals with the newly loaded checkgroup state
  UpdatePerfCardTheme;
end;



procedure Tgoverlayform.LoadMangoHudBoolFlag(const ATrimmedLine: string);
begin
  if SameText(ATrimmedLine, MANGO_FLAG_HORIZONTAL) then
    horizontalRadioButton.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_NO_DISPLAY) then
    hidehudCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_HUD_COMPACT) then
    hudcompactCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_FPS) then
    fpsCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_FRAME_TIMING) then
    frametimegraphCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_SHOW_FPS_LIMIT) then
    showfpslimCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_FRAME_COUNT) then
    framecountCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_HISTOGRAM) then
  begin
    frametimetypeBitBtn.ImageIndex := 7;
    frametimetypeBitBtn.Caption := 'Histogram';
  end
  else if SameText(ATrimmedLine, MANGO_FLAG_GPU_STATS) then
    gpuavgloadCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_GPU_LOAD_CHANGE) then
    gpuloadcolorCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_VRAM) then
    vramusageCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_GPU_CORE_CLOCK) then
    gpufreqCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_GPU_MEM_CLOCK) then
    gpumemfreqCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_GPU_TEMP) then
    gputempCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_GPU_MEM_TEMP) then
    gpumemtempCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_GPU_JUNCTION_TEMP) then
    gpujunctempCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_GPU_FAN) then
    gpufanCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_GPU_POWER) then
    gpupowerCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_GPU_POWER_LIMIT) then
    gpupowerlimitCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_GPU_EFFICIENCY) then
    gpuefficiencyCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_FLIP_EFFICIENCY) then
  begin
    gpuframesjouleBitBtn.Caption := 'Joules / Frame';
    cpuframesjouleBitBtn.Caption := 'Joules / Frame';
  end
  else if SameText(ATrimmedLine, MANGO_FLAG_GPU_VOLTAGE) then
    gpuvoltageCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_THROTTLING) then
    gputhrottlingCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_THROTTLING_GRAPH) then
    gputhrottlinggraphCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_GPU_NAME) then
    gpumodelCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_VULKAN_DRIVER) then
    vulkandriverCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_CPU_STATS) then
    cpuavgloadCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_CPU_LOAD_CHANGE) then
    cpuloadcolorCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_CORE_LOAD) then
    cpuloadcoreCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_CORE_BARS) then
  begin
    coreloadtypeBitBtn.ImageIndex := 7;
    coreloadtypeBitBtn.Caption := 'Graph';
  end
  else if SameText(ATrimmedLine, MANGO_FLAG_CPU_MHZ) then
    cpufreqCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_CPU_TEMP) then
    cputempCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_CPU_POWER) then
    cpupowerCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_CPU_EFFICIENCY) then
    cpuefficiencyCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_CORE_TYPE) then
    cpucoretypeCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_RAM) then
    ramusageCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_IO_READ) then
    diskioCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_IO_WRITE) then
    diskioCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_PROCMEM) then
    procmemCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_PROC_VRAM) then
    procvramCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_SWAP) then
    swapusageCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_RAM_TEMP) then
    ramtempCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_ARCH) then
    archCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_RESOLUTION) then
    resolutionCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_WINE) then
    wineCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_ENGINE_VERSION) then
    engineversionCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_ENGINE_SHORT) then
    engineshortCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_GAMEMODE) then
    gamemodestatusCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_VKBASALT) then
    vkbasaltstatusCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_FCAT) then
    fcatCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_FEX_STATS) then
    fexstatsCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_FSR) then
    fsrCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_HDR) then
    hdrCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_REFRESH_RATE) then
    refreshrateCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_BATTERY) then
    batteryCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_BATTERY_WATT) then
    batterywattCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_BATTERY_TIME) then
    batterytimeCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_MEDIA_PLAYER) then
    mediaCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_TEMP_FAHRENHEIT) then
    fahrenheitCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_WINESYNC) then
    winesyncCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_PRESENT_MODE) then
    vpsCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_LOG_VERSIONING) then
    versioningCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_UPLOAD_LOGS) then
    autouploadCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_FPS_COLOR_CHANGE) then
    fpscolorCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_BICUBIC) then
    filterRadioGroup.ItemIndex := 1
  else if SameText(ATrimmedLine, MANGO_FLAG_TRILINEAR) then
    filterRadioGroup.ItemIndex := 2
  else if SameText(ATrimmedLine, MANGO_FLAG_RETRO) then
    filterRadioGroup.ItemIndex := 3
  else if SameText(ATrimmedLine, MANGO_FLAG_DISPLAY_SERVER) then
    displayserverCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_TIME) then
    timeCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_TIME + '#') then
    timeCheckBox.Checked := True
  else if SameText(ATrimmedLine, MANGO_FLAG_VERSION + '#') then
    hudversionCheckBox.Checked := True;
end;

procedure Tgoverlayform.LoadMangoHudKeyValue(const AKey, AValue: string);
var
  IntValue: Integer;
  FloatValue: Double;
  j: Integer;
begin
  // ============= VISUAL TAB =============
  if SameText(AKey, MANGO_KEY_CUSTOM_TEXT) then
    hudtitleEdit.Text := AValue
  else if SameText(AKey, MANGO_KEY_BG_ALPHA) then
  begin
    if TryStrToFloat(AValue, FloatValue) then
    begin
      transpTrackBar.Position := Round(FloatValue * 10);
      alphavalueLabel.Caption := FormatFloat('#0.0', FloatValue);
    end;
  end
  else if SameText(AKey, MANGO_KEY_ROUND_CORNERS) then
  begin
    if TryStrToInt(AValue, IntValue) then
    begin
      if IntValue = 0 then
        squareRadioButton.Checked := True
      else
        roundRadioButton.Checked := True;
    end;
  end
  else if SameText(AKey, MANGO_KEY_BG_COLOR) then
    hudbackgroundColorButton.ButtonColor := HexToColor(AValue)
  else if SameText(AKey, MANGO_KEY_FONT_SIZE) then
  begin
    if TryStrToInt(AValue, IntValue) then
    begin
      fontsizeTrackBar.Position := IntValue;
      fontsizevalueLabel.Caption := IntToStr(IntValue);
    end;
  end
  else if SameText(AKey, MANGO_KEY_TEXT_COLOR) then
    fontColorButton.ButtonColor := HexToColor(AValue)
  else if SameText(AKey, MANGO_KEY_FONT_FILE) then
    fontComboBox.Text := ExtractFileName(AValue)
  else if SameText(AKey, MANGO_KEY_POSITION) then
  begin
    if SameText(AValue, MANGO_POS_TOP_LEFT) then
      topleftRadioButton.Checked := True
    else if SameText(AValue, MANGO_POS_TOP_CENTER) then
      topcenterRadioButton.Checked := True
    else if SameText(AValue, MANGO_POS_TOP_RIGHT) then
      toprightRadioButton.Checked := True
    else if SameText(AValue, MANGO_POS_MIDDLE_LEFT) then
      middleleftRadioButton.Checked := True
    else if SameText(AValue, MANGO_POS_MIDDLE_RIGHT) then
      middlerightRadioButton.Checked := True
    else if SameText(AValue, MANGO_POS_BOTTOM_LEFT) then
      bottomleftRadioButton.Checked := True
    else if SameText(AValue, MANGO_POS_BOTTOM_CENTER) then
      bottomcenterRadioButton.Checked := True
    else if SameText(AValue, MANGO_POS_BOTTOM_RIGHT) then
      bottomrightRadioButton.Checked := True;
  end
  else if SameText(AKey, MANGO_KEY_OFFSET_X) then
  begin
    if TryStrToInt(AValue, IntValue) then
      offsetxSpinEdit.Value := IntValue;
  end
  else if SameText(AKey, MANGO_KEY_OFFSET_Y) then
  begin
    if TryStrToInt(AValue, IntValue) then
      offsetySpinEdit.Value := IntValue;
  end
  else if SameText(AKey, MANGO_KEY_TOGGLE_HUD) then
  begin
    hudonoffComboBox.Text := AValue;
    if Assigned(FVisualCaptureBtn) and (Trim(AValue) <> '') then
      FVisualCaptureBtn.Caption := '⌨ ' + AValue;
  end
  else if SameText(AKey, MANGO_KEY_TABLE_COLS) then
  begin
    if TryStrToInt(AValue, IntValue) then
    begin
      columvalueLabel.Caption := AValue;
      case IntValue of
        1: begin
          columShape.Visible := True; columShape1.Visible := False; columShape2.Visible := False;
          columShape3.Visible := False; columShape4.Visible := False; columShape5.Visible := False;
        end;
        2: begin
          columShape.Visible := True; columShape1.Visible := True; columShape2.Visible := False;
          columShape3.Visible := False; columShape4.Visible := False; columShape5.Visible := False;
        end;
        3: begin
          columShape.Visible := True; columShape1.Visible := True; columShape2.Visible := True;
          columShape3.Visible := False; columShape4.Visible := False; columShape5.Visible := False;
        end;
        4: begin
          columShape.Visible := True; columShape1.Visible := True; columShape2.Visible := True;
          columShape3.Visible := True; columShape4.Visible := False; columShape5.Visible := False;
        end;
        5: begin
          columShape.Visible := True; columShape1.Visible := True; columShape2.Visible := True;
          columShape3.Visible := True; columShape4.Visible := True; columShape5.Visible := False;
        end;
        6: begin
          columShape.Visible := True; columShape1.Visible := True; columShape2.Visible := True;
          columShape3.Visible := True; columShape4.Visible := True; columShape5.Visible := True;
        end;
      end;
    end;
  end
  // ============= METRICS TAB =============
  else if SameText(AKey, MANGO_KEY_GPU_TEXT) then
    gpunameEdit.Text := AValue
  else if SameText(AKey, MANGO_KEY_GPU_COLOR) then
    gpuColorButton.ButtonColor := HexToColor(AValue)
  else if SameText(AKey, MANGO_KEY_CPU_TEXT) then
    cpunameEdit.Text := AValue
  else if SameText(AKey, MANGO_KEY_CPU_COLOR) then
    cpuColorButton.ButtonColor := HexToColor(AValue)
  else if SameText(AKey, MANGO_KEY_VRAM_COLOR) then
    vramColorButton.ButtonColor := HexToColor(AValue)
  else if SameText(AKey, MANGO_KEY_RAM_COLOR) then
    ramColorButton.ButtonColor := HexToColor(AValue)
  else if SameText(AKey, MANGO_KEY_IO_COLOR) then
    iordrwColorButton.ButtonColor := HexToColor(AValue)
  else if SameText(AKey, MANGO_KEY_FRAMETIME_COLOR) then
    frametimegraphColorButton.ButtonColor := HexToColor(AValue)
  // ============= PERFORMANCE TAB =============
  else if SameText(AKey, MANGO_KEY_FPS_LIMIT_METHOD) then
  begin
    if SameText(AValue, MANGO_FPS_LATE) then
      fpslimmetComboBox.ItemIndex := 0
    else if SameText(AValue, MANGO_FPS_EARLY) then
      fpslimmetComboBox.ItemIndex := 1;
  end
  else if SameText(AKey, MANGO_KEY_TOGGLE_FPS_LIMIT) then
  begin
    fpslimtoggleComboBox.Text := AValue;
    if Assigned(FLimitCaptureBtn) and (Trim(AValue) <> '') then
      FLimitCaptureBtn.Caption := '⌨ ' + AValue;
  end
  else if SameText(AKey, MANGO_KEY_VSYNC) then
  begin
    if TryStrToInt(AValue, IntValue) then
      vsyncComboBox.ItemIndex := IntValue;
  end
  else if SameText(AKey, MANGO_KEY_GL_VSYNC) then
  begin
    if SameText(AValue, MANGO_GL_VSYNC_MINUS1) then
      glvsyncComboBox.ItemIndex := 0
    else if SameText(AValue, MANGO_GL_VSYNC_0) then
      glvsyncComboBox.ItemIndex := 1
    else if SameText(AValue, MANGO_GL_VSYNC_1) then
      glvsyncComboBox.ItemIndex := 2
    else if SameText(AValue, MANGO_GL_VSYNC_N) then
      glvsyncComboBox.ItemIndex := 3;
  end
  else if SameText(AKey, MANGO_KEY_AF) then
  begin
    if TryStrToInt(AValue, IntValue) then
    begin
      afTrackBar.Position := IntValue;
      afvalueLabel.Caption := IntToStr(IntValue);
    end;
  end
  else if SameText(AKey, MANGO_KEY_PICMIP) then
  begin
    if TryStrToInt(AValue, IntValue) then
    begin
      mipmapTrackBar.Position := IntValue;
      mipmapvalueLabel.Caption := IntToStr(IntValue);
    end;
  end
  // ============= EXTRAS TAB =============
  else if SameText(AKey, MANGO_KEY_WINE_COLOR) then
    wineColorButton.ButtonColor := HexToColor(AValue)
  else if SameText(AKey, MANGO_KEY_ENGINE_COLOR) then
    engineColorButton.ButtonColor := HexToColor(AValue)
  else if SameText(AKey, MANGO_KEY_BATTERY_COLOR) then
    batteryColorButton.ButtonColor := HexToColor(AValue)
  else if SameText(AKey, MANGO_KEY_MEDIA_COLOR) then
    mediaColorButton.ButtonColor := HexToColor(AValue)
  else if SameText(AKey, MANGO_KEY_DEVICE_BATTERY) then
    deviceCheckBox.Checked := True
  else if SameText(AKey, MANGO_KEY_OUTPUT_FOLDER) then
    logfolderEdit.Text := AValue
  else if SameText(AKey, MANGO_KEY_LOG_DURATION) then
  begin
    if TryStrToInt(AValue, IntValue) then
    begin
      durationTrackBar.Position := IntValue;
      durationvalueLabel.Caption := IntToStr(IntValue) + 's';
    end;
  end
  else if SameText(AKey, MANGO_KEY_AUTOSTART_LOG) then
  begin
    if TryStrToInt(AValue, IntValue) then
    begin
      delayTrackBar.Position := IntValue;
      delayvalueLabel.Caption := IntToStr(IntValue) + 's';
    end;
  end
  else if SameText(AKey, MANGO_KEY_LOG_INTERVAL) then
  begin
    if TryStrToInt(AValue, IntValue) then
    begin
      intervalTrackBar.Position := IntValue;
      intervalvalueLabel.Caption := IntToStr(IntValue) + 'ms';
    end;
  end
  else if SameText(AKey, MANGO_KEY_TOGGLE_LOGGING) then
  begin
    logtoggleComboBox.Text := AValue;
    if Assigned(FLoggingCaptureBtn) and (Trim(AValue) <> '') then
      FLoggingCaptureBtn.Caption := '⌨ ' + AValue;
  end
  else if SameText(AKey, MANGO_KEY_FPS_METRICS) then
  begin
    if Pos(MANGO_FPS_METRICS_1PCT, AValue) > 0 then
    begin
      fpsavgCheckBox.Checked := True;
      fpsavgBitBtn.ImageIndex := 9;
      fpsavgBitBtn.Caption := '1% low';
    end
    else if Pos(MANGO_FPS_METRICS_01PCT, AValue) > 0 then
    begin
      fpsavgCheckBox.Checked := True;
      fpsavgBitBtn.ImageIndex := 10;
      fpsavgBitBtn.Caption := '0.1% low';
    end;
  end
  else if SameText(AKey, MANGO_KEY_NETWORK) then
  begin
    networkCheckBox.Checked := True;
    if AValue <> '' then
    begin
      networkComboBox.ItemIndex := -1;
      for j := 0 to networkComboBox.Items.Count - 1 do
      begin
        if SameText(networkComboBox.Items[j], AValue) then
        begin
          networkComboBox.ItemIndex := j;
          Break;
        end;
      end;
      if networkComboBox.ItemIndex = -1 then
      begin
        networkComboBox.Items.Add(AValue);
        networkComboBox.ItemIndex := networkComboBox.Items.Count - 1;
      end;
    end;
  end
  else if SameText(AKey, MANGO_KEY_EXEC) then
  begin
    if (Pos('uname -r', AValue) > 0) or (Pos('goverlay/distro', AValue) > 0) then
      distroinfoCheckBox.Checked := True;
  end;
end;

procedure Tgoverlayform.SaveMangoHudConfig;
var
  ConfigLines: TStringList;
  ConfigDir, FontPath, FontDir, DistroFile: string;
  FlatpakSteamConfigDir, FlatpakMangoHudFile: string;
  SelectedValues: TStringList;
  i, TempFPS, MaxFPS, FPS: Integer;
  FPSNumbers: TStringList;

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
  // When in game-specific mode, MANGOHUDCFGFILE already points to the game
  // config path; otherwise use the global XDG-compliant MangoHud directory.
  if FActiveGameName <> '' then
    ConfigDir := ExtractFilePath(MANGOHUDCFGFILE)
  else
    ConfigDir := GetMangoHudConfigDir();

  // Create directory if it doesn't exist (use CreateHostDirectory for Flatpak compatibility)
  if not DirectoryExists(ConfigDir) then
  begin
    if FActiveGameName <> '' then
      ForceDirectories(ConfigDir)
    else
      CreateHostDirectory(ConfigDir);
  end;

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

    if Trim(hudonoffComboBox.Text) <> '' then
      ConfigLines.Add('toggle_hud=' + hudonoffComboBox.Text);

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

    if Trim(fpslimtoggleComboBox.Text) <> '' then
      ConfigLines.Add('toggle_fps_limit=' + fpslimtoggleComboBox.Text);

    // FPS limits (from edit field)
    if Assigned(FFpsLimitEdit) and (Trim(FFpsLimitEdit.Text) <> '') then
      ConfigLines.Add('fps_limit=' + Trim(FFpsLimitEdit.Text))
    else
      ConfigLines.Add('fps_limit=0');

    // Update FPS colour thresholds from the entered limit values
    if Assigned(FFpsLimitEdit) then
    begin
      FPSNumbers := TStringList.Create;
      try
        FPSNumbers.Delimiter := ',';
        FPSNumbers.DelimitedText := Trim(FFpsLimitEdit.Text);
        MaxFPS := 0;
        for i := 0 to FPSNumbers.Count - 1 do
        begin
          FPS := StrToIntDef(FPSNumbers[i], 0);
          if FPS > MaxFPS then
            MaxFPS := FPS;
        end;
        if MaxFPS = 0 then
          MaxFPS := 60;
        fpscolor3SpinEdit.Value := MaxFPS;
        fpscolor2SpinEdit.Value := Round(MaxFPS / 2);
      finally
        FPSNumbers.Free;
      end;
    end;

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

    if Trim(logtoggleComboBox.Text) <> '' then
      ConfigLines.Add('toggle_logging=' + logtoggleComboBox.Text);

    // Log versioning
    AddIfChecked(versioningCheckBox, 'log_versioning');

    // Auto upload
    AddIfChecked(autouploadCheckBox, 'upload_logs');

    // Save to active config file (game-specific or global)
    ConfigLines.SaveToFile(MANGOHUDCFGFILE);

    // In game-specific mode: inject MANGOHUD_CONFIGFILE into the game fgmod
    // so Steam picks up the per-game config at launch.
    if FActiveGameName <> '' then
    begin
      PatchGameFGModConfigPath(
        GetGameConfigDir(FActiveGameName) + 'fgmod',
        'MANGOHUD_CONFIGFILE',
        MANGOHUDCFGFILE);
      Exit;
    end;

    try
      FlatpakSteamConfigDir := GetUserDir + '.var/app/com.valvesoftware.Steam/config/MangoHud';
      FlatpakMangoHudFile := FlatpakSteamConfigDir + '/MangoHud.conf';

      // Create Flatpak directory if it doesn't exist
      if not DirectoryExists(FlatpakSteamConfigDir) and DirectoryExists(GetUserDir + '.var') then
        ForceDirectories(FlatpakSteamConfigDir)
      else
        WriteLn('[WARN] SaveMangoHudConfig: ~/.var does not exist, skipping saving config for Steam Flatpak');

      if DirectoryExists(FlatpakSteamConfigDir) then
      begin
        // Save the same configuration to Flatpak location
        ConfigLines.SaveToFile(FlatpakMangoHudFile);
        WriteLn('[DEBUG] SaveMangoHudConfig: Configuration also saved to Steam Flatpak location: ', FlatpakMangoHudFile);
      end
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
  Value, EffectsStr, FullEffectPath: string;
  EffectsList: TStringArray;
  j, k: Integer;
  FloatValue: Double;
  FS: TFormatSettings;
  Cfg: TConfigFile;
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

  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';

  Cfg := TConfigFile.Create;
  try
    if not Cfg.Load(VKBASALTCFGFILE) then Exit;

    // Process effects list (custom colon-separated value)
    EffectsStr := Cfg.GetValue('effects=', '');
    if EffectsStr <> '' then
    begin
      EffectsList := SplitString(EffectsStr, ':');
      for j := Low(EffectsList) to High(EffectsList) do
      begin
        EffectsList[j] := Trim(EffectsList[j]);
        if SameText(EffectsList[j], 'cas') then
        begin
          if casTrackBar.Position = 0 then
            casTrackBar.Position := 5;
        end
        else if SameText(EffectsList[j], 'fxaa') then
        begin
          if fxaaTrackBar.Position = 0 then
            fxaaTrackBar.Position := 5;
        end
        else if SameText(EffectsList[j], 'smaa') then
        begin
          if smaaTrackBar.Position = 0 then
            smaaTrackBar.Position := 5;
        end
        else if SameText(EffectsList[j], 'dls') then
        begin
          if dlsTrackBar.Position = 0 then
            dlsTrackBar.Position := 5;
        end
        else if EffectsList[j] <> '' then
        begin
          FullEffectPath := '';
          for k := 0 to aveffectsListbox.Items.Count - 1 do
          begin
            if SameText(ChangeFileExt(ExtractFileName(aveffectsListbox.Items[k]), ''), EffectsList[j]) then
            begin
              FullEffectPath := aveffectsListbox.Items[k];
              Break;
            end;
          end;
          if FullEffectPath = '' then
            FullEffectPath := EffectsList[j];
          if acteffectsListBox.Items.IndexOf(FullEffectPath) = -1 then
            acteffectsListBox.Items.Add(FullEffectPath);
        end;
      end;
    end;

    Value := Cfg.GetValue('casSharpness=', '');
    if TryStrToFloat(Value, FloatValue, FS) then
    begin
      casTrackBar.Position := Round(FloatValue * 10);
      casvalueLabel.Caption := IntToStr(casTrackBar.Position);
      if Assigned(FVkCasValLbl) then FVkCasValLbl.Caption := casvalueLabel.Caption;
    end;

    Value := Cfg.GetValue('fxaaQualitySubpix=', '');
    if TryStrToFloat(Value, FloatValue, FS) then
    begin
      fxaaTrackBar.Position := Round(FloatValue * 10);
      fxaavalueLabel.Caption := IntToStr(fxaaTrackBar.Position);
      if Assigned(FVkFxaaValLbl) then FVkFxaaValLbl.Caption := fxaavalueLabel.Caption;
    end;

    Value := Cfg.GetValue('smaaCornerRounding=', '');
    if TryStrToFloat(Value, FloatValue, FS) then
    begin
      smaaTrackBar.Position := Round(FloatValue / 25 * 9) + 1;
      smaavalueLabel.Caption := IntToStr(smaaTrackBar.Position);
      if Assigned(FVkSmaaValLbl) then FVkSmaaValLbl.Caption := smaavalueLabel.Caption;
    end;

    Value := Cfg.GetValue('dlsSharpness=', '');
    if TryStrToFloat(Value, FloatValue, FS) then
    begin
      dlsTrackBar.Position := Round(FloatValue * 9) + 1;
      dlsvalueLabel.Caption := IntToStr(dlsTrackBar.Position);
      if Assigned(FVkDlsValLbl) then FVkDlsValLbl.Caption := dlsvalueLabel.Caption;
    end;

    Value := Cfg.GetValue('toggleKey=', '');
    if Value <> '' then
    begin
      vkbtogglekeyCombobox.Text := Value;
      if Assigned(FVkToggleCaptureBtn) then
        FVkToggleCaptureBtn.Caption := '⌨ ' + Value;
    end;
  finally
    Cfg.Free;
  end;
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
  if Assigned(FCoverThread) then
  begin
    FCoverThread.Terminate;
    FCoverThread.WaitFor;
    FreeAndNil(FCoverThread);
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

begin

  //Program Version
  GVERSION := '1.8.0';
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
    dependenciesLabel.Caption := 'Application status' ;
    if Assigned(FDepsMenuItem) then
      FDepsMenuItem.Caption := 'Application status';
   end
  else
  begin
    dependencieSpeedbutton.ImageIndex := 1 ;  //red icon
    dependenciesLabel.Caption := ('Missing: ' + LineEnding + Missing.Text);
    if Assigned(FDepsMenuItem) then
      FDepsMenuItem.Caption := 'Missing: ' + Missing.CommaText;
    
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

    //Load fgmod configuration
    LoadFgmodConfig;

    //Load OptiScaler configuration
    LoadOptiScalerConfig;


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

    //Load FakeNvapi configuration (Needs to run after nvidia/mesa checks because they overwrite reflex default values)
    LoadFakeNvapiConfig;

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
type
  TTweakRow = record
    CheckBox: TCheckBox;
    Category: string;
    VarName: string;
    Description: string;
  end;

const
  TWEAK_ROW_COUNT = 23;
  TWEAK_ROWS: array[0..TWEAK_ROW_COUNT - 1] of TTweakRow = (
    (CheckBox: nil; Category: 'General';    VarName: 'SteamDeck=1';                      Description: 'Simulate Steam Deck'),
    (CheckBox: nil; Category: 'General';    VarName: '#gamemode';                        Description: 'Always use GameMode'),
    (CheckBox: nil; Category: 'General';    VarName: 'PROTON_ENABLE_HDR=1';              Description: 'Enable HDR'),
    (CheckBox: nil; Category: 'General';    VarName: 'PROTON_ENABLE_WAYLAND=1';          Description: 'Enable Wayland'),
    (CheckBox: nil; Category: 'General';    VarName: 'PROTON_LOG=1';                     Description: 'Active Proton Logs'),
    (CheckBox: nil; Category: 'General';    VarName: 'PROTON_USE_SDL=1';                 Description: 'Use SDL Input'),
    (CheckBox: nil; Category: 'Graphics';   VarName: 'RADV_PERFTEST=rt,emulate_rt';      Description: 'Emulate RT (old AMD)'),
    (CheckBox: nil; Category: 'Graphics';   VarName: 'PROTON_HIDE_NVIDIA_GPU=1';         Description: 'Hide Nvidia GPU'),
    (CheckBox: nil; Category: 'Graphics';   VarName: 'PROTON_ENABLE_NVAPI=1';            Description: 'Force enable NVAPI'),
    (CheckBox: nil; Category: 'Graphics';   VarName: 'PROTON_USE_WINED3D=1';             Description: 'Use old WINED3D'),
    (CheckBox: nil; Category: 'Graphics';   VarName: 'MESA_LOADER_DRIVER_OVERRIDE=zink'; Description: 'Force Zink'),
    (CheckBox: nil; Category: 'Graphics';   VarName: 'RADV_DEBUG=nofastclears';          Description: 'No fast clears'),
    (CheckBox: nil; Category: 'Graphics';   VarName: 'PROTON_FSR4_UPGRADE=1';            Description: 'Automatically upgrade FSR to the latest version'),
    (CheckBox: nil; Category: 'Graphics';   VarName: 'PROTON_DLSS_UPGRADE=1';            Description: 'Automatically upgrade DLSS to the latest version'),
    (CheckBox: nil; Category: 'Graphics';   VarName: 'PROTON_XESS_UPGRADE=1';            Description: 'Automatically upgrade XeSS to the latest version'),
    (CheckBox: nil; Category: 'Performance';VarName: 'PROTON_PRIORITY_HIGH=1';           Description: 'Higher priority for games'),
    (CheckBox: nil; Category: 'Performance';VarName: 'PROTON_USE_WOW64=1';               Description: 'Use WOW64'),
    (CheckBox: nil; Category: 'Performance';VarName: 'PROTON_FORCE_LARGE_ADDRESS_AWARE=1'; Description: 'Large Address Aware'),
    (CheckBox: nil; Category: 'Performance';VarName: 'STAGING_SHARED_MEMORY=1';          Description: 'Staging shared memory'),
    (CheckBox: nil; Category: 'Performance';VarName: 'PROTON_NO_NTSYNC=1';               Description: 'Disable NTSYNC'),
    (CheckBox: nil; Category: 'Performance';VarName: 'PROTON_HEAP_DELAY_FREE=1';         Description: 'Heap Delay Free'),
    (CheckBox: nil; Category: 'Performance';VarName: 'ENABLE_LAYER_MESA_ANTI_LAG=1';     Description: 'Enable AMD Anti-Lag 2'),
    (CheckBox: nil; Category: 'Graphics';   VarName: '#winedetectionenable=false';             Description: 'Enable RE Engine Ray Tracing workaround')
  );

function GetTweakRowCheckBox(Form: Tgoverlayform; Index: Integer): TCheckBox;
begin
  case Index of
    0: Result := Form.simdeckCheckBox;
    1: Result := Form.gamemodeCheckBox;
    2: Result := Form.enhdrCheckBox;
    3: Result := Form.enwaylandCheckBox;
    4: Result := Form.actprotonlogsCheckBox;
    5: Result := Form.usesdlCheckBox;
    6: Result := Form.emurtCheckBox;
    7: Result := Form.hidenvidiaCheckBox;
    8: Result := Form.forcenvapiCheckBox;
    9: Result := Form.wined3dCheckBox;
    10: Result := Form.forcezinkCheckBox;
    11: Result := Form.nofastclearsCheckBox;
    12: Result := Form.highpriCheckBox;
    13: Result := Form.wow64CheckBox;
    14: Result := Form.largeaddressCheckBox;
    15: Result := Form.stagememCheckBox;
    16: Result := Form.disablentsyncCheckBox;
    17: Result := Form.heapdelayCheckBox;
    18: Result := Form.FAntilagCheckBox;
    19: Result := Form.FFSR4UpgradeCheckBox;
    20: Result := Form.FDLSSUpgradeCheckBox;
    21: Result := Form.FXeSSUpgradeCheckBox;
    22: Result := Form.FReEngineRTCheckBox;
  else
    Result := nil;
  end;
end;

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


function Tgoverlayform.OsHexToKeyStr(const HexStr: string): string;
var
  VkCode: Integer;
begin
  if SameText(HexStr, 'auto') or (HexStr = '') then
  begin
    Result := 'auto';
    Exit;
  end;
  try
    if (Length(HexStr) > 2) and (Copy(HexStr, 1, 2) = '0x') then
      VkCode := StrToInt('$' + Copy(HexStr, 3, MaxInt))
    else
      VkCode := StrToInt(HexStr);
  except
    Result := HexStr;
    Exit;
  end;
  // F1–F24
  if (VkCode >= $70) and (VkCode <= $87) then
  begin
    Result := 'F' + IntToStr(VkCode - $70 + 1);
    Exit;
  end;
  // Numpad 0–9
  if (VkCode >= $60) and (VkCode <= $69) then
  begin
    Result := 'Numpad' + IntToStr(VkCode - $60);
    Exit;
  end;
  // Digits 0–9
  if (VkCode >= $30) and (VkCode <= $39) then
  begin
    Result := Chr(VkCode);
    Exit;
  end;
  // Letters A–Z
  if (VkCode >= $41) and (VkCode <= $5A) then
  begin
    Result := Chr(VkCode);
    Exit;
  end;
  case VkCode of
    $08: Result := 'Backspace';
    $09: Result := 'Tab';
    $0D: Result := 'Enter';
    $13: Result := 'Pause';
    $14: Result := 'CapsLock';
    $1B: Result := 'Escape';
    $20: Result := 'Space';
    $21: Result := 'PageUp';
    $22: Result := 'PageDown';
    $23: Result := 'End';
    $24: Result := 'Home';
    $25: Result := 'Left';
    $26: Result := 'Up';
    $27: Result := 'Right';
    $28: Result := 'Down';
    $2C: Result := 'PrintScreen';
    $2D: Result := 'Insert';
    $2E: Result := 'Delete';
    $6A: Result := 'Numpad*';
    $6B: Result := 'Numpad+';
    $6D: Result := 'Numpad-';
    $6E: Result := 'Numpad.';
    $6F: Result := 'Numpad/';
    $90: Result := 'NumLock';
    $91: Result := 'ScrollLock';
    $BA: Result := 'Semicolon';
    $BB: Result := 'Plus';
    $BC: Result := 'Comma';
    $BD: Result := 'Minus';
    $BE: Result := 'Period';
    $BF: Result := 'Slash';
    $C0: Result := 'Tilde';
    $DB: Result := '[';
    $DC: Result := '\';
    $DD: Result := ']';
    $DE: Result := 'Quote';
  else
    Result := Format('0x%.2x', [VkCode]);
  end;
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
var
  i: Integer;
const
  BG = $001A192E; // RGB(22, 25, 37) — dark blue-grey background
begin
  // Default all categories expanded
  FTweaksCatExpanded[0] := True;
  FTweaksCatExpanded[1] := True;
  FTweaksCatExpanded[2] := True;
  FTweaksScrollPos := 0;
  FTweaksHoverIdx := -1;

  // Hide old LFM visual elements from the Tweaks tab
  tweaksImage.Visible := False;
  tweaksText.Visible  := False;
  tweaksText2.Visible := False;
  tweaksLabel.Visible := False;
  tweaksShape.Visible := False;

  // PaintBox fills the tab but leaves room for the bottom bar (40px + padding)
  FTweaksPaintBox := TPaintBox.Create(Self);
  FTweaksPaintBox.Parent      := tweaksTabSheet;
  FTweaksPaintBox.Align       := alNone;
  FTweaksPaintBox.Anchors     := [akLeft, akTop, akRight, akBottom];
  FTweaksPaintBox.SetBounds(0, 0, tweaksTabSheet.ClientWidth,
                            tweaksTabSheet.ClientHeight - 50);
  FTweaksPaintBox.Color       := BG;
  FTweaksPaintBox.OnPaint     := @TweaksMD3Paint;
  FTweaksPaintBox.OnMouseMove := @TweaksMD3MouseMove;
  FTweaksPaintBox.OnMouseDown := @TweaksMD3MouseDown;
  FTweaksPaintBox.OnMouseWheel:= @TweaksMD3MouseWheel;

  // Vertical scrollbar (right edge)
  FTweaksScrollBar := TScrollBar.Create(Self);
  FTweaksScrollBar.Parent      := tweaksTabSheet;
  FTweaksScrollBar.Kind        := sbVertical;
  FTweaksScrollBar.Align       := alRight;
  FTweaksScrollBar.Width       := 14;
  FTweaksScrollBar.Visible     := False;
  FTweaksScrollBar.OnChange    := @TweaksMD3ScrollChange;

  // Floating Action Button — circular "+"
  FTweaksFABBtn := TSpeedButton.Create(Self);
  FTweaksFABBtn.Parent       := tweaksTabSheet;
  FTweaksFABBtn.Width        := 48;
  FTweaksFABBtn.Height       := 48;
  FTweaksFABBtn.Left         := tweaksTabSheet.ClientWidth - 64;
  FTweaksFABBtn.Top          := tweaksTabSheet.ClientHeight - 96; // above Save button
  FTweaksFABBtn.Anchors      := [akRight, akBottom];
  FTweaksFABBtn.Caption      := '+';
  FTweaksFABBtn.Font.Size    := 24;
  FTweaksFABBtn.Font.Style   := [fsBold];
  FTweaksFABBtn.Font.Color   := clWhite;
  FTweaksFABBtn.Flat         := True;
  FTweaksFABBtn.ShowHint     := True;
  FTweaksFABBtn.Hint         := 'Add custom environment variable';
  FTweaksFABBtn.OnClick      := @TweaksMD3FABClick;
  FTweaksFABBtn.OnPaint      := @TweaksMD3FABPaint;

  // Hidden checkbox for AMD Anti-Lag 2 (not in LFM — created dynamically)
  FAntilagCheckBox := TCheckBox.Create(Self);
  FAntilagCheckBox.Parent      := Self;
  FAntilagCheckBox.Visible     := False;
  FAntilagCheckBox.Name        := 'antilagCheckBox';
  FAntilagCheckBox.Caption     := 'Enable AMD Anti-Lag 2';

  // Hidden checkboxes for upgrade tweaks (not in LFM — created dynamically)
  FFSR4UpgradeCheckBox := TCheckBox.Create(Self);
  FFSR4UpgradeCheckBox.Parent  := Self;
  FFSR4UpgradeCheckBox.Visible := False;
  FFSR4UpgradeCheckBox.Name    := 'fsr4upgradeCheckBox';
  FFSR4UpgradeCheckBox.Caption := 'Automatically upgrade FSR to the latest version';

  FDLSSUpgradeCheckBox := TCheckBox.Create(Self);
  FDLSSUpgradeCheckBox.Parent  := Self;
  FDLSSUpgradeCheckBox.Visible := False;
  FDLSSUpgradeCheckBox.Name    := 'dlssupgradeCheckBox';
  FDLSSUpgradeCheckBox.Caption := 'Automatically upgrade DLSS to the latest version';

  FXeSSUpgradeCheckBox := TCheckBox.Create(Self);
  FXeSSUpgradeCheckBox.Parent  := Self;
  FXeSSUpgradeCheckBox.Visible := False;
  FXeSSUpgradeCheckBox.Name    := 'xessupgradeCheckBox';
  FXeSSUpgradeCheckBox.Caption := 'Automatically upgrade XeSS to the latest version';

  FReEngineRTCheckBox := TCheckBox.Create(Self);
  FReEngineRTCheckBox.Parent  := Self;
  FReEngineRTCheckBox.Visible := False;
  FReEngineRTCheckBox.Name    := 'reenginertCheckBox';
  FReEngineRTCheckBox.Caption := 'Enable RE Engine Ray Tracing workaround';

  // Hidden grid used as data store for custom variables (visual is PaintBox)
  FTweaksGrid := TStringGrid.Create(Self);
  FTweaksGrid.Parent      := Self;
  FTweaksGrid.Visible     := False;
  FTweaksGrid.ColCount    := 4;
  FTweaksGrid.RowCount    := 1 + TWEAK_ROW_COUNT;
  FTweaksGrid.FixedRows   := 1;
  for i := 0 to TWEAK_ROW_COUNT - 1 do
  begin
    FTweaksGrid.Cells[0, i + 1] := '0';
    FTweaksGrid.Cells[1, i + 1] := TWEAK_ROWS[i].Category;
    FTweaksGrid.Cells[2, i + 1] := TWEAK_ROWS[i].VarName;
    FTweaksGrid.Cells[3, i + 1] := TWEAK_ROWS[i].Description;
  end;
end;

procedure Tgoverlayform.TweaksMD3FABPaint(Sender: TObject);
var
  Btn: TSpeedButton;
  R: TRect;
  PlusW, PlusH: Integer;
begin
  Btn := Sender as TSpeedButton;
  R := Rect(0, 0, Btn.Width, Btn.Height);

  // Circle background
  Btn.Canvas.Brush.Color := RGBToColor(48, 190, 240); // accent cyan
  Btn.Canvas.Pen.Color   := RGBToColor(48, 190, 240);
  Btn.Canvas.Ellipse(R);

  // Shadow ring
  Btn.Canvas.Pen.Color := RGBToColor(38, 160, 210);
  Btn.Canvas.Ellipse(R.Left + 1, R.Top + 1, R.Right - 1, R.Bottom - 1);

  // Draw "+" manually in the centre
  Btn.Canvas.Font.Name  := 'DejaVu Sans';
  Btn.Canvas.Font.Size  := 22;
  Btn.Canvas.Font.Style := [fsBold];
  Btn.Canvas.Font.Color := clWhite;
  PlusW := Btn.Canvas.TextWidth('+');
  PlusH := Btn.Canvas.TextHeight('+');
  Btn.Canvas.TextOut((Btn.Width - PlusW) div 2, (Btn.Height - PlusH) div 2 - 1, '+');
end;

procedure Tgoverlayform.TweaksMD3BuildItems;
// Virtual — items are rendered on-the-fly in paint event using checkboxes + custom list
begin
  // No persistent list needed; paint event reads directly from checkboxes + grid custom rows
end;

procedure Tgoverlayform.TweaksMD3Paint(Sender: TObject);

  procedure DrawToggle(ACanvas: TCanvas; AX, AY: Integer; AOn: Boolean);
  var
    ThumbR: TRect;
    CX, CY, ThumbD, Pad: Integer;
    TrackColor: TColor;
  const
    TRACK_W = 44;
    TRACK_H = 24;
    THUMB_D = 18;
    RADIUS  = 12; // rounded-cap radius
  begin
    Pad := 2;
    CX  := AX + TRACK_W div 2;
    CY  := AY + TRACK_H div 2;

    // Track colour
    if AOn then
      TrackColor := RGBToColor(60, 180, 80)   // green
    else
      TrackColor := RGBToColor(70, 70, 70);   // grey

    // --- Draw pill-shaped track using central rect + two end caps ---
    ACanvas.Brush.Color := TrackColor;
    ACanvas.Pen.Color   := TrackColor;

    // Central rectangle (rounded ends are handled by the caps)
    ACanvas.FillRect(AX + RADIUS, AY, AX + TRACK_W - RADIUS, AY + TRACK_H);

    // Left cap (semi-circle)
    ACanvas.Ellipse(AX, AY, AX + RADIUS * 2, AY + TRACK_H);

    // Right cap (semi-circle)
    ACanvas.Ellipse(AX + TRACK_W - RADIUS * 2, AY, AX + TRACK_W, AY + TRACK_H);

    // --- Thumb ---
    ThumbD := THUMB_D;
    if AOn then
      ThumbR.Left := AX + TRACK_W - ThumbD - Pad
    else
      ThumbR.Left := AX + Pad;
    ThumbR.Top    := CY - ThumbD div 2;
    ThumbR.Right  := ThumbR.Left + ThumbD;
    ThumbR.Bottom := ThumbR.Top + ThumbD;

    // Subtle shadow
    ACanvas.Brush.Color := RGBToColor(200, 200, 200);
    ACanvas.Pen.Color   := RGBToColor(160, 160, 160);
    ACanvas.Ellipse(ThumbR);

    // White thumb body
    InflateRect(ThumbR, -2, -2);
    ACanvas.Brush.Color := clWhite;
    ACanvas.Pen.Color   := clWhite;
    ACanvas.Ellipse(ThumbR);
  end;

  procedure DrawHeader(ACanvas: TCanvas; const ARect: TRect; const ACat: string; const AIcon: string; AExpanded: Boolean; AHover: Boolean);
  var
    TxtH: Integer;
    Arrow: string;
    IconX, TextX: Integer;
  begin
    if AHover then
      ACanvas.Brush.Color := RGBToColor(55, 95, 150)   // bright blue
    else
      ACanvas.Brush.Color := RGBToColor(40, 70, 115);  // dark blue
    ACanvas.FillRect(ARect);

    // Arrow (expand/collapse indicator)
    if AExpanded then
      Arrow := '▼'
    else
      Arrow := '▶';
    ACanvas.Font.Color  := RGBToColor(200, 200, 200);
    ACanvas.Font.Size   := 9;
    ACanvas.Font.Style  := [];
    ACanvas.Font.Name   := 'DejaVu Sans';
    ACanvas.TextOut(ARect.Left + 12, ARect.Top + (ARect.Height - ACanvas.TextHeight(Arrow)) div 2, Arrow);

    // Icon
    IconX := ARect.Left + 32;
    ACanvas.Font.Name   := 'Noto Color Emoji';
    ACanvas.Font.Size   := 14;
    ACanvas.Font.Style  := [];
    ACanvas.TextOut(IconX, ARect.Top + (ARect.Height - ACanvas.TextHeight(AIcon)) div 2, AIcon);

    // Category name
    TextX := IconX + 22;
    ACanvas.Font.Name  := 'DejaVu Sans';
    ACanvas.Font.Color := clWhite;
    ACanvas.Font.Style := [fsBold];
    ACanvas.Font.Size  := 9;
    TxtH := ACanvas.TextHeight(ACat);
    ACanvas.TextOut(TextX, ARect.Top + (ARect.Height - TxtH) div 2, ACat);
  end;

  procedure DrawItem(ACanvas: TCanvas; const ARect: TRect; const AVar, ADesc: string;
                     AChecked, AHover: Boolean; AIsCustom: Boolean);
  var
    ToggleX, ToggleY, DelX: Integer;
    VarRect, DescRect: TRect;
  const
    PAD = 16;
    DEL_W = 24;
  begin
    // Background
    if AChecked then
      ACanvas.Brush.Color := RGBToColor(30, 50, 80)   // blue tint
    else if AHover then
      ACanvas.Brush.Color := RGBToColor(50, 55, 70)   // grey-blue
    else
      ACanvas.Brush.Color := RGBToColor(22, 25, 37);  // dark background
    ACanvas.FillRect(ARect);

    // Bottom hairline separator
    ACanvas.Pen.Color := RGBToColor(40, 45, 60);
    ACanvas.Line(ARect.Left, ARect.Bottom - 1, ARect.Right, ARect.Bottom - 1);

    // Delete "×" button for custom rows (left side)
    if AIsCustom then
    begin
      DelX := ARect.Left + PAD;
      ACanvas.Font.Name  := 'DejaVu Sans';
      ACanvas.Font.Size  := 12;
      ACanvas.Font.Style := [fsBold];
      ACanvas.Font.Color := RGBToColor(220, 80, 80);  // red
      ACanvas.TextOut(DelX, ARect.Top + (ARect.Height - ACanvas.TextHeight('×')) div 2, '×');
    end;

    // Toggle switch (right side)
    ToggleX := ARect.Right - 60;
    ToggleY := ARect.Top + (ARect.Height - 24) div 2;
    DrawToggle(ACanvas, ToggleX, ToggleY, AChecked);

    // Description (top line, prominent)
    DescRect := ARect;
    if AIsCustom then
      DescRect.Left := ARect.Left + PAD + DEL_W + 4
    else
      DescRect.Left := ARect.Left + PAD;
    DescRect.Right := ToggleX - PAD;
    DescRect.Bottom := DescRect.Top + DescRect.Height div 2 + 2;
    ACanvas.Font.Name  := 'DejaVu Sans';
    ACanvas.Font.Size  := 9;
    ACanvas.Font.Style := [];
    if AIsCustom then
      ACanvas.Font.Color := RGBToColor(160, 160, 160)
    else
      ACanvas.Font.Color := clWhite;
    ACanvas.TextRect(DescRect, DescRect.Left, DescRect.Top + 2, ADesc);

    // Variable name (below description, monospace, dimmed)
    VarRect := ARect;
    if AIsCustom then
      VarRect.Left := ARect.Left + PAD + DEL_W + 4
    else
      VarRect.Left := ARect.Left + PAD;
    VarRect.Right := ToggleX - PAD;
    VarRect.Top := DescRect.Bottom;
    ACanvas.Font.Name  := 'DejaVu Sans Mono';
    ACanvas.Font.Size  := 8;
    ACanvas.Font.Color := RGBToColor(150, 150, 150);
    ACanvas.TextRect(VarRect, VarRect.Left, VarRect.Top, AVar);
  end;

var
  PB: TPaintBox;
  Y, ItemH, HeadH: Integer;
  i, CatIdx: Integer;
  CatNames: array[0..2] of string;
  CatExpanded: array[0..2] of Boolean;
  HoverIdx, RowIdx: Integer;
  R: TRect;
  Chk: TCheckBox;
begin
  PB := Sender as TPaintBox;
  PB.Canvas.Brush.Color := RGBToColor(22, 25, 37);
  PB.Canvas.FillRect(PB.ClientRect);

  ItemH := TweaksMD3ItemHeight;
  HeadH := TweaksMD3HeaderHeight;
  CatNames[0] := 'General';
  CatNames[1] := 'Graphics';
  CatNames[2] := 'Performance';
  CatExpanded := FTweaksCatExpanded;

  Y := -FTweaksScrollPos;
  RowIdx := 0;
  HoverIdx := FTweaksHoverIdx;

  for CatIdx := 0 to 2 do
  begin
    // Category header with icon
    R := Rect(0, Y, PB.Width, Y + HeadH);
    case CatIdx of
      0: DrawHeader(PB.Canvas, R, CatNames[CatIdx], '⚙', CatExpanded[CatIdx], HoverIdx = RowIdx);
      1: DrawHeader(PB.Canvas, R, CatNames[CatIdx], '🎮', CatExpanded[CatIdx], HoverIdx = RowIdx);
      2: DrawHeader(PB.Canvas, R, CatNames[CatIdx], '⚡', CatExpanded[CatIdx], HoverIdx = RowIdx);
    end;
    Inc(Y, HeadH);
    Inc(RowIdx);

    if CatExpanded[CatIdx] then
    begin
      for i := 0 to TWEAK_ROW_COUNT - 1 do
      begin
        if TWEAK_ROWS[i].Category <> CatNames[CatIdx] then Continue;
        Chk := GetTweakRowCheckBox(Self, i);
        R := Rect(0, Y, PB.Width, Y + ItemH);
        DrawItem(PB.Canvas, R, TWEAK_ROWS[i].VarName, TWEAK_ROWS[i].Description,
                 Assigned(Chk) and Chk.Checked, HoverIdx = RowIdx, False);
        Inc(Y, ItemH);
        Inc(RowIdx);
      end;
    end;
  end;

  // Custom variables header
  R := Rect(0, Y, PB.Width, Y + HeadH);
  DrawHeader(PB.Canvas, R, 'Custom', '✎', True, HoverIdx = RowIdx);
  Inc(Y, HeadH);
  Inc(RowIdx);

  // Custom rows from legacy grid (if any) or hidden listbox
  if Assigned(FTweaksGrid) and (FTweaksGrid.RowCount > 1 + TWEAK_ROW_COUNT) then
  begin
    for i := 1 + TWEAK_ROW_COUNT to FTweaksGrid.RowCount - 1 do
    begin
      R := Rect(0, Y, PB.Width, Y + ItemH);
      DrawItem(PB.Canvas, R, FTweaksGrid.Cells[2, i], FTweaksGrid.Cells[3, i],
               FTweaksGrid.Cells[0, i] = '1', HoverIdx = RowIdx, True);
      Inc(Y, ItemH);
      Inc(RowIdx);
    end;
  end;

  // Update scrollbar
  if Y + FTweaksScrollPos > PB.Height then
  begin
    FTweaksScrollBar.Max := Y + FTweaksScrollPos - PB.Height + 20;
    FTweaksScrollBar.PageSize := PB.Height;
    FTweaksScrollBar.Visible := True;
  end
  else
    FTweaksScrollBar.Visible := False;
end;

procedure Tgoverlayform.TweaksMD3MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  PB: TPaintBox;
  OldHover, ItemH, HeadH, RowIdx, i, CatIdx: Integer;
  YPos: Integer;
  CatName: string;
  InHeader: Boolean;
begin
  PB := Sender as TPaintBox;
  OldHover := FTweaksHoverIdx;
  FTweaksHoverIdx := -1;

  ItemH := TweaksMD3ItemHeight;
  HeadH := TweaksMD3HeaderHeight;
  YPos := -FTweaksScrollPos;
  RowIdx := 0;

  for CatIdx := 0 to 2 do
  begin
    case CatIdx of
      0: CatName := 'General';
      1: CatName := 'Graphics';
      2: CatName := 'Performance';
    end;

    // Header
    if (Y >= YPos) and (Y < YPos + HeadH) then
    begin
      FTweaksHoverIdx := RowIdx;
      Break;
    end;
    Inc(YPos, HeadH);
    Inc(RowIdx);

    if FTweaksCatExpanded[CatIdx] then
    begin
      for i := 0 to TWEAK_ROW_COUNT - 1 do
      begin
        if TWEAK_ROWS[i].Category <> CatName then Continue;
        if (Y >= YPos) and (Y < YPos + ItemH) then
        begin
          FTweaksHoverIdx := RowIdx;
          Break;
        end;
        Inc(YPos, ItemH);
        Inc(RowIdx);
      end;
      if FTweaksHoverIdx >= 0 then Break;
    end;
  end;

  // Custom section
  if FTweaksHoverIdx < 0 then
  begin
    if (Y >= YPos) and (Y < YPos + HeadH) then
      FTweaksHoverIdx := RowIdx;
    Inc(YPos, HeadH);
    Inc(RowIdx);

    if Assigned(FTweaksGrid) then
      for i := 1 + TWEAK_ROW_COUNT to FTweaksGrid.RowCount - 1 do
      begin
        if (Y >= YPos) and (Y < YPos + ItemH) then
        begin
          FTweaksHoverIdx := RowIdx;
          Break;
        end;
        Inc(YPos, ItemH);
        Inc(RowIdx);
      end;
  end;

  if OldHover <> FTweaksHoverIdx then
    PB.Invalidate;
end;

procedure Tgoverlayform.TweaksMD3MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  PB: TPaintBox;
  ItemH, HeadH, RowIdx, i, CatIdx: Integer;
  YPos: Integer;
  CatName: string;
  ToggleX: Integer;
  Chk: TCheckBox;
begin
  if Button <> mbLeft then Exit;
  PB := Sender as TPaintBox;
  ItemH := TweaksMD3ItemHeight;
  HeadH := TweaksMD3HeaderHeight;
  YPos := -FTweaksScrollPos;
  RowIdx := 0;

  for CatIdx := 0 to 2 do
  begin
    case CatIdx of
      0: CatName := 'General';
      1: CatName := 'Graphics';
      2: CatName := 'Performance';
    end;

    // Header click = toggle expand
    if (Y >= YPos) and (Y < YPos + HeadH) then
    begin
      FTweaksCatExpanded[CatIdx] := not FTweaksCatExpanded[CatIdx];
      PB.Invalidate;
      Exit;
    end;
    Inc(YPos, HeadH);
    Inc(RowIdx);

    if FTweaksCatExpanded[CatIdx] then
    begin
      for i := 0 to TWEAK_ROW_COUNT - 1 do
      begin
        if TWEAK_ROWS[i].Category <> CatName then Continue;
        if (Y >= YPos) and (Y < YPos + ItemH) then
        begin
          // Check if click is on toggle (right side)
          ToggleX := PB.Width - 66;
          if X >= ToggleX then
          begin
            Chk := GetTweakRowCheckBox(Self, i);
            if Assigned(Chk) then
            begin
              Chk.Checked := not Chk.Checked;
              PB.Invalidate;
            end;
          end;
          Exit;
        end;
        Inc(YPos, ItemH);
        Inc(RowIdx);
      end;
    end;
  end;

  // Custom section header (no toggle)
  if (Y >= YPos) and (Y < YPos + HeadH) then
  begin
    Inc(YPos, HeadH);
    Inc(RowIdx);
  end
  else
    Inc(YPos, HeadH);

  // Custom rows
  if Assigned(FTweaksGrid) then
    for i := 1 + TWEAK_ROW_COUNT to FTweaksGrid.RowCount - 1 do
    begin
      if (Y >= YPos) and (Y < YPos + ItemH) then
      begin
        // Delete button hit area (left side, ~24x24 px)
        if (X >= 16) and (X < 40) then
        begin
          // Remove custom row from grid
          FTweaksGrid.DeleteRow(i);
          PB.Invalidate;
          Exit;
        end;
        ToggleX := PB.Width - 66;
        if X >= ToggleX then
        begin
          if FTweaksGrid.Cells[0, i] = '1' then
            FTweaksGrid.Cells[0, i] := '0'
          else
            FTweaksGrid.Cells[0, i] := '1';
          PB.Invalidate;
        end;
        Exit;
      end;
      Inc(YPos, ItemH);
    end;
end;

procedure Tgoverlayform.TweaksMD3MouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  FTweaksScrollPos := FTweaksScrollPos - WheelDelta div 4;
  if FTweaksScrollPos < 0 then FTweaksScrollPos := 0;
  if FTweaksScrollPos > FTweaksScrollBar.Max then FTweaksScrollPos := FTweaksScrollBar.Max;
  FTweaksScrollBar.Position := FTweaksScrollPos;
  FTweaksPaintBox.Invalidate;
  Handled := True;
end;

procedure Tgoverlayform.TweaksMD3ScrollChange(Sender: TObject);
begin
  FTweaksScrollPos := FTweaksScrollBar.Position;
  FTweaksPaintBox.Invalidate;
end;

procedure Tgoverlayform.TweaksMD3ToggleItem(Index: Integer);
begin
  // Not used directly — mouse down handles toggling via checkbox
end;

procedure Tgoverlayform.TweaksMD3FABClick(Sender: TObject);
var
  Val: string;
  Row: Integer;
begin
  Val := Trim(InputBox('Custom Environment Variable',
                       'Enter the variable (e.g. MY_VAR=1):', ''));
  if Val = '' then Exit;

  if not Assigned(FTweaksGrid) then Exit;
  Row := FTweaksGrid.RowCount;
  FTweaksGrid.RowCount := Row + 1;
  FTweaksGrid.Cells[0, Row] := '1';
  FTweaksGrid.Cells[1, Row] := 'Custom';
  FTweaksGrid.Cells[2, Row] := Val;
  FTweaksGrid.Cells[3, Row] := '';
  FTweaksPaintBox.Invalidate;
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
  if FActiveGameName <> '' then
    FGModFilePath := GetGameConfigDir(FActiveGameName) + 'fgmod'
  else
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
  if FActiveGameName <> '' then
    FGModFilePath := GetGameConfigDir(FActiveGameName) + 'fgmod'
  else
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

        // Index 6: "Enable AMD Anti-Lag 2" -> export ENABLE_LAYER_MESA_ANTI_LAG=1
        if Pos('export ENABLE_LAYER_MESA_ANTI_LAG=1', FileLines[i]) > 0 then
        begin
          FAntilagCheckBox.Checked := True;
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
    SyncTweaksGridFromCheckBoxes;
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
      
      geSpeedButton.Enabled := false;
      geSpeedButton.ImageIndex := 1;  // ON state
      
      geLabel.Caption := 'Global enable';
    end
    else
    begin
      // Normal state: enabled and restore default caption
      
      geSpeedButton.Enabled := true;
      
      geLabel.Caption := 'Auto Enable';
    end;
  end
  else
  begin
    // On other tabs (vkBasalt, OptiScaler, Tweaks), always show and enable these controls
    
    geSpeedButton.Enabled := true;
    
    geLabel.Caption := 'Auto Enable';
  end;
end;


procedure Tgoverlayform.ApplyCustomEnvTheme;
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
  FGModFilePath: string;
  FileLines: TStringList;
  i, Row: Integer;
  TweakFound: Boolean;
  CustomEnvValue, Line: string;
  StartPos, EndPos: Integer;
begin
  // Get fgmod file path
  if FActiveGameName <> '' then
    FGModFilePath := GetGameConfigDir(FActiveGameName) + 'fgmod'
  else
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
    FAntilagCheckBox.Checked := False;
    FFSR4UpgradeCheckBox.Checked := False;
    FDLSSUpgradeCheckBox.Checked := False;
    FXeSSUpgradeCheckBox.Checked := False;
    FReEngineRTCheckBox.Checked := False;

    // Reset custom env list
    customenvEdit.Text := '';
    FCustomListBox.Items.Clear;

    // Reset grid to predefined rows only (discard previous custom rows)
    if Assigned(FTweaksGrid) then
      FTweaksGrid.RowCount := 1 + TWEAK_ROW_COUNT;

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

      // RE Engine RT workaround marker
      if Pos('#winedetectionenable=false', FileLines[i]) > 0 then
      begin
        FReEngineRTCheckBox.Checked := True;
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

      // Index 5: "Automatically upgrade FSR" -> export PROTON_FSR4_UPGRADE=1
      if Pos('export PROTON_FSR4_UPGRADE=1', FileLines[i]) > 0 then
      begin
        FFSR4UpgradeCheckBox.Checked := True;
        TweakFound := True;
      end;

      // Index 6: "Automatically upgrade DLSS" -> export PROTON_DLSS_UPGRADE=1
      if Pos('export PROTON_DLSS_UPGRADE=1', FileLines[i]) > 0 then
      begin
        FDLSSUpgradeCheckBox.Checked := True;
        TweakFound := True;
      end;

      // Index 7: "Automatically upgrade XeSS" -> export PROTON_XESS_UPGRADE=1
      if Pos('export PROTON_XESS_UPGRADE=1', FileLines[i]) > 0 then
      begin
        FXeSSUpgradeCheckBox.Checked := True;
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

      // Index 6: "Enable AMD Anti-Lag 2" -> export ENABLE_LAYER_MESA_ANTI_LAG=1
      if Pos('export ENABLE_LAYER_MESA_ANTI_LAG=1', FileLines[i]) > 0 then
      begin
        FAntilagCheckBox.Checked := True;
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
          FCustomListBox.Items.Add(Trim(CustomEnvValue));
          TweakFound := True;

          // Add as a custom row in the grid
          if Assigned(FTweaksGrid) then
          begin
            Row := FTweaksGrid.RowCount;
            FTweaksGrid.RowCount := Row + 1;
            FTweaksGrid.Cells[0, Row] := '1';
            FTweaksGrid.Cells[1, Row] := 'Custom';
            FTweaksGrid.Cells[2, Row] := Trim(CustomEnvValue);
            FTweaksGrid.Cells[3, Row] := '';
          end;
        end;
      end;
    end;

  finally
    FileLines.Free;
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
    UpdateGameContextLabel;
    HideGameThumb;
    LoadGameToggleStates;  // reset all tools to enabled, hide toggles
    SetSaveBtnEnabled(True);
  end;

  SetNavActive(0);

  //Disable tabs
  goverlayPageControl.ShowTabs:=false;
  vkbasalttabsheet.TabVisible:=false;
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
  geSpeedButton.Visible:=false;
  geLabel.Visible:=false;
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
vkbasalttabsheet.TabVisible:=false; //disable vkbasalt tab
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
  DbgLog('>> optiscalerLabelClick BEGIN');
  SetNavActive(3);

//Disable tabs
  goverlayPageControl.ShowTabs:=false;
  vkbasalttabsheet.TabVisible:=false;
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
  // Reload OptiScaler and FakeNVAPI configs from the correct path (game or global)
  LoadOptiScalerConfig;
  LoadFakeNvapiConfig;
  // In game mode, also reload fgmod config so fsrversionComboBox reflects goverlay.vars
  if FActiveGameName <> '' then
    LoadFgmodConfig;
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


  if IsCommandAvailable('pascube') then
    ExecuteGUICommand(GetMangoHudLaunchEnv + GetVkBasaltLaunchEnv + 'pascube &')
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
      ExecuteGUICommand(GetMangoHudLaunchEnv + GetVkBasaltLaunchEnv + 'vkcube-wayland &')
    else
      ExecuteGUICommand(GetMangoHudLaunchEnv + GetVkBasaltLaunchEnv + 'vkcube &');
  end
  else
  begin
    if USERSESSION = 'wayland' then
      ExecuteGUICommand(GetMangoHudLaunchEnv + GetVkBasaltLaunchEnv + 'vkcube &')
    else
      ExecuteGUICommand(GetMangoHudLaunchEnv + GetVkBasaltLaunchEnv + 'vkcube &');
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
  FGModFilePath: string;
  FGModLines: TStringList;
  LineIndex, i: Integer;
begin
  // Build the command line from checked items
  LaunchCommand := '';

  // Index 0: "Simulate Steam Deck" -> SteamDeck=1
  if GetGeneralCheckBox(0).Checked then
    LaunchCommand := LaunchCommand + ENV_STEAMDECK + ' ';

  // Index 2: "Enable HDR" -> PROTON_ENABLE_HDR=1
  if GetGeneralCheckBox(2).Checked then
    LaunchCommand := LaunchCommand + ENV_PROTON_ENABLE_HDR + ' ';

  // Index 3: "Enable Wayland" -> PROTON_ENABLE_WAYLAND=1
  if GetGeneralCheckBox(3).Checked then
    LaunchCommand := LaunchCommand + ENV_PROTON_ENABLE_WAYLAND + ' ';

  // Index 4: "Active Proton Logs" -> PROTON_LOG=1
  if GetGeneralCheckBox(4).Checked then
    LaunchCommand := LaunchCommand + ENV_PROTON_LOG + ' ';

  // Index 5: "Use SDL Input" -> PROTON_USE_SDL=1
  if GetGeneralCheckBox(5).Checked then
    LaunchCommand := LaunchCommand + ENV_PROTON_USE_SDL + ' ';

  // graphicsCheckGroup items
  // Index 0: "Emulate RT (old AMD)" -> RADV_PERFTEST=rt,emulate_rt
  if GetGraphicsCheckBox(0).Checked then
    LaunchCommand := LaunchCommand + ENV_RADV_PERFTEST_RT + ' ';

  // Index 1: "Hide Nvidia GPU" -> PROTON_HIDE_NVIDIA_GPU=1
  if GetGraphicsCheckBox(1).Checked then
    LaunchCommand := LaunchCommand + ENV_PROTON_HIDE_NVIDIA_GPU + ' ';

  // Index 2: "Force enable NVAPI" -> PROTON_ENABLE_NVAPI=1
  if GetGraphicsCheckBox(2).Checked then
    LaunchCommand := LaunchCommand + ENV_PROTON_ENABLE_NVAPI + ' ';

  // Index 3: "Use old WINED3D" -> PROTON_USE_WINED3D=1
  if GetGraphicsCheckBox(3).Checked then
    LaunchCommand := LaunchCommand + ENV_PROTON_USE_WINED3D + ' ';

  // Index 4: "Force Zink" -> MESA_LOADER_DRIVER_OVERRIDE=zink (plus __GLX_VENDOR_LIBRARY_NAME for NVIDIA)
  if GetGraphicsCheckBox(4).Checked then
  begin
    if IsNvidiaModuleLoaded then
      LaunchCommand := LaunchCommand + ENV_GLX_VENDOR_MESA + ' ' + ENV_MESA_LOADER_OVERRIDE + ' '
    else
      LaunchCommand := LaunchCommand + ENV_MESA_LOADER_OVERRIDE + ' ';
  end;

  // "No Fast Clears" -> RADV_DEBUG=nofastclears
  if nofastclearsCheckBox.Checked then
    LaunchCommand := LaunchCommand + ENV_RADV_DEBUG_NOFASTCLEARS + ' ';

  // graphicsCheckGroup upgrade items
  // Index 5: "Automatically upgrade FSR" -> PROTON_FSR4_UPGRADE=1
  if FFSR4UpgradeCheckBox.Checked then
    LaunchCommand := LaunchCommand + ENV_PROTON_FSR4_UPGRADE + ' ';

  // Index 6: "Automatically upgrade DLSS" -> PROTON_DLSS_UPGRADE=1
  if FDLSSUpgradeCheckBox.Checked then
    LaunchCommand := LaunchCommand + ENV_PROTON_DLSS_UPGRADE + ' ';

  // Index 7: "Automatically upgrade XeSS" -> PROTON_XESS_UPGRADE=1
  if FXeSSUpgradeCheckBox.Checked then
    LaunchCommand := LaunchCommand + ENV_PROTON_XESS_UPGRADE + ' ';

  // performanceCheckGroup items
  // Index 0: "Higher priority for games" -> PROTON_PRIORITY_HIGH=1
  if GetPerformanceCheckBox(0).Checked then
    LaunchCommand := LaunchCommand + ENV_PROTON_PRIORITY_HIGH + ' ';

  // Index 1: "Use WOW64" -> PROTON_USE_WOW64=1
  if GetPerformanceCheckBox(1).Checked then
    LaunchCommand := LaunchCommand + ENV_PROTON_USE_WOW64 + ' ';

  // Index 2: "Large Address Aware" -> PROTON_FORCE_LARGE_ADDRESS_AWARE=1
  if GetPerformanceCheckBox(2).Checked then
    LaunchCommand := LaunchCommand + ENV_PROTON_FORCE_LARGE_ADDR + ' ';

  // Index 3: "Staging shared memory" -> STAGING_SHARED_MEMORY=1
  if GetPerformanceCheckBox(3).Checked then
    LaunchCommand := LaunchCommand + ENV_STAGING_SHARED_MEMORY + ' ';

  // Index 4: "Disable NTSYNC" -> PROTON_NO_NTSYNC=1
  if GetPerformanceCheckBox(4).Checked then
    LaunchCommand := LaunchCommand + ENV_PROTON_NO_NTSYNC + ' ';

  // Index 5: "Heap Delay Free" -> PROTON_HEAP_DELAY_FREE=1
  if GetPerformanceCheckBox(5).Checked then
    LaunchCommand := LaunchCommand + ENV_PROTON_HEAP_DELAY_FREE + ' ';

  // Index 6: "Enable AMD Anti-Lag 2" -> ENABLE_LAYER_MESA_ANTI_LAG=1
  if FAntilagCheckBox.Checked then
    LaunchCommand := LaunchCommand + ENV_ENABLE_MESA_ANTILAG + ' ';

  // Index 1: "Always use GameMode" -> -- env gamemoderun (before %command%)
  if GetGeneralCheckBox(1).Checked then
    LaunchCommand := LaunchCommand + ENV_GAMEMODERUN + ' ';

  // Add custom environment variables from grid custom rows
  if Assigned(FTweaksGrid) then
    for i := 1 + TWEAK_ROW_COUNT to FTweaksGrid.RowCount - 1 do
      if (FTweaksGrid.Cells[0, i] = '1') and (Trim(FTweaksGrid.Cells[2, i]) <> '') then
        LaunchCommand := LaunchCommand + Trim(FTweaksGrid.Cells[2, i]) + ' ';

  // Always end with %command%
  LaunchCommand := LaunchCommand + LAUNCH_COMMAND_SUFFIX;

  // In game mode, always write tweaks to the game-specific fgmod (toggle already
  // blocks this path when FNavToolEnabled[3] = False via disabled Save button).
  // In global mode, only write when geSpeedButton (Auto Enable) is ON.
  if (FActiveGameName <> '') or (geSpeedButton.ImageIndex = 1) then
  begin
    if FActiveGameName <> '' then
      FGModFilePath := GetGameConfigDir(FActiveGameName) + 'fgmod'
    else
      FGModFilePath := GetFGModPath + PathDelim + 'fgmod';

    if FileExists(FGModFilePath) then
    begin
      FGModLines := TStringList.Create;
      try
        // Load the fgmod file
        FGModLines.LoadFromFile(FGModFilePath);

        // First, remove any existing tweak export lines to avoid duplicates.
        // NOTE: Do NOT remove 'export WINEDLLOVERRIDES=' here - that line belongs
        // to the OptiScaler section and must never be touched by the Tweaks code.
        for LineIndex := FGModLines.Count - 1 downto 0 do
        begin
          if (Pos(FGMOD_PREFIX_EXPORT_HDR, FGModLines[LineIndex]) > 0) or
             (Pos(FGMOD_PREFIX_EXPORT_HDR_WSI, FGModLines[LineIndex]) > 0) or
             (Pos(FGMOD_PREFIX_EXPORT_WAYLAND, FGModLines[LineIndex]) > 0) or
             (Pos(FGMOD_PREFIX_EXPORT_LOG, FGModLines[LineIndex]) > 0) or
             (Pos(FGMOD_PREFIX_EXPORT_SDL, FGModLines[LineIndex]) > 0) or
             (Pos(FGMOD_MARKER_GAMEMODE, FGModLines[LineIndex]) > 0) or
             // graphicsCheckGroup exports
             (Pos(FGMOD_PREFIX_EXPORT_RADV_RT, FGModLines[LineIndex]) > 0) or
             (Pos(FGMOD_PREFIX_EXPORT_HIDE_NV, FGModLines[LineIndex]) > 0) or
             (Pos(FGMOD_PREFIX_EXPORT_NVAPI, FGModLines[LineIndex]) > 0) or
             (Pos(FGMOD_PREFIX_EXPORT_WINED3D, FGModLines[LineIndex]) > 0) or
             // Zink exports
             (Pos(FGMOD_PREFIX_EXPORT_ZINK, FGModLines[LineIndex]) > 0) or
             (Pos(FGMOD_PREFIX_EXPORT_GLX, FGModLines[LineIndex]) > 0) or
             (Pos(FGMOD_PREFIX_EXPORT_NOFAST, FGModLines[LineIndex]) > 0) or
             (Pos(FGMOD_PREFIX_EXPORT_FSR, FGModLines[LineIndex]) > 0) or
             (Pos(FGMOD_PREFIX_EXPORT_DLSS, FGModLines[LineIndex]) > 0) or
             (Pos(FGMOD_PREFIX_EXPORT_XESS, FGModLines[LineIndex]) > 0) or
             // performanceCheckGroup exports
             (Pos(FGMOD_PREFIX_EXPORT_PRIORITY, FGModLines[LineIndex]) > 0) or
             (Pos(FGMOD_PREFIX_EXPORT_WOW64, FGModLines[LineIndex]) > 0) or
             (Pos(FGMOD_PREFIX_EXPORT_LARGE, FGModLines[LineIndex]) > 0) or
             (Pos(FGMOD_PREFIX_EXPORT_SHMEM, FGModLines[LineIndex]) > 0) or
             (Pos(FGMOD_PREFIX_EXPORT_NTSYNC, FGModLines[LineIndex]) > 0) or
             (Pos(FGMOD_PREFIX_EXPORT_HEAP, FGModLines[LineIndex]) > 0) or
              (Pos(FGMOD_PREFIX_EXPORT_ANTILAG, FGModLines[LineIndex]) > 0) or
              // RE Engine RT workaround marker
              (Pos(FGMOD_MARKER_WINE_DETECTION, FGModLines[LineIndex]) > 0) or
              // Custom environment variable marker
              (Pos(FGMOD_MARKER_CUSTOMENV, FGModLines[LineIndex]) > 0) then
          begin
            FGModLines.Delete(LineIndex);
          end;
        end;

        // Find the "# Execute the original command" line and add enabled tweaks after it
        for LineIndex := 0 to FGModLines.Count - 1 do
        begin
          if Pos(FGMOD_ANCHOR_EXEC, FGModLines[LineIndex]) > 0 then
          begin
            // Insert lines in reverse order so they appear in correct order after insertion.
            // Index 1: "Always use GameMode" -> #gamemode (comment marker)
            if GetGeneralCheckBox(1).Checked then
              FGModLines.Insert(LineIndex + 1, FGMOD_MARKER_GAMEMODE);

            // RE Engine RT workaround marker
            if FReEngineRTCheckBox.Checked then
              FGModLines.Insert(LineIndex + 1, FGMOD_MARKER_WINE_DETECTION);

            // Index 5: "Use SDL Input" -> export PROTON_USE_SDL=1
            if GetGeneralCheckBox(5).Checked then
              FGModLines.Insert(LineIndex + 1, FGMOD_PREFIX_EXPORT_SDL);

            // Index 4: "Active Proton Logs" -> export PROTON_LOG=1
            if GetGeneralCheckBox(4).Checked then
              FGModLines.Insert(LineIndex + 1, FGMOD_PREFIX_EXPORT_LOG);

            // Index 3: "Enable Wayland" -> export PROTON_ENABLE_WAYLAND=1
            if GetGeneralCheckBox(3).Checked then
              FGModLines.Insert(LineIndex + 1, FGMOD_PREFIX_EXPORT_WAYLAND);

            // Index 2: "Enable HDR" -> export PROTON_ENABLE_HDR=1 and ENABLE_HDR_WSI=1
            if GetGeneralCheckBox(2).Checked then
            begin
              FGModLines.Insert(LineIndex + 1, FGMOD_PREFIX_EXPORT_HDR_WSI);
              FGModLines.Insert(LineIndex + 1, FGMOD_PREFIX_EXPORT_HDR);
            end;

            // graphicsCheckGroup items (insert in reverse order)
            // Index 3: "Use old WINED3D" -> export PROTON_USE_WINED3D=1
            if GetGraphicsCheckBox(3).Checked then
              FGModLines.Insert(LineIndex + 1, FGMOD_PREFIX_EXPORT_WINED3D);

            // Index 2: "Force enable NVAPI" -> export PROTON_ENABLE_NVAPI=1
            if GetGraphicsCheckBox(2).Checked then
              FGModLines.Insert(LineIndex + 1, FGMOD_PREFIX_EXPORT_NVAPI);

            // Index 1: "Hide Nvidia GPU" -> export PROTON_HIDE_NVIDIA_GPU=1
            if GetGraphicsCheckBox(1).Checked then
              FGModLines.Insert(LineIndex + 1, FGMOD_PREFIX_EXPORT_HIDE_NV);

            if GetGraphicsCheckBox(0).Checked then
              FGModLines.Insert(LineIndex + 1, FGMOD_PREFIX_EXPORT_RADV_RT);

            // "No Fast Clears" -> export RADV_DEBUG=nofastclears
            if nofastclearsCheckBox.Checked then
              FGModLines.Insert(LineIndex + 1, FGMOD_PREFIX_EXPORT_NOFAST);

            // Index 4: "Force Zink" -> MESA_LOADER_DRIVER_OVERRIDE=zink (plus __GLX_VENDOR_LIBRARY_NAME for NVIDIA)
            if GetGraphicsCheckBox(4).Checked then
            begin
              if IsNvidiaModuleLoaded then
              begin
                FGModLines.Insert(LineIndex + 1, FGMOD_PREFIX_EXPORT_ZINK);
                FGModLines.Insert(LineIndex + 1, FGMOD_PREFIX_EXPORT_GLX);
              end
              else
              begin
                FGModLines.Insert(LineIndex + 1, FGMOD_PREFIX_EXPORT_ZINK);
              end;
            end;

            // performanceCheckGroup items (insert in reverse order)
            // Index 6: "Enable AMD Anti-Lag 2" -> export ENABLE_LAYER_MESA_ANTI_LAG=1
            if FAntilagCheckBox.Checked then
              FGModLines.Insert(LineIndex + 1, FGMOD_PREFIX_EXPORT_ANTILAG);

            // Index 5: "Heap Delay Free" -> export PROTON_HEAP_DELAY_FREE=1
            if GetPerformanceCheckBox(5).Checked then
              FGModLines.Insert(LineIndex + 1, FGMOD_PREFIX_EXPORT_HEAP);

            // graphicsCheckGroup upgrade items (insert in reverse order)
            // Index 7: "Automatically upgrade XeSS" -> export PROTON_XESS_UPGRADE=1
            if FXeSSUpgradeCheckBox.Checked then
              FGModLines.Insert(LineIndex + 1, FGMOD_PREFIX_EXPORT_XESS);

            // Index 6: "Automatically upgrade DLSS" -> export PROTON_DLSS_UPGRADE=1
            if FDLSSUpgradeCheckBox.Checked then
              FGModLines.Insert(LineIndex + 1, FGMOD_PREFIX_EXPORT_DLSS);

            // Index 5: "Automatically upgrade FSR" -> export PROTON_FSR4_UPGRADE=1
            if FFSR4UpgradeCheckBox.Checked then
              FGModLines.Insert(LineIndex + 1, FGMOD_PREFIX_EXPORT_FSR);

            // Index 4: "Disable NTSYNC" -> export PROTON_NO_NTSYNC=1
            if GetPerformanceCheckBox(4).Checked then
              FGModLines.Insert(LineIndex + 1, FGMOD_PREFIX_EXPORT_NTSYNC);

            // Index 3: "Staging shared memory" -> export STAGING_SHARED_MEMORY=1
            if GetPerformanceCheckBox(3).Checked then
              FGModLines.Insert(LineIndex + 1, FGMOD_PREFIX_EXPORT_SHMEM);

            // Index 2: "Large Address Aware" -> export PROTON_FORCE_LARGE_ADDRESS_AWARE=1
            if GetPerformanceCheckBox(2).Checked then
              FGModLines.Insert(LineIndex + 1, FGMOD_PREFIX_EXPORT_LARGE);

            // Index 1: "Use WOW64" -> export PROTON_USE_WOW64=1
            if GetPerformanceCheckBox(1).Checked then
              FGModLines.Insert(LineIndex + 1, FGMOD_PREFIX_EXPORT_WOW64);

            // Index 0: "Higher priority for games" -> export PROTON_PRIORITY_HIGH=1
            if GetPerformanceCheckBox(0).Checked then
              FGModLines.Insert(LineIndex + 1, FGMOD_PREFIX_EXPORT_PRIORITY);

            // Custom environment variables from grid (insert in reverse so order is preserved)
            if Assigned(FTweaksGrid) then
              for i := FTweaksGrid.RowCount - 1 downto 1 + TWEAK_ROW_COUNT do
                if (FTweaksGrid.Cells[0, i] = '1') and (Trim(FTweaksGrid.Cells[2, i]) <> '') then
                  FGModLines.Insert(LineIndex + 1, '  export ' + Trim(FTweaksGrid.Cells[2, i]) + ' #customenv');

            Break;
          end;
        end;

        // Handle "Simulate Steam Deck" (index 0).
        // Try to modify existing SteamDeck line first; if not found, leave as-is
        // (the embedded fgmod template already contains 'export SteamDeck=0' after the anchor).
        for LineIndex := 0 to FGModLines.Count - 1 do
        begin
          if Pos(FGMOD_PREFIX_STEAMDECK, FGModLines[LineIndex]) > 0 then
          begin
            if GetGeneralCheckBox(0).Checked then
              FGModLines[LineIndex] := FGMOD_PREFIX_STEAMDECK + '1'
            else
              FGModLines[LineIndex] := FGMOD_PREFIX_STEAMDECK + '0';
            Break;
          end;
        end;

        // Save the modified file
        FGModLines.SaveToFile(FGModFilePath);

        // Refresh grid to reflect saved state
        SyncTweaksGridFromCheckBoxes;

        // Show notification
        SendNotification('Tweaks', 'Configuration saved', GetIconFile);

        // Build launch command with full absolute path for fgmod
        // (Done globally below)

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
    // geSpeedButton is OFF (global mode only) - check if there are any tweaks selected.
    // If the user has checked tweaks, auto-enable Auto Enable and save to fgmod.
    // This avoids the confusing case where tweaks are selected but never saved.
    // In game mode this branch is never reached (condition above is always true).
    if GetGeneralCheckBox(0).Checked or GetGeneralCheckBox(1).Checked or
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
        FFSR4UpgradeCheckBox.Checked or
        FDLSSUpgradeCheckBox.Checked or
        FXeSSUpgradeCheckBox.Checked or
        FReEngineRTCheckBox.Checked or
        (Assigned(FTweaksGrid) and (FTweaksGrid.RowCount > 1 + TWEAK_ROW_COUNT)) then
    begin
      // Auto-enable Auto Enable and save
      geSpeedButton.ImageIndex := 1;
      SaveTweaksConfig;
      Exit;
    end
    else
    begin
      // No tweaks selected and Auto Enable is OFF - just show notification
      SendNotification('Tweaks', 'Nenhuma tweak selecionada para guardar', GetIconFile);
    end;
  end;

  // Build launch command — use game-specific fgmod copy when in game mode
  if FActiveGameName <> '' then
    LaunchCommand := '"' + GetGameConfigDir(FActiveGameName) + 'fgmod" '
  else
    LaunchCommand := '"' + GetFGModPath + '/fgmod" ';
  // Index 1: "Always use GameMode" -> -- env gamemoderun (before %command%)
  if GetGeneralCheckBox(1).Checked then
    LaunchCommand := LaunchCommand + ENV_GAMEMODERUN + ' ';
  // Always end with %command%
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
var
  FGModFilePath: string;
  FGModLines: TStringList;
  LineIndex: Integer;
  LineFound, WineOverrideFound: Boolean;
  SelectedDllName, DllNameWithoutExt: string;
  OptiScalerIniPath: string;
  OptiCfg: TConfigFile;
  SelectedShortcutKey, ScaleValue: string;
  ScaleFloat: Double;
  FS: TFormatSettings;
  OverrideNvapiDllValue: string;
  DxgiValue: string;
  LoadAsiPluginsValue: string;
  Fsr4UpdateValue: string;
  FakeNvapiIniPath: string;
  FakeCfg: TConfigFile;
  ForceReflexValue: string;
  ForceLatencyFlexValue, LatencyFlexModeValue: string;
  EnableTraceLogsValue: string;
  LaunchCommand: string;
  FGModPath, FGModDestPath, VarsFilePath: string;
  Lines: TStringList;
  i: Integer;
begin
  // If geSpeedButton is OFF, just show notification and exit - no fgmod modification needed
  if geSpeedButton.ImageIndex = 0 then
  begin
    SendNotification('OptiScaler', 'Configuration saved (Auto Enable disabled)', GetIconFile);
    Exit;
  end;

  // Get the fgmod file path
  if FActiveGameName <> '' then
    FGModFilePath := GetGameConfigDir(FActiveGameName) + 'fgmod'
  else
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
        0: SelectedDllName := OPTI_DLL_DXGI;
        1: SelectedDllName := OPTI_DLL_VERSION;
        2: SelectedDllName := OPTI_DLL_DBGHELP;
        3: SelectedDllName := OPTI_DLL_D3D12;
        4: SelectedDllName := OPTI_DLL_WININET;
        5: SelectedDllName := OPTI_DLL_WINHTTP;
        6: SelectedDllName := OPTI_DLL_WINMM;
        7: SelectedDllName := OPTI_DLL_ASI;
      else
        SelectedDllName := OPTI_DLL_DXGI; // Default
      end;

      // Extract DLL name without extension
      DllNameWithoutExt := ChangeFileExt(SelectedDllName, '');

      // Search for the line containing dll_name="${DLL:-
      LineFound := False;
      for LineIndex := 0 to FGModLines.Count - 1 do
      begin
        if Pos(OPTI_DLL_NAME_ANCHOR, FGModLines[LineIndex]) > 0 then
        begin
          // Replace the line with the new DLL name
          FGModLines[LineIndex] := OPTI_DLL_NAME_ANCHOR + SelectedDllName + '}"';
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
          if Pos(OPTI_WINEOVERRIDES_PREFIX, FGModLines[LineIndex]) > 0 then
          begin
            // Replace the line with the new DLL name (without extension)
            FGModLines[LineIndex] := OPTI_WINEOVERRIDES_PREFIX + DllNameWithoutExt + OPTI_WINEOVERRIDES_SUFFIX;
            WineOverrideFound := True;
            Break;
          end;
        end;

        // If WINEDLLOVERRIDES line not found, add it after "# Execute the original command"
        if not WineOverrideFound then
        begin
          for LineIndex := 0 to FGModLines.Count - 1 do
          begin
            if Pos(FGMOD_ANCHOR_EXEC, FGModLines[LineIndex]) > 0 then
            begin
              FGModLines.Insert(LineIndex + 1, '  ' + OPTI_WINEOVERRIDES_PREFIX + DllNameWithoutExt + OPTI_WINEOVERRIDES_SUFFIX);
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
          if Pos(OPTI_EMUFP8_LINE, FGModLines[LineIndex]) > 0 then
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
            if Pos(OPTI_WINEOVERRIDES_PREFIX, FGModLines[LineIndex]) > 0 then
            begin
              // Insert the DXIL_SPIRV_CONFIG line right after WINEDLLOVERRIDES
              FGModLines.Insert(LineIndex + 1, '  ' + OPTI_EMUFP8_LINE);
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
        if FActiveGameName <> '' then
          OptiScalerIniPath := GetGameConfigDir(FActiveGameName) + 'OptiScaler.ini'
        else
          OptiScalerIniPath := GetOptiScalerInstallPath + PathDelim + 'OptiScaler.ini';

        // Get ShortcutKey from hidden combobox (stores hex VK code or 'auto')
        SelectedShortcutKey := Trim(shortcutkeyComboBox.Text);
        if SelectedShortcutKey = '' then
          SelectedShortcutKey := 'auto';

        // Calculate Scale value from menuscaleTrackBar (divide by 10)
        ScaleFloat := menuscaleTrackBar.Position / 10.0;
        // Format with dot as decimal separator
        FS := DefaultFormatSettings;
        FS.DecimalSeparator := '.';
        ScaleValue := FloatToStrF(ScaleFloat, ffFixed, 3, 1, FS);

        // Get OverrideNvapiDll value from overrideCheckBox
        if overrideCheckBox.Checked then
          OverrideNvapiDllValue := 'true'
        else
          OverrideNvapiDllValue := 'auto';

        // Get Dxgi value from spoofCheckBox (Spoof DLSS inputs)
        if spoofCheckBox.Checked then
          DxgiValue := 'auto'
        else
          DxgiValue := 'false';

        // Get Fsr4Update value from fsrversionComboBox
        if fsrversionComboBox.ItemIndex = 0 then
          Fsr4UpdateValue := 'True'
        else
          Fsr4UpdateValue := 'auto';

        // Get LoadAsiPlugins value from optipatcherCheckBox
        if optipatcherCheckBox.Checked then
          LoadAsiPluginsValue := 'true'
        else
          LoadAsiPluginsValue := 'auto';

        // Check if OptiScaler.ini exists
        // Update OptiScaler.ini using TConfigFile wrapper
        OptiCfg := TConfigFile.Create;
        try
          if OptiCfg.Load(OptiScalerIniPath) then
          begin
            OptiCfg.SetValue(OPTI_KEY_SHORTCUT, SelectedShortcutKey, OPTI_INI_SECTION_MENU);
            OptiCfg.SetValue(OPTI_KEY_SCALE, ScaleValue, OPTI_INI_SECTION_MENU);
            OptiCfg.SetValue(OPTI_KEY_OVERRIDE_NVAPI, OverrideNvapiDllValue);
            OptiCfg.SetValue(OPTI_KEY_DXGI, DxgiValue);
            OptiCfg.SetValue(OPTI_KEY_LOAD_ASI, LoadAsiPluginsValue);
            OptiCfg.SetValue(OPTI_KEY_FSR4_UPDATE, Fsr4UpdateValue);
            OptiCfg.Save;
          end;
        finally
          OptiCfg.Free;
        end;
        // Silently skip if OptiScaler.ini doesn't exist (OptiScaler not installed yet)

        // ##### Now modify fakenvapi.ini file #####
        begin
          // Get fakenvapi.ini file path
          if FActiveGameName <> '' then
            FakeNvapiIniPath := GetGameConfigDir(FActiveGameName) + 'fakenvapi.ini'
          else
            FakeNvapiIniPath := GetOptiScalerInstallPath + PathDelim + 'fakenvapi.ini';

          // Get selected force_reflex value from reflexComboBox
          if forcereflexCheckBox.Checked then
          begin
            case reflexComboBox.ItemIndex of
              0: ForceReflexValue := '0';
              1: ForceReflexValue := '1';
              2: ForceReflexValue := '2';
            end;
          end
          else
            ForceReflexValue := '0';

          // Get force_latencyflex and latencyflex_mode values
          if forcelatencyflexCheckBox.Checked then
          begin
            ForceLatencyFlexValue := '1';
            case latencyflexComboBox.ItemIndex of
              0: LatencyFlexModeValue := '0';
              1: LatencyFlexModeValue := '1';
              2: LatencyFlexModeValue := '2';
            else
              LatencyFlexModeValue := '0';
            end;
          end
          else
          begin
            ForceLatencyFlexValue := '0';
            LatencyFlexModeValue := '0';
          end;

          // Get enable_trace_logs value from tracelogCheckBox
          if tracelogCheckBox.Checked then
            EnableTraceLogsValue := '1'
          else
            EnableTraceLogsValue := '0';

          // Update fakenvapi.ini using TConfigFile wrapper
          FakeCfg := TConfigFile.Create;
          try
            if FakeCfg.Load(FakeNvapiIniPath) then
            begin
              FakeCfg.SetValue(FAKE_KEY_FORCE_REFLEX, ForceReflexValue);
              FakeCfg.SetValue(FAKE_KEY_FORCE_LATENCY, ForceLatencyFlexValue);
              FakeCfg.SetValue(FAKE_KEY_LATENCY_MODE, LatencyFlexModeValue);
              FakeCfg.SetValue(FAKE_KEY_TRACE_LOGS, EnableTraceLogsValue);
              if (not forcereflexCheckBox.Checked or FakeCfg.HasKey(FAKE_KEY_FORCE_REFLEX)) and
                 (not forcelatencyflexCheckBox.Checked or (FakeCfg.HasKey(FAKE_KEY_FORCE_LATENCY) and FakeCfg.HasKey(FAKE_KEY_LATENCY_MODE))) then
                FakeCfg.Save
              else
              begin
                if forcereflexCheckBox.Checked and not FakeCfg.HasKey(FAKE_KEY_FORCE_REFLEX) then
                  ShowMessage('Warning: Could not find force_reflex line in fakenvapi.ini file');
                if forcelatencyflexCheckBox.Checked and not FakeCfg.HasKey(FAKE_KEY_FORCE_LATENCY) then
                  ShowMessage('Warning: Could not find force_latencyflex line in fakenvapi.ini file');
                if forcelatencyflexCheckBox.Checked and not FakeCfg.HasKey(FAKE_KEY_LATENCY_MODE) then
                  ShowMessage('Warning: Could not find latencyflex_mode line in fakenvapi.ini file');
              end;
            end;
          finally
            FakeCfg.Free;
          end;
          // Silently skip if fakenvapi.ini doesn't exist (OptiScaler not installed yet)
        end;

        // ##### Copy FSR4 DLL based on fsrversionCombobox selection #####
        try
          // FSR4 sub-folders (FSR4_LATEST, FSR4_INT8) always live in the global install path
          FGModPath := GetOptiScalerInstallPath;
          // Destination: game config dir in game mode, global install path in global mode
          if FActiveGameName <> '' then
            FGModDestPath := ExcludeTrailingPathDelimiter(GetGameConfigDir(FActiveGameName))
          else
            FGModDestPath := FGModPath;

          case fsrversionComboBox.ItemIndex of
            0: // Latest (FP8)
              begin
                // Copy amd_fidelityfx_upscaler_dx12.dll from FSR4_LATEST to destination root
                if FileExists(IncludeTrailingPathDelimiter(FGModPath) + 'FSR4_LATEST' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll') then
                begin
                  CopyFile(IncludeTrailingPathDelimiter(FGModPath) + 'FSR4_LATEST' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll',
                           IncludeTrailingPathDelimiter(FGModDestPath) + 'amd_fidelityfx_upscaler_dx12.dll');

                  // Add fsrversion=Latest (FP8) to goverlay.vars
                  VarsFilePath := IncludeTrailingPathDelimiter(FGModDestPath) + 'goverlay.vars';
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
                      Lines.Add('fsrversion=Latest (FP8)');

                      // Save the file
                      Lines.SaveToFile(VarsFilePath);
                    finally
                      Lines.Free;
                    end;
                  end;
                end;
                // Silently skip if FSR4_LATEST doesn't exist (OptiScaler not installed yet)
              end;

            1: // 4.0.2c (INT8)
              begin
                // Copy amd_fidelityfx_upscaler_dx12.dll from FSR4_INT8 to destination root
                if FileExists(IncludeTrailingPathDelimiter(FGModPath) + 'FSR4_INT8' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll') then
                begin
                  CopyFile(IncludeTrailingPathDelimiter(FGModPath) + 'FSR4_INT8' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll',
                           IncludeTrailingPathDelimiter(FGModDestPath) + 'amd_fidelityfx_upscaler_dx12.dll');

                  // Add fsrversion line to goverlay.vars
                  VarsFilePath := IncludeTrailingPathDelimiter(FGModDestPath) + 'goverlay.vars';
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
                      Lines.Add('fsrversion=4.0.2c (INT8)');

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

        // Build launch command — use game-specific fgmod copy when in game mode
        if FActiveGameName <> '' then
          LaunchCommand := '"' + GetGameConfigDir(FActiveGameName) + 'fgmod" '
        else
          LaunchCommand := '"' + GetFGModPath + '/fgmod" ';

        // Check if gamemode should be added
        if GetGeneralCheckBox(1).Checked then
          LaunchCommand := LaunchCommand + ENV_GAMEMODERUN + ' ';

        LaunchCommand := LaunchCommand + LAUNCH_COMMAND_SUFFIX;

        notificationLabel.Visible := False;
        FLaunchCommand := LaunchCommand;
        commandPaintBox.Invalidate;
        commandPanel.Visible := True;
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
end;

procedure Tgoverlayform.SaveVkBasaltConfig;
var
  RepoDir, RelPath, EffectName, EffectKey, FullPath, EffectsLine: string;
  TexPath, IncPath: string;
  Lines: TStringList;
  Sharp: Double;
  FxaaQuality: Double;
  SmaaCorner: Double;
  DlsSharp: Double;
  FS: TFormatSettings;
  LaunchCommand: string;
  i: Integer;
begin
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
      EffectsLine := EffectsLine + 'cas';
    // 2) FXAA (if active)
    if fxaatrackbar.Position >= 1 then
    begin
      if EffectsLine <> '' then
        EffectsLine := EffectsLine + ':';
      EffectsLine := EffectsLine + 'fxaa';
    end;
    // 3) SMAA (if active)
    if smaatrackbar.Position >= 1 then
    begin
      if EffectsLine <> '' then
        EffectsLine := EffectsLine + ':';
      EffectsLine := EffectsLine + 'smaa';
    end;
    // 4) DLS (if active)
    if dlstrackbar.Position >= 1 then
    begin
      if EffectsLine <> '' then
        EffectsLine := EffectsLine + ':';
      EffectsLine := EffectsLine + 'dls';
    end;
    // 5) reshade effects on the list
    for i := 0 to acteffectsListbox.Items.Count - 1 do
    begin
      RelPath := acteffectsListbox.Items[i];
      EffectName := ChangeFileExt(ExtractFileName(RelPath), '');
      EffectKey := EffectName;
      if EffectsLine <> '' then
        EffectsLine := EffectsLine + ':';
      EffectsLine := EffectsLine + EffectName;
    end;
    if EffectsLine <> '' then
      Lines.Add('effects = ' + EffectsLine);
    Lines.Add('');
    // --- CAS ajustment if active ---
    if casTrackBar.Position >= 1 then
    begin
      Sharp := casTrackBar.Position / 10.0;
      FS := DefaultFormatSettings;
      FS.DecimalSeparator := '.';
      Lines.Add('casSharpness = ' + FloatToStrF(Sharp, ffFixed, 3, 1, FS));
    end;
    // --- FXAA adjustment if active ---
    if fxaatrackbar.Position >= 1 then
    begin
      FxaaQuality := fxaatrackbar.Position / 10.0;
      FS := DefaultFormatSettings;
      FS.DecimalSeparator := '.';
      Lines.Add('fxaaQualitySubpix = ' + FloatToStrF(FxaaQuality, ffFixed, 3, 1, FS));
    end;
    // --- SMAA adjustment if active ---
    if smaatrackbar.Position >= 1 then
    begin
      FS := DefaultFormatSettings;
      FS.DecimalSeparator := '.';
      SmaaCorner := 25.0 * (smaatrackbar.Position - 1) / 9.0;
      Lines.Add('smaaCornerRounding = ' + FloatToStrF(SmaaCorner, ffFixed, 3, 1, FS));
      Lines.Add('smaaThreshold = ' + FloatToStrF(0.1 - 0.05 * (smaatrackbar.Position - 1) / 9.0, ffFixed, 3, 2, FS));
      Lines.Add('smaaMaxSearchSteps = ' + IntToStr(Round(16 + 16 * (smaatrackbar.Position - 1) / 9.0)));
      Lines.Add('smaaMaxSearchStepsDiag = ' + IntToStr(Round(8 + 8 * (smaatrackbar.Position - 1) / 9.0)));
    end;
    // --- DLS adjustment if active ---
    if dlstrackbar.Position >= 1 then
    begin
      DlsSharp := (dlstrackbar.Position - 1) / 9.0;
      FS := DefaultFormatSettings;
      FS.DecimalSeparator := '.';
      Lines.Add('dlsSharpness = ' + FloatToStrF(DlsSharp, ffFixed, 3, 1, FS));
    end;
    // --- Map reshade effects ---
    for i := 0 to acteffectsListbox.Items.Count - 1 do
    begin
      RelPath := acteffectsListbox.Items[i];
      EffectName := ChangeFileExt(ExtractFileName(RelPath), '');
      EffectKey := EffectName;
      FullPath := IncludeTrailingPathDelimiter(RepoDir) + RelPath;
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

    // In game-specific mode: inject VKBASALT_CONFIG_FILE into the game fgmod
    if FActiveGameName <> '' then
      PatchGameFGModConfigPath(
        GetGameConfigDir(FActiveGameName) + 'fgmod',
        'VKBASALT_CONFIG_FILE',
        VKBASALTCFGFILE);

    SendNotification('vkBasalt', 'configuration saved', GetIconFile);

    // Always show the fgmod command — use game-specific fgmod copy when in game mode
    if FActiveGameName <> '' then
      LaunchCommand := '"' + GetGameConfigDir(FActiveGameName) + 'fgmod" '
    else
      LaunchCommand := '"' + GetFGModPath + '/fgmod" ';

    // Check if gamemode should be added (check generalCheckGroup)
    if GetGeneralCheckBox(1).Checked then
      LaunchCommand := LaunchCommand + ENV_GAMEMODERUN + ' ';

    LaunchCommand := LaunchCommand + LAUNCH_COMMAND_SUFFIX;

    notificationLabel.Visible := False;
    FLaunchCommand := LaunchCommand;
    commandPaintBox.Invalidate;
    commandPanel.Visible := True;
  except
    on E: Exception do
      ShowMessage('Fail to save vkbasalt.conf: ' + E.Message);
  end;
  Lines.Free;
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
        LaunchCommand := '"' + GetGameConfigDir(FActiveGameName) + 'fgmod" '
      else
        LaunchCommand := '"' + GetFGModPath + '/fgmod" ';

      // Check if gamemode should be added (check generalCheckGroup)
      if GetGeneralCheckBox(1).Checked then
        LaunchCommand := LaunchCommand + ENV_GAMEMODERUN + ' ';

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
  FGModFilePath: string;
  FileLines: TStringList;
  i: Integer;
  LineRemoved: Boolean;
begin
  // Get fgmod file path
  if FActiveGameName <> '' then
    FGModFilePath := GetGameConfigDir(FActiveGameName) + 'fgmod'
  else
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

// ============================================================================
// PRESETS — modern card-grid UI
// ============================================================================

procedure Tgoverlayform.BuildPresetsWrapper;
const
  WRAPPER_W  = 829;
  PC_W       = 130;   // card outer width
  PC_H       = 140;   // card outer height (18 top + 70 img + 8 gap + 18 label + 23 bottom + 3 sel)
  PC_IMG_SZ  = 70;    // native layoutImageList size — no scaling, no quality loss
  PC_IMG_T   = 18;    // image top padding inside card
  PC_SEL_H   = 3;     // selection indicator bar height
const
  LAYOUT_TITLES: array[0..4] of string = (
    'Full', 'Basic', 'Basic Horizontal', 'FPS only', 'Custom');
  LAYOUT_IMG: array[0..4] of Integer = (0, 1, 2, 3, 4);
  COLOR_TITLES: array[0..3] of string = (
    'MangoHud Stock', 'Goverlay', 'Simple White', 'Old Afterburner');
  COLOR_IMG: array[0..3] of Integer = (5, 8, 6, 7);
var
  i: Integer;
  Bmp: TBitmap;
  CardImg: TImage;
  CardLbl: TLabel;
  CtrlsToMove: array of TControl;

  procedure MakeCard(var ACard: TPanel; var ASelBar: TPanel;
                     ImgIdx: Integer; const Title: string; ATag: Integer);
  begin
    ACard := TPanel.Create(Self);
    ACard.Parent       := FPresetsWrapper;
    ACard.BevelOuter   := bvNone;
    ACard.Caption      := '';
    ACard.Tag          := ATag;
    ACard.Cursor       := crHandPoint;
    ACard.OnPaint      := @PresetCardPaint;
    ACard.OnClick      := @PresetCardClick;
    ACard.OnMouseEnter := @PresetCardMouseEnter;
    ACard.OnMouseLeave := @PresetCardMouseLeave;
    ACard.SetBounds(0, 0, PC_W, PC_H);

    // Image centred horizontally at native 70×70 — no stretch, pixel-perfect
    CardImg := TImage.Create(ACard);
    CardImg.Parent       := ACard;
    CardImg.Stretch      := False;
    CardImg.Proportional := False;
    CardImg.Center       := False;
    CardImg.Transparent  := True;
    CardImg.SetBounds((PC_W - PC_IMG_SZ) div 2, PC_IMG_T, PC_IMG_SZ, PC_IMG_SZ);
    CardImg.Tag          := ATag;
    CardImg.OnClick      := @PresetCardClick;
    CardImg.OnMouseEnter := @PresetCardMouseEnter;
    CardImg.OnMouseLeave := @PresetCardMouseLeave;
    Bmp := TBitmap.Create;
    try
      layoutImageList.GetBitmap(ImgIdx, Bmp);
      CardImg.Picture.Assign(Bmp);
    finally Bmp.Free; end;

    // Title label centred in card width
    CardLbl := TLabel.Create(ACard);
    CardLbl.Parent      := ACard;
    CardLbl.Caption     := Title;
    CardLbl.AutoSize    := False;
    CardLbl.Alignment   := taCenter;
    CardLbl.Width       := PC_W;
    CardLbl.Left        := 0;
    CardLbl.Top         := PC_IMG_T + PC_IMG_SZ + 8;
    CardLbl.Height      := 18;
    CardLbl.Font.Size   := 8;
    CardLbl.Transparent := True;
    CardLbl.Tag         := ATag;
    CardLbl.OnClick     := @PresetCardClick;
    CardLbl.OnMouseEnter := @PresetCardMouseEnter;
    CardLbl.OnMouseLeave := @PresetCardMouseLeave;

    // Selection indicator bar (bottom edge, hidden until active)
    ASelBar := TPanel.Create(ACard);
    ASelBar.Parent     := ACard;
    ASelBar.BevelOuter := bvNone;
    ASelBar.Caption    := '';
    ASelBar.Color      := clHighlight;
    ASelBar.SetBounds(0, PC_H - PC_SEL_H, PC_W, PC_SEL_H);
    ASelBar.Visible    := False;
  end;

begin
  FActiveLayoutCard  := -1;
  FActiveColorCard   := -1;
  FHoveredPresetCard := nil;

  // Move all existing .lfm children into the wrapper so they share the
  // coordinate space; we then hide the legacy BitBtn/Label controls.
  SetLength(CtrlsToMove, presetTabSheet.ControlCount);
  for i := 0 to presetTabSheet.ControlCount - 1 do
    CtrlsToMove[i] := presetTabSheet.Controls[i];

  // TPaintBox as background — drawn first (lowest z-order), fills the entire tab
  FPresetsBgBox := TPaintBox.Create(Self);
  FPresetsBgBox.Parent  := presetTabSheet;
  FPresetsBgBox.Align   := alClient;
  FPresetsBgBox.OnPaint := @PresetsBgBoxPaint;

  // Wrapper: child of tabsheet, sits above the paintbox
  // OnPaint fills with the same navy — Qt6 ignores Color on TPanel without it
  FPresetsWrapper := TPanel.Create(Self);
  FPresetsWrapper.Parent      := presetTabSheet;
  FPresetsWrapper.BevelOuter  := bvNone;
  FPresetsWrapper.BorderStyle := bsNone;
  FPresetsWrapper.Caption     := '';
  FPresetsWrapper.OnPaint     := @PresetsWrapperPaint;
  FPresetsWrapper.Top         := 0;
  FPresetsWrapper.Left        := 0;
  FPresetsWrapper.Width       := WRAPPER_W;
  FPresetsWrapper.Anchors     := [akTop, akBottom];
  FPresetsWrapper.Height      := presetTabSheet.ClientHeight;

  for i := 0 to High(CtrlsToMove) do
    CtrlsToMove[i].Parent := FPresetsWrapper;

  // Hide all legacy .lfm BitBtn controls and their labels
  fullBitBtn.Visible              := False;
  basicBitBtn.Visible             := False;
  basichorizontalBitBtn.Visible   := False;
  fpsonlyBitBtn.Visible           := False;
  usercustomBitBtn.Visible        := False;
  mangocolorBitBtn.Visible        := False;
  goverlayBitBtn.Visible          := False;
  whitecolorBitBtn.Visible        := False;
  afterburnercolorBitBtn1.Visible := False;
  fullLabel.Visible               := False;
  basicLabel.Visible              := False;
  basichorizontalLabel.Visible    := False;
  fpsonlyLabel.Visible            := False;
  customLabel.Visible             := False;
  mangocolorLabel.Visible         := False;
  customolorLabel.Visible         := False;
  whitecolorLabel.Visible         := False;
  afterburnercolorLabel.Visible   := False;

  // Style the section header labels (already inside FPresetsWrapper)
  layoutsLabel.Font.Size   := 10;
  layoutsLabel.Font.Style  := [fsBold];
  layoutsLabel.Transparent := True;
  layoutsLabel.AutoSize    := True;

  colorthemeLabel.Font.Size   := 10;
  colorthemeLabel.Font.Style  := [fsBold];
  colorthemeLabel.Transparent := True;
  colorthemeLabel.AutoSize    := True;

  // Build layout preset cards — Tags 100-104
  for i := 0 to 4 do
    MakeCard(FPresetLayoutCards[i], FPresetLayoutSelBars[i],
             LAYOUT_IMG[i], LAYOUT_TITLES[i], 100 + i);

  // Build color preset cards — Tags 200-203
  for i := 0 to 3 do
    MakeCard(FPresetColorCards[i], FPresetColorSelBars[i],
             COLOR_IMG[i], COLOR_TITLES[i], 200 + i);
end;

// ---------------------------------------------------------------------------
// Preset card helpers
// ---------------------------------------------------------------------------

function Tgoverlayform.FindPresetCard(ASender: TObject): TPanel;
var
  SenderTag: PtrInt;
  i: Integer;
begin
  Result := nil;
  if not (ASender is TControl) then Exit;
  SenderTag := TControl(ASender).Tag;
  for i := 0 to 4 do
    if Assigned(FPresetLayoutCards[i]) and (FPresetLayoutCards[i].Tag = SenderTag) then
    begin Result := FPresetLayoutCards[i]; Exit; end;
  for i := 0 to 3 do
    if Assigned(FPresetColorCards[i]) and (FPresetColorCards[i].Tag = SenderTag) then
    begin Result := FPresetColorCards[i]; Exit; end;
end;

procedure Tgoverlayform.UpdatePresetCardVisuals;
var
  i, j: Integer;
  LblColor: TColor;
begin
  // Card label text colour depends on the painted background — always light on
  // dark cards, always dark on light cards, regardless of the global theme.
  if CurrentTheme = tmLight then
    LblColor := LightTextColor
  else
    LblColor := DarkTextColor;

  // Selection bar is drawn directly in PresetCardPaint — no TPanel visibility needed.
  // We only Invalidate each card so OnPaint runs with the updated FActiveLayoutCard/
  // FActiveColorCard state.
  for i := 0 to 4 do
  begin
    FPresetLayoutCards[i].Invalidate;
    for j := 0 to FPresetLayoutCards[i].ControlCount - 1 do
      if FPresetLayoutCards[i].Controls[j] is TLabel then
        TLabel(FPresetLayoutCards[i].Controls[j]).Font.Color := LblColor;
  end;
  for i := 0 to 3 do
  begin
    FPresetColorCards[i].Invalidate;
    for j := 0 to FPresetColorCards[i].ControlCount - 1 do
      if FPresetColorCards[i].Controls[j] is TLabel then
        TLabel(FPresetColorCards[i].Controls[j]).Font.Color := LblColor;
  end;
end;

procedure Tgoverlayform.PresetCardPaint(Sender: TObject);
const
  // Dark theme — Lazarus TColor = $00BBGGRR (Blue, Green, Red byte order)
  DARK_BG     = $003E2E2E;   // RGB( 46, 46, 62) dark blue-gray
  DARK_HOVER  = $004E3A3A;   // RGB( 58, 58, 78) slightly lighter
  DARK_SEL    = $0050321E;   // RGB( 30, 50, 80) blue-tinted selection
  DARK_BRD    = $00645050;   // RGB( 80, 80,100) subtle border
  DARK_H_BRD  = $00998888;   // RGB(136,136,153) hover border
  // Light theme
  LIGHT_BG    = $00F2F2F2;   // RGB(242,242,242) near-white
  LIGHT_HOVER = $00EEE4E4;   // RGB(228,228,238) faint blue tint
  LIGHT_SEL   = $00FFE8DC;   // RGB(220,232,255) light blue selection
  LIGHT_BRD   = $00C8C0C0;   // RGB(192,192,200) light border
  LIGHT_H_BRD = $00A09090;   // RGB(144,144,160) hover border
var
  Card: TPanel;
  BgColor, BorderColor: TColor;
  IsHovered, IsSelected: Boolean;
  i: Integer;
begin
  Card      := TPanel(Sender);
  IsHovered := Card = FHoveredPresetCard;
  IsSelected := False;
  for i := 0 to 4 do
    if (Card = FPresetLayoutCards[i]) and (i = FActiveLayoutCard) then
    begin IsSelected := True; Break; end;
  if not IsSelected then
    for i := 0 to 3 do
      if (Card = FPresetColorCards[i]) and (i = FActiveColorCard) then
      begin IsSelected := True; Break; end;

  if CurrentTheme = tmLight then
  begin
    if IsSelected      then BgColor := LIGHT_SEL
    else if IsHovered  then BgColor := LIGHT_HOVER
    else                    BgColor := LIGHT_BG;
    if IsSelected      then BorderColor := clHighlight
    else if IsHovered  then BorderColor := LIGHT_H_BRD
    else                    BorderColor := LIGHT_BRD;
  end
  else
  begin
    if IsSelected      then BgColor := DARK_SEL
    else if IsHovered  then BgColor := DARK_HOVER
    else                    BgColor := DARK_BG;
    if IsSelected      then BorderColor := clHighlight
    else if IsHovered  then BorderColor := DARK_H_BRD
    else                    BorderColor := DARK_BRD;
  end;

  // 1. Background fill
  Card.Canvas.Brush.Color := BgColor;
  Card.Canvas.Brush.Style := bsSolid;
  Card.Canvas.FillRect(Card.ClientRect);

  // 2. Selection accent bar — 4 px, inset 2 px from sides, flush with the 1px border.
  //    Drawn on canvas (not a child TPanel) so z-order is never an issue.
  if IsSelected then
  begin
    Card.Canvas.Brush.Color := clHighlight;
    Card.Canvas.Brush.Style := bsSolid;
    Card.Canvas.FillRect(Rect(2, Card.Height - 3, Card.Width - 2, Card.Height - 1));
  end;

  // 3. 1px border rectangle on top of everything
  Card.Canvas.Brush.Style := bsClear;
  Card.Canvas.Pen.Color   := BorderColor;
  Card.Canvas.Pen.Width   := 1;
  Card.Canvas.Rectangle(0, 0, Card.Width, Card.Height);
end;

procedure Tgoverlayform.PresetCardClick(Sender: TObject);
var
  Card: TPanel;
  i: Integer;
begin
  Card := FindPresetCard(Sender);
  if Card = nil then Exit;
  for i := 0 to 4 do
    if Card = FPresetLayoutCards[i] then
    begin
      FActiveLayoutCard := i;
      UpdatePresetCardVisuals;
      case i of
        0: fullBitBtnClick(fullBitBtn);
        1: basicBitBtnClick(basicBitBtn);
        2: basichorizontalBitBtnClick(basichorizontalBitBtn);
        3: fpsonlyBitBtnClick(fpsonlyBitBtn);
        4: usercustomBitBtnClick(usercustomBitBtn);
      end;
      Exit;
    end;
  for i := 0 to 3 do
    if Card = FPresetColorCards[i] then
    begin
      FActiveColorCard := i;
      UpdatePresetCardVisuals;
      case i of
        0: mangocolorBitBtnClick(mangocolorBitBtn);
        1: goverlayBitBtnClick(goverlayBitBtn);
        2: whitecolorBitBtnClick(whitecolorBitBtn);
        3: afterburnercolorBitBtn1Click(afterburnercolorBitBtn1);
      end;
      Exit;
    end;
end;

procedure Tgoverlayform.PresetCardMouseEnter(Sender: TObject);
var
  Card, Prev: TPanel;
begin
  Card := FindPresetCard(Sender);
  if (Card = nil) or (Card = FHoveredPresetCard) then Exit;
  Prev := FHoveredPresetCard;
  FHoveredPresetCard := Card;
  if Assigned(Prev) then Prev.Invalidate;
  Card.Invalidate;
end;

procedure Tgoverlayform.PresetCardMouseLeave(Sender: TObject);
var
  Card: TPanel;
  Pos: TPoint;
begin
  Card := FindPresetCard(Sender);
  if (Card = nil) or (FHoveredPresetCard <> Card) then Exit;
  // Guard: only clear hover when cursor truly leaves the card bounding box.
  // This prevents spurious clears when moving between child controls
  // (TImage → TLabel within the same card).
  Pos := Card.ScreenToClient(Mouse.CursorPos);
  if not PtInRect(Rect(0, 0, Card.Width, Card.Height), Pos) then
  begin
    FHoveredPresetCard := nil;
    Card.Invalidate;
  end;
end;

// NAV RAIL — modern sidebar navigation
// ============================================================================

procedure Tgoverlayform.BuildNavRail;
const
  // Item definitions: (unicode icon, caption, top offset)
  ITEMS: array[0..4] of record Icon, Caption: string; end = (
    (Icon: '󰊴'; Caption: 'Games'),
    (Icon: '󱁥'; Caption: 'MangoHud'),
    (Icon: '󰏘'; Caption: 'vkBasalt'),
    (Icon: '󰋮'; Caption: 'OptiScaler'),
    (Icon: '󰒓'; Caption: 'Proton Tweaks')
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
  FCubeAutoLaunch  := True;  // enabled by default

  // Restore sidebar collapsed state from previous session
  UIStateFile := IncludeTrailingPathDelimiter(TConfigManager.GetGoverlayFolder) + 'ui_state';
  if FileExists(UIStateFile) then
  begin
    SL := TStringList.Create;
    try
      SL.LoadFromFile(UIStateFile);
      if (SL.Count > 0) and (SL[0] = '1') then
        FNavCollapsed := True;
      if (SL.Count > 1) and (SL[1] = '0') then
        FCubeAutoLaunch := False;
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
    IconPath := ExtractFilePath(Application.ExeName) + 'data/icons/128x128/goverlay.png';
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

      IconPath := ExtractFilePath(Application.ExeName) + 'assets/icons/scale-up2.png';
      if FileExists(IconPath) then
        try FOptiScalerImg.Picture.LoadFromFile(IconPath); except end;
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

      IconPath := ExtractFilePath(Application.ExeName) + 'assets/icons/mango-inactive.png';
      if FileExists(IconPath) then
        try FMangoHudImg.Picture.LoadFromFile(IconPath); except end;
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
  FDepsMenuItem.Caption := 'Application status';
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
      PatchGameFGModConditionalExport(GameCfgDir + 'fgmod',
        '[[ "$GOVERLAY_VKBASALT" == "1" ]] && export ENABLE_VKBASALT=1',
        'ENABLE_VKBASALT=1');
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
  FGModFile: string;
  Lines: TStringList;
  i: Integer;
  Flag: string;
begin
  Result := False;  // default: disabled until explicitly saved
  FGModFile := GetGameConfigDir(AGameName) + 'fgmod';
  if not FileExists(FGModFile) then Exit;
  Flag  := FLAGS[AToolIdx] + '=';
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(FGModFile);
    for i := 0 to Lines.Count - 1 do
    begin
      if Pos(Flag, Trim(Lines[i])) = 1 then
      begin
        Result := Trim(Copy(Trim(Lines[i]), Length(Flag) + 1, MaxInt)) <> '0';
        Break;
      end;
    end;
  finally
    Lines.Free;
  end;
end;

procedure Tgoverlayform.SetGameToolEnabled(const AGameName: string; AToolIdx: Integer; AEnabled: Boolean);
const
  FLAGS: array[0..3] of string = ('GOVERLAY_MANGOHUD', 'GOVERLAY_VKBASALT', 'GOVERLAY_OPTISCALER', 'GOVERLAY_TWEAKS');
var
  FGModFile: string;
  Lines: TStringList;
  i: Integer;
  Flag, NewLine: string;
  Found: Boolean;
begin
  FGModFile := GetGameConfigDir(AGameName) + 'fgmod';
  if not FileExists(FGModFile) then Exit;
  Flag    := FLAGS[AToolIdx] + '=';
  NewLine := FLAGS[AToolIdx] + '=' + IfThen(AEnabled, '1', '0');
  Lines   := TStringList.Create;
  Found   := False;
  try
    Lines.LoadFromFile(FGModFile);
    for i := 0 to Lines.Count - 1 do
    begin
      if Pos(Flag, Trim(Lines[i])) = 1 then
      begin
        Lines[i] := NewLine;
        Found := True;
        Break;
      end;
    end;
    if not Found then
    begin
      // Find "=== CONFIG ===" and insert feature flag line after preserve_ini line
      for i := 0 to Lines.Count - 1 do
      begin
        if Pos('# === CONFIG ===', Lines[i]) >= 1 then
        begin
          Lines.Insert(i + 1, NewLine);
          Found := True;
          Break;
        end;
      end;
      if not Found then
        Lines.Insert(0, NewLine);  // fallback
    end;
    Lines.SaveToFile(FGModFile);
  finally
    Lines.Free;
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
    1: SetControlTreeEnabled(vkbasaltTabsheet,    AEnabled);
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
  else if P = vkbasaltTabsheet then
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
  Lines: TStringList;
  i: Integer;
begin
  if not FileExists(AFGModFile) then Exit;
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(AFGModFile);
    for i := Lines.Count - 1 downto 0 do
    begin
      if (Pos('export PROTON_ENABLE_HDR=1',              Lines[i]) > 0) or
         (Pos('export ENABLE_HDR_WSI=1',                 Lines[i]) > 0) or
         (Pos('export PROTON_ENABLE_WAYLAND=1',          Lines[i]) > 0) or
         (Pos('export PROTON_LOG=1',                     Lines[i]) > 0) or
         (Pos('export PROTON_USE_SDL=1',                 Lines[i]) > 0) or
         (Pos('#gamemode',                               Lines[i]) > 0) or
         (Pos('export RADV_PERFTEST=rt,emulate_rt',      Lines[i]) > 0) or
         (Pos('export PROTON_HIDE_NVIDIA_GPU=1',         Lines[i]) > 0) or
         (Pos('export PROTON_ENABLE_NVAPI=1',            Lines[i]) > 0) or
         (Pos('export PROTON_USE_WINED3D=1',             Lines[i]) > 0) or
         (Pos('export MESA_LOADER_DRIVER_OVERRIDE=zink', Lines[i]) > 0) or
         (Pos('export __GLX_VENDOR_LIBRARY_NAME=mesa',   Lines[i]) > 0) or
         (Pos('export RADV_DEBUG=nofastclears',          Lines[i]) > 0) or
         (Pos('export PROTON_PRIORITY_HIGH=1',           Lines[i]) > 0) or
         (Pos('export PROTON_USE_WOW64=1',               Lines[i]) > 0) or
         (Pos('export PROTON_FORCE_LARGE_ADDRESS_AWARE=1', Lines[i]) > 0) or
         (Pos('export STAGING_SHARED_MEMORY=1',          Lines[i]) > 0) or
           (Pos('export PROTON_NO_NTSYNC=1',               Lines[i]) > 0) or
           (Pos('export PROTON_HEAP_DELAY_FREE=1',         Lines[i]) > 0) or
           (Pos('export ENABLE_LAYER_MESA_ANTI_LAG=1',     Lines[i]) > 0) or
           (Pos('export PROTON_FSR4_UPGRADE=1',            Lines[i]) > 0) or
           (Pos('export PROTON_DLSS_UPGRADE=1',            Lines[i]) > 0) or
           (Pos('export PROTON_XESS_UPGRADE=1',            Lines[i]) > 0) or
           (Pos('#customenv',                              Lines[i]) > 0) or
           (Pos('export SteamDeck=1',                     Lines[i]) > 0) then
        Lines.Delete(i);
    end;
    Lines.SaveToFile(AFGModFile);
    fpChmod(AFGModFile, &755);
  finally
    Lines.Free;
  end;
end;

procedure Tgoverlayform.EnsureGameFGModOptiScalerConditional(const AFGModFile: string);
var
  Lines: TStringList;
  i, StartIdx, EndIdx: Integer;
begin
  if not FileExists(AFGModFile) then Exit;
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(AFGModFile);
    // Already has the new conditional — nothing to do
    for i := 0 to Lines.Count - 1 do
      if Pos('GOVERLAY_OPTISCALER" == "1"', Lines[i]) > 0 then
        Exit;
    // Find start of OptiScaler install section
    StartIdx := -1;
    for i := 0 to Lines.Count - 1 do
      if Pos('Cleanup Old Injectors', Lines[i]) > 0 then
      begin
        StartIdx := i;
        Break;
      end;
    // Find end: first "cp -f ... MangoHud.conf" line after start
    EndIdx := -1;
    for i := StartIdx + 1 to Lines.Count - 1 do
      if (Pos('MangoHud.conf', Lines[i]) > 0) and (Pos('cp -f', Lines[i]) > 0) then
      begin
        EndIdx := i;
        Break;
      end;
    if (StartIdx < 0) or (EndIdx <= StartIdx) then Exit;
    // Insert 'fi' + blank line before the MangoHud.conf line
    Lines.Insert(EndIdx, '');
    Lines.Insert(EndIdx, 'fi');
    // Insert the 'if' check + blank line before the start of the OptiScaler section
    Lines.Insert(StartIdx, '');
    Lines.Insert(StartIdx, 'if [[ "$GOVERLAY_OPTISCALER" == "1" ]]; then');
    Lines.SaveToFile(AFGModFile);
    fpChmod(AFGModFile, &755);
  finally
    Lines.Free;
  end;
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
const
  CONDITIONAL_LINE = '[[ "$GOVERLAY_OPTISCALER" == "1" ]] && export WINEDLLOVERRIDES="$WINEDLLOVERRIDES,dxgi=n,b"';
  LEGACY_LINE      = '  export WINEDLLOVERRIDES="$WINEDLLOVERRIDES,dxgi=n,b"';
var
  Lines: TStringList;
  i: Integer;
  Found: Boolean;
begin
  if not FileExists(AFGModFile) then Exit;
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(AFGModFile);
    Found := False;
    for i := 0 to Lines.Count - 1 do
    begin
      // Match both the conditional form (new template) and the legacy unconditional form
      if (Pos('WINEDLLOVERRIDES', Lines[i]) > 0) and
         (Pos('dxgi=n,b', Lines[i]) > 0) then
      begin
        Lines[i] := CONDITIONAL_LINE;
        Found := True;
        Break;
      end;
    end;
    // If no WINEDLLOVERRIDES line found at all, insert before "$@" in the execute block
    if not Found then
    begin
      for i := 0 to Lines.Count - 1 do
      begin
        if Trim(Lines[i]) = '"$@"' then
        begin
          Lines.Insert(i, '  ' + CONDITIONAL_LINE);
          Break;
        end;
      end;
    end;
    Lines.SaveToFile(AFGModFile);
    fpChmod(AFGModFile, &755);
  finally
    Lines.Free;
  end;
end;

// Ensures AConditionalLine is present in AFGModFile, inserting it before "$@"
// in the execute block if absent. ASearchKey is a unique substring of the line
// used to detect whether it already exists. The GOVERLAY_X flag value (written
// by SetGameToolEnabled) already controls whether the line actually runs — this
// function only guarantees the line is there in the first place.
procedure Tgoverlayform.PatchGameFGModConditionalExport(
  const AFGModFile, AConditionalLine, ASearchKey: string);
var
  Lines: TStringList;
  i: Integer;
begin
  if not FileExists(AFGModFile) then Exit;
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(AFGModFile);
    // Already present — nothing to do
    for i := 0 to Lines.Count - 1 do
      if Pos(ASearchKey, Lines[i]) > 0 then
        Exit;
    // Not found: insert before the "$@" call in the execute block
    for i := 0 to Lines.Count - 1 do
      if Trim(Lines[i]) = '"$@"' then
      begin
        Lines.Insert(i, '  ' + AConditionalLine);
        Break;
      end;
    Lines.SaveToFile(AFGModFile);
    fpChmod(AFGModFile, &755);
  finally
    Lines.Free;
  end;
end;

// Adds or updates `export AEnvVar="AConfigPath"` in the game fgmod file.
// Inserts before the "$@" execute line when not yet present; replaces in-place
// when already present (handles path changes after re-saving the config).
procedure Tgoverlayform.PatchGameFGModConfigPath(
  const AFGModFile, AEnvVar, AConfigPath: string);
var
  Lines: TStringList;
  ExportLine: string;
  i: Integer;
begin
  if not FileExists(AFGModFile) then Exit;
  ExportLine := 'export ' + AEnvVar + '="' + AConfigPath + '"';
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(AFGModFile);
    // Update if already present (path may have changed)
    for i := 0 to Lines.Count - 1 do
      if Pos('export ' + AEnvVar + '=', Lines[i]) > 0 then
      begin
        Lines[i] := '  ' + ExportLine;
        Lines.SaveToFile(AFGModFile);
        fpChmod(AFGModFile, &755);
        Exit;
      end;
    // Not found: insert before the "$@" execute call
    for i := 0 to Lines.Count - 1 do
      if Trim(Lines[i]) = '"$@"' then
      begin
        Lines.Insert(i, '  ' + ExportLine);
        Break;
      end;
    Lines.SaveToFile(AFGModFile);
    fpChmod(AFGModFile, &755);
  finally
    Lines.Free;
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
        IconPath := ExtractFilePath(Application.ExeName) + 'assets/icons/scale-up2-active.png';
        if FileExists(IconPath) then
          try FOptiScalerImg.Picture.LoadFromFile(IconPath); except end;
      end;
      if (i = 1) and Assigned(FMangoHudImg) then
      begin
        IconPath := ExtractFilePath(Application.ExeName) + 'assets/icons/mango-active.png';
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
        IconPath := ExtractFilePath(Application.ExeName) + 'assets/icons/scale-up2.png';
        if FileExists(IconPath) then
          try FOptiScalerImg.Picture.LoadFromFile(IconPath); except end;
      end;
      if (i = 1) and Assigned(FMangoHudImg) then
      begin
        IconPath := ExtractFilePath(Application.ExeName) + 'assets/icons/mango-inactive.png';
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
  CARD_BG  = $002E1E1A;  // rgb(26, 30, 46)  — subtly lighter than navy bg
  CARD_BRD = $003E2824;  // rgb(36, 40, 62)  — subtle blue border
  CYAN_H   = 2;          // cyan top accent height (px)
  CYAN_CLR = $00F0BE30;  // rgb(48, 190, 240) — same cyan as active tab indicator
var
  Card: TPanel;
begin
  if not (Sender is TPanel) then Exit;
  Card := TPanel(Sender);

  // Fill background
  Card.Canvas.Brush.Color := CARD_BG;
  Card.Canvas.Brush.Style := bsSolid;
  Card.Canvas.FillRect(Card.ClientRect);

  // Border (all four sides)
  Card.Canvas.Brush.Style := bsClear;
  Card.Canvas.Pen.Color   := CARD_BRD;
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
// Used for nested panels inside cards (Visual sections, GroupBox replacements).
const
  BG  = $002E1E1A;  // rgb(26, 30, 46)
  BRD = $00342620;  // rgb(32, 38, 52) — barely visible divider
var
  P: TPanel;
begin
  if not (Sender is TPanel) then Exit;
  P := TPanel(Sender);
  P.Canvas.Brush.Color := BG;
  P.Canvas.Brush.Style := bsSolid;
  P.Canvas.FillRect(P.ClientRect);
  P.Canvas.Brush.Style := bsClear;
  P.Canvas.Pen.Color   := BRD;
  P.Canvas.Pen.Width   := 1;
  P.Canvas.Rectangle(0, 0, P.Width, P.Height);
end;

procedure Tgoverlayform.UpdateVisualCardTheme;
const
  DARK_BG   = $00362E2E;
  LIGHT_BG  = $00FFFFFF;
var
  i: Integer;
  CardBg, GbBg, TextColor: TColor;
  Card: TPanel;
  j: Integer;
begin
  if not Assigned(FVisualCards[0]) then Exit;

  if CurrentTheme = tmLight then
  begin
    CardBg    := LIGHT_BG;
    GbBg      := LIGHT_BG;
    TextColor := LightTextColor;
  end
  else
  begin
    CardBg    := DARK_BG;
    GbBg      := DARK_BG;
    TextColor := DarkTextColor;
  end;

  for i := 0 to 5 do
  begin
    Card := FVisualCards[i];
    if not Assigned(Card) then Continue;
    Card.Color := CardBg;
    Card.Invalidate;
    for j := 0 to Card.ControlCount - 1 do
    begin
      if Card.Controls[j] is TLabel then
      begin
        TLabel(Card.Controls[j]).Font.Color := TextColor;
        TLabel(Card.Controls[j]).Transparent := True;
      end;
    end;
  end;

  // Invalidate inner section panels (section title labels keep their muted color)
  for i := 0 to 5 do
  begin
    if Assigned(FVisualSections[i]) then
    begin
      FVisualSections[i].Color := CardBg;
      FVisualSections[i].Invalidate;
    end;
  end;

  // Update GPU info bar
  if Assigned(FVisualGpuBar) then
  begin
    FVisualGpuBar.Color := CardBg;
    FVisualGpuBar.Invalidate;
    for j := 0 to FVisualGpuBar.ControlCount - 1 do
    begin
      if FVisualGpuBar.Controls[j] is TLabel then
      begin
        TLabel(FVisualGpuBar.Controls[j]).Font.Color := TextColor;
        TLabel(FVisualGpuBar.Controls[j]).Color      := CardBg;
      end;
    end;
    gpudescEdit.Color       := CardBg;
    gpudescEdit.Font.Color  := TextColor;
    hudtitleEdit.Color      := CardBg;
    hudtitleEdit.Font.Color := TextColor;
  end;

  // Update HUD settings bar
  if Assigned(FVisualHudBar) then
  begin
    FVisualHudBar.Color := CardBg;
    FVisualHudBar.Invalidate;
    hudtoggleLabel.Font.Color    := TextColor;
    hudcompactCheckBox.Color     := CardBg;
    hudcompactCheckBox.Font.Color := TextColor;
    hidehudCheckBox.Color        := CardBg;
    hidehudCheckBox.Font.Color   := TextColor;
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
  if ssShift in Shift then ModStr := ModStr + 'Shift_L+';
  if ssCtrl  in Shift then ModStr := ModStr + 'Control_L+';
  if ssAlt   in Shift then ModStr := ModStr + 'Alt_L+';
  if ssSuper in Shift then ModStr := ModStr + 'Super_L+';

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
    else if FCaptureBtn.Tag = 4 then vkbtogglekeyCombobox.Text := FinalStr;
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
const
  ACCENT_H = 3;
  TITLE_T  = 6;
  TITLE_H  = 22;
  HDR      = ACCENT_H + TITLE_T + TITLE_H + 3;  // = 34, content starts here

  CARD_TITLES: array[0..0] of string = ('Visual Settings');

  procedure MakeCard(AIndex: Integer; ATitle: string);
  var
    Card: TPanel;
    Bar: TPanel;
    Lbl: TLabel;
    IsLight: Boolean;
    BgColor, TextColor: TColor;
  begin
    IsLight   := CurrentTheme = tmLight;
    BgColor   := IfThen(IsLight, clWhite, RGBToColor(26, 30, 46));
    TextColor := IfThen(IsLight, LightTextColor, DarkTextColor);

    Card := TPanel.Create(Self);
    Card.Parent      := visualTabSheet;
    Card.BevelOuter  := bvNone;
    Card.BorderStyle := bsNone;
    Card.Caption     := '';
    Card.Color       := BgColor;
    Card.ParentColor := False;
    Card.OnPaint     := @PerfCardPaint;
    FVisualCards[AIndex] := Card;

    Bar := TPanel.Create(Card);
    Bar.Parent      := Card;
    Bar.BevelOuter  := bvNone;
    Bar.Caption     := '';
    Bar.Color       := RGBToColor(48, 190, 240);
    Bar.SetBounds(0, 0, Card.Width, ACCENT_H);
    Bar.Anchors     := [akLeft, akRight, akTop];

    Lbl := TLabel.Create(Card);
    Lbl.Parent       := Card;
    Lbl.Caption      := ATitle;
    Lbl.Font.Style   := [fsBold];
    Lbl.Font.Size    := 9;
    Lbl.Font.Color   := TextColor;
    Lbl.Transparent  := True;
    Lbl.AutoSize     := True;
    Lbl.Left         := 10;
    Lbl.Top          := TITLE_T + ACCENT_H;
  end;

  // Reparent a control directly onto a card, clearing all anchor dependencies.
  procedure Place(C: TControl; Card: TPanel; ALeft, ATop: Integer);
  begin
    C.AnchorSideLeft.Control   := nil;
    C.AnchorSideTop.Control    := nil;
    C.AnchorSideRight.Control  := nil;
    C.AnchorSideBottom.Control := nil;
    C.Anchors := [akLeft, akTop];
    C.Parent  := Card;
    C.Left    := ALeft;
    C.Top     := ATop;
  end;

  procedure MakeSection(AIndex: Integer; ATitle: string);
  var
    Sec: TPanel;
    Lbl: TLabel;
  begin
    Sec := TPanel.Create(FVisualCards[0]);
    Sec.Parent      := FVisualCards[0];
    Sec.BevelOuter  := bvNone;
    Sec.BorderStyle := bsNone;
    Sec.Caption     := '';
    Sec.Color       := IfThen(CurrentTheme = tmLight, $00FFFFFF, RGBToColor(26, 30, 46));
    Sec.ParentColor := False;
    Sec.OnPaint     := @SubCardPaint;
    FVisualSections[AIndex] := Sec;
    Lbl := TLabel.Create(Sec);
    Lbl.Parent     := Sec;
    Lbl.Caption    := ATitle;
    Lbl.Font.Color := $00AAAACC;
    Lbl.Font.Style := [fsBold];
    Lbl.Font.Size  := 8;
    Lbl.Transparent := True;
    Lbl.AutoSize    := True;
    Lbl.Left := 6;
    Lbl.Top  := 4;
  end;

var
  i: Integer;
  IsLight: Boolean;
  BarBg, TextColor: TColor;
  Lbl: TLabel;
  SS: WideString;
var
  BgBox: TPaintBox;
begin
  BgBox := TPaintBox.Create(Self);
  BgBox.Parent  := visualTabSheet;
  BgBox.Align   := alClient;
  BgBox.OnPaint := @PresetsBgBoxPaint;

  MakeCard(0, CARD_TITLES[0]);
  FVisualCards[1] := nil; FVisualCards[2] := nil;
  FVisualCards[3] := nil; FVisualCards[4] := nil; FVisualCards[5] := nil;

  IsLight   := CurrentTheme = tmLight;
  BarBg     := IfThen(IsLight, $00F2F2F2, $00362E2E);
  TextColor := IfThen(IsLight, LightTextColor, DarkTextColor);

  // Hide the LFM GroupBoxes — controls reparented directly to section panels.
  orientationGroupBox.Visible := False;
  borderGroupBox.Visible      := False;
  backgroundGroupBox.Visible  := False;
  fontsGroupBox.Visible       := False;
  positionGroupBox.Visible    := False;
  columsGroupBox.Visible      := False;

  // ── Single card — Visual Settings with 6 inner section panels ───────────
  // Row 1: [0]Orientation | [1]Borders | [2]Background
  // Row 2: [3]Fonts       | [4]Position | [5]Columns
  // Section bounds are set by ReflowVisualTab; controls use relative coords.
  MakeSection(0, 'Orientation');
  MakeSection(1, 'Borders');
  MakeSection(2, 'Background');
  MakeSection(3, 'Fonts');
  MakeSection(4, 'Position');
  MakeSection(5, 'Columns');

  // ·· [0] Orientation — positions set by Reflow ···························
  Place(verticalRadioButton,   FVisualSections[0], 6,  50);
  Place(vImage,                FVisualSections[0], 30, 28);
  Place(horizontalRadioButton, FVisualSections[0], 6,  50);
  Place(hImage,                FVisualSections[0], 30, 40);
  verticalRadioButton.Color   := $002E1E1A; verticalRadioButton.ParentColor   := False;
  horizontalRadioButton.Color := $002E1E1A; horizontalRadioButton.ParentColor := False;
  vImage.Transparent := True; hImage.Transparent := True;
  vImage.Width := 30;  vImage.Height := 56;   // portrait — Reflow positions these
  hImage.Width := 56;  hImage.Height := 30;   // landscape
  SS := 'QRadioButton { background-color: rgb(26,30,46); }';
  QWidget_setStyleSheet(TQtWidget(FVisualSections[0].Handle).Widget, @SS);

  // ·· [1] Borders — positions set by Reflow ································
  Place(squareRadioButton, FVisualSections[1], 6,  50);
  Place(squareImage,       FVisualSections[1], 30, 30);
  Place(roundRadioButton,  FVisualSections[1], 6,  50);
  Place(roundImage,        FVisualSections[1], 30, 30);
  squareRadioButton.Color := $002E1E1A; squareRadioButton.ParentColor := False;
  roundRadioButton.Color  := $002E1E1A; roundRadioButton.ParentColor  := False;
  squareImage.Transparent := True; roundImage.Transparent := True;
  squareImage.Width := 48; squareImage.Height := 42;
  roundImage.Width  := 48; roundImage.Height  := 42;
  SS := 'QRadioButton { background-color: rgb(26,30,46); }';
  QWidget_setStyleSheet(TQtWidget(FVisualSections[1].Handle).Widget, @SS);

  // ·· [2] Background ·······················································
  Place(backgroundLabel,          FVisualSections[2], 6,  32);
  Place(hudbackgroundColorButton, FVisualSections[2], 52, 28);
  Place(transparencyLabel,        FVisualSections[2], 6,  72);
  Place(transpTrackBar,           FVisualSections[2], 52, 70);
  Place(alphavalueLabel,          FVisualSections[2], 52, 92);
  backgroundLabel.Font.Color   := TextColor; backgroundLabel.Transparent   := True;
  transparencyLabel.Font.Color := TextColor; transparencyLabel.Transparent := True;
  alphavalueLabel.Font.Color   := TextColor; alphavalueLabel.Transparent   := True;
  hudbackgroundColorButton.Color := BarBg;
  transpTrackBar.Color := BarBg; transpTrackBar.ParentColor := False;

  // ·· [3] Fonts ····························································
  Place(fontComboBox,       FVisualSections[3], 6,  22);
  Place(fontcolorLabel,     FVisualSections[3], 6,  84);
  Place(FontcolorButton,    FVisualSections[3], 52, 82);
  Place(fontLabel,          FVisualSections[3], 6,  142);
  Place(fontsizeTrackBar,   FVisualSections[3], 40, 140);
  Place(fontsizevalueLabel, FVisualSections[3], 40, 164);
  fontcolorLabel.Font.Color     := TextColor; fontcolorLabel.Transparent     := True;
  fontLabel.Font.Color          := TextColor; fontLabel.Transparent          := True;
  fontsizevalueLabel.Font.Color := TextColor; fontsizevalueLabel.Transparent := True;
  FontcolorButton.Color  := BarBg;
  fontsizeTrackBar.Color := BarBg; fontsizeTrackBar.ParentColor := False;

  // ·· [4] Position ·························································
  Image1.Stretch      := True;
  Image1.Proportional := False;
  Image1.AnchorSideLeft.Control   := nil; Image1.AnchorSideTop.Control    := nil;
  Image1.AnchorSideRight.Control  := nil; Image1.AnchorSideBottom.Control := nil;
  Image1.Anchors := [akLeft, akTop];
  Image1.BorderSpacing.Left   := 0; Image1.BorderSpacing.Right  := 0;
  Image1.BorderSpacing.Top    := 0; Image1.BorderSpacing.Bottom := 0;
  Image1.Parent := FVisualSections[4];
  Image1.SetBounds(4, 22, 100, 80);  // Reflow sets actual size
  Place(topleftRadioButton,      FVisualSections[4], 10, 30);
  Place(topcenterRadioButton,    FVisualSections[4], 50, 30);
  Place(toprightRadioButton,     FVisualSections[4], 90, 30);
  Place(middleleftRadioButton,   FVisualSections[4], 10, 80);
  Place(middlerightRadioButton,  FVisualSections[4], 90, 80);
  Place(bottomleftRadioButton,   FVisualSections[4], 10, 130);
  Place(bottomcenterRadioButton, FVisualSections[4], 50, 130);
  Place(bottomrightRadioButton,  FVisualSections[4], 90, 130);
  // SpinEdits use the monitor-screen blue so they blend into the position image
  offsetxSpinEdit.Parent := FVisualSections[4];
  offsetxSpinEdit.AnchorSideLeft.Control := nil; offsetxSpinEdit.AnchorSideTop.Control := nil;
  offsetxSpinEdit.Anchors     := [akLeft, akTop];
  offsetxSpinEdit.Color       := $00D9904A;   // monitor-screen blue (BGR)
  offsetxSpinEdit.Font.Color  := clWhite;
  offsetxSpinEdit.ParentColor := False;
  offsetxSpinEdit.Left := 10; offsetxSpinEdit.Top := 60;
  offsetySpinEdit.Parent := FVisualSections[4];
  offsetySpinEdit.AnchorSideLeft.Control := nil; offsetySpinEdit.AnchorSideTop.Control := nil;
  offsetySpinEdit.Anchors     := [akLeft, akTop];
  offsetySpinEdit.Color       := $00D9904A;
  offsetySpinEdit.Font.Color  := clWhite;
  offsetySpinEdit.ParentColor := False;
  offsetySpinEdit.Left := 10; offsetySpinEdit.Top := 90;

  // ·· [5] Columns ··························································
  Place(columShape,      FVisualSections[5], 10, 50);
  Place(columShape1,     FVisualSections[5], 37, 50);
  Place(columShape2,     FVisualSections[5], 64, 50);
  Place(columShape3,     FVisualSections[5], 91, 50);
  Place(columShape4,     FVisualSections[5], 118, 50);
  Place(columShape5,     FVisualSections[5], 145, 50);
  Place(minusButton,     FVisualSections[5], 64,  162);
  Place(plusSpeedButton, FVisualSections[5], 91,  162);
  Place(columvalueLabel, FVisualSections[5], 124, 164);
  columvalueLabel.Font.Color := TextColor; columvalueLabel.Transparent := True;
  columShape.Height  := 100; columShape1.Height := 100; columShape2.Height := 100;
  columShape3.Height := 100; columShape4.Height := 100; columShape5.Height := 100;

  // ── GPU info bar ─────────────────────────────────────────────────────────
  IsLight   := CurrentTheme = tmLight;
  BarBg     := IfThen(IsLight, $00F2F2F2, RGBToColor(26, 30, 46));
  TextColor := IfThen(IsLight, LightTextColor, DarkTextColor);

  FVisualGpuBar := TPanel.Create(Self);
  FVisualGpuBar.Parent      := visualTabSheet;
  FVisualGpuBar.BevelOuter  := bvNone;
  FVisualGpuBar.BorderStyle := bsNone;
  FVisualGpuBar.Caption     := '';
  FVisualGpuBar.Color       := BarBg;
  FVisualGpuBar.ParentColor := False;
  FVisualGpuBar.OnPaint     := @SubCardPaint;

  // "Active GPU" section label
  Lbl := TLabel.Create(FVisualGpuBar);
  Lbl.Parent      := FVisualGpuBar;
  Lbl.Caption     := 'Active GPU';
  Lbl.Font.Style  := [fsBold];
  Lbl.Font.Size   := 9;
  Lbl.Font.Color  := TextColor;
  Lbl.Color       := BarBg;
  Lbl.Transparent := False;
  Lbl.AutoSize    := True;
  Lbl.Left        := 11;
  Lbl.Top         := 6;

  activegpuLabel.Visible := False;

  pcidevComboBox.Parent := FVisualGpuBar;
  pcidevComboBox.AnchorSideLeft.Control  := nil;
  pcidevComboBox.AnchorSideTop.Control   := nil;
  pcidevComboBox.AnchorSideRight.Control := nil;
  pcidevComboBox.Anchors := [akLeft, akTop];
  pcidevComboBox.Left    := 11;
  pcidevComboBox.Top     := 26;

  gpudescEdit.Parent := FVisualGpuBar;
  gpudescEdit.AnchorSideLeft.Control  := nil;
  gpudescEdit.AnchorSideTop.Control   := nil;
  gpudescEdit.AnchorSideRight.Control := nil;
  gpudescEdit.Anchors     := [akLeft, akTop, akRight];
  gpudescEdit.Left        := pcidevComboBox.Left + pcidevComboBox.Width + 4;
  gpudescEdit.Top         := pcidevComboBox.Top + (pcidevComboBox.Height - gpudescEdit.Height) div 2;
  gpudescEdit.Color       := BarBg;
  gpudescEdit.Font.Color  := TextColor;
  gpudescEdit.BorderStyle := bsNone;
  SS := 'background-color: rgb(26,30,46); border: none; color: white;';
  QWidget_setStyleSheet(TQtWidget(gpudescEdit.Handle).Widget, @SS);

  // ── HUD Title field — option C: style in place ───────────────────────────
  hudtitleEdit.Color       := BarBg;
  hudtitleEdit.Font.Color  := TextColor;
  hudtitleEdit.BorderStyle := bsSingle;

  // ── HUD settings — integrated into Visual Settings card ──────────────────
  // Horizontal separator between section panels and HUD row (width set in Reflow)
  FVisualHudSep := TPanel.Create(FVisualCards[0]);
  FVisualHudSep.Parent      := FVisualCards[0];
  FVisualHudSep.BevelOuter  := bvNone;
  FVisualHudSep.Caption     := '';
  FVisualHudSep.Color       := $005A5050;
  FVisualHudSep.SetBounds(8, 382, 800, 1);
  FVisualHudSep.Anchors := [akLeft, akTop, akRight];

  FVisualHudBar := TPanel.Create(FVisualCards[0]);
  FVisualHudBar.Parent      := FVisualCards[0];  // child of main card, not tabsheet
  FVisualHudBar.BevelOuter  := bvNone;
  FVisualHudBar.BorderStyle := bsNone;
  FVisualHudBar.Caption     := '';
  FVisualHudBar.Color       := BarBg;
  FVisualHudBar.ParentColor := False;
  FVisualHudBar.OnPaint     := @SubCardPaint;

  // Reparent HUD toggle label
  hudtoggleLabel.Parent := FVisualHudBar;
  hudtoggleLabel.AnchorSideLeft.Control   := nil;
  hudtoggleLabel.AnchorSideTop.Control    := nil;
  hudtoggleLabel.AnchorSideRight.Control  := nil;
  hudtoggleLabel.AnchorSideBottom.Control := nil;
  hudtoggleLabel.Anchors    := [akLeft, akTop];
  hudtoggleLabel.Font.Color := TextColor;
  hudtoggleLabel.Left := 11;
  hudtoggleLabel.Top  := 6;

  // Hide the keyboard icon — Capture button takes its place
  hudtoggleImage.Parent := FVisualHudBar;
  hudtoggleImage.AnchorSideLeft.Control   := nil;
  hudtoggleImage.AnchorSideTop.Control    := nil;
  hudtoggleImage.AnchorSideRight.Control  := nil;
  hudtoggleImage.AnchorSideBottom.Control := nil;
  hudtoggleImage.Visible := False;

  // Hide the original combobox — now replaced by a styled TEdit
  hudonoffComboBox.Visible := False;

  // Capture button — shows "⌨ Capture" or "⌨ <shortcut>" after capture
  FVisualCaptureBtn := TBitBtn.Create(FVisualHudBar);
  FVisualCaptureBtn.Parent  := FVisualHudBar;
  FVisualCaptureBtn.Tag     := 1; // Visual Tab
  FVisualCaptureBtn.SetBounds(11, 24, 160, 28);
  FVisualCaptureBtn.OnClick := @CaptureBtnClick;
  FVisualCaptureBtn.Cursor  := crHandPoint;
  if Trim(hudonoffComboBox.Text) <> '' then
    FVisualCaptureBtn.Caption := '⌨ ' + hudonoffComboBox.Text
  else
    FVisualCaptureBtn.Caption := '⌨ Capture';

  // Reparent Compact HUD checkbox (Left set in Reflow)
  hudcompactCheckBox.Parent := FVisualHudBar;
  hudcompactCheckBox.AnchorSideLeft.Control   := nil;
  hudcompactCheckBox.AnchorSideTop.Control    := nil;
  hudcompactCheckBox.AnchorSideRight.Control  := nil;
  hudcompactCheckBox.AnchorSideBottom.Control := nil;
  hudcompactCheckBox.Anchors     := [akLeft, akTop];
  hudcompactCheckBox.Font.Color  := TextColor;
  hudcompactCheckBox.Color       := $002E1E1A;
  hudcompactCheckBox.ParentColor := False;
  hudcompactCheckBox.Top := 17;

  // Reparent Hide by default checkbox (Left set in Reflow)
  hidehudCheckBox.Parent := FVisualHudBar;
  hidehudCheckBox.AnchorSideLeft.Control   := nil;
  hidehudCheckBox.AnchorSideTop.Control    := nil;
  hidehudCheckBox.AnchorSideRight.Control  := nil;
  hidehudCheckBox.AnchorSideBottom.Control := nil;
  hidehudCheckBox.Anchors     := [akLeft, akTop];
  hidehudCheckBox.Font.Color  := TextColor;
  hidehudCheckBox.Color       := $002E1E1A;
  hidehudCheckBox.ParentColor := False;
  hidehudCheckBox.Top := 17;

  SS := 'QCheckBox { background-color: rgb(26,30,46); }';
  QWidget_setStyleSheet(TQtWidget(FVisualHudBar.Handle).Widget, @SS);

end;

procedure Tgoverlayform.ReflowVisualTab(AContentW: Integer);
const
  MARGIN   = 4;
  GPU_TOP  = 52;
  GPU_H    = 67;
  CARD_TOP = GPU_TOP + GPU_H + 10;  // = 129
  HUD_H    = 56;
  HDR      = 34;
  R1_TOP   = HDR + 4;
  R1_H     = 118;
  R2_TOP   = HDR + 130;
  R2H      = 216;
  HUD_SEP  = R2_TOP + R2H + 4;
  HUD_TOP  = HUD_SEP + 6;
  CARD_H   = HUD_TOP + HUD_H + 4;
var
  W, S1, S2, SW: Integer;
  SecW1, SecW2, SecW3: Integer;
  RW, RH, CL, CC, CR, RT, RM, RB: Integer;
  ImgW, ImgH: Integer;
  HalfW, GrpW, GrpX, CY: Integer;
begin
  if not Assigned(FVisualCards[0]) then Exit;

  W  := AContentW - 2 * MARGIN;
  S1 := W div 3;
  S2 := (W * 2) div 3;
  SW := W - S2;
  SecW1 := S1 - 8;
  SecW2 := S2 - S1 - 8;
  SecW3 := W - S2 - 8;

  // GPU info bar — separate card above Visual Settings
  if Assigned(FVisualGpuBar) then
  begin
    FVisualGpuBar.SetBounds(MARGIN, GPU_TOP, W, GPU_H);
    gpudescEdit.Width := FVisualGpuBar.ClientWidth - gpudescEdit.Left - 5;
  end;

  // Visual Settings card — full width
  FVisualCards[0].SetBounds(MARGIN, CARD_TOP, W, CARD_H);

  // ── Row 1 section panels ──────────────────────────────────────────────────
  if Assigned(FVisualSections[0]) then
    FVisualSections[0].SetBounds(4,      R1_TOP, SecW1, R1_H);
  if Assigned(FVisualSections[1]) then
    FVisualSections[1].SetBounds(S1 + 4, R1_TOP, SecW2, R1_H);
  if Assigned(FVisualSections[2]) then
    FVisualSections[2].SetBounds(S2 + 4, R1_TOP, SecW3, R1_H);

  // ── Orientation section: 2 pairs (RB + image) centered in each half ──────
  CY    := 22 + (R1_H - 22) div 2;  // vertical center of content area = 70
  HalfW := SecW1 div 2;
  // Left half: verticalRB (20×20) + vImage (30×56)
  GrpW := 20 + 6 + 30;
  GrpX := HalfW div 2 - GrpW div 2;
  if GrpX < 4 then GrpX := 4;
  verticalRadioButton.Left := GrpX;
  verticalRadioButton.Top  := CY - 10;
  vImage.Left := GrpX + 26;
  vImage.Top  := CY - 28;
  // Right half: horizontalRB (20×20) + hImage (56×30)
  GrpW := 20 + 6 + 56;
  GrpX := HalfW + HalfW div 2 - GrpW div 2;
  if GrpX + GrpW > SecW1 - 4 then GrpX := SecW1 - 4 - GrpW;
  horizontalRadioButton.Left := GrpX;
  horizontalRadioButton.Top  := CY - 10;
  hImage.Left := GrpX + 26;
  hImage.Top  := CY - 15;

  // ── Borders section: 2 pairs (RB + image) centered in each half ───────────
  HalfW := SecW2 div 2;
  // Left half: squareRB (20×20) + squareImage (48×42)
  GrpW := 20 + 6 + 48;
  GrpX := HalfW div 2 - GrpW div 2;
  if GrpX < 4 then GrpX := 4;
  squareRadioButton.Left := GrpX;
  squareRadioButton.Top  := CY - 10;
  squareImage.Left := GrpX + 26;
  squareImage.Top  := CY - 21;
  // Right half: roundRB + roundImage (48×42)
  GrpX := HalfW + HalfW div 2 - GrpW div 2;
  if GrpX + GrpW > SecW2 - 4 then GrpX := SecW2 - 4 - GrpW;
  roundRadioButton.Left := GrpX;
  roundRadioButton.Top  := CY - 10;
  roundImage.Left := GrpX + 26;
  roundImage.Top  := CY - 21;

  // Background section: transpTrackBar stretches to fill panel
  transpTrackBar.Width := SecW3 - 60;
  alphavalueLabel.Left := 52 + (transpTrackBar.Width div 2) - 8;

  // ── Row 2 section panels ──────────────────────────────────────────────────
  if Assigned(FVisualSections[3]) then
    FVisualSections[3].SetBounds(4,      R2_TOP, SecW1, R2H);
  if Assigned(FVisualSections[4]) then
    FVisualSections[4].SetBounds(S1 + 4, R2_TOP, SecW2, R2H);
  if Assigned(FVisualSections[5]) then
    FVisualSections[5].SetBounds(S2 + 4, R2_TOP, SecW3, R2H);

  // Fonts section: elastic widths (controls are relative to section panel)
  fontComboBox.Width     := SecW1 - 12;
  fontsizeTrackBar.Width := SecW1 - 46;
  fontsizevalueLabel.Left := (SecW1 div 2) - 5;

  // Position section: Image fills panel, radio buttons proportional within it
  ImgW := SecW2 - 8;
  ImgH := R2H - 26;
  Image1.SetBounds(4, 22, ImgW, ImgH);
  RW  := topleftRadioButton.Width;
  RH  := topleftRadioButton.Height;
  CL  := 4 + Round(ImgW * 0.094) - RW div 2;
  CC  := 4 + (ImgW div 2) - RW div 2;
  CR  := 4 + Round(ImgW * 0.906) - RW div 2;
  RT  := 22 + Round(ImgH * 0.131) - RH div 2;
  RB  := 22 + Round(ImgH * 0.620) - RH div 2;
  RM  := (RT + RB) div 2;
  topleftRadioButton.SetBounds(CL, RT, RW, RH);
  topcenterRadioButton.SetBounds(CC, RT, RW, RH);
  toprightRadioButton.SetBounds(CR, RT, RW, RH);
  middleleftRadioButton.SetBounds(CL, RM, RW, RH);
  middlerightRadioButton.SetBounds(CR, RM, RW, RH);
  bottomleftRadioButton.SetBounds(CL, RB, RW, RH);
  bottomcenterRadioButton.SetBounds(CC, RB, RW, RH);
  bottomrightRadioButton.SetBounds(CR, RB, RW, RH);
  // offsetxSpinEdit: right of middleleftRadioButton
  offsetxSpinEdit.Left := CL + RW + 4;
  offsetxSpinEdit.Top  := RM + (RH - offsetxSpinEdit.Height) div 2;
  // offsetySpinEdit: below topcenterRadioButton
  offsetySpinEdit.Left := CC + (RW - offsetySpinEdit.Width) div 2;
  offsetySpinEdit.Top  := RT + RH + 4;

  // Columns section: center 6 shapes (each 24px, 3px gap = 159px total) in panel
  CL := (SecW3 - 159) div 2;
  if CL < 6 then CL := 6;
  columShape.Left  := CL;       columShape1.Left := CL + 27;
  columShape2.Left := CL + 54;  columShape3.Left := CL + 81;
  columShape4.Left := CL + 108; columShape5.Left := CL + 135;
  minusButton.Left     := CL + 54;
  plusSpeedButton.Left := CL + 81;
  columvalueLabel.Left := CL + 110;

  // HUD separator and bar — integrated at the bottom of the main card
  if Assigned(FVisualHudSep) then
    FVisualHudSep.SetBounds(8, HUD_SEP, W - 16, 1);
  if Assigned(FVisualHudBar) then
  begin
    FVisualHudBar.SetBounds(0, HUD_TOP, W, HUD_H);
    hudcompactCheckBox.Left := (W - hudcompactCheckBox.Width) div 2;
    hidehudCheckBox.Left    := W - hidehudCheckBox.Width - 16;
  end;
end;

// ============================================================================
// FPS LIMIT CHIPS — visual tag-style chip grid
// ============================================================================

procedure Tgoverlayform.BuildFpsLimitEdit;
var
  IsLight: Boolean;
  Bg, TextColor, EditBg: TColor;
  Lbl: TLabel;
  ContL, ContT, ContW, ContH: Integer;
begin
  IsLight   := CurrentTheme = tmLight;
  Bg        := IfThen(IsLight, clWhite, RGBToColor(26, 30, 46));
  TextColor := IfThen(IsLight, LightTextColor, DarkTextColor);
  EditBg    := IfThen(IsLight, $00F5F5F5, $002E2E2E);

  // ── Free anchors that pointed to fpslimCheckGroup ─────────────────────────
  fpscolorCheckBox.AnchorSideLeft.Control   := nil;
  fpscolorCheckBox.AnchorSideTop.Control    := nil;
  fpscolorCheckBox.AnchorSideBottom.Control := nil;
  fpscolorCheckBox.Anchors := [akLeft, akTop];

  fpscolor1ColorButton.AnchorSideLeft.Control   := nil;
  fpscolor1ColorButton.AnchorSideTop.Control    := nil;
  fpscolor1ColorButton.AnchorSideBottom.Control := nil;
  fpscolor1ColorButton.Anchors := [akLeft, akTop];

  fpscolor2ColorButton.AnchorSideLeft.Control   := nil;
  fpscolor2ColorButton.AnchorSideTop.Control    := nil;
  fpscolor2ColorButton.AnchorSideBottom.Control := nil;
  fpscolor2ColorButton.Anchors := [akLeft, akTop];

  fpscolor3ColorButton.AnchorSideLeft.Control   := nil;
  fpscolor3ColorButton.AnchorSideRight.Control  := nil;
  fpscolor3ColorButton.AnchorSideTop.Control    := nil;
  fpscolor3ColorButton.AnchorSideBottom.Control := nil;
  fpscolor3ColorButton.Anchors := [akLeft, akTop];

  fpscolor2SpinEdit.AnchorSideLeft.Control   := nil;
  fpscolor2SpinEdit.AnchorSideTop.Control    := nil;
  fpscolor2SpinEdit.AnchorSideBottom.Control := nil;
  fpscolor2SpinEdit.Anchors := [akLeft, akTop];

  fpscolor3SpinEdit.AnchorSideLeft.Control   := nil;
  fpscolor3SpinEdit.AnchorSideTop.Control    := nil;
  fpscolor3SpinEdit.AnchorSideRight.Control  := nil;
  fpscolor3SpinEdit.AnchorSideBottom.Control := nil;
  fpscolor3SpinEdit.Anchors := [akLeft, akTop];

  methodLabel.AnchorSideLeft.Control   := nil;
  methodLabel.AnchorSideTop.Control    := nil;
  methodLabel.AnchorSideBottom.Control := nil;
  methodLabel.Anchors := [akLeft, akTop];

  fpslimmetComboBox.AnchorSideLeft.Control   := nil;
  fpslimmetComboBox.AnchorSideTop.Control    := nil;
  fpslimmetComboBox.AnchorSideBottom.Control := nil;
  fpslimmetComboBox.Anchors := [akLeft, akTop];

  limtoggleLabel.AnchorSideLeft.Control   := nil;
  limtoggleLabel.AnchorSideTop.Control    := nil;
  limtoggleLabel.AnchorSideRight.Control  := nil;
  limtoggleLabel.AnchorSideBottom.Control := nil;
  limtoggleLabel.Anchors := [akLeft, akTop];

  // Hide legacy controls
  fpslimCheckGroup.Visible := False;
  offsetSpinEdit.Visible   := False;
  offsetLabel.Visible      := False;
  fpslimLabel.Visible      := False;

  // Container rect based on where fpslimCheckGroup was
  ContL := fpslimCheckGroup.Left;
  ContT := fpslimCheckGroup.Top;
  ContW := fpslimCheckGroup.Width;
  ContH := fpslimiterGroupBox.Height - ContT;  // usable height to bottom of groupbox

  // Title label with lightning icon
  Lbl := TLabel.Create(Self);
  Lbl.Parent := fpslimiterGroupBox;
  Lbl.Caption := '⚡ FPS Limit';
  Lbl.Font.Name := 'Noto Sans';
  Lbl.Font.Color := TextColor;
  Lbl.Font.Style := [fsBold];
  Lbl.Font.Size := 9;
  Lbl.Transparent := True;
  Lbl.SetBounds(ContL + 6, ContT - 18, 140, 20);
  Lbl.Anchors := [akLeft, akTop];

  // Create the edit — very large font for readability
  FFpsLimitEdit := TEdit.Create(Self);
  FFpsLimitEdit.Parent := fpslimiterGroupBox;
  FFpsLimitEdit.SetBounds(ContL + 6, ContT + 8, ContW - 12, 44);
  FFpsLimitEdit.Anchors := [akLeft, akTop, akRight];
  FFpsLimitEdit.Font.Name := 'DejaVu Sans Mono';
  FFpsLimitEdit.Font.Size := 24;
  FFpsLimitEdit.Font.Color := TextColor;
  FFpsLimitEdit.Color := EditBg;
  FFpsLimitEdit.BorderStyle := bsNone;
  FFpsLimitEdit.Text := '0';

  // Small hint label below the edit
  Lbl := TLabel.Create(Self);
  Lbl.Parent := fpslimiterGroupBox;
  Lbl.Caption := 'e.g. 30,60,120,0 — 0 to unlimited';
  Lbl.Font.Name := 'Noto Sans';
  Lbl.Font.Color := IfThen(IsLight, $00999999, $00666666);
  Lbl.Font.Size := 7;
  Lbl.Transparent := True;
  Lbl.SetBounds(ContL + 6, ContT + 54, ContW - 12, 14);
  Lbl.Anchors := [akLeft, akTop];

  // ── Spread controls vertically: edit top, colours middle, method bottom ───
  fpscolorCheckBox.SetBounds(ContL + (ContW - 150) div 2, ContT + 115, 150, 21);
  fpscolorCheckBox.Font.Color := TextColor;

  fpscolor1ColorButton.SetBounds(ContL + 6,        ContT + 140, 80, 18);
  fpscolor2ColorButton.SetBounds(ContL + ContW div 2 - 40, ContT + 140, 80, 18);
  fpscolor3ColorButton.SetBounds(ContL + ContW - 86,      ContT + 140, 80, 18);

  fpscolor2SpinEdit.SetBounds(ContL + ContW div 2 - 35, ContT + 165, 70, 26);
  fpscolor3SpinEdit.SetBounds(ContL + ContW - 81,      ContT + 165, 70, 26);

  // ── Method / Limit toggle key pinned to the bottom of the groupbox ────────
  methodLabel.SetBounds(ContL + 6, ContT + ContH - 70, 60, 18);
  methodLabel.Font.Color := TextColor;

  fpslimmetComboBox.SetBounds(ContL + 6, ContT + ContH - 48, 110, 32);
end;

// ============================================================================
// PERFORMANCE TAB — card redesign
// ============================================================================

procedure Tgoverlayform.InitPerformanceTab;
const
  ACCENT_H  = 3;
  TITLE_T   = 6;
  TITLE_H   = 22;
  GB_OFFSET = ACCENT_H + TITLE_T + TITLE_H + 4;  // 35px

  // Vertical layout: 2 full-width cards
  ROW1_TOP = 0;
  ROW1_H   = 180;
  ROW2_TOP = 185;
  ROW2_H   = 389;

  // Each card holds two side-by-side sections
  procedure MakeCard(AIndex: Integer;
                     ATitle1: string; AGB1: TGroupBox;
                     ATitle2: string; AGB2: TGroupBox;
                     ATop, AHeight: Integer);
  var
    Card: TPanel;
    Bar: TPanel;
    Lbl1, Lbl2: TLabel;
    IsLight: Boolean;
    BgColor, TextColor: TColor;
    HalfW: Integer;
    GbSS: WideString;
    GbW: QWidgetH;
  begin
    IsLight   := CurrentTheme = tmLight;
    BgColor   := IfThen(IsLight, clWhite, RGBToColor(26, 30, 46));
    TextColor := IfThen(IsLight, LightTextColor, DarkTextColor);

    Card := TPanel.Create(Self);
    Card.Parent      := performanceTabSheet;
    Card.BevelOuter  := bvNone;
    Card.BorderStyle := bsNone;
    Card.Caption     := '';
    Card.Color       := BgColor;
    Card.ParentColor := False;
    Card.OnPaint     := @PerfCardPaint;
    Card.SetBounds(2, ATop, 800, AHeight);  // provisional; corrected by Reflow
    FPerfCards[AIndex] := Card;

    // Cyan accent bar
    Bar := TPanel.Create(Card);
    Bar.Parent     := Card;
    Bar.BevelOuter := bvNone;
    Bar.Caption    := '';
    Bar.Color      := RGBToColor(48, 190, 240);
    Bar.SetBounds(0, 0, Card.Width, ACCENT_H);
    Bar.Anchors    := [akLeft, akRight, akTop];

    HalfW := Card.Width div 2;

    // Left section title
    Lbl1 := TLabel.Create(Card);
    Lbl1.Parent      := Card;
    Lbl1.Caption     := ATitle1;
    Lbl1.Font.Style  := [fsBold];
    Lbl1.Font.Size   := 9;
    Lbl1.Font.Color  := TextColor;
    Lbl1.Transparent := True;
    Lbl1.AutoSize    := True;
    Lbl1.Left        := 10;
    Lbl1.Top         := TITLE_T + ACCENT_H;

    // Right section title
    Lbl2 := TLabel.Create(Card);
    Lbl2.Parent      := Card;
    Lbl2.Caption     := ATitle2;
    Lbl2.Font.Style  := [fsBold];
    Lbl2.Font.Size   := 9;
    Lbl2.Font.Color  := TextColor;
    Lbl2.Transparent := True;
    Lbl2.AutoSize    := True;
    Lbl2.Left        := HalfW + 10;
    Lbl2.Top         := TITLE_T + ACCENT_H;
    FPerfRightLbl[AIndex] := Lbl2;

    // Left GroupBox
    AGB1.Parent   := Card;
    AGB1.Caption  := '';
    AGB1.Color    := BgColor;
    AGB1.Font.Color := TextColor;
    AGB1.AnchorSideLeft.Control   := nil;
    AGB1.AnchorSideTop.Control    := nil;
    AGB1.AnchorSideRight.Control  := nil;
    AGB1.AnchorSideBottom.Control := nil;
    AGB1.Anchors := [akLeft, akTop, akBottom];
    AGB1.Left    := -1;
    AGB1.Top     := GB_OFFSET - 1;
    AGB1.Width   := HalfW + 2;
    AGB1.Height  := AHeight - GB_OFFSET + 2;

    // Right GroupBox
    AGB2.Parent   := Card;
    AGB2.Caption  := '';
    AGB2.Color    := BgColor;
    AGB2.Font.Color := TextColor;
    AGB2.AnchorSideLeft.Control   := nil;
    AGB2.AnchorSideTop.Control    := nil;
    AGB2.AnchorSideRight.Control  := nil;
    AGB2.AnchorSideBottom.Control := nil;
    AGB2.Anchors := [akLeft, akTop, akBottom];
    AGB2.Left    := HalfW - 1;
    AGB2.Top     := GB_OFFSET - 1;
    AGB2.Width   := HalfW + 2;
    AGB2.Height  := AHeight - GB_OFFSET + 2;

    // Custom UI for FPS Limit Toggle in Limiters card (AIndex = 1, AGB1 = fpslimiterGroupBox)
    if AIndex = 1 then
    begin
      fpslimtoggleComboBox.Visible := False;
      fpstoggleImage.Visible := False;

      limtoggleLabel.AnchorSideLeft.Control   := nil;
      limtoggleLabel.AnchorSideTop.Control    := nil;
      limtoggleLabel.AnchorSideRight.Control  := nil;
      limtoggleLabel.AnchorSideBottom.Control := nil;
      limtoggleLabel.Anchors := [akLeft, akTop];
      // Align with the repositioned bottom row from BuildFpsLimitEdit
      limtoggleLabel.Left    := AGB1.ClientWidth - 150;
      limtoggleLabel.Top     := AGB1.Height - 70;
      limtoggleLabel.Font.Color := TextColor;
      limtoggleLabel.ParentColor := True;

      FLimitCaptureBtn := TBitBtn.Create(AGB1);
      FLimitCaptureBtn.Parent  := AGB1;
      FLimitCaptureBtn.Tag     := 2;
      FLimitCaptureBtn.SetBounds(limtoggleLabel.Left, AGB1.Height - 48, 130, 32);
      FLimitCaptureBtn.OnClick := @CaptureBtnClick;
      FLimitCaptureBtn.Cursor  := crHandPoint;
      if Trim(fpslimtoggleComboBox.Text) <> '' then
        FLimitCaptureBtn.Caption := '⌨ ' + fpslimtoggleComboBox.Text
      else
        FLimitCaptureBtn.Caption := '⌨ Capture';
    end;

    // Remove GroupBox border — scoped to QGroupBox only, not child buttons
    GbSS := 'QGroupBox { border: none; }';
    GbW  := TQtWidget(AGB1.Handle).Widget;
    QWidget_setStyleSheet(GbW, @GbSS);
    GbW  := TQtWidget(AGB2.Handle).Widget;
    QWidget_setStyleSheet(GbW, @GbSS);
  end;

  procedure MakeVsyncRow(AIndex: Integer; ARow, AHeight: Integer;
                         Logo: TImage; Combo: TComboBox);
  var
    Row: TPanel;
  begin
    // Transparent container — inherits GroupBox background, no fill color
    Row := TPanel.Create(vsyncGroupBox);
    Row.Parent      := vsyncGroupBox;
    Row.BevelOuter  := bvNone;
    Row.Caption     := '';
    Row.ParentColor := True;
    Row.SetBounds(8, ARow, vsyncGroupBox.ClientWidth - 16, AHeight);
    Row.Anchors     := [akLeft, akTop, akRight];
    FVsyncRows[AIndex] := Row;

    // Logo — transparent, left-aligned, vertically centered
    Logo.Parent      := Row;
    Logo.Transparent := True;
    Logo.AnchorSideLeft.Control  := nil;
    Logo.AnchorSideTop.Control   := nil;
    Logo.AnchorSideRight.Control := nil;
    Logo.Anchors := [akLeft, akTop];
    Logo.Left    := 8;
    Logo.Top     := (AHeight - Logo.Height) div 2;

    // Combo — placed immediately after the logo
    Combo.Parent := Row;
    Combo.AnchorSideLeft.Control   := nil;
    Combo.AnchorSideTop.Control    := nil;
    Combo.AnchorSideRight.Control  := nil;
    Combo.AnchorSideBottom.Control := nil;
    Combo.Anchors := [akLeft, akTop];
    Combo.Top     := (AHeight - Combo.Height) div 2;
    Combo.Left    := Logo.Left + Logo.Width + 8;
  end;

  procedure AddVsyncSeparator;
  var
    Sep: TPanel;
    IsLight: Boolean;
  begin
    IsLight := CurrentTheme = tmLight;
    Sep := TPanel.Create(vsyncGroupBox);
    Sep.Parent      := vsyncGroupBox;
    Sep.BevelOuter  := bvNone;
    Sep.Caption     := '';
    Sep.Color       := IfThen(IsLight, $00C8C0C0, $005A5050);
    Sep.ParentColor := False;
    Sep.SetBounds(8, 56, vsyncGroupBox.ClientWidth - 16, 1);
    Sep.Anchors     := [akLeft, akTop, akRight];
  end;

var
  BgBox: TPaintBox;
begin
  BgBox := TPaintBox.Create(Self);
  BgBox.Parent  := performanceTabSheet;
  BgBox.Align   := alClient;
  BgBox.OnPaint := @PresetsBgBoxPaint;

  MakeCard(0, 'Information', fpsGroupBox,         'VSYNC',    vsyncGroupBox,      ROW1_TOP, ROW1_H);
  MakeCard(1, 'Limiters',   fpslimiterGroupBox,   'Filters',  filtersGroupBox,    ROW2_TOP, ROW2_H);
  FPerfCards[2] := nil;
  FPerfCards[3] := nil;

  // Free all Information grid controls from anchor chains — Reflow will center them
  fpsCheckBox.AnchorSideLeft.Control           := nil; fpsCheckBox.AnchorSideTop.Control           := nil; fpsCheckBox.AnchorSideRight.Control           := nil; fpsCheckBox.AnchorSideBottom.Control           := nil; fpsCheckBox.Anchors           := [akLeft, akTop];
  frametimegraphCheckBox.AnchorSideLeft.Control := nil; frametimegraphCheckBox.AnchorSideTop.Control := nil; frametimegraphCheckBox.AnchorSideRight.Control := nil; frametimegraphCheckBox.AnchorSideBottom.Control := nil; frametimegraphCheckBox.Anchors := [akLeft, akTop];
  frametimegraphColorButton.AnchorSideLeft.Control := nil; frametimegraphColorButton.AnchorSideTop.Control := nil; frametimegraphColorButton.AnchorSideRight.Control := nil; frametimegraphColorButton.AnchorSideBottom.Control := nil; frametimegraphColorButton.Anchors := [akLeft, akTop];
  frametimetypeBitBtn.AnchorSideLeft.Control    := nil; frametimetypeBitBtn.AnchorSideTop.Control    := nil; frametimetypeBitBtn.AnchorSideRight.Control    := nil; frametimetypeBitBtn.AnchorSideBottom.Control    := nil; frametimetypeBitBtn.Anchors    := [akLeft, akTop];
  fpsavgCheckBox.AnchorSideLeft.Control         := nil; fpsavgCheckBox.AnchorSideTop.Control         := nil; fpsavgCheckBox.AnchorSideRight.Control         := nil; fpsavgCheckBox.AnchorSideBottom.Control         := nil; fpsavgCheckBox.Anchors         := [akLeft, akTop];
  fpsavgBitBtn.AnchorSideLeft.Control           := nil; fpsavgBitBtn.AnchorSideTop.Control           := nil; fpsavgBitBtn.AnchorSideRight.Control           := nil; fpsavgBitBtn.AnchorSideBottom.Control           := nil; fpsavgBitBtn.Anchors           := [akLeft, akTop];
  framecountCheckBox.AnchorSideLeft.Control     := nil; framecountCheckBox.AnchorSideTop.Control     := nil; framecountCheckBox.AnchorSideRight.Control     := nil; framecountCheckBox.AnchorSideBottom.Control     := nil; framecountCheckBox.Anchors     := [akLeft, akTop];
  ftraceCheckBox.AnchorSideLeft.Control         := nil; ftraceCheckBox.AnchorSideTop.Control         := nil; ftraceCheckBox.AnchorSideRight.Control         := nil; ftraceCheckBox.AnchorSideBottom.Control         := nil; ftraceCheckBox.Anchors         := [akLeft, akTop];
  showfpslimCheckBox.AnchorSideLeft.Control     := nil; showfpslimCheckBox.AnchorSideTop.Control     := nil; showfpslimCheckBox.AnchorSideRight.Control     := nil; showfpslimCheckBox.AnchorSideBottom.Control     := nil; showfpslimCheckBox.Anchors     := [akLeft, akTop];
  vpsCheckBox.AnchorSideLeft.Control            := nil; vpsCheckBox.AnchorSideTop.Control            := nil; vpsCheckBox.AnchorSideRight.Control            := nil; vpsCheckBox.AnchorSideBottom.Control            := nil; vpsCheckBox.Anchors            := [akLeft, akTop];

  // VSYNC card — Vulkan in top half, OpenGL in bottom half, no separator
  MakeVsyncRow(0, 0,
    vsyncGroupBox.ClientHeight div 2,
    vulkanImage, vsyncComboBox);
  MakeVsyncRow(1,
    vsyncGroupBox.ClientHeight div 2,
    vsyncGroupBox.ClientHeight - vsyncGroupBox.ClientHeight div 2,
    openglImage, glvsyncComboBox);

  // FPS Limit — single comma-separated input field
  BuildFpsLimitEdit;
end;

procedure Tgoverlayform.InitExtrasTab;
// Fully code-driven layout matching the Metrics tab pattern.
const
  CARD_BG  = $002E1E1A;  // rgb(28, 33, 52) — Option B
  OUTER_BG = $00281A16;
  WHITE    = clWhite;
  HDR      = 34;

  procedure MakeCard(out Card: TPanel; const ATitle: string);
  var
    Bar: TPanel;
    Lbl: TLabel;
  begin
    Card := TPanel.Create(Self);
    Card.Parent      := FExtBgPanel;
    Card.BevelOuter  := bvNone;
    Card.BorderStyle := bsNone;
    Card.Color       := CARD_BG;
    Card.Caption     := '';
    Card.OnPaint     := @PerfCardPaint;
    Bar := TPanel.Create(Card);
    Bar.Parent     := Card;
    Bar.BevelOuter := bvNone;
    Bar.Color      := RGBToColor(48, 190, 240);
    Bar.Caption    := '';
    Bar.SetBounds(0, 0, 800, 3);
    Bar.Anchors    := [akLeft, akRight, akTop];
    Lbl := TLabel.Create(Card);
    Lbl.Parent      := Card;
    Lbl.Caption     := ATitle;
    Lbl.Font.Color  := WHITE;
    Lbl.Font.Size   := 10;
    Lbl.Font.Style  := [fsBold];
    Lbl.AutoSize    := True;
    Lbl.SetBounds(12, 8, 200, 22);
    Lbl.Transparent := True;
  end;

  procedure Place(C: TControl; Card: TPanel; ALeft, ATop: Integer);
  begin
    C.AnchorSideLeft.Control   := nil;
    C.AnchorSideTop.Control    := nil;
    C.AnchorSideRight.Control  := nil;
    C.AnchorSideBottom.Control := nil;
    C.Anchors := [akLeft, akTop];
    C.Parent  := Card;
    C.Left    := ALeft;
    C.Top     := ATop;
  end;

  procedure DarkCheck(C: TCheckBox);
  begin
    C.ParentColor := False;
    C.Color       := CARD_BG;
    C.Font.Color  := WHITE;
    C.Font.Size   := 9;
  end;

  procedure DarkLabel(L: TLabel);
  begin
    L.Font.Color  := WHITE;
    L.Transparent := True;
    L.ParentColor := False;
  end;

begin
  FExtScrollBox := TScrollBox.Create(Self);
  FExtScrollBox.Parent      := extrasTabSheet;
  FExtScrollBox.Align       := alClient;
  FExtScrollBox.AutoScroll  := True;
  FExtScrollBox.BorderStyle := bsNone;
  FExtScrollBox.Color       := RGBToColor(22, 26, 40);

  FExtBgPanel := TPanel.Create(Self);
  FExtBgPanel.Parent      := FExtScrollBox;
  FExtBgPanel.BevelOuter  := bvNone;
  FExtBgPanel.BorderStyle := bsNone;
  FExtBgPanel.Color       := RGBToColor(22, 26, 40);
  FExtBgPanel.OnPaint     := @PresetsWrapperPaint;
  FExtBgPanel.Caption     := '';

  // ── Card 1: System info ─────────────────────────────────────────────────
  MakeCard(FExtSysCard, 'System info');

  Place(systemLabel,           FExtSysCard, 11,  11 + HDR);  DarkLabel(systemLabel);
  Place(distroinfoCheckBox,    FExtSysCard, 11,  32 + HDR);  DarkCheck(distroinfoCheckBox);
  Place(refreshrateCheckBox,   FExtSysCard, 128, 32 + HDR);  DarkCheck(refreshrateCheckBox);
  Place(resolutionCheckBox,    FExtSysCard, 254, 32 + HDR);  DarkCheck(resolutionCheckBox);
  Place(displayserverCheckBox, FExtSysCard, 372, 32 + HDR);  DarkCheck(displayserverCheckBox);
  Place(timeCheckBox,          FExtSysCard, 513, 32 + HDR);  DarkCheck(timeCheckBox);
  Place(archCheckBox,          FExtSysCard, 597, 32 + HDR);  DarkCheck(archCheckBox);

  Place(wineLabel,             FExtSysCard, 11,  68 + HDR);  DarkLabel(wineLabel);
  Place(wineCheckBox,          FExtSysCard, 11,  89 + HDR);  DarkCheck(wineCheckBox);
  Place(engineversionCheckBox, FExtSysCard, 128, 89 + HDR);  DarkCheck(engineversionCheckBox);
  Place(engineshortCheckBox,   FExtSysCard, 254, 89 + HDR);  DarkCheck(engineshortCheckBox);
  Place(winesyncCheckBox,      FExtSysCard, 372, 89 + HDR);  DarkCheck(winesyncCheckBox);
  Place(dxapiCheckBox,         FExtSysCard, 513, 89 + HDR);  DarkCheck(dxapiCheckBox);
  Place(fexstatsCheckBox,      FExtSysCard, 597, 89 + HDR);  DarkCheck(fexstatsCheckBox);
  Place(wineColorButton,       FExtSysCard, 7,   111 + HDR);
  Place(engineColorButton,     FExtSysCard, 122, 111 + HDR);

  Place(optionsLabel,           FExtSysCard, 11,  131 + HDR); DarkLabel(optionsLabel);
  Place(hudversionCheckBox,     FExtSysCard, 11,  152 + HDR); DarkCheck(hudversionCheckBox);
  Place(gamemodestatusCheckBox, FExtSysCard, 128, 152 + HDR); DarkCheck(gamemodestatusCheckBox);
  Place(vkbasaltstatusCheckBox, FExtSysCard, 254, 152 + HDR); DarkCheck(vkbasaltstatusCheckBox);
  Place(fcatCheckBox,           FExtSysCard, 372, 152 + HDR); DarkCheck(fcatCheckBox);
  Place(fsrCheckBox,            FExtSysCard, 513, 152 + HDR); DarkCheck(fsrCheckBox);
  Place(hdrCheckBox,            FExtSysCard, 597, 152 + HDR); DarkCheck(hdrCheckBox);

  Place(batteryLabel,        FExtSysCard, 8,   190 + HDR); DarkLabel(batteryLabel);
  Place(batteryCheckBox,     FExtSysCard, 11,  211 + HDR); DarkCheck(batteryCheckBox);
  Place(batterywattCheckBox, FExtSysCard, 128, 211 + HDR); DarkCheck(batterywattCheckBox);
  Place(batterytimeCheckBox, FExtSysCard, 254, 211 + HDR); DarkCheck(batterytimeCheckBox);
  Place(deviceCheckBox,      FExtSysCard, 372, 211 + HDR); DarkCheck(deviceCheckBox);
  Place(batteryColorButton,  FExtSysCard, 6,   233 + HDR);

  Place(othersLabel,         FExtSysCard, 11,  262 + HDR); DarkLabel(othersLabel);
  Place(mediaCheckBox,       FExtSysCard, 11,  283 + HDR); DarkCheck(mediaCheckBox);
  Place(networkCheckBox,     FExtSysCard, 128, 283 + HDR); DarkCheck(networkCheckBox);
  Place(fahrenheitCheckBox,  FExtSysCard, 254, 283 + HDR); DarkCheck(fahrenheitCheckBox);
  Place(customcommandEdit,   FExtSysCard, 372, 283 + HDR); // keeps black/lime colors
  Place(mediaColorButton,    FExtSysCard, 6,   305 + HDR);
  Place(networkComboBox,     FExtSysCard, 128, 305 + HDR);
  networkComboBox.Color      := OUTER_BG;
  networkComboBox.Font.Color := WHITE;

  // Icon in card header — positioned in ReflowExtrasTab
  Place(sysinfoImage, FExtSysCard, 4, 5);
  systemGroupBox.Visible := False;

  // ── Card 2: Logging ─────────────────────────────────────────────────────
  MakeCard(FExtLogCard, 'Logging');

  Place(logdurationLabel,  FExtLogCard, 11,  11 + HDR);  DarkLabel(logdurationLabel);
  Place(logdelayLabel,     FExtLogCard, 105, 11 + HDR);  DarkLabel(logdelayLabel);
  Place(logintervalLabel,  FExtLogCard, 206, 11 + HDR);  DarkLabel(logintervalLabel);
  Place(durationTrackBar,  FExtLogCard, 26,  40 + HDR);
  Place(delayTrackBar,     FExtLogCard, 123, 40 + HDR);
  Place(intervalTrackBar,  FExtLogCard, 218, 40 + HDR);
  Place(durationvalueLabel,FExtLogCard, 54,  96 + HDR);  DarkLabel(durationvalueLabel);
  Place(delayvalueLabel,   FExtLogCard, 151, 96 + HDR);  DarkLabel(delayvalueLabel);
  Place(intervalvalueLabel,FExtLogCard, 246, 96 + HDR);  DarkLabel(intervalvalueLabel);

  Place(logtoggleLabel, FExtLogCard, 356, 40 + HDR);
  logtoggleLabel.Font.Color  := WHITE;
  logtoggleLabel.Transparent := True;

  Place(logtoggleComboBox, FExtLogCard, 356, 61 + HDR);
  logtoggleComboBox.Visible := False;

  FLoggingCaptureBtn := TBitBtn.Create(FExtLogCard);
  FLoggingCaptureBtn.Parent  := FExtLogCard;
  FLoggingCaptureBtn.Tag     := 3;
  FLoggingCaptureBtn.SetBounds(356, 61 + HDR, 160, 28);
  FLoggingCaptureBtn.OnClick := @CaptureBtnClick;
  FLoggingCaptureBtn.Cursor  := crHandPoint;
  if Trim(logtoggleComboBox.Text) <> '' then
    FLoggingCaptureBtn.Caption := '⌨ ' + logtoggleComboBox.Text
  else
    FLoggingCaptureBtn.Caption := '⌨ Capture';

  Place(autouploadCheckBox, FExtLogCard, 530, 67 + HDR); DarkCheck(autouploadCheckBox);
  Place(versioningCheckBox, FExtLogCard, 665, 67 + HDR); DarkCheck(versioningCheckBox);

  Place(logfolderLabel,  FExtLogCard, 527, 122 + HDR); DarkLabel(logfolderLabel);
  Place(logfolderEdit,   FExtLogCard, 335, 143 + HDR);
  logfolderEdit.Color      := OUTER_BG;
  logfolderEdit.Font.Color := WHITE;
  Place(logfolderBitBtn, FExtLogCard, 783, 143 + HDR);

  Place(logtoggleImage, FExtLogCard, 325, 63 + HDR);
  logtoggleImage.Visible := False;
  // Log icon in card header — right-anchored
  // Icon in card header — positioned in ReflowExtrasTab
  Place(Image2, FExtLogCard, 4, 5);

  loggingGroupBox.Visible := False;
end;

procedure Tgoverlayform.UpdatePerfCardTheme;
const
  DARK_BG  = $002E1E1A;  // rgb(28, 33, 52) — Option B
  LIGHT_BG = $00FFFFFF;
var
  i, j: Integer;
  CardBg, TextColor: TColor;
  Card: TPanel;
begin
  if not Assigned(FPerfCards[0]) then Exit;

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

  for i := 0 to 3 do
  begin
    Card := FPerfCards[i];
    if not Assigned(Card) then Continue;
    Card.Color := CardBg;
    Card.Invalidate;
    for j := 0 to Card.ControlCount - 1 do
    begin
      if Card.Controls[j] is TLabel then
      begin
        TLabel(Card.Controls[j]).Font.Color := TextColor;
        TLabel(Card.Controls[j]).Color      := CardBg;
      end;
      if Card.Controls[j] is TGroupBox then
      begin
        TGroupBox(Card.Controls[j]).Color      := CardBg;
        TGroupBox(Card.Controls[j]).Font.Color := TextColor;
      end;
    end;
  end;

  // VSYNC row labels: update font color for theme change
  if Assigned(FVsyncRows[0]) or Assigned(FVsyncRows[1]) then
  begin
    for i := 0 to 1 do
    begin
      if not Assigned(FVsyncRows[i]) then Continue;
      for j := 0 to FVsyncRows[i].ControlCount - 1 do
        if FVsyncRows[i].Controls[j] is TLabel then
          TLabel(FVsyncRows[i].Controls[j]).Font.Color := TextColor;
    end;
  end;

  // FPS Limit edit: update colors for theme
  if Assigned(FFpsLimitEdit) then
  begin
    FFpsLimitEdit.Color     := IfThen(CurrentTheme = tmLight, $00F5F5F5, $002E2E2E);
    FFpsLimitEdit.Font.Color := TextColor;
  end;
end;

procedure Tgoverlayform.ReflowPerformanceTab(AContentW: Integer);
const
  MARGIN   = 2;
  GAP      = 5;   // gap between cards
  ROW1_TOP = 0;
  ROW1_H   = 180;
  ROW2_TOP = 185;
  ROW2_H   = 389;
  GB_OFF   = 34;
var
  CardW, HalfW, i, InfoMargin: Integer;
begin
  CardW := AContentW - MARGIN * 2;
  HalfW := CardW div 2;

  if Assigned(FPerfCards[0]) then
  begin
    FPerfCards[0].SetBounds(MARGIN, ROW1_TOP, CardW, ROW1_H);
    FPerfCards[1].SetBounds(MARGIN, ROW2_TOP, CardW, ROW2_H);

    // Left GroupBoxes
    fpsGroupBox.SetBounds(-1, GB_OFF - 1, HalfW + 2, ROW1_H - GB_OFF + 2);
    fpslimiterGroupBox.SetBounds(-1, GB_OFF - 1, HalfW + 2, ROW2_H - GB_OFF + 2);
    // Right GroupBoxes
    vsyncGroupBox.SetBounds(HalfW - 1, GB_OFF - 1, HalfW + 2, ROW1_H - GB_OFF + 2);
    filtersGroupBox.SetBounds(HalfW - 1, GB_OFF - 1, HalfW + 2, ROW2_H - GB_OFF + 2);

    // Update right labels
    for i := 0 to 1 do
      if Assigned(FPerfRightLbl[i]) then
        FPerfRightLbl[i].Left := HalfW + 10;

    // Center Information grid columns within fpsGroupBox
    // Block: col1(offset 0, w=100) + gap + col2(offset 110, w=107) + gap + col3(offset 225, w=76) = 301px total
    InfoMargin := (HalfW - 301) div 2;
    if InfoMargin < 4 then InfoMargin := 4;
    fpsCheckBox.Left                := InfoMargin;
    frametimegraphCheckBox.Left     := InfoMargin;
    frametimegraphColorButton.Left  := InfoMargin;
    frametimetypeBitBtn.Left        := InfoMargin;
    fpsavgCheckBox.Left             := InfoMargin + 110;
    fpsavgBitBtn.Left               := InfoMargin + 110;
    framecountCheckBox.Left         := InfoMargin + 110;
    ftraceCheckBox.Left             := InfoMargin + 110;
    showfpslimCheckBox.Left         := InfoMargin + 225;
    vpsCheckBox.Left                := InfoMargin + 225;

    // Center logo+combo block (101+8+109=218px) within each VSYNC row
    if Assigned(FVsyncRows[0]) then
    begin
      FVsyncRows[0].Width := vsyncGroupBox.ClientWidth - 16;
      vulkanImage.Left    := (FVsyncRows[0].Width - 218) div 2;
      vsyncComboBox.Left  := vulkanImage.Left + vulkanImage.Width + 8;
    end;
    if Assigned(FVsyncRows[1]) then
    begin
      FVsyncRows[1].Width := vsyncGroupBox.ClientWidth - 16;
      openglImage.Left    := (FVsyncRows[1].Width - 218) div 2;
      glvsyncComboBox.Left := openglImage.Left + openglImage.Width + 8;
    end;
  end;
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
const
  BG      = $002E1E1A;  // rgb(28, 33, 52) — Option B
  ACCENT  = $00F0BE30;  // rgb(48, 190, 240) — cyan
  WHITE   = clWhite;
  PURPLE  = $BB99FF;
  GRAY    = $AAAAAA;
  GREEN   = $66CC44;
  BLUELK  = $4499FF;
  COMBOBG = $2A2A40;

  procedure MakeCard(out Card: TPanel; const ATitle: string);
  var
    Bar: TPanel;
    Lbl: TLabel;
  begin
    Card := TPanel.Create(Self);
    Card.Parent     := FOsBgPanel;
    Card.BevelOuter := bvNone;
    Card.BorderStyle := bsNone;
    Card.Color      := BG;
    Card.Caption    := '';
    Card.OnPaint    := @PerfCardPaint;
    Bar := TPanel.Create(Card);
    Bar.Parent     := Card;
    Bar.BevelOuter := bvNone;
    Bar.Color      := ACCENT;
    Bar.Caption    := '';
    Bar.SetBounds(0, 0, 400, 3);
    Bar.Anchors    := [akLeft, akRight, akTop];
    Lbl := TLabel.Create(Card);
    Lbl.Parent      := Card;
    Lbl.Caption     := ATitle;
    Lbl.Font.Color  := WHITE;
    Lbl.Font.Size   := 10;
    Lbl.Font.Style  := [fsBold];
    Lbl.AutoSize    := True;
    Lbl.SetBounds(12, 8, 200, 22);
    Lbl.Transparent := True;
  end;

  // Reparent a GroupBox into a card, clearing its own anchor references
  // and replacing its built-in title+border with the card header.
  procedure ReparentGB(GB: TGroupBox; Card: TPanel);
  var SS: WideString;
  begin
    GB.Parent   := Card;
    GB.Visible  := True;
    GB.Caption  := '';
    GB.Color    := BG;
    GB.Font.Color := WHITE;
    GB.AnchorSideLeft.Control   := nil;
    GB.AnchorSideTop.Control    := nil;
    GB.AnchorSideRight.Control  := nil;
    GB.AnchorSideBottom.Control := nil;
    GB.Anchors := [akLeft, akTop];
    SS := 'QGroupBox { border: none; }';
    QWidget_setStyleSheet(TQtWidget(GB.Handle).Widget, @SS);
  end;

  procedure DarkCheck(C: TCheckBox);
  begin
    C.ParentColor := False; C.Color := BG; C.Font.Color := WHITE; C.Font.Size := 9;
  end;

  procedure DarkRadio(R: TRadioButton);
  begin
    R.ParentColor := False; R.Color := BG; R.Font.Color := WHITE; R.Font.Size := 9;
  end;

  procedure DarkCombo(C: TComboBox);
  begin
    C.Color := COMBOBG; C.Font.Color := WHITE; C.Font.Size := 9;
  end;

  procedure DarkLbl(L: TLabel; AColor: TColor);
  begin
    L.Color      := BG;
    L.Font.Color := AColor;
    L.Font.Size  := 9;
    L.Transparent := False;
  end;

const
  STAT_NAMES: array[0..5] of string = (
    'OptiScaler', 'FakeNVAPI', 'FSR', 'XeSS', 'DLSS', 'OptiPatcher');
var
  i: Integer;
  Dot: TShape;
  NLbl, VLbl: TLabel;
  Png: TPortableNetworkGraphic;
  IconPath: string;
  GbSS: WideString;
begin
  // Scroll container fills the tab
  FOsScrollBox := TScrollBox.Create(Self);
  FOsScrollBox.Parent      := optiscalerTabSheet;
  FOsScrollBox.Align       := alClient;
  FOsScrollBox.AutoScroll  := True;
  FOsScrollBox.BorderStyle := bsNone;
  FOsScrollBox.HorzScrollBar.Visible := False;
  FOsScrollBox.Color       := $1E1E2E;
  FOsScrollBox.ParentColor := False;

  // FOsBgPanel fills the scroll box and reliably paints the dark background
  // in the Qt6 backend (TScrollBox.Color is ignored by the Qt viewport).
  FOsBgPanel := TPanel.Create(Self);
  FOsBgPanel.Parent     := FOsScrollBox;
  FOsBgPanel.BevelOuter := bvNone;
  FOsBgPanel.Color      := RGBToColor(22, 26, 40);
  FOsBgPanel.Caption    := '';
  FOsBgPanel.OnPaint    := @PresetsWrapperPaint;
  FOsBgPanel.Left       := 0;
  FOsBgPanel.Top        := 0;
  FOsBgPanel.Width      := FOsScrollBox.ClientWidth;
  FOsBgPanel.Height     := 600;  // provisional; updated by ReflowOptiScalerTabNew

  // ── Card 0: GPU Driver ──────────────────────────────────────────────
  // Migrate all controls directly into the card panel — no TGroupBox used.
  // Offset = HDR(34) - 1 + GroupBox_title(29) = 62 to preserve the original
  // absolute positions that were in the GroupBox client area.
  MakeCard(FOsGpuCard, 'GPU Driver');
  GbSS := 'QRadioButton::indicator { width:14px; height:14px; background-color:rgb(26,30,46); border:1px solid rgb(130,140,170); border-radius:7px; }'
        + 'QRadioButton::indicator:checked { background-color:rgb(48,190,240); border-color:rgb(48,190,240); }';
  QWidget_setStyleSheet(TQtWidget(FOsGpuCard.Handle).Widget, @GbSS);

  nvidiaRadioButton.AnchorSideLeft.Control   := nil;
  nvidiaRadioButton.AnchorSideTop.Control    := nil;
  nvidiaRadioButton.AnchorSideRight.Control  := nil;
  nvidiaRadioButton.AnchorSideBottom.Control := nil;
  nvidiaRadioButton.Anchors := [akLeft, akTop];
  nvidiaRadioButton.Top     := nvidiaRadioButton.Top + 62;
  nvidiaRadioButton.Parent  := FOsGpuCard;
  DarkRadio(nvidiaRadioButton);

  mesaRadioButton.AnchorSideLeft.Control   := nil;
  mesaRadioButton.AnchorSideTop.Control    := nil;
  mesaRadioButton.AnchorSideRight.Control  := nil;
  mesaRadioButton.AnchorSideBottom.Control := nil;
  mesaRadioButton.Anchors := [akLeft, akTop];
  mesaRadioButton.Top     := mesaRadioButton.Top + 62;
  mesaRadioButton.Parent  := FOsGpuCard;
  DarkRadio(mesaRadioButton);

  nvidiaImage.AnchorSideLeft.Control   := nil;
  nvidiaImage.AnchorSideTop.Control    := nil;
  nvidiaImage.AnchorSideRight.Control  := nil;
  nvidiaImage.AnchorSideBottom.Control := nil;
  nvidiaImage.Anchors     := [akLeft, akTop];
  nvidiaImage.Top         := nvidiaImage.Top + 62;
  nvidiaImage.Transparent := True;
  nvidiaImage.Parent      := FOsGpuCard;

  mesaImage.AnchorSideLeft.Control   := nil;
  mesaImage.AnchorSideTop.Control    := nil;
  mesaImage.AnchorSideRight.Control  := nil;
  mesaImage.AnchorSideBottom.Control := nil;
  mesaImage.Anchors     := [akLeft, akTop];
  mesaImage.Top         := mesaImage.Top + 62;
  mesaImage.Transparent := True;
  mesaImage.Parent      := FOsGpuCard;

  autodetectnvLabel.AnchorSideLeft.Control   := nil;
  autodetectnvLabel.AnchorSideTop.Control    := nil;
  autodetectnvLabel.AnchorSideRight.Control  := nil;
  autodetectnvLabel.AnchorSideBottom.Control := nil;
  autodetectnvLabel.Anchors     := [akLeft, akTop];
  autodetectnvLabel.Top         := autodetectnvLabel.Top + 62;
  autodetectnvLabel.Transparent := True;
  autodetectnvLabel.Font.Color  := GREEN;
  autodetectnvLabel.Parent      := FOsGpuCard;

  autodetectmesaLabel.AnchorSideLeft.Control   := nil;
  autodetectmesaLabel.AnchorSideTop.Control    := nil;
  autodetectmesaLabel.AnchorSideRight.Control  := nil;
  autodetectmesaLabel.AnchorSideBottom.Control := nil;
  autodetectmesaLabel.Anchors     := [akLeft, akTop];
  autodetectmesaLabel.Top         := autodetectmesaLabel.Top + 62;
  autodetectmesaLabel.Transparent := True;
  autodetectmesaLabel.Font.Color  := GREEN;
  autodetectmesaLabel.Parent      := FOsGpuCard;

  gpudriverGroupBox.Visible := False;

  // ── Card 1: Options (3-column inner layout) ─────────────────────────
  // No GroupBox in the hierarchy — section TPanels parent directly to the card.
  MakeCard(FOsOptionsCard, 'Options');
  optionsGroupBox.Visible    := False;
  optiscalerGroupBox.Visible := False;
  imgmenuGroupBox.Visible    := False;
  fakenvapiGroupBox.Visible  := False;

  FOsOptiSec := TPanel.Create(Self);
  FOsOptiSec.Parent      := FOsOptionsCard;
  FOsOptiSec.BevelOuter  := bvNone;
  FOsOptiSec.BorderStyle := bsNone;
  FOsOptiSec.Caption     := '';
  FOsOptiSec.Color       := BG;
  FOsOptiSec.OnPaint     := @SubCardPaint;
  with TLabel.Create(FOsOptiSec) do begin
    Parent := FOsOptiSec; Caption := 'OptiScaler';
    Font.Color := $00CCAAAA; Font.Style := [fsBold]; Font.Size := 8;
    Left := 6; Top := 4; Transparent := True; AutoSize := True;
  end;

  FOsImgSec := TPanel.Create(Self);
  FOsImgSec.Parent      := FOsOptionsCard;
  FOsImgSec.BevelOuter  := bvNone;
  FOsImgSec.BorderStyle := bsNone;
  FOsImgSec.Caption     := '';
  FOsImgSec.Color       := BG;
  FOsImgSec.OnPaint     := @SubCardPaint;
  with TLabel.Create(FOsImgSec) do begin
    Parent := FOsImgSec; Caption := 'ImGUI Menu';
    Font.Color := $00CCAAAA; Font.Style := [fsBold]; Font.Size := 8;
    Left := 6; Top := 4; Transparent := True; AutoSize := True;
  end;

  FOsFakeSec := TPanel.Create(Self);
  FOsFakeSec.Parent      := FOsOptionsCard;
  FOsFakeSec.BevelOuter  := bvNone;
  FOsFakeSec.BorderStyle := bsNone;
  FOsFakeSec.Caption     := '';
  FOsFakeSec.Color       := BG;
  FOsFakeSec.OnPaint     := @SubCardPaint;
  with TLabel.Create(FOsFakeSec) do begin
    Parent := FOsFakeSec; Caption := 'FakeNVAPI';
    Font.Color := $00CCAAAA; Font.Style := [fsBold]; Font.Size := 8;
    Left := 6; Top := 4; Transparent := True; AutoSize := True;
  end;

  // Reparent OptiScaler controls → FOsOptiSec (top += 22 past section title)
  filenameLabel.AnchorSideLeft.Control   := nil; filenameLabel.AnchorSideTop.Control    := nil;
  filenameLabel.AnchorSideRight.Control  := nil; filenameLabel.AnchorSideBottom.Control := nil;
  filenameLabel.Anchors := [akLeft, akTop]; filenameLabel.Top := filenameLabel.Top + 22;
  filenameLabel.Parent  := FOsOptiSec;

  filenameComboBox.AnchorSideLeft.Control   := nil; filenameComboBox.AnchorSideTop.Control    := nil;
  filenameComboBox.AnchorSideRight.Control  := nil; filenameComboBox.AnchorSideBottom.Control := nil;
  filenameComboBox.Anchors := [akLeft, akTop]; filenameComboBox.Top := filenameComboBox.Top + 22;
  filenameComboBox.Parent  := FOsOptiSec;

  spoofCheckBox.AnchorSideLeft.Control   := nil; spoofCheckBox.AnchorSideTop.Control    := nil;
  spoofCheckBox.AnchorSideRight.Control  := nil; spoofCheckBox.AnchorSideBottom.Control := nil;
  spoofCheckBox.Anchors := [akLeft, akTop]; spoofCheckBox.Top := spoofCheckBox.Top + 22;
  spoofCheckBox.Parent  := FOsOptiSec;

  fsrversionLabel.AnchorSideLeft.Control   := nil; fsrversionLabel.AnchorSideTop.Control    := nil;
  fsrversionLabel.AnchorSideRight.Control  := nil; fsrversionLabel.AnchorSideBottom.Control := nil;
  fsrversionLabel.Anchors := [akLeft, akTop]; fsrversionLabel.Top := fsrversionLabel.Top + 22;
  fsrversionLabel.Parent  := FOsOptiSec;

  fsrversionComboBox.AnchorSideLeft.Control   := nil; fsrversionComboBox.AnchorSideTop.Control    := nil;
  fsrversionComboBox.AnchorSideRight.Control  := nil; fsrversionComboBox.AnchorSideBottom.Control := nil;
  fsrversionComboBox.Anchors := [akLeft, akTop]; fsrversionComboBox.Top := fsrversionComboBox.Top + 22;
  fsrversionComboBox.Parent  := FOsOptiSec;

  emufp8CheckBox.AnchorSideLeft.Control   := nil; emufp8CheckBox.AnchorSideTop.Control    := nil;
  emufp8CheckBox.AnchorSideRight.Control  := nil; emufp8CheckBox.AnchorSideBottom.Control := nil;
  emufp8CheckBox.Anchors := [akLeft, akTop]; emufp8CheckBox.Top := emufp8CheckBox.Top + 22;
  emufp8CheckBox.Parent  := FOsOptiSec;

  osversionLabel.AnchorSideLeft.Control   := nil; osversionLabel.AnchorSideTop.Control    := nil;
  osversionLabel.AnchorSideRight.Control  := nil; osversionLabel.AnchorSideBottom.Control := nil;
  osversionLabel.Anchors := [akLeft, akTop]; osversionLabel.Top := osversionLabel.Top + 22;
  osversionLabel.Parent  := FOsOptiSec;

  protontricksManagerButton.AnchorSideLeft.Control   := nil; protontricksManagerButton.AnchorSideTop.Control    := nil;
  protontricksManagerButton.AnchorSideRight.Control  := nil; protontricksManagerButton.AnchorSideBottom.Control := nil;
  protontricksManagerButton.Anchors := [akLeft, akTop]; protontricksManagerButton.Top := protontricksManagerButton.Top + 22;
  protontricksManagerButton.Parent  := FOsOptiSec;

  optipatcherCheckBox.AnchorSideLeft.Control   := nil; optipatcherCheckBox.AnchorSideTop.Control    := nil;
  optipatcherCheckBox.AnchorSideRight.Control  := nil; optipatcherCheckBox.AnchorSideBottom.Control := nil;
  optipatcherCheckBox.Anchors := [akLeft, akTop]; optipatcherCheckBox.Top := optipatcherCheckBox.Top + 22;
  optipatcherCheckBox.Parent  := FOsOptiSec;

  patcherlistLabel.AnchorSideLeft.Control   := nil; patcherlistLabel.AnchorSideTop.Control    := nil;
  patcherlistLabel.AnchorSideRight.Control  := nil; patcherlistLabel.AnchorSideBottom.Control := nil;
  patcherlistLabel.Anchors := [akLeft, akTop]; patcherlistLabel.Top := patcherlistLabel.Top + 22;
  patcherlistLabel.Parent  := FOsOptiSec;

  // Reparent ImGUI Menu controls → FOsImgSec
  menuLabel.AnchorSideLeft.Control   := nil; menuLabel.AnchorSideTop.Control    := nil;
  menuLabel.AnchorSideRight.Control  := nil; menuLabel.AnchorSideBottom.Control := nil;
  menuLabel.Anchors := [akLeft, akTop]; menuLabel.Top := menuLabel.Top + 22;
  menuLabel.Parent  := FOsImgSec;

  menuscalevalueLabel.AnchorSideLeft.Control   := nil; menuscalevalueLabel.AnchorSideTop.Control    := nil;
  menuscalevalueLabel.AnchorSideRight.Control  := nil; menuscalevalueLabel.AnchorSideBottom.Control := nil;
  menuscalevalueLabel.Anchors := [akLeft, akTop]; menuscalevalueLabel.Top := menuscalevalueLabel.Top + 22;
  menuscalevalueLabel.Left    := 252;
  menuscalevalueLabel.Parent  := FOsImgSec;

  menuscaleTrackBar.AnchorSideLeft.Control   := nil; menuscaleTrackBar.AnchorSideTop.Control    := nil;
  menuscaleTrackBar.AnchorSideRight.Control  := nil; menuscaleTrackBar.AnchorSideBottom.Control := nil;
  menuscaleTrackBar.Anchors := [akLeft, akTop]; menuscaleTrackBar.Top := menuscaleTrackBar.Top + 22;
  menuscaleTrackBar.Parent  := FOsImgSec;

  mark1Label.AnchorSideLeft.Control   := nil; mark1Label.AnchorSideTop.Control    := nil;
  mark1Label.AnchorSideRight.Control  := nil; mark1Label.AnchorSideBottom.Control := nil;
  mark1Label.Anchors := [akLeft, akTop]; mark1Label.Top := mark1Label.Top + 22;
  mark1Label.Parent  := FOsImgSec;

  mark2Label.AnchorSideLeft.Control   := nil; mark2Label.AnchorSideTop.Control    := nil;
  mark2Label.AnchorSideRight.Control  := nil; mark2Label.AnchorSideBottom.Control := nil;
  mark2Label.Anchors := [akLeft, akTop]; mark2Label.Top := mark2Label.Top + 22;
  mark2Label.Parent  := FOsImgSec;

  mark3Label.AnchorSideLeft.Control   := nil; mark3Label.AnchorSideTop.Control    := nil;
  mark3Label.AnchorSideRight.Control  := nil; mark3Label.AnchorSideBottom.Control := nil;
  mark3Label.Anchors := [akLeft, akTop]; mark3Label.Top := mark3Label.Top + 22;
  mark3Label.Parent  := FOsImgSec;

  shortcutkeyLabel.AnchorSideLeft.Control   := nil; shortcutkeyLabel.AnchorSideTop.Control    := nil;
  shortcutkeyLabel.AnchorSideRight.Control  := nil; shortcutkeyLabel.AnchorSideBottom.Control := nil;
  shortcutkeyLabel.Anchors  := [akLeft, akTop];
  shortcutkeyLabel.Top      := shortcutkeyLabel.Top + 22;
  shortcutkeyLabel.Caption  := 'Menu Toggle Key';
  shortcutkeyLabel.Parent   := FOsImgSec;

  // shortcutImage removed from UI — just hide it
  shortcutImage.Visible := False;

  // Keep combobox as hidden data store (hex VK code); button is the visible UI
  shortcutkeyComboBox.Visible := False;
  shortcutkeyComboBox.Parent  := FOsImgSec;
  if (shortcutkeyComboBox.Text = '') or SameText(shortcutkeyComboBox.Text, 'auto') then
    shortcutkeyComboBox.Text := '0x2d';  // INSERT = default ShortcutKey

  FOsShortcutCaptureBtn := TBitBtn.Create(FOsImgSec);
  FOsShortcutCaptureBtn.Parent   := FOsImgSec;
  FOsShortcutCaptureBtn.Tag      := 5;
  FOsShortcutCaptureBtn.Anchors  := [akLeft, akTop];
  FOsShortcutCaptureBtn.Cursor   := crHandPoint;
  FOsShortcutCaptureBtn.OnClick  := @CaptureBtnClick;
  FOsShortcutCaptureBtn.Left     := shortcutkeyLabel.Left;
  FOsShortcutCaptureBtn.Top      := shortcutkeyLabel.Top + shortcutkeyLabel.Height + 4;
  FOsShortcutCaptureBtn.Width    := 100;
  FOsShortcutCaptureBtn.Height   := 28;
  FOsShortcutCaptureBtn.Caption  := '⌨ ' + OsHexToKeyStr(shortcutkeyComboBox.Text);

  // Reparent FakeNVAPI controls → FOsFakeSec
  forcereflexCheckBox.AnchorSideLeft.Control   := nil; forcereflexCheckBox.AnchorSideTop.Control    := nil;
  forcereflexCheckBox.AnchorSideRight.Control  := nil; forcereflexCheckBox.AnchorSideBottom.Control := nil;
  forcereflexCheckBox.Anchors := [akLeft, akTop]; forcereflexCheckBox.Top := forcereflexCheckBox.Top + 22;
  forcereflexCheckBox.Parent  := FOsFakeSec;

  reflexComboBox.AnchorSideLeft.Control   := nil; reflexComboBox.AnchorSideTop.Control    := nil;
  reflexComboBox.AnchorSideRight.Control  := nil; reflexComboBox.AnchorSideBottom.Control := nil;
  reflexComboBox.Anchors := [akLeft, akTop]; reflexComboBox.Top := reflexComboBox.Top + 22;
  reflexComboBox.Parent  := FOsFakeSec;

  forcelatencyflexCheckBox.AnchorSideLeft.Control   := nil; forcelatencyflexCheckBox.AnchorSideTop.Control    := nil;
  forcelatencyflexCheckBox.AnchorSideRight.Control  := nil; forcelatencyflexCheckBox.AnchorSideBottom.Control := nil;
  forcelatencyflexCheckBox.Anchors := [akLeft, akTop]; forcelatencyflexCheckBox.Top := forcelatencyflexCheckBox.Top + 22;
  forcelatencyflexCheckBox.Parent  := FOsFakeSec;

  latencyflexComboBox.AnchorSideLeft.Control   := nil; latencyflexComboBox.AnchorSideTop.Control    := nil;
  latencyflexComboBox.AnchorSideRight.Control  := nil; latencyflexComboBox.AnchorSideBottom.Control := nil;
  latencyflexComboBox.Anchors := [akLeft, akTop]; latencyflexComboBox.Top := latencyflexComboBox.Top + 22;
  latencyflexComboBox.Parent  := FOsFakeSec;

  overrideCheckBox.AnchorSideLeft.Control   := nil; overrideCheckBox.AnchorSideTop.Control    := nil;
  overrideCheckBox.AnchorSideRight.Control  := nil; overrideCheckBox.AnchorSideBottom.Control := nil;
  overrideCheckBox.Anchors := [akLeft, akTop]; overrideCheckBox.Top := overrideCheckBox.Top + 22;
  overrideCheckBox.Parent  := FOsFakeSec;

  tracelogCheckBox.AnchorSideLeft.Control   := nil; tracelogCheckBox.AnchorSideTop.Control    := nil;
  tracelogCheckBox.AnchorSideRight.Control  := nil; tracelogCheckBox.AnchorSideBottom.Control := nil;
  tracelogCheckBox.Anchors := [akLeft, akTop]; tracelogCheckBox.Top := tracelogCheckBox.Top + 22;
  tracelogCheckBox.Parent  := FOsFakeSec;

  // DLL & Options section
  DarkLbl(filenameLabel,    PURPLE); filenameLabel.Transparent    := True;
  DarkCombo(filenameComboBox);
  DarkCheck(spoofCheckBox);
  DarkCheck(emufp8CheckBox);
  DarkCheck(optipatcherCheckBox);
  DarkLbl(fsrversionLabel,  PURPLE); fsrversionLabel.Transparent := True;
  DarkCombo(fsrversionComboBox);
  DarkLbl(osversionLabel,   GRAY); osversionLabel.Transparent := True;
  DarkLbl(patcherlistLabel, BLUELK); patcherlistLabel.Transparent := True;
  // In-Game Menu section
  DarkLbl(menuLabel,           PURPLE);
  DarkLbl(menuscalevalueLabel, WHITE);
  menuLabel.Transparent          := True;
  menuscalevalueLabel.Transparent := True;
  DarkLbl(mark1Label,          GRAY); mark1Label.Transparent := True;
  DarkLbl(mark2Label,          GRAY); mark2Label.Transparent := True;
  DarkLbl(mark3Label,          GRAY); mark3Label.Transparent := True;
  DarkLbl(shortcutkeyLabel,    PURPLE); shortcutkeyLabel.Transparent := True;
  DarkCombo(shortcutkeyComboBox);
  // FakeNVAPI section
  DarkCheck(forcereflexCheckBox);
  DarkCheck(overrideCheckBox);
  DarkCheck(forcelatencyflexCheckBox);
  DarkCheck(tracelogCheckBox);
  DarkCombo(reflexComboBox);
  DarkCombo(latencyflexComboBox);

  // ── Card 2: Software Status — fresh indicator rows ──────────────────
  // statusGroupBox stays hidden; FOptiscalerUpdate writes version text to its
  // labels (optlabel1, fakenvapi1, etc.) which serve as invisible data sinks.
  // FOsStatDots/FOsStatVerLbls are fresh controls that we sync via RefreshOsStatusDots.
  MakeCard(FOsStatusCard, 'Software Status');
  statusGroupBox.Visible := False;

  // Reparent the branch selector combo
  optversionComboBox.Parent  := FOsStatusCard;
  optversionComboBox.Anchors := [akLeft, akTop];
  optversionComboBox.Visible := True;
  DarkCombo(optversionComboBox);

  // Reparent update buttons (were inside hidden statusGroupBox)
  updateBitBtn.Parent      := FOsStatusCard;
  updateBitBtn.Anchors     := [akLeft, akTop];
  updateBitBtn.Visible     := True;
  updateBitBtn.Caption     := 'Update';
  updateBitBtn.Font.Color  := clWhite;
  updateBitBtn.Font.Size   := 9;
  updateBitBtn.Font.Style  := [fsBold];
  updateBitBtn.Glyph.Clear;
  updateBitBtn.Images      := nil;
  // Load the download icon (left of text)
  IconPath := ExtractFilePath(Application.ExeName) + 'data/icons/buttons/24x24/download.png';
  if FileExists(IconPath) then
  begin
    Png := TPortableNetworkGraphic.Create;
    try
      Png.LoadFromFile(IconPath);
      updateBitBtn.Glyph.Assign(Png);
    finally
      Png.Free;
    end;
  end;
  updateBitBtn.Layout  := blGlyphLeft;
  updateBitBtn.Spacing := 6;

  checkupdBitBtn.Parent    := FOsStatusCard;
  checkupdBitBtn.Anchors   := [akLeft, akTop];
  checkupdBitBtn.Visible   := True;
  checkupdBitBtn.Font.Color := clWhite;
  checkupdBitBtn.Font.Size := 9;
  checkupdBitBtn.Layout    := blGlyphLeft;
  checkupdBitBtn.Spacing   := 6;

  // Reparent progress bar and status label (were direct children of optiscalerTabSheet)
  updateProgressBar.Parent  := FOsStatusCard;
  updateProgressBar.Anchors := [akLeft, akTop];
  updateProgressBar.Visible := False;   // shown only during update
  updatestatusLabel.Parent  := FOsStatusCard;
  updatestatusLabel.Anchors := [akLeft, akTop];
  updatestatusLabel.Visible := False;   // shown only during update
  DarkLbl(updatestatusLabel, $AAAAAA);
  updatestatusLabel.Transparent := True;

  // Build dot + name + version rows for each library
  // Index: 0=OptiScaler  1=FakeNVAPI  2=FSR  3=XeSS  4=DLSS  5=OptiPatcher
  for i := 0 to 5 do
  begin
    Dot := TShape.Create(Self);
    Dot.Parent      := FOsStatusCard;
    Dot.Shape       := stEllipse;
    Dot.Brush.Color := $00888888;
    Dot.Pen.Style   := psClear;
    FOsStatDots[i]  := Dot;

    NLbl := TLabel.Create(Self);
    NLbl.Parent      := FOsStatusCard;
    NLbl.Caption     := STAT_NAMES[i];
    NLbl.Font.Color  := $AAAAAA;
    NLbl.Font.Size   := 9;
    NLbl.AutoSize    := True;
    NLbl.Transparent := True;
    FOsStatNameLbls[i] := NLbl;

    VLbl := TLabel.Create(Self);
    VLbl.Parent      := FOsStatusCard;
    VLbl.Caption     := '—';
    VLbl.Font.Color  := $BB99FF;
    VLbl.Font.Size   := 9;
    VLbl.AutoSize    := True;
    VLbl.Transparent := True;
    FOsStatVerLbls[i] := VLbl;
  end;

  // Populate initial version text from whatever FOptiscalerUpdate already loaded
  RefreshOsStatusDots;
end;

procedure Tgoverlayform.RefreshOsStatusDots;
// Syncs version text from the hidden source labels (written by FOptiscalerUpdate)
// into the visible FOsStatVerLbls, and colours FOsStatDots accordingly.
// For OptiScaler (i=0), also shows the new version tag from optLabel2 when
// an update was found (e.g. "0.9.0.0 → v0.9.5.0").
const
  CLR_OK     = $0044BB44;   // green — library found
  CLR_NONE   = $00666666;   // gray  — not installed
  PURPLE     = $BB99FF;
  CLR_UPDATE = $0044AAFF;   // blue highlight — update available
  PREFIX_LEN = Length('Update Available ');
var
  i: Integer;
  Ver, NewTag, VerCaption: string;
  SrcLbls: array[0..5] of TLabel;
begin
  if not Assigned(FOsStatDots[0]) then Exit;

  SrcLbls[0] := optlabel1;
  SrcLbls[1] := fakenvapi1;
  SrcLbls[2] := fsrLabel1;
  SrcLbls[3] := xessLabel1;
  SrcLbls[4] := dlssLabel1;
  SrcLbls[5] := optipatcherLabel1;

  for i := 0 to 5 do
  begin
    Ver := SrcLbls[i].Caption;
    VerCaption := IfThen(Ver <> '', Ver, '—');

    // For OptiScaler: if optLabel2 holds an update notification, append the new tag
    if (i = 0) and optLabel2.Visible and (optLabel2.Caption <> '') then
    begin
      NewTag := optLabel2.Caption;
      if Pos('Update Available ', NewTag) = 1 then
        NewTag := Copy(NewTag, PREFIX_LEN + 1, MaxInt);
      if NewTag <> '' then
      begin
        VerCaption := VerCaption + ' → ' + NewTag;
        FOsStatVerLbls[i].Caption    := VerCaption;
        FOsStatVerLbls[i].Font.Color := CLR_UPDATE;
        FOsStatDots[i].Brush.Color   := CLR_OK;
        Continue;
      end;
    end;

    FOsStatVerLbls[i].Caption    := VerCaption;
    FOsStatVerLbls[i].Font.Color := PURPLE;
    if (Ver <> '') and (Ver <> '—') and (Ver <> '--') then
      FOsStatDots[i].Brush.Color := CLR_OK
    else
      FOsStatDots[i].Brush.Color := CLR_NONE;
  end;
end;

procedure Tgoverlayform.ReflowOptiScalerTabNew(AContentW: Integer);
const
  MARGIN  = 8;    // outer margin inside scroll box
  GAP     = 6;    // gap between cards
  HDR     = 34;   // accent bar (3) + title area (31)
  PAD     = 14;   // inner horizontal padding
  // GroupBox heights
  GPU_GH  = 96;   // reduced from 130; controls centered within content area
  OPT_GH  = 265;  // trimmed: BOX_TOP(6)+BOX_H(251)+pad(8) — removes blank bottom area
  // Card heights
  GPU_H   = HDR + GPU_GH;    // 130
  OPT_H   = HDR + OPT_GH;    // 299
  // Status card — fresh indicator rows + update controls
  DOT_SZ    = 10;
  ROW_H     = 22;   // compact rows — saves 3×4=12px vs 26
  STAT_ROWS = 3;    // 3 rows × 2 columns = 6 items (OptiScaler/FakeNVAPI/FSR/XeSS/DLSS/OptiPatcher)
  CB_H      = 26;   // combo height
  BTN_H     = 32;   // update buttons height
  PB_H      = 16;   // progress bar height (overlaid on button row — only visible during update)
  // Layout: HDR + 6 + (button row / progress bar overlay) + 8 + dot grid + 8
  STAT_H    = HDR + 6 + BTN_H + 8 + STAT_ROWS * ROW_H + 8;
  // Inner 3-col layout constants (mirrors ReflowOptiScalerTab)
  W1      = 252;
  W3      = 252;
  MIN_W2  = 180;
  BOX_H   = 251;
  BOX_TOP = 6;
  IMARGIN = 4;
  IGAP    = 4;
var
  CW, CardTop, Y, Row, DotY, TotalH: Integer;
  ColX: array[0..1] of Integer;
  ColW, i, Col, RowIdx: Integer;
  InnerW, Center, W2, X1, X2, X3: Integer;
  ComboW, CheckW: Integer;
begin
  if not Assigned(FOsScrollBox) then Exit;
  CW := FOsScrollBox.ClientWidth - 2 * MARGIN;
  if CW < 100 then Exit;

  // Size the background panel to cover the full virtual content area,
  // but at least the full visible height of the scrollbox so the Qt6
  // viewport never shows through with the default palette colour.
  TotalH := MARGIN + GPU_H + GAP + OPT_H + GAP + STAT_H + MARGIN;
  if FOsScrollBox.ClientHeight > TotalH then
    TotalH := FOsScrollBox.ClientHeight;
  FOsBgPanel.SetBounds(0, 0, FOsScrollBox.ClientWidth, TotalH);

  // ── Card 0: GPU Driver ──────────────────────────────────────────────
  FOsGpuCard.SetBounds(MARGIN, MARGIN, CW, GPU_H);
  // Center controls vertically: mesaImage (62px) is tallest; block = 62+4+17 = 83px.
  // IMG_TOP = HDR + (GPU_GH - 83) / 2
  Y := HDR + (GPU_GH - 83) div 2;
  mesaImage.Top          := Y;
  nvidiaImage.Top        := Y + (62 - 43) div 2;
  mesaRadioButton.Top    := Y + (62 - 20) div 2;
  nvidiaRadioButton.Top  := Y + (62 - 20) div 2;
  autodetectmesaLabel.Top := Y + 62 + 4;
  autodetectnvLabel.Top   := Y + 62 + 4;

  // ── Card 1: Options ─────────────────────────────────────────────────
  CardTop := MARGIN + GPU_H + GAP;
  FOsOptionsCard.SetBounds(MARGIN, CardTop, CW, OPT_H);

  // Section panels are direct children of FOsOptionsCard (no GroupBox).
  // Y position = HDR (card header) + BOX_TOP (inner padding).
  InnerW := CW - 8;
  Center := InnerW div 2;
  W2     := Max(MIN_W2, InnerW - IMARGIN - W1 - IGAP - W3 - IMARGIN - IGAP);
  X2     := Center - W2 div 2;
  if X2 - IGAP - W1 < IMARGIN then
    X2 := IMARGIN + W1 + IGAP;
  X1 := X2 - IGAP - W1;
  X3 := X2 + W2 + IGAP;
  if Assigned(FOsOptiSec)  then FOsOptiSec.SetBounds(X1, HDR + BOX_TOP, W1, BOX_H);
  if Assigned(FOsImgSec)   then FOsImgSec.SetBounds(X2,  HDR + BOX_TOP, W2, BOX_H);
  if Assigned(FOsFakeSec)  then FOsFakeSec.SetBounds(X3, HDR + BOX_TOP, W3, BOX_H);

  // ── Card 2: Software Status ──────────────────────────────────────────
  // Layout order:
  //   1. Channel selector + buttons (top)
  //      Progress bar overlays the button row — only visible during update
  //   2. 2-column dot grid (OptiScaler/FakeNVAPI/FSR/XeSS/DLSS)
  CardTop := MARGIN + GPU_H + GAP + OPT_H + GAP;
  FOsStatusCard.SetBounds(MARGIN, CardTop, CW, STAT_H);

  // ── 1. Channel selector + button row ───────────────────────────────
  // Both checkupdBitBtn and updateBitBtn share the same slot (130px right-side).
  // They are mutually exclusive: one is hidden when the other is shown.
  CheckW := 130;
  ComboW := CW - 2 * PAD - 8 - CheckW;
  if ComboW < 80 then ComboW := 80;
  Y := HDR + 6;
  optversionComboBox.SetBounds(PAD, Y + (BTN_H - CB_H) div 2, ComboW, CB_H);
  checkupdBitBtn.SetBounds(PAD + ComboW + 8, Y, CheckW, BTN_H);
  updateBitBtn.SetBounds(PAD + ComboW + 8, Y, CheckW, BTN_H);   // same slot

  // Progress bar + status label overlay the button row (only shown during update)
  updateProgressBar.SetBounds(PAD, Y + (BTN_H - PB_H) div 2, ComboW, PB_H);
  updatestatusLabel.SetBounds(PAD + ComboW + 4, Y + (BTN_H - PB_H) div 2, CheckW + 4, PB_H);

  // ── 2. Dot indicator grid ────────────────────────────────────────────
  // 2-column, 3 rows:  OptiScaler/FakeNVAPI | FSR/XeSS | DLSS/(empty)
  Y := Y + BTN_H + 8;
  ColW    := (CW - 2 * PAD) div 2;
  ColX[0] := PAD;
  ColX[1] := PAD + ColW;

  for i := 0 to 5 do
  begin
    Col    := i mod 2;
    RowIdx := i div 2;
    Row    := Y + RowIdx * ROW_H;
    DotY   := Row + (ROW_H - DOT_SZ) div 2;

    FOsStatDots[i].SetBounds(ColX[Col], DotY, DOT_SZ, DOT_SZ);
    FOsStatNameLbls[i].Left := ColX[Col] + DOT_SZ + 6;
    FOsStatNameLbls[i].Top  := Row + (ROW_H - 16) div 2;
    FOsStatVerLbls[i].Left  := ColX[Col] + DOT_SZ + 6 + 80;
    FOsStatVerLbls[i].Top   := Row + (ROW_H - 16) div 2;
  end;
end;

// ============================================================================
// METRICS TAB — modern card redesign
// ============================================================================

procedure Tgoverlayform.InitMetricsTab;
// Fully code-driven layout: every control is reparented directly to its card
// TPanel (no TGroupBox involved).  The card's PerfCardPaint reliably fills
// CARD_BG everywhere, solving the Qt6 GroupBox background rendering issue.
const
  CARD_BG  = $002E1E1A;  // rgb(28, 33, 52) — Option B blue-gray
  OUTER_BG = $00281A16;  // navy bg
  WHITE    = clWhite;
  SECT_GPU = $66AAFF;
  SECT_CPU = $FFAA55;
  HDR      = 34;   // accent bar (3px) + title label area

  procedure MakeCard(out Card: TPanel; const ATitle: string);
  var
    Bar: TPanel;
    Lbl: TLabel;
  begin
    Card := TPanel.Create(Self);
    Card.Parent      := FMtBgPanel;
    Card.BevelOuter  := bvNone;
    Card.BorderStyle := bsNone;
    Card.Color       := CARD_BG;
    Card.Caption     := '';
    Card.OnPaint     := @PerfCardPaint;
    Bar := TPanel.Create(Card);
    Bar.Parent     := Card;
    Bar.BevelOuter := bvNone;
    Bar.Color      := RGBToColor(48, 190, 240);
    Bar.Caption    := '';
    Bar.SetBounds(0, 0, 400, 3);
    Bar.Anchors    := [akLeft, akRight, akTop];
    Lbl := TLabel.Create(Card);
    Lbl.Parent      := Card;
    Lbl.Caption     := ATitle;
    Lbl.Font.Color  := WHITE;
    Lbl.Font.Size   := 10;
    Lbl.Font.Style  := [fsBold];
    Lbl.AutoSize    := True;
    Lbl.SetBounds(12, 8, 200, 22);
    Lbl.Transparent := True;
  end;

  // Reparent a control directly to a card, clearing all anchor dependencies and
  // placing it at (ALeft, ATop) relative to the card.  All controls land directly
  // on the TPanel — no GroupBox in the hierarchy.
  procedure Place(C: TControl; Card: TPanel; ALeft, ATop: Integer);
  begin
    C.AnchorSideLeft.Control   := nil;
    C.AnchorSideTop.Control    := nil;
    C.AnchorSideRight.Control  := nil;
    C.AnchorSideBottom.Control := nil;
    C.Anchors  := [akLeft, akTop];
    C.Parent   := Card;
    C.Left     := ALeft;
    C.Top      := ATop;
  end;

  procedure DarkCheck(C: TCheckBox);
  begin
    C.ParentColor := False;
    C.Color       := CARD_BG;
    C.Font.Color  := WHITE;
    C.Font.Size   := 9;
  end;

  procedure DarkSectLbl(L: TLabel; AColor: TColor);
  begin
    L.Font.Color  := AColor;
    L.Font.Size   := 9;
    L.Font.Style  := [fsBold];
    L.Transparent := True;
  end;

begin
  // ── Scroll container fills the tab ──────────────────────────────────────
  FMtScrollBox := TScrollBox.Create(Self);
  FMtScrollBox.Parent      := metricsTabSheet;
  FMtScrollBox.Align       := alClient;
  FMtScrollBox.AutoScroll  := True;
  FMtScrollBox.BorderStyle := bsNone;
  FMtScrollBox.HorzScrollBar.Visible := False;
  FMtScrollBox.HorzScrollBar.Range   := 0;
  FMtScrollBox.Color       := RGBToColor(22, 26, 40);
  FMtScrollBox.ParentColor := False;

  FMtBgPanel := TPanel.Create(Self);
  FMtBgPanel.Parent     := FMtScrollBox;
  FMtBgPanel.BevelOuter := bvNone;
  FMtBgPanel.Color      := RGBToColor(22, 26, 40);
  FMtBgPanel.OnPaint    := @PresetsWrapperPaint;
  FMtBgPanel.Caption    := '';
  FMtBgPanel.Left       := 0;
  FMtBgPanel.Top        := 0;
  FMtBgPanel.Width      := FMtScrollBox.ClientWidth;
  FMtBgPanel.Height     := 600;

  // Hide the original GroupBoxes — they are no longer needed as containers.
  gpuGroupBox.Visible := False;
  cpuGroupBox.Visible := False;

  // ── Card 0: GPU Metrics ─────────────────────────────────────────────────
  // All Y values = LFM position + HDR (34) to offset below the card header.
  MakeCard(FMtGpuCard, 'GPU Metrics');

  // Name edit (centered in LFM at Left=285, Top=3)
  Place(gpunameEdit, FMtGpuCard, 285, 3 + HDR);
  gpunameEdit.Color      := CARD_BG;
  gpunameEdit.Font.Color := WHITE;
  gpunameEdit.Font.Size  := 9;

  // Main color bar (Left=281, Top=35)
  Place(gpuColorButton, FMtGpuCard, 281, 35 + HDR);
  gpuColorButton.Color := CARD_BG;

  // Section: Main metrics (label Top=56, controls Top=77/99)
  Place(mainmetricLabel,    FMtGpuCard, 11,  56 + HDR);
  Place(gpuavgloadCheckBox, FMtGpuCard, 11,  77 + HDR);
  Place(gpuloadcolorCheckBox,FMtGpuCard,120, 77 + HDR);
  Place(gpuload1ColorButton, FMtGpuCard,120, 99 + HDR);
  Place(gpuload2ColorButton, FMtGpuCard,150, 99 + HDR);
  Place(gpuload3ColorButton, FMtGpuCard,181, 99 + HDR);
  Place(vramusageCheckBox,  FMtGpuCard, 266, 77 + HDR);
  Place(vramColorButton,    FMtGpuCard, 264, 99 + HDR);
  Place(gpufreqCheckBox,    FMtGpuCard, 381, 77 + HDR);
  Place(gpumemfreqCheckBox, FMtGpuCard, 519, 77 + HDR);
  DarkSectLbl(mainmetricLabel, SECT_GPU);
  DarkCheck(gpuavgloadCheckBox);
  DarkCheck(gpuloadcolorCheckBox);
  DarkCheck(vramusageCheckBox);
  DarkCheck(gpufreqCheckBox);
  DarkCheck(gpumemfreqCheckBox);
  gpuload1ColorButton.Color := CARD_BG;
  gpuload2ColorButton.Color := CARD_BG;
  gpuload3ColorButton.Color := CARD_BG;
  vramColorButton.Color := CARD_BG;

  // Section: Temperature (label Top=113, controls Top=134)
  Place(gputempLabel,        FMtGpuCard, 11,  113 + HDR);
  Place(gputempCheckBox,     FMtGpuCard, 11,  134 + HDR);
  Place(gpumemtempCheckBox,  FMtGpuCard, 120, 134 + HDR);
  Place(gpujunctempCheckBox, FMtGpuCard, 266, 134 + HDR);
  Place(gpufanCheckBox,      FMtGpuCard, 381, 134 + HDR);
  DarkSectLbl(gputempLabel, SECT_GPU);
  DarkCheck(gputempCheckBox);
  DarkCheck(gpumemtempCheckBox);
  DarkCheck(gpujunctempCheckBox);
  DarkCheck(gpufanCheckBox);

  // Section: Power (label Top=170, controls Top=191/213)
  Place(gpupowerLabel,           FMtGpuCard, 11,  170 + HDR);
  Place(gpupowerCheckBox,        FMtGpuCard, 11,  191 + HDR);
  Place(gpuvoltageCheckBox,      FMtGpuCard, 120, 191 + HDR);
  Place(gputhrottlingCheckBox,   FMtGpuCard, 266, 191 + HDR);
  Place(gputhrottlinggraphCheckBox,FMtGpuCard,381,191 + HDR);
  Place(gpuefficiencyCheckBox,   FMtGpuCard, 519, 191 + HDR);
  Place(gpupowerlimitCheckBox,   FMtGpuCard, 611, 191 + HDR);
  Place(gpuframesjouleBitBtn,    FMtGpuCard, 516, 213 + HDR);
  DarkSectLbl(gpupowerLabel, SECT_GPU);
  DarkCheck(gpupowerCheckBox);
  DarkCheck(gpuvoltageCheckBox);
  DarkCheck(gputhrottlingCheckBox);
  DarkCheck(gputhrottlinggraphCheckBox);
  DarkCheck(gpuefficiencyCheckBox);
  DarkCheck(gpupowerlimitCheckBox);
  gpuframesjouleBitBtn.Font.Color := WHITE;

  // Section: Information (label Top=227, controls Top=248)
  Place(gpuinfoLabel,      FMtGpuCard, 11,  227 + HDR);
  Place(gpumodelCheckBox,  FMtGpuCard, 11,  248 + HDR);
  Place(vulkandriverCheckBox,FMtGpuCard,120, 248 + HDR);
  Place(procvramCheckBox,  FMtGpuCard, 266, 248 + HDR);
  DarkSectLbl(gpuinfoLabel, SECT_GPU);
  DarkCheck(gpumodelCheckBox);
  DarkCheck(vulkandriverCheckBox);
  DarkCheck(procvramCheckBox);

  // GPU image — right-anchored, positioned in ReflowMetricsTab
  gpuImage.AnchorSideLeft.Control   := nil;
  gpuImage.AnchorSideTop.Control    := nil;
  gpuImage.AnchorSideRight.Control  := nil;
  gpuImage.AnchorSideBottom.Control := nil;
  gpuImage.Anchors := [akLeft, akTop];
  gpuImage.Parent  := FMtGpuCard;
  gpuImage.Top     := 5 + HDR;

  // ── Card 1: CPU / Memory Metrics ────────────────────────────────────────
  MakeCard(FMtCpuCard, 'CPU / Memory Metrics');

  // Name edit (Left=285, Top=3)
  Place(cpunameEdit, FMtCpuCard, 285, 3 + HDR);
  cpunameEdit.Color      := CARD_BG;
  cpunameEdit.Font.Color := WHITE;
  cpunameEdit.Font.Size  := 9;

  // Main color bar (Left=281, Top=35)
  Place(cpuColorButton, FMtCpuCard, 281, 35 + HDR);
  cpuColorButton.Color := CARD_BG;

  // Section: Main metrics (label Top=45, controls Top=66/88)
  Place(cpumainmetricsLabel, FMtCpuCard, 11,  45 + HDR);
  Place(cpuavgloadCheckBox,  FMtCpuCard, 11,  66 + HDR);
  Place(cpuloadcolorCheckBox,FMtCpuCard, 120, 66 + HDR);
  Place(cpuload1ColorButton, FMtCpuCard, 120, 88 + HDR);
  Place(cpuload2ColorButton, FMtCpuCard, 150, 88 + HDR);
  Place(cpuload3ColorButton, FMtCpuCard, 181, 88 + HDR);
  Place(cpuloadcoreCheckBox, FMtCpuCard, 266, 66 + HDR);
  Place(coreloadtypeBitBtn,  FMtCpuCard, 264, 88 + HDR);
  Place(cpufreqCheckBox,     FMtCpuCard, 382, 66 + HDR);
  Place(cpucoretypeCheckBox, FMtCpuCard, 516, 66 + HDR);
  DarkSectLbl(cpumainmetricsLabel, SECT_CPU);
  DarkCheck(cpuavgloadCheckBox);
  DarkCheck(cpuloadcolorCheckBox);
  DarkCheck(cpuloadcoreCheckBox);
  DarkCheck(cpufreqCheckBox);
  DarkCheck(cpucoretypeCheckBox);
  cpuload1ColorButton.Color := CARD_BG;
  cpuload2ColorButton.Color := CARD_BG;
  cpuload3ColorButton.Color := CARD_BG;
  coreloadtypeBitBtn.Font.Color := WHITE;

  // Section: Temperature / Power (label Top=113, controls Top=134/156)
  Place(cputempLabel,      FMtCpuCard, 11,  113 + HDR);
  Place(cputempCheckBox,   FMtCpuCard, 11,  134 + HDR);
  Place(cpupowerCheckBox,  FMtCpuCard, 120, 134 + HDR);
  Place(intelpowerfixBitBtn,FMtCpuCard,213, 135 + HDR);
  Place(cpuefficiencyCheckBox,FMtCpuCard,266,134 + HDR);
  Place(ramtempCheckBox,   FMtCpuCard, 382, 134 + HDR);
  Place(cpuframesjouleBitBtn,FMtCpuCard,263,156 + HDR);
  DarkSectLbl(cputempLabel, SECT_CPU);
  DarkCheck(cputempCheckBox);
  DarkCheck(cpupowerCheckBox);
  DarkCheck(cpuefficiencyCheckBox);
  DarkCheck(ramtempCheckBox);
  cpuframesjouleBitBtn.Font.Color := WHITE;
  intelpowerfixBitBtn.Font.Color  := WHITE;

  // Section: Memory / IO (label Top=181, controls Top=202/224)
  Place(memLabel,          FMtCpuCard, 11,  181 + HDR);
  Place(ramusageCheckBox,  FMtCpuCard, 11,  202 + HDR);
  Place(diskioCheckBox,    FMtCpuCard, 120, 202 + HDR);
  Place(procmemCheckBox,   FMtCpuCard, 266, 202 + HDR);
  Place(swapusageCheckBox, FMtCpuCard, 382, 202 + HDR);
  Place(ramColorButton,    FMtCpuCard, 5,   224 + HDR);
  Place(iordrwColorButton, FMtCpuCard, 114, 224 + HDR);
  DarkSectLbl(memLabel, SECT_CPU);
  DarkCheck(ramusageCheckBox);
  DarkCheck(diskioCheckBox);
  DarkCheck(procmemCheckBox);
  DarkCheck(swapusageCheckBox);
  ramColorButton.Color    := CARD_BG;
  iordrwColorButton.Color := CARD_BG;

  // CPU image — right-anchored, positioned in ReflowMetricsTab
  cpuImage.AnchorSideLeft.Control   := nil;
  cpuImage.AnchorSideTop.Control    := nil;
  cpuImage.AnchorSideRight.Control  := nil;
  cpuImage.AnchorSideBottom.Control := nil;
  cpuImage.Anchors := [akLeft, akTop];
  cpuImage.Parent  := FMtCpuCard;
  cpuImage.Top     := 5 + HDR;
end;

procedure Tgoverlayform.ReflowMetricsTab(AContentW: Integer);
const
  MARGIN = 8;
  GAP    = 6;
  HDR    = 34;
  // Card heights: HDR + (LFM deepest control bottom + bottom padding)
  // GPU: procvramCheckBox bottom = 248+22=270 → +8 = 278 → GPU_H = 34+278 = 312
  // CPU: iordrwColorButton bottom = 224+15=239 → +8 = 247 → CPU_H = 34+247 = 281
  GPU_H = 312;
  CPU_H = 281;
var
  CW, TotalH, CardTop: Integer;
begin
  if not Assigned(FMtScrollBox) then Exit;
  CW := FMtScrollBox.ClientWidth - 2 * MARGIN;
  if CW < 100 then Exit;

  FMtScrollBox.HorzScrollBar.Range := 0;

  TotalH := MARGIN + GPU_H + GAP + CPU_H + MARGIN;
  if FMtScrollBox.ClientHeight > TotalH then
    TotalH := FMtScrollBox.ClientHeight;
  FMtBgPanel.SetBounds(0, 0, FMtScrollBox.ClientWidth, TotalH);

  // GPU card
  FMtGpuCard.SetBounds(MARGIN, MARGIN, CW, GPU_H);
  // GPU image: right-aligned, 5px from right edge, same top as LFM (5+HDR)
  gpuImage.Left := CW - gpuImage.Width - 5;

  // CPU card
  CardTop := MARGIN + GPU_H + GAP;
  FMtCpuCard.SetBounds(MARGIN, CardTop, CW, CPU_H);
  // CPU image: right-aligned
  cpuImage.Left := CW - cpuImage.Width - 5;
end;

procedure Tgoverlayform.ReflowExtrasTab(AContentW: Integer);
const
  MARGIN = 8;
  GAP    = 6;
  HDR    = 34;
  // Card height = HDR + LFM ClientHeight + bottom padding
  SYS_H  = HDR + 335 + 8;  // 377  (systemGroupBox ClientHeight=335)
  LOG_H  = HDR + 179 + 8;  // 221  (loggingGroupBox ClientHeight=179)
var
  CW, TotalH: Integer;
begin
  if not Assigned(FExtScrollBox) then Exit;
  CW := AContentW - 2 * MARGIN;
  if CW < 100 then Exit;

  FExtScrollBox.HorzScrollBar.Range := 0;

  TotalH := MARGIN + SYS_H + GAP + LOG_H + MARGIN;
  if FExtScrollBox.ClientHeight > TotalH then
    TotalH := FExtScrollBox.ClientHeight;
  FExtBgPanel.SetBounds(0, 0, AContentW, TotalH);

  FExtSysCard.SetBounds(MARGIN, MARGIN, CW, SYS_H);
  sysinfoImage.Left := CW - sysinfoImage.Width - 4;
  sysinfoImage.Top  := 5;

  FExtLogCard.SetBounds(MARGIN, MARGIN + SYS_H + GAP, CW, LOG_H);
  Image2.Left := CW - Image2.Width - 4;
  Image2.Top  := 5;
end;

// ============================================================================
// VKBASALT TAB — modern redesign
// ============================================================================

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
const
  BG        = $002E1E1A;  // rgb(26,30,46) — matches other tabs
  ACCENT    = $00F0BE30;  // rgb(48,190,240) — cyan accent
  CLR_WHITE = clWhite;
var
  AccentBar: TPanel;
  TitleLbl:  TLabel;
begin
  // ── Hide the old LFM group boxes (functional children are reparented below)
  reshadeGroupBox.Visible        := False;
  builtineffectsGroupBox.Visible := False;
  vktoggleLabel.Visible          := False;
  toggleImage.Visible            := False;

  // ══════════════════════════════════════════════════════════════════════════
  // CARD 1 — Reshade Effects
  // ══════════════════════════════════════════════════════════════════════════
  FVkReshadeCard := TPanel.Create(Self);
  FVkReshadeCard.Parent     := vkbasaltTabSheet;
  FVkReshadeCard.BevelOuter := bvNone;
  FVkReshadeCard.Color      := BG;
  FVkReshadeCard.Caption    := '';
  FVkReshadeCard.OnPaint    := @PerfCardPaint;

  AccentBar := TPanel.Create(FVkReshadeCard);
  AccentBar.Parent     := FVkReshadeCard;
  AccentBar.BevelOuter := bvNone;
  AccentBar.Color      := ACCENT;
  AccentBar.Caption    := '';
  AccentBar.SetBounds(0, 0, 200, 3);
  AccentBar.Anchors := [akLeft, akRight, akTop];

  TitleLbl := TLabel.Create(FVkReshadeCard);
  TitleLbl.Parent      := FVkReshadeCard;
  TitleLbl.Caption     := '  Reshade Effects';
  TitleLbl.Font.Name   := 'Noto Sans';
  TitleLbl.Font.Size   := 10;
  TitleLbl.Font.Style  := [fsBold];
  TitleLbl.Font.Color  := CLR_WHITE;
  TitleLbl.AutoSize    := True;
  TitleLbl.SetBounds(12, 12, 200, 22);
  TitleLbl.Transparent := True;

  FVkAvHdrLbl := TLabel.Create(FVkReshadeCard);
  FVkAvHdrLbl.Parent      := FVkReshadeCard;
  FVkAvHdrLbl.Caption     := 'Available Effects';
  FVkAvHdrLbl.Font.Name   := 'Noto Sans';
  FVkAvHdrLbl.Font.Size   := 8;
  FVkAvHdrLbl.Font.Style  := [fsBold];
  FVkAvHdrLbl.Font.Color  := $BB99FF;
  FVkAvHdrLbl.AutoSize    := True;
  FVkAvHdrLbl.SetBounds(12, 40, 120, 16);
  FVkAvHdrLbl.Transparent := True;

  FVkActHdrLbl := TLabel.Create(FVkReshadeCard);
  FVkActHdrLbl.Parent      := FVkReshadeCard;
  FVkActHdrLbl.Caption     := 'Active Effects';
  FVkActHdrLbl.Font.Name   := 'Noto Sans';
  FVkActHdrLbl.Font.Size   := 8;
  FVkActHdrLbl.Font.Style  := [fsBold];
  FVkActHdrLbl.Font.Color  := $FFCC66;
  FVkActHdrLbl.AutoSize    := True;
  FVkActHdrLbl.SetBounds(12, 40, 100, 16);
  FVkActHdrLbl.Transparent := True;

  // Reparent + style Available listbox
  aveffectsListBox.Parent      := FVkReshadeCard;
  aveffectsListBox.Anchors     := [akLeft, akTop];
  aveffectsListBox.Color       := $12121E;
  aveffectsListBox.Font.Color  := CLR_WHITE;
  aveffectsListBox.Font.Size   := 9;
  aveffectsListBox.Visible     := True;

  // Reparent + style Active listbox
  acteffectsListBox.Parent     := FVkReshadeCard;
  acteffectsListBox.Anchors    := [akLeft, akTop];
  acteffectsListBox.Color      := $12121E;
  acteffectsListBox.Font.Color := $FFCC66;
  acteffectsListBox.Font.Size  := 9;
  acteffectsListBox.Visible    := True;

  // Reparent +/- buttons
  addBitBtn.Parent  := FVkReshadeCard;
  addBitBtn.Anchors := [akLeft, akTop];
  addBitBtn.Visible := True;
  subBitBtn.Parent  := FVkReshadeCard;
  subBitBtn.Anchors := [akLeft, akTop];
  subBitBtn.Visible := True;

  // Reparent Update button
  reshaderefreshBitBtn.Parent  := FVkReshadeCard;
  reshaderefreshBitBtn.Anchors := [akLeft, akTop];
  reshaderefreshBitBtn.Visible := True;

  // ══════════════════════════════════════════════════════════════════════════
  // CARD 2 — Built-in Effects
  // ══════════════════════════════════════════════════════════════════════════
  FVkBuiltinCard := TPanel.Create(Self);
  FVkBuiltinCard.Parent     := vkbasaltTabSheet;
  FVkBuiltinCard.BevelOuter := bvNone;
  FVkBuiltinCard.Color      := BG;
  FVkBuiltinCard.Caption    := '';
  FVkBuiltinCard.OnPaint    := @PerfCardPaint;

  AccentBar := TPanel.Create(FVkBuiltinCard);
  AccentBar.Parent     := FVkBuiltinCard;
  AccentBar.BevelOuter := bvNone;
  AccentBar.Color      := ACCENT;
  AccentBar.Caption    := '';
  AccentBar.SetBounds(0, 0, 200, 3);
  AccentBar.Anchors := [akLeft, akRight, akTop];

  TitleLbl := TLabel.Create(FVkBuiltinCard);
  TitleLbl.Parent      := FVkBuiltinCard;
  TitleLbl.Caption     := '  Built-in Effects';
  TitleLbl.Font.Name   := 'Noto Sans';
  TitleLbl.Font.Size   := 10;
  TitleLbl.Font.Style  := [fsBold];
  TitleLbl.Font.Color  := CLR_WHITE;
  TitleLbl.AutoSize    := True;
  TitleLbl.SetBounds(12, 12, 200, 22);
  TitleLbl.Transparent := True;

  // Reparent trackbars + name labels; hide old value labels (replaced below)
  casTrackBar.Parent  := FVkBuiltinCard; casTrackBar.Anchors := [akLeft, akTop]; casTrackBar.Visible := True;
  fxaaTrackBar.Parent := FVkBuiltinCard; fxaaTrackBar.Anchors := [akLeft, akTop]; fxaaTrackBar.Visible := True;
  smaaTrackBar.Parent := FVkBuiltinCard; smaaTrackBar.Anchors := [akLeft, akTop]; smaaTrackBar.Visible := True;
  dlsTrackBar.Parent  := FVkBuiltinCard; dlsTrackBar.Anchors  := [akLeft, akTop]; dlsTrackBar.Visible  := True;

  casLabel.Parent  := FVkBuiltinCard; casLabel.Anchors  := [akLeft, akTop];
  casLabel.Font.Color := $BB99FF; casLabel.Font.Style := [fsBold]; casLabel.Font.Size := 9;
  casLabel.Color := BG; casLabel.Visible := True;

  fxaaLabel.Parent := FVkBuiltinCard; fxaaLabel.Anchors := [akLeft, akTop];
  fxaaLabel.Font.Color := $BB99FF; fxaaLabel.Font.Style := [fsBold]; fxaaLabel.Font.Size := 9;
  fxaaLabel.Color := BG; fxaaLabel.Visible := True;

  smaaLabel.Parent := FVkBuiltinCard; smaaLabel.Anchors := [akLeft, akTop];
  smaaLabel.Font.Color := $BB99FF; smaaLabel.Font.Style := [fsBold]; smaaLabel.Font.Size := 9;
  smaaLabel.Color := BG; smaaLabel.Visible := True;

  dlsLabel.Parent  := FVkBuiltinCard; dlsLabel.Anchors  := [akLeft, akTop];
  dlsLabel.Font.Color := $BB99FF; dlsLabel.Font.Style := [fsBold]; dlsLabel.Font.Size := 9;
  dlsLabel.Color := BG; dlsLabel.Visible := True;

  // Fresh value labels — created here to avoid any LFM inheritance issues
  FVkCasValLbl := TLabel.Create(Self);
  FVkCasValLbl.Parent := FVkBuiltinCard;
  FVkCasValLbl.Caption := casvalueLabel.Caption;
  FVkCasValLbl.Font.Color := CLR_WHITE; FVkCasValLbl.Font.Size := 9;
  FVkCasValLbl.Color := BG; FVkCasValLbl.Anchors := [akLeft, akTop];

  FVkFxaaValLbl := TLabel.Create(Self);
  FVkFxaaValLbl.Parent := FVkBuiltinCard;
  FVkFxaaValLbl.Caption := fxaavalueLabel.Caption;
  FVkFxaaValLbl.Font.Color := CLR_WHITE; FVkFxaaValLbl.Font.Size := 9;
  FVkFxaaValLbl.Color := BG; FVkFxaaValLbl.Anchors := [akLeft, akTop];

  FVkSmaaValLbl := TLabel.Create(Self);
  FVkSmaaValLbl.Parent := FVkBuiltinCard;
  FVkSmaaValLbl.Caption := smaavalueLabel.Caption;
  FVkSmaaValLbl.Font.Color := CLR_WHITE; FVkSmaaValLbl.Font.Size := 9;
  FVkSmaaValLbl.Color := BG; FVkSmaaValLbl.Anchors := [akLeft, akTop];

  FVkDlsValLbl := TLabel.Create(Self);
  FVkDlsValLbl.Parent := FVkBuiltinCard;
  FVkDlsValLbl.Caption := dlsvalueLabel.Caption;
  FVkDlsValLbl.Font.Color := CLR_WHITE; FVkDlsValLbl.Font.Size := 9;
  FVkDlsValLbl.Color := BG; FVkDlsValLbl.Anchors := [akLeft, akTop];

  // ══════════════════════════════════════════════════════════════════════════
  // CARD 3 — Toggle Key
  // ══════════════════════════════════════════════════════════════════════════
  FVkToggleCard := TPanel.Create(Self);
  FVkToggleCard.Parent     := vkbasaltTabSheet;
  FVkToggleCard.BevelOuter := bvNone;
  FVkToggleCard.Color      := BG;
  FVkToggleCard.Caption    := '';
  FVkToggleCard.OnPaint    := @PerfCardPaint;

  AccentBar := TPanel.Create(FVkToggleCard);
  AccentBar.Parent     := FVkToggleCard;
  AccentBar.BevelOuter := bvNone;
  AccentBar.Color      := ACCENT;
  AccentBar.Caption    := '';
  AccentBar.SetBounds(0, 0, 200, 3);
  AccentBar.Anchors := [akLeft, akRight, akTop];

  TitleLbl := TLabel.Create(FVkToggleCard);
  TitleLbl.Parent      := FVkToggleCard;
  TitleLbl.Caption     := '  vkBasalt Toggle Key';
  TitleLbl.Font.Name   := 'Noto Sans';
  TitleLbl.Font.Size   := 10;
  TitleLbl.Font.Style  := [fsBold];
  TitleLbl.Font.Color  := CLR_WHITE;
  TitleLbl.AutoSize    := True;
  TitleLbl.SetBounds(12, 8, 200, 22);
  TitleLbl.Transparent := True;

  // Reparent combobox off the vkbasalt tab (hidden data store)
  vkbtogglekeyCombobox.Visible := False;
  vkbtogglekeyCombobox.Parent  := Self;
  if vkbtogglekeyCombobox.Text = '' then
    vkbtogglekeyCombobox.Text := 'Home';

  FVkToggleCaptureBtn := TBitBtn.Create(FVkToggleCard);
  FVkToggleCaptureBtn.Parent   := FVkToggleCard;
  FVkToggleCaptureBtn.Tag      := 4;
  FVkToggleCaptureBtn.Anchors  := [akLeft, akTop];
  FVkToggleCaptureBtn.Cursor   := crHandPoint;
  FVkToggleCaptureBtn.OnClick  := @CaptureBtnClick;
  FVkToggleCaptureBtn.Caption  := '⌨ ' + vkbtogglekeyCombobox.Text;
end;

procedure Tgoverlayform.ReflowVkBasaltTab(AContentW: Integer);
const
  MARGIN   = 10;   // outer margin each side
  GAP      = 8;    // gap between cards
  RSHD_H   = 308;  // reshade card height
  BTIN_H   = 170;  // built-in effects card height
  TOGL_H   = 70;   // toggle key card height
  HDR_Y    = 42;   // Y where list/content starts inside card
  PAD      = 12;   // inner horizontal padding
  BTN_COL  = 36;   // width of +/- button column
  UPD_W    = 90;   // Update button width
  NAME_W   = 52;   // effect name label width
  VAL_W    = 32;   // value label width
var
  CW:      Integer;
  ListW:   Integer;
  ListH:   Integer;
  BtnX:    Integer;
  AvX:     Integer;
  ActX:    Integer;
  InnerW:  Integer;
  ColW:    Integer;
  TrkW:    Integer;
  Col0:    Integer;
  Col1:    Integer;
  Row0:    Integer;
  Row1:    Integer;
begin
  if not Assigned(FVkReshadeCard) then Exit;

  CW := AContentW - 2 * MARGIN;

  // ── Card 1: Reshade ────────────────────────────────────────────────────
  FVkReshadeCard.SetBounds(MARGIN, MARGIN, CW, RSHD_H);

  // Update button on the left, below title
  reshaderefreshBitBtn.SetBounds(PAD, HDR_Y, UPD_W, 56);

  // Listbox layout: [UpdateBtn gap] [AvList] [+/-] [ActList] [pad]
  AvX   := PAD + UPD_W + PAD;
  ListH := RSHD_H - HDR_Y - PAD;
  // Split remaining width evenly around the +/- column
  InnerW := CW - AvX - PAD;
  ListW  := (InnerW - BTN_COL - PAD) div 2;
  BtnX   := AvX + ListW + PAD div 2;
  ActX   := BtnX + BTN_COL;

  FVkAvHdrLbl.Left  := AvX;
  FVkActHdrLbl.Left := ActX;

  aveffectsListBox.SetBounds(AvX,  HDR_Y, ListW, ListH);
  acteffectsListBox.SetBounds(ActX, HDR_Y, CW - ActX - PAD, ListH);

  addBitBtn.SetBounds(BtnX, HDR_Y + ListH div 2 - 34, 28, 28);
  subBitBtn.SetBounds(BtnX, HDR_Y + ListH div 2 + 4,  28, 28);

  // ── Card 2: Built-in Effects ───────────────────────────────────────────
  // Layout per column:
  //   [Name label .............. value]   ← header row
  //   [==========trackbar===========]    ← slider full-width
  FVkBuiltinCard.SetBounds(MARGIN, MARGIN + RSHD_H + GAP, CW, BTIN_H);

  ColW  := (CW - 3 * PAD) div 2;
  Col0  := PAD;
  Col1  := PAD + ColW + PAD;
  Row0  := HDR_Y;           // label/value header row
  Row1  := Row0 + 20 + 4;  // trackbar row

  // CAS / FXAA (row 0)
  casLabel.SetBounds(Col0, Row0, ColW - VAL_W - 4, 20);
  if Assigned(FVkCasValLbl)  then FVkCasValLbl.SetBounds(Col0 + ColW - VAL_W, Row0, VAL_W, 20);
  casTrackBar.SetBounds(Col0, Row1, ColW, 28);

  fxaaLabel.SetBounds(Col1, Row0, ColW - VAL_W - 4, 20);
  if Assigned(FVkFxaaValLbl) then FVkFxaaValLbl.SetBounds(Col1 + ColW - VAL_W, Row0, VAL_W, 20);
  fxaaTrackBar.SetBounds(Col1, Row1, ColW, 28);

  // SMAA / DLS (row 1)
  Row0 := Row1 + 28 + 14;
  Row1 := Row0 + 20 + 4;

  smaaLabel.SetBounds(Col0, Row0, ColW - VAL_W - 4, 20);
  if Assigned(FVkSmaaValLbl) then FVkSmaaValLbl.SetBounds(Col0 + ColW - VAL_W, Row0, VAL_W, 20);
  smaaTrackBar.SetBounds(Col0, Row1, ColW, 28);

  dlsLabel.SetBounds(Col1, Row0, ColW - VAL_W - 4, 20);
  if Assigned(FVkDlsValLbl)  then FVkDlsValLbl.SetBounds(Col1 + ColW - VAL_W, Row0, VAL_W, 20);
  dlsTrackBar.SetBounds(Col1, Row1, ColW, 28);

  // ── Card 3: Toggle Key ─────────────────────────────────────────────────
  FVkToggleCard.SetBounds(MARGIN, MARGIN + RSHD_H + GAP + BTIN_H + GAP, CW, TOGL_H);

  if Assigned(FVkToggleCaptureBtn) then
    FVkToggleCaptureBtn.SetBounds(PAD, 36, 130, 28);
end;

// ============================================================================
// GAMES TAB — Steam installed games grid
// ============================================================================

procedure Tgoverlayform.InitGamesTab;
var
  OpenFolderItem: TMenuItem;
  OpenPrefixItem: TMenuItem;
  UninstallItem: TMenuItem;
  GamesBgPB: TPaintBox;
  IconPath: string;
begin
  FCardPanels := TList.Create;
  FOrigCovers := TList.Create;

  // Right-click context menu for game cards
  FGameCardMenu := TPopupMenu.Create(Self);
  OpenFolderItem := TMenuItem.Create(FGameCardMenu);
  OpenFolderItem.Caption := 'Open install folder';
  OpenFolderItem.OnClick := @GameCardOpenFolderClick;
  FGameCardMenu.Items.Add(OpenFolderItem);

  OpenPrefixItem := TMenuItem.Create(FGameCardMenu);
  OpenPrefixItem.Caption := 'Open prefix folder';
  OpenPrefixItem.OnClick := @GameCardOpenPrefixClick;
  FGameCardMenu.Items.Add(OpenPrefixItem);

  UninstallItem := TMenuItem.Create(FGameCardMenu);
  UninstallItem.Caption := 'Uninstall changes';
  UninstallItem.OnClick := @GameCardUninstallClick;
  FGameCardMenu.Items.Add(UninstallItem);

  FGamesScrollBox := TScrollBox.Create(Self);
  FGamesScrollBox.Parent := gamesTabSheet;
  FGamesScrollBox.Align := alClient;
  FGamesScrollBox.AutoScroll := True;
  FGamesScrollBox.BorderStyle := bsNone;
  FGamesScrollBox.HorzScrollBar.Visible := False;
  FGamesScrollBox.Color := RGBToColor(22, 26, 40);
  FGamesScrollBox.ParentColor := False;
  FGamesScrollBox.OnResize := @GamesScrollBoxResize;

  // Navy background paintbox — created before FGamesPanel so it sits behind the cards
  GamesBgPB := TPaintBox.Create(Self);
  GamesBgPB.Parent  := FGamesScrollBox;
  GamesBgPB.Align   := alClient;
  GamesBgPB.OnPaint := @PresetsBgBoxPaint;

  FGamesPanel := TPanel.Create(Self);
  FGamesPanel.Parent := FGamesScrollBox;
  FGamesPanel.Caption := '';
  FGamesPanel.BevelOuter := bvNone;
  FGamesPanel.Color := RGBToColor(22, 26, 40);
  FGamesPanel.Left := 0;
  FGamesPanel.Top := 0;
  FGamesPanel.Width := 800;
  FGamesPanel.Height := 100;
  FGamesPanel.OnPaint := @PresetsWrapperPaint;
  FGamesPanel.OnClick := @GamesEmptySpaceClick;
  FGamesScrollBox.OnClick := @GamesEmptySpaceClick;

  // Cache badge icons for corner ribbon (loaded once, reused per card)
  FMangoIconGfx := TPortableNetworkGraphic.Create;
  IconPath := ExtractFilePath(Application.ExeName) + 'assets/icons/mango-active.png';
  if FileExists(IconPath) then try FMangoIconGfx.LoadFromFile(IconPath); except end;

  FOptiIconGfx := TPortableNetworkGraphic.Create;
  IconPath := ExtractFilePath(Application.ExeName) + 'assets/icons/scale-up2-active.png';
  if FileExists(IconPath) then try FOptiIconGfx.LoadFromFile(IconPath); except end;

  // Navy background for the bottom bar
  goverlaybarPanel.OnPaint := @PresetsWrapperPaint;

  // Quick preview button — icon-only, sits immediately left of popupBitBtn.
  FPreviewBtn := TBitBtn.Create(Self);
  FPreviewBtn.Parent      := goverlaybarPanel;
  // Align height (30) and vertical position (5) with the rest of the bar
  FPreviewBtn.SetBounds(684, 5, 28, 30);
  FPreviewBtn.Anchors     := [akRight, akBottom];
  FPreviewBtn.Caption     := '▶';
  FPreviewBtn.Color       := $00445566;
  FPreviewBtn.Font.Color  := clWhite;
  FPreviewBtn.Font.Size   := 10;
  FPreviewBtn.Font.Style  := [fsBold];
  FPreviewBtn.Font.Name   := 'Noto Sans';
  FPreviewBtn.Hint        := 'Launch a quick preview cube (pascube / vkcube)';
  FPreviewBtn.ShowHint    := True;
  FPreviewBtn.OnClick     := @PreviewBtnClick;

  // Re-anchor commandPanel so it stops at the left edge of FPreviewBtn,
  // preventing the panel from drawing over the preview button.
  commandPanel.AnchorSideRight.Control := FPreviewBtn;
  commandPanel.AnchorSideRight.Side    := asrLeft;

  // Informative hint for the launch-command box
  commandPanel.Hint := 'Copy this command and paste it into the game''s Launch Options in Steam.';
  commandPanel.ShowHint := True;

end;

procedure Tgoverlayform.GetSteamLibraries(Libraries: TStringList);
var
  HomeDir, VdfPath, LibPath, Line: string;
  VdfFile: TStringList;
  i, p1, p2, p3, p4: Integer;
begin
  HomeDir := GetEnvironmentVariable('HOME');

  LibPath := HomeDir + '/.local/share/Steam/steamapps';
  if DirectoryExists(LibPath) then
    Libraries.Add(LibPath);

  // Flatpak Steam
  LibPath := HomeDir + '/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps';
  if DirectoryExists(LibPath) and (Libraries.IndexOf(LibPath) < 0) then
    Libraries.Add(LibPath);

  // Parse libraryfolders.vdf for additional library paths
  VdfPath := HomeDir + '/.local/share/Steam/steamapps/libraryfolders.vdf';
  if not FileExists(VdfPath) then
    VdfPath := HomeDir + '/.steam/steam/steamapps/libraryfolders.vdf';
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
          if DirectoryExists(LibPath) and (Libraries.IndexOf(LibPath) < 0) then
            Libraries.Add(LibPath);
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

procedure ProcessCoverBitmap(Bmp: TBitmap; GradH: Integer);
var
  IntfImg: TLazIntfImage;
  ResultBmp: TBitmap;
  Stride, BPP, W, H: Integer;
  Row: PByte;
  x, y, px, DimPct, Bright: Integer;
begin
  W := Bmp.Width;
  H := Bmp.Height;
  if (W = 0) or (H = 0) then Exit;
  IntfImg := TLazIntfImage.Create(W, H);
  try
    IntfImg.LoadFromBitmap(Bmp.Handle, 0);
    Stride := IntfImg.DataDescription.BytesPerLine;
    BPP    := IntfImg.DataDescription.BitsPerPixel div 8;
    if BPP < 3 then Exit;

    for y := 0 to H - 1 do
    begin
      if y < H - GradH then Continue;
      DimPct := Round((y - (H - GradH)) / GradH * 88);
      if DimPct <= 0 then Continue;
      Row := IntfImg.PixelData + PtrUInt(y * Stride);
      for x := 0 to W - 1 do
      begin
        px := x * BPP;
        Row[px]   := Byte(Integer(Row[px])   * (100 - DimPct) div 100);
        Row[px+1] := Byte(Integer(Row[px+1]) * (100 - DimPct) div 100);
        Row[px+2] := Byte(Integer(Row[px+2]) * (100 - DimPct) div 100);
      end;
    end;

    ResultBmp := TBitmap.Create;
    try
      ResultBmp.LoadFromIntfImage(IntfImg);
      Bmp.Assign(ResultBmp);
    finally
      ResultBmp.Free;
    end;
  finally
    IntfImg.Free;
  end;
end;

procedure Tgoverlayform.DrawCardRibbon(Bmp: TBitmap; BadgeMask: Integer);
const
  // Nerd Font glyphs — same as nav rail (rendered via 'Noto Sans' on this system)
  GLYPHS: array[0..3] of string = ('󱁥', '󰏘', '󰋮', '⚙');
  ICN_SZ  = 16;  // icon cell size
  ICN_GAP = 6;   // vertical gap between icons
  PAD_R   = 6;   // right margin from card edge
  PAD_T   = 5;   // top margin from card edge
  FONT_SZ = 13;  // glyph font size
var
  BC: TCanvas;
  BitIdx, Slot, IcoX, IcoY, DX, DY: Integer;
  G: string;
begin
  BC := Bmp.Canvas;
  BC.Font.Name  := 'Noto Sans';
  BC.Font.Size  := FONT_SZ;
  BC.Font.Style := [];
  BC.Brush.Style := bsClear;

  IcoX := CARD_W - ICN_SZ - PAD_R;

  Slot := 0;
  for BitIdx := 0 to 3 do
  begin
    if (BadgeMask and (1 shl BitIdx)) = 0 then Continue;
    G    := GLYPHS[BitIdx];
    IcoY := PAD_T + Slot * (ICN_SZ + ICN_GAP);

    // Drop shadow (+2 offset, black)
    BC.Font.Color := clBlack;
    BC.TextOut(IcoX + 2, IcoY + 2, G);

    // 1px black outline — 8 directions
    for DX := -1 to 1 do
      for DY := -1 to 1 do
        if (DX <> 0) or (DY <> 0) then
          BC.TextOut(IcoX + DX, IcoY + DY, G);

    // White icon on top
    BC.Font.Color := clWhite;
    BC.TextOut(IcoX, IcoY, G);

    Inc(Slot);
  end;
end;

procedure Tgoverlayform.LoadSteamGames;
const
  // bit0=Mango(PNG), bit1=vkBasalt(glyph), bit2=OptiScaler(PNG), bit3=Tweaks(glyph)
  BADGE_GLYPHS: array[0..3] of string = ('', '󰏘', '', '󰒓');
  BDG_SZ    = 18;   // icon cell size
  BDG_GAP   = 5;    // vertical gap between icons
  BDG_PAD_V = 6;    // top/bottom padding inside strip
  BDG_FONT  = 13;   // glyph font size
  BDG_W     = 26;   // strip width (right edge)
var
  Libraries: TStringList;
  PendingIDs: TStringList;
  PendingImages: TList;
  CacheDir: string;
  i, j, CardX, CardY, CardsPerRow, TotalRows, RowMargin: Integer;
  LibPath, AcfContent, AppID, GameName, ImagePath, HomeDir, InstallDir, IconPath: string;
  SR: TSearchRec;
  AcfFile: TStringList;
  CardPanel: TPanel;
  CardImage: TImage;
  BdgLbl: TLabel;
  BdgImg: TImage;
  BdgBg:  TShape;
  NoGamesLabel: TLabel;
  LowerName, GameCfgDir: string;
  ScaledBmp: TBitmap;
  HasMango, HasVkBasalt, HasOptiScaler, HasTweaks: Boolean;
  TweakLines: TStringList;
  k, BadgeCount, BdgBit, BdgSlot, BdgX, BdgY: Integer;
begin
  if not Assigned(FGamesScrollBox) or not Assigned(FGamesPanel) then
    Exit;

  HomeDir  := GetEnvironmentVariable('HOME');
  CacheDir := HomeDir + '/.cache/goverlay/covers/';
  ForceDirectories(CacheDir);

  Libraries     := TStringList.Create;
  PendingIDs    := TStringList.Create;
  PendingImages := TList.Create;
  try
    GetSteamLibraries(Libraries);

    if Libraries.Count = 0 then
    begin
      NoGamesLabel := TLabel.Create(Self);
      NoGamesLabel.Parent := FGamesPanel;
      NoGamesLabel.Caption := 'Steam not found or no libraries detected.';
      NoGamesLabel.Font.Color := clSilver;
      NoGamesLabel.Font.Size := 10;
      NoGamesLabel.Left := 16;
      NoGamesLabel.Top := 16;
      Exit;
    end;

    CardsPerRow := Max(1, FGamesScrollBox.Width div (CARD_W + CARD_MARGIN));
    RowMargin := (FGamesScrollBox.Width - CardsPerRow * CARD_W) div (CardsPerRow + 1);
    if RowMargin < 4 then RowMargin := 4;
    j := 0;

    for i := 0 to Libraries.Count - 1 do
    begin
      LibPath := Libraries[i];
      if FindFirst(LibPath + '/appmanifest_*.acf', faAnyFile, SR) = 0 then
      begin
        repeat
          AcfFile := TStringList.Create;
          try
            AcfFile.LoadFromFile(LibPath + '/' + SR.Name);
            AcfContent := AcfFile.Text;
          finally
            AcfFile.Free;
          end;

          AppID      := ParseAcfValue(AcfContent, 'appid');
          GameName   := ParseAcfValue(AcfContent, 'name');
          InstallDir := ParseAcfValue(AcfContent, 'installdir');
          if (AppID = '') or (GameName = '') then
            Continue;

          // Skip non-game Steam entries (runtimes, tools, redistributables)
          LowerName := LowerCase(GameName);
          if (Pos('proton', LowerName) > 0) or
             (Pos('steamworks', LowerName) > 0) or
             (Pos('steam linux runtime', LowerName) > 0) or
             (Pos('redistributable', LowerName) > 0) or
             (Pos('steam sdk', LowerName) > 0) then
            Continue;

          // Look for local cover; if absent, queue for CDN download
          ImagePath := HomeDir + '/.local/share/Steam/appcache/librarycache/' + AppID + '/library_600x900.jpg';
          if not FileExists(ImagePath) then
            ImagePath := HomeDir + '/.local/share/Steam/appcache/librarycache/' + AppID + '/header.jpg';
          if not FileExists(ImagePath) then
            ImagePath := HomeDir + '/.var/app/com.valvesoftware.Steam/.local/share/Steam/appcache/librarycache/' + AppID + '/library_600x900.jpg';
          if not FileExists(ImagePath) then
            ImagePath := HomeDir + '/.var/app/com.valvesoftware.Steam/.local/share/Steam/appcache/librarycache/' + AppID + '/header.jpg';
          // Also check the persistent cache from previous downloads
          if not FileExists(ImagePath) then
            ImagePath := CacheDir + AppID + '.jpg';

          // Card position (dynamic margin distributes leftover space evenly)
          CardX := RowMargin + (j mod CardsPerRow) * (CARD_W + RowMargin);
          CardY := RowMargin + (j div CardsPerRow) * (CARD_H + RowMargin);

          CardPanel := TPanel.Create(Self);
          CardPanel.Parent := FGamesPanel;
          CardPanel.SetBounds(CardX, CardY, CARD_W, CARD_H);
          CardPanel.BevelOuter := bvNone;
          CardPanel.Caption := '';
          CardPanel.Tag := 9999;  // marker: game card — excluded from theme color override
          CardPanel.Color := $303030;  // slightly lighter than the navy bg for contrast
          CardPanel.Hint := '(' + AppID + ') ' + GameName + LineEnding + LibPath + '/common/' + InstallDir;
          CardPanel.ShowHint := True;
          CardPanel.OnMouseEnter := @GameCardMouseEnter;
          CardPanel.OnMouseLeave := @GameCardMouseLeave;
          CardPanel.OnClick := @GameCardClick;
          CardPanel.OnMouseUp := @GameCardMouseUp;

          CardImage := TImage.Create(CardPanel);
          CardImage.Parent := CardPanel;
          CardImage.SetBounds(0, 0, CARD_W, CARD_H);
          CardImage.Stretch := True;
          CardImage.Proportional := False;
          CardImage.Center := False;
          CardImage.Hint := '(' + AppID + ') ' + GameName + LineEnding + LibPath + '/common/' + InstallDir;
          CardImage.ShowHint := True;
          CardImage.OnMouseEnter := @GameCardMouseEnter;
          CardImage.OnMouseLeave := @GameCardMouseLeave;
          CardImage.OnClick := @GameCardClick;
          CardImage.OnMouseUp := @GameCardMouseUp;

          // Load local image or queue for CDN download
          if FileExists(ImagePath) then
          begin
            try
              CardImage.Picture.LoadFromFile(ImagePath);
            except
            end;
          end
          else
          begin
            // No local image — will be downloaded by background thread
            PendingIDs.Add(AppID);
            PendingImages.Add(CardImage);
          end;

          // Compute badge bitmask and store in Tag for use by download thread
          GameCfgDir := GetGameConfigDir(GameName);
          HasMango      := FileExists(GameCfgDir + 'MangoHud.conf');
          HasVkBasalt   := FileExists(GameCfgDir + 'vkBasalt.conf');
          HasOptiScaler := FileExists(GameCfgDir + 'OptiScaler.ini');
          HasTweaks := False;
          if FileExists(GameCfgDir + 'fgmod') then
          begin
            TweakLines := TStringList.Create;
            try
              TweakLines.LoadFromFile(GameCfgDir + 'fgmod');
              for k := 0 to TweakLines.Count - 1 do
                if (Pos('#gamemode', TweakLines[k]) > 0) or
                   (Pos('export PROTON_', TweakLines[k]) > 0) or
                   (Pos('export RADV_', TweakLines[k]) > 0) or
                   (Pos('export MESA_', TweakLines[k]) > 0) or
                   (Pos('#customenv', TweakLines[k]) > 0) or
                   (Pos('export SteamDeck=1', TweakLines[k]) > 0) then
                begin
                  HasTweaks := True;
                  Break;
                end;
            finally
              TweakLines.Free;
            end;
          end;
          // Badges — PNG for MangoHud/OptiScaler (matches nav rail), glyph for vkBasalt/Tweaks
          BadgeCount := 0;
          if HasMango      then Inc(BadgeCount, 1);
          if HasVkBasalt   then Inc(BadgeCount, 2);
          if HasOptiScaler then Inc(BadgeCount, 4);
          if HasTweaks     then Inc(BadgeCount, 8);
          CardPanel.Tag := BadgeCount;

          if BadgeCount > 0 then
          begin
            // Graphite background strip (right edge, auto-height)
            BdgY := 2 * BDG_PAD_V + PopCnt(DWord(BadgeCount)) * BDG_SZ
                    + (PopCnt(DWord(BadgeCount)) - 1) * BDG_GAP;
            BdgBg := TShape.Create(CardPanel);
            BdgBg.Parent      := CardPanel;
            BdgBg.Shape       := stRectangle;
            BdgBg.Brush.Color := RGBToColor(28, 52, 96);
            BdgBg.Pen.Style   := psClear;
            BdgBg.SetBounds(CARD_W - BDG_W, 0, BDG_W, BdgY);
            BdgBg.OnMouseEnter := @GameCardMouseEnter;
            BdgBg.OnMouseLeave := @GameCardMouseLeave;
            BdgBg.OnClick      := @GameCardClick;
            BdgBg.OnMouseUp    := @GameCardMouseUp;

            BdgSlot := 0;
            for BdgBit := 0 to 3 do
            begin
              if (BadgeCount and (1 shl BdgBit)) = 0 then Continue;
              BdgX := CARD_W - BDG_W + (BDG_W - BDG_SZ) div 2;
              BdgY := BDG_PAD_V + BdgSlot * (BDG_SZ + BDG_GAP);

              if BdgBit = 0 then  // MangoHud — PNG icon
              begin
                BdgImg := TImage.Create(CardPanel);
                BdgImg.Parent      := CardPanel;
                BdgImg.AutoSize    := False;
                BdgImg.SetBounds(BdgX, BdgY, BDG_SZ, BDG_SZ);
                BdgImg.Stretch     := True;
                BdgImg.Proportional := True;
                BdgImg.Center      := True;
                BdgImg.Transparent := True;
                IconPath := ExtractFilePath(Application.ExeName) + 'assets/icons/mango-active.png';
                if FileExists(IconPath) then
                  try BdgImg.Picture.LoadFromFile(IconPath); except end;
                BdgImg.BringToFront;
                BdgImg.OnMouseEnter := @GameCardMouseEnter;
                BdgImg.OnMouseLeave := @GameCardMouseLeave;
                BdgImg.OnClick      := @GameCardClick;
                BdgImg.OnMouseUp    := @GameCardMouseUp;
              end
              else if BdgBit = 2 then  // OptiScaler — PNG icon
              begin
                BdgImg := TImage.Create(CardPanel);
                BdgImg.Parent      := CardPanel;
                BdgImg.AutoSize    := False;
                BdgImg.SetBounds(BdgX, BdgY, BDG_SZ, BDG_SZ);
                BdgImg.Stretch     := True;
                BdgImg.Proportional := True;
                BdgImg.Center      := True;
                BdgImg.Transparent := True;
                IconPath := ExtractFilePath(Application.ExeName) + 'assets/icons/scale-up2-active.png';
                if FileExists(IconPath) then
                  try BdgImg.Picture.LoadFromFile(IconPath); except end;
                BdgImg.BringToFront;
                BdgImg.OnMouseEnter := @GameCardMouseEnter;
                BdgImg.OnMouseLeave := @GameCardMouseLeave;
                BdgImg.OnClick      := @GameCardClick;
                BdgImg.OnMouseUp    := @GameCardMouseUp;
              end
              else  // vkBasalt ('󰏘') or Tweaks ('󰒓') — TLabel glyph
              begin
                // Shadow
                BdgLbl := TLabel.Create(CardPanel);
                BdgLbl.Parent     := CardPanel;
                BdgLbl.AutoSize   := False;
                BdgLbl.SetBounds(BdgX + 1, BdgY + 1, BDG_SZ + 2, BDG_SZ + 2);
                BdgLbl.Caption    := BADGE_GLYPHS[BdgBit];
                BdgLbl.Font.Name  := 'Noto Sans';
                BdgLbl.Font.Size  := BDG_FONT;
                BdgLbl.Font.Color := clBlack;
                BdgLbl.Font.Style := [];
                BdgLbl.Transparent := True;
                BdgLbl.OnMouseEnter := @GameCardMouseEnter;
                BdgLbl.OnMouseLeave := @GameCardMouseLeave;
                BdgLbl.OnClick      := @GameCardClick;
                BdgLbl.OnMouseUp    := @GameCardMouseUp;
                // White icon
                BdgLbl := TLabel.Create(CardPanel);
                BdgLbl.Parent     := CardPanel;
                BdgLbl.AutoSize   := False;
                BdgLbl.SetBounds(BdgX, BdgY, BDG_SZ + 2, BDG_SZ + 2);
                BdgLbl.Caption    := BADGE_GLYPHS[BdgBit];
                BdgLbl.Font.Name  := 'Noto Sans';
                BdgLbl.Font.Size  := BDG_FONT;
                BdgLbl.Font.Color := clWhite;
                BdgLbl.Font.Style := [];
                BdgLbl.Transparent := True;
                BdgLbl.BringToFront;
                BdgLbl.OnMouseEnter := @GameCardMouseEnter;
                BdgLbl.OnMouseLeave := @GameCardMouseLeave;
                BdgLbl.OnClick      := @GameCardClick;
                BdgLbl.OnMouseUp    := @GameCardMouseUp;
              end;
              Inc(BdgSlot);
            end;
          end;

          // Store card and original image; apply gradient
          FCardPanels.Add(CardPanel);
          if (CardImage.Picture.Graphic <> nil) and
             (CardImage.Picture.Graphic.Width > 0) then
          begin
            ScaledBmp := TBitmap.Create;
            try
              ScaledBmp.SetSize(CARD_W, CARD_H);
              ScaledBmp.Canvas.StretchDraw(
                Rect(0, 0, CARD_W, CARD_H), CardImage.Picture.Graphic);
              ProcessCoverBitmap(ScaledBmp, GRAD_H);
              CardImage.Picture.Bitmap.Assign(ScaledBmp);
              FOrigCovers.Add(ScaledBmp.CreateIntfImage);
            finally
              ScaledBmp.Free;
            end;
            ApplyCardBrightness(CardPanel, 100);
          end
          else
            FOrigCovers.Add(nil);

          Inc(j);
        until FindNext(SR) <> 0;
        FindClose(SR);
      end;
    end;

    // Resize inner panel to fit all cards
    if j > 0 then
    begin
      TotalRows := (j + CardsPerRow - 1) div CardsPerRow;
      FGamesPanel.Width := FGamesScrollBox.Width;
      FGamesPanel.Height := RowMargin + TotalRows * (CARD_H + RowMargin);
    end
    else
    begin
      NoGamesLabel := TLabel.Create(Self);
      NoGamesLabel.Parent := FGamesPanel;
      NoGamesLabel.Caption := 'No installed Steam games found.';
      NoGamesLabel.Font.Color := clSilver;
      NoGamesLabel.Font.Size := 10;
      NoGamesLabel.Left := 16;
      NoGamesLabel.Top := 16;
    end;

    // Launch background thread to download missing covers from Steam CDN
    if PendingIDs.Count > 0 then
    begin
      if Assigned(FCoverThread) then
      begin
        FCoverThread.Terminate;
        FCoverThread.WaitFor;
        FreeAndNil(FCoverThread);
      end;
      // Thread takes ownership of PendingIDs and PendingImages
      FCoverThread := TCoverDownloadThread.Create(
        PendingIDs, PendingImages, CacheDir, Self);
      PendingIDs    := nil;
      PendingImages := nil;
      FCoverThread.Start;
    end;

  finally
    Libraries.Free;
    PendingIDs.Free;
    PendingImages.Free;
  end;
end;

procedure Tgoverlayform.RefreshGameCards;
var
  i: Integer;
begin
  // Stop any running cover download thread
  if Assigned(FCoverThread) then
  begin
    FCoverThread.Terminate;
    FCoverThread.WaitFor;
    FreeAndNil(FCoverThread);
  end;
  // Free all card panels — they own their children (CardImage, CardLabel, badges)
  // so a single Free call cleans up each card and all its sub-controls.
  if Assigned(FCardPanels) then
  begin
    for i := 0 to FCardPanels.Count - 1 do
      TPanel(FCardPanels[i]).Free;
    FCardPanels.Clear;
  end;
  // Free cached cover bitmaps
  if Assigned(FOrigCovers) then
  begin
    for i := 0 to FOrigCovers.Count - 1 do
      if FOrigCovers[i] <> nil then
        TLazIntfImage(FOrigCovers[i]).Free;
    FOrigCovers.Clear;
  end;
  // Rebuild the grid with up-to-date badge states
  LoadSteamGames;
end;

// ============================================================================
// Home tab
// ============================================================================

function Tgoverlayform.GetMangoHudVersion: string;
var
  P: TProcess;
  S: TStringList;
begin
  Result := '';
  P := TProcess.Create(nil);
  try
    P.Executable := FindDefaultExecutablePath('sh');
    P.Parameters.Add('-c');
    P.Parameters.Add('mangohud --version 2>&1 | head -1');
    P.Options := [poUsePipes, poWaitOnExit];
    try
      P.Execute;
      S := TStringList.Create;
      try
        S.LoadFromStream(P.Output);
        if S.Count > 0 then Result := Trim(S[0]);
      finally S.Free; end;
    except end;
  finally P.Free; end;
end;

function Tgoverlayform.GetVkBasaltVersion: string;
var
  P: TProcess;
  S: TStringList;
begin
  Result := '';
  P := TProcess.Create(nil);
  try
    P.Executable := FindDefaultExecutablePath('sh');
    P.Parameters.Add('-c');
    P.Parameters.Add('pacman -Q vkbasalt 2>/dev/null | awk ''{print $2}'' || ' +
                     'dpkg-query -W -f=''${Version}'' vkbasalt 2>/dev/null || ' +
                     'rpm -q --qf ''%{VERSION}'' vkbasalt 2>/dev/null || echo ""');
    P.Options := [poUsePipes, poWaitOnExit];
    try
      P.Execute;
      S := TStringList.Create;
      try
        S.LoadFromStream(P.Output);
        if S.Count > 0 then Result := Trim(S[0]);
      finally S.Free; end;
    except end;
  finally P.Free; end;
end;

function Tgoverlayform.FindBinPath(const BinName: string): string;
var
  P: TProcess;
  S: TStringList;
begin
  Result := '';
  P := TProcess.Create(nil);
  try
    P.Executable := 'which';
    P.Parameters.Add(BinName);
    P.Options := [poUsePipes, poWaitOnExit];
    try
      P.Execute;
      S := TStringList.Create;
      try
        S.LoadFromStream(P.Output);
        if S.Count > 0 then Result := Trim(S[0]);
      finally S.Free; end;
    except end;
  finally P.Free; end;
end;

function Tgoverlayform.FindLibPath(const LibName: string): string;
var
  P: TProcess;
  S: TStringList;
  Line: string;
  ArrowPos: Integer;
begin
  Result := '';
  P := TProcess.Create(nil);
  try
    P.Executable := FindDefaultExecutablePath('sh');
    P.Parameters.Add('-c');
    P.Parameters.Add('ldconfig -p 2>/dev/null | grep "' + LibName + '" | head -1');
    P.Options := [poUsePipes, poWaitOnExit];
    try
      P.Execute;
      S := TStringList.Create;
      try
        S.LoadFromStream(P.Output);
        if S.Count > 0 then
        begin
          Line := Trim(S[0]);
          // Format: "  libFoo.so (libc6,x86-64) => /usr/lib/libFoo.so"
          ArrowPos := Pos('=>', Line);
          if ArrowPos > 0 then
            Result := Trim(Copy(Line, ArrowPos + 2, MaxInt));
        end;
      finally S.Free; end;
    except end;
  finally P.Free; end;
end;

procedure Tgoverlayform.HomeDiagramPaint(Sender: TObject);
const
  R = 40;
var
  Box: TPaintBox;
  Cv: TCanvas;
  W, H, CX: Integer;
  PTop, PBL, PBR: TPoint;

  procedure DrawArrow(A, B: TPoint);
  var
    dx, dy, Len, nx, ny: Double;
    A2, B2: TPoint;
    px, py: Integer;
  begin
    dx := B.X - A.X; dy := B.Y - A.Y;
    Len := Sqrt(dx * dx + dy * dy);
    if Len < 1 then Exit;
    nx := dx / Len; ny := dy / Len;
    A2 := Point(A.X + Round(nx * R) + 2, A.Y + Round(ny * R) + 2);
    B2 := Point(B.X - Round(nx * R) - 2, B.Y - Round(ny * R) - 2);
    Cv.Pen.Color := $00888888;
    Cv.Pen.Width := 1;
    Cv.MoveTo(A2.X, A2.Y); Cv.LineTo(B2.X, B2.Y);
    // Arrow head at B2
    px := Round(nx * 8); py := Round(ny * 8);
    Cv.MoveTo(B2.X, B2.Y);
    Cv.LineTo(B2.X - px + Round(ny * 5), B2.Y - py - Round(nx * 5));
    Cv.MoveTo(B2.X, B2.Y);
    Cv.LineTo(B2.X - px - Round(ny * 5), B2.Y - py + Round(nx * 5));
    // Arrow head at A2
    Cv.MoveTo(A2.X, A2.Y);
    Cv.LineTo(A2.X + px + Round(ny * 5), A2.Y + py - Round(nx * 5));
    Cv.MoveTo(A2.X, A2.Y);
    Cv.LineTo(A2.X + px - Round(ny * 5), A2.Y + py + Round(nx * 5));
  end;

  procedure DrawCircle(CCx, CCy: Integer; BgCol: TColor; const L1, L2: string);
  var tw1, tw2: Integer;
  begin
    Cv.Brush.Color := BgCol;
    Cv.Pen.Color   := BgCol;
    Cv.Ellipse(CCx - R, CCy - R, CCx + R, CCy + R);
    Cv.Brush.Style := bsClear;
    Cv.Font.Color  := clWhite;
    Cv.Font.Size   := 8;
    Cv.Font.Style  := [fsBold];
    tw1 := Cv.TextWidth(L1);
    tw2 := Cv.TextWidth(L2);
    Cv.TextOut(CCx - tw1 div 2, CCy - 12, L1);
    Cv.TextOut(CCx - tw2 div 2, CCy + 2,  L2);
    Cv.Brush.Style := bsSolid;
  end;

begin
  Box := TPaintBox(Sender);
  Cv  := Box.Canvas;
  W   := Box.Width;
  H   := Box.Height;
  Cv.Brush.Color := $00252525;
  Cv.FillRect(Rect(0, 0, W, H));
  CX   := W div 2;
  PTop := Point(CX,       R + 10);
  PBL  := Point(CX - 80,  H - R - 10);
  PBR  := Point(CX + 80,  H - R - 10);
  DrawArrow(PTop, PBL);
  DrawArrow(PTop, PBR);
  DrawArrow(PBL,  PBR);
  DrawCircle(PTop.X, PTop.Y, $003F8B3F, 'NVIDIA', 'DLSS');
  DrawCircle(PBL.X,  PBL.Y,  $00882222, 'AMD',    'FSR');
  DrawCircle(PBR.X,  PBR.Y,  $002266BB, 'intel.', 'XeSS');
end;

procedure Tgoverlayform.HomeBtnRowResize(Sender: TObject);
begin
  if Assigned(FHomeGlobalBtn) and Assigned(FHomeBtnRow) then
    FHomeGlobalBtn.Width := (FHomeBtnRow.ClientWidth - 16) div 2;
end;

procedure Tgoverlayform.HomeGlobalBtnClick(Sender: TObject);
begin
  mangohudLabelClick(nil);
end;

procedure Tgoverlayform.HomeGameBtnClick(Sender: TObject);
begin
  gamesLabelClick(nil);
end;

procedure Tgoverlayform.HomeGlobalBtnEnter(Sender: TObject);
begin
  if Sender is TPanel then
    TPanel(Sender).Color := $00283060;
end;

procedure Tgoverlayform.HomeGlobalBtnLeave(Sender: TObject);
begin
  if Sender is TPanel then
    TPanel(Sender).Color := $00202040;
end;

procedure Tgoverlayform.HomeGameBtnEnter(Sender: TObject);
begin
  if Sender is TPanel then
    TPanel(Sender).Color := $00284028;
end;

procedure Tgoverlayform.HomeGameBtnLeave(Sender: TObject);
begin
  if Sender is TPanel then
    TPanel(Sender).Color := $00203020;
end;

procedure Tgoverlayform.HomeChannelComboChange(Sender: TObject);
begin
  // No longer used (channel combo removed from Home tab)
end;

procedure Tgoverlayform.RefreshHomeModuleStatus;
const
  CLR_OK      = $0044BB44;  // green
  CLR_MISSING = $00BB4444;  // red
var
  Missing: TStringList;
  MangoOK, VkOK, OptiOK: Boolean;
  MangoVer, VkVer: string;
begin
  if not Assigned(FHomeModDots[0]) then Exit;

  CheckDependencies(Missing);
  try
    MangoOK := (Missing.IndexOf('mangohud') < 0) and
               (Missing.IndexOf('MangoHud runtime 25.08') < 0);
    VkOK    := (Missing.IndexOf('vkbasalt') < 0) and
               (Missing.IndexOf('vkBasalt runtime 25.08') < 0);
    OptiOK  := IsOptiScalerInstalled;
  finally
    Missing.Free;
  end;

  FHomeModDots[0].Brush.Color := IfThen(MangoOK, CLR_OK, CLR_MISSING);
  FHomeModDots[1].Brush.Color := IfThen(VkOK,    CLR_OK, CLR_MISSING);
  FHomeModDots[2].Brush.Color := IfThen(OptiOK,  CLR_OK, CLR_MISSING);

  MangoVer := GetMangoHudVersion;
  if MangoVer = '' then MangoVer := IfThen(MangoOK, 'installed', 'not found');
  FHomeModVerLbls[0].Caption := MangoVer;

  VkVer := GetVkBasaltVersion;
  if VkVer = '' then VkVer := IfThen(VkOK, 'installed', 'not found');
  FHomeModVerLbls[1].Caption := VkVer;

  if OptiOK and Assigned(optlabel1) and (optlabel1.Caption <> '') then
    FHomeModVerLbls[2].Caption := optlabel1.Caption
  else if OptiOK then
    FHomeModVerLbls[2].Caption := 'installed'
  else
    FHomeModVerLbls[2].Caption := 'not found';
end;

procedure Tgoverlayform.RefreshHomeOptiStatus;
const
  CLR_OK   = $0044BB44;
  CLR_NONE = $00666666;

  procedure SetLib(Idx: Integer; SrcLbl: TLabel);
  var Ver: string;
  begin
    if not Assigned(FHomeOptiLbls[Idx]) then Exit;
    Ver := '';
    if Assigned(SrcLbl) then Ver := SrcLbl.Caption;
    FHomeOptiLbls[Idx].Caption := IfThen(Ver <> '', Ver, '—');
    if Assigned(FHomeLibDots[Idx]) then
      FHomeLibDots[Idx].Brush.Color := IfThen((Ver <> '') and (Ver <> '--'), CLR_OK, CLR_NONE);
  end;

begin
  // Update OptiScaler version in module status
  if Assigned(FHomeModVerLbls[2]) and Assigned(optlabel1) and (optlabel1.Caption <> '') then
    FHomeModVerLbls[2].Caption := optlabel1.Caption;

  // Library sub-rows: FakeNvAPI[0], Optipatcher[1], FSR[2], XeSS[3], DLSS[4]
  SetLib(0, fakenvapi1);
  SetLib(1, optipatcherLabel1);
  SetLib(2, fsrlabel1);
  SetLib(3, xessLabel1);
  SetLib(4, dlssLabel1);
end;

procedure Tgoverlayform.RefreshHomeDeps;
const
  DEP_KEYS: array[0..6] of string = (
    'pascube', 'vkcube', 'p7zip', 'curl', 'git', 'gamemode', 'libqt6pas');
  DEP_DISPLAY: array[0..6] of string = (
    'PasCube', 'vkcube', '7z (p7zip)', 'curl', 'git', 'gamemode', 'qt6pas');
  DEP_HINTS: array[0..6] of string = (
    'OpenGL preview cube for testing the MangoHud overlay',
    'Vulkan cube for testing Vulkan layer injection',
    'Archive tool required for OptiScaler extraction',
    'HTTP client used to download OptiScaler updates and covers',
    'Version control used to fetch fgmod scripts',
    'Feral GameMode daemon for CPU/GPU optimisation',
    'Qt6 Pascal bindings — required for the Goverlay GUI');
  CLR_OK      = $0044BB44;
  CLR_MISSING = $004444BB;  // RGB(187,68,68) — red in Lazarus BGR format
var
  Missing: TStringList;
  i: Integer;
begin
  if not Assigned(FHomeDepDots[0]) then Exit;
  CheckDependencies(Missing);
  try
    for i := 0 to 6 do
    begin
      FHomeDepDots[i].Hint := DEP_HINTS[i];
      FHomeDepLbls[i].Hint := DEP_HINTS[i];
      if Missing.IndexOf(DEP_KEYS[i]) >= 0 then
      begin
        FHomeDepDots[i].Brush.Color := CLR_MISSING;
        FHomeDepDots[i].Pen.Color   := CLR_MISSING;
        FHomeDepLbls[i].Font.Color  := $00888888;
      end
      else
      begin
        FHomeDepDots[i].Brush.Color := CLR_OK;
        FHomeDepDots[i].Pen.Color   := CLR_OK;
        FHomeDepLbls[i].Font.Color  := clWhite;
      end;
    end;
  finally
    Missing.Free;
  end;
end;

procedure Tgoverlayform.InitHomeTab;
const
  BG         = $001A1A1A;
  CARD_BG    = $00222222;
  CARD_M     = 16;
  CARD_P     = 18;   // padding inside card (left content margin)
  ROW_H      = 32;
  DOT_SZ     = 14;
  SEC_GAP    = 14;
  COL_W      = 200;
  ACCENT_W   = 4;    // left accent bar width
  // accent colors per section
  ACC_MOD    = $004488CC;  // blue  — Module Status
  ACC_DEP    = $0033AA55;  // green — Dependencies
  ACC_SYS    = $00CC8844;  // orange — System Info

  DEP_NAMES: array[0..6] of string = (
    'PasCube', 'vkcube', '7z', 'curl', 'git', 'gamemode', 'qt6pas');
  MOD_NAMES: array[0..2] of string = ('MangoHud', 'vkBasalt', 'OptiScaler');
  LIB_NAMES: array[0..4] of string = ('FakeNvAPI:', 'Optipatcher:', 'FSR:', 'XeSS:', 'DLSS:');

var
  Content:   TPanel;
  Card:      TPanel;
  BtnRow:    TPanel;
  AccBar:    TShape;
  Lbl:       TLabel;
  Ico:       TImage;
  IconFile:  string;
  Sep:       TBevel;
  i, Row, Y, ColX, Col2X: Integer;
  Dot:       TShape;

  function MkCard(AY, AH: Integer): TPanel;
  begin
    Result := TPanel.Create(Self);
    Result.Parent     := Content;
    Result.BevelOuter := bvNone;
    Result.Color      := CARD_BG;
    Result.Caption    := '';
    Result.Tag        := 9998;
    Result.Left       := CARD_M;
    Result.Top        := AY;
    Result.Height     := AH;
    Result.Anchors    := [akLeft, akTop, akRight];
    Result.AnchorSideRight.Control := Content;
    Result.AnchorSideRight.Side    := asrRight;
    Result.BorderSpacing.Right     := CARD_M;
  end;

  // Colored left accent bar spanning the full card height
  procedure MkAccent(ACard: TPanel; AColor: TColor);
  begin
    AccBar := TShape.Create(Self);
    AccBar.Parent      := ACard;
    AccBar.Shape       := stRectangle;
    AccBar.Brush.Color := AColor;
    AccBar.Pen.Style   := psClear;
    AccBar.Left        := 0;
    AccBar.Top         := 0;
    AccBar.Width       := ACCENT_W;
    AccBar.Height      := ACard.Height;
    AccBar.Anchors     := [akLeft, akTop, akBottom];
  end;

  function MkTitle(AParent: TWinControl; const AText: string; AY: Integer): TLabel;
  begin
    Result := TLabel.Create(Self);
    Result.Parent     := AParent;
    Result.Caption    := AText;
    Result.Font.Bold  := True;
    Result.Font.Color := clWhite;
    Result.Font.Size  := 10;
    Result.Left       := CARD_P;
    Result.Top        := AY;
    Result.AutoSize   := True;
  end;

  procedure MkSep(AParent: TWinControl; AY: Integer);
  begin
    Sep := TBevel.Create(Self);
    Sep.Parent  := AParent;
    Sep.Style   := bsLowered;
    Sep.Shape   := bsTopLine;
    Sep.Left    := CARD_P;
    Sep.Top     := AY;
    Sep.Height  := 2;
    Sep.Anchors := [akLeft, akTop, akRight];
    Sep.AnchorSideRight.Control := AParent;
    Sep.AnchorSideRight.Side    := asrRight;
    Sep.BorderSpacing.Right     := CARD_P;
  end;

  function MkDot(AParent: TWinControl; AX, AY: Integer): TShape;
  begin
    Result := TShape.Create(Self);
    Result.Parent      := AParent;
    Result.Shape       := stEllipse;
    Result.Brush.Color := $00888888;
    Result.Pen.Style   := psClear;
    Result.SetBounds(AX, AY, DOT_SZ, DOT_SZ);
  end;

  function MkBtnLabel(AParent: TWinControl; const ACaption: string;
    AFontSize: Integer; AColor: TColor; AFontName: string = ''): TLabel;
  begin
    Result := TLabel.Create(Self);
    Result.Parent     := AParent;
    Result.Caption    := ACaption;
    Result.Alignment  := taCenter;
    Result.Layout     := tlCenter;
    Result.Align      := alTop;
    Result.Font.Size  := AFontSize;
    Result.Font.Color := AColor;
    if AFontName <> '' then Result.Font.Name := AFontName;
    Result.Cursor     := crHandPoint;
  end;

begin
  // ── Tab sheet ────────────────────────────────────────────────────────────
  FHomeTabSheet := TTabSheet.Create(goverlayPageControl);
  FHomeTabSheet.PageControl := goverlayPageControl;
  FHomeTabSheet.Caption     := 'Home';
  FHomeTabSheet.TabVisible  := False;
  FHomeTabSheet.Color       := BG;

  // ── Content panel fills the tab — no ScrollBox needed ────────────────────
  Content := TPanel.Create(Self);
  Content.Parent    := FHomeTabSheet;
  Content.BevelOuter := bvNone;
  Content.Color     := BG;
  Content.Caption   := '';
  Content.Align     := alClient;

  Y    := CARD_M;

  // ── System (List) ────────────────────────────────────────────────────────
  Card := MkCard(Y, CARD_P * 2 + 24 + 4 * ROW_H + 8);
  MkTitle(Card, 'System', CARD_P);
  MkSep(Card, CARD_P + 22);

  for i := 0 to 3 do
  begin
    Row  := CARD_P + 30 + i * ROW_H;
    ColX := CARD_P;

    Ico := TImage.Create(Self);
    Ico.Parent := Card;
    Ico.Width  := 22;
    Ico.Height := 22;
    Ico.Left   := ColX;
    Ico.Top    := Row + (ROW_H - 22) div 2;
    Ico.Proportional := True;
    Ico.Center := True;
    Ico.Transparent := True;

    Lbl := TLabel.Create(Self);
    Lbl.Parent     := Card;
    case i of
      0: 
      begin 
        IconFile := 'data/icons/system/os.png'; 
        Lbl.Caption := GetSysLinuxDistribution + ' (' + GetKernelVersion + ')'; 
        Ico.Hint := 'OS / Kernel'; 
      end;
      1: 
      begin 
        IconFile := 'data/icons/system/cpu.png'; 
        Lbl.Caption := GetSysCPUModel; 
        Ico.Hint := 'CPU'; 
      end;
      2: 
      begin 
        IconFile := 'data/icons/system/gpu.png'; 
        Lbl.Caption := GetSysGPUModel; 
        Ico.Hint := 'GPU'; 
      end;
      3: 
      begin 
        IconFile := 'data/icons/system/driver.png'; 
        Lbl.Caption := GetSysGPUDriver; 
        Ico.Hint := 'Driver'; 
      end;
    end;
    if FileExists(ExtractFilePath(Application.ExeName) + IconFile) then
      Ico.Picture.LoadFromFile(ExtractFilePath(Application.ExeName) + IconFile);

    Lbl.Font.Color := clWhite;
    Lbl.Font.Size  := 9;
    Lbl.Left       := ColX + DOT_SZ + 16;
    Lbl.Top        := Row + (ROW_H - 16) div 2;
    Lbl.AutoSize   := True;
    Lbl.ShowHint   := True;
    Lbl.Hint       := Lbl.Caption;
    Ico.ShowHint   := True;
  end;
  Inc(Y, Card.Height + SEC_GAP);

  // ── Module Status + Libraries ────────────────────────────────────────────
  Card := MkCard(Y, CARD_P * 2 + 24 + 3 * ROW_H + 10 + 3 * ROW_H + 4);
  MkTitle(Card, 'Libraries', CARD_P);
  MkSep(Card, CARD_P + 22);

  // Module rows (MangoHud, vkBasalt, OptiScaler)
  for i := 0 to 2 do
  begin
    Row := CARD_P + 30 + i * ROW_H;
    Dot := MkDot(Card, CARD_P, Row + (ROW_H - DOT_SZ) div 2);
    Dot.ShowHint := True;
    FHomeModDots[i] := Dot;

    Lbl := TLabel.Create(Self);
    Lbl.Parent     := Card;
    Lbl.Caption    := MOD_NAMES[i];
    Lbl.Font.Color := clWhite;
    Lbl.Font.Size  := 9;
    Lbl.Left       := CARD_P + DOT_SZ + 8;
    Lbl.Top        := Row + (ROW_H - 16) div 2;
    Lbl.AutoSize   := True;
    Lbl.ShowHint   := True;

    Lbl := TLabel.Create(Self);
    Lbl.Parent     := Card;
    Lbl.Caption    := '—';
    Lbl.Font.Color := clSilver;
    Lbl.Font.Size  := 9;
    Lbl.Left       := CARD_P + DOT_SZ + 8 + 110;
    Lbl.Top        := Row + (ROW_H - 16) div 2;
    Lbl.AutoSize   := True;
    Lbl.ShowHint   := True;
    FHomeModVerLbls[i] := Lbl;
  end;

  // Thin divider between module rows and library sub-rows
  MkSep(Card, CARD_P + 30 + 3 * ROW_H + 2);

  // Library sub-rows (indented) — 2 columns, 3 rows
  // i=0 FakeNvAPI, i=1 Optipatcher, i=2 FSR, i=3 XeSS, i=4 DLSS
  // Left col: i=0,2,4  Right col: i=1,3
  Col2X := 330;
  for i := 0 to 4 do
  begin
    if i mod 2 = 0 then ColX := CARD_P
    else                 ColX := Col2X;
    Row := CARD_P + 30 + 3 * ROW_H + 10 + (i div 2) * ROW_H;

    Dot := MkDot(Card, ColX, Row + (ROW_H - DOT_SZ) div 2);
    Dot.ShowHint := True;
    FHomeLibDots[i] := Dot;

    Lbl := TLabel.Create(Self);
    Lbl.Parent     := Card;
    Lbl.Caption    := LIB_NAMES[i];
    Lbl.Font.Color := clSilver;
    Lbl.Font.Size  := 9;
    Lbl.Left       := ColX + DOT_SZ + 8;
    Lbl.Top        := Row + (ROW_H - 16) div 2;
    Lbl.AutoSize   := True;
    Lbl.ShowHint   := True;

    Lbl := TLabel.Create(Self);
    Lbl.Parent     := Card;
    Lbl.Caption    := '—';
    Lbl.Font.Color := $004499FF;
    Lbl.Font.Size  := 9;
    Lbl.Left       := ColX + DOT_SZ + 8 + 110;
    Lbl.Top        := Row + (ROW_H - 16) div 2;
    Lbl.AutoSize   := True;
    Lbl.ShowHint   := True;
    FHomeOptiLbls[i] := Lbl;
  end;
  Inc(Y, Card.Height + SEC_GAP);

  // ── Card 2: Dependencies (3×3 grid) ──────────────────────────────────────
  Card := MkCard(Y, CARD_P * 2 + 24 + 3 * ROW_H + 8);
  MkTitle(Card, 'Dependencies', CARD_P);
  MkSep(Card, CARD_P + 22);

  for i := 0 to 6 do
  begin
    Row  := CARD_P + 30 + (i div 3) * ROW_H;
    ColX := CARD_P + (i mod 3) * COL_W;

    Dot := MkDot(Card, ColX, Row + (ROW_H - DOT_SZ) div 2);
    Dot.ShowHint := True;
    FHomeDepDots[i] := Dot;

    Lbl := TLabel.Create(Self);
    Lbl.Parent     := Card;
    Lbl.Caption    := DEP_NAMES[i];
    Lbl.Font.Color := clWhite;
    Lbl.Font.Size  := 9;
    Lbl.Left       := ColX + DOT_SZ + 6;
    Lbl.Top        := Row + (ROW_H - 16) div 2;
    Lbl.Width      := COL_W - DOT_SZ - 10;
    Lbl.AutoSize   := False;
    Lbl.ShowHint   := True;
    FHomeDepLbls[i] := Lbl;
  end;
  Inc(Y, Card.Height + SEC_GAP);


end;

procedure Tgoverlayform.ShowHomeTab(Sender: TObject);
begin
  SetNavActive(-1);

  goverlayPageControl.ShowTabs := False;
  vkbasalttabsheet.TabVisible  := False;
  optiscalertabsheet.TabVisible := False;
  tweakstabsheet.TabVisible    := False;
  gamesTabSheet.TabVisible     := False;
  FHomeTabSheet.TabVisible     := True;
  goverlayPageControl.ActivePage := FHomeTabSheet;

  notificationLabel.Visible := False;
  commandPanel.Visible       := False;

  geSpeedButton.Visible     := False;
  geLabel.Visible           := False;
  goverlaybarPanel.Visible  := False;

  // Refresh all home tab sections
  RefreshHomeOptiStatus;
  RefreshHomeModuleStatus;
  RefreshHomeDeps;
end;

procedure Tgoverlayform.ReflowGamesGrid;
var
  CardCount, CardsPerRow, TotalRows, i, CardX, CardY, RowMargin: Integer;
  Ctrl: TControl;
  WasHovered: TPanel;
begin
  if not Assigned(FGamesScrollBox) or not Assigned(FGamesPanel) then
    Exit;
  // Skip reflow while games tab is not visible — avoids N×SetBounds on every tab switch
  if not gamesTabSheet.TabVisible then
  begin
    DbgLog('  ReflowGamesGrid SKIPPED (tab not visible)');
    Exit;
  end;

  Inc(FReflowCount);
  DbgLog(Format('  ReflowGamesGrid BEGIN #%d scrollW=%d', [FReflowCount, FGamesScrollBox.Width]));

  CardsPerRow := Max(1, FGamesScrollBox.Width div (CARD_W + CARD_MARGIN));
  RowMargin := (FGamesScrollBox.Width - CardsPerRow * CARD_W) div (CardsPerRow + 1);
  if RowMargin < 4 then RowMargin := 4;
  CardCount   := 0;

  // Completely clear hover state before reflow — prevents ChangeBounds loops
  WasHovered := FHoveredCard;
  FHoveredCard := nil;
  FHoverBrightness := 0;
  FHoverDir := 0;
  if Assigned(FHoverTimer) then
    FHoverTimer.Enabled := False;

  // Prevent LCL alignment loops while manually repositioning every card
  FInReflow := True;
  FGamesPanel.DisableAlign;
  try
    for i := 0 to FCardPanels.Count - 1 do
    begin
      Ctrl := TControl(FCardPanels[i]);
      if not (Ctrl is TPanel) then
        Continue;
      CardX := RowMargin + (CardCount mod CardsPerRow) * (CARD_W + RowMargin);
      CardY := RowMargin + (CardCount div CardsPerRow) * (CARD_H + RowMargin);
      // Only SetBounds if position actually changed (reduces LCL churn)
      if (Ctrl.Left <> CardX) or (Ctrl.Top <> CardY) or
         (Ctrl.Width <> CARD_W) or (Ctrl.Height <> CARD_H) then
      begin
        Ctrl.SetBounds(CardX, CardY, CARD_W, CARD_H);
        if (TPanel(Ctrl).ControlCount > 0) and (TPanel(Ctrl).Controls[0] is TImage) then
          TImage(TPanel(Ctrl).Controls[0]).SetBounds(0, 0, CARD_W, CARD_H);
      end;
      Inc(CardCount);
    end;

    if CardCount > 0 then
    begin
      TotalRows := (CardCount + CardsPerRow - 1) div CardsPerRow;
      // Use Width (not ClientWidth) so scrollbar appearance doesn't trigger a loop
      FGamesPanel.Width  := FGamesScrollBox.Width;
      FGamesPanel.Height := RowMargin + TotalRows * (CARD_H + RowMargin);
    end;
  finally
    FInReflow := False;
    FGamesPanel.EnableAlign;
    DbgLog(Format('  ReflowGamesGrid END   #%d', [FReflowCount]));
  end;

end;

procedure Tgoverlayform.GamesScrollBoxResize(Sender: TObject);
begin
  if FGamesLoaded then
    ReflowGamesGrid;
end;

procedure Tgoverlayform.GamesEmptySpaceClick(Sender: TObject);
begin
  // Clicking empty space in the games grid
  if FActiveGameName <> '' then
  begin
    FActiveGameName := '';
    MANGOHUDCFGFILE := IncludeTrailingPathDelimiter(GetMangoHudConfigDir()) + 'MangoHud.conf';
    VKBASALTCFGFILE := IncludeTrailingPathDelimiter(GetVkBasaltConfigDir()) + 'vkBasalt.conf';
    UpdateGameContextLabel;
    HideGameThumb;
    LoadGameToggleStates;  // reset all tools to enabled, hide toggles
  end;
end;

procedure Tgoverlayform.GameCardMouseEnter(Sender: TObject);
var
  Panel: TPanel;
begin
  DbgLog('GameCardMouseEnter: ' + TControl(Sender).Name);
  if Sender is TPanel then Panel := TPanel(Sender)
  else if Sender is TImage then Panel := TPanel(TImage(Sender).Parent)
  else if Sender is TLabel then Panel := TPanel(TLabel(Sender).Parent)
  else Exit;

  if Sender is TControl then
    TControl(Sender).Cursor := crHandPoint;

  if Panel = FHoveredCard then
  begin
    // Re-entering same card (e.g. from child control): ensure brightening
    FHoverDir := 1;
    if Assigned(FHoverTimer) and not FHoverTimer.Enabled then
      FHoverTimer.Enabled := True;
    Exit;
  end;

  // Snap previous hovered card back to dim and restore its size instantly.
  if Assigned(FHoveredCard) then
  begin
    ApplyCardBrightness(FHoveredCard, 100);
    FHoveredCard.SetBounds(
      FHoveredCard.Left + (FHoveredCard.Width - CARD_W) div 2,
      FHoveredCard.Top  + (FHoveredCard.Height - CARD_H) div 2,
      CARD_W, CARD_H);
    if (FHoveredCard.ControlCount > 0) and (FHoveredCard.Controls[0] is TImage) then
      TImage(FHoveredCard.Controls[0]).SetBounds(0, 0, CARD_W, CARD_H);
  end;

  FHoveredCard     := Panel;
  FHoverBrightness := 0;
  FHoverDir        := 1;
  FHoverBaseLeft   := Panel.Left;
  FHoverBaseTop    := Panel.Top;

  // Smooth scale-up is driven by HoverTimerTick; just bring to front now
  Panel.BringToFront;

  if not Assigned(FHoverTimer) then
  begin
    FHoverTimer          := TTimer.Create(Self);
    FHoverTimer.Interval := 16;
    FHoverTimer.OnTimer  := @HoverTimerTick;
  end;
  FHoverTimer.Enabled := True;
end;

procedure Tgoverlayform.GameCardMouseLeave(Sender: TObject);
var
  Panel: TPanel;
begin
  DbgLog('GameCardMouseLeave: ' + TControl(Sender).Name);
  if Sender is TPanel then Panel := TPanel(Sender)
  else if Sender is TImage then Panel := TPanel(TImage(Sender).Parent)
  else if Sender is TLabel then Panel := TPanel(TLabel(Sender).Parent)
  else Exit;

  if Panel <> FHoveredCard then
  begin
    DbgLog('GameCardMouseLeave: not hovered card, ignoring');
    Exit;
  end;

  // Smooth shrink-back is driven by HoverTimerTick
  FHoverDir := -1;
  if Assigned(FHoverTimer) then
    FHoverTimer.Enabled := True;
end;

procedure Tgoverlayform.GameCardClick(Sender: TObject);
var
  Panel: TPanel;
  GameName, GameCfgDir, FGOrig: string;
  Lines: TStringList;
  p: Integer;
begin
  if Sender is TPanel then Panel := TPanel(Sender)
  else if Sender is TImage then Panel := TPanel(TImage(Sender).Parent)
  else if Sender is TLabel then Panel := TPanel(TLabel(Sender).Parent)
  else Exit;

  // Extract game name from card hint
  Lines := TStringList.Create;
  try
    Lines.Text := Panel.Hint;
    if Lines.Count < 1 then Exit;
    GameName := Lines[0];
  finally
    Lines.Free;
  end;

  if (Length(GameName) > 0) and (GameName[1] = '(') then
  begin
    p := Pos(') ', GameName);
    if p > 0 then
      GameName := Copy(GameName, p + 2, Length(GameName));
  end;

  FActiveGameName := GameName;
  ShowGameThumb(Panel);
  LoadGameToggleStates;

  // Navigate directly to MangoHud game config
  GameCfgDir := GetGameConfigDir(GameName);
  if not DirectoryExists(GameCfgDir) then
    ForceDirectories(GameCfgDir);
  // Copy only the launch scripts — OptiScaler files are copied only when the
  // OptiScaler toggle is explicitly enabled for this game.
  // Copy scripts without overwriting — user config lives inside fgmod.
  // Then patch the script body for OptiScaler conditional if needed.
  FGOrig := IncludeTrailingPathDelimiter(GetFGModOriginalPath);
  ExecuteShellCommand('cp -n ' + QuotedStr(FGOrig + 'fgmod') + ' ' +
    QuotedStr(GameCfgDir + 'fgmod') + ' 2>/dev/null && chmod 755 ' +
    QuotedStr(GameCfgDir + 'fgmod'));
  ExecuteShellCommand('cp -n ' + QuotedStr(FGOrig + 'fgmod-uninstaller.sh') + ' ' +
    QuotedStr(GameCfgDir + 'fgmod-uninstaller.sh') + ' 2>/dev/null && chmod 755 ' +
    QuotedStr(GameCfgDir + 'fgmod-uninstaller.sh'));
  ExecuteShellCommand('cp -n ' + QuotedStr(FGOrig + 'fgmod-remover.sh') + ' ' +
    QuotedStr(GameCfgDir + 'fgmod-remover.sh') + ' 2>/dev/null && chmod 755 ' +
    QuotedStr(GameCfgDir + 'fgmod-remover.sh'));
  EnsureGameFGModOptiScalerConditional(GameCfgDir + 'fgmod');
  MANGOHUDCFGFILE := GameCfgDir + 'MangoHud.conf';
  UpdateGameContextLabel;
  SetNavActive(1);
  goverlayPageControl.ShowTabs := True;
  vkbasalttabsheet.TabVisible  := False;
  optiscalertabsheet.TabVisible := False;
  tweakstabsheet.TabVisible    := False;
  gamesTabSheet.TabVisible     := False;
  goverlayPageControl.ActivePage := presetTabsheet;
  notificationLabel.Visible := False;
  commandPanel.Visible       := False;

  goverlaybarPanel.Visible  := True;
  popupBitBtn.Visible := True;
  FPreviewBtn.Visible  := True;
  UpdateGeSpeedButtonState;
  UpdateGlobalEnableMenuItemVisibility;
  LoadMangoHudConfig;
end;

procedure Tgoverlayform.GameCardMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Panel: TPanel;
  Pt: TPoint;
begin
  if Button <> mbRight then Exit;

  if Sender is TPanel then
    Panel := TPanel(Sender)
  else if Sender is TImage then
    Panel := TPanel(TImage(Sender).Parent)
  else if Sender is TLabel then
    Panel := TPanel(TLabel(Sender).Parent)
  else
    Exit;

  FRightClickedCard := Panel;

  Pt := TControl(Sender).ClientToScreen(Point(X, Y));
  FGameCardMenu.PopUp(Pt.X, Pt.Y);
end;

procedure Tgoverlayform.GameCardOpenFolderClick(Sender: TObject);
var
  Panel: TPanel;
  GamePath: string;
  Lines: TStringList;
begin
  Panel := FRightClickedCard;
  if Panel = nil then Exit;

  Lines := TStringList.Create;
  try
    Lines.Text := Panel.Hint;
    if Lines.Count >= 2 then
      GamePath := Lines[1]
    else
      Exit;
  finally
    Lines.Free;
  end;

  if DirectoryExists(GamePath) then
    ExecuteShellCommand('xdg-open ' + QuotedStr(GamePath));
end;

procedure Tgoverlayform.GameCardOpenPrefixClick(Sender: TObject);
var
  Panel: TPanel;
  GamePath: string;
  PrefixPath: string;
  Lines: TStringList;
  AppID: string;
  p: Integer;
begin
  Panel := FRightClickedCard;
  if Panel = nil then Exit;

  Lines := TStringList.Create;
  try
    Lines.Text := Panel.Hint;
    if Lines.Count >= 2 then
    begin
      AppID := '';
      if (Length(Lines[0]) > 0) and (Lines[0][1] = '(') then
      begin
        p := Pos(') ', Lines[0]);
        if p > 0 then
          AppID := Copy(Lines[0], 2, p - 2);
      end;
      
      GamePath := Lines[1];
    end
    else
      Exit;
  finally
    Lines.Free;
  end;

  if AppID <> '' then
  begin
    p := Pos('/common/', GamePath);
    if p > 0 then
    begin
      PrefixPath := Copy(GamePath, 1, p - 1) + '/compatdata/' + AppID + '/pfx';
      if DirectoryExists(PrefixPath) then
        ExecuteShellCommand('xdg-open ' + QuotedStr(PrefixPath));
    end;
  end;
end;

procedure Tgoverlayform.GameCardUninstallClick(Sender: TObject);
var
  Panel: TPanel;
  GameName, GameCfgDir, GamePath, ProxyDLL: string;
  Lines: TStringList;
  i: Integer;
begin
  Panel := FRightClickedCard;
  if Panel = nil then Exit;

  // Extract game name and install path from Hint:
  // '(AppID) GameName' + LineEnding + 'LibPath/common/InstallDir'
  Lines := TStringList.Create;
  try
    if Panel.Hint = '' then Exit;
    Lines.Text := Panel.Hint;
    if Lines.Count < 2 then Exit;
    i := Pos(') ', Lines[0]);
    if i > 0 then
      GameName := Copy(Lines[0], i + 2, MaxInt)
    else
      GameName := Lines[0];
    GamePath := Lines[1];
  finally
    Lines.Free;
  end;

  if GameName = '' then Exit;

  GameCfgDir := GetGameConfigDir(GameName);

  // Try to read the proxy DLL name from fgmod before we delete it
  ProxyDLL := '';
  if FileExists(GameCfgDir + 'fgmod') then
  begin
    Lines := TStringList.Create;
    try
      Lines.LoadFromFile(GameCfgDir + 'fgmod');
      for i := 0 to Lines.Count - 1 do
      begin
        if Pos('dll_name="${DLL:-', Lines[i]) > 0 then
        begin
          ProxyDLL := Copy(Lines[i], Pos(':-', Lines[i]) + 2, MaxInt);
          ProxyDLL := Copy(ProxyDLL, 1, Pos('}"', ProxyDLL) - 1);
          Break;
        end;
      end;
    finally
      Lines.Free;
    end;
  end;

  // Recursively delete the GOverlay game config directory
  if DirectoryExists(GameCfgDir) then
    DeleteDirectory(GameCfgDir, False);

  // Best-effort cleanup of known OptiScaler files from the game directory
  if (GamePath <> '') and DirectoryExists(GamePath) then
  begin
    GamePath := IncludeTrailingPathDelimiter(GamePath);

    // Proxy DLL selected in OptiScaler
    if ProxyDLL <> '' then
      DeleteFile(GamePath + ProxyDLL);

    // Common companion DLLs copied by GOverlay/OptiScaler
    DeleteFile(GamePath + 'amd_fidelityfx_upscaler_dx12.dll');
    DeleteFile(GamePath + 'amd_fidelityfx_framegeneration_dx12.dll');
    DeleteFile(GamePath + 'amd_fidelityfx_vk.dll');
    DeleteFile(GamePath + 'amd_fidelityfx_dx12.dll');
    DeleteFile(GamePath + 'dlssg_to_fsr3_amd_is_better.dll');
    DeleteFile(GamePath + 'nvngx.dll');
    DeleteFile(GamePath + 'nvngx_dlss.dll');
    DeleteFile(GamePath + 'nvngx_dlssd.dll');
    DeleteFile(GamePath + 'nvngx_dlssg.dll');
    DeleteFile(GamePath + 'fakenvapi.ini');
    DeleteFile(GamePath + 'OptiScaler.ini');
    DeleteFile(GamePath + 'OptiScaler.log');
    DeleteFile(GamePath + 'goverlay.vars');
  end;

  // Remove badge controls from the card panel.
  // Cover image has Proportional=False; badge images have Proportional=True.
  for i := Panel.ControlCount - 1 downto 0 do
  begin
    if Panel.Controls[i] is TImage then
    begin
      if TImage(Panel.Controls[i]).Proportional then
        Panel.Controls[i].Free;
    end
    else if (Panel.Controls[i] is TShape) or (Panel.Controls[i] is TLabel) then
      Panel.Controls[i].Free;
  end;

  // Reset badge mask
  Panel.Tag := 0;

  SendNotification('Goverlay', 'Changes uninstalled for ' + GameName, GetIconFile);
end;

// ============================================================================
// Game-specific config helpers
// ============================================================================

function Tgoverlayform.SanitizeFileName(const AName: string): string;
var
  i: Integer;
begin
  Result := AName;
  for i := 1 to Length(Result) do
    if Result[i] in ['/', '\', ':', '*', '?', '"', '<', '>', '|'] then
      Result[i] := '_';
end;

function Tgoverlayform.GetGameConfigDir(const AGameName: string): string;
begin
  // Use the centralized Flatpak-aware helper so game configs are stored in
  // the same location whether GOverlay is running natively or as Flatpak.
  Result := IncludeTrailingPathDelimiter(TConfigManager.GetHostDataDir) +
            'goverlay/gameconfig/' + SanitizeFileName(AGameName) + '/';
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

function Tgoverlayform.GetVkBasaltConfigEnvPrefix: string;
begin
  if FActiveGameName <> '' then
    Result := 'VKBASALT_CONFIG_FILE="' + GetGameConfigDir(FActiveGameName) + 'vkBasalt.conf" '
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
    ExecuteGUICommand(GetMangoHudLaunchEnv + GetVkBasaltLaunchEnv + 'pascube &')
  else if IsCommandAvailable('vkcube') then
    ExecuteGUICommand(GetMangoHudLaunchEnv + GetVkBasaltLaunchEnv + 'vkcube &')
  else
    SendNotification('Goverlay', 'PasCube and VkCube not found.', GetIconFile);
end;

procedure Tgoverlayform.ShowGameThumb(ACard: TPanel);
var
  i: Integer;
  Img: TImage;
  Bmp: TBitmap;
begin
  if ACard = nil then Exit;

  // Find the TImage child of the selected game card
  Img := nil;
  for i := 0 to ACard.ControlCount - 1 do
    if ACard.Controls[i] is TImage then
    begin
      Img := TImage(ACard.Controls[i]);
      Break;
    end;

  FreeAndNil(FGameThumbBmp);

  if Assigned(Img) and Assigned(Img.Picture.Graphic) and
     (Img.Picture.Graphic.Width > 0) then
  begin
    Bmp := TBitmap.Create;
    try
      Bmp.SetSize(Img.Picture.Graphic.Width, Img.Picture.Graphic.Height);
      Bmp.Canvas.Draw(0, 0, Img.Picture.Graphic);
      FGameThumbBmp := Bmp;
    except
      Bmp.Free;
    end;
  end;

  goverlayPaintBox.Invalidate;
end;

procedure Tgoverlayform.LoadGlobalThumb;
var
  ImgPath: string;
begin
  FreeAndNil(FGameThumbBmp);
  // Load global icon only once
  if not Assigned(FGlobalThumbPng) then
  begin
    ImgPath := ExtractFilePath(Application.ExeName) + 'assets/icons/global-white.png';
    if FileExists(ImgPath) then
    begin
      FGlobalThumbPng := TPortableNetworkGraphic.Create;
      try
        FGlobalThumbPng.LoadFromFile(ImgPath);
      except
        FreeAndNil(FGlobalThumbPng);
      end;
    end;
  end;
  goverlayPaintBox.Invalidate;
end;

procedure Tgoverlayform.HideGameThumb;
begin
  LoadGlobalThumb;
end;

// ============================================================================
// Card hover brightness animation
// ============================================================================

procedure Tgoverlayform.ApplyCardBrightness(ACard: TPanel; BrightFactor: Integer);
var
  CardIdx: Integer;
  OrigIntf, DimIntf: TLazIntfImage;
  Img: TImage;
  DimBmp: TBitmap;
  SrcRow, DstRow: PByte;
  W, H, Stride, BPP, x, y, px: Integer;
begin
  if not Assigned(FCardPanels) or not Assigned(FOrigCovers) then Exit;
  CardIdx := FCardPanels.IndexOf(ACard);
  if (CardIdx < 0) or (CardIdx >= FOrigCovers.Count) then Exit;
  OrigIntf := TLazIntfImage(FOrigCovers[CardIdx]);
  if OrigIntf = nil then Exit;
  if (ACard.ControlCount = 0) or not (ACard.Controls[0] is TImage) then Exit;
  Img := TImage(ACard.Controls[0]);

  W      := OrigIntf.Width;
  H      := OrigIntf.Height;
  Stride := OrigIntf.DataDescription.BytesPerLine;
  BPP    := OrigIntf.DataDescription.BitsPerPixel div 8;

  DimIntf := TLazIntfImage.Create(W, H);
  DimIntf.DataDescription := OrigIntf.DataDescription;
  DimIntf.CreateData;
  try
    for y := 0 to H - 1 do
    begin
      SrcRow := OrigIntf.PixelData + PtrUInt(y * Stride);
      DstRow := DimIntf.PixelData  + PtrUInt(y * Stride);
      for x := 0 to W - 1 do
      begin
        px := x * BPP;
        DstRow[px]   := Byte(Integer(SrcRow[px])   * BrightFactor div 100);
        DstRow[px+1] := Byte(Integer(SrcRow[px+1]) * BrightFactor div 100);
        DstRow[px+2] := Byte(Integer(SrcRow[px+2]) * BrightFactor div 100);
        if BPP >= 4 then
          DstRow[px+3] := SrcRow[px+3];
      end;
    end;
    DimBmp := TBitmap.Create;
    try
      DimBmp.LoadFromIntfImage(DimIntf);
      Img.Picture.Bitmap.Assign(DimBmp);
      Img.Invalidate;
    finally
      DimBmp.Free;
    end;
  finally
    DimIntf.Free;
  end;
end;

procedure Tgoverlayform.ApplyAllCardsDim;
var
  i: Integer;
begin
  if not Assigned(FCardPanels) then Exit;
  for i := 0 to FCardPanels.Count - 1 do
    ApplyCardBrightness(TPanel(FCardPanels[i]), 100);
  FHoveredCard     := nil;
  FHoverBrightness := 0;
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

end.
