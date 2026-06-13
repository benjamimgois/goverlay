
# Base devices

These following devices are the base devices that are almost always present in a RISC-V system. They are the minimum set of devices that are 
required to boot a RISC-V system.

| What                  | Where     | Size      | IRQ(s)                    | Description                                                                          |
|-----------------------|-----------|-----------|---------------------------|--------------------------------------------------------------------------------------|
| DS1742                | $00101000 | $8        |                           | Real-time clock                                                                      |
| ACLINT                | $02000000 | $10000    |                           | Core Local Interruptor                                                               |
| IMSIC-M               | $02400000 | #HART<<12 |                           | Interrupt Message Signaled Interrupt Controller (IMSIC) for Machine mode (if AIA)    |
| IMSIC-S               | $02800000 | #HART<<12 |                           | Interrupt Message Signaled Interrupt Controller (IMSIC) for Supervisor mode (if AIA) |
| PLIC                  | $0c000000 | $208000   |                           | Platform Level Interrupt Controller (if no AIA)                                      |
| APLIC                 | $0cfffffc | $0004     |                           | Advanced Platform Level Interrupt Controller (internal ghost device if AIA)          |
| APLIC-M               | $0c000000 | $4000     |                           | Advanced Platform Level Interrupt Controller for Machine mode (if AIA)               |
| APLIC-S               | $0d000000 | $4000     |                           | Advanced Platform Level Interrupt Controller for Supervisor mode (if AIA)            |
| UART                  | $10000000 | $100      | $0a                       | Universal Asynchronous Receiver/Transmitter                                          | 
| SP805 WATCHDOG        | $10030000 | $1000     | $0e                       | ARM SP805 PrimeCell watchdog timer (`arm,sp805`); two-phase reset with IRQ then reboot |
| SYSCON                | $11100000 | $1000     |                           | System Controller (Reset, Power off, etc.)                                           |

# HID devices

These devices are the Human Interface Devices (HID) that are used to interact with the system. 

| What                  | Where     | Size      | IRQ(s)                    | Description                                 |
|-----------------------|-----------|-----------|---------------------------|---------------------------------------------|
| RAW KEYBOARD          | $10008000 | $1000     |                           | Raw keyboard input with scancode bit-array  |
| PS/2 KEYBOARD         | $10010000 | $8        | $05                       | PS/2 keyboard input                         |
| PS/2 MOUSE            | $10011000 | $8        | $06                       | PS/2 mouse input                            |

Once the operating system initializes the VirtIO HID devices, the PS/2 HID devices are no longer fed with input data to avoid duplicating input events.

The raw keyboard device is a simple device that provides a bit array of scancodes. It can be used in conjunction with games specially tweaked for the emulator or other applications that work better with raw scan codes.

# I2C devices

The emulator includes an I2C bus with two selectable controller modes, configurable via `Configuration.I2CMode`. The I2C bus is activated automatically when `RTCMode=DS1307`.

| Mode       | Device                  | Size   | Compatible string          | Linux driver              | Description                                                    |
|------------|-------------------------|--------|----------------------------|---------------------------|----------------------------------------------------------------|
| OpenCores  | TOpenCoresI2CDevice     | $14    | opencores,i2c-ocores       | i2c-ocores                | Classic register-based I2C controller (CLKLO/HI, CTR, TXR/RXR, CR/SR) |
| DesignWare | TDesignWareI2CDevice    | $100   | snps,designware-i2c        | i2c-designware-platform   | Synopsys DesignWare I2C controller with RX/TX FIFOs (16 entries each), interrupt-driven, COMP_TYPE/VERSION/PARAM_1 identification registers. Default mode. |

Both controllers share the same base address ($10020000) and IRQ ($0d).

| What                  | Where     | Size      | IRQ(s)                    | Description                                 |
|-----------------------|-----------|-----------|---------------------------|---------------------------------------------|
| I2C                   | $10020000 | $14/$100  | $0d                       | I2C controller (size depends on mode)       |

# RTC modes

The emulator supports four RTC modes, selectable via `Configuration.RTCMode`:

| Mode       | Device                  | Type       | Linux driver              | Description                                                                                  |
|------------|-------------------------|------------|---------------------------|----------------------------------------------------------------------------------------------|
| Goldfish   | TGoldfishRTCDevice      | MMIO       | goldfish-rtc              | Google Goldfish RTC with interrupt support. Default mode, widely supported by Linux kernels.  |
| DS1742     | TDS1742Device           | MMIO       | rtc-ds1742                | Maxim DS1742 battery-backed timekeeping RAM. Simple polled interface, no IRQ.                 |
| DS1307     | TDS1307Device           | I2C        | rtc-ds1307                | Maxim DS1307 I2C RTC. Requires I2C controller (automatically activated).                     |
| VirtIO     | TVirtIORTCDevice        | VirtIO MMIO| virtio-rtc (staging)      | VirtIO RTC (Device ID 17). Provides UTC, TAI and monotonic clocks with nanosecond precision. |

# VirtIO devices

These devices are the VirtIO devices that are used to connect to the system. They are partly required for the system to boot, but not all of them
are required. The VirtIO devices are used to provide a standard interface for devices for virtual machines.

| What                  | Where     | Size      | IRQ(s)                    | Description                                   |
|-----------------------|-----------|-----------|---------------------------|-----------------------------------------------|
| VIRTIO BLOCK          | $10050000 | $1000     | $10                       | VirtIO block device                           |
| VIRTIO INPUT KEYBOARD | $10051000 | $1000     | $11                       | VirtIO keyboard input                         |
| VIRTIO INPUT MOUSE    | $10052000 | $1000     | $12                       | VirtIO mouse input                            |
| VIRTIO INPUT TOUCH    | $10053000 | $1000     | $13                       | VirtIO touch input (planned)                  |
| VIRTIO SOUND          | $10054000 | $1000     | $14                       | VirtIO sound device                           |
| VIRTIO 9P             | $10055000 | $1000     | $15                       | VirtIO 9P device                              |
| VIRTIO NET            | $10056000 | $1000     | $16                       | VirtIO network device                         |
| VIRTIO RNG            | $10057000 | $1000     | $17                       | VirtIO random number generator                |
| VIRTIO GPU            | $10058000 | $1000     | $18                       | VirtIO GPU device (if DisplayMode=VirtIOGPU)  |
| VIRTIO VSOCK          | $10059000 | $1000     | $19                       | VirtIO socket device                          |
| VIRTIO RTC            | $1005a000 | $1000     | $1a                       | VirtIO RTC device (if RTCMode=VirtIO)         |
| VIRTIO FS             | $1005b000 | $1000     | $1b                       | VirtIO filesystem device                      |
| VIRTIO CRYPTO         | $1005c000 | $1000     | $1c                       | VirtIO crypto device                          |
| VIRTIO BALLOON        | $1005d000 | $1000     | $1d                       | VirtIO balloon device                         |
| VIRTIO INPUT GAMEPAD  | $1005e000 | $1000     | $1e                       | VirtIO gamepad input (evdev: BTN_GAMEPAD + dual sticks/triggers/D-pad) |

For each VirtIO device, the MMIO region size is $1000. For the VirtIO GPU device, the guest OS allocates its own frame buffer memory ranges, so $1000 as MMIO region size remains valid for the device registers in this case.

# Display modes

The emulator supports three display modes, selectable via `Configuration.DisplayMode`:

| Mode       | Device                  | Type       | Linux driver   | Description                                                                                           |
|------------|-------------------------|------------|----------------|-------------------------------------------------------------------------------------------------------|
| SimpleFB   | TSimpleFBDevice         | MMIO       | simplefb       | Custom framebuffer at $28000000, uses a simple memory-mapped interface with control registers. Default mode, suitable for baremetal and simple guest software. |
| VirtIOGPU  | TVirtIOGPUDevice        | VirtIO MMIO| virtio-gpu     | VirtIO GPU (2D only, no 3D/virgl). Guest allocates resources, attaches backing memory, transfers pixel data and flushes to host framebuffer. Supports EDID. |
| BochsVBE   | TBochsVBEDevice         | PCIe       | bochs-drm      | Bochs VBE VGA adapter on PCIe bus (vendor $1234, device $1111). 16MB linear framebuffer (BAR0) with VBE DISPI registers (BAR2) for mode setting. |
| Cirrus     | TCirrusDevice           | PCIe       | cirrus (drm)   | Cirrus Logic GD 5446 VGA adapter on PCIe bus (vendor $1013, device $00b8). 4MB linear framebuffer (BAR0) with VGA register MMIO (BAR2) for mode setting. Subsystem IDs match QEMU ($1af4:$1100) for Linux cirrus-qemu driver compatibility. |

All three modes write their output to the shared `TFrameBufferDevice` pixel buffer, which the host frontend reads for rendering. The frontend code does not need to change between display modes.

# Shared Memory device

The shared memory device provides a simple flat memory-mapped region for zero-copy host-guest communication. It is declared as a `reserved-memory` node in the device tree with `no-map` to prevent the kernel from using it as regular RAM. The device includes a small register area (first 64 bytes) for control and signaling, followed by the data region.

| What                  | Where     | Size      | IRQ(s)                    | Description                                 |
|-----------------------|-----------|-----------|---------------------------|---------------------------------------------|
| SHARED MEMORY         | $2f000000 | $100000   | $1f                       | Shared memory with doorbell IRQ             |

Register layout (offsets from base address):

| Offset | Size    | Access       | Description                                                  |
|--------|---------|--------------|--------------------------------------------------------------|
| $00    | 4 bytes | Guest: Write | Doorbell — writing triggers a callback on the host side      |
| $04    | 4 bytes | Guest: Read  | Host flags — set by the host, readable by the guest          |
| $08    | 4 bytes | Guest: R/W   | Guest flags — set by the guest, readable by the host         |
| $0C    | 4 bytes | Guest: Read  | Data size — size of the shared data region in bytes          |
| $10    | 4 bytes | Guest: Read  | IRQ status — bitmask of pending interrupt reasons            |
| $14    | 4 bytes | Guest: Write | IRQ acknowledge — write bits to clear corresponding IRQ      |
| $40+   | varies  | Guest: R/W   | Shared memory data region                                    |

# PCIe devices

These devices are the Peripheral Component Interconnect Express (PCIe) devices that are used to connect to the system. 

| What                  | Where     | Size      | IRQ(s)                    | Description                                 |
|-----------------------|-----------|-----------|---------------------------|---------------------------------------------|
| PCIe controller base  | $30000000 | $10000000 | $01 - $04 (cross-wired)   | PCIe controller base MMIO                   |
| PCIe I/O              | $03000000 | $00010000 |                           | PCIe I/O                                    |
| PCIe BAR memory range | $40000000 | $40000000 |                           | PCIe BAR memory range                       |

# PCIe bus devices

These devices are the PCIe bus devices that are used to connect to the system.

| Bus  | Device | Function | Class ID | Vendor ID | Device ID | Description                                                 |
|------|--------|----------|----------|-----------|-----------|-------------------------------------------------------------|
| $00  | $00    | $00      | $0600    | $f15e     | $0000     | PCIe controller (host bridge)                               |
| $00  | $01    | $00      | $0108    | $1aad     | $a809     | Non-Volatile Memory Controller (NVMe) / NVMe SSD controller |
| $00  | $03    | $00      | $0300    | $1234     | $1111     | Bochs VBE VGA compatible controller (if DisplayMode=BochsVBE) |
| $00  | $04    | $00      | $0300    | $1013     | $00b8     | Cirrus Logic GD 5446 VGA controller (if DisplayMode=Cirrus)   |

# Boot Trampoline and Device Tree Blob Memory

The memory region for the boot trampoline and the Device Tree Blob (DTB) is a dedicated 64KiB segment starting at $00000000. This memory serves two primary purposes:

1. **Boot Trampoline Code**: The boot trampoline code initializes essential CPU components, including CPU registers and the stack pointer. After initialization, it transfers control to the firmware's entry point. In the future, this code will be removed, and the CPU emulation will directly handle the initialization of registers and the stack pointer.

2. **Device Tree Blob (DTB)**: The DTB provides a structured description of the system's hardware configuration to the operating system. It is passed to the operating system by the firmware and includes details such as CPU cores, memory, and device mappings.

# System Memory

The system memory begins at $80000000 and its size is dynamically determined based on the system configuration. It is the primary memory space and serves multiple purposes:

- **Operating System**: The system memory stores the kernel, essential services, and system libraries required for operation.
- **Applications and Data**: User applications, processes, and associated data are loaded and managed here.
- **Firmware and DTB**: The firmware and a copy of the Device Tree Blob are also stored in system memory, ensuring accessibility during boot and runtime.

This dynamic memory allocation ensures flexibility and scalability, adapting to the needs of different system configurations.

# VirtIO Network Device

The VirtIO network device (`virtio,mmio` at `$10056000`, IRQ `$16`) provides Ethernet connectivity to the guest. Two backends are available, selected via `Configuration.VirtIONetBackend`.

## NAT Userland Backend (default)

The NAT backend (`VirtIONetBackend=NAT`) is a built-in userland NAT stack. The packet parsing and protocol handling (ARP, DHCP, ICMP, UDP, TCP) are purely in-memory and OS-independent. Forwarding to the host network uses OS sockets; currently implemented for Unix (Linux, macOS) via FPC `BaseUnix`. Windows support via WinSock2 is not yet implemented but is architecturally possible. It requires no TAP device, no root access, and no kernel modules. It is enabled by the compile-time flag `{$define PasRISCVEthernetDeviceNAT}` (on by default).

### Guest Network Configuration

| Parameter        | Value           |
|------------------|-----------------|
| Guest IP         | `10.0.2.15`     |
| Subnet mask      | `255.255.255.0` |
| Default gateway  | `10.0.2.2`      |
| DNS server       | `10.0.2.3`      |
| Lease time       | 86400 s         |

The guest MAC address is auto-generated per session. The gateway MAC is `52:54:00:12:34:02`.

### Supported Protocols

| Protocol | Support                                                                                          |
|----------|--------------------------------------------------------------------------------------------------|
| ARP      | Replies to ARP requests for gateway IP `10.0.2.2`                                               |
| DHCP     | Full DISCOVER/OFFER/REQUEST/ACK lease for `10.0.2.15`                                           |
| ICMP     | Echo relay via host ping sockets (`SOCK_DGRAM`/`IPPROTO_ICMP`); no root required on Unix       |
| UDP      | Full NAT with LRU session table (`NATUDPMaxSessions=64`); non-blocking sockets                  |
| TCP      | Full NAT with state machine (`NATTCPMaxSessions=32`); non-blocking connect, pending-send buffer |

### DNS Proxy

UDP packets addressed to `10.0.2.3:53` (the virtual DNS server) are transparently redirected to the first `nameserver` entry from `/etc/resolv.conf` on the host (fallback: `8.8.8.8`). Replies are rewritten to appear to originate from `10.0.2.3`.

## TUN/TAP Backend

The TUN backend (`VirtIONetBackend=TUN`) is available on Unix (Linux/macOS) only and requires root or `CAP_NET_ADMIN`. It opens a host TAP interface (`/dev/net/tun`) and forwards raw Ethernet frames between the guest and the host.

| Configuration key       | Default | Description                              |
|-------------------------|---------|------------------------------------------|
| `VirtIONetBackend`      | `0` (NAT) | `0` = NAT, `1` = TUN                  |
| `VirtIONetTAPInterface` | `tap0`  | Name of the host TAP interface (TUN only) |

The TAP interface must be created and configured on the host before starting the emulator, for example:

```sh
ip tuntap add dev tap0 mode tap
ip addr add 10.0.2.1/24 dev tap0
ip link set tap0 up
```

