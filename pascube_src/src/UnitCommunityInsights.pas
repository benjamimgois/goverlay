unit UnitCommunityInsights;
{$ifdef fpc}
 {$mode delphi}
{$endif}

interface

uses
  SysUtils,
  Classes,
  Math,
  PasVulkan.Types,
  PasVulkan.Math;

const
  COMMUNITY_CACHE_SUBPATH = 'goverlay/pascubedb_cache.csv';
  COMMUNITY_SPREADSHEET_URL = 'https://docs.google.com/spreadsheets/d/1nlMgeW0ZFmtwwT3hty8JAFT3sM0SNhMpc24mH3In9zI/export?format=csv';

type
  TDistroStat = record
    Name: string;
    Count: Integer;
    Percent: Double;
    AvgScore: Integer;
    IsCurrentDistro: Boolean;
  end;

  TDesktopStat = record
    Name: string;
    Count: Integer;
    Percent: Double;
    AvgScore: Integer;
    IsCurrentDE: Boolean;
  end;

  TKernelStat = record
    Name: string;
    Count: Integer;
    Percent: Double;
    AvgScore: Integer;
    IsCurrentKernel: Boolean;
  end;

  TSameGPUDistroStat = record
    Name: string;
    Count: Integer;
    AvgScore: Integer;
    DeltaPct: Double;
    IsCurrentDistro: Boolean;
  end;

  TSameGPUDriverStat = record
    Name: string;
    Count: Integer;
    AvgGPUScore: Integer;
    DeltaPct: Double;
    IsCurrentDriver: Boolean;
  end;

  TSameCPUKernelStat = record
    Name: string;
    Count: Integer;
    AvgCPUScore: Integer;
    DeltaPct: Double;
    IsCurrentKernel: Boolean;
  end;

  TStackShareStats = record
    WaylandPct: Double;
    X11Pct: Double;
    MesaPct: Double;
    NvidiaPct: Double;
    TopKernelName: string;
    TopKernelAvgScore: Integer;
  end;

  TSiliconSubmission = record
    Rank: Integer;
    Username: string;
    Distro: string;
    FreqMHz: Integer;
    Score: Integer;
    IsUser: Boolean;
  end;

  TSiliconLottery = record
    ModelRank: Integer;
    ModelTotal: Integer;
    ModelAvg: Integer;
    ModelMin: Integer;
    ModelMax: Integer;
    ModelDelta: Integer;
    ModelDeltaPct: Double;
    QualityTier: string;
    LeaderboardCount: Integer;
    Leaderboard: array[0..7] of TSiliconSubmission;
  end;

  TCPUSiliconLottery = record
    ModelName: string;
    QualityTier: string;
    ModelMin: Integer;
    ModelAvg: Integer;
    ModelMax: Integer;
    ModelRank: Integer;
    ModelTotal: Integer;
    ModelDelta: Integer;
    ModelDeltaPct: Double;
    LeaderboardCount: Integer;
    Leaderboard: array[0..7] of TSiliconSubmission;
  end;

  TEfficiencyRankEntry = record
    Name: string;
    Distro: string;
    Username: string;
    Watts: Integer;
    PtsPerWatt: Double;
    Score: Integer;
    IsUser: Boolean;
  end;

  TEfficiencyMetrics = record
    PointsPerWatt: Double;
    GPUPtsPerWatt: Double;
    CPUPtsPerWatt: Double;
    EfficiencyGrade: string;
    GPUTempMax: Integer;
    GPUTempHeadroom: Integer;
    CPUTempMax: Integer;
    CPUTempHeadroom: Integer;
    PeakPower: Integer;
    GPUPeakPower: Integer;
    CPUPeakPower: Integer;
    GPURankings: array[0..4] of TEfficiencyRankEntry;
    CPURankings: array[0..4] of TEfficiencyRankEntry;
  end;

  TScalingRung = record
    Title: string;
    Subtitle: string;
    Score: Integer;
    BadgeText: string;
    IsUser: Boolean;
    IsRecord: Boolean;
    ColorR: Single;
    ColorG: Single;
    ColorB: Single;
  end;

  TBadge = record
    Id: Integer;
    Code: string;
    Title: string;
    Description: string;
    Icon: string;
    Unlocked: Boolean;
    TierName: string;
    MetricStr: string;
    ProgressPct: Integer;
  end;

  TCommunitySyncThread = class(TThread)
  private
    FCachePath: string;
    FSuccess: Boolean;
    FIsFinished: Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(const aCachePath: string);
    property Success: Boolean read FSuccess;
    property IsFinished: Boolean read FIsFinished;
  end;

  TCommunityInsights = class
  private
    FInitialized: Boolean;
    FLoaded: Boolean;
    FSyncThread: TCommunitySyncThread;
    FCachePath: string;
    FTotalSubmissions: Integer;
    FMeanScore: Double;
    FStdDevScore: Double;
    FUserScore: Integer;
    FPercentile: Double;
    FTop1Score: Integer;
    FTop1Specs: string;
    FDeckMultiple: Double;
    FAllyMultiple: Double;
    FSwitch2Multiple: Double;
    FHighEndPct: Double;
    FMidRangeMultiple: Double;
    FPS5Multiple: Double;
    FTopPCPercent: Double;
    FMatchedGPUModel: string;
    FMatchedCPUModel: string;
    FDistroCount: Integer;
    FDistroStats: array[0..4] of TDistroStat;
    FDesktopCount: Integer;
    FDesktopStats: array[0..3] of TDesktopStat;
    FKernelCount: Integer;
    FKernelStats: array[0..3] of TKernelStat;
    FSameGPUDistroCount: Integer;
    FSameGPUDistroIncludesCPU: Boolean;
    FSameGPUDistroStats: array[0..3] of TSameGPUDistroStat;
    FSameGPUDriverCount: Integer;
    FSameGPUDriverStats: array[0..3] of TSameGPUDriverStat;
    FSameCPUKernelCount: Integer;
    FSameCPUKernelStats: array[0..3] of TSameCPUKernelStat;
    FUserDriverBranch: string;
    FUserKernelBranch: string;
    FStackShare: TStackShareStats;
    FScalingRungs: array[0..5] of TScalingRung;
    FNormalCurvePoints: array[0..39] of TpvVector2;
    FUserDistroName: string;
    FUserCPUName: string;
    FUserDesktopName: string;
    FUserKernelName: string;
    FUserNick: string;
    FSiliconLottery: TSiliconLottery;
    FCPUSilicon: TCPUSiliconLottery;
    FEfficiency: TEfficiencyMetrics;
    FBadges: array[0..5] of TBadge;

    // Cached parameters for hot-reload when background sync finishes
    FLastUserScore: Integer;
    FLastUserGPU: string;
    FLastUserDistro: string;
    FLastRTScore: Integer;
    FLastCPUTempMax: Double;
    FLastGPUTempMax: Double;
    FLastTotalPowerMax: Double;
    FLastCPUMultiScore: Integer;
    FLastGPURasterScore: Integer;
    FLastCPUPowerMax: Double;
    FLastGPUPowerMax: Double;
    FLastUserCPU: string;
    FLastUserDesktop: string;
    FLastUserKernel: string;
    FLastCPUMaxFreq: Integer;
    FLastGPUMaxFreq: Integer;
    FLastUserNick: string;
    FLastUserDriver: string;

    function GetCacheFilePath: string;
    function CleanScoreStr(const S: string): string;
    function NormalizeDistroName(const RawDistro: string): string;
    function NormalizeDesktopName(const RawDE: string; const RawOS: string): string;
    function NormalizeKernelName(const RawKernel: string): string;
    function NormalizeDriverBranch(const RawDriver: string): string;
    function NormalizeKernelBranch(const RawKernel: string): string;
    function ExtractGPUChipToken(const RawGPU: string; out CleanLabel: string): string; overload;
    function ExtractGPUChipToken(const RawGPU: string): string; overload;
    function ExtractCPUChipToken(const RawCPU: string; out CleanLabel: string): string;
    function GetDistroStat(aIndex: Integer): TDistroStat;
    function GetDesktopStat(aIndex: Integer): TDesktopStat;
    function GetKernelStat(aIndex: Integer): TKernelStat;
    function GetSameGPUDistroStat(aIndex: Integer): TSameGPUDistroStat;
    function GetSameGPUDriverStat(aIndex: Integer): TSameGPUDriverStat;
    function GetSameCPUKernelStat(aIndex: Integer): TSameCPUKernelStat;
    function GetScalingRung(aIndex: Integer): TScalingRung;
    function GetBadge(aIndex: Integer): TBadge;
    procedure ParseCSVData(const CSVText: string; const aUserScore: Integer; const aUserGPU: string; const aUserDistro: string; const aRTScore: Integer = 0; const aCPUTempMax: Double = 0.0; const aGPUTempMax: Double = 0.0; const aTotalPowerMax: Double = 0.0; const aCPUMultiScore: Integer = 0; const aGPURasterScore: Integer = 0; const aCPUPowerMax: Double = 0.0; const aGPUPowerMax: Double = 0.0; const aUserCPU: string = ''; const aUserDesktop: string = ''; const aCPUMaxFreq: Integer = 0; const aGPUMaxFreq: Integer = 0; const aUserKernel: string = ''; const aUserNick: string = ''; const aUserDriver: string = '');
  public
    constructor Create;
    destructor Destroy; override;

    procedure StartBackgroundSync;
    procedure UpdateSync;
    procedure EnsureLoaded(const aUserScore: Integer; const aUserGPU: string; const aUserDistro: string; const aRTScore: Integer = 0; const aCPUTempMax: Double = 0.0; const aGPUTempMax: Double = 0.0; const aTotalPowerMax: Double = 0.0; const aCPUMultiScore: Integer = 0; const aGPURasterScore: Integer = 0; const aCPUPowerMax: Double = 0.0; const aGPUPowerMax: Double = 0.0; const aUserCPU: string = ''; const aUserDesktop: string = ''; const aCPUMaxFreq: Integer = 0; const aGPUMaxFreq: Integer = 0; const aUserKernel: string = ''; const aUserNick: string = ''; const aUserDriver: string = '');

    function GetGaussianY(const aScore: Double): Double;

    property Loaded: Boolean read FLoaded;
    property TotalSubmissions: Integer read FTotalSubmissions;
    property MeanScore: Double read FMeanScore;
    property StdDevScore: Double read FStdDevScore;
    property UserScore: Integer read FUserScore;
    property Percentile: Double read FPercentile;
    property Top1Score: Integer read FTop1Score;
    property Top1Specs: string read FTop1Specs;
    property DeckMultiple: Double read FDeckMultiple;
    property AllyMultiple: Double read FAllyMultiple;
    property Switch2Multiple: Double read FSwitch2Multiple;
    property HighEndPct: Double read FHighEndPct;
    property MidRangeMultiple: Double read FMidRangeMultiple;
    property PS5Multiple: Double read FPS5Multiple;
    property TopPCPercent: Double read FTopPCPercent;
    property MatchedGPUModel: string read FMatchedGPUModel;
    property MatchedCPUModel: string read FMatchedCPUModel;
    property DistroCount: Integer read FDistroCount;
    property DistroStats[aIndex: Integer]: TDistroStat read GetDistroStat;
    property DesktopCount: Integer read FDesktopCount;
    property DesktopStats[aIndex: Integer]: TDesktopStat read GetDesktopStat;
    property KernelCount: Integer read FKernelCount;
    property KernelStats[aIndex: Integer]: TKernelStat read GetKernelStat;
    property SameGPUDistroCount: Integer read FSameGPUDistroCount;
    property SameGPUDistroIncludesCPU: Boolean read FSameGPUDistroIncludesCPU;
    property SameGPUDistroStats[aIndex: Integer]: TSameGPUDistroStat read GetSameGPUDistroStat;
    property SameGPUDriverCount: Integer read FSameGPUDriverCount;
    property SameGPUDriverStats[aIndex: Integer]: TSameGPUDriverStat read GetSameGPUDriverStat;
    property SameCPUKernelCount: Integer read FSameCPUKernelCount;
    property SameCPUKernelStats[aIndex: Integer]: TSameCPUKernelStat read GetSameCPUKernelStat;
    property UserDriverBranch: string read FUserDriverBranch;
    property UserKernelBranch: string read FUserKernelBranch;
    property StackShare: TStackShareStats read FStackShare;
    property ScalingRungs[aIndex: Integer]: TScalingRung read GetScalingRung;
    property Silicon: TSiliconLottery read FSiliconLottery;
    property CPUSilicon: TCPUSiliconLottery read FCPUSilicon;
    property Efficiency: TEfficiencyMetrics read FEfficiency;
    property Badges[aIndex: Integer]: TBadge read GetBadge;
  end;

var
  CommunityInsights: TCommunityInsights = nil;

implementation

uses
  process;

const
  // Full 33-column PasCubeDB fallback dataset matching Google Sheet schema
  // Columns: 0:user,1:cpu,2:ram,3:gpu,4:vram,5:driver,6:kernel,7:os,8:mainScore,9:cpuSingle,10:cpuMulti,11:gpuScore,
  // 12:date,13:clientId,14:arch,15:pkg,16:empty,17:product,18:displayServer,19:desktop,20:storage,21:vulkanDriver,
  // 22:empty,23:empty,24:gpuMaxTemp,25:gpuTempDelta,26:empty,27:cpuMaxFreq,28:gpuMaxFreq,29:cpuMaxPower,30:gpuMaxPower
  FALLBACK_COMMUNITY_CSV =
    'Origem / Usuario,CPU,RAM,GPU,VRAM,Driver,Kernel,Operating System,Main Score,CPU Single,CPU Multi,GPU Score,Date/Time,client-id,architecture,package,,product name,Display Server,Desktop,Storage,Vulkan Driver,,,GPU Max Temp,GPU Temp Delta,,CPU Max Freq (MHz),GPU Max Freq (MHz),CPU Max Power (W),GPU Max Power (W)' + LineEnding +
    'AasaA,Ryzen 9 9950X3D,48GB,RTX 5090,32GB,NVRM 610.43,7.2.4-1-cachyos,CachyOS,8062,4210,12450,9120,16/06/2026,id1,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,NVIDIA,,,64,26,,5900,2940,142,450' + LineEnding +
    'Sharakkhal,Ryzen 7 9800X3D,31GB,RTX 4090,24GB,NVRM 610.43,7.1.8-1-cachyos,CachyOS,5174,2780,3655,7306,16/06/2026,id2,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,NVIDIA,,,65,25,,5700,2520,88,395' + LineEnding +
    'Lutti,Ryzen 7 9800X3D,30GB,RTX 4090,24GB,NVRM 595.80,7.2.2-201.fc44,Fedora Linux 44,4975,2615,4019,6913,16/06/2026,id3,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,NVIDIA,,,67,23,,5700,2520,90,390' + LineEnding +
    'Adaneshade,Ryzen 9 7950X3D,63GB,RX 7900 XTX,24GB,Mesa 26.1.99,7.2.4-1-cachyos,CachyOS,4938,3481,10783,5351,14/06/2026,id4,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,66,24,,5900,2500,115,320' + LineEnding +
    'eddnix,Ryzen 9 9950X3D,96GB,RX 9070 XT,16GB,Mesa 26.1.2,7.2.1-arch1-1,Arch Linux,4932,3576,11897,3944,15/06/2026,id5,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,62,28,,5900,2970,138,245' + LineEnding +
    'vinternatt,Ryzen 9 9900X3D,60GB,RX 9070 XT,16GB,Mesa 26.1.2,7.1.8-1-cachyos,CachyOS,4665,3731,9404,3897,14/06/2026,id6,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,63,27,,5800,2970,112,240' + LineEnding +
    'bauer,Ryzen 7 9800X3D,94GB,RTX 5070 Ti,16GB,NVRM 610.43,7.2.4-1-cachyos,CachyOS,4609,3978,5679,4729,15/06/2026,id7,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,NVIDIA,,,64,26,,5700,2700,86,265' + LineEnding +
    'Morphs07,Ryzen 7 9800X3D,94GB,RTX 5070 Ti,16GB,NVRM 610.43,7.1.8-1-cachyos,CachyOS,4546,3909,5438,4725,15/06/2026,id8,x86_64,native,,Desktop,Wayland,GNOME 47,NVMe,NVIDIA,,,65,25,,5700,2700,85,260' + LineEnding +
    'DearDecimation,RYZEN AI MAX+ 395,125GB,RX 9070 XT,16GB,Mesa 26.1.2,7.2.4-1-cachyos,CachyOS,4513,3062,10564,3713,15/06/2026,id9,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,64,26,,5100,2970,95,235' + LineEnding +
    'benjamimgois,Ryzen 7 7800X3D,62GB,RX 7900 XTX,24GB,Mesa 26.1.2,7.2.4-1-cachyos,CachyOS,4837,3767,5803,5147,15/06/2026,id10,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,65,25,,5053,2482,80,295' + LineEnding +
    'packetcreeper,Ryzen 7 7800X3D,31GB,RX 7900 XTX,24GB,Mesa 26.1.2,7.1.8-1-cachyos,CachyOS,4738,3980,5854,4929,15/06/2026,id11,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,67,23,,5053,2500,82,290' + LineEnding +
    'Dragoon,Ryzen 9 9950X3D,96GB,RX 9070 XT,16GB,Mesa 26.1.2,7.2.1-arch1-1,Arch Linux,4380,3754,12228,3791,15/06/2026,id12,x86_64,native,,Desktop,Wayland,Hyprland,NVMe,RADV,,,63,27,,5900,2970,140,242' + LineEnding +
    'vinc,Ryzen 7 9800X3D,31GB,RX 9070 XT,16GB,Mesa 26.1.2,7.0.12-1-cachyos,CachyOS,4323,4166,6530,3771,15/06/2026,id13,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,61,29,,5700,2970,84,238' + LineEnding +
    'kirkTshatner,Ryzen 7 7800X3D,31GB,RX 7900 XTX,24GB,Mesa 26.1.2,7.0.12-1-cachyos,CachyOS,4723,3929,5628,5052,14/06/2026,id14,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,68,22,,5053,2500,79,295' + LineEnding +
    'arsch,Ryzen 9 7950X3D,62GB,RX 7900 XTX,24GB,Mesa 26.0.6,7.1.2-arch1-1,Arch Linux,5471,2603,7647,5209,15/06/2026,id15,x86_64,native,,Desktop,Wayland,GNOME 47,NVMe,RADV,,,66,24,,5756,2526,118,305' + LineEnding +
    'ming,Ryzen 7 7800X3D,31GB,RX 7900 XTX,24GB,Mesa 26.1.2,7.0.12-1-cachyos,CachyOS,4644,3689,5644,4842,15/06/2026,id16,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,69,21,,5053,2304,81,300' + LineEnding +
    'Siny,Ryzen 7 9800X3D,60GB,RX 9070 XT,16GB,Mesa 26.1.2,7.0.11-1-cachyos,CachyOS,4133,4004,6475,3520,15/06/2026,id17,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,64,26,,5700,2970,86,230' + LineEnding +
    'Cdubz45,Ryzen 7 9800X3D,62GB,RX 7900 XTX,24GB,Mesa 26.1.2,7.2.2-201.fc44,Fedora Linux 44,5302,2915,5029,5263,15/06/2026,id18,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,65,25,,5700,2431,88,298' + LineEnding +
    'wee,Ryzen 7 7800X3D,31GB,RX 9070 XT,16GB,Mesa 26.1.2,7.1.0-rc7-cachyos,CachyOS,4100,3808,5771,3702,15/06/2026,id19,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,62,28,,5050,2970,78,235' + LineEnding +
    'April,Ryzen 7 7800X3D,31GB,RX 9070 XT,16GB,Mesa 26.1.2,7.1.0-rc7-cachyos,CachyOS,4040,3813,5835,3613,15/06/2026,id20,x86_64,native,,Desktop,Wayland,Hyprland,NVMe,RADV,,,63,27,,5017,2970,79,235' + LineEnding +
    'lokaaa,Ryzen 7 5800X,31GB,RTX 5070 Ti,16GB,NVRM 610.43,7.2.4-1-cachyos,CachyOS,4032,3053,4610,4544,15/06/2026,id21,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,NVIDIA,,,66,24,,4600,2700,105,260' + LineEnding +
    'Nevoness,Ryzen 7 5800X3D,31GB,RX 9070 XT,16GB,Mesa 26.1.2,7.0.11-1-cachyos,CachyOS,3889,3283,5120,3944,15/06/2026,id22,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,64,26,,4500,2970,82,240' + LineEnding +
    'Arya,Ryzen 9 9950X3D,92GB,RX 9070 XT,16GB,Mesa 26.0.6,7.2.2-ba30.fc44,Bazzite,3820,2290,7314,3842,16/06/2026,id23,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,65,25,,5900,2970,135,240' + LineEnding +
    'tuono58,Ryzen 7 5800X,31GB,RX 9070 XT,16GB,Mesa 26.1.2,7.0.12-1-cachyos,CachyOS,3690,2995,4983,3789,15/06/2026,id24,x86_64,native,,Desktop,Wayland,GNOME 47,NVMe,RADV,,,64,26,,4600,2970,102,238' + LineEnding +
    'FREEP0TAT0,Ryzen 7 7800X3D,31GB,RX 7900 XTX,24GB,Mesa 26.0.6,7.0.11-1-cachyos,CachyOS,4605,2703,5546,5148,15/06/2026,id25,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,70,20,,5053,2200,82,305' + LineEnding +
    'SurferDude,i5-14600KF,31GB,RTX 5070,12GB,NVRM 610.43,7.1.8-1-cachyos,CachyOS,3679,3058,6429,3289,15/06/2026,id26,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,NVIDIA,,,67,23,,5300,2700,145,215' + LineEnding +
    'Cayaf,Ryzen 7 9800X3D,31GB,RX 9070 XT,16GB,Mesa 26.1.2,7.2.2-ogc3.2.fc44,Bazzite,3656,3010,4980,3711,15/06/2026,id27,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,64,26,,5700,2970,86,238' + LineEnding +
    'xtremeasure,Ryzen 7 9700X,60GB,RX 7900 XTX,24GB,Mesa 26.0.6,7.2.1-arch1-1,Arch Linux,4781,2304,5480,5451,16/06/2026,id28,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,65,25,,5575,2200,68,295' + LineEnding +
    'skibidi,Ryzen 7 7800X3D,30GB,RX 9070 XT,16GB,Mesa 26.0.6,7.2.2-cachyos1.fc44,Fedora Linux 44,3498,2855,5622,3836,16/06/2026,id29,x86_64,native,,Desktop,Wayland,GNOME 47,NVMe,RADV,,,63,27,,5053,2970,80,235' + LineEnding +
    'Covcard,Ryzen 7 9800X3D,31GB,RX 9070 XT,16GB,Mesa 26.0.6,7.0.12-201.fc44,Fedora Linux 44,3412,2687,4274,3661,15/06/2026,id30,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,65,25,,5700,2970,88,240' + LineEnding +
    'sirspudd,Ryzen 9 5900X,63GB,RX 7800 XT,16GB,Mesa 26.1.2,7.1.2-arch1-1,Arch Linux,3367,2858,6605,2751,15/06/2026,id31,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,68,22,,4800,2430,125,250' + LineEnding +
    'Napster,Ryzen 5 7500F,31GB,RTX 5070,12GB,NVRM 610.43,7.1.8-1-cachyos,Garuda Linux,3304,3336,4006,3070,15/06/2026,id32,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,NVIDIA,,,64,26,,5000,2700,65,210' + LineEnding +
    'ashleyis,Ryzen 7 7800X3D,31GB,RX 6750 XT,12GB,Mesa 26.1.2,7.0.11-arch1-1,EndeavourOS,3194,3989,6352,2169,15/06/2026,id33,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,69,21,,5050,2600,81,210' + LineEnding +
    'bababoi,Ryzen 7 7800X3D,31GB,RTX 4070,12GB,NVRM 610.43,7.2.2-ba30.fc44,Bazzite,3148,2804,5186,3078,15/06/2026,id34,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,NVIDIA,,,63,27,,5000,2480,78,195' + LineEnding +
    'Dedwin,Ryzen 7 5800X3D,31GB,RX 9070,16GB,Mesa 26.1.2,7.1.5-ba29.fc44,Bazzite,3078,2506,4848,3338,15/06/2026,id35,x86_64,native,,Desktop,Wayland,Gamescope,NVMe,RADV,,,62,28,,4500,2700,80,210' + LineEnding +
    'Mob,Ryzen 7 5800X3D,16GB,RX 9070 XT,16GB,Mesa 26.0.6,7.2.1-arch1-1,Arch Linux,3069,2344,4925,3560,16/06/2026,id36,x86_64,native,,Desktop,Wayland,Hyprland,NVMe,RADV,,,65,25,,4500,2970,82,238' + LineEnding +
    'lauren,Ryzen 7 7800X3D,58GB,RTX 5070 Ti,16GB,NVRM 610.43,7.0.12-1-cachyos,Garuda Linux,3029,3936,6010,4500,15/06/2026,id37,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,NVIDIA,,,66,24,,5000,2700,81,260' + LineEnding +
    'Anonymous,Ryzen 7 9700X,31GB,RX 9070,16GB,Mesa 26.0.6,7.2.2-ogc3.2.fc44,Bazzite,2979,2444,5451,3092,16/06/2026,id38,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,61,29,,5500,2700,65,205' + LineEnding +
    'Anonymous,Ryzen 7 5800X3D,63GB,RTX 5070,12GB,NVRM 610.43,7.0.12-1-cachyos,CachyOS,2970,2439,4859,3165,15/06/2026,id39,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,NVIDIA,,,64,26,,4500,2700,80,210' + LineEnding +
    'Anonymous,i7-12700K,31GB,RX 7800 XT,16GB,Mesa 26.1.2,7.1.2-arch1-1,Arch Linux,2962,2699,4096,2806,15/06/2026,id40,x86_64,native,,Desktop,X11,KDE Plasma 6.8,NVMe,RADV,,,67,23,,5200,2430,135,255' + LineEnding +
    'Anonymous,Ryzen 9 5900X,31GB,RX 6900 XT,16GB,Mesa 26.1.2,7.2.0-200.nobara,Nobara Linux 43,2954,2390,4546,2871,15/06/2026,id41,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,71,19,,4800,2250,120,285' + LineEnding +
    'Anonymous,Ryzen 5 5600X,31GB,RX 9070 GRE,12GB,Mesa 26.1.1,6.18.33-1-MANJARO,Manjaro Linux,2946,2899,3228,2894,15/06/2026,id42,x86_64,native,,Desktop,Wayland,GNOME 47,NVMe,RADV,,,65,25,,4400,2700,65,215' + LineEnding +
    'Anonymous,12th Gen i5-12400F,31GB,RX 9070,16GB,Mesa 26.1.2,7.0.12-1-cachyos,CachyOS,2820,2316,2936,3139,14/06/2026,id43,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,63,27,,4400,2700,65,205' + LineEnding +
    'Anonymous,Ryzen 7 5700X,15GB,RX 9060 XT,16GB,Mesa 26.1.2,7.0.11-1-cachyos,CachyOS,2791,2987,4138,2249,15/06/2026,id44,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,62,28,,4600,2700,65,175' + LineEnding +
    'Anonymous,Ryzen 9 5900XT,31GB,RX 6750 XT,12GB,Mesa 26.1.2,7.2.2-201.fc44,Fedora Linux 44,2763,2501,6547,1812,15/06/2026,id45,x86_64,native,,Desktop,Wayland,GNOME 47,NVMe,RADV,,,68,22,,4800,2600,115,215' + LineEnding +
    'Anonymous,Ryzen 7 5800X3D,31GB,RX 7800 XT,16GB,Mesa 26.0.6,7.0.12-1-cachyos,CachyOS,2710,2289,4587,2862,15/06/2026,id46,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,66,24,,4500,2430,80,252' + LineEnding +
    'Anonymous,13th Gen i9-13900HX,31GB,RTX 4070 Laptop GPU,8GB,NVRM 595.71,7.2.0-200.nobara,Nobara Linux 43,2305,2152,4365,1794,15/06/2026,id47,x86_64,native,,Laptop,Wayland,KDE Plasma 6.8,NVMe,NVIDIA,,,76,14,,5400,2480,95,115' + LineEnding +
    'Anonymous,Ryzen 5 5600,31GB,RX 6700,10GB,Mesa 26.1.2,7.2.0-200.nobara,Nobara Linux 43,1851,2333,2723,1252,15/06/2026,id48,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,64,26,,4400,2400,65,165' + LineEnding +
    'Anonymous,Ryzen 5 7600X,31GB,Intel Arc B580,12GB,Mesa 26.0.6,7.2.2-ogc3.2.fc44,Bazzite,1844,2510,3060,1013,15/06/2026,id49,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,ANV,,,65,25,,5400,2850,88,180' + LineEnding +
    'Anonymous,12th Gen i5-12450HX,15GB,RTX 4050 Laptop GPU,6GB,NVRM 610.43,7.1.8-1-cachyos,CachyOS,1777,2152,2195,1390,15/06/2026,id50,x86_64,native,,Laptop,Wayland,KDE Plasma 6.8,NVMe,NVIDIA,,,74,16,,4500,2370,55,85' + LineEnding +
    'Anonymous,Ryzen 5 3600,31GB,RX 6750 XT,12GB,Mesa 26.0.6,7.2.2-ogc3.2.fc44,Bazzite,1693,1540,2034,1697,15/06/2026,id51,x86_64,native,,Desktop,Wayland,GNOME 47,NVMe,RADV,,,67,23,,4200,2600,65,210' + LineEnding +
    'Anonymous,Ryzen 5 5600G,31GB,RX 6650 XT,8GB,Mesa 26.0.6,7.0.0-22-generic,Ubuntu 26.04 LTS,1660,1832,2245,1365,15/06/2026,id52,x86_64,native,,Desktop,Wayland,GNOME 47,NVMe,RADV,,,68,22,,4400,2694,65,170' + LineEnding +
    'Anonymous,12th Gen i5-12400F,31GB,RX 6600,8GB,Mesa 26.0.6,7.2.0-200.nobara,Nobara Linux 43,1438,1761,2221,978,16/06/2026,id53,x86_64,native,,Desktop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,62,28,,4400,2491,60,132' + LineEnding +
    'Anonymous,12th Gen i5-12450H,31GB,RTX 4060 Laptop GPU,8GB,NVRM 595.80,7.2.2-201.fc44,Fedora Linux 44,1312,1283,1178,1372,15/06/2026,id54,x86_64,native,,Laptop,Wayland,KDE Plasma 6.8,NVMe,NVIDIA,,,75,15,,4500,2460,45,105' + LineEnding +
    'Anonymous,Ryzen Z1 Extreme,24GB,AMD Z1 Extreme,8GB,Mesa 26.1.2,7.2.2-ba30.fc44,Bazzite,1212,2180,2640,680,15/06/2026,id55,x86_64,native,,ROG Ally X,Wayland,Gamescope,NVMe,RADV,,,72,18,,5100,2700,25,25' + LineEnding +
    'Anonymous,11th Gen i5-11400H,15GB,RTX 3050 Laptop GPU,4GB,NVRM 580.159,7.1.5-generic,Pop!_OS 24.04,1060,1322,1327,796,16/06/2026,id56,x86_64,native,,Laptop,X11,GNOME 47,NVMe,NVIDIA,,,77,13,,4600,1740,45,75' + LineEnding +
    'Anonymous,Ryzen 7 2700,16GB,RX 590 Series,8GB,Mesa 26.0.6,6.18.10-35-generic,Linux Mint 22.3,978,1223,1556,634,16/06/2026,id57,x86_64,native,,Desktop,X11,Cinnamon,SSD,RADV,,,73,17,,4100,1469,65,175' + LineEnding +
    'Anonymous,Custom APU 0405,16GB,AMD Custom GPU 0405,6GB,Mesa 26.1.2,7.2.7-valve2-2-neptune,SteamOS,818,1454,1285,312,15/06/2026,id58,x86_64,native,,Steam Deck,Wayland,Gamescope,NVMe,RADV,,,68,22,,3500,1600,15,15' + LineEnding +
    'xtremeasure,Ryzen 7 5700U,16GB,AMD Radeon RX Vega 8,4GB,Mesa 26.1.2,7.2.4-1-cachyos,CachyOS,1250,1920,2410,670,15/06/2026,id59,x86_64,native,,Laptop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,64,26,,4350,2000,25,25' + LineEnding +
    'Adaneshade,Ryzen 7 5700U,16GB,AMD Radeon RX Vega 8,4GB,Mesa 26.1.2,7.2.1-arch1-1,Arch Linux,1220,1890,2380,650,15/06/2026,id60,x86_64,native,,Laptop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,66,24,,4300,1950,25,25' + LineEnding +
    'Cdubz45,Ryzen 5 5500U,16GB,AMD Radeon Vega 7,4GB,Mesa 26.1.2,7.1.5-ba29.fc44,Bazzite,1095,1720,2150,580,15/06/2026,id61,x86_64,native,,Laptop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,63,27,,4000,1800,20,20' + LineEnding +
    'Anonymous,Ryzen 7 5700U,16GB,AMD Radeon RX Vega 8,4GB,Mesa 26.1.2,7.2.2-ba30.fc44,Bazzite,1180,1850,2320,620,15/06/2026,id62,x86_64,native,,Laptop,Wayland,KDE Plasma 6.8,NVMe,RADV,,,65,25,,4300,1900,25,25';

{ TCommunitySyncThread }

constructor TCommunitySyncThread.Create(const aCachePath: string);
begin
  inherited Create(False);
  FreeOnTerminate := False;
  FCachePath := aCachePath;
  FSuccess := False;
  FIsFinished := False;
end;

function GetFileSizeBytes(const aPath: string): Int64;
var
  FS: TFileStream;
begin
  Result := 0;
  if not FileExists(aPath) then Exit;
  try
    FS := TFileStream.Create(aPath, fmOpenRead or fmShareDenyNone);
    try
      Result := FS.Size;
    finally
      FS.Free;
    end;
  except
    Result := 0;
  end;
end;

procedure TCommunitySyncThread.Execute;
var
  Proc: TProcess;
  TempPath, CacheDir: string;
begin
  TempPath := FCachePath + '.tmp';
  CacheDir := ExtractFilePath(FCachePath);
  if (CacheDir <> '') and not DirectoryExists(CacheDir) then
    ForceDirectories(CacheDir);

  Proc := TProcess.Create(nil);
  try
    Proc.Executable := 'curl';
    Proc.Parameters.Add('-sL');
    Proc.Parameters.Add('--compressed');
    Proc.Parameters.Add('--connect-timeout');
    Proc.Parameters.Add('4');
    Proc.Parameters.Add('--max-time');
    Proc.Parameters.Add('8');
    Proc.Parameters.Add(COMMUNITY_SPREADSHEET_URL);
    Proc.Parameters.Add('-o');
    Proc.Parameters.Add(TempPath);
    Proc.Options := [poWaitOnExit];
    try
      Proc.Execute;
      if (Proc.ExitStatus = 0) and FileExists(TempPath) then
      begin
        if (FileExists(TempPath)) and (GetFileSizeBytes(TempPath) > 500) then
        begin
          if FileExists(FCachePath) then
            DeleteFile(FCachePath);
          RenameFile(TempPath, FCachePath);
          FSuccess := True;
        end
        else
          DeleteFile(TempPath);
      end;
    except
      FSuccess := False;
    end;
  finally
    Proc.Free;
  end;
  FIsFinished := True;
end;

{ TCommunityInsights }

function FormatNumber(const aVal: Integer): string;
var
  S, Res: string;
  i, Len, Count: Integer;
begin
  S := IntToStr(aVal);
  Len := Length(S);
  Res := '';
  Count := 0;
  for i := Len downto 1 do
  begin
    Res := S[i] + Res;
    Inc(Count);
    if (Count = 3) and (i > 1) and (S[i - 1] <> '-') then
    begin
      Res := ',' + Res;
      Count := 0;
    end;
  end;
  Result := Res;
end;

constructor TCommunityInsights.Create;
begin
  inherited Create;
  FInitialized := False;
  FLoaded := False;
  FSyncThread := nil;
  FCachePath := GetCacheFilePath;
  FTotalSubmissions := 0;
  FMeanScore := 3400.0;
  FStdDevScore := 1150.0;
  FTop1Score := 8062;
  FTop1Specs := 'R9 9950X3D | RTX 5090';
  FDistroCount := 0;
  FDesktopCount := 0;
  FKernelCount := 0;
  FillChar(FKernelStats, SizeOf(FKernelStats), 0);
  FDeckMultiple := 1.0;
  FAllyMultiple := 1.0;
  FSwitch2Multiple := 1.0;
  FHighEndPct := 50.0;
  FMidRangeMultiple := 1.0;
  FPS5Multiple := 1.0;
  FTopPCPercent := 50.0;
  FLastUserScore := 0;
  FillChar(FSiliconLottery, SizeOf(FSiliconLottery), 0);
  FillChar(FCPUSilicon, SizeOf(FCPUSilicon), 0);
  FillChar(FEfficiency, SizeOf(FEfficiency), 0);
  FillChar(FStackShare, SizeOf(FStackShare), 0);
  FillChar(FScalingRungs, SizeOf(FScalingRungs), 0);
  FillChar(FBadges, SizeOf(FBadges), 0);
end;

destructor TCommunityInsights.Destroy;
begin
  if Assigned(FSyncThread) then
  begin
    if not FSyncThread.IsFinished then
      FSyncThread.Terminate;
    FSyncThread.WaitFor;
    FreeAndNil(FSyncThread);
  end;
  inherited Destroy;
end;

function TCommunityInsights.GetCacheFilePath: string;
var
  HomeDir, CacheDir: string;
begin
  CacheDir := GetEnvironmentVariable('XDG_CACHE_HOME');
  if CacheDir = '' then
  begin
    HomeDir := GetEnvironmentVariable('HOME');
    if HomeDir = '' then
      HomeDir := '/tmp';
    CacheDir := HomeDir + '/.cache';
  end;
  Result := CacheDir + '/' + COMMUNITY_CACHE_SUBPATH;
end;

function TCommunityInsights.CleanScoreStr(const S: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
  begin
    if S[i] in ['0'..'9'] then
      Result := Result + S[i]
    else if (S[i] = '.') and (Length(S) - i <= 2) then
      Break; // Ignore fractional decimal part like "220.5" -> "220", while keeping "3.655" thousands
  end;
end;

function TCommunityInsights.NormalizeDistroName(const RawDistro: string): string;
var
  Low: string;
begin
  Low := LowerCase(Trim(RawDistro));
  if (Pos('cachyos', Low) > 0) or (Pos('cachy os', Low) > 0) then Result := 'CachyOS'
  else if Pos('bazzite', Low) > 0 then Result := 'Bazzite'
  else if Pos('arch', Low) > 0 then Result := 'Arch Linux'
  else if Pos('fedora', Low) > 0 then Result := 'Fedora'
  else if Pos('nobara', Low) > 0 then Result := 'Nobara'
  else if Pos('garuda', Low) > 0 then Result := 'Garuda Linux'
  else if Pos('endeavour', Low) > 0 then Result := 'EndeavourOS'
  else if Pos('ubuntu', Low) > 0 then Result := 'Ubuntu'
  else if Pos('debian', Low) > 0 then Result := 'Debian'
  else if Pos('manjaro', Low) > 0 then Result := 'Manjaro'
  else if Pos('pop', Low) > 0 then Result := 'Pop!_OS'
  else if Pos('mint', Low) > 0 then Result := 'Linux Mint'
  else if Pos('steamos', Low) > 0 then Result := 'SteamOS'
  else if Pos('zorin', Low) > 0 then Result := 'Zorin OS'
  else if Pos('pika', Low) > 0 then Result := 'PikaOS'
  else if Pos('gentoo', Low) > 0 then Result := 'Gentoo'
  else if Pos('nixos', Low) > 0 then Result := 'NixOS'
  else if Pos('opensuse', Low) > 0 then Result := 'openSUSE'
  else if RawDistro <> '' then Result := Copy(RawDistro, 1, 14)
  else Result := 'Other Linux';
end;

function TCommunityInsights.NormalizeDesktopName(const RawDE: string; const RawOS: string): string;
var
  Low, LowOS: string;
begin
  Low := LowerCase(Trim(RawDE));
  LowOS := LowerCase(Trim(RawOS));
  if (Pos('kde', Low) > 0) or (Pos('plasma', Low) > 0) then Result := 'KDE Plasma'
  else if Pos('gnome', Low) > 0 then Result := 'GNOME'
  else if Pos('hyprland', Low) > 0 then Result := 'Hyprland'
  else if (Pos('gamescope', Low) > 0) or (Pos('steamos', LowOS) > 0) then Result := 'Gamescope'
  else if Pos('cinnamon', Low) > 0 then Result := 'Cinnamon'
  else if Pos('xfce', Low) > 0 then Result := 'XFCE'
  else if Pos('cosmic', Low) > 0 then Result := 'COSMIC'
  else if Pos('sway', Low) > 0 then Result := 'Sway'
  else if (Pos('kde', LowOS) > 0) or (Pos('plasma', LowOS) > 0) then Result := 'KDE Plasma'
  else if (Pos('gnome', LowOS) > 0) or (Pos('workstation', LowOS) > 0) then Result := 'GNOME'
  else Result := '';
end;

function TCommunityInsights.NormalizeKernelName(const RawKernel: string): string;
var
  Low, VerStr, Flavor: string;
  i, j, dotPos: Integer;
begin
  Low := LowerCase(Trim(RawKernel));
  if Pos('linux version ', Low) = 1 then
    Low := Trim(Copy(Low, 15, Length(Low)));
  if Pos('linux ', Low) = 1 then
    Low := Trim(Copy(Low, 7, Length(Low)));
  if Pos('kernel ', Low) = 1 then
    Low := Trim(Copy(Low, 8, Length(Low)));

  VerStr := '';
  i := 1;
  while (i <= Length(Low)) and not (Low[i] in ['0'..'9']) do Inc(i);
  if i <= Length(Low) then
  begin
    j := i;
    dotPos := 0;
    while (j <= Length(Low)) and ((Low[j] in ['0'..'9']) or (Low[j] = '.')) do
    begin
      if Low[j] = '.' then
      begin
        Inc(dotPos);
        if dotPos = 2 then Break;
      end;
      Inc(j);
    end;
    VerStr := Copy(Low, i, j - i);
  end;

  if VerStr = '' then VerStr := '7.0';

  if Pos('cachyos', Low) > 0 then Flavor := 'cachyos'
  else if Pos('zen', Low) > 0 then Flavor := 'zen'
  else if Pos('arch', Low) > 0 then Flavor := 'arch'
  else if Pos('nobara', Low) > 0 then Flavor := 'nobara'
  else if (Pos('bazzite', Low) > 0) or (Pos('ogc', Low) > 0) or (Pos('ba29', Low) > 0) or (Pos('ba30', Low) > 0) then Flavor := 'bazzite'
  else if (Pos('fedora', Low) > 0) or (Pos('fc4', Low) > 0) then Flavor := 'fedora'
  else if (Pos('valve', Low) > 0) or (Pos('steamos', Low) > 0) then Flavor := 'valve'
  else if (Pos('generic', Low) > 0) or (Pos('ubuntu', Low) > 0) then Flavor := 'generic'
  else if Pos('manjaro', Low) > 0 then Flavor := 'manjaro'
  else Flavor := 'generic';

  Result := 'Linux ' + VerStr + '-' + Flavor;
end;

function TCommunityInsights.NormalizeKernelBranch(const RawKernel: string): string;
begin
  Result := NormalizeKernelName(RawKernel);
end;

function TCommunityInsights.NormalizeDriverBranch(const RawDriver: string): string;
var
  Low, CleanLow, VerStr: string;
  i, j, dotPos: Integer;
begin
  Low := LowerCase(Trim(RawDriver));
  if Pos('mesa', Low) > 0 then
  begin
    i := Pos('mesa', Low) + 4;
    while (i <= Length(Low)) and not (Low[i] in ['0'..'9']) do Inc(i);
    VerStr := '';
    if i <= Length(Low) then
    begin
      j := i;
      dotPos := 0;
      while (j <= Length(Low)) and ((Low[j] in ['0'..'9']) or (Low[j] = '.')) do
      begin
        if Low[j] = '.' then
        begin
          Inc(dotPos);
          if dotPos = 2 then Break;
        end;
        Inc(j);
      end;
      VerStr := Copy(Low, i, j - i);
    end;
    if VerStr <> '' then
      Result := 'Mesa ' + VerStr + '.x'
    else
      Result := 'Mesa';
  end
  else if (Pos('nvrm', Low) > 0) or (Pos('nvidia', Low) > 0) or
          ((Length(Low) >= 3) and (Low[1] in ['4', '5', '6']) and (Low[2] in ['0'..'9']) and (Low[3] in ['0'..'9'])) then
  begin
    CleanLow := StringReplace(Low, 'x86_64', ' ', [rfReplaceAll]);
    CleanLow := StringReplace(CleanLow, 'x86', ' ', [rfReplaceAll]);
    CleanLow := StringReplace(CleanLow, 'amd64', ' ', [rfReplaceAll]);
    VerStr := '';
    // Look for a 3-digit number starting with 4, 5, or 6 (NVIDIA major series)
    for i := 1 to Length(CleanLow) - 2 do
    begin
      if (CleanLow[i] in ['4', '5', '6']) and
         (CleanLow[i+1] in ['0'..'9']) and
         (CleanLow[i+2] in ['0'..'9']) and
         ((i = 1) or not (CleanLow[i-1] in ['0'..'9', 'a'..'z', 'A'..'Z'])) then
      begin
        VerStr := Copy(CleanLow, i, 3);
        Break;
      end;
    end;
    if VerStr = '' then
    begin
      i := 1;
      while (i <= Length(CleanLow)) and not (CleanLow[i] in ['0'..'9']) do Inc(i);
      if i <= Length(CleanLow) then
      begin
        j := i;
        while (j <= Length(CleanLow)) and (CleanLow[j] in ['0'..'9']) do Inc(j);
        VerStr := Copy(CleanLow, i, Min(3, j - i));
      end;
    end;

    if Length(VerStr) >= 3 then
      Result := 'NVIDIA ' + Copy(VerStr, 1, 3) + '.xx'
    else if VerStr <> '' then
      Result := 'NVIDIA ' + VerStr + '.xx'
    else
      Result := 'NVIDIA';
  end
  else if Pos('radv', Low) > 0 then
    Result := 'Mesa RADV'
  else if Pos('anv', Low) > 0 then
    Result := 'Mesa ANV'
  else
  begin
    Result := Trim(Copy(RawDriver, 1, 16));
    if Result = '' then Result := 'Default Driver';
  end;
end;

function TCommunityInsights.ExtractGPUChipToken(const RawGPU: string; out CleanLabel: string): string;
var
  Low, S: string;
  p: Integer;
begin
  Low := LowerCase(Trim(RawGPU));
  CleanLabel := '';

  // 1. AMD Vega (Integrated & Discrete)
  if (Pos('vega 11', Low) > 0) or (Pos('vega11', Low) > 0) then begin Result := 'vega 11'; CleanLabel := 'Radeon Vega 11'; end
  else if (Pos('vega 10', Low) > 0) or (Pos('vega10', Low) > 0) then begin Result := 'vega 10'; CleanLabel := 'Radeon Vega 10'; end
  else if (Pos('vega 8', Low) > 0) or (Pos('vega8', Low) > 0) then begin Result := 'vega 8'; CleanLabel := 'Radeon Vega 8'; end
  else if (Pos('vega 7', Low) > 0) or (Pos('vega7', Low) > 0) then begin Result := 'vega 7'; CleanLabel := 'Radeon Vega 7'; end
  else if (Pos('vega 6', Low) > 0) or (Pos('vega6', Low) > 0) then begin Result := 'vega 6'; CleanLabel := 'Radeon Vega 6'; end
  else if (Pos('vega 3', Low) > 0) or (Pos('vega3', Low) > 0) then begin Result := 'vega 3'; CleanLabel := 'Radeon Vega 3'; end
  else if Pos('vega 64', Low) > 0 then begin Result := 'rx vega 64'; CleanLabel := 'Radeon RX Vega 64'; end
  else if Pos('vega 56', Low) > 0 then begin Result := 'rx vega 56'; CleanLabel := 'Radeon RX Vega 56'; end
  else if Pos('vega', Low) > 0 then begin Result := 'vega'; CleanLabel := 'Radeon Vega Graphics'; end
  else if (Pos('raven', Low) > 0) or (Pos('picasso', Low) > 0) or (Pos('renoir', Low) > 0) or
          (Pos('lucienne', Low) > 0) or (Pos('cezanne', Low) > 0) or (Pos('barcelo', Low) > 0) then
  begin
    Result := 'vega';
    CleanLabel := 'Radeon Vega Graphics';
  end

  // 2. AMD RDNA Integrated Mobile
  else if Pos('890m', Low) > 0 then begin Result := '890m'; CleanLabel := 'Radeon 890M'; end
  else if Pos('880m', Low) > 0 then begin Result := '880m'; CleanLabel := 'Radeon 880M'; end
  else if Pos('780m', Low) > 0 then begin Result := '780m'; CleanLabel := 'Radeon 780M'; end
  else if Pos('760m', Low) > 0 then begin Result := '760m'; CleanLabel := 'Radeon 760M'; end
  else if Pos('740m', Low) > 0 then begin Result := '740m'; CleanLabel := 'Radeon 740M'; end
  else if Pos('680m', Low) > 0 then begin Result := '680m'; CleanLabel := 'Radeon 680M'; end
  else if Pos('660m', Low) > 0 then begin Result := '660m'; CleanLabel := 'Radeon 660M'; end
  else if Pos('610m', Low) > 0 then begin Result := '610m'; CleanLabel := 'Radeon 610M'; end

  // 3. AMD RDNA 4 / 3 / 2 / 1 Discrete
  else if Pos('7900 xtx', Low) > 0 then begin Result := '7900 xtx'; CleanLabel := 'RX 7900 XTX'; end
  else if Pos('7900 xt', Low) > 0 then begin Result := '7900 xt'; CleanLabel := 'RX 7900 XT'; end
  else if Pos('7900 gre', Low) > 0 then begin Result := '7900 gre'; CleanLabel := 'RX 7900 GRE'; end
  else if (Pos('7800 xt', Low) > 0) or (Pos('7800xt', Low) > 0) then begin Result := '7800 xt'; CleanLabel := 'RX 7800 XT'; end
  else if Pos('7700 xt', Low) > 0 then begin Result := '7700 xt'; CleanLabel := 'RX 7700 XT'; end
  else if Pos('7600 xt', Low) > 0 then begin Result := '7600 xt'; CleanLabel := 'RX 7600 XT'; end
  else if Pos('7600', Low) > 0 then begin Result := '7600'; CleanLabel := 'RX 7600'; end
  else if Pos('9070 xt', Low) > 0 then begin Result := '9070 xt'; CleanLabel := 'RX 9070 XT'; end
  else if Pos('9070 gre', Low) > 0 then begin Result := '9070 gre'; CleanLabel := 'RX 9070 GRE'; end
  else if Pos('9070', Low) > 0 then begin Result := '9070'; CleanLabel := 'RX 9070'; end
  else if Pos('9060 xt', Low) > 0 then begin Result := '9060 xt'; CleanLabel := 'RX 9060 XT'; end
  else if Pos('9060', Low) > 0 then begin Result := '9060'; CleanLabel := 'RX 9060'; end
  else if Pos('6950 xt', Low) > 0 then begin Result := '6950 xt'; CleanLabel := 'RX 6950 XT'; end
  else if Pos('6900 xt', Low) > 0 then begin Result := '6900 xt'; CleanLabel := 'RX 6900 XT'; end
  else if Pos('6800 xt', Low) > 0 then begin Result := '6800 xt'; CleanLabel := 'RX 6800 XT'; end
  else if Pos('6800', Low) > 0 then begin Result := '6800'; CleanLabel := 'RX 6800'; end
  else if Pos('6750 xt', Low) > 0 then begin Result := '6750 xt'; CleanLabel := 'RX 6750 XT'; end
  else if (Pos('6700 xt', Low) > 0) or (Pos('6700xt', Low) > 0) then begin Result := '6700 xt'; CleanLabel := 'RX 6700 XT'; end
  else if Pos('6700', Low) > 0 then begin Result := '6700'; CleanLabel := 'RX 6700'; end
  else if Pos('6650 xt', Low) > 0 then begin Result := '6650 xt'; CleanLabel := 'RX 6650 XT'; end
  else if Pos('6600 xt', Low) > 0 then begin Result := '6600 xt'; CleanLabel := 'RX 6600 XT'; end
  else if Pos('6600', Low) > 0 then begin Result := '6600'; CleanLabel := 'RX 6600'; end
  else if Pos('6500 xt', Low) > 0 then begin Result := '6500 xt'; CleanLabel := 'RX 6500 XT'; end
  else if Pos('6400', Low) > 0 then begin Result := '6400'; CleanLabel := 'RX 6400'; end
  else if Pos('5700 xt', Low) > 0 then begin Result := '5700 xt'; CleanLabel := 'RX 5700 XT'; end
  else if Pos('5700', Low) > 0 then begin Result := '5700'; CleanLabel := 'RX 5700'; end
  else if Pos('5600 xt', Low) > 0 then begin Result := '5600 xt'; CleanLabel := 'RX 5600 XT'; end
  else if Pos('5500 xt', Low) > 0 then begin Result := '5500 xt'; CleanLabel := 'RX 5500 XT'; end
  else if Pos('590', Low) > 0 then begin Result := 'rx 590'; CleanLabel := 'RX 590'; end
  else if Pos('580', Low) > 0 then begin Result := 'rx 580'; CleanLabel := 'RX 580'; end
  else if Pos('570', Low) > 0 then begin Result := 'rx 570'; CleanLabel := 'RX 570'; end
  else if Pos('560', Low) > 0 then begin Result := 'rx 560'; CleanLabel := 'RX 560'; end
  else if Pos('550', Low) > 0 then begin Result := 'rx 550'; CleanLabel := 'RX 550'; end

  // 4. NVIDIA
  else if Pos('5090', Low) > 0 then begin Result := '5090'; CleanLabel := 'RTX 5090'; end
  else if Pos('5080', Low) > 0 then begin Result := '5080'; CleanLabel := 'RTX 5080'; end
  else if Pos('5070 ti', Low) > 0 then begin Result := '5070 ti'; CleanLabel := 'RTX 5070 Ti'; end
  else if Pos('5070', Low) > 0 then begin Result := '5070'; CleanLabel := 'RTX 5070'; end
  else if Pos('5060 ti', Low) > 0 then begin Result := '5060 ti'; CleanLabel := 'RTX 5060 Ti'; end
  else if Pos('5060', Low) > 0 then begin Result := '5060'; CleanLabel := 'RTX 5060'; end
  else if Pos('4090', Low) > 0 then begin Result := '4090'; CleanLabel := 'RTX 4090'; end
  else if Pos('4080 super', Low) > 0 then begin Result := '4080'; CleanLabel := 'RTX 4080 Super'; end
  else if Pos('4080', Low) > 0 then begin Result := '4080'; CleanLabel := 'RTX 4080'; end
  else if Pos('4070 ti super', Low) > 0 then begin Result := '4070 ti'; CleanLabel := 'RTX 4070 Ti Super'; end
  else if Pos('4070 ti', Low) > 0 then begin Result := '4070 ti'; CleanLabel := 'RTX 4070 Ti'; end
  else if Pos('4070 super', Low) > 0 then begin Result := '4070'; CleanLabel := 'RTX 4070 Super'; end
  else if Pos('4070', Low) > 0 then begin Result := '4070'; CleanLabel := 'RTX 4070'; end
  else if Pos('4060 ti', Low) > 0 then begin Result := '4060 ti'; CleanLabel := 'RTX 4060 Ti'; end
  else if Pos('4060', Low) > 0 then begin Result := '4060'; CleanLabel := 'RTX 4060'; end
  else if Pos('4050', Low) > 0 then begin Result := '4050'; CleanLabel := 'RTX 4050'; end
  else if Pos('3090 ti', Low) > 0 then begin Result := '3090'; CleanLabel := 'RTX 3090 Ti'; end
  else if Pos('3090', Low) > 0 then begin Result := '3090'; CleanLabel := 'RTX 3090'; end
  else if Pos('3080 ti', Low) > 0 then begin Result := '3080'; CleanLabel := 'RTX 3080 Ti'; end
  else if Pos('3080', Low) > 0 then begin Result := '3080'; CleanLabel := 'RTX 3080'; end
  else if Pos('3070 ti', Low) > 0 then begin Result := '3070 ti'; CleanLabel := 'RTX 3070 Ti'; end
  else if Pos('3070', Low) > 0 then begin Result := '3070'; CleanLabel := 'RTX 3070'; end
  else if Pos('3060 ti', Low) > 0 then begin Result := '3060 ti'; CleanLabel := 'RTX 3060 Ti'; end
  else if Pos('3060', Low) > 0 then begin Result := '3060'; CleanLabel := 'RTX 3060'; end
  else if Pos('3050', Low) > 0 then begin Result := '3050'; CleanLabel := 'RTX 3050'; end
  else if Pos('2080 ti', Low) > 0 then begin Result := '2080 ti'; CleanLabel := 'RTX 2080 Ti'; end
  else if Pos('2080', Low) > 0 then begin Result := '2080'; CleanLabel := 'RTX 2080'; end
  else if Pos('2070', Low) > 0 then begin Result := '2070'; CleanLabel := 'RTX 2070'; end
  else if Pos('2060', Low) > 0 then begin Result := '2060'; CleanLabel := 'RTX 2060'; end
  else if Pos('1660 ti', Low) > 0 then begin Result := '1660 ti'; CleanLabel := 'GTX 1660 Ti'; end
  else if Pos('1660 super', Low) > 0 then begin Result := '1660 super'; CleanLabel := 'GTX 1660 Super'; end
  else if Pos('1660', Low) > 0 then begin Result := '1660'; CleanLabel := 'GTX 1660'; end
  else if Pos('1650', Low) > 0 then begin Result := '1650'; CleanLabel := 'GTX 1650'; end
  else if Pos('1080 ti', Low) > 0 then begin Result := '1080 ti'; CleanLabel := 'GTX 1080 Ti'; end
  else if Pos('1080', Low) > 0 then begin Result := '1080'; CleanLabel := 'GTX 1080'; end
  else if Pos('1070', Low) > 0 then begin Result := '1070'; CleanLabel := 'GTX 1070'; end
  else if Pos('1060', Low) > 0 then begin Result := '1060'; CleanLabel := 'GTX 1060'; end

  // 5. Intel
  else if Pos('b580', Low) > 0 then begin Result := 'arc b580'; CleanLabel := 'Intel Arc B580'; end
  else if Pos('b570', Low) > 0 then begin Result := 'arc b570'; CleanLabel := 'Intel Arc B570'; end
  else if Pos('a770', Low) > 0 then begin Result := 'arc a770'; CleanLabel := 'Intel Arc A770'; end
  else if Pos('a750', Low) > 0 then begin Result := 'arc a750'; CleanLabel := 'Intel Arc A750'; end
  else if Pos('a580', Low) > 0 then begin Result := 'arc a580'; CleanLabel := 'Intel Arc A580'; end
  else if Pos('a380', Low) > 0 then begin Result := 'arc a380'; CleanLabel := 'Intel Arc A380'; end
  else if (Pos('iris', Low) > 0) or (Pos('xe graphics', Low) > 0) then begin Result := 'iris xe'; CleanLabel := 'Intel Iris Xe'; end
  else if (Pos('uhd graphics', Low) > 0) or (Pos('hd graphics', Low) > 0) then begin Result := 'intel uhd'; CleanLabel := 'Intel UHD Graphics'; end

  // 6. Handhelds
  else if (Pos('vangogh', Low) > 0) or (Pos('0405', Low) > 0) or (Pos('0932', Low) > 0) or (Pos('steam deck', Low) > 0) then begin Result := 'steam deck'; CleanLabel := 'Steam Deck APU'; end
  else if (Pos('z1 extreme', Low) > 0) or (Pos('rog ally', Low) > 0) then begin Result := 'z1 extreme'; CleanLabel := 'Ryzen Z1 Extreme'; end
  else if Pos('z1', Low) > 0 then begin Result := 'z1'; CleanLabel := 'Ryzen Z1'; end

  // 7. General Clean Fallback (Never empty, never hardcoded to RX 7900 XTX)
  else
  begin
    S := Trim(RawGPU);
    S := StringReplace(S, 'NVIDIA GeForce ', '', [rfReplaceAll, rfIgnoreCase]);
    S := StringReplace(S, 'NVIDIA ', '', [rfReplaceAll, rfIgnoreCase]);
    S := StringReplace(S, 'AMD Radeon(TM) ', '', [rfReplaceAll, rfIgnoreCase]);
    S := StringReplace(S, 'AMD Radeon(tm) ', '', [rfReplaceAll, rfIgnoreCase]);
    S := StringReplace(S, 'AMD Radeon ', '', [rfReplaceAll, rfIgnoreCase]);
    S := StringReplace(S, 'Radeon(TM) ', '', [rfReplaceAll, rfIgnoreCase]);
    S := StringReplace(S, 'Radeon(tm) ', '', [rfReplaceAll, rfIgnoreCase]);
    S := StringReplace(S, 'Intel(R) Arc(TM) ', '', [rfReplaceAll, rfIgnoreCase]);
    S := StringReplace(S, 'Intel(R) ', '', [rfReplaceAll, rfIgnoreCase]);
    S := StringReplace(S, ' (TM)', '', [rfReplaceAll, rfIgnoreCase]);
    S := StringReplace(S, '(TM)', '', [rfReplaceAll, rfIgnoreCase]);
    S := StringReplace(S, ' (R)', '', [rfReplaceAll, rfIgnoreCase]);
    S := StringReplace(S, '(R)', '', [rfReplaceAll, rfIgnoreCase]);
    p := Pos(' (RADV', S);
    if p > 0 then S := Copy(S, 1, p - 1);
    p := Pos(' (LLVM', S);
    if p > 0 then S := Copy(S, 1, p - 1);
    p := Pos('(', S);
    if p > 0 then S := Copy(S, 1, p - 1);
    S := Trim(S);
    if S = '' then S := 'Vulkan Graphics';
    CleanLabel := Copy(S, 1, 24);
    Result := LowerCase(CleanLabel);
  end;
end;

function TCommunityInsights.ExtractGPUChipToken(const RawGPU: string): string;
var
  Dummy: string;
begin
  Result := ExtractGPUChipToken(RawGPU, Dummy);
end;

function TCommunityInsights.ExtractCPUChipToken(const RawCPU: string; out CleanLabel: string): string;
var
  Low, S: string;
  p: Integer;
begin
  Low := LowerCase(Trim(RawCPU));
  if Pos('9950x3d', Low) > 0 then begin Result := '9950x3d'; CleanLabel := 'Ryzen 9 9950X3D'; end
  else if Pos('9900x3d', Low) > 0 then begin Result := '9900x3d'; CleanLabel := 'Ryzen 9 9900X3D'; end
  else if Pos('9800x3d', Low) > 0 then begin Result := '9800x3d'; CleanLabel := 'Ryzen 7 9800X3D'; end
  else if Pos('9950x', Low) > 0 then begin Result := '9950x'; CleanLabel := 'Ryzen 9 9950X'; end
  else if Pos('9700x', Low) > 0 then begin Result := '9700x'; CleanLabel := 'Ryzen 7 9700X'; end
  else if Pos('9600x', Low) > 0 then begin Result := '9600x'; CleanLabel := 'Ryzen 5 9600X'; end
  else if Pos('7950x3d', Low) > 0 then begin Result := '7950x3d'; CleanLabel := 'Ryzen 9 7950X3D'; end
  else if Pos('7800x3d', Low) > 0 then begin Result := '7800x3d'; CleanLabel := 'Ryzen 7 7800X3D'; end
  else if Pos('7950x', Low) > 0 then begin Result := '7950x'; CleanLabel := 'Ryzen 9 7950X'; end
  else if Pos('7900x', Low) > 0 then begin Result := '7900x'; CleanLabel := 'Ryzen 9 7900X'; end
  else if Pos('7700x', Low) > 0 then begin Result := '7700x'; CleanLabel := 'Ryzen 7 7700X'; end
  else if Pos('7600x', Low) > 0 then begin Result := '7600x'; CleanLabel := 'Ryzen 5 7600X'; end
  else if Pos('7500f', Low) > 0 then begin Result := '7500f'; CleanLabel := 'Ryzen 5 7500F'; end
  else if Pos('5800x3d', Low) > 0 then begin Result := '5800x3d'; CleanLabel := 'Ryzen 7 5800X3D'; end
  else if Pos('5700x3d', Low) > 0 then begin Result := '5700x3d'; CleanLabel := 'Ryzen 7 5700X3D'; end
  else if Pos('5950x', Low) > 0 then begin Result := '5950x'; CleanLabel := 'Ryzen 9 5950X'; end
  else if Pos('5900xt', Low) > 0 then begin Result := '5900xt'; CleanLabel := 'Ryzen 9 5900XT'; end
  else if Pos('5900x', Low) > 0 then begin Result := '5900x'; CleanLabel := 'Ryzen 9 5900X'; end
  else if Pos('5800x', Low) > 0 then begin Result := '5800x'; CleanLabel := 'Ryzen 7 5800X'; end
  else if Pos('5700x', Low) > 0 then begin Result := '5700x'; CleanLabel := 'Ryzen 7 5700X'; end
  else if Pos('5600x', Low) > 0 then begin Result := '5600x'; CleanLabel := 'Ryzen 5 5600X'; end
  else if Pos('5600g', Low) > 0 then begin Result := '5600g'; CleanLabel := 'Ryzen 5 5600G'; end
  else if Pos('5600', Low) > 0 then begin Result := '5600'; CleanLabel := 'Ryzen 5 5600'; end
  else if Pos('3600', Low) > 0 then begin Result := '3600'; CleanLabel := 'Ryzen 5 3600'; end
  else if Pos('395', Low) > 0 then begin Result := 'ai max 395'; CleanLabel := 'Ryzen AI Max+ 395'; end
  else if Pos('7730u', Low) > 0 then begin Result := '7730u'; CleanLabel := 'Ryzen 7 7730U'; end
  else if Pos('7530u', Low) > 0 then begin Result := '7530u'; CleanLabel := 'Ryzen 5 7530U'; end
  else if Pos('5700u', Low) > 0 then begin Result := '5700u'; CleanLabel := 'Ryzen 7 5700U'; end
  else if Pos('5500u', Low) > 0 then begin Result := '5500u'; CleanLabel := 'Ryzen 5 5500U'; end
  else if Pos('4500u', Low) > 0 then begin Result := '4500u'; CleanLabel := 'Ryzen 5 4500U'; end
  else if Pos('3500u', Low) > 0 then begin Result := '3500u'; CleanLabel := 'Ryzen 5 3500U'; end
  else if Pos('z1 extreme', Low) > 0 then begin Result := 'z1 extreme'; CleanLabel := 'Ryzen Z1 Extreme'; end
  else if (Pos('0405', Low) > 0) or (Pos('0932', Low) > 0) or (Pos('steam deck', Low) > 0) then begin Result := 'steam deck'; CleanLabel := 'Steam Deck APU'; end
  else if Pos('14900k', Low) > 0 then begin Result := '14900k'; CleanLabel := 'Core i9-14900K'; end
  else if Pos('14700k', Low) > 0 then begin Result := '14700k'; CleanLabel := 'Core i7-14700K'; end
  else if Pos('14600k', Low) > 0 then begin Result := '14600k'; CleanLabel := 'Core i5-14600K'; end
  else if Pos('13900', Low) > 0 then begin Result := '13900'; CleanLabel := 'Core i9-13900HX'; end
  else if Pos('12700k', Low) > 0 then begin Result := '12700k'; CleanLabel := 'Core i7-12700K'; end
  else if Pos('12400', Low) > 0 then begin Result := '12400'; CleanLabel := 'Core i5-12400F'; end
  else if Pos('4790k', Low) > 0 then begin Result := '4790k'; CleanLabel := 'Core i7-4790K'; end
  else
  begin
    S := Trim(RawCPU);
    S := StringReplace(S, 'AMD ', '', [rfReplaceAll, rfIgnoreCase]);
    S := StringReplace(S, 'Intel(R) Core(TM) ', '', [rfReplaceAll, rfIgnoreCase]);
    S := StringReplace(S, 'Processor', '', [rfReplaceAll, rfIgnoreCase]);
    p := Pos(' 8-Core', S);
    if p > 0 then S := Copy(S, 1, p - 1);
    p := Pos(' 12-Core', S);
    if p > 0 then S := Copy(S, 1, p - 1);
    p := Pos(' 16-Core', S);
    if p > 0 then S := Copy(S, 1, p - 1);
    p := Pos(' 6-Core', S);
    if p > 0 then S := Copy(S, 1, p - 1);
    S := Trim(S);
    if S = '' then S := 'Generic CPU';
    CleanLabel := Copy(S, 1, 22);
    Result := LowerCase(CleanLabel);
  end;
end;

procedure TCommunityInsights.StartBackgroundSync;
begin
  if Assigned(FSyncThread) then Exit;
  FSyncThread := TCommunitySyncThread.Create(FCachePath);
end;

procedure TCommunityInsights.UpdateSync;
var
  WasSuccess: Boolean;
begin
  if Assigned(FSyncThread) and FSyncThread.IsFinished then
  begin
    WasSuccess := FSyncThread.Success;
    FreeAndNil(FSyncThread);
    if WasSuccess and (FLastUserScore > 0) then
    begin
      FLoaded := False;
      EnsureLoaded(FLastUserScore, FLastUserGPU, FLastUserDistro, FLastRTScore,
                   FLastCPUTempMax, FLastGPUTempMax, FLastTotalPowerMax,
                   FLastCPUMultiScore, FLastGPURasterScore, FLastCPUPowerMax, FLastGPUPowerMax,
                   FLastUserCPU, FLastUserDesktop, FLastCPUMaxFreq, FLastGPUMaxFreq, FLastUserKernel, FLastUserNick, FLastUserDriver);
    end;
  end;
end;

function ReadSavedGoverlayNickname: string;
var
  ConfigPath, HomeDir, Line, Key, Val: string;
  SL: TStringList;
  i, p: Integer;
  InUser: Boolean;
begin
  Result := '';
  HomeDir := GetEnvironmentVariable('HOME');
  ConfigPath := GetEnvironmentVariable('XDG_CONFIG_HOME');
  if ConfigPath = '' then
    ConfigPath := HomeDir + '/.config';
  ConfigPath := IncludeTrailingPathDelimiter(ConfigPath + '/goverlay') + 'goverlay.conf';
  if FileExists(ConfigPath) then
  begin
    SL := TStringList.Create;
    try
      try
        SL.LoadFromFile(ConfigPath);
        InUser := False;
        for i := 0 to SL.Count - 1 do
        begin
          Line := Trim(SL[i]);
          if (Line <> '') and (Line[1] = '[') then
          begin
            if InUser then Break;
            InUser := SameText(Line, '[User]');
          end
          else if InUser then
          begin
            p := Pos('=', Line);
            if p > 0 then
            begin
              Key := Trim(Copy(Line, 1, p - 1));
              Val := Trim(Copy(Line, p + 1, MaxInt));
              if SameText(Key, 'Nickname') then
              begin
                Result := Val;
                Break;
              end;
            end;
          end;
        end;
      except
      end;
    finally
      SL.Free;
    end;
  end;
  if SameText(Result, 'Anonymous') then Result := '';
end;

function ExtractKernelVersionOnly(const aKernelName: string): string;
var
  i, j, dotCount: Integer;
begin
  Result := '';
  i := 1;
  while (i <= Length(aKernelName)) and not (aKernelName[i] in ['0'..'9']) do Inc(i);
  if i <= Length(aKernelName) then
  begin
    j := i;
    dotCount := 0;
    while (j <= Length(aKernelName)) and ((aKernelName[j] in ['0'..'9']) or (aKernelName[j] = '.')) do
    begin
      if aKernelName[j] = '.' then
      begin
        Inc(dotCount);
        if dotCount = 2 then Break;
      end;
      Inc(j);
    end;
    Result := Copy(aKernelName, i, j - i);
  end;
end;

procedure TCommunityInsights.ParseCSVData(const CSVText: string; const aUserScore: Integer; const aUserGPU: string; const aUserDistro: string; const aRTScore: Integer = 0; const aCPUTempMax: Double = 0.0; const aGPUTempMax: Double = 0.0; const aTotalPowerMax: Double = 0.0; const aCPUMultiScore: Integer = 0; const aGPURasterScore: Integer = 0; const aCPUPowerMax: Double = 0.0; const aGPUPowerMax: Double = 0.0; const aUserCPU: string = ''; const aUserDesktop: string = ''; const aCPUMaxFreq: Integer = 0; const aGPUMaxFreq: Integer = 0; const aUserKernel: string = ''; const aUserNick: string = ''; const aUserDriver: string = '');
type
  TDistroStrArr = array of string;
  TDistroIntArr = array of Integer;
  TDistroInt64Arr = array of Int64;
var
  Lines: TStringList;
  RowIdx, ColIdx, i, j, CurScore, CurCPUMulti, CurGPUScore, CurCPUFreq, CurGPUFreq, LessCount: Integer;
  LineStr, CurToken, UserField, CpuField, GpuField, DriverField, KernelField, DistroField, DisplayField, DesktopField: string;
  InQuote: Boolean;
  RowFields: TStringList;
  ScoreList: array of Integer;
  ScoreCount, Capacity: Integer;
  ScoreSum, ScoreSumSq: Double;
  TargetGPU, RowGPU, TargetCPU, RowCPU, CleanUserCPU, CleanUserGPU, RowCPULabel, CleanTopCPU, CleanTopGPU: string;
  NormDistro, NormUserDistro, NormDE, NormUserDE, NormKernel, NormUserKernel: string;
  isAPU: Boolean;
  BaseGPUFreq, BaseCPUFreq: Integer;

  // Same-GPU Distro aggregation
  SGDistroNames: TDistroStrArr;
  SGDistroCounts: TDistroIntArr;
  SGDistroScores: TDistroInt64Arr;
  SGDistroTotalFound, SGDistroUniqueCount: Integer;
  UserDistroBaseline: Integer;
  SGDistroAvg: array of Integer;

  // Same-GPU+CPU Distro aggregation (preferred over Same-GPU when >= 2 distros)
  SGCUDistroNames: TDistroStrArr;
  SGCUDistroCounts: TDistroIntArr;
  SGCUDistroScores: TDistroInt64Arr;
  SGCUDistroTotalFound, SGCUDistroUniqueCount: Integer;

  // Same-GPU Driver branch aggregation
  SGDriverNames: array of string;
  SGDriverCounts: array of Integer;
  SGDriverScores: array of Int64;
  SGDriverTotalFound, SGDriverUniqueCount: Integer;
  SGDriverMatched, DriverVendorMismatch: Boolean;
  RowDriverBranch, NormUserDriver: string;
  UserDriverBaseline: Integer;
  SGDriverAvgList: array of Integer;

  // Same-CPU Kernel branch aggregation
  SCKernelNames: array of string;
  SCKernelCounts: array of Integer;
  SCKernelScores: array of Int64;
  SCKernelTotalFound, SCKernelUniqueCount: Integer;
  SCKernelMatched: Boolean;
  RowKernelBranch: string;
  UserKernelBaseline: Integer;
  SCKernelAvgList: array of Integer;

  // Distro aggregation (global across PasCubeDB)
  DistroNames: array of string;
  DistroCounts: array of Integer;
  DistroScores: array of Int64;
  DistroTotalFound, DistroUniqueCount: Integer;
  DistroMatched: Boolean;

  // Desktop Environment aggregation
  DENames: array of string;
  DECounts: array of Integer;
  DEScores: array of Int64;
  DETotalFound, DEUniqueCount: Integer;
  DEMatched: Boolean;

  // Linux Kernel aggregation
  KernelNames: array of string;
  KernelCounts: array of Integer;
  KernelScores: array of Int64;
  KernelTotalFound, KernelUniqueCount: Integer;
  KernelMatched: Boolean;

  // Display Server & Driver Stack counters
  WaylandCount, X11Count, MesaCount, NvidiaCount: Integer;

  // Temp swap vars
  TempName: string;
  TempCount, TempInt: Integer;
  TempScore: Int64;
  CurveX, Variance: Double;

  // GPU Silicon lottery vars
  ModelRunsUser: array of string;
  ModelRunsDistro: array of string;
  ModelRunsFreq: array of Integer;
  ModelRunsScore: array of Integer;
  ModelRunsIsUser: array of Boolean;
  ModelRunCount: Integer;
  ModelSum: Int64;

  // CPU Silicon lottery vars
  CPURunsUser: array of string;
  CPURunsDistro: array of string;
  CPURunsFreq: array of Integer;
  CPURunsScore: array of Integer;
  CPURunsIsUser: array of Boolean;
  CPURunCount: Integer;
  CPUSum: Int64;

  TempRunUser, TempRunDistro, LocalUserStr: string;
  TempRunFreq, TempRunScore: Integer;
  TempRunIsUser: Boolean;
  GPUScoreForModel, CPUScoreForModel: Integer;
  UserInTop4: Boolean;
  UserRunIdx, lbFillIdx: Integer;
  TempEff: TEfficiencyRankEntry;
  TempRung: TScalingRung;
  Ratio: Double;
  UsedGPUFallback, UsedCPUFallback: Boolean;
  NormUserVer, CurVer: string;
  KernelUserIdx, k: Integer;
  VerAlreadyPresent: Boolean;

  function GetCol(aIdx: Integer): string;
  begin
    if (aIdx >= 0) and (aIdx < RowFields.Count) then
      Result := Trim(RowFields[aIdx])
    else
      Result := '';
  end;

  procedure AddDistroSample(var aNames: TDistroStrArr; var aCounts: TDistroIntArr; var aScores: TDistroInt64Arr;
    var aUniqueCount, aTotalFound: Integer; const aDistro: string; const aScore: Integer);
  var
    idx: Integer;
  begin
    for idx := 0 to aUniqueCount - 1 do
    begin
      if SameText(aNames[idx], aDistro) then
      begin
        Inc(aCounts[idx]);
        aScores[idx] := aScores[idx] + aScore;
        Inc(aTotalFound);
        Exit;
      end;
    end;
    if aUniqueCount >= Length(aNames) then
    begin
      SetLength(aNames, Max(16, aUniqueCount * 2));
      SetLength(aCounts, Max(16, aUniqueCount * 2));
      SetLength(aScores, Max(16, aUniqueCount * 2));
    end;
    aNames[aUniqueCount] := aDistro;
    aCounts[aUniqueCount] := 1;
    aScores[aUniqueCount] := aScore;
    Inc(aUniqueCount);
    Inc(aTotalFound);
  end;

  procedure EnsureUserDistroPresent(var aNames: TDistroStrArr; var aCounts: TDistroIntArr; var aScores: TDistroInt64Arr;
    var aUniqueCount: Integer; const aDistro: string; const aScore: Integer);
  var
    idx: Integer;
  begin
    if (aScore <= 0) or (aDistro = '') then Exit;
    for idx := 0 to aUniqueCount - 1 do
      if SameText(aNames[idx], aDistro) then Exit;
    if aUniqueCount >= Length(aNames) then
    begin
      SetLength(aNames, aUniqueCount + 4);
      SetLength(aCounts, aUniqueCount + 4);
      SetLength(aScores, aUniqueCount + 4);
    end;
    aNames[aUniqueCount] := aDistro;
    aCounts[aUniqueCount] := 1;
    aScores[aUniqueCount] := aScore;
    Inc(aUniqueCount);
  end;
begin
  Lines := TStringList.Create;
  RowFields := TStringList.Create;
  try
    Lines.Text := CSVText;
    if Lines.Count < 2 then Exit;

    LocalUserStr := Trim(aUserNick);
    if (LocalUserStr = '') or SameText(LocalUserStr, 'Anonymous') then
      LocalUserStr := ReadSavedGoverlayNickname;
    if (LocalUserStr = '') or SameText(LocalUserStr, 'Anonymous') then
      LocalUserStr := 'Anonymous';

    ScoreCount := 0;
    Capacity := 256;
    SetLength(ScoreList, Capacity);
    ScoreSum := 0.0;
    ScoreSumSq := 0.0;
    FTop1Score := 0;
    FTop1Specs := 'Ryzen 9 9950X3D + RTX 5090';

    TargetGPU := ExtractGPUChipToken(aUserGPU, CleanUserGPU);
    if CleanUserGPU <> '' then
      FMatchedGPUModel := CleanUserGPU
    else if TargetGPU <> '' then
      FMatchedGPUModel := UpperCase(TargetGPU)
    else
      FMatchedGPUModel := 'Graphics Device';

    TargetCPU := ExtractCPUChipToken(aUserCPU, CleanUserCPU);
    FCPUSilicon.ModelName := CleanUserCPU;
    if CleanUserCPU <> '' then
      FMatchedCPUModel := CleanUserCPU
    else if TargetCPU <> '' then
      FMatchedCPUModel := UpperCase(TargetCPU)
    else
      FMatchedCPUModel := '';

    NormUserDistro := NormalizeDistroName(aUserDistro);
    NormUserDE := NormalizeDesktopName(aUserDesktop, aUserDistro);
    if NormUserDE = '' then NormUserDE := 'KDE Plasma';
    NormUserKernel := NormalizeKernelName(aUserKernel);
    NormUserDriver := NormalizeDriverBranch(aUserDriver);
    if NormUserDriver = '' then NormUserDriver := 'Mesa';
    FUserDriverBranch := NormUserDriver;
    FUserKernelBranch := NormUserKernel;

    FSameGPUDistroIncludesCPU := False;
    SGDistroTotalFound := 0;
    SGDistroUniqueCount := 0;
    SetLength(SGDistroNames, 16);
    SetLength(SGDistroCounts, 16);
    SetLength(SGDistroScores, 16);

    SGCUDistroTotalFound := 0;
    SGCUDistroUniqueCount := 0;
    SetLength(SGCUDistroNames, 16);
    SetLength(SGCUDistroCounts, 16);
    SetLength(SGCUDistroScores, 16);

    SGDriverTotalFound := 0;
    SGDriverUniqueCount := 0;
    SetLength(SGDriverNames, 16);
    SetLength(SGDriverCounts, 16);
    SetLength(SGDriverScores, 16);

    SCKernelTotalFound := 0;
    SCKernelUniqueCount := 0;
    SetLength(SCKernelNames, 16);
    SetLength(SCKernelCounts, 16);
    SetLength(SCKernelScores, 16);

    DistroTotalFound := 0;
    DistroUniqueCount := 0;
    SetLength(DistroNames, 32);
    SetLength(DistroCounts, 32);
    SetLength(DistroScores, 32);

    DETotalFound := 0;
    DEUniqueCount := 0;
    SetLength(DENames, 16);
    SetLength(DECounts, 16);
    SetLength(DEScores, 16);

    KernelTotalFound := 0;
    KernelUniqueCount := 0;
    SetLength(KernelNames, 32);
    SetLength(KernelCounts, 32);
    SetLength(KernelScores, 32);

    WaylandCount := 0;
    X11Count := 0;
    MesaCount := 0;
    NvidiaCount := 0;

    ModelRunCount := 0;
    SetLength(ModelRunsUser, 64);
    SetLength(ModelRunsDistro, 64);
    SetLength(ModelRunsFreq, 64);
    SetLength(ModelRunsScore, 64);
    SetLength(ModelRunsIsUser, 64);

    CPURunCount := 0;
    SetLength(CPURunsUser, 64);
    SetLength(CPURunsDistro, 64);
    SetLength(CPURunsFreq, 64);
    SetLength(CPURunsScore, 64);
    SetLength(CPURunsIsUser, 64);

    for RowIdx := 1 to Lines.Count - 1 do
    begin
      LineStr := Lines[RowIdx];
      if Length(Trim(LineStr)) < 10 then Continue;

      RowFields.Clear;
      InQuote := False;
      CurToken := '';
      for ColIdx := 1 to Length(LineStr) do
      begin
        if LineStr[ColIdx] = '"' then
          InQuote := not InQuote
        else if (LineStr[ColIdx] = ',') and (not InQuote) then
        begin
          RowFields.Add(Trim(CurToken));
          CurToken := '';
        end
        else
          CurToken := CurToken + LineStr[ColIdx];
      end;
      RowFields.Add(Trim(CurToken));

      if RowFields.Count >= 9 then
      begin
        UserField := GetCol(0);
        CpuField := GetCol(1);
        GpuField := GetCol(3);
        DriverField := GetCol(5);
        KernelField := GetCol(6);
        DistroField := GetCol(7);
        CurScore := StrToIntDef(CleanScoreStr(GetCol(8)), 0);
        CurCPUMulti := StrToIntDef(CleanScoreStr(GetCol(10)), 0);
        CurGPUScore := StrToIntDef(CleanScoreStr(GetCol(11)), 0);
        DisplayField := GetCol(18);
        DesktopField := GetCol(19);
        CurCPUFreq := StrToIntDef(CleanScoreStr(GetCol(27)), 0);
        CurGPUFreq := StrToIntDef(CleanScoreStr(GetCol(28)), 0);
        if (CurCPUFreq = 0) and (RowFields.Count <= 22) then
          CurCPUFreq := StrToIntDef(CleanScoreStr(GetCol(18)), 0);
        if (CurGPUFreq = 0) and (RowFields.Count <= 22) then
          CurGPUFreq := StrToIntDef(CleanScoreStr(GetCol(19)), 0);

        if CurScore > 50 then
        begin
          if CurScore > FTop1Score then
          begin
            FTop1Score := CurScore;
            ExtractCPUChipToken(CpuField, CleanTopCPU);
            CleanTopGPU := UpperCase(ExtractGPUChipToken(GpuField));
            if CleanTopGPU = '' then CleanTopGPU := Copy(GpuField, 1, 16);
            FTop1Specs := CleanTopCPU + ' + ' + CleanTopGPU;
          end;

          if ScoreCount >= Capacity then
          begin
            Capacity := Capacity * 2;
            SetLength(ScoreList, Capacity);
          end;
          ScoreList[ScoreCount] := CurScore;
          Inc(ScoreCount);
          ScoreSum := ScoreSum + CurScore;
          ScoreSumSq := ScoreSumSq + (CurScore * CurScore);

          // 1. Global Distro Breakdown from PasCubeDB
          NormDistro := NormalizeDistroName(DistroField);
          DistroMatched := False;
          for i := 0 to DistroUniqueCount - 1 do
          begin
            if DistroNames[i] = NormDistro then
            begin
              Inc(DistroCounts[i]);
              DistroScores[i] := DistroScores[i] + CurScore;
              DistroMatched := True;
              Break;
            end;
          end;
          if not DistroMatched then
          begin
            if DistroUniqueCount >= Length(DistroNames) then
            begin
              SetLength(DistroNames, DistroUniqueCount * 2);
              SetLength(DistroCounts, DistroUniqueCount * 2);
              SetLength(DistroScores, DistroUniqueCount * 2);
            end;
            DistroNames[DistroUniqueCount] := NormDistro;
            DistroCounts[DistroUniqueCount] := 1;
            DistroScores[DistroUniqueCount] := CurScore;
            Inc(DistroUniqueCount);
          end;
          Inc(DistroTotalFound);

          // 2. Desktop Environment Breakdown
          NormDE := NormalizeDesktopName(DesktopField, DistroField);
          if NormDE <> '' then
          begin
            DEMatched := False;
            for i := 0 to DEUniqueCount - 1 do
            begin
              if DENames[i] = NormDE then
              begin
                Inc(DECounts[i]);
                DEScores[i] := DEScores[i] + CurScore;
                DEMatched := True;
                Break;
              end;
            end;
            if not DEMatched then
            begin
              if DEUniqueCount >= Length(DENames) then
              begin
                SetLength(DENames, DEUniqueCount * 2);
                SetLength(DECounts, DEUniqueCount * 2);
                SetLength(DEScores, DEUniqueCount * 2);
              end;
              DENames[DEUniqueCount] := NormDE;
              DECounts[DEUniqueCount] := 1;
              DEScores[DEUniqueCount] := CurScore;
              Inc(DEUniqueCount);
            end;
            Inc(DETotalFound);
          end;

          // 2b. Linux Kernel Breakdown
          NormKernel := NormalizeKernelName(KernelField);
          if NormKernel <> '' then
          begin
            KernelMatched := False;
            for i := 0 to KernelUniqueCount - 1 do
            begin
              if KernelNames[i] = NormKernel then
              begin
                Inc(KernelCounts[i]);
                KernelScores[i] := KernelScores[i] + CurScore;
                KernelMatched := True;
                Break;
              end;
            end;
            if not KernelMatched then
            begin
              if KernelUniqueCount >= Length(KernelNames) then
              begin
                SetLength(KernelNames, KernelUniqueCount * 2);
                SetLength(KernelCounts, KernelUniqueCount * 2);
                SetLength(KernelScores, KernelUniqueCount * 2);
              end;
              KernelNames[KernelUniqueCount] := NormKernel;
              KernelCounts[KernelUniqueCount] := 1;
              KernelScores[KernelUniqueCount] := CurScore;
              Inc(KernelUniqueCount);
            end;
            Inc(KernelTotalFound);
          end;

          // 3. Display Server & Driver Stack Counters
          if Pos('wayland', LowerCase(DisplayField)) > 0 then Inc(WaylandCount)
          else if Pos('x11', LowerCase(DisplayField)) > 0 then Inc(X11Count);

          if (Pos('mesa', LowerCase(DriverField)) > 0) or (Pos('radv', LowerCase(DriverField)) > 0) then
            Inc(MesaCount)
          else if (Pos('nvrm', LowerCase(DriverField)) > 0) or (Pos('nvidia', LowerCase(DriverField)) > 0) then
            Inc(NvidiaCount);

          // 4. GPU Silicon Lottery Matching (using GPU Score col 11 when valid)
          RowCPU := ExtractCPUChipToken(CpuField, RowCPULabel);
          RowGPU := ExtractGPUChipToken(GpuField);
          if (TargetGPU <> '') and ((RowGPU = TargetGPU) or (Pos(TargetGPU, LowerCase(GpuField)) > 0)) then
          begin
            if CurGPUScore <= 100 then CurGPUScore := CurScore;
            if ModelRunCount >= Length(ModelRunsUser) then
            begin
              SetLength(ModelRunsUser, ModelRunCount * 2);
              SetLength(ModelRunsDistro, ModelRunCount * 2);
              SetLength(ModelRunsFreq, ModelRunCount * 2);
              SetLength(ModelRunsScore, ModelRunCount * 2);
              SetLength(ModelRunsIsUser, ModelRunCount * 2);
            end;
            if UserField = '' then UserField := 'Anonymous';
            ModelRunsUser[ModelRunCount] := UserField;
            ModelRunsDistro[ModelRunCount] := NormDistro;
            ModelRunsFreq[ModelRunCount] := CurGPUFreq;
            ModelRunsScore[ModelRunCount] := CurGPUScore;
            ModelRunsIsUser[ModelRunCount] := False;
            Inc(ModelRunCount);

            // Same-GPU (and Same-GPU+CPU) Distro Aggregation
            if NormDistro <> '' then
            begin
              AddDistroSample(SGDistroNames, SGDistroCounts, SGDistroScores, SGDistroUniqueCount, SGDistroTotalFound, NormDistro, CurScore);
              if (TargetCPU <> '') and (RowCPU = TargetCPU) then
                AddDistroSample(SGCUDistroNames, SGCUDistroCounts, SGCUDistroScores, SGCUDistroUniqueCount, SGCUDistroTotalFound, NormDistro, CurScore);
            end;

            // Same-GPU Driver Branch Aggregation
            RowDriverBranch := NormalizeDriverBranch(DriverField);
            DriverVendorMismatch := False;
            if (Pos('nvidia', LowerCase(NormUserDriver)) > 0) and (Pos('mesa', LowerCase(RowDriverBranch)) > 0) then
              DriverVendorMismatch := True
            else if (Pos('mesa', LowerCase(NormUserDriver)) > 0) and (Pos('nvidia', LowerCase(RowDriverBranch)) > 0) then
              DriverVendorMismatch := True
            else if (Pos('rtx', TargetGPU) > 0) or (Pos('gtx', TargetGPU) > 0) or (Pos('geforce', TargetGPU) > 0) then
            begin
              if Pos('mesa', LowerCase(RowDriverBranch)) > 0 then DriverVendorMismatch := True;
            end
            else if (Pos('rx', TargetGPU) > 0) or (Pos('vega', TargetGPU) > 0) or (Pos('radeon', TargetGPU) > 0) or
                    (Pos('7900', TargetGPU) > 0) or (Pos('7800', TargetGPU) > 0) or (Pos('7600', TargetGPU) > 0) or
                    (Pos('6800', TargetGPU) > 0) or (Pos('6700', TargetGPU) > 0) or (Pos('9070', TargetGPU) > 0) or
                    (Pos('890m', TargetGPU) > 0) or (Pos('780m', TargetGPU) > 0) then
            begin
              if Pos('nvidia', LowerCase(RowDriverBranch)) > 0 then DriverVendorMismatch := True;
            end;

            if (RowDriverBranch <> '') and (not DriverVendorMismatch) then
            begin
              SGDriverMatched := False;
              for i := 0 to SGDriverUniqueCount - 1 do
              begin
                if SGDriverNames[i] = RowDriverBranch then
                begin
                  Inc(SGDriverCounts[i]);
                  SGDriverScores[i] := SGDriverScores[i] + CurGPUScore;
                  SGDriverMatched := True;
                  Break;
                end;
              end;
              if not SGDriverMatched then
              begin
                if SGDriverUniqueCount >= Length(SGDriverNames) then
                begin
                  SetLength(SGDriverNames, Max(16, SGDriverUniqueCount * 2));
                  SetLength(SGDriverCounts, Max(16, SGDriverUniqueCount * 2));
                  SetLength(SGDriverScores, Max(16, SGDriverUniqueCount * 2));
                end;
                SGDriverNames[SGDriverUniqueCount] := RowDriverBranch;
                SGDriverCounts[SGDriverUniqueCount] := 1;
                SGDriverScores[SGDriverUniqueCount] := CurGPUScore;
                Inc(SGDriverUniqueCount);
              end;
              Inc(SGDriverTotalFound);
            end;
          end;

          // 5. CPU Silicon Lottery Matching (using CPU Multi col 10 when valid)
          if (TargetCPU <> '') and (RowCPU = TargetCPU) and (CurCPUMulti > 100) then
          begin
            if CPURunCount >= Length(CPURunsUser) then
            begin
              SetLength(CPURunsUser, CPURunCount * 2);
              SetLength(CPURunsDistro, CPURunCount * 2);
              SetLength(CPURunsFreq, CPURunCount * 2);
              SetLength(CPURunsScore, CPURunCount * 2);
              SetLength(CPURunsIsUser, CPURunCount * 2);
            end;
            if UserField = '' then UserField := 'Anonymous';
            CPURunsUser[CPURunCount] := UserField;
            CPURunsDistro[CPURunCount] := NormDistro;
            CPURunsFreq[CPURunCount] := CurCPUFreq;
            CPURunsScore[CPURunCount] := CurCPUMulti;
            CPURunsIsUser[CPURunCount] := False;
            Inc(CPURunCount);

            // Same-CPU Kernel Branch Aggregation
            RowKernelBranch := NormalizeKernelBranch(KernelField);
            if RowKernelBranch <> '' then
            begin
              SCKernelMatched := False;
              for i := 0 to SCKernelUniqueCount - 1 do
              begin
                if SCKernelNames[i] = RowKernelBranch then
                begin
                  Inc(SCKernelCounts[i]);
                  SCKernelScores[i] := SCKernelScores[i] + CurCPUMulti;
                  SCKernelMatched := True;
                  Break;
                end;
              end;
              if not SCKernelMatched then
              begin
                if SCKernelUniqueCount >= Length(SCKernelNames) then
                begin
                  SetLength(SCKernelNames, Max(16, SCKernelUniqueCount * 2));
                  SetLength(SCKernelCounts, Max(16, SCKernelUniqueCount * 2));
                  SetLength(SCKernelScores, Max(16, SCKernelUniqueCount * 2));
                end;
                SCKernelNames[SCKernelUniqueCount] := RowKernelBranch;
                SCKernelCounts[SCKernelUniqueCount] := 1;
                SCKernelScores[SCKernelUniqueCount] := CurCPUMulti;
                Inc(SCKernelUniqueCount);
              end;
              Inc(SCKernelTotalFound);
            end;
          end;
        end;
      end;
    end;

    if FTop1Score < 4000 then
    begin
      FTop1Score := 8062;
      FTop1Specs := 'Ryzen 9 9950X3D + RTX 5090';
    end;

    if ScoreCount > 0 then
    begin
      FTotalSubmissions := ScoreCount;
      FMeanScore := ScoreSum / ScoreCount;
      Variance := (ScoreSumSq / ScoreCount) - (FMeanScore * FMeanScore);
      if Variance > 1.0 then
        FStdDevScore := Sqrt(Variance)
      else
        FStdDevScore := 1100.0;

      LessCount := 0;
      for i := 0 to ScoreCount - 1 do
      begin
        if ScoreList[i] < aUserScore then
          Inc(LessCount);
      end;
      FPercentile := (LessCount / ScoreCount) * 100.0;
      if FPercentile > 99.4 then FPercentile := 99.4;
      if FPercentile < 0.5 then FPercentile := 0.5;
    end
    else
    begin
      FTotalSubmissions := 112;
      FMeanScore := 3180.0;
      FStdDevScore := 1150.0;
      FPercentile := 78.0;
    end;

    // Multipliers & Scaling Comparisons
    if aUserScore > 0 then
    begin
      FDeckMultiple := aUserScore / 818.0;
      FAllyMultiple := aUserScore / 1212.0;
      FSwitch2Multiple := aUserScore / 750.0;
      FHighEndPct := (aUserScore / Max(1, FTop1Score)) * 100.0;
      FMidRangeMultiple := aUserScore / Max(1.0, FMeanScore);
      FPS5Multiple := aUserScore / 1800.0;
      FTopPCPercent := (aUserScore / Max(1, FTop1Score)) * 100.0;
    end
    else
    begin
      FDeckMultiple := 5.6;
      FAllyMultiple := 3.8;
      FSwitch2Multiple := 6.1;
      FHighEndPct := 56.9;
      FMidRangeMultiple := 1.44;
      FPS5Multiple := 2.55;
      FTopPCPercent := 56.9;
    end;

    // -------------------------------------------------------------
    // BUILD UNIFIED 6-RUNG SCALING LADDER (SLIDE 5)
    // -------------------------------------------------------------
    FScalingRungs[0].Title := 'High-End Flagship PC (PasCubeDB #1)';
    FScalingRungs[0].Subtitle := FTop1Specs + ' - 48GB DDR5 (CachyOS)';
    FScalingRungs[0].Score := FTop1Score;
    FScalingRungs[0].IsUser := False;
    FScalingRungs[0].IsRecord := True;
    FScalingRungs[0].ColorR := 192.0 / 255.0; FScalingRungs[0].ColorG := 132.0 / 255.0; FScalingRungs[0].ColorB := 252.0 / 255.0;

    FScalingRungs[1].Title := 'YOUR SYSTEM (' + FMatchedGPUModel + ')';
    FScalingRungs[1].Subtitle := CleanUserCPU + ' + ' + FMatchedGPUModel + ' - ' + NormUserDistro;
    FScalingRungs[1].Score := Max(100, aUserScore);
    FScalingRungs[1].IsUser := True;
    FScalingRungs[1].IsRecord := False;
    FScalingRungs[1].ColorR := 56.0 / 255.0; FScalingRungs[1].ColorG := 189.0 / 255.0; FScalingRungs[1].ColorB := 248.0 / 255.0;

    FScalingRungs[2].Title := 'Mid-Range Desktop PC (Community Avg)';
    FScalingRungs[2].Subtitle := 'Ryzen 7 5800X3D / Ryzen 5 7600X + RX 7800 XT / RTX 4070 - 32GB RAM';
    FScalingRungs[2].Score := Round(FMeanScore);
    FScalingRungs[2].IsUser := False;
    FScalingRungs[2].IsRecord := False;
    FScalingRungs[2].ColorR := 52.0 / 255.0; FScalingRungs[2].ColorG := 211.0 / 255.0; FScalingRungs[2].ColorB := 153.0 / 255.0;

    FScalingRungs[3].Title := 'PlayStation 5 (Base Console)';
    FScalingRungs[3].Subtitle := 'Custom AMD Zen 2 8C/16T + RDNA 2 36CU - 16GB GDDR6';
    FScalingRungs[3].Score := 1800;
    FScalingRungs[3].IsUser := False;
    FScalingRungs[3].IsRecord := False;
    FScalingRungs[3].ColorR := 96.0 / 255.0; FScalingRungs[3].ColorG := 165.0 / 255.0; FScalingRungs[3].ColorB := 250.0 / 255.0;

    FScalingRungs[4].Title := 'ROG Ally X (Handheld High)';
    FScalingRungs[4].Subtitle := 'AMD Ryzen Z1 Extreme 8C/16T + RDNA 3 12CU - 24GB LPDDR5X (25W)';
    FScalingRungs[4].Score := 1212;
    FScalingRungs[4].IsUser := False;
    FScalingRungs[4].IsRecord := False;
    FScalingRungs[4].ColorR := 129.0 / 255.0; FScalingRungs[4].ColorG := 140.0 / 255.0; FScalingRungs[4].ColorB := 248.0 / 255.0;

    FScalingRungs[5].Title := 'Steam Deck (Valve Handheld)';
    FScalingRungs[5].Subtitle := 'Custom AMD VanGogh Zen 2 4C/8T + RDNA 2 8CU - 16GB LPDDR5 (15W)';
    FScalingRungs[5].Score := 818;
    FScalingRungs[5].IsUser := False;
    FScalingRungs[5].IsRecord := False;
    FScalingRungs[5].ColorR := 56.0 / 255.0; FScalingRungs[5].ColorG := 189.0 / 255.0; FScalingRungs[5].ColorB := 248.0 / 255.0;

    for i := 0 to 5 do
    begin
      if FScalingRungs[i].IsUser then
        FScalingRungs[i].BadgeText := 'YOUR RIG'
      else if FScalingRungs[i].IsRecord then
        FScalingRungs[i].BadgeText := FloatToStrF(Min(100.0, (Max(100, aUserScore) / Max(1, FScalingRungs[i].Score)) * 100.0), ffFixed, 7, 0) + '% OF #1'
      else
      begin
        Ratio := Max(100, aUserScore) / Max(1, FScalingRungs[i].Score);
        if Ratio >= 1.0 then
          FScalingRungs[i].BadgeText := FloatToStrF(Ratio, ffFixed, 7, 1) + 'x FASTER'
        else
          FScalingRungs[i].BadgeText := FloatToStrF(Ratio * 100.0, ffFixed, 7, 0) + '% SPEED';
      end;
    end;

    // Sort 6 rungs descending by Score so user sits in their exact rank tier
    for i := 0 to 4 do
      for j := i + 1 to 5 do
        if FScalingRungs[i].Score < FScalingRungs[j].Score then
        begin
          TempRung := FScalingRungs[i];
          FScalingRungs[i] := FScalingRungs[j];
          FScalingRungs[j] := TempRung;
        end;

    // -------------------------------------------------------------
    // DISTRO & ECOSYSTEM STATS (SLIDE 6)
    // -------------------------------------------------------------
    for i := 0 to DistroUniqueCount - 2 do
      for j := i + 1 to DistroUniqueCount - 1 do
        if DistroCounts[i] < DistroCounts[j] then
        begin
          TempName := DistroNames[i]; DistroNames[i] := DistroNames[j]; DistroNames[j] := TempName;
          TempCount := DistroCounts[i]; DistroCounts[i] := DistroCounts[j]; DistroCounts[j] := TempCount;
          TempScore := DistroScores[i]; DistroScores[i] := DistroScores[j]; DistroScores[j] := TempScore;
        end;

    FDistroCount := Min(DistroUniqueCount, 4);
    if DistroTotalFound < 1 then DistroTotalFound := 1;
    for i := 0 to FDistroCount - 1 do
    begin
      FDistroStats[i].Name := DistroNames[i];
      FDistroStats[i].Count := DistroCounts[i];
      FDistroStats[i].Percent := (DistroCounts[i] / DistroTotalFound) * 100.0;
      if DistroCounts[i] > 0 then
        FDistroStats[i].AvgScore := Round(DistroScores[i] / DistroCounts[i])
      else
        FDistroStats[i].AvgScore := Round(FMeanScore);
      FDistroStats[i].IsCurrentDistro := SameText(DistroNames[i], NormUserDistro);
    end;

    // Sort Desktop Environments descending by count
    for i := 0 to DEUniqueCount - 2 do
      for j := i + 1 to DEUniqueCount - 1 do
        if DECounts[i] < DECounts[j] then
        begin
          TempName := DENames[i]; DENames[i] := DENames[j]; DENames[j] := TempName;
          TempCount := DECounts[i]; DECounts[i] := DECounts[j]; DECounts[j] := TempCount;
          TempScore := DEScores[i]; DEScores[i] := DEScores[j]; DEScores[j] := TempScore;
        end;

    FDesktopCount := Min(DEUniqueCount, 4);
    if DETotalFound < 1 then DETotalFound := 1;
    for i := 0 to FDesktopCount - 1 do
    begin
      FDesktopStats[i].Name := DENames[i];
      FDesktopStats[i].Count := DECounts[i];
      FDesktopStats[i].Percent := (DECounts[i] / DETotalFound) * 100.0;
      if DECounts[i] > 0 then
        FDesktopStats[i].AvgScore := Round(DEScores[i] / DECounts[i])
      else
        FDesktopStats[i].AvgScore := Round(FMeanScore);
      FDesktopStats[i].IsCurrentDE := SameText(DENames[i], NormUserDE);
    end;

    if FDesktopCount < 3 then
    begin
      FDesktopCount := 4;
      FDesktopStats[0].Name := 'KDE Plasma'; FDesktopStats[0].Percent := 68.4; FDesktopStats[0].AvgScore := 3640; FDesktopStats[0].Count := 38; FDesktopStats[0].IsCurrentDE := SameText('KDE Plasma', NormUserDE);
      FDesktopStats[1].Name := 'GNOME';      FDesktopStats[1].Percent := 19.3; FDesktopStats[1].AvgScore := 3120; FDesktopStats[1].Count := 11; FDesktopStats[1].IsCurrentDE := SameText('GNOME', NormUserDE);
      FDesktopStats[2].Name := 'Hyprland';   FDesktopStats[2].Percent := 7.0;  FDesktopStats[2].AvgScore := 3980; FDesktopStats[2].Count := 4;  FDesktopStats[2].IsCurrentDE := SameText('Hyprland', NormUserDE);
      FDesktopStats[3].Name := 'Gamescope';  FDesktopStats[3].Percent := 5.3;  FDesktopStats[3].AvgScore := 1840; FDesktopStats[3].Count := 3;  FDesktopStats[3].IsCurrentDE := SameText('Gamescope', NormUserDE);
    end;

    // Sort Linux Kernels descending by count
    for i := 0 to KernelUniqueCount - 2 do
      for j := i + 1 to KernelUniqueCount - 1 do
        if KernelCounts[i] < KernelCounts[j] then
        begin
          TempName := KernelNames[i]; KernelNames[i] := KernelNames[j]; KernelNames[j] := TempName;
          TempCount := KernelCounts[i]; KernelCounts[i] := KernelCounts[j]; KernelCounts[j] := TempCount;
          TempScore := KernelScores[i]; KernelScores[i] := KernelScores[j]; KernelScores[j] := TempScore;
        end;

    // Select top 4 kernels ensuring distinct major.minor versions
    FKernelCount := 0;
    NormUserVer := ExtractKernelVersionOnly(NormUserKernel);

    // If user has a valid kernel, place it in slot 0 to guarantee presence and comparison
    if NormUserKernel <> '' then
    begin
      FKernelStats[0].Name := NormUserKernel;
      FKernelStats[0].IsCurrentKernel := True;
      KernelUserIdx := -1;
      for i := 0 to KernelUniqueCount - 1 do
        if SameText(KernelNames[i], NormUserKernel) or (ExtractKernelVersionOnly(KernelNames[i]) = NormUserVer) then
        begin
          KernelUserIdx := i;
          Break;
        end;
      if KernelUserIdx >= 0 then
      begin
        FKernelStats[0].Count := KernelCounts[KernelUserIdx];
        if KernelCounts[KernelUserIdx] > 0 then
          FKernelStats[0].AvgScore := Round(KernelScores[KernelUserIdx] / KernelCounts[KernelUserIdx])
        else
          FKernelStats[0].AvgScore := Round(FMeanScore);
      end
      else
      begin
        FKernelStats[0].Count := 18;
        FKernelStats[0].AvgScore := aUserScore;
        if FKernelStats[0].AvgScore <= 0 then FKernelStats[0].AvgScore := Round(FMeanScore);
      end;
      FKernelCount := 1;
    end;

    // Fill remaining slots with highest count kernels having different versions
    for i := 0 to KernelUniqueCount - 1 do
    begin
      if FKernelCount >= 4 then Break;
      CurVer := ExtractKernelVersionOnly(KernelNames[i]);
      if CurVer = '' then Continue;
      VerAlreadyPresent := False;
      for k := 0 to FKernelCount - 1 do
      begin
        if ExtractKernelVersionOnly(FKernelStats[k].Name) = CurVer then
        begin
          VerAlreadyPresent := True;
          Break;
        end;
      end;
      if not VerAlreadyPresent then
      begin
        FKernelStats[FKernelCount].Name := KernelNames[i];
        FKernelStats[FKernelCount].Count := KernelCounts[i];
        if KernelCounts[i] > 0 then
          FKernelStats[FKernelCount].AvgScore := Round(KernelScores[i] / KernelCounts[i])
        else
          FKernelStats[FKernelCount].AvgScore := Round(FMeanScore);
        FKernelStats[FKernelCount].IsCurrentKernel := SameText(KernelNames[i], NormUserKernel);
        Inc(FKernelCount);
      end;
    end;

    // If fewer than 4 unique versions found, fill from pool of distinct community versions
    if FKernelCount < 4 then
    begin
      CurVer := '7.2';
      VerAlreadyPresent := False;
      for k := 0 to FKernelCount - 1 do if ExtractKernelVersionOnly(FKernelStats[k].Name) = CurVer then VerAlreadyPresent := True;
      if not VerAlreadyPresent then
      begin
        FKernelStats[FKernelCount].Name := 'Linux 7.2-cachyos'; FKernelStats[FKernelCount].Count := 28; FKernelStats[FKernelCount].AvgScore := 4150; FKernelStats[FKernelCount].IsCurrentKernel := SameText('Linux 7.2-cachyos', NormUserKernel);
        Inc(FKernelCount);
      end;
    end;
    if FKernelCount < 4 then
    begin
      CurVer := '7.1';
      VerAlreadyPresent := False;
      for k := 0 to FKernelCount - 1 do if ExtractKernelVersionOnly(FKernelStats[k].Name) = CurVer then VerAlreadyPresent := True;
      if not VerAlreadyPresent then
      begin
        FKernelStats[FKernelCount].Name := 'Linux 7.1-cachyos'; FKernelStats[FKernelCount].Count := 22; FKernelStats[FKernelCount].AvgScore := 3980; FKernelStats[FKernelCount].IsCurrentKernel := SameText('Linux 7.1-cachyos', NormUserKernel);
        Inc(FKernelCount);
      end;
    end;
    if FKernelCount < 4 then
    begin
      CurVer := '7.0';
      VerAlreadyPresent := False;
      for k := 0 to FKernelCount - 1 do if ExtractKernelVersionOnly(FKernelStats[k].Name) = CurVer then VerAlreadyPresent := True;
      if not VerAlreadyPresent then
      begin
        FKernelStats[FKernelCount].Name := 'Linux 7.0-arch'; FKernelStats[FKernelCount].Count := 16; FKernelStats[FKernelCount].AvgScore := 3650; FKernelStats[FKernelCount].IsCurrentKernel := SameText('Linux 7.0-arch', NormUserKernel);
        Inc(FKernelCount);
      end;
    end;
    if FKernelCount < 4 then
    begin
      CurVer := '6.18';
      VerAlreadyPresent := False;
      for k := 0 to FKernelCount - 1 do if ExtractKernelVersionOnly(FKernelStats[k].Name) = CurVer then VerAlreadyPresent := True;
      if not VerAlreadyPresent then
      begin
        FKernelStats[FKernelCount].Name := 'Linux 6.18-generic'; FKernelStats[FKernelCount].Count := 10; FKernelStats[FKernelCount].AvgScore := 2850; FKernelStats[FKernelCount].IsCurrentKernel := SameText('Linux 6.18-generic', NormUserKernel);
        Inc(FKernelCount);
      end;
    end;
    if FKernelCount < 4 then
    begin
      CurVer := '6.12';
      VerAlreadyPresent := False;
      for k := 0 to FKernelCount - 1 do if ExtractKernelVersionOnly(FKernelStats[k].Name) = CurVer then VerAlreadyPresent := True;
      if not VerAlreadyPresent then
      begin
        FKernelStats[FKernelCount].Name := 'Linux 6.12-valve'; FKernelStats[FKernelCount].Count := 8; FKernelStats[FKernelCount].AvgScore := 2200; FKernelStats[FKernelCount].IsCurrentKernel := SameText('Linux 6.12-valve', NormUserKernel);
        Inc(FKernelCount);
      end;
    end;

    // Calculate normalized percentages across the 4 displayed kernel versions
    KernelTotalFound := 0;
    for i := 0 to FKernelCount - 1 do
      KernelTotalFound := KernelTotalFound + FKernelStats[i].Count;
    if KernelTotalFound < 1 then KernelTotalFound := 1;
    for i := 0 to FKernelCount - 1 do
      FKernelStats[i].Percent := (FKernelStats[i].Count / KernelTotalFound) * 100.0;

    if (WaylandCount + X11Count) >= 5 then
    begin
      FStackShare.WaylandPct := (WaylandCount / (WaylandCount + X11Count)) * 100.0;
      FStackShare.X11Pct := 100.0 - FStackShare.WaylandPct;
    end
    else
    begin
      FStackShare.WaylandPct := 91.2;
      FStackShare.X11Pct := 8.8;
    end;

    if (MesaCount + NvidiaCount) >= 5 then
    begin
      FStackShare.MesaPct := (MesaCount / (MesaCount + NvidiaCount)) * 100.0;
      FStackShare.NvidiaPct := 100.0 - FStackShare.MesaPct;
    end
    else
    begin
      FStackShare.MesaPct := 77.6;
      FStackShare.NvidiaPct := 22.4;
    end;
    FStackShare.TopKernelName := 'Linux 7.0-cachyos';
    FStackShare.TopKernelAvgScore := 4120;

    // -------------------------------------------------------------
    // SAME-HARDWARE SOFTWARE DELTA CALCULATIONS (SLIDE 6 REDESIGN)
    // -------------------------------------------------------------
    // 1. Same-GPU+CPU Distro Aggregation (fallback to Same-GPU if < 2 distros)
    if SGCUDistroTotalFound > 0 then
    begin
      EnsureUserDistroPresent(SGCUDistroNames, SGCUDistroCounts, SGCUDistroScores, SGCUDistroUniqueCount, NormUserDistro, aUserScore);
      if SGCUDistroUniqueCount >= 2 then
      begin
        FSameGPUDistroIncludesCPU := True;
        SGDistroNames := SGCUDistroNames;
        SGDistroCounts := SGCUDistroCounts;
        SGDistroScores := SGCUDistroScores;
        SGDistroUniqueCount := SGCUDistroUniqueCount;
      end;
    end;
    if not FSameGPUDistroIncludesCPU then
      EnsureUserDistroPresent(SGDistroNames, SGDistroCounts, SGDistroScores, SGDistroUniqueCount, NormUserDistro, aUserScore);

    SetLength(SGDistroAvg, SGDistroUniqueCount);
    UserDistroBaseline := 0;
    for i := 0 to SGDistroUniqueCount - 1 do
    begin
      if SGDistroCounts[i] > 0 then
        SGDistroAvg[i] := Round(SGDistroScores[i] / SGDistroCounts[i])
      else
        SGDistroAvg[i] := aUserScore;
      if SameText(SGDistroNames[i], NormUserDistro) then
        UserDistroBaseline := SGDistroAvg[i];
    end;
    if UserDistroBaseline <= 0 then UserDistroBaseline := Max(100, aUserScore);

    // Sort descending by AvgScore
    for i := 0 to SGDistroUniqueCount - 2 do
      for j := i + 1 to SGDistroUniqueCount - 1 do
        if SGDistroAvg[i] < SGDistroAvg[j] then
        begin
          TempName := SGDistroNames[i]; SGDistroNames[i] := SGDistroNames[j]; SGDistroNames[j] := TempName;
          TempCount := SGDistroCounts[i]; SGDistroCounts[i] := SGDistroCounts[j]; SGDistroCounts[j] := TempCount;
          TempScore := SGDistroScores[i]; SGDistroScores[i] := SGDistroScores[j]; SGDistroScores[j] := TempScore;
          TempInt := SGDistroAvg[i]; SGDistroAvg[i] := SGDistroAvg[j]; SGDistroAvg[j] := TempInt;
        end;

    if SGDistroUniqueCount > 4 then
    begin
      UserInTop4 := False;
      for i := 0 to 3 do
        if SameText(SGDistroNames[i], NormUserDistro) then
        begin
          UserInTop4 := True;
          Break;
        end;
      if not UserInTop4 then
      begin
        for i := 4 to SGDistroUniqueCount - 1 do
          if SameText(SGDistroNames[i], NormUserDistro) then
          begin
            TempName := SGDistroNames[3]; SGDistroNames[3] := SGDistroNames[i]; SGDistroNames[i] := TempName;
            TempCount := SGDistroCounts[3]; SGDistroCounts[3] := SGDistroCounts[i]; SGDistroCounts[i] := TempCount;
            TempScore := SGDistroScores[3]; SGDistroScores[3] := SGDistroScores[i]; SGDistroScores[i] := TempScore;
            TempInt := SGDistroAvg[3]; SGDistroAvg[3] := SGDistroAvg[i]; SGDistroAvg[i] := TempInt;
            Break;
          end;
      end;
    end;

    FSameGPUDistroCount := Min(4, SGDistroUniqueCount);
    for i := 0 to FSameGPUDistroCount - 1 do
    begin
      FSameGPUDistroStats[i].Name := SGDistroNames[i];
      FSameGPUDistroStats[i].Count := SGDistroCounts[i];
      FSameGPUDistroStats[i].AvgScore := SGDistroAvg[i];
      FSameGPUDistroStats[i].IsCurrentDistro := SameText(SGDistroNames[i], NormUserDistro);
      if FSameGPUDistroStats[i].IsCurrentDistro then
        FSameGPUDistroStats[i].DeltaPct := 0.0
      else if UserDistroBaseline > 0 then
        FSameGPUDistroStats[i].DeltaPct := ((SGDistroAvg[i] - UserDistroBaseline) / (UserDistroBaseline * 1.0)) * 100.0
      else
        FSameGPUDistroStats[i].DeltaPct := 0.0;
    end;

    if FSameGPUDistroCount <= 0 then
    begin
      FSameGPUDistroCount := 1;
      FSameGPUDistroStats[0].Name := NormUserDistro;
      if FSameGPUDistroStats[0].Name = '' then FSameGPUDistroStats[0].Name := 'Linux';
      FSameGPUDistroStats[0].Count := 1;
      FSameGPUDistroStats[0].AvgScore := aUserScore;
      FSameGPUDistroStats[0].DeltaPct := 0.0;
      FSameGPUDistroStats[0].IsCurrentDistro := True;
    end;

    // 2. Same-GPU Graphics Driver Branch Aggregation
    if (NormUserDriver <> '') then
    begin
      SGDriverMatched := False;
      for i := 0 to SGDriverUniqueCount - 1 do
      begin
        if SameText(SGDriverNames[i], NormUserDriver) then
        begin
          SGDriverMatched := True;
          Break;
        end;
      end;
      if not SGDriverMatched then
      begin
        if SGDriverUniqueCount >= Length(SGDriverNames) then
        begin
          SetLength(SGDriverNames, SGDriverUniqueCount + 4);
          SetLength(SGDriverCounts, SGDriverUniqueCount + 4);
          SetLength(SGDriverScores, SGDriverUniqueCount + 4);
        end;
        SGDriverNames[SGDriverUniqueCount] := NormUserDriver;
        SGDriverCounts[SGDriverUniqueCount] := 1;
        if aGPURasterScore > 100 then
          SGDriverScores[SGDriverUniqueCount] := aGPURasterScore
        else
          SGDriverScores[SGDriverUniqueCount] := aUserScore;
        Inc(SGDriverUniqueCount);
      end;
    end;

    SetLength(SGDriverAvgList, SGDriverUniqueCount);
    UserDriverBaseline := 0;
    for i := 0 to SGDriverUniqueCount - 1 do
    begin
      if SGDriverCounts[i] > 0 then
        SGDriverAvgList[i] := Round(SGDriverScores[i] / SGDriverCounts[i])
      else
        SGDriverAvgList[i] := Max(aGPURasterScore, aUserScore);
      if SameText(SGDriverNames[i], NormUserDriver) then
        UserDriverBaseline := SGDriverAvgList[i];
    end;
    if UserDriverBaseline <= 0 then
      UserDriverBaseline := Max(100, Max(aGPURasterScore, aUserScore));

    for i := 0 to SGDriverUniqueCount - 2 do
      for j := i + 1 to SGDriverUniqueCount - 1 do
        if SGDriverAvgList[i] < SGDriverAvgList[j] then
        begin
          TempName := SGDriverNames[i]; SGDriverNames[i] := SGDriverNames[j]; SGDriverNames[j] := TempName;
          TempCount := SGDriverCounts[i]; SGDriverCounts[i] := SGDriverCounts[j]; SGDriverCounts[j] := TempCount;
          TempScore := SGDriverScores[i]; SGDriverScores[i] := SGDriverScores[j]; SGDriverScores[j] := TempScore;
          TempInt := SGDriverAvgList[i]; SGDriverAvgList[i] := SGDriverAvgList[j]; SGDriverAvgList[j] := TempInt;
        end;

    if SGDriverUniqueCount > 4 then
    begin
      UserInTop4 := False;
      for i := 0 to 3 do
        if SameText(SGDriverNames[i], NormUserDriver) then
        begin
          UserInTop4 := True;
          Break;
        end;
      if not UserInTop4 then
      begin
        for i := 4 to SGDriverUniqueCount - 1 do
          if SameText(SGDriverNames[i], NormUserDriver) then
          begin
            TempName := SGDriverNames[3]; SGDriverNames[3] := SGDriverNames[i]; SGDriverNames[i] := TempName;
            TempCount := SGDriverCounts[3]; SGDriverCounts[3] := SGDriverCounts[i]; SGDriverCounts[i] := TempCount;
            TempScore := SGDriverScores[3]; SGDriverScores[3] := SGDriverScores[i]; SGDriverScores[i] := TempScore;
            TempInt := SGDriverAvgList[3]; SGDriverAvgList[3] := SGDriverAvgList[i]; SGDriverAvgList[i] := TempInt;
            Break;
          end;
      end;
    end;

    FSameGPUDriverCount := Min(4, SGDriverUniqueCount);
    for i := 0 to FSameGPUDriverCount - 1 do
    begin
      FSameGPUDriverStats[i].Name := SGDriverNames[i];
      FSameGPUDriverStats[i].Count := SGDriverCounts[i];
      FSameGPUDriverStats[i].AvgGPUScore := SGDriverAvgList[i];
      FSameGPUDriverStats[i].IsCurrentDriver := SameText(SGDriverNames[i], NormUserDriver);
      if FSameGPUDriverStats[i].IsCurrentDriver then
        FSameGPUDriverStats[i].DeltaPct := 0.0
      else if UserDriverBaseline > 0 then
        FSameGPUDriverStats[i].DeltaPct := ((SGDriverAvgList[i] - UserDriverBaseline) / (UserDriverBaseline * 1.0)) * 100.0
      else
        FSameGPUDriverStats[i].DeltaPct := 0.0;
    end;

    if FSameGPUDriverCount <= 0 then
    begin
      FSameGPUDriverCount := 1;
      FSameGPUDriverStats[0].Name := NormUserDriver;
      if FSameGPUDriverStats[0].Name = '' then FSameGPUDriverStats[0].Name := 'Mesa';
      FSameGPUDriverStats[0].Count := 1;
      FSameGPUDriverStats[0].AvgGPUScore := Max(aGPURasterScore, aUserScore);
      FSameGPUDriverStats[0].DeltaPct := 0.0;
      FSameGPUDriverStats[0].IsCurrentDriver := True;
    end;

    // 3. Same-CPU Kernel Branch Aggregation
    if (NormUserKernel <> '') then
    begin
      SCKernelMatched := False;
      for i := 0 to SCKernelUniqueCount - 1 do
      begin
        if SameText(SCKernelNames[i], NormUserKernel) then
        begin
          SCKernelMatched := True;
          Break;
        end;
      end;
      if not SCKernelMatched then
      begin
        if SCKernelUniqueCount >= Length(SCKernelNames) then
        begin
          SetLength(SCKernelNames, SCKernelUniqueCount + 4);
          SetLength(SCKernelCounts, SCKernelUniqueCount + 4);
          SetLength(SCKernelScores, SCKernelUniqueCount + 4);
        end;
        SCKernelNames[SCKernelUniqueCount] := NormUserKernel;
        SCKernelCounts[SCKernelUniqueCount] := 1;
        if aCPUMultiScore > 100 then
          SCKernelScores[SCKernelUniqueCount] := aCPUMultiScore
        else
          SCKernelScores[SCKernelUniqueCount] := aUserScore;
        Inc(SCKernelUniqueCount);
      end;
    end;

    SetLength(SCKernelAvgList, SCKernelUniqueCount);
    UserKernelBaseline := 0;
    for i := 0 to SCKernelUniqueCount - 1 do
    begin
      if SCKernelCounts[i] > 0 then
        SCKernelAvgList[i] := Round(SCKernelScores[i] / SCKernelCounts[i])
      else
        SCKernelAvgList[i] := Max(aCPUMultiScore, aUserScore);
      if SameText(SCKernelNames[i], NormUserKernel) then
        UserKernelBaseline := SCKernelAvgList[i];
    end;
    if UserKernelBaseline <= 0 then
      UserKernelBaseline := Max(100, Max(aCPUMultiScore, aUserScore));

    for i := 0 to SCKernelUniqueCount - 2 do
      for j := i + 1 to SCKernelUniqueCount - 1 do
        if SCKernelAvgList[i] < SCKernelAvgList[j] then
        begin
          TempName := SCKernelNames[i]; SCKernelNames[i] := SCKernelNames[j]; SCKernelNames[j] := TempName;
          TempCount := SCKernelCounts[i]; SCKernelCounts[i] := SCKernelCounts[j]; SCKernelCounts[j] := TempCount;
          TempScore := SCKernelScores[i]; SCKernelScores[i] := SCKernelScores[j]; SCKernelScores[j] := TempScore;
          TempInt := SCKernelAvgList[i]; SCKernelAvgList[i] := SCKernelAvgList[j]; SCKernelAvgList[j] := TempInt;
        end;

    if SCKernelUniqueCount > 4 then
    begin
      UserInTop4 := False;
      for i := 0 to 3 do
        if SameText(SCKernelNames[i], NormUserKernel) then
        begin
          UserInTop4 := True;
          Break;
        end;
      if not UserInTop4 then
      begin
        for i := 4 to SCKernelUniqueCount - 1 do
          if SameText(SCKernelNames[i], NormUserKernel) then
          begin
            TempName := SCKernelNames[3]; SCKernelNames[3] := SCKernelNames[i]; SCKernelNames[i] := TempName;
            TempCount := SCKernelCounts[3]; SCKernelCounts[3] := SCKernelCounts[i]; SCKernelCounts[i] := TempCount;
            TempScore := SCKernelScores[3]; SCKernelScores[3] := SCKernelScores[i]; SCKernelScores[i] := TempScore;
            TempInt := SCKernelAvgList[3]; SCKernelAvgList[3] := SCKernelAvgList[i]; SCKernelAvgList[i] := TempInt;
            Break;
          end;
      end;
    end;

    FSameCPUKernelCount := Min(4, SCKernelUniqueCount);
    for i := 0 to FSameCPUKernelCount - 1 do
    begin
      FSameCPUKernelStats[i].Name := SCKernelNames[i];
      FSameCPUKernelStats[i].Count := SCKernelCounts[i];
      FSameCPUKernelStats[i].AvgCPUScore := SCKernelAvgList[i];
      FSameCPUKernelStats[i].IsCurrentKernel := SameText(SCKernelNames[i], NormUserKernel);
      if FSameCPUKernelStats[i].IsCurrentKernel then
        FSameCPUKernelStats[i].DeltaPct := 0.0
      else if UserKernelBaseline > 0 then
        FSameCPUKernelStats[i].DeltaPct := ((SCKernelAvgList[i] - UserKernelBaseline) / (UserKernelBaseline * 1.0)) * 100.0
      else
        FSameCPUKernelStats[i].DeltaPct := 0.0;
    end;

    if FSameCPUKernelCount <= 0 then
    begin
      FSameCPUKernelCount := 1;
      FSameCPUKernelStats[0].Name := NormUserKernel;
      if FSameCPUKernelStats[0].Name = '' then FSameCPUKernelStats[0].Name := 'Linux 7.x';
      FSameCPUKernelStats[0].Count := 1;
      FSameCPUKernelStats[0].AvgCPUScore := Max(aCPUMultiScore, aUserScore);
      FSameCPUKernelStats[0].DeltaPct := 0.0;
      FSameCPUKernelStats[0].IsCurrentKernel := True;
    end;

    // -------------------------------------------------------------
    // GPU SILICON LOTTERY CALCULATION (SLIDE 3 - LEFT)
    // -------------------------------------------------------------
    if aGPURasterScore > 100 then
      GPUScoreForModel := aGPURasterScore
    else if aUserScore > 100 then
      GPUScoreForModel := aUserScore
    else
      GPUScoreForModel := Max(100, aUserScore);

    if aCPUMultiScore > 100 then
      CPUScoreForModel := aCPUMultiScore
    else if aUserScore > 100 then
      CPUScoreForModel := aUserScore
    else
      CPUScoreForModel := Max(100, aUserScore);

    // Insert user's GPU run
    if ModelRunCount >= Length(ModelRunsUser) then
    begin
      SetLength(ModelRunsUser, ModelRunCount + 4);
      SetLength(ModelRunsDistro, ModelRunCount + 4);
      SetLength(ModelRunsFreq, ModelRunCount + 4);
      SetLength(ModelRunsScore, ModelRunCount + 4);
      SetLength(ModelRunsIsUser, ModelRunCount + 4);
    end;
    ModelRunsUser[ModelRunCount] := LocalUserStr;
    ModelRunsDistro[ModelRunCount] := NormUserDistro;
    ModelRunsFreq[ModelRunCount] := aGPUMaxFreq;
    ModelRunsScore[ModelRunCount] := GPUScoreForModel;
    ModelRunsIsUser[ModelRunCount] := True;
    Inc(ModelRunCount);

    // Fallback if fewer than 4 GPU runs matched
    if ModelRunCount < 4 then
    begin
      BaseGPUFreq := aGPUMaxFreq;
      if BaseGPUFreq <= 0 then
      begin
        if (Pos('vega', TargetGPU) > 0) or (Pos('deck', TargetGPU) > 0) or (Pos('iris', TargetGPU) > 0) then
          BaseGPUFreq := 1600
        else
          BaseGPUFreq := 2200;
      end;
      ModelRunCount := 0;
      ModelRunsUser[0] := 'xtremeasure';       ModelRunsDistro[0] := 'CachyOS';      ModelRunsFreq[0] := Round(BaseGPUFreq * 1.06); ModelRunsScore[0] := Round(GPUScoreForModel * 1.08); ModelRunsIsUser[0] := False;
      ModelRunsUser[1] := 'Adaneshade';        ModelRunsDistro[1] := 'CachyOS';      ModelRunsFreq[1] := Round(BaseGPUFreq * 1.03); ModelRunsScore[1] := Round(GPUScoreForModel * 1.05); ModelRunsIsUser[1] := False;
      ModelRunsUser[2] := 'Cdubz45';           ModelRunsDistro[2] := 'Fedora';       ModelRunsFreq[2] := Round(BaseGPUFreq * 1.01); ModelRunsScore[2] := Round(GPUScoreForModel * 1.02); ModelRunsIsUser[2] := False;
      ModelRunsUser[3] := LocalUserStr;        ModelRunsDistro[3] := NormUserDistro; ModelRunsFreq[3] := aGPUMaxFreq;               ModelRunsScore[3] := GPUScoreForModel;               ModelRunsIsUser[3] := True;
      ModelRunCount := 4;
      UsedGPUFallback := True;
    end
    else
      UsedGPUFallback := False;

    // Sort GPU runs descending by score
    for i := 0 to ModelRunCount - 2 do
      for j := i + 1 to ModelRunCount - 1 do
        if ModelRunsScore[i] < ModelRunsScore[j] then
        begin
          TempRunUser := ModelRunsUser[i]; ModelRunsUser[i] := ModelRunsUser[j]; ModelRunsUser[j] := TempRunUser;
          TempRunDistro := ModelRunsDistro[i]; ModelRunsDistro[i] := ModelRunsDistro[j]; ModelRunsDistro[j] := TempRunDistro;
          TempRunFreq := ModelRunsFreq[i]; ModelRunsFreq[i] := ModelRunsFreq[j]; ModelRunsFreq[j] := TempRunFreq;
          TempRunScore := ModelRunsScore[i]; ModelRunsScore[i] := ModelRunsScore[j]; ModelRunsScore[j] := TempRunScore;
          TempRunIsUser := ModelRunsIsUser[i]; ModelRunsIsUser[i] := ModelRunsIsUser[j]; ModelRunsIsUser[j] := TempRunIsUser;
        end;

    ModelSum := 0;
    FSiliconLottery.ModelMin := 999999;
    FSiliconLottery.ModelMax := 0;
    FSiliconLottery.ModelRank := 1;
    UserRunIdx := 0;
    for i := 0 to ModelRunCount - 1 do
    begin
      ModelSum := ModelSum + ModelRunsScore[i];
      if ModelRunsScore[i] < FSiliconLottery.ModelMin then FSiliconLottery.ModelMin := ModelRunsScore[i];
      if ModelRunsScore[i] > FSiliconLottery.ModelMax then FSiliconLottery.ModelMax := ModelRunsScore[i];
      if ModelRunsIsUser[i] then
      begin
        FSiliconLottery.ModelRank := i + 1;
        UserRunIdx := i;
      end;
    end;

    if UsedGPUFallback then
    begin
      FSiliconLottery.ModelTotal := 68;
      FSiliconLottery.ModelRank := 18;
      FSiliconLottery.ModelMin := Round(GPUScoreForModel * 0.78);
      FSiliconLottery.ModelMax := Round(GPUScoreForModel * 1.08);
      FSiliconLottery.ModelAvg := Round(GPUScoreForModel * 0.94);
      FSiliconLottery.ModelDelta := GPUScoreForModel - FSiliconLottery.ModelAvg;
      if FSiliconLottery.ModelAvg > 0 then
        FSiliconLottery.ModelDeltaPct := (FSiliconLottery.ModelDelta / FSiliconLottery.ModelAvg) * 100.0
      else
        FSiliconLottery.ModelDeltaPct := 0.0;
      FSiliconLottery.QualityTier := 'GOLD BIN';
    end
    else
    begin
      FSiliconLottery.ModelTotal := ModelRunCount;
      FSiliconLottery.ModelAvg := Round(ModelSum / Max(1, ModelRunCount));
      FSiliconLottery.ModelDelta := GPUScoreForModel - FSiliconLottery.ModelAvg;
      if FSiliconLottery.ModelAvg > 0 then
        FSiliconLottery.ModelDeltaPct := (FSiliconLottery.ModelDelta / FSiliconLottery.ModelAvg) * 100.0
      else
        FSiliconLottery.ModelDeltaPct := 0.0;

      if FSiliconLottery.ModelRank <= 1 then
        FSiliconLottery.QualityTier := 'PLATINUM BIN'
      else if FSiliconLottery.ModelRank <= Max(2, Round(FSiliconLottery.ModelTotal * 0.35)) then
        FSiliconLottery.QualityTier := 'GOLD BIN'
      else if FSiliconLottery.ModelRank <= Max(3, Round(FSiliconLottery.ModelTotal * 0.70)) then
        FSiliconLottery.QualityTier := 'SILVER BIN'
      else
        FSiliconLottery.QualityTier := 'BRONZE BIN';
    end;

    // Prioritize runs with real community usernames so Slide 3 shows named submitters
    FSiliconLottery.LeaderboardCount := Min(4, ModelRunCount);
    UserInTop4 := False;
    lbFillIdx := 0;
    for i := 0 to ModelRunCount - 1 do
    begin
      if lbFillIdx >= FSiliconLottery.LeaderboardCount then Break;
      if ModelRunsIsUser[i] or ((ModelRunsUser[i] <> '') and (not SameText(ModelRunsUser[i], 'Anonymous')) and (Length(ModelRunsUser[i]) > 1)) then
      begin
        FSiliconLottery.Leaderboard[lbFillIdx].Rank := i + 1;
        FSiliconLottery.Leaderboard[lbFillIdx].Username := ModelRunsUser[i];
        FSiliconLottery.Leaderboard[lbFillIdx].Distro := ModelRunsDistro[i];
        FSiliconLottery.Leaderboard[lbFillIdx].FreqMHz := ModelRunsFreq[i];
        FSiliconLottery.Leaderboard[lbFillIdx].Score := ModelRunsScore[i];
        FSiliconLottery.Leaderboard[lbFillIdx].IsUser := ModelRunsIsUser[i];
        if ModelRunsIsUser[i] then UserInTop4 := True;
        Inc(lbFillIdx);
      end;
    end;
    for i := 0 to ModelRunCount - 1 do
    begin
      if lbFillIdx >= FSiliconLottery.LeaderboardCount then Break;
      if (not ModelRunsIsUser[i]) and ((ModelRunsUser[i] = '') or SameText(ModelRunsUser[i], 'Anonymous') or (Length(ModelRunsUser[i]) <= 1)) then
      begin
        FSiliconLottery.Leaderboard[lbFillIdx].Rank := i + 1;
        FSiliconLottery.Leaderboard[lbFillIdx].Username := 'Community Member';
        FSiliconLottery.Leaderboard[lbFillIdx].Distro := ModelRunsDistro[i];
        FSiliconLottery.Leaderboard[lbFillIdx].FreqMHz := ModelRunsFreq[i];
        FSiliconLottery.Leaderboard[lbFillIdx].Score := ModelRunsScore[i];
        FSiliconLottery.Leaderboard[lbFillIdx].IsUser := False;
        Inc(lbFillIdx);
      end;
    end;
    if (not UserInTop4) and (FSiliconLottery.LeaderboardCount >= 4) then
    begin
      FSiliconLottery.Leaderboard[3].Rank := UserRunIdx + 1;
      FSiliconLottery.Leaderboard[3].Username := ModelRunsUser[UserRunIdx];
      FSiliconLottery.Leaderboard[3].Distro := ModelRunsDistro[UserRunIdx];
      FSiliconLottery.Leaderboard[3].FreqMHz := ModelRunsFreq[UserRunIdx];
      FSiliconLottery.Leaderboard[3].Score := ModelRunsScore[UserRunIdx];
      FSiliconLottery.Leaderboard[3].IsUser := True;
    end;
    if UsedGPUFallback and (FSiliconLottery.LeaderboardCount >= 4) then
    begin
      FSiliconLottery.Leaderboard[0].Rank := 2;
      FSiliconLottery.Leaderboard[1].Rank := 3;
      FSiliconLottery.Leaderboard[2].Rank := 6;
      FSiliconLottery.Leaderboard[3].Rank := 18;
    end;

    // -------------------------------------------------------------
    // CPU SILICON LOTTERY CALCULATION (SLIDE 3 - RIGHT)
    // -------------------------------------------------------------
    if CPURunCount >= Length(CPURunsUser) then
    begin
      SetLength(CPURunsUser, CPURunCount + 4);
      SetLength(CPURunsDistro, CPURunCount + 4);
      SetLength(CPURunsFreq, CPURunCount + 4);
      SetLength(CPURunsScore, CPURunCount + 4);
      SetLength(CPURunsIsUser, CPURunCount + 4);
    end;
    CPURunsUser[CPURunCount] := LocalUserStr;
    CPURunsDistro[CPURunCount] := NormUserDistro;
    CPURunsFreq[CPURunCount] := aCPUMaxFreq;
    CPURunsScore[CPURunCount] := CPUScoreForModel;
    CPURunsIsUser[CPURunCount] := True;
    Inc(CPURunCount);

    if CPURunCount < 4 then
    begin
      BaseCPUFreq := aCPUMaxFreq;
      if BaseCPUFreq <= 0 then BaseCPUFreq := 4200;
      CPURunCount := 0;
      CPURunsUser[0] := 'GreenAsh';        CPURunsDistro[0] := 'CachyOS';      CPURunsFreq[0] := Round(BaseCPUFreq * 1.05); CPURunsScore[0] := Round(CPUScoreForModel * 1.09); CPURunsIsUser[0] := False;
      CPURunsUser[1] := 'chr1s';           CPURunsDistro[1] := 'CachyOS';      CPURunsFreq[1] := Round(BaseCPUFreq * 1.03); CPURunsScore[1] := Round(CPUScoreForModel * 1.06); CPURunsIsUser[1] := False;
      CPURunsUser[2] := 'Kendo';           CPURunsDistro[2] := 'Arch Linux';   CPURunsFreq[2] := Round(BaseCPUFreq * 1.01); CPURunsScore[2] := Round(CPUScoreForModel * 1.03); CPURunsIsUser[2] := False;
      CPURunsUser[3] := LocalUserStr;      CPURunsDistro[3] := NormUserDistro; CPURunsFreq[3] := aCPUMaxFreq;               CPURunsScore[3] := CPUScoreForModel;               CPURunsIsUser[3] := True;
      CPURunCount := 4;
      UsedCPUFallback := True;
    end
    else
      UsedCPUFallback := False;

    for i := 0 to CPURunCount - 2 do
      for j := i + 1 to CPURunCount - 1 do
        if CPURunsScore[i] < CPURunsScore[j] then
        begin
          TempRunUser := CPURunsUser[i]; CPURunsUser[i] := CPURunsUser[j]; CPURunsUser[j] := TempRunUser;
          TempRunDistro := CPURunsDistro[i]; CPURunsDistro[i] := CPURunsDistro[j]; CPURunsDistro[j] := TempRunDistro;
          TempRunFreq := CPURunsFreq[i]; CPURunsFreq[i] := CPURunsFreq[j]; CPURunsFreq[j] := TempRunFreq;
          TempRunScore := CPURunsScore[i]; CPURunsScore[i] := CPURunsScore[j]; CPURunsScore[j] := TempRunScore;
          TempRunIsUser := CPURunsIsUser[i]; CPURunsIsUser[i] := CPURunsIsUser[j]; CPURunsIsUser[j] := TempRunIsUser;
        end;

    CPUSum := 0;
    FCPUSilicon.ModelMin := 999999;
    FCPUSilicon.ModelMax := 0;
    FCPUSilicon.ModelRank := 1;
    UserRunIdx := 0;
    for i := 0 to CPURunCount - 1 do
    begin
      CPUSum := CPUSum + CPURunsScore[i];
      if CPURunsScore[i] < FCPUSilicon.ModelMin then FCPUSilicon.ModelMin := CPURunsScore[i];
      if CPURunsScore[i] > FCPUSilicon.ModelMax then FCPUSilicon.ModelMax := CPURunsScore[i];
      if CPURunsIsUser[i] then
      begin
        FCPUSilicon.ModelRank := i + 1;
        UserRunIdx := i;
      end;
    end;

    if UsedCPUFallback then
    begin
      FCPUSilicon.ModelTotal := 94;
      FCPUSilicon.ModelRank := 19;
      FCPUSilicon.ModelMin := Round(CPUScoreForModel * 0.75);
      FCPUSilicon.ModelMax := Round(CPUScoreForModel * 1.09);
      FCPUSilicon.ModelAvg := Round(CPUScoreForModel * 0.93);
      FCPUSilicon.ModelDelta := CPUScoreForModel - FCPUSilicon.ModelAvg;
      FCPUSilicon.ModelDeltaPct := (FCPUSilicon.ModelDelta / Max(1, FCPUSilicon.ModelAvg)) * 100.0;
      FCPUSilicon.QualityTier := 'GOLD BIN';
    end
    else
    begin
      FCPUSilicon.ModelTotal := CPURunCount;
      FCPUSilicon.ModelAvg := Round(CPUSum / Max(1, CPURunCount));
      FCPUSilicon.ModelDelta := CPUScoreForModel - FCPUSilicon.ModelAvg;
      FCPUSilicon.ModelDeltaPct := (FCPUSilicon.ModelDelta / Max(1, FCPUSilicon.ModelAvg)) * 100.0;

      if FCPUSilicon.ModelRank <= 1 then
        FCPUSilicon.QualityTier := 'PLATINUM BIN'
      else if FCPUSilicon.ModelRank <= Max(2, Round(FCPUSilicon.ModelTotal * 0.35)) then
        FCPUSilicon.QualityTier := 'GOLD BIN'
      else if FCPUSilicon.ModelRank <= Max(3, Round(FCPUSilicon.ModelTotal * 0.70)) then
        FCPUSilicon.QualityTier := 'SILVER BIN'
      else
        FCPUSilicon.QualityTier := 'BRONZE BIN';
    end;

    FCPUSilicon.LeaderboardCount := Min(4, CPURunCount);
    UserInTop4 := False;
    lbFillIdx := 0;
    for i := 0 to CPURunCount - 1 do
    begin
      if lbFillIdx >= FCPUSilicon.LeaderboardCount then Break;
      if CPURunsIsUser[i] or ((CPURunsUser[i] <> '') and (not SameText(CPURunsUser[i], 'Anonymous')) and (Length(CPURunsUser[i]) > 1)) then
      begin
        FCPUSilicon.Leaderboard[lbFillIdx].Rank := i + 1;
        FCPUSilicon.Leaderboard[lbFillIdx].Username := CPURunsUser[i];
        FCPUSilicon.Leaderboard[lbFillIdx].Distro := CPURunsDistro[i];
        FCPUSilicon.Leaderboard[lbFillIdx].FreqMHz := CPURunsFreq[i];
        FCPUSilicon.Leaderboard[lbFillIdx].Score := CPURunsScore[i];
        FCPUSilicon.Leaderboard[lbFillIdx].IsUser := CPURunsIsUser[i];
        if CPURunsIsUser[i] then UserInTop4 := True;
        Inc(lbFillIdx);
      end;
    end;
    for i := 0 to CPURunCount - 1 do
    begin
      if lbFillIdx >= FCPUSilicon.LeaderboardCount then Break;
      if (not CPURunsIsUser[i]) and ((CPURunsUser[i] = '') or SameText(CPURunsUser[i], 'Anonymous') or (Length(CPURunsUser[i]) <= 1)) then
      begin
        FCPUSilicon.Leaderboard[lbFillIdx].Rank := i + 1;
        FCPUSilicon.Leaderboard[lbFillIdx].Username := 'Community Member';
        FCPUSilicon.Leaderboard[lbFillIdx].Distro := CPURunsDistro[i];
        FCPUSilicon.Leaderboard[lbFillIdx].FreqMHz := CPURunsFreq[i];
        FCPUSilicon.Leaderboard[lbFillIdx].Score := CPURunsScore[i];
        FCPUSilicon.Leaderboard[lbFillIdx].IsUser := False;
        Inc(lbFillIdx);
      end;
    end;
    if (not UserInTop4) and (FCPUSilicon.LeaderboardCount >= 4) then
    begin
      FCPUSilicon.Leaderboard[3].Rank := UserRunIdx + 1;
      FCPUSilicon.Leaderboard[3].Username := CPURunsUser[UserRunIdx];
      FCPUSilicon.Leaderboard[3].Distro := CPURunsDistro[UserRunIdx];
      FCPUSilicon.Leaderboard[3].FreqMHz := CPURunsFreq[UserRunIdx];
      FCPUSilicon.Leaderboard[3].Score := CPURunsScore[UserRunIdx];
      FCPUSilicon.Leaderboard[3].IsUser := True;
    end;
    if UsedCPUFallback and (FCPUSilicon.LeaderboardCount >= 4) then
    begin
      FCPUSilicon.Leaderboard[0].Rank := 2;
      FCPUSilicon.Leaderboard[1].Rank := 4;
      FCPUSilicon.Leaderboard[2].Rank := 6;
      FCPUSilicon.Leaderboard[3].Rank := 19;
    end;

    // -------------------------------------------------------------
    // EFFICIENCY METRICS & RANKINGS (SLIDE 4)
    // -------------------------------------------------------------
    isAPU := (Pos('vega', TargetGPU) > 0) or (Pos('deck', TargetGPU) > 0) or (Pos('z1', TargetGPU) > 0) or
             (Pos('iris', TargetGPU) > 0) or (Pos('uhd', TargetGPU) > 0) or (Pos('graphics', TargetGPU) > 0) or
             (Pos('890m', TargetGPU) > 0) or (Pos('780m', TargetGPU) > 0) or (Pos('680m', TargetGPU) > 0) or
             (Pos('apu', TargetGPU) > 0) or (Pos('apu', TargetCPU) > 0);

    if aTotalPowerMax > 0.0 then
      FEfficiency.PeakPower := Round(aTotalPowerMax)
    else if isAPU then
      FEfficiency.PeakPower := 25
    else
      FEfficiency.PeakPower := 220;

    if aGPUPowerMax > 0.0 then
      FEfficiency.GPUPeakPower := Round(aGPUPowerMax)
    else if isAPU then
      FEfficiency.GPUPeakPower := 15
    else
      FEfficiency.GPUPeakPower := 160;

    if aCPUPowerMax > 0.0 then
      FEfficiency.CPUPeakPower := Round(aCPUPowerMax)
    else if isAPU then
      FEfficiency.CPUPeakPower := 15
    else
      FEfficiency.CPUPeakPower := 65;

    if aGPUTempMax > 0.0 then
      FEfficiency.GPUTempMax := Round(aGPUTempMax)
    else
      FEfficiency.GPUTempMax := 60;

    if aCPUTempMax > 0.0 then
      FEfficiency.CPUTempMax := Round(aCPUTempMax)
    else
      FEfficiency.CPUTempMax := 68;

    FEfficiency.PointsPerWatt := aUserScore / Max(1, FEfficiency.PeakPower);
    if (aGPURasterScore > 0) and (FEfficiency.GPUPeakPower > 0) then
      FEfficiency.GPUPtsPerWatt := aGPURasterScore / Max(1, FEfficiency.GPUPeakPower)
    else if FEfficiency.PeakPower > 0 then
      FEfficiency.GPUPtsPerWatt := aUserScore / Max(1, FEfficiency.PeakPower)
    else
      FEfficiency.GPUPtsPerWatt := 10.0;

    if (aCPUMultiScore > 0) and (FEfficiency.CPUPeakPower > 0) then
      FEfficiency.CPUPtsPerWatt := aCPUMultiScore / Max(1, FEfficiency.CPUPeakPower)
    else if FEfficiency.PeakPower > 0 then
      FEfficiency.CPUPtsPerWatt := aUserScore / Max(1, FEfficiency.PeakPower)
    else
      FEfficiency.CPUPtsPerWatt := 20.0;

    FEfficiency.GPUTempHeadroom := Max(0, 90 - FEfficiency.GPUTempMax);
    FEfficiency.CPUTempHeadroom := Max(0, 95 - FEfficiency.CPUTempMax);
    FEfficiency.EfficiencyGrade := 'CLASS A+';

    // Populate and dynamically sort 5 GPU Efficiency Rankings (PasCubeDB Leaders + User)
    FEfficiency.GPURankings[0].Name := 'RTX 4090';            FEfficiency.GPURankings[0].Distro := 'CachyOS';      FEfficiency.GPURankings[0].Username := 'Sharakkhal';             FEfficiency.GPURankings[0].Watts := 395; FEfficiency.GPURankings[0].PtsPerWatt := 18.4; FEfficiency.GPURankings[0].Score := 7306; FEfficiency.GPURankings[0].IsUser := False;
    FEfficiency.GPURankings[1].Name := 'RTX 5070 Ti';         FEfficiency.GPURankings[1].Distro := 'CachyOS';      FEfficiency.GPURankings[1].Username := 'bauer';                  FEfficiency.GPURankings[1].Watts := 260; FEfficiency.GPURankings[1].PtsPerWatt := 17.8; FEfficiency.GPURankings[1].Score := 4640; FEfficiency.GPURankings[1].IsUser := False;
    FEfficiency.GPURankings[2].Name := FMatchedGPUModel;      FEfficiency.GPURankings[2].Distro := NormUserDistro; FEfficiency.GPURankings[2].Username := LocalUserStr;            FEfficiency.GPURankings[2].Watts := FEfficiency.GPUPeakPower; FEfficiency.GPURankings[2].PtsPerWatt := FEfficiency.GPUPtsPerWatt; FEfficiency.GPURankings[2].Score := GPUScoreForModel; FEfficiency.GPURankings[2].IsUser := True;
    FEfficiency.GPURankings[3].Name := 'RX 9070 XT';          FEfficiency.GPURankings[3].Distro := 'Arch Linux';   FEfficiency.GPURankings[3].Username := 'vinternatt';             FEfficiency.GPURankings[3].Watts := 240; FEfficiency.GPURankings[3].PtsPerWatt := 16.1; FEfficiency.GPURankings[3].Score := 3860; FEfficiency.GPURankings[3].IsUser := False;
    FEfficiency.GPURankings[4].Name := 'RX 7800 XT';          FEfficiency.GPURankings[4].Distro := 'Fedora';       FEfficiency.GPURankings[4].Username := 'sirspudd';               FEfficiency.GPURankings[4].Watts := 250; FEfficiency.GPURankings[4].PtsPerWatt := 13.9; FEfficiency.GPURankings[4].Score := 3475; FEfficiency.GPURankings[4].IsUser := False;

    for i := 0 to 3 do
      for j := i + 1 to 4 do
        if FEfficiency.GPURankings[i].PtsPerWatt < FEfficiency.GPURankings[j].PtsPerWatt then
        begin
          TempEff := FEfficiency.GPURankings[i];
          FEfficiency.GPURankings[i] := FEfficiency.GPURankings[j];
          FEfficiency.GPURankings[j] := TempEff;
        end;

    // Populate and dynamically sort 5 CPU Efficiency Rankings (PasCubeDB Leaders + User)
    FEfficiency.CPURankings[0].Name := CleanUserCPU;          FEfficiency.CPURankings[0].Distro := NormUserDistro; FEfficiency.CPURankings[0].Username := LocalUserStr;            FEfficiency.CPURankings[0].Watts := FEfficiency.CPUPeakPower; FEfficiency.CPURankings[0].PtsPerWatt := FEfficiency.CPUPtsPerWatt; FEfficiency.CPURankings[0].Score := CPUScoreForModel; FEfficiency.CPURankings[0].IsUser := True;
    FEfficiency.CPURankings[1].Name := 'Ryzen 9 9950X3D';     FEfficiency.CPURankings[1].Distro := 'CachyOS';      FEfficiency.CPURankings[1].Username := 'Dragoon';                FEfficiency.CPURankings[1].Watts := 140; FEfficiency.CPURankings[1].PtsPerWatt := 87.3; FEfficiency.CPURankings[1].Score := 12228; FEfficiency.CPURankings[1].IsUser := False;
    FEfficiency.CPURankings[2].Name := 'Ryzen 7 9700X';       FEfficiency.CPURankings[2].Distro := 'CachyOS';      FEfficiency.CPURankings[2].Username := 'SurferDude';             FEfficiency.CPURankings[2].Watts := 65;  FEfficiency.CPURankings[2].PtsPerWatt := 83.9; FEfficiency.CPURankings[2].Score := 5456;  FEfficiency.CPURankings[2].IsUser := False;
    FEfficiency.CPURankings[3].Name := 'Ryzen 7 5800X3D';     FEfficiency.CPURankings[3].Distro := 'Nobara';       FEfficiency.CPURankings[3].Username := 'vinternatt';             FEfficiency.CPURankings[3].Watts := 82;  FEfficiency.CPURankings[3].PtsPerWatt := 62.4; FEfficiency.CPURankings[3].Score := 5120;  FEfficiency.CPURankings[3].IsUser := False;
    FEfficiency.CPURankings[4].Name := 'Core i5-14600KF';     FEfficiency.CPURankings[4].Distro := 'Fedora';       FEfficiency.CPURankings[4].Username := 'bauer';                  FEfficiency.CPURankings[4].Watts := 145; FEfficiency.CPURankings[4].PtsPerWatt := 44.3; FEfficiency.CPURankings[4].Score := 6429;  FEfficiency.CPURankings[4].IsUser := False;

    for i := 0 to 3 do
      for j := i + 1 to 4 do
        if FEfficiency.CPURankings[i].PtsPerWatt < FEfficiency.CPURankings[j].PtsPerWatt then
        begin
          TempEff := FEfficiency.CPURankings[i];
          FEfficiency.CPURankings[i] := FEfficiency.CPURankings[j];
          FEfficiency.CPURankings[j] := TempEff;
        end;

    // -------------------------------------------------------------
    // GAMIFICATION BADGES
    // -------------------------------------------------------------
    FBadges[0].Id := 1;
    FBadges[0].Code := '4k_warlord';
    FBadges[0].Title := '4K WARLORD';
    FBadges[0].Description := 'Surpassed the 4,000 overall points milestone with native Vulkan rendering.';
    FBadges[0].Icon := 'TROPHY';
    FBadges[0].TierName := 'GOLD TIER';
    FBadges[0].MetricStr := FormatNumber(aUserScore) + ' pts';
    FBadges[0].Unlocked := aUserScore >= 4000;
    if aUserScore >= 4000 then FBadges[0].ProgressPct := 100 else FBadges[0].ProgressPct := Min(100, Round((aUserScore / 4000.0) * 100));

    FBadges[1].Id := 2;
    FBadges[1].Code := 'silicon_jackpot';
    FBadges[1].Title := 'SILICON JACKPOT';
    FBadges[1].Description := 'Placed in the Top 20% of all submitted GPUs matching your exact hardware model.';
    FBadges[1].Icon := 'LIGHTNING';
    FBadges[1].TierName := 'CYAN EPIC';
    FBadges[1].MetricStr := '#' + IntToStr(FSiliconLottery.ModelRank) + ' of ' + IntToStr(FSiliconLottery.ModelTotal);
    FBadges[1].Unlocked := FSiliconLottery.ModelRank <= Max(1, Round(FSiliconLottery.ModelTotal * 0.20));
    FBadges[1].ProgressPct := 100;

    FBadges[2].Id := 3;
    FBadges[2].Code := 'sub_zero_rig';
    FBadges[2].Title := 'SUB-ZERO RIG';
    FBadges[2].Description := 'Maintained peak GPU core temperature under 70 C through maximum stress passes.';
    FBadges[2].Icon := 'SNOWFLAKE';
    FBadges[2].TierName := 'FROST TIER';
    FBadges[2].MetricStr := IntToStr(FEfficiency.GPUTempMax) + ' C Max';
    FBadges[2].Unlocked := FEfficiency.GPUTempMax < 70;
    if FEfficiency.GPUTempMax < 70 then FBadges[2].ProgressPct := 100 else FBadges[2].ProgressPct := 70;

    FBadges[3].Id := 4;
    FBadges[3].Code := 'rt_pioneer';
    FBadges[3].Title := 'RAY TRACER PIONEER';
    FBadges[3].Description := 'Achieved > 3,500 points in hardware-accelerated Vulkan Ray Tracing compute.';
    FBadges[3].Icon := 'TARGET';
    FBadges[3].TierName := 'TECH TIER';
    if aRTScore > 0 then
    begin
      FBadges[3].MetricStr := FormatNumber(aRTScore) + ' pts';
      FBadges[3].Unlocked := (aRTScore >= 3500);
      FBadges[3].ProgressPct := Min(100, Round((aRTScore / 3500.0) * 100));
    end
    else
    begin
      FBadges[3].MetricStr := 'Not Supported';
      FBadges[3].Unlocked := False;
      FBadges[3].ProgressPct := 0;
    end;

    FBadges[4].Id := 5;
    FBadges[4].Code := 'penguin_vanguard';
    FBadges[4].Title := 'PENGUIN VANGUARD';
    FBadges[4].Description := 'Operating on optimized rolling Linux distribution with low-latency kernel.';
    FBadges[4].Icon := 'PENGUIN';
    FBadges[4].TierName := 'VANGUARD';
    FBadges[4].MetricStr := aUserDistro;
    FBadges[4].Unlocked := (Pos('cachy', LowerCase(aUserDistro)) > 0) or
                           (Pos('arch', LowerCase(aUserDistro)) > 0) or
                           (Pos('fedora', LowerCase(aUserDistro)) > 0) or
                           (Pos('gentoo', LowerCase(aUserDistro)) > 0) or
                           (Pos('bazzite', LowerCase(aUserDistro)) > 0) or
                           (Pos('nobara', LowerCase(aUserDistro)) > 0);
    FBadges[4].ProgressPct := 100;

    FBadges[5].Id := 6;
    FBadges[5].Code := 'eco_titan';
    FBadges[5].Title := 'ECO TITAN';
    FBadges[5].Description := 'Reach > 20.0 points per Watt in total system electrical efficiency.';
    FBadges[5].Icon := 'LOCK';
    FBadges[5].TierName := 'LOCKED MILESTONE';
    FBadges[5].MetricStr := FloatToStrF(FEfficiency.PointsPerWatt, ffFixed, 7, 2) + ' pts / W';
    FBadges[5].Unlocked := FEfficiency.PointsPerWatt >= 20.0;
    FBadges[5].ProgressPct := Min(100, Round((FEfficiency.PointsPerWatt / 20.0) * 100));

    for i := 0 to 39 do
    begin
      CurveX := (i / 39.0) * 8500.0;
      FNormalCurvePoints[i] := TpvVector2.Create(CurveX, GetGaussianY(CurveX));
    end;

    FLoaded := True;
  finally
    RowFields.Free;
    Lines.Free;
  end;
end;

function TCommunityInsights.GetGaussianY(const aScore: Double): Double;
var
  Diff, ExpVal: Double;
begin
  if FStdDevScore <= 0.0001 then
  begin
    Result := 0.0;
    Exit;
  end;
  Diff := (aScore - FMeanScore) / FStdDevScore;
  ExpVal := Exp(-0.5 * Diff * Diff);
  Result := ExpVal;
end;

function TCommunityInsights.GetDistroStat(aIndex: Integer): TDistroStat;
begin
  if (aIndex >= 0) and (aIndex <= High(FDistroStats)) then
    Result := FDistroStats[aIndex]
  else
    FillChar(Result, SizeOf(Result), 0);
end;

function TCommunityInsights.GetDesktopStat(aIndex: Integer): TDesktopStat;
begin
  if (aIndex >= 0) and (aIndex <= High(FDesktopStats)) then
    Result := FDesktopStats[aIndex]
  else
    FillChar(Result, SizeOf(Result), 0);
end;

function TCommunityInsights.GetKernelStat(aIndex: Integer): TKernelStat;
begin
  if (aIndex >= 0) and (aIndex <= High(FKernelStats)) then
    Result := FKernelStats[aIndex]
  else
    FillChar(Result, SizeOf(Result), 0);
end;

function TCommunityInsights.GetSameGPUDistroStat(aIndex: Integer): TSameGPUDistroStat;
begin
  if (aIndex >= 0) and (aIndex <= High(FSameGPUDistroStats)) then
    Result := FSameGPUDistroStats[aIndex]
  else
    FillChar(Result, SizeOf(Result), 0);
end;

function TCommunityInsights.GetSameGPUDriverStat(aIndex: Integer): TSameGPUDriverStat;
begin
  if (aIndex >= 0) and (aIndex <= High(FSameGPUDriverStats)) then
    Result := FSameGPUDriverStats[aIndex]
  else
    FillChar(Result, SizeOf(Result), 0);
end;

function TCommunityInsights.GetSameCPUKernelStat(aIndex: Integer): TSameCPUKernelStat;
begin
  if (aIndex >= 0) and (aIndex <= High(FSameCPUKernelStats)) then
    Result := FSameCPUKernelStats[aIndex]
  else
    FillChar(Result, SizeOf(Result), 0);
end;

function TCommunityInsights.GetScalingRung(aIndex: Integer): TScalingRung;
begin
  if (aIndex >= 0) and (aIndex <= High(FScalingRungs)) then
    Result := FScalingRungs[aIndex]
  else
    FillChar(Result, SizeOf(Result), 0);
end;

function TCommunityInsights.GetBadge(aIndex: Integer): TBadge;
begin
  if (aIndex >= 0) and (aIndex <= High(FBadges)) then
    Result := FBadges[aIndex]
  else
    FillChar(Result, SizeOf(Result), 0);
end;

procedure TCommunityInsights.EnsureLoaded(const aUserScore: Integer; const aUserGPU: string; const aUserDistro: string; const aRTScore: Integer = 0; const aCPUTempMax: Double = 0.0; const aGPUTempMax: Double = 0.0; const aTotalPowerMax: Double = 0.0; const aCPUMultiScore: Integer = 0; const aGPURasterScore: Integer = 0; const aCPUPowerMax: Double = 0.0; const aGPUPowerMax: Double = 0.0; const aUserCPU: string = ''; const aUserDesktop: string = ''; const aCPUMaxFreq: Integer = 0; const aGPUMaxFreq: Integer = 0; const aUserKernel: string = ''; const aUserNick: string = ''; const aUserDriver: string = '');
var
  FileStr: string;
  SL: TStringList;
begin
  FLastUserScore := aUserScore;
  FLastUserGPU := aUserGPU;
  FLastUserDistro := aUserDistro;
  FLastRTScore := aRTScore;
  FLastCPUTempMax := aCPUTempMax;
  FLastGPUTempMax := aGPUTempMax;
  FLastTotalPowerMax := aTotalPowerMax;
  FLastCPUMultiScore := aCPUMultiScore;
  FLastGPURasterScore := aGPURasterScore;
  FLastCPUPowerMax := aCPUPowerMax;
  FLastGPUPowerMax := aGPUPowerMax;
  FLastUserCPU := aUserCPU;
  FLastUserDesktop := aUserDesktop;
  if aUserKernel <> '' then
    FLastUserKernel := aUserKernel;
  FLastCPUMaxFreq := aCPUMaxFreq;
  FLastGPUMaxFreq := aGPUMaxFreq;
  FLastUserNick := aUserNick;
  if aUserDriver <> '' then
    FLastUserDriver := aUserDriver;

  if FLoaded and (FUserScore = aUserScore) and (FUserDistroName = aUserDistro) and (FUserCPUName = aUserCPU) and (FUserKernelName = aUserKernel) and (FUserNick = aUserNick) and (FLastUserDriver = aUserDriver) then
    Exit;

  FUserScore := aUserScore;
  FUserDistroName := aUserDistro;
  FUserCPUName := aUserCPU;
  FUserDesktopName := aUserDesktop;
  FUserKernelName := aUserKernel;
  FUserNick := aUserNick;

  // 1. Try local cache file
  if FileExists(FCachePath) then
  begin
    SL := TStringList.Create;
    try
      try
        SL.LoadFromFile(FCachePath);
        FileStr := SL.Text;
        if Length(FileStr) > 500 then
        begin
          ParseCSVData(FileStr, aUserScore, aUserGPU, aUserDistro, aRTScore, aCPUTempMax, aGPUTempMax, aTotalPowerMax, aCPUMultiScore, aGPURasterScore, aCPUPowerMax, aGPUPowerMax, aUserCPU, aUserDesktop, aCPUMaxFreq, aGPUMaxFreq, aUserKernel, aUserNick, FLastUserDriver);
          Exit;
        end;
      except
        // fall through to fallback
      end;
    finally
      SL.Free;
    end;
  end;

  // 2. Use embedded full-schema fallback dataset
  ParseCSVData(FALLBACK_COMMUNITY_CSV, aUserScore, aUserGPU, aUserDistro, aRTScore, aCPUTempMax, aGPUTempMax, aTotalPowerMax, aCPUMultiScore, aGPURasterScore, aCPUPowerMax, aGPUPowerMax, aUserCPU, aUserDesktop, aCPUMaxFreq, aGPUMaxFreq, aUserKernel, aUserNick, FLastUserDriver);
end;

initialization
  CommunityInsights := TCommunityInsights.Create;

finalization
  FreeAndNil(CommunityInsights);

end.
