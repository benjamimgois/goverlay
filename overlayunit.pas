unit overlayunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, Forms, Controls, Graphics, Dialogs, ExtCtrls, Math,
  unix, BaseUnix, StdCtrls, Spin, ComCtrls, Buttons, ColorBox, ActnList, Menus, aboutunit, optiscaler_update, protontricksunit,
  ATStringProc_HtmlColor, blacklistUnit, customeffectsunit, LCLtype, CheckLst,Clipbrd, LCLIntf,
  FileUtil, StrUtils, gfxlaunch, Types,fpjson, jsonparser, git2pas, howto, themeunit, systemdetector, constants,
  fgmod_resources, hintsunit, qtwidgets, fpreadjpeg, configmanager, IntfGraphics;



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
    FStartTick: Cardinal;
    FOptiscalerUpdate: TOptiscalerTab;
    FReshadeProgressBar: TProgressBar;
    FReshadePhaseLabel: TLabel;
    FStatusTimer: TTimer;
    FGamesScrollBox: TScrollBox;
    FGamesPanel: TPanel;
    FGamesLoaded: Boolean;
    FCoverThread: TThread;
    FSelectedCard: TPanel;
    FActionBtns: array[0..3] of TPanel;
    FDimTimer:    TTimer;   // animates card dimming on selection
    FDimProgress: Integer;  // 0 = undimmed, 100 = fully dimmed
    FDimDir:      Integer;  // +1 dimming, -1 undimming
    FCardPanels:  TList;    // ordered list of game card TPanels
    FOrigCovers:  TList;    // parallel list of TLazIntfImage originals (owned)
    FActiveGameName:    string;   // non-empty when editing a game-specific config
    FGameContextLabel:  TLabel;   // bottom-bar label showing the active game name
    FGameThumbBmp:      TBitmap;              // game cover drawn on the sidebar paintbox
    FGlobalThumbPng:    TPortableNetworkGraphic; // global-config icon (white, transparent)
    FGameCardMenu: TPopupMenu;      // right-click context menu for game cards
    FRightClickedCard: TPanel;      // card that triggered the context menu

    // Nav rail
    FNavItems:       array of TPanel;    // item panels
    FNavIndicators:  array of TShape;    // left indicator bars
    FNavIcons:       array of TLabel;    // unicode icon labels
    FNavLabels:      array of TLabel;    // caption labels
    FNavActive:      Integer;            // index of active item (-1 = none)
    FNavHoveredIdx:  Integer;            // index of hovered item (-1 = none)
    FNavClickCBs:    array of TNotifyEvent; // click callbacks per item
    FNavCollapsed:   Boolean;            // sidebar collapsed state
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
    FCubeAutoLaunch:     Boolean;    // whether to auto-launch pascube/vkcube

    // Per-tool enable toggles (game mode only) — indices 0=MangoHud 1=vkBasalt 2=OptiScaler 3=Tweaks
    FNavToolBtns:    array[0..3] of TSpeedButton;
    FNavToolEnabled: array[0..3] of Boolean;

    // Home tab
    FHomeTabSheet:     TTabSheet;
    FHomeModDots:      array[0..2] of TShape;   // status dots: MangoHud, vkBasalt, OptiScaler
    FHomeModVerLbls:   array[0..2] of TLabel;   // version text
    FHomeOptiLbls:     array[0..4] of TLabel;   // library version labels: FakeNvAPI, Optipatcher, FSR, XeSS, DLSS
    FHomeLibDots:      array[0..4] of TShape;   // library status dots
    FHomeDepDots:      array[0..8] of TShape;
    FHomeDepLbls:      array[0..8] of TLabel;
    FHomeGlobalBtn:    TPanel;
    FHomeGameBtn:      TPanel;
    FHomeBtnRow:       TPanel;

    procedure BuildNavRail;
    procedure BuildPresetsWrapper;
    procedure BuildSettingsButton;
    procedure RestoreNavRailColors;
    procedure SettingsBtnMouseEnter(Sender: TObject);
    procedure SettingsBtnMouseLeave(Sender: TObject);
    procedure SettingsBtnClick(Sender: TObject);
    procedure CubeAutoLaunchMenuItemClick(Sender: TObject);
    procedure BuildNavToolToggles;
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
    procedure RemoveTweaksFromGameFGMod(const AFGModFile: string);
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
    procedure ReflowPerformanceTab(AContentW: Integer);
    procedure ReflowOptiScalerTab(AContentW: Integer);
    procedure ReflowTweaksTab(AContentW: Integer);

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
    procedure ShowGameActionPanel(ACard: TPanel);
    procedure HideGameActionPanel;
    procedure GameActionBtnMouseEnter(Sender: TObject);
    procedure GameActionBtnMouseLeave(Sender: TObject);
    procedure GameActionBtnClick(Sender: TObject);
    function  GetGameConfigDir(const AGameName: string): string;
    function  SanitizeFileName(const AName: string): string;
    function  GetMangoHudConfigEnvPrefix: string;
    function  GetMangoHudLaunchEnv: string;
    function  GetVkBasaltConfigEnvPrefix: string;
    function  GetVkBasaltLaunchEnv: string;
    procedure UpdateGameContextLabel;
    procedure LoadGlobalThumb;
    procedure ShowGameThumb(ACard: TPanel);
    procedure HideGameThumb;
    function  DimmedCardColor: TColor;
    procedure ApplyDimToCards;
    procedure StartDimAnimation(ADimming: Boolean);
    procedure DimTimerTick(Sender: TObject);
    procedure RestoreCardImageFromOriginal(ACard: TPanel);
    function ParseAcfValue(const AContent, AKey: string): string;
    procedure GetSteamLibraries(Libraries: TStringList);

    function GetGeneralCheckBox(Index: Integer): TCheckBox;
    function GetGraphicsCheckBox(Index: Integer): TCheckBox;
    function GetPerformanceCheckBox(Index: Integer): TCheckBox;
    procedure ReshadeGitProgress(APhase: string; APercent: Integer);
    procedure UpdateGeSpeedButtonState;
    procedure UpdateGlobalEnableMenuItemVisibility;
    procedure RemoveMangoHudFromFGMod;
    procedure LoadTweaksFromFGMod;
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

  // Nav rail
  NAV_ITEM_H      = 64;   // height of each nav item
  NAV_ITEM_W      = 211;  // width (same as sidebar)
  NAV_INDICATOR_W = 3;    // active indicator bar width
  NAV_ICON_SIZE   = 28;   // icon area size
  NAV_COLOR_BG        = $00221F1E; // item normal background (dark)
  NAV_COLOR_HOVER     = $00332E2C; // item hover background (dark)
  NAV_COLOR_ACTIVE    = $00443E3A; // item active background (dark)
  NAV_COLOR_INDICATOR = clHighlight; // active indicator — system accent/selection color
  // Light theme nav colors
  NAV_LIGHT_BG        = $00E8E8E8;
  NAV_LIGHT_HOVER     = $00D0D0D0;
  NAV_LIGHT_ACTIVE    = $00C0C0C0;
  NAV_W_EXPANDED  = 211;
  NAV_W_COLLAPSED = 60;
implementation

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
    FCurrentImage: TImage;
    FCurrentPath:  string;
    procedure DoUpdateImage;
  protected
    procedure Execute; override;
  public
    constructor Create(AAppIDs: TStringList; AImages: TList;
                       const ACacheDir: string);
    destructor Destroy; override;
  end;

constructor TCoverDownloadThread.Create(AAppIDs: TStringList; AImages: TList;
  const ACacheDir: string);
begin
  inherited Create(True);
  FAppIDs   := AAppIDs;
  FImages   := AImages;
  FCacheDir := ACacheDir;
  FreeOnTerminate := False;
end;

destructor TCoverDownloadThread.Destroy;
begin
  FAppIDs.Free;
  FImages.Free;
  inherited;
end;

procedure TCoverDownloadThread.DoUpdateImage;
begin
  if Assigned(FCurrentImage) and FileExists(FCurrentPath) then
  begin
    try
      FCurrentImage.Picture.LoadFromFile(FCurrentPath);
    except
    end;
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
  DbgLog('>> tweaksLabelClick BEGIN');
  SetNavActive(3);

//Enable goverlay tabs
goverlayPageControl.ShowTabs:=false; //disable mangohud tab
vkbasalttabsheet.TabVisible:=false; //disable vkbasalt tab
optiscalertabsheet.TabVisible:=false; //disable optiscaler tab
gamesTabSheet.TabVisible:=false; //disable games tab
tweakstabsheet.TabVisible:=true;

goverlayPageControl.ActivePage:=tweaksTabsheet;

//Hide notification messages
notificationLabel.Visible:=false;
commandEdit.Visible:=false;
copyBitbtn.Visible:=false;

//Show Global Enable controls and bottom bar for tweaks tabs


goverlaybarPanel.Visible:=true;
UpdateGeSpeedButtonState;
UpdateGlobalEnableMenuItemVisibility;
// Re-apply per-game tool enabled state for Tweaks
if FActiveGameName <> '' then
begin
  ApplyToolEnabledState(3, FNavToolEnabled[3]);
  SetSaveBtnEnabled(FNavToolEnabled[3]);
end;

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

  SetNavActive(1);

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
  commandEdit.Visible:=false;
  copyBitbtn.Visible:=false;

  //Restore bottom bar
  goverlaybarPanel.Visible:=true;
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
  BlockSize    = 4;   // block size in pixels
  THUMB_MARGIN = 8;
  THUMB_GAP    = 12;
var
  X, Y, TWidth, THeight: Integer;
  BaseR, BaseG, BaseB: Byte;
  Factor, OffsetX, OffsetY: Single;
  R, G, B: Byte;
  TimeElapsed: Single;
  ThumbY, ThumbW, ThumbH: Integer;
  ThumbDst: TRect;
  AvailH, IconTop: Integer;
  RectRight, RectBottom: Integer;
  OffBmp: TBitmap;
begin
  BaseR := 36;  // 0x24
  BaseG := 50;  // 0x32
  BaseB := 70;  // 0x46

  TWidth  := goverlayPaintBox.Width;
  THeight := goverlayPaintBox.Height;

  TimeElapsed := (GetTickCount - FStartTick) / 1000;

  // Render the animated background to an off-screen bitmap first, then blit
  // it to the paintbox in a single Draw call. This avoids tens of thousands
  // of individual FillRect calls hitting the Qt widget per frame, which was
  // the primary source of CPU overhead.
  OffBmp := TBitmap.Create;
  try
    OffBmp.SetSize(TWidth, THeight);

    Y := 0;
    while Y < THeight do   // THeight: paintbox height (was form Height — bug fix)
    begin
      X := 0;
      while X < TWidth do  // TWidth:  paintbox width  (was form Width  — bug fix)
      begin
        OffsetX := Sin((X * 0.01) + TimeElapsed * 0.5) + Sin((Y * 0.015) + TimeElapsed * 0.6);
        OffsetY := Cos((X * 0.015) - TimeElapsed * 0.4) + Cos((Y * 0.01) - TimeElapsed * 0.45);

        Factor := 0.3 + 0.35 * (OffsetX + 1) + 0.35 * (OffsetY + 1);
        if Factor > 1.0 then Factor := 1.0;
        if Factor < 0.3 then Factor := 0.3;

        R := Round(BaseR * Factor);
        G := Round(BaseG * Factor);
        B := Round(BaseB * Factor);

        RectRight  := X + BlockSize;
        if RectRight  > TWidth  then RectRight  := TWidth;
        RectBottom := Y + BlockSize;
        if RectBottom > THeight then RectBottom := THeight;

        OffBmp.Canvas.Brush.Color := RGBToColor(R, G, B);
        OffBmp.Canvas.FillRect(Rect(X, Y, RectRight, RectBottom));

        Inc(X, BlockSize);
      end;
      Inc(Y, BlockSize);
    end;

    // Single blit: replaces thousands of per-block Qt canvas round-trips
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
         and (FNavActive >= 0) then
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

    // Save to active config file (game-specific or global)
    ConfigLines.SaveToFile(MANGOHUDCFGFILE);

    // Also save to Steam Flatpak MangoHud config location — global mode only.
    // Game-specific configs are applied via the launch command, not this path.
    if FActiveGameName <> '' then Exit;

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
              casTrackBar.Position := 5; // default value
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

  // Detach all anchor-side control references for every groupbox we reflow
  // manually (Visual + Performance tabs). Without this the LCL anchor engine
  // keeps repositioning them even when Anchors = [akTop, akLeft].
  orientationGroupBox.AnchorSideLeft.Control  := nil;
  orientationGroupBox.AnchorSideRight.Control := nil;
  orientationGroupBox.AnchorSideTop.Control   := nil;
  orientationGroupBox.Anchors                 := [akTop, akLeft];

  borderGroupBox.AnchorSideLeft.Control       := nil;
  borderGroupBox.AnchorSideRight.Control      := nil;
  borderGroupBox.AnchorSideTop.Control        := nil;
  borderGroupBox.Anchors                      := [akTop, akLeft];

  backgroundGroupBox.AnchorSideLeft.Control   := nil;
  backgroundGroupBox.AnchorSideRight.Control  := nil;
  backgroundGroupBox.AnchorSideTop.Control    := nil;
  backgroundGroupBox.Anchors                  := [akTop, akLeft];

  fontsGroupBox.AnchorSideLeft.Control        := nil;
  fontsGroupBox.AnchorSideTop.Control         := nil;
  fontsGroupBox.Anchors                       := [akTop, akLeft];

  positionGroupBox.AnchorSideLeft.Control     := nil;
  positionGroupBox.AnchorSideTop.Control      := nil;
  positionGroupBox.Anchors                    := [akTop, akLeft];

  columsGroupBox.AnchorSideLeft.Control       := nil;
  columsGroupBox.AnchorSideTop.Control        := nil;
  columsGroupBox.Anchors                      := [akTop, akLeft];

  vsyncGroupBox.AnchorSideRight.Control       := nil;
  vsyncGroupBox.AnchorSideTop.Control         := nil;
  vsyncGroupBox.Anchors                       := [akTop, akLeft];

  filtersGroupBox.AnchorSideRight.Control     := nil;
  filtersGroupBox.AnchorSideBottom.Control    := nil;
  filtersGroupBox.AnchorSideTop.Control       := nil;
  filtersGroupBox.Anchors                     := [akTop, akLeft];

  // Detach anchor-side control references for Tweaks tab inner groupboxes
  generalGroupBox.AnchorSideLeft.Control      := nil;
  generalGroupBox.AnchorSideTop.Control       := nil;
  generalGroupBox.Anchors                     := [akTop, akLeft];

  graphicsGroupBox.AnchorSideLeft.Control     := nil;
  graphicsGroupBox.AnchorSideTop.Control      := nil;
  graphicsGroupBox.Anchors                    := [akTop, akLeft];

  performanceGroupBox.AnchorSideLeft.Control  := nil;
  performanceGroupBox.AnchorSideTop.Control   := nil;
  performanceGroupBox.Anchors                 := [akTop, akLeft];

  customenvEdit.Anchors                       := [akTop, akLeft];

  // Detach anchor-side control references for OptiScaler tab inner groupboxes
  optiscalerGroupBox.AnchorSideLeft.Control   := nil;
  optiscalerGroupBox.AnchorSideRight.Control  := nil;
  optiscalerGroupBox.AnchorSideTop.Control    := nil;
  optiscalerGroupBox.AnchorSideBottom.Control := nil;
  optiscalerGroupBox.Anchors                  := [akTop, akLeft];

  imgmenuGroupBox.AnchorSideLeft.Control      := nil;
  imgmenuGroupBox.AnchorSideRight.Control     := nil;
  imgmenuGroupBox.AnchorSideTop.Control       := nil;
  imgmenuGroupBox.AnchorSideBottom.Control    := nil;
  imgmenuGroupBox.Anchors                     := [akTop, akLeft];

  fakenvapiGroupBox.AnchorSideLeft.Control    := nil;
  fakenvapiGroupBox.AnchorSideRight.Control   := nil;
  fakenvapiGroupBox.AnchorSideTop.Control     := nil;
  fakenvapiGroupBox.AnchorSideBottom.Control  := nil;
  fakenvapiGroupBox.Anchors                   := [akTop, akLeft];

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

  // Update settings menu theme item caption based on loaded theme
  if SavedTheme = tmLight then
    themeMenuItem.Caption := 'Switch to Dark theme'
  else
    themeMenuItem.Caption := 'Switch to Light theme';

  // Bring settings button to front to ensure it's visible
  settingsSpeedButton.BringToFront;



  //Hide howto button until OptiScaler configuration is saved
  howtoBitBtn.Visible := False;

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


  // Dependencies are shown in the settings menu; hide sidebar widgets
  dependencieSpeedButton.Visible := False;
  dependenciesLabel.Visible      := False;

  //Check for dependencies
   if CheckDependencies(Missing) then
   begin
    dependencieSpeedbutton.ImageIndex := 0 ; //green icon
    dependenciesLabel.Caption := 'All dependencies OK' ;
    if Assigned(FDepsMenuItem) then
      FDepsMenuItem.Caption := '✓  All dependencies OK';
   end
  else
  begin
    dependencieSpeedbutton.ImageIndex := 1 ;  //red icon
    dependenciesLabel.Caption := ('Missing: ' + LineEnding + Missing.Text);
    if Assigned(FDepsMenuItem) then
      FDepsMenuItem.Caption := '⚠  Missing: ' + Missing.CommaText;
    
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



     //Select home as initial option
     ShowHomeTab;

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

    // Populate Home tab OptiScaler component labels after update check
    RefreshHomeOptiStatus;

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
    HideGameActionPanel;
    LoadGameToggleStates;  // reset all tools to enabled, hide toggles
    SetSaveBtnEnabled(True);
  end;

  SetNavActive(-1);

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
  commandEdit.Visible:=false;
  copyBitbtn.Visible:=false;

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

  SetNavActive(0);

//Enable goverlay tabs
goverlayPageControl.ShowTabs:=true;
vkbasalttabsheet.TabVisible:=false; //disable vkbasalt tab
optiscalertabsheet.TabVisible:=false; //disable optiscaler tab
tweakstabsheet.TabVisible:=false;  //disable tweaks tab
gamesTabSheet.TabVisible:=false; //disable games tab

goverlayPageControl.ActivePage:=presetTabsheet;

//Hide notification messages
notificationLabel.Visible:=false;
commandEdit.Visible:=false;
copyBitbtn.Visible:=false;

//Show Global Enable controls and bottom bar for MangoHud tabs


goverlaybarPanel.Visible:=true;
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
  SetNavActive(2);

//Disable tabs
  goverlayPageControl.ShowTabs:=false;
  vkbasalttabsheet.TabVisible:=false;
  tweakstabsheet.TabVisible:=false;
  gamesTabSheet.TabVisible:=false; //disable games tab

  optiscalertabsheet.TabVisible:=true;
  goverlayPageControl.ActivePage:= optiscalerTabsheet;

  //Hide notification messages
  notificationLabel.Visible:=false;
  commandEdit.Visible:=false;
  copyBitbtn.Visible:=false;

  //Restore bottom bar
  goverlaybarPanel.Visible:=true;
  //Update geSpeedButton state for OptiScaler
  UpdateGeSpeedButtonState;
  UpdateGlobalEnableMenuItemVisibility;
  // Re-apply per-game tool enabled state (overrides UpdateGeSpeedButtonState if tool is disabled)
  if FActiveGameName <> '' then
  begin
    ApplyToolEnabledState(2, FNavToolEnabled[2]);
    SetSaveBtnEnabled(FNavToolEnabled[2]);
  end;
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
  // Disable emufp8CheckBox when "4.0.2b (INT8)" is selected (ItemIndex = 1)
  // Enable emufp8CheckBox when "Latest (FP8)" is selected (ItemIndex = 0)
  case fsrversionComboBox.ItemIndex of
    0: // Latest (FP8)
      begin
        emufp8CheckBox.Enabled := True;
      end;
    1: // 4.0.2b (INT8)
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
  GlobalMangoHudFile: string;  // Global MangoHud config path (for blacklist — never game-specific)

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
  Fsr4UpdateValue: string;
  Fsr4UpdateFound: Boolean;

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
                // Insert lines in reverse order so they appear in correct order after insertion.
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

            // Handle "Simulate Steam Deck" (index 0).
            // Try to modify existing SteamDeck line first; if not found, leave as-is
            // (the embedded fgmod template already contains 'export SteamDeck=0' after the anchor).
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
           (Trim(customenvEdit.Text) <> '') then
        begin
          // Auto-enable Auto Enable and save
          geSpeedButton.ImageIndex := 1;
          saveBitBtnClick(Sender);
          Exit;
        end
        else
        begin
          // No tweaks selected and Auto Enable is OFF - just show notification
          SendNotification('Tweaks', 'Nenhuma tweak selecionada para guardar', GetIconFile);
        end;
      end;

      // Always build launch command with full absolute path for fgmod (quoted for spaces)
      LaunchCommand := '"' + GetFGModPath + '/fgmod" ';
      // Index 1: "Always use GameMode" -> -- env gamemoderun (before %command%)
      if GetGeneralCheckBox(1).Checked then
        LaunchCommand := LaunchCommand + '-- env gamemoderun ';
      // Always end with %command%
      LaunchCommand := LaunchCommand + '%command%';

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

          // Get Fsr4Update value from fsrversionComboBox
          if fsrversionComboBox.ItemIndex = 0 then
            Fsr4UpdateValue := 'true'
          else
            Fsr4UpdateValue := 'auto';

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
                  Fsr4UpdateFound := False;
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

                    // Check for Fsr4Update line
                    if Pos('Fsr4Update=', OptiScalerIniLines[LineIndex]) > 0 then
                    begin
                      // Replace the line with the new Fsr4Update value
                      OptiScalerIniLines[LineIndex] := 'Fsr4Update=' + Fsr4UpdateValue;
                      Fsr4UpdateFound := True;
                    end;

                    // Exit loop if all found
                     if ShortcutKeyFound and ScaleFound and OverrideNvapiDllFound and DxgiFound and LoadAsiPluginsFound and Fsr4UpdateFound then
                       Break;
                  end;

                  if not LoadAsiPluginsFound then
                    OptiScalerIniLines.Add('LoadAsiPlugins=' + LoadAsiPluginsValue);

                  if not Fsr4UpdateFound then
                    OptiScalerIniLines.Add('Fsr4Update=' + Fsr4UpdateValue);

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

                1: // 4.0.2b (INT8)
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
                          Lines.Add('fsrversion=4.0.2b (INT8)');

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

            // Build launch command with full absolute path (quoted for spaces)
            LaunchCommand := '"' + GetFGModPath + '/fgmod" ';

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
    end;

    //########################################### SAVE BLACKLIST
    // The blacklist is always applied to the global MangoHud.conf (it filters
    // process names system-wide). Use a local variable so that MANGOHUDCFGFILE
    // continues to point to the game-specific path when in game mode.

  BLACKLISTFILE := GetUserConfigDir + '/goverlay/blacklist.conf';
  GlobalMangoHudFile := IncludeTrailingPathDelimiter(GetMangoHudConfigDir()) + 'MangoHud.conf';

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
    if FileExists(GlobalMangoHudFile) then
      ConfigLines.LoadFromFile(GlobalMangoHudFile);


    // if there's no blacklist, add it to the end of file
    if not Found then
    begin
      ConfigLines.Add(blacklistVAR);
    end;

    // make sure mangohud directory exists (use CreateHostDirectory for Flatpak compatibility)
    CreateHostDirectory(ExtractFilePath(GlobalMangoHudFile));

    // Save changes to mangohud file
    ConfigLines.SaveToFile(GlobalMangoHudFile);


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
     if EffectsLine <> '' then
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

     // Always show the fgmod command — use game-specific fgmod copy when in game mode
     // Quoted to handle spaces in game names / paths.
     if FActiveGameName <> '' then
       LaunchCommand := '"' + GetGameConfigDir(FActiveGameName) + 'fgmod" '
     else
       LaunchCommand := '"' + GetFGModPath + '/fgmod" ';

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

   except
     on E: Exception do
       ShowMessage('Fail to save vkbasalt.conf: ' + E.Message);
   end;
   Lines.Free;






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

// ============================================================================
// PRESETS WRAPPER — centered fixed-width panel for the Presets tab
// ============================================================================

procedure Tgoverlayform.BuildPresetsWrapper;
const
  WRAPPER_W = 829;
var
  i: Integer;
  CtrlsToMove: array of TControl;
begin
  // Snapshot existing children of presetTabSheet before adding the wrapper
  SetLength(CtrlsToMove, presetTabSheet.ControlCount);
  for i := 0 to presetTabSheet.ControlCount - 1 do
    CtrlsToMove[i] := presetTabSheet.Controls[i];

  FPresetsWrapper := TPanel.Create(Self);
  FPresetsWrapper.Parent      := presetTabSheet;
  FPresetsWrapper.BevelOuter  := bvNone;
  FPresetsWrapper.BorderStyle := bsNone;
  FPresetsWrapper.Caption     := '';
  FPresetsWrapper.ParentColor := True;
  FPresetsWrapper.Top         := 0;
  FPresetsWrapper.Left        := 0;
  FPresetsWrapper.Width       := WRAPPER_W;
  FPresetsWrapper.Anchors     := [akTop, akBottom];
  FPresetsWrapper.Height      := presetTabSheet.ClientHeight;

  // Re-parent all existing controls into the wrapper
  for i := 0 to High(CtrlsToMove) do
    CtrlsToMove[i].Parent := FPresetsWrapper;
end;

// NAV RAIL — modern sidebar navigation
// ============================================================================

procedure Tgoverlayform.BuildNavRail;
const
  // Item definitions: (unicode icon, caption, top offset)
  ITEMS: array[0..3] of record Icon, Caption: string; end = (
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

  FNavClickCBs[0] := @mangohudLabelClick;
  FNavClickCBs[1] := @vkbasaltLabelClick;
  FNavClickCBs[2] := @optiscalerLabelClick;
  FNavClickCBs[3] := @tweaksLabelClick;

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
  FNavSmallIcon.Cursor       := crHandPoint;
  FNavSmallIcon.OnClick      := @ShowHomeTab;
  FNavSmallIcon.Visible      := False;
  // Load icon — try installed path first, then local data dir
  IconPath := GetIconFile();
  if not FileExists(IconPath) then
    IconPath := ExtractFilePath(Application.ExeName) + 'data/icons/128x128/goverlay.png';
  if FileExists(IconPath) then
    try FNavSmallIcon.Picture.LoadFromFile(IconPath); except end;

  // Make the large logo clickable too
  goverlayimage.Cursor       := crHandPoint;
  goverlayimage.OnClick      := @ShowHomeTab;

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

    if i = 2 then
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
    else if i = 0 then
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
  FDepsMenuItem.Caption := '● Checking dependencies…';
  FDepsMenuItem.Enabled := False;  // informational only
  settingsMenu.Items.Insert(0, FDepsMenuItem);

  // Separator after deps item
  Sep := TMenuItem.Create(settingsMenu);
  Sep.Caption := '-';
  settingsMenu.Items.Insert(1, Sep);

  // Auto-launch cube toggle
  FCubeAutoLaunchItem := TMenuItem.Create(settingsMenu);
  FCubeAutoLaunchItem.Caption := 'Auto-launch PasCube/VkCube';
  FCubeAutoLaunchItem.Checked := FCubeAutoLaunch;
  FCubeAutoLaunchItem.OnClick := @CubeAutoLaunchMenuItemClick;
  settingsMenu.Items.Insert(2, FCubeAutoLaunchItem);

  Sep := TMenuItem.Create(settingsMenu);
  Sep.Caption := '-';
  settingsMenu.Items.Insert(3, Sep);
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
    Btn.Parent    := FNavItems[i];
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
        '[[ "$GOVERLAY_MANGOHUD" != "0" ]] && export MANGOHUD=1',
        'MANGOHUD=1');
    if Idx = 1 then
      PatchGameFGModConditionalExport(GameCfgDir + 'fgmod',
        '[[ "$GOVERLAY_VKBASALT" != "0" ]] && export ENABLE_VKBASALT=1',
        'ENABLE_VKBASALT=1');
    // OptiScaler toggle also controls the WINEDLLOVERRIDES line in the game's fgmod
    if Idx = 2 then
    begin
      PatchGameFGModWineDllOverrides(GameCfgDir + 'fgmod', NewEnabled);
      // When re-enabling OptiScaler, restore OptiScaler.ini from the pristine
      // fgmod original so the game gets a valid config on the next launch.
      if NewEnabled and not FileExists(GameCfgDir + 'OptiScaler.ini') then
        CopyFile(GetFGModOriginalPath + PathDelim + 'OptiScaler.ini',
                 GameCfgDir + 'OptiScaler.ini', True);
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
        end
        else
        begin
          // Collapsed: small button below the icon, horizontally centred
          BtnW    := BTN_SMALL;
          BtnLeft := (NAV_W_COLLAPSED - BtnW) div 2;
          BtnTop  := ICON_TOP_C + NAV_ICON_SIZE + 4;
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
  Result := True;  // default: enabled
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

procedure Tgoverlayform.PatchGameFGModWineDllOverrides(const AFGModFile: string; AEnabled: Boolean);
const
  CONDITIONAL_LINE = '[[ "$GOVERLAY_OPTISCALER" != "0" ]] && export WINEDLLOVERRIDES="$WINEDLLOVERRIDES,dxgi=n,b"';
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
      FNavIndicators[i].Visible := True;
      FNavIcons[i].Font.Color   := IfThen(CurrentTheme = tmLight, clBlack, clWhite);
      FNavLabels[i].Font.Color  := IfThen(CurrentTheme = tmLight, clBlack, clWhite);
      if (i = 2) and Assigned(FOptiScalerImg) then
      begin
        IconPath := ExtractFilePath(Application.ExeName) + 'assets/icons/scale-up2-active.png';
        if FileExists(IconPath) then
          try FOptiScalerImg.Picture.LoadFromFile(IconPath); except end;
      end;
      if (i = 0) and Assigned(FMangoHudImg) then
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
      if (i = 2) and Assigned(FOptiScalerImg) then
      begin
        IconPath := ExtractFilePath(Application.ExeName) + 'assets/icons/scale-up2.png';
        if FileExists(IconPath) then
          try FOptiScalerImg.Picture.LoadFromFile(IconPath); except end;
      end;
      if (i = 0) and Assigned(FMangoHudImg) then
      begin
        IconPath := ExtractFilePath(Application.ExeName) + 'assets/icons/mango-inactive.png';
        if FileExists(IconPath) then
          try FMangoHudImg.Picture.LoadFromFile(IconPath); except end;
      end;
    end;
    FNavItems[i].Invalidate;
  end;

  if FNavActive = 0 then
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
    ApplyNavWidth(NextW);
end;

procedure Tgoverlayform.ApplyNavWidth(AWidth: Integer);
var
  i, PanelLeft, ContentW: Integer;
  ShowLabels: Boolean;
begin
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
  ReflowOptiScalerTab(ContentW);
  ReflowTweaksTab(ContentW);
  if FGamesLoaded then
    ReflowGamesGrid;

  // Repaint sidebar so the thumbnail scales with the nav width
  if Assigned(FGameThumbBmp) then
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
  ReflowOptiScalerTab(ContentW);
  ReflowTweaksTab(ContentW);

  if FGamesLoaded then
    ReflowGamesGrid;
end;

// ============================================================================
// TAB REFLOW — redistribute controls when the window is resized
// ============================================================================

procedure Tgoverlayform.ReflowPresetTab(AContentW: Integer);
const
  MIN_GAP   = 8;
  BTN_W     = 123;
  BTN_H     = 91;
  WRAPPER_W = 829;
var
  W, Gap5, Gap4, StartX5, StartX4, X, i: Integer;
  LayoutBtns:   array[0..4] of TBitBtn;
  LayoutLabels: array[0..4] of TLabel;
  ColorBtns:    array[0..3] of TBitBtn;
  ColorLabels:  array[0..3] of TLabel;
begin
  // Center the fixed-width wrapper; icons inside never reflow on sidebar toggle
  if Assigned(FPresetsWrapper) then
  begin
    FPresetsWrapper.Left   := Max(0, (AContentW - WRAPPER_W) div 2);
    FPresetsWrapper.Height := presetTabSheet.ClientHeight;
  end;
  W := WRAPPER_W;

  LayoutBtns[0] := fullBitBtn;            LayoutLabels[0] := fullLabel;
  LayoutBtns[1] := basicBitBtn;           LayoutLabels[1] := basicLabel;
  LayoutBtns[2] := basichorizontalBitBtn; LayoutLabels[2] := basichorizontalLabel;
  LayoutBtns[3] := fpsonlyBitBtn;         LayoutLabels[3] := fpsonlyLabel;
  LayoutBtns[4] := usercustomBitBtn;      LayoutLabels[4] := customLabel;

  ColorBtns[0] := mangocolorBitBtn;         ColorLabels[0] := mangocolorLabel;
  ColorBtns[1] := goverlayBitBtn;           ColorLabels[1] := customolorLabel;
  ColorBtns[2] := whitecolorBitBtn;         ColorLabels[2] := whitecolorLabel;
  ColorBtns[3] := afterburnercolorBitBtn1;  ColorLabels[3] := afterburnercolorLabel;

  // Row 1: 5 buttons — Left is centered in code; Top comes from .lfm button position.
  // Labels are placed 8px below their button bottom so they follow .lfm vertical layout.
  Gap5    := Max(MIN_GAP, (W - 5 * BTN_W) div 6);
  StartX5 := (W - 5 * BTN_W - 4 * Gap5) div 2;
  layoutsLabel.Left := Max(8, W * 20 div 829);
  for i := 0 to 4 do
  begin
    X := StartX5 + i * (BTN_W + Gap5);
    LayoutBtns[i].SetBounds(X, LayoutBtns[i].Top, BTN_W, BTN_H);
    LayoutLabels[i].Left := X + (BTN_W - LayoutLabels[i].Width) div 2;
    LayoutLabels[i].Top  := LayoutBtns[i].Top + BTN_H + 8;
  end;

  // Row 2: 4 buttons — same approach; Top derives from button's .lfm Top.
  Gap4    := Max(MIN_GAP, (W - 4 * BTN_W) div 5);
  StartX4 := (W - 4 * BTN_W - 3 * Gap4) div 2;
  colorthemeLabel.Left := Max(8, W * 20 div 829);
  for i := 0 to 3 do
  begin
    X := StartX4 + i * (BTN_W + Gap4);
    ColorBtns[i].SetBounds(X, ColorBtns[i].Top, BTN_W, BTN_H);
    ColorLabels[i].Left := X + (BTN_W - ColorLabels[i].Width) div 2;
    ColorLabels[i].Top  := ColorBtns[i].Top + BTN_H + 8;
  end;

  // Ensure section + card labels use the correct theme text color.
  // presetTabSheet has Font.Color=clWhite in the .lfm, which can bleed into
  // labels when light theme is active.
  if CurrentTheme = tmLight then
  begin
    layoutsLabel.Font.Color    := LightTextColor;
    colorthemeLabel.Font.Color := LightTextColor;
    for i := 0 to 4 do LayoutLabels[i].Font.Color := LightTextColor;
    for i := 0 to 3 do ColorLabels[i].Font.Color  := LightTextColor;
  end
  else
  begin
    layoutsLabel.Font.Color    := DarkTextColor;
    colorthemeLabel.Font.Color := DarkTextColor;
    for i := 0 to 4 do LayoutLabels[i].Font.Color := DarkTextColor;
    for i := 0 to 3 do ColorLabels[i].Font.Color  := DarkTextColor;
  end;
end;

procedure Tgoverlayform.ReflowVisualTab(AContentW: Integer);
const
  // Original layout at base AContentW=829
  BASE_W    = 829;
  BASE_COLW = 216;
  BASE_GAP  = 76;
  ROW1_T    = 135;
  H1        = 131;
  H2        = 189;
  ROW_GAP   = 40;
  MIN_COLW  = 160;
  MIN_GAP   = 8;
var
  ColW, Gap, Center, C1, C2, C3, Row2T: Integer;
begin
  ColW   := Max(MIN_COLW, AContentW * BASE_COLW div BASE_W);
  Gap    := Max(MIN_GAP,  AContentW * BASE_GAP  div BASE_W);
  // Middle column centered on the content area; C1 and C3 are symmetric
  Center := AContentW div 2;
  C2     := Center - ColW div 2;
  C1     := C2 - Gap - ColW;
  C3     := C2 + ColW + Gap;
  // Guard: if C1 clips off the left edge, fall back to left-flush
  if C1 < 4 then
  begin
    C1 := 4;
    C2 := C1 + ColW + Gap;
    C3 := C2 + ColW + Gap;
  end;
  Row2T := ROW1_T + H1 + ROW_GAP;

  // Row 1
  orientationGroupBox.SetBounds(C1, ROW1_T, ColW, H1);
  borderGroupBox.SetBounds(C2, ROW1_T, ColW, H1);
  backgroundGroupBox.SetBounds(C3, ROW1_T, ColW, H1);

  // Row 2
  fontsGroupBox.SetBounds(C1, Row2T, ColW, H2);
  positionGroupBox.SetBounds(C2, Row2T, ColW, H2);
  columsGroupBox.SetBounds(C3, Row2T, ColW, H2);
end;

procedure Tgoverlayform.ReflowPerformanceTab(AContentW: Integer);
const
  // Two equal columns symmetric around the content center.
  // At base AContentW=829: C1=2, ColW=386, Gap=47, C2=435
  BASE_GAP = 47;   // fixed gap between columns
  BASE_C1  = 2;    // left margin (also used as right margin for symmetry)
  MIN_COLW = 200;
var
  Center, ColW, C1, C2: Integer;
begin
  Center := AContentW div 2;
  // Each column spans from its margin to half the gap from center
  ColW := Max(MIN_COLW, Center - BASE_C1 - BASE_GAP div 2);
  C1   := BASE_C1;
  C2   := AContentW - BASE_C1 - ColW;  // right-anchored, mirror of C1

  // Left column
  fpsGroupBox.SetBounds(C1, fpsGroupBox.Top, ColW, fpsGroupBox.Height);
  fpslimiterGroupBox.SetBounds(C1, fpslimiterGroupBox.Top, ColW, fpslimiterGroupBox.Height);

  // Right column
  vsyncGroupBox.SetBounds(C2, vsyncGroupBox.Top, ColW, vsyncGroupBox.Height);
  filtersGroupBox.SetBounds(C2, filtersGroupBox.Top, ColW, filtersGroupBox.Height);
end;

procedure Tgoverlayform.ReflowOptiScalerTab(AContentW: Integer);
const
  // Lateral boxes have fixed widths; ImGUI Menu fills the center.
  // At base AContentW=828 the ImGUI center (410px) coincides with the
  // optionsGroupBox center (820/2=410), so we use that as the anchor.
  W1      = 252;   // optiscalerGroupBox — fixed width, left-anchored
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

procedure Tgoverlayform.ReflowTweaksTab(AContentW: Integer);
const
  // At base AContentW=828:
  //   basicGroupBox:   Left=2,  Width=824, Client=820
  //   advancedGroupBox: Left=5, Width=818, Client=814
  // Each contains 2 inner sections; inner boxes use center anchor (left/right symmetric).
  MARGIN_B   = 5;    // inner margin inside basicGroupBox
  GAP_B      = 10;   // gap between generalGroupBox and graphicsGroupBox
  MIN_COLW_B = 140;

  MARGIN_A   = 5;    // inner margin inside advancedGroupBox
  GAP_A      = 25;   // gap between performanceGroupBox and customenvEdit
  MIN_COLW_A = 140;
  MIN_EDIT_W = 150;

  BOX_H      = 137;  // inner groupbox height (fixed)
  BOX_TOP    = 5;
var
  InnB, CenterB, ColWB, C1B, C2B: Integer;
  InnA, CenterA, ColWA, C1A, EditLeft, EditW: Integer;
begin
  // --- basicGroupBox inner: generalGroupBox (left) + graphicsGroupBox (right) ---
  // basicGroupBox: Left=2, Border=4 → Client ≈ AContentW - 8
  InnB    := AContentW - 8;
  CenterB := InnB div 2;
  ColWB   := Max(MIN_COLW_B, CenterB - MARGIN_B - GAP_B div 2);
  C1B     := MARGIN_B;
  C2B     := InnB - MARGIN_B - ColWB;   // right-anchored mirror of C1B

  generalGroupBox.SetBounds(C1B, BOX_TOP, ColWB, BOX_H);
  graphicsGroupBox.SetBounds(C2B, BOX_TOP, ColWB, BOX_H);

  // --- advancedGroupBox inner: performanceGroupBox (left) + customenvEdit (right) ---
  // advancedGroupBox: Left=5, Border=4 → Client ≈ AContentW - 14
  InnA    := AContentW - 14;
  CenterA := InnA div 2;
  ColWA   := Max(MIN_COLW_A, CenterA - MARGIN_A - GAP_A div 2);
  C1A     := MARGIN_A;
  EditLeft := C1A + ColWA + GAP_A;
  EditW    := Max(MIN_EDIT_W, InnA - MARGIN_A - EditLeft);

  performanceGroupBox.SetBounds(C1A, BOX_TOP, ColWA, BOX_H);
  customenvEdit.Left  := EditLeft;
  customenvEdit.Width := EditW;
end;

// ============================================================================
// GAMES TAB — Steam installed games grid
// ============================================================================

procedure Tgoverlayform.InitGamesTab;
const
  BTN_CAPTIONS: array[0..3] of string = ('MangoHud', 'vkBasalt', 'OptiScaler', 'Tweaks');
var
  k: Integer;
  OpenFolderItem: TMenuItem;
begin
  FCardPanels := TList.Create;
  FOrigCovers := TList.Create;

  // Right-click context menu for game cards
  FGameCardMenu := TPopupMenu.Create(Self);
  OpenFolderItem := TMenuItem.Create(FGameCardMenu);
  OpenFolderItem.Caption := 'Open install folder';
  OpenFolderItem.OnClick := @GameCardOpenFolderClick;
  FGameCardMenu.Items.Add(OpenFolderItem);

  FGamesScrollBox := TScrollBox.Create(Self);
  FGamesScrollBox.Parent := gamesTabSheet;
  FGamesScrollBox.Align := alClient;
  FGamesScrollBox.AutoScroll := True;
  FGamesScrollBox.BorderStyle := bsNone;
  FGamesScrollBox.HorzScrollBar.Visible := False;
  FGamesScrollBox.Color := $1A1A1A;
  FGamesScrollBox.OnResize := @GamesScrollBoxResize;

  FGamesPanel := TPanel.Create(Self);
  FGamesPanel.Parent := FGamesScrollBox;
  FGamesPanel.Caption := '';
  FGamesPanel.BevelOuter := bvNone;
  FGamesPanel.Color := $1A1A1A;
  FGamesPanel.Left := 0;
  FGamesPanel.Top := 0;
  FGamesPanel.Width := 800;
  FGamesPanel.Height := 100;
  FGamesPanel.OnClick := @GamesEmptySpaceClick;
  FGamesScrollBox.OnClick := @GamesEmptySpaceClick;

  // 4 shared action buttons — children of FGamesPanel, repositioned on card select
  for k := 0 to 3 do
  begin
    FActionBtns[k] := TPanel.Create(Self);
    FActionBtns[k].Parent     := FGamesPanel;
    FActionBtns[k].BevelOuter := bvNone;
    FActionBtns[k].Caption    := BTN_CAPTIONS[k];
    FActionBtns[k].Color      := $2D2D2D;
    FActionBtns[k].Font.Color := $AAAAAA;
    FActionBtns[k].Font.Size  := 8;
    FActionBtns[k].Cursor     := crHandPoint;
    FActionBtns[k].Tag        := k;
    FActionBtns[k].Visible    := False;
    FActionBtns[k].SetBounds(0, 0, 134, 32);
    FActionBtns[k].OnMouseEnter := @GameActionBtnMouseEnter;
    FActionBtns[k].OnMouseLeave := @GameActionBtnMouseLeave;
    FActionBtns[k].OnClick      := @GameActionBtnClick;
  end;

  // Game context label — shown in the bottom bar when editing a game-specific config
  FGameContextLabel := TLabel.Create(Self);
  FGameContextLabel.Parent     := goverlaybarPanel;
  FGameContextLabel.Align      := alLeft;
  FGameContextLabel.AutoSize   := True;
  FGameContextLabel.Layout     := tlCenter;
  FGameContextLabel.Caption    := '';
  FGameContextLabel.Font.Color := $88AAFF;
  FGameContextLabel.Font.Size  := 8;
  FGameContextLabel.Font.Style := [fsBold];
  FGameContextLabel.Visible    := False;

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

procedure Tgoverlayform.LoadSteamGames;
const
  CARD_W      = 150;
  CARD_H      = 235;
  CARD_IMG_H  = 210;
  CARD_MARGIN = 8;
var
  Libraries: TStringList;
  PendingIDs: TStringList;
  PendingImages: TList;
  CacheDir: string;
  i, j, CardX, CardY, CardsPerRow, TotalRows: Integer;
  LibPath, AcfContent, AppID, GameName, ImagePath, HomeDir, InstallDir, IconPath: string;
  SR: TSearchRec;
  AcfFile: TStringList;
  CardPanel: TPanel;
  CardImage: TImage;
  CardLabel: TLabel;
  BadgeCircle: TShape;
  BadgeMangoImg: TImage;
  BadgeVkLabel: TLabel;
  BadgeX: Integer;
  NoGamesLabel: TLabel;
  LowerName, GameCfgDir: string;
  ScaledBmp: TBitmap;
  HasMango, HasVkBasalt, HasOptiScaler, HasTweaks: Boolean;
  BadgeOptiScalerLabel: TLabel;
  BadgeTweaksLabel: TLabel;
  TweakLines: TStringList;
  k: Integer;
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

    CardsPerRow := Max(1, (FGamesScrollBox.ClientWidth - CARD_MARGIN) div (CARD_W + CARD_MARGIN));
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

          // Card position
          CardX := CARD_MARGIN + (j mod CardsPerRow) * (CARD_W + CARD_MARGIN);
          CardY := CARD_MARGIN + (j div CardsPerRow) * (CARD_H + CARD_MARGIN);

          CardPanel := TPanel.Create(Self);
          CardPanel.Parent := FGamesPanel;
          CardPanel.SetBounds(CardX, CardY, CARD_W, CARD_H);
          CardPanel.BevelOuter := bvNone;
          CardPanel.Caption := '';
          CardPanel.Tag := 9999;  // marker: game card — excluded from theme color override
          CardPanel.Color := IfThen(CurrentTheme = tmLight, $00F0F0F0, $2A2A2A);
          CardPanel.Hint := GameName + LineEnding + LibPath + '/common/' + InstallDir;
          CardPanel.ShowHint := True;
          CardPanel.OnMouseEnter := @GameCardMouseEnter;
          CardPanel.OnMouseLeave := @GameCardMouseLeave;
          CardPanel.OnClick := @GameCardClick;
          CardPanel.OnMouseUp := @GameCardMouseUp;

          CardImage := TImage.Create(CardPanel);
          CardImage.Parent := CardPanel;
          CardImage.SetBounds(0, 0, CARD_W, CARD_IMG_H);
          CardImage.Stretch := True;
          CardImage.Proportional := False;
          CardImage.Center := False;
          CardImage.Hint := GameName + LineEnding + LibPath + '/common/' + InstallDir;
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

          CardLabel := TLabel.Create(CardPanel);
          CardLabel.Parent := CardPanel;
          CardLabel.SetBounds(2, CARD_IMG_H + 4, CARD_W - 4, CARD_H - CARD_IMG_H - 6);
          CardLabel.Caption := GameName;
          CardLabel.Font.Color := IfThen(CurrentTheme = tmLight, clBlack, clWhite);
          CardLabel.Font.Size := 7;
          CardLabel.Alignment := taCenter;
          CardLabel.WordWrap := False;
          CardLabel.ParentColor := True;
          CardLabel.Hint := GameName + LineEnding + LibPath + '/common/' + InstallDir;
          CardLabel.ShowHint := True;
          CardLabel.OnMouseEnter := @GameCardMouseEnter;
          CardLabel.OnMouseLeave := @GameCardMouseLeave;
          CardLabel.OnClick := @GameCardClick;
          CardLabel.OnMouseUp := @GameCardMouseUp;

          // Config badges: coloured icons top-left if per-game configs exist
          GameCfgDir := GetGameConfigDir(GameName);
          HasMango      := FileExists(GameCfgDir + 'MangoHud.conf');
          HasVkBasalt   := FileExists(GameCfgDir + 'vkBasalt.conf');
          HasOptiScaler := FileExists(GameCfgDir + 'OptiScaler.ini');
          BadgeX := 4;
          // Check for Tweaks content in fgmod
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

          if HasMango then
          begin
            // Dark circle background
            BadgeCircle := TShape.Create(CardPanel);
            BadgeCircle.Parent      := CardPanel;
            BadgeCircle.Shape       := stEllipse;
            BadgeCircle.Brush.Color := $00780DC8;
            BadgeCircle.Pen.Style   := psClear;
            BadgeCircle.SetBounds(BadgeX, 4, 24, 24);
            BadgeCircle.OnMouseEnter := @GameCardMouseEnter;
            BadgeCircle.OnMouseLeave := @GameCardMouseLeave;
            BadgeCircle.OnClick      := @GameCardClick;
            BadgeCircle.OnMouseUp    := @GameCardMouseUp;
            // MangoHud icon on top
            BadgeMangoImg := TImage.Create(CardPanel);
            BadgeMangoImg.Parent   := CardPanel;
            BadgeMangoImg.AutoSize := False;
            BadgeMangoImg.SetBounds(BadgeX + 3, 7, 18, 18);
            BadgeMangoImg.Stretch  := True;
            BadgeMangoImg.Center   := True;
            BadgeMangoImg.Transparent := True;
            IconPath := ExtractFilePath(Application.ExeName) + 'assets/icons/mango-active.png';
            if FileExists(IconPath) then
              BadgeMangoImg.Picture.LoadFromFile(IconPath);
            BadgeMangoImg.BringToFront;
            BadgeMangoImg.OnMouseEnter := @GameCardMouseEnter;
            BadgeMangoImg.OnMouseLeave := @GameCardMouseLeave;
            BadgeMangoImg.OnClick      := @GameCardClick;
            BadgeMangoImg.OnMouseUp    := @GameCardMouseUp;
            BadgeX := BadgeX + 28;
          end;

          if HasVkBasalt then
          begin
            // Dark circle background
            BadgeCircle := TShape.Create(CardPanel);
            BadgeCircle.Parent      := CardPanel;
            BadgeCircle.Shape       := stEllipse;
            BadgeCircle.Brush.Color := $00780DC8;
            BadgeCircle.Pen.Style   := psClear;
            BadgeCircle.SetBounds(BadgeX, 4, 24, 24);
            BadgeCircle.OnMouseEnter := @GameCardMouseEnter;
            BadgeCircle.OnMouseLeave := @GameCardMouseLeave;
            BadgeCircle.OnClick      := @GameCardClick;
            BadgeCircle.OnMouseUp    := @GameCardMouseUp;
            // vkBasalt label on top
            BadgeVkLabel := TLabel.Create(CardPanel);
            BadgeVkLabel.Parent     := CardPanel;
            BadgeVkLabel.AutoSize   := False;
            BadgeVkLabel.SetBounds(BadgeX, 4, 24, 24);
            BadgeVkLabel.Caption    := '󰏘';
            BadgeVkLabel.Font.Name  := 'Noto Sans';
            BadgeVkLabel.Font.Size  := 12;
            BadgeVkLabel.Font.Color := clWhite;
            BadgeVkLabel.Alignment  := taCenter;
            BadgeVkLabel.Layout     := tlCenter;
            BadgeVkLabel.BringToFront;
            BadgeVkLabel.OnMouseEnter := @GameCardMouseEnter;
            BadgeVkLabel.OnMouseLeave := @GameCardMouseLeave;
            BadgeVkLabel.OnClick      := @GameCardClick;
            BadgeVkLabel.OnMouseUp    := @GameCardMouseUp;
            BadgeX := BadgeX + 28;
          end;

          if HasOptiScaler then
          begin
            // Dark circle background
            BadgeCircle := TShape.Create(CardPanel);
            BadgeCircle.Parent      := CardPanel;
            BadgeCircle.Shape       := stEllipse;
            BadgeCircle.Brush.Color := $00780DC8;
            BadgeCircle.Pen.Style   := psClear;
            BadgeCircle.SetBounds(BadgeX, 4, 24, 24);
            BadgeCircle.OnMouseEnter := @GameCardMouseEnter;
            BadgeCircle.OnMouseLeave := @GameCardMouseLeave;
            BadgeCircle.OnClick      := @GameCardClick;
            BadgeCircle.OnMouseUp    := @GameCardMouseUp;
            // OptiScaler icon label on top
            BadgeOptiScalerLabel := TLabel.Create(CardPanel);
            BadgeOptiScalerLabel.Parent     := CardPanel;
            BadgeOptiScalerLabel.AutoSize   := False;
            BadgeOptiScalerLabel.SetBounds(BadgeX, 4, 24, 24);
            BadgeOptiScalerLabel.Caption    := '󰋮';
            BadgeOptiScalerLabel.Font.Name  := 'Noto Sans';
            BadgeOptiScalerLabel.Font.Size  := 12;
            BadgeOptiScalerLabel.Font.Color := clWhite;
            BadgeOptiScalerLabel.Alignment  := taCenter;
            BadgeOptiScalerLabel.Layout     := tlCenter;
            BadgeOptiScalerLabel.BringToFront;
            BadgeOptiScalerLabel.OnMouseEnter := @GameCardMouseEnter;
            BadgeOptiScalerLabel.OnMouseLeave := @GameCardMouseLeave;
            BadgeOptiScalerLabel.OnClick      := @GameCardClick;
            BadgeOptiScalerLabel.OnMouseUp    := @GameCardMouseUp;
            BadgeX := BadgeX + 28;
          end;

          if HasTweaks then
          begin
            // Dark circle background
            BadgeCircle := TShape.Create(CardPanel);
            BadgeCircle.Parent      := CardPanel;
            BadgeCircle.Shape       := stEllipse;
            BadgeCircle.Brush.Color := $00780DC8;
            BadgeCircle.Pen.Style   := psClear;
            BadgeCircle.SetBounds(BadgeX, 4, 24, 24);
            BadgeCircle.OnMouseEnter := @GameCardMouseEnter;
            BadgeCircle.OnMouseLeave := @GameCardMouseLeave;
            BadgeCircle.OnClick      := @GameCardClick;
            BadgeCircle.OnMouseUp    := @GameCardMouseUp;
            // Tweaks (gear) icon label on top
            BadgeTweaksLabel := TLabel.Create(CardPanel);
            BadgeTweaksLabel.Parent     := CardPanel;
            BadgeTweaksLabel.AutoSize   := False;
            BadgeTweaksLabel.SetBounds(BadgeX, 4, 24, 24);
            BadgeTweaksLabel.Caption    := '󰒓';
            BadgeTweaksLabel.Font.Name  := 'Noto Sans';
            BadgeTweaksLabel.Font.Size  := 12;
            BadgeTweaksLabel.Font.Color := clWhite;
            BadgeTweaksLabel.Alignment  := taCenter;
            BadgeTweaksLabel.Layout     := tlCenter;
            BadgeTweaksLabel.BringToFront;
            BadgeTweaksLabel.OnMouseEnter := @GameCardMouseEnter;
            BadgeTweaksLabel.OnMouseLeave := @GameCardMouseLeave;
            BadgeTweaksLabel.OnClick      := @GameCardClick;
            BadgeTweaksLabel.OnMouseUp    := @GameCardMouseUp;
            BadgeX := BadgeX + 28;
          end;

          // Store card and original image for dim animation
          FCardPanels.Add(CardPanel);
          if (CardImage.Picture.Graphic <> nil) and
             (CardImage.Picture.Graphic.Width > 0) then
          begin
            ScaledBmp := TBitmap.Create;
            try
              ScaledBmp.SetSize(CARD_W, CARD_IMG_H);
              ScaledBmp.Canvas.StretchDraw(
                Rect(0, 0, CARD_W, CARD_IMG_H), CardImage.Picture.Graphic);
              FOrigCovers.Add(ScaledBmp.CreateIntfImage);
            finally
              ScaledBmp.Free;
            end;
          end
          else
            FOrigCovers.Add(nil);  // pending download — skip pixel dim

          Inc(j);
        until FindNext(SR) <> 0;
        FindClose(SR);
      end;
    end;

    // Resize inner panel to fit all cards
    if j > 0 then
    begin
      TotalRows := (j + CardsPerRow - 1) div CardsPerRow;
      FGamesPanel.Width := Max(FGamesScrollBox.ClientWidth,
        CardsPerRow * (CARD_W + CARD_MARGIN) + CARD_MARGIN);
      FGamesPanel.Height := CARD_MARGIN + TotalRows * (CARD_H + CARD_MARGIN);
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
        PendingIDs, PendingImages, CacheDir);
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
    TPanel(Sender).Color := $00303860;
end;

procedure Tgoverlayform.HomeGlobalBtnLeave(Sender: TObject);
begin
  if Sender is TPanel then
    TPanel(Sender).Color := $00252540;
end;

procedure Tgoverlayform.HomeGameBtnEnter(Sender: TObject);
begin
  if Sender is TPanel then
    TPanel(Sender).Color := $00306030;
end;

procedure Tgoverlayform.HomeGameBtnLeave(Sender: TObject);
begin
  if Sender is TPanel then
    TPanel(Sender).Color := $00253025;
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
  DEP_KEYS: array[0..8] of string = (
    'pascube', 'mangohud', 'MangoHud runtime 25.08',
    'vkbasalt', 'vkBasalt runtime 25.08',
    'vkcube', 'p7zip', 'curl', 'git');
  DEP_DISPLAY: array[0..8] of string = (
    'PasCube', 'MangoHud', 'MangoHud runtime 25.08',
    'vkBasalt', 'vkBasalt runtime 25.08',
    'vkcube', '7z (p7zip)', 'curl', 'git');
  CLR_OK      = $0044BB44;
  CLR_MISSING = $00BB4444;
var
  Missing: TStringList;
  i: Integer;
begin
  if not Assigned(FHomeDepDots[0]) then Exit;
  CheckDependencies(Missing);
  try
    // First 9 fixed deps shown as dots
    for i := 0 to 8 do
    begin
      if Missing.IndexOf(DEP_KEYS[i]) >= 0 then
      begin
        FHomeDepDots[i].Brush.Color := CLR_MISSING;
        FHomeDepDots[i].Pen.Color   := CLR_MISSING;
        FHomeDepLbls[i].Font.Color  := $00AA6666;
      end
      else
      begin
        FHomeDepDots[i].Brush.Color := CLR_OK;
        FHomeDepDots[i].Pen.Color   := CLR_OK;
        FHomeDepLbls[i].Font.Color  := $0088CC88;
      end;
    end;
  finally
    Missing.Free;
  end;
end;

procedure Tgoverlayform.InitHomeTab;
const
  BG       = $001A1A1A;
  CARD_BG  = $00252525;
  CARD_M   = 16;
  CARD_P   = 14;
  ROW_H    = 32;
  DOT_SZ   = 14;
  SEC_GAP  = 12;
  COL_W    = 200;  // fixed column width for dep grid

  DEP_NAMES: array[0..8] of string = (
    'PasCube', 'MangoHud', 'MangoHud rt.', 'vkBasalt', 'vkBasalt rt.',
    'vkcube', '7z', 'curl', 'git');
  MOD_NAMES: array[0..2] of string = ('MangoHud', 'vkBasalt', 'OptiScaler');

const
  LIB_NAMES: array[0..4] of string = ('FakeNvAPI:', 'Optipatcher:', 'FSR:', 'XeSS:', 'DLSS:');
  LIB_COL2  = 3;  // first index in LIB_NAMES for right column

var
  Content:   TPanel;
  Card:      TPanel;
  BtnRow:    TPanel;  // used as spacer panel
  Lbl:       TLabel;
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

  function MkTitle(AParent: TWinControl; const AText: string; AY: Integer): TLabel;
  begin
    Result := TLabel.Create(Self);
    Result.Parent   := AParent;
    Result.Caption  := AText;
    Result.Font.Bold  := True;
    Result.Font.Color := clWhite;
    Result.Font.Size  := 10;
    Result.Left     := CARD_P;
    Result.Top      := AY;
    Result.AutoSize := True;
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

  // Creates a centered label inside a button panel using Align
  function MkBtnLabel(AParent: TWinControl; const ACaption: string;
    AFontSize: Integer; AColor: TColor; AFontName: string = ''): TLabel;
  begin
    Result := TLabel.Create(Self);
    Result.Parent    := AParent;
    Result.Caption   := ACaption;
    Result.Alignment := taCenter;
    Result.Layout    := tlCenter;
    Result.Align     := alTop;
    Result.Font.Size  := AFontSize;
    Result.Font.Color := AColor;
    if AFontName <> '' then Result.Font.Name := AFontName;
    Result.Cursor    := crHandPoint;
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

  // ── Card 1: Module Status + Libraries (indented sub-rows for OptiScaler libs)
  // Layout: 3 module rows, thin separator, 3 library rows (2-col: left=[0,2,4], right=[1,3])
  Y    := CARD_M;
  Card := MkCard(Y, CARD_P * 2 + 24 + 3 * ROW_H + 10 + 3 * ROW_H + 4);
  MkTitle(Card, 'Module Status', CARD_P);
  MkSep(Card, CARD_P + 22);

  // Module rows (MangoHud, vkBasalt, OptiScaler)
  for i := 0 to 2 do
  begin
    Row := CARD_P + 30 + i * ROW_H;
    Dot := MkDot(Card, CARD_P, Row + (ROW_H - DOT_SZ) div 2);
    FHomeModDots[i] := Dot;

    Lbl := TLabel.Create(Self);
    Lbl.Parent     := Card;
    Lbl.Caption    := MOD_NAMES[i];
    Lbl.Font.Color := clSilver;
    Lbl.Font.Size  := 9;
    Lbl.Left       := CARD_P + DOT_SZ + 8;
    Lbl.Top        := Row + (ROW_H - 16) div 2;
    Lbl.AutoSize   := True;

    Lbl := TLabel.Create(Self);
    Lbl.Parent     := Card;
    Lbl.Caption    := '—';
    Lbl.Font.Color := $00AAAAAA;
    Lbl.Font.Size  := 9;
    Lbl.Left       := CARD_P + DOT_SZ + 8 + 110;
    Lbl.Top        := Row + (ROW_H - 16) div 2;
    Lbl.AutoSize   := True;
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
    FHomeLibDots[i] := Dot;

    Lbl := TLabel.Create(Self);
    Lbl.Parent     := Card;
    Lbl.Caption    := LIB_NAMES[i];
    Lbl.Font.Color := $00888888;
    Lbl.Font.Size  := 8;
    Lbl.Left       := ColX + DOT_SZ + 8;
    Lbl.Top        := Row + (ROW_H - 16) div 2;
    Lbl.AutoSize   := True;

    Lbl := TLabel.Create(Self);
    Lbl.Parent     := Card;
    Lbl.Caption    := '—';
    Lbl.Font.Color := $00DDAA44;
    Lbl.Font.Size  := 8;
    Lbl.Left       := ColX + DOT_SZ + 8 + 110;
    Lbl.Top        := Row + (ROW_H - 16) div 2;
    Lbl.AutoSize   := True;
    FHomeOptiLbls[i] := Lbl;
  end;
  Inc(Y, Card.Height + SEC_GAP);

  // ── Card 2: Dependencies (3×3 grid, fixed column width) ──────────────────
  Card := MkCard(Y, CARD_P * 2 + 24 + 3 * ROW_H + 8);
  MkTitle(Card, 'Dependencies', CARD_P);
  MkSep(Card, CARD_P + 22);

  for i := 0 to 8 do
  begin
    Row  := CARD_P + 30 + (i div 3) * ROW_H;
    ColX := CARD_P + (i mod 3) * COL_W;

    Dot := MkDot(Card, ColX, Row + (ROW_H - DOT_SZ) div 2);
    FHomeDepDots[i] := Dot;

    Lbl := TLabel.Create(Self);
    Lbl.Parent     := Card;
    Lbl.Caption    := DEP_NAMES[i];
    Lbl.Font.Color := $00AAAAAA;
    Lbl.Font.Size  := 9;
    Lbl.Left       := ColX + DOT_SZ + 6;
    Lbl.Top        := Row + (ROW_H - 16) div 2;
    Lbl.Width      := COL_W - DOT_SZ - 10;  // clip to column width
    Lbl.AutoSize   := False;
    FHomeDepLbls[i] := Lbl;
  end;
  Inc(Y, Card.Height + SEC_GAP);


  // ── Action Buttons (pinned to bottom of content) ─────────────────────────
  FHomeBtnRow := TPanel.Create(Self);
  FHomeBtnRow.Parent     := Content;
  FHomeBtnRow.BevelOuter := bvNone;
  FHomeBtnRow.Color      := BG;
  FHomeBtnRow.Caption    := '';
  FHomeBtnRow.Align      := alBottom;
  FHomeBtnRow.Height     := 90;
  FHomeBtnRow.OnResize   := @HomeBtnRowResize;

  // Global Config — left half (OnResize keeps width = 50%)
  FHomeGlobalBtn := TPanel.Create(Self);
  FHomeGlobalBtn.Parent     := FHomeBtnRow;
  FHomeGlobalBtn.BevelOuter := bvNone;
  FHomeGlobalBtn.Color      := $00252540;
  FHomeGlobalBtn.Caption    := '';
  FHomeGlobalBtn.Cursor     := crHandPoint;
  FHomeGlobalBtn.Align      := alLeft;
  FHomeGlobalBtn.Width      := 300;   // updated immediately by HomeBtnRowResize
  FHomeGlobalBtn.OnClick      := @HomeGlobalBtnClick;
  FHomeGlobalBtn.OnMouseEnter := @HomeGlobalBtnEnter;
  FHomeGlobalBtn.OnMouseLeave := @HomeGlobalBtnLeave;

  // Spacer
  BtnRow := TPanel.Create(Self);
  BtnRow.Parent := FHomeBtnRow;
  BtnRow.BevelOuter := bvNone;
  BtnRow.Color := BG;
  BtnRow.Caption := '';
  BtnRow.Align := alLeft;
  BtnRow.Width := CARD_M;

  // Game Config — takes remaining space
  FHomeGameBtn := TPanel.Create(Self);
  FHomeGameBtn.Parent     := FHomeBtnRow;
  FHomeGameBtn.BevelOuter := bvNone;
  FHomeGameBtn.Color      := $00253025;
  FHomeGameBtn.Caption    := '';
  FHomeGameBtn.Cursor     := crHandPoint;
  FHomeGameBtn.Align      := alClient;
  FHomeGameBtn.OnClick      := @HomeGameBtnClick;
  FHomeGameBtn.OnMouseEnter := @HomeGameBtnEnter;
  FHomeGameBtn.OnMouseLeave := @HomeGameBtnLeave;

  // Icons + captions (taCenter + Align=alTop → centered in any width)
  Lbl := MkBtnLabel(FHomeGlobalBtn, '󰋊', 28, $00AAAADD, 'Noto Sans');
  Lbl.Height := 56;
  Lbl.OnClick := @HomeGlobalBtnClick;
  Lbl := MkBtnLabel(FHomeGlobalBtn, 'Global Config', 10, clSilver);
  Lbl.Font.Bold := True;
  Lbl.Height := 26;
  Lbl.OnClick := @HomeGlobalBtnClick;

  Lbl := MkBtnLabel(FHomeGameBtn, '󰊴', 28, $00AADDAA, 'Noto Sans');
  Lbl.Height := 56;
  Lbl.OnClick := @HomeGameBtnClick;
  Lbl := MkBtnLabel(FHomeGameBtn, 'Game Config', 10, clSilver);
  Lbl.Font.Bold := True;
  Lbl.Height := 26;
  Lbl.OnClick := @HomeGameBtnClick;
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
  commandEdit.Visible       := False;
  copyBitbtn.Visible        := False;
  geSpeedButton.Visible     := False;
  geLabel.Visible           := False;
  goverlaybarPanel.Visible  := False;

  // Ensure button row is correctly sized (needed on first show)
  HomeBtnRowResize(nil);

  // Refresh all home tab sections
  RefreshHomeOptiStatus;
  RefreshHomeModuleStatus;
  RefreshHomeDeps;
end;

procedure Tgoverlayform.ReflowGamesGrid;
const
  CARD_W      = 150;
  CARD_H      = 235;
  CARD_MARGIN = 8;
var
  CardCount, CardsPerRow, TotalRows, i, CardX, CardY: Integer;
  Ctrl: TControl;
begin
  if not Assigned(FGamesScrollBox) or not Assigned(FGamesPanel) then
    Exit;
  // Skip reflow while games tab is not visible — avoids N×SetBounds on every tab switch
  if not gamesTabSheet.TabVisible then
  begin
    DbgLog('  ReflowGamesGrid SKIPPED (tab not visible)');
    Exit;
  end;
  DbgLog('  ReflowGamesGrid BEGIN (tab visible)');

  CardsPerRow := Max(1, (FGamesScrollBox.ClientWidth - CARD_MARGIN) div (CARD_W + CARD_MARGIN));
  CardCount   := 0;

  for i := 0 to FGamesPanel.ControlCount - 1 do
  begin
    Ctrl := FGamesPanel.Controls[i];
    if not (Ctrl is TPanel) then
      Continue;
    // Skip the shared action buttons
    if (TPanel(Ctrl) = FActionBtns[0]) or (TPanel(Ctrl) = FActionBtns[1]) or
       (TPanel(Ctrl) = FActionBtns[2]) or (TPanel(Ctrl) = FActionBtns[3]) then
      Continue;
    CardX := CARD_MARGIN + (CardCount mod CardsPerRow) * (CARD_W + CARD_MARGIN);
    CardY := CARD_MARGIN + (CardCount div CardsPerRow) * (CARD_H + CARD_MARGIN);
    Ctrl.SetBounds(CardX, CardY, CARD_W, CARD_H);
    Inc(CardCount);
  end;

  if CardCount > 0 then
  begin
    TotalRows := (CardCount + CardsPerRow - 1) div CardsPerRow;
    FGamesPanel.Width  := Max(FGamesScrollBox.ClientWidth,
      CardsPerRow * (CARD_W + CARD_MARGIN) + CARD_MARGIN);
    FGamesPanel.Height := CARD_MARGIN + TotalRows * (CARD_H + CARD_MARGIN);
  end;

  // Keep action buttons in sync with selected card after reflow
  if FSelectedCard <> nil then
  begin
    FActionBtns[0].SetBounds(FSelectedCard.Left + 8, FSelectedCard.Top +  31, FSelectedCard.Width - 16, 32);
    FActionBtns[1].SetBounds(FSelectedCard.Left + 8, FSelectedCard.Top +  70, FSelectedCard.Width - 16, 32);
    FActionBtns[2].SetBounds(FSelectedCard.Left + 8, FSelectedCard.Top + 109, FSelectedCard.Width - 16, 32);
    FActionBtns[3].SetBounds(FSelectedCard.Left + 8, FSelectedCard.Top + 148, FSelectedCard.Width - 16, 32);
  end;
end;

procedure Tgoverlayform.GamesScrollBoxResize(Sender: TObject);
begin
  if FGamesLoaded then
    ReflowGamesGrid;
end;

procedure Tgoverlayform.GamesEmptySpaceClick(Sender: TObject);
begin
  // Clicking empty space in the games grid: deselect cards and return to global config
  HideGameActionPanel;
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
  if Sender is TPanel then
    Panel := TPanel(Sender)
  else if (Sender is TImage) then
    Panel := TPanel(TImage(Sender).Parent)
  else if (Sender is TLabel) then
    Panel := TPanel(TLabel(Sender).Parent)
  else
    Exit;

  if Panel <> FSelectedCard then
    Panel.Color := IfThen(CurrentTheme = tmLight, $00D8D8D8, $3A3A3A);
  if Sender is TControl then
    TControl(Sender).Cursor := crHandPoint;
end;

procedure Tgoverlayform.GameCardMouseLeave(Sender: TObject);
var
  Panel: TPanel;
begin
  if Sender is TPanel then
    Panel := TPanel(Sender)
  else if (Sender is TImage) then
    Panel := TPanel(TImage(Sender).Parent)
  else if (Sender is TLabel) then
    Panel := TPanel(TLabel(Sender).Parent)
  else
    Exit;

  // Restore original panel color (respects current dim state)
  if Panel <> FSelectedCard then
    Panel.Color := DimmedCardColor;
end;

procedure Tgoverlayform.GameCardClick(Sender: TObject);
var
  Panel: TPanel;
begin
  if Sender is TPanel then
    Panel := TPanel(Sender)
  else if Sender is TImage then
    Panel := TPanel(TImage(Sender).Parent)
  else if Sender is TLabel then
    Panel := TPanel(TLabel(Sender).Parent)
  else
    Exit;

  if Panel = FSelectedCard then
  begin
    HideGameActionPanel;
    Exit;
  end;

  ShowGameActionPanel(Panel);
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

procedure Tgoverlayform.ShowGameActionPanel(ACard: TPanel);
const
  BTN_OFFSETS: array[0..3] of Integer = (31, 70, 109, 148);
  // Config files to check for each button index (empty = not implemented yet)
  CFG_FILES: array[0..2] of string = (
    'MangoHud.conf',
    'vkBasalt.conf',
    'OptiScaler.ini'
  );
  COLOR_CONFIGURED = $0066DD66;  // green — game has a saved config
  COLOR_DEFAULT    = $00AAAAAA;  // gray  — no config yet
var
  k: Integer;
  i: Integer;
  Switching: Boolean;
  GameName, GameCfgDir: string;
  HintLines: TStringList;
  HasTweaks: Boolean;
  TweakLines: TStringList;
begin
  Switching := FSelectedCard <> nil;

  if Switching then
  begin
    // Switching between cards: hide buttons and deselect without triggering undim
    for k := 0 to 3 do
      FActionBtns[k].Visible := False;
    FSelectedCard.Color := DimmedCardColor;
    FSelectedCard := nil;
  end;

  FSelectedCard       := ACard;
  FSelectedCard.Color := clHighlight;

  // Restore the newly selected card's image to original brightness
  RestoreCardImageFromOriginal(ACard);

  // Dim all other cards to current level (snaps old selected card instantly)
  if Switching then
    ApplyDimToCards;

  // Extract game name to check for existing per-game configs
  GameName := '';
  HintLines := TStringList.Create;
  try
    HintLines.Text := ACard.Hint;
    if HintLines.Count > 0 then
      GameName := HintLines[0];
  finally
    HintLines.Free;
  end;
  GameCfgDir := GetGameConfigDir(GameName);

  // Check Tweaks: fgmod must contain at least one tweak-specific line
  HasTweaks := False;
  if FileExists(GameCfgDir + 'fgmod') then
  begin
    TweakLines := TStringList.Create;
    try
      TweakLines.LoadFromFile(GameCfgDir + 'fgmod');
      for i := 0 to TweakLines.Count - 1 do
        if (Pos('#gamemode', TweakLines[i]) > 0) or
           (Pos('export PROTON_', TweakLines[i]) > 0) or
           (Pos('export RADV_', TweakLines[i]) > 0) or
           (Pos('export MESA_', TweakLines[i]) > 0) or
           (Pos('#customenv', TweakLines[i]) > 0) or
           (Pos('export SteamDeck=1', TweakLines[i]) > 0) then
        begin
          HasTweaks := True;
          Break;
        end;
    finally
      TweakLines.Free;
    end;
  end;

  for k := 0 to 3 do
  begin
    FActionBtns[k].SetBounds(
      ACard.Left + 8,
      ACard.Top  + BTN_OFFSETS[k],
      ACard.Width - 16,
      32);

    // Color the button text green if a game-specific config already exists
    if k <= 2 then
    begin
      if FileExists(GameCfgDir + CFG_FILES[k]) then
        FActionBtns[k].Font.Color := COLOR_CONFIGURED
      else
        FActionBtns[k].Font.Color := COLOR_DEFAULT;
    end
    else  // Tweaks (k = 3)
    begin
      if HasTweaks then
        FActionBtns[k].Font.Color := COLOR_CONFIGURED
      else
        FActionBtns[k].Font.Color := COLOR_DEFAULT;
    end;

    FActionBtns[k].Visible := True;
    FActionBtns[k].BringToFront;
  end;

  StartDimAnimation(True);
end;

procedure Tgoverlayform.HideGameActionPanel;
var
  k: Integer;
begin
  if FSelectedCard = nil then
    Exit;

  for k := 0 to 3 do
    FActionBtns[k].Visible := False;

  FSelectedCard.Color := $2A2A2A;
  FSelectedCard := nil;

  StartDimAnimation(False);
end;

procedure Tgoverlayform.GameActionBtnMouseEnter(Sender: TObject);
begin
  if Sender is TPanel then
    TPanel(Sender).Color := $404040;
end;

procedure Tgoverlayform.GameActionBtnMouseLeave(Sender: TObject);
begin
  if Sender is TPanel then
    TPanel(Sender).Color := $2D2D2D;
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
var
  DataHome: string;
begin
  DataHome := GetEnvironmentVariable('XDG_DATA_HOME');
  if DataHome = '' then
    DataHome := GetUserDir + '.local/share';
  Result := IncludeTrailingPathDelimiter(DataHome) +
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
  if not Assigned(FGameContextLabel) then Exit;
  if FActiveGameName <> '' then
  begin
    FGameContextLabel.Caption := 'Jogo: ' + FActiveGameName;
    FGameContextLabel.Visible := True;
  end
  else
  begin
    FGameContextLabel.Caption := '';
    FGameContextLabel.Visible := False;
  end;
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

procedure Tgoverlayform.GameActionBtnClick(Sender: TObject);
var
  BtnIndex: Integer;
  GameName: string;
  Lines: TStringList;
  GameCfgDir: string;
begin
  if not (Sender is TPanel) then Exit;
  if FSelectedCard = nil then Exit;

  BtnIndex := TPanel(Sender).Tag;

  // Extract game name from card hint (format: "GameName\nInstallPath")
  Lines := TStringList.Create;
  try
    Lines.Text := FSelectedCard.Hint;
    if Lines.Count < 1 then Exit;
    GameName := Lines[0];
  finally
    Lines.Free;
  end;

  FActiveGameName := GameName;
  ShowGameThumb(FSelectedCard);
  LoadGameToggleStates;

  case BtnIndex of
    0: // MangoHud — navigate directly (do NOT call mangohudLabelClick to avoid
       // triggering the game-mode reset that sidebar navigation applies)
    begin
      GameCfgDir := GetGameConfigDir(GameName);
      if not DirectoryExists(GameCfgDir) then
        ForceDirectories(GameCfgDir);
      ExecuteShellCommand('cp -rn ' + QuotedStr(GetFGModOriginalPath) + '/. ' + QuotedStr(GameCfgDir) + ' 2>/dev/null');
      MANGOHUDCFGFILE := GameCfgDir + 'MangoHud.conf';
      UpdateGameContextLabel;
      SetNavActive(0);
      goverlayPageControl.ShowTabs := True;
      vkbasalttabsheet.TabVisible  := False;
      optiscalertabsheet.TabVisible := False;
      tweakstabsheet.TabVisible    := False;
      gamesTabSheet.TabVisible     := False;
      goverlayPageControl.ActivePage := presetTabsheet;
      notificationLabel.Visible := False;
      commandEdit.Visible       := False;
      copyBitbtn.Visible        := False;
      
      
      goverlaybarPanel.Visible  := True;
      UpdateGeSpeedButtonState;
      UpdateGlobalEnableMenuItemVisibility;
      LoadMangoHudConfig;
    end;
    1: // vkBasalt
    begin
      GameCfgDir := GetGameConfigDir(GameName);
      if not DirectoryExists(GameCfgDir) then
        ForceDirectories(GameCfgDir);
      ExecuteShellCommand('cp -rn ' + QuotedStr(GetFGModOriginalPath) + '/. ' + QuotedStr(GameCfgDir) + ' 2>/dev/null');
      VKBASALTCFGFILE := GameCfgDir + 'vkBasalt.conf';
      UpdateGameContextLabel;
      vkbasaltLabelClick(nil);
    end;
    2: // OptiScaler
    begin
      UpdateGameContextLabel;
      optiscalerLabelClick(nil);
    end;
    3: // Tweaks
    begin
      UpdateGameContextLabel;
      tweaksLabelClick(nil);
    end;
  end;

  HideGameActionPanel;
end;

// ============================================================================
// Card dim animation
// ============================================================================

function Tgoverlayform.DimmedCardColor: TColor;
const
  BRIGHT = $2A;
  DIM    = $12;
var
  V: Integer;
begin
  if CurrentTheme = tmLight then
    Result := $00F0F0F0
  else
  begin
    V := BRIGHT + (DIM - BRIGHT) * FDimProgress div 100;
    Result := V or (V shl 8) or (V shl 16);
  end;
end;

procedure Tgoverlayform.ApplyDimToCards;
var
  i, x, y: Integer;
  BrightFactor: Integer;
  Panel: TPanel;
  Img: TImage;
  OrigIntf, DimIntf: TLazIntfImage;
  DimBmp: TBitmap;
  SrcRow, DstRow: PByte;
  W, H, Stride, BPP, px: Integer;
begin
  if not Assigned(FCardPanels) then Exit;
  // Dim to 35% brightness at max — visible but not fully black
  BrightFactor := 35 + 65 * (100 - FDimProgress) div 100;

  for i := 0 to FCardPanels.Count - 1 do
  begin
    Panel := TPanel(FCardPanels[i]);
    if Panel = FSelectedCard then Continue;

    // Dim the label strip background
    Panel.Color := DimmedCardColor;

    // Pixel-blend the cover image
    if i >= FOrigCovers.Count then Continue;
    OrigIntf := TLazIntfImage(FOrigCovers[i]);
    if OrigIntf = nil then Continue;
    if (Panel.ControlCount = 0) or not (Panel.Controls[0] is TImage) then Continue;
    Img := TImage(Panel.Controls[0]);

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
            DstRow[px+3] := SrcRow[px+3];  // preserve alpha
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
end;

procedure Tgoverlayform.StartDimAnimation(ADimming: Boolean);
begin
  FDimDir := IfThen(ADimming, 1, -1);
  if not Assigned(FDimTimer) then
  begin
    FDimTimer          := TTimer.Create(Self);
    FDimTimer.Interval := 16;
    FDimTimer.OnTimer  := @DimTimerTick;
  end;
  FDimTimer.Enabled := True;
end;

procedure Tgoverlayform.RestoreCardImageFromOriginal(ACard: TPanel);
var
  CardIdx: Integer;
  OrigIntf: TLazIntfImage;
  Bmp: TBitmap;
  Img: TImage;
begin
  if not Assigned(FCardPanels) or not Assigned(FOrigCovers) then Exit;
  CardIdx := FCardPanels.IndexOf(ACard);
  if (CardIdx < 0) or (CardIdx >= FOrigCovers.Count) then Exit;
  OrigIntf := TLazIntfImage(FOrigCovers[CardIdx]);
  if OrigIntf = nil then Exit;
  if (ACard.ControlCount = 0) or not (ACard.Controls[0] is TImage) then Exit;
  Img := TImage(ACard.Controls[0]);
  Bmp := TBitmap.Create;
  try
    Bmp.LoadFromIntfImage(OrigIntf);
    Img.Picture.Bitmap.Assign(Bmp);
    Img.Invalidate;
  finally
    Bmp.Free;
  end;
end;

procedure Tgoverlayform.DimTimerTick(Sender: TObject);
const
  STEP = 7;
begin
  FDimProgress := FDimProgress + FDimDir * STEP;
  if FDimProgress <= 0 then
  begin
    FDimProgress := 0;
    FDimTimer.Enabled := False;
  end
  else if FDimProgress >= 100 then
  begin
    FDimProgress := 100;
    FDimTimer.Enabled := False;
  end;
  ApplyDimToCards;
end;

end.
