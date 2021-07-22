unit overlayunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  unix, StdCtrls, Spin, ComCtrls, Buttons, ColorBox, ActnList, Menus, aboutunit,
  ATStringProc_HtmlColor, crosshairUnit, hudbackgroundUnit, customeffectsunit;



type

  { Tgoverlayform }

  Tgoverlayform = class(TForm)
    aboutBitBtn: TBitBtn;
    addBitBtn: TBitBtn;
    archCheckBox: TCheckBox;
    archlabel: TLabel;
    audiobitrateCombobox: TComboBox;
    aacprofileCombobox: TComboBox;
    audiodevCombobox: TComboBox;
    audioinputCombobox: TComboBox;
    audioencoderCombobox: TComboBox;
    distroinfolabel: TLabel;
    distroinfolabel2: TLabel;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    runvkbasaltBitBtn: TBitBtn;
    vkbasaltPopupMenu: TPopupMenu;
    sessionlabel: TLabel;
    homepartitionlabel: TLabel;
    customcommandlabel: TLabel;
    bottomleftSpeedButton: TSpeedButton;
    bottomrightSpeedButton: TSpeedButton;
    cpuavrloadCheckBox: TCheckBox;
    cpuColorButton: TColorButton;
    cpufreqCheckBox: TCheckBox;
    cpuloadgraphBitBtn: TBitBtn;
    distroinfoCheckBox: TCheckBox;
    resolutionvaluelabel: TLabel;
    resolutionlabel: TLabel;
    batterylabel: TLabel;
    vkbasaltstatuslabel: TLabel;
    fpslimitvaluelabel: TLabel;
    gamemodestatuslabel: TLabel;
    vkbasaltstatusvaluelabel: TLabel;
    gamemodestatusvaluelabel: TLabel;
    batteryvaluelabel2: TLabel;
    batteryvaluelabel: TLabel;
    sessionCheckBox: TCheckBox;
    homepartCheckBox: TCheckBox;
    hudtitleEdit: TEdit;
    customcommandEdit: TEdit;
    cputempgraphBitBtn: TBitBtn;
    resolutionCheckBox: TCheckBox;
    gamemodestatusCheckBox: TCheckBox;
    fpslimitlabel: TLabel;
    vkbasaltstatusCheckBox: TCheckBox;
    batteryCheckBox: TCheckBox;
    fpslimtoggleComboBox: TComboBox;
    fpslimLabel3: TLabel;
    gpucfgraphBitBtn: TBitBtn;
    gpuloadgraphBitBtn: TBitBtn;
    gpumfgraphBitBtn: TBitBtn;
    gputempgraphBitBtn: TBitBtn;
    hudtitlelabel: TLabel;
    graph1: TLabel;
    graph10: TLabel;
    graph11: TLabel;
    graph2: TLabel;
    graph3: TLabel;
    graph4: TLabel;
    graph5: TLabel;
    graph9: TLabel;
    hidehudCheckBox: TCheckBox;
    showfpslimCheckBox: TCheckBox;
    swapusagelabel: TLabel;
    performanceGroupBox2: TGroupBox;
    ramgraphBitBtn: TBitBtn;
    swapusageCheckBox: TCheckBox;
    cpufreqlabel: TLabel;
    cpuGroupBox: TGroupBox;
    cpulabel: TLabel;
    cpuload1ColorButton: TColorButton;
    cpuload2ColorButton: TColorButton;
    cpuload3ColorButton: TColorButton;
    cpuloadcolorCheckBox: TCheckBox;
    cpuloadcoreCheckBox: TCheckBox;
    cpunameEdit: TEdit;
    cpupowerCheckBox: TCheckBox;
    cpupowerlabel: TLabel;
    cputempCheckBox: TCheckBox;
    cputemplabel: TLabel;
    cpuusagelabel: TLabel;
    destfolderpathLabel: TLabel;
    diskioCheckBox: TCheckBox;
    driverversionCheckBox: TCheckBox;
    driverversionlabel: TLabel;
    engineColorButton: TColorButton;
    engineversionCheckBox: TCheckBox;
    engineversionlabel: TLabel;
    fpsCheckBox: TCheckBox;
    framegraphRadioButton: TRadioButton;
    framehistogramRadioButton: TRadioButton;
    frametimegraphCheckBox: TCheckBox;
    frametimegraphColorButton: TColorButton;
    frametimegraphlabel: TLabel;
    frametimelabel: TLabel;
    frametimelabel2: TLabel;
    gpuavrloadCheckBox: TCheckBox;
    gpuclocklabel: TLabel;
    gpuColorButton: TColorButton;
    gpufreqCheckBox: TCheckBox;
    gpuGroupBox: TGroupBox;
    gpulabel: TLabel;
    gpuload1ColorButton: TColorButton;
    gpuload2ColorButton: TColorButton;
    gpuload3ColorButton: TColorButton;
    gpuloadcolorCheckBox: TCheckBox;
    gpumemfreqCheckBox: TCheckBox;
    gpumemfreqlabel: TLabel;
    gpumodelCheckBox: TCheckBox;
    gpunameEdit: TEdit;
    gpunamelabel: TLabel;
    gpupowerCheckBox: TCheckBox;
    gpupowerlabel: TLabel;
    gputempCheckBox: TCheckBox;
    gputemplabel: TLabel;
    gpuusagelabel: TLabel;
    graphhudBitBtn: TBitBtn;
    GroupBox3: TGroupBox;
    hudbackgroundShape: TShape;
    hudversionCheckBox: TCheckBox;
    hudversionlabel: TLabel;
    Image1: TImage;
    intelpowerfixBitBtn: TBitBtn;
    iordrwColorButton: TColorButton;
    iordrwlabel: TLabel;
    iordvaluelabel: TLabel;
    iorwvaluelabel: TLabel;
    mediaCheckBox: TCheckBox;
    mediaColorButton: TColorButton;
    mediaComboBox: TComboBox;
    otherGroupBox: TGroupBox;
    performanceGroupBox1: TGroupBox;
    previewLabel: TLabel;
    ramColorButton: TColorButton;
    ramlabel: TLabel;
    ramusageCheckBox: TCheckBox;
    ramusagelabel: TLabel;
    spotify1label: TLabel;
    spotify2label: TLabel;
    spotify3label: TLabel;
    steamMenuItem: TMenuItem;
    lutrisMenuItem: TMenuItem;
    heroicMenuItem: TMenuItem;
    gamePopupMenu: TPopupMenu;
    runsteamBitBtn: TBitBtn;
    Label26: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    timeCheckBox: TCheckBox;
    timelabel: TLabel;
    TittlelogLabel: TLabel;
    topcenterSpeedButton: TSpeedButton;
    topleftSpeedButton: TSpeedButton;
    toprightSpeedButton: TSpeedButton;
    videodevEdit: TEdit;
    audioGroupBox: TGroupBox;
    audiosampCombobox: TComboBox;
    autoresCheckBox: TCheckBox;
    autoscaleCheckBox: TCheckBox;
    autouploadCheckBox: TCheckBox;
    autovideoqualityCheckBox: TCheckBox;
    autovideobitrateCheckBox: TCheckBox;
    autoaudiobitrateCheckBox: TCheckBox;
    clipdurationCombobox: TComboBox;
    compacthudBitBtn: TBitBtn;
    audiodevEdit: TEdit;
    Label25: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    scalewidthSpinEdit: TSpinEdit;
    scaleheightSpinEdit: TSpinEdit;
    outputscaleGroupBox: TGroupBox;
    videoqualityLabel: TLabel;
    videobitrateLabel: TLabel;
    videogopLabel: TLabel;
    autologSpinEdit: TSpinEdit;
    fpslimLabel2: TLabel;
    framerateCombobox: TComboBox;
    hlepresetLabel: TLabel;
    Label22: TLabel;
    Label24: TLabel;
    videobitrateTrackBar: TTrackBar;
    videogopTrackBar: TTrackBar;
    videodeviceCombobox: TComboBox;
    videoencoderCombobox: TComboBox;
    videodeviceLabel: TLabel;
    videodeviceLabel1: TLabel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    hudonoffComboBox: TComboBox;
    casValueLabel: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    h264profileLabel: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label23: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label9: TLabel;
    loggingComboBox: TComboBox;
    logpathBitBtn: TBitBtn;
    replaykeyCombobox: TComboBox;
    replaytoggleLabel: TLabel;
    videoqualityTrackBar: TTrackBar;
    saveclipEdit: TEdit;
    videoinputCombobox: TComboBox;
    videoinputLabel: TLabel;
    vramColorButton: TColorButton;
    vramgraphBitBtn: TBitBtn;
    vramlabel: TLabel;
    vramusageCheckBox: TCheckBox;
    GlobalenableLabel1: TLabel;
    replaystateLabel: TLabel;
    replaystateSpeedButton: TSpeedButton;
    heightImage: TImage;
    replaystopBitBtn: TBitBtn;
    vramusagelabel: TLabel;
    vulkanfpslabel: TLabel;
    vulkanftimelabel: TLabel;
    vulkanlabel: TLabel;
    widthImage: TImage;
    replaygeSpeedButton: TSpeedButton;
    replayGlobalenableLabel: TLabel;
    replaystartBitBtn: TBitBtn;
    replaysaveBitBtn: TBitBtn;
    videoGroupBox: TGroupBox;
    videocustomGroupBox: TGroupBox;
    Label12: TLabel;
    Label13: TLabel;
    replayImage: TImage;
    replayPanel: TPanel;
    replayLabel: TLabel;
    replayShape: TShape;
    reswidthSpinEdit: TSpinEdit;
    resheightSpinEdit: TSpinEdit;
    customresShape: TShape;
    fullscreenShape: TShape;
    wineCheckBox: TCheckBox;
    wineColorButton: TColorButton;
    reshadeProgressBar: TProgressBar;
    subBitBtn: TBitBtn;
    aveffectsListBox: TListBox;
    acteffectsListBox: TListBox;
    reshadeLabel1: TLabel;
    reshadeLabel2: TLabel;
    reshadesyncBitBtn: TBitBtn;
    casCheckBox: TCheckBox;
    effectsGroupBox: TGroupBox;
    vkbtogglekeyCombobox: TComboBox;
    ImageList3: TImageList;
    vktoggleLabel: TLabel;
    ImageList2: TImageList;
    dependencieSpeedButton: TSpeedButton;
    transparencyLabel: TLabel;
    cas01Image: TImage;
    cas02Image: TImage;
    cas03Image: TImage;
    cas04Image: TImage;
    cas05Image: TImage;
    cas06Image: TImage;
    cas07Image: TImage;
    cas08Image: TImage;
    cas09Image: TImage;
    cas10Image: TImage;
    backgroundLabel: TLabel;
    casorigLabel: TLabel;
    caspostLabel: TLabel;
    casTrackBar: TTrackBar;
    casTrackBar2: TTrackBar;
    completehudBitBtn: TBitBtn;
    FontcolorButton: TColorButton;
    FontcolorLabel: TLabel;
    fontsizeComboBox: TComboBox;
    fontsizeLabel: TLabel;
    fontsizeLabel1: TLabel;
    fontsizeSpinEdit: TSpinEdit;
    fpscustomSpinEdit: TSpinEdit;
    fpslimComboBox: TComboBox;
    fpslimLabel: TLabel;
    fpslimLabel1: TLabel;
    geSpeedButton: TSpeedButton;
    basaltgeSpeedButton: TSpeedButton;
    GlobalenableLabel: TLabel;
    basaltGlobalenableLabel: TLabel;
    glvsyncComboBox: TComboBox;
    glvsyncLabel: TLabel;
    casGroupBox: TGroupBox;
    hudbackgroundColorButton: TColorButton;
    hudtranspBitBtn: TBitBtn;
    cas00Image: TImage;
    originalImage: TImage;
    ImageList1: TImageList;
    mangohudLabel: TLabel;
    basaltrunBitBtn: TBitBtn;
    basaltsaveBitBtn: TBitBtn;
    dependenciesLabel: TLabel;
    vkbasaltPanel: TPanel;
    vkbasaltLabel: TLabel;
    mangohudPanel: TPanel;
    goverlayimage: TImage;
    performanceGroupBox: TGroupBox;
    runBitBtn: TBitBtn;
    saveBitBtn: TBitBtn;
    mangohudShape: TShape;
    vkbasaltShape: TShape;
    visualGroupBox: TGroupBox;
    vsyncComboBox: TComboBox;
    vsyncLabel: TLabel;
    h264profileCombobox: TComboBox;
    videohlepresetCombobox: TComboBox;
    winelabel: TLabel;
    procedure addBitBtnClick(Sender: TObject);
    procedure archCheckBoxClick(Sender: TObject);
    procedure audiobitrateComboboxKeyPress(Sender: TObject; var Key: char);
    procedure aacprofileComboboxKeyPress(Sender: TObject; var Key: char);
    procedure audiodevComboboxKeyPress(Sender: TObject; var Key: char);
    procedure audiosampComboboxKeyPress(Sender: TObject; var Key: char);
    procedure autoaudiobitrateCheckBoxChange(Sender: TObject);
    procedure autoresCheckBoxChange(Sender: TObject);
    procedure autoscaleCheckBoxChange(Sender: TObject);
    procedure autovideobitrateCheckBoxChange(Sender: TObject);
    procedure autovideoqualityCheckBoxChange(Sender: TObject);
    procedure basaltgeSpeedButtonClick(Sender: TObject);
    procedure basaltrunBitBtnClick(Sender: TObject);
    procedure basaltsaveBitBtnClick(Sender: TObject);
    procedure batteryCheckBoxClick(Sender: TObject);
    procedure bottomleftSpeedButtonClick(Sender: TObject);
    procedure bottomrightSpeedButtonClick(Sender: TObject);
    procedure casCheckBoxChange(Sender: TObject);
    procedure casTrackBarChange(Sender: TObject);
    procedure compacthudBitBtnClick(Sender: TObject);
    procedure completehudBitBtnClick(Sender: TObject);
    procedure clipdurationComboboxKeyPress(Sender: TObject; var Key: char);
    procedure cpufreqCheckBoxClick(Sender: TObject);
    procedure cpuloadcolorCheckBoxChange(Sender: TObject);
    procedure cpuloadcolorCheckBoxClick(Sender: TObject);
    procedure cpuloadgraphBitBtnClick(Sender: TObject);
    procedure cpunameEditChange(Sender: TObject);
    procedure cpupowerCheckBoxClick(Sender: TObject);
    procedure cputempgraphBitBtnClick(Sender: TObject);
    procedure crosshairsizeBitBtnClick(Sender: TObject);
    procedure customcommandEditChange(Sender: TObject);
    procedure distroinfoCheckBoxClick(Sender: TObject);
    procedure driverversionCheckBoxChange(Sender: TObject);
    procedure engineColorButtonColorChanged(Sender: TObject);
    procedure engineversionCheckBoxClick(Sender: TObject);
    procedure FontcolorButtonColorChanged(Sender: TObject);
    procedure fpsCheckBoxClick(Sender: TObject);
    procedure framegraphRadioButtonChange(Sender: TObject);
    procedure framegraphRadioButtonClick(Sender: TObject);
    procedure framehistogramRadioButtonClick(Sender: TObject);
    procedure framerateComboboxKeyPress(Sender: TObject; var Key: char);
    procedure gamemodestatusCheckBoxClick(Sender: TObject);
    procedure geSpeedButtonClick(Sender: TObject);
    procedure gpucfgraphBitBtnClick(Sender: TObject);
    procedure gpuloadcolorCheckBoxChange(Sender: TObject);
    procedure gpuloadcolorCheckBoxClick(Sender: TObject);
    procedure gpuloadgraphBitBtnClick(Sender: TObject);
    procedure gpumemfreqCheckBoxClick(Sender: TObject);
    procedure gpumfgraphBitBtnClick(Sender: TObject);
    procedure gpumodelCheckBoxClick(Sender: TObject);
    procedure gpunameEditChange(Sender: TObject);
    procedure gpupowerCheckBoxClick(Sender: TObject);
    procedure gputempgraphBitBtnClick(Sender: TObject);
    procedure graphhudBitBtnClick(Sender: TObject);
    procedure heroicMenuItemClick(Sender: TObject);
    procedure homepartCheckBoxClick(Sender: TObject);
    procedure hudbackgroundColorButtonColorChanged(Sender: TObject);
    procedure cpuColorButtonColorChanged(Sender: TObject);
    procedure cpuavrloadCheckBoxClick(Sender: TObject);
    procedure cputempCheckBoxClick(Sender: TObject);
    procedure diskioCheckBoxClick(Sender: TObject);
    procedure frametimegraphColorButtonColorChanged(Sender: TObject);
    procedure hudtitleEditChange(Sender: TObject);
    procedure hudtranspBitBtnClick(Sender: TObject);
    procedure intelpowerfixBitBtnClick(Sender: TObject);
    procedure iordrwColorButtonColorChanged(Sender: TObject);
    procedure fontsizeComboBoxChange(Sender: TObject);
    procedure fontsizeComboBoxKeyPress(Sender: TObject; var Key: char);
    procedure fpslimComboBoxChange(Sender: TObject);
    procedure fpslimComboBoxKeyPress(Sender: TObject; var Key: char);
    procedure frametimegraphCheckBoxClick(Sender: TObject);
    procedure glvsyncComboBoxKeyPress(Sender: TObject; var Key: char);
    procedure gpuavrloadCheckBoxClick(Sender: TObject);
    procedure gpuColorButtonColorChanged(Sender: TObject);
    procedure gpufreqCheckBoxClick(Sender: TObject);
    procedure gputempCheckBoxClick(Sender: TObject);
    procedure hudonoffComboBoxKeyPress(Sender: TObject; var Key: char);
    procedure loggingComboBoxKeyPress(Sender: TObject; var Key: char);
    procedure logpathBitBtnClick(Sender: TObject);
    procedure lutrisMenuItemClick(Sender: TObject);
    procedure mangohudLabelClick(Sender: TObject);
    procedure mangohudLabelMouseEnter(Sender: TObject);
    procedure mangohudLabelMouseLeave(Sender: TObject);
    procedure mangohudPanelClick(Sender: TObject);
    procedure mediaColorButtonColorChanged(Sender: TObject);
    procedure mediaComboBoxKeyPress(Sender: TObject; var Key: char);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure ramColorButtonColorChanged(Sender: TObject);
    procedure ramgraphBitBtnClick(Sender: TObject);
    procedure ramusageCheckBoxClick(Sender: TObject);
    procedure replaygeSpeedButtonClick(Sender: TObject);
    procedure replaykeyComboboxKeyPress(Sender: TObject; var Key: char);
    procedure replayLabelClick(Sender: TObject);
    procedure replayLabelMouseEnter(Sender: TObject);
    procedure replayLabelMouseLeave(Sender: TObject);
    procedure replaysaveBitBtnClick(Sender: TObject);
    procedure replaystartBitBtnClick(Sender: TObject);
    procedure replaystopBitBtnClick(Sender: TObject);
    procedure resolutionCheckBoxClick(Sender: TObject);
    procedure runsteamBitBtnClick(Sender: TObject);
    procedure runvkbasaltBitBtnClick(Sender: TObject);
    procedure saveBitBtn1Click(Sender: TObject);
    procedure sessionCheckBoxClick(Sender: TObject);
    procedure showfpslimCheckBoxClick(Sender: TObject);
    procedure steamMenuItemClick(Sender: TObject);
    procedure swapusageCheckBoxClick(Sender: TObject);
    procedure videobitrateTrackBarChange(Sender: TObject);
    procedure videogopTrackBarChange(Sender: TObject);
    procedure videoqualityTrackBarChange(Sender: TObject);
    procedure reshadesyncBitBtnClick(Sender: TObject);
    procedure resheightSpinEditMouseEnter(Sender: TObject);
    procedure resheightSpinEditMouseLeave(Sender: TObject);
    procedure reswidthSpinEditMouseEnter(Sender: TObject);
    procedure reswidthSpinEditMouseLeave(Sender: TObject);
    procedure saveBitBtnClick(Sender: TObject);
    procedure runBitBtnClick(Sender: TObject);
    procedure aboutBitBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mediaCheckBoxClick(Sender: TObject);
    procedure subBitBtnClick(Sender: TObject);
    procedure timeCheckBoxClick(Sender: TObject);
    procedure topcenterSpeedButtonClick(Sender: TObject);
    procedure topleftSpeedButtonClick(Sender: TObject);
    procedure hudversionCheckBoxClick(Sender: TObject);
    procedure toprightSpeedButtonClick(Sender: TObject);
    procedure vkbasaltLabelClick(Sender: TObject);
    procedure vkbasaltLabelMouseEnter(Sender: TObject);
    procedure vkbasaltLabelMouseLeave(Sender: TObject);
    procedure vkbasaltstatusCheckBoxClick(Sender: TObject);
    procedure vramColorButtonColorChanged(Sender: TObject);
    procedure vramgraphBitBtnClick(Sender: TObject);
    procedure vramusageCheckBoxClick(Sender: TObject);
    procedure vsyncComboBoxKeyPress(Sender: TObject; var Key: char);
    procedure widthImageMouseEnter(Sender: TObject);
    procedure wineCheckBoxChange(Sender: TObject);
    procedure wineColorButtonColorChanged(Sender: TObject);
    procedure h264profileComboboxKeyPress(Sender: TObject; var Key: char);

  private

  public

  end;

var
  goverlayform: Tgoverlayform;
  s: string;
  Color: string;
  fpsCustomValue:TextFile;
  fpsCustomScript:TextFile;
  fontsizeCustomValue:TextFile;
  fontsizeCustomScript:TextFile;
  crosshairsizeScript:TextFile;
  crosshairsizeValue:TextFile;
  gpucolorValue:TextFile;
  gpucolorScript:TextFile;
  cpucolorValue:TextFile;
  cpucolorScript:TextFile;
  cpucolorhtml: string;
  gpucolorhtml: string;
  iordrwcolorhtml: string;
  iordrwcolorScript:TextFile;
  iordrwcolorValue:TextFile;
  vramcolorhtml: string;
  vramcolorValue: TextFile;
  vramcolorScript: TextFile;
  ramcolorhtml: string;
  ramcolorValue: TextFile;
  ramcolorScript: TextFile;
  frametimegraphcolorhtml: string;
  frametimegraphcolorValue: TextFile;
  frametimegraphcolorScript: TextFile;
  crosshaircolorhtml: string;
  crosshaircolorValue: Textfile;
  crosshaircolorScript: Textfile;
  hudbackgroundcolorhtml: string;
  hudbackgroundcolorValue: Textfile;
  hudbackgroundcolorScript: Textfile;
  togglestateValueVAR: Textfile;
  togglestateValueSTR: string;
  toggleBasaltstateValueVAR: Textfile;
  toggleBasaltstateValueSTR: string;
  userhomepathVAR: Textfile;
  userhomepathSTR: string;
  destinationfolderValue: TextFile;
  destinationfolderScript: TextFile;
  hudfontcolorhtml: string;
  hudfontcolorValue: TextFile;
  hudfontcolorScript: TextFile;
  effectssum: Integer;
  cpunameValue: Textfile;
  cpunameScript: Textfile;
  cpunameSTR: string;
  gpunameValue: Textfile;
  gpunameScript: Textfile;
  gpunameSTR: string;
  mangohudVAR: Textfile;
  mangohudSTR: string;
  mangohuddependencyVALUE: Integer;
  vkbasaltVAR: Textfile;
  vkbasaltSTR: string;
  vkbasaltdependencyVALUE: Integer;
  replayVAR: Textfile;
  replaySTR: string;
  replaydependencyVALUE: Integer;
  mangohudsel: boolean;
  vkbasaltsel: boolean;
  replaysel: boolean;
  mangofile: Textfile;
  fileline : String;
  reshadepath1Value: Textfile;
  reshadepath1STR: string;
  reshadepath2Value: Textfile;
  reshadepath2STR: string;
  shaderspathValue: Textfile;
  shaderspathSTR: string;
  reshadegitVAR: Textfile;
  reshadegitSTR: string;
  numeffect: Integer;
  effectsValue: Textfile;
  effectsSTR: string;
  numeffects: integer;
  effect0Value: Textfile;
  effect0: string;
  effect1Value: Textfile;
  effect1: string;
  effect2Value: Textfile;
  effect2: string;
  effect3Value: Textfile;
  effect3: string;
  effect4Value: Textfile;
  effect4: string;
  casSTR: Boolean;
  cascheckValue: Textfile;
  winecolorhtml: string;
  winecolorValue: TextFile;
  winecolorScript: TextFile;
  enginecolorhtml: string;
  enginecolorValue: TextFile;
  enginecolorScript: TextFile;
  mediacolorhtml: string;
  mediacolorValue: TextFile;
  mediacolorScript: TextFile;
  hudtitleValue: Textfile;
  hudtitleScript: Textfile;
  hudtitleSTR: string;
  customcommandValue: Textfile;
  customcommandScript: Textfile;
  customcommandSTR: string;

  //ReplaySorcery variables
  reswidthCustomValue:TextFile;
  reswidthCustomValueScript:TextFile;
  resheightCustomValue:TextFile;
  resheightCustomValueScript:TextFile;
  scaleheightCustomValue:TextFile;
  scaleheightCustomValueScript:TextFile;
  scalewidthCustomValue:TextFile;
  scalewidthCustomValueScript:TextFile;



  // Variables for Shaders path
  TDFXshaderpathValue: Textfile;
  TDFXshaderpathSTR: string;
  AdaptiveFogshaderpathValue: Textfile;
  AdaptiveFogshaderpathSTR: string;
  AdaptiveSharpenshaderpathValue: Textfile;
  AdaptiveSharpenshaderpathSTR: string;
  AmbientLightshaderpathValue: Textfile;
  AmbientLightshaderpathSTR: string;
  ASCIIshaderpathValue: Textfile;
  ASCIIshaderpathSTR: string;
  AspectRatioshaderpathValue: Textfile;
  AspectRatioshaderpathSTR: string;
  BloomshaderpathValue: Textfile;
  BloomshaderpathSTR: string;
  BordershaderpathValue: Textfile;
  BordershaderpathSTR: string;
  CartoonshaderpathValue: Textfile;
  CartoonshaderpathSTR: string;
  ChromaKeyshaderpathValue: Textfile;
  ChromaKeyshaderpathSTR: string;
  ChromaticAberrationshaderpathValue: Textfile;
  ChromaticAberrationshaderpathSTR: string;
  CinematicDOFshaderpathValue: Textfile;
  CinematicDOFshaderpathSTR: string;
  ClarityshaderpathValue: Textfile;
  ClarityshaderpathSTR: string;
  ColorMatrixshaderpathValue: Textfile;
  ColorMatrixshaderpathSTR: string;
  ColourfulnessshaderpathValue: Textfile;
  ColourfulnessshaderpathSTR: string;
  CRTshaderpathValue: Textfile;
  CRTshaderpathSTR: string;
  CurvesshaderpathValue: Textfile;
  CurvesshaderpathSTR: string;
  DaltonizeshaderpathValue: Textfile;
  DaltonizeshaderpathSTR: string;
  DebandshaderpathValue: Textfile;
  DebandshaderpathSTR: string;
  DenoiseshaderpathValue: Textfile;
  DenoiseshaderpathSTR: string;
  Depth3DshaderpathValue: Textfile;
  Depth3DshaderpathSTR: string;
  DephhazeshaderpathValue: Textfile;
  DephhazeshaderpathSTR: string;
  DisplayDepthshaderpathValue: Textfile;
  DisplayDepthshaderpathSTR: string;
  DOFshaderpathValue: Textfile;
  DOFshaderpathSTR: string;
  DPXshaderpathValue: Textfile;
  DPXshaderpathSTR: string;
  EmphasizeshaderpathValue: Textfile;
  EmphasizeshaderpathSTR: string;
  EyeAdaptionshaderpathValue: Textfile;
  EyeAdaptionshaderpathSTR: string;
  FakeHDRshaderpathValue: Textfile;
  FakeHDRshaderpathSTR: string;
  FakeMotionBlurshaderpathValue: Textfile;
  FakeMotionBlurshaderpathSTR: string;
  FilmGrainshaderpathValue: Textfile;
  FilmGrainshaderpathSTR: string;
  FilmGrain2shaderpathValue: Textfile;
  FilmGrain2shaderpathSTR: string;
  FilmicAnamorphSharpenshaderpathValue: Textfile;
  FilmicAnamorphSharpenshaderpathSTR: string;
  FilmicPassshaderpathValue: Textfile;
  FilmicPassshaderpathSTR: string;
  FineSharpshaderpathValue: Textfile;
  FineSharpshaderpathSTR: string;
  FXAAshaderpathValue: Textfile;
  FXAAshaderpathSTR: string;
  GaussianBlurshaderpathValue: Textfile;
  GaussianBlurshaderpathSTR: string;
  GlitchshaderpathValue: Textfile;
  GlitchshaderpathSTR: string;
  HighPassSharpenshaderpathValue: Textfile;
  HighPassSharpenshaderpathSTR: string;
  HQ4XshaderpathValue: Textfile;
  HQ4XshaderpathSTR: string;
  HSLShiftshaderpathValue: Textfile;
  HSLShiftshaderpathSTR: string;
  LayershaderpathValue: Textfile;
  LayershaderpathSTR: string;
  LevelsshaderpathValue: Textfile;
  LevelsshaderpathSTR: string;
  LevelsPlusshaderpathValue: Textfile;
  LevelsPlusshaderpathSTR: string;
  LiftGammaGainshaderpathValue: Textfile;
  LiftGammaGainshaderpathSTR: string;
  LightDoFshaderpathValue: Textfile;
  LightDoFshaderpathSTR: string;
  LumaSharpenshaderpathValue: Textfile;
  LumaSharpenshaderpathSTR: string;
  LUTshaderpathValue: Textfile;
  LUTshaderpathSTR: string;
  MagicBloomshaderpathValue: Textfile;
  MagicBloomshaderpathSTR: string;
  MonochromeshaderpathValue: Textfile;
  MonochromeshaderpathSTR: string;
  MultiLUTshaderpathValue: Textfile;
  MultiLUTshaderpathSTR: string;
  MXAOshaderpathValue: Textfile;
  MXAOshaderpathSTR: string;
  NightVisionshaderpathValue: Textfile;
  NightVisionshaderpathSTR: string;
  NostalgiashaderpathValue: Textfile;
  NostalgiashaderpathSTR: string;
  PerfectPerspectiveshaderpathValue: Textfile;
  PerfectPerspectiveshaderpathSTR: string;
  PPFX_BloomshaderpathValue: Textfile;
  PPFX_BloomshaderpathSTR: string;
  PPFX_GodraysshaderpathValue: Textfile;
  PPFX_GodraysshaderpathSTR: string;
  PrismshaderpathValue: Textfile;
  PrismshaderpathSTR: string;
  ReflectiveBumpMappingshaderpathValue: Textfile;
  ReflectiveBumpMappingshaderpathSTR: string;
  SepiashaderpathValue: Textfile;
  SepiashaderpathSTR: string;
  SMAAshaderpathValue: Textfile;
  SMAAshaderpathSTR: string;
  SplitscreenshaderpathValue: Textfile;
  SplitscreenshaderpathSTR: string;
  StageDepthshaderpathValue: Textfile;
  StageDepthshaderpathSTR: string;
  SurfaceBlurshaderpathValue: Textfile;
  SurfaceBlurshaderpathSTR: string;
  TechnicolorshaderpathValue: Textfile;
  TechnicolorshaderpathSTR: string;
  Technicolor2shaderpathValue: Textfile;
  Technicolor2shaderpathSTR: string;
  TiltShiftshaderpathValue: Textfile;
  TiltShiftshaderpathSTR: string;
  TonemapshaderpathValue: Textfile;
  TonemapshaderpathSTR: string;
  TriDithershaderpathValue: Textfile;
  TriDithershaderpathSTR: string;
  UIDetectshaderpathValue: Textfile;
  UIDetectshaderpathSTR: string;
  UIMaskshaderpathValue: Textfile;
  UIMaskshaderpathSTR: string;
  VibranceshaderpathValue: Textfile;
  VibranceshaderpathSTR: string;
  VignetteshaderpathValue: Textfile;
  VignetteshaderpathSTR: string;

  //Variables for initial values
  initfpslimit: Textfile;
  initfpslimitSTR: string;
  initvsync: Textfile;
  initvsyncSTR: string;
  initgl_vsync: Textfile;
  initgl_vsyncSTR: string;
  initcpustats: Textfile;
  initcpustatsSTR: string;
  initcputemp: Textfile;
  initcputempSTR: string;
  initcoreload: Textfile;
  initcoreloadSTR: string;
  initgpustats: Textfile;
  initgpustatsSTR: string;
  initgputemp: Textfile;
  initgputempSTR: string;
  initgpucoreclock: Textfile;
  initgpucoreclockSTR: string;
  initgpumemclock: Textfile;
  initgpumemclockSTR: string;
  initgpupower: Textfile;
  initgpupowerSTR: string;
  initvulkandriver: Textfile;
  initvulkandriverSTR: string;
  initgpuname: Textfile;
  initgpunameSTR: string;
  initswap: Textfile;
  initswapSTR: string;
  initvram: Textfile;
  initvramSTR: string;
  initram: Textfile;
  initramSTR: string;
  initioread: Textfile;
  initioreadSTR: string;
  initframetiming: Textfile;
  initframetimingSTR: string;
  inithistogram: Textfile;
  inithistogramSTR: string;
  inittime: Textfile;
  inittimeSTR: string;
  inithudversion: Textfile;
  inithudversionSTR: string;
  initarch: Textfile;
  initarchSTR: string;
  initengineversion: Textfile;
  initengineversionSTR: string;
  initmediaplayer: Textfile;
  initmediaplayerSTR: string;
  initfontsize: Textfile;
  initfontsizeSTR: string;
  initposition: Textfile;
  initpositionSTR: string;
  initnodisplay: Textfile;
  initnodisplaySTR: string;
  inittogglehud: Textfile;
  inittogglehudSTR: string;
  inittogglelogging: Textfile;
  inittoggleloggingSTR: string;
  initmediaplayername: Textfile;
  initmediaplayernameSTR: string;
  initvkbasaltcas: Textfile;
  initvkbasaltcasSTR: string;
  initcasSharpness: Textfile;
  initcasSharpnessSTR: string;
  initcputextvalue: Textfile;
  initcputextvalueSTR: string;
  initgputextvalue: Textfile;
  initgputextvalueSTR: string;
  initfontsizevalue: Textfile;
  initfontsizevalueSTR: string;
  fontsizeINT: Integer;
  initwine: Textfile;
  initwineSTR: string;
  initeffect0: Textfile;
  initeffect0STR: string;
  initcascheckValue: Textfile;
  initcascheckSTR: string;
  initautoupload: Textfile;
  initautouploadSTR: string;
  initvkbasalttoggleValue: Textfile;
  initvkbasalttoggleSTR: string;
  initfps: Textfile;
  initfpsSTR: string;
  initshowfpslimit: Textfile;
  initshowfpslimitSTR: string;
  inittogglefpslimit: Textfile;
  inittogglefpslimitSTR: string;
  initresolution: Textfile;
  initresolutionSTR: string;
  initbattery: Textfile;
  initbatterySTR: string;
  initvkbasaltstatus: Textfile;
  initvkbasaltstatusSTR: string;
  initgamemodestatus: Textfile;
  initgamemodestatusSTR: string;
  initsession: Textfile;
  initsessionSTR: string;
  inithomepart: Textfile;
  inithomepartSTR: string;
  initdistroinfo: Textfile;
  initdistroinfoSTR: string;
  inithudtitlevalue: Textfile;
  inithudtitlevalueSTR: string;

  //GRAPHs variables
  initgraphgpuload: Textfile;
  initgraphgpuloadSTR: string;
  initgraphgputemp: Textfile;
  initgraphgputempSTR: string;
  initgraphgpucf: Textfile;
  initgraphgpucfSTR: string;
  initgraphgpumf: Textfile;
  initgraphgpumfSTR: string;
  initgraphvram: Textfile;
  initgraphvramSTR: string;
  initgraphcpuload: Textfile;
  initgraphcpuloadSTR: string;
  initgraphcputemp: Textfile;
  initgraphcputempSTR: string;
  initgraphram: Textfile;
  initgraphramSTR: string;

  //############################################Replay sorcery initial values
  initreplayframerateValue: Textfile;
  initreplayframerateSTR: string;
  initreplaydurationValue: Textfile;
  initreplaydurationSTR: string;
  initreplayvideoInputValue: Textfile;
  initreplayvideoInputSTR: string;
  initreplaykeynameValue: Textfile;
  initreplaykeynameSTR: string;
  initreplayaudiochannelsValue: Textfile;
  initreplayaudiochannelsSTR: string;
  initreplayaudiosampleValue: Textfile;
  initreplayaudiosampleSTR: string;
  initreplaybitrateValue: Textfile;
  initreplaybitrateSTR: string;
  initreplayfullscreenValue: textfile;
  initreplayfullscreenSTR: string;
  initreplayautoscaleValue: textfile;
  initreplayautoscaleSTR: string;
  initreplayvideoautoqualityValue: Textfile;
  initreplayvideoautoqualitySTR: string;
  initreplayvideoautobitrateValue: Textfile;
  initreplayvideoautobitrateSTR: string;
  initreplayaudioautobitrateValue: Textfile;
  initreplayaudioautobitrateSTR: string;
  initreplayvideoDeviceValue: Textfile;
  initreplayvideoDeviceSTR: string;
  initreplayvideoEncoderValue: Textfile;
  initreplayvideoEncoderSTR: string;
  initreplayvideoProfileValue: Textfile;
  initreplayvideoProfileSTR: string;
  initreplayvideoPresetValue: Textfile;
  initreplayvideoPresetSTR: string;
  initreplayvideoQualityValue: Textfile;
  initreplayvideoQualitySTR: string;
  initreplayvideoBitrateValue: Textfile;
  initreplayvideoBitrateSTR: string;
  initreplayvideoGOPValue: Textfile;
  initreplayvideoGOPSTR: string;
  initreplayaudioinputValue: Textfile;
  initreplayaudioinputSTR: string;
  initreplayaudiodeviceValue: Textfile;
  initreplayaudiodeviceSTR: string;
  initreplayaudioencoderValue: Textfile;
  initreplayaudioencoderSTR: string;
  initreplayaudioprofileValue: Textfile;
  initreplayaudioprofileSTR: string;
  initreplayaudiobitrateValue: Textfile;
  initreplayaudiobitrateSTR: string;




  customreswidthINT: integer;
  initcustomwidthValue: Textfile;
  initcustomwidthSTR: string;
  customresheightINT: integer;
  initcustomheightValue: Textfile;
  initcustomheightSTR: string;
  customoffsetYINT: integer;
  initcustomoffsetYValue: Textfile;
  initcustomoffsetYSTR: string;
  customoffsetXINT: integer;
  initcustomoffsetXValue: Textfile;
  initcustomoffsetXSTR: string;
  initreplaycompressQualityValue: Textfile;
  initreplaycompressQualitySTR: string;
  replaystateVAR: Textfile;
  replaystateSTR: string;
  replaytogglestateValueVAR: textfile;
  replaytogglestateValueSTR: string;

  cpuload1colorhtml: string;
  cpuload1colorValue: Textfile;
  cpuload1colorScript: Textfile;
  cpuload2colorhtml: string;
  cpuload2colorValue: Textfile;
  cpuload2colorScript: Textfile;
  cpuload3colorhtml: string;
  cpuload3colorValue: Textfile;
  cpuload3colorScript: Textfile;
  cpuloadcolorScript: Textfile;
  cpuloadcolorsScript: Textfile;
  gpuload1colorhtml: string;
  gpuload1colorValue: Textfile;
  gpuload1colorScript: Textfile;
  gpuload2colorhtml: string;
  gpuload2colorValue: Textfile;
  gpuload2colorScript: Textfile;
  gpuload3colorhtml: string;
  gpuload3colorValue: Textfile;
  gpuload3colorScript: Textfile;
  gpuloadcolorScript: Textfile;
  gpuloadcolorsScript: Textfile;
  autologValue: Textfile;
  autologScript: Textfile;


  initgpuloadchange: Textfile;
  initgpuloadchangeSTR: string;
  initcpuloadchange: Textfile;
  initcpuloadchangeSTR: string;
  initcpufreq: Textfile;
  initcpufreqSTR: string;
  initcpupower: Textfile;
  initcpupowerSTR: string;
  initautolog: Textfile;
  initautologSTR: string;
  autologINT: integer;

  //######################################## Variables for Mangohud Graphs
   gpuloadgraphVAR: boolean;

implementation

{$R *.lfm}


{ Tgoverlayform }

// Reference to logpathunit so the homepath can be aquired from overlayUnit
uses logpathUnit;

procedure Tgoverlayform.saveBitBtnClick(Sender: TObject);
begin
  //Create directories
  RunCommand('bash -c ''mkdir -p $HOME/.config/MangoHud/''', s);
  //RunCommand('bash -c ''mkdir -p $HOME/.config/goverlay/values/''', s);


  // Delete old file if it exists
  RunCommand('bash -c ''rm $HOME/.config/MangoHud/MangoHud.conf''', s);

  // Create a new file for GOverlay
  RunCommand('bash -c ''echo "################### File Generated by GOverlay ###################" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

  // Popup a notification
  RunCommand('bash -c ''notify-send -i /usr/share/icons/hicolor/128x128/apps/goverlay.png "MangoHud" "Configuration saved"''', s);




  // ###################################################################################### HUD Title

      // Only create title entry if title isn't blank and diferent of default title
      if (hudtitleEdit.text <> '') and (hudtitleEdit.text <> 'HUD Title') then

       begin

      hudtitleSTR := hudtitleEdit.text;

      // Assign value to file
      AssignFile(hudtitleValue, '/tmp/goverlay/hudtitleValue');
      Rewrite(hudtitleValue);
      Writeln(hudtitleValue,hudtitleSTR);
      CloseFile(hudtitleValue);

      // Create custom script
      AssignFile(hudtitleScript, '/tmp/goverlay/hudtitleScript.sh');
      Rewrite(hudtitleScript);
      Writeln(hudtitleScript,'hudtitle=$(cat /tmp/goverlay/hudtitleValue)');  //Store hud title in Linux/Unix variable and remove # character
      Writeln(hudtitleScript,'echo "custom_text_center=$hudtitle" >> $HOME/.config/MangoHud/MangoHud.conf'); //Create correct command with name value
      CloseFile(hudtitleScript);

      //execute custom script to store custom value on mangohud.conf
      RunCommand('bash -c ''sh /tmp/goverlay/hudtitleScript.sh''', s);
        end;


  //####################################################################################### PERFORMANCE


  //Setup FPS Limit
       case fpslimCombobox.ItemIndex of
      0:RunCommand('bash -c ''echo "fps_limit=15" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
      1:RunCommand('bash -c ''echo "fps_limit=30" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
      2:RunCommand('bash -c ''echo "fps_limit=45" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
      3:RunCommand('bash -c ''echo "fps_limit=60" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
      4:RunCommand('bash -c ''echo "fps_limit=60,30" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
      5:RunCommand('bash -c ''echo "fps_limit=90" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
      6:RunCommand('bash -c ''echo "fps_limit=120" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
      7:RunCommand('bash -c ''echo "fps_limit=120,60" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
      8:RunCommand('bash -c ''echo "fps_limit=144" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
      9:RunCommand('bash -c ''echo "fps_limit=240" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
      10:RunCommand('bash -c ''echo "fps_limit=300" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
      11:RunCommand('bash -c ''echo "fps_limit=360" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
      12:RunCommand('bash -c ''echo "fps_limit=420" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
      13:RunCommand('bash -c ''echo "#fps_limit=" >> $HOME/.config/MangoHud/MangoHud.conf''', s);    // unlocked

      14:begin        //14 is the custom command
        // Assign custom value to file
        AssignFile(fpsCustomValue, '/tmp/goverlay/fpsCustom');
        Rewrite(fpsCustomValue);
        Writeln(fpsCustomValue,fpscustomSpinedit.Value);
        CloseFile(fpsCustomValue);

        // Create custom script
        AssignFile(fpsCustomScript, '/tmp/goverlay/fpsCustomScript.sh');
        Rewrite(fpsCustomScript);
        Writeln(fpsCustomScript,'FPSc=$(cat /tmp/goverlay/fpsCustom)');  //Store fps custom value in a Linux/Unix variable
        Writeln(fpsCustomScript,'echo "fps_limit=$FPSc" >> $HOME/.config/MangoHud/MangoHud.conf'); //Create correct command with custom value
        CloseFile(fpsCustomScript);

        //execute custom script to store custom value on mangohud.conf
        RunCommand('bash -c ''sh /tmp/goverlay/fpsCustomScript.sh''', s);
       end;

       15:RunCommand('bash -c ''echo "" >> $HOME/.config/MangoHud/MangoHud.conf''', s);  // unset
       end;



   //FPS Limit toggle
  case fpslimtoggleCombobox.ItemIndex of
    0:RunCommand('bash -c ''echo "toggle_fps_limit=F1" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    1:RunCommand('bash -c ''echo "toggle_fps_limit=F2" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    2:RunCommand('bash -c ''echo "toggle_fps_limit=F3" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    3:RunCommand('bash -c ''echo "toggle_fps_limit=F4" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
  end;


  //Setup VSYNC

  //VULKAN VSYNC
  case vsyncCombobox.ItemIndex of
    0:RunCommand('bash -c ''echo "vsync=0" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    1:RunCommand('bash -c ''echo "vsync=1" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    2:RunCommand('bash -c ''echo "vsync=2" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    3:RunCommand('bash -c ''echo "vsync=3" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    4:RunCommand('bash -c ''echo "" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
  end;

  //OPENGL VSYNC
  case glvsyncCombobox.ItemIndex of
    0:RunCommand('bash -c ''echo "gl_vsync=-1" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    1:RunCommand('bash -c ''echo "gl_vsync=0" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    2:RunCommand('bash -c ''echo "gl_vsync=n" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    3:RunCommand('bash -c ''echo "gl_vsync=1" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    4:RunCommand('bash -c ''echo "" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
  end;

  //####################################################################################### MANGOHUD
  
  // Set non legacy mode
  RunCommand('bash -c ''echo "legacy_layout=false" >> $HOME/.config/MangoHud/MangoHud.conf''', s);


  //###################################################### GPU

  //GPU checks

  //GPU LOAD
  if gpuavrloadCheckbox.Checked=true then
  RunCommand('bash -c ''echo "gpu_stats" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

    //GPU LOAD GRAPH
     if gpuloadgraphBitbtn.ImageIndex=2 then
     RunCommand('bash -c ''echo "graphs=gpu_load" >> $HOME/.config/MangoHud/MangoHud.conf''', s);



  //GPU TEMP
  if gputempCheckbox.Checked=true then
  RunCommand('bash -c ''echo "gpu_temp" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

      //GPU TEMP GRAPH
     if gpucfgraphBitbtn.ImageIndex=2 then
     RunCommand('bash -c ''echo "graphs=gpu_temp" >> $HOME/.config/MangoHud/MangoHud.conf''', s);



  //GPU CORE FREQ
  if gpufreqCheckbox.Checked=true then
  RunCommand('bash -c ''echo "gpu_core_clock" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

        //GPU CORE FREQ GRAPH
     if gputempgraphBitbtn.ImageIndex=2 then
     RunCommand('bash -c ''echo "graphs=gpu_core_clock" >> $HOME/.config/MangoHud/MangoHud.conf''', s);


  //GPU MEM FREQ
  if gpumemfreqCheckbox.Checked=true then
  RunCommand('bash -c ''echo "gpu_mem_clock" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

       //GPU MEM FREQ GRAPH
     if gpumfgraphBitbtn.ImageIndex=2 then
     RunCommand('bash -c ''echo "graphs=gpu_mem_clock" >> $HOME/.config/MangoHud/MangoHud.conf''', s);


  //GPU Power
  if gpupowerCheckbox.Checked=true then
  RunCommand('bash -c ''echo "gpu_power" >> $HOME/.config/MangoHud/MangoHud.conf''', s);


  //GPU LOAD COLORS
  if gpuloadcolorCheckbox.Checked=true then
  begin
  RunCommand('bash -c ''echo "gpu_load_change" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
  RunCommand('bash -c ''echo "gpu_load_value=50,90" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

   //Store gpu load colors
          //Use function SColorToHtmlColor from unit ATStringProc_htmlColor to change color format to RGB and store in text file
          gpuload1colorhtml := SColorToHtmlColor(gpuload1colorButton.ButtonColor);
          gpuload2colorhtml := SColorToHtmlColor(gpuload2colorButton.ButtonColor);
          gpuload3colorhtml := SColorToHtmlColor(gpuload3colorButton.ButtonColor);

          // gpu LOAD 1 Color - Assign value to file
          AssignFile(gpuload1colorValue, '/tmp/goverlay/gpuload1colorValue');
          Rewrite(gpuload1colorValue);
          Writeln(gpuload1colorValue,gpuload1colorhtml);
          CloseFile(gpuload1colorValue);

          // gpu LOAD 1 Color - Create custom script to store value in unix variable
          AssignFile(gpuload1colorScript, '/tmp/goverlay/gpuload1colorScript.sh');
          Rewrite(gpuload1colorScript);
          Writeln(gpuload1colorScript,'gpuL1c=$(cat /tmp/goverlay/gpuload1colorValue | cut -c 2-10)');  //Store gpu Load1 color in Linux/Unix variable and remove # character
          CloseFile(gpuload1colorScript);

          //gpu LOAD 1 Color - execute custom script
          RunCommand('bash -c ''sh /tmp/goverlay/gpuload1colorScript.sh''', s);



          // gpu LOAD 2 Color - Assign value to file
          AssignFile(gpuload2colorValue, '/tmp/goverlay/gpuload2colorValue');
          Rewrite(gpuload2colorValue);
          Writeln(gpuload2colorValue,gpuload2colorhtml);
          CloseFile(gpuload2colorValue);

          // gpu LOAD 2 Color - Create custom script to store value in unix variable
          AssignFile(gpuload2colorScript, '/tmp/goverlay/gpuload2colorScript.sh');
          Rewrite(gpuload2colorScript);
          Writeln(gpuload2colorScript,'gpuL2c=$(cat /tmp/goverlay/gpuload2colorValue | cut -c 2-10)');  //Store gpu Load2 color in Linux/Unix variable and remove # character
          CloseFile(gpuload2colorScript);

          //gpu LOAD 2 Color - execute custom script
          RunCommand('bash -c ''sh /tmp/goverlay/gpuload2colorScript.sh''', s);




          // gpu LOAD 3 Color - Assign value to file
          AssignFile(gpuload3colorValue, '/tmp/goverlay/gpuload3colorValue');
          Rewrite(gpuload3colorValue);
          Writeln(gpuload3colorValue,gpuload3colorhtml);
          CloseFile(gpuload3colorValue);

          // gpu LOAD 3 Color - Create custom script to store value in unix variable
          AssignFile(gpuload3colorScript, '/tmp/goverlay/gpuload3colorScript.sh');
          Rewrite(gpuload3colorScript);
          Writeln(gpuload3colorScript,'gpuL3c=$(cat /tmp/goverlay/gpuload3colorValue | cut -c 2-10)');  //Store gpu Load3 color in Linux/Unix variable and remove # character
          CloseFile(gpuload3colorScript);

          //gpu LOAD 3 Color - execute custom script
          RunCommand('bash -c ''sh /tmp/goverlay/gpuload3colorScript.sh''', s);




          //gpu LOAD Colors - Create custom script with all colors
          AssignFile(gpuloadcolorsScript, '/tmp/goverlay/gpuloadcolorsScript.sh');
          Rewrite(gpuloadcolorsScript);
          Writeln(gpuloadcolorsScript,'gpuL1c=$(cat /tmp/goverlay/gpuload1colorValue | cut -c 2-10)');  //Store gpu Load1 color in Linux/Unix variable and remove # character
          Writeln(gpuloadcolorsScript,'gpuL2c=$(cat /tmp/goverlay/gpuload2colorValue | cut -c 2-10)');  //Store gpu Load2 color in Linux/Unix variable and remove # character
          Writeln(gpuloadcolorsScript,'gpuL3c=$(cat /tmp/goverlay/gpuload3colorValue | cut -c 2-10)');  //Store gpu Load3 color in Linux/Unix variable and remove # character
          Writeln(gpuloadcolorsScript,'echo gpu_load_color=$gpuL1c,$gpuL2c,$gpuL3c >> $HOME/.config/MangoHud/MangoHud.conf'); //Create correct command
          CloseFile(gpuloadcolorsScript);


          //gpu LOAD Colors - execute custom script with all colors
          RunCommand('bash -c ''sh /tmp/goverlay/gpuloadcolorsScript.sh''', s);

  end;

      //GPU Name

      gpunameSTR := gpunameEdit.text;

      // Assign value to file
      AssignFile(gpunameValue, '/tmp/goverlay/gpunameValue');
      Rewrite(gpunameValue);
      Writeln(gpunameValue,gpunameSTR);
      CloseFile(gpunameValue);

      // Create custom script
      AssignFile(gpunameScript, '/tmp/goverlay/gpunameScript.sh');
      Rewrite(gpunameScript);
      Writeln(gpunameScript,'gpuname=$(cat /tmp/goverlay/gpunameValue)');  //Store gpu name in Linux/Unix variable and remove # character
      Writeln(gpunameScript,'echo "gpu_text=$gpuname" >> $HOME/.config/MangoHud/MangoHud.conf'); //Create correct command with name value
      CloseFile(gpunameScript);

      //execute custom script to store custom value on mangohud.conf
      RunCommand('bash -c ''sh /tmp/goverlay/gpunameScript.sh''', s);

    //###################################################### GPU

  //###################################################### CPU


  //CPU LOAD
  if cpuavrloadCheckbox.Checked=true then
  RunCommand('bash -c ''echo "cpu_stats" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

          //CPU LOAD GRAPH
        if cpuloadgraphBitbtn.ImageIndex=2 then
        RunCommand('bash -c ''echo "graphs=cpu_load" >> $HOME/.config/MangoHud/MangoHud.conf''', s);


  //CPU TEMP
  if cputempCheckbox.Checked=true then
  RunCommand('bash -c ''echo "cpu_temp" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

            //CPU TEMP GRAPH
        if cputempgraphBitbtn.ImageIndex=2 then
        RunCommand('bash -c ''echo "graphs=cpu_temp" >> $HOME/.config/MangoHud/MangoHud.conf''', s);


  //CPU LOAD CORES
  if cpuloadcoreCheckbox.Checked=true then
  RunCommand('bash -c ''echo "core_load" >> $HOME/.config/MangoHud/MangoHud.conf''', s);


  //CPU POWER
  if cpupowerCheckbox.Checked=true then
  RunCommand('bash -c ''echo "cpu_power" >> $HOME/.config/MangoHud/MangoHud.conf''', s);


  //CPU FREQUENCY
  if cpufreqCheckbox.Checked=true then
  RunCommand('bash -c ''echo "cpu_mhz" >> $HOME/.config/MangoHud/MangoHud.conf''', s);


  //CPU LOAD COLOR
  if cpuloadcolorCheckbox.Checked=true then
  begin
  RunCommand('bash -c ''echo "cpu_load_change" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
  RunCommand('bash -c ''echo "core_load_change" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
  RunCommand('bash -c ''echo "cpu_load_value=50,90" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

     //Store cpu load colors
          //Use function SColorToHtmlColor from unit ATStringProc_htmlColor to change color format to RGB and store in text file
          cpuload1colorhtml := SColorToHtmlColor(cpuload1colorButton.ButtonColor);
          cpuload2colorhtml := SColorToHtmlColor(cpuload2colorButton.ButtonColor);
          cpuload3colorhtml := SColorToHtmlColor(cpuload3colorButton.ButtonColor);

          // CPU LOAD 1 Color - Assign value to file
          AssignFile(cpuload1colorValue, '/tmp/goverlay/cpuload1colorValue');
          Rewrite(cpuload1colorValue);
          Writeln(cpuload1colorValue,cpuload1colorhtml);
          CloseFile(cpuload1colorValue);

          // CPU LOAD 1 Color - Create custom script to store value in unix variable
          AssignFile(cpuload1colorScript, '/tmp/goverlay/cpuload1colorScript.sh');
          Rewrite(cpuload1colorScript);
          Writeln(cpuload1colorScript,'CPUL1c=$(cat /tmp/goverlay/cpuload1colorValue | cut -c 2-10)');  //Store cpu Load1 color in Linux/Unix variable and remove # character
          CloseFile(cpuload1colorScript);

          //CPU LOAD 1 Color - execute custom script
          RunCommand('bash -c ''sh /tmp/goverlay/cpuload1colorScript.sh''', s);



          // CPU LOAD 2 Color - Assign value to file
          AssignFile(cpuload2colorValue, '/tmp/goverlay/cpuload2colorValue');
          Rewrite(cpuload2colorValue);
          Writeln(cpuload2colorValue,cpuload2colorhtml);
          CloseFile(cpuload2colorValue);

          // CPU LOAD 2 Color - Create custom script to store value in unix variable
          AssignFile(cpuload2colorScript, '/tmp/goverlay/cpuload2colorScript.sh');
          Rewrite(cpuload2colorScript);
          Writeln(cpuload2colorScript,'CPUL2c=$(cat /tmp/goverlay/cpuload2colorValue | cut -c 2-10)');  //Store cpu Load2 color in Linux/Unix variable and remove # character
          CloseFile(cpuload2colorScript);

          //CPU LOAD 2 Color - execute custom script
          RunCommand('bash -c ''sh /tmp/goverlay/cpuload2colorScript.sh''', s);




          // CPU LOAD 3 Color - Assign value to file
          AssignFile(cpuload3colorValue, '/tmp/goverlay/cpuload3colorValue');
          Rewrite(cpuload3colorValue);
          Writeln(cpuload3colorValue,cpuload3colorhtml);
          CloseFile(cpuload3colorValue);

          // CPU LOAD 3 Color - Create custom script to store value in unix variable
          AssignFile(cpuload3colorScript, '/tmp/goverlay/cpuload3colorScript.sh');
          Rewrite(cpuload3colorScript);
          Writeln(cpuload3colorScript,'CPUL3c=$(cat /tmp/goverlay/cpuload3colorValue | cut -c 2-10)');  //Store cpu Load3 color in Linux/Unix variable and remove # character
          CloseFile(cpuload3colorScript);

          //CPU LOAD 3 Color - execute custom script
          RunCommand('bash -c ''sh /tmp/goverlay/cpuload3colorScript.sh''', s);




          //CPU LOAD Colors - Create custom script with all colors
          AssignFile(cpuloadcolorsScript, '/tmp/goverlay/cpuloadcolorsScript.sh');
          Rewrite(cpuloadcolorsScript);
          Writeln(cpuloadcolorsScript,'CPUL1c=$(cat /tmp/goverlay/cpuload1colorValue | cut -c 2-10)');  //Store cpu Load1 color in Linux/Unix variable and remove # character
          Writeln(cpuloadcolorsScript,'CPUL2c=$(cat /tmp/goverlay/cpuload2colorValue | cut -c 2-10)');  //Store cpu Load2 color in Linux/Unix variable and remove # character
          Writeln(cpuloadcolorsScript,'CPUL3c=$(cat /tmp/goverlay/cpuload3colorValue | cut -c 2-10)');  //Store cpu Load3 color in Linux/Unix variable and remove # character
          Writeln(cpuloadcolorsScript,'echo cpu_load_color=$CPUL1c,$CPUL2c,$CPUL3c >> $HOME/.config/MangoHud/MangoHud.conf'); //Create correct command
          CloseFile(cpuloadcolorsScript);


          //CPU LOAD Colors - execute custom script with all colors
          RunCommand('bash -c ''sh /tmp/goverlay/cpuloadcolorsScript.sh''', s);


  end;




  //CPU Color

      // Assign value to file
      AssignFile(cpucolorValue, '/tmp/goverlay/cpucolorValue');
      Rewrite(cpucolorValue);
      Writeln(cpucolorValue,cpucolorhtml);
      CloseFile(cpucolorValue);

      // Create custom script
      AssignFile(cpucolorScript, '/tmp/goverlay/cpucolorScript.sh');
      Rewrite(cpucolorScript);
      Writeln(cpucolorScript,'CPUc=$(cat /tmp/goverlay/cpucolorValue | cut -c 2-10)');  //Store cpu color in Linux/Unix variable and remove # character
      Writeln(cpucolorScript,'echo "cpu_color=$CPUc" >> $HOME/.config/MangoHud/MangoHud.conf'); //Create correct command with color value
      CloseFile(cpucolorScript);

      //execute custom script to store custom value on mangohud.conf
      RunCommand('bash -c ''sh /tmp/goverlay/cpucolorScript.sh''', s);



       //CPU Name

      cpunameSTR := cpunameEdit.text;

      // Assign value to file
      AssignFile(cpunameValue, '/tmp/goverlay/cpunameValue');
      Rewrite(cpunameValue);
      Writeln(cpunameValue,cpunameSTR);
      CloseFile(cpunameValue);

      // Create custom script
      AssignFile(cpunameScript, '/tmp/goverlay/cpunameScript.sh');
      Rewrite(cpunameScript);
      Writeln(cpunameScript,'CPUname=$(cat /tmp/goverlay/cpunameValue)');  //Store cpu name in Linux/Unix variable and remove # character
      Writeln(cpunameScript,'echo "cpu_text=$CPUname" >> $HOME/.config/MangoHud/MangoHud.conf'); //Create correct command with name value
      CloseFile(cpunameScript);

      //execute custom script to store custom value on mangohud.conf
      RunCommand('bash -c ''sh /tmp/goverlay/cpunameScript.sh''', s);

      //###################################################### CPU





   //###################################################### OTHERS


  //Disk IO

  if diskioCheckbox.Checked=true then
  begin
  RunCommand('bash -c ''echo "io_stats" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
  RunCommand('bash -c ''echo "io_read" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
  RunCommand('bash -c ''echo "io_write" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
  end;

  //DISK IO Color

      // Assign value to file
      AssignFile(iordrwcolorValue, '/tmp/goverlay/iordrwcolorValue');
      Rewrite(iordrwcolorValue);
      Writeln(iordrwcolorValue,iordrwcolorhtml);
      CloseFile(iordrwcolorValue);

      // Create custom script
      AssignFile(iordrwcolorScript, '/tmp/goverlay/iordrwcolorScript.sh');
      Rewrite(iordrwcolorScript);
      Writeln(iordrwcolorScript,'IOc=$(cat /tmp/goverlay/iordrwcolorValue | cut -c 2-10)');  //Store io color in Linux/Unix variable and remove # character
      Writeln(iordrwcolorScript,'echo "io_color=$IOc" >> $HOME/.config/MangoHud/MangoHud.conf'); //Create correct command with color value
      CloseFile(iordrwcolorScript);

      //execute custom script to store custom value on mangohud.conf
      RunCommand('bash -c ''sh /tmp/goverlay/iordrwcolorScript.sh''', s);

  //SWAP
  if swapusageCheckbox.Checked=true then
  RunCommand('bash -c ''echo "swap" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

 //VRAM
  if vramusageCheckbox.Checked=true then
  RunCommand('bash -c ''echo "vram" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

        //VRAM GRAPH
        if vramgraphBitbtn.ImageIndex=2 then
        RunCommand('bash -c ''echo "graphs=vram" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

  //VRAM Color

      // Assign value to file
      AssignFile(vramcolorValue, '/tmp/goverlay/vramcolorValue');
      Rewrite(vramcolorValue);
      Writeln(vramcolorValue,vramcolorhtml);
      CloseFile(vramcolorValue);

      // Create custom script
      AssignFile(vramcolorScript, '/tmp/goverlay/vramcolorScript.sh');
      Rewrite(vramcolorScript);
      Writeln(vramcolorScript,'VRAMc=$(cat /tmp/goverlay/vramcolorValue | cut -c 2-10)');  //Store vram color in Linux/Unix variable and remove # character
      Writeln(vramcolorScript,'echo "vram_color=$VRAMc" >> $HOME/.config/MangoHud/MangoHud.conf'); //Create correct command with crosshair color value
      CloseFile(vramcolorScript);

      //execute custom script to store custom value on mangohud.conf
      RunCommand('bash -c ''sh /tmp/goverlay/vramcolorScript.sh''', s);

   //RAM
   if ramusageCheckbox.Checked=true then
  RunCommand('bash -c ''echo "ram" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

        //RAM GRAPH
        if ramgraphBitbtn.ImageIndex=2 then
        RunCommand('bash -c ''echo "graphs=ram" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

    //RAM Color
    // Assign value to file
      AssignFile(ramcolorValue, '/tmp/goverlay/ramcolorValue');
      Rewrite(ramcolorValue);
      Writeln(ramcolorValue,ramcolorhtml);
      CloseFile(ramcolorValue);

      // Create custom script
      AssignFile(ramcolorScript, '/tmp/goverlay/ramcolorScript.sh');
      Rewrite(ramcolorScript);
      Writeln(ramcolorScript,'RAMc=$(cat /tmp/goverlay/ramcolorValue | cut -c 2-10)');  //Store ram color in Linux/Unix variable and remove # character
      Writeln(ramcolorScript,'echo "ram_color=$RAMc" >> $HOME/.config/MangoHud/MangoHud.conf'); //Create correct command with crosshair color value
      CloseFile(ramcolorScript);

      //execute custom script to store custom value on mangohud.conf
      RunCommand('bash -c ''sh /tmp/goverlay/ramcolorScript.sh''', s);


//FPS
   if fpsCheckbox.Checked=true then
   RunCommand('bash -c ''echo "fps" >> $HOME/.config/MangoHud/MangoHud.conf''', s);



  //Engine version
  if engineversionCheckbox.Checked=true then
  RunCommand('bash -c ''echo "engine_version" >> $HOME/.config/MangoHud/MangoHud.conf''', s);



  //engine Color
      // Assign value to file
      AssignFile(enginecolorValue, '/tmp/goverlay/enginecolorValue');
      Rewrite(enginecolorValue);
      Writeln(enginecolorValue,enginecolorhtml);
      CloseFile(enginecolorValue);

      // Create custom script
      AssignFile(enginecolorScript, '/tmp/goverlay/enginecolorScript.sh');
      Rewrite(enginecolorScript);
      Writeln(enginecolorScript,'ENGc=$(cat /tmp/goverlay/enginecolorValue | cut -c 2-10)');  //Store color in Linux/Unix variable and remove # character
      Writeln(enginecolorScript,'echo "engine_color=$ENGc" >> $HOME/.config/MangoHud/MangoHud.conf'); //Create correct command with crosshair color value
      CloseFile(enginecolorScript);

      //execute custom script to store custom value on mangohud.conf
      RunCommand('bash -c ''sh /tmp/goverlay/enginecolorScript.sh''', s);


  //Others checks

    //GPU Name - Model
    if gpumodelCheckBox.Checked=true then
    RunCommand('bash -c ''echo "gpu_name" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

    //GPU name Color

      // Assign value to file
      AssignFile(gpucolorValue, '/tmp/goverlay/gpucolorValue');
      Rewrite(gpucolorValue);
      Writeln(gpucolorValue,gpucolorhtml);
      CloseFile(gpucolorValue);

      // Create custom script
      AssignFile(gpucolorScript, '/tmp/goverlay/gpucolorScript.sh');
      Rewrite(gpucolorScript);
      Writeln(gpucolorScript,'GPUc=$(cat /tmp/goverlay/gpucolorValue | cut -c 2-10)');  //Store gpu color in Linux/Unix variable and remove # character
      Writeln(gpucolorScript,'echo "gpu_color=$GPUc" >> $HOME/.config/MangoHud/MangoHud.conf'); //Create correct command with crosshair color value
      CloseFile(gpucolorScript);

      //execute custom script to store custom value on mangohud.conf
      RunCommand('bash -c ''sh /tmp/goverlay/gpucolorScript.sh''', s);

  //Driver version
    if driverversionCheckbox.Checked=true then
  RunCommand('bash -c ''echo "vulkan_driver" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

  //Arch
  if archCheckbox.Checked=true then
  RunCommand('bash -c ''echo "arch" >> $HOME/.config/MangoHud/MangoHud.conf''', s);



  //Wine
  if wineCheckbox.Checked=true then
  RunCommand('bash -c ''echo "wine" >> $HOME/.config/MangoHud/MangoHud.conf''', s);



  //wine Color
    // Assign value to file
      AssignFile(winecolorValue, '/tmp/goverlay/winecolorValue');
      Rewrite(winecolorValue);
      Writeln(winecolorValue,winecolorhtml);
      CloseFile(winecolorValue);

      // Create custom script
      AssignFile(winecolorScript, '/tmp/goverlay/winecolorScript.sh');
      Rewrite(winecolorScript);
      Writeln(winecolorScript,'WINEc=$(cat /tmp/goverlay/winecolorValue | cut -c 2-10)');  //Store color in Linux/Unix variable and remove # character
      Writeln(winecolorScript,'echo "wine_color=$WINEc" >> $HOME/.config/MangoHud/MangoHud.conf'); //Create correct command with crosshair color value
      CloseFile(winecolorScript);

      //execute custom script to store custom value on mangohud.conf
      RunCommand('bash -c ''sh /tmp/goverlay/winecolorScript.sh''', s);




  //Frame time
  if frametimegraphCheckbox.Checked=true then
  RunCommand('bash -c ''echo "frame_timing=1" >> $HOME/.config/MangoHud/MangoHud.conf''', s)
  else
  RunCommand('bash -c ''echo "frame_timing=0" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

    //Frame time Graph Color
    // Assign value to file
      AssignFile(frametimegraphcolorValue, '/tmp/goverlay/frametimegraphcolorValue');
      Rewrite(frametimegraphcolorValue);
      Writeln(frametimegraphcolorValue,frametimegraphcolorhtml);
      CloseFile(frametimegraphcolorValue);

      // Create custom script
      AssignFile(frametimegraphcolorScript, '/tmp/goverlay/frametimegraphcolorScript.sh');
      Rewrite(frametimegraphcolorScript);
      Writeln(frametimegraphcolorScript,'FTGc=$(cat /tmp/goverlay/frametimegraphcolorValue | cut -c 2-10)');  //Store frame time graph color in Linux/Unix variable and remove # character
      Writeln(frametimegraphcolorScript,'echo "frametime_color=$FTGc" >> $HOME/.config/MangoHud/MangoHud.conf'); //Create correct command with crosshair color value
      CloseFile(frametimegraphcolorScript);

      //execute custom script to store custom value on mangohud.conf
      RunCommand('bash -c ''sh /tmp/goverlay/frametimegraphcolorScript.sh''', s);


      //Change Frame time graph to histogram

      if framehistogramRadioButton.Checked=true then
      RunCommand('bash -c ''echo "histogram" >> $HOME/.config/MangoHud/MangoHud.conf''', s) ;


//show fps limitation
if showfpslimCheckbox.Checked=true then
RunCommand('bash -c ''echo "show_fps_limit" >> $HOME/.config/MangoHud/MangoHud.conf''', s);



//show Resolution
if resolutionCheckbox.Checked=true then
RunCommand('bash -c ''echo "resolution" >> $HOME/.config/MangoHud/MangoHud.conf''', s);



//show vkbasalt status
if vkbasaltstatusCheckbox.Checked=true then
RunCommand('bash -c ''echo "vkbasalt" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

//show gamemode status
if gamemodestatusCheckbox.Checked=true then
RunCommand('bash -c ''echo "gamemode" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

//show Battery
if batteryCheckbox.Checked=true then
begin
RunCommand('bash -c ''echo "battery" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
RunCommand('bash -c ''echo "exec=echo #add a line for text space" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
RunCommand('bash -c ''echo "exec=echo #add a line for text space" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
end;

//show Distro info
if distroinfoCheckBox.Checked=true then
begin
RunCommand('bash -c ''echo "exec=echo #add a line for text space" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
RunCommand('bash -c ''echo "exec=echo #add a line for text space" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
RunCommand('bash -c ''echo "exec=lsb_release -a | grep Description | cut -c 14-26" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
RunCommand('bash -c ''echo "exec=lsb_release -a | grep Release | cut -c 10-26" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
RunCommand('bash -c ''echo "exec=echo #add a line for text space" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
RunCommand('bash -c ''echo "custom_text=Kernel:" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
RunCommand('bash -c ''echo "exec=uname -r" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
end;

//show Session type
if sessionCheckbox.Checked=true then
begin
RunCommand('bash -c ''echo "exec=echo #add a line for text space" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
RunCommand('bash -c ''echo "custom_text=Session:" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
RunCommand('bash -c ''echo "exec=printf $XDG_SESSION_TYPE" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
end;

//show home partition size
if homepartCheckbox.Checked=true then
begin
RunCommand('bash -c ''echo "exec=echo #add a line for text space" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
RunCommand('bash -c ''echo "exec=df -h /home | tail -n 1" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
RunCommand('bash -c ''echo "exec=echo #add a line for text space" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
RunCommand('bash -c ''echo "exec=echo #add a line for text space" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
end;


// ###################################################################################### Custom Command

    // Only create custom command entry if entry isn't blank
    //if customcommandEdit.text <> '' then

    if (customcommandEdit.text <> '') and (customcommandEdit.text <> 'Custom command') then
    begin

    customcommandSTR := customcommandEdit.text;

    // Assign value to file
    AssignFile(customcommandValue, '/tmp/goverlay/customcommandValue');
    Rewrite(customcommandValue);
    Writeln(customcommandValue,customcommandSTR);
    CloseFile(customcommandValue);

    // Create custom script
    AssignFile(customcommandScript, '/tmp/goverlay/customcommandScript.sh');
    Rewrite(customcommandScript);
    Writeln(customcommandScript,'customcommand=$(cat /tmp/goverlay/customcommandValue)');  //Store custom command in Linux/Unix variable and remove # character
    Writeln(customcommandScript,'echo "exec=$customcommand" >> $HOME/.config/MangoHud/MangoHud.conf'); //Create correct command with name value
    CloseFile(customcommandScript);

    //execute custom script to store custom value on mangohud.conf
    RunCommand('bash -c ''sh /tmp/goverlay/customcommandScript.sh''', s);

     end;


  //Media Player
  if mediaCheckBox.Checked=true then
  RunCommand('bash -c ''echo "media_player" >> $HOME/.config/MangoHud/MangoHud.conf''', s);


  //Media Color
    // Assign value to file
      AssignFile(mediacolorValue, '/tmp/goverlay/mediacolorValue');
      Rewrite(mediacolorValue);
      Writeln(mediacolorValue,mediacolorhtml);
      CloseFile(mediacolorValue);

      // Create custom script
      AssignFile(mediacolorScript, '/tmp/goverlay/mediacolorScript.sh');
      Rewrite(mediacolorScript);
      Writeln(mediacolorScript,'MEDc=$(cat /tmp/goverlay/mediacolorValue | cut -c 2-10)');  //Store color in Linux/Unix variable and remove # character
      Writeln(mediacolorScript,'echo "media_player_color=$MEDc" >> $HOME/.config/MangoHud/MangoHud.conf'); //Create correct command with crosshair color value
      CloseFile(mediacolorScript);

      //execute custom script to store custom value on mangohud.conf
      RunCommand('bash -c ''sh /tmp/goverlay/mediacolorScript.sh''', s);


   //Time
  if timeCheckbox.Checked=true then
  RunCommand('bash -c ''echo "time" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

  //Hud version
  if hudversionCheckbox.Checked=true then
  RunCommand('bash -c ''echo "version" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

      //###################################################### OTHERS

  //####################################################################################### VISUALS


  //Setup Default HUD Visualization
  if hidehudcheckbox.Checked=true then
  RunCommand('bash -c ''echo "no_display" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

  //Background transparency
   case hudbackgroundForm.transptrackbar.Position of
    0:RunCommand('bash -c ''echo "background_alpha=1" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    1:RunCommand('bash -c ''echo "background_alpha=0.9" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    2:RunCommand('bash -c ''echo "background_alpha=0.8" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    3:RunCommand('bash -c ''echo "background_alpha=0.7" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    4:RunCommand('bash -c ''echo "background_alpha=0.6" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    5:RunCommand('bash -c ''echo "background_alpha=0.5" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    6:RunCommand('bash -c ''echo "background_alpha=0.4" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    7:RunCommand('bash -c ''echo "background_alpha=0.3" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    8:RunCommand('bash -c ''echo "background_alpha=0.2" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    9:RunCommand('bash -c ''echo "background_alpha=0.1" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    10:RunCommand('bash -c ''echo "background_alpha=0" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
  end;

  //Font Size
  case fontsizeCombobox.ItemIndex of
    0:RunCommand('bash -c ''echo "font_size=19" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    1:RunCommand('bash -c ''echo "font_size=24" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    2:RunCommand('bash -c ''echo "font_size=38" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    3:begin
      // Assign custom value to file
      AssignFile(fontsizeCustomValue, '/tmp/goverlay/fontsizeCustom');
      Rewrite(fontsizeCustomValue);
      Writeln(fontsizeCustomValue,fontsizeSpinedit.Value);
      CloseFile(fontsizeCustomValue);

      // Create custom script
      AssignFile(fontsizeCustomScript, '/tmp/goverlay/fontsizeCustomScript.sh');
      Rewrite(fontsizeCustomScript);
      Writeln(fontsizeCustomScript,'FONTSIZEc=$(cat /tmp/goverlay/fontsizeCustom)');  //Store font size in a Linux/Unix variable
      Writeln(fontsizeCustomScript,'echo "font_size=$FONTSIZEc" >> $HOME/.config/MangoHud/MangoHud.conf'); //Create correct command with custom value
      CloseFile(fontsizeCustomScript);

      //execute custom script to store custom value on mangohud.conf
      RunCommand('bash -c ''sh /tmp/goverlay/fontsizeCustomScript.sh''', s);

      end;
  end;


  //HUD BACKGROUND COLOR

      // Assign custom value to file
      AssignFile(hudbackgroundcolorValue, '/tmp/goverlay/hudbackgroundcolorValue');
      Rewrite(hudbackgroundcolorValue);
      Writeln(hudbackgroundcolorValue,hudbackgroundcolorhtml);
      CloseFile(hudbackgroundcolorValue);

      // Create custom script
      AssignFile(hudbackgroundcolorScript, '/tmp/goverlay/hudbackgroundcolorScript.sh');
      Rewrite(hudbackgroundcolorScript);
      Writeln(hudbackgroundcolorScript,'HUDBACKGROUNDc=$(cat /tmp/goverlay/hudbackgroundcolorValue| cut -c 2-10)');  //Store hud color in a Linux/Unix variable
      Writeln(hudbackgroundcolorScript,'echo "background_color=$HUDBACKGROUNDc" >> $HOME/.config/MangoHud/MangoHud.conf'); //Create correct command with custom value
      CloseFile(hudbackgroundcolorScript);

      //execute custom script to store custom value on mangohud.conf
      RunCommand('bash -c ''sh /tmp/goverlay/hudbackgroundcolorScript.sh''', s);


      //HUD Position

  if topleftSpeedbutton.ImageIndex=0 then
  RunCommand('bash -c ''echo "position=top-left" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

  if toprightSpeedbutton.ImageIndex=1 then
  RunCommand('bash -c ''echo "position=top-right" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

  if bottomleftSpeedbutton.ImageIndex=2 then
  RunCommand('bash -c ''echo "position=bottom-left" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

  if bottomrightSpeedbutton.ImageIndex=3 then
  RunCommand('bash -c ''echo "position=bottom-right" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

  if topcenterSpeedbutton.ImageIndex=4 then
  RunCommand('bash -c ''echo "position=top-center" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

    //HUD Font Color

      // Assign value to file
      AssignFile(hudfontcolorValue, '/tmp/goverlay/hudfontcolorValue');
      Rewrite(hudfontcolorValue);
      Writeln(hudfontcolorValue,hudfontcolorhtml);
      CloseFile(hudfontcolorValue);

      // Create custom script
      AssignFile(hudfontcolorScript, '/tmp/goverlay/hudfontcolorScript.sh');
      Rewrite(hudfontcolorScript);
      Writeln(hudfontcolorScript,'HUDFONTc=$(cat /tmp/goverlay/hudfontcolorValue | cut -c 2-10)');  //Store hud font color in Linux/Unix variable and remove # character
      Writeln(hudfontcolorScript,'echo "text_color=$HUDFONTc" >> $HOME/.config/MangoHud/MangoHud.conf'); //Create correct command with color value
      CloseFile(hudfontcolorScript);

      //execute custom script to store custom value on mangohud.conf
      RunCommand('bash -c ''sh /tmp/goverlay/hudfontcolorScript.sh''', s);

  //####################################################################################### KEYBINDINGS


    //HUD ON / OFF  - Toggle key
  case hudonoffCombobox.ItemIndex of
    0:RunCommand('bash -c ''echo "toggle_hud=Shift_R+F12" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    1:RunCommand('bash -c ''echo "toggle_hud=F1" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    2:RunCommand('bash -c ''echo "toggle_hud=F2" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    3:RunCommand('bash -c ''echo "toggle_hud=F3" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    4:RunCommand('bash -c ''echo "toggle_hud=F4" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
  end;

     //LOGGING - Toggle Key
  case loggingCombobox.ItemIndex of
    0:RunCommand('bash -c ''echo "toggle_logging=Shift_L+F2" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    1:RunCommand('bash -c ''echo "toggle_logging=F1" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    2:RunCommand('bash -c ''echo "toggle_logging=F2" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    3:RunCommand('bash -c ''echo "toggle_logging=F3" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    4:RunCommand('bash -c ''echo "toggle_logging=F4" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
  end;


//LOGGING


  //Automatically start logging

  if autologSpinedit.Value > 0 then
  begin
   // Assign custom value to file
      AssignFile(autologValue, '/tmp/goverlay/autolog');
      Rewrite(autologValue);
      Writeln(autologValue,autologSpinedit.Value);
      CloseFile(autologValue);

   // Save only value for later
      AssignFile(autologValue, '/tmp/goverlay/autolog_value');
      Rewrite(autologValue);
      Writeln(autologValue,autologSpinedit.Value);
      CloseFile(autologValue);



      // Create custom script
      AssignFile(autologScript, '/tmp/goverlay/autologScript.sh');
      Rewrite(autologScript);
      Writeln(autologScript,'ALOG=$(cat /tmp/goverlay/autolog)');  //Store autolog value in a Linux/Unix variable
      Writeln(autologScript,'echo "autostart_log=$ALOG" >> $HOME/.config/MangoHud/MangoHud.conf'); //Create correct command with custom value
      CloseFile(autologScript);

      //execute custom script to store custom value on mangohud.conf
      RunCommand('bash -c ''sh /tmp/goverlay/autologScript.sh''', s);
  end;




  //Auto upload log
  if autouploadcheckbox.Checked=true then
  RunCommand('bash -c ''echo "permit_upload" >> $HOME/.config/MangoHud/MangoHud.conf''', s);

  //Set logging destination folder

  // Assign custom value to file
  AssignFile(destinationfolderValue, '/tmp/goverlay/destinationlogfolder');
  Rewrite(destinationfolderValue);
  Writeln(destinationfolderValue,destinationfolder);
  CloseFile(destinationfolderValue);

  // Create custom script
  AssignFile(destinationfolderScript, '/tmp/goverlay/destinationfolderScript.sh');
  Rewrite(destinationfolderScript);
  Writeln(destinationfolderScript,'DESTFOLDER=$(cat /tmp/goverlay/destinationlogfolder)');  //Store destination folder in a Linux/Unix variable
  Writeln(destinationfolderScript,'echo "output_folder=$DESTFOLDER" >> $HOME/.config/MangoHud/MangoHud.conf'); //Create correct command with custom value
  CloseFile(destinationfolderScript);

  //execute custom script to store custom value on mangohud.conf
  RunCommand('bash -c ''sh /tmp/goverlay/destinationfolderScript.sh''', s);


  //update logging label
  destfolderpathLabel.Caption:=destinationfolder;

  //Show logging label
  TittlelogLabel.Visible:=true;
  destfolderpathLabel.Visible:=true;

  // Select media player
  case mediaCombobox.ItemIndex of
    0:RunCommand('bash -c ''echo "media_player_name=spotify" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    1:RunCommand('bash -c ''echo "media_player_name=vlc" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    2:RunCommand('bash -c ''echo "media_player_name=audacious" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
    3:RunCommand('bash -c ''echo "media_player_name=cantata" >> $HOME/.config/MangoHud/MangoHud.conf''', s);
  end;

  //Copy generated Mangohud.conf to goverlay config folder
  RunCommand('bash -c ''yes | cp -rf $HOME/.config/MangoHud/MangoHud.conf $HOME/.config/goverlay/MangoHud.conf ''', s);

  // Delete old initial values and recreate folder
  RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/''', s);
  RunCommand('bash -c ''mkdir -p $HOME/.config/goverlay/initial_values/''', s);
  RunCommand('bash -c ''rm -Rf /tmp/goverlay/initial_values/''', s);
  RunCommand('bash -c ''mkdir -p /tmp/goverlay/initial_values/''', s);


  //Extract configurations from main config File to the initial_values folder for MangoHud

RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w fps_limit >> $HOME/.config/goverlay/initial_values/fps_limit''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w gl_vsync >> $HOME/.config/goverlay/initial_values/gl_vsync''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w vsync >> $HOME/.config/goverlay/initial_values/vsync''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w cpu_stats >> $HOME/.config/goverlay/initial_values/cpu_stats''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w cpu_temp >> $HOME/.config/goverlay/initial_values/cpu_temp''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w core_load >> $HOME/.config/goverlay/initial_values/core_load''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w cpu_color >> $HOME/.config/goverlay/initial_values/cpu_color''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w gpu_stats >> $HOME/.config/goverlay/initial_values/gpu_stats''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w gpu_temp >> $HOME/.config/goverlay/initial_values/gpu_temp''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w gpu_core_clock >> $HOME/.config/goverlay/initial_values/gpu_core_clock''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w gpu_mem_clock >> $HOME/.config/goverlay/initial_values/gpu_mem_clock''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w gpu_power >> $HOME/.config/goverlay/initial_values/gpu_power''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w vulkan_driver >> $HOME/.config/goverlay/initial_values/vulkan_driver''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w gpu_name >> $HOME/.config/goverlay/initial_values/gpu_name''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w gpu_color >> $HOME/.config/goverlay/initial_values/gpu_color''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w swap >> $HOME/.config/goverlay/initial_values/swap''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w vram >> $HOME/.config/goverlay/initial_values/vram''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w vram_color >> $HOME/.config/goverlay/initial_values/vram''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w ram >> $HOME/.config/goverlay/initial_values/ram''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w ram_color >> $HOME/.config/goverlay/initial_values/ram_color''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w io_read >> $HOME/.config/goverlay/initial_values/io_read''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w io_write >> $HOME/.config/goverlay/initial_values/io_write''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w io_color >> $HOME/.config/goverlay/initial_values/io_color''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w frame_timing >> $HOME/.config/goverlay/initial_values/frame_timing''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w histogram >> $HOME/.config/goverlay/initial_values/histogram''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w frametime_color >> $HOME/.config/goverlay/initial_values/frametime_color''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w time >> $HOME/.config/goverlay/initial_values/time''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w version >> $HOME/.config/goverlay/initial_values/version''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w arch >> $HOME/.config/goverlay/initial_values/arch''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w engine_version >> $HOME/.config/goverlay/initial_values/engine_version''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w media_player >> $HOME/.config/goverlay/initial_values/media_player''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w background_alpha >> $HOME/.config/goverlay/initial_values/background_alpha''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w background_color >> $HOME/.config/goverlay/initial_values/background_color''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w position >> $HOME/.config/goverlay/initial_values/position''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w text_color >> $HOME/.config/goverlay/initial_values/text_color''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w toggle_hud >> $HOME/.config/goverlay/initial_values/toggle_hud''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w toggle_logging >> $HOME/.config/goverlay/initial_values/toggle_logging''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w output_folder >> $HOME/.config/goverlay/initial_values/output_folder''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w media_player_name >> $HOME/.config/goverlay/initial_values/media_player_name''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w no_display >> $HOME/.config/goverlay/initial_values/no_display''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w wine >> $HOME/.config/goverlay/initial_values/wine''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w permit_upload >> $HOME/.config/goverlay/initial_values/autoupload''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w cpu_load_change >> $HOME/.config/goverlay/initial_values/cpu_load_change''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w cpu_load_color >> $HOME/.config/goverlay/initial_values/cpu_load_color''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w cpu_load_value >> $HOME/.config/goverlay/initial_values/cpu_load_value''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w gpu_load_change >> $HOME/.config/goverlay/initial_values/gpu_load_change''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w gpu_load_color >> $HOME/.config/goverlay/initial_values/gpu_load_color''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w gpu_load_value >> $HOME/.config/goverlay/initial_values/gpu_load_value''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w cpu_power >> $HOME/.config/goverlay/initial_values/cpu_power''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w cpu_mhz >> $HOME/.config/goverlay/initial_values/cpu_mhz''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w autostart_log >> $HOME/.config/goverlay/initial_values/autolog''', s);
RunCommand('bash -c ''cp /tmp/goverlay/autolog_value $HOME/.config/goverlay/initial_values/''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w fps >> $HOME/.config/goverlay/initial_values/fps''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w show_fps_limit >> $HOME/.config/goverlay/initial_values/show_fps_limit''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w toggle_fps_limit >> $HOME/.config/goverlay/initial_values/toggle_fps_limit''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w resolution >> $HOME/.config/goverlay/initial_values/resolution''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w battery >> $HOME/.config/goverlay/initial_values/battery''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w vkbasalt >> $HOME/.config/goverlay/initial_values/vkbasalt''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w gamemode >> $HOME/.config/goverlay/initial_values/gamemode''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w custom_text=Session: >> $HOME/.config/goverlay/initial_values/session''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w exec=df  >> $HOME/.config/goverlay/initial_values/homepart''', s);

//distro info
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w Description  >> $HOME/.config/goverlay/initial_values/distroinfo''', s);


//GRAPHs configs
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w graphs=gpu_load >> $HOME/.config/goverlay/initial_values/graphs_gpu_load''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w graphs=gpu_temp >> $HOME/.config/goverlay/initial_values/graphs_gpu_temp''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w graphs=gpu_core_clock >> $HOME/.config/goverlay/initial_values/graphs_gpu_core_clock''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w graphs=gpu_mem_clock >> $HOME/.config/goverlay/initial_values/graphs_gpu_mem_clock''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w graphs=cpu_load >> $HOME/.config/goverlay/initial_values/graphs_cpu_load''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w graphs=cpu_temp >> $HOME/.config/goverlay/initial_values/graphs_cpu_temp''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w graphs=vram >> $HOME/.config/goverlay/initial_values/graphs_vram''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w graphs=ram >> $HOME/.config/goverlay/initial_values/graphs_ram''', s);

//TEXT configs
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w cpu_text >> $HOME/.config/goverlay/initial_values/cpu_text''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w cpu_text | cut -c 10-20 >> $HOME/.config/goverlay/initial_values/cpu_text_value''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w gpu_text >> $HOME/.config/goverlay/initial_values/gpu_text''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w gpu_text | cut -c 10-20 >> $HOME/.config/goverlay/initial_values/gpu_text_value''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w font_size >> $HOME/.config/goverlay/initial_values/font_size''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w font_size | cut -c 11-13 >> $HOME/.config/goverlay/initial_values/font_size_value''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w custom_text_center >> $HOME/.config/goverlay/initial_values/hudtitle_text''', s);
RunCommand('bash -c ''cat $HOME/.config/MangoHud/MangoHud.conf | grep -w custom_text_center | cut -c 20-40 >> $HOME/.config/goverlay/initial_values/hudtitle_value''', s);

end;

procedure Tgoverlayform.fontsizeComboBoxChange(Sender: TObject);
begin
  if fontsizeCombobox.ItemIndex=3 then
   fontsizeSpinEdit.Enabled:=true
  else
   fontsizeSpinEdit.Enabled:=false;
end;

procedure Tgoverlayform.fontsizeComboBoxKeyPress(Sender: TObject; var Key: char
  );
begin
  //Block keypress on combobox
  key:=#0;
end;

procedure Tgoverlayform.fpslimComboBoxChange(Sender: TObject);
begin
  //Enable spinedit only when custom option is selected
  if fpslimCombobox.ItemIndex=8 then
  fpscustomSpinEdit.Enabled:=true
  else
    fpscustomSpinEdit.Enabled:=false;
end;

procedure Tgoverlayform.fpslimComboBoxKeyPress(Sender: TObject; var Key: char);
begin
  //Block keypress on combobox
  key:=#0;
end;

procedure Tgoverlayform.frametimegraphCheckBoxClick(Sender: TObject);
begin

     if frametimegraphCheckbox.Checked=true then
        begin
        framegraphRadioButton.Enabled := true;   // enable graph radiobutton
        framehistogramRadioButton.Enabled := true;   // enable histogram radiobutton
        framegraphRadioButton.checked := True;   // check graph option by default

        //Preview changes
        frametimelabel.Caption:='Frametime';
        frametimelabel2.Caption:='16.6ms';
        frametimegraphlabel.Caption:='------------------------------------';
        end

        else

        begin
        framegraphRadioButton.Enabled := false;   // enable graph radiobutton
        framehistogramRadioButton.Enabled := false;   // enable histogram radiobutton
        framegraphRadioButton.checked := false;   // check graph option by default

        //Preview changes
        frametimelabel.Caption:='';
        frametimelabel2.Caption:='';
        frametimegraphlabel.Caption:='';
        end
     end;


procedure Tgoverlayform.glvsyncComboBoxKeyPress(Sender: TObject; var Key: char);
begin
   //Block keypress on combobox
  key:=#0;
end;

procedure Tgoverlayform.gpuavrloadCheckBoxClick(Sender: TObject);
begin
  //Preview GPU Average Load
  if gpuavrloadCheckbox.Checked=true then
  begin
  gpulabel.Caption:='GPU';
  gpuusagelabel.Caption:='95%'
  end
  else
  begin
  gpulabel.Caption:='';
  gpuusagelabel.Caption:='';
  end;
end;

procedure Tgoverlayform.gpuColorButtonColorChanged(Sender: TObject);
begin
     // Change GPU color labels
    gpulabel.font.Color:=gpucolorButton.ButtonColor;

    //Use function SColorToHtmlColor from unit ATStringProc_htmlColor to change color format to RGB and write value to label
    gpucolorhtml := SColorToHtmlColor(gpucolorButton.ButtonColor);
end;

procedure Tgoverlayform.gpufreqCheckBoxClick(Sender: TObject);
begin
  //Preview GPU Clock
  if gpufreqCheckbox.Checked=true then
  begin
  gpulabel.Caption:='GPU';
  gpuclocklabel.Caption:='1733MHz';
  end
  else
  begin
  gpuclocklabel.Caption:='';
  end;
end;

procedure Tgoverlayform.gputempCheckBoxClick(Sender: TObject);
begin
  //PREVIEW GPU TEMPERATURE
  if gputempCheckbox.Checked=true then
  begin
  gpulabel.Caption:='GPU';
  gputemplabel.Caption:='82ºC';
  end
  else
  begin
  gputemplabel.Caption:='';
  end;
end;

procedure Tgoverlayform.hudonoffComboBoxKeyPress(Sender: TObject; var Key: char
  );
begin
    //Block keypress on combobox
  key:=#0;
end;

procedure Tgoverlayform.loggingComboBoxKeyPress(Sender: TObject; var Key: char);
begin
  //Block keypress on combobox
  key:=#0;
end;

procedure Tgoverlayform.logpathBitBtnClick(Sender: TObject);
begin
  logpathForm.show;
end;

procedure Tgoverlayform.lutrisMenuItemClick(Sender: TObject);
begin
  RunCommand('bash -c ''mangohud lutris''', s);  // run lutris
end;

procedure Tgoverlayform.mangohudLabelClick(Sender: TObject);
begin
  //On Select mangohud shape - Change variables
  mangohudsel := true;
  vkbasaltsel := false;
  replaysel := false;

  //On Select mangohud shape - Change colors and unselect vkbasalt and replaysourcery
  mangohudShape.Brush.Color:=$00383838;
  mangohudShape.Visible:=true;
  mangohudLabel.Font.color:=clwhite;
  vkbasaltlabel.Font.color:=clgray;
  vkbasaltshape.Visible:=false;
  replaylabel.Font.color:=clgray;
  replayshape.Visible:=false;

  //Display mangohud panel
  mangohudPanel.Visible:=true;
  vkbasaltPanel.Visible:=false;
  replayPanel.Visible:=false;
end;

procedure Tgoverlayform.mangohudLabelMouseEnter(Sender: TObject);
begin
   //highlight mangohud shape on mouse enter if vkbasalt is selected
  if vkbasaltsel = true  then
    begin
     mangohudShape.Brush.Color:=$00232323;
     mangohudShape.Visible:=true;
    end;

  //highlight mangohud shape on mouse enter if replay is selected
  if replaysel = true  then
    begin
     mangohudShape.Brush.Color:=$00232323;
     mangohudShape.Visible:=true;
    end;

end;

procedure Tgoverlayform.mangohudLabelMouseLeave(Sender: TObject);
begin
   //hide mangohud shape on mouse leave if vkbasalt is selected
  if vkbasaltsel = true  then
  mangohudShape.Visible:=false;

  if replaysel = true  then
  mangohudShape.Visible:=false;

end;

procedure Tgoverlayform.mangohudPanelClick(Sender: TObject);
begin

end;

procedure Tgoverlayform.mediaColorButtonColorChanged(Sender: TObject);
begin
    // Media color
    spotify1label.font.Color:=mediacolorButton.ButtonColor;
    spotify2label.font.Color:=mediacolorButton.ButtonColor;
    spotify3label.font.Color:=mediacolorButton.ButtonColor;

    //Use function SColorToHtmlColor from unit ATStringProc_htmlColor to change color format to RGB and write value to label
    mediacolorhtml := SColorToHtmlColor(mediacolorButton.ButtonColor);
end;

procedure Tgoverlayform.mediaComboBoxKeyPress(Sender: TObject; var Key: char);
begin
  //Block keypress on combobox
  key:=#0;
end;

procedure Tgoverlayform.MenuItem1Click(Sender: TObject);
begin
   RunCommand('bash -c ''ENABLE_VKBASALT=1 steam''', s)     //Run steam
end;

procedure Tgoverlayform.MenuItem2Click(Sender: TObject);
begin
   RunCommand('bash -c ''ENABLE_VKBASALT=1 lutris''', s)    //Run lutris
end;

procedure Tgoverlayform.MenuItem3Click(Sender: TObject);
begin
    RunCommand('bash -c ''ENABLE_VKBASALT=1 heroic''', s)  //Run heroic
end;



procedure Tgoverlayform.ramColorButtonColorChanged(Sender: TObject);
begin
    // Change RAM label color
    ramlabel.font.Color:=ramcolorButton.ButtonColor;

    //Use function SColorToHtmlColor from unit ATStringProc_htmlColor to change color format to RGB and write value to label
    ramcolorhtml := SColorToHtmlColor(ramcolorButton.ButtonColor);
end;

procedure Tgoverlayform.ramgraphBitBtnClick(Sender: TObject);
begin
     case ramgraphBitbtn.ImageIndex of
     2:ramgraphBitbtn.ImageIndex:= 3;
     3:ramgraphBitbtn.ImageIndex:= 2;
     end;
end;

procedure Tgoverlayform.ramusageCheckBoxClick(Sender: TObject);
begin
  //Preview RAM usage
  if ramusageCheckbox.Checked=true then
    begin
     ramlabel.Caption:='RAM';
     ramusagelabel.Caption:='5.99GB'
     end
   else
     begin
     ramlabel.Caption:='';
     ramusagelabel.Caption:=''
  end;
end;

procedure Tgoverlayform.replaygeSpeedButtonClick(Sender: TObject);
begin
  case replaygeSpeedButton.imageIndex of
    0: begin
      replaygeSpeedButton.ImageIndex:=1; //switch button position
      RunCommand('bash -c ''rm $HOME/.config/autostart/replay.desktop''', s); //delete old file
      RunCommand('bash -c ''echo "[Desktop Entry]" >> $HOME/.config/autostart/replay.desktop''', s);  // create autostart file
      RunCommand('bash -c ''echo "Type=Application" >> $HOME/.config/autostart/replay.desktop''', s);  // create autostart file
      RunCommand('bash -c ''echo "Encoding=UTF-8" >> $HOME/.config/autostart/replay.desktop''', s);  // create autostart file
      RunCommand('bash -c ''echo "Name=replay-sourcery" >> $HOME/.config/autostart/replay.desktop''', s);  // create autostart file
      RunCommand('bash -c ''echo "Comment=replay-sourcery" >> $HOME/.config/autostart/replay.desktop''', s);  // create autostart file
      RunCommand('bash -c ''echo "Terminal=false" >> $HOME/.config/autostart/replay.desktop''', s);  // create autostart file
      RunCommand('bash -c ''echo "Categories=Graphics;Game;" >> $HOME/.config/autostart/replay.desktop''', s);  // create autostart file
      RunCommand('bash -c ''echo "Exec=systemctl --user enable --now replay-sorcery" >> $HOME/.config/autostart/replay.desktop''', s);  // create autostart file
      RunCommand('bash -c ''echo "X-GNOME-Autostart-enabled=true" >> $HOME/.config/autostart/replay.desktop''', s);  // create autostart file
      RunCommand('bash -c ''echo "Keywords=replay;goverlay;" >> $HOME/.config/autostart/replay.desktop''', s);  // create autostart file
      RunCommand('bash -c ''chmod +x $HOME/.config/autostart/replay.desktop''', s);  // turn file executable
      RunCommand('bash -c ''notify-send -i /usr/share/icons/hicolor/128x128/apps/goverlay.png "ReplaySorcery Global Enable Activated" "The desktop will be continually recorded in the background"''', s); // Popup a notification
      showmessage ('Restart your system to take effect');
    end;
    1: begin
      replaygeSpeedButton.ImageIndex:=0;  //switch button position
      RunCommand('bash -c ''rm $HOME/.config/autostart/replay.desktop''', s); //delete old file
      RunCommand('bash -c ''notify-send -i /usr/share/icons/hicolor/128x128/apps/goverlay.png "Deactivated"''', s); // Popup a notification
      showmessage ('Restart your system to take effect');
     end;
  end;
end;

procedure Tgoverlayform.replaykeyComboboxKeyPress(Sender: TObject; var Key: char
  );
begin
    //Block keypress on combobox
  key:=#0;
end;

procedure Tgoverlayform.replayLabelClick(Sender: TObject);
begin
    //On Select replay shape - Change variables
  mangohudsel := false;
  vkbasaltsel := false;
  replaysel := true;

  //On Select replaysorce shape - Change colors and unselect Mangohud and replaysoruce
  replayShape.Brush.Color:=$00383838;
  replayShape.Visible:=true;
  replayLabel.Font.color:=clwhite;
  mangohudlabel.Font.color:=clgray;
  mangohudshape.Visible:=false;
  vkbasaltlabel.Font.color:=clgray;
  vkbasaltshape.Visible:=false;

  //Display replay-sourcery panel
  Mangohudpanel.Visible:=false;
  vkbasaltPanel.Visible:=false;
  replaypanel.Visible:=true;
end;

procedure Tgoverlayform.replayLabelMouseEnter(Sender: TObject);
begin
  //highlight replay shape on mouse enter if mangohud is selected
 if mangohudsel = true  then
   begin
    replayShape.Brush.Color:=$00232323;
    replayShape.Visible:=true;
   end;

 //highlight replay shape on mouse enter if vkbasalt is selected
 if vkbasaltsel = true  then
   begin
   replayShape.Brush.Color:=$00232323;
   replayShape.Visible:=true;
   end;
end;

procedure Tgoverlayform.replayLabelMouseLeave(Sender: TObject);
begin
 //hide replay shape on mouse leave if mangohud is selected
if mangohudsel = true  then
replayShape.Visible:=false;

if vkbasaltsel = true  then
replayShape.Visible:=false;
end;

procedure Tgoverlayform.replaysaveBitBtnClick(Sender: TObject);
begin
    // Delete old config file if it exists
  RunCommand('bash -c ''rm $HOME/.config/replay-sorcery.conf''', s);

  // Create a new file for GOverlay
  RunCommand('bash -c ''echo "################### File Generated by GOverlay ###################" >> $HOME/.config/replay-sorcery.conf''', s);

  // Popup a notification
  RunCommand('bash -c ''notify-send -i /usr/share/icons/hicolor/128x128/apps/goverlay.png "ReplaySorcery" "Configuration saved"''', s);



  //####################################################################################### Video Settings


  //Record the whole display - AUTO

    if autoresCheckbox.Checked = true then
    begin
       RunCommand('bash -c ''echo "videoWidth = auto" >> $HOME/.config/replay-sorcery.conf''', s);
       RunCommand('bash -c ''echo "videoHeight = auto" >> $HOME/.config/replay-sorcery.conf''', s);
       RunCommand('bash -c ''rm /tmp/goverlay/initial_values/replay_FULLSCREEN''', s); // delete old variable to manage initial value
       RunCommand('bash -c ''echo "TRUE" >> /tmp/goverlay/initial_values/replay_FULLSCREEN''', s); // variable to manage initial value
    end;


      //Auto Scale

    if autoscaleCheckbox.Checked = true then
    begin
       RunCommand('bash -c ''echo "scaleWidth = auto" >> $HOME/.config/replay-sorcery.conf''', s);
       RunCommand('bash -c ''echo "scaleHeight = auto" >> $HOME/.config/replay-sorcery.conf''', s);
       RunCommand('bash -c ''rm /tmp/goverlay/initial_values/replay_AUTOSCALE''', s); // delete old variable to manage initial value
       RunCommand('bash -c ''echo "TRUE" >> /tmp/goverlay/initial_values/replay_AUTOSCALE''', s); // variable to manage initial value
    end;



  //Record custom area

   if autoresCheckbox.Checked = false then
    begin

    RunCommand('bash -c ''rm /tmp/goverlay/initial_values/replay_FULLSCREEN''', s); // delete old variable to manage initial value
    RunCommand('bash -c ''echo "FALSE" >> /tmp/goverlay/initial_values/replay_FULLSCREEN''', s); // variable to manage initial value

    //Custom retangle - Width

       // Assign custom value to file
      AssignFile(reswidthCustomValue, '/tmp/goverlay/reswidthCustomValue');
      Rewrite(reswidthCustomValue);
      Writeln(reswidthCustomValue,reswidthSpinedit.Value);
      CloseFile(reswidthCustomValue);

      // Create custom script
      AssignFile(reswidthCustomValueScript, '/tmp/goverlay/reswidthCustomValueScript.sh');
      Rewrite(reswidthCustomValueScript);
      Writeln(reswidthCustomValueScript,'RWSc=$(cat /tmp/goverlay/reswidthCustomValue)');  //Store custom value in a Linux/Unix variable
      Writeln(reswidthCustomValueScript,'echo "videoWidth=$RWSc" >> $HOME/.config/replay-sorcery.conf'); //Create correct command with custom value
      CloseFile(reswidthCustomValueScript);

      //execute custom script to store custom value on replay-sorcery.conf
      RunCommand('bash -c ''sh /tmp/goverlay/reswidthCustomValueScript.sh''', s);




      //Custom retangle - Height

      // Assign custom value to file
      AssignFile(resheightCustomValue, '/tmp/goverlay/resheightCustomValue');
      Rewrite(resheightCustomValue);
      Writeln(resheightCustomValue,resheightSpinedit.Value);
      CloseFile(resheightCustomValue);

      // Create custom script
      AssignFile(resheightCustomValueScript, '/tmp/goverlay/resheightCustomValueScript.sh');
      Rewrite(resheightCustomValueScript);
      Writeln(resheightCustomValueScript,'RHSc=$(cat /tmp/goverlay/resheightCustomValue)');  //Store custom value in a Linux/Unix variable
      Writeln(resheightCustomValueScript,'echo "videoHeight=$RHSc" >> $HOME/.config/replay-sorcery.conf'); //Create correct command with custom value
      CloseFile(resheightCustomValueScript);

      //execute custom script to store custom value on replay-sorcery.conf
      RunCommand('bash -c ''sh /tmp/goverlay/resheightCustomValueScript.sh''', s);

    end;


   // Auto Scale

    if autoscaleCheckbox.Checked = true then
    begin
       RunCommand('bash -c ''echo "scaleWidth = auto" >> $HOME/.config/replay-sorcery.conf''', s);
       RunCommand('bash -c ''echo "scaleHeight = auto" >> $HOME/.config/replay-sorcery.conf''', s);
       RunCommand('bash -c ''rm /tmp/goverlay/initial_values/replay_AUTOSCALE''', s); // delete old variable to manage initial value
       RunCommand('bash -c ''echo "TRUE" >> /tmp/goverlay/initial_values/replay_AUTOSCALE''', s); // variable to manage initial value
    end;


   //Custom Scale



   if autoscaleCheckbox.Checked = false then
    begin

    RunCommand('bash -c ''rm /tmp/goverlay/initial_values/replay_AUTOSCALE''', s); // delete old variable to manage initial value
    RunCommand('bash -c ''echo "FALSE" >> /tmp/goverlay/initial_values/replay_AUTOSCALE''', s); // variable to manage initial value



    //Custom scale - Width

       // Assign custom value to file
      AssignFile(scalewidthCustomValue, '/tmp/goverlay/scalewidthCustomValue');
      Rewrite(scalewidthCustomValue);
      Writeln(scalewidthCustomValue,scalewidthSpinedit.Value);
      CloseFile(scalewidthCustomValue);

      // Create custom script
      AssignFile(scalewidthCustomValueScript, '/tmp/goverlay/scalewidthCustomValueScript.sh');
      Rewrite(scalewidthCustomValueScript);
      Writeln(scalewidthCustomValueScript,'SWSc=$(cat /tmp/goverlay/scalewidthCustomValue)');  //Store custom value in a Linux/Unix variable
      Writeln(scalewidthCustomValueScript,'echo "scaleWidth=$SWSc" >> $HOME/.config/replay-sorcery.conf'); //Create correct command with custom value
      CloseFile(scalewidthCustomValueScript);

      //execute custom script to store custom value on replay-sorcery.conf
      RunCommand('bash -c ''sh /tmp/goverlay/scalewidthCustomValueScript.sh''', s);




      //Custom scale - Height

      // Assign custom value to file
      AssignFile(scaleheightCustomValue, '/tmp/goverlay/scaleheightCustomValue');
      Rewrite(scaleheightCustomValue);
      Writeln(scaleheightCustomValue,scaleheightSpinedit.Value);
      CloseFile(scaleheightCustomValue);

      // Create custom script
      AssignFile(scaleheightCustomValueScript, '/tmp/goverlay/scaleheightCustomValueScript.sh');
      Rewrite(scaleheightCustomValueScript);
      Writeln(scaleheightCustomValueScript,'SHSc=$(cat /tmp/goverlay/scaleheightCustomValue)');  //Store custom value in a Linux/Unix variable
      Writeln(scaleheightCustomValueScript,'echo "scaleHeight=$SHSc" >> $HOME/.config/replay-sorcery.conf'); //Create correct command with custom value
      CloseFile(scaleheightCustomValueScript);

      //execute custom script to store custom value on replay-sorcery.conf
      RunCommand('bash -c ''sh /tmp/goverlay/scaleheightCustomValueScript.sh''', s);

    end;



    //REPLAY video input
  case videoinputCombobox.ItemIndex of
        0:RunCommand('bash -c ''echo "videoInput = auto" >> $HOME/.config/replay-sorcery.conf''', s);
        1:RunCommand('bash -c ''echo "videoInput = hwaccel" >> $HOME/.config/replay-sorcery.conf''', s);
	2:RunCommand('bash -c ''echo "videoInput = x11" >> $HOME/.config/replay-sorcery.conf''', s);
	3:RunCommand('bash -c ''echo "videoInput = kms" >> $HOME/.config/replay-sorcery.conf''', s);
  end;

  //REPLAY video device
  case videodeviceCombobox.ItemIndex of
        0:RunCommand('bash -c ''echo "videoDevice = auto" >> $HOME/.config/replay-sorcery.conf''', s);
        1:RunCommand('bash -c ''echo "videoDevice = auto" >> $HOME/.config/replay-sorcery.conf''', s);  // LATER

  end;


   //REPLAY FPS
  case framerateCombobox.ItemIndex of
        0:RunCommand('bash -c ''echo "videoFramerate = 15" >> $HOME/.config/replay-sorcery.conf''', s);
        1:RunCommand('bash -c ''echo "videoFramerate = 30" >> $HOME/.config/replay-sorcery.conf''', s);
	2:RunCommand('bash -c ''echo "videoFramerate = 60" >> $HOME/.config/replay-sorcery.conf''', s);
	3:RunCommand('bash -c ''echo "videoFramerate = 90" >> $HOME/.config/replay-sorcery.conf''', s);
	4:RunCommand('bash -c ''echo "videoFramerate = 120" >> $HOME/.config/replay-sorcery.conf''', s);
	5:RunCommand('bash -c ''echo "videoFramerate = 144" >> $HOME/.config/replay-sorcery.conf''', s);
	6:RunCommand('bash -c ''echo "videoFramerate = 240" >> $HOME/.config/replay-sorcery.conf''', s);
  end;


    //REPLAY record duration
  case clipdurationCombobox.ItemIndex of
        0:RunCommand('bash -c ''echo "recordSeconds = 10" >> $HOME/.config/replay-sorcery.conf''', s);
	1:RunCommand('bash -c ''echo "recordSeconds = 15" >> $HOME/.config/replay-sorcery.conf''', s);
	2:RunCommand('bash -c ''echo "recordSeconds = 30" >> $HOME/.config/replay-sorcery.conf''', s);
	3:RunCommand('bash -c ''echo "recordSeconds = 60" >> $HOME/.config/replay-sorcery.conf''', s);
	4:RunCommand('bash -c ''echo "recordSeconds = 120" >> $HOME/.config/replay-sorcery.conf''', s);
  end;


   //REPLAY Video Encoder
  case videoencoderCombobox.ItemIndex of
    0:RunCommand('bash -c ''echo "videoEncoder = auto" >> $HOME/.config/replay-sorcery.conf''', s);
    1:RunCommand('bash -c ''echo "videoEncoder = x264" >> $HOME/.config/replay-sorcery.conf''', s);
    2:RunCommand('bash -c ''echo "videoEncoder = openh264" >> $HOME/.config/replay-sorcery.conf''', s);
    3:RunCommand('bash -c ''echo "videoEncoder = x265" >> $HOME/.config/replay-sorcery.conf''', s);
    4:RunCommand('bash -c ''echo "videoEncoder = hevc" >> $HOME/.config/replay-sorcery.conf''', s);
    5:RunCommand('bash -c ''echo "videoEncoder = vaapi_h264" >> $HOME/.config/replay-sorcery.conf''', s);
    6:RunCommand('bash -c ''echo "videoEncoder = vaapi_hevc" >> $HOME/.config/replay-sorcery.conf''', s);
  end;

  //REPLAY H264 Profile
  case h264profileCombobox.ItemIndex of
    0:RunCommand('bash -c ''echo "videoProfile = baseline" >> $HOME/.config/replay-sorcery.conf''', s);
    1:RunCommand('bash -c ''echo "videoProfile = main" >> $HOME/.config/replay-sorcery.conf''', s);
    2:RunCommand('bash -c ''echo "videoProfile = high" >> $HOME/.config/replay-sorcery.conf''', s);
  end;


    //REPLAY HLE Preset
  case videohlepresetCombobox.ItemIndex of
    0:RunCommand('bash -c ''echo "videoPreset = fast" >> $HOME/.config/replay-sorcery.conf''', s);
    1:RunCommand('bash -c ''echo "videoPreset = medium" >> $HOME/.config/replay-sorcery.conf''', s);
    2:RunCommand('bash -c ''echo "videoPreset = slow" >> $HOME/.config/replay-sorcery.conf''', s);
  end;


    //REPLAY Video quality
    if autovideoqualityCheckbox.Checked = true then
       begin
       RunCommand('bash -c ''echo "videoQuality = auto" >> $HOME/.config/replay-sorcery.conf''', s);
       RunCommand('bash -c ''rm /tmp/goverlay/initial_values/replay_VIDEO_AUTO_QUALITY''', s); // delete old variable to manage initial value
       RunCommand('bash -c ''echo "TRUE" >> /tmp/goverlay/initial_values/replay_VIDEO_AUTO_QUALITY''', s); // variable to manage initial value
       end;


    if autovideoqualityCheckbox.Checked = false then

       case videoqualityTrackBar.Position of
       1:RunCommand('bash -c ''echo "videoQuality = 50" >> $HOME/.config/replay-sorcery.conf''', s);
       2:RunCommand('bash -c ''echo "videoQuality = 45" >> $HOME/.config/replay-sorcery.conf''', s);
       3:RunCommand('bash -c ''echo "videoQuality = 40" >> $HOME/.config/replay-sorcery.conf''', s);
       4:RunCommand('bash -c ''echo "videoQuality = 35" >> $HOME/.config/replay-sorcery.conf''', s);
       5:RunCommand('bash -c ''echo "videoQuality = 30" >> $HOME/.config/replay-sorcery.conf''', s);
       6:RunCommand('bash -c ''echo "videoQuality = 25" >> $HOME/.config/replay-sorcery.conf''', s);
       7:RunCommand('bash -c ''echo "videoQuality = 20" >> $HOME/.config/replay-sorcery.conf''', s);
       8:RunCommand('bash -c ''echo "videoQuality = 15" >> $HOME/.config/replay-sorcery.conf''', s);
       9:RunCommand('bash -c ''echo "videoQuality = 10" >> $HOME/.config/replay-sorcery.conf''', s);
       10:RunCommand('bash -c ''echo "videoQuality = 5" >> $HOME/.config/replay-sorcery.conf''', s);
  end;


      //REPLAY Video bitrate
    if autovideobitrateCheckbox.Checked = true then
       begin
       RunCommand('bash -c ''echo "videoBitrate = auto" >> $HOME/.config/replay-sorcery.conf''', s);
       RunCommand('bash -c ''rm /tmp/goverlay/initial_values/replay_VIDEO_AUTO_BITRATE''', s); // delete old variable to manage initial value
       RunCommand('bash -c ''echo "TRUE" >> /tmp/goverlay/initial_values/replay_VIDEO_AUTO_BITRATE''', s); // variable to manage initial value
       end;


    if autovideobitrateCheckbox.Checked = false then

       case videobitrateTrackBar.Position of
       1:RunCommand('bash -c ''echo "videoBitrate = 1M" >> $HOME/.config/replay-sorcery.conf''', s);
       2:RunCommand('bash -c ''echo "videoBitrate = 2M" >> $HOME/.config/replay-sorcery.conf''', s);
       3:RunCommand('bash -c ''echo "videoBitrate = 3M" >> $HOME/.config/replay-sorcery.conf''', s);
       4:RunCommand('bash -c ''echo "videoBitrate = 4M" >> $HOME/.config/replay-sorcery.conf''', s);
       5:RunCommand('bash -c ''echo "videoBitrate = 5M" >> $HOME/.config/replay-sorcery.conf''', s);
       6:RunCommand('bash -c ''echo "videoBitrate = 6M" >> $HOME/.config/replay-sorcery.conf''', s);
       7:RunCommand('bash -c ''echo "videoBitrate = 7M" >> $HOME/.config/replay-sorcery.conf''', s);
       8:RunCommand('bash -c ''echo "videoBitrate = 8M" >> $HOME/.config/replay-sorcery.conf''', s);
       9:RunCommand('bash -c ''echo "videoBitrate = 9M" >> $HOME/.config/replay-sorcery.conf''', s);
       10:RunCommand('bash -c ''echo "videoBitratey = 10M" >> $HOME/.config/replay-sorcery.conf''', s);
  end;


      //REPLAY Video GOPs


      case videogopTrackBar.Position of
      20:RunCommand('bash -c ''echo "videoGOP = 20" >> $HOME/.config/replay-sorcery.conf''', s);
      21:RunCommand('bash -c ''echo "videoGOP = 21" >> $HOME/.config/replay-sorcery.conf''', s);
      22:RunCommand('bash -c ''echo "videoGOP = 22" >> $HOME/.config/replay-sorcery.conf''', s);
      23:RunCommand('bash -c ''echo "videoGOP = 23" >> $HOME/.config/replay-sorcery.conf''', s);
      24:RunCommand('bash -c ''echo "videoGOP = 24" >> $HOME/.config/replay-sorcery.conf''', s);
      25:RunCommand('bash -c ''echo "videoGOP = 25" >> $HOME/.config/replay-sorcery.conf''', s);
      26:RunCommand('bash -c ''echo "videoGOP = 26" >> $HOME/.config/replay-sorcery.conf''', s);
      27:RunCommand('bash -c ''echo "videoGOP = 27" >> $HOME/.config/replay-sorcery.conf''', s);
      28:RunCommand('bash -c ''echo "videoGOP = 28" >> $HOME/.config/replay-sorcery.conf''', s);
      29:RunCommand('bash -c ''echo "videoGOP = 29" >> $HOME/.config/replay-sorcery.conf''', s);
      30:RunCommand('bash -c ''echo "videoGOP = 30" >> $HOME/.config/replay-sorcery.conf''', s);
      31:RunCommand('bash -c ''echo "videoGOP = 31" >> $HOME/.config/replay-sorcery.conf''', s);
      32:RunCommand('bash -c ''echo "videoGOP = 32" >> $HOME/.config/replay-sorcery.conf''', s);
      33:RunCommand('bash -c ''echo "videoGOP = 33" >> $HOME/.config/replay-sorcery.conf''', s);
      34:RunCommand('bash -c ''echo "videoGOP = 34" >> $HOME/.config/replay-sorcery.conf''', s);
      35:RunCommand('bash -c ''echo "videoGOP = 35" >> $HOME/.config/replay-sorcery.conf''', s);
      36:RunCommand('bash -c ''echo "videoGOP = 36" >> $HOME/.config/replay-sorcery.conf''', s);
      37:RunCommand('bash -c ''echo "videoGOP = 37" >> $HOME/.config/replay-sorcery.conf''', s);
      38:RunCommand('bash -c ''echo "videoGOP = 38" >> $HOME/.config/replay-sorcery.conf''', s);
      39:RunCommand('bash -c ''echo "videoGOP = 39" >> $HOME/.config/replay-sorcery.conf''', s);
      40:RunCommand('bash -c ''echo "videoGOP = 40" >> $HOME/.config/replay-sorcery.conf''', s);
  end;

    //####################################################################################### Audio Settings

  //REPLAY audio input
  case audioinputCombobox.ItemIndex of
    0:RunCommand('bash -c ''echo "audioInput = auto" >> $HOME/.config/replay-sorcery.conf''', s);
    1:RunCommand('bash -c ''echo "audioInput = pulse" >> $HOME/.config/replay-sorcery.conf''', s);
    2:RunCommand('bash -c ''echo "audioInput = none" >> $HOME/.config/replay-sorcery.conf''', s);
  end;

    //REPLAY audio device
  case audiodevCombobox.ItemIndex of
    0:RunCommand('bash -c ''echo "audioDevice = auto" >> $HOME/.config/replay-sorcery.conf''', s);
    1:RunCommand('bash -c ''echo "audioDevice = system" >> $HOME/.config/replay-sorcery.conf''', s);
    2:RunCommand('bash -c ''echo "audioDevice = custom" >> $HOME/.config/replay-sorcery.conf''', s);
  end;

     //REPLAY audio encoder
  case audioencoderCombobox.ItemIndex of
    0:RunCommand('bash -c ''echo "audioEncoder = auto" >> $HOME/.config/replay-sorcery.conf''', s);
    1:RunCommand('bash -c ''echo "audioEncoder = aac" >> $HOME/.config/replay-sorcery.conf''', s);
    2:RunCommand('bash -c ''echo "audioEncoder = fdk" >> $HOME/.config/replay-sorcery.conf''', s);
  end;

       //REPLAY aac profile
  case aacprofileCombobox.ItemIndex of
    0:RunCommand('bash -c ''echo "audioProfile = low" >> $HOME/.config/replay-sorcery.conf''', s);
    1:RunCommand('bash -c ''echo "audioProfile = main" >> $HOME/.config/replay-sorcery.conf''', s);
    2:RunCommand('bash -c ''echo "audioProfile = high" >> $HOME/.config/replay-sorcery.conf''', s);
  end;

   //REPLAY audio sample rate
  case audiosampCombobox.ItemIndex of
    0:RunCommand('bash -c ''echo "audioSamplerate = 11025" >> $HOME/.config/replay-sorcery.conf''', s);
    1:RunCommand('bash -c ''echo "audioSamplerate = 22050" >> $HOME/.config/replay-sorcery.conf''', s);
    2:RunCommand('bash -c ''echo "audioSamplerate = 44100" >> $HOME/.config/replay-sorcery.conf''', s);
    3:RunCommand('bash -c ''echo "audioSamplerate = 48000" >> $HOME/.config/replay-sorcery.conf''', s);
  end;

     //REPLAY audio bit rate
    if autoaudiobitrateCheckbox.Checked = true then
       begin
       RunCommand('bash -c ''echo "audioBitrate = auto" >> $HOME/.config/replay-sorcery.conf''', s);
       RunCommand('bash -c ''rm /tmp/goverlay/initial_values/replay_AUDIO_AUTO_BITRATE''', s); // delete old variable to manage initial value
       RunCommand('bash -c ''echo "TRUE" >> /tmp/goverlay/initial_values/replay_AUDIO_AUTO_BITRATE''', s); // variable to manage initial value
       end;


       if autoaudiobitrateCheckbox.Checked = false then

          case audiobitrateCombobox.ItemIndex of
          1:RunCommand('bash -c ''echo "audioBitrate = 32K" >> $HOME/.config/replay-sorcery.conf''', s);
          2:RunCommand('bash -c ''echo "audioBitrate = 64K" >> $HOME/.config/replay-sorcery.conf''', s);
          3:RunCommand('bash -c ''echo "audioBitrate = 96K" >> $HOME/.config/replay-sorcery.conf''', s);
          4:RunCommand('bash -c ''echo "audioBitrate = 128K" >> $HOME/.config/replay-sorcery.conf''', s);

     end;

      //####################################################################################### Other Settings

       //REPLAY toogle key
    case replaykeyCombobox.ItemIndex of
    0:begin
      RunCommand('bash -c ''echo "keyMods = ctrl+super" >> $HOME/.config/replay-sorcery.conf''', s);
      RunCommand('bash -c ''echo "keyName = r" >> $HOME/.config/replay-sorcery.conf''', s);
    end;
    1:begin
      RunCommand('bash -c ''echo "keyMods = ctrl+super" >> $HOME/.config/replay-sorcery.conf''', s);
      RunCommand('bash -c ''echo "keyName = F1" >> $HOME/.config/replay-sorcery.conf''', s);
    end;
    2:begin
      RunCommand('bash -c ''echo "keyMods = ctrl+super" >> $HOME/.config/replay-sorcery.conf''', s);
      RunCommand('bash -c ''echo "keyName = F2" >> $HOME/.config/replay-sorcery.conf''', s);
    end;
    3:begin
      RunCommand('bash -c ''echo "keyMods = ctrl+super" >> $HOME/.config/replay-sorcery.conf''', s);
      RunCommand('bash -c ''echo "keyName = F3" >> $HOME/.config/replay-sorcery.conf''', s);
    end;
    4:begin
      RunCommand('bash -c ''echo "keyMods = ctrl+super" >> $HOME/.config/replay-sorcery.conf''', s);
      RunCommand('bash -c ''echo "keyName = F4" >> $HOME/.config/replay-sorcery.conf''', s);
    end;
  end;

      //REPLAY Save message
      //RunCommand('bash -c ''echo "preOutputCommand = notify-send -i /usr/share/icons/hicolor/128x128/apps/goverlay.png Saving_video_recording" >> $HOME/.config/replay-sorcery.conf''', s);
      RunCommand('bash -c ''echo "outputCommand = notify-send -i /usr/share/icons/hicolor/128x128/apps/goverlay.png Video_Saved_in_the_home_folder" >> $HOME/.config/replay-sorcery.conf''', s);


     //Replay output folder
     RunCommand('bash -c ''echo "outputFile = $HOME/%F_%H-%M-%S.mp4" >> $HOME/.config/replay-sorcery.conf''', s);

   //####################################################################################### End of file creation


    //Copy generated replay-sorcery.conf to goverlay config folder
    RunCommand('bash -c ''yes | cp -rf $HOME/.config/replay-sorcery.conf $HOME/.config/goverlay/replay-sorcery.conf ''', s);



    // Delete old initial values and recreate folder
    //RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/''', s);
    //RunCommand('bash -c ''mkdir -p $HOME/.config/goverlay/initial_values/''', s);

    // Delete old initial values and recreate folder
    RunCommand('bash -c ''mkdir -p $HOME/.config/goverlay/initial_values/''', s);


    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_height''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_height_custom''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_width''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_width_custom''', s);

    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_videoFramerate''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_recordSeconds''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_videoInput''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_videoDevice''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_videoEncoder''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_videoProfile''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_videoPreset''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_videoQuality''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_videoBitrate''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_videoGOP''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_FULLSCREEN''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_AUTOSCALE''', s);

    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_audioInput''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_audioDevice''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_audioEncoder''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_audioProfile''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_audioSamplerate''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_audioBitrate''', s);


    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_keyCombo''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_offsetX''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_offsetX_custom''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_offsetY''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_offsetY_custom''', s);
    RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/replay_outputX264Preset''', s);



   //Extract configurations from main config File to the initial_values folder for replay-sorcery
    RunCommand('bash -c ''cat $HOME/.config/replay-sorcery.conf | grep -w videoWidth >> $HOME/.config/goverlay/initial_values/replay_width''', s);
    RunCommand('bash -c ''cat $HOME/.config/replay-sorcery.conf | grep -w videoWidth | cut -c 12-16  >> $HOME/.config/goverlay/initial_values/replay_width_custom''', s);  //store just the integer for initial values

    RunCommand('bash -c ''cat $HOME/.config/replay-sorcery.conf | grep -w videoHeight >> $HOME/.config/goverlay/initial_values/replay_height''', s);
    RunCommand('bash -c ''cat $HOME/.config/replay-sorcery.conf | grep -w videoHeight | cut -c 13-16  >> $HOME/.config/goverlay/initial_values/replay_height_custom''', s);  //store just the integer for initial values


    RunCommand('bash -c ''cat $HOME/.config/replay-sorcery.conf | grep -w videoFramerate >> $HOME/.config/goverlay/initial_values/replay_videoFramerate''', s);
    RunCommand('bash -c ''cat $HOME/.config/replay-sorcery.conf | grep -w recordSeconds >> $HOME/.config/goverlay/initial_values/replay_recordSeconds''', s);

    RunCommand('bash -c ''cat $HOME/.config/replay-sorcery.conf | grep -w videoInput >> $HOME/.config/goverlay/initial_values/replay_videoInput''', s);
    RunCommand('bash -c ''cat $HOME/.config/replay-sorcery.conf | grep -w videoDevice >> $HOME/.config/goverlay/initial_values/replay_videoDevice''', s);
    RunCommand('bash -c ''cat $HOME/.config/replay-sorcery.conf | grep -w videoEncoder >> $HOME/.config/goverlay/initial_values/replay_videoEncoder''', s);
    RunCommand('bash -c ''cat $HOME/.config/replay-sorcery.conf | grep -w videoProfile >> $HOME/.config/goverlay/initial_values/replay_videoProfile''', s);
    RunCommand('bash -c ''cat $HOME/.config/replay-sorcery.conf | grep -w videoPreset >> $HOME/.config/goverlay/initial_values/replay_videoPreset''', s);
    RunCommand('bash -c ''cat $HOME/.config/replay-sorcery.conf | grep -w videoQuality >> $HOME/.config/goverlay/initial_values/replay_videoQuality''', s);
    RunCommand('bash -c ''cat $HOME/.config/replay-sorcery.conf | grep -w videoBitrate >> $HOME/.config/goverlay/initial_values/replay_videoBitrate''', s);
    RunCommand('bash -c ''cat $HOME/.config/replay-sorcery.conf | grep -w videoGOP >> $HOME/.config/goverlay/initial_values/replay_videoGOP''', s);

    RunCommand('bash -c ''cat /tmp/goverlay/initial_values/replay_FULLSCREEN >> $HOME/.config/goverlay/initial_values/replay_FULLSCREEN''', s);
    RunCommand('bash -c ''cat /tmp/goverlay/initial_values/replay_AUTOSCALE >> $HOME/.config/goverlay/initial_values/replay_AUTOSCALE''', s);
    RunCommand('bash -c ''cat /tmp/goverlay/initial_values/replay_VIDEO_AUTO_QUALITY >> $HOME/.config/goverlay/initial_values/replay_VIDEO_AUTO_QUALITY''', s);
    RunCommand('bash -c ''cat /tmp/goverlay/initial_values/replay_VIDEO_AUTO_BITRATE >> $HOME/.config/goverlay/initial_values/replay_VIDEO_AUTO_BITRATE''', s);
    RunCommand('bash -c ''cat /tmp/goverlay/initial_values/replay_AUDIO_AUTO_BITRATE >> $HOME/.config/goverlay/initial_values/replay_AUDIO_AUTO_BITRATE''', s);

    RunCommand('bash -c ''cat $HOME/.config/replay-sorcery.conf | grep -w audioInput >> $HOME/.config/goverlay/initial_values/replay_audioInput''', s);
    RunCommand('bash -c ''cat $HOME/.config/replay-sorcery.conf | grep -w audioDevice >> $HOME/.config/goverlay/initial_values/replay_audioDevice''', s);
    RunCommand('bash -c ''cat $HOME/.config/replay-sorcery.conf | grep -w audioEncoder >> $HOME/.config/goverlay/initial_values/replay_audioEncoder''', s);
    RunCommand('bash -c ''cat $HOME/.config/replay-sorcery.conf | grep -w audioProfile >> $HOME/.config/goverlay/initial_values/replay_audioProfile''', s);
    RunCommand('bash -c ''cat $HOME/.config/replay-sorcery.conf | grep -w audioSamplerate >> $HOME/.config/goverlay/initial_values/replay_audioSamplerate''', s);
    RunCommand('bash -c ''cat $HOME/.config/replay-sorcery.conf | grep -w audioBitrate >> $HOME/.config/goverlay/initial_values/replay_audioBitrate''', s);

    RunCommand('bash -c ''cat $HOME/.config/replay-sorcery.conf | grep -w keyMods >> $HOME/.config/goverlay/initial_values/replay_keyMods''', s);
    RunCommand('bash -c ''cat $HOME/.config/replay-sorcery.conf | grep -w keyName >> $HOME/.config/goverlay/initial_values/replay_keyName''', s);



    end;

procedure Tgoverlayform.replaystartBitBtnClick(Sender: TObject);
begin
   RunCommand('bash -c ''notify-send -i /usr/share/icons/hicolor/128x128/apps/goverlay.png "Replay-Sorcery" "Service running in background, press the toggle key clip it"''', s);
   RunCommand('bash -c ''systemctl --user enable --now replay-sorcery''', s);
   RunCommand('bash -c ''rm /tmp/goverlay/replay_state''', s); // delete old variable for replay-sorcery state
   RunCommand('bash -c ''ps -e | grep replay >> /tmp/goverlay/replay_state''', s);

   //Store the state of replay-sorcery service
     AssignFile(replaystateVAR, '/tmp/goverlay/replay_state');
     Reset(replaystateVAR);
     Readln(replaystateVAR,replaystateSTR); //Assign Text file to String
     CloseFile(replaystateVAR);

     //Check state and activate components acordingly
     if replaystateSTR = '' then     // if service is not running
         begin
            replaystopBitbtn.Enabled := false;
            replayStartBitbtn.enabled := true;
            replaystateSpeedButton.ImageIndex:=1;
            replaystateLabel.Caption:='Service is not running';
         end
     else       // if service is running
         begin
            replaystopBitbtn.Enabled := true;
            replayStartBitbtn.enabled := false;
            replaystateSpeedButton.ImageIndex:=0;
            replaystateLabel.Caption:='Service is running';
         end;

end;

procedure Tgoverlayform.replaystopBitBtnClick(Sender: TObject);
begin
   RunCommand('bash -c ''notify-send -i /usr/share/icons/hicolor/128x128/apps/goverlay.png "Replay-Sorcery" "Service stopped"''', s);
   RunCommand('bash -c ''systemctl --user stop --now replay-sorcery''', s);
   RunCommand('bash -c ''rm /tmp/goverlay/replay_state''', s); // delete old variable for replay-sorcery state
   RunCommand('bash -c ''ps -e | grep replay >> /tmp/goverlay/replay_state''', s);

   //Store the state of replay-sorcery service
     AssignFile(replaystateVAR, '/tmp/goverlay/replay_state');
     Reset(replaystateVAR);
     Readln(replaystateVAR,replaystateSTR); //Assign Text file to String
     CloseFile(replaystateVAR);

     //Check state and activate components acordingly
     if replaystateSTR = '' then     // if service is not running
         begin
            replaystopBitbtn.Enabled := false;
            replayStartBitbtn.enabled := true;
            replaystateSpeedButton.ImageIndex:=1;
            replaystateLabel.Caption:='Service is not running';
         end
     else       // if service is running
         begin
            replaystopBitbtn.Enabled := true;
            replayStartBitbtn.enabled := false;
            replaystateSpeedButton.ImageIndex:=0;
            replaystateLabel.Caption:='Service is running';
         end;
end;

procedure Tgoverlayform.resolutionCheckBoxClick(Sender: TObject);
begin
         //Preview resolution
  if resolutionCheckbox.Checked=true then
  begin
  resolutionlabel.Caption:='Resolution';
  resolutionvaluelabel.Caption:='1920x1080';
  end
  else
  begin
  resolutionlabel.Caption:='';
   resolutionvaluelabel.Caption:='';
  end;
end;

procedure Tgoverlayform.runsteamBitBtnClick(Sender: TObject);
begin
      with runsteamBitbtn.ClientToScreen(point(0, 0)) do
     gamePopupMenu.Popup(X, Y);
end;

procedure Tgoverlayform.runvkbasaltBitBtnClick(Sender: TObject);
begin
     with runvkbasaltBitbtn.ClientToScreen(point(0, 0)) do
     vkbasaltPopupMenu.Popup(X, Y);
end;

procedure Tgoverlayform.saveBitBtn1Click(Sender: TObject);
begin
  RunCommand('bash -c ''export GALLIUM_HUD=simple,fps,cpu,frametime''', s); // test GALLIUMHUD
end;

procedure Tgoverlayform.sessionCheckBoxClick(Sender: TObject);
begin
    //Preview session
  if sessionCheckbox.Checked=true then
  begin
  sessionlabel.Caption:='Session:    x11';

  end
  else
  begin
  sessionlabel.Caption:='';

  end;
end;

procedure Tgoverlayform.showfpslimCheckBoxClick(Sender: TObject);
begin
     //Preview fps limit
  if showfpslimCheckbox.Checked=true then
  begin
  fpslimitlabel.Caption:='FPS Limit';
  fpslimitvaluelabel.Caption:='60';
  end
  else
  begin
  fpslimitlabel.Caption:='';
  fpslimitvaluelabel.Caption:='';
  end;
end;

procedure Tgoverlayform.steamMenuItemClick(Sender: TObject);
begin
  RunCommand('bash -c ''mangohud steam ''', s);   //Run steam
end;

procedure Tgoverlayform.swapusageCheckBoxClick(Sender: TObject);
begin
        //Preview SWAP usage
  if swapusageCheckbox.Checked=true then
    begin

    swapusagelabel.Caption:='2.00GB'
    end
  else
    begin

   swapusagelabel.Caption:='2.00GB'
  end;
end;

procedure Tgoverlayform.videobitrateTrackBarChange(Sender: TObject);
begin
   videobitrateLabel.Caption:= inttostr(videobitrateTrackBar.Position)+' Mbps';
end;

procedure Tgoverlayform.videogopTrackBarChange(Sender: TObject);
begin
  videogopLabel.Caption:= inttostr(videogopTrackBar.Position);
end;

procedure Tgoverlayform.videoqualityTrackBarChange(Sender: TObject);
begin
   videoqualityLabel.Caption:= inttostr(videoqualityTrackBar.Position);
end;




procedure Tgoverlayform.reshadesyncBitBtnClick(Sender: TObject);
begin
  //Delete old reshade files
  RunCommand('bash -c ''rm -Rf /tmp/goverlay/reshade''', s);

  // Popup a notification  and sync reshade git repositorie
  RunCommand('bash -c ''notify-send -i /usr/share/icons/hicolor/128x128/apps/goverlay.png "Syncing Reshade repositories..." "This can take a few seconds, please wait until complete" | git clone https://github.com/benjamimgois/reshade-shaders.git $HOME/.local/share/reshade''', s);
  RunCommand('bash -c ''notify-send -i /usr/share/icons/hicolor/128x128/apps/goverlay.png "Sync Complete"''', s); // Popup a notification


  // Copy reshade files to tmp folder
  RunCommand('bash -c ''yes | cp -rf $HOME/.local/share/reshade/ /tmp/goverlay/''', s);


// Check if Reshade files exist
RunCommand('bash -c ''rm $HOME/.config/goverlay/initial_values/reshade_git''', s); //delete old file in original folder
RunCommand('bash -c ''touch $HOME/.config/goverlay/initial_values/reshade_git''', s);   //create dummy file
RunCommand('bash -c ''cat $HOME/.local/share/reshade/README.md | grep -w master.zip >> $HOME/.config/goverlay/initial_values/reshade_git''', s);
RunCommand('bash -c ''yes | cp -rf $HOME/.config/goverlay/initial_values/reshade_git /tmp/goverlay/''', s); //copy file to tmp folder

// Assign Text file to variable
     AssignFile(reshadegitVAR, '/tmp/goverlay/reshade_git');
     Reset(reshadegitVAR);
     Readln(reshadegitVAR,reshadegitSTR); //Assign Text file to String
     CloseFile(reshadegitVAR);

//Check state and activate components acordingly
if reshadegitSTR = '1. [Download](https://github.com/crosire/reshade-shaders/archive/master.zip) this repository' then
   begin
   aveffectsListbox.Enabled := true;
   acteffectsListbox.Enabled:= true;
   addBitbtn.Enabled:=true;
   subBitbtn.Enabled:=true;
   reshadeProgressbar.Position:=100;
   end
else
    begin
    aveffectsListbox.Enabled := false;
    acteffectsListbox.Enabled:= false;
    addBitbtn.Enabled:=false;
    subBitbtn.Enabled:=false;
    end;


end;

procedure Tgoverlayform.resheightSpinEditMouseEnter(Sender: TObject);
begin
    if autoresCheckbox.Checked = false then
    heightImage.Visible:= true;
end;

procedure Tgoverlayform.resheightSpinEditMouseLeave(Sender: TObject);
begin
    if autoresCheckbox.Checked = false then
    heightImage.Visible:= false;
end;

procedure Tgoverlayform.reswidthSpinEditMouseEnter(Sender: TObject);
begin
  if autoresCheckbox.Checked = false then
  widthImage.Visible:= true;
end;

procedure Tgoverlayform.reswidthSpinEditMouseLeave(Sender: TObject);
begin
  if autoresCheckbox.Checked = false then
  widthImage.Visible:=false;
end;


procedure Tgoverlayform.completehudBitBtnClick(Sender: TObject);
begin
  //Check all hud options
  cpuavrloadCheckbox.Checked:=true;
  cputempCheckbox.Checked:=true;
  cpuloadcoreCheckbox.Checked:=true;
  gpuavrloadCheckbox.Checked:=true;
  gputempCheckbox.Checked:=true;
  gpufreqCheckbox.Checked:=true;
  diskioCheckbox.Checked:=true;
  swapusageCheckbox.Checked:=true;
  vramusageCheckbox.Checked:=true;
  ramusageCheckbox.Checked:=true;
  frametimegraphCheckbox.Checked:=true;
  timeCheckbox.Checked:=false;
  archCheckbox.Checked:=true;
  driverversionCheckbox.Checked:=true;
  gpupowerCheckBox.Checked:=true;
  gpumodelCheckBox.Checked:=true;
  gpumemfreqCheckBox.Checked:=true;
  engineversionCheckBox.Checked:=true;
  wineCheckbox.Checked:=true;
  cpufreqCheckbox.Checked:=true;
  cpupowerCheckbox.Checked:=true;
  gpuloadcolorCheckbox.Checked:=true;
  cpuloadcolorCheckbox.Checked:=true;
  hudversionCheckbox.Checked:=false;
  fpsCheckbox.Checked:=true;

  showfpslimCheckbox.Checked:=true;
  batteryCheckbox.Checked:=true;
  resolutionCheckbox.Checked:=true;
  vkbasaltstatusCheckbox.Checked:=true;
  gamemodestatusCheckbox.Checked:=true;
  sessionCheckbox.Checked:=true;
  distroinfoCheckbox.Checked:=true;
  homepartCheckbox.Checked:=true;

  gpuloadgraphBitbtn.imageindex:=3;
  gputempgraphBitbtn.imageindex:=3;
  gpucfgraphBitbtn.imageindex:=3;
  gpumfgraphBitbtn.imageindex:=3;
  vramgraphBitbtn.imageindex:=3;
  cpuloadgraphBitbtn.imageindex:=3;
  cputempgraphBitbtn.imageindex:=3;
  ramgraphBitbtn.imageindex:=3;

  //Preview all hud options
  cpulabel.Caption:='CPU';
  cpuusagelabel.Caption:='51%';
  cputemplabel.Caption:='71ºC';
  gpulabel.Caption:='GPU';
  gpuusagelabel.Caption:='95%';
  gpulabel.Caption:='GPU';
  gputemplabel.Caption:='82ºC';
  vramlabel.Caption:='VRAM';
  vramusagelabel.Caption:='2.56GB';
  //swapusagelabel.Caption:='3.2GB';
  ramlabel.Caption:='RAM';
  ramusagelabel.Caption:='5.99GB';
  frametimelabel.Caption:='Frametime';
  frametimelabel2.Caption:='16.6ms';
  frametimegraphlabel.Caption:='--------------------------------------';
  timelabel.Caption:='';
  iordrwlabel.caption:='IO RF/RW';
  iordvaluelabel.caption:='32MiB/s';
  iorwvaluelabel.caption:='22MiB/s';
  gpuclocklabel.caption:='1733MHz';
  archlabel.caption:='64bit';
  gpunamelabel.caption:='Geforce GTX 180';
  driverversionlabel.caption:='NVIDIA 440.18.00';
  gpupowerlabel.Caption:='120W';
  gpumemfreqlabel.Caption:='600MHz';
  engineversionlabel.Caption:='1.2.131';
  winelabel.Caption:='Proton 5.0-9';
  hudversionlabel.Caption:='';
  cpufreqlabel.Caption:='3400 MHz';
  cpupowerlabel.Caption:='150W' ;
  gpuusagelabel.Font.Color:=gpuload3Colorbutton.ButtonColor;
  cpuusagelabel.Font.Color:=cpuload2Colorbutton.ButtonColor;

  fpslimitlabel.Caption:='FPS Limit';
  fpslimitvaluelabel.Caption:='60';
  batterylabel.Caption:='BATT';
  batteryvaluelabel.Caption:='83%';
  batteryvaluelabel2.Caption:='25.3W';
  resolutionlabel.Caption:='Resolution';
  resolutionvaluelabel.Caption:='1920x1080';
  vkbasaltstatuslabel.Caption:='VKBASALT';
  vkbasaltstatusvaluelabel.Caption:='ON';
  gamemodestatuslabel.Caption:='GAMEMODE';
  gamemodestatusvaluelabel.Caption:='ON';
  sessionlabel.Caption:='Session:    x11';
  distroinfolabel.Caption:='Distribution info';
  distroinfolabel2.Caption:='Kernel:      version';
  homepartitionlabel.Caption:='/home/ partition size';

end;

procedure Tgoverlayform.clipdurationComboboxKeyPress(Sender: TObject;
  var Key: char);
begin
    //Block keypress on combobox
  key:=#0;
end;

procedure Tgoverlayform.cpufreqCheckBoxClick(Sender: TObject);
begin
      //PREVIEW CPU FREQUENCY
  if cpufreqCheckbox.Checked=true then
     cpufreqlabel.Caption:='3400 MHz'
  else
     cpufreqlabel.Caption:='' ;

end;

procedure Tgoverlayform.cpuloadcolorCheckBoxChange(Sender: TObject);
begin

end;



procedure Tgoverlayform.cpuloadcolorCheckBoxClick(Sender: TObject);
begin
            //PREVIEW  CPU load color
  if cpuloadcolorCheckbox.Checked=true then
     cpuusagelabel.Font.Color:=cpuload2Colorbutton.ButtonColor;
  if cpuloadcolorCheckbox.Checked=false then
     cpuusagelabel.Font.Color:=cpuload1Colorbutton.ButtonColor;
end;

procedure Tgoverlayform.cpuloadgraphBitBtnClick(Sender: TObject);
begin
     case cpuloadgraphBitbtn.ImageIndex of
     2:cpuloadgraphBitbtn.ImageIndex:= 3;
     3:cpuloadgraphBitbtn.ImageIndex:= 2;
     end;
end;

procedure Tgoverlayform.cpunameEditChange(Sender: TObject);
begin
  cpulabel.Caption:=cpunameEdit.Text;
end;

procedure Tgoverlayform.cpupowerCheckBoxClick(Sender: TObject);
begin
      //PREVIEW CPU POWER
  if cpupowerCheckbox.Checked=true then
     cpupowerlabel.Caption:='150W'
  else
     cpupowerlabel.Caption:='' ;

end;

procedure Tgoverlayform.cputempgraphBitBtnClick(Sender: TObject);
begin
     case cputempgraphBitbtn.ImageIndex of
     2:cputempgraphBitbtn.ImageIndex:= 3;
     3:cputempgraphBitbtn.ImageIndex:= 2;
     end;
end;

procedure Tgoverlayform.basaltsaveBitBtnClick(Sender: TObject);
begin
//Create directories
RunCommand('bash -c ''mkdir -p $HOME/.config/vkBasalt/''', s);



// Delete old file if it exists
RunCommand('bash -c ''rm $HOME/.config/vkBasalt/vkBasalt.conf''', s);


// Create a new vkbasalt file for goverlay
RunCommand('bash -c ''echo "################### File Generated by GOverlay ###################" >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //Insert reshade Paths in vkbasalt.conf
                 reshadepath1STR := 'reshadeTexturePath = '+userhomepathSTR+'/.local/share/reshade/Textures';
                 reshadepath2STR := 'reshadeIncludePath = '+userhomepathSTR+'/.local/share/reshade';


                 // Assign reshadepath1STR to text file
                 AssignFile(reshadepath1Value, '/tmp/goverlay/reshadepath1Value');
                 Rewrite(reshadepath1Value);
                 Writeln(reshadepath1Value,reshadepath1STR);
                 CloseFile(reshadepath1Value);

                 RunCommand('bash -c ''cat /tmp/goverlay/reshadepath1Value >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);

                 // Assign reshadepath2STR to text file
                 AssignFile(reshadepath2Value, '/tmp/goverlay/reshadepath2Value');
                 Rewrite(reshadepath2Value);
                 Writeln(reshadepath2Value,reshadepath2STR);
                 CloseFile(reshadepath2Value);

                 RunCommand('bash -c ''cat /tmp/goverlay/reshadepath2Value >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);



//#########################################       RESHADE SHADERS       ###########################################################################

                 //TDFX
                 TDFXshaderpathSTR := '3DFX = '+userhomepathSTR+'/.local/share/reshade/Shaders/3DFX.fx';

                 // Assign shadersSTR to text file
                 AssignFile(TDFXshaderpathValue, '/tmp/goverlay/TDFXshaderpathValue');
                 Rewrite(TDFXshaderpathValue);
                 Writeln(TDFXshaderpathValue,TDFXshaderpathSTR);
                 CloseFile(TDFXshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/TDFXshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //AdaptiveFog
                 AdaptiveFogshaderpathSTR := 'AdaptiveFog = '+userhomepathSTR+'/.local/share/reshade/Shaders/AdaptiveFog.fx';

                 // Assign shadersSTR to text file
                 AssignFile(AdaptiveFogshaderpathValue, '/tmp/goverlay/AdaptiveFogshaderpathValue');
                 Rewrite(AdaptiveFogshaderpathValue);
                 Writeln(AdaptiveFogshaderpathValue,AdaptiveFogshaderpathSTR);
                 CloseFile(AdaptiveFogshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/AdaptiveFogshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //AdaptiveSharpen
                 AdaptiveSharpenshaderpathSTR := 'AdaptiveSharpen = '+userhomepathSTR+'/.local/share/reshade/Shaders/AdaptiveSharpen.fx';

                 // Assign shadersSTR to text file
                 AssignFile(AdaptiveSharpenshaderpathValue, '/tmp/goverlay/AdaptiveSharpenshaderpathValue');
                 Rewrite(AdaptiveSharpenshaderpathValue);
                 Writeln(AdaptiveSharpenshaderpathValue,AdaptiveSharpenshaderpathSTR);
                 CloseFile(AdaptiveSharpenshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/AdaptiveSharpenshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //AmbientLight
                 AmbientLightshaderpathSTR := 'AmbientLight = '+userhomepathSTR+'/.local/share/reshade/Shaders/AmbientLight.fx';

                 // Assign shadersSTR to text file
                 AssignFile(AmbientLightshaderpathValue, '/tmp/goverlay/AmbientLightshaderpathValue');
                 Rewrite(AmbientLightshaderpathValue);
                 Writeln(AmbientLightshaderpathValue,AmbientLightshaderpathSTR);
                 CloseFile(AmbientLightshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/AmbientLightshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //ASCII
                 ASCIIshaderpathSTR := 'ASCII = '+userhomepathSTR+'/.local/share/reshade/Shaders/ASCII.fx';

                 // Assign shadersSTR to text file
                 AssignFile(ASCIIshaderpathValue, '/tmp/goverlay/ASCIIshaderpathValue');
                 Rewrite(ASCIIshaderpathValue);
                 Writeln(ASCIIshaderpathValue,ASCIIshaderpathSTR);
                 CloseFile(ASCIIshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/ASCIIshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //AspectRatio
                 AspectRatioshaderpathSTR := 'AspectRatio = '+userhomepathSTR+'/.local/share/reshade/Shaders/AspectRatio.fx';

                 // Assign shadersSTR to text file
                 AssignFile(AspectRatioshaderpathValue, '/tmp/goverlay/AspectRatioshaderpathValue');
                 Rewrite(AspectRatioshaderpathValue);
                 Writeln(AspectRatioshaderpathValue,AspectRatioshaderpathSTR);
                 CloseFile(AspectRatioshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/AspectRatioshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //Bloom
                 BloomshaderpathSTR := 'Bloom = '+userhomepathSTR+'/.local/share/reshade/Shaders/Bloom.fx';

                 // Assign shadersSTR to text file
                 AssignFile(BloomshaderpathValue, '/tmp/goverlay/BloomshaderpathValue');
                 Rewrite(BloomshaderpathValue);
                 Writeln(BloomshaderpathValue,BloomshaderpathSTR);
                 CloseFile(BloomshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/BloomshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);

                 //Border
                 BordershaderpathSTR := 'Border = '+userhomepathSTR+'/.local/share/reshade/Shaders/Border.fx';

                 // Assign shadersSTR to text file
                 AssignFile(BordershaderpathValue, '/tmp/goverlay/BordershaderpathValue');
                 Rewrite(BordershaderpathValue);
                 Writeln(BordershaderpathValue,BordershaderpathSTR);
                 CloseFile(BordershaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/BordershaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //Cartoon
                 CartoonshaderpathSTR := 'Cartoon = '+userhomepathSTR+'/.local/share/reshade/Shaders/Cartoon.fx';

                 // Assign shadersSTR to text file
                 AssignFile(CartoonshaderpathValue, '/tmp/goverlay/CartoonshaderpathValue');
                 Rewrite(CartoonshaderpathValue);
                 Writeln(CartoonshaderpathValue,CartoonshaderpathSTR);
                 CloseFile(CartoonshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/CartoonshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //ChromaKey
                 ChromaKeyshaderpathSTR := 'ChromaKey = '+userhomepathSTR+'/.local/share/reshade/Shaders/ChromaKey.fx';

                 // Assign shadersSTR to text file
                 AssignFile(ChromaKeyshaderpathValue, '/tmp/goverlay/ChromaKeyshaderpathValue');
                 Rewrite(ChromaKeyshaderpathValue);
                 Writeln(ChromaKeyshaderpathValue,ChromaKeyshaderpathSTR);
                 CloseFile(ChromaKeyshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/ChromaKeyshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //ChromaticAberration
                 ChromaticAberrationshaderpathSTR := 'ChromaticAberration = '+userhomepathSTR+'/.local/share/reshade/Shaders/ChromaticAberration.fx';

                 // Assign shadersSTR to text file
                 AssignFile(ChromaticAberrationshaderpathValue, '/tmp/goverlay/ChromaticAberrationshaderpathValue');
                 Rewrite(ChromaticAberrationshaderpathValue);
                 Writeln(ChromaticAberrationshaderpathValue,ChromaticAberrationshaderpathSTR);
                 CloseFile(ChromaticAberrationshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/ChromaticAberrationshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //CinematicDOF
                 CinematicDOFshaderpathSTR := 'CinematicDOF = '+userhomepathSTR+'/.local/share/reshade/Shaders/CinematicDOF.fx';

                 // Assign STRING to text file
                 AssignFile(CinematicDOFshaderpathValue, '/tmp/goverlay/CinematicDOFshaderpathValue');
                 Rewrite(CinematicDOFshaderpathValue);
                 Writeln(CinematicDOFshaderpathValue,CinematicDOFshaderpathSTR);
                 CloseFile(CinematicDOFshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/CinematicDOFshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //Clarity
                 ClarityshaderpathSTR := 'Clarity = '+userhomepathSTR+'/.local/share/reshade/Shaders/Clarity.fx';

                 // Assign STRING to text file
                 AssignFile(ClarityshaderpathValue, '/tmp/goverlay/ClarityshaderpathValue');
                 Rewrite(ClarityshaderpathValue);
                 Writeln(ClarityshaderpathValue,ClarityshaderpathSTR);
                 CloseFile(ClarityshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/ClarityshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //ColorMatrix
                 ColorMatrixshaderpathSTR := 'ColorMatrix = '+userhomepathSTR+'/.local/share/reshade/Shaders/ColorMatrix.fx';

                 // Assign STRING to text file
                 AssignFile(ColorMatrixshaderpathValue, '/tmp/goverlay/ColorMatrixshaderpathValue');
                 Rewrite(ColorMatrixshaderpathValue);
                 Writeln(ColorMatrixshaderpathValue,ColorMatrixshaderpathSTR);
                 CloseFile(ColorMatrixshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/ColorMatrixshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //Colourfulness
                 ColourfulnessshaderpathSTR := 'Colourfulness = '+userhomepathSTR+'/.local/share/reshade/Shaders/Colourfulness.fx';

                 // Assign STRING to text file
                 AssignFile(ColourfulnessshaderpathValue, '/tmp/goverlay/ColourfulnessshaderpathValue');
                 Rewrite(ColourfulnessshaderpathValue);
                 Writeln(ColourfulnessshaderpathValue,ColourfulnessshaderpathSTR);
                 CloseFile(ColourfulnessshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/ColourfulnessshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //CRT
                 CRTshaderpathSTR := 'CRT = '+userhomepathSTR+'/.local/share/reshade/Shaders/CRT.fx';

                 // Assign STRING to text file
                 AssignFile(CRTshaderpathValue, '/tmp/goverlay/CRTshaderpathValue');
                 Rewrite(CRTshaderpathValue);
                 Writeln(CRTshaderpathValue,CRTshaderpathSTR);
                 CloseFile(CRTshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/CRTshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);

                 //Curves
                 CurvesshaderpathSTR := 'Curves = '+userhomepathSTR+'/.local/share/reshade/Shaders/Curves.fx';

                 // Assign STRING to text file
                 AssignFile(CurvesshaderpathValue, '/tmp/goverlay/CurvesshaderpathValue');
                 Rewrite(CurvesshaderpathValue);
                 Writeln(CurvesshaderpathValue,CurvesshaderpathSTR);
                 CloseFile(CurvesshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/CurvesshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //Daltonize
                 DaltonizeshaderpathSTR := 'Daltonize = '+userhomepathSTR+'/.local/share/reshade/Shaders/Daltonize.fx';

                 // Assign STRING to text file
                 AssignFile(DaltonizeshaderpathValue, '/tmp/goverlay/DaltonizeshaderpathValue');
                 Rewrite(DaltonizeshaderpathValue);
                 Writeln(DaltonizeshaderpathValue,DaltonizeshaderpathSTR);
                 CloseFile(DaltonizeshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/DaltonizeshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);

                 //Deband
                 DebandshaderpathSTR := 'Deband = '+userhomepathSTR+'/.local/share/reshade/Shaders/Deband.fx';

                 // Assign STRING to text file
                 AssignFile(DebandshaderpathValue, '/tmp/goverlay/DebandshaderpathValue');
                 Rewrite(DebandshaderpathValue);
                 Writeln(DebandshaderpathValue,DebandshaderpathSTR);
                 CloseFile(DebandshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/DebandshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);

                                  //Denoise
                 DenoiseshaderpathSTR := 'Denoise = '+userhomepathSTR+'/.local/share/reshade/Shaders/Denoise.fx';

                 // Assign STRING to text file
                 AssignFile(DenoiseshaderpathValue, '/tmp/goverlay/DenoiseshaderpathValue');
                 Rewrite(DenoiseshaderpathValue);
                 Writeln(DenoiseshaderpathValue,DenoiseshaderpathSTR);
                 CloseFile(DenoiseshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/DenoiseshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                               //Depth3D
                 Depth3DshaderpathSTR := 'Depth3D = '+userhomepathSTR+'/.local/share/reshade/Shaders/Depth3D.fx';

                 // Assign STRING to text file
                 AssignFile(Depth3DshaderpathValue, '/tmp/goverlay/Depth3DshaderpathValue');
                 Rewrite(Depth3DshaderpathValue);
                 Writeln(Depth3DshaderpathValue,Depth3DshaderpathSTR);
                 CloseFile(Depth3DshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/Depth3DshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //Dephhaze
                 DephhazeshaderpathSTR := 'Dephhaze = '+userhomepathSTR+'/.local/share/reshade/Shaders/Dephhaze.fx';

                 // Assign STRING to text file
                 AssignFile(DephhazeshaderpathValue, '/tmp/goverlay/DephhazeshaderpathValue');
                 Rewrite(DephhazeshaderpathValue);
                 Writeln(DephhazeshaderpathValue,DephhazeshaderpathSTR);
                 CloseFile(DephhazeshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/DephhazeshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //DisplayDepth
                 DisplayDepthshaderpathSTR := 'DisplayDepth = '+userhomepathSTR+'/.local/share/reshade/Shaders/DisplayDepth.fx';

                 // Assign STRING to text file
                 AssignFile(DisplayDepthshaderpathValue, '/tmp/goverlay/DisplayDepthshaderpathValue');
                 Rewrite(DisplayDepthshaderpathValue);
                 Writeln(DisplayDepthshaderpathValue,DisplayDepthshaderpathSTR);
                 CloseFile(DisplayDepthshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/DisplayDepthshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);

                                  //DOF
                 DOFshaderpathSTR := 'DOF = '+userhomepathSTR+'/.local/share/reshade/Shaders/DOF.fx';

                 // Assign STRING to text file
                 AssignFile(DOFshaderpathValue, '/tmp/goverlay/DOFshaderpathValue');
                 Rewrite(DOFshaderpathValue);
                 Writeln(DOFshaderpathValue,DOFshaderpathSTR);
                 CloseFile(DOFshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/DOFshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //DPX
                 DPXshaderpathSTR := 'DPX = '+userhomepathSTR+'/.local/share/reshade/Shaders/DPX.fx';

                 // Assign STRING to text file
                 AssignFile(DPXshaderpathValue, '/tmp/goverlay/DPXshaderpathValue');
                 Rewrite(DPXshaderpathValue);
                 Writeln(DPXshaderpathValue,DPXshaderpathSTR);
                 CloseFile(DPXshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/DPXshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //Emphasize
                 EmphasizeshaderpathSTR := 'Emphasize = '+userhomepathSTR+'/.local/share/reshade/Shaders/Emphasize.fx';

                 // Assign STRING to text file
                 AssignFile(EmphasizeshaderpathValue, '/tmp/goverlay/EmphasizeshaderpathValue');
                 Rewrite(EmphasizeshaderpathValue);
                 Writeln(EmphasizeshaderpathValue,EmphasizeshaderpathSTR);
                 CloseFile(EmphasizeshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/EmphasizeshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);

                                  //EyeAdaption
                 EyeAdaptionshaderpathSTR := 'EyeAdaption = '+userhomepathSTR+'/.local/share/reshade/Shaders/EyeAdaption.fx';

                 // Assign STRING to text file
                 AssignFile(EyeAdaptionshaderpathValue, '/tmp/goverlay/EyeAdaptionshaderpathValue');
                 Rewrite(EyeAdaptionshaderpathValue);
                 Writeln(EyeAdaptionshaderpathValue,EyeAdaptionshaderpathSTR);
                 CloseFile(EyeAdaptionshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/EyeAdaptionshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //FakeHDR
                 FakeHDRshaderpathSTR := 'FakeHDR = '+userhomepathSTR+'/.local/share/reshade/Shaders/FakeHDR.fx';

                 // Assign STRING to text file
                 AssignFile(FakeHDRshaderpathValue, '/tmp/goverlay/FakeHDRshaderpathValue');
                 Rewrite(FakeHDRshaderpathValue);
                 Writeln(FakeHDRshaderpathValue,FakeHDRshaderpathSTR);
                 CloseFile(FakeHDRshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/FakeHDRshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //FakeMotionBlur
                 FakeMotionBlurshaderpathSTR := 'FakeMotionBlur = '+userhomepathSTR+'/.local/share/reshade/Shaders/FakeMotionBlur.fx';

                 // Assign STRING to text file
                 AssignFile(FakeMotionBlurshaderpathValue, '/tmp/goverlay/FakeMotionBlurshaderpathValue');
                 Rewrite(FakeMotionBlurshaderpathValue);
                 Writeln(FakeMotionBlurshaderpathValue,FakeMotionBlurshaderpathSTR);
                 CloseFile(FakeMotionBlurshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/FakeMotionBlurshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //FilmGrain
                 FilmGrainshaderpathSTR := 'FilmGrain = '+userhomepathSTR+'/.local/share/reshade/Shaders/FilmGrain.fx';

                 // Assign STRING to text file
                 AssignFile(FilmGrainshaderpathValue, '/tmp/goverlay/FilmGrainshaderpathValue');
                 Rewrite(FilmGrainshaderpathValue);
                 Writeln(FilmGrainshaderpathValue,FilmGrainshaderpathSTR);
                 CloseFile(FilmGrainshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/FilmGrainshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //FilmGrain2
                 FilmGrain2shaderpathSTR := 'FilmGrain2 = '+userhomepathSTR+'/.local/share/reshade/Shaders/FilmGrain2.fx';

                 // Assign STRING to text file
                 AssignFile(FilmGrain2shaderpathValue, '/tmp/goverlay/FilmGrain2shaderpathValue');
                 Rewrite(FilmGrain2shaderpathValue);
                 Writeln(FilmGrain2shaderpathValue,FilmGrain2shaderpathSTR);
                 CloseFile(FilmGrain2shaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/FilmGrain2shaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);



                                  //FilmicAnamorphSharpen
                 FilmicAnamorphSharpenshaderpathSTR := 'FilmicAnamorphSharpen = '+userhomepathSTR+'/.local/share/reshade/Shaders/FilmicAnamorphSharpen.fx';

                 // Assign STRING to text file
                 AssignFile(FilmicAnamorphSharpenshaderpathValue, '/tmp/goverlay/FilmicAnamorphSharpenshaderpathValue');
                 Rewrite(FilmicAnamorphSharpenshaderpathValue);
                 Writeln(FilmicAnamorphSharpenshaderpathValue,FilmicAnamorphSharpenshaderpathSTR);
                 CloseFile(FilmicAnamorphSharpenshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/FilmicAnamorphSharpenshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);



                                  //FilmicPass
                 FilmicPassshaderpathSTR := 'FilmicPass = '+userhomepathSTR+'/.local/share/reshade/Shaders/FilmicPass.fx';

                 // Assign STRING to text file
                 AssignFile(FilmicPassshaderpathValue, '/tmp/goverlay/FilmicPassshaderpathValue');
                 Rewrite(FilmicPassshaderpathValue);
                 Writeln(FilmicPassshaderpathValue,FilmicPassshaderpathSTR);
                 CloseFile(FilmicPassshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/FilmicPassshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //FineSharp
                 FineSharpshaderpathSTR := 'FineSharp = '+userhomepathSTR+'/.local/share/reshade/Shaders/FineSharp.fx';

                 // Assign STRING to text file
                 AssignFile(FineSharpshaderpathValue, '/tmp/goverlay/FineSharpshaderpathValue');
                 Rewrite(FineSharpshaderpathValue);
                 Writeln(FineSharpshaderpathValue,FineSharpshaderpathSTR);
                 CloseFile(FineSharpshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/FineSharpshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //FXAA
                 FXAAshaderpathSTR := 'FXAA = '+userhomepathSTR+'/.local/share/reshade/Shaders/FXAA.fx';

                 // Assign STRING to text file
                 AssignFile(FXAAshaderpathValue, '/tmp/goverlay/FXAAshaderpathValue');
                 Rewrite(FXAAshaderpathValue);
                 Writeln(FXAAshaderpathValue,FXAAshaderpathSTR);
                 CloseFile(FXAAshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/FXAAshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //GaussianBlur
                 GaussianBlurshaderpathSTR := 'GaussianBlur = '+userhomepathSTR+'/.local/share/reshade/Shaders/GaussianBlur.fx';

                 // Assign STRING to text file
                 AssignFile(GaussianBlurshaderpathValue, '/tmp/goverlay/GaussianBlurshaderpathValue');
                 Rewrite(GaussianBlurshaderpathValue);
                 Writeln(GaussianBlurshaderpathValue,GaussianBlurshaderpathSTR);
                 CloseFile(GaussianBlurshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/GaussianBlurshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //Glitch
                 GlitchshaderpathSTR := 'Glitch = '+userhomepathSTR+'/.local/share/reshade/Shaders/Glitch.fx';

                 // Assign STRING to text file
                 AssignFile(GlitchshaderpathValue, '/tmp/goverlay/GlitchshaderpathValue');
                 Rewrite(GlitchshaderpathValue);
                 Writeln(GlitchshaderpathValue,GlitchshaderpathSTR);
                 CloseFile(GlitchshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/GlitchshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //HighPassSharpen
                 HighPassSharpenshaderpathSTR := 'HighPassSharpen = '+userhomepathSTR+'/.local/share/reshade/Shaders/HighPassSharpen.fx';

                 // Assign STRING to text file
                 AssignFile(HighPassSharpenshaderpathValue, '/tmp/goverlay/HighPassSharpenshaderpathValue');
                 Rewrite(HighPassSharpenshaderpathValue);
                 Writeln(HighPassSharpenshaderpathValue,HighPassSharpenshaderpathSTR);
                 CloseFile(HighPassSharpenshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/HighPassSharpenshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //HQ4X
                 HQ4XshaderpathSTR := 'HQ4X = '+userhomepathSTR+'/.local/share/reshade/Shaders/HQ4X.fx';

                 // Assign STRING to text file
                 AssignFile(HQ4XshaderpathValue, '/tmp/goverlay/HQ4XshaderpathValue');
                 Rewrite(HQ4XshaderpathValue);
                 Writeln(HQ4XshaderpathValue,HQ4XshaderpathSTR);
                 CloseFile(HQ4XshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/HQ4XshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //HSLShift
                 HSLShiftshaderpathSTR := 'HSLShift = '+userhomepathSTR+'/.local/share/reshade/Shaders/HSLShift.fx';

                 // Assign STRING to text file
                 AssignFile(HSLShiftshaderpathValue, '/tmp/goverlay/HSLShiftshaderpathValue');
                 Rewrite(HSLShiftshaderpathValue);
                 Writeln(HSLShiftshaderpathValue,HSLShiftshaderpathSTR);
                 CloseFile(HSLShiftshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/HSLShiftshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //Layer
                 LayershaderpathSTR := 'Layer = '+userhomepathSTR+'/.local/share/reshade/Shaders/Layer.fx';

                 // Assign STRING to text file
                 AssignFile(LayershaderpathValue, '/tmp/goverlay/LayershaderpathValue');
                 Rewrite(LayershaderpathValue);
                 Writeln(LayershaderpathValue,LayershaderpathSTR);
                 CloseFile(LayershaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/LayershaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //Levels
                 LevelsshaderpathSTR := 'Levels = '+userhomepathSTR+'/.local/share/reshade/Shaders/Levels.fx';

                 // Assign STRING to text file
                 AssignFile(LevelsshaderpathValue, '/tmp/goverlay/LevelsshaderpathValue');
                 Rewrite(LevelsshaderpathValue);
                 Writeln(LevelsshaderpathValue,LevelsshaderpathSTR);
                 CloseFile(LevelsshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/LevelsshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //LevelsPlus
                 LevelsPlusshaderpathSTR := 'LevelsPlus = '+userhomepathSTR+'/.local/share/reshade/Shaders/LevelsPlus.fx';

                 // Assign STRING to text file
                 AssignFile(LevelsPlusshaderpathValue, '/tmp/goverlay/LevelsPlusshaderpathValue');
                 Rewrite(LevelsPlusshaderpathValue);
                 Writeln(LevelsPlusshaderpathValue,LevelsPlusshaderpathSTR);
                 CloseFile(LevelsPlusshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/LevelsPlusshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                 //LiftGammaGain
                 LiftGammaGainshaderpathSTR := 'LiftGammaGain = '+userhomepathSTR+'/.local/share/reshade/Shaders/LiftGammaGain.fx';

                 // Assign STRING to text file
                 AssignFile(LiftGammaGainshaderpathValue, '/tmp/goverlay/LiftGammaGainshaderpathValue');
                 Rewrite(LiftGammaGainshaderpathValue);
                 Writeln(LiftGammaGainshaderpathValue,LiftGammaGainshaderpathSTR);
                 CloseFile(LiftGammaGainshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/LiftGammaGainshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //LightDoF
                 LightDoFshaderpathSTR := 'LightDoF = '+userhomepathSTR+'/.local/share/reshade/Shaders/LightDoF.fx';

                 // Assign STRING to text file
                 AssignFile(LightDoFshaderpathValue, '/tmp/goverlay/LightDoFshaderpathValue');
                 Rewrite(LightDoFshaderpathValue);
                 Writeln(LightDoFshaderpathValue,LightDoFshaderpathSTR);
                 CloseFile(LightDoFshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/LightDoFshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //LumaSharpen
                 LumaSharpenshaderpathSTR := 'LumaSharpen = '+userhomepathSTR+'/.local/share/reshade/Shaders/LumaSharpen.fx';

                 // Assign STRING to text file
                 AssignFile(LumaSharpenshaderpathValue, '/tmp/goverlay/LumaSharpenshaderpathValue');
                 Rewrite(LumaSharpenshaderpathValue);
                 Writeln(LumaSharpenshaderpathValue,LumaSharpenshaderpathSTR);
                 CloseFile(LumaSharpenshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/LumaSharpenshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //LUT
                 LUTshaderpathSTR := 'LUT = '+userhomepathSTR+'/.local/share/reshade/Shaders/LUT.fx';

                 // Assign STRING to text file
                 AssignFile(LUTshaderpathValue, '/tmp/goverlay/LUTshaderpathValue');
                 Rewrite(LUTshaderpathValue);
                 Writeln(LUTshaderpathValue,LUTshaderpathSTR);
                 CloseFile(LUTshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/LUTshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //MagicBloom
                 MagicBloomshaderpathSTR := 'MagicBloom = '+userhomepathSTR+'/.local/share/reshade/Shaders/MagicBloom.fx';

                 // Assign STRING to text file
                 AssignFile(MagicBloomshaderpathValue, '/tmp/goverlay/MagicBloomshaderpathValue');
                 Rewrite(MagicBloomshaderpathValue);
                 Writeln(MagicBloomshaderpathValue,MagicBloomshaderpathSTR);
                 CloseFile(MagicBloomshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/MagicBloomshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //Monochrome
                 MonochromeshaderpathSTR := 'Monochrome = '+userhomepathSTR+'/.local/share/reshade/Shaders/Monochrome.fx';

                 // Assign STRING to text file
                 AssignFile(MonochromeshaderpathValue, '/tmp/goverlay/MonochromeshaderpathValue');
                 Rewrite(MonochromeshaderpathValue);
                 Writeln(MonochromeshaderpathValue,MonochromeshaderpathSTR);
                 CloseFile(MonochromeshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/MonochromeshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //MultiLUT
                 MultiLUTshaderpathSTR := 'MultiLUT = '+userhomepathSTR+'/.local/share/reshade/Shaders/MultiLUT.fx';

                 // Assign STRING to text file
                 AssignFile(MultiLUTshaderpathValue, '/tmp/goverlay/MultiLUTshaderpathValue');
                 Rewrite(MultiLUTshaderpathValue);
                 Writeln(MultiLUTshaderpathValue,MultiLUTshaderpathSTR);
                 CloseFile(MultiLUTshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/MultiLUTshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //MXAO
                 MXAOshaderpathSTR := 'MXAO = '+userhomepathSTR+'/.local/share/reshade/Shaders/MXAO.fx';

                 // Assign STRING to text file
                 AssignFile(MXAOshaderpathValue, '/tmp/goverlay/MXAOshaderpathValue');
                 Rewrite(MXAOshaderpathValue);
                 Writeln(MXAOshaderpathValue,MXAOshaderpathSTR);
                 CloseFile(MXAOshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/MXAOshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //NightVision
                 NightVisionshaderpathSTR := 'NightVision = '+userhomepathSTR+'/.local/share/reshade/Shaders/NightVision.fx';

                 // Assign STRING to text file
                 AssignFile(NightVisionshaderpathValue, '/tmp/goverlay/NightVisionshaderpathValue');
                 Rewrite(NightVisionshaderpathValue);
                 Writeln(NightVisionshaderpathValue,NightVisionshaderpathSTR);
                 CloseFile(NightVisionshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/NightVisionshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                 //Nostalgia
                 NostalgiashaderpathSTR := 'Nostalgia = '+userhomepathSTR+'/.local/share/reshade/Shaders/Nostalgia.fx';

                 // Assign STRING to text file
                 AssignFile(NostalgiashaderpathValue, '/tmp/goverlay/NostalgiashaderpathValue');
                 Rewrite(NostalgiashaderpathValue);
                 Writeln(NostalgiashaderpathValue,NostalgiashaderpathSTR);
                 CloseFile(NostalgiashaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/NostalgiashaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                                  //PerfectPerspective
                 PerfectPerspectiveshaderpathSTR := 'PerfectPerspective = '+userhomepathSTR+'/.local/share/reshade/Shaders/PerfectPerspective.fx';

                 // Assign STRING to text file
                 AssignFile(PerfectPerspectiveshaderpathValue, '/tmp/goverlay/PerfectPerspectiveshaderpathValue');
                 Rewrite(PerfectPerspectiveshaderpathValue);
                 Writeln(PerfectPerspectiveshaderpathValue,PerfectPerspectiveshaderpathSTR);
                 CloseFile(PerfectPerspectiveshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/PerfectPerspectiveshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);

                 //PPFX_Bloom
                 PPFX_BloomshaderpathSTR := 'PPFX_Bloom = '+userhomepathSTR+'/.local/share/reshade/Shaders/PPFX_Bloom.fx';

                 // Assign STRING to text file
                 AssignFile(PPFX_BloomshaderpathValue, '/tmp/goverlay/PPFX_BloomshaderpathValue');
                 Rewrite(PPFX_BloomshaderpathValue);
                 Writeln(PPFX_BloomshaderpathValue,PPFX_BloomshaderpathSTR);
                 CloseFile(PPFX_BloomshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/PPFX_BloomshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //PPFX_Godrays
                 PPFX_GodraysshaderpathSTR := 'PPFX_Godrays = '+userhomepathSTR+'/.local/share/reshade/Shaders/PPFX_Godrays.fx';

                 // Assign STRING to text file
                 AssignFile(PPFX_GodraysshaderpathValue, '/tmp/goverlay/PPFX_GodraysshaderpathValue');
                 Rewrite(PPFX_GodraysshaderpathValue);
                 Writeln(PPFX_GodraysshaderpathValue,PPFX_GodraysshaderpathSTR);
                 CloseFile(PPFX_GodraysshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/PPFX_GodraysshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //Prism
                 PrismshaderpathSTR := 'Prism = '+userhomepathSTR+'/.local/share/reshade/Shaders/Prism.fx';

                 // Assign STRING to text file
                 AssignFile(PrismshaderpathValue, '/tmp/goverlay/PrismshaderpathValue');
                 Rewrite(PrismshaderpathValue);
                 Writeln(PrismshaderpathValue,PrismshaderpathSTR);
                 CloseFile(PrismshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/PrismshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);

                 //ReflectiveBumpMapping
                 ReflectiveBumpMappingshaderpathSTR := 'ReflectiveBumpMapping = '+userhomepathSTR+'/.local/share/reshade/Shaders/ReflectiveBumpMapping.fx';

                 // Assign STRING to text file
                 AssignFile(ReflectiveBumpMappingshaderpathValue, '/tmp/goverlay/ReflectiveBumpMappingshaderpathValue');
                 Rewrite(ReflectiveBumpMappingshaderpathValue);
                 Writeln(ReflectiveBumpMappingshaderpathValue,ReflectiveBumpMappingshaderpathSTR);
                 CloseFile(ReflectiveBumpMappingshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/ReflectiveBumpMappingshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //Sepia
                 SepiashaderpathSTR := 'Sepia = '+userhomepathSTR+'/.local/share/reshade/Shaders/Sepia.fx';

                 // Assign STRING to text file
                 AssignFile(SepiashaderpathValue, '/tmp/goverlay/SepiashaderpathValue');
                 Rewrite(SepiashaderpathValue);
                 Writeln(SepiashaderpathValue,SepiashaderpathSTR);
                 CloseFile(SepiashaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/SepiashaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //SMAA
                 SMAAshaderpathSTR := 'SMAA = '+userhomepathSTR+'/.local/share/reshade/Shaders/SMAA.fx';

                 // Assign STRING to text file
                 AssignFile(SMAAshaderpathValue, '/tmp/goverlay/SMAAshaderpathValue');
                 Rewrite(SMAAshaderpathValue);
                 Writeln(SMAAshaderpathValue,SMAAshaderpathSTR);
                 CloseFile(SMAAshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/SMAAshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //Splitscreen
                 SplitscreenshaderpathSTR := 'Splitscreen = '+userhomepathSTR+'/.local/share/reshade/Shaders/Splitscreen.fx';

                 // Assign STRING to text file
                 AssignFile(SplitscreenshaderpathValue, '/tmp/goverlay/SplitscreenshaderpathValue');
                 Rewrite(SplitscreenshaderpathValue);
                 Writeln(SplitscreenshaderpathValue,SplitscreenshaderpathSTR);
                 CloseFile(SplitscreenshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/SplitscreenshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);

                 //StageDepth
                 StageDepthshaderpathSTR := 'StageDepth = '+userhomepathSTR+'/.local/share/reshade/Shaders/StageDepth.fx';

                 // Assign STRING to text file
                 AssignFile(StageDepthshaderpathValue, '/tmp/goverlay/StageDepthshaderpathValue');
                 Rewrite(StageDepthshaderpathValue);
                 Writeln(StageDepthshaderpathValue,StageDepthshaderpathSTR);
                 CloseFile(StageDepthshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/StageDepthshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //SurfaceBlur
                 SurfaceBlurshaderpathSTR := 'SurfaceBlur = '+userhomepathSTR+'/.local/share/reshade/Shaders/SurfaceBlur.fx';

                 // Assign STRING to text file
                 AssignFile(SurfaceBlurshaderpathValue, '/tmp/goverlay/SurfaceBlurshaderpathValue');
                 Rewrite(SurfaceBlurshaderpathValue);
                 Writeln(SurfaceBlurshaderpathValue,SurfaceBlurshaderpathSTR);
                 CloseFile(SurfaceBlurshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/SurfaceBlurshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //Technicolor
                 TechnicolorshaderpathSTR := 'Technicolor = '+userhomepathSTR+'/.local/share/reshade/Shaders/Technicolor.fx';

                 // Assign STRING to text file
                 AssignFile(TechnicolorshaderpathValue, '/tmp/goverlay/TechnicolorshaderpathValue');
                 Rewrite(TechnicolorshaderpathValue);
                 Writeln(TechnicolorshaderpathValue,TechnicolorshaderpathSTR);
                 CloseFile(TechnicolorshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/TechnicolorshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //Technicolor2
                 Technicolor2shaderpathSTR := 'Technicolor2 = '+userhomepathSTR+'/.local/share/reshade/Shaders/Technicolor2.fx';

                 // Assign STRING to text file
                 AssignFile(Technicolor2shaderpathValue, '/tmp/goverlay/Technicolor2shaderpathValue');
                 Rewrite(Technicolor2shaderpathValue);
                 Writeln(Technicolor2shaderpathValue,Technicolor2shaderpathSTR);
                 CloseFile(Technicolor2shaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/Technicolor2shaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //TiltShift
                 TiltShiftshaderpathSTR := 'TiltShift = '+userhomepathSTR+'/.local/share/reshade/Shaders/TiltShift.fx';

                 // Assign STRING to text file
                 AssignFile(TiltShiftshaderpathValue, '/tmp/goverlay/TiltShiftshaderpathValue');
                 Rewrite(TiltShiftshaderpathValue);
                 Writeln(TiltShiftshaderpathValue,TiltShiftshaderpathSTR);
                 CloseFile(TiltShiftshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/TiltShiftshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //Tonemap
                 TonemapshaderpathSTR := 'Tonemap = '+userhomepathSTR+'/.local/share/reshade/Shaders/Tonemap.fx';

                 // Assign STRING to text file
                 AssignFile(TonemapshaderpathValue, '/tmp/goverlay/TonemapshaderpathValue');
                 Rewrite(TonemapshaderpathValue);
                 Writeln(TonemapshaderpathValue,TonemapshaderpathSTR);
                 CloseFile(TonemapshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/TonemapshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //TriDither
                 TriDithershaderpathSTR := 'TriDither = '+userhomepathSTR+'/.local/share/reshade/Shaders/TriDither.fx';

                 // Assign STRING to text file
                 AssignFile(TriDithershaderpathValue, '/tmp/goverlay/TriDithershaderpathValue');
                 Rewrite(TriDithershaderpathValue);
                 Writeln(TriDithershaderpathValue,TriDithershaderpathSTR);
                 CloseFile(TriDithershaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/TriDithershaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //UIDetect
                 UIDetectshaderpathSTR := 'UIDetect = '+userhomepathSTR+'/.local/share/reshade/Shaders/UIDetect.fx';

                 // Assign STRING to text file
                 AssignFile(UIDetectshaderpathValue, '/tmp/goverlay/UIDetectshaderpathValue');
                 Rewrite(UIDetectshaderpathValue);
                 Writeln(UIDetectshaderpathValue,UIDetectshaderpathSTR);
                 CloseFile(UIDetectshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/UIDetectshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);

                 //UIMask
                 UIMaskshaderpathSTR := 'UIMask = '+userhomepathSTR+'/.local/share/reshade/Shaders/UIMask.fx';

                 // Assign STRING to text file
                 AssignFile(UIMaskshaderpathValue, '/tmp/goverlay/UIMaskshaderpathValue');
                 Rewrite(UIMaskshaderpathValue);
                 Writeln(UIMaskshaderpathValue,UIMaskshaderpathSTR);
                 CloseFile(UIMaskshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/UIMaskshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //Vibrance
                 VibranceshaderpathSTR := 'Vibrance = '+userhomepathSTR+'/.local/share/reshade/Shaders/Vibrance.fx';

                 // Assign STRING to text file
                 AssignFile(VibranceshaderpathValue, '/tmp/goverlay/VibranceshaderpathValue');
                 Rewrite(VibranceshaderpathValue);
                 Writeln(VibranceshaderpathValue,VibranceshaderpathSTR);
                 CloseFile(VibranceshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/VibranceshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


                 //Vignette
                 VignetteshaderpathSTR := 'Vignette = '+userhomepathSTR+'/.local/share/reshade/Shaders/Vignette.fx';

                 // Assign STRING to text file
                 AssignFile(VignetteshaderpathValue, '/tmp/goverlay/VignetteshaderpathValue');
                 Rewrite(VignetteshaderpathValue);
                 Writeln(VignetteshaderpathValue,VignetteshaderpathSTR);
                 CloseFile(VignetteshaderpathValue);

                 RunCommand('bash -c ''cat /tmp/goverlay/VignetteshaderpathValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


//#########################################       RESHADE SHADERS       ###########################################################################

  // Popup a notification
  RunCommand('bash -c ''notify-send -i /usr/share/icons/hicolor/128x128/apps/goverlay.png "vkBasalt" "Configuration saved"''', s);


  // Effects in use

  //CAS
  if  casCheckBox.Checked = true then
  begin
  casSTR := true;
     // Assign cas value to text file
      AssignFile(cascheckValue, '/tmp/goverlay/cascheckValue');
      Rewrite(cascheckValue);
      Writeln(cascheckValue,casSTR);
      CloseFile(cascheckValue);
  end;
 RunCommand('bash -c ''yes | cp -rf /tmp/goverlay/cascheckValue $HOME/.config/goverlay/initial_values/cascheckValue''', s);

  if  casCheckBox.Checked = false then
  begin
  casSTR := false;
     // Assign cas value to text file
      AssignFile(cascheckValue, '/tmp/goverlay/cascheckValue');
      Rewrite(cascheckValue);
      Writeln(cascheckValue,casSTR);
      CloseFile(cascheckValue);
  end;
  RunCommand('bash -c ''yes | cp -rf /tmp/goverlay/cascheckValue $HOME/.config/goverlay/initial_values/cascheckValue''', s);

  //CAS VALUE
   case castrackbar.Position of
    0:RunCommand('bash -c ''echo "casSharpness=0.0" >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);
    1:RunCommand('bash -c ''echo "casSharpness=0.1" >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);
    2:RunCommand('bash -c ''echo "casSharpness=0.2" >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);
    3:RunCommand('bash -c ''echo "casSharpness=0.3" >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);
    4:RunCommand('bash -c ''echo "casSharpness=0.4" >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);
    5:RunCommand('bash -c ''echo "casSharpness=0.5" >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);
    6:RunCommand('bash -c ''echo "casSharpness=0.6" >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);
    7:RunCommand('bash -c ''echo "casSharpness=0.7" >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);
    8:RunCommand('bash -c ''echo "casSharpness=0.8" >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);
    9:RunCommand('bash -c ''echo "casSharpness=0.9" >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);
    10:RunCommand('bash -c ''echo "casSharpness=1.0" >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);
  end;



  //Toggle Key
  case vkbtogglekeyCombobox.ItemIndex of
    0:RunCommand('bash -c ''echo "toggleKey = Home" >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);
    1:RunCommand('bash -c ''echo "toggleKey = F1" >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);
    2:RunCommand('bash -c ''echo "toggleKey = F2" >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);
    3:RunCommand('bash -c ''echo "toggleKey = F3" >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);
    4:RunCommand('bash -c ''echo "toggleKey = F4" >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);
  end;


   //Count number of active effects
  numeffects := acteffectsListbox.Items.Count;

  //Create temporary variables and store in vkbasalt.conf
  case numeffects of
  0:begin
  if casCheckbox.Checked = false then
  effectsSTR := 'effects = ';

  if casCheckbox.Checked = true then
  effectsSTR := 'effects = cas ';
  end;

 1:begin
         effect0:= acteffectsListbox.Items[0];
         effectsSTR := 'effects = ' +effect0;
    end;
  2:begin
         effect0:= acteffectsListbox.Items[0];
         effect1:= acteffectsListbox.Items[1];
         effectsSTR := 'effects = ' +effect0+':'+effect1;
    end;
  3:begin
         effect0:= acteffectsListbox.Items[0];
         effect1:= acteffectsListbox.Items[1];
         effect2:= acteffectsListbox.Items[2];
         effectsSTR := 'effects = ' +effect0+':'+effect1+':'+effect2;
    end;
  4:begin
         effect0:= acteffectsListbox.Items[0];
         effect1:= acteffectsListbox.Items[1];
         effect2:= acteffectsListbox.Items[2];
         effect3:= acteffectsListbox.Items[3];
         effectsSTR := 'effects = ' +effect0+':'+effect1+':'+effect2+':'+effect3;
    end;
  5:begin
         effect0:= acteffectsListbox.Items[0];
         effect1:= acteffectsListbox.Items[1];
         effect2:= acteffectsListbox.Items[2];
         effect3:= acteffectsListbox.Items[3];
         effect4:= acteffectsListbox.Items[4];
        effectsSTR := 'effects = ' +effect0+':'+effect1+':'+effect2+':'+effect3+':'+effect4;
      end;
  end;


  //Store effects in textfiles

    // Assign effect0 to text file
      AssignFile(effect0Value, '/tmp/goverlay/effect0Value');
      Rewrite(effect0Value);
      Writeln(effect0Value,effect0);
      CloseFile(effect0Value);

      //Save value
      RunCommand('bash -c ''yes | cp -rf /tmp/goverlay/effect0Value >> $HOME/.config/goverlay/initial_values/effect0''', s);


       // Assign effect1 to text file
      AssignFile(effect1Value, '/tmp/goverlay/effect1Value');
      Rewrite(effect1Value);
      Writeln(effect1Value,effect1);
      CloseFile(effect1Value);

       RunCommand('bash -c ''yes | cp -rf /tmp/goverlay/effect1Value >> $HOME/.config/goverlay/initial_values/effect1''', s);

          // Assign effect2 to text file
      AssignFile(effect2Value, '/tmp/goverlay/effect2Value');
      Rewrite(effect2Value);
      Writeln(effect2Value,effect2);
      CloseFile(effect2Value);

       RunCommand('bash -c ''yes | cp -rf /tmp/goverlay/effect2Value >> $HOME/.config/goverlay/initial_values/effect2''', s);

          // Assign effect3 to text file
      AssignFile(effect3Value, '/tmp/goverlay/effect3Value');
      Rewrite(effect3Value);
      Writeln(effect3Value,effect3);
      CloseFile(effect3Value);

        RunCommand('bash -c ''yes | cp -rf /tmp/goverlay/effect3Value >> $HOME/.config/goverlay/initial_values/effect3''', s);

          // Assign effect4 to text file
      AssignFile(effect4Value, '/tmp/goverlay/effect4Value');
      Rewrite(effect4Value);
      Writeln(effect4Value,effect4);
      CloseFile(effect4Value);

      RunCommand('bash -c ''yes | cp -rf /tmp/goverlay/effect4Value >> $HOME/.config/goverlay/initial_values/effect4''', s);


      //Inject contrast adaptive sharpening if checkbox is checked

      if numeffects > 0 then
       if casCheckbox.Checked = true then
           effectsSTR := effectsSTR+':cas';


      // Assign command inside effectsSTR to text file
      AssignFile(effectsValue, '/tmp/goverlay/effectsValue');
      Rewrite(effectsValue);
      Writeln(effectsValue,effectsSTR);
      CloseFile(effectsValue);

      RunCommand('bash -c ''cat /tmp/goverlay/effectsValue >> $HOME/.config/vkBasalt/vkBasalt.conf''', s);


   //Copy generated vkBasalt.conf to goverlay config folder
    RunCommand('bash -c ''yes | cp -rf $HOME/.config/vkBasalt/vkBasalt.conf $HOME/.config/goverlay/vkBasalt.conf ''', s);



  // Delete old initial values and recreate folder
  RunCommand('bash -c ''mkdir -p $HOME/.config/goverlay/initial_values/''', s);
  RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/vkbasalt_toggle''', s);
  RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/casSharpness''', s);
  RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/reshade_git''', s);
  RunCommand('bash -c ''rm -Rf $HOME/.config/goverlay/initial_values/vkbasaltcas''', s);


   //Extract configurations from main config File to the initial_values folder for vkbasalt
   RunCommand('bash -c ''cat $HOME/.config/vkBasalt/vkBasalt.conf | grep -w casSharpness >> $HOME/.config/goverlay/initial_values/casSharpness''', s);
   RunCommand('bash -c ''cat $HOME/.config/vkBasalt/vkBasalt.conf | grep -w cas >> $HOME/.config/goverlay/initial_values/vkbasaltcas''', s);
   RunCommand('bash -c ''cat $HOME/.config/vkBasalt/vkBasalt.conf | grep -w toggleKey >> $HOME/.config/goverlay/initial_values/vkbasalt_toggle''', s);




end;

procedure Tgoverlayform.batteryCheckBoxClick(Sender: TObject);
begin
       //Preview battery
  if batteryCheckbox.Checked=true then
  begin
  batterylabel.Caption:='BATT';
  batteryvaluelabel.Caption:='83%';
  batteryvaluelabel2.Caption:='25.3W';
  end
  else
  begin
  batterylabel.Caption:='';
  batteryvaluelabel.Caption:='';
  batteryvaluelabel2.Caption:='';
  end;
end;


procedure Tgoverlayform.bottomleftSpeedButtonClick(Sender: TObject);
begin
  //Highlight main button
  bottomleftSpeedbutton.ImageIndex:=2;

  //Clear other buttons
  topleftSpeedbutton.ImageIndex:=-1;
  toprightSpeedbutton.ImageIndex:=-1;
  bottomrightSpeedbutton.ImageIndex:=-1;
  topcenterSpeedButton.imageIndex:=-1;
end;

procedure Tgoverlayform.bottomrightSpeedButtonClick(Sender: TObject);
begin
   //Highlight main button
   bottomrightSpeedbutton.ImageIndex:=3;


  //Clear other buttons
  topleftSpeedbutton.ImageIndex:=-1;
  toprightSpeedbutton.ImageIndex:=-1;
  bottomleftSpeedbutton.ImageIndex:=-1;
  topcenterSpeedButton.imageIndex:=-1;
end;

procedure Tgoverlayform.casCheckBoxChange(Sender: TObject);
begin
  if casCheckbox.Checked=true then casTrackbar.Enabled:= true;
end;



procedure Tgoverlayform.casTrackBarChange(Sender: TObject);
begin

  casValueLabel.Caption:= inttostr(casTrackBar.Position);

  //CAS Preview heightImage


    case castrackbar.Position of
     0:begin
    cas00Image.Visible:=true;
    cas01Image.Visible:=false;
    cas02Image.Visible:=false;
    cas03Image.Visible:=false;
    cas04Image.Visible:=false;
    cas05Image.Visible:=false;
    cas06Image.Visible:=false;
    cas07Image.Visible:=false;
    cas08Image.Visible:=false;
    cas09Image.Visible:=false;
    cas10Image.Visible:=false;
    end;
     1:begin
    cas00Image.Visible:=false;
    cas01Image.Visible:=true;
    cas02Image.Visible:=false;
    cas03Image.Visible:=false;
    cas04Image.Visible:=false;
    cas05Image.Visible:=false;
    cas06Image.Visible:=false;
    cas07Image.Visible:=false;
    cas08Image.Visible:=false;
    cas09Image.Visible:=false;
    cas10Image.Visible:=false;
    end;
     2:begin
    cas00Image.Visible:=false;
    cas01Image.Visible:=false;
    cas02Image.Visible:=true;
    cas03Image.Visible:=false;
    cas04Image.Visible:=false;
    cas05Image.Visible:=false;
    cas06Image.Visible:=false;
    cas07Image.Visible:=false;
    cas08Image.Visible:=false;
    cas09Image.Visible:=false;
    cas10Image.Visible:=false;
    end;
     3:begin
    cas00Image.Visible:=false;
    cas01Image.Visible:=false;
    cas02Image.Visible:=false;
    cas03Image.Visible:=true;
    cas04Image.Visible:=false;
    cas05Image.Visible:=false;
    cas06Image.Visible:=false;
    cas07Image.Visible:=false;
    cas08Image.Visible:=false;
    cas09Image.Visible:=false;
    cas10Image.Visible:=false;
    end;
     4:begin
    cas00Image.Visible:=false;
    cas01Image.Visible:=false;
    cas02Image.Visible:=false;
    cas03Image.Visible:=false;
    cas04Image.Visible:=true;
    cas05Image.Visible:=false;
    cas06Image.Visible:=false;
    cas07Image.Visible:=false;
    cas08Image.Visible:=false;
    cas09Image.Visible:=false;
    cas10Image.Visible:=false;
    end;
     5:begin
    cas00Image.Visible:=false;
    cas01Image.Visible:=false;
    cas02Image.Visible:=false;
    cas03Image.Visible:=false;
    cas04Image.Visible:=false;
    cas05Image.Visible:=true;
    cas06Image.Visible:=false;
    cas07Image.Visible:=false;
    cas08Image.Visible:=false;
    cas09Image.Visible:=false;
    cas10Image.Visible:=false;
    end;
     6:begin
    cas00Image.Visible:=false;
    cas01Image.Visible:=false;
    cas02Image.Visible:=false;
    cas03Image.Visible:=false;
    cas04Image.Visible:=false;
    cas05Image.Visible:=false;
    cas06Image.Visible:=true;
    cas07Image.Visible:=false;
    cas08Image.Visible:=false;
    cas09Image.Visible:=false;
    cas10Image.Visible:=false;
    end;
     7:begin
    cas00Image.Visible:=false;
    cas01Image.Visible:=false;
    cas02Image.Visible:=false;
    cas03Image.Visible:=false;
    cas04Image.Visible:=false;
    cas05Image.Visible:=false;
    cas06Image.Visible:=false;
    cas07Image.Visible:=true;
    cas08Image.Visible:=false;
    cas09Image.Visible:=false;
    cas10Image.Visible:=false;
    end;
     8:begin
    cas00Image.Visible:=false;
    cas01Image.Visible:=false;
    cas02Image.Visible:=false;
    cas03Image.Visible:=false;
    cas04Image.Visible:=false;
    cas05Image.Visible:=false;
    cas06Image.Visible:=false;
    cas07Image.Visible:=false;
    cas08Image.Visible:=true;
    cas09Image.Visible:=false;
    cas10Image.Visible:=false;
    end;
     9:begin
    cas00Image.Visible:=false;
    cas01Image.Visible:=false;
    cas02Image.Visible:=false;
    cas03Image.Visible:=false;
    cas04Image.Visible:=false;
    cas05Image.Visible:=false;
    cas06Image.Visible:=false;
    cas07Image.Visible:=false;
    cas08Image.Visible:=false;
    cas09Image.Visible:=true;
    cas10Image.Visible:=false;
    end;
     10:begin
    cas00Image.Visible:=false;
    cas01Image.Visible:=false;
    cas02Image.Visible:=false;
    cas03Image.Visible:=false;
    cas04Image.Visible:=false;
    cas05Image.Visible:=false;
    cas06Image.Visible:=false;
    cas07Image.Visible:=false;
    cas08Image.Visible:=false;
    cas09Image.Visible:=false;
    cas10Image.Visible:=true;
    end;
  end;
end;

procedure Tgoverlayform.compacthudBitBtnClick(Sender: TObject);
begin
  //Check compact hud options
   cpuavrloadCheckbox.Checked:=true;
   cputempCheckbox.Checked:=true;
   cpuloadcoreCheckbox.Checked:=false;
   gpuavrloadCheckbox.Checked:=true;
   gputempCheckbox.Checked:=true;
   gpufreqCheckbox.Checked:=false;
   diskioCheckbox.Checked:=false;
   vramusageCheckbox.Checked:=true;
   ramusageCheckbox.Checked:=true;
   swapusageCheckbox.Checked:=false;
   frametimegraphCheckbox.Checked:=true;
   timeCheckbox.Checked:=false;
   archCheckbox.Checked:=false;
   driverversionCheckbox.Checked:=false;
   gpupowerCheckBox.Checked:=false;
   gpumodelCheckBox.Checked:=false;
   gpumemfreqCheckBox.Checked:=false;
   engineversionCheckBox.Checked:=false;
   wineCheckbox.Checked:=false;
   gpuloadcolorCheckbox.Checked:=true;
   cpuloadcolorCheckbox.Checked:=true;
   cpupowerCheckbox.Checked:=false;
   cpufreqCheckbox.Checked:=false;
   hudversionCheckbox.Checked:=false;
   fpsCheckbox.Checked:=true;

  showfpslimCheckbox.Checked:=false;
  batteryCheckbox.Checked:=false;
  resolutionCheckbox.Checked:=false;
  vkbasaltstatusCheckbox.Checked:=false;
  gamemodestatusCheckbox.Checked:=false;
  sessionCheckbox.Checked:=false;
  distroinfoCheckbox.Checked:=false;
  homepartCheckbox.Checked:=false;

   gpuloadgraphBitbtn.imageindex:=3;
   gputempgraphBitbtn.imageindex:=3;
   gpucfgraphBitbtn.imageindex:=3;
   gpumfgraphBitbtn.imageindex:=3;
   vramgraphBitbtn.imageindex:=3;
   cpuloadgraphBitbtn.imageindex:=3;
   cputempgraphBitbtn.imageindex:=3;
   ramgraphBitbtn.imageindex:=3;

   //Preview compact hud options
   cpulabel.Caption:='CPU';
   cpuusagelabel.Caption:='51%';
   cputemplabel.Caption:='71ºC';
   gpulabel.Caption:='GPU';
   gpuusagelabel.Caption:='95%';
   gpulabel.Caption:='GPU';
   gputemplabel.Caption:='82ºC';
   vramlabel.Caption:='VRAM';
   vramusagelabel.Caption:='2.56GB';
   ramlabel.Caption:='RAM';
   ramusagelabel.Caption:='5.99GB';
   frametimelabel.Caption:='Frametime';
   frametimelabel2.Caption:='16.6ms';
   frametimegraphlabel.Caption:='--------------------------------------';
   gpuusagelabel.Font.Color:=gpuload3Colorbutton.ButtonColor;
   cpuusagelabel.Font.Color:=cpuload2Colorbutton.ButtonColor;

   timelabel.Caption:='';
   iordrwlabel.caption:='';
   iordvaluelabel.caption:='';
   iorwvaluelabel.caption:='';
   gpuclocklabel.caption:='';
   archlabel.caption:='';
   gpunamelabel.caption:='';
   driverversionlabel.caption:='';
   gpupowerlabel.Caption:='';
   gpumemfreqlabel.Caption:='';
   engineversionlabel.Caption:='';
   winelabel.Caption:='';
   cpufreqlabel.Caption:='';
   cpupowerlabel.Caption:='';
   hudversionlabel.Caption:='';
   swapusagelabel.Caption:='';

  fpslimitlabel.Caption:='';
  fpslimitvaluelabel.Caption:='';
  batterylabel.Caption:='';
  batteryvaluelabel.Caption:='';
  batteryvaluelabel2.Caption:='';
  resolutionlabel.Caption:='';
  resolutionvaluelabel.Caption:='';
  vkbasaltstatuslabel.Caption:='';
  vkbasaltstatusvaluelabel.Caption:='';
  gamemodestatuslabel.Caption:='';
  gamemodestatusvaluelabel.Caption:='';
  sessionlabel.Caption:='';
  distroinfolabel.Caption:='';
  distroinfolabel2.Caption:='';
  homepartitionlabel.Caption:='';
end;

procedure Tgoverlayform.basaltgeSpeedButtonClick(Sender: TObject);
begin
     case basaltgeSpeedButton.imageIndex of
     0: begin
       basaltgeSpeedButton.ImageIndex:=1; //switch button position
       RunCommand('bash -c ''yes | cp -rf $HOME/.profile $HOME/.profile_vkbasalt_bkp''', s); //backup original .profile file
       RunCommand('bash -c ''yes | cp -rf $HOME/.bash_profile $HOME/.bash_profile_vkbasalt_bkp''', s); //backup original .bash_profile file
       RunCommand('bash -c ''echo "export ENABLE_VKBASALT=1" >> $HOME/.profile''', s);  // Activate vkBasalt globally for vulkan apps
       RunCommand('bash -c ''echo "export ENABLE_VKBASALT=1" >> $HOME/.bash_profile''', s);  // Workaround to Activate vkBasalt globally for vulkan apps on some distros
       RunCommand('bash -c ''notify-send -i /usr/share/icons/hicolor/128x128/apps/goverlay.png "vkBasalt Global Enable Activated" "Every Vulkan application will have these effects applied"''', s); // Popup a notification
       showmessage ('Restart your system to take effect');
     end;
     1: begin
        basaltgeSpeedButton.ImageIndex:=0;
        RunCommand('bash -c ''yes | cp -rf $HOME/.profile_vkbasalt_bkp $HOME/.profile''', s);  //restore original .profile file
        RunCommand('bash -c ''yes | cp -rf $HOME/.bash_profile_vkbasalt_bkp $HOME/.bash_profile''', s);  //restore original .profile file
        RunCommand('bash -c ''notify-send -i /usr/share/icons/hicolor/128x128/apps/goverlay.png "Deactivated"''', s); // Popup a notification
        showmessage ('Restart your system to take effect');
     end;

  end;
end;

procedure Tgoverlayform.basaltrunBitBtnClick(Sender: TObject);
begin
    //Run vkcube
  if mangohuddependencyVALUE=1 then
      RunCommand('bash -c ''ENABLE_VKBASALT=1 mangohud vkcube''', s)
  else
      RunCommand('bash -c ''ENABLE_VKBASALT=1 vkcube''', s)
end;

procedure Tgoverlayform.archCheckBoxClick(Sender: TObject);
begin
       //Preview Arch
     if archCheckbox.Checked=true then
       archlabel.Caption:='64bit'
     else
       archlabel.Caption:='';
end;

procedure Tgoverlayform.audiobitrateComboboxKeyPress(Sender: TObject;
  var Key: char);
begin
    //Block keypress on combobox
  key:=#0;
end;

procedure Tgoverlayform.aacprofileComboboxKeyPress(Sender: TObject; var Key: char
  );
begin
    //Block keypress on combobox
  key:=#0;
end;

procedure Tgoverlayform.audiodevComboboxKeyPress(Sender: TObject; var Key: char
  );
begin
    //Block keypress on combobox
  key:=#0;
end;

procedure Tgoverlayform.audiosampComboboxKeyPress(Sender: TObject; var Key: char
  );
begin
    //Block keypress on combobox
  key:=#0;
end;

procedure Tgoverlayform.autoaudiobitrateCheckBoxChange(Sender: TObject);
begin
         if autoaudiobitrateCheckbox.Checked = true then

       begin
       // Disable audio bitrate controls
          audiobitrateCombobox.Enabled:=false;
       end;

       if autoaudiobitrateCheckbox.Checked = false then
       begin
          // Enable audio bitrate controls
             audiobitrateCombobox.Enabled:=true;
       end;
end;

procedure Tgoverlayform.autoresCheckBoxChange(Sender: TObject);
begin
         if autoresCheckbox.Checked = true then
       begin
          //Change video preview
          fullscreenShape.Visible:= true;
          customresShape.Visible:= false;

          // Disable custom resolution controls
          reswidthSpinedit.Enabled := false;
          resheightSpinedit.Enabled := false;

       end;

       if autoresCheckbox.Checked = false then
       begin
           //Change video preview
          fullscreenShape.Visible:= false;
          customresShape.Visible:= true;

          // Disable custom resolution controls
          reswidthSpinedit.Enabled := true;
          resheightSpinedit.Enabled := true;

       end;
 end;



procedure Tgoverlayform.autoscaleCheckBoxChange(Sender: TObject);
begin
       if autoscaleCheckbox.Checked = true then

       begin
       // Disable custom scale controls
          scalewidthSpinedit.Enabled := false;
          scaleheightSpinedit.Enabled := false;
       end;

       if autoscaleCheckbox.Checked = false then
       begin
       // Enable custom  scale controls
       scalewidthSpinedit.Enabled := true;
       scaleheightSpinedit.Enabled := true;
       end;
end;

procedure Tgoverlayform.autovideobitrateCheckBoxChange(Sender: TObject);
begin
    if autovideobitrateCheckbox.Checked = true then
   begin
        videobitrateTrackBar.Enabled := false;
        videobitrateLabel.Caption:= '';
   end;


    if autovideobitrateCheckbox.Checked = false then
     begin
          videobitrateTrackBar.Enabled := true;
          videobitrateLabel.Caption:=inttostr (videobitrateTrackBar.Position)+' Mbps'; //video bitrate value
     end;
end;

procedure Tgoverlayform.autovideoqualityCheckBoxChange(Sender: TObject);
begin
  if autovideoqualityCheckbox.Checked = true then
   begin
        videoqualityTrackBar.Enabled := false;
        videoqualityLabel.Caption:= '';
   end;


    if autovideoqualityCheckbox.Checked = false then
     begin
          videoqualityTrackBar.Enabled := true;
          videoqualityLabel.Caption:=inttostr (videoqualityTrackBar.Position); //compress quality value
     end;

end;



procedure Tgoverlayform.addBitBtnClick(Sender: TObject);
begin

  // Add selected effect to active effects listbox

  case aveffectslistbox.Itemindex of
0:      acteffectslistbox.Items.Add     ('3DFX');
1:      acteffectslistbox.Items.Add     ('AdaptiveFog');
2:      acteffectslistbox.Items.Add     ('AdaptiveSharpen');
3:	acteffectslistbox.Items.Add	('AmbientLight');
4:	acteffectslistbox.Items.Add	('ASCII');
5:	acteffectslistbox.Items.Add	('AspectRatio');
6:	acteffectslistbox.Items.Add	('Bloom');
7:	acteffectslistbox.Items.Add	('Border');
8:	acteffectslistbox.Items.Add	('Cartoon');
9:	acteffectslistbox.Items.Add	('Chromakey');
10:	acteffectslistbox.Items.Add	('ChromaticAberration');
11:	acteffectslistbox.Items.Add	('CinematicDOF');
12:	acteffectslistbox.Items.Add	('Clarity');
13:	acteffectslistbox.Items.Add	('ColorMatrix');
14:	acteffectslistbox.Items.Add	('Colourfulness');
15:	acteffectslistbox.Items.Add	('CRT');
16:	acteffectslistbox.Items.Add	('Curves');
17:	acteffectslistbox.Items.Add	('Daltonize');
18:	acteffectslistbox.Items.Add	('Deband');
19:	acteffectslistbox.Items.Add	('Denoise');
20:	acteffectslistbox.Items.Add	('Depth3D');
21:	acteffectslistbox.Items.Add	('Depth Haze');
22:	acteffectslistbox.Items.Add	('DisplayDepth');
23:	acteffectslistbox.Items.Add	('DOF');
24:	acteffectslistbox.Items.Add	('DPX');
25:	acteffectslistbox.Items.Add	('Emphasize');
26:	acteffectslistbox.Items.Add	('EyeAdaption');
27:	acteffectslistbox.Items.Add	('FakeHDR');
28:	acteffectslistbox.Items.Add	('FakeMotion Blur');
29:	acteffectslistbox.Items.Add	('FilmGrain');
30:	acteffectslistbox.Items.Add	('FilmGrain2');
31:	acteffectslistbox.Items.Add	('FilmicAnamorphSharpen');
32:	acteffectslistbox.Items.Add	('FilmicPass');
33:	acteffectslistbox.Items.Add	('FineSharp');
34:	acteffectslistbox.Items.Add	('FXAA');
35:	acteffectslistbox.Items.Add	('GaussianBlur');
36:	acteffectslistbox.Items.Add	('Glitch');
37:	acteffectslistbox.Items.Add	('HighPassSharpen');
38:	acteffectslistbox.Items.Add	('HQ4X');
39:	acteffectslistbox.Items.Add	('HSLShift');
40:	acteffectslistbox.Items.Add	('Layer');
41:	acteffectslistbox.Items.Add	('Levels');
42:	acteffectslistbox.Items.Add	('Levels Plus');
43:	acteffectslistbox.Items.Add	('LiftGammaGain');
44:	acteffectslistbox.Items.Add	('LightDOF');
45:	acteffectslistbox.Items.Add	('LumaSharpen');
46:	acteffectslistbox.Items.Add	('LUT');
47:	acteffectslistbox.Items.Add	('MagicBloom');
48:	acteffectslistbox.Items.Add	('Monochrome');
49:	acteffectslistbox.Items.Add	('MultiLUT');
50:	acteffectslistbox.Items.Add	('MXAO');
51:	acteffectslistbox.Items.Add	('NightVision');
52:	acteffectslistbox.Items.Add	('Nostalgia');
53:	acteffectslistbox.Items.Add	('PerfectPerspective');
54:	acteffectslistbox.Items.Add	('PPFX_Bloom');
55:	acteffectslistbox.Items.Add	('PPFX_Godrays');
56:	acteffectslistbox.Items.Add	('Prism');
57:	acteffectslistbox.Items.Add	('ReflectiveBumpMapping');
58:	acteffectslistbox.Items.Add	('Sepia');
59:	acteffectslistbox.Items.Add	('SMAA');
60:	acteffectslistbox.Items.Add	('SplitScreen');
61:	acteffectslistbox.Items.Add	('StageDepth');
62:	acteffectslistbox.Items.Add	('SurfaceBlur');
63:	acteffectslistbox.Items.Add	('Technicolor');
64:	acteffectslistbox.Items.Add	('Technicolor2');
65:	acteffectslistbox.Items.Add	('TiltShift');
66:	acteffectslistbox.Items.Add	('Tonemap');
67:	acteffectslistbox.Items.Add	('TriDither');
68:	acteffectslistbox.Items.Add	('UIDetect');
69:	acteffectslistbox.Items.Add	('UIMask');
70:	acteffectslistbox.Items.Add	('Vibrance');
71:	acteffectslistbox.Items.Add	('Vignette');
  end;

end;


procedure Tgoverlayform.crosshairsizeBitBtnClick(Sender: TObject);
begin
  crosshairsizeForm.show;
end;

procedure Tgoverlayform.customcommandEditChange(Sender: TObject);
begin
   customcommandlabel.Caption:=customcommandEdit.Text;
end;

procedure Tgoverlayform.distroinfoCheckBoxClick(Sender: TObject);
begin
      //Preview distro info
  if distroinfoCheckbox.Checked=true then
  begin
  distroinfolabel.Caption:='Distribution info';
  distroinfolabel2.Caption:='Kernel:      version';
  end
  else
  begin
  distroinfolabel.Caption:='';
  distroinfolabel2.Caption:='';
  end;
end;




procedure Tgoverlayform.driverversionCheckBoxChange(Sender: TObject);
begin
  //Preview Driver Version
  if driverversionCheckbox.Checked=true then
  driverversionlabel.Caption:='NVIDIA 440.18.00'
  else
  driverversionlabel.Caption:='';
end;

procedure Tgoverlayform.engineColorButtonColorChanged(Sender: TObject);
begin
    // engine color
    engineversionlabel.font.Color:=enginecolorButton.ButtonColor;
    vulkanlabel.font.Color:=enginecolorButton.ButtonColor;
    gpunamelabel.font.Color:=enginecolorButton.ButtonColor;
    driverversionlabel.font.Color:=enginecolorButton.ButtonColor;
    archlabel.font.Color:=enginecolorButton.ButtonColor;
    frametimelabel.font.Color:=enginecolorButton.ButtonColor;

    //Use function SColorToHtmlColor from unit ATStringProc_htmlColor to change color format to RGB and write value to label
    enginecolorhtml := SColorToHtmlColor(enginecolorButton.ButtonColor);
end;

procedure Tgoverlayform.engineversionCheckBoxClick(Sender: TObject);
begin
  //PREVIEW Engine Version
  if engineversionCheckbox.Checked=true then
     engineversionlabel.Caption:='1.2.131'
  else
     engineversionlabel.Caption:=''  ;
  end;


procedure Tgoverlayform.FontcolorButtonColorChanged(Sender: TObject);
begin
   // PREVIEW - Change Font color labels
    gpuusagelabel.font.Color:=FontcolorButton.ButtonColor;
    gputemplabel.font.Color:=FontcolorButton.ButtonColor;
    gpuclocklabel.font.Color:=FontcolorButton.ButtonColor;
    cpuusagelabel.font.Color:=FontcolorButton.ButtonColor;
    cputemplabel.font.Color:=FontcolorButton.ButtonColor;
    iordvaluelabel.font.Color:=FontcolorButton.ButtonColor;
    iorwvaluelabel.font.Color:=FontcolorButton.ButtonColor;
    vramusagelabel.font.Color:=FontcolorButton.ButtonColor;
    ramusagelabel.font.Color:=FontcolorButton.ButtonColor;
    swapusagelabel.font.Color:=FontcolorButton.ButtonColor;
    vulkanfpslabel.font.Color:=FontcolorButton.ButtonColor;
    vulkanftimelabel.font.Color:=FontcolorButton.ButtonColor;
    frametimelabel2.font.Color:=FontcolorButton.ButtonColor;
    gpupowerlabel.font.Color:=FontcolorButton.ButtonColor;
    gpumemfreqlabel.font.Color:=FontcolorButton.ButtonColor;

    //Use function SColorToHtmlColor from unit ATStringProc_htmlColor to change color format to RGB and write value to label
    hudfontcolorhtml := SColorToHtmlColor(FontcolorButton.ButtonColor);
end;

procedure Tgoverlayform.fpsCheckBoxClick(Sender: TObject);
begin
     //Preview FPS
     if fpsCheckbox.Checked=true then
      begin
      vulkanlabel.visible:=true;
      vulkanfpslabel.visible:=true;
      end;

     if fpsCheckbox.Checked=false then
      begin
      vulkanlabel.visible:=false;
      vulkanfpslabel.visible:=false;
      end;
end;

procedure Tgoverlayform.framegraphRadioButtonChange(Sender: TObject);
begin

end;

procedure Tgoverlayform.framegraphRadioButtonClick(Sender: TObject);
begin
      //Preview frame time graph
     if framegraphRadiobutton.Checked=true then
     begin
       frametimelabel.Caption:='Frametime';
       frametimelabel2.Caption:='16.6ms';
       frametimegraphlabel.Caption:='--------------------------------------'
     end
   else
     begin
       frametimelabel.Caption:='';
       frametimelabel2.Caption:='';
       frametimegraphlabel.Caption:=''
     end;
end;

procedure Tgoverlayform.framehistogramRadioButtonClick(Sender: TObject);
begin
   //Preview frame time graph
     if framehistogramRadiobutton.Checked=true then
     begin
       frametimelabel.Caption:='Frametime';
       frametimelabel2.Caption:='16.6ms';
       frametimegraphlabel.Caption:='--||------||||||||||||||||||||------|||----'
     end
   else
     begin
       frametimelabel.Caption:='';
       frametimelabel2.Caption:='';
       frametimegraphlabel.Caption:=''
     end;
end;

procedure Tgoverlayform.framerateComboboxKeyPress(Sender: TObject; var Key: char
  );
begin
    //Block keypress on combobox
  key:=#0;
end;

procedure Tgoverlayform.gamemodestatusCheckBoxClick(Sender: TObject);
begin
  //Preview gamemode
  if gamemodestatusCheckbox.Checked=true then
  begin
  gamemodestatuslabel.Caption:='GAMEMODE';
  gamemodestatusvaluelabel.Caption:='ON';
  end
  else
  begin
  gamemodestatuslabel.Caption:='';
  gamemodestatusvaluelabel.Caption:='';
  end;
end;




procedure Tgoverlayform.hudbackgroundColorButtonColorChanged(Sender: TObject);
begin
   // Change backgroud preview color
    hudbackgroundShape.brush.Color:=hudbackgroundcolorButton.ButtonColor;

    //Use function SColorToHtmlColor from unit ATStringProc_htmlColor to change color format to RGB and write value to label
    hudbackgroundcolorhtml := SColorToHtmlColor(hudbackgroundcolorButton.ButtonColor);
end;

procedure Tgoverlayform.cpuColorButtonColorChanged(Sender: TObject);
begin
    // Change color of labels
    cpulabel.font.Color:=cpucolorButton.ButtonColor;

    //Use function SColorToHtmlColor from unit ATStringProc_htmlColor to change color format to RGB and write value to label
    cpucolorhtml := SColorToHtmlColor(cpucolorButton.ButtonColor);
end;


procedure Tgoverlayform.cpuavrloadCheckBoxClick(Sender: TObject);
begin
   //Preview CPU Average Load
  if cpuavrloadCheckbox.Checked=true then
  begin
  cpulabel.Caption:='CPU';
  cpuusagelabel.Caption:='51%'
  end
  else
  begin
  cpulabel.Caption:='';
  cpuusagelabel.Caption:='';
  end;
end;


procedure Tgoverlayform.cputempCheckBoxClick(Sender: TObject);
begin
  //Preview CPU temperature
  if cputempCheckbox.Checked=true then
  begin
  cpulabel.Caption:='CPU';
  cputemplabel.Caption:='44ºC';
  end
  else
  begin
  cputemplabel.Caption:='';
  end;
end;

procedure Tgoverlayform.diskioCheckBoxClick(Sender: TObject);
begin
      //Preview DISK IO
  if diskioCheckbox.Checked=true then
    begin
     iordrwlabel.caption:='IO RF/RW';
     iordvaluelabel.caption:='32MiB/s';
     iorwvaluelabel.caption:='22MiB/s';
    end
  else
    begin
     iordrwlabel.caption:='';
     iordvaluelabel.caption:='';
     iorwvaluelabel.caption:='';
  end;
end;

procedure Tgoverlayform.frametimegraphColorButtonColorChanged(Sender: TObject);
begin
      // Frame Time Graph color
    frametimegraphlabel.font.Color:=frametimegraphcolorButton.ButtonColor;

    //Use function SColorToHtmlColor from unit ATStringProc_htmlColor to change color format to RGB and write value to label
    frametimegraphcolorhtml := SColorToHtmlColor(frametimegraphcolorButton.ButtonColor);
end;

procedure Tgoverlayform.hudtitleEditChange(Sender: TObject);
begin
  hudtitlelabel.Caption:=hudtitleEdit.Text;
end;

procedure Tgoverlayform.hudtranspBitBtnClick(Sender: TObject);
begin
  hudbackgroundForm.show;
end;

procedure Tgoverlayform.intelpowerfixBitBtnClick(Sender: TObject);
begin
  RunCommand('bash -c ''pkexec chmod o+r /sys/class/powercap/intel-rapl\:0/energy_uj''', s); // Enable reading for intel power drawn
  intelpowerfixBitBtn.ImageIndex:=0;
end;


procedure Tgoverlayform.iordrwColorButtonColorChanged(Sender: TObject);
begin
    // Change color of DISK IO label
    iordrwlabel.font.Color:=iordrwColorButton.ButtonColor;

    //Use function SColorToHtmlColor from unit ATStringProc_htmlColor to change color format to RGB and write value to label
    iordrwcolorhtml := SColorToHtmlColor(iordrwColorButton.ButtonColor);
end;

procedure Tgoverlayform.runBitBtnClick(Sender: TObject);
begin
  //Run vkcube and glxgears
  if vkbasaltdependencyVALUE=1 then
      RunCommand('bash -c ''ENABLE_VKBASALT=1 mangohud vkcube & mangohud glxgears''', s)
  else
      RunCommand('bash -c ''mangohud vkcube & mangohud glxgears''', s)
end;


procedure Tgoverlayform.aboutBitBtnClick(Sender: TObject);
begin
  aboutForm.show;
end;




procedure Tgoverlayform.FormCreate(Sender: TObject);
begin
  //Centralize window
  Left:=(Screen.Width-Width)  div 2;
  Top:=(Screen.Height-Height) div 2;

  //Clear hud preview options
  cpulabel.Caption:='';
  cpuusagelabel.Caption:='';
  cputemplabel.Caption:='';
  gpulabel.Caption:='';
  gpuusagelabel.Caption:='';
  gpulabel.Caption:='';
  gputemplabel.Caption:='';
  vramlabel.Caption:='';
  vramusagelabel.Caption:='';
  swapusagelabel.Caption:='';
  ramlabel.Caption:='';
  ramusagelabel.Caption:='';
  frametimelabel.Caption:='';
  frametimelabel2.Caption:='';
  frametimegraphlabel.Caption:='';
  timelabel.Caption:='';
  iordrwlabel.caption:='';
  iordvaluelabel.caption:='';
  iorwvaluelabel.caption:='';
  gpuclocklabel.caption:='';
  hudversionlabel.caption:='';
  archlabel.caption:='';
  spotify1label.caption:='';
  spotify2label.caption:='';
  spotify3label.caption:='';
  gpunamelabel.caption:='';
  driverversionlabel.caption:='';
  gpupowerlabel.caption:='';
  gpumemfreqlabel.caption:='';
  winelabel.Caption:='';
  cpupowerlabel.Caption:='';
  cpufreqlabel.Caption:='';

  fpslimitlabel.Caption:='';
  fpslimitvaluelabel.Caption:='';
  batterylabel.Caption:='';
  batteryvaluelabel.Caption:='';
  batteryvaluelabel2.Caption:='';
  resolutionlabel.Caption:='';
  resolutionvaluelabel.Caption:='';
  vkbasaltstatuslabel.Caption:='';
  vkbasaltstatusvaluelabel.Caption:='';
  gamemodestatuslabel.Caption:='';
  gamemodestatusvaluelabel.Caption:='';
  sessionlabel.Caption:='';
  distroinfolabel.Caption:='';
  distroinfolabel2.Caption:='';
  homepartitionlabel.Caption:='';

  //Initialize Variables with stock Mangohud colors
  cpucolorhtml :='#2e97cb';
  gpucolorhtml :='#2e9762';
  iordrwcolorhtml :='#a491d3';
  vramcolorhtml :='#ad64c1';
  ramcolorhtml :='#c26693';
  //swapcolorhtml :='#c26693';
  frametimegraphcolorhtml := '#00ff00';
  crosshaircolorhtml := '#000000';
  hudbackgroundcolorhtml := '#020202';
  hudfontcolorhtml := '#ffffff';
  enginecolorhtml := '#eb5b5b';
  winecolorhtml := '#eb5b5b';
  mediacolorhtml := '#ffffff' ;

  // Initialize vkBasalt default value
  cas04Image.Visible:=true;
  effectssum:=0;

  // Initialize menu selections
  mangohudsel := true;
  mangohudPanel.Visible:=true;
  vkbasaltsel := false;
  vkbasaltPanel.Visible:=false;
  replaysel := false;
  replayPanel.Visible:=false;

  //Initial trackbar labels value
  videoqualityLabel.Caption:=inttostr (videoqualityTrackBar.Position); //video quality value
  videobitrateLabel.Caption:=inttostr (videobitrateTrackBar.Position)+' Mbps'; //video bitrate value
  videogopLabel.Caption:=inttostr (videogopTrackBar.Position); //video bitrate value
  casValueLabel.Caption:=inttostr (casTrackbar.Position); //cas value


  //Create temporary folder and files for goverlay
  RunCommand('bash -c ''mkdir -p /tmp/goverlay/''', s);
  RunCommand('bash -c ''mkdir -p /tmp/goverlay/initial_values/''', s);
  RunCommand('bash -c ''touch /tmp/goverlay/togglestateValue''', s);

  //Create goverlay config folder
  RunCommand('bash -c ''mkdir -p $HOME/.config/goverlay/initial_values/''', s);

  //Erase dependecy files check
  RunCommand('bash -c ''rm /tmp/goverlay/dependency_mangohud''', s);
  RunCommand('bash -c ''rm /tmp/goverlay/dependency_vkbasalt''', s);
  RunCommand('bash -c ''rm /tmp/goverlay/dependency_replay''', s);


       //Determine toggle position - MangoHUD

         //Read file .profile and store result in tmp folder
         RunCommand('bash -c ''cat $HOME/.profile | grep MANGOHUD=1 >> /tmp/goverlay/togglestateValue''', s);

         // Assign Text file to variable
         AssignFile(togglestateValueVAR, '/tmp/goverlay/togglestateValue'); //
         Reset(togglestateValueVAR);
         Readln(togglestateValueVAR,togglestateValueSTR); //Assign Text file to String
         CloseFile(togglestateValueVAR);

         // Read String with toggle value
         if togglestateValueSTR = 'export MANGOHUD=1' then
            geSpeedbutton.imageIndex:=1
         else
            geSpeedbutton.imageIndex:=0;



      //Determine toggle position - vkBasalt

         //Read file .profile and store result in tmp folder
         RunCommand('bash -c ''cat $HOME/.profile | grep ENABLE_VKBASALT=1 >> /tmp/goverlay/togglebasaltstateValue''', s);

          // Assign Text file to variable
          AssignFile(toggleBasaltstateValueVAR, '/tmp/goverlay/togglebasaltstateValue'); //
          Reset(toggleBasaltstateValueVAR);
          Readln(toggleBasaltstateValueVAR,toggleBasaltstateValueSTR); //Assign Text file to String
          CloseFile(toggleBasaltstateValueVAR);

          // Read String with toggle value
          if toggleBasaltstateValueSTR = 'export ENABLE_VKBASALT=1' then
             basaltgeSpeedbutton.imageIndex:=1
          else
             basaltgeSpeedbutton.imageIndex:=0;



       //Determine toggle position - Replay-Sorcery

          //Read file .desktop file and store result in tmp folder
          RunCommand('bash -c ''cat $HOME/.config/autostart/replay.desktop | grep Name=replay-sourcery >> /tmp/goverlay/replaytogglestateValue''', s);

          // Assign Text file to variable
          AssignFile(replaytogglestateValueVAR, '/tmp/goverlay/replaytogglestateValue'); //
          Reset(replaytogglestateValueVAR);
          Readln(replaytogglestateValueVAR,replaytogglestateValueSTR); //Assign Text file to String
          CloseFile(replaytogglestateValueVAR);

          // Read String with toggle value
          if replaytogglestateValueSTR = 'Name=replay-sourcery' then
             replaygeSpeedButton.imageIndex:=1
          else
             replaygeSpeedButton.imageIndex:=0;



   //Define user Home Folder and store in variable userhomepathVAR

    //Read file $HOME variable and store result in tmp folder text file
     RunCommand('bash -c ''echo $HOME >> /tmp/goverlay/userhomepath''', s);

    // Assign Text file to variable
     AssignFile(userhomepathVAR, '/tmp/goverlay/userhomepath'); //
     Reset(userhomepathVAR);
     Readln(userhomepathVAR,userhomepathSTR); //Assign Text file to String
     CloseFile(userhomepathVAR);

   //Stock folder for Mangohud logging
   destinationfolder := userhomepathSTR;
   destfolderpathLabel.Caption:=destinationfolder;

   //Stock folder replay videos
   destinationfolder := userhomepathSTR;
   saveclipEdit.Text:=destinationfolder;



   //Determine Mangohud dependency status

          //locate MangoHud and store result in tmp folder
          RunCommand('bash -c ''find /usr/share/vulkan/implicit_layer.d/MangoHud.json >> /tmp/goverlay/dependency_mangohud''', s);

          // Assign Text file dependency_mangohud to variable mangohudVAR
          AssignFile(mangohudVAR, '/tmp/goverlay/dependency_mangohud');
          Reset(mangohudVAR);
          Readln(mangohudVAR,mangohudSTR); //Assign Text file to String
          CloseFile(mangohudVAR);

          // Read String and store value on mangohuddependencyVALUE based on result
          if mangohudSTR = '/usr/share/vulkan/implicit_layer.d/MangoHud.json' then
          mangohuddependencyVALUE := 1
          else
          mangohuddependencyVALUE := 0;


   //Determine vkBasalt dependency staus

           //locate vkBasalt and store result in tmp folder
           RunCommand('bash -c ''find /usr/share/vulkan/implicit_layer.d/vkBasalt.json >> /tmp/goverlay/dependency_vkbasalt''', s);

           // Assign Text file dependency_mangohud to variable mangohudVAR
           AssignFile(vkbasaltVAR, '/tmp/goverlay/dependency_vkbasalt');
           Reset(vkbasaltVAR);
           Readln(vkbasaltVAR,vkbasaltSTR); //Assign Text file to String
           CloseFile(vkbasaltVAR);

           // Read String and store value on vkbasaltdependencyVALUE based on result
           if vkbasaltSTR = '/usr/share/vulkan/implicit_layer.d/vkBasalt.json' then
           vkbasaltdependencyVALUE := 1
           else
           vkbasaltdependencyVALUE := 0;


   //Determine replay-sorcery dependency staus

            //locate replay-sorcey and store result in tmp folder
            RunCommand('bash -c ''which replay-sorcery >> /tmp/goverlay/dependency_replay''', s);

            // Assign Text file dependency_replay to variable replayVAR
            AssignFile(replayVAR, '/tmp/goverlay/dependency_replay');
            Reset(replayVAR);
            Readln(replayVAR,replaySTR); //Assign Text file to String
            CloseFile(replayVAR);

            // Read String and store value on replaydependencyVALUE based on result
            if replaySTR <> '' then
               replaydependencyVALUE := 1
               else
               replaydependencyVALUE := 0;


        //Print Dependency status information

        //Missing single dependency
        if (mangohuddependencyVALUE = 1) and ( vkbasaltdependencyVALUE = 1) and ( replaydependencyVALUE = 1 ) then
        begin
        dependenciesLabel.Caption:= '    All dependencies OK';
        dependencieSpeedButton.ImageIndex := 0;
        end;

        if (mangohuddependencyVALUE = 0) and ( vkbasaltdependencyVALUE = 1) and ( replaydependencyVALUE = 1 ) then
        begin
        dependenciesLabel.Caption:= 'Missing MangoHud';
        dependencieSpeedButton.ImageIndex := 1;
        end;

        if (mangohuddependencyVALUE = 1) and ( vkbasaltdependencyVALUE = 0) and ( replaydependencyVALUE = 1 ) then
        begin
        dependenciesLabel.Caption:= 'Missing vkBasalt';
        dependencieSpeedButton.ImageIndex := 1;
        end;

        if (mangohuddependencyVALUE = 1) and ( vkbasaltdependencyVALUE = 1) and ( replaydependencyVALUE = 0 ) then
        begin
        dependenciesLabel.Caption:= 'Missing ReplaySorcery';
        dependencieSpeedButton.ImageIndex := 1;
        end;

        //Missing dual dependency
        if (mangohuddependencyVALUE = 0) and ( vkbasaltdependencyVALUE = 0) and ( replaydependencyVALUE = 1 ) then
        begin
        dependenciesLabel.Caption:= 'Missing MangoHud / vkbasalt';
        dependencieSpeedButton.ImageIndex := 1;
        end;

        if (mangohuddependencyVALUE = 0) and ( vkbasaltdependencyVALUE = 1) and ( replaydependencyVALUE = 0 ) then
        begin
        dependenciesLabel.Caption:= 'Missing MangoHud / ReplaySorcery';
        dependencieSpeedButton.ImageIndex := 1;
        end;

        if (mangohuddependencyVALUE = 1) and ( vkbasaltdependencyVALUE = 0) and ( replaydependencyVALUE = 0 ) then
        begin
        dependenciesLabel.Caption:= 'Missing vkbasalt / ReplaySorcery';
        dependencieSpeedButton.ImageIndex := 1;
        end;

        //Missing all dependencies
        if (mangohuddependencyVALUE = 0) and ( vkbasaltdependencyVALUE = 0) and ( replaydependencyVALUE = 0 ) then
        begin
        dependenciesLabel.Caption:= 'Missing all dependencies';
        dependencieSpeedButton.ImageIndex := 1;
        end;


// Check if Reshade files exist
RunCommand('bash -c ''rm $HOME/.config/goverlay/initial_values/reshade_git''', s); //delete old file in original folder
RunCommand('bash -c ''touch $HOME/.config/goverlay/initial_values/reshade_git''', s);   //create dummy file
RunCommand('bash -c ''cat $HOME/.local/share/reshade/README.md | grep -w master.zip >> $HOME/.config/goverlay/initial_values/reshade_git''', s);
RunCommand('bash -c ''yes | cp -rf $HOME/.config/goverlay/initial_values/reshade_git /tmp/goverlay/''', s); //copy file to tmp folder

// Assign Text file to variable
     AssignFile(reshadegitVAR, '/tmp/goverlay/reshade_git');
     Reset(reshadegitVAR);
     Readln(reshadegitVAR,reshadegitSTR); //Assign Text file to String
     CloseFile(reshadegitVAR);

//Check state and activate components acordingly
if reshadegitSTR = '1. [Download](https://github.com/crosire/reshade-shaders/archive/master.zip) this repository' then
   begin
   aveffectsListbox.Enabled := true;
   acteffectsListbox.Enabled:= true;
   addBitbtn.Enabled:=true;
   subBitbtn.Enabled:=true;
   end
else
    begin
    aveffectsListbox.Enabled := false;
    acteffectsListbox.Enabled:= false;
    addBitbtn.Enabled:=false;
    subBitbtn.Enabled:=false;
end;



// ########################################## LOAD INITIAL CONFIG ########################################################

//Delete old tmp files and recreate directory
RunCommand('bash -c ''rm -Rf /tmp/goverlay/initial_values/''', s);
RunCommand('bash -c ''mkdir -p /tmp/goverlay/initial_values/''', s);

//Create dummy files to avoid program error at boot

//Mangohud dummy initials
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/fps_limit''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/vsync''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/gl_vsync''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/cpu_stats''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/cpu_temp''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/mem_load''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/gpu_stats''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/gpu_temp''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/gpu_core_clock''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/gpu_mem_clock''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/gpu_power''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/vulkan_driver''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/gpu_name''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/vram''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/swap''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/ram''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/io_read''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/frame_timing''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/time''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/version''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/arch''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/engine_version''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/media_player''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/font_size''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/position''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/toggle_hud''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/toggle_logging''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/media_player_name''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/core_load''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/vkbasalcas''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/casSharpness''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/no_display''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/cpu_text_value''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/gpu_text_value''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/autoupload''', s);
RunCommand('bash -c ''echo 24 >> /tmp/goverlay/initial_values/font_size_value''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/wine''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/autolog''', s);
RunCommand('bash -c ''echo 0 >> /tmp/goverlay/initial_values/autolog_value''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/hudtitle_value''', s);

RunCommand('bash -c ''touch /tmp/goverlay/initial_values/cpu_load_change''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/gpu_load_change''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/cpu_power''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/cpu_mhz''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/fps''', s);

RunCommand('bash -c ''touch /tmp/goverlay/initial_values/graphs_gpu_load''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/graphs_gpu_temp''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/graphs_gpu_core_clock''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/graphs_gpu_mem_clock''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/graphs_cpu_load''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/graphs_cpu_temp''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/graphs_vram''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/graphs_swap''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/graphs_ram''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/show_fps_limit''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/toggle_fps_limit''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/resolution''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/battery''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/vkbasalt''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/gamemode''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/session''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/homepart''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/distroinfo''', s);

//vkbasalt dummy initials
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/cascheckValue''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/vkbasalt_toggle''', s);

//replay-sorcery dummy initials
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_width''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_width_custom''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_height''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_height_custom''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_videoFramerate''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_recordSeconds''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_videoDevice''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_videoEncoder''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_videoInput''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_videoProfile''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_videoPreset''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_videoQuality''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_videoBitrate''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_videoGOP''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_FULLSCREEN''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_AUTOSCALE''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_VIDEO_AUTO_QUALITY''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_VIDEO_AUTO_BITRATE''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_AUDIO_AUTO_BITRATE''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_audioInput''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_audioDevice''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_audioEncoder''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_audioProfile''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_audioSamplerate''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_audioBitrate''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_keyMods''', s);
RunCommand('bash -c ''touch /tmp/goverlay/initial_values/replay_keyName''', s);

//Copy files with initial values to tmp folder
RunCommand('bash -c ''yes | cp -rf $HOME/.config/goverlay/initial_values/ /tmp/goverlay/''', s);



// ########################################         Read configuration files - MANGOHUD  ########################################################



//###################################################################### FPS_LIMIT

// Assign Text file to variable than assign variable to string
AssignFile(initfpslimit, '/tmp/goverlay/initial_values/fps_limit');
Reset(initfpslimit);
Readln(initfpslimit,initfpslimitSTR); //Assign Text file to String
CloseFile(initfpslimit);

case initfpslimitSTR of
'fps_limit=15':fpslimComboBox.ItemIndex:=0;
'fps_limit=30':fpslimComboBox.ItemIndex:=1;
'fps_limit=45':fpslimComboBox.ItemIndex:=2;
'fps_limit=60':fpslimComboBox.ItemIndex:=3;
'fps_limit=60,30':fpslimComboBox.ItemIndex:=4;
'fps_limit=90':fpslimComboBox.ItemIndex:=5;
'fps_limit=120':fpslimComboBox.ItemIndex:=6;
'fps_limit=120,60':fpslimComboBox.ItemIndex:=7;
'fps_limit=144':fpslimComboBox.ItemIndex:=8;
'fps_limit=240':fpslimComboBox.ItemIndex:=9;
'fps_limit=300':fpslimComboBox.ItemIndex:=10;
'fps_limit=360':fpslimComboBox.ItemIndex:=11;
'fps_limit=420':fpslimComboBox.ItemIndex:=12;
'#fps_limit=':fpslimComboBox.ItemIndex:=13;
'':fpslimComboBox.ItemIndex:=15;
 end;

//###################################################################### show_fps_limit

// Assign Text file to variable than assign variable to string
AssignFile(initshowfpslimit, '/tmp/goverlay/initial_values/show_fps_limit');
Reset(initshowfpslimit);
Readln(initshowfpslimit,initshowfpslimitSTR); //Assign Text file to String
CloseFile(initshowfpslimit);

case initshowfpslimitSTR of
'':showfpslimCheckbox.Checked:=false;
'show_fps_limit':showfpslimCheckbox.Checked:=true;
 end;


//###################################################################### Resolution

// Assign Text file to variable than assign variable to string
AssignFile(initresolution, '/tmp/goverlay/initial_values/resolution');
Reset(initresolution);
Readln(initresolution,initresolutionSTR); //Assign Text file to String
CloseFile(initresolution);

case initresolutionSTR of
'':resolutionCheckbox.Checked:=false;
'resolution':resolutionCheckbox.Checked:=true;
 end;


//###################################################################### battery

// Assign Text file to variable than assign variable to string
AssignFile(initbattery, '/tmp/goverlay/initial_values/battery');
Reset(initbattery);
Readln(initbattery,initbatterySTR); //Assign Text file to String
CloseFile(initbattery);

case initbatterySTR of
'':batteryCheckbox.Checked:=false;
'battery':batteryCheckbox.Checked:=true;
 end;


//###################################################################### vkbasalt status

// Assign Text file to variable than assign variable to string
AssignFile(initvkbasaltstatus, '/tmp/goverlay/initial_values/vkbasalt');
Reset(initvkbasaltstatus);
Readln(initvkbasaltstatus,initvkbasaltstatusSTR); //Assign Text file to String
CloseFile(initvkbasaltstatus);

case initvkbasaltstatusSTR of
'':vkbasaltstatusCheckbox.Checked:=false;
'vkbasalt':vkbasaltstatusCheckbox.Checked:=true;
 end;

//###################################################################### Gamemode status

// Assign Text file to variable than assign variable to string
AssignFile(initgamemodestatus, '/tmp/goverlay/initial_values/gamemode');
Reset(initgamemodestatus);
Readln(initgamemodestatus,initgamemodestatusSTR); //Assign Text file to String
CloseFile(initgamemodestatus);

case initgamemodestatusSTR of
'':gamemodestatusCheckbox.Checked:=false;
'gamemode':gamemodestatusCheckbox.Checked:=true;
 end;

//###################################################################### Session type

// Assign Text file to variable than assign variable to string
AssignFile(initsession, '/tmp/goverlay/initial_values/session');
Reset(initsession);
Readln(initsession,initsessionSTR); //Assign Text file to String
CloseFile(initsession);

case initsessionSTR of
'':sessionCheckbox.Checked:=false;
'custom_text=Session:':sessionCheckbox.Checked:=true;
 end;

//###################################################################### Distro info
// Assign Text file to variable than assign variable to string
AssignFile(initdistroinfo, '/tmp/goverlay/initial_values/distroinfo');
Reset(initdistroinfo);
Readln(initdistroinfo,initdistroinfoSTR); //Assign Text file to String
CloseFile(initdistroinfo);

case initdistroinfoSTR of
'':distroinfoCheckbox.Checked:=false;
'exec=lsb_release -a | grep Description | cut -c 14-26':distroinfoCheckbox.Checked:=true;
 end;

//###################################################################### Home partition
// Assign Text file to variable than assign variable to string
AssignFile(inithomepart, '/tmp/goverlay/initial_values/homepart');
Reset(inithomepart);
Readln(inithomepart,inithomepartSTR); //Assign Text file to String
CloseFile(inithomepart);

case inithomepartSTR of
'':homepartCheckbox.Checked:=false;
'exec=df -h /home | tail -n 1':homepartCheckbox.Checked:=true;
 end;

//###################################################################### toggle key for fps limit

// Assign Text file to variable than assign variable to string
AssignFile(inittogglefpslimit, '/tmp/goverlay/initial_values/toggle_fps_limit');
Reset(inittogglefpslimit);
Readln(inittogglefpslimit,inittogglefpslimitSTR); //Assign Text file to String
CloseFile(inittogglefpslimit);

case inittogglefpslimitSTR of
'toggle_fps_limit=F1':fpslimtoggleCombobox.ItemIndex:=0;
'toggle_fps_limit=F2':fpslimtoggleCombobox.ItemIndex:=1;
'toggle_fps_limit=F3':fpslimtoggleCombobox.ItemIndex:=2;
'toggle_fps_limit=F4':fpslimtoggleCombobox.ItemIndex:=3;
 end;

//###################################################################### VSYNC

// Assign Text file to variable than assign variable to string
AssignFile(initvsync, '/tmp/goverlay/initial_values/vsync');
Reset(initvsync);
Readln(initvsync,initvsyncSTR); //Assign Text file to String
CloseFile(initvsync);

case initvsyncSTR of
'vsync=0':vsyncComboBox.ItemIndex:=0;
'vsync=1':vsyncComboBox.ItemIndex:=1;
'vsync=2':vsyncComboBox.ItemIndex:=2;
'vsync=3':vsyncComboBox.ItemIndex:=3;
'':vsyncComboBox.ItemIndex:=4;
 end;

//###################################################################### gl_vsync

// Assign Text file to variable than assign variable to string
AssignFile(initgl_vsync, '/tmp/goverlay/initial_values/gl_vsync');
Reset(initgl_vsync);
Readln(initgl_vsync,initgl_vsyncSTR); //Assign Text file to String
CloseFile(initgl_vsync);

case initgl_vsyncSTR of
'gl_vsync=-1':glvsyncComboBox.ItemIndex:=0;
'gl_vsync=0':glvsyncComboBox.ItemIndex:=1;
'gl_vsync=n':glvsyncComboBox.ItemIndex:=2;
'gl_vsync=1':glvsyncComboBox.ItemIndex:=3;
'':glvsyncComboBox.ItemIndex:=4;
 end;

//###################################################################### cpu_stats (cpu load)

// Assign Text file to variable than assign variable to string
AssignFile(initcpustats, '/tmp/goverlay/initial_values/cpu_stats');
Reset(initcpustats);
Readln(initcpustats,initcpustatsSTR); //Assign Text file to String
CloseFile(initcpustats);

case initcpustatsSTR of
'':cpuavrloadCheckbox.Checked:=false;
'cpu_stats':cpuavrloadCheckbox.Checked:=true;
 end;

//###################################################################### cpu_temp

// Assign Text file to variable than assign variable to string
AssignFile(initcputemp, '/tmp/goverlay/initial_values/cpu_temp');
Reset(initcputemp);
Readln(initcputemp,initcputempSTR); //Assign Text file to String
CloseFile(initcputemp);

case initcputempSTR of
'':cputempCheckbox.Checked:=false;
'cpu_temp':cputempCheckbox.Checked:=true;
 end;

//###################################################################### cpu core load (multiple cores)

// Assign Text file to variable than assign variable to string
AssignFile(initcoreload, '/tmp/goverlay/initial_values/core_load');
Reset(initcoreload);
Readln(initcoreload,initcoreloadSTR); //Assign Text file to String
CloseFile(initcoreload);

case initcoreloadSTR of
'':cpuloadcoreCheckbox.Checked:=false;
'core_load':cpuloadcoreCheckbox.Checked:=true;
 end;


//###################################################################### cpu_load_change and color

// Assign Text file to variable than assign variable to string
AssignFile(initcpuloadchange, '/tmp/goverlay/initial_values/cpu_load_change');
Reset(initcpuloadchange);
Readln(initcpuloadchange,initcpuloadchangeSTR); //Assign Text file to String
CloseFile(initcpuloadchange);

case initcpuloadchangeSTR of
'':cpuloadcolorCheckbox.Checked:=false;
'cpu_load_change':cpuloadcolorCheckbox.Checked:=true;
 end;

//###################################################################### cpu_frequency

// Assign Text file to variable than assign variable to string
AssignFile(initcpufreq, '/tmp/goverlay/initial_values/cpu_mhz');
Reset(initcpufreq);
Readln(initcpufreq,initcpufreqSTR); //Assign Text file to String
CloseFile(initcpufreq);

case initcpufreqSTR of
'':cpufreqCheckbox.Checked:=false;
'cpu_mhz':cpufreqCheckbox.Checked:=true;
 end;

//###################################################################### cpu_power

// Assign Text file to variable than assign variable to string
AssignFile(initcpupower, '/tmp/goverlay/initial_values/cpu_power');
Reset(initcpupower);
Readln(initcpupower,initcpupowerSTR); //Assign Text file to String
CloseFile(initcpupower);

case initcpupowerSTR of
'':cpupowerCheckbox.Checked:=false;
'cpu_power':cpupowerCheckbox.Checked:=true;
 end;


//###################################################################### cpu_text_value

// Assign Text file to variable than assign variable to string
AssignFile(initcputextvalue, '/tmp/goverlay/initial_values/cpu_text_value');
Reset(initcputextvalue);
Readln(initcputextvalue,initcputextvalueSTR); //Assign Text file to String
CloseFile(initcputextvalue);

if initcputextvalueSTR = '' then
   cpunameEdit.text:= 'CPU'
   else
   cpunameEdit.text:= initcputextvalueSTR;


//###################################################################### gpu load

// Assign Text file to variable than assign variable to string
AssignFile(initgpustats, '/tmp/goverlay/initial_values/gpu_stats');
Reset(initgpustats);
Readln(initgpustats,initgpustatsSTR); //Assign Text file to String
CloseFile(initgpustats);

case initgpustatsSTR of
'':gpuavrloadCheckbox.Checked:=false;
'gpu_stats':gpuavrloadCheckbox.Checked:=true;
 end;

//###################################################################### gpu load

// Assign Text file to variable than assign variable to string
AssignFile(initgpustats, '/tmp/goverlay/initial_values/gpu_stats');
Reset(initgpustats);
Readln(initgpustats,initgpustatsSTR); //Assign Text file to String
CloseFile(initgpustats);

case initgpustatsSTR of
'':gpuavrloadCheckbox.Checked:=false;
'gpu_stats':gpuavrloadCheckbox.Checked:=true;
 end;


//###################################################################### gpu_temp

// Assign Text file to variable than assign variable to string
AssignFile(initgputemp, '/tmp/goverlay/initial_values/gpu_temp');
Reset(initgputemp);
Readln(initgputemp,initgputempSTR); //Assign Text file to String
CloseFile(initgputemp);

case initgputempSTR of
'':gputempCheckbox.Checked:=false;
'gpu_temp':gputempCheckbox.Checked:=true;
 end;

//###################################################################### gpu_core_clock

// Assign Text file to variable than assign variable to string
AssignFile(initgpucoreclock, '/tmp/goverlay/initial_values/gpu_core_clock');
Reset(initgpucoreclock);
Readln(initgpucoreclock,initgpucoreclockSTR); //Assign Text file to String
CloseFile(initgpucoreclock);

case initgpucoreclockSTR of
'':gpufreqCheckbox.Checked:=false;
'gpu_core_clock':gpufreqCheckbox.Checked:=true;
 end;

//###################################################################### gpu_mem_clock

// Assign Text file to variable than assign variable to string
AssignFile(initgpumemclock, '/tmp/goverlay/initial_values/gpu_mem_clock');
Reset(initgpumemclock);
Readln(initgpumemclock,initgpumemclockSTR); //Assign Text file to String
CloseFile(initgpumemclock);

case initgpumemclockSTR of
'':gpumemfreqCheckbox.Checked:=false;
'gpu_mem_clock':gpumemfreqCheckbox.Checked:=true;
 end;

//###################################################################### gpu_power

// Assign Text file to variable than assign variable to string
AssignFile(initgpupower, '/tmp/goverlay/initial_values/gpu_power');
Reset(initgpupower);
Readln(initgpupower,initgpupowerSTR); //Assign Text file to String
CloseFile(initgpupower);

case initgpupowerSTR of
'':gpupowerCheckbox.Checked:=false;
'gpu_power':gpupowerCheckbox.Checked:=true;
 end;

//###################################################################### gpu_load_change and color

// Assign Text file to variable than assign variable to string
AssignFile(initgpuloadchange, '/tmp/goverlay/initial_values/gpu_load_change');
Reset(initgpuloadchange);
Readln(initgpuloadchange,initgpuloadchangeSTR); //Assign Text file to String
CloseFile(initgpuloadchange);

case initgpuloadchangeSTR of
'':gpuloadcolorCheckbox.Checked:=false;
'gpu_load_change':gpuloadcolorCheckbox.Checked:=true;
 end;


//###################################################################### gpu_text_value

// Assign Text file to variable than assign variable to string
AssignFile(initgputextvalue, '/tmp/goverlay/initial_values/gpu_text_value');
Reset(initgputextvalue);
Readln(initgputextvalue,initgputextvalueSTR); //Assign Text file to String
CloseFile(initgputextvalue);

if initgputextvalueSTR = '' then
   gpunameEdit.text:= 'GPU'
   else
   gpunameEdit.text:= initgputextvalueSTR;


//###################################################################### hudtitle_value

// Assign Text file to variable than assign variable to string
AssignFile(inithudtitlevalue, '/tmp/goverlay/initial_values/hudtitle_value');
Reset(inithudtitlevalue);
Readln(inithudtitlevalue,inithudtitlevalueSTR); //Assign Text file to String
CloseFile(inithudtitlevalue);

if inithudtitlevalueSTR = '' then
   hudtitleEdit.text:= ''
   else
   hudtitleEdit.text:= inithudtitlevalueSTR;

//###################################################################### vulkan_driver

// Assign Text file to variable than assign variable to string
AssignFile(initvulkandriver, '/tmp/goverlay/initial_values/vulkan_driver');
Reset(initvulkandriver);
Readln(initvulkandriver,initvulkandriverSTR); //Assign Text file to String
CloseFile(initvulkandriver);

case initvulkandriverSTR of
'':driverversionCheckbox.Checked:=false;
'vulkan_driver':driverversionCheckbox.Checked:=true;
 end;

//###################################################################### gpu_name

// Assign Text file to variable than assign variable to string
AssignFile(initgpuname, '/tmp/goverlay/initial_values/gpu_name');
Reset(initgpuname);
Readln(initgpuname,initgpunameSTR); //Assign Text file to String
CloseFile(initgpuname);

case initgpunameSTR of
'':gpumodelCheckbox.Checked:=false;
'gpu_name':gpumodelCheckbox.Checked:=true;
 end;


//###################################################################### swap

// Assign Text file to variable than assign variable to string
AssignFile(initswap, '/tmp/goverlay/initial_values/swap');
Reset(initswap);
Readln(initswap,initswapSTR); //Assign Text file to String
CloseFile(initswap);

case initswapSTR of
'':swapusageCheckbox.Checked:=false;
'swap':swapusageCheckbox.Checked:=true;
 end;

//###################################################################### vram

// Assign Text file to variable than assign variable to string
AssignFile(initvram, '/tmp/goverlay/initial_values/vram');
Reset(initvram);
Readln(initvram,initvramSTR); //Assign Text file to String
CloseFile(initvram);

case initvramSTR of
'':vramusageCheckbox.Checked:=false;
'vram':vramusageCheckbox.Checked:=true;
 end;

//###################################################################### ram

// Assign Text file to variable than assign variable to string
AssignFile(initram, '/tmp/goverlay/initial_values/ram');
Reset(initram);
Readln(initram,initramSTR); //Assign Text file to String
CloseFile(initram);

case initramSTR of
'':ramusageCheckbox.Checked:=false;
'ram':ramusageCheckbox.Checked:=true;
 end;

//###################################################################### io_read

// Assign Text file to variable than assign variable to string
AssignFile(initioread, '/tmp/goverlay/initial_values/io_read');
Reset(initioread);
Readln(initioread,initioreadSTR); //Assign Text file to String
CloseFile(initioread);

case initioreadSTR of
'':diskioCheckbox.Checked:=false;
'io_read':diskioCheckbox.Checked:=true;
 end;


//###################################################################### frame_timing

// Assign Text file to variable than assign variable to string
AssignFile(initframetiming, '/tmp/goverlay/initial_values/frame_timing');
Reset(initframetiming);
Readln(initframetiming,initframetimingSTR); //Assign Text file to String
CloseFile(initframetiming);

case initframetimingSTR of
'frame_timing=0':frametimegraphCheckbox.Checked:=false;
'frame_timing=1':frametimegraphCheckbox.Checked:=true;
 end;

//###################################################################### frame_timing histogram

// Assign Text file to variable than assign variable to string
//AssignFile(inithistogram, '/tmp/goverlay/initial_values/histogram');
//Reset(inithistogram);
//Readln(inithistogram,inithistogramSTR); //Assign Text file to String
//CloseFile(inithistogram);

//case inithistogramSTR of
//'':framehistogramRadioButton.Checked:=false;
//'histogram':framehistogramRadioButton.Checked:=true;
// end;

//###################################################################### time

// Assign Text file to variable than assign variable to string
AssignFile(inittime, '/tmp/goverlay/initial_values/time');
Reset(inittime);
Readln(inittime,inittimeSTR); //Assign Text file to String
CloseFile(inittime);

case inittimeSTR of
'':timeCheckbox.Checked:=false;
'time':timeCheckbox.Checked:=true;
 end;

//###################################################################### hud version

// Assign Text file to variable than assign variable to string
AssignFile(inithudversion, '/tmp/goverlay/initial_values/version');
Reset(inithudversion);
Readln(inithudversion,inithudversionSTR); //Assign Text file to String
CloseFile(inithudversion);

case inithudversionSTR of
'':hudversionCheckbox.Checked:=false;
'version':hudversionCheckbox.Checked:=true;
 end;

//###################################################################### arch

// Assign Text file to variable than assign variable to string
AssignFile(initarch, '/tmp/goverlay/initial_values/arch');
Reset(initarch);
Readln(initarch,initarchSTR); //Assign Text file to String
CloseFile(initarch);

case initarchSTR of
'':archCheckbox.Checked:=false;
'arch':archCheckbox.Checked:=true;
 end;


//###################################################################### engine_version

// Assign Text file to variable than assign variable to string
AssignFile(initengineversion, '/tmp/goverlay/initial_values/engine_version');
Reset(initengineversion);
Readln(initengineversion,initengineversionSTR); //Assign Text file to String
CloseFile(initengineversion);

case initengineversionSTR of
'':engineversionCheckbox.Checked:=false;
'engine_version':engineversionCheckbox.Checked:=true;
 end;

//###################################################################### media_player

// Assign Text file to variable than assign variable to string
AssignFile(initmediaplayer, '/tmp/goverlay/initial_values/media_player');
Reset(initmediaplayer);
Readln(initmediaplayer,initmediaplayerSTR); //Assign Text file to String
CloseFile(initmediaplayer);

case initmediaplayerSTR of
'':mediaCheckbox.Checked:=false;
'media_player':mediaCheckbox.Checked:=true;
 end;


//###################################################################### wine

// Assign Text file to variable than assign variable to string
AssignFile(initwine, '/tmp/goverlay/initial_values/wine');
Reset(initwine);
Readln(initwine,initwineSTR); //Assign Text file to String
CloseFile(initwine);

case initwineSTR of
'':wineCheckbox.Checked:=false;
'wine':wineCheckbox.Checked:=true;
 end;



//###################################################################### hud position

// Assign Text file to variable than assign variable to string
AssignFile(initposition, '/tmp/goverlay/initial_values/position');
Reset(initposition);
Readln(initposition,initpositionSTR); //Assign Text file to String
CloseFile(initposition);

case initpositionSTR of
'position=top-left':begin
  //Highlight main button
  topleftSpeedbutton.ImageIndex:=0;

  //Clear other buttons
  toprightSpeedbutton.ImageIndex:=-1;
  bottomleftSpeedbutton.ImageIndex:=-1;
  bottomrightSpeedbutton.ImageIndex:=-1;
  end;

'position=top-right':begin
  //Highlight main button
  toprightSpeedbutton.ImageIndex:=1;

  //Clear other buttons
  topleftSpeedbutton.ImageIndex:=-1;
  bottomleftSpeedbutton.ImageIndex:=-1;
  bottomrightSpeedbutton.ImageIndex:=-1;
  end;

'position=bottom-left':begin
  //Highlight main button
  bottomleftSpeedbutton.ImageIndex:=2;

  //Clear other buttons
  topleftSpeedbutton.ImageIndex:=-1;
  toprightSpeedbutton.ImageIndex:=-1;
  bottomrightSpeedbutton.ImageIndex:=-1;
  end;


 'position=bottom-right':begin
   //Highlight main button
   bottomrightSpeedbutton.ImageIndex:=3;


  //Clear other buttons
  topleftSpeedbutton.ImageIndex:=-1;
  toprightSpeedbutton.ImageIndex:=-1;
  bottomleftSpeedbutton.ImageIndex:=-1;
end;

  'position=top-center':begin
   //Highlight main button
   topcenterSpeedbutton.ImageIndex:=4;


  //Clear other buttons
  topleftSpeedbutton.ImageIndex:=-1;
  toprightSpeedbutton.ImageIndex:=-1;
  bottomleftSpeedbutton.ImageIndex:=-1;
  bottomrightSpeedbutton.ImageIndex:=-1;
end;

end;


//###################################################################### no_display (hide hud by default)

// Assign Text file to variable than assign variable to string
AssignFile(initnodisplay, '/tmp/goverlay/initial_values/no_display');
Reset(initnodisplay);
Readln(initnodisplay,initnodisplaySTR); //Assign Text file to String
CloseFile(initnodisplay);

case initnodisplaySTR of
'':hidehudCheckbox.Checked:=false;
'no_display':hidehudCheckbox.Checked:=true;
 end;

//###################################################################### toggle hud ON OFF

// Assign Text file to variable than assign variable to string
AssignFile(inittogglehud, '/tmp/goverlay/initial_values/toggle_hud');
Reset(inittogglehud);
Readln(inittogglehud,inittogglehudSTR); //Assign Text file to String
CloseFile(inittogglehud);

case inittogglehudSTR of
'toggle_hud=Shift_R+F12':hudonoffComboBox.ItemIndex:=0;
'toggle_hud=F1':hudonoffComboBox.ItemIndex:=1;
'toggle_hud=F2':hudonoffComboBox.ItemIndex:=2;
'toggle_hud=F3':hudonoffComboBox.ItemIndex:=3;
'toggle_hud=F4':hudonoffComboBox.ItemIndex:=4;
 end;

//###################################################################### toggle logging

// Assign Text file to variable than assign variable to string
AssignFile(inittogglelogging, '/tmp/goverlay/initial_values/toggle_logging');
Reset(inittogglelogging);
Readln(inittogglelogging,inittoggleloggingSTR); //Assign Text file to String
CloseFile(inittogglelogging);

case inittoggleloggingSTR of
'toggle_logging=Shift_L+F2':loggingComboBox.ItemIndex:=0;
'toggle_logging=F1':loggingComboBox.ItemIndex:=1;
'toggle_logging=F2':loggingComboBox.ItemIndex:=2;
'toggle_logging=F3':loggingComboBox.ItemIndex:=3;
'toggle_logging=F4':loggingComboBox.ItemIndex:=4;
 end;


//###################################################################### auto upload logging

// Assign Text file to variable than assign variable to string
AssignFile(initautoupload, '/tmp/goverlay/initial_values/autoupload');
Reset(initautoupload);
Readln(initautoupload,initautouploadSTR); //Assign Text file to String
CloseFile(initautoupload);

case initautouploadSTR of
'':autouploadCheckbox.Checked:=false;
'permit_upload':autouploadCheckbox.Checked:=true;
 end;

//###################################################################### autostart_log

// Assign Text file to variable than assign variable to string
AssignFile(initautolog, '/tmp/goverlay/initial_values/autolog_value');
Reset(initautolog);
Readln(initautolog,initautologSTR); //Assign Text file to String
CloseFile(initautolog);

autologINT := StrtoInt(initautologSTR);
autologSpinEdit.Value := autologINT;


//###################################################################### media player name

// Assign Text file to variable than assign variable to string
AssignFile(initmediaplayername, '/tmp/goverlay/initial_values/media_player_name');
Reset(initmediaplayername);
Readln(initmediaplayername,initmediaplayernameSTR); //Assign Text file to String
CloseFile(initmediaplayername);

case initmediaplayernameSTR of
'media_player_name=spotify':mediaComboBox.ItemIndex:=0;
'media_player_name=vlc':mediaComboBox.ItemIndex:=1;
'media_player_name=audacious':mediaComboBox.ItemIndex:=2;
'media_player_name=cantata':mediaComboBox.ItemIndex:=3;
 end;

//###################################################################### font_size_value

// Assign Text file to variable than assign variable to string
AssignFile(initfontsizevalue, '/tmp/goverlay/initial_values/font_size_value');
Reset(initfontsizevalue);
Readln(initfontsizevalue,initfontsizevalueSTR); //Assign Text file to String
CloseFile(initfontsizevalue);


// If value is customized than set fontsizecombobox to custom
if fontsizeSpinEdit.Value  <> (19) and (24) and (38) then
begin
fontsizeComboBox.ItemIndex := 3;
fontsizeINT := StrtoInt(initfontsizevalueSTR);
fontsizeSpinEdit.Value := fontsizeINT;
end;

//###################################################################### font size

// Assign Text file to variable than assign variable to string
AssignFile(initfontsize, '/tmp/goverlay/initial_values/font_size');
Reset(initfontsize);
Readln(initfontsize,initfontsizeSTR); //Assign Text file to String
CloseFile(initfontsize);

case initfontsizeSTR of
'font_size=19':fontsizeComboBox.ItemIndex:=0;
'font_size=24':fontsizeComboBox.ItemIndex:=1;
'font_size=38':fontsizeComboBox.ItemIndex:=2;
// to be implemented custom sizes
 end;


//###################################################################### GRAPH_GPU_LOAD
// Assign Text file to variable than assign variable to string
AssignFile(initgraphgpuload, '/tmp/goverlay/initial_values/graphs_gpu_load');
Reset(initgraphgpuload);
Readln(initgraphgpuload,initgraphgpuloadSTR); //Assign Text file to String
CloseFile(initgraphgpuload);

case initgraphgpuloadSTR of
  '':gpuloadgraphBitbtn.imageindex:=3;
  'graphs=gpu_load':gpuloadgraphBitbtn.imageindex:=2;
end;



//###################################################################### FPS
// Assign Text file to variable than assign variable to string
AssignFile(initfps, '/tmp/goverlay/initial_values/fps');
Reset(initfps);
Readln(initfps,initfpsSTR); //Assign Text file to String
CloseFile(initfps);

case initfpsSTR of
  '':fpsCheckbox.checked:=false;
  'fps':fpsCheckbox.checked:=true;
end;

//###################################################################### GRAPH_GPU_temp
// Assign Text file to variable than assign variable to string
AssignFile(initgraphgputemp, '/tmp/goverlay/initial_values/graphs_gpu_temp');
Reset(initgraphgputemp);
Readln(initgraphgputemp,initgraphgputempSTR); //Assign Text file to String
CloseFile(initgraphgputemp);

case initgraphgputempSTR of
  '':gputempgraphBitbtn.imageindex:=3;
  'graphs=gpu_temp':gputempgraphBitbtn.imageindex:=2;
end;


//###################################################################### GRAPH_GPU_CORE_CLOCK
// Assign Text file to variable than assign variable to string
AssignFile(initgraphgpucf, '/tmp/goverlay/initial_values/graphs_gpu_core_clock');
Reset(initgraphgpucf);
Readln(initgraphgpucf,initgraphgpucfSTR); //Assign Text file to String
CloseFile(initgraphgpucf);

case initgraphgpucfSTR of
  '':gpucfgraphBitbtn.imageindex:=3;
  'graphs=gpu_core_clock':gpucfgraphBitbtn.imageindex:=2;
end;


//###################################################################### GRAPH_GPU_MEM_CLOCK
// Assign Text file to variable than assign variable to string
AssignFile(initgraphgpumf, '/tmp/goverlay/initial_values/graphs_gpu_mem_clock');
Reset(initgraphgpumf);
Readln(initgraphgpumf,initgraphgpumfSTR); //Assign Text file to String
CloseFile(initgraphgpumf);

case initgraphgpumfSTR of
  '':gpumfgraphBitbtn.imageindex:=3;
  'graphs=gpu_mem_clock':gpumfgraphBitbtn.imageindex:=2;
end;



//###################################################################### GRAPH_VRAM
// Assign Text file to variable than assign variable to string
AssignFile(initgraphvram, '/tmp/goverlay/initial_values/graphs_vram');
Reset(initgraphvram);
Readln(initgraphvram,initgraphvramSTR); //Assign Text file to String
CloseFile(initgraphvram);

case initgraphvramSTR of
  '':vramgraphBitbtn.imageindex:=3;
  'graphs=vram':vramgraphBitbtn.imageindex:=2;
end;


//###################################################################### GRAPH_CPU_LOAD
// Assign Text file to variable than assign variable to string
AssignFile(initgraphcpuload, '/tmp/goverlay/initial_values/graphs_cpu_load');
Reset(initgraphcpuload);
Readln(initgraphcpuload,initgraphcpuloadSTR); //Assign Text file to String
CloseFile(initgraphcpuload);

case initgraphcpuloadSTR of
  '':cpuloadgraphBitbtn.imageindex:=3;
  'graphs=cpu_load':cpuloadgraphBitbtn.imageindex:=2;
end;


//###################################################################### GRAPH_CPU_temp
// Assign Text file to variable than assign variable to string
AssignFile(initgraphcputemp, '/tmp/goverlay/initial_values/graphs_cpu_temp');
Reset(initgraphcputemp);
Readln(initgraphcputemp,initgraphcputempSTR); //Assign Text file to String
CloseFile(initgraphcputemp);

case initgraphcputempSTR of
  '':cputempgraphBitbtn.imageindex:=3;
  'graphs=cpu_temp':cputempgraphBitbtn.imageindex:=2;
end;

//###################################################################### GRAPH_ram
// Assign Text file to variable than assign variable to string
AssignFile(initgraphram, '/tmp/goverlay/initial_values/graphs_ram');
Reset(initgraphram);
Readln(initgraphram,initgraphramSTR); //Assign Text file to String
CloseFile(initgraphram);

case initgraphramSTR of
  '':ramgraphBitbtn.imageindex:=3;
  'graphs=ram':ramgraphBitbtn.imageindex:=2;
end;



// ########################################         Read configuration files - VKBASALT  ########################################################


//###################################################################### cas Sharpness

// Assign Text file to variable than assign variable to string
AssignFile(initcasSharpness, '/tmp/goverlay/initial_values/casSharpness');
Reset(initcasSharpness);
Readln(initcasSharpness,initcasSharpnessSTR); //Assign Text file to String
CloseFile(initcasSharpness);

case initcasSharpnessSTR of
'casSharpness=0.1':casTrackbar.position:=1;
'casSharpness=0.2':casTrackbar.position:=2;
'casSharpness=0.3':casTrackbar.position:=3;
'casSharpness=0.4':casTrackbar.position:=4;
'casSharpness=0.5':casTrackbar.position:=5;
'casSharpness=0.6':casTrackbar.position:=6;
'casSharpness=0.7':casTrackbar.position:=7;
'casSharpness=0.8':casTrackbar.position:=8;
'casSharpness=0.9':casTrackbar.position:=9;
'casSharpness=1.0':casTrackbar.position:=10;
end;



//###################################################################### vkbasalt CAS

// Assign Text file to variable than assign variable to string
AssignFile(initvkbasalttoggleValue, '/tmp/goverlay/initial_values/vkbasalt_toggle');
Reset(initvkbasalttoggleValue);
Readln(initvkbasalttoggleValue,initvkbasalttoggleSTR); //Assign Text file to String
CloseFile(initvkbasalttoggleValue);

case initvkbasalttoggleSTR of
  'toggleKey = Home':vkbtogglekeyCombobox.ItemIndex:=0;
  'toggleKey = F1':vkbtogglekeyCombobox.ItemIndex:=1;
  'toggleKey = F2':vkbtogglekeyCombobox.ItemIndex:=2;
  'toggleKey = F3':vkbtogglekeyCombobox.ItemIndex:=3;
  'toggleKey = F4':vkbtogglekeyCombobox.ItemIndex:=4;
end;


//###################################################################### vkbasalt toggle

// Assign Text file to variable than assign variable to string
AssignFile(initcascheckValue, '/tmp/goverlay/initial_values/cascheckValue');
Reset(initcascheckValue);
Readln(initcascheckValue,initcascheckSTR); //Assign Text file to String
CloseFile(initcascheckValue);

case initcascheckSTR of
'TRUE':cascheckbox.checked:=true;
end;


// ########################################         Read configuration files - replay-sorcery  ########################################################


//###################################################################### replay-sorcery fullscreen

// Assign Text file to variable than assign variable to string
AssignFile(initreplayfullscreenValue, '/tmp/goverlay/initial_values/replay_FULLSCREEN');
Reset(initreplayfullscreenValue);
Readln(initreplayfullscreenValue,initreplayfullscreenSTR); //Assign Text file to String
CloseFile(initreplayfullscreenValue);

case initreplayfullscreenSTR of
  'TRUE':begin
  autoresCheckbox.Checked:=true;
  fullscreenShape.Visible:=true;
  customresShape.Visible:=false;
  end;
   'FALSE':begin
   autoresCheckbox.Checked:=false;
   fullscreenShape.Visible:=false;
   customresShape.Visible:=true;
   end;
end;


//###################################################################### replay-sorcery AUTOSCALE

// Assign Text file to variable than assign variable to string
AssignFile(initreplayautoscaleValue, '/tmp/goverlay/initial_values/replay_AUTOSCALE');
Reset(initreplayautoscaleValue);
Readln(initreplayautoscaleValue,initreplayautoscaleSTR); //Assign Text file to String
CloseFile(initreplayautoscaleValue);

case initreplayautoscaleSTR of
  'TRUE':autoscaleCheckbox.Checked:=true;
   'FALSE':autoscaleCheckbox.Checked:=false;

end;



//###################################################################### replay-sorcery VIDEO AUTO QUALITY

// Assign Text file to variable than assign variable to string
AssignFile(initreplayvideoautoqualityValue, '/tmp/goverlay/initial_values/replay_VIDEO_AUTO_QUALITY');
Reset(initreplayvideoautoqualityValue);
Readln(initreplayvideoautoqualityValue,initreplayvideoautoqualitySTR); //Assign Text file to String
CloseFile(initreplayvideoautoqualityValue);

case initreplayvideoautoqualitySTR of
  'TRUE':autovideoqualityCheckbox.Checked:=true;
   '':autovideoqualityCheckbox.Checked:=false;
end;


//###################################################################### replay-sorcery VIDEO AUTO BITRATE

// Assign Text file to variable than assign variable to string
AssignFile(initreplayvideoautobitrateValue, '/tmp/goverlay/initial_values/replay_VIDEO_AUTO_BITRATE');
Reset(initreplayvideoautobitrateValue);
Readln(initreplayvideoautobitrateValue,initreplayvideoautobitrateSTR); //Assign Text file to String
CloseFile(initreplayvideoautobitrateValue);

case initreplayvideoautobitrateSTR of
  'TRUE':autovideobitrateCheckbox.Checked:=true;
   '':autovideobitrateCheckbox.Checked:=false;
end;



//###################################################################### replay-sorcery AUDIO_AUTO_BITRATE

// Assign Text file to variable than assign variable to string
AssignFile(initreplayaudioautobitrateValue, '/tmp/goverlay/initial_values/replay_AUDIO_AUTO_BITRATE');
Reset(initreplayaudioautobitrateValue);
Readln(initreplayaudioautobitrateValue,initreplayaudioautobitrateSTR); //Assign Text file to String
CloseFile(initreplayaudioautobitrateValue);

case initreplayaudioautobitrateSTR of
  'TRUE':autoaudiobitrateCheckbox.Checked:=true;
   '':autoaudiobitrateCheckbox.Checked:=false;
end;


//###################################################################### custom_resolution_values

// custom width
AssignFile(initcustomwidthValue, '/tmp/goverlay/initial_values/replay_width_custom');
Reset(initcustomwidthValue);
Readln(initcustomwidthValue,initcustomwidthSTR); //Assign Text file to String
CloseFile(initcustomwidthValue);

// custom height
AssignFile(initcustomheightValue, '/tmp/goverlay/initial_values/replay_height_custom');
Reset(initcustomheightValue);
Readln(initcustomheightValue,initcustomheightSTR); //Assign Text file to String
CloseFile(initcustomheightValue);


//###################################################################### replay state

// Check the state of reḉay-sorcery state
RunCommand('bash -c ''rm /tmp/goverlay/replay_state''', s); // delete old variable for replay-sorcery state
RunCommand('bash -c ''ps -e | grep replay >> /tmp/goverlay/replay_state''', s);

//Store the state of replay-sorcery service
  AssignFile(replaystateVAR, '/tmp/goverlay/replay_state');
  Reset(replaystateVAR);
  Readln(replaystateVAR,replaystateSTR); //Assign Text file to String
  CloseFile(replaystateVAR);

 //Check state and activate components acordingly
 if replaystateSTR = '' then     // if service is not running
     begin
        replaystopBitbtn.Enabled := false;
        replayStartBitbtn.enabled := true;
        replaystateSpeedButton.ImageIndex:=1;
        replaystateLabel.Caption:='Service is not running';
     end
 else       // if service is running
     begin
        replaystopBitbtn.Enabled := true;
        replayStartBitbtn.enabled := false;
        replaystateSpeedButton.ImageIndex:=0;
        replaystateLabel.Caption:='Service is running';
     end;

 //###################################################################### replay-sorcery framerate

     // Assign Text file to variable than assign variable to string
     AssignFile(initreplayframerateValue, '/tmp/goverlay/initial_values/replay_videoFramerate');
     Reset(initreplayframerateValue);
     Readln(initreplayframerateValue,initreplayframerateSTR); //Assign Text file to String
     CloseFile(initreplayframerateValue);

     case initreplayframerateSTR of
       'videoFramerate = 15':framerateCombobox.ItemIndex:=0;
       'videoFramerate = 30':framerateCombobox.ItemIndex:=1;
       'videoFramerate = 60':framerateCombobox.ItemIndex:=2;
       'videoFramerate = 90':framerateCombobox.ItemIndex:=3;
       'videoFramerate = 120':framerateCombobox.ItemIndex:=4;
       'videoFramerate = 144':framerateCombobox.ItemIndex:=5;
       'videoFramerate = 240':framerateCombobox.ItemIndex:=6;
     end;


//###################################################################### replay-sorcery duration

// Assign Text file to variable than assign variable to string
AssignFile(initreplaydurationValue, '/tmp/goverlay/initial_values/replay_recordSeconds');
Reset(initreplaydurationValue);
Readln(initreplaydurationValue,initreplaydurationSTR); //Assign Text file to String
CloseFile(initreplaydurationValue);

case initreplaydurationSTR of
  'recordSeconds = 10':clipdurationCombobox.ItemIndex:=0;
  'recordSeconds = 15':clipdurationCombobox.ItemIndex:=1;
  'recordSeconds = 30':clipdurationCombobox.ItemIndex:=2;
  'recordSeconds = 60':clipdurationCombobox.ItemIndex:=3;
  'recordSeconds = 120':clipdurationCombobox.ItemIndex:=4;
end;


//###################################################################### replay-sorcery video input

// Assign Text file to variable than assign variable to string
AssignFile(initreplayvideoInputValue, '/tmp/goverlay/initial_values/replay_videoInput');
Reset(initreplayvideoInputValue);
Readln(initreplayvideoInputValue,initreplayvideoInputSTR); //Assign Text file to String
CloseFile(initreplayvideoInputValue);

case initreplayvideoInputSTR of
  'videoInput = auto':videoInputCombobox.ItemIndex:=0;
  'videoInput = hwaccel':videoInputCombobox.ItemIndex:=1;
  'videoInput = x11':videoInputCombobox.ItemIndex:=2;
  'videoInput = kms':videoInputCombobox.ItemIndex:=3;
end;

//###################################################################### replay-sorcery video device

// Assign Text file to variable than assign variable to string
AssignFile(initreplayvideoDeviceValue, '/tmp/goverlay/initial_values/replay_videoDevice');
Reset(initreplayvideoDeviceValue);
Readln(initreplayvideoDeviceValue,initreplayvideoDeviceSTR); //Assign Text file to String
CloseFile(initreplayvideoDeviceValue);

case initreplayvideoDeviceSTR of
  'videoDevice = auto':videodeviceCombobox.ItemIndex:=0;
end;


//###################################################################### replay-sorcery video encoder

// Assign Text file to variable than assign variable to string
AssignFile(initreplayvideoEncoderValue, '/tmp/goverlay/initial_values/replay_videoEncoder');
Reset(initreplayvideoEncoderValue);
Readln(initreplayvideoEncoderValue,initreplayvideoEncoderSTR); //Assign Text file to String
CloseFile(initreplayvideoEncoderValue);

case initreplayvideoEncoderSTR of
  'videoEncoder = auto':videoencoderCombobox.ItemIndex:=0;
  'videoEncoder = x264':videoencoderCombobox.ItemIndex:=1;
  'videoEncoder = openh264':videoencoderCombobox.ItemIndex:=2;
  'videoEncoder = x265':videoencoderCombobox.ItemIndex:=3;
  'videoEncoder = hevc':videoencoderCombobox.ItemIndex:=4;
  'videoEncoder = vaapi_h264':videoencoderCombobox.ItemIndex:=5;
  'videoEncoder = vaapi_hevc':videoencoderCombobox.ItemIndex:=6;
end;


//###################################################################### replay-sorcery video profile

// Assign Text file to variable than assign variable to string
AssignFile(initreplayvideoProfileValue, '/tmp/goverlay/initial_values/replay_videoProfile');
Reset(initreplayvideoProfileValue);
Readln(initreplayvideoProfileValue,initreplayvideoProfileSTR); //Assign Text file to String
CloseFile(initreplayvideoProfileValue);

case initreplayvideoProfileSTR of
  'videoProfile = baseline':h264profileCombobox.ItemIndex:=0;
  'videoProfile = main':h264profileCombobox.ItemIndex:=1;
  'videoProfile = high':h264profileCombobox.ItemIndex:=2;

end;


//###################################################################### replay-sorcery video preset

// Assign Text file to variable than assign variable to string
AssignFile(initreplayvideoPresetValue, '/tmp/goverlay/initial_values/replay_videoPreset');
Reset(initreplayvideoPresetValue);
Readln(initreplayvideoPresetValue,initreplayvideoPresetSTR); //Assign Text file to String
CloseFile(initreplayvideoPresetValue);

case initreplayvideoPresetSTR of
  'videoProfile = fast':videohlepresetCombobox.ItemIndex:=0;
  'videoProfile = medium':videohlepresetCombobox.ItemIndex:=1;
  'videoProfile = slow':videohlepresetCombobox.ItemIndex:=2;

end;


//###################################################################### replay-sorcery video quality

// Assign Text file to variable than assign variable to string
AssignFile(initreplayvideoQualityValue, '/tmp/goverlay/initial_values/replay_videoQuality');
Reset(initreplayvideoQualityValue);
Readln(initreplayvideoQualityValue,initreplayvideoQualitySTR); //Assign Text file to String
CloseFile(initreplayvideoQualityValue);

case initreplayvideoQualitySTR of
  'videoQuality = 50':videoqualityTrackBar.Position:=1;
  'videoQuality = 45':videoqualityTrackBar.Position:=2;
  'videoQuality = 40':videoqualityTrackBar.Position:=3;
  'videoQuality = 35':videoqualityTrackBar.Position:=4;
  'videoQuality = 30':videoqualityTrackBar.Position:=5;
  'videoQuality = 25':videoqualityTrackBar.Position:=6;
  'videoQuality = 20':videoqualityTrackBar.Position:=7;
  'videoQuality = 15':videoqualityTrackBar.Position:=8;
  'videoQuality = 10':videoqualityTrackBar.Position:=9;
  'videoQuality = 5':videoqualityTrackBar.Position:=10;
end;

//###################################################################### replay-sorcery video bitrate

// Assign Text file to variable than assign variable to string
AssignFile(initreplayvideoBitrateValue, '/tmp/goverlay/initial_values/replay_videoBitrate');
Reset(initreplayvideoBitrateValue);
Readln(initreplayvideoBitrateValue,initreplayvideoBitrateSTR); //Assign Text file to String
CloseFile(initreplayvideoBitrateValue);

case initreplayvideoBitrateSTR of
  'videoBitrate = 1M':videobitrateTrackBar.Position:=1;
  'videoBitrate = 2M':videobitrateTrackBar.Position:=2;
  'videoBitrate = 3M':videobitrateTrackBar.Position:=3;
  'videoBitrate = 4M':videobitrateTrackBar.Position:=4;
  'videoBitrate = 5M':videobitrateTrackBar.Position:=5;
  'videoBitrate = 6M':videobitrateTrackBar.Position:=6;
  'videoBitrate = 7M':videobitrateTrackBar.Position:=7;
  'videoBitrate = 8M':videobitrateTrackBar.Position:=8;
  'videoBitrate = 9M':videobitrateTrackBar.Position:=9;
  'videoBitrate = 10M':videobitrateTrackBar.Position:=10;
end;


//###################################################################### replay-sorcery video gop

// Assign Text file to variable than assign variable to string
AssignFile(initreplayvideoGOPValue, '/tmp/goverlay/initial_values/replay_videoGOP');
Reset(initreplayvideoGOPValue);
Readln(initreplayvideoGOPValue,initreplayvideoGOPSTR); //Assign Text file to String
CloseFile(initreplayvideoGOPValue);

case initreplayvideoGOPSTR of
  'videoGOP = 20':videogopTrackBar.Position:=20;
  'videoGOP = 21':videogopTrackBar.Position:=21;
  'videoGOP = 22':videogopTrackBar.Position:=22;
  'videoGOP = 23':videogopTrackBar.Position:=23;
  'videoGOP = 24':videogopTrackBar.Position:=24;
  'videoGOP = 25':videogopTrackBar.Position:=25;
  'videoGOP = 26':videogopTrackBar.Position:=26;
  'videoGOP = 27':videogopTrackBar.Position:=27;
  'videoGOP = 28':videogopTrackBar.Position:=28;
  'videoGOP = 29':videogopTrackBar.Position:=29;
  'videoGOP = 30':videogopTrackBar.Position:=30;
  'videoGOP = 31':videogopTrackBar.Position:=31;
  'videoGOP = 32':videogopTrackBar.Position:=32;
  'videoGOP = 33':videogopTrackBar.Position:=33;
  'videoGOP = 34':videogopTrackBar.Position:=34;
  'videoGOP = 35':videogopTrackBar.Position:=35;
  'videoGOP = 36':videogopTrackBar.Position:=36;
  'videoGOP = 37':videogopTrackBar.Position:=37;
  'videoGOP = 38':videogopTrackBar.Position:=38;
  'videoGOP = 39':videogopTrackBar.Position:=39;
  'videoGOP = 40':videogopTrackBar.Position:=40;
end;


//###################################################################### replay-sorcery keyname

// Assign Text file to variable than assign variable to string
AssignFile(initreplaykeynameValue, '/tmp/goverlay/initial_values/replay_keyName');
Reset(initreplaykeynameValue);
Readln(initreplaykeynameValue,initreplaykeynameSTR); //Assign Text file to String
CloseFile(initreplaykeynameValue);

case initreplaykeynameSTR of
  'keyName = r':replaykeyCombobox.ItemIndex:=0;
  'keyName = F1':replaykeyCombobox.ItemIndex:=1;
  'keyName = F2':replaykeyCombobox.ItemIndex:=2;
  'keyName = F3':replaykeyCombobox.ItemIndex:=3;
  'keyName = F4':replaykeyCombobox.ItemIndex:=4;
end;

//###################################################################### replay-sorcery audio input

// Assign Text file to variable than assign variable to string
AssignFile(initreplayaudioinputValue, '/tmp/goverlay/initial_values/replay_audioInput');
Reset(initreplayaudioinputValue);
Readln(initreplayaudioinputValue,initreplayaudioinputSTR); //Assign Text file to String
CloseFile(initreplayaudioinputValue);

case initreplayaudioinputSTR of
  'audioInput = auto':audioinputcombobox.ItemIndex:=0;
  'audioInput = pulse':audioinputcombobox.ItemIndex:=1;
  'audioInput = none':audioinputcombobox.ItemIndex:=2;
end;


//###################################################################### replay-sorcery audio device

// Assign Text file to variable than assign variable to string
AssignFile(initreplayaudiodeviceValue, '/tmp/goverlay/initial_values/replay_audioDevice');
Reset(initreplayaudiodeviceValue);
Readln(initreplayaudiodeviceValue,initreplayaudiodeviceSTR); //Assign Text file to String
CloseFile(initreplayaudiodeviceValue);

case initreplayaudiodeviceSTR of
  'audioDevice = auto':audiodevCombobox.ItemIndex:=0;
end;



//###################################################################### replay-sorcery audiosample

// Assign Text file to variable than assign variable to string
AssignFile(initreplayaudiosampleValue, '/tmp/goverlay/initial_values/replay_audioSamplerate');
Reset(initreplayaudiosampleValue);
Readln(initreplayaudiosampleValue,initreplayaudiosampleSTR); //Assign Text file to String
CloseFile(initreplayaudiosampleValue);

case initreplayaudiosampleSTR of
  'audioSamplerate = 11025':audiosampCombobox.ItemIndex:=0;
  'audioSamplerate = 22050':audiosampCombobox.ItemIndex:=1;
  'audioSamplerate = 44100':audiosampCombobox.ItemIndex:=2;
  'audioSamplerate = 48000':audiosampCombobox.ItemIndex:=3;
end;


//###################################################################### replay-sorcery bitrate

// Assign Text file to variable than assign variable to string
AssignFile(initreplaybitrateValue, '/tmp/goverlay/initial_values/replay_audioBitrate');
Reset(initreplaybitrateValue);
Readln(initreplaybitrateValue,initreplaybitrateSTR); //Assign Text file to String
CloseFile(initreplaybitrateValue);

case initreplaybitrateSTR of
  'audioBitrate = 32000':audiobitrateCombobox.ItemIndex:=0;
  'audioBitrate = 64000':audiobitrateCombobox.ItemIndex:=1;
  'audioBitrate = 96000':audiobitrateCombobox.ItemIndex:=2;
  'audioBitrate = 128000':audiobitrateCombobox.ItemIndex:=3;
end;


//###################################################################### replay-sorcery audio device

// Assign Text file to variable than assign variable to string
AssignFile(initreplayaudioencoderValue, '/tmp/goverlay/initial_values/replay_audioEncoder');
Reset(initreplayaudioencoderValue);
Readln(initreplayaudioencoderValue,initreplayaudioencoderSTR); //Assign Text file to String
CloseFile(initreplayaudioencoderValue);

case initreplayaudioencoderSTR of
  'audioEncoder = auto':audioencoderCombobox.ItemIndex:=0;
  'audioEncoder = aac':audioencoderCombobox.ItemIndex:=1;
  'audioEncoder = fdk':audioencoderCombobox.ItemIndex:=2;
end;


//###################################################################### replay-sorcery audio profile

// Assign Text file to variable than assign variable to string
AssignFile(initreplayaudioprofileValue, '/tmp/goverlay/initial_values/replay_audioProfile');
Reset(initreplayaudioprofileValue);
Readln(initreplayaudioprofileValue,initreplayaudioprofileSTR); //Assign Text file to String
CloseFile(initreplayaudioprofileValue);

case initreplayaudioprofileSTR of
  'audioProfile = low':aacprofileCombobox.ItemIndex:=0;
  'audioProfile = main':aacprofileCombobox.ItemIndex:=1;
  'audioProfile = high':aacprofileCombobox.ItemIndex:=2;
end;


//###################################################################### replay-sorcery audio bitrate

// Assign Text file to variable than assign variable to string
AssignFile(initreplayaudiobitrateValue, '/tmp/goverlay/initial_values/replay_audioBitrate');
Reset(initreplayaudiobitrateValue);
Readln(initreplayaudiobitrateValue,initreplayaudiobitrateSTR); //Assign Text file to String
CloseFile(initreplayaudiobitrateValue);

case initreplayaudiobitrateSTR of
  'audioBitrate = 32K':audiobitrateCombobox.ItemIndex:=0;
  'audioBitrate = 64K':audiobitrateCombobox.ItemIndex:=1;
  'audioBitrate = 96K':audiobitrateCombobox.ItemIndex:=2;
  'audioBitrate = 128K':audiobitrateCombobox.ItemIndex:=3;
end;








end;

procedure Tgoverlayform.mediaCheckBoxClick(Sender: TObject);
begin
    //Preview spotify status
     if mediaCheckBox.Checked=true then
     begin
        spotify1label.Caption:='Lonely no more';
        spotify2label.Caption:='Rob Thomas' ;
        spotify3label.Caption:='Something to be' ;
     end
     else
       begin
        spotify1label.Caption:='';
        spotify2label.Caption:='';
        spotify3label.Caption:='';
       end;
end;

procedure Tgoverlayform.subBitBtnClick(Sender: TObject);
begin
  // Remove selected active effect

 acteffectslistbox.deleteselected;

end;

procedure Tgoverlayform.geSpeedButtonClick(Sender: TObject);
begin
   case geSpeedButton.imageIndex of
     0: begin
       geSpeedButton.ImageIndex:=1; //switch button position
       RunCommand('bash -c ''yes | cp -rf $HOME/.profile $HOME/.profile_bkp''', s); //backup original .profile file
       RunCommand('bash -c ''yes | cp -rf $HOME/.bash_profile $HOME/.bash_profile_bkp''', s); //backup original .profile file
       RunCommand('bash -c ''echo "export MANGOHUD=1" >> $HOME/.profile''', s);  // Activate MANGOHUD globally for vulkan apps
       RunCommand('bash -c ''echo "export MANGOHUD=1" >> $HOME/.bash_profile''', s);  // Workaround to Activate MANGOHUD globally for vulkan apps in some distros
       RunCommand('bash -c ''notify-send -i /usr/share/icons/hicolor/128x128/apps/goverlay.png "VULKAN Global Enable Activated" "Every Vulkan application will have Mangohud Enabled now"''', s); // Popup a notification
       showmessage ('Restart your system to take effect');
     end;
     1: begin
        geSpeedButton.ImageIndex:=0;
        RunCommand('bash -c ''yes | cp -rf $HOME/.profile_bkp $HOME/.profile''', s);  //restore original .profile file
        RunCommand('bash -c ''yes | cp -rf $HOME/.bash_profile_bkp $HOME/.bash_profile''', s);  //restore original .profile file
        RunCommand('bash -c ''notify-send -i /usr/share/icons/hicolor/128x128/apps/goverlay.png "Deactivated"''', s); // Popup a notification
        showmessage ('Restart your system to take effect');
     end;

  end;

   end;

procedure Tgoverlayform.gpucfgraphBitBtnClick(Sender: TObject);
begin
     case gpucfgraphBitbtn.ImageIndex of
     2:gpucfgraphBitbtn.ImageIndex:= 3;
     3:gpucfgraphBitbtn.ImageIndex:= 2;
     end;
end;

procedure Tgoverlayform.gpuloadcolorCheckBoxChange(Sender: TObject);
begin

end;

procedure Tgoverlayform.gpuloadcolorCheckBoxClick(Sender: TObject);
begin
        //PREVIEW GPU load color
  if gpuloadcolorCheckbox.Checked=true then
     gpuusagelabel.Font.Color:=gpuload3Colorbutton.ButtonColor;
  if gpuloadcolorCheckbox.Checked=false then
     gpuusagelabel.Font.Color:=gpuload1Colorbutton.ButtonColor;
end;

procedure Tgoverlayform.gpuloadgraphBitBtnClick(Sender: TObject);
begin

  case gpuloadgraphBitbtn.ImageIndex of
    2:gpuloadgraphBitbtn.ImageIndex:= 3;
    3:gpuloadgraphBitbtn.ImageIndex:= 2;
    end;

end;

procedure Tgoverlayform.gpumemfreqCheckBoxClick(Sender: TObject);
begin
      //PREVIEW GPU Mem Frequency
  if gpumemfreqCheckbox.Checked=true then
     gpumemfreqlabel.Caption:='600MHz'
  else
     gpumemfreqlabel.Caption:='' ;
  end;

procedure Tgoverlayform.gpumfgraphBitBtnClick(Sender: TObject);
begin
     case gpumfgraphBitbtn.ImageIndex of
     2:gpumfgraphBitbtn.ImageIndex:= 3;
     3:gpumfgraphBitbtn.ImageIndex:= 2;
     end;
end;


procedure Tgoverlayform.gpumodelCheckBoxClick(Sender: TObject);
begin
      //PREVIEW GPU Model
  if gpumodelCheckbox.Checked=true then
     gpunamelabel.Caption:='GTX 1080'
  else
     gpunamelabel.Caption:='' ;
  end;


procedure Tgoverlayform.gpunameEditChange(Sender: TObject);
begin
   gpulabel.Caption:=gpunameEdit.Text;
end;

procedure Tgoverlayform.gpupowerCheckBoxClick(Sender: TObject);
begin
    //PREVIEW GPU POWER
  if gpupowerCheckbox.Checked=true then
     gpupowerlabel.Caption:='120W'
  else
     gpupowerlabel.Caption:='' ;
  end;

procedure Tgoverlayform.gputempgraphBitBtnClick(Sender: TObject);
begin
     case gputempgraphBitbtn.ImageIndex of
     2:gputempgraphBitbtn.ImageIndex:= 3;
     3:gputempgraphBitbtn.ImageIndex:= 2;
     end;
end;

procedure Tgoverlayform.graphhudBitBtnClick(Sender: TObject);
begin
   //Check graph hud options
  cpuavrloadCheckbox.Checked:=false;
  cputempCheckbox.Checked:=false;
  cpuloadcoreCheckbox.Checked:=false;
  gpuavrloadCheckbox.Checked:=false;
  gputempCheckbox.Checked:=false;
  gpufreqCheckbox.Checked:=false;
  diskioCheckbox.Checked:=false;
  vramusageCheckbox.Checked:=false;
  ramusageCheckbox.Checked:=false;
  frametimegraphCheckbox.Checked:=false;

  timeCheckbox.Checked:=false;
  archCheckbox.Checked:=false;
  driverversionCheckbox.Checked:=false;
  gpupowerCheckBox.Checked:=false;
  gpumodelCheckBox.Checked:=false;
  gpumemfreqCheckBox.Checked:=false;
  engineversionCheckBox.Checked:=false;
  wineCheckbox.Checked:=false;
  cpufreqCheckbox.Checked:=false;
  cpupowerCheckbox.Checked:=false;
  gpuloadcolorCheckbox.Checked:=false;
  cpuloadcolorCheckbox.Checked:=false;
  hudversionCheckbox.Checked:=false;
  fpsCheckbox.Checked:=false;

  showfpslimCheckbox.Checked:=false;
  batteryCheckbox.Checked:=false;
  resolutionCheckbox.Checked:=false;
  vkbasaltstatusCheckbox.Checked:=false;
  gamemodestatusCheckbox.Checked:=false;
  sessionCheckbox.Checked:=false;
  distroinfoCheckbox.Checked:=false;
  homepartCheckbox.Checked:=false;

  gpuloadgraphBitbtn.imageindex:=2;
  gputempgraphBitbtn.imageindex:=2;
  gpucfgraphBitbtn.imageindex:=2;
  gpumfgraphBitbtn.imageindex:=2;
  vramgraphBitbtn.imageindex:=2;
  cpuloadgraphBitbtn.imageindex:=2;
  cputempgraphBitbtn.imageindex:=2;
  ramgraphBitbtn.imageindex:=2;
end;

procedure Tgoverlayform.heroicMenuItemClick(Sender: TObject);
begin
  RunCommand('bash -c ''mangohud heroic''', s);  // run heroic
end;

procedure Tgoverlayform.homepartCheckBoxClick(Sender: TObject);
begin
        //Preview home partition
  if homepartCheckbox.Checked=true then
  begin
  homepartitionlabel.Caption:='/home/ partition size';

  end
  else
  begin
  homepartitionlabel.Caption:='';
  end;
end;


procedure Tgoverlayform.timeCheckBoxClick(Sender: TObject);
begin
   //Preview TIME
     if timeCheckbox.Checked=true then
        timelabel.Caption:='22:30:43'
     else
        timelabel.Caption:='';

end;

procedure Tgoverlayform.topcenterSpeedButtonClick(Sender: TObject);
begin
     //Highlight main button
   topcenterSpeedButton.imageIndex:=4;


  //Clear other buttons
  topleftSpeedbutton.ImageIndex:=-1;
  toprightSpeedbutton.ImageIndex:=-1;
  bottomleftSpeedbutton.ImageIndex:=-1;
  bottomrightSpeedbutton.ImageIndex:=-1;
end;



procedure Tgoverlayform.topleftSpeedButtonClick(Sender: TObject);
begin
  //Highlight main button
  topleftSpeedbutton.ImageIndex:=0;

  //Clear other buttons
  toprightSpeedbutton.ImageIndex:=-1;
  bottomleftSpeedbutton.ImageIndex:=-1;
  bottomrightSpeedbutton.ImageIndex:=-1;
  topcenterSpeedButton.imageIndex:=-1;
end;



procedure Tgoverlayform.hudversionCheckBoxClick(Sender: TObject);
begin
     //Preview HudVersion
     if hudversionCheckbox.Checked=true then
       hudversionlabel.Caption:='v0.3.5-31'
     else
        hudversionlabel.Caption:='';
end;

procedure Tgoverlayform.toprightSpeedButtonClick(Sender: TObject);
begin
    //Highlight main button
  toprightSpeedbutton.ImageIndex:=1;

  //Clear other buttons
  topleftSpeedbutton.ImageIndex:=-1;
  bottomleftSpeedbutton.ImageIndex:=-1;
  bottomrightSpeedbutton.ImageIndex:=-1;
  topcenterSpeedButton.imageIndex:=-1;
end;

procedure Tgoverlayform.vkbasaltLabelClick(Sender: TObject);
begin
  //On Select vkbbasalt shape - Change variables
  mangohudsel := false;
  vkbasaltsel := true;
  replaysel :=false;

  //On Select vkbbasalt shape - Change colors and unselect Mangohud and replaysoruce
  vkbasaltShape.Brush.Color:=$00383838;
  vkbasaltShape.Visible:=true;
  vkbasaltLabel.Font.color:=clwhite;
  mangohudlabel.Font.color:=clgray;
  mangohudshape.Visible:=false;
  replaylabel.Font.color:=clgray;
  replayshape.Visible:=false;

  //Display vkbasalt panel
  Mangohudpanel.Visible:=false;
  vkbasaltPanel.Visible:=true;
  replaypanel.Visible:=false;

end;

procedure Tgoverlayform.vkbasaltLabelMouseEnter(Sender: TObject);
begin
     //highlight vkbasalt shape on mouse enter if mangohud is selected
     if mangohudsel = true  then
       begin
        vkbasaltShape.Brush.Color:=$00232323;
        vkbasaltShape.Visible:=true;
       end;

     //highlight vkbasalt shape on mouse enter if replay is selected
     if replaysel = true  then
       begin
        vkbasaltShape.Brush.Color:=$00232323;
        vkbasaltShape.Visible:=true;
       end;
end;

procedure Tgoverlayform.vkbasaltLabelMouseLeave(Sender: TObject);
begin
  //hide vkbasalt shape on mouse leave if mangohud is selected
 if mangohudsel = true  then
 vkbasaltShape.Visible:=false;

 if replaysel = true  then
 vkbasaltShape.Visible:=false;
end;

procedure Tgoverlayform.vkbasaltstatusCheckBoxClick(Sender: TObject);
begin
           //Preview vkbasalt
  if vkbasaltstatusCheckbox.Checked=true then
  begin
  vkbasaltstatuslabel.Caption:='VKBASALT';
  vkbasaltstatusvaluelabel.Caption:='ON';
  end
  else
  begin
  vkbasaltstatuslabel.Caption:='';
  vkbasaltstatusvaluelabel.Caption:='';
  end;
end;

procedure Tgoverlayform.vramColorButtonColorChanged(Sender: TObject);
begin
    // Change VRAM label color
    vramlabel.font.Color:=vramcolorButton.ButtonColor;

    //Use function SColorToHtmlColor from unit ATStringProc_htmlColor to change color format to RGB and write value to label
    vramcolorhtml := SColorToHtmlColor(vramcolorButton.ButtonColor);
end;

procedure Tgoverlayform.vramgraphBitBtnClick(Sender: TObject);
begin
     case vramgraphBitbtn.ImageIndex of
     2:vramgraphBitbtn.ImageIndex:= 3;
     3:vramgraphBitbtn.ImageIndex:= 2;
     end;
end;

procedure Tgoverlayform.vramusageCheckBoxClick(Sender: TObject);
begin
      //Preview VRAM usage
  if vramusageCheckbox.Checked=true then
    begin
    vramlabel.Caption:='VRAM';
    vramusagelabel.Caption:='2.56GB'
    end
  else
    begin
    vramlabel.Caption:='';
    vramusagelabel.Caption:=''
  end;
end;

procedure Tgoverlayform.vsyncComboBoxKeyPress(Sender: TObject; var Key: char);
begin
   //Block keypress on combobox
  key:=#0;
end;

procedure Tgoverlayform.widthImageMouseEnter(Sender: TObject);
begin
    if autoresCheckbox.Checked = false then
    widthImage.Visible:= true;
end;

procedure Tgoverlayform.wineCheckBoxChange(Sender: TObject);
begin
     //Preview Wine Version
     if wineCheckbox.Checked=true then
        winelabel.Caption:='Proton 5.0-9'
     else
        winelabel.Caption:='';
end;

procedure Tgoverlayform.wineColorButtonColorChanged(Sender: TObject);
begin
  
  // wine color
   winelabel.font.Color:=winecolorButton.ButtonColor;

   //Use function SColorToHtmlColor from unit ATStringProc_htmlColor to change color format to RGB and write value to label
   winecolorhtml := SColorToHtmlColor(winecolorButton.ButtonColor);
end;

procedure Tgoverlayform.h264profileComboboxKeyPress(Sender: TObject;
  var Key: char);
begin
    //Block keypress on combobox
  key:=#0;
end;





end.

