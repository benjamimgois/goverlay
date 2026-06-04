@echo off
d:
chdir d:\cygwin\bin
bash --login -i "/cygdrive/d/DropBox/Dropbox/- JOY-INN Share -/- CURRENT PROJECTS -/REVISION RELEASE - SCENEMON/CODE/src/androidthirdlibs/libtremor/doit.sh"
d:
cd "d:\DropBox\Dropbox\- JOY-INN Share -\- CURRENT PROJECTS -\REVISION RELEASE - SCENEMON\CODE\src\androidthirdlibs\libtremor\"
del /f ..\libtremor.a 
copy obj\local\armeabi\libtremor.a ..\libtremor.a 