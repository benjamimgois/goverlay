@echo off

cd textoverlay
call compileshaders.bat
cd ..

cd triangle
call compileshaders.bat
cd ..

cd cube
call compileshaders.bat
cd ..

cd dragon
call compileshaders.bat
cd ..

rem echo.
rem pause
