@echo off 
call rsvars.bat
msbuild projectmanager.dproj /t:Rebuild /p:Config=Release
