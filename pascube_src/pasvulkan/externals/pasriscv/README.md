# PasRISCV

A RISC-V RV64GC emulator written in Object Pascal. It simulates processor cores, memory, I/O, and much more.

## Features

- RV64GC instruction set support with these ISA extensions:  
  - M (Integer Multiplication and Division)  
  - A (Atomic Operations)  
  - F (Single-Precision Floating-Point)  
  - D (Double-Precision Floating-Point)  
  - C (Compressed Instructions)
  - Zicsr (Control and Status Register)
  - Zifencei (Instruction-Fetch Fence)
  - Zicond (Conditional stuff)
  - Zkr (Entropy source)
  - Zicboz (Cache-Block Zero Instructions)
  - Zicbom (Cache-Block Management Instructions)
  - Svadu (Hardware Updating of PTE A/D Bits) 
  - Sstc (RISC-V "stimecmp / vstimecmp" Extension)
  - Svnapot ("NAPOT Translation" Continuity)
  - Zbb/Zcb/Zbs/Zba (Bit Manipulations)
  - Zacas (Atomic Compare-And-Swap)
- Multi-core SMP support
- Emulated peripherals
  - ACLINT
  - PLIC when AIA is not enabled (default), otherwise APLIC and IMSIC if AIA is enabled
  - AIA (Advanced Interrupt Architecture) support with APLIC and IMSIC devices (disabled by default, because not fully tested yet, enable at your own risk)
  - UART NS16550A
  - SysCon   
  - VirtIO MMIO with following devices support
    - Block
    - Network
    - Random/Entropy
    - 9P filesystem
    - Keyboard
    - Mouse
    - Sound
  - Framebuffer support
  - PS/2 keyboard and mouse
  - Raw keyboard input with scancode bit-array (for more direct input per polling) 
  - DS1742 real-time clock (read-only, no write support)
  - PCIe Bus
    - NVMe SSD
  - I2C bus (disabled for now, due to IRQ issues, will be either fixed, removed, or replaced with virtio-i2c later)
    - HID devices
      - Keyboard
- Full MMU support with Sv39, Sv48 and Sv57 page table modes, including support for Svnapot and Svadu extensions
- Disassembler
  - RV64GC instruction set support
  - Supports disassembling code with or without compressed instructions
  - Supports disassembling code with or without floating-point instructions
  - Provides human-readable assembly code output
- Debugger
  - Internal debugger
    - Command line interface
    - Debugger GUI backend API support
    - Breakpoint support
    - Memory and register inspection/modification
    - Step, Continue, Pause execution control
    - Reboot, Reset, PowerOff/Shutdown control
  - GDB remote debugging support (partially implemented)
    - Own GDB server implementation
  - Multiple debugger client support 
    - GDB, internal CLI, custom GUI backends, all simultaneously at the same time
- ELF loader
- Linux kernel boot support
- Untested support for other OS images (FreeBSD, NetBSD, OpenBSD, Haiku, etc.), may require additional fixes or tweaks
- Device Tree Blob (DTB) support
- Initrd support
- Command line support for the guest OS
- Simple test suite with various test cases for different parts of the emulator
- Cross-platform (Windows, Linux, macOS)
- Written in Object Pascal (Free Pascal / Lazarus)

## Why 64-bit only?

The decision to support only 64-bit RISC-V (RV64GC) is primarily driven by the need for a modern architecture that can efficiently handle current and future workloads. 64-bit architectures provide several advantages over their 32-bit counterparts, including:

1. **Larger Address Space**: 64-bit systems can address significantly more memory than 32-bit systems, allowing for more extensive and complex applications.

2. **Improved Performance**: 64-bit processors can handle more data per clock cycle, leading to better performance for compute-intensive tasks.

3. **Future-Proofing**: As software and workloads evolve, the demand for 64-bit processing power will only increase. Supporting 64-bit from the outset ensures that the emulator can accommodate future developments.

4. **Compatibility with Modern Software**: Most modern operating systems and applications are designed with 64-bit architectures in mind, making it essential for the emulator to support this architecture for compatibility reasons.

And support for 32-bit RISC-V is virtually nonexistent outside of source-based distros (Gentoo, Buildroot, Yocto, etc.), strange embedded systems and some hobbyist projects. Most mainstream Linux distributions, other operating systems and software projects have moved to 64-bit as the standard, making it more practical to focus only on 64-bit support. 32-bit support would require additional development and maintenance effort, which may not be justified given the limited use cases and demand for 32-bit RISC-V. So, it is 64-bit only, and it will remain that way. The same applies to 128-bit RISC-V, which is not supported at all, since there is no real-world implementation or use case for it at this time.

## Why Little-Endian only? Why not Big-Endian or Mixed-Endian?

The decision to support only Little-Endian mode in the PasRISCV emulator is based on several practical considerations:

1. **Prevalence of Little-Endian**: Little-Endian is the most commonly used endianness in modern computing systems, including x86 and modern ARM architectures. By focusing on Little-Endian, the emulator aligns with the majority of existing software and hardware, ensuring better compatibility and ease of use. And most all RISC-V systems in the wild are also Little-Endian. And the RISC-V specification itself defaults to Little-Endian, with Big-Endian support being not specified and rarely implemented officially.

2. **Simplicity and Maintainability**: Supporting multiple endianness modes (Little-Endian, Big-Endian, and Mixed-Endian) would significantly increase the complexity of the emulator's design and implementation. This added complexity could lead to more bugs, increased development time, and greater maintenance challenges. By limiting the scope to Little-Endian, the development process becomes more straightforward and manageable.

3. **Target Audience**: The primary users of the PasRISCV emulator are likely to be developers and enthusiasts who are already familiar with Little-Endian systems. By catering to this audience, the emulator can provide a more focused and optimized experience.

4. **Performance Considerations**: Emulating multiple endianness modes could introduce performance overhead due to the need for additional checks and conversions during memory access operations. By standardizing on Little-Endian, the emulator can optimize performance for the most common use cases.

5. **Low Byte-Swapping Costs**: Modern compilers and processors are highly optimized for handling byte-swapping operations when necessary. This means that even if a user needs to work with Big-Endian data, the performance impact of converting between endianness is minimal in most scenarios. PasRISCV supports the Zbb extension, which includes bit manipulation instructions that can facilitate efficient byte-swapping just in a single instruction when needed, for example for network protocols (network byte order) or older file formats that used still Big-Endian.

6. **Big-Endian Is Dead**: There are very few use cases for Big-Endian systems today, and they are mostly limited to legacy systems or specific niche applications. The demand for Big-Endian support is minimal, making it less justifiable to invest resources in its implementation. Big-Endian lives on mostly in some network protocols (network byte order) and some older file formats, but even there, its use is declining as more systems adopt Little-Endian.

7. **Mixed-Endian Complexity**: Mixed-Endian systems, which use different endianness for different data types or structures, are even more complex to implement and maintain. The rarity of Mixed-Endian systems in practical applications further diminishes the need for support in the emulator.

Overall, the decision to support only Little-Endian mode in the PasRISCV emulator is a strategic choice that balances compatibility, simplicity, performance, and user needs. While Big-Endian and Mixed-Endian modes have their use cases, the benefits of focusing on Little-Endian outweigh the potential advantages of supporting multiple endianness modes in this context.

## Usage

See [pasriscvemu](https://github.com/BeRo1985/pasriscvemu) PasVulkan project for an emulator frontend that uses this library.

## Documentation

See the `docs` directory for more information.

## Related connected repositories

- [PasRISCV Third-Party Software Repository](https://github.com/BeRo1985/pasriscv_software) - This repository contains third-party software, including test cases, guest Linux system build scripts, and other related assets, for the PasRISCV Emulator — a RV64GC RISC-V emulator developed in Object Pascal. Needed for the test suite and other related assets.
- [PasVulkan](https://github.com/BeRo1985/pasvulkan) - PasVulkan game engine and Vulkan API bindings for Object Pascal.
- [pasriscemu](https://github.com/BeRo1985/pasriscvemu) - PasRISCV Emulator frontend using PasVulkan.

## License

This project is released under zlib license.
