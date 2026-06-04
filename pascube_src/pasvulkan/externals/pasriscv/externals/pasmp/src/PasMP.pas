(******************************************************************************
 *                                   PasMP                                    *
 ******************************************************************************
 *                        Version 2025-01-17-01-10-0000                       *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2016-2025, Benjamin Rosseaux (benjamin@rosseaux.de)          *
 *                                                                            *
 * This software is provided 'as-is', without any express or implied          *
 * warranty. In no event will the authors be held liable for any damages      *
 * arising from the use of this software.                                     *
 *                                                                            *
 * Permission is granted to anyone to use this software for any purpose,      *
 * including commercial applications, and to alter it and redistribute it     *
 * freely, subject to the following restrictions:                             *
 *                                                                            *
 * 1. The origin of this software must not be misrepresented; you must not    *
 *    claim that you wrote the original software. If you use this software    *
 *    in a product, an acknowledgement in the product documentation would be  *
 *    appreciated but is not required.                                        *
 * 2. Altered source versions must be plainly marked as such, and must not be *
 *    misrepresented as being the original software.                          *
 * 3. This notice may not be removed or altered from any source distribution. *
 *                                                                            *
 ******************************************************************************
 *                  General guidelines for code contributors                  *
 *============================================================================*
 *                                                                            *
 * 1. Make sure you are legally allowed to make a contribution under the zlib *
 *    license.                                                                *
 * 2. The zlib license header goes at the top of each source file, with       *
 *    appropriate copyright notice.                                           *
 * 3. After a pull request, check the status of your pull request on          *
      http://github.com/BeRo1985/pasmp                                        *
 * 4. Write code, which is compatible with Delphi 7-XE7 and FreePascal >= 2.6 *
 *    so don't use generics/templates, operator overloading and another newer *
 *    syntax features than Delphi 7 has support for that, but if needed, make *
 *    it out-ifdef-able.                                                      *
 * 5. Don't use Delphi-only, FreePascal-only or Lazarus-only libraries/units, *
 *    but if needed, make it out-ifdef-able.                                  *
 * 6. No use of third-party libraries/units as possible, but if needed, make  *
 *    it out-ifdef-able.                                                      *
 * 7. Try to use const when possible.                                         *
 * 8. Make sure to comment out writeln, used while debugging.                 *
 * 9. Make sure the code compiles on 32-bit and 64-bit platforms (x86-32,     *
 *    x86-64, ARM, ARM64, etc.).                                              *
 * 10. Make sure the code runs on platforms with weak and strong memory       *
 *     models without any issues.                                             *
 *                                                                            *
 ******************************************************************************)
unit PasMP;
{$ifdef fpc}
 {$mode delphi}
 {$ifdef CPUi386}
  {$define CPU386}
 {$endif}
 {$ifdef CPUAMD64}
  {$define CPUx86_64}
 {$endif}
 {$ifdef CPU386}
  {$define CPUx86}
  {$define CPU32}
  {$asmmode intel}
  {$define PasMPHaveFPUControls}
 {$endif}
 {$ifdef CPUx86_64}
  {$define CPUx64}
  {$define CPU64}
  {$asmmode intel}
  {$define PasMPHaveFPUControls}
 {$endif}
 {$ifdef FPC_LITTLE_ENDIAN}
  {$define LITTLE_ENDIAN}
 {$else}
  {$ifdef FPC_BIG_ENDIAN}
   {$define BIG_ENDIAN}
  {$endif}
 {$endif}
 {-$pic off}
 {$define HAS_ADVANCED_RECORDS}
 {$define CAN_INLINE}
 {$ifdef FPC_HAS_TYPE_EXTENDED}
  {$define HAS_TYPE_EXTENDED}
 {$else}
  {$undef HAS_TYPE_EXTENDED}
 {$endif}
 {$ifdef FPC_HAS_TYPE_DOUBLE}
  {$define HAS_TYPE_DOUBLE}
 {$else}
  {$undef HAS_TYPE_DOUBLE}
 {$endif}
 {$ifdef FPC_HAS_TYPE_SINGLE}
  {$define HAS_TYPE_SINGLE}
 {$else}
  {$undef HAS_TYPE_SINGLE}
 {$endif}
 {$if defined(FPC_FULLVERSION) and (FPC_FULLVERSION>=30301) and not defined(PASMP_NO_ANONYMOUS_METHODS)}
  {$modeswitch functionreferences}
  {$modeswitch anonymousfunctions}
  {$warn 5036 off}
  {$define HAS_ANONYMOUS_METHODS}
 {$else}
  {$undef HAS_ANONYMOUS_METHODS}
 {$ifend}
 {$if declared(RawByteString)}
  {$define HAS_TYPE_RAWBYTESTRING}
 {$else}
  {$undef HAS_TYPE_RAWBYTESTRING}
 {$ifend}
 {$if declared(UTF8String)}
  {$define HAS_TYPE_UTF8STRING}
 {$else}
  {$undef HAS_TYPE_UTF8STRING}
 {$ifend}
 {$define HAS_GENERICS}
 {$define HAS_STATIC}
 {$if defined(FPC_VERSION) and (FPC_VERSION>=3)}
  {$define HAS_NAMETHREADFORDEBUGGING}
 {$ifend}
{$else}
 {$realcompatibility off}
 {$localsymbols on}
 {$define LITTLE_ENDIAN}
 {$ifndef CPU64}
  {$define CPU32}
 {$endif}
 {$ifdef CPUx64}
  {$define CPUx86_64}
  {$define CPU64}
  {$define PasMPHaveFPUControls}
 {$else}
  {$ifdef CPU386}
   {$define CPUx86}
   {$define CPU32}
   {$define PasMPHaveFPUControls}
  {$endif}
 {$endif}
 {$define HAS_TYPE_EXTENDED}
 {$define HAS_TYPE_DOUBLE}
 {$define HAS_TYPE_SINGLE}
 {$undef HAS_TYPE_RAWBYTESTRING}
 {$undef HAS_TYPE_UTF8STRING}
 {$realcompatibility off}
 {$localsymbols on}
 {$define LITTLE_ENDIAN}
 {$ifndef cpu64}
  {$define cpu32}
 {$endif}
 {$ifndef BCB}
  {$ifdef ver120}
   {$define Delphi4or5}
  {$endif}
  {$ifdef ver130}
   {$define Delphi4or5}
  {$endif}
  {$ifdef ver140}
   {$define Delphi6}
  {$endif}
  {$ifdef ver150}
   {$define Delphi7}
  {$endif}
  {$ifdef ver170}
   {$define Delphi2005}
  {$endif}
 {$else}
  {$ifdef ver120}
   {$define Delphi4or5}
   {$define BCB4}
  {$endif}
  {$ifdef ver130}
   {$define Delphi4or5}
  {$endif}
 {$endif}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
  {$if declared(RawByteString)}
   {$define HAS_TYPE_RAWBYTESTRING}
  {$else}
   {$undef HAS_TYPE_RAWBYTESTRING}
  {$ifend}
  {$if declared(UTF8String)}
   {$define HAS_TYPE_UTF8STRING}
  {$else}
   {$undef HAS_TYPE_UTF8STRING}
  {$ifend}
  {$if CompilerVersion>=14.0}
   {$if CompilerVersion=14.0}
    {$define Delphi6}
   {$ifend}
   {$define Delphi6AndUp}
  {$ifend}
  {$if CompilerVersion>=15.0}
   {$if CompilerVersion=15.0}
    {$define Delphi7}
   {$ifend}
   {$define Delphi7AndUp}
  {$ifend}
  {$if CompilerVersion>=17.0}
   {$if CompilerVersion=17.0}
    {$define Delphi2005}
   {$ifend}
   {$define Delphi2005AndUp}
  {$ifend}
  {$if CompilerVersion>=18.0}
   {$if CompilerVersion=18.0}
    {$define BDS2006}
    {$define Delphi2006}
   {$ifend}
   {$define Delphi2006AndUp}
   {$define CAN_INLINE}
   {$define HAS_ADVANCED_RECORDS}
  {$ifend}
  {$if CompilerVersion>=18.5}
   {$if CompilerVersion=18.5}
    {$define Delphi2007}
   {$ifend}
   {$define Delphi2007AndUp}
  {$ifend}
  {$if CompilerVersion=19.0}
   {$define Delphi2007Net}
  {$ifend}
  {$if CompilerVersion>=20.0}
   {$if CompilerVersion=20.0}
    {$define Delphi2009}
   {$ifend}
   {$define Delphi2009AndUp}
   {$ifndef PASMP_NO_ANONYMOUS_METHODS}
    {$define HAS_ANONYMOUS_METHODS}
   {$endif}
   {$define HAS_GENERICS}
   {$define HAS_STATIC}
  {$ifend}
  {$if CompilerVersion>=21.0}
   {$if CompilerVersion=21.0}
    {$define Delphi2010}
   {$ifend}
   {$define Delphi2010AndUp}
  {$ifend}
  {$if CompilerVersion>=22.0}
   {$if CompilerVersion=22.0}
    {$define DelphiXE}
   {$ifend}
   {$define DelphiXEAndUp}
  {$ifend}
  {$if CompilerVersion>=23.0}
   {$if CompilerVersion=23.0}
    {$define DelphiXE2}
   {$ifend}
   {$define DelphiXE2AndUp}
  {$ifend}
  {$if CompilerVersion>=24.0}
   {$if CompilerVersion=24.0}
    {$define DelphiXE3}
   {$ifend}
   {$define DelphiXE3AndUp}
   {$define HAS_ATOMICS}
  {$ifend}
  {$if CompilerVersion>=25.0}
   {$if CompilerVersion=25.0}
    {$define DelphiXE4}
   {$ifend}
   {$define DelphiXE4AndUp}
   {$define HAS_WEAK}
   {$define HAS_VOLATILE}
   {$define HAS_REF}
  {$ifend}
  {$if CompilerVersion>=26.0}
   {$if CompilerVersion=26.0}
    {$define DelphiXE5}
   {$ifend}
   {$define DelphiXE5AndUp}
  {$ifend}
  {$if CompilerVersion>=27.0}
   {$if CompilerVersion=27.0}
    {$define DelphiXE6}
   {$ifend}
   {$define DelphiXE6AndUp}
  {$ifend}
  {$if CompilerVersion>=28.0}
   {$if CompilerVersion=28.0}
    {$define DelphiXE7}
   {$ifend}
   {$define DelphiXE7AndUp}
  {$ifend}
  {$if CompilerVersion>=29.0}
   {$if CompilerVersion=29.0}
    {$define DelphiXE8}
   {$ifend}
   {$define DelphiXE8AndUp}
  {$ifend}
  {$if CompilerVersion>=30.0}
   {$if CompilerVersion=30.0}
    {$define Delphi10Seattle}
   {$ifend}
   {$define Delphi10SeattleAndUp}
  {$ifend}
  {$if CompilerVersion>=31.0}
   {$if CompilerVersion=31.0}
    {$define Delphi10Berlin}
   {$ifend}
   {$define Delphi10BerlinAndUp}
  {$ifend}
  {$if CompilerVersion>=31.0}
   {$define HAS_NAMETHREADFORDEBUGGING}
  {$ifend}
 {$endif}
 {$ifndef Delphi4or5}
  {$ifndef BCB}
   {$define Delphi6AndUp}
  {$endif}
  {$ifndef Delphi6}
   {$define BCB6OrDelphi7AndUp}
   {$ifndef BCB}
    {$define Delphi7AndUp}
   {$endif}
   {$ifndef BCB}
    {$ifndef Delphi7}
     {$ifndef Delphi2005}
      {$define BDS2006AndUp}
     {$endif}
    {$endif}
   {$endif}
  {$endif}
 {$endif}
 {$ifdef Delphi6AndUp}
  {$warn symbol_platform off}
  {$warn symbol_deprecated off}
 {$endif}
 {$ifdef Posix}
  {$define Unix}
 {$endif}
{$endif}
{$if defined(CPU386) or defined(CPUx86_64) or (defined(FPC) and defined(CPUAARCH64))}
 {$define PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}
{$elseif defined(CPUARM)}
 {$if defined(CPUARMV6K)}
  // = CPUARMV6K
  {$ifdef PASMP_FORCE_ARM_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}
   {$define PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}
  {$endif}
 {$elseif defined(CPUARM_HAS_DMB) and defined(CPUARM_HAS_LDREX)}
  // >= CPUARMV7A
  {$ifdef PASMP_FORCE_ARM_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}
   {$define PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}
  {$endif}
 {$ifend}
{$ifend}
{$if defined(Win32) or defined(Win64) or defined(WinCE)}
 {$define Windows}
{$ifend}
{$rangechecks off}
{$extendedsyntax on}
{$writeableconst on}
{$hints off}
{$booleval off}
{$typedaddress off}
{$stackframes off}
{$varstringchecks on}
{$typeinfo on}
{$overflowchecks off}
{$longstrings on}
{$openstrings on}

{$undef UseThreadLocalStorage}
{$undef UseThreadLocalStorageX8632}

{$if defined(Linux) or defined(Android)}
 {$ifdef fpc}
  {$define PasMPPThreadSpinLock}
  {$define PasMPPThreadBarrier}
 {$else}
  {$undef PasMPPThreadSpinLock}
  {$undef PasMPPThreadBarrier}
 {$endif}
{$else}
 {$undef PasMPPThreadSpinLock}
 {$undef PasMPPThreadBarrier}
{$ifend}

{$ifdef PasMPUseAsStrictSingletonInstance}
{$if defined(Windows) and (defined(CPU386) or defined(CPUx86_64)) and not (defined(FPC) or defined(UseMultiplePasMPInstanceInstances))}
 // Delphi (under x86 Windows) has fast thread local storage handling (per nearly direct TEB access by reading fs:[0x18])
 {$define UseThreadLocalStorage}
 {$ifdef cpu386}
  {$define UseThreadLocalStorageX8632}
 {$endif}
 {$ifdef cpux86_64}
  {$define UseThreadLocalStorageX8664}
 {$endif}
{$else}
 // FreePascal has portable but unfortunately slow thread local storage handling (for example under Windows, over TLSGetIndex
 // calls etc. in FPC_THREADVAR_RELOCATE), so use here the bit faster thread ID hash table approach with less total CPU-cycle
 // count and less OS-API calls than with the FPC_THREADVAR_RELOCATE variant
{$ifend}
{$endif}

{$define PasMPUseWakeUpConditionVariable}

interface

uses {$ifdef Windows}
      Windows,MMSystem,
     {$else}
      {$ifdef fpc}
       {$ifdef Unix}
        {$ifdef usecthreads}
         cthreads,
        {$endif}
        BaseUnix,Unix,UnixType,{$ifndef AndroidOld}PThreads,{$endif}
        {$if defined(Linux) or defined(Android)}
         Linux,
        {$else}
         ctypes,sysctl,
        {$ifend}
       {$endif}
      {$else}
       {$if defined(DelphiXE2AndUp) and defined(Posix)}
        Posix.Base,
        Posix.StdDef,
        Posix.SysTypes,
        Posix.SysTime,
        Posix.Time,
        Posix.Sched,
        Posix.Semaphore,
        Posix.Pthread,
        Posix.Errno,
       {$ifend}
      {$endif}
     {$endif}
     SysUtils,Classes,
     {$ifdef HAS_GENERICS}
      {$if defined(fpc)}
       {$if defined(FreePascalGenericsCollectionsLibrary) or (defined(fpc) and (((fpc_version=3.0) and (fpc_release>=1.0)) or (fpc_version>3.0)))}
     Generics.Defaults,
        {$define HasGenericsCollections}
       {$ifend}
      {$else}
     System.Generics.Defaults,
       {$define HasGenericsCollections}
      {$ifend}
     {$endif}
     Math,SyncObjs;

type TPasMPInt8={$if declared(Int8)}Int8{$else}shortint{$ifend};
     PPasMPInt8=^TPasMPInt8;

     TPasMPUInt8={$if declared(UInt8)}UInt8{$else}byte{$ifend};
     PPasMPUInt8=^TPasMPUInt8;

     TPasMPInt16={$if declared(Int16)}Int16{$else}smallint{$ifend};
     PPasMPInt16=^TPasMPInt16;

     TPasMPUInt16={$if declared(UInt16)}UInt16{$else}word{$ifend};
     PPasMPUInt16=^TPasMPUInt16;

     TPasMPInt32={$if declared(Int32)}Int32{$else}longint{$ifend};
     PPasMPInt32=^TPasMPInt32;

     TPasMPUInt32={$if declared(UInt32)}UInt32{$else}longword{$ifend};
     PPasMPUInt32=^TPasMPUInt32;

     TPasMPInt64=int64;
     PPasMPInt64=^TPasMPInt64;

{$ifdef fpc}
 {$undef OldDelphi}
     TPasMPUInt64=uint64;
     TPasMPPtrUInt=PtrUInt;
     TPasMPPtrInt=PtrInt;
{$else}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=23.0}
   {$undef OldDelphi}
     TPasMPUInt64=uint64;
     TPasMPPtrUInt=NativeUInt;
     TPasMPPtrInt=NativeInt;
  {$else}
   {$define OldDelphi}
  {$ifend}
 {$else}
  {$define OldDelphi}
 {$endif}
{$endif}
{$ifdef OldDelphi}
  {$if CompilerVersion>=15.0}
     TPasMPUInt64=uint64;
  {$else}
     TPasMPUInt64=TPasMPInt64;
  {$ifend}
  {$ifdef CPU64}
     TPasMPPtrUInt=qword;
     TPasMPPtrInt=TPasMPInt64;
  {$else}
     TPasMPPtrUInt=TPasMPUInt32;
     TPasMPPtrInt=TPasMPInt32;
  {$endif}
{$endif}

     PPasMPUInt64=^TPasMPUInt64;

     TPasMPUInt64DynamicArray=array of TPasMPUInt64;

     PPasMPPtrUInt=^TPasMPPtrUInt;
     PPasMPPtrInt=^TPasMPPtrInt;

     TPasMPNativeUInt=TPasMPPtrUInt;
     PPasMPNativeUInt=^TPasMPNativeUInt;

     TPasMPNativeInt=TPasMPPtrInt;
     PPasMPNativeInt=^TPasMPNativeInt;

     TPasMPSizeUInt=TPasMPPtrUInt;
     PPasMPSizeUInt=^TPasMPSizeUInt;

     TPasMPSizeInt=TPasMPPtrInt;
     PPasMPSizeInt=^TPasMPSizeInt;

     TPasMPSizeIntEx={$ifdef cpu64}TPasMPInt64{$else}TPasMPInt32{$endif};
     PPasMPSizeIntEx=^TPasMPSizeIntEx;

     TPasMPSizeUIntEx={$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif};
     PPasMPSizeUIntEx=^TPasMPSizeUIntEx;

     TPasMPBoolean=boolean;
     PPasMPBoolean=^TPasMPBoolean;

     TPasMPBool8=bytebool;
     PPasMPBool8=^TPasMPBool8;

     TPasMPBool16=wordbool;
     PPasMPBool16=^TPasMPBool16;

     TPasMPBool32=longbool;
     PPasMPBool32=^TPasMPBool32;

const PasMPAllocatorPoolBucketBits=12;
      PasMPAllocatorPoolBucketSize=1 shl PasMPAllocatorPoolBucketBits;
      PasMPAllocatorPoolBucketMask=PasMPAllocatorPoolBucketSize-1;

      PasMPJobQueueStartSize=4096; // must be power of two

      PasMPJobWorkerThreadHashTableSize=4096;
      PasMPJobWorkerThreadHashTableMask=PasMPJobWorkerThreadHashTableSize-1;

      PasMPDefaultDepth=16;

      PasMPJobThreadIndexBits=12; // 4096 worker threads should be enough for the first time
      PasMPJobThreadIndexSize=TPasMPUInt32(TPasMPUInt32(1) shl PasMPJobThreadIndexBits);
      PasMPJobThreadIndexMask=PasMPJobThreadIndexSize-1;
      PasMPJobThreadIndexShift=0;
      PasMPJobThreadIndexShiftedMask=PasMPJobThreadIndexMask shl PasMPJobThreadIndexShift;

      PasMPJobPriorityBits=2; // 4 priorities (inherited, low, normal, high)
      PasMPJobPrioritySize=TPasMPUInt32(TPasMPUInt32(1) shl PasMPJobPriorityBits);
      PasMPJobPriorityMask=PasMPJobPrioritySize-1;
      PasMPJobPriorityShift=PasMPJobThreadIndexBits;
      PasMPJobPriorityShiftedMask=PasMPJobPriorityMask shl PasMPJobPriorityShift;

      PasMPJobTagBits=12; // 4096 task tags should be enough for the first time
      PasMPJobTagSize=TPasMPUInt32(TPasMPUInt32(1) shl PasMPJobTagBits);
      PasMPJobTagMask=PasMPJobTagSize-1;
      PasMPJobTagShift=PasMPJobThreadIndexBits+PasMPJobPriorityBits;
      PasMPJobTagShiftedMask=PasMPJobTagMask shl PasMPJobTagShift;

      PasMPJobPriorityInherited=(TPasMPUInt32(0) shl PasMPJobPriorityShift) and PasMPJobPriorityShiftedMask;
      PasMPJobPriorityLow=(TPasMPUInt32(1) shl PasMPJobPriorityShift) and PasMPJobPriorityShiftedMask;
      PasMPJobPriorityNormal=(TPasMPUInt32(2) shl PasMPJobPriorityShift) and PasMPJobPriorityShiftedMask;
      PasMPJobPriorityHigh=(TPasMPUInt32(3) shl PasMPJobPriorityShift) and PasMPJobPriorityShiftedMask;

      PasMPJobFlagRequeue=TPasMPUInt32(TPasMPUInt32(1) shl 28);
      PasMPJobFlagRequeueAndNotMask=TPasMPUInt32(not PasMPJobFlagRequeue);

      PasMPJobFlagHasOwnerWorkerThread=TPasMPUInt32(TPasMPUInt32(1) shl 29);
      PasMPJobFlagReleaseOnFinish=TPasMPUInt32(TPasMPUInt32(1) shl 30);

      PasMPJobFlagActive=TPasMPUInt32(TPasMPUInt32(1) shl 31);
      PasMPJobFlagActiveAndNotMask=TPasMPUInt32(not PasMPJobFlagActive);

      PasMPCPUCacheLineSize=64;

      PasMPDoubleNativeMachineWordAtomicCompareExchangeAlignment=SizeOf(TPasMPPtrUInt) shl 1;

      PasMPProfilerHistoryRingBufferSizeBits=16;
      PasMPProfilerHistoryRingBufferSize=TPasMPUInt32(1) shl PasMPProfilerHistoryRingBufferSizeBits;
      PasMPProfilerHistoryRingBufferSizeMask=TPasMPUInt32(PasMPProfilerHistoryRingBufferSize-1);

      PasMPOnceInit={$ifdef Linux}PTHREAD_ONCE_INIT{$else}0{$endif};

      PasMPJobQueuePriorityLow=2;
      PasMPJobQueuePriorityNormal=1;
      PasMPJobQueuePriorityHigh=0;

      PasMPJobQueuePriorityFirst=PasMPJobQueuePriorityHigh;
      PasMPJobQueuePriorityLast=PasMPJobQueuePriorityLow;

      PasMPVersionMajor=1000000;
      PasMPVersionMinor=1000;
      PasMPVersionRelease=1;

{$ifndef FPC}
      // Delphi evaluates every $IF-directive even if it is disabled by a surrounding, so it's then a error in Delphi, and for to avoid it, we define dummys here.
      FPC_VERSION=0;
      FPC_RELEASE=0;
      FPC_PATCH=0;
      FPC_FULLVERSION=(FPC_VERSION*10000)+(FPC_RELEASE*100)+(FPC_PATCH*1);
{$endif}

//    FPC_VERSION_PASMP=(FPC_VERSION*PasMPVersionMajor)+(FPC_RELEASE*PasMPVersionMinor)+(FPC_PATCH*PasMPVersionRelease);

{$ifndef Windows}
{$ifndef fpc}
      INFINITE=TPasMPUInt32(-1);
{$endif}
{$endif}

      PasMPThreadSafeDynamicArrayFirstBucketBits=3;
      PasMPThreadSafeDynamicArrayFirstBucketSize=1 shl PasMPThreadSafeDynamicArrayFirstBucketBits;
      PasMPThreadSafeDynamicArrayNumberOfBuckets=30;
      PasMPThreadSafeDynamicArrayMarkFirstBit=TPasMPUInt32($80000000);

      PasMPCLZDebruijn32Multiplicator=TPasMPUInt32($07c4acdd);
      PasMPCLZDebruijn32Shift=27;
      PasMPCLZDebruijn32Mask=31;
      PasMPCLZDebruijn32Table:array[0..31] of TPasMPInt32=(31,22,30,21,18,10,29,2,20,17,15,13,9,6,28,1,23,19,11,3,16,14,7,24,12,4,8,25,5,26,27,0);

      PasMPCLZDebruijn64Multiplicator:TPasMPUInt64=TPasMPUInt64($03f79d71b4cb0a89);
      PasMPCLZDebruijn64Shift=58;
      PasMPCLZDebruijn64Mask=63;
      PasMPCLZDebruijn64Table:array[0..63] of TPasMPInt32=(63,16,62,7,15,36,61,3,6,14,22,26,35,47,60,2,9,5,28,11,13,21,42,19,25,31,34,40,46,52,59,1,
                                                           17,8,37,4,23,27,48,10,29,12,43,20,32,41,53,18,38,24,49,30,44,33,54,39,50,45,55,51,56,57,58,0);

      PasMPCTZDebruijn32Multiplicator=TPasMPUInt32($077cb531);
      PasMPCTZDebruijn32Shift=27;
      PasMPCTZDebruijn32Mask=31;
      PasMPCTZDebruijn32Table:array[0..31] of TPasMPInt32=(0,1,28,2,29,14,24,3,30,22,20,15,25,17,4,8,31,27,13,23,21,19,16,7,26,12,18,6,11,5,10,9);

      PasMPCTZDebruijn64Multiplicator:TPasMPUInt64=TPasMPUInt64($07edd5e59a4e28c2);
      PasMPCTZDebruijn64Shift=58;
      PasMPCTZDebruijn64Mask=63;
      PasMPCTZDebruijn64Table:array[0..63] of TPasMPInt32=(63,0,58,1,59,47,53,2,60,39,48,27,54,33,42,3,61,51,37,40,49,18,28,20,55,30,34,11,43,14,22,4,
                                                           62,57,46,52,38,26,32,41,50,36,17,19,29,10,13,21,56,45,25,31,35,16,9,12,44,24,15,8,23,7,6,5);

      PasMPBSFDebruijn32Multiplicator=TPasMPUInt32($077cb531);
      PasMPBSFDebruijn32Shift=27;
      PasMPBSFDebruijn32Mask=31;
      PasMPBSFDebruijn32Table:array[0..31] of TPasMPInt32=(0,1,28,2,29,14,24,3,30,22,20,15,25,17,4,8,31,27,13,23,21,19,16,7,26,12,18,6,11,5,10,9);

      PasMPBSFDebruijn64Multiplicator:TPasMPUInt64=TPasMPUInt64($03f79d71b4cb0a89);
      PasMPBSFDebruijn64Shift=58;
      PasMPBSFDebruijn64Mask=63;
      PasMPBSFDebruijn64Table:array[0..63] of TPasMPInt32=(0,1,48,2,57,49,28,3,61,58,50,42,38,29,17,4,62,55,59,36,53,51,43,22,45,39,33,30,24,18,12,5,
                                                          63,47,56,27,60,41,37,16,54,35,52,21,44,32,23,11,46,26,40,15,34,20,31,10,25,14,19,9,13,8,7,6);

      PasMPBSRDebruijn32Multiplicator=TPasMPUInt32($07c4acdd);
      PasMPBSRDebruijn32Shift=27;
      PasMPBSRDebruijn32Mask=31;
      PasMPBSRDebruijn32Table:array[0..31] of TPasMPInt32=(0,9,1,10,13,21,2,29,11,14,16,18,22,25,3,30,8,12,20,28,15,17,24,7,19,27,23,6,26,5,4,31);

      PasMPBSRDebruijn64Multiplicator:TPasMPUInt64=TPasMPUInt64($03f79d71b4cb0a89);
      PasMPBSRDebruijn64Shift=58;
      PasMPBSRDebruijn64Mask=63;
      PasMPBSRDebruijn64Table:array[0..63] of TPasMPInt32=(0,47,1,56,48,27,2,60,57,49,41,37,28,16,3,61,54,58,35,52,50,42,21,44,38,32,29,23,17,11,4,62,
                                                           46,55,26,59,40,36,15,53,34,51,20,43,31,22,10,45,25,39,14,33,19,30,9,24,13,18,8,12,7,6,5,63);

type TPasMPAvailableCPUCores=array of TPasMPInt32;

     PPasMPInt128Record=^TPasMPInt128Record;
     TPasMPInt128Record=record
{$ifdef BIG_ENDIAN}
      Hi,Lo:TPasMPUInt64;
{$else}
      Lo,Hi:TPasMPUInt64;
{$endif}
     end;

     PPasMPInt64Record=^TPasMPInt64Record;
     TPasMPInt64Record=record
      case boolean of
       false:(
{$ifdef BIG_ENDIAN}
        Hi,Lo:TPasMPUInt32;
{$else}
        Lo,Hi:TPasMPUInt32;
{$endif}
       );
       true:(
        Value:TPasMPInt64;
       );
     end;

     PPasMPTaggedPointer=^TPasMPTaggedPointer;
     TPasMPTaggedPointer=record
      case TPasMPInt32 of
       0:(
        PointerValue:pointer;
        TagValue:TPasMPPtrUInt;
       );
       1:(
        Value:{$ifdef CPU64}TPasMPInt128Record{$else}TPasMPInt64Record{$endif};
       );
     end;

{$ifdef Unix}
     PPasMPTimeSpec=^TPasMPTimeSpec;
     TPasMPTimeSpec={$if defined(fpc)}TTimeSpec{$elseif declared(timespec)}timespec{$else}record
      tv_sec:time_t;
      tv_nsec:suseconds_t;
     end{$ifend};

     PPasMPTimeZone=^TPasMPTimeZone;
     TPasMPTimeZone={$ifdef fpc}timezone{$else}record
      tz_minuteswest:TPasMPInt32;
      tz_dsttime:TPasMPInt32;
     end{$endif};
{$endif}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPMath=class
      public
       class function PopulationCount32(Value:TPasMPUInt32):TPasMPInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function PopulationCount64(Value:TPasMPUInt64):TPasMPInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function PopulationCount(Value:TPasMPPtrUInt):TPasMPInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function BitScanForward32(Value:TPasMPUInt32):TPasMPInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function BitScanForward64(Value:TPasMPUInt64):TPasMPInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function BitScanForward(Value:TPasMPPtrUInt):TPasMPInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function BitScanReverse32(Value:TPasMPUInt32):TPasMPInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function BitScanReverse64(Value:TPasMPUInt64):TPasMPInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function BitScanReverse(Value:TPasMPPtrUInt):TPasMPInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function CountLeadingZeros32(Value:TPasMPUInt32):TPasMPInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function CountLeadingZeros64(Value:TPasMPUInt64):TPasMPInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function CountLeadingZeros(Value:TPasMPPtrUInt):TPasMPInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function CountTrailingZeros32(Value:TPasMPUInt32):TPasMPInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function CountTrailingZeros64(Value:TPasMPUInt64):TPasMPInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function CountTrailingZeros(Value:TPasMPPtrUInt):TPasMPInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function FindFirstSetBit32(Value:TPasMPUInt32):TPasMPInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function FindFirstSetBit64(Value:TPasMPUInt64):TPasMPInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function FindFirstSetBit(Value:TPasMPPtrUInt):TPasMPInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function RoundUpToPowerOfTwo32(Value:TPasMPUInt32):TPasMPUInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function RoundUpToPowerOfTwo64(Value:TPasMPUInt64):TPasMPUInt64; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function RoundUpToPowerOfTwo(Value:TPasMPPtrUInt):TPasMPPtrUInt; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function RoundUpToMask32(Value,Mask:TPasMPUInt32):TPasMPUInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function RoundUpToMask64(Value,Mask:TPasMPUInt64):TPasMPUInt64; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function RoundUpToMask(Value,Mask:TPasMPPtrUInt):TPasMPPtrUInt; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPInterlocked=class
      public
       class function Increment(var Destination:TPasMPInt32):TPasMPInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Increment(var Destination:TPasMPUInt32):TPasMPUInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$ifdef CPU64}
       class function Increment(var Destination:TPasMPInt64):TPasMPInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Increment(var Destination:TPasMPUInt64):TPasMPUInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$endif}
       class function Decrement(var Destination:TPasMPInt32):TPasMPInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Decrement(var Destination:TPasMPUInt32):TPasMPUInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$ifdef CPU64}
       class function Decrement(var Destination:TPasMPInt64):TPasMPInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Decrement(var Destination:TPasMPUInt64):TPasMPUInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$endif}
       class function Add(var Destination:TPasMPInt32;const Value:TPasMPInt32):TPasMPInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Add(var Destination:TPasMPUInt32;const Value:TPasMPUInt32):TPasMPUInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$ifdef CPU64}
       class function Add(var Destination:TPasMPInt64;const Value:TPasMPInt64):TPasMPInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Add(var Destination:TPasMPUInt64;const Value:TPasMPUInt64):TPasMPUInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$endif}
       class function Sub(var Destination:TPasMPInt32;const Value:TPasMPInt32):TPasMPInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Sub(var Destination:TPasMPUInt32;const Value:TPasMPUInt32):TPasMPUInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$ifdef CPU64}
       class function Sub(var Destination:TPasMPInt64;const Value:TPasMPInt64):TPasMPInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Sub(var Destination:TPasMPUInt64;const Value:TPasMPUInt64):TPasMPUInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$endif}
       class procedure BitwiseAnd(var Destination:TPasMPInt32;const Value:TPasMPInt32); overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(cpu386) or defined(cpux86_64)}register;{$else}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}{$ifend}
       class procedure BitwiseAnd(var Destination:TPasMPUInt32;const Value:TPasMPUInt32); overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(cpu386) or defined(cpux86_64)}register;{$else}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}{$ifend}
{$ifdef CPU64}
       class procedure BitwiseAnd(var Destination:TPasMPInt64;const Value:TPasMPInt64); overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(cpux86_64)}register;{$else}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}{$ifend}
       class procedure BitwiseAnd(var Destination:TPasMPUInt64;const Value:TPasMPUInt64); overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(cpux86_64)}register;{$else}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}{$ifend}
{$endif}
       class procedure BitwiseOr(var Destination:TPasMPInt32;const Value:TPasMPInt32); overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(cpu386) or defined(cpux86_64)}register;{$else}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}{$ifend}
       class procedure BitwiseOr(var Destination:TPasMPUInt32;const Value:TPasMPUInt32); overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(cpu386) or defined(cpux86_64)}register;{$else}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}{$ifend}
{$ifdef CPU64}
       class procedure BitwiseOr(var Destination:TPasMPInt64;const Value:TPasMPInt64); overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(cpux86_64)}register;{$else}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}{$ifend}
       class procedure BitwiseOr(var Destination:TPasMPUInt64;const Value:TPasMPUInt64); overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(cpux86_64)}register;{$else}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}{$ifend}
{$endif}
       class procedure BitwiseXor(var Destination:TPasMPInt32;const Value:TPasMPInt32); overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(cpu386) or defined(cpux86_64)}register;{$else}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}{$ifend}
       class procedure BitwiseXor(var Destination:TPasMPUInt32;const Value:TPasMPUInt32); overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(cpu386) or defined(cpux86_64)}register;{$else}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}{$ifend}
{$ifdef CPU64}
       class procedure BitwiseXor(var Destination:TPasMPInt64;const Value:TPasMPInt64); overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(cpux86_64)}register;{$else}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}{$ifend}
       class procedure BitwiseXor(var Destination:TPasMPUInt64;const Value:TPasMPUInt64); overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(cpux86_64)}register;{$else}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}{$ifend}
{$endif}
       class function ExchangeBitwiseAnd(var Destination:TPasMPInt32;const Value:TPasMPInt32):TPasMPInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function ExchangeBitwiseAnd(var Destination:TPasMPUInt32;const Value:TPasMPUInt32):TPasMPUInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$ifdef CPU64}
       class function ExchangeBitwiseAnd(var Destination:TPasMPInt64;const Value:TPasMPInt64):TPasMPInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function ExchangeBitwiseAnd(var Destination:TPasMPUInt64;const Value:TPasMPUInt64):TPasMPUInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$endif}
       class function ExchangeBitwiseOr(var Destination:TPasMPInt32;const Value:TPasMPInt32):TPasMPInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function ExchangeBitwiseOr(var Destination:TPasMPUInt32;const Value:TPasMPUInt32):TPasMPUInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$ifdef CPU64}
       class function ExchangeBitwiseOr(var Destination:TPasMPInt64;const Value:TPasMPInt64):TPasMPInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function ExchangeBitwiseOr(var Destination:TPasMPUInt64;const Value:TPasMPUInt64):TPasMPUInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$endif}
       class function ExchangeBitwiseAndOr(var Destination:TPasMPInt32;const AndValue,OrValue:TPasMPInt32):TPasMPInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function ExchangeBitwiseAndOr(var Destination:TPasMPUInt32;const AndValue,OrValue:TPasMPUInt32):TPasMPUInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$ifdef CPU64}
       class function ExchangeBitwiseAndOr(var Destination:TPasMPInt64;const AndValue,OrValue:TPasMPInt64):TPasMPInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function ExchangeBitwiseAndOr(var Destination:TPasMPUInt64;const AndValue,OrValue:TPasMPUInt64):TPasMPUInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$endif}
       class function ExchangeBitwiseXor(var Destination:TPasMPInt32;const Value:TPasMPInt32):TPasMPInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function ExchangeBitwiseXor(var Destination:TPasMPUInt32;const Value:TPasMPUInt32):TPasMPUInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$ifdef CPU64}
       class function ExchangeBitwiseXor(var Destination:TPasMPInt64;const Value:TPasMPInt64):TPasMPInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function ExchangeBitwiseXor(var Destination:TPasMPUInt64;const Value:TPasMPUInt64):TPasMPUInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$endif}
       class function Exchange(var Destination:TPasMPInt32;const Source:TPasMPInt32):TPasMPInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Exchange(var Destination:TPasMPUInt32;const Source:TPasMPUInt32):TPasMPUInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$ifdef CPU64}
       class function Exchange(var Destination:TPasMPInt64;const Source:TPasMPInt64):TPasMPInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Exchange(var Destination:TPasMPUInt64;const Source:TPasMPUInt64):TPasMPUInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$endif}
       class function Exchange(var Destination:pointer;const Source:pointer):pointer; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Exchange(var Destination:TObject;const Source:TObject):TObject; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Exchange(var Destination:TPasMPBool32;const Source:TPasMPBool32):TPasMPBool32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function CompareExchange(var Destination:TPasMPInt32;const NewValue,Comperand:TPasMPInt32):TPasMPInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function CompareExchange(var Destination:TPasMPUInt32;const NewValue,Comperand:TPasMPUInt32):TPasMPUInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$if defined(CPU64) or ((defined(CPU386) or defined(CPUARM)) and defined(PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE))}
       class function CompareExchange(var Destination:TPasMPInt64;const NewValue,Comperand:TPasMPInt64):TPasMPInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function CompareExchange(var Destination:TPasMPInt64Record;const NewValue,Comperand:TPasMPInt64Record):TPasMPInt64Record; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function CompareExchange(var Destination:TPasMPUInt64;const NewValue,Comperand:TPasMPUInt64):TPasMPUInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$ifend}
{$if defined(CPU64) and defined(PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE)}
       class function CompareExchange(var Destination:TPasMPInt128Record;const NewValue,Comperand:TPasMPInt128Record):TPasMPInt128Record; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(fpc)}inline;{$ifend}
{$ifend}
       class function CompareExchange(var Destination:pointer;const NewValue,Comperand:pointer):pointer; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function CompareExchange(var Destination:TObject;const NewValue,Comperand:TObject):TObject; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function CompareExchange(var Destination:TPasMPBool32;const NewValue,Comperand:TPasMPBool32):TPasMPBool32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Read(var Source:TPasMPInt32):TPasMPInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Read(var Source:TPasMPUInt32):TPasMPUInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$if defined(CPU64) or ((defined(CPU386) or defined(CPUARM)) and defined(PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE))}
       class function Read(var Source:TPasMPInt64):TPasMPInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Read(var Source:TPasMPInt64Record):TPasMPInt64Record; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Read(var Source:TPasMPUInt64):TPasMPUInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$if defined(CPU64) and defined(PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE)}
       class function Read(var Source:TPasMPInt128Record):TPasMPInt128Record; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(fpc)}inline;{$ifend}
{$ifend}
{$ifend}
       class function Read(var Source:pointer):pointer; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Read(var Source:TObject):TObject; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Read(var Source:TPasMPBool32):TPasMPBool32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Write(var Destination:TPasMPInt32;const Source:TPasMPInt32):TPasMPInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Write(var Destination:TPasMPUInt32;const Source:TPasMPUInt32):TPasMPUInt32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$if defined(CPU64) or ((defined(CPU386) or defined(CPUARM)) and defined(PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE))}
       class function Write(var Destination:TPasMPInt64;const Source:TPasMPInt64):TPasMPInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Write(var Destination:TPasMPInt64Record;const Source:TPasMPInt64Record):TPasMPInt64Record; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Write(var Destination:TPasMPUInt64;const Source:TPasMPUInt64):TPasMPUInt64; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
{$if defined(CPU64) and defined(PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE)}
       class function Write(var Destination:TPasMPInt128Record;const Source:TPasMPInt128Record):TPasMPInt128Record; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(fpc)}inline;{$ifend}
{$ifend}
{$ifend}
       class function Write(var Destination:pointer;const Source:pointer):pointer; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Write(var Destination:TObject;const Source:TObject):TObject; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function Write(var Destination:TPasMPBool32;const Source:TPasMPBool32):TPasMPBool32; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPAtomic=class(TPasMPInterlocked);
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPMemoryBarrier=class
      public
       class procedure Read; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class procedure ReadDependency; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class procedure ReadWrite; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class procedure Write; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class procedure Sync; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPMemory=class
      public
       class procedure AllocateAlignedMemory(var p;Size:TPasMPInt32;Align:TPasMPInt32=PasMPCPUCacheLineSize); {$ifdef HAS_STATIC}static;{$endif}
       class procedure FreeAlignedMemory(const p); {$ifdef HAS_STATIC}static;{$endif}
       class procedure Barrier; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

     PPPasMPHighResolutionTime=^PPasMPHighResolutionTime;
     PPasMPHighResolutionTime=^TPasMPHighResolutionTime;
     TPasMPHighResolutionTime=TPasMPInt64;

     TPasMPHighResolutionTimer=class
      private
       fFrequency:TPasMPInt64;
       fFrequencyShift:TPasMPInt32;
       fMillisecondInterval:TPasMPHighResolutionTime;
       fTwoMillisecondsInterval:TPasMPHighResolutionTime;
       fFourMillisecondsInterval:TPasMPHighResolutionTime;
       fQuarterSecondInterval:TPasMPHighResolutionTime;
       fMinuteInterval:TPasMPHighResolutionTime;
       fHourInterval:TPasMPHighResolutionTime;
      public
       constructor Create;
       destructor Destroy; override;
       function GetTime:TPasMPInt64;
       procedure Sleep(const pDelay:TPasMPHighResolutionTime);
       function ToFloatSeconds(const pTime:TPasMPHighResolutionTime):double;
       function FromFloatSeconds(const pTime:double):TPasMPHighResolutionTime;
       function ToMilliseconds(const pTime:TPasMPHighResolutionTime):TPasMPInt64;
       function FromMilliseconds(const pTime:TPasMPInt64):TPasMPHighResolutionTime;
       function ToMicroseconds(const pTime:TPasMPHighResolutionTime):TPasMPInt64;
       function FromMicroseconds(const pTime:TPasMPInt64):TPasMPHighResolutionTime;
       function ToNanoseconds(const pTime:TPasMPHighResolutionTime):TPasMPInt64;
       function FromNanoseconds(const pTime:TPasMPInt64):TPasMPHighResolutionTime;
       property Frequency:TPasMPInt64 read fFrequency;
       property MillisecondInterval:TPasMPHighResolutionTime read fMillisecondInterval;
       property TwoMillisecondsInterval:TPasMPHighResolutionTime read fTwoMillisecondsInterval;
       property FourMillisecondsInterval:TPasMPHighResolutionTime read fFourMillisecondsInterval;
       property QuarterSecondInterval:TPasMPHighResolutionTime read fQuarterSecondInterval;
       property SecondInterval:TPasMPHighResolutionTime read fFrequency;
       property MinuteInterval:TPasMPHighResolutionTime read fMinuteInterval;
       property HourInterval:TPasMPHighResolutionTime read fHourInterval;
     end;

     TPasMP=class;

     PPasMPOnce=^TPasMPOnce;
     TPasMPOnce={$ifdef Linux}pthread_once_t{$else}TPasMPInt32{$endif};

     TPasMPOnceInitRoutine={$ifdef fpc}TProcedure{$else}procedure{$endif};

     TPasMPEvent=class(TEvent);

     TPasMPSimpleEvent=class(TPasMPEvent)
      public
       constructor Create;
     end;

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
{$if defined(fpc)}
     TPasMPCriticalSectionInstance=TRTLCriticalSection;
{$elseif defined(POSIX)}
     TPasMPCriticalSectionInstance=TObject;
{$else}
     TPasMPCriticalSectionInstance=TRTLCriticalSection;
{$ifend}
     TPasMPCriticalSection=class(TCriticalSection)
      protected
{$if not defined(Darwin)}
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-SizeOf(TPasMPCriticalSectionInstance))-1] of TPasMPUInt8;
{$ifend}
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPMutex=class(TSynchroObject)
{$if defined(Windows)}
      private
       fMutex:THandle;
      protected
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-SizeOf(TPasMPCriticalSectionInstance))-1] of TPasMPUInt8;
{$elseif defined(Unix)}
      private
       fMutex:pthread_mutex_t;
      protected
{$if not defined(Darwin)}
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-SizeOf(pthread_mutex_t))-1] of TPasMPUInt8;
{$ifend}
{$else}
      private
       fCriticalSection:TPasMPCriticalSection;
      protected
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-SizeOf(TPasMPCriticalSection))-1] of TPasMPUInt8;
{$ifend}
      public
       constructor Create; overload;
{$if defined(Unix)}
       constructor Create(const lpMutexAttributes:pointer); overload;
{$elseif defined(Windows)}
       constructor Create(const lpMutexAttributes:pointer;const bInitialOwner:boolean;const lpName:string); overload;
       constructor Create(const DesiredAccess:TPasMPUInt32;const bInitialOwner:boolean;const lpName:string); overload;
{$ifend}
       destructor Destroy; override;
       procedure Acquire; override;
       procedure Release; override;
{$if defined(Windows)}
       property Mutex:THandle read fMutex;
{$elseif defined(Unix)}
       property Mutex:pthread_mutex_t read fMutex;
{$else}
       property CriticalSection:TPasMPCriticalSection read fCriticalSection;
{$ifend}
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPConditionVariableLock=class(TSynchroObject)
{$if defined(Windows)}
      private
       fCriticalSection:TRTLCriticalSection;
      protected
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-SizeOf(TRTLCriticalSection))-1] of TPasMPUInt8;
{$elseif defined(Unix)}
      private
       fMutex:pthread_mutex_t;
      protected
{$if not defined(Darwin)}
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-SizeOf(pthread_mutex_t))-1] of TPasMPUInt8;
{$ifend}
{$else}
      private
       fCriticalSection:TPasMPCriticalSection;
      protected
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-SizeOf(TPasMPCriticalSection))-1] of TPasMPUInt8;
{$ifend}
      public
       constructor Create;
       destructor Destroy; override;
       procedure Acquire; override;
       procedure Release; override;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$ifdef Windows}
     PPasMPConditionVariableData=^TPasMPConditionVariableData;
     TPasMPConditionVariableData=pointer;
{$endif}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPConditionVariable=class
{$if defined(Windows)}
      private
       fConditionVariable:TPasMPConditionVariableData;
      protected
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-SizeOf(TPasMPConditionVariableData))-1] of TPasMPUInt8;
{$elseif defined(Unix)}
      private
       fConditionVariable:pthread_cond_t;
       fConditionVariableAttributes:pthread_condattr_t;
       fHasConditionVariableAttributes:TPasMPBool32;
       fClockID:TPasMPInt32;
      protected
       fCacheLineFillUp:array[0..((PasMPCPUCacheLineSize*2)-(SizeOf(pthread_cond_t)+SizeOf(pthread_condattr_t)+SizeOf(TPasMPBool32)+SizeOf(TPasMPInt32)))-1] of TPasMPUInt8;
{$else}
      private
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fWaitCounter:TPasMPInt32;
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fReleaseCounter:TPasMPInt32;
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fGenerationCounter:TPasMPInt32;
       fCriticalSection:TPasMPCriticalSection;
       fEvent:TPasMPEvent;
      protected
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-((SizeOf(TPasMPInt32)*3)+SizeOf(TPasMPCriticalSection)+SizeOf(TPasMPEvent)))-1] of TPasMPUInt8;
{$ifend}
      public
       constructor Create;
       destructor Destroy; override;
       procedure Signal; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       procedure Broadcast; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       function Wait(const Lock:TPasMPConditionVariableLock;const dwMilliSeconds:TPasMPUInt32=INFINITE):TWaitResult; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPSemaphore=class(TSynchroObject)
      private
       fInitialCount:TPasMPInt32;
       fMaximumCount:TPasMPInt32;
{$if defined(Windows)}
       fHandle:THandle;
      protected
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-((SizeOf(TPasMPInt32)*2)+SizeOf(THandle)))-1] of TPasMPUInt8;
{$elseif defined(Unix)}
       fHandle:{$ifdef fpc}TPasMPInt32{$else}sem_t{$endif};
      protected
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-((SizeOf(TPasMPInt32)*2)+SizeOf({$ifdef fpc}TPasMPInt32{$else}sem_t{$endif})))-1] of TPasMPUInt8;
{$else}
{$define PasMPSemaphoreUseConditionVariable}
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fCurrentCount:TPasMPInt32;
{$ifdef PasMPSemaphoreUseConditionVariable}
       fConditionVariableLock:TPasMPConditionVariableLock;
       fConditionVariable:TPasMPConditionVariable;
{$else}
       fCriticalSection:TPasMPCriticalSection;
       fEvent:TPasMPEvent;
{$endif}
      protected
{$ifdef PasMPSemaphoreUseConditionVariable}
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-((SizeOf(TPasMPInt32)*3)+SizeOf(TPasMPConditionVariableLock)+SizeOf(TPasMPConditionVariable)))-1] of TPasMPUInt8;
{$else}
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-((SizeOf(TPasMPInt32)*3)+SizeOf(TPasMPCriticalSection)+SizeOf(TPasMPEvent)))-1] of TPasMPUInt8;
{$endif}
{$ifend}
      public
       constructor Create(const InitialCount,MaximumCount:TPasMPInt32);
       destructor Destroy; override;
       procedure Acquire; overload; override;
       procedure Release; overload; override;
       function Acquire(const AcquireCount:TPasMPInt32):TWaitResult; reintroduce; overload;
       function Release(const ReleaseCount:TPasMPInt32):TPasMPInt32; reintroduce; overload;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPInvertedSemaphore=class(TSynchroObject)
      private
       fInitialCount:TPasMPInt32;
       fMaximumCount:TPasMPInt32;
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fCurrentCount:TPasMPInt32;
       fConditionVariableLock:TPasMPConditionVariableLock;
       fConditionVariable:TPasMPConditionVariable;
      protected
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-((SizeOf(TPasMPInt32)*3)+SizeOf(TPasMPConditionVariableLock)+SizeOf(TPasMPConditionVariable)))-1] of TPasMPUInt8;
      public
       constructor Create(const InitialCount,MaximumCount:TPasMPInt32);
       destructor Destroy; override;
       procedure Acquire; overload; override; // Acquire a number of resource elements. It never blocks.
       procedure Release; overload; override; // Release a number of resource elements. It never blocks, but it may wake up waiting threads.
       function Acquire(const AcquireCount:TPasMPInt32;out Count:TPasMPInt32):TPasMPInt32; reintroduce; overload;
       function Release(const ReleaseCount:TPasMPInt32;out Count:TPasMPInt32):TPasMPInt32; reintroduce; overload;
       function Wait(const dwMilliSeconds:TPasMPUInt32=INFINITE):TWaitResult; // Block until the inverted semaphore reaches zero
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$ifdef Windows}
     PPasMPSRWLock=^TPasMPSRWLock;
     TPasMPSRWLock=pointer;
{$endif}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPMultipleReaderSingleWriterLock=class(TInterfacedObject,IReadWriteSync)
{$if defined(Windows)}
      private
       fSRWLock:TPasMPSRWLock;
      protected
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-SizeOf(TPasMPSRWLock))-1] of TPasMPUInt8;
{$elseif defined(Unix)}
      private
       fReadWriteLock:pthread_rwlock_t;
      protected
{$if not (defined(CPUAArch64) or defined(Darwin))}
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-SizeOf(pthread_rwlock_t))-1] of TPasMPUInt8;
{$ifend}
{$else}
      private
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fReaders:TPasMPInt32;
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fWriters:TPasMPInt32;
       fConditionVariableLock:TPasMPConditionVariableLock;
       fConditionVariable:TPasMPConditionVariable;
      protected
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-((SizeOf(TPasMPInt32)*2)+SizeOf(TPasMPConditionVariableLock)+SizeOf(TPasMPConditionVariable)))-1] of TPasMPUInt8;
{$ifend}
      public
       constructor Create;
       destructor Destroy; override;
       procedure AcquireRead; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       function TryAcquireRead:boolean; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       procedure ReleaseRead; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       procedure AcquireWrite; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       function TryAcquireWrite:boolean; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       procedure ReleaseWrite; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       procedure ReadToWrite; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       procedure WriteToRead; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       procedure BeginRead;
       procedure EndRead;
       function BeginWrite:boolean;
       procedure EndWrite;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPMultipleReaderSingleWriterSpinLock=class(TInterfacedObject,IReadWriteSync)
      private
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fState:TPasMPInt32;
      protected
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-((SizeOf(TPasMPInt32)*2)+SizeOf(TPasMPConditionVariableLock)+SizeOf(TPasMPConditionVariable)))-1] of TPasMPUInt8;
      public
       constructor Create;
       destructor Destroy; override;
       procedure AcquireRead; overload; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       function TryAcquireRead:boolean; overload; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       procedure ReleaseRead; overload; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       procedure AcquireWrite; overload; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       function TryAcquireWrite:boolean; overload; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       procedure ReleaseWrite; overload; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       procedure ReadToWrite; overload; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       procedure WriteToRead; overload; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       procedure BeginRead;
       procedure EndRead;
       function BeginWrite:boolean;
       procedure EndWrite;
       class procedure AcquireRead(var LockState:TPasMPInt32); overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function TryAcquireRead(var LockState:TPasMPInt32):boolean; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class procedure ReleaseRead(var LockState:TPasMPInt32); overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class procedure AcquireWrite(var LockState:TPasMPInt32); overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class function TryAcquireWrite(var LockState:TPasMPInt32):boolean; overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class procedure ReleaseWrite(var LockState:TPasMPInt32); overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class procedure ReadToWrite(var LockState:TPasMPInt32); overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
       class procedure WriteToRead(var LockState:TPasMPInt32); overload; {$ifdef HAS_STATIC}static;{$endif}{$if defined(HAS_ATOMICS) or defined(fpc)}inline;{$ifend}
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPSlimReaderWriterLock=class(TSynchroObject)
{$if defined(Windows)}
      private
       fSRWLock:TPasMPSRWLock;
      protected
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-SizeOf(TPasMPSRWLock))-1] of TPasMPUInt8;
{$elseif defined(Unix)}
      private
       fReadWriteLock:pthread_rwlock_t;
      protected
{$if not (defined(CPUAArch64) or defined(Darwin))}
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-SizeOf(pthread_rwlock_t))-1] of TPasMPUInt8;
{$ifend}
{$else}
      private
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fCount:TPasMPInt32;
       fConditionVariableLock:TPasMPConditionVariableLock;
       fConditionVariable:TPasMPConditionVariable;
      protected
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-(SizeOf(TPasMPInt32)+SizeOf(TPasMPConditionVariableLock)+SizeOf(TPasMPConditionVariable)))-1] of TPasMPUInt8;
{$ifend}
      public
       constructor Create;
       destructor Destroy; override;
       procedure Acquire; override;
       function TryAcquire:boolean;
       procedure Release; override;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$if defined(PasMPPThreadSpinLock)}
{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     PPasMPSpinLockPThreadSpinLock=^TPasMPSpinLockPThreadSpinLock;
{$ifdef Android}
     TPasMPSpinLockPThreadSpinLock=TPasMPInt32;
{$else}
     TPasMPSpinLockPThreadSpinLock=pthread_spinlock_t;
{$endif}
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
{$ifend}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPSpinLock=class(TSynchroObject)
{$if defined(PasMPPThreadSpinLock)}
      private
       fSpinLock:TPasMPSpinLockPThreadSpinLock;
      protected
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-SizeOf(TPasMPSpinLockPThreadSpinLock))-1] of TPasMPUInt8;
{$else}
      private
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fState:TPasMPInt32;
      protected
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-SizeOf(TPasMPInt32))-1] of TPasMPUInt8;
{$ifend}
      public
       constructor Create;
       destructor Destroy; override;
       procedure Acquire; override;
       function TryAcquire:longbool; {$if not defined(Unix)}{$if defined(cpu386) or defined(cpux86_64)}register;{$else}{$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}{$ifend}{$ifend}
       procedure Release; override;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPBenaphore=class(TSynchroObject)
      private
       fSemaphore:TPasMPSemaphore;
       fLockCount:TPasMPUInt32;
      protected
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-(SizeOf(TPasMPSemaphore)+SizeOf(TPasMPUInt32)))-1] of TPasMPUInt8;
      public
       constructor Create;
       destructor Destroy; override;
       procedure Acquire; override;
       function TryAcquire:longbool; {$if not defined(Unix)}{$if defined(cpu386) or defined(cpux86_64)}register;{$else}{$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}{$ifend}{$ifend}
       procedure Release; override;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

     EPasMPRecursiveBenaphore=class(Exception);

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPRecursiveBenaphore=class(TSynchroObject)
      private
       fSemaphore:TPasMPSemaphore;
       fOwningThreadID:{$ifdef fpc}TThreadID{$else}TPasMPUInt32{$endif};
       fLockCount:TPasMPUInt32;
       fRecursionCount:TPasMPUInt32;
      protected
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-(SizeOf(TPasMPSemaphore)+SizeOf({$ifdef fpc}TThreadID{$else}TPasMPUInt32{$endif})+(SizeOf(TPasMPUInt32)*2)))-1] of TPasMPUInt8;
      public
       constructor Create;
       destructor Destroy; override;
       procedure Acquire; override;
       function TryAcquire:longbool; {$if not defined(Unix)}{$if defined(cpu386) or defined(cpux86_64)}register;{$else}{$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}{$ifend}{$ifend}
       procedure Release; override;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$if defined(PasMPPThreadBarrier)}
{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     PPasMPSpinLockPThreadBarrier=^TPasMPSpinLockPThreadBarrier;
{$if defined(Android)}
     PPasMPSpinLockPThreadFastLock=^TPasMPSpinLockPThreadFastLock;
     TPasMPSpinLockPThreadFastLock={$ifdef fpc}_pthread_fastlock{$else}record
      __status:TPasMPInt32;
      __spinlock:TPasMPInt32;
     end{$endif};
     TPasMPSpinLockPThreadBarrier=record
      __ba_lock:TPasMPSpinLockPThreadFastLock;
      __ba_required:TPasMPInt32;
      __ba_present:TPasMPInt32;
      __ba_waiting:pointer{_pthread_descr};
     end;
{$else}
     TPasMPSpinLockPThreadBarrier=pthread_barrier_t;
{$ifend}
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
{$ifend}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPBarrier=class
{$if defined(PasMPPThreadBarrier)}
      private
       fBarrier:TPasMPSpinLockPThreadBarrier;
      protected
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-SizeOf(TPasMPSpinLockPThreadBarrier))-1] of TPasMPUInt8;
{$else}
      private
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fCount:TPasMPInt32;
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fTotal:TPasMPInt32;
       fConditionVariableLock:TPasMPConditionVariableLock;
       fConditionVariable:TPasMPConditionVariable;
      protected
       fCacheLineFillUp:array[0..(PasMPCPUCacheLineSize-((SizeOf(TPasMPInt32)*2)+SizeOf(TPasMPConditionVariableLock)+SizeOf(TPasMPConditionVariable)))-1] of TPasMPUInt8;
{$ifend}
      public
       constructor Create(const Count:TPasMPInt32);
       destructor Destroy; override;
       function Wait:boolean; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

     PPasMPThreadSafeStackEntry=^TPasMPThreadSafeStackEntry;
     TPasMPThreadSafeStackEntry=pointer;

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     // The lock-free variant is based on the idea behind the concept of the internal workings of the "Interlocked Singly Linked Lists" Windows API, just stripped by the Depth stuff
     // The lock-based variant is based of my head
     TPasMPThreadSafeStack=class // only for PasMP internal usage
      private
{$ifdef PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}
       fHead:PPasMPTaggedPointer;
{$else}
       fCriticalSection:TPasMPCriticalSection;
       fHead:pointer;
{$endif}
      public
       constructor Create;
       destructor Destroy; override;
       procedure Clear; {$ifdef CAN_INLINE}inline;{$endif}
       function IsEmpty:boolean; {$ifdef CAN_INLINE}inline;{$endif}
       function Push(const Item:pointer):pointer; {$ifdef CAN_INLINE}inline;{$endif}
       function Pop:pointer; {$ifdef CAN_INLINE}inline;{$endif}
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

     PPasMPThreadSafeQueueNode=^TPasMPThreadSafeQueueNode;
     TPasMPThreadSafeQueueNode=record
{$ifdef PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}
      Previous:TPasMPTaggedPointer;
      Next:TPasMPTaggedPointer;
{$else}
      Next:pointer;
{$endif}
      Data:record
       // Empty
      end;
     end;

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
{$define PASMP_USE_OPTIMISTIC_FIFO_QUEUE}
{$ifdef PASMP_USE_OPTIMISTIC_FIFO_QUEUE}
     // The lock-free variant is based on http://people.csail.mit.edu/edya/publications/OptimisticFIFOQueue-journal.pdf
{$else}
     // The lock-free variant is based on M. M. Michael and M. L. Scott "Simple, fast, and practical non-blocking and blocking concurrent queue algorithms" together with tagged pointer counters
{$endif}
     // The lock-based variant is based on the two-lock concurrent queue
     TPasMPThreadSafeQueue=class // only for PasMP internal usage
      private
{$ifdef PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}
       fHead:PPasMPTaggedPointer;
       fTail:PPasMPTaggedPointer;
{$else}
       fHeadCriticalSection:TPasMPCriticalSection;
       fTailCriticalSection:TPasMPCriticalSection;
       fHead:PPasMPThreadSafeQueueNode;
       fTail:PPasMPThreadSafeQueueNode;
{$endif}
       fItemSize:TPasMPInt32;
       fInternalNodeSize:TPasMPInt32;
       fAddCPUCacheLinePaddingToInternalItemDataStructure:boolean;
      protected
       procedure InitializeItem(const Data:pointer); virtual;
       procedure FinalizeItem(const Data:pointer); virtual;
       procedure CopyItem(const Source,Destination:pointer); virtual;
      public
       constructor Create(ItemSize:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
       destructor Destroy; override;
       procedure Clear; {$ifndef PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       function IsEmpty:boolean; {$ifdef CAN_INLINE}inline;{$endif}
       procedure Enqueue(const Item); {$ifndef PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       function Dequeue(out Item):boolean; {$ifndef PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

     PPasMPThreadSafeBoundedArrayBasedQueueItemNode=^TPasMPThreadSafeBoundedArrayBasedQueueItemNode;
     TPasMPThreadSafeBoundedArrayBasedQueueItemNode=record
      Sequence:TPasMPUInt32;
      Data:record
       // Empty
      end;
     end;

     EPasMPThreadSafeBoundedArrayBasedQueue=class(Exception);

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPThreadSafeBoundedArrayBasedQueue=class // only for TPasMP internal usage
      private
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fData:pointer;
       fMaximalCount:TPasMPUInt32;
       fMask:TPasMPUInt32;
       fItemSize:TPasMPUInt32;
       fInternalItemSize:TPasMPUInt32;
      protected
       fCacheLineFillUp0:array[0..(PasMPCPUCacheLineSize-(SizeOf(pointer)+(SizeOf(TPasMPUInt32)*4)))-1] of TPasMPUInt8; // for to force fields to different CPU cache lines
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fHeadSequence:TPasMPUInt32;
       fCacheLineFillUp1:array[0..(PasMPCPUCacheLineSize-SizeOf(TPasMPUInt32))-1] of TPasMPUInt8; // for to force fields to different CPU cache lines
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fTailSequence:TPasMPUInt32;
       fCacheLineFillUp2:array[0..(PasMPCPUCacheLineSize-SizeOf(TPasMPUInt32))-1] of TPasMPUInt8; // for to force fields to different CPU cache lines
      protected
       procedure InitializeItem(const Data:pointer); virtual;
       procedure FinalizeItem(const Data:pointer); virtual;
       procedure CopyItem(const Source,Destination:pointer); virtual;
      public
       constructor Create(const MaximalCount,ItemSize:TPasMPUInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
       destructor Destroy; override;
       procedure Clear;
       function IsEmpty:boolean;
       function IsFull:boolean;
       function Enqueue(const Item):boolean;
       function Dequeue(out Item):boolean;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

     TPasMPThreadSafeHashTableHash=TPasMPUInt32;

     PPasMPThreadSafeHashTableItem=^TPasMPThreadSafeHashTableItem;
     TPasMPThreadSafeHashTableItem=record
      case TPasMPInt32 of
       0:(
        Lock:TPasMPInt32;
        State:TPasMPInt32;
        Hash:TPasMPThreadSafeHashTableHash;
        Data:record
         // Empty
        end;
       );
       1:(
        LockState:TPasMPInt64Record;
       );
     end;

     PPasMPThreadSafeHashTableState=^TPasMPThreadSafeHashTableState;
     TPasMPThreadSafeHashTableState=record
      case TPasMPInt32 of
       0:(
        Previous:PPasMPThreadSafeHashTableState;
        Next:PPasMPThreadSafeHashTableState;
        ReferenceCounter:TPasMPInt32;
        Version:TPasMPInt32;
        Size:TPasMPInt32;
        Mask:TPasMPInt32;
        LogSize:TPasMPInt32;
        Count:TPasMPInt32;
        Items:pointer;
       );
       1:(
        FillUp:array[0..(PasMPCPUCacheLineSize*(SizeOf(TPasMPPtrUInt) div SizeOf(TPasMPUInt32)))-1] of TPasMPUInt8;
       );
     end;

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     // A thread-safe hash table with open addressing and double-hashing-like probing (two values from one single hash value)
     // The read operation is almost lock-free until the read-acquisition of the multiple-reader-single-writer-lock of a hash item,
     // since a item value can larger than one and two native maschine words
     // The write operations are almost multiple-reader-single-writer-lock-based
     // Why not complete lock-free? => Because TPasMPThreadSafeHashTable should be universal usable independently by the key and
     // value data types and also key-and-value-object-reference-counting-free as much as possble.
     TPasMPThreadSafeHashTable=class // only for PasMP internal usage
      private
       fCriticalSection:TPasMPCriticalSection;
       fLock:TPasMPMultipleReaderSingleWriterSpinLock;
       fResizeLock:TPasMPMultipleReaderSingleWriterSpinLock;
       fItemSize:TPasMPInt32;
       fInternalItemSize:TPasMPInt32;
       fGrowLoadFactor:TPasMPInt32; // 24.7 bit fixed point
       fFirstState:PPasMPThreadSafeHashTableState;
       fLastState:PPasMPThreadSafeHashTableState;
       fVersion:TPasMPInt32;
       function GetGrowLoadFactor:single;
       procedure SetGrowLoadFactor(const NewGrowLoadFactor:single);
       function CreateState:PPasMPThreadSafeHashTableState;
       procedure FreeState(const State:PPasMPThreadSafeHashTableState);
       function AcquireState:PPasMPThreadSafeHashTableState; {$ifdef CAN_INLINE}inline;{$endif}
       procedure ReleaseState(const State:PPasMPThreadSafeHashTableState); {$ifdef CAN_INLINE}inline;{$endif}
       procedure Clear;
       function SetKeyValueOnState(const CurrentState:PPasMPThreadSafeHashTableState;const Key,Value:pointer):boolean;
       function UnderGrowLoadFactor(const CurrentState:PPasMPThreadSafeHashTableState):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       procedure Grow;
      protected
       procedure InitializeItem(const Data:pointer); virtual;
       procedure FinalizeItem(const Data:pointer); virtual;
       procedure CopyItem(const Source,Destination:pointer); virtual;
       procedure GetKey(const Data,Key:pointer); virtual;
       procedure SetKey(const Data,Key:pointer); virtual;
       procedure GetValue(const Data,Value:pointer); virtual;
       procedure SetValue(const Data,Value:pointer); virtual;
       function HashKey(const Key:pointer):TPasMPThreadSafeHashTableHash; virtual;
       function CompareKey(const Data,Key:pointer):boolean; virtual;
       function GetKeyValue(const Key,Value:pointer):boolean;
       function SetKeyValue(const Key,Value:pointer):boolean;
       function DeleteKey(const Key:pointer):boolean;
      public
       constructor Create(const ItemSize:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
       destructor Destroy; override;
       property GrowLoadFactor:single read GetGrowLoadFactor write SetGrowLoadFactor;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

     PPasMPThreadSafeDynamicArrayBuckets=^TPasMPThreadSafeDynamicArrayBuckets;
     TPasMPThreadSafeDynamicArrayBuckets=array[0..PasMPThreadSafeDynamicArrayNumberOfBuckets-1] of pointer;

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPThreadSafeDynamicArray=class // only for PasMP internal usage
      private
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fSize:TPasMPInt32;
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fItemSize:TPasMPInt32;
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fItemLockOffset:TPasMPInt32;
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fInternalItemSize:TPasMPInt32;
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fAllocated:TPasMPInt32;
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fCountBuckets:TPasMPInt32;
       fLock:TPasMPMultipleReaderSingleWriterSpinLock;
       fBuckets:TPasMPThreadSafeDynamicArrayBuckets;
      protected
       procedure InitializeItem(const ItemData:pointer); virtual;
       procedure FinalizeItem(const ItemData:pointer); virtual;
       procedure CopyItem(const Source,Destination:pointer); virtual;
       procedure SetSize(const NewSize:TPasMPInt32);
       function GetItem(const ItemIndex:TPasMPInt32;const ItemData:pointer):boolean;
       function SetItem(const ItemIndex:TPasMPInt32;const ItemData:pointer):boolean;
       function Push(const ItemData:pointer):TPasMPInt32;
       function Pop(const ItemData:pointer):boolean;
      public
       constructor Create(const aItemSize:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
       destructor Destroy; override;
       procedure Clear; virtual;
       property Size:TPasMPInt32 read fSize write SetSize;
       property ItemSize:TPasMPInt32 read fItemSize;
       property Allocated:TPasMPInt32 read fAllocated;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPSingleProducerSingleConsumerRingBuffer=class
      protected
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fReadIndex:TPasMPInt32;
       fCacheLineFillUp0:array[0..(PasMPCPUCacheLineSize-SizeOf(TPasMPInt32))-1] of TPasMPUInt8; // for to force fReadIndex and fWriteIndex to different CPU cache lines
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fWriteIndex:TPasMPInt32;
       fCacheLineFillUp1:array[0..(PasMPCPUCacheLineSize-SizeOf(TPasMPInt32))-1] of TPasMPUInt8; // for to force fWriteIndex and fData to different CPU cache lines
       fData:array of TPasMPUInt8;
       fSize:TPasMPInt32;
       fLockState:TPasMPInt32;
       fCacheLineFillUp2:array[0..(PasMPCPUCacheLineSize-(SizeOf(pointer)+SizeOf(TPasMPInt32)+SizeOf(TPasMPInt32)))-1] of TPasMPUInt8; // as CPU cache line alignment
      public
       constructor Create(const Size:TPasMPInt32);
       destructor Destroy; override;
       procedure Clear;
       function Read(const Buffer:pointer;Bytes:TPasMPInt32):TPasMPInt32;
       function TryRead(const Buffer:pointer;Bytes:TPasMPInt32):TPasMPInt32;
       function ReadAsMuchAsPossible(const Buffer:pointer;Bytes:TPasMPInt32):TPasMPInt32;
       function Write(const Buffer:pointer;Bytes:TPasMPInt32):TPasMPInt32;
       function TryWrite(const Buffer:pointer;Bytes:TPasMPInt32):TPasMPInt32;
       function WriteAsMuchAsPossible(const Buffer:pointer;Bytes:TPasMPInt32):TPasMPInt32;
       function AvailableForRead:TPasMPInt32;
       function AvailableForWrite:TPasMPInt32;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPSingleProducerSingleConsumerBoundedQueue=class
      protected
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fReadIndex:TPasMPInt32;
       fCacheLineFillUp0:array[0..(PasMPCPUCacheLineSize-SizeOf(TPasMPInt32))-1] of TPasMPUInt8; // for to force fReadIndex and fWriteIndex to different CPU cache lines
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fWriteIndex:TPasMPInt32;
       fCacheLineFillUp1:array[0..(PasMPCPUCacheLineSize-SizeOf(TPasMPInt32))-1] of TPasMPUInt8; // for to force fWriteIndex and fData to different CPU cache lines
       fData:array of TPasMPUInt8;
       fMaximalCount:TPasMPInt32;
       fItemSize:TPasMPInt32;
       fCacheLineFillUp2:array[0..(PasMPCPUCacheLineSize-(SizeOf(pointer)+SizeOf(TPasMPInt32)))-1] of TPasMPUInt8; // as CPU cache line alignment
      public
       constructor Create(const MaximalCount,ItemSize:TPasMPInt32);
       destructor Destroy; override;
       function Enqueue(const Item):boolean;
       function Dequeue(out Item):boolean;
       function AvailableForEnqueue:TPasMPInt32;
       function AvailableForDequeue:TPasMPInt32;
       function IsFull:boolean;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$ifdef HAS_GENERICS}
{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPSingleProducerSingleConsumerBoundedQueue<T>=class
      protected
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fReadIndex:TPasMPInt32;
       fCacheLineFillUp0:array[0..(PasMPCPUCacheLineSize-SizeOf(TPasMPInt32))-1] of TPasMPUInt8; // for to force fReadIndex and fWriteIndex to different CPU cache lines
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fWriteIndex:TPasMPInt32;
       fCacheLineFillUp1:array[0..(PasMPCPUCacheLineSize-SizeOf(TPasMPInt32))-1] of TPasMPUInt8; // for to force fWriteIndex and fData to different CPU cache lines
       fData:array of T;
       fMaximalCount:TPasMPInt32;
       fCacheLineFillUp2:array[0..(PasMPCPUCacheLineSize-(SizeOf(pointer)+SizeOf(TPasMPInt32)))-1] of TPasMPUInt8; // as CPU cache line alignment
      public
       constructor Create(const MaximalCount:TPasMPInt32);
       destructor Destroy; override;
       function Enqueue(const Item:T):boolean;
       function Dequeue(out Item:T):boolean;
       function AvailableForEnqueue:TPasMPInt32;
       function AvailableForDequeue:TPasMPInt32;
       function IsFull:boolean;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
{$endif}

     PPasMPBoundedStackItem=^TPasMPBoundedStackItem;
     TPasMPBoundedStackItem=record
      Next:TPasMPThreadSafeStackEntry;
      Data:record
       // Empty
      end;
     end;

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPBoundedStack=class
      private
       fStack:TPasMPThreadSafeStack;
       fFree:TPasMPThreadSafeStack;
       fData:pointer;
       fMaximalCount:TPasMPInt32;
       fItemSize:TPasMPInt32;
       fInternalItemSize:TPasMPInt32;
      public
       constructor Create(const MaximalCount,ItemSize:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
       destructor Destroy; override;
       function IsEmpty:boolean;
       function IsFull:boolean;
       function Push(const Item):boolean;
       function Pop(out Item):boolean;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$ifdef HAS_GENERICS}
{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPBoundedStack<T>=class
      private
       type PPasMPBoundedTypedStackItem=^TPasMPBoundedTypedStackItem;
            TPasMPBoundedTypedStackItem=record
             Next:TPasMPThreadSafeStackEntry;
             Data:T;
            end;
      private
       fStack:TPasMPThreadSafeStack;
       fFree:TPasMPThreadSafeStack;
       fData:pointer;
       fMaximalCount:TPasMPInt32;
       fInternalItemSize:TPasMPInt32;
      public
       constructor Create(const MaximalCount:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
       destructor Destroy; override;
       function IsEmpty:boolean;
       function IsFull:boolean;
       function Push(const Item:T):boolean;
       function Pop(out Item:T):boolean;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
{$endif}

     PPasMPUnboundedStackItem=^TPasMPUnboundedStackItem;
     TPasMPUnboundedStackItem=record
      Next:TPasMPThreadSafeStackEntry;
      Data:record
       // Empty
      end;
     end;

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPUnboundedStack=class
      private
       fStack:TPasMPThreadSafeStack;
       fItemSize:TPasMPInt32;
       fAddCPUCacheLinePaddingToInternalItemDataStructure:boolean;
      public
       constructor Create(const ItemSize:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
       destructor Destroy; override;
       function IsEmpty:boolean;
       function Push(const Item):boolean;
       function Pop(out Item):boolean;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$ifdef HAS_GENERICS}
{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPUnboundedStack<T>=class
      private
       type PPasMPUnboundedTypedStackItem=^TPasMPUnboundedTypedStackItem;
            TPasMPUnboundedTypedStackItem=record
             Next:TPasMPThreadSafeStackEntry;
             Data:T;
            end;
      private
       fStack:TPasMPThreadSafeStack;
       fItemSize:TPasMPInt32;
       fAddCPUCacheLinePaddingToInternalItemDataStructure:boolean;
      public
       constructor Create(const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
       destructor Destroy; override;
       function IsEmpty:boolean;
       function Push(const Item:T):boolean;
       function Pop(out Item:T):boolean;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
{$endif}

     PPasMPBoundedQueueItem=^TPasMPBoundedQueueItem;
     TPasMPBoundedQueueItem=record
      Next:TPasMPThreadSafeStackEntry;
      Data:record
       // Empty
      end;
     end;

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPBoundedQueue=class
      private
       fQueue:TPasMPThreadSafeQueue;
       fFree:TPasMPThreadSafeStack;
       fData:pointer;
       fMaximalCount:TPasMPInt32;
       fItemSize:TPasMPInt32;
       fInternalItemSize:TPasMPInt32;
      public
       constructor Create(const MaximalCount,ItemSize:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
       destructor Destroy; override;
       function IsEmpty:boolean;
       function IsFull:boolean;
       function Enqueue(const Item):boolean;
       function Dequeue(out Item):boolean;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$ifdef HAS_GENERICS}
{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPBoundedQueue<T>=class
      private
       type PPasMPBoundedTypedQueueItem=^TPasMPBoundedTypedQueueItem;
            TPasMPBoundedTypedQueueItem=record
             Next:TPasMPThreadSafeStackEntry;
             Data:T;
            end;
      private
       fQueue:TPasMPThreadSafeQueue;
       fFree:TPasMPThreadSafeStack;
       fData:pointer;
       fMaximalCount:TPasMPInt32;
       fInternalItemSize:TPasMPInt32;
      public
       constructor Create(const MaximalCount:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
       destructor Destroy; override;
       function IsEmpty:boolean;
       function IsFull:boolean;
       function Enqueue(const Item:T):boolean;
       function Dequeue(out Item:T):boolean;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
{$endif}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPBoundedArrayBasedQueue=class(TPasMPThreadSafeBoundedArrayBasedQueue)
      public
       constructor Create(const MaximalCount,ItemSize:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true); reintroduce;
       destructor Destroy; override;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$ifdef HAS_GENERICS}
{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPBoundedArrayBasedQueue<T>=class(TPasMPThreadSafeBoundedArrayBasedQueue)
      protected
       procedure InitializeItem(const Data:pointer); override;
       procedure FinalizeItem(const Data:pointer); override;
       procedure CopyItem(const Source,Destination:pointer); override;
      public
       constructor Create(const MaximalCount:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true); reintroduce;
       destructor Destroy; override;
       function Enqueue(const Item:T):boolean; reintroduce;
       function Dequeue(out Item:T):boolean; reintroduce;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
{$endif}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPUnboundedQueue=class(TPasMPThreadSafeQueue)
      public
       constructor Create(const ItemSize:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true); reintroduce;
       destructor Destroy; override;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$ifdef HAS_GENERICS}
{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPUnboundedQueue<T>=class(TPasMPThreadSafeQueue)
      protected
       procedure InitializeItem(const Data:pointer); override;
       procedure FinalizeItem(const Data:pointer); override;
       procedure CopyItem(const Source,Destination:pointer); override;
      public
       constructor Create(const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true); reintroduce;
       destructor Destroy; override;
       procedure Enqueue(const Item:T); reintroduce;
       function Dequeue(out Item:T):boolean; reintroduce;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
{$endif}

{$ifdef HAS_GENERICS}
{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPMultipleProducerMultipleConsumerQueue<T>=class
      public
       type TSlot=record
             public
              fTurn:TPasMPSizeUIntEx;
              fPadding1:array[0..(PasMPCPUCacheLineSize-SizeOf(TPasMPSizeUIntEx))-1] of TPasMPUInt8;
              fData:T;
            end;
            PSlot=^TSlot;
            TSlotDynamicArray=array of TSlot;
      private
       fCapacity:TPasMPSizeUIntEx;
       fSlots:TSlotDynamicArray;
       fHead:TPasMPSizeUIntEx;
       fPaddingHead:array[0..(PasMPCPUCacheLineSize-SizeOf(TPasMPSizeUIntEx))-1] of TPasMPUInt8;
       fTail:TPasMPSizeInt;
       fPaddingTail:array[0..(PasMPCPUCacheLineSize-SizeOf(TPasMPSizeUIntEx))-1] of TPasMPUInt8;
       function Idx(const aX:TPasMPSizeUIntEx):TPasMPSizeUIntEx; inline;
       function TurnOf(const aX:TPasMPSizeUIntEx):TPasMPSizeUIntEx; inline;
      public
       constructor Create(const aCapacity:TPasMPSizeInt);
       destructor Destroy; override;
       procedure Enqueue(const aValue:T);
       function TryEnqueue(const aValue:T):Boolean;
       procedure Dequeue(out AValue:T);
       function TryDequeue(out AValue:T):Boolean;
       function Size:TPasMPSizeUIntEx;
       function Empty:Boolean; inline;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
{$endif}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPHashTable=class(TPasMPThreadSafeHashTable)
      private
       fKeySize:TPasMPInt32;
       fValueSize:TPasMPInt32;
       fItemSize:TPasMPInt32;
      protected
       procedure InitializeItem(const Data:pointer); override;
       procedure FinalizeItem(const Data:pointer); override;
       procedure CopyItem(const Source,Destination:pointer); override;
       procedure GetKey(const Data,Key:pointer); override;
       procedure SetKey(const Data,Key:pointer); override;
       procedure GetValue(const Data,Value:pointer); override;
       procedure SetValue(const Data,Value:pointer); override;
       function HashKey(const Key:pointer):TPasMPThreadSafeHashTableHash; override;
       function CompareKey(const Data,Key:pointer):boolean; override;
      public
       constructor Create(const KeySize,ValueSize:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
       destructor Destroy; override;
       function GetKeyValue(const Key;out Value):boolean;
       function SetKeyValue(const Key,Value):boolean;
       function DeleteKey(const Key):boolean;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPStringHashTable=class(TPasMPThreadSafeHashTable)
      private
       fKeySize:TPasMPInt32;
       fValueSize:TPasMPInt32;
       fItemSize:TPasMPInt32;
      protected
       procedure InitializeItem(const Data:pointer); override;
       procedure FinalizeItem(const Data:pointer); override;
       procedure CopyItem(const Source,Destination:pointer); override;
       procedure GetKey(const Data,Key:pointer); override;
       procedure SetKey(const Data,Key:pointer); override;
       procedure GetValue(const Data,Value:pointer); override;
       procedure SetValue(const Data,Value:pointer); override;
       function HashKey(const Key:pointer):TPasMPThreadSafeHashTableHash; override;
       function CompareKey(const Data,Key:pointer):boolean; override;
      public
       constructor Create(const ValueSize:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
       destructor Destroy; override;
       function GetKeyValue(const Key:string;out Value):boolean;
       function SetKeyValue(const Key:string;const Value):boolean;
       function DeleteKey(const Key:string):boolean;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPStringStringHashTable=class(TPasMPThreadSafeHashTable)
      private
       fKeySize:TPasMPInt32;
       fValueSize:TPasMPInt32;
       fItemSize:TPasMPInt32;
      protected
       procedure InitializeItem(const Data:pointer); override;
       procedure FinalizeItem(const Data:pointer); override;
       procedure CopyItem(const Source,Destination:pointer); override;
       procedure GetKey(const Data,Key:pointer); override;
       procedure SetKey(const Data,Key:pointer); override;
       procedure GetValue(const Data,Value:pointer); override;
       procedure SetValue(const Data,Value:pointer); override;
       function HashKey(const Key:pointer):TPasMPThreadSafeHashTableHash; override;
       function CompareKey(const Data,Key:pointer):boolean; override;
      public
       constructor Create(const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
       destructor Destroy; override;
       function GetKeyValue(const Key:string;out Value:string):boolean;
       function SetKeyValue(const Key,Value:string):boolean;
       function DeleteKey(const Key:string):boolean;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$ifdef HasGenericsCollections}
{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPHashTable<KeyType,ValueType>=class(TPasMPThreadSafeHashTable)
      private
       fKeySize:TPasMPInt32;
       fValueSize:TPasMPInt32;
       fItemSize:TPasMPInt32;
       fComparer:IEqualityComparer<KeyType>;
{$ifdef fpc}
       procedure Dummy(out Value:ValueType); inline;
{$endif}
      protected
       procedure InitializeItem(const Data:pointer); override;
       procedure FinalizeItem(const Data:pointer); override;
       procedure CopyItem(const Source,Destination:pointer); override;
       procedure GetKey(const Data,Key:pointer); override;
       procedure SetKey(const Data,Key:pointer); override;
       procedure GetValue(const Data,Value:pointer); override;
       procedure SetValue(const Data,Value:pointer); override;
       function HashKey(const Key:pointer):TPasMPThreadSafeHashTableHash; override;
       function CompareKey(const Data,Key:pointer):boolean; override;
      public
       constructor Create(const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
       destructor Destroy; override;
       function GetKeyValue(const Key:KeyType;out Value:ValueType):boolean;
       function SetKeyValue(const Key:KeyType;const Value:ValueType):boolean;
       function DeleteKey(const Key:KeyType):boolean;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
{$endif}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     EPasMPDynamicArrayOutOfBounds=class(Exception);
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPDynamicArray=class(TPasMPThreadSafeDynamicArray)
      protected
       procedure InitializeItem(const ItemData:pointer); override;
       procedure FinalizeItem(const ItemData:pointer); override;
       procedure CopyItem(const Source,Destination:pointer); override;
      public
       constructor Create(const aItemSize:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
       destructor Destroy; override;
       function GetItem(const ItemIndex:TPasMPInt32;out ItemData):boolean;
       function SetItem(const ItemIndex:TPasMPInt32;const ItemData):boolean;
       function Push(const ItemData):TPasMPInt32;
       function Pop(out ItemData):boolean;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$ifdef HAS_GENERICS}
{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPDynamicArray<T>=class(TPasMPThreadSafeDynamicArray)
      private
       type PPasMPDynamicArrayDataType=^TPasMPDynamicArrayDataType;
            TPasMPDynamicArrayDataType=T;
      protected
       procedure InitializeItem(const ItemData:pointer); override;
       procedure FinalizeItem(const ItemData:pointer); override;
       procedure CopyItem(const Source,Destination:pointer); override;
       function GetPropertyItem(const ItemIndex:TPasMPInt32):T;
       procedure SetPropertyItem(const ItemIndex:TPasMPInt32;const ItemData:T);
      public
       constructor Create(const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
       destructor Destroy; override;
       function GetItem(const ItemIndex:TPasMPInt32;out ItemData:T):boolean;
       function SetItem(const ItemIndex:TPasMPInt32;const ItemData:T):boolean;
       function Push(const ItemData:T):TPasMPInt32;
       function Pop(out ItemData:T):boolean;
       property Items[const ItemIndex:TPasMPInt32]:T read GetPropertyItem write SetPropertyItem; default;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}
{$endif}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPThread=class(TThread)
{$if defined(fpc) and (defined(Linux) or defined(Android)) and declared(TThreadPriority)}
      private
       function GetPriority:TThreadPriority; reintroduce;
       procedure SetPriority(Value:TThreadPriority); reintroduce;
      public
       property Priority:TThreadPriority read GetPriority write SetPriority;
{$ifend}
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

     PPasMPJobPriority=^TPasMPJobPriority;
     TPasMPJobPriority=
      (
       pmjpInherited,
       pmjpLow,
       pmjpNormal,
       pmjpHigh
      );

     PPasMPJob=^TPasMPJob;

{$ifdef HAS_ANONYMOUS_METHODS}
     TPasMPJobReferenceProcedure=reference to procedure(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
{$endif}

     TPasMPJobProcedure=procedure(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);

     TPasMPJobMethod=procedure(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32) of object;

{$ifdef HAS_ANONYMOUS_METHODS}
     TPasMPParallelForReferenceProcedure=reference to procedure(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32;const Data:pointer;const FromIndex,ToIndex:TPasMPNativeInt);
{$endif}

     TPasMPParallelForProcedure=procedure(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32;const Data:pointer;const FromIndex,ToIndex:TPasMPNativeInt);

     TPasMPParallelForMethod=procedure(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32;const Data:pointer;const FromIndex,ToIndex:TPasMPNativeInt) of object;

     TPasMPParallelSortCompareFunction=function(const a,b:pointer):TPasMPInt32;

     TPasMPJobWorkerThread=class;

     TPasMPJob=record
      case TPasMPInt32 of
       0:(                                          // 32 / 64 bit
        Method:TMethod;                             //  8 / 16 => 2x pointers
        ParentJob:PPasMPJob;                        //  4 /  8 => 1x pointer
        ChildrenJobs:TPasMPUInt32;                  //  4 /  4 => 1x 32-bit unsigned integer (children jobs)
        InternalData:TPasMPUInt32;                  //  4 /  4 => 1x 32-bit unsigned integer (owner worker thread index, job priority, task tag, flags, etc. and last high bit = active bit)
        AreaMask:TPasMPUInt32;                      //  4 /  4 => 1x 32-bit unsigned integer (area mask)
        Data:pointer;                               // ------- => just a dummy variable as struct field offset anchor
       );                                           // 24 / 36
       1:(
        Next:TPasMPThreadSafeStackEntry;
       );
       2:(
        // for 32-bit Destinations: use one whole cache line (1x 64 bytes = 16x 32-bit pointers/integers) to avoid false sharing (1 cache line => 64 bytes on the most CPUs) and also to have some free place for meta data
        // for 64-bit Destinations: use two whole cache lines (2x 64 bytes = 16x 64-bit pointers/integers) to avoid false sharing (1 cache line => 64 bytes on the most CPUs) and also to have some free place for meta data
        // and so on . . .
        FillUp:array[0..(PasMPCPUCacheLineSize*(SizeOf(TPasMPPtrUInt) div SizeOf(TPasMPUInt32)))-1] of TPasMPUInt8;
       );
     end;

     TPPasMPJobs=array of PPasMPJob;

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPJobTask=class
      private
       fFreeOnRelease:boolean;
       fJob:PPasMPJob;
       fThreadIndex:TPasMPInt32;
       fJobTag:TPasMPUInt32;
      public
       constructor Create;
       destructor Destroy; override;
       procedure Run; virtual;
       function Split:TPasMPJobTask; virtual;
       function PartialPop:TPasMPJobTask; virtual;
       function Spread:boolean; virtual;
       property FreeOnRelease:boolean read fFreeOnRelease write fFreeOnRelease;
       property Job:PPasMPJob read fJob;
       property ThreadIndex:TPasMPInt32 read fThreadIndex;
       property JobTag:TPasMPUInt32 read fJobTag write fJobTag;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

     PPasMPJobAllocatorMemoryPoolBucket=^TPasMPJobAllocatorMemoryPoolBucket;
     TPasMPJobAllocatorMemoryPoolBucket=array[0..PasMPAllocatorPoolBucketSize-1] of TPasMPJob;

     PPPasMPJobAllocatorMemoryPoolBuckets=^TPPasMPJobAllocatorMemoryPoolBuckets;
     TPPasMPJobAllocatorMemoryPoolBuckets=array of PPasMPJobAllocatorMemoryPoolBucket;

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPJobAllocator=class
      private
       fJobWorkerThread:TPasMPJobWorkerThread;
       fFreeJobs:TPasMPThreadSafeStack;
       fMemoryPoolBuckets:TPPasMPJobAllocatorMemoryPoolBuckets;
       fCountMemoryPoolBuckets:TPasMPInt32;
       fCountAllocatedJobs:TPasMPInt32;
       procedure AllocateNewBuckets(const NewCountMemoryPoolBuckets:TPasMPInt32);
       function AllocateJob:PPasMPJob; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       procedure FreeJobs; {$ifdef CAN_INLINE}inline;{$endif}
       procedure FreeJob(const Job:PPasMPJob);
      public
       constructor Create(const AJobWorkerThread:TPasMPJobWorkerThread);
       destructor Destroy; override;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPWorkerSystemThread=class(TPasMPThread)
      private
       fJobWorkerThread:TPasMPJobWorkerThread;
      protected
       procedure Execute; override;
      public
       constructor Create(const AJobWorkerThread:TPasMPJobWorkerThread);
       destructor Destroy; override;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

     TPasMPJobQueueJobs=array of PPasMPJob;

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPJobQueue=class
      private
       fPasMPInstance:TPasMP;
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fQueueLockState:TPasMPInt32;
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fQueueSize:TPasMPInt32;
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fQueueMask:TPasMPInt32;
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fQueueBottom:TPasMPInt32;
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fQueueTop:TPasMPInt32;
       {$ifdef HAS_VOLATILE}[volatile]{$endif}fQueueJobs:TPasMPJobQueueJobs;
       function HasJobs:boolean; {$ifdef CAN_INLINE}inline;{$endif}
       procedure Resize(const QueueBottom,QueueTop:TPasMPInt32);
       procedure PushJob(const pJob:PPasMPJob);
       function PopJob:PPasMPJob;
       function StealJob:PPasMPJob;
      public
       constructor Create(const APasMPInstance:TPasMP);
       destructor Destroy; override;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

     PPasMPJobQueues=^TPasMPJobQueues;
     TPasMPJobQueues=array[PasMPJobQueuePriorityFirst..PasMPJobQueuePriorityLast] of TPasMPJobQueue;

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPJobWorkerThread=class
      private
       fPasMPInstance:TPasMP;
       fNext:TPasMPJobWorkerThread;
       fThreadIndex:TPasMPInt32;
       fCurrentJobPriority:TPasMPUInt32;
       fDepth:TPasMPUInt32;
       fAreaMask:TPasMPUInt32;
{$ifndef UseThreadLocalStorage}
       fThreadID:{$ifdef fpc}TThreadID{$else}TPasMPUInt32{$endif};
{$endif}
       fCPUAffinityMask:TPasMPUInt64; // 64-bit CPU affinity mask for maximum 64 CPU logical cores for now
       fSystemThread:TPasMPWorkerSystemThread;
       fIsReadyEvent:TPasMPEvent;
       fJobAllocator:TPasMPJobAllocator;
       fJobQueues:TPasMPJobQueues;
       fJobQueuesUsedBitmap:TPasMPUInt32;
       fMaxPriorityJobQueueIndex:TPasMPUInt32;
       fXorShift32:TPasMPUInt32;
       procedure ThreadInitialization;
       function GetJob:PPasMPJob;
       function HasJobs:boolean; {$ifdef CAN_INLINE}inline;{$endif}
       procedure ThreadProc;
      public
       constructor Create(const APasMPInstance:TPasMP;const AThreadIndex:TPasMPInt32;const aCPUAffinityMask:TPasMPUInt64=0);
       destructor Destroy; override;
       property Depth:TPasMPUInt32 read fDepth;
       property AreaMask:TPasMPUInt32 read fAreaMask;
       property ThreadIndex:TPasMPInt32 read fThreadIndex;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

     TPasMPJobWorkerThreads=array of TPasMPJobWorkerThread;

     TPasMPJobWorkerThreadHashTable=array[0..PasMPJobWorkerThreadHashTableSize-1] of TPasMPJobWorkerThread;

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPScope=class
      private
       fPasMPInstance:TPasMP;
       fWaitCalled:longbool;
       fJobs:TPPasMPJobs;
       fCountJobs:TPasMPInt32;
      public
       constructor Create(const APasMPInstance:TPasMP);
       destructor Destroy; override;
       procedure Run(const Job:PPasMPJob); overload;
       procedure Run(const Jobs:array of PPasMPJob); overload;
       procedure Run(const JobTask:TPasMPJobTask); overload;
       procedure Run(const JobTasks:array of TPasMPJobTask); overload;
       procedure Wait;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     PPasMPProfilerHistoryRingBufferItem=^TPasMPProfilerHistoryRingBufferItem;
     TPasMPProfilerHistoryRingBufferItem=record
      case TPasMPUInt32 of
       0:(
        JobTag:TPasMPUInt32;
        ThreadIndexStackDepth:TPasMPUInt32;
        StartTime:TPasMPHighResolutionTime;
        EndTime:TPasMPHighResolutionTime;
        Dummy:pointer;
       );
       1:(
        CacheLineFillUp:array[0..PasMPCPUCacheLineSize-1] of TPasMPUInt8;
       );
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

     PPasMPProfilerHistory=^TPasMPProfilerHistory;
     TPasMPProfilerHistory=array[0..PasMPProfilerHistoryRingBufferSize-1] of TPasMPProfilerHistoryRingBufferItem;

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMPProfiler=class
      private
       fHistory:TPasMPProfilerHistory;
       fPointerToHistory:PPasMPProfilerHistory;
       fPasMPInstance:TPasMP;
       fCount:TPasMPInt32;
       fHighResolutionTimer:TPasMPHighResolutionTimer;
       fStartTime:TPasMPHighResolutionTime;
       fLastTime:TPasMPHighResolutionTime;
       fOffsetTime:TPasMPHighResolutionTime;
       function GetHistoryRingBufferItem(const pIndex:TPasMPUInt32):PPasMPProfilerHistoryRingBufferItem; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       procedure Sort;
      public
       constructor Create(const pPasMPInstance:TPasMP);
       destructor Destroy; override;
       procedure Reset;
       procedure Start(const SuppressGaps:boolean=true);
       procedure Stop(const MaximalTimePeriodToKeep:TPasMPHighResolutionTime=-1);
       function Acquire:PPasMPProfilerHistoryRingBufferItem; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       property History:PPasMPProfilerHistory read fPointerToHistory;
       property HistoryRingBufferItems[const pIndex:TPasMPUInt32]:PPasMPProfilerHistoryRingBufferItem read GetHistoryRingBufferItem;
       property PasMPInstance:TPasMP read fPasMPInstance;
       property Count:TPasMPInt32 read fCount;
       property HighResolutionTimer:TPasMPHighResolutionTimer read fHighResolutionTimer;
       property StartTime:TPasMPHighResolutionTime read fStartTime;
       property LastTime:TPasMPHighResolutionTime read fLastTime;
       property OffsetTime:TPasMPHighResolutionTime read fOffsetTime;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

{$if declared(TThreadPriority)}
  {$define HasRealTThreadPriority}
{$else}
  {$undef HasRealTThreadPriority}
     // Workaround for Delphi mobile targets
     TThreadPriority=
      (
       tpIdle,
       tpLowest,
       tpLower,
       tpNormal,
       tpHigher,
       tpHighest,
       tpTimeCritical
      );
{$ifend}

     TPasMPOnWorkerThreadException=function(const aException:Exception):Boolean of object;

     TPasMPOnCheckJobExecution=function(const aPasMPInstance:TPasMP;const aJob:PPasMPJob;const aJobWorkerThread:TPasMPJobWorkerThread):Boolean of object;

{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
     TPasMP=class
      private
       fAvailableCPUCores:TPasMPAvailableCPUCores;
       fDoCPUCorePinning:longbool;
       fSleepingOnIdle:longbool;
       fAllWorkerThreadsHaveOwnSystemThreads:longbool;
{$ifdef PasMPHaveFPUControls}
       fFPUExceptionMask:TFPUExceptionMask;
       fFPUPrecisionMode:TFPUPrecisionMode;
       fFPURoundingMode:TFPURoundingMode;
{$endif}
       fJobWorkerThreads:TPasMPJobWorkerThreads;
       fCountJobWorkerThreads:TPasMPInt32;
       fSleepingJobWorkerThreads:TPasMPInt32;
       fWorkingJobWorkerThreads:TPasMPInt32;
       fSystemIsReadyEvent:TPasMPEvent;
{$ifdef PasMPUseWakeUpConditionVariable}
       fWakeUpCounter:TPasMPInt32;
       fWakeUpConditionVariableLock:TPasMPConditionVariableLock;
       fWakeUpConditionVariable:TPasMPConditionVariable;
{$else}
       fWakeUpEvent:TPasMPEvent;
{$endif}
       fCountCPUThreads:TPasMPInt32;
       fCriticalSection:TPasMPCriticalSection;
       fJobAllocatorCriticalSection:TPasMPCriticalSection;
       fJobAllocator:TPasMPJobAllocator;
       fJobQueues:TPasMPJobQueues;
       fJobQueuesUsedBitmap:TPasMPUInt32;
       fJobQueuesLock:TPasMPSlimReaderWriterLock;
       fGlobalJobQueuesUsedBitmap:TPasMPUInt32;
{$ifndef UseThreadLocalStorage}
       fJobWorkerThreadHashTableCriticalSection:TPasMPCriticalSection;
       fJobWorkerThreadHashTable:TPasMPJobWorkerThreadHashTable;
{$endif}
       fProfiler:TPasMPProfiler;
       fWorkerThreadPriority:TThreadPriority;
       fWorkerThreadStackSize:TPasMPSizeUInt;
       fWorkerThreadMaxDepth:TPasMPUInt32;
       fOnWorkerThreadException:TPasMPOnWorkerThreadException;
       fOnCheckJobExecution:TPasMPOnCheckJobExecution;
       class function GetThreadIDHash(ThreadID:{$ifdef fpc}TThreadID{$else}TPasMPUInt32{$endif}):TPasMPUInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       function GetJobWorkerThread:TPasMPJobWorkerThread; {$ifndef UseThreadLocalStorage}{$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}{$endif}
       procedure WaitForWakeUp;
       procedure WakeUpAll;
       function CanSpread:boolean;
       function IsFull:boolean;
       function GlobalAllocateJob:PPasMPJob;
       procedure GlobalFreeJob(const Job:PPasMPJob);
       function AllocateJob(const MethodCode,MethodData,Data:pointer;const ParentJob:PPasMPJob;const Flags,AreaMask:TPasMPUInt32):PPasMPJob; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       procedure WaitOnChildrenJobs(const Job:PPasMPJob);
       procedure ExecuteJobTask(const Job:PPasMPJob;const JobWorkerThread:TPasMPJobWorkerThread;const ThreadIndex:TPasMPInt32); {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       function CheckJobExecution(const Job:PPasMPJob;const JobWorkerThread:TPasMPJobWorkerThread):Boolean;
       procedure ExecuteJob(const Job:PPasMPJob;const JobWorkerThread:TPasMPJobWorkerThread); //{$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       procedure PushJob(const Job:PPasMPJob;const JobWorkerThread:TPasMPJobWorkerThread); {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
{$ifdef HAS_ANONYMOUS_METHODS}
       procedure JobReferenceProcedureJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
       procedure ParallelForJobReferenceProcedureProcess(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
       procedure ParallelForJobReferenceProcedureFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
       procedure ParallelForStartJobReferenceProcedureFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
{$endif}
       procedure ParallelForJobFunctionProcess(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
       procedure ParallelForJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
       procedure ParallelForStartJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
       procedure ParallelDirectIntroSortJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
       procedure ParallelIndirectIntroSortJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
       procedure ParallelDirectMergeSortJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
       procedure ParallelDirectMergeSortRootJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
       procedure ParallelIndirectMergeSortJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
       procedure ParallelIndirectMergeSortRootJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
      public
       constructor Create(const CountThreads:TPasMPInt32=-1;const MinimumCountThreads:TPasMPInt32=-1;const MaximumCountThreads:TPasMPInt32=-1;const ThreadHeadRoomForForeignTasks:TPasMPInt32=0;const DoCPUCorePinning:boolean=true;const SleepingOnIdle:boolean=true;const AllWorkerThreadsHaveOwnSystemThreads:boolean=false;const Profiling:boolean=false;const WorkerThreadPriority:TThreadPriority=TThreadPriority.tpNormal;const WorkerThreadStackSize:TPasMPSizeUInt=0;const WorkerThreadMaxDepth:TPasMPUInt32=0);
       destructor Destroy; override;
       class function CreateGlobalInstance:TPasMP;
       class procedure DestroyGlobalInstance;
       class function GetGlobalInstance:TPasMP; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       class function GetCountOfPhysicalCores(out AvailableCPUCores:TPasMPAvailableCPUCores):TPasMPInt32; {$ifdef HAS_STATIC}static;{$endif}
       class function GetCountOfHardwareThreads(out AvailableCPUCores:TPasMPAvailableCPUCores):TPasMPInt32; {$ifdef HAS_STATIC}static;{$endif}
       class procedure Relax; {$ifdef HAS_STATIC}static;{$endif}{$if defined(CPU386) or defined(CPUx86_64)}{$elseif defined(CAN_INLINE)}inline;{$ifend}
       class procedure Yield; {$ifdef HAS_STATIC}static;{$endif}{$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       class function Once(var OnceControl:TPasMPOnce;const InitRoutine:TPasMPOnceInitRoutine):boolean; {$ifdef Linux}{$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}{$endif}
       class function IsJobCompleted(const Job:PPasMPJob):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       class function IsJobValid(const Job:PPasMPJob):boolean; {$ifdef CAN_INLINE}inline;{$endif}
       class function EncodeJobPriorityToJobFlags(const JobPriority:TPasMPJobPriority):TPasMPUInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function DecodeJobPriorityFromJobFlags(const Flags:TPasMPUInt32):TPasMPJobPriority; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function EncodeJobTagToJobFlags(const JobTag:TPasMPUInt32):TPasMPUInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       class function DecodeJobTagFromJobFlags(const Flags:TPasMPUInt32):TPasMPUInt32; {$ifdef HAS_STATIC}static;{$endif}{$ifdef CAN_INLINE}inline;{$endif}
       procedure Reset;
       function CreateScope:TPasMPScope; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       function GetJobWorkerThreadIndex:TPasMPInt32;
{$ifdef HAS_ANONYMOUS_METHODS}
       function Acquire(const JobReferenceProcedure:TPasMPJobReferenceProcedure;const Data:pointer=nil;const ParentJob:PPasMPJob=nil;const Flags:TPasMPUInt32=0;const AreaMask:TPasMPUInt32=0):PPasMPJob; overload;
{$endif}
       function Acquire(const JobProcedure:TPasMPJobProcedure;const Data:pointer=nil;const ParentJob:PPasMPJob=nil;const Flags:TPasMPUInt32=0;const AreaMask:TPasMPUInt32=0):PPasMPJob; overload;
       function Acquire(const JobMethod:TPasMPJobMethod;const Data:pointer=nil;const ParentJob:PPasMPJob=nil;const Flags:TPasMPUInt32=0;const AreaMask:TPasMPUInt32=0):PPasMPJob; overload;
       function Acquire(const JobTask:TPasMPJobTask;const Data:pointer=nil;const ParentJob:PPasMPJob=nil;const Flags:TPasMPUInt32=0;const AreaMask:TPasMPUInt32=0):PPasMPJob; overload;
       procedure Release(const Job:PPasMPJob); overload; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       procedure Release(const Jobs:array of PPasMPJob); overload;
       procedure Run(const Job:PPasMPJob;const GlobalQueue:Boolean=false); overload; {$ifdef fpc}{$ifdef CAN_INLINE}inline;{$endif}{$endif}
       procedure Run(const Jobs:array of PPasMPJob;const GlobalQueue:Boolean=false); overload;
       function StealAndExecuteJob:boolean;
       procedure Wait(const Job:PPasMPJob); overload;
       procedure Wait(const Jobs:array of PPasMPJob); overload;
       procedure RunWait(const Job:PPasMPJob); overload; {$ifdef CAN_INLINE}inline;{$endif}
       procedure RunWait(const Jobs:array of PPasMPJob); overload;
       procedure WaitRelease(const Job:PPasMPJob); overload; {$ifdef CAN_INLINE}inline;{$endif}
       procedure WaitRelease(const Jobs:array of PPasMPJob); overload;
       procedure Invoke(const Job:PPasMPJob); overload; {$ifdef CAN_INLINE}inline;{$endif}
       procedure Invoke(const Jobs:array of PPasMPJob); overload;
       procedure Invoke(const JobTask:TPasMPJobTask); overload; {$ifdef CAN_INLINE}inline;{$endif}
       procedure Invoke(const JobTasks:array of TPasMPJobTask); overload;
{$ifdef HAS_ANONYMOUS_METHODS}
       function ParallelFor(const Data:pointer;const FirstIndex,LastIndex:TPasMPNativeInt;const ParallelForReferenceProcedure:TPasMPParallelForReferenceProcedure;const Granularity:TPasMPInt32=1;const Depth:TPasMPInt32=PasMPDefaultDepth;const ParentJob:PPasMPJob=nil;const Flags:TPasMPUInt32=0;const AreaMask:TPasMPUInt32=0;const RecursiveSplit:Boolean=true):PPasMPJob; overload;
{$endif}
       function ParallelFor(const Data:pointer;const FirstIndex,LastIndex:TPasMPNativeInt;const ParallelForProcedure:TPasMPParallelForProcedure;const Granularity:TPasMPInt32=1;const Depth:TPasMPInt32=PasMPDefaultDepth;const ParentJob:PPasMPJob=nil;const Flags:TPasMPUInt32=0;const AreaMask:TPasMPUInt32=0;const RecursiveSplit:Boolean=true):PPasMPJob; overload;
       function ParallelFor(const Data:pointer;const FirstIndex,LastIndex:TPasMPNativeInt;const ParallelForMethod:TPasMPParallelForMethod;const Granularity:TPasMPInt32=1;const Depth:TPasMPInt32=PasMPDefaultDepth;const ParentJob:PPasMPJob=nil;const Flags:TPasMPUInt32=0;const AreaMask:TPasMPUInt32=0;const RecursiveSplit:Boolean=true):PPasMPJob; overload;
       function ParallelDirectIntroSort(const Items:pointer;const Left,Right:TPasMPNativeInt;const ElementSize:TPasMPInt32;const CompareFunc:TPasMPParallelSortCompareFunction;const Granularity:TPasMPInt32=16;const Depth:TPasMPInt32=PasMPDefaultDepth;const ParentJob:PPasMPJob=nil;const Flags:TPasMPUInt32=0;const AreaMask:TPasMPUInt32=0):PPasMPJob;
       function ParallelIndirectIntroSort(const Items:pointer;const Left,Right:TPasMPNativeInt;const CompareFunc:TPasMPParallelSortCompareFunction;const Granularity:TPasMPInt32=16;const Depth:TPasMPInt32=PasMPDefaultDepth;const ParentJob:PPasMPJob=nil;const Flags:TPasMPUInt32=0;const AreaMask:TPasMPUInt32=0):PPasMPJob;
       function ParallelDirectMergeSort(const Items:pointer;const Left,Right:TPasMPNativeInt;const ElementSize:TPasMPInt32;const CompareFunc:TPasMPParallelSortCompareFunction;const Granularity:TPasMPInt32=16;const Depth:TPasMPInt32=PasMPDefaultDepth;const ParentJob:PPasMPJob=nil;const Flags:TPasMPUInt32=0;const AreaMask:TPasMPUInt32=0):PPasMPJob;
       function ParallelIndirectMergeSort(const Items:pointer;const Left,Right:TPasMPNativeInt;const CompareFunc:TPasMPParallelSortCompareFunction;const Granularity:TPasMPInt32=16;const Depth:TPasMPInt32=PasMPDefaultDepth;const ParentJob:PPasMPJob=nil;const Flags:TPasMPUInt32=0;const AreaMask:TPasMPUInt32=0):PPasMPJob;
       property JobWorkerThread:TPasMPJobWorkerThread read GetJobWorkerThread;
       property JobWorkerThreads:TPasMPJobWorkerThreads read fJobWorkerThreads;
       property CountJobWorkerThreads:TPasMPInt32 read fCountJobWorkerThreads;
       property Profiler:TPasMPProfiler read fProfiler;
       property SleepingOnIdle:longbool read fSleepingOnIdle write fSleepingOnIdle;
       property OnWorkerThreadException:TPasMPOnWorkerThreadException read fOnWorkerThreadException write fOnWorkerThreadException;
       property OnCheckJobExecution:TPasMPOnCheckJobExecution read fOnCheckJobExecution write fOnCheckJobExecution;
     end;
{$if defined(fpc) and (fpc_version>=3)}{$pop}{$ifend}

var GlobalPasMP:TPasMP=nil; // "Optional" singleton-like global PasMP instance

    GlobalPasMPCountThreads:TPasMPInt32=-1;
    GlobalPasMPMinimumCountThreads:TPasMPInt32=-1;
    GlobalPasMPMaximumCountThreads:TPasMPInt32=-1;
    GlobalPasMPThreadHeadRoomForForeignTasks:TPasMPInt32=0;
    GlobalPasMPDoCPUCorePinning:boolean=true;
    GlobalPasMPSleepingOnIdle:boolean=true;
    GlobalPasMPAllWorkerThreadsHaveOwnSystemThreads:boolean=false;
    GlobalPasMPProfiling:boolean=false;
    GlobalPasMPWorkerThreadPriority:TThreadPriority=TThreadPriority.tpNormal;
    GlobalPasMPOverrideThreadPriorityFunctions:boolean=false;
    GlobalPasMPWorkerThreadStackSize:TPasMPSizeUInt=0;
    GlobalPasMPWorkerThreadMaxDepth:TPasMPUInt32=0;

    GPasMP:TPasMP absolute GlobalPasMP; // A shorter name for lazy peoples

{$if defined(fpc)}
{$elseif CompilerVersion>=25}
{$elseif defined(fpc)}
procedure FallbackMemoryBarrier; {$ifdef CAN_INLINE}inline;{$endif}
{$elseif CompilerVersion>=25}
procedure FallbackReadBarrier; {$ifdef CAN_INLINE}inline;{$endif}
procedure FallbackReadDependencyBarrier; {$ifdef CAN_INLINE}inline;{$endif}
procedure FallbackReadWriteBarrier; {$ifdef CAN_INLINE}inline;{$endif}
procedure FallbackWriteBarrier; {$ifdef CAN_INLINE}inline;{$endif}
procedure FallbackMemoryBarrier; {$ifdef CAN_INLINE}inline;{$endif}
{$elseif defined(CPU386)}
procedure FallbackReadBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
procedure FallbackReadDependencyBarrier; {$ifdef CAN_INLINE}inline;{$endif}
procedure FallbackReadWriteBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
procedure FallbackWriteBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
procedure FallbackMemoryBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
{$elseif defined(CPUx86)}
procedure FallbackReadBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
procedure FallbackReadDependencyBarrier; {$ifdef CAN_INLINE}inline;{$endif}
procedure FallbackReadWriteBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
procedure FallbackWriteBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
procedure FallbackMemoryBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
{$elseif defined(CPUAARCH64)}
procedure FallbackReadBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
procedure FallbackReadDependencyBarrier; {$ifdef CAN_INLINE}inline;{$endif}
procedure FallbackReadWriteBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
procedure FallbackWriteBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
procedure FallbackMemoryBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
{$elseif defined(CPUARM)}
procedure FallbackReadBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
procedure FallbackReadDependencyBarrier; {$ifdef CAN_INLINE}inline;{$endif}
procedure FallbackReadWriteBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
procedure FallbackWriteBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
procedure FallbackMemoryBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
{$else}
procedure FallbackReadBarrier; {$ifdef CAN_INLINE}inline;{$endif}
procedure FallbackReadDependencyBarrier; {$ifdef CAN_INLINE}inline;{$endif}
procedure FallbackReadWriteBarrier; {$ifdef CAN_INLINE}inline;{$endif}
procedure FallbackWriteBarrier; {$ifdef CAN_INLINE}inline;{$endif}
procedure FallbackMemoryBarrier; {$ifdef CAN_INLINE}inline;{$endif}
{$ifend}

{$if defined(cpu386)}
{$ifndef fpc}
function BSFDWord(Value:TPasMPUInt32):TPasMPUInt32; assembler; register;
function BSRDWord(Value:TPasMPUInt32):TPasMPUInt32; assembler; register;
function BSFQWord(Value:TPasMPUInt64):TPasMPUInt32; assembler; stdcall;
function BSRQWord(Value:TPasMPUInt64):TPasMPUInt32; assembler; stdcall;
function CTZDWord(Value:TPasMPUInt32):TPasMPUInt32; assembler; register;
function CLZDWord(Value:TPasMPUInt32):TPasMPUInt32; assembler; register;
function CTZQWord(Value:TPasMPUInt64):TPasMPUInt32; assembler; stdcall;
function CLZQWord(Value:TPasMPUInt64):TPasMPUInt32; assembler; stdcall;
function POPCNTDWord(Value:TPasMPUInt32):TPasMPUInt32; assembler; register;
function POPCNTQWord(Value:TPasMPUInt64):TPasMPUInt32; assembler; stdcall;
{$endif}
{$elseif defined(cpux86_64)}
{$ifndef fpc}
function BSFDWord(Value:TPasMPUInt32):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
function BSRDWord(Value:TPasMPUInt32):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
function BSFQWord(Value:TPasMPUInt64):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
function BSRQWord(Value:TPasMPUInt64):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
function CTZDWord(Value:TPasMPUInt32):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
function CLZDWord(Value:TPasMPUInt32):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
function CTZQWord(Value:TPasMPUInt64):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
function CLZQWord(Value:TPasMPUInt64):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
function POPCNTDWord(Value:TPasMPUInt32):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
function POPCNTQWord(Value:TPasMPUInt64):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
{$endif}
{$elseif not defined(fpc)}
function UInt64Mul(a,b:TPasMPUInt64):TPasMPUInt64;{$ifdef cpu386}assembler; stdcall;{$else}{$ifdef cpu64}{$ifdef CAN_INLINE}inline;{$endif}{$endif}{$endif}
function BSFDWord(Value:TPasMPUInt32):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
function BSFQWord(Value:TPasMPUInt64):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
function BSRDWord(Value:TPasMPUInt32):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
function BSRQWord(Value:TPasMPUInt64):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
function CLZDWord(Value:TPasMPUInt32):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
function CLZQWord(Value:TPasMPUInt64):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
function CTZDWord(Value:TPasMPUInt32):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
function CTZQWord(Value:TPasMPUInt64):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
function POPCNTDWord(Value:TPasMPUInt32):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
function POPCNTQWord(Value:TPasMPUInt64):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
{$ifend}

{$ifdef fpc}
function CTZDWord(Value:TPasMPUInt32):TPasMPUInt32; {$ifdef CAN_INLINE}inline;{$endif}
function CLZDWord(Value:TPasMPUInt32):TPasMPUInt32; {$ifdef CAN_INLINE}inline;{$endif}
function CTZQWord(Value:TPasMPUInt64):TPasMPUInt32; {$ifdef CAN_INLINE}inline;{$endif}
function CLZQWord(Value:TPasMPUInt64):TPasMPUInt32; {$ifdef CAN_INLINE}inline;{$endif}
{$endif}

implementation

const PasMPBarrierFlag=TPasMPInt32(1) shl 30;

{$ifdef UseThreadLocalStorage}
{$if defined(UseThreadLocalStorageX8632) or defined(UseThreadLocalStorageX8664)}
var CurrentJobWorkerThreadTLSIndex,CurrentJobWorkerThreadTLSOffset:TPasMPInt32;
{$else}
threadvar CurrentJobWorkerThread:TPasMPJobWorkerThread;
{$ifend}
{$endif}

var GlobalPasMPCriticalSection:TPasMPCriticalSection=nil;

{$ifdef PasMPUseGlobalPasMPCountOfHardwareThreads}
    GlobalPasMPCountOfHardwareThreads:TPasMPInt32=-1;

    GlobalPasMPAvailableCPUCores:TPasMPAvailableCPUCores;
{$endif}

{$ifdef fpc}
 {$undef OldDelphi}
{$else}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=23.0}
   {$undef OldDelphi}
type qword=uint64;
     ptruint=NativeUInt;
     ptrint=NativeInt;
  {$else}
   {$define OldDelphi}
  {$ifend}
 {$else}
  {$define OldDelphi}
 {$endif}
{$endif}
{$ifdef OldDelphi}
type qword=TPasMPInt64;
{$ifdef CPU64}
     ptruint=qword;
     ptrint=TPasMPInt64;
{$else}
     ptruint=TPasMPUInt32;
     ptrint=TPasMPInt32;
{$endif}
{$endif}

{$if defined(Windows)}

function SwitchToThread:BOOL; external 'kernel32.dll' name 'SwitchToThread';

function SetThreadIdealProcessor(hThread:THANDLE;dwIdealProcessor:TPasMPUInt32):TPasMPUInt32; stdcall; external 'kernel32.dll' name 'SetThreadIdealProcessor';

procedure InitializeConditionVariable(ConditionVariable:PPasMPConditionVariableData); stdcall; external 'kernel32.dll' name 'InitializeConditionVariable';
function SleepConditionVariableCS(ConditionVariable:PPasMPConditionVariableData;CriticalSection:PRTLCriticalSection;dwMilliSeconds:TPasMPUInt32):bool; stdcall; external 'kernel32.dll' name 'SleepConditionVariableCS';
procedure WakeConditionVariable(ConditionVariable:PPasMPConditionVariableData); stdcall; external 'kernel32.dll' name 'WakeConditionVariable';
procedure WakeAllConditionVariable(ConditionVariable:PPasMPConditionVariableData); stdcall; external 'kernel32.dll' name 'WakeAllConditionVariable';

procedure InitializeSRWLock(SRWLock:PPasMPSRWLock); stdcall; external 'kernel32.dll' name 'InitializeSRWLock';
procedure AcquireSRWLockShared(SRWLock:PPasMPSRWLock); stdcall; external 'kernel32.dll' name 'AcquireSRWLockShared';
function TryAcquireSRWLockShared(SRWLock:PPasMPSRWLock):bool; stdcall; external 'kernel32.dll' name 'TryAcquireSRWLockShared';
procedure ReleaseSRWLockShared(SRWLock:PPasMPSRWLock); stdcall; external 'kernel32.dll' name 'ReleaseSRWLockShared';
procedure AcquireSRWLockExclusive(SRWLock:PPasMPSRWLock); stdcall; external 'kernel32.dll' name 'AcquireSRWLockExclusive';
function TryAcquireSRWLockExclusive(SRWLock:PPasMPSRWLock):bool; stdcall; external 'kernel32.dll' name 'TryAcquireSRWLockExclusive';
procedure ReleaseSRWLockExclusive(SRWLock:PPasMPSRWLock); stdcall; external 'kernel32.dll' name 'ReleaseSRWLockExclusive';

{$elseif defined(Linux) or defined(Android)}
{$ifdef fpc}
const _SC_UIO_MAXIOV=60;
      _SC_NPROCESSORS_CONF=(_SC_UIO_MAXIOV)+23;

{$if defined(PasMPPThreadBarrier)}
      PTHREAD_BARRIER_SERIAL_THREAD=-1;
{$ifend}

type cpu_set_p=^cpu_set_t;
     cpu_set_t=TPasMPInt64;

{$ifdef fpc}
{$linklib c}
{$endif}

{$if defined(Android) or not defined(fpc)}
type ppthread_mutex_t=^pthread_mutex_t;
     ppthread_mutexattr_t=^pthread_mutexattr_t;

     ppthread_cond_t=^pthread_cond_t;
     ppthread_condattr_t=^pthread_condattr_t;

     Ppthread_rwlock_t=^pthread_rwlock_t;
     Ppthread_rwlockattr_t=^pthread_rwlockattr_t;

     Psem_t=^sem_t;

{$if defined(PasMPPThreadSpinLock)}
     pthread_spinlock_t=TPasMPSpinLockPThreadSpinLock;
     ppthread_spinlock_t=^pthread_spinlock_t;
     TPthreadSpinlock=pthread_spinlock_t;
     PTPthreadSpinlock=^TPthreadSpinlock;
{$ifend}

{$if defined(PasMPPThreadBarrier)}
     Ppthread_barrier_t=^pthread_barrier_t;
     pthread_barrier_t=TPasMPSpinLockPThreadBarrier;

     pthread_barrierattr_t=record
      __pshared:TPasMPInt32;
     end;
     ppthread_barrierattr_t=^pthread_barrierattr_t;
     TPthreadBarrierAttribute=pthread_barrierattr_t;
     PPthreadBarrierAttribute=^TPthreadBarrierAttribute;
{$ifend}

{$ifend}

function sysconf(__name:TPasMPInt32):TPasMPInt32; cdecl; external 'c' name 'sysconf';

function sched_getaffinity(pid:ptruint;cpusetsize:TPasMPInt32;cpuset:pointer):TPasMPInt32; cdecl; external 'c' name 'sched_getaffinity';
function sched_setaffinity(pid:ptruint;cpusetsize:TPasMPInt32;cpuset:pointer):TPasMPInt32; cdecl; external 'c' name 'sched_setaffinity';

function pthread_setaffinity_np(pid:ptruint;cpusetsize:TPasMPInt32;cpuset:pointer):TPasMPInt32; cdecl; external 'c' name 'pthread_setaffinity_np';
function pthread_getaffinity_np(pid:ptruint;cpusetsize:TPasMPInt32;cpuset:pointer):TPasMPInt32; cdecl; external 'c' name 'pthread_getaffinity_np';

{$if defined(Android) or not defined(fpc)}
function pthread_mutex_init(__mutex:ppthread_mutex_t;__mutex_attr:ppthread_mutexattr_t):TPasMPInt32; cdecl; external 'c' name 'pthread_mutex_init';
function pthread_mutex_destroy(__mutex:ppthread_mutex_t):TPasMPInt32; cdecl; external 'c' name 'pthread_mutex_destroy';
function pthread_mutex_trylock(__mutex:ppthread_mutex_t):TPasMPInt32; cdecl; external 'c' name 'pthread_mutex_trylock';
function pthread_mutex_lock(__mutex:ppthread_mutex_t):TPasMPInt32; cdecl; external 'c' name 'pthread_mutex_lock';
function pthread_mutex_unlock(__mutex:ppthread_mutex_t):TPasMPInt32; cdecl; external 'c' name 'pthread_mutex_unlock';

function pthread_cond_init(__cond:ppthread_cond_t;__cond_attr:ppthread_condattr_t):TPasMPInt32; cdecl; external 'c' name 'pthread_cond_init';
function pthread_cond_destroy(__cond:ppthread_cond_t):TPasMPInt32; cdecl; external 'c' name 'pthread_cond_destroy';
function pthread_cond_signal(__cond:ppthread_cond_t):TPasMPInt32; cdecl; external 'c' name 'pthread_cond_signal';
function pthread_cond_broadcast(__cond:ppthread_cond_t):TPasMPInt32; cdecl; external 'c' name 'pthread_cond_broadcast';
function pthread_cond_wait(__cond:ppthread_cond_t; __mutex:ppthread_mutex_t):TPasMPInt32; cdecl; external 'c' name 'pthread_cond_wait';
function pthread_cond_timedwait(__cond:ppthread_cond_t;__mutex:ppthread_mutex_t;__abstime:PPasMPTimeSpec):TPasMPInt32; cdecl; external 'c' name 'pthread_cond_timedwait';

function pthread_rwlock_init(__rwlock:Ppthread_rwlock_t;__attr:Ppthread_rwlockattr_t):TPasMPInt32; cdecl; external 'c' name 'pthread_rwlock_init';
function pthread_rwlock_destroy(__rwlock:Ppthread_rwlock_t):TPasMPInt32; cdecl; external 'c' name 'pthread_rwlock_destroy';
function pthread_rwlock_rdlock(__rwlock:Ppthread_rwlock_t):TPasMPInt32; cdecl; external 'c' name 'pthread_rwlock_rdlock';
function pthread_rwlock_tryrdlock(__rwlock:Ppthread_rwlock_t):TPasMPInt32; cdecl; external 'c' name 'pthread_rwlock_tryrdlock';
function pthread_rwlock_timedrdlock(__rwlock:Ppthread_rwlock_t;__abstime:PPasMPTimeSpec):TPasMPInt32; cdecl; external 'c' name 'pthread_rwlock_timedrdlock';
function pthread_rwlock_wrlock(__rwlock:Ppthread_rwlock_t):TPasMPInt32; cdecl; external 'c' name 'pthread_rwlock_wrlock';
function pthread_rwlock_trywrlock(__rwlock:Ppthread_rwlock_t):TPasMPInt32; cdecl; external 'c' name 'pthread_rwlock_trywrlock';
function pthread_rwlock_timedwrlock(__rwlock:Ppthread_rwlock_t;__abstime:PPasMPTimeSpec):TPasMPInt32; cdecl; external 'c' name 'pthread_rwlock_timedwrlock';
function pthread_rwlock_unlock(__rwlock:Ppthread_rwlock_t):TPasMPInt32; cdecl; external 'c' name 'pthread_rwlock_unlock';

{$if defined(PasMPPThreadSpinLock)}
function pthread_spin_init(__lock:Ppthread_spinlock_t;__pshared:TPasMPInt32):TPasMPInt32; cdecl; external 'c' name 'pthread_spin_init';
function pthread_spin_destroy(__lock:Ppthread_spinlock_t):TPasMPInt32; cdecl; external 'c' name 'pthread_spin_destroy';
function pthread_spin_lock(__lock:Ppthread_spinlock_t):TPasMPInt32; cdecl; external 'c' name 'pthread_spin_lock';
function pthread_spin_trylock(__lock:Ppthread_spinlock_t):TPasMPInt32; cdecl; external 'c' name 'pthread_spin_trylock';
function pthread_spin_unlock(__lock:Ppthread_spinlock_t):TPasMPInt32; cdecl; external 'c' name 'pthread_spin_unlock';
{$ifend}

{$if defined(PasMPPThreadBarrier)}
function pthread_barrier_init(__barrier:Ppthread_barrier_t;__attr:Ppthread_barrierattr_t;__count:TPasMPUInt32):TPasMPInt32; cdecl; external 'c' name 'pthread_barrier_init';
function pthread_barrier_destroy(__barrier:Ppthread_barrier_t):TPasMPInt32; cdecl; external 'c' name 'pthread_barrier_destroy';
function pthread_barrier_wait(__barrier:Ppthread_barrier_t):TPasMPInt32; cdecl; external 'c' name 'pthread_barrier_wait';
{$ifend}

function sem_init(__sem:Psem_t;__pshared:TPasMPInt32;__value:TPasMPUInt32):TPasMPInt32; cdecl; external 'c' name 'sem_init';
function sem_destroy(__sem:Psem_t):TPasMPInt32; cdecl; external 'c' name 'sem_destroy';
function sem_close(__sem:Psem_t):TPasMPInt32; cdecl; external 'c' name 'sem_close';
function sem_unlink(__name:Pchar):TPasMPInt32; cdecl; external 'c' name 'sem_unlink';
function sem_wait(__sem:Psem_t):TPasMPInt32; cdecl; external 'c' name 'sem_wait';
function sem_trywait(__sem:Psem_t):TPasMPInt32; cdecl; external 'c' name 'sem_trywait';
function sem_post(__sem:Psem_t):TPasMPInt32; cdecl; external 'c' name 'sem_post';
function sem_getvalue(__sem:Psem_t;__sval:PPasMPInt32):TPasMPInt32; cdecl; external 'c' name 'sem_getvalue';
function sem_timedwait(__sem:Psem_t;__abstime:PPasMPTimeSpec):TPasMPInt32; cdecl; external 'c' name 'sem_timedwait';
{$ifend}

{$else}

{$if defined(PasMPPThreadSpinLock)}
type pthread_spinlock_t=TPasMPSpinLockPThreadSpinLock;
     ppthread_spinlock_t=^pthread_spinlock_t;
     TPthreadSpinlock=pthread_spinlock_t;
     PTPthreadSpinlock=^TPthreadSpinlock;

function pthread_spin_init(__lock:Ppthread_spinlock_t;__pshared:TPasMPInt32):TPasMPInt32; cdecl; external libpthread name _PU+'pthread_spin_init';
function pthread_spin_destroy(__lock:Ppthread_spinlock_t):TPasMPInt32; cdecl; external libpthread name _PU+'pthread_spin_destroy';
function pthread_spin_lock(__lock:Ppthread_spinlock_t):TPasMPInt32; cdecl; external libpthread name _PU+'pthread_spin_lock';
function pthread_spin_trylock(__lock:Ppthread_spinlock_t):TPasMPInt32; cdecl; external libpthread name _PU+'pthread_spin_trylock';
function pthread_spin_unlock(__lock:Ppthread_spinlock_t):TPasMPInt32; cdecl; external libpthread name _PU+'pthread_spin_unlock';


{$ifend}

{$if defined(PasMPPThreadBarrier)}
const PTHREAD_BARRIER_SERIAL_THREAD=-1;

type Ppthread_barrier_t=^pthread_barrier_t;
     pthread_barrier_t=TPasMPSpinLockPThreadBarrier;

     pthread_barrierattr_t=record
      __pshared:TPasMPInt32;
     end;
     ppthread_barrierattr_t=^pthread_barrierattr_t;
     TPthreadBarrierAttribute=pthread_barrierattr_t;
     PPthreadBarrierAttribute=^TPthreadBarrierAttribute;

function pthread_barrier_init(__barrier:Ppthread_barrier_t;__attr:Ppthread_barrierattr_t;__count:TPasMPUInt32):TPasMPInt32; cdecl; external libpthread name _PU+'pthread_barrier_init';
function pthread_barrier_destroy(__barrier:Ppthread_barrier_t):TPasMPInt32; cdecl; external libpthread name _PU+'pthread_barrier_destroy';
function pthread_barrier_wait(__barrier:Ppthread_barrier_t):TPasMPInt32; cdecl; external libpthread name _PU+'pthread_barrier_wait';

{$ifend}

{$endif}

{$ifend}

{$ifdef fpc}
{$if defined(Linux) and not (defined(Android) or declared(pthread_condattr_setclock))}
function pthread_condattr_setclock(Attr:ppthread_condattr_t;clockid:TPasMPInt32):TPasMPInt32; cdecl; external 'c' name 'pthread_condattr_setclock';
{$ifend}
{$else}
{$if defined(Linux) and not defined(Android)}
function pthread_condattr_setclock(var Attr:pthread_condattr_t;clockid:TPasMPInt32):TPasMPInt32; cdecl; external 'c' name 'pthread_condattr_setclock';
{$ifend}
{$endif}

{$if defined(cpu386)}
{$ifndef fpc}
function BSFDWord(Value:TPasMPUInt32):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
 bsf eax,eax
 jnz @Done
 mov eax,255
@Done:
end;

function BSRDWord(Value:TPasMPUInt32):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
 bsr eax,eax
 jnz @Done
 mov eax,255
@Done:
end;

function BSFQWord(Value:TPasMPUInt64):TPasMPUInt32; assembler; stdcall; {$ifdef fpc}nostackframe;{$endif}
asm
 bsf eax,dword ptr [Value+0]
 jnz @Done
 bsf eax,dword ptr [Value+4]
 jz @Fail
 add eax,32
 jmp @Done
@Fail:
 mov eax,255
@Done:
end;

function BSRQWord(Value:TPasMPUInt64):TPasMPUInt32; assembler; stdcall; {$ifdef fpc}nostackframe;{$endif}
asm
 bsr eax,dword ptr [Value+4]
 jz @LowPart
 add eax,32
 jmp @Done
@LowPart:
 xor ecx,ecx
 bsr eax,dword ptr [Value+0]
 jnz @Done
 mov eax,255
@Done:
end;

function CTZDWord(Value:TPasMPUInt32):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
 bsf eax,eax
 jnz @Done
 mov eax,32
@Done:
end;

function CLZDWord(Value:TPasMPUInt32):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
 bsr edx,eax
 jnz @Done
 xor edx,edx
 not edx
@Done:
 mov eax,31
 sub eax,edx
end;

function CTZQWord(Value:TPasMPUInt64):TPasMPUInt32; assembler; stdcall; {$ifdef fpc}nostackframe;{$endif}
asm
 bsf eax,dword ptr [Value+0]
 jnz @Done
 bsf eax,dword ptr [Value+4]
 jz @Fail
 add eax,32
 jmp @Done
@Fail:
 xor eax,eax
 not eax
@Done:
end;

function CLZQWord(Value:TPasMPUInt64):TPasMPUInt32; assembler; stdcall; {$ifdef fpc}nostackframe;{$endif}
asm
 bsr edx,dword ptr [Value+4]
 jz @LowPart
 add edx,32
 jmp @Done
@LowPart:
 bsr edx,dword ptr [Value+0]
 jnz @Done
 xor edx,edx
 not edx
@Done:
 mov eax,63
 sub eax,edx
end;

function POPCNTDWord(Value:TPasMPUInt32):TPasMPUInt32; assembler; register;
asm
 // result:=Value-((Value shr 1) and $55555555);
 mov edx,eax
 shr eax,1
 and eax,$55555555
 sub edx,eax

 // result:=(result and $33333333)+((result shr 2) and $33333333);
 mov eax,edx
 shr edx,2
 and eax,$33333333
 and edx,$33333333
 add eax,edx

 // result:=(result+(result shr 4)) and $0f0f0f0f;
 mov edx,eax
 shr eax,4
 add eax,edx
 and eax,$0f0f0f0f

 // inc(result,result shr 8);
 mov edx,eax
 shr edx,8
 add eax,edx

 // inc(result,result shr 16);
 mov edx,eax
 shr edx,16
 add eax,edx

 // result:=result and $3f;
 and eax,$3f
end;

function POPCNTQWord(Value:TPasMPUInt64):TPasMPUInt32; assembler; stdcall;
asm
 mov eax,dword [Value+0]
 mov ecx,dword [Value+4]

 // result:=Value-((Value shr 1) and $55555555);
 mov edx,eax
 shr eax,1
 and eax,$55555555
 sub edx,eax

 // result:=(result and $33333333)+((result shr 2) and $33333333);
 mov eax,edx
 shr edx,2
 and eax,$33333333
 and edx,$33333333
 add eax,edx

 // result:=(result+(result shr 4)) and $0f0f0f0f;
 mov edx,eax
 shr eax,4
 add eax,edx
 and eax,$0f0f0f0f

 // inc(result,result shr 8);
 mov edx,eax
 shr edx,8
 add eax,edx

 // inc(result,result shr 16);
 mov edx,eax
 shr edx,16
 add eax,edx

 // result:=result and $3f;
 and eax,$3f

 xchg ecx,eax

 // result:=Value-((Value shr 1) and $55555555);
 mov edx,eax
 shr eax,1
 and eax,$55555555
 sub edx,eax

 // result:=(result and $33333333)+((result shr 2) and $33333333);
 mov eax,edx
 shr edx,2
 and eax,$33333333
 and edx,$33333333
 add eax,edx

 // result:=(result+(result shr 4)) and $0f0f0f0f;
 mov edx,eax
 shr eax,4
 add eax,edx
 and eax,$0f0f0f0f

 // inc(result,result shr 8);
 mov edx,eax
 shr edx,8
 add eax,edx

 // inc(result,result shr 16);
 mov edx,eax
 shr edx,16
 add eax,edx

 // result:=result and $3f;
 and eax,$3f

 add eax,ecx
end;
{$endif}

{$elseif defined(cpux86_64)}

{$ifndef fpc}
function BSFDWord(Value:TPasMPUInt32):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .NOFRAME
{$endif}
{$ifdef Windows}
 bsf eax,ecx
{$else}
 bsf eax,edi
{$endif}
 jnz @Done
 mov eax,255
@Done:
end;

function BSRDWord(Value:TPasMPUInt32):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .NOFRAME
{$endif}
{$ifdef Windows}
 bsr eax,ecx
{$else}
 bsr eax,edi
{$endif}
 jnz @Done
 mov eax,255
@Done:
end;

function BSFQWord(Value:TPasMPUInt64):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .NOFRAME
{$endif}
{$ifdef Windows}
 bsf rax,rcx
{$else}
 bsf rax,rdi
{$endif}
 jnz @Done
 mov eax,255
@Done:
end;

function BSRQWord(Value:TPasMPUInt64):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .NOFRAME
{$endif}
{$ifdef Windows}
 bsr rax,rcx
{$else}
 bsr rax,rdi
{$endif}
 jnz @Done
 mov eax,255
@Done:
end;

function CTZDWord(Value:TPasMPUInt32):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .NOFRAME
{$endif}
{$ifdef Windows}
 bsf eax,ecx
{$else}
 bsf eax,edi
{$endif}
 jnz @Done
 mov eax,32
@Done:
end;

function CLZDWord(Value:TPasMPUInt32):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .NOFRAME
{$endif}
{$ifdef Windows}
 bsr ecx,ecx
 jnz @Done
 xor ecx,ecx
 not ecx
@Done:
 mov eax,31
 sub eax,ecx
{$else}
 bsr edi,edi
 jnz @Done
 xor edi,edi
 not edi
@Done:
 mov eax,31
 sub eax,edi
{$endif}
end;

function CTZQWord(Value:TPasMPUInt64):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .NOFRAME
{$endif}
{$ifdef Windows}
 bsf rax,rcx
{$else}
 bsf rax,rdi
{$endif}
 jnz @Done
 mov eax,64
@Done:
end;

function CLZQWord(Value:TPasMPUInt64):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .NOFRAME
{$endif}
{$ifdef Windows}
 bsr rcx,rcx
 jnz @Done
 xor rcx,rcx
 not rcx
@Done:
 mov rax,63
 sub rax,rcx
{$else}
 bsr rdi,rdi
 jnz @Done
 xor rdi,rdi
 not rdi
@Done:
 mov rax,63
 sub rax,rdi
{$endif}
end;

function POPCNTDWord(Value:TPasMPUInt32):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .NOFRAME
{$endif}
{$ifdef Windows}
 mov eax,ecx
{$else}
 mov eax,edi
{$endif}

 // result:=Value-((Value shr 1) and $55555555);
 mov edx,eax
 shr eax,1
 and eax,$55555555
 sub edx,eax

 // result:=(result and $33333333)+((result shr 2) and $33333333);
 mov eax,edx
 shr edx,2
 and eax,$33333333
 and edx,$33333333
 add eax,edx

 // result:=(result+(result shr 4)) and $0f0f0f0f;
 mov edx,eax
 shr eax,4
 add eax,edx
 and eax,$0f0f0f0f

 // inc(result,result shr 8);
 mov edx,eax
 shr edx,8
 add eax,edx

 // inc(result,result shr 16);
 mov edx,eax
 shr edx,16
 add eax,edx

 // result:=result and $3f;
 and eax,$3f
end;

function POPCNTQWord(Value:TPasMPUInt64):TPasMPUInt32; assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .NOFRAME
{$endif}
{$ifdef Windows}
 mov rax,rcx
{$else}
 mov rax,rdi
{$endif}

 // result:=Value-((Value shr 1) and $5555555555555555);
 mov rdx,rax
 shr rax,1
 mov r8,$5555555555555555
 and rax,r8
 sub rdx,rax

 // result:=(result and $3333333333333333)+((result shr 2) and $3333333333333333);
 mov rax,rdx
 shr rdx,2
 mov r8,$3333333333333333
 and rax,r8
 and rdx,r8
 add rax,rdx

 // result:=(result+(result shr 4)) and $0f0f0f0f0f0f0f0f;
 mov rdx,rax
 shr rax,4
 add rax,rdx
 mov r8,$0f0f0f0f0f0f0f0f
 and rax,r8

 // inc(result,result shr 8);
 mov rdx,rax
 shr rdx,8
 add rax,rdx

 // inc(result,result shr 16);
 mov rdx,rax
 shr rdx,16
 add rax,rdx

 // inc(result,result shr 32);
 mov rdx,rax
 shr rdx,32
 add rax,rdx

 // result:=result and $7f;
 and rax,$7f
end;
{$endif}

{$elseif not defined(fpc)}

function UInt64Mul(a,b:TPasMPUInt64):TPasMPUInt64;{$ifdef cpu386}assembler; stdcall;
asm
 push ebx
 push esi
 push edi
  mov ebx,dword ptr [b+0]
  mov ecx,dword ptr [b+4]
  mov esi,dword ptr [a+0]
  mov edi,dword ptr [a+4]
  mov eax,edi
  mul ebx
  xchg eax,ebx
  mul esi
  xchg esi,eax
  add ebx,edx
  mul ecx
  lea edx,[eax+ebx]
  mov eax,esi
 pop edi
 pop esi
 pop ebx
end;
{$else}
{$ifdef cpu64}{$ifdef CAN_INLINE}inline;{$endif}
begin
 result:=a*b;
end;
{$else}
var al,ah,bl,bh,zl,zh:TPasMPUInt32;
begin
 al:=a and $ffffffff;
 ah:=a shr 32;
 bl:=b and $ffffffff;
 bh:=b shr 32;
 zl:=al*bl;
 zh:=(al*bh)+(ah*bl)+(((al shr 1)*(bl shr 1)) shr 30);
 result:=(uint64(zh) shl 32) or uint64(zl);
end;
{$endif}
{$endif}

function BSFDWord(Value:TPasMPUInt32):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
begin
 if Value=0 then begin
  result:=255;
 end else begin
  result:=PasMPBSFDebruijn32Table[(((Value and not (Value-1))*PasMPBSFDebruijn32Multiplicator) shr PasMPBSFDebruijn32Shift) and PasMPBSFDebruijn32Mask];
 end;
end;

function BSFQWord(Value:TPasMPUInt64):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
begin
 if Value=0 then begin
  result:=255;
 end else begin
  result:=PasMPBSFDebruijn64Table[(((Value and not (Value-1))*PasMPBSFDebruijn64Multiplicator) shr PasMPBSFDebruijn64Shift) and PasMPBSFDebruijn64Mask];
 end;
end;

function BSRDWord(Value:TPasMPUInt32):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
begin
 if Value=0 then begin
  result:=255;
 end else begin
  Value:=Value or (Value shr 1);
  Value:=Value or (Value shr 2);
  Value:=Value or (Value shr 4);
  Value:=Value or (Value shr 8);
  Value:=Value or (Value shr 16);
  result:=PasMPBSRDebruijn32Table[((Value*PasMPBSRDebruijn32Multiplicator) shr PasMPBSRDebruijn32Shift) and PasMPBSRDebruijn32Mask];
 end;
end;

function BSRQWord(Value:TPasMPUInt64):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
begin
 if Value=0 then begin
  result:=255;
 end else begin
  Value:=Value or (Value shr 1);
  Value:=Value or (Value shr 2);
  Value:=Value or (Value shr 4);
  Value:=Value or (Value shr 8);
  Value:=Value or (Value shr 16);
  Value:=Value or (Value shr 32);
  result:=PasMPBSRDebruijn64Table[((Value*PasMPBSRDebruijn64Multiplicator) shr PasMPBSRDebruijn64Shift) and PasMPBSRDebruijn64Mask];
 end;
end;

function CLZDWord(Value:TPasMPUInt32):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
begin
 if Value=0 then begin
  result:=32;
 end else begin
  Value:=Value or (Value shr 1);
  Value:=Value or (Value shr 2);
  Value:=Value or (Value shr 4);
  Value:=Value or (Value shr 8);
  Value:=Value or (Value shr 16);
  result:=PasMPCLZDebruijn32Table[((longword(Value)*PasMPCLZDebruijn32Multiplicator) shr PasMPCLZDebruijn32Shift) and PasMPCLZDebruijn32Mask];
 end;
end;

function CLZQWord(Value:TPasMPUInt64):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
begin
 if Value=0 then begin
  result:=64;
 end else begin
  Value:=Value or (Value shr 1);
  Value:=Value or (Value shr 2);
  Value:=Value or (Value shr 4);
  Value:=Value or (Value shr 8);
  Value:=Value or (Value shr 16);
  Value:=Value or (Value shr 32);
  result:=PasMPCLZDebruijn64Table[((Value*PasMPCLZDebruijn64Multiplicator) shr PasMPCLZDebruijn64Shift) and PasMPCLZDebruijn64Mask];
 end;
end;

function CTZDWord(Value:TPasMPUInt32):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
begin
 if Value=0 then begin
  result:=32;
 end else begin
  result:=PasMPCTZDebruijn32Table[((longword(Value and (-Value))*PasMPCTZDebruijn32Multiplicator) shr PasMPCTZDebruijn32Shift) and PasMPCTZDebruijn32Mask];
 end;
end;

function CTZQWord(Value:TPasMPUInt64):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
begin
 if Value=0 then begin
  result:=64;
 end else begin
  result:=PasMPCTZDebruijn64Table[(((Value and (-Value))*PasMPCTZDebruijn64Multiplicator) shr PasMPCTZDebruijn64Shift) and PasMPCTZDebruijn64Mask];
 end;
end;

function POPCNTDWord(Value:TPasMPUInt32):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
begin
 Value:=Value-((Value shr 1) and longword($55555555));
 Value:=(Value and longword($33333333))+((Value shr 2) and longword($33333333));
 Value:=(Value+(Value shr 4)) and longword($0f0f0f0f);
 inc(Value,Value shr 8);
 inc(Value,Value shr 16);
 result:=Value and $3f;
end;

function POPCNTQWord(Value:TPasMPUInt64):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
begin
 Value:=Value-((Value shr 1) and uint64($5555555555555555));
 Value:=(Value and uint64($3333333333333333))+((Value shr 2) and uint64($3333333333333333));
 Value:=(Value+(Value shr 4)) and uint64($0f0f0f0f0f0f0f0f);
 inc(Value,Value shr 8);
 inc(Value,Value shr 16);
 inc(Value,Value shr 32);
 result:=Value and $7f;
end;
{$ifend}

{$ifdef fpc}
function CTZDWord(Value:TPasMPUInt32):TPasMPUInt32; {$ifdef CAN_INLINE}inline;{$endif}
begin
 if Value=0 then begin
  result:=32;
 end else begin
  result:=BSFDWord(Value);
 end;
end;

function CLZDWord(Value:TPasMPUInt32):TPasMPUInt32; {$ifdef CAN_INLINE}inline;{$endif}
begin
 if Value=0 then begin
  result:=0;
 end else begin
  result:=31-BSRDWord(Value);
 end;
end;

function CTZQWord(Value:TPasMPUInt64):TPasMPUInt32; {$ifdef CAN_INLINE}inline;{$endif}
begin
 if Value=0 then begin
  result:=64;
 end else begin
  result:=BSFQWord(Value);
 end;
end;

function CLZQWord(Value:TPasMPUInt64):TPasMPUInt32; {$ifdef CAN_INLINE}inline;{$endif}
begin
 if Value=0 then begin
  result:=0;
 end else begin
  result:=63-BSRQWord(Value);
 end;
end;
{$endif}

{$if defined(FPC) and defined(CPUAArch64) and defined(PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE)}
(*function IsCASPInstructionSupported:Boolean; assembler;
asm
 .pushnv
 .arch armv8-a

 mrs x0, ID_AA64PFR0_EL1 // Read ID_AA64PFR0_EL1 system register into x0
 and x0, x0, #(15 shl 16) // Extract bits [19:16] to check the architecture version
 cmp x0, #(1 shl 16) // Compare the extracted bits with ARMv8.1-A
 b.ge 1f // If the architecture is ARMv8.1-A or later, set the return value to True

 mov x0, #0 // Set the return value to False (casp is not supported)
 b 2f

 1:
 mov x0, #1 // Set the return value to True (casp is supported)

 2:
 .popnv
end;*)

{$if defined(Darwin)}
// Using casp instruction (recommended for ARMv8.1-A and later)
(*function _InterlockedCompareExchange128_(Dest:PPasMPInt64;XChgHigh,XChgLow:TPasMPInt64;Compare:PPasMPInt64):TPasMPUInt8; assembler; nostackframe;
asm
 sub sp, sp, #32
 str x0, [sp, #24]
 str x1, [sp, #16]
 str x2, [sp, #8]
 str x3, [sp]
 ldr x8, [sp, #24]
 ldr x9, [sp]
 ldr q0, [x9]
 ldr x9, [sp, #16]
 mov x11, xzr
 ldr x10, [sp, #8]
 orr x2, x11, x10
 // orr x9, x9, x10, asr #63
 .byte 0x29
 .byte 0xfd
 .byte 0x8a
 .byte 0xaa
 fmov d2, d0
 mov d1, v0.d[1]
 fmov x0, d2
 fmov x1, d1
 mov x3, x9
 // caspal x0, x1, x2, x3, [x8]
 .byte 0xe8
 .byte 0x03
 .byte 0x00
 .byte 0xaa
 mov x8, x0
 mov x9, x1
 fmov d1, d0
 mov d0, v0.d[1]
 fmov x10, d1
 eor x8, x8, x10
 fmov x10, d0
 eor x9, x9, x10
 orr x8, x8, x9
 subs x8, x8, #0
 cset w8, eq
 and w0, w8, #0x1
 add sp, sp, #32
end;*)

procedure _InterlockedCompareExchange128(Dest:PPasMPInt64;XChgHigh,XChgLow:TPasMPInt64;Compare,Result_:PPasMPInt64); assembler; nostackframe;
asm
 sub sp, sp, #48
 str x0, [sp, #40]
 str x1, [sp, #32]
 str x2, [sp, #24]
 str x3, [sp, #16]
 str x4, [sp, #8]
 ldr x8, [sp, #40]
 ldr x9, [sp, #16]
 ldr q0, [x9]
 ldr x9, [sp, #32]
 mov x11, xzr
 ldr x10, [sp, #24]
 orr x2, x11, x10
 //.dword 0xaa8afd29 // orr x9, x9, x10, asr #63
 .byte 0x29
 .byte 0xfd
 .byte 0x8a
 .byte 0xaa
 fmov d1, d0
 mov d0, v0.d[1]
 fmov x0, d1
 fmov x1, d0
 mov x3, x9
 // .dword 0x4860fd02 // caspal x0, x1, x2, x3, [x8]
 .byte 0x02
 .byte 0xfd
 .byte 0x60
 .byte 0x48
 mov x9, x0
 mov x8, x1
 mov v0.d[0], x9
 mov v0.d[1], x8
 ldr x8, [sp, #8]
 str q0, [x8]
 add sp, sp, #48
end;
{$else}
// Using ldxp and stxp instructions (for broader compatibility, including ARMv8-A)
(*function _InterlockedCompareExchange128_(Dest:PPasMPInt64;XChgHigh,XChgLow:TPasMPInt64;Compare:PPasMPInt64):TPasMPUInt8; assembler; nostackframe;
label LBB0_1,LBB0_2,LBB0_3,LBB0_4;
asm
 sub sp, sp, #32
 str x0, [sp, #24]
 str x1, [sp, #16]
 str x2, [sp, #8]
 str x3, [sp]
 ldr x11, [sp, #24]
 ldr x8, [sp]
 ldr q0, [x8]
 ldr x8, [sp, #16]
 mov x10, xzr
 ldr x9, [sp, #8]
 orr x14, x10, x9
 // orr x15, x8, x9, asr #63
 .byte 0x0f
 .byte 0xfd
 .byte 0x89
 .byte 0xaa
 fmov d1, d0
 mov d2, v0.d[1]
 fmov x13, d2
 fmov x12, d1
LBB0_1: // =>This Inner Loop Header: Depth=1
 ldaxp x8, x9, [x11]
 cmp x8, x12
 cset w10, ne
 cmp x9, x13
 cinc w10, w10, ne
 cbnz w10, .LBB0_3
 stlxp w10, x14, x15, [x11]
 cbnz w10, LBB0_1
 b LBB0_4
LBB0_3: // in Loop: Header=BB0_1 Depth=1
 stlxp w10, x8, x9, [x11]
 cbnz w10, LBB0_1
LBB0_4:
 fmov d1, d0
 mov d0, v0.d[1]
 fmov x10, d1
 eor x8, x8, x10
 fmov x10, d0
 eor x9, x9, x10
 orr x8, x8, x9
 subs x8, x8, #0
 cset w8, eq
 and w0, w8, #0x1
 add sp, sp, #32
end;*)

procedure _InterlockedCompareExchange128(Dest:PPasMPInt64;XChgHigh,XChgLow:TPasMPInt64;Compare,Result_:PPasMPInt64); assembler; nostackframe;
label LBB1_1,LBB1_3,LBB1_4;
asm
 sub sp, sp, #48
 str x0, [sp, #40]
 str x1, [sp, #32]
 str x2, [sp, #24]
 str x3, [sp, #16]
 str x4, [sp, #8]
 ldr x11, [sp, #40]
 ldr x8, [sp, #16]
 ldr q1, [x8]
 ldr x8, [sp, #32]
 mov x10, xzr
 ldr x9, [sp, #24]
 orr x14, x10, x9
 // .dword 0xaa89fd0f // orr x15, x8, x9, asr #63
 .byte 0x0f
 .byte 0xfd
 .byte 0x89
 .byte 0xaa
 fmov d0, d1
 mov d1, v1.d[1]
 fmov x13, d1
 fmov x12, d0
LBB1_1: // =>This Inner Loop Header: Depth=1
 // .dword 0xc87fa169 // ldaxp x9, x8, [x11]
 .byte 0x69
 .byte 0xa1
 .byte 0x7f
 .byte 0xc8
 cmp x9, x12
 cset w10, ne
 cmp x8, x13
 cinc w10, w10, ne
 cbnz w10, LBB1_3
 stlxp w10, x14, x15, [x11]
 cbnz w10, LBB1_1
 b LBB1_4
LBB1_3: // in Loop: Header=BB1_1 Depth=1
 stlxp w10, x9, x8, [x11]
 cbnz w10, LBB1_1
LBB1_4:
 mov v0.d[0], x9
 mov v0.d[1], x8
 ldr x8, [sp, #8]
 str q0, [x8]
 add sp, sp, #48
end;
{$ifend}

function InterlockedCompareExchange128(var Destination:TPasMPInt128Record;const NewValue,Comperand:TPasMPInt128Record):TPasMPInt128Record;
begin
 _InterlockedCompareExchange128(PPasMPInt64(@Destination),NewValue.Hi,NewValue.Lo,PPasMPInt64(@Comperand),PPasMPInt64(@result));
end;

{$elseif defined(FPC) and defined(CPUARM) and defined(PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE)}
{$if defined(CPUARM_HAS_LDREX)}
function InterlockedCompareExchange64(var Destination:TPasMPInt64;NewValue,Comperand:TPasMPInt64):TPasMPInt64; assembler; {$ifdef fpc}nostackframe;{$else}register;{$endif}
label Loop;
asm
 // LDREXD and STREXD were introduced in ARM 11, so the LDREXD and STREXD instructions in
 // ARM all v7 variants or above. In v6, only some variants support it (ARMv6k).
 // the LDREXD and STREXD instructions demands that Rm be an even numbered register
 // This routine is for non-thumb code
 // Input:
 // r0 = pointer to Destination
 // r1 = NewValue.Lo
 // r2 = NewValue.Hi
 // r3 = Comperand.Lo
 // [sp] = Comperand.Hi
 stmfd sp!,{r4,r5,r6,r7}
 mov r4,r3 // r4 = Comperand.Lo (r3)
 ldr r5,[sp,#16] // r5 = Comperand.Hi ([sp+16])
 mov r6,r1 // r6 = NewValue.Lo (r1)
 mov r7,r2 // r7 = NewValue.Hi (r2)
 mov r2,r0 // r2 = pointer to Destination (r0)
{$if defined(CPUARM_HAS_DMB)} // >= CPUARMV7A
 .long 0xf57ff05f // dmb sy
{$elseif defined(CPUARMV6K)} // = CPUARMV6K
 .long 0xee072fba // mcr p15,0,r2,c7,c10,5
{$elseif defined(Linux) or defined(Android)} // Linux and Android with a kernel version >= 2.6.15 respectively _kuser_helper_version >= 3
 // r0 = kuser_memory_barrier at 0xffff0fa0 (see https://www.kernel.org/doc/Documentation/arm/kernel_user_helpers.txt)
 stmfd r13!,{lr}
 mvn r0,#0x0000f000
 sub r0,r0,#0x5f
{$if defined(CPUARM_HAS_BLX)}
 blx r0
{$elseif defined(CPUARM_HAS_BLX)}
 mov lr,pc
{$if defined(CPUARM_HAS_BX)}
 bx r0
{$else}
 mov pc,r0
{$ifend}
 ldmfd r13!,{pc}
{$ifend}
{$else} // Otherwise give up
 {$error Non-supported target platform configuration}
{$ifend}
Loop:
 ldrexd	r0,r1,[r2] // loads r0 and r1 from pointer to Destination (r2), so r0 = Destination.Lo, r1 = Destination.Hi
 eors r3,r0,r4 // compare Destination.Lo (r0) with Comperand.Lo (r4)
 eoreqs r3,r1,r5 // compare Destination.Hi (r1) with Comperand.Hi (r5)
 strexdeq r3,r6,r7,[r2]  // [r2]=r6 and [r2+4]=r7 and r3=result (0 for success or 1 for failure)
 teqeq r3,#1 // 1 for failure and 0 for success
 beq Loop // try again if failed
{$if defined(CPUARM_HAS_DMB)} // >= CPUARMV7A
 .long 0xf57ff05f // dmb sy
{$elseif defined(CPUARMV6K)} // = CPUARMV6K
 .long 0xee072fba // mcr p15,0,r2,c7,c10,5
{$elseif defined(Linux) or defined(Android)} // Linux and Android with a kernel version >= 2.6.15 respectively _kuser_helper_version >= 3
 // r0 = kuser_memory_barrier at 0xffff0fa0 (see https://www.kernel.org/doc/Documentation/arm/kernel_user_helpers.txt)
 stmfd r13!,{lr}
 mvn r0,#0x0000f000
 sub r0,r0,#0x5f
{$if defined(CPUARM_HAS_BLX)}
 blx r0
{$elseif defined(CPUARM_HAS_BLX)}
 mov lr,pc
{$if defined(CPUARM_HAS_BX)}
 bx r0
{$else}
 mov pc,r0
{$ifend}
 ldmfd r13!,{pc}
{$ifend}
{$else} // Otherwise give up
 {$error Non-supported target platform configuration}
{$ifend}
 // r0 and r1 should contain here now the old Lo and Hi values from pointer to Destination (r2) as
 // result value registers
 ldmfd sp!,{r4,r5,r6,r7}
end;
{$elseif defined(FPC) and defined(CPUAARCH64)}
function InterlockedCompareExchange128(var Destination:TPasMPInt128Record;const NewValue,Comperand:TPasMPInt128Record):TPasMPInt128Record; assembler; {$ifdef fpc}nostackframe;{$else}register;{$endif}
label Loop,Fail;
asm
 // Input:
 // x0 = pointer to Destination
 // x1 = NewValue.Lo
 // x2 = NewValue.Hi
 // x3 = Comperand.Lo
 // x4 = Comperand.Hi
 // x5 = Destination.Lo = [x0+0]
 // x6 = Destination.Hi = [x0+8]
 mov x6,x1
Loop:
 ldaxp x5,x1,[x0]
 cmp x5,x3
 bne Fail
 cmp x1,x4
 bne Fail
 stlxp w7,x6,x2,[x0]
 cbnz w7,Loop
Fail:
 mov x0,x5
 // x0 and x1 should contain here now the old Lo and Hi values from pointer to Destination (x0) as
 // result value registers
end;
{$elseif defined(Linux) or defined(Android)} // Linux and Android with a kernel version >= 3.1 respectively _kuser_helper_version >= 5
function InterlockedCompareExchange64(var Destination:TPasMPInt64;NewValue,Comperand:TPasMPInt64):TPasMPInt64;
type Tkuser__cmpxchg64=function(Comperand,NewValue,Destination:PPasMPInt64):TPasMPInt32;
begin
 if PPasMPInt32(Pointer(PtrUInt($ffff0ffc{__kuser__helper_version})))^>=5 then begin
  // Warning:
  // This assumes that the InterlockedCompareExchange64 caller uses the result only for
  // successful/failure checking, but not for other purposes
  result:=Destination;
  if Tkuser__cmpxchg64(Pointer(PtrUInt($ffff0f60{__kuser__cmpxchg64})))(@Comperand,@NewValue,@Destination)=0 then begin
   result:=Comperand;
  end else if result=Comperand then begin
   result:=not Comperand;
  end;
 end else begin
  Assert(false,'Non-supported target platform configuration');
  result:=not Comperand;
 end;
end;
{$else} // Otherwise give up
 {$error Non-supported target platform configuration}
{$ifend}

{$elseif defined(CPU386)}

function InterlockedCompareExchange64(var Destination:TPasMPInt64;NewValue,Comperand:TPasMPInt64):TPasMPInt64; assembler;
asm
 push ebx
 push edi
 mov edi,eax
 mov edx,dword ptr [Comperand+4]
 mov eax,dword ptr [Comperand+0]
 mov ecx,dword ptr [NewValue+4]
 mov ebx,dword ptr [NewValue+0]
 lock cmpxchg8b [edi]
 pop edi
 pop ebx
end;

{$elseif defined(CPUx86_64)}

function InterlockedCompareExchange128(var Destination:TPasMPInt128Record;const NewValue,Comperand:TPasMPInt128Record):TPasMPInt128Record; assembler; {$ifdef fpc}nostackframe;{$else}register;{$endif}
asm
 push rbx
{$ifdef Windows}
 push rcx
 mov rbx,qword ptr [r8]
 mov rcx,qword ptr [r8+8]
 mov r8,rdx
 mov rax,qword ptr [r9]
 mov rdx,qword ptr [r9+8]
 lock cmpxchg16b [r8]
 pop rcx
 mov qword ptr [rcx],rax
 mov qword ptr [rcx+8],rdx
{$else}
 mov rbx,rsi
 mov rax,rcx
 mov rcx,rdx
 mov rdx,r8
 lock cmpxchg16b [rdi]
{$endif}
 pop rbx
end;

{$ifend}

{$ifndef fpc}
{$ifdef CPU386}
function InterlockedDecrement(var Destination:TPasMPInt32):TPasMPInt32; assembler; {$ifdef fpc}nostackframe;{$else}register;{$endif}
asm
 mov edx,$ffffffff
 xchg eax,edx
 lock xadd dword ptr [edx],eax
 dec eax
end;

function InterlockedIncrement(var Destination:TPasMPInt32):TPasMPInt32; assembler; {$ifdef fpc}nostackframe;{$else}register;{$endif}
asm
 mov edx,1
 xchg eax,edx
 lock xadd dword ptr [edx],eax
 inc eax
end;

function InterlockedExchange(var Destination:TPasMPInt32;Source:TPasMPInt32):TPasMPInt32; assembler; {$ifdef fpc}nostackframe;{$else}register;{$endif}
asm
 lock xchg dword ptr [eax],edx
 mov eax,edx
end;

function InterlockedExchangePointer(var Destination:pointer;Source:pointer):pointer; assembler; {$ifdef fpc}nostackframe;{$else}register;{$endif}
asm
 lock xchg dword ptr [eax],edx
 mov eax,edx
end;

function InterlockedExchangeAdd(var Destination:TPasMPInt32;Source:TPasMPInt32):TPasMPInt32; assembler; {$ifdef fpc}nostackframe;{$else}register;{$endif}
asm
 xchg edx,eax
 lock xadd dword ptr [edx],eax
end;

function InterlockedCompareExchange(var Destination:TPasMPInt32;NewValue,Comperand:TPasMPInt32):TPasMPInt32; assembler; {$ifdef fpc}nostackframe;{$else}register;{$endif}
asm
 xchg ecx,eax
 lock cmpxchg dword ptr [ecx],edx
end;
{$else}
{$ifdef CPUx86_64}
function InterlockedDecrement(var Destination:TPasMPInt32):TPasMPInt32; assembler; {$ifdef fpc}nostackframe;{$else}register;{$endif}
asm
{$ifdef Windows}
 mov rax,rcx
{$else}
 mov rax,rdi
{$endif}
 mov edx,$ffffffff
 xchg rdx,rax
 lock xadd dword ptr [rdx],eax
 dec eax
end;

function InterlockedDecrement64(var Destination:TPasMPInt64):TPasMPInt64; assembler; {$ifdef fpc}nostackframe;{$else}register;{$endif}
asm
{$ifdef Windows}
 mov rax,rcx
{$else}
 mov rax,rdi
{$endif}
 mov rdx,$ffffffffffffffff
 xchg rdx,rax
 lock xadd qword ptr [rdx],rax
 dec rax
end;

function InterlockedIncrement(var Destination:TPasMPInt32):TPasMPInt32; assembler; {$ifdef fpc}nostackframe;{$else}register;{$endif}
asm
{$ifdef Windows}
 mov rax,rcx
{$else}
 mov rax,rdi
{$endif}
 mov edx,1
 xchg rdx,rax
 lock xadd dword ptr [rdx],eax
 inc eax
end;

function InterlockedIncrement64(var Destination:TPasMPInt64):TPasMPInt64; assembler; {$ifdef fpc}nostackframe;{$else}register;{$endif}
asm
{$ifdef Windows}
 mov rax,rcx
{$else}
 mov rax,rdi
{$endif}
 mov rdx,1
 xchg rdx,rax
 lock xadd qword ptr [rdx],rax
 inc rax
end;

function InterlockedExchange(var Destination:TPasMPInt32;Source:TPasMPInt32):TPasMPInt32; assembler; {$ifdef fpc}nostackframe;{$else}register;{$endif}
asm
{$ifdef Windows}
 lock xchg dword ptr [rcx],edx
 mov eax,edx
{$else}
 lock xchg dword ptr [rdi],esi
 mov eax,esi
{$endif}
end;

function InterlockedExchange64(var Destination:TPasMPInt64;NewValue:TPasMPInt64;Comperand:TPasMPInt64):TPasMPInt64; assembler; {$ifdef fpc}nostackframe;{$else}register;{$endif}
asm
{$ifdef Windows}
 lock xchg rdx,qword ptr [rcx]
 mov rax,rdx
{$else}
 lock xchg rsi,qword ptr [rdi]
 mov rax,rsi
{$endif}
end;

function InterlockedExchangePointer(var Destination:pointer;Source:pointer):pointer; assembler; {$ifdef fpc}nostackframe;{$else}register;{$endif}
asm
{$ifdef Windows}
 lock xchg rdx,qword ptr [rcx]
 mov rax,rdx
{$else}
 lock xchg rsi,qword ptr [rdi]
 mov rax,rsi
{$endif}
end;

function InterlockedExchangeAdd(var Destination:TPasMPInt32;Source:TPasMPInt32):TPasMPInt32; assembler; {$ifdef fpc}nostackframe;{$else}register;{$endif}
asm
{$ifdef Windows}
 xchg rdx,rcx
 lock xadd dword ptr [rdx],ecx
 mov eax,ecx
{$else}
 xchg rsi,rdi
 lock xadd dword ptr [rsi],edi
 mov eax,edi
{$endif}
end;

function InterlockedExchangeAdd64(var Destination:TPasMPInt64;NewValue:TPasMPInt64;Comperand:TPasMPInt64):TPasMPInt64; assembler; {$ifdef fpc}nostackframe;{$else}register;{$endif}
asm
{$ifdef Windows}
 xchg rdx,rcx
 lock xadd qword ptr [rdx],rcx
 mov rax,rcx
{$else}
 xchg rsi,rdi
 lock xadd qword ptr [rsi],rdi
 mov rax,rdi
{$endif}
end;

function InterlockedCompareExchange(var Destination:TPasMPInt32;NewValue,Comperand:TPasMPInt32):TPasMPInt32; assembler; {$ifdef fpc}nostackframe;{$else}register;{$endif}
asm
{$ifdef Windows}
 mov eax,r8d
 lock cmpxchg dword ptr [rcx],edx
{$else}
 mov eax,edx
 lock cmpxchg dword ptr [rdi],esi
{$endif}
end;

function InterlockedCompareExchange64(var Destination:TPasMPInt64;NewValue,Comperand:TPasMPInt64):TPasMPInt64; assembler; {$ifdef fpc}nostackframe;{$else}register;{$endif}
asm
{$ifdef Windows}
 mov rax,r8
 lock cmpxchg qword ptr [rcx],rdx
{$else}
 mov rax,rdx
 lock cmpxchg qword ptr [rdi],rsi
{$endif}
end;
{$else}
{$ifndef HAS_ATOMICS}
function InterlockedDecrement(var Destination:TPasMPInt32):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicDecrement(Destination);
{$else}
 result:=Windows.InterlockedDecrement(Destination);
{$endif}
end;

function InterlockedIncrement(var Destination:TPasMPInt32):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicIncrement(Destination);
{$else}
 result:=Windows.InterlockedIncrement(Destination);
{$endif}
end;

function InterlockedExchange(var Destination:TPasMPInt32;Source:TPasMPInt32):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicExchange(Destination,Source);
{$else}
 result:=Windows.InterlockedExchange(Destination,Source);
{$endif}
end;

function InterlockedExchangePointer(var Destination:pointer;Source:pointer):pointer; {$ifdef CAN_INLINE}inline;{$endif}
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicExchange(Destination,Source);
{$else}
 result:=Windows.InterlockedExchangePointer(Destination,Source);
{$endif}
end;

function InterlockedExchangeAdd(var Destination:TPasMPInt32;Source:TPasMPInt32):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
begin
{$ifdef HAS_ATOMICS}
 repeat
  result:=Destination;
 until AtomicCmpExchange(Destination,Destination+Source,Destination)=result;
{$else}
 result:=Windows.InterlockedExchangeAdd(Destination,Source);
{$endif}
end;

function InterlockedCompareExchange(var Destination:TPasMPInt32;NewValue,Comperand:TPasMPInt32):TPasMPInt32; {$ifdef CAN_INLINE}inline;{$endif}
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicCmpExchange(Destination,NewValue,Comperand);
{$else}
 result:=Windows.InterlockedCompareExchange(Destination,NewValue,Comperand);
{$endif}
end;

function InterlockedCompareExchange64(var Destination:TPasMPInt64;NewValue,Comperand:TPasMPInt64):TPasMPInt64; {$ifdef CAN_INLINE}inline;{$endif}
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicCmpExchange(Destination,NewValue,Comperand);
{$else}
 result:=Windows.InterlockedCompareExchange64(Destination,NewValue,Comperand);
{$endif}
end;
{$endif}
{$endif}
{$endif}
{$endif}

{$if defined(fpc)}

procedure FallbackMemoryBarrier; {$ifdef CAN_INLINE}inline;{$endif}
begin
 ReadWriteBarrier;
end;

{$elseif CompilerVersion>=25}

procedure FallbackReadBarrier; {$ifdef CAN_INLINE}inline;{$endif}
begin
 MemoryBarrier;
end;

procedure FallbackReadDependencyBarrier; {$ifdef CAN_INLINE}inline;{$endif}
begin
 // reads imply barrier on earlier reads depended on
end;

procedure FallbackReadWriteBarrier; {$ifdef CAN_INLINE}inline;{$endif}
begin
 MemoryBarrier;
end;

procedure FallbackWriteBarrier; {$ifdef CAN_INLINE}inline;{$endif}
begin
 MemoryBarrier;
end;

procedure FallbackMemoryBarrier; {$ifdef CAN_INLINE}inline;{$endif}
begin
 MemoryBarrier;
end;

{$elseif defined(CPU386)}

procedure FallbackReadBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
asm
 lfence
end;

procedure FallbackReadDependencyBarrier; {$ifdef CAN_INLINE}inline;{$endif}
begin
 // reads imply barrier on earlier reads depended on
end;

procedure FallbackReadWriteBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
asm
 mfence
end;

procedure FallbackWriteBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
asm
 sfence
end;

procedure FallbackMemoryBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
asm
 mfence
end;

{$elseif defined(CPUx64)}

procedure FallbackReadBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
asm
 lfence
end;

procedure FallbackReadDependencyBarrier; {$ifdef CAN_INLINE}inline;{$endif}
begin
 // reads imply barrier on earlier reads depended on
end;

procedure FallbackReadWriteBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
asm
 mfence
end;

procedure FallbackWriteBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
asm
 sfence
end;

procedure FallbackMemoryBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
asm
 mfence
end;

{$elseif defined(CPUAARCH64)}

procedure FallbackReadBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
asm
 .long 0xd50339bf // dmb ishld (or #9)
end;

procedure FallbackReadDependencyBarrier; {$ifdef CAN_INLINE}inline;{$endif}
begin
 // reads imply barrier on earlier reads depended on
end;

procedure FallbackReadWriteBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
asm
 .long 0xd5033bbf // dmb ish (or #11)
end;

procedure FallbackWriteBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
asm
 .long 0xd5033abf // dmb ishst or (#10)
end;

procedure FallbackMemoryBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
asm
 .long 0xd5033bbf // dmb ish (or #11)
end;

{$elseif defined(CPUARM)}

procedure FallbackReadBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
asm
{$if defined(CPUARM_HAS_DMB)} // >= CPUARMV7A
 .long 0xf57ff05f // dmb sy
{$elseif defined(CPUARMV6K)} // = CPUARMV6K
 mov r0,#0
 .long 0xee070fba // mcr p15,0,r2,c7,c10,5
{$elseif defined(Linux) or defined(Android)} // Linux and Android with a kernel version >= 2.6.15 respectively _kuser_helper_version >= 3
 // r0 = kuser_memory_barrier at 0xffff0fa0 (see https://www.kernel.org/doc/Documentation/arm/kernel_user_helpers.txt)
 stmfd r13!,{lr}
 mvn r0,#0x0000f000
 sub r0,r0,#0x5f
{$if defined(CPUARM_HAS_BLX)}
 blx r0
{$elseif defined(CPUARM_HAS_BLX)}
 mov lr,pc
{$if defined(CPUARM_HAS_BX)}
 bx r0
{$else}
 mov pc,r0
{$ifend}
 ldmfd r13!,{pc}
{$ifend}
{$else} // Otherwise give up
 {$error Non-supported target platform configuration}
{$ifend}
end;

procedure FallbackReadDependencyBarrier; {$ifdef CAN_INLINE}inline;{$endif}
begin
 // reads imply barrier on earlier reads depended on
end;

procedure FallbackReadWriteBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
asm
{$if defined(CPUARM_HAS_DMB)} // >= CPUARMV7A
 .long 0xf57ff05f // dmb sy
{$elseif defined(CPUARMV6K)} // = CPUARMV6K
 mov r0,#0
 .long 0xee070fba // mcr p15,0,r2,c7,c10,5
{$elseif defined(Linux) or defined(Android)} // Linux and Android with a kernel version >= 2.6.15 respectively _kuser_helper_version >= 3
 // r0 = kuser_memory_barrier at 0xffff0fa0 (see https://www.kernel.org/doc/Documentation/arm/kernel_user_helpers.txt)
 stmfd r13!,{lr}
 mvn r0,#0x0000f000
 sub r0,r0,#0x5f
{$if defined(CPUARM_HAS_BLX)}
 blx r0
{$elseif defined(CPUARM_HAS_BLX)}
 mov lr,pc
{$if defined(CPUARM_HAS_BX)}
 bx r0
{$else}
 mov pc,r0
{$ifend}
 ldmfd r13!,{pc}
{$ifend}
{$else} // Otherwise give up
 {$error Non-supported target platform configuration}
{$ifend}
end;

procedure FallbackWriteBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
asm
{$if defined(CPUARM_HAS_DMB)} // >= CPUARMV7A
 .long 0xf57ff05e // dmb st
{$elseif defined(CPUARMV6K)} // = CPUARMV6K
 mov r0,#0
 .long 0xee070fba // mcr p15,0,r2,c7,c10,5
{$elseif defined(Linux) or defined(Android)} // Linux and Android with a kernel version >= 2.6.15 respectively _kuser_helper_version >= 3
 // r0 = kuser_memory_barrier at 0xffff0fa0 (see https://www.kernel.org/doc/Documentation/arm/kernel_user_helpers.txt)
 stmfd r13!,{lr}
 mvn r0,#0x0000f000
 sub r0,r0,#0x5f
{$if defined(CPUARM_HAS_BLX)}
 blx r0
{$elseif defined(CPUARM_HAS_BLX)}
 mov lr,pc
{$if defined(CPUARM_HAS_BX)}
 bx r0
{$else}
 mov pc,r0
{$ifend}
 ldmfd r13!,{pc}
{$ifend}
{$else} // Otherwise give up
 {$error Non-supported target platform configuration}
{$ifend}
end;

procedure FallbackMemoryBarrier; assembler; {$ifdef fpc}nostackframe; {$ifdef CAN_INLINE}inline;{$endif}{$endif}
asm
{$if defined(CPUARM_HAS_DMB)} // >= CPUARMV7A
 .long 0xf57ff05f // dmb sy
{$elseif defined(CPUARMV6K)} // = CPUARMV6K
 mov r0,#0
 .long 0xee070fba // mcr p15,0,r2,c7,c10,5
{$elseif defined(Linux) or defined(Android)} // Linux and Android with a kernel version >= 2.6.15 respectively _kuser_helper_version >= 3
 // r0 = kuser_memory_barrier at 0xffff0fa0 (see https://www.kernel.org/doc/Documentation/arm/kernel_user_helpers.txt)
 stmfd r13!,{lr}
 mvn r0,#0x0000f000
 sub r0,r0,#0x5f
{$if defined(CPUARM_HAS_BLX)}
 blx r0
{$elseif defined(CPUARM_HAS_BLX)}
 mov lr,pc
{$if defined(CPUARM_HAS_BX)}
 bx r0
{$else}
 mov pc,r0
{$ifend}
 ldmfd r13!,{pc}
{$ifend}
{$else} // Otherwise give up
 {$error Non-supported target platform configuration}
{$ifend}
end;

{$else}
procedure FallbackReadBarrier; {$ifdef CAN_INLINE}inline;{$endif}
begin
end;

procedure FallbackReadDependencyBarrier; {$ifdef CAN_INLINE}inline;{$endif}
begin
 // reads imply barrier on earlier reads depended on
end;

procedure FallbackReadWriteBarrier; {$ifdef CAN_INLINE}inline;{$endif}
begin
end;

procedure FallbackWriteBarrier; {$ifdef CAN_INLINE}inline;{$endif}
begin
end;

procedure FallbackMemoryBarrier; {$ifdef CAN_INLINE}inline;{$endif}
begin
{$ifdef fpc}
 ReadWriteBarrier;
{$else}
 FallBackReadWriteBarrier;
{$endif}
end;
{$ifend}

procedure MemorySwap(a,b:pointer;Size:TPasMPInt32);
var Temp:TPasMPUInt32;
begin
 while Size>=SizeOf(TPasMPUInt32) do begin
  Temp:=TPasMPUInt32(a^);
  TPasMPUInt32(a^):=TPasMPUInt32(b^);
  TPasMPUInt32(b^):=Temp;
  inc(TPasMPPtrUInt(a),SizeOf(TPasMPUInt32));
  inc(TPasMPPtrUInt(b),SizeOf(TPasMPUInt32));
  dec(Size,SizeOf(TPasMPUInt32));
 end;
 while Size>=SizeOf(TPasMPUInt8) do begin
  Temp:=TPasMPUInt8(a^);
  TPasMPUInt8(a^):=TPasMPUInt8(b^);
  TPasMPUInt8(b^):=Temp;
  inc(TPasMPPtrUInt(a),SizeOf(TPasMPUInt8));
  inc(TPasMPPtrUInt(b),SizeOf(TPasMPUInt8));
  dec(Size,SizeOf(TPasMPUInt8));
 end;
end;

class function TPasMPMath.PopulationCount32(Value:TPasMPUInt32):TPasMPInt32;
begin
{$ifdef fpc}
 result:=PopCnt(Value);
{$else}
 result:=POPCNTDWord(Value);
{$endif}
end;

class function TPasMPMath.PopulationCount64(Value:TPasMPUInt64):TPasMPInt32;
begin
{$ifdef fpc}
 result:=PopCnt(Value);
{$else}
 result:=POPCNTQWord(Value);
{$endif}
end;

class function TPasMPMath.PopulationCount(Value:TPasMPPtrUInt):TPasMPInt32;
begin
{$ifdef fpc}
 result:=PopCnt(Value);
{$else}
{$ifdef CPU64}
 result:=POPCNTQWord(Value);
{$else}
 result:=POPCNTDWord(Value);
{$endif}
{$endif}
end;

class function TPasMPMath.BitScanForward32(Value:TPasMPUInt32):TPasMPInt32;
begin
 result:=BSFDWord(Value);
end;

class function TPasMPMath.BitScanForward64(Value:TPasMPUInt64):TPasMPInt32;
begin
 result:=BSFQWord(Value);
end;

class function TPasMPMath.BitScanForward(Value:TPasMPPtrUInt):TPasMPInt32;
begin
{$ifdef CPU64}
 result:=BSFQWord(Value);
{$else}
 result:=BSFDWord(Value);
{$endif}
end;

class function TPasMPMath.BitScanReverse32(Value:TPasMPUInt32):TPasMPInt32;
begin
 result:=BSRDWord(Value);
end;

class function TPasMPMath.BitScanReverse64(Value:TPasMPUInt64):TPasMPInt32;
begin
 result:=BSRQWord(Value);
end;

class function TPasMPMath.BitScanReverse(Value:TPasMPPtrUInt):TPasMPInt32;
begin
{$ifdef CPU64}
 result:=BSRQWord(Value);
{$else}
 result:=BSRDWord(Value);
{$endif}
end;

class function TPasMPMath.CountLeadingZeros32(Value:TPasMPUInt32):TPasMPInt32;
begin
 result:=CLZDWord(Value);
end;

class function TPasMPMath.CountLeadingZeros64(Value:TPasMPUInt64):TPasMPInt32;
begin
 result:=CLZQWord(Value);
end;

class function TPasMPMath.CountLeadingZeros(Value:TPasMPPtrUInt):TPasMPInt32;
begin
{$ifdef CPU64}
 result:=CLZQWord(Value);
{$else}
 result:=CLZDWord(Value);
{$endif}
end;

class function TPasMPMath.CountTrailingZeros32(Value:TPasMPUInt32):TPasMPInt32;
begin
 result:=CTZDWord(Value);
end;

class function TPasMPMath.CountTrailingZeros64(Value:TPasMPUInt64):TPasMPInt32;
begin
 result:=CTZQWord(Value);
end;

class function TPasMPMath.CountTrailingZeros(Value:TPasMPPtrUInt):TPasMPInt32;
begin
{$ifdef CPU64}
 result:=CTZQWord(Value);
{$else}
 result:=CTZDWord(Value);
{$endif}
end;

class function TPasMPMath.FindFirstSetBit32(Value:TPasMPUInt32):TPasMPInt32;
begin
 if Value=0 then begin
  result:=-1;
 end else begin
  result:=BSFDWord(Value);
 end;
end;

class function TPasMPMath.FindFirstSetBit64(Value:TPasMPUInt64):TPasMPInt32;
begin
 if Value=0 then begin
  result:=-1;
 end else begin
  result:=BSFQWord(Value);
 end;
end;

class function TPasMPMath.FindFirstSetBit(Value:TPasMPPtrUInt):TPasMPInt32;
begin
 if Value=0 then begin
  result:=-1;
 end else begin
{$ifdef CPU64}
  result:=BSFQWord(Value);
{$else}
  result:=BSFDWord(Value);
{$endif}
 end;
end;

class function TPasMPMath.RoundUpToPowerOfTwo32(Value:TPasMPUInt32):TPasMPUInt32;
begin
 dec(Value);
 Value:=Value or (Value shr 1);
 Value:=Value or (Value shr 2);
 Value:=Value or (Value shr 4);
 Value:=Value or (Value shr 8);
 Value:=Value or (Value shr 16);
 result:=Value+1;
end;

class function TPasMPMath.RoundUpToPowerOfTwo64(Value:TPasMPUInt64):TPasMPUInt64;
begin
 dec(Value);
 Value:=Value or (Value shr 1);
 Value:=Value or (Value shr 2);
 Value:=Value or (Value shr 4);
 Value:=Value or (Value shr 8);
 Value:=Value or (Value shr 16);
 Value:=Value or (Value shr 32);
 result:=Value+1;
end;

class function TPasMPMath.RoundUpToPowerOfTwo(Value:TPasMPPtrUInt):TPasMPPtrUInt;
begin
 dec(Value);
 Value:=Value or (Value shr 1);
 Value:=Value or (Value shr 2);
 Value:=Value or (Value shr 4);
 Value:=Value or (Value shr 8);
 Value:=Value or (Value shr 16);
{$ifdef CPU64}
 Value:=Value or (Value shr 32);
{$endif}
 result:=Value+1;
end;

class function TPasMPMath.RoundUpToMask32(Value,Mask:TPasMPUInt32):TPasMPUInt32;
begin
 if (Value and (Mask-1))<>0 then begin
  result:=(Value+Mask) and not (Mask-1);
 end else begin
  result:=Value;
 end;
end;

class function TPasMPMath.RoundUpToMask64(Value,Mask:TPasMPUInt64):TPasMPUInt64;
begin
 if (Value and (Mask-1))<>0 then begin
  result:=(Value+Mask) and not (Mask-1);
 end else begin
  result:=Value;
 end;
end;

class function TPasMPMath.RoundUpToMask(Value,Mask:TPasMPPtrUInt):TPasMPPtrUInt;
begin
 if (Value and (Mask-1))<>0 then begin
  result:=(Value+Mask) and not (Mask-1);
 end else begin
  result:=Value;
 end;
end;

class function TPasMP.GetThreadIDHash(ThreadID:{$ifdef fpc}TThreadID{$else}TPasMPUInt32{$endif}):TPasMPUInt32;
{$if defined(Darwin)}
var ThreadIDCasted:TPasMPUInt32 absolute ThreadID;
{$ifend}
begin
{$if defined(Darwin)}
 result:=(ThreadIDCasted*83492791) xor ((ThreadIDCasted shr 24)*19349669) xor ((ThreadIDCasted shr 16)*73856093) xor ((ThreadIDCasted shr 8)*50331653);
{$else}
 result:=(ThreadID*83492791) xor ((ThreadID shr 24)*19349669) xor ((ThreadID shr 16)*73856093) xor ((ThreadID shr 8)*50331653);
{$ifend}
end;

class function TPasMP.EncodeJobPriorityToJobFlags(const JobPriority:TPasMPJobPriority):TPasMPUInt32;
begin
 case JobPriority of
  pmjpLow:begin
   result:=PasMPJobPriorityLow;
  end;
  pmjpNormal:begin
   result:=PasMPJobPriorityNormal;
  end;
  pmjpHigh:begin
   result:=PasMPJobPriorityHigh;
  end;
  else begin
   result:=PasMPJobPriorityInherited;
  end;
 end;
end;

class function TPasMP.DecodeJobPriorityFromJobFlags(const Flags:TPasMPUInt32):TPasMPJobPriority;
begin
 case Flags and PasMPJobPriorityMask of
  PasMPJobPriorityLow:begin
   result:=pmjpLow;
  end;
  PasMPJobPriorityNormal:begin
   result:=pmjpNormal;
  end;
  PasMPJobPriorityHigh:begin
   result:=pmjpHigh;
  end;
  else begin
   result:=pmjpInherited;
  end;
 end;
end;

class function TPasMP.EncodeJobTagToJobFlags(const JobTag:TPasMPUInt32):TPasMPUInt32;
begin
 result:=(JobTag and PasMPJobTagMask) shl PasMPJobTagShift;
end;

class function TPasMP.DecodeJobTagFromJobFlags(const Flags:TPasMPUInt32):TPasMPUInt32;
begin
 result:=(Flags shr PasMPJobTagShift) and PasMPJobTagMask;
end;

class procedure TPasMP.Relax;{$if defined(CPU386)}assembler;
asm
 db $f3,$90 // pause (rep nop)
end;
{$elseif defined(CPUx86_64)}assembler;
asm
 pause
end;
{$else}
begin
{$ifdef fpc}
 TPasMP.Yield;
{$else}
 YieldProcessor;
{$endif}
end;
{$ifend}

class procedure TPasMP.Yield;
{$if defined(Windows)}
begin
 SwitchToThread;
end;
{$elseif defined(Unix)}
{$if defined(fpc) and defined(usecthreads)}
begin
 sched_yield;
end;
{$elseif defined(fpc)}
var timeout:timeval;
begin
 timeout.tv_sec:=0;
 timeout.tv_usec:=0;
 fpselect(0,nil,nil,nil,@timeout);
end;
{$else}
begin
 TThread.Yield;
end;
{$ifend}
{$elseif defined(fpc)}
begin
 ThreadSwitch;
end;
{$else}
begin
 TThread.Yield;
end;
{$ifend}

class function TPasMPInterlocked.Increment(var Destination:TPasMPInt32):TPasMPInt32;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicIncrement(Destination);
{$else}
 result:=InterlockedIncrement(Destination);
{$endif}
end;

class function TPasMPInterlocked.Increment(var Destination:TPasMPUInt32):TPasMPUInt32;
begin
{$ifdef HAS_ATOMICS}
 result:=TPasMPUInt32(TPasMPInt32(AtomicIncrement(TPasMPInt32(Destination))));
{$else}
 result:=TPasMPUInt32(TPasMPInt32(InterlockedIncrement(TPasMPInt32(Destination))));
{$endif}
end;

{$ifdef CPU64}
class function TPasMPInterlocked.Increment(var Destination:TPasMPInt64):TPasMPInt64;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicIncrement(Destination);
{$else}
 result:=InterlockedIncrement64(Destination);
{$endif}
end;

class function TPasMPInterlocked.Increment(var Destination:TPasMPUInt64):TPasMPUInt64;
begin
{$ifdef HAS_ATOMICS}
 result:=TPasMPUInt64(TPasMPInt64(AtomicIncrement(TPasMPInt64(Destination))));
{$else}
 result:=TPasMPUInt64(TPasMPInt64(InterlockedIncrement64(TPasMPInt64(Destination))));
{$endif}
end;
{$endif}

class function TPasMPInterlocked.Decrement(var Destination:TPasMPInt32):TPasMPInt32;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicDecrement(Destination);
{$else}
 result:=InterlockedDecrement(Destination);
{$endif}
end;

class function TPasMPInterlocked.Decrement(var Destination:TPasMPUInt32):TPasMPUInt32;
begin
{$ifdef HAS_ATOMICS}
 result:=TPasMPUInt32(TPasMPInt32(AtomicDecrement(TPasMPInt32(Destination))));
{$else}
 result:=TPasMPUInt32(TPasMPInt32(InterlockedDecrement(TPasMPInt32(Destination))));
{$endif}
end;

{$ifdef CPU64}
class function TPasMPInterlocked.Decrement(var Destination:TPasMPInt64):TPasMPInt64;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicDecrement(Destination);
{$else}
 result:=InterlockedDecrement64(Destination);
{$endif}
end;

class function TPasMPInterlocked.Decrement(var Destination:TPasMPUInt64):TPasMPUInt64;
begin
{$ifdef HAS_ATOMICS}
 result:=TPasMPUInt64(TPasMPInt64(AtomicDecrement(TPasMPInt64(Destination))));
{$else}
 result:=TPasMPUInt64(TPasMPInt64(InterlockedDecrement64(TPasMPInt64(Destination))));
{$endif}
end;
{$endif}

class function TPasMPInterlocked.Add(var Destination:TPasMPInt32;const Value:TPasMPInt32):TPasMPInt32;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicIncrement(Destination,Value)-Value;
{$else}
 result:=InterlockedExchangeAdd(Destination,Value);
{$endif}
end;

class function TPasMPInterlocked.Add(var Destination:TPasMPUInt32;const Value:TPasMPUInt32):TPasMPUInt32;
begin
{$ifdef HAS_ATOMICS}
 result:=TPasMPUInt32(TPasMPInt32(AtomicIncrement(TPasMPInt32(Destination),TPasMPInt32(Value))-TPasMPInt32(Value)));
{$else}
 result:=TPasMPUInt32(TPasMPInt32(InterlockedExchangeAdd(TPasMPInt32(Destination),TPasMPInt32(Value))));
{$endif}
end;

{$ifdef CPU64}
class function TPasMPInterlocked.Add(var Destination:TPasMPInt64;const Value:TPasMPInt64):TPasMPInt64;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicIncrement(Destination,Value)-Value;
{$else}
 result:=InterlockedExchangeAdd64(Destination,Value);
{$endif}
end;

class function TPasMPInterlocked.Add(var Destination:TPasMPUInt64;const Value:TPasMPUInt64):TPasMPUInt64;
begin
{$ifdef HAS_ATOMICS}
 result:=TPasMPUInt64(TPasMPInt64(AtomicIncrement(TPasMPInt64(Destination),TPasMPInt64(Value))-TPasMPInt64(Value)));
{$else}
 result:=TPasMPUInt64(TPasMPInt64(InterlockedExchangeAdd64(TPasMPInt64(Destination),TPasMPInt64(Value))));
{$endif}
end;
{$endif}

class function TPasMPInterlocked.Sub(var Destination:TPasMPInt32;const Value:TPasMPInt32):TPasMPInt32;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicIncrement(Destination,-Value)+Value;
{$else}
 result:=InterlockedExchangeAdd(Destination,-Value);
{$endif}
end;

class function TPasMPInterlocked.Sub(var Destination:TPasMPUInt32;const Value:TPasMPUInt32):TPasMPUInt32;
begin
{$ifdef HAS_ATOMICS}
 result:=TPasMPUInt32(TPasMPInt32(AtomicIncrement(TPasMPInt32(Destination),-TPasMPInt32(Value))+TPasMPInt32(Value)));
{$else}
 result:=TPasMPUInt32(TPasMPInt32(InterlockedExchangeAdd(TPasMPInt32(Destination),-TPasMPInt32(Value))));
{$endif}
end;

{$ifdef CPU64}
class function TPasMPInterlocked.Sub(var Destination:TPasMPInt64;const Value:TPasMPInt64):TPasMPInt64;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicIncrement(Destination,-Value)+Value;
{$else}
 result:=InterlockedExchangeAdd64(Destination,-Value);
{$endif}
end;

class function TPasMPInterlocked.Sub(var Destination:TPasMPUInt64;const Value:TPasMPUInt64):TPasMPUInt64;
begin
{$ifdef HAS_ATOMICS}
 result:=TPasMPUInt64(TPasMPInt64(AtomicIncrement(TPasMPInt64(Destination),-TPasMPInt64(Value))+TPasMPInt64(Value)));
{$else}
 result:=TPasMPUInt64(TPasMPInt64(InterlockedExchangeAdd64(TPasMPInt64(Destination),-TPasMPInt64(Value))));
{$endif}
end;
{$endif}

class procedure TPasMPInterlocked.BitwiseAnd(var Destination:TPasMPInt32;const Value:TPasMPInt32);
{$if defined(cpu386)}
asm
{$ifdef HAS_STATIC}
 lock and dword ptr [eax],edx
{$else}
 lock and dword ptr [edx],ecx
{$endif}
end;
{$elseif defined(cpux86_64)}
asm
{$ifdef Windows}
 // Win64 ABI
 // rcx = Parameter 1
 // rdx = Parameter 2
 // r8 = Parameter 3
{$ifdef HAS_STATIC}
 lock and dword ptr [rcx],edx
{$else}
 lock and dword ptr [rdx],r8d
{$endif}
{$else}
 // System V ABI
 // rdi = self
 // rsi = Job
 // rdx = Temporary
{$ifdef HAS_STATIC}
 lock and dword ptr [rdi],esi
{$else}
 lock and dword ptr [rsi],edx
{$endif}
{$endif}
end;
{$else}
var OldValue:TPasMPInt32;
begin
 repeat
  OldValue:=Destination;
{$ifdef HAS_ATOMICS}
 until AtomicCmpExchange(Destination,OldValue and Value,OldValue)=OldValue;
{$else}
 until InterlockedCompareExchange(Destination,OldValue and Value,OldValue)=OldValue;
{$endif}
end;
{$ifend}

class procedure TPasMPInterlocked.BitwiseAnd(var Destination:TPasMPUInt32;const Value:TPasMPUInt32);
{$if defined(cpu386)}
asm
{$ifdef HAS_STATIC}
 lock and dword ptr [eax],edx
{$else}
 lock and dword ptr [edx],ecx
{$endif}
end;
{$elseif defined(cpux86_64)}
asm
{$ifdef Windows}
 // Win64 ABI
 // rcx = Parameter 1
 // rdx = Parameter 2
 // r8 = Parameter 3
{$ifdef HAS_STATIC}
 lock and dword ptr [rcx],edx
{$else}
 lock and dword ptr [rdx],r8d
{$endif}
{$else}
 // System V ABI
 // rdi = self
 // rsi = Job
 // rdx = Temporary
{$ifdef HAS_STATIC}
 lock and dword ptr [rdi],esi
{$else}
 lock and dword ptr [rsi],edx
{$endif}
{$endif}
end;
{$else}
var OldValue:TPasMPUInt32;
begin
 repeat
  OldValue:=Destination;
{$ifdef HAS_ATOMICS}
 until TPasMPUInt32(TPasMPInt32(AtomicCmpExchange(TPasMPInt32(Destination),TPasMPInt32(OldValue and Value),TPasMPInt32(OldValue))))=OldValue;
{$else}
 until TPasMPUInt32(TPasMPInt32(InterlockedCompareExchange(TPasMPInt32(Destination),TPasMPInt32(OldValue and Value),TPasMPInt32(OldValue))))=OldValue;
{$endif}
end;
{$ifend}

{$ifdef CPU64}
class procedure TPasMPInterlocked.BitwiseAnd(var Destination:TPasMPInt64;const Value:TPasMPInt64);
{$if defined(cpux86_64)}
asm
{$ifdef Windows}
 // Win64 ABI
 // rcx = Parameter 1
 // rdx = Parameter 2
 // r8 = Parameter 3
{$ifdef HAS_STATIC}
 lock and qword ptr [rcx],rdx
{$else}
 lock and qword ptr [rdx],r8
{$endif}
{$else}
 // System V ABI
 // rdi = self
 // rsi = Job
 // rdx = Temporary
{$ifdef HAS_STATIC}
 lock and qword ptr [rdi],rsi
{$else}
 lock and qword ptr [rsi],rdx
{$endif}
{$endif}
end;
{$else}
var OldValue:TPasMPInt64;
begin
 repeat
  OldValue:=Destination;
{$ifdef HAS_ATOMICS}
 until AtomicCmpExchange(Destination,OldValue and Value,OldValue)=OldValue;
{$else}
 until InterlockedCompareExchange64(Destination,OldValue and Value,OldValue)=OldValue;
{$endif}
end;
{$ifend}

class procedure TPasMPInterlocked.BitwiseAnd(var Destination:TPasMPUInt64;const Value:TPasMPUInt64);
{$if defined(cpux86_64)}
asm
{$ifdef Windows}
 // Win64 ABI
 // rcx = Parameter 1
 // rdx = Parameter 2
 // r8 = Parameter 3
{$ifdef HAS_STATIC}
 lock and qword ptr [rcx],rdx
{$else}
 lock and qword ptr [rdx],r8
{$endif}
{$else}
 // System V ABI
 // rdi = self
 // rsi = Job
 // rdx = Temporary
{$ifdef HAS_STATIC}
 lock and qword ptr [rdi],rsi
{$else}
 lock and qword ptr [rsi],rdx
{$endif}
{$endif}
end;
{$else}
var OldValue:TPasMPInt64;
begin
 repeat
  OldValue:=Destination;
{$ifdef HAS_ATOMICS}
 until TPasMPUInt64(TPasMPInt64(AtomicCmpExchange(TPasMPInt64(Destination),TPasMPInt64(OldValue and Value),TPasMPInt64(OldValue))))=OldValue;
{$else}
 until TPasMPUInt64(TPasMPInt64(InterlockedCompareExchange64(TPasMPInt64(Destination),TPasMPInt64(OldValue and Value),TPasMPInt64(OldValue))))=OldValue;
{$endif}
end;
{$ifend}
{$endif}

class procedure TPasMPInterlocked.BitwiseOr(var Destination:TPasMPInt32;const Value:TPasMPInt32);
{$if defined(cpu386)}
asm
{$ifdef HAS_STATIC}
 lock or dword ptr [eax],edx
{$else}
 lock or dword ptr [edx],ecx
{$endif}
end;
{$elseif defined(cpux86_64)}
asm
{$ifdef Windows}
 // Win64 ABI
 // rcx = Parameter 1
 // rdx = Parameter 2
 // r8 = Parameter 3
{$ifdef HAS_STATIC}
 lock or dword ptr [rcx],edx
{$else}
 lock or dword ptr [rdx],r8d
{$endif}
{$else}
 // System V ABI
 // rdi = self
 // rsi = Job
 // rdx = Temporary
{$ifdef HAS_STATIC}
 lock or dword ptr [rdi],esi
{$else}
 lock or dword ptr [rsi],edx
{$endif}
{$endif}
end;
{$else}
var OldValue:TPasMPInt32;
begin
 repeat
  OldValue:=Destination;
{$ifdef HAS_ATOMICS}
 until AtomicCmpExchange(Destination,OldValue or Value,OldValue)=OldValue;
{$else}
 until InterlockedCompareExchange(Destination,OldValue or Value,OldValue)=OldValue;
{$endif}
end;
{$ifend}

class procedure TPasMPInterlocked.BitwiseOr(var Destination:TPasMPUInt32;const Value:TPasMPUInt32);
{$if defined(cpu386)}
asm
{$ifdef HAS_STATIC}
 lock or dword ptr [eax],edx
{$else}
 lock or dword ptr [edx],ecx
{$endif}
end;
{$elseif defined(cpux86_64)}
asm
{$ifdef Windows}
 // Win64 ABI
 // rcx = Parameter 1
 // rdx = Parameter 2
 // r8 = Parameter 3
{$ifdef HAS_STATIC}
 lock or dword ptr [rcx],edx
{$else}
 lock or dword ptr [rdx],r8d
{$endif}
{$else}
 // System V ABI
 // rdi = self
 // rsi = Job
 // rdx = Temporary
{$ifdef HAS_STATIC}
 lock or dword ptr [rdi],esi
{$else}
 lock or dword ptr [rsi],edx
{$endif}
{$endif}
end;
{$else}
var OldValue:TPasMPUInt32;
begin
 repeat
  OldValue:=Destination;
{$ifdef HAS_ATOMICS}
 until TPasMPUInt32(TPasMPInt32(AtomicCmpExchange(TPasMPInt32(Destination),TPasMPInt32(OldValue or Value),TPasMPInt32(OldValue))))=OldValue;
{$else}
 until TPasMPUInt32(TPasMPInt32(InterlockedCompareExchange(TPasMPInt32(Destination),TPasMPInt32(OldValue or Value),TPasMPInt32(OldValue))))=OldValue;
{$endif}
end;
{$ifend}

{$ifdef CPU64}
class procedure TPasMPInterlocked.BitwiseOr(var Destination:TPasMPInt64;const Value:TPasMPInt64);
{$if defined(cpux86_64)}
asm
{$ifdef Windows}
 // Win64 ABI
 // rcx = Parameter 1
 // rdx = Parameter 2
 // r8 = Parameter 3
{$ifdef HAS_STATIC}
 lock or qword ptr [rcx],rdx
{$else}
 lock or qword ptr [rdx],r8
{$endif}
{$else}
 // System V ABI
 // rdi = self
 // rsi = Job
 // rdx = Temporary
{$ifdef HAS_STATIC}
 lock or qword ptr [rdi],rsi
{$else}
 lock or qword ptr [rsi],rdx
{$endif}
{$endif}
end;
{$else}
var OldValue:TPasMPInt64;
begin
 repeat
  OldValue:=Destination;
{$ifdef HAS_ATOMICS}
 until AtomicCmpExchange(Destination,OldValue or Value,OldValue)=OldValue;
{$else}
 until InterlockedCompareExchange64(Destination,OldValue or Value,OldValue)=OldValue;
{$endif}
end;
{$ifend}

class procedure TPasMPInterlocked.BitwiseOr(var Destination:TPasMPUInt64;const Value:TPasMPUInt64);
{$if defined(cpux86_64)}
asm
{$ifdef Windows}
 // Win64 ABI
 // rcx = Parameter 1
 // rdx = Parameter 2
 // r8 = Parameter 3
{$ifdef HAS_STATIC}
 lock or qword ptr [rcx],rdx
{$else}
 lock or qword ptr [rdx],r8
{$endif}
{$else}
 // System V ABI
 // rdi = self
 // rsi = Job
 // rdx = Temporary
{$ifdef HAS_STATIC}
 lock or qword ptr [rdi],rsi
{$else}
 lock or qword ptr [rsi],rdx
{$endif}
{$endif}
end;
{$else}
var OldValue:TPasMPInt64;
begin
 repeat
  OldValue:=Destination;
{$ifdef HAS_ATOMICS}
 until TPasMPUInt64(TPasMPInt64(AtomicCmpExchange(TPasMPInt64(Destination),TPasMPInt64(OldValue or Value),TPasMPInt64(OldValue))))=OldValue;
{$else}
 until TPasMPUInt64(TPasMPInt64(InterlockedCompareExchange64(TPasMPInt64(Destination),TPasMPInt64(OldValue or Value),TPasMPInt64(OldValue))))=OldValue;
{$endif}
end;
{$ifend}
{$endif}

class procedure TPasMPInterlocked.BitwiseXor(var Destination:TPasMPInt32;const Value:TPasMPInt32);
{$if defined(cpu386)}
asm
{$ifdef HAS_STATIC}
 lock xor dword ptr [eax],edx
{$else}
 lock xor dword ptr [edx],ecx
{$endif}
end;
{$elseif defined(cpux86_64)}
asm
{$ifdef Windows}
 // Win64 ABI
 // rcx = Parameter 1
 // rdx = Parameter 2
 // r8 = Parameter 3
{$ifdef HAS_STATIC}
 lock xor dword ptr [rcx],edx
{$else}
 lock xor dword ptr [rdx],r8d
{$endif}
{$else}
 // System V ABI
 // rdi = self
 // rsi = Job
 // rdx = Temporary
{$ifdef HAS_STATIC}
 lock xor dword ptr [rdi],esi
{$else}
 lock xor dword ptr [rsi],edx
{$endif}
{$endif}
end;
{$else}
var OldValue:TPasMPInt32;
begin
 repeat
  OldValue:=Destination;
{$ifdef HAS_ATOMICS}
 until AtomicCmpExchange(Destination,OldValue xor Value,OldValue)=OldValue;
{$else}
 until InterlockedCompareExchange(Destination,OldValue xor Value,OldValue)=OldValue;
{$endif}
end;
{$ifend}

class procedure TPasMPInterlocked.BitwiseXor(var Destination:TPasMPUInt32;const Value:TPasMPUInt32);
{$if defined(cpu386)}
asm
{$ifdef HAS_STATIC}
 lock xor dword ptr [eax],edx
{$else}
 lock xor dword ptr [edx],ecx
{$endif}
end;
{$elseif defined(cpux86_64)}
asm
{$ifdef Windows}
 // Win64 ABI
 // rcx = Parameter 1
 // rdx = Parameter 2
 // r8 = Parameter 3
{$ifdef HAS_STATIC}
 lock xor dword ptr [rcx],edx
{$else}
 lock xor dword ptr [rdx],r8d
{$endif}
{$else}
 // System V ABI
 // rdi = self
 // rsi = Job
 // rdx = Temporary
{$ifdef HAS_STATIC}
 lock xor dword ptr [rdi],esi
{$else}
 lock xor dword ptr [rsi],edx
{$endif}
{$endif}
end;
{$else}
var OldValue:TPasMPUInt32;
begin
 repeat
  OldValue:=Destination;
{$ifdef HAS_ATOMICS}
 until TPasMPUInt32(TPasMPInt32(AtomicCmpExchange(TPasMPInt32(Destination),TPasMPInt32(OldValue xor Value),TPasMPInt32(OldValue))))=OldValue;
{$else}
 until TPasMPUInt32(TPasMPInt32(InterlockedCompareExchange(TPasMPInt32(Destination),TPasMPInt32(OldValue xor Value),TPasMPInt32(OldValue))))=OldValue;
{$endif}
end;
{$ifend}

{$ifdef CPU64}
class procedure TPasMPInterlocked.BitwiseXor(var Destination:TPasMPInt64;const Value:TPasMPInt64);
{$if defined(cpux86_64)}
asm
{$ifdef Windows}
 // Win64 ABI
 // rcx = Parameter 1
 // rdx = Parameter 2
 // r8 = Parameter 3
{$ifdef HAS_STATIC}
 lock xor qword ptr [rcx],rdx
{$else}
 lock xor qword ptr [rdx],r8
{$endif}
{$else}
 // System V ABI
 // rdi = self
 // rsi = Job
 // rdx = Temporary
{$ifdef HAS_STATIC}
 lock xor qword ptr [rdi],rsi
{$else}
 lock xor qword ptr [rsi],rdx
{$endif}
{$endif}
end;
{$else}
var OldValue:TPasMPInt64;
begin
 repeat
  OldValue:=Destination;
{$ifdef HAS_ATOMICS}
 until AtomicCmpExchange(Destination,OldValue xor Value,OldValue)=OldValue;
{$else}
 until InterlockedCompareExchange64(Destination,OldValue xor Value,OldValue)=OldValue;
{$endif}
end;
{$ifend}

class procedure TPasMPInterlocked.BitwiseXor(var Destination:TPasMPUInt64;const Value:TPasMPUInt64);
{$if defined(cpux86_64)}
asm
{$ifdef Windows}
 // Win64 ABI
 // rcx = Parameter 1
 // rdx = Parameter 2
 // r8 = Parameter 3
{$ifdef HAS_STATIC}
 lock xor qword ptr [rcx],rdx
{$else}
 lock xor qword ptr [rdx],r8
{$endif}
{$else}
 // System V ABI
 // rdi = self
 // rsi = Job
 // rdx = Temporary
{$ifdef HAS_STATIC}
 lock xor qword ptr [rdi],rsi
{$else}
 lock xor qword ptr [rsi],rdx
{$endif}
{$endif}
end;
{$else}
var OldValue:TPasMPInt64;
begin
 repeat
  OldValue:=Destination;
{$ifdef HAS_ATOMICS}
 until TPasMPUInt64(TPasMPInt64(AtomicCmpExchange(TPasMPInt64(Destination),TPasMPInt64(OldValue xor Value),TPasMPInt64(OldValue))))=OldValue;
{$else}
 until TPasMPUInt64(TPasMPInt64(InterlockedCompareExchange64(TPasMPInt64(Destination),TPasMPInt64(OldValue xor Value),TPasMPInt64(OldValue))))=OldValue;
{$endif}
end;
{$ifend}
{$endif}

class function TPasMPInterlocked.ExchangeBitwiseAnd(var Destination:TPasMPInt32;const Value:TPasMPInt32):TPasMPInt32;
var OldValue,NewValue:TPasMPInt32;
begin
 repeat
  OldValue:=Destination;
  NewValue:=OldValue and Value;
{$ifdef HAS_ATOMICS}
  result:=AtomicCmpExchange(Destination,NewValue,OldValue);
{$else}
  result:=InterlockedCompareExchange(Destination,NewValue,OldValue);
{$endif}
 until result=OldValue;
end;

class function TPasMPInterlocked.ExchangeBitwiseAnd(var Destination:TPasMPUInt32;const Value:TPasMPUInt32):TPasMPUInt32;
var OldValue,NewValue:TPasMPUInt32;
begin
 repeat
  OldValue:=Destination;
  NewValue:=OldValue and Value;
{$ifdef HAS_ATOMICS}
  result:=TPasMPUInt32(TPasMPInt32(AtomicCmpExchange(TPasMPInt32(Destination),TPasMPInt32(NewValue),TPasMPInt32(OldValue))));
{$else}
  result:=TPasMPUInt32(TPasMPInt32(InterlockedCompareExchange(TPasMPInt32(Destination),TPasMPInt32(NewValue),TPasMPInt32(OldValue))));
{$endif}
 until result=OldValue;
end;

{$ifdef CPU64}
class function TPasMPInterlocked.ExchangeBitwiseAnd(var Destination:TPasMPInt64;const Value:TPasMPInt64):TPasMPInt64;
var OldValue,NewValue:TPasMPInt64;
begin
 repeat
  OldValue:=Destination;
  NewValue:=OldValue and Value;
{$ifdef HAS_ATOMICS}
  result:=AtomicCmpExchange(Destination,NewValue,OldValue);
{$else}
  result:=InterlockedCompareExchange64(Destination,NewValue,OldValue);
{$endif}
 until result=OldValue;
end;

class function TPasMPInterlocked.ExchangeBitwiseAnd(var Destination:TPasMPUInt64;const Value:TPasMPUInt64):TPasMPUInt64;
var OldValue,NewValue:TPasMPUInt64;
begin
 repeat
  OldValue:=Destination;
  NewValue:=OldValue and Value;
{$ifdef HAS_ATOMICS}
  result:=TPasMPUInt64(TPasMPInt64(AtomicCmpExchange(TPasMPInt64(Destination),TPasMPInt64(NewValue),TPasMPInt64(OldValue))));
{$else}
  result:=TPasMPUInt64(TPasMPInt64(InterlockedCompareExchange64(TPasMPInt64(Destination),TPasMPInt64(NewValue),TPasMPInt64(OldValue))));
{$endif}
 until result=OldValue;
end;
{$endif}

class function TPasMPInterlocked.ExchangeBitwiseOr(var Destination:TPasMPInt32;const Value:TPasMPInt32):TPasMPInt32;
var OldValue,NewValue:TPasMPInt32;
begin
 repeat
  OldValue:=Destination;
  NewValue:=OldValue or Value;
{$ifdef HAS_ATOMICS}
  result:=AtomicCmpExchange(Destination,NewValue,OldValue);
{$else}
  result:=InterlockedCompareExchange(Destination,NewValue,OldValue);
{$endif}
 until result=OldValue;
end;

class function TPasMPInterlocked.ExchangeBitwiseOr(var Destination:TPasMPUInt32;const Value:TPasMPUInt32):TPasMPUInt32;
var OldValue,NewValue:TPasMPUInt32;
begin
 repeat
  OldValue:=Destination;
  NewValue:=OldValue or Value;
{$ifdef HAS_ATOMICS}
  result:=TPasMPUInt32(TPasMPInt32(AtomicCmpExchange(TPasMPInt32(Destination),TPasMPInt32(NewValue),TPasMPInt32(OldValue))));
{$else}
  result:=TPasMPUInt32(TPasMPInt32(InterlockedCompareExchange(TPasMPInt32(Destination),TPasMPInt32(NewValue),TPasMPInt32(OldValue))));
{$endif}
 until result=OldValue;
end;

{$ifdef CPU64}
class function TPasMPInterlocked.ExchangeBitwiseOr(var Destination:TPasMPInt64;const Value:TPasMPInt64):TPasMPInt64;
var OldValue,NewValue:TPasMPInt64;
begin
 repeat
  OldValue:=Destination;
  NewValue:=OldValue or Value;
{$ifdef HAS_ATOMICS}
  result:=AtomicCmpExchange(Destination,NewValue,OldValue);
{$else}
  result:=InterlockedCompareExchange64(Destination,NewValue,OldValue);
{$endif}
 until result=OldValue;
end;

class function TPasMPInterlocked.ExchangeBitwiseOr(var Destination:TPasMPUInt64;const Value:TPasMPUInt64):TPasMPUInt64;
var OldValue,NewValue:TPasMPUInt64;
begin
 repeat
  OldValue:=Destination;
  NewValue:=OldValue or Value;
{$ifdef HAS_ATOMICS}
  result:=TPasMPUInt64(TPasMPInt64(AtomicCmpExchange(TPasMPInt64(Destination),TPasMPInt64(NewValue),TPasMPInt64(OldValue))));
{$else}
  result:=TPasMPUInt64(TPasMPInt64(InterlockedCompareExchange64(TPasMPInt64(Destination),TPasMPInt64(NewValue),TPasMPInt64(OldValue))));
{$endif}
 until result=OldValue;
end;
{$endif}

class function TPasMPInterlocked.ExchangeBitwiseAndOr(var Destination:TPasMPInt32;const AndValue,OrValue:TPasMPInt32):TPasMPInt32;
var OldValue,NewValue:TPasMPInt32;
begin
 repeat
  OldValue:=Destination;
  NewValue:=(OldValue and AndValue) or OrValue;
{$ifdef HAS_ATOMICS}
  result:=AtomicCmpExchange(Destination,NewValue,OldValue);
{$else}
  result:=InterlockedCompareExchange(Destination,NewValue,OldValue);
{$endif}
 until result=OldValue;
end;

class function TPasMPInterlocked.ExchangeBitwiseAndOr(var Destination:TPasMPUInt32;const AndValue,OrValue:TPasMPUInt32):TPasMPUInt32;
var OldValue,NewValue:TPasMPUInt32;
begin
 repeat
  OldValue:=Destination;
  NewValue:=(OldValue and AndValue) or OrValue;
{$ifdef HAS_ATOMICS}
  result:=TPasMPUInt32(TPasMPInt32(AtomicCmpExchange(TPasMPInt32(Destination),TPasMPInt32(NewValue),TPasMPInt32(OldValue))));
{$else}
  result:=TPasMPUInt32(TPasMPInt32(InterlockedCompareExchange(TPasMPInt32(Destination),TPasMPInt32(NewValue),TPasMPInt32(OldValue))));
{$endif}
 until result=OldValue;
end;

{$ifdef CPU64}
class function TPasMPInterlocked.ExchangeBitwiseAndOr(var Destination:TPasMPInt64;const AndValue,OrValue:TPasMPInt64):TPasMPInt64;
var OldValue,NewValue:TPasMPInt64;
begin
 repeat
  OldValue:=Destination;
  NewValue:=(OldValue and AndValue) or OrValue;
{$ifdef HAS_ATOMICS}
  result:=AtomicCmpExchange(Destination,NewValue,OldValue);
{$else}
  result:=InterlockedCompareExchange64(Destination,NewValue,OldValue);
{$endif}
 until result=OldValue;
end;

class function TPasMPInterlocked.ExchangeBitwiseAndOr(var Destination:TPasMPUInt64;const AndValue,OrValue:TPasMPUInt64):TPasMPUInt64;
var OldValue,NewValue:TPasMPUInt64;
begin
 repeat
  OldValue:=Destination;
  NewValue:=(OldValue and AndValue) or OrValue;
{$ifdef HAS_ATOMICS}
  result:=TPasMPUInt64(TPasMPInt64(AtomicCmpExchange(TPasMPInt64(Destination),TPasMPInt64(NewValue),TPasMPInt64(OldValue))));
{$else}
  result:=TPasMPUInt64(TPasMPInt64(InterlockedCompareExchange64(TPasMPInt64(Destination),TPasMPInt64(NewValue),TPasMPInt64(OldValue))));
{$endif}
 until result=OldValue;
end;
{$endif}

class function TPasMPInterlocked.ExchangeBitwiseXor(var Destination:TPasMPInt32;const Value:TPasMPInt32):TPasMPInt32;
var OldValue,NewValue:TPasMPInt32;
begin
 repeat
  OldValue:=Destination;
  NewValue:=OldValue xor Value;
{$ifdef HAS_ATOMICS}
  result:=AtomicCmpExchange(Destination,NewValue,OldValue);
{$else}
  result:=InterlockedCompareExchange(Destination,NewValue,OldValue);
{$endif}
 until result=OldValue;
end;

class function TPasMPInterlocked.ExchangeBitwiseXor(var Destination:TPasMPUInt32;const Value:TPasMPUInt32):TPasMPUInt32;
var OldValue,NewValue:TPasMPUInt32;
begin
 repeat
  OldValue:=Destination;
  NewValue:=OldValue xor Value;
{$ifdef HAS_ATOMICS}
  result:=TPasMPUInt32(TPasMPInt32(AtomicCmpExchange(TPasMPInt32(Destination),TPasMPInt32(NewValue),TPasMPInt32(OldValue))));
{$else}
  result:=TPasMPUInt32(TPasMPInt32(InterlockedCompareExchange(TPasMPInt32(Destination),TPasMPInt32(NewValue),TPasMPInt32(OldValue))));
{$endif}
 until result=OldValue;
end;

{$ifdef CPU64}
class function TPasMPInterlocked.ExchangeBitwiseXor(var Destination:TPasMPInt64;const Value:TPasMPInt64):TPasMPInt64;
var OldValue,NewValue:TPasMPInt64;
begin
 repeat
  OldValue:=Destination;
  NewValue:=OldValue xor Value;
{$ifdef HAS_ATOMICS}
  result:=AtomicCmpExchange(Destination,NewValue,OldValue);
{$else}
  result:=InterlockedCompareExchange64(Destination,NewValue,OldValue);
{$endif}
 until result=OldValue;
end;

class function TPasMPInterlocked.ExchangeBitwiseXor(var Destination:TPasMPUInt64;const Value:TPasMPUInt64):TPasMPUInt64;
var OldValue,NewValue:TPasMPUInt64;
begin
 repeat
  OldValue:=Destination;
  NewValue:=OldValue xor Value;
{$ifdef HAS_ATOMICS}
  result:=TPasMPUInt64(TPasMPInt64(AtomicCmpExchange(TPasMPInt64(Destination),TPasMPInt64(NewValue),TPasMPInt64(OldValue))));
{$else}
  result:=TPasMPUInt64(TPasMPInt64(InterlockedCompareExchange64(TPasMPInt64(Destination),TPasMPInt64(NewValue),TPasMPInt64(OldValue))));
{$endif}
 until result=OldValue;
end;
{$endif}

class function TPasMPInterlocked.Exchange(var Destination:TPasMPInt32;const Source:TPasMPInt32):TPasMPInt32;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicExchange(Destination,Source);
{$else}
 result:=InterlockedExchange(Destination,Source);
{$endif}
end;

class function TPasMPInterlocked.Exchange(var Destination:TPasMPUInt32;const Source:TPasMPUInt32):TPasMPUInt32;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicExchange(Destination,Source);
{$else}
 result:=TPasMPUInt32(InterlockedExchange(TPasMPInt32(Destination),TPasMPInt32(Source)));
{$endif}
end;

{$ifdef CPU64}
class function TPasMPInterlocked.Exchange(var Destination:TPasMPInt64;const Source:TPasMPInt64):TPasMPInt64;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicExchange(Destination,Source);
{$else}
 result:=InterlockedExchange64(Destination,Source);
{$endif}
end;

class function TPasMPInterlocked.Exchange(var Destination:TPasMPUInt64;const Source:TPasMPUInt64):TPasMPUInt64;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicExchange(Destination,Source);
{$else}
 result:=TPasMPUInt64(InterlockedExchange64(TPasMPInt64(Destination),TPasMPInt64(Source)));
{$endif}
end;
{$endif}

class function TPasMPInterlocked.Exchange(var Destination:pointer;const Source:pointer):pointer;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicExchange(Destination,Source);
{$else}
{$ifdef CPU64}
 result:=pointer(TPasMPPtrInt(InterlockedExchange64(TPasMPInt64(TPasMPPtrInt(Destination)),TPasMPInt64(TPasMPPtrInt(Source)))));
{$else}
 result:=pointer(TPasMPPtrInt(InterlockedExchange(TPasMPInt32(TPasMPPtrInt(Destination)),TPasMPInt32(TPasMPPtrInt(Source)))));
{$endif}
{$endif}
end;

class function TPasMPInterlocked.Exchange(var Destination:TObject;const Source:TObject):TObject;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicExchange(pointer(Destination),pointer(Source));
{$else}
{$ifdef CPU64}
 result:=pointer(TPasMPPtrInt(InterlockedExchange64(TPasMPInt64(TPasMPPtrInt(Destination)),TPasMPInt64(TPasMPPtrInt(Source)))));
{$else}
 result:=pointer(TPasMPPtrInt(InterlockedExchange(TPasMPInt32(TPasMPPtrInt(Destination)),TPasMPInt32(TPasMPPtrInt(Source)))));
{$endif}
{$endif}
end;

class function TPasMPInterlocked.Exchange(var Destination:TPasMPBool32;const Source:TPasMPBool32):TPasMPBool32;
begin
{$ifdef HAS_ATOMICS}
{$if defined(cpu64bits) and defined(nextgen)}
 result:=TPasMPBool32(TPasMPInt64(AtomicExchange(TPasMPInt32(Destination),TPasMPInt32(Source))));
{$else}
 result:=TPasMPBool32(TPasMPInt32(AtomicExchange(TPasMPInt32(Destination),TPasMPInt32(Source))));
{$ifend}
{$else}
 result:=TPasMPBool32(TPasMPInt32(InterlockedExchange(TPasMPInt32(Destination),TPasMPInt32(Source))));
{$endif}
end;

class function TPasMPInterlocked.CompareExchange(var Destination:TPasMPInt32;const NewValue,Comperand:TPasMPInt32):TPasMPInt32;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicCmpExchange(Destination,NewValue,Comperand);
{$else}
 result:=InterlockedCompareExchange(Destination,NewValue,Comperand);
{$endif}
end;

class function TPasMPInterlocked.CompareExchange(var Destination:TPasMPUInt32;const NewValue,Comperand:TPasMPUInt32):TPasMPUInt32;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicCmpExchange(Destination,NewValue,Comperand);
{$else}
 result:=TPasMPUInt32(InterlockedCompareExchange(TPasMPInt32(Destination),TPasMPInt32(NewValue),TPasMPInt32(Comperand)));
{$endif}
end;

{$if defined(CPU64) or ((defined(CPU386) or defined(CPUARM)) and defined(PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE))}
class function TPasMPInterlocked.CompareExchange(var Destination:TPasMPInt64;const NewValue,Comperand:TPasMPInt64):TPasMPInt64;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicCmpExchange(Destination,NewValue,Comperand);
{$else}
 result:=InterlockedCompareExchange64(Destination,NewValue,Comperand);
{$endif}
end;

class function TPasMPInterlocked.CompareExchange(var Destination:TPasMPInt64Record;const NewValue,Comperand:TPasMPInt64Record):TPasMPInt64Record;
begin
{$ifdef HAS_ATOMICS}
 result.Value:=AtomicCmpExchange(Destination.Value,NewValue.Value,Comperand.Value);
{$else}
 result.Value:=InterlockedCompareExchange64(Destination.Value,NewValue.Value,Comperand.Value);
{$endif}
end;

class function TPasMPInterlocked.CompareExchange(var Destination:TPasMPUInt64;const NewValue,Comperand:TPasMPUInt64):TPasMPUInt64;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicCmpExchange(Destination,NewValue,Comperand);
{$else}
 result:=TPasMPUInt64(InterlockedCompareExchange64(TPasMPInt64(Destination),TPasMPInt64(NewValue),TPasMPInt64(Comperand)));
{$endif}
end;
{$ifend}

{$if defined(CPU64) and defined(PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE)}
class function TPasMPInterlocked.CompareExchange(var Destination:TPasMPInt128Record;const NewValue,Comperand:TPasMPInt128Record):TPasMPInt128Record;
begin
 result:=InterlockedCompareExchange128(Destination,NewValue,Comperand);
end;
{$ifend}

class function TPasMPInterlocked.CompareExchange(var Destination:pointer;const NewValue,Comperand:pointer):pointer;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicCmpExchange(Destination,NewValue,Comperand);
{$else}
{$ifdef CPU64}
 result:=pointer(TPasMPPtrInt(InterlockedCompareExchange64(TPasMPInt64(TPasMPPtrInt(Destination)),TPasMPInt64(TPasMPPtrInt(NewValue)),TPasMPInt64(TPasMPPtrInt(Comperand)))));
{$else}
 result:=pointer(TPasMPPtrInt(InterlockedCompareExchange(TPasMPInt32(TPasMPPtrInt(Destination)),TPasMPInt32(TPasMPPtrInt(NewValue)),TPasMPInt32(TPasMPPtrInt(Comperand)))));
{$endif}
{$endif}
end;

class function TPasMPInterlocked.CompareExchange(var Destination:TObject;const NewValue,Comperand:TObject):TObject;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicCmpExchange(pointer(Destination),pointer(NewValue),pointer(Comperand));
{$else}
{$ifdef CPU64}
 result:=pointer(TPasMPPtrInt(InterlockedCompareExchange64(TPasMPInt64(TPasMPPtrInt(Destination)),TPasMPInt64(TPasMPPtrInt(NewValue)),TPasMPInt64(TPasMPPtrInt(Comperand)))));
{$else}
 result:=pointer(TPasMPPtrInt(InterlockedCompareExchange(TPasMPInt32(TPasMPPtrInt(Destination)),TPasMPInt32(TPasMPPtrInt(NewValue)),TPasMPInt32(TPasMPPtrInt(Comperand)))));
{$endif}
{$endif}
end;

class function TPasMPInterlocked.CompareExchange(var Destination:TPasMPBool32;const NewValue,Comperand:TPasMPBool32):TPasMPBool32;
begin
{$ifdef HAS_ATOMICS}
 result:=TPasMPBool32(TPasMPInt32(AtomicCmpExchange(TPasMPInt32(Destination),TPasMPInt32(NewValue),TPasMPInt32(Comperand))));
{$else}
 result:=TPasMPBool32(TPasMPInt32(InterlockedCompareExchange(TPasMPInt32(Destination),TPasMPInt32(NewValue),TPasMPInt32(Comperand))));
{$endif}
end;

class function TPasMPInterlocked.Read(var Source:TPasMPInt32):TPasMPInt32;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicCmpExchange(Source,0,0);
{$else}
 result:=InterlockedCompareExchange(Source,0,0);
{$endif}
end;

class function TPasMPInterlocked.Read(var Source:TPasMPUInt32):TPasMPUInt32;
begin
{$ifdef HAS_ATOMICS}
 result:=TPasMPUInt32(TPasMPInt32(AtomicCmpExchange(TPasMPInt32(Source),0,0)));
{$else}
 result:=TPasMPUInt32(TPasMPInt32(InterlockedCompareExchange(TPasMPInt32(Source),0,0)));
{$endif}
end;

{$if defined(CPU64) or ((defined(CPU386) or defined(CPUARM)) and defined(PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE))}
class function TPasMPInterlocked.Read(var Source:TPasMPInt64):TPasMPInt64;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicCmpExchange(Source,0,0);
{$else}
 result:=InterlockedCompareExchange64(Source,0,0);
{$endif}
end;

class function TPasMPInterlocked.Read(var Source:TPasMPInt64Record):TPasMPInt64Record;
begin
{$ifdef HAS_ATOMICS}
 result.Value:=AtomicCmpExchange(Source.Value,0,0);
{$else}
 result.Value:=InterlockedCompareExchange64(Source.Value,0,0);
{$endif}
end;

class function TPasMPInterlocked.Read(var Source:TPasMPUInt64):TPasMPUInt64;
begin
{$ifdef HAS_ATOMICS}
 result:=TPasMPUInt64(TPasMPInt64(AtomicCmpExchange(TPasMPInt64(Source),0,0)));
{$else}
 result:=TPasMPUInt64(TPasMPInt64(InterlockedCompareExchange64(TPasMPInt64(Source),0,0)));
{$endif}
end;

{$if defined(CPU64) and defined(PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE)}
class function TPasMPInterlocked.Read(var Source:TPasMPInt128Record):TPasMPInt128Record;
var Temp:TPasMPInt128Record;
begin
 Temp.Lo:=0;
 Temp.Hi:=0;
 result:=InterlockedCompareExchange128(Source,Temp,Temp);
end;
{$ifend}
{$ifend}

class function TPasMPInterlocked.Read(var Source:pointer):pointer;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicCmpExchange(Source,nil,nil);
{$else}
{$ifdef CPU64}
 result:=pointer(TPasMPPtrInt(InterlockedCompareExchange64(TPasMPInt64(TPasMPPtrInt(Source)),TPasMPInt64(TPasMPPtrInt(0)),TPasMPInt64(TPasMPPtrInt(0)))));
{$else}
 result:=pointer(TPasMPPtrInt(InterlockedCompareExchange(TPasMPInt32(TPasMPPtrInt(Source)),TPasMPInt32(TPasMPPtrInt(0)),TPasMPInt32(TPasMPPtrInt(0)))));
{$endif}
{$endif}
end;

class function TPasMPInterlocked.Read(var Source:TObject):TObject;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicCmpExchange(pointer(Source),nil,nil);
{$else}
{$ifdef CPU64}
 result:=pointer(TPasMPPtrInt(InterlockedCompareExchange64(TPasMPInt64(TPasMPPtrInt(Source)),TPasMPInt64(TPasMPPtrInt(0)),TPasMPInt64(TPasMPPtrInt(0)))));
{$else}
 result:=pointer(TPasMPPtrInt(InterlockedCompareExchange(TPasMPInt32(TPasMPPtrInt(Source)),TPasMPInt32(TPasMPPtrInt(0)),TPasMPInt32(TPasMPPtrInt(0)))));
{$endif}
{$endif}
end;

class function TPasMPInterlocked.Read(var Source:TPasMPBool32):TPasMPBool32;
begin
{$ifdef HAS_ATOMICS}
 result:=TPasMPBool32(TPasMPInt32(AtomicCmpExchange(TPasMPInt32(Source),TPasMPInt32(0),TPasMPInt32(0))));
{$else}
 result:=TPasMPBool32(TPasMPInt32(InterlockedCompareExchange(TPasMPInt32(Source),TPasMPInt32(0),TPasMPInt32(0))));
{$endif}
end;

class function TPasMPInterlocked.Write(var Destination:TPasMPInt32;const Source:TPasMPInt32):TPasMPInt32;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicExchange(Destination,Source);
{$else}
 result:=InterlockedExchange(Destination,Source);
{$endif}
end;

class function TPasMPInterlocked.Write(var Destination:TPasMPUInt32;const Source:TPasMPUInt32):TPasMPUInt32;
begin
{$ifdef HAS_ATOMICS}
 result:=TPasMPUInt32(TPasMPInt32(AtomicExchange(TPasMPInt32(Destination),TPasMPInt32(Source))));
{$else}
 result:=TPasMPUInt32(TPasMPInt32(InterlockedExchange(TPasMPInt32(Destination),TPasMPInt32(Source))));
{$endif}
end;

{$if defined(CPU64) or ((defined(CPU386) or defined(CPUARM)) and defined(PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE))}
class function TPasMPInterlocked.Write(var Destination:TPasMPInt64;const Source:TPasMPInt64):TPasMPInt64;
{$ifdef CPU64}
{$ifdef HAS_ATOMICS}
begin
 result:=AtomicExchange(Destination,Source);
end;
{$else}
begin
 result:=InterlockedExchange64(Destination,Source);
end;
{$endif}
{$else}
{$ifdef HAS_ATOMICS}
var Old:TPasMPInt64;
begin
 repeat
  Old:=Destination;
  result:=AtomicCmpExchange(Destination,Source,Old);
 until result=Old;
end;
{$else}
var Old:TPasMPInt64;
begin
 repeat
  Old:=Destination;
  result:=InterlockedCompareExchange64(Destination,Source,Old);
 until result=Old;
end;
{$endif}
{$endif}

class function TPasMPInterlocked.Write(var Destination:TPasMPInt64Record;const Source:TPasMPInt64Record):TPasMPInt64Record;
{$ifdef CPU64}
{$ifdef HAS_ATOMICS}
begin
 result.Value:=AtomicExchange(Destination.Value,Source.Value);
end;
{$else}
begin
 result.Value:=InterlockedExchange64(Destination.Value,Source.Value);
end;
{$endif}
{$else}
{$ifdef HAS_ATOMICS}
var Old:TPasMPInt64;
begin
 repeat
  Old:=Destination.Value;
  result.Value:=AtomicCmpExchange(Destination.Value,Source.Value,Old);
 until result.Value=Old;
end;
{$else}
var Old:TPasMPInt64;
begin
 repeat
  Old:=Destination.Value;
  result.Value:=InterlockedCompareExchange64(Destination.Value,Source.Value,Old);
 until result.Value=Old;
end;
{$endif}
{$endif}

{$if defined(CPU64) and defined(PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE)}
class function TPasMPInterlocked.Write(var Destination:TPasMPInt128Record;const Source:TPasMPInt128Record):TPasMPInt128Record;
var Old:TPasMPInt128Record;
begin
 repeat
  Old:=Destination;
  result:=InterlockedCompareExchange128(Destination,Source,Old);
 until (result.Lo=Old.Lo) and (result.Hi=Old.Hi);
end;
{$ifend}

class function TPasMPInterlocked.Write(var Destination:TPasMPUInt64;const Source:TPasMPUInt64):TPasMPUInt64;
{$ifdef CPU64}
{$ifdef HAS_ATOMICS}
begin
 result:=TPasMPUInt64(TPasMPInt64(AtomicExchange(TPasMPInt64(Destination),TPasMPInt64(Source))));
end;
{$else}
begin
 result:=TPasMPUInt64(TPasMPInt64(InterlockedExchange64(TPasMPInt64(Destination),TPasMPInt64(Source))));
end;
{$endif}
{$else}
{$ifdef HAS_ATOMICS}
var Old:TPasMPUInt64;
begin
 repeat
  Old:=Destination;
  result:=TPasMPUInt64(TPasMPInt64(AtomicCmpExchange(TPasMPInt64(Destination),TPasMPInt64(Source),TPasMPInt64(Old))));
 until result=Old;
end;
{$else}
var Old:TPasMPUInt64;
begin
 repeat
  Old:=Destination;
  result:=TPasMPUInt64(TPasMPInt64(InterlockedCompareExchange64(TPasMPInt64(Destination),TPasMPInt64(Source),TPasMPInt64(Old))));
 until result=Old;
end;
{$endif}
{$endif}

{$ifend}

class function TPasMPInterlocked.Write(var Destination:pointer;const Source:pointer):pointer;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicExchange(Destination,Source);
{$else}
{$ifdef CPU64}
 result:=pointer(TPasMPPtrInt(InterlockedExchange64(TPasMPInt64(TPasMPPtrInt(Destination)),TPasMPInt64(TPasMPPtrInt(Source)))));
{$else}
 result:=pointer(TPasMPPtrInt(InterlockedExchange(TPasMPInt32(TPasMPPtrInt(Destination)),TPasMPInt32(TPasMPPtrInt(Source)))));
{$endif}
{$endif}
end;

class function TPasMPInterlocked.Write(var Destination:TObject;const Source:TObject):TObject;
begin
{$ifdef HAS_ATOMICS}
 result:=AtomicExchange(pointer(Destination),pointer(Source));
{$else}
{$ifdef CPU64}
 result:=pointer(TPasMPPtrInt(InterlockedExchange64(TPasMPInt64(TPasMPPtrInt(Destination)),TPasMPInt64(TPasMPPtrInt(Source)))));
{$else}
 result:=pointer(TPasMPPtrInt(InterlockedExchange(TPasMPInt32(TPasMPPtrInt(Destination)),TPasMPInt32(TPasMPPtrInt(Source)))));
{$endif}
{$endif}
end;

class function TPasMPInterlocked.Write(var Destination:TPasMPBool32;const Source:TPasMPBool32):TPasMPBool32;
begin
{$ifdef HAS_ATOMICS}
 result:=TPasMPBool32(TPasMPInt32(AtomicExchange(TPasMPInt32(Destination),TPasMPInt32(Source))));
{$else}
 result:=TPasMPBool32(TPasMPInt32(InterlockedExchange(TPasMPInt32(Destination),TPasMPInt32(Source))));
{$endif}
end;

class procedure TPasMPMemoryBarrier.Read;
begin
{$if defined(fpc)}
 ReadBarrier;
{$elseif CompilerVersion>=25}
 MemoryBarrier;
{$else}
 FallbackReadBarrier;
{$ifend}
end;

class procedure TPasMPMemoryBarrier.ReadDependency;
begin
 // reads imply barrier on earlier reads depended on
end;

class procedure TPasMPMemoryBarrier.ReadWrite;
begin
{$if defined(fpc)}
 ReadWriteBarrier;
{$elseif CompilerVersion>=25}
 MemoryBarrier;
{$else}
 FallbackReadWriteBarrier;
{$ifend}
end;

class procedure TPasMPMemoryBarrier.Write;
begin
{$if defined(fpc)}
 WriteBarrier;
{$elseif CompilerVersion>=25}
 MemoryBarrier;
{$else}
 FallbackWriteBarrier;
{$ifend}
end;

class procedure TPasMPMemoryBarrier.Sync;
begin
{$if defined(fpc)}
 ReadWriteBarrier;
{$elseif CompilerVersion>=25}
 MemoryBarrier;
{$else}
 FallbackReadWriteBarrier;
{$ifend}
end;

class procedure TPasMPMemory.AllocateAlignedMemory(var p;Size:TPasMPInt32;Align:TPasMPInt32=PasMPCPUCacheLineSize);
var Original,Aligned:pointer;
    Mask:ptruint;
begin
 if (Align and (Align-1))<>0 then begin
  Align:=TPasMPMath.RoundUpToPowerOfTwo(Align);
 end;
 Mask:=Align-1;
 inc(Size,((Align shl 1)+SizeOf(pointer)));
 GetMem(Original,Size);
 FillChar(Original^,Size,#0);
 Aligned:=pointer(ptruint(ptruint(Original)+SizeOf(pointer)));
 if (Align>1) and ((ptruint(Aligned) and Mask)<>0) then begin
  inc(ptruint(Aligned),ptruint(ptruint(Align)-(ptruint(Aligned) and Mask)));
 end;
 pointer(pointer(ptruint(ptruint(Aligned)-SizeOf(pointer)))^):=Original;
 pointer(pointer(@p)^):=Aligned;
end;

class procedure TPasMPMemory.FreeAlignedMemory(const p);
var pp:pointer;
begin
 pp:=pointer(pointer(@p)^);
 if assigned(pp) then begin
  pp:=pointer(pointer(ptruint(ptruint(pp)-SizeOf(pointer)))^);
  FreeMem(pp);
 end;
end;

class procedure TPasMPMemory.Barrier;
begin
{$ifdef fpc}
 ReadWriteBarrier;
{$else}
{$if CompilerVersion>=25}
 MemoryBarrier;
{$else}
 FallbackReadWriteBarrier;
{$ifend}
{$endif}
end;

constructor TPasMPHighResolutionTimer.Create;
begin
 inherited Create;
 fFrequencyShift:=0;
{$if defined(Windows)}
 if QueryPerformanceFrequency(fFrequency) then begin
  while (fFrequency and $ffffffffe0000000)<>0 do begin
   fFrequency:=fFrequency shr 1;
   inc(fFrequencyShift);
  end;
 end else begin
  fFrequency:=1000;
 end;
{$elseif defined(Linux)}
 fFrequency:=1000000000;
{$elseif defined(Unix)}
 fFrequency:=1000000;
{$else}
 fFrequency:=1000;
{$ifend}
 fMillisecondInterval:=(fFrequency+500) div 1000;
 fTwoMillisecondsInterval:=(fFrequency+250) div 500;
 fFourMillisecondsInterval:=(fFrequency+125) div 250;
 fQuarterSecondInterval:=(fFrequency+2) div 4;
 fMinuteInterval:=fFrequency*60;
 fHourInterval:=fFrequency*3600;
end;

destructor TPasMPHighResolutionTimer.Destroy;
begin
 inherited Destroy;
end;

function TPasMPHighResolutionTimer.GetTime:TPasMPInt64;
{$if defined(Linux)}
var NowTimeSpec:TPasMPTimeSpec;
    tv:timeval;
    tz:TPasMPTimeZone;
    ia,ib:TPasMPInt64;
begin
 if clock_gettime(CLOCK_MONOTONIC,@NowTimeSpec)=0 then begin
  ia:=TPasMPInt64(NowTimeSpec.tv_sec)*TPasMPInt64(1000000000);
  ib:=NowTimeSpec.tv_nsec;
  result:=(ia+ib) shr fFrequencyShift;
 end else begin
  tz.tz_minuteswest:=0;
  tz.tz_dsttime:=0;
{$ifdef fpc}
  fpgettimeofday(@tv,@tz);
{$else}
  gettimeofday(tv,@tz);
{$endif}
  ia:=TPasMPInt64(tv.tv_sec)*TPasMPInt64(1000000);
  ib:=tv.tv_usec;
  result:=((ia+ib)*1000) shr fFrequencyShift;
 end;
end;
{$elseif defined(unix)}
var tv:timeval;
    tz:TPasMPTimeZone;
    ia,ib:TPasMPInt64;
begin
 tz.tz_minuteswest:=0;
 tz.tz_dsttime:=0;
{$ifdef fpc}
 fpgettimeofday(@tv,@tz);
{$else}
 gettimeofday(tv,@tz);
{$endif}
 ia:=TPasMPInt64(tv.tv_sec)*TPasMPInt64(1000000);
 ib:=tv.tv_usec;
 result:=(ia+ib) shr fFrequencyShift;
end;
{$elseif defined(Windows)}
begin
 if not QueryPerformanceCounter(result) then begin
  result:=timeGetTime;
 end;
 result:=result shr fFrequencyShift;
end;
{$else}
begin
 result:=trunc(Now*86400000.0) shr fFrequencyShift;
end;
{$ifend}

procedure TPasMPHighResolutionTimer.Sleep(const pDelay:TPasMPInt64);
var EndTime,NowTime{$ifdef unix},SleepTime{$endif}:TPasMPInt64;
{$ifdef unix}
    req,rem:TPasMPTimeSpec;
{$endif}
begin
 if pDelay>0 then begin
{$if defined(Windows)}
  NowTime:=GetTime;
  EndTime:=NowTime+pDelay;
  while (NowTime+fTwoMillisecondsInterval)<EndTime do begin
   Windows.Sleep(1);
   NowTime:=GetTime;
  end;
  while (NowTime+fMillisecondInterval)<EndTime do begin
   Windows.Sleep(0);
   NowTime:=GetTime;
  end;
  while NowTime<EndTime do begin
   NowTime:=GetTime;
  end;
{$elseif defined(Linux) or defined(Android)}
  NowTime:=GetTime;
  EndTime:=NowTime+pDelay;
  while (NowTime+fFourMillisecondsInterval)<EndTime do begin
   SleepTime:=((EndTime-NowTime)+2) shr 2;
   if SleepTime>0 then begin
    req.tv_sec:=SleepTime div 1000000000;
    req.tv_nsec:=SleepTime mod 10000000000;
{$ifdef fpc}
    fpNanoSleep(@req,@rem);
{$else}
    NanoSleep(req,@rem);
{$endif}
    NowTime:=GetTime;
    continue;
   end;
   break;
  end;
  while (NowTime+fTwoMillisecondsInterval)<EndTime do begin
   TPasMP.Yield;
   NowTime:=GetTime;
  end;
  while NowTime<EndTime do begin
   NowTime:=GetTime;
  end;
{$elseif defined(Unix)}
  NowTime:=GetTime;
  EndTime:=NowTime+pDelay;
  while (NowTime+fFourMillisecondsInterval)<EndTime do begin
   SleepTime:=((EndTime-NowTime)+2) shr 2;
   if SleepTime>0 then begin
    req.tv_sec:=SleepTime div 1000000;
    req.tv_nsec:=(SleepTime mod 1000000)*1000;
{$ifdef fpc}
    fpNanoSleep(@req,@rem);
{$else}
    NanoSleep(req,@rem);
{$endif}
    NowTime:=GetTime;
    continue;
   end;
   break;
  end;
  while (NowTime+fTwoMillisecondsInterval)<EndTime do begin
   TPasMP.Yield;
   NowTime:=GetTime;
  end;
  while NowTime<EndTime do begin
   NowTime:=GetTime;
  end;
{$else}
  NowTime:=GetTime;
  EndTime:=NowTime+pDelay;
  while (NowTime+4)<EndTime do begin
   TPasMP.Yield;
   NowTime:=GetTime;
  end;
  while (NowTime+2)<EndTime do begin
   TPasMP.Yield;
   NowTime:=GetTime;
  end;
  while NowTime<EndTime do begin
   NowTime:=GetTime;
  end;
{$ifend}
 end;
end;

function TPasMPHighResolutionTimer.ToFloatSeconds(const pTime:TPasMPHighResolutionTime):double;
begin
 if fFrequency<>0 then begin
  result:=pTime/fFrequency;
 end else begin
  result:=0;
 end;
end;

function TPasMPHighResolutionTimer.FromFloatSeconds(const pTime:double):TPasMPHighResolutionTime;
begin
 if fFrequency<>0 then begin
  result:=trunc(pTime*fFrequency);
 end else begin
  result:=0;
 end;
end;

function TPasMPHighResolutionTimer.ToMilliseconds(const pTime:TPasMPHighResolutionTime):TPasMPInt64;
begin
 result:=pTime;
 if fFrequency<>1000 then begin
  result:=((pTime*1000)+((fFrequency+1) shr 1)) div fFrequency;
 end;
end;

function TPasMPHighResolutionTimer.FromMilliseconds(const pTime:TPasMPInt64):TPasMPHighResolutionTime;
begin
 result:=pTime;
 if fFrequency<>1000 then begin
  result:=((pTime*fFrequency)+500) div 1000;
 end;
end;

function TPasMPHighResolutionTimer.ToMicroseconds(const pTime:TPasMPHighResolutionTime):TPasMPInt64;
begin
 result:=pTime;
 if fFrequency<>1000000 then begin
  result:=((pTime*1000000)+((fFrequency+1) shr 1)) div fFrequency;
 end;
end;

function TPasMPHighResolutionTimer.FromMicroseconds(const pTime:TPasMPInt64):TPasMPHighResolutionTime;
begin
 result:=pTime;
 if fFrequency<>1000000 then begin
  result:=((pTime*fFrequency)+500000) div 1000000;
 end;
end;

function TPasMPHighResolutionTimer.ToNanoseconds(const pTime:TPasMPHighResolutionTime):TPasMPInt64;
begin
 result:=pTime;
 if fFrequency<>1000000000 then begin
  result:=((pTime*1000000000)+((fFrequency+1) shr 1)) div fFrequency;
 end;
end;

function TPasMPHighResolutionTimer.FromNanoseconds(const pTime:TPasMPInt64):TPasMPHighResolutionTime;
begin
 result:=pTime;
 if fFrequency<>1000000000 then begin
  result:=((pTime*fFrequency)+500000000) div 1000000000;
 end;
end;

constructor TPasMPSimpleEvent.Create;
begin
 inherited Create(nil,false,false,'');
end;

constructor TPasMPMutex.Create;
begin
 inherited Create;
{$if defined(Windows)}
 fMutex:=CreateMutex(nil,false,nil);
 if fMutex=0 then begin
  RaiseLastOSError;
 end;
{$elseif defined(Unix)}
{$ifdef fpc}
 pthread_mutex_init(@fMutex,nil);
{$else}
 pthread_mutex_init(fMutex,nil);
{$endif}
{$else}
 fCriticalSection:=TPasMPCriticalSection.Create;
{$ifend}
end;

{$ifdef Unix}
constructor TPasMPMutex.Create(const lpMutexAttributes:pointer);
begin
 inherited Create;
{$if defined(Windows)}
 fMutex:=CreateMutex(lpMutexAttributes,false,'');
 if fMutex=0 then begin
  RaiseLastOSError;
 end;
{$elseif defined(Unix)}
{$ifdef fpc}
 pthread_mutex_init(@fMutex,lpMutexAttributes);
{$else}
 pthread_mutex_init(fMutex,lpMutexAttributes);
{$endif}
{$else}
 fCriticalSection:=TCriticalSection.Create;
{$ifend}
end;
{$endif}

{$ifdef Windows}
constructor TPasMPMutex.Create(const lpMutexAttributes:pointer;const bInitialOwner:boolean;const lpName:string);
begin
 inherited Create;
{$if defined(Windows)}
 fMutex:=CreateMutex(lpMutexAttributes,bInitialOwner,PChar(lpName));
 if fMutex=0 then begin
  RaiseLastOSError;
 end;
{$elseif defined(Unix)}
 pthread_mutex_init(@fMutex,lpMutexAttributes);
{$else}
 fCriticalSection:=TCriticalSection.Create;
{$ifend}
end;

constructor TPasMPMutex.Create(const DesiredAccess:TPasMPUInt32;const bInitialOwner:boolean;const lpName:string);
begin
 inherited Create;
{$if defined(Windows)}
 fMutex:=OpenMutex(DesiredAccess,bInitialOwner,PChar(lpName));
 if fMutex=0 then begin
  RaiseLastOSError;
 end;
{$elseif defined(Unix)}
 pthread_mutex_init(@fMutex,nil);
{$else}
 fCriticalSection:=TCriticalSection.Create;
{$ifend}
end;
{$endif}

destructor TPasMPMutex.Destroy;
begin
{$if defined(Windows)}
 CloseHandle(fMutex);
{$elseif defined(Unix)}
{$ifdef fpc}
 pthread_mutex_destroy(@fMutex);
{$else}
 pthread_mutex_destroy(fMutex);
{$endif}
{$else}
 fCriticalSection.Free;
{$ifend}
 inherited Destroy;
end;

procedure TPasMPMutex.Acquire;
begin
{$if defined(Windows)}
 case WaitForSingleObject(fMutex,INFINITE) of
  WAIT_OBJECT_0:begin
  end;
  WAIT_TIMEOUT:begin
  end;
  WAIT_ABANDONED:begin
  end;
  else begin
   RaiseLastOSError;
  end;
 end;
{$elseif defined(Unix)}
{$ifdef fpc}
 pthread_mutex_lock(@fMutex);
{$else}
 pthread_mutex_lock(fMutex);
{$endif}
{$else}
 fCriticalSection.Acquire;
{$ifend}
end;

procedure TPasMPMutex.Release;
begin
{$if defined(Windows)}
 if not ReleaseMutex(fMutex) then begin
  RaiseLastOSError;
 end;
{$elseif defined(Unix)}
{$ifdef fpc}
 pthread_mutex_unlock(@fMutex);
{$else}
 pthread_mutex_unlock(fMutex);
{$endif}
{$else}
 fCriticalSection.Release;
{$ifend}
end;

constructor TPasMPConditionVariableLock.Create;
begin
 inherited Create;
{$if defined(Windows)}
 InitializeCriticalSection(fCriticalSection);
{$elseif defined(Unix)}
{$ifdef fpc}
 pthread_mutex_init(@fMutex,nil);
{$else}
 pthread_mutex_init(fMutex,nil);
{$endif}
{$else}
 fCriticalSection:=TPasMPCriticalSection.Create;
{$ifend}
end;

destructor TPasMPConditionVariableLock.Destroy;
begin
{$if defined(Windows)}
 DeleteCriticalSection(fCriticalSection);
{$elseif defined(Unix)}
{$ifdef fpc}
 pthread_mutex_destroy(@fMutex);
{$else}
 pthread_mutex_destroy(fMutex);
{$endif}
{$else}
 fCriticalSection.Free;
{$ifend}
 inherited Destroy;
end;

procedure TPasMPConditionVariableLock.Acquire;
begin
{$if defined(Windows)}
 EnterCriticalSection(fCriticalSection);
{$elseif defined(Unix)}
{$ifdef fpc}
 pthread_mutex_lock(@fMutex);
{$else}
 pthread_mutex_lock(fMutex);
{$endif}
{$else}
 fCriticalSection.Acquire;
{$ifend}
end;

procedure TPasMPConditionVariableLock.Release;
begin
{$if defined(Windows)}
 LeaveCriticalSection(fCriticalSection);
{$elseif defined(Unix)}
{$ifdef fpc}
 pthread_mutex_unlock(@fMutex);
{$else}
 pthread_mutex_unlock(fMutex);
{$endif}
{$else}
 fCriticalSection.Release;
{$ifend}
end;

constructor TPasMPConditionVariable.Create;
{$if defined(Unix)}
const CLOCK_REALTIME=0;
      CLOCK_MONOTONIC=1;
      CLOCK_MONOTONIC_RAW=4;
var r:TPasMPInt32;
    TimeSpec_:TPasMPTimeSpec;
{$ifend}
begin
 inherited Create;
{$if defined(Windows)}
 InitializeConditionVariable(@fConditionVariable);
{$elseif defined(Unix)}
 fClockID:=CLOCK_REALTIME;
 fHasConditionVariableAttributes:=false;
 // TODO: FIX-ME: Also use monotonic clock source for other *nix targets than just Linux, otherwise we
 // can have NTP-related deadlock fun on these Non-Linux *nix targets!
{$if defined(Linux) and not defined(Android)}
 r:=pthread_condattr_init({$ifdef fpc}@fConditionVariableAttributes{$else}fConditionVariableAttributes{$endif});
 if r=0 then begin
  try
   if clock_gettime(CLOCK_MONOTONIC_RAW,@TimeSpec_)=0 then begin
    r:=pthread_condattr_setclock({$ifdef fpc}@fConditionVariableAttributes{$else}fConditionVariableAttributes{$endif},CLOCK_MONOTONIC_RAW);
   end else begin
    r:=-1; // No support for CLOCK_MONOTONIC_RAW
   end;
   if r=0 then begin
    fClockID:=CLOCK_MONOTONIC_RAW;
   end else begin
    if clock_gettime(CLOCK_MONOTONIC,@TimeSpec_)=0 then begin
     r:=pthread_condattr_setclock({$ifdef fpc}@fConditionVariableAttributes{$else}fConditionVariableAttributes{$endif},CLOCK_MONOTONIC);
     if r=0 then begin
      fClockID:=CLOCK_MONOTONIC;
     end;
    end;
   end;
  finally
   if fClockID<>CLOCK_REALTIME then begin
    fHasConditionVariableAttributes:=true;
   end else begin
    pthread_condattr_destroy({$ifdef fpc}@fConditionVariableAttributes{$else}fConditionVariableAttributes{$endif});
   end;
  end;
 end;
 if fHasConditionVariableAttributes then begin
  pthread_cond_init({$ifdef fpc}@fConditionVariable{$else}fConditionVariable{$endif},@fConditionVariableAttributes);
 end else{$ifend}begin
  pthread_cond_init({$ifdef fpc}@fConditionVariable{$else}fConditionVariable{$endif},nil);
 end;
{$else}
 fWaitCounter:=0;
 fCriticalSection:=TPasMPCriticalSection.Create;
 fReleaseCounter:=0;
 fGenerationCounter:=0;
 fEvent:=TPasMPEvent.Create(nil,true,false,'');
{$ifend}
end;

destructor TPasMPConditionVariable.Destroy;
begin
{$if defined(Windows)}
{$elseif defined(Unix)}
{$ifdef fpc}
 pthread_cond_destroy(@fConditionVariable);
{$else}
 pthread_cond_destroy(fConditionVariable);
{$endif}
 if fHasConditionVariableAttributes then begin
  try
   pthread_condattr_destroy({$ifdef fpc}@fConditionVariableAttributes{$else}fConditionVariableAttributes{$endif});
  finally
   fHasConditionVariableAttributes:=false;
  end;
 end;
{$else}
 fCriticalSection.Free;
 fEvent.Free;
{$ifend}
 inherited Destroy;
end;

function TPasMPConditionVariable.Wait(const Lock:TPasMPConditionVariableLock;const dwMilliSeconds:TPasMPUInt32=INFINITE):TWaitResult;
{$if defined(Windows)}
begin
 if SleepConditionVariableCS(@fConditionVariable,@Lock.fCriticalSection,dwMilliSeconds) then begin
  result:=wrSignaled;
 end else begin
  case GetLastError of
   ERROR_TIMEOUT:begin
    result:=wrTimeOut;
   end;
   else begin
    result:=wrError;
   end;
  end;
 end;
end;
{$elseif defined(Unix)}
var TimeSpec_:TPasMPTimeSpec;
    tv:timeval;
    tz:TPasMPTimeZone;
begin
 if dwMilliSeconds=INFINITE then begin
  case pthread_cond_wait({$ifdef fpc}@fConditionVariable,@Lock.fMutex{$else}fConditionVariable,Lock.fMutex{$endif}) of
   0:begin
    result:=wrSignaled;
   end;
   {$ifdef fpc}ESysETIMEDOUT{$else}ETIMEDOUT{$endif}:begin
    result:=wrTimeOut;
   end;
   {$ifdef fpc}ESysEINVAL{$else}EINVAL{$endif}:begin
    result:=wrAbandoned;
   end;
   else begin
    result:=wrError;
   end;
  end;
 end else begin
 {$if defined(Linux)}if clock_gettime(fClockID,@TimeSpec_)<>0 then{$ifend}begin
   tz.tz_minuteswest:=0;
   tz.tz_dsttime:=0;
{$ifdef fpc}
   fpgettimeofday(@tv,@tz);
{$else}
   gettimeofday(tv,@tz);
{$endif}
   TimeSpec_.tv_sec:=tv.tv_sec;
   TimeSpec_.tv_nsec:=tv.tv_usec*1000;
  end;
  TimeSpec_.tv_sec:=TimeSpec_.tv_sec+(TPasMPInt64(dwMilliSeconds) div 1000);
  TimeSpec_.tv_nsec:=((TPasMPInt64(dwMilliSeconds) mod 1000)*1000000)+(TimeSpec_.tv_nsec);
  if TimeSpec_.tv_nsec>=1000000000 then begin
   inc(TimeSpec_.tv_sec);
   dec(TimeSpec_.tv_nsec,1000000000);
  end;
  case pthread_cond_timedwait({$ifdef fpc}@fConditionVariable,@Lock.fMutex,@TimeSpec_{$else}fConditionVariable,Lock.fMutex,TimeSpec_{$endif}) of
   0:begin
    result:=wrSignaled;
   end;
   {$ifdef fpc}ESysETIMEDOUT{$else}ETIMEDOUT{$endif}:begin
    result:=wrTimeOut;
   end;
   {$ifdef fpc}ESysEINVAL{$else}EINVAL{$endif}:begin
    result:=wrAbandoned;
   end;
   else begin
    result:=wrError;
   end;
  end;
 end;
end;
{$else}
var SavedGenerationCounter:TPasMPInt32;
    WaitDone,WasLastWaiter:boolean;
begin

 result:=wrError;

 fCriticalSection.Acquire;
 try
  inc(fWaitCounter);
  SavedGenerationCounter:=fGenerationCounter;
 finally
  fCriticalSection.Release;
 end;

 Lock.Release;
 try
  repeat
   case fEvent.WaitFor(dwMilliSeconds) of
    wrSignaled:begin
     try
      WaitDone:=(fReleaseCounter>0) and (SavedGenerationCounter<>fGenerationCounter);
     finally
      fCriticalSection.Release;
     end;
     if WaitDone then begin
      result:=wrSignaled;
     end;
    end;
    wrTimeOut:begin
     WaitDone:=true;
     result:=wrTimeOut;
    end;
    wrAbandoned:begin
     WaitDone:=true;
     result:=wrAbandoned;
    end;
    else begin
     WaitDone:=true;
     result:=wrError;
    end;
   end;
  until WaitDone;
 finally
  Lock.Acquire;
 end;

 fCriticalSection.Acquire;
 try
  dec(fWaitCounter);
  dec(fReleaseCounter);
  WasLastWaiter:=fReleaseCounter=0;
 finally
  fCriticalSection.Release;
 end;

 if WasLastWaiter then begin
  fEvent.ResetEvent;
 end;

end;
{$ifend}

procedure TPasMPConditionVariable.Signal;
{$if defined(Windows)}
begin
 WakeConditionVariable(@fConditionVariable);
end;
{$elseif defined(Unix)}
begin
{$ifdef fpc}
 pthread_cond_signal(@fConditionVariable);
{$else}
 pthread_cond_signal(fConditionVariable);
{$endif}
end;
{$else}
begin
 fCriticalSection.Acquire;
 try
  if fWaitCounter>fReleaseCounter then begin
   inc(fReleaseCounter);
   inc(fGenerationCounter);
   fEvent.SetEvent;
  end;
 finally
  fCriticalSection.Release;
 end;
end;
{$ifend}

procedure TPasMPConditionVariable.Broadcast;
{$if defined(Windows)}
begin
 WakeAllConditionVariable(@fConditionVariable);
end;
{$elseif defined(Unix)}
begin
{$ifdef fpc}
 pthread_cond_broadcast(@fConditionVariable);
{$else}
 pthread_cond_signal(fConditionVariable);
{$endif}
end;
{$else}
begin
 fCriticalSection.Acquire;
 try
  if fWaitCounter>0 then begin
   fReleaseCounter:=fWaitCounter;
   inc(fGenerationCounter);
   fEvent.SetEvent;
  end;
 finally
  fCriticalSection.Release;
 end;
end;
{$ifend}

constructor TPasMPSemaphore.Create(const InitialCount,MaximumCount:TPasMPInt32);
begin
 inherited Create;
 fInitialCount:=InitialCount;
 fMaximumCount:=MaximumCount;
{$if defined(Windows)}
 fHandle:=CreateSemaphore(nil,InitialCount,MaximumCount,nil);
{$elseif defined(Unix)}
{$ifdef fpc}
 sem_init(@fHandle,0,InitialCount);
{$else}
 sem_init(fHandle,0,InitialCount);
{$endif}
{$else}
 fCurrentCount:=fInitialCount;
{$ifdef PasMPSemaphoreUseConditionVariable}
 fConditionVariableLock:=TPasMPConditionVariableLock.Create;
 fConditionVariable:=TPasMPConditionVariable.Create;
{$else}
 fCriticalSection:=TPasMPCriticalSection.Create;
 fEvent:=TPasMPEvent.Create(nil,false,false,'');
{$endif}
{$ifend}
end;

destructor TPasMPSemaphore.Destroy;
begin
{$if defined(Windows)}
 CloseHandle(fHandle);
{$elseif defined(Unix)}
{$ifdef fpc}
 sem_destroy(@fHandle);
{$else}
 sem_destroy(fHandle);
{$endif}
{$else}
{$ifdef PasMPSemaphoreUseConditionVariable}
 fConditionVariable.Free;
 fConditionVariableLock.Free;
{$else}
 fEvent.Free;
 fCriticalSection.Free;
{$endif}
{$ifend}
 inherited Destroy;
end;

procedure TPasMPSemaphore.Acquire;
begin
 Acquire(1);
end;

procedure TPasMPSemaphore.Release;
begin
 Release(1);
end;

function TPasMPSemaphore.Acquire(const AcquireCount:TPasMPInt32):TWaitResult;
{$if defined(Windows)}
var Counter:TPasMPInt32;
begin
 result:=wrError;
 for Counter:=1 to AcquireCount do begin
  case WaitForSingleObject(fHandle,INFINITE) of
   WAIT_OBJECT_0:begin
    result:=wrSignaled;
   end;
   WAIT_TIMEOUT:begin
    result:=wrTimeOut;
    exit;
   end;
   WAIT_ABANDONED:begin
    result:=wrAbandoned;
    exit;
   end;
   else begin
    result:=wrError;
    exit;
   end;
  end;
 end;
end;
{$elseif defined(Unix)}
var Counter:TPasMPInt32;
begin
 result:=wrError;
 for Counter:=1 to AcquireCount do begin
  case sem_wait({$ifdef fpc}@fHandle{$else}fHandle{$endif}) of
   0:begin
    result:=wrSignaled;
   end;
   {$ifdef fpc}ESysETIMEDOUT{$else}ETIMEDOUT{$endif}:begin
    result:=wrTimeOut;
    exit;
   end;
   {$ifdef fpc}ESysEINVAL{$else}EINVAL{$endif}:begin
    result:=wrAbandoned;
    exit;
   end;
   else begin
    result:=wrError;
    exit;
   end;
  end;
 end;
end;
{$else}
{$ifdef PasMPSemaphoreUseConditionVariable}
var Counter:TPasMPInt32;
begin
 result:=wrError;
 fConditionVariableLock.Acquire;
 try
  for Counter:=1 to AcquireCount do begin
   result:=wrSignaled;
   while fCurrentCount=0 do begin
    result:=fConditionVariable.Wait(fConditionVariableLock,INFINITE);
    if result<>wrSignaled then begin
     break;
    end;
   end;
   if result<>wrSignaled then begin
    break;
   end;
   if fCurrentCount<>0 then begin
    dec(fCurrentCount);
   end;
  end;
 finally
  fConditionVariableLock.Release;
 end;
end;
{$else}
var Counter:TPasMPInt32;
    Done:boolean;
begin
 result:=wrError;
 for Counter:=1 to AcquireCount do begin
  result:=wrSignaled;
  repeat
   fCriticalSection.Acquire;
   try
    Done:=fCurrentCount<>0;
    if Done then begin
     dec(fCurrentCount);
    end;
   finally
    fCriticalSection.Release;
   end;
   if Done then begin
    break;
   end;
   result:=fEvent.WaitFor(INFINITE);
  until result<>wrSignaled;
  if result<>wrSignaled then begin
   exit;
  end;
 end;
end;
{$endif}
{$ifend}

function TPasMPSemaphore.Release(const ReleaseCount:TPasMPInt32):TPasMPInt32;
{$if defined(Windows)}
begin
 ReleaseSemaphore(fHandle,ReleaseCount,@result);
end;
{$elseif defined(Unix)}
begin
 result:=0;
 while result<ReleaseCount do begin
  case sem_post({$ifdef fpc}@fHandle{$else}fHandle{$endif}) of
   0:begin
    inc(result);
   end;
   else begin
    break;
   end;
  end;
 end;
end;
{$else}
{$ifdef PasMPSemaphoreUseConditionVariable}
begin
 fConditionVariableLock.Acquire;
 try
  if ((fCurrentCount+ReleaseCount)<fCurrentCount) or
     ((fCurrentCount+ReleaseCount)>fMaximumCount) then begin
   // Invalid release count
   result:=0;
  end else begin
   if fCurrentCount<>0 then begin
    // There can't be any thread to wake up if the value of fCurrentCount isn't zero
    inc(fCurrentCount,ReleaseCount);
   end else begin
    fCurrentCount:=ReleaseCount;
    fConditionVariable.Broadcast;
   end;
   result:=fCurrentCount;
  end;
 finally
  fConditionVariableLock.Release;
 end;
end;
{$else}
var WakeUp:boolean;
begin
 WakeUp:=false;
 fCriticalSection.Acquire;
 try
  if ((fCurrentCount+ReleaseCount)<fCurrentCount) or
     ((fCurrentCount+ReleaseCount)>fMaximumCount) then begin
   // Invalid release count
   result:=0;
  end else begin
   if fCurrentCount<>0 then begin
    // There can't be any thread to wake up if the value of fCurrentCount isn't zero
    inc(fCurrentCount,ReleaseCount);
   end else begin
    fCurrentCount:=ReleaseCount;
    WakeUp:=true;
   end;
   result:=fCurrentCount;
  end;
 finally
  fCriticalSection.Release;
 end;
 if WakeUp then begin
  fEvent.SetEvent;
 end;
end;
{$endif}
{$ifend}

constructor TPasMPInvertedSemaphore.Create(const InitialCount,MaximumCount:TPasMPInt32);
begin
 inherited Create;
 fInitialCount:=InitialCount;
 fMaximumCount:=MaximumCount;
 fCurrentCount:=InitialCount;
 fConditionVariableLock:=TPasMPConditionVariableLock.Create;
 fConditionVariable:=TPasMPConditionVariable.Create;
end;

destructor TPasMPInvertedSemaphore.Destroy;
begin
 fConditionVariable.Free;
 fConditionVariableLock.Free;
 inherited Destroy;
end;

procedure TPasMPInvertedSemaphore.Acquire;
var Temp:TPasMPInt32;
begin
 Acquire(1,Temp);
end;

procedure TPasMPInvertedSemaphore.Release;
var Temp:TPasMPInt32;
begin
 Release(1,Temp);
end;

function TPasMPInvertedSemaphore.Acquire(const AcquireCount:TPasMPInt32;out Count:TPasMPInt32):TPasMPInt32;
begin
 fConditionVariableLock.Acquire;
 try
  if AcquireCount<=0 then begin
   result:=0;
  end else if (fCurrentCount+AcquireCount)<fMaximumCount then begin
   result:=AcquireCount;
  end else begin
   result:=fMaximumCount-fCurrentCount;
  end;
  inc(fCurrentCount,result);
  Count:=fCurrentCount;
 finally
  fConditionVariableLock.Release;
 end;
end;

function TPasMPInvertedSemaphore.Release(const ReleaseCount:TPasMPInt32;out Count:TPasMPInt32):TPasMPInt32;
begin
 fConditionVariableLock.Acquire;
 try
  if ReleaseCount<=0 then begin
   result:=0;
  end else if fCurrentCount<ReleaseCount then begin
   result:=fCurrentCount;
  end else begin
   result:=ReleaseCount;
  end;
  dec(fCurrentCount,result);
  if fCurrentCount=0 then begin
   fConditionVariable.Broadcast;
  end;
  Count:=fCurrentCount;
 finally
  fConditionVariableLock.Release;
 end;
end;

function TPasMPInvertedSemaphore.Wait(const dwMilliSeconds:TPasMPUInt32=INFINITE):TWaitResult;
begin
 result:=wrSignaled;
 fConditionVariableLock.Acquire;
 try
  while fCurrentCount<>0 do begin
   result:=fConditionVariable.Wait(fConditionVariableLock,dwMilliSeconds);
   if dwMilliSeconds=INFINITE then begin
    // special case due to spurious wakeups of condition variables
    if not (result in [wrSignaled,wrTimeOut]) then begin
     break;
    end;
   end else begin
    if result<>wrSignaled then begin
     break;
    end;
   end;
  end;
 finally
  fConditionVariableLock.Release;
 end;
end;

constructor TPasMPMultipleReaderSingleWriterLock.Create;
begin
 inherited Create;
{$if defined(Windows)}
 InitializeSRWLock(@fSRWLock);
{$elseif defined(Unix)}
{$ifdef fpc}
 pthread_rwlock_init(@fReadWriteLock,nil);
{$else}
 pthread_rwlock_init(fReadWriteLock,nil);
{$endif}
{$else}
 fReaders:=0;
 fWriters:=0;
 fConditionVariableLock:=TPasMPConditionVariableLock.Create;
 fConditionVariable:=TPasMPConditionVariable.Create;
{$ifend}
end;

destructor TPasMPMultipleReaderSingleWriterLock.Destroy;
begin
{$if defined(Windows)}
{$elseif defined(Unix)}
{$ifdef fpc}
 pthread_rwlock_destroy(@fReadWriteLock);
{$else}
 pthread_rwlock_destroy(fReadWriteLock);
{$endif}
{$else}
 fConditionVariable.Free;
 fConditionVariableLock.Free;
{$ifend}
 inherited Destroy;
end;

procedure TPasMPMultipleReaderSingleWriterLock.AcquireRead;
{$if defined(Windows)}
begin
 AcquireSRWLockShared(@fSRWLock);
end;
{$elseif defined(Unix)}
begin
{$ifdef fpc}
 pthread_rwlock_rdlock(@fReadWriteLock);
{$else}
 pthread_rwlock_rdlock(fReadWriteLock);
{$endif}
end;
{$else}
var State:TPasMPInt32;
begin
 fConditionVariableLock.Acquire;
 try
  while fWriters<>0 do begin
   fConditionVariable.Wait(fConditionVariableLock,INFINITE);
  end;
  inc(fReaders);
 finally
  fConditionVariableLock.Release;
 end;
end;
{$ifend}

function TPasMPMultipleReaderSingleWriterLock.TryAcquireRead:boolean;
{$if defined(Windows)}
begin
 result:=TryAcquireSRWLockShared(@fSRWLock);
end;
{$elseif defined(Unix)}
begin
{$ifdef fpc}
 result:=pthread_rwlock_tryrdlock(@fReadWriteLock)=0;
{$else}
 result:=pthread_rwlock_tryrdlock(fReadWriteLock)=0;
{$endif}
end;
{$else}
var State:TPasMPInt32;
begin
 fConditionVariableLock.Acquire;
 try
  result:=fWriters=0;
  if result then begin
   inc(fReaders);
  end;
 finally
  fConditionVariableLock.Release;
 end;
end;
{$ifend}

procedure TPasMPMultipleReaderSingleWriterLock.ReleaseRead;
{$if defined(Windows)}
begin
 ReleaseSRWLockShared(@fSRWLock);
end;
{$elseif defined(Unix)}
begin
{$ifdef fpc}
 pthread_rwlock_unlock(@fReadWriteLock);
{$else}
 pthread_rwlock_unlock(fReadWriteLock);
{$endif}
end;
{$else}
begin
 fConditionVariableLock.Acquire;
 try
  dec(fReaders);
  if fReaders=0 then begin
   fConditionVariable.Broadcast;
  end;
 finally
  fConditionVariableLock.Release;
 end;
end;
{$ifend}

procedure TPasMPMultipleReaderSingleWriterLock.AcquireWrite;
{$if defined(Windows)}
begin
 AcquireSRWLockExclusive(@fSRWLock);
end;
{$elseif defined(Unix)}
begin
{$ifdef fpc}
 pthread_rwlock_wrlock(@fReadWriteLock);
{$else}
 pthread_rwlock_wrlock(fReadWriteLock);
{$endif}
end;
{$else}
begin
 fConditionVariableLock.Acquire;
 try
  while (fReaders<>0) or (fWriters<>0) do begin
   fConditionVariable.Wait(fConditionVariableLock,INFINITE);
  end;
  inc(fWriters);
 finally
  fConditionVariableLock.Release;
 end;
end;
{$ifend}

function TPasMPMultipleReaderSingleWriterLock.TryAcquireWrite:boolean;
{$if defined(Windows)}
begin
 result:=TryAcquireSRWLockExclusive(@fSRWLock);
end;
{$elseif defined(Unix)}
begin
{$ifdef fpc}
 result:=pthread_rwlock_trywrlock(@fReadWriteLock)=0;
{$else}
 result:=pthread_rwlock_trywrlock(fReadWriteLock)=0;
{$endif}
end;
{$else}
begin
 fConditionVariableLock.Acquire;
 try
  result:=(fReaders=0) and (fWriters=0);
  if result then begin
   inc(fWriters);
  end;
 finally
  fConditionVariableLock.Release;
 end;
end;
{$ifend}

procedure TPasMPMultipleReaderSingleWriterLock.ReleaseWrite;
{$if defined(Windows)}
begin
 ReleaseSRWLockExclusive(@fSRWLock);
end;
{$elseif defined(Unix)}
begin
{$ifdef fpc}
 pthread_rwlock_unlock(@fReadWriteLock);
{$else}
 pthread_rwlock_unlock(fReadWriteLock);
{$endif}
end;
{$else}
begin
 fConditionVariableLock.Acquire;
 try
  dec(fWriters);
  if fWriters=0 then begin
   fConditionVariable.Broadcast;
  end;
 finally
  fConditionVariableLock.Release;
 end;
end;
{$ifend}

procedure TPasMPMultipleReaderSingleWriterLock.ReadToWrite;
{$if defined(Windows)}
begin
 ReleaseSRWLockShared(@fSRWLock);
 AcquireSRWLockExclusive(@fSRWLock);
end;
{$elseif defined(Unix)}
begin
{$ifdef fpc}
 pthread_rwlock_unlock(@fReadWriteLock);
 pthread_rwlock_wrlock(@fReadWriteLock);
{$else}
 pthread_rwlock_unlock(fReadWriteLock);
 pthread_rwlock_wrlock(fReadWriteLock);
{$endif}
end;
{$else}
begin
 fConditionVariableLock.Acquire;
 try
  dec(fReaders);
  while (fWriters<>0) and (fReaders<>0) do begin
   fConditionVariable.Wait(fConditionVariableLock,INFINITE);
  end;
  inc(fWriters);
 finally
  fConditionVariableLock.Release;
 end;
end;
{$ifend}

procedure TPasMPMultipleReaderSingleWriterLock.WriteToRead;
{$if defined(Windows)}
begin
 ReleaseSRWLockExclusive(@fSRWLock);
 AcquireSRWLockShared(@fSRWLock);
end;
{$elseif defined(Unix)}
begin
{$ifdef fpc}
 pthread_rwlock_unlock(@fReadWriteLock);
 pthread_rwlock_rdlock(@fReadWriteLock);
{$else}
 pthread_rwlock_unlock(fReadWriteLock);
 pthread_rwlock_rdlock(fReadWriteLock);
{$endif}
end;
{$else}
begin
 fConditionVariableLock.Acquire;
 try
  dec(fWriters);
  while fWriters<>0 do begin
   fConditionVariable.Wait(fConditionVariableLock,INFINITE);
  end;
  inc(fReaders);
 finally
  fConditionVariableLock.Release;
 end;
end;
{$ifend}

procedure TPasMPMultipleReaderSingleWriterLock.BeginRead;
begin
 AcquireRead;
end;

procedure TPasMPMultipleReaderSingleWriterLock.EndRead;
begin
 ReleaseRead;
end;

function TPasMPMultipleReaderSingleWriterLock.BeginWrite:boolean;
begin
 AcquireWrite;
 result:=true;
end;

procedure TPasMPMultipleReaderSingleWriterLock.EndWrite;
begin
 ReleaseWrite;
end;

constructor TPasMPMultipleReaderSingleWriterSpinLock.Create;
begin
 inherited Create;
 fState:=0;
end;

destructor TPasMPMultipleReaderSingleWriterSpinLock.Destroy;
begin
 inherited Destroy;
end;

procedure TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead;
var State:TPasMPInt32;
begin
 repeat
  State:=fState and TPasMPInt32(TPasMPUInt32($fffffffe));
  if TPasMPInterlocked.CompareExchange(fState,State+2,State)=State then begin
   break;
  end else begin
   TPasMP.Relax;
  end;
 until false;
end;

function TPasMPMultipleReaderSingleWriterSpinLock.TryAcquireRead:boolean;
var State:TPasMPInt32;
begin
 State:=fState and TPasMPInt32(TPasMPUInt32($fffffffe));
 result:=TPasMPInterlocked.CompareExchange(fState,State+2,State)=State;
end;

procedure TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead;
begin
 TPasMPInterlocked.Sub(fState,2);
end;

procedure TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite;
var State:TPasMPInt32;
begin
 repeat
  State:=fState and TPasMPInt32(TPasMPUInt32($fffffffe));
  if TPasMPInterlocked.CompareExchange(fState,State or 1,State)=State then begin
   break;
  end else begin
   TPasMP.Relax;
  end;
 until false;
 while fState<>1 do begin
  TPasMP.Relax;
 end;
end;

function TPasMPMultipleReaderSingleWriterSpinLock.TryAcquireWrite:boolean;
var State:TPasMPInt32;
begin
 State:=fState and TPasMPInt32(TPasMPUInt32($fffffffe));
 result:=TPasMPInterlocked.CompareExchange(fState,1,State)=State;
end;

procedure TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite;
begin
 TPasMPInterlocked.Write(fState,0);
end;

procedure TPasMPMultipleReaderSingleWriterSpinLock.ReadToWrite;
var State:TPasMPInt32;
begin
 TPasMPInterlocked.Sub(fState,2);
 repeat
  State:=fState and TPasMPInt32(TPasMPUInt32($fffffffe));
  if TPasMPInterlocked.CompareExchange(fState,State or 1,State)=State then begin
   break;
  end else begin
   TPasMP.Relax;
  end;
 until false;
 while fState<>1 do begin
  TPasMP.Relax;
 end;
end;

procedure TPasMPMultipleReaderSingleWriterSpinLock.WriteToRead;
begin
 TPasMPInterlocked.Write(fState,2);
end;

procedure TPasMPMultipleReaderSingleWriterSpinLock.BeginRead;
begin
 AcquireRead;
end;

procedure TPasMPMultipleReaderSingleWriterSpinLock.EndRead;
begin
 ReleaseRead;
end;

function TPasMPMultipleReaderSingleWriterSpinLock.BeginWrite:boolean;
begin
 AcquireWrite;
 result:=true;
end;

procedure TPasMPMultipleReaderSingleWriterSpinLock.EndWrite;
begin
 ReleaseWrite;
end;

class procedure TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(var LockState:TPasMPInt32);
var State:TPasMPInt32;
begin
 repeat
  State:=LockState and TPasMPInt32(TPasMPUInt32($fffffffe));
  if TPasMPInterlocked.CompareExchange(LockState,State+2,State)=State then begin
   break;
  end else begin
   TPasMP.Relax;
  end;
 until false;
end;

class function TPasMPMultipleReaderSingleWriterSpinLock.TryAcquireRead(var LockState:TPasMPInt32):boolean;
var State:TPasMPInt32;
begin
 State:=LockState and TPasMPInt32(TPasMPUInt32($fffffffe));
 result:=TPasMPInterlocked.CompareExchange(LockState,State+2,State)=State;
end;

class procedure TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(var LockState:TPasMPInt32);
begin
 TPasMPInterlocked.Sub(LockState,2);
end;

class procedure TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(var LockState:TPasMPInt32);
var State:TPasMPInt32;
begin
 repeat
  State:=LockState and TPasMPInt32(TPasMPUInt32($fffffffe));
  if TPasMPInterlocked.CompareExchange(LockState,State or 1,State)=State then begin
   break;
  end else begin
   TPasMP.Relax;
  end;
 until false;
 while LockState<>1 do begin
  TPasMP.Relax;
 end;
end;

class function TPasMPMultipleReaderSingleWriterSpinLock.TryAcquireWrite(var LockState:TPasMPInt32):boolean;
var State:TPasMPInt32;
begin
 State:=LockState and TPasMPInt32(TPasMPUInt32($fffffffe));
 result:=TPasMPInterlocked.CompareExchange(LockState,1,State)=State;
end;

class procedure TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(var LockState:TPasMPInt32);
begin
 TPasMPInterlocked.Write(LockState,0);
end;

class procedure TPasMPMultipleReaderSingleWriterSpinLock.ReadToWrite(var LockState:TPasMPInt32);
var State:TPasMPInt32;
begin
 TPasMPInterlocked.Sub(LockState,2);
 repeat
  State:=LockState and TPasMPInt32(TPasMPUInt32($fffffffe));
  if TPasMPInterlocked.CompareExchange(LockState,State or 1,State)=State then begin
   break;
  end else begin
   TPasMP.Relax;
  end;
 until false;
 while LockState<>1 do begin
  TPasMP.Relax;
 end;
end;

class procedure TPasMPMultipleReaderSingleWriterSpinLock.WriteToRead(var LockState:TPasMPInt32);
begin
 TPasMPInterlocked.Write(LockState,2);
end;

constructor TPasMPSlimReaderWriterLock.Create;
begin
 inherited Create;
{$if defined(Windows)}
 InitializeSRWLock(@fSRWLock);
{$elseif defined(Unix)}
{$ifdef fpc}
 pthread_rwlock_init(@fReadWriteLock,nil);
{$else}
 pthread_rwlock_init(fReadWriteLock,nil);
{$endif}
{$else}
 fCount:=0;
 fConditionVariableLock:=TPasMPConditionVariableLock.Create;
 fConditionVariable:=TPasMPConditionVariable.Create;
{$ifend}
end;

destructor TPasMPSlimReaderWriterLock.Destroy;
begin
{$if defined(Windows)}
{$elseif defined(Unix)}
{$ifdef fpc}
 pthread_rwlock_destroy(@fReadWriteLock);
{$else}
 pthread_rwlock_destroy(fReadWriteLock);
{$endif}
{$else}
 fConditionVariable.Free;
 fConditionVariableLock.Free;
{$ifend}
 inherited Destroy;
end;

procedure TPasMPSlimReaderWriterLock.Acquire;
{$if defined(Windows)}
begin
 AcquireSRWLockExclusive(@fSRWLock);
end;
{$elseif defined(Unix)}
begin
{$ifdef fpc}
 pthread_rwlock_wrlock(@fReadWriteLock);
{$else}
 pthread_rwlock_wrlock(fReadWriteLock);
{$endif}
end;
{$else}
begin
 fConditionVariableLock.Acquire;
 try
  while fCount<>0 do begin
   fConditionVariable.Wait(fConditionVariableLock,INFINITE);
  end;
  inc(fCount);
 finally
  fConditionVariableLock.Release;
 end;
end;
{$ifend}

function TPasMPSlimReaderWriterLock.TryAcquire:boolean;
{$if defined(Windows)}
begin
 result:=TryAcquireSRWLockExclusive(@fSRWLock);
end;
{$elseif defined(Unix)}
begin
{$ifdef fpc}
 result:=pthread_rwlock_trywrlock(@fReadWriteLock)=0;
{$else}
 result:=pthread_rwlock_trywrlock(fReadWriteLock)=0;
{$endif}
end;
{$else}
begin
 fConditionVariableLock.Acquire;
 try
  result:=fCount=0;
  if result then begin
   inc(fCount);
  end;
 finally
  fConditionVariableLock.Release;
 end;
end;
{$ifend}

procedure TPasMPSlimReaderWriterLock.Release;
{$if defined(Windows)}
begin
 ReleaseSRWLockExclusive(@fSRWLock);
end;
{$elseif defined(Unix)}
begin
{$ifdef fpc}
 pthread_rwlock_unlock(@fReadWriteLock);
{$else}
 pthread_rwlock_unlock(fReadWriteLock);
{$endif}
end;
{$else}
begin
 fConditionVariableLock.Acquire;
 try
  dec(fCount);
  if fCount=0 then begin
   fConditionVariable.Broadcast;
  end;
 finally
  fConditionVariableLock.Release;
 end;
end;
{$ifend}

constructor TPasMPSpinLock.Create;
begin
 inherited Create;
{$if defined(PasMPPThreadSpinLock)}
 pthread_spin_init(@fSpinLock,0);
{$else}
 fState:=0;
{$ifend}
end;

destructor TPasMPSpinLock.Destroy;
begin
{$if defined(PasMPPThreadSpinLock)}
 pthread_spin_destroy(@fSpinLock);
{$ifend}
 inherited Destroy;
end;

procedure TPasMPSpinLock.Acquire; {$if defined(PasMPPThreadSpinLock)}
begin
 pthread_spin_lock(@fSpinLock);
end;
{$elseif defined(cpu386)}assembler; register;
asm
 test dword ptr [eax+TPasMPSpinLock.fState],1
 jnz @SpinLoop
@TryAgain:
 lock bts dword ptr [eax+TPasMPSpinLock.fState],0
 jnc @TryDone
@SpinLoop:
 db $f3,$90 // pause (rep nop)
 test dword ptr [eax+TPasMPSpinLock.fState],1
 jnz @SpinLoop
 jmp @TryAgain
@TryDone:
end;
{$elseif defined(cpux86_64)}assembler; register;
{$ifdef Windows}
asm
 // Win64 ABI
 // rcx = self
 test dword ptr [rcx+TPasMPSpinLock.fState],1
 jnz @SpinLoop
@TryAgain:
 lock bts dword ptr [rcx+TPasMPSpinLock.fState],0
 jnc @TryDone
@SpinLoop:
 pause
 test dword ptr [rcx+TPasMPSpinLock.fState],1
 jnz @SpinLoop
 jmp @TryAgain
@TryDone:
end;
{$else}
asm
 // System V ABI
 // rdi = self
 test dword ptr [edi+TPasMPSpinLock.fState],1
 jnz @SpinLoop
@TryAgain:
 lock bts dword ptr [rdi+TPasMPSpinLock.fState],0
 jnc @TryDone
@SpinLoop:
 pause
 test dword ptr [rdi+TPasMPSpinLock.fState],1
 jnz @SpinLoop
 jmp @TryAgain
@TryDone:
end;
{$endif}
{$else}
begin
 while TPasMPInterlocked.CompareExchange(fState,-1,0)<>0 do begin
  TPasMP.Yield;
 end;
end;
{$ifend}

function TPasMPSpinLock.TryAcquire:longbool; {$if defined(PasMPPThreadSpinLock)}
begin
 result:=pthread_spin_trylock(@fSpinLock)=0;
end;
{$elseif defined(cpu386)}assembler; register;
asm
 xor eax,eax
 lock bts dword ptr [eax+TPasMPSpinLock.fState],0
 jc @Failed
  not eax
 @Failed:
end;
{$elseif defined(cpux86_64)}assembler; register;
{$ifdef Windows}
asm
 // Win64 ABI
 // rcx = self
 xor rax,rax
 lock bts dword ptr [rcx+TPasMPSpinLock.fState],0
 jc @Failed
  not rax
 @Failed:
end;
{$else}
asm
 // System V ABI
 // rdi = self
 xor rax,rax
 lock bts dword ptr [rdi+TPasMPSpinLock.fState],0
 jc @Failed
  not rax
 @Failed:
end;
{$endif}
{$else}
begin
 result:=TPasMPInterlocked.CompareExchange(fState,-1,0)=0;
end;
{$ifend}

procedure TPasMPSpinLock.Release; {$if defined(PasMPPThreadSpinLock)}
begin
 pthread_spin_unlock(@fSpinLock);
end;
{$elseif defined(cpu386)}assembler; register;
asm
 mov dword ptr [eax+TPasMPSpinLock.fState],0
end;
{$elseif defined(cpux86_64)}assembler; register;
{$ifdef Windows}
asm
 // Win64 ABI
 // rcx = self
 mov dword ptr [rcx+TPasMPSpinLock.fState],0
end;
{$else}
asm
 // System V ABI
 // rdi = self
 mov dword ptr [rdi+TPasMPSpinLock.fState],0
end;
{$endif}
{$else}
begin
 TPasMPInterlocked.Exchange(fState,0);
end;
{$ifend}

constructor TPasMPBenaphore.Create;
begin
 inherited Create;
 fSemaphore:=TPasMPSemaphore.Create(0,1);
 fLockCount:=0;
end;

destructor TPasMPBenaphore.Destroy;
begin
 FreeAndNil(fSemaphore);
 inherited Destroy;
end;

procedure TPasMPBenaphore.Acquire;
begin
 if TPasMPInterlocked.Increment(fLockCount)>1 then begin
  fSemaphore.Acquire;
 end;
end;

function TPasMPBenaphore.TryAcquire:longbool;
begin
 result:=TPasMPInterlocked.CompareExchange(fLockCount,1,0)=0;
end;

procedure TPasMPBenaphore.Release;
begin
 if TPasMPInterlocked.Decrement(fLockCount)>0 then begin
  fSemaphore.Release;
 end;
end;

constructor TPasMPRecursiveBenaphore.Create;
begin
 inherited Create;
 fSemaphore:=TPasMPSemaphore.Create(0,1);
 fOwningThreadID:=0;
 fLockCount:=0;
 fRecursionCount:=0;
end;

destructor TPasMPRecursiveBenaphore.Destroy;
begin
 FreeAndNil(fSemaphore);
 inherited Destroy;
end;

procedure TPasMPRecursiveBenaphore.Acquire;
var CurrentThreadID:TThreadID;
begin
{$if (defined(NEXTGEN) or not defined(Windows)) and not defined(FPC)}
 CurrentThreadID:=TThread.CurrentThread.ThreadID;
{$else}
 CurrentThreadID:=GetCurrentThreadID;
{$ifend}
 if TPasMPInterlocked.Increment(fLockCount)>1 then begin
  if fOwningThreadID=CurrentThreadID then begin
   inc(fRecursionCount);
   exit;
  end else begin
   fSemaphore.Acquire;
  end;
 end;
 fOwningThreadID:=CurrentThreadID;
 fRecursionCount:=1;
end;

function TPasMPRecursiveBenaphore.TryAcquire:longbool;
var CurrentThreadID:TThreadID;
begin
{$if (defined(NEXTGEN) or not defined(Windows)) and not defined(FPC)}
 CurrentThreadID:=TThread.CurrentThread.ThreadID;
{$else}
 CurrentThreadID:=GetCurrentThreadID;
{$ifend}
 if TPasMPInterlocked.CompareExchange(fLockCount,1,0)=0 then begin
  fOwningThreadID:=CurrentThreadID;
  fRecursionCount:=1;
  result:=true;
 end else if fOwningThreadID=CurrentThreadID then begin
  TPasMPInterlocked.Increment(fLockCount);
  inc(fRecursionCount);
  result:=true;
 end else begin
  result:=false;
 end;
end;

procedure TPasMPRecursiveBenaphore.Release;
var CurrentThreadID:TThreadID;
begin
{$if (defined(NEXTGEN) or not defined(Windows)) and not defined(FPC)}
 CurrentThreadID:=TThread.CurrentThread.ThreadID;
{$else}
 CurrentThreadID:=GetCurrentThreadID;
{$ifend}
 if fOwningThreadID=CurrentThreadID then begin
  dec(fRecursionCount);
  if fRecursionCount=0 then begin
   fOwningThreadID:={$ifdef fpc}TThreadID(0){$else}0{$endif};
   if TPasMPInterlocked.Decrement(fLockCount)>0 then begin
    fSemaphore.Release;
   end;
  end else begin
   TPasMPInterlocked.Decrement(fLockCount);
  end;
 end else begin
  raise EPasMPRecursiveBenaphore.Create('Releasing TPasMPRecursiveBenaphore not owned by current thread!');
 end;
end;

constructor TPasMPBarrier.Create(const Count:TPasMPInt32);
begin
 inherited Create;
{$if defined(PasMPPThreadBarrier)}
 pthread_barrier_init(@fBarrier,nil,Count);
{$else}
 fCount:=Count;
 fTotal:=0;
 fConditionVariableLock:=TPasMPConditionVariableLock.Create;
 fConditionVariable:=TPasMPConditionVariable.Create;
{$ifend}
end;

destructor TPasMPBarrier.Destroy;
begin
{$if defined(PasMPPThreadBarrier)}
 pthread_barrier_destroy(@fBarrier);
{$else}
 fConditionVariableLock.Acquire;
 try
  while fTotal>PasMPBarrierFlag do begin
   // Wait until everyone exits the barrier
   fConditionVariable.Wait(fConditionVariableLock,INFINITE);
  end;
 finally
  fConditionVariableLock.Release;
 end;
 fConditionVariable.Free;
 fConditionVariableLock.Free;
{$ifend}
 inherited Destroy;
end;

function TPasMPBarrier.Wait:boolean;
{$if defined(PasMPPThreadBarrier)}
begin
 result:=pthread_barrier_wait(@fBarrier)=PTHREAD_BARRIER_SERIAL_THREAD;
end;
{$else}
begin
 fConditionVariableLock.Acquire;
 try
  while fTotal>PasMPBarrierFlag do begin
   // Wait until everyone exits the barrier
   fConditionVariable.Wait(fConditionVariableLock,INFINITE);
  end;
  if fTotal=PasMPBarrierFlag then begin
   // Are we the first to enter?
   fTotal:=0;
  end;
  inc(fTotal);
  if fTotal=fCount then begin
   inc(fTotal,PasMPBarrierFlag-1);
   fConditionVariable.Broadcast;
   result:=true;
  end else begin
   while fTotal<PasMPBarrierFlag do begin
    // Wait until enough threads enter the barrier
    fConditionVariable.Wait(fConditionVariableLock,INFINITE);
   end;
   dec(fTotal);
   if ftotal=PasMPBarrierFlag then begin
    // Get entering threads to wake up
    fConditionVariable.Broadcast;
   end;
   result:=false;
  end;
 finally
  fConditionVariableLock.Release;
 end;
end;
{$ifend}

constructor TPasMPThreadSafeStack.Create;
{$ifdef PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}
begin
 inherited Create;
 TPasMPMemory.AllocateAlignedMemory(fHead,SizeOf(TPasMPTaggedPointer),PasMPCPUCacheLineSize);
 fHead^.PointerValue:=nil;
 fHead^.TagValue:=0;
end;
{$else}
begin
 inherited Create;
 fCriticalSection:=TPasMPCriticalSection.Create;
 fHead:=nil;
end;
{$endif}

destructor TPasMPThreadSafeStack.Destroy;
{$ifdef PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}
begin
 TPasMPMemory.FreeAlignedMemory(fHead);
 inherited Destroy;
end;
{$else}
begin
 fCriticalSection.Free;
 inherited Destroy;
end;
{$endif}

procedure TPasMPThreadSafeStack.Clear;
{$ifdef PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}
begin
 fHead^.PointerValue:=nil;
 fHead^.TagValue:=0;
end;
{$else}
begin
 fHead:=nil;
end;
{$endif}

function TPasMPThreadSafeStack.IsEmpty:boolean;
{$ifdef PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}
begin
 result:=not assigned(fHead^.PointerValue);
end;
{$else}
begin
 result:=true;
 if assigned(fHead) then begin
  fCriticalSection.Acquire;
  try
   if assigned(fHead) then begin
    result:=false;
   end;
  finally
   fCriticalSection.Leave;
  end;
 end;
end;
{$endif}

function TPasMPThreadSafeStack.Push(const Item:pointer):pointer;
{$ifdef PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}
var OldHead,NewHead,ComparsionHead:TPasMPTaggedPointer;
begin
 OldHead:=fHead^;
 repeat
  pointer(Item^):=OldHead.PointerValue;
  NewHead.PointerValue:=Item;
  NewHead.TagValue:=OldHead.TagValue+1;
  ComparsionHead:=OldHead;
  OldHead.Value:=TPasMPInterlocked.CompareExchange(fHead^.Value,NewHead.Value,ComparsionHead.Value);
 until {$ifdef cpu64}(OldHead.PointerValue=ComparsionHead.PointerValue) and (OldHead.TagValue=ComparsionHead.TagValue){$else}OldHead.Value.Value=ComparsionHead.Value.Value{$endif};
 result:=OldHead.PointerValue;
end;
{$else}
begin
 fCriticalSection.Acquire;
 try
  result:=fHead;
  pointer(Item^):=fHead;
  fHead:=Item;
 finally
  fCriticalSection.Leave;
 end;
end;
{$endif}

function TPasMPThreadSafeStack.Pop:pointer;
{$ifdef PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}
var OldHead,NewHead,ComparsionHead:TPasMPTaggedPointer;
begin
 if assigned(fHead^.PointerValue) then begin
  OldHead:=fHead^;
  while assigned(OldHead.PointerValue) do begin
   NewHead.PointerValue:=pointer(OldHead.PointerValue^);
   NewHead.TagValue:=NewHead.TagValue+1;
   ComparsionHead:=OldHead;
   OldHead.Value:=TPasMPInterlocked.CompareExchange(fHead^.Value,NewHead.Value,ComparsionHead.Value);
   if {$ifdef cpu64}(OldHead.PointerValue=ComparsionHead.PointerValue) and (OldHead.TagValue=ComparsionHead.TagValue){$else}OldHead.Value.Value=ComparsionHead.Value.Value{$endif} then begin
    break;
   end;
  end;
  result:=OldHead.PointerValue;
 end else begin
  result:=nil;
 end;
end;
{$else}
begin
 result:=nil;
 if assigned(fHead) then begin
  fCriticalSection.Acquire;
  try
   if assigned(fHead) then begin
    result:=fHead;
    fHead:=pointer(result^);
   end;
  finally
   fCriticalSection.Leave;
  end;
 end;
end;
{$endif}

constructor TPasMPThreadSafeQueue.Create(ItemSize:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
{$ifdef PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}
var Node:PPasMPThreadSafeQueueNode;
begin
 inherited Create;
 fItemSize:=ItemSize;
 fInternalNodeSize:=SizeOf(TPasMPThreadSafeQueueNode)+fItemSize;
 fAddCPUCacheLinePaddingToInternalItemDataStructure:=AddCPUCacheLinePaddingToInternalItemDataStructure;
 if AddCPUCacheLinePaddingToInternalItemDataStructure then begin
  fInternalNodeSize:=TPasMPMath.RoundUpToPowerOfTwo(Max(fInternalNodeSize,PasMPCPUCacheLineSize));
 end else begin
  fInternalNodeSize:=TPasMPMath.RoundUpToPowerOfTwo(Max(fInternalNodeSize,PasMPDoubleNativeMachineWordAtomicCompareExchangeAlignment));
 end;
 fHead:=nil;
 fTail:=nil;
 TPasMPMemory.AllocateAlignedMemory(fHead,SizeOf(TPasMPTaggedPointer),PasMPCPUCacheLineSize);
 TPasMPMemory.AllocateAlignedMemory(fTail,SizeOf(TPasMPTaggedPointer),PasMPCPUCacheLineSize);
 TPasMPMemory.AllocateAlignedMemory(Node,fInternalNodeSize,PasMPCPUCacheLineSize);
 Node^.Previous.PointerValue:=nil;
 Node^.Previous.TagValue:=0;
 Node^.Next.PointerValue:=nil;
 Node^.Next.TagValue:=0;
 fHead^.PointerValue:=Node;
 fHead^.TagValue:=0;
 fTail^.PointerValue:=Node;
 fTail^.TagValue:=0;
 InitializeItem(@Node^.Data);
end;
{$else}
begin
 inherited Create;
 fItemSize:=ItemSize;
 fAddCPUCacheLinePaddingToInternalItemDataStructure:=AddCPUCacheLinePaddingToInternalItemDataStructure;
 fInternalNodeSize:=SizeOf(TPasMPThreadSafeQueueNode)+fItemSize;
 if AddCPUCacheLinePaddingToInternalItemDataStructure then begin
  fInternalNodeSize:=TPasMPMath.RoundUpToPowerOfTwo(Max(fInternalNodeSize,PasMPCPUCacheLineSize));
 end;
 fHeadCriticalSection:=TPasMPCriticalSection.Create;
 fTailCriticalSection:=TPasMPCriticalSection.Create;
 fHead:=nil;
 if fAddCPUCacheLinePaddingToInternalItemDataStructure then begin
  TPasMPMemory.AllocateAlignedMemory(fHead,fInternalNodeSize,PasMPCPUCacheLineSize);
 end else begin
  GetMem(fHead,fInternalNodeSize);
 end;
 fHead^.Next:=nil;
 fTail:=fHead;
 InitializeItem(@fHead^.Data);
end;
{$endif}

destructor TPasMPThreadSafeQueue.Destroy;
{$ifdef PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}
var Item:pointer;
begin
 GetMem(Item,fItemSize);
 try
  InitializeItem(Item);
  while Dequeue(Item^) do begin
   FinalizeItem(Item);
  end;
 finally
  FreeMem(Item);
 end;
 if assigned(PPasMPThreadSafeQueueNode(fTail)^.Previous.PointerValue) then begin
  FinalizeItem(@PPasMPThreadSafeQueueNode(PPasMPThreadSafeQueueNode(fTail)^.Previous.PointerValue)^.Data);
  TPasMPMemory.FreeAlignedMemory(PPasMPThreadSafeQueueNode(fTail)^.Previous.PointerValue);
 end;
 TPasMPMemory.FreeAlignedMemory(fTail);
 TPasMPMemory.FreeAlignedMemory(fHead);
 inherited Destroy;
end;
{$else}
var CurrentNode,NextNode:PPasMPThreadSafeQueueNode;
begin
 CurrentNode:=fHead;
 while assigned(CurrentNode) do begin
  NextNode:=CurrentNode^.Next;
  FinalizeItem(@CurrentNode^.Data);
  if fAddCPUCacheLinePaddingToInternalItemDataStructure then begin
   TPasMPMemory.FreeAlignedMemory(CurrentNode);
  end else begin
   FreeMem(CurrentNode);
  end;
  CurrentNode:=NextNode;
 end;
 fTailCriticalSection.Free;
 fHeadCriticalSection.Free;
 inherited Destroy;
end;
{$endif}

procedure TPasMPThreadSafeQueue.InitializeItem(const Data:pointer);
begin
end;

procedure TPasMPThreadSafeQueue.FinalizeItem(const Data:pointer);
begin
end;

procedure TPasMPThreadSafeQueue.CopyItem(const Source,Destination:pointer);
begin
 Move(Source^,Destination^,fItemSize);
end;

procedure TPasMPThreadSafeQueue.Clear;
{$ifdef PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}
var Node:PPasMPThreadSafeQueueNode;
    Item:pointer;
begin
 GetMem(Item,fItemSize);
 try
  InitializeItem(Item);
  while Dequeue(Item^) do begin
   FinalizeItem(Item);
  end;
 finally
  FreeMem(Item);
 end;
 if assigned(PPasMPThreadSafeQueueNode(fTail)^.Previous.PointerValue) then begin
  FinalizeItem(@PPasMPThreadSafeQueueNode(PPasMPThreadSafeQueueNode(fTail)^.Previous.PointerValue)^.Data);
  TPasMPMemory.FreeAlignedMemory(PPasMPThreadSafeQueueNode(fTail)^.Previous.PointerValue);
 end;
 TPasMPMemory.AllocateAlignedMemory(Node,fInternalNodeSize,PasMPCPUCacheLineSize);
 Node^.Previous.PointerValue:=nil;
 Node^.Previous.TagValue:=0;
 Node^.Next.PointerValue:=nil;
 Node^.Next.TagValue:=0;
 fHead^.PointerValue:=Node;
 fHead^.TagValue:=0;
 fTail^.PointerValue:=Node;
 fTail^.TagValue:=0;
 InitializeItem(@Node^.Data);
end;
{$else}
var CurrentNode,NextNode:PPasMPThreadSafeQueueNode;
begin
 CurrentNode:=fHead;
 while assigned(CurrentNode) do begin
  NextNode:=CurrentNode^.Next;
  FinalizeItem(@CurrentNode^.Data);
  if fAddCPUCacheLinePaddingToInternalItemDataStructure then begin
   TPasMPMemory.FreeAlignedMemory(CurrentNode);
  end else begin
   FreeMem(CurrentNode);
  end;
  CurrentNode:=NextNode;
 end;
 fHead:=nil;
 if fAddCPUCacheLinePaddingToInternalItemDataStructure then begin
  TPasMPMemory.AllocateAlignedMemory(fHead,fInternalNodeSize,PasMPCPUCacheLineSize);
 end else begin
  GetMem(fHead,fInternalNodeSize);
 end;
 fHead^.Next:=nil;
 fTail:=fHead;
 InitializeItem(@fHead^.Data);
end;
{$endif}

function TPasMPThreadSafeQueue.IsEmpty:boolean;
{$ifdef PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}
begin
 result:=fHead^.PointerValue=fTail^.PointerValue;
end;
{$else}
begin
 result:=fHead=fTail;
end;
{$endif}

procedure TPasMPThreadSafeQueue.Enqueue(const Item);
{$ifdef PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}
{$ifdef PASMP_USE_OPTIMISTIC_FIFO_QUEUE}
// Based on http://people.csail.mit.edu/edya/publications/OptimisticFIFOQueue-journal.pdf
var Node:PPasMPThreadSafeQueueNode;
    Tail,OldTail,NewTail:TPasMPTaggedPointer;
begin
 if fAddCPUCacheLinePaddingToInternalItemDataStructure then begin
  TPasMPMemory.AllocateAlignedMemory(Node,fInternalNodeSize,PasMPCPUCacheLineSize);
 end else begin
  TPasMPMemory.AllocateAlignedMemory(Node,fInternalNodeSize,PasMPDoubleNativeMachineWordAtomicCompareExchangeAlignment);
 end;
 Node^.Previous.PointerValue:=nil;
 Node^.Previous.TagValue:=0;
 InitializeItem(@Node^.Data);
 CopyItem(@Item,@Node^.Data);
 OldTail.Value:=fTail^.Value;
 repeat
  Tail:=OldTail;
  Node^.Next.PointerValue:=Tail.PointerValue;
  Node^.Next.TagValue:=Tail.TagValue+1;
  NewTail.PointerValue:=Node;
  NewTail.TagValue:=Tail.TagValue+1;
  OldTail.Value:=TPasMPInterlocked.CompareExchange(fTail^.Value,NewTail.Value,Tail.Value);
 until {$ifdef CPU64}(OldTail.PointerValue=Tail.PointerValue) and (OldTail.TagValue=Tail.TagValue){$else}OldTail.Value.Value=Tail.Value.Value{$endif};
 NewTail.PointerValue:=Node;
 NewTail.TagValue:=Tail.TagValue;
 PPasMPThreadSafeQueueNode(Tail.PointerValue)^.Previous.Value:=NewTail.Value;
end;
{$else}
var Node:PPasMPThreadSafeQueueNode;
    Tail,Next,CheckTail,Temporary,OldNext:TPasMPTaggedPointer;
begin
 if fAddCPUCacheLinePaddingToInternalItemDataStructure then begin
  TPasMPMemory.AllocateAlignedMemory(Node,fInternalNodeSize,PasMPCPUCacheLineSize);
 end else begin
  TPasMPMemory.AllocateAlignedMemory(Node,fInternalNodeSize,PasMPDoubleNativeMachineWordAtomicCompareExchangeAlignment);
 end;
 Node^.Previous.PointerValue:=nil;
 Node^.Previous.TagValue:=0;
 Node^.Next.PointerValue:=nil;
 Node^.Next.TagValue:=0;
 InitializeItem(@Node^.Data);
 CopyItem(@Item,@Node^.Data);
 repeat
  Tail.Value:=fTail^.Value;
  TPasMPMemoryBarrier.Read;
	Next.Value:=PPasMPThreadSafeQueueNode(Tail.PointerValue)^.Next.Value;
  TPasMPMemoryBarrier.Read;
  CheckTail.Value:=fTail^.Value;
  if {$ifdef CPU64}(Tail.TagValue=CheckTail.TagValue) and (Tail.PointerValue=CheckTail.PointerValue){$else}Tail.Value.Value=CheckTail.Value.Value{$endif} then begin
	 if assigned(Next.PointerValue) then begin
    Temporary.PointerValue:=Next.PointerValue;
    Temporary.TagValue:=Tail.TagValue+1;
    TPasMPInterlocked.CompareExchange(fTail^.Value,Temporary.Value,Tail.Value);
   end else begin
    Temporary.PointerValue:=Node;
    Temporary.TagValue:=Next.TagValue+1;
    OldNext.Value:=TPasMPInterlocked.CompareExchange(PPasMPThreadSafeQueueNode(Tail^.PointerValue)^.Next.Value,Temporary.Value,Next.Value);
    if {$ifdef CPU64}(OldNext.PointerValue=Next.PointerValue) and (OldNext.TagValue=Next.TagValue){$else}OldNext.Value.Value=Next.Value.Value{$endif} then begin
     Temporary.PointerValue:=Node;
     Temporary.TagValue:=Tail.TagValue+1;
     TPasMPInterlocked.CompareExchange(fTail^.Value,Temporary.Value,Tail.Value);
     break;
    end;
   end;
  end;
 until false;
end;
{$endif}
{$else}
var Node:PPasMPThreadSafeQueueNode;
begin
 if fAddCPUCacheLinePaddingToInternalItemDataStructure then begin
  TPasMPMemory.AllocateAlignedMemory(Node,fInternalNodeSize,PasMPCPUCacheLineSize);
 end else begin
  GetMem(Node,fInternalNodeSize);
 end;
 Node^.Next:=nil;
 InitializeItem(@Node^.Data);
 CopyItem(@Item,@Node^.Data);
 fTailCriticalSection.Acquire;
 try
  fTail^.Next:=Node;
  fTail:=Node;
 finally
  fTailCriticalSection.Release;
 end;
end;
{$endif}

function TPasMPThreadSafeQueue.Dequeue(out Item):boolean;
{$ifdef PASMP_HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}
{$ifdef PASMP_USE_OPTIMISTIC_FIFO_QUEUE}
// Based on http://people.csail.mit.edu/edya/publications/OptimisticFIFOQueue-journal.pdf
var Tail,Head,CheckHead,FirstNodePrevious,NewHead,OldHead,CurrentNode,NextNode,NewNode:TPasMPTaggedPointer;
begin
 result:=false;
 repeat
  Head.Value:=fHead^.Value;
  Tail.Value:=fTail^.Value;
  TPasMPMemoryBarrier.Read;
  FirstNodePrevious.Value:=PPasMPThreadSafeQueueNode(Head.PointerValue)^.Previous.Value;
  TPasMPMemoryBarrier.Read;
  CheckHead.Value:=fHead^.Value;
  if {$ifdef cpu64}(Head.PointerValue=CheckHead.PointerValue) and (Head.TagValue=CheckHead.TagValue){$else}Head.Value.Value=CheckHead.Value.Value{$endif} then begin
   if {$ifdef cpu64}(Head.PointerValue<>Tail.PointerValue) or (Head.TagValue<>Tail.TagValue){$else}Head.Value.Value<>Tail.Value.Value{$endif} then begin
    // Not in the original paper, but there is a race condition where push adds a node, but leaves Node^.Next^.Previous uninitialized for a short time.
    // This only manifests too when FirstNodePrevious.TagValue = Head.TagValue, which is also very rare. If they aren't equal, FixList fixes the issue
		// (or at least it takes long enough, so that things settle). So here ensure time is not wasted getting to the end-game only to try to dereference
    // nil.
    if assigned(FirstNodePrevious.PointerValue) then begin
     if FirstNodePrevious.TagValue<>Head.TagValue then begin
      // Fix list
      CurrentNode:=Tail;
      repeat
       CheckHead.Value:=fHead^.Value;
{$ifdef cpu64}
       if ((Head.PointerValue=CheckHead.PointerValue) and (Head.TagValue=CheckHead.TagValue)) and
          ((CurrentNode.PointerValue<>Head.PointerValue) or (CurrentNode.TagValue<>Head.TagValue)) then begin
{$else}
       if (Head.Value.Value=CheckHead.Value.Value) and (CurrentNode.Value.Value<>Head.Value.Value) then begin
{$endif}
        NextNode.Value:=PPasMPThreadSafeQueueNode(CurrentNode.PointerValue)^.Next.Value;
        NewNode.PointerValue:=CurrentNode.PointerValue;
        NewNode.TagValue:=CurrentNode.TagValue-1;
        PPasMPThreadSafeQueueNode(NextNode.PointerValue)^.Previous.Value:=NewNode.Value;
        NewNode.PointerValue:=NextNode.PointerValue;
        NewNode.TagValue:=CurrentNode.TagValue-1;
        CurrentNode.Value:=NewNode.Value;
       end else begin
        break;
       end;
      until false;
     end else begin
      NewHead.PointerValue:=FirstNodePrevious.PointerValue;
      NewHead.TagValue:=Head.TagValue+1;
      OldHead.Value:=TPasMPInterlocked.CompareExchange(fHead^.Value,NewHead.Value,Head.Value);
      if {$ifdef CPU64}(OldHead.PointerValue=Head.PointerValue) and (OldHead.TagValue=Head.TagValue){$else}OldHead.Value.Value=Head.Value.Value{$endif} then begin
       CopyItem(@PPasMPThreadSafeQueueNode(FirstNodePrevious.PointerValue)^.Data,@Item);
       FinalizeItem(@PPasMPThreadSafeQueueNode(FirstNodePrevious.PointerValue)^.Data);
       TPasMPMemory.FreeAlignedMemory(Head.PointerValue);
       result:=true;
       exit;
      end;
     end;
    end;
   end else begin
    break;
   end;
  end;
 until false;
end;
{$else}
var Head,Tail,Next,CheckHead,OldHead,Temporary:TPasMPTaggedPointer;
begin
 result:=false;
 repeat
  Head.Value:=fHead^.Value;
  Tail.Value:=fTail^.Value;
  TPasMPMemoryBarrier.Read;
	Next.Value:=PPasMPThreadSafeQueueNode(Head.PointerValue)^.Next.Value;
  TPasMPMemoryBarrier.Read;
  CheckHead.Value:=fHead^.Value;
  if {$ifdef cpu64}(Head.PointerValue=CheckHead.PointerValue) and (Head.TagValue=CheckHead.TagValue){$else}Head.Value.Value=CheckHead.Value.Value{$endif} then begin
	 if Head.PointerValue=Tail.PointerValue then begin
    if assigned(Next.PointerValue) then begin
     Temporary.PointerValue:=Next.PointerValue;
     Temporary.TagValue:=Head.TagValue+1;
     TPasMPInterlocked.CompareExchange(fTail^.Value,Temporary.Value,Tail.Value);
    end else begin
     break;
    end;
   end else begin
    Temporary.PointerValue:=Next.PointerValue;
    Temporary.TagValue:=Head.TagValue+1;
    OldHead.Value:=TPasMPInterlocked.CompareExchange(fHead^.Value,Temporary.Value,Head.Value);
    if {$ifdef CPU64}(OldHead.PointerValue=Head.PointerValue) and (OldHead.TagValue=Head.TagValue){$else}OldHead.Value.Value=Head.Value.Value{$endif} then begin
     CopyItem(@PPasMPThreadSafeQueueNode(Next.PointerValue)^.Data,@Item);
     FinalizeItem(@PPasMPThreadSafeQueueNode(Next.PointerValue)^.Data);
     TPasMPMemory.FreeAlignedMemory(Head.PointerValue);
     result:=true;
     exit;
    end;
   end;
  end;
 until false;
end;
{$endif}
{$else}
var Node,NewHead:PPasMPThreadSafeQueueNode;
begin
 result:=false;
 if assigned(fHead) and (fHead<>fTail) then begin
  fHeadCriticalSection.Acquire;
  try
   Node:=fHead;
   NewHead:=fHead^.Next;
   if assigned(NewHead) then begin
    CopyItem(@NewHead^.Data,@Item);
    FinalizeItem(@NewHead^.Data);
    fHead:=NewHead;
    if fAddCPUCacheLinePaddingToInternalItemDataStructure then begin
     TPasMPMemory.FreeAlignedMemory(Node);
    end else begin
     FreeMem(Node);
    end;
    result:=true;
   end;
  finally
   fHeadCriticalSection.Release;
  end;
 end;
end;
{$endif}

constructor TPasMPThreadSafeBoundedArrayBasedQueue.Create(const MaximalCount,ItemSize:TPasMPUInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
var i:TPasMPUInt32;
    p:PPasMPUInt8;
    QueueItemNode:PPasMPThreadSafeBoundedArrayBasedQueueItemNode;
begin
 inherited Create;
 fMaximalCount:=TPasMPMath.RoundUpToPowerOfTwo(MaximalCount);
 if fMaximalCount<>MaximalCount then begin
  raise EPasMPThreadSafeBoundedArrayBasedQueue.Create('Maximum count must be power of two');
 end;
 fMask:=fMaximalCount-1;
 fItemSize:=ItemSize;
 fInternalItemSize:=SizeOf(TPasMPThreadSafeBoundedArrayBasedQueueItemNode)+fItemSize;
 if AddCPUCacheLinePaddingToInternalItemDataStructure then begin
  fInternalItemSize:=TPasMPMath.RoundUpToMask32(fInternalItemSize,PasMPCPUCacheLineSize);
 end else begin
  fInternalItemSize:=TPasMPMath.RoundUpToMask32(fInternalItemSize,SizeOf(TPasMPPtrUInt));
 end;
 fHeadSequence:=0;
 fTailSequence:=0;
 TPasMPMemoryBarrier.ReadWrite;
 TPasMPMemory.AllocateAlignedMemory(fData,fInternalItemSize*fMaximalCount,PasMPCPUCacheLineSize);
 p:=fData;
 for i:=1 to fMaximalCount do begin
  QueueItemNode:=pointer(p);
  QueueItemNode^.Sequence:=i-1;
  InitializeItem(@QueueItemNode^.Data);
  inc(p,fInternalItemSize);
 end;
 TPasMPMemoryBarrier.ReadWrite;
end;

destructor TPasMPThreadSafeBoundedArrayBasedQueue.Destroy;
var i:TPasMPUInt32;
    p:PPasMPUInt8;
    QueueItemNode:PPasMPThreadSafeBoundedArrayBasedQueueItemNode;
begin
 p:=fData;
 for i:=1 to fMaximalCount do begin
  QueueItemNode:=pointer(p);
  FinalizeItem(@QueueItemNode^.Data);
  inc(p,fInternalItemSize);
 end;
 TPasMPMemory.FreeAlignedMemory(fData);
 inherited Destroy;
end;

procedure TPasMPThreadSafeBoundedArrayBasedQueue.InitializeItem(const Data:pointer);
begin
end;

procedure TPasMPThreadSafeBoundedArrayBasedQueue.FinalizeItem(const Data:pointer);
begin
end;

procedure TPasMPThreadSafeBoundedArrayBasedQueue.CopyItem(const Source,Destination:pointer);
begin
 Move(Source^,Destination^,fItemSize);
end;

procedure TPasMPThreadSafeBoundedArrayBasedQueue.Clear;
var Item:pointer;
begin
 GetMem(Item,fItemSize);
 try
  InitializeItem(Item);
  while Dequeue(Item^) do begin
   FinalizeItem(Item);
  end;
 finally
  FreeMem(Item);
 end;
end;

function TPasMPThreadSafeBoundedArrayBasedQueue.IsEmpty:boolean;
var LocalTailSequence,QueueItemNodeSequence:TPasMPUInt32;
    QueueItemNode:PPasMPThreadSafeBoundedArrayBasedQueueItemNode;
begin
{$if not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.ReadWrite;
{$ifend}
 LocalTailSequence:=fTailSequence;
 QueueItemNode:={%H-}pointer(TPasMPPtrUInt(TPasMPPtrUInt(pointer(fData))+TPasMPPtrUInt(TPasMPPtrUInt(LocalTailSequence and fMask)*TPasMPPtrUInt(fInternalItemSize))));
{$if defined(CPU386) or defined(CPUx86_64)}
 TPasMPMemoryBarrier.ReadDependency;
{$else}
 TPasMPMemoryBarrier.Read;
{$ifend}
 QueueItemNodeSequence:=QueueItemNode^.Sequence;
 result:=TPasMPInt32(QueueItemNodeSequence-(LocalTailSequence+1))<0;
end;

function TPasMPThreadSafeBoundedArrayBasedQueue.IsFull:boolean;
var LocalHeadSequence,QueueItemNodeSequence:TPasMPUInt32;
    QueueItemNode:PPasMPThreadSafeBoundedArrayBasedQueueItemNode;
begin
{$if not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.ReadWrite;
{$ifend}
 LocalHeadSequence:=fHeadSequence;
 QueueItemNode:={%H-}pointer(TPasMPPtrUInt(TPasMPPtrUInt(pointer(fData))+TPasMPPtrUInt(TPasMPPtrUInt(LocalHeadSequence and fMask)*TPasMPPtrUInt(fInternalItemSize))));
{$if defined(CPU386) or defined(CPUx86_64)}
 TPasMPMemoryBarrier.ReadDependency;
{$else}
 TPasMPMemoryBarrier.Read;
{$ifend}
 QueueItemNodeSequence:=QueueItemNode^.Sequence;
 result:=TPasMPInt32(QueueItemNodeSequence-LocalHeadSequence)<0;
end;

function TPasMPThreadSafeBoundedArrayBasedQueue.Enqueue(const Item):boolean;
var LocalHeadSequence,QueueItemNodeSequence:TPasMPUInt32;
    QueueItemNode:PPasMPThreadSafeBoundedArrayBasedQueueItemNode;
begin
{$if not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.Read;
{$ifend}
 LocalHeadSequence:=fHeadSequence;
 repeat
  QueueItemNode:={%H-}pointer(TPasMPPtrUInt(TPasMPPtrUInt(pointer(fData))+TPasMPPtrUInt(TPasMPPtrUInt(LocalHeadSequence and fMask)*TPasMPPtrUInt(fInternalItemSize))));
{$if defined(CPU386) or defined(CPUx86_64)}
  TPasMPMemoryBarrier.ReadDependency;
{$else}
  TPasMPMemoryBarrier.Read;
{$ifend}
  QueueItemNodeSequence:=QueueItemNode^.Sequence;
  case TPasMPInt32(QueueItemNodeSequence-LocalHeadSequence) of
   0:begin
    if TPasMPInterlocked.CompareExchange(fHeadSequence,
                                         LocalHeadSequence+1,
                                         LocalHeadSequence)=LocalHeadSequence then begin
     break;
    end;
   end;
   Low(TPasMPInt32)..-1:begin
    result:=false;
    exit;
   end;
   else begin
{$if defined(CPU386) or defined(CPUx86_64)}
    TPasMPMemoryBarrier.ReadDependency;
{$else}
    TPasMPMemoryBarrier.Read;
{$ifend}
    LocalHeadSequence:=fHeadSequence;
   end;
  end;
 until false;
 InitializeItem(@QueueItemNode^.Data);
 CopyItem(@Item,@QueueItemNode^.Data);
{$if defined(CPU386)}
 asm
  mfence;
 end;
{$elseif not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.ReadWrite;
{$ifend}
 QueueItemNode^.Sequence:=LocalHeadSequence+1;
{$if not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.Write;
{$ifend}
 result:=true;
end;

function TPasMPThreadSafeBoundedArrayBasedQueue.Dequeue(out Item):boolean;
var LocalTailSequence,QueueItemNodeSequence:TPasMPUInt32;
    QueueItemNode:PPasMPThreadSafeBoundedArrayBasedQueueItemNode;
begin
{$if not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.Read;
{$ifend}
 LocalTailSequence:=fTailSequence;
 repeat
  QueueItemNode:={%H-}pointer(TPasMPPtrUInt(TPasMPPtrUInt(pointer(fData))+TPasMPPtrUInt(TPasMPPtrUInt(LocalTailSequence and fMask)*TPasMPPtrUInt(fInternalItemSize))));
{$if defined(CPU386) or defined(CPUx86_64)}
  TPasMPMemoryBarrier.ReadDependency;
{$else}
  TPasMPMemoryBarrier.Read;
{$ifend}
  QueueItemNodeSequence:=QueueItemNode^.Sequence;
  case TPasMPInt32(QueueItemNodeSequence-(LocalTailSequence+1)) of
   0:begin
    if TPasMPInterlocked.CompareExchange(fTailSequence,
                                         LocalTailSequence+1,
                                         LocalTailSequence)=LocalTailSequence then begin
     break;
    end;
   end;
   Low(TPasMPInt32)..-1:begin
    result:=false;
    exit;
   end;
   else begin
{$if defined(CPU386) or defined(CPUx86_64)}
    TPasMPMemoryBarrier.ReadDependency;
{$else}
    TPasMPMemoryBarrier.Read;
{$ifend}
    LocalTailSequence:=fTailSequence;
   end;
  end;
 until false;
 CopyItem(@QueueItemNode^.Data,@Item);
 FinalizeItem(@QueueItemNode^.Data);
{$if defined(CPU386)}
 asm
  mfence;
 end;
{$elseif not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.ReadWrite;
{$ifend}
 QueueItemNode^.Sequence:=LocalTailSequence+fMask+1;
{$if not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.Write;
{$ifend}
 result:=true;
end;

const PasMPThreadSafeHashTableItemStateDeleted=-1;
      PasMPThreadSafeHashTableItemStateEmpty=0;
      PasMPThreadSafeHashTableItemStateUsed=1;

constructor TPasMPThreadSafeHashTable.Create(const ItemSize:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
begin
 inherited Create;
 fCriticalSection:=TPasMPCriticalSection.Create;
 fLock:=TPasMPMultipleReaderSingleWriterSpinLock.Create;
 fResizeLock:=TPasMPMultipleReaderSingleWriterSpinLock.Create;
 fItemSize:=ItemSize;
 fInternalItemSize:=SizeOf(TPasMPThreadSafeHashTableItem)+fItemSize;
 if AddCPUCacheLinePaddingToInternalItemDataStructure then begin
  fInternalItemSize:=TPasMPMath.RoundUpToMask32(fInternalItemSize,PasMPCPUCacheLineSize);
 end else begin
  fInternalItemSize:=TPasMPMath.RoundUpToMask32(fInternalItemSize,PasMPDoubleNativeMachineWordAtomicCompareExchangeAlignment);
 end;
 fGrowLoadFactor:=((75 shl 7)+128) div 100; // 0.75
 TPasMPMemory.AllocateAlignedMemory(fFirstState,SizeOf(TPasMPThreadSafeHashTableState),PasMPCPUCacheLineSize);
 FillChar(fFirstState^,SizeOf(TPasMPThreadSafeHashTableState),#0);
 Initialize(fFirstState^);
 fFirstState^.Previous:=nil;
 fFirstState^.Next:=nil;
 fFirstState^.ReferenceCounter:=1;
 fFirstState^.Version:=0;
 fFirstState^.Size:=TPasMPMath.RoundUpToPowerOfTwo(Max(16,4096 div fInternalItemSize));
 fFirstState^.Mask:=fFirstState^.Size-1;
 if fFirstState^.LogSize=0 then begin
  fFirstState^.LogSize:=0;
 end else begin
  fFirstState^.LogSize:=TPasMPMath.BitScanReverse32(fFirstState^.Size);
 end;
 fFirstState^.Count:=0;
 TPasMPMemory.AllocateAlignedMemory(fFirstState^.Items,fFirstState^.Size*fInternalItemSize,PasMPCPUCacheLineSize);
 FillChar(fFirstState^.Items^,fFirstState^.Size*fInternalItemSize,#0);
 fLastState:=fFirstState;
 fVersion:=fFirstState^.Version;
end;

destructor TPasMPThreadSafeHashTable.Destroy;
begin
 while assigned(fFirstState) do begin
  FreeState(fFirstState);
 end;
 fCriticalSection.Free;
 fLock.Free;
 fResizeLock.Free;
 inherited Destroy;
end;

function TPasMPThreadSafeHashTable.GetGrowLoadFactor:single;
begin
 result:=fGrowLoadFactor/128.0;
end;

procedure TPasMPThreadSafeHashTable.SetGrowLoadFactor(const NewGrowLoadFactor:single);
begin
 fGrowLoadFactor:=Min(Max(round(fGrowLoadFactor*128.0),0),128);
end;

function TPasMPThreadSafeHashTable.CreateState:PPasMPThreadSafeHashTableState;
begin
 TPasMPMemory.AllocateAlignedMemory(result,SizeOf(TPasMPThreadSafeHashTableState),PasMPCPUCacheLineSize);
 FillChar(result^,SizeOf(TPasMPThreadSafeHashTableState),#0);
 Initialize(result^);
 result^.Previous:=nil;
 result^.Next:=nil;
 result^.ReferenceCounter:=1;
end;

procedure TPasMPThreadSafeHashTable.FreeState(const State:PPasMPThreadSafeHashTableState);
var Index:TPasMPInt32;
    Item:PPasMPThreadSafeHashTableItem;
begin
 fLock.AcquireWrite;
 try
  if assigned(State^.Previous) then begin
   State^.Previous^.Next:=State^.Next;
  end else if fFirstState=State then begin
   fFirstState:=State^.Next;
  end;
  if assigned(State^.Next) then begin
   State^.Next^.Previous:=State^.Previous;
  end else if fLastState=State then begin
   fLastState:=State^.Previous;
  end;
  Item:=State^.Items;
  for Index:=0 to State^.Size-1 do begin
   FinalizeItem(@Item^.Data);
   Finalize(Item^);
   inc(TPasMPPtrUInt(Item),fInternalItemSize);
  end;
  TPasMPMemory.FreeAlignedMemory(State^.Items);
  Finalize(State^);
  TPasMPMemory.FreeAlignedMemory(State);
 finally
  fLock.ReleaseWrite;
 end;
end;

function TPasMPThreadSafeHashTable.AcquireState:PPasMPThreadSafeHashTableState;
begin
 result:=fLastState;
 TPasMPInterlocked.Increment(result^.ReferenceCounter);
end;

procedure TPasMPThreadSafeHashTable.ReleaseState(const State:PPasMPThreadSafeHashTableState);
begin
 if TPasMPInterlocked.Decrement(State^.ReferenceCounter)=0 then begin
  FreeState(State);
 end;
end;

procedure TPasMPThreadSafeHashTable.InitializeItem(const Data:pointer);
begin
end;

procedure TPasMPThreadSafeHashTable.FinalizeItem(const Data:pointer);
begin
end;

procedure TPasMPThreadSafeHashTable.CopyItem(const Source,Destination:pointer);
begin
end;

procedure TPasMPThreadSafeHashTable.GetKey(const Data,Key:pointer);
begin
end;

procedure TPasMPThreadSafeHashTable.SetKey(const Data,Key:pointer);
begin
end;

procedure TPasMPThreadSafeHashTable.GetValue(const Data,Value:pointer);
begin
end;

procedure TPasMPThreadSafeHashTable.SetValue(const Data,Value:pointer);
begin
end;

function TPasMPThreadSafeHashTable.HashKey(const Key:pointer):TPasMPThreadSafeHashTableHash;
begin
 result:=0;
end;

function TPasMPThreadSafeHashTable.CompareKey(const Data,Key:pointer):boolean;
begin
 result:=false;
end;

procedure TPasMPThreadSafeHashTable.Clear;
begin
end;

function TPasMPThreadSafeHashTable.GetKeyValue(const Key,Value:pointer):boolean;
var CurrentState:PPasMPThreadSafeHashTableState;
    Hash:TPasMPThreadSafeHashTableHash;
    StartIndex,Index,Step:TPasMPInt32;
    Item:PPasMPThreadSafeHashTableItem;
begin
 result:=false;
 CurrentState:=AcquireState;
 try
  Hash:=HashKey(Key);
  StartIndex:=(Hash shr (32-CurrentState^.LogSize)) and CurrentState^.Mask;
  Step:=((Hash shl 1) or 1) and CurrentState^.Mask;
  Index:=StartIndex;
  repeat
   Item:=pointer(TPasMPPtrUInt(TPasMPPtrUInt(CurrentState^.Items)+TPasMPPtrUInt(TPasMPPtrUInt(Index)*TPasMPPtrUInt(fInternalItemSize))));
   case Item^.State of
    PasMPThreadSafeHashTableItemStateDeleted:begin
     // Found deleted item slot => ignore it
    end;
    PasMPThreadSafeHashTableItemStateEmpty:begin
     // Found empty item slot => abort search
     break;
    end;
    PasMPThreadSafeHashTableItemStateUsed:begin
     // Found used item slot => try to read it
     if Item^.Hash=Hash then begin
      TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(Item^.Lock);
      try
       if (Item^.State=PasMPThreadSafeHashTableItemStateUsed) and (Item^.Hash=Hash) and CompareKey(@Item^.Data,Key) then begin
        GetValue(@Item^.Data,Value);
        result:=true;
       end;
      finally
       TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(Item^.Lock);
      end;
      if result then begin
       break;
      end;
     end;
    end;
   end;
   Index:=(Index+Step) and CurrentState^.Mask;
  until Index=StartIndex;
 finally
  ReleaseState(CurrentState);
 end;
end;

function TPasMPThreadSafeHashTable.SetKeyValueOnState(const CurrentState:PPasMPThreadSafeHashTableState;const Key,Value:pointer):boolean;
var Hash:TPasMPThreadSafeHashTableHash;
    StartIndex,Index,Step,FoundDeletedItemSlotIndex:TPasMPInt32;
    Item:PPasMPThreadSafeHashTableItem;
begin
 result:=false;

 Hash:=HashKey(Key);

 StartIndex:=(Hash shr (32-CurrentState^.LogSize)) and CurrentState^.Mask;
 Step:=((Hash shl 1) or 1) and CurrentState^.Mask;

 FoundDeletedItemSlotIndex:=-1;

 // First try to set a existent or empty slot item
 Index:=StartIndex;
 repeat
  Item:=pointer(TPasMPPtrUInt(TPasMPPtrUInt(CurrentState^.Items)+TPasMPPtrUInt(TPasMPPtrUInt(Index)*TPasMPPtrUInt(fInternalItemSize))));
  case Item^.State of
   PasMPThreadSafeHashTableItemStateDeleted:begin
    // Found deleted item slot => remember it for the next try iteration
    FoundDeletedItemSlotIndex:=Index;
   end;
   PasMPThreadSafeHashTableItemStateEmpty:begin
    // Found empty item slot => try to use it
    TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(Item^.Lock);
    try
     if Item^.State=PasMPThreadSafeHashTableItemStateEmpty then begin
      TPasMPMultipleReaderSingleWriterSpinLock.ReadToWrite(Item^.Lock);
      try
       Item^.Hash:=Hash;
       InitializeItem(@Item^.Data);
       SetKey(@Item^.Data,Key);
       SetValue(@Item^.Data,Value);
       TPasMPInterlocked.Write(Item^.State,PasMPThreadSafeHashTableItemStateUsed);
       TPasMPInterlocked.Increment(CurrentState^.Count);
       result:=true;
      finally
       TPasMPMultipleReaderSingleWriterSpinLock.WriteToRead(Item^.Lock);
      end;
     end;
    finally
     TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(Item^.Lock);
    end;
    if result then begin
     exit;
    end;
   end;
   PasMPThreadSafeHashTableItemStateUsed:begin
    // Found used item slot => try to overwrite it
    if Item^.Hash=Hash then begin
     TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(Item^.Lock);
     try
      if (Item^.State=PasMPThreadSafeHashTableItemStateUsed) and (Item^.Hash=Hash) and CompareKey(@Item^.Data,Key) then begin
       TPasMPMultipleReaderSingleWriterSpinLock.ReadToWrite(Item^.Lock);
       try
        SetValue(@Item^.Data,Value);
       finally
        TPasMPMultipleReaderSingleWriterSpinLock.WriteToRead(Item^.Lock);
       end;
       result:=true;
      end;
     finally
      TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(Item^.Lock);
     end;
     if result then begin
      exit;
     end;
    end;
   end;
  end;
  Index:=(Index+Step) and CurrentState^.Mask;
 until Index=StartIndex;

 // Otherwise try to set the last found deleted slot item
 if FoundDeletedItemSlotIndex>=0 then begin
  Index:=FoundDeletedItemSlotIndex;
  Item:=pointer(TPasMPPtrUInt(TPasMPPtrUInt(CurrentState^.Items)+TPasMPPtrUInt(TPasMPPtrUInt(Index)*TPasMPPtrUInt(fInternalItemSize))));
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(Item^.Lock);
  try
   if Item^.State=PasMPThreadSafeHashTableItemStateDeleted then begin
    TPasMPMultipleReaderSingleWriterSpinLock.ReadToWrite(Item^.Lock);
    try
     InitializeItem(@Item^.Data);
     Item^.Hash:=Hash;
     SetKey(@Item^.Data,Key);
     SetValue(@Item^.Data,Value);
     TPasMPInterlocked.Write(Item^.State,PasMPThreadSafeHashTableItemStateUsed);
     TPasMPInterlocked.Increment(CurrentState^.Count);
     result:=true;
    finally
     TPasMPMultipleReaderSingleWriterSpinLock.WriteToRead(Item^.Lock);
    end;
   end;
  finally
   TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(Item^.Lock);
  end;
  if result then begin
   exit;
  end;
 end;

 // Otherwise try to find and set a deleted slot item
 Index:=StartIndex;
 repeat
  Item:=pointer(TPasMPPtrUInt(TPasMPPtrUInt(CurrentState^.Items)+TPasMPPtrUInt(TPasMPPtrUInt(Index)*TPasMPPtrUInt(fInternalItemSize))));
  case Item^.State of
   PasMPThreadSafeHashTableItemStateDeleted:begin
    TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(Item^.Lock);
    try
     if Item^.State=PasMPThreadSafeHashTableItemStateDeleted then begin
      TPasMPMultipleReaderSingleWriterSpinLock.ReadToWrite(Item^.Lock);
      try
       Item^.Hash:=Hash;
       InitializeItem(@Item^.Data);
       SetKey(@Item^.Data,Key);
       SetValue(@Item^.Data,Value);
       TPasMPInterlocked.Write(Item^.State,PasMPThreadSafeHashTableItemStateUsed);
       TPasMPInterlocked.Increment(CurrentState^.Count);
       result:=true;
      finally
       TPasMPMultipleReaderSingleWriterSpinLock.WriteToRead(Item^.Lock);
      end;
     end;
    finally
     TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(Item^.Lock);
    end;
    if result then begin
     exit;
    end;
   end;
  end;
  Index:=(Index+Step) and CurrentState^.Mask;
 until Index=StartIndex;

 result:=false;

end;

function TPasMPThreadSafeHashTable.UnderGrowLoadFactor(const CurrentState:PPasMPThreadSafeHashTableState):boolean;
begin
 if CurrentState^.Count<CurrentState^.Size then begin
  if CurrentState^.Count<=$7fffff then begin
   result:=CurrentState^.Count<((CurrentState^.Size*fGrowLoadFactor) shr 7);
  end else begin
   result:=CurrentState^.Count<((TPasMPInt64(CurrentState^.Size)*fGrowLoadFactor) shr 7);
  end;
 end else begin
  result:=false;
 end;
end;

procedure TPasMPThreadSafeHashTable.Grow;
var CurrentState,NewState,OldLastState:PPasMPThreadSafeHashTableState;
    StartIndex,Index,Step,OtherIndex:TPasMPInt32;
    Item,OtherItem:PPasMPThreadSafeHashTableItem;
begin
 CurrentState:=fLastState;

 fResizeLock.AcquireWrite;
 try

  {if not UnderGrowLoadFactor(CurrentState) then} begin

   TPasMPInterlocked.Write(fVersion,CurrentState^.Version+1);

   fLock.AcquireWrite;
   try

    NewState:=CreateState;
    NewState^.Version:=fVersion;
    NewState^.Size:=CurrentState^.Size shl 1;
    NewState^.Mask:=NewState^.Size-1;
    NewState^.LogSize:=CurrentState^.LogSize+1;
    NewState^.Count:=CurrentState^.Count;

    TPasMPMemory.AllocateAlignedMemory(NewState^.Items,NewState^.Size*fInternalItemSize,PasMPCPUCacheLineSize);
    FillChar(NewState^.Items^,NewState^.Size*fInternalItemSize,#0);

    OtherIndex:=0;
    while OtherIndex<CurrentState^.Size do begin

     OtherItem:=pointer(TPasMPPtrUInt(TPasMPPtrUInt(CurrentState^.Items)+TPasMPPtrUInt(TPasMPPtrUInt(OtherIndex)*TPasMPPtrUInt(fInternalItemSize))));

     if OtherItem^.State=PasMPThreadSafeHashTableItemStateUsed then begin

      TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(OtherItem^.Lock);
      try

       if OtherItem^.State=PasMPThreadSafeHashTableItemStateUsed then begin

        StartIndex:=(OtherItem^.Hash shr (32-NewState^.LogSize)) and NewState^.Mask;
        Step:=((OtherItem^.Hash shl 1) or 1) and NewState^.Mask;

        Index:=StartIndex;

        repeat

         Item:=pointer(TPasMPPtrUInt(TPasMPPtrUInt(NewState^.Items)+TPasMPPtrUInt(TPasMPPtrUInt(Index)*TPasMPPtrUInt(fInternalItemSize))));

         if Item^.State=PasMPThreadSafeHashTableItemStateEmpty then begin
          Item^.Hash:=OtherItem^.Hash;
          InitializeItem(@Item^.Data);
          CopyItem(@OtherItem^.Data,@Item^.Data);
          Item^.State:=PasMPThreadSafeHashTableItemStateUsed;
          break;
         end;

         Index:=(Index+Step) and NewState^.Mask;

        until Index=StartIndex;

       end;

      finally
       TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(OtherItem^.Lock);
      end;

     end;

     inc(OtherIndex);

    end;

    OldLastState:=fLastState;
    if assigned(OldLastState) then begin
     OldLastState^.Next:=NewState;
     NewState^.Previous:=OldLastState;
    end else begin
     NewState^.Previous:=nil;
     OldLastState:=NewState;
    end;
    NewState^.Next:=nil;
    TPasMPInterlocked.Write(pointer(fLastState),pointer(NewState));

    TPasMPInterlocked.Decrement(CurrentState^.ReferenceCounter);

   finally
    fLock.ReleaseWrite;
   end;

  end;

 finally
  fResizeLock.ReleaseWrite;
 end;

end;

function TPasMPThreadSafeHashTable.SetKeyValue(const Key,Value:pointer):boolean;
var CurrentState:PPasMPThreadSafeHashTableState;
    Version:TPasMPInt32;
begin
 repeat
  result:=false;
  CurrentState:=AcquireState;
  try
   Version:=CurrentState^.Version;
   if UnderGrowLoadFactor(CurrentState) and SetKeyValueOnState(CurrentState,Key,Value) then begin
    result:=true;
   end else begin
    Grow;
   end;
  finally
   ReleaseState(CurrentState);
  end;
 until result and (Version=fVersion);
end;

function TPasMPThreadSafeHashTable.DeleteKey(const Key:pointer):boolean;
var CurrentState:PPasMPThreadSafeHashTableState;
    Hash:TPasMPThreadSafeHashTableHash;
    StartIndex,Index,Step,Version:TPasMPInt32;
    Item:PPasMPThreadSafeHashTableItem;
begin
 repeat
  result:=false;
  CurrentState:=AcquireState;
  try
   Version:=CurrentState^.Version;
   Hash:=HashKey(Key);
   StartIndex:=(Hash shr (32-CurrentState^.LogSize)) and CurrentState^.Mask;
   Step:=((Hash shl 1) or 1) and CurrentState^.Mask;
   Index:=StartIndex;
   repeat
    Item:=pointer(TPasMPPtrUInt(TPasMPPtrUInt(CurrentState^.Items)+TPasMPPtrUInt(TPasMPPtrUInt(Index)*TPasMPPtrUInt(fInternalItemSize))));
    case Item^.State of
     PasMPThreadSafeHashTableItemStateDeleted:begin
      // Found deleted item slot => ignore it
     end;
     PasMPThreadSafeHashTableItemStateEmpty:begin
      // Found empty item slot => abort search
      break;
     end;
     PasMPThreadSafeHashTableItemStateUsed:begin
      // Found used item slot => try to read it
      if Item^.Hash=Hash then begin
       TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(Item^.Lock);
       try
        if (Item^.State=PasMPThreadSafeHashTableItemStateUsed) and (Item^.Hash=Hash) and CompareKey(@Item^.Data,Key) then begin
         TPasMPMultipleReaderSingleWriterSpinLock.ReadToWrite(Item^.Lock);
         try
          FinalizeItem(@Item^.Data);
          TPasMPInterlocked.Write(Item^.State,PasMPThreadSafeHashTableItemStateDeleted);
          TPasMPInterlocked.Write(Item^.Lock,0);
          TPasMPInterlocked.Decrement(CurrentState^.Count);
          result:=true;
         finally
          TPasMPMultipleReaderSingleWriterSpinLock.WriteToRead(Item^.Lock);
         end;
        end;
       finally
        TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(Item^.Lock);
       end;
       if result then begin
        break;
       end;
      end;
     end;
    end;
    Index:=(Index+Step) and CurrentState^.Mask;
   until Index=StartIndex;
  finally
   ReleaseState(CurrentState);
  end;
 until Version=fVersion;
end;

constructor TPasMPThreadSafeDynamicArray.Create(const AItemSize:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
var BucketItemIndex:TPasMPInt32;
    Bucket:pointer;
    BucketItemOffset:TPasMPPtrUInt;
begin
 inherited Create;
 fSize:=0;
 fAllocated:=PasMPThreadSafeDynamicArrayFirstBucketSize;
 fCountBuckets:=1;
 fItemSize:=AItemSize;
 fItemLockOffset:=TPasMPMath.RoundUpToMask32(fItemSize,SizeOf(TPasMPInt32));
 fInternalItemSize:=fItemLockOffset+SizeOf(TPasMPInt32);
 if AddCPUCacheLinePaddingToInternalItemDataStructure then begin
  fInternalItemSize:=TPasMPMath.RoundUpToMask32(fInternalItemSize,PasMPCPUCacheLineSize);
 end else begin
  fInternalItemSize:=TPasMPMath.RoundUpToMask32(fInternalItemSize,SizeOf(TPasMPPtrUInt));
 end;
 fLock:=TPasMPMultipleReaderSingleWriterSpinLock.Create;
 FillChar(fBuckets,SizeOf(TPasMPThreadSafeDynamicArrayBuckets),#0);
 TPasMPMemory.AllocateAlignedMemory(Bucket,PasMPThreadSafeDynamicArrayFirstBucketSize*TPasMPPtrUInt(fInternalItemSize));
 FillChar(Bucket^,PasMPThreadSafeDynamicArrayFirstBucketSize*TPasMPPtrUInt(fInternalItemSize),#0);
 for BucketItemIndex:=0 to PasMPThreadSafeDynamicArrayFirstBucketSize-1 do begin
  BucketItemOffset:=TPasMPPtrUInt(BucketItemIndex)*TPasMPPtrUInt(fInternalItemSize);
  InitializeItem(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Bucket)+BucketItemOffset)));
  PPasMPInt32(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Bucket)+BucketItemOffset+TPasMPPtrUInt(fItemLockOffset))))^:=0;
 end;
 TPasMPInterlocked.Write(fBuckets[0],Bucket);
 TPasMPMemoryBarrier.ReadWrite;
end;

destructor TPasMPThreadSafeDynamicArray.Destroy;
var BucketIndex,BucketSize,BucketItemIndex:TPasMPInt32;
    Bucket:pointer;
begin
 TPasMPMemoryBarrier.ReadWrite;
 for BucketIndex:=low(TPasMPThreadSafeDynamicArrayBuckets) to high(TPasMPThreadSafeDynamicArrayBuckets) do begin
  Bucket:=TPasMPInterlocked.Exchange(fBuckets[BucketIndex],nil);
  if assigned(Bucket) then begin
   BucketSize:=PasMPThreadSafeDynamicArrayFirstBucketSize shl BucketIndex;
   for BucketItemIndex:=0 to BucketSize-1 do begin
    FinalizeItem(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Bucket)+(TPasMPPtrUInt(BucketItemIndex)*TPasMPPtrUInt(fInternalItemSize)))));
   end;
   TPasMPMemory.FreeAlignedMemory(Bucket);
  end;
 end;
 fLock.Free;
 inherited Destroy;
end;

procedure TPasMPThreadSafeDynamicArray.InitializeItem(const ItemData:pointer);
begin
end;

procedure TPasMPThreadSafeDynamicArray.FinalizeItem(const ItemData:pointer);
begin
end;

procedure TPasMPThreadSafeDynamicArray.CopyItem(const Source,Destination:pointer);
begin
end;

procedure TPasMPThreadSafeDynamicArray.SetSize(const NewSize:TPasMPInt32);
var ItemIndex,BucketIndex,BucketItemIndex,Position,PositionHighestBit,OldCountBuckets,NewCountBuckets,BucketSize:TPasMPInt32;
    Bucket:pointer;
    BucketItemOffset:TPasMPPtrUInt;
begin

 TPasMPMemoryBarrier.ReadWrite;

 if fSize<>NewSize then begin

  fLock.AcquireRead;
  try

   if fSize<>NewSize then begin

    fLock.ReadToWrite;
    try

     TPasMPMemoryBarrier.ReadWrite;

     if fSize<>NewSize then begin

      if NewSize<fSize then begin
       for ItemIndex:=fSize-1 downto NewSize do begin
        Position:=ItemIndex+PasMPThreadSafeDynamicArrayFirstBucketSize;
        PositionHighestBit:=TPasMPMath.BitScanReverse32(Position);
        BucketIndex:=PositionHighestBit-PasMPThreadSafeDynamicArrayFirstBucketBits;
        BucketItemIndex:=(TPasMPInt32(1) shl PositionHighestBit) xor Position;
        Bucket:=fBuckets[BucketIndex];
        if assigned(Bucket) then begin
         BucketItemOffset:=TPasMPPtrUInt(BucketItemIndex)*TPasMPPtrUInt(fInternalItemSize);
         FinalizeItem(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Bucket)+BucketItemOffset)));
         FillChar(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Bucket)+BucketItemOffset))^,fInternalItemSize,#0);
        end;
       end;
      end;

      Position:=NewSize+PasMPThreadSafeDynamicArrayFirstBucketSize;
      PositionHighestBit:=TPasMPMath.BitScanReverse32(Position);

      OldCountBuckets:=fCountBuckets;
      NewCountBuckets:=PositionHighestBit-(PasMPThreadSafeDynamicArrayFirstBucketBits-1);

      if OldCountBuckets<NewCountBuckets then begin
       // Grow
       for BucketIndex:=OldCountBuckets to NewCountBuckets-1 do begin
        BucketSize:=PasMPThreadSafeDynamicArrayFirstBucketSize shl BucketIndex;
        TPasMPMemory.AllocateAlignedMemory(Bucket,TPasMPPtrUInt(BucketSize)*TPasMPPtrUInt(fInternalItemSize));
        FillChar(Bucket^,TPasMPPtrUInt(BucketSize)*TPasMPPtrUInt(fInternalItemSize),#0);
        if assigned(Bucket) then begin
         for BucketItemIndex:=0 to BucketSize-1 do begin
          BucketItemOffset:=TPasMPPtrUInt(BucketItemIndex)*TPasMPPtrUInt(fInternalItemSize);
          InitializeItem(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Bucket)+BucketItemOffset)));
          PPasMPInt32(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Bucket)+BucketItemOffset+TPasMPPtrUInt(fItemLockOffset))))^:=0;
         end;
        end;
        TPasMPInterlocked.Write(fBuckets[BucketIndex],Bucket);
       end;
      end else if NewCountBuckets<OldCountBuckets then begin
       // Shrink
       for BucketIndex:=NewCountBuckets-1 downto OldCountBuckets do begin
        BucketSize:=PasMPThreadSafeDynamicArrayFirstBucketSize shl BucketIndex;
        Bucket:=TPasMPInterlocked.Exchange(fBuckets[BucketIndex],nil);
        if assigned(Bucket) then begin
         for BucketItemIndex:=0 to BucketSize-1 do begin
          BucketItemOffset:=TPasMPPtrUInt(BucketItemIndex)*TPasMPPtrUInt(fInternalItemSize);
          FinalizeItem(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Bucket)+BucketItemOffset)));
          FillChar(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Bucket)+BucketItemOffset))^,fInternalItemSize,#0);
         end;
         TPasMPMemory.FreeAlignedMemory(Bucket);
        end;
       end;
      end;

      fAllocated:=TPasMPInt32(1) shl PositionHighestBit;
      fCountBuckets:=NewCountBuckets;
      fSize:=NewSize;

     end;

    finally
     fLock.WriteToRead;
    end;

   end;

  finally
   fLock.ReleaseRead;
  end;

 end;

end;

function TPasMPThreadSafeDynamicArray.GetItem(const ItemIndex:TPasMPInt32;const ItemData:pointer):boolean;
var Position,PositionHighestBit,BucketIndex,BucketItemIndex:TPasMPInt32;
    Bucket:pointer;
    BucketItemOffset:TPasMPPtrUInt;
    BucketItemLock:PPasMPInt32;
begin
 result:=false;
 if (ItemIndex>=0) and (ItemIndex<fSize) then begin
  fLock.AcquireRead;
  try
   if (ItemIndex>=0) and (ItemIndex<fSize) then begin
    Position:=ItemIndex+PasMPThreadSafeDynamicArrayFirstBucketSize;
    PositionHighestBit:=TPasMPMath.BitScanReverse32(Position);
    BucketIndex:=PositionHighestBit-PasMPThreadSafeDynamicArrayFirstBucketBits;
    BucketItemIndex:=(TPasMPInt32(1) shl PositionHighestBit) xor Position;
    Bucket:=fBuckets[BucketIndex];
    BucketItemOffset:=TPasMPPtrUInt(BucketItemIndex)*TPasMPPtrUInt(fInternalItemSize);
    BucketItemLock:=PPasMPInt32(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Bucket)+BucketItemOffset+TPasMPPtrUInt(fItemLockOffset))));
    TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(BucketItemLock^);
    try
     CopyItem(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Bucket)+BucketItemOffset)),ItemData);
    finally
     TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(BucketItemLock^);
    end;
    result:=true;
   end;
  finally
   fLock.ReleaseRead;
  end;
 end;
end;

function TPasMPThreadSafeDynamicArray.SetItem(const ItemIndex:TPasMPInt32;const ItemData:pointer):boolean;
var Position,PositionHighestBit,BucketIndex,BucketItemIndex:TPasMPInt32;
    Bucket:pointer;
    BucketItemOffset:TPasMPPtrUInt;
    BucketItemLock:PPasMPInt32;
begin
 result:=false;
 if (ItemIndex>=0) and (ItemIndex<fSize) then begin
  fLock.AcquireRead;
  try
   if (ItemIndex>=0) and (ItemIndex<fSize) then begin
    Position:=ItemIndex+PasMPThreadSafeDynamicArrayFirstBucketSize;
    PositionHighestBit:=TPasMPMath.BitScanReverse32(Position);
    BucketIndex:=PositionHighestBit-PasMPThreadSafeDynamicArrayFirstBucketBits;
    Bucket:=fBuckets[BucketIndex];
    BucketItemIndex:=(TPasMPInt32(1) shl PositionHighestBit) xor Position;
    BucketItemOffset:=TPasMPPtrUInt(BucketItemIndex)*TPasMPPtrUInt(fInternalItemSize);
    BucketItemLock:=PPasMPInt32(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Bucket)+BucketItemOffset+TPasMPPtrUInt(fItemLockOffset))));
    TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(BucketItemLock^);
    try
     CopyItem(ItemData,pointer(TPasMPPtrUInt(TPasMPPtrUInt(Bucket)+BucketItemOffset)));
    finally
     TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(BucketItemLock^);
    end;
    result:=true;
   end;
  finally
   fLock.ReleaseRead;
  end;
 end;
end;

function TPasMPThreadSafeDynamicArray.Push(const ItemData:pointer):TPasMPInt32;
var NewSize,Position,PositionHighestBit,OldCountBuckets,NewCountBuckets,BucketIndex,BucketSize,BucketItemIndex:TPasMPInt32;
    Bucket:pointer;
    BucketItemOffset:TPasMPPtrUInt;
    BucketItemLock:PPasMPInt32;
begin
 fLock.AcquireWrite;
 try
  result:=fSize;

  NewSize:=fSize+1;

  Position:=result+PasMPThreadSafeDynamicArrayFirstBucketSize;
  PositionHighestBit:=TPasMPMath.BitScanReverse32(Position);

  OldCountBuckets:=fCountBuckets;
  NewCountBuckets:=PositionHighestBit-(PasMPThreadSafeDynamicArrayFirstBucketBits-1);

  if OldCountBuckets<NewCountBuckets then begin
   // Grow
   for BucketIndex:=OldCountBuckets to NewCountBuckets-1 do begin
    BucketSize:=PasMPThreadSafeDynamicArrayFirstBucketSize shl BucketIndex;
    TPasMPMemory.AllocateAlignedMemory(Bucket,TPasMPPtrUInt(BucketSize)*TPasMPPtrUInt(fInternalItemSize));
    FillChar(Bucket^,TPasMPPtrUInt(BucketSize)*TPasMPPtrUInt(fInternalItemSize),#0);
    if assigned(Bucket) then begin
     for BucketItemIndex:=0 to BucketSize-1 do begin
      BucketItemOffset:=TPasMPPtrUInt(BucketItemIndex)*TPasMPPtrUInt(fInternalItemSize);
      InitializeItem(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Bucket)+BucketItemOffset)));
      PPasMPInt32(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Bucket)+BucketItemOffset+TPasMPPtrUInt(fItemLockOffset))))^:=0;
     end;
    end;
    TPasMPInterlocked.Write(fBuckets[BucketIndex],Bucket);
   end;
  end;

  fAllocated:=TPasMPInt32(1) shl PositionHighestBit;
  fCountBuckets:=NewCountBuckets;
  fSize:=NewSize;

  Position:=(NewSize-1)+PasMPThreadSafeDynamicArrayFirstBucketSize;
  PositionHighestBit:=TPasMPMath.BitScanReverse32(Position);
  BucketIndex:=PositionHighestBit-PasMPThreadSafeDynamicArrayFirstBucketBits;
  Bucket:=fBuckets[BucketIndex];
  BucketItemIndex:=(TPasMPInt32(1) shl PositionHighestBit) xor Position;
  BucketItemOffset:=TPasMPPtrUInt(BucketItemIndex)*TPasMPPtrUInt(fInternalItemSize);
  BucketItemLock:=PPasMPInt32(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Bucket)+BucketItemOffset+TPasMPPtrUInt(fItemLockOffset))));
  InitializeItem(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Bucket)+BucketItemOffset)));
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(BucketItemLock^);
  try
   CopyItem(ItemData,pointer(TPasMPPtrUInt(TPasMPPtrUInt(Bucket)+BucketItemOffset)));
  finally
   TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(BucketItemLock^);
  end;

 finally
  fLock.ReleaseWrite;
 end;
end;

function TPasMPThreadSafeDynamicArray.Pop(const ItemData:pointer):boolean;
var NewSize,Position,PositionHighestBit,OldCountBuckets,NewCountBuckets,BucketIndex,BucketSize,BucketItemIndex:TPasMPInt32;
    Bucket:pointer;
    BucketItemOffset:TPasMPPtrUInt;
    BucketItemLock:PPasMPInt32;
begin

 result:=false;

 if fSize>0 then begin

  fLock.AcquireWrite;
  try

   if fSize>0 then begin

    NewSize:=fSize-1;

    Position:=NewSize+PasMPThreadSafeDynamicArrayFirstBucketSize;
    PositionHighestBit:=TPasMPMath.BitScanReverse32(Position);

    BucketIndex:=PositionHighestBit-PasMPThreadSafeDynamicArrayFirstBucketBits;
    Bucket:=fBuckets[BucketIndex];
    BucketItemIndex:=(TPasMPInt32(1) shl PositionHighestBit) xor Position;
    BucketItemOffset:=TPasMPPtrUInt(BucketItemIndex)*TPasMPPtrUInt(fInternalItemSize);
    BucketItemLock:=PPasMPInt32(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Bucket)+BucketItemOffset+TPasMPPtrUInt(fItemLockOffset))));
    TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(BucketItemLock^);
    try
     CopyItem(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Bucket)+BucketItemOffset)),ItemData);
    finally
     TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(BucketItemLock^);
    end;

    FinalizeItem(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Bucket)+BucketItemOffset)));
    FillChar(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Bucket)+BucketItemOffset))^,fInternalItemSize,#0);

    OldCountBuckets:=fCountBuckets;
    NewCountBuckets:=PositionHighestBit-(PasMPThreadSafeDynamicArrayFirstBucketBits-1);

    if NewCountBuckets<OldCountBuckets then begin
     // Shrink
     for BucketIndex:=NewCountBuckets-1 downto OldCountBuckets do begin
      BucketSize:=PasMPThreadSafeDynamicArrayFirstBucketSize shl BucketIndex;
      Bucket:=TPasMPInterlocked.Exchange(fBuckets[BucketIndex],nil);
      if assigned(Bucket) then begin
       for BucketItemIndex:=0 to BucketSize-1 do begin
        BucketItemOffset:=TPasMPPtrUInt(BucketItemIndex)*TPasMPPtrUInt(fInternalItemSize);
        FinalizeItem(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Bucket)+BucketItemOffset)));
       end;
       TPasMPMemory.FreeAlignedMemory(Bucket);
      end;
     end;
    end;

    fAllocated:=TPasMPInt32(1) shl PositionHighestBit;
    fCountBuckets:=NewCountBuckets;
    fSize:=NewSize;

    result:=true;

   end;

  finally
   fLock.ReleaseWrite;
  end;

 end;
end;

procedure TPasMPThreadSafeDynamicArray.Clear;
begin
 SetSize(0);
end;

constructor TPasMPSingleProducerSingleConsumerRingBuffer.Create(const Size:TPasMPInt32);
begin
 inherited Create;
 fSize:=Size;
 fReadIndex:=0;
 fWriteIndex:=0;
 fData:=nil;
 SetLength(fData,fSize);
 fLockState:=0;
end;

destructor TPasMPSingleProducerSingleConsumerRingBuffer.Destroy;
begin
 SetLength(fData,0);
 inherited Destroy;
end;

procedure TPasMPSingleProducerSingleConsumerRingBuffer.Clear;
begin
 TPasMPMultipleReaderSingleWriterSpinLock.AcquireWrite(fLockState);
 fReadIndex:=0;
 fWriteIndex:=0;
 TPasMPMultipleReaderSingleWriterSpinLock.ReleaseWrite(fLockState);
end;

function TPasMPSingleProducerSingleConsumerRingBuffer.Read(const Buffer:pointer;Bytes:TPasMPInt32):TPasMPInt32;
var LocalReadIndex,LocalWriteIndex,ToRead:TPasMPInt32;
    p:PPasMPUInt8;
begin
 if (Bytes=0) or (Bytes>fSize) then begin
  result:=0;
 end else begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fLockState);
  repeat
{$if not (defined(CPU386) or defined(CPUx86_64))}
   TPasMPMemoryBarrier.ReadWrite;
{$ifend}
   LocalReadIndex:=fReadIndex;
{$if defined(CPU386) or defined(CPUx86_64)}
   TPasMPMemoryBarrier.ReadDependency;
{$else}
   TPasMPMemoryBarrier.Read;
{$ifend}
   LocalWriteIndex:=fWriteIndex;
   if LocalWriteIndex>=LocalReadIndex then begin
    result:=LocalWriteIndex-LocalReadIndex;
   end else begin
    result:=(fSize-LocalReadIndex)+LocalWriteIndex;
   end;
   if Bytes<=result then begin
    break;
   end else begin
    TPasMP.Yield;
   end;
  until false;
  p:=pointer(Buffer);
  if (LocalReadIndex+Bytes)>fSize then begin
   ToRead:=fSize-LocalReadIndex;
   Move(fData[LocalReadIndex],p^,ToRead);
   inc(p,ToRead);
   dec(Bytes,ToRead);
   LocalReadIndex:=0;
  end;
  if Bytes>0 then begin
   Move(fData[LocalReadIndex],p^,Bytes);
   inc(LocalReadIndex,Bytes);
   if LocalReadIndex>=fSize then begin
    dec(LocalReadIndex,fSize);
   end;
  end;
{$ifdef CPU386}
  asm
   mfence
  end;
{$else}
  TPasMPMemoryBarrier.ReadWrite;
{$endif}
  fReadIndex:=LocalReadIndex;
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fLockState);
  result:=Bytes;
 end;
end;

function TPasMPSingleProducerSingleConsumerRingBuffer.TryRead(const Buffer:pointer;Bytes:TPasMPInt32):TPasMPInt32;
var LocalReadIndex,LocalWriteIndex,ToRead:TPasMPInt32;
    p:PPasMPUInt8;
begin
 if (Bytes=0) or (Bytes>fSize) then begin
  result:=0;
 end else begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fLockState);
{$if not (defined(CPU386) or defined(CPUx86_64))}
  TPasMPMemoryBarrier.ReadWrite;
{$ifend}
  LocalReadIndex:=fReadIndex;
{$if defined(CPU386) or defined(CPUx86_64)}
  TPasMPMemoryBarrier.ReadDependency;
{$else}
  TPasMPMemoryBarrier.Read;
{$ifend}
  LocalWriteIndex:=fWriteIndex;
  if LocalWriteIndex>=LocalReadIndex then begin
   result:=LocalWriteIndex-LocalReadIndex;
  end else begin
   result:=(fSize-LocalReadIndex)+LocalWriteIndex;
  end;
  if Bytes>result then begin
   result:=0;
  end else begin
   p:=pointer(Buffer);
   if (LocalReadIndex+Bytes)>fSize then begin
    ToRead:=fSize-LocalReadIndex;
    Move(fData[LocalReadIndex],p^,ToRead);
    inc(p,ToRead);
    dec(Bytes,ToRead);
    LocalReadIndex:=0;
   end;
   if Bytes>0 then begin
    Move(fData[LocalReadIndex],p^,Bytes);
    inc(LocalReadIndex,Bytes);
    if LocalReadIndex>=fSize then begin
     dec(LocalReadIndex,fSize);
    end;
   end;
{$ifdef CPU386}
   asm
    mfence
   end;
{$else}
   TPasMPMemoryBarrier.ReadWrite;
{$endif}
   fReadIndex:=LocalReadIndex;
   result:=Bytes;
  end;
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fLockState);
 end;
end;

function TPasMPSingleProducerSingleConsumerRingBuffer.ReadAsMuchAsPossible(const Buffer:pointer;Bytes:TPasMPInt32):TPasMPInt32;
var LocalReadIndex,LocalWriteIndex,ToRead:TPasMPInt32;
    p:PPasMPUInt8;
begin
 if (Bytes=0) or (Bytes>fSize) then begin
  result:=0;
 end else begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fLockState);
{$if not (defined(CPU386) or defined(CPUx86_64))}
  TPasMPMemoryBarrier.ReadWrite;
{$ifend}
  LocalReadIndex:=fReadIndex;
{$if defined(CPU386) or defined(CPUx86_64)}
  TPasMPMemoryBarrier.ReadDependency;
{$else}
  TPasMPMemoryBarrier.Read;
{$ifend}
  LocalWriteIndex:=fWriteIndex;
  if LocalWriteIndex>=LocalReadIndex then begin
   result:=LocalWriteIndex-LocalReadIndex;
  end else begin
   result:=(fSize-LocalReadIndex)+LocalWriteIndex;
  end;
  if Bytes>result then begin
   Bytes:=result;
  end;
  if Bytes>0 then begin
   p:=pointer(Buffer);
   if (LocalReadIndex+Bytes)>fSize then begin
    ToRead:=fSize-LocalReadIndex;
    Move(fData[LocalReadIndex],p^,ToRead);
    inc(p,ToRead);
    dec(Bytes,ToRead);
    LocalReadIndex:=0;
   end;
   if Bytes>0 then begin
    Move(fData[LocalReadIndex],p^,Bytes);
    inc(LocalReadIndex,Bytes);
    if LocalReadIndex>=fSize then begin
     dec(LocalReadIndex,fSize);
    end;
   end;
{$ifdef CPU386}
   asm
    mfence
   end;
{$else}
   TPasMPMemoryBarrier.ReadWrite;
{$endif}
   fReadIndex:=LocalReadIndex;
  end;
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fLockState);
  result:=Bytes;
 end;
end;

function TPasMPSingleProducerSingleConsumerRingBuffer.Write(const Buffer:pointer;Bytes:TPasMPInt32):TPasMPInt32;
var LocalReadIndex,LocalWriteIndex,ToWrite:TPasMPInt32;
    p:PPasMPUInt8;
begin
 if (Bytes=0) or (Bytes>fSize) then begin
  result:=0;
 end else begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fLockState);
  repeat
{$if not (defined(CPU386) or defined(CPUx86_64))}
   TPasMPMemoryBarrier.ReadWrite;
{$ifend}
   LocalReadIndex:=fReadIndex;
{$if defined(CPU386) or defined(CPUx86_64)}
   TPasMPMemoryBarrier.ReadDependency;
{$else}
   TPasMPMemoryBarrier.Read;
{$ifend}
   LocalWriteIndex:=fWriteIndex;
   if LocalWriteIndex>=LocalReadIndex then begin
    result:=((fSize+LocalReadIndex)-LocalWriteIndex)-1;
   end else begin
    result:=(LocalReadIndex-LocalWriteIndex)-1;
   end;
   if Bytes<=result then begin
    break;
   end else begin
    TPasMP.Yield;
   end;
  until false;
  p:=pointer(Buffer);
  if (LocalWriteIndex+Bytes)>fSize then begin
   ToWrite:=fSize-LocalWriteIndex;
   Move(p^,fData[LocalWriteIndex],ToWrite);
   inc(p,ToWrite);
   dec(Bytes,ToWrite);
   LocalWriteIndex:=0;
  end;
  if Bytes>0 then begin
   Move(p^,fData[LocalWriteIndex],Bytes);
   inc(LocalWriteIndex,Bytes);
   if LocalWriteIndex>=fSize then begin
    dec(LocalWriteIndex,fSize);
   end;
  end;
{$ifdef CPU386}
  asm
   mfence
  end;
{$else}
  TPasMPMemoryBarrier.ReadWrite;
{$endif}
  fWriteIndex:=LocalWriteIndex;
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fLockState);
  result:=Bytes;
 end;
end;

function TPasMPSingleProducerSingleConsumerRingBuffer.TryWrite(const Buffer:pointer;Bytes:TPasMPInt32):TPasMPInt32;
var LocalReadIndex,LocalWriteIndex,ToWrite:TPasMPInt32;
    p:PPasMPUInt8;
begin
 if (Bytes=0) or (Bytes>fSize) then begin
  result:=0;
 end else begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fLockState);
{$if not (defined(CPU386) or defined(CPUx86_64))}
  TPasMPMemoryBarrier.ReadWrite;
{$ifend}
  LocalReadIndex:=fReadIndex;
{$if defined(CPU386) or defined(CPUx86_64)}
  TPasMPMemoryBarrier.ReadDependency;
{$else}
  TPasMPMemoryBarrier.Read;
{$ifend}
  LocalWriteIndex:=fWriteIndex;
  if LocalWriteIndex>=LocalReadIndex then begin
   result:=((fSize+LocalReadIndex)-LocalWriteIndex)-1;
  end else begin
   result:=(LocalReadIndex-LocalWriteIndex)-1;
  end;
  if Bytes>result then begin
   result:=0;
  end else begin
   p:=pointer(Buffer);
   if (LocalWriteIndex+Bytes)>fSize then begin
    ToWrite:=fSize-LocalWriteIndex;
    Move(p^,fData[LocalWriteIndex],ToWrite);
    inc(p,ToWrite);
    dec(Bytes,ToWrite);
    LocalWriteIndex:=0;
   end;
   if Bytes>0 then begin
    Move(p^,fData[LocalWriteIndex],Bytes);
    inc(LocalWriteIndex,Bytes);
    if LocalWriteIndex>=fSize then begin
     dec(LocalWriteIndex,fSize);
    end;
   end;
{$ifdef CPU386}
   asm
    mfence
   end;
{$else}
   TPasMPMemoryBarrier.ReadWrite;
{$endif}
   fWriteIndex:=LocalWriteIndex;
   result:=Bytes;
  end;
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fLockState);
 end;
end;

function TPasMPSingleProducerSingleConsumerRingBuffer.WriteAsMuchAsPossible(const Buffer:pointer;Bytes:TPasMPInt32):TPasMPInt32;
var LocalReadIndex,LocalWriteIndex,ToWrite:TPasMPInt32;
    p:PPasMPUInt8;
begin
 if (Bytes=0) or (Bytes>fSize) then begin
  result:=0;
 end else begin
  TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fLockState);
{$if not (defined(CPU386) or defined(CPUx86_64))}
  TPasMPMemoryBarrier.ReadWrite;
{$ifend}
  LocalReadIndex:=fReadIndex;
{$if defined(CPU386) or defined(CPUx86_64)}
  TPasMPMemoryBarrier.ReadDependency;
{$else}
  TPasMPMemoryBarrier.Read;
{$ifend}
  LocalWriteIndex:=fWriteIndex;
  if LocalWriteIndex>=LocalReadIndex then begin
   result:=((fSize+LocalReadIndex)-LocalWriteIndex)-1;
  end else begin
   result:=(LocalReadIndex-LocalWriteIndex)-1;
  end;
  if Bytes>result then begin
   Bytes:=result;
  end;
  if Bytes>0 then begin
   p:=pointer(Buffer);
   if (LocalWriteIndex+Bytes)>fSize then begin
    ToWrite:=fSize-LocalWriteIndex;
    Move(p^,fData[LocalWriteIndex],ToWrite);
    inc(p,ToWrite);
    dec(Bytes,ToWrite);
    LocalWriteIndex:=0;
   end;
   if Bytes>0 then begin
    Move(p^,fData[LocalWriteIndex],Bytes);
    inc(LocalWriteIndex,Bytes);
    if LocalWriteIndex>=fSize then begin
     dec(LocalWriteIndex,fSize);
    end;
   end;
{$ifdef CPU386}
   asm
    mfence
   end;
{$else}
   TPasMPMemoryBarrier.ReadWrite;
{$endif}
   fWriteIndex:=LocalWriteIndex;
  end;
  TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fLockState);
  result:=Bytes;
 end;
end;

function TPasMPSingleProducerSingleConsumerRingBuffer.AvailableForRead:TPasMPInt32;
var LocalReadIndex,LocalWriteIndex:TPasMPInt32;
begin
 TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fLockState);
{$if not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.ReadWrite;
{$ifend}
 LocalReadIndex:=fReadIndex;
{$if defined(CPU386) or defined(CPUx86_64)}
 TPasMPMemoryBarrier.ReadDependency;
{$else}
 TPasMPMemoryBarrier.Read;
{$ifend}
 LocalWriteIndex:=fWriteIndex;
 TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fLockState);
 if LocalWriteIndex>=LocalReadIndex then begin
  result:=LocalWriteIndex-LocalReadIndex;
 end else begin
  result:=(fSize-LocalReadIndex)+LocalWriteIndex;
 end;
end;

function TPasMPSingleProducerSingleConsumerRingBuffer.AvailableForWrite:TPasMPInt32;
var LocalReadIndex,LocalWriteIndex:TPasMPInt32;
begin
 TPasMPMultipleReaderSingleWriterSpinLock.AcquireRead(fLockState);
{$if not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.ReadWrite;
{$ifend}
 LocalReadIndex:=fReadIndex;
{$if defined(CPU386) or defined(CPUx86_64)}
 TPasMPMemoryBarrier.ReadDependency;
{$else}
 TPasMPMemoryBarrier.Read;
{$ifend}
 LocalWriteIndex:=fWriteIndex;
 TPasMPMultipleReaderSingleWriterSpinLock.ReleaseRead(fLockState);
 if LocalWriteIndex>=LocalReadIndex then begin
  result:=((fSize+LocalReadIndex)-LocalWriteIndex)-1;
 end else begin
  result:=(LocalReadIndex-LocalWriteIndex)-1;
 end;
end;

constructor TPasMPSingleProducerSingleConsumerBoundedQueue.Create(const MaximalCount,ItemSize:TPasMPInt32);
begin
 inherited Create;
 fMaximalCount:=MaximalCount;
 fItemSize:=ItemSize;
 fReadIndex:=0;
 fWriteIndex:=0;
 fData:=nil;
 SetLength(fData,fMaximalCount*fItemSize);
end;

destructor TPasMPSingleProducerSingleConsumerBoundedQueue.Destroy;
begin
 SetLength(fData,0);
 inherited Destroy;
end;

function TPasMPSingleProducerSingleConsumerBoundedQueue.Enqueue(const Item):boolean;
var LocalReadIndex,LocalWriteIndex:TPasMPInt32;
begin
{$if not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.ReadWrite;
{$ifend}
 LocalReadIndex:=fReadIndex;
{$if defined(CPU386) or defined(CPUx86_64)}
 TPasMPMemoryBarrier.ReadDependency;
{$else}
 TPasMPMemoryBarrier.Read;
{$ifend}
 LocalWriteIndex:=fWriteIndex;
 if LocalWriteIndex>=LocalReadIndex then begin
  result:=(((fMaximalCount+LocalReadIndex)-LocalWriteIndex)-1)>0;
 end else begin
  result:=((LocalReadIndex-LocalWriteIndex)-1)>0;
 end;
 if result then begin
  LocalWriteIndex:=fWriteIndex;
  Move(Item,fData[LocalWriteIndex*fItemSize],fItemSize);
  inc(LocalWriteIndex);
  if LocalWriteIndex>=fMaximalCount then begin
   LocalWriteIndex:=0;
  end;
  TPasMPMemoryBarrier.ReadWrite;
  fWriteIndex:=LocalWriteIndex;
 end;
end;

function TPasMPSingleProducerSingleConsumerBoundedQueue.Dequeue(out Item):boolean;
var LocalReadIndex,LocalWriteIndex:TPasMPInt32;
begin
{$if not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.ReadWrite;
{$ifend}
 LocalReadIndex:=fReadIndex;
{$if defined(CPU386) or defined(CPUx86_64)}
 TPasMPMemoryBarrier.ReadDependency;
{$else}
 TPasMPMemoryBarrier.Read;
{$ifend}
 LocalWriteIndex:=fWriteIndex;
 if LocalWriteIndex>=LocalReadIndex then begin
  result:=(LocalWriteIndex-LocalReadIndex)>0;
 end else begin
  result:=((fMaximalCount-LocalReadIndex)+LocalWriteIndex)>0;
 end;
 if result then begin
  LocalReadIndex:=fReadIndex;
  Move(fData[LocalReadIndex*fItemSize],Item,fItemSize);
  inc(LocalReadIndex);
  if LocalReadIndex>=fMaximalCount then begin
   LocalReadIndex:=0;
  end;
  TPasMPMemoryBarrier.ReadWrite;
  fReadIndex:=LocalReadIndex;
 end;
end;

function TPasMPSingleProducerSingleConsumerBoundedQueue.AvailableForEnqueue:TPasMPInt32;
var LocalReadIndex,LocalWriteIndex:TPasMPInt32;
begin
{$if not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.ReadWrite;
{$ifend}
 LocalReadIndex:=fReadIndex;
{$if defined(CPU386) or defined(CPUx86_64)}
 TPasMPMemoryBarrier.ReadDependency;
{$else}
 TPasMPMemoryBarrier.Read;
{$ifend}
 LocalWriteIndex:=fWriteIndex;
 if LocalWriteIndex>=LocalReadIndex then begin
  result:=((fMaximalCount+LocalReadIndex)-LocalWriteIndex)-1;
 end else begin
  result:=(LocalReadIndex-LocalWriteIndex)-1;
 end;
end;

function TPasMPSingleProducerSingleConsumerBoundedQueue.AvailableForDequeue:TPasMPInt32;
var LocalReadIndex,LocalWriteIndex:TPasMPInt32;
begin
{$if not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.ReadWrite;
{$ifend}
 LocalReadIndex:=fReadIndex;
{$if defined(CPU386) or defined(CPUx86_64)}
 TPasMPMemoryBarrier.ReadDependency;
{$else}
 TPasMPMemoryBarrier.Read;
{$ifend}
 LocalWriteIndex:=fWriteIndex;
 if LocalWriteIndex>=LocalReadIndex then begin
  result:=LocalWriteIndex-LocalReadIndex;
 end else begin
  result:=(fMaximalCount-LocalReadIndex)+LocalWriteIndex;
 end;
end;

function TPasMPSingleProducerSingleConsumerBoundedQueue.IsFull:boolean;
var LocalReadIndex,LocalWriteIndex:TPasMPInt32;
begin
{$if not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.ReadWrite;
{$ifend}
 LocalReadIndex:=fReadIndex;
{$if defined(CPU386) or defined(CPUx86_64)}
 TPasMPMemoryBarrier.ReadDependency;
{$else}
 TPasMPMemoryBarrier.Read;
{$ifend}
 LocalWriteIndex:=fWriteIndex;
 if LocalWriteIndex>=LocalReadIndex then begin
  result:=(LocalWriteIndex-LocalReadIndex)=0;
 end else begin
  result:=((fMaximalCount-LocalReadIndex)+LocalWriteIndex)=0;
 end;
end;

{$ifdef HAS_GENERICS}
constructor TPasMPSingleProducerSingleConsumerBoundedQueue<T>.Create(const MaximalCount:TPasMPInt32);
begin
 inherited Create;
 fMaximalCount:=MaximalCount;
 fReadIndex:=0;
 fWriteIndex:=0;
 fData:=nil;
 SetLength(fData,fMaximalCount);
end;

destructor TPasMPSingleProducerSingleConsumerBoundedQueue<T>.Destroy;
begin
 SetLength(fData,0);
 inherited Destroy;
end;

function TPasMPSingleProducerSingleConsumerBoundedQueue<T>.Enqueue(const Item:T):boolean;
var LocalReadIndex,LocalWriteIndex:TPasMPInt32;
begin
{$if not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.ReadWrite;
{$ifend}
 LocalReadIndex:=fReadIndex;
{$if defined(CPU386) or defined(CPUx86_64)}
 TPasMPMemoryBarrier.ReadDependency;
{$else}
 TPasMPMemoryBarrier.Read;
{$ifend}
 LocalWriteIndex:=fWriteIndex;
 if LocalWriteIndex>=LocalReadIndex then begin
  result:=(((fMaximalCount+LocalReadIndex)-LocalWriteIndex)-1)>0;
 end else begin
  result:=((LocalReadIndex-LocalWriteIndex)-1)>0;
 end;
 if result then begin
  LocalWriteIndex:=fWriteIndex;
  Initialize(fData[LocalWriteIndex]);
  fData[LocalWriteIndex]:=Item;
  inc(LocalWriteIndex);
  if LocalWriteIndex>=fMaximalCount then begin
   LocalWriteIndex:=0;
  end;
  TPasMPMemoryBarrier.ReadWrite;
  fWriteIndex:=LocalWriteIndex;
 end;
end;

function TPasMPSingleProducerSingleConsumerBoundedQueue<T>.Dequeue(out Item:T):boolean;
var LocalReadIndex,LocalWriteIndex:TPasMPInt32;
begin
{$if not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.ReadWrite;
{$ifend}
 LocalReadIndex:=fReadIndex;
{$if defined(CPU386) or defined(CPUx86_64)}
 TPasMPMemoryBarrier.ReadDependency;
{$else}
 TPasMPMemoryBarrier.Read;
{$ifend}
 LocalWriteIndex:=fWriteIndex;
 if LocalWriteIndex>=LocalReadIndex then begin
  result:=(LocalWriteIndex-LocalReadIndex)>0;
 end else begin
  result:=((fMaximalCount-LocalReadIndex)+LocalWriteIndex)>0;
 end;
 if result then begin
  LocalReadIndex:=fReadIndex;
  Item:=fData[LocalReadIndex];
  Finalize(fData[LocalReadIndex]);
  inc(LocalReadIndex);
  if LocalReadIndex>=fMaximalCount then begin
   LocalReadIndex:=0;
  end;
  TPasMPMemoryBarrier.ReadWrite;
  fReadIndex:=LocalReadIndex;
 end;
end;

function TPasMPSingleProducerSingleConsumerBoundedQueue<T>.AvailableForEnqueue:TPasMPInt32;
var LocalReadIndex,LocalWriteIndex:TPasMPInt32;
begin
{$if not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.ReadWrite;
{$ifend}
 LocalReadIndex:=fReadIndex;
{$if defined(CPU386) or defined(CPUx86_64)}
 TPasMPMemoryBarrier.ReadDependency;
{$else}
 TPasMPMemoryBarrier.Read;
{$ifend}
 LocalWriteIndex:=fWriteIndex;
 if LocalWriteIndex>=LocalReadIndex then begin
  result:=((fMaximalCount+LocalReadIndex)-LocalWriteIndex)-1;
 end else begin
  result:=(LocalReadIndex-LocalWriteIndex)-1;
 end;
end;

function TPasMPSingleProducerSingleConsumerBoundedQueue<T>.AvailableForDequeue:TPasMPInt32;
var LocalReadIndex,LocalWriteIndex:TPasMPInt32;
begin
{$if not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.ReadWrite;
{$ifend}
 LocalReadIndex:=fReadIndex;
{$if defined(CPU386) or defined(CPUx86_64)}
 TPasMPMemoryBarrier.ReadDependency;
{$else}
 TPasMPMemoryBarrier.Read;
{$ifend}
 LocalWriteIndex:=fWriteIndex;
 if LocalWriteIndex>=LocalReadIndex then begin
  result:=LocalWriteIndex-LocalReadIndex;
 end else begin
  result:=(fMaximalCount-LocalReadIndex)+LocalWriteIndex;
 end;
end;

function TPasMPSingleProducerSingleConsumerBoundedQueue<T>.IsFull:boolean;
var LocalReadIndex,LocalWriteIndex:TPasMPInt32;
begin
{$if not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.ReadWrite;
{$ifend}
 LocalReadIndex:=fReadIndex;
{$if defined(CPU386) or defined(CPUx86_64)}
 TPasMPMemoryBarrier.ReadDependency;
{$else}
 TPasMPMemoryBarrier.Read;
{$ifend}
 LocalWriteIndex:=fWriteIndex;
 if LocalWriteIndex>=LocalReadIndex then begin
  result:=(LocalWriteIndex-LocalReadIndex)=0;
 end else begin
  result:=((fMaximalCount-LocalReadIndex)+LocalWriteIndex)=0;
 end;
end;
{$endif}

constructor TPasMPBoundedStack.Create(const MaximalCount,ItemSize:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
var i:TPasMPInt32;
    p:PPasMPUInt8;
    StackItem:PPasMPBoundedStackItem;
begin
 inherited Create;
 fStack:=TPasMPThreadSafeStack.Create;
 fFree:=TPasMPThreadSafeStack.Create;
 fMaximalCount:=MaximalCount;
 fItemSize:=ItemSize;
 fInternalItemSize:=SizeOf(TPasMPBoundedStackItem)+fItemSize;
 if AddCPUCacheLinePaddingToInternalItemDataStructure then begin
  fInternalItemSize:=TPasMPMath.RoundUpToMask32(fInternalItemSize,PasMPCPUCacheLineSize);
 end else begin
  fInternalItemSize:=TPasMPMath.RoundUpToMask32(fInternalItemSize,PasMPDoubleNativeMachineWordAtomicCompareExchangeAlignment);
 end;
 TPasMPMemory.AllocateAlignedMemory(fData,fInternalItemSize*fMaximalCount,PasMPCPUCacheLineSize);
 p:=fData;
 for i:=0 to fMaximalCount-1 do begin
  StackItem:=pointer(p);
  inc(p,fInternalItemSize);
  fFree.Push(StackItem);
 end;
end;

destructor TPasMPBoundedStack.Destroy;
begin
 TPasMPMemory.FreeAlignedMemory(fData);
 fFree.Free;
 fStack.Free;
 inherited Destroy;
end;

function TPasMPBoundedStack.IsEmpty:boolean;
begin
 result:=fStack.IsEmpty;
end;

function TPasMPBoundedStack.IsFull:boolean;
begin
 result:=fFree.IsEmpty;
end;

function TPasMPBoundedStack.Push(const Item):boolean;
var StackItem:PPasMPBoundedStackItem;
begin
 StackItem:=fFree.Pop;
 if assigned(StackItem) then begin
  Move(Item,StackItem^.Data,fItemSize);
  fStack.Push(StackItem);
  result:=true;
 end else begin
  result:=false;
 end;
end;

function TPasMPBoundedStack.Pop(out Item):boolean;
var StackItem:PPasMPBoundedStackItem;
begin
 StackItem:=fStack.Pop;
 if assigned(StackItem) then begin
  Move(StackItem^.Data,Item,fItemSize);
  fFree.Push(StackItem);
  result:=true;
 end else begin
  result:=false;
 end;
end;

{$ifdef HAS_GENERICS}
constructor TPasMPBoundedStack<T>.Create(const MaximalCount:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
var i:TPasMPInt32;
    p:PPasMPUInt8;
    StackItem:PPasMPBoundedTypedStackItem;
begin
 inherited Create;
 fStack:=TPasMPThreadSafeStack.Create;
 fFree:=TPasMPThreadSafeStack.Create;
 fMaximalCount:=MaximalCount;
 fInternalItemSize:=SizeOf(TPasMPBoundedTypedStackItem);
 if AddCPUCacheLinePaddingToInternalItemDataStructure then begin
  fInternalItemSize:=TPasMPMath.RoundUpToMask32(fInternalItemSize,PasMPCPUCacheLineSize);
 end else begin
  fInternalItemSize:=TPasMPMath.RoundUpToMask32(fInternalItemSize,PasMPDoubleNativeMachineWordAtomicCompareExchangeAlignment);
 end;
 TPasMPMemory.AllocateAlignedMemory(fData,fInternalItemSize*fMaximalCount,PasMPCPUCacheLineSize);
 p:=fData;
 for i:=0 to fMaximalCount-1 do begin
  StackItem:=pointer(p);
  Initialize(StackItem^);
  inc(p,fInternalItemSize);
  fFree.Push(StackItem);
 end;
end;

destructor TPasMPBoundedStack<T>.Destroy;
var i:TPasMPInt32;
    p:PPasMPUInt8;
    StackItem:PPasMPBoundedTypedStackItem;
begin
 p:=fData;
 for i:=0 to fMaximalCount-1 do begin
  StackItem:=pointer(p);
  Finalize(StackItem^);
  inc(p,fInternalItemSize);
 end;
 TPasMPMemory.FreeAlignedMemory(fData);
 fFree.Free;
 fStack.Free;
 inherited Destroy;
end;

function TPasMPBoundedStack<T>.IsEmpty:boolean;
begin
 result:=fStack.IsEmpty;
end;

function TPasMPBoundedStack<T>.IsFull:boolean;
begin
 result:=fFree.IsEmpty;
end;

function TPasMPBoundedStack<T>.Push(const Item:T):boolean;
var StackItem:PPasMPBoundedTypedStackItem;
begin
 StackItem:=fFree.Pop;
 if assigned(StackItem) then begin
  StackItem^.Data:=Item;
  fStack.Push(StackItem);
  result:=true;
 end else begin
  result:=false;
 end;
end;

function TPasMPBoundedStack<T>.Pop(out Item:T):boolean;
var StackItem:PPasMPBoundedTypedStackItem;
begin
 StackItem:=fStack.Pop;
 if assigned(StackItem) then begin
  Item:=StackItem^.Data;
  Finalize(StackItem^);
  fFree.Push(StackItem);
  result:=true;
 end else begin
  result:=false;
 end;
end;
{$endif}

constructor TPasMPUnboundedStack.Create(const ItemSize:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
begin
 inherited Create;
 fStack:=TPasMPThreadSafeStack.Create;
 fItemSize:=ItemSize;
 fAddCPUCacheLinePaddingToInternalItemDataStructure:=AddCPUCacheLinePaddingToInternalItemDataStructure;
end;

destructor TPasMPUnboundedStack.Destroy;
var StackItem:PPasMPUnboundedStackItem;
begin
 repeat
  StackItem:=fStack.Pop;
  if assigned(StackItem) then begin
   TPasMPMemory.FreeAlignedMemory(StackItem);
  end else begin
   break;
  end;
 until false;
 fStack.Free;
 inherited Destroy;
end;

function TPasMPUnboundedStack.IsEmpty:boolean;
begin
 result:=fStack.IsEmpty;
end;

function TPasMPUnboundedStack.Push(const Item):boolean;
var StackItem:PPasMPUnboundedStackItem;
begin
 if fAddCPUCacheLinePaddingToInternalItemDataStructure then begin
  TPasMPMemory.AllocateAlignedMemory(StackItem,TPasMPMath.RoundUpToMask32(SizeOf(TPasMPUnboundedStackItem)+fItemSize,PasMPCPUCacheLineSize),PasMPCPUCacheLineSize);
 end else begin
  TPasMPMemory.AllocateAlignedMemory(StackItem,TPasMPMath.RoundUpToMask32(SizeOf(TPasMPUnboundedStackItem)+fItemSize,PasMPDoubleNativeMachineWordAtomicCompareExchangeAlignment),PasMPDoubleNativeMachineWordAtomicCompareExchangeAlignment);
 end;
 Move(Item,StackItem^.Data,fItemSize);
 fStack.Push(StackItem);
 result:=true;
end;

function TPasMPUnboundedStack.Pop(out Item):boolean;
var StackItem:PPasMPUnboundedStackItem;
begin
 StackItem:=fStack.Pop;
 if assigned(StackItem) then begin
  Move(StackItem^.Data,Item,fItemSize);
  TPasMPMemory.FreeAlignedMemory(StackItem);
  result:=true;
 end else begin
  result:=false;
 end;
end;

{$ifdef HAS_GENERICS}
constructor TPasMPUnboundedStack<T>.Create(const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
begin
 inherited Create;
 fStack:=TPasMPThreadSafeStack.Create;
 fItemSize:=SizeOf(T);
 fAddCPUCacheLinePaddingToInternalItemDataStructure:=AddCPUCacheLinePaddingToInternalItemDataStructure;
end;

destructor TPasMPUnboundedStack<T>.Destroy;
var StackItem:PPasMPUnboundedTypedStackItem;
begin
 repeat
  StackItem:=fStack.Pop;
  if assigned(StackItem) then begin
   Finalize(StackItem^);
   TPasMPMemory.FreeAlignedMemory(StackItem);
  end else begin
   break;
  end;
 until false;
 fStack.Free;
 inherited Destroy;
end;

function TPasMPUnboundedStack<T>.IsEmpty:boolean;
begin
 result:=fStack.IsEmpty;
end;

function TPasMPUnboundedStack<T>.Push(const Item:T):boolean;
var StackItem:PPasMPUnboundedTypedStackItem;
begin
 if fAddCPUCacheLinePaddingToInternalItemDataStructure then begin
  TPasMPMemory.AllocateAlignedMemory(StackItem,TPasMPMath.RoundUpToMask32(SizeOf(TPasMPUnboundedTypedStackItem),PasMPCPUCacheLineSize),PasMPCPUCacheLineSize);
 end else begin
  TPasMPMemory.AllocateAlignedMemory(StackItem,TPasMPMath.RoundUpToMask32(SizeOf(TPasMPUnboundedTypedStackItem),PasMPDoubleNativeMachineWordAtomicCompareExchangeAlignment),PasMPDoubleNativeMachineWordAtomicCompareExchangeAlignment);
 end;
 Initialize(StackItem^);
 StackItem^.Data:=Item;
 fStack.Push(StackItem);
 result:=true;
end;

function TPasMPUnboundedStack<T>.Pop(out Item:T):boolean;
var StackItem:PPasMPUnboundedTypedStackItem;
begin
 StackItem:=fStack.Pop;
 if assigned(StackItem) then begin
  Item:=StackItem^.Data;
  Finalize(StackItem^);
  TPasMPMemory.FreeAlignedMemory(StackItem);
  result:=true;
 end else begin
  result:=false;
 end;
end;
{$endif}

constructor TPasMPBoundedQueue.Create(const MaximalCount,ItemSize:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
var i:TPasMPInt32;
    p:PPasMPUInt8;
    QueueItem:PPasMPBoundedQueueItem;
begin
 inherited Create;
 fQueue:=TPasMPThreadSafeQueue.Create(SizeOf(PPasMPBoundedQueueItem),AddCPUCacheLinePaddingToInternalItemDataStructure);
 fFree:=TPasMPThreadSafeStack.Create;
 fMaximalCount:=MaximalCount;
 fItemSize:=ItemSize;
 fInternalItemSize:=SizeOf(TPasMPBoundedQueueItem)+fItemSize;
 if AddCPUCacheLinePaddingToInternalItemDataStructure then begin
  fInternalItemSize:=TPasMPMath.RoundUpToMask32(fInternalItemSize,PasMPCPUCacheLineSize);
 end else begin
  fInternalItemSize:=TPasMPMath.RoundUpToMask32(fInternalItemSize,PasMPDoubleNativeMachineWordAtomicCompareExchangeAlignment);
 end;
 TPasMPMemory.AllocateAlignedMemory(fData,fInternalItemSize*fMaximalCount,PasMPCPUCacheLineSize);
 p:=fData;
 for i:=0 to fMaximalCount-1 do begin
  QueueItem:=pointer(p);
  inc(p,fInternalItemSize);
  fFree.Push(QueueItem);
 end;
end;

destructor TPasMPBoundedQueue.Destroy;
begin
 TPasMPMemory.FreeAlignedMemory(fData);
 fFree.Free;
 fQueue.Free;
 inherited Destroy;
end;

function TPasMPBoundedQueue.IsEmpty:boolean;
begin
 result:=fQueue.IsEmpty;
end;

function TPasMPBoundedQueue.IsFull:boolean;
begin
 result:=fFree.IsEmpty;
end;

function TPasMPBoundedQueue.Enqueue(const Item):boolean;
var QueueItem:PPasMPBoundedQueueItem;
begin
 QueueItem:=fFree.Pop;
 if assigned(QueueItem) then begin
  Move(Item,QueueItem^.Data,fItemSize);
  fQueue.Enqueue(QueueItem);
  result:=true;
 end else begin
  result:=false;
 end;
end;

function TPasMPBoundedQueue.Dequeue(out Item):boolean;
var StackItem:PPasMPBoundedQueueItem;
begin
 result:=fQueue.Dequeue(StackItem);
 if result then begin
  Move(StackItem^.Data,Item,fItemSize);
  fFree.Push(StackItem);
 end;
end;

{$ifdef HAS_GENERICS}
constructor TPasMPBoundedQueue<T>.Create(const MaximalCount:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
var i:TPasMPInt32;
    p:PPasMPUInt8;
    QueueItem:PPasMPBoundedTypedQueueItem;
begin
 inherited Create;
 fQueue:=TPasMPThreadSafeQueue.Create(SizeOf(PPasMPBoundedQueueItem),AddCPUCacheLinePaddingToInternalItemDataStructure);
 fFree:=TPasMPThreadSafeStack.Create;
 fMaximalCount:=MaximalCount;
 fInternalItemSize:=SizeOf(TPasMPBoundedTypedQueueItem);
 if AddCPUCacheLinePaddingToInternalItemDataStructure then begin
  fInternalItemSize:=TPasMPMath.RoundUpToMask32(fInternalItemSize,PasMPCPUCacheLineSize);
 end else begin
  fInternalItemSize:=TPasMPMath.RoundUpToMask32(fInternalItemSize,PasMPDoubleNativeMachineWordAtomicCompareExchangeAlignment);
 end;
 TPasMPMemory.AllocateAlignedMemory(fData,fInternalItemSize*fMaximalCount,PasMPCPUCacheLineSize);
 p:=fData;
 for i:=0 to fMaximalCount-1 do begin
  QueueItem:=pointer(p);
  Initialize(QueueItem^);
  inc(p,fInternalItemSize);
  fFree.Push(QueueItem);
 end;
end;

destructor TPasMPBoundedQueue<T>.Destroy;
var i:TPasMPInt32;
    p:PPasMPUInt8;
    QueueItem:PPasMPBoundedTypedQueueItem;
begin
 p:=fData;
 for i:=0 to fMaximalCount-1 do begin
  QueueItem:=pointer(p);
  Finalize(QueueItem^);
  inc(p,fInternalItemSize);
 end;
 TPasMPMemory.FreeAlignedMemory(fData);
 fFree.Free;
 fQueue.Free;
 inherited Destroy;
end;

function TPasMPBoundedQueue<T>.IsEmpty:boolean;
begin
 result:=fQueue.IsEmpty;
end;

function TPasMPBoundedQueue<T>.IsFull:boolean;
begin
 result:=fFree.IsEmpty;
end;

function TPasMPBoundedQueue<T>.Enqueue(const Item:T):boolean;
var QueueItem:PPasMPBoundedTypedQueueItem;
begin
 QueueItem:=fFree.Pop;
 if assigned(QueueItem) then begin
  Initialize(QueueItem^);
  QueueItem^.Data:=Item;
  fQueue.Enqueue(QueueItem);
  result:=true;
 end else begin
  result:=false;
 end;
end;

function TPasMPBoundedQueue<T>.Dequeue(out Item:T):boolean;
var QueueItem:PPasMPBoundedTypedQueueItem;
begin
 result:=fQueue.Dequeue(QueueItem);
 if result then begin
  Item:=QueueItem^.Data;
  Finalize(QueueItem^);
  fFree.Push(QueueItem);
  result:=true;
 end else begin
  result:=false;
 end;
end;
{$endif}

constructor TPasMPBoundedArrayBasedQueue.Create(const MaximalCount,ItemSize:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
begin
 inherited Create(MaximalCount,ItemSize,AddCPUCacheLinePaddingToInternalItemDataStructure);
end;

destructor TPasMPBoundedArrayBasedQueue.Destroy;
begin
 inherited Destroy;
end;

{$ifdef HAS_GENERICS}
constructor TPasMPBoundedArrayBasedQueue<T>.Create(const MaximalCount:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
begin
 inherited Create(MaximalCount,SizeOf(T),AddCPUCacheLinePaddingToInternalItemDataStructure);
end;

destructor TPasMPBoundedArrayBasedQueue<T>.Destroy;
begin
 inherited Destroy;
end;

procedure TPasMPBoundedArrayBasedQueue<T>.InitializeItem(const Data:pointer);
begin
 Initialize(T(Data^));
end;

procedure TPasMPBoundedArrayBasedQueue<T>.FinalizeItem(const Data:pointer);
begin
 Finalize(T(Data^));
end;

procedure TPasMPBoundedArrayBasedQueue<T>.CopyItem(const Source,Destination:pointer);
begin
 T(Destination^):=T(Source^);
end;

function TPasMPBoundedArrayBasedQueue<T>.Enqueue(const Item:T):boolean;
begin
 result:=inherited Enqueue(Item);
end;

function TPasMPBoundedArrayBasedQueue<T>.Dequeue(out Item:T):boolean;
begin
 result:=inherited Dequeue(Item);
end;

{$endif}

constructor TPasMPUnboundedQueue.Create(const ItemSize:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
begin
 inherited Create(ItemSize,AddCPUCacheLinePaddingToInternalItemDataStructure);
end;

destructor TPasMPUnboundedQueue.Destroy;
begin
 inherited Destroy;
end;

{$ifdef HAS_GENERICS}
constructor TPasMPUnboundedQueue<T>.Create(const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
begin
 inherited Create(SizeOf(T),AddCPUCacheLinePaddingToInternalItemDataStructure);
end;

destructor TPasMPUnboundedQueue<T>.Destroy;
begin
 inherited Destroy;
end;

procedure TPasMPUnboundedQueue<T>.InitializeItem(const Data:pointer);
begin
 Initialize(T(Data^));
end;

procedure TPasMPUnboundedQueue<T>.FinalizeItem(const Data:pointer);
begin
 Finalize(T(Data^));
end;

procedure TPasMPUnboundedQueue<T>.CopyItem(const Source,Destination:pointer);
begin
 T(Destination^):=T(Source^);
end;

procedure TPasMPUnboundedQueue<T>.Enqueue(const Item:T);
begin
 inherited Enqueue(Item);
end;

function TPasMPUnboundedQueue<T>.Dequeue(out Item:T):boolean;
begin
 result:=inherited Dequeue(Item);
end;
{$endif}

{$ifdef HAS_GENERICS}
{$if defined(fpc) and (fpc_version>=3)}{$push}{$optimization noorderfields}{$ifend}
constructor TPasMPMultipleProducerMultipleConsumerQueue<T>.Create(const aCapacity:TPasMPSizeInt);
var Index:TPasMPSizeInt;
begin
 inherited Create;

 if aCapacity<1 then begin
  raise Exception.Create('Capacity < 1 is invalid');
 end;

 fCapacity:=aCapacity;

 fSlots:=nil;
 SetLength(fSlots,fCapacity+1);

 for Index:=0 to fCapacity do begin
  fSlots[Index].fTurn:=0;
 end;

 fHead:=0;
 fTail:=0;

end;

destructor TPasMPMultipleProducerMultipleConsumerQueue<T>.Destroy;
begin
 fSlots:=nil;
 inherited Destroy;
end;

function TPasMPMultipleProducerMultipleConsumerQueue<T>.Idx(const aX:TPasMPSizeUIntEx):TPasMPSizeUIntEx;
begin
 result:=aX mod fCapacity;
end;

function TPasMPMultipleProducerMultipleConsumerQueue<T>.TurnOf(const aX:TPasMPSizeUIntEx):TPasMPSizeUIntEx;
begin
 result:=aX div fCapacity;
end;

procedure TPasMPMultipleProducerMultipleConsumerQueue<T>.Enqueue(const aValue:T);
var OldHead,SlotTurn,DesiredTurn:TPasMPSizeUIntEx;
    Slot:PSlot;
begin

 // Atomically increment fHead by 1 (fetch-and-add).
 OldHead:=TPasMPInterlocked.Add({$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(fHead),{$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(1));
 Slot:=@fSlots[Idx(OldHead)];

 // Wait for the consumer to finish the previous round if needed
 DesiredTurn:=TurnOf(OldHead) shl 1;
 repeat
{$if defined(CPU386) or defined(CPUx86_64)}
  TPasMPMemoryBarrier.ReadDependency;
{$else}
  TPasMPMemoryBarrier.Read;
{$ifend}
  SlotTurn:=Slot^.fTurn; // SlotTurn:=TPasMPInterlocked.Read({$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(Slot^.fTurn));
 until SlotTurn=DesiredTurn;

 // Construct the item
 Slot^.fData:=aValue;

 // Release: indicate that the slot now holds a valid item (turn+1).
 // memory_order_release -> we do a memory barrier or store
 TPasMPMemoryBarrier.Write;  // or TPasMPMemoryBarrier.ReadWrite;
 Slot^.fTurn:=DesiredTurn+1; //TPasMPInterlocked.Write(Slot^.fTurn,DesiredTurn+1);

end;

function TPasMPMultipleProducerMultipleConsumerQueue<T>.TryEnqueue(const aValue:T):Boolean;
var HeadSnapshot,SlotTurn,DesiredTurn,PreviousHeadSnapshot:TPasMPSizeUIntEx;
    Slot:PSlot;
begin

 result:=false;

 // Read the local head
{$if defined(CPU386) or defined(CPUx86_64)}
 TPasMPMemoryBarrier.ReadDependency;
{$else}
 TPasMPMemoryBarrier.Read;
{$ifend}
 HeadSnapshot:=fHead; // HeadSnapshot:=TPasMPInterlocked.Read(fHead);

 // The loop
 while true do begin

  Slot:=@fSlots[Idx(HeadSnapshot)];
  DesiredTurn:=TurnOf(HeadSnapshot) shl 1;
{$if defined(CPU386) or defined(CPUx86_64)}
  TPasMPMemoryBarrier.ReadDependency;
{$else}
  TPasMPMemoryBarrier.Read;
{$ifend}
  SlotTurn:=Slot^.fTurn; // SlotTurn:=TPasMPInterlocked.Read({$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(Slot^.fTurn));

  // If the slot is indeed ready to store
  if SlotTurn=DesiredTurn then begin
   // Attempt to claim by CAS the head
   if TPasMPInterlocked.CompareExchange({$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(fHead),{$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(HeadSnapshot+1),{$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(HeadSnapshot))={$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(HeadSnapshot) then begin
    // We succeeded, now place the item
    Slot^.fData:=aValue;
    TPasMPMemoryBarrier.Write;
    Slot^.fTurn:=DesiredTurn+1; // TPasMPInterlocked.Write({$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(Slot^.fTurn),{$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(DesiredTurn+1));
    result:=true;
   end else begin
    // If CAS failed, someone else advanced head, so re-read and try again
{$if defined(CPU386) or defined(CPUx86_64)}
    TPasMPMemoryBarrier.ReadDependency;
{$else}
    TPasMPMemoryBarrier.Read;
{$ifend}
    HeadSnapshot:=fHead; // HeadSnapshot:=TPasMPInterlocked.Read({$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(fHead));
   end;
  end else begin
   // The slot is not ready -> queue is full or behind. Re-read head to see if it changed; if not, just fail
   PreviousHeadSnapshot:=HeadSnapshot;
{$if defined(CPU386) or defined(CPUx86_64)}
   TPasMPMemoryBarrier.ReadDependency;
{$else}
   TPasMPMemoryBarrier.Read;
{$ifend}
   HeadSnapshot:=fHead; // HeadSnapshot:=TPasMPInterlocked.Read({$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(fHead));
   if HeadSnapshot=PreviousHeadSnapshot then begin
    result:=false;
    exit;
   end else begin
    // try again
   end;
  end;
 end;

end;

procedure TPasMPMultipleProducerMultipleConsumerQueue<T>.Dequeue(out aValue:T);
var OldTail,SlotTurn,DesiredTurn:TPasMPSizeUIntEx;
    Slot:PSlot;
begin

// Atomically increment FTail
 OldTail:=TPasMPInterlocked.Add({$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(fTail),{$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(1));
 Slot:=@fSlots[Idx(OldTail)];

 // We expect the slot turn to be: turn(OldTail)*2 + 1
 DesiredTurn:=(TurnOf(OldTail) shl 1) or 1;

 repeat
{$if defined(CPU386) or defined(CPUx86_64)}
  TPasMPMemoryBarrier.ReadDependency;
{$else}
  TPasMPMemoryBarrier.Read;
{$ifend}
  SlotTurn:=Slot^.fTurn; // SlotTurn:=TPasMPInterlocked.Read({$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(Slot^.fTurn));
 until SlotTurn=DesiredTurn;

 // Acquire barrier
 TPasMPMemoryBarrier.Read;
 aValue:=Slot^.fData;
 Finalize(Slot^.fData);

 // Mark slot free => DesiredTurn + 1
//TPasMPInterlocked.Write({$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(Slot^.fTurn),{$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(DesiredTurn+1));
 TPasMPMemoryBarrier.Write;
 Slot^.fTurn:=DesiredTurn+1;

end;

function TPasMPMultipleProducerMultipleConsumerQueue<T>.TryDequeue(out AValue:T):Boolean;
var TailSnapshot,SlotTurn,DesiredTurn,PreviousTailSnapshot:TPasMPSizeUIntEx;
    Slot:PSlot;
begin

 result:=false;

{$if defined(CPU386) or defined(CPUx86_64)}
 TPasMPMemoryBarrier.ReadDependency;
{$else}
 TPasMPMemoryBarrier.Read;
{$ifend}
 TailSnapshot:=fTail; //TailSnapshot:=TPasMPInterlocked.Read({$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(fTail));
 TPasMPMemoryBarrier.ReadDependency;

 while true do begin

  Slot:=@fSlots[Idx(TailSnapshot)];
  DesiredTurn:=(TurnOf(TailSnapshot) shl 1) or 1;
{$if defined(CPU386) or defined(CPUx86_64)}
  TPasMPMemoryBarrier.ReadDependency;
{$else}
  TPasMPMemoryBarrier.Read;
{$ifend}
  SlotTurn:=Slot^.fTurn; //SlotTurn:=TPasMPInterlocked.Read(Slot^.fTurn);
  TPasMPMemoryBarrier.ReadDependency;

  if SlotTurn=DesiredTurn then begin
   // Attempt to claim the slot by CAS
   if TPasMPInterlocked.CompareExchange({$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(fTail),{$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(TailSnapshot+1),{$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(TailSnapshot))={$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(TailSnapshot) then begin
    TPasMPMemoryBarrier.Read;
    aValue:=Slot^.fData;
    Finalize(Slot^.fData);
    Slot^.fTurn:=DesiredTurn+1; //TPasMPInterlocked.Write({$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(Slot^.fTurn),{$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(DesiredTurn+1));
{$if not (defined(CPU386) or defined(CPUx86_64))}
    TPasMPMemoryBarrier.Write;
{$ifend}
    result:=true;
    exit;
   end else begin
    // Another consumer got it first
{$if defined(CPU386) or defined(CPUx86_64)}
    TPasMPMemoryBarrier.ReadDependency;
{$else}
    TPasMPMemoryBarrier.Read;
{$ifend}
    TailSnapshot:=fTail; // TailSnapshot:=TPasMPInterlocked.Read(fTail);
    TPasMPMemoryBarrier.ReadDependency;
   end;
  end else begin
   // Slot doesn't hold a valid item; if fTail hasn't changed, queue is empty
   PreviousTailSnapshot:=TailSnapshot;
{$if defined(CPU386) or defined(CPUx86_64)}
   TPasMPMemoryBarrier.ReadDependency;
{$else}
   TPasMPMemoryBarrier.Read;
{$ifend}
   TailSnapshot:=fTail; // TailSnapshot:=TPasMPInterlocked.Read({$ifdef cpu64}TPasMPUInt64{$else}TPasMPUInt32{$endif}(fTail));
   if TailSnapshot=PreviousTailSnapshot then begin
    result:=false;
    exit;
   end else begin
    // Try again
   end;
  end;
 end;

end;

function TPasMPMultipleProducerMultipleConsumerQueue<T>.Size:TPasMPSizeUIntEx;
var LocalHead,LocalTail:TPasMPSizeInt;
begin
 LocalHead:=fHead;
{$if defined(CPU386) or defined(CPUx86_64)}
 TPasMPMemoryBarrier.ReadDependency;
{$else}
 TPasMPMemoryBarrier.Read;
{$ifend}
 LocalTail:=fTail;
 result:=LocalHead-LocalTail;
end;

function TPasMPMultipleProducerMultipleConsumerQueue<T>.Empty:Boolean;
begin
 result:=Size<=0;
end;

{$endif}

constructor TPasMPHashTable.Create(const KeySize,ValueSize:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
begin
 fKeySize:=KeySize;
 fValueSize:=ValueSize;
 fItemSize:=fKeySize+fValueSize;
 inherited Create(fItemSize,AddCPUCacheLinePaddingToInternalItemDataStructure);
end;

destructor TPasMPHashTable.Destroy;
begin
 inherited Destroy;
end;

procedure TPasMPHashTable.InitializeItem(const Data:pointer);
begin
 FillChar(Data^,fItemSize,#0);
end;

procedure TPasMPHashTable.FinalizeItem(const Data:pointer);
begin
end;

procedure TPasMPHashTable.CopyItem(const Source,Destination:pointer);
begin
 Move(Source^,Destination^,fItemSize);
end;

procedure TPasMPHashTable.GetKey(const Data,Key:pointer);
begin
 Move(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Data)))^,Key^,fKeySize);
end;

procedure TPasMPHashTable.SetKey(const Data,Key:pointer);
begin
 Move(Key^,pointer(TPasMPPtrUInt(TPasMPPtrUInt(Data)))^,fKeySize);
end;

procedure TPasMPHashTable.GetValue(const Data,Value:pointer);
begin
 Move(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Data)+TPasMPPtrUInt(fKeySize)))^,Value^,fValueSize);
end;

procedure TPasMPHashTable.SetValue(const Data,Value:pointer);
begin
 Move(Value^,pointer(TPasMPPtrUInt(TPasMPPtrUInt(Data)+TPasMPPtrUInt(fKeySize)))^,fValueSize);
end;

function TPasMPHashTable.HashKey(const Key:pointer):TPasMPThreadSafeHashTableHash;
{$ifdef CPUARM}
var b:PPasMPUInt8;
    len,h,i:TPasMPUInt32;
begin
 result:=2166136261;
 len:=fKeySize;
 h:=len;
 if len>0 then begin
  b:=Key;
  while len>3 do begin
   i:=TPasMPUInt32(pointer(b)^);
   h:=(h xor i) xor $2e63823a;
   inc(h,(h shl 15) or (h shr (32-15)));
   dec(h,(h shl 9) or (h shr (32-9)));
   inc(h,(h shl 4) or (h shr (32-4)));
   dec(h,(h shl 1) or (h shr (32-1)));
   h:=h xor (h shl 2) or (h shr (32-2));
   result:=result xor i;
   inc(result,(result shl 1)+(result shl 4)+(result shl 7)+(result shl 8)+(result shl 24));
   inc(b,4);
   dec(len,4);
  end;
  if len>1 then begin
   i:=TPasMPUInt16(pointer(b)^);
   h:=(h xor i) xor $2e63823a;
   inc(h,(h shl 15) or (h shr (32-15)));
   dec(h,(h shl 9) or (h shr (32-9)));
   inc(h,(h shl 4) or (h shr (32-4)));
   dec(h,(h shl 1) or (h shr (32-1)));
   h:=h xor (h shl 2) or (h shr (32-2));
   result:=result xor i;
   inc(result,(result shl 1)+(result shl 4)+(result shl 7)+(result shl 8)+(result shl 24));
   inc(b,2);
   dec(len,2);
  end;
  if len>0 then begin
   i:=TPasMPUInt8(b^);
   h:=(h xor i) xor $2e63823a;
   inc(h,(h shl 15) or (h shr (32-15)));
   dec(h,(h shl 9) or (h shr (32-9)));
   inc(h,(h shl 4) or (h shr (32-4)));
   dec(h,(h shl 1) or (h shr (32-1)));
   h:=h xor (h shl 2) or (h shr (32-2));
   result:=result xor i;
   inc(result,(result shl 1)+(result shl 4)+(result shl 7)+(result shl 8)+(result shl 24));
  end;
 end;
 result:=result xor h;
 if result=0 then begin
  result:=$ffffffff;
 end;
end;
{$else}
const m=TPasMPUInt32($57559429);
      n=TPasMPUInt32($5052acdb);
var b:PPasMPUInt8;
    h,k,len:TPasMPUInt32;
    p:{$ifdef fpc}qword{$else}TPasMPInt64{$endif};
begin
 len:=fKeySize;
 h:=len;
 k:=h+n+1;
 if len>0 then begin
  b:=Key;
  while len>7 do begin
   begin
    p:=TPasMPUInt32(pointer(b)^)*{$ifdef fpc}qword{$else}TPasMPInt64{$endif}(n);
    h:=h xor TPasMPUInt32(p and $ffffffff);
    k:=k xor TPasMPUInt32(p shr 32);
    inc(b,4);
   end;
   begin
    p:=TPasMPUInt32(pointer(b)^)*{$ifdef fpc}qword{$else}TPasMPInt64{$endif}(m);
    k:=k xor TPasMPUInt32(p and $ffffffff);
    h:=h xor TPasMPUInt32(p shr 32);
    inc(b,4);
   end;
   dec(len,8);
  end;
  if len>3 then begin
   p:=TPasMPUInt32(pointer(b)^)*{$ifdef fpc}qword{$else}TPasMPInt64{$endif}(n);
   h:=h xor TPasMPUInt32(p and $ffffffff);
   k:=k xor TPasMPUInt32(p shr 32);
   inc(b,4);
   dec(len,4);
  end;
  if len>0 then begin
   if len>1 then begin
    p:=TPasMPUInt16(pointer(b)^);
    inc(b,2);
    dec(len,2);
   end else begin
    p:=0;
   end;
   if len>0 then begin
    p:=p or (TPasMPUInt8(b^) shl 16);
   end;
   p:=p*{$ifdef fpc}qword{$else}TPasMPInt64{$endif}(m);
   k:=k xor TPasMPUInt32(p and $ffffffff);
   h:=h xor TPasMPUInt32(p shr 32);
  end;
 end;
 begin
  p:=(h xor (k+n))*{$ifdef fpc}qword{$else}TPasMPInt64{$endif}(n);
  h:=h xor TPasMPUInt32(p and $ffffffff);
  k:=k xor TPasMPUInt32(p shr 32);
 end;
 result:=k xor h;
 if result=0 then begin
  result:=$ffffffff;
 end;
end;
{$endif}

function TPasMPHashTable.CompareKey(const Data,Key:pointer):boolean;
{$ifdef OldDelphi}
type PLongwords=^TLongwords;
     TLongwords=array[0..$ffff] of TPasMPUInt32;
     PBytes=^TBytes;
     TBytes=array[0..$ffff] of TPasMPUInt8;
var Index:TPasMPInt32;
begin
 for Index:=0 to (fKeySize div SizeOf(TPasMPUInt32))-1 do begin
  if PLongwords(pointer(Data))^[Index]<>PLongwords(pointer(Key))^[Index] then begin
   result:=false;
   exit;
  end;
 end;
 for Index:=(fKeySize and not (SizeOf(TPasMPUInt32)-1)) to fKeySize-1 do begin
  if PBytes(pointer(Data))^[Index]<>PBytes(pointer(Key))^[Index] then begin
   result:=false;
   exit;
  end;
 end;
 result:=true;
end;
{$else}
begin
 result:=CompareMem(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Data))),Key,fKeySize);
end;
{$endif}

function TPasMPHashTable.GetKeyValue(const Key;out Value):boolean;
begin
 result:=inherited GetKeyValue(@Key,@Value);
end;

function TPasMPHashTable.SetKeyValue(const Key,Value):boolean;
begin
 result:=inherited SetKeyValue(@Key,@Value);
end;

function TPasMPHashTable.DeleteKey(const Key):boolean;
begin
 result:=inherited DeleteKey(@Key);
end;

constructor TPasMPStringHashTable.Create(const ValueSize:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
begin
 fKeySize:=SizeOf(string);
 fValueSize:=ValueSize;
 fItemSize:=fKeySize+fValueSize;
 inherited Create(fItemSize,AddCPUCacheLinePaddingToInternalItemDataStructure);
end;

destructor TPasMPStringHashTable.Destroy;
begin
 inherited Destroy;
end;

procedure TPasMPStringHashTable.InitializeItem(const Data:pointer);
begin
 Initialize(string(Data^));
end;

procedure TPasMPStringHashTable.FinalizeItem(const Data:pointer);
begin
 Finalize(string(Data^));
end;

procedure TPasMPStringHashTable.CopyItem(const Source,Destination:pointer);
begin
 string(Destination^):=string(Source^);
 Move(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Source)+TPasMPPtrUInt(fKeySize)))^,pointer(TPasMPPtrUInt(TPasMPPtrUInt(Destination)+TPasMPPtrUInt(fKeySize)))^,fValueSize);
end;

procedure TPasMPStringHashTable.GetKey(const Data,Key:pointer);
begin
 string(Key^):=string(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Data)))^);
end;

procedure TPasMPStringHashTable.SetKey(const Data,Key:pointer);
begin
 string(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Data)))^):=string(Key^);
end;

procedure TPasMPStringHashTable.GetValue(const Data,Value:pointer);
begin
 Move(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Data)+TPasMPPtrUInt(fKeySize)))^,Value^,fValueSize);
end;

procedure TPasMPStringHashTable.SetValue(const Data,Value:pointer);
begin
 Move(Value^,pointer(TPasMPPtrUInt(TPasMPPtrUInt(Data)+TPasMPPtrUInt(fKeySize)))^,fValueSize);
end;

function TPasMPStringHashTable.HashKey(const Key:pointer):TPasMPThreadSafeHashTableHash;
var Index:TPasMPInt32;
begin
 result:=length(string(Key^));
 for Index:=1 to length(string(Key^)) do begin
  result:=((result shl 27) or (result shl 5))+ord(string(Key^)[Index]);
 end;
 if result=0 then begin
  result:=$ffffffff;
 end;
end;

function TPasMPStringHashTable.CompareKey(const Data,Key:pointer):boolean;
begin
 result:=string(Data^)=string(Key^);
end;

function TPasMPStringHashTable.GetKeyValue(const Key:string;out Value):boolean;
begin
 result:=inherited GetKeyValue(@Key,@Value);
end;

function TPasMPStringHashTable.SetKeyValue(const Key:string;const Value):boolean;
begin
 result:=inherited SetKeyValue(@Key,@Value);
end;

function TPasMPStringHashTable.DeleteKey(const Key:string):boolean;
begin
 result:=inherited DeleteKey(@Key);
end;

constructor TPasMPStringStringHashTable.Create(const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
begin
 fKeySize:=SizeOf(string);
 fValueSize:=SizeOf(string);
 fItemSize:=fKeySize+fValueSize;
 inherited Create(fItemSize,AddCPUCacheLinePaddingToInternalItemDataStructure);
end;

destructor TPasMPStringStringHashTable.Destroy;
begin
 inherited Destroy;
end;

procedure TPasMPStringStringHashTable.InitializeItem(const Data:pointer);
begin
 Initialize(string(Data^));
 Initialize(string(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Data)+TPasMPPtrUInt(fKeySize)))^));
end;

procedure TPasMPStringStringHashTable.FinalizeItem(const Data:pointer);
begin
 Finalize(string(Data^));
 Finalize(string(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Data)+TPasMPPtrUInt(fKeySize)))^));
end;

procedure TPasMPStringStringHashTable.CopyItem(const Source,Destination:pointer);
begin
 string(Destination^):=string(Source^);
 string(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Destination)+TPasMPPtrUInt(fKeySize)))^):=string(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Source)+TPasMPPtrUInt(fKeySize)))^);
end;

procedure TPasMPStringStringHashTable.GetKey(const Data,Key:pointer);
begin
 string(Key^):=string(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Data)))^);
end;

procedure TPasMPStringStringHashTable.SetKey(const Data,Key:pointer);
begin
 string(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Data)))^):=string(Key^);
end;

procedure TPasMPStringStringHashTable.GetValue(const Data,Value:pointer);
begin
 string(Value^):=string(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Data)+TPasMPPtrUInt(fKeySize)))^);
end;

procedure TPasMPStringStringHashTable.SetValue(const Data,Value:pointer);
begin
 string(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Data)+TPasMPPtrUInt(fKeySize)))^):=string(Value^);
end;

function TPasMPStringStringHashTable.HashKey(const Key:pointer):TPasMPThreadSafeHashTableHash;
var Index:TPasMPInt32;
begin
 result:=length(string(Key^));
 for Index:=1 to length(string(Key^)) do begin
  result:=((result shl 27) or (result shl 5))+ord(string(Key^)[Index]);
 end;
 if result=0 then begin
  result:=$ffffffff;
 end;
end;

function TPasMPStringStringHashTable.CompareKey(const Data,Key:pointer):boolean;
begin
 result:=string(Data^)=string(Key^);
end;

function TPasMPStringStringHashTable.GetKeyValue(const Key:string;out Value:string):boolean;
begin
 result:=inherited GetKeyValue(@Key,@Value);
end;

function TPasMPStringStringHashTable.SetKeyValue(const Key,Value:string):boolean;
begin
 result:=inherited SetKeyValue(@Key,@Value);
end;

function TPasMPStringStringHashTable.DeleteKey(const Key:string):boolean;
begin
 result:=inherited DeleteKey(@Key);
end;

{$ifdef HasGenericsCollections}
constructor TPasMPHashTable<KeyType,ValueType>.Create(const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
begin
 fKeySize:=SizeOf(KeyType);
 fValueSize:=SizeOf(ValueType);
 fItemSize:=fKeySize+fValueSize;
 fComparer:=TEqualityComparer<KeyType>.Default;
 inherited Create(fItemSize,AddCPUCacheLinePaddingToInternalItemDataStructure);
end;

destructor TPasMPHashTable<KeyType,ValueType>.Destroy;
begin
 inherited Destroy;
end;

procedure TPasMPHashTable<KeyType,ValueType>.InitializeItem(const Data:pointer);
begin
 Initialize(KeyType(Data^));
 Initialize(ValueType(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Data)+TPasMPPtrUInt(fKeySize)))^));
end;

procedure TPasMPHashTable<KeyType,ValueType>.FinalizeItem(const Data:pointer);
begin
 Finalize(KeyType(Data^));
 Finalize(ValueType(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Data)+TPasMPPtrUInt(fKeySize)))^));
end;

procedure TPasMPHashTable<KeyType,ValueType>.CopyItem(const Source,Destination:pointer);
begin
 KeyType(Destination^):=KeyType(Source^);
 ValueType(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Destination)+TPasMPPtrUInt(fKeySize)))^):=ValueType(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Source)+TPasMPPtrUInt(fKeySize)))^);
end;

procedure TPasMPHashTable<KeyType,ValueType>.GetKey(const Data,Key:pointer);
begin
 KeyType(Key^):=KeyType(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Data)))^);
end;

procedure TPasMPHashTable<KeyType,ValueType>.SetKey(const Data,Key:pointer);
begin
 KeyType(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Data)))^):=KeyType(Key^);
end;

procedure TPasMPHashTable<KeyType,ValueType>.GetValue(const Data,Value:pointer);
begin
 ValueType(Value^):=ValueType(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Data)+TPasMPPtrUInt(fKeySize)))^);
end;

procedure TPasMPHashTable<KeyType,ValueType>.SetValue(const Data,Value:pointer);
begin
 ValueType(pointer(TPasMPPtrUInt(TPasMPPtrUInt(Data)+TPasMPPtrUInt(fKeySize)))^):=ValueType(Value^);
end;

function TPasMPHashTable<KeyType,ValueType>.HashKey(const Key:pointer):TPasMPThreadSafeHashTableHash;
begin
 result:=fComparer.GetHashCode(KeyType(Key^));
 if result=0 then begin
  result:=$ffffffff;
 end;
end;

function TPasMPHashTable<KeyType,ValueType>.CompareKey(const Data,Key:pointer):boolean;
begin
 result:=fComparer.Equals(KeyType(Data^),KeyType(Key^));
end;

{$ifdef fpc}
procedure TPasMPHashTable<KeyType,ValueType>.Dummy(out Value:ValueType);
begin
 // "Warning: Variable "Value" does not seem to be initialized" anti-warning workaround for FPC
end;
{$endif}

function TPasMPHashTable<KeyType,ValueType>.GetKeyValue(const Key:KeyType;out Value:ValueType):boolean;
begin
{$ifdef fpc}
 Dummy(Value);
{$endif}
 result:=inherited GetKeyValue(@Key,@Value);
end;

function TPasMPHashTable<KeyType,ValueType>.SetKeyValue(const Key:KeyType;const Value:ValueType):boolean;
begin
 result:=inherited SetKeyValue(@Key,@Value);
end;

function TPasMPHashTable<KeyType,ValueType>.DeleteKey(const Key:KeyType):boolean;
begin
 result:=inherited DeleteKey(@Key);
end;
{$endif}

constructor TPasMPDynamicArray.Create(const aItemSize:TPasMPInt32;const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
begin
 inherited Create(aItemSize,AddCPUCacheLinePaddingToInternalItemDataStructure);
end;

destructor TPasMPDynamicArray.Destroy;
begin
 inherited Destroy;
end;

procedure TPasMPDynamicArray.InitializeItem(const ItemData:pointer);
begin
end;

procedure TPasMPDynamicArray.FinalizeItem(const ItemData:pointer);
begin
end;

procedure TPasMPDynamicArray.CopyItem(const Source,Destination:pointer);
begin
 Move(Source^,Destination^,ItemSize);
end;

function TPasMPDynamicArray.GetItem(const ItemIndex:TPasMPInt32;out ItemData):boolean;
begin
 result:=inherited GetItem(ItemIndex,@ItemData);
end;

function TPasMPDynamicArray.SetItem(const ItemIndex:TPasMPInt32;const ItemData):boolean;
begin
 result:=inherited SetItem(ItemIndex,@ItemData);
end;

function TPasMPDynamicArray.Push(const ItemData):TPasMPInt32;
begin
 result:=inherited Push(@ItemData);
end;

function TPasMPDynamicArray.Pop(out ItemData):boolean;
begin
 result:=inherited Pop(@ItemData);
end;

{$ifdef HAS_GENERICS}
constructor TPasMPDynamicArray<T>.Create(const AddCPUCacheLinePaddingToInternalItemDataStructure:boolean=true);
begin
 inherited Create(SizeOf(T),AddCPUCacheLinePaddingToInternalItemDataStructure);
end;

destructor TPasMPDynamicArray<T>.Destroy;
begin
 inherited Destroy;
end;

procedure TPasMPDynamicArray<T>.InitializeItem(const ItemData:pointer);
begin
 Initialize(PPasMPDynamicArrayDataType(ItemData)^);
end;

procedure TPasMPDynamicArray<T>.FinalizeItem(const ItemData:pointer);
begin
 Finalize(PPasMPDynamicArrayDataType(ItemData)^);
end;

procedure TPasMPDynamicArray<T>.CopyItem(const Source,Destination:pointer);
begin
 PPasMPDynamicArrayDataType(Destination)^:=PPasMPDynamicArrayDataType(Source)^;
end;

function TPasMPDynamicArray<T>.GetItem(const ItemIndex:TPasMPInt32;out ItemData:T):boolean;
begin
 result:=inherited GetItem(ItemIndex,@ItemData);
end;

function TPasMPDynamicArray<T>.SetItem(const ItemIndex:TPasMPInt32;const ItemData:T):boolean;
begin
 result:=inherited SetItem(ItemIndex,@ItemData);
end;

function TPasMPDynamicArray<T>.Push(const ItemData:T):TPasMPInt32;
begin
 result:=inherited Push(@ItemData);
end;

function TPasMPDynamicArray<T>.Pop(out ItemData:T):boolean;
begin
 result:=inherited Pop(@ItemData);
end;

function TPasMPDynamicArray<T>.GetPropertyItem(const ItemIndex:TPasMPInt32):T;
begin
//Initialize(result); // <= should insert the compiler itself automatically
 if not inherited GetItem(ItemIndex,@result) then begin
  raise EPasMPDynamicArrayOutOfBounds.Create('Out of bounds');
 end;
end;

procedure TPasMPDynamicArray<T>.SetPropertyItem(const ItemIndex:TPasMPInt32;const ItemData:T);
begin
 if not inherited SetItem(ItemIndex,@ItemData) then begin
  raise EPasMPDynamicArrayOutOfBounds.Create('Out of bounds');
 end;
end;
{$endif}

{$if defined(fpc) and (defined(Linux) or defined(Android)) and declared(TThreadPriority)}

{$if not declared(pthread_t)}
type pthread_t=ptruint;
{$ifend}

{$if not (declared(Psched_param) and declared(Tsched_param) and declared(sched_param))}
type sched_param=record
      sched_priority:TPasMPInt32;
     end;
     Tsched_param=sched_param;
     Psched_param=^Tsched_param;
{$ifend}

{$if not declared(sched_get_priority_min)}
function sched_get_priority_min(policy:TPasMPInt32):TPasMPInt32; cdecl; external 'c' name 'sched_get_priority_min';
{$ifend}

{$if not declared(sched_get_priority_max)}
function sched_get_priority_max(policy:TPasMPInt32):TPasMPInt32; cdecl; external 'c' name 'sched_get_priority_max';
{$ifend}

{$if not declared(pthread_getschedparam)}
function pthread_getschedparam(thread:pthread_t;policy:PPasMPInt32;param:Psched_param):TPasMPInt32; cdecl; external 'c' name 'pthread_getschedparam';
{$ifend}

{$if not declared(pthread_setschedparam)}
function pthread_setschedparam(thread:pthread_t;policy:TPasMPInt32;param:Psched_param):TPasMPInt32; cdecl; external 'c' name 'pthread_getschedparam';
{$ifend}

// A mapping of TThreadPriority to POSIX thread priorities as normalized-scaled 10 bit resolution (1024 levels) values
const POSIXPriorities:array[TThreadPriority] of TPasMPInt32=
       (
        0,    // tpIdle, THREAD_PRIORITY_IDLE, lowest possible priority, 0/6 = 0.00% * 1024 ~= 0
        171,  // tpLowest, THREAD_PRIORITY_LOWEST, low priority, 1/6 = 16.66% * 1024 ~= 171
        341,  // tpLower, THREAD_PRIORITY_BELOW_NORMAL, below-normal priority, 2/6 = 33.33% * 1024 ~= 341
        512,  // tpNormal, THREAD_PRIORITY_NORMAL, normal priority, 3/6 = 50.00% * 1024 ~= 512
        683,  // tpHigher, THREAD_PRIORITY_ABOVE_NORMAL, above-normal priority, 4/6 = 66.66% * 1024 ~= 683
        853,  // tpHighest, THREAD_PRIORITY_HIGHEST, high priority, 5/6 = 83.33% * 1024 ~= 853
        1024  // tpTimeCritical, THREAD_PRIORITY_TIME_CRITICAL, highest possible priority, 6/6 = 100.00% * 1024 ~= 1024
       );

function TPasMPThread.GetPriority:TThreadPriority;
var Policy,MinPriority,MaxPriority,ScaledPriority,BestDifference,Difference:TPasMPInt32;
    Param:Tsched_param;
    CurrentPriority:TThreadPriority;
begin

 if GlobalPasMPOverrideThreadPriorityFunctions then begin

  // Default to tpNormal
  result:=TThreadPriority.tpNormal;

  // Initialize Param with zero
  Param.sched_priority:=0;

  // Get the current scheduling policy and priority
  if (Handle<>0) and (pthread_getschedparam(Handle,@Policy,@Param)=0) then begin

   // Get the minimum and maximum priority levels for the current policy
   MinPriority:=sched_get_priority_min(Policy);
   MaxPriority:=sched_get_priority_max(Policy);

   // Check if the priority range is valid, because both MinPriority and MaxPriority could be the same value, for example at SCHED_OTHER policy
   if MinPriority<MaxPriority then begin

    // Calculate scaled priority to a 10 bit resolution (1024 levels) value (with halfway rounding)
    ScaledPriority:=((TPasMPInt64(Param.sched_priority-MinPriority) shl 10)+(((MaxPriority-MinPriority)+1) shr 1)) div (MaxPriority-MinPriority);

    // Find the closest priority level
    BestDifference:=High(TPasMPInt32);

    // Iterate over all possible priorities
    for CurrentPriority:=Low(TThreadPriority) to High(TThreadPriority) do begin

     // Calculate the absolute difference
     Difference:=abs(POSIXPriorities[CurrentPriority]-ScaledPriority);

     // Check if the current difference is better than the best difference
     if BestDifference>Difference then begin

      // Update the best difference
      BestDifference:=Difference;

      // Update the result with the current priority
      result:=CurrentPriority;

      // Check if the best difference is zero
      if BestDifference=0 then begin
       break; // If it is the case, we can't get any better and we can stop the search
      end;

     end;

    end;

   end;

  end;

 end else begin

  result:=inherited Priority;

 end;

end;

procedure TPasMPThread.SetPriority(Value:TThreadPriority);
var Policy,MinPriority,MaxPriority,ScaledPriority:TPasMPInt32;
    Param:Tsched_param;
begin

 if GlobalPasMPOverrideThreadPriorityFunctions then begin

  // Initialize Param with zero
  Param.sched_priority:=0;

  // Get the current scheduling policy and priority
  if (Handle<>0) and (pthread_getschedparam(Handle,@Policy,@Param)=0) then begin

   // Get the minimum and maximum priority levels for the current policy
   MinPriority:=sched_get_priority_min(Policy);
   MaxPriority:=sched_get_priority_max(Policy);

   // Check if the priority range is valid, because both MinPriority and MaxPriority could be the same value, for example at SCHED_OTHER policy
   if MinPriority<MaxPriority then begin

    // Calculate back-scaled priority from a 10 bit resolution (1024 levels) value (with halfway rounding) and restrict it to the valid range
    ScaledPriority:=Min(Max(MinPriority+(((TPasMPInt64(MaxPriority-MinPriority)*POSIXPriorities[Value])+512) shr 10),MinPriority),MaxPriority);

    // Check if the priority has changed at all
    if Param.sched_priority<>ScaledPriority then begin

     // If yes, set the new priority to Param
     Param.sched_priority:=ScaledPriority;

     // And set the new scheduling policy and priority
     if pthread_setschedparam(Handle,Policy,@Param)=0 then begin

      // Success (nothing to do)

     end else begin

      // Error (maybe raise exception?)

     end;

    end;

   end;

  end;

 end else begin

  inherited Priority:=Value;

 end;

end;
{$ifend}

constructor TPasMPJobTask.Create;
begin
 inherited Create;
 fFreeOnRelease:=false;
 fJob:=nil;
 fThreadIndex:=-1;
 fJobTag:=0;
end;

destructor TPasMPJobTask.Destroy;
begin
 inherited Destroy;
end;

procedure TPasMPJobTask.Run;
begin
end;

function TPasMPJobTask.Split:TPasMPJobTask;
begin
 result:=nil;
end;

function TPasMPJobTask.PartialPop:TPasMPJobTask;
begin
 result:=nil;
end;

function TPasMPJobTask.Spread:boolean;
begin
 result:=false;
end;

constructor TPasMPJobAllocator.Create(const AJobWorkerThread:TPasMPJobWorkerThread);
begin
 inherited Create;
 fJobWorkerThread:=AJobWorkerThread;
 fMemoryPoolBuckets:=nil;
 fCountMemoryPoolBuckets:=1;
 SetLength(fMemoryPoolBuckets,fCountMemoryPoolBuckets);
 TPasMPMemory.AllocateAlignedMemory(fMemoryPoolBuckets[0],SizeOf(TPasMPJobAllocatorMemoryPoolBucket),SizeOf(TPasMPJob));
 fCountAllocatedJobs:=0;
 fFreeJobs:=TPasMPThreadSafeStack.Create;
end;

destructor TPasMPJobAllocator.Destroy;
var MemoryPoolBucketIndex:TPasMPInt32;
begin
 for MemoryPoolBucketIndex:=0 to fCountMemoryPoolBuckets-1 do begin
  TPasMPMemory.FreeAlignedMemory(fMemoryPoolBuckets[MemoryPoolBucketIndex]);
 end;
 SetLength(fMemoryPoolBuckets,0);
 fFreeJobs.Free;
 inherited Destroy;
end;

procedure TPasMPJobAllocator.AllocateNewBuckets(const NewCountMemoryPoolBuckets:TPasMPInt32);
var OldCountMemoryPoolBuckets,MemoryPoolBucketIndex:TPasMPInt32;
begin
 OldCountMemoryPoolBuckets:=fCountMemoryPoolBuckets;
 fCountMemoryPoolBuckets:=TPasMPMath.RoundUpToPowerOfTwo(NewCountMemoryPoolBuckets);
 if OldCountMemoryPoolBuckets<fCountMemoryPoolBuckets then begin
  SetLength(fMemoryPoolBuckets,fCountMemoryPoolBuckets);
  for MemoryPoolBucketIndex:=OldCountMemoryPoolBuckets to fCountMemoryPoolBuckets-1 do begin
   TPasMPMemory.AllocateAlignedMemory(fMemoryPoolBuckets[MemoryPoolBucketIndex],SizeOf(TPasMPJobAllocatorMemoryPoolBucket),SizeOf(TPasMPJob));
  end;
 end else begin
  fCountMemoryPoolBuckets:=OldCountMemoryPoolBuckets;
 end;
end;

function TPasMPJobAllocator.AllocateJob:PPasMPJob;
var JobIndex,MemoryPoolBucketIndex:TPasMPInt32;
begin
 result:=fFreeJobs.Pop;
 if not assigned(result) then begin
  JobIndex:=fCountAllocatedJobs;
  inc(fCountAllocatedJobs);
  MemoryPoolBucketIndex:=JobIndex shr PasMPAllocatorPoolBucketBits;
  if fCountMemoryPoolBuckets<=MemoryPoolBucketIndex then begin
   AllocateNewBuckets(MemoryPoolBucketIndex+1);
  end;
  result:=@fMemoryPoolBuckets[MemoryPoolBucketIndex]^[JobIndex and PasMPAllocatorPoolBucketMask];
 end;
end;

procedure TPasMPJobAllocator.FreeJobs;
begin
 fCountAllocatedJobs:=0;
 fFreeJobs.Clear;
end;

procedure TPasMPJobAllocator.FreeJob(const Job:PPasMPJob);
begin
 fFreeJobs.Push(Job);
 Job^.InternalData:=0;
end;

constructor TPasMPWorkerSystemThread.Create(const AJobWorkerThread:TPasMPJobWorkerThread);
begin
 fJobWorkerThread:=AJobWorkerThread;
 if AJobWorkerThread.fPasMPInstance.fWorkerThreadStackSize>0 then begin
  inherited Create(false,AJobWorkerThread.fPasMPInstance.fWorkerThreadStackSize);
 end else begin
  inherited Create(false);
 end;
{$ifdef HasRealTThreadPriority}
 Priority:=AJobWorkerThread.fPasMPInstance.fWorkerThreadPriority;
{$endif}
end;

destructor TPasMPWorkerSystemThread.Destroy;
begin
 inherited Destroy;
end;

procedure TPasMPWorkerSystemThread.Execute;
begin
{$ifdef HAS_NAMETHREADFORDEBUGGING}
 NameThreadForDebugging('TPasMPWorkerSystemThread');
{$endif}
 ReturnValue:=0;
{$ifdef HasRealTThreadPriority}
 Priority:=fJobWorkerThread.fPasMPInstance.fWorkerThreadPriority;
{$endif}
 fJobWorkerThread.ThreadProc;
 ReturnValue:=1;
end;

constructor TPasMPJobQueue.Create(const APasMPInstance:TPasMP);
begin
 inherited Create;
 fPasMPInstance:=APasMPInstance;
 fQueueLockState:=0;
 fQueueSize:=TPasMPMath.RoundUpToPowerOfTwo(PasMPJobQueueStartSize);
 fQueueMask:=fQueueSize-1;
 SetLength(fQueueJobs,fQueueSize);
 fQueueBottom:=0;
 fQueueTop:=0;
end;

destructor TPasMPJobQueue.Destroy;
begin
 SetLength(fQueueJobs,0);
 inherited Destroy;
end;

function TPasMPJobQueue.HasJobs:boolean;
begin
 result:=fQueueBottom>fQueueTop;
end;

procedure TPasMPJobQueue.Resize(const QueueBottom,QueueTop:TPasMPInt32);
var QueueLockState,OldMask,Index:TPasMPInt32;
    NewJobs:TPasMPJobQueueJobs;
begin
 NewJobs:=nil;
 begin
  // Acquire single-writer-side of lock
  repeat
{$if defined(CPU386) or defined(CPUx86_64)}
   TPasMPMemoryBarrier.ReadDependency;
{$else}
   TPasMPMemoryBarrier.Read;
{$ifend}
   QueueLockState:=fQueueLockState and TPasMPInt32(TPasMPUInt32($fffffffe));
   if TPasMPInterlocked.CompareExchange(fQueueLockState,QueueLockState or 1,QueueLockState)=QueueLockState then begin
    break;
   end else begin
    TPasMP.Relax;
   end;
  until false;
{$if defined(CPU386) or defined(CPUx86_64)}
  TPasMPMemoryBarrier.ReadDependency;
{$else}
  TPasMPMemoryBarrier.Read;
{$ifend}
  while fQueueLockState<>1 do begin
   TPasMP.Yield;
{$if defined(CPU386) or defined(CPUx86_64)}
   TPasMPMemoryBarrier.ReadDependency;
{$else}
   TPasMPMemoryBarrier.Read;
{$ifend}
  end;
 end;
 try
  OldMask:=fQueueMask;
  inc(fQueueSize,fQueueSize);
  fQueueMask:=fQueueSize-1;
  SetLength(NewJobs,fQueueSize);
  for Index:=QueueTop to QueueBottom do begin
   NewJobs[Index and fQueueMask]:=fQueueJobs[Index and OldMask];
  end;
  SetLength(fQueueJobs,0);
  fQueueJobs:=NewJobs;
  NewJobs:=nil;
{$ifdef CPU386}
  asm
   mfence
  end;
{$else}
  TPasMPMemoryBarrier.ReadWrite;
{$endif}
 finally
  // Release single-writer-side of lock
  TPasMPInterlocked.Exchange(fQueueLockState,0);
 end;
{$if not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.Write;
{$ifend}
end;

procedure TPasMPJobQueue.PushJob(const pJob:PPasMPJob);
var QueueBottom,QueueTop:TPasMPInt32;
begin
{$if not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.Read;
{$ifend}
 QueueBottom:=fQueueBottom;
{$if defined(CPU386) or defined(CPUx86_64)}
 TPasMPMemoryBarrier.ReadDependency;
{$else}
 TPasMPMemoryBarrier.Read;
{$ifend}
 QueueTop:=fQueueTop;
{$if defined(CPU386) or defined(CPUx86_64)}
 TPasMPMemoryBarrier.ReadDependency;
{$else}
 TPasMPMemoryBarrier.Read;
{$ifend}
 if (QueueBottom-QueueTop)>(fQueueSize-1) then begin
  // Full queue => non-lock-free resize
  Resize(QueueBottom,QueueTop);
 end;
 fQueueJobs[QueueBottom and fQueueMask]:=pJob;
{$ifdef CPU386}
 asm
  mfence
 end;
{$else}
{$ifdef CPUx86_64}
 TPasMPMemoryBarrier.ReadWrite;
{$endif}
{$endif}
{$if defined(CPU386) or defined(CPUx86_64)}
 fQueueBottom:=QueueBottom+1;
{$else}
 TPasMPInterlocked.Exchange(fQueueBottom,QueueBottom+1);
{$ifend}
end;

function TPasMPJobQueue.PopJob:PPasMPJob;
var QueueBottom,QueueTop:TPasMPInt32;
begin
{$if not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.Read;
{$ifend}
 QueueBottom:=fQueueBottom-1;
{$if defined(CPU386) or defined(CPUx86_64)}
 TPasMPMemoryBarrier.ReadDependency;
{$else}
 TPasMPMemoryBarrier.Read;
{$ifend}
 TPasMPInterlocked.Exchange(fQueueBottom,QueueBottom);
{$ifdef CPU386}
 asm
  mfence
 end;
{$else}
 TPasMPMemoryBarrier.ReadWrite;
{$endif}
 QueueTop:=fQueueTop;
 if QueueTop<=QueueBottom then begin
{$if defined(CPU386) or defined(CPUx86_64)}
  TPasMPMemoryBarrier.ReadDependency;
{$else}
  TPasMPMemoryBarrier.Read;
{$ifend}
  result:=pointer(fQueueJobs[QueueBottom and fQueueMask]);
  if QueueTop=QueueBottom then begin
   if TPasMPInterlocked.CompareExchange(fQueueTop,QueueTop+1,QueueTop)<>QueueTop then begin
    // Failed race against steal operation
    result:=nil;
   end;
{$if defined(CPU386) or defined(CPUx86_64)}
   fQueueBottom:=QueueTop+1;
{$else}
   TPasMPInterlocked.Exchange(fQueueBottom,QueueTop+1);
{$ifend}
  end else begin
   // There's still more than one item left in the queue
  end;
 end else begin
  // Deque was already empty
{$if defined(CPU386) or defined(CPUx86_64)}
  fQueueBottom:=QueueTop;
{$else}
  TPasMPInterlocked.Exchange(fQueueBottom,QueueTop);
{$ifend}
  result:=nil;
 end;
end;

function TPasMPJobQueue.StealJob:PPasMPJob;
var QueueTop,QueueBottom,QueueLockState:TPasMPInt32;
begin
 result:=nil;

 // Try to acquire multiple-reader-side of lock
{$if not (defined(CPU386) or defined(CPUx86_64))}
 TPasMPMemoryBarrier.Read;
{$ifend}

 QueueLockState:=fQueueLockState and TPasMPInt32(TPasMPUInt32($fffffffe));
 if TPasMPInterlocked.CompareExchange(fQueueLockState,QueueLockState+2,QueueLockState)=QueueLockState then begin

  begin
{$if not (defined(CPU386) or defined(CPUx86_64))}
   TPasMPMemoryBarrier.Read;
{$ifend}
   QueueTop:=fQueueTop;
{$if defined(CPU386) or defined(CPUx86_64)}
   TPasMPMemoryBarrier.ReadDependency;
{$else}
   TPasMPMemoryBarrier.Read;
{$ifend}
   QueueBottom:=fQueueBottom;
   if QueueTop<QueueBottom then begin
    // Non-empty queue.
{$if defined(CPU386) or defined(CPUx86_64)}
    TPasMPMemoryBarrier.ReadDependency;
{$else}
    TPasMPMemoryBarrier.Read;
{$ifend}
    result:=fQueueJobs[QueueTop and fQueueMask];
    if TPasMPInterlocked.CompareExchange(fQueueTop,QueueTop+1,QueueTop)<>QueueTop then begin
     // Failed race against steal operation
     result:=nil;
    end;
   end;
  end;

  begin
   // Release multiple-reader-side of lock
   TPasMPInterlocked.Add(fQueueLockState,-2);
  end;

 end;

end;

constructor TPasMPJobWorkerThread.Create(const APasMPInstance:TPasMP;const AThreadIndex:TPasMPInt32;const aCPUAffinityMask:TPasMPUInt64);
var JobQueueIndex:TPasMPInt32;
begin
 inherited Create;
 fPasMPInstance:=APasMPInstance;
 fCPUAffinityMask:=aCPUAffinityMask;
 fJobAllocator:=TPasMPJobAllocator.Create(self);
 for JobQueueIndex:=low(TPasMPJobQueues) to high(TPasMPJobQueues) do begin
  fJobQueues[JobQueueIndex]:=TPasMPJobQueue.Create(fPasMPInstance);
 end;
 fJobQueuesUsedBitmap:=0;
 fMaxPriorityJobQueueIndex:=PasMPJobQueuePriorityHigh;
 fIsReadyEvent:=TPasMPEvent.Create(nil,false,false,'');
 fThreadIndex:=AThreadIndex;
 fCurrentJobPriority:=PasMPJobPriorityNormal;
 fDepth:=0;
 fAreaMask:=0;
 fXorShift32:=(TPasMPUInt32(AThreadIndex+1)*83492791) or 1;
 if (fThreadIndex>0) or fPasMPInstance.fAllWorkerThreadsHaveOwnSystemThreads then begin
  fSystemThread:=TPasMPWorkerSystemThread.Create(self);
 end else begin
  fSystemThread:=nil;
  ThreadInitialization;
 end;
end;

destructor TPasMPJobWorkerThread.Destroy;
var JobQueueIndex:TPasMPInt32;
begin
 if assigned(fSystemThread) then begin
  fSystemThread.Terminate;
  fPasMPInstance.WakeUpAll;
  fSystemThread.WaitFor;
  fSystemThread.Free;
 end;
 fIsReadyEvent.Free;
 for JobQueueIndex:=low(TPasMPJobQueues) to high(TPasMPJobQueues) do begin
  fJobQueues[JobQueueIndex].Free;
 end;
 fJobAllocator.Free;
 inherited Destroy;
end;

procedure TPasMPJobWorkerThread.ThreadInitialization;
var ThreadIDHash:TPasMPUInt32;
    HashJobWorkerThread:TPasMPJobWorkerThread;
{$ifdef Windows}
    CurrentThreadHandle:THANDLE;
{$else}
{$ifdef Linux}
    CPUSet:TPasMPInt64;
{$endif}
{$endif}
begin

{$ifdef PasMPHaveFPUControls}
 SetExceptionMask(fPasMPInstance.fFPUExceptionMask);
 SetPrecisionMode(fPasMPInstance.fFPUPrecisionMode);
 SetRoundMode(fPasMPInstance.fFPURoundingMode);
{$endif}

 if fCPUAffinityMask<>0 then begin

  if fPasMPInstance.fDoCPUCorePinning then begin
{$if defined(Windows)}
   CurrentThreadHandle:=GetCurrentThread;
 //SetThreadIdealProcessor(CurrentThreadHandle,fPasMPInstance.fAvailableCPUCores[fThreadIndex]);
   SetThreadAffinityMask(CurrentThreadHandle,fCPUAffinityMask);
{$elseif defined(Linux)}
   CPUSet:=TPasMPInt64(fCPUAffinityMask);
   sched_setaffinity(GetThreadID,SizeOf(CPUSet),@CPUSet);
{$ifend}
  end;

 end else if (length(fPasMPInstance.fAvailableCPUCores)>1) and
             (fThreadIndex<length(fPasMPInstance.fAvailableCPUCores)) then begin

{$if defined(Windows)}
  CurrentThreadHandle:=GetCurrentThread;
  if fPasMPInstance.fDoCPUCorePinning then begin
 //SetThreadIdealProcessor(CurrentThreadHandle,fPasMPInstance.fAvailableCPUCores[fThreadIndex]);
   SetThreadAffinityMask(CurrentThreadHandle,TPasMPUInt32(1) shl fPasMPInstance.fAvailableCPUCores[fThreadIndex]);
  end;
{$elseif defined(Linux)}
  if fPasMPInstance.fDoCPUCorePinning then begin
   CPUSet:=TPasMPInt64(1) shl fPasMPInstance.fAvailableCPUCores[fThreadIndex];
   sched_setaffinity(GetThreadID,SizeOf(CPUSet),@CPUSet);
  end;
{$ifend}

 end;

{$ifdef UseThreadLocalStorage}

{$if defined(UseThreadLocalStorageX8632) or defined(UseThreadLocalStorageX8664)}
 TLSSetValue(CurrentJobWorkerThreadTLSIndex,self);
{$else}
 CurrentJobWorkerThread:=self;
{$ifend}

{$else}

{$if (defined(NEXTGEN) or not defined(Windows)) and not defined(FPC)}
 fThreadID:=TThread.CurrentThread.ThreadID;
{$else}
 fThreadID:=GetCurrentThreadID;
{$ifend}
 ThreadIDHash:=TPasMP.GetThreadIDHash(fThreadID);

 fPasMPInstance.fJobWorkerThreadHashTableCriticalSection.Acquire;
 try
  HashJobWorkerThread:=fPasMPInstance.fJobWorkerThreadHashTable[ThreadIDHash and PasMPJobWorkerThreadHashTableMask];
  if assigned(HashJobWorkerThread) then begin
   HashJobWorkerThread.fNext:=self;
  end;
  fNext:=nil;
  fPasMPInstance.fJobWorkerThreadHashTable[ThreadIDHash and PasMPJobWorkerThreadHashTableMask]:=self;
 finally
  fPasMPInstance.fJobWorkerThreadHashTableCriticalSection.Release;
 end;
{$endif}

 fIsReadyEvent.SetEvent;

end;

{//$define AlternativeGetJobVariant}
{$ifdef AlternativeGetJobVariant}
// A prioritized GetJob implementation variant, which is based on the paper "Load Balancing Prioritized Tasks via Work-Stealing"
// by Shams Imam and Vivek Sarkar
// Optimized here by me (Benjamin Rosseaux) by replacing the boolean-arrays with uint32-variables for more effective atomic
// operations and better faster bit scan possibilities for to find the next active priority index, for example with the BSF and
// BSR machine instructions on the x86 CPU architecture
function TPasMPJobWorkerThread.GetJob:PPasMPJob;
var FoundPriorityIndex,JobQueuePriorityIndex,OtherJobWorkerThreadIndex,OtherJobWorkerThreadCounter:TPasMPInt32;
    XorShiftTemp,PriorityJobQueueBitMask,CurrentBitmap:TPasMPUInt32;
    OtherJobWorkerThread:TPasMPJobWorkerThread;
begin

 // First search for highest priority job
 if (fJobQueuesUsedBitmap and TPasMPUInt32(TPasMPUInt32(1) shl PasMPJobQueuePriorityHigh))<>0 then begin
  // Our local bitmap claim we have a job with highest priority!
  result:=fJobQueues[PasMPJobQueuePriorityHigh].PopJob;
  if assigned(result) and ((result^.InternalData and PasMPJobFlagActive)<>0) then begin
   // Found a local job to execute with highest priority
   fMaxPriorityJobQueueIndex:=PasMPJobQueuePriorityHigh;
   exit;
  end else begin
   fJobQueuesUsedBitmap:=fJobQueuesUsedBitmap and not TPasMPUInt32(TPasMPUInt32(1) shl PasMPJobQueuePriorityHigh);
  end;
 end;

 // Ensure we don't have any local job with a higher priority (in case global state is out of sync)
 CurrentBitmap:=fPasMPInstance.fGlobalJobQueuesUsedBitmap;
 if CurrentBitmap=0 then begin
  FoundPriorityIndex:=0;
 end else begin
  FoundPriorityIndex:=TPasMPMath.BitScanForward32(CurrentBitmap);
 end;
 for JobQueuePriorityIndex:=fMaxPriorityJobQueueIndex to FoundPriorityIndex-1 do begin
  PriorityJobQueueBitMask:=TPasMPUInt32(1) shl TPasMPUInt32(JobQueuePriorityIndex);
  if (fJobQueuesUsedBitmap and PriorityJobQueueBitMask)<>0 then begin
   // Our local bitmap claim we have a job with higher priority!
   result:=fJobQueues[JobQueuePriorityIndex].PopJob;
   if assigned(result) and ((result^.InternalData and PasMPJobFlagActive)<>0) then begin
    if fJobQueues[JobQueuePriorityIndex].HasJobs then begin
     TPasMPInterlocked.BitwiseOr(fPasMPInstance.fGlobalJobQueuesUsedBitmap,PriorityJobQueueBitMask);
     fMaxPriorityJobQueueIndex:=PasMPJobQueuePriorityHigh;
    end else begin
     fJobQueuesUsedBitmap:=fJobQueuesUsedBitmap and not PriorityJobQueueBitMask;
    end;
    exit;
   end else begin
    fJobQueuesUsedBitmap:=fJobQueuesUsedBitmap and not PriorityJobQueueBitMask;
   end;
  end;
 end;

 // Exhaustively search local and global pools, attempting steals
 JobQueuePriorityIndex:=FoundPriorityIndex;
 while JobQueuePriorityIndex<=PasMPJobQueuePriorityLast do begin

  PriorityJobQueueBitMask:=TPasMPUInt32(1) shl TPasMPUInt32(JobQueuePriorityIndex);

  if (fJobQueuesUsedBitmap and PriorityJobQueueBitMask)<>0 then begin
   // Our local bitmap claim we have a job
   result:=fJobQueues[JobQueuePriorityIndex].PopJob;
   if assigned(result) and ((result^.InternalData and PasMPJobFlagActive)<>0) then begin
    // Found a local job to execute
    fMaxPriorityJobQueueIndex:=JobQueuePriorityIndex;
    exit;
   end;
  end;

  // When it is not a valid job or our own queue is empty, so try stealing from some other queue
  // Find victim index and try to steal from there
  XorShiftTemp:=fXorShift32;
  XorShiftTemp:=XorShiftTemp xor (XorShiftTemp shl 13);
  XorShiftTemp:=XorShiftTemp xor (XorShiftTemp shr 17);
  XorShiftTemp:=XorShiftTemp xor (XorShiftTemp shl 5);
  fXorShift32:=XorShiftTemp;
  OtherJobWorkerThreadIndex:=((XorShiftTemp shr 16)*TPasMPUInt32(fPasMPInstance.fCountJobWorkerThreads)) shr 16;
  for OtherJobWorkerThreadCounter:=0 to fPasMPInstance.fCountJobWorkerThreads-1 do begin
   OtherJobWorkerThread:=fPasMPInstance.fJobWorkerThreads[OtherJobWorkerThreadIndex];
   if (OtherJobWorkerThread<>self) and
      ((OtherJobWorkerThread.fJobQueuesUsedBitmap and PriorityJobQueueBitMask)<>0) then begin
    // The victim bitmap claim we have a job
    result:=OtherJobWorkerThread.fJobQueues[JobQueuePriorityIndex].StealJob;
    if assigned(result) and ((result^.InternalData and PasMPJobFlagActive)<>0) then begin
     // Found a stolen job to execute
     exit;
    end;
   end;
   inc(OtherJobWorkerThreadIndex);
   if OtherJobWorkerThreadIndex>=fPasMPInstance.fCountJobWorkerThreads then begin
    OtherJobWorkerThreadIndex:=0;
   end;
  end;

  // Otherwise try stealing from the global queue
  if (fPasMPInstance.fJobQueuesUsedBitmap and PriorityJobQueueBitMask)<>0 then begin
   fPasMPInstance.fJobQueuesLock.Acquire;
   try
{$if defined(cpu386) or defined(cpux86_64)}
    TPasMPMemoryBarrier.ReadDependency;
{$else}
    TPasMPMemoryBarrier.Read;
{$ifend}
    if (fPasMPInstance.fJobQueuesUsedBitmap and PriorityJobQueueBitMask)<>0 then begin
     // The global bitmap claim we have a job
     result:=fPasMPInstance.fJobQueues[JobQueuePriorityIndex].StealJob;
     if assigned(result) and ((result^.InternalData and PasMPJobFlagActive)<>0) then begin
      // Found a stolen global job to execute
      exit;
     end else begin
      fPasMPInstance.fJobQueuesUsedBitmap:=fPasMPInstance.fJobQueuesUsedBitmap and not PriorityJobQueueBitMask;
      TPasMPMemoryBarrier.ReadWrite;
     end;
    end;
   finally
    fPasMPInstance.fJobQueuesLock.Release;
   end;
  end;

  // No job with specified priority found, attempt to update global state
  TPasMPInterlocked.BitWiseAnd(fPasMPInstance.fGlobalJobQueuesUsedBitmap,not PriorityJobQueueBitMask);

  // Try and search for task with next available priority
  CurrentBitmap:=fPasMPInstance.fGlobalJobQueuesUsedBitmap and not ((PriorityJobQueueBitMask shl 1)-1);
  if CurrentBitmap=0 then begin
   inc(JobQueuePriorityIndex);
  end else begin
   JobQueuePriorityIndex:=TPasMPMath.BitScanForward32(CurrentBitmap);
  end;

 end;

 result:=nil;
end;
{$else}
// A prioritized GetJob implementation variant, which is based completety on my own ideas, which is better structured,
// easier to understand and more pretty than the implementation above, in my opinion.
function TPasMPJobWorkerThread.GetJob:PPasMPJob;
var JobQueuePriorityIndex,OtherJobWorkerThreadIndex,OtherJobWorkerThreadCounter:TPasMPInt32;
    XorShiftTemp,PriorityJobQueueBitMask,CurrentBitmap:TPasMPUInt32;
    OtherJobWorkerThread:TPasMPJobWorkerThread;
    FirstTry:boolean;
begin

{$if not (defined(cpu386) or defined(cpux86_64))}
 TPasMPMemoryBarrier.ReadWrite;
{$ifend}
 CurrentBitmap:=fPasMPInstance.fGlobalJobQueuesUsedBitmap;
{$if not (defined(cpu386) or defined(cpux86_64))}
 TPasMPMemoryBarrier.Read;
{$ifend}

 FirstTry:=true;

 repeat

  // Ensure that the local bitmap content is inside the global bitmap content
  if (CurrentBitmap and fJobQueuesUsedBitmap)<>fJobQueuesUsedBitmap then begin
   CurrentBitmap:=TPasMPInterlocked.ExchangeBitWiseOr(fPasMPInstance.fGlobalJobQueuesUsedBitmap,fJobQueuesUsedBitmap) or fJobQueuesUsedBitmap;
  end;

  while CurrentBitmap<>0 do begin

   JobQueuePriorityIndex:=TPasMPMath.BitScanForward32(CurrentBitmap);

   PriorityJobQueueBitMask:=TPasMPUInt32(1) shl TPasMPUInt32(JobQueuePriorityIndex);

   // Try getting a job from our own queue first
   if (fJobQueuesUsedBitmap and PriorityJobQueueBitMask)<>0 then begin
    result:=fJobQueues[JobQueuePriorityIndex].PopJob;
    if assigned(result) and ((result^.InternalData and PasMPJobFlagActive)<>0) then begin
     exit;
    end else begin
     fJobQueuesUsedBitmap:=fJobQueuesUsedBitmap and not PriorityJobQueueBitMask;
    end;
   end;

   // When it is not a valid job or our own queue is empty, so try stealing from some other queue
   XorShiftTemp:=fXorShift32;
   XorShiftTemp:=XorShiftTemp xor (XorShiftTemp shl 13);
   XorShiftTemp:=XorShiftTemp xor (XorShiftTemp shr 17);
   XorShiftTemp:=XorShiftTemp xor (XorShiftTemp shl 5);
   fXorShift32:=XorShiftTemp;
   OtherJobWorkerThreadIndex:=((XorShiftTemp shr 16)*TPasMPUInt32(fPasMPInstance.fCountJobWorkerThreads)) shr 16;
   for OtherJobWorkerThreadCounter:=0 to fPasMPInstance.fCountJobWorkerThreads-1 do begin
    OtherJobWorkerThread:=fPasMPInstance.fJobWorkerThreads[OtherJobWorkerThreadIndex];
    if (OtherJobWorkerThread<>self) and
       ((OtherJobWorkerThread.fJobQueuesUsedBitmap and PriorityJobQueueBitMask)<>0) then begin
     result:=OtherJobWorkerThread.fJobQueues[JobQueuePriorityIndex].StealJob;
     if assigned(result) and ((result^.InternalData and PasMPJobFlagActive)<>0) then begin
      exit;
     end;
    end;
    inc(OtherJobWorkerThreadIndex);
    if OtherJobWorkerThreadIndex>=fPasMPInstance.fCountJobWorkerThreads then begin
     OtherJobWorkerThreadIndex:=0;
    end;
   end;

   // Otherwise try stealing from the global queue
   if (fPasMPInstance.fJobQueuesUsedBitmap and PriorityJobQueueBitMask)<>0 then begin
    fPasMPInstance.fJobQueuesLock.Acquire;
    try
{$if defined(cpu386) or defined(cpux86_64)}
     TPasMPMemoryBarrier.ReadDependency;
{$else}
     TPasMPMemoryBarrier.Read;
{$ifend}
     if (fPasMPInstance.fJobQueuesUsedBitmap and PriorityJobQueueBitMask)<>0 then begin
      result:=fPasMPInstance.fJobQueues[JobQueuePriorityIndex].StealJob;
      if assigned(result) and ((result^.InternalData and PasMPJobFlagActive)<>0) then begin
       // Yay, we've stolen a job!
       exit;
      end else begin
       fPasMPInstance.fJobQueuesUsedBitmap:=fPasMPInstance.fJobQueuesUsedBitmap and not PriorityJobQueueBitMask;
       TPasMPMemoryBarrier.ReadWrite;
      end;
     end;
    finally
     fPasMPInstance.fJobQueuesLock.Release;
    end;
   end;

   // Update the global used priority queue bit mask to signal no jobs of the specified priority were available
   TPasMPInterlocked.BitWiseAnd(fPasMPInstance.fGlobalJobQueuesUsedBitmap,not PriorityJobQueueBitMask);

   // Mask out first set bit
   CurrentBitmap:=CurrentBitmap and (CurrentBitmap-1);

  end;

  // We now realize that the global used priority queue bit mask is out of sync as none of the victims including ourself could provide a job,
  // so we should update the global used priority queue bit mask with our local used priority queue bit mask and so on
  if FirstTry then begin
   FirstTry:=false;
   CurrentBitmap:=fJobQueuesUsedBitmap or fPasMPInstance.fJobQueuesUsedBitmap;
   CurrentBitmap:=TPasMPInterlocked.ExchangeBitWiseOr(fPasMPInstance.fGlobalJobQueuesUsedBitmap,CurrentBitmap) or CurrentBitmap;
   if CurrentBitmap<>0 then begin
    // Time for a second try
    continue;
   end;
  end;

  // Otherwise, when everything had no success, we should give up
  break;

 until false;

 result:=nil;

end;
{$endif}

function TPasMPJobWorkerThread.HasJobs:boolean;
begin
 result:=fJobQueues[PasMPJobQueuePriorityHigh].HasJobs or
         fJobQueues[PasMPJobQueuePriorityNormal].HasJobs or
         fJobQueues[PasMPJobQueuePriorityLow].HasJobs;
end;

procedure TPasMPJobWorkerThread.ThreadProc;
var SpinCount,CountMaxSpinCount:TPasMPInt32;
    Job:PPasMPJob;
begin
 try
  ThreadInitialization;
  fPasMPInstance.fSystemIsReadyEvent.WaitFor(INFINITE);
  fPasMPInstance.WaitForWakeUp;
  SpinCount:=0;
  CountMaxSpinCount:=128;
  while not fSystemThread.Terminated do begin
   Job:=GetJob;
   if assigned(Job) then begin
    TPasMPInterlocked.Increment(fPasMPInstance.fWorkingJobWorkerThreads);
    fPasMPInstance.ExecuteJob(Job,self);
    TPasMPInterlocked.Decrement(fPasMPInstance.fWorkingJobWorkerThreads);
    SpinCount:=0;
   end else begin
    if SpinCount<CountMaxSpinCount then begin
     inc(SpinCount);
    end else begin
     fPasMPInstance.WaitForWakeUp;
     SpinCount:=0;
    end;
   end;
  end;
 except
  on e:Exception do begin
   if assigned(fPasMPInstance.fOnWorkerThreadException) then begin
    if not fPasMPInstance.fOnWorkerThreadException(e) then begin
     raise;
    end;
   end else begin
    raise;
   end;
  end;
 end;
end;

constructor TPasMPScope.Create(const APasMPInstance:TPasMP);
begin
 inherited Create;
 fPasMPInstance:=APasMPInstance;
 fWaitCalled:=false;
 fJobs:=nil;
 fCountJobs:=0;
end;

destructor TPasMPScope.Destroy;
begin
 if not fWaitCalled then begin
  Wait;
 end;
 fPasMPInstance.Release(fJobs);
 SetLength(fJobs,0);
 inherited Destroy;
end;

procedure TPasMPScope.Run(const Job:PPasMPJob);
begin
 fPasMPInstance.Run(Job);
 if length(fJobs)<=(fCountJobs+1) then begin
  SetLength(fJobs,(fCountJobs+1)*2);
 end;
 fJobs[fCountJobs]:=Job;
 inc(fCountJobs);
end;

procedure TPasMPScope.Run(const Jobs:array of PPasMPJob);
var Count:TPasMPInt32;
begin
 fPasMPInstance.Run(Jobs);
 Count:=length(Jobs);
 if Count>0 then begin
  if length(fJobs)<=(fCountJobs+Count) then begin
   SetLength(fJobs,(fCountJobs+Count)*2);
  end;
  Move(Jobs[0],fJobs[fCountJobs],Count*SizeOf(PPasMPJob));
  inc(fCountJobs,Count);
 end;
end;

procedure TPasMPScope.Run(const JobTask:TPasMPJobTask);
begin
 Run(fPasMPInstance.Acquire(JobTask));
end;

procedure TPasMPScope.Run(const JobTasks:array of TPasMPJobTask);
var Index:TPasMPInt32;
begin
 for Index:=0 to length(JobTasks)-1 do begin
  Run(fPasMPInstance.Acquire(JobTasks[Index]));
 end;
end;

procedure TPasMPScope.Wait;
begin
 fWaitCalled:=true;
 if fCountJobs>0 then begin
  SetLength(fJobs,fCountJobs);
  fPasMPInstance.Wait(fJobs);
 end;
end;

constructor TPasMPProfiler.Create(const pPasMPInstance:TPasMP);
begin
 inherited Create;
 fPointerToHistory:=@fHistory;
 fPasMPInstance:=pPasMPInstance;
 fHighResolutionTimer:=TPasMPHighResolutionTimer.Create;
 Reset;
end;

destructor TPasMPProfiler.Destroy;
begin
 fHighResolutionTimer.Free;
 inherited Destroy;
end;

function TPasMPProfiler.GetHistoryRingBufferItem(const pIndex:TPasMPUInt32):PPasMPProfilerHistoryRingBufferItem;
begin
 result:=@fHistory[pIndex and PasMPProfilerHistoryRingBufferSizeMask];
end;

procedure TPasMPProfiler.Sort;
type PItem=^TItem;
     TItem=TPasMPProfilerHistoryRingBufferItem;
     PItemArray=^TItemArray;
     TItemArray=array of TItem;
     PStackItem=^TStackItem;
     TStackItem=record
      Left,Right,Depth:TPasMPInt32;
     end;
 function Compare(const a,b:TPasMPProfilerHistoryRingBufferItem):TPasMPInt32;
 begin
  if a.StartTime<b.StartTime then begin
   result:=-1;
  end else if a.StartTime>b.StartTime then begin
   result:=1;
  end else if a.EndTime<b.EndTime then begin
   result:=-1;
  end else if a.EndTime>b.EndTime then begin
   result:=1;
  end else begin
   result:=0;
  end;
 end;
var Left,Right,Depth,i,j,Middle,Size,Parent,Child,Pivot,iA,iB,iC:TPasMPInt32;
    StackItem:PStackItem;
    Stack:array[0..31] of TStackItem;
    Temp:TPasMPProfilerHistoryRingBufferItem;
begin
 if fCount>0 then begin
  StackItem:=@Stack[0];
  StackItem^.Left:=0;
  StackItem^.Right:=Min(fCount-1,PasMPProfilerHistoryRingBufferSizeMask);
  StackItem^.Depth:=TPasMPMath.BitScanReverse32(StackItem^.Right+1) shl 1;
  inc(StackItem);
  while TPasMPPtrUInt(pointer(StackItem))>TPasMPPtrUInt(pointer(@Stack[0])) do begin
   dec(StackItem);
   Left:=StackItem^.Left;
   Right:=StackItem^.Right;
   Depth:=StackItem^.Depth;
   Size:=(Right-Left)+1;
   if Size<16 then begin
    // Insertion sort
    iA:=Left;
    iB:=iA+1;
    while iB<=Right do begin
     iC:=iB;
     while (iA>=Left) and
           (iC>=Left) and
           (Compare(fHistory[iA],fHistory[iC])>0) do begin
      Temp:=fHistory[iA];
      fHistory[iA]:=fHistory[iC];
      fHistory[iC]:=Temp;
      dec(iA);
      dec(iC);
     end;
     iA:=iB;
     inc(iB);
    end;
   end else begin
    if (Depth=0) or (TPasMPPtrUInt(pointer(StackItem))>=TPasMPPtrUInt(pointer(@Stack[high(Stack)-1]))) then begin
     // Heap sort
     i:=Size div 2;
     repeat
      if i>0 then begin
       dec(i);
      end else begin
       dec(Size);
       if Size>0 then begin
        Temp:=fHistory[Left+Size];
        fHistory[Left+Size]:=fHistory[Left];
        fHistory[Left]:=Temp;
       end else begin
        break;
       end;
      end;
      Parent:=i;
      repeat
       Child:=(Parent*2)+1;
       if Child<Size then begin
        if (Child<(Size-1)) and (Compare(fHistory[Left+Child],fHistory[Left+Child+1])<0) then begin
         inc(Child);
        end;
        if Compare(fHistory[Left+Parent],fHistory[Left+Child])<0 then begin
         Temp:=fHistory[Left+Parent];
         fHistory[Left+Parent]:=fHistory[Left+Child];
         fHistory[Left+Child]:=Temp;
         Parent:=Child;
         continue;
        end;
       end;
       break;
      until false;
     until false;
    end else begin
     // Quick sort width median-of-three optimization
     Middle:=Left+((Right-Left) shr 1);
     if (Right-Left)>3 then begin
      if Compare(fHistory[Left],fHistory[Middle])>0 then begin
       Temp:=fHistory[Left];
       fHistory[Left]:=fHistory[Middle];
       fHistory[Middle]:=Temp;
      end;
      if Compare(fHistory[Left],fHistory[Right])>0 then begin
       Temp:=fHistory[Left];
       fHistory[Left]:=fHistory[Right];
       fHistory[Right]:=Temp;
      end;
      if Compare(fHistory[Middle],fHistory[Right])>0 then begin
       Temp:=fHistory[Middle];
       fHistory[Middle]:=fHistory[Right];
       fHistory[Right]:=Temp;
      end;
     end;
     Pivot:=Middle;
     i:=Left;
     j:=Right;
     repeat
      while (i<Right) and (Compare(fHistory[i],fHistory[Pivot])<0) do begin
       inc(i);
      end;
      while (j>=i) and (Compare(fHistory[j],fHistory[Pivot])>0) do begin
       dec(j);
      end;
      if i>j then begin
       break;
      end else begin
       if i<>j then begin
        Temp:=fHistory[i];
        fHistory[i]:=fHistory[j];
        fHistory[j]:=Temp;
        if Pivot=i then begin
         Pivot:=j;
        end else if Pivot=j then begin
         Pivot:=i;
        end;
       end;
       inc(i);
       dec(j);
      end;
     until false;
     if i<Right then begin
      StackItem^.Left:=i;
      StackItem^.Right:=Right;
      StackItem^.Depth:=Depth-1;
      inc(StackItem);
     end;
     if Left<j then begin
      StackItem^.Left:=Left;
      StackItem^.Right:=j;
      StackItem^.Depth:=Depth-1;
      inc(StackItem);
     end;
    end;
   end;
  end;
 end;
end;

procedure TPasMPProfiler.Reset;
begin
 fCount:=0;
 fStartTime:=HighResolutionTimer.GetTime;
 fLastTime:=0;
 fOffsetTime:=fLastTime-fStartTime;
end;

procedure TPasMPProfiler.Start(const SuppressGaps:boolean=true);
begin
 if SuppressGaps then begin
  fStartTime:=HighResolutionTimer.GetTime;
  fOffsetTime:=fLastTime-fStartTime;
 end;
end;

procedure TPasMPProfiler.Stop(const MaximalTimePeriodToKeep:TPasMPHighResolutionTime=-1);
var Index,Counter:TPasMPInt32;
begin
 if fCount>0 then begin
  Sort;
  if fCount>PasMPProfilerHistoryRingBufferSize then begin
   fCount:=PasMPProfilerHistoryRingBufferSize;
  end;
  fLastTime:=fHistory[(fCount-1) and PasMPProfilerHistoryRingBufferSizeMask].EndTime;
  if MaximalTimePeriodToKeep>=0 then begin
   Counter:=0;
   for Index:=0 to fCount-1 do begin
    if (fHistory[Index].StartTime<=fLastTime) and ((fLastTime-MaximalTimePeriodToKeep)<=fHistory[Index].EndTime) then begin
     if Index<>Counter then begin
      Move(fHistory[Index],fHistory[Counter],TPasMPPtrUInt(pointer(@PPasMPProfilerHistoryRingBufferItem(nil)^.Dummy)));
     end;
     inc(Counter);
    end;
   end;
   fCount:=Counter;
  end;
 end else begin
  fLastTime:=0;
 end;
end;

function TPasMPProfiler.Acquire:PPasMPProfilerHistoryRingBufferItem;
begin
 result:=@fHistory[TPasMPUInt32(TPasMPInterlocked.Increment(TPasMPInt32(fCount))-1) and PasMPProfilerHistoryRingBufferSizeMask];
end;

constructor TPasMP.Create(const CountThreads:TPasMPInt32;
                          const MinimumCountThreads:TPasMPInt32;
                          const MaximumCountThreads:TPasMPInt32;
                          const ThreadHeadRoomForForeignTasks:TPasMPInt32;
                          const DoCPUCorePinning:boolean;
                          const SleepingOnIdle:boolean;
                          const AllWorkerThreadsHaveOwnSystemThreads:boolean;
                          const Profiling:boolean;
                          const WorkerThreadPriority:TThreadPriority;
                          const WorkerThreadStackSize:TPasMPSizeUInt;
                          const WorkerThreadMaxDepth:TPasMPUInt32);
var Index,CPUCoreIndex:TPasMPInt32;
    CPUAffinityMasks:TPasMPUInt64DynamicArray;
begin

 inherited Create;

{$ifdef PasMPHaveFPUControls}
 fFPUExceptionMask:=GetExceptionMask;
 fFPUPrecisionMode:=GetPrecisionMode;
 fFPURoundingMode:=GetRoundMode;
{$endif}

 fAvailableCPUCores:=nil;

 fDoCPUCorePinning:=DoCPUCorePinning;

 fSleepingOnIdle:=SleepingOnIdle;

 fOnWorkerThreadException:=nil;

 fOnCheckJobExecution:=nil;

 fAllWorkerThreadsHaveOwnSystemThreads:=AllWorkerThreadsHaveOwnSystemThreads;

 fWorkerThreadPriority:=WorkerThreadPriority;

 fWorkerThreadStackSize:=WorkerThreadStackSize;

 fWorkerThreadMaxDepth:=WorkerThreadMaxDepth;

 if Profiling then begin
  fProfiler:=TPasMPProfiler.Create(self);
 end else begin
  fProfiler:=nil;
 end;

{$ifdef PasMPUseGlobalPasMPCountOfHardwareThreads}
 fCountCPUThreads:=GlobalPasMPCountOfHardwareThreads;
 fAvailableCPUCores:=GlobalPasMPAvailableCPUCores;
{$else}
 fCountCPUThreads:=TPasMP.GetCountOfHardwareThreads(fAvailableCPUCores);
{$endif}

 if CountThreads>0 then begin
  fCountJobWorkerThreads:=CountThreads;
 end else begin
  fCountJobWorkerThreads:=fCountCPUThreads-ThreadHeadRoomForForeignTasks;
 end;

 if fCountJobWorkerThreads<1 then begin
  fCountJobWorkerThreads:=1;
 end;
 if (MinimumCountThreads>0) and (fCountJobWorkerThreads<MinimumCountThreads) then begin
  fCountJobWorkerThreads:=MinimumCountThreads;
 end;
 if (MaximumCountThreads>0) and (fCountJobWorkerThreads>MaximumCountThreads) then begin
  fCountJobWorkerThreads:=MaximumCountThreads;
 end;
 if fCountJobWorkerThreads>=TPasMPInt32(PasMPJobThreadIndexSize) then begin
  fCountJobWorkerThreads:=TPasMPInt32(PasMPJobThreadIndexSize-1);
 end;

 fSleepingJobWorkerThreads:=0;

 fSystemIsReadyEvent:=TPasMPEvent.Create(nil,true,false,'');

{$ifdef PasMPUseWakeUpConditionVariable}
 fWakeUpCounter:=0;
 fWakeUpConditionVariableLock:=TPasMPConditionVariableLock.Create;
 fWakeUpConditionVariable:=TPasMPConditionVariable.Create;
{$else}
 fWakeUpEvent:=TPasMPEvent.Create(nil,true,false,'');
{$endif}

 fJobWorkerThreads:=nil;
 SetLength(fJobWorkerThreads,fCountJobWorkerThreads);

 fCriticalSection:=TPasMPCriticalSection.Create;

 fJobAllocatorCriticalSection:=TPasMPCriticalSection.Create;

 fJobAllocator:=TPasMPJobAllocator.Create(nil);

 for Index:=low(TPasMPJobQueues) to high(TPasMPJobQueues) do begin
  fJobQueues[Index]:=TPasMPJobQueue.Create(self);
 end;

 fJobQueuesUsedBitmap:=0;

 fJobQueuesLock:=TPasMPSlimReaderWriterLock.Create;

 fGlobalJobQueuesUsedBitmap:=0;

{$ifndef UseThreadLocalStorage}
 fJobWorkerThreadHashTableCriticalSection:=TPasMPCriticalSection.Create;

 FillChar(fJobWorkerThreadHashTable,SizeOf(TPasMPJobWorkerThreadHashTable),#0);
{$endif}

 CPUAffinityMasks:=nil;
 try

  // Spread the worker threads over the available CPU cores for better cache locality
  SetLength(CPUAffinityMasks,fCountJobWorkerThreads);
  FillChar(CPUAffinityMasks[0],SizeOf(TPasMPUInt64)*fCountJobWorkerThreads,#0);
  if length(fAvailableCPUCores)>0 then begin
   CPUCoreIndex:=0;
   for Index:=0 to fCountJobWorkerThreads-1 do begin
    CPUAffinityMasks[Index]:=CPUAffinityMasks[Index] or (TPasMPUInt64(1) shl fAvailableCPUCores[CPUCoreIndex]);
    inc(CPUCoreIndex);
    if CPUCoreIndex>=length(fAvailableCPUCores) then begin
     CPUCoreIndex:=0;
    end;
   end;
  end;

  for Index:=0 to fCountJobWorkerThreads-1 do begin
    fJobWorkerThreads[Index]:=TPasMPJobWorkerThread.Create(self,Index,CPUAffinityMasks[Index]);
  end;
  for Index:=0 to fCountJobWorkerThreads-1 do begin
    fJobWorkerThreads[Index].fIsReadyEvent.WaitFor(INFINITE);
    FreeAndNil(fJobWorkerThreads[Index].fIsReadyEvent);
  end;
  fSystemIsReadyEvent.SetEvent;

 finally
  CPUAffinityMasks:=nil;
 end;

end;

destructor TPasMP.Destroy;
var Index:TPasMPInt32;
    JobWorkerThread:TPasMPJobWorkerThread;
begin
 for Index:=0 to fCountJobWorkerThreads-1 do begin
  JobWorkerThread:=fJobWorkerThreads[Index];
  if assigned(JobWorkerThread.fSystemThread) then begin
   JobWorkerThread.fSystemThread.Terminate;
  end;
 end;
 WakeUpAll;
 for Index:=0 to fCountJobWorkerThreads-1 do begin
  JobWorkerThread:=fJobWorkerThreads[Index];
  if assigned(JobWorkerThread.fSystemThread) then begin
   while JobWorkerThread.fSystemThread.ReturnValue=0 do begin
    WakeUpAll;
    TPasMP.Yield;
   end;
   JobWorkerThread.fSystemThread.WaitFor;
  end;
 end;
 for Index:=0 to fCountJobWorkerThreads-1 do begin
  JobWorkerThread:=fJobWorkerThreads[Index];
  if assigned(JobWorkerThread.fSystemThread) then begin
   FreeAndNil(JobWorkerThread.fSystemThread);
  end;
  JobWorkerThread.Free;
 end;
 SetLength(fJobWorkerThreads,0);
 SetLength(fAvailableCPUCores,0);
 for Index:=low(TPasMPJobQueues) to high(TPasMPJobQueues) do begin
  fJobQueues[Index].Free;
 end;
 fJobQueuesLock.Free;
 fJobAllocator.Free;
 fJobAllocatorCriticalSection.Free;
 fSystemIsReadyEvent.Free;
{$ifdef PasMPUseWakeUpConditionVariable}
 fWakeUpConditionVariable.Free;
 fWakeUpConditionVariableLock.Free;
{$else}
 fWakeUpEvent.Free;
{$endif}
{$ifndef UseThreadLocalStorage}
 fJobWorkerThreadHashTableCriticalSection.Free;
{$endif}
 fProfiler.Free;
 fCriticalSection.Free;
 inherited Destroy;
end;

class function TPasMP.CreateGlobalInstance:TPasMP;
begin
 TPasMPMemoryBarrier.Sync;
 if not assigned(GlobalPasMP) then begin
  GlobalPasMPCriticalSection.Acquire;
  try
   if not assigned(GlobalPasMP) then begin
    GlobalPasMP:=TPasMP.Create(GlobalPasMPCountThreads,
                               GlobalPasMPMinimumCountThreads,
                               GlobalPasMPMaximumCountThreads,
                               GlobalPasMPThreadHeadRoomForForeignTasks,
                               GlobalPasMPDoCPUCorePinning,
                               GlobalPasMPSleepingOnIdle,
                               GlobalPasMPAllWorkerThreadsHaveOwnSystemThreads,
                               GlobalPasMPProfiling,
                               GlobalPasMPWorkerThreadPriority,
                               GlobalPasMPWorkerThreadStackSize,
                               GlobalPasMPWorkerThreadMaxDepth);
    TPasMPMemoryBarrier.Sync;
   end;
  finally
   GlobalPasMPCriticalSection.Release;
  end;
 end;
 result:=GlobalPasMP;
end;

class procedure TPasMP.DestroyGlobalInstance;
begin
 GlobalPasMPCriticalSection.Acquire;
 try
  FreeAndNil(GlobalPasMP);
 finally
  GlobalPasMPCriticalSection.Release;
 end;
end;

class function TPasMP.GetGlobalInstance:TPasMP;
begin
 if not assigned(GlobalPasMP) then begin
  CreateGlobalInstance;
 end;
 result:=GlobalPasMP;
end;

class function TPasMP.GetCountOfPhysicalCores(out AvailableCPUCores:TPasMPAvailableCPUCores):TPasMPInt32;
{$if defined(Windows)}
var PhysicalCores,LogicalCores,i,j:TPasMPInt32;
    sinfo:SYSTEM_INFO;
    dwProcessAffinityMask,dwSystemAffinityMask:TPasMPPtrUInt;
    CPUProcessorMasks:array of TPasMPPtrUInt;
    CPUFirstLogicalCore:array of TPasMPInt32;
 procedure GetCPUInfo(var PhysicalCores,LogicalCores:TPasMPInt32);
 const RelationProcessorCore=0;
       RelationNumaNode=1;
       RelationCache=2;
       RelationProcessorPackage=3;
       RelationGroup=4;
       RelationAll=$ffff;
       CacheUnified=0;
       CacheInstruction=1;
       CacheData=2;
       CacheTrace=3;
 type TLogicalProcessorRelationship=TPasMPUInt32;
      TProcessorCacheType=TPasMPUInt32;
      TCacheDescriptor=packed record
       Level:TPasMPUInt8;
       Associativity:TPasMPUInt8;
       LineSize:TPasMPUInt16;
       Size:TPasMPUInt32;
       pcType:TProcessorCacheType;
      end;
      PSystemLogicalProcessorInformation=^TSystemLogicalProcessorInformation;
      TSystemLogicalProcessorInformation=packed record
       ProcessorMask:TPasMPPtrUInt;
       case Relationship:TLogicalProcessorRelationship of
        0:(
         Flags:TPasMPUInt8;
        );
        1:(
         NodeNumber:TPasMPUInt32;
        );
        2:(
         Cache:TCacheDescriptor;
        );
        3:(
         Reserved:array[0..1] of TPasMPInt64;
        );
      end;
      TGetLogicalProcessorInformation=function(Buffer:PSystemLogicalProcessorInformation;out ReturnLength:TPasMPUInt32):BOOL; stdcall;
  function CountSetBits(Value:TPasMPPtrUInt):TPasMPInt32;
  begin
   result:=0;
   while Value<>0 do begin
    inc(result);
    Value:=Value and (Value-1);
   end;
  end;
 var GetLogicalProcessorInformation:TGetLogicalProcessorInformation;
     Buffer:array of TSystemLogicalProcessorInformation;
     ReturnLength:TPasMPUInt32;
     Index,Count:TPasMPInt32;
 begin
  Buffer:=nil;
  PhysicalCores:=0;
  LogicalCores:=0;
  try
   CPUProcessorMasks:=nil;
   CPUFirstLogicalCore:=nil;
   GetLogicalProcessorInformation:=GetProcAddress(GetModuleHandle('kernel32'),'GetLogicalProcessorInformation');
   if assigned(GetLogicalProcessorInformation) then begin
    SetLength(Buffer,64);
    Count:=0;
    repeat
     ReturnLength:=length(Buffer)*SizeOf(TSystemLogicalProcessorInformation);
     if GetLogicalProcessorInformation(@Buffer[0],ReturnLength) then begin
      Count:=ReturnLength div SizeOf(TSystemLogicalProcessorInformation);
     end else begin
      if GetLastError=ERROR_INSUFFICIENT_BUFFER then begin
       SetLength(Buffer,(ReturnLength div SizeOf(TSystemLogicalProcessorInformation))+1);
       continue;
      end;
     end;
     break;
    until false;
    if Count>0 then begin
     PhysicalCores:=0;
     for Index:=0 to Count-1 do begin
      if Buffer[Index].Relationship=RelationProcessorCore then begin
       if length(CPUProcessorMasks)<=PhysicalCores then begin
        SetLength(CPUProcessorMasks,(PhysicalCores+1)*2);
       end;
       if length(CPUFirstLogicalCore)<=PhysicalCores then begin
        SetLength(CPUFirstLogicalCore,(PhysicalCores+1)*2);
       end;
       CPUProcessorMasks[PhysicalCores]:=Buffer[Index].ProcessorMask;
       CPUFirstLogicalCore[PhysicalCores]:=Index;
       inc(PhysicalCores);
       inc(LogicalCores,CountSetBits(Buffer[Index].ProcessorMask));
      end;
     end;
    end;
   end;
  finally
   SetLength(Buffer,0);
  end;
 end;
begin
 CPUProcessorMasks:=nil;
 CPUFirstLogicalCore:=nil;
 try
  GetCPUInfo(PhysicalCores,LogicalCores);
  result:=PhysicalCores;
  GetSystemInfo(sinfo);
  GetProcessAffinityMask(GetCurrentProcess,dwProcessAffinityMask,dwSystemAffinityMask);
  SetLength(AvailableCPUCores,result);
  for i:=0 to PhysicalCores-1 do begin
   AvailableCPUCores[i]:=CPUFirstLogicalCore[i];
  end;
 finally
  CPUProcessorMasks:=nil;
  CPUFirstLogicalCore:=nil;
 end;
end;
{$elseif defined(Linux) or defined(Android)}
var CountCountIDs,CoreID,CPUIndex,Index:Int32;
    CoreIDFile:Text;
    CoreIDs:array of Int32;
    CPUIDs:array of Int32;
    CPUPath:string;
    IsUnique:Boolean;
    CoreIDStr:string;
begin

 result:=0;

 CountCountIDs:=0;
 CPUIndex:=0;

 CoreIDs:=nil;
 CPUIDs:=nil;
 try

  while true do begin

   // Construct the file path for each CPU core's core_id file
   CPUPath:='/sys/devices/system/cpu/cpu'+IntToStr(CPUIndex)+'/topology/core_id';

   // Check if the core_id file exists
   if not FileExists(CPUPath) then begin
    break;  // Exit loop if there are no more CPUs
   end;

   // Try to open the core_id file
   AssignFile(CoreIDFile,CPUPath);
   {$i-}System.Reset(CoreIDFile);{$i+}
   if IOResult<>0 then begin
    break;  // Exit loop if there are no more CPUs
   end;

    // Read the core_id as a string and close the file
   ReadLn(CoreIDFile,CoreIDStr);
   CloseFile(CoreIDFile);

   // Convert core_id to integer
   CoreID:=StrToIntDef(CoreIDStr,-1);
   if CoreID<0 then begin
    continue;  // Skip if conversion fails
   end;

   // Check if this CoreID is unique
   IsUnique:=true;
   for Index:=0 to CountCountIDs-1 do begin
    if CoreIDs[Index]=CoreID then begin
     IsUnique:=false;
     break;
    end;
   end;

   // If unique, add to dynamic array of CoreIDs
   if IsUnique then begin
    if length(CoreIDs)<=CountCountIDs then begin
     SetLength(CoreIDs,(CountCountIDs+1)*2);
    end;
    if length(CPUIDs)<=CountCountIDs then begin
     SetLength(CPUIDs,(CountCountIDs+1)*2);
    end;
    CoreIDs[CountCountIDs]:=CoreID;
    CPUIDs[CountCountIDs]:=CPUIndex;
    inc(CountCountIDs);
    inc(result);
   end;

   inc(CPUIndex);

  end;

  SetLength(AvailableCPUCores,result);
  for Index:=0 to result-1 do begin
   AvailableCPUCores[Index]:=CPUIDs[Index];
  end;

 finally
  CoreIDs:=nil;
  CPUIDs:=nil;
 end;

end;
{$elseif defined(Solaris)}
var i:TPasMPInt32;
begin
 result:=sysconf(_SC_NPROC_ONLN);
 SetLength(AvailableCPUCores,result);
 for i:=0 to result-1 do begin
  AvailableCPUCores[i]:=i;
 end;
end;
{$elseif defined(fpc) and defined(Darwin)}
const IDs:array[0..3] of RawByteString=
       (
        'machdep.cpu.core_count',
        'hw.physicalcpu',
        'machdep.cpu.thread_count',
        'hw.logicalcpu',
       );
var status,t,i:cint;
    len:size_t;
begin
 result:=1;
 len:=SizeOf(t);
 for i:=Low(IDs) to High(IDs) do begin
  t:=0;
  status:=fpSysCtlByName(PAnsiChar(IDs[i]),@t,@len,nil,0);
  if (status=0) and (t>=1) then begin
   result:=t;
   break;
  end;
 end;
 SetLength(AvailableCPUCores,result);
 for i:=0 to result-1 do begin
  AvailableCPUCores[i]:=i;
 end;
end;
{$elseif defined(Unix)}
var mib:array[0..1] of cint;
    len:cint;
    t:cint;
    i:TPasMPInt32;
begin
 mib[0]:=CTL_HW;
 mib[1]:=HW_AVAILCPU;
 len:=SizeOf(t);
 fpsysctl(Pointer(@mib),2,@t,@len,nil,0);
 if t<1 then begin
  mib[1]:=HW_NCPU;
  fpsysctl(Pointer(@mib),2,@t,@len,nil,0);
  if t<1 then begin
   t:=1;
  end;
 end;
 result:=t;
 SetLength(AvailableCPUCores,result);
 for i:=0 to result-1 do begin
  AvailableCPUCores[i]:=i;
 end;
end;
{$else}
var i:TPasMPInt32;
begin
 result:=1;
 SetLength(AvailableCPUCores,result);
 for i:=0 to result-1 do begin
  AvailableCPUCores[i]:=i;
 end;
end;
{$ifend}

class function TPasMP.GetCountOfHardwareThreads(out AvailableCPUCores:TPasMPAvailableCPUCores):TPasMPInt32;
{$if defined(Windows)}
var PhysicalCores,LogicalCores,i,j:TPasMPInt32;
    sinfo:SYSTEM_INFO;
    dwProcessAffinityMask,dwSystemAffinityMask:TPasMPPtrUInt;
 procedure GetCPUInfo(var PhysicalCores,LogicalCores:TPasMPInt32);
 const RelationProcessorCore=0;
       RelationNumaNode=1;
       RelationCache=2;
       RelationProcessorPackage=3;
       RelationGroup=4;
       RelationAll=$ffff;
       CacheUnified=0;
       CacheInstruction=1;
       CacheData=2;
       CacheTrace=3;
 type TLogicalProcessorRelationship=TPasMPUInt32;
      TProcessorCacheType=TPasMPUInt32;
      TCacheDescriptor=packed record
       Level:TPasMPUInt8;
       Associativity:TPasMPUInt8;
       LineSize:TPasMPUInt16;
       Size:TPasMPUInt32;
       pcType:TProcessorCacheType;
      end;
      PSystemLogicalProcessorInformation=^TSystemLogicalProcessorInformation;
      TSystemLogicalProcessorInformation=packed record
       ProcessorMask:TPasMPPtrUInt;
       case Relationship:TLogicalProcessorRelationship of
        0:(
         Flags:TPasMPUInt8;
        );
        1:(
         NodeNumber:TPasMPUInt32;
        );
        2:(
         Cache:TCacheDescriptor;
        );
        3:(
         Reserved:array[0..1] of TPasMPInt64;
        );
      end;
      TGetLogicalProcessorInformation=function(Buffer:PSystemLogicalProcessorInformation;out ReturnLength:TPasMPUInt32):BOOL; stdcall;
  function CountSetBits(Value:TPasMPPtrUInt):TPasMPInt32;
  begin
   result:=0;
   while Value<>0 do begin
    inc(result);
    Value:=Value and (Value-1);
   end;
  end;
 var GetLogicalProcessorInformation:TGetLogicalProcessorInformation;
     Buffer:array of TSystemLogicalProcessorInformation;
     ReturnLength:TPasMPUInt32;
     Index,Count:TPasMPInt32;
 begin
  Buffer:=nil;
  PhysicalCores:=0;
  LogicalCores:=0;
  try
   GetLogicalProcessorInformation:=GetProcAddress(GetModuleHandle('kernel32'),'GetLogicalProcessorInformation');
   if assigned(GetLogicalProcessorInformation) then begin
    SetLength(Buffer,64);
    Count:=0;
    repeat
     ReturnLength:=length(Buffer)*SizeOf(TSystemLogicalProcessorInformation);
     if GetLogicalProcessorInformation(@Buffer[0],ReturnLength) then begin
      Count:=ReturnLength div SizeOf(TSystemLogicalProcessorInformation);
     end else begin
      if GetLastError=ERROR_INSUFFICIENT_BUFFER then begin
       SetLength(Buffer,(ReturnLength div SizeOf(TSystemLogicalProcessorInformation))+1);
       continue;
      end;
     end;
     break;
    until false;
    if Count>0 then begin
     PhysicalCores:=0;
     for Index:=0 to Count-1 do begin
      if Buffer[Index].Relationship=RelationProcessorCore then begin
       inc(PhysicalCores);
       inc(LogicalCores,CountSetBits(Buffer[Index].ProcessorMask));
      end;
     end;
    end;
   end;
  finally
   SetLength(Buffer,0);
  end;
 end;
begin
 GetCPUInfo(PhysicalCores,LogicalCores);
 result:=LogicalCores;
 if result=0 then begin
  result:=PhysicalCores;
 end;
 GetSystemInfo(sinfo);
 GetProcessAffinityMask(GetCurrentProcess,dwProcessAffinityMask,dwSystemAffinityMask);
 SetLength(AvailableCPUCores,result);
 j:=0;
 for i:=0 to sinfo.dwNumberOfProcessors-1 do begin
  if (dwProcessAffinityMask and (1 shl i))<>0 then begin
   AvailableCPUCores[j]:=i;
   inc(j);
   if j>=result then begin
    break;
   end;
  end;
 end;
 if result>j then begin
  result:=j;
  SetLength(AvailableCPUCores,result);
 end;
end;
{$elseif defined(Android)}
const Paths:array[0..1] of string=
       (
        '/sys/devices/system/cpu/possible',
        '/sys/devices/system/cpu/present'
       );
var TryIteration,i:TPasMPInt32;
    fs:TFileStream;
    s:{$ifdef HAS_TYPE_RAWBYTESTRING}RawByteString{$else}AnsiString{$endif};
begin
 for TryIteration:=0 to 1 do begin
  if FileExists(Paths[TryIteration]) then begin
   s:='';
   fs:=TFileStream.Create(Paths[TryIteration],fmOpenRead or fmShareDenyWrite);
   try
    SetLength(s,fs.Size);
    fs.Read(s[1],length(s));
   finally
    fs.Free;
   end;
   if (length(s)>2) and (s[1]='0') and (s[2]='-') then begin
    Delete(s,1,2);
    result:=StrToIntDef(String(s),-1);
    if result>=0 then begin
     inc(result);
     SetLength(AvailableCPUCores,result);
     for i:=0 to result-1 do begin
      AvailableCPUCores[i]:=i;
     end;
     exit;
    end;
   end;
  end;
 end;
 result:=1;
 for i:=0 to 127 do begin
  if DirectoryExists('/sys/devices/system/cpu/cpu'+IntToStr(i)) then begin
   result:=i+1;
  end else begin
   break;
  end;
 end;
 SetLength(AvailableCPUCores,result);
 for i:=0 to result-1 do begin
  AvailableCPUCores[i]:=i;
 end;
end;
{$elseif defined(Linux) or defined(Android)}
var i,j:TPasMPInt32;
    CPUSet:TPasMPInt64;
begin
 result:=sysconf(_SC_NPROCESSORS_CONF);
 SetLength(AvailableCPUCores,result);
 CPUSet:=0;
 if sched_getaffinity(GetProcessID,SizeOf(CPUSet),@CPUSet)=0 then begin
  j:=0;
  for i:=0 to 63 do begin
   if (CPUSet and (TPasMPInt64(1) shl i))<>0 then begin
    AvailableCPUCores[j]:=i;
    inc(j);
    if j>=result then begin
     break;
    end;
   end;
  end;
  if result>j then begin
   result:=j;
   SetLength(AvailableCPUCores,result);
  end;
 end else begin
  for i:=0 to result-1 do begin
   AvailableCPUCores[i]:=i;
  end;
 end;
end;
{$elseif defined(Solaris)}
var i:TPasMPInt32;
begin
 result:=sysconf(_SC_NPROC_ONLN);
 SetLength(AvailableCPUCores,result);
 for i:=0 to result-1 do begin
  AvailableCPUCores[i]:=i;
 end;
end;
{$elseif defined(fpc) and defined(Darwin)}
const IDs:array[0..3] of RawByteString=
       (
        'machdep.cpu.thread_count',
        'hw.logicalcpu',
        'machdep.cpu.core_count',
        'hw.physicalcpu'
       );
var status,t,i:cint;
    len:size_t;
begin
 result:=1;
 len:=SizeOf(t);
 for i:=Low(IDs) to High(IDs) do begin
  t:=0;
  status:=fpSysCtlByName(PAnsiChar(IDs[i]),@t,@len,nil,0);
  if (status=0) and (t>=1) then begin
   result:=t;
   break;
  end;
 end;
 SetLength(AvailableCPUCores,result);
 for i:=0 to result-1 do begin
  AvailableCPUCores[i]:=i;
 end;
end;
{$elseif defined(Unix)}
var mib:array[0..1] of cint;
    len:cint;
    t:cint;
    i:TPasMPInt32;
begin
 mib[0]:=CTL_HW;
 mib[1]:=HW_AVAILCPU;
 len:=SizeOf(t);
 fpsysctl(Pointer(@mib),2,@t,@len,nil,0);
 if t<1 then begin
  mib[1]:=HW_NCPU;
  fpsysctl(Pointer(@mib),2,@t,@len,nil,0);
  if t<1 then begin
   t:=1;
  end;
 end;
 result:=t;
 SetLength(AvailableCPUCores,result);
 for i:=0 to result-1 do begin
  AvailableCPUCores[i]:=i;
 end;
end;
{$else}
var i:TPasMPInt32;
begin
 result:=1;
 SetLength(AvailableCPUCores,result);
 for i:=0 to result-1 do begin
  AvailableCPUCores[i]:=i;
 end;
end;
{$ifend}

class function TPasMP.Once(var OnceControl:TPasMPOnce;const InitRoutine:TPasMPOnceInitRoutine):boolean;
{$ifdef Linux}
begin
 result:=pthread_once(@OnceControl,InitRoutine)=0;
end;
{$else}
var SavedOnceControl:TPasMPOnce;
begin
 result:=false;
 SavedOnceControl:=OnceControl;
{$ifdef CPU386}
 asm
  mfence
 end;
{$else}
 TPasMPMemoryBarrier.ReadWrite;
{$endif}
 while SavedOnceControl<>1 do begin
  if SavedOnceControl=0 then begin
   if TPasMPInterlocked.CompareExchange(OnceControl,2,0)=0 then begin
    try
     InitRoutine;
    finally
     OnceControl:=1;
    end;
    result:=true;
    exit;
   end;
  end;
{$ifdef cpu386}
  asm
   db $f3,$90 // pause (rep nop)
  end;
{$else}
  TPasMP.Yield;
{$endif}
{$ifdef CPU386}
  asm
   mfence
  end;
{$else}
  TPasMPMemoryBarrier.ReadWrite;
{$endif}
  SavedOnceControl:=OnceControl;
 end;
end;
{$endif}

procedure TPasMP.Reset;
var Index:TPasMPInt32;
begin
 fJobAllocator.FreeJobs;
 for Index:=0 to fCountJobWorkerThreads-1 do begin
  fJobWorkerThreads[Index].fJobAllocator.FreeJobs;
 end;
end;

function TPasMP.CreateScope:TPasMPScope;
begin
 result:=TPasMPScope.Create(self);
end;

class function TPasMP.IsJobCompleted(const Job:PPasMPJob):boolean;
begin
 result:=assigned(Job) and ((Job^.InternalData and PasMPJobFlagActive)=0);
end;

class function TPasMP.IsJobValid(const Job:PPasMPJob):boolean;
begin
 result:=assigned(Job) and ((Job^.InternalData and PasMPJobFlagActive)<>0);
end;

function TPasMP.GetJobWorkerThread:TPasMPJobWorkerThread; {$ifdef UseThreadLocalStorage}{$if defined(UseThreadLocalStorageX8632) or defined(UseThreadLocalStorageX8664)}assembler;{$ifend}{$endif}
{$ifdef UseThreadLocalStorage}
{$if defined(UseThreadLocalStorageX8632)}
asm
 mov eax,dword ptr fs:[$00000018]
 mov ecx,dword ptr CurrentJobWorkerThreadTLSOffset
 mov eax,dword ptr [eax+ecx]
end;
{$elseif defined(UseThreadLocalStorageX8664)}
asm
 mov rax,qword ptr gs:[$00000058]
 mov ecx,dword ptr CurrentJobWorkerThreadTLSOffset
 mov rax,qword ptr [rax+rcx]
end;
{$else}
begin
 result:=CurrentJobWorkerThread;
end;
{$ifend}
{$else}
var ThreadID:{$ifdef fpc}TThreadID{$else}TPasMPUInt32{$endif};
    ThreadIDHash:TPasMPUInt32;
begin
{$if (defined(NEXTGEN) or not defined(Windows)) and not defined(FPC)}
 ThreadID:=TThread.CurrentThread.ThreadID;
{$else}
 ThreadID:=GetCurrentThreadID;
{$ifend}
 ThreadIDHash:=TPasMP.GetThreadIDHash(ThreadID);
 result:=fJobWorkerThreadHashTable[ThreadIDHash and PasMPJobWorkerThreadHashTableMask];
 while assigned(result) and (result.fThreadID<>ThreadID) do begin
  result:=result.fNext;
 end;
end;
{$endif}

function TPasMP.GetJobWorkerThreadIndex:TPasMPInt32;
var CurrentJobWorkerThread:TPasMPJobWorkerThread;
begin
 CurrentJobWorkerThread:=GetJobWorkerThread;
 if assigned(CurrentJobWorkerThread) then begin
  result:=CurrentJobWorkerThread.fThreadIndex;
 end else begin
  result:=-1;
 end;
end;

procedure TPasMP.WaitForWakeUp;
{$ifdef PasMPUseWakeUpConditionVariable}
var SavedWakeUpCounter:TPasMPInt32;
begin
 if fSleepingOnIdle then begin
  fWakeUpConditionVariableLock.Acquire;
  try
   TPasMPInterlocked.Increment(fSleepingJobWorkerThreads);
   SavedWakeUpCounter:=fWakeUpCounter;
   repeat
    fWakeUpConditionVariable.Wait(fWakeUpConditionVariableLock);
   until SavedWakeUpCounter<>fWakeUpCounter;
   TPasMPInterlocked.Decrement(fSleepingJobWorkerThreads);
  finally
   fWakeUpConditionVariableLock.Release;
  end;
 end else begin
  TPasMP.Yield;
 end;
end;
{$else}
begin
 if fSleepingOnIdle then begin
  fWakeUpEvent.ResetEvent;
  TPasMPInterlocked.Increment(fSleepingJobWorkerThreads);
  fWakeUpEvent.WaitFor(INFINITE);
  TPasMPInterlocked.Decrement(fSleepingJobWorkerThreads);
 end else begin
  TPasMP.Yield;
 end;
end;
{$endif}

procedure TPasMP.WakeUpAll;
{$ifdef PasMPUseWakeUpConditionVariable}
begin
 if fSleepingJobWorkerThreads>0 then begin
  fWakeUpConditionVariableLock.Acquire;
  try
   inc(fWakeUpCounter);
   fWakeUpConditionVariable.Broadcast;
  finally
   fWakeUpConditionVariableLock.Release;
  end;
 end;
end;
{$else}
begin
 if fSleepingJobWorkerThreads>0 then begin
  fWakeUpEvent.SetEvent;
 end;
end;
{$endif}

function TPasMP.CanSpread:boolean;
var CurrentJobWorkerThread,JobWorkerThread:TPasMPJobWorkerThread;
    ThreadIndex,Index:TPasMPInt32;
begin
 result:=false;
 CurrentJobWorkerThread:=GetJobWorkerThread;
 if assigned(CurrentJobWorkerThread) then begin
  ThreadIndex:=CurrentJobWorkerThread.fThreadIndex;
  if ((ThreadIndex=0) and (fWorkingJobWorkerThreads=0)) or ((ThreadIndex<>0) and (fWorkingJobWorkerThreads=1)) then begin
   for Index:=0 to fCountJobWorkerThreads-1 do begin
    JobWorkerThread:=fJobWorkerThreads[Index];
    if (JobWorkerThread<>CurrentJobWorkerThread) and JobWorkerThread.HasJobs then begin
     // We are not alone with queued work.
     exit;
    end;
   end;
   // We are alone with queued work.
   result:=true;
  end;
 end;
end;

function TPasMP.IsFull:boolean;
var CurrentJobWorkerThread,JobWorkerThread:TPasMPJobWorkerThread;
    ThreadIndex,Index:TPasMPInt32;
begin
 result:=false;
 CurrentJobWorkerThread:=GetJobWorkerThread;
 if assigned(CurrentJobWorkerThread) and (fWorkerThreadMaxDepth>0) then begin
  result:=true;
  for Index:=0 to fCountJobWorkerThreads-1 do begin
   JobWorkerThread:=fJobWorkerThreads[Index];
   if (JobWorkerThread<>CurrentJobWorkerThread) and (JobWorkerThread.fDepth<fWorkerThreadMaxDepth) then begin
    result:=false;
    exit;
   end;
  end;
 end;
end;

function TPasMP.GlobalAllocateJob:PPasMPJob;
begin
 fJobAllocatorCriticalSection.Acquire;
 try
  result:=fJobAllocator.AllocateJob;
 finally
  fJobAllocatorCriticalSection.Release;
 end;
end;

procedure TPasMP.GlobalFreeJob(const Job:PPasMPJob);
begin
 fJobAllocatorCriticalSection.Acquire;
 try
  fJobAllocator.FreeJob(Job);
 finally
  fJobAllocatorCriticalSection.Release;
 end;
end;

function TPasMP.AllocateJob(const MethodCode,MethodData,Data:pointer;const ParentJob:PPasMPJob;const Flags,AreaMask:TPasMPUInt32):PPasMPJob;
var JobWorkerThread:TPasMPJobWorkerThread;
    InternalData:TPasMPUInt32;
begin
 if assigned(ParentJob) and ((ParentJob^.InternalData and PasMPJobFlagActive)<>0) then begin
  TPasMPInterlocked.Increment(ParentJob^.ChildrenJobs);
 end;
 JobWorkerThread:=GetJobWorkerThread;
 InternalData:=PasMPJobFlagActive or Flags;
 if assigned(JobWorkerThread) then begin
  if (InternalData and PasMPJobPriorityShiftedMask)=PasMPJobPriorityInherited then begin
   InternalData:=InternalData or JobWorkerThread.fCurrentJobPriority;
  end;
  InternalData:=InternalData or (PasMPJobFlagHasOwnerWorkerThread or TPasMPUInt32(JobWorkerThread.fThreadIndex));
  result:=JobWorkerThread.fJobAllocator.AllocateJob;
 end else begin
  if (InternalData and PasMPJobPriorityShiftedMask)=PasMPJobPriorityInherited then begin
   InternalData:=InternalData or PasMPJobPriorityNormal;
  end;
  result:=GlobalAllocateJob;
 end;
 result^.Method.Code:=MethodCode;
 result^.Method.Data:=MethodData;
 result^.ParentJob:=ParentJob;
 result^.ChildrenJobs:=0;
 result^.InternalData:=InternalData;
 result^.AreaMask:=AreaMask;
 result^.Data:=Data;
end;

{$ifdef HAS_ANONYMOUS_METHODS}
type PPasMPJobReferenceProcedureJobData=^TPasMPJobReferenceProcedureJobData;
     TPasMPJobReferenceProcedureJobData=record
      JobReferenceProcedure:TPasMPJobReferenceProcedure;
      Data:pointer;
     end;

procedure TPasMP.JobReferenceProcedureJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
var JobReferenceProcedureJobData:PPasMPJobReferenceProcedureJobData;
begin
 JobReferenceProcedureJobData:=PPasMPJobReferenceProcedureJobData(pointer(@Job^.Data));
 try
  JobReferenceProcedureJobData^.JobReferenceProcedure(JobReferenceProcedureJobData^.Data,ThreadIndex);
 finally
  Finalize(JobReferenceProcedureJobData^);
 end;
end;

function TPasMP.Acquire(const JobReferenceProcedure:TPasMPJobReferenceProcedure;const Data:pointer=nil;const ParentJob:PPasMPJob=nil;const Flags:TPasMPUInt32=0;const AreaMask:TPasMPUInt32=0):PPasMPJob;
var JobMethod:TPasMPJobMethod;
    JobReferenceProcedureJobData:PPasMPJobReferenceProcedureJobData;
begin
 JobMethod:=JobReferenceProcedureJobFunction;
 result:=AllocateJob(TMethod(JobMethod).Code,TMethod(JobMethod).Data,nil,ParentJob,Flags,AreaMask);
 if assigned(result) then begin
  JobReferenceProcedureJobData:=PPasMPJobReferenceProcedureJobData(pointer(@result^.Data));
  Initialize(JobReferenceProcedureJobData^);
  JobReferenceProcedureJobData^.JobReferenceProcedure:=JobReferenceProcedure;
  JobReferenceProcedureJobData^.Data:=Data;
 end;
end;
{$endif}

function TPasMP.Acquire(const JobProcedure:TPasMPJobProcedure;const Data:pointer=nil;const ParentJob:PPasMPJob=nil;const Flags:TPasMPUInt32=0;const AreaMask:TPasMPUInt32=0):PPasMPJob;
begin
 result:=AllocateJob(Addr(JobProcedure),nil,Data,ParentJob,Flags,AreaMask);
end;

function TPasMP.Acquire(const JobMethod:TPasMPJobMethod;const Data:pointer=nil;const ParentJob:PPasMPJob=nil;const Flags:TPasMPUInt32=0;const AreaMask:TPasMPUInt32=0):PPasMPJob;
begin
 result:=AllocateJob(TMethod(JobMethod).Code,TMethod(JobMethod).Data,Data,ParentJob,Flags,AreaMask);
end;

function TPasMP.Acquire(const JobTask:TPasMPJobTask;const Data:pointer=nil;const ParentJob:PPasMPJob=nil;const Flags:TPasMPUInt32=0;const AreaMask:TPasMPUInt32=0):PPasMPJob;
begin
 result:=AllocateJob(nil,pointer(JobTask),Data,ParentJob,Flags or TPasMP.EncodeJobTagToJobFlags(JobTask.fJobTag),AreaMask);
 JobTask.fJob:=result;
 JobTask.fThreadIndex:=-1;
end;

procedure TPasMP.Release(const Job:PPasMPJob);
begin
 if assigned(Job) then begin
  if (assigned(Job^.Method.Data) and not assigned(Job^.Method.Code)) and TPasMPJobTask(pointer(Job^.Method.Data)).fFreeOnRelease then begin
   TPasMPJobTask(pointer(Job^.Method.Data)).Free;
  end;
  if (Job^.InternalData and PasMPJobFlagHasOwnerWorkerThread)<>0 then begin
   fJobWorkerThreads[(Job^.InternalData shr PasMPJobThreadIndexShift) and PasMPJobThreadIndexMask].fJobAllocator.FreeJob(Job);
  end else begin
   GlobalFreeJob(Job);
  end;
 end;
end;

procedure TPasMP.Release(const Jobs:array of PPasMPJob);
var JobIndex:TPasMPInt32;
begin
 for JobIndex:=0 to length(Jobs)-1 do begin
  Release(Jobs[JobIndex]);
 end;
end;

procedure TPasMP.ExecuteJobTask(const Job:PPasMPJob;const JobWorkerThread:TPasMPJobWorkerThread;const ThreadIndex:TPasMPInt32);
var JobTask,NewJobTask:TPasMPJobTask;
    NewJob:PPasMPJob;
begin

 JobTask:=TPasMPJobTask(pointer(Job^.Method.Data));
 JobTask.fThreadIndex:=ThreadIndex;

 if CanSpread then begin
  // First try to spread, when all worker threads (except us) are jobless
  JobTask.Spread;
 end;

 if ((Job^.InternalData and PasMPJobFlagHasOwnerWorkerThread)<>0) and
    (TPasMPInt32((Job^.InternalData shr PasMPJobThreadIndexShift) and PasMPJobThreadIndexMask)<>ThreadIndex) then begin
  // It's a stolen job => try Split
  NewJobTask:=JobTask.Split;
  if not assigned(NewJobTask) then begin
   // if Split of a stolen job has failed => try PartialPop
   NewJobTask:=JobTask.PartialPop;
  end;
 end else begin
  // It's a non-stolen job => try PartialPop
  NewJobTask:=JobTask.PartialPop;
 end;

 if assigned(NewJobTask) then begin
  // Run our both halfed jobs
  NewJob:=Acquire(NewJobTask,nil,nil,0,Job^.AreaMask);
  Run(NewJob);
  JobTask.Run;
  Wait(NewJob);
  Release(NewJob);
 end else begin
  // if PartialPop has also failed => just execute the job as whole
  JobTask.Run;
 end;

end;

procedure TPasMP.WaitOnChildrenJobs(const Job:PPasMPJob);
var SpinCount,CountMaxSpinCount:TPasMPInt32;
    NextJob:PPasMPJob;
    JobWorkerThread:TPasMPJobWorkerThread;
begin
 if assigned(Job) then begin
  JobWorkerThread:=GetJobWorkerThread;
  SpinCount:=0;
  CountMaxSpinCount:=128;
  while Job^.ChildrenJobs>0 do begin
   if assigned(JobWorkerThread) then begin
    NextJob:=JobWorkerThread.GetJob;
    if assigned(NextJob) then begin
     ExecuteJob(NextJob,JobWorkerThread);
     SpinCount:=0;
    end else begin
     if SpinCount<CountMaxSpinCount then begin
      inc(SpinCount);
     end else begin
      TPasMP.Yield;
     end;
    end;
   end else begin
    TPasMP.Yield;
   end;
  end;
 end;
end;

function TPasMP.CheckJobExecution(const Job:PPasMPJob;const JobWorkerThread:TPasMPJobWorkerThread):Boolean;
begin

 if assigned(fOnCheckJobExecution) and not fOnCheckJobExecution(Self,Job,JobWorkerThread) then begin
  result:=false;
  exit;
 end;

 result:=true;

end;

procedure TPasMP.ExecuteJob(const Job:PPasMPJob;const JobWorkerThread:TPasMPJobWorkerThread);
var LastJobPriority,OldAreaMask:TPasMPUInt32;
    ProfilerHistoryRingBufferItem:PPasMPProfilerHistoryRingBufferItem;
begin

 if JobWorkerThread.HasJobs then begin
  WakeUpAll;
 end;

 // Check if the job is allowed to run now here
 if not CheckJobExecution(Job,JobWorkerThread) then begin

  // Job is not allowed to run alright now, so re-enqueue it for later

  // Clear the requeue flag, if it was set, so we don't requeue it again and again
  TPasMPInterlocked.BitwiseAnd(Job^.InternalData,PasMPJobFlagRequeueAndNotMask);

  // Requeue the job, so it will be executed later, but into the global job queue for better chances to be executed directly without re-enqueueing again
  Run(Job,true);

  exit;

 end;

 if assigned(fProfiler) then begin
  ProfilerHistoryRingBufferItem:=fProfiler.Acquire;
  ProfilerHistoryRingBufferItem^.JobTag:=TPasMP.DecodeJobTagFromJobFlags(Job^.InternalData);
  ProfilerHistoryRingBufferItem^.ThreadIndexStackDepth:=TPasMPUInt32(JobWorkerThread.fThreadIndex and $ffff) or (JobWorkerThread.fDepth shl 16);
  ProfilerHistoryRingBufferItem^.StartTime:=fProfiler.fHighResolutionTimer.GetTime+fProfiler.fOffsetTime;
 end else begin
  ProfilerHistoryRingBufferItem:=nil;
 end;

 inc(JobWorkerThread.fDepth);

 OldAreaMask:=JobWorkerThread.fAreaMask;
 JobWorkerThread.fAreaMask:=OldAreaMask or Job^.AreaMask;

 LastJobPriority:=JobWorkerThread.fCurrentJobPriority;
 JobWorkerThread.fCurrentJobPriority:=Job^.InternalData and PasMPJobPriorityShiftedMask;

 if assigned(Job^.Method.Data) then begin
  if assigned(Job^.Method.Code) then begin
   TPasMPJobMethod(Job^.Method)(Job,JobWorkerThread.ThreadIndex);
  end else begin
   ExecuteJobTask(Job,JobWorkerThread,JobWorkerThread.ThreadIndex);
  end;
 end else begin
  if assigned(Job^.Method.Code) then begin
   TPasMPJobProcedure(pointer(Job^.Method.Code))(Job,JobWorkerThread.ThreadIndex);
  end;
 end;

 JobWorkerThread.fCurrentJobPriority:=LastJobPriority;

 if ((Job^.InternalData and PasMPJobFlagRequeue)=0) and (Job^.ChildrenJobs>0) then begin
  WaitOnChildrenJobs(Job);
 end;

 if assigned(ProfilerHistoryRingBufferItem) then begin
  ProfilerHistoryRingBufferItem^.EndTime:=fProfiler.fHighResolutionTimer.GetTime+fProfiler.fOffsetTime;
 end;

 JobWorkerThread.fAreaMask:=OldAreaMask;

 dec(JobWorkerThread.fDepth);

 if (Job^.InternalData and PasMPJobFlagRequeue)<>0 then begin

  TPasMPInterlocked.BitwiseAnd(Job^.InternalData,PasMPJobFlagRequeueAndNotMask);

  Run(Job,true);

 end else begin

  if assigned(Job^.ParentJob) then begin
   TPasMPInterlocked.Decrement(Job^.ParentJob^.ChildrenJobs);
  end;

  TPasMPInterlocked.BitwiseAnd(Job^.InternalData,PasMPJobFlagActiveAndNotMask);

  if (Job^.InternalData and PasMPJobFlagReleaseOnFinish)<>0 then begin
   Release(Job);
  end;

 end;

end;

procedure TPasMP.PushJob(const Job:PPasMPJob;const JobWorkerThread:TPasMPJobWorkerThread);
var JobQueueIndex,PriorityJobQueueBitMask:TPasMPUInt32;
begin
 JobQueueIndex:=PasMPJobQueuePriorityLast-(((Job^.InternalData and PasMPJobPriorityShiftedMask) shr PasMPJobPriorityShift)-(PasMPJobPriorityLow shr PasMPJobPriorityShift));
 PriorityJobQueueBitMask:=TPasMPUInt32(1) shl TPasMPUInt32(JobQueueIndex);
 if assigned(JobWorkerThread) then begin
  JobWorkerThread.fJobQueues[JobQueueIndex].PushJob(Job);
  if (JobWorkerThread.fJobQueuesUsedBitmap and PriorityJobQueueBitMask)=0 then begin
   JobWorkerThread.fJobQueuesUsedBitmap:=JobWorkerThread.fJobQueuesUsedBitmap or PriorityJobQueueBitMask;
   TPasMPInterlocked.BitwiseOr(fGlobalJobQueuesUsedBitmap,PriorityJobQueueBitMask);
  end;
 end else begin
  fJobQueuesLock.Acquire;
  try
   fJobQueues[JobQueueIndex].PushJob(Job);
{$if defined(cpu386) or defined(cpux86_64)}
   TPasMPMemoryBarrier.ReadDependency;
{$else}
   TPasMPMemoryBarrier.Read;
{$ifend}
   if (fJobQueuesUsedBitmap and PriorityJobQueueBitMask)=0 then begin
    fJobQueuesUsedBitmap:=fJobQueuesUsedBitmap or PriorityJobQueueBitMask;
    TPasMPMemoryBarrier.ReadWrite;
    TPasMPInterlocked.BitwiseOr(fGlobalJobQueuesUsedBitmap,PriorityJobQueueBitMask);
   end;
  finally
   fJobQueuesLock.Release;
  end;
 end;
end;

procedure TPasMP.Run(const Job:PPasMPJob;const GlobalQueue:Boolean);
var JobWorkerThread:TPasMPJobWorkerThread;
begin
 if assigned(Job) then begin
  if GlobalQueue then begin
   JobWorkerThread:=nil;
  end else begin
   JobWorkerThread:=GetJobWorkerThread;
  end;
  PushJob(Job,JobWorkerThread);
  WakeUpAll;
 end;
end;

procedure TPasMP.Run(const Jobs:array of PPasMPJob;const GlobalQueue:Boolean);
var JobWorkerThread:TPasMPJobWorkerThread;
    JobIndex:TPasMPInt32;
    Job:PPasMPJob;
begin
 if GlobalQueue then begin
  JobWorkerThread:=nil;
 end else begin
  JobWorkerThread:=GetJobWorkerThread;
 end;
 for JobIndex:=0 to length(Jobs)-1 do begin
  Job:=Jobs[JobIndex];
  if assigned(Job) then begin
   PushJob(Job,JobWorkerThread);
  end;
 end;
 WakeUpAll;
end;

function TPasMP.StealAndExecuteJob:boolean;
var NextJob:PPasMPJob;
    JobWorkerThread:TPasMPJobWorkerThread;
begin
 result:=false;
 JobWorkerThread:=GetJobWorkerThread;
 if assigned(JobWorkerThread) then begin
  NextJob:=JobWorkerThread.GetJob;
  if assigned(NextJob) then begin
   ExecuteJob(NextJob,JobWorkerThread);
   result:=true;
  end;
 end;
end;

procedure TPasMP.Wait(const Job:PPasMPJob);
var SpinCount,CountMaxSpinCount:TPasMPInt32;
    NextJob:PPasMPJob;
    JobWorkerThread:TPasMPJobWorkerThread;
begin
 if assigned(Job) then begin
  JobWorkerThread:=GetJobWorkerThread;
  SpinCount:=0;
  CountMaxSpinCount:=128;
  while (Job^.InternalData and PasMPJobFlagActive)<>0 do begin
   if assigned(JobWorkerThread) then begin
    NextJob:=JobWorkerThread.GetJob;
    if assigned(NextJob) then begin
     ExecuteJob(NextJob,JobWorkerThread);
     SpinCount:=0;
    end else begin
     if SpinCount<CountMaxSpinCount then begin
      inc(SpinCount);
     end else begin
      TPasMP.Yield;
     end;
    end;
   end else begin
    TPasMP.Yield;
   end;
  end;
 end;
end;

procedure TPasMP.Wait(const Jobs:array of PPasMPJob);
var JobIndex,CountJobs,SpinCount,CountMaxSpinCount:TPasMPInt32;
    Job,NextJob:PPasMPJob;
    Done:boolean;
    JobWorkerThread:TPasMPJobWorkerThread;
begin
 CountJobs:=length(Jobs);
 if CountJobs>0 then begin
  JobWorkerThread:=GetJobWorkerThread;
  SpinCount:=0;
  CountMaxSpinCount:=128;
  repeat
   Done:=true;
   for JobIndex:=0 to CountJobs-1 do begin
    Job:=Jobs[JobIndex];
    if assigned(Job) and ((Job^.InternalData and PasMPJobFlagActive)<>0) then begin
     Done:=false;
     break;
    end;
   end;
   if Done then begin
    break;
   end else begin
    if assigned(JobWorkerThread) then begin
     NextJob:=JobWorkerThread.GetJob;
     if assigned(NextJob) then begin
      ExecuteJob(NextJob,JobWorkerThread);
      SpinCount:=0;
     end else begin
      if SpinCount<CountMaxSpinCount then begin
       inc(SpinCount);
      end else begin
       TPasMP.Yield;
      end;
     end;
    end else begin
     TPasMP.Yield;
    end;
   end;
  until false;
 end;
end;

procedure TPasMP.RunWait(const Job:PPasMPJob);
begin
 if assigned(Job) then begin
  Run(Job);
  Wait(Job);
 end;
end;

procedure TPasMP.RunWait(const Jobs:array of PPasMPJob);
begin
 Run(Jobs);
 Wait(Jobs);
end;

procedure TPasMP.WaitRelease(const Job:PPasMPJob);
begin
 if assigned(Job) then begin
  Wait(Job);
  Release(Job);
 end;
end;

procedure TPasMP.WaitRelease(const Jobs:array of PPasMPJob);
begin
 Wait(Jobs);
 Release(Jobs);
end;

procedure TPasMP.Invoke(const Job:PPasMPJob);
begin
 if assigned(Job) then begin
  Run(Job);
  Wait(Job);
  Release(Job);
 end;
end;

procedure TPasMP.Invoke(const Jobs:array of PPasMPJob);
begin
 Run(Jobs);
 Wait(Jobs);
 Release(Jobs);
end;

procedure TPasMP.Invoke(const JobTask:TPasMPJobTask);
begin
 Invoke(Acquire(JobTask));
end;

procedure TPasMP.Invoke(const JobTasks:array of TPasMPJobTask);
var CountJobTasks,Index:TPasMPInt32;
    Jobs:array of PPasMPJob;
begin
 Jobs:=nil;
 CountJobTasks:=length(JobTasks);
 SetLength(Jobs,CountJobTasks);
 try
  for Index:=0 to CountJobTasks-1 do begin
   Jobs[Index]:=Acquire(JobTasks[Index]);
  end;
  Invoke(Jobs);
 finally
  SetLength(Jobs,0);
 end;
end;

{$ifdef HAS_ANONYMOUS_METHODS}
type PPasMPParallelForReferenceProcedureStartJobData=^TPasMPParallelForReferenceProcedureStartJobData;
     TPasMPParallelForReferenceProcedureStartJobData=record
      ParallelForReferenceProcedure:TPasMPParallelForReferenceProcedure;
      Data:pointer;
      FirstIndex:TPasMPNativeInt;
      LastIndex:TPasMPNativeInt;
      Granularity:TPasMPInt32;
      Depth:TPasMPInt32;
      CanSpread:longbool;
      RecursiveSplit:longbool;
     end;

     PPasMPParallelForReferenceProcedureJobData=^TPasMPParallelForReferenceProcedureJobData;
     TPasMPParallelForReferenceProcedureJobData=record
      StartJobData:PPasMPParallelForReferenceProcedureStartJobData;
      FirstIndex:TPasMPNativeInt;
      LastIndex:TPasMPNativeInt;
      RemainDepth:TPasMPInt32;
     end;

procedure TPasMP.ParallelForJobReferenceProcedureProcess(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
var JobData:PPasMPParallelForReferenceProcedureJobData;
    StartJobData:PPasMPParallelForReferenceProcedureStartJobData;
begin
 JobData:=PPasMPParallelForReferenceProcedureJobData(pointer(@Job^.Data));
 StartJobData:=JobData^.StartJobData;
 if assigned(StartJobData^.ParallelForReferenceProcedure) then begin
  StartJobData^.ParallelForReferenceProcedure(Job,ThreadIndex,StartJobData^.Data,JobData^.FirstIndex,JobData^.LastIndex);
 end;
end;

procedure TPasMP.ParallelForJobReferenceProcedureFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
var NewJobs:array[0..1] of PPasMPJob;
    StartJobData:PPasMPParallelForReferenceProcedureStartJobData;
    JobData,NewJobData:PPasMPParallelForReferenceProcedureJobData;
begin
 JobData:=PPasMPParallelForReferenceProcedureJobData(pointer(@Job^.Data));
 if JobData^.FirstIndex<=JobData^.LastIndex then begin
  StartJobData:=JobData^.StartJobData;
  if (((JobData^.LastIndex-JobData^.FirstIndex)+1)<=StartJobData^.Granularity) or (JobData^.RemainDepth=0) or not StartJobData^.RecursiveSplit then begin
   ParallelForJobReferenceProcedureProcess(Job,ThreadIndex);
  end else begin
   if ((Job^.InternalData and PasMPJobFlagHasOwnerWorkerThread)<>0) and
      (TPasMPInt32((Job^.InternalData shr PasMPJobThreadIndexShift) and PasMPJobThreadIndexMask)<>ThreadIndex) then begin
    // It is a stolen job => split in two halfs
    begin
     NewJobs[0]:=Acquire(ParallelForJobReferenceProcedureFunction,nil,nil,Job^.InternalData and PasMPJobTagShiftedMask,Job^.AreaMask);
     NewJobData:=PPasMPParallelForReferenceProcedureJobData(pointer(@NewJobs[0]^.Data));
     NewJobData^.StartJobData:=StartJobData;
     NewJobData^.FirstIndex:=JobData^.FirstIndex;
     NewJobData^.LastIndex:=(JobData^.FirstIndex+((JobData^.LastIndex-JobData^.FirstIndex) div 2))-1;
     NewJobData^.RemainDepth:=JobData^.RemainDepth-1;
    end;
    begin
     NewJobs[1]:=Acquire(ParallelForJobReferenceProcedureFunction,nil,nil,Job^.InternalData and PasMPJobTagShiftedMask,Job^.AreaMask);
     NewJobData:=PPasMPParallelForReferenceProcedureJobData(pointer(@NewJobs[1]^.Data));
     NewJobData^.StartJobData:=StartJobData;
     NewJobData^.FirstIndex:=PPasMPParallelForReferenceProcedureJobData(pointer(@NewJobs[0]^.Data))^.LastIndex+1;
     NewJobData^.LastIndex:=JobData^.LastIndex;
     NewJobData^.RemainDepth:=JobData^.RemainDepth-1;
    end;
    Invoke(NewJobs);
   end else begin
    // It is a non-stolen job => split and increment by granularity count
    begin
     NewJobs[0]:=Acquire(ParallelForJobReferenceProcedureFunction,nil,nil,Job^.InternalData and PasMPJobTagShiftedMask,Job^.AreaMask);
     NewJobData:=PPasMPParallelForReferenceProcedureJobData(pointer(@NewJobs[0]^.Data));
     NewJobData^.StartJobData:=StartJobData;
     NewJobData^.FirstIndex:=JobData^.FirstIndex+StartJobData^.Granularity;
     NewJobData^.LastIndex:=JobData^.LastIndex;
     NewJobData^.RemainDepth:=JobData^.RemainDepth-1;
     JobData^.LastIndex:=NewJobData^.FirstIndex-1;
    end;
    Run(NewJobs[0]);
    ParallelForJobReferenceProcedureProcess(Job,ThreadIndex);
    WaitRelease(NewJobs[0]);
   end;
  end;
 end;
end;

procedure TPasMP.ParallelForStartJobReferenceProcedureFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
var NewJobs:array[0..31] of PPasMPJob;
    JobData:PPasMPParallelForReferenceProcedureStartJobData;
    NewJobData,NewJobDataEx:PPasMPParallelForReferenceProcedureJobData;
    Index,EndIndex,Granularity,Count,CountJobs,PartSize,Rest,Size:TPasMPNativeInt;
    JobIndex:TPasMPInt32;
    JobEx:TPasMPJob;
begin
 JobData:=PPasMPParallelForReferenceProcedureStartJobData(pointer(@Job^.Data));
 try
  Index:=JobData^.FirstIndex;
  EndIndex:=JobData^.LastIndex+1;
  if JobData^.FirstIndex<EndIndex then begin
   Granularity:=JobData^.Granularity;
   Count:=EndIndex-Index;
   if Count<=Granularity then begin
    JobEx:=Job^;
    NewJobDataEx:=PPasMPParallelForReferenceProcedureJobData(pointer(@JobEx.Data));
    NewJobDataEx^.StartJobData:=JobData;
    NewJobDataEx^.FirstIndex:=JobData^.FirstIndex;
    NewJobDataEx^.LastIndex:=JobData^.LastIndex;
    NewJobDataEx^.RemainDepth:=JobData^.Depth;
    ParallelForJobReferenceProcedureProcess(@JobEx,ThreadIndex);
   end else begin
    if JobData^.CanSpread or not JobData^.RecursiveSplit then begin
     // Only try to spread, when all worker threads (except us) are jobless
     CountJobs:=Count div Granularity;
    end else begin
     CountJobs:=1;
    end;
    if CountJobs<1 then begin
     CountJobs:=1;
    end else if CountJobs>length(NewJobs) then begin
     CountJobs:=length(NewJobs);
    end;
    PartSize:=Count div CountJobs;
    Rest:=Count-(CountJobs*PartSize);
    for JobIndex:=0 to CountJobs-1 do begin
     Size:=PartSize;
     if Rest>JobIndex then begin
      inc(Size);
     end;
     NewJobs[JobIndex]:=Acquire(ParallelForJobReferenceProcedureFunction,nil,nil,Job^.InternalData and PasMPJobTagShiftedMask,Job^.AreaMask);
     NewJobData:=PPasMPParallelForReferenceProcedureJobData(pointer(@NewJobs[JobIndex]^.Data));
     NewJobData^.StartJobData:=JobData;
     NewJobData^.FirstIndex:=Index;
     NewJobData^.LastIndex:=(Index+Size)-1;
     if NewJobData^.LastIndex>JobData^.LastIndex then begin
      NewJobData^.LastIndex:=JobData^.LastIndex;
     end;
     NewJobData^.RemainDepth:=JobData^.Depth;
     Run(NewJobs[JobIndex]);
     inc(Index,Size);
    end;
    for JobIndex:=0 to CountJobs-1 do begin
     WaitRelease(NewJobs[JobIndex]);
    end;
   end;
  end;
 finally
  Finalize(JobData^);
 end;
end;

function TPasMP.ParallelFor(const Data:pointer;const FirstIndex,LastIndex:TPasMPNativeInt;const ParallelForReferenceProcedure:TPasMPParallelForReferenceProcedure;const Granularity:TPasMPInt32;const Depth:TPasMPInt32;const ParentJob:PPasMPJob;const Flags:TPasMPUInt32;const AreaMask:TPasMPUInt32;const RecursiveSplit:Boolean):PPasMPJob;
var JobData:PPasMPParallelForReferenceProcedureStartJobData;
begin
 result:=Acquire(ParallelForStartJobReferenceProcedureFunction,nil,ParentJob,Flags,AreaMask);
 JobData:=PPasMPParallelForReferenceProcedureStartJobData(pointer(@result^.Data));
 Initialize(JobData^);
 JobData^.ParallelForReferenceProcedure:=ParallelForReferenceProcedure;
 JobData^.Data:=Data;
 JobData^.FirstIndex:=FirstIndex;
 JobData^.LastIndex:=LastIndex;
 JobData^.Granularity:=Granularity;
 JobData^.Depth:=Depth;
 JobData^.CanSpread:=CanSpread;
 JobData^.RecursiveSplit:=RecursiveSplit;
end;
{$endif}

type PPasMPParallelForStartJobData=^TPasMPParallelForStartJobData;
     TPasMPParallelForStartJobData=record
      Method:TMethod;
      Data:pointer;
      FirstIndex:TPasMPNativeInt;
      LastIndex:TPasMPNativeInt;
      Granularity:TPasMPInt32;
      Depth:TPasMPInt32;
      CanSpread:longbool;
      RecursiveSplit:longbool;
     end;

     PPasMPParallelForJobData=^TPasMPParallelForJobData;
     TPasMPParallelForJobData=record
      StartJobData:PPasMPParallelForStartJobData;
      FirstIndex:TPasMPNativeInt;
      LastIndex:TPasMPNativeInt;
      RemainDepth:TPasMPInt32;
     end;

procedure TPasMP.ParallelForJobFunctionProcess(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
var JobData:PPasMPParallelForJobData;
    StartJobData:PPasMPParallelForStartJobData;
begin
 JobData:=PPasMPParallelForJobData(pointer(@Job^.Data));
 StartJobData:=JobData^.StartJobData;
 if assigned(StartJobData^.Method.Data) then begin
  TPasMPParallelForMethod(StartJobData^.Method)(Job,ThreadIndex,StartJobData^.Data,JobData^.FirstIndex,JobData^.LastIndex);
 end else begin
  TPasMPParallelForProcedure(StartJobData^.Method.Code)(Job,ThreadIndex,StartJobData^.Data,JobData^.FirstIndex,JobData^.LastIndex);
 end;
end;

procedure TPasMP.ParallelForJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
var NewJobs:array[0..1] of PPasMPJob;
    JobData,NewJobData:PPasMPParallelForJobData;
    StartJobData:PPasMPParallelForStartJobData;
begin
 JobData:=PPasMPParallelForJobData(pointer(@Job^.Data));
 if JobData^.FirstIndex<=JobData^.LastIndex then begin
  StartJobData:=JobData^.StartJobData;
  if (((JobData^.LastIndex-JobData^.FirstIndex)+1)<=StartJobData^.Granularity) or (JobData^.RemainDepth<=0) or not StartJobData^.RecursiveSplit then begin
   ParallelForJobFunctionProcess(Job,ThreadIndex);
  end else begin
   if ((Job^.InternalData and PasMPJobFlagHasOwnerWorkerThread)<>0) and
      (TPasMPInt32((Job^.InternalData shr PasMPJobThreadIndexShift) and PasMPJobThreadIndexMask)<>ThreadIndex) then begin
    // It is a stolen job => split in two halfs
    begin
     NewJobs[0]:=Acquire(ParallelForJobFunction,nil,nil,Job^.InternalData and PasMPJobTagShiftedMask,Job^.AreaMask);
     NewJobData:=PPasMPParallelForJobData(pointer(@NewJobs[0]^.Data));
     NewJobData^.StartJobData:=JobData^.StartJobData;
     NewJobData^.FirstIndex:=JobData^.FirstIndex;
     NewJobData^.LastIndex:=(JobData^.FirstIndex+((JobData^.LastIndex-JobData^.FirstIndex) div 2))-1;
     NewJobData^.RemainDepth:=JobData^.RemainDepth-1;
    end;
    begin
     NewJobs[1]:=Acquire(ParallelForJobFunction,nil,nil,Job^.InternalData and PasMPJobTagShiftedMask,Job^.AreaMask);
     NewJobData:=PPasMPParallelForJobData(pointer(@NewJobs[1]^.Data));
     NewJobData^.StartJobData:=JobData^.StartJobData;
     NewJobData^.FirstIndex:=PPasMPParallelForJobData(pointer(@NewJobs[0]^.Data))^.LastIndex+1;
     NewJobData^.LastIndex:=JobData^.LastIndex;
     NewJobData^.RemainDepth:=JobData^.RemainDepth-1;
    end;
    Invoke(NewJobs);
   end else begin
    // It is a non-stolen job => split and increment by granularity count
    begin
     NewJobs[0]:=Acquire(ParallelForJobFunction,nil,nil,Job^.InternalData and PasMPJobTagShiftedMask,Job^.AreaMask);
     NewJobData:=PPasMPParallelForJobData(pointer(@NewJobs[0]^.Data));
     NewJobData^.StartJobData:=JobData^.StartJobData;
     NewJobData^.FirstIndex:=JobData^.FirstIndex+StartJobData^.Granularity;
     NewJobData^.LastIndex:=JobData^.LastIndex;
     NewJobData^.RemainDepth:=JobData^.RemainDepth-1;
     JobData^.LastIndex:=NewJobData^.FirstIndex-1;
    end;
    Run(NewJobs[0]);
    ParallelForJobFunctionProcess(Job,ThreadIndex);
    WaitRelease(NewJobs[0]);
   end;
  end;
 end;
end;

procedure TPasMP.ParallelForStartJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
var NewJobs:array[0..31] of PPasMPJob;
    JobData:PPasMPParallelForStartJobData;
    NewJobData,NewJobDataEx:PPasMPParallelForJobData;
    Index,EndIndex,Granularity,Count,CountJobs,PartSize,Rest,Size:TPasMPNativeInt;
    JobIndex:TPasMPInt32;
    JobEx:TPasMPJob;
begin
 JobData:=PPasMPParallelForStartJobData(pointer(@Job^.Data));
 Index:=JobData^.FirstIndex;
 EndIndex:=JobData^.LastIndex+1;
 if JobData^.FirstIndex<EndIndex then begin
  Granularity:=JobData^.Granularity;
  Count:=EndIndex-Index;
  if Count<=Granularity then begin
   JobEx:=Job^;
   NewJobDataEx:=PPasMPParallelForJobData(pointer(@JobEx.Data));
   NewJobDataEx^.StartJobData:=JobData;
   NewJobDataEx^.FirstIndex:=JobData^.FirstIndex;
   NewJobDataEx^.LastIndex:=JobData^.LastIndex;
   NewJobDataEx^.RemainDepth:=JobData^.Depth;
   ParallelForJobFunctionProcess(@JobEx,ThreadIndex);
  end else begin
   if JobData^.CanSpread or not JobData^.RecursiveSplit then begin
    // Only try to spread, when all worker threads (except us) are jobless
    CountJobs:=Count div Granularity;
   end else begin
    CountJobs:=1;
   end;
   if CountJobs<1 then begin
    CountJobs:=1;
   end else if CountJobs>length(NewJobs) then begin
    CountJobs:=length(NewJobs);
   end;
   PartSize:=Count div CountJobs;
   Rest:=Count-(CountJobs*PartSize);
   NewJobs[0]:=nil;
   for JobIndex:=0 to CountJobs-1 do begin
    Size:=PartSize;
    if Rest>JobIndex then begin
     inc(Size);
    end;
    NewJobs[JobIndex]:=Acquire(ParallelForJobFunction,nil,nil,Job^.InternalData and PasMPJobTagShiftedMask,Job^.AreaMask);
    NewJobData:=PPasMPParallelForJobData(pointer(@NewJobs[JobIndex]^.Data));
    NewJobData^.StartJobData:=JobData;
    NewJobData^.FirstIndex:=Index;
    NewJobData^.LastIndex:=(Index+Size)-1;
    if NewJobData^.LastIndex>JobData^.LastIndex then begin
     NewJobData^.LastIndex:=JobData^.LastIndex;
    end;
    NewJobData^.RemainDepth:=JobData^.Depth;
    Run(NewJobs[JobIndex]);
    inc(Index,Size);
   end;
   for JobIndex:=0 to CountJobs-1 do begin
    WaitRelease(NewJobs[JobIndex]);
   end;
  end;
 end;
end;

function TPasMP.ParallelFor(const Data:pointer;const FirstIndex,LastIndex:TPasMPNativeInt;const ParallelForProcedure:TPasMPParallelForProcedure;const Granularity:TPasMPInt32;const Depth:TPasMPInt32;const ParentJob:PPasMPJob;const Flags:TPasMPUInt32;const AreaMask:TPasMPUInt32;const RecursiveSplit:Boolean):PPasMPJob;
var JobData:PPasMPParallelForStartJobData;
begin
 result:=Acquire(ParallelForStartJobFunction,nil,ParentJob,Flags,AreaMask);
 JobData:=PPasMPParallelForStartJobData(pointer(@result^.Data));
 JobData^.Method.Code:=Addr(ParallelForProcedure);
 JobData^.Method.Data:=nil;
 JobData^.Data:=Data;
 JobData^.FirstIndex:=FirstIndex;
 JobData^.LastIndex:=LastIndex;
 if Granularity<1 then begin
  JobData^.Granularity:=1;
 end else begin
  JobData^.Granularity:=Granularity;
 end;
 JobData^.Depth:=Depth;
 JobData^.CanSpread:=CanSpread;
 JobData^.RecursiveSplit:=RecursiveSplit;
end;

function TPasMP.ParallelFor(const Data:pointer;const FirstIndex,LastIndex:TPasMPNativeInt;const ParallelForMethod:TPasMPParallelForMethod;const Granularity:TPasMPInt32;const Depth:TPasMPInt32;const ParentJob:PPasMPJob;const Flags:TPasMPUInt32;const AreaMask:TPasMPUInt32;const RecursiveSplit:Boolean):PPasMPJob;
var JobData:PPasMPParallelForStartJobData;
begin
 result:=Acquire(ParallelForStartJobFunction,nil,ParentJob,Flags,AreaMask);
 JobData:=PPasMPParallelForStartJobData(pointer(@result^.Data));
 JobData^.Method:=TMethod(ParallelForMethod);
 JobData^.Data:=Data;
 JobData^.FirstIndex:=FirstIndex;
 JobData^.LastIndex:=LastIndex;
 if Granularity<1 then begin
  JobData^.Granularity:=1;
 end else begin
  JobData^.Granularity:=Granularity;
 end;
 JobData^.Depth:=Depth;
 JobData^.CanSpread:=CanSpread;
 JobData^.RecursiveSplit:=RecursiveSplit;
end;

type PPasMPParallelDirectIntroSortJobData=^TPasMPParallelDirectIntroSortJobData;
     TPasMPParallelDirectIntroSortJobData=record
      Items:pointer;
      Left:TPasMPNativeInt;
      Right:TPasMPNativeInt;
      Depth:TPasMPInt32;
      ElementSize:TPasMPInt32;
      Granularity:TPasMPInt32;
      CompareFunc:TPasMPParallelSortCompareFunction;
     end;

procedure TPasMP.ParallelDirectIntroSortJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
type PByteArray=^TByteArray;
     TByteArray=array[0..$3fffffff] of TPasMPUInt8;
var NewJobs:array[0..1] of PPasMPJob;
    JobData,NewJobData:PPasMPParallelDirectIntroSortJobData;
    Left,Right,Size,Parent,Child,Middle,Pivot,i,j,iA,iB,iC:TPasMPNativeInt;
    ElementSize:TPasMPInt32;
    CompareFunc:TPasMPParallelSortCompareFunction;
    Items{$ifdef PasMPAlternativeDirectHeapSort},Temp{$endif}:pointer;
begin
 JobData:=PPasMPParallelDirectIntroSortJobData(pointer(@Job^.Data));
 Left:=JobData^.Left;
 Right:=JobData^.Right;
 if Left<Right then begin
  Items:=JobData^.Items;
  ElementSize:=JobData^.ElementSize;
  CompareFunc:=JobData^.CompareFunc;
  Size:=(Right-Left)+1;
  if Size<16 then begin
   // Insertion sort
   iA:=Left;
   iB:=iA+1;
   while iB<=Right do begin
    iC:=iB;
    while (iA>=Left) and
          (iC>=Left) and
          (CompareFunc(pointer(@PByteArray(Items)^[iA*ElementSize]),pointer(@PByteArray(Items)^[iC*ElementSize]))>0) do begin
     MemorySwap(@PByteArray(Items)^[iA*ElementSize],@PByteArray(Items)^[iC*ElementSize],ElementSize);
     dec(iA);
     dec(iC);
    end;
    iA:=iB;
    inc(iB);
   end;
  end else begin
   if (JobData^.Depth=0) or (Size<=JobData^.Granularity) then begin
    // Heap sort
{$ifdef PasMPAlternativeDirectHeapSort}
    GetMem(Temp,JobData^.ElementSize);
    try
     i:=Size div 2;
     repeat
      if i>0 then begin
       dec(i);
       Move(PByteArray(Items)^[(Left+i)*ElementSize],Temp^,ElementSize);
      end else begin
       dec(Size);
       if Size>0 then begin
        Move(PByteArray(Items)^[(Left+Size)*ElementSize],Temp^,ElementSize);
        Move(PByteArray(Items)^[Left*ElementSize],PByteArray(Items)^[(Left+Size)*ElementSize],ElementSize);
       end else begin
        break;
       end;
      end;
      Parent:=i;
      Child:=(i*2)+1;
      while Child<Size do begin
       if ((Child+1)<Size) and (CompareFunc(pointer(@PByteArray(Items)^[((Left+Child)+1)*ElementSize]),pointer(@PByteArray(Items)^[(Left+Child)*ElementSize]))>0) then begin
        inc(Child);
       end;
       if CompareFunc(pointer(@PByteArray(Items)^[(Left+Child)*ElementSize]),Temp)>0 then begin
        Move(PByteArray(Items)^[(Left+Child)*ElementSize],PByteArray(Items)^[(Left+Parent)*ElementSize],ElementSize);
        Parent:=Child;
        Child:=(Parent*2)+1;
       end else begin
        break;
       end;
      end;
      Move(Temp^,PByteArray(Items)^[(Left+Parent)*ElementSize],ElementSize);
     until false;
    finally
     FreeMem(Temp);
    end;
{$else}
    i:=Size div 2;
    repeat
     if i>0 then begin
      dec(i);
     end else begin
      dec(Size);
      if Size>0 then begin
       MemorySwap(@PByteArray(Items)^[(Left+Size)*ElementSize],@PByteArray(Items)^[Left*ElementSize],ElementSize);
      end else begin
       break;
      end;
     end;
     Parent:=i;
     repeat
      Child:=(Parent*2)+1;
      if Child<Size then begin
       if (Child<(Size-1)) and (CompareFunc(pointer(@PByteArray(Items)^[(Left+Child)*ElementSize]),pointer(@PByteArray(Items)^[(Left+Child+1)*ElementSize]))<0) then begin
        inc(Child);
       end;
       if CompareFunc(pointer(@PByteArray(Items)^[(Left+Parent)*ElementSize]),pointer(@PByteArray(Items)^[(Left+Child)*ElementSize]))<0 then begin
        MemorySwap(@PByteArray(Items)^[(Left+Parent)*ElementSize],@PByteArray(Items)^[(Left+Child)*ElementSize],ElementSize);
        Parent:=Child;
        continue;
       end;
      end;
      break;
     until false;
    until false;
{$endif}
   end else begin
    // Quick sort width median-of-three optimization
    Middle:=Left+((Right-Left) shr 1);
    if (Right-Left)>3 then begin
     if CompareFunc(pointer(@PByteArray(Items)^[Left*ElementSize]),pointer(@PByteArray(Items)^[Middle*ElementSize]))>0 then begin
      MemorySwap(@PByteArray(Items)^[Left*ElementSize],@PByteArray(Items)^[Middle*ElementSize],ElementSize);
     end;
     if CompareFunc(pointer(@PByteArray(Items)^[Left*ElementSize]),pointer(@PByteArray(Items)^[Right*ElementSize]))>0 then begin
      MemorySwap(@PByteArray(Items)^[Left*ElementSize],@PByteArray(Items)^[Right*ElementSize],ElementSize);
     end;
     if CompareFunc(pointer(@PByteArray(Items)^[Middle*ElementSize]),pointer(@PByteArray(Items)^[Right*ElementSize]))>0 then begin
      MemorySwap(@PByteArray(Items)^[Middle*ElementSize],@PByteArray(Items)^[Right*ElementSize],ElementSize);
     end;
    end;
    Pivot:=Middle;
    i:=Left;
    j:=Right;
    repeat
     while (i<Right) and (CompareFunc(pointer(@PByteArray(Items)^[i*ElementSize]),pointer(@PByteArray(Items)^[Pivot*ElementSize]))<0) do begin
      inc(i);
     end;
     while (j>=i) and (CompareFunc(pointer(@PByteArray(Items)^[j*ElementSize]),pointer(@PByteArray(Items)^[Pivot*ElementSize]))>0) do begin
      dec(j);
     end;
     if i>j then begin
      break;
     end else begin
      if i<>j then begin
       MemorySwap(@PByteArray(Items)^[i*ElementSize],@PByteArray(Items)^[j*ElementSize],ElementSize);
       if Pivot=i then begin
        Pivot:=j;
       end else if Pivot=j then begin
        Pivot:=i;
       end;
      end;
      inc(i);
      dec(j);
     end;
    until false;
    if Left<j then begin
     NewJobs[0]:=Acquire(ParallelDirectIntroSortJobFunction,nil,nil,Job^.InternalData and PasMPJobTagShiftedMask,Job^.AreaMask);
     NewJobData:=PPasMPParallelDirectIntroSortJobData(pointer(@NewJobs[0]^.Data));
     NewJobData^.Items:=JobData^.Items;
     NewJobData^.Left:=Left;
     NewJobData^.Right:=j;
     NewJobData^.Depth:=JobData^.Depth-1;
     NewJobData^.ElementSize:=JobData^.ElementSize;
     NewJobData^.Granularity:=JobData^.Granularity;
     NewJobData^.CompareFunc:=CompareFunc;
    end else begin
     NewJobs[0]:=nil;
    end;
    if i<Right then begin
     NewJobs[1]:=Acquire(ParallelDirectIntroSortJobFunction,nil,nil,Job^.InternalData and PasMPJobTagShiftedMask,Job^.AreaMask);
     NewJobData:=PPasMPParallelDirectIntroSortJobData(pointer(@NewJobs[1]^.Data));
     NewJobData^.Items:=JobData^.Items;
     NewJobData^.Left:=i;
     NewJobData^.Right:=Right;
     NewJobData^.Depth:=JobData^.Depth-1;
     NewJobData^.ElementSize:=JobData^.ElementSize;
     NewJobData^.Granularity:=JobData^.Granularity;
     NewJobData^.CompareFunc:=CompareFunc;
    end else begin
     NewJobs[1]:=nil;
    end;
    Invoke(NewJobs);
   end;
  end;
 end;
end;

function TPasMP.ParallelDirectIntroSort(const Items:pointer;const Left,Right:TPasMPNativeInt;const ElementSize:TPasMPInt32;const CompareFunc:TPasMPParallelSortCompareFunction;const Granularity:TPasMPInt32=16;const Depth:TPasMPInt32=PasMPDefaultDepth;const ParentJob:PPasMPJob=nil;const Flags:TPasMPUInt32=0;const AreaMask:TPasMPUInt32=0):PPasMPJob;
var JobData:PPasMPParallelDirectIntroSortJobData;
begin
 result:=Acquire(ParallelDirectIntroSortJobFunction,nil,ParentJob,Flags,AreaMask);
 JobData:=PPasMPParallelDirectIntroSortJobData(pointer(@result^.Data));
 JobData^.Items:=Items;
 JobData^.Left:=Left;
 JobData^.Right:=Right;
 if Left<Right then begin
  JobData^.Depth:=TPasMPMath.BitScanReverse((Right-Left)+1) shl 1;
  if JobData^.Depth>Depth then begin
   JobData^.Depth:=Depth;
  end;
 end else begin
  JobData^.Depth:=0;
 end;
 JobData^.ElementSize:=ElementSize;
 JobData^.Granularity:=Granularity;
 JobData^.CompareFunc:=CompareFunc;
end;

type PPasMPParallelIndirectIntroSortJobData=^TPasMPParallelIndirectIntroSortJobData;
     TPasMPParallelIndirectIntroSortJobData=record
      Items:pointer;
      Left:TPasMPNativeInt;
      Right:TPasMPNativeInt;
      Depth:TPasMPInt32;
      Granularity:TPasMPInt32;
      CompareFunc:TPasMPParallelSortCompareFunction;
     end;

procedure TPasMP.ParallelIndirectIntroSortJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
type PPointers=^TPointers;
     TPointers=array[0..($7fffffff div SizeOf(pointer))-1] of pointer;
var NewJobs:array[0..1] of PPasMPJob;
    JobData,NewJobData:PPasMPParallelIndirectIntroSortJobData;
    Left,Right,Size,Parent,Child,Middle,i,j:TPasMPNativeInt;
    CompareFunc:TPasMPParallelSortCompareFunction;
    Items,Temp,Pivot:pointer;
begin
 JobData:=PPasMPParallelIndirectIntroSortJobData(pointer(@Job^.Data));
 Left:=JobData^.Left;
 Right:=JobData^.Right;
 if Left<Right then begin
  Items:=JobData^.Items;
  CompareFunc:=JobData^.CompareFunc;
  Size:=(Right-Left)+1;
  if Size<16 then begin
   // Insertion sort
   for i:=Left+1 to Right do begin
    Temp:=PPointers(Items)^[i];
    j:=i-1;
    if (j>=Left) and (CompareFunc(PPointers(Items)^[j],Temp)>0) then begin
     repeat
      PPointers(Items)^[j+1]:=PPointers(Items)^[j];
      dec(j);
     until not ((j>=Left) and (CompareFunc(PPointers(Items)^[j],Temp)>0));
     PPointers(Items)^[j+1]:=Temp;
    end;
   end;
  end else begin
   if (JobData^.Depth=0) or (Size<=JobData^.Granularity) then begin
    // Heap sort
{$ifdef PasMPAlternativeIndirectHeapSort}
    i:=Size div 2;
    repeat
     if i>0 then begin
      dec(i);
     end else begin
      dec(Size);
      if Size>0 then begin
       Temp:=PPointers(Items)^[Left+Size];
       PPointers(Items)^[Left+Size]:=PPointers(Items)^[Left];
       PPointers(Items)^[Left]:=Temp;
      end else begin
       break;
      end;
     end;
     Parent:=i;
     repeat
      Child:=(Parent*2)+1;
      if Child<Size then begin
       if (Child<(Size-1)) and (CompareFunc(PPointers(Items)^[Left+Child],PPointers(Items)^[Left+Child+1])<0) then begin
        inc(Child);
       end;
       if CompareFunc(PPointers(Items)^[Left+Parent],PPointers(Items)^[Left+Child])<0 then begin
        Temp:=PPointers(Items)^[Left+Parent];
        PPointers(Items)^[Left+Parent]:=PPointers(Items)^[Left+Child];
        PPointers(Items)^[Left+Child]:=Temp;
        Parent:=Child;
        continue;
       end;
      end;
      break;
     until false;
    until false;
{$else}
    i:=Size div 2;
    Temp:=nil;
    repeat
     if i>0 then begin
      dec(i);
      Temp:=PPointers(Items)^[Left+i];
     end else begin
      dec(Size);
      if Size>0 then begin
       Temp:=PPointers(Items)^[Left+Size];
       PPointers(Items)^[Left+Size]:=PPointers(Items)^[Left];
      end else begin
       break;
      end;
     end;
     Parent:=i;
     Child:=(i*2)+1;
     while Child<Size do begin
      if ((Child+1)<Size) and (CompareFunc(PPointers(Items)^[Left+Child+1],PPointers(Items)^[Left+Child])>0) then begin
       inc(Child);
      end;
      if CompareFunc(PPointers(Items)^[Left+Child],Temp)>0 then begin
       PPointers(Items)^[Left+Parent]:=PPointers(Items)^[Left+Child];
       Parent:=Child;
       Child:=(Parent*2)+1;
      end else begin
       break;
      end;
     end;
     PPointers(Items)^[Left+Parent]:=Temp;
    until false;
{$endif}
   end else begin
    // Quick sort width median-of-three optimization
    Middle:=Left+((Right-Left) shr 1);
    if (Right-Left)>3 then begin
     if CompareFunc(PPointers(Items)^[Left],PPointers(Items)^[Middle])>0 then begin
      Temp:=PPointers(Items)^[Left];
      PPointers(Items)^[Left]:=PPointers(Items)^[Middle];
      PPointers(Items)^[Middle]:=Temp;
     end;
     if CompareFunc(PPointers(Items)^[Left],PPointers(Items)^[Right])>0 then begin
      Temp:=PPointers(Items)^[Left];
      PPointers(Items)^[Left]:=PPointers(Items)^[Right];
      PPointers(Items)^[Right]:=Temp;
     end;
     if CompareFunc(PPointers(Items)^[Middle],PPointers(Items)^[Right])>0 then begin
      Temp:=PPointers(Items)^[Middle];
      PPointers(Items)^[Middle]:=PPointers(Items)^[Right];
      PPointers(Items)^[Right]:=Temp;
     end;
    end;
    Pivot:=PPointers(Items)^[Middle];
    i:=Left;
    j:=Right;
    repeat
     while (i<Right) and (CompareFunc(PPointers(Items)^[i],Pivot)<0) do begin
      inc(i);
     end;
     while (j>=i) and (CompareFunc(PPointers(Items)^[j],Pivot)>0) do begin
      dec(j);
     end;
     if i>j then begin
      break;
     end else begin
      if i<>j then begin
       Temp:=PPointers(Items)^[i];
       PPointers(Items)^[i]:=PPointers(Items)^[j];
       PPointers(Items)^[j]:=Temp;
      end;
      inc(i);
      dec(j);
     end;
    until false;
    if Left<j then begin
     NewJobs[0]:=Acquire(ParallelIndirectIntroSortJobFunction,nil,nil,Job^.InternalData and PasMPJobTagShiftedMask,Job^.AreaMask);
     NewJobData:=PPasMPParallelIndirectIntroSortJobData(pointer(@NewJobs[0]^.Data));
     NewJobData^.Items:=JobData^.Items;
     NewJobData^.Left:=Left;
     NewJobData^.Right:=j;
     NewJobData^.Depth:=JobData^.Depth-1;
     NewJobData^.Granularity:=JobData^.Granularity;
     NewJobData^.CompareFunc:=CompareFunc;
    end else begin
     NewJobs[0]:=nil;
    end;
    if i<Right then begin
     NewJobs[1]:=Acquire(ParallelIndirectIntroSortJobFunction,nil,nil,Job^.InternalData and PasMPJobTagShiftedMask,Job^.AreaMask);
     NewJobData:=PPasMPParallelIndirectIntroSortJobData(pointer(@NewJobs[1]^.Data));
     NewJobData^.Items:=JobData^.Items;
     NewJobData^.Left:=i;
     NewJobData^.Right:=Right;
     NewJobData^.Depth:=JobData^.Depth-1;
     NewJobData^.Granularity:=JobData^.Granularity;
     NewJobData^.CompareFunc:=CompareFunc;
    end else begin
     NewJobs[1]:=nil;
    end;
    Invoke(NewJobs);
   end;
  end;
 end;
end;

function TPasMP.ParallelIndirectIntroSort(const Items:pointer;const Left,Right:TPasMPNativeInt;const CompareFunc:TPasMPParallelSortCompareFunction;const Granularity:TPasMPInt32=16;const Depth:TPasMPInt32=PasMPDefaultDepth;const ParentJob:PPasMPJob=nil;const Flags:TPasMPUInt32=0;const AreaMask:TPasMPUInt32=0):PPasMPJob;
var JobData:PPasMPParallelIndirectIntroSortJobData;
begin
 result:=Acquire(ParallelIndirectIntroSortJobFunction,nil,ParentJob,Flags,AreaMask);
 JobData:=PPasMPParallelIndirectIntroSortJobData(pointer(@result^.Data));
 JobData^.Items:=Items;
 JobData^.Left:=Left;
 JobData^.Right:=Right;
 if Left<Right then begin
  JobData^.Depth:=TPasMPMath.BitScanReverse((Right-Left)+1) shl 1;
  if JobData^.Depth>Depth then begin
   JobData^.Depth:=Depth;
  end;
 end else begin
  JobData^.Depth:=0;
 end;
 JobData^.Granularity:=Granularity;
 JobData^.CompareFunc:=CompareFunc;
end;

type PPasMPParallelDirectMergeSortData=^TPasMPParallelDirectMergeSortData;
     TPasMPParallelDirectMergeSortData=record
      Items:pointer;
      Temp:pointer;
      ElementSize:TPasMPInt32;
      Granularity:TPasMPInt32;
      CompareFunc:TPasMPParallelSortCompareFunction;
     end;

     PPasMPParallelDirectMergeSortJobData=^TPasMPParallelDirectMergeSortJobData;
     TPasMPParallelDirectMergeSortJobData=record
      Data:PPasMPParallelDirectMergeSortData;
      Left:TPasMPNativeInt;
      Right:TPasMPNativeInt;
      Depth:TPasMPInt32;
     end;

procedure TPasMP.ParallelDirectMergeSortJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
type PByteArray=^TByteArray;
     TByteArray=array[0..$3fffffff] of TPasMPUInt8;
var NewJobs:array[0..1] of PPasMPJob;
    JobData,NewJobData:PPasMPParallelDirectMergeSortJobData;
    Left,Right,Size,Middle,iA,iB,iC,Count:TPasMPNativeInt;
    ElementSize:TPasMPInt32;
    CompareFunc:TPasMPParallelSortCompareFunction;
    Items,Temp:pointer;
    Data:PPasMPParallelDirectMergeSortData;
begin
 JobData:=PPasMPParallelDirectMergeSortJobData(pointer(@Job^.Data));
 Left:=JobData^.Left;
 Right:=JobData^.Right;
 if Left<Right then begin
  Data:=JobData^.Data;
  Items:=Data^.Items;
  ElementSize:=Data^.ElementSize;
  CompareFunc:=Data^.CompareFunc;
  Size:=(Right-Left)+1;
  case Size of
   2:begin
    if CompareFunc(pointer(@PByteArray(Items)^[Left*ElementSize]),pointer(@PByteArray(Items)^[Right*ElementSize]))>0 then begin
     MemorySwap(@PByteArray(Items)^[Left*ElementSize],@PByteArray(Items)^[Right*ElementSize],ElementSize);
    end;
   end;
   3:begin
    Middle:=Left+1;
    if CompareFunc(pointer(@PByteArray(Items)^[Left*ElementSize]),pointer(@PByteArray(Items)^[Middle*ElementSize]))<=0 then begin
     if CompareFunc(pointer(@PByteArray(Items)^[Middle*ElementSize]),pointer(@PByteArray(Items)^[Right*ElementSize]))<=0 then begin
      // 0 <= 1 <= 2
     end else if CompareFunc(pointer(@PByteArray(Items)^[Left*ElementSize]),pointer(@PByteArray(Items)^[Right*ElementSize]))<=0 then begin
      // 0 <= 2 < 1
      MemorySwap(@PByteArray(Items)^[Middle*ElementSize],@PByteArray(Items)^[Right*ElementSize],ElementSize);
     end else begin
      // 2 < 0 <= 1
      MemorySwap(@PByteArray(Items)^[Left*ElementSize],@PByteArray(Items)^[Right*ElementSize],ElementSize);
      MemorySwap(@PByteArray(Items)^[Middle*ElementSize],@PByteArray(Items)^[Right*ElementSize],ElementSize);
     end;
    end else begin
     if CompareFunc(pointer(@PByteArray(Items)^[Left*ElementSize]),pointer(@PByteArray(Items)^[Right*ElementSize]))<=0 then begin
      // 1 < 0 <= 2
      MemorySwap(@PByteArray(Items)^[Left*ElementSize],@PByteArray(Items)^[Middle*ElementSize],ElementSize);
     end else if CompareFunc(pointer(@PByteArray(Items)^[Middle*ElementSize]),pointer(@PByteArray(Items)^[Right*ElementSize]))<=0 then begin
      // 1 <= 2 < 0
      MemorySwap(@PByteArray(Items)^[Left*ElementSize],@PByteArray(Items)^[Middle*ElementSize],ElementSize);
      MemorySwap(@PByteArray(Items)^[Middle*ElementSize],@PByteArray(Items)^[Right*ElementSize],ElementSize);
     end else begin
      // 2 < 1 < 0
      MemorySwap(@PByteArray(Items)^[Left*ElementSize],@PByteArray(Items)^[Right*ElementSize],ElementSize);
     end;
    end;
   end;
   else begin
    if (JobData^.Depth=0) or (Size<=JobData^.Data.Granularity) then begin
{    // Insertion sort (with temporary memory)
     GetMem(Temp,ElementSize);
     try
      for iA:=Left+1 to Right do begin
       iB:=iA-1;
       if (iB>=Left) and (CompareFunc(pointer(@PByteArray(Items)^[iB*ElementSize]),pointer(@PByteArray(Items)^[iA*ElementSize]))>0) then begin
        Move(PByteArray(Items)^[iA*ElementSize],Temp^,ElementSize);
        repeat
         Move(PByteArray(Items)^[iB*ElementSize],PByteArray(Items)^[(iB+1)*ElementSize],ElementSize);
         dec(iB);
        until not ((iB>=Left) and (CompareFunc(pointer(@PByteArray(Items)^[iB*ElementSize]),Temp)>0));
        Move(Temp^,PByteArray(Items)^[(iB+1)*ElementSize],ElementSize);
       end;
      end;
     finally
      FreeMem(Temp);
     end;}
     // Insertion sort (in-place)
     iA:=Left;
     iB:=iA+1;
     while iB<=Right do begin
      iC:=iB;
      while (iA>=Left) and
            (iC>=Left) and
            (CompareFunc(pointer(@PByteArray(Items)^[iA*ElementSize]),pointer(@PByteArray(Items)^[iC*ElementSize]))>0) do begin
       MemorySwap(@PByteArray(Items)^[iA*ElementSize],@PByteArray(Items)^[iC*ElementSize],ElementSize);
       dec(iA);
       dec(iC);
      end;
      iA:=iB;
      inc(iB);
     end;
    end else begin
     Middle:=Left+((Right-Left) shr 1);
     if Left<Middle then begin
      NewJobs[0]:=Acquire(ParallelDirectMergeSortJobFunction,nil,nil,Job^.InternalData and PasMPJobTagShiftedMask,Job^.AreaMask);
      NewJobData:=PPasMPParallelDirectMergeSortJobData(pointer(@NewJobs[0]^.Data));
      NewJobData^.Data:=Data;
      NewJobData^.Left:=Left;
      NewJobData^.Right:=Middle-1;
      NewJobData^.Depth:=JobData^.Depth-1;
     end else begin
      NewJobs[0]:=nil;
     end;
     if Middle<=Right then begin
      NewJobs[1]:=Acquire(ParallelDirectMergeSortJobFunction,nil,nil,Job^.InternalData and PasMPJobTagShiftedMask,Job^.AreaMask);
      NewJobData:=PPasMPParallelDirectMergeSortJobData(pointer(@NewJobs[1]^.Data));
      NewJobData^.Data:=JobData^.Data;
      NewJobData^.Left:=Middle;
      NewJobData^.Right:=Right;
      NewJobData^.Depth:=JobData^.Depth-1;
     end else begin
      NewJobs[1]:=nil;
     end;
     Invoke(NewJobs);
     begin
      // Merge
      Temp:=Data^.Temp;
      iA:=Left;
      iB:=Middle;
      iC:=Left;
      while (iA<Middle) and
            (CompareFunc(pointer(@PByteArray(Items)^[iA*ElementSize]),pointer(@PByteArray(Items)^[iB*ElementSize]))<=0) do begin
       inc(iA);
      end;
      if iA<Middle then begin
       Left:=iA;
       iC:=iA;
       Move(PByteArray(Items)^[iB*ElementSize],PByteArray(Temp)^[iC*ElementSize],ElementSize);
       inc(iB);
       inc(iC);
       while (iA<Middle) and (iB<=Right) do begin
        if CompareFunc(pointer(@PByteArray(Items)^[iA*ElementSize]),pointer(@PByteArray(Items)^[iB*ElementSize]))>0 then begin
         Move(PByteArray(Items)^[iB*ElementSize],PByteArray(Temp)^[iC*ElementSize],ElementSize);
         inc(iB);
        end else begin
         Move(PByteArray(Items)^[iA*ElementSize],PByteArray(Temp)^[iC*ElementSize],ElementSize);
         inc(iA);
        end;
        inc(iC);
       end;
       if iA<Middle then begin
        Count:=Middle-iA;
        Move(PByteArray(Items)^[iA*ElementSize],PByteArray(Temp)^[iC*ElementSize],Count*ElementSize);
        inc(iC,Count);
       end;
       if iB<=Right then begin
        Count:=(Right-iB)+1;
        Move(PByteArray(Items)^[iB*ElementSize],PByteArray(Temp)^[iC*ElementSize],Count*ElementSize);
       end;
       Move(PByteArray(Temp)^[Left*ElementSize],PByteArray(Items)^[Left*ElementSize],((Right-Left)+1)*ElementSize);
      end;
     end;
    end;
   end;
  end;
 end;
end;

type PPasMPParallelDirectMergeSortRootJobData=^TPasMPParallelDirectMergeSortRootJobData;
     TPasMPParallelDirectMergeSortRootJobData=record
      Items:pointer;
      Left:TPasMPNativeInt;
      Right:TPasMPNativeInt;
      Depth:TPasMPInt32;
      ElementSize:TPasMPInt32;
      Granularity:TPasMPInt32;
      CompareFunc:TPasMPParallelSortCompareFunction;
     end;

procedure TPasMP.ParallelDirectMergeSortRootJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
var Data:TPasMPParallelDirectMergeSortData;
    JobData:PPasMPParallelDirectMergeSortRootJobData;
    ChildJobData:PPasMPParallelDirectMergeSortJobData;
    ChildJob:PPasMPJob;
begin
 JobData:=PPasMPParallelDirectMergeSortRootJobData(pointer(@Job^.Data));
 GetMem(Data.Temp,((JobData^.Right-JobData^.Left)+1)*JobData^.ElementSize);
 try
  Data.Items:=JobData^.Items;
  Data.ElementSize:=JobData^.ElementSize;
  Data.Granularity:=JobData^.Granularity;
  Data.CompareFunc:=JobData^.CompareFunc;
  ChildJob:=Acquire(ParallelDirectMergeSortJobFunction,nil,nil,Job^.InternalData and PasMPJobTagShiftedMask,Job^.AreaMask);
  ChildJobData:=PPasMPParallelDirectMergeSortJobData(pointer(@ChildJob^.Data));
  ChildJobData^.Data:=@Data;
  ChildJobData^.Left:=JobData^.Left;
  ChildJobData^.Right:=JobData^.Right;
  ChildJobData^.Depth:=JobData^.Depth;
  Invoke(ChildJob);
 finally
  FreeMem(Data.Temp);
 end;
end;

function TPasMP.ParallelDirectMergeSort(const Items:pointer;const Left,Right:TPasMPNativeInt;const ElementSize:TPasMPInt32;const CompareFunc:TPasMPParallelSortCompareFunction;const Granularity:TPasMPInt32=16;const Depth:TPasMPInt32=PasMPDefaultDepth;const ParentJob:PPasMPJob=nil;const Flags:TPasMPUInt32=0;const AreaMask:TPasMPUInt32=0):PPasMPJob;
var JobData:PPasMPParallelDirectMergeSortRootJobData;
begin
 if ((Left+1)<Right) and (ElementSize>0) then begin
  result:=Acquire(ParallelDirectMergeSortRootJobFunction,nil,ParentJob,Flags,AreaMask);
  JobData:=PPasMPParallelDirectMergeSortRootJobData(pointer(@result^.Data));
  JobData^.Items:=Items;
  JobData^.Left:=Left;
  JobData^.Right:=Right;
  JobData^.ElementSize:=ElementSize;
  JobData^.Granularity:=Granularity;
  JobData^.CompareFunc:=CompareFunc;
  if Left<Right then begin
   JobData^.Depth:=TPasMPMath.BitScanReverse((Right-Left)+1);
   if JobData^.Depth>Depth then begin
    JobData^.Depth:=Depth;
   end;
  end else begin
   JobData^.Depth:=0;
  end;
 end else begin
  result:=nil;
 end;
end;

type PPasMPParallelIndirectMergeSortData=^TPasMPParallelIndirectMergeSortData;
     TPasMPParallelIndirectMergeSortData=record
      Items:pointer;
      Temp:pointer;
      Granularity:TPasMPInt32;
      CompareFunc:TPasMPParallelSortCompareFunction;
     end;

     PPasMPParallelIndirectMergeSortJobData=^TPasMPParallelIndirectMergeSortJobData;
     TPasMPParallelIndirectMergeSortJobData=record
      Data:PPasMPParallelIndirectMergeSortData;
      Left:TPasMPNativeInt;
      Right:TPasMPNativeInt;
      Depth:TPasMPInt32;
     end;

procedure TPasMP.ParallelIndirectMergeSortJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
type PPointers=^TPointers;
     TPointers=array[0..($7fffffff div SizeOf(pointer))-1] of pointer;
var ChildJobs:array[0..1] of PPasMPJob;
    JobData,ChildJobData:PPasMPParallelIndirectMergeSortJobData;
    Left,Right,Size,Middle,i,j,iA,iB,iC,Count:TPasMPNativeInt;
    CompareFunc:TPasMPParallelSortCompareFunction;
    Items,Temp:pointer;
    Data:PPasMPParallelIndirectMergeSortData;
begin
 JobData:=PPasMPParallelIndirectMergeSortJobData(pointer(@Job^.Data));
 Left:=JobData^.Left;
 Right:=JobData^.Right;
 if Left<Right then begin
  Data:=JobData^.Data;
  Items:=Data^.Items;
  CompareFunc:=Data^.CompareFunc;
  Size:=(Right-Left)+1;
  case Size of
   2:begin
    if CompareFunc(PPointers(Items)^[Left],PPointers(Items)^[Right])>0 then begin
     Temp:=PPointers(Items)^[Left];
     PPointers(Items)^[Left]:=PPointers(Items)^[Right];
     PPointers(Items)^[Right]:=Temp;
    end;
   end;
   3:begin
    if CompareFunc(PPointers(Items)^[Left+0],PPointers(Items)^[Left+1])<=0 then begin
     if CompareFunc(PPointers(Items)^[Left+1],PPointers(Items)^[Left+2])<=0 then begin
      // 0 <= 1 <= 2
     end else if CompareFunc(PPointers(Items)^[Left+0],PPointers(Items)^[Left+2])<=0 then begin
      // 0 <= 2 < 1
      Temp:=PPointers(Items)^[Left+1];
      PPointers(Items)^[Left+1]:=PPointers(Items)^[Left+2];
      PPointers(Items)^[Left+2]:=Temp;
     end else begin
      // 2 < 0 <= 1
      Temp:=PPointers(Items)^[Left+0];
      PPointers(Items)^[Left+0]:=PPointers(Items)^[Left+2];
      PPointers(Items)^[Left+2]:=PPointers(Items)^[Left+1];
      PPointers(Items)^[Left+1]:=Temp;
     end;
    end else begin
     if CompareFunc(PPointers(Items)^[Left+0],PPointers(Items)^[Left+2])<=0 then begin
      // 1 < 0 <= 2
      Temp:=PPointers(Items)^[Left+0];
      PPointers(Items)^[Left+0]:=PPointers(Items)^[Left+1];
      PPointers(Items)^[Left+1]:=Temp;
     end else if CompareFunc(PPointers(Items)^[Left+1],PPointers(Items)^[Left+2])<=0 then begin
      // 1 <= 2 < 0
      Temp:=PPointers(Items)^[Left+0];
      PPointers(Items)^[Left+0]:=PPointers(Items)^[Left+1];
      PPointers(Items)^[Left+1]:=PPointers(Items)^[Left+2];
      PPointers(Items)^[Left+2]:=Temp;
     end else begin
      // 2 < 1 < 0
      Temp:=PPointers(Items)^[Left+0];
      PPointers(Items)^[Left+0]:=PPointers(Items)^[Left+2];
      PPointers(Items)^[Left+2]:=Temp;
     end;
    end;
   end;
   else begin
    if (JobData^.Depth=0) or (Size<=JobData^.Data.Granularity) then begin
     // Insertion sort
     for i:=Left+1 to Right do begin
      j:=i-1;
      if (j>=Left) and (CompareFunc(PPointers(Items)^[j],PPointers(Items)^[i])>0) then begin
       Temp:=PPointers(Items)^[i];
       repeat
        PPointers(Items)^[j+1]:=PPointers(Items)^[j];
        dec(j);
       until not ((j>=Left) and (CompareFunc(PPointers(Items)^[j],Temp)>0));
       PPointers(Items)^[j+1]:=Temp;
      end;
     end;
    end else begin
     Middle:=Left+((Right-Left) shr 1);
     if Left<Middle then begin
      ChildJobs[0]:=Acquire(ParallelIndirectMergeSortJobFunction,nil,nil,Job^.InternalData and PasMPJobTagShiftedMask,Job^.AreaMask);
      ChildJobData:=PPasMPParallelIndirectMergeSortJobData(pointer(@ChildJobs[0]^.Data));
      ChildJobData^.Data:=Data;
      ChildJobData^.Left:=Left;
      ChildJobData^.Right:=Middle-1;
      ChildJobData^.Depth:=JobData^.Depth-1;
     end else begin
      ChildJobs[0]:=nil;
     end;
     if Middle<=Right then begin
      ChildJobs[1]:=Acquire(ParallelIndirectMergeSortJobFunction,nil,nil,Job^.InternalData and PasMPJobTagShiftedMask,Job^.AreaMask);
      ChildJobData:=PPasMPParallelIndirectMergeSortJobData(pointer(@ChildJobs[1]^.Data));
      ChildJobData^.Data:=JobData^.Data;
      ChildJobData^.Left:=Middle;
      ChildJobData^.Right:=Right;
      ChildJobData^.Depth:=JobData^.Depth-1;
     end else begin
      ChildJobs[1]:=nil;
     end;
     Invoke(ChildJobs);
     begin
      // Merge
      Temp:=Data^.Temp;
      iA:=Left;
      iB:=Middle;
      iC:=Left;
      while (iA<Middle) and
            (CompareFunc(PPointers(Items)^[iA],PPointers(Items)^[iB])<=0) do begin
       inc(iA);
      end;
      if iA<Middle then begin
       Left:=iA;
       iC:=iA;
       PPointers(Temp)^[iC]:=PPointers(Items)^[iB];
       inc(iB);
       inc(iC);
       while (iA<Middle) and (iB<=Right) do begin
        if CompareFunc(PPointers(Items)^[iA],PPointers(Items)^[iB])>0 then begin
         PPointers(Temp)^[iC]:=PPointers(Items)^[iB];
         inc(iB);
        end else begin
         PPointers(Temp)^[iC]:=PPointers(Items)^[iA];
         inc(iA);
        end;
        inc(iC);
       end;
       if iA<Middle then begin
        Count:=Middle-iA;
        Move(PPointers(Items)^[iA],PPointers(Temp)^[iC],Count*SizeOf(pointer));
        inc(iC,Count);
       end;
       if iB<=Right then begin
        Count:=(Right-iB)+1;
        Move(PPointers(Items)^[iB],PPointers(Temp)^[iC],Count*SizeOf(pointer));
       end;
       Move(PPointers(Temp)^[Left],PPointers(Items)^[Left],((Right-Left)+1)*SizeOf(pointer));
      end;
     end;
    end;
   end;
  end;
 end;
end;

type PPasMPParallelIndirectMergeSortRootJobData=^TPasMPParallelIndirectMergeSortRootJobData;
     TPasMPParallelIndirectMergeSortRootJobData=record
      Items:pointer;
      Left:TPasMPNativeInt;
      Right:TPasMPNativeInt;
      Depth:TPasMPInt32;
      Granularity:TPasMPInt32;
      CompareFunc:TPasMPParallelSortCompareFunction;
     end;

procedure TPasMP.ParallelIndirectMergeSortRootJobFunction(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32);
var Data:TPasMPParallelIndirectMergeSortData;
    JobData:PPasMPParallelIndirectMergeSortRootJobData;
    ChildJobData:PPasMPParallelIndirectMergeSortJobData;
    ChildJob:PPasMPJob;
begin
 JobData:=PPasMPParallelIndirectMergeSortRootJobData(pointer(@Job^.Data));
 GetMem(Data.Temp,((JobData^.Right-JobData^.Left)+1)*SizeOf(pointer));
 try
  Data.Items:=JobData^.Items;
  Data.Granularity:=JobData^.Granularity;
  Data.CompareFunc:=JobData^.CompareFunc;
  ChildJob:=Acquire(ParallelIndirectMergeSortJobFunction,nil,nil,Job^.InternalData and PasMPJobTagShiftedMask,Job^.AreaMask);
  ChildJobData:=PPasMPParallelIndirectMergeSortJobData(pointer(@ChildJob^.Data));
  ChildJobData^.Data:=@Data;
  ChildJobData^.Left:=JobData^.Left;
  ChildJobData^.Right:=JobData^.Right;
  ChildJobData^.Depth:=JobData^.Depth;
  Invoke(ChildJob);
 finally
  FreeMem(Data.Temp);
 end;
end;

function TPasMP.ParallelIndirectMergeSort(const Items:pointer;const Left,Right:TPasMPNativeInt;const CompareFunc:TPasMPParallelSortCompareFunction;const Granularity:TPasMPInt32=16;const Depth:TPasMPInt32=PasMPDefaultDepth;const ParentJob:PPasMPJob=nil;const Flags:TPasMPUInt32=0;const AreaMask:TPasMPUInt32=0):PPasMPJob;
var JobData:PPasMPParallelIndirectMergeSortRootJobData;
begin
 if (Left+1)<Right then begin
  result:=Acquire(ParallelIndirectMergeSortRootJobFunction,nil,ParentJob,Flags,AreaMask);
  JobData:=PPasMPParallelIndirectMergeSortRootJobData(pointer(@result^.Data));
  JobData^.Items:=Items;
  JobData^.Left:=Left;
  JobData^.Right:=Right;
  JobData^.Granularity:=Granularity;
  JobData^.CompareFunc:=CompareFunc;
  if Left<Right then begin
   JobData^.Depth:=TPasMPMath.BitScanReverse((Right-Left)+1);
   if JobData^.Depth>Depth then begin
    JobData^.Depth:=Depth;
   end;
  end else begin
   JobData^.Depth:=0;
  end;
 end else begin
  result:=nil;
 end;
end;

initialization
{$ifdef UseThreadLocalStorage}
{$if defined(UseThreadLocalStorageX8632) or defined(UseThreadLocalStorageX8664)}
 CurrentJobWorkerThreadTLSIndex:=TLSAlloc;
 CurrentJobWorkerThreadTLSOffset:={$if defined(UseThreadLocalStorageX8632)}$e10+(CurrentJobWorkerThreadTLSIndex*4){$else}$1480+(CurrentJobWorkerThreadTLSIndex*8){$ifend};
{$ifend}
{$endif}
 GlobalPasMP:=nil;
 GlobalPasMPCriticalSection:=TPasMPCriticalSection.Create;
{$ifdef PasMPUseGlobalPasMPCountOfHardwareThreads}
 GlobalPasMPCountOfHardwareThreads:=TPasMP.GetCountOfHardwareThreads(GlobalPasMPAvailableCPUCores);
 if GlobalPasMPCountOfHardwareThreads<1 then begin
  GlobalPasMPCountOfHardwareThreads:=1;
 end;
{$endif}
{$ifdef Windows}
 timeBeginPeriod(1);
{$endif}
finalization
{$ifdef Windows}
 timeEndPeriod(1);
{$endif}
 if assigned(GlobalPasMP) then begin
  TPasMP.DestroyGlobalInstance;
 end;
 GlobalPasMPCriticalSection.Free;
end.
