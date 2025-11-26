unit constants;

{$mode objfpc}{$H+}

interface

const
  // ============================================================================
  // APPLICATION INFORMATION
  // ============================================================================
  APP_NAME = 'Goverlay';
  APP_AUTHOR = 'Benjamim Gois';

  // ============================================================================
  // GITHUB URLS
  // ============================================================================

  // Goverlay Repository
  URL_GOVERLAY_REPO = 'https://github.com/benjamimgois/goverlay';
  URL_GOVERLAY_API_TAGS = 'https://api.github.com/repos/benjamimgois/goverlay/tags?per_page=3';
  URL_GOVERLAY_RELEASES = 'https://github.com/benjamimgois/goverlay/releases/tag/';

  // MangoHud Repository
  URL_MANGOHUD_REPO = 'https://github.com/flightlessmango/MangoHud';

  // vkBasalt Repository
  URL_VKBASALT_REPO = 'https://github.com/DadSchoorse/vkBasalt';

  // ReplaySorcery Repository
  URL_REPLAYSORCERY_REPO = 'https://github.com/matanui159/ReplaySorcery';

  // ReShade Shaders Repository
  URL_RESHADE_SHADERS_REPO = 'https://github.com/benjamimgois/reshade-shaders.git';
  URL_RESHADE_SHADERS_CROSIRE = 'https://github.com/crosire/reshade-shaders.git';

  // OptiScaler / Decky Framegen
  URL_DECKY_FRAMEGEN_API = 'https://api.github.com/repos/xXJSONDeruloXx/Decky-Framegen/releases/latest';
  URL_DECKY_FRAMEGEN_REPO = 'https://github.com/xXJSONDeruloXx/Decky-Framegen/releases/download/';

  // FakeNvapi
  URL_FAKENVAPI_API = 'https://api.github.com/repos/optiscaler/fakenvapi/releases/latest';
  URL_FAKENVAPI_REPO = 'https://github.com/optiscaler/fakenvapi/releases/download/';

  // ============================================================================
  // SOCIAL MEDIA URLS
  // ============================================================================
  URL_TWITTER = 'https://twitter.com/benjamimgois';
  URL_LINKEDIN = 'https://www.linkedin.com/in/benjamim-gois-37100155/';
  URL_KOFI = 'https://ko-fi.com/benjamimgois';

  // ============================================================================
  // CONFIGURATION FILE NAMES
  // ============================================================================

  // MangoHud
  MANGOHUD_CONFIG_FILE = 'MangoHud.conf';
  MANGOHUD_CUSTOM_FILE = 'custom.conf';
  MANGOHUD_FOLDER_NAME = 'MangoHud';

  // vkBasalt
  VKBASALT_CONFIG_FILE = 'vkBasalt.conf';
  VKBASALT_FOLDER_NAME = 'vkBasalt';

  // Goverlay
  GOVERLAY_FOLDER_NAME = 'goverlay';
  GOVERLAY_BLACKLIST_FILE = 'blacklist.conf';
  GOVERLAY_DISTRO_FILE = 'distro';

  // OptiScaler / fgmod
  FGMOD_FOLDER_NAME = 'fgmod';
  FGMOD_SCRIPT_NAME = 'fgmod';
  OPTISCALER_INI_FILE = 'OptiScaler.ini';
  FAKENVAPI_INI_FILE = 'fakenvapi.ini';
  GOVERLAY_VARS_FILE = 'goverlay.vars';

  // ============================================================================
  // SYSTEM PATHS
  // ============================================================================

  // Font directories
  PATH_SYSTEM_FONTS = '/usr/share/fonts';
  PATH_LOCAL_FONTS = '/usr/local/share/fonts';
  PATH_USER_FONTS = '.local/share/fonts';
  PATH_USER_FONTS_OLD = '.fonts';

  // NixOS paths
  PATH_NIXOS_SYSTEM_FONTS = '/run/current-system/sw/share/fonts';
  PATH_NIXOS_USER_FONTS = '.nix-profile/share/fonts';

  // Flatpak paths
  PATH_FLATPAK_FONTS = '/var/lib/flatpak/exports/share/fonts';
  PATH_FLATPAK_USER_FONTS = '.local/share/flatpak/exports/share/fonts';

  // Icon path
  PATH_GOVERLAY_ICON = '/usr/share/icons/hicolor/128x128/apps/goverlay.png';

  // ============================================================================
  // GPU COLORS (BGR FORMAT)
  // ============================================================================
  COLOR_AMD_RED = $003B00F1;           // AMD Red
  COLOR_NVIDIA_GREEN = $0000B875;      // NVIDIA Green
  COLOR_INTEL_ARC_YELLOW = $00FEC601;  // Intel ARC Yellow

  // ============================================================================
  // RESHADE SHADER FOLDER
  // ============================================================================
  RESHADE_SHADERS_FOLDER = 'reshade-shaders';

implementation

end.
