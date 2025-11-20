unit git2pas;

{
  Pascal bindings for libgit2 - Git operations without external git command
  This unit provides basic git clone and pull functionality for Flatpak compatibility
}

interface

uses
  Classes, SysUtils;

type
  // Callback for progress reporting during git operations
  TGitProgressCallback = procedure(Phase: string; Percent: Integer) of object;

  // Main class for git operations using libgit2
  TGit2Helper = class
  private
    FProgressCallback: TGitProgressCallback;
    FLastPercent: Integer;

    procedure UpdateProgress(const APhase: string; APercent: Integer);
  public
    constructor Create;
    destructor Destroy; override;

    // Clone a repository
    function Clone(const AURL, ADestPath: string): Boolean;

    // Pull (fetch + merge) latest changes
    function Pull(const ARepoPath: string): Boolean;

    // Check if libgit2 is available
    class function IsLibGit2Available: Boolean;

    property OnProgress: TGitProgressCallback read FProgressCallback write FProgressCallback;
  end;

implementation

uses
  DynLibs;

const
  {$IFDEF LINUX}
  LIBGIT2_NAME = 'libgit2.so.1.7';
  LIBGIT2_ALT1 = 'libgit2.so.1.6';
  LIBGIT2_ALT2 = 'libgit2.so.1';
  LIBGIT2_ALT3 = 'libgit2.so';
  {$ENDIF}

type
  // libgit2 types
  Pgit_repository = Pointer;
  Pgit_remote = Pointer;
  git_strarray = record
    strings: PPChar;
    count: SizeInt;
  end;

  git_transfer_progress = record
    total_objects: Cardinal;
    indexed_objects: Cardinal;
    received_objects: Cardinal;
    local_objects: Cardinal;
    total_deltas: Cardinal;
    indexed_deltas: Cardinal;
    received_bytes: SizeInt;
  end;
  Pgit_transfer_progress = ^git_transfer_progress;

  git_indexer_progress = git_transfer_progress;
  Pgit_indexer_progress = ^git_indexer_progress;

  git_checkout_progress_cb = procedure(
    path: PChar;
    completed_steps: SizeInt;
    total_steps: SizeInt;
    payload: Pointer); cdecl;

  git_clone_options = record
    version: Cardinal;
    checkout_opts: Pointer;
    fetch_opts: Pointer;
    bare: Integer;
    local: Integer;
    checkout_branch: PChar;
    repository_cb: Pointer;
    repository_cb_payload: Pointer;
    remote_cb: Pointer;
    remote_cb_payload: Pointer;
  end;
  Pgit_clone_options = ^git_clone_options;

  git_checkout_options = record
    version: Cardinal;
    checkout_strategy: Cardinal;
    disable_filters: Integer;
    dir_mode: Cardinal;
    file_mode: Cardinal;
    file_open_flags: Integer;
    notify_flags: Cardinal;
    notify_cb: Pointer;
    notify_payload: Pointer;
    progress_cb: git_checkout_progress_cb;
    progress_payload: Pointer;
    paths: git_strarray;
    baseline: Pointer;
    baseline_index: Pointer;
    target_directory: PChar;
    ancestor_label: PChar;
    our_label: PChar;
    their_label: PChar;
    perfdata_cb: Pointer;
    perfdata_payload: Pointer;
  end;
  Pgit_checkout_options = ^git_checkout_options;

  git_fetch_options = record
    version: Cardinal;
    callbacks: Pointer;
    prune: Integer;
    update_fetchhead: Integer;
    download_tags: Integer;
    proxy_opts: Pointer;
    custom_headers: git_strarray;
  end;
  Pgit_fetch_options = ^git_fetch_options;

  git_remote_callbacks = record
    version: Cardinal;
    sideband_progress: Pointer;
    completion: Pointer;
    credentials: Pointer;
    certificate_check: Pointer;
    transfer_progress: function(stats: Pgit_transfer_progress; payload: Pointer): Integer; cdecl;
    update_tips: Pointer;
    pack_progress: Pointer;
    push_transfer_progress: Pointer;
    push_update_reference: Pointer;
    push_negotiation: Pointer;
    transport: Pointer;
    payload: Pointer;
    resolve_url: Pointer;
  end;
  Pgit_remote_callbacks = ^git_remote_callbacks;

var
  LibGit2Handle: TLibHandle = NilHandle;

  // libgit2 function pointers
  git_libgit2_init: function: Integer; cdecl = nil;
  git_libgit2_shutdown: function: Integer; cdecl = nil;
  git_clone: function(out repo: Pgit_repository; url: PChar; local_path: PChar; options: Pgit_clone_options): Integer; cdecl = nil;
  git_repository_open: function(out repo: Pgit_repository; path: PChar): Integer; cdecl = nil;
  git_repository_free: procedure(repo: Pgit_repository); cdecl = nil;
  git_remote_lookup: function(out remote: Pgit_remote; repo: Pgit_repository; name: PChar): Integer; cdecl = nil;
  git_remote_fetch: function(remote: Pgit_remote; refspecs: Pointer; opts: Pgit_fetch_options; reflog_message: PChar): Integer; cdecl = nil;
  git_remote_free: procedure(remote: Pgit_remote); cdecl = nil;
  git_clone_options_init: function(opts: Pgit_clone_options; version: Cardinal): Integer; cdecl = nil;
  git_fetch_options_init: function(opts: Pgit_fetch_options; version: Cardinal): Integer; cdecl = nil;
  git_checkout_options_init: function(opts: Pgit_checkout_options; version: Cardinal): Integer; cdecl = nil;
  git_repository_head: function(out reference: Pointer; repo: Pgit_repository): Integer; cdecl = nil;
  git_reference_free: procedure(ref: Pointer); cdecl = nil;
  git_reset_from_annotated: function(repo: Pgit_repository; commit: Pointer; reset_type: Integer; checkout_opts: Pgit_checkout_options): Integer; cdecl = nil;
  git_annotated_commit_from_fetchhead: function(out commit: Pointer; repo: Pgit_repository; branch_name: PChar; remote_url: PChar; oid: Pointer): Integer; cdecl = nil;
  git_annotated_commit_free: procedure(commit: Pointer); cdecl = nil;
  git_merge: function(repo: Pgit_repository; their_heads: Pointer; their_heads_len: SizeInt; merge_opts: Pointer; checkout_opts: Pgit_checkout_options): Integer; cdecl = nil;

const
  GIT_CLONE_OPTIONS_VERSION = 1;
  GIT_FETCH_OPTIONS_VERSION = 1;
  GIT_CHECKOUT_OPTIONS_VERSION = 1;
  GIT_REMOTE_CALLBACKS_VERSION = 1;
  GIT_CHECKOUT_SAFE = 1 shl 0;

var
  GlobalProgressHelper: TGit2Helper = nil;

// Callback function for clone/fetch progress
function TransferProgressCallback(stats: Pgit_transfer_progress; payload: Pointer): Integer; cdecl;
var
  Percent: Integer;
begin
  Result := 0;

  if not Assigned(GlobalProgressHelper) then Exit;
  if not Assigned(stats) then Exit;

  try
    // Calculate percentage based on received objects
    if stats^.total_objects > 0 then
    begin
      Percent := Round((stats^.received_objects / stats^.total_objects) * 100);
      GlobalProgressHelper.UpdateProgress('Receiving objects', Percent);
    end;
  except
    // Ignore errors in callback
  end;
end;

// Callback for checkout progress
procedure CheckoutProgressCallback(path: PChar; completed_steps: SizeInt; total_steps: SizeInt; payload: Pointer); cdecl;
var
  Percent: Integer;
begin
  if not Assigned(GlobalProgressHelper) then Exit;

  try
    if total_steps > 0 then
    begin
      Percent := Round((completed_steps / total_steps) * 100);
      GlobalProgressHelper.UpdateProgress('Checking out files', Percent);
    end;
  except
    // Ignore errors in callback
  end;
end;

function LoadLibGit2: Boolean;
var
  LibName: string;
begin
  Result := False;

  if LibGit2Handle <> NilHandle then
  begin
    Result := True;
    Exit;
  end;

  // Try different library names
  {$IFDEF LINUX}
  LibGit2Handle := LoadLibrary(LIBGIT2_NAME);
  if LibGit2Handle = NilHandle then
    LibGit2Handle := LoadLibrary(LIBGIT2_ALT1);
  if LibGit2Handle = NilHandle then
    LibGit2Handle := LoadLibrary(LIBGIT2_ALT2);
  if LibGit2Handle = NilHandle then
    LibGit2Handle := LoadLibrary(LIBGIT2_ALT3);
  {$ENDIF}

  if LibGit2Handle = NilHandle then
    Exit;

  // Load function pointers
  Pointer(git_libgit2_init) := GetProcAddress(LibGit2Handle, 'git_libgit2_init');
  Pointer(git_libgit2_shutdown) := GetProcAddress(LibGit2Handle, 'git_libgit2_shutdown');
  Pointer(git_clone) := GetProcAddress(LibGit2Handle, 'git_clone');
  Pointer(git_repository_open) := GetProcAddress(LibGit2Handle, 'git_repository_open');
  Pointer(git_repository_free) := GetProcAddress(LibGit2Handle, 'git_repository_free');
  Pointer(git_remote_lookup) := GetProcAddress(LibGit2Handle, 'git_remote_lookup');
  Pointer(git_remote_fetch) := GetProcAddress(LibGit2Handle, 'git_remote_fetch');
  Pointer(git_remote_free) := GetProcAddress(LibGit2Handle, 'git_remote_free');
  Pointer(git_clone_options_init) := GetProcAddress(LibGit2Handle, 'git_clone_options_init');
  Pointer(git_fetch_options_init) := GetProcAddress(LibGit2Handle, 'git_fetch_options_init');
  Pointer(git_checkout_options_init) := GetProcAddress(LibGit2Handle, 'git_checkout_options_init');
  Pointer(git_repository_head) := GetProcAddress(LibGit2Handle, 'git_repository_head');
  Pointer(git_reference_free) := GetProcAddress(LibGit2Handle, 'git_reference_free');
  Pointer(git_reset_from_annotated) := GetProcAddress(LibGit2Handle, 'git_reset_from_annotated');
  Pointer(git_annotated_commit_from_fetchhead) := GetProcAddress(LibGit2Handle, 'git_annotated_commit_from_fetchhead');
  Pointer(git_annotated_commit_free) := GetProcAddress(LibGit2Handle, 'git_annotated_commit_free');
  Pointer(git_merge) := GetProcAddress(LibGit2Handle, 'git_merge');

  Result := Assigned(git_libgit2_init) and
            Assigned(git_clone) and
            Assigned(git_repository_open);

  if Result then
    git_libgit2_init();
end;

procedure UnloadLibGit2;
begin
  if LibGit2Handle <> NilHandle then
  begin
    if Assigned(git_libgit2_shutdown) then
      git_libgit2_shutdown();
    FreeLibrary(LibGit2Handle);
    LibGit2Handle := NilHandle;
  end;
end;

{ TGit2Helper }

constructor TGit2Helper.Create;
begin
  inherited Create;
  FLastPercent := -1;

  if not LoadLibGit2 then
    raise Exception.Create('Failed to load libgit2. Make sure libgit2 is installed on your system.');

  // Test if libgit2 is actually functional
  try
    if Assigned(git_libgit2_init) then
      git_libgit2_init();
  except
    raise Exception.Create('libgit2 library loaded but initialization failed.');
  end;
end;

destructor TGit2Helper.Destroy;
begin
  inherited Destroy;
end;

procedure TGit2Helper.UpdateProgress(const APhase: string; APercent: Integer);
begin
  // Avoid duplicate updates
  if (APercent = FLastPercent) and (APercent < 100) then
    Exit;

  FLastPercent := APercent;

  if Assigned(FProgressCallback) then
    FProgressCallback(APhase, APercent);
end;

function TGit2Helper.Clone(const AURL, ADestPath: string): Boolean;
var
  Repo: Pgit_repository;
  RetCode: Integer;
begin
  Result := False;

  if not LoadLibGit2 then
    Exit;

  try
    GlobalProgressHelper := Self;

    UpdateProgress('Starting clone', 0);

    // Perform simple clone without complex options
    // Use nil for options to use defaults
    RetCode := git_clone(Repo, PChar(AURL), PChar(ADestPath), nil);

    if RetCode = 0 then
    begin
      UpdateProgress('Completed', 100);
      if Assigned(git_repository_free) then
        git_repository_free(Repo);
      Result := True;
    end
    else
    begin
      UpdateProgress('Clone failed', 0);
    end;

  finally
    GlobalProgressHelper := nil;
  end;
end;

function TGit2Helper.Pull(const ARepoPath: string): Boolean;
var
  Repo: Pgit_repository;
  Remote: Pgit_remote;
  RetCode: Integer;
begin
  Result := False;

  if not LoadLibGit2 then
    Exit;

  try
    GlobalProgressHelper := Self;

    // Open repository
    RetCode := git_repository_open(Repo, PChar(ARepoPath));
    if RetCode <> 0 then
      Exit;

    try
      // Lookup origin remote
      RetCode := git_remote_lookup(Remote, Repo, 'origin');
      if RetCode <> 0 then
        Exit;

      try
        UpdateProgress('Fetching', 0);

        // Fetch from remote with default options
        RetCode := git_remote_fetch(Remote, nil, nil, nil);

        if RetCode = 0 then
        begin
          UpdateProgress('Completed', 100);
          Result := True;
        end
        else
        begin
          UpdateProgress('Fetch failed', 0);
        end;

      finally
        if Assigned(git_remote_free) then
          git_remote_free(Remote);
      end;

    finally
      if Assigned(git_repository_free) then
        git_repository_free(Repo);
    end;

  finally
    GlobalProgressHelper := nil;
  end;
end;

class function TGit2Helper.IsLibGit2Available: Boolean;
begin
  Result := LoadLibGit2;
end;

initialization

finalization
  UnloadLibGit2;

end.
