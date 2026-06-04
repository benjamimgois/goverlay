@echo off
rem Compile here your asset files and move the compiled files then to ..\..\assets\ 
cd shaders
call compileshaders.bat
cd ..
tools\dae2mdl\dae2mdl.exe models\dragon.dae ..\..\assets\models\dragon.mdl
