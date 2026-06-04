@echo off

fpc -O3 -g -FUunits -Twin32 -Pi386 -o..\bin\libFLRE_i386.dll -B libFLRE.dpr || goto :error
fpc -O3 -g -FUunits -Twin64 -Px86_64 -o..\bin\libFLRE_x86_64.dll -B libFLRE.dpr || goto :error

fpc -O3 -g -FUunits -Tandroid -Pi386 -o..\bin\libFLRE_android_i386.so -B libFLRE.dpr || goto :error
fpc -O3 -g -FUunits -Tandroid -Px86_64 -o..\bin\libFLRE_android_x86_64.so -B libFLRE.dpr || goto :error
fpc -O3 -g -FUunits -Tandroid -Parm -o..\bin\libFLRE_android_arm.so -B libFLRE.dpr || goto :error
fpc -O3 -g -FUunits -Tandroid -Paarch64 -o..\bin\libFLRE_android_aarch64.so -B libFLRE.dpr || goto :error

fpc -O3 -g -FUunits -Tlinux -Pi386 -o..\bin\libFLRE_linux_i386.so -B libFLRE.dpr || goto :error
fpc -O3 -g -FUunits -Tlinux -Px86_64 -o..\bin\libFLRE_linux_x86_64.so -B libFLRE.dpr || goto :error
fpc -O3 -g -FUunits -Tlinux -Parm -CaEABIHF -fPIC -o..\bin\libFLRE_linux_arm.so -B libFLRE.dpr || goto :error
fpc -O3 -g -FUunits -Tlinux -Paarch64 -o..\bin\libFLRE_linux_aarch64.so -B libFLRE.dpr || goto :error

fpc -O3 -g -FUunits -Tfreebsd -Pi386 -o..\bin\libFLRE_freebsd_i386.so -B libFLRE.dpr || goto :error
fpc -O3 -g -FUunits -Tfreebsd -Px86_64 -o..\bin\libFLRE_freebsd_x86_64.so -B libFLRE.dpr || goto :error

fpc -O3 -g -FUunits -Tdarwin -Pi386 -o..\bin\libFLRE_darwin_i386.dylib -B libFLRE.dpr || goto :error
fpc -O3 -g -FUunits -Tdarwin -Px86_64 -o..\bin\libFLRE_darwin_x86_64.dylib -B libFLRE.dpr || goto :error
fpc -O3 -g -FUunits -Tdarwin -Paarch64 -o..\bin\libFLRE_darwin_aarch64.dylib -B libFLRE.dpr || goto :error

rem fpc -O3 -g -FUunits -TiOS -Parm -fPIC -o..\bin\libFLRE_ios_arm.dylib -B libFLRE.dpr || goto :error
rem fpc -O3 -g -FUunits -TiOS -Parm -fPIC -o..\bin\libFLRE_ios_aarch64.dylib -B libFLRE.dpr || goto :error

goto :noerror

:error
exit /b %errorlevel%

:noerror
exit /b 0

