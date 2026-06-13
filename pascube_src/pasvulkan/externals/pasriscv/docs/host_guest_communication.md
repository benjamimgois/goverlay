# Host-Guest Communication

PasRISCV provides three different mechanisms for host-guest communication, each with its own trade-offs regarding complexity, performance, guest driver requirements, and use cases.

## Overview

| Property | IVSHMEM (PCIe) | VirtIO Socket (vsock) | Shared Memory (Simple Bus) |
|---|---|---|---|
| **Bus** | PCIe (BAR-based) | VirtIO MMIO | Direct flat MMIO |
| **Base Address** | PCIe BAR auto-assigned | `$10059000` | `$2F000000` |
| **Register Size** | 256 bytes (BAR0) | 4 KB (VirtIO MMIO) | 64 bytes |
| **Data Size** | Configurable (default 1 MB, BAR2) | N/A (virtqueue-based) | ~1 MB (`Size - $40`) |
| **IRQ** | PCIe interrupt-map | `$19` (25) | `$1A` (26) |
| **FDT** | Under `pci@` node (ECAM) | `virtio@10059000` in SoC | `reserved-memory` with `no-map` |
| **Data Transfer** | Direct memory (BAR2) | Virtqueue descriptors (copy) | Direct memory (offset `$40`+) |
| **Guest→Host Signal** | Write to Doorbell register | VirtIO TX queue | Write to Doorbell register |
| **Host→Guest Signal** | `RingDoorbell` (PCIe IRQ) | VirtIO RX queue + IRQ | `RingDoorbell` (PLIC/APLIC IRQ) |
| **Guest Driver** | UIO / VFIO / custom PCI driver | `AF_VSOCK` (built-in kernel) | `devmem` / mmap / custom DT driver |
| **Complexity** | Medium (PCI enumeration, BARs) | High (VirtIO protocol, state machine) | Minimal (flat memory access) |
| **Overhead** | Low (zero-copy via BAR2) | Medium (data copied through virtqueues) | None (zero-copy) |

---

## 1. IVSHMEM (Inter-VM Shared Memory) — PCIe Device

### Description

IVSHMEM is a standardized PCIe device (Vendor `$1AF4` / Red Hat, Device `$1110`) that exposes a shared memory region via a PCI BAR. It follows the [QEMU IVSHMEM specification](https://www.qemu.org/docs/master/specs/ivshmem-spec.html), making it compatible with existing guest drivers.

### Memory Map

The device uses two PCI BARs:

**BAR0 — Device Registers (256 bytes)**

| Offset | Size | Access | Name | Description |
|--------|------|--------|------|-------------|
| `$00` | 4 | R/W | INTMASK | Interrupt mask — bit 0 enables interrupts |
| `$04` | 4 | R (clear-on-read) / W (clear bits) | INTSTATUS | Interrupt status |
| `$08` | 4 | R | IVPOSITION | IV position (always 0 in PasRISCV) |
| `$0C` | 4 | W | DOORBELL | Guest→host doorbell notification |
| `$10` | 4 | R | SHM\_SIZE\_LO | Shared memory size, low 32 bits |
| `$14` | 4 | R | SHM\_SIZE\_HI | Shared memory size, high 32 bits |

**BAR2 — Shared Memory (configurable, default 1 MB)**

Flat read/write memory region. Both host and guest access the same backing buffer directly.

### Configuration

| Property | Default | Description |
|---|---|---|
| `IVSHMEMSharedMemorySize` | `$100000` (1 MB) | Size of the shared memory region (BAR2) |

### Host-Side API (Pascal)

```pascal
// Direct pointer to the shared memory buffer
var P:Pointer;
P:=Machine.IVSHMEMDevice.SharedMemory;

// Read/write shared memory directly
PPasRISCVUInt32(P)^:=$DEADBEEF;
Value:=PPasRISCVUInt32(P)^;

// Get size
Size:=Machine.IVSHMEMDevice.SharedMemorySize;

// Guest→host notification callback
Machine.IVSHMEMDevice.OnDoorbellEvent:=@MyDoorbellHandler;
// procedure MyDoorbellHandler(const aSender:TIVSHMEMDevice;const aValue:TPasRISCVUInt32);

// Host→guest interrupt (requires guest to have INTMASK bit 0 set)
Machine.IVSHMEMDevice.RingDoorbell;
```

### Guest-Side Access

The guest discovers the device via standard PCIe enumeration:

```bash
# Find the IVSHMEM device
lspci -d 1af4:1110

# Using UIO driver
modprobe uio_pci_generic
echo "1af4 1110" > /sys/bus/pci/drivers/uio_pci_generic/new_id

# In application code: mmap BAR0 for registers, BAR2 for shared memory
```

```c
// C example with UIO
int uio_fd = open("/dev/uio0", O_RDWR);

// Map BAR0 (registers)
volatile uint32_t *regs = mmap(NULL, 256, PROT_READ|PROT_WRITE,
                                MAP_SHARED, uio_fd, 0);

// Map BAR2 (shared memory) — offset depends on BAR sizes
volatile uint8_t *shm = mmap(NULL, shm_size, PROT_READ|PROT_WRITE,
                              MAP_SHARED, uio_fd, 2 * getpagesize());

// Enable interrupts
regs[0] = 0x01;  // INTMASK

// Write to doorbell to notify host
regs[3] = 0x01;  // DOORBELL

// Read/write shared memory
shm[0] = 0x42;
uint32_t val = ((volatile uint32_t *)shm)[0];
```

### Advantages

- **Standardized** — uses the well-known IVSHMEM specification, compatible with existing QEMU tools and drivers
- **Zero-copy** — BAR2 provides direct shared memory access without data copying
- **Bidirectional signaling** — doorbell in both directions (guest→host and host→guest via interrupt)
- **Large memory support** — BAR2 size is configurable and can be large
- **Existing driver ecosystem** — can use `uio_pci_generic`, `vfio-pci`, or the ivshmem-specific kernel module

### Disadvantages

- **Requires PCI stack** — guest must have PCIe bus support and PCI driver infrastructure
- **More complex setup** — BAR enumeration, interrupt-map routing, PCI configuration space
- **Not suitable for bare-metal** — minimal guest environments without PCI support cannot use this device
- **Dynamic addressing** — BAR addresses are assigned at PCI enumeration time, not fixed

---

## 2. VirtIO Socket (vsock) — VirtIO MMIO Device

### Description

VirtIO Socket (vsock) implements the [VirtIO Socket specification](https://docs.oasis-open.org/virtio/virtio/v1.2/virtio-v1.2.html) (device type 19). It provides a standard socket-based communication channel between host and guest, supporting both stream (`SOCK_STREAM`) and sequential packet (`SOCK_SEQPACKET`) socket types. The guest uses the standard `AF_VSOCK` address family, which is built into most Linux kernels.

### Memory Map

Standard VirtIO MMIO v2 register layout at `$10059000`:

| Offset | Name | Description |
|--------|------|-------------|
| `$000` | MagicValue | `$74726976` ("virt") |
| `$004` | Version | 2 |
| `$008` | DeviceID | 19 (vsock) |
| `$00C` | VendorID | — |
| `$010` | DeviceFeatures | `VIRTIO_F_VERSION_1`, `VSOCK_F_STREAM`, `VSOCK_F_SEQPACKET` |
| `$070` | Status | Device status register |
| `$100+` | Config Space | 8 bytes: little-endian `guest_cid` |

Three virtqueues:
- **RX (0)** — host-to-guest packets
- **TX (1)** — guest-to-host packets
- **Event (2)** — transport events (e.g., reset)

### Protocol

The vsock protocol uses a 44-byte header (`TVSockHeader`) for all packets:

```
SrcCID:UInt64, DstCID:UInt64, SrcPort:UInt32, DstPort:UInt32,
Len:UInt32, SocketType:UInt16, Op:UInt16, Flags:UInt32,
BufAlloc:UInt32, FwdCnt:UInt32
```

Connection lifecycle:
1. **REQUEST** — initiator sends connection request
2. **RESPONSE** — responder accepts (or **RST** to reject)
3. **RW** — data transfer with flow control (credit-based)
4. **SHUTDOWN** — graceful close (with send/receive flags)
5. **RST** — hard close / error

### Configuration

| Property | Default | Description |
|---|---|---|
| `VirtIOVSockBase` | `$10059000` | MMIO base address |
| `VirtIOVSockSize` | `$1000` | MMIO region size |
| `VirtIOVSockIRQ` | `$19` (25) | Interrupt number |
| `VirtIOVSockGuestCID` | `3` | Guest context ID (host is always CID 2) |

### Host-Side API (Pascal)

```pascal
// Callbacks — set these before booting the guest
Machine.VirtIOVSockDevice.OnConnect:=@HandleConnect;
Machine.VirtIOVSockDevice.OnConnected:=@HandleConnected;
Machine.VirtIOVSockDevice.OnDisconnect:=@HandleDisconnect;
Machine.VirtIOVSockDevice.OnReceive:=@HandleReceive;

// Accept a guest-initiated connection (call from OnConnect handler)
Machine.VirtIOVSockDevice.AcceptConnection(RemotePort,LocalPort);

// Reject a guest-initiated connection
Machine.VirtIOVSockDevice.RejectConnection(RemotePort,LocalPort);

// Host initiates a connection to the guest
Machine.VirtIOVSockDevice.Connect(LocalPort,RemotePort);
// Result arrives via OnConnected callback (aAccepted=true/false)

// Send data to the guest (handles chunking and flow control)
Machine.VirtIOVSockDevice.SendData(RemotePort,LocalPort,@Buffer,Size,EOR);

// Send a single packet (max 64 KB)
Machine.VirtIOVSockDevice.SendPacket(RemotePort,LocalPort,@Buffer,Size);

// Close a connection
Machine.VirtIOVSockDevice.CloseConnection(RemotePort,LocalPort);

// Full transport reset (disconnects everything, notifies guest)
Machine.VirtIOVSockDevice.SendTransportReset;
```

### Guest-Side Access

The guest uses the standard `AF_VSOCK` socket API:

```python
# Python example — guest side
import socket

# Listen for host connections
s = socket.socket(socket.AF_VSOCK, socket.SOCK_STREAM)
s.bind((socket.VMADDR_CID_ANY, 1234))
s.listen(1)
conn, addr = s.accept()
data = conn.recv(4096)
conn.send(b"Hello from guest!")

# Connect to host (CID 2)
s = socket.socket(socket.AF_VSOCK, socket.SOCK_STREAM)
s.connect((2, 5678))
s.send(b"Hello from guest!")
data = s.recv(4096)
```

```c
// C example — guest side
#include <sys/socket.h>
#include <linux/vm_sockets.h>

int fd = socket(AF_VSOCK, SOCK_STREAM, 0);
struct sockaddr_vm addr = {
    .svm_family = AF_VSOCK,
    .svm_cid = VMADDR_CID_HOST,  // CID 2
    .svm_port = 1234,
};
connect(fd, (struct sockaddr *)&addr, sizeof(addr));
write(fd, "Hello", 5);
```

Kernel requirements:
```
CONFIG_VSOCKETS=y          (or =m)
CONFIG_VIRTIO_VSOCKETS=y   (or =m)
```

### Advantages

- **Standard socket API** — guest uses `AF_VSOCK`, no custom drivers needed
- **Built into Linux kernels** — most distributions include `virtio_vsock` as a module
- **Structured communication** — full connection lifecycle with connect/accept/reject/close
- **Flow control** — credit-based flow control prevents buffer overflows
- **Stream and seqpacket** — supports both `SOCK_STREAM` (byte stream) and `SOCK_SEQPACKET` (message boundaries)
- **Multiple connections** — supports many concurrent connections on different ports
- **Secure** — no direct memory sharing, data goes through virtqueue copies

### Disadvantages

- **Higher overhead** — data is copied through virtqueues, not zero-copy
- **Complex implementation** — full VirtIO protocol with virtqueues and state machine
- **Requires VirtIO support** — guest needs VirtIO MMIO driver infrastructure
- **Latency** — virtqueue processing introduces latency compared to direct memory access
- **Not suitable for bare-metal** — requires a full OS with VirtIO and socket support
- **Maximum packet size** — individual packets limited to 64 KB (`VSOCK_MAX_PKT_BUF_SIZE`), though `SendData` handles chunking automatically

---

## 3. Shared Memory — Simple Bus Device

### Description

The shared memory device is the simplest possible host-guest communication mechanism. It provides a flat memory-mapped region that both the host and guest can read and write directly, with a small register area for signaling. It requires no special guest drivers — just direct memory access via `/dev/mem`, `mmap`, or bare-metal load/store instructions.

The device is declared in the FDT as a `reserved-memory` node with the `no-map` property, preventing the Linux kernel from using the region as regular RAM.

### Memory Map

**Base address**: `$2F000000`, total size: `$100000` (1 MB)

**Registers (first 64 bytes)**

| Offset | Size | Access | Name | Description |
|--------|------|--------|------|-------------|
| `$00` | 4 | W | DOORBELL | Guest writes here to notify host (triggers callback) |
| `$04` | 4 | R | HOST\_FLAGS | Flags set by the host, readable by the guest |
| `$08` | 4 | R/W | GUEST\_FLAGS | Flags set by the guest, readable by the host |
| `$0C` | 4 | R | SIZE | Data region size in bytes |
| `$10` | 4 | R | IRQ\_STATUS | Bitmask of pending interrupt reasons |
| `$14` | 4 | W | IRQ\_ACK | Write bits to clear corresponding IRQ status bits |
| `$18`–`$3F` | — | — | (Reserved) | Reserved for future use |

**Data Region (offset `$40` to end)**

| Offset | Size | Access | Description |
|--------|------|--------|-------------|
| `$40` – `$FFFFF` | 1,048,512 bytes | R/W | Shared memory data region |

### Configuration

| Property | Default | Description |
|---|---|---|
| `SharedMemoryBase` | `$2F000000` | Base address |
| `SharedMemorySize` | `$100000` (1 MB) | Total size (registers + data) |
| `SharedMemoryIRQ` | `$1A` (26) | Interrupt number |

### FDT Node

```dts
reserved-memory {
    #address-cells = <2>;
    #size-cells = <2>;
    ranges;

    shared-memory@2f000000 {
        compatible = "pasriscv,shared-memory";
        reg = <0x00 0x2f000000 0x00 0x100000>;
        no-map;
        interrupts-extended = <&intc 0x1a>;
    };
};
```

### Host-Side API (Pascal)

```pascal
// Direct pointer to the data region (offset $40 onwards)
var P:Pointer;
P:=Machine.SharedMemoryDevice.DataPointer;

// Direct read/write — zero-copy
PPasRISCVUInt32(P)^:=$12345678;
Value:=PPasRISCVUInt32(P)^;

// Data region size
Size:=Machine.SharedMemoryDevice.DataSize;

// Thread-safe access
Machine.SharedMemoryDevice.Lock.AcquireRead;
try
 // read data...
finally
 Machine.SharedMemoryDevice.Lock.ReleaseRead;
end;

// Set flags visible to guest (at register $04)
Machine.SharedMemoryDevice.HostFlags:=$01;

// Read flags set by guest (at register $08)
if (Machine.SharedMemoryDevice.GuestFlags and $01)<>0 then begin
 ProcessGuestData(Machine.SharedMemoryDevice.DataPointer);
end;

// Guest→host doorbell callback
Machine.SharedMemoryDevice.OnDoorbellEvent:=@MyDoorbellHandler;
// procedure MyDoorbellHandler(const aSender:TSharedMemoryDevice;const aValue:TPasRISCVUInt32);

// Host→guest interrupt
Machine.SharedMemoryDevice.HostFlags:=$01; // set flag first
Machine.SharedMemoryDevice.RingDoorbell;   // then send IRQ
```

### Guest-Side Access

**Using `devmem` (for quick testing)**

```bash
# Read data region size
devmem 0x2F00000C 32

# Read host flags
devmem 0x2F000004 32

# Write guest flags
devmem 0x2F000008 32 0x01

# Write/read shared data
devmem 0x2F000040 32 0xDEADBEEF
devmem 0x2F000040 32

# Ring doorbell to notify host
devmem 0x2F000000 32 0x01
```

**Using mmap in C**

```c
#include <fcntl.h>
#include <sys/mman.h>
#include <stdint.h>

#define SHM_BASE  0x2F000000
#define SHM_SIZE  0x100000
#define DATA_OFF  0x40

int fd = open("/dev/mem", O_RDWR | O_SYNC);
volatile uint8_t *base = mmap(NULL, SHM_SIZE, PROT_READ | PROT_WRITE,
                               MAP_SHARED, fd, SHM_BASE);

volatile uint32_t *regs = (volatile uint32_t *)base;
volatile uint8_t  *data = base + DATA_OFF;

// Read data region size
uint32_t data_size = regs[3];  // offset $0C / 4

// Read host flags
uint32_t host_flags = regs[1];  // offset $04 / 4

// Write guest flags
regs[2] = 0x01;  // offset $08 / 4

// Read/write data
data[0] = 0x42;
((volatile uint32_t *)data)[0] = 0xDEADBEEF;

// Ring doorbell to notify host
regs[0] = 0x01;  // offset $00 / 4
```

**Bare-metal (RISC-V assembly)**

```asm
# Load base address
li   t0, 0x2F000000

# Write 0x42 to data region (offset $40)
li   t1, 0x42
sb   t1, 0x40(t0)

# Ring doorbell (offset $00)
li   t1, 1
sw   t1, 0(t0)

# Read host flags (offset $04)
lw   t2, 4(t0)
```

### Advantages

- **Zero complexity** — simplest possible host-guest communication, just load/store to a known address
- **Zero-copy** — host and guest access the same memory buffer directly
- **No driver required** — works with bare-metal code, `devmem`, or simple mmap; no kernel modules needed
- **No PCI or VirtIO stack required** — works in minimal guest environments without any bus infrastructure
- **Fixed address** — always at a known physical address, no enumeration needed
- **Device Tree discoverable** — guest can find it via FDT `compatible` string
- **Bidirectional signaling** — doorbell in both directions with IRQ support
- **DMA-capable** — supports `GetDeviceDirectMemoryAccessPointer` for efficient bulk transfers
- **Ideal for game integration** — perfect for shared state, command buffers, textures, or other real-time data

### Disadvantages

- **No structure** — raw memory with no built-in protocol; the application must define its own data format and synchronization
- **No flow control** — unlike vsock, there is no built-in mechanism to prevent one side from overwriting data before the other has consumed it
- **Custom compatible string** — uses `pasriscv,shared-memory`, which has no upstream Linux driver (requires custom driver, UIO, or `/dev/mem`)
- **Security** — the entire shared memory region is readable and writable by the guest with no access control
- **Fixed size** — the memory region size is set at configuration time and cannot be resized at runtime
- **Single region** — only one shared memory region is available (though the application can partition it internally)

---

## Choosing the Right Mechanism

### Use IVSHMEM when:

- You need **compatibility with existing tools** and the QEMU/KVM ecosystem
- The guest has a **full OS with PCI support** (Linux, BSD, Windows)
- You want **zero-copy shared memory** with an established specification
- You need **interoperability** with other hypervisors that support IVSHMEM

### Use VirtIO Socket (vsock) when:

- You need **structured communication** with connections, streams, and message boundaries
- The guest has a **full Linux kernel** with VirtIO support
- You want to use the **standard socket API** (`AF_VSOCK`) in the guest
- **Multiple independent channels** are needed (different port numbers)
- **Flow control** and **backpressure** are important
- **Security** matters — no direct memory sharing between host and guest

### Use Shared Memory when:

- You need the **simplest possible** host-guest data exchange
- The guest is **bare-metal** or has no PCI/VirtIO stack
- **Zero-copy performance** is critical (e.g., game state, framebuffer data, sensor arrays)
- You want to work with **`devmem`** or **mmap** without any kernel drivers
- The guest is a **custom firmware** or **embedded application**
- You need **real-time shared state** between host and guest with minimal latency

### Combining Mechanisms

All three mechanisms can be active simultaneously. A typical setup might use:

- **Shared Memory** for high-bandwidth, low-latency game state or framebuffer data
- **VirtIO Socket** for structured control messages and RPC between host and guest applications
- **IVSHMEM** for compatibility with third-party tools expecting the IVSHMEM interface
