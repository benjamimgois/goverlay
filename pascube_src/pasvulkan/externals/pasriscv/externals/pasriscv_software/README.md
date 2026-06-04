# pasriscv_software

This repository contains third-party software, including test cases, guest Linux system build scripts, and other related assets, for the PasRISCV Emulator — a RV64GC RISC-V emulator developed in Object Pascal.

It is based on the work of https://github.com/bane9/rv64gc-emu-software where he has developed a RISC-V emulator in C++. I'm using his work to a starting point for test cases, guest Linux system build scripts, DOOM, and other software that can be used to test the PasRISCV Emulator.

## Getting Started

In order to build the stuff in this repository, you need to have the dependencies. The following dependencies are required:

```bash
sudo apt install -y git build-essential wget cpio unzip rsync bc libncurses5-dev screen bison file flex 
```

## Building the Guest Linux System

The guest Linux system is built using the buildroot tool. The buildroot tool is a simple, efficient, and easy-to-use tool to generate embedded Linux systems through cross-compilation. The buildroot tool is used to generate the root filesystem for the guest Linux system.

To build the guest Linux system, you need to run the following commands:

```bash
cd linux
./build.sh
```

The build.sh script will download the buildroot tool, configure the buildroot tool, and build the guest Linux system.

## DOOM

DOOM is a first-person shooter video game developed by id Software. The DOOM game is ported to the RISC-V architecture and can be run on the PasRISCV Emulator under the guest Linux system. You do need a valid DOOM WAD file to build and to run the DOOM game. The DOOM WAD file is not included in this repository due to licensing restrictions.

To build DOOM, you need to run the following commands:

```bash
cd doom
make
```

The make command will build the DOOM game.

## RISC-V Test Cases

The RISC-V test cases are used to test the RISC-V emulator. The RISC-V test cases are taken from the RISC-V Compliance Test Suite. The RISC-V Compliance Test Suite is a comprehensive set of tests that verify the correctness of a RISC-V processor implementation. The RISC-V test cases are used to test the PasRISCV Emulator. This repository contains the RISC-V test cases for the RV64GC RISC-V architecture in precompiled form for fast ready-to-use testing. To build the RISC-V test cases yourself, go to the following repository: https://github.com/riscv/riscv-tests and follow the instructions there.

