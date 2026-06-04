#!/bin/bash

set -x

# Linux x86_32
clang -c -target i386-linux -g -gdwarf-2 -masm=intel -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O4 -march=haswell -D linux -fverbose-asm -fno-builtin LzmaDec.c -o lzmadec_linux_x86_32.o
clang -c -target i386-linux -g -gdwarf-2 -masm=intel -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O4 -march=haswell -D linux -fverbose-asm -fno-builtin LzmaDec.c -S -o lzmadec_linux_x86_32.s

# Linux x86_64
clang -c -target x86_64-linux -g -gdwarf-2 -masm=intel -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O4 -march=haswell -D linux -fverbose-asm -fno-builtin LzmaDec.c -o lzmadec_linux_x86_64.o
clang -c -target x86_64-linux -g -gdwarf-2 -masm=intel -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O4 -march=haswell -D linux -fverbose-asm -fno-builtin LzmaDec.c -S -o lzmadec_linux_x86_64.s

# Linux AArch64
clang -c -target aarch64-linux -g -gdwarf-2 -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O4 -D linux -fverbose-asm -fno-builtin LzmaDec.c -o lzmadec_linux_aarch64.o
clang -c -target aarch64-linux -g -gdwarf-2 -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O4 -D linux -fverbose-asm -fno-builtin LzmaDec.c -S -o lzmadec_linux_aarch64.s

# Linux ARM7
clang -c -target armv7-linux -mfloat-abi=hard -g -gdwarf-2 -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O4 -D linux -fverbose-asm -fno-builtin LzmaDec.c -o lzmadec_linux_arm7.o
clang -c -target armv7-linux -mfloat-abi=hard -g -gdwarf-2 -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O4 -D linux -fverbose-asm -fno-builtin LzmaDec.c -S -o lzmadec_linux_arm7.s

# Android x86_64
clang -c -target x86_64-linux-android -g -gdwarf-2 -masm=intel -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O4 -march=haswell -D android -fverbose-asm -fno-builtin LzmaDec.c -o lzmadec_android_x86_64.o
clang -c -target x86_64-linux-android -g -gdwarf-2 -masm=intel -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O4 -march=haswell -D android -fverbose-asm -fno-builtin LzmaDec.c -S -o lzmadec_android_x86_64.s

# Android AArch64
clang -c -target aarch64-linux-android -g -gdwarf-2 -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O4 -D android -fverbose-asm -fno-builtin LzmaDec.c -o lzmadec_android_aarch64.o
clang -c -target aarch64-linux-android -g -gdwarf-2 -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O4 -D android -fverbose-asm -fno-builtin LzmaDec.c -S -o lzmadec_android_aarch64.s

# Windows x86_32
clang -c -target i386-windows -g -gdwarf-2 -masm=intel -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O4 -march=haswell -D windows -fverbose-asm -fno-builtin LzmaDec.c -o lzmadec_windows_x86_32.o
clang -c -target i386-windows -g -gdwarf-2 -masm=intel -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O4 -march=haswell -D windows -fverbose-asm -fno-builtin LzmaDec.c -S -o lzmadec_windows_x86_32.s

# Windows x86_64
clang -c -target x86_64-windows -g -gdwarf-2 -masm=intel -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O4 -march=haswell -D windows -fverbose-asm -fno-builtin LzmaDec.c -o lzmadec_windows_x86_64.o
clang -c -target x86_64-windows -g -gdwarf-2 -masm=intel -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O4 -march=haswell -D windows -fverbose-asm -fno-builtin LzmaDec.c -S -o lzmadec_windows_x86_64.s

# Windows AArch64
clang -c -target aarch64-windows -g -gdwarf-2 -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O4 -D windows -fverbose-asm -fno-builtin LzmaDec.c -o lzmadec_windows_aarch64.o
clang -c -target aarch64-windows -g -gdwarf-2 -Wno-c++2b-extensions -Wno-return-type -Wno-deprecated -O4 -D windows -fverbose-asm -fno-builtin LzmaDec.c -S -o lzmadec_windows_aarch64.s

# No MacOS, because Vulkan doesn't exist natively on MacOS, and MoltenVK is rather an non-optimal solution for this, in my opinion. The same for iOS and other Apple platforms.

# No BSD, because I don't have any BSD system to test it on.




