@echo off
if exist .git (
  call initsubmodules.bat
) else (
  call create_externals_symlinks_for_with_svn.bat
)
call compileprojectmanager.bat

