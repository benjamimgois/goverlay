#!/bin/sh

# Copy DOOM binary to the root filesystem, but not on the first run, as the root filesystem is not yet created => chicken and egg problem
# So this script must be run more times, once to create the root filesystem, and once to copy the DOOM binary to the root filesystem
if [ -d overlay/games ]; then
  if [ -d buildroot/output/target/games ]; then
    cp -f ../doom/doomgeneric.elf overlay/games/doom
    cp -f ../doom/doomgeneric.elf buildroot/output/target/games/doom
  fi
fi

# Build the kernel including the root filesystem as an initramfs
./build_linux.sh

if [ -d ~/Projects/GitHub/pasvulkan/projects/riscvemu/assets/riscv ]; then

  if [ ! -f buildroot/output/images/Image ]; then
      echo "Kernel build failed"
      exit 1
  fi

  cp -f buildroot/output/images/Image ~/Projects/GitHub/pasvulkan/projects/riscvemu/assets/riscv/kernel.bin

fi 
