# PasMP
PasMP - a parallel-processing/multi-processing library for Object Pascal 

License: zlib

## Support me

[Support me at Patreon](https://www.patreon.com/bero)

## Features

- Low-level-based design with optional high-level-based constructs
- Designed for fully-strict fork-join model in mind (because it's less error-prone to work with it than with terminally-strict fork-join for my taste), but it can be also abused for more flexible models, the only important thing is, that you're releasing the jobs again as soon as they are completed (the simplest weay would be by calling TPasMP.Reset per workload-frame), otherwise you'll have memory leaks, or just use the PasMPJobFlagReleaseOnFinish flag.
- It can be used as a job scheduler for multithreaded game engines and so on
- Work-first lock-free work-stealing dynamic-sized Chase-Lev queue/deque (where only the resizing code part of it isn't lock-free, so that on the other hand it is garbage-collector-free)
- Lock-free job memory allocator (al least lock-free on x86-32 and x86-64 targets)
- Parallel-for pattern
- Parallel intro sort (direct and indirect)
- Parellel merge sort (direct and indirect)
- Thread-safe single producer single consumer queue (untyped and typed, bounded-only, lock-free)
- Thread-safe multiple producer multiple consumer stack (untyped and typed, bounded and unbounded, lock-free on x86-32/x86-64/ARM32, lock-based on another CPU targets)
- Thread-safe multiple producer multiple consumer queue (untyped and typed, bounded and unbounded, lock-free on x86-32/x86-64/ARM32, lock-based on another CPU targets)
- Thread-safe hash table (untyped and typed, hybrid-implementation of lock-free and fine-graded lock-based single-operation code parts)
- Thread-safe dynamic-sized array (untyped and typed, fine-graded lock-based)
- TPasMPMath class with class static useful (primary bit-twiddling) math function methods
- TPasMPInterlocked class with class static atomic function methods
- TPasMPMemoryBarrier class with class static memory barrier function methods
- TPasMPMemory class with class static aligned memory allocation function methods
- Synchronisation primitives:
  - TPasMPEvent
  - TPasMPSimpleEvent
  - TPasMPCriticalSection
  - TPasMPMutex
  - TPasMPConditionVariableLock
  - TPasMPConditionVariable
  - TPasMPSemaphore
  - TPasMPInvertedSemaphore
  - TPasMPMultipleReaderSingleWriterLock
  - TPasMPMultipleReaderSingleWriterSpinLock
  - TPasMPSlimReaderWriterLock
  - TPasMPSpinLock
  - TPasMPBarrier  
- Optional strict singleton usage option per global PasMPUseAsStrictSingletonInstance define (besides the option of usage of multiple PasMP instances)
- Compatible with FreePascal >= 3.0.0 and Delphi >= 7
- Cross platform (Windows (needs Vista or higher, so no XP, no 9x, no NT 3.x, no NT 4.x), Linux, etc.)

## Target informations (i.e. System requirements)

- 32-bit x86 targets must support the cmpxchg8b instruction (it present on most all post-80486 processors, so >= Pentium 1 and newer)
- 64-bit x86 targets must support the cmpxchg16b instruction (early AMD64 processors before Revision F and some early stepping D Intel Nocona processors lacked the CMPXCHG16B instruction, otherwise all 64-bit x86 processors should have support for the cmpxchg16b instruction)
- ARM targets must support the ldrexd and strexd instructions (it present on ARMv6k and ARMv7 and higher ARM processors)
- MIPS targets aren't supported in the lock-free PasMP build variant (only as lock-based PasMP build variant), until I've found a way to do Double-Compare-And-Swap on the MIPS target. I would be most pleased to have your hints and suggestions to help up me to implement DCAS (or a lock-free ABA-free multiple producer multiple consumer queue and stack) on the MIPS target. 
- PowerPC targets aren't supported in the lock-free PasMP build variant (only as lock-based PasMP build variant), until I've found a way to do Double-Compare-And-Swap on the PowerPC target. I would be most pleased to have your hints and suggestions to help up me to implement DCAS (or a lock-free ABA-free multiple producer multiple consumer queue and stack) on the PowerPC target. 







 


 



