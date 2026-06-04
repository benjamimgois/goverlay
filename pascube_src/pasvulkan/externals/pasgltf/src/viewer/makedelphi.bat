@echo off
call rsvars.bat
msbuild PASGLTFViewer.dproj /t:Rebuild /p:Config=Release;Platform=Win64
