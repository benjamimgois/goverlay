@echo off
set PATH=%USERPROFILE%\AppData\Local\Android\sdk\ndk-bundle\;%PATH%
call ndk-build.cmd NDK_PROJECT_PATH=./ %*
