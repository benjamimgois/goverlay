@echo off
mkdir fpctemp
fpc -Sd -B -FEfpctemp -FUfpctemp -o../../../projectmanager.exe projectmanager.dpr
rmdir /s /q fpctemp

