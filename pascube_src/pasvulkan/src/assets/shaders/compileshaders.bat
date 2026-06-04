@echo off

cd canvas
call compileshaders.bat
cd ..

cd scene3d
call compileshaders.bat
cd ..

echo.
pause