
# Base devices

These following devices are the base devices that are almost always present in a RISC-V system. They are the minimum set of devices that are 
required to boot a RISC-V system.

| What                  | Where     | Size      | IRQ(s)                    | Description                                                                          |
|-----------------------|-----------|-----------|---------------------------|--------------------------------------------------------------------------------------|
| DS1742                | $00101000 | $8        |                           | Real-time clock                                                                      |
| ACLINT                | $02000000 | $10000    |                           | Core Local Interruptor                                                               |
| PLIC                  | $0c000000 | $208000   |                           | Platform Level Interrupt Controller (if no AIA)                                      |
| APLIC                 | $0cfffffc | $0004     |                           | Advanced Platform Level Interrupt Controller (internal ghost device if AIA)          |
| APLIC-M               | $0c000000 | $4000     |                           | Advanced Platform Level Interrupt Controller for Machine mode (if AIA)               |
| APLIC-S               | $0d000000 | $4000     |                           | Advanced Platform Level Interrupt Controller for Supervisor mode (if AIA)            |
| UART                  | $10000000 | $100      | $0a                       | Universal Asynchronous Receiver/Transmitter                                          | 
| SYSCON                | $11100000 | $1000     |                           | System Controller (Reset, Power off, etc.)                                           |
| IMSIC-M               | $24000000 | #HART<<12 |                           | Interrupt Message Signaled Interrupt Controller (IMSIC) for Machine mode (if AIA)    |
| IMSIC-S               | $28000000 | #HART<<12 |                           | Interrupt Message Signaled Interrupt Controller (IMSIC) for Supervisor mode (if AIA) |

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

These devices are the Inter-Integrated Circuit (I2C) devices that are used to connect to the system.

| What                  | Where     | Size      | IRQ(s)                    | Description                                 |
|-----------------------|-----------|-----------|---------------------------|---------------------------------------------|
| I2C                   | $10020000 | $14       | $0d                       | I2C controller                              |

# VirtIO devices

These devices are the VirtIO devices that are used to connect to the system. They are partly required for the system to boot, but not all of them
are required. The VirtIO devices are used to provide a standard interface for devices for virtual machines.

| What                  | Where     | Size      | IRQ(s)                    | Description                                 |
|-----------------------|-----------|-----------|---------------------------|---------------------------------------------|
| VIRTIO BLOCK          | $10050000 | $1000     | $10                       | VirtIO block device                         |
| VIRTIO INPUT KEYBOARD | $10051000 | $1000     | $11                       | VirtIO keyboard input                       |
| VIRTIO INPUT MOUSE    | $10052000 | $1000     | $12                       | VirtIO mouse input                          |
| VIRTIO INPUT TOUCH    | $10053000 | $1000     | $13                       | VirtIO touch input (planned)                |
| VIRTIO SOUND          | $10054000 | $1000     | $14                       | VirtIO sound device                         |
| VIRTIO 9P             | $10055000 | $1000     | $15                       | VirtIO 9P device                            |
| VIRTIO NET            | $10056000 | $1000     | $16                       | VirtIO network device                       |
| VIRTIO RNG            | $10057000 | $1000     | $17                       | VirtIO random number generator              |
| VIRTIO GPU            | $10058000 | $1000     | $18                       | VirtIO GPU device (planned)                 |

For each VirtIO device, the MMIO region size is $1000. For the VirtIO GPU device, the guest OS allocates its own frame buffer memory ranges, so $1000 as MMIO region size remains valid for the device registers in this case.

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

