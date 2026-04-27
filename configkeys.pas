unit configkeys;

{$mode objfpc}{$H+}

interface

// ============================================================================
// TWEAKS / PROTON ENVIRONMENT VARIABLES
// ============================================================================

const
  // General tweaks
  ENV_STEAMDECK                = 'SteamDeck=1';
  ENV_PROTON_ENABLE_HDR        = 'PROTON_ENABLE_HDR=1';
  ENV_ENABLE_HDR_WSI           = 'ENABLE_HDR_WSI=1';
  ENV_PROTON_ENABLE_WAYLAND    = 'PROTON_ENABLE_WAYLAND=1';
  ENV_PROTON_LOG               = 'PROTON_LOG=1';
  ENV_PROTON_USE_SDL           = 'PROTON_USE_SDL=1';
  ENV_GAMEMODERUN              = '-- env gamemoderun';

  // Graphics tweaks
  ENV_RADV_PERFTEST_RT         = 'RADV_PERFTEST=rt,emulate_rt';
  ENV_PROTON_HIDE_NVIDIA_GPU   = 'PROTON_HIDE_NVIDIA_GPU=1';
  ENV_PROTON_ENABLE_NVAPI      = 'PROTON_ENABLE_NVAPI=1';
  ENV_PROTON_USE_WINED3D       = 'PROTON_USE_WINED3D=1';
  ENV_MESA_LOADER_OVERRIDE     = 'MESA_LOADER_DRIVER_OVERRIDE=zink';
  ENV_GLX_VENDOR_MESA          = '__GLX_VENDOR_LIBRARY_NAME=mesa';
  ENV_RADV_DEBUG_NOFASTCLEARS  = 'RADV_DEBUG=nofastclears';

  // Upgrade tweaks
  ENV_PROTON_FSR4_UPGRADE      = 'PROTON_FSR4_UPGRADE=1';
  ENV_PROTON_DLSS_UPGRADE      = 'PROTON_DLSS_UPGRADE=1';
  ENV_PROTON_XESS_UPGRADE      = 'PROTON_XESS_UPGRADE=1';

  // Performance tweaks
  ENV_PROTON_PRIORITY_HIGH     = 'PROTON_PRIORITY_HIGH=1';
  ENV_PROTON_USE_WOW64         = 'PROTON_USE_WOW64=1';
  ENV_PROTON_FORCE_LARGE_ADDR  = 'PROTON_FORCE_LARGE_ADDRESS_AWARE=1';
  ENV_STAGING_SHARED_MEMORY    = 'STAGING_SHARED_MEMORY=1';
  ENV_PROTON_NO_NTSYNC         = 'PROTON_NO_NTSYNC=1';
  ENV_PROTON_HEAP_DELAY_FREE   = 'PROTON_HEAP_DELAY_FREE=1';
  ENV_ENABLE_MESA_ANTILAG      = 'ENABLE_LAYER_MESA_ANTI_LAG=1';

// ============================================================================
// FGMOD SCRIPT ANCHORS AND MARKERS
// ============================================================================

const
  FGMOD_ANCHOR_EXEC            = '# Execute the original command';
  FGMOD_MARKER_GAMEMODE        = '#gamemode';
  FGMOD_MARKER_CUSTOMENV       = '#customenv';
  FGMOD_MARKER_WINE_DETECTION  = '#winedetectionenable=false';
  LAUNCH_SUFFIX_WINE_DETECTION = ' /WineDetectionEnabled:False';
  FGMOD_PREFIX_EXPORT          = 'export ';
  FGMOD_PREFIX_EXPORT_SDL      = '  export PROTON_USE_SDL=1';
  FGMOD_PREFIX_EXPORT_LOG      = '  export PROTON_LOG=1';
  FGMOD_PREFIX_EXPORT_WAYLAND  = '  export PROTON_ENABLE_WAYLAND=1';
  FGMOD_PREFIX_EXPORT_HDR      = '  export PROTON_ENABLE_HDR=1';
  FGMOD_PREFIX_EXPORT_HDR_WSI  = '  export ENABLE_HDR_WSI=1';
  FGMOD_PREFIX_EXPORT_WINED3D  = '  export PROTON_USE_WINED3D=1';
  FGMOD_PREFIX_EXPORT_NVAPI    = '  export PROTON_ENABLE_NVAPI=1';
  FGMOD_PREFIX_EXPORT_HIDE_NV  = '  export PROTON_HIDE_NVIDIA_GPU=1';
  FGMOD_PREFIX_EXPORT_RADV_RT  = '  export RADV_PERFTEST=rt,emulate_rt';
  FGMOD_PREFIX_EXPORT_NOFAST   = '  export RADV_DEBUG=nofastclears';
  FGMOD_PREFIX_EXPORT_ZINK     = '  export MESA_LOADER_DRIVER_OVERRIDE=zink';
  FGMOD_PREFIX_EXPORT_GLX      = '  export __GLX_VENDOR_LIBRARY_NAME=mesa';
  FGMOD_PREFIX_EXPORT_ANTILAG  = '  export ENABLE_LAYER_MESA_ANTI_LAG=1';
  FGMOD_PREFIX_EXPORT_HEAP     = '  export PROTON_HEAP_DELAY_FREE=1';
  FGMOD_PREFIX_EXPORT_XESS     = '  export PROTON_XESS_UPGRADE=1';
  FGMOD_PREFIX_EXPORT_DLSS     = '  export PROTON_DLSS_UPGRADE=1';
  FGMOD_PREFIX_EXPORT_FSR      = '  export PROTON_FSR4_UPGRADE=1';
  FGMOD_PREFIX_EXPORT_NTSYNC   = '  export PROTON_NO_NTSYNC=1';
  FGMOD_PREFIX_EXPORT_SHMEM    = '  export STAGING_SHARED_MEMORY=1';
  FGMOD_PREFIX_EXPORT_LARGE    = '  export PROTON_FORCE_LARGE_ADDRESS_AWARE=1';
  FGMOD_PREFIX_EXPORT_WOW64    = '  export PROTON_USE_WOW64=1';
  FGMOD_PREFIX_EXPORT_PRIORITY = '  export PROTON_PRIORITY_HIGH=1';
  FGMOD_PREFIX_STEAMDECK       = '  export SteamDeck=';
  FGMOD_PREFIX_CUSTOMENV       = '  export ';

  LAUNCH_COMMAND_SUFFIX        = '%command%';

// ============================================================================
// OPTISCALER CONFIG KEYS
// ============================================================================

const
  OPTI_DLL_NAME_ANCHOR         = 'dll_name="${DLL:-';
  OPTI_WINEOVERRIDES_PREFIX    = 'export WINEDLLOVERRIDES="$WINEDLLOVERRIDES,';
  OPTI_WINEOVERRIDES_SUFFIX    = '=n,b"';
  OPTI_EMUFP8_LINE             = 'export DXIL_SPIRV_CONFIG="wmma_rdna3_workaround"';

  OPTI_DLL_DXGI                = 'dxgi.dll';
  OPTI_DLL_VERSION             = 'version.dll';
  OPTI_DLL_DBGHELP             = 'dbghelp.dll';
  OPTI_DLL_D3D12               = 'd3d12.dll';
  OPTI_DLL_WININET             = 'wininet.dll';
  OPTI_DLL_WINHTTP             = 'winhttp.dll';
  OPTI_DLL_WINMM               = 'winmm.dll';
  OPTI_DLL_ASI                 = 'OptiScaler.asi';

  OPTI_INI_SECTION_MENU        = '[Menu]';
  OPTI_KEY_SHORTCUT            = 'ShortcutKey=';
  OPTI_KEY_SCALE               = 'Scale=';
  OPTI_KEY_OVERRIDE_NVAPI      = 'OverrideNvapiDll=';
  OPTI_KEY_DXGI                = 'Dxgi=';
  OPTI_KEY_LOAD_ASI            = 'LoadAsiPlugins=';
  OPTI_KEY_FSR4_UPDATE         = 'Fsr4Update=';

  FAKE_KEY_FORCE_REFLEX        = 'force_reflex=';
  FAKE_KEY_FORCE_LATENCY       = 'force_latencyflex=';
  FAKE_KEY_LATENCY_MODE        = 'latencyflex_mode=';
  FAKE_KEY_TRACE_LOGS          = 'enable_trace_logs=';

// ============================================================================
// MANGOHUD CONFIG KEYS (complement to constants.pas)
// ============================================================================

const
  MANGO_KEY_CUSTOM_TEXT        = 'custom_text_center';
  MANGO_KEY_BG_ALPHA           = 'background_alpha';
  MANGO_KEY_ROUND_CORNERS      = 'round_corners';
  MANGO_KEY_BG_COLOR           = 'background_color';
  MANGO_KEY_FONT_SIZE          = 'font_size';
  MANGO_KEY_TEXT_COLOR         = 'text_color';
  MANGO_KEY_FONT_FILE          = 'font_file';
  MANGO_KEY_POSITION           = 'position';
  MANGO_KEY_OFFSET_X           = 'offset_x';
  MANGO_KEY_OFFSET_Y           = 'offset_y';
  MANGO_KEY_TOGGLE_HUD         = 'toggle_hud';
  MANGO_KEY_TABLE_COLS         = 'table_columns';
  MANGO_KEY_GPU_TEXT           = 'gpu_text';
  MANGO_KEY_GPU_COLOR          = 'gpu_color';
  MANGO_KEY_CPU_TEXT           = 'cpu_text';
  MANGO_KEY_CPU_COLOR          = 'cpu_color';
  MANGO_KEY_VRAM_COLOR         = 'vram_color';
  MANGO_KEY_RAM_COLOR          = 'ram_color';
  MANGO_KEY_IO_COLOR           = 'io_color';
  MANGO_KEY_FRAMETIME_COLOR    = 'frametime_color';
  MANGO_KEY_FPS_LIMIT_METHOD   = 'fps_limit_method';
  MANGO_KEY_TOGGLE_FPS_LIMIT   = 'toggle_fps_limit';
  MANGO_KEY_VSYNC              = 'vsync';
  MANGO_KEY_GL_VSYNC           = 'gl_vsync';
  MANGO_KEY_AF                 = 'af';
  MANGO_KEY_PICMIP             = 'picmip';
  MANGO_KEY_FPS_LIMIT          = 'fps_limit';
  MANGO_KEY_FPS_COLOR          = 'fps_color';
  MANGO_KEY_WINE_COLOR         = 'wine_color';
  MANGO_KEY_ENGINE_COLOR       = 'engine_color';
  MANGO_KEY_BATTERY_COLOR      = 'battery_color';
  MANGO_KEY_MEDIA_COLOR        = 'media_player_color';
  MANGO_KEY_DEVICE_BATTERY     = 'device_battery';
  MANGO_KEY_OUTPUT_FOLDER      = 'output_folder';
  MANGO_KEY_LOG_DURATION       = 'log_duration';
  MANGO_KEY_AUTOSTART_LOG      = 'autostart_log';
  MANGO_KEY_LOG_INTERVAL       = 'log_interval';
  MANGO_KEY_TOGGLE_LOGGING     = 'toggle_logging';
  MANGO_KEY_FPS_METRICS        = 'fps_metrics';
  MANGO_KEY_NETWORK            = 'network';
  MANGO_KEY_EXEC               = 'exec';
  MANGO_KEY_GPU_LIST           = 'gpu_list';
  MANGO_KEY_PCI_DEV            = 'pci_dev';

  // Boolean flags
  MANGO_FLAG_HORIZONTAL        = 'horizontal';
  MANGO_FLAG_NO_DISPLAY        = 'no_display';
  MANGO_FLAG_HUD_COMPACT       = 'hud_compact';
  MANGO_FLAG_FPS               = 'fps';
  MANGO_FLAG_FRAME_TIMING      = 'frame_timing';
  MANGO_FLAG_SHOW_FPS_LIMIT    = 'show_fps_limit';
  MANGO_FLAG_FRAME_COUNT       = 'frame_count';
  MANGO_FLAG_HISTOGRAM         = 'histogram';
  MANGO_FLAG_GPU_STATS         = 'gpu_stats';
  MANGO_FLAG_GPU_LOAD_CHANGE   = 'gpu_load_change';
  MANGO_FLAG_VRAM              = 'vram';
  MANGO_FLAG_GPU_CORE_CLOCK    = 'gpu_core_clock';
  MANGO_FLAG_GPU_MEM_CLOCK     = 'gpu_mem_clock';
  MANGO_FLAG_GPU_TEMP          = 'gpu_temp';
  MANGO_FLAG_GPU_MEM_TEMP      = 'gpu_mem_temp';
  MANGO_FLAG_GPU_JUNCTION_TEMP = 'gpu_junction_temp';
  MANGO_FLAG_GPU_FAN           = 'gpu_fan';
  MANGO_FLAG_GPU_POWER         = 'gpu_power';
  MANGO_FLAG_GPU_POWER_LIMIT   = 'gpu_power_limit';
  MANGO_FLAG_GPU_EFFICIENCY    = 'gpu_efficiency';
  MANGO_FLAG_FLIP_EFFICIENCY   = 'flip_efficiency';
  MANGO_FLAG_GPU_VOLTAGE       = 'gpu_voltage';
  MANGO_FLAG_THROTTLING        = 'throttling_status';
  MANGO_FLAG_THROTTLING_GRAPH  = 'throttling_status_graph';
  MANGO_FLAG_GPU_NAME          = 'gpu_name';
  MANGO_FLAG_VULKAN_DRIVER     = 'vulkan_driver';
  MANGO_FLAG_CPU_STATS         = 'cpu_stats';
  MANGO_FLAG_CPU_LOAD_CHANGE   = 'cpu_load_change';
  MANGO_FLAG_CORE_LOAD         = 'core_load';
  MANGO_FLAG_CORE_BARS         = 'core_bars';
  MANGO_FLAG_CPU_MHZ           = 'cpu_mhz';
  MANGO_FLAG_CPU_TEMP          = 'cpu_temp';
  MANGO_FLAG_CPU_POWER         = 'cpu_power';
  MANGO_FLAG_CPU_EFFICIENCY    = 'cpu_efficiency';
  MANGO_FLAG_CORE_TYPE         = 'core_type';
  MANGO_FLAG_RAM               = 'ram';
  MANGO_FLAG_IO_READ           = 'io_read';
  MANGO_FLAG_IO_WRITE          = 'io_write';
  MANGO_FLAG_PROCMEM           = 'procmem';
  MANGO_FLAG_PROC_VRAM         = 'proc_vram';
  MANGO_FLAG_SWAP              = 'swap';
  MANGO_FLAG_RAM_TEMP          = 'ram_temp';
  MANGO_FLAG_ARCH              = 'arch';
  MANGO_FLAG_RESOLUTION        = 'resolution';
  MANGO_FLAG_WINE              = 'wine';
  MANGO_FLAG_ENGINE_VERSION    = 'engine_version';
  MANGO_FLAG_ENGINE_SHORT      = 'engine_short_names';
  MANGO_FLAG_GAMEMODE          = 'gamemode';
  MANGO_FLAG_VKBASALT          = 'vkbasalt';
  MANGO_FLAG_FCAT              = 'fcat';
  MANGO_FLAG_FEX_STATS         = 'fex_stats';
  MANGO_FLAG_FSR               = 'fsr';
  MANGO_FLAG_HDR               = 'hdr';
  MANGO_FLAG_REFRESH_RATE      = 'refresh_rate';
  MANGO_FLAG_BATTERY           = 'battery';
  MANGO_FLAG_BATTERY_WATT      = 'battery_watt';
  MANGO_FLAG_BATTERY_TIME      = 'battery_time';
  MANGO_FLAG_MEDIA_PLAYER      = 'media_player';
  MANGO_FLAG_TEMP_FAHRENHEIT   = 'temp_fahrenheit';
  MANGO_FLAG_WINESYNC          = 'winesync';
  MANGO_FLAG_PRESENT_MODE      = 'present_mode';
  MANGO_FLAG_LOG_VERSIONING    = 'log_versioning';
  MANGO_FLAG_UPLOAD_LOGS       = 'upload_logs';
  MANGO_FLAG_FPS_COLOR_CHANGE  = 'fps_color_change';
  MANGO_FLAG_BICUBIC           = 'bicubic';
  MANGO_FLAG_TRILINEAR         = 'trilinear';
  MANGO_FLAG_RETRO             = 'retro';
  MANGO_FLAG_DISPLAY_SERVER    = 'display_server';
  MANGO_FLAG_TIME              = 'time';
  MANGO_FLAG_VERSION           = 'version';

  // Position values
  MANGO_POS_TOP_LEFT           = 'top-left';
  MANGO_POS_TOP_CENTER         = 'top-center';
  MANGO_POS_TOP_RIGHT          = 'top-right';
  MANGO_POS_MIDDLE_LEFT        = 'middle-left';
  MANGO_POS_MIDDLE_RIGHT       = 'middle-right';
  MANGO_POS_BOTTOM_LEFT        = 'bottom-left';
  MANGO_POS_BOTTOM_CENTER      = 'bottom-center';
  MANGO_POS_BOTTOM_RIGHT       = 'bottom-right';

  // FPS limit method values
  MANGO_FPS_LATE               = 'late';
  MANGO_FPS_EARLY              = 'early';

  // GL VSync values
  MANGO_GL_VSYNC_MINUS1        = '-1';
  MANGO_GL_VSYNC_0             = '0';
  MANGO_GL_VSYNC_1             = '1';
  MANGO_GL_VSYNC_N             = 'n';

  // FPS metrics values
  MANGO_FPS_METRICS_1PCT       = '0.01';
  MANGO_FPS_METRICS_01PCT      = '0.001';

  // Special comment markers
  MANGO_COMMENT_OFFSET         = '#offset=';

implementation

end.
