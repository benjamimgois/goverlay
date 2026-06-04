(******************************************************************************
 *                        RNL (Realtime Network Library)                      *
 ******************************************************************************
 *                      Version see RNL_VERSION code constant                 *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2016-2023, Benjamin Rosseaux (benjamin@rosseaux.de)          *
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
      http://github.com/BeRo1985/rnl                                          *
 * 4. Write code, which is compatible with newer modern Delphi versions and   *
 *    FreePascal >= 3.0.4, but if needed, make it out-ifdef-able.             *
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
 ******************************************************************************
 *
 * RNL is an UDP-based network library for real-time applications and games, inspired
 * by ENet, yojimbo, libgren, and so on.
 *
 * Thanks to Lee Salzman for ENet as inspiration for the base API design implementation ideas
 * Thanks to Glenn Fiedler for inspiration for security-oriented implementation ideas
 * Thanks to Sergey Ignatchenko ("No Bugs" Hare) for inspiration also for security-oriented
 * implementation ideas
 *
 * Warning: RNL including its cryptography code is non-audited so far, thus RNL is only intended
 *          for real-time games and multimedia applications without processing of any with critical
 *          data, but not for serious applications with critical data!
 *
 * RNL is designed around common patterns used in real-time games, which are simulation bound,
 * not I/O bound, and completely stateful, so async IO does not make a lot of sense. Thus the
 * RNL core design is single-threaded, not multi-threaded. But you can use multiple TRNLHost
 * instances inside multiple different threads (one to very few instances per one thread), so
 * that you can host multiple network game matches at the same machine, as long as this one
 * machine is strong and fast enough for hosting multiple network game matches at the same time.
 *
 * And at game client side, the whole network stuff should run, if possible, in an own
 * (also if possible, CPU-core-pinned) thread, for possible few interferences and other similiar
 * problems. (offtopic: the same also applies to the audio thread, unless one likes possible
 * audio buffer underrun issues and so on, when it did not get enough CPU time at the right
 * time points. :-) )
 *
 * And for larger games with masses of clients in a single game world, you should use several
 * subdivided TRNLHost instances, so that each TRNLHost must handle only few connected clients,
 * in multiple threads and that in turn on multiple physical dedicated servers, which also in
 * turn may communicate with each other to mimic the impression of a single very large game world.
 * At least a single TRNLHost instance is rather designed for typical low client numbers, as these
 * are the typical case for egoshooters, racing games, and so forth. Or in other words for large
 * game worlds with masses of clients: Divide and conquer (for example with partially sector-border
 * overlapping game world sectors for just as an example of an divide-and-conquer concept idea)
 *
 * RNL features:
 *
 *   - Mostly fully object oriented code design
 *   - IPv6 support
 *   - Cross platform
 *       - Windows (with FreePascal and Delphi)
 *       - Linux (with FreePascal)
 *       - *BSD (with FreePascal)
 *       - Android (with FreePascal and Delphi)
 *       - Darwin (MacOS(X) and iOS) (with FreePascal and Delphi)
 *   - UDP-based protocol
 *   - Sequencing
 *   - Channels
 *      - With following possible free configurable channel types:
 *         - Reliable ordered
 *         - Reliable unordered
 *         - Unreliable ordered
 *         - Unreliable unordered
 *   - Reliability
 *   - Fragmentation and reassembly
 *   - Aggregation
 *   - Adaptability
 *   - Portability
 *   - Possibility of using a peer-to-peer model or even a mixed peer-to-peer
 *     and client/server hybrid model instead only a pure client/server model, and
 *     of course also of a classic client/server model
 *   - Cryptographically secure pseudo-random number generator (CSPRNG)
 *       - Based on arc4random but with ChaCha20 instead RC4 as the basic building block
 *       - Multiple sources of entropy (because you should never trust a single source of
 *         entropy, as it may have a backdoor)
 *           - Including usage of the rdseed/rdrand instructions on newer x86 processors
 *             as an optional additional quasi-hardware-based entropy source, if these
 *             instructions are supported by the current running processor
 *   - Mutual authentication
 *       - Based on a Station-to-Station (STS) like protocol, which assumes that the parties
 *         have signature keys, which are used to sign messages, thereby providing minification
 *         security against man-in-the-middle attacks, unlike the basic plain Diffie-Hellman
 *         method without any so such extensions.
 *       - Long-term private/public keys are ED25519 keys and are used only for
 *         signing purposes
 *   - Forward secrecy using elliptic curve ephemeral Diffie-Hellman (curve 25519)
 *       - The consequence of this along other facts is that each connection always has
 *         new different private and public short-term keys on both sides and therefore
 *         also new shared secret short-term keys
 *       - Short-term private/public keys are X25519 keys and the short-term shared
 *         secret key is using only for AEAD-based ciphering purposes
 *   - Authenticated Encryption with Associated Data (AEAD) packet encryption
 *       - Based on ChaCha20 as cipher and Poly1305 as cryptographic message authentication code
 *   - Replay protection of application packet data
 *       - Based on various protection mechanisms at the connection establishment phase and
 *         encrypted packet sequence numbers
 *   - Delayed connection establishment mechanism as an additional attack surface minification
 *     mechanism
 *   - Connection and authentication tokens (as an optional option, where you should have a
 *     separate out-of-band communication channel, for example a HTTPS-based master backend
 *     for to generate and handle this stuff) as an additional attack surface minification
 *     mechanism against DDoS amplification attacks
 *       - Connection token are transferred in clear text, so that they are checked in a fast
 *         way at the first ever data packet from a connection attempt, without the need to
 *         decrypt the connection token first before it is possible to check the token, so
 *         in order to save CPU time in this point. This option is primarily for use in against
 *         DDoS amplification attacks, which means that the server will not respond straight
 *         away if the connection token does not match at the first ever data packet from a
 *         connection attempt, and thus DDoS amplification attacks would simply go into the
 *         nothing. Consequently, these tokens should only be valid for a short period of
 *         time, which also applies to the master backend side of your infrastructure.
 *       - Authentication tokens are transferred encrypted, after the private/public key
 *         exchange, shared secret key generation, etc. were successfully processed.
 *         Authentication tokens, in contrast to the connection token, are NOT a
 *         countermeasure against DDoS-category attacks, but rather authentication tokens are,
 *         as the name suggests, only for separate out-of-band communication channel
 *         authentication purposes, in other words, as additional protection against
 *         unauthorized connections, where you can check it in more detail on your master
 *         backend side of your infrastructure, before the "client" can connect to the
 *         real server, where all the real action happens.
 *   - Connection attempt rate limiter
 *       - Configurable with two constants, burst and period
 *   - Configurable bandwidth rate limiter
 *   - Optional virtual network feature (for example for fast network-API-less local
 *     loopback solution for singleplayer game matches, which should be still server/client
 *     concept based)
 *   - Network interference simulator (for example for testcases and so on)
 *       - Configurable simulated packet loss probability (each for incoming and outgoing packets)
 *       - Configurable simulated latency (each for incoming and outgoing packets)
 *       - Configurable simulated jitter (each for incoming and outgoing packets)
 *       - Configurable simulated duplicate packet probability (each for incoming and outgoing packets)
 *   - Dynamic connection challenge request response difficulty adjustment mechanism
 *       - Configurable with a factor value
 *       - Based on history-smoothing-frames-per-second-style determination mechanism,
 *         but just instead frames per second, connection attempts per second
 *   - More compression algorithms as choices
 *       - Deflate (a zlib bit-stream compatible LZ77 and canonical Huffman hybrid,
 *                  only fixed-static-canonical-huffman in this implementation here on
 *                  compressor side, but the decompressor side is full featured)
 *       - LZBRRC (a LZ77-style compressor together with an entropy range coder backend)
 *       - BRRC (a pure order 0 entropy range coder)
 *   - CRC32C instead CRC32 (without C at the end)
 *   - And a lot of more stuff  . . .
 *
 * Planned features (a.k.a Todo) in random order of priorities:
 *
 * - TODO
 *
 *)
unit RNL;
{$ifdef fpc}
 {$mode delphi}
 {-$codepage utf8}
 {$ifdef CPUI386}
  {$define CPU386}
 {$endif}
 {$ifdef CPU386}
  {$define CPUX86}
  {$asmmode intel}
  {$undef CPU64}
 {$endif}
 {$ifdef CPUAMD64}
  {$define CPUX64}
  {$asmmode intel}
  {$define CPU64}
 {$endif}
 {$ifdef CPUARM}
  {$undef CPU64}
 {$endif}
 {$ifdef CPUAARCH64}
  {$define CPU64}
 {$endif}
 {$ifdef FPC_LITTLE_ENDIAN}
  {$define LITTLE_ENDIAN}
 {$else}
  {$ifdef FPC_BIG_ENDIAN}
   {$define BIG_ENDIAN}
  {$endif}
 {$endif}
 {$define CAN_INLINE}
 {$define HAS_ADVANCED_RECORDS}
{$else}
 {$realcompatibility off}
 {$localsymbols on}
 {$undef CPU64}
 {$ifdef CPU64BITS}
  {$define CPU64}
 {$else}
  {$ifdef CPUX64}
   {$define CPU64}
  {$endif}
 {$endif}
 {$ifndef CPU64}
  {$define CPU32}
 {$endif}
 {$undef CAN_INLINE}
 {$undef HAS_ADVANCED_RECORDS}
 {$define LITTLE_ENDIAN}
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
   {$legacyifend on}
   {$if CompilerVersion=24.0}
    {$define DelphiXE3}
   {$ifend}
   {$define DelphiXE3AndUp}
  {$ifend}
  {$if CompilerVersion>=25.0}
   {$if CompilerVersion=25.0}
    {$define DelphiXE4}
   {$ifend}
   {$define DelphiXE4AndUp}
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
  {$if CompilerVersion>=32.0}
   {$if CompilerVersion=32.0}
    {$define Delphi10Tokyo}
   {$ifend}
   {$define Delphi10TokyoAndUp}
  {$ifend}
  {$if CompilerVersion>=33.0}
   {$if CompilerVersion=33.0}
    {$define Delphi10Rio}
   {$ifend}
   {$define Delphi10RioAndUp}
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
 {$ifdef DelphiXE2AndUp}
  {$warn implicit_string_cast_loss off}
  {$warn implicit_string_cast off}
  {$warn suspicious_typecast off}
  {$warn unit_platform off}
  {$warn duplicate_ctor_dtor off}
 {$endif}
{$endif}
{$if defined(Win32) or defined(Win64)}
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
{$m+}

{$ifndef HAS_ADVANCED_RECORDS}
 {$error "Sorry, but your compiler is too old, because it doesn't support advanced records"}
{$endif}

{$ifndef CAN_INLINE}
 {$error "Sorry, but your compiler is too old, because it doesn't suppont inlined functions"}
{$endif}

interface

uses {$if defined(Posix)}
      // Delphi: Linux, Android, Darwin (MacOS, iOS)
      Posix.Base,
      Posix.NetDB,
      Posix.NetIf,
      Posix.NetinetIn,
      Posix.NetinetIp6,
      Posix.NetinetTCP,
      Posix.NetinetUDP,
      Posix.StrOpts,
      Posix.SysSelect,
      Posix.SysSocket,
      Posix.SysTime,
      Posix.SysTimes,
      Posix.SysTypes,
      Posix.SysWait,
      Posix.Termios,
      Posix.Errno,
      Posix.Fcntl,
      Posix.Unistd,
      Posix.Time,
      System.Net.Socket,
      {$ifdef Linux}
       Linuxapi.KernelIoctl,
      {$endif}
      {$if defined(Android) and defined(RNL_DEBUG)}
       Androidapi.Log,
      {$ifend}
     {$elseif defined(Unix)}
      // FreePascal: Unix, Linux, Android, Darwin (MacOS, iOS)
      ctypes,
      BaseUnix,
      Unix,
      UnixType,
      Sockets,
      {$if not defined(Darwin)}
       cnetdb,
      {$ifend}
      termio,
      {$if defined(linux) or defined(android)}
       linux,
      {$ifend}
     {$else}
      // Delphi and FreePascal: Win32, Win64
      Windows,
      MMSystem,
      {$ifdef fpc}
       jwaIpTypes,
       JwaIpHlpApi,
      {$else}
       Winapi.IpTypes,
       Winapi.IpHlpApi,
      {$endif}
     {$ifend}
     SysUtils,
     Classes,
     SyncObjs,
     TypInfo,
     Math;

{    Generics.Defaults,
     Generics.Collections;}

const RNL_VERSION='1.00.2023.05.07.16.08.0000';

type PPRNLInt8=^PRNLInt8;
     PRNLInt8=^TRNLInt8;
     TRNLInt8={$ifdef fpc}Int8{$else}ShortInt{$endif};

     PPRNLUInt8=^PRNLUInt8;
     PRNLUInt8=^TRNLUInt8;
     TRNLUInt8={$ifdef fpc}UInt8{$else}byte{$endif};

     PPRNLInt16=^PRNLInt16;
     PRNLInt16=^TRNLInt16;
     TRNLInt16={$ifdef fpc}Int16{$else}SmallInt{$endif};

     PPRNLUInt16=^PRNLUInt16;
     PRNLUInt16=^TRNLUInt16;
     TRNLUInt16={$ifdef fpc}UInt16{$else}Word{$endif};

     PPRNLInt32=^PRNLInt32;
     PRNLInt32=^TRNLInt32;
     TRNLInt32={$ifdef fpc}Int32{$else}LongInt{$endif};

     PPRNLUInt32=^PRNLUInt32;
     PRNLUInt32=^TRNLUInt32;
     TRNLUInt32={$ifdef fpc}UInt32{$else}LongWord{$endif};

     PPRNLInt64=^PRNLInt64;
     PRNLInt64=^TRNLInt64;
     TRNLInt64=Int64;

     PPRNLUInt64=^PRNLUInt64;
     PRNLUInt64=^TRNLUInt64;
     TRNLUInt64=UInt64;

     PPRNLUInt64Record=^PRNLUInt64Record;
     PRNLUInt64Record=^TRNLUInt64Record;
     TRNLUInt64Record=record
      case boolean of
       false:(
        {$ifdef BIG_ENDIAN}Hi,Lo{$else}Lo,Hi{$endif}:TRNLUInt32;
       );
       true:(
        Value:TRNLUInt64;
       );
     end;

     PPRNLDouble=^PRNLDouble;
     PRNLDouble=^TRNLDouble;
     TRNLDouble=Double;

{$if defined(NEXTGEN)}
     PPRNLChar=^PChar;
     PRNLChar=PChar;
     TRNLChar=Char;
{$else}
     PPRNLChar=^PAnsiChar;
     PRNLChar=PAnsiChar;
     TRNLChar=AnsiChar;

     PPRNLRawByteChar=^PAnsiChar;
     PRNLRawByteChar=PAnsiChar;
     TRNLRawByteChar=AnsiChar;
{$ifend}

     PPRNLPointer=^PRNLPointer;
     PRNLPointer=^TRNLPointer;
     TRNLPointer=Pointer;

     PPRNLPtrUInt=^PRNLPtrUInt;
     PPRNLPtrInt=^PRNLPtrInt;
     PRNLPtrUInt=^TRNLPtrUInt;
     PRNLPtrInt=^TRNLPtrInt;
{$ifdef fpc}
     TRNLPtrUInt=PtrUInt;
     TRNLPtrInt=PtrInt;
 {$undef OldDelphi}
{$else}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=23.0}
   {$undef OldDelphi}
     TRNLPtrUInt=NativeUInt;
     TRNLPtrInt=NativeInt;
  {$else}
   {$define OldDelphi}
  {$ifend}
 {$else}
  {$define OldDelphi}
 {$endif}
{$endif}
{$ifdef OldDelphi}
{$ifdef CPU64}
     TRNLPtrUInt=TRNLUInt64;
     TRNLPtrInt=TRNLInt64;
{$else}
     TRNLPtrUInt=TRNLUInt32;
     TRNLPtrInt=TRNLInt32;
{$endif}
{$endif}

     PPRNLSizeUInt=^PRNLSizeUInt;
     PRNLSizeUInt=^TRNLSizeUInt;
     TRNLSizeUInt=TRNLPtrUInt;

     PPRNLSizeInt=^PRNLSizeInt;
     PRNLSizeInt=^TRNLSizeInt;
     TRNLSizeInt=TRNLPtrInt;

     PPRNLNativeUInt=^PRNLNativeUInt;
     PRNLNativeUInt=^TRNLNativeUInt;
     TRNLNativeUInt=TRNLPtrUInt;

     PPRNLNativeInt=^PRNLNativeInt;
     PRNLNativeInt=^TRNLNativeInt;
     TRNLNativeInt=TRNLPtrInt;

     PPRNLSize=^PRNLSizeUInt;
     PRNLSize=^TRNLSizeUInt;
     TRNLSize=TRNLPtrUInt;

     PPRNLPtrDiff=^PRNLPtrDiff;
     PRNLPtrDiff=^TRNLPtrDiff;
     TRNLPtrDiff=TRNLPtrInt;

     PPRNLRawByteString=^PRNLRawByteString;
     PRNLRawByteString=^TRNLRawByteString;
     TRNLRawByteString={$if declared(RawByteString)}RawByteString{$else}AnsiString{$ifend};

     PPRNLUTF8String=^PRNLUTF8String;
     PRNLUTF8String=^TRNLUTF8String;
     TRNLUTF8String={$if declared(UTF8String)}UTF8String{$else}AnsiString{$ifend};

     PPRNLUTF16String=^PRNLUTF16String;
     PRNLUTF16String=^TRNLUTF16String;
     TRNLUTF16String={$if declared(UnicodeString)}UnicodeString{$else}WideString{$ifend};

     PPRNLString=^PRNLString;
     PRNLString=^TRNLString;
     TRNLString=String;

     PRNLInt8Array=^TRNLInt8Array;
     TRNLInt8Array=array[0..65535] of TRNLInt8;

     PRNLUInt8Array=^TRNLUInt8Array;
     TRNLUInt8Array=array[0..65535] of TRNLUInt8;

     PRNLInt16Array=^TRNLInt16Array;
     TRNLInt16Array=array[0..65535] of TRNLInt16;

     PRNLUInt16Array=^TRNLUInt16Array;
     TRNLUInt16Array=array[0..65535] of TRNLUInt16;

     PRNLInt32Array=^TRNLInt32Array;
     TRNLInt32Array=array[0..65535] of TRNLInt32;

     PRNLUInt32Array=^TRNLUInt32Array;
     TRNLUInt32Array=array[0..65535] of TRNLUInt32;

     PRNLInt64Array=^TRNLInt64Array;
     TRNLInt64Array=array[0..65535] of TRNLInt64;

     PRNLUInt64Array=^TRNLUInt64Array;
     TRNLUInt64Array=array[0..65535] of TRNLUInt64;

const RNL_PROTOCOL_VERSION_MAJOR=1;
      RNL_PROTOCOL_VERSION_MINOR=0;
      RNL_PROTOCOL_VERSION_PATCH=0;

      RNL_PROTOCOL_VERSION=TRNLUInt64((TRNLUInt64(RNL_PROTOCOL_VERSION_MAJOR) shl 32) or (TRNLUInt64(RNL_PROTOCOL_VERSION_MINOR) shl 16) or RNL_PROTOCOL_VERSION_PATCH);

      RNL_TIME_HALF_OVERFLOW=TRNLUInt64($2000000000000000); // 1/8 of a 64-bit unsigned integer

      RNL_TIME_OVERFLOW=TRNLUInt64($4000000000000000); // 1/4 of a 64-bit unsigned integer

      RNL_TIME_OVERFLOW_MASK=TRNLUInt64($3fffffffffffffff); // 1/4 of a 64-bit unsigned integer

      RNL_IPV4MAPPED_PREFIX_LEN=12; // specifies the length of the IPv4-mapped IPv6 prefix

      RNL_PORT_ANY=0; // specifies that a Port should be automatically chosen

      RNL_NO_ADDRESS_FAMILY=0;
      RNL_IPV4=1 shl 0;
      RNL_IPV6=1 shl 1;

      RNL_FD_SETSIZE={$ifdef Unix}64{$else}64{$endif};

      RNL_KEY_SIZE=256 shr 3; // 32 bytes, 256 bits (DON'T CHANGE OR YOU WILL BREAK IT!)

      RNL_CONNECTION_TOKEN_SIZE=128;

      RNL_AUTHENTICATION_TOKEN_SIZE=128;

      RNL_MAXIMUM_PEER_CHANNELS=32;

      RNL_MINIMUM_MTU=576;
      RNL_MAXIMUM_MTU=4096;

      RNL_IPV4_HEADER_SIZE=60; // 20 bytes as minimum size and 60 bytes as maximum size
                               // of an IPv4 header, but we just assume the maximum size
                               // here, just for the worst case

      RNL_IPV6_HEADER_SIZE=40; // But the IPv6 header has luckly a fixed size of 40 bytes

      RNL_IP_HEADER_SIZE=RNL_IPV4_HEADER_SIZE; // We are using the IPv4 header size here, because it is the bigger thing

      RNL_UDP_HEADER_SIZE=8;

      RNL_CONNECTION_ATTEMPT_BITS=8;
      RNL_CONNECTION_ATTEMPT_SIZE=1 shl RNL_CONNECTION_ATTEMPT_BITS;
      RNL_CONNECTION_ATTEMPT_MASK=RNL_CONNECTION_ATTEMPT_SIZE-1;

      RNL_PROTOCOL_PACKET_HEADER_SESSION_MASK=$ff;

      RNL_PROTOCOL_PACKET_HEADER_FLAG_COMPRESSED=1 shl 0;

      RNL_PEER_PACKET_LOSS_INTERVAL=10000;

      RNL_BROADCAST_IPV4='255.255.255.255';

      RNL_MULTICAST_GROUP_IPV4='224.0.0.1';

      RNL_MULTICAST_GROUP_IPV6='FF02:0:0:0:0:0:0:1';

type PRNLVersion=^TRNLVersion;
     TRNLVersion=TRNLUInt32;

     ERNL=class(Exception);

     ERNLNetwork=class(ERNL);

     ERNLInstance=class(ERNL);

     ERNLHost=class(ERNL);

     TRNLHost=class;

     TRNLPeer=class;

     TRNLMath=class
      public
       class function RoundUpToPowerOfTwo32(Value:TRNLUInt32):TRNLUInt32; static;
       class function RoundUpToPowerOfTwo64(Value:TRNLUInt64):TRNLUInt64; static;
       class function RoundUpToPowerOfTwo(Value:TRNLPtrUInt):TRNLPtrUInt; static;
     end;

     PRNLEndianness=^TRNLEndianness;
     TRNLEndianness=record
      public
       class function Swap16(const aValue:TRNLUInt16):TRNLUInt16; static; {$if defined(CPU386) or defined(CPUX64)}register;{$else}inline;{$ifend}
       class function Swap32(const aValue:TRNLUInt32):TRNLUInt32; static; {$if defined(CPU386) or defined(CPUX64)}register;{$else}inline;{$ifend}
       class function Swap64(const aValue:TRNLUInt64):TRNLUInt64; static; {$if defined(CPU386) or defined(CPUX64)}register;{$else}inline;{$ifend}
       class function HostToNet16(const aValue:TRNLUInt16):TRNLUInt16; static; {$if defined(CPU386) or defined(CPUX64)}register;{$else}inline;{$ifend}
       class function HostToNet32(const aValue:TRNLUInt32):TRNLUInt32; static; {$if defined(CPU386) or defined(CPUX64)}register;{$else}inline;{$ifend}
       class function HostToNet64(const aValue:TRNLUInt64):TRNLUInt64; static; {$if defined(CPU386) or defined(CPUX64)}register;{$else}inline;{$ifend}
       class function NetToHost16(const aValue:TRNLUInt16):TRNLUInt16; static; {$if defined(CPU386) or defined(CPUX64)}register;{$else}inline;{$ifend}
       class function NetToHost32(const aValue:TRNLUInt32):TRNLUInt32; static; {$if defined(CPU386) or defined(CPUX64)}register;{$else}inline;{$ifend}
       class function NetToHost64(const aValue:TRNLUInt64):TRNLUInt64; static; {$if defined(CPU386) or defined(CPUX64)}register;{$else}inline;{$ifend}
       class function HostToLittleEndian16(const aValue:TRNLUInt16):TRNLUInt16; static; inline;
       class function HostToLittleEndian32(const aValue:TRNLUInt32):TRNLUInt32; static; inline;
       class function HostToLittleEndian64(const aValue:TRNLUInt64):TRNLUInt64; static; inline;
       class function LittleEndianToHost16(const aValue:TRNLUInt16):TRNLUInt16; static; inline;
       class function LittleEndianToHost32(const aValue:TRNLUInt32):TRNLUInt32; static; inline;
       class function LittleEndianToHost64(const aValue:TRNLUInt64):TRNLUInt64; static; inline;
     end;

     PRNLMemoryAccess=^TRNLMemoryAccess;
     TRNLMemoryAccess=record
      public
       class function LoadBigEndianInt8(const aLocation):TRNLInt8; static; inline;
       class function LoadBigEndianUInt8(const aLocation):TRNLUInt8; static; inline;
       class function LoadBigEndianInt16(const aLocation):TRNLInt16; static; {$if defined(CPU386) or defined(CPUX64)}register;{$else}inline;{$ifend}
       class function LoadBigEndianUInt16(const aLocation):TRNLUInt16; static; {$if defined(CPU386) or defined(CPUX64)}register;{$else}inline;{$ifend}
       class function LoadBigEndianInt32(const aLocation):TRNLInt32; static; {$if defined(CPU386) or defined(CPUX64)}register;{$else}inline;{$ifend}
       class function LoadBigEndianUInt32(const aLocation):TRNLUInt32; static; {$if defined(CPU386) or defined(CPUX64)}register;{$else}inline;{$ifend}
       class function LoadBigEndianInt64(const aLocation):TRNLInt64; static; {$if defined(CPU386) or defined(CPUX64)}register;{$else}inline;{$ifend}
       class function LoadBigEndianUInt64(const aLocation):TRNLUInt64; static; {$if defined(CPU386) or defined(CPUX64)}register;{$else}inline;{$ifend}
       class function LoadLittleEndianInt8(const aLocation):TRNLInt8; static; inline;
       class function LoadLittleEndianUInt8(const aLocation):TRNLUInt8; static; inline;
       class function LoadLittleEndianInt16(const aLocation):TRNLInt16; static; inline;
       class function LoadLittleEndianUInt16(const aLocation):TRNLUInt16; static; inline;
       class function LoadLittleEndianUInt24(const aLocation):TRNLUInt32; static; inline;
       class function LoadLittleEndianInt32(const aLocation):TRNLInt32; static; inline;
       class function LoadLittleEndianUInt32(const aLocation):TRNLUInt32; static; inline;
       class function LoadLittleEndianInt64(const aLocation):TRNLInt64; static; inline;
       class function LoadLittleEndianUInt64(const aLocation):TRNLUInt64; static; inline;
       class procedure StoreBigEndianInt8(out aLocation;const aValue:TRNLInt8); static; inline;
       class procedure StoreBigEndianUInt8(out aLocation;const aValue:TRNLUInt8); static; inline;
       class procedure StoreBigEndianInt16(out aLocation;const aValue:TRNLInt16); static; {$if defined(CPU386) or defined(CPUX64)}register;{$else}inline;{$ifend}
       class procedure StoreBigEndianUInt16(out aLocation;const aValue:TRNLUInt16); static; {$if defined(CPU386) or defined(CPUX64)}register;{$else}inline;{$ifend}
       class procedure StoreBigEndianInt32(out aLocation;const aValue:TRNLInt32); static; {$if defined(CPU386) or defined(CPUX64)}register;{$else}inline;{$ifend}
       class procedure StoreBigEndianUInt32(out aLocation;const aValue:TRNLUInt32); static; {$if defined(CPU386) or defined(CPUX64)}register;{$else}inline;{$ifend}
       class procedure StoreBigEndianInt64(out aLocation;const aValue:TRNLInt64); static; {$if defined(CPU386) or defined(CPUX64)}register;{$else}inline;{$ifend}
       class procedure StoreBigEndianUInt64(out aLocation;const aValue:TRNLUInt64); static; {$if defined(CPU386) or defined(CPUX64)}register;{$else}inline;{$ifend}
       class procedure StoreLittleEndianInt8(out aLocation;const aValue:TRNLInt8); static; inline;
       class procedure StoreLittleEndianUInt8(out aLocation;const aValue:TRNLUInt8); static; inline;
       class procedure StoreLittleEndianInt16(out aLocation;const aValue:TRNLInt16); static; inline;
       class procedure StoreLittleEndianUInt16(out aLocation;const aValue:TRNLUInt16); static; inline;
       class procedure StoreLittleEndianInt32(out aLocation;const aValue:TRNLInt32); static; inline;
       class procedure StoreLittleEndianUInt32(out aLocation;const aValue:TRNLUInt32); static; inline;
       class procedure StoreLittleEndianInt64(out aLocation;const aValue:TRNLInt64); static; inline;
       class procedure StoreLittleEndianUInt64(out aLocation;const aValue:TRNLUInt64); static; inline;
     end;

     PRNLMemory=^TRNLMemory;
     TRNLMemory=record
      public
       class function SecureIsEqual(const aLocationA,aLocationB;const aSize:TRNLSizeUInt):boolean; static; inline;
       class function SecureIsNotEqual(const aLocationA,aLocationB;const aSize:TRNLSizeUInt):boolean; static; inline;
       class function SecureIsZero(const aLocation;const aSize:TRNLSizeUInt):boolean; static; inline;
       class function SecureIsNonZero(const aLocation;const aSize:TRNLSizeUInt):boolean; static; inline;
     end;

     TRNLTypedSort<T>=class
      public
       type TRNLTypedSortCompareFunction=function(const a,b:T):TRNLInt32;
      public
       class procedure IntroSort(const pItems:TRNLPointer;const pLeft,pRight:TRNLInt32;const pCompareFunc:TRNLTypedSortCompareFunction); static;
     end;

     PRNLHashUtils=^TRNLHashUtils;
     TRNLHashUtils=record
      public
       class function Hash32(const aLocation;const aSize:TRNLSizeUInt):TRNLUInt32; static;
     end;

     PRNLChaCha20State=^TRNLChaCha20State;
     TRNLChaCha20State=array[0..15] of TRNLUInt32;

     PRNLChaCha20Context=^TRNLChaCha20Context;
     TRNLChaCha20Context=record
      private
       fInput:TRNLChaCha20State;
       fPool:TRNLChaCha20State;
       fPoolIndex:TRNLUInt32;
       function GetCounter:TRNLUInt64; inline;
       procedure SetCounter(const aCounter:TRNLUInt64); inline;
      public
       class procedure Update(out aOutput:TRNLChaCha20State;const aInput:TRNLChaCha20State); static; inline;
       class procedure HChaCha20Process(out aOutput;const aKey,aInput); static;
      public
       procedure Initialize(const aKey,aNonce;const aCounter:TRNLUInt64=0);
       procedure EndianNeutralInitialize(const aKey;const aNonce:TRNLUInt64=0;const aCounter:TRNLUInt64=0);
       procedure XChaCha20Initialize(const aKey,aNonce;const aCounter:TRNLUInt64=0);
       procedure RefillPool;
       procedure Process(out aCipherText;const aPlainText;const aTextSize:TRNLSizeUInt;const aUsePlainText:boolean=true);
       procedure Stream(out aCipherText;const aTextSize:TRNLSizeUInt);
      public
       property Counter:TRNLUInt64 read GetCounter write SetCounter;
     end;

     PRNLChaCha20=^TRNLChaCha20;
     TRNLChaCha20=record
      public
       class procedure SelfTest; static;
     end;

     // arc4random-based random generator, but with ChaCha20 instead RC4 as the basic building block
     TRNLRandomGenerator=class
      public
       const KeySize=32;
             NonceSize=12;
             BlockSize=64;
             BufferSize=BlockSize*16;
       type PRNLRandomGeneratorKey=^TRNLRandomGeneratorKey;
            TRNLRandomGeneratorKey=array[0..KeySize-1] of TRNLUInt8;
            PRNLRandomGeneratorNonce=^TRNLRandomGeneratorNonce;
            TRNLRandomGeneratorNonce=array[0..NonceSize-1] of TRNLUInt8;
            PRNLRandomGeneratorBuffer=^TRNLRandomGeneratorBuffer;
            TRNLRandomGeneratorBuffer=array[0..BufferSize-1] of TRNLUInt8;
            PRNLRandomGeneratorSeed=^TRNLRandomGeneratorSeed;
            TRNLRandomGeneratorSeed=packed record
             Key:TRNLRandomGeneratorKey;
             Nonce:TRNLRandomGeneratorNonce;
            end;
            PRNLRandomGeneratorEntropyData=^TRNLRandomGeneratorEntropyData;
            TRNLRandomGeneratorEntropyData=array[0..(KeySize+NonceSize)-1] of TRNLUInt8;
{$if defined(Windows)}
      private
       fWindowsCryptProvider:PRNLUInt32;
       fWindowsCryptProviderInitialized:boolean;
{$ifend}
      private
       fInitialized:boolean;
       fPosition:TRNLSizeUInt;
       fHave:TRNLSizeUInt;
       fCount:TRNLSizeUInt;
       fBuffer:TRNLRandomGeneratorBuffer;
       fChaCha20Context:TRNLChaCha20Context;
       fGuassianFloatUseLast:boolean;
       fGuassianFloatLast:single;
       fGuassianDoubleUseLast:boolean;
       fGuassianDoubleLast:double;
       procedure Initialize(const aData;const aDataLength:TRNLSizeUInt);
       procedure Rekey(const aData;const aDataLength:TRNLSizeUInt);
       procedure Reseed;
       procedure ReseedIfNeeded(const aCount:TRNLSizeUInt);
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure GetRandomBytes(out aLocation;const aCount:TRNLSizeUInt);
       function GetUInt32:TRNLUInt32;
       function GetUInt64:TRNLUInt64;
       function GetBoundedUInt32(const aBound:TRNLUInt32):TRNLUInt32;
       function GetUniformBoundedUInt32(const aBound:TRNLUInt32):TRNLUInt32;
       function GetFloat:single; // -1.0.0 .. 1.0
       function GetAbsoluteFloat:single; // 0.0 .. 1.0
       function GetDouble:double; // -1.0.0 .. 1.0
       function GetAbsoluteDouble:Double; // 0.0 .. 1.0
       function GetGuassianFloat:single; // -1.0 .. 1.0
       function GetAbsoluteGuassianFloat:single; // 0.0 .. 1.0
       function GetGuassianDouble:double; // -1.0 .. 1.0
       function GetAbsoluteGuassianDouble:double; // 0.0 .. 1.0
       function GetGuassian(const aBound:TRNLUInt32):TRNLUInt32;
     end;

     PPRNLTime=^PRNLTime;
     PRNLTime=^TRNLTime;
     TRNLTime=record
      private
       fValue:TRNLUInt64;
      public
       class operator Implicit(const a:TRNLUInt64):TRNLTime; inline;
       class operator Explicit(const a:TRNLUInt64):TRNLTime; inline;
       class operator Implicit(const a:TRNLTime):TRNLUInt64; inline;
       class operator Explicit(const a:TRNLTime):TRNLUInt64; inline;
       class operator Equal(const a,b:TRNLTime):boolean; inline;
       class operator NotEqual(const a,b:TRNLTime):boolean; inline;
       class operator GreaterThan(const a,b:TRNLTime):boolean;
       class operator GreaterThanOrEqual(const a,b:TRNLTime):boolean;
       class operator LessThan(const a,b:TRNLTime):boolean;
       class operator LessThanOrEqual(const a,b:TRNLTime):boolean;
       class function RelativeDifference(const a,b:TRNLTime):TRNLInt64; static;
       class function Difference(const a,b:TRNLTime):TRNLInt64; static;
       class function Minimum(const a,b:TRNLTime):TRNLTime; static;
       class operator Inc(const a:TRNLTime):TRNLTime; inline;
       class operator Dec(const a:TRNLTime):TRNLTime; inline;
       class operator LogicalNot(const a:TRNLTime):TRNLTime; inline;
       class operator Add(const a,b:TRNLTime):TRNLTime; inline;
       class operator Add(const a:TRNLTime;const b:TRNLUInt64):TRNLUInt64; inline;
       class operator Add(const a:TRNLUInt64;const b:TRNLTime):TRNLUInt64; inline;
       class operator Subtract(const a,b:TRNLTime):TRNLTime; inline;
       class operator Subtract(const a:TRNLTime;const b:TRNLUInt64):TRNLUInt64; inline;
       class operator Subtract(const a:TRNLUInt64;const b:TRNLTime):TRNLUInt64; inline;
       class operator Multiply(const a,b:TRNLTime):TRNLTime; inline;
       class operator Multiply(const a:TRNLTime;const b:TRNLUInt64):TRNLUInt64; inline;
       class operator Multiply(const a:TRNLUInt64;const b:TRNLTime):TRNLUInt64; inline;
       class operator Divide(const a,b:TRNLTime):TRNLTime; inline;
       class operator Divide(const a:TRNLTime;const b:TRNLUInt64):TRNLUInt64; inline;
       class operator Divide(const a:TRNLUInt64;const b:TRNLTime):TRNLUInt64; inline;
       class operator IntDivide(const a,b:TRNLTime):TRNLTime; inline;
       class operator IntDivide(const a:TRNLTime;const b:TRNLUInt64):TRNLUInt64; inline;
       class operator IntDivide(const a:TRNLUInt64;const b:TRNLTime):TRNLUInt64; inline;
       class operator Modulus(const a,b:TRNLTime):TRNLTime; inline;
       class operator LeftShift(const a:TRNLTime;const b:TRNLInt32):TRNLTime; inline;
       class operator RightShift(const a:TRNLTime;const b:TRNLInt32):TRNLTime; inline;
       class operator BitwiseAnd(const a,b:TRNLTime):TRNLTime; inline;
       class operator BitwiseOr(const a,b:TRNLTime):TRNLTime; inline;
       class operator BitwiseXor(const a,b:TRNLTime):TRNLTime; inline;
       class operator Negative(const a:TRNLTime):TRNLTime; inline;
       class operator Positive(const a:TRNLTime):TRNLTime; inline;
       property Value:TRNLUInt64 read fValue write fValue;
     end;

     PPRNLSequenceNumber=^PRNLSequenceNumber;
     PRNLSequenceNumber=^TRNLSequenceNumber;
     TRNLSequenceNumber=record
      private
       fValue:TRNLUInt16;
      public
       class operator Implicit(const a:TRNLUInt16):TRNLSequenceNumber; inline;
       class operator Explicit(const a:TRNLUInt16):TRNLSequenceNumber; inline;
       class operator Implicit(const a:TRNLSequenceNumber):TRNLUInt16; inline;
       class operator Explicit(const a:TRNLSequenceNumber):TRNLUInt16; inline;
       class operator Equal(const a,b:TRNLSequenceNumber):boolean; inline;
       class operator NotEqual(const a,b:TRNLSequenceNumber):boolean; inline;
       class operator GreaterThan(const a,b:TRNLSequenceNumber):boolean; inline;
       class operator GreaterThanOrEqual(const a,b:TRNLSequenceNumber):boolean; inline;
       class operator LessThan(const a,b:TRNLSequenceNumber):boolean; inline;
       class operator LessThanOrEqual(const a,b:TRNLSequenceNumber):boolean; inline;
       class function RelativeDifference(const a,b:TRNLSequenceNumber):TRNLInt32; static; inline;
       class function Difference(const a,b:TRNLSequenceNumber):TRNLInt32; static; inline;
       class function Minimum(const a,b:TRNLSequenceNumber):TRNLSequenceNumber; static;
       class operator Inc(const a:TRNLSequenceNumber):TRNLSequenceNumber; inline;
       class operator Dec(const a:TRNLSequenceNumber):TRNLSequenceNumber; inline;
       class operator LogicalNot(const a:TRNLSequenceNumber):TRNLSequenceNumber; inline;
       class operator Add(const a,b:TRNLSequenceNumber):TRNLSequenceNumber; inline;
       class operator Add(const a:TRNLSequenceNumber;const b:TRNLUInt16):TRNLUInt16; inline;
       class operator Add(const a:TRNLUInt16;const b:TRNLSequenceNumber):TRNLUInt16; inline;
       class operator Subtract(const a,b:TRNLSequenceNumber):TRNLSequenceNumber; inline;
       class operator Subtract(const a:TRNLSequenceNumber;const b:TRNLUInt16):TRNLUInt16; inline;
       class operator Subtract(const a:TRNLUInt16;const b:TRNLSequenceNumber):TRNLUInt16; inline;
       class operator Multiply(const a,b:TRNLSequenceNumber):TRNLSequenceNumber; inline;
       class operator Multiply(const a:TRNLSequenceNumber;const b:TRNLUInt16):TRNLUInt16; inline;
       class operator Multiply(const a:TRNLUInt16;const b:TRNLSequenceNumber):TRNLUInt16; inline;
       class operator Divide(const a,b:TRNLSequenceNumber):TRNLSequenceNumber; inline;
       class operator Divide(const a:TRNLSequenceNumber;const b:TRNLUInt16):TRNLUInt16; inline;
       class operator Divide(const a:TRNLUInt16;const b:TRNLSequenceNumber):TRNLUInt16; inline;
       class operator IntDivide(const a,b:TRNLSequenceNumber):TRNLSequenceNumber; inline;
       class operator IntDivide(const a:TRNLSequenceNumber;const b:TRNLUInt16):TRNLUInt16; inline;
       class operator IntDivide(const a:TRNLUInt16;const b:TRNLSequenceNumber):TRNLUInt16; inline;
       class operator Modulus(const a,b:TRNLSequenceNumber):TRNLSequenceNumber; inline;
       class operator LeftShift(const a:TRNLSequenceNumber;const b:TRNLInt32):TRNLSequenceNumber; inline;
       class operator RightShift(const a:TRNLSequenceNumber;const b:TRNLInt32):TRNLSequenceNumber; inline;
       class operator BitwiseAnd(const a,b:TRNLSequenceNumber):TRNLSequenceNumber; inline;
       class operator BitwiseOr(const a,b:TRNLSequenceNumber):TRNLSequenceNumber; inline;
       class operator BitwiseXor(const a,b:TRNLSequenceNumber):TRNLSequenceNumber; inline;
       class operator Negative(const a:TRNLSequenceNumber):TRNLSequenceNumber; inline;
       class operator Positive(const a:TRNLSequenceNumber):TRNLSequenceNumber; inline;
       property Value:TRNLUInt16 read fValue write fValue;
     end;

     TRNLSequenceNumberArray=array of TRNLSequenceNumber;

     PRNLKey=^TRNLKey;
     TRNLKey=record
      public
       class operator Implicit(const a:TRNLUInt64):TRNLKey;
       class operator Explicit(const a:TRNLUInt64):TRNLKey;
       class operator Implicit(const a:TRNLKey):TRNLUInt64;
       class operator Explicit(const a:TRNLKey):TRNLUInt64;
       class operator Equal(const a,b:TRNLKey):boolean;
       class operator NotEqual(const a,b:TRNLKey):boolean;
       function ClampForCurve25519:TRNLKey; inline;
       function ConvertFromED25519ToX25519PrivateKey:TRNLKey;
       function ConvertFromED25519ToX25519PublicKey:TRNLKey;
       class function CreateRandom(const aRandomGenerator:TRNLRandomGenerator):TRNLKey; static;
       case TRNLUInt8 of
        0:(
         ui8:array[0..(RNL_KEY_SIZE div SizeOf(TRNLUInt8))-1] of TRNLUInt8;
        );
        1:(
         ui16:array[0..(RNL_KEY_SIZE div SizeOf(TRNLUInt16))-1] of TRNLUInt16;
        );
        2:(
         ui32:array[0..(RNL_KEY_SIZE div SizeOf(TRNLUInt32))-1] of TRNLUInt32;
        );
        3:(
         ui64:array[0..(RNL_KEY_SIZE div SizeOf(TRNLUInt64))-1] of TRNLUInt64;
        );
     end;

     PRNLTwoKeys=^TRNLTwoKeys;
     TRNLTwoKeys=array[0..1] of TRNLKey;

     PRNLValue2551964=^TRNLValue2551964;
     TRNLValue2551964=record
      public
       Limbs:array[0..9] of TRNLInt64;
     end;

     PRNLValue25519=^TRNLValue25519;
     TRNLValue25519=record
      public
       constructor Create(const aValue:TRNLInt32);
       class operator Implicit(const a:TRNLInt32):TRNLValue25519; //inline;
       class operator Explicit(const a:TRNLInt32):TRNLValue25519; //inline;
       class operator Add(const a,b:TRNLValue25519):TRNLValue25519; //inline;
       class operator Subtract(const a,b:TRNLValue25519):TRNLValue25519; //inline;
       class operator Multiply(const a,b:TRNLValue25519):TRNLValue25519; //{$if not (defined(CPUX64) and not defined(fpc))}inline;{$ifend}
       class operator Negative(const a:TRNLValue25519):TRNLValue25519; //inline;
       class operator Positive(const a:TRNLValue25519):TRNLValue25519; //inline;
       class operator Equal(const a,b:TRNLValue25519):boolean; //inline;
       class operator NotEqual(const a,b:TRNLValue25519):boolean; //inline;
       function Square:TRNLValue25519; overload; //{$if not (defined(CPUX64) and not defined(fpc))}inline;{$ifend}
       function Square(const aCount:TRNLInt32):TRNLValue25519; overload;
       class procedure ConditionalSwap(var a,b:TRNLValue25519;const aSelect:TRNLInt32); static;
       function Carry:TRNLValue25519; //inline;
       class function Carry64(const aValue:TRNLValue2551964):TRNLValue25519; static; //{$if not (defined(CPUX64) and not defined(fpc))}inline;{$ifend}
       class function CreateRandom(const aRandomGenerator:TRNLRandomGenerator):TRNLValue25519; static; //{$if not (defined(CPUX64) and not defined(fpc))}inline;{$ifend}
       class function LoadFromMemory(const aLocation):TRNLValue25519; static;
       procedure SaveToMemory(out aLocation);
       class operator Multiply(const a:TRNLValue25519;const b:TRNLInt32):TRNLValue25519; //{$if not (defined(CPUX64) and not defined(fpc))}inline;{$ifend}
       function Mul121666:TRNLValue25519; //{$if not (defined(CPUX64) and not defined(fpc))}inline;{$ifend}
       function Mul973324:TRNLValue25519; //{$if not (defined(CPUX64) and not defined(fpc))}inline;{$ifend}
       function Invert:TRNLValue25519; //{$if not (defined(CPUX64) and not defined(fpc))}inline;{$ifend}
       function Pow22523:TRNLValue25519; //{$if not (defined(CPUX64) and not defined(fpc))}inline;{$ifend}
       function IsNegative:boolean; inline;
       function IsNonZero:boolean; inline;
       function IsZero:boolean; inline;
       class procedure SelfTest; static;
       case TRNLUInt8 of
        0:(
         Limbs:array[0..9] of TRNLInt32;
        );
     end;

     PRNLPoint25519=^TRNLPoint25519;
     TRNLPoint25519=record
      private
       fX:TRNLValue25519;
       fY:TRNLValue25519;
       fZ:TRNLValue25519;
       fT:TRNLValue25519;
      public
       constructor CreateFromXY(const aX,aY:TRNLValue25519);
       class function LoadFromMemory(out aPoint:TRNLPoint25519;const aLocation):boolean; static;
       procedure SaveToMemory(out aLocation);
       class operator Add(const p,q:TRNLPoint25519):TRNLPoint25519;
     end;

     PRNLCurve25519=^TRNLCurve25519;
     TRNLCurve25519=record
      public
       class procedure Clean(out aX:TRNLKey); static;
       class function IsWeakPoint(const aK:TRNLKey):boolean; static;
       class function IsInRange(const aX:TRNLKey):boolean; static;
       class procedure Ladder(const aX1:TRNLValue25519;out aX2,aZ2,aX3,aZ3:TRNLValue25519;const aScalar:TRNLKey); static;
       class function Eval(out aResult:TRNLKey;const aSecret:TRNLKey;const aBasePoint:PRNLKey=nil):boolean; static;
       class procedure SelfTest; static;
     end;

     PRNLX25519=^TRNLX25519;
     TRNLX25519=record
      public
       class function GeneratePublicPrivateKeyPair(const aRandomGenerator:TRNLRandomGenerator;out aPublicKey,aPrivateKey:TRNLKey):boolean; static;
       class function GenerateSharedSecretKey(out aSharedSecretKey:TRNLKey;const aPublicKey,aPrivateKey:TRNLKey):boolean; static;
       class procedure SelfTest; static;
     end;

     PRNLPoly1305MAC=^TRNLPoly1305MAC;
     TRNLPoly1305MAC=array[0..15] of TRNLUInt8;

     PRNLPoly1305Context=^TRNLPoly1305Context;
     TRNLPoly1305Context=record
      private
       fR:array[0..3] of TRNLUInt32;
       fH:array[0..4] of TRNLUInt32;
       fC:array[0..4] of TRNLUInt32;
       fPad:array[0..3] of TRNLUInt32;
       fCIndex:TRNLUInt32;
       procedure ClearC; inline;
       procedure ProcessByte(const aValue:TRNLUInt8); inline;
       procedure Block;
      public
       procedure Initialize(const aKey);
       procedure Update(const aMessage;const aMessageSize:TRNLSizeUInt);
       procedure Finalize(out aMAC);
     end;

     PRNLPoly1305=^TRNLPoly1305;
     TRNLPoly1305=record
      public
       class function OneTimeAuthentication(out aOutput;const aInput;const aInputLength:TRNLSizeUInt;const aSecretKey):boolean; static;
       class function OneTimeAuthenticationVerify(const aComparsion;const aInput;const aInputLength:TRNLSizeUInt;const aSecretKey):boolean; static;
       class procedure SelfTest; static;
     end;

     PRNLSHA512State=^TRNLSHA512State;
     TRNLSHA512State=array[0..7] of TRNLUInt64;

     PRNLSHA512Hash=^TRNLSHA512Hash;
     TRNLSHA512Hash=array[0..63] of TRNLUInt8;

     PRNLSHA512Input=^TRNLSHA512Input;
     TRNLSHA512Input=array[0..15] of TRNLUInt64;

     PRNLSHA512Context=^TRNLSHA512Context;
     TRNLSHA512Context=record
      public
       const BLOCK_SIZE=512;
             HASH_SIZE=64;
      private
       const InitialState:TRNLSHA512State=
              (
               TRNLUInt64($6a09e667f3bcc908),TRNLUInt64($bb67ae8584caa73b),
               TRNLUInt64($3c6ef372fe94f82b),TRNLUInt64($a54ff53a5f1d36f1),
               TRNLUInt64($510e527fade682d1),TRNLUInt64($9b05688c2b3e6c1f),
               TRNLUInt64($1f83d9abfb41bd6b),TRNLUInt64($5be0cd19137e2179)
              );
             RoundK:array[0..79] of TRNLUInt64=
              (
               TRNLUInt64($428a2f98d728ae22),TRNLUInt64($7137449123ef65cd),
               TRNLUInt64($b5c0fbcfec4d3b2f),TRNLUInt64($e9b5dba58189dbbc),
               TRNLUInt64($3956c25bf348b538),TRNLUInt64($59f111f1b605d019),
               TRNLUInt64($923f82a4af194f9b),TRNLUInt64($ab1c5ed5da6d8118),
               TRNLUInt64($d807aa98a3030242),TRNLUInt64($12835b0145706fbe),
               TRNLUInt64($243185be4ee4b28c),TRNLUInt64($550c7dc3d5ffb4e2),
               TRNLUInt64($72be5d74f27b896f),TRNLUInt64($80deb1fe3b1696b1),
               TRNLUInt64($9bdc06a725c71235),TRNLUInt64($c19bf174cf692694),
               TRNLUInt64($e49b69c19ef14ad2),TRNLUInt64($efbe4786384f25e3),
               TRNLUInt64($0fc19dc68b8cd5b5),TRNLUInt64($240ca1cc77ac9c65),
               TRNLUInt64($2de92c6f592b0275),TRNLUInt64($4a7484aa6ea6e483),
               TRNLUInt64($5cb0a9dcbd41fbd4),TRNLUInt64($76f988da831153b5),
               TRNLUInt64($983e5152ee66dfab),TRNLUInt64($a831c66d2db43210),
               TRNLUInt64($b00327c898fb213f),TRNLUInt64($bf597fc7beef0ee4),
               TRNLUInt64($c6e00bf33da88fc2),TRNLUInt64($d5a79147930aa725),
               TRNLUInt64($06ca6351e003826f),TRNLUInt64($142929670a0e6e70),
               TRNLUInt64($27b70a8546d22ffc),TRNLUInt64($2e1b21385c26c926),
               TRNLUInt64($4d2c6dfc5ac42aed),TRNLUInt64($53380d139d95b3df),
               TRNLUInt64($650a73548baf63de),TRNLUInt64($766a0abb3c77b2a8),
               TRNLUInt64($81c2c92e47edaee6),TRNLUInt64($92722c851482353b),
               TRNLUInt64($a2bfe8a14cf10364),TRNLUInt64($a81a664bbc423001),
               TRNLUInt64($c24b8b70d0f89791),TRNLUInt64($c76c51a30654be30),
               TRNLUInt64($d192e819d6ef5218),TRNLUInt64($d69906245565a910),
               TRNLUInt64($f40e35855771202a),TRNLUInt64($106aa07032bbd1b8),
               TRNLUInt64($19a4c116b8d2d0c8),TRNLUInt64($1e376c085141ab53),
               TRNLUInt64($2748774cdf8eeb99),TRNLUInt64($34b0bcb5e19b48a8),
               TRNLUInt64($391c0cb3c5c95a63),TRNLUInt64($4ed8aa4ae3418acb),
               TRNLUInt64($5b9cca4f7763e373),TRNLUInt64($682e6ff3d6b2b8a3),
               TRNLUInt64($748f82ee5defb2fc),TRNLUInt64($78a5636f43172f60),
               TRNLUInt64($84c87814a1f0ab72),TRNLUInt64($8cc702081a6439ec),
               TRNLUInt64($90befffa23631e28),TRNLUInt64($a4506cebde82bde9),
               TRNLUInt64($bef9a3f7b2c67915),TRNLUInt64($c67178f2e372532b),
               TRNLUInt64($ca273eceea26619c),TRNLUInt64($d186b8c721c0c207),
               TRNLUInt64($eada7dd6cde0eb1e),TRNLUInt64($f57d4f7fee6ed178),
               TRNLUInt64($06f067aa72176fba),TRNLUInt64($0a637dc5a2c898a6),
               TRNLUInt64($113f9804bef90dae),TRNLUInt64($1b710b35131c471b),
               TRNLUInt64($28db77f523047d84),TRNLUInt64($32caab7b40c72493),
               TRNLUInt64($3c9ebe0a15c9bebc),TRNLUInt64($431d67c49c100d4c),
               TRNLUInt64($4cc5d4becb3e42b6),TRNLUInt64($597f299cfc657e2a),
               TRNLUInt64($5fcb6fab3ad6faec),TRNLUInt64($6c44198c4a475817)
              );
      private
       fState:TRNLSHA512State;
       fInput:TRNLSHA512Input;
       fInputSize:array[0..1] of TRNLUInt64;
       fInputIndex:TRNLUInt32;
       class function RotateRight64(const aValue:TRNLUInt64;const aBits:TRNLUInt32):TRNLUInt64; static; inline;
       procedure ResetInput;
       procedure Compress;
       procedure ProcessByte(const aValue:TRNLUInt8);
       procedure Increment(var aX;const aY:TRNLUInt64);
       procedure EndBlock;
      public
       procedure Initialize;
       procedure Update(const aMessage;const aMessageSize:TRNLSizeUInt);
       procedure Finalize(out aHash);
     end;

     PRNLSHA512=^TRNLSHA512;
     TRNLSHA512=record
      public
       class procedure Process(out aHash;const aMessage;const aMessageSize:TRNLSizeUInt); static;
       class procedure SelfTest; static;
     end;

     PRNLBLAKE2BHash=^TRNLBLAKE2BHash;
     TRNLBLAKE2BHash=array[0..63] of TRNLUInt8;

     PRNLBLAKE2BKey=^TRNLBLAKE2BKey;
     TRNLBLAKE2BKey=array[0..63] of TRNLUInt8;

     PRNLBLAKE2BOut=^TRNLBLAKE2BOut;
     TRNLBLAKE2BOut=array[0..63] of TRNLUInt8;

     PRNLBLAKE2BBlock=^TRNLBLAKE2BBlock;
     TRNLBLAKE2BBlock=array[0..127] of TRNLUInt8;

{$define RNLUseBLAKE2BManualExpanded}

     PRNLBLAKE2BContext=^TRNLBLAKE2BContext;
     TRNLBLAKE2BContext=record
      public
       const BLAKE2B_BLOCKBYTES=128;
             BLAKE2B_OUTBYTES=64;
             BLAKE2B_KEYBYTES=64;
      private
       type TVectors=array[0..7] of TRNLUInt64;
            TWorkVectors=array[0..15] of TRNLUInt64;
       const InitializationVectors:TVectors=
              (
               TRNLUInt64($6a09e667f3bcc908),TRNLUInt64($bb67ae8584caa73b),
               TRNLUInt64($3c6ef372fe94f82b),TRNLUInt64($a54ff53a5f1d36f1),
               TRNLUInt64($510e527fade682d1),TRNLUInt64($9b05688c2b3e6c1f),
               TRNLUInt64($1f83d9abfb41bd6b),TRNLUInt64($5be0cd19137e2179)
              );
             Sigma:array[0..11,0..15] of TRNLUInt8=
              (
               (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15),
               (14,10,4,8,9,15,13,6,1,12,0,2,11,7,5,3),
               (11,8,12,0,5,2,15,13,10,14,3,6,7,1,9,4),
               (7,9,3,1,13,12,11,14,2,6,5,10,4,0,15,8),
               (9,0,5,7,2,4,10,15,14,1,11,12,6,8,3,13),
               (2,12,6,10,0,11,8,3,4,13,7,5,15,14,1,9),
               (12,5,1,15,14,13,4,10,0,7,6,3,9,2,8,11),
               (13,11,7,14,12,1,3,9,5,0,15,4,8,6,2,10),
               (6,15,14,9,11,3,0,8,12,2,13,7,1,4,10,5),
               (10,2,8,4,7,6,1,5,15,11,9,14,3,12,13,0),
               (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15),
               (14,10,4,8,9,15,13,6,1,12,0,2,11,7,5,3)
              );
      private
       fBuffer:TRNLBLAKE2BBlock;
       fH:TVectors;
       fT:array[0..1] of TRNLUInt64;
       fBufferLen:TRNLSizeUInt;
       fOutLen:TRNLSizeUInt;
       class function RotateRight64(const aValue:TRNLUInt64;const aBits:TRNLUInt32):TRNLUInt64; static; inline;
{$if not defined(RNLUseBLAKE2BManualExpanded)}
       procedure G(const r,i:TRNLUInt64;var a,b,c,d:TRNLUInt64;var M:TWorkVectors); inline;
       procedure Round_(const r:TRNLUInt64;var V,M:TWorkVectors); inline;
{$ifend}
       procedure Compress(const aLast:boolean);
      public
       function Initialize(const aOutLen:TRNLSizeInt=BLAKE2B_OUTBYTES;const aKey:Pointer=nil;const aKeyLen:TRNLSizeInt=64):boolean;
       procedure Update(const aMessage;const aMessageSize:TRNLSizeUInt);
       procedure Finalize(out aHash);
     end;

     PRNLBLAKE2B=^TRNLBLAKE2B;
     TRNLBLAKE2B=record
      public
       class function Process(out aHash;const aMessage;const aMessageSize:TRNLSizeUInt;const aOutLen:TRNLSizeInt=TRNLBLAKE2BContext.BLAKE2B_OUTBYTES;const aKey:Pointer=nil;const aKeyLen:TRNLSizeInt=TRNLBLAKE2BContext.BLAKE2B_KEYBYTES):boolean; static;
       class procedure SelfTest; static;
     end;

     PRNLED25519HashContext=^TRNLED25519HashContext;
     TRNLED25519HashContext={$ifdef RNLUseBLAKE2B}TRNLBLAKE2BContext{$else}TRNLSHA512Context{$endif};

     PRNLED25519Hash=^TRNLED25519Hash;
     TRNLED25519Hash={$ifdef RNLUseBLAKE2B}TRNLBLAKE2B{$else}TRNLSHA512{$endif};

     PRNLED25519Signature=^TRNLED25519Signature;
     TRNLED25519Signature=array[0..63] of TRNLUInt8;

     PRNLED25519=^TRNLED25519;
     TRNLED25519=record
      private
       class procedure ModL(out aR;const aX); static;
       class procedure Reduce(var aR); static;
       class procedure HashRAM(out aK;const aR,aA,aM;const aMSize:TRNLSizeUInt); static;
       class function ScalarMultiplication(out aResult:TRNLPoint25519;const aInput:TRNLPoint25519;const aScalar:TRNLKey):boolean; overload; static;
       class function ScalarMultiplicationBase(out aResult:TRNLPoint25519;const aScalar:TRNLKey):boolean; overload; static;
      public
       class procedure DerivePublicKey(out aPublicKey;const aPrivateKey); static;
       class procedure GeneratePublicPrivateKeyPair(const aRandomGenerator:TRNLRandomGenerator;out aPublicKey,aPrivateKey); static;
       class procedure Sign(out aSignature;const aPrivateKey,aMessage;const aMessageSize:TRNLSizeUInt;const aPublicKey:TRNLPointer=nil); overload; static;
       class procedure Sign(out aSignature;const aPrivateKey,aPublicKey,aMessage;const aMessageSize:TRNLSizeUInt); overload; static;
       class function Verify(const aSignature,aPublicKey,aMessage;const aMessageSize:TRNLSizeUInt):boolean; static;
       class procedure SelfTest; static;
     end;

     PRNLKeyExchange=^TRNLKeyExchange;
     TRNLKeyExchange=record
      public
       class function Process(out aSharedKey:TRNLKey;const aYourSecretKey,aTheirPublicKey:TRNLKey):boolean; static;
     end;

     PRNLAuthenticatedEncryption=^TRNLAuthenticatedEncryption;
     TRNLAuthenticatedEncryption=record
      private
       class procedure Authenticate(out aMAC;const aAuthKey,aT1;const aT1Size:TRNLSizeUInt;const aT2;const aT2Size:TRNLSizeUInt); static;
      public
       class function Encrypt(out aCipherText;const aKey,aNonce;out aMAC;const aAssociatedData;const aAssociatedDataSize:TRNLSizeUInt;const aPlainText;const aPlainTextSize:TRNLSizeUInt):boolean; overload; static;
       class function Encrypt(out aCipherText;const aKey,aNonce;out aMAC;const aPlainText;const aPlainTextSize:TRNLSizeUInt):boolean; overload; static;
       class function Decrypt(out aPlainText;const aKey,aNonce,aMAC,aAssociatedData;const aAssociatedDataSize:TRNLSizeUInt;const aCipherText;const aCipherTextSize:TRNLSizeUInt):boolean; overload; static;
       class function Decrypt(out aPlainText;const aKey,aNonce,aMAC,aCipherText;const aCipherTextSize:TRNLSizeUInt):boolean; overload; static;
     end;

     PRNLSocket=^TRNLSocket;
     TRNLSocket=type {$if defined(Unix)}TSocket{$else}TRNLPtrUInt{$ifend};

     TRNLSocketArray=array of TRNLSocket;

     PRNLSocketSet=^TRNLSocketSet;
     TRNLSocketSet={$if defined(Posix)}fd_Set{$elseif defined(Unix)}TFDSet{$else}record
      fd_count:TRNLUInt32;
      fd_array:array[0..RNL_FD_SETSIZE-1] of TRNLSocket;
     end{$ifend};

     TRNLSocketSetHelper=record helper for TRNLSocketSet
      public
       class function Empty:TRNLSocketSet; static;
       procedure Clear;
       procedure Add(const aSocket:TRNLSocket);
       procedure Remove(const aSocket:TRNLSocket);
       function Check(const aSocket:TRNLSocket):boolean;
     end;

     PRNLProtocolFlags=^TRNLProtocolFlags;
     TRNLProtocolFlags=TRNLInt32;

     TRNLSpinLock=class(TSynchroObject)
      private
       fState:TRNLInt32;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Acquire; override;
       procedure Release; override;
     end;

     TRNLCircularDoublyLinkedListNode<T>=class
      public
       type TValueEnumerator=record
             private
              fCircularDoublyLinkedList:TRNLCircularDoublyLinkedListNode<T>;
              fNode:TRNLCircularDoublyLinkedListNode<T>;
              function GetCurrent:T; inline;
             public
              constructor Create(const aCircularDoublyLinkedList:TRNLCircularDoublyLinkedListNode<T>);
              function MoveNext:boolean; inline;
              property Current:T read GetCurrent;
            end;
            TCompareFunc=function(const a,b:TObject):TRNLInt32 of object;
      private
       fNext:TRNLCircularDoublyLinkedListNode<T>;
       fPrevious:TRNLCircularDoublyLinkedListNode<T>;
       fValue:T;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Clear; inline;
       function Head:TRNLCircularDoublyLinkedListNode<T>; inline;
       function Tail:TRNLCircularDoublyLinkedListNode<T>; inline;
       function IsEmpty:boolean; inline;
       function IsNotEmpty:boolean; inline;
       function Front:TRNLCircularDoublyLinkedListNode<T>; inline;
       function Back:TRNLCircularDoublyLinkedListNode<T>; inline;
       function Insert(const aData:TRNLCircularDoublyLinkedListNode<T>):TRNLCircularDoublyLinkedListNode<T>; inline;
       function Add(const aData:TRNLCircularDoublyLinkedListNode<T>):TRNLCircularDoublyLinkedListNode<T>; inline;
       function Remove:TRNLCircularDoublyLinkedListNode<T>; // inline;
       function MoveFrom(const aDataFirst,aDataLast:TRNLCircularDoublyLinkedListNode<T>):TRNLCircularDoublyLinkedListNode<T>; inline;
       function PopFromFront(out aData):boolean; inline;
       function PopFromBack(out aData):boolean; inline;
       function SortedInserted(const aData:TRNLCircularDoublyLinkedListNode<T>;const aCompareFunc:TCompareFunc):TRNLCircularDoublyLinkedListNode<T>;
       function ListSize:TRNLSizeUInt;
       function GetEnumerator:TValueEnumerator;
      published
       property Next:TRNLCircularDoublyLinkedListNode<T> read fNext write fNext;
       property Previous:TRNLCircularDoublyLinkedListNode<T> read fPrevious write fPrevious;
      public
       property Value:T read fValue write fValue;
     end;

     TRNLQueue<T>=class
      private
       type TRNLQueueItems=array of T;
      private
       fItems:TRNLQueueItems;
       fHead:TRNLSizeInt;
       fTail:TRNLSizeInt;
       fCount:TRNLSizeInt;
       fSize:TRNLSizeInt;
       fSpinLock:TRNLSpinLock;
       function GetCount:TRNLSizeInt; inline;
       procedure GrowResize(const aSize:TRNLSizeInt);
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Clear;
       function IsEmpty:boolean; inline;
       function IsNotEmpty:boolean; inline;
       procedure EnqueueAtFront(const aItem:T);
       procedure Enqueue(const aItem:T);
       function Dequeue(out aItem:T):boolean; overload;
       function Dequeue:boolean; overload;
       function Peek(out aItem:T):boolean;
      published
       property Count:TRNLSizeInt read GetCount;
     end;

     TRNLSequenceNumberQueue=TRNLQueue<TRNLSequenceNumber>;

     TRNLStack<T>=class
      private
       type TRNLStackArray=array of T;
      private
       fItems:TRNLStackArray;
       fCount:TRNLSizeInt;
       fSpinLock:TRNLSpinLock;
       function GetCount:TRNLSizeInt; inline;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Clear;
       function IsEmpty:boolean; inline;
       function IsNotEmpty:boolean; inline;
       procedure Push(const aItem:T);
       function Pop(out aItem:T):boolean;
       function Peek(out aItem:T):boolean;
      published
       property Count:TRNLSizeInt read GetCount;
     end;

     TRNLObjectList<T:class>=class
      public
       type TValueEnumerator=record
             private
              fObjectList:TRNLObjectList<T>;
              fIndex:TRNLSizeInt;
              function GetCurrent:T; inline;
             public
              constructor Create(const aObjectList:TRNLObjectList<T>);
              function MoveNext:boolean; inline;
              property Current:T read GetCurrent;
            end;
      private
       fItems:array of T;
       fCount:TRNLSizeInt;
       fAllocated:TRNLSizeInt;
       fOwnObjects:boolean;
       function GetItem(const pIndex:TRNLSizeInt):T; inline;
       procedure SetItem(const pIndex:TRNLSizeInt;const pItem:T); inline;
      protected
      public
       constructor Create(const aOwnObjects:boolean);
       destructor Destroy; override;
       procedure Clear;
       procedure Assign(const pFrom:TRNLObjectList<T>);
       function IndexOf(const pItem:T):TRNLSizeInt;
       function Add(const pItem:T):TRNLSizeInt;
       procedure Insert(const pIndex:TRNLSizeInt;const pItem:T);
       procedure Delete(const pIndex:TRNLSizeInt);
       procedure Remove(const pItem:T);
       procedure Exchange(const pIndex,pWithIndex:TRNLSizeInt);
       function GetEnumerator:TValueEnumerator;
       property Count:TRNLSizeInt read fCount{ write SetCount};
       property Allocated:TRNLSizeInt read fAllocated;
       property Items[const pIndex:TRNLSizeInt]:T read GetItem write SetItem; default;
     end;

     TRNLBits=class
      private
       type TRNLBitsData=array of TRNLUInt32;
      private
       fData:TRNLBitsData;
       fSize:TRNLSizeInt;
       function GetBit(const aIndex:TRNLSizeInt):boolean; inline;
       procedure SetBit(const aIndex:TRNLSizeInt;const aBit:boolean); inline;
      public
       constructor Create(const aSize:TRNLSizeInt); reintroduce;
       destructor Destroy; override;
       procedure Clear;
       function GetNextSetBitIndex(const aIndex:TRNLSizeInt=-1):TRNLSizeInt;
       property Bits[const aIndex:TRNLSizeInt]:boolean read GetBit write SetBit; default;
       property Size:TRNLSizeInt read fSize;
     end;

     TRNLID=TRNLUInt32;

     TRNLIDManager=class
      private
       type TRNLIDManagerFreeStack=TRNLStack<TRNLID>;
      private
       fIDCounter:TRNLID;
       fFreeStack:TRNLIDManagerFreeStack;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       function AllocateID:TRNLID;
       procedure FreeID(const aID:TRNLID);
      published
       property IDCounter:TRNLID read fIDCounter;
     end;

     TRNLIDMap<T:class>=class
      private
       fItems:array of T;
       fCount:TRNLSizeUInt;
       function GetItem(const aID:TRNLID):T;
       procedure SetItem(const aID:TRNLID;const aItem:T);
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       property Items[const aID:TRNLID]:T read GetItem write SetItem; default;
      published
     end;

     PRNLCipherNonce=^TRNLCipherNonce;
     TRNLCipherNonce=record
      case TRNLUInt8 of
       0:(
        ui8:array[0..23] of TRNLUInt8;
       );
       1:(
        ui16:array[0..11] of TRNLUInt16;
       );
       2:(
        ui32:array[0..5] of TRNLUInt32;
       );
       3:(
        ui64:array[0..2] of TRNLUInt64;
       );
     end;

     PRNLCipherMAC=^TRNLCipherMAC;
     TRNLCipherMAC=array[0..15] of TRNLUInt8;

     PRNLSocketType=^TRNLSocketType;
     TRNLSocketType=
      (
       RNL_SOCKET_TYPE_STREAM=1,
       RNL_SOCKET_TYPE_DATAGRAM=2
      );

     PRNLSocketWait=^TRNLSocketWait;
     TRNLSocketWait=TRNLUInt8;

     PRNLSocketOption=^TRNLSocketOption;
     TRNLSocketOption=
      (
       RNL_SOCKET_OPTION_NONE,
       RNL_SOCKET_OPTION_NONBLOCK,
       RNL_SOCKET_OPTION_BROADCAST,
       RNL_SOCKET_OPTION_RCVBUF,
       RNL_SOCKET_OPTION_SNDBUF,
       RNL_SOCKET_OPTION_REUSEADDR,
       RNL_SOCKET_OPTION_RCVTIMEO,
       RNL_SOCKET_OPTION_SNDTIMEO,
       RNL_SOCKET_OPTION_ERROR,
       RNL_SOCKET_OPTION_NODELAY,
       RNL_SOCKET_OPTION_DONTFRAGMENT,
       RNL_SOCKET_OPTION_IPV6_V6ONLY
      );

     PRNLSocketShutdown=^TRNLSocketShutdown;
     TRNLSocketShutdown=
      (
       RNL_SOCKET_SHUTDOWN_READ=0,
       RNL_SOCKET_SHUTDOWN_WRITE=1,
       RNL_SOCKET_SHUTDOWN_READ_WRITE=2
      );

     PRNLAddressFamily=^TRNLAddressFamily;
     TRNLAddressFamily=TRNLUInt8;

     TRNLAddressFamilyHelper=record helper for TRNLAddressFamily
      public
       function GetAddressFamily:TRNLUInt16;
       function GetSockAddrSize:TRNLInt32;
     end;

     PRNLHostAddress=^TRNLHostAddress;
     TRNLHostAddress=packed record
      public
       Addr:array[0..15] of TRNLUInt8;
       constructor CreateFromIPV4(Address:TRNLUInt32);
       function Equals(const aWith:TRNLHostAddress):boolean;
     end;

     PRNLAddress=^TRNLAddress;
     TRNLAddress=packed record
      public
       Host:TRNLHostAddress;
       ScopeID:{$ifdef Unix}TRNLUInt32{$else}TRNLInt64{$endif};
       Port:TRNLUInt16;
       constructor CreateFromString(const aString:TRNLString);
       function GetAddressFamily:TRNLAddressFamily; inline;
       function SetAddress(const aSIN:TRNLPointer):TRNLAddressFamily;
       function SetSIN(const aSIN:TRNLPointer;const aFamily:TRNLAddressFamily):boolean;
       function ToString:TRNLString;
       function Equals(const aWith:TRNLAddress):boolean;
     end;

     PRNLSocketWaitCondition=^TRNLSocketWaitCondition;
     TRNLSocketWaitCondition=
      (
       RNL_SOCKET_WAIT_CONDITION_IO_RECEIVE,
       RNL_SOCKET_WAIT_CONDITION_IO_SEND,
       RNL_SOCKET_WAIT_CONDITION_IO_INTERRUPT,
       RNL_SOCKET_WAIT_CONDITION_SERVICE_INTERRUPT
      );

     PRNLSocketWaitConditions=^TRNLSocketWaitConditions;
     TRNLSocketWaitConditions=set of TRNLSocketWaitCondition;

     PRNLConnectionChallenge=^TRNLConnectionChallenge;
     TRNLConnectionChallenge={$ifdef RNLUseBLAKE2B}TRNLBLAKE2BHash{$else}TRNLSHA512Hash{$endif};

     PRNLConnectionChallengePair=^TRNLConnectionChallengePair;
     TRNLConnectionChallengePair=array[0..1] of TRNLConnectionChallenge;

     PRNLConnectionRequestRateLimiter=^TRNLConnectionRequestRateLimiter;
     TRNLConnectionRequestRateLimiter=record
      private
       fBurst:TRNLInt64;
       fLastTime:TRNLUInt64;
      public
       procedure Reset(const aTime:TRNLTime);
       function RateLimit(const aTime:TRNLTime;const aBurst:TRNLInt64;const aPeriod:TRNLUInt64):boolean;
     end;

     PRNLBandwidthRateLimiter=^TRNLBandwidthRateLimiter;
     TRNLBandwidthRateLimiter=record
      private
       fMaximumPerPeriod:TRNLUInt64;
       fPeriodLength:TRNLUInt64;
       fUsedInPeriod:TRNLUInt64;
       fPeriodStart:TRNLTime;
       fPeriodEnd:TRNLTime;
      public
       constructor Create(const aMaximumPerPeriod,aPeriodLength:TRNLUInt64;const aTime:TRNLTime);
       procedure Setup(const aMaximumPerPeriod,aPeriodLength:TRNLUInt64);
       procedure Reset(const aTime:TRNLTime);
       function CanProceed(const aDesired:TRNLUInt32;const aTime:TRNLTime):boolean;
       procedure AddAmount(const aUsed:TRNLUInt32;const aTime:TRNLTime);
       property MaximumPerPeriod:TRNLUInt64 read fMaximumPerPeriod;
       property UsedInPeriod:TRNLUInt64 read fUsedInPeriod;
     end;

     PRNLBandwidthRateTracker=^TRNLBandwidthRateTracker;
     TRNLBandwidthRateTracker=record
      private
       fPeriodUnits:TRNLSizeUInt;
       fUnitsPerSecond:TRNLUInt32;
       fLastTime:TRNLTime;
       fTime:TRNLTime;
      public
       procedure Reset;
       procedure SetTime(const aTime:TRNLTime);
       procedure AddUnits(const aUnits:TRNLUInt32);
       procedure Update;
       property UnitsPerSecond:TRNLUInt32 read fUnitsPerSecond;
     end;

     PRNLPacketBuffer=^TRNLPacketBuffer;
     TRNLPacketBuffer=array[0..65535] of TRNLUInt8;

     PRNLOutgoingPacketBuffer=^TRNLOutgoingPacketBuffer;
     TRNLOutgoingPacketBuffer=record
      private
       fSize:TRNLSizeUInt;
       fAssociatedDataSize:TRNLSizeUInt;
       fBufferLength:TRNLSizeUInt;
       fData:TRNLPacketBuffer;
     public
       procedure Reset(const aAssociatedDataSize:TRNLSizeUInt=0;const aBufferLength:TRNLSizeUInt=SizeOf(TRNLPacketBuffer));
       function HasSpaceFor(const aDataLength:TRNLSizeUInt):boolean;
       function PayloadSize:TRNLSizeUInt;
       function Write(const aData;const aDataLength:TRNLSizeUInt):TRNLSizeUInt;
       property Size:TRNLSizeUInt read fSize;
     end;

     PRNLConnectionToken=^TRNLConnectionToken;
     TRNLConnectionToken=packed record
      public
       class operator Equal(const a,b:TRNLConnectionToken):boolean; inline;
       class operator NotEqual(const a,b:TRNLConnectionToken):boolean; inline;
      public
       Data:array[0..RNL_CONNECTION_TOKEN_SIZE-1] of TRNLUInt8;
     end;

     PRNLAuthenticationToken=^TRNLAuthenticationToken;
     TRNLAuthenticationToken=packed record
      public
       class operator Equal(const a,b:TRNLAuthenticationToken):boolean; inline;
       class operator NotEqual(const a,b:TRNLAuthenticationToken):boolean; inline;
      public
       Data:array[0..RNL_AUTHENTICATION_TOKEN_SIZE-1] of TRNLUInt8;
     end;

     PRNLConnectionKnownCandidateHostAddress=^TRNLConnectionKnownCandidateHostAddress;
     TRNLConnectionKnownCandidateHostAddress=record
      case boolean of
       false:(
        HostAddress:TRNLHostAddress;
        RateLimiter:TRNLConnectionRequestRateLimiter;
       );
       true:(
       );
     end;

     PRNLConnectionKnownCandidateHostAddressHashTable=^TRNLConnectionKnownCandidateHostAddressHashTable;
     TRNLConnectionKnownCandidateHostAddressHashTable=record
      public
       const HashBits=12;
             HashSize=1 shl HashBits;
             HashMask=HashSize-1;
       type PRNLConnectionKnownCandidateHostAddressHashTableEntries=^TRNLConnectionKnownCandidateHostAddressHashTableEntries;
            TRNLConnectionKnownCandidateHostAddressHashTableEntries=array[0..HashSize-1] of TRNLConnectionKnownCandidateHostAddress;
      private
       fEntries:TRNLConnectionKnownCandidateHostAddressHashTableEntries;
      public
       procedure Clear;
       function Find(const aHostAddress:TRNLHostAddress;const aTime:TRNLTime;const aAddIfNotExist:boolean):PRNLConnectionKnownCandidateHostAddress;
     end;

     PRNLConnectionCandidateState=^TRNLConnectionCandidateState;
     TRNLConnectionCandidateState=
      (
       RNL_CONNECTION_STATE_INVALID=0,
       RNL_CONNECTION_STATE_REQUESTING,
       RNL_CONNECTION_STATE_CHALLENGING,
       RNL_CONNECTION_STATE_AUTHENTICATING,
       RNL_CONNECTION_STATE_APPROVING
      );

     PRNLConnectionCandidateData=^TRNLConnectionCandidateData;
     TRNLConnectionCandidateData=record
      private
       fHost:TRNLHost;
       fPeer:TRNLPeer;
       fLocalShortTermPrivateKey:TRNLKey;
       fLocalShortTermPublicKey:TRNLKey;
       fRemoteShortTermPublicKey:TRNLKey;
       fSharedSecretKey:TRNLKey;
       fOutgoingPeerID:TRNLUInt16;
       fIncomingBandwidthLimit:TRNLUInt32;
       fOutgoingBandwidthLimit:TRNLUInt32;
       fRemoteCountChannels:TRNLUInt32;
       fData:TRNLUInt64;
       fNonce:TRNLUInt64;
       fMTU:TRNLUInt16;
       fCountChallengeRepetitions:TRNLUInt16;
       fNextChallengeTimeout:TRNLTime;
       fNextShortTermKeyPairTimeout:TRNLTime;
       fNextNonceTimeout:TRNLTime;
       fChallenge:TRNLConnectionChallenge;
       fSolvedChallenge:TRNLConnectionChallenge;
       fConnectionToken:TRNLConnectionToken;
       fAuthenticationToken:TRNLAuthenticationToken;
      public
     end;

     PRNLConnectionCandidate=^TRNLConnectionCandidate;
     TRNLConnectionCandidate=record
      private
       fState:TRNLConnectionCandidateState;
       fRemoteSalt:TRNLUInt64;
       fLocalSalt:TRNLUInt64;
       fCreateTime:TRNLTime;
       fAddress:TRNLAddress;
       fData:PRNLConnectionCandidateData;
       function GetConnectionToken:TRNLConnectionToken;
       function GetAuthenticationToken:TRNLAuthenticationToken;
      public
       procedure AcceptConnectionToken;
       procedure RejectConnectionToken;
       function AcceptAuthenticationToken:TRNLPeer;
       procedure RejectAuthenticationToken;
       property Address:TRNLAddress read fAddress;
       property ConnectionToken:TRNLConnectionToken read GetConnectionToken;
       property AuthenticationToken:TRNLAuthenticationToken read GetAuthenticationToken;
     end;

     PRNLConnectionCandidateHashTable=^TRNLConnectionCandidateHashTable;
     TRNLConnectionCandidateHashTable=record
      public
       const HashBits=12;
             HashSize=1 shl HashBits;
             HashMask=HashSize-1;
       type PRNLConnectionCandidateHashTableEntries=^TRNLConnectionCandidateHashTableEntries;
            TRNLConnectionCandidateHashTableEntries=array[0..HashSize-1] of TRNLConnectionCandidate;
      private
       fEntries:TRNLConnectionCandidateHashTableEntries;
      public
       procedure Clear;
       procedure Free;
       function Find(const aRandomGenerator:TRNLRandomGenerator;const aAddress:TRNLAddress;const aRemoteSalt,aLocalSalt:TRNLUInt64;const aTime,aTimeout:TRNLTime;const aAddIfNotExist:boolean):PRNLConnectionCandidate;
     end;

     PRNLConnectionDenialReason=^TRNLConnectionDenialReason;
     TRNLConnectionDenialReason=
      (
       RNL_CONNECTION_DENIAL_REASON_UNKNOWN=0,
       RNL_CONNECTION_DENIAL_REASON_FULL=1,
       RNL_CONNECTION_DENIAL_REASON_TOO_LESS_CHANNELS=2,
       RNL_CONNECTION_DENIAL_REASON_TOO_MANY_CHANNELS=3,
       RNL_CONNECTION_DENIAL_REASON_WRONG_CHANNEL_TYPES=4,
       RNL_CONNECTION_DENIAL_REASON_UNAUTHORIZED=5
      );

     PRNLProtocolHandshakePacketHeaderSignature=^TRNLProtocolHandshakePacketHeaderSignature;
     TRNLProtocolHandshakePacketHeaderSignature=array[0..3] of TRNLUInt8;

     PRNLProtocolHandshakePacketType=^TRNLProtocolHandshakePacketType;
     TRNLProtocolHandshakePacketType=
      (
       RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_NONE=-1,
       RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_REQUEST=0,
       RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_CHALLENGE_REQUEST=1,
       RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_CHALLENGE_RESPONSE=2,
       RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_AUTHENTICATION_REQUEST=3,
       RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_AUTHENTICATION_RESPONSE=4,
       RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_APPROVAL_RESPONSE=5,
       RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_DENIAL_RESPONSE=6,
       RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_APPROVAL_ACKNOWLEDGE=7,
       RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_DENIAL_ACKNOWLEDGE=8
      );

     PRNLProtocolHandshakePacketHeader=^TRNLProtocolHandshakePacketHeader;
     TRNLProtocolHandshakePacketHeader=packed record
      Signature:TRNLProtocolHandshakePacketHeaderSignature;
      ProtocolVersion:TRNLUInt64;
      ProtocolID:TRNLUInt64;
      Checksum:TRNLUInt32;
      PacketType:TRNLUInt8;
     end;

     // DDoS minification
     // Make DDoS-amplification-attacks unattractive for anyone thinking of launching
     // this kind of attack, when the outgoing response packet is bigger or equal-
     // sized like the incoming request packet
     PRNLProtocolHandshakePacketAntiDDoSAmplificationPadding=^TRNLProtocolHandshakePacketAntiDDoSAmplificationPadding;
     TRNLProtocolHandshakePacketAntiDDoSAmplificationPadding=packed record
      // should big enough but also including the IP+UDP headers additionally top on it
      // smaller than the minimum MTU of 576 bytes at the same time
      Padding:array[1..RNL_MINIMUM_MTU-(RNL_IPV4_HEADER_SIZE+RNL_UDP_HEADER_SIZE)] of TRNLUInt8;
     end;

     PRNLProtocolHandshakePacketConnectionRequest=^TRNLProtocolHandshakePacketConnectionRequest;
     TRNLProtocolHandshakePacketConnectionRequest=packed record
      case boolean of
       false:(
        Header:TRNLProtocolHandshakePacketHeader;
        PeerID:TRNLUInt16;
        OutgoingSalt:TRNLUInt64;
        IncomingBandwidthLimit:TRNLUInt32;
        OutgoingBandwidthLimit:TRNLUInt32;
        ConnectionToken:TRNLConnectionToken;
       );
       true:(
        AntiDDoSAmplificationPadding:TRNLProtocolHandshakePacketAntiDDoSAmplificationPadding;
       );
     end;

     PRNLProtocolHandshakePacketConnectionChallengeRequest=^TRNLProtocolHandshakePacketConnectionChallengeRequest;
     TRNLProtocolHandshakePacketConnectionChallengeRequest=packed record
      case boolean of
       false:(
        Header:TRNLProtocolHandshakePacketHeader;
        PeerID:TRNLUInt16;
        IncomingSalt:TRNLUInt64;
        OutgoingSalt:TRNLUInt64;
        IncomingBandwidthLimit:TRNLUInt32;
        OutgoingBandwidthLimit:TRNLUInt32;
        CountChallengeRepetitions:TRNLUInt16;
        Challenge:TRNLConnectionChallenge;
       );
       true:(
        AntiDDoSAmplificationPadding:TRNLProtocolHandshakePacketAntiDDoSAmplificationPadding;
       );
     end;

     PRNLProtocolHandshakePacketConnectionChallengeResponse=^TRNLProtocolHandshakePacketConnectionChallengeResponse;
     TRNLProtocolHandshakePacketConnectionChallengeResponse=packed record
      case boolean of
       false:(
        Header:TRNLProtocolHandshakePacketHeader;
        ConnectionSalt:TRNLUInt64;
        ShortTermPublicKey:TRNLKey;
        ChallengeResponse:TRNLConnectionChallenge;
       );
       true:(
        AntiDDoSAmplificationPadding:TRNLProtocolHandshakePacketAntiDDoSAmplificationPadding;
       );
     end;

     PTRNLProtocolHandshakePacketConnectionAuthenticationRequestPayload=^TTRNLProtocolHandshakePacketConnectionAuthenticationRequestPayload;
     TTRNLProtocolHandshakePacketConnectionAuthenticationRequestPayload=packed record
      LongTermPublicKey:TRNLKey;
      Signature:TRNLED25519Signature;
      MTU:TRNLUInt16;
     end;

     PRNLProtocolHandshakePacketConnectionAuthenticationRequest=^TRNLProtocolHandshakePacketConnectionAuthenticationRequest;
     TRNLProtocolHandshakePacketConnectionAuthenticationRequest=packed record
      case boolean of
       false:(
        Header:TRNLProtocolHandshakePacketHeader;
        PeerID:TRNLUInt16;
        ConnectionSalt:TRNLUInt64;
        ShortTermPublicKey:TRNLKey;
        Nonce:TRNLUInt64;
        PayloadMAC:TRNLCipherMAC;
        Payload:TTRNLProtocolHandshakePacketConnectionAuthenticationRequestPayload;
       );
       true:(
        AntiDDoSAmplificationPadding:TRNLProtocolHandshakePacketAntiDDoSAmplificationPadding;
       );
     end;

     PRNLProtocolHandshakePacketPeerChannelTypes=^TRNLProtocolHandshakePacketPeerChannelTypes;
     TRNLProtocolHandshakePacketPeerChannelTypes=array[0..RNL_MAXIMUM_PEER_CHANNELS-1] of TRNLUInt8;

     PRNLProtocolHandshakePacketConnectionAuthenticationResponsePayload=^TRNLProtocolHandshakePacketConnectionAuthenticationResponsePayload;
     TRNLProtocolHandshakePacketConnectionAuthenticationResponsePayload=packed record
      LongTermPublicKey:TRNLKey;
      Signature:TRNLED25519Signature;
      AuthenticationToken:TRNLAuthenticationToken;
      MTU:TRNLUInt16;
      CountChannels:TRNLUInt16;
      ChannelTypes:TRNLProtocolHandshakePacketPeerChannelTypes;
      Data:TRNLUInt64;
     end;

     PRNLProtocolHandshakePacketConnectionAuthenticationResponse=^TRNLProtocolHandshakePacketConnectionAuthenticationResponse;
     TRNLProtocolHandshakePacketConnectionAuthenticationResponse=packed record
      case boolean of
       false:(
        Header:TRNLProtocolHandshakePacketHeader;
        ConnectionSalt:TRNLUInt64;
        Nonce:TRNLUInt64;
        PayloadMAC:TRNLCipherMAC;
        Payload:TRNLProtocolHandshakePacketConnectionAuthenticationResponsePayload;
       );
       true:(
        AntiDDoSAmplificationPadding:TRNLProtocolHandshakePacketAntiDDoSAmplificationPadding;
       );
     end;

     PRNLProtocolHandshakePacketConnectionApprovalResponsePayload=^TRNLProtocolHandshakePacketConnectionApprovalResponsePayload;
     TRNLProtocolHandshakePacketConnectionApprovalResponsePayload=packed record
      PeerID:TRNLUInt16;
     end;

     PRNLProtocolHandshakePacketConnectionApprovalResponse=^TRNLProtocolHandshakePacketConnectionApprovalResponse;
     TRNLProtocolHandshakePacketConnectionApprovalResponse=packed record
      case boolean of
       false:(
        Header:TRNLProtocolHandshakePacketHeader;
        PeerID:TRNLUInt16;
        ConnectionSalt:TRNLUInt64;
        Nonce:TRNLUInt64;
        PayloadMAC:TRNLCipherMAC;
        Payload:TRNLProtocolHandshakePacketConnectionApprovalResponsePayload;
       );
       true:(
        AntiDDoSAmplificationPadding:TRNLProtocolHandshakePacketAntiDDoSAmplificationPadding;
       );
     end;

     PRNLProtocolHandshakePacketConnectionDenialResponsePayload=^TRNLProtocolHandshakePacketConnectionDenialResponsePayload;
     TRNLProtocolHandshakePacketConnectionDenialResponsePayload=packed record
      Reason:TRNLUInt8;
     end;

     PRNLProtocolHandshakePacketConnectionDenialResponse=^TRNLProtocolHandshakePacketConnectionDenialResponse;
     TRNLProtocolHandshakePacketConnectionDenialResponse=packed record
      case boolean of
       false:(
        Header:TRNLProtocolHandshakePacketHeader;
        PeerID:TRNLUInt16;
        ConnectionSalt:TRNLUInt64;
        Nonce:TRNLUInt64;
        PayloadMAC:TRNLCipherMAC;
        Payload:TRNLProtocolHandshakePacketConnectionDenialResponsePayload;
       );
       true:(
        AntiDDoSAmplificationPadding:TRNLProtocolHandshakePacketAntiDDoSAmplificationPadding;
       );
     end;

     PRNLProtocolHandshakePacketConnectionApprovalAcknowledge=^TRNLProtocolHandshakePacketConnectionApprovalAcknowledge;
     TRNLProtocolHandshakePacketConnectionApprovalAcknowledge=packed record
      case boolean of
       false:(
        Header:TRNLProtocolHandshakePacketHeader;
        PeerID:TRNLUInt16;
        ConnectionSalt:TRNLUInt64;
        Nonce:TRNLUInt64;
        WholePacketMAC:TRNLCipherMAC;
       );
       true:(
        AntiDDoSAmplificationPadding:TRNLProtocolHandshakePacketAntiDDoSAmplificationPadding;
       );
     end;

     PRNLProtocolHandshakePacketConnectionDenialAcknowledgePayload=^TRNLProtocolHandshakePacketConnectionDenialAcknowledgePayload;
     TRNLProtocolHandshakePacketConnectionDenialAcknowledgePayload=packed record
      Data:TRNLUInt64;
     end;

     PRNLProtocolHandshakePacketConnectionDenialAcknowledge=^TRNLProtocolHandshakePacketConnectionDenialAcknowledge;
     TRNLProtocolHandshakePacketConnectionDenialAcknowledge=packed record
      case boolean of
       false:(
        Header:TRNLProtocolHandshakePacketHeader;
        PeerID:TRNLUInt16;
        ConnectionSalt:TRNLUInt64;
        Nonce:TRNLUInt64;
        PayloadMAC:TRNLCipherMAC;
        Payload:TRNLProtocolHandshakePacketConnectionDenialAcknowledgePayload;
       );
       true:(
        AntiDDoSAmplificationPadding:TRNLProtocolHandshakePacketAntiDDoSAmplificationPadding;
       );
     end;

     PRNLProtocolHandshakePacket=^TRNLProtocolHandshakePacket;
     TRNLProtocolHandshakePacket=packed record
      case TRNLProtocolHandshakePacketType of
       RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_NONE:(
        Header:TRNLProtocolHandshakePacketHeader;
       );
       RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_REQUEST:(
        ConnectionRequest:TRNLProtocolHandshakePacketConnectionRequest;
       );
       RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_CHALLENGE_REQUEST:(
        ConnectionChallengeRequest:TRNLProtocolHandshakePacketConnectionChallengeRequest;
       );
       RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_CHALLENGE_RESPONSE:(
        ConnectionChallengeResponse:TRNLProtocolHandshakePacketConnectionChallengeResponse;
       );
       RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_AUTHENTICATION_REQUEST:(
        ConnectionAuthenticationRequest:TRNLProtocolHandshakePacketConnectionAuthenticationRequest;
       );
       RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_AUTHENTICATION_RESPONSE:(
        ConnectionAuthenticationResponse:TRNLProtocolHandshakePacketConnectionAuthenticationResponse;
       );
       RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_APPROVAL_RESPONSE:(
        ConnectionApprovalResponse:TRNLProtocolHandshakePacketConnectionApprovalResponse;
       );
       RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_DENIAL_RESPONSE:(
        ConnectionDenialResponse:TRNLProtocolHandshakePacketConnectionDenialResponse;
       );
       RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_APPROVAL_ACKNOWLEDGE:(
        ConnectionApprovalAcknowledge:TRNLProtocolHandshakePacketConnectionApprovalAcknowledge;
       );
       RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_DENIAL_ACKNOWLEDGE:(
        ConnectionDenialAcknowledge:TRNLProtocolHandshakePacketConnectionDenialAcknowledge;
       );
     end;

     PRNLProtocolNormalPacketHeader=^TRNLProtocolNormalPacketHeader;
     TRNLProtocolNormalPacketHeader=packed record
      PeerID:TRNLUInt16;
      Flags:TRNLUInt8;
      Not255:TRNLUInt8; // <= Must be never 255, otherwise we've a conflict with RNLProtocolHandshakePacketHeaderSignature at this packet data position
      SentTime:TRNLUInt16;
      EncryptedPacketSequenceNumber:TRNLUInt64;
      PayloadMAC:TRNLCipherMAC;
      // No extra checksum, because the Authenticated Encryption with Associated Data (AEAD) stuff
      // does also this task as a positive side-effect
     end;

     PRNLProtocolBlockPacketType=^TRNLProtocolBlockPacketType;
     TRNLProtocolBlockPacketType=
      (
       RNL_PROTOCOL_BLOCK_PACKET_TYPE_NONE=0,
       RNL_PROTOCOL_BLOCK_PACKET_TYPE_PING=1,
       RNL_PROTOCOL_BLOCK_PACKET_TYPE_PONG=2,
       RNL_PROTOCOL_BLOCK_PACKET_TYPE_DISCONNECT=3,
       RNL_PROTOCOL_BLOCK_PACKET_TYPE_DISCONNECT_ACKNOWLEGDEMENT=4,
       RNL_PROTOCOL_BLOCK_PACKET_TYPE_BANDWIDTH_LIMITS=5,
       RNL_PROTOCOL_BLOCK_PACKET_TYPE_BANDWIDTH_LIMITS_ACKNOWLEGDEMENT=6,
       RNL_PROTOCOL_BLOCK_PACKET_TYPE_MTU_PROBE=7,
       RNL_PROTOCOL_BLOCK_PACKET_TYPE_CHANNEL=8
      );

     PRNLProtocolBlockPacketHeader=^TRNLProtocolBlockPacketHeader;
     TRNLProtocolBlockPacketHeader=packed record // 1 byte
      TypeAndSubtype:TRNLUInt8;
     end;

     PRNLProtocolBlockPacketPing=^TRNLProtocolBlockPacketPing;
     TRNLProtocolBlockPacketPing=packed record // 2 bytes
      Header:TRNLProtocolBlockPacketHeader;
      SequenceNumber:TRNLUInt8;
     end;

     PRNLProtocolBlockPacketPong=^TRNLProtocolBlockPacketPong;
     TRNLProtocolBlockPacketPong=packed record // 4 bytes
      Header:TRNLProtocolBlockPacketHeader;
      SequenceNumber:TRNLUInt8;
      SentTime:TRNLUInt16;
     end;

     PRNLProtocolBlockPacketDisconnect=^TRNLProtocolBlockPacketDisconnect;
     TRNLProtocolBlockPacketDisconnect=packed record // 9 bytes
      Header:TRNLProtocolBlockPacketHeader;
      Data:TRNLUInt64;
     end;

     PRNLProtocolBlockPacketDisconnectAcknowledgement=^TRNLProtocolBlockPacketDisconnectAcknowledgement;
     TRNLProtocolBlockPacketDisconnectAcknowledgement=packed record // 2 bytes
      Header:TRNLProtocolBlockPacketHeader;
      SequenceNumber:TRNLUInt8;
     end;

     PRNLProtocolBlockPacketBandwidthLimits=^TRNLProtocolBlockPacketBandwidthLimits;
     TRNLProtocolBlockPacketBandwidthLimits=packed record // 10 bytes
      Header:TRNLProtocolBlockPacketHeader;
      SequenceNumber:TRNLUInt8;
      IncomingBandwidthLimit:TRNLUInt32;
      OutgoingBandwidthLimit:TRNLUInt32;
     end;

     PRNLProtocolBlockPacketBandwidthLimitsAcknowledgement=^TRNLProtocolBlockPacketBandwidthLimitsAcknowledgement;
     TRNLProtocolBlockPacketBandwidthLimitsAcknowledgement=packed record // 2 bytes
      Header:TRNLProtocolBlockPacketHeader;
      SequenceNumber:TRNLUInt8;
     end;

     PRNLProtocolBlockPacketMTUProbe=^TRNLProtocolBlockPacketMTUProbe;
     TRNLProtocolBlockPacketMTUProbe=packed record // 8 bytes + size of dummy payload
      Header:TRNLProtocolBlockPacketHeader;
      SequenceNumber:TRNLUInt16;
      Phase:TRNLUInt8;
      Size:TRNLUInt16;
      PayloadDataLength:TRNLUInt16;
     end;

     PRNLProtocolBlockPacketChannel=^TRNLProtocolBlockPacketChannel;
     TRNLProtocolBlockPacketChannel=packed record // 4 bytes + size of channel-protocol-dependent payload
      Header:TRNLProtocolBlockPacketHeader;
      ChannelNumber:TRNLUInt8;
      PayloadDataLength:TRNLUInt16;
     end;

     PRNLProtocolBlockPacket=^TRNLProtocolBlockPacket;
     TRNLProtocolBlockPacket=packed record
      case TRNLProtocolBlockPacketType of
       RNL_PROTOCOL_BLOCK_PACKET_TYPE_NONE:(
        Header:TRNLProtocolBlockPacketHeader;
       );
       RNL_PROTOCOL_BLOCK_PACKET_TYPE_PING:(
        Ping:TRNLProtocolBlockPacketPing;
       );
       RNL_PROTOCOL_BLOCK_PACKET_TYPE_PONG:(
        Pong:TRNLProtocolBlockPacketPong;
       );
       RNL_PROTOCOL_BLOCK_PACKET_TYPE_DISCONNECT:(
        Disconnect:TRNLProtocolBlockPacketDisconnect;
       );
       RNL_PROTOCOL_BLOCK_PACKET_TYPE_DISCONNECT_ACKNOWLEGDEMENT:(
        DisconnectAcknowledgement:TRNLProtocolBlockPacketDisconnectAcknowledgement;
       );
       RNL_PROTOCOL_BLOCK_PACKET_TYPE_BANDWIDTH_LIMITS:(
        BandwidthLimits:TRNLProtocolBlockPacketBandwidthLimits;
       );
       RNL_PROTOCOL_BLOCK_PACKET_TYPE_BANDWIDTH_LIMITS_ACKNOWLEGDEMENT:(
        BandwidthLimitsAcknowledgement:TRNLProtocolBlockPacketBandwidthLimitsAcknowledgement;
       );
       RNL_PROTOCOL_BLOCK_PACKET_TYPE_MTU_PROBE:(
        MTUProbe:TRNLProtocolBlockPacketMTUProbe;
       );
       RNL_PROTOCOL_BLOCK_PACKET_TYPE_CHANNEL:(
        Channel:TRNLProtocolBlockPacketChannel;
       );
     end;

     TRNLInstance=class;

     TRNLRawByteDataArray=array of TRNLUInt8;

     PRNLMessageFlag=^TRNLMessageFlag;
     TRNLMessageFlag=
      (
       RNL_MESSAGE_FLAG_NO_ALLOCATE,
       RNL_MESSAGE_FLAG_NO_FREE,
       RNL_MESSAGE_FLAG_UNRELIABLE_ORDERED_CHANNEL_PREVIOUS_LOST
      );

     PRNLMessageFlags=^TRNLMessageFlags;
     TRNLMessageFlags=set of TRNLMessageFlag;

     TRNLMessage=class;

     TRNLMessageOnFree=procedure(const aMessage:TRNLMessage) of object;

     TRNLMessage=class
      private
       fReferenceCounter:TRNLUInt32;
       fFlags:TRNLMessageFlags;
       fStream:TStream;
       fData:TRNLPointer;
       fDataLength:TRNLUInt32;
       fOnFree:TRNLMessageOnFree;
       fUserData:TRNLPointer;
       procedure Initialize;
       function GetDataAsBytes:TBytes;
       function GetDataAsRawByteString:TRNLRawByteString;
       function GetDataAsUTF8String:TRNLUTF8String;
       function GetDataAsUTF16String:TRNLUTF16String;
       function GetDataAsString:TRNLString;
      public
       constructor CreateFromMemory(const aData:TRNLPointer;const aDataLength:TRNLUInt32;const aFlags:TRNLMessageFlags=[]); reintroduce; overload;
       constructor CreateFromBytes(const aData:TBytes;const aFlags:TRNLMessageFlags=[]); reintroduce; overload;
       constructor CreateFromBytes(const aData:array of TRNLUInt8;const aFlags:TRNLMessageFlags=[]); reintroduce; overload;
       constructor CreateFromRawByteString(const aData:TRNLRawByteString;const aFlags:TRNLMessageFlags=[]); reintroduce; overload;
       constructor CreateFromUTF8String(const aData:TRNLUTF8String;const aFlags:TRNLMessageFlags=[]); reintroduce; overload;
       constructor CreateFromUTF16String(const aData:TRNLUTF16String;const aFlags:TRNLMessageFlags=[]); reintroduce; overload;
       constructor CreateFromString(const aData:TRNLString;const aFlags:TRNLMessageFlags=[]); reintroduce; overload;
       constructor CreateFromStream(const aStream:TStream;const aFlags:TRNLMessageFlags=[]); reintroduce; overload;
       destructor Destroy; override;
       procedure IncRef;
       procedure DecRef;
       procedure Resize(const aDataLength:TRNLUInt32);
       property Data:TRNLPointer read fData write fData;
       property UserData:TRNLPointer read fUserData write fUserData;
       property AsBytes:TBytes read GetDataAsBytes;
      published
       property ReferenceCounter:TRNLUInt32 read fReferenceCounter write fReferenceCounter;
       property Flags:TRNLMessageFlags read fFlags write fFlags;
       property DataLength:TRNLUInt32 read fDataLength write fDataLength;
       property OnFree:TRNLMessageOnFree read fOnFree write fOnFree;
       property AsRawByteString:TRNLRawByteString read GetDataAsRawByteString;
       property AsUTF8String:TRNLUTF8String read GetDataAsUTF8String;
       property AsUTF16String:TRNLUTF16String read GetDataAsUTF16String;
       property AsString:TRNLString read GetDataAsString;
     end;

     TRNLMessageQueue=TRNLQueue<TRNLMessage>;

     TRNLCompressor=class
      public
       constructor Create; reintroduce; virtual;
      destructor Destroy; override;
       function Compress(const aInData:TRNLPointer;const aInSize:TRNLSizeUInt;const aOutData:TRNLPointer;const aOutLimit:TRNLSizeUInt):TRNLSizeUInt; virtual;
       function Decompress(const aInData:TRNLPointer;const aInSize:TRNLSizeUInt;const aOutData:TRNLPointer;const aOutLimit:TRNLSizeUInt):TRNLSizeUInt; virtual;
     end;

     TRNLCompressorClass=class of TRNLCompressor;

     TRNLCompressorDeflate=class(TRNLCompressor)
      protected
       const HashBits=16;
             HashSize=1 shl HashBits;
             HashMask=HashSize-1;
             HashShift=32-HashBits;
             WindowSize=32768;
             WindowMask=WindowSize-1;
             MinMatch=3;
             MaxMatch=258;
             MaxOffset=32768;
       const LengthCodes:array[0..28,0..3] of TRNLUInt32=
              ( // Code, ExtraBits, Min, Max
               (257,0,3,3),
               (258,0,4,4),
               (259,0,5,5),
               (260,0,6,6),
               (261,0,7,7),
               (262,0,8,8),
               (263,0,9,9),
               (264,0,10,10),
               (265,1,11,12),
               (266,1,13,14),
               (267,1,15,16),
               (268,1,17,18),
               (269,2,19,22),
               (270,2,23,26),
               (271,2,27,30),
               (272,2,31,34),
               (273,3,35,42),
               (274,3,43,50),
               (275,3,51,58),
               (276,3,59,66),
               (277,4,67,82),
               (278,4,83,98),
               (279,4,99,114),
               (280,4,115,130),
               (281,5,131,162),
               (282,5,163,194),
               (283,5,195,226),
               (284,5,227,257),
               (285,0,258,258)
              );
             DistanceCodes:array[0..29,0..3] of TRNLUInt32=
              ( // Code, ExtraBits, Min, Max
               (0,0,1,1),
               (1,0,2,2),
               (2,0,3,3),
               (3,0,4,4),
               (4,1,5,6),
               (5,1,7,8),
               (6,2,9,12),
               (7,2,13,16),
               (8,3,17,24),
               (9,3,25,32),
               (10,4,33,48),
               (11,4,49,64),
               (12,5,65,96),
               (13,5,97,128),
               (14,6,129,192),
               (15,6,193,256),
               (16,7,257,384),
               (17,7,385,512),
               (18,8,513,768),
               (19,8,769,1024),
               (20,9,1025,1536),
               (21,9,1537,2048),
               (22,10,2049,3072),
               (23,10,3073,4096),
               (24,11,4097,6144),
               (25,11,6145,8192),
               (26,12,8193,12288),
               (27,12,12289,16384),
               (28,13,16385,24576),
               (29,13,24577,32768)
              );
             MirrorBytes:array[TRNLUInt8] of TRNLUInt8=
              (
               $00,$80,$40,$c0,$20,$a0,$60,$e0,
               $10,$90,$50,$d0,$30,$b0,$70,$f0,
               $08,$88,$48,$c8,$28,$a8,$68,$e8,
               $18,$98,$58,$d8,$38,$b8,$78,$f8,
               $04,$84,$44,$c4,$24,$a4,$64,$e4,
               $14,$94,$54,$d4,$34,$b4,$74,$f4,
               $0c,$8c,$4c,$cc,$2c,$ac,$6c,$ec,
               $1c,$9c,$5c,$dc,$3c,$bc,$7c,$fc,
               $02,$82,$42,$c2,$22,$a2,$62,$e2,
               $12,$92,$52,$d2,$32,$b2,$72,$f2,
               $0a,$8a,$4a,$ca,$2a,$aa,$6a,$ea,
               $1a,$9a,$5a,$da,$3a,$ba,$7a,$fa,
               $06,$86,$46,$c6,$26,$a6,$66,$e6,
               $16,$96,$56,$d6,$36,$b6,$76,$f6,
               $0e,$8e,$4e,$ce,$2e,$ae,$6e,$ee,
               $1e,$9e,$5e,$de,$3e,$be,$7e,$fe,
               $01,$81,$41,$c1,$21,$a1,$61,$e1,
               $11,$91,$51,$d1,$31,$b1,$71,$f1,
               $09,$89,$49,$c9,$29,$a9,$69,$e9,
               $19,$99,$59,$d9,$39,$b9,$79,$f9,
               $05,$85,$45,$c5,$25,$a5,$65,$e5,
               $15,$95,$55,$d5,$35,$b5,$75,$f5,
               $0d,$8d,$4d,$cd,$2d,$ad,$6d,$ed,
               $1d,$9d,$5d,$dd,$3d,$bd,$7d,$fd,
               $03,$83,$43,$c3,$23,$a3,$63,$e3,
               $13,$93,$53,$d3,$33,$b3,$73,$f3,
               $0b,$8b,$4b,$cb,$2b,$ab,$6b,$eb,
               $1b,$9b,$5b,$db,$3b,$bb,$7b,$fb,
               $07,$87,$47,$c7,$27,$a7,$67,$e7,
               $17,$97,$57,$d7,$37,$b7,$77,$f7,
               $0f,$8f,$4f,$cf,$2f,$af,$6f,$ef,
               $1f,$9f,$5f,$df,$3f,$bf,$7f,$ff
              );
             CLCIndex:array[0..18] of TRNLUInt8=(16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15);
       type PHashTable=^THashTable;
            THashTable=array[0..HashSize-1] of PRNLUInt8;
            PChainTable=^TChainTable;
            TChainTable=array[0..WindowSize-1] of TRNLPointer;
            PTree=^TTree;
            TTree=packed record
             Table:array[0..15] of TRNLUInt16;
             Translation:array[0..287] of TRNLUInt16;
            end;
            PBuffer=^TBuffer;
            TBuffer=array[0..65535] of TRNLUInt8;
            PLengths=^TLengths;
            TLengths=array[0..288+32-1] of TRNLUInt8;
            POffsets=^TOffsets;
            TOffsets=array[0..15] of TRNLUInt16;
            TBits=array[0..29] of TRNLUInt8;
            PBits=^TBits;
            TBase=array[0..29] of TRNLUInt16;
            PBase=^TBase;
      private
       fHashTable:THashTable;
       fChainTable:TChainTable;
       fLengthCodesLookUpTable:array[0..258] of TRNLInt32;
       fDistanceCodesLookUpTable:array[0..32768] of TRNLInt32;
       fSymbolLengthTree:TTree;
       fDistanceTree:TTree;
       fFixedSymbolLengthTree:TTree;
       fFixedDistanceTree:TTree;
       fLengthBits:TBits;
       fDistanceBits:TBits;
       fLengthBase:TBase;
       fDistanceBase:TBase;
       fCodeTree:TTree;
       fLengths:TLengths;
       fWithHeader:boolean;
       fGreedy:boolean;
       fSkipStrength:TRNLUInt32;
       fMaxSteps:TRNLUInt32;
      public
       constructor Create; override;
       destructor Destroy; override;
       function Compress(const aInData:TRNLPointer;const aInSize:TRNLSizeUInt;const aOutData:TRNLPointer;const aOutLimit:TRNLSizeUInt):TRNLSizeUInt; override;
       function Decompress(const aInData:TRNLPointer;const aInSize:TRNLSizeUInt;const aOutData:TRNLPointer;const aOutLimit:TRNLSizeUInt):TRNLSizeUInt; override;
      published
       property WithHeader:boolean read fWithHeader write fWithHeader;
       property Greedy:boolean read fGreedy write fGreedy;
       property SkipStrength:TRNLUInt32 read fSkipStrength write fSkipStrength;
       property MaxSteps:TRNLUInt32 read fMaxSteps write fMaxSteps;
     end;

     TRNLCompressorLZBRRC=class(TRNLCompressor)
      protected
       const FlagModel=0;
             PreviousMatchModel=2;
             MatchLowModel=3;
             LiteralModel=35;
             Gamma0Model=291;
             Gamma1Model=547;
             SizeModels=803;
             HashBits=12;
             HashSize=1 shl HashBits;
             HashMask=HashSize-1;
             HashShift=32-HashBits;
             WindowSize=32768;
             WindowMask=WindowSize-1;
             MinMatch=2;
             MaxMatch=$20000000;
             MaxOffset=$40000000;
       type PHashTable=^THashTable;
            THashTable=array[0..HashSize-1] of PRNLUInt8;
            PChainTable=^TChainTable;
            TChainTable=array[0..WindowSize-1] of TRNLPointer;
      private
       fHashTable:THashTable;
       fChainTable:TChainTable;
       fGreedy:boolean;
       fSkipStrength:TRNLUInt32;
       fMaxSteps:TRNLUInt32;
      public
       constructor Create; override;
       destructor Destroy; override;
       function Compress(const aInData:TRNLPointer;const aInSize:TRNLSizeUInt;const aOutData:TRNLPointer;const aOutLimit:TRNLSizeUInt):TRNLSizeUInt; override;
       function Decompress(const aInData:TRNLPointer;const aInSize:TRNLSizeUInt;const aOutData:TRNLPointer;const aOutLimit:TRNLSizeUInt):TRNLSizeUInt; override;
      published
       property Greedy:boolean read fGreedy write fGreedy;
       property SkipStrength:TRNLUInt32 read fSkipStrength write fSkipStrength;
       property MaxSteps:TRNLUInt32 read fMaxSteps write fMaxSteps;
     end;

     TRNLCompressorBRRC=class(TRNLCompressor)
      private
       const FlagModel=0;
             LiteralModel=1;
             SizeModels=257;
      private
      public
       constructor Create; override;
       destructor Destroy; override;
       function Compress(const aInData:TRNLPointer;const aInSize:TRNLSizeUInt;const aOutData:TRNLPointer;const aOutLimit:TRNLSizeUInt):TRNLSizeUInt; override;
       function Decompress(const aInData:TRNLPointer;const aInSize:TRNLSizeUInt;const aOutData:TRNLPointer;const aOutLimit:TRNLSizeUInt):TRNLSizeUInt; override;
      published
     end;

     PRNLHostEventType=^TRNLHostEventType;
     TRNLHostEventType=
      (
       RNL_HOST_EVENT_TYPE_NONE,
       RNL_HOST_EVENT_TYPE_PEER_CHECK_CONNECTION_TOKEN,
       RNL_HOST_EVENT_TYPE_PEER_CHECK_AUTHENTICATION_TOKEN,
       RNL_HOST_EVENT_TYPE_PEER_CONNECT,
       RNL_HOST_EVENT_TYPE_PEER_DISCONNECT,
       RNL_HOST_EVENT_TYPE_PEER_APPROVAL,
       RNL_HOST_EVENT_TYPE_PEER_DENIAL,
       RNL_HOST_EVENT_TYPE_PEER_BANDWIDTH_LIMITS,
       RNL_HOST_EVENT_TYPE_PEER_MTU,
       RNL_HOST_EVENT_TYPE_PEER_RECEIVE
      );

     PRNLHostEvent=^TRNLHostEvent;
     TRNLHostEvent=record
      public
       procedure Initialize;
       procedure Finalize;
       procedure Free;
      public
       Type_:TRNLHostEventType;
       Peer:TRNLPeer;
       Message:TRNLMessage;
       case TRNLHostEventType of
        RNL_HOST_EVENT_TYPE_PEER_CHECK_CONNECTION_TOKEN,
        RNL_HOST_EVENT_TYPE_PEER_CHECK_AUTHENTICATION_TOKEN:(
         ConnectionCandidate:PRNLConnectionCandidate;
        );
        RNL_HOST_EVENT_TYPE_PEER_CONNECT,
        RNL_HOST_EVENT_TYPE_PEER_DISCONNECT:(
         Data:TRNLUInt64;
        );
        RNL_HOST_EVENT_TYPE_PEER_APPROVAL:(
        );
        RNL_HOST_EVENT_TYPE_PEER_DENIAL:(
         DenialReason:TRNLConnectionDenialReason;
        );
        RNL_HOST_EVENT_TYPE_PEER_MTU:(
         MTU:TRNLUInt16;
        );
        RNL_HOST_EVENT_TYPE_PEER_RECEIVE:(
         Channel:TRNLUInt8;
        );
     end;

     TRNLHostEventQueue=TRNLQueue<TRNLHostEvent>;

     PRNLHostServiceStatus=^TRNLHostServiceStatus;
     TRNLHostServiceStatus=
      (
       RNL_HOST_SERVICE_STATUS_ERROR,
       RNL_HOST_SERVICE_STATUS_TIMEOUT,
       RNL_HOST_SERVICE_STATUS_INTERRUPT,
       RNL_HOST_SERVICE_STATUS_EVENT
      );

     TRNLHostSockets=array[0..1] of TRNLSocket;

     TRNLHostSocketFamilies=array[0..1] of TRNLAddressFamily;

     TRNLHostOnPeerCheckConnectionToken=function(const aHost:TRNLHost;const aAddress:TRNLAddress;const aConnectionToken:TRNLConnectionToken):boolean of object;

     TRNLHostOnPeerCheckAuthenticationToken=function(const aHost:TRNLHost;const aAddress:TRNLAddress;const aAuthenticationToken:TRNLAuthenticationToken):boolean of object;

     TRNLHostOnPeerConnect=procedure(const aHost:TRNLHost;const aPeer:TRNLPeer;const aData:TRNLUInt64) of object;

     TRNLHostOnPeerDisconnect=procedure(const aHost:TRNLHost;const aPeer:TRNLPeer;const aData:TRNLUInt64) of object;

     TRNLHostOnPeerApproval=procedure(const aHost:TRNLHost;const aPeer:TRNLPeer) of object;

     TRNLHostOnPeerDenial=procedure(const aHost:TRNLHost;const aPeer:TRNLPeer;const aDenialReason:TRNLConnectionDenialReason) of object;

     TRNLHostOnPeerBandwidthLimits=procedure(const aHost:TRNLHost;const aPeer:TRNLPeer) of object;

     TRNLHostOnPeerMTU=procedure(const aHost:TRNLHost;const aPeer:TRNLPeer;const aMTU:TRNLUInt16) of object;

     TRNLHostOnPeerReceive=procedure(const aHost:TRNLHost;const aPeer:TRNLPeer;const aChannel:TRNLUInt8;const aMessage:TRNLMessage) of object;

{      RNL_HOST_EVENT_TYPE_BANDWIDTH_LIMITS,
       RNL_HOST_EVENT_TYPE_MTU,
       RNL_HOST_EVENT_TYPE_RECEIVE
}
     TRNLHostPeerCircularDoublyLinkedListNode=TRNLCircularDoublyLinkedListNode<TRNLPeer>;

     TRNLHostPeerIDMap=TRNLIDMap<TRNLPeer>;

     TRNLHostPeerList=TRNLObjectList<TRNLPeer>;

     TRNLInstance=class
      private
       fTimeBase:TRNLTime;
{$if defined(RNL_DEBUG)}
       fDebugLock:TCriticalSection;
{$ifend}
       class procedure GlobalInitialize;
       class procedure GlobalFinalize;
       function GetTime:TRNLTime;
       procedure SetTime(const aTimeBase:TRNLTime);
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       property Time:TRNLTime read GetTime write SetTime;
     end;

     PRNLNetworkSendResult=^TRNLNetworkSendResult;
     TRNLNetworkSendResult=
      (
       RNL_NETWORK_SEND_RESULT_ERROR,
       RNL_NETWORK_SEND_RESULT_OK,
       RNL_NETWORK_SEND_RESULT_BANDWIDTH_RATE_LIMITER_DROP
      );

     TRNLNetworkEvent=class
      private
{$ifdef Windows}
       fEvent:THandle;
{$else}
       fEventLock:TCriticalSection;
       fEventPipeFDs:{$ifdef fpc}TFilDes{$else}array[0..1] of TRNLInt32{$endif};
{$endif}
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure SetEvent;
       procedure ResetEvent;
       function WaitFor(const aTimeout:TRNLInt64):TWaitResult;
       class function WaitForMultipleEvents(const aEvents:array of TRNLNetworkEvent;const aTimeout:TRNLInt64):TRNLInt32; static;
     end;

     TRNLInterfaceHostAddressType=
      (
       RNL_INTERFACE_HOST_ADDRESS_UNICAST,
       RNL_INTERFACE_HOST_ADDRESS_MULTICAST
      );

     TRNLNetwork=class
      private
       fInstance:TRNLInstance;
      public
       constructor Create(const aInstance:TRNLInstance); reintroduce; virtual;
       destructor Destroy; override;
       function AddressSetHost(var aAddress:TRNLAddress;const aName:TRNLRawByteString):boolean; virtual;
       function AddressGetHost(const aAddress:TRNLAddress;out aName;const aNameLength:TRNLInt32;const aFlags:TRNLInt32=0):boolean; virtual;
       function AddressGetHostIP(const aAddress:TRNLAddress;out aName;const aNameLength:TRNLInt32):boolean; virtual;
       function AddressGetPrimaryInterfaceHostIP(var aAddress:TRNLAddress;const aFamily:TRNLAddressFamily;const aInterfaceHostAddressType:TRNLInterfaceHostAddressType=RNL_INTERFACE_HOST_ADDRESS_UNICAST):boolean; virtual;
       function SocketCreate(const aType:TRNLSocketType;const aFamily:TRNLAddressFamily):TRNLSocket; virtual;
       procedure SocketDestroy(const aSocket:TRNLSocket); virtual;
       function SocketShutdown(const aSocket:TRNLSocket;const aHow:TRNLSocketShutdown=RNL_SOCKET_SHUTDOWN_READ_WRITE):boolean; virtual;
       function SocketGetAddress(const aSocket:TRNLSocket;out aAddress:TRNLAddress;const aFamily:TRNLAddressFamily):boolean; virtual;
       function SocketSetOption(const aSocket:TRNLSocket;const aOption:TRNLSocketOption;const aValue:TRNLInt32):boolean; virtual;
       function SocketGetOption(const aSocket:TRNLSocket;const aOption:TRNLSocketOption;out aValue:TRNLInt32):boolean; virtual;
       function SocketBind(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aFamily:TRNLAddressFamily):boolean; virtual;
       function SocketListen(const aSocket:TRNLSocket;const aBackLog:TRNLInt32):boolean; virtual;
       function SocketConnect(const aSocket:TRNLSocket;const aAddress:TRNLAddress;const aFamily:TRNLAddressFamily):boolean; virtual;
       function SocketAccept(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aFamily:TRNLAddressFamily):TRNLSocket; virtual;
       function SocketSelect(const aMaxSocket:TRNLSocket;var aReadSet,aWriteSet:TRNLSocketSet;const aTimeout:TRNLInt64;const aEvent:TRNLNetworkEvent=nil):TRNLInt32; virtual;
       function SocketWait(const aSockets:array of TRNLSocket;var aConditions:TRNLSocketWaitConditions;const aTimeout:TRNLInt64;const aEvent:TRNLNetworkEvent=nil):boolean; virtual;
       function Send(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aData;const aDataLength:TRNLSizeInt;const aFamily:TRNLAddressFamily):TRNLSizeInt; virtual;
       function Receive(const aSocket:TRNLSocket;const aAddress:PRNLAddress;out aData;const aDataLength:TRNLSizeInt;const aFamily:TRNLAddressFamily):TRNLSizeInt; virtual;
      published
       property Instance:TRNLInstance read fInstance;
     end;

     ERNLRealNetwork=class(Exception);

     TRNLRealNetwork=class(TRNLNetwork)
{$ifdef Windows}
      private
       type TRNLRealNetworkHandles=array of THandle;
            PRNLRealNetworkPollFD=^TRNLRealNetworkPollFD;
            TRNLRealNetworkPollFD=record
             fd:TRNLSocket;
             events:TRNLInt16;
             revents:TRNLInt16;
            end;
            PRNLRealNetworkPollFDs=^TRNLRealNetworkPollFDs;
            TRNLRealNetworkPollFDs=array[0..65535] of TRNLRealNetworkPollFD;
      private
       function EmulatePoll(const aPollFDs:PRNLRealNetworkPollFDs;const aCount:TRNLSizeInt;const aTimeout:TRNLInt64;const aEvent:TRNLNetworkEvent=nil):TRNLInt32;
{$else}
      private
{$endif}
       class procedure GlobalInitialize;
       class procedure GlobalFinalize;
      public
       constructor Create(const aInstance:TRNLInstance); override;
       destructor Destroy; override;
       function AddressSetHost(var aAddress:TRNLAddress;const aName:TRNLRawByteString):boolean; override;
       function AddressGetHost(const aAddress:TRNLAddress;out aName;const aNameLength:TRNLInt32;const aFlags:TRNLInt32=0):boolean; override;
       function AddressGetHostIP(const aAddress:TRNLAddress;out aName;const aNameLength:TRNLInt32):boolean; override;
       function AddressGetPrimaryInterfaceHostIP(var aAddress:TRNLAddress;const aFamily:TRNLAddressFamily;const aInterfaceHostAddressType:TRNLInterfaceHostAddressType=RNL_INTERFACE_HOST_ADDRESS_UNICAST):boolean; override;
       function SocketCreate(const aType:TRNLSocketType;const aFamily:TRNLAddressFamily):TRNLSocket; override;
       procedure SocketDestroy(const aSocket:TRNLSocket); override;
       function SocketShutdown(const aSocket:TRNLSocket;const aHow:TRNLSocketShutdown=RNL_SOCKET_SHUTDOWN_READ_WRITE):boolean; override;
       function SocketGetAddress(const aSocket:TRNLSocket;out aAddress:TRNLAddress;const aFamily:TRNLAddressFamily):boolean; override;
       function SocketSetOption(const aSocket:TRNLSocket;const aOption:TRNLSocketOption;const aValue:TRNLInt32):boolean; override;
       function SocketGetOption(const aSocket:TRNLSocket;const aOption:TRNLSocketOption;out aValue:TRNLInt32):boolean; override;
       function SocketBind(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aFamily:TRNLAddressFamily):boolean; override;
       function SocketListen(const aSocket:TRNLSocket;const aBackLog:TRNLInt32):boolean; override;
       function SocketConnect(const aSocket:TRNLSocket;const aAddress:TRNLAddress;const aFamily:TRNLAddressFamily):boolean; override;
       function SocketAccept(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aFamily:TRNLAddressFamily):TRNLSocket; override;
       function SocketSelect(const aMaxSocket:TRNLSocket;var aReadSet,aWriteSet:TRNLSocketSet;const aTimeout:TRNLInt64;const aEvent:TRNLNetworkEvent=nil):TRNLInt32; override;
       function SocketWait(const aSockets:array of TRNLSocket;var aConditions:TRNLSocketWaitConditions;const aTimeout:TRNLInt64;const aEvent:TRNLNetworkEvent=nil):boolean; override;
       function Send(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aData;const aDataLength:TRNLSizeInt;const aFamily:TRNLAddressFamily):TRNLSizeInt; override;
       function Receive(const aSocket:TRNLSocket;const aAddress:PRNLAddress;out aData;const aDataLength:TRNLSizeInt;const aFamily:TRNLAddressFamily):TRNLSizeInt; override;
     end;

     TRNLVirtualNetwork=class(TRNLNetwork)
      private
       const RNL_VIRTUAL_NETWORK_SOCKET_HASH_BITS=12;
             RNL_VIRTUAL_NETWORK_SOCKET_HASH_SIZE=1 shl RNL_VIRTUAL_NETWORK_SOCKET_HASH_BITS;
             RNL_VIRTUAL_NETWORK_SOCKET_HASH_MASK=RNL_VIRTUAL_NETWORK_SOCKET_HASH_SIZE-1;
       type TRNLVirtualNetworkSocketStack=TRNLStack<TRNLSocket>;
            TRNLVirtualNetworkSocketData=record
             Address:TRNLAddress;
             Data:TBytes;
            end;
            TRNLVirtualNetworkSocketDataQueue=TRNLQueue<TRNLVirtualNetworkSocketData>;
            TRNLVirtualNetworkSocketInstance=class;
            TRNLVirtualNetworkSocketInstanceListNode=TRNLCircularDoublyLinkedListNode<TRNLVirtualNetworkSocketInstance>;
            TRNLVirtualNetworkSocketInstance=class(TRNLVirtualNetworkSocketInstanceListNode)
             private
              fNetwork:TRNLVirtualNetwork;
              fSocket:TRNLSocket;
              fAddress:TRNLAddress;
              fAddressHash:TRNLUInt32;
              fAddressListNode:TRNLVirtualNetworkSocketInstanceListNode;
              fSocketInstanceListNode:TRNLVirtualNetworkSocketInstanceListNode;
              fData:TRNLVirtualNetworkSocketDataQueue;
             public
              constructor Create(const aNetwork:TRNLVirtualNetwork;const aSocket:TRNLSocket); reintroduce;
              destructor Destroy; override;
              procedure UpdateAddress;
            end;
            TRNLVirtualNetworkSocketInstanceHashMap=array[0..RNL_VIRTUAL_NETWORK_SOCKET_HASH_SIZE-1] of TRNLVirtualNetworkSocketInstanceListNode;
      private
       fLock:TCriticalSection;
       fNewDataEvent:TRNLNetworkEvent;
       fSocketCounter:TRNLSocket;
       fFreeSockets:TRNLVirtualNetworkSocketStack;
       fSocketInstanceList:TRNLVirtualNetworkSocketInstanceListNode;
       fSocketInstanceHashMap:TRNLVirtualNetworkSocketInstanceHashMap;
       fAddressSocketInstanceHashMap:TRNLVirtualNetworkSocketInstanceHashMap;
       class function HashSocket(const aSocket:TRNLSocket):TRNLUInt32; static;
       class function HashAddress(const aAddress:TRNLAddress):TRNLUInt32; static;
       function FindSocketInstance(const aSocket:TRNLSocket;const aCreateIfNotExist:boolean):TRNLVirtualNetworkSocketInstance;
       function FindAddressSocketInstance(const aAddress:TRNLAddress):TRNLVirtualNetworkSocketInstance;
      public
       constructor Create(const aInstance:TRNLInstance); override;
       destructor Destroy; override;
       function AddressSetHost(var aAddress:TRNLAddress;const aName:TRNLRawByteString):boolean; override;
       function AddressGetHost(const aAddress:TRNLAddress;out aName;const aNameLength:TRNLInt32;const aFlags:TRNLInt32=0):boolean; override;
       function AddressGetHostIP(const aAddress:TRNLAddress;out aName;const aNameLength:TRNLInt32):boolean; override;
       function SocketCreate(const aType:TRNLSocketType;const aFamily:TRNLAddressFamily):TRNLSocket; override;
       procedure SocketDestroy(const aSocket:TRNLSocket); override;
       function SocketShutdown(const aSocket:TRNLSocket;const aHow:TRNLSocketShutdown=RNL_SOCKET_SHUTDOWN_READ_WRITE):boolean; override;
       function SocketGetAddress(const aSocket:TRNLSocket;out aAddress:TRNLAddress;const aFamily:TRNLAddressFamily):boolean; override;
       function SocketSetOption(const aSocket:TRNLSocket;const aOption:TRNLSocketOption;const aValue:TRNLInt32):boolean; override;
       function SocketGetOption(const aSocket:TRNLSocket;const aOption:TRNLSocketOption;out aValue:TRNLInt32):boolean; override;
       function SocketBind(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aFamily:TRNLAddressFamily):boolean; override;
       function SocketListen(const aSocket:TRNLSocket;const aBackLog:TRNLInt32):boolean; override;
       function SocketConnect(const aSocket:TRNLSocket;const aAddress:TRNLAddress;const aFamily:TRNLAddressFamily):boolean; override;
       function SocketAccept(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aFamily:TRNLAddressFamily):TRNLSocket; override;
       function SocketSelect(const aMaxSocket:TRNLSocket;var aReadSet,aWriteSet:TRNLSocketSet;const aTimeout:TRNLInt64;const aEvent:TRNLNetworkEvent=nil):TRNLInt32; override;
       function SocketWait(const aSockets:array of TRNLSocket;var aConditions:TRNLSocketWaitConditions;const aTimeout:TRNLInt64;const aEvent:TRNLNetworkEvent=nil):boolean; override;
       function Send(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aData;const aDataLength:TRNLSizeInt;const aFamily:TRNLAddressFamily):TRNLSizeInt; override;
       function Receive(const aSocket:TRNLSocket;const aAddress:PRNLAddress;out aData;const aDataLength:TRNLSizeInt;const aFamily:TRNLAddressFamily):TRNLSizeInt; override;
     end;

     TRNLNetworkInterferenceSimulator=class(TRNLNetwork)
      private
       type TRNLNetworkInterferenceSimulatorPacket=class;
            TRNLNetworkInterferenceSimulatorPacketListNode=TRNLCircularDoublyLinkedListNode<TRNLNetworkInterferenceSimulatorPacket>;
            TRNLNetworkInterferenceSimulatorPacket=class(TRNLNetworkInterferenceSimulatorPacketListNode)
             private
              fNetworkInterferenceSimulator:TRNLNetworkInterferenceSimulator;
              fTime:TRNLTime;
              fSocket:TRNLSocket;
              fAddress:TRNLAddress;
              fData:TBytes;
              fFamily:TRNLAddressFamily;
             public
              constructor Create(const aNetworkInterferenceSimulator:TRNLNetworkInterferenceSimulator);
              destructor Destroy; override;
            end;
      private
       fNetwork:TRNLNetwork;
       fLock:TCriticalSection;
       fRandomGenerator:TRNLRandomGenerator;
       fNextTimeout:TRNLTime;
       fIncomingPacketList:TRNLNetworkInterferenceSimulatorPacketListNode;
       fOutgoingPacketList:TRNLNetworkInterferenceSimulatorPacketListNode;
       fSimulatedIncomingPacketLossProbabilityFactor:TRNLUInt32;
       fSimulatedOutgoingPacketLossProbabilityFactor:TRNLUInt32;
       fSimulatedIncomingDuplicatePacketProbabilityFactor:TRNLUInt32;
       fSimulatedOutgoingDuplicatePacketProbabilityFactor:TRNLUInt32;
       fSimulatedIncomingOutOfOrderPacketProbabilityFactor:TRNLUInt32;
       fSimulatedOutgoingOutOfOrderPacketProbabilityFactor:TRNLUInt32;
       fSimulatedIncomingBitFlippingProbabilityFactor:TRNLUInt32;
       fSimulatedOutgoingBitFlippingProbabilityFactor:TRNLUInt32;
       fSimulatedIncomingMinimumFlippingBits:TRNLUInt32;
       fSimulatedOutgoingMinimumFlippingBits:TRNLUInt32;
       fSimulatedIncomingMaximumFlippingBits:TRNLUInt32;
       fSimulatedOutgoingMaximumFlippingBits:TRNLUInt32;
       fSimulatedIncomingLatency:TRNLUInt32;
       fSimulatedOutgoingLatency:TRNLUInt32;
       fSimulatedIncomingJitter:TRNLUInt32;
       fSimulatedOutgoingJitter:TRNLUInt32;
       function SimulateIncomingPacketLoss:boolean;
       function SimulateOutgoingPacketLoss:boolean;
       function SimulateIncomingDuplicatePacket:boolean;
       function SimulateOutgoingDuplicatePacket:boolean;
       function SimulateIncomingOutOfOrderPacket:boolean;
       function SimulateOutgoingOutOfOrderPacket:boolean;
       function SimulateIncomingBitFlipping:boolean;
       function SimulateOutgoingBitFlipping:boolean;
       procedure SimulateBitFlipping(var aData;
                                     const aDataLength:TRNLUInt32;
                                     const aMinimumFlippingBits:TRNLUInt32;
                                     const aMaximumFlippingBits:TRNLUInt32);
       function TRNLNetworkInterferenceSimulatorPacketCompare(const a,b:TObject):TRNLInt32;
       procedure Update;
      public
       constructor Create(const aInstance:TRNLInstance;const aNetwork:TRNLNetwork); reintroduce;
       destructor Destroy; override;
       function AddressSetHost(var aAddress:TRNLAddress;const aName:TRNLRawByteString):boolean; override;
       function AddressGetHost(const aAddress:TRNLAddress;out aName;const aNameLength:TRNLInt32;const aFlags:TRNLInt32=0):boolean; override;
       function AddressGetHostIP(const aAddress:TRNLAddress;out aName;const aNameLength:TRNLInt32):boolean; override;
       function SocketCreate(const aType:TRNLSocketType;const aFamily:TRNLAddressFamily):TRNLSocket; override;
       procedure SocketDestroy(const aSocket:TRNLSocket); override;
       function SocketShutdown(const aSocket:TRNLSocket;const aHow:TRNLSocketShutdown=RNL_SOCKET_SHUTDOWN_READ_WRITE):boolean; override;
       function SocketGetAddress(const aSocket:TRNLSocket;out aAddress:TRNLAddress;const aFamily:TRNLAddressFamily):boolean; override;
       function SocketSetOption(const aSocket:TRNLSocket;const aOption:TRNLSocketOption;const aValue:TRNLInt32):boolean; override;
       function SocketGetOption(const aSocket:TRNLSocket;const aOption:TRNLSocketOption;out aValue:TRNLInt32):boolean; override;
       function SocketBind(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aFamily:TRNLAddressFamily):boolean; override;
       function SocketListen(const aSocket:TRNLSocket;const aBackLog:TRNLInt32):boolean; override;
       function SocketConnect(const aSocket:TRNLSocket;const aAddress:TRNLAddress;const aFamily:TRNLAddressFamily):boolean; override;
       function SocketAccept(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aFamily:TRNLAddressFamily):TRNLSocket; override;
       function SocketSelect(const aMaxSocket:TRNLSocket;var aReadSet,aWriteSet:TRNLSocketSet;const aTimeout:TRNLInt64;const aEvent:TRNLNetworkEvent=nil):TRNLInt32; override;
       function SocketWait(const aSockets:array of TRNLSocket;var aConditions:TRNLSocketWaitConditions;const aTimeout:TRNLInt64;const aEvent:TRNLNetworkEvent=nil):boolean; override;
       function Send(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aData;const aDataLength:TRNLSizeInt;const aFamily:TRNLAddressFamily):TRNLSizeInt; override;
       function Receive(const aSocket:TRNLSocket;const aAddress:PRNLAddress;out aData;const aDataLength:TRNLSizeInt;const aFamily:TRNLAddressFamily):TRNLSizeInt; override;
      published
       property SimulatedIncomingPacketLossProbabilityFactor:TRNLUInt32 read fSimulatedIncomingPacketLossProbabilityFactor write fSimulatedIncomingPacketLossProbabilityFactor;
       property SimulatedOutgoingPacketLossProbabilityFactor:TRNLUInt32 read fSimulatedOutgoingPacketLossProbabilityFactor write fSimulatedOutgoingPacketLossProbabilityFactor;
       property SimulatedIncomingDuplicatePacketProbabilityFactor:TRNLUInt32 read fSimulatedIncomingDuplicatePacketProbabilityFactor write fSimulatedIncomingDuplicatePacketProbabilityFactor;
       property SimulatedOutgoingDuplicatePacketProbabilityFactor:TRNLUInt32 read fSimulatedOutgoingDuplicatePacketProbabilityFactor write fSimulatedOutgoingDuplicatePacketProbabilityFactor;
       property SimulatedIncomingOutOfOrderPacketProbabilityFactor:TRNLUInt32 read fSimulatedIncomingOutOfOrderPacketProbabilityFactor write fSimulatedIncomingOutOfOrderPacketProbabilityFactor;
       property SimulatedOutgoingOutOfOrderPacketProbabilityFactor:TRNLUInt32 read fSimulatedOutgoingOutOfOrderPacketProbabilityFactor write fSimulatedOutgoingOutOfOrderPacketProbabilityFactor;
       property SimulatedIncomingBitFlippingProbabilityFactor:TRNLUInt32 read fSimulatedIncomingBitFlippingProbabilityFactor write fSimulatedIncomingBitFlippingProbabilityFactor;
       property SimulatedOutgoingBitFlippingProbabilityFactor:TRNLUInt32 read fSimulatedOutgoingBitFlippingProbabilityFactor write fSimulatedOutgoingBitFlippingProbabilityFactor;
       property SimulatedIncomingMinimumFlippingBits:TRNLUInt32 read fSimulatedIncomingMinimumFlippingBits write fSimulatedIncomingMinimumFlippingBits;
       property SimulatedOutgoingMinimumFlippingBits:TRNLUInt32 read fSimulatedOutgoingMinimumFlippingBits write fSimulatedOutgoingMinimumFlippingBits;
       property SimulatedIncomingMaximumFlippingBits:TRNLUInt32 read fSimulatedIncomingMaximumFlippingBits write fSimulatedIncomingMaximumFlippingBits;
       property SimulatedOutgoingMaximumFlippingBits:TRNLUInt32 read fSimulatedOutgoingMaximumFlippingBits write fSimulatedOutgoingMaximumFlippingBits;
       property SimulatedIncomingLatency:TRNLUInt32 read fSimulatedIncomingLatency write fSimulatedIncomingLatency;
       property SimulatedOutgoingLatency:TRNLUInt32 read fSimulatedOutgoingLatency write fSimulatedOutgoingLatency;
       property SimulatedIncomingJitter:TRNLUInt32 read fSimulatedIncomingJitter write fSimulatedIncomingJitter;
       property SimulatedOutgoingJitter:TRNLUInt32 read fSimulatedOutgoingJitter write fSimulatedOutgoingJitter;
     end;

     PRNLPeerState=^TRNLPeerState;
     TRNLPeerState=
      (
       RNL_PEER_STATE_DISCONNECTED,
       RNL_PEER_STATE_CONNECTION_REQUESTING,
       RNL_PEER_STATE_CONNECTION_CHALLENGING,
       RNL_PEER_STATE_CONNECTION_AUTHENTICATING,
       RNL_PEER_STATE_CONNECTION_APPROVING,
       RNL_PEER_STATE_CONNECTED,
       RNL_PEER_STATE_DISCONNECT_LATER,
       RNL_PEER_STATE_DISCONNECTING,
       RNL_PEER_STATE_DISCONNECTION_ACKNOWLEDGING,
       RNL_PEER_STATE_DISCONNECTION_PENDING
      );

     TRNLPeerPendingConnectionHandshakeSendData=class
      private
       fPeer:TRNLPeer;
       fHandshakePacket:TRNLProtocolHandshakePacket;
      public
       constructor Create(const aPeer:TRNLPeer); reintroduce;
       function Send:boolean;
     end;

     TRNLPeerIncomingEncryptedPacketSequenceBuffer=array of TRNLUInt64;

     TRNLPeerBlockPacketData=TBytes;

     PRNLPeerBlockPacket=^TRNLPeerBlockPacket;

     TRNLPeerBlockPacket=class;

     TRNLPeerBlockPacketCircularDoublyLinkedListNode=TRNLCircularDoublyLinkedListNode<TRNLPeerBlockPacket>;

     TRNLPeerBlockPacket=class(TRNLPeerBlockPacketCircularDoublyLinkedListNode)
      private
       fPeer:TRNLPeer;
       fChannel:TRNLUInt8;
       fSequenceNumber:TRNLSequenceNumber;
       fCountSendAttempts:TRNLUInt32;
       fRoundTripTimeout:TRNLUInt64;
       fRoundTripTimeoutLimit:TRNLUInt64;
       fSentTime:TRNLTime;
       fReceivedTime:TRNLTime;
       fBlockPacket:TRNLProtocolBlockPacket;
       fBlockPacketData:TRNLPeerBlockPacketData;
       fBlockPacketDataLength:TRNLSizeUInt;
       fReferenceCounter:TRNLUInt32;
       fPendingResendOutgoingBlockPacketsList:TRNLPeerBlockPacketCircularDoublyLinkedListNode;
       function GetPointerToBlockPacket:PRNLProtocolBlockPacket; inline;
       function GetSize:TRNLSizeUInt;
      public
       constructor Create(const aPeer:TRNLPeer); reintroduce;
       destructor Destroy; override;
       procedure IncRef;
       procedure DecRef;
       procedure Clear;
       function AppendTo(var aOutgoingPacketBuffer:TRNLOutgoingPacketBuffer):boolean;
       property BlockPacket:PRNLProtocolBlockPacket read GetPointerToBlockPacket;
       property Size:TRNLSizeUInt read GetSize;
       property ReferenceCounter:TRNLUInt32 read fReferenceCounter write fReferenceCounter;
     end;

     TRNLPeerBlockPacketQueue=TRNLQueue<TRNLPeerBlockPacket>;

     TRNLPeerBlockPacketStack=TRNLStack<TRNLPeerBlockPacket>;

     TRNLPeerChannel=class;

     PRNLPeerChannelType=^TRNLPeerChannelType;
     TRNLPeerChannelType=
      (
       RNL_PEER_RELIABLE_ORDERED_CHANNEL=0,
       RNL_PEER_RELIABLE_UNORDERED_CHANNEL=1,
       RNL_PEER_UNRELIABLE_ORDERED_CHANNEL=2,
       RNL_PEER_UNRELIABLE_UNORDERED_CHANNEL=3
      );

     PRNLPeerChannelTypes=^TRNLPeerChannelTypes;
     TRNLPeerChannelTypes=array[0..RNL_MAXIMUM_PEER_CHANNELS-1] of TRNLPeerChannelType;

     TRNLPeerChannel=class
      private

       fPeer:TRNLPeer;

       fHost:TRNLHost;

       fChannelNumber:TRNLUInt16;

       fIncomingMessageQueue:TRNLMessageQueue;

       fOutgoingMessageQueue:TRNLMessageQueue;

       function GetMaximumUnfragmentedMessageSize:TRNLSizeUInt; virtual;

       procedure DispatchOutgoingBlockPackets; virtual;

       procedure DispatchIncomingBlockPacket(const aBlockPacket:TRNLPeerBlockPacket); virtual;

       procedure DispatchIncomingMessages; virtual;

      public

       constructor Create(const aPeer:TRNLPeer;const aChannelNumber:TRNLUInt16); reintroduce; virtual;
       destructor Destroy; override;

       procedure SendMessage(const aMessage:TRNLMessage);
       procedure SendMessageData(const aData:TRNLPointer;const aDataLength:TRNLUInt32;const aFlags:TRNLMessageFlags=[]);
       procedure SendMessageBytes(const aBytes:TBytes;const aFlags:TRNLMessageFlags=[]); overload;
       procedure SendMessageBytes(const aBytes:array of TRNLUInt8;const aFlags:TRNLMessageFlags=[]); overload;
       procedure SendMessageRawByteString(const aString:TRNLRawByteString;const aFlags:TRNLMessageFlags=[]);
       procedure SendMessageUTF8String(const aString:TRNLUTF8String;const aFlags:TRNLMessageFlags=[]);
       procedure SendMessageUTF16String(const aString:TRNLUTF16String;const aFlags:TRNLMessageFlags=[]);
       procedure SendMessageString(const aString:TRNLString;const aFlags:TRNLMessageFlags=[]);
       procedure SendMessageStream(const aStream:TStream;const aFlags:TRNLMessageFlags=[]);

       property MaximumUnfragmentedMessageSize:TRNLSizeUInt read GetMaximumUnfragmentedMessageSize;

     end;

     PRNLPeerReliableChannelCommandType=^TRNLPeerReliableChannelCommandType;
     TRNLPeerReliableChannelCommandType=
      (
       RNL_PEER_RELIABLE_CHANNEL_COMMAND_TYPE_SHORT_MESSAGE=0,
       RNL_PEER_RELIABLE_CHANNEL_COMMAND_TYPE_LONG_MESSAGE=1,
       RNL_PEER_RELIABLE_CHANNEL_COMMAND_TYPE_ACKNOWLEDGEMENT=2,
       RNL_PEER_RELIABLE_CHANNEL_COMMAND_TYPE_ACKNOWLEDGEMENTS=3
      );

     PRNLPeerReliableChannelPacketHeader=^TRNLPeerReliableChannelPacketHeader;
     TRNLPeerReliableChannelPacketHeader=packed record
      SequenceNumber:TRNLUInt16;
     end;

     PRNLPeerReliableChannelShortMessagePacketHeader=^TRNLPeerReliableChannelShortMessagePacketHeader;
     TRNLPeerReliableChannelShortMessagePacketHeader=packed record
      Header:TRNLPeerReliableChannelPacketHeader;
     end;

     PRNLPeerReliableChannelLongMessagePacketHeader=^TRNLPeerReliableChannelLongMessagePacketHeader;
     TRNLPeerReliableChannelLongMessagePacketHeader=packed record
      Header:TRNLPeerReliableChannelPacketHeader;
      MessageNumber:TRNLUInt16;
      Offset:TRNLUInt32;
      Length:TRNLUInt32;
     end;

     PRNLPeerReliableChannelAcknowledgementPacketHeader=^TRNLPeerReliableChannelAcknowledgementPacketHeader;
     TRNLPeerReliableChannelAcknowledgementPacketHeader=packed record
      Header:TRNLPeerReliableChannelPacketHeader;
     end;

     PRNLPeerReliableChannelAcknowledgementsPacketHeader=^TRNLPeerReliableChannelAcknowledgementsPacketHeader;
     TRNLPeerReliableChannelAcknowledgementsPacketHeader=packed record
      Header:TRNLPeerReliableChannelPacketHeader;
     end;

     TRNLPeerReliableChannelBlockPacketBufferArray=array of TRNLPeerBlockPacket;

     PRNLPeerReliableChannelAcknowledgement=^TRNLPeerReliableChannelAcknowledgement;
     TRNLPeerReliableChannelAcknowledgement=TRNLInt32;

     TRNLPeerReliableChannelAcknowledgementArray=array of TRNLPeerReliableChannelAcknowledgement;

     TRNLPeerReliableChannel=class(TRNLPeerChannel)
      private

       fOrdered:boolean;

       fIncomingBlockPackets:TRNLPeerReliableChannelBlockPacketBufferArray;
       fIncomingBlockPacketSequenceNumber:TRNLSequenceNumber;

       fIncomingAcknowledgements:TRNLPeerReliableChannelAcknowledgementArray;
       fIncomingAcknowledgementSequenceNumber:TRNLSequenceNumber;

       fOutgoingBlockPackets:TRNLPeerReliableChannelBlockPacketBufferArray;
       fOutgoingBlockPacketSequenceNumber:TRNLSequenceNumber;

       fOutgoingAcknowledgementQueue:TRNLSequenceNumberQueue;

       fOutgoingAcknowledgementArray:TRNLSequenceNumberArray;

       fOutgoingAcknowledgementData:TBytes;

       fOutgoingBlockPacketQueue:TRNLPeerBlockPacketQueue;

       fSentOutgoingBlockPackets:TRNLPeerBlockPacketCircularDoublyLinkedListNode;

       function GetMaximumUnfragmentedMessageSize:TRNLSizeUInt; override;

       procedure DispatchOutgoingBlockPacketsTimeout;

       procedure DispatchOutgoingAcknowledgementBlockPackets;

       procedure DispatchOutgoingMessageBlockPackets; virtual; abstract;

       procedure DispatchOutgoingBlockPackets; override;

       procedure DispatchIncomingMessageBlockPacket(const aBlockPacket:TRNLPeerBlockPacket); virtual; abstract;

       procedure DispatchIncomingBlockPacketAcknowledgement(const aBlockPacketSequenceNumber:TRNLSequenceNumber;const aBlockPacketReceivedTime:TRNLTime);

       procedure DispatchIncomingAcknowledgementsBlockPacket(const aBlockPacket:TRNLPeerBlockPacket);

       procedure DispatchIncomingBlockPacket(const aBlockPacket:TRNLPeerBlockPacket); override;

      public

       constructor Create(const aPeer:TRNLPeer;const aChannelNumber:TRNLUInt16); override;

       destructor Destroy; override;

     end;

     TRNLPeerReliableOrderedChannel=class(TRNLPeerReliableChannel)
      private

       fOutgoingMessageBlockPacketSequenceNumber:TRNLSequenceNumber;

       fOutgoingMessageNumber:TRNLSequenceNumber;

       fIncomingMessageNumber:TRNLSequenceNumber;

       fIncomingMessageLength:TRNLUInt32;

       fIncomingReceivedMessageDataLength:TRNLUInt32;

       fIncomingMessageReceiveBufferData:TRNLPointer;

       procedure DispatchOutgoingMessageBlockPackets; override;

       procedure DispatchIncomingMessageBlockPacket(const aBlockPacket:TRNLPeerBlockPacket); override;

      public

       constructor Create(const aPeer:TRNLPeer;const aChannelNumber:TRNLUInt16); override;

       destructor Destroy; override;

     end;

     TRNLPeerReliableUnorderedChannel=class;

     TRNLPeerReliableUnorderedChannelLongMessage=class;

     TRNLPeerReliableUnorderedChannelLongMessageListNode=TRNLCircularDoublyLinkedListNode<TRNLPeerReliableUnorderedChannelLongMessage>;

     TRNLPeerReliableUnorderedChannelLongMessage=class(TRNLPeerReliableUnorderedChannelLongMessageListNode)
      private

       fChannel:TRNLPeerReliableUnorderedChannel;

       fMessageNumber:TRNLSequenceNumber;

       fIncomingMessageLength:TRNLUInt32;

       fIncomingReceivedMessageDataLength:TRNLUInt32;

       fIncomingMessageReceiveBufferData:TRNLPointer;

       fIncomingMessageReceiveBufferFlagData:TRNLPointer;

       procedure DispatchIncomingData(const aOffset,aLength:TRNLUInt32;const aData:TRNLPointer);

      public

       constructor Create(const aChannel:TRNLPeerReliableUnorderedChannel;const aMessageNumber,aMessageLength:TRNLUInt32); reintroduce;

       destructor Destroy; override;

     end;

     TRNLPeerReliableUnorderedChannel=class(TRNLPeerReliableChannel)
      private

       fIncomingLongMessages:TRNLPeerReliableUnorderedChannelLongMessageListNode;

       fOutgoingMessageBlockPacketSequenceNumber:TRNLSequenceNumber;

       fOutgoingMessageNumber:TRNLSequenceNumber;

       procedure DispatchOutgoingMessageBlockPackets; override;

       procedure DispatchIncomingMessageBlockPacket(const aBlockPacket:TRNLPeerBlockPacket); override;

      public

       constructor Create(const aPeer:TRNLPeer;const aChannelNumber:TRNLUInt16); override;

       destructor Destroy; override;

     end;

     PRNLPeerUnreliableOrderedChannelCommandType=^TRNLPeerUnreliableOrderedChannelCommandType;
     TRNLPeerUnreliableOrderedChannelCommandType=
      (
       RNL_PEER_UNRELIABLE_ORDERED_CHANNEL_COMMAND_TYPE_SHORT_MESSAGE=0,
       RNL_PEER_UNRELIABLE_ORDERED_CHANNEL_COMMAND_TYPE_LONG_MESSAGE=1
      );

     PRNLPeerUnreliableOrderedChannelShortMessagePacketHeader=^TRNLPeerUnreliableOrderedChannelShortMessagePacketHeader;
     TRNLPeerUnreliableOrderedChannelShortMessagePacketHeader=packed record
      SequenceNumber:TRNLUInt16;
     end;

     PRNLPeerUnreliableOrderedChannelLongMessagePacketHeader=^TRNLPeerUnreliableOrderedChannelLongMessagePacketHeader;
     TRNLPeerUnreliableOrderedChannelLongMessagePacketHeader=packed record
      SequenceNumber:TRNLUInt16;
      MessageNumber:TRNLUInt16;
      Offset:TRNLUInt32;
      Length:TRNLUInt32;
     end;

     TRNLPeerUnreliableOrderedChannel=class(TRNLPeerChannel)
      private

       fIncomingSequenceNumber:TRNLSequenceNumber;

       fIncomingMessageNumber:TRNLSequenceNumber;

       fIncomingMessageLength:TRNLUInt32;

       fIncomingReceivedMessageDataLength:TRNLUInt32;

       fIncomingMessageReceiveBufferData:TRNLPointer;

       fIncomingSawLost:longbool;

       fOutgoingSequenceNumber:TRNLSequenceNumber;

       fOutgoingMessageNumber:TRNLSequenceNumber;

       function GetMaximumUnfragmentedMessageSize:TRNLSizeUInt; override;

       procedure DispatchOutgoingBlockPackets; override;

       procedure DispatchIncomingBlockPacket(const aBlockPacket:TRNLPeerBlockPacket); override;

      public

       constructor Create(const aPeer:TRNLPeer;const aChannelNumber:TRNLUInt16); override;

       destructor Destroy; override;

     end;

     PRNLPeerUnreliableUnorderedChannelCommandType=^TRNLPeerUnreliableUnorderedChannelCommandType;
     TRNLPeerUnreliableUnorderedChannelCommandType=
      (
       RNL_PEER_UNRELIABLE_UNORDERED_CHANNEL_COMMAND_TYPE_SHORT_MESSAGE=0,
       RNL_PEER_UNRELIABLE_UNORDERED_CHANNEL_COMMAND_TYPE_LONG_MESSAGE=1
      );

     PRNLPeerUnreliableUnorderedChannelShortMessagePacketHeader=^TRNLPeerUnreliableUnorderedChannelShortMessagePacketHeader;
     TRNLPeerUnreliableUnorderedChannelShortMessagePacketHeader=packed record
     end;

     PRNLPeerUnreliableUnorderedChannelLongMessagePacketHeader=^TRNLPeerUnreliableUnorderedChannelLongMessagePacketHeader;
     TRNLPeerUnreliableUnorderedChannelLongMessagePacketHeader=packed record
      MessageNumber:TRNLUInt16;
      Offset:TRNLUInt32;
      Length:TRNLUInt32;
     end;

     TRNLPeerUnreliableUnorderedChannel=class(TRNLPeerChannel)
      private

       fIncomingMessageNumber:TRNLSequenceNumber;

       fIncomingMessageLength:TRNLUInt32;

       fIncomingReceivedMessageDataLength:TRNLUInt32;

       fIncomingMessageReceiveBufferData:TRNLPointer;

       fIncomingMessageReceiveBufferFlagData:TRNLPointer;

       fOutgoingMessageNumber:TRNLSequenceNumber;

       function GetMaximumUnfragmentedMessageSize:TRNLSizeUInt; override;

       procedure DispatchOutgoingBlockPackets; override;

       procedure DispatchIncomingBlockPacket(const aBlockPacket:TRNLPeerBlockPacket); override;

      public

       constructor Create(const aPeer:TRNLPeer;const aChannelNumber:TRNLUInt16); override;

       destructor Destroy; override;

     end;

     TRNLPeerChannelList=TRNLObjectList<TRNLPeerChannel>;

     PRNLPeerKeepAliveWindowItemState=^TRNLPeerKeepAliveWindowItemState;
     TRNLPeerKeepAliveWindowItemState=
      (
       RNL_PEER_KEEP_ALIVE_WINDOW_ITEM_STATE_FREE=0,
       RNL_PEER_KEEP_ALIVE_WINDOW_ITEM_STATE_SENT=1,
       RNL_PEER_KEEP_ALIVE_WINDOW_ITEM_STATE_ACKNOWLEDGED=2
      );

     PRNLPeerKeepAliveWindowItem=^TRNLPeerKeepAliveWindowItem;
     TRNLPeerKeepAliveWindowItem=record
      State:TRNLPeerKeepAliveWindowItemState;
      SequenceNumber:TRNLUInt8;
      Time:TRNLTime;
      ResendTimeout:TRNLTime;
     end;

     TRNLPeerKeepAliveWindowItems=array of TRNLPeerKeepAliveWindowItem;

     TRNLPeerIncomingPacketQueue=TRNLQueue<TBytes>;

     TRNLPeerListNode=TRNLCircularDoublyLinkedListNode<TRNLPeer>;

     TRNLPeer=class(TRNLPeerListNode)
      private

       fHost:TRNLHost;

       fCurrentThreadIndex:TRNLInt32;

       fReferenceCounter:TRNLUInt32;

       fLocalPeerID:TRNLID;

       fRemotePeerID:TRNLID;

{$if defined(RNL_LINEAR_PEER_LIST)}
       fPeerListIndex:TRNLSizeInt;
{$ifend}

       fPeerToFreeListNode:TRNLPeerListNode;

       fChannels:TRNLPeerChannelList;

       fAddress:TRNLAddress;
       fPointerToAddress:PRNLAddress;

       fRemoteHostSalt:TRNLUInt64;

       fRemoteMTU:TRNLUInt32;

       fMTU:TRNLSizeUInt;

       fState:TRNLPeerState;

       fRemoteIncomingBandwidthLimit:TRNLUInt32;

       fRemoteOutgoingBandwidthLimit:TRNLUInt32;

       fIncomingPacketQueue:TRNLPeerIncomingPacketQueue;

       fOutgoingEncryptedPacketSequenceNumber:TRNLUInt64;
       fIncomingEncryptedPacketSequenceNumber:TRNLUInt64;
       fIncomingEncryptedPacketSequenceBuffer:TRNLPeerIncomingEncryptedPacketSequenceBuffer;

       fLocalSalt:TRNLUInt64;

       fRemoteSalt:TRNLUInt64;

       fCountChannels:TRNLUInt32;

       fDisconnectData:TRNLUInt64;

       fConnectionData:TRNLUInt64;

       fConnectionSalt:TRNLUInt64;

       fConnectionNonce:TRNLUInt64;

       fChecksumPlaceHolder:TRNLUInt32;

       fLocalShortTermPublicKey:TRNLKey;

       fLocalShortTermPrivateKey:TRNLKey;

       fSharedSecretKey:TRNLKey;

       fConnectionChallengeResponse:PRNLConnectionChallenge;

       fUnacknowlegmentedBlockPackets:TRNLUInt32;

       fRoundTripTimeFirst:boolean;

       fRoundTripTime:TRNLInt64;

       fRoundTripTimeVariance:TRNLInt64;

       fRetransmissionTimeout:TRNLInt64;

       fPacketLoss:TRNLInt64;

       fPacketLossVariance:TRNLInt64;

       fCountPacketLoss:TRNLUInt32;

       fCountSentPackets:TRNLUInt32;

       fLastPacketLossUpdateTime:TRNLTime;

       fLastSentDataTime:TRNLTime;

       fLastReceivedDataTime:TRNLTime;

       fLastPingSentTime:TRNLTime;

       fNextPingSendTime:TRNLTime;

       fNextPingResendTime:TRNLTime;

       fIncomingPongSequenceNumber:TRNLUInt8;

       fOutgoingPingSequenceNumber:TRNLUInt8;

       fKeepAliveWindowItems:TRNLPeerKeepAliveWindowItems;

       fNextCheckTimeoutsTimeout:TRNLTime;

       fNextReliableBlockPacketTimeout:TRNLTime;

       fNextPendingConnectionSendTimeout:TRNLTime;

       fNextPendingConnectionSaltTimeout:TRNLTime;

       fNextPendingConnectionShortTermKeyPairTimeout:TRNLTime;

       fNextPendingDisconnectionSendTimeout:TRNLTime;

       fDisconnectionTimeout:TRNLTime;

       fDisconnectionSequenceNumber:TRNLUInt16;

       fPendingConnectionHandshakeSendData:TRNLPeerPendingConnectionHandshakeSendData;

       fConnectionToken:PRNLConnectionToken;

       fAuthenticationToken:PRNLAuthenticationToken;

       fIncomingBlockPackets:TRNLPeerBlockPacketQueue;

       fOutgoingBlockPackets:TRNLPeerBlockPacketQueue;

       fOutgoingMTUProbeBlockPackets:TRNLPeerBlockPacketQueue;

       fDeferredOutgoingBlockPackets:TRNLPeerBlockPacketQueue;

       fMTUProbeIndex:TRNLInt32;

       fMTUProbeSequenceNumber:TRNLSequenceNumber;

       fMTUProbeTryIterationsPerMTUProbeSize:TRNLUInt32;

       fMTUProbeRemainingTryIterations:TRNLUInt32;

       fMTUProbeInterval:TRNLUInt64;

       fMTUProbeNextTimeout:TRNLTime;

       fSendNewHostBandwidthLimits:boolean;

       fReceivedNewHostBandwidthLimitsSequenceNumber:TRNLUInt8;

       fSendNewHostBandwidthLimitsSequenceNumber:TRNLUInt8;

       fSendNewHostBandwidthLimitsInterval:TRNLUInt64;

       fSendNewHostBandwidthLimitsNextTimeout:TRNLTime;

       fIncomingBandwidthRateTracker:TRNLBandwidthRateTracker;

       fOutgoingBandwidthRateTracker:TRNLBandwidthRateTracker;

       fOutgoingBandwidthRateLimiter:TRNLBandwidthRateLimiter;

       procedure UpdateOutgoingBandwidthRateLimiter;

       function GetIncomingBandwidthRate:TRNLUInt32;

       function GetOutgoingBandwidthRate:TRNLUInt32;

       function GetCountChannels:TRNLSizeInt; inline;

       procedure SetCountChannels(aCountChannels:TRNLSizeInt);

       procedure UpdateRoundTripTime(const aRoundTripTime:TRNLInt64);

       function SendPacket(const aData;const aDataLength:TRNLSizeUInt):TRNLNetworkSendResult;

       procedure UpdatePatchLossStatistics;

       procedure DispatchIncomingMTUProbeBlockPacket(const aIncomingBlockPacket:TRNLPeerBlockPacket);

       procedure DispatchIncomingBlockPackets;

       procedure DispatchStateActions;

       procedure DispatchIncomingChannelMessages;

       procedure DispatchOutgoingChannelPackets;

       function DispatchOutgoingMTUProbeBlockPackets(var aOutgoingPacketBuffer:TRNLOutgoingPacketBuffer):boolean;

       function DispatchOutgoingBlockPackets(var aOutgoingPacketBuffer:TRNLOutgoingPacketBuffer):boolean;

       procedure DispatchNewHostBandwidthLimits;

       procedure DispatchMTUProbe;

       procedure DispatchKeepAlive;

       procedure DispatchConnectionTimeout;

       procedure DispatchIncomingPacket(const aPayloadData;const aPayloadDataLength:TRNLSizeUInt;const aSentTime:TRNLUInt64);

       procedure DispatchIncomingPackets;

       function DispatchOutgoingPackets:boolean;

       function DispatchPeer:boolean;

       procedure SendNewHostBandwidthLimits;

      public
       constructor Create(const aHost:TRNLHost); reintroduce;
       destructor Destroy; override;
       procedure IncRef;
       procedure DecRef;
       procedure Disconnect(const aData:TRNLUInt64=0;const aDelayed:boolean=false);
       procedure MTUProbe(const aTryIterationsPerMTUProbeSize:TRNLUInt32=5;const aMTUProbeInterval:TRNLUInt64=100);
      public
       property Address:PRNLAddress read fPointerToAddress;
      published
       property ReferenceCounter:TRNLUInt32 read fReferenceCounter write fReferenceCounter;
       property LocalPeerID:TRNLID read fLocalPeerID;
       property RemotePeerID:TRNLID read fRemotePeerID;
       property Host:TRNLHost read fHost;
       property RemoteHostSalt:TRNLUInt64 read fRemoteHostSalt write fRemoteHostSalt;
       property Channels:TRNLPeerChannelList read fChannels;
       property CountChannels:TRNLSizeInt read GetCountChannels write SetCountChannels;
       property RemoteIncomingBandwidthLimit:TRNLUInt32 read fRemoteIncomingBandwidthLimit;
       property RemoteOutgoingBandwidthLimit:TRNLUInt32 read fRemoteOutgoingBandwidthLimit;
       property IncomingBandwidthRate:TRNLUInt32 read GetIncomingBandwidthRate;
       property OutgoingBandwidthRate:TRNLUInt32 read GetOutgoingBandwidthRate;
     end;

     PRNLHostAddressFamilyWorkMode=^TRNLHostAddressFamilyWorkMode;
     TRNLHostAddressFamilyWorkMode=
      (
       RNL_HOST_ADDRESS_FAMILY_WORK_MODE_AUTOMATIC=0,
       RNL_HOST_ADDRESS_FAMILY_WORK_MODE_IPV4_ONLY=1,
       RNL_HOST_ADDRESS_FAMILY_WORK_MODE_IPV6_ONLY=2,
       RNL_HOST_ADDRESS_FAMILY_WORK_MODE_IPV4_ON_IPV6=3,
       RNL_HOST_ADDRESS_FAMILY_WORK_MODE_IPV4_AND_IPV6=4
      );

     TRNLHost=class
      private
       const HostSocketFamilies:array[0..1] of TRNLInt32=
              (
                RNL_IPV4,
                RNL_IPV6
              );
      private

       fInstance:TRNLInstance;

       fNetwork:TRNLNetwork;

       fNetworkEvent:TRNLNetworkEvent;

       fRandomGenerator:TRNLRandomGenerator;

       fCompressor:TRNLCompressor;

       fPeerLock:TCriticalSection;

       fPeerIDManager:TRNLIDManager;

       fPeerIDMap:TRNLHostPeerIDMap;

{$if defined(RNL_LINEAR_PEER_LIST)}
       fPeerList:TRNLHostPeerList;
{$else}
       fPeerList:TRNLPeerListNode;
{$ifend}

       fCountPeers:TRNLUInt32;

       fPeerToFreeList:TRNLPeerListNode;

       fEventQueue:TRNLHostEventQueue;

       fAddress:TRNLAddress;

       fPointerToAddress:PRNLAddress;

       fAllowIncomingConnections:boolean;

       fChannelTypes:TRNLPeerChannelTypes;

       fMaximumCountPeers:TRNLUInt32;

       fMaximumCountChannels:TRNLUInt32;

       fIncomingBandwidthLimit:TRNLUInt32;

       fOutgoingBandwidthLimit:TRNLUInt32;

       fReliableChannelBlockPacketWindowSize:TRNLUInt32;

       fReliableChannelBlockPacketWindowMask:TRNLUInt32;

       fMaximumMessageSize:TRNLSizeUInt;

       fReceiveBufferSize:TRNLUInt32;

       fSendBufferSize:TRNLUInt32;

       fMTU:TRNLSizeUInt;

       fMTUDoFragment:boolean;

       fEncryptedPacketSequenceWindowSize:TRNLUInt32;

       fEncryptedPacketSequenceWindowMask:TRNLUInt32;

       fKeepAliveWindowSize:TRNLUInt32;

       fKeepAliveWindowMask:TRNLUInt32;

       fProtocolID:TRNLUInt64;

       fSalt:TRNLUInt64;

       fLongTermPrivateKey:TRNLKey;

       fLongTermPublicKey:TRNLKey;

       fConnectionTimeout:TRNLTime;

       fPingInterval:TRNLTime;

       fPingResendTimeout:TRNLTime;

       fPendingConnectionTimeout:TRNLUInt64;

       fPendingConnectionSendTimeout:TRNLUInt64;

       fPendingConnectionSaltTimeout:TRNLUInt64;

       fPendingConnectionShortTermKeyPairTimeout:TRNLUInt64;

       fPendingConnectionChallengeTimeout:TRNLUInt64;

       fPendingConnectionNonceTimeout:TRNLUInt64;

       fPendingDisconnectionTimeout:TRNLUInt64;

       fPendingDisconnectionSendTimeout:TRNLUInt64;

       fPendingSendNewBandwidthLimitsSendTimeout:TRNLUInt64;

       fDefaultRoundTripTime:TRNLInt64;

       fMinimumRetransmissionTimeout:TRNLInt64;

       fMaximumRetransmissionTimeout:TRNLInt64;

       fMinimumRetransmissionTimeoutLimit:TRNLInt64;

       fMaximumRetransmissionTimeoutLimit:TRNLInt64;

       fRateLimiterHostAddressBurst:TRNLInt64;

       fRateLimiterHostAddressPeriod:TRNLUInt64;

       fCheckConnectionTokens:boolean;

       fCheckAuthenticationTokens:boolean;

       fOnPeerCheckConnectionToken:TRNLHostOnPeerCheckConnectionToken;

       fOnPeerCheckAuthenticationToken:TRNLHostOnPeerCheckAuthenticationToken;

       fOnPeerConnect:TRNLHostOnPeerConnect;

       fOnPeerDisconnect:TRNLHostOnPeerDisconnect;

       fOnPeerApproval:TRNLHostOnPeerApproval;

       fOnPeerDenial:TRNLHostOnPeerDenial;

       fOnPeerBandwidthLimits:TRNLHostOnPeerBandwidthLimits;

       fOnPeerMTU:TRNLHostOnPeerMTU;

       fOnPeerReceive:TRNLHostOnPeerReceive;

       fSockets:TRNLHostSockets;

       fSocketFamilies:TRNLHostSocketFamilies;

       fTime:TRNLTime;

       fNextPeerEventTime:TRNLTime;

       fReceiveBuffer:TRNLPacketBuffer;

       fReceivedBufferLength:TRNLInt32;

       fReceivedAddress:TRNLAddress;

       fTotalReceivedData:TRNLUInt64;

       fTotalReceivedPackets:TRNLUInt64;

       fConnectionChallengeDifficultyLevel:TRNLUInt32;

       fConnectionAttemptsPerSecondChallengeDifficultyFactor:TRNLUInt32;

       fConnectionCandidateHashTable:PRNLConnectionCandidateHashTable;

       fConnectionKnownCandidateHostAddressHashTable:PRNLConnectionKnownCandidateHostAddressHashTable;

       fConnectionAttemptDeltaTime:TRNLTime;
       fConnectionAttemptLastTime:TRNLTime;
       fConnectionAttemptHasLastTime:boolean;

       fConnectionAttemptHistoryDeltaTimes:array[0..RNL_CONNECTION_ATTEMPT_SIZE-1] of TRNLUInt64;
       fConnectionAttemptHistoryTimePoints:array[0..RNL_CONNECTION_ATTEMPT_SIZE-1] of TRNLTIme;

       fConnectionAttemptHistoryReadIndex:TRNLUInt32;
       fConnectionAttemptHistoryWriteIndex:TRNLUInt32;

       fConnectionAttemptsPerSecond:TRNLUInt32;

       fIncomingBandwidthRateTracker:TRNLBandwidthRateTracker;

       fOutgoingBandwidthRateTracker:TRNLBandwidthRateTracker;

       fOutgoingBandwidthRateLimiter:TRNLBandwidthRateLimiter;

       fCompressionBuffer:TRNLPacketBuffer;

       fOutgoingPacketBuffer:TRNLOutgoingPacketBuffer;

       function GetInterruptible:boolean;
       procedure SetInterruptible(const aInterruptible:boolean);

       procedure ClearPeerToFreeList;

       procedure SetReliableChannelBlockPacketWindowSize(const aReliableChannelBlockPacketWindowSize:TRNLUInt32);

       procedure BroadcastNewBandwidthLimits;

       procedure SetIncomingBandwidthLimit(const aIncomingBandwidthLimit:TRNLUInt32);

       procedure SetOutgoingBandwidthLimit(const aOutgoingBandwidthLimit:TRNLUInt32);

       function GetIncomingBandwidthRate:TRNLUInt32;

       function GetOutgoingBandwidthRate:TRNLUInt32;

       function GetChannelType(const aIndex:TRNLUInt32):TRNLPeerChannelType;

       procedure SetChannelType(const aIndex:TRNLUInt32;const aChannelType:TRNLPeerChannelType);

       procedure SetMaximumCountChannels(const aMaximumCountChannels:TRNLUInt32);

       procedure SetMTU(const aMTU:TRNLSizeUInt);

       procedure SetConnectionTimeout(const aConnectionTimeout:TRNLTime);

       procedure SetPingInterval(const aPingInterval:TRNLTime);

       procedure SetPingResendTimeout(const aPingResendTimeout:TRNLTime);

       procedure SetEncryptedPacketSequenceWindowSize(const aEncryptedPacketSequenceWindowSize:TRNLUInt32);

       procedure SetKeepAliveWindowSize(const aKeepAliveWindowSize:TRNLUInt32);

       function SendPacket(const aAddress:TRNLAddress;const aData;const aDataLength:TRNLSizeUInt):TRNLNetworkSendResult;

       procedure ResetConnectionAttemptHistory;

       procedure UpdateConnectionAttemptHistory(const aTime:TRNLTime);

       procedure AddHandshakePacketChecksum(var aHandshakePacket);

       function VerifyHandshakePacketChecksum(var aHandshakePacket):boolean;

       procedure AcceptHandshakeConnectionRequest(const aConnectionCandidate:PRNLConnectionCandidate);

       procedure RejectHandshakeConnectionRequest(const aConnectionCandidate:PRNLConnectionCandidate);

       procedure DispatchReceivedHandshakePacketConnectionRequest(const aIncomingPacket:PRNLProtocolHandshakePacketConnectionRequest);

       procedure DispatchReceivedHandshakePacketConnectionChallengeRequest(const aIncomingPacket:PRNLProtocolHandshakePacketConnectionChallengeRequest);

       procedure DispatchReceivedHandshakePacketConnectionChallengeResponse(const aIncomingPacket:PRNLProtocolHandshakePacketConnectionChallengeResponse);

       procedure DispatchReceivedHandshakePacketConnectionAuthenticationRequest(const aIncomingPacket:PRNLProtocolHandshakePacketConnectionAuthenticationRequest);

       function AcceptHandshakePacketConnectionAuthenticationResponse(const aConnectionCandidate:PRNLConnectionCandidate):TRNLPeer;

       procedure RejectHandshakePacketConnectionAuthenticationResponse(const aConnectionCandidate:PRNLConnectionCandidate;const aDenialReason:TRNLConnectionDenialReason);

       procedure DispatchReceivedHandshakePacketConnectionAuthenticationResponse(const aIncomingPacket:PRNLProtocolHandshakePacketConnectionAuthenticationResponse);

       procedure DispatchReceivedHandshakePacketConnectionApprovalResponse(const aIncomingPacket:PRNLProtocolHandshakePacketConnectionApprovalResponse);

       procedure DispatchReceivedHandshakePacketConnectionDenialResponse(const aIncomingPacket:PRNLProtocolHandshakePacketConnectionDenialResponse);

       procedure DispatchReceivedHandshakePacketConnectionApprovalAcknowledge(const aIncomingPacket:PRNLProtocolHandshakePacketConnectionApprovalAcknowledge);

       procedure DispatchReceivedHandshakePacketData(var aPacketData;const aPacketDataLength:TRNLSizeUInt);

       procedure DispatchReceivedNormalPacketData(var aPacketData;const aPacketDataLength:TRNLSizeUInt);

       procedure DispatchReceivedPacketData(var aPacketData;const aPacketDataLength:TRNLSizeUInt);

       function DispatchPeers(var aNextTimeout:TRNLTime):boolean;

       function ReceivePackets(const aTimeout:TRNLTime):boolean;

       function DispatchIteration(const aEvent:PRNLHostEvent=nil;const aTimeout:TRNLInt64=1000):TRNLHostServiceStatus;

      public
       constructor Create(const aInstance:TRNLInstance;const aNetwork:TRNLNetwork); reintroduce;
       destructor Destroy; override;
       procedure Start(const aAddressFamilyWorkMode:TRNLHostAddressFamilyWorkMode=RNL_HOST_ADDRESS_FAMILY_WORK_MODE_IPV4_AND_IPV6);
       function Connect(const aAddress:TRNLAddress;
                        const aCountChannels:TRNLUInt32=1;
                        const aData:TRNLUInt64=0;
                        const aConnectionToken:PRNLConnectionToken=nil;
                        const aAuthenticationToken:PRNLAuthenticationToken=nil):TRNLPeer;
       procedure BroadcastMessage(const aChannel:TRNLUInt8;const aMessage:TRNLMessage);
       procedure BroadcastMessageData(const aChannel:TRNLUInt8;const aData:TRNLPointer;const aDataLength:TRNLUInt32;const aFlags:TRNLMessageFlags=[]);
       procedure BroadcastMessageBytes(const aChannel:TRNLUInt8;const aBytes:TBytes;const aFlags:TRNLMessageFlags=[]); overload;
       procedure BroadcastMessageBytes(const aChannel:TRNLUInt8;const aBytes:array of TRNLUInt8;const aFlags:TRNLMessageFlags=[]); overload;
       procedure BroadcastMessageRawByteString(const aChannel:TRNLUInt8;const aString:TRNLRawByteString;const aFlags:TRNLMessageFlags=[]);
       procedure BroadcastMessageUTF8String(const aChannel:TRNLUInt8;const aString:TRNLUTF8String;const aFlags:TRNLMessageFlags=[]);
       procedure BroadcastMessageUTF16String(const aChannel:TRNLUInt8;const aString:TRNLUTF16String;const aFlags:TRNLMessageFlags=[]);
       procedure BroadcastMessageString(const aChannel:TRNLUInt8;const aString:TRNLString;const aFlags:TRNLMessageFlags=[]);
       procedure BroadcastMessageStream(const aChannel:TRNLUInt8;const aStream:TStream;const aFlags:TRNLMessageFlags=[]);
       function Service(var aEvent:TRNLHostEvent;const aTimeout:TRNLInt64=1000):TRNLHostServiceStatus;
       function ConnectService(var aEvent:TRNLHostEvent;const aTimeout:TRNLInt64=1000):TRNLHostServiceStatus;
       function CheckEvents(var aEvent:TRNLHostEvent):boolean;
       function Flush:boolean;
       procedure Interrupt;
      public
       property Address:PRNLAddress read fPointerToAddress;
       property ProtocolID:TRNLUInt64 read fProtocolID write fProtocolID;
       property ChannelTypes[const aIndex:TRNLUInt32]:TRNLPeerChannelType read GetChannelType write SetChannelType;
       property LongTermPrivateKey:TRNLKey read fLongTermPrivateKey write fLongTermPrivateKey;
       property LongTermPublicKey:TRNLKey read fLongTermPublicKey write fLongTermPublicKey;
       property ConnectionTimeout:TRNLTime read fConnectionTimeout write SetConnectionTimeout;
       property PingInterval:TRNLTime read fPingInterval write SetPingInterval;
       property PingResendTimeout:TRNLTime read fPingResendTimeout write SetPingResendTimeout;
       property PendingConnectionTimeout:TRNLUInt64 read fPendingConnectionTimeout write fPendingConnectionTimeout;
       property PendingConnectionSendTimeout:TRNLUInt64 read fPendingConnectionSendTimeout write fPendingConnectionSendTimeout;
       property PendingConnectionSaltTimeout:TRNLUInt64 read fPendingConnectionSaltTimeout write fPendingConnectionSaltTimeout;
       property PendingConnectionShortTermKeyPairTimeout:TRNLUInt64 read fPendingConnectionShortTermKeyPairTimeout write fPendingConnectionShortTermKeyPairTimeout;
       property PendingConnectionChallengeTimeout:TRNLUInt64 read fPendingConnectionChallengeTimeout write fPendingConnectionChallengeTimeout;
       property PendingConnectionNonceTimeout:TRNLUInt64 read fPendingConnectionNonceTimeout write fPendingConnectionNonceTimeout;
       property PendingDisconnectionTimeout:TRNLUInt64 read fPendingDisconnectionTimeout write fPendingDisconnectionTimeout;
       property PendingDisconnectionSendTimeout:TRNLUInt64 read fPendingDisconnectionSendTimeout write fPendingDisconnectionSendTimeout;
       property PendingSendNewBandwidthLimitsSendTimeout:TRNLUInt64 read fPendingSendNewBandwidthLimitsSendTimeout write fPendingSendNewBandwidthLimitsSendTimeout;
       property DefaultRoundTripTime:TRNLInt64 read fDefaultRoundTripTime write fDefaultRoundTripTime;
       property MinimumRetransmissionTimeout:TRNLInt64 read fMinimumRetransmissionTimeout write fMinimumRetransmissionTimeout;
       property MaximumRetransmissionTimeout:TRNLInt64 read fMaximumRetransmissionTimeout write fMaximumRetransmissionTimeout;
       property MinimumRetransmissionTimeoutLimit:TRNLInt64 read fMinimumRetransmissionTimeoutLimit write fMinimumRetransmissionTimeoutLimit;
       property MaximumRetransmissionTimeoutLimit:TRNLInt64 read fMaximumRetransmissionTimeoutLimit write fMaximumRetransmissionTimeoutLimit;
       property RateLimiterHostAddressBurst:TRNLInt64 read fRateLimiterHostAddressBurst write fRateLimiterHostAddressBurst;
       property RateLimiterHostAddressPeriod:TRNLUInt64 read fRateLimiterHostAddressPeriod write fRateLimiterHostAddressPeriod;
{$if defined(RNL_LINEAR_PEER_LIST)}
       property Peers:TRNLHostPeerList read fPeerList;
{$else}
       property Peers:TRNLPeerListNode read fPeerList;
{$ifend}
       property CountPeers:TRNLUInt32 read fCountPeers;
      published
       property Instance:TRNLInstance read fInstance;
       property Network:TRNLNetwork read fNetwork;
       property Compressor:TRNLCompressor read fCompressor write fCompressor;
       property Interruptible:boolean read GetInterruptible write SetInterruptible;
       property AllowIncomingConnections:boolean read fAllowIncomingConnections write fAllowIncomingConnections;
       property MaximumCountPeers:TRNLUInt32 read fMaximumCountPeers write fMaximumCountPeers;
       property MaximumCountChannels:TRNLUInt32 read fMaximumCountChannels write SetMaximumCountChannels;
       property IncomingBandwidthLimit:TRNLUInt32 read fIncomingBandwidthLimit write SetIncomingBandwidthLimit;
       property OutgoingBandwidthLimit:TRNLUInt32 read fOutgoingBandwidthLimit write SetOutgoingBandwidthLimit;
       property IncomingBandwidthRate:TRNLUInt32 read GetIncomingBandwidthRate;
       property OutgoingBandwidthRate:TRNLUInt32 read GetOutgoingBandwidthRate;
       property ReliableChannelBlockPacketWindowSize:TRNLUInt32 read fReliableChannelBlockPacketWindowSize write SetReliableChannelBlockPacketWindowSize;
       property EncryptedPacketSequenceWindowSize:TRNLUInt32 read fEncryptedPacketSequenceWindowSize write SetEncryptedPacketSequenceWindowSize;
       property KeepAliveWindowSize:TRNLUInt32 read fKeepAliveWindowSize write SetKeepAliveWindowSize;
       property ReceiveBufferSize:TRNLUInt32 read fReceiveBufferSize write fReceiveBufferSize;
       property SendBufferSize:TRNLUInt32 read fSendBufferSize write fSendBufferSize;
       property MTU:TRNLSizeUInt read fMTU write SetMTU;
       property MTUDoFragment:boolean read fMTUDoFragment write fMTUDoFragment;
       property CheckConnectionTokens:boolean read fCheckConnectionTokens write fCheckConnectionTokens;
       property CheckAuthenticationTokens:boolean read fCheckAuthenticationTokens write fCheckAuthenticationTokens;
       property OnPeerCheckConnectionToken:TRNLHostOnPeerCheckConnectionToken read fOnPeerCheckConnectionToken write fOnPeerCheckConnectionToken;
       property OnPeerCheckAuthenticationToken:TRNLHostOnPeerCheckAuthenticationToken read fOnPeerCheckAuthenticationToken write fOnPeerCheckAuthenticationToken;
       property OnPeerConnect:TRNLHostOnPeerConnect read fOnPeerConnect write fOnPeerConnect;
       property OnPeerDisconnect:TRNLHostOnPeerDisconnect read fOnPeerDisconnect write fOnPeerDisconnect;
       property OnPeerApproval:TRNLHostOnPeerApproval read fOnPeerApproval write fOnPeerApproval;
       property OnPeerDenial:TRNLHostOnPeerDenial read fOnPeerDenial write fOnPeerDenial;
       property OnPeerBandwidthLimits:TRNLHostOnPeerBandwidthLimits read fOnPeerBandwidthLimits write fOnPeerBandwidthLimits;
       property OnPeerMTU:TRNLHostOnPeerMTU read fOnPeerMTU write fOnPeerMTU;
       property OnPeerReceive:TRNLHostOnPeerReceive read fOnPeerReceive write fOnPeerReceive;
     end;

     TRNLDiscoverySignature=array[0..7] of TRNLChar;

     TRNLDiscoveryServiceID=array[0..15] of TRNLChar;

     TRNLDiscoveryServerFlag=
      (
       RNL_DISCOVERY_SERVER_FLAG_IPV4=0,
       RNL_DISCOVERY_SERVER_FLAG_IPV6=1
      );

     PRNLDiscoveryServerFlag=^TRNLDiscoveryServerFlag;

     TRNLDiscoveryServerFlags=set of TRNLDiscoveryServerFlag;

     PRNLDiscoveryServerFlags=^TRNLDiscoveryServerFlags;

     TRNLDiscoveryMeta=String[255];

     TRNLDiscoveryRequestPacket=packed record
      Signature:TRNLDiscoverySignature;
      ServiceID:TRNLDiscoveryServiceID;
      ClientVersion:TRNLUInt32;
      ClientHost:TRNLHostAddress;
      ClientPort:TRNLUInt16;
      Meta:TRNLDiscoveryMeta;
     end;

     PRNLDiscoveryRequestPacket=^TRNLDiscoveryRequestPacket;

     TRNLDiscoveryAnswerPacket=packed record
      Signature:TRNLDiscoverySignature;
      ServiceID:TRNLDiscoveryServiceID;
      ServerVersion:TRNLUInt32;
      ServerHost:TRNLHostAddress;
      ServerPort:TRNLUInt16;
      Meta:TRNLDiscoveryMeta;
     end;

     PRNLDiscoveryAnswerPacket=^TRNLDiscoveryAnswerPacket;

     TRNLDiscoveryServerOnAccept=function(const aRequestPacket:TRNLDiscoveryRequestPacket):boolean of object;

     TRNLDiscoveryServer=class(TThread)
      private
       fInstance:TRNLInstance;
       fNetwork:TRNLNetwork;
       fPort:TRNLUInt16;
       fServiceID:TRNLDiscoveryServiceID;
       fServiceVersion:TRNLUInt32;
       fServiceAddressIPv4:TRNLAddress;
       fServiceAddressIPv6:TRNLAddress;
       fFlags:TRNLDiscoveryServerFlags;
       fOnAccept:TRNLDiscoveryServerOnAccept;
       fMeta:TRNLDiscoveryMeta;
       fSockets:TRNLHostSockets;
       fActiveSockets:TRNLSocketArray;
       fEvent:TRNLNetworkEvent;
       fRecvData:array[0..$ffff] of TRNLUInt8;
      protected
       procedure Execute; override;
      public
       constructor Create(const aInstance:TRNLInstance;
                          const aNetwork:TRNLNetwork;
                          const aPort:TRNLUInt16;
                          const aServiceID:TRNLDiscoveryServiceID;
                          const aServiceVersion:TRNLUInt32;
                          const aServiceAddressIPv4:TRNLAddress;
                          const aServiceAddressIPv6:TRNLAddress;
                          const aFlags:TRNLDiscoveryServerFlags;
                          const aOnAccept:TRNLDiscoveryServerOnAccept=nil;
                          const aMeta:TRNLDiscoveryMeta=''); reintroduce;
       destructor Destroy; override;
       procedure Shutdown;
      public
       property Instance:TRNLInstance read fInstance;
       property Network:TRNLNetwork read fNetwork;
       property Port:TRNLUInt16 read fPort;
       property ServiceID:TRNLDiscoveryServiceID read fServiceID;
       property ServiceVersion:TRNLUInt32 read fServiceVersion;
       property ServiceAddressIPv4:TRNLAddress read fServiceAddressIPv4;
       property ServiceAddressIPv6:TRNLAddress read fServiceAddressIPv6;
       property Flags:TRNLDiscoveryServerFlags read fFlags;
     end;

     TRNLDiscoveryService=record
      Address:TRNLAddress;
      ServiceVersion:TRNLUInt32;
      Meta:TRNLDiscoveryMeta;
     end;

     PRNLDiscoveryService=^TRNLDiscoveryService;

     TRNLDiscoveryServices=array of TRNLDiscoveryService;

     TRNLDiscoveryClient=class
      public
       class function Discover(const aInstance:TRNLInstance;
                               const aNetwork:TRNLNetwork;
                               const aPort:TRNLUInt16;
                               const aMulticastIPV4Address:TRNLAddress;
                               const aMulticastIPV6Address:TRNLAddress;
                               const aServiceID:TRNLDiscoveryServiceID;
                               const aServiceVersion:TRNLUInt32;
                               const aMeta:TRNLDiscoveryMeta='';
                               const aMaximumServers:TRNLInt32=1;
                               const aTimeOut:TRNLInt32=1000):TRNLDiscoveryServices; static;
     end;

{$ifdef RNLWorkInProgress}
     TRNLTCPToUDPBridge=class;

     TRNLTCPToUDPBridgeClient=class(TThread)
      private
       fBridge:TRNLTCPToUDPBridge;
       fClientSocket:TRNLSocket;
       fEvent:TRNLNetworkEvent;
      protected
       procedure Execute; override;
      public
       constructor Create(const aBridge:TRNLTCPToUDPBridge;const aClientSocket:TRNLSocket); reintroduce;
       destructor Destroy; override;
     end;

     TRNLTCPToUDPBridge=class(TThread)
      private
       fInstance:TRNLInstance;
       fNetwork:TRNLRealNetwork;
       fAddress:TRNLAddress;
       fPointerToAddress:PRNLAddress;
       fAddressFamilies:TRNLAddressFamily;
       fTargetAddress:TRNLAddress;
       fPointerToTargetAddress:PRNLAddress;
       fBackLog:TRNLInt32;
       fStarted:boolean;
       fEvent:TRNLNetworkEvent;
       fSockets:TRNLHostSockets;
       fClients:TThreadList;
      protected
       procedure Execute; override;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Start; reintroduce;
       procedure Stop; reintroduce;
      public
       property Address:PRNLAddress read fPointerToAddress;
       property AddressFamilies:TRNLAddressFamily read fAddressFamilies write fAddressFamilies;
       property TargetAddress:PRNLAddress read fPointerToTargetAddress;
       property BackLog:TRNLInt32 read fBackLog write fBackLog;
     end;
{$endif}

const RNL_ADDRESS_EMPTY:TRNLAddress=(Host:(Addr:(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));ScopeID:0;Port:0);
      RNL_ADDRESS_NONE:TRNLAddress=(Host:(Addr:(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));ScopeID:0;Port:0);

      RNL_HOST_NONE:TRNLHostAddress=(Addr:(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
      RNL_HOST_ANY_INIT:TRNLHostAddress=(Addr:(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
      RNL_HOST_ANY:TRNLHostAddress=(Addr:(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
      RNL_HOST_IPV4_LOCALHOST:TRNLHostAddress=(Addr:(0,0,0,0,0,0,0,0,0,0,255,255,127,0,0,1));
      RNL_IPV4MAPPED_PREFIX_INIT:TRNLHostAddress=(Addr:(0,0,0,0,0,0,0,0,0,0,255,255,0,0,0,0));
      RNL_IPV4MAPPED_PREFIX:TRNLHostAddress=(Addr:(0,0,0,0,0,0,0,0,0,0,255,255,0,0,0,0));
      RNL_HOST_BROADCAST_INIT:TRNLHostAddress=(Addr:(0,0,0,0,0,0,0,0,0,0,255,255,255,255,255,255));
      RNL_HOST_BROADCAST_:TRNLHostAddress=(Addr:(0,0,0,0,0,0,0,0,0,0,255,255,255,255,255,255));

{$ifdef Unix}
      RNL_INVALID_SOCKET=-1;
{$else}
      RNL_INVALID_SOCKET=TRNLSocket(not(0));
{$endif}

      RNL_SOCKET_NULL={$ifdef Unix}-1{$else}RNL_INVALID_SOCKET{$endif};

      RNL_HOST_EVENT_EMPTY:TRNLHostEvent=
       (
        Type_:RNL_HOST_EVENT_TYPE_NONE;
        Peer:nil;
        Message:nil;
        Data:0;
       );

{$ifndef fpc}
function BSRDWord(Value:TRNLUInt32):TRNLUInt32; {$if defined(CPU386) or defined(CPUX64)}assembler; register;{$ifend}
function SARLongint(Value,Shift:TRNLInt32):TRNLInt32;
function SARInt64(Value:TRNLInt64;Shift:TRNLInt32):TRNLInt64;
{$endif}

implementation

const RNLDiscoveryRequestSignature:TRNLDiscoverySignature=('R','N','L','D','R',#0,#0,#0);

      RNLDiscoveryAnswerSignature:TRNLDiscoverySignature=('R','N','L','D','A',#0,#0,#0);

      RNLProtocolHandshakePacketHeaderSignature:TRNLProtocolHandshakePacketHeaderSignature=
       (TRNLUInt8(ord('R')),
        TRNLUInt8(ord('N')),
        TRNLUInt8(ord('L')),
        $ff
       );

      RNLProtocolHandshakePacketSizes:array[TRNLProtocolHandshakePacketType] of TRNLSizeUInt=
       (
        SizeOf(TRNLProtocolHandshakePacketHeader),
        SizeOf(TRNLProtocolHandshakePacketConnectionRequest),
        SizeOf(TRNLProtocolHandshakePacketConnectionChallengeRequest),
        SizeOf(TRNLProtocolHandshakePacketConnectionChallengeResponse),
        SizeOf(TRNLProtocolHandshakePacketConnectionAuthenticationRequest),
        SizeOf(TRNLProtocolHandshakePacketConnectionAuthenticationResponse),
        SizeOf(TRNLProtocolHandshakePacketConnectionApprovalResponse),
        SizeOf(TRNLProtocolHandshakePacketConnectionDenialResponse),
        SizeOf(TRNLProtocolHandshakePacketConnectionApprovalAcknowledge),
        SizeOf(TRNLProtocolHandshakePacketConnectionDenialAcknowledge)
       );

      RNLProtocolBlockPacketSizes:array[TRNLProtocolBlockPacketType] of TRNLSizeUInt=
       (
        SizeOf(TRNLProtocolBlockPacketHeader),
        SizeOf(TRNLProtocolBlockPacketPing),
        SizeOf(TRNLProtocolBlockPacketPong),
        SizeOf(TRNLProtocolBlockPacketDisconnect),
        SizeOf(TRNLProtocolBlockPacketDisconnectAcknowledgement),
        SizeOf(TRNLProtocolBlockPacketBandwidthLimits),
        SizeOf(TRNLProtocolBlockPacketBandwidthLimitsAcknowledgement),
        SizeOf(TRNLProtocolBlockPacketMTUProbe),
        SizeOf(TRNLProtocolBlockPacketChannel)
       );

      RNLNormalPacketPeerStates=
       [
        RNL_PEER_STATE_CONNECTED,
        RNL_PEER_STATE_DISCONNECT_LATER,
        RNL_PEER_STATE_DISCONNECTING,
        RNL_PEER_STATE_DISCONNECTION_ACKNOWLEDGING,
        RNL_PEER_STATE_DISCONNECTION_PENDING
       ];

      RNLKnownCommonMTUSizes:array[0..19] of TRNLUInt16=
       (
        576,  // Internet Path MTU for X.25 (RFC 879)
        1024, // 1/64 of maximum
        1280, // IPv6 path MTU
        1452, // DS-Lite over PPPoE, Ethernet v2 MTU (1500) - PPPoE header (8) - IPv6 header (40)
        1492, // Ethernet with LLC and SNAP, PPPoE (RFC 1042)
        1493, // Minimum Ethernet Jumbo Frame MTU (1501 - 9198) - PPPoE header (8)
        1500, // Ethernet II (RFC 1191)
        1501, // Minimum Ethernet Jumbo Frame MTU (1501 - 9198)
        2048, // 1/32 of maximum
        2304, // WLAN (802.11), the maximum MSDU size is 2304 before encryption. WEP will add 8 bytes, WPA-TKIP 20 bytes, and WPA2-CCMP 16 bytes.
        4096, // 1/16 of maximum
        4352, // FDDI
        4464, // Token ring
        7981, // WLAN
        8192, // 1/8 of maximum
        9190, // Maximum Ethernet Jumbo Frame MTU (1501 - 9198) - PPPoE header (8)
        9198, // Maximum Ethernet Jumbo Frame MTU (1501 - 9198)
        16384, // 1/4 of maximum
        32768, // Half maximum
        65535 // Maximum minus one (minus one because 0..65535 range of the 16-bit unsigned integer data fields here)
       );

      OneDiv32Bit=1.0/TRNLInt64($100000000);

{$ifndef BIG_ENDIAN}
      MultiplyDeBruijnBytePosition:array[0..31] of TRNLUInt8=(0,0,3,0,3,1,3,0,
                                                              3,2,2,1,3,2,0,1,
                                                              3,3,1,2,2,2,2,0,
                                                              3,1,2,0,1,0,1,1);
{$endif}

{$if defined(RNL_DEBUG)}
{$if defined(fpc) and defined(Android)}
const ANDROID_LOG_UNKNOWN=0;
      ANDROID_LOG_DEFAULT=1;
      ANDROID_LOG_VERBOSE=2;
      ANDROID_LOG_DEBUG=3;
      ANDROID_LOG_INFO=4;
      ANDROID_LOG_WARN=5;
      ANDROID_LOG_ERROR=6;
      ANDROID_LOG_FATAL=7;
      ANDROID_LOG_SILENT=8;

      LibLogName='liblog.so';

function __android_log_write(prio:cint;tag,text:PAnsiChar):cint; cdecl; external LibLogName name '__android_log_write';
function LOGI(prio:longint;tag,text:PAnsiChar):cint; cdecl; varargs; external LibLogName name '__android_log_print';
{$ifend}

function RNLDebugFormatFloat(const aValue:TRNLDouble;const aWidth,aWidth2:TRNLInt32):string;
{$ifdef NextGen}
begin
 Str(aValue:aWidth:aWidth2,result);
end;
{$else}
var TemporaryString:ShortString;
begin
 Str(aValue:aWidth:aWidth2,TemporaryString);
 result:=TemporaryString;
end;
{$endif}

procedure RNLDebugOutputString(const aMessage:string);
{$if defined(fpc) and defined(Android)}
const Tag:TRNLRawByteString='RNL';
var TemporaryString:TRNLRawByteString;
begin
 TemporaryString:=aMessage;
 __android_log_write(ANDROID_LOG_INFO, PAnsiChar(Tag), PAnsiChar(TemporaryString));
end;
{$elseif defined(Posix) and defined(Android)}
var TemporaryString:TRNLRawByteString;
begin
 TemporaryString:=aMessage;
 Androidapi.Log.LOGI({$ifdef NextGen}MarshaledAString{$else}PAnsiChar{$endif}(TemporaryString));
end;
{$elseif defined(Windows) or defined(Win32) or defined(Win64)}
var TemporaryString:WideString;
begin
 TemporaryString:=aMessage;
 OutputDebugStringW(PWideChar(TemporaryString));
end;
{$else)}
begin
 WriteLn(aMessage);
end;
{$ifend}

{$ifend}

class function TRNLMath.RoundUpToPowerOfTwo32(Value:TRNLUInt32):TRNLUInt32;
begin
 dec(Value);
 Value:=Value or (Value shr 1);
 Value:=Value or (Value shr 2);
 Value:=Value or (Value shr 4);
 Value:=Value or (Value shr 8);
 Value:=Value or (Value shr 16);
 result:=Value+1;
end;

class function TRNLMath.RoundUpToPowerOfTwo64(Value:TRNLUInt64):TRNLUInt64;
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

class function TRNLMath.RoundUpToPowerOfTwo(Value:TRNLPtrUInt):TRNLPtrUInt;
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

{$ifndef fpc}

function BSRDWord(Value:TRNLUInt32):TRNLUInt32;{$if defined(CPU386)}assembler; register;
asm
 bsr eax,eax
 jnz @Done
 mov eax,255
@Done:
end;
{$elseif defined(CPUX64)}assembler; register; {$ifdef fpc}nostackframe;{$endif}
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
{$else}
const BSRDebruijn32Multiplicator=TRNLUInt32($07c4acdd);
      BSRDebruijn32Shift=27;
      BSRDebruijn32Mask=31;
      BSRDebruijn32Table:array[0..31] of TRNLInt32=(0,9,1,10,13,21,2,29,11,14,16,18,22,25,3,30,8,12,20,28,15,17,24,7,19,27,23,6,26,5,4,31);
begin
 if Value=0 then begin
  result:=255;
 end else begin
  Value:=Value or (Value shr 1);
  Value:=Value or (Value shr 2);
  Value:=Value or (Value shr 4);
  Value:=Value or (Value shr 8);
  Value:=Value or (Value shr 16);
  result:=BSRDebruijn32Table[((Value*BSRDebruijn32Multiplicator) shr BSRDebruijn32Shift) and BSRDebruijn32Mask];
 end;
end;
{$ifend}

function SARLongint(Value,Shift:TRNLInt32):TRNLInt32;
{$if defined(CPU386)}assembler; register;
asm
 mov ecx,edx
 sar eax,cl
end;
{$elseif defined(CPUX64)}assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 // Win64 ABI: rcx, rdx, r8, r9, rest on stack (scratch registers: rax, rcx, rdx, r8, r9, r10, r11)
 mov eax,ecx
 mov ecx,edx
{$else}
 // SystemV ABI: rdi, rsi, rdx, rcx, r8, r9, rest on stack (scratch registers: rax, rdi, rsi, rdx, rcx, r8, r9, r10, r11)
 mov eax,edi
 mov ecx,esi
{$endif}
 sar eax,cl
end;
{$elseif defined(CPUARM) and defined(fpc)}assembler; register;
asm
 mov r0,r0,asr R1
end {$ifdef fpc}['r0','R1']{$endif};
{$else}
begin
 Shift:=Shift and 31;
 result:=(TRNLUInt32(Value) shr Shift) or (TRNLUInt32(TRNLInt32(TRNLUInt32(-TRNLUInt32(TRNLUInt32(Value) shr 31)) and TRNLUInt32(-TRNLUInt32(ord(Shift<>0) and 1)))) shl (32-Shift));
end;
{$ifend}

function SARInt64(Value:TRNLInt64;Shift:TRNLInt32):TRNLInt64;
{$if defined(CPU386)}assembler; register;
asm
 mov ecx,eax
 and cl,63
 cmp cl,32
 jc @Full
  mov eax,dword ptr [Value+4]
  sar eax,cl
  bt eax,31
  sbb edx,eax
  jmp @Done
 @Full:
  mov eax,dword ptr [Value+0]
  mov edx,dword ptr [Value+4]
  shrd eax,edx,cl
  sar edx,cl
@Done:
 mov dword ptr [result+0],eax
 mov dword ptr [result+4],edx
end;
{$elseif defined(CPUX64)}assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 // Win64 ABI: rcx, rdx, r8, r9, rest on stack (scratch registers: rax, rcx, rdx, r8, r9, r10, r11)
 mov rax,rcx
 mov rcx,rdx
{$else}
 // SystemV ABI: rdi, rsi, rdx, rcx, r8, r9, rest on stack (scratch registers: rax, rdi, rsi, rdx, rcx, r8, r9, r10, r11)
 mov rax,rdi
 mov rcx,rsi
{$endif}
 sar rax,cl
end;
{$else}
begin
 Shift:=Shift and 63;
 result:=(TRNLInt64(Value) shr Shift) or (TRNLInt64(TRNLInt64(TRNLInt64(-TRNLInt64(TRNLInt64(Value) shr 63)) and TRNLInt64(-TRNLInt64(ord(Shift<>0) and 1)))) shl (63-Shift));
end;
{$ifend}

{$endif}

{$if defined(CPU386) or defined(CPUX64)}
function x86_rdrand_support:boolean; assembler; register;
asm
{$ifdef CPUX64}
 push rbx
{$else}
 push ebx
{$endif}
 xor eax,eax
 cpuid
 cmp ebx,$756e6547
 je @CheckIntel
 cmp ebx,$68747541
 je @CheckAMD
 jmp @NoSupport
@CheckIntel:
 cmp ecx,$6c65746e
 jne @NoSupport
 cmp edx,$49656e69
 jne @NoSupport
 jmp @HasSupport
@CheckAMD:
 cmp ecx,$444d4163
 jne @NoSupport
 cmp edx,$69746e65
 jne @NoSupport
@HasSupport:
 mov eax,1
 cpuid
 mov eax,ecx
 shr eax,30
 and eax,1
 jmp @Done
@NoSupport:
 xor eax,eax
@Done:
{$ifdef CPUX64}
 pop rbx
{$else}
 pop ebx
{$endif}
end;

function x86_rdrand_ui32:TRNLUInt32; assembler; register;
asm
 mov ecx,16
@Loop:
 db $0f,$c7,$f0 // rdrand eax
 jc @Done
 dec ecx
 jnz @Loop
@Done:
end;

function x86_rdrand_ui64:TRNLUInt64; assembler; register;
asm
{$if defined(CPUX64)}
 mov ecx,16
@Loop:
 db $48,$0f,$c7,$f0 // rdrand rax
 jc @Done
 dec ecx
 jnz @Loop
@Done:
{$else}
 call x86_rdrand_ui32
 mov edx,eax
 push edx
 call x86_rdrand_ui32
 pop edx
{$ifend}
end;

function x86_rdseed_support:boolean; assembler; register;
asm
 xor eax,eax
 cpuid
 cmp ebx,$756e6547
 jne @NoSupport
 cmp edx,$49656e69
 jne @NoSupport
 cmp ecx,$6c65746e
 jne @NoSupport
 mov eax,7
 cpuid
 mov eax,ebx
 shr eax,18
 and eax,1
 jmp @Done
@NoSupport:
 xor eax,eax
@Done:
end;

function x86_rdseed_ui32:TRNLUInt32; assembler; register;
asm
 mov ecx,16
@Loop:
 db $0f,$c7,$f8 // rdseed eax
 jc @Done
 dec ecx
 jnz @Loop
@Done:
end;

function x86_rdseed_ui64:TRNLUInt64; assembler; register;
asm
{$if defined(CPUX64)}
 mov ecx,16
@Loop:
 db $48,$0f,$c7,$f8 // rdseed rax
 jc @Done
 dec ecx
 jnz @Loop
@Done:
{$else}
 call x86_rdseed_ui32
 mov edx,eax
 push edx
 call x86_rdseed_ui32
 push eax
{$ifend}
end;
{$ifend}

function PopFirstOneBitUInt32(var Value:TRNLUInt32):TRNLUInt32;{$ifdef cpu386}assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
 push esi
 mov esi,Value
 xor eax,eax
 bsf ecx,dword ptr [esi]
 jz @Found
 xor eax,ecx
 xor edx,edx
 inc edx
 shl edx,cl
 xor dword ptr [esi],edx
 @Found:
 pop esi
end;
{$else}
{$ifdef cpux64}assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifdef win64}
 mov eax,dword ptr [rcx]
{$else}
 mov eax,dword ptr [rdi]
{$endif}
 lea edx,[eax-1]
 bsf eax,eax
{$ifdef win64}
 and dword ptr [rcx],edx
{$else}
 and dword ptr [rdi],edx
{$endif}
end;
{$else}
begin
{$ifdef fpc}
 result:=BSFDWord(Value);
{$else}
 result:=(Value and (-Value))-1;
 result:=result-((result shr 1) and $55555555);
 result:=(result and $33333333)+((result shr 2) and $33333333);
 result:=(result+(result shr 4)) and $0f0f0f0f;
 inc(result,result shr 8);
 inc(result,result shr 16);
 result:=result and $1f;
{$endif}
 Value:=Value and (Value-1);
end;
{$endif}
{$endif}

function BitScanForwardUInt32(Value:TRNLUInt32):TRNLUInt32;{$ifdef cpu386}assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
 bsf eax,eax
 jnz @NotFound
 mov eax,255
@NotFound:
end;
{$else}
{$ifdef cpux64}assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .NOFRAME
{$endif}
{$ifdef win64}
 bsf eax,ecx
{$else}
 bsf eax,edi
{$endif}
 jnz @NotFound
 mov eax,255
@NotFound:
end;
{$else}
{$ifndef fpc}
const Debruijn32Multiplicator=TRNLUInt32($077cb531);
      Debruijn32Shift=27;
      Debruijn32Mask=31;
      Debruijn32Table:array[0..31] of TRNLInt32=(0,1,28,2,29,14,24,3,30,22,20,15,25,17,4,8,31,27,13,23,21,19,16,7,26,12,18,6,11,5,10,9);
{$endif}
begin
 if Value=0 then begin
  result:=255;
 end else begin
{$ifdef fpc}
  result:=BsfDWord(Value);
{$else}
  result:=Debruijn32Table[(((Value and not (Value-1))*Debruijn32Multiplicator) shr Debruijn32Shift) and Debruijn32Mask];
{$endif}
 end;
end;
{$endif}
{$endif}

function RawBitScanForwardUInt32(Value:TRNLUInt32):TRNLUInt32;{$ifdef cpu386}assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
 bsf eax,eax
end;
{$else}
{$ifdef cpux64}assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .NOFRAME
{$endif}
{$ifdef win64}
 bsf eax,ecx
{$else}
 bsf eax,edi
{$endif}
end;
{$else}
{$ifdef fpc}inline;
begin
 result:=BsfDWord(Value);
end;
{$else}
const Debruijn32Multiplicator=TRNLUInt32($077cb531);
      Debruijn32Shift=27;
      Debruijn32Mask=31;
      Debruijn32Table:array[0..31] of TRNLInt32=(0,1,28,2,29,14,24,3,30,22,20,15,25,17,4,8,31,27,13,23,21,19,16,7,26,12,18,6,11,5,10,9);
begin
 result:=Debruijn32Table[(((Value and not (Value-1))*Debruijn32Multiplicator) shr Debruijn32Shift) and Debruijn32Mask];
end;
{$endif}
{$endif}
{$endif}

procedure BytewiseMemoryMove(const aSource;var aDestination;const aLength:TRNLSizeUInt);{$if defined(CPU386)} register; assembler; {$ifdef fpc}nostackframe;{$endif}
asm
 push esi
 push edi
 mov esi,eax
 mov edi,edx
 cld
 rep movsb
 pop edi
 pop esi
end;
{$elseif defined(CPUX64)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 // Win64 ABI: rcx, rdx, r8, r9, rest on stack (scratch registers: rax, rcx, rdx, r8, r9, r10, r11)
 push rdi
 push rsi
 mov rsi,rcx
 mov rdi,rdx
 mov rcx,r8
{$else}
 // SystemV ABI: rdi, rsi, rdx, rcx, r8, r9, rest on stack (scratch registers: rax, rdi, rsi, rdx, rcx, r8, r9, r10, r11)
 xchg rsi,rdi
 mov rcx,rdx
{$endif}
 cld
 rep movsb
{$ifdef win64}
 pop rsi
 pop rdi
{$endif}
end;
{$else}
var Index:TRNLSizeUInt;
    Source,Destination:PRNLUInt8Array;
begin
 if aLength>0 then begin
  Source:=TRNLPointer(@aSource);
  Destination:=TRNLPointer(@aDestination);
  for Index:=0 to aLength-1 do begin
   Destination^[Index]:=Source^[Index];
  end;
 end;
end;
{$ifend}

procedure RLELikeSideEffectAwareMemoryMove(const aSource;var aDestination;const aLength:TRNLSizeUInt);
begin
 if aLength>0 then begin
  if ({%H-}TRNLSizeUInt(TRNLPointer(@aSource))+aLength)<={%H-}TRNLSizeUInt(TRNLPointer(@aDestination)) then begin
   // Non-overlapping, so we an use an optimized memory move function
   Move(aSource,aDestination,aLength);
  end else begin
   // Overlapping, so we must do copy byte-wise for to get the free RLE-like side-effect included
   BytewiseMemoryMove(aSource,aDestination,aLength);
  end;
 end;
end;

class function TRNLEndianness.Swap16(const aValue:TRNLUInt16):TRNLUInt16;
{$if defined(CPU386)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
 xchg al,ah
end;
{$elseif defined(CPUX64)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 movzx eax,cx
{$else}
 movzx eax,di
{$endif}
 xchg al,ah
end;
{$else}
begin
 result:=(aValue shr 8) or (aValue shl 8);
end;
{$ifend}

class function TRNLEndianness.Swap32(const aValue:TRNLUInt32):TRNLUInt32;
{$if defined(CPU386)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
 bswap eax
end;
{$elseif defined(CPUX64)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 mov eax,ecx
{$else}
 mov eax,edi
{$endif}
 bswap eax
end;
{$else}
begin
 result:=(aValue shr 24) or
         ((aValue and TRNLUInt32($00ff0000)) shr 8) or
         ((aValue and TRNLUInt32($0000ff00)) shl 8) or
         (aValue shl 24);
end;
{$ifend}

class function TRNLEndianness.Swap64(const aValue:TRNLUInt64):TRNLUInt64;
{$if defined(CPU386)}assembler;
asm
 mov edx,dword ptr [aValue+0]
 mov eax,dword ptr [aValue+4]
 bswap eax
 bswap edx
end;
{$elseif defined(CPUX64)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 mov rax,rcx
{$else}
 mov rax,rdi
{$endif}
 bswap rax
end;
{$else}
begin
 result:=(aValue shr 32) or (aValue shl 32);
 result:=((result and TRNLUInt64($ffff0000ffff0000)) shr 16) or
         ((result and TRNLUInt64($0000ffff0000ffff)) shl 16);
 result:=((result and TRNLUInt64($ff00ff00ff00ff00)) shr 8) or
         ((result and TRNLUInt64($00ff00ff00ff00ff)) shl 8);
end;
{$ifend}

class function TRNLEndianness.HostToNet16(const aValue:TRNLUInt16):TRNLUInt16;
{$if defined(CPU386)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
 xchg al,ah
end;
{$elseif defined(CPUX64)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 mov al,ch
 mov ah,cl
{$else}
 mov ax,di
 xchg al,ah
{$endif}
end;
{$elseif defined(BIG_ENDIAN)}
begin
 result:=aValue;
end;
{$else}
begin
 result:=(aValue shr 8) or (aValue shl 8);
end;
{$ifend}

class function TRNLEndianness.HostToNet32(const aValue:TRNLUInt32):TRNLUInt32;
{$if defined(CPU386)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
 bswap eax
end;
{$elseif defined(CPUX64)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 mov eax,ecx
{$else}
 mov eax,edi
{$endif}
 bswap eax
end;
{$elseif defined(BIG_ENDIAN)}
begin
 result:=aValue;
end;
{$else}
begin
 result:=(aValue shr 24) or
         ((aValue and TRNLUInt32($00ff0000)) shr 8) or
         ((aValue and TRNLUInt32($0000ff00)) shl 8) or
         (aValue shl 24);
end;
{$ifend}

class function TRNLEndianness.HostToNet64(const aValue:TRNLUInt64):TRNLUInt64;
{$if defined(CPU386)}assembler;
asm
 mov edx,dword ptr [aValue+0]
 mov eax,dword ptr [aValue+4]
 bswap eax
 bswap edx
end;
{$elseif defined(CPUX64)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 mov rax,rcx
{$else}
 mov rax,rdi
{$endif}
 bswap rax
end;
{$elseif defined(BIG_ENDIAN)}
begin
 result:=aValue;
end;
{$else}
begin
 result:=(aValue shr 32) or (aValue shl 32);
 result:=((result and TRNLUInt64($ffff0000ffff0000)) shr 16) or
         ((result and TRNLUInt64($0000ffff0000ffff)) shl 16);
 result:=((result and TRNLUInt64($ff00ff00ff00ff00)) shr 8) or
         ((result and TRNLUInt64($00ff00ff00ff00ff)) shl 8);
end;
{$ifend}

class function TRNLEndianness.NetToHost16(const aValue:TRNLUInt16):TRNLUInt16;
{$if defined(CPU386)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
 xchg al,ah
end;
{$elseif defined(CPUX64)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 mov al,ch
 mov ah,cl
{$else}
 mov ax,di
 xchg al,ah
{$endif}
end;
{$elseif defined(BIG_ENDIAN)}
begin
 result:=aValue;
end;
{$else}
begin
 result:=(aValue shr 8) or (aValue shl 8);
end;
{$ifend}

class function TRNLEndianness.NetToHost32(const aValue:TRNLUInt32):TRNLUInt32;
{$if defined(CPU386)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
 bswap eax
end;
{$elseif defined(CPUX64)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 mov eax,ecx
{$else}
 mov eax,edi
{$endif}
 bswap eax
end;
{$elseif defined(BIG_ENDIAN)}
begin
 result:=aValue;
end;
{$else}
begin
 result:=(aValue shr 24) or
         ((aValue and TRNLUInt32($00ff0000)) shr 8) or
         ((aValue and TRNLUInt32($0000ff00)) shl 8) or
         (aValue shl 24);
end;
{$ifend}

class function TRNLEndianness.NetToHost64(const aValue:TRNLUInt64):TRNLUInt64;
{$if defined(CPU386)}assembler;
asm
 mov edx,dword ptr [aValue+0]
 mov eax,dword ptr [aValue+4]
 bswap eax
 bswap edx
end;
{$elseif defined(CPUX64)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 mov rax,rcx
{$else}
 mov rax,rdi
{$endif}
 bswap rax
end;
{$elseif defined(BIG_ENDIAN)}
begin
 result:=aValue;
end;
{$else}
begin
 result:=(aValue shr 32) or (aValue shl 32);
 result:=((result and TRNLUInt64($ffff0000ffff0000)) shr 16) or
         ((result and TRNLUInt64($0000ffff0000ffff)) shl 16);
 result:=((result and TRNLUInt64($ff00ff00ff00ff00)) shr 8) or
         ((result and TRNLUInt64($00ff00ff00ff00ff)) shl 8);
end;
{$ifend}

class function TRNLEndianness.HostToLittleEndian16(const aValue:TRNLUInt16):TRNLUInt16;
{$if not defined(BIG_ENDIAN)}
begin
 result:=aValue;
end;
{$else}
begin
 result:=(aValue shr 8) or (aValue shl 8);
end;
{$ifend}

class function TRNLEndianness.HostToLittleEndian32(const aValue:TRNLUInt32):TRNLUInt32;
{$if not defined(BIG_ENDIAN)}
begin
 result:=aValue;
end;
{$else}
begin
 result:=(aValue shr 24) or
         ((aValue and TRNLUInt32($00ff0000)) shr 8) or
         ((aValue and TRNLUInt32($0000ff00)) shl 8) or
         (aValue shl 24);
end;
{$ifend}

class function TRNLEndianness.HostToLittleEndian64(const aValue:TRNLUInt64):TRNLUInt64;
{$if not defined(BIG_ENDIAN)}
begin
 result:=aValue;
end;
{$else}
begin
 result:=(aValue shr 32) or (aValue shl 32);
 result:=((result and TRNLUInt64($ffff0000ffff0000)) shr 16) or
         ((result and TRNLUInt64($0000ffff0000ffff)) shl 16);
 result:=((result and TRNLUInt64($ff00ff00ff00ff00)) shr 8) or
         ((result and TRNLUInt64($00ff00ff00ff00ff)) shl 8);
end;
{$ifend}

class function TRNLEndianness.LittleEndianToHost16(const aValue:TRNLUInt16):TRNLUInt16;
{$if not defined(BIG_ENDIAN)}
begin
 result:=aValue;
end;
{$else}
begin
 result:=(aValue shr 8) or (aValue shl 8);
end;
{$ifend}

class function TRNLEndianness.LittleEndianToHost32(const aValue:TRNLUInt32):TRNLUInt32;
{$if not defined(BIG_ENDIAN)}
begin
 result:=aValue;
end;
{$else}
begin
 result:=(aValue shr 24) or
         ((aValue and TRNLUInt32($00ff0000)) shr 8) or
         ((aValue and TRNLUInt32($0000ff00)) shl 8) or
         (aValue shl 24);
end;
{$ifend}

class function TRNLEndianness.LittleEndianToHost64(const aValue:TRNLUInt64):TRNLUInt64;
{$if not defined(BIG_ENDIAN)}
begin
 result:=aValue;
end;
{$else}
begin
 result:=(aValue shr 32) or (aValue shl 32);
 result:=((result and TRNLUInt64($ffff0000ffff0000)) shr 16) or
         ((result and TRNLUInt64($0000ffff0000ffff)) shl 16);
 result:=((result and TRNLUInt64($ff00ff00ff00ff00)) shr 8) or
         ((result and TRNLUInt64($00ff00ff00ff00ff)) shl 8);
end;
{$ifend}

class function TRNLMemoryAccess.LoadBigEndianInt8(const aLocation):TRNLInt8;
begin
 result:=TRNLInt8(aLocation);
end;

class function TRNLMemoryAccess.LoadBigEndianUInt8(const aLocation):TRNLUInt8;
begin
 result:=TRNLUInt8(aLocation);
end;

class function TRNLMemoryAccess.LoadBigEndianInt16(const aLocation):TRNLInt16;
{$if defined(CPU386)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
 movzx eax,word ptr [eax]
 xchg al,ah
end;
{$elseif defined(CPUX64)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 movzx eax,word ptr [rcx]
{$else}
 movzx eax,word ptr [rdi]
{$endif}
 xchg al,ah
end;
{$else}
begin
 result:=TRNLInt16(aLocation);
{$ifndef BIG_ENDIAN}
 result:=TRNLInt16(TRNLUInt16((TRNLUInt16(result) shr 8) or
                              (TRNLUInt16(result) shl 8)));
{$endif}
end;
{$ifend}

class function TRNLMemoryAccess.LoadBigEndianUInt16(const aLocation):TRNLUInt16;
{$if defined(CPU386)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
 movzx eax,word ptr [eax]
 xchg al,ah
end;
{$elseif defined(CPUX64)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 movzx eax,word ptr [rcx]
{$else}
 movzx eax,word ptr [rdi]
{$endif}
 xchg al,ah
end;
{$else}
begin
 result:=TRNLUInt16(aLocation);
{$ifndef BIG_ENDIAN}
 result:=TRNLUInt16(TRNLUInt16((TRNLUInt16(result) shr 8) or
                               (TRNLUInt16(result) shl 8)));
{$endif}
end;
{$ifend}

class function TRNLMemoryAccess.LoadBigEndianInt32(const aLocation):TRNLInt32;
{$if defined(CPU386)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
 mov eax,dword ptr [eax]
 bswap eax
end;
{$elseif defined(CPUX64)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 mov eax,dword ptr [rcx]
{$else}
 mov eax,dword ptr [rdi]
{$endif}
 bswap eax
end;
{$else}
begin
 result:=TRNLInt32(aLocation);
{$ifndef BIG_ENDIAN}
 result:=TRNLInt32(TRNLUInt32((TRNLUInt32(result) shr 24) or
                              ((TRNLUInt32(result) and TRNLUInt32($00ff0000)) shr 8) or
                              ((TRNLUInt32(result) and TRNLUInt32($0000ff00)) shl 8) or
                              (TRNLUInt32(result) shl 24)));
{$endif}
end;
{$ifend}

class function TRNLMemoryAccess.LoadBigEndianUInt32(const aLocation):TRNLUInt32;
{$if defined(CPU386)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
 mov eax,dword ptr [eax]
 bswap eax
end;
{$elseif defined(CPUX64)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 mov eax,dword ptr [rcx]
{$else}
 mov eax,dword ptr [rdi]
{$endif}
 bswap eax
end;
{$else}
begin
 result:=TRNLInt32(aLocation);
{$ifndef BIG_ENDIAN}
 result:=TRNLUInt32(TRNLUInt32((TRNLUInt32(result) shr 24) or
                               ((TRNLUInt32(result) and TRNLUInt32($00ff0000)) shr 8) or
                               ((TRNLUInt32(result) and TRNLUInt32($0000ff00)) shl 8) or
                               (TRNLUInt32(result) shl 24)));
{$endif}
end;
{$ifend}

class function TRNLMemoryAccess.LoadBigEndianInt64(const aLocation):TRNLInt64;
{$if defined(CPU386)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
 mov edx,dword ptr [eax]
 mov eax,dword ptr [eax+4]
 bswap eax
 bswap edx
end;
{$elseif defined(CPUX64)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 mov rax,qword ptr [rcx]
{$else}
 mov rax,qword ptr [rdi]
{$endif}
 bswap rax
end;
{$else}
begin
 result:=TRNLInt64(aLocation);
{$ifndef BIG_ENDIAN}
 result:=TRNLInt64(TRNLUInt64((TRNLUInt64(result) shr 32) or (TRNLUInt64(result) shl 32)));
 result:=TRNLInt64(TRNLUInt64(((TRNLUInt64(result) and TRNLUInt64($ffff0000ffff0000)) shr 16) or
                              ((TRNLUInt64(result) and TRNLUInt64($0000ffff0000ffff)) shl 16)));
 result:=TRNLInt64(TRNLUInt64(((TRNLUInt64(result) and TRNLUInt64($ff00ff00ff00ff00)) shr 8) or
                              ((TRNLUInt64(result) and TRNLUInt64($00ff00ff00ff00ff)) shl 8)));
{$endif}
end;
{$ifend}

class function TRNLMemoryAccess.LoadBigEndianUInt64(const aLocation):TRNLUInt64;
{$if defined(CPU386)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
 mov edx,dword ptr [eax]
 mov eax,dword ptr [eax+4]
 bswap eax
 bswap edx
end;
{$elseif defined(CPUX64)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 mov rax,qword ptr [rcx]
{$else}
 mov rax,qword ptr [rdi]
{$endif}
 bswap rax
end;
{$else}
begin
 result:=TRNLUInt64(aLocation);
{$ifndef BIG_ENDIAN}
 result:=TRNLUInt64(TRNLUInt64((TRNLUInt64(result) shr 32) or (TRNLUInt64(result) shl 32)));
 result:=TRNLUInt64(TRNLUInt64(((TRNLUInt64(result) and TRNLUInt64($ffff0000ffff0000)) shr 16) or
                               ((TRNLUInt64(result) and TRNLUInt64($0000ffff0000ffff)) shl 16)));
 result:=TRNLUInt64(TRNLUInt64(((TRNLUInt64(result) and TRNLUInt64($ff00ff00ff00ff00)) shr 8) or
                               ((TRNLUInt64(result) and TRNLUInt64($00ff00ff00ff00ff)) shl 8)));
{$endif}
end;
{$ifend}

class function TRNLMemoryAccess.LoadLittleEndianInt8(const aLocation):TRNLInt8;
begin
 result:=TRNLInt8(aLocation);
end;

class function TRNLMemoryAccess.LoadLittleEndianUInt8(const aLocation):TRNLUInt8;
begin
 result:=TRNLUInt8(aLocation);
end;

class function TRNLMemoryAccess.LoadLittleEndianInt16(const aLocation):TRNLInt16;
begin
 result:=TRNLInt16(aLocation);
{$ifdef BIG_ENDIAN}
 result:=TRNLInt16(TRNLUInt16((TRNLUInt16(result) shr 8) or
                              (TRNLUInt16(result) shl 8)));
{$endif}
end;

class function TRNLMemoryAccess.LoadLittleEndianUInt16(const aLocation):TRNLUInt16;
begin
 result:=TRNLUInt16(aLocation);
{$ifdef BIG_ENDIAN}
 result:=TRNLUInt16(TRNLUInt16((TRNLUInt16(result) shr 8) or
                               (TRNLUInt16(result) shl 8)));
{$endif}
end;

class function TRNLMemoryAccess.LoadLittleEndianUInt24(const aLocation):TRNLUInt32;
begin
 result:=(TRNLUInt32(PRNLUInt8Array(TRNLPointer(@aLocation))^[0]) shl 0) or
         (TRNLUInt32(PRNLUInt8Array(TRNLPointer(@aLocation))^[1]) shl 8) or
         (TRNLUInt32(PRNLUInt8Array(TRNLPointer(@aLocation))^[2]) shl 16);
end;

class function TRNLMemoryAccess.LoadLittleEndianInt32(const aLocation):TRNLInt32;
begin
 result:=TRNLInt32(aLocation);
{$ifdef BIG_ENDIAN}
 result:=TRNLInt32(TRNLUInt32((TRNLUInt32(result) shr 24) or
                              ((TRNLUInt32(result) and TRNLUInt32($00ff0000)) shr 8) or
                              ((TRNLUInt32(result) and TRNLUInt32($0000ff00)) shl 8) or
                              (TRNLUInt32(result) shl 24)));
{$endif}
end;

class function TRNLMemoryAccess.LoadLittleEndianUInt32(const aLocation):TRNLUInt32;
begin
 result:=TRNLUInt32(aLocation);
{$ifdef BIG_ENDIAN}
 result:=TRNLUInt32(TRNLUInt32((TRNLUInt32(result) shr 24) or
                               ((TRNLUInt32(result) and TRNLUInt32($00ff0000)) shr 8) or
                               ((TRNLUInt32(result) and TRNLUInt32($0000ff00)) shl 8) or
                               (TRNLUInt32(result) shl 24)));
{$endif}
end;

class function TRNLMemoryAccess.LoadLittleEndianInt64(const aLocation):TRNLInt64;
begin
 result:=TRNLInt64(aLocation);
{$ifdef BIG_ENDIAN}
 result:=TRNLInt64(TRNLUInt64((TRNLUInt64(result) shr 32) or (TRNLUInt64(result) shl 32)));
 result:=TRNLInt64(TRNLUInt64(((TRNLUInt64(result) and TRNLUInt64($ffff0000ffff0000)) shr 16) or
                              ((TRNLUInt64(result) and TRNLUInt64($0000ffff0000ffff)) shl 16)));
 result:=TRNLInt64(TRNLUInt64(((TRNLUInt64(result) and TRNLUInt64($ff00ff00ff00ff00)) shr 8) or
                              ((TRNLUInt64(result) and TRNLUInt64($00ff00ff00ff00ff)) shl 8)));
{$endif}
end;

class function TRNLMemoryAccess.LoadLittleEndianUInt64(const aLocation):TRNLUInt64;
begin
 result:=TRNLUInt64(aLocation);
{$ifdef BIG_ENDIAN}
 result:=TRNLUInt64(TRNLUInt64((TRNLUInt64(result) shr 32) or (TRNLUInt64(result) shl 32)));
 result:=TRNLUInt64(TRNLUInt64(((TRNLUInt64(result) and TRNLUInt64($ffff0000ffff0000)) shr 16) or
                               ((TRNLUInt64(result) and TRNLUInt64($0000ffff0000ffff)) shl 16)));
 result:=TRNLUInt64(TRNLUInt64(((TRNLUInt64(result) and TRNLUInt64($ff00ff00ff00ff00)) shr 8) or
                               ((TRNLUInt64(result) and TRNLUInt64($00ff00ff00ff00ff)) shl 8)));
{$endif}
end;

class procedure TRNLMemoryAccess.StoreBigEndianInt8(out aLocation;const aValue:TRNLInt8);
begin
 TRNLInt8(aLocation):=aValue;
end;

class procedure TRNLMemoryAccess.StoreBigEndianUInt8(out aLocation;const aValue:TRNLUInt8);
begin
 TRNLUInt8(aLocation):=aValue;
end;

class procedure TRNLMemoryAccess.StoreBigEndianInt16(out aLocation;const aValue:TRNLInt16);
{$if defined(CPU386)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
 xchg dl,dh
 mov word ptr [eax],dx
end;
{$elseif defined(CPUX64)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 xchg dl,dh
 mov word ptr [rcx],dx
{$else}
 mov ax,si
 xchg al,ah
 mov word ptr [rdi],ax
{$endif}
end;
{$elseif not defined(BIG_ENDIAN)}
begin
 TRNLInt16(aLocation):=TRNLInt16(TRNLUInt16((TRNLUInt16(aValue) shr 8) or
                                            (TRNLUInt16(aValue) shl 8)));
end;
{$else}
begin
 TRNLInt16(aLocation):=aValue;
end;
{$ifend}

class procedure TRNLMemoryAccess.StoreBigEndianUInt16(out aLocation;const aValue:TRNLUInt16);
{$if defined(CPU386)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
 xchg dl,dh
 mov word ptr [eax],dx
end;
{$elseif defined(CPUX64)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 xchg dl,dh
 mov word ptr [rcx],dx
{$else}
 mov ax,si
 xchg al,ah
 mov word ptr [rdi],ax
{$endif}
end;
{$elseif not defined(BIG_ENDIAN)}
begin
 TRNLUInt16(aLocation):=TRNLUInt16(TRNLUInt16((TRNLUInt16(aValue) shr 8) or
                                              (TRNLUInt16(aValue) shl 8)));
end;
{$else}
begin
 TRNLUInt16(aLocation):=aValue;
end;
{$ifend}

class procedure TRNLMemoryAccess.StoreBigEndianInt32(out aLocation;const aValue:TRNLInt32);
{$if defined(CPU386)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
 bswap edx
 mov dword ptr [eax],edx
end;
{$elseif defined(CPUX64)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 bswap edx
 mov dword ptr [rcx],edx
{$else}
 bswap esi
 mov dword ptr [rdi],esi
{$endif}
end;
{$elseif not defined(BIG_ENDIAN)}
begin
 TRNLInt32(aLocation):=TRNLInt32(TRNLUInt32((TRNLUInt32(aValue) shr 24) or
                                            ((TRNLUInt32(aValue) and TRNLUInt32($00ff0000)) shr 8) or
                                            ((TRNLUInt32(aValue) and TRNLUInt32($0000ff00)) shl 8) or
                                            (TRNLUInt32(aValue) shl 24)));
end;
{$else}
begin
 TRNLInt32(aLocation):=aValue;
end;
{$ifend}

class procedure TRNLMemoryAccess.StoreBigEndianUInt32(out aLocation;const aValue:TRNLUInt32);
{$if defined(CPU386)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
 bswap edx
 mov dword ptr [eax],edx
end;
{$elseif defined(CPUX64)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 bswap edx
 mov dword ptr [rcx],edx
{$else}
 bswap esi
 mov dword ptr [rdi],esi
{$endif}
end;
{$elseif not defined(BIG_ENDIAN)}
begin
 TRNLUInt32(aLocation):=TRNLUInt32(TRNLUInt32((TRNLUInt32(aValue) shr 24) or
                                              ((TRNLUInt32(aValue) and TRNLUInt32($00ff0000)) shr 8) or
                                              ((TRNLUInt32(aValue) and TRNLUInt32($0000ff00)) shl 8) or
                                              (TRNLUInt32(aValue) shl 24)));
end;
{$else}
begin
 TRNLUInt32(aLocation):=aValue;
end;
{$ifend}

class procedure TRNLMemoryAccess.StoreBigEndianInt64(out aLocation;const aValue:TRNLInt64);
{$if defined(CPU386)}assembler;
asm
 mov edx,dword ptr [aValue]
 mov ecx,dword ptr [aValue+4]
 bswap ecx
 bswap edx
 mov dword ptr [eax],ecx
 mov dword ptr [eax+4],edx
end;
{$elseif defined(CPUX64)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 bswap rdx
 mov qword ptr [rcx],rdx
{$else}
 bswap rsi
 mov qword ptr [rdi],rsi
{$endif}
end;
{$elseif not defined(BIG_ENDIAN)}
var Value:TRNLUInt64;
begin
 Value:=(TRNLUInt64(aValue) shr 32) or (TRNLUInt64(aValue) shl 32);
 Value:=((Value and TRNLUInt64($ffff0000ffff0000)) shr 16) or
        ((Value and TRNLUInt64($0000ffff0000ffff)) shl 16);
 TRNLUInt64(aLocation):=((Value and TRNLUInt64($ff00ff00ff00ff00)) shr 8) or
                        ((Value and TRNLUInt64($00ff00ff00ff00ff)) shl 8);
end;
{$else}
begin
 TRNLInt64(aLocation):=aValue;
end;
{$ifend}

class procedure TRNLMemoryAccess.StoreBigEndianUInt64(out aLocation;const aValue:TRNLUInt64);
{$if defined(CPU386)}assembler;
asm
 mov edx,dword ptr [aValue]
 mov ecx,dword ptr [aValue+4]
 bswap ecx
 bswap edx
 mov dword ptr [eax],ecx
 mov dword ptr [eax+4],edx
end;
{$elseif defined(CPUX64)}assembler;{$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$ifdef Win64}
 bswap rdx
 mov qword ptr [rcx],rdx
{$else}
 bswap rsi
 mov qword ptr [rdi],rsi
{$endif}
end;
{$elseif not defined(BIG_ENDIAN)}
var Value:TRNLUInt64;
begin
 Value:=(aValue shr 32) or (aValue shl 32);
 Value:=((Value and TRNLUInt64($ffff0000ffff0000)) shr 16) or
        ((Value and TRNLUInt64($0000ffff0000ffff)) shl 16);
 TRNLUInt64(aLocation):=((Value and TRNLUInt64($ff00ff00ff00ff00)) shr 8) or
                        ((Value and TRNLUInt64($00ff00ff00ff00ff)) shl 8);
end;
{$else}
begin
 TRNLUInt64(aLocation):=aValue;
end;
{$ifend}

class procedure TRNLMemoryAccess.StoreLittleEndianInt8(out aLocation;const aValue:TRNLInt8);
begin
 TRNLInt8(aLocation):=aValue;
end;

class procedure TRNLMemoryAccess.StoreLittleEndianUInt8(out aLocation;const aValue:TRNLUInt8);
begin
 TRNLUInt8(aLocation):=aValue;
end;

class procedure TRNLMemoryAccess.StoreLittleEndianInt16(out aLocation;const aValue:TRNLInt16);
{$ifdef BIG_ENDIAN}
begin
 TRNLInt16(aLocation):=TRNLInt16(TRNLUInt16((TRNLUInt16(aValue) shr 8) or
                                            (TRNLUInt16(aValue) shl 8)));
end;
{$else}
begin
 TRNLInt16(aLocation):=aValue;
end;
{$endif}

class procedure TRNLMemoryAccess.StoreLittleEndianUInt16(out aLocation;const aValue:TRNLUInt16);
{$ifdef BIG_ENDIAN}
begin
 TRNLUInt16(aLocation):=TRNLUInt16(TRNLUInt16((TRNLUInt16(aValue) shr 8) or
                                              (TRNLUInt16(aValue) shl 8)));
end;
{$else}
begin
 TRNLUInt16(aLocation):=aValue;
end;
{$endif}

class procedure TRNLMemoryAccess.StoreLittleEndianInt32(out aLocation;const aValue:TRNLInt32);
{$ifdef BIG_ENDIAN}
begin
 TRNLInt32(aLocation):=TRNLInt32(TRNLUInt32((TRNLUInt32(aValue) shr 24) or
                                            ((TRNLUInt32(aValue) and TRNLUInt32($00ff0000)) shr 8) or
                                            ((TRNLUInt32(aValue) and TRNLUInt32($0000ff00)) shl 8) or
                                            (TRNLUInt32(aValue) shl 24)));
end;
{$else}
begin
 TRNLInt32(aLocation):=aValue;
end;
{$endif}

class procedure TRNLMemoryAccess.StoreLittleEndianUInt32(out aLocation;const aValue:TRNLUInt32);
{$ifdef BIG_ENDIAN}
begin
 TRNLUInt32(aLocation):=TRNLUInt32(TRNLUInt32((TRNLUInt32(aValue) shr 24) or
                                              ((TRNLUInt32(aValue) and TRNLUInt32($00ff0000)) shr 8) or
                                              ((TRNLUInt32(aValue) and TRNLUInt32($0000ff00)) shl 8) or
                                              (TRNLUInt32(aValue) shl 24)));
end;
{$else}
begin
 TRNLUInt32(aLocation):=aValue;
end;
{$endif}

class procedure TRNLMemoryAccess.StoreLittleEndianInt64(out aLocation;const aValue:TRNLInt64);
{$ifdef BIG_ENDIAN}
var Value:TRNLUInt64;
begin
 Value:=(TRNLUInt64(aValue) shr 32) or (TRNLUInt64(aValue) shl 32);
 Value:=((Value and TRNLUInt64($ffff0000ffff0000)) shr 16) or
        ((Value and TRNLUInt64($0000ffff0000ffff)) shl 16);
 TRNLUInt64(aLocation):=((Value and TRNLUInt64($ff00ff00ff00ff00)) shr 8) or
                        ((Value and TRNLUInt64($00ff00ff00ff00ff)) shl 8);
end;
{$else}
begin
 TRNLInt64(aLocation):=aValue;
end;
{$endif}

class procedure TRNLMemoryAccess.StoreLittleEndianUInt64(out aLocation;const aValue:TRNLUInt64);
{$ifdef BIG_ENDIAN}
var Value:TRNLUInt64;
begin
 Value:=(aValue shr 32) or (aValue shl 32);
 Value:=((Value and TRNLUInt64($ffff0000ffff0000)) shr 16) or
        ((Value and TRNLUInt64($0000ffff0000ffff)) shl 16);
 TRNLUInt64(aLocation):=((Value and TRNLUInt64($ff00ff00ff00ff00)) shr 8) or
                        ((Value and TRNLUInt64($00ff00ff00ff00ff)) shl 8);
end;
{$else}
begin
 TRNLUInt64(aLocation):=aValue;
end;
{$endif}

class function TRNLMemory.SecureIsEqual(const aLocationA,aLocationB;const aSize:TRNLSizeUInt):boolean;
var Index,Position:TRNLSizeUInt;
    Temporary:TRNLUInt32;
begin
 Temporary:=0;
 for Index:=1 to aSize do begin
  Position:=Index-1;
  Temporary:=Temporary or (PRNLUInt8Array(TRNLPointer(@aLocationA))^[Position] xor PRNLUInt8Array(TRNLPointer(@aLocationB))^[Position]);
 end;
 result:=Temporary=0;
end;

class function TRNLMemory.SecureIsNotEqual(const aLocationA,aLocationB;const aSize:TRNLSizeUInt):boolean;
var Index,Position:TRNLSizeUInt;
    Temporary:TRNLUInt32;
begin
 Temporary:=0;
 for Index:=1 to aSize do begin
  Position:=Index-1;
  Temporary:=Temporary or (PRNLUInt8Array(TRNLPointer(@aLocationA))^[Position] xor PRNLUInt8Array(TRNLPointer(@aLocationB))^[Position]);
 end;
 result:=Temporary<>0;
end;

class function TRNLMemory.SecureIsZero(const aLocation;const aSize:TRNLSizeUInt):boolean;
var Index:TRNLSizeUInt;
    Temporary:TRNLUInt32;
begin
 Temporary:=0;
 for Index:=1 to aSize do begin
  Temporary:=Temporary or PRNLUInt8Array(TRNLPointer(@aLocation))^[Index-1];
 end;
 result:=Temporary=0;
end;

class function TRNLMemory.SecureIsNonZero(const aLocation;const aSize:TRNLSizeUInt):boolean;
var Index:TRNLSizeUInt;
    Temporary:TRNLUInt32;
begin
 Temporary:=0;
 for Index:=1 to aSize do begin
  Temporary:=Temporary or PRNLUInt8Array(TRNLPointer(@aLocation))^[Index-1];
 end;
 result:=Temporary<>0;
end;

class procedure TRNLTypedSort<T>.IntroSort(const pItems:TRNLPointer;const pLeft,pRight:TRNLInt32;const pCompareFunc:TRNLTypedSortCompareFunction);
type TItem=T;
     PItem=^TItem;
     TItemArray=array[0..65535] of TItem;
     PItemArray=^TItemArray;
     TStackItem=record
      Left,Right,Depth:TRNLInt32;
     end;
     PStackItem=^TStackItem;
var Left,Right,Depth,i,j,Middle,Size,Parent,Child,Pivot,iA,iB,iC:TRNLInt32;
    StackItem:PStackItem;
    Stack:array[0..31] of TStackItem;
    Temp:T;
begin
 if pLeft<pRight then begin
  StackItem:=@Stack[0];
  StackItem^.Left:=pLeft;
  StackItem^.Right:=pRight;
  StackItem^.Depth:=BSRDWord((pRight-pLeft)+1) shl 1;
  inc(StackItem);
  while {%H-}TRNLPtrUInt(TRNLPointer(StackItem))>TRNLPtrUInt(TRNLPointer(@Stack[0])) do begin
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
           (pCompareFunc(PItemArray(pItems)^[iA],PItemArray(pItems)^[iC])>0) do begin
      Temp:=PItemArray(pItems)^[iA];
      PItemArray(pItems)^[iA]:=PItemArray(pItems)^[iC];
      PItemArray(pItems)^[iC]:=Temp;
      dec(iA);
      dec(iC);
     end;
     iA:=iB;
     inc(iB);
    end;
   end else begin
    if (Depth=0) or ({%H-}TRNLPtrUInt(TRNLPointer(StackItem))>=TRNLPtrUInt(TRNLPointer(@Stack[high(Stack)-1]))) then begin
     // Heap sort
     i:=Size div 2;
     repeat
      if i>0 then begin
       dec(i);
      end else begin
       dec(Size);
       if Size>0 then begin
        Temp:=PItemArray(pItems)^[Left+Size];
        PItemArray(pItems)^[Left+Size]:=PItemArray(pItems)^[Left];
        PItemArray(pItems)^[Left]:=Temp;
       end else begin
        break;
       end;
      end;
      Parent:=i;
      repeat
       Child:=(Parent*2)+1;
       if Child<Size then begin
        if (Child<(Size-1)) and (pCompareFunc(PItemArray(pItems)^[Left+Child],PItemArray(pItems)^[Left+Child+1])<0) then begin
         inc(Child);
        end;
        if pCompareFunc(PItemArray(pItems)^[Left+Parent],PItemArray(pItems)^[Left+Child])<0 then begin
         Temp:=PItemArray(pItems)^[Left+Parent];
         PItemArray(pItems)^[Left+Parent]:=PItemArray(pItems)^[Left+Child];
         PItemArray(pItems)^[Left+Child]:=Temp;
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
      if pCompareFunc(PItemArray(pItems)^[Left],PItemArray(pItems)^[Middle])>0 then begin
       Temp:=PItemArray(pItems)^[Left];
       PItemArray(pItems)^[Left]:=PItemArray(pItems)^[Middle];
       PItemArray(pItems)^[Middle]:=Temp;
      end;
      if pCompareFunc(PItemArray(pItems)^[Left],PItemArray(pItems)^[Right])>0 then begin
       Temp:=PItemArray(pItems)^[Left];
       PItemArray(pItems)^[Left]:=PItemArray(pItems)^[Right];
       PItemArray(pItems)^[Right]:=Temp;
      end;
      if pCompareFunc(PItemArray(pItems)^[Middle],PItemArray(pItems)^[Right])>0 then begin
       Temp:=PItemArray(pItems)^[Middle];
       PItemArray(pItems)^[Middle]:=PItemArray(pItems)^[Right];
       PItemArray(pItems)^[Right]:=Temp;
      end;
     end;
     Pivot:=Middle;
     i:=Left;
     j:=Right;
     repeat
      while (i<Right) and (pCompareFunc(PItemArray(pItems)^[i],PItemArray(pItems)^[Pivot])<0) do begin
       inc(i);
      end;
      while (j>=i) and (pCompareFunc(PItemArray(pItems)^[j],PItemArray(pItems)^[Pivot])>0) do begin
       dec(j);
      end;
      if i>j then begin
       break;
      end else begin
       if i<>j then begin
        Temp:=PItemArray(pItems)^[i];
        PItemArray(pItems)^[i]:=PItemArray(pItems)^[j];
        PItemArray(pItems)^[j]:=Temp;
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

class function TRNLHashUtils.Hash32(const aLocation;const aSize:TRNLSizeUInt):TRNLUInt32;
var b:PRNLUInt8;
    Remaining:TRNLSizeUInt;
    h,i:TRNLUInt32;
begin
 result:=2166136261;
 Remaining:=aSize;
 h:=Remaining;
 if Remaining>0 then begin
  b:=@aLocation;
  while Remaining>3 do begin
   i:=TRNLUInt32(TRNLPointer(b)^);
   h:=(h xor i) xor $2e63823a;
   inc(h,(h shl 15) or (h shr (32-15)));
   dec(h,(h shl 9) or (h shr (32-9)));
   inc(h,(h shl 4) or (h shr (32-4)));
   dec(h,(h shl 1) or (h shr (32-1)));
   h:=h xor (h shl 2) or (h shr (32-2));
   result:=result xor i;
   inc(result,(result shl 1)+(result shl 4)+(result shl 7)+(result shl 8)+(result shl 24));
   inc(b,4);
   dec(Remaining,4);
  end;
  if Remaining>1 then begin
   i:=TRNLUInt16(TRNLPointer(b)^);
   h:=(h xor i) xor $2e63823a;
   inc(h,(h shl 15) or (h shr (32-15)));
   dec(h,(h shl 9) or (h shr (32-9)));
   inc(h,(h shl 4) or (h shr (32-4)));
   dec(h,(h shl 1) or (h shr (32-1)));
   h:=h xor (h shl 2) or (h shr (32-2));
   result:=result xor i;
   inc(result,(result shl 1)+(result shl 4)+(result shl 7)+(result shl 8)+(result shl 24));
   inc(b,2);
   dec(Remaining,2);
  end;
  if Remaining>0 then begin
   i:=TRNLUInt8(b^);
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

class operator TRNLTime.Implicit(const a:TRNLUInt64):TRNLTime;
begin
 result.fValue:=a;
end;

class operator TRNLTime.Explicit(const a:TRNLUInt64):TRNLTime;
begin
 result.fValue:=a;
end;

class operator TRNLTime.Implicit(const a:TRNLTime):TRNLUInt64;
begin
 result:=a.fValue;
end;

class operator TRNLTime.Explicit(const a:TRNLTime):TRNLUInt64;
begin
 result:=a.fValue;
end;

class operator TRNLTime.Equal(const a,b:TRNLTime):boolean;
begin
 result:=a.fValue=b.fValue;
end;

class operator TRNLTime.NotEqual(const a,b:TRNLTime):boolean;
begin
 result:=a.fValue<>b.fValue;
end;

class operator TRNLTime.GreaterThan(const a,b:TRNLTime):boolean;
var t:TRNLInt64;
begin
 t:=b.fValue-a.fValue;
 result:=(t<0) or (t>=RNL_TIME_OVERFLOW);
end;

class operator TRNLTime.GreaterThanOrEqual(const a,b:TRNLTime):boolean;
var t:TRNLInt64;
begin
 t:=a.fValue-b.fValue;
 result:=not ((t<0) or (t>=RNL_TIME_OVERFLOW));
end;

class operator TRNLTime.LessThan(const a,b:TRNLTime):boolean;
var t:TRNLInt64;
begin
 t:=a.fValue-b.fValue;
 result:=(t<0) or (t>=RNL_TIME_OVERFLOW);
end;

class operator TRNLTime.LessThanOrEqual(const a,b:TRNLTime):boolean;
var t:TRNLInt64;
begin
 t:=b.fValue-a.fValue;
 result:=not ((t<0) or (t>=RNL_TIME_OVERFLOW));
end;

class operator TRNLTime.Inc(const a:TRNLTime):TRNLTime;
begin
 result.fValue:=a.fValue+1;
end;

class operator TRNLTime.Dec(const a:TRNLTime):TRNLTime;
begin
 result.fValue:=a.fValue-1;
end;

class operator TRNLTime.LogicalNot(const a:TRNLTime):TRNLTime;
begin
 result.fValue:=not a.fValue;
end;

class operator TRNLTime.Add(const a,b:TRNLTime):TRNLTime;
begin
 result.fValue:=a.fValue+b.fValue;
end;

class operator TRNLTime.Add(const a:TRNLTime;const b:TRNLUInt64):TRNLUInt64;
begin
 result:=a.fValue+b;
end;

class operator TRNLTime.Add(const a:TRNLUInt64;const b:TRNLTime):TRNLUInt64;
begin
 result:=a+b.fValue;
end;

class operator TRNLTime.Subtract(const a,b:TRNLTime):TRNLTime;
begin
 result.fValue:=a.fValue-b.fValue;
end;

class operator TRNLTime.Subtract(const a:TRNLTime;const b:TRNLUInt64):TRNLUInt64;
begin
 result:=a.fValue-b;
end;

class operator TRNLTime.Subtract(const a:TRNLUInt64;const b:TRNLTime):TRNLUInt64;
begin
 result:=a-b.fValue;
end;

class operator TRNLTime.Multiply(const a,b:TRNLTime):TRNLTime;
begin
 result.fValue:=a.fValue*b.fValue;
end;

class operator TRNLTime.Multiply(const a:TRNLTime;const b:TRNLUInt64):TRNLUInt64;
begin
 result:=a.fValue*b;
end;

class operator TRNLTime.Multiply(const a:TRNLUInt64;const b:TRNLTime):TRNLUInt64;
begin
 result:=a*b.fValue;
end;

class operator TRNLTime.Divide(const a,b:TRNLTime):TRNLTime;
begin
 result.fValue:=a.fValue div b.fValue;
end;

class operator TRNLTime.Divide(const a:TRNLTime;const b:TRNLUInt64):TRNLUInt64;
begin
 result:=a.fValue div b;
end;

class operator TRNLTime.Divide(const a:TRNLUInt64;const b:TRNLTime):TRNLUInt64;
begin
 result:=a div b.fValue;
end;

class operator TRNLTime.IntDivide(const a,b:TRNLTime):TRNLTime;
begin
 result.fValue:=a.fValue div b.fValue;
end;

class operator TRNLTime.IntDivide(const a:TRNLTime;const b:TRNLUInt64):TRNLUInt64;
begin
 result:=a.fValue div b;
end;

class operator TRNLTime.IntDivide(const a:TRNLUInt64;const b:TRNLTime):TRNLUInt64;
begin
 result:=a div b.fValue;
end;

class operator TRNLTime.Modulus(const a,b:TRNLTime):TRNLTime;
begin
 result.fValue:=a.fValue mod b.fValue;
end;

class operator TRNLTime.LeftShift(const a:TRNLTime;const b:TRNLInt32):TRNLTime;
begin
 result.fValue:=a.fValue shl b;
end;

class operator TRNLTime.RightShift(const a:TRNLTime;const b:TRNLInt32):TRNLTime;
begin
 result.fValue:=a.fValue shr b;
end;

class operator TRNLTime.BitwiseAnd(const a,b:TRNLTime):TRNLTime;
begin
 result.fValue:=a.fValue and b.fValue;
end;

class operator TRNLTime.BitwiseOr(const a,b:TRNLTime):TRNLTime;
begin
 result.fValue:=a.fValue or b.fValue;
end;

class operator TRNLTime.BitwiseXor(const a,b:TRNLTime):TRNLTime;
begin
 result.fValue:=a.fValue xor b.fValue;
end;

class operator TRNLTime.Negative(const a:TRNLTime):TRNLTime;
begin
 result.fValue:=-a.fValue;
end;

class operator TRNLTime.Positive(const a:TRNLTime):TRNLTime;
begin
 result.fValue:=a.fValue;
end;

class function TRNLTime.RelativeDifference(const a,b:TRNLTime):TRNLInt64;
begin
 result:=TRNLInt64(TRNLUInt64(a.fValue-b.fValue));
end;

class function TRNLTime.Difference(const a,b:TRNLTime):TRNLInt64;
begin
 result:=a.fValue-b.fValue;
 if (result<0) or (result>=RNL_TIME_OVERFLOW) then begin
  result:=b.fValue-a.fValue;
 end;
end;

class function TRNLTime.Minimum(const a,b:TRNLTime):TRNLTime;
begin
 if a.fValue<b.fValue then begin
  result.fValue:=a.fValue;
 end else begin
  result.fValue:=b.fValue;
 end;
end;

class operator TRNLSequenceNumber.Implicit(const a:TRNLUInt16):TRNLSequenceNumber;
begin
 result.fValue:=a;
end;

class operator TRNLSequenceNumber.Explicit(const a:TRNLUInt16):TRNLSequenceNumber;
begin
 result.fValue:=a;
end;

class operator TRNLSequenceNumber.Implicit(const a:TRNLSequenceNumber):TRNLUInt16;
begin
 result:=a.fValue;
end;

class operator TRNLSequenceNumber.Explicit(const a:TRNLSequenceNumber):TRNLUInt16;
begin
 result:=a.fValue;
end;

class operator TRNLSequenceNumber.Equal(const a,b:TRNLSequenceNumber):boolean;
begin
 result:=a.fValue=b.fValue;
end;

class operator TRNLSequenceNumber.NotEqual(const a,b:TRNLSequenceNumber):boolean;
begin
 result:=a.fValue<>b.fValue;
end;

class operator TRNLSequenceNumber.GreaterThan(const a,b:TRNLSequenceNumber):boolean;
begin
{$if defined(CPU386) or defined(CPUX64)}
 result:=TRNLInt16(TRNLUInt16(a.fValue-b.fValue))>0;
{$else}
 result:=((((a.fValue-b.fValue)+32768) and $ffff)-32768)>0;
{$ifend}
end;

class operator TRNLSequenceNumber.GreaterThanOrEqual(const a,b:TRNLSequenceNumber):boolean;
begin
{$if defined(CPU386) or defined(CPUX64)}
 result:=TRNLInt16(TRNLUInt16(a.fValue-b.fValue))>=0;
{$else}
 result:=((((a.fValue-b.fValue)+32768) and $ffff)-32768)>=0;
{$ifend}
end;

class operator TRNLSequenceNumber.LessThan(const a,b:TRNLSequenceNumber):boolean;
begin
{$if defined(CPU386) or defined(CPUX64)}
 result:=TRNLInt16(TRNLUInt16(a.fValue-b.fValue))<0;
{$else}
 result:=((((a.fValue-b.fValue)+32768) and $ffff)-32768)<0;
{$ifend}
end;

class operator TRNLSequenceNumber.LessThanOrEqual(const a,b:TRNLSequenceNumber):boolean;
begin
{$if defined(CPU386) or defined(CPUX64)}
 result:=TRNLInt16(TRNLUInt16(a.fValue-b.fValue))<=0;
{$else}
 result:=((((a.fValue-b.fValue)+32768) and $ffff)-32768)<=0;
{$ifend}
end;

class operator TRNLSequenceNumber.Inc(const a:TRNLSequenceNumber):TRNLSequenceNumber;
begin
 result.fValue:=a.fValue+1;
end;

class operator TRNLSequenceNumber.Dec(const a:TRNLSequenceNumber):TRNLSequenceNumber;
begin
 result.fValue:=a.fValue-1;
end;

class operator TRNLSequenceNumber.LogicalNot(const a:TRNLSequenceNumber):TRNLSequenceNumber;
begin
 result.fValue:=not a.fValue;
end;

class operator TRNLSequenceNumber.Add(const a,b:TRNLSequenceNumber):TRNLSequenceNumber;
begin
 result.fValue:=a.fValue+b.fValue;
end;

class operator TRNLSequenceNumber.Add(const a:TRNLSequenceNumber;const b:TRNLUInt16):TRNLUInt16;
begin
 result:=a.fValue+b;
end;

class operator TRNLSequenceNumber.Add(const a:TRNLUInt16;const b:TRNLSequenceNumber):TRNLUInt16;
begin
 result:=a+b.fValue;
end;

class operator TRNLSequenceNumber.Subtract(const a,b:TRNLSequenceNumber):TRNLSequenceNumber;
begin
 result.fValue:=a.fValue-b.fValue;
end;

class operator TRNLSequenceNumber.Subtract(const a:TRNLSequenceNumber;const b:TRNLUInt16):TRNLUInt16;
begin
 result:=a.fValue-b;
end;

class operator TRNLSequenceNumber.Subtract(const a:TRNLUInt16;const b:TRNLSequenceNumber):TRNLUInt16;
begin
 result:=a-b.fValue;
end;

class operator TRNLSequenceNumber.Multiply(const a,b:TRNLSequenceNumber):TRNLSequenceNumber;
begin
 result.fValue:=a.fValue*b.fValue;
end;

class operator TRNLSequenceNumber.Multiply(const a:TRNLSequenceNumber;const b:TRNLUInt16):TRNLUInt16;
begin
 result:=a.fValue*b;
end;

class operator TRNLSequenceNumber.Multiply(const a:TRNLUInt16;const b:TRNLSequenceNumber):TRNLUInt16;
begin
 result:=a*b.fValue;
end;

class operator TRNLSequenceNumber.Divide(const a,b:TRNLSequenceNumber):TRNLSequenceNumber;
begin
 result.fValue:=a.fValue div b.fValue;
end;

class operator TRNLSequenceNumber.Divide(const a:TRNLSequenceNumber;const b:TRNLUInt16):TRNLUInt16;
begin
 result:=a.fValue div b;
end;

class operator TRNLSequenceNumber.Divide(const a:TRNLUInt16;const b:TRNLSequenceNumber):TRNLUInt16;
begin
 result:=a div b.fValue;
end;

class operator TRNLSequenceNumber.IntDivide(const a,b:TRNLSequenceNumber):TRNLSequenceNumber;
begin
 result.fValue:=a.fValue div b.fValue;
end;

class operator TRNLSequenceNumber.IntDivide(const a:TRNLSequenceNumber;const b:TRNLUInt16):TRNLUInt16;
begin
 result:=a.fValue div b;
end;

class operator TRNLSequenceNumber.IntDivide(const a:TRNLUInt16;const b:TRNLSequenceNumber):TRNLUInt16;
begin
 result:=a div b.fValue;
end;

class operator TRNLSequenceNumber.Modulus(const a,b:TRNLSequenceNumber):TRNLSequenceNumber;
begin
 result.fValue:=a.fValue mod b.fValue;
end;

class operator TRNLSequenceNumber.LeftShift(const a:TRNLSequenceNumber;const b:TRNLInt32):TRNLSequenceNumber;
begin
 result.fValue:=a.fValue shl b;
end;

class operator TRNLSequenceNumber.RightShift(const a:TRNLSequenceNumber;const b:TRNLInt32):TRNLSequenceNumber;
begin
 result.fValue:=a.fValue shr b;
end;

class operator TRNLSequenceNumber.BitwiseAnd(const a,b:TRNLSequenceNumber):TRNLSequenceNumber;
begin
 result.fValue:=a.fValue and b.fValue;
end;

class operator TRNLSequenceNumber.BitwiseOr(const a,b:TRNLSequenceNumber):TRNLSequenceNumber;
begin
 result.fValue:=a.fValue or b.fValue;
end;

class operator TRNLSequenceNumber.BitwiseXor(const a,b:TRNLSequenceNumber):TRNLSequenceNumber;
begin
 result.fValue:=a.fValue xor b.fValue;
end;

class operator TRNLSequenceNumber.Negative(const a:TRNLSequenceNumber):TRNLSequenceNumber;
begin
 result.fValue:=-a.fValue;
end;

class operator TRNLSequenceNumber.Positive(const a:TRNLSequenceNumber):TRNLSequenceNumber;
begin
 result.fValue:=a.fValue;
end;

class function TRNLSequenceNumber.RelativeDifference(const a,b:TRNLSequenceNumber):TRNLInt32;
begin
{$if defined(CPU386) or defined(CPUX64)}
 result:=TRNLInt16(TRNLUInt16(a.fValue-b.fValue));
{$else}
 result:=(((a.fValue-b.fValue)+32768) and $ffff)-32768;
{$ifend}
end;

class function TRNLSequenceNumber.Difference(const a,b:TRNLSequenceNumber):TRNLInt32;
begin
{$if defined(CPU386) or defined(CPUX64)}
 result:=abs(TRNLInt16(TRNLUInt16(a.fValue-b.fValue)));
{$else}
 result:=abs((((a.fValue-b.fValue)+32768) and $ffff)-32768);
{$ifend}
end;

class function TRNLSequenceNumber.Minimum(const a,b:TRNLSequenceNumber):TRNLSequenceNumber;
begin
 if a.fValue<b.fValue then begin
  result.fValue:=a.fValue;
 end else begin
  result.fValue:=b.fValue;
 end;
end;

class operator TRNLKey.Implicit(const a:TRNLUInt64):TRNLKey;
var Index:TRNLInt32;
begin
 for Index:=0 to 7 do begin
  result.ui8[Index]:=(a shr (Index shl 3)) and $ff;
 end;
 for Index:=8 to 31 do begin
  result.ui8[Index]:=0;
 end;
end;

class operator TRNLKey.Explicit(const a:TRNLUInt64):TRNLKey;
var Index:TRNLInt32;
begin
 for Index:=0 to 7 do begin
  result.ui8[Index]:=(a shr (Index shl 3)) and $ff;
 end;
 for Index:=8 to 31 do begin
  result.ui8[Index]:=0;
 end;
end;

class operator TRNLKey.Implicit(const a:TRNLKey):TRNLUInt64;
var Index:TRNLInt32;
begin
 result:=0;
 for Index:=0 to 7 do begin
  result:=result or (TRNLUInt64(a.ui8[Index]) shl (Index shl 3));
 end;
end;

class operator TRNLKey.Explicit(const a:TRNLKey):TRNLUInt64;
var Index:TRNLInt32;
begin
 result:=0;
 for Index:=0 to 7 do begin
  result:=result or (TRNLUInt64(a.ui8[Index]) shl (Index shl 3));
 end;
end;

class operator TRNLKey.Equal(const a,b:TRNLKey):boolean;
begin
 result:=(a.ui64[0]=b.ui64[0]) and
         (a.ui64[1]=b.ui64[1]) and
         (a.ui64[2]=b.ui64[2]) and
         (a.ui64[3]=b.ui64[3]);
end;

class operator TRNLKey.NotEqual(const a,b:TRNLKey):boolean;
begin
 result:=(a.ui64[0]<>b.ui64[0]) or
         (a.ui64[1]<>b.ui64[1]) or
         (a.ui64[2]<>b.ui64[2]) or
         (a.ui64[3]<>b.ui64[3]);
end;

function TRNLKey.ClampForCurve25519:TRNLKey;
begin
 result:=self;
 result.ui8[0]:=ui8[0] and $f8;
 result.ui8[31]:=(ui8[31] and $7f) or $40;
end;

function TRNLKey.ConvertFromED25519ToX25519PrivateKey:TRNLKey;
var Temporary:array[0..63] of TRNLUInt8;
begin
 TRNLED25519Hash.Process(Temporary,self,SizeOf(TRNLKey));
 PRNLKey(Pointer(@result))^:=PRNLKey(Pointer(@Temporary))^.ClampForCurve25519;
end;

function TRNLKey.ConvertFromED25519ToX25519PublicKey:TRNLKey;
var t,o:TRNLValue25519;
begin
 t.LoadFromMemory(self);
 o:=TRNLValue25519(1);
 (TRNLValue25519(o+t)*(TRNLValue25519(o-t).Invert)).SaveToMemory(result);
end;

class function TRNLKey.CreateRandom(const aRandomGenerator:TRNLRandomGenerator):TRNLKey;
var Index:TRNLInt32;
begin
 for Index:=0 to 31 do begin
  result.ui8[Index]:=aRandomGenerator.GetUInt32 and $ff;
 end;
 result:=result.ClampForCurve25519;
end;

constructor TRNLValue25519.Create(const aValue:TRNLInt32);
begin
 Limbs[0]:=aValue;
 Limbs[1]:=0;
 Limbs[2]:=0;
 Limbs[3]:=0;
 Limbs[4]:=0;
 Limbs[5]:=0;
 Limbs[6]:=0;
 Limbs[7]:=0;
 Limbs[8]:=0;
 Limbs[9]:=0;
end;

class operator TRNLValue25519.Implicit(const a:TRNLInt32):TRNLValue25519;
begin
 result.Limbs[0]:=a;
 result.Limbs[1]:=0;
 result.Limbs[2]:=0;
 result.Limbs[3]:=0;
 result.Limbs[4]:=0;
 result.Limbs[5]:=0;
 result.Limbs[6]:=0;
 result.Limbs[7]:=0;
 result.Limbs[8]:=0;
 result.Limbs[9]:=0;
end;

class operator TRNLValue25519.Explicit(const a:TRNLInt32):TRNLValue25519;
begin
 result.Limbs[0]:=a;
 result.Limbs[1]:=0;
 result.Limbs[2]:=0;
 result.Limbs[3]:=0;
 result.Limbs[4]:=0;
 result.Limbs[5]:=0;
 result.Limbs[6]:=0;
 result.Limbs[7]:=0;
 result.Limbs[8]:=0;
 result.Limbs[9]:=0;
end;

class operator TRNLValue25519.Add(const a,b:TRNLValue25519):TRNLValue25519;
begin
 result.Limbs[0]:=a.Limbs[0]+b.Limbs[0];
 result.Limbs[1]:=a.Limbs[1]+b.Limbs[1];
 result.Limbs[2]:=a.Limbs[2]+b.Limbs[2];
 result.Limbs[3]:=a.Limbs[3]+b.Limbs[3];
 result.Limbs[4]:=a.Limbs[4]+b.Limbs[4];
 result.Limbs[5]:=a.Limbs[5]+b.Limbs[5];
 result.Limbs[6]:=a.Limbs[6]+b.Limbs[6];
 result.Limbs[7]:=a.Limbs[7]+b.Limbs[7];
 result.Limbs[8]:=a.Limbs[8]+b.Limbs[8];
 result.Limbs[9]:=a.Limbs[9]+b.Limbs[9];
end;

class operator TRNLValue25519.Subtract(const a,b:TRNLValue25519):TRNLValue25519;
begin
 result.Limbs[0]:=a.Limbs[0]-b.Limbs[0];
 result.Limbs[1]:=a.Limbs[1]-b.Limbs[1];
 result.Limbs[2]:=a.Limbs[2]-b.Limbs[2];
 result.Limbs[3]:=a.Limbs[3]-b.Limbs[3];
 result.Limbs[4]:=a.Limbs[4]-b.Limbs[4];
 result.Limbs[5]:=a.Limbs[5]-b.Limbs[5];
 result.Limbs[6]:=a.Limbs[6]-b.Limbs[6];
 result.Limbs[7]:=a.Limbs[7]-b.Limbs[7];
 result.Limbs[8]:=a.Limbs[8]-b.Limbs[8];
 result.Limbs[9]:=a.Limbs[9]-b.Limbs[9];
end;

class operator TRNLValue25519.Multiply(const a,b:TRNLValue25519):TRNLValue25519;
var f0,f1,f2,f3,f4,f5,f6,f7,f8,f9,g0,g1,g2,g3,g4,g5,g6,g7,g8,g9,
    x1,x3,x5,x7,x9,y1,y2,y3,y4,y5,y6,y7,y8,y9:TRNLInt32;
    h0,h1,h2,h3,h4,h5,h6,h7,h8,h9,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9:TRNLInt64;
begin
 f0:=a.Limbs[0];
 f1:=a.Limbs[1];
 f2:=a.Limbs[2];
 f3:=a.Limbs[3];
 f4:=a.Limbs[4];
 f5:=a.Limbs[5];
 f6:=a.Limbs[6];
 f7:=a.Limbs[7];
 f8:=a.Limbs[8];
 f9:=a.Limbs[9];
 g0:=b.Limbs[0];
 g1:=b.Limbs[1];
 g2:=b.Limbs[2];
 g3:=b.Limbs[3];
 g4:=b.Limbs[4];
 g5:=b.Limbs[5];
 g6:=b.Limbs[6];
 g7:=b.Limbs[7];
 g8:=b.Limbs[8];
 g9:=b.Limbs[9];
 x1:=f1*2;
 x3:=f3*2;
 x5:=f5*2;
 x7:=f7*2;
 x9:=f9*2;
 y1:=g1*19;
 y2:=g2*19;
 y3:=g3*19;
 y4:=g4*19;
 y5:=g5*19;
 y6:=g6*19;
 y7:=g7*19;
 y8:=g8*19;
 y9:=g9*19;
 h0:=(f0*TRNLInt64(g0))+(x1*TRNLInt64(y9))+(f2*TRNLInt64(y8))+(x3*TRNLInt64(y7))+(f4*TRNLInt64(y6))+(x5*TRNLInt64(y5))+(f6*TRNLInt64(y4))+(x7*TRNLInt64(y3))+(f8*TRNLInt64(y2))+(x9*TRNLInt64(y1));
 h1:=(f0*TRNLInt64(g1))+(f1*TRNLInt64(g0))+(f2*TRNLInt64(y9))+(f3*TRNLInt64(y8))+(f4*TRNLInt64(y7))+(f5*TRNLInt64(y6))+(f6*TRNLInt64(y5))+(f7*TRNLInt64(y4))+(f8*TRNLInt64(y3))+(f9*TRNLInt64(y2));
 h2:=(f0*TRNLInt64(g2))+(x1*TRNLInt64(g1))+(f2*TRNLInt64(g0))+(x3*TRNLInt64(y9))+(f4*TRNLInt64(y8))+(x5*TRNLInt64(y7))+(f6*TRNLInt64(y6))+(x7*TRNLInt64(y5))+(f8*TRNLInt64(y4))+(x9*TRNLInt64(y3));
 h3:=(f0*TRNLInt64(g3))+(f1*TRNLInt64(g2))+(f2*TRNLInt64(g1))+(f3*TRNLInt64(g0))+(f4*TRNLInt64(y9))+(f5*TRNLInt64(y8))+(f6*TRNLInt64(y7))+(f7*TRNLInt64(y6))+(f8*TRNLInt64(y5))+(f9*TRNLInt64(y4));
 h4:=(f0*TRNLInt64(g4))+(x1*TRNLInt64(g3))+(f2*TRNLInt64(g2))+(x3*TRNLInt64(g1))+(f4*TRNLInt64(g0))+(x5*TRNLInt64(y9))+(f6*TRNLInt64(y8))+(x7*TRNLInt64(y7))+(f8*TRNLInt64(y6))+(x9*TRNLInt64(y5));
 h5:=(f0*TRNLInt64(g5))+(f1*TRNLInt64(g4))+(f2*TRNLInt64(g3))+(f3*TRNLInt64(g2))+(f4*TRNLInt64(g1))+(f5*TRNLInt64(g0))+(f6*TRNLInt64(y9))+(f7*TRNLInt64(y8))+(f8*TRNLInt64(y7))+(f9*TRNLInt64(y6));
 h6:=(f0*TRNLInt64(g6))+(x1*TRNLInt64(g5))+(f2*TRNLInt64(g4))+(x3*TRNLInt64(g3))+(f4*TRNLInt64(g2))+(x5*TRNLInt64(g1))+(f6*TRNLInt64(g0))+(x7*TRNLInt64(y9))+(f8*TRNLInt64(y8))+(x9*TRNLInt64(y7));
 h7:=(f0*TRNLInt64(g7))+(f1*TRNLInt64(g6))+(f2*TRNLInt64(g5))+(f3*TRNLInt64(g4))+(f4*TRNLInt64(g3))+(f5*TRNLInt64(g2))+(f6*TRNLInt64(g1))+(f7*TRNLInt64(g0))+(f8*TRNLInt64(y9))+(f9*TRNLInt64(y8));
 h8:=(f0*TRNLInt64(g8))+(x1*TRNLInt64(g7))+(f2*TRNLInt64(g6))+(x3*TRNLInt64(g5))+(f4*TRNLInt64(g4))+(x5*TRNLInt64(g3))+(f6*TRNLInt64(g2))+(x7*TRNLInt64(g1))+(f8*TRNLInt64(g0))+(x9*TRNLInt64(y9));
 h9:=(f0*TRNLInt64(g9))+(f1*TRNLInt64(g8))+(f2*TRNLInt64(g7))+(f3*TRNLInt64(g6))+(f4*TRNLInt64(g5))+(f5*TRNLInt64(g4))+(f6*TRNLInt64(g3))+(f7*TRNLInt64(g2))+(f8*TRNLInt64(g1))+(f9*TRNLInt64(g0));
 c0:=SARInt64(h0+TRNLInt64(1 shl 25),26);
 inc(h1,c0);
 dec(h0,c0 shl 26);
 c4:=SARInt64(h4+TRNLInt64(1 shl 25),26);
 inc(h5,c4);
 dec(h4,c4 shl 26);
 c1:=SARInt64(h1+TRNLInt64(1 shl 24),25);
 inc(h2,c1);
 dec(h1,c1 shl 25);
 c5:=SARInt64(h5+TRNLInt64(1 shl 24),25);
 inc(h6,c5);
 dec(h5,c5 shl 25);
 c2:=SARInt64(h2+TRNLInt64(1 shl 25),26);
 inc(h3,c2);
 dec(h2,c2 shl 26);
 c6:=SARInt64(h6+TRNLInt64(1 shl 25),26);
 inc(h7,c6);
 dec(h6,c6 shl 26);
 c3:=SARInt64(h3+TRNLInt64(1 shl 24),25);
 inc(h4,c3);
 dec(h3,c3 shl 25);
 c7:=SARInt64(h7+TRNLInt64(1 shl 24),25);
 inc(h8,c7);
 dec(h7,c7 shl 25);
 c4:=SARInt64(h4+TRNLInt64(1 shl 25),26);
 inc(h5,c4);
 dec(h4,c4 shl 26);
 c8:=SARInt64(h8+TRNLInt64(1 shl 25),26);
 inc(h9,c8);
 dec(h8,c8 shl 26);
 c9:=SARInt64(h9+TRNLInt64(1 shl 24),25);
 inc(h0,c9*19);
 dec(h9,c9 shl 25);
 c0:=SARInt64(h0+TRNLInt64(1 shl 25),26);
 inc(h1,c0);
 dec(h0,c0 shl 26);
 result.Limbs[0]:=h0;
 result.Limbs[1]:=h1;
 result.Limbs[2]:=h2;
 result.Limbs[3]:=h3;
 result.Limbs[4]:=h4;
 result.Limbs[5]:=h5;
 result.Limbs[6]:=h6;
 result.Limbs[7]:=h7;
 result.Limbs[8]:=h8;
 result.Limbs[9]:=h9;
end;

class operator TRNLValue25519.Negative(const a:TRNLValue25519):TRNLValue25519;
begin
 result.Limbs[0]:=-a.Limbs[0];
 result.Limbs[1]:=-a.Limbs[1];
 result.Limbs[2]:=-a.Limbs[2];
 result.Limbs[3]:=-a.Limbs[3];
 result.Limbs[4]:=-a.Limbs[4];
 result.Limbs[5]:=-a.Limbs[5];
 result.Limbs[6]:=-a.Limbs[6];
 result.Limbs[7]:=-a.Limbs[7];
 result.Limbs[8]:=-a.Limbs[8];
 result.Limbs[9]:=-a.Limbs[9];
end;

class operator TRNLValue25519.Positive(const a:TRNLValue25519):TRNLValue25519;
begin
 result:=a;
end;

class operator TRNLValue25519.Equal(const a,b:TRNLValue25519):boolean;
begin
 result:=(a.Limbs[0]=b.Limbs[0]) and
         (a.Limbs[1]=b.Limbs[1]) and
         (a.Limbs[2]=b.Limbs[2]) and
         (a.Limbs[3]=b.Limbs[3]) and
         (a.Limbs[4]=b.Limbs[4]) and
         (a.Limbs[5]=b.Limbs[5]) and
         (a.Limbs[6]=b.Limbs[6]) and
         (a.Limbs[7]=b.Limbs[7]) and
         (a.Limbs[8]=b.Limbs[8]) and
         (a.Limbs[9]=b.Limbs[9]);
end;

class operator TRNLValue25519.NotEqual(const a,b:TRNLValue25519):boolean;
begin
 result:=(a.Limbs[0]<>b.Limbs[0]) or
         (a.Limbs[1]<>b.Limbs[1]) or
         (a.Limbs[2]<>b.Limbs[2]) or
         (a.Limbs[3]<>b.Limbs[3]) or
         (a.Limbs[4]<>b.Limbs[4]) or
         (a.Limbs[5]<>b.Limbs[5]) or
         (a.Limbs[6]<>b.Limbs[6]) or
         (a.Limbs[7]<>b.Limbs[7]) or
         (a.Limbs[8]<>b.Limbs[8]) or
         (a.Limbs[9]<>b.Limbs[9]);
end;

function TRNLValue25519.Square:TRNLValue25519;
var f0,f1,f2,f3,f4,f5,f6,f7,f8,f9,f0_2,f1_2,f2_2,f3_2,f4_2,f5_2,f6_2,f7_2,
    f5_38,f6_19,f7_38,f8_19,f9_38:TRNLInt32;
    h0,h1,h2,h3,h4,h5,h6,h7,h8,h9,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9:TRNLInt64;
begin
 f0:=Limbs[0];
 f1:=Limbs[1];
 f2:=Limbs[2];
 f3:=Limbs[3];
 f4:=Limbs[4];
 f5:=Limbs[5];
 f6:=Limbs[6];
 f7:=Limbs[7];
 f8:=Limbs[8];
 f9:=Limbs[9];
 f0_2:=f0*2;
 f1_2:=f1*2;
 f2_2:=f2*2;
 f3_2:=f3*2;
 f4_2:=f4*2;
 f5_2:=f5*2;
 f6_2:=f6*2;
 f7_2:=f7*2;
 f5_38:=f5*38;
 f6_19:=f6*19;
 f7_38:=f7*38;
 f8_19:=f8*19;
 f9_38:=f9*38;
 h0:=(f0*TRNLInt64(f0))+(f1_2*TRNLInt64(f9_38))+(f2_2*TRNLInt64(f8_19))+(f3_2*TRNLInt64(f7_38))+(f4_2*TRNLInt64(f6_19))+(f5*TRNLInt64(f5_38));
 h1:=(f0_2*TRNLInt64(f1))+(f2*TRNLInt64(f9_38))+(f3_2*TRNLInt64(f8_19))+(f4*TRNLInt64(f7_38))+(f5_2*TRNLInt64(f6_19));
 h2:=(f0_2*TRNLInt64(f2))+(f1_2*TRNLInt64(f1))+(f3_2*TRNLInt64(f9_38))+(f4_2*TRNLInt64(f8_19))+(f5_2*TRNLInt64(f7_38))+(f6*TRNLInt64(f6_19));
 h3:=(f0_2*TRNLInt64(f3))+(f1_2*TRNLInt64(f2))+(f4*TRNLInt64(f9_38))+(f5_2*TRNLInt64(f8_19))+(f6*TRNLInt64(f7_38));
 h4:=(f0_2*TRNLInt64(f4))+(f1_2*TRNLInt64(f3_2))+(f2*TRNLInt64(f2))+(f5_2*TRNLInt64(f9_38))+(f6_2*TRNLInt64(f8_19))+(f7*TRNLInt64(f7_38));
 h5:=(f0_2*TRNLInt64(f5))+(f1_2*TRNLInt64(f4))+(f2_2*TRNLInt64(f3))+(f6*TRNLInt64(f9_38))+(f7_2*TRNLInt64(f8_19));
 h6:=(f0_2*TRNLInt64(f6))+(f1_2*TRNLInt64(f5_2))+(f2_2*TRNLInt64(f4))+(f3_2*TRNLInt64(f3))+(f7_2*TRNLInt64(f9_38))+(f8*TRNLInt64(f8_19));
 h7:=(f0_2*TRNLInt64(f7))+(f1_2*TRNLInt64(f6))+(f2_2*TRNLInt64(f5))+(f3_2*TRNLInt64(f4))+(f8*TRNLInt64(f9_38));
 h8:=(f0_2*TRNLInt64(f8))+(f1_2*TRNLInt64(f7_2))+(f2_2*TRNLInt64(f6))+(f3_2*TRNLInt64(f5_2))+(f4*TRNLInt64(f4))+(f9*TRNLInt64(f9_38));
 h9:=(f0_2*TRNLInt64(f9))+(f1_2*TRNLInt64(f8))+(f2_2*TRNLInt64(f7))+(f3_2*TRNLInt64(f6))+(f4*TRNLInt64(f5_2));
 c0:=SARInt64(h0+TRNLInt64(1 shl 25),26);
 inc(h1,c0);
 dec(h0,c0 shl 26);
 c4:=SARInt64(h4+TRNLInt64(1 shl 25),26);
 inc(h5,c4);
 dec(h4,c4 shl 26);
 c1:=SARInt64(h1+TRNLInt64(1 shl 24),25);
 inc(h2,c1);
 dec(h1,c1 shl 25);
 c5:=SARInt64(h5+TRNLInt64(1 shl 24),25);
 inc(h6,c5);
 dec(h5,c5 shl 25);
 c2:=SARInt64(h2+TRNLInt64(1 shl 25),26);
 inc(h3,c2);
 dec(h2,c2 shl 26);
 c6:=SARInt64(h6+TRNLInt64(1 shl 25),26);
 inc(h7,c6);
 dec(h6,c6 shl 26);
 c3:=SARInt64(h3+TRNLInt64(1 shl 24),25);
 inc(h4,c3);
 dec(h3,c3 shl 25);
 c7:=SARInt64(h7+TRNLInt64(1 shl 24),25);
 inc(h8,c7);
 dec(h7,c7 shl 25);
 c4:=SARInt64(h4+TRNLInt64(1 shl 25),26);
 inc(h5,c4);
 dec(h4,c4 shl 26);
 c8:=SARInt64(h8+TRNLInt64(1 shl 25),26);
 inc(h9,c8);
 dec(h8,c8 shl 26);
 c9:=SARInt64(h9+TRNLInt64(1 shl 24),25);
 inc(h0,c9*19);
 dec(h9,c9 shl 25);
 c0:=SARInt64(h0+TRNLInt64(1 shl 25),26);
 inc(h1,c0);
 dec(h0,c0 shl 26);
 result.Limbs[0]:=h0;
 result.Limbs[1]:=h1;
 result.Limbs[2]:=h2;
 result.Limbs[3]:=h3;
 result.Limbs[4]:=h4;
 result.Limbs[5]:=h5;
 result.Limbs[6]:=h6;
 result.Limbs[7]:=h7;
 result.Limbs[8]:=h8;
 result.Limbs[9]:=h9;
end;

function TRNLValue25519.Square(const aCount:TRNLInt32):TRNLValue25519;
var i:TRNLInt32;
begin
 if aCount>0 then begin
  result:=Square;
  if aCount>1 then begin
   for i:=1 to aCount do begin
    result:=result.Square;
   end;
  end;
 end else begin
  result:=self;
 end;
end;

class procedure TRNLValue25519.ConditionalSwap(var a,b:TRNLValue25519;const aSelect:TRNLInt32);
var x,m,i:TRNLInt32;
begin
 m:=-(aSelect and 1);
 for i:=0 to 9 do begin
  x:=(a.Limbs[i] xor b.Limbs[i]) and m;
  a.Limbs[i]:=a.Limbs[i] xor x;
  b.Limbs[i]:=b.Limbs[i] xor x;
 end;
end;

function TRNLValue25519.Carry:TRNLValue25519;
var c0,c1,c2,c3,c4,c5,c6,c7,c8,c9:TRNLInt64;
begin
 result:=self;
 c9:=SARInt64(result.Limbs[9]+TRNLInt64(1 shl 24),25);
 inc(result.Limbs[0],c9*19);
 dec(result.Limbs[9],c9 shl 25);
 c1:=SARInt64(result.Limbs[1]+TRNLInt64(1 shl 24),25);
 inc(result.Limbs[2],c1);
 dec(result.Limbs[1],c1 shl 25);
 c3:=SARInt64(result.Limbs[3]+TRNLInt64(1 shl 24),25);
 inc(result.Limbs[4],c3);
 dec(result.Limbs[3],c3 shl 25);
 c5:=SARInt64(result.Limbs[5]+TRNLInt64(1 shl 24),25);
 inc(result.Limbs[6],c5);
 dec(result.Limbs[5],c5 shl 25);
 c7:=SARInt64(result.Limbs[7]+TRNLInt64(1 shl 24),25);
 inc(result.Limbs[8],c7);
 dec(result.Limbs[7],c7 shl 25);
 c0:=SARInt64(result.Limbs[0]+TRNLInt64(1 shl 25),26);
 inc(result.Limbs[1],c0);
 dec(result.Limbs[0],c0 shl 26);
 c2:=SARInt64(result.Limbs[2]+TRNLInt64(1 shl 25),26);
 inc(result.Limbs[3],c2);
 dec(result.Limbs[2],c2 shl 26);
 c4:=SARInt64(result.Limbs[4]+TRNLInt64(1 shl 25),26);
 inc(result.Limbs[5],c4);
 dec(result.Limbs[4],c4 shl 26);
 c6:=SARInt64(result.Limbs[6]+TRNLInt64(1 shl 25),26);
 inc(result.Limbs[7],c6);
 dec(result.Limbs[6],c6 shl 26);
 c8:=SARInt64(result.Limbs[8]+TRNLInt64(1 shl 25),26);
 inc(result.Limbs[9],c8);
 dec(result.Limbs[8],c8 shl 26);
end;

class function TRNLValue25519.Carry64(const aValue:TRNLValue2551964):TRNLValue25519;
var c0,c1,c2,c3,c4,c5,c6,c7,c8,c9:TRNLInt64;
    Value:TRNLValue2551964;
begin
 Value:=aValue;
 c9:=SARInt64(Value.Limbs[9]+TRNLInt64(1 shl 24),25);
 inc(Value.Limbs[0],c9*19);
 dec(Value.Limbs[9],c9 shl 25);
 c1:=SARInt64(Value.Limbs[1]+TRNLInt64(1 shl 24),25);
 inc(Value.Limbs[2],c1);
 dec(Value.Limbs[1],c1 shl 25);
 c3:=SARInt64(Value.Limbs[3]+TRNLInt64(1 shl 24),25);
 inc(Value.Limbs[4],c3);
 dec(Value.Limbs[3],c3 shl 25);
 c5:=SARInt64(Value.Limbs[5]+TRNLInt64(1 shl 24),25);
 inc(Value.Limbs[6],c5);
 dec(Value.Limbs[5],c5 shl 25);
 c7:=SARInt64(Value.Limbs[7]+TRNLInt64(1 shl 24),25);
 inc(Value.Limbs[8],c7);
 dec(Value.Limbs[7],c7 shl 25);
 c0:=SARInt64(Value.Limbs[0]+TRNLInt64(1 shl 25),26);
 inc(Value.Limbs[1],c0);
 dec(Value.Limbs[0],c0 shl 26);
 c2:=SARInt64(Value.Limbs[2]+TRNLInt64(1 shl 25),26);
 inc(Value.Limbs[3],c2);
 dec(Value.Limbs[2],c2 shl 26);
 c4:=SARInt64(Value.Limbs[4]+TRNLInt64(1 shl 25),26);
 inc(Value.Limbs[5],c4);
 dec(Value.Limbs[4],c4 shl 26);
 c6:=SARInt64(Value.Limbs[6]+TRNLInt64(1 shl 25),26);
 inc(Value.Limbs[7],c6);
 dec(Value.Limbs[6],c6 shl 26);
 c8:=SARInt64(Value.Limbs[8]+TRNLInt64(1 shl 25),26);
 inc(Value.Limbs[9],c8);
 dec(Value.Limbs[8],c8 shl 26);
 result.Limbs[0]:=Value.Limbs[0];
 result.Limbs[1]:=Value.Limbs[1];
 result.Limbs[2]:=Value.Limbs[2];
 result.Limbs[3]:=Value.Limbs[3];
 result.Limbs[4]:=Value.Limbs[4];
 result.Limbs[5]:=Value.Limbs[5];
 result.Limbs[6]:=Value.Limbs[6];
 result.Limbs[7]:=Value.Limbs[7];
 result.Limbs[8]:=Value.Limbs[8];
 result.Limbs[9]:=Value.Limbs[9];
end;

class function TRNLValue25519.CreateRandom(const aRandomGenerator:TRNLRandomGenerator):TRNLValue25519;
var Value:TRNLValue2551964;
begin
 Value.Limbs[0]:=aRandomGenerator.GetUInt32 and $7fffffff;
 Value.Limbs[1]:=aRandomGenerator.GetUInt32 and $7fffffff;
 Value.Limbs[2]:=aRandomGenerator.GetUInt32 and $7fffffff;
 Value.Limbs[3]:=aRandomGenerator.GetUInt32 and $7fffffff;
 Value.Limbs[4]:=aRandomGenerator.GetUInt32 and $7fffffff;
 Value.Limbs[5]:=aRandomGenerator.GetUInt32 and $7fffffff;
 Value.Limbs[6]:=aRandomGenerator.GetUInt32 and $7fffffff;
 Value.Limbs[7]:=aRandomGenerator.GetUInt32 and $7fffffff;
 Value.Limbs[8]:=aRandomGenerator.GetUInt32 and $7fffffff;
 Value.Limbs[9]:=aRandomGenerator.GetUInt32 and $7fffffff;
 result:=Carry64(Value);
end;

class function TRNLValue25519.LoadFromMemory(const aLocation):TRNLValue25519;
var Value:TRNLValue2551964;
begin
 Value.Limbs[0]:=TRNLInt64(TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt8Array(TRNLPointer(@aLocation))^[0]));
 Value.Limbs[1]:=TRNLInt64(TRNLMemoryAccess.LoadLittleEndianUInt24(PRNLUInt8Array(TRNLPointer(@aLocation))^[4])) shl 6;
 Value.Limbs[2]:=TRNLInt64(TRNLMemoryAccess.LoadLittleEndianUInt24(PRNLUInt8Array(TRNLPointer(@aLocation))^[7])) shl 5;
 Value.Limbs[3]:=TRNLInt64(TRNLMemoryAccess.LoadLittleEndianUInt24(PRNLUInt8Array(TRNLPointer(@aLocation))^[10])) shl 3;
 Value.Limbs[4]:=TRNLInt64(TRNLMemoryAccess.LoadLittleEndianUInt24(PRNLUInt8Array(TRNLPointer(@aLocation))^[13])) shl 2;
 Value.Limbs[5]:=TRNLInt64(TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt8Array(TRNLPointer(@aLocation))^[16]));
 Value.Limbs[6]:=TRNLInt64(TRNLMemoryAccess.LoadLittleEndianUInt24(PRNLUInt8Array(TRNLPointer(@aLocation))^[20])) shl 7;
 Value.Limbs[7]:=TRNLInt64(TRNLMemoryAccess.LoadLittleEndianUInt24(PRNLUInt8Array(TRNLPointer(@aLocation))^[23])) shl 5;
 Value.Limbs[8]:=TRNLInt64(TRNLMemoryAccess.LoadLittleEndianUInt24(PRNLUInt8Array(TRNLPointer(@aLocation))^[26])) shl 4;
 Value.Limbs[9]:=TRNLInt64(TRNLMemoryAccess.LoadLittleEndianUInt24(PRNLUInt8Array(TRNLPointer(@aLocation))^[29]) and $7fffff) shl 2;
 result:=Carry64(Value);
end;

procedure TRNLValue25519.SaveToMemory(out aLocation);
var t:TRNLValue25519;
    q,i,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9:TRNLInt32;
begin
 t:=self;
 q:=SARLongint((19*t.Limbs[9])+(1 shl 24),25);
 for i:=0 to 4 do begin
  q:=SARLongint(SARLongint(q+t.Limbs[(i shl 1) or 0],26)+t.Limbs[(i shl 1) or 1],25);
 end;
 inc(t.Limbs[0],19*q);
 c0:=SARLongint(t.Limbs[0],26);
 inc(t.Limbs[1],c0);
 dec(t.Limbs[0],c0 shl 26);
 c1:=SARLongint(t.Limbs[1],25);
 inc(t.Limbs[2],c1);
 dec(t.Limbs[1],c1 shl 25);
 c2:=SARLongint(t.Limbs[2],26);
 inc(t.Limbs[3],c2);
 dec(t.Limbs[2],c2 shl 26);
 c3:=SARLongint(t.Limbs[3],25);
 inc(t.Limbs[4],c3);
 dec(t.Limbs[3],c3 shl 25);
 c4:=SARLongint(t.Limbs[4],26);
 inc(t.Limbs[5],c4);
 dec(t.Limbs[4],c4 shl 26);
 c5:=SARLongint(t.Limbs[5],25);
 inc(t.Limbs[6],c5);
 dec(t.Limbs[5],c5 shl 25);
 c6:=SARLongint(t.Limbs[6],26);
 inc(t.Limbs[7],c6);
 dec(t.Limbs[6],c6 shl 26);
 c7:=SARLongint(t.Limbs[7],25);
 inc(t.Limbs[8],c7);
 dec(t.Limbs[7],c7 shl 25);
 c8:=SARLongint(t.Limbs[8],26);
 inc(t.Limbs[9],c8);
 dec(t.Limbs[8],c8 shl 26);
 c9:=SARLongint(t.Limbs[9],25);
 dec(t.Limbs[9],c9 shl 25);
 TRNLMemoryAccess.StoreLittleEndianUInt32(PRNLUInt8Array(TRNLPointer(@aLocation))^[0],(TRNLUInt32(t.Limbs[0]) shr 0) or (TRNLUInt32(t.Limbs[1]) shl 26));
 TRNLMemoryAccess.StoreLittleEndianUInt32(PRNLUInt8Array(TRNLPointer(@aLocation))^[4],(TRNLUInt32(t.Limbs[1]) shr 6) or (TRNLUInt32(t.Limbs[2]) shl 19));
 TRNLMemoryAccess.StoreLittleEndianUInt32(PRNLUInt8Array(TRNLPointer(@aLocation))^[8],(TRNLUInt32(t.Limbs[2]) shr 13) or (TRNLUInt32(t.Limbs[3]) shl 13));
 TRNLMemoryAccess.StoreLittleEndianUInt32(PRNLUInt8Array(TRNLPointer(@aLocation))^[12],(TRNLUInt32(t.Limbs[3]) shr 19) or (TRNLUInt32(t.Limbs[4]) shl 6));
 TRNLMemoryAccess.StoreLittleEndianUInt32(PRNLUInt8Array(TRNLPointer(@aLocation))^[16],(TRNLUInt32(t.Limbs[5]) shr 0) or (TRNLUInt32(t.Limbs[6]) shl 25));
 TRNLMemoryAccess.StoreLittleEndianUInt32(PRNLUInt8Array(TRNLPointer(@aLocation))^[20],(TRNLUInt32(t.Limbs[6]) shr 7) or (TRNLUInt32(t.Limbs[7]) shl 19));
 TRNLMemoryAccess.StoreLittleEndianUInt32(PRNLUInt8Array(TRNLPointer(@aLocation))^[24],(TRNLUInt32(t.Limbs[7]) shr 13) or (TRNLUInt32(t.Limbs[8]) shl 12));
 TRNLMemoryAccess.StoreLittleEndianUInt32(PRNLUInt8Array(TRNLPointer(@aLocation))^[28],(TRNLUInt32(t.Limbs[8]) shr 20) or (TRNLUInt32(t.Limbs[9]) shl 6));
end;

class operator TRNLValue25519.Multiply(const a:TRNLValue25519;const b:TRNLInt32):TRNLValue25519;
var Value:TRNLValue2551964;
begin
 Value.Limbs[0]:=a.Limbs[0]*TRNLInt64(b);
 Value.Limbs[1]:=a.Limbs[1]*TRNLInt64(b);
 Value.Limbs[2]:=a.Limbs[2]*TRNLInt64(b);
 Value.Limbs[3]:=a.Limbs[3]*TRNLInt64(b);
 Value.Limbs[4]:=a.Limbs[4]*TRNLInt64(b);
 Value.Limbs[5]:=a.Limbs[5]*TRNLInt64(b);
 Value.Limbs[6]:=a.Limbs[6]*TRNLInt64(b);
 Value.Limbs[7]:=a.Limbs[7]*TRNLInt64(b);
 Value.Limbs[8]:=a.Limbs[8]*TRNLInt64(b);
 Value.Limbs[9]:=a.Limbs[9]*TRNLInt64(b);
 result:=Carry64(Value);
end;

function TRNLValue25519.Mul121666:TRNLValue25519;
var Value:TRNLValue2551964;
begin
 Value.Limbs[0]:=Limbs[0]*TRNLInt64(121666);
 Value.Limbs[1]:=Limbs[1]*TRNLInt64(121666);
 Value.Limbs[2]:=Limbs[2]*TRNLInt64(121666);
 Value.Limbs[3]:=Limbs[3]*TRNLInt64(121666);
 Value.Limbs[4]:=Limbs[4]*TRNLInt64(121666);
 Value.Limbs[5]:=Limbs[5]*TRNLInt64(121666);
 Value.Limbs[6]:=Limbs[6]*TRNLInt64(121666);
 Value.Limbs[7]:=Limbs[7]*TRNLInt64(121666);
 Value.Limbs[8]:=Limbs[8]*TRNLInt64(121666);
 Value.Limbs[9]:=Limbs[9]*TRNLInt64(121666);
 result:=Carry64(Value);
end;

function TRNLValue25519.Mul973324:TRNLValue25519;
var Value:TRNLValue2551964;
begin
 Value.Limbs[0]:=Limbs[0]*TRNLInt64(973324);
 Value.Limbs[1]:=Limbs[1]*TRNLInt64(973324);
 Value.Limbs[2]:=Limbs[2]*TRNLInt64(973324);
 Value.Limbs[3]:=Limbs[3]*TRNLInt64(973324);
 Value.Limbs[4]:=Limbs[4]*TRNLInt64(973324);
 Value.Limbs[5]:=Limbs[5]*TRNLInt64(973324);
 Value.Limbs[6]:=Limbs[6]*TRNLInt64(973324);
 Value.Limbs[7]:=Limbs[7]*TRNLInt64(973324);
 Value.Limbs[8]:=Limbs[8]*TRNLInt64(973324);
 Value.Limbs[9]:=Limbs[9]*TRNLInt64(973324);
 result:=Carry64(Value);
end;

function TRNLValue25519.Invert:TRNLValue25519;
var t0,t1,t2,t3:TRNLValue25519;
    i:TRNLInt32;
begin
 t0:=self.Square;
 t1:=self*t0.Square.Square;
 t0:=t0*t1;
 t2:=t0.Square;
 t1:=t1*t2;
 t2:=t1.Square;
 for i:=2 to 5 do begin
  t2:=t2.Square;
 end;
 t1:=t2*t1;
 t2:=t1.Square;
 for i:=2 to 10 do begin
  t2:=t2.Square;
 end;
 t2:=t2*t1;
 t3:=t2.Square;
 for i:=2 to 20 do begin
  t3:=t3.Square;
 end;
 t2:=(t3*t2).Square;
 for i:=2 to 10 do begin
  t2:=t2.Square;
 end;
 t1:=t2*t1;
 t2:=t1.Square;
 for i:=2 to 50 do begin
  t2:=t2.Square;
 end;
 t2:=t2*t1;
 t3:=t2.Square;
 for i:=2 to 100 do begin
  t3:=t3.Square;
 end;
 t2:=(t3*t2).Square;
 for i:=2 to 50 do begin
  t2:=t2.Square;
 end;
 t1:=(t2*t1).Square;
 for i:=2 to 5 do begin
  t1:=t1.Square;
 end;
 result:=t1*t0;
end;

function TRNLValue25519.Pow22523:TRNLValue25519;
var t0,t1,t2:TRNLValue25519;
    i:TRNLInt32;
begin
 t0:=self.Square;
 t1:=self*t0.Square.Square;
 t0:=(t0*t1).Square;
 t0:=t1*t0;
 t1:=t0.Square;
 for i:=2 to 5 do begin
  t1:=t1.Square;
 end;
 t0:=t1*t0;
 t1:=t0.Square;
 for i:=2 to 10 do begin
  t1:=t1.Square;
 end;
 t1:=t1*t0;
 t2:=t1.Square;
 for i:=2 to 20 do begin
  t2:=t2.Square;
 end;
 t1:=t2*t1;
 t1:=t1.Square;
 for i:=2 to 10 do begin
  t1:=t1.Square;
 end;
 t0:=t1*t0;
 t1:=t0.Square;
 for i:=2 to 50 do begin
  t1:=t1.Square;
 end;
 t1:=t1*t0;
 t2:=t1.Square;
 for i:=2 to 100 do begin
  t2:=t2.Square;
 end;
 t1:=t2*t1;
 t1:=t1.Square;
 for i:=2 to 50 do begin
  t1:=t1.Square;
 end;
 t0:=(t1*t0).Square;
 for i:=2 to 2 do begin
  t0:=t0.Square;
 end;
 result:=t0*self;
end;

function TRNLValue25519.IsNegative:boolean;
var s:array[0..31] of TRNLUInt8;
begin
 SaveToMemory(s);
 result:=(s[0] and 1)<>0;
end;

function TRNLValue25519.IsNonZero:boolean;
var s:array[0..3] of TRNLUInt64;
begin
 SaveToMemory(s);
 result:=(s[0] or s[1] or s[2] or s[3])<>0;
end;

function TRNLValue25519.IsZero:boolean;
var s:array[0..3] of TRNLUInt64;
begin
 SaveToMemory(s);
 result:=(s[0] or s[1] or s[2] or s[3])=0;
end;

class procedure TRNLValue25519.SelfTest;
var a,b,c,d,x:TRNLValue25519;
    RandomGenerator:TRNLRandomGenerator;
begin
 RandomGenerator:=TRNLRandomGenerator.Create;
 try
  begin
   write('[Value25519] Testing conditional swap ... ');
   a:=13;
   b:=42;
   ConditionalSwap(a,b,0);
   c:=13;
   d:=42;
   ConditionalSwap(c,d,1);
   if (a=d) and (b=c) then begin
    writeln('OK!');
   end else begin
    writeln('FAILED!');
   end;
  end;
  begin
   write('[Value25519] Testing addition and subtraction ... ');
   a:=TRNLValue25519.CreateRandom(RandomGenerator);
   b:=TRNLValue25519.CreateRandom(RandomGenerator);
   c:=TRNLValue25519.CreateRandom(RandomGenerator);
   x:=((((a+b)-c)-a)+c).Carry;
   if x=b then begin
    writeln('OK!');
   end else begin
    writeln('FAILED!');
   end;
  end;
  begin
   write('[Value25519] Testing multiplication ... ');
   a:=TRNLValue25519.CreateRandom(RandomGenerator);
   b:=(a+a).Carry;
   c:=a*2;
   if b=c then begin
    writeln('OK!');
   end else begin
    writeln('FAILED!');
   end;
  end;
  begin
   write('[Value25519] Testing inverse ... ');
   a:=TRNLValue25519.CreateRandom(RandomGenerator);
   b:=1;
   c:=a.Invert*a;
   if b=c then begin
    writeln('OK!');
   end else begin
    writeln('FAILED!');
   end;
  end;
 finally
  RandomGenerator.Free;
 end;
end;

constructor TRNLPoint25519.CreateFromXY(const aX,aY:TRNLValue25519);
begin
 fX:=aX;
 fY:=aY;
 fZ:=1;
 fT:=fX*fY;
end;

class function TRNLPoint25519.LoadFromMemory(out aPoint:TRNLPoint25519;const aLocation):boolean;
const d:TRNLValue25519=(Limbs:(-10913610,13857413,-15372611,6949391,114729,-8787816,-6275908,-3247719,-18696448,-12055116));
      sqrtm1:TRNLValue25519=(Limbs:(-32595792,-7943725,9377950,3500415,12389472,-272473,-25146209,-2005654,326686,11406482));
var u,v,v3,vxx:TRNLValue25519;
begin
 aPoint.fY:=TRNLValue25519.LoadFromMemory(aLocation);
 aPoint.fZ:=1;
 u:=aPoint.fY.Square;
 v:=(u*d)+aPoint.fZ;
 u:=u-aPoint.fZ;
 v3:=v.Square*v;
 aPoint.fX:=(((v3.Square*v)*u).Pow22523*v3)*u;
 vxx:=aPoint.fX.Square*v;
 if (vxx-u).IsNonZero then begin
  if (vxx+u).IsNonZero then begin
   result:=false;
   exit;
  end;
  aPoint.fX:=aPoint.fX*sqrtm1;
 end;
 if aPoint.fX.IsNegative=(((PRNLUInt8Array(TRNLPointer(@aLocation))^[31] shr 7) and 1)<>0) then begin
  aPoint.fX:=-aPoint.fX;
 end;
 aPoint.fT:=aPoint.fX*aPoint.fY;
 result:=true;
end;

procedure TRNLPoint25519.SaveToMemory(out aLocation);
var r,x,y:TRNLValue25519;
begin
 r:=fZ.Invert;
 x:=fX*r;
 y:=fY*r;
 y.SaveToMemory(aLocation);
 PRNLUInt8Array(TRNLPointer(@aLocation))^[31]:=PRNLUInt8Array(TRNLPointer(@aLocation))^[31] xor (TRNLUInt8(ord(x.IsNegative) and 1) shl 7);
end;

class operator TRNLPoint25519.Add(const p,q:TRNLPoint25519):TRNLPoint25519;
const d2:TRNLValue25519=(Limbs:($2b2f159,$1a6e509,$22add7a,$0d4141d,$0038052,$0f3d130,$3407977,$19ce331,$1c56dff,$0901b67));
var a,b,c,d,e,f,g,h:TRNLValue25519;
begin
 a:=(p.fY-p.fX)*(q.fY-q.fX);
 b:=(p.fX+p.fY)*(q.fX+q.fY);
 c:=(p.fT*q.fT)*d2;
 d:=(p.fZ+p.fZ)*q.fZ;
 e:=b-a;
 f:=d-c;
 g:=d+c;
 h:=b+a;
 result.fX:=e*f;
 result.fY:=g*h;
 result.fZ:=f*g;
 result.fT:=e*h;
end;

class procedure TRNLCurve25519.Clean(out aX:TRNLKey);
begin
 FillChar(aX,SizeOf(TRNLKey),#0);
end;

class function TRNLCurve25519.IsWeakPoint(const aK:TRNLKey):boolean;
const Data:array[0..4,0..31] of TRNLUInt8=
       (($00,$00,$00,$00,$00,$00,$00,$00,
         $00,$00,$00,$00,$00,$00,$00,$00,
         $00,$00,$00,$00,$00,$00,$00,$00,
         $00,$00,$00,$00,$00,$00,$00,$00),
        ($01,$00,$00,$00,$00,$00,$00,$00,
         $00,$00,$00,$00,$00,$00,$00,$00,
         $00,$00,$00,$00,$00,$00,$00,$00,
         $00,$00,$00,$00,$00,$00,$00,$00),
        ($e0,$eb,$7a,$7c,$3b,$41,$b8,$ae,
         $16,$56,$e3,$fa,$f1,$9f,$c4,$6a,
         $da,$09,$8d,$eb,$9c,$32,$b1,$fd,
         $86,$62,$05,$16,$5f,$49,$b8,$00),
        ($5f,$9c,$95,$bc,$a3,$50,$8c,$24,
         $b1,$d0,$b1,$55,$9c,$83,$ef,$5b,
         $04,$44,$5c,$c4,$58,$1c,$8e,$86,
         $d8,$22,$4e,$dd,$d0,$9f,$11,$57),
        ($ec,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
         $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
         $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
         $ff,$ff,$ff,$ff,$ff,$ff,$ff,$7f));
var Index,SubIndex,Check,ResultValue:TRNLInt32;
begin
 ResultValue:=0;
 for Index:=low(Data) to high(Data) do begin
  Check:=(Data[Index,31] xor aK.ui8[31]) and $7f;
  for SubIndex:=high(Data[Index])-1 downto low(Data[Index]) do begin
   Check:=Check or (Data[Index,SubIndex] xor aK.ui8[SubIndex]);
  end;
  ResultValue:=ResultValue or (($100-Check) shr 8);
 end;
 result:=ResultValue<>0;
end;

class function TRNLCurve25519.IsInRange(const aX:TRNLKey):boolean;
var Index,Last:TRNLUInt32;
    Carry:TRNLUInt64;
begin
 Carry:=19;
 for Index:=0 to 7 do begin
{$ifdef BIG_ENDIAN}
  inc(Carry,(aX.ui8[(Index shl 2) or 0] shl 0) or
            (aX.ui8[(Index shl 2) or 1] shl 8) or
            (aX.ui8[(Index shl 2) or 2] shl 16) or
            (aX.ui8[(Index shl 2) or 3] shl 24));
{$else}
  inc(Carry,aX.ui32[Index]);
{$endif}
  Last:=Carry and $ffffffff;
  Carry:=Carry shr 32;
 end;
 result:=(Last and $80000000)=0;
end;

class procedure TRNLCurve25519.Ladder(const aX1:TRNLValue25519;out aX2,aZ2,aX3,aZ3:TRNLValue25519;const aScalar:TRNLKey);
var Swap,Position,b:TRNLInt32;
    t0,t1:TRNLValue25519;
begin
 aX2:=1;
 aZ2:=0;
 aX3:=aX1;
 aZ3:=1;
 Swap:=0;
 for Position:=254 downto 0 do begin
  b:=(aScalar.ui8[Position shr 3] shr (Position and 7)) and 1;
  Swap:=Swap xor b;
  TRNLValue25519.ConditionalSwap(aX2,aX3,Swap);
  TRNLValue25519.ConditionalSwap(aZ2,aZ3,Swap);
  Swap:=b;
  t1:=aX2-aZ2;
  aX2:=aX2+aZ2;
  aZ2:=(aX3+aZ3)*t1;
  aZ3:=(aX3-aZ3)*aX2;
  aX3:=(aZ3+aZ2).Square;
  aZ3:=aX1*(aZ3-aZ2).Square;
  t0:=t1.Square;
  t1:=aX2.Square;
  aX2:=t1*t0;
  t1:=t1-t0;
  aZ2:=t1*(t0+t1.Mul121666);
 end;
 TRNLValue25519.ConditionalSwap(aX2,aX3,Swap);
 TRNLValue25519.ConditionalSwap(aZ2,aZ3,Swap);
end;

class function TRNLCurve25519.Eval(out aResult:TRNLKey;const aSecret:TRNLKey;const aBasePoint:PRNLKey=nil):boolean;
const Value9:TRNLKey=(ui8:(9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
var BasePoint:PRNLKey;
    x2,z2,x3,z3:TRNLValue25519;
begin
 if assigned(aBasePoint) then begin
  BasePoint:=aBasePoint;
 end else begin
  BasePoint:=@Value9;
 end;
 Ladder(TRNLValue25519.LoadFromMemory(BasePoint^),
        x2,z2,
        x3,z3,
        PRNLKey(TRNLPointer(@aSecret))^.ClampForCurve25519);
 (x2*z2.Invert).SaveToMemory(aResult);
 result:=IsInRange(BasePoint^);
end;

class procedure TRNLCurve25519.SelfTest;
const alice_private:TRNLKey=(ui8:($77,$07,$6d,$0a,$73,$18,$a5,$7d,$3c,$16,$c1,$72,$51,$b2,$66,$45,$df,$4c,$2f,$87,$eb,$c0,$99,$2a,$b1,$77,$fb,$a5,$1d,$b9,$2c,$2a));
      alice_public:TRNLKey=(ui8:($85,$20,$f0,$09,$89,$30,$a7,$54,$74,$8b,$7d,$dc,$b4,$3e,$f7,$5a,$0d,$bf,$3a,$0d,$26,$38,$1a,$f4,$eb,$a4,$a9,$8e,$aa,$9b,$4e,$6a));
      bob_private:TRNLKey=(ui8:($5d,$ab,$08,$7e,$62,$4a,$8a,$4b,$79,$e1,$7f,$8b,$83,$80,$0e,$e6,$6f,$3b,$b1,$29,$26,$18,$b6,$fd,$1c,$2f,$8b,$27,$ff,$88,$e0,$eb));
      bob_public:TRNLKey=(ui8:($de,$9e,$db,$7d,$7b,$7d,$c1,$b4,$d3,$5b,$61,$c2,$ec,$e4,$35,$37,$3f,$83,$43,$c8,$5b,$78,$67,$4d,$ad,$fc,$7e,$14,$6f,$88,$2b,$4f));
      shared_secret:TRNLKey=(ui8:($4a,$5d,$9d,$5b,$a4,$ce,$2d,$e1,$72,$8e,$3b,$f4,$80,$35,$0f,$25,$e0,$7e,$21,$c9,$47,$d1,$9e,$33,$76,$f0,$9b,$3c,$1e,$16,$17,$42));
var alice_private_,bob_private_,r:TRNLKey;
begin

 write('[Curve25519] Generating private and public key pair for Alice ... ');
 alice_private_:=alice_private.ClampForCurve25519;
 Eval(r,alice_private_,nil);
 if r=alice_public then begin
  writeln('OK!');
 end else begin
  writeln('FAILED!');
 end;

 write('[Curve25519] Generating private and public key pair for Bob ... ');
 bob_private_:=bob_private.ClampForCurve25519;
 Eval(r,bob_private_,nil);
 if r=bob_public then begin
  writeln('OK!');
 end else begin
  writeln('FAILED!');
 end;

 write('[Curve25519] Generating shared secret for Alice ... ');
 Eval(r,alice_private_,@bob_public);
 if r=shared_secret then begin
  writeln('OK!');
 end else begin
  writeln('FAILED!');
 end;

 write('[Curve25519] Generating shared secret for Bob ... ');
 Eval(r,bob_private_,@alice_public);
 if r=shared_secret then begin
  writeln('OK!');
 end else begin
  writeln('FAILED!');
 end;

end;

class function TRNLX25519.GeneratePublicPrivateKeyPair(const aRandomGenerator:TRNLRandomGenerator;out aPublicKey,aPrivateKey:TRNLKey):boolean;
begin
 repeat
  aPrivateKey:=TRNLKey.CreateRandom(aRandomGenerator).ClampForCurve25519;
  TRNLCurve25519.Eval(aPublicKey,aPrivateKey,nil);
 until not TRNLCurve25519.IsWeakPoint(aPublicKey);
 result:=true;
end;

class function TRNLX25519.GenerateSharedSecretKey(out aSharedSecretKey:TRNLKey;const aPublicKey,aPrivateKey:TRNLKey):boolean;
var k:TRNLKey;
begin
 k:=aPublicKey;
 result:=not ((TRNLCurve25519.IsWeakPoint(k) or not TRNLCurve25519.Eval(k,aPrivateKey,@k)) or TRNLCurve25519.IsWeakPoint(k));
 if result then begin
  aSharedSecretKey:=k;
 end else begin
  FillChar(aSharedSecretKey,SizeOf(TRNLKey),#0);
 end;
end;

class procedure TRNLX25519.SelfTest;
var alice_k,alice_f,alice_s,bob_k,bob_f,bob_s:TRNLKey;
    RandomGenerator:TRNLRandomGenerator;
begin

 RandomGenerator:=TRNLRandomGenerator.Create;
 try

  write('[X25519] Generating random public/private key pair for Alice ... ');
  if GeneratePublicPrivateKeyPair(RandomGenerator,alice_k,alice_f) then begin
   writeln('OK!');
  end else begin
   writeln('FAILED!');
   exit;
  end;

  write('[X25519] Generating random public/private key pair for Bob ... ');
  if GeneratePublicPrivateKeyPair(RandomGenerator,bob_k,bob_f) then begin
   writeln('OK!');
  end else begin
   writeln('FAILED!');
   exit;
  end;

  write('[X25519] Generating shared secret key for Alice ... ');
  if GenerateSharedSecretKey(alice_s,bob_k,alice_f) then begin
   writeln('OK!');
  end else begin
   writeln('FAILED!');
   exit;
  end;

  write('[X25519] Generating shared secret key for Bob ... ');
  if GenerateSharedSecretKey(bob_s,alice_k,bob_f) then begin
   writeln('OK!');
  end else begin
   writeln('FAILED!');
   exit;
  end;

  if alice_s=bob_s then begin
   writeln('[X25519] Both shared secrets are equal => OK!');
  end else begin
   writeln('[X25519] Both shared secrets are not equal => FAILED!');
  end;

 finally
  RandomGenerator.Free;
 end;

end;

procedure TRNLPoly1305Context.ClearC;
begin
 fC[0]:=0;
 fC[1]:=0;
 fC[2]:=0;
 fC[3]:=0;
 fCIndex:=0;
end;

procedure TRNLPoly1305Context.ProcessByte(const aValue:TRNLUInt8);
var Index:TRNLUInt32;
begin
 Index:=fCIndex shr 2;
 fC[Index]:=fC[Index] or (TRNLUInt64(aValue) shl ((fCIndex and 3) shl 3));
 inc(fCIndex);
end;

procedure TRNLPoly1305Context.Block;
var s0,s1,s2,s3,s4,x0,x1,x2,x3,u0,u1,u2,u3,u4:TRNLUInt64;
    r0,r1,r2,r3,rr0,rr1,rr2,rr3,x4,u5:TRNLUInt32;
begin
 s0:=fH[0]+TRNLUInt64(fC[0]);
 s1:=fH[1]+TRNLUInt64(fC[1]);
 s2:=fH[2]+TRNLUInt64(fC[2]);
 s3:=fH[3]+TRNLUInt64(fC[3]);
 s4:=fH[4]+TRNLUInt64(fC[4]);
 r0:=fR[0];
 r1:=fR[1];
 r2:=fR[2];
 r3:=fR[3];
 rr0:=(r0 shr 2)*5;
 rr1:=(r1 shr 2)+r1;
 rr2:=(r2 shr 2)+r2;
 rr3:=(r3 shr 2)+r3;
 x0:=(s0*r0)+(s1*rr3)+(s2*rr2)+(s3*rr1)+(s4*rr0);
 x1:=(s0*r1)+(s1*r0)+(s2*rr3)+(s3*rr2)+(s4*rr1);
 x2:=(s0*r2)+(s1*r1)+(s2*r0)+(s3*rr3)+(s4*rr2);
 x3:=(s0*r3)+(s1*r2)+(s2*r1)+(s3*r0)+(s4*rr3);
 x4:=s4*(r0 and 3);
 u5:=x4+(x3 shr 32);
 u0:=((u5 shr 2)*5)+(x0 and $ffffffff);
 u1:=(u0 shr 32)+(x1 and $ffffffff)+(x0 shr 32);
 u2:=(u1 shr 32)+(x2 and $ffffffff)+(x1 shr 32);
 u3:=(u2 shr 32)+(x3 and $ffffffff)+(x2 shr 32);
 u4:=(u3 shr 32)+(u5 and 3);
 fH[0]:=u0 and $ffffffff;
 fH[1]:=u1 and $ffffffff;
 fH[2]:=u2 and $ffffffff;
 fH[3]:=u3 and $ffffffff;
 fH[4]:=u4;
end;

procedure TRNLPoly1305Context.Initialize(const aKey);
begin
 FillChar(self,SizeOf(TRNLPoly1305Context),#0);
 fH[0]:=0;
 fH[1]:=0;
 fH[2]:=0;
 fH[3]:=0;
 fH[4]:=0;
 ClearC;
 fC[4]:=1;
 fR[0]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[0]) and $0fffffff;
 fR[1]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[1]) and $0ffffffc;
 fR[2]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[2]) and $0ffffffc;
 fR[3]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[3]) and $0ffffffc;
 fPad[0]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[4]);
 fPad[1]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[5]);
 fPad[2]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[6]);
 fPad[3]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[7]);
end;

procedure TRNLPoly1305Context.Update(const aMessage;const aMessageSize:TRNLSizeUInt);
var MessagePosition,MessageSize:TRNLSizeUInt;
begin
 MessagePosition:=0;
 MessageSize:=AMessageSize;
 while ((fCIndex and 15)<>0) and (MessageSize>0) do begin
  ProcessByte(PRNLUInt8Array(TRNLPointer(@aMessage))^[MessagePosition]);
  inc(MessagePosition);
  dec(MessageSize);
 end;
 if fCIndex=16 then begin
  Block;
  ClearC;
 end;
 if MessageSize>=16 then begin
  repeat
   fC[0]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt8Array(TRNLPointer(@aMessage))^[MessagePosition+0]);
   fC[1]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt8Array(TRNLPointer(@aMessage))^[MessagePosition+4]);
   fC[2]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt8Array(TRNLPointer(@aMessage))^[MessagePosition+8]);
   fC[3]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt8Array(TRNLPointer(@aMessage))^[MessagePosition+12]);
   Block;
   inc(MessagePosition,16);
   dec(MessageSize,16);
  until MessageSize<16;
  ClearC;
 end;
 while MessageSize>0 do begin
  ProcessByte(PRNLUInt8Array(TRNLPointer(@aMessage))^[MessagePosition]);
  inc(MessagePosition);
  dec(MessageSize);
 end;
end;

procedure TRNLPoly1305Context.Finalize(out aMAC);
var u:TRNLUInt64;
begin
 if fCIndex<>0 then begin
  fC[4]:=0;
  ProcessByte(1);
  Block;
 end;
 u:=(((((((((((5+TRNLUInt64(fH[0])) shr 32)+
                 TRNLUInt64(fH[1])) shr 32)+
                 TRNLUInt64(fH[2])) shr 32)+
                 TRNLUInt64(fH[3])) shr 32)+
                 TRNLUInt64(fH[4])) shr 2)*TRNLUInt64(5))+
    (TRNLUInt64(fH[0])+fPad[0]);
 TRNLMemoryAccess.StoreLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aMAC))^[0],u and $ffffffff);
 u:=(u shr 32)+
    (TRNLUInt64(fH[1])+fPad[1]);
 TRNLMemoryAccess.StoreLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aMAC))^[1],u and $ffffffff);
 u:=(u shr 32)+
    (TRNLUInt64(fH[2])+fPad[2]);
 TRNLMemoryAccess.StoreLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aMAC))^[2],u and $ffffffff);
 u:=(u shr 32)+
    (TRNLUInt64(fH[3])+fPad[3]);
 TRNLMemoryAccess.StoreLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aMAC))^[3],u and $ffffffff);
end;

class function TRNLPoly1305.OneTimeAuthentication(out aOutput;const aInput;const aInputLength:TRNLSizeUInt;const aSecretKey):boolean;
var Context:TRNLPoly1305Context;
begin
 Context.Initialize(aSecretKey);
 Context.Update(aInput,aInputLength);
 Context.Finalize(aOutput);
 result:=true;
end;

class function TRNLPoly1305.OneTimeAuthenticationVerify(const aComparsion;const aInput;const aInputLength:TRNLSizeUInt;const aSecretKey):boolean;
var Correct:array[0..15] of TRNLUInt8;
begin
 OneTimeAuthentication(Correct,aInput,aInputLength,aSecretKey);
 result:=(PRNLUInt64Array(TRNLPointer(@Correct))^[0]=PRNLUInt64Array(TRNLPointer(@aComparsion))^[0]) and
         (PRNLUInt64Array(TRNLPointer(@Correct))^[1]=PRNLUInt64Array(TRNLPointer(@aComparsion))^[1]);
end;

class procedure TRNLPoly1305.SelfTest;
const Key:array[0..31] of TRNLUInt8=($ee,$a6,$a7,$25,$1c,$1e,$72,$91,$6d,$11,$c2,$cb,$21,$4d,$3c,$25,$25,$39,$12,$1d,$8e,$23,$4e,$65,$2d,$65,$1f,$a4,$c8,$cf,$f8,$80);
      Data:array[0..130] of TRNLUInt8=($8e,$99,$3b,$9f,$48,$68,$12,$73,$c2,$96,$50,$ba,$32,$fc,
                                       $76,$ce,$48,$33,$2e,$a7,$16,$4d,$96,$a4,$47,$6f,$b8,$c5,
                                       $31,$a1,$18,$6a,$c0,$df,$c1,$7c,$98,$dc,$e8,$7b,$4d,$a7,
                                       $f0,$11,$ec,$48,$c9,$72,$71,$d2,$c2,$0f,$9b,$92,$8f,$e2,
                                       $27,$0d,$6f,$b8,$63,$d5,$17,$38,$b4,$8e,$ee,$e3,$14,$a7,
                                       $cc,$8a,$b9,$32,$16,$45,$48,$e5,$26,$ae,$90,$22,$43,$68,
                                       $51,$7a,$cf,$ea,$bd,$6b,$b3,$73,$2b,$c0,$e9,$da,$99,$83,
                                       $2b,$61,$ca,$01,$b6,$de,$56,$24,$4a,$9e,$88,$d5,$f9,$b3,
                                       $79,$73,$f6,$22,$a4,$3d,$14,$a6,$59,$9b,$1f,$65,$4c,$b4,
                                       $5a,$74,$e3,$55,$a5);
      Hash:array[0..15] of TRNLUInt8=($f3,$ff,$c7,$70,$3f,$94,$00,$e5,$2a,$7d,$fb,$4b,$3d,$33,$05,$d9);
begin
 write('[Poly1305] ');
 if OneTimeAuthenticationVerify(Hash,Data,SizeOf(Data),Key) then begin
  writeln('OK!');
 end else begin
  writeln('FAILED!');
 end;
end;

class function TRNLSHA512Context.RotateRight64(const aValue:TRNLUInt64;const aBits:TRNLUInt32):TRNLUInt64;
begin
{$ifdef fpc}
 result:=RORQWord(aValue,aBits);
{$else}
 result:=(aValue shl (64-aBits)) or (aValue shr aBits);
{$endif}
end;

procedure TRNLSHA512Context.ResetInput;
begin
 FillChar(fInput,SizeOf(fInput),#0);
 fInputIndex:=0;
end;

procedure TRNLSHA512Context.Initialize;
begin
 fState:=InitialState;
 ResetInput;
 fInputSize[0]:=0;
 fInputSize[1]:=0;
end;

procedure TRNLSHA512Context.Compress;
var w:array[0..79] of TRNLUInt64;
    a,b,c,d,e,f,g,h,t1,t2:TRNLUInt64;
    i:TRNLInt32;
begin
 PRNLSHA512Input(TRNLPointer(@w))^:=fInput;
 for i:=16 to 79 do begin
  a:=w[i-2];
  b:=w[i-15];
  w[i]:=(RotateRight64(a,19) xor RotateRight64(a,61) xor (a shr 6))+
        w[i-7]+
        (RotateRight64(b,1) xor RotateRight64(b,8) xor (b shr 7))+
        w[i-16];
 end;
 a:=fState[0];
 b:=fState[1];
 c:=fState[2];
 d:=fState[3];
 e:=fState[4];
 f:=fState[5];
 g:=fState[6];
 h:=fState[7];
 for i:=0 to 79 do begin
  t1:=(RotateRight64(e,14) xor RotateRight64(e,18) xor RotateRight64(e,41))+
      ((e and f) xor ((not e) and g))+
      h+
      RoundK[i]+
      w[i];
  t2:=(RotateRight64(a,28) xor RotateRight64(a,34) xor RotateRight64(a,39))+
      ((a and b) xor (a and c) xor (b and c));
  h:=g;
  g:=f;
  f:=e;
  e:=d+t1;
  d:=c;
  c:=b;
  b:=a;
  a:=t1+t2;
 end;
 inc(fState[0],a);
 inc(fState[1],b);
 inc(fState[2],c);
 inc(fState[3],d);
 inc(fState[4],e);
 inc(fState[5],f);
 inc(fState[6],g);
 inc(fState[7],h);
end;

procedure TRNLSHA512Context.ProcessByte(const aValue:TRNLUInt8);
var Index:TRNLUInt32;
begin
 Index:=fInputIndex shr 3;
 fInput[Index]:=fInput[Index] or (TRNLUInt64(aValue) shl ((7-(fInputIndex and 7)) shl 3));
end;

procedure TRNLSHA512Context.Increment(var aX;const aY:TRNLUInt64);
begin
 inc(PRNLUInt64Array(TRNLPointer(@aX))^[1],aY);
 if PRNLUInt64Array(TRNLPointer(@aX))^[1]<aY then begin
  inc(PRNLUInt64Array(TRNLPointer(@aX))^[0]);
 end;
end;

procedure TRNLSHA512Context.EndBlock;
begin
 if fInputIndex=128 then begin
  Increment(fInputSize,1024);
  Compress;
  ResetInput;
 end;
end;

procedure TRNLSHA512Context.Update(const aMessage;const aMessageSize:TRNLSizeUInt);
var MessagePosition,MessageSize:TRNLSizeUInt;
begin
 MessagePosition:=0;
 MessageSize:=AMessageSize;
 while ((fInputIndex and 7)<>0) and (MessageSize>0) do begin
  ProcessByte(PRNLUInt8Array(TRNLPointer(@aMessage))^[MessagePosition]);
  inc(fInputIndex);
  inc(MessagePosition);
  dec(MessageSize);
 end;
 EndBlock;
 while MessageSize>=8 do begin
  fInput[fInputIndex shr 3]:=TRNLMemoryAccess.LoadBigEndianUInt64(PRNLUInt8Array(TRNLPointer(@aMessage))^[MessagePosition]);
  inc(fInputIndex,8);
  inc(MessagePosition,8);
  dec(MessageSize,8);
  EndBlock;
 end;
 while MessageSize>0 do begin
  ProcessByte(PRNLUInt8Array(TRNLPointer(@aMessage))^[MessagePosition]);
  inc(fInputIndex);
  inc(MessagePosition);
  dec(MessageSize);
 end;
end;

procedure TRNLSHA512Context.Finalize(out aHash);
var Index:TRNLInt32;
begin
 Increment(fInputSize,fInputIndex shl 3);
 ProcessByte($80);
 if fInputIndex>111 then begin
  Compress;
  ResetInput;
 end;
 fInput[14]:=fInputSize[0];
 fInput[15]:=fInputSize[1];
 Compress;
 for Index:=0 to 7 do begin
  TRNLMemoryAccess.StoreBigEndianUInt64(PRNLUInt64Array(TRNLPointer(@aHash))^[Index],fState[Index]);
 end;
end;

class procedure TRNLSHA512.Process(out aHash;const aMessage;const aMessageSize:TRNLSizeUInt);
var Context:TRNLSHA512Context;
begin
 Context.Initialize;
 Context.Update(aMessage,aMessageSize);
 Context.Finalize(aHash);
end;

class procedure TRNLSHA512.SelfTest;
const Hash0:TRNLSHA512Hash=
       (
        $cf,$83,$e1,$35,$7e,$ef,$b8,$bd,
        $f1,$54,$28,$50,$d6,$6d,$80,$07,
        $d6,$20,$e4,$05,$0b,$57,$15,$dc,
        $83,$f4,$a9,$21,$d3,$6c,$e9,$ce,
        $47,$d0,$d1,$3c,$5d,$85,$f2,$b0,
        $ff,$83,$18,$d2,$87,$7e,$ec,$2f,
        $63,$b9,$31,$bd,$47,$41,$7a,$81,
        $a5,$38,$32,$7a,$f9,$27,$da,$3e
       );
       DataABC:array[0..2] of TRNLUInt8=
        (
         ord('a'),
         ord('b'),
         ord('c')
        );
       HashABC:TRNLSHA512Hash=
       (
        $dd,$af,$35,$a1,$93,$61,$7a,$ba,
        $cc,$41,$73,$49,$ae,$20,$41,$31,
        $12,$e6,$fa,$4e,$89,$a9,$7e,$a2,
        $0a,$9e,$ee,$e6,$4b,$55,$d3,$9a,
        $21,$92,$99,$2a,$27,$4f,$c1,$a8,
        $36,$ba,$3c,$23,$a3,$fe,$eb,$bd,
        $45,$4d,$44,$23,$64,$3c,$e8,$0e,
        $2a,$9a,$c9,$4f,$a5,$4c,$a4,$9f
       );
       Data0123456789abcdef:array[0..15] of TRNLUInt8=
        (
         ord('0'),
         ord('1'),
         ord('2'),
         ord('3'),
         ord('4'),
         ord('5'),
         ord('6'),
         ord('7'),
         ord('8'),
         ord('9'),
         ord('a'),
         ord('b'),
         ord('c'),
         ord('d'),
         ord('e'),
         ord('f')
        );
       Hash0123456789abcdef:TRNLSHA512Hash=
       (
        $1c,$04,$3f,$be,$4b,$ca,$7c,$79,
        $20,$da,$e5,$36,$c6,$80,$fd,$44,
        $c1,$5d,$71,$ec,$12,$cd,$82,$a2,
        $a9,$49,$1b,$00,$43,$b5,$7f,$4d,
        $0b,$89,$05,$98,$5e,$85,$ad,$13,
        $83,$1e,$e6,$d3,$9e,$55,$a5,$4e,
        $8f,$80,$8c,$c8,$2c,$41,$a0,$58,
        $29,$31,$bb,$c0,$c0,$22,$1d,$60
       );
{$if not defined(NEXTGEN)}
       DataLong:array[0..111] of TRNLRawByteChar='abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmn'+
                                                 'hijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu';
       HashLong:TRNLSHA512Hash=
       (
        $8e,$95,$9b,$75,$da,$e3,$13,$da,
        $8c,$f4,$f7,$28,$14,$fc,$14,$3f,
        $8f,$77,$79,$c6,$eb,$9f,$7f,$a1,
        $72,$99,$ae,$ad,$b6,$88,$90,$18,
        $50,$1d,$28,$9e,$49,$00,$f7,$e4,
        $33,$1b,$99,$de,$c4,$b5,$43,$3a,
        $c7,$d3,$29,$ee,$b6,$dd,$26,$54,
        $5e,$96,$e5,$5b,$87,$4b,$e9,$09
       );
{$ifend}
var Hash:TRNLSHA512Hash;
begin

 write('[SHA512] Hashing "" ... ');
 Process(Hash,TRNLPointer(nil)^,0);
 if TRNLMemory.SecureIsEqual(Hash,Hash0,SizeOf(TRNLSHA512Hash)) then begin
  writeln('OK!');
 end else begin
  writeln('FAILED!');
 end;

 write('[SHA512] Hashing "abc" ... ');
 Process(Hash,DataABC,SizeOf(DataABC));
 if TRNLMemory.SecureIsEqual(Hash,HashABC,SizeOf(TRNLSHA512Hash)) then begin
  writeln('OK!');
 end else begin
  writeln('FAILED!');
 end;

 write('[SHA512] Hashing "0123456789abcdef" ... ');
 Process(Hash,Data0123456789abcdef,SizeOf(Data0123456789abcdef));
 if TRNLMemory.SecureIsEqual(Hash,Hash0123456789abcdef,SizeOf(TRNLSHA512Hash)) then begin
  writeln('OK!');
 end else begin
  writeln('FAILED!');
 end;

{$if not defined(NEXTGEN)}
 write('[SHA512] Hashing "','abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu','" ... ');
 Process(Hash,DataLong,SizeOf(DataLong));
 if TRNLMemory.SecureIsEqual(Hash,HashLong,SizeOf(TRNLSHA512Hash)) then begin
  writeln('OK!');
 end else begin
  writeln('FAILED!');
 end;
{$ifend}

end;

class function TRNLBLAKE2BContext.RotateRight64(const aValue:TRNLUInt64;const aBits:TRNLUInt32):TRNLUInt64;
begin
{$ifdef fpc}
 result:=RORQWord(aValue,aBits);
{$else}
 result:=(aValue shl (64-aBits)) or (aValue shr aBits);
{$endif}
end;

{$if not defined(RNLUseBLAKE2BManualExpanded)}
procedure TRNLBLAKE2BContext.G(const r,i:TRNLUInt64;var a,b,c,d:TRNLUInt64;var M:TWorkVectors);
begin
 a:=a+b+M[Sigma[r,(i shl 1) or 0]];
 d:=RotateRight64(d xor a,32);
 c:=c+d;
 b:=RotateRight64(b xor c,24);
 a:=a+b+M[Sigma[r,(i shl 1) or 1]];
 d:=RotateRight64(d xor a,16);
 c:=c+d;
 b:=RotateRight64(b xor c,63);
end;

procedure TRNLBLAKE2BContext.Round_(const r:TRNLUInt64;var V,M:TWorkVectors);
begin
 G(r,0,V[0],V[4],V[8],V[12],M);
 G(r,1,V[1],V[5],V[9],V[13],M);
 G(r,2,V[2],V[6],V[10],V[14],M);
 G(r,3,V[3],V[7],V[11],V[15],M);
 G(r,4,V[0],V[5],V[10],V[15],M);
 G(r,5,V[1],V[6],V[11],V[12],M);
 G(r,6,V[2],V[7],V[8],V[13],M);
 G(r,7,V[3],V[4],V[9],V[14],M);
end;
{$ifend}

procedure TRNLBLAKE2BContext.Compress(const aLast:boolean);
var V,M:TWorkVectors;
begin
 M[0]:=TRNLMemoryAccess.LoadLittleEndianUInt64(PRNLUInt64Array(Pointer(@fBuffer))^[0]);
 M[1]:=TRNLMemoryAccess.LoadLittleEndianUInt64(PRNLUInt64Array(Pointer(@fBuffer))^[1]);
 M[2]:=TRNLMemoryAccess.LoadLittleEndianUInt64(PRNLUInt64Array(Pointer(@fBuffer))^[2]);
 M[3]:=TRNLMemoryAccess.LoadLittleEndianUInt64(PRNLUInt64Array(Pointer(@fBuffer))^[3]);
 M[4]:=TRNLMemoryAccess.LoadLittleEndianUInt64(PRNLUInt64Array(Pointer(@fBuffer))^[4]);
 M[5]:=TRNLMemoryAccess.LoadLittleEndianUInt64(PRNLUInt64Array(Pointer(@fBuffer))^[5]);
 M[6]:=TRNLMemoryAccess.LoadLittleEndianUInt64(PRNLUInt64Array(Pointer(@fBuffer))^[6]);
 M[7]:=TRNLMemoryAccess.LoadLittleEndianUInt64(PRNLUInt64Array(Pointer(@fBuffer))^[7]);
 M[8]:=TRNLMemoryAccess.LoadLittleEndianUInt64(PRNLUInt64Array(Pointer(@fBuffer))^[8]);
 M[9]:=TRNLMemoryAccess.LoadLittleEndianUInt64(PRNLUInt64Array(Pointer(@fBuffer))^[9]);
 M[10]:=TRNLMemoryAccess.LoadLittleEndianUInt64(PRNLUInt64Array(Pointer(@fBuffer))^[10]);
 M[11]:=TRNLMemoryAccess.LoadLittleEndianUInt64(PRNLUInt64Array(Pointer(@fBuffer))^[11]);
 M[12]:=TRNLMemoryAccess.LoadLittleEndianUInt64(PRNLUInt64Array(Pointer(@fBuffer))^[12]);
 M[13]:=TRNLMemoryAccess.LoadLittleEndianUInt64(PRNLUInt64Array(Pointer(@fBuffer))^[13]);
 M[14]:=TRNLMemoryAccess.LoadLittleEndianUInt64(PRNLUInt64Array(Pointer(@fBuffer))^[14]);
 M[15]:=TRNLMemoryAccess.LoadLittleEndianUInt64(PRNLUInt64Array(Pointer(@fBuffer))^[15]);
 V[0]:=fH[0];
 V[1]:=fH[1];
 V[2]:=fH[2];
 V[3]:=fH[3];
 V[4]:=fH[4];
 V[5]:=fH[5];
 V[6]:=fH[6];
 V[7]:=fH[7];
 V[8]:=InitializationVectors[0];
 V[9]:=InitializationVectors[1];
 V[10]:=InitializationVectors[2];
 V[11]:=InitializationVectors[3];
 V[12]:=InitializationVectors[4] xor fT[0];
 V[13]:=InitializationVectors[5] xor fT[1];
 if aLast then begin
  V[14]:=not InitializationVectors[6];
 end else begin
  V[14]:=InitializationVectors[6];
 end;
 V[15]:=InitializationVectors[7];
{$if defined(RNLUseBLAKE2BManualExpanded)}
 inc(v[0],v[4]+M[Sigma[0,(0 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[0],32);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],24);
 inc(v[0],v[4]+M[Sigma[0,(0 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[0],16);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],63);
 inc(v[1],v[5]+M[Sigma[0,(1 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[1],32);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],24);
 inc(v[1],v[5]+M[Sigma[0,(1 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[1],16);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],63);
 inc(v[2],v[6]+M[Sigma[0,(2 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[2],32);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],24);
 inc(v[2],v[6]+M[Sigma[0,(2 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[2],16);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],63);
 inc(v[3],v[7]+M[Sigma[0,(3 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[3],32);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],24);
 inc(v[3],v[7]+M[Sigma[0,(3 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[3],16);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],63);
 inc(v[0],v[5]+M[Sigma[0,(4 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[0],32);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],24);
 inc(v[0],v[5]+M[Sigma[0,(4 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[0],16);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],63);
 inc(v[1],v[6]+M[Sigma[0,(5 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[1],32);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],24);
 inc(v[1],v[6]+M[Sigma[0,(5 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[1],16);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],63);
 inc(v[2],v[7]+M[Sigma[0,(6 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[2],32);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],24);
 inc(v[2],v[7]+M[Sigma[0,(6 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[2],16);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],63);
 inc(v[3],v[4]+M[Sigma[0,(7 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[3],32);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],24);
 inc(v[3],v[4]+M[Sigma[0,(7 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[3],16);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],63);
 inc(v[0],v[4]+M[Sigma[1,(0 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[0],32);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],24);
 inc(v[0],v[4]+M[Sigma[1,(0 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[0],16);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],63);
 inc(v[1],v[5]+M[Sigma[1,(1 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[1],32);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],24);
 inc(v[1],v[5]+M[Sigma[1,(1 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[1],16);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],63);
 inc(v[2],v[6]+M[Sigma[1,(2 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[2],32);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],24);
 inc(v[2],v[6]+M[Sigma[1,(2 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[2],16);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],63);
 inc(v[3],v[7]+M[Sigma[1,(3 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[3],32);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],24);
 inc(v[3],v[7]+M[Sigma[1,(3 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[3],16);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],63);
 inc(v[0],v[5]+M[Sigma[1,(4 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[0],32);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],24);
 inc(v[0],v[5]+M[Sigma[1,(4 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[0],16);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],63);
 inc(v[1],v[6]+M[Sigma[1,(5 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[1],32);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],24);
 inc(v[1],v[6]+M[Sigma[1,(5 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[1],16);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],63);
 inc(v[2],v[7]+M[Sigma[1,(6 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[2],32);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],24);
 inc(v[2],v[7]+M[Sigma[1,(6 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[2],16);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],63);
 inc(v[3],v[4]+M[Sigma[1,(7 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[3],32);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],24);
 inc(v[3],v[4]+M[Sigma[1,(7 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[3],16);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],63);
 inc(v[0],v[4]+M[Sigma[2,(0 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[0],32);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],24);
 inc(v[0],v[4]+M[Sigma[2,(0 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[0],16);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],63);
 inc(v[1],v[5]+M[Sigma[2,(1 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[1],32);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],24);
 inc(v[1],v[5]+M[Sigma[2,(1 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[1],16);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],63);
 inc(v[2],v[6]+M[Sigma[2,(2 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[2],32);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],24);
 inc(v[2],v[6]+M[Sigma[2,(2 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[2],16);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],63);
 inc(v[3],v[7]+M[Sigma[2,(3 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[3],32);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],24);
 inc(v[3],v[7]+M[Sigma[2,(3 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[3],16);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],63);
 inc(v[0],v[5]+M[Sigma[2,(4 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[0],32);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],24);
 inc(v[0],v[5]+M[Sigma[2,(4 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[0],16);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],63);
 inc(v[1],v[6]+M[Sigma[2,(5 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[1],32);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],24);
 inc(v[1],v[6]+M[Sigma[2,(5 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[1],16);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],63);
 inc(v[2],v[7]+M[Sigma[2,(6 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[2],32);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],24);
 inc(v[2],v[7]+M[Sigma[2,(6 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[2],16);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],63);
 inc(v[3],v[4]+M[Sigma[2,(7 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[3],32);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],24);
 inc(v[3],v[4]+M[Sigma[2,(7 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[3],16);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],63);
 inc(v[0],v[4]+M[Sigma[3,(0 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[0],32);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],24);
 inc(v[0],v[4]+M[Sigma[3,(0 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[0],16);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],63);
 inc(v[1],v[5]+M[Sigma[3,(1 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[1],32);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],24);
 inc(v[1],v[5]+M[Sigma[3,(1 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[1],16);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],63);
 inc(v[2],v[6]+M[Sigma[3,(2 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[2],32);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],24);
 inc(v[2],v[6]+M[Sigma[3,(2 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[2],16);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],63);
 inc(v[3],v[7]+M[Sigma[3,(3 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[3],32);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],24);
 inc(v[3],v[7]+M[Sigma[3,(3 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[3],16);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],63);
 inc(v[0],v[5]+M[Sigma[3,(4 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[0],32);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],24);
 inc(v[0],v[5]+M[Sigma[3,(4 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[0],16);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],63);
 inc(v[1],v[6]+M[Sigma[3,(5 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[1],32);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],24);
 inc(v[1],v[6]+M[Sigma[3,(5 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[1],16);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],63);
 inc(v[2],v[7]+M[Sigma[3,(6 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[2],32);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],24);
 inc(v[2],v[7]+M[Sigma[3,(6 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[2],16);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],63);
 inc(v[3],v[4]+M[Sigma[3,(7 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[3],32);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],24);
 inc(v[3],v[4]+M[Sigma[3,(7 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[3],16);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],63);
 inc(v[0],v[4]+M[Sigma[4,(0 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[0],32);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],24);
 inc(v[0],v[4]+M[Sigma[4,(0 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[0],16);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],63);
 inc(v[1],v[5]+M[Sigma[4,(1 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[1],32);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],24);
 inc(v[1],v[5]+M[Sigma[4,(1 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[1],16);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],63);
 inc(v[2],v[6]+M[Sigma[4,(2 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[2],32);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],24);
 inc(v[2],v[6]+M[Sigma[4,(2 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[2],16);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],63);
 inc(v[3],v[7]+M[Sigma[4,(3 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[3],32);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],24);
 inc(v[3],v[7]+M[Sigma[4,(3 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[3],16);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],63);
 inc(v[0],v[5]+M[Sigma[4,(4 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[0],32);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],24);
 inc(v[0],v[5]+M[Sigma[4,(4 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[0],16);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],63);
 inc(v[1],v[6]+M[Sigma[4,(5 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[1],32);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],24);
 inc(v[1],v[6]+M[Sigma[4,(5 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[1],16);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],63);
 inc(v[2],v[7]+M[Sigma[4,(6 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[2],32);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],24);
 inc(v[2],v[7]+M[Sigma[4,(6 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[2],16);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],63);
 inc(v[3],v[4]+M[Sigma[4,(7 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[3],32);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],24);
 inc(v[3],v[4]+M[Sigma[4,(7 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[3],16);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],63);
 inc(v[0],v[4]+M[Sigma[5,(0 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[0],32);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],24);
 inc(v[0],v[4]+M[Sigma[5,(0 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[0],16);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],63);
 inc(v[1],v[5]+M[Sigma[5,(1 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[1],32);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],24);
 inc(v[1],v[5]+M[Sigma[5,(1 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[1],16);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],63);
 inc(v[2],v[6]+M[Sigma[5,(2 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[2],32);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],24);
 inc(v[2],v[6]+M[Sigma[5,(2 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[2],16);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],63);
 inc(v[3],v[7]+M[Sigma[5,(3 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[3],32);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],24);
 inc(v[3],v[7]+M[Sigma[5,(3 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[3],16);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],63);
 inc(v[0],v[5]+M[Sigma[5,(4 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[0],32);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],24);
 inc(v[0],v[5]+M[Sigma[5,(4 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[0],16);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],63);
 inc(v[1],v[6]+M[Sigma[5,(5 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[1],32);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],24);
 inc(v[1],v[6]+M[Sigma[5,(5 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[1],16);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],63);
 inc(v[2],v[7]+M[Sigma[5,(6 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[2],32);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],24);
 inc(v[2],v[7]+M[Sigma[5,(6 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[2],16);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],63);
 inc(v[3],v[4]+M[Sigma[5,(7 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[3],32);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],24);
 inc(v[3],v[4]+M[Sigma[5,(7 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[3],16);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],63);
 inc(v[0],v[4]+M[Sigma[6,(0 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[0],32);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],24);
 inc(v[0],v[4]+M[Sigma[6,(0 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[0],16);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],63);
 inc(v[1],v[5]+M[Sigma[6,(1 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[1],32);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],24);
 inc(v[1],v[5]+M[Sigma[6,(1 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[1],16);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],63);
 inc(v[2],v[6]+M[Sigma[6,(2 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[2],32);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],24);
 inc(v[2],v[6]+M[Sigma[6,(2 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[2],16);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],63);
 inc(v[3],v[7]+M[Sigma[6,(3 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[3],32);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],24);
 inc(v[3],v[7]+M[Sigma[6,(3 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[3],16);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],63);
 inc(v[0],v[5]+M[Sigma[6,(4 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[0],32);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],24);
 inc(v[0],v[5]+M[Sigma[6,(4 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[0],16);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],63);
 inc(v[1],v[6]+M[Sigma[6,(5 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[1],32);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],24);
 inc(v[1],v[6]+M[Sigma[6,(5 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[1],16);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],63);
 inc(v[2],v[7]+M[Sigma[6,(6 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[2],32);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],24);
 inc(v[2],v[7]+M[Sigma[6,(6 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[2],16);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],63);
 inc(v[3],v[4]+M[Sigma[6,(7 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[3],32);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],24);
 inc(v[3],v[4]+M[Sigma[6,(7 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[3],16);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],63);
 inc(v[0],v[4]+M[Sigma[7,(0 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[0],32);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],24);
 inc(v[0],v[4]+M[Sigma[7,(0 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[0],16);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],63);
 inc(v[1],v[5]+M[Sigma[7,(1 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[1],32);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],24);
 inc(v[1],v[5]+M[Sigma[7,(1 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[1],16);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],63);
 inc(v[2],v[6]+M[Sigma[7,(2 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[2],32);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],24);
 inc(v[2],v[6]+M[Sigma[7,(2 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[2],16);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],63);
 inc(v[3],v[7]+M[Sigma[7,(3 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[3],32);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],24);
 inc(v[3],v[7]+M[Sigma[7,(3 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[3],16);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],63);
 inc(v[0],v[5]+M[Sigma[7,(4 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[0],32);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],24);
 inc(v[0],v[5]+M[Sigma[7,(4 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[0],16);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],63);
 inc(v[1],v[6]+M[Sigma[7,(5 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[1],32);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],24);
 inc(v[1],v[6]+M[Sigma[7,(5 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[1],16);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],63);
 inc(v[2],v[7]+M[Sigma[7,(6 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[2],32);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],24);
 inc(v[2],v[7]+M[Sigma[7,(6 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[2],16);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],63);
 inc(v[3],v[4]+M[Sigma[7,(7 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[3],32);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],24);
 inc(v[3],v[4]+M[Sigma[7,(7 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[3],16);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],63);
 inc(v[0],v[4]+M[Sigma[8,(0 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[0],32);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],24);
 inc(v[0],v[4]+M[Sigma[8,(0 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[0],16);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],63);
 inc(v[1],v[5]+M[Sigma[8,(1 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[1],32);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],24);
 inc(v[1],v[5]+M[Sigma[8,(1 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[1],16);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],63);
 inc(v[2],v[6]+M[Sigma[8,(2 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[2],32);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],24);
 inc(v[2],v[6]+M[Sigma[8,(2 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[2],16);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],63);
 inc(v[3],v[7]+M[Sigma[8,(3 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[3],32);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],24);
 inc(v[3],v[7]+M[Sigma[8,(3 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[3],16);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],63);
 inc(v[0],v[5]+M[Sigma[8,(4 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[0],32);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],24);
 inc(v[0],v[5]+M[Sigma[8,(4 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[0],16);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],63);
 inc(v[1],v[6]+M[Sigma[8,(5 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[1],32);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],24);
 inc(v[1],v[6]+M[Sigma[8,(5 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[1],16);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],63);
 inc(v[2],v[7]+M[Sigma[8,(6 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[2],32);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],24);
 inc(v[2],v[7]+M[Sigma[8,(6 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[2],16);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],63);
 inc(v[3],v[4]+M[Sigma[8,(7 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[3],32);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],24);
 inc(v[3],v[4]+M[Sigma[8,(7 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[3],16);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],63);
 inc(v[0],v[4]+M[Sigma[9,(0 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[0],32);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],24);
 inc(v[0],v[4]+M[Sigma[9,(0 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[0],16);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],63);
 inc(v[1],v[5]+M[Sigma[9,(1 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[1],32);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],24);
 inc(v[1],v[5]+M[Sigma[9,(1 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[1],16);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],63);
 inc(v[2],v[6]+M[Sigma[9,(2 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[2],32);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],24);
 inc(v[2],v[6]+M[Sigma[9,(2 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[2],16);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],63);
 inc(v[3],v[7]+M[Sigma[9,(3 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[3],32);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],24);
 inc(v[3],v[7]+M[Sigma[9,(3 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[3],16);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],63);
 inc(v[0],v[5]+M[Sigma[9,(4 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[0],32);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],24);
 inc(v[0],v[5]+M[Sigma[9,(4 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[0],16);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],63);
 inc(v[1],v[6]+M[Sigma[9,(5 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[1],32);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],24);
 inc(v[1],v[6]+M[Sigma[9,(5 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[1],16);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],63);
 inc(v[2],v[7]+M[Sigma[9,(6 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[2],32);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],24);
 inc(v[2],v[7]+M[Sigma[9,(6 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[2],16);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],63);
 inc(v[3],v[4]+M[Sigma[9,(7 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[3],32);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],24);
 inc(v[3],v[4]+M[Sigma[9,(7 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[3],16);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],63);
 inc(v[0],v[4]+M[Sigma[10,(0 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[0],32);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],24);
 inc(v[0],v[4]+M[Sigma[10,(0 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[0],16);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],63);
 inc(v[1],v[5]+M[Sigma[10,(1 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[1],32);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],24);
 inc(v[1],v[5]+M[Sigma[10,(1 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[1],16);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],63);
 inc(v[2],v[6]+M[Sigma[10,(2 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[2],32);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],24);
 inc(v[2],v[6]+M[Sigma[10,(2 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[2],16);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],63);
 inc(v[3],v[7]+M[Sigma[10,(3 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[3],32);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],24);
 inc(v[3],v[7]+M[Sigma[10,(3 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[3],16);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],63);
 inc(v[0],v[5]+M[Sigma[10,(4 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[0],32);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],24);
 inc(v[0],v[5]+M[Sigma[10,(4 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[0],16);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],63);
 inc(v[1],v[6]+M[Sigma[10,(5 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[1],32);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],24);
 inc(v[1],v[6]+M[Sigma[10,(5 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[1],16);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],63);
 inc(v[2],v[7]+M[Sigma[10,(6 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[2],32);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],24);
 inc(v[2],v[7]+M[Sigma[10,(6 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[2],16);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],63);
 inc(v[3],v[4]+M[Sigma[10,(7 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[3],32);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],24);
 inc(v[3],v[4]+M[Sigma[10,(7 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[3],16);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],63);
 inc(v[0],v[4]+M[Sigma[11,(0 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[0],32);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],24);
 inc(v[0],v[4]+M[Sigma[11,(0 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[0],16);
 inc(v[8],v[12]);
 v[4]:=RotateRight64(v[4] xor v[8],63);
 inc(v[1],v[5]+M[Sigma[11,(1 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[1],32);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],24);
 inc(v[1],v[5]+M[Sigma[11,(1 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[1],16);
 inc(v[9],v[13]);
 v[5]:=RotateRight64(v[5] xor v[9],63);
 inc(v[2],v[6]+M[Sigma[11,(2 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[2],32);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],24);
 inc(v[2],v[6]+M[Sigma[11,(2 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[2],16);
 inc(v[10],v[14]);
 v[6]:=RotateRight64(v[6] xor v[10],63);
 inc(v[3],v[7]+M[Sigma[11,(3 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[3],32);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],24);
 inc(v[3],v[7]+M[Sigma[11,(3 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[3],16);
 inc(v[11],v[15]);
 v[7]:=RotateRight64(v[7] xor v[11],63);
 inc(v[0],v[5]+M[Sigma[11,(4 shl 1) or 0]]);
 v[15]:=RotateRight64(v[15] xor v[0],32);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],24);
 inc(v[0],v[5]+M[Sigma[11,(4 shl 1) or 1]]);
 v[15]:=RotateRight64(v[15] xor v[0],16);
 inc(v[10],v[15]);
 v[5]:=RotateRight64(v[5] xor v[10],63);
 inc(v[1],v[6]+M[Sigma[11,(5 shl 1) or 0]]);
 v[12]:=RotateRight64(v[12] xor v[1],32);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],24);
 inc(v[1],v[6]+M[Sigma[11,(5 shl 1) or 1]]);
 v[12]:=RotateRight64(v[12] xor v[1],16);
 inc(v[11],v[12]);
 v[6]:=RotateRight64(v[6] xor v[11],63);
 inc(v[2],v[7]+M[Sigma[11,(6 shl 1) or 0]]);
 v[13]:=RotateRight64(v[13] xor v[2],32);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],24);
 inc(v[2],v[7]+M[Sigma[11,(6 shl 1) or 1]]);
 v[13]:=RotateRight64(v[13] xor v[2],16);
 inc(v[8],v[13]);
 v[7]:=RotateRight64(v[7] xor v[8],63);
 inc(v[3],v[4]+M[Sigma[11,(7 shl 1) or 0]]);
 v[14]:=RotateRight64(v[14] xor v[3],32);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],24);
 inc(v[3],v[4]+M[Sigma[11,(7 shl 1) or 1]]);
 v[14]:=RotateRight64(v[14] xor v[3],16);
 inc(v[9],v[14]);
 v[4]:=RotateRight64(v[4] xor v[9],63);
{$else}
 Round_(0,V,M);
 Round_(1,V,M);
 Round_(2,V,M);
 Round_(3,V,M);
 Round_(4,V,M);
 Round_(5,V,M);
 Round_(6,V,M);
 Round_(7,V,M);
 Round_(8,V,M);
 Round_(9,V,M);
 Round_(10,V,M);
 Round_(11,V,M);
{$ifend}
 fH[0]:=fH[0] xor (V[0] xor V[8]);
 fH[1]:=fH[1] xor (V[1] xor V[9]);
 fH[2]:=fH[2] xor (V[2] xor V[10]);
 fH[3]:=fH[3] xor (V[3] xor V[11]);
 fH[4]:=fH[4] xor (V[4] xor V[12]);
 fH[5]:=fH[5] xor (V[5] xor V[13]);
 fH[6]:=fH[6] xor (V[6] xor V[14]);
 fH[7]:=fH[7] xor (V[7] xor V[15]);
end;

function TRNLBLAKE2BContext.Initialize(const aOutLen:TRNLSizeInt;const aKey:Pointer;const aKeyLen:TRNLSizeInt):boolean;
var Block:TRNLBLAKE2BBlock;
    KeyLen:TRNLSizeInt;
begin

 if (aOutLen=0) or (aOutLen>BLAKE2B_OUTBYTES) then begin
  result:=false;
  exit;
 end;

 if assigned(aKey) then begin
  KeyLen:=aKeyLen;
 end else begin
  KeyLen:=0;
 end;

 if KeyLen>BLAKE2B_KEYBYTES then begin
  result:=false;
  exit;
 end;

 fH[0]:=InitializationVectors[0] xor (($01010000 xor ((KeyLen and $ff) shl 8)) xor (aOutLen and $ff));
 fH[1]:=InitializationVectors[1];
 fH[2]:=InitializationVectors[2];
 fH[3]:=InitializationVectors[3];
 fH[4]:=InitializationVectors[4];
 fH[5]:=InitializationVectors[5];
 fH[6]:=InitializationVectors[6];
 fH[7]:=InitializationVectors[7];
 fT[0]:=0;
 fT[1]:=0;
 FillChar(fBuffer,SizeOf(TRNLBLAKE2BBlock),#0);
 fBufferLen:=0;
 fOutLen:=aOutLen;

 FillChar(Block,SizeOf(TRNLBLAKE2BBlock),#0);
 if KeyLen>0 then begin
  Move(aKey^,Block,KeyLen);
  Update(Block,SizeOf(TRNLBLAKE2BBlock));
  FillChar(Block,SizeOf(TRNLBLAKE2BBlock),#0);
 end;

 result:=true;
end;

procedure TRNLBLAKE2BContext.Update(const aMessage;const aMessageSize:TRNLSizeUInt);
var Position,Remaining,ToDo,Available:TRNLSizeUInt;
begin
 Position:=0;
 Remaining:=aMessageSize;
 while Remaining>0 do begin
  if fBufferLen>=BLAKE2B_BLOCKBYTES then begin
   inc(fT[0],fBufferLen);
   if fT[0]<fBufferLen then begin
    inc(fT[1]);
   end;
   Compress(false);
   fBufferLen:=0;
  end;
  Available:=BLAKE2B_BLOCKBYTES-fBufferLen;
  if Remaining<Available then begin
   ToDo:=Remaining;
  end else begin
   ToDo:=Available;
  end;
  if ToDo>0 then begin
   Move(PRNLUInt8Array(@aMessage)^[Position],fBuffer[fBufferLen],ToDo);
   inc(fBufferLen,ToDo);
   inc(Position,ToDo);
   dec(Remaining,ToDo);
  end else begin
   break;
  end;
 end;
end;

procedure TRNLBLAKE2BContext.Finalize(out aHash);
begin
 inc(fT[0],fBufferLen);
 if fT[0]<fBufferLen then begin
  inc(fT[1]);
 end;
 if fBufferLen<BLAKE2B_BLOCKBYTES then begin
  FillChar(fBuffer[fBufferLen],BLAKE2B_BLOCKBYTES-fBufferLen,#0);
  fBufferLen:=BLAKE2B_BLOCKBYTES;
 end;
 Compress(true);
 TRNLMemoryAccess.StoreLittleEndianUInt64(PRNLUInt64Array(@fBuffer)^[0],fH[0]);
 TRNLMemoryAccess.StoreLittleEndianUInt64(PRNLUInt64Array(@fBuffer)^[1],fH[1]);
 TRNLMemoryAccess.StoreLittleEndianUInt64(PRNLUInt64Array(@fBuffer)^[2],fH[2]);
 TRNLMemoryAccess.StoreLittleEndianUInt64(PRNLUInt64Array(@fBuffer)^[3],fH[3]);
 TRNLMemoryAccess.StoreLittleEndianUInt64(PRNLUInt64Array(@fBuffer)^[4],fH[4]);
 TRNLMemoryAccess.StoreLittleEndianUInt64(PRNLUInt64Array(@fBuffer)^[5],fH[5]);
 TRNLMemoryAccess.StoreLittleEndianUInt64(PRNLUInt64Array(@fBuffer)^[6],fH[6]);
 TRNLMemoryAccess.StoreLittleEndianUInt64(PRNLUInt64Array(@fBuffer)^[7],fH[7]);
 System.Move(fBuffer,aHash,fOutLen);
 FillChar(fBuffer,SizeOf(TRNLBLAKE2BBlock),#0);
end;

class function TRNLBLAKE2B.Process(out aHash;const aMessage;const aMessageSize:TRNLSizeUInt;const aOutLen:TRNLSizeInt;const aKey:Pointer;const aKeyLen:TRNLSizeInt):boolean;
var Context:TRNLBLAKE2BContext;
begin
 if (not assigned(Pointer(@aMessage))) and (aMessageSize>0) then begin
  result:=false;
  exit;
 end;
 if not assigned(Pointer(@aHash)) then begin
  result:=false;
  exit;
 end;
 if (aOutLen=0) or (aOutLen>TRNLBLAKE2BContext.BLAKE2B_OUTBYTES) then begin
  result:=false;
  exit;
 end;
 if assigned(aKey) and (aKeyLen>TRNLBLAKE2BContext.BLAKE2B_KEYBYTES) then begin
  result:=false;
  exit;
 end;
 result:=Context.Initialize(aOutLen,aKey,aKeyLen);
 if result then begin
  Context.Update(aMessage,aMessageSize);
  Context.Finalize(aHash);
 end;
end;

class procedure TRNLBLAKE2B.SelfTest;
 procedure RFC7693Test;
 const BLACK2B_RES:TRNLBLAKE2BHash=
        (
         $C2,$3A,$78,$00,$D9,$81,$23,$BD,
         $10,$F5,$06,$C6,$1E,$29,$DA,$56,
         $03,$D7,$63,$B8,$BB,$AD,$2E,$73,
         $7F,$5E,$76,$5A,$7B,$CC,$D4,$75,
         $00,$00,$00,$00,$00,$00,$00,$00,
         $00,$00,$00,$00,$00,$00,$00,$00,
         $00,$00,$00,$00,$00,$00,$00,$00,
         $00,$00,$00,$00,$00,$00,$00,$00
        );
       b2b_md_len:array[0..3] of TRNLInt32=(20,32,48,64);
       b2b_in_len:array[0..5] of TRNLInt32=(0,3,128,129,255,1024);
  procedure SelfTestSeq(const aOut:PRNLUInt8Array;const aLen:TRNLSizeInt;const aSeed:TRNLUInt32);
  var Index:TRNLSizeInt;
      t,a,b:TRNLUInt32;
  begin
   a:=$DEAD4BAD*aSeed;
   b:=1;
   for Index:=0 to aLen-1 do begin
    t:=a+b;
    a:=b;
    b:=t;
    aOut^[Index]:=(t shr 24) and $ff;
   end;
  end;
 var i,j,OutLen,InLen:TRNLSizeInt;
     In_:array[0..1023] of TRNLUInt8;
     MD:array[0..63] of TRNLUInt8;
     Key_:array[0..63] of TRNLUInt8;
     Context:TRNLBLAKE2BContext;
 begin
  write('[BLAKE2B] Testing RFC7693 test ... ');
  Context.Initialize(32);
  for i:=0 to 3 do begin
   OutLen:=b2b_md_len[i];
   for j:=0 to 5 do begin
    InLen:=b2b_in_len[j];
    SelfTestSeq(@In_,InLen,InLen);
    TRNLBLAKE2B.Process(MD,In_,InLen,OutLen,nil,0);
    Context.Update(MD,OutLen);
    SelfTestSeq(@Key_,OutLen,OutLen);
    TRNLBLAKE2B.Process(MD,In_,InLen,OutLen,@Key_,OutLen);
    Context.Update(MD,OutLen);
   end;
  end;
  Context.Finalize(MD);
  if TRNLMemory.SecureIsEqual(MD,BLACK2B_RES,32) then begin
   writeln('OK!');
  end else begin
   writeln('FAILED!');
  end;
 end;
 procedure OfficalTest;
 const BLAKE2_KAT_LENGTH=256;
       BLAKB2B_KEYED_KAT:array[0..BLAKE2_KAT_LENGTH-1] of TRNLBLAKE2BHash=
        (
         (
          $10,$EB,$B6,$77,$00,$B1,$86,$8E,
          $FB,$44,$17,$98,$7A,$CF,$46,$90,
          $AE,$9D,$97,$2F,$B7,$A5,$90,$C2,
          $F0,$28,$71,$79,$9A,$AA,$47,$86,
          $B5,$E9,$96,$E8,$F0,$F4,$EB,$98,
          $1F,$C2,$14,$B0,$05,$F4,$2D,$2F,
          $F4,$23,$34,$99,$39,$16,$53,$DF,
          $7A,$EF,$CB,$C1,$3F,$C5,$15,$68
         ),
         (
          $96,$1F,$6D,$D1,$E4,$DD,$30,$F6,
          $39,$01,$69,$0C,$51,$2E,$78,$E4,
          $B4,$5E,$47,$42,$ED,$19,$7C,$3C,
          $5E,$45,$C5,$49,$FD,$25,$F2,$E4,
          $18,$7B,$0B,$C9,$FE,$30,$49,$2B,
          $16,$B0,$D0,$BC,$4E,$F9,$B0,$F3,
          $4C,$70,$03,$FA,$C0,$9A,$5E,$F1,
          $53,$2E,$69,$43,$02,$34,$CE,$BD
         ),
         (
          $DA,$2C,$FB,$E2,$D8,$40,$9A,$0F,
          $38,$02,$61,$13,$88,$4F,$84,$B5,
          $01,$56,$37,$1A,$E3,$04,$C4,$43,
          $01,$73,$D0,$8A,$99,$D9,$FB,$1B,
          $98,$31,$64,$A3,$77,$07,$06,$D5,
          $37,$F4,$9E,$0C,$91,$6D,$9F,$32,
          $B9,$5C,$C3,$7A,$95,$B9,$9D,$85,
          $74,$36,$F0,$23,$2C,$88,$A9,$65
         ),
         (
          $33,$D0,$82,$5D,$DD,$F7,$AD,$A9,
          $9B,$0E,$7E,$30,$71,$04,$AD,$07,
          $CA,$9C,$FD,$96,$92,$21,$4F,$15,
          $61,$35,$63,$15,$E7,$84,$F3,$E5,
          $A1,$7E,$36,$4A,$E9,$DB,$B1,$4C,
          $B2,$03,$6D,$F9,$32,$B7,$7F,$4B,
          $29,$27,$61,$36,$5F,$B3,$28,$DE,
          $7A,$FD,$C6,$D8,$99,$8F,$5F,$C1
         ),
         (
          $BE,$AA,$5A,$3D,$08,$F3,$80,$71,
          $43,$CF,$62,$1D,$95,$CD,$69,$05,
          $14,$D0,$B4,$9E,$FF,$F9,$C9,$1D,
          $24,$B5,$92,$41,$EC,$0E,$EF,$A5,
          $F6,$01,$96,$D4,$07,$04,$8B,$BA,
          $8D,$21,$46,$82,$8E,$BC,$B0,$48,
          $8D,$88,$42,$FD,$56,$BB,$4F,$6D,
          $F8,$E1,$9C,$4B,$4D,$AA,$B8,$AC
         ),
         (
          $09,$80,$84,$B5,$1F,$D1,$3D,$EA,
          $E5,$F4,$32,$0D,$E9,$4A,$68,$8E,
          $E0,$7B,$AE,$A2,$80,$04,$86,$68,
          $9A,$86,$36,$11,$7B,$46,$C1,$F4,
          $C1,$F6,$AF,$7F,$74,$AE,$7C,$85,
          $76,$00,$45,$6A,$58,$A3,$AF,$25,
          $1D,$C4,$72,$3A,$64,$CC,$7C,$0A,
          $5A,$B6,$D9,$CA,$C9,$1C,$20,$BB
         ),
         (
          $60,$44,$54,$0D,$56,$08,$53,$EB,
          $1C,$57,$DF,$00,$77,$DD,$38,$10,
          $94,$78,$1C,$DB,$90,$73,$E5,$B1,
          $B3,$D3,$F6,$C7,$82,$9E,$12,$06,
          $6B,$BA,$CA,$96,$D9,$89,$A6,$90,
          $DE,$72,$CA,$31,$33,$A8,$36,$52,
          $BA,$28,$4A,$6D,$62,$94,$2B,$27,
          $1F,$FA,$26,$20,$C9,$E7,$5B,$1F
         ),
         (
          $7A,$8C,$FE,$9B,$90,$F7,$5F,$7E,
          $CB,$3A,$CC,$05,$3A,$AE,$D6,$19,
          $31,$12,$B6,$F6,$A4,$AE,$EB,$3F,
          $65,$D3,$DE,$54,$19,$42,$DE,$B9,
          $E2,$22,$81,$52,$A3,$C4,$BB,$BE,
          $72,$FC,$3B,$12,$62,$95,$28,$CF,
          $BB,$09,$FE,$63,$0F,$04,$74,$33,
          $9F,$54,$AB,$F4,$53,$E2,$ED,$52
         ),
         (
          $38,$0B,$EA,$F6,$EA,$7C,$C9,$36,
          $5E,$27,$0E,$F0,$E6,$F3,$A6,$4F,
          $B9,$02,$AC,$AE,$51,$DD,$55,$12,
          $F8,$42,$59,$AD,$2C,$91,$F4,$BC,
          $41,$08,$DB,$73,$19,$2A,$5B,$BF,
          $B0,$CB,$CF,$71,$E4,$6C,$3E,$21,
          $AE,$E1,$C5,$E8,$60,$DC,$96,$E8,
          $EB,$0B,$7B,$84,$26,$E6,$AB,$E9
         ),
         (
          $60,$FE,$3C,$45,$35,$E1,$B5,$9D,
          $9A,$61,$EA,$85,$00,$BF,$AC,$41,
          $A6,$9D,$FF,$B1,$CE,$AD,$D9,$AC,
          $A3,$23,$E9,$A6,$25,$B6,$4D,$A5,
          $76,$3B,$AD,$72,$26,$DA,$02,$B9,
          $C8,$C4,$F1,$A5,$DE,$14,$0A,$C5,
          $A6,$C1,$12,$4E,$4F,$71,$8C,$E0,
          $B2,$8E,$A4,$73,$93,$AA,$66,$37
         ),
         (
          $4F,$E1,$81,$F5,$4A,$D6,$3A,$29,
          $83,$FE,$AA,$F7,$7D,$1E,$72,$35,
          $C2,$BE,$B1,$7F,$A3,$28,$B6,$D9,
          $50,$5B,$DA,$32,$7D,$F1,$9F,$C3,
          $7F,$02,$C4,$B6,$F0,$36,$8C,$E2,
          $31,$47,$31,$3A,$8E,$57,$38,$B5,
          $FA,$2A,$95,$B2,$9D,$E1,$C7,$F8,
          $26,$4E,$B7,$7B,$69,$F5,$85,$CD
         ),
         (
          $F2,$28,$77,$3C,$E3,$F3,$A4,$2B,
          $5F,$14,$4D,$63,$23,$7A,$72,$D9,
          $96,$93,$AD,$B8,$83,$7D,$0E,$11,
          $2A,$8A,$0F,$8F,$FF,$F2,$C3,$62,
          $85,$7A,$C4,$9C,$11,$EC,$74,$0D,
          $15,$00,$74,$9D,$AC,$9B,$1F,$45,
          $48,$10,$8B,$F3,$15,$57,$94,$DC,
          $C9,$E4,$08,$28,$49,$E2,$B8,$5B
         ),
         (
          $96,$24,$52,$A8,$45,$5C,$C5,$6C,
          $85,$11,$31,$7E,$3B,$1F,$3B,$2C,
          $37,$DF,$75,$F5,$88,$E9,$43,$25,
          $FD,$D7,$70,$70,$35,$9C,$F6,$3A,
          $9A,$E6,$E9,$30,$93,$6F,$DF,$8E,
          $1E,$08,$FF,$CA,$44,$0C,$FB,$72,
          $C2,$8F,$06,$D8,$9A,$21,$51,$D1,
          $C4,$6C,$D5,$B2,$68,$EF,$85,$63
         ),
         (
          $43,$D4,$4B,$FA,$18,$76,$8C,$59,
          $89,$6B,$F7,$ED,$17,$65,$CB,$2D,
          $14,$AF,$8C,$26,$02,$66,$03,$90,
          $99,$B2,$5A,$60,$3E,$4D,$DC,$50,
          $39,$D6,$EF,$3A,$91,$84,$7D,$10,
          $88,$D4,$01,$C0,$C7,$E8,$47,$78,
          $1A,$8A,$59,$0D,$33,$A3,$C6,$CB,
          $4D,$F0,$FA,$B1,$C2,$F2,$23,$55
         ),
         (
          $DC,$FF,$A9,$D5,$8C,$2A,$4C,$A2,
          $CD,$BB,$0C,$7A,$A4,$C4,$C1,$D4,
          $51,$65,$19,$00,$89,$F4,$E9,$83,
          $BB,$1C,$2C,$AB,$4A,$AE,$FF,$1F,
          $A2,$B5,$EE,$51,$6F,$EC,$D7,$80,
          $54,$02,$40,$BF,$37,$E5,$6C,$8B,
          $CC,$A7,$FA,$B9,$80,$E1,$E6,$1C,
          $94,$00,$D8,$A9,$A5,$B1,$4A,$C6
         ),
         (
          $6F,$BF,$31,$B4,$5A,$B0,$C0,$B8,
          $DA,$D1,$C0,$F5,$F4,$06,$13,$79,
          $91,$2D,$DE,$5A,$A9,$22,$09,$9A,
          $03,$0B,$72,$5C,$73,$34,$6C,$52,
          $42,$91,$AD,$EF,$89,$D2,$F6,$FD,
          $8D,$FC,$DA,$6D,$07,$DA,$D8,$11,
          $A9,$31,$45,$36,$C2,$91,$5E,$D4,
          $5D,$A3,$49,$47,$E8,$3D,$E3,$4E
         ),
         (
          $A0,$C6,$5B,$DD,$DE,$8A,$DE,$F5,
          $72,$82,$B0,$4B,$11,$E7,$BC,$8A,
          $AB,$10,$5B,$99,$23,$1B,$75,$0C,
          $02,$1F,$4A,$73,$5C,$B1,$BC,$FA,
          $B8,$75,$53,$BB,$A3,$AB,$B0,$C3,
          $E6,$4A,$0B,$69,$55,$28,$51,$85,
          $A0,$BD,$35,$FB,$8C,$FD,$E5,$57,
          $32,$9B,$EB,$B1,$F6,$29,$EE,$93
         ),
         (
          $F9,$9D,$81,$55,$50,$55,$8E,$81,
          $EC,$A2,$F9,$67,$18,$AE,$D1,$0D,
          $86,$F3,$F1,$CF,$B6,$75,$CC,$E0,
          $6B,$0E,$FF,$02,$F6,$17,$C5,$A4,
          $2C,$5A,$A7,$60,$27,$0F,$26,$79,
          $DA,$26,$77,$C5,$AE,$B9,$4F,$11,
          $42,$27,$7F,$21,$C7,$F7,$9F,$3C,
          $4F,$0C,$CE,$4E,$D8,$EE,$62,$B1
         ),
         (
          $95,$39,$1D,$A8,$FC,$7B,$91,$7A,
          $20,$44,$B3,$D6,$F5,$37,$4E,$1C,
          $A0,$72,$B4,$14,$54,$D5,$72,$C7,
          $35,$6C,$05,$FD,$4B,$C1,$E0,$F4,
          $0B,$8B,$B8,$B4,$A9,$F6,$BC,$E9,
          $BE,$2C,$46,$23,$C3,$99,$B0,$DC,
          $A0,$DA,$B0,$5C,$B7,$28,$1B,$71,
          $A2,$1B,$0E,$BC,$D9,$E5,$56,$70
         ),
         (
          $04,$B9,$CD,$3D,$20,$D2,$21,$C0,
          $9A,$C8,$69,$13,$D3,$DC,$63,$04,
          $19,$89,$A9,$A1,$E6,$94,$F1,$E6,
          $39,$A3,$BA,$7E,$45,$18,$40,$F7,
          $50,$C2,$FC,$19,$1D,$56,$AD,$61,
          $F2,$E7,$93,$6B,$C0,$AC,$8E,$09,
          $4B,$60,$CA,$EE,$D8,$78,$C1,$87,
          $99,$04,$54,$02,$D6,$1C,$EA,$F9
         ),
         (
          $EC,$0E,$0E,$F7,$07,$E4,$ED,$6C,
          $0C,$66,$F9,$E0,$89,$E4,$95,$4B,
          $05,$80,$30,$D2,$DD,$86,$39,$8F,
          $E8,$40,$59,$63,$1F,$9E,$E5,$91,
          $D9,$D7,$73,$75,$35,$51,$49,$17,
          $8C,$0C,$F8,$F8,$E7,$C4,$9E,$D2,
          $A5,$E4,$F9,$54,$88,$A2,$24,$70,
          $67,$C2,$08,$51,$0F,$AD,$C4,$4C
         ),
         (
          $9A,$37,$CC,$E2,$73,$B7,$9C,$09,
          $91,$36,$77,$51,$0E,$AF,$76,$88,
          $E8,$9B,$33,$14,$D3,$53,$2F,$D2,
          $76,$4C,$39,$DE,$02,$2A,$29,$45,
          $B5,$71,$0D,$13,$51,$7A,$F8,$DD,
          $C0,$31,$66,$24,$E7,$3B,$EC,$1C,
          $E6,$7D,$F1,$52,$28,$30,$20,$36,
          $F3,$30,$AB,$0C,$B4,$D2,$18,$DD
         ),
         (
          $4C,$F9,$BB,$8F,$B3,$D4,$DE,$8B,
          $38,$B2,$F2,$62,$D3,$C4,$0F,$46,
          $DF,$E7,$47,$E8,$FC,$0A,$41,$4C,
          $19,$3D,$9F,$CF,$75,$31,$06,$CE,
          $47,$A1,$8F,$17,$2F,$12,$E8,$A2,
          $F1,$C2,$67,$26,$54,$53,$58,$E5,
          $EE,$28,$C9,$E2,$21,$3A,$87,$87,
          $AA,$FB,$C5,$16,$D2,$34,$31,$52
         ),
         (
          $64,$E0,$C6,$3A,$F9,$C8,$08,$FD,
          $89,$31,$37,$12,$98,$67,$FD,$91,
          $93,$9D,$53,$F2,$AF,$04,$BE,$4F,
          $A2,$68,$00,$61,$00,$06,$9B,$2D,
          $69,$DA,$A5,$C5,$D8,$ED,$7F,$DD,
          $CB,$2A,$70,$EE,$EC,$DF,$2B,$10,
          $5D,$D4,$6A,$1E,$3B,$73,$11,$72,
          $8F,$63,$9A,$B4,$89,$32,$6B,$C9
         ),
         (
          $5E,$9C,$93,$15,$8D,$65,$9B,$2D,
          $EF,$06,$B0,$C3,$C7,$56,$50,$45,
          $54,$26,$62,$D6,$EE,$E8,$A9,$6A,
          $89,$B7,$8A,$DE,$09,$FE,$8B,$3D,
          $CC,$09,$6D,$4F,$E4,$88,$15,$D8,
          $8D,$8F,$82,$62,$01,$56,$60,$2A,
          $F5,$41,$95,$5E,$1F,$6C,$A3,$0D,
          $CE,$14,$E2,$54,$C3,$26,$B8,$8F
         ),
         (
          $77,$75,$DF,$F8,$89,$45,$8D,$D1,
          $1A,$EF,$41,$72,$76,$85,$3E,$21,
          $33,$5E,$B8,$8E,$4D,$EC,$9C,$FB,
          $4E,$9E,$DB,$49,$82,$00,$88,$55,
          $1A,$2C,$A6,$03,$39,$F1,$20,$66,
          $10,$11,$69,$F0,$DF,$E8,$4B,$09,
          $8F,$DD,$B1,$48,$D9,$DA,$6B,$3D,
          $61,$3D,$F2,$63,$88,$9A,$D6,$4B
         ),
         (
          $F0,$D2,$80,$5A,$FB,$B9,$1F,$74,
          $39,$51,$35,$1A,$6D,$02,$4F,$93,
          $53,$A2,$3C,$7C,$E1,$FC,$2B,$05,
          $1B,$3A,$8B,$96,$8C,$23,$3F,$46,
          $F5,$0F,$80,$6E,$CB,$15,$68,$FF,
          $AA,$0B,$60,$66,$1E,$33,$4B,$21,
          $DD,$E0,$4F,$8F,$A1,$55,$AC,$74,
          $0E,$EB,$42,$E2,$0B,$60,$D7,$64
         ),
         (
          $86,$A2,$AF,$31,$6E,$7D,$77,$54,
          $20,$1B,$94,$2E,$27,$53,$64,$AC,
          $12,$EA,$89,$62,$AB,$5B,$D8,$D7,
          $FB,$27,$6D,$C5,$FB,$FF,$C8,$F9,
          $A2,$8C,$AE,$4E,$48,$67,$DF,$67,
          $80,$D9,$B7,$25,$24,$16,$09,$27,
          $C8,$55,$DA,$5B,$60,$78,$E0,$B5,
          $54,$AA,$91,$E3,$1C,$B9,$CA,$1D
         ),
         (
          $10,$BD,$F0,$CA,$A0,$80,$27,$05,
          $E7,$06,$36,$9B,$AF,$8A,$3F,$79,
          $D7,$2C,$0A,$03,$A8,$06,$75,$A7,
          $BB,$B0,$0B,$E3,$A4,$5E,$51,$64,
          $24,$D1,$EE,$88,$EF,$B5,$6F,$6D,
          $57,$77,$54,$5A,$E6,$E2,$77,$65,
          $C3,$A8,$F5,$E4,$93,$FC,$30,$89,
          $15,$63,$89,$33,$A1,$DF,$EE,$55
         ),
         (
          $B0,$17,$81,$09,$2B,$17,$48,$45,
          $9E,$2E,$4E,$C1,$78,$69,$66,$27,
          $BF,$4E,$BA,$FE,$BB,$A7,$74,$EC,
          $F0,$18,$B7,$9A,$68,$AE,$B8,$49,
          $17,$BF,$0B,$84,$BB,$79,$D1,$7B,
          $74,$31,$51,$14,$4C,$D6,$6B,$7B,
          $33,$A4,$B9,$E5,$2C,$76,$C4,$E1,
          $12,$05,$0F,$F5,$38,$5B,$7F,$0B
         ),
         (
          $C6,$DB,$C6,$1D,$EC,$6E,$AE,$AC,
          $81,$E3,$D5,$F7,$55,$20,$3C,$8E,
          $22,$05,$51,$53,$4A,$0B,$2F,$D1,
          $05,$A9,$18,$89,$94,$5A,$63,$85,
          $50,$20,$4F,$44,$09,$3D,$D9,$98,
          $C0,$76,$20,$5D,$FF,$AD,$70,$3A,
          $0E,$5C,$D3,$C7,$F4,$38,$A7,$E6,
          $34,$CD,$59,$FE,$DE,$DB,$53,$9E
         ),
         (
          $EB,$A5,$1A,$CF,$FB,$4C,$EA,$31,
          $DB,$4B,$8D,$87,$E9,$BF,$7D,$D4,
          $8F,$E9,$7B,$02,$53,$AE,$67,$AA,
          $58,$0F,$9A,$C4,$A9,$D9,$41,$F2,
          $BE,$A5,$18,$EE,$28,$68,$18,$CC,
          $9F,$63,$3F,$2A,$3B,$9F,$B6,$8E,
          $59,$4B,$48,$CD,$D6,$D5,$15,$BF,
          $1D,$52,$BA,$6C,$85,$A2,$03,$A7
         ),
         (
          $86,$22,$1F,$3A,$DA,$52,$03,$7B,
          $72,$22,$4F,$10,$5D,$79,$99,$23,
          $1C,$5E,$55,$34,$D0,$3D,$A9,$D9,
          $C0,$A1,$2A,$CB,$68,$46,$0C,$D3,
          $75,$DA,$F8,$E2,$43,$86,$28,$6F,
          $96,$68,$F7,$23,$26,$DB,$F9,$9B,
          $A0,$94,$39,$24,$37,$D3,$98,$E9,
          $5B,$B8,$16,$1D,$71,$7F,$89,$91
         ),
         (
          $55,$95,$E0,$5C,$13,$A7,$EC,$4D,
          $C8,$F4,$1F,$B7,$0C,$B5,$0A,$71,
          $BC,$E1,$7C,$02,$4F,$F6,$DE,$7A,
          $F6,$18,$D0,$CC,$4E,$9C,$32,$D9,
          $57,$0D,$6D,$3E,$A4,$5B,$86,$52,
          $54,$91,$03,$0C,$0D,$8F,$2B,$18,
          $36,$D5,$77,$8C,$1C,$E7,$35,$C1,
          $77,$07,$DF,$36,$4D,$05,$43,$47
         ),
         (
          $CE,$0F,$4F,$6A,$CA,$89,$59,$0A,
          $37,$FE,$03,$4D,$D7,$4D,$D5,$FA,
          $65,$EB,$1C,$BD,$0A,$41,$50,$8A,
          $AD,$DC,$09,$35,$1A,$3C,$EA,$6D,
          $18,$CB,$21,$89,$C5,$4B,$70,$0C,
          $00,$9F,$4C,$BF,$05,$21,$C7,$EA,
          $01,$BE,$61,$C5,$AE,$09,$CB,$54,
          $F2,$7B,$C1,$B4,$4D,$65,$8C,$82
         ),
         (
          $7E,$E8,$0B,$06,$A2,$15,$A3,$BC,
          $A9,$70,$C7,$7C,$DA,$87,$61,$82,
          $2B,$C1,$03,$D4,$4F,$A4,$B3,$3F,
          $4D,$07,$DC,$B9,$97,$E3,$6D,$55,
          $29,$8B,$CE,$AE,$12,$24,$1B,$3F,
          $A0,$7F,$A6,$3B,$E5,$57,$60,$68,
          $DA,$38,$7B,$8D,$58,$59,$AE,$AB,
          $70,$13,$69,$84,$8B,$17,$6D,$42
         ),
         (
          $94,$0A,$84,$B6,$A8,$4D,$10,$9A,
          $AB,$20,$8C,$02,$4C,$6C,$E9,$64,
          $76,$76,$BA,$0A,$AA,$11,$F8,$6D,
          $BB,$70,$18,$F9,$FD,$22,$20,$A6,
          $D9,$01,$A9,$02,$7F,$9A,$BC,$F9,
          $35,$37,$27,$27,$CB,$F0,$9E,$BD,
          $61,$A2,$A2,$EE,$B8,$76,$53,$E8,
          $EC,$AD,$1B,$AB,$85,$DC,$83,$27
         ),
         (
          $20,$20,$B7,$82,$64,$A8,$2D,$9F,
          $41,$51,$14,$1A,$DB,$A8,$D4,$4B,
          $F2,$0C,$5E,$C0,$62,$EE,$E9,$B5,
          $95,$A1,$1F,$9E,$84,$90,$1B,$F1,
          $48,$F2,$98,$E0,$C9,$F8,$77,$7D,
          $CD,$BC,$7C,$C4,$67,$0A,$AC,$35,
          $6C,$C2,$AD,$8C,$CB,$16,$29,$F1,
          $6F,$6A,$76,$BC,$EF,$BE,$E7,$60
         ),
         (
          $D1,$B8,$97,$B0,$E0,$75,$BA,$68,
          $AB,$57,$2A,$DF,$9D,$9C,$43,$66,
          $63,$E4,$3E,$B3,$D8,$E6,$2D,$92,
          $FC,$49,$C9,$BE,$21,$4E,$6F,$27,
          $87,$3F,$E2,$15,$A6,$51,$70,$E6,
          $BE,$A9,$02,$40,$8A,$25,$B4,$95,
          $06,$F4,$7B,$AB,$D0,$7C,$EC,$F7,
          $11,$3E,$C1,$0C,$5D,$D3,$12,$52
         ),
         (
          $B1,$4D,$0C,$62,$AB,$FA,$46,$9A,
          $35,$71,$77,$E5,$94,$C1,$0C,$19,
          $42,$43,$ED,$20,$25,$AB,$8A,$A5,
          $AD,$2F,$A4,$1A,$D3,$18,$E0,$FF,
          $48,$CD,$5E,$60,$BE,$C0,$7B,$13,
          $63,$4A,$71,$1D,$23,$26,$E4,$88,
          $A9,$85,$F3,$1E,$31,$15,$33,$99,
          $E7,$30,$88,$EF,$C8,$6A,$5C,$55
         ),
         (
          $41,$69,$C5,$CC,$80,$8D,$26,$97,
          $DC,$2A,$82,$43,$0D,$C2,$3E,$3C,
          $D3,$56,$DC,$70,$A9,$45,$66,$81,
          $05,$02,$B8,$D6,$55,$B3,$9A,$BF,
          $9E,$7F,$90,$2F,$E7,$17,$E0,$38,
          $92,$19,$85,$9E,$19,$45,$DF,$1A,
          $F6,$AD,$A4,$2E,$4C,$CD,$A5,$5A,
          $19,$7B,$71,$00,$A3,$0C,$30,$A1
         ),
         (
          $25,$8A,$4E,$DB,$11,$3D,$66,$C8,
          $39,$C8,$B1,$C9,$1F,$15,$F3,$5A,
          $DE,$60,$9F,$11,$CD,$7F,$86,$81,
          $A4,$04,$5B,$9F,$EF,$7B,$0B,$24,
          $C8,$2C,$DA,$06,$A5,$F2,$06,$7B,
          $36,$88,$25,$E3,$91,$4E,$53,$D6,
          $94,$8E,$DE,$92,$EF,$D6,$E8,$38,
          $7F,$A2,$E5,$37,$23,$9B,$5B,$EE
         ),
         (
          $79,$D2,$D8,$69,$6D,$30,$F3,$0F,
          $B3,$46,$57,$76,$11,$71,$A1,$1E,
          $6C,$3F,$1E,$64,$CB,$E7,$BE,$BE,
          $E1,$59,$CB,$95,$BF,$AF,$81,$2B,
          $4F,$41,$1E,$2F,$26,$D9,$C4,$21,
          $DC,$2C,$28,$4A,$33,$42,$D8,$23,
          $EC,$29,$38,$49,$E4,$2D,$1E,$46,
          $B0,$A4,$AC,$1E,$3C,$86,$AB,$AA
         ),
         (
          $8B,$94,$36,$01,$0D,$C5,$DE,$E9,
          $92,$AE,$38,$AE,$A9,$7F,$2C,$D6,
          $3B,$94,$6D,$94,$FE,$DD,$2E,$C9,
          $67,$1D,$CD,$E3,$BD,$4C,$E9,$56,
          $4D,$55,$5C,$66,$C1,$5B,$B2,$B9,
          $00,$DF,$72,$ED,$B6,$B8,$91,$EB,
          $CA,$DF,$EF,$F6,$3C,$9E,$A4,$03,
          $6A,$99,$8B,$E7,$97,$39,$81,$E7
         ),
         (
          $C8,$F6,$8E,$69,$6E,$D2,$82,$42,
          $BF,$99,$7F,$5B,$3B,$34,$95,$95,
          $08,$E4,$2D,$61,$38,$10,$F1,$E2,
          $A4,$35,$C9,$6E,$D2,$FF,$56,$0C,
          $70,$22,$F3,$61,$A9,$23,$4B,$98,
          $37,$FE,$EE,$90,$BF,$47,$92,$2E,
          $E0,$FD,$5F,$8D,$DF,$82,$37,$18,
          $D8,$6D,$1E,$16,$C6,$09,$00,$71
         ),
         (
          $B0,$2D,$3E,$EE,$48,$60,$D5,$86,
          $8B,$2C,$39,$CE,$39,$BF,$E8,$10,
          $11,$29,$05,$64,$DD,$67,$8C,$85,
          $E8,$78,$3F,$29,$30,$2D,$FC,$13,
          $99,$BA,$95,$B6,$B5,$3C,$D9,$EB,
          $BF,$40,$0C,$CA,$1D,$B0,$AB,$67,
          $E1,$9A,$32,$5F,$2D,$11,$58,$12,
          $D2,$5D,$00,$97,$8A,$D1,$BC,$A4
         ),
         (
          $76,$93,$EA,$73,$AF,$3A,$C4,$DA,
          $D2,$1C,$A0,$D8,$DA,$85,$B3,$11,
          $8A,$7D,$1C,$60,$24,$CF,$AF,$55,
          $76,$99,$86,$82,$17,$BC,$0C,$2F,
          $44,$A1,$99,$BC,$6C,$0E,$DD,$51,
          $97,$98,$BA,$05,$BD,$5B,$1B,$44,
          $84,$34,$6A,$47,$C2,$CA,$DF,$6B,
          $F3,$0B,$78,$5C,$C8,$8B,$2B,$AF
         ),
         (
          $A0,$E5,$C1,$C0,$03,$1C,$02,$E4,
          $8B,$7F,$09,$A5,$E8,$96,$EE,$9A,
          $EF,$2F,$17,$FC,$9E,$18,$E9,$97,
          $D7,$F6,$CA,$C7,$AE,$31,$64,$22,
          $C2,$B1,$E7,$79,$84,$E5,$F3,$A7,
          $3C,$B4,$5D,$EE,$D5,$D3,$F8,$46,
          $00,$10,$5E,$6E,$E3,$8F,$2D,$09,
          $0C,$7D,$04,$42,$EA,$34,$C4,$6D
         ),
         (
          $41,$DA,$A6,$AD,$CF,$DB,$69,$F1,
          $44,$0C,$37,$B5,$96,$44,$01,$65,
          $C1,$5A,$DA,$59,$68,$13,$E2,$E2,
          $2F,$06,$0F,$CD,$55,$1F,$24,$DE,
          $E8,$E0,$4B,$A6,$89,$03,$87,$88,
          $6C,$EE,$C4,$A7,$A0,$D7,$FC,$6B,
          $44,$50,$63,$92,$EC,$38,$22,$C0,
          $D8,$C1,$AC,$FC,$7D,$5A,$EB,$E8
         ),
         (
          $14,$D4,$D4,$0D,$59,$84,$D8,$4C,
          $5C,$F7,$52,$3B,$77,$98,$B2,$54,
          $E2,$75,$A3,$A8,$CC,$0A,$1B,$D0,
          $6E,$BC,$0B,$EE,$72,$68,$56,$AC,
          $C3,$CB,$F5,$16,$FF,$66,$7C,$DA,
          $20,$58,$AD,$5C,$34,$12,$25,$44,
          $60,$A8,$2C,$92,$18,$70,$41,$36,
          $3C,$C7,$7A,$4D,$C2,$15,$E4,$87
         ),
         (
          $D0,$E7,$A1,$E2,$B9,$A4,$47,$FE,
          $E8,$3E,$22,$77,$E9,$FF,$80,$10,
          $C2,$F3,$75,$AE,$12,$FA,$7A,$AA,
          $8C,$A5,$A6,$31,$78,$68,$A2,$6A,
          $36,$7A,$0B,$69,$FB,$C1,$CF,$32,
          $A5,$5D,$34,$EB,$37,$06,$63,$01,
          $6F,$3D,$21,$10,$23,$0E,$BA,$75,
          $40,$28,$A5,$6F,$54,$AC,$F5,$7C
         ),
         (
          $E7,$71,$AA,$8D,$B5,$A3,$E0,$43,
          $E8,$17,$8F,$39,$A0,$85,$7B,$A0,
          $4A,$3F,$18,$E4,$AA,$05,$74,$3C,
          $F8,$D2,$22,$B0,$B0,$95,$82,$53,
          $50,$BA,$42,$2F,$63,$38,$2A,$23,
          $D9,$2E,$41,$49,$07,$4E,$81,$6A,
          $36,$C1,$CD,$28,$28,$4D,$14,$62,
          $67,$94,$0B,$31,$F8,$81,$8E,$A2
         ),
         (
          $FE,$B4,$FD,$6F,$9E,$87,$A5,$6B,
          $EF,$39,$8B,$32,$84,$D2,$BD,$A5,
          $B5,$B0,$E1,$66,$58,$3A,$66,$B6,
          $1E,$53,$84,$57,$FF,$05,$84,$87,
          $2C,$21,$A3,$29,$62,$B9,$92,$8F,
          $FA,$B5,$8D,$E4,$AF,$2E,$DD,$4E,
          $15,$D8,$B3,$55,$70,$52,$32,$07,
          $FF,$4E,$2A,$5A,$A7,$75,$4C,$AA
         ),
         (
          $46,$2F,$17,$BF,$00,$5F,$B1,$C1,
          $B9,$E6,$71,$77,$9F,$66,$52,$09,
          $EC,$28,$73,$E3,$E4,$11,$F9,$8D,
          $AB,$F2,$40,$A1,$D5,$EC,$3F,$95,
          $CE,$67,$96,$B6,$FC,$23,$FE,$17,
          $19,$03,$B5,$02,$02,$34,$67,$DE,
          $C7,$27,$3F,$F7,$48,$79,$B9,$29,
          $67,$A2,$A4,$3A,$5A,$18,$3D,$33
         ),
         (
          $D3,$33,$81,$93,$B6,$45,$53,$DB,
          $D3,$8D,$14,$4B,$EA,$71,$C5,$91,
          $5B,$B1,$10,$E2,$D8,$81,$80,$DB,
          $C5,$DB,$36,$4F,$D6,$17,$1D,$F3,
          $17,$FC,$72,$68,$83,$1B,$5A,$EF,
          $75,$E4,$34,$2B,$2F,$AD,$87,$97,
          $BA,$39,$ED,$DC,$EF,$80,$E6,$EC,
          $08,$15,$93,$50,$B1,$AD,$69,$6D
         ),
         (
          $E1,$59,$0D,$58,$5A,$3D,$39,$F7,
          $CB,$59,$9A,$BD,$47,$90,$70,$96,
          $64,$09,$A6,$84,$6D,$43,$77,$AC,
          $F4,$47,$1D,$06,$5D,$5D,$B9,$41,
          $29,$CC,$9B,$E9,$25,$73,$B0,$5E,
          $D2,$26,$BE,$1E,$9B,$7C,$B0,$CA,
          $BE,$87,$91,$85,$89,$F8,$0D,$AD,
          $D4,$EF,$5E,$F2,$5A,$93,$D2,$8E
         ),
         (
          $F8,$F3,$72,$6A,$C5,$A2,$6C,$C8,
          $01,$32,$49,$3A,$6F,$ED,$CB,$0E,
          $60,$76,$0C,$09,$CF,$C8,$4C,$AD,
          $17,$81,$75,$98,$68,$19,$66,$5E,
          $76,$84,$2D,$7B,$9F,$ED,$F7,$6D,
          $DD,$EB,$F5,$D3,$F5,$6F,$AA,$AD,
          $44,$77,$58,$7A,$F2,$16,$06,$D3,
          $96,$AE,$57,$0D,$8E,$71,$9A,$F2
         ),
         (
          $30,$18,$60,$55,$C0,$79,$49,$94,
          $81,$83,$C8,$50,$E9,$A7,$56,$CC,
          $09,$93,$7E,$24,$7D,$9D,$92,$8E,
          $86,$9E,$20,$BA,$FC,$3C,$D9,$72,
          $17,$19,$D3,$4E,$04,$A0,$89,$9B,
          $92,$C7,$36,$08,$45,$50,$18,$68,
          $86,$EF,$BA,$2E,$79,$0D,$8B,$E6,
          $EB,$F0,$40,$B2,$09,$C4,$39,$A4
         ),
         (
          $F3,$C4,$27,$6C,$B8,$63,$63,$77,
          $12,$C2,$41,$C4,$44,$C5,$CC,$1E,
          $35,$54,$E0,$FD,$DB,$17,$4D,$03,
          $58,$19,$DD,$83,$EB,$70,$0B,$4C,
          $E8,$8D,$F3,$AB,$38,$41,$BA,$02,
          $08,$5E,$1A,$99,$B4,$E1,$73,$10,
          $C5,$34,$10,$75,$C0,$45,$8B,$A3,
          $76,$C9,$5A,$68,$18,$FB,$B3,$E2
         ),
         (
          $0A,$A0,$07,$C4,$DD,$9D,$58,$32,
          $39,$30,$40,$A1,$58,$3C,$93,$0B,
          $CA,$7D,$C5,$E7,$7E,$A5,$3A,$DD,
          $7E,$2B,$3F,$7C,$8E,$23,$13,$68,
          $04,$35,$20,$D4,$A3,$EF,$53,$C9,
          $69,$B6,$BB,$FD,$02,$59,$46,$F6,
          $32,$BD,$7F,$76,$5D,$53,$C2,$10,
          $03,$B8,$F9,$83,$F7,$5E,$2A,$6A
         ),
         (
          $08,$E9,$46,$47,$20,$53,$3B,$23,
          $A0,$4E,$C2,$4F,$7A,$E8,$C1,$03,
          $14,$5F,$76,$53,$87,$D7,$38,$77,
          $7D,$3D,$34,$34,$77,$FD,$1C,$58,
          $DB,$05,$21,$42,$CA,$B7,$54,$EA,
          $67,$43,$78,$E1,$87,$66,$C5,$35,
          $42,$F7,$19,$70,$17,$1C,$C4,$F8,
          $16,$94,$24,$6B,$71,$7D,$75,$64
         ),
         (
          $D3,$7F,$F7,$AD,$29,$79,$93,$E7,
          $EC,$21,$E0,$F1,$B4,$B5,$AE,$71,
          $9C,$DC,$83,$C5,$DB,$68,$75,$27,
          $F2,$75,$16,$CB,$FF,$A8,$22,$88,
          $8A,$68,$10,$EE,$5C,$1C,$A7,$BF,
          $E3,$32,$11,$19,$BE,$1A,$B7,$BF,
          $A0,$A5,$02,$67,$1C,$83,$29,$49,
          $4D,$F7,$AD,$6F,$52,$2D,$44,$0F
         ),
         (
          $DD,$90,$42,$F6,$E4,$64,$DC,$F8,
          $6B,$12,$62,$F6,$AC,$CF,$AF,$BD,
          $8C,$FD,$90,$2E,$D3,$ED,$89,$AB,
          $F7,$8F,$FA,$48,$2D,$BD,$EE,$B6,
          $96,$98,$42,$39,$4C,$9A,$11,$68,
          $AE,$3D,$48,$1A,$01,$78,$42,$F6,
          $60,$00,$2D,$42,$44,$7C,$6B,$22,
          $F7,$B7,$2F,$21,$AA,$E0,$21,$C9
         ),
         (
          $BD,$96,$5B,$F3,$1E,$87,$D7,$03,
          $27,$53,$6F,$2A,$34,$1C,$EB,$C4,
          $76,$8E,$CA,$27,$5F,$A0,$5E,$F9,
          $8F,$7F,$1B,$71,$A0,$35,$12,$98,
          $DE,$00,$6F,$BA,$73,$FE,$67,$33,
          $ED,$01,$D7,$58,$01,$B4,$A9,$28,
          $E5,$42,$31,$B3,$8E,$38,$C5,$62,
          $B2,$E3,$3E,$A1,$28,$49,$92,$FA
         ),
         (
          $65,$67,$6D,$80,$06,$17,$97,$2F,
          $BD,$87,$E4,$B9,$51,$4E,$1C,$67,
          $40,$2B,$7A,$33,$10,$96,$D3,$BF,
          $AC,$22,$F1,$AB,$B9,$53,$74,$AB,
          $C9,$42,$F1,$6E,$9A,$B0,$EA,$D3,
          $3B,$87,$C9,$19,$68,$A6,$E5,$09,
          $E1,$19,$FF,$07,$78,$7B,$3E,$F4,
          $83,$E1,$DC,$DC,$CF,$6E,$30,$22
         ),
         (
          $93,$9F,$A1,$89,$69,$9C,$5D,$2C,
          $81,$DD,$D1,$FF,$C1,$FA,$20,$7C,
          $97,$0B,$6A,$36,$85,$BB,$29,$CE,
          $1D,$3E,$99,$D4,$2F,$2F,$74,$42,
          $DA,$53,$E9,$5A,$72,$90,$73,$14,
          $F4,$58,$83,$99,$A3,$FF,$5B,$0A,
          $92,$BE,$B3,$F6,$BE,$26,$94,$F9,
          $F8,$6E,$CF,$29,$52,$D5,$B4,$1C
         ),
         (
          $C5,$16,$54,$17,$01,$86,$3F,$91,
          $00,$5F,$31,$41,$08,$CE,$EC,$E3,
          $C6,$43,$E0,$4F,$C8,$C4,$2F,$D2,
          $FF,$55,$62,$20,$E6,$16,$AA,$A6,
          $A4,$8A,$EB,$97,$A8,$4B,$AD,$74,
          $78,$2E,$8D,$FF,$96,$A1,$A2,$FA,
          $94,$93,$39,$D7,$22,$ED,$CA,$A3,
          $2B,$57,$06,$70,$41,$DF,$88,$CC
         ),
         (
          $98,$7F,$D6,$E0,$D6,$85,$7C,$55,
          $3E,$AE,$BB,$3D,$34,$97,$0A,$2C,
          $2F,$6E,$89,$A3,$54,$8F,$49,$25,
          $21,$72,$2B,$80,$A1,$C2,$1A,$15,
          $38,$92,$34,$6D,$2C,$BA,$64,$44,
          $21,$2D,$56,$DA,$9A,$26,$E3,$24,
          $DC,$CB,$C0,$DC,$DE,$85,$D4,$D2,
          $EE,$43,$99,$EE,$C5,$A6,$4E,$8F
         ),
         (
          $AE,$56,$DE,$B1,$C2,$32,$8D,$9C,
          $40,$17,$70,$6B,$CE,$6E,$99,$D4,
          $13,$49,$05,$3B,$A9,$D3,$36,$D6,
          $77,$C4,$C2,$7D,$9F,$D5,$0A,$E6,
          $AE,$E1,$7E,$85,$31,$54,$E1,$F4,
          $FE,$76,$72,$34,$6D,$A2,$EA,$A3,
          $1E,$EA,$53,$FC,$F2,$4A,$22,$80,
          $4F,$11,$D0,$3D,$A6,$AB,$FC,$2B
         ),
         (
          $49,$D6,$A6,$08,$C9,$BD,$E4,$49,
          $18,$70,$49,$85,$72,$AC,$31,$AA,
          $C3,$FA,$40,$93,$8B,$38,$A7,$81,
          $8F,$72,$38,$3E,$B0,$40,$AD,$39,
          $53,$2B,$C0,$65,$71,$E1,$3D,$76,
          $7E,$69,$45,$AB,$77,$C0,$BD,$C3,
          $B0,$28,$42,$53,$34,$3F,$9F,$6C,
          $12,$44,$EB,$F2,$FF,$0D,$F8,$66
         ),
         (
          $DA,$58,$2A,$D8,$C5,$37,$0B,$44,
          $69,$AF,$86,$2A,$A6,$46,$7A,$22,
          $93,$B2,$B2,$8B,$D8,$0A,$E0,$E9,
          $1F,$42,$5A,$D3,$D4,$72,$49,$FD,
          $F9,$88,$25,$CC,$86,$F1,$40,$28,
          $C3,$30,$8C,$98,$04,$C7,$8B,$FE,
          $EE,$EE,$46,$14,$44,$CE,$24,$36,
          $87,$E1,$A5,$05,$22,$45,$6A,$1D
         ),
         (
          $D5,$26,$6A,$A3,$33,$11,$94,$AE,
          $F8,$52,$EE,$D8,$6D,$7B,$5B,$26,
          $33,$A0,$AF,$1C,$73,$59,$06,$F2,
          $E1,$32,$79,$F1,$49,$31,$A9,$FC,
          $3B,$0E,$AC,$5C,$E9,$24,$52,$73,
          $BD,$1A,$A9,$29,$05,$AB,$E1,$62,
          $78,$EF,$7E,$FD,$47,$69,$47,$89,
          $A7,$28,$3B,$77,$DA,$3C,$70,$F8
         ),
         (
          $29,$62,$73,$4C,$28,$25,$21,$86,
          $A9,$A1,$11,$1C,$73,$2A,$D4,$DE,
          $45,$06,$D4,$B4,$48,$09,$16,$30,
          $3E,$B7,$99,$1D,$65,$9C,$CD,$A0,
          $7A,$99,$11,$91,$4B,$C7,$5C,$41,
          $8A,$B7,$A4,$54,$17,$57,$AD,$05,
          $47,$96,$E2,$67,$97,$FE,$AF,$36,
          $E9,$F6,$AD,$43,$F1,$4B,$35,$A4
         ),
         (
          $E8,$B7,$9E,$C5,$D0,$6E,$11,$1B,
          $DF,$AF,$D7,$1E,$9F,$57,$60,$F0,
          $0A,$C8,$AC,$5D,$8B,$F7,$68,$F9,
          $FF,$6F,$08,$B8,$F0,$26,$09,$6B,
          $1C,$C3,$A4,$C9,$73,$33,$30,$19,
          $F1,$E3,$55,$3E,$77,$DA,$3F,$98,
          $CB,$9F,$54,$2E,$0A,$90,$E5,$F8,
          $A9,$40,$CC,$58,$E5,$98,$44,$B3
         ),
         (
          $DF,$B3,$20,$C4,$4F,$9D,$41,$D1,
          $EF,$DC,$C0,$15,$F0,$8D,$D5,$53,
          $9E,$52,$6E,$39,$C8,$7D,$50,$9A,
          $E6,$81,$2A,$96,$9E,$54,$31,$BF,
          $4F,$A7,$D9,$1F,$FD,$03,$B9,$81,
          $E0,$D5,$44,$CF,$72,$D7,$B1,$C0,
          $37,$4F,$88,$01,$48,$2E,$6D,$EA,
          $2E,$F9,$03,$87,$7E,$BA,$67,$5E
         ),
         (
          $D8,$86,$75,$11,$8F,$DB,$55,$A5,
          $FB,$36,$5A,$C2,$AF,$1D,$21,$7B,
          $F5,$26,$CE,$1E,$E9,$C9,$4B,$2F,
          $00,$90,$B2,$C5,$8A,$06,$CA,$58,
          $18,$7D,$7F,$E5,$7C,$7B,$ED,$9D,
          $26,$FC,$A0,$67,$B4,$11,$0E,$EF,
          $CD,$9A,$0A,$34,$5D,$E8,$72,$AB,
          $E2,$0D,$E3,$68,$00,$1B,$07,$45
         ),
         (
          $B8,$93,$F2,$FC,$41,$F7,$B0,$DD,
          $6E,$2F,$6A,$A2,$E0,$37,$0C,$0C,
          $FF,$7D,$F0,$9E,$3A,$CF,$CC,$0E,
          $92,$0B,$6E,$6F,$AD,$0E,$F7,$47,
          $C4,$06,$68,$41,$7D,$34,$2B,$80,
          $D2,$35,$1E,$8C,$17,$5F,$20,$89,
          $7A,$06,$2E,$97,$65,$E6,$C6,$7B,
          $53,$9B,$6B,$A8,$B9,$17,$05,$45
         ),
         (
          $6C,$67,$EC,$56,$97,$AC,$CD,$23,
          $5C,$59,$B4,$86,$D7,$B7,$0B,$AE,
          $ED,$CB,$D4,$AA,$64,$EB,$D4,$EE,
          $F3,$C7,$EA,$C1,$89,$56,$1A,$72,
          $62,$50,$AE,$C4,$D4,$8C,$AD,$CA,
          $FB,$BE,$2C,$E3,$C1,$6C,$E2,$D6,
          $91,$A8,$CC,$E0,$6E,$88,$79,$55,
          $6D,$44,$83,$ED,$71,$65,$C0,$63
         ),
         (
          $F1,$AA,$2B,$04,$4F,$8F,$0C,$63,
          $8A,$3F,$36,$2E,$67,$7B,$5D,$89,
          $1D,$6F,$D2,$AB,$07,$65,$F6,$EE,
          $1E,$49,$87,$DE,$05,$7E,$AD,$35,
          $78,$83,$D9,$B4,$05,$B9,$D6,$09,
          $EE,$A1,$B8,$69,$D9,$7F,$B1,$6D,
          $9B,$51,$01,$7C,$55,$3F,$3B,$93,
          $C0,$A1,$E0,$F1,$29,$6F,$ED,$CD
         ),
         (
          $CB,$AA,$25,$95,$72,$D4,$AE,$BF,
          $C1,$91,$7A,$CD,$DC,$58,$2B,$9F,
          $8D,$FA,$A9,$28,$A1,$98,$CA,$7A,
          $CD,$0F,$2A,$A7,$6A,$13,$4A,$90,
          $25,$2E,$62,$98,$A6,$5B,$08,$18,
          $6A,$35,$0D,$5B,$76,$26,$69,$9F,
          $8C,$B7,$21,$A3,$EA,$59,$21,$B7,
          $53,$AE,$3A,$2D,$CE,$24,$BA,$3A
         ),
         (
          $FA,$15,$49,$C9,$79,$6C,$D4,$D3,
          $03,$DC,$F4,$52,$C1,$FB,$D5,$74,
          $4F,$D9,$B9,$B4,$70,$03,$D9,$20,
          $B9,$2D,$E3,$48,$39,$D0,$7E,$F2,
          $A2,$9D,$ED,$68,$F6,$FC,$9E,$6C,
          $45,$E0,$71,$A2,$E4,$8B,$D5,$0C,
          $50,$84,$E9,$6B,$65,$7D,$D0,$40,
          $40,$45,$A1,$DD,$EF,$E2,$82,$ED
         ),
         (
          $5C,$F2,$AC,$89,$7A,$B4,$44,$DC,
          $B5,$C8,$D8,$7C,$49,$5D,$BD,$B3,
          $4E,$18,$38,$B6,$B6,$29,$42,$7C,
          $AA,$51,$70,$2A,$D0,$F9,$68,$85,
          $25,$F1,$3B,$EC,$50,$3A,$3C,$3A,
          $2C,$80,$A6,$5E,$0B,$57,$15,$E8,
          $AF,$AB,$00,$FF,$A5,$6E,$C4,$55,
          $A4,$9A,$1A,$D3,$0A,$A2,$4F,$CD
         ),
         (
          $9A,$AF,$80,$20,$7B,$AC,$E1,$7B,
          $B7,$AB,$14,$57,$57,$D5,$69,$6B,
          $DE,$32,$40,$6E,$F2,$2B,$44,$29,
          $2E,$F6,$5D,$45,$19,$C3,$BB,$2A,
          $D4,$1A,$59,$B6,$2C,$C3,$E9,$4B,
          $6F,$A9,$6D,$32,$A7,$FA,$AD,$AE,
          $28,$AF,$7D,$35,$09,$72,$19,$AA,
          $3F,$D8,$CD,$A3,$1E,$40,$C2,$75
         ),
         (
          $AF,$88,$B1,$63,$40,$2C,$86,$74,
          $5C,$B6,$50,$C2,$98,$8F,$B9,$52,
          $11,$B9,$4B,$03,$EF,$29,$0E,$ED,
          $96,$62,$03,$42,$41,$FD,$51,$CF,
          $39,$8F,$80,$73,$E3,$69,$35,$4C,
          $43,$EA,$E1,$05,$2F,$9B,$63,$B0,
          $81,$91,$CA,$A1,$38,$AA,$54,$FE,
          $A8,$89,$CC,$70,$24,$23,$68,$97
         ),
         (
          $48,$FA,$7D,$64,$E1,$CE,$EE,$27,
          $B9,$86,$4D,$B5,$AD,$A4,$B5,$3D,
          $00,$C9,$BC,$76,$26,$55,$58,$13,
          $D3,$CD,$67,$30,$AB,$3C,$C0,$6F,
          $F3,$42,$D7,$27,$90,$5E,$33,$17,
          $1B,$DE,$6E,$84,$76,$E7,$7F,$B1,
          $72,$08,$61,$E9,$4B,$73,$A2,$C5,
          $38,$D2,$54,$74,$62,$85,$F4,$30
         ),
         (
          $0E,$6F,$D9,$7A,$85,$E9,$04,$F8,
          $7B,$FE,$85,$BB,$EB,$34,$F6,$9E,
          $1F,$18,$10,$5C,$F4,$ED,$4F,$87,
          $AE,$C3,$6C,$6E,$8B,$5F,$68,$BD,
          $2A,$6F,$3D,$C8,$A9,$EC,$B2,$B6,
          $1D,$B4,$EE,$DB,$6B,$2E,$A1,$0B,
          $F9,$CB,$02,$51,$FB,$0F,$8B,$34,
          $4A,$BF,$7F,$36,$6B,$6D,$E5,$AB
         ),
         (
          $06,$62,$2D,$A5,$78,$71,$76,$28,
          $7F,$DC,$8F,$ED,$44,$0B,$AD,$18,
          $7D,$83,$00,$99,$C9,$4E,$6D,$04,
          $C8,$E9,$C9,$54,$CD,$A7,$0C,$8B,
          $B9,$E1,$FC,$4A,$6D,$0B,$AA,$83,
          $1B,$9B,$78,$EF,$66,$48,$68,$1A,
          $48,$67,$A1,$1D,$A9,$3E,$E3,$6E,
          $5E,$6A,$37,$D8,$7F,$C6,$3F,$6F
         ),
         (
          $1D,$A6,$77,$2B,$58,$FA,$BF,$9C,
          $61,$F6,$8D,$41,$2C,$82,$F1,$82,
          $C0,$23,$6D,$7D,$57,$5E,$F0,$B5,
          $8D,$D2,$24,$58,$D6,$43,$CD,$1D,
          $FC,$93,$B0,$38,$71,$C3,$16,$D8,
          $43,$0D,$31,$29,$95,$D4,$19,$7F,
          $08,$74,$C9,$91,$72,$BA,$00,$4A,
          $01,$EE,$29,$5A,$BA,$C2,$4E,$46
         ),
         (
          $3C,$D2,$D9,$32,$0B,$7B,$1D,$5F,
          $B9,$AA,$B9,$51,$A7,$60,$23,$FA,
          $66,$7B,$E1,$4A,$91,$24,$E3,$94,
          $51,$39,$18,$A3,$F4,$40,$96,$AE,
          $49,$04,$BA,$0F,$FC,$15,$0B,$63,
          $BC,$7A,$B1,$EE,$B9,$A6,$E2,$57,
          $E5,$C8,$F0,$00,$A7,$03,$94,$A5,
          $AF,$D8,$42,$71,$5D,$E1,$5F,$29
         ),
         (
          $04,$CD,$C1,$4F,$74,$34,$E0,$B4,
          $BE,$70,$CB,$41,$DB,$4C,$77,$9A,
          $88,$EA,$EF,$6A,$CC,$EB,$CB,$41,
          $F2,$D4,$2F,$FF,$E7,$F3,$2A,$8E,
          $28,$1B,$5C,$10,$3A,$27,$02,$1D,
          $0D,$08,$36,$22,$50,$75,$3C,$DF,
          $70,$29,$21,$95,$A5,$3A,$48,$72,
          $8C,$EB,$58,$44,$C2,$D9,$8B,$AB
         ),
         (
          $90,$71,$B7,$A8,$A0,$75,$D0,$09,
          $5B,$8F,$B3,$AE,$51,$13,$78,$57,
          $35,$AB,$98,$E2,$B5,$2F,$AF,$91,
          $D5,$B8,$9E,$44,$AA,$C5,$B5,$D4,
          $EB,$BF,$91,$22,$3B,$0F,$F4,$C7,
          $19,$05,$DA,$55,$34,$2E,$64,$65,
          $5D,$6E,$F8,$C8,$9A,$47,$68,$C3,
          $F9,$3A,$6D,$C0,$36,$6B,$5B,$C8
         ),
         (
          $EB,$B3,$02,$40,$DD,$96,$C7,$BC,
          $8D,$0A,$BE,$49,$AA,$4E,$DC,$BB,
          $4A,$FD,$C5,$1F,$F9,$AA,$F7,$20,
          $D3,$F9,$E7,$FB,$B0,$F9,$C6,$D6,
          $57,$13,$50,$50,$17,$69,$FC,$4E,
          $BD,$0B,$21,$41,$24,$7F,$F4,$00,
          $D4,$FD,$4B,$E4,$14,$ED,$F3,$77,
          $57,$BB,$90,$A3,$2A,$C5,$C6,$5A
         ),
         (
          $85,$32,$C5,$8B,$F3,$C8,$01,$5D,
          $9D,$1C,$BE,$00,$EE,$F1,$F5,$08,
          $2F,$8F,$36,$32,$FB,$E9,$F1,$ED,
          $4F,$9D,$FB,$1F,$A7,$9E,$82,$83,
          $06,$6D,$77,$C4,$4C,$4A,$F9,$43,
          $D7,$6B,$30,$03,$64,$AE,$CB,$D0,
          $64,$8C,$8A,$89,$39,$BD,$20,$41,
          $23,$F4,$B5,$62,$60,$42,$2D,$EC
         ),
         (
          $FE,$98,$46,$D6,$4F,$7C,$77,$08,
          $69,$6F,$84,$0E,$2D,$76,$CB,$44,
          $08,$B6,$59,$5C,$2F,$81,$EC,$6A,
          $28,$A7,$F2,$F2,$0C,$B8,$8C,$FE,
          $6A,$C0,$B9,$E9,$B8,$24,$4F,$08,
          $BD,$70,$95,$C3,$50,$C1,$D0,$84,
          $2F,$64,$FB,$01,$BB,$7F,$53,$2D,
          $FC,$D4,$73,$71,$B0,$AE,$EB,$79
         ),
         (
          $28,$F1,$7E,$A6,$FB,$6C,$42,$09,
          $2D,$C2,$64,$25,$7E,$29,$74,$63,
          $21,$FB,$5B,$DA,$EA,$98,$73,$C2,
          $A7,$FA,$9D,$8F,$53,$81,$8E,$89,
          $9E,$16,$1B,$C7,$7D,$FE,$80,$90,
          $AF,$D8,$2B,$F2,$26,$6C,$5C,$1B,
          $C9,$30,$A8,$D1,$54,$76,$24,$43,
          $9E,$66,$2E,$F6,$95,$F2,$6F,$24
         ),
         (
          $EC,$6B,$7D,$7F,$03,$0D,$48,$50,
          $AC,$AE,$3C,$B6,$15,$C2,$1D,$D2,
          $52,$06,$D6,$3E,$84,$D1,$DB,$8D,
          $95,$73,$70,$73,$7B,$A0,$E9,$84,
          $67,$EA,$0C,$E2,$74,$C6,$61,$99,
          $90,$1E,$AE,$C1,$8A,$08,$52,$57,
          $15,$F5,$3B,$FD,$B0,$AA,$CB,$61,
          $3D,$34,$2E,$BD,$CE,$ED,$DC,$3B
         ),
         (
          $B4,$03,$D3,$69,$1C,$03,$B0,$D3,
          $41,$8D,$F3,$27,$D5,$86,$0D,$34,
          $BB,$FC,$C4,$51,$9B,$FB,$CE,$36,
          $BF,$33,$B2,$08,$38,$5F,$AD,$B9,
          $18,$6B,$C7,$8A,$76,$C4,$89,$D8,
          $9F,$D5,$7E,$7D,$C7,$54,$12,$D2,
          $3B,$CD,$1D,$AE,$84,$70,$CE,$92,
          $74,$75,$4B,$B8,$58,$5B,$13,$C5
         ),
         (
          $31,$FC,$79,$73,$8B,$87,$72,$B3,
          $F5,$5C,$D8,$17,$88,$13,$B3,$B5,
          $2D,$0D,$B5,$A4,$19,$D3,$0B,$A9,
          $49,$5C,$4B,$9D,$A0,$21,$9F,$AC,
          $6D,$F8,$E7,$C2,$3A,$81,$15,$51,
          $A6,$2B,$82,$7F,$25,$6E,$CD,$B8,
          $12,$4A,$C8,$A6,$79,$2C,$CF,$EC,
          $C3,$B3,$01,$27,$22,$E9,$44,$63
         ),
         (
          $BB,$20,$39,$EC,$28,$70,$91,$BC,
          $C9,$64,$2F,$C9,$00,$49,$E7,$37,
          $32,$E0,$2E,$57,$7E,$28,$62,$B3,
          $22,$16,$AE,$9B,$ED,$CD,$73,$0C,
          $4C,$28,$4E,$F3,$96,$8C,$36,$8B,
          $7D,$37,$58,$4F,$97,$BD,$4B,$4D,
          $C6,$EF,$61,$27,$AC,$FE,$2E,$6A,
          $E2,$50,$91,$24,$E6,$6C,$8A,$F4
         ),
         (
          $F5,$3D,$68,$D1,$3F,$45,$ED,$FC,
          $B9,$BD,$41,$5E,$28,$31,$E9,$38,
          $35,$0D,$53,$80,$D3,$43,$22,$78,
          $FC,$1C,$0C,$38,$1F,$CB,$7C,$65,
          $C8,$2D,$AF,$E0,$51,$D8,$C8,$B0,
          $D4,$4E,$09,$74,$A0,$E5,$9E,$C7,
          $BF,$7E,$D0,$45,$9F,$86,$E9,$6F,
          $32,$9F,$C7,$97,$52,$51,$0F,$D3
         ),
         (
          $8D,$56,$8C,$79,$84,$F0,$EC,$DF,
          $76,$40,$FB,$C4,$83,$B5,$D8,$C9,
          $F8,$66,$34,$F6,$F4,$32,$91,$84,
          $1B,$30,$9A,$35,$0A,$B9,$C1,$13,
          $7D,$24,$06,$6B,$09,$DA,$99,$44,
          $BA,$C5,$4D,$5B,$B6,$58,$0D,$83,
          $60,$47,$AA,$C7,$4A,$B7,$24,$B8,
          $87,$EB,$F9,$3D,$4B,$32,$EC,$A9
         ),
         (
          $C0,$B6,$5C,$E5,$A9,$6F,$F7,$74,
          $C4,$56,$CA,$C3,$B5,$F2,$C4,$CD,
          $35,$9B,$4F,$F5,$3E,$F9,$3A,$3D,
          $A0,$77,$8B,$E4,$90,$0D,$1E,$8D,
          $A1,$60,$1E,$76,$9E,$8F,$1B,$02,
          $D2,$A2,$F8,$C5,$B9,$FA,$10,$B4,
          $4F,$1C,$18,$69,$85,$46,$8F,$EE,
          $B0,$08,$73,$02,$83,$A6,$65,$7D
         ),
         (
          $49,$00,$BB,$A6,$F5,$FB,$10,$3E,
          $CE,$8E,$C9,$6A,$DA,$13,$A5,$C3,
          $C8,$54,$88,$E0,$55,$51,$DA,$6B,
          $6B,$33,$D9,$88,$E6,$11,$EC,$0F,
          $E2,$E3,$C2,$AA,$48,$EA,$6A,$E8,
          $98,$6A,$3A,$23,$1B,$22,$3C,$5D,
          $27,$CE,$C2,$EA,$DD,$E9,$1C,$E0,
          $79,$81,$EE,$65,$28,$62,$D1,$E4
         ),
         (
          $C7,$F5,$C3,$7C,$72,$85,$F9,$27,
          $F7,$64,$43,$41,$4D,$43,$57,$FF,
          $78,$96,$47,$D7,$A0,$05,$A5,$A7,
          $87,$E0,$3C,$34,$6B,$57,$F4,$9F,
          $21,$B6,$4F,$A9,$CF,$4B,$7E,$45,
          $57,$3E,$23,$04,$90,$17,$56,$71,
          $21,$A9,$C3,$D4,$B2,$B7,$3E,$C5,
          $E9,$41,$35,$77,$52,$5D,$B4,$5A
         ),
         (
          $EC,$70,$96,$33,$07,$36,$FD,$B2,
          $D6,$4B,$56,$53,$E7,$47,$5D,$A7,
          $46,$C2,$3A,$46,$13,$A8,$26,$87,
          $A2,$80,$62,$D3,$23,$63,$64,$28,
          $4A,$C0,$17,$20,$FF,$B4,$06,$CF,
          $E2,$65,$C0,$DF,$62,$6A,$18,$8C,
          $9E,$59,$63,$AC,$E5,$D3,$D5,$BB,
          $36,$3E,$32,$C3,$8C,$21,$90,$A6
         ),
         (
          $82,$E7,$44,$C7,$5F,$46,$49,$EC,
          $52,$B8,$07,$71,$A7,$7D,$47,$5A,
          $3B,$C0,$91,$98,$95,$56,$96,$0E,
          $27,$6A,$5F,$9E,$AD,$92,$A0,$3F,
          $71,$87,$42,$CD,$CF,$EA,$EE,$5C,
          $B8,$5C,$44,$AF,$19,$8A,$DC,$43,
          $A4,$A4,$28,$F5,$F0,$C2,$DD,$B0,
          $BE,$36,$05,$9F,$06,$D7,$DF,$73
         ),
         (
          $28,$34,$B7,$A7,$17,$0F,$1F,$5B,
          $68,$55,$9A,$B7,$8C,$10,$50,$EC,
          $21,$C9,$19,$74,$0B,$78,$4A,$90,
          $72,$F6,$E5,$D6,$9F,$82,$8D,$70,
          $C9,$19,$C5,$03,$9F,$B1,$48,$E3,
          $9E,$2C,$8A,$52,$11,$83,$78,$B0,
          $64,$CA,$8D,$50,$01,$CD,$10,$A5,
          $47,$83,$87,$B9,$66,$71,$5E,$D6
         ),
         (
          $16,$B4,$AD,$A8,$83,$F7,$2F,$85,
          $3B,$B7,$EF,$25,$3E,$FC,$AB,$0C,
          $3E,$21,$61,$68,$7A,$D6,$15,$43,
          $A0,$D2,$82,$4F,$91,$C1,$F8,$13,
          $47,$D8,$6B,$E7,$09,$B1,$69,$96,
          $E1,$7F,$2D,$D4,$86,$92,$7B,$02,
          $88,$AD,$38,$D1,$30,$63,$C4,$A9,
          $67,$2C,$39,$39,$7D,$37,$89,$B6
         ),
         (
          $78,$D0,$48,$F3,$A6,$9D,$8B,$54,
          $AE,$0E,$D6,$3A,$57,$3A,$E3,$50,
          $D8,$9F,$7C,$6C,$F1,$F3,$68,$89,
          $30,$DE,$89,$9A,$FA,$03,$76,$97,
          $62,$9B,$31,$4E,$5C,$D3,$03,$AA,
          $62,$FE,$EA,$72,$A2,$5B,$F4,$2B,
          $30,$4B,$6C,$6B,$CB,$27,$FA,$E2,
          $1C,$16,$D9,$25,$E1,$FB,$DA,$C3
         ),
         (
          $0F,$74,$6A,$48,$74,$92,$87,$AD,
          $A7,$7A,$82,$96,$1F,$05,$A4,$DA,
          $4A,$BD,$B7,$D7,$7B,$12,$20,$F8,
          $36,$D0,$9E,$C8,$14,$35,$9C,$0E,
          $C0,$23,$9B,$8C,$7B,$9F,$F9,$E0,
          $2F,$56,$9D,$1B,$30,$1E,$F6,$7C,
          $46,$12,$D1,$DE,$4F,$73,$0F,$81,
          $C1,$2C,$40,$CC,$06,$3C,$5C,$AA
         ),
         (
          $F0,$FC,$85,$9D,$3B,$D1,$95,$FB,
          $DC,$2D,$59,$1E,$4C,$DA,$C1,$51,
          $79,$EC,$0F,$1D,$C8,$21,$C1,$1D,
          $F1,$F0,$C1,$D2,$6E,$62,$60,$AA,
          $A6,$5B,$79,$FA,$FA,$CA,$FD,$7D,
          $3A,$D6,$1E,$60,$0F,$25,$09,$05,
          $F5,$87,$8C,$87,$45,$28,$97,$64,
          $7A,$35,$B9,$95,$BC,$AD,$C3,$A3
         ),
         (
          $26,$20,$F6,$87,$E8,$62,$5F,$6A,
          $41,$24,$60,$B4,$2E,$2C,$EF,$67,
          $63,$42,$08,$CE,$10,$A0,$CB,$D4,
          $DF,$F7,$04,$4A,$41,$B7,$88,$00,
          $77,$E9,$F8,$DC,$3B,$8D,$12,$16,
          $D3,$37,$6A,$21,$E0,$15,$B5,$8F,
          $B2,$79,$B5,$21,$D8,$3F,$93,$88,
          $C7,$38,$2C,$85,$05,$59,$0B,$9B
         ),
         (
          $22,$7E,$3A,$ED,$8D,$2C,$B1,$0B,
          $91,$8F,$CB,$04,$F9,$DE,$3E,$6D,
          $0A,$57,$E0,$84,$76,$D9,$37,$59,
          $CD,$7B,$2E,$D5,$4A,$1C,$BF,$02,
          $39,$C5,$28,$FB,$04,$BB,$F2,$88,
          $25,$3E,$60,$1D,$3B,$C3,$8B,$21,
          $79,$4A,$FE,$F9,$0B,$17,$09,$4A,
          $18,$2C,$AC,$55,$77,$45,$E7,$5F
         ),
         (
          $1A,$92,$99,$01,$B0,$9C,$25,$F2,
          $7D,$6B,$35,$BE,$7B,$2F,$1C,$47,
          $45,$13,$1F,$DE,$BC,$A7,$F3,$E2,
          $45,$19,$26,$72,$04,$34,$E0,$DB,
          $6E,$74,$FD,$69,$3A,$D2,$9B,$77,
          $7D,$C3,$35,$5C,$59,$2A,$36,$1C,
          $48,$73,$B0,$11,$33,$A5,$7C,$2E,
          $3B,$70,$75,$CB,$DB,$86,$F4,$FC
         ),
         (
          $5F,$D7,$96,$8B,$C2,$FE,$34,$F2,
          $20,$B5,$E3,$DC,$5A,$F9,$57,$17,
          $42,$D7,$3B,$7D,$60,$81,$9F,$28,
          $88,$B6,$29,$07,$2B,$96,$A9,$D8,
          $AB,$2D,$91,$B8,$2D,$0A,$9A,$AB,
          $A6,$1B,$BD,$39,$95,$81,$32,$FC,
          $C4,$25,$70,$23,$D1,$EC,$A5,$91,
          $B3,$05,$4E,$2D,$C8,$1C,$82,$00
         ),
         (
          $DF,$CC,$E8,$CF,$32,$87,$0C,$C6,
          $A5,$03,$EA,$DA,$FC,$87,$FD,$6F,
          $78,$91,$8B,$9B,$4D,$07,$37,$DB,
          $68,$10,$BE,$99,$6B,$54,$97,$E7,
          $E5,$CC,$80,$E3,$12,$F6,$1E,$71,
          $FF,$3E,$96,$24,$43,$60,$73,$15,
          $64,$03,$F7,$35,$F5,$6B,$0B,$01,
          $84,$5C,$18,$F6,$CA,$F7,$72,$E6
         ),
         (
          $02,$F7,$EF,$3A,$9C,$E0,$FF,$F9,
          $60,$F6,$70,$32,$B2,$96,$EF,$CA,
          $30,$61,$F4,$93,$4D,$69,$07,$49,
          $F2,$D0,$1C,$35,$C8,$1C,$14,$F3,
          $9A,$67,$FA,$35,$0B,$C8,$A0,$35,
          $9B,$F1,$72,$4B,$FF,$C3,$BC,$A6,
          $D7,$C7,$BB,$A4,$79,$1F,$D5,$22,
          $A3,$AD,$35,$3C,$02,$EC,$5A,$A8
         ),
         (
          $64,$BE,$5C,$6A,$BA,$65,$D5,$94,
          $84,$4A,$E7,$8B,$B0,$22,$E5,$BE,
          $BE,$12,$7F,$D6,$B6,$FF,$A5,$A1,
          $37,$03,$85,$5A,$B6,$3B,$62,$4D,
          $CD,$1A,$36,$3F,$99,$20,$3F,$63,
          $2E,$C3,$86,$F3,$EA,$76,$7F,$C9,
          $92,$E8,$ED,$96,$86,$58,$6A,$A2,
          $75,$55,$A8,$59,$9D,$5B,$80,$8F
         ),
         (
          $F7,$85,$85,$50,$5C,$4E,$AA,$54,
          $A8,$B5,$BE,$70,$A6,$1E,$73,$5E,
          $0F,$F9,$7A,$F9,$44,$DD,$B3,$00,
          $1E,$35,$D8,$6C,$4E,$21,$99,$D9,
          $76,$10,$4B,$6A,$E3,$17,$50,$A3,
          $6A,$72,$6E,$D2,$85,$06,$4F,$59,
          $81,$B5,$03,$88,$9F,$EF,$82,$2F,
          $CD,$C2,$89,$8D,$DD,$B7,$88,$9A
         ),
         (
          $E4,$B5,$56,$60,$33,$86,$95,$72,
          $ED,$FD,$87,$47,$9A,$5B,$B7,$3C,
          $80,$E8,$75,$9B,$91,$23,$28,$79,
          $D9,$6B,$1D,$DA,$36,$C0,$12,$07,
          $6E,$E5,$A2,$ED,$7A,$E2,$DE,$63,
          $EF,$84,$06,$A0,$6A,$EA,$82,$C1,
          $88,$03,$1B,$56,$0B,$EA,$FB,$58,
          $3F,$B3,$DE,$9E,$57,$95,$2A,$7E
         ),
         (
          $E1,$B3,$E7,$ED,$86,$7F,$6C,$94,
          $84,$A2,$A9,$7F,$77,$15,$F2,$5E,
          $25,$29,$4E,$99,$2E,$41,$F6,$A7,
          $C1,$61,$FF,$C2,$AD,$C6,$DA,$AE,
          $B7,$11,$31,$02,$D5,$E6,$09,$02,
          $87,$FE,$6A,$D9,$4C,$E5,$D6,$B7,
          $39,$C6,$CA,$24,$0B,$05,$C7,$6F,
          $B7,$3F,$25,$DD,$02,$4B,$F9,$35
         ),
         (
          $85,$FD,$08,$5F,$DC,$12,$A0,$80,
          $98,$3D,$F0,$7B,$D7,$01,$2B,$0D,
          $40,$2A,$0F,$40,$43,$FC,$B2,$77,
          $5A,$DF,$0B,$AD,$17,$4F,$9B,$08,
          $D1,$67,$6E,$47,$69,$85,$78,$5C,
          $0A,$5D,$CC,$41,$DB,$FF,$6D,$95,
          $EF,$4D,$66,$A3,$FB,$DC,$4A,$74,
          $B8,$2B,$A5,$2D,$A0,$51,$2B,$74
         ),
         (
          $AE,$D8,$FA,$76,$4B,$0F,$BF,$F8,
          $21,$E0,$52,$33,$D2,$F7,$B0,$90,
          $0E,$C4,$4D,$82,$6F,$95,$E9,$3C,
          $34,$3C,$1B,$C3,$BA,$5A,$24,$37,
          $4B,$1D,$61,$6E,$7E,$7A,$BA,$45,
          $3A,$0A,$DA,$5E,$4F,$AB,$53,$82,
          $40,$9E,$0D,$42,$CE,$9C,$2B,$C7,
          $FB,$39,$A9,$9C,$34,$0C,$20,$F0
         ),
         (
          $7B,$A3,$B2,$E2,$97,$23,$35,$22,
          $EE,$B3,$43,$BD,$3E,$BC,$FD,$83,
          $5A,$04,$00,$77,$35,$E8,$7F,$0C,
          $A3,$00,$CB,$EE,$6D,$41,$65,$65,
          $16,$21,$71,$58,$1E,$40,$20,$FF,
          $4C,$F1,$76,$45,$0F,$12,$91,$EA,
          $22,$85,$CB,$9E,$BF,$FE,$4C,$56,
          $66,$06,$27,$68,$51,$45,$05,$1C
         ),
         (
          $DE,$74,$8B,$CF,$89,$EC,$88,$08,
          $47,$21,$E1,$6B,$85,$F3,$0A,$DB,
          $1A,$61,$34,$D6,$64,$B5,$84,$35,
          $69,$BA,$BC,$5B,$BD,$1A,$15,$CA,
          $9B,$61,$80,$3C,$90,$1A,$4F,$EF,
          $32,$96,$5A,$17,$49,$C9,$F3,$A4,
          $E2,$43,$E1,$73,$93,$9D,$C5,$A8,
          $DC,$49,$5C,$67,$1A,$B5,$21,$45
         ),
         (
          $AA,$F4,$D2,$BD,$F2,$00,$A9,$19,
          $70,$6D,$98,$42,$DC,$E1,$6C,$98,
          $14,$0D,$34,$BC,$43,$3D,$F3,$20,
          $AB,$A9,$BD,$42,$9E,$54,$9A,$A7,
          $A3,$39,$76,$52,$A4,$D7,$68,$27,
          $77,$86,$CF,$99,$3C,$DE,$23,$38,
          $67,$3E,$D2,$E6,$B6,$6C,$96,$1F,
          $EF,$B8,$2C,$D2,$0C,$93,$33,$8F
         ),
         (
          $C4,$08,$21,$89,$68,$B7,$88,$BF,
          $86,$4F,$09,$97,$E6,$BC,$4C,$3D,
          $BA,$68,$B2,$76,$E2,$12,$5A,$48,
          $43,$29,$60,$52,$FF,$93,$BF,$57,
          $67,$B8,$CD,$CE,$71,$31,$F0,$87,
          $64,$30,$C1,$16,$5F,$EC,$6C,$4F,
          $47,$AD,$AA,$4F,$D8,$BC,$FA,$CE,
          $F4,$63,$B5,$D3,$D0,$FA,$61,$A0
         ),
         (
          $76,$D2,$D8,$19,$C9,$2B,$CE,$55,
          $FA,$8E,$09,$2A,$B1,$BF,$9B,$9E,
          $AB,$23,$7A,$25,$26,$79,$86,$CA,
          $CF,$2B,$8E,$E1,$4D,$21,$4D,$73,
          $0D,$C9,$A5,$AA,$2D,$7B,$59,$6E,
          $86,$A1,$FD,$8F,$A0,$80,$4C,$77,
          $40,$2D,$2F,$CD,$45,$08,$36,$88,
          $B2,$18,$B1,$CD,$FA,$0D,$CB,$CB
         ),
         (
          $72,$06,$5E,$E4,$DD,$91,$C2,$D8,
          $50,$9F,$A1,$FC,$28,$A3,$7C,$7F,
          $C9,$FA,$7D,$5B,$3F,$8A,$D3,$D0,
          $D7,$A2,$56,$26,$B5,$7B,$1B,$44,
          $78,$8D,$4C,$AF,$80,$62,$90,$42,
          $5F,$98,$90,$A3,$A2,$A3,$5A,$90,
          $5A,$B4,$B3,$7A,$CF,$D0,$DA,$6E,
          $45,$17,$B2,$52,$5C,$96,$51,$E4
         ),
         (
          $64,$47,$5D,$FE,$76,$00,$D7,$17,
          $1B,$EA,$0B,$39,$4E,$27,$C9,$B0,
          $0D,$8E,$74,$DD,$1E,$41,$6A,$79,
          $47,$36,$82,$AD,$3D,$FD,$BB,$70,
          $66,$31,$55,$80,$55,$CF,$C8,$A4,
          $0E,$07,$BD,$01,$5A,$45,$40,$DC,
          $DE,$A1,$58,$83,$CB,$BF,$31,$41,
          $2D,$F1,$DE,$1C,$D4,$15,$2B,$91
         ),
         (
          $12,$CD,$16,$74,$A4,$48,$8A,$5D,
          $7C,$2B,$31,$60,$D2,$E2,$C4,$B5,
          $83,$71,$BE,$DA,$D7,$93,$41,$8D,
          $6F,$19,$C6,$EE,$38,$5D,$70,$B3,
          $E0,$67,$39,$36,$9D,$4D,$F9,$10,
          $ED,$B0,$B0,$A5,$4C,$BF,$F4,$3D,
          $54,$54,$4C,$D3,$7A,$B3,$A0,$6C,
          $FA,$0A,$3D,$DA,$C8,$B6,$6C,$89
         ),
         (
          $60,$75,$69,$66,$47,$9D,$ED,$C6,
          $DD,$4B,$CF,$F8,$EA,$7D,$1D,$4C,
          $E4,$D4,$AF,$2E,$7B,$09,$7E,$32,
          $E3,$76,$35,$18,$44,$11,$47,$CC,
          $12,$B3,$C0,$EE,$6D,$2E,$CA,$BF,
          $11,$98,$CE,$C9,$2E,$86,$A3,$61,
          $6F,$BA,$4F,$4E,$87,$2F,$58,$25,
          $33,$0A,$DB,$B4,$C1,$DE,$E4,$44
         ),
         (
          $A7,$80,$3B,$CB,$71,$BC,$1D,$0F,
          $43,$83,$DD,$E1,$E0,$61,$2E,$04,
          $F8,$72,$B7,$15,$AD,$30,$81,$5C,
          $22,$49,$CF,$34,$AB,$B8,$B0,$24,
          $91,$5C,$B2,$FC,$9F,$4E,$7C,$C4,
          $C8,$CF,$D4,$5B,$E2,$D5,$A9,$1E,
          $AB,$09,$41,$C7,$D2,$70,$E2,$DA,
          $4C,$A4,$A9,$F7,$AC,$68,$66,$3A
         ),
         (
          $B8,$4E,$F6,$A7,$22,$9A,$34,$A7,
          $50,$D9,$A9,$8E,$E2,$52,$98,$71,
          $81,$6B,$87,$FB,$E3,$BC,$45,$B4,
          $5F,$A5,$AE,$82,$D5,$14,$15,$40,
          $21,$11,$65,$C3,$C5,$D7,$A7,$47,
          $6B,$A5,$A4,$AA,$06,$D6,$64,$76,
          $F0,$D9,$DC,$49,$A3,$F1,$EE,$72,
          $C3,$AC,$AB,$D4,$98,$96,$74,$14
         ),
         (
          $FA,$E4,$B6,$D8,$EF,$C3,$F8,$C8,
          $E6,$4D,$00,$1D,$AB,$EC,$3A,$21,
          $F5,$44,$E8,$27,$14,$74,$52,$51,
          $B2,$B4,$B3,$93,$F2,$F4,$3E,$0D,
          $A3,$D4,$03,$C6,$4D,$B9,$5A,$2C,
          $B6,$E2,$3E,$BB,$7B,$9E,$94,$CD,
          $D5,$DD,$AC,$54,$F0,$7C,$4A,$61,
          $BD,$3C,$B1,$0A,$A6,$F9,$3B,$49
         ),
         (
          $34,$F7,$28,$66,$05,$A1,$22,$36,
          $95,$40,$14,$1D,$ED,$79,$B8,$95,
          $72,$55,$DA,$2D,$41,$55,$AB,$BF,
          $5A,$8D,$BB,$89,$C8,$EB,$7E,$DE,
          $8E,$EE,$F1,$DA,$A4,$6D,$C2,$9D,
          $75,$1D,$04,$5D,$C3,$B1,$D6,$58,
          $BB,$64,$B8,$0F,$F8,$58,$9E,$DD,
          $B3,$82,$4B,$13,$DA,$23,$5A,$6B
         ),
         (
          $3B,$3B,$48,$43,$4B,$E2,$7B,$9E,
          $AB,$AB,$BA,$43,$BF,$6B,$35,$F1,
          $4B,$30,$F6,$A8,$8D,$C2,$E7,$50,
          $C3,$58,$47,$0D,$6B,$3A,$A3,$C1,
          $8E,$47,$DB,$40,$17,$FA,$55,$10,
          $6D,$82,$52,$F0,$16,$37,$1A,$00,
          $F5,$F8,$B0,$70,$B7,$4B,$A5,$F2,
          $3C,$FF,$C5,$51,$1C,$9F,$09,$F0
         ),
         (
          $BA,$28,$9E,$BD,$65,$62,$C4,$8C,
          $3E,$10,$A8,$AD,$6C,$E0,$2E,$73,
          $43,$3D,$1E,$93,$D7,$C9,$27,$9D,
          $4D,$60,$A7,$E8,$79,$EE,$11,$F4,
          $41,$A0,$00,$F4,$8E,$D9,$F7,$C4,
          $ED,$87,$A4,$51,$36,$D7,$DC,$CD,
          $CA,$48,$21,$09,$C7,$8A,$51,$06,
          $2B,$3B,$A4,$04,$4A,$DA,$24,$69
         ),
         (
          $02,$29,$39,$E2,$38,$6C,$5A,$37,
          $04,$98,$56,$C8,$50,$A2,$BB,$10,
          $A1,$3D,$FE,$A4,$21,$2B,$4C,$73,
          $2A,$88,$40,$A9,$FF,$A5,$FA,$F5,
          $48,$75,$C5,$44,$88,$16,$B2,$78,
          $5A,$00,$7D,$A8,$A8,$D2,$BC,$7D,
          $71,$A5,$4E,$4E,$65,$71,$F1,$0B,
          $60,$0C,$BD,$B2,$5D,$13,$ED,$E3
         ),
         (
          $E6,$FE,$C1,$9D,$89,$CE,$87,$17,
          $B1,$A0,$87,$02,$46,$70,$FE,$02,
          $6F,$6C,$7C,$BD,$A1,$1C,$AE,$F9,
          $59,$BB,$2D,$35,$1B,$F8,$56,$F8,
          $05,$5D,$1C,$0E,$BD,$AA,$A9,$D1,
          $B1,$78,$86,$FC,$2C,$56,$2B,$5E,
          $99,$64,$2F,$C0,$64,$71,$0C,$0D,
          $34,$88,$A0,$2B,$5E,$D7,$F6,$FD
         ),
         (
          $94,$C9,$6F,$02,$A8,$F5,$76,$AC,
          $A3,$2B,$A6,$1C,$2B,$20,$6F,$90,
          $72,$85,$D9,$29,$9B,$83,$AC,$17,
          $5C,$20,$9A,$8D,$43,$D5,$3B,$FE,
          $68,$3D,$D1,$D8,$3E,$75,$49,$CB,
          $90,$6C,$28,$F5,$9A,$B7,$C4,$6F,
          $87,$51,$36,$6A,$28,$C3,$9D,$D5,
          $FE,$26,$93,$C9,$01,$96,$66,$C8
         ),
         (
          $31,$A0,$CD,$21,$5E,$BD,$2C,$B6,
          $1D,$E5,$B9,$ED,$C9,$1E,$61,$95,
          $E3,$1C,$59,$A5,$64,$8D,$5C,$9F,
          $73,$7E,$12,$5B,$26,$05,$70,$8F,
          $2E,$32,$5A,$B3,$38,$1C,$8D,$CE,
          $1A,$3E,$95,$88,$86,$F1,$EC,$DC,
          $60,$31,$8F,$88,$2C,$FE,$20,$A2,
          $41,$91,$35,$2E,$61,$7B,$0F,$21
         ),
         (
          $91,$AB,$50,$4A,$52,$2D,$CE,$78,
          $77,$9F,$4C,$6C,$6B,$A2,$E6,$B6,
          $DB,$55,$65,$C7,$6D,$3E,$7E,$7C,
          $92,$0C,$AF,$7F,$75,$7E,$F9,$DB,
          $7C,$8F,$CF,$10,$E5,$7F,$03,$37,
          $9E,$A9,$BF,$75,$EB,$59,$89,$5D,
          $96,$E1,$49,$80,$0B,$6A,$AE,$01,
          $DB,$77,$8B,$B9,$0A,$FB,$C9,$89
         ),
         (
          $D8,$5C,$AB,$C6,$BD,$5B,$1A,$01,
          $A5,$AF,$D8,$C6,$73,$47,$40,$DA,
          $9F,$D1,$C1,$AC,$C6,$DB,$29,$BF,
          $C8,$A2,$E5,$B6,$68,$B0,$28,$B6,
          $B3,$15,$4B,$FB,$87,$03,$FA,$31,
          $80,$25,$1D,$58,$9A,$D3,$80,$40,
          $CE,$B7,$07,$C4,$BA,$D1,$B5,$34,
          $3C,$B4,$26,$B6,$1E,$AA,$49,$C1
         ),
         (
          $D6,$2E,$FB,$EC,$2C,$A9,$C1,$F8,
          $BD,$66,$CE,$8B,$3F,$6A,$89,$8C,
          $B3,$F7,$56,$6B,$A6,$56,$8C,$61,
          $8A,$D1,$FE,$B2,$B6,$5B,$76,$C3,
          $CE,$1D,$D2,$0F,$73,$95,$37,$2F,
          $AF,$28,$42,$7F,$61,$C9,$27,$80,
          $49,$CF,$01,$40,$DF,$43,$4F,$56,
          $33,$04,$8C,$86,$B8,$1E,$03,$99
         ),
         (
          $7C,$8F,$DC,$61,$75,$43,$9E,$2C,
          $3D,$B1,$5B,$AF,$A7,$FB,$06,$14,
          $3A,$6A,$23,$BC,$90,$F4,$49,$E7,
          $9D,$EE,$F7,$3C,$3D,$49,$2A,$67,
          $17,$15,$C1,$93,$B6,$FE,$A9,$F0,
          $36,$05,$0B,$94,$60,$69,$85,$6B,
          $89,$7E,$08,$C0,$07,$68,$F5,$EE,
          $5D,$DC,$F7,$0B,$7C,$D6,$D0,$E0
         ),
         (
          $58,$60,$2E,$E7,$46,$8E,$6B,$C9,
          $DF,$21,$BD,$51,$B2,$3C,$00,$5F,
          $72,$D6,$CB,$01,$3F,$0A,$1B,$48,
          $CB,$EC,$5E,$CA,$29,$92,$99,$F9,
          $7F,$09,$F5,$4A,$9A,$01,$48,$3E,
          $AE,$B3,$15,$A6,$47,$8B,$AD,$37,
          $BA,$47,$CA,$13,$47,$C7,$C8,$FC,
          $9E,$66,$95,$59,$2C,$91,$D7,$23
         ),
         (
          $27,$F5,$B7,$9E,$D2,$56,$B0,$50,
          $99,$3D,$79,$34,$96,$ED,$F4,$80,
          $7C,$1D,$85,$A7,$B0,$A6,$7C,$9C,
          $4F,$A9,$98,$60,$75,$0B,$0A,$E6,
          $69,$89,$67,$0A,$8F,$FD,$78,$56,
          $D7,$CE,$41,$15,$99,$E5,$8C,$4D,
          $77,$B2,$32,$A6,$2B,$EF,$64,$D1,
          $52,$75,$BE,$46,$A6,$82,$35,$FF
         ),
         (
          $39,$57,$A9,$76,$B9,$F1,$88,$7B,
          $F0,$04,$A8,$DC,$A9,$42,$C9,$2D,
          $2B,$37,$EA,$52,$60,$0F,$25,$E0,
          $C9,$BC,$57,$07,$D0,$27,$9C,$00,
          $C6,$E8,$5A,$83,$9B,$0D,$2D,$8E,
          $B5,$9C,$51,$D9,$47,$88,$EB,$E6,
          $24,$74,$A7,$91,$CA,$DF,$52,$CC,
          $CF,$20,$F5,$07,$0B,$65,$73,$FC
         ),
         (
          $EA,$A2,$37,$6D,$55,$38,$0B,$F7,
          $72,$EC,$CA,$9C,$B0,$AA,$46,$68,
          $C9,$5C,$70,$71,$62,$FA,$86,$D5,
          $18,$C8,$CE,$0C,$A9,$BF,$73,$62,
          $B9,$F2,$A0,$AD,$C3,$FF,$59,$92,
          $2D,$F9,$21,$B9,$45,$67,$E8,$1E,
          $45,$2F,$6C,$1A,$07,$FC,$81,$7C,
          $EB,$E9,$96,$04,$B3,$50,$5D,$38
         ),
         (
          $C1,$E2,$C7,$8B,$6B,$27,$34,$E2,
          $48,$0E,$C5,$50,$43,$4C,$B5,$D6,
          $13,$11,$1A,$DC,$C2,$1D,$47,$55,
          $45,$C3,$B1,$B7,$E6,$FF,$12,$44,
          $44,$76,$E5,$C0,$55,$13,$2E,$22,
          $29,$DC,$0F,$80,$70,$44,$BB,$91,
          $9B,$1A,$56,$62,$DD,$38,$A9,$EE,
          $65,$E2,$43,$A3,$91,$1A,$ED,$1A
         ),
         (
          $8A,$B4,$87,$13,$38,$9D,$D0,$FC,
          $F9,$F9,$65,$D3,$CE,$66,$B1,$E5,
          $59,$A1,$F8,$C5,$87,$41,$D6,$76,
          $83,$CD,$97,$13,$54,$F4,$52,$E6,
          $2D,$02,$07,$A6,$5E,$43,$6C,$5D,
          $5D,$8F,$8E,$E7,$1C,$6A,$BF,$E5,
          $0E,$66,$90,$04,$C3,$02,$B3,$1A,
          $7E,$A8,$31,$1D,$4A,$91,$60,$51
         ),
         (
          $24,$CE,$0A,$DD,$AA,$4C,$65,$03,
          $8B,$D1,$B1,$C0,$F1,$45,$2A,$0B,
          $12,$87,$77,$AA,$BC,$94,$A2,$9D,
          $F2,$FD,$6C,$7E,$2F,$85,$F8,$AB,
          $9A,$C7,$EF,$F5,$16,$B0,$E0,$A8,
          $25,$C8,$4A,$24,$CF,$E4,$92,$EA,
          $AD,$0A,$63,$08,$E4,$6D,$D4,$2F,
          $E8,$33,$3A,$B9,$71,$BB,$30,$CA
         ),
         (
          $51,$54,$F9,$29,$EE,$03,$04,$5B,
          $6B,$0C,$00,$04,$FA,$77,$8E,$DE,
          $E1,$D1,$39,$89,$32,$67,$CC,$84,
          $82,$5A,$D7,$B3,$6C,$63,$DE,$32,
          $79,$8E,$4A,$16,$6D,$24,$68,$65,
          $61,$35,$4F,$63,$B0,$07,$09,$A1,
          $36,$4B,$3C,$24,$1D,$E3,$FE,$BF,
          $07,$54,$04,$58,$97,$46,$7C,$D4
         ),
         (
          $E7,$4E,$90,$79,$20,$FD,$87,$BD,
          $5A,$D6,$36,$DD,$11,$08,$5E,$50,
          $EE,$70,$45,$9C,$44,$3E,$1C,$E5,
          $80,$9A,$F2,$BC,$2E,$BA,$39,$F9,
          $E6,$D7,$12,$8E,$0E,$37,$12,$C3,
          $16,$DA,$06,$F4,$70,$5D,$78,$A4,
          $83,$8E,$28,$12,$1D,$43,$44,$A2,
          $C7,$9C,$5E,$0D,$B3,$07,$A6,$77
         ),
         (
          $BF,$91,$A2,$23,$34,$BA,$C2,$0F,
          $3F,$D8,$06,$63,$B3,$CD,$06,$C4,
          $E8,$80,$2F,$30,$E6,$B5,$9F,$90,
          $D3,$03,$5C,$C9,$79,$8A,$21,$7E,
          $D5,$A3,$1A,$BB,$DA,$7F,$A6,$84,
          $28,$27,$BD,$F2,$A7,$A1,$C2,$1F,
          $6F,$CF,$CC,$BB,$54,$C6,$C5,$29,
          $26,$F3,$2D,$A8,$16,$26,$9B,$E1
         ),
         (
          $D9,$D5,$C7,$4B,$E5,$12,$1B,$0B,
          $D7,$42,$F2,$6B,$FF,$B8,$C8,$9F,
          $89,$17,$1F,$3F,$93,$49,$13,$49,
          $2B,$09,$03,$C2,$71,$BB,$E2,$B3,
          $39,$5E,$F2,$59,$66,$9B,$EF,$43,
          $B5,$7F,$7F,$CC,$30,$27,$DB,$01,
          $82,$3F,$6B,$AE,$E6,$6E,$4F,$9F,
          $EA,$D4,$D6,$72,$6C,$74,$1F,$CE
         ),
         (
          $50,$C8,$B8,$CF,$34,$CD,$87,$9F,
          $80,$E2,$FA,$AB,$32,$30,$B0,$C0,
          $E1,$CC,$3E,$9D,$CA,$DE,$B1,$B9,
          $D9,$7A,$B9,$23,$41,$5D,$D9,$A1,
          $FE,$38,$AD,$DD,$5C,$11,$75,$6C,
          $67,$99,$0B,$25,$6E,$95,$AD,$6D,
          $8F,$9F,$ED,$CE,$10,$BF,$1C,$90,
          $67,$9C,$DE,$0E,$CF,$1B,$E3,$47
         ),
         (
          $0A,$38,$6E,$7C,$D5,$DD,$9B,$77,
          $A0,$35,$E0,$9F,$E6,$FE,$E2,$C8,
          $CE,$61,$B5,$38,$3C,$87,$EA,$43,
          $20,$50,$59,$C5,$E4,$CD,$4F,$44,
          $08,$31,$9B,$B0,$A8,$23,$60,$F6,
          $A5,$8E,$6C,$9C,$E3,$F4,$87,$C4,
          $46,$06,$3B,$F8,$13,$BC,$6B,$A5,
          $35,$E1,$7F,$C1,$82,$6C,$FC,$91
         ),
         (
          $1F,$14,$59,$CB,$6B,$61,$CB,$AC,
          $5F,$0E,$FE,$8F,$C4,$87,$53,$8F,
          $42,$54,$89,$87,$FC,$D5,$62,$21,
          $CF,$A7,$BE,$B2,$25,$04,$76,$9E,
          $79,$2C,$45,$AD,$FB,$1D,$6B,$3D,
          $60,$D7,$B7,$49,$C8,$A7,$5B,$0B,
          $DF,$14,$E8,$EA,$72,$1B,$95,$DC,
          $A5,$38,$CA,$6E,$25,$71,$12,$09
         ),
         (
          $E5,$8B,$38,$36,$B7,$D8,$FE,$DB,
          $B5,$0C,$A5,$72,$5C,$65,$71,$E7,
          $4C,$07,$85,$E9,$78,$21,$DA,$B8,
          $B6,$29,$8C,$10,$E4,$C0,$79,$D4,
          $A6,$CD,$F2,$2F,$0F,$ED,$B5,$50,
          $32,$92,$5C,$16,$74,$81,$15,$F0,
          $1A,$10,$5E,$77,$E0,$0C,$EE,$3D,
          $07,$92,$4D,$C0,$D8,$F9,$06,$59
         ),
         (
          $B9,$29,$CC,$65,$05,$F0,$20,$15,
          $86,$72,$DE,$DA,$56,$D0,$DB,$08,
          $1A,$2E,$E3,$4C,$00,$C1,$10,$00,
          $29,$BD,$F8,$EA,$98,$03,$4F,$A4,
          $BF,$3E,$86,$55,$EC,$69,$7F,$E3,
          $6F,$40,$55,$3C,$5B,$B4,$68,$01,
          $64,$4A,$62,$7D,$33,$42,$F4,$FC,
          $92,$B6,$1F,$03,$29,$0F,$B3,$81
         ),
         (
          $72,$D3,$53,$99,$4B,$49,$D3,$E0,
          $31,$53,$92,$9A,$1E,$4D,$4F,$18,
          $8E,$E5,$8A,$B9,$E7,$2E,$E8,$E5,
          $12,$F2,$9B,$C7,$73,$91,$38,$19,
          $CE,$05,$7D,$DD,$70,$02,$C0,$43,
          $3E,$E0,$A1,$61,$14,$E3,$D1,$56,
          $DD,$2C,$4A,$7E,$80,$EE,$53,$37,
          $8B,$86,$70,$F2,$3E,$33,$EF,$56
         ),
         (
          $C7,$0E,$F9,$BF,$D7,$75,$D4,$08,
          $17,$67,$37,$A0,$73,$6D,$68,$51,
          $7C,$E1,$AA,$AD,$7E,$81,$A9,$3C,
          $8C,$1E,$D9,$67,$EA,$21,$4F,$56,
          $C8,$A3,$77,$B1,$76,$3E,$67,$66,
          $15,$B6,$0F,$39,$88,$24,$1E,$AE,
          $6E,$AB,$96,$85,$A5,$12,$49,$29,
          $D2,$81,$88,$F2,$9E,$AB,$06,$F7
         ),
         (
          $C2,$30,$F0,$80,$26,$79,$CB,$33,
          $82,$2E,$F8,$B3,$B2,$1B,$F7,$A9,
          $A2,$89,$42,$09,$29,$01,$D7,$DA,
          $C3,$76,$03,$00,$83,$10,$26,$CF,
          $35,$4C,$92,$32,$DF,$3E,$08,$4D,
          $99,$03,$13,$0C,$60,$1F,$63,$C1,
          $F4,$A4,$A4,$B8,$10,$6E,$46,$8C,
          $D4,$43,$BB,$E5,$A7,$34,$F4,$5F
         ),
         (
          $6F,$43,$09,$4C,$AF,$B5,$EB,$F1,
          $F7,$A4,$93,$7E,$C5,$0F,$56,$A4,
          $C9,$DA,$30,$3C,$BB,$55,$AC,$1F,
          $27,$F1,$F1,$97,$6C,$D9,$6B,$ED,
          $A9,$46,$4F,$0E,$7B,$9C,$54,$62,
          $0B,$8A,$9F,$BA,$98,$31,$64,$B8,
          $BE,$35,$78,$42,$5A,$02,$4F,$5F,
          $E1,$99,$C3,$63,$56,$B8,$89,$72
         ),
         (
          $37,$45,$27,$3F,$4C,$38,$22,$5D,
          $B2,$33,$73,$81,$87,$1A,$0C,$6A,
          $AF,$D3,$AF,$9B,$01,$8C,$88,$AA,
          $02,$02,$58,$50,$A5,$DC,$3A,$42,
          $A1,$A3,$E0,$3E,$56,$CB,$F1,$B0,
          $87,$6D,$63,$A4,$41,$F1,$D2,$85,
          $6A,$39,$B8,$80,$1E,$B5,$AF,$32,
          $52,$01,$C4,$15,$D6,$5E,$97,$FE
         ),
         (
          $C5,$0C,$44,$CC,$A3,$EC,$3E,$DA,
          $AE,$77,$9A,$7E,$17,$94,$50,$EB,
          $DD,$A2,$F9,$70,$67,$C6,$90,$AA,
          $6C,$5A,$4A,$C7,$C3,$01,$39,$BB,
          $27,$C0,$DF,$4D,$B3,$22,$0E,$63,
          $CB,$11,$0D,$64,$F3,$7F,$FE,$07,
          $8D,$B7,$26,$53,$E2,$DA,$AC,$F9,
          $3A,$E3,$F0,$A2,$D1,$A7,$EB,$2E
         ),
         (
          $8A,$EF,$26,$3E,$38,$5C,$BC,$61,
          $E1,$9B,$28,$91,$42,$43,$26,$2A,
          $F5,$AF,$E8,$72,$6A,$F3,$CE,$39,
          $A7,$9C,$27,$02,$8C,$F3,$EC,$D3,
          $F8,$D2,$DF,$D9,$CF,$C9,$AD,$91,
          $B5,$8F,$6F,$20,$77,$8F,$D5,$F0,
          $28,$94,$A3,$D9,$1C,$7D,$57,$D1,
          $E4,$B8,$66,$A7,$F3,$64,$B6,$BE
         ),
         (
          $28,$69,$61,$41,$DE,$6E,$2D,$9B,
          $CB,$32,$35,$57,$8A,$66,$16,$6C,
          $14,$48,$D3,$E9,$05,$A1,$B4,$82,
          $D4,$23,$BE,$4B,$C5,$36,$9B,$C8,
          $C7,$4D,$AE,$0A,$CC,$9C,$C1,$23,
          $E1,$D8,$DD,$CE,$9F,$97,$91,$7E,
          $8C,$01,$9C,$55,$2D,$A3,$2D,$39,
          $D2,$21,$9B,$9A,$BF,$0F,$A8,$C8
         ),
         (
          $2F,$B9,$EB,$20,$85,$83,$01,$81,
          $90,$3A,$9D,$AF,$E3,$DB,$42,$8E,
          $E1,$5B,$E7,$66,$22,$24,$EF,$D6,
          $43,$37,$1F,$B2,$56,$46,$AE,$E7,
          $16,$E5,$31,$EC,$A6,$9B,$2B,$DC,
          $82,$33,$F1,$A8,$08,$1F,$A4,$3D,
          $A1,$50,$03,$02,$97,$5A,$77,$F4,
          $2F,$A5,$92,$13,$67,$10,$E9,$DC
         ),
         (
          $66,$F9,$A7,$14,$3F,$7A,$33,$14,
          $A6,$69,$BF,$2E,$24,$BB,$B3,$50,
          $14,$26,$1D,$63,$9F,$49,$5B,$6C,
          $9C,$1F,$10,$4F,$E8,$E3,$20,$AC,
          $A6,$0D,$45,$50,$D6,$9D,$52,$ED,
          $BD,$5A,$3C,$DE,$B4,$01,$4A,$E6,
          $5B,$1D,$87,$AA,$77,$0B,$69,$AE,
          $5C,$15,$F4,$33,$0B,$0B,$0A,$D8
         ),
         (
          $F4,$C4,$DD,$1D,$59,$4C,$35,$65,
          $E3,$E2,$5C,$A4,$3D,$AD,$82,$F6,
          $2A,$BE,$A4,$83,$5E,$D4,$CD,$81,
          $1B,$CD,$97,$5E,$46,$27,$98,$28,
          $D4,$4D,$4C,$62,$C3,$67,$9F,$1B,
          $7F,$7B,$9D,$D4,$57,$1D,$7B,$49,
          $55,$73,$47,$B8,$C5,$46,$0C,$BD,
          $C1,$BE,$F6,$90,$FB,$2A,$08,$C0
         ),
         (
          $8F,$1D,$C9,$64,$9C,$3A,$84,$55,
          $1F,$8F,$6E,$91,$CA,$C6,$82,$42,
          $A4,$3B,$1F,$8F,$32,$8E,$E9,$22,
          $80,$25,$73,$87,$FA,$75,$59,$AA,
          $6D,$B1,$2E,$4A,$EA,$DC,$2D,$26,
          $09,$91,$78,$74,$9C,$68,$64,$B3,
          $57,$F3,$F8,$3B,$2F,$B3,$EF,$A8,
          $D2,$A8,$DB,$05,$6B,$ED,$6B,$CC
         ),
         (
          $31,$39,$C1,$A7,$F9,$7A,$FD,$16,
          $75,$D4,$60,$EB,$BC,$07,$F2,$72,
          $8A,$A1,$50,$DF,$84,$96,$24,$51,
          $1E,$E0,$4B,$74,$3B,$A0,$A8,$33,
          $09,$2F,$18,$C1,$2D,$C9,$1B,$4D,
          $D2,$43,$F3,$33,$40,$2F,$59,$FE,
          $28,$AB,$DB,$BB,$AE,$30,$1E,$7B,
          $65,$9C,$7A,$26,$D5,$C0,$F9,$79
         ),
         (
          $06,$F9,$4A,$29,$96,$15,$8A,$81,
          $9F,$E3,$4C,$40,$DE,$3C,$F0,$37,
          $9F,$D9,$FB,$85,$B3,$E3,$63,$BA,
          $39,$26,$A0,$E7,$D9,$60,$E3,$F4,
          $C2,$E0,$C7,$0C,$7C,$E0,$CC,$B2,
          $A6,$4F,$C2,$98,$69,$F6,$E7,$AB,
          $12,$BD,$4D,$3F,$14,$FC,$E9,$43,
          $27,$90,$27,$E7,$85,$FB,$5C,$29
         ),
         (
          $C2,$9C,$39,$9E,$F3,$EE,$E8,$96,
          $1E,$87,$56,$5C,$1C,$E2,$63,$92,
          $5F,$C3,$D0,$CE,$26,$7D,$13,$E4,
          $8D,$D9,$E7,$32,$EE,$67,$B0,$F6,
          $9F,$AD,$56,$40,$1B,$0F,$10,$FC,
          $AA,$C1,$19,$20,$10,$46,$CC,$A2,
          $8C,$5B,$14,$AB,$DE,$A3,$21,$2A,
          $E6,$55,$62,$F7,$F1,$38,$DB,$3D
         ),
         (
          $4C,$EC,$4C,$9D,$F5,$2E,$EF,$05,
          $C3,$F6,$FA,$AA,$97,$91,$BC,$74,
          $45,$93,$71,$83,$22,$4E,$CC,$37,
          $A1,$E5,$8D,$01,$32,$D3,$56,$17,
          $53,$1D,$7E,$79,$5F,$52,$AF,$7B,
          $1E,$B9,$D1,$47,$DE,$12,$92,$D3,
          $45,$FE,$34,$18,$23,$F8,$E6,$BC,
          $1E,$5B,$AD,$CA,$5C,$65,$61,$08
         ),
         (
          $89,$8B,$FB,$AE,$93,$B3,$E1,$8D,
          $00,$69,$7E,$AB,$7D,$97,$04,$FA,
          $36,$EC,$33,$9D,$07,$61,$31,$CE,
          $FD,$F3,$0E,$DB,$E8,$D9,$CC,$81,
          $C3,$A8,$0B,$12,$96,$59,$B1,$63,
          $A3,$23,$BA,$B9,$79,$3D,$4F,$EE,
          $D9,$2D,$54,$DA,$E9,$66,$C7,$75,
          $29,$76,$4A,$09,$BE,$88,$DB,$45
         ),
         (
          $EE,$9B,$D0,$46,$9D,$3A,$AF,$4F,
          $14,$03,$5B,$E4,$8A,$2C,$3B,$84,
          $D9,$B4,$B1,$FF,$F1,$D9,$45,$E1,
          $F1,$C1,$D3,$89,$80,$A9,$51,$BE,
          $19,$7B,$25,$FE,$22,$C7,$31,$F2,
          $0A,$EA,$CC,$93,$0B,$A9,$C4,$A1,
          $F4,$76,$22,$27,$61,$7A,$D3,$50,
          $FD,$AB,$B4,$E8,$02,$73,$A0,$F4
         ),
         (
          $3D,$4D,$31,$13,$30,$05,$81,$CD,
          $96,$AC,$BF,$09,$1C,$3D,$0F,$3C,
          $31,$01,$38,$CD,$69,$79,$E6,$02,
          $6C,$DE,$62,$3E,$2D,$D1,$B2,$4D,
          $4A,$86,$38,$BE,$D1,$07,$33,$44,
          $78,$3A,$D0,$64,$9C,$C6,$30,$5C,
          $CE,$C0,$4B,$EB,$49,$F3,$1C,$63,
          $30,$88,$A9,$9B,$65,$13,$02,$67
         ),
         (
          $95,$C0,$59,$1A,$D9,$1F,$92,$1A,
          $C7,$BE,$6D,$9C,$E3,$7E,$06,$63,
          $ED,$80,$11,$C1,$CF,$D6,$D0,$16,
          $2A,$55,$72,$E9,$43,$68,$BA,$C0,
          $20,$24,$48,$5E,$6A,$39,$85,$4A,
          $A4,$6F,$E3,$8E,$97,$D6,$C6,$B1,
          $94,$7C,$D2,$72,$D8,$6B,$06,$BB,
          $5B,$2F,$78,$B9,$B6,$8D,$55,$9D
         ),
         (
          $22,$7B,$79,$DE,$D3,$68,$15,$3B,
          $F4,$6C,$0A,$3C,$A9,$78,$BF,$DB,
          $EF,$31,$F3,$02,$4A,$56,$65,$84,
          $24,$68,$49,$0B,$0F,$F7,$48,$AE,
          $04,$E7,$83,$2E,$D4,$C9,$F4,$9D,
          $E9,$B1,$70,$67,$09,$D6,$23,$E5,
          $C8,$C1,$5E,$3C,$AE,$CA,$E8,$D5,
          $E4,$33,$43,$0F,$F7,$2F,$20,$EB
         ),
         (
          $5D,$34,$F3,$95,$2F,$01,$05,$EE,
          $F8,$8A,$E8,$B6,$4C,$6C,$E9,$5E,
          $BF,$AD,$E0,$E0,$2C,$69,$B0,$87,
          $62,$A8,$71,$2D,$2E,$49,$11,$AD,
          $3F,$94,$1F,$C4,$03,$4D,$C9,$B2,
          $E4,$79,$FD,$BC,$D2,$79,$B9,$02,
          $FA,$F5,$D8,$38,$BB,$2E,$0C,$64,
          $95,$D3,$72,$B5,$B7,$02,$98,$13
         ),
         (
          $7F,$93,$9B,$F8,$35,$3A,$BC,$E4,
          $9E,$77,$F1,$4F,$37,$50,$AF,$20,
          $B7,$B0,$39,$02,$E1,$A1,$E7,$FB,
          $6A,$AF,$76,$D0,$25,$9C,$D4,$01,
          $A8,$31,$90,$F1,$56,$40,$E7,$4F,
          $3E,$6C,$5A,$90,$E8,$39,$C7,$82,
          $1F,$64,$74,$75,$7F,$75,$C7,$BF,
          $90,$02,$08,$4D,$DC,$7A,$62,$DC
         ),
         (
          $06,$2B,$61,$A2,$F9,$A3,$3A,$71,
          $D7,$D0,$A0,$61,$19,$64,$4C,$70,
          $B0,$71,$6A,$50,$4D,$E7,$E5,$E1,
          $BE,$49,$BD,$7B,$86,$E7,$ED,$68,
          $17,$71,$4F,$9F,$0F,$C3,$13,$D0,
          $61,$29,$59,$7E,$9A,$22,$35,$EC,
          $85,$21,$DE,$36,$F7,$29,$0A,$90,
          $CC,$FC,$1F,$FA,$6D,$0A,$EE,$29
         ),
         (
          $F2,$9E,$01,$EE,$AE,$64,$31,$1E,
          $B7,$F1,$C6,$42,$2F,$94,$6B,$F7,
          $BE,$A3,$63,$79,$52,$3E,$7B,$2B,
          $BA,$BA,$7D,$1D,$34,$A2,$2D,$5E,
          $A5,$F1,$C5,$A0,$9D,$5C,$E1,$FE,
          $68,$2C,$CE,$D9,$A4,$79,$8D,$1A,
          $05,$B4,$6C,$D7,$2D,$FF,$5C,$1B,
          $35,$54,$40,$B2,$A2,$D4,$76,$BC
         ),
         (
          $EC,$38,$CD,$3B,$BA,$B3,$EF,$35,
          $D7,$CB,$6D,$5C,$91,$42,$98,$35,
          $1D,$8A,$9D,$C9,$7F,$CE,$E0,$51,
          $A8,$A0,$2F,$58,$E3,$ED,$61,$84,
          $D0,$B7,$81,$0A,$56,$15,$41,$1A,
          $B1,$B9,$52,$09,$C3,$C8,$10,$11,
          $4F,$DE,$B2,$24,$52,$08,$4E,$77,
          $F3,$F8,$47,$C6,$DB,$AA,$FE,$16
         ),
         (
          $C2,$AE,$F5,$E0,$CA,$43,$E8,$26,
          $41,$56,$5B,$8C,$B9,$43,$AA,$8B,
          $A5,$35,$50,$CA,$EF,$79,$3B,$65,
          $32,$FA,$FA,$D9,$4B,$81,$60,$82,
          $F0,$11,$3A,$3E,$A2,$F6,$36,$08,
          $AB,$40,$43,$7E,$CC,$0F,$02,$29,
          $CB,$8F,$A2,$24,$DC,$F1,$C4,$78,
          $A6,$7D,$9B,$64,$16,$2B,$92,$D1
         ),
         (
          $15,$F5,$34,$EF,$FF,$71,$05,$CD,
          $1C,$25,$4D,$07,$4E,$27,$D5,$89,
          $8B,$89,$31,$3B,$7D,$36,$6D,$C2,
          $D7,$D8,$71,$13,$FA,$7D,$53,$AA,
          $E1,$3F,$6D,$BA,$48,$7A,$D8,$10,
          $3D,$5E,$85,$4C,$91,$FD,$B6,$E1,
          $E7,$4B,$2E,$F6,$D1,$43,$17,$69,
          $C3,$07,$67,$DD,$E0,$67,$A3,$5C
         ),
         (
          $89,$AC,$BC,$A0,$B1,$69,$89,$7A,
          $0A,$27,$14,$C2,$DF,$8C,$95,$B5,
          $B7,$9C,$B6,$93,$90,$14,$2B,$7D,
          $60,$18,$BB,$3E,$30,$76,$B0,$99,
          $B7,$9A,$96,$41,$52,$A9,$D9,$12,
          $B1,$B8,$64,$12,$B7,$E3,$72,$E9,
          $CE,$CA,$D7,$F2,$5D,$4C,$BA,$B8,
          $A3,$17,$BE,$36,$49,$2A,$67,$D7
         ),
         (
          $E3,$C0,$73,$91,$90,$ED,$84,$9C,
          $9C,$96,$2F,$D9,$DB,$B5,$5E,$20,
          $7E,$62,$4F,$CA,$C1,$EB,$41,$76,
          $91,$51,$54,$99,$EE,$A8,$D8,$26,
          $7B,$7E,$8F,$12,$87,$A6,$36,$33,
          $AF,$50,$11,$FD,$E8,$C4,$DD,$F5,
          $5B,$FD,$F7,$22,$ED,$F8,$88,$31,
          $41,$4F,$2C,$FA,$ED,$59,$CB,$9A
         ),
         (
          $8D,$6C,$F8,$7C,$08,$38,$0D,$2D,
          $15,$06,$EE,$E4,$6F,$D4,$22,$2D,
          $21,$D8,$C0,$4E,$58,$5F,$BF,$D0,
          $82,$69,$C9,$8F,$70,$28,$33,$A1,
          $56,$32,$6A,$07,$24,$65,$64,$00,
          $EE,$09,$35,$1D,$57,$B4,$40,$17,
          $5E,$2A,$5D,$E9,$3C,$C5,$F8,$0D,
          $B6,$DA,$F8,$35,$76,$CF,$75,$FA
         ),
         (
          $DA,$24,$BE,$DE,$38,$36,$66,$D5,
          $63,$EE,$ED,$37,$F6,$31,$9B,$AF,
          $20,$D5,$C7,$5D,$16,$35,$A6,$BA,
          $5E,$F4,$CF,$A1,$AC,$95,$48,$7E,
          $96,$F8,$C0,$8A,$F6,$00,$AA,$B8,
          $7C,$98,$6E,$BA,$D4,$9F,$C7,$0A,
          $58,$B4,$89,$0B,$9C,$87,$6E,$09,
          $10,$16,$DA,$F4,$9E,$1D,$32,$2E
         ),
         (
          $F9,$D1,$D1,$B1,$E8,$7E,$A7,$AE,
          $75,$3A,$02,$97,$50,$CC,$1C,$F3,
          $D0,$15,$7D,$41,$80,$5E,$24,$5C,
          $56,$17,$BB,$93,$4E,$73,$2F,$0A,
          $E3,$18,$0B,$78,$E0,$5B,$FE,$76,
          $C7,$C3,$05,$1E,$3E,$3A,$C7,$8B,
          $9B,$50,$C0,$51,$42,$65,$7E,$1E,
          $03,$21,$5D,$6E,$C7,$BF,$D0,$FC
         ),
         (
          $11,$B7,$BC,$16,$68,$03,$20,$48,
          $AA,$43,$34,$3D,$E4,$76,$39,$5E,
          $81,$4B,$BB,$C2,$23,$67,$8D,$B9,
          $51,$A1,$B0,$3A,$02,$1E,$FA,$C9,
          $48,$CF,$BE,$21,$5F,$97,$FE,$9A,
          $72,$A2,$F6,$BC,$03,$9E,$39,$56,
          $BF,$A4,$17,$C1,$A9,$F1,$0D,$6D,
          $7B,$A5,$D3,$D3,$2F,$F3,$23,$E5
         ),
         (
          $B8,$D9,$00,$0E,$4F,$C2,$B0,$66,
          $ED,$B9,$1A,$FE,$E8,$E7,$EB,$0F,
          $24,$E3,$A2,$01,$DB,$8B,$67,$93,
          $C0,$60,$85,$81,$E6,$28,$ED,$0B,
          $CC,$4E,$5A,$A6,$78,$79,$92,$A4,
          $BC,$C4,$4E,$28,$80,$93,$E6,$3E,
          $E8,$3A,$BD,$0B,$C3,$EC,$6D,$09,
          $34,$A6,$74,$A4,$DA,$13,$83,$8A
         ),
         (
          $CE,$32,$5E,$29,$4F,$9B,$67,$19,
          $D6,$B6,$12,$78,$27,$6A,$E0,$6A,
          $25,$64,$C0,$3B,$B0,$B7,$83,$FA,
          $FE,$78,$5B,$DF,$89,$C7,$D5,$AC,
          $D8,$3E,$78,$75,$6D,$30,$1B,$44,
          $56,$99,$02,$4E,$AE,$B7,$7B,$54,
          $D4,$77,$33,$6E,$C2,$A4,$F3,$32,
          $F2,$B3,$F8,$87,$65,$DD,$B0,$C3
         ),
         (
          $29,$AC,$C3,$0E,$96,$03,$AE,$2F,
          $CC,$F9,$0B,$F9,$7E,$6C,$C4,$63,
          $EB,$E2,$8C,$1B,$2F,$9B,$4B,$76,
          $5E,$70,$53,$7C,$25,$C7,$02,$A2,
          $9D,$CB,$FB,$F1,$4C,$99,$C5,$43,
          $45,$BA,$2B,$51,$F1,$7B,$77,$B5,
          $F1,$5D,$B9,$2B,$BA,$D8,$FA,$95,
          $C4,$71,$F5,$D0,$70,$A1,$37,$CC
         ),
         (
          $33,$79,$CB,$AA,$E5,$62,$A8,$7B,
          $4C,$04,$25,$55,$0F,$FD,$D6,$BF,
          $E1,$20,$3F,$0D,$66,$6C,$C7,$EA,
          $09,$5B,$E4,$07,$A5,$DF,$E6,$1E,
          $E9,$14,$41,$CD,$51,$54,$B3,$E5,
          $3B,$4F,$5F,$B3,$1A,$D4,$C7,$A9,
          $AD,$5C,$7A,$F4,$AE,$67,$9A,$A5,
          $1A,$54,$00,$3A,$54,$CA,$6B,$2D
         ),
         (
          $30,$95,$A3,$49,$D2,$45,$70,$8C,
          $7C,$F5,$50,$11,$87,$03,$D7,$30,
          $2C,$27,$B6,$0A,$F5,$D4,$E6,$7F,
          $C9,$78,$F8,$A4,$E6,$09,$53,$C7,
          $A0,$4F,$92,$FC,$F4,$1A,$EE,$64,
          $32,$1C,$CB,$70,$7A,$89,$58,$51,
          $55,$2B,$1E,$37,$B0,$0B,$C5,$E6,
          $B7,$2F,$A5,$BC,$EF,$9E,$3F,$FF
         ),
         (
          $07,$26,$2D,$73,$8B,$09,$32,$1F,
          $4D,$BC,$CE,$C4,$BB,$26,$F4,$8C,
          $B0,$F0,$ED,$24,$6C,$E0,$B3,$1B,
          $9A,$6E,$7B,$C6,$83,$04,$9F,$1F,
          $3E,$55,$45,$F2,$8C,$E9,$32,$DD,
          $98,$5C,$5A,$B0,$F4,$3B,$D6,$DE,
          $07,$70,$56,$0A,$F3,$29,$06,$5E,
          $D2,$E4,$9D,$34,$62,$4C,$2C,$BB
         ),
         (
          $B6,$40,$5E,$CA,$8E,$E3,$31,$6C,
          $87,$06,$1C,$C6,$EC,$18,$DB,$A5,
          $3E,$6C,$25,$0C,$63,$BA,$1F,$3B,
          $AE,$9E,$55,$DD,$34,$98,$03,$6A,
          $F0,$8C,$D2,$72,$AA,$24,$D7,$13,
          $C6,$02,$0D,$77,$AB,$2F,$39,$19,
          $AF,$1A,$32,$F3,$07,$42,$06,$18,
          $AB,$97,$E7,$39,$53,$99,$4F,$B4
         ),
         (
          $7E,$E6,$82,$F6,$31,$48,$EE,$45,
          $F6,$E5,$31,$5D,$A8,$1E,$5C,$6E,
          $55,$7C,$2C,$34,$64,$1F,$C5,$09,
          $C7,$A5,$70,$10,$88,$C3,$8A,$74,
          $75,$61,$68,$E2,$CD,$8D,$35,$1E,
          $88,$FD,$1A,$45,$1F,$36,$0A,$01,
          $F5,$B2,$58,$0F,$9B,$5A,$2E,$8C,
          $FC,$13,$8F,$3D,$D5,$9A,$3F,$FC
         ),
         (
          $1D,$26,$3C,$17,$9D,$6B,$26,$8F,
          $6F,$A0,$16,$F3,$A4,$F2,$9E,$94,
          $38,$91,$12,$5E,$D8,$59,$3C,$81,
          $25,$60,$59,$F5,$A7,$B4,$4A,$F2,
          $DC,$B2,$03,$0D,$17,$5C,$00,$E6,
          $2E,$CA,$F7,$EE,$96,$68,$2A,$A0,
          $7A,$B2,$0A,$61,$10,$24,$A2,$85,
          $32,$B1,$C2,$5B,$86,$65,$79,$02
         ),
         (
          $10,$6D,$13,$2C,$BD,$B4,$CD,$25,
          $97,$81,$28,$46,$E2,$BC,$1B,$F7,
          $32,$FE,$C5,$F0,$A5,$F6,$5D,$BB,
          $39,$EC,$4E,$6D,$C6,$4A,$B2,$CE,
          $6D,$24,$63,$0D,$0F,$15,$A8,$05,
          $C3,$54,$00,$25,$D8,$4A,$FA,$98,
          $E3,$67,$03,$C3,$DB,$EE,$71,$3E,
          $72,$DD,$E8,$46,$5B,$C1,$BE,$7E
         ),
         (
          $0E,$79,$96,$82,$26,$65,$06,$67,
          $A8,$D8,$62,$EA,$8D,$A4,$89,$1A,
          $F5,$6A,$4E,$3A,$8B,$6D,$17,$50,
          $E3,$94,$F0,$DE,$A7,$6D,$64,$0D,
          $85,$07,$7B,$CE,$C2,$CC,$86,$88,
          $6E,$50,$67,$51,$B4,$F6,$A5,$83,
          $8F,$7F,$0B,$5F,$EF,$76,$5D,$9D,
          $C9,$0D,$CD,$CB,$AF,$07,$9F,$08
         ),
         (
          $52,$11,$56,$A8,$2A,$B0,$C4,$E5,
          $66,$E5,$84,$4D,$5E,$31,$AD,$9A,
          $AF,$14,$4B,$BD,$5A,$46,$4F,$DC,
          $A3,$4D,$BD,$57,$17,$E8,$FF,$71,
          $1D,$3F,$FE,$BB,$FA,$08,$5D,$67,
          $FE,$99,$6A,$34,$F6,$D3,$E4,$E6,
          $0B,$13,$96,$BF,$4B,$16,$10,$C2,
          $63,$BD,$BB,$83,$4D,$56,$08,$16
         ),
         (
          $1A,$BA,$88,$BE,$FC,$55,$BC,$25,
          $EF,$BC,$E0,$2D,$B8,$B9,$93,$3E,
          $46,$F5,$76,$61,$BA,$EA,$BE,$B2,
          $1C,$C2,$57,$4D,$2A,$51,$8A,$3C,
          $BA,$5D,$C5,$A3,$8E,$49,$71,$34,
          $40,$B2,$5F,$9C,$74,$4E,$75,$F6,
          $B8,$5C,$9D,$8F,$46,$81,$F6,$76,
          $16,$0F,$61,$05,$35,$7B,$84,$06
         ),
         (
          $5A,$99,$49,$FC,$B2,$C4,$73,$CD,
          $A9,$68,$AC,$1B,$5D,$08,$56,$6D,
          $C2,$D8,$16,$D9,$60,$F5,$7E,$63,
          $B8,$98,$FA,$70,$1C,$F8,$EB,$D3,
          $F5,$9B,$12,$4D,$95,$BF,$BB,$ED,
          $C5,$F1,$CF,$0E,$17,$D5,$EA,$ED,
          $0C,$02,$C5,$0B,$69,$D8,$A4,$02,
          $CA,$BC,$CA,$44,$33,$B5,$1F,$D4
         ),
         (
          $B0,$CE,$AD,$09,$80,$7C,$67,$2A,
          $F2,$EB,$2B,$0F,$06,$DD,$E4,$6C,
          $F5,$37,$0E,$15,$A4,$09,$6B,$1A,
          $7D,$7C,$BB,$36,$EC,$31,$C2,$05,
          $FB,$EF,$CA,$00,$B7,$A4,$16,$2F,
          $A8,$9F,$B4,$FB,$3E,$B7,$8D,$79,
          $77,$0C,$23,$F4,$4E,$72,$06,$66,
          $4C,$E3,$CD,$93,$1C,$29,$1E,$5D
         ),
         (
          $BB,$66,$64,$93,$1E,$C9,$70,$44,
          $E4,$5B,$2A,$E4,$20,$AE,$1C,$55,
          $1A,$88,$74,$BC,$93,$7D,$08,$E9,
          $69,$39,$9C,$39,$64,$EB,$DB,$A8,
          $34,$6C,$DD,$5D,$09,$CA,$AF,$E4,
          $C2,$8B,$A7,$EC,$78,$81,$91,$CE,
          $CA,$65,$DD,$D6,$F9,$5F,$18,$58,
          $3E,$04,$0D,$0F,$30,$D0,$36,$4D
         ),
         (
          $65,$BC,$77,$0A,$5F,$AA,$37,$92,
          $36,$98,$03,$68,$3E,$84,$4B,$0B,
          $E7,$EE,$96,$F2,$9F,$6D,$6A,$35,
          $56,$80,$06,$BD,$55,$90,$F9,$A4,
          $EF,$63,$9B,$7A,$80,$61,$C7,$B0,
          $42,$4B,$66,$B6,$0A,$C3,$4A,$F3,
          $11,$99,$05,$F3,$3A,$9D,$8C,$3A,
          $E1,$83,$82,$CA,$9B,$68,$99,$00
         ),
         (
          $EA,$9B,$4D,$CA,$33,$33,$36,$AA,
          $F8,$39,$A4,$5C,$6E,$AA,$48,$B8,
          $CB,$4C,$7D,$DA,$BF,$FE,$A4,$F6,
          $43,$D6,$35,$7E,$A6,$62,$8A,$48,
          $0A,$5B,$45,$F2,$B0,$52,$C1,$B0,
          $7D,$1F,$ED,$CA,$91,$8B,$6F,$11,
          $39,$D8,$0F,$74,$C2,$45,$10,$DC,
          $BA,$A4,$BE,$70,$EA,$CC,$1B,$06
         ),
         (
          $E6,$34,$2F,$B4,$A7,$80,$AD,$97,
          $5D,$0E,$24,$BC,$E1,$49,$98,$9B,
          $91,$D3,$60,$55,$7E,$87,$99,$4F,
          $6B,$45,$7B,$89,$55,$75,$CC,$02,
          $D0,$C1,$5B,$AD,$3C,$E7,$57,$7F,
          $4C,$63,$92,$7F,$F1,$3F,$3E,$38,
          $1F,$F7,$E7,$2B,$DB,$E7,$45,$32,
          $48,$44,$A9,$D2,$7E,$3F,$1C,$01
         ),
         (
          $3E,$20,$9C,$9B,$33,$E8,$E4,$61,
          $17,$8A,$B4,$6B,$1C,$64,$B4,$9A,
          $07,$FB,$74,$5F,$1C,$8B,$C9,$5F,
          $BF,$B9,$4C,$6B,$87,$C6,$95,$16,
          $65,$1B,$26,$4E,$F9,$80,$93,$7F,
          $AD,$41,$23,$8B,$91,$DD,$C0,$11,
          $A5,$DD,$77,$7C,$7E,$FD,$44,$94,
          $B4,$B6,$EC,$D3,$A9,$C2,$2A,$C0
         ),
         (
          $FD,$6A,$3D,$5B,$18,$75,$D8,$04,
          $86,$D6,$E6,$96,$94,$A5,$6D,$BB,
          $04,$A9,$9A,$4D,$05,$1F,$15,$DB,
          $26,$89,$77,$6B,$A1,$C4,$88,$2E,
          $6D,$46,$2A,$60,$3B,$70,$15,$DC,
          $9F,$4B,$74,$50,$F0,$53,$94,$30,
          $3B,$86,$52,$CF,$B4,$04,$A2,$66,
          $96,$2C,$41,$BA,$E6,$E1,$8A,$94
         ),
         (
          $95,$1E,$27,$51,$7E,$6B,$AD,$9E,
          $41,$95,$FC,$86,$71,$DE,$E3,$E7,
          $E9,$BE,$69,$CE,$E1,$42,$2C,$B9,
          $FE,$CF,$CE,$0D,$BA,$87,$5F,$7B,
          $31,$0B,$93,$EE,$3A,$3D,$55,$8F,
          $94,$1F,$63,$5F,$66,$8F,$F8,$32,
          $D2,$C1,$D0,$33,$C5,$E2,$F0,$99,
          $7E,$4C,$66,$F1,$47,$34,$4E,$02
         ),
         (
          $8E,$BA,$2F,$87,$4F,$1A,$E8,$40,
          $41,$90,$3C,$7C,$42,$53,$C8,$22,
          $92,$53,$0F,$C8,$50,$95,$50,$BF,
          $DC,$34,$C9,$5C,$7E,$28,$89,$D5,
          $65,$0B,$0A,$D8,$CB,$98,$8E,$5C,
          $48,$94,$CB,$87,$FB,$FB,$B1,$96,
          $12,$EA,$93,$CC,$C4,$C5,$CA,$D1,
          $71,$58,$B9,$76,$34,$64,$B4,$92
         ),
         (
          $16,$F7,$12,$EA,$A1,$B7,$C6,$35,
          $47,$19,$A8,$E7,$DB,$DF,$AF,$55,
          $E4,$06,$3A,$4D,$27,$7D,$94,$75,
          $50,$01,$9B,$38,$DF,$B5,$64,$83,
          $09,$11,$05,$7D,$50,$50,$61,$36,
          $E2,$39,$4C,$3B,$28,$94,$5C,$C9,
          $64,$96,$7D,$54,$E3,$00,$0C,$21,
          $81,$62,$6C,$FB,$9B,$73,$EF,$D2
         ),
         (
          $C3,$96,$39,$E7,$D5,$C7,$FB,$8C,
          $DD,$0F,$D3,$E6,$A5,$20,$96,$03,
          $94,$37,$12,$2F,$21,$C7,$8F,$16,
          $79,$CE,$A9,$D7,$8A,$73,$4C,$56,
          $EC,$BE,$B2,$86,$54,$B4,$F1,$8E,
          $34,$2C,$33,$1F,$6F,$72,$29,$EC,
          $4B,$4B,$C2,$81,$B2,$D8,$0A,$6E,
          $B5,$00,$43,$F3,$17,$96,$C8,$8C
         ),
         (
          $72,$D0,$81,$AF,$99,$F8,$A1,$73,
          $DC,$C9,$A0,$AC,$4E,$B3,$55,$74,
          $05,$63,$9A,$29,$08,$4B,$54,$A4,
          $01,$72,$91,$2A,$2F,$8A,$39,$51,
          $29,$D5,$53,$6F,$09,$18,$E9,$02,
          $F9,$E8,$FA,$60,$00,$99,$5F,$41,
          $68,$DD,$C5,$F8,$93,$01,$1B,$E6,
          $A0,$DB,$C9,$B8,$A1,$A3,$F5,$BB
         ),
         (
          $C1,$1A,$A8,$1E,$5E,$FD,$24,$D5,
          $FC,$27,$EE,$58,$6C,$FD,$88,$47,
          $FB,$B0,$E2,$76,$01,$CC,$EC,$E5,
          $EC,$CA,$01,$98,$E3,$C7,$76,$53,
          $93,$BB,$74,$45,$7C,$7E,$7A,$27,
          $EB,$91,$70,$35,$0E,$1F,$B5,$38,
          $57,$17,$75,$06,$BE,$3E,$76,$2C,
          $C0,$F1,$4D,$8C,$3A,$FE,$90,$77
         ),
         (
          $C2,$8F,$21,$50,$B4,$52,$E6,$C0,
          $C4,$24,$BC,$DE,$6F,$8D,$72,$00,
          $7F,$93,$10,$FE,$D7,$F2,$F8,$7D,
          $E0,$DB,$B6,$4F,$44,$79,$D6,$C1,
          $44,$1B,$A6,$6F,$44,$B2,$AC,$CE,
          $E6,$16,$09,$17,$7E,$D3,$40,$12,
          $8B,$40,$7E,$CE,$C7,$C6,$4B,$BE,
          $50,$D6,$3D,$22,$D8,$62,$77,$27
         ),
         (
          $F6,$3D,$88,$12,$28,$77,$EC,$30,
          $B8,$C8,$B0,$0D,$22,$E8,$90,$00,
          $A9,$66,$42,$61,$12,$BD,$44,$16,
          $6E,$2F,$52,$5B,$76,$9C,$CB,$E9,
          $B2,$86,$D4,$37,$A0,$12,$91,$30,
          $DD,$E1,$A8,$6C,$43,$E0,$4B,$ED,
          $B5,$94,$E6,$71,$D9,$82,$83,$AF,
          $E6,$4C,$E3,$31,$DE,$98,$28,$FD
         ),
         (
          $34,$8B,$05,$32,$88,$0B,$88,$A6,
          $61,$4A,$8D,$74,$08,$C3,$F9,$13,
          $35,$7F,$BB,$60,$E9,$95,$C6,$02,
          $05,$BE,$91,$39,$E7,$49,$98,$AE,
          $DE,$7F,$45,$81,$E4,$2F,$6B,$52,
          $69,$8F,$7F,$A1,$21,$97,$08,$C1,
          $44,$98,$06,$7F,$D1,$E0,$95,$02,
          $DE,$83,$A7,$7D,$D2,$81,$15,$0C
         ),
         (
          $51,$33,$DC,$8B,$EF,$72,$53,$59,
          $DF,$F5,$97,$92,$D8,$5E,$AF,$75,
          $B7,$E1,$DC,$D1,$97,$8B,$01,$C3,
          $5B,$1B,$85,$FC,$EB,$C6,$33,$88,
          $AD,$99,$A1,$7B,$63,$46,$A2,$17,
          $DC,$1A,$96,$22,$EB,$D1,$22,$EC,
          $F6,$91,$3C,$4D,$31,$A6,$B5,$2A,
          $69,$5B,$86,$AF,$00,$D7,$41,$A0
         ),
         (
          $27,$53,$C4,$C0,$E9,$8E,$CA,$D8,
          $06,$E8,$87,$80,$EC,$27,$FC,$CD,
          $0F,$5C,$1A,$B5,$47,$F9,$E4,$BF,
          $16,$59,$D1,$92,$C2,$3A,$A2,$CC,
          $97,$1B,$58,$B6,$80,$25,$80,$BA,
          $EF,$8A,$DC,$3B,$77,$6E,$F7,$08,
          $6B,$25,$45,$C2,$98,$7F,$34,$8E,
          $E3,$71,$9C,$DE,$F2,$58,$C4,$03
         ),
         (
          $B1,$66,$35,$73,$CE,$4B,$9D,$8C,
          $AE,$FC,$86,$50,$12,$F3,$E3,$97,
          $14,$B9,$89,$8A,$5D,$A6,$CE,$17,
          $C2,$5A,$6A,$47,$93,$1A,$9D,$DB,
          $9B,$BE,$98,$AD,$AA,$55,$3B,$EE,
          $D4,$36,$E8,$95,$78,$45,$54,$16,
          $C2,$A5,$2A,$52,$5C,$F2,$86,$2B,
          $8D,$1D,$49,$A2,$53,$1B,$73,$91
         ),
         (
          $64,$F5,$8B,$D6,$BF,$C8,$56,$F5,
          $E8,$73,$B2,$A2,$95,$6E,$A0,$ED,
          $A0,$D6,$DB,$0D,$A3,$9C,$8C,$7F,
          $C6,$7C,$9F,$9F,$EE,$FC,$FF,$30,
          $72,$CD,$F9,$E6,$EA,$37,$F6,$9A,
          $44,$F0,$C6,$1A,$A0,$DA,$36,$93,
          $C2,$DB,$5B,$54,$96,$0C,$02,$81,
          $A0,$88,$15,$1D,$B4,$2B,$11,$E8
         ),
         (
          $07,$64,$C7,$BE,$28,$12,$5D,$90,
          $65,$C4,$B9,$8A,$69,$D6,$0A,$ED,
          $E7,$03,$54,$7C,$66,$A1,$2E,$17,
          $E1,$C6,$18,$99,$41,$32,$F5,$EF,
          $82,$48,$2C,$1E,$3F,$E3,$14,$6C,
          $C6,$53,$76,$CC,$10,$9F,$01,$38,
          $ED,$9A,$80,$E4,$9F,$1F,$3C,$7D,
          $61,$0D,$2F,$24,$32,$F2,$06,$05
         ),
         (
          $F7,$48,$78,$43,$98,$A2,$FF,$03,
          $EB,$EB,$07,$E1,$55,$E6,$61,$16,
          $A8,$39,$74,$1A,$33,$6E,$32,$DA,
          $71,$EC,$69,$60,$01,$F0,$AD,$1B,
          $25,$CD,$48,$C6,$9C,$FC,$A7,$26,
          $5E,$CA,$1D,$D7,$19,$04,$A0,$CE,
          $74,$8A,$C4,$12,$4F,$35,$71,$07,
          $6D,$FA,$71,$16,$A9,$CF,$00,$E9
         ),
         (
          $3F,$0D,$BC,$01,$86,$BC,$EB,$6B,
          $78,$5B,$A7,$8D,$2A,$2A,$01,$3C,
          $91,$0B,$E1,$57,$BD,$AF,$FA,$E8,
          $1B,$B6,$66,$3B,$1A,$73,$72,$2F,
          $7F,$12,$28,$79,$5F,$3E,$CA,$DA,
          $87,$CF,$6E,$F0,$07,$84,$74,$AF,
          $73,$F3,$1E,$CA,$0C,$C2,$00,$ED,
          $97,$5B,$68,$93,$F7,$61,$CB,$6D
         ),
         (
          $D4,$76,$2C,$D4,$59,$98,$76,$CA,
          $75,$B2,$B8,$FE,$24,$99,$44,$DB,
          $D2,$7A,$CE,$74,$1F,$DA,$B9,$36,
          $16,$CB,$C6,$E4,$25,$46,$0F,$EB,
          $51,$D4,$E7,$AD,$CC,$38,$18,$0E,
          $7F,$C4,$7C,$89,$02,$4A,$7F,$56,
          $19,$1A,$DB,$87,$8D,$FD,$E4,$EA,
          $D6,$22,$23,$F5,$A2,$61,$0E,$FE
         ),
         (
          $CD,$36,$B3,$D5,$B4,$C9,$1B,$90,
          $FC,$BB,$A7,$95,$13,$CF,$EE,$19,
          $07,$D8,$64,$5A,$16,$2A,$FD,$0C,
          $D4,$CF,$41,$92,$D4,$A5,$F4,$C8,
          $92,$18,$3A,$8E,$AC,$DB,$2B,$6B,
          $6A,$9D,$9A,$A8,$C1,$1A,$C1,$B2,
          $61,$B3,$80,$DB,$EE,$24,$CA,$46,
          $8F,$1B,$FD,$04,$3C,$58,$EE,$FE
         ),
         (
          $98,$59,$34,$52,$28,$16,$61,$A5,
          $3C,$48,$A9,$D8,$CD,$79,$08,$26,
          $C1,$A1,$CE,$56,$77,$38,$05,$3D,
          $0B,$EE,$4A,$91,$A3,$D5,$BD,$92,
          $EE,$FD,$BA,$BE,$BE,$32,$04,$F2,
          $03,$1C,$A5,$F7,$81,$BD,$A9,$9E,
          $F5,$D8,$AE,$56,$E5,$B0,$4A,$9E,
          $1E,$CD,$21,$B0,$EB,$05,$D3,$E1
         ),
         (
          $77,$1F,$57,$DD,$27,$75,$CC,$DA,
          $B5,$59,$21,$D3,$E8,$E3,$0C,$CF,
          $48,$4D,$61,$FE,$1C,$1B,$9C,$2A,
          $E8,$19,$D0,$FB,$2A,$12,$FA,$B9,
          $BE,$70,$C4,$A7,$A1,$38,$DA,$84,
          $E8,$28,$04,$35,$DA,$AD,$E5,$BB,
          $E6,$6A,$F0,$83,$6A,$15,$4F,$81,
          $7F,$B1,$7F,$33,$97,$E7,$25,$A3
         ),
         (
          $C6,$08,$97,$C6,$F8,$28,$E2,$1F,
          $16,$FB,$B5,$F1,$5B,$32,$3F,$87,
          $B6,$C8,$95,$5E,$AB,$F1,$D3,$80,
          $61,$F7,$07,$F6,$08,$AB,$DD,$99,
          $3F,$AC,$30,$70,$63,$3E,$28,$6C,
          $F8,$33,$9C,$E2,$95,$DD,$35,$2D,
          $F4,$B4,$B4,$0B,$2F,$29,$DA,$1D,
          $D5,$0B,$3A,$05,$D0,$79,$E6,$BB
         ),
         (
          $82,$10,$CD,$2C,$2D,$3B,$13,$5C,
          $2C,$F0,$7F,$A0,$D1,$43,$3C,$D7,
          $71,$F3,$25,$D0,$75,$C6,$46,$9D,
          $9C,$7F,$1B,$A0,$94,$3C,$D4,$AB,
          $09,$80,$8C,$AB,$F4,$AC,$B9,$CE,
          $5B,$B8,$8B,$49,$89,$29,$B4,$B8,
          $47,$F6,$81,$AD,$2C,$49,$0D,$04,
          $2D,$B2,$AE,$C9,$42,$14,$B0,$6B
         ),
         (
          $1D,$4E,$DF,$FF,$D8,$FD,$80,$F7,
          $E4,$10,$78,$40,$FA,$3A,$A3,$1E,
          $32,$59,$84,$91,$E4,$AF,$70,$13,
          $C1,$97,$A6,$5B,$7F,$36,$DD,$3A,
          $C4,$B4,$78,$45,$61,$11,$CD,$43,
          $09,$D9,$24,$35,$10,$78,$2F,$A3,
          $1B,$7C,$4C,$95,$FA,$95,$15,$20,
          $D0,$20,$EB,$7E,$5C,$36,$E4,$EF
         ),
         (
          $AF,$8E,$6E,$91,$FA,$B4,$6C,$E4,
          $87,$3E,$1A,$50,$A8,$EF,$44,$8C,
          $C2,$91,$21,$F7,$F7,$4D,$EE,$F3,
          $4A,$71,$EF,$89,$CC,$00,$D9,$27,
          $4B,$C6,$C2,$45,$4B,$BB,$32,$30,
          $D8,$B2,$EC,$94,$C6,$2B,$1D,$EC,
          $85,$F3,$59,$3B,$FA,$30,$EA,$6F,
          $7A,$44,$D7,$C0,$94,$65,$A2,$53
         ),
         (
          $29,$FD,$38,$4E,$D4,$90,$6F,$2D,
          $13,$AA,$9F,$E7,$AF,$90,$59,$90,
          $93,$8B,$ED,$80,$7F,$18,$32,$45,
          $4A,$37,$2A,$B4,$12,$EE,$A1,$F5,
          $62,$5A,$1F,$CC,$9A,$C8,$34,$3B,
          $7C,$67,$C5,$AB,$A6,$E0,$B1,$CC,
          $46,$44,$65,$49,$13,$69,$2C,$6B,
          $39,$EB,$91,$87,$CE,$AC,$D3,$EC
         ),
         (
          $A2,$68,$C7,$88,$5D,$98,$74,$A5,
          $1C,$44,$DF,$FE,$D8,$EA,$53,$E9,
          $4F,$78,$45,$6E,$0B,$2E,$D9,$9F,
          $F5,$A3,$92,$47,$60,$81,$38,$26,
          $D9,$60,$A1,$5E,$DB,$ED,$BB,$5D,
          $E5,$22,$6B,$A4,$B0,$74,$E7,$1B,
          $05,$C5,$5B,$97,$56,$BB,$79,$E5,
          $5C,$02,$75,$4C,$2C,$7B,$6C,$8A
         ),
         (
          $0C,$F8,$54,$54,$88,$D5,$6A,$86,
          $81,$7C,$D7,$EC,$B1,$0F,$71,$16,
          $B7,$EA,$53,$0A,$45,$B6,$EA,$49,
          $7B,$6C,$72,$C9,$97,$E0,$9E,$3D,
          $0D,$A8,$69,$8F,$46,$BB,$00,$6F,
          $C9,$77,$C2,$CD,$3D,$11,$77,$46,
          $3A,$C9,$05,$7F,$DD,$16,$62,$C8,
          $5D,$0C,$12,$64,$43,$C1,$04,$73
         ),
         (
          $B3,$96,$14,$26,$8F,$DD,$87,$81,
          $51,$5E,$2C,$FE,$BF,$89,$B4,$D5,
          $40,$2B,$AB,$10,$C2,$26,$E6,$34,
          $4E,$6B,$9A,$E0,$00,$FB,$0D,$6C,
          $79,$CB,$2F,$3E,$C8,$0E,$80,$EA,
          $EB,$19,$80,$D2,$F8,$69,$89,$16,
          $BD,$2E,$9F,$74,$72,$36,$65,$51,
          $16,$64,$9C,$D3,$CA,$23,$A8,$37
         ),
         (
          $74,$BE,$F0,$92,$FC,$6F,$1E,$5D,
          $BA,$36,$63,$A3,$FB,$00,$3B,$2A,
          $5B,$A2,$57,$49,$65,$36,$D9,$9F,
          $62,$B9,$D7,$3F,$8F,$9E,$B3,$CE,
          $9F,$F3,$EE,$C7,$09,$EB,$88,$36,
          $55,$EC,$9E,$B8,$96,$B9,$12,$8F,
          $2A,$FC,$89,$CF,$7D,$1A,$B5,$8A,
          $72,$F4,$A3,$BF,$03,$4D,$2B,$4A
         ),
         (
          $3A,$98,$8D,$38,$D7,$56,$11,$F3,
          $EF,$38,$B8,$77,$49,$80,$B3,$3E,
          $57,$3B,$6C,$57,$BE,$E0,$46,$9B,
          $A5,$EE,$D9,$B4,$4F,$29,$94,$5E,
          $73,$47,$96,$7F,$BA,$2C,$16,$2E,
          $1C,$3B,$E7,$F3,$10,$F2,$F7,$5E,
          $E2,$38,$1E,$7B,$FD,$6B,$3F,$0B,
          $AE,$A8,$D9,$5D,$FB,$1D,$AF,$B1
         ),
         (
          $58,$AE,$DF,$CE,$6F,$67,$DD,$C8,
          $5A,$28,$C9,$92,$F1,$C0,$BD,$09,
          $69,$F0,$41,$E6,$6F,$1E,$E8,$80,
          $20,$A1,$25,$CB,$FC,$FE,$BC,$D6,
          $17,$09,$C9,$C4,$EB,$A1,$92,$C1,
          $5E,$69,$F0,$20,$D4,$62,$48,$60,
          $19,$FA,$8D,$EA,$0C,$D7,$A4,$29,
          $21,$A1,$9D,$2F,$E5,$46,$D4,$3D
         ),
         (
          $93,$47,$BD,$29,$14,$73,$E6,$B4,
          $E3,$68,$43,$7B,$8E,$56,$1E,$06,
          $5F,$64,$9A,$6D,$8A,$DA,$47,$9A,
          $D0,$9B,$19,$99,$A8,$F2,$6B,$91,
          $CF,$61,$20,$FD,$3B,$FE,$01,$4E,
          $83,$F2,$3A,$CF,$A4,$C0,$AD,$7B,
          $37,$12,$B2,$C3,$C0,$73,$32,$70,
          $66,$31,$12,$CC,$D9,$28,$5C,$D9
         ),
         (
          $B3,$21,$63,$E7,$C5,$DB,$B5,$F5,
          $1F,$DC,$11,$D2,$EA,$C8,$75,$EF,
          $BB,$CB,$7E,$76,$99,$09,$0A,$7E,
          $7F,$F8,$A8,$D5,$07,$95,$AF,$5D,
          $74,$D9,$FF,$98,$54,$3E,$F8,$CD,
          $F8,$9A,$C1,$3D,$04,$85,$27,$87,
          $56,$E0,$EF,$00,$C8,$17,$74,$56,
          $61,$E1,$D5,$9F,$E3,$8E,$75,$37
         ),
         (
          $10,$85,$D7,$83,$07,$B1,$C4,$B0,
          $08,$C5,$7A,$2E,$7E,$5B,$23,$46,
          $58,$A0,$A8,$2E,$4F,$F1,$E4,$AA,
          $AC,$72,$B3,$12,$FD,$A0,$FE,$27,
          $D2,$33,$BC,$5B,$10,$E9,$CC,$17,
          $FD,$C7,$69,$7B,$54,$0C,$7D,$95,
          $EB,$21,$5A,$19,$A1,$A0,$E2,$0E,
          $1A,$BF,$A1,$26,$EF,$D5,$68,$C7
         ),
         (
          $4E,$5C,$73,$4C,$7D,$DE,$01,$1D,
          $83,$EA,$C2,$B7,$34,$7B,$37,$35,
          $94,$F9,$2D,$70,$91,$B9,$CA,$34,
          $CB,$9C,$6F,$39,$BD,$F5,$A8,$D2,
          $F1,$34,$37,$9E,$16,$D8,$22,$F6,
          $52,$21,$70,$CC,$F2,$DD,$D5,$5C,
          $84,$B9,$E6,$C6,$4F,$C9,$27,$AC,
          $4C,$F8,$DF,$B2,$A1,$77,$01,$F2
         ),
         (
          $69,$5D,$83,$BD,$99,$0A,$11,$17,
          $B3,$D0,$CE,$06,$CC,$88,$80,$27,
          $D1,$2A,$05,$4C,$26,$77,$FD,$82,
          $F0,$D4,$FB,$FC,$93,$57,$55,$23,
          $E7,$99,$1A,$5E,$35,$A3,$75,$2E,
          $9B,$70,$CE,$62,$99,$2E,$26,$8A,
          $87,$77,$44,$CD,$D4,$35,$F5,$F1,
          $30,$86,$9C,$9A,$20,$74,$B3,$38
         ),
         (
          $A6,$21,$37,$43,$56,$8E,$3B,$31,
          $58,$B9,$18,$43,$01,$F3,$69,$08,
          $47,$55,$4C,$68,$45,$7C,$B4,$0F,
          $C9,$A4,$B8,$CF,$D8,$D4,$A1,$18,
          $C3,$01,$A0,$77,$37,$AE,$DA,$0F,
          $92,$9C,$68,$91,$3C,$5F,$51,$C8,
          $03,$94,$F5,$3B,$FF,$1C,$3E,$83,
          $B2,$E4,$0C,$A9,$7E,$BA,$9E,$15
         ),
         (
          $D4,$44,$BF,$A2,$36,$2A,$96,$DF,
          $21,$3D,$07,$0E,$33,$FA,$84,$1F,
          $51,$33,$4E,$4E,$76,$86,$6B,$81,
          $39,$E8,$AF,$3B,$B3,$39,$8B,$E2,
          $DF,$AD,$DC,$BC,$56,$B9,$14,$6D,
          $E9,$F6,$81,$18,$DC,$58,$29,$E7,
          $4B,$0C,$28,$D7,$71,$19,$07,$B1,
          $21,$F9,$16,$1C,$B9,$2B,$69,$A9
         ),
         (
          $14,$27,$09,$D6,$2E,$28,$FC,$CC,
          $D0,$AF,$97,$FA,$D0,$F8,$46,$5B,
          $97,$1E,$82,$20,$1D,$C5,$10,$70,
          $FA,$A0,$37,$2A,$A4,$3E,$92,$48,
          $4B,$E1,$C1,$E7,$3B,$A1,$09,$06,
          $D5,$D1,$85,$3D,$B6,$A4,$10,$6E,
          $0A,$7B,$F9,$80,$0D,$37,$3D,$6D,
          $EE,$2D,$46,$D6,$2E,$F2,$A4,$61
         )
        );
 var Index:TRNLSizeInt;
     Key:TRNLBLAKE2BKey;
     Hash:TRNLBLAKE2BHash;
     Buf:array[0..BLAKE2_KAT_LENGTH-1] of UInt8;
 begin
  for Index:=0 to TRNLBLAKE2BContext.BLAKE2B_KEYBYTES-1 do begin
   Key[Index]:=Index;
  end;
  for Index:=0 to BLAKE2_KAT_LENGTH-1 do begin
   Buf[Index]:=Index;
  end;
  for Index:=0 to BLAKE2_KAT_LENGTH-1 do begin
   write('[BLAKE2B] Testing offical vector #',Index,' ... ');
   TRNLBLAKE2B.Process(Hash,Buf,Index,TRNLBLAKE2BContext.BLAKE2B_OUTBYTES,@Key,TRNLBLAKE2BContext.BLAKE2B_KEYBYTES);
   if TRNLMemory.SecureIsEqual(Hash,BLAKB2B_KEYED_KAT[Index],SizeOf(TRNLBLAKE2BHash)) then begin
    writeln('OK!');
   end else begin
    writeln('FAILED!');
   end;
  end;
 end;
type TTestVector=record
      Data:TRNLRawByteString;
      Key:TRNLRawByteString;
      Hash:TRNLRawByteString;
     end;
     PTestVector=^TTestVector;
const TestVectors:array[0..7] of TTestVector=
       (
        (Data:'';Key:'';Hash:'786a02f742015903c6c6fd852552d272912f4740e15847618a86e217f71f5419d25e1031afee585313896444934eb04b903a685b1448b755d56f701afe9be2ce'),
        (Data:'Hallo';Key:'';Hash:'6c834952e7478042b5edc6af7f8e50cbf30938122ae60d08ff7807c2ddd71a56256ea21b4410e2ed65f314df41a5d9937bc25bf0843c4ee3922a5620de9cf417'),
        (Data:'Hello world';Key:'';Hash:'6ff843ba685842aa82031d3f53c48b66326df7639a63d128974c5c14f31a0f33343a8c65551134ed1ae0f2b0dd2bb495dc81039e3eeb0aa1bb0388bbeac29183'),
        (Data:'';Key:'test';Hash:'af007b40b85039c1ac7ca29c4a484e3a614a9fead502fdf5693733ec52d768bc8915b3700a04ae607866141eda16322c9b85b433ccc09f9abd2825c4c23b4f31'),
        (Data:'Hallo';Key:'test';Hash:'2b6641a65091fda18d2a9876cd2aec933e7bd70d2668d93c15c9b34363e09399eb6cdaafe94ceceb1d47b457d71a331b24c65ef3a9ef5283fe55d44363fcd5ba'),
        (Data:'Hello world';Key:'test';Hash:'56f5d8250e65acd4da3c3025a514219f5c65f63ef8c4298dcf1336932fe3e1f70d17c430b22d1895499003d8a9155043d4fab1a4766c3a8fbd0a87032dc8c87d'),
        (Data:'abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu';Key:'';Hash:'ce741ac5930fe346811175c5227bb7bfcd47f42612fae46c0809514f9e0e3a11ee1773287147cdeaeedff50709aa716341fe65240f4ad6777d6bfaf9726e5e52'),
        (Data:'The quick brown fox jumps over the lazy dog';Key:'';Hash:'a8add4bdddfd93e4877d2746e62817b116364a1fa7bc148d95090bc7333b3673f82401cf7aa2e4cb1ecd90296e3f14cb5413f8ed77be73045b13914cdcd6a918')
       );
var Index,DataLen,KeyLen,HashLen,HashIndex:TRNLSizeInt;
    TestVector:PTestVector;
    Hash,RefHash:TRNLBLAKE2BHash;
    Data,Key:pointer;
begin

 RFC7693Test;

 OfficalTest;

 for Index:=Low(TestVectors) to High(TestVectors) do begin
  TestVector:=@TestVectors[Index];
  DataLen:=length(TestVector^.Data);
  KeyLen:=length(TestVector^.Key);
  if DataLen>0 then begin
   Data:=@TestVector^.Data[1];
  end else begin
   Data:=nil;
  end;
  if KeyLen>0 then begin
   Key:=@TestVector^.Key[1];
  end else begin
   Key:=nil;
  end;
  HashLen:=length(TestVector^.Hash) shr 1;
  write('[BLAKE2B] Testing additional test vector #',Index,' ... ');
  FillChar(Hash,SizeOf(TRNLBLAKE2BHash),#0);
  if TRNLBLAKE2B.Process(Hash,Data^,DataLen,HashLen,Key,KeyLen) then begin
   FillChar(RefHash,SizeOf(TRNLBLAKE2BHash),#0);
   for HashIndex:=0 to HashLen-1 do begin
    RefHash[HashIndex]:=StrToInt('$'+Copy(TestVector^.Hash,(HashIndex shl 1)+1,2));
   end;
   if TRNLMemory.SecureIsEqual(Hash,RefHash,HashLen) then begin
    writeln('OK!');
   end else begin
    writeln('FAILED!');
   end;
  end else begin
   writeln('FAILED!');
  end;
 end;
end;

class procedure TRNLED25519.ModL(out aR;const aX);
const L:array[0..31] of TRNLInt64=
       (
        $ed,$d3,$f5,$5c,$1a,$63,$12,$58,
        $d6,$9c,$f7,$a2,$de,$f9,$de,$14,
        $00,$00,$00,$00,$00,$00,$00,$00,
        $00,$00,$00,$00,$00,$00,$00,$10
       );
var i,j:TRNLInt32;
    Carry:TRNLInt64;
begin
 for i:=63 downto 32 do begin
  Carry:=0;
  for j:=i-32 to i-13 do begin
   inc(PRNLInt64Array(TRNLPointer(@aX))^[j],Carry-(16*PRNLInt64Array(TRNLPointer(@aX))^[i]*L[j-(i-32)]));
   Carry:=SARInt64(PRNLInt64Array(TRNLPointer(@aX))^[j]+128,8);
   dec(PRNLInt64Array(TRNLPointer(@aX))^[j],Carry shl 8);
  end;
  inc(PRNLInt64Array(TRNLPointer(@aX))^[i-12],Carry);
  PRNLInt64Array(TRNLPointer(@aX))^[i]:=0;
 end;
 Carry:=0;
 for i:=0 to 31 do begin
  inc(PRNLInt64Array(TRNLPointer(@aX))^[i],Carry-(SARInt64(PRNLInt64Array(TRNLPointer(@aX))^[31],4)*L[i]));
  Carry:=SARInt64(PRNLInt64Array(TRNLPointer(@aX))^[i],8);
  PRNLInt64Array(TRNLPointer(@aX))^[i]:=PRNLInt64Array(TRNLPointer(@aX))^[i] and $ff;
 end;
 for i:=0 to 31 do begin
  dec(PRNLInt64Array(TRNLPointer(@aX))^[i],Carry*L[i]);
 end;
 for i:=0 to 31 do begin
  inc(PRNLInt64Array(TRNLPointer(@aX))^[i+1],SARInt64(PRNLInt64Array(TRNLPointer(@aX))^[i],8));
  PRNLUInt8Array(TRNLPointer(@aR))^[i]:=PRNLInt64Array(TRNLPointer(@aX))^[i] and $ff;
 end;
end;

class procedure TRNLED25519.Reduce(var aR);
var x:array[0..64] of TRNLInt64;
    i:TRNLInt32;
begin
 for i:=0 to 63 do begin
  x[i]:=PRNLUInt8Array(TRNLPointer(@aR))^[i];
  PRNLUInt8Array(TRNLPointer(@aR))^[i]:=0;
 end;
 ModL(aR,x);
end;

class procedure TRNLED25519.HashRAM(out aK;const aR,aA,aM;const aMSize:TRNLSizeUInt);
var HashContext:TRNLED25519HashContext;
begin
 HashContext.Initialize;
 HashContext.Update(aR,32);
 HashContext.Update(aA,32);
 HashContext.Update(aM,aMSize);
 HashContext.Finalize(aK);
 Reduce(aK);
end;

class function TRNLED25519.ScalarMultiplication(out aResult:TRNLPoint25519;const aInput:TRNLPoint25519;const aScalar:TRNLKey):boolean;
const K:TRNLValue25519=(Limbs:(54885894,25242303,55597453,9067496,51808079,33312638,25456129,14121551,54921728,3972023));
var x1,y1,z1,x2,z2,x3,z3,t1,t2,t3,t4:TRNLValue25519;
begin

 // convert input to montgomery format
 z1:=aInput.fZ-aInput.fY;
 z1:=(z1*aInput.fX).Invert;
 t1:=aInput.fZ+aInput.fY;
 x1:=aInput.fX*t1;
 x1:=x1*z1;
 y1:=aInput.fZ*t1;
 y1:=y1*z1;
 y1:=K*y1;
 z1:=1; // implied in the ladder, needed to convert back.

 // montgomery scalarmult
 TRNLCurve25519.Ladder(x1,x2,z2,x3,z3,aScalar);

 // Recover the y coordinate (Katsuyuki Okeya & Kouichi Sakurai, 2001)
 // Note the shameless reuse of x1: (x1, y1, z1) will correspond to what was originally (x2, z2).
 t1:=x1*z2;
 t2:=x2+t1;
 t3:=x2-t1;
 t3:=t3.Square;
 t3:=t3*x3;
 t1:=z2.Mul973324;
 t2:=t2+t1;
 t4:=x1*x2;
 t4:=t4+z2;
 t2:=t2*t4;
 t1:=t1*z2;
 t2:=t2-t1;
 t2:=t2*z3;
 t1:=y1+y1;
 t1:=t1*z2;
 t1:=t1*z3;
 x1:=t1*x2;
 y1:=t2-t3;
 z1:=t1*z2;

 // convert back to twisted edwards
 t1:=x1-z1;
 t2:=x1+z1;
 x1:=K*x1;
 aResult.fX:=x1*t2;
 aResult.fY:=y1*t1;
 aResult.fZ:=y1*t2;
 aResult.fT:=x1*t1;

 result:=true;

end;

class function TRNLED25519.ScalarMultiplicationBase(out aResult:TRNLPoint25519;const aScalar:TRNLKey):boolean;
const x:TRNLValue25519=(Limbs:($325d51a,$18b5823,$0f6592a,$104a92d,$1a4b31d,$1d6dc5c,$27118fe,$07fd814,$13cd6e5,$085a4db));
      y:TRNLValue25519=(Limbs:($2666658,$1999999,$0cccccc,$1333333,$1999999,$0666666,$3333333,$0cccccc,$2666666,$1999999));
begin
 result:=ScalarMultiplication(aResult,TRNLPoint25519.CreateFromXY(x,y),aScalar);
end;

class procedure TRNLED25519.DerivePublicKey(out aPublicKey;const aPrivateKey);
var a:array[0..63] of TRNLUInt8;
    b:TRNLPoint25519;
begin
 TRNLED25519Hash.Process(a,aPrivateKey,32);
 PRNLKey(TRNLPointer(@a))^:=PRNLKey(TRNLPointer(@a))^.ClampForCurve25519;
 TRNLED25519.ScalarMultiplicationBase(b,PRNLKey(TRNLPointer(@a))^);
 b.SaveToMemory(aPublicKey);
end;

class procedure TRNLED25519.GeneratePublicPrivateKeyPair(const aRandomGenerator:TRNLRandomGenerator;out aPublicKey,aPrivateKey);
begin
 PRNLKey(TRNLPointer(@aPrivateKey))^:=TRNLKey.CreateRandom(aRandomGenerator).ClampForCurve25519;
 DerivePublicKey(aPublicKey,aPrivateKey);
end;

class procedure TRNLED25519.Sign(out aSignature;const aPrivateKey,aMessage;const aMessageSize:TRNLSizeUInt;const aPublicKey:TRNLPointer=nil);
var a,r,h_ram:array[0..63] of TRNLUInt8;
    pkbuf:array[0..31] of TRNLUInt8;
    pk,Prefix:TRNLPointer;
    Hash:TRNLED25519HashContext;
    b:TRNLPoint25519;
    s:array[0..63] of TRNLInt64;
    i,j:TRNLInt32;
begin

 Prefix:=@a[32];

 TRNLED25519Hash.Process(a,aPrivateKey,32);

 PRNLKey(TRNLPointer(@a))^:=PRNLKey(TRNLPointer(@a))^.ClampForCurve25519;

 pk:=aPublicKey;
 if not assigned(pk) then begin
  DerivePublicKey(pkbuf,aPrivateKey);
  pk:=@pkbuf;
 end;

 // Constructs the "random" nonce from the secret key and message.
 // An actual random number would work just fine, and would save us
 // the trouble of hashing the message twice. If we did that
 // however, the user could fuck it up and reuse the nonce.
 Hash.Initialize;
 Hash.Update(Prefix^,32);
 Hash.Update(aMessage,aMessageSize);
 Hash.Finalize(r);
 Reduce(r);

 // first half of the signature = "random" nonce times basepoint
 ScalarMultiplicationBase(b,PRNLKey(TRNLPointer(@r))^);
 b.SaveToMemory(aSignature);

 HashRAM(h_ram,aSignature,pk^,aMessage,aMessageSize);

 for i:=0 to 31 do begin
  s[i]:=r[i];
 end;
 for i:=32 to 63 do begin
  s[i]:=0;
 end;
 for i:=0 to 31 do begin
  for j:=0 to 31 do begin
   inc(s[i+j],h_ram[i]*TRNLUInt64(a[j]));
  end;
 end;

 // second half of the signature = s
 ModL(PRNLUInt8Array(TRNLPointer(@aSignature))^[32],s);

end;

class procedure TRNLED25519.Sign(out aSignature;const aPrivateKey,aPublicKey,aMessage;const aMessageSize:TRNLSizeUInt);
begin
 Sign(aSignature,aPrivateKey,aMessage,aMessageSize,@aPublicKey);
end;

class function TRNLED25519.Verify(const aSignature,aPublicKey,aMessage;const aMessageSize:TRNLSizeUInt):boolean;
var A,p,sB:TRNLPoint25519;
    h_ram:array[0..63] of TRNLUInt8;
    R_check:array[0..31] of TRNLUInt8;
begin
 result:=TRNLPoint25519.LoadFromMemory(A,aPublicKey);
 if result then begin
  HashRAM(h_ram,aSignature,aPublicKey,aMessage,aMessageSize);
  ScalarMultiplication(p,A,PRNLKey(TRNLPointer(@h_ram))^);
  ScalarMultiplicationBase(sB,PRNLKey(TRNLPointer(@PRNLUInt8Array(TRNLPointer(@aSignature))^[32]))^);
  (p+sB).SaveToMemory(R_check);
  result:=TRNLMemory.SecureIsEqual(aSignature,R_check,32);
 end;
end;

class procedure TRNLED25519.SelfTest;
{$ifdef RNLUseBLAKE2B}
begin
 // TODO
end;
{$else}
const PrivateKey0:array[0..31] of TRNLUInt8=
       (
        $9d,$61,$b1,$9d,$ef,$fd,$5a,$60,
        $ba,$84,$4a,$f4,$92,$ec,$2c,$c4,
        $44,$49,$c5,$69,$7b,$32,$69,$19,
        $70,$3b,$ac,$03,$1c,$ae,$7f,$60
       );
      PublicKey0:array[0..31] of TRNLUInt8=
       (
        $d7,$5a,$98,$01,$82,$b1,$0a,$b7,
        $d5,$4b,$fe,$d3,$c9,$64,$07,$3a,
        $0e,$e1,$72,$f3,$da,$a6,$23,$25,
        $af,$02,$1a,$68,$f7,$07,$51,$1a
       );
      Message0:array[0..1] of TRNLUInt8=
       (
        $00,
        $00
       );
      MessageSize0=0;
      Signature0:array[0..63] of TRNLUInt8=
       (
        $e5,$56,$43,$00,$c3,$60,$ac,$72,
        $90,$86,$e2,$cc,$80,$6e,$82,$8a,
        $84,$87,$7f,$1e,$b8,$e5,$d9,$74,
        $d8,$73,$e0,$65,$22,$49,$01,$55,
        $5f,$b8,$82,$15,$90,$a3,$3b,$ac,
        $c6,$1e,$39,$70,$1c,$f9,$b4,$6b,
        $d2,$5b,$f5,$f0,$59,$5b,$be,$24,
        $65,$51,$41,$43,$8e,$7a,$10,$0b
       );
      PrivateKey1:array[0..31] of TRNLUInt8=
       (
        $4c,$cd,$08,$9b,$28,$ff,$96,$da,
        $9d,$b6,$c3,$46,$ec,$11,$4e,$0f,
        $5b,$8a,$31,$9f,$35,$ab,$a6,$24,
        $da,$8c,$f6,$ed,$4f,$b8,$a6,$fb
       );
      PublicKey1:array[0..31] of TRNLUInt8=
       (
        $3d,$40,$17,$c3,$e8,$43,$89,$5a,
        $92,$b7,$0a,$a7,$4d,$1b,$7e,$bc,
        $9c,$98,$2c,$cf,$2e,$c4,$96,$8c,
        $c0,$cd,$55,$f1,$2a,$f4,$66,$0c
       );
      Message1:array[0..1] of TRNLUInt8=
       (
        $72,
        $00
       );
      MessageSize1=1;
      Signature1:array[0..63] of TRNLUInt8=
       (
        $92,$a0,$09,$a9,$f0,$d4,$ca,$b8,
        $72,$0e,$82,$0b,$5f,$64,$25,$40,
        $a2,$b2,$7b,$54,$16,$50,$3f,$8f,
        $b3,$76,$22,$23,$eb,$db,$69,$da,
        $08,$5a,$c1,$e4,$3e,$15,$99,$6e,
        $45,$8f,$36,$13,$d0,$f1,$1d,$8c,
        $38,$7b,$2e,$ae,$b4,$30,$2a,$ee,
        $b0,$0d,$29,$16,$12,$bb,$0c,$00
       );
var Signature:array[0..63] of TRNLUInt8;
begin

 write('[ED25519] Signing message 0 ... ');
 FillChar(Signature,64,#0);
 Sign(Signature,PrivateKey0,PublicKey0,Message0,MessageSize0);
 if TRNLMemory.SecureIsEqual(Signature,Signature0,64) then begin
  writeln('OK!');
 end else begin
  writeln('FAILED!');
 end;

 write('[ED25519] Verifing message 0 ... ');
 if Verify(Signature,PublicKey0,Message0,MessageSize0) then begin
  writeln('OK!');
 end else begin
  writeln('FAILED!');
 end;

 write('[ED25519] Deriving public key 0 ... ');
 FillChar(Signature,32,#0);
 DerivePublicKey(Signature,PrivateKey0);
 if TRNLMemory.SecureIsEqual(Signature,PublicKey0,32) then begin
  writeln('OK!');
 end else begin
  writeln('FAILED!');
 end;

 write('[ED25519] Signing message 1 ... ');
 FillChar(Signature,64,#0);
 Sign(Signature,PrivateKey1,PublicKey1,Message1,MessageSize1);
 if TRNLMemory.SecureIsEqual(Signature,Signature1,64) then begin
  writeln('OK!');
 end else begin
  writeln('FAILED!');
 end;

 write('[ED25519] Verifing message 1 ... ');
 if Verify(Signature,PublicKey1,Message1,MessageSize1) then begin
  writeln('OK!');
 end else begin
  writeln('FAILED!');
 end;

 write('[ED25519] Deriving public key 1 ... ');
 FillChar(Signature,32,#0);
 DerivePublicKey(Signature,PrivateKey1);
 if TRNLMemory.SecureIsEqual(Signature,PublicKey1,32) then begin
  writeln('OK!');
 end else begin
  writeln('FAILED!');
 end;

end;
{$endif}

function TRNLChaCha20Context.GetCounter:TRNLUInt64;
begin
 result:=(TRNLUInt64(fInput[12]) shl 0) or
         (TRNLUInt64(fInput[13]) shl 32);
end;

procedure TRNLChaCha20Context.SetCounter(const aCounter:TRNLUInt64);
begin
 fInput[12]:=aCounter and TRNLUInt32($ffffffff);
 fInput[13]:=aCounter shr 32;
 fPoolIndex:=64;
end;

procedure TRNLChaCha20Context.Initialize(const aKey,aNonce;const aCounter:TRNLUInt64=0);
begin
 fInput[0]:=$61707865;
 fInput[1]:=$3320646e;
 fInput[2]:=$79622d32;
 fInput[3]:=$6b206574;
 fInput[4]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[0]);
 fInput[5]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[1]);
 fInput[6]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[2]);
 fInput[7]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[3]);
 fInput[8]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[4]);
 fInput[9]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[5]);
 fInput[10]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[6]);
 fInput[11]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[7]);
 fInput[12]:=aCounter and TRNLUInt32($ffffffff);
 fInput[13]:=aCounter shr 32;
 fInput[14]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aNonce))^[0]);
 fInput[15]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aNonce))^[1]);
 FillChar(fPool,SizeOf(TRNLChaCha20State),#0);
 fPoolIndex:=64;
end;

procedure TRNLChaCha20Context.EndianNeutralInitialize(const aKey;const aNonce:TRNLUInt64=0;const aCounter:TRNLUInt64=0);
var LocalNonce:TRNLUInt64;
begin
 TRNLMemoryAccess.StoreBigEndianUInt64(LocalNonce,aNonce);
 Initialize(aKey,LocalNonce,Counter);
end;

class procedure TRNLChaCha20Context.Update(out aOutput:TRNLChaCha20State;const aInput:TRNLChaCha20State);
var Index,x,x00,x01,x02,x03,x04,x05,x06,x07,x08,x09,x10,x11,x12,x13,x14,x15:TRNLUInt32;
begin
 x00:=aInput[0];
 x01:=aInput[1];
 x02:=aInput[2];
 x03:=aInput[3];
 x04:=aInput[4];
 x05:=aInput[5];
 x06:=aInput[6];
 x07:=aInput[7];
 x08:=aInput[8];
 x09:=aInput[9];
 x10:=aInput[10];
 x11:=aInput[11];
 x12:=aInput[12];
 x13:=aInput[13];
 x14:=aInput[14];
 x15:=aInput[15];
 for Index:=1 to 20 shr 1 do begin
  // Two unrolled rounds per loop iteration
  inc(x00,x04);
  x:=x12 xor x00;
  x12:={$ifdef fpc}ROLDWord(x,16){$else}(x shl 16) or (x shr 16){$endif};
  inc(x08,x12);
  x:=x04 xor x08;
  x04:={$ifdef fpc}ROLDWord(x,12){$else}(x shl 12) or (x shr 20){$endif};
  inc(x00,x04);
  x:=x12 xor x00;
  x12:={$ifdef fpc}ROLDWord(x,8){$else}(x shl 8) or (x shr 24){$endif};
  inc(x08,x12);
  x:=x04 xor x08;
  x04:={$ifdef fpc}ROLDWord(x,7){$else}(x shl 7) or (x shr 25){$endif};
  inc(x01,x05);
  x:=x13 xor x01;
  x13:={$ifdef fpc}ROLDWord(x,16){$else}(x shl 16) or (x shr 16){$endif};
  inc(x09,x13);
  x:=x05 xor x09;
  x05:={$ifdef fpc}ROLDWord(x,12){$else}(x shl 12) or (x shr 20){$endif};
  inc(x01,x05);
  x:=x13 xor x01;
  x13:={$ifdef fpc}ROLDWord(x,8){$else}(x shl 8) or (x shr 24){$endif};
  inc(x09,x13);
  x:=x05 xor x09;
  x05:={$ifdef fpc}ROLDWord(x,7){$else}(x shl 7) or (x shr 25){$endif};
  inc(x02,x06);
  x:=x14 xor x02;
  x14:={$ifdef fpc}ROLDWord(x,16){$else}(x shl 16) or (x shr 16){$endif};
  inc(x10,x14);
  x:=x06 xor x10;
  x06:={$ifdef fpc}ROLDWord(x,12){$else}(x shl 12) or (x shr 20){$endif};
  inc(x02,x06);
  x:=x14 xor x02;
  x14:={$ifdef fpc}ROLDWord(x,8){$else}(x shl 8) or (x shr 24){$endif};
  inc(x10,x14);
  x:=x06 xor x10;
  x06:={$ifdef fpc}ROLDWord(x,7){$else}(x shl 7) or (x shr 25){$endif};
  inc(x03,x07);
  x:=x15 xor x03;
  x15:={$ifdef fpc}ROLDWord(x,16){$else}(x shl 16) or (x shr 16){$endif};
  inc(x11,x15);
  x:=x07 xor x11;
  x07:={$ifdef fpc}ROLDWord(x,12){$else}(x shl 12) or (x shr 20){$endif};
  inc(x03,x07);
  x:=x15 xor x03;
  x15:={$ifdef fpc}ROLDWord(x,8){$else}(x shl 8) or (x shr 24){$endif};
  inc(x11,x15);
  x:=x07 xor x11;
  x07:={$ifdef fpc}ROLDWord(x,7){$else}(x shl 7) or (x shr 25){$endif};
  inc(x00,x05);
  x:=x15 xor x00;
  x15:={$ifdef fpc}ROLDWord(x,16){$else}(x shl 16) or (x shr 16){$endif};
  inc(x10,x15);
  x:=x05 xor x10;
  x05:={$ifdef fpc}ROLDWord(x,12){$else}(x shl 12) or (x shr 20){$endif};
  inc(x00,x05);
  x:=x15 xor x00;
  x15:={$ifdef fpc}ROLDWord(x,8){$else}(x shl 8) or (x shr 24){$endif};
  inc(x10,x15);
  x:=x05 xor x10;
  x05:={$ifdef fpc}ROLDWord(x,7){$else}(x shl 7) or (x shr 25){$endif};
  inc(x01,x06);
  x:=x12 xor x01;
  x12:={$ifdef fpc}ROLDWord(x,16){$else}(x shl 16) or (x shr 16){$endif};
  inc(x11,x12);
  x:=x06 xor x11;
  x06:={$ifdef fpc}ROLDWord(x,12){$else}(x shl 12) or (x shr 20){$endif};
  inc(x01,x06);
  x:=x12 xor x01;
  x12:={$ifdef fpc}ROLDWord(x,8){$else}(x shl 8) or (x shr 24){$endif};
  inc(x11,x12);
  x:=x06 xor x11;
  x06:={$ifdef fpc}ROLDWord(x,7){$else}(x shl 7) or (x shr 25){$endif};
  inc(x02,x07);
  x:=x13 xor x02;
  x13:={$ifdef fpc}ROLDWord(x,16){$else}(x shl 16) or (x shr 16){$endif};
  inc(x08,x13);
  x:=x07 xor x08;
  x07:={$ifdef fpc}ROLDWord(x,12){$else}(x shl 12) or (x shr 20){$endif};
  inc(x02,x07);
  x:=x13 xor x02;
  x13:={$ifdef fpc}ROLDWord(x,8){$else}(x shl 8) or (x shr 24){$endif};
  inc(x08,x13);
  x:=x07 xor x08;
  x07:={$ifdef fpc}ROLDWord(x,7){$else}(x shl 7) or (x shr 25){$endif};
  inc(x03,x04);
  x:=x14 xor x03;
  x14:={$ifdef fpc}ROLDWord(x,16){$else}(x shl 16) or (x shr 16){$endif};
  inc(x09,x14);
  x:=x04 xor x09;
  x04:={$ifdef fpc}ROLDWord(x,12){$else}(x shl 12) or (x shr 20){$endif};
  inc(x03,x04);
  x:=x14 xor x03;
  x14:={$ifdef fpc}ROLDWord(x,8){$else}(x shl 8) or (x shr 24){$endif};
  inc(x09,x14);
  x:=x04 xor x09;
  x04:={$ifdef fpc}ROLDWord(x,7){$else}(x shl 7) or (x shr 25){$endif};
 end;
 aOutput[0]:=x00;
 aOutput[1]:=x01;
 aOutput[2]:=x02;
 aOutput[3]:=x03;
 aOutput[4]:=x04;
 aOutput[5]:=x05;
 aOutput[6]:=x06;
 aOutput[7]:=x07;
 aOutput[8]:=x08;
 aOutput[9]:=x09;
 aOutput[10]:=x10;
 aOutput[11]:=x11;
 aOutput[12]:=x12;
 aOutput[13]:=x13;
 aOutput[14]:=x14;
 aOutput[15]:=x15;
end;

class procedure TRNLChaCha20Context.HChaCha20Process(out aOutput;const aKey,aInput);
var State:TRNLChaCha20State;
begin
 State[0]:=$61707865;
 State[1]:=$3320646e;
 State[2]:=$79622d32;
 State[3]:=$6b206574;
 State[4]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[0]);
 State[5]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[1]);
 State[6]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[2]);
 State[7]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[3]);
 State[8]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[4]);
 State[9]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[5]);
 State[10]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[6]);
 State[11]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aKey))^[7]);
 State[12]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aInput))^[0]);
 State[13]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aInput))^[1]);
 State[14]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aInput))^[2]);
 State[15]:=TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aInput))^[3]);
 TRNLChaCha20Context.Update(State,State);
 TRNLMemoryAccess.StoreLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aOutput))^[0],State[0]);
 TRNLMemoryAccess.StoreLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aOutput))^[1],State[1]);
 TRNLMemoryAccess.StoreLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aOutput))^[2],State[2]);
 TRNLMemoryAccess.StoreLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aOutput))^[3],State[3]);
 TRNLMemoryAccess.StoreLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aOutput))^[4],State[12]);
 TRNLMemoryAccess.StoreLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aOutput))^[5],State[13]);
 TRNLMemoryAccess.StoreLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aOutput))^[6],State[14]);
 TRNLMemoryAccess.StoreLittleEndianUInt32(PRNLUInt32Array(TRNLPointer(@aOutput))^[7],State[15]);
end;

procedure TRNLChaCha20Context.XChaCha20Initialize(const aKey,aNonce;const aCounter:TRNLUInt64=0);
var DerivedKey:TRNLKey;
begin
 HChaCha20Process(DerivedKey,aKey,aNonce);
 Initialize(DerivedKey,PRNLUInt64(@PRNLUInt8Array(TRNLPointer(@aNonce))^[16])^,0);
end;

procedure TRNLChaCha20Context.RefillPool;
begin
 Update(fPool,fInput);
 inc(fPool[0],fInput[0]);
 inc(fPool[1],fInput[1]);
 inc(fPool[2],fInput[2]);
 inc(fPool[3],fInput[3]);
 inc(fPool[4],fInput[4]);
 inc(fPool[5],fInput[5]);
 inc(fPool[6],fInput[6]);
 inc(fPool[7],fInput[7]);
 inc(fPool[8],fInput[8]);
 inc(fPool[9],fInput[9]);
 inc(fPool[10],fInput[10]);
 inc(fPool[11],fInput[11]);
 inc(fPool[12],fInput[12]);
 inc(fPool[13],fInput[13]);
 inc(fPool[14],fInput[14]);
 inc(fPool[15],fInput[15]);
 fPoolIndex:=0;
 inc(fInput[12]);
 if fInput[12]=0 then begin
  inc(fInput[13]);
 end;
end;

procedure TRNLChaCha20Context.Process(out aCipherText;const aPlainText;const aTextSize:TRNLSizeUInt;const aUsePlainText:boolean=true);
var TextPosition,TextSize:TRNLSizeUInt;
    Plain:TRNLUInt8;
    Index:TRNLUInt32;
begin
 TextPosition:=0;
 TextSize:=aTextSize;
 Plain:=0;
 while ((fPoolIndex and 63)<>0) and (TextSize>0) do begin
  if aUsePlainText then begin
   Plain:=PRNLUInt8Array(TRNLPointer(@aPlainText))^[TextPosition];
  end;
  PRNLUInt8Array(TRNLPointer(@aCipherText))^[TextPosition]:=Plain xor (fPool[fPoolIndex shr 2] shr ((fPoolIndex and 3) shl 3)) and $ff;
  inc(fPoolIndex);
  inc(TextPosition);
  dec(TextSize);
 end;
 if TextSize>=64 then begin
  repeat
   RefillPool;
   if aUsePlainText then begin
    for Index:=0 to 15 do begin
     TRNLMemoryAccess.StoreLittleEndianUInt32(PRNLUInt8Array(TRNLPointer(@aCipherText))^[TextPosition+(Index shl 2)],
                                              TRNLMemoryAccess.LoadLittleEndianUInt32(PRNLUInt8Array(TRNLPointer(@aPlainText))^[TextPosition+(Index shl 2)]) xor fPool[Index]);
    end;
   end else begin
    for Index:=0 to 15 do begin
     TRNLMemoryAccess.StoreLittleEndianUInt32(PRNLUInt8Array(TRNLPointer(@aCipherText))^[TextPosition+(Index shl 2)],
                                              fPool[Index]);
    end;
   end;
   inc(TextPosition,64);
   dec(TextSize,64);
  until TextSize<64;
  fPoolIndex:=64;
 end;
 while TextSize>0 do begin
  if fPoolIndex=64 then begin
   RefillPool;
  end;
  if aUsePlainText then begin
   Plain:=PRNLUInt8Array(TRNLPointer(@aPlainText))^[TextPosition];
  end;
  PRNLUInt8Array(TRNLPointer(@aCipherText))^[TextPosition]:=Plain xor (fPool[fPoolIndex shr 2] shr ((fPoolIndex and 3) shl 3)) and $ff;
  inc(fPoolIndex);
  inc(TextPosition);
  dec(TextSize);
 end;
end;

procedure TRNLChaCha20Context.Stream(out aCipherText;const aTextSize:TRNLSizeUInt);
begin
 Process(aCipherText,TRNLPointer(nil)^,aTextSize,false);
end;

class procedure TRNLChaCha20.SelfTest;
begin
end;

class function TRNLKeyExchange.Process(out aSharedKey:TRNLKey;const aYourSecretKey,aTheirPublicKey:TRNLKey):boolean;
const Zero:array[0..15] of TRNLUInt8=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
var SharedSecret:TRNLKey;
begin
 result:=TRNLCurve25519.Eval(SharedSecret,aYourSecretKey,@aTheirPublicKey);
 TRNLChaCha20Context.HChaCha20Process(aSharedKey,SharedSecret,Zero);
end;

class procedure TRNLAuthenticatedEncryption.Authenticate(out aMAC;const aAuthKey,aT1;const aT1Size:TRNLSizeUInt;const aT2;const aT2Size:TRNLSizeUInt);
var Context:TRNLPoly1305Context;
begin
 Context.Initialize(aAuthKey);
 Context.Update(aT1,aT1Size);
 Context.Update(aT2,aT2Size);
 Context.Finalize(aMAC);
end;

class function TRNLAuthenticatedEncryption.Encrypt(out aCipherText;const aKey,aNonce;out aMAC;const aAssociatedData;const aAssociatedDataSize:TRNLSizeUInt;const aPlainText;const aPlainTextSize:TRNLSizeUInt):boolean;
var AuthKey:TRNLKey;
    Context:TRNLChaCha20Context;
begin
 Context.XChaCha20Initialize(aKey,aNonce,0);
 Context.Stream(AuthKey,SizeOf(TRNLKey));
 Context.Process(aCipherText,aPlainText,aPlainTextSize);
 Authenticate(aMAC,AuthKey,aAssociatedData,aAssociatedDataSize,aCipherText,aPlainTextSize);
 result:=true;
end;

class function TRNLAuthenticatedEncryption.Encrypt(out aCipherText;const aKey,aNonce;out aMAC;const aPlainText;const aPlainTextSize:TRNLSizeUInt):boolean;
begin
 result:=Encrypt(aCipherText,aKey,aNonce,aMAC,TRNLPointer(nil)^,0,aPlainText,aPlainTextSize);
end;

class function TRNLAuthenticatedEncryption.Decrypt(out aPlainText;const aKey,aNonce,aMAC,aAssociatedData;const aAssociatedDataSize:TRNLSizeUInt;const aCipherText;const aCipherTextSize:TRNLSizeUInt):boolean;
var AuthKey:TRNLKey;
    RealMAC:array[0..15] of TRNLUInt8;
    Context:TRNLChaCha20Context;
begin
 Context.XChaCha20Initialize(aKey,aNonce,0);
 Context.Stream(AuthKey,SizeOf(TRNLKey));
 Authenticate(RealMAC,AuthKey,aAssociatedData,aAssociatedDataSize,aCipherText,aCipherTextSize);
 result:=TRNLMemory.SecureIsEqual(aMAC,RealMAC,16);
 if result then begin
  Context.Process(aPlainText,aCipherText,aCipherTextSize,true);
 end;
end;

class function TRNLAuthenticatedEncryption.Decrypt(out aPlainText;const aKey,aNonce,aMAC,aCipherText;const aCipherTextSize:TRNLSizeUInt):boolean;
begin
 result:=Decrypt(aPlainText,aKey,aNonce,aMac,TRNLPointer(nil)^,0,aCipherText,aCipherTextSize);
end;

constructor TRNLSpinLock.Create;
begin
 inherited Create;
 fState:=0;
end;

destructor TRNLSpinLock.Destroy;
begin
 inherited Destroy;
end;

procedure TRNLSpinLockCPURelax;
{$if defined(cpu386) or defined(cpuamd64) or defined(cpux64)}assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$if not (defined(fpc) or defined(cpu386))}
 .noframe
{$ifend}
 rep nop // pause
end;
{$else}
begin
end;
{$ifend}

procedure TRNLSpinLock.Acquire;
var Wait,Index:TRNLSizeUInt;
begin
 Wait:=1;
 while {$ifdef fpc}InterlockedCompareExchange{$else}AtomicCmpExchange{$endif}(fState,-1,0)<>0 do begin
//while {$ifdef fpc}InterlockedExchange{$else}AtomicExchange{$endif}(fState,-1)<>0 do begin
  for Index:=1 to Wait do begin
   TRNLSpinLockCPURelax;
  end;
  while fState<>0 do begin
   if Wait<1024 then begin
    inc(Wait,Wait);
   end;
   for Index:=1 to Wait do begin
    TRNLSpinLockCPURelax;
   end;
  end;
 end;
end;

procedure TRNLSpinLock.Release;
begin
 {$ifdef fpc}InterlockedExchange{$else}AtomicExchange{$endif}(fState,0);
end;

constructor TRNLCircularDoublyLinkedListNode<T>.TValueEnumerator.Create(const aCircularDoublyLinkedList:TRNLCircularDoublyLinkedListNode<T>);
begin
 fCircularDoublyLinkedList:=aCircularDoublyLinkedList;
 fNode:=aCircularDoublyLinkedList;
end;

function TRNLCircularDoublyLinkedListNode<T>.TValueEnumerator.GetCurrent:T;
begin
 result:=fNode.fValue;
end;

function TRNLCircularDoublyLinkedListNode<T>.TValueEnumerator.MoveNext:boolean;
begin
 result:=fCircularDoublyLinkedList.fNext<>fCircularDoublyLinkedList;
 if result then begin
  fNode:=fNode.fNext;
  result:=assigned(fNode) and (fNode<>fCircularDoublyLinkedList);
 end;
end;

constructor TRNLCircularDoublyLinkedListNode<T>.Create;
begin
 inherited Create;
 fNext:=self;
 fPrevious:=self;
 Initialize(fValue);
end;

destructor TRNLCircularDoublyLinkedListNode<T>.Destroy;
begin
 Finalize(fValue);
 if fNext<>self then begin
  Remove;
 end;
 inherited Destroy;
end;

procedure TRNLCircularDoublyLinkedListNode<T>.Clear;
begin
 fNext:=self;
 fPrevious:=self;
 Finalize(fValue);
 Initialize(fValue);
end;

function TRNLCircularDoublyLinkedListNode<T>.Head:TRNLCircularDoublyLinkedListNode<T>;
begin
 result:=fNext;
end;

function TRNLCircularDoublyLinkedListNode<T>.Tail:TRNLCircularDoublyLinkedListNode<T>;
begin
 result:=self;
end;

function TRNLCircularDoublyLinkedListNode<T>.IsEmpty:boolean;
begin
 result:=fNext=self;
end;

function TRNLCircularDoublyLinkedListNode<T>.IsNotEmpty:boolean;
begin
 result:=fNext<>self;
end;

function TRNLCircularDoublyLinkedListNode<T>.Front:TRNLCircularDoublyLinkedListNode<T>;
begin
 result:=fNext;
end;

function TRNLCircularDoublyLinkedListNode<T>.Back:TRNLCircularDoublyLinkedListNode<T>;
begin
 result:=fPrevious;
end;

function TRNLCircularDoublyLinkedListNode<T>.Insert(const aData:TRNLCircularDoublyLinkedListNode<T>):TRNLCircularDoublyLinkedListNode<T>;
var Position:TRNLCircularDoublyLinkedListNode<T>;
begin
 Position:=self;
 result:=aData;
 result.fPrevious:=Position.fPrevious;
 result.fNext:=Position;
 result.fPrevious.fNext:=result;
 Position.fPrevious:=result;
end;

function TRNLCircularDoublyLinkedListNode<T>.Add(const aData:TRNLCircularDoublyLinkedListNode<T>):TRNLCircularDoublyLinkedListNode<T>;
var Position:TRNLCircularDoublyLinkedListNode<T>;
begin
 Position:=Previous;
 result:=aData;
 result.fPrevious:=Position.fPrevious;
 result.fNext:=Position;
 result.fPrevious.fNext:=result;
 Position.fPrevious:=result;
end;

function TRNLCircularDoublyLinkedListNode<T>.Remove:TRNLCircularDoublyLinkedListNode<T>;
begin
 fPrevious.fNext:=fNext;
 fNext.fPrevious:=fPrevious;
 fPrevious:=self;
 fNext:=self;
 result:=self;
end;

function TRNLCircularDoublyLinkedListNode<T>.MoveFrom(const aDataFirst,aDataLast:TRNLCircularDoublyLinkedListNode<T>):TRNLCircularDoublyLinkedListNode<T>;
var First,Last:TRNLCircularDoublyLinkedListNode<T>;
begin
 First:=aDataFirst;
 Last:=aDataLast;
 First.fPrevious.fNext:=Last.fNext;
 Last.fNext.fPrevious:=First.fPrevious;
 First.fPrevious:=fPrevious;
 Last.fNext:=self;
 First.fPrevious.fNext:=First;
 fPrevious:=Last;
 result:=First;
end;

function TRNLCircularDoublyLinkedListNode<T>.PopFromFront(out aData):boolean;
begin
 result:=fNext<>self;
 if result then begin
  TRNLCircularDoublyLinkedListNode<T>(aData):=fNext;
  fNext.Remove;
 end;
end;

function TRNLCircularDoublyLinkedListNode<T>.PopFromBack(out aData):boolean;
begin
 result:=fNext<>self;
 if result then begin
  TRNLCircularDoublyLinkedListNode<T>(aData):=fPrevious;
  fPrevious.Remove;
 end;
end;

function TRNLCircularDoublyLinkedListNode<T>.SortedInserted(const aData:TRNLCircularDoublyLinkedListNode<T>;const aCompareFunc:TRNLCircularDoublyLinkedListNode<T>.TCompareFunc):TRNLCircularDoublyLinkedListNode<T>;
var Current:TRNLCircularDoublyLinkedListNode<T>;
begin
 if assigned(self) then begin
  if IsEmpty then begin
   result:=Add(aData);
  end else if aCompareFunc(fPrevious,aData)<=0 then begin
   result:=fPrevious.fNext.Insert(aData);
  end else begin
   Current:=fNext;
   while (Current<>self) and (aCompareFunc(Current,aData)<=0) do begin
    Current:=Current.fNext;
   end;
   result:=Current.Insert(aData);
  end;
{ Current:=fNext;
  while Current<>self do begin
   if (Current.fNext<>self) and (aCompareFunc(Current,Current.fNext)>0) then begin
    write('!');
   end;
   Current:=Current.fNext;
  end;}
 end else begin
  result:=nil;
 end;
end;

function TRNLCircularDoublyLinkedListNode<T>.ListSize:TRNLSizeUInt;
var Position:TRNLCircularDoublyLinkedListNode<T>;
begin
 result:=0;
 if assigned(self) then begin
  Position:=Next;
  while Position<>self do begin
   inc(result);
   Position:=Position.fNext;
  end;
 end;
end;

function TRNLCircularDoublyLinkedListNode<T>.GetEnumerator:TRNLCircularDoublyLinkedListNode<T>.TValueEnumerator;
begin
 result:=TValueEnumerator.Create(self);
end;

constructor TRNLQueue<T>.Create;
begin
 inherited Create;
 fItems:=nil;
 fHead:=0;
 fTail:=0;
 fCount:=0;
 fSize:=0;
 fSpinLock:=TRNLSpinLock.Create;
end;

destructor TRNLQueue<T>.Destroy;
begin
 FreeAndNil(fSpinLock);
 fItems:=nil;
 inherited Destroy;
end;

function TRNLQueue<T>.GetCount:TRNLSizeInt;
begin
 result:=fCount;
end;

procedure TRNLQueue<T>.Clear;
begin
 fSpinLock.Acquire;
 try
  while fCount>0 do begin
   dec(fCount);
   Finalize(fItems[fHead]);
   inc(fHead);
   if fHead>=fSize then begin
    fHead:=0;
   end;
  end;
  fItems:=nil;
  fHead:=0;
  fTail:=0;
  fCount:=0;
  fSize:=0;
 finally
  fSpinLock.Release;
 end;
end;

function TRNLQueue<T>.IsEmpty:boolean;
begin
 result:=fCount=0;
end;

function TRNLQueue<T>.IsNotEmpty:boolean;
begin
 result:=fCount>0;
end;

procedure TRNLQueue<T>.GrowResize(const aSize:TRNLSizeInt);
var Index,OtherIndex:TRNLSizeInt;
    NewItems:TRNLQueueItems;
begin
 SetLength(NewItems,aSize);
 OtherIndex:=fHead;
 for Index:=0 to fCount-1 do begin
  NewItems[Index]:=fItems[OtherIndex];
  inc(OtherIndex);
  if OtherIndex>=fSize then begin
   OtherIndex:=0;
  end;
 end;
 fItems:=NewItems;
 fHead:=0;
 fTail:=fCount;
 fSize:=aSize;
end;

procedure TRNLQueue<T>.EnqueueAtFront(const aItem:T);
var Index:TRNLSizeInt;
begin
 fSpinLock.Acquire;
 try
  if fSize<=fCount then begin
   GrowResize(fCount+1);
  end;
  dec(fHead);
  if fHead<0 then begin
   inc(fHead,fSize);
  end;
  Index:=fHead;
  fItems[Index]:=aItem;
  {$ifdef fpc}{$ifdef CPU64}InterlockedIncrement64{$else}InterlockedIncrement{$endif}{$else}AtomicIncrement{$endif}({$ifdef CPU64}TRNLInt64{$else}TRNLInt32{$endif}(fCount));
 finally
  fSpinLock.Release;
 end;
end;

procedure TRNLQueue<T>.Enqueue(const aItem:T);
var Index:TRNLSizeInt;
begin
 fSpinLock.Acquire;
 try
  if fSize<=fCount then begin
   GrowResize(fCount+1);
  end;
  Index:=fTail;
  inc(fTail);
  if fTail>=fSize then begin
   fTail:=0;
  end;
  fItems[Index]:=aItem;
  {$ifdef fpc}{$ifdef CPU64}InterlockedIncrement64{$else}InterlockedIncrement{$endif}{$else}AtomicIncrement{$endif}({$ifdef CPU64}TRNLInt64{$else}TRNLInt32{$endif}(fCount));
 finally
  fSpinLock.Release;
 end;
end;

function TRNLQueue<T>.Dequeue(out aItem:T):boolean;
begin
 fSpinLock.Acquire;
 try
  result:=fCount>0;
  if result then begin
   {$ifdef fpc}{$ifdef CPU64}InterlockedDecrement64{$else}InterlockedDecrement{$endif}{$else}AtomicDecrement{$endif}({$ifdef CPU64}TRNLInt64{$else}TRNLInt32{$endif}(fCount));
   aItem:=fItems[fHead];
   Finalize(fItems[fHead]);
   FillChar(fItems[fHead],SizeOf(T),#0);
   if fCount=0 then begin
    fHead:=0;
    fTail:=0;
   end else begin
    inc(fHead);
    if fHead>=fSize then begin
     fHead:=0;
    end;
   end;
  end;
 finally
  fSpinLock.Release;
 end;
end;

function TRNLQueue<T>.Dequeue:boolean;
begin
 fSpinLock.Acquire;
 try
  result:=fCount>0;
  if result then begin
   {$ifdef fpc}{$ifdef CPU64}InterlockedDecrement64{$else}InterlockedDecrement{$endif}{$else}AtomicDecrement{$endif}({$ifdef CPU64}TRNLInt64{$else}TRNLInt32{$endif}(fCount));
   Finalize(fItems[fHead]);
   FillChar(fItems[fHead],SizeOf(T),#0);
   if fCount=0 then begin
    fHead:=0;
    fTail:=0;
   end else begin
    inc(fHead);
    if fHead>=fSize then begin
     fHead:=0;
    end;
   end;
  end;
 finally
  fSpinLock.Release;
 end;
end;

function TRNLQueue<T>.Peek(out aItem:T):boolean;
begin
 fSpinLock.Acquire;
 try
  result:=fCount>0;
  if result then begin
   aItem:=fItems[fHead];
  end;
 finally
  fSpinLock.Release;
 end;
end;

constructor TRNLStack<T>.Create;
begin
 inherited Create;
 fItems:=nil;
 fCount:=0;
 fSpinLock:=TRNLSpinLock.Create;
end;

destructor TRNLStack<T>.Destroy;
begin
 FreeAndNil(fSpinLock);
 fItems:=nil;
 inherited Destroy;
end;

function TRNLStack<T>.GetCount:TRNLSizeInt;
begin
 result:=fCount;
end;

procedure TRNLStack<T>.Clear;
begin
 fSpinLock.Acquire;
 try
  while fCount>0 do begin
   {$ifdef fpc}{$ifdef CPU64}InterlockedDecrement64{$else}InterlockedDecrement{$endif}{$else}AtomicDecrement{$endif}({$ifdef CPU64}TRNLInt64{$else}TRNLInt32{$endif}(fCount));
   Finalize(fItems[fCount]);
  end;
 finally
  fSpinLock.Release;
 end;
end;

function TRNLStack<T>.IsEmpty:boolean;
begin
 result:=fCount=0;
end;

function TRNLStack<T>.IsNotEmpty:boolean;
begin
 result:=fCount>0;
end;

procedure TRNLStack<T>.Push(const aItem:T);
var Index:TRNLSizeInt;
begin
 fSpinLock.Acquire;
 try
  Index:=fCount;
  {$ifdef fpc}{$ifdef CPU64}InterlockedIncrement64{$else}InterlockedIncrement{$endif}{$else}AtomicIncrement{$endif}({$ifdef CPU64}TRNLInt64{$else}TRNLInt32{$endif}(fCount));
  if length(fItems)<fCount then begin
   SetLength(fItems,fCount+fCount);
  end;
  fItems[Index]:=aItem;
 finally
  fSpinLock.Release;
 end;
end;

function TRNLStack<T>.Pop(out aItem:T):boolean;
begin
 fSpinLock.Acquire;
 try
  result:=fCount>0;
  if result then begin
   {$ifdef fpc}{$ifdef CPU64}InterlockedDecrement64{$else}InterlockedDecrement{$endif}{$else}AtomicDecrement{$endif}({$ifdef CPU64}TRNLInt64{$else}TRNLInt32{$endif}(fCount));
   aItem:=fItems[fCount];
   Finalize(fItems[fCount]);
  end;
 finally
  fSpinLock.Release;
 end;
end;

function TRNLStack<T>.Peek(out aItem:T):boolean;
begin
 fSpinLock.Acquire;
 try
  result:=fCount>0;
  if result then begin
   aItem:=fItems[fCount-1];
  end;
 finally
  fSpinLock.Release;
 end;
end;

constructor TRNLObjectList<T>.TValueEnumerator.Create(const aObjectList:TRNLObjectList<T>);
begin
 fObjectList:=aObjectList;
 fIndex:=-1;
end;

function TRNLObjectList<T>.TValueEnumerator.MoveNext:boolean;
begin
 inc(fIndex);
 result:=fIndex<fObjectList.fCount;
end;

function TRNLObjectList<T>.TValueEnumerator.GetCurrent:T;
begin
 result:=fObjectList.fItems[fIndex];
end;

constructor TRNLObjectList<T>.Create(const aOwnObjects:boolean);
begin
 inherited Create;
 fItems:=nil;
 fCount:=0;
 fAllocated:=0;
 fOwnObjects:=aOwnObjects;
end;

destructor TRNLObjectList<T>.Destroy;
begin
 Clear;
 inherited Destroy;
end;

procedure TRNLObjectList<T>.Clear;
var Index:TRNLSizeInt;
begin
 if fOwnObjects then begin
  for Index:=0 to fCount-1 do begin
   FreeAndNil(fItems[Index]);
  end;
 end;
 SetLength(fItems,0);
 fCount:=0;
 fAllocated:=0;
end;

function TRNLObjectList<T>.GetItem(const pIndex:TRNLSizeInt):T;
begin
 if (pIndex<0) or (pIndex>=fCount) then begin
  raise ERangeError.Create('Out of index range');
 end;
 result:=fItems[pIndex];
end;

procedure TRNLObjectList<T>.SetItem(const pIndex:TRNLSizeInt;const pItem:T);
begin
 if (pIndex<0) or (pIndex>=fCount) then begin
  raise ERangeError.Create('Out of index range');
 end;
 fItems[pIndex]:=pItem;
end;

procedure TRNLObjectList<T>.Assign(const pFrom:TRNLObjectList<T>);
begin
 fItems:=pFrom.fItems;
 fCount:=pFrom.Count;
 fAllocated:=pFrom.fAllocated;
end;

function TRNLObjectList<T>.IndexOf(const pItem:T):TRNLSizeInt;
var Index:TRNLSizeInt;
begin
 for Index:=0 to fCount-1 do begin
  if fItems[Index]=pItem then begin
   result:=Index;
   exit;
  end;
 end;
 result:=-1;
end;

function TRNLObjectList<T>.Add(const pItem:T):TRNLSizeInt;
begin
 result:=fCount;
 inc(fCount);
 if fAllocated<fCount then begin
  fAllocated:=fCount+fCount;
  SetLength(fItems,fAllocated);
 end;
 fItems[result]:=pItem;
end;

procedure TRNLObjectList<T>.Insert(const pIndex:TRNLSizeInt;const pItem:T);
var a,b:pointer;
begin
 if pIndex>=0 then begin
  if pIndex<fCount then begin
   inc(fCount);
   if fCount<fAllocated then begin
    fAllocated:=fCount shl 1;
    SetLength(fItems,fAllocated);
   end;
   a:=@fItems[pIndex];
   b:=@fItems[pIndex+1];
   Move(a^,b^,(fCount-(pIndex+1))*SizeOf(T));
   FillChar(fItems[pIndex],SizeOf(T),#0);
  end else begin
   fCount:=pIndex+1;
   if fCount<fAllocated then begin
    fAllocated:=fCount shl 1;
    SetLength(fItems,fAllocated);
   end;
  end;
  fItems[pIndex]:=pItem;
 end;
end;

procedure TRNLObjectList<T>.Delete(const pIndex:TRNLSizeInt);
var a,b:pointer;
begin
 if (pIndex<0) or (pIndex>=fCount) then begin
  raise ERangeError.Create('Out of index range');
 end;
 if fOwnObjects then begin
  FreeAndNil(fItems[pIndex]);
 end;
 pointer(fItems[pIndex]):=nil;
 a:=@fItems[pIndex+1];
 b:=@fItems[pIndex];
 Move(a^,b^,(fCount-pIndex)*SizeOf(T));
 dec(fCount);
 FillChar(fItems[fCount],SizeOf(T),#0);
 if fCount<(fAllocated shr 1) then begin
  fAllocated:=fAllocated shr 1;
  SetLength(fItems,fAllocated);
 end;
end;

procedure TRNLObjectList<T>.Remove(const pItem:T);
var Index:TRNLSizeInt;
begin
 Index:=IndexOf(pItem);
 if Index>=0 then begin
  Delete(Index);
 end;
end;

procedure TRNLObjectList<T>.Exchange(const pIndex,pWithIndex:TRNLSizeInt);
var Temporary:T;
begin
 if ((pIndex<0) or (pIndex>=fCount)) or ((pWithIndex<0) or (pWithIndex>=fCount)) then begin
  raise ERangeError.Create('Out of index range');
 end;
 Temporary:=fItems[pIndex];
 fItems[pIndex]:=fItems[pWithIndex];
 fItems[pWithIndex]:=Temporary;
end;

function TRNLObjectList<T>.GetEnumerator:TRNLObjectList<T>.TValueEnumerator;
begin
 result:=TValueEnumerator.Create(self);
end;

constructor TRNLBits.Create(const aSize:TRNLSizeInt);
begin
 inherited Create;
 fData:=nil;
 fSize:=aSize;
 SetLength(fData,(fSize+31) shr 5);
 if length(fData)>0 then begin
  FillChar(fData[0],length(fData)*SizeOf(TRNLUInt32),#0);
 end;
end;

destructor TRNLBits.Destroy;
begin
 fData:=nil;
 inherited Destroy;
end;

procedure TRNLBits.Clear;
begin
 if length(fData)>0 then begin
  FillChar(fData[0],length(fData)*SizeOf(TRNLUInt32),#0);
 end;
end;

function TRNLBits.GetNextSetBitIndex(const aIndex:TRNLSizeInt=-1):TRNLSizeInt;
var Index,ElementIndex:TRNLSizeInt;
    Element:TRNLUInt32;
begin
 Index:=aIndex+1;
 while Index<fSize do begin
  ElementIndex:=Index shr 5;
  Element:=fData[ElementIndex] and not ((TRNLUInt32(1) shl (Index and 31))-1);
  if Element<>0 then begin
   result:=(ElementIndex shl 5) or TRNLSizeInt({$ifdef fpc}BSFDWord{$else}RawBitScanForwardUInt32{$endif}(Element));
   exit;
  end else begin
   inc(Index,32);
  end;
 end;
 result:=-1;
end;

function TRNLBits.GetBit(const aIndex:TRNLSizeInt):boolean;
begin
 result:=(fData[aIndex shr 5] and (TRNLUInt32(1) shl (aIndex and 31)))<>0;
end;

procedure TRNLBits.SetBit(const aIndex:TRNLSizeInt;const aBit:boolean);
var Index:TRNLSizeUInt;
    Mask:TRNLUInt32;
begin
 Index:=aIndex shr 5;
 Mask:=TRNLUInt32(1) shl (aIndex and 31);
 if aBit then begin
  fData[Index]:=fData[Index] or Mask;
 end else begin
  fData[Index]:=fData[Index] and not Mask;
 end;
end;

constructor TRNLIDManager.Create;
begin
 inherited Create;
 fIDCounter:=0;
 fFreeStack:=TRNLIDManagerFreeStack.Create;
end;

destructor TRNLIDManager.Destroy;
begin
 fFreeStack.Free;
 inherited Destroy;
end;

function TRNLIDManager.AllocateID:TRNLID;
begin
 if not fFreeStack.Pop(result) then begin
  result:=fIDCounter;
  inc(fIDCounter);
 end;
end;

procedure TRNLIDManager.FreeID(const aID:TRNLID);
begin
 fFreeStack.Push(aID);
end;

constructor TRNLIDMap<T>.Create;
begin
 inherited Create;
 fItems:=nil;
 fCount:=0;
end;

destructor TRNLIDMap<T>.Destroy;
begin
 fItems:=nil;
 inherited Destroy;
end;

function TRNLIDMap<T>.GetItem(const aID:TRNLID):T;
begin
 if aID<fCount then begin
  result:=fItems[aID];
 end else begin
  pointer(result):=nil;
 end;
end;

procedure TRNLIDMap<T>.SetItem(const aID:TRNLID;const aItem:T);
var OldCount:TRNLSizeUInt;
begin
 OldCount:=fCount;
 if OldCount<=aID then begin
  fCount:=TRNLSizeUInt(aID+1)*2;
  SetLength(fItems,fCount);
  FillChar(fItems[OldCount],(fCount-OldCount)*TRNLSizeUInt(SizeOf(T)),#0);
 end;
 fItems[aID]:=aItem;
end;

constructor TRNLAddress.CreateFromString(const aString:TRNLString);
 function ParseIP(const aInputString:TRNLRawByteString;out aAddress:TRNLAddress):boolean;
 var Index,Part,StringLength,SubLength,Value,Base,
     FirstColonPosition,
     FirstDotPosition,
     FirstOpenBracketPosition,
     FirstCloseBracketPosition,
     ZeroCompressionLocation:TRNLSizeInt;
     IsLocalIPv6:boolean;
 begin

  result:=false;

  StringLength:=length(aInputString);

  FirstColonPosition:=0;
  FirstDotPosition:=0;
  FirstOpenBracketPosition:=0;
  FirstCloseBracketPosition:=0;

  for Index:=1 to StringLength do begin
   case aInputString[Index] of
    ':':begin
     if FirstColonPosition=0 then begin
      FirstColonPosition:=Index;
     end;
    end;
    '.':begin
     if FirstDotPosition=0 then begin
      FirstDotPosition:=Index;
     end;
    end;
    '[':begin
     if FirstOpenBracketPosition=0 then begin
      FirstOpenBracketPosition:=Index;
     end;
    end;
    ']':begin
     if FirstCloseBracketPosition=0 then begin
      FirstCloseBracketPosition:=Index;
     end;
    end;
   end;
  end;

  IsLocalIPv6:=(FirstOpenBracketPosition>0) or
               (FirstDotPosition=0) or
               ((FirstColonPosition>0) and
                ((FirstDotPosition=0) or
                 (FirstColonPosition<FirstDotPosition)));

  if IsLocalIPv6 then begin

   if (FirstOpenBracketPosition>0) and
      ((FirstCloseBracketPosition=0) or
       (FirstOpenBracketPosition>FirstCloseBracketPosition)) then begin
    exit;
   end;

   ZeroCompressionLocation:=-1;

   Index:=FirstOpenBracketPosition+1;

   SubLength:=StringLength;
   if (FirstCloseBracketPosition>0) and (FirstCloseBracketPosition<=SubLength) then begin
    SubLength:=FirstCloseBracketPosition-1;
   end;

   Part:=0;
   while Part<16 do begin

    Value:=0;

    if (Index<=StringLength) and (aInputString[Index] in ['0'..'9','a'..'f','A'..'F']) then begin

     Base:=Index;

     while Index<=StringLength do begin
      case aInputString[Index] of
       '0'..'9':begin
        Value:=(Value shl 4) or (ord(aInputString[Index])-ord('0'));
       end;
       'a'..'f':begin
        Value:=(Value shl 4) or ((ord(aInputString[Index])-ord('a'))+$a);
       end;
       'A'..'F':begin
        Value:=(Value shl 4) or ((ord(aInputString[Index])-ord('A'))+$a);
       end;
       else begin
        break;
       end;
      end;
      inc(Index);
     end;

     if (Index<=StringLength) and (aInputString[Index]='.') then begin

      Index:=Base;

      Base:=Part;

      for Part:=0 to 3 do begin

       if not ((Index<=StringLength) and (aInputString[Index] in ['0'..'9'])) then begin
        exit;
       end;

       Value:=0;
       while (Index<=StringLength) and (aInputString[Index] in ['0'..'9']) do begin
        Value:=(Value*10)+(ord(aInputString[Index])-ord('0'));
        inc(Index);
       end;

       aAddress.Host.Addr[Base+Part]:=Value;

       if Part<>3 then begin
        if (Index<=StringLength) and (aInputString[Index]='.') then begin
         inc(Index);
        end else begin
         exit;
        end;
       end;

      end;

      Part:=Base+4;

      break;

     end else begin

      if Part<15 then begin

       aAddress.Host.Addr[Part+0]:=Value shr 8;
       aAddress.Host.Addr[Part+1]:=Value and $ff;
       inc(Part,2);

       if (Index<=StringLength) and (aInputString[Index]=':') then begin
        inc(Index);
       end else begin
        break;
       end;

      end;
     end;

    end else begin

     if ZeroCompressionLocation>=0 then begin
      if ZeroCompressionLocation=Part then begin
       dec(Part,2);
       break;
      end else begin
       exit;
      end;
     end;

     if (Index<=StringLength) and (aInputString[Index]=':') then begin
      if Part=0 then begin
       inc(Index);
       if (not (Index<=StringLength) and (aInputString[Index]=':')) then begin
        break;
       end;
      end;
      inc(Index);
      ZeroCompressionLocation:=Part;
     end else begin
      exit;
     end;

    end;

   end;

   if FirstCloseBracketPosition>0 then begin
    Index:=FirstCloseBracketPosition+1;
   end;

   if ZeroCompressionLocation>=0 then begin
    System.Move(aAddress.Host.Addr[ZeroCompressionLocation],
                aAddress.Host.Addr[16-(Part-ZeroCompressionLocation)],
                Part-ZeroCompressionLocation);
    FillChar(aAddress.Host.Addr[ZeroCompressionLocation],(16-(Part-ZeroCompressionLocation))-ZeroCompressionLocation,#0);
   end;

  end else begin

   if (FirstDotPosition=0) or
      ((FirstColonPosition>0) and (FirstColonPosition<FirstDotPosition)) or
      (FirstOpenBracketPosition>0) or
      (FirstCloseBracketPosition>0) then begin
    exit;
   end;

   aAddress.Host:=RNL_IPV4MAPPED_PREFIX;

   Index:=1;

   for Part:=0 to 3 do begin

    if not ((Index<=StringLength) and (aInputString[Index] in ['0'..'9'])) then begin
     exit;
    end;

    Value:=0;
    while (Index<=StringLength) and (aInputString[Index] in ['0'..'9']) do begin
     Value:=(Value*10)+(ord(aInputString[Index])-ord('0'));
     inc(Index);
    end;

    aAddress.Host.Addr[RNL_IPV4MAPPED_PREFIX_LEN+Part]:=Value;

    if Part<>3 then begin
     if (Index<=StringLength) and (aInputString[Index]='.') then begin
      inc(Index);
     end else begin
      exit;
     end;
    end;

   end;

  end;

  result:=true;

  if (Index<=StringLength) and (aInputString[Index]=':') then begin

   inc(Index);

   if not ((Index<=StringLength) and (aInputString[Index] in ['0'..'9'])) then begin
    exit;
   end;

   Value:=0;
   while (Index<=StringLength) and (aInputString[Index] in ['0'..'9']) do begin
    Value:=(Value*10)+(ord(aInputString[Index])-ord('0'));
    inc(Index);
   end;

   aAddress.Port:=Value;

  end;

 end;
begin
 FillChar(self,SizeOf(TRNLAddress),#0);
 if ParseIP(aString,self) then begin
  ScopeID:=0;
 end else begin
  ScopeID:=TRNLUInt32($deadc0d3);
 end;
end;

function TRNLAddress.ToString:TRNLString;
const HexChars:array[0..15] of TRNLChar=('0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f');
var Index,BestIndex,BestLength,CurrentIndex,CurrentLength,Value:Int32;
    HasDigits:boolean;
begin
 case GetAddressFamily of
  RNL_IPV4:begin
   result:=IntToStr(Host.Addr[12])+'.'+
           IntToStr(Host.Addr[13])+'.'+
           IntToStr(Host.Addr[14])+'.'+
           IntToStr(Host.Addr[15])+':'+
           IntToStr(Port);
  end;
  RNL_IPV6:begin
   if PRNLUInt64Array(@Host.Addr)^[0]=0 then begin
    if PRNLUInt16Array(@Host.Addr)^[4]=0 then begin
     case PRNLUInt16Array(@Host.Addr)^[5] of
      0:begin
       if PRNLUInt32Array(@Host.Addr)^[3]=0 then begin
        result:='::';
        exit;
       end else begin
        result:='[::'+
                IntToStr(Host.Addr[12])+'.'+
                IntToStr(Host.Addr[13])+'.'+
                IntToStr(Host.Addr[14])+'.'+
                IntToStr(Host.Addr[15])+']:'+
                IntToStr(Port);
        exit;
       end;
      end;
      $ffff:begin
       result:='[::ffff:'+
               IntToStr(Host.Addr[12])+'.'+
               IntToStr(Host.Addr[13])+'.'+
               IntToStr(Host.Addr[14])+'.'+
               IntToStr(Host.Addr[15])+']:'+
               IntToStr(Port);
       exit;
      end;
     end;
    end;
   end;
   begin
    result:='[';
    BestIndex:=-1;
    BestLength:=0;
    CurrentIndex:=-1;
    CurrentLength:=0;
    for Index:=0 to 7 do begin
     if PRNLUInt16Array(@Host.Addr)^[Index]=0 then begin
      if CurrentIndex<0 then begin
       CurrentIndex:=Index;
       CurrentLength:=1;
      end else begin
       inc(CurrentLength);
      end;
     end else begin
      if CurrentIndex>=0 then begin
       if (BestLength<0) or (BestLength<CurrentLength) then begin
        BestIndex:=CurrentIndex;
        BestLength:=CurrentLength;
       end;
       CurrentIndex:=-1;
      end;
     end;
    end;
    if (CurrentIndex>=0) and ((BestLength<0) or (BestLength<CurrentLength)) then begin
     BestIndex:=CurrentIndex;
     BestLength:=CurrentLength;
    end;
    if (BestIndex>=0) and (BestLength<2) then begin
     BestIndex:=-1;
    end;
    for Index:=0 to 7 do begin
     if (BestIndex>=0) and (Index>=BestIndex) and (Index<(BestIndex+BestLength)) then begin
      if Index=BestIndex then begin
       result:=result+':';
      end;
     end else begin
      if Index<>0 then begin
       result:=result+':';
      end;
      if (Index=6) and
         (BestIndex=0) and
         ((BestLength=5) and
          (PRNLUInt64Array(@Host.Addr)^[0]=0) and
          (PRNLUInt16Array(@Host.Addr)^[4]=0) and
          (PRNLUInt16Array(@Host.Addr)^[5]=$ffff)) or
         ((BestLength=6) and
          (PRNLUInt64Array(@Host.Addr)^[0]=0) and
          (PRNLUInt32Array(@Host.Addr)^[2]=0)) then begin
       result:=result+
               IntToStr(Host.Addr[12])+'.'+
               IntToStr(Host.Addr[13])+'.'+
               IntToStr(Host.Addr[14])+'.'+
               IntToStr(Host.Addr[15]);
       break;
      end else begin
       HasDigits:=false;
       Value:=(Host.Addr[(Index shl 1) or 0] shr 4) and $f;
       if Value<>0 then begin
        result:=result+HexChars[Value and $f];
        HasDigits:=true;
       end;
       Value:=(Host.Addr[(Index shl 1) or 0] shr 0) and $f;
       if HasDigits or (Value<>0) then begin
        result:=result+HexChars[Value and $f];
        HasDigits:=true;
       end;
       Value:=(Host.Addr[(Index shl 1) or 1] shr 4) and $f;
       if HasDigits or (Value<>0) then begin
        result:=result+HexChars[Value and $f];
        HasDigits:=true;
       end;
       Value:=(Host.Addr[(Index shl 1) or 1] shr 0) and $f;
       if HasDigits or (Value<>0) then begin
        result:=result+HexChars[Value and $f];
       end;
      end;
     end;
    end;
    if (BestIndex>=0) and ((BestIndex+BestLength)=8) then begin
     result:=result+':';
    end;
   end;
   result:=result+']:'+
                  IntToStr(Port);
  end;
  else begin
   result:='';
  end;
 end;
end;

function TRNLAddress.Equals(const aWith:TRNLAddress):boolean;
begin
 result:=Host.Equals(aWith.Host) and (ScopeID=aWith.ScopeID) and (Port=aWith.Port);
end;

{$ifdef Windows}
function __WSAFDIsSet(s:TRNLSocket;var FDSet:TRNLSocketSet):bool; stdcall; external 'ws2_32.dll' name '__WSAFDIsSet';

procedure FD_CLR(const Socket:TRNLSocket;var FDSet:TRNLSocketSet);
var i:TRNLUInt32;
begin
 i:=0;
 while i<FDSet.fd_count do begin
  if FDSet.fd_array[i]=Socket then begin
   while i<FDSet.fd_count-1 do begin
    FDSet.fd_array[i]:=FDSet.fd_array[i+1];
    inc(i);
   end;
   dec(FDSet.fd_count);
   break;
  end;
  inc(i);
 end;
end;

function FD_ISSET(const Socket:TRNLSocket;var FDSet:TRNLSocketSet):Boolean;
begin
 result:=__WSAFDIsSet(Socket,FDSet);
end;

procedure FD_SET(const Socket:TRNLSocket;var FDSet:TRNLSocketSet);
begin
 if FDSet.fd_count<RNL_FD_SETSIZE then begin
  FDSet.fd_array[FDSet.fd_count]:=Socket;
  inc(FDSet.fd_count);
 end;
end;

procedure FD_ZERO(var FDSet:TRNLSocketSet);
begin
 FDSet.fd_count:=0;
end;
{$endif}

class function TRNLSocketSetHelper.Empty:TRNLSocketSet;
begin
{$if defined(Posix)}
 __FD_ZERO(result);
{$elseif defined(Unix)}
 fpFD_ZERO(result);
{$else}
 FD_ZERO(result);
{$ifend}
end;

procedure TRNLSocketSetHelper.Clear;
begin
{$if defined(Posix)}
 __FD_ZERO(self);
{$elseif defined(Unix)}
 fpFD_ZERO(self);
{$else}
 FD_ZERO(self);
{$ifend}
end;

procedure TRNLSocketSetHelper.Add(const aSocket:TRNLSocket);
begin
{$if defined(Posix)}
 __FD_SET(aSocket,self);
{$elseif defined(Unix)}
 fpFD_SET(aSocket,self);
{$else}
 FD_SET(aSocket,self);
{$ifend}
end;

procedure TRNLSocketSetHelper.Remove(const aSocket:TRNLSocket);
begin
{$if defined(Posix)}
 __FD_CLR(aSocket,self);
{$elseif defined(Unix)}
 fpFD_CLR(aSocket,self);
{$else}
 FD_CLR(aSocket,self);
{$ifend}
end;

function TRNLSocketSetHelper.Check(const aSocket:TRNLSocket):boolean;
begin
{$if defined(Posix)}
 result:=__FD_ISSET(aSocket,self);
{$elseif defined(Unix)}
 result:=fpFD_ISSET(aSocket,self)=1;
{$else}
 result:=FD_ISSET(aSocket,self);
{$ifend}
end;

function TRNLAddress.GetAddressFamily:TRNLAddressFamily;
begin
 if (Host.Addr[0]=RNL_IPV4MAPPED_PREFIX.Addr[0]) and
    (Host.Addr[1]=RNL_IPV4MAPPED_PREFIX.Addr[1]) and
    (Host.Addr[2]=RNL_IPV4MAPPED_PREFIX.Addr[2]) and
    (Host.Addr[3]=RNL_IPV4MAPPED_PREFIX.Addr[3]) and
    (Host.Addr[4]=RNL_IPV4MAPPED_PREFIX.Addr[4]) and
    (Host.Addr[5]=RNL_IPV4MAPPED_PREFIX.Addr[5]) and
    (Host.Addr[6]=RNL_IPV4MAPPED_PREFIX.Addr[6]) and
    (Host.Addr[7]=RNL_IPV4MAPPED_PREFIX.Addr[7]) and
    (Host.Addr[8]=RNL_IPV4MAPPED_PREFIX.Addr[8]) and
    (Host.Addr[9]=RNL_IPV4MAPPED_PREFIX.Addr[9]) and
    (Host.Addr[10]=RNL_IPV4MAPPED_PREFIX.Addr[10]) and
    (Host.Addr[11]=RNL_IPV4MAPPED_PREFIX.Addr[11]) then begin
  result:=RNL_IPV4;
 end else begin
  result:=RNL_IPV6;
 end;
end;

constructor TRNLHostAddress.CreateFromIPV4(Address:TRNLUInt32);
begin
 self:=RNL_IPV4MAPPED_PREFIX_INIT;
 TRNLUInt32(TRNLPointer(@Addr[12])^):=Address;
end;

function TRNLHostAddress.Equals(const aWith:TRNLHostAddress):boolean;
begin
 result:=(PRNLUInt64Array(TRNLPointer(@self))^[0]=PRNLUInt64Array(TRNLPointer(@aWith))^[0]) and
         (PRNLUInt64Array(TRNLPointer(@self))^[1]=PRNLUInt64Array(TRNLPointer(@aWith))^[1]);
end;

var RNLInitializationReferenceCounter:TRNLInt32=0;

    RNLNetworkInitializationReferenceCounter:TRNLInt32=0;

{$if defined(Unix) or defined(Posix)}
const SOCKET_ERROR=-1;

{$if defined(Linux) or defined(Android)}
      SOCK_CLOEXEC=$80000; // 02000000;
{$ifend}

{$ifdef fpc}
      AI_ADDRCONFIG=$400;
{$endif}

{$if defined(Linux) or defined(Android)}
      IP_MTU_DISCOVER=10;
      IP_MTU=14;

      IP_NODEFRAG=22;

      IP_PMTUDISC_DONT=0;
      IP_PMTUDISC_WANT=1;
      IP_PMTUDISC_DO=2;
      IP_PMTUDISC_PROBE=3;
      IP_PMTUDISC_INTERFACE=4;
      IP_PMTUDISC_OMIT=5;
{$elseif defined(AIX)}
      IP_DONTFRAG=25;
{$elseif defined(Solaris)}
      IP_DONTFRAG=27;
{$elseif defined(Darwin)}
      IP_DONTFRAG=67; // TODO: Check
{$elseif defined(NetBSD)}
      IP_DONTFRAG=$4000;
{$elseif defined(BSD) or defined(FreeBSD)}
      IP_DONTFRAG=67;
{$ifend}

{$ifndef fpc}
{$if defined(Linux) or defined(Android)}
     FIONREAD=$541b;
     FIONBIO=$5421;
     FIOASYNC=$5452;
{$else}
     FIONBIO=$8004667e;
     FIOASYNC=$8004667d;
{$ifend}
{$endif}

type PSockaddrStorage=^TSockaddrStorage;
     TSockaddrStorage=record
      ss_family:TRNLUInt16;
      _ss_pad1:array[0..5] of TRNLUInt8;
      _ss_align:TRNLInt64;
      _ss_pad2:array[0..119] of TRNLUInt8;
     end;

{$if defined(Posix)}
     TAddrInfo=AddrInfo;
{$ifend}

class procedure TRNLInstance.GlobalInitialize;
begin
end;

class procedure TRNLInstance.GlobalFinalize;
begin
end;

function TRNLInstance.GetTime:TRNLTime;
{$if defined(fpc)}
{$if defined(linux) or defined(android)}
var NowTimeSpec:TimeSpec;
    ia,ib:TRNLInt64;
begin
 clock_gettime(CLOCK_MONOTONIC,@NowTimeSpec);
 ia:=TRNLInt64(NowTimeSpec.tv_sec)*TRNLInt64(1000);
 ib:=NowTimeSpec.tv_nsec div TRNLInt64(1000000);
 result:=(ia+ib)-fTimeBase;
end;
{$else}
var tv:TTimeVal;
begin
 fpgettimeofday(@tv,nil);
 result:=((TRNLUInt64(tv.tv_sec)*1000)+(TRNLUInt64(tv.tv_usec) div 1000))-fTimeBase;
end;
{$ifend}
{$else}
{$if defined(linux) or defined(android)}
var NowTimeSpec:TimeSpec;
begin
 clock_gettime(CLOCK_MONOTONIC,@NowTimeSpec);
 result:=((NowTimeSpec.tv_sec*TRNLInt64(1000))+(NowTimeSpec.tv_nsec div 1000000))-fTimeBase;
end;
{$else}
var tv:TimeVal;
begin
 gettimeofday(tv,nil);
 result:=((TRNLUInt64(tv.tv_sec)*1000)+(TRNLUInt64(tv.tv_usec) div 1000))-fTimeBase;
end;
{$ifend}
{$ifend}

procedure TRNLInstance.SetTime(const aTimeBase:TRNLTime);
begin
 fTimeBase:=(GetTime+fTimeBase)-aTimeBase;
end;

function TRNLAddressFamilyHelper.GetAddressFamily:TRNLUInt16;
begin
 case self of
  RNL_IPV4:begin
   result:=AF_INET;
  end;
  RNL_IPV6:begin
   result:=AF_INET6;
  end;
  else begin
   result:=0;
  end;
 end;
end;

function TRNLAddressFamilyHelper.GetSockAddrSize:TRNLInt32;
begin
 case self of
  RNL_IPV4:begin
   result:=SizeOf(sockaddr_in);
  end;
  RNL_IPV6:begin
   result:=SizeOf(sockaddr_in6);
  end;
  else begin
   result:=0;
  end;
 end;
end;

function TRNLAddress.SetAddress(const aSIN:TRNLPointer):TRNLAddressFamily;
begin
 FillChar(self,SizeOf(TRNLAddress),#0);
 case Psockaddr_in(aSIN)^.sin_family of
  AF_INET:begin
   Host:=TRNLHostAddress.CreateFromIPV4(Psockaddr_in(aSIN)^.sin_addr.S_addr);
   ScopeID:=0;
   Port:=TRNLEndianness.NetToHost16(Psockaddr_in(aSIN)^.sin_port);
   result:=RNL_IPV4;
  end;
  AF_INET6:begin
   Host:=PRNLHostAddress(TRNLPointer(@Psockaddr_in6(aSIN)^.sin6_addr))^;
   ScopeID:=Psockaddr_in6(aSIN)^.sin6_scope_id;
   Port:=TRNLEndianness.NetToHost16(Psockaddr_in6(aSIN)^.sin6_port);
   result:=RNL_IPV6;
  end;
  else begin
   result:=RNL_NO_ADDRESS_FAMILY;
  end;
 end;
end;

function TRNLAddress.SetSIN(const aSIN:TRNLPointer;const aFamily:TRNLAddressFamily):boolean;
begin
 FillChar(aSIN^,aFamily.GetSockAddrSize,#0);
 if (aFamily=RNL_IPV4) and
    ((GetAddressFamily=RNL_IPV4) or
     ((Host.Addr[0]=RNL_HOST_ANY.Addr[0]) and
      (Host.Addr[1]=RNL_HOST_ANY.Addr[1]) and
      (Host.Addr[2]=RNL_HOST_ANY.Addr[2]) and
      (Host.Addr[3]=RNL_HOST_ANY.Addr[3]) and
      (Host.Addr[4]=RNL_HOST_ANY.Addr[4]) and
      (Host.Addr[5]=RNL_HOST_ANY.Addr[5]) and
      (Host.Addr[6]=RNL_HOST_ANY.Addr[6]) and
      (Host.Addr[7]=RNL_HOST_ANY.Addr[7]) and
      (Host.Addr[8]=RNL_HOST_ANY.Addr[8]) and
      (Host.Addr[9]=RNL_HOST_ANY.Addr[9]) and
      (Host.Addr[10]=RNL_HOST_ANY.Addr[10]) and
      (Host.Addr[11]=RNL_HOST_ANY.Addr[11]) and
      (Host.Addr[12]=RNL_HOST_ANY.Addr[12]) and
      (Host.Addr[13]=RNL_HOST_ANY.Addr[13]) and
      (Host.Addr[14]=RNL_HOST_ANY.Addr[14]) and
      (Host.Addr[15]=RNL_HOST_ANY.Addr[15]))) then begin
  Psockaddr_in(aSIN)^.sin_family:=AF_INET;
  Psockaddr_in(aSIN)^.sin_addr.S_addr:=TRNLUInt32(TRNLPointer(@Host.Addr[12])^);
  Psockaddr_in(aSIN)^.sin_port:=TRNLEndianness.HostToNet16(Port);
  result:=true;
 end else if aFamily=RNL_IPV6 then begin
  Psockaddr_in6(aSIN)^.sin6_family:=AF_INET6;
  PRNLHostAddress(TRNLPointer(@Psockaddr_in6(aSIN)^.sin6_addr))^:=Host;
  Psockaddr_in6(aSIN)^.sin6_scope_id:=ScopeID;
  Psockaddr_in6(aSIN)^.sin6_port:=TRNLEndianness.HostToNet16(Port);
  result:=true;
 end else begin
  result:=false;
 end;
end;

{$else}
const AF_UNSPEC=0;
      AF_INET=2;
      AF_INET6=23;
      AF_MAX=24;

      AI_ADDRCONFIG=$400;

      NI_NUMERICHOST=$2;

      IPPROTO_IP=0;
      IPPROTO_TCP=6;
      IPPROTO_UDP=17;
      IPPROTO_IPV6=41;

      IPV6_V6ONLY=26;

      WSADESCRIPTION_LEN=256;
      WSASYS_STATUS_LEN=128;

      SOCKET_ERROR=-1;

      SOMAXCONN=$7fffffff;

      SOCK_STREAM=1;
      SOCK_DGRAM=2;
      SOCK_RAW=3;
      SOCK_RDM=4;
      SOCK_SEQPACKET=5;

      IOC_IN=$80000000;

      FIONBIO=IOC_IN or (SizeOf(TRNLInt32) shl 16) or (Ord('f') shl 8) or 126;

      SOL_SOCKET=$ffff;

      SO_DEBUG=$0001;
      SO_ACCEPTCONN=$0002;
      SO_REUSEADDR=$0004;
      SO_KEEPALIVE=$0008;
      SO_DONTROUTE=$0010;
      SO_BROADCAST=$0020;
      SO_USELOOPBACK=$0040;
      SO_LINGER=$0080;
      SO_OOBINLINE=$0100;
      SO_DONTLINGER=not SO_LINGER;
      SO_EXCLUSIVEADDRUSE=not SO_REUSEADDR;
      SO_SNDBUF=$1001;
      SO_RCVBUF=$1002;      
      SO_SNDLOWAT=$1003;      
      SO_RCVLOWAT=$1004;      
      SO_SNDTIMEO=$1005;
      SO_RCVTIMEO=$1006;      
      SO_ERROR=$1007;
      SO_TYPE=$1008;
      SO_CONNDATA=$7000;
      SO_CONNOPT=$7001;
      SO_DISCDATA=$7002;
      SO_DISCOPT=$7003;
      SO_CONNDATALEN=$7004;
      SO_CONNOPTLEN=$7005;
      SO_DISCDATALEN=$7006;
      SO_DISCOPTLEN=$7007;
      SO_OPENTYPE=$7008;
      SO_SYNCHRONOUS_ALERT=$10;
      SO_SYNCHRONOUS_NONALERT=$20;
      SO_MAXDG=$7009;
      SO_MAXPATHDG=$700A;
      SO_UPDATE_ACCEPT_CONTEXT=$700B;
      SO_CONNECT_TIME=$700C;
      TCP_NODELAY=$0001;
      TCP_BSDURGENT=$7000;
      SO_GROUP_ID=$2001;
      SO_GROUP_PRIORITY=$2002;
      SO_MAX_MSG_SIZE=$2003;
      SO_PROTOCOL_INFOA=$2004;
      SO_PROTOCOL_INFOW=$2005;
      SO_PROTOCOL_INFO=SO_PROTOCOL_INFOA;
      PVD_CONFIG=$3001;
      SO_CONDITIONAL_ACCEPT=$3002;

      IP_DONTFRAGMENT=14;

      IP_DONTFRAG=$1023;

      WSABASEERR=10000;

      WSAEINTR=WSABASEERR+4;
      WSAEBADF=WSABASEERR+9;
      WSAEACCES=WSABASEERR+13;
      WSAEFAULT=WSABASEERR+14;
      WSAEINVAL=WSABASEERR+22;
      WSAEMFILE=WSABASEERR+24;
      WSAEWOULDBLOCK=WSABASEERR+35;
      WSAEINPROGRESS=WSABASEERR+36;
      WSAEALREADY=WSABASEERR+37;
      WSAENOTSOCK=WSABASEERR+38;
      WSAEDESTADDRREQ=WSABASEERR+39;
      WSAEMSGSIZE=WSABASEERR+40;
      WSAEPROTOTYPE=WSABASEERR+41;
      WSAENOPROTOOPT=WSABASEERR+42;
      WSAEPROTONOSUPPORT=WSABASEERR+43;
      WSAESOCKTNOSUPPORT=WSABASEERR+44;
      WSAEOPNOTSUPP=WSABASEERR+45;
      WSAEPFNOSUPPORT=WSABASEERR+46;
      WSAEAFNOSUPPORT=WSABASEERR+47;
      WSAEADDRINUSE=WSABASEERR+48;
      WSAEADDRNOTAVAIL=WSABASEERR+49;
      WSAENETDOWN=WSABASEERR+50;
      WSAENETUNREACH=WSABASEERR+51;
      WSAENETRESET=WSABASEERR+52;
      WSAECONNABORTED=WSABASEERR+53;
      WSAECONNRESET=WSABASEERR+54;
      WSAENOBUFS=WSABASEERR+55;
      WSAEISCONN=WSABASEERR+56;
      WSAENOTCONN=WSABASEERR+57;
      WSAESHUTDOWN=WSABASEERR+58;
      WSAETOOMANYREFS=WSABASEERR+59;
      WSAETIMEDOUT=WSABASEERR+60;
      WSAECONNREFUSED=WSABASEERR+61;
      WSAELOOP=WSABASEERR+62;
      WSAENAMETOOLONG=WSABASEERR+63;
      WSAEHOSTDOWN=WSABASEERR+64;
      WSAEHOSTUNREACH=WSABASEERR+65;
      WSAENOTEMPTY=WSABASEERR+66;
      WSAEPROCLIM=WSABASEERR+67;
      WSAEUSERS=WSABASEERR+68;
      WSAEDQUOT=WSABASEERR+69;
      WSAESTALE=WSABASEERR+70;
      WSAEREMOTE=WSABASEERR+71;
      WSASYSNOTREADY=WSABASEERR+91;
      WSAVERNOTSUPPORTED=WSABASEERR+92;
      WSANOTINITIALISED=WSABASEERR+93;
      WSAEDISCON=WSABASEERR+101;
      WSAENOMORE=WSABASEERR+102;
      WSAECANCELLED=WSABASEERR+103;
      WSAEINVALIDPROCTABLE=WSABASEERR+104;
      WSAEINVALIDPROVIDER=WSABASEERR+105;
      WSAEPROVIDERFAILEDINIT=WSABASEERR+106;
      WSASYSCALLFAILURE=WSABASEERR+107;
      WSASERVICE_NOT_FOUND=WSABASEERR+108;
      WSATYPE_NOT_FOUND=WSABASEERR+109;
      WSA_E_NO_MORE=WSABASEERR+110;
      WSA_E_CANCELLED=WSABASEERR+111;
      WSAEREFUSED=WSABASEERR+112;

      MSG_PARTIAL=$8000;

      WSA_WAIT_EVENT_0=WAIT_OBJECT_0;

      WSA_WAIT_TIMEOUT=WAIT_TIMEOUT;

      WSA_WAIT_IO_COMPLETION=WAIT_IO_COMPLETION;

      WSA_WAIT_FAILED=WAIT_FAILED;

      WSA_INVALID_EVENT=0;

      FD_READ_BIT=0;
      FD_READ=1;
      FD_WRITE_BIT=1;
      FD_WRITE=2;
      FD_OOB_BIT=2;
      FD_OOB=4;
      FD_ACCEPT_BIT=3;
      FD_ACCEPT=8;
      FD_CONNECT_BIT=4;
      FD_CONNECT=16;
      FD_CLOSE_BIT=5;
      FD_CLOSE=32;
      FD_QOS_BIT=6;
      FD_QOS=64;
      FD_GROUP_QOS_BIT=7;
      FD_GROUP_QOS=128;
      FD_ROUTING_INTERFACE_CHANGE_BIT=8;
      FD_ROUTING_INTERFACE_CHANGE=256;
      FD_ADDRESS_LIST_CHANGE_BIT=9;
      FD_ADDRESS_LIST_CHANGE=512;
      FD_MAX_EVENTS=10;

      POLLRDNORM=1 shl 0;
      POLLWRNORM=1 shl 1;
      POLLPRI=1 shl 2;
      POLLNVAL=1 shl 3;
      POLLERR=1 shl 4;
      POLLHUP=1 shl 5;
      POLLIN=1 shl 6;
      POLLOUT=1 shl 7;

type TInAddr=record
      case TRNLInt32 of
       0:(
        S_bytes:array[0..3] of TRNLUInt8;
       );
       1:(
        S_addr:TRNLUInt32;
       );
     end;

     PSockAddrIn=^TSockAddrIn;
     TSockAddrIn=packed record
      case TRNLInt32 of
       0:(
        sin_family:TRNLUInt16;
        sin_port:TRNLUInt16;
        sin_addr:TInAddr;
        sin_zero:array[0..7] of TRNLUInt8;
       );
       1:(
        sa_family:TRNLUInt16;
        sa_data:array[0..13] of TRNLUInt8;
       );
     end;

     PInAddr6=^TInAddr6;
     TInAddr6=record
      case TRNLUInt8 of
       0:(
        s6_addr:array[0..15] of TRNLInt8;
       );
       1:(
        u6_addr8:array[0..15] of TRNLUInt8;
       );
       2:(
        u6_addr16:array[0..7] of TRNLUInt16;
       );
       3:(
        u6_addr32:array[0..3] of TRNLUInt32;
       );
       4:(
        u6_addr64:array[0..1] of TRNLUInt64;
       );
     end;

     PSockAddrIn6=^TSockAddrIn6;
     TSockAddrIn6=record
      sin6_family:TRNLUInt16;
      sin6_port:TRNLUInt16;
      sin6_flowinfo:TRNLUInt32;
      sin6_addr:TInAddr6;
      sin6_scope_id:TRNLUInt32;
     end;

     PSockAddr=^TSockAddr;
     TSockAddr=TSockAddrIn;

     PPAddrInfo=^PAddrInfo;
     PAddrInfo=^TAddrInfo;
     TAddrInfo=record
      ai_flags:TRNLInt32;
      ai_family:TRNLInt32;
      ai_socktype:TRNLInt32;
      ai_protocol:TRNLInt32;
      ai_addrlen:TRNLSizeInt;
      ai_canonname:PAnsiChar;
      ai_addr:PSockAddr;
      ai_next:PAddrInfo;
     end;

     PSockaddrStorage=^TSockaddrStorage;
     TSockaddrStorage=record
      ss_family:TRNLUInt16;
      _ss_pad1:array[0..5] of TRNLUInt8;
      _ss_align:TRNLInt64;
      _ss_pad2:array[0..119] of TRNLUInt8;
     end;

     PWSAData=^TWSAData;
     TWSAData=packed record
      wVersion:TRNLUInt16;
      wHighVersion:TRNLUInt16;
      szDescription:array[0..WSADESCRIPTION_LEN] of AnsiChar;
      szSystemStatus:array[0..WSASYS_STATUS_LEN] of AnsiChar;
      iMaxSockets:TRNLUInt16;
      iMaxUdpDg:TRNLUInt16;
      lpVendorInfo:PAnsiChar;
     end;

     PWSABUF=^TWSABUF;
     LPWSABUF=PWSABUF;
     TWSABUF=record
      len:TRNLUInt32;
      buf:PRNLUInt8Array;
     end;

     PWSAOverlapped=^WSAOverlapped;
     LPWSAOVERLAPPED=PWSAOverlapped;
     WSAOVERLAPPED=TOverlapped;
     TWSAOverlapped=WSAOverlapped;

     TGetAddrInfo=function(NodeName:PAnsiChar;ServName:PAnsiChar;Hints:PAddrInfo;Addrinfo:PPAddrInfo):TRNLInt32; stdcall;
     TFreeAddrInfo=procedure(ai:PAddrInfo); stdcall;
     TGetNameInfo=function(Addr:PSockAddr;namelen:TRNLUInt32;Host:PAnsiChar;hostlen:TRNLUInt32;serv:PAnsiChar;servlen:TRNLUInt32;Flags:TRNLInt32):TRNLInt32; stdcall;

     LPWSAOVERLAPPED_COMPLETION_ROUTINE=procedure(const dwError,cbTransferred:TRNLUInt32;
                                                  const lpOverlapped:LPWSAOVERLAPPED;
                                                  const dwFlags:TRNLUInt32); stdcall;


     PTimeVal=^TTimeVal;
     TTimeVal=packed record
      tv_sec:TRNLInt32;
      tv_usec:TRNLInt32;
     end;

     TWSAEvent=THandle;

     PWSANETWORKEVENTS=^TWSANETWORKEVENTS;
     TWSANETWORKEVENTS=packed record
      lNetworkEvents:TRNLUInt32;
      iErrorCode:array[0..FD_MAX_EVENTS-1] of TRNLInt32;
     end;


     TQueryUnbiasedInterruptTime=function(var lpUnbiasedInterruptTime:TRNLUInt64):bool; stdcall;

const GetAddrInfo:TGetAddrInfo=nil;
      FreeAddrInfo:TFreeAddrInfo=nil;
      GetNameInfo:TGetNameInfo=nil;
      QueryUnbiasedInterruptTime:TQueryUnbiasedInterruptTime=nil;

      WinSock2LibHandle:THandle=0;
      Kernel32LibHandle:THandle=0;

      QueryPerformanceFrequencyBase:TRNLUInt64=0;
      QueryPerformanceFrequencyShift:TRNLInt32=0;

function GetTickCount64:TRNLUInt64; stdcall; external 'kernel32.dll' name 'GetTickCount64';

function WSAStartup(wVersionRequired:TRNLUInt16;var WSData:TWSAData):TRNLInt32; stdcall; external 'ws2_32.dll' name 'WSAStartup';
function WSACleanup:TRNLInt32; stdcall; external 'ws2_32.dll' name 'WSACleanup';
function _bind(const s:TRNLSocket;const addr:PSockAddr;const namelen:TRNLInt32):TRNLInt32; stdcall; external 'ws2_32.dll' name 'bind';
function getsockname(const s:TRNLSocket;var name:TSockAddr;var namelen:TRNLInt32):TRNLInt32; stdcall; external 'ws2_32.dll' name 'getsockname';
function _listen(s:TrNLSocket;backlog:TRNLInt32):TRNLInt32; stdcall; external 'ws2_32.dll' name 'listen';
function _socket(const af,struct,protocol:TRNLInt32):TRNLSocket; stdcall; external 'ws2_32.dll' name 'socket';
function ioctlsocket(const s:TRNLSocket;const cmd:TRNLUInt32;var arg:TRNLUInt32):TRNLInt32; stdcall; external 'ws2_32.dll' name 'ioctlsocket';
function setsockopt(s:TRNLSocket;level,optname:TRNLInt32;optval:PAnsiChar;optlen:TRNLInt32):TRNLInt32; stdcall; external 'ws2_32.dll' name 'setsockopt';
function _shutdown(s:TRNLSocket;how:TRNLInt32):TRNLInt32; stdcall; external 'ws2_32.dll' name 'shutdown';
function _connect(const s:TRNLSocket;const name:PSockAddr;namelen:TRNLInt32):TRNLInt32; stdcall; external 'ws2_32.dll' name 'connect';
function WSAGetLastError:TRNLInt32; stdcall; external 'ws2_32.dll' name 'WSAGetLastError';
function _accept(const s:TRNLSocket;var addr:TSockAddr;var addrlen:TRNLInt32):TRNLSocket; stdcall; external 'ws2_32.dll' name 'accept';
function closesocket(const s:TRNLSocket):TRNLInt32; stdcall; external 'ws2_32.dll' name 'closesocket';
function WSASendTo(s:TRNLSocket;
                   lpBuffers:LPWSABUF;
                   dwBufferCount:TRNLUInt32;
                   var lpNumberOfBytesSent:TRNLUInt32;
                   dwFlags:DWORD;
                   lpTo:PSockAddr;
                   iToLen:TRNLInt32;
                   lpOverlapped:LPWSAOVERLAPPED;
                   lpCompletionRoutine:LPWSAOVERLAPPED_COMPLETION_ROUTINE):TRNLInt32; stdcall; external 'ws2_32.dll' name 'WSASendTo';
function WSARecvFrom(s:TRNLSocket;
                     lpBuffers:LPWSABUF;
                     dwBufferCount:TRNLUInt32;
                     var lpNumberOfBytesRecvd:TRNLUInt32;
                     var lpFlags:TRNLUInt32;
                     lpFrom:PSockAddr;
                     lpFromLen:PRNLInt32;
                     lpOverlapped:LPWSAOVERLAPPED;
                     lpCompletionRoutine:LPWSAOVERLAPPED_COMPLETION_ROUTINE):TRNLInt32; stdcall; external 'ws2_32.dll' name 'WSARecvFrom';
function _select(nfds:TRNLInt32;readfds,writefds,exceptfds:PRNLSocketSet;timeout:PTimeVal):TRNLInt32; stdcall; external 'ws2_32.dll' name 'select';

function WSACreateEvent:TWSAEvent; stdcall; external 'ws2_32.dll' name 'WSACreateEvent';
function WSACloseEvent(hEvent:TWSAEvent):bool; stdcall; external 'ws2_32.dll' name 'WSACloseEvent';
function WSAResetEvent(hEvent:TWSAEvent):bool;stdcall; external 'ws2_32.dll' name 'WSAResetEvent';
function WSASetEvent(hEvent:TWSAEvent):bool;stdcall; external 'ws2_32.dll' name 'WSASetEvent';
function WSAEventSelect(s:TRNLSocket;hEventObject:TWSAEvent;lNetworkEvents:TRNLInt32):TRNLInt32; stdcall; external 'ws2_32.dll' name 'WSAEventSelect';
function WSAWaitForMultipleEvents(cEvents:TRNLUInt32;lphEvents:TRNLPointer;fWaitAll:bool;dwTimeOut:TRNLUInt32;fAlertable:bool):TRNLUInt32; stdcall; external 'ws2_32.dll' name 'WSAWaitForMultipleEvents';
function WSAEnumNetworkEvents(s:TRNLSocket;hEventObject:TWSAEvent;lphNetworkEvents:TRNLPointer):TRNLInt32; stdcall; external 'ws2_32.dll' name 'WSAEnumNetworkEvents';

function QueryPerformanceCounter(out lpPerformanceCount:TRNLUInt64):bool; stdcall; external kernel32 name 'QueryPerformanceCounter';
function QueryPerformanceFrequency(out lpFrequency:TRNLUInt64):bool; stdcall; external kernel32 name 'QueryPerformanceFrequency';

class procedure TRNLInstance.GlobalInitialize;
begin
 Kernel32LibHandle:=LoadLibrary(PChar('kernel32.dll'));
 if Kernel32LibHandle=0 then begin
  WSACleanup;
  raise ERNLInstance.Create('Incompatible system version');
 end;
 QueryUnbiasedInterruptTime:=GetProcAddress(Kernel32LibHandle,PAnsiChar(AnsiString('QueryUnbiasedInterruptTime')));
 if QueryPerformanceFrequency(QueryPerformanceFrequencyBase) then begin
  if QueryPerformanceFrequencyBase=1000 then begin
   QueryPerformanceFrequencyBase:=0;
  end else begin
   QueryPerformanceFrequencyShift:=0;
   while (QueryPerformanceFrequencyBase>1) and ((QueryPerformanceFrequencyBase and 1)=0) do begin
    QueryPerformanceFrequencyBase:=QueryPerformanceFrequencyBase shr 1;
    inc(QueryPerformanceFrequencyShift);
   end;
  end;
 end else begin
  QueryPerformanceFrequencyBase:=0;
 end;
 timeBeginPeriod(1);
end;

class procedure TRNLInstance.GlobalFinalize;
begin
 timeEndPeriod(1);
 FreeLibrary(Kernel32LibHandle);
end;

function TRNLInstance.GetTime:TRNLTime;
begin
 if assigned(QueryUnbiasedInterruptTime) and QueryUnbiasedInterruptTime(TRNLUInt64(result.fValue)) then begin
  result:=result div 10000;
 end else if (QueryPerformanceFrequencyBase<>0) and QueryPerformanceCounter(TRNLUInt64(result.fValue)) then begin
  result:=(((result.fValue shr QueryPerformanceFrequencyShift)*1000) div QueryPerformanceFrequencyBase)-fTimeBase;
 end else begin
  result:=GetTickCount64-fTimeBase;
//result:=timeGetTime-fTimeBase;
 end;
end;

procedure TRNLInstance.SetTime(const aTimeBase:TRNLTime);
begin
 fTimeBase:=(GetTime+fTimeBase)-aTimeBase;
end;

function TRNLAddressFamilyHelper.GetAddressFamily:TRNLUInt16;
begin
 case self of
  RNL_IPV4:begin
   result:=AF_INET;
  end;
  RNL_IPV6:begin
   result:=AF_INET6;
  end;
  else begin
   result:=0;
  end;
 end;
end;

function TRNLAddressFamilyHelper.GetSockAddrSize:TRNLInt32;
begin
 case self of
  RNL_IPV4:begin
   result:=SizeOf(TSockAddrIn);
  end;
  RNL_IPV6:begin
   result:=SizeOf(TSockAddrIn6);
  end;
  else begin
   result:=0;
  end;
 end;
end;

function TRNLAddress.SetAddress(const aSIN:TRNLPointer):TRNLAddressFamily;
begin
 FillChar(self,SizeOf(TRNLAddress),AnsiChar(#0));
 case PSockAddrIn(aSIN)^.sin_family of
  AF_INET:begin
   Host:=TRNLHostAddress.CreateFromIPV4(PSockAddrIn(aSIN)^.sin_addr.S_addr);
   ScopeID:=0;
   Port:=TRNLEndianness.NetToHost16(PSockAddrIn(aSIN)^.sin_port);
   result:=RNL_IPV4;
  end;
  AF_INET6:begin
   Host:=PRNLHostAddress(TRNLPointer(@PSockAddrIn6(aSIN)^.sin6_addr))^;
   ScopeID:=PSockAddrIn6(aSIN)^.sin6_scope_id;
   Port:=TRNLEndianness.NetToHost16(PSockAddrIn6(aSIN)^.sin6_port);
   result:=RNL_IPV6;
  end;
  else begin
   result:=RNL_NO_ADDRESS_FAMILY;
  end;
 end;
end;

function TRNLAddress.SetSIN(const aSIN:TRNLPointer;const aFamily:TRNLAddressFamily):boolean;
begin
 FillChar(aSIN^,aFamily.GetSockAddrSize,AnsiChar(#0));
 if (aFamily=RNL_IPV4) and
    ((GetAddressFamily=RNL_IPV4) or
     ((Host.Addr[0]=RNL_HOST_ANY.Addr[0]) and
      (Host.Addr[1]=RNL_HOST_ANY.Addr[1]) and
      (Host.Addr[2]=RNL_HOST_ANY.Addr[2]) and
      (Host.Addr[3]=RNL_HOST_ANY.Addr[3]) and
      (Host.Addr[4]=RNL_HOST_ANY.Addr[4]) and
      (Host.Addr[5]=RNL_HOST_ANY.Addr[5]) and
      (Host.Addr[6]=RNL_HOST_ANY.Addr[6]) and
      (Host.Addr[7]=RNL_HOST_ANY.Addr[7]) and
      (Host.Addr[8]=RNL_HOST_ANY.Addr[8]) and
      (Host.Addr[9]=RNL_HOST_ANY.Addr[9]) and
      (Host.Addr[10]=RNL_HOST_ANY.Addr[10]) and
      (Host.Addr[11]=RNL_HOST_ANY.Addr[11]) and
      (Host.Addr[12]=RNL_HOST_ANY.Addr[12]) and
      (Host.Addr[13]=RNL_HOST_ANY.Addr[13]) and
      (Host.Addr[14]=RNL_HOST_ANY.Addr[14]) and
      (Host.Addr[15]=RNL_HOST_ANY.Addr[15]))) then begin
  PSockAddrIn(aSIN)^.sin_family:=AF_INET;
  PSockAddrIn(aSIN)^.sin_addr.S_addr:=TRNLUInt32(TRNLPointer(@Host.Addr[12])^);
  PSockAddrIn(aSIN)^.sin_port:=TRNLEndianness.HostToNet16(Port);
  result:=true;
 end else if aFamily=RNL_IPV6 then begin
  PSockAddrIn6(aSIN)^.sin6_family:=AF_INET6;
  PRNLHostAddress(TRNLPointer(@PSockAddrIn6(aSIN)^.sin6_addr))^:=Host;
  PSockAddrIn6(aSIN)^.sin6_scope_id:=ScopeID;
  PSockAddrIn6(aSIN)^.sin6_port:=TRNLEndianness.HostToNet16(Port);
  result:=true;
 end else begin
  result:=false;
 end;
end;

{$ifend}

{$if defined(Windows)}
type HCRYPTPROV=PRNLUInt32;

const PROV_RSA_FULL=1;
      CRYPT_VERIFYCONTEXT=$f0000000;
      CRYPT_SILENT=$00000040;
      CRYPT_NEWKEYSET=$00000008;

function CryptAcquireContext(var phProv:HCRYPTPROV;pszContainer:PAnsiChar;pszProvider:PAnsiChar;dwProvType:TRNLUInt32;dwFlags:TRNLUInt32):LONGBOOL; stdcall; external advapi32 name 'CryptAcquireContextA';
function CryptReleaseContext(hProv:HCRYPTPROV;dwFlags:TRNLUInt32):BOOL; stdcall; external advapi32 name 'CryptReleaseContext';
function CryptGenRandom(hProv:HCRYPTPROV;dwLen:TRNLUInt32;pbBuffer:Pointer):BOOL; stdcall; external advapi32 name 'CryptGenRandom';

function CoCreateGuid(var aGuid:TGUID):HResult; stdcall; external 'ole32.dll';
{$ifend}

constructor TRNLRandomGenerator.Create;
begin
 inherited Create;
{$if defined(Windows)}
 fWindowsCryptProviderInitialized:=false;
 if CryptAcquireContext(HCRYPTPROV(fWindowsCryptProvider),nil,nil,PROV_RSA_FULL,CRYPT_VERIFYCONTEXT) then begin
  fWindowsCryptProviderInitialized:=true;
 end else if GetLastError=TRNLUInt32(NTE_BAD_KEYSET) then begin
  if CryptAcquireContext(HCRYPTPROV(fWindowsCryptProvider),nil,nil,PROV_RSA_FULL,CRYPT_NEWKEYSET) then begin
   fWindowsCryptProviderInitialized:=true;
  end;
 end;
{$ifend}
 fPosition:=0;
 fHave:=0;
 fInitialized:=false;
 fGuassianFloatUseLast:=false;
 fGuassianDoubleUseLast:=false;
end;

destructor TRNLRandomGenerator.Destroy;
begin
{$if defined(Windows)}
 if fWindowsCryptProviderInitialized then begin
  fWindowsCryptProviderInitialized:=false;
  CryptReleaseContext(HCRYPTPROV(fWindowsCryptProvider),0);
 end;
{$ifend}
 inherited Destroy;
end;

procedure TRNLRandomGenerator.Initialize(const aData;const aDataLength:TRNLSizeUInt);
begin
 if aDataLength>=SizeOf(TRNLRandomGeneratorSeed) then begin
  fChaCha20Context.XChaCha20Initialize(PRNLRandomGeneratorSeed(TRNLPointer(@aData))^.Key,
                                       PRNLRandomGeneratorSeed(TRNLPointer(@aData))^.Nonce,
                                       0);
 end;
end;

procedure TRNLRandomGenerator.Rekey(const aData;const aDataLength:TRNLSizeUInt);
var Index,Len:TRNLSizeUInt;
begin
 fChaCha20Context.Process(fBuffer,fBuffer,SizeOf(TRNLRandomGeneratorBuffer));
 if aDataLength>0 then begin
  if TRNLSizeUInt(aDataLength)<TRNLSizeUInt(SizeOf(TRNLRandomGeneratorSeed)) then begin
   Len:=TRNLSizeUInt(aDataLength);
  end else begin
   Len:=TRNLSizeUInt(SizeOf(TRNLRandomGeneratorSeed));
  end;
  for Index:=1 to Len do begin
   fBuffer[Index]:=fBuffer[Index] xor PRNLUInt8Array(TRNLPointer(@aData))^[Index];
  end;
 end;
 Initialize(fBuffer[0],SizeOf(TRNLRandomGeneratorSeed));
 FillChar(fBuffer[0],SizeOf(TRNLRandomGeneratorSeed),#0);
 fPosition:=SizeOf(TRNLRandomGeneratorSeed);
 fHave:=SizeOf(TRNLRandomGeneratorBuffer)-SizeOf(TRNLRandomGeneratorSeed);
end;

procedure TRNLRandomGenerator.Reseed;
var EntropyData:TRNLRandomGeneratorEntropyData;
 procedure GetEntropyData;
{$if defined(Windows)}
  function WindowsGetEntropyData(out aBuffer;const aSize:TRNLSizeUInt):boolean;
  begin
   if fWindowsCryptProviderInitialized then begin
    FillChar(aBuffer,aSize,#0);
    result:=CryptGenRandom(HCRYPTPROV(fWindowsCryptProvider),aSize,@aBuffer);
   end else begin
    result:=false;
   end;
  end;
  function WindowsEnvironmentStringsGetEntropyData(out aBuffer;const aSize:TRNLSizeUInt):boolean;
  var Index,SubIndex:TRNLSizeUInt;
      HashState:TRNLUInt64;
      pp,p:PWideChar;
  begin
   result:=false;
   HashState:=TRNLUInt64(4695981039346656037);
   pp:=GetEnvironmentStringsW;
   if assigned(pp) then begin
    p:=pp;
    try
     FillChar(aBuffer,aSize,#0);
     Index:=0;
     while assigned(p) and (p^<>#0) do begin
      while assigned(p) and (p^<>#0) do begin
       HashState:=(HashState xor TRNLUInt16(WideChar(p^)))*TRNLUInt64(1099511628211);
       for SubIndex:=0 to SizeOf(TRNLUInt64)-1 do begin
        PRNLUInt8Array(TRNLPointer(@aBuffer))^[Index]:=HashState shr (SubIndex shl 3);
        inc(Index);
        if Index>=aSize then begin
         Index:=0;
        end;
       end;
       inc(p);
      end;
      inc(p);
     end;
     result:=true;
    finally
     FreeEnvironmentStringsW(TRNLPointer(p));
    end;
   end;
  end;
  function WindowsCommandLineGetEntropyData(out aBuffer;const aSize:TRNLSizeUInt):boolean;
  var Index,SubIndex:TRNLSizeUInt;
      HashState:TRNLUInt64;
      pp,p:PWideChar;
  begin
   result:=false;
   HashState:=TRNLUInt64(91734284728269012);
   pp:=GetCommandLineW;
   if assigned(pp) then begin
    p:=pp;
    try
     FillChar(aBuffer,aSize,#0);
     Index:=0;
     while assigned(p) and (p^<>#0) do begin
      while assigned(p) and (p^<>#0) do begin
       HashState:=(HashState xor TRNLUInt16(WideChar(p^)))*TRNLUInt64(1099511628211);
       for SubIndex:=0 to SizeOf(TRNLUInt64)-1 do begin
        PRNLUInt8Array(TRNLPointer(@aBuffer))^[Index]:=HashState shr (SubIndex shl 3);
        inc(Index);
        if Index>=aSize then begin
         Index:=0;
        end;
       end;
       inc(p);
      end;
      inc(p);
     end;
     result:=true;
    finally
     FreeEnvironmentStringsW(TRNLPointer(p));
    end;
   end;
  end;
{$elseif defined(Unix) or defined(Posix)}
  function PosixGetEntropyData(out aBuffer;const aSize:TRNLInt32):boolean;
  const Paths:array[0..2] of string=('/dev/srandom','/dev/urandom','/dev/random');
  var Index:TRNLSizeUInt;
      Path:string;
 {$ifdef fpc}
      fd:TRNLInt32;
 {$else}
      FileStream:TFileStream;
 {$endif}
  begin
   result:=false;
   FillChar(aBuffer,aSize,#0);
   for Index:=low(Paths) to high(Paths) do begin
    Path:=Paths[Index];
    try
 {$ifdef fpc}
     fd:=fpopen(Path,O_RDONLY);
     if fd>=0 then begin
      try
       result:=fpread(fd,aBuffer,aSize)=aSize;
      finally
       fpclose(fd);
      end;
     end;
 {$else}
     if FileExists(Path) then begin
      FileStream:=TFileStream.Create(Path,fmOpenRead or fmShareDenyNone);
      try
       result:=FileStream.Read(aBuffer,aSize)=aSize;
      finally
       FileStream.Free;
      end;
     end;
 {$endif}
    except
    end;
    if result then begin
     break;
    end;
   end;
  end;
{$ifend}
  function GetAdditionalEntropyData(out aBuffer;const aSize:TRNLInt32):boolean;
  type PRNLRandomGeneratorPCG32=^TRNLRandomGeneratorPCG32;
       TRNLRandomGeneratorPCG32=record
        State:TRNLUInt64;
        Increment:TRNLUInt64;
       end;
       PRNLRandomGeneratorSplitMix64=^TRNLRandomGeneratorSplitMix64;
       TRNLRandomGeneratorSplitMix64=TRNLUInt64;
       PRNLRandomGeneratorLCG64=^TRNLRandomGeneratorLCG64;
       TRNLRandomGeneratorLCG64=TRNLUInt64;
       PRNLRandomGeneratorMWC=^TRNLRandomGeneratorMWC;
       TRNLRandomGeneratorMWC=record
        x:TRNLUInt32;
        y:TRNLUInt32;
        c:TRNLUInt32;
       end;
       PRNLRandomGeneratorXorShift128=^TRNLRandomGeneratorXorShift128;
       TRNLRandomGeneratorXorShift128=record
        x,y,z,w:TRNLUInt32;
       end;
       PRNLRandomGeneratorXorShift128Plus=^TRNLRandomGeneratorXorShift128Plus;
       TRNLRandomGeneratorXorShift128Plus=record
        s:array[0..1] of TRNLUInt64;
       end;
       PRNLRandomGeneratorXorShift1024=^TRNLRandomGeneratorXorShift1024;
       TRNLRandomGeneratorXorShift1024=record
        s:array[0..15] of TRNLUInt64;
        p:TRNLInt32;
       end;
       PRNLRandomGeneratorCMWC4096=^TRNLRandomGeneratorCMWC4096;
       TRNLRandomGeneratorCMWC4096=record
        Q:array[0..4095] of TRNLUInt64;
        QC:TRNLUInt64;
        QJ:TRNLUInt64;
       end;
       PRNLRandomGeneratorState=^TRNLRandomGeneratorState;
       TRNLRandomGeneratorState=record
        LCG64:TRNLRandomGeneratorLCG64;
        XorShift1024:TRNLRandomGeneratorXorShift1024;
        CMWC4096:TRNLRandomGeneratorCMWC4096;
        PCG32:TRNLRandomGeneratorPCG32;
       end;
   function PCG32Next(var State:TRNLRandomGeneratorPCG32):TRNLUInt64; {$ifdef caninline}inline;{$endif}
   var OldState:TRNLUInt64;
       XorShifted,Rot:TRNLUInt32;
   begin
    OldState:=State.State;
    State.State:=(OldState*TRNLUInt64(6364136223846793005))+(State.Increment or 1);
    XorShifted:=TRNLUInt64((OldState shr 18) xor OldState) shr 27;
    Rot:=OldState shr 59;
    result:=(XorShifted shr rot) or (TRNLUInt64(XorShifted) shl ((-Rot) and 31));
   end;
   function SplitMix64Next(var State:TRNLRandomGeneratorSplitMix64):TRNLUInt64; {$ifdef caninline}inline;{$endif}
   var z:TRNLUInt64;
   begin
    State:=State+{$ifndef fpc}TRNLUInt64{$endif}($9e3779b97f4a7c15);
    z:=State;
    z:=(z xor (z shr 30))*{$ifndef fpc}TRNLUInt64{$endif}($bf58476d1ce4e5b9);
    z:=(z xor (z shr 27))*{$ifndef fpc}TRNLUInt64{$endif}($94d049bb133111eb);
    result:=z xor (z shr 31);
   end;
   function LCG64Next(var State:TRNLRandomGeneratorLCG64):TRNLUInt64; {$ifdef caninline}inline;{$endif}
   begin
    State:=(State*TRNLUInt64(2862933555777941757))+TRNLUInt64(3037000493);
    result:=State;
   end;
   function XorShift128Next(var State:TRNLRandomGeneratorXorShift128):TRNLUInt32; {$ifdef caninline}inline;{$endif}
   var t:TRNLUInt32;
   begin
    t:=State.x xor (State.x shl 11);
    State.x:=State.y;
    State.y:=State.z;
    State.z:=State.w;
    State.w:=(State.w xor (State.w shr 19)) xor (t xor (t shr 8));
    result:=State.w;
   end;
   function XorShift128PlusNext(var State:TRNLRandomGeneratorXorShift128Plus):TRNLUInt64; {$ifdef caninline}inline;{$endif}
   var s0,s1:TRNLUInt64;
   begin
    s1:=State.s[0];
    s0:=State.s[1];
    State.s[0]:=s0;
    s1:=s1 xor (s1 shl 23);
    State.s[1]:=((s1 xor s0) xor (s1 shr 18)) xor (s0 shr 5);
    result:=State.s[1]+s0;
   end;
   procedure XorShift128PlusJump(var State:TRNLRandomGeneratorXorShift128Plus);
   const Jump:array[0..1] of TRNLUInt64=
          (TRNLUInt64($8a5cd789635d2dff),
           TRNLUInt64($121fd2155c472f96));
   var i,b:TRNLSizeInt;
       s0,s1:TRNLUInt64;
   begin
    s0:=0;
    s1:=0;
    for i:=0 to 1 do begin
     for b:=0 to 63 do begin
      if (Jump[i] and TRNLUInt64(TRNLUInt64(1) shl b))<>0 then begin
       s0:=s0 xor State.s[0];
       s1:=s1 xor State.s[1];
      end;
      XorShift128PlusNext(State);
     end;
    end;
    State.s[0]:=s0;
    State.s[1]:=s1;
   end;
   function XorShift1024Next(var State:TRNLRandomGeneratorXorShift1024):TRNLUInt64; {$ifdef caninline}inline;{$endif}
   var s0,s1:TRNLUInt64;
   begin
    s0:=State.s[State.p and 15];
    State.p:=(State.p+1) and 15;
    s1:=State.s[State.p];
    s1:=s1 xor (s1 shl 31);
    State.s[State.p]:=((s1 xor s0) xor (s1 shr 11)) xor (s0 shr 30);
    result:=State.s[State.p]*TRNLUInt64(1181783497276652981);
   end;
   procedure XorShift1024Jump(var State:TRNLRandomGeneratorXorShift1024);
   const Jump:array[0..15] of TRNLUInt64=
          (TRNLUInt64($84242f96eca9c41d),
           TRNLUInt64($a3c65b8776f96855),
           TRNLUInt64($5b34a39f070b5837),
           TRNLUInt64($4489affce4f31a1e),
           TRNLUInt64($2ffeeb0a48316f40),
           TRNLUInt64($dc2d9891fe68c022),
           TRNLUInt64($3659132bb12fea70),
           TRNLUInt64($aac17d8efa43cab8),
           TRNLUInt64($c4cb815590989b13),
           TRNLUInt64($5ee975283d71c93b),
           TRNLUInt64($691548c86c1bd540),
           TRNLUInt64($7910c41d10a1e6a5),
           TRNLUInt64($0b5fc64563b3e2a8),
           TRNLUInt64($047f7684e9fc949d),
           TRNLUInt64($b99181f2d8f685ca),
           TRNLUInt64($284600e3f30e38c3));
   var i,b,j:TRNLSizeInt;
       t:array[0..15] of TRNLUInt64;
   begin
    for i:=0 to 15 do begin
     t[i]:=0;
    end;
    for i:=0 to 15 do begin
     for b:=0 to 63 do begin
      if (Jump[i] and TRNLUInt64(TRNLUInt64(1) shl b))<>0 then begin
       for j:=0 to 15 do begin
        t[j]:=t[j] xor State.s[(j+State.p) and 15];
       end;
      end;
      XorShift1024Next(State);
     end;
    end;
    for i:=0 to 15 do begin
     State.s[(i+State.p) and 15]:=t[i];
    end;
   end;
   function CMWC4096Next(var State:TRNLRandomGeneratorCMWC4096):TRNLUInt64; {$ifdef caninline}inline;{$endif}
   var x,t:TRNLUInt64;
   begin
    State.QJ:=(State.QJ+1) and high(State.Q);
    x:=State.Q[State.QJ];
    t:=(x shl 58)+State.QC;
    State.QC:=x shr 6;
    inc(t,x);
    if x<t then begin
     inc(State.QC);
    end;
    State.Q[State.QJ]:=t;
    result:=t;
   end;
  const CountStateQWords=(SizeOf(TRNLRandomGeneratorState) div SizeOf(TRNLUInt64));
  type PStateQWords=^TStateQWords;
       TStateQWords=array[0..CountStateQWords-1] of TRNLUInt64;
  var Index,Remain,ToDo:TRNLSizeUInt;
      UnixTimeInMilliSeconds:TRNLInt64;
      SplitMix64,Value:TRNLUInt64;
      State:PRNLRandomGeneratorState;
  begin
   GetMem(State,SizeOf(TRNLRandomGeneratorState));
   try
    FillChar(State^,SizeOf(TRNLRandomGeneratorState),#0);
    UnixTimeInMilliSeconds:=round((SysUtils.Now-25569.0)*86400000.0);
    SplitMix64:=TRNLUInt64(UnixTimeInMilliSeconds) xor TRNLUInt64(TRNLUInt64($7a5cde814c2a9d21){$ifdef Windows}+TRNLUInt64(GetTickCount64){$endif});
{$if defined(Windows)}
    QueryPerformanceFrequency(TRNLUInt64(PStateQWords(TRNLPointer(State))^[0]));
    for Index:=1 to CountStateQWords-1 do begin
     QueryPerformanceCounter(TRNLUInt64(PStateQWords(TRNLPointer(State))^[Index]));
    end;
{$else}
    for Index:=0 to CountStateQWords-1 do begin
     PStateQWords(TRNLPointer(State))^[Index]:=0;
    end;
{$ifend}
{$if defined(CPU386)or defined(CPUX64)}
    if x86_rdseed_support then begin
     for Index:=0 to CountStateQWords-1 do begin
      PStateQWords(TRNLPointer(State))^[Index]:=PStateQWords(TRNLPointer(State))^[Index] xor
                                                x86_rdseed_ui64;
     end;
    end else if x86_rdrand_support then begin
     for Index:=0 to CountStateQWords-1 do begin
      PStateQWords(TRNLPointer(State))^[Index]:=PStateQWords(TRNLPointer(State))^[Index] xor
                                                x86_rdrand_ui64;
     end;
    end;
{$ifend}
    for Index:=0 to CountStateQWords-1 do begin
     PStateQWords(TRNLPointer(State))^[Index]:=PStateQWords(TRNLPointer(State))^[Index] xor
                                               SplitMix64Next(SplitMix64);
    end;
    XorShift1024Jump(State^.XorShift1024);
    FillChar(aBuffer,aSize,#0);
    Index:=0;
    Remain:=aSize;
    while Remain>0 do begin
     if Remain<SizeOf(TRNLUInt64) then begin
      ToDo:=Remain;
     end else begin
      ToDo:=SizeOf(TRNLUInt64);
     end;
     Value:=(LCG64Next(State^.LCG64)+
             XorShift1024Next(State^.XorShift1024)+
             CMWC4096Next(State^.CMWC4096)) xor
            PCG32Next(State^.PCG32);
{$if defined(CPU386) or defined(CPUX64)}
     if x86_rdrand_support then begin
      Value:=Value xor x86_rdrand_ui64;
     end;
{$ifend}
     Move(Value,PRNLUInt8Array(TRNLPointer(@aBuffer))^[Index],ToDo);
     inc(Index,ToDo);
     dec(Remain,ToDo);
    end;
   finally
    FillChar(State^,SizeOf(TRNLRandomGeneratorState),#0);
    FreeMem(State);
   end;
   result:=true;
  end;
  function GUIDGetEntropyData(out aBuffer;const aSize:TRNLSizeUInt):boolean;
  var Index,Remain,ToDo:TRNLSizeUInt;
      Value:TGUID;
{$if not (defined(Windows) or defined(fpc) or defined(NextGen))}
      OK:boolean;
      fs:TFileStream;
      s:TRNLRawByteString;
{$ifend}
  begin
   FillChar(aBuffer,aSize,#0);
   Index:=0;
   Remain:=aSize;
   while Remain>0 do begin
    if Remain<SizeOf(TGUID) then begin
     ToDo:=Remain;
    end else begin
     ToDo:=SizeOf(TGUID);
    end;
{$if defined(fpc)}
    // FPC's RTL is doing already the right thing
    CreateGUID(Value);
{$elseif defined(Windows)}
    CoCreateGUID(Value);
{$elseif defined(NextGen)}
    // In this case, we hope, that the next-gen delphi ecosystem stuff is doing already the right thing
    CreateGUID(Value);
{$else}
    OK:=false;
    if (not OK) and FileExists('/proc/sys/kernel/random/uuid') then begin
     try
      fs:=TFileStream.Create('/proc/sys/kernel/random/uuid',fmOpenRead or fmShareDenyNone);
      s:='';
      try
       SetLength(s,36);
       if fs.Read(s[1],36)=36 then begin
        Value:=StringToGUID('{'+s+'}');
        OK:=true;
       end;
      finally
       SetLength(s,0);
      end;
     except
     end;
    end;
    if not OK then begin
     CreateGUID(Value);
    end;
{$ifend}
    Move(Value,PRNLUInt8Array(TRNLPointer(@aBuffer))^[Index],ToDo);
    inc(Index,ToDo);
    dec(Remain,ToDo);
   end;
   result:=true;
  end;
 var TemporaryEntropyData:TRNLRandomGeneratorEntropyData;
  procedure MixEntropyData;
  var Index:TRNLSizeUInt;
  begin
   for Index:=0 to SizeOf(TRNLRandomGeneratorEntropyData)-1 do begin
    EntropyData[Index]:=EntropyData[Index] xor TemporaryEntropyData[Index];
   end;
  end;
 begin
  FillChar(EntropyData,SizeOf(TRNLRandomGeneratorEntropyData),#0);
  FillChar(TemporaryEntropyData,SizeOf(TRNLRandomGeneratorEntropyData),#0);
{$if defined(Windows)}
  if WindowsGetEntropyData(TemporaryEntropyData,SizeOf(TRNLRandomGeneratorEntropyData)) then begin
   MixEntropyData;
  end else begin
   if WindowsEnvironmentStringsGetEntropyData(TemporaryEntropyData,SizeOf(TRNLRandomGeneratorEntropyData)) then begin
    MixEntropyData;
   end;
   if WindowsCommandLineGetEntropyData(TemporaryEntropyData,SizeOf(TRNLRandomGeneratorEntropyData)) then begin
    MixEntropyData;
   end;
   if GUIDGetEntropyData(TemporaryEntropyData,SizeOf(TRNLRandomGeneratorEntropyData)) then begin
    MixEntropyData;
   end;
  end;
{$elseif defined(Unix) or defined(Posix)}
  if PosixGetEntropyData(TemporaryEntropyData,SizeOf(TRNLRandomGeneratorEntropyData)) then begin
   MixEntropyData;
  end;
  if GUIDGetEntropyData(TemporaryEntropyData,SizeOf(TRNLRandomGeneratorEntropyData)) then begin
   MixEntropyData;
  end;
{$else}
  if GUIDGetEntropyData(TemporaryEntropyData,SizeOf(TRNLRandomGeneratorEntropyData)) then begin
   MixEntropyData;
  end;
{$ifend}
  if GetAdditionalEntropyData(TemporaryEntropyData,SizeOf(TRNLRandomGeneratorEntropyData)) then begin
   MixEntropyData;
  end;
  FillChar(TemporaryEntropyData,SizeOf(TRNLRandomGeneratorEntropyData),#0);
 end;
begin
 EntropyData[0]:=0;
 GetEntropyData;
 if not fInitialized then begin
  fInitialized:=true;
  Initialize(EntropyData,SizeOf(TRNLRandomGeneratorEntropyData));
 end else begin
  Rekey(EntropyData,SizeOf(TRNLRandomGeneratorEntropyData));
 end;
 FillChar(EntropyData,SizeOf(TRNLRandomGeneratorEntropyData),#0);
 FillChar(fBuffer,SizeOf(TRNLRandomGeneratorBuffer),#0);
 fPosition:=SizeOf(TRNLRandomGeneratorSeed);
 fHave:=0;
 fCount:=1600000;
end;

procedure TRNLRandomGenerator.ReseedIfNeeded(const aCount:TRNLSizeUInt);
begin
 if (fCount<=aCount) or not fInitialized then begin
  Reseed;
 end;
 if fCount<=aCount then begin
  fCount:=0;
 end else begin
  dec(fCount,aCount);
 end;
end;

procedure TRNLRandomGenerator.GetRandomBytes(out aLocation;const aCount:TRNLSizeUInt);
var Index,Remain,ToDo:TRNLSizeUInt;
begin
 ReseedIfNeeded(aCount);
 Index:=0;
 Remain:=aCount;
 while Remain>0 do begin
  if fHave>0 then begin
   if Remain<fHave then begin
    ToDo:=Remain;
   end else begin
    ToDo:=fHave;
   end;
   Move(PRNLUInt8Array(TRNLPointer(@fBuffer))^[fPosition],
        PRNLUInt8Array(TRNLPointer(@aLocation))^[Index],
        ToDo);
   inc(fPosition,ToDo);
   dec(fHave,ToDo);
   inc(Index,ToDo);
   dec(Remain,ToDo);
  end;
  if fHave=0 then begin
   Rekey(TRNLPointer(nil)^,0);
  end;
 end;
end;

function TRNLRandomGenerator.GetUInt32:TRNLUInt32;
begin
 GetRandomBytes(result,SizeOf(TRNLUInt32));
end;

function TRNLRandomGenerator.GetUInt64:TRNLUInt64;
begin
 GetRandomBytes(result,SizeOf(TRNLUInt64));
end;

function TRNLRandomGenerator.GetBoundedUInt32(const aBound:TRNLUInt32):TRNLUInt32;
begin
 if (aBound and TRNLUInt32($ffff0000))=0 then begin
  result:=((GetUInt32 shr 16)*aBound) shr 16;
 end else begin
  result:=(TRNLUInt64(GetUInt32)*aBound) shr 32;
 end;
end;

function TRNLRandomGenerator.GetUniformBoundedUInt32(const aBound:TRNLUInt32):TRNLUInt32;
var Minimum:TRNLUInt32;
begin
 if aBound>1 then begin
  Minimum:=TRNLUInt64($100000000) mod aBound;
  repeat
   result:=GetUInt32;
  until result>=Minimum;
  result:=result mod aBound;
 end else begin
  result:=0;
 end;
end;

function TRNLRandomGenerator.GetFloat:single; // -1.0 .. 1.0
var t:TRNLUInt32;
begin
 t:=GetUInt32;
 t:=(((t shr 9) and $7fffff)+((t shr 8) and 1)) or $40000000;
 result:=single(TRNLPointer(@t)^)-3.0;
end;

function TRNLRandomGenerator.GetAbsoluteFloat:single; // 0.0 .. 1.0
var t:TRNLUInt32;
begin
 t:=GetUInt32;
 t:=(((t shr 10) and $3fffff)+((t shr 9) and 1)) or $40000000;
 result:=single(TRNLPointer(@t)^)-2.0;
end;

function TRNLRandomGenerator.GetDouble:double; // -1.0 .. 1.0
var t:TRNLUInt64;
begin
 t:=GetUInt64;
 t:=(((t shr 12) and $fffffffffffff)+((t shr 11) and 1)) or $4000000000000000;
 result:=double(TRNLPointer(@t)^)-3.0;
end;

function TRNLRandomGenerator.GetAbsoluteDouble:double; // 0.0 .. 1.0
var t:int64;
begin
 t:=GetUInt64;
 t:=(((t shr 13) and $7ffffffffffff)+((t shr 12) and 1)) or $4000000000000000;
 result:=double(TRNLPointer(@t)^)-2.0;
end;

function TRNLRandomGenerator.GetGuassianFloat:single; // -1.0 .. 1.0
var x1,x2,w:single;
    i:TRNLUInt32;
begin
 if fGuassianFloatUseLast then begin
  fGuassianFloatUseLast:=false;
  result:=fGuassianFloatLast;
 end else begin
  i:=0;
  repeat
   x1:=GetFloat;
   x2:=GetFloat;
   w:=sqr(x1)+sqr(x2);
   inc(i);
  until ((i and $80000000)<>0) or (w<1.0);
  if (i and $80000000)<>0 then begin
   result:=x1;
   fGuassianFloatLast:=x2;
   fGuassianFloatUseLast:=true;
  end else if abs(w)<1e-18 then begin
   result:=0.0;
  end else begin
   w:=sqrt(((-2.0)*ln(w))/w);
   result:=x1*w;
   fGuassianFloatLast:=x2*w;
   fGuassianFloatUseLast:=true;
  end;
 end;
 if result<-1.0 then begin
  result:=-1.0;
 end else if result>1.0 then begin
  result:=1.0;
 end;
end;

function TRNLRandomGenerator.GetAbsoluteGuassianFloat:single; // 0.0 .. 1.0
begin
 result:=(GetGuassianFloat+1.0)*0.5;
 if result<0.0 then begin
  result:=0.0;
 end else if result>1.0 then begin
  result:=1.0;
 end;
end;

function TRNLRandomGenerator.GetGuassianDouble:double; // -1.0 .. 1.0
var x1,x2,w:double;
    i:TRNLUInt32;
begin
 if fGuassianDoubleUseLast then begin
  fGuassianDoubleUseLast:=false;
  result:=fGuassianDoubleLast;
 end else begin
  i:=0;
  repeat
   x1:=GetDouble;
   x2:=GetDouble;
   w:=sqr(x1)+sqr(x2);
   inc(i);
  until ((i and $80000000)<>0) or (w<1.0);
  if (i and $80000000)<>0 then begin
   result:=x1;
   fGuassianDoubleLast:=x2;
   fGuassianDoubleUseLast:=true;
  end else if abs(w)<1e-18 then begin
   result:=0.0;
  end else begin
   w:=sqrt(((-2.0)*ln(w))/w);
   result:=x1*w;
   fGuassianDoubleLast:=x2*w;
   fGuassianDoubleUseLast:=true;
  end;
 end;
 if result<-1.0 then begin
  result:=-1.0;
 end else if result>1.0 then begin
  result:=1.0;
 end;
end;

function TRNLRandomGenerator.GetAbsoluteGuassianDouble:double; // 0.0 .. 1.0
begin
 result:=(GetGuassianDouble+1.0)*0.5;
 if result<0.0 then begin
  result:=0.0;
 end else if result>1.0 then begin
  result:=1.0;
 end;
end;

function TRNLRandomGenerator.GetGuassian(const aBound:TRNLUInt32):TRNLUInt32;
begin
 result:=round(GetAbsoluteGuassianDouble*(aBound-0.98725));
end;

procedure TRNLConnectionRequestRateLimiter.Reset(const aTime:TRNLTime);
begin
 fBurst:=0;
 fLastTime:=aTime;
end;

function TRNLConnectionRequestRateLimiter.RateLimit(const aTime:TRNLTime;const aBurst:TRNLInt64;const aPeriod:TRNLUInt64):boolean;
var Interval,Expired:TRNLTime;
begin
 Interval:=aTime-fLastTime;
 Expired:=Interval div aPeriod;
 if Expired>fBurst then begin
  Reset(aTime);
 end else begin
  dec(fBurst,Expired.fValue);
  fLastTime:=aTime-(Interval mod aPeriod);
 end;
 if fBurst<aBurst then begin
  inc(fBurst);
  result:=false;
 end else begin
  result:=true;
 end;
end;

constructor TRNLBandwidthRateLimiter.Create(const aMaximumPerPeriod,aPeriodLength:TRNLUInt64;const aTime:TRNLTime);
begin
 Setup(aMaximumPerPeriod,aPeriodLength);
 Reset(aTime);
end;

procedure TRNLBandwidthRateLimiter.Setup(const aMaximumPerPeriod,aPeriodLength:TRNLUInt64);
begin
 fMaximumPerPeriod:=aMaximumPerPeriod;
 fPeriodLength:=aPeriodLength;
end;

procedure TRNLBandwidthRateLimiter.Reset(const aTime:TRNLTime);
begin
 fUsedInPeriod:=0;
 fPeriodStart:=aTime;
 fPeriodEnd:=aTime+fMaximumPerPeriod;
end;

function TRNLBandwidthRateLimiter.CanProceed(const aDesired:TRNLUInt32;const aTime:TRNLTime):boolean;
begin
 result:=(fMaximumPerPeriod=0) or
         ((fPeriodEnd<aTime) and (aDesired<=fMaximumPerPeriod)) or
         ((fUsedInPeriod+aDesired)<=fMaximumPerPeriod);
end;

procedure TRNLBandwidthRateLimiter.AddAmount(const aUsed:TRNLUInt32;const aTime:TRNLTime);
begin
 if fPeriodEnd<aTime then begin
  Reset(aTime);
 end;
 if fMaximumPerPeriod=0 then begin
  fUsedInPeriod:=0;
 end else begin
  inc(fUsedInPeriod,aUsed);
 end;
end;

procedure TRNLBandwidthRateTracker.Reset;
begin
 fPeriodUnits:=0;
 fUnitsPerSecond:=0;
 fLastTime:=0;
 fTime:=0;
end;

procedure TRNLBandwidthRateTracker.SetTime(const aTime:TRNLTime);
begin
 fTime:=aTime;
 if fLastTime.fValue=0 then begin
  fLastTime:=aTime;
 end;
end;

procedure TRNLBandwidthRateTracker.AddUnits(const aUnits:TRNLUInt32);
begin
 inc(fPeriodUnits,aUnits);
end;

procedure TRNLBandwidthRateTracker.Update;
var TimeDifference:TRNLInt64;
    AbsoluteTimeDifference,FractionUnits,Seconds,FractionTime:TRNLSizeUInt;
begin
 TimeDifference:=TRNLTime.RelativeDifference(fTime,fLastTime);
 if TimeDifference>=1000 then begin
  AbsoluteTimeDifference:=TRNLSizeUInt(TimeDifference);
{$if not (defined(CPU386) or defined(CPUX64))}
  if AbsoluteTimeDifference<400000 then begin
   // Fast path
   Seconds:=((AbsoluteTimeDifference shr 3)*67109) shr 23; // /8)*125)/(2 shl 23) because 1000 = 8*125
   FractionTime:=AbsoluteTimeDifference-(Seconds*1000);
  end else{$ifend}begin
   // Slower path on CPUs (mostly on older ARM CPUs) without extra hardware division support
   Seconds:=AbsoluteTimeDifference div 1000;
   FractionTime:=AbsoluteTimeDifference mod 1000;
  end;
  FractionUnits:=(TRNLUInt64(fPeriodUnits)*FractionTime) div AbsoluteTimeDifference;
  fUnitsPerSecond:=(fPeriodUnits-FractionUnits) div Seconds;
  fLastTime:=fTime-FractionTime;
  fPeriodUnits:=FractionUnits;
 end;
end;

procedure TRNLOutgoingPacketBuffer.Reset(const aAssociatedDataSize:TRNLSizeUInt=0;const aBufferLength:TRNLSizeUInt=SizeOf(TRNLPacketBuffer));
begin
 fAssociatedDataSize:=aAssociatedDataSize;
 fSize:=aAssociatedDataSize;
 fBufferLength:=aBufferLength;
end;

function TRNLOutgoingPacketBuffer.HasSpaceFor(const aDataLength:TRNLSizeUInt):boolean;
begin
 result:=(fSize<=fBufferLength) and ((fBufferLength-fSize)>=aDataLength);
end;

function TRNLOutgoingPacketBuffer.PayloadSize:TRNLSizeUInt;
begin
 if fAssociatedDataSize<=fSize then begin
  result:=fSize-fAssociatedDataSize;
 end else begin
  result:=0;
 end;
end;

function TRNLOutgoingPacketBuffer.Write(const aData;const aDataLength:TRNLSizeUInt):TRNLSizeUInt;
begin
 result:=TRNLSizeUInt(SizeOf(TRNLPacketBuffer))-fSize;
 if aDataLength<result then begin
  result:=aDataLength;
 end;
 if result>0 then begin
{ if length(fData)<(fSize+result) then begin
   SetLength(fData,(fSize+result)*2);
  end;}
  Move(aData,fData[fSize],result);
  inc(fSize,result);
 end;
end;

class operator TRNLConnectionToken.Equal(const a,b:TRNLConnectionToken):boolean;
begin
 result:=TRNLMemory.SecureIsEqual(a,b,SizeOf(TRNLConnectionToken));
end;

class operator TRNLConnectionToken.NotEqual(const a,b:TRNLConnectionToken):boolean;
begin
 result:=TRNLMemory.SecureIsNotEqual(a,b,SizeOf(TRNLConnectionToken));
end;

class operator TRNLAuthenticationToken.Equal(const a,b:TRNLAuthenticationToken):boolean;
begin
 result:=TRNLMemory.SecureIsEqual(a,b,SizeOf(TRNLAuthenticationToken));
end;

class operator TRNLAuthenticationToken.NotEqual(const a,b:TRNLAuthenticationToken):boolean;
begin
 result:=TRNLMemory.SecureIsNotEqual(a,b,SizeOf(TRNLAuthenticationToken));
end;

procedure TRNLConnectionKnownCandidateHostAddressHashTable.Clear;
begin
 FillChar(self,SizeOf(TRNLConnectionKnownCandidateHostAddressHashTable),#0);
end;

function TRNLConnectionKnownCandidateHostAddressHashTable.Find(const aHostAddress:TRNLHostAddress;const aTime:TRNLTime;const aAddIfNotExist:boolean):PRNLConnectionKnownCandidateHostAddress;
type PToHash=^TToHash;
     TToHash=packed record
      HostAddress:TRNLHostAddress;
     end;
var ToHash:TToHash;
    Hash,Index:TRNLUInt32;
    Item:PRNLConnectionKnownCandidateHostAddress;
begin
 result:=nil;
 ToHash.HostAddress:=aHostAddress;
 Hash:=TRNLHashUtils.Hash32(ToHash,SizeOf(TToHash));
 Index:=Hash and HashMask;
 Item:=@fEntries[Index];
 if TRNLMemory.SecureIsEqual(Item^.HostAddress,aHostAddress,SizeOf(TRNLHostAddress)) then begin
  result:=Item;
 end else if aAddIfNotExist then begin
  Item^.HostAddress:=aHostAddress;
  Item^.RateLimiter.Reset(aTime);
  result:=Item;
 end;
end;

function TRNLConnectionCandidate.GetConnectionToken:TRNLConnectionToken;
begin
 if assigned(fData) then begin
  result:=fData^.fConnectionToken;
 end else begin
  FillChar(result,SizeOf(TRNLConnectionToken),#0);
 end;
end;

procedure TRNLConnectionCandidate.AcceptConnectionToken;
begin
 if assigned(fData) and assigned(fData^.fHost) then begin
  fData^.fHost.AcceptHandshakeConnectionRequest(@self);
 end;
end;

procedure TRNLConnectionCandidate.RejectConnectionToken;
begin
 if assigned(fData) and assigned(fData^.fHost) then begin
  fData^.fHost.RejectHandshakeConnectionRequest(@self);
 end;
end;

function TRNLConnectionCandidate.GetAuthenticationToken:TRNLAuthenticationToken;
begin
 if assigned(fData) then begin
  result:=fData^.fAuthenticationToken;
 end else begin
  FillChar(result,SizeOf(TRNLAuthenticationToken),#0);
 end;
end;

function TRNLConnectionCandidate.AcceptAuthenticationToken:TRNLPeer;
begin
 if assigned(fData) and assigned(fData^.fHost) then begin
  result:=fData^.fHost.AcceptHandshakePacketConnectionAuthenticationResponse(@self);
 end else begin
  result:=nil;
 end;
end;

procedure TRNLConnectionCandidate.RejectAuthenticationToken;
begin
 if assigned(fData) and assigned(fData^.fHost) then begin
  fData^.fHost.RejectHandshakePacketConnectionAuthenticationResponse(@self,RNL_CONNECTION_DENIAL_REASON_UNAUTHORIZED);
 end;
end;

procedure TRNLConnectionCandidateHashTable.Clear;
begin
 FillChar(self,SizeOf(TRNLConnectionCandidateHashTable),#0);
 Initialize(self);
end;

procedure TRNLConnectionCandidateHashTable.Free;
var Index:TRNLUInt32;
    Item:PRNLConnectionCandidate;
begin

 for Index:=Low(TRNLConnectionCandidateHashTableEntries) to High(TRNLConnectionCandidateHashTableEntries) do begin

  Item:=@fEntries[Index];

  if assigned(Item^.fData) then begin
   Finalize(Item^.fData^);
   FillChar(Item^.fData^,SizeOf(TRNLConnectionCandidateData),#0);
   FreeMem(Item^.fData);
   Item^.fData:=nil;
  end;

 end;

 Finalize(self);

 FillChar(self,SizeOf(TRNLConnectionCandidateHashTable),#0);

end;

function TRNLConnectionCandidateHashTable.Find(const aRandomGenerator:TRNLRandomGenerator;const aAddress:TRNLAddress;const aRemoteSalt,aLocalSalt:TRNLUInt64;const aTime,aTimeout:TRNLTime;const aAddIfNotExist:boolean):PRNLConnectionCandidate;
type PToHash=^TToHash;
     TToHash=packed record
      Address:TRNLAddress;
      RemoteSalt:TRNLUInt64;
      LocalSalt:TRNLUInt64;
     end;
var ToHash:TToHash;
    Hash,Index:TRNLUInt32;
    Item:PRNLConnectionCandidate;
begin
 result:=nil;
 ToHash.Address:=aAddress;
 ToHash.RemoteSalt:=aRemoteSalt;
 ToHash.LocalSalt:=aLocalSalt;
 Hash:=TRNLHashUtils.Hash32(ToHash,SizeOf(TToHash));
 Index:=Hash and HashMask;
 Item:=@fEntries[Index];
 if (Item^.fState<>RNL_CONNECTION_STATE_INVALID) and
    TRNLMemory.SecureIsEqual(Item^.fAddress,aAddress,SizeOf(TRNLAddress)) and
    (Item^.fRemoteSalt=aRemoteSalt) and
    (Item^.fCreateTime.fValue<=aTime.fValue) and
    ((Item^.fCreateTime+aTimeout).fValue>=aTime.fValue) then begin
  result:=Item;
 end else if aAddIfNotExist then begin
  Item^.fState:=RNL_CONNECTION_STATE_REQUESTING;
  Item^.fRemoteSalt:=aRemoteSalt;
  Item^.fLocalSalt:=aLocalSalt;
  Item^.fCreateTime:=aTime;
  Item^.fAddress:=aAddress;
  if assigned(Item^.fData) then begin
   Finalize(Item^.fData^);
   FillChar(Item^.fData^,SizeOf(TRNLConnectionCandidateData),#0);
   FreeMem(Item^.fData);
   Item^.fData:=nil;
  end;
  result:=Item;
 end;
end;

constructor TRNLMessage.CreateFromMemory(const aData:TRNLPointer;const aDataLength:TRNLUInt32;const aFlags:TRNLMessageFlags);
begin
 inherited Create;
 Initialize;
 if RNL_MESSAGE_FLAG_NO_ALLOCATE in aFlags then begin
  fData:=aData;
 end else if aDataLength<=0 then begin
  fData:=nil;
 end else begin
  GetMem(fData,aDataLength);
  if assigned(aData) then begin
   Move(aData^,fData^,aDataLength);
  end else begin
   FillChar(fData^,aDataLength,#0);
  end;
 end;
 fDataLength:=aDataLength;
 fFlags:=aFlags;
end;

constructor TRNLMessage.CreateFromBytes(const aData:TBytes;const aFlags:TRNLMessageFlags);
begin
 CreateFromMemory(@aData[0],
                  length(aData),
                  aFlags-[RNL_MESSAGE_FLAG_NO_ALLOCATE,RNL_MESSAGE_FLAG_NO_FREE]);
end;

constructor TRNLMessage.CreateFromBytes(const aData:array of TRNLUInt8;const aFlags:TRNLMessageFlags);
begin
 CreateFromMemory(@aData[0],
                  length(aData),
                  aFlags-[RNL_MESSAGE_FLAG_NO_ALLOCATE,RNL_MESSAGE_FLAG_NO_FREE]);
end;

constructor TRNLMessage.CreateFromRawByteString(const aData:TRNLRawByteString;const aFlags:TRNLMessageFlags);
begin
 CreateFromMemory({$ifdef NextGen}MarshaledAString{$else}PAnsiChar{$endif}(aData),
                  length(aData),
                  aFlags-[RNL_MESSAGE_FLAG_NO_ALLOCATE,RNL_MESSAGE_FLAG_NO_FREE]);
end;

constructor TRNLMessage.CreateFromUTF8String(const aData:TRNLUTF8String;const aFlags:TRNLMessageFlags);
begin
 CreateFromMemory({$ifdef NextGen}MarshaledAString{$else}PAnsiChar{$endif}(aData),
                  length(aData),
                  aFlags-[RNL_MESSAGE_FLAG_NO_ALLOCATE,RNL_MESSAGE_FLAG_NO_FREE]);
end;

constructor TRNLMessage.CreateFromUTF16String(const aData:TRNLUTF16String;const aFlags:TRNLMessageFlags);
begin
 CreateFromUTF8String(UTF8Encode(aData));
end;

constructor TRNLMessage.CreateFromString(const aData:TRNLString;const aFlags:TRNLMessageFlags);
begin
 CreateFromUTF8String(UTF8Encode(aData));
end;

constructor TRNLMessage.CreateFromStream(const aStream:TStream;const aFlags:TRNLMessageFlags);
var StreamData:TRNLPointer;
begin
 if aStream is TMemoryStream then begin
  if RNL_MESSAGE_FLAG_NO_ALLOCATE in aFlags then begin
   inherited Create;
   Initialize;
   fStream:=aStream;
   fData:=TMemoryStream(aStream).Memory;
   fDataLength:=TMemoryStream(aStream).Size;
   fFlags:=aFlags;
  end else begin
   CreateFromMemory(TMemoryStream(aStream).Memory,aStream.Size,aFlags);
  end;
 end else begin
  GetMem(StreamData,aStream.Size+1);
  try
   aStream.Seek(0,soBeginning);
   aStream.ReadBuffer(StreamData^,aStream.Size);
   CreateFromMemory(StreamData,aStream.Size,aFlags-[RNL_MESSAGE_FLAG_NO_ALLOCATE,RNL_MESSAGE_FLAG_NO_FREE]);
  finally
   FreeMem(StreamData);
  end;
 end;
end;

destructor TRNLMessage.Destroy;
begin
 if assigned(fOnFree) then begin
  fOnFree(self);
 end;
 if assigned(fStream) and (RNL_MESSAGE_FLAG_NO_ALLOCATE in fFlags) then begin
  if not (RNL_MESSAGE_FLAG_NO_FREE in fFlags) then begin
   fStream.Free;
  end;
 end else begin
  if assigned(fData) and not (RNL_MESSAGE_FLAG_NO_FREE in fFlags) then begin
   FreeMem(fData);
  end;
 end;
 fStream:=nil;
 fData:=nil;
 inherited Destroy;
end;

procedure TRNLMessage.Initialize;
begin
 fStream:=nil;
 fData:=nil;
 fDataLength:=0;
 fReferenceCounter:=1;
 fOnFree:=nil;
 fUserData:=nil;
 fFlags:=[];
end;

procedure TRNLMessage.IncRef;
begin
 {$ifdef fpc}InterlockedIncrement{$else}AtomicIncrement{$endif}(TRNLInt32(fReferenceCounter));
end;

procedure TRNLMessage.DecRef;
begin
 if assigned(self) and
    ({$ifdef fpc}InterlockedDecrement{$else}AtomicDecrement{$endif}(TRNLInt32(fReferenceCounter))=0) then begin
  Free;
 end;
end;

procedure TRNLMessage.Resize(const aDataLength:TRNLUInt32);
var NewData:TRNLPointer;
begin
 if (aDataLength<=fDataLength) or (RNL_MESSAGE_FLAG_NO_ALLOCATE in fFlags) then begin
  fDataLength:=aDataLength;
 end else begin
  GetMem(NewData,aDataLength);
  FillChar(NewData^,aDataLength,#0);
  Move(fData^,NewData^,fDataLength);
  FreeMem(fData);
  fData:=NewData;
  fDataLength:=aDataLength;
 end;
end;

function TRNLMessage.GetDataAsBytes:TBytes;
begin
 result:=nil;
 if fDataLength>0 then begin
  SetLength(result,fDataLength);
  Move(fData^,result[0],fDataLength);
 end;
end;

function TRNLMessage.GetDataAsRawByteString:TRNLRawByteString;
{$if defined(fpc)}
begin
 result:='';
 if fDataLength>0 then begin
  SetLength(result,fDataLength);
  Move(fData^,result[1],fDataLength);
 end;
end;
{$else}
begin
 result:='';
 if fDataLength>0 then begin
  SetString(result,{$ifdef NextGen}MarshaledAString{$else}PAnsiChar{$endif}(fData),fDataLength);
 end;
end;
{$ifend}

function TRNLMessage.GetDataAsUTF8String:TRNLUTF8String;
{$if defined(fpc)}
begin
 result:='';
 if fDataLength>0 then begin
  SetLength(result,fDataLength);
  Move(fData^,result[1],fDataLength);
 end;
end;
{$else}
begin
 result:='';
 if fDataLength>0 then begin
  SetString(result,{$ifdef NextGen}MarshaledAString{$else}PAnsiChar{$endif}(fData),fDataLength);
 end;
end;
{$ifend}

function TRNLMessage.GetDataAsUTF16String:TRNLUTF16String;
begin
 result:={$ifdef fpc}UTF8Decode{$else}UTF8ToUnicodeString{$endif}(GetDataAsUTF8String);
end;

function TRNLMessage.GetDataAsString:TRNLString;
begin
 result:=TRNLString({$ifdef fpc}UTF8Decode{$else}UTF8ToString{$endif}(GetDataAsUTF8String));
end;

var CRC32CTable:array[0..7,TRNLUInt8] of TRNLUInt32;

procedure InitializeCRC32C;
const ReversedBitOrderPoly=$82f63b78;
var Index,OtherIndex:TRNLInt32;
    Value:TRNLUInt32;
begin
 for Index:=0 to 255 do begin
  Value:=Index;
  for OtherIndex:=0 to 7 do begin
   Value:=(Value shr 1) xor (ReversedBitOrderPoly and (-(Value and 1)));
  end;
  CRC32CTable[0,Index]:=Value;
 end;
 for Index:=0 to 255 do begin
  Value:=CRC32CTable[0,Index];
  for OtherIndex:=1 to 7 do begin
   Value:=(Value shr 8) xor CRC32CTable[0,Value and $ff];
   CRC32CTable[OtherIndex,Index]:=Value;
  end;
 end;
end;

function ChecksumCRC32C(const aLocation;const aSize:TRNLUInt32):TRNLUInt32;
var Remaining:TRNLInt32;
    Data:PRNLUInt8;
{$ifdef CPU64}
    Value:TRNLUInt64;
{$endif}
begin
 result:=$ffffffff;
 Remaining:=aSize;
 if Remaining>0 then begin
  Data:=@aLocation;
  while (Remaining>0) and (({%H-}TRNLPtrUInt(TRNLPointer(Data)) and ({$ifdef CPU64}SizeOf(TRNLUInt64){$else}SizeOf(TRNLUInt32){$endif}-1))<>0) do begin
   result:=(result shr 8) xor CRC32CTable[0,(result and $ff) xor Data^];
   inc(Data);
   dec(Remaining);
  end;
{$ifdef CPU64}
  while Remaining>=SizeOf(TRNLUInt64) do begin
   Value:=result xor PRNLUInt64(TRNLPointer(Data))^;
{$ifdef BIG_ENDIAN}
   result:=CRC32CTable[0,(Value shr 0) and $ff] xor
           CRC32CTable[1,(Value shr 8) and $ff] xor
           CRC32CTable[2,(Value shr 16) and $ff] xor
           CRC32CTable[3,(Value shr 24) and $ff] xor
           CRC32CTable[4,(Value shr 32) and $ff] xor
           CRC32CTable[5,(Value shr 40) and $ff] xor
           CRC32CTable[6,(Value shr 48) and $ff] xor
           CRC32CTable[7,(Value shr 56) and $ff];
{$else}
   result:=CRC32CTable[7,(Value shr 0) and $ff] xor
           CRC32CTable[6,(Value shr 8) and $ff] xor
           CRC32CTable[5,(Value shr 16) and $ff] xor
           CRC32CTable[4,(Value shr 24) and $ff] xor
           CRC32CTable[3,(Value shr 32) and $ff] xor
           CRC32CTable[2,(Value shr 40) and $ff] xor
           CRC32CTable[1,(Value shr 48) and $ff] xor
           CRC32CTable[0,(Value shr 56) and $ff];
{$endif}
   inc(Data,SizeOf(TRNLUInt64));
   dec(Remaining,SizeOf(TRNLUInt64));
  end;
{$else}
  while Remaining>=SizeOf(TRNLUInt32) do begin
   result:=result xor PRNLUInt32(TRNLPointer(Data))^;
{$ifdef BIG_ENDIAN}
   result:=CRC32CTable[0,(result shr 0) and $ff] xor
           CRC32CTable[1,(result shr 8) and $ff] xor
           CRC32CTable[2,(result shr 16) and $ff] xor
           CRC32CTable[3,(result shr 24) and $ff];
{$else}
   result:=CRC32CTable[3,(result shr 0) and $ff] xor
           CRC32CTable[2,(result shr 8) and $ff] xor
           CRC32CTable[1,(result shr 16) and $ff] xor
           CRC32CTable[0,(result shr 24) and $ff];
{$endif}
   inc(Data,SizeOf(TRNLUInt32));
   dec(Remaining,SizeOf(TRNLUInt32));
  end;
{$endif}
  while Remaining>0 do begin
   result:=(result shr 8) xor CRC32CTable[0,(result and $ff) xor Data^];
   inc(Data);
   dec(Remaining);
  end;
 end;
 result:=not result;
end;

procedure TRNLHostEvent.Initialize;
begin
 Type_:=RNL_HOST_EVENT_TYPE_NONE;
 Peer:=nil;
 Message:=nil;
 Data:=0;
end;

procedure TRNLHostEvent.Finalize;
begin
 Free;
end;

procedure TRNLHostEvent.Free;
begin
 Type_:=RNL_HOST_EVENT_TYPE_NONE;
 if assigned(Peer) then begin
  Peer.DecRef;
  Peer:=nil;
 end;
 if assigned(Message) then begin
  Message.DecRef;
  Message:=nil;
 end;
end;

constructor TRNLInstance.Create;
begin
 inherited Create;
 if RNLInitializationReferenceCounter=0 then begin
  GlobalInitialize;
  inc(RNLInitializationReferenceCounter);
 end;
 fTimeBase:=0;
{$if defined(RNL_DEBUG)}
 fDebugLock:=TCriticalSection.Create;
{$ifend}
end;

destructor TRNLInstance.Destroy;
begin
 if RNLInitializationReferenceCounter>0 then begin
  dec(RNLInitializationReferenceCounter);
  if RNLInitializationReferenceCounter=0 then begin
   GlobalFinalize;
  end;
 end;
{$if defined(RNL_DEBUG)}
 FreeAndNil(fDebugLock);
{$ifend}
 inherited Destroy;
end;

constructor TRNLNetworkEvent.Create;
{$if not defined(Windows)}
var t:TRNLInt32;
{$ifndef fpc}
    PipeDescriptors:TPipeDescriptors;
{$endif}
{$ifend}
begin
 inherited Create;
{$if defined(Windows)}
 fEvent:=CreateEvent(nil,false,false,'');
{$else}
 fEventLock:=TCriticalSection.Create;
 fEventPipeFDs[0]:=-1;
 fEventPipeFDs[1]:=-1;
{$if defined(fpc)}
 if fppipe(fEventPipeFDs)<0 then begin
  raise ERNLRealNetwork.Create('Pipe error');
 end;
 try
  t:=fpfcntl(fEventPipeFDs[0],F_GETFL);
  if t<0 then begin
   raise ERNLRealNetwork.Create('Pipe error');
  end;
  if fpfcntl(fEventPipeFDs[0],F_SETFL,t or O_NONBLOCK)<0 then begin
   raise ERNLRealNetwork.Create('Pipe error');
  end;
  t:=fpfcntl(fEventPipeFDs[1],F_GETFL);
  if t<0 then begin
   raise ERNLRealNetwork.Create('Pipe error');
  end;
  if fpfcntl(fEventPipeFDs[1],F_SETFL,t or O_NONBLOCK)<0 then begin
   raise ERNLRealNetwork.Create('Pipe error');
  end;
 except
  on e:ERNLRealNetwork do begin
   fpclose(fEventPipeFDs[0]);
   fpclose(fEventPipeFDs[1]);
   fEventPipeFDs[0]:=-1;
   fEventPipeFDs[1]:=-1;
   raise;
  end;
 end;
{$else}
 if pipe(PipeDescriptors)<0 then begin
  raise ERNLRealNetwork.Create('Pipe error');
 end;
 fEventPipeFDs[0]:=PipeDescriptors.ReadDes;
 fEventPipeFDs[1]:=PipeDescriptors.WriteDes;
 try
  t:=fcntl(fEventPipeFDs[0],F_GETFL);
  if t<0 then begin
   raise ERNLRealNetwork.Create('Pipe error');
  end;
  if fcntl(fEventPipeFDs[0],F_SETFL,t or O_NONBLOCK)<0 then begin
   raise ERNLRealNetwork.Create('Pipe error');
  end;
  t:=fcntl(fEventPipeFDs[1],F_GETFL);
  if t<0 then begin
   raise ERNLRealNetwork.Create('Pipe error');
  end;
  if fcntl(fEventPipeFDs[1],F_SETFL,t or O_NONBLOCK)<0 then begin
   raise ERNLRealNetwork.Create('Pipe error');
  end;
 except
  on e:ERNLRealNetwork do begin
   __close(fEventPipeFDs[0]);
   __close(fEventPipeFDs[1]);
   fEventPipeFDs[0]:=-1;
   fEventPipeFDs[1]:=-1;
   raise;
  end;
 end;
{$ifend}
{$ifend}
end;

destructor TRNLNetworkEvent.Destroy;
begin
{$if defined(Windows)}
 CloseHandle(fEvent);
{$else}
{$if defined(fpc)}
 if fEventPipeFDs[0]>=0 then begin
  fpclose(fEventPipeFDs[0]);
 end;
 if fEventPipeFDs[1]>=0 then begin
  fpclose(fEventPipeFDs[1]);
 end;
{$else}
 if fEventPipeFDs[0]>=0 then begin
  __close(fEventPipeFDs[0]);
 end;
 if fEventPipeFDs[1]>=0 then begin
  __close(fEventPipeFDs[1]);
 end;
{$ifend}
 fEventPipeFDs[0]:=-1;
 fEventPipeFDs[1]:=-1;
 FreeAndNil(fEventLock);
{$ifend}
 inherited Destroy;
end;

procedure TRNLNetworkEvent.SetEvent;
{$if not defined(Windows)}
const b:TRNLUInt8=1;
var Count:TRNLInt32;
{$ifend}
begin
{$if defined(Windows)}
 Windows.SetEvent(fEvent);
{$else}
 fEventLock.Acquire;
 try
{$ifdef fpc}
  if (fpioctl(fEventPipeFDs[0],FIONREAD,@Count)=0) and (Count=0) then begin
   fpwrite(fEventPipeFDs[1],b,SizeOf(TRNLUInt8));
  end;
{$else}
  if (ioctl(fEventPipeFDs[0],FIONREAD,@Count)=0) and (Count=0) then begin
   __write(fEventPipeFDs[1],@b,SizeOf(TRNLUInt8));
  end;
{$endif}
 finally
  fEventLock.Release;
 end;
{$ifend}
end;

procedure TRNLNetworkEvent.ResetEvent;
{$if not defined(Windows)}
var b:TRNLUInt8;
    Count:TRNLInt32;
{$ifend}
begin
{$if defined(Windows)}
 Windows.ResetEvent(fEvent);
{$else}
 fEventLock.Acquire;
 try
{$ifdef fpc}
  if (fpioctl(fEventPipeFDs[0],FIONREAD,@Count)=0) and (Count>0) then begin
   fpread(fEventPipeFDs[0],b,SizeOf(TRNLUInt8));
  end;
{$else}
  if (ioctl(fEventPipeFDs[0],FIONREAD,@Count)=0) and (Count>0) then begin
   __read(fEventPipeFDs[0],@b,SizeOf(TRNLUInt8));
  end;
{$endif}
 finally
  fEventLock.Release;
 end;
{$ifend}
end;

function TRNLNetworkEvent.WaitFor(const aTimeout:TRNLInt64):TWaitResult;
{$if defined(Windows)}
var Timeout:TRNLUInt32;
begin
 if aTimeout>=0 then begin
  Timeout:=aTimeout;
 end else begin
  Timeout:=INFINITE;
 end;
 if Timeout>0 then begin
  case WaitForSingleObject(fEvent,Timeout) of
   WAIT_OBJECT_0:begin
    result:=wrSignaled;
   end;
   WAIT_TIMEOUT:begin
    result:=wrTimeOut;
   end;
{$ifndef fpc}
   WAIT_IO_COMPLETION:begin
    result:=wrIOCompletion;
   end;
{$endif}
   else {WAIT_FAILED:}begin
    result:=wrError;
   end;
  end;
 end else begin
  result:=wrTimeOut;
 end;
end;
{$else}
var tv:{$if defined(Windows)}TTimeVal{$elseif defined(fpc)}TTimeVal{$else}TimeVal{$ifend};
    ReadSet,WriteSet:TRNLSocketSet;
    t:pointer;
    r:TRNLSizeInt;
begin
 if aTimeout<0 then begin
  t:=nil;
 end else begin
  tv.tv_sec:=aTimeout div 1000;
  tv.tv_usec:=(aTimeout mod 1000)*1000;
  t:=@tv;
 end;
{$if defined(Posix)}
  __fd_zero(ReadSet);
  __fd_zero(WriteSet);
  __fd_set(fEventPipeFDs[0],ReadSet);
{$elseif defined(Unix)}
  fpFD_ZERO(ReadSet);
  fpFD_ZERO(WriteSet);
  fpFD_SET(fEventPipeFDs[0],ReadSet);
{$else}
  FD_ZERO(ReadSet);
  FD_ZERO(WriteSet);
  FD_SET(fEventPipeFDs[0],ReadSet);
{$ifend}
{$if defined(fpc)}
 r:=fpselect(fEventPipeFDs[0]+1,@ReadSet,@WriteSet,nil,t);
{$else}
 r:=Posix.SysSelect.select(fEventPipeFDs[0]+1,@ReadSet,@WriteSet,nil,t);
{$ifend}
 if r<0 then begin
  result:=wrError;
  exit;
 end;
 if {$if defined(Windows)}FD_ISSET(fEventPipeFDs[0],ReadSet)
    {$elseif defined(fpc)}
     fpFD_ISSET(fEventPipeFDs[0],ReadSet)=1
    {$else}
     __fd_isset(fEventPipeFDs[0],ReadSet)
    {$ifend} then begin
  ResetEvent;
 end;
 result:=wrTimeOut;
end;
{$ifend}

class function TRNLNetworkEvent.WaitForMultipleEvents(const aEvents:array of TRNLNetworkEvent;const aTimeout:TRNLInt64):TRNLInt32;
{$if defined(Windows)}
var Timeout:TRNLUInt32;
    r:TRNLInt32;
    Events:array of THandle;
    Index:TRNLSizeInt;
begin
 if aTimeout>=0 then begin
  Timeout:=aTimeout;
 end else begin
  Timeout:=INFINITE;
 end;
 if Timeout>0 then begin
  if length(aEvents)>0 then begin
   Events:=nil;
   try
    SetLength(Events,length(aEvents));
    for Index:=0 to length(aEvents)-1 do begin
     Events[Index]:=aEvents[Index].fEvent;
    end;
    r:=WaitForMultipleObjects(length(Events),@Events[0],false,Timeout);
    case r of
     WAIT_OBJECT_0..WAIT_OBJECT_0+$7f:begin
      result:=r-WAIT_OBJECT_0;
     end;
     WAIT_TIMEOUT:begin
      result:=-1;
     end;
{$ifndef fpc}
     WAIT_IO_COMPLETION:begin
      result:=-2;
     end;
{$endif}
     else {WAIT_FAILED:}begin
      result:=-3;
     end;
    end;
   finally
    Events:=nil;
   end;
  end else begin
   if SleepEx(Timeout,true)=0 then begin
    result:=-1;
   end else begin
{$ifdef fpc}
    result:=-1;
{$else}
    result:=-2;
{$endif}
   end;
  end;
 end else begin
  result:=-1;
 end;
end;
{$else}
var tv:{$if defined(Windows)}TTimeVal{$elseif defined(fpc)}TTimeVal{$else}TimeVal{$ifend};
    ReadSet,WriteSet:TRNLSocketSet;
    t:pointer;
    Index,r:TRNLSizeInt;
    MaxFD:TRNLInt32;
begin
 if aTimeout<0 then begin
  t:=nil;
 end else begin
  tv.tv_sec:=aTimeout div 1000;
  tv.tv_usec:=(aTimeout mod 1000)*1000;
  t:=@tv;
 end;
 MaxFD:=0;
{$if defined(Posix)}
  __fd_zero(ReadSet);
  __fd_zero(WriteSet);
  for Index:=0 to length(aEvents)-1 do begin
   __fd_set(aEvents[Index].fEventPipeFDs[0],ReadSet);
   MaxFD:=Max(MaxFD,aEvents[Index].fEventPipeFDs[0]);
  end;
{$elseif defined(Unix)}
  fpFD_ZERO(ReadSet);
  fpFD_ZERO(WriteSet);
  for Index:=0 to length(aEvents)-1 do begin
   fpFD_SET(aEvents[Index].fEventPipeFDs[0],ReadSet);
   MaxFD:=Max(MaxFD,aEvents[Index].fEventPipeFDs[0]);
  end;
{$else}
  FD_ZERO(ReadSet);
  FD_ZERO(WriteSet);
  for Index:=0 to length(aEvents)-1 do begin
   FD_SET(aEvents[Index].fEventPipeFDs[0],ReadSet);
   MaxFD:=Max(MaxFD,aEvents[Index].fEventPipeFDs[0]);
  end;
{$ifend}
{$if defined(fpc)}
 r:=fpselect(MaxFD+1,@ReadSet,@WriteSet,nil,t);
{$else}
 r:=Posix.SysSelect.select(MaxFD+1,@ReadSet,@WriteSet,nil,t);
{$ifend}
 if r<0 then begin
  if errno={$ifdef fpc}ESysEINTR{$else}EINTR{$endif} then begin
   result:=-2;
  end else begin
   result:=-3;
  end;
 end;
 result:=-1;
 if r>0 then begin
  for Index:=0 to length(aEvents)-1 do begin
   if {$if defined(Windows)}FD_ISSET(aEvents[Index].fEventPipeFDs[0],ReadSet)
      {$elseif defined(fpc)}
       fpFD_ISSET(aEvents[Index].fEventPipeFDs[0],ReadSet)=1
      {$else}
       __fd_isset(aEvents[Index].fEventPipeFDs[0],ReadSet)
      {$ifend} then begin
    aEvents[Index].ResetEvent;
    if result<0 then begin
     result:=Index;
    end;
   end;
  end;
 end;
end;
{$ifend}

{$if defined(fpc) and defined(Darwin)}
const NI_NUMERICHOST=1;
      NI_NUMERICSERV=2;
      NI_NOFQDN=4;
      NI_NAMEREQD=8;
      NI_DGRAM=16;

{$if not declared(TAddrInfo)}
type PAddrInfo=^TAddrInfo;
     TAddrInfo=record
      ai_flags:cint;
      ai_family:cint;
      ai_socktype:cint;
      ai_protocol:cint;
      ai_addrlen:TSockLen;
      ai_canonname:PAnsiChar;
      ai_addr:psockaddr;
      ai_next:PAddrInfo;
     end;
     PPAddrInfo=^PAddrInfo;
{$ifend}

function  getaddrinfo(name,service:PAnsiChar;hints:PAddrInfo;res:PPAddrInfo):cInt; cdecl; external 'c' name 'getaddrinfo';
function  getnameinfo(sa:PSockAddr;salen:TSockLen;host:PAnsiChar;hostlen:TSize;serv:PChar;servlen:TSize;flags:cInt):cInt; cdecl; external 'c' name 'getnameinfo';
procedure freeaddrinfo(ai:PAddrInfo); cdecl; external 'c' name 'freeaddrinfo';

{$ifend}

constructor TRNLNetwork.Create(const aInstance:TRNLInstance);
begin
 inherited Create;
 fInstance:=aInstance;
end;

destructor TRNLNetwork.Destroy;
begin
 inherited Destroy;
end;

function TRNLNetwork.AddressSetHost(var aAddress:TRNLAddress;const aName:TRNLRawByteString):boolean;
begin
 result:=false;
end;

function TRNLNetwork.AddressGetHost(const aAddress:TRNLAddress;out aName;const aNameLength:TRNLInt32;const aFlags:TRNLInt32=0):boolean;
begin
 result:=false;
end;

function TRNLNetwork.AddressGetHostIP(const aAddress:TRNLAddress;out aName;const aNameLength:TRNLInt32):boolean;
begin
 result:=false;
end;

function TRNLNetwork.AddressGetPrimaryInterfaceHostIP(var aAddress:TRNLAddress;const aFamily:TRNLAddressFamily;const aInterfaceHostAddressType:TRNLInterfaceHostAddressType=RNL_INTERFACE_HOST_ADDRESS_UNICAST):boolean;
begin
 result:=false;
end;

function TRNLNetwork.SocketCreate(const aType:TRNLSocketType;const aFamily:TRNLAddressFamily):TRNLSocket;
begin
 result:=RNL_SOCKET_NULL;
end;

procedure TRNLNetwork.SocketDestroy(const aSocket:TRNLSocket);
begin
end;

function TRNLNetwork.SocketShutdown(const aSocket:TRNLSocket;const aHow:TRNLSocketShutdown=RNL_SOCKET_SHUTDOWN_READ_WRITE):boolean;
begin
 result:=false;
end;

function TRNLNetwork.SocketGetAddress(const aSocket:TRNLSocket;out aAddress:TRNLAddress;const aFamily:TRNLAddressFamily):boolean;
begin
 result:=false;
end;

function TRNLNetwork.SocketSetOption(const aSocket:TRNLSocket;const aOption:TRNLSocketOption;const aValue:TRNLInt32):boolean;
begin
 result:=false;
end;

function TRNLNetwork.SocketGetOption(const aSocket:TRNLSocket;const aOption:TRNLSocketOption;out aValue:TRNLInt32):boolean;
begin
 result:=false;
end;

function TRNLNetwork.SocketBind(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aFamily:TRNLAddressFamily):boolean;
begin
 result:=false;
end;

function TRNLNetwork.SocketListen(const aSocket:TRNLSocket;const aBackLog:TRNLInt32):boolean;
begin
 result:=false;
end;

function TRNLNetwork.SocketConnect(const aSocket:TRNLSocket;const aAddress:TRNLAddress;const aFamily:TRNLAddressFamily):boolean;
begin
 result:=false;
end;

function TRNLNetwork.SocketAccept(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aFamily:TRNLAddressFamily):TRNLSocket;
begin
 result:=RNL_SOCKET_NULL;
end;

function TRNLNetwork.SocketSelect(const aMaxSocket:TRNLSocket;var aReadSet,aWriteSet:TRNLSocketSet;const aTimeout:TRNLInt64;const aEvent:TRNLNetworkEvent=nil):TRNLInt32;
begin
 result:=-1;
end;

function TRNLNetwork.SocketWait(const aSockets:array of TRNLSocket;var aConditions:TRNLSocketWaitConditions;const aTimeout:TRNLInt64;const aEvent:TRNLNetworkEvent=nil):boolean;
begin
 aConditions:=[];
 result:=false;
end;

function TRNLNetwork.Send(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aData;const aDataLength:TRNLSizeInt;const aFamily:TRNLAddressFamily):TRNLSizeInt;
begin
 result:=-1;
end;

function TRNLNetwork.Receive(const aSocket:TRNLSocket;const aAddress:PRNLAddress;out aData;const aDataLength:TRNLSizeInt;const aFamily:TRNLAddressFamily):TRNLSizeInt;
begin
 result:=-1;
end;

constructor TRNLRealNetwork.Create(const aInstance:TRNLInstance);
begin
 if RNLNetworkInitializationReferenceCounter=0 then begin
  GlobalInitialize;
  inc(RNLNetworkInitializationReferenceCounter);
 end;
 inherited Create(aInstance);
end;

destructor TRNLRealNetwork.Destroy;
begin
 inherited Destroy;
 if RNLNetworkInitializationReferenceCounter>0 then begin
  dec(RNLNetworkInitializationReferenceCounter);
  if RNLNetworkInitializationReferenceCounter=0 then begin
   GlobalFinalize;
  end;
 end;
end;

{$ifdef Windows}
function TRNLRealNetwork.EmulatePoll(const aPollFDs:PRNLRealNetworkPollFDs;const aCount:TRNLSizeInt;const aTimeout:TRNLInt64;const AEvent:TRNLNetworkEvent=nil):TRNLInt32;
var Timeout,Mask,CountEvents,LastResult:TRNLUInt32;
    Events:TRNLRealNetworkHandles;
    Count,Index:TRNLSizeInt;
    PollFD:PRNLRealNetworkPollFD;
    ReadSet,WriteSet,ExceptSet:TRNLSocketSet;
    tv:{$if defined(Windows)}TTimeVal{$elseif defined(fpc)}TTimeVal{$else}TimeVal{$ifend};
    NetworkEvents:TWSANETWORKEVENTS;
begin

 LastResult:=WSA_WAIT_FAILED;

 if aTimeout>=0 then begin
  Timeout:=aTimeout;
 end else begin
  Timeout:=INFINITE;
 end;

 if aCount=0 then begin

  if assigned(aEvent) then begin
   case WaitForSingleObject(aEvent.fEvent,Timeout) of
    WSA_WAIT_EVENT_0:begin
     result:=0;
    end;
    WSA_WAIT_TIMEOUT:begin
     result:=0;
    end;
    WSA_WAIT_IO_COMPLETION:begin
     result:=0;
    end;
    else {WSA_WAIT_FAILED:}begin
     result:=-1;
    end;
   end;
  end else begin
   if SleepEx(Timeout,true)=0 then begin
    result:=0;
   end else begin
    result:=-2;
   end;
  end;

  exit;

 end;

 Events:=nil;
 try

  if assigned(aEvent) then begin
   SetLength(Events,aCount+1);
  end else begin
   SetLength(Events,aCount);
  end;

  CountEvents:=0;

  for Index:=0 to aCount-1 do begin

   PollFD:=@aPollFDs^[Index];

   FD_ZERO(ReadSet);
   FD_ZERO(WriteSet);
   FD_ZERO(ExceptSet);
   FD_SET(PollFD^.fd,ExceptSet);

   Mask:=FD_CLOSE;

   if (PollFD^.events and POLLIN)<>0 then begin
    Mask:=Mask or FD_READ;
    FD_SET(PollFD^.fd,ReadSet);
   end;

   if (PollFD^.events and POLLOUT)<>0 then begin
    Mask:=Mask or FD_WRITE;
    FD_SET(PollFD^.fd,WriteSet);
   end;

   if (PollFD^.events and POLLRDNORM)<>0 then begin
    Mask:=Mask or (FD_READ or FD_ACCEPT);
    FD_SET(PollFD^.fd,ReadSet);
   end;

   if (PollFD^.events and POLLWRNORM)<>0 then begin
    Mask:=Mask or (FD_WRITE or FD_CONNECT);
    FD_SET(PollFD^.fd,WriteSet);
   end;

   if (PollFD^.events and POLLPRI)<>0 then begin
    Mask:=Mask or FD_OOB;
   end;

   PollFD^.revents:=0;

   Events[CountEvents]:=WSACreateEvent;

   if Events[CountEvents]=WSA_INVALID_EVENT then begin
    while CountEvents>0 do begin
     WSACloseEvent(Events[CountEvents]);
     dec(CountEvents);
    end;
    result:=-1;
    exit;
   end;

   if (WSAEventSelect(PollFD^.fd,Events[CountEvents],Mask)<>0) and
      (WSAGetLastError=WSAENOTSOCK) then begin
    PollFD^.revents:=PollFD^.revents or POLLNVAL;
   end;

   tv.tv_sec:=0;
   tv.tv_usec:=0;

   if _select(PollFD^.fd,@ReadSet,@WriteSet,@ExceptSet,@tv)>0 then begin
    if FD_ISSET(PollFD^.fd,ReadSet) then begin
     PollFD^.revents:=PollFD^.revents or (PollFD^.events and (POLLRDNORM or POLLIN));
    end;
    if FD_ISSET(PollFD^.fd,WriteSet) then begin
     PollFD^.revents:=PollFD^.revents or (PollFD^.events and (POLLWRNORM or POLLOUT));
    end;
    if FD_ISSET(PollFD^.fd,ExceptSet) then begin
     PollFD^.revents:=PollFD^.revents or (PollFD^.events and POLLPRI) or POLLERR;
    end;
   end;

   if (PollFD^.revents<>0) and (LastResult=WSA_WAIT_FAILED) then begin
    LastResult:=WSA_WAIT_EVENT_0+CountEvents;
   end;

   inc(CountEvents);

  end;

  if assigned(aEvent) then begin
   Events[CountEvents]:=aEvent.fEvent;
   inc(CountEvents);
  end;

  if LastResult=WSA_WAIT_FAILED then begin
   LastResult:=WSAWaitForMultipleEvents(CountEvents,@Events[0],false,Timeout,true);
  end;

  Count:=0;

  for Index:=0 to aCount-1 do begin

   PollFD:=@aPollFDs^[Index];

   if WSAEnumNetworkEvents(PollFD^.fd,Events[Index],@NetworkEvents)<>0 then begin
    FillChar(NetworkEvents,SizeOf(TWSANETWORKEVENTS),#0);
   end;

   WSAEventSelect(PollFD^.fd,Events[Index],0);
   WSACloseEvent(Events[Index]);

   if (NetworkEvents.lNetworkEvents and FD_CONNECT)<>0 then begin
    PollFD^.revents:=PollFD^.revents or POLLWRNORM;
    if NetworkEvents.iErrorCode[FD_CONNECT_BIT]<>0 then begin
     PollFD^.revents:=PollFD^.revents or POLLERR;
    end;
   end;

   if (NetworkEvents.lNetworkEvents and FD_CLOSE)<>0 then begin
    PollFD^.revents:=PollFD^.revents or ((PollFD^.events and POLLRDNORM) or POLLHUP);
    if NetworkEvents.iErrorCode[FD_CLOSE_BIT]<>0 then begin
     PollFD^.revents:=PollFD^.revents or POLLERR;
    end;
   end;

   if (NetworkEvents.lNetworkEvents and FD_ACCEPT)<>0 then begin
    PollFD^.revents:=PollFD^.revents or POLLRDNORM;
    if NetworkEvents.iErrorCode[FD_ACCEPT_BIT]<>0 then begin
     PollFD^.revents:=PollFD^.revents or POLLERR;
    end;
   end;

   if (NetworkEvents.lNetworkEvents and FD_OOB)<>0 then begin
    PollFD^.revents:=PollFD^.revents or POLLPRI;
    if NetworkEvents.iErrorCode[FD_OOB_BIT]<>0 then begin
     PollFD^.revents:=PollFD^.revents or POLLERR;
    end;
   end;

   if (NetworkEvents.lNetworkEvents and FD_READ)<>0 then begin
    PollFD^.revents:=PollFD^.revents or (POLLRDNORM or POLLIN);
    if NetworkEvents.iErrorCode[FD_READ_BIT]<>0 then begin
     PollFD^.revents:=PollFD^.revents or POLLERR;
    end;
   end;

   if (NetworkEvents.lNetworkEvents and FD_WRITE)<>0 then begin
    PollFD^.revents:=PollFD^.revents or (POLLWRNORM or POLLOUT);
    if NetworkEvents.iErrorCode[FD_WRITE_BIT]<>0 then begin
     PollFD^.revents:=PollFD^.revents or POLLERR;
    end;
   end;

   if PollFD^.revents<>0 then begin
    inc(Count);
   end;

  end;

  if Count=0 then begin
   for Index:=aCount to CountEvents-1 do begin
    if LastResult=TRNLUInt32(WSA_WAIT_EVENT_0+Index) then begin
     Count:=-3;
     break;
    end;
   end;
  end;

 finally
  Events:=nil;
 end;

 if (Count=0) and (LastResult=WSA_WAIT_IO_COMPLETION) then begin
  result:=-2;
 end else begin
  result:=Count;
 end;

end;
{$endif}

class procedure TRNLRealNetwork.GlobalInitialize;
{$if defined(Windows)}
var versionRequested:TRNLUInt16;
    vWSAData:TWSAData;
begin
 WinSock2LibHandle:=0;
 versionRequested:=MAKEWORD(2,2);
 if WSAStartup(versionRequested,vWSAData)<>0 then begin
  raise ERNLNetwork.Create('Incompatible WinSocks version');
 end;
 WinSock2LibHandle:=LoadLibrary(PChar('ws2_32.dll'));
 if (WinSock2LibHandle=0) or ((LOBYTE(vWSAData.wVersion)<>2) or (HIBYTE(vWSAData.wVersion)<>2)) then begin
  WSACleanup;
  raise ERNLNetwork.Create('Incompatible WinSocks version');
 end;
 GetAddrInfo:=GetProcAddress(WinSock2LibHandle,PAnsiChar(AnsiString('getaddrinfo')));
 FreeAddrInfo:=GetProcAddress(WinSock2LibHandle,PAnsiChar(AnsiString('freeaddrinfo')));
 GetNameInfo:=GetProcAddress(WinSock2LibHandle,PAnsiChar(AnsiString('getnameinfo')));
 if not (assigned(GetAddrInfo) and assigned(FreeAddrInfo) and assigned(GetNameInfo)) then begin
  FreeLibrary(WinSock2LibHandle);
  WinSock2LibHandle:=LoadLibrary(PChar('wship6.dll'));
  GetAddrInfo:=GetProcAddress(WinSock2LibHandle,PAnsiChar(AnsiString('getaddrinfo')));
  FreeAddrInfo:=GetProcAddress(WinSock2LibHandle,PAnsiChar(AnsiString('freeaddrinfo')));
  GetNameInfo:=GetProcAddress(WinSock2LibHandle,PAnsiChar(AnsiString('getnameinfo')));
  if not (assigned(GetAddrInfo) and assigned(FreeAddrInfo) and assigned(GetNameInfo)) then begin
   FreeLibrary(WinSock2LibHandle);
   WinSock2LibHandle:=0;
   WSACleanup;
   raise ERNLNetwork.Create('Incompatible WinSocks version');
  end;
 end;
end;
{$else}
begin
end;
{$ifend}

class procedure TRNLRealNetwork.GlobalFinalize;
{$if defined(Windows)}
begin
 WSACleanup;
 FreeLibrary(WinSock2LibHandle);
end;
{$else}
begin
end;
{$ifend}

function TRNLRealNetwork.AddressSetHost(var aAddress:TRNLAddress;const aName:TRNLRawByteString):boolean;
{$if defined(Windows)}
var TempPort:TRNLUInt16;
    Hints:TAddrInfo;
    r,res:PAddrInfo;
begin
 TempPort:=aAddress.Port;
 FillChar(Hints,SizeOf(TAddrInfo),AnsiChar(#0));
 hints.ai_flags:=AI_ADDRCONFIG;
 hints.ai_family:=AF_UNSPEC;
 if getaddrinfo(PAnsiChar(aName),nil,@hints,@r)<>0 then begin
  result:=false;
  exit;
 end;
 try
  res:=r;
  while assigned(res) do begin
   if aAddress.SetAddress(res^.ai_addr)<>RNL_NO_ADDRESS_FAMILY then begin
    break;
   end;
   res:=res^.ai_next;
  end;
  aAddress.Port:=TempPort;
 finally
  freeaddrinfo(r);
 end;
 if not assigned(res) then begin
  result:=false;
  exit;
 end;
 result:=true;
end;
{$else}
var TempPort:TRNLUInt16;
    Hints:TAddrInfo;
    r,res:PAddrInfo;
begin
 TempPort:=aAddress.Port;
 FillChar(Hints,SizeOf(TAddrInfo),#0);
 hints.ai_flags:=AI_ADDRCONFIG;
 hints.ai_family:=AF_UNSPEC;
 if getaddrinfo({$ifdef NEXTGEN}MarshaledAString{$else}PAnsiChar{$endif}(aName),nil,{$ifdef fpc}@hints,@r{$else}hints,r{$endif})<>0 then begin
  result:=false;
  exit;
 end;
 try
  res:=r;
  while assigned(res) do begin
   if aAddress.SetAddress(res^.ai_addr)<>RNL_NO_ADDRESS_FAMILY then begin
    break;
   end;
   res:=res^.ai_next;
  end;
  aAddress.Port:=TempPort;
 finally
  freeaddrinfo({$ifdef fpc}r{$else}r^{$endif});
 end;
 if not assigned(res) then begin
  result:=false;
  exit;
 end;
 result:=true;
end;
{$ifend}

function TRNLRealNetwork.AddressGetHost(const aAddress:TRNLAddress;out aName;const aNameLength:TRNLInt32;const aFlags:TRNLInt32=0):boolean;
var SIN:TSockaddrStorage;
begin
 aAddress.SetSIN(@SIN,RNL_IPV6);
{$if defined(Windows)}
 result:=GetNameInfo(TRNLPointer(@SIN),TRNLAddressFamily(RNL_IPV6).GetSockAddrSize,@aName,aNameLength,nil,0,aFlags)<>0;
{$elseif defined(fpc)}
 result:=getnameinfo(TRNLPointer(@SIN),TRNLAddressFamily(RNL_IPV6).GetSockAddrSize,@aName,aNameLength,nil,0,aFlags)<>0;
{$else}
 result:=getnameinfo(sockaddr(TRNLPointer(@SIN)^),TRNLAddressFamily(RNL_IPV6).GetSockAddrSize,@aName,aNameLength,nil,0,aFlags)<>0;
{$ifend}
end;

function TRNLRealNetwork.AddressGetHostIP(const aAddress:TRNLAddress;out aName;const aNameLength:TRNLInt32):boolean;
begin
 result:=AddressGetHost(aAddress,aName,aNameLength,NI_NUMERICHOST);
end;

function TRNLRealNetwork.AddressGetPrimaryInterfaceHostIP(var aAddress:TRNLAddress;const aFamily:TRNLAddressFamily;const aInterfaceHostAddressType:TRNLInterfaceHostAddressType=RNL_INTERFACE_HOST_ADDRESS_UNICAST):boolean;
{$if defined(Windows)}
var AdapterSize:DWORD;
    Adapters,Adapter:PIP_ADAPTER_ADDRESSES;
    AdapterUnicastAddress:PIP_ADAPTER_UNICAST_ADDRESS;
    AdapterMulticastAddress:PIP_ADAPTER_MULTICAST_ADDRESS;
    Found:boolean;
    Temp:array[0..255] of AnsiChar;
begin
 case aFamily of
  RNL_IPV4,RNL_IPV6:begin
   AdapterSize:=20000;
   Adapters:=nil;
   try
    repeat
     GetMem(Adapters,AdapterSize);
     case GetAdaptersAddresses(AF_UNSPEC,GAA_FLAG_INCLUDE_PREFIX,nil,Adapters,@AdapterSize) of
      ERROR_BUFFER_OVERFLOW:begin
       FreeMem(Adapters);
       Adapters:=nil;
      end;
      ERROR_SUCCESS:begin
       break;
      end;
      else begin
       FreeMem(Adapters);
       Adapters:=nil;
       break;
      end;
     end;
    until assigned(Adapters);
    Adapter:=Adapters;
    Found:=false;
    while assigned(Adapter) and not Found do begin
     if (Adapter^.IfType<>24{IF_TYPE_SOFTWARE_LOOPBACK}) and
        (Adapter^.OperStatus=IfOperStatusUp) then begin
      case aInterfaceHostAddressType of
       RNL_INTERFACE_HOST_ADDRESS_UNICAST:begin
        AdapterUnicastAddress:=Adapter^.FirstUnicastAddress;
        while assigned(AdapterUnicastAddress) and not Found do begin
         if ((aFamily=RNL_IPV4) and (AdapterUnicastAddress^.Address.lpSockaddr^.sa_family=AF_INET)) or
            ((aFamily=RNL_IPV6) and (AdapterUnicastAddress^.Address.lpSockaddr^.sa_family=AF_INET6)) then begin
          FillChar(Temp,SizeOf(Temp),#0);
          GetNameInfo(pointer(AdapterUnicastAddress^.Address.lpSockaddr),
                      AdapterUnicastAddress^.Address.iSockaddrLength,
                      @Temp[0],
                      SizeOf(Temp)-1,
                      nil,
                      0,
                      NI_NUMERICHOST);
          aAddress:=TRNLAddress.CreateFromString(String(PAnsiChar(@Temp[0])));
          Found:=true;
          break;
         end;
         AdapterUnicastAddress:=AdapterUnicastAddress^.Next;
        end;
       end;
       RNL_INTERFACE_HOST_ADDRESS_MULTICAST:begin
        AdapterMulticastAddress:=Adapter^.FirstMulticastAddress;
        while assigned(AdapterMulticastAddress) and not Found do begin
         if ((aFamily=RNL_IPV4) and (AdapterMulticastAddress^.Address.lpSockaddr^.sa_family=AF_INET)) or
            ((aFamily=RNL_IPV6) and (AdapterMulticastAddress^.Address.lpSockaddr^.sa_family=AF_INET6)) then begin
          FillChar(Temp,SizeOf(Temp),#0);
          GetNameInfo(pointer(AdapterMulticastAddress^.Address.lpSockaddr),
                      AdapterMulticastAddress^.Address.iSockaddrLength,
                      @Temp[0],
                      SizeOf(Temp)-1,
                      nil,
                      0,
                      NI_NUMERICHOST);
          aAddress:=TRNLAddress.CreateFromString(String(PAnsiChar(@Temp[0])));
          Found:=true;
          break;
         end;
         AdapterMulticastAddress:=AdapterMulticastAddress^.Next;
        end;
       end;
      end;
     end;
     Adapter:=Adapter^.Next;
    end;
   finally
    if assigned(Adapters) then begin
     FreeMem(Adapters);
    end;
   end;
   result:=Found;
  end;
  else
  begin
   result:=false;
  end;
 end;
end;
{$else}
begin
 result:=false;
end;
{$ifend}

function TRNLRealNetwork.SocketCreate(const aType:TRNLSocketType;const aFamily:TRNLAddressFamily):TRNLSocket;
{$if defined(Windows)}
begin
 if aType=RNL_SOCKET_TYPE_DATAGRAM then begin
  result:=_Socket(aFamily.GetAddressFamily,SOCK_DGRAM,0);
 end else begin
  result:=_Socket(aFamily.GetAddressFamily,SOCK_STREAM,0);
 end;
end;
{$else}
{$if defined(fpc) and defined(Darwin)}
const TemporaryInt32:TRNLInt32=1;
{$ifend}
begin
{$ifdef fpc}
 if aType=RNL_SOCKET_TYPE_DATAGRAM then begin
  result:=fpsocket(aFamily.GetAddressFamily,SOCK_DGRAM{$if defined(Linux) or defined(Android)}or SOCK_CLOEXEC{$ifend},0);
 end else begin
  result:=fpsocket(aFamily.GetAddressFamily,SOCK_STREAM{$if defined(Linux) or defined(Android)}or SOCK_CLOEXEC{$ifend},0);
 end;
{$ifdef Darwin}
 fpsetsockopt(result,SOL_SOCKET,SO_NOSIGPIPE,TRNLPointer(@TemporaryInt32),SizeOf(TRNLInt32));
{$endif}
{$else}
 if aType=RNL_SOCKET_TYPE_DATAGRAM then begin
  result:=Posix.SysSocket.socket(aFamily.GetAddressFamily,SOCK_DGRAM{$if defined(Linux) or defined(Android)}or SOCK_CLOEXEC{$ifend},0);
 end else begin
  result:=Posix.SysSocket.socket(aFamily.GetAddressFamily,SOCK_STREAM{$if defined(Linux) or defined(Android)}or SOCK_CLOEXEC{$ifend},0);
 end;
{$endif}
end;
{$ifend}

procedure TRNLRealNetwork.SocketDestroy(const aSocket:TRNLSocket);
{$if defined(Windows)}
begin
 if aSocket<>RNL_INVALID_SOCKET then begin
  CloseSocket(aSocket);
 end;
end;
{$else}
begin
 if aSocket<>RNL_INVALID_SOCKET then begin
{$ifdef fpc}
  CloseSocket(aSocket);
{$else}
  Posix.Unistd.__close(aSocket);
{$endif}
 end;
end;
{$ifend}

function TRNLRealNetwork.SocketShutdown(const aSocket:TRNLSocket;const aHow:TRNLSocketShutdown=RNL_SOCKET_SHUTDOWN_READ_WRITE):boolean;
begin
{$if defined(Windows)}
 result:=_shutdown(aSocket,TRNLINt32(aHow))<>SOCKET_ERROR;
{$elseif defined(fpc)}
 result:=fpshutdown(aSocket,TRNLInt32(aHow))<>SOCKET_ERROR;
{$else}
 result:=Posix.SysSocket.shutdown(aSocket,TRNLInt32(aHow))<>SOCKET_ERROR;
{$ifend}
end;

function TRNLRealNetwork.SocketGetAddress(const aSocket:TRNLSocket;out aAddress:TRNLAddress;const aFamily:TRNLAddressFamily):boolean;
var SIN:TSockaddrStorage;
    SINLength:{$if defined(Windows)}TRNLInt32{$else}socklen_t{$ifend};
    TemporaryAddress:TRNLAddress;
begin
 SINLength:=aFamily.GetSockAddrSize;
{$if defined(Windows)}
 if getsockname(aSocket,TSockAddr(TRNLPointer(@SIN)^),SINLength)=-1 then begin
  result:=false;
 end else begin
  if TemporaryAddress.SetAddress(@SIN)=RNL_NO_ADDRESS_FAMILY then begin
   result:=false;
  end else begin
   aAddress:=TemporaryAddress;
   result:=false;
  end;
 end;
{$else}
 if {$ifdef fpc}
     fpgetsockname(aSocket,TRNLPointer(@SIN),@SINLength)=-1
    {$else}
     getsockname(aSocket,sockaddr(TRNLPointer(@SIN)^),SINLength)=-1
    {$endif} then begin
  result:=false;
 end else begin
  if TemporaryAddress.SetAddress(@SIN)=RNL_NO_ADDRESS_FAMILY then begin
   result:=false;
  end else begin
   aAddress:=TemporaryAddress;
   result:=true;
  end;
 end;
{$ifend}
end;

function TRNLRealNetwork.SocketSetOption(const aSocket:TRNLSocket;const aOption:TRNLSocketOption;const aValue:TRNLInt32):boolean;
{$if defined(Windows)}
var r:TRNLInt32;
    nonBlocking:TRNLUInt32;
begin
 r:=SOCKET_ERROR;
 case aOption of
  RNL_SOCKET_OPTION_NONBLOCK:begin
   nonBlocking:=aValue;
   r:=ioctlsocket(aSocket,FIONBIO,nonBlocking);
  end;
  RNL_SOCKET_OPTION_BROADCAST:begin
   r:=setsockopt(aSocket,SOL_SOCKET,SO_BROADCAST,TRNLPointer(@aValue),SizeOf(TRNLInt32));
  end;
  RNL_SOCKET_OPTION_REUSEADDR:begin
   r:=setsockopt(aSocket,SOL_SOCKET,SO_REUSEADDR,TRNLPointer(@aValue),SizeOf(TRNLInt32));
  end;
  RNL_SOCKET_OPTION_RCVBUF:begin
   r:=setsockopt(aSocket,SOL_SOCKET,SO_RCVBUF,TRNLPointer(@aValue),SizeOf(TRNLInt32));
  end;
  RNL_SOCKET_OPTION_SNDBUF:begin
   r:=setsockopt(aSocket,SOL_SOCKET,SO_SNDBUF,TRNLPointer(@aValue),SizeOf(TRNLInt32));
  end;
  RNL_SOCKET_OPTION_RCVTIMEO:begin
   r:=setsockopt(aSocket,SOL_SOCKET,SO_RCVTIMEO,TRNLPointer(@aValue),SizeOf(TRNLInt32));
  end;
  RNL_SOCKET_OPTION_SNDTIMEO:begin
   r:=setsockopt(aSocket,SOL_SOCKET,SO_SNDTIMEO,TRNLPointer(@aValue),SizeOf(TRNLInt32));
  end;
  RNL_SOCKET_OPTION_NODELAY:begin
   r:=setsockopt(aSocket,IPPROTO_TCP,TCP_NODELAY,TRNLPointer(@aValue),SizeOf(TRNLInt32));
  end;
  RNL_SOCKET_OPTION_DONTFRAGMENT:begin
   r:=setsockopt(aSocket,IPPROTO_IP,IP_DONTFRAGMENT,TRNLPointer(@aValue),SizeOf(TRNLInt32));
  end;
  RNL_SOCKET_OPTION_IPV6_V6ONLY:begin
   r:=setsockopt(aSocket,IPPROTO_IPV6,IPV6_V6ONLY,TRNLPointer(@aValue),SizeOf(TRNLInt32));
  end;
 end;
 result:=r<>SOCKET_ERROR;
end;
{$elseif defined(fpc)}
var r,t:TRNLInt32;
    nonBlocking:TRNLUInt32;
    tv:TTimeVal;
begin
 r:=SOCKET_ERROR;
 case aOption of
  RNL_SOCKET_OPTION_NONBLOCK:begin
   nonBlocking:=aValue;
   r:=fpioctl(aSocket,FIONBIO,TRNLPointer(@nonBlocking));
  end;
  RNL_SOCKET_OPTION_BROADCAST:begin
   r:=fpsetsockopt(aSocket,SOL_SOCKET,SO_BROADCAST,TRNLPointer(@aValue),SizeOf(TRNLInt32));
  end;
  RNL_SOCKET_OPTION_REUSEADDR:begin
   r:=fpsetsockopt(aSocket,SOL_SOCKET,SO_REUSEADDR,TRNLPointer(@aValue),SizeOf(TRNLInt32));
  end;
  RNL_SOCKET_OPTION_RCVBUF:begin
   r:=fpsetsockopt(aSocket,SOL_SOCKET,SO_RCVBUF,TRNLPointer(@aValue),SizeOf(TRNLInt32));
  end;
  RNL_SOCKET_OPTION_SNDBUF:begin
   r:=fpsetsockopt(aSocket,SOL_SOCKET,SO_SNDBUF,TRNLPointer(@aValue),SizeOf(TRNLInt32));
  end;
  RNL_SOCKET_OPTION_RCVTIMEO:begin
   tv.tv_sec:=aValue div 1000;
   tv.tv_usec:=(aValue mod 1000)*1000;
   r:=fpsetsockopt(aSocket,SOL_SOCKET,SO_RCVTIMEO,TRNLPointer(@tv),SizeOf(TTimeVal));
  end;
  RNL_SOCKET_OPTION_SNDTIMEO:begin
   tv.tv_sec:=aValue div 1000;
   tv.tv_usec:=(aValue mod 1000)*1000;
   r:=fpsetsockopt(aSocket,SOL_SOCKET,SO_SNDTIMEO,TRNLPointer(@tv),SizeOf(TTimeVal));
  end;
  RNL_SOCKET_OPTION_NODELAY:begin
   r:=fpsetsockopt(aSocket,IPPROTO_TCP,TCP_NODELAY,TRNLPointer(@aValue),SizeOf(TRNLInt32));
  end;
  RNL_SOCKET_OPTION_DONTFRAGMENT:begin
{$if defined(Linux) or defined(Android)}
   if aValue<>0 then begin
    t:=IP_PMTUDISC_DO;
   end else begin
    t:=IP_PMTUDISC_DONT;
   end;
   r:=fpsetsockopt(aSocket,IPPROTO_IP,IP_MTU_DISCOVER,TRNLPointer(@t),SizeOf(TRNLInt32));
{$else}
   t:=aValue;
   r:=fpsetsockopt(aSocket,IPPROTO_IP,IP_DONTFRAG,TRNLPointer(@t),SizeOf(TRNLInt32));
{$ifend}
  end;
  RNL_SOCKET_OPTION_IPV6_V6ONLY:begin
   r:=fpsetsockopt(aSocket,IPPROTO_IPV6,IPV6_V6ONLY,TRNLPointer(@aValue),SizeOf(TRNLInt32));
  end;
 end;
 result:=r<>SOCKET_ERROR;
end;
{$else}
var r,t:TRNLInt32;
    nonBlocking:TRNLUInt32;
    tv:TimeVal;
begin
 r:=SOCKET_ERROR;
 case aOption of
  RNL_SOCKET_OPTION_NONBLOCK:begin
   nonBlocking:=aValue;
   r:=ioctl(aSocket,FIONBIO,TRNLPointer(@nonBlocking));
  end;
  RNL_SOCKET_OPTION_BROADCAST:begin
   r:=setsockopt(aSocket,SOL_SOCKET,SO_BROADCAST,aValue,SizeOf(TRNLInt32));
  end;
  RNL_SOCKET_OPTION_REUSEADDR:begin
   r:=setsockopt(aSocket,SOL_SOCKET,SO_REUSEADDR,aValue,SizeOf(TRNLInt32));
  end;
  RNL_SOCKET_OPTION_RCVBUF:begin
   r:=setsockopt(aSocket,SOL_SOCKET,SO_RCVBUF,aValue,SizeOf(TRNLInt32));
  end;
  RNL_SOCKET_OPTION_SNDBUF:begin
   r:=setsockopt(aSocket,SOL_SOCKET,SO_SNDBUF,aValue,SizeOf(TRNLInt32));
  end;
  RNL_SOCKET_OPTION_RCVTIMEO:begin
   tv.tv_sec:=aValue div 1000;
   tv.tv_usec:=(aValue mod 1000)*1000;
   r:=setsockopt(aSocket,SOL_SOCKET,SO_RCVTIMEO,tv,SizeOf(TimeVal));
  end;
  RNL_SOCKET_OPTION_SNDTIMEO:begin
   tv.tv_sec:=aValue div 1000;
   tv.tv_usec:=(aValue mod 1000)*1000;
   r:=setsockopt(aSocket,SOL_SOCKET,SO_SNDTIMEO,tv,SizeOf(TimeVal));
  end;
  RNL_SOCKET_OPTION_NODELAY:begin
   r:=setsockopt(aSocket,IPPROTO_TCP,TCP_NODELAY,aValue,SizeOf(TRNLInt32));
  end;
  RNL_SOCKET_OPTION_DONTFRAGMENT:begin
{$if defined(Linux) or defined(Android)}
   if aValue<>0 then begin
    t:=IP_PMTUDISC_DO;
   end else begin
    t:=IP_PMTUDISC_DONT;
   end;
   r:=setsockopt(aSocket,IPPROTO_IP,IP_MTU_DISCOVER,t,SizeOf(TRNLInt32));
{$else}
   t:=aValue;
   r:=setsockopt(aSocket,IPPROTO_IP,IP_DONTFRAG,t,SizeOf(TRNLInt32));
{$ifend}
  end;
  RNL_SOCKET_OPTION_IPV6_V6ONLY:begin
   r:=setsockopt(aSocket,IPPROTO_IPV6,IPV6_V6ONLY,aValue,SizeOf(TRNLInt32));
  end;
 end;
 result:=r<>SOCKET_ERROR;
end;
{$ifend}

function TRNLRealNetwork.SocketGetOption(const aSocket:TRNLSocket;const aOption:TRNLSocketOption;out aValue:TRNLInt32):boolean;
{$if defined(Windows)}
var r:TRNLInt32;
begin
 r:=SOCKET_ERROR;
 case aOption of
  RNL_SOCKET_OPTION_ERROR:begin
   r:=setsockopt(aSocket,SOL_SOCKET,SO_ERROR,TRNLPointer(@aValue),SizeOf(TRNLInt32));
  end;
 end;
 result:=r<>SOCKET_ERROR;
end;
{$else}
var r:TRNLInt32;
    SockLen:socklen_t;
begin
 r:=SOCKET_ERROR;
 case aOption of
  RNL_SOCKET_OPTION_ERROR:begin
   SockLen:=SizeOf(TRNLInt32);
{$ifdef fpc}
   r:=fpgetsockopt(aSocket,SOL_SOCKET,SO_ERROR,TRNLPointer(@aValue),@SockLen);
{$else}
   r:=getsockopt(aSocket,SOL_SOCKET,SO_ERROR,aValue,SockLen);
{$endif}
  end;
 end;
 result:=r<>SOCKET_ERROR;
end;
{$ifend}

function TRNLRealNetwork.SocketBind(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aFamily:TRNLAddressFamily):boolean;
var SIN:TSockaddrStorage;
    Address_:TRNLAddress;
begin
 if assigned(aAddress) then begin
  aAddress^.SetSIN(@SIN,aFamily);
 end else begin
  Address_.Host:=RNL_HOST_ANY_INIT;
  Address_.ScopeID:=0;
  Address_.Port:=0;
  Address_.SetSIN(@SIN,aFamily);
 end;
{$if defined(Windows)}
 result:=_bind(aSocket,TRNLPointer(@SIN),aFamily.GetSockAddrSize)<>SOCKET_ERROR;
{$elseif defined(fpc)}
 result:=fpbind(aSocket,TRNLPointer(@SIN),aFamily.GetSockAddrSize)<>SOCKET_ERROR;
{$else}
 result:=Posix.SysSocket.bind(aSocket,sockaddr(TRNLPointer(@SIN)^),aFamily.GetSockAddrSize)<>SOCKET_ERROR;
{$ifend}
end;

function TRNLRealNetwork.SocketListen(const aSocket:TRNLSocket;const aBackLog:TRNLInt32):boolean;
begin
{$if defined(Windows)}
 if aBackLog<0 then begin
  result:=_listen(aSocket,SOMAXCONN)<>SOCKET_ERROR;
 end else begin
  result:=_listen(aSocket,aBackLog)<>SOCKET_ERROR;
 end;
{$elseif defined(fpc)}
 if aBackLog<0 then begin
  result:=fplisten(aSocket,SOMAXCONN)<>SOCKET_ERROR;
 end else begin
  result:=fplisten(aSocket,aBackLog)<>SOCKET_ERROR;
 end;
{$else}
 if aBackLog<0 then begin
  result:=Posix.SysSocket.listen(aSocket,SOMAXCONN)<>SOCKET_ERROR;
 end else begin
  result:=Posix.SysSocket.listen(aSocket,aBackLog)<>SOCKET_ERROR;
 end;
{$ifend}
end;

function TRNLRealNetwork.SocketConnect(const aSocket:TRNLSocket;const aAddress:TRNLAddress;const aFamily:TRNLAddressFamily):boolean;
var r:TRNLInt32;
    SIN:TSockaddrStorage;
begin
 aAddress.SetSIN(@SIN,aFamily);
{$if defined(Windows)}
 r:=_Connect(aSocket,TRNLPointer(@SIN),aFamily.GetSockAddrSize);
 result:=not ((r=SOCKET_ERROR) and (WSAGetLastError<>WSAEWOULDBLOCK));
{$elseif defined(fpc)}
 r:=fpconnect(aSocket,TRNLPointer(@SIN),aFamily.GetSockAddrSize);
 if (r=SOCKET_ERROR) and (fpgeterrno=ESysEINPROGRESS) then begin
  result:=true;
 end else begin
  result:=r<>SOCKET_ERROR;
 end;
{$else}
 r:=Posix.SysSocket.connect(aSocket,sockaddr(TRNLPointer(@SIN)^),aFamily.GetSockAddrSize);
 if (r=SOCKET_ERROR) and (Posix.Errno.Errno=EINPROGRESS) then begin
  result:=true;
 end else begin
  result:=r<>SOCKET_ERROR;
 end;
{$ifend}
end;

function TRNLRealNetwork.SocketAccept(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aFamily:TRNLAddressFamily):TRNLSocket;
var SIN:TSockaddrStorage;
    SINLength:{$if defined(Windows)}TRNLInt32{$else}socklen_t{$ifend};
begin
 SINLength:=aFamily.GetSockAddrSize;
{$if defined(Windows)}
 if assigned(aAddress) then begin
  result:=_accept(aSocket,TSockAddr(TRNLPointer(@SIN)^),SINLength);
 end else begin
  result:=_accept(aSocket,TSockAddr(TRNLPointer(nil)^),TRNLInt32(TRNLPointer(nil)^));
 end;
{$elseif defined(fpc)}
 if assigned(aAddress) then begin
  result:=fpaccept(aSocket,TRNLPointer(@SIN),@SINLength);
 end else begin
  result:=fpaccept(aSocket,nil,nil);
 end;
{$else}
 if assigned(aAddress) then begin
  result:=Posix.SysSocket.accept(aSocket,sockaddr(TRNLPointer(@SIN)^),SINLength);
 end else begin
  result:=Posix.SysSocket.accept(aSocket,sockaddr(TRNLPointer(nil)^),socklen_t(TRNLPointer(nil)^));
 end;
{$ifend}
 if result=RNL_INVALID_SOCKET then begin
  result:=RNL_SOCKET_NULL;
  exit;
 end;
 if assigned(aAddress) then begin
  aAddress.SetAddress(@SIN);
 end;
end;

function TRNLRealNetwork.SocketSelect(const aMaxSocket:TRNLSocket;var aReadSet,aWriteSet:TRNLSocketSet;const aTimeout:TRNLInt64;const aEvent:TRNLNetworkEvent=nil):TRNLInt32;
{$if defined(Windows)}
// Under Windows, we use the self-simulated POSIX-style poll function,
// so that we can also wait on an event additionally, if needed
type TPollFDs=array[0..63] of TRNLRealNetworkPollFD;
var Index,SubIndex,Found,CountPollFDs,PollCount:TRNLInt32;
    PollFDs:TPollFDs;
    tv:{$if defined(Windows)}TTimeVal{$elseif defined(fpc)}TTimeVal{$else}TimeVal{$ifend};
    t:pointer;
begin

 if assigned(aEvent) then begin

  PollFDs[0].events:=0;

  CountPollFDs:=0;

  for Index:=0 to aReadSet.fd_count-1 do begin
   Found:=-1;
   for SubIndex:=0 to CountPollFDs-1 do begin
    if PollFDs[SubIndex].fd=aReadSet.fd_array[Index] then begin
     Found:=SubIndex;
     break;
    end;
   end;
   if Found<0 then begin
    Found:=CountPollFDs;
    inc(CountPollFDs);
    PollFDs[Found].fd:=aReadSet.fd_array[Index];
    PollFDs[Found].events:=0;
    PollFDs[Found].revents:=0;
   end;
   PollFDs[Found].events:=PollFDs[Found].events or POLLIN;
  end;

  for Index:=0 to aWriteSet.fd_count-1 do begin
   Found:=-1;
   for SubIndex:=0 to CountPollFDs-1 do begin
    if PollFDs[SubIndex].fd=aWriteSet.fd_array[Index] then begin
     Found:=SubIndex;
     break;
    end;
   end;
   if Found<0 then begin
    Found:=CountPollFDs;
    inc(CountPollFDs);
    PollFDs[Found].fd:=aWriteSet.fd_array[Index];
    PollFDs[Found].events:=0;
    PollFDs[Found].revents:=0;
   end;
   PollFDs[Found].events:=PollFDs[Found].events or POLLOUT;
  end;

  FD_ZERO(aReadSet);
  FD_ZERO(aWriteSet);

  PollCount:=EmulatePoll(@PollFDs[0],CountPollFDs,aTimeout,aEvent);

  if PollCount<0 then begin
   if PollCount=-3 then begin
    result:=0;
   end else begin
    result:=-1;
   end;
   exit;
  end;

  result:=0;

  for Index:=0 to CountPollFDs-1 do begin
   if (PollFDs[Index].revents and (POLLIN or POLLOUT))<>0 then begin
    if (PollFDs[Index].revents and POLLIN)<>0 then begin
     FD_SET(PollFDs[Index].FD,aReadSet);
    end;
    if (PollFDs[Index].revents and POLLOUT)<>0 then begin
     FD_SET(PollFDs[Index].FD,aWriteSet);
    end;
    inc(result);
   end;
  end;

 end else begin

  if aTimeout<0 then begin
   t:=nil;
  end else begin
   tv.tv_sec:=aTimeout div 1000;
   tv.tv_usec:=(aTimeout mod 1000)*1000;
   t:=@tv;
  end;
  result:=_select(aMaxSocket+1,@aReadSet,@aWriteSet,nil,t);

 end;

end;
{$else}
var tv:{$if defined(Windows)}TTimeVal{$elseif defined(fpc)}TTimeVal{$else}TimeVal{$ifend};
    t:pointer;
{$if not defined(Windows)}
    ReadSet,WriteSet:TRNLSocketSet;
{$ifend}
begin
 if aTimeout<0 then begin
  t:=nil;
 end else begin
  tv.tv_sec:=aTimeout div 1000;
  tv.tv_usec:=(aTimeout mod 1000)*1000;
  t:=@tv;
 end;
{$if defined(Windows)}
 result:=_select(aMaxSocket+1,@aReadSet,@aWriteSet,nil,t);
{$else}
 if assigned(aEvent) then begin
  ReadSet:=aReadSet;
  WriteSet:=aWriteSet;
{$if defined(Posix)}
   __fd_set(aEvent.fEventPipeFDs[0],ReadSet);
{$elseif defined(Unix)}
   fpFD_SET(aEvent.fEventPipeFDs[0],ReadSet);
{$else}
   FD_SET(aEvent.fEventPipeFDs[0],ReadSet);
{$ifend}
{$if defined(fpc)}
  result:=fpselect(Max(aEvent.fEventPipeFDs[0],aMaxSocket)+1,@ReadSet,@WriteSet,nil,t);
{$elseif defined(NextGen) or defined(Android) or defined(iOS)}
  if aEvent.fEventPipeFDs[0]<aMaxSocket then begin
   result:=Posix.SysSelect.select(aMaxSocket+1,@ReadSet,@WriteSet,nil,t);
  end else begin
   result:=Posix.SysSelect.select(aEvent.fEventPipeFDs[0]+1,@ReadSet,@WriteSet,nil,t);
  end;
{$else}
  result:=Posix.SysSelect.select(Max(aEvent.fEventPipeFDs[0],aMaxSocket)+1,@ReadSet,@WriteSet,nil,t);
{$ifend}
  if {$if defined(Windows)}FD_ISSET(aEvent.fEventPipeFDs[0],ReadSet)
     {$elseif defined(fpc)}
      fpFD_ISSET(aEvent.fEventPipeFDs[0],ReadSet)=1
     {$else}
      __fd_isset(aEvent.fEventPipeFDs[0],ReadSet)
     {$ifend} then begin
   aEvent.ResetEvent;
  end;
 end else begin
{$if defined(fpc)}
  result:=fpselect(aMaxSocket+1,@aReadSet,@aWriteSet,nil,t);
{$else}
  result:=Posix.SysSelect.select(aMaxSocket+1,@aReadSet,@aWriteSet,nil,t);
{$ifend}
 end;
{$ifend}
end;
{$ifend}

function TRNLRealNetwork.SocketWait(const aSockets:array of TRNLSocket;var aConditions:TRNLSocketWaitConditions;const aTimeout:TRNLInt64;const aEvent:TRNLNetworkEvent=nil):boolean;
{$if defined(Windows)}
// Under Windows, we do simulate the POSIX-style poll function ourself,
// so that we can also wait on an event additionally, if needed
type TPollFDs=array[0..1] of TRNLRealNetworkPollFD;
var Index,CountPollFDs,PollCount,SelectCount:TRNLInt32;
    PollFDs:TPollFDs;
    ReadSet,WriteSet:TRNLSocketSet;
    tv:{$if defined(Windows)}TTimeVal{$elseif defined(fpc)}TTimeVal{$else}TimeVal{$ifend};
    t:pointer;
    MaxSocket:TRNLSocket;
begin

 if assigned(aEvent) then begin

  CountPollFDs:=0;

  for Index:=0 to length(aSockets)-1 do begin
   if aSockets[Index]<>RNL_SOCKET_NULL then begin
    PollFDs[CountPollFDs].fd:=aSockets[Index];
    PollFDs[CountPollFDs].events:=0;
    if RNL_SOCKET_WAIT_CONDITION_IO_RECEIVE in aConditions then begin
     PollFDs[CountPollFDs].events:=PollFDs[CountPollFDs].events or POLLIN;
    end;
    if RNL_SOCKET_WAIT_CONDITION_IO_SEND in aConditions then begin
     PollFDs[CountPollFDs].events:=PollFDs[CountPollFDs].events or POLLOUT;
    end;
    PollFDs[CountPollFDs].revents:=0;
    inc(CountPollFDs);
   end;
  end;

  PollCount:=EmulatePoll(@PollFDs[0],CountPollFDs,aTimeout,aEvent);

  if PollCount<0 then begin
   if (RNL_SOCKET_WAIT_CONDITION_SERVICE_INTERRUPT in aConditions) and (PollCount=(-3)) then begin
    aConditions:=[RNL_SOCKET_WAIT_CONDITION_SERVICE_INTERRUPT];
    result:=true;
   end else if (RNL_SOCKET_WAIT_CONDITION_IO_INTERRUPT in aConditions) and (PollCount=(-2)) then begin
    aConditions:=[RNL_SOCKET_WAIT_CONDITION_IO_INTERRUPT];
    result:=true;
   end else begin
    result:=false;
   end;
   exit;
  end;

  aConditions:=[];

  for Index:=0 to CountPollFDs-1 do begin
   if (PollFDs[Index].revents and POLLIN)<>0 then begin
    Include(aConditions,RNL_SOCKET_WAIT_CONDITION_IO_RECEIVE);
   end;
   if (PollFDs[Index].revents and POLLOUT)<>0 then begin
    Include(aConditions,RNL_SOCKET_WAIT_CONDITION_IO_SEND);
   end;
  end;

  result:=true;

 end else begin

  if aTimeout<0 then begin
   t:=nil;
  end else begin
   tv.tv_sec:=aTimeout div 1000;
   tv.tv_usec:=(aTimeout mod 1000)*1000;
   t:=@tv;
  end;

  FD_ZERO(ReadSet);
  FD_ZERO(WriteSet);

  for Index:=0 to length(aSockets)-1 do begin
   if aSockets[Index]<>RNL_SOCKET_NULL then begin
    if RNL_SOCKET_WAIT_CONDITION_IO_RECEIVE in aConditions then begin
     FD_SET(aSockets[Index],ReadSet);
    end;
    if RNL_SOCKET_WAIT_CONDITION_IO_SEND in aConditions then begin
     FD_SET(aSockets[Index],WriteSet);
    end;
   end;
  end;

  MaxSocket:=0;

  for Index:=0 to length(aSockets)-1 do begin
   if (aSockets[Index]<>RNL_SOCKET_NULL) and (MaxSocket<aSockets[Index]) then begin
    MaxSocket:=aSockets[Index];
   end;
  end;

  SelectCount:=_select(MaxSocket+1,@ReadSet,@WriteSet,nil,t);
  if SelectCount<0 then begin
   result:=false;
   exit;
  end;

  aConditions:=[];

  if SelectCount=0 then begin
   result:=true;
   exit;
  end;

  for Index:=0 to length(aSockets)-1 do begin
   if aSockets[Index]<>RNL_SOCKET_NULL then begin
    if FD_ISSET(aSockets[Index],ReadSet) then begin
     Include(aConditions,RNL_SOCKET_WAIT_CONDITION_IO_RECEIVE);
    end;
    if FD_ISSET(aSockets[Index],WriteSet) then begin
     Include(aConditions,RNL_SOCKET_WAIT_CONDITION_IO_SEND);
    end;
   end;
  end;

  result:=true;

 end;
end;
{$elseif defined(fpc) and defined(Unix) and declared(fppoll) and not defined(Darwin)}
// Use poll on POSIX-based targets except on iOS/macOS, because the first MacOS X version until 10.3
// had no poll support at all, the later added poll() in MacOS X 10.3 was buggy and broken, maybe also
// in all MacOS X versions to and including MacOS X 10.8, and at least with the release of MacOS X 10.9
// in October 2013 the poll() implementation was fixed, but with macOS 10.12 (without the X now) poll()
// was broken again, but what was fixed at macOS 10.12.2.
// So all in all, we should avoid the poll() function on the iOS/macOS targets and use the long-proven
// select() function instead on these iOS/macOS targets, to be sure that everything will work in the
// long run.
type TPollFDs=array[0..2] of pollfd;
var Index,CountPollFDs,PollCount:TRNLInt32;
    PollFDs:TPollFDs;
    ServiceInterrupt:boolean;
begin

 CountPollFDs:=0;

 for Index:=0 to length(aSockets)-1 do begin
  if aSockets[Index]<>RNL_SOCKET_NULL then begin
   PollFDs[CountPollFDs].fd:=aSockets[Index];
   PollFDs[CountPollFDs].events:=0;
   if RNL_SOCKET_WAIT_CONDITION_IO_RECEIVE in aConditions then begin
    PollFDs[CountPollFDs].events:=PollFDs[CountPollFDs].events or POLLIN;
   end;
   if RNL_SOCKET_WAIT_CONDITION_IO_SEND in aConditions then begin
    PollFDs[CountPollFDs].events:=PollFDs[CountPollFDs].events or POLLOUT;
   end;
   PollFDs[CountPollFDs].revents:=0;
   inc(CountPollFDs);
  end;
 end;

 if assigned(aEvent) then begin
  PollFDs[CountPollFDs].fd:=aEvent.fEventPipeFDs[0];
  PollFDs[CountPollFDs].events:=POLLIN;
  PollFDs[CountPollFDs].revents:=0;
  inc(CountPollFDs);
 end;

 PollCount:=fppoll(@PollFDs[0],CountPollFDs,aTimeout);

 if PollCount<0 then begin
  result:=false;
  exit;
 end;

 ServiceInterrupt:=RNL_SOCKET_WAIT_CONDITION_SERVICE_INTERRUPT in aConditions;

 aConditions:=[];

 for Index:=0 to CountPollFDs-1 do begin
  if assigned(aEvent) and (PollFDs[Index].fd=aEvent.fEventPipeFDs[0]) then begin
   aEvent.ResetEvent;
   if ServiceInterrupt then begin
    Include(aConditions,RNL_SOCKET_WAIT_CONDITION_SERVICE_INTERRUPT);
   end;
  end else begin
   if (PollFDs[Index].revents and POLLIN)<>0 then begin
    Include(aConditions,RNL_SOCKET_WAIT_CONDITION_IO_RECEIVE);
   end;
   if (PollFDs[Index].revents and POLLOUT)<>0 then begin
    Include(aConditions,RNL_SOCKET_WAIT_CONDITION_IO_SEND);
   end;
  end;
 end;

 result:=true;

end;
{$else}
var Index,SelectCount:TRNLInt32;
    ReadSet,WriteSet:TRNLSocketSet;
    tv:{$if defined(Windows)}TTimeVal{$elseif defined(fpc)}TTimeVal{$else}TimeVal{$ifend};
    t:pointer;
    MaxSocket:TRNLSocket;
{$if not defined(Windows)}
    b:TRNLUInt8;
    Count:TRNLInt32;
    ServiceInterrupt:boolean;
{$ifend}
begin

 if aTimeout<0 then begin
  t:=nil;
 end else begin
  tv.tv_sec:=aTimeout div 1000;
  tv.tv_usec:=(aTimeout mod 1000)*1000;
  t:=@tv;
 end;

{$if defined(Windows)}
 FD_ZERO(ReadSet);
 FD_ZERO(WriteSet);
{$elseif defined(fpc)}
 fpFD_ZERO(ReadSet);
 fpFD_ZERO(WriteSet);
{$else}
 FD_ZERO(ReadSet);
 FD_ZERO(WriteSet);
{$ifend}

 for Index:=0 to length(aSockets)-1 do begin
  if aSockets[Index]<>RNL_SOCKET_NULL then begin
   if RNL_SOCKET_WAIT_CONDITION_IO_RECEIVE in aConditions then begin
{$if defined(Windows)}
    FD_SET(aSockets[Index],ReadSet);
{$elseif defined(Posix)}
    __fd_set(aSockets[Index],ReadSet);
{$elseif defined(Unix)}
    fpFD_SET(aSockets[Index],ReadSet);
{$else}
    FD_SET(aSockets[Index],ReadSet);
{$ifend}
   end;
   if RNL_SOCKET_WAIT_CONDITION_IO_SEND in aConditions then begin
{$if defined(Windows)}
    FD_SET(aSockets[Index],WriteSet);
{$elseif defined(Posix)}
    __fd_set(aSockets[Index],WriteSet);
{$elseif defined(Unix)}
    fpFD_SET(aSockets[Index],WriteSet);
{$else}
    FD_SET(aSockets[Index],WriteSet);
{$ifend}
   end;
  end;
 end;

{$if defined(Windows)}

 MaxSocket:=0;

{$else}

 if assigned(aEvent) then begin

{$if defined(Posix)}
  __fd_set(aEvent.fEventPipeFDs[0],ReadSet);
{$elseif defined(Unix)}
  fpFD_SET(aEvent.fEventPipeFDs[0],ReadSet);
{$else}
  FD_SET(aEvent.fEventPipeFDs[0],ReadSet);
{$ifend}

  MaxSocket:=aEvent.fEventPipeFDs[0];

 end else begin

  MaxSocket:=0;

 end;

{$ifend}

 for Index:=0 to length(aSockets)-1 do begin
  if (aSockets[Index]<>RNL_SOCKET_NULL) and (MaxSocket<aSockets[Index]) then begin
   MaxSocket:=aSockets[Index];
  end;
 end;

{$if defined(Windows)}
 SelectCount:=_select(MaxSocket+1,@ReadSet,@WriteSet,nil,t);
 if SelectCount<0 then begin
  result:=false;
  exit;
 end;
{$else}
{$ifdef fpc}
 SelectCount:=fpselect(MaxSocket+1,@ReadSet,@WriteSet,nil,t);
{$else}
 SelectCount:=Posix.SysSelect.select(MaxSocket+1,@ReadSet,@WriteSet,nil,t);
{$endif}
 if SelectCount<0 then begin
  if (errno={$ifdef fpc}ESysEINTR{$else}EINTR{$endif}) and
     (RNL_SOCKET_WAIT_CONDITION_IO_INTERRUPT in aConditions) then begin
   aConditions:=[RNL_SOCKET_WAIT_CONDITION_IO_INTERRUPT];
   result:=true;
  end else begin
   result:=false;
  end;
  exit;
 end;
{$ifend}

{$if not defined(Windows)}
 ServiceInterrupt:=RNL_SOCKET_WAIT_CONDITION_SERVICE_INTERRUPT in aConditions;
{$ifend}

 aConditions:=[];

 if SelectCount=0 then begin
  result:=true;
  exit;
 end;

{$if not defined(Windows)}
 if assigned(aEvent) then begin
  if {$if defined(Windows)}FD_ISSET(aEvent.fEventPipeFDs[0],ReadSet)
     {$elseif defined(fpc)}
      fpFD_ISSET(aEvent.fEventPipeFDs[0],ReadSet)=1
     {$else}
      __fd_isset(aEvent.fEventPipeFDs[0],ReadSet)
     {$ifend} then begin
   aEvent.ResetEvent;
   if ServiceInterrupt then begin
    Include(aConditions,RNL_SOCKET_WAIT_CONDITION_SERVICE_INTERRUPT);
   end;
  end;
 end;
{$ifend}

 for Index:=0 to length(aSockets)-1 do begin
  if aSockets[Index]<>RNL_SOCKET_NULL then begin
   if {$if defined(Windows)}FD_ISSET(aSockets[Index],ReadSet)
      {$elseif defined(fpc)}
       fpFD_ISSET(aSockets[Index],ReadSet)=1
      {$else}
       __fd_isset(aSockets[Index],ReadSet)
      {$ifend} then begin
    Include(aConditions,RNL_SOCKET_WAIT_CONDITION_IO_RECEIVE);
   end;
   if {$if defined(Windows)}FD_ISSET(aSockets[Index],WriteSet)
      {$elseif defined(fpc)}
       fpFD_ISSET(aSockets[Index],WriteSet)=1
      {$else}
       __fd_isset(aSockets[Index],WriteSet)
      {$ifend} then begin
    Include(aConditions,RNL_SOCKET_WAIT_CONDITION_IO_SEND);
   end;
  end;
 end;

 result:=true;
end;
{$ifend}

function TRNLRealNetwork.Send(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aData;const aDataLength:TRNLSizeInt;const aFamily:TRNLAddressFamily):TRNLSizeInt;
{$if defined(Windows)}
var SIN:TSockaddrStorage;
    SentLength:TRNLUInt32;
    OK:boolean;
    Buffer:TWSABUF;
begin
 Buffer.buf:=@aData;
 Buffer.len:=aDataLength;
 if assigned(aAddress) then begin
  aAddress^.SetSIN(@SIN,aFamily);
  OK:=WSASendTo(aSocket,LPWSABUF(@Buffer),1,SentLength,0,TRNLPointer(@SIN),aFamily.GetSockAddrSize,nil,nil)<>SOCKET_ERROR;
 end else begin
  OK:=WSASendTo(aSocket,LPWSABUF(@Buffer),1,SentLength,0,nil,0,nil,nil)<>SOCKET_ERROR;
 end;
 if OK then begin
  result:=SentLength;
 end else begin
  case WSAGetLastError of
   WSAEWOULDBLOCK,WSAEMSGSIZE:begin
    result:=0;
   end;
   else begin
    result:=-1;
   end;
  end;
 end;
end;
{$elseif defined(fpc)}
var SIN:TSockaddrStorage;
    SentLength:TRNLInt32;
begin
 if assigned(aAddress) then begin
  aAddress^.SetSIN(@SIN,aFamily);
  SentLength:=fpSendTo(aSocket,@aData,aDataLength,{$if defined(fpc) and defined(Darwin)}0{$else}MSG_NOSIGNAL{$ifend},TRNLPointer(@SIN),aFamily.GetSockAddrSize);
 end else begin
  SentLength:=fpSendTo(aSocket,@aData,aDataLength,{$if defined(fpc) and defined(Darwin)}0{$else}MSG_NOSIGNAL{$ifend},nil,0);
 end;
 if SentLength<>SOCKET_ERROR then begin
  result:=SentLength;
 end else begin
  case SocketError of
   EsockEWOULDBLOCK{,EsockECONNRESET},EsockEMSGSIZE:begin
    result:=0;
   end;
   else begin
    result:=-1;
   end;
  end;
 end;
end;
{$else}
var SIN:TSockaddrStorage;
    SentLength:TRNLInt32;
begin
 if assigned(aAddress) then begin
  aAddress^.SetSIN(@SIN,aFamily);
  SentLength:=Posix.SysSocket.SendTo(aSocket,aData,aDataLength,{$if defined(fpc) and defined(Darwin)}0{$else}MSG_NOSIGNAL{$ifend},sockaddr(TRNLPointer(@SIN)^),aFamily.GetSockAddrSize);
 end else begin
  SentLength:=Posix.SysSocket.SendTo(aSocket,aData,aDataLength,{$if defined(fpc) and defined(Darwin)}0{$else}MSG_NOSIGNAL{$ifend},sockaddr(TRNLPointer(nil)^),0);
 end;
 if SentLength<>SOCKET_ERROR then begin
  result:=SentLength;
 end else begin
  case GetLastError of
   EWOULDBLOCK,EMSGSIZE:begin
    result:=0;
   end;
   else begin
    result:=-1;
   end;
  end;
 end;
end;
{$ifend}

function TRNLRealNetwork.Receive(const aSocket:TRNLSocket;const aAddress:PRNLAddress;out aData;const aDataLength:TRNLSizeInt;const aFamily:TRNLAddressFamily):TRNLSizeInt;
{$if defined(Windows)}
var SIN:TSockaddrStorage;
    SINLength:TRNLInt32;
    Flags,RecvLength:TRNLUInt32;
    OK:boolean;
    Buffer:TWSABUF;
begin
 Buffer.buf:=@aData;
 Buffer.len:=aDataLength;
 SINLength:=aFamily.GetSockAddrSize;
 Flags:=0;
 if assigned(aAddress) then begin
  OK:=WSARecvFrom(aSocket,LPWSABUF(@Buffer),1,RecvLength,Flags,TRNLPointer(@SIN),@SINLength,nil,nil)<>SOCKET_ERROR;
 end else begin
  OK:=WSARecvFrom(aSocket,LPWSABUF(@Buffer),1,RecvLength,Flags,nil,nil,nil,nil)<>SOCKET_ERROR;
 end;
 if OK then begin
  if (Flags and MSG_PARTIAL)<>0 then begin
   result:=-1;
  end else begin
   if assigned(aAddress) then begin
    aAddress^.SetAddress(@SIN);
   end;
   result:=RecvLength;
  end;
 end else begin
  case WSAGetLastError of
   WSAEWOULDBLOCK,WSAECONNRESET,WSAEMSGSIZE:begin
    result:=0;
   end;
   else begin
    result:=-1;
   end;
  end;
 end;
end;
{$elseif defined(fpc)}
var SIN:TSockaddrStorage;
    SINLength:TRNLInt32;
    RecvLength:TRNLSizeInt;
begin
 SINLength:=aFamily.GetSockAddrSize;
 if assigned(aAddress) then begin
  RecvLength:=fpRecvFrom(aSocket,@aData,aDataLength,{$if defined(fpc) and defined(Darwin)}0{$else}MSG_NOSIGNAL{$ifend},TRNLPointer(@SIN),@SINLength);
 end else begin
  RecvLength:=fpRecvFrom(aSocket,@aData,aDataLength,{$if defined(fpc) and defined(Darwin)}0{$else}MSG_NOSIGNAL{$ifend},nil,nil);
 end;
 if RecvLength<>SOCKET_ERROR then begin
  if assigned(aAddress) then begin
   aAddress^.SetAddress(@SIN);
  end;
  result:=RecvLength;
 end else begin
  case SocketError of
   EsockEWOULDBLOCK{,EsockECONNRESET},EsockEMSGSIZE{$if defined(fpc) and defined(Android)},0{$ifend}:begin
    result:=0;
   end;
   else begin
    result:=-1;
   end;
  end;
 end;
end;
{$else}
var SIN:TSockaddrStorage;
    SINLength:TRNLInt32;
    RecvLength:TRNLSizeInt;
begin
 SINLength:=aFamily.GetSockAddrSize;
 RecvLength:=0;
{$if (defined(NextGen) or defined(Android) or defined(iOS)) and not defined(fpc)}
 if assigned(aAddress) then begin
  RecvLength:=Posix.SysSocket.RecvFrom(aSocket,aData,aDataLength,{$if defined(fpc) and defined(Darwin)}0{$else}MSG_NOSIGNAL{$ifend},sockaddr(TRNLPointer(@SIN)^),{$ifdef CPU64}Cardinal{$else}Integer{$endif}(TRNLPointer(@SINLength)^));
 end else begin
  RecvLength:=Posix.SysSocket.RecvFrom(aSocket,aData,aDataLength,{$if defined(fpc) and defined(Darwin)}0{$else}MSG_NOSIGNAL{$ifend},sockaddr(TRNLPointer(nil)^),{$ifdef CPU64}Cardinal{$else}Integer{$endif}(TRNLPointer(@SIN)^));
 end;
{$else}
 if assigned(aAddress) then begin
  RecvLength:=Posix.SysSocket.RecvFrom(aSocket,aData,aDataLength,{$if defined(fpc) and defined(Darwin)}0{$else}MSG_NOSIGNAL{$ifend},sockaddr(TRNLPointer(@SIN)^),TRNLUInt32(SINLength));
 end else begin
  RecvLength:=Posix.SysSocket.RecvFrom(aSocket,aData,aDataLength,{$if defined(fpc) and defined(Darwin)}0{$else}MSG_NOSIGNAL{$ifend},sockaddr(TRNLPointer(nil)^),TRNLUInt32(TRNLPointer(@SIN)^));
 end;
{$ifend}
 if RecvLength<>SOCKET_ERROR then begin
  if assigned(aAddress) then begin
   aAddress^.SetAddress(@SIN);
  end;
  result:=RecvLength;
 end else begin
  case GetLastError of
   EWOULDBLOCK{,ECONNRESET},EMSGSIZE:begin
    result:=0;
   end;
   else begin
    result:=-1;
   end;
  end;
 end;
end;
{$ifend}

constructor TRNLVirtualNetwork.TRNLVirtualNetworkSocketInstance.Create(const aNetwork:TRNLVirtualNetwork;const aSocket:TRNLSocket);
begin

 inherited Create;

 fValue:=self;

 fNetwork:=aNetwork;

 fSocket:=aSocket;

 FillChar(fAddress,SizeOf(TRNLAddress),#0);

 System.Move(RNL_IPV4MAPPED_PREFIX,fAddress.Host,RNL_IPV4MAPPED_PREFIX_LEN);

 fAddress.Host.Addr[RNL_IPV4MAPPED_PREFIX_LEN+0]:=((aSocket+1) shr 24) and $ff;
 fAddress.Host.Addr[RNL_IPV4MAPPED_PREFIX_LEN+1]:=((aSocket+1) shr 16) and $ff;
 fAddress.Host.Addr[RNL_IPV4MAPPED_PREFIX_LEN+2]:=((aSocket+1) shr 8) and $ff;
 fAddress.Host.Addr[RNL_IPV4MAPPED_PREFIX_LEN+3]:=((aSocket+1) shr 0) and $ff;

 fAddress.ScopeID:=1;

 fAddress.Port:=(TRNLUInt16(aSocket)+1) and $ffff;

 fAddressHash:=0;

 fAddressListNode:=TRNLVirtualNetworkSocketInstanceListNode.Create;
 fAddressListNode.fValue:=self;

 fSocketInstanceListNode:=TRNLVirtualNetworkSocketInstanceListNode.Create;
 fSocketInstanceListNode.fValue:=self;

 fData:=TRNLVirtualNetworkSocketDataQueue.Create;

end;

destructor TRNLVirtualNetwork.TRNLVirtualNetworkSocketInstance.Destroy;
begin

 FreeAndNil(fAddressListNode);

 FreeAndNil(fSocketInstanceListNode);

 FreeAndNil(fData);

 inherited Destroy;

end;

procedure TRNLVirtualNetwork.TRNLVirtualNetworkSocketInstance.UpdateAddress;
var Hash:TRNLUInt32;
begin
 fAddressListNode.Remove;
 Hash:=TRNLVirtualNetwork.HashAddress(fAddress);
 fAddressHash:=Hash;
 fNetwork.fAddressSocketInstanceHashMap[Hash and RNL_VIRTUAL_NETWORK_SOCKET_HASH_MASK].Add(fAddressListNode);
end;

constructor TRNLVirtualNetwork.Create(const aInstance:TRNLInstance);
var Index:TRNLSizeInt;
begin

 inherited Create(aInstance);

 fLock:=TCriticalSection.Create;

 fNewDataEvent:=TRNLNetworkEvent.Create;

 fSocketCounter:=0;

 fFreeSockets:=TRNLVirtualNetworkSocketStack.Create;

 fSocketInstanceList:=TRNLVirtualNetworkSocketInstanceListNode.Create;

 for Index:=Low(TRNLVirtualNetworkSocketInstanceHashMap) to High(TRNLVirtualNetworkSocketInstanceHashMap) do begin
  fSocketInstanceHashMap[Index]:=TRNLVirtualNetworkSocketInstanceListNode.Create;
  fAddressSocketInstanceHashMap[Index]:=TRNLVirtualNetworkSocketInstanceListNode.Create;
 end;

end;

destructor TRNLVirtualNetwork.Destroy;
var Index:TRNLSizeInt;
begin

 while not fSocketInstanceList.IsEmpty do begin
  fSocketInstanceList.Front.Value.Free;
 end;
 FreeAndNil(fSocketInstanceList);

 for Index:=Low(TRNLVirtualNetworkSocketInstanceHashMap) to High(TRNLVirtualNetworkSocketInstanceHashMap) do begin

  while not fSocketInstanceHashMap[Index].IsEmpty do begin
   fSocketInstanceHashMap[Index].Front.Value.Free;
  end;
  FreeAndNil(fSocketInstanceHashMap[Index]);

  while not fAddressSocketInstanceHashMap[Index].IsEmpty do begin
   fAddressSocketInstanceHashMap[Index].Front.Value.Free;
  end;
  FreeAndNil(fAddressSocketInstanceHashMap[Index]);

 end;

 FreeAndNil(fFreeSockets);

 FreeAndNil(fNewDataEvent);

 FreeAndNil(fLock);

 inherited Destroy;

end;

class function TRNLVirtualNetwork.HashSocket(const aSocket:TRNLSocket):TRNLUInt32;
begin
 result:=TRNLHashUtils.Hash32(aSocket,SizeOf(TRNLSocket));
end;

class function TRNLVirtualNetwork.HashAddress(const aAddress:TRNLAddress):TRNLUInt32;
begin
 result:=TRNLHashUtils.Hash32(aAddress,SizeOf(TRNLAddress));
end;

function TRNLVirtualNetwork.FindSocketInstance(const aSocket:TRNLSocket;const aCreateIfNotExist:boolean):TRNLVirtualNetworkSocketInstance;
var Hash:TRNLUInt32;
    HashBucket,HashBucketItem:TRNLVirtualNetworkSocketInstanceListNode;
begin
 if aSocket=RNL_SOCKET_NULL then begin
  result:=nil;
 end else begin
  Hash:=HashSocket(aSocket);
  HashBucket:=fSocketInstanceHashMap[Hash and RNL_VIRTUAL_NETWORK_SOCKET_HASH_MASK];
  HashBucketItem:=HashBucket.Front;
  while HashBucketItem<>HashBucket do begin
   if HashBucketItem.Value.fSocket=aSocket then begin
    result:=HashBucketItem.Value;
    exit;
   end;
   HashBucketItem:=HashBucketItem.Next;
  end;
  if aCreateIfNotExist then begin
   result:=TRNLVirtualNetworkSocketInstance.Create(self,aSocket);
   fSocketInstanceHashMap[Hash and RNL_VIRTUAL_NETWORK_SOCKET_HASH_MASK].Add(result);
   result.UpdateAddress;
   fSocketInstanceList.Add(result.fSocketInstanceListNode);
  end else begin
   result:=nil;
  end;
 end;
end;

function TRNLVirtualNetwork.FindAddressSocketInstance(const aAddress:TRNLAddress):TRNLVirtualNetworkSocketInstance;
var Hash:TRNLUInt32;
    HashBucket,HashBucketItem:TRNLVirtualNetworkSocketInstanceListNode;
begin
 Hash:=HashAddress(aAddress);
 HashBucket:=fAddressSocketInstanceHashMap[Hash and RNL_VIRTUAL_NETWORK_SOCKET_HASH_MASK];
 HashBucketItem:=HashBucket.Front;
 while HashBucketItem<>HashBucket do begin
  if (HashBucketItem.Value.fAddressHash=Hash) and
     TRNLMemory.SecureIsEqual(HashBucketItem.Value.fAddress,aAddress,SizeOf(TRNLAddress)) then begin
   result:=HashBucketItem.Value;
   exit;
  end;
  HashBucketItem:=HashBucketItem.Next;
 end;
 result:=nil;
end;

function TRNLVirtualNetwork.AddressSetHost(var aAddress:TRNLAddress;const aName:TRNLRawByteString):boolean;
begin
 aAddress:=TRNLAddress.CreateFromString(aName);
 result:=aAddress.ScopeID<>TRNLUInt32($deadc0d3);
end;

function TRNLVirtualNetwork.AddressGetHost(const aAddress:TRNLAddress;out aName;const aNameLength:TRNLInt32;const aFlags:TRNLInt32=0):boolean;
const HexChars:array[0..15] of TRNLUInt8=(ord('0'),ord('1'),ord('2'),ord('3'),
                                          ord('4'),ord('5'),ord('6'),ord('7'),
                                          ord('8'),ord('9'),ord('a'),ord('b'),
                                          ord('c'),ord('d'),ord('e'),ord('f'));
var Index:TRNLSizeInt;
begin
 // Do it with the most simple way => as non-zero-compressed non-beginning-zero-trimmed IPv6 address
 result:=(aNameLength>0) and (aNameLength>=40);
 if result then begin
  for Index:=0 to 7 do begin
   PRNLUInt8Array(TRNLPointer(@aName))^[(Index*5)+0]:=HexChars[(aAddress.Host.Addr[(Index shl 1) or 0] shr 4) and $f];
   PRNLUInt8Array(TRNLPointer(@aName))^[(Index*5)+1]:=HexChars[(aAddress.Host.Addr[(Index shl 1) or 0] shr 0) and $f];
   PRNLUInt8Array(TRNLPointer(@aName))^[(Index*5)+2]:=HexChars[(aAddress.Host.Addr[(Index shl 1) or 1] shr 4) and $f];
   PRNLUInt8Array(TRNLPointer(@aName))^[(Index*5)+3]:=HexChars[(aAddress.Host.Addr[(Index shl 1) or 1] shr 0) and $f];
   if Index<>7 then begin
    PRNLUInt8Array(TRNLPointer(@aName))^[(Index*5)+4]:=ord(':');
   end else begin
    PRNLUInt8Array(TRNLPointer(@aName))^[(Index*5)+4]:=0;
   end;
  end;
 end;
end;

function TRNLVirtualNetwork.AddressGetHostIP(const aAddress:TRNLAddress;out aName;const aNameLength:TRNLInt32):boolean;
begin
 result:=AddressGetHost(aAddress,aName,aNameLength,0);
end;

function TRNLVirtualNetwork.SocketCreate(const aType:TRNLSocketType;const aFamily:TRNLAddressFamily):TRNLSocket;
begin
 fLock.Acquire;
 try
  if not fFreeSockets.Pop(result) then begin
   result:=fSocketCounter;
   if result<>RNL_SOCKET_NULL then begin
    inc(fSocketCounter);
   end;
  end;
  if result<>RNL_SOCKET_NULL then begin
   FindSocketInstance(result,true);
  end;
 finally
  fLock.Release;
 end;
end;

procedure TRNLVirtualNetwork.SocketDestroy(const aSocket:TRNLSocket);
var SocketInstance:TRNLVirtualNetworkSocketInstance;
begin
 fLock.Acquire;
 try
  SocketInstance:=FindSocketInstance(aSocket,false);
  if assigned(SocketInstance) then begin
   SocketInstance.Free;
   fFreeSockets.Push(aSocket);
  end;
 finally
  fLock.Release;
 end;
end;

function TRNLVirtualNetwork.SocketShutdown(const aSocket:TRNLSocket;const aHow:TRNLSocketShutdown=RNL_SOCKET_SHUTDOWN_READ_WRITE):boolean;
begin
 result:=false;
end;

function TRNLVirtualNetwork.SocketGetAddress(const aSocket:TRNLSocket;out aAddress:TRNLAddress;const aFamily:TRNLAddressFamily):boolean;
var SocketInstance:TRNLVirtualNetworkSocketInstance;
begin
 fLock.Acquire;
 try
  SocketInstance:=FindSocketInstance(aSocket,false);
  if assigned(SocketInstance) then begin
   aAddress:=SocketInstance.fAddress;
   result:=true;
  end else begin
   result:=false;
  end;
 finally
  fLock.Release;
 end;
end;

function TRNLVirtualNetwork.SocketSetOption(const aSocket:TRNLSocket;const aOption:TRNLSocketOption;const aValue:TRNLInt32):boolean;
begin
 result:=true;
end;

function TRNLVirtualNetwork.SocketGetOption(const aSocket:TRNLSocket;const aOption:TRNLSocketOption;out aValue:TRNLInt32):boolean;
begin
 result:=false;
end;

function TRNLVirtualNetwork.SocketBind(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aFamily:TRNLAddressFamily):boolean;
var SocketInstance:TRNLVirtualNetworkSocketInstance;
begin
 fLock.Acquire;
 try
  SocketInstance:=FindSocketInstance(aSocket,false);
  if assigned(SocketInstance) then begin
   if assigned(aAddress) then begin
    if TRNLMemory.SecureIsEqual(aAddress^.Host,RNL_HOST_ANY,SizeOf(TRNLHostAddress)) then begin
     SocketInstance.fAddress.Host:=RNL_HOST_IPV4_LOCALHOST;
     SocketInstance.fAddress.ScopeID:=aAddress^.ScopeID;
     SocketInstance.fAddress.Port:=aAddress^.Port;
    end else begin
     SocketInstance.fAddress:=aAddress^;
    end;
    SocketInstance.UpdateAddress;
   end;
   result:=true;
  end else begin
   result:=false;
  end;
 finally
  fLock.Release;
 end;
end;

function TRNLVirtualNetwork.SocketListen(const aSocket:TRNLSocket;const aBackLog:TRNLInt32):boolean;
begin
 result:=false;
end;

function TRNLVirtualNetwork.SocketConnect(const aSocket:TRNLSocket;const aAddress:TRNLAddress;const aFamily:TRNLAddressFamily):boolean;
begin
 result:=false;
end;

function TRNLVirtualNetwork.SocketAccept(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aFamily:TRNLAddressFamily):TRNLSocket;
begin
 result:=RNL_SOCKET_NULL;
end;

function TRNLVirtualNetwork.SocketSelect(const aMaxSocket:TRNLSocket;var aReadSet,aWriteSet:TRNLSocketSet;const aTimeout:TRNLInt64;const aEvent:TRNLNetworkEvent=nil):TRNLInt32;
var SocketInstanceListNode:TRNLVirtualNetworkSocketInstanceListNode;
    Socket:TRNLSocket;
    Timeout:TRNLTime;
    TimeoutDifference:TRNLInt64;
begin
 result:=0;
 Timeout:=fInstance.Time+aTimeout;
 repeat
  fLock.Acquire;
  try
   SocketInstanceListNode:=fSocketInstanceList.Front;
   while SocketInstanceListNode<>fSocketInstanceList do begin
    Socket:=SocketInstanceListNode.Value.fSocket;
    if {$if defined(Posix)}
        __FD_ISSET(Socket,aReadSet)
       {$elseif defined(Unix)}
        (fpFD_ISSET(Socket,aReadSet)=1)
       {$else}
        FD_ISSET(Socket,aReadSet)
       {$ifend}
       or
       {$if defined(Posix)}
        __FD_ISSET(Socket,aWriteSet)
       {$elseif defined(Unix)}
        (fpFD_ISSET(Socket,aWriteSet)=1)
       {$else}
        FD_ISSET(Socket,aWriteSet)
       {$ifend} then begin
     if SocketInstanceListNode.Value.fData.IsEmpty then begin
{$if defined(Posix)}
      __FD_CLR(Socket,aReadSet);
      __FD_CLR(Socket,aWriteSet);
{$elseif defined(Unix)}
      fpFD_CLR(Socket,aReadSet);
      fpFD_CLR(Socket,aWriteSet);
{$else}
      FD_CLR(Socket,aReadSet);
      FD_CLR(Socket,aWriteSet);
{$ifend}
     end else begin
      inc(result);
     end;
    end;
    SocketInstanceListNode:=SocketInstanceListNode.Next;
   end;
  finally
   fLock.Release;
  end;
  if aTimeout>=0 then begin
   TimeoutDifference:=TRNLTime.RelativeDifference(Timeout,fInstance.Time);
   if (result<>0) or (TimeoutDifference<=0) then begin
    break;
   end else begin
    if assigned(aEvent) then begin
     if TRNLNetworkEvent.WaitForMultipleEvents([fNewDataEvent,aEvent],TimeoutDifference)<>0 then begin
      break;
     end;
    end else begin
     fNewDataEvent.WaitFor(TimeoutDifference);
    end;
   end;
  end else begin
   if result<>0 then begin
    break;
   end else begin
    if assigned(aEvent) then begin
     if TRNLNetworkEvent.WaitForMultipleEvents([fNewDataEvent,aEvent],-1)<>0 then begin
      break;
     end;
    end else begin
     fNewDataEvent.WaitFor(-1);
    end;
   end;
  end;
 until false;
end;

function TRNLVirtualNetwork.SocketWait(const aSockets:array of TRNLSocket;var aConditions:TRNLSocketWaitConditions;const aTimeout:TRNLInt64;const aEvent:TRNLNetworkEvent=nil):boolean;
var Socket:TRNLSocket;
    SocketInstance:TRNLVirtualNetworkSocketInstance;
    Timeout:TRNLTime;
    TimeoutDifference:TRNLInt64;
    Conditions:TRNLSocketWaitConditions;
begin
 Conditions:=aConditions;
 aConditions:=[];
 Timeout:=fInstance.Time+aTimeout;
 repeat
  if length(aSockets)>0 then begin
   fLock.Acquire;
   try
    for Socket in aSockets do begin
     SocketInstance:=FindSocketInstance(Socket,false);
     if assigned(SocketInstance) and (RNL_SOCKET_WAIT_CONDITION_IO_RECEIVE in Conditions) and not SocketInstance.fData.IsEmpty then begin
      Include(aConditions,RNL_SOCKET_WAIT_CONDITION_IO_RECEIVE);
      break;
     end;
    end;
   finally
    fLock.Release;
   end;
  end;
  if aTimeout>=0 then begin
   TimeoutDifference:=TRNLTime.RelativeDifference(Timeout,fInstance.Time);
   if (aConditions<>[]) or (TimeoutDifference<=0) then begin
    break;
   end else begin
    if assigned(aEvent) then begin
     if TRNLNetworkEvent.WaitForMultipleEvents([fNewDataEvent,aEvent],TimeoutDifference)<>0 then begin
      if RNL_SOCKET_WAIT_CONDITION_SERVICE_INTERRUPT in Conditions then begin
       Include(aConditions,RNL_SOCKET_WAIT_CONDITION_SERVICE_INTERRUPT);
      end;
      break;
     end;
    end else begin
     fNewDataEvent.WaitFor(TimeoutDifference);
    end;
   end;
  end else begin
   if aConditions<>[] then begin
    break;
   end else begin
    if assigned(aEvent) then begin
     if TRNLNetworkEvent.WaitForMultipleEvents([fNewDataEvent,aEvent],-1)<>0 then begin
      if RNL_SOCKET_WAIT_CONDITION_SERVICE_INTERRUPT in Conditions then begin
       Include(aConditions,RNL_SOCKET_WAIT_CONDITION_SERVICE_INTERRUPT);
      end;
      break;
     end;
    end else begin
     fNewDataEvent.WaitFor(-1);
    end;
   end;
  end;
 until false;
 result:=true;
end;

function TRNLVirtualNetwork.Send(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aData;const aDataLength:TRNLSizeInt;const aFamily:TRNLAddressFamily):TRNLSizeInt;
var SocketInstance,OtherSocketInstance:TRNLVirtualNetworkSocketInstance;
    Data:TRNLVirtualNetworkSocketData;
begin
 result:=-1;
 fLock.Acquire;
 try
  SocketInstance:=FindSocketInstance(aSocket,false);
  if assigned(SocketInstance) and assigned(aAddress) and (aDataLength>0) then begin
   result:=0;
   OtherSocketInstance:=FindAddressSocketInstance(aAddress^);
   if assigned(OtherSocketInstance) then begin
    Data.Address:=SocketInstance.fAddress;
    SetLength(Data.Data,aDataLength);
    Move(aData,Data.Data[0],aDataLength);
    OtherSocketInstance.fData.Enqueue(Data);
    result:=aDataLength;
   end;
  end;
 finally
  fLock.Release;
 end;
 fNewDataEvent.SetEvent;
end;

function TRNLVirtualNetwork.Receive(const aSocket:TRNLSocket;const aAddress:PRNLAddress;out aData;const aDataLength:TRNLSizeInt;const aFamily:TRNLAddressFamily):TRNLSizeInt;
var SocketInstance:TRNLVirtualNetworkSocketInstance;
    Data:TRNLVirtualNetworkSocketData;
begin
 result:=0;
 fLock.Acquire;
 try
  SocketInstance:=FindSocketInstance(aSocket,false);
  if assigned(SocketInstance) and assigned(aAddress) and (aDataLength>0) then begin
   if SocketInstance.fData.Dequeue(Data) then begin
    if length(Data.Data)<=aDataLength then begin
     aAddress^:=Data.Address;
     try
      Move(Data.Data[0],aData,length(Data.Data));
      result:=length(Data.Data);
     finally
      Data.Data:=nil;
     end;
    end else begin
     result:=-1;
    end;
   end;
  end;
 finally
  fLock.Release;
 end;
end;

constructor TRNLNetworkInterferenceSimulator.TRNLNetworkInterferenceSimulatorPacket.Create(const aNetworkInterferenceSimulator:TRNLNetworkInterferenceSimulator);
begin

 inherited Create;

 fValue:=self;

 fNetworkInterferenceSimulator:=aNetworkInterferenceSimulator;

 fTime:=0;

 fSocket:=0;

 fData:=nil;

end;

destructor TRNLNetworkInterferenceSimulator.TRNLNetworkInterferenceSimulatorPacket.Destroy;
begin

 fData:=nil;

 inherited Destroy;

end;

constructor TRNLNetworkInterferenceSimulator.Create(const aInstance:TRNLInstance;const aNetwork:TRNLNetwork);
begin

 inherited Create(aInstance);

 fNetwork:=aNetwork;

 fLock:=TCriticalSection.Create;

 fRandomGenerator:=TRNLRandomGenerator.Create;

 fNextTimeout.fValue:=TRNLUInt64(High(TRNLUInt64));

 fIncomingPacketList:=TRNLNetworkInterferenceSimulatorPacketListNode.Create;

 fOutgoingPacketList:=TRNLNetworkInterferenceSimulatorPacketListNode.Create;

 fSimulatedIncomingPacketLossProbabilityFactor:=0;

 fSimulatedOutgoingPacketLossProbabilityFactor:=0;

 fSimulatedIncomingDuplicatePacketProbabilityFactor:=0;

 fSimulatedOutgoingDuplicatePacketProbabilityFactor:=0;

 fSimulatedIncomingOutOfOrderPacketProbabilityFactor:=0;

 fSimulatedOutgoingOutOfOrderPacketProbabilityFactor:=0;

 fSimulatedIncomingBitFlippingProbabilityFactor:=0;

 fSimulatedOutgoingBitFlippingProbabilityFactor:=0;

 fSimulatedIncomingMinimumFlippingBits:=0;

 fSimulatedOutgoingMinimumFlippingBits:=0;

 fSimulatedIncomingMaximumFlippingBits:=0;

 fSimulatedOutgoingMaximumFlippingBits:=0;

 fSimulatedIncomingLatency:=0;

 fSimulatedOutgoingLatency:=0;

 fSimulatedIncomingJitter:=0;

 fSimulatedOutgoingJitter:=0;

end;

destructor TRNLNetworkInterferenceSimulator.Destroy;
begin

 while not fIncomingPacketList.IsEmpty do begin
  fIncomingPacketList.Front.Value.Free;
 end;

 FreeAndNil(fIncomingPacketList);

 while not fOutgoingPacketList.IsEmpty do begin
  fOutgoingPacketList.Front.Value.Free;
 end;

 FreeAndNil(fOutgoingPacketList);

 FreeAndNil(fRandomGenerator);

 FreeAndNil(fLock);

 inherited Destroy;

end;

function TRNLNetworkInterferenceSimulator.SimulateIncomingPacketLoss:boolean;
begin
 case fSimulatedIncomingPacketLossProbabilityFactor of
  0:begin
   result:=false;
  end;
  TRNLUInt32($ffffffff):begin
   result:=true;
  end;
  else begin
   fLock.Acquire;
   try
    result:=fRandomGenerator.GetUInt32<fSimulatedIncomingPacketLossProbabilityFactor;
   finally
    fLock.Release;
   end;
  end;
 end;
end;

function TRNLNetworkInterferenceSimulator.SimulateOutgoingPacketLoss:boolean;
begin
 case fSimulatedOutgoingPacketLossProbabilityFactor of
  0:begin
   result:=false;
  end;
  TRNLUInt32($ffffffff):begin
   result:=true;
  end;
  else begin
   fLock.Acquire;
   try
    result:=fRandomGenerator.GetUInt32<fSimulatedOutgoingPacketLossProbabilityFactor;
   finally
    fLock.Release;
   end;
  end;
 end;
end;

function TRNLNetworkInterferenceSimulator.SimulateIncomingDuplicatePacket:boolean;
begin
 case fSimulatedIncomingDuplicatePacketProbabilityFactor of
  0:begin
   result:=false;
  end;
  TRNLUInt32($ffffffff):begin
   result:=true;
  end;
  else begin
   fLock.Acquire;
   try
    result:=fRandomGenerator.GetUInt32<fSimulatedIncomingDuplicatePacketProbabilityFactor;
   finally
    fLock.Release;
   end;
  end;
 end;
end;

function TRNLNetworkInterferenceSimulator.SimulateOutgoingDuplicatePacket:boolean;
begin
 case fSimulatedOutgoingDuplicatePacketProbabilityFactor of
  0:begin
   result:=false;
  end;
  TRNLUInt32($ffffffff):begin
   result:=true;
  end;
  else begin
   fLock.Acquire;
   try
    result:=fRandomGenerator.GetUInt32<fSimulatedOutgoingDuplicatePacketProbabilityFactor;
   finally
    fLock.Release;
   end;
  end;
 end;
end;

function TRNLNetworkInterferenceSimulator.SimulateIncomingOutOfOrderPacket:boolean;
begin
 case fSimulatedIncomingOutOfOrderPacketProbabilityFactor of
  0:begin
   result:=false;
  end;
  TRNLUInt32($ffffffff):begin
   result:=true;
  end;
  else begin
   fLock.Acquire;
   try
    result:=fRandomGenerator.GetUInt32<fSimulatedIncomingOutOfOrderPacketProbabilityFactor;
   finally
    fLock.Release;
   end;
  end;
 end;
end;

function TRNLNetworkInterferenceSimulator.SimulateOutgoingOutOfOrderPacket:boolean;
begin
 case fSimulatedOutgoingOutOfOrderPacketProbabilityFactor of
  0:begin
   result:=false;
  end;
  TRNLUInt32($ffffffff):begin
   result:=true;
  end;
  else begin
   fLock.Acquire;
   try
    result:=fRandomGenerator.GetUInt32<fSimulatedOutgoingOutOfOrderPacketProbabilityFactor;
   finally
    fLock.Release;
   end;
  end;
 end;
end;

function TRNLNetworkInterferenceSimulator.SimulateIncomingBitFlipping:boolean;
begin
 case fSimulatedIncomingBitFlippingProbabilityFactor of
  0:begin
   result:=false;
  end;
  TRNLUInt32($ffffffff):begin
   result:=true;
  end;
  else begin
   fLock.Acquire;
   try
    result:=fRandomGenerator.GetUInt32<fSimulatedIncomingBitFlippingProbabilityFactor;
   finally
    fLock.Release;
   end;
  end;
 end;
end;

function TRNLNetworkInterferenceSimulator.SimulateOutgoingBitFlipping:boolean;
begin
 case fSimulatedOutgoingBitFlippingProbabilityFactor of
  0:begin
   result:=false;
  end;
  TRNLUInt32($ffffffff):begin
   result:=true;
  end;
  else begin
   fLock.Acquire;
   try
    result:=fRandomGenerator.GetUInt32<fSimulatedOutgoingBitFlippingProbabilityFactor;
   finally
    fLock.Release;
   end;
  end;
 end;
end;

procedure TRNLNetworkInterferenceSimulator.SimulateBitFlipping(var aData;
                                                               const aDataLength:TRNLUInt32;
                                                               const aMinimumFlippingBits:TRNLUInt32;
                                                               const aMaximumFlippingBits:TRNLUInt32);
var CountFlippingBits,BitIndex:TRNLUInt32;
    p:PRNLUInt8;
begin
 if aDataLength>0 then begin
  fLock.Acquire;
  try
   CountFlippingBits:=fRandomGenerator.GetBoundedUInt32(aMaximumFlippingBits-aMinimumFlippingBits)+aMinimumFlippingBits;
   while CountFlippingBits>0 do begin
    dec(CountFlippingBits);
    BitIndex:=fRandomGenerator.GetBoundedUInt32(aDataLength shl 3);
    p:=@PRNLUInt8Array(@aData)^[BitIndex shr 3];
    p^:=p^ xor (TRNLUInt8(1) shl (BitIndex and 7));
   end;
  finally
   fLock.Release;
  end;
 end;
end;

function TRNLNetworkInterferenceSimulator.TRNLNetworkInterferenceSimulatorPacketCompare(const a,b:TObject):TRNLInt32;
begin
 result:=Sign(TRNLTime.RelativeDifference(TRNLNetworkInterferenceSimulatorPacket(a).fTime,TRNLNetworkInterferenceSimulatorPacket(b).fTime));
end;

procedure TRNLNetworkInterferenceSimulator.Update;
var PacketListNode,NextPacketListNode:TRNLNetworkInterferenceSimulatorPacketListNode;
    Packet:TRNLNetworkInterferenceSimulatorPacket;
    Time:TRNLTime;
begin

 fLock.Acquire;
 try

  Time:=fInstance.Time;

  fNextTimeout.fValue:=TRNLUInt64(High(TRNLUInt64));

  PacketListNode:=fIncomingPacketList.Front;
  while PacketListNode<>fIncomingPacketList do begin
   NextPacketListNode:=PacketListNode.Next;
   Packet:=PacketListNode.fValue;
   if Packet.fTime.fValue<fNextTimeout.fValue then begin
    fNextTimeout.fValue:=Packet.fTime.fValue;
   end;
   PacketListNode:=NextPacketListNode;
  end;

  PacketListNode:=fOutgoingPacketList.Front;
  while PacketListNode<>fOutgoingPacketList do begin
   NextPacketListNode:=PacketListNode.Next;
   Packet:=PacketListNode.fValue;
   if Packet.fTime.fValue<=Time.fValue then begin
    try
     if length(Packet.fData)>=0 then begin
      fNetwork.Send(Packet.fSocket,@Packet.fAddress,Packet.fData[0],length(Packet.fData),Packet.fFamily);
     end;
     Packet.Remove;
    finally
     Packet.Free;
    end;
   end else if Packet.fTime.fValue<fNextTimeout.fValue then begin
    fNextTimeout.fValue:=Packet.fTime.fValue;
   end;
   PacketListNode:=NextPacketListNode;
  end;

 finally
  fLock.Release;
 end;

end;

function TRNLNetworkInterferenceSimulator.AddressSetHost(var aAddress:TRNLAddress;const aName:TRNLRawByteString):boolean;
begin
 Update;
 result:=fNetwork.AddressSetHost(aAddress,aName);
end;

function TRNLNetworkInterferenceSimulator.AddressGetHost(const aAddress:TRNLAddress;out aName;const aNameLength:TRNLInt32;const aFlags:TRNLInt32=0):boolean;
begin
 Update;
 result:=fNetwork.AddressGetHost(aAddress,aName,aNameLength,aFlags);
end;

function TRNLNetworkInterferenceSimulator.AddressGetHostIP(const aAddress:TRNLAddress;out aName;const aNameLength:TRNLInt32):boolean;
begin
 Update;
 result:=fNetwork.AddressGetHostIP(aAddress,aName,aNameLength);
end;

function TRNLNetworkInterferenceSimulator.SocketCreate(const aType:TRNLSocketType;const aFamily:TRNLAddressFamily):TRNLSocket;
begin
 Update;
 result:=fNetwork.SocketCreate(aType,aFamily);
end;

procedure TRNLNetworkInterferenceSimulator.SocketDestroy(const aSocket:TRNLSocket);
var PacketListNode,NextPacketListNode:TRNLNetworkInterferenceSimulatorPacketListNode;
    Packet:TRNLNetworkInterferenceSimulatorPacket;
begin

 Update;

 fLock.Acquire;
 try

  PacketListNode:=fIncomingPacketList.Front;
  while PacketListNode<>fIncomingPacketList do begin
   NextPacketListNode:=PacketListNode.Next;
   Packet:=PacketListNode.fValue;
   if Packet.fSocket=aSocket then begin
    Packet.Free;
   end;
   PacketListNode:=NextPacketListNode;
  end;

  PacketListNode:=fOutgoingPacketList.Front;
  while PacketListNode<>fOutgoingPacketList do begin
   NextPacketListNode:=PacketListNode.Next;
   Packet:=PacketListNode.fValue;
   if Packet.fSocket=aSocket then begin
    Packet.Free;
   end;
   PacketListNode:=NextPacketListNode;
  end;

 finally
  fLock.Release;
 end;

 fNetwork.SocketDestroy(aSocket);

end;

function TRNLNetworkInterferenceSimulator.SocketShutdown(const aSocket:TRNLSocket;const aHow:TRNLSocketShutdown=RNL_SOCKET_SHUTDOWN_READ_WRITE):boolean;
begin
 Update;
 result:=fNetwork.SocketShutdown(aSocket,aHow);
end;

function TRNLNetworkInterferenceSimulator.SocketGetAddress(const aSocket:TRNLSocket;out aAddress:TRNLAddress;const aFamily:TRNLAddressFamily):boolean;
begin
 Update;
 result:=fNetwork.SocketGetAddress(aSocket,aAddress,aFamily);
end;

function TRNLNetworkInterferenceSimulator.SocketSetOption(const aSocket:TRNLSocket;const aOption:TRNLSocketOption;const aValue:TRNLInt32):boolean;
begin
 Update;
 result:=fNetwork.SocketSetOption(aSocket,aOption,aValue);
end;

function TRNLNetworkInterferenceSimulator.SocketGetOption(const aSocket:TRNLSocket;const aOption:TRNLSocketOption;out aValue:TRNLInt32):boolean;
begin
 Update;
 result:=fNetwork.SocketGetOption(aSocket,aOption,aValue);
end;

function TRNLNetworkInterferenceSimulator.SocketBind(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aFamily:TRNLAddressFamily):boolean;
begin
 Update;
 result:=fNetwork.SocketBind(aSocket,aAddress,aFamily);
end;

function TRNLNetworkInterferenceSimulator.SocketListen(const aSocket:TRNLSocket;const aBackLog:TRNLInt32):boolean;
begin
 Update;
 result:=fNetwork.SocketListen(aSocket,aBackLog);
end;

function TRNLNetworkInterferenceSimulator.SocketConnect(const aSocket:TRNLSocket;const aAddress:TRNLAddress;const aFamily:TRNLAddressFamily):boolean;
begin
 Update;
 result:=fNetwork.SocketConnect(aSocket,aAddress,aFamily);
end;

function TRNLNetworkInterferenceSimulator.SocketAccept(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aFamily:TRNLAddressFamily):TRNLSocket;
begin
 Update;
 result:=fNetwork.SocketAccept(aSocket,aAddress,aFamily);
end;

function TRNLNetworkInterferenceSimulator.SocketSelect(const aMaxSocket:TRNLSocket;var aReadSet,aWriteSet:TRNLSocketSet;const aTimeout:TRNLInt64;const aEvent:TRNLNetworkEvent=nil):TRNLInt32;
var Time:TRNLTime;
    Timeout:TRNLInt64;
begin
 Update;
 fLock.Acquire;
 try
  if fNextTimeout.fValue<>TRNLUInt64(High(TRNLUInt64)) then begin
   Time:=fInstance.Time;
   Timeout:=Max(1,TRNLTime.RelativeDifference(TRNLTime.Minimum(Time+aTimeout,fNextTimeout),Time));
   fLock.Release;
   try
    result:=fNetwork.SocketSelect(aMaxSocket,aReadSet,aWriteSet,Timeout,aEvent);
   finally
    fLock.Acquire;
   end;
  end else begin
   fLock.Release;
   try
    result:=fNetwork.SocketSelect(aMaxSocket,aReadSet,aWriteSet,aTimeout,aEvent);
   finally
    fLock.Acquire;
   end;
  end;
 finally
  fLock.Release;
 end;
end;

function TRNLNetworkInterferenceSimulator.SocketWait(const aSockets:array of TRNLSocket;var aConditions:TRNLSocketWaitConditions;const aTimeout:TRNLInt64;const aEvent:TRNLNetworkEvent=nil):boolean;
var Time:TRNLTime;
    Timeout:TRNLInt64;
begin
 Update;
 fLock.Acquire;
 try
  if fNextTimeout.fValue<>TRNLUInt64(High(TRNLUInt64)) then begin
   Time:=fInstance.Time;
   Timeout:=Max(1,TRNLTime.RelativeDifference(TRNLTime.Minimum(Time+aTimeout,fNextTimeout),Time));
   fLock.Release;
   try
    result:=fNetwork.SocketWait(aSockets,aConditions,Timeout,aEvent);
   finally
    fLock.Acquire;
   end;
  end else begin
   fLock.Release;
   try
    result:=fNetwork.SocketWait(aSockets,aConditions,aTimeout);
   finally
    fLock.Acquire;
   end;
  end;
 finally
  fLock.Release;
 end;
end;

function TRNLNetworkInterferenceSimulator.Send(const aSocket:TRNLSocket;const aAddress:PRNLAddress;const aData;const aDataLength:TRNLSizeInt;const aFamily:TRNLAddressFamily):TRNLSizeInt;
var Time:TRNLTime;
    Delay:TRNLInt64;
    Packet:TRNLNetworkInterferenceSimulatorPacket;
    Data:pointer;
begin
 result:=0;
 Update;
 if SimulateOutgoingPacketLoss then begin
  result:=aDataLength;
 end else begin
  Data:=@aData;
  try
   if (aDataLength>0) and SimulateOutgoingBitFlipping then begin
    GetMem(Data,aDataLength);
    Move(aData,Data^,aDataLength);
    SimulateBitFlipping(Data^,
                        result,
                        fSimulatedOutgoingMinimumFlippingBits,
                        fSimulatedOutgoingMaximumFlippingBits);
   end;
   if (aDataLength=0) or
      (not assigned(aAddress)) or
      ((fSimulatedOutgoingLatency=0) and
       (fSimulatedOutgoingJitter=0) and
       (fSimulatedOutgoingDuplicatePacketProbabilityFactor=0) and
       (fSimulatedOutgoingOutOfOrderPacketProbabilityFactor=0)) then begin
    result:=fNetwork.Send(aSocket,aAddress,Data^,aDataLength,aFamily);
   end else begin
    fLock.Acquire;
    try
     Time:=fInstance.Time;
     Delay:=(fSimulatedOutgoingLatency+(fRandomGenerator.GetUniformBoundedUInt32(fSimulatedOutgoingJitter*2)))-fSimulatedOutgoingJitter;
     if SimulateOutgoingOutOfOrderPacket then begin
      Delay:=Delay+fRandomGenerator.GetUniformBoundedUInt32(99)+1;
      if fOutgoingPacketList.IsNotEmpty then begin
       Delay:=Delay+Max(0,TRNLNetworkInterferenceSimulatorPacket(fOutgoingPacketList.Back).fTime.fValue-Time.fValue);
      end;
     end;
     if Delay>0 then begin
      Packet:=TRNLNetworkInterferenceSimulatorPacket.Create(self);
      try
       Packet.fTime.fValue:=Time.fValue+TRNLUInt64(Delay);
       Packet.fSocket:=aSocket;
       Packet.fAddress:=aAddress^;
       SetLength(Packet.fData,aDataLength);
       Move(Data^,Packet.fData[0],aDataLength);
       Packet.fFamily:=aFamily;
      finally
       fOutgoingPacketList.SortedInserted(Packet,TRNLNetworkInterferenceSimulatorPacketCompare);
      end;
      result:=aDataLength;
     end else begin
      Delay:=0;
      result:=fNetwork.Send(aSocket,aAddress,Data^,aDataLength,aFamily);
     end;
     if (result=aDataLength) and SimulateOutgoingDuplicatePacket then begin
      inc(Delay,fRandomGenerator.GetUniformBoundedUInt32(99)+1);
      Packet:=TRNLNetworkInterferenceSimulatorPacket.Create(self);
      try
       Packet.fTime.fValue:=Time.fValue+TRNLUInt64(Delay);
       Packet.fSocket:=aSocket;
       Packet.fAddress:=aAddress^;
       SetLength(Packet.fData,aDataLength);
       Move(Data^,Packet.fData[0],aDataLength);
       Packet.fFamily:=aFamily;
      finally
       fOutgoingPacketList.SortedInserted(Packet,TRNLNetworkInterferenceSimulatorPacketCompare);
      end;
     end;
    finally
     fLock.Release;
    end;
   end;
  finally
   if Data<>@aData then begin
    FreeMem(Data);
   end;
  end;
 end;
end;

function TRNLNetworkInterferenceSimulator.Receive(const aSocket:TRNLSocket;const aAddress:PRNLAddress;out aData;const aDataLength:TRNLSizeInt;const aFamily:TRNLAddressFamily):TRNLSizeInt;
var PacketListNode,NextPacketListNode:TRNLNetworkInterferenceSimulatorPacketListNode;
    Packet:TRNLNetworkInterferenceSimulatorPacket;
    Time:TRNLTime;
    Delay:TRNLInt64;
    HasPacket,DelayPacket:boolean;
begin

 Update;

 result:=0;

 repeat

  if (fSimulatedIncomingLatency<>0) or
     (fSimulatedIncomingJitter<>0) or
     (fSimulatedIncomingDuplicatePacketProbabilityFactor<>0) then begin

   HasPacket:=false;

   fLock.Acquire;
   try

    if not fIncomingPacketList.IsEmpty then begin

     Time:=fInstance.Time;

     PacketListNode:=fIncomingPacketList.Front;
     while PacketListNode<>fIncomingPacketList do begin
      NextPacketListNode:=PacketListNode.Next;
      Packet:=PacketListNode.fValue;
      if (Packet.fSocket=aSocket) and
         (Packet.fTime.fValue<=Time.fValue) then begin
       try
        result:=length(Packet.fData);
        if result<=aDataLength then begin
         if result>0 then begin
          Move(Packet.fData[0],aData,result);
         end;
         if assigned(aAddress) then begin
          aAddress^:=Packet.fAddress;
         end;
        end else begin
         result:=-1;
        end;
        HasPacket:=true;
        break;
       finally
        Packet.Free;
       end;
      end;
      PacketListNode:=NextPacketListNode;
     end;

    end;

   finally
    fLock.Release;
   end;

   if HasPacket then begin
    break;
   end;

  end;

  result:=fNetwork.Receive(aSocket,aAddress,aData,aDataLength,aFamily);

  if (result>0) and SimulateIncomingPacketLoss then begin
   continue;
  end;

  if (result>0) and
     assigned(aAddress) and
     ((fSimulatedIncomingLatency<>0) or
      (fSimulatedIncomingJitter<>0) or
      (fSimulatedIncomingDuplicatePacketProbabilityFactor<>0) or
      (fSimulatedIncomingOutOfOrderPacketProbabilityFactor<>0)) then begin

   fLock.Acquire;
   try
    Time:=fInstance.Time;
    Delay:=(fSimulatedIncomingLatency+(fRandomGenerator.GetUniformBoundedUInt32(fSimulatedIncomingJitter*2)))-fSimulatedIncomingJitter;
    if SimulateIncomingOutOfOrderPacket then begin
     Delay:=Delay+fRandomGenerator.GetUniformBoundedUInt32(99)+1;
     if fIncomingPacketList.IsNotEmpty then begin
      Delay:=Delay+Max(0,TRNLNetworkInterferenceSimulatorPacket(fIncomingPacketList.Back).fTime.fValue-Time.fValue);
     end;
    end;
    DelayPacket:=Delay>0;
    if DelayPacket then begin
     Packet:=TRNLNetworkInterferenceSimulatorPacket.Create(self);
     try
      Packet.fTime.fValue:=Time.fValue+TRNLUInt64(Delay);
      Packet.fSocket:=aSocket;
      Packet.fAddress:=aAddress^;
      SetLength(Packet.fData,result);
      Move(aData,Packet.fData[0],result);
      Packet.fFamily:=aFamily;
     finally
      fIncomingPacketList.SortedInserted(Packet,TRNLNetworkInterferenceSimulatorPacketCompare);
     end;
    end else begin
     Delay:=0;
    end;
    if SimulateIncomingDuplicatePacket then begin
     inc(Delay,fRandomGenerator.GetUniformBoundedUInt32(99)+1);
     Packet:=TRNLNetworkInterferenceSimulatorPacket.Create(self);
     try
      Packet.fTime.fValue:=Time.fValue+TRNLUInt64(Delay);
      Packet.fSocket:=aSocket;
      Packet.fAddress:=aAddress^;
      SetLength(Packet.fData,result);
      Move(aData,Packet.fData[0],result);
      Packet.fFamily:=aFamily;
     finally
      fIncomingPacketList.SortedInserted(Packet,TRNLNetworkInterferenceSimulatorPacketCompare);
     end;
    end;
   finally
    fLock.Release;
   end;

   if DelayPacket then begin
    result:=0;
    continue;
   end;

  end;

  break;

 until false;

 if (result>0) and SimulateIncomingBitFlipping then begin

  SimulateBitFlipping(aData,
                      result,
                      fSimulatedIncomingMinimumFlippingBits,
                      fSimulatedIncomingMaximumFlippingBits);

 end;
end;

constructor TRNLCompressor.Create;
begin
 inherited Create;
end;

destructor TRNLCompressor.Destroy;
begin
 inherited Destroy;
end;

function TRNLCompressor.Compress(const aInData:TRNLPointer;const aInSize:TRNLSizeUInt;const aOutData:TRNLPointer;const aOutLimit:TRNLSizeUInt):TRNLSizeUInt;
begin
 result:=0;
end;

function TRNLCompressor.Decompress(const aInData:TRNLPointer;const aInSize:TRNLSizeUInt;const aOutData:TRNLPointer;const aOutLimit:TRNLSizeUInt):TRNLSizeUInt;
begin
 result:=0;
end;

constructor TRNLCompressorDeflate.Create;
 procedure BuildFixedTrees(var aLT,aDT:TTree);
 var i:TRNLInt32;
 begin
  for i:=0 to 6 do begin
   aLT.Table[i]:=0;
  end;
  aLT.Table[7]:=24;
  aLT.Table[8]:=152;
  aLT.Table[9]:=112;
  for i:=0 to 23 do begin
   aLT.Translation[i]:=256+i;
  end;
  for i:=0 to 143 do begin
   aLT.Translation[24+i]:=i;
  end;
  for i:=0 to 7 do begin
   aLT.Translation[168+i]:=280+i;
  end;
  for i:=0 to 111 do begin
   aLT.Translation[176+i]:=144+i;
  end;
  for i:=0 to 4 do begin
   aDT.Table[i]:=0;
  end;
  aDT.Table[5]:=32;
  for i:=0 to 31 do begin
   aDT.Translation[i]:=i;
  end;
 end;
 procedure BuildBitsBase(aBits:PRNLUInt8Array;aBase:PRNLUInt16;aDelta,aFirst:TRNLInt32);
 var i,Sum:TRNLInt32;
 begin
  for i:=0 to aDelta-1 do begin
   aBits^[i]:=0;
  end;
  for i:=0 to (30-aDelta)-1 do begin
   aBits^[i+aDelta]:=i div aDelta;
  end;
  Sum:=aFirst;
  for i:=0 to 29 do begin
   aBase^:=Sum;
   inc(aBase);
   inc(Sum,1 shl aBits^[i]);
  end;
 end;
var Index,ValueIndex:TRNLInt32;
begin
 inherited Create;
 for Index:=0 to length(LengthCodes)-1 do begin
  for ValueIndex:=IfThen(Index=0,0,LengthCodes[Index,2]) to LengthCodes[Index,3] do begin
   fLengthCodesLookUpTable[ValueIndex]:=Index;
  end;
 end;
 for Index:=0 to length(DistanceCodes)-1 do begin
  for ValueIndex:=IfThen(Index=0,0,DistanceCodes[Index,2]) to DistanceCodes[Index,3] do begin
   fDistanceCodesLookUpTable[ValueIndex]:=Index;
  end;
 end;
 FillChar(fLengthBits,sizeof(TBits),#0);
 FillChar(fDistanceBits,sizeof(TBits),#0);
 FillChar(fLengthBase,sizeof(TBase),#0);
 FillChar(fDistanceBase,sizeof(TBase),#0);
 FillChar(fFixedSymbolLengthTree,sizeof(TTree),#0);
 FillChar(FfixedDistanceTree,sizeof(TTree),#0);
 BuildFixedTrees(fFixedSymbolLengthTree,fFixedDistanceTree);
 BuildBitsBase(TRNLPointer(@fLengthBits[0]),PRNLUInt16(TRNLPointer(@fLengthBase[0])),4,3);
 BuildBitsBase(TRNLPointer(@fDistanceBits[0]),PRNLUInt16(TRNLPointer(@fDistanceBase[0])),2,1);
 fLengthBits[28]:=0;
 fLengthBase[28]:=258;
 fWithHeader:=false;
 fGreedy:=true;
 fSkipStrength:=32;
 fMaxSteps:=128;
end;

destructor TRNLCompressorDeflate.Destroy;
begin
 inherited Destroy;
end;

function TRNLCompressorDeflate.Compress(const aInData:TRNLPointer;const aInSize:TRNLSizeUInt;const aOutData:TRNLPointer;const aOutLimit:TRNLSizeUInt):TRNLSizeUInt;
var OutputBits,CountOutputBits:TRNLUInt32;
    DestLen:TRNLSizeUInt;
    OK:boolean;
 procedure DoOutputBits(const aBits,aCountBits:TRNLUInt32);
 begin
  Assert((CountOutputBits+aCountBits)<=32);
  OutputBits:=OutputBits or (aBits shl CountOutputBits);
  inc(CountOutputBits,aCountBits);
  while CountOutputBits>=8 do begin
   if DestLen<aOutLimit then begin
    PRNLUInt8Array(aOutData)^[DestLen]:=OutputBits and $ff;
    inc(DestLen);
   end else begin
    OK:=false;
   end;
   OutputBits:=OutputBits shr 8;
   dec(CountOutputBits,8);
  end;
 end;
 procedure DoOutputLiteral(const aValue:TRNLUInt8);
 begin
  case aValue of
   0..143:begin
    DoOutputBits(MirrorBytes[$30+aValue],8);
   end;
   else begin
    DoOutputBits((MirrorBytes[$90+(aValue-144)] shl 1) or 1,9);
   end;
  end;
 end;
 procedure DoOutputCopy(const aDistance,aLength:TRNLUInt32);
 var Remain,ToDo,Index:TRNLUInt32;
 begin
  Remain:=aLength;
  while Remain>0 do begin
   case Remain of
    0..258:begin
     ToDo:=Remain;
    end;
    259..260:begin
     ToDo:=Remain-3;
    end;
    else begin
     ToDo:=258;
    end;
   end;
   dec(Remain,ToDo);
   Index:=fLengthCodesLookUpTable[Min(Max(ToDo,0),258)];
   if LengthCodes[Index,0]<=279 then begin
    DoOutputBits(MirrorBytes[(LengthCodes[Index,0]-256) shl 1],7);
   end else begin
    DoOutputBits(MirrorBytes[$c0+(LengthCodes[Index,0]-280)],8);
   end;
   if LengthCodes[Index,1]<>0 then begin
    DoOutputBits(ToDo-LengthCodes[Index,2],LengthCodes[Index,1]);
   end;
   Index:=fDistanceCodesLookUpTable[Min(Max(aDistance,0),32768)];
   DoOutputBits(MirrorBytes[DistanceCodes[Index,0] shl 3],5);
   if DistanceCodes[Index,1]<>0 then begin
    DoOutputBits(aDistance-DistanceCodes[Index,2],DistanceCodes[Index,1]);
   end;
  end;
 end;
 procedure OutputStartBlock;
 begin
  DoOutputBits(1,1); // Final block
  DoOutputBits(1,2); // Static huffman block
 end;
 procedure OutputEndBlock;
 begin
  DoOutputBits(0,7); // Close block
  DoOutputBits(0,7); // Make sure all bits are flushed
 end;
 function Adler32(const aData:TRNLPointer;const aLength:TRNLUInt32):TRNLUInt32;
 const Base=65521;
       MaximumCountAtOnce=5552;
 var Buf:PRNLUInt8;
     Remain,s1,s2,ToDo,Index:TRNLUInt32;
 begin
  s1:=1;
  s2:=0;
  Buf:=aData;
  Remain:=aLength;
  while Remain>0 do begin
   if Remain<MaximumCountAtOnce then begin
    ToDo:=Remain;
   end else begin
    ToDo:=MaximumCountAtOnce;
   end;
   dec(Remain,ToDo);
   for Index:=1 to ToDo do begin
    inc(s1,TRNLUInt8(Buf^));
    inc(s2,s1);
    inc(Buf);
   end;
   s1:=s1 mod Base;
   s2:=s2 mod Base;
  end;
  result:=(s2 shl 16) or s1;
 end;
var CurrentPointer,EndPointer,EndSearchPointer,Head,CurrentPossibleMatch:PRNLUInt8;
    BestMatchDistance,BestMatchLength,MatchLength,CheckSum,Step,Difference,Offset,
    UnsuccessfulFindMatchAttempts:TRNLUInt32;
    HashTableItem:PPRNLUInt8;
begin
 OK:=true;
 DestLen:=0;
 OutputBits:=0;
 CountOutputBits:=0;
 if fWithHeader then begin
  DoOutputBits($78,8); // CMF
  DoOutputBits($9c,8); // FLG Default Compression
 end;
 OutputStartBlock;
 FillChar(fHashTable,SizeOf(THashTable),#0);
 FillChar(fChainTable,SizeOf(TChainTable),#0);
 CurrentPointer:=aInData;
 EndPointer:={%H-}TRNLPointer(TRNLPtrUInt(TRNLPtrUInt(CurrentPointer)+TRNLPtrUInt(aInSize)));
 EndSearchPointer:={%H-}TRNLPointer(TRNLPtrUInt((TRNLPtrUInt(CurrentPointer)+TRNLPtrUInt(aInSize))-TRNLPtrUInt(TRNLInt64(Max(TRNLInt64(MinMatch),TRNLInt64(SizeOf(TRNLUInt32)))))));
 UnsuccessfulFindMatchAttempts:=TRNLUInt32(1) shl fSkipStrength;
 while {%H-}TRNLPtrUInt(CurrentPointer)<{%H-}TRNLPtrUInt(EndSearchPointer) do begin
  HashTableItem:=@fHashTable[((((PRNLUInt32(TRNLPointer(CurrentPointer))^ and TRNLUInt32({$if defined(FPC_BIG_ENDIAN)}$ffffff00{$else}$00ffffff{$ifend}){$if defined(FPC_BIG_ENDIAN)}shr 8{$ifend}))*TRNLUInt32($1e35a7bd)) shr HashShift) and HashMask];
  Head:=HashTableItem^;
  CurrentPossibleMatch:=Head;
  BestMatchDistance:=0;
  BestMatchLength:=1;
  Step:=0;
  while assigned(CurrentPossibleMatch) and
        ({%H-}TRNLPtrUInt(CurrentPointer)>{%H-}TRNLPtrUInt(CurrentPossibleMatch)) and
        (TRNLPtrInt({%H-}TRNLPtrUInt({%H-}TRNLPtrUInt(CurrentPointer)-{%H-}TRNLPtrUInt(CurrentPossibleMatch)))<TRNLPtrInt(MaxOffset)) do begin
   Difference:=PRNLUInt32(TRNLPointer(@PRNLUInt8Array(CurrentPointer)^[0]))^ xor PRNLUInt32(TRNLPointer(@PRNLUInt8Array(CurrentPossibleMatch)^[0]))^;
   if (Difference and TRNLUInt32({$if defined(FPC_BIG_ENDIAN)}$ffffff00{$else}$00ffffff{$ifend}))=0 then begin
    if (BestMatchLength<=({%H-}TRNLPtrUInt(EndPointer)-{%H-}TRNLPtrUInt(CurrentPointer))) and
       (PRNLUInt8Array(CurrentPointer)^[BestMatchLength-1]=PRNLUInt8Array(CurrentPossibleMatch)^[BestMatchLength-1]) then begin
     MatchLength:=MinMatch;
     while (({%H-}TRNLPtrUInt(@PRNLUInt8Array(CurrentPointer)^[MatchLength]) and (SizeOf(TRNLUInt32)-1))<>0) and
           (({%H-}TRNLPtrUInt(@PRNLUInt8Array(CurrentPointer)^[MatchLength])<{%H-}TRNLPtrUInt(EndPointer))) and
           (PRNLUInt8Array(CurrentPointer)^[MatchLength]=PRNLUInt8Array(CurrentPossibleMatch)^[MatchLength]) do begin
      inc(MatchLength);
     end;
     while ({%H-}TRNLPtrUInt(@PRNLUInt8Array(CurrentPointer)^[MatchLength+(SizeOf(TRNLUInt32)-1)])<{%H-}TRNLPtrUInt(EndPointer)) do begin
      Difference:=PRNLUInt32(TRNLPointer(@PRNLUInt8Array(CurrentPointer)^[MatchLength]))^ xor PRNLUInt32(TRNLPointer(@PRNLUInt8Array(CurrentPossibleMatch)^[MatchLength]))^;
      if Difference=0 then begin
       inc(MatchLength,SizeOf(TRNLUInt32));
      end else begin
{$if defined(FPC_BIG_ENDIAN)}
       if (Difference shr 16)<>0 then begin
        inc(MatchLength,not (Difference shr 24));
       end else begin
        inc(MatchLength,2+(not (Difference shr 8)));
       end;
{$else}
       inc(MatchLength,MultiplyDeBruijnBytePosition[TRNLUInt32(TRNLUInt32(Difference and (-Difference))*TRNLUInt32($077cb531)) shr 27]);
{$ifend}
       break;
      end;
     end;
     if BestMatchLength<MatchLength then begin
      BestMatchDistance:={%H-}TRNLPtrUInt({%H-}TRNLPtrUInt(CurrentPointer)-{%H-}TRNLPtrUInt(CurrentPossibleMatch));
      BestMatchLength:=MatchLength;
     end;
    end;
   end;
   inc(Step);
   if Step<fMaxSteps then begin
    CurrentPossibleMatch:=fChainTable[({%H-}TRNLPtrUInt(CurrentPossibleMatch)-{%H-}TRNLPtrUInt(aInData)) and WindowMask];
   end else begin
    break;
   end;
  end;
  if (BestMatchDistance>0) and (BestMatchLength>1) then begin
   DoOutputCopy(BestMatchDistance,BestMatchLength);
   UnsuccessfulFindMatchAttempts:=TRNLUInt32(1) shl fSkipStrength;
  end else begin
   if fSkipStrength>31 then begin
    DoOutputLiteral(CurrentPointer^);
   end else begin
    Step:=UnsuccessfulFindMatchAttempts shr fSkipStrength;
    Offset:=0;
    while (Offset<Step) and (({%H-}TRNLPtrUInt(CurrentPointer)+Offset)<{%H-}TRNLPtrUInt(EndSearchPointer)) do begin
     DoOutputLiteral(PRNLUInt8Array(CurrentPointer)^[Offset]);
     inc(Offset);
    end;
    BestMatchLength:=Offset;
    inc(UnsuccessfulFindMatchAttempts,ord(UnsuccessfulFindMatchAttempts<TRNLUInt32($ffffffff)) and 1);
   end;
  end;
  if not OK then begin
   break;
  end;
  HashTableItem^:=CurrentPointer;
  fChainTable[({%H-}TRNLPtrUInt(CurrentPointer)-{%H-}TRNLPtrUInt(aInData)) and WindowMask]:=Head;
  if fGreedy then begin
   inc(CurrentPointer);
   dec(BestMatchLength);
   while (BestMatchLength>0) and ({%H-}TRNLPtrUInt(CurrentPointer)<{%H-}TRNLPtrUInt(EndSearchPointer)) do begin
    HashTableItem:=@fHashTable[((((PRNLUInt32(TRNLPointer(CurrentPointer))^ and TRNLUInt32({$if defined(FPC_BIG_ENDIAN)}$ffffff00{$else}$00ffffff{$ifend}){$if defined(FPC_BIG_ENDIAN)}shr 8{$ifend}))*TRNLUInt32($1e35a7bd)) shr HashShift) and HashMask];
    Head:=HashTableItem^;
    HashTableItem^:=CurrentPointer;
    fChainTable[({%H-}TRNLPtrUInt(CurrentPointer)-{%H-}TRNLPtrUInt(aInData)) and WindowMask]:=Head;
    inc(CurrentPointer);
    dec(BestMatchLength);
   end;
  end;
  inc(CurrentPointer,BestMatchLength);
 end;
 while {%H-}TRNLPtrUInt(CurrentPointer)<{%H-}TRNLPtrUInt(EndPointer) do begin
  DoOutputLiteral(CurrentPointer^);
  if not OK then begin
   break;
  end;
  inc(CurrentPointer);
 end;
 OutputEndBlock;
 if fWithHeader then begin
  CheckSum:=Adler32(aInData,aInSize);
  if (DestLen+4)<aOutLimit then begin
   PRNLUInt8Array(aOutData)^[DestLen+0]:=(CheckSum shr 24) and $ff;
   PRNLUInt8Array(aOutData)^[DestLen+1]:=(CheckSum shr 16) and $ff;
   PRNLUInt8Array(aOutData)^[DestLen+2]:=(CheckSum shr 8) and $ff;
   PRNLUInt8Array(aOutData)^[DestLen+3]:=(CheckSum shr 0) and $ff;
   inc(DestLen,4);
  end;
 end;
 if OK then begin
  result:=DestLen;
 end else begin
  result:=0;
 end;
end;

function TRNLCompressorDeflate.Decompress(const aInData:TRNLPointer;const aInSize:TRNLSizeUInt;const aOutData:TRNLPointer;const aOutLimit:TRNLSizeUInt):TRNLSizeUInt;
var Tag,BitCount:TRNLUInt32;
    Source,SourceEnd:PRNLUInt8;
    Dest:PRNLUInt8;
    DestLen:TRNLSizeUInt;
 function Adler32(aData:TRNLPointer;aLength:TRNLUInt32):TRNLUInt32;
 const BASE=65521;
       NMAX=5552;
 var buf:PRNLUInt8;
     s1,s2,k,i:TRNLUInt32;
 begin
  s1:=1;
  s2:=0;
  buf:=aData;
  while aLength>0 do begin
   if aLength<NMAX then begin
    k:=aLength;
   end else begin
    k:=NMAX;
   end;
   dec(aLength,k);
   for i:=1 to k do begin
    inc(s1,TRNLUInt8(buf^));
    inc(s2,s1);
    inc(buf);
   end;
   s1:=s1 mod Base;
   s2:=s2 mod Base;
  end;
  result:=(s2 shl 16) or s1;
 end;
 procedure BuildTree(var aTree:TTree;aLengths:PRNLUInt8Array;aNum:TRNLInt32);
 var Offsets:POffsets;
     i:TRNLInt32;
     Sum:TRNLUInt32;
 begin
  New(Offsets);
  try
   for i:=0 to 15 do begin
    aTree.Table[i]:=0;
   end;
   for i:=0 to aNum-1 do begin
    inc(aTree.Table[TRNLUInt8(aLengths^[i])]);
   end;
   aTree.Table[0]:=0;
   Sum:=0;
   for i:=0 to 15 do begin
    Offsets^[i]:=Sum;
    inc(Sum,aTree.Table[i]);
   end;
   for i:=0 to aNum-1 do begin
    if aLengths^[i]<>0 then begin
     aTree.Translation[Offsets^[TRNLUInt8(aLengths^[i])]]:=i;
     inc(Offsets^[TRNLUInt8(aLengths^[i])]);
    end;
   end;
  finally
   Dispose(Offsets);
  end;
 end;
 function GetBit:TRNLUInt32;
 begin
  if BitCount=0 then begin
   Tag:=TRNLUInt8(Source^);
   inc(Source);
   BitCount:=7;
  end else begin
   dec(BitCount);
  end;
  result:=Tag and 1;
  Tag:=Tag shr 1;
 end;
 function ReadBits(aNum,aBase:TRNLUInt32):TRNLUInt32;
 var Limit,Mask:TRNLUInt32;
 begin
  result:=0;
  if aNum<>0 then begin
   Limit:=1 shl aNum;
   Mask:=1;
   while Mask<Limit do begin
    if GetBit<>0 then begin
     inc(result,Mask);
    end;
    Mask:=Mask shl 1;
   end;
  end;
  inc(result,aBase);
 end;
 function DecodeSymbol(const aTree:TTree):TRNLUInt32;
 var Sum,c,l:TRNLInt32;
 begin
  Sum:=0;
  c:=0;
  l:=0;
  repeat
   c:=(c*2)+TRNLInt32(GetBit);
   inc(l);
   inc(Sum,aTree.Table[l]);
   dec(c,aTree.Table[l]);
  until not (c>=0);
  result:=aTree.Translation[Sum+c];
 end;
 procedure DecodeTrees(var aLT,aDT:TTree);
 var hlit,hdist,hclen,i,Num,Len,clen,Symbol,Prev:TRNLUInt32;
 begin
  FillChar(fCodeTree,sizeof(TTree),#0);
  FillChar(fLengths,sizeof(TLengths),#0);
  hlit:=ReadBits(5,257);
  hdist:=ReadBits(5,1);
  hclen:=ReadBits(4,4);
  for i:=0 to 18 do begin
   fLengths[i]:=0;
  end;
  for i:=1 to hclen do begin
   clen:=ReadBits(3,0);
   fLengths[CLCIndex[i-1]]:=clen;
  end;
  BuildTree(fCodeTree,TRNLPointer(@fLengths[0]),19);
  Num:=0;
  while Num<(hlit+hdist) do begin
   Symbol:=DecodeSymbol(fCodeTree);
   case Symbol of
    16:begin
     prev:=fLengths[Num-1];
     Len:=ReadBits(2,3);
     while Len>0 do begin
      fLengths[Num]:=prev;
      inc(Num);
      dec(Len);
     end;
    end;
    17:begin
     Len:=ReadBits(3,3);
     while Len>0 do begin
      fLengths[Num]:=0;
      inc(Num);
      dec(Len);
     end;
    end;
    18:begin
     Len:=ReadBits(7,11);
     while Len>0 do begin
      fLengths[Num]:=0;
      inc(Num);
      dec(Len);
     end;
    end;
    else begin
     fLengths[Num]:=Symbol;
     inc(Num);
    end;
   end;
  end;
  BuildTree(aLT,TRNLPointer(@fLengths[0]),hlit);
  BuildTree(aDT,TRNLPointer(@fLengths[hlit]),hdist);
 end;
 function InflateBlockData(const aLT,aDT:TTree):boolean;
 var Symbol:TRNLUInt32;
     Len,Distance,Offset:TRNLInt32;
     t:PRNLUInt8;
 begin
  result:=false;
  while ({%H-}TRNLPtrUInt(TRNLPointer(Source))<{%H-}TRNLPtrUInt(TRNLPointer(SourceEnd))) or (BitCount>0) do begin
   Symbol:=DecodeSymbol(aLT);
   if Symbol=256 then begin
    result:=true;
    break;
   end;
   if Symbol<256 then begin
    if (DestLen+1)<=aOutLimit then begin
     Dest^:=TRNLUInt8(Symbol);
     inc(Dest);
     inc(DestLen);
    end else begin
     exit;
    end;
   end else begin
    dec(Symbol,257);
    Len:=ReadBits(fLengthBits[Symbol],fLengthBase[Symbol]);
    Distance:=DecodeSymbol(aDT);
    Offset:=ReadBits(fDistanceBits[Distance],fDistanceBase[Distance]);
    if (DestLen+TRNLSizeUInt(Len))<=aOutLimit then begin
     t:=TRNLPointer(Dest);
     dec(t,Offset);
     RLELikeSideEffectAwareMemoryMove(t^,Dest^,Len);
     inc(Dest,Len);
     inc(DestLen,Len);
    end else begin
     exit;
    end;
   end;
  end;
 end;
 function InflateUncompressedBlock:boolean;
 var Len,InvLen:TRNLUInt32;
 begin
  result:=false;
  Len:=(TRNLUInt8(PRNLUInt8Array(Source)^[1]) shl 8) or TRNLUInt8(PRNLUInt8Array(Source)^[0]);
  InvLen:=(TRNLUInt8(PRNLUInt8Array(Source)^[3]) shl 8) or TRNLUInt8(PRNLUInt8Array(Source)^[2]);
  if Len<>((not InvLen) and $ffff) then begin
   exit;
  end;
  inc(Source,4);
  if Len>0 then begin
   if (DestLen+Len)<aOutLimit then begin
    Move(Source^,Dest^,Len);
    inc(Source,Len);
    inc(Dest,Len);
   end else begin
    exit;
   end;
  end;
  BitCount:=0;
  inc(DestLen,Len);
  result:=true;
 end;
 function InflateFixedBlock:boolean;
 begin
  result:=InflateBlockData(fFixedSymbolLengthTree,fFixedDistanceTree);
 end;
 function InflateDynamicBlock:boolean;
 begin
  FillChar(fSymbolLengthTree,sizeof(TTree),#0);
  FillChar(fDistanceTree,sizeof(TTree),#0);
  DecodeTrees(fSymbolLengthTree,fDistanceTree);
  result:=InflateBlockData(fSymbolLengthTree,fDistanceTree);
 end;
 function Uncompress:boolean;
 var FinalBlock:boolean;
     BlockType:TRNLUInt32;
 begin
  BitCount:=0;
  repeat
   FinalBlock:=GetBit<>0;
   BlockType:=ReadBits(2,0);
   case BlockType of
    0:begin
     result:=InflateUncompressedBlock;
    end;
    1:begin
     result:=InflateFixedBlock;
    end;
    2:begin
     result:=InflateDynamicBlock;
    end;
    else begin
     result:=false;
    end;
   end;
  until FinalBlock or not result;
 end;
 function UncompressZLIB:boolean;
 var cmf,flg:TRNLUInt8;
     a32:TRNLUInt32;
 begin
  result:=false;
  Source:=aInData;
  cmf:=TRNLUInt8(PRNLUInt8Array(Source)^[0]);
  flg:=TRNLUInt8(PRNLUInt8Array(Source)^[1]);
  if ((((cmf shl 8)+flg) mod 31)<>0) or ((cmf and $f)<>8) or ((cmf shr 4)>7) or ((flg and $20)<>0) then begin
   exit;
  end;
  a32:=(TRNLUInt8(PRNLUInt8Array(Source)^[aInSize-4]) shl 24) or
       (TRNLUInt8(PRNLUInt8Array(Source)^[aInSize-3]) shl 16) or
       (TRNLUInt8(PRNLUInt8Array(Source)^[aInSize-2]) shl 8) or
       (TRNLUInt8(PRNLUInt8Array(Source)^[aInSize-1]) shl 0);
  inc(Source,2);
  SourceEnd:=@PRNLUInt8Array(Source)^[aInSize-6];
  result:=Uncompress;
  if not result then begin
   exit;
  end;
  result:=Adler32(aOutData,DestLen)=a32;
 end;
 function UncompressDirect:boolean;
 begin
  Source:=aInData;
  SourceEnd:=@PRNLUInt8Array(Source)^[aInSize];
  result:=Uncompress;
 end;
begin
 Dest:=aOutData;
 DestLen:=0;
 result:=0;
 if fWithHeader then begin
  if UncompressZLIB then begin
   result:=DestLen;
  end;
 end else begin
  if UncompressDirect then begin
   result:=DestLen;
  end;
 end;
end;

constructor TRNLCompressorLZBRRC.Create;
begin
 inherited Create;
 fGreedy:=true;
 fSkipStrength:=32;
 fMaxSteps:=128;
end;

destructor TRNLCompressorLZBRRC.Destroy;
begin
 inherited Destroy;
end;

function TRNLCompressorLZBRRC.Compress(const aInData:TRNLPointer;const aInSize:TRNLSizeUInt;const aOutData:TRNLPointer;const aOutLimit:TRNLSizeUInt):TRNLSizeUInt;
var {$ifndef CPU64}Code,{$endif}Range,Cache,CountFFBytes:TRNLUInt32;
    {$ifdef CPU64}Code:TRNLUInt64;{$endif}
    Model:array[0..SizeModels-1] of TRNLUInt32;
    LastWasMatch,FirstByte{$ifndef CPU64},Carry{$endif},OK:boolean;
    DestLen,MinDestLen:TRNLUInt32;
 procedure EncoderShift;
{$ifdef CPU64}
 var Carry:boolean;
{$endif}
 begin
{$ifdef CPU64}
  Carry:=PRNLUInt64Record(TRNLPointer(@Code))^.Hi<>0; // or (Code shr 32)<>0; or also (Code and TRNLUInt64($ffffffff00000000))<>0;
{$endif}
  if (Code<$ff000000) or Carry then begin
   if FirstByte then begin
    FirstByte:=false;
   end else begin
    if TRNLSizeUInt(DestLen)<TRNLSizeUInt(aOutLimit) then begin
     PRNLUInt8Array(aOutData)^[DestLen]:=Cache+TRNLUInt8(ord(Carry) and 1);
     inc(DestLen);
    end else begin
     OK:=false;
     exit;
    end;
   end;
   while CountFFBytes<>0 do begin
    dec(CountFFBytes);
    if TRNLSizeUInt(DestLen)<TRNLSizeUInt(aOutLimit) then begin
     PRNLUInt8Array(aOutData)^[DestLen]:=$ff+TRNLUInt8(ord(Carry) and 1);
     inc(DestLen);
    end else begin
     OK:=false;
     exit;
    end;
   end;
   Cache:=(Code shr 24) and $ff;
  end else begin
   inc(CountFFBytes);
  end;
  Code:=(Code shl 8){$ifdef CPU64}and TRNLUInt32($ffffffff){$endif};
  Carry:=false;
 end;
 function EncodeBit(ModelIndex,Move,Bit:TRNLInt32):TRNLInt32;
 var Bound{$ifndef CPU64},OldCode{$endif}:TRNLUInt32;
 begin
  Bound:=(Range shr 12)*Model[ModelIndex];
  if Bit=0 then begin
   Range:=Bound;
   inc(Model[ModelIndex],(4096-Model[ModelIndex]) shr Move);
  end else begin
{$ifndef CPU64}
   OldCode:=Code;
{$endif}
   inc(Code,Bound);
{$ifndef CPU64}
   Carry:=Carry or (Code<OldCode);
{$endif}
   dec(Range,Bound);
   dec(Model[ModelIndex],Model[ModelIndex] shr Move);
  end;
  while Range<$1000000 do begin
   Range:=Range shl 8;
   EncoderShift;
  end;
  result:=Bit;
 end;
 procedure EncoderFlush;
 var Counter:TRNLInt32;
 begin
  for Counter:=1 to 5 do begin
   EncoderShift;
  end;
 end;
 procedure EncodeTree(ModelIndex,Bits,Move,Value:TRNLInt32);
 var Context:TRNLInt32;
 begin
  Context:=1;
  while Bits>0 do begin
   dec(Bits);
   Context:=(Context shl 1) or EncodeBit(ModelIndex+Context,Move,(Value shr Bits) and 1);
  end;
 end;
 procedure EncodeGamma(ModelIndex,Value:TRNLUInt32);
{$if true}
 var Index:TRNLInt32;
     Context:TRNLUInt8;
 begin
  Context:=1;
  for Index:=Max(1,BSRDWord(Value))-1 downto 0 do begin
   Context:=(Context shl 1) or TRNLUInt32(EncodeBit(ModelIndex+Context,5,TRNLUInt32(-Index) shr 31));
   Context:=(Context shl 1) or TRNLUInt32(EncodeBit(ModelIndex+Context,5,TRNLUInt32(-((Value shr Index) and 1)) shr 31));
  end;
 end;
{$else}
 var Mask:TRNLUInt32;
     Context:TRNLUInt8;
 begin
  Mask:=Value shr 1;
  while (Mask and (Mask-1))<>0 do begin
   Mask:=Mask and (Mask-1);
  end;
  Context:=1;
  while Mask<>0 do begin
   Context:=(Context shl 1) or TRNLUInt32(EncodeBit(ModelIndex+Context,5,TRNLUInt32(-(Mask shr 1)) shr 31));
   Context:=(Context shl 1) or TRNLUInt32(EncodeBit(ModelIndex+Context,5,TRNLUInt32(-(Value and Mask)) shr 31));
   Mask:=Mask shr 1;
  end;
 end;
{$ifend}
 procedure EncodeEnd(ModelIndex:TRNLInt32);
 var Bits:TRNLUInt32;
     Context:TRNLUInt8;
 begin
  Context:=1;
  Bits:=32;
  while Bits>0 do begin
   dec(Bits);
   Context:=(Context shl 1) or EncodeBit(ModelIndex+Context,5,TRNLUInt32(-Bits) shr 31);
   EncodeBit(ModelIndex+Context,5,0);
   Context:=Context shl 1;
  end;
 end;
var CurrentPointer,EndPointer,EndSearchPointer,Head,CurrentPossibleMatch:PRNLUInt8;
    BestMatchDistance,BestMatchLength,MatchLength,Offset,Step,Difference,
    LastMatchDistance,UnsuccessfulFindMatchAttempts:TRNLUInt32;
    HashTableItem:PPRNLUInt8;
    First:boolean;
begin
 DestLen:=0;
 LastWasMatch:=false;
 FirstByte:=true;
 OK:=true;
 CountFFBytes:=0;
 Range:=$ffffffff;
 Code:=0;
 LastMatchDistance:=$ffffffff;
 for Step:=0 to SizeModels-1 do begin
  Model[Step]:=2048;
 end;
 FillChar(fHashTable,SizeOf(THashTable),#0);
 FillChar(fChainTable,SizeOf(TChainTable),#0);
 CurrentPointer:=aInData;
 EndPointer:={%H-}TRNLPointer(TRNLPtrUInt(TRNLPtrUInt(CurrentPointer)+TRNLPtrUInt(aInSize)));
 EndSearchPointer:={%H-}TRNLPointer(TRNLPtrUInt((TRNLPtrUInt(CurrentPointer)+TRNLPtrUInt(aInSize))-TRNLPtrUInt(TRNLInt64(Max(TRNLInt64(MinMatch),TRNLInt64(SizeOf(TRNLUInt32)))))));
 First:=true;
 UnsuccessfulFindMatchAttempts:=TRNLUInt32(1) shl fSkipStrength;
 while {%H-}TRNLPtrUInt(CurrentPointer)<{%H-}TRNLPtrUInt(EndSearchPointer) do begin
  HashTableItem:=@fHashTable[((((PRNLUInt32(TRNLPointer(CurrentPointer))^ and TRNLUInt32({$if defined(FPC_BIG_ENDIAN)}$ffff0000{$else}$0000ffff{$ifend}){$if defined(FPC_BIG_ENDIAN)}shr 16{$ifend}))*TRNLUInt32($1e35a7bd)) shr HashShift) and HashMask];
  Head:=HashTableItem^;
  CurrentPossibleMatch:=Head;
  BestMatchDistance:=0;
  BestMatchLength:=1;
  if First then begin
   First:=false;
   EncodeTree(LiteralModel,8,4,PRNLUInt8(CurrentPointer)^);
  end else begin
   Step:=0;
   while assigned(CurrentPossibleMatch) and
         ({%H-}TRNLPtrUInt(CurrentPointer)>{%H-}TRNLPtrUInt(CurrentPossibleMatch)) and
         (TRNLPtrInt({%H-}TRNLPtrUInt({%H-}TRNLPtrUInt(CurrentPointer)-{%H-}TRNLPtrUInt(CurrentPossibleMatch)))<TRNLPtrInt(MaxOffset)) do begin
    Difference:=PRNLUInt32(TRNLPointer(@PRNLUInt8Array(CurrentPointer)^[0]))^ xor PRNLUInt32(TRNLPointer(@PRNLUInt8Array(CurrentPossibleMatch)^[0]))^;
    if (Difference and TRNLUInt32({$if defined(FPC_BIG_ENDIAN)}$ffff0000{$else}$0000ffff{$ifend}))=0 then begin
     if (BestMatchLength<=({%H-}TRNLPtrUInt(EndPointer)-{%H-}TRNLPtrUInt(CurrentPointer))) and
        (PRNLUInt8Array(CurrentPointer)^[BestMatchLength-1]=PRNLUInt8Array(CurrentPossibleMatch)^[BestMatchLength-1]) then begin
      MatchLength:=MinMatch;
      while (({%H-}TRNLPtrUInt(@PRNLUInt8Array(CurrentPointer)^[MatchLength]) and (SizeOf(TRNLUInt32)-1))<>0) and
            (({%H-}TRNLPtrUInt(@PRNLUInt8Array(CurrentPointer)^[MatchLength])<{%H-}TRNLPtrUInt(EndPointer))) and
            (PRNLUInt8Array(CurrentPointer)^[MatchLength]=PRNLUInt8Array(CurrentPossibleMatch)^[MatchLength]) do begin
       inc(MatchLength);
      end;
      while ({%H-}TRNLPtrUInt(@PRNLUInt8Array(CurrentPointer)^[MatchLength+(SizeOf(TRNLUInt32)-1)])<{%H-}TRNLPtrUInt(EndPointer)) do begin
       Difference:=PRNLUInt32(TRNLPointer(@PRNLUInt8Array(CurrentPointer)^[MatchLength]))^ xor PRNLUInt32(TRNLPointer(@PRNLUInt8Array(CurrentPossibleMatch)^[MatchLength]))^;
       if Difference=0 then begin
        inc(MatchLength,SizeOf(TRNLUInt32));
       end else begin
{$if defined(BIG_ENDIAN)}
        if (Difference shr 16)<>0 then begin
         inc(MatchLength,not (Difference shr 24));
        end else begin
         inc(MatchLength,2+(not (Difference shr 8)));
        end;
{$else}
        inc(MatchLength,MultiplyDeBruijnBytePosition[TRNLUInt32(TRNLUInt32(Difference and (-Difference))*TRNLUInt32($077cb531)) shr 27]);
{$ifend}
        break;
       end;
      end;
      if BestMatchLength<MatchLength then begin
       BestMatchDistance:={%H-}TRNLPtrUInt({%H-}TRNLPtrUInt(CurrentPointer)-{%H-}TRNLPtrUInt(CurrentPossibleMatch));
       BestMatchLength:=MatchLength;
      end;
     end;
    end;
    inc(Step);
    if Step<fMaxSteps then begin
     CurrentPossibleMatch:=fChainTable[({%H-}TRNLPtrUInt(CurrentPossibleMatch)-{%H-}TRNLPtrUInt(aInData)) and WindowMask];
    end else begin
     break;
    end;
   end;
   if (BestMatchDistance>0) and
      (((BestMatchDistance<96) and (BestMatchLength>1)) or
       ((BestMatchDistance>=96) and (BestMatchLength>3)) or
       ((BestMatchDistance>=2048) and (BestMatchLength>4))) then begin
//  writeln('C: ',BestMatchLength,' ',{%H-}TRNLPtrUInt(CurrentPointer)-{%H-}TRNLPtrUInt(aInData),' ',({%H-}TRNLPtrUInt(CurrentPointer)-{%H-}TRNLPtrUInt(aInData))+BestMatchLength);
    MatchLength:=BestMatchLength;
    EncodeBit(FlagModel+TRNLUInt8(ord(LastWasMatch) and 1),5,1);
    if (not LastWasMatch) and (BestMatchDistance=LastMatchDistance) then begin
     EncodeBit(PreviousMatchModel,5,1);
    end else begin
     if not LastWasMatch then begin
      EncodeBit(PreviousMatchModel,5,0);
     end;
     Offset:=BestMatchDistance-1;
     EncodeGamma(Gamma0Model,(Offset shr 4)+2);
     EncodeTree(MatchLowModel+((ord((Offset shr 4)<>0) and 1) shl 4),4,5,Offset and $f);
     dec(MatchLength,(ord(BestMatchDistance>=96) and 1)+(ord(BestMatchDistance>=2048) and 1));
    end;
    EncodeGamma(Gamma1Model,MatchLength);
    LastWasMatch:=true;
    LastMatchDistance:=BestMatchDistance;
    UnsuccessfulFindMatchAttempts:=TRNLUInt32(1) shl fSkipStrength;
   end else begin
    if (fSkipStrength>31) and (BestMatchLength=1) then begin
     EncodeBit(FlagModel+TRNLUInt8(ord(LastWasMatch) and 1),5,0);
     EncodeTree(LiteralModel,8,4,CurrentPointer^);
     LastWasMatch:=false;
    end else begin
     if BestMatchLength=1 then begin
      Step:=UnsuccessfulFindMatchAttempts shr fSkipStrength;
     end else begin
      Step:=BestMatchLength;
     end;
     Offset:=0;
     while Offset<Step do begin
      if (({%H-}TRNLPtrUInt(CurrentPointer)+Offset)<{%H-}TRNLPtrUInt(EndSearchPointer)) then begin
       EncodeBit(FlagModel+TRNLUInt8(ord(LastWasMatch) and 1),5,0);
       EncodeTree(LiteralModel,8,4,PRNLUInt8Array(CurrentPointer)^[Offset]);
       LastWasMatch:=false;
       inc(Offset);
      end else begin
       BestMatchLength:=Offset;
       break;
      end;
     end;
     if BestMatchLength=1 then begin
      BestMatchLength:=Offset;
      inc(UnsuccessfulFindMatchAttempts,ord(UnsuccessfulFindMatchAttempts<TRNLUInt32($ffffffff)) and 1);
     end;
    end;
   end;
  end;
  if not OK then begin
   break;
  end;
  HashTableItem^:=CurrentPointer;
  fChainTable[({%H-}TRNLPtrUInt(CurrentPointer)-{%H-}TRNLPtrUInt(aInData)) and WindowMask]:=Head;
  if fGreedy then begin
   inc(CurrentPointer);
   dec(BestMatchLength);
   while (BestMatchLength>0) and ({%H-}TRNLPtrUInt(CurrentPointer)<{%H-}TRNLPtrUInt(EndSearchPointer)) do begin
    HashTableItem:=@fHashTable[((((PRNLUInt32(TRNLPointer(CurrentPointer))^ and TRNLUInt32({$if defined(FPC_BIG_ENDIAN)}$ffff0000{$else}$0000ffff{$ifend}){$if defined(FPC_BIG_ENDIAN)}shr 16{$ifend}))*TRNLUInt32($1e35a7bd)) shr HashShift) and HashMask];
    Head:=HashTableItem^;
    HashTableItem^:=CurrentPointer;
    fChainTable[({%H-}TRNLPtrUInt(CurrentPointer)-{%H-}TRNLPtrUInt(aInData)) and WindowMask]:=Head;
    inc(CurrentPointer);
    dec(BestMatchLength);
   end;
  end;
  inc(CurrentPointer,BestMatchLength);
 end;
 while {%H-}TRNLPtrUInt(CurrentPointer)<{%H-}TRNLPtrUInt(EndPointer) do begin
  EncodeBit(FlagModel+TRNLUInt8(ord(LastWasMatch) and 1),5,0);
  EncodeTree(LiteralModel,8,4,CurrentPointer^);
  LastWasMatch:=false;
  inc(CurrentPointer);
 end;
 EncodeBit(FlagModel+TRNLUInt8(ord(LastWasMatch) and 1),5,1);
 if not LastWasMatch then begin
  EncodeBit(PreviousMatchModel,5,0);
 end;
 EncodeEnd(Gamma0Model);
 MinDestLen:=Max(2,DestLen+1);
 EncoderFlush;
 if OK then begin
  while (DestLen>MinDestLen) and (PRNLUInt8Array(aOutData)^[DestLen-1]=0) do begin
   dec(DestLen);
  end;
  result:=DestLen;
 end else begin
  result:=0;
 end;
end;

function TRNLCompressorLZBRRC.Decompress(const aInData:TRNLPointer;const aInSize:TRNLSizeUInt;const aOutData:TRNLPointer;const aOutLimit:TRNLSizeUInt):TRNLSizeUInt;
var Code,Range,Position:TRNLUInt32;
    Model:array[0..SizeModels-1] of TRNLUInt32;
    OK:boolean;
 function DecodeBit(ModelIndex,Move:TRNLInt32):TRNLInt32;
 var Bound:TRNLUInt32;
 begin
  Bound:=(Range shr 12)*Model[ModelIndex];
  if Code<Bound then begin
   Range:=Bound;
   inc(Model[ModelIndex],(4096-Model[ModelIndex]) shr Move);
   result:=0;
  end else begin
   dec(Code,Bound);
   dec(Range,Bound);
   dec(Model[ModelIndex],Model[ModelIndex] shr Move);
   result:=1;
  end;
  while Range<$1000000 do begin
   if Position<aInSize then begin
    Code:=(Code shl 8) or PRNLUInt8Array(aInData)^[Position];
   end else begin
    if Position<(aInSize+5) then begin
     Code:=Code shl 8;
    end else begin
     OK:=false;
     break;
    end;
   end;
   inc(Position);
   Range:=Range shl 8;
  end;
 end;
 function DecodeTree(ModelIndex,MaxValue,Move:TRNLInt32):TRNLInt32;
 begin
  result:=1;
  while OK and (result<MaxValue) do begin
   result:=(result shl 1) or DecodeBit(ModelIndex+result,Move);
  end;
  dec(result,MaxValue);
 end;
 function DecodeGamma(ModelIndex:TRNLInt32):TRNLInt32;
 var Context:TRNLUInt8;
 begin
  result:=1;
  Context:=1;
  repeat
   Context:=(Context shl 1) or DecodeBit(ModelIndex+Context,5);
   result:=(result shl 1) or DecodeBit(ModelIndex+Context,5);
   Context:=(Context shl 1) or (result and 1);
  until (not OK) or ((Context and 2)=0);
 end;
var Len,Offset,LastOffset,DestLen,Value:TRNLInt32;
    Flag,LastWasMatch:boolean;
begin
 result:=0;
 if aInSize>=3 then begin
  OK:=true;
  Code:=(PRNLUInt8Array(aInData)^[0] shl 24) or
        (PRNLUInt8Array(aInData)^[1] shl 16) or
        (PRNLUInt8Array(aInData)^[2] shl 8) or
        (PRNLUInt8Array(aInData)^[3] shl 0);
  Position:=4;
  Range:=$ffffffff;
  for Value:=0 to SizeModels-1 do begin
   Model[Value]:=2048;
  end;
  LastOffset:=0;
  LastWasMatch:=false;
  Flag:=false;
  DestLen:=0;
  repeat
   if Flag then begin
    if (not LastWasMatch) and (DecodeBit(PreviousMatchModel,5)<>0) then begin
     if OK then begin
      Offset:=LastOffset;
      Len:=0;
     end else begin
      exit;
     end;
    end else begin
     Offset:=DecodeGamma(Gamma0Model);
     if OK then begin
      if Offset=0 then begin
       break;
      end else begin
       dec(Offset,2);
       Offset:=((Offset shl 4)+DecodeTree(MatchLowModel+((ord(Offset<>0) and 1) shl 4),16,5))+1;
       Len:=(ord(Offset>=96) and 1)+(ord(Offset>=2048) and 1);
      end;
     end else begin
      exit;
     end;
    end;
    LastOffset:=Offset;
    LastWasMatch:=true;
    inc(Len,DecodeGamma(Gamma1Model));
//  writeln('D: ',DestLen,' ',Len,' ',DestLen+Len);
    if (TRNLSizeUInt(DestLen+Len)<=TRNLSizeUInt(aOutLimit)) and
       (TRNLSizeUInt(Offset)<=TRNLSizeUInt(DestLen)) then begin
     RLELikeSideEffectAwareMemoryMove(PRNLUInt8Array(aOutData)^[DestLen-Offset],
                                      PRNLUInt8Array(aOutData)^[DestLen],
                                      Len);
     inc(DestLen,Len);
    end else begin
     exit;
    end;
   end else begin
    Value:=DecodeTree(LiteralModel,256,4);
    if OK and (TRNLSizeUInt(DestLen)<TRNLSizeUInt(aOutLimit)) then begin
     PRNLUInt8Array(aOutData)^[DestLen]:=Value;
     inc(DestLen);
     LastWasMatch:=false;
    end else begin
     exit;
    end;
   end;
   Flag:=boolean(byte(DecodeBit(FlagModel+TRNLUInt8(ord(LastWasMatch) and 1),5)));
  until false;
  result:=DestLen;
 end;
end;

constructor TRNLCompressorBRRC.Create;
begin
 inherited Create;
end;

destructor TRNLCompressorBRRC.Destroy;
begin
 inherited Destroy;
end;

function TRNLCompressorBRRC.Compress(const aInData:TRNLPointer;const aInSize:TRNLSizeUInt;const aOutData:TRNLPointer;const aOutLimit:TRNLSizeUInt):TRNLSizeUInt;
var {$ifndef CPU64}Code,{$endif}Range,Cache,CountFFBytes:TRNLUInt32;
    {$ifdef CPU64}Code:TRNLUInt64;{$endif}
    Model:array[0..SizeModels-1] of TRNLUInt32;
    OK,FirstByte{$ifndef CPU64},Carry{$endif}:boolean;
    DestLen:TRNLInt32;
 procedure EncoderShift;
{$ifdef CPU64}
 var Carry:boolean;
{$endif}
 begin
{$ifdef CPU64}
  Carry:=PRNLUInt64Record(TRNLPointer(@Code))^.Hi<>0; // or (Code shr 32)<>0; or also (Code and TRNLUInt64($ffffffff00000000))<>0;
{$endif}
  if (Code<$ff000000) or Carry then begin
   if FirstByte then begin
    FirstByte:=false;
   end else begin
    if TRNLSizeUInt(DestLen)<TRNLSizeUInt(aOutLimit) then begin
     PRNLUInt8Array(aOutData)^[DestLen]:=Cache+TRNLUInt8(ord(Carry) and 1);
     inc(DestLen);
    end else begin
     OK:=false;
     exit;
    end;
   end;
   while CountFFBytes<>0 do begin
    dec(CountFFBytes);
    if TRNLSizeUInt(DestLen)<TRNLSizeUInt(aOutLimit) then begin
     PRNLUInt8Array(aOutData)^[DestLen]:=$ff+TRNLUInt8(ord(Carry) and 1);
     inc(DestLen);
    end else begin
     OK:=false;
     exit;
    end;
   end;
   Cache:=(Code shr 24) and $ff;
  end else begin
   inc(CountFFBytes);
  end;
  Code:=(Code shl 8){$ifdef CPU64}and TRNLUInt32($ffffffff){$endif};
  Carry:=false;
 end;
 function EncodeBit(ModelIndex,Move,Bit:TRNLInt32):TRNLInt32;
 var Bound{$ifndef CPU64},OldCode{$endif}:TRNLUInt32;
 begin
  Bound:=(Range shr 12)*Model[ModelIndex];
  if Bit=0 then begin
   Range:=Bound;
   inc(Model[ModelIndex],(4096-Model[ModelIndex]) shr Move);
  end else begin
{$ifndef CPU64}
   OldCode:=Code;
{$endif}
   inc(Code,Bound);
{$ifndef CPU64}
   Carry:=Carry or (Code<OldCode);
{$endif}
   dec(Range,Bound);
   dec(Model[ModelIndex],Model[ModelIndex] shr Move);
  end;
  while Range<$1000000 do begin
   Range:=Range shl 8;
   EncoderShift;
  end;
  result:=Bit;
 end;
 procedure EncoderFlush;
 var Counter:TRNLInt32;
 begin
  for Counter:=1 to 5 do begin
   EncoderShift;
  end;
 end;
 procedure EncodeTree(ModelIndex,Bits,Move,Value:TRNLInt32);
 var Context:TRNLInt32;
 begin
  Context:=1;
  while Bits>0 do begin
   dec(Bits);
   Context:=(Context shl 1) or EncodeBit(ModelIndex+Context,Move,(Value shr Bits) and 1);
  end;
 end;
var CurrentPointer,EndPointer:PRNLUInt8;
    Len,MinDestLen:TRNLInt32;
begin
 DestLen:=0;
 FirstByte:=true;
 OK:=true;
 CountFFBytes:=0;
 Range:=$ffffffff;
 Code:=0;
 for Len:=0 to SizeModels-1 do begin
  Model[Len]:=2048;
 end;
 CurrentPointer:=aInData;
 EndPointer:={%H-}TRNLPointer(TRNLPtrUInt(TRNLPtrUInt(CurrentPointer)+TRNLPtrUInt(aInSize)));
 while {%H-}TRNLPtrUInt(CurrentPointer)<{%H-}TRNLPtrUInt(EndPointer) do begin
  EncodeBit(FlagModel,1,1);
  EncodeTree(LiteralModel,8,4,PRNLUInt8(CurrentPointer)^);
  if not OK then begin
   break;
  end;
  inc(CurrentPointer);
 end;
 EncodeBit(FlagModel,1,0);
 MinDestLen:=Max(2,DestLen+1);
 EncoderFlush;
 if OK then begin
  while (DestLen>MinDestLen) and (PRNLUInt8Array(aOutData)^[DestLen-1]=0) do begin
   dec(DestLen);
  end;
  result:=DestLen;
 end else begin
  result:=0;
 end;
end;

function TRNLCompressorBRRC.Decompress(const aInData:TRNLPointer;const aInSize:TRNLSizeUInt;const aOutData:TRNLPointer;const aOutLimit:TRNLSizeUInt):TRNLSizeUInt;
var Code,Range,Position:TRNLUInt32;
    Model:array[0..SizeModels-1] of TRNLUInt32;
    OK:boolean;
 function DecodeBit(ModelIndex,Move:TRNLInt32):TRNLInt32;
 var Bound:TRNLUInt32;
 begin
  Bound:=(Range shr 12)*Model[ModelIndex];
  if Code<Bound then begin
   Range:=Bound;
   inc(Model[ModelIndex],(4096-Model[ModelIndex]) shr Move);
   result:=0;
  end else begin
   dec(Code,Bound);
   dec(Range,Bound);
   dec(Model[ModelIndex],Model[ModelIndex] shr Move);
   result:=1;
  end;
  while Range<$1000000 do begin
   if Position<aInSize then begin
    Code:=(Code shl 8) or PRNLUInt8Array(aInData)^[Position];
   end else begin
    if Position<(aInSize+4+5) then begin
     Code:=Code shl 8;
    end else begin
     OK:=false;
     break;
    end;
   end;
   inc(Position);
   Range:=Range shl 8;
  end;
 end;
 function DecodeTree(ModelIndex,MaxValue,Move:TRNLInt32):TRNLInt32;
 begin
  result:=1;
  while OK and (result<MaxValue) do begin
   result:=(result shl 1) or DecodeBit(ModelIndex+result,Move);
  end;
  dec(result,MaxValue);
 end;
var DestLen,Value:TRNLInt32;
begin
 result:=0;
 if aInSize>=3 then begin
  OK:=true;
  Code:=(PRNLUInt8Array(aInData)^[0] shl 24) or
        (PRNLUInt8Array(aInData)^[1] shl 16) or
        (PRNLUInt8Array(aInData)^[2] shl 8) or
        (PRNLUInt8Array(aInData)^[3] shl 0);
  Position:=4;
  Range:=$ffffffff;
  for Value:=0 to SizeModels-1 do begin
   Model[Value]:=2048;
  end;
  DestLen:=0;
  repeat
   Value:=DecodeBit(FlagModel,1);
   if OK then begin
    if Value<>0 then begin
     Value:=DecodeTree(LiteralModel,256,4);
     if OK and (TRNLSizeUInt(DestLen)<TRNLSizeUInt(aOutLimit)) then begin
      PRNLUInt8Array(aOutData)^[DestLen]:=Value;
      inc(DestLen);
     end else begin
      exit;
     end;
    end else begin
     break;
    end;
   end else begin
    exit;
   end;
  until false;
  result:=DestLen;
 end;
end;

constructor TRNLPeerPendingConnectionHandshakeSendData.Create(const aPeer:TRNLPeer);
begin
 fPeer:=aPeer;
 FillChar(fHandshakePacket,SizeOf(TRNLProtocolHandshakePacket),#0);
end;

function TRNLPeerPendingConnectionHandshakeSendData.Send:boolean;
var PacketSize:TRNLSizeInt;
begin
 fPeer.fHost.AddHandshakePacketChecksum(fHandshakePacket);
 PacketSize:=RNLProtocolHandshakePacketSizes[TRNLProtocolHandshakePacketType(TRNLInt32(fHandshakePacket.Header.PacketType))];
 result:=(PacketSize>0) and (fPeer.SendPacket(fHandshakePacket,PacketSize)<>RNL_NETWORK_SEND_RESULT_ERROR);
end;

constructor TRNLPeerBlockPacket.Create(const aPeer:TRNLPeer);
begin
 inherited Create;
 fPeer:=aPeer;
 fValue:=self;
 fChannel:=$ff;
 fSequenceNumber:=0;
 fCountSendAttempts:=0;
 fRoundTripTimeout:=0;
 fRoundTripTimeoutLimit:=0;
 fSentTime:=0;
 fReceivedTime:=0;
 fBlockPacketData:=nil;
 fBlockPacketDataLength:=0;
 fReferenceCounter:=1;
 fPendingResendOutgoingBlockPacketsList:=nil;
end;

destructor TRNLPeerBlockPacket.Destroy;
begin
 fBlockPacketData:=nil;
 inherited Destroy;
end;

procedure TRNLPeerBlockPacket.IncRef;
begin
 {$ifdef fpc}InterlockedIncrement{$else}AtomicIncrement{$endif}(TRNLInt32(fReferenceCounter));
end;

procedure TRNLPeerBlockPacket.DecRef;
begin
 if assigned(self) and
    ({$ifdef fpc}InterlockedDecrement{$else}AtomicDecrement{$endif}(TRNLInt32(fReferenceCounter))=0) then begin
  Free;
 end;
end;

procedure TRNLPeerBlockPacket.Clear;
begin
 if self<>fNext then begin
  Remove;
 end;
 fChannel:=$ff;
 fSequenceNumber:=0;
 fCountSendAttempts:=0;
 fRoundTripTimeout:=0;
 fRoundTripTimeoutLimit:=0;
 fSentTime:=0;
 fReceivedTime:=0;
 fBlockPacketDataLength:=0;
 fPendingResendOutgoingBlockPacketsList:=nil;
end;

function TRNLPeerBlockPacket.GetPointerToBlockPacket:PRNLProtocolBlockPacket;
begin
 result:=@fBlockPacket;
end;

function TRNLPeerBlockPacket.GetSize:TRNLSizeUInt;
begin
 result:=RNLProtocolBlockPacketSizes[TRNLProtocolBlockPacketType(TRNLInt32(fBlockPacket.Header.TypeAndSubtype and $f))]+
         fBlockPacketDataLength;
end;

function TRNLPeerBlockPacket.AppendTo(var aOutgoingPacketBuffer:TRNLOutgoingPacketBuffer):boolean;
begin
 aOutgoingPacketBuffer.Write(fBlockPacket,RNLProtocolBlockPacketSizes[TRNLProtocolBlockPacketType(TRNLInt32(fBlockPacket.Header.TypeAndSubtype and $f))]);
 if fBlockPacketDataLength>0 then begin
  aOutgoingPacketBuffer.Write(fBlockPacketData[0],fBlockPacketDataLength);
 end;
 result:=true;
end;

constructor TRNLPeerChannel.Create(const aPeer:TRNLPeer;const aChannelNumber:TRNLUInt16);
begin
 inherited Create;

 fPeer:=aPeer;

 fHost:=fPeer.fHost;

 fChannelNumber:=aChannelNumber;

 fIncomingMessageQueue:=TRNLMessageQueue.Create;

 fOutgoingMessageQueue:=TRNLMessageQueue.Create;

end;

destructor TRNLPeerChannel.Destroy;
var Message:TRNLMessage;
begin

 while fIncomingMessageQueue.Dequeue(Message) do begin
  Message.DecRef;
 end;

 while fOutgoingMessageQueue.Dequeue(Message) do begin
  Message.DecRef;
 end;

 fIncomingMessageQueue.Free;

 fOutgoingMessageQueue.Free;

 inherited Destroy;
end;

procedure TRNLPeerChannel.DispatchOutgoingBlockPackets;
begin
end;

procedure TRNLPeerChannel.DispatchIncomingBlockPacket(const aBlockPacket:TRNLPeerBlockPacket);
begin
end;

procedure TRNLPeerChannel.DispatchIncomingMessages;
var Message:TRNLMessage;
    HostEvent:TRNLHostEvent;
begin
 while fIncomingMessageQueue.Dequeue(Message) do begin
  if assigned(fHost.fOnPeerReceive) then begin
   try
    fHost.fOnPeerReceive(fHost,fPeer,fChannelNumber,Message);
   finally
    Message.DecRef;
   end;
  end else begin
   HostEvent.Initialize;
   try
    HostEvent.Type_:=RNL_HOST_EVENT_TYPE_PEER_RECEIVE;
    HostEvent.Peer:=fPeer;
    HostEvent.Peer.IncRef;
    HostEvent.Channel:=fChannelNumber;
    HostEvent.Message:=Message;
   finally
    fHost.fEventQueue.Enqueue(HostEvent);
   end;
  end;
 end;
end;

function TRNLPeerChannel.GetMaximumUnfragmentedMessageSize:TRNLSizeUInt;
begin
 result:=fPeer.fMTU-(RNL_IP_HEADER_SIZE+
                     RNL_UDP_HEADER_SIZE+
                     SizeOf(TRNLProtocolNormalPacketHeader)+
                     SizeOf(TRNLProtocolBlockPacketChannel));
end;

procedure TRNLPeerChannel.SendMessage(const aMessage:TRNLMessage);
begin
 try
  aMessage.IncRef;
 finally
  fOutgoingMessageQueue.Enqueue(aMessage);
 end;
end;

procedure TRNLPeerChannel.SendMessageData(const aData:TRNLPointer;const aDataLength:TRNLUInt32;const aFlags:TRNLMessageFlags=[]);
var Message:TRNLMessage;
begin
 Message:=TRNLMessage.CreateFromMemory(aData,aDataLength,aFlags);
 try
  SendMessage(Message);
 finally
  Message.DecRef;
 end;
end;

procedure TRNLPeerChannel.SendMessageBytes(const aBytes:TBytes;const aFlags:TRNLMessageFlags=[]);
var Message:TRNLMessage;
begin
 Message:=TRNLMessage.CreateFromBytes(aBytes,aFlags);
 try
  SendMessage(Message);
 finally
  Message.DecRef;
 end;
end;

procedure TRNLPeerChannel.SendMessageBytes(const aBytes:array of TRNLUInt8;const aFlags:TRNLMessageFlags=[]);
var Message:TRNLMessage;
begin
 Message:=TRNLMessage.CreateFromBytes(aBytes,aFlags);
 try
  SendMessage(Message);
 finally
  Message.DecRef;
 end;
end;

procedure TRNLPeerChannel.SendMessageRawByteString(const aString:TRNLRawByteString;const aFlags:TRNLMessageFlags=[]);
var Message:TRNLMessage;
begin
 Message:=TRNLMessage.CreateFromRawByteString(aString,aFlags);
 try
  SendMessage(Message);
 finally
  Message.DecRef;
 end;
end;

procedure TRNLPeerChannel.SendMessageUTF8String(const aString:TRNLUTF8String;const aFlags:TRNLMessageFlags=[]);
var Message:TRNLMessage;
begin
 Message:=TRNLMessage.CreateFromUTF8String(aString,aFlags);
 try
  SendMessage(Message);
 finally
  Message.DecRef;
 end;
end;

procedure TRNLPeerChannel.SendMessageUTF16String(const aString:TRNLUTF16String;const aFlags:TRNLMessageFlags=[]);
var Message:TRNLMessage;
begin
 Message:=TRNLMessage.CreateFromUTF16String(aString,aFlags);
 try
  SendMessage(Message);
 finally
  Message.DecRef;
 end;
end;

procedure TRNLPeerChannel.SendMessageString(const aString:TRNLString;const aFlags:TRNLMessageFlags=[]);
var Message:TRNLMessage;
begin
 Message:=TRNLMessage.CreateFromString(aString,aFlags);
 try
  SendMessage(Message);
 finally
  Message.DecRef;
 end;
end;

procedure TRNLPeerChannel.SendMessageStream(const aStream:TStream;const aFlags:TRNLMessageFlags=[]);
var Message:TRNLMessage;
begin
 Message:=TRNLMessage.CreateFromStream(aStream,aFlags);
 try
  SendMessage(Message);
 finally
  Message.DecRef;
 end;
end;

constructor TRNLPeerReliableChannel.Create(const aPeer:TRNLPeer;const aChannelNumber:TRNLUInt16);
begin

 inherited Create(aPeer,aChannelNumber);

 fOrdered:=true;

 fIncomingBlockPackets:=nil;
 SetLength(fIncomingBlockPackets,fHost.fReliableChannelBlockPacketWindowSize);
 FillChar(fIncomingBlockPackets[0],fHost.fReliableChannelBlockPacketWindowSize*SizeOf(TRNLPeerBlockPacket),#0);
 fIncomingBlockPacketSequenceNumber:=0;

 fIncomingAcknowledgements:=nil;
 SetLength(fIncomingAcknowledgements,fHost.fReliableChannelBlockPacketWindowSize);
 FillChar(fIncomingAcknowledgements[0],fHost.fReliableChannelBlockPacketWindowSize*SizeOf(TRNLInt32),#$ff);
 fIncomingAcknowledgementSequenceNumber:=0;

 fOutgoingBlockPackets:=nil;
 SetLength(fOutgoingBlockPackets,fHost.fReliableChannelBlockPacketWindowSize);
 FillChar(fOutgoingBlockPackets[0],fHost.fReliableChannelBlockPacketWindowSize*SizeOf(TRNLPeerBlockPacket),#0);
 fOutgoingBlockPacketSequenceNumber:=0;

 fOutgoingAcknowledgementQueue:=TRNLSequenceNumberQueue.Create;

 fOutgoingAcknowledgementArray:=nil;
 SetLength(fOutgoingAcknowledgementArray,fHost.fReliableChannelBlockPacketWindowSize);

 fOutgoingAcknowledgementData:=nil;

 fOutgoingBlockPacketQueue:=TRNLPeerBlockPacketQueue.Create;

 fSentOutgoingBlockPackets:=TRNLPeerBlockPacketCircularDoublyLinkedListNode.Create;

end;

destructor TRNLPeerReliableChannel.Destroy;
var BlockPacket:TRNLPeerBlockPacket;
begin

 for BlockPacket in fIncomingBlockPackets do begin
  BlockPacket.DecRef;
 end;
 fIncomingBlockPackets:=nil;

 for BlockPacket in fOutgoingBlockPackets do begin
  BlockPacket.DecRef;
 end;
 fOutgoingBlockPackets:=nil;

 fIncomingAcknowledgements:=nil;

 FreeAndNil(fOutgoingAcknowledgementQueue);

 fOutgoingAcknowledgementArray:=nil;

 fOutgoingAcknowledgementData:=nil;

 while fOutgoingBlockPacketQueue.Dequeue(BlockPacket) do begin
  BlockPacket.DecRef;
 end;
 FreeAndNil(fOutgoingBlockPacketQueue);

 while not fSentOutgoingBlockPackets.IsEmpty do begin
  fSentOutgoingBlockPackets.Front.Value.DecRef;
 end;
 FreeAndNil(fSentOutgoingBlockPackets);

 inherited Destroy;

end;

function TRNLPeerReliableChannel.GetMaximumUnfragmentedMessageSize:TRNLSizeUInt;
begin
 result:=fPeer.fMTU-(RNL_IP_HEADER_SIZE+
                     RNL_UDP_HEADER_SIZE+
                     SizeOf(TRNLProtocolNormalPacketHeader)+
                     SizeOf(TRNLProtocolBlockPacketChannel)+
                     SizeOf(TRNLPeerReliableChannelShortMessagePacketHeader));
end;

procedure TRNLPeerReliableChannel.DispatchOutgoingBlockPacketsTimeout;
var CurrentBlockPacketListNode,
    NextBlockPacketListNode:TRNLPeerBlockPacketCircularDoublyLinkedListNode;
    BlockPacket:TRNLPeerBlockPacket;
begin

 CurrentBlockPacketListNode:=fSentOutgoingBlockPackets.Front;
 while CurrentBlockPacketListNode<>fSentOutgoingBlockPackets do begin

  NextBlockPacketListNode:=CurrentBlockPacketListNode.Next;

  BlockPacket:=CurrentBlockPacketListNode.fValue;

  if TRNLTime.Difference(fHost.fTime,BlockPacket.fSentTime)>=BlockPacket.fRoundTripTimeout then begin

   inc(fPeer.fCountPacketLoss);

   inc(BlockPacket.fRoundTripTimeout,BlockPacket.fRoundTripTimeout);

   if BlockPacket.fRoundTripTimeout>BlockPacket.fRoundTripTimeoutLimit then begin
    BlockPacket.fRoundTripTimeout:=BlockPacket.fRoundTripTimeoutLimit;
   end;

   BlockPacket.Remove;

   BlockPacket.fPendingResendOutgoingBlockPacketsList:=fSentOutgoingBlockPackets;

   fPeer.fOutgoingBlockPackets.EnqueueAtFront(BlockPacket);

  end;

  CurrentBlockPacketListNode:=NextBlockPacketListNode;

 end;

end;

function TRNLPeerReliableChannelSortOutgoingAcknowledgementSequenceNumbers(const a,b:TRNLSequenceNumber):TRNLInt32;
begin
 result:=TRNLSequenceNumber.RelativeDifference(a,b);
end;

procedure TRNLPeerReliableChannel.DispatchOutgoingAcknowledgementBlockPackets;
var CountAcknowledgements,AcknowledgementIndex:TRNLSizeInt;
    MaximumAcknowledgementBits,AcknowledgementDataLength,AcknowledgementDataPosition:TRNLSizeUInt;
    BlockPacketSequenceNumber,StartSequenceNumber:TRNLSequenceNumber;
    AcknowledgmentBitIndex:TRNLInt32;
    BlockPacket:TRNLPeerBlockPacket;
    AcknowledgementPacketHeader:PRNLPeerReliableChannelAcknowledgementPacketHeader;
    AcknowledgementsPacketHeader:PRNLPeerReliableChannelAcknowledgementsPacketHeader;
    DoNeedSort:boolean;
begin

 // Dispatch outgoing enqueued incoming acknowledgements to outgoing acknowledgement(s) block packets

 MaximumAcknowledgementBits:=(fPeer.fMTU-(RNL_IP_HEADER_SIZE+
                                          RNL_UDP_HEADER_SIZE+
                                          SizeOf(TRNLProtocolNormalPacketHeader)+
                                          SizeOf(TRNLProtocolBlockPacketChannel)+
                                          SizeOf(TRNLPeerReliableChannelAcknowledgementPacketHeader))) shl 3;

{while fOutgoingAcknowledgementQueue.Dequeue(BlockPacketSequenceNumber) do begin

  BlockPacket:=TRNLPeerBlockPacket.Create(fPeer);
  try

   BlockPacket.fBlockPacket.Channel.Header.TypeAndSubtype:=(TRNLInt32(TRNLProtocolBlockPacketType(RNL_PROTOCOL_BLOCK_PACKET_TYPE_CHANNEL)) shl 0) or
                                                           (TRNLInt32(TRNLPeerReliableChannelCommandType(RNL_PEER_RELIABLE_CHANNEL_COMMAND_TYPE_ACKNOWLEDGEMENT)) shl 4);
   BlockPacket.fBlockPacket.Channel.ChannelNumber:=fChannelNumber;
   BlockPacket.fBlockPacket.Channel.PayloadDataLength:=TRNLEndianness.HostToLittleEndian16(SizeOf(TRNLPeerReliableChannelAcknowledgementPacketHeader));

   BlockPacket.fBlockPacketDataLength:=SizeOf(TRNLPeerReliableChannelAcknowledgementPacketHeader);

   SetLength(BlockPacket.fBlockPacketData,BlockPacket.fBlockPacketDataLength);

   AcknowledgementPacketHeader:=TRNLPointer(@BlockPacket.fBlockPacketData[0]);
   AcknowledgementPacketHeader^.Header.SequenceNumber:=TRNLEndianness.HostToLittleEndian16(BlockPacketSequenceNumber);

   BlockPacket.fPendingResendOutgoingBlockPacketsList:=nil; // No resend timeout

  finally
   fPeer.fOutgoingBlockPackets.Enqueue(BlockPacket);
  end;

 end;

 exit;//}

 DoNeedSort:=false;

 CountAcknowledgements:=0;
 while fOutgoingAcknowledgementQueue.Dequeue(BlockPacketSequenceNumber) and
       (CountAcknowledgements<length(fOutgoingAcknowledgementArray)) do begin
  DoNeedSort:=DoNeedSort or
              ((CountAcknowledgements>0) and
               (fOutgoingAcknowledgementArray[CountAcknowledgements-1]>BlockPacketSequenceNumber));
  fOutgoingAcknowledgementArray[CountAcknowledgements]:=BlockPacketSequenceNumber;
  inc(CountAcknowledgements);
 end;

 if CountAcknowledgements>0 then begin

  if (CountAcknowledgements>1) and DoNeedSort then begin
   TRNLTypedSort<TRNLSequenceNumber>.IntroSort(@fOutgoingAcknowledgementArray[0],0,CountAcknowledgements-1,TRNLPeerReliableChannelSortOutgoingAcknowledgementSequenceNumbers);
  end;

  AcknowledgementIndex:=0;
  while AcknowledgementIndex<CountAcknowledgements do begin

   StartSequenceNumber:=fOutgoingAcknowledgementArray[AcknowledgementIndex];

   AcknowledgementDataLength:=0;

   while AcknowledgementIndex<CountAcknowledgements do begin

    AcknowledgmentBitIndex:=TRNLSequenceNumber.RelativeDifference(fOutgoingAcknowledgementArray[AcknowledgementIndex],
                                                                  StartSequenceNumber);

    if AcknowledgmentBitIndex>=TRNLSizeInt(MaximumAcknowledgementBits) then begin
     break;
    end;

    AcknowledgementDataPosition:=AcknowledgmentBitIndex shr 3;

    if AcknowledgementDataLength<=AcknowledgementDataPosition then begin
     if TRNLSizeUInt(length(fOutgoingAcknowledgementData))<=AcknowledgementDataPosition then begin
      SetLength(fOutgoingAcknowledgementData,(AcknowledgementDataPosition+1)*2);
     end;
     FillChar(fOutgoingAcknowledgementData[AcknowledgementDataLength],
              (AcknowledgementDataPosition-AcknowledgementDataLength)+1,
              #0);
     AcknowledgementDataLength:=AcknowledgementDataPosition+1;
    end;

    fOutgoingAcknowledgementData[AcknowledgementDataPosition]:=fOutgoingAcknowledgementData[AcknowledgementDataPosition] or (TRNLUInt8(1) shl TRNLSizeUInt(AcknowledgmentBitIndex and 7));

    inc(AcknowledgementIndex);
   end;

   if (AcknowledgementDataLength=1) and (fOutgoingAcknowledgementData[0]=1) then begin

    BlockPacket:=TRNLPeerBlockPacket.Create(fPeer);
    try

     BlockPacket.fBlockPacket.Channel.Header.TypeAndSubtype:=(TRNLInt32(TRNLProtocolBlockPacketType(RNL_PROTOCOL_BLOCK_PACKET_TYPE_CHANNEL)) shl 0) or
                                                             (TRNLInt32(TRNLPeerReliableChannelCommandType(RNL_PEER_RELIABLE_CHANNEL_COMMAND_TYPE_ACKNOWLEDGEMENT)) shl 4);
     BlockPacket.fBlockPacket.Channel.ChannelNumber:=fChannelNumber;
     BlockPacket.fBlockPacket.Channel.PayloadDataLength:=TRNLEndianness.HostToLittleEndian16(SizeOf(TRNLPeerReliableChannelAcknowledgementPacketHeader));

     BlockPacket.fBlockPacketDataLength:=SizeOf(TRNLPeerReliableChannelAcknowledgementPacketHeader);

     SetLength(BlockPacket.fBlockPacketData,BlockPacket.fBlockPacketDataLength);

     AcknowledgementPacketHeader:=TRNLPointer(@BlockPacket.fBlockPacketData[0]);
     AcknowledgementPacketHeader^.Header.SequenceNumber:=TRNLEndianness.HostToLittleEndian16(StartSequenceNumber);

     BlockPacket.fPendingResendOutgoingBlockPacketsList:=nil; // No resend timeout

    finally
     fPeer.fOutgoingBlockPackets.Enqueue(BlockPacket);
    end;

   end else if AcknowledgementDataLength>0 then begin

    BlockPacket:=TRNLPeerBlockPacket.Create(fPeer);
    try

     BlockPacket.fBlockPacket.Channel.Header.TypeAndSubtype:=(TRNLInt32(TRNLProtocolBlockPacketType(RNL_PROTOCOL_BLOCK_PACKET_TYPE_CHANNEL)) shl 0) or
                                                             (TRNLInt32(TRNLPeerReliableChannelCommandType(RNL_PEER_RELIABLE_CHANNEL_COMMAND_TYPE_ACKNOWLEDGEMENTS)) shl 4);
     BlockPacket.fBlockPacket.Channel.ChannelNumber:=fChannelNumber;
     BlockPacket.fBlockPacket.Channel.PayloadDataLength:=TRNLEndianness.HostToLittleEndian16(SizeOf(TRNLPeerReliableChannelAcknowledgementsPacketHeader)+AcknowledgementDataLength);

     BlockPacket.fBlockPacketDataLength:=SizeOf(TRNLPeerReliableChannelAcknowledgementsPacketHeader)+AcknowledgementDataLength;

     SetLength(BlockPacket.fBlockPacketData,BlockPacket.fBlockPacketDataLength);

     AcknowledgementsPacketHeader:=TRNLPointer(@BlockPacket.fBlockPacketData[0]);
     AcknowledgementsPacketHeader^.Header.SequenceNumber:=TRNLEndianness.HostToLittleEndian16(StartSequenceNumber);

     Move(fOutgoingAcknowledgementData[0],
          BlockPacket.fBlockPacketData[SizeOf(TRNLPeerReliableChannelAcknowledgementsPacketHeader)],
          AcknowledgementDataLength);

     BlockPacket.fPendingResendOutgoingBlockPacketsList:=nil; // No resend timeout

    finally
     fPeer.fOutgoingBlockPackets.Enqueue(BlockPacket);
    end;

   end;

  end;

 end;

end;

procedure TRNLPeerReliableChannel.DispatchOutgoingBlockPackets;
var SequenceNumberDifference,MaxPacketsToMove,Index:TRNLSizeUInt;
    BlockPacket:TRNLPeerBlockPacket;
    IndirectBlockPacket:PRNLPeerBlockPacket;
begin

 DispatchOutgoingBlockPacketsTimeout;

 DispatchOutgoingAcknowledgementBlockPackets;

 DispatchOutgoingMessageBlockPackets;

 // Move local enqueued outgoing block packets into the peer global outgoing block packet queue
 // as much as possible in a single straight row.
 // This intermediate step is necessary in order to be able to keep the acknowledgement and
 // sent window sizes, so that the receiver side will not be spammed with too much
 // window-size-technical-early packets.

 // Compute the difference between outgoing and incoming sequence numbers
 // SequenceNumberDifference:=((fOutgoingBlockPacketSequenceNumber.fValue+fHost.fReliableChannelBlockPacketWindowSize)-fIncomingAcknowledgementSequenceNumber.fValue) and fHost.fReliableChannelBlockPacketWindowMask;
 SequenceNumberDifference:=TRNLSequenceNumber.Difference(fOutgoingBlockPacketSequenceNumber,fIncomingAcknowledgementSequenceNumber);

 if SequenceNumberDifference<fHost.fReliableChannelBlockPacketWindowSize then begin

  // Compute the maximum allowed number of packets that can be moved in this iteration
  MaxPacketsToMove:=fHost.fReliableChannelBlockPacketWindowSize-SequenceNumberDifference;

  for Index:=1 to MaxPacketsToMove do begin

   IndirectBlockPacket:=@fOutgoingBlockPackets[fOutgoingBlockPacketSequenceNumber.fValue and fHost.fReliableChannelBlockPacketWindowMask];

   // Move the block packet from the local window to the global queue if it has not yet been allocated
   if (not assigned(IndirectBlockPacket^)) and
      fOutgoingBlockPacketQueue.Peek(BlockPacket) and
      (TRNLUInt16(BlockPacket.fSequenceNumber)=fOutgoingBlockPacketSequenceNumber) then begin

    try

     // Insert into the global queue
     IndirectBlockPacket^:=BlockPacket;
     BlockPacket.fPendingResendOutgoingBlockPacketsList:=fSentOutgoingBlockPackets;
     fPeer.fOutgoingBlockPackets.Enqueue(BlockPacket);

    finally

     // Remove the package from the local queue
     fOutgoingBlockPacketQueue.Dequeue;

    end;

    inc(fOutgoingBlockPacketSequenceNumber);

   end else begin

    // End the loop if the packet is outside the valid sequence number range
    break;

   end;

  end;

 end;

end;

procedure TRNLPeerReliableChannel.DispatchIncomingBlockPacketAcknowledgement(const aBlockPacketSequenceNumber:TRNLSequenceNumber;const aBlockPacketReceivedTime:TRNLTime);
var IndirectBlockPacket:PRNLPeerBlockPacket;
    Acknowledgement:PRNLPeerReliableChannelAcknowledgement;
begin

 if (aBlockPacketSequenceNumber>=fIncomingAcknowledgementSequenceNumber) and
    (aBlockPacketSequenceNumber<=fOutgoingBlockPacketSequenceNumber) then begin

  // Dispatch received block packet acknowledgement
  if fIncomingAcknowledgements[aBlockPacketSequenceNumber.fValue and fHost.fReliableChannelBlockPacketWindowMask]<0 then begin
   IndirectBlockPacket:=@fOutgoingBlockPackets[aBlockPacketSequenceNumber.fValue and fHost.fReliableChannelBlockPacketWindowMask];
   if assigned(IndirectBlockPacket^) and
      (IndirectBlockPacket^.fSequenceNumber.fValue=aBlockPacketSequenceNumber.fValue) then begin
    try
     fIncomingAcknowledgements[aBlockPacketSequenceNumber.fValue and fHost.fReliableChannelBlockPacketWindowMask]:=aBlockPacketSequenceNumber.fValue;
     fPeer.UpdateRoundTripTime(abs(TRNLInt16(TRNLUInt16(aBlockPacketReceivedTime.fValue-IndirectBlockPacket^.fSentTime.fValue))));
     dec(fPeer.fUnacknowlegmentedBlockPackets);
     IndirectBlockPacket^.Remove;
    finally
     IndirectBlockPacket^.DecRef;
     IndirectBlockPacket^:=nil;
    end;
   end;
  end;

  // Catch up so many received block packet acknowledgement sequence numbers as much as possible in a single straight row
  repeat
   Acknowledgement:=@fIncomingAcknowledgements[fIncomingAcknowledgementSequenceNumber.fValue and fHost.fReliableChannelBlockPacketWindowMask];
   if Acknowledgement^=fIncomingAcknowledgementSequenceNumber.fValue then begin
    Acknowledgement^:=-1;
    inc(fIncomingAcknowledgementSequenceNumber.fValue);
   end else begin
    break;
   end;
  until false;

//writeln('ACK: ',aBlockPacketSequenceNumber.fValue,' ',fIncomingAcknowledgementSequenceNumber.fValue);

 end;

end;

procedure TRNLPeerReliableChannel.DispatchIncomingAcknowledgementsBlockPacket(const aBlockPacket:TRNLPeerBlockPacket);
var BlockPacketDataPosition,AcknowledgementBits,AcknowledgementBitIndex:TRNLSizeUInt;
    BlockPacketSequenceNumber:TRNLSequenceNumber;
begin
 BlockPacketSequenceNumber:=TRNLEndianness.LittleEndianToHost16(PRNLPeerReliableChannelPacketHeader(TRNLPointer(@aBlockPacket.fBlockPacketData[0]))^.SequenceNumber);
 BlockPacketDataPosition:=SizeOf(TRNLPeerReliableChannelAcknowledgementsPacketHeader);
 while BlockPacketDataPosition<aBlockPacket.fBlockPacketDataLength do begin
  AcknowledgementBits:=aBlockPacket.fBlockPacketData[BlockPacketDataPosition];
  while AcknowledgementBits<>0 do begin
   AcknowledgementBitIndex:={$ifdef fpc}BSFDWord{$else}RawBitScanForwardUInt32{$endif}(AcknowledgementBits);
   DispatchIncomingBlockPacketAcknowledgement(BlockPacketSequenceNumber+AcknowledgementBitIndex,aBlockPacket.fReceivedTime);
   AcknowledgementBits:=AcknowledgementBits and (AcknowledgementBits-1);
  end;
  inc(BlockPacketSequenceNumber.fValue,8);
  inc(BlockPacketDataPosition);
 end;
end;

procedure TRNLPeerReliableChannel.DispatchIncomingBlockPacket(const aBlockPacket:TRNLPeerBlockPacket);
var BlockPacketDataPosition:TRNLSizeUInt;
    BlockPacketSequenceNumber:TRNLSequenceNumber;
    RelativeSequenceNumber:TRNLInt32;
    PacketHeader:PRNLPeerReliableChannelPacketHeader;
    IndirectBlockPacket:PRNLPeerBlockPacket;
    ChannelCommandType:TRNLPeerReliableChannelCommandType;
begin

 BlockPacketDataPosition:=0;

 if (BlockPacketDataPosition+(SizeOf(TRNLPeerReliableChannelPacketHeader)-1))>=aBlockPacket.fBlockPacketDataLength then begin
  exit;
 end;

 PacketHeader:=TRNLPointer(@aBlockPacket.fBlockPacketData[BlockPacketDataPosition]);

 BlockPacketSequenceNumber:=TRNLEndianness.LittleEndianToHost16(PacketHeader^.SequenceNumber);

 ChannelCommandType:=TRNLPeerReliableChannelCommandType(TRNLInt32(aBlockPacket.fBlockPacket.Channel.Header.TypeAndSubtype shr 4));

// writeln(GetCurrentThreadId,' K ',BlockPacketSequenceNumber.fValue,' ',fIncomingBlockPacketSequenceNumber.fValue);

 case ChannelCommandType of
  RNL_PEER_RELIABLE_CHANNEL_COMMAND_TYPE_SHORT_MESSAGE,
  RNL_PEER_RELIABLE_CHANNEL_COMMAND_TYPE_LONG_MESSAGE:begin

   // if < 0 then it's too late arrived or a duplicate packet => drop but send an acknowledgment
   // if = 0 then it's arrived in time => accept and send an acknowledgment
   // if > 0 and < WindowSize then it's too early, but not much too early arrived => accept with withheld for later and send an acknowledgment also already
   // if >= WindowSize then it's much too early arrived => drop and NOT send an acknowledgment, so the sender can send it again at a better time point, even if the sender can be missing-acknowledgment-resend-spamming us then in this case
   RelativeSequenceNumber:=TRNLSequenceNumber.RelativeDifference(BlockPacketSequenceNumber,
                                                                 fIncomingBlockPacketSequenceNumber);

   if RelativeSequenceNumber<TRNLSizeInt(fHost.fReliableChannelBlockPacketWindowSize) then begin

    if RelativeSequenceNumber>=0 then begin

     // Enqueue (and, if not ordered channel, dispatch) received block packet
     IndirectBlockPacket:=@fIncomingBlockPackets[BlockPacketSequenceNumber.fValue and fHost.fReliableChannelBlockPacketWindowMask];
     try
      if assigned(IndirectBlockPacket^) then begin
       try
        IndirectBlockPacket^.DecRef;
       finally
        IndirectBlockPacket^:=nil;
       end;
      end;
      aBlockPacket.fSequenceNumber:=BlockPacketSequenceNumber;
      IndirectBlockPacket^:=aBlockPacket;
      if not fOrdered then begin
       DispatchIncomingMessageBlockPacket(aBlockPacket);
       aBlockPacket.fBlockPacketData:=nil; // The actual block packet payload data are no more needed
       aBlockPacket.fBlockPacketDataLength:=0;
      end;
     finally
      IndirectBlockPacket^.IncRef;
     end;

     // Dequeue (and, if ordered channel, dispatch) so many received block packets as much as possible in a single straight row
     repeat
      IndirectBlockPacket:=@fIncomingBlockPackets[fIncomingBlockPacketSequenceNumber.fValue and fHost.fReliableChannelBlockPacketWindowMask];
      if assigned(IndirectBlockPacket^) and (IndirectBlockPacket^.fSequenceNumber.fValue=fIncomingBlockPacketSequenceNumber.fValue) then begin
       try
        if fOrdered then begin
         DispatchIncomingMessageBlockPacket(IndirectBlockPacket^);
        end;
        inc(fIncomingBlockPacketSequenceNumber.fValue);
       finally
        IndirectBlockPacket^.DecRef;
        IndirectBlockPacket^:=nil;
       end;
      end else begin
       break;
      end;
     until false;

    end;

    // Queue outgoing acknowledgement if needed
    fOutgoingAcknowledgementQueue.Enqueue(BlockPacketSequenceNumber);

   end;

  end;

  RNL_PEER_RELIABLE_CHANNEL_COMMAND_TYPE_ACKNOWLEDGEMENT:begin

   DispatchIncomingBlockPacketAcknowledgement(BlockPacketSequenceNumber,aBlockPacket.fReceivedTime);

  end;

  RNL_PEER_RELIABLE_CHANNEL_COMMAND_TYPE_ACKNOWLEDGEMENTS:begin

   DispatchIncomingAcknowledgementsBlockPacket(aBlockPacket);

  end;

 end;

end;

constructor TRNLPeerReliableOrderedChannel.Create(const aPeer:TRNLPeer;const aChannelNumber:TRNLUInt16);
begin

 inherited Create(aPeer,aChannelNumber);

 fOrdered:=true;

 fOutgoingMessageBlockPacketSequenceNumber:=0;

 fOutgoingMessageNumber:=0;

 fIncomingMessageNumber:=$ffff;

 fIncomingMessageLength:=0;

 fIncomingMessageReceiveBufferData:=nil;

end;

destructor TRNLPeerReliableOrderedChannel.Destroy;
begin

 fIncomingMessageReceiveBufferData:=nil;

 inherited Destroy;

end;

procedure TRNLPeerReliableOrderedChannel.DispatchOutgoingMessageBlockPackets;
var Message:TRNLMessage;
    MaximumShortMessageBlockPacketSize,
    MaximumLongMessageBlockPacketSize,
    MessagePartLength,
    MessagePosition:TRNLSizeUInt;
    MaxPacketsToSend:TRNLSizeInt;
    BlockPacket:TRNLPeerBlockPacket;
    ShortMessagePacketHeader:PRNLPeerReliableChannelShortMessagePacketHeader;
    LongMessagePacketHeader:PRNLPeerReliableChannelLongMessagePacketHeader;
begin

 // Dispatch outgoing enqueued messages to outgoing short and long message (fragment) block packets

 if fOutgoingMessageQueue.IsEmpty then begin
  exit;
 end;

 MaximumShortMessageBlockPacketSize:=fPeer.fMTU-(RNL_IP_HEADER_SIZE+
                                                 RNL_UDP_HEADER_SIZE+
                                                 SizeOf(TRNLProtocolNormalPacketHeader)+
                                                 SizeOf(TRNLProtocolBlockPacketChannel)+
                                                 SizeOf(TRNLPeerReliableChannelShortMessagePacketHeader));

 MaximumLongMessageBlockPacketSize:=fPeer.fMTU-(RNL_IP_HEADER_SIZE+
                                                RNL_UDP_HEADER_SIZE+
                                                SizeOf(TRNLProtocolNormalPacketHeader)+
                                                SizeOf(TRNLProtocolBlockPacketChannel)+
                                                SizeOf(TRNLPeerReliableChannelLongMessagePacketHeader));

 MaxPacketsToSend:=TRNLSizeInt(fHost.fReliableChannelBlockPacketWindowSize)-TRNLSequenceNumber.Difference(fOutgoingBlockPacketSequenceNumber,fIncomingAcknowledgementSequenceNumber);

 while fOutgoingMessageQueue.Peek(Message) do begin

  if assigned(Message) and ((Message.fDataLength>0) and (Message.fDataLength<=fHost.fMaximumMessageSize)) then begin

   if Message.fDataLength<=MaximumShortMessageBlockPacketSize then begin

    if MaxPacketsToSend<1 then begin

     break;

    end else begin

     try

      fOutgoingMessageQueue.Dequeue;

      BlockPacket:=TRNLPeerBlockPacket.Create(fPeer);
      try

       BlockPacket.fBlockPacket.Channel.Header.TypeAndSubtype:=(TRNLInt32(TRNLProtocolBlockPacketType(RNL_PROTOCOL_BLOCK_PACKET_TYPE_CHANNEL)) shl 0) or
                                                               (TRNLInt32(TRNLPeerReliableChannelCommandType(RNL_PEER_RELIABLE_CHANNEL_COMMAND_TYPE_SHORT_MESSAGE)) shl 4);
       BlockPacket.fBlockPacket.Channel.ChannelNumber:=fChannelNumber;
       BlockPacket.fBlockPacket.Channel.PayloadDataLength:=TRNLEndianness.HostToLittleEndian16(SizeOf(TRNLPeerReliableChannelShortMessagePacketHeader)+Message.fDataLength);

       BlockPacket.fBlockPacketDataLength:=SizeOf(TRNLPeerReliableChannelShortMessagePacketHeader)+Message.fDataLength;

       SetLength(BlockPacket.fBlockPacketData,BlockPacket.fBlockPacketDataLength);

       ShortMessagePacketHeader:=TRNLPointer(@BlockPacket.fBlockPacketData[0]);
       ShortMessagePacketHeader^.Header.SequenceNumber:=TRNLEndianness.HostToLittleEndian16(fOutgoingMessageBlockPacketSequenceNumber);

       Move(Message.fData^,
            BlockPacket.fBlockPacketData[SizeOf(TRNLPeerReliableChannelShortMessagePacketHeader)],
            Message.fDataLength);

       BlockPacket.fSequenceNumber:=fOutgoingMessageBlockPacketSequenceNumber;

       inc(fOutgoingMessageBlockPacketSequenceNumber);

       inc(fPeer.fUnacknowlegmentedBlockPackets);

      finally
       fOutgoingBlockPacketQueue.Enqueue(BlockPacket);
      end;

     finally
      Message.DecRef;
     end;

    end;

   end else begin

    if MaxPacketsToSend<((Message.fDataLength+(MaximumLongMessageBlockPacketSize-1)) div MaximumLongMessageBlockPacketSize) then begin

     break;

    end else begin

     try

      fOutgoingMessageQueue.Dequeue;

      MessagePosition:=0;
      while MessagePosition<Message.fDataLength do begin

       MessagePartLength:=Min(Max(TRNLInt64(Message.fDataLength-MessagePosition),TRNLInt64(1)),TRNLInt64(MaximumLongMessageBlockPacketSize));

       BlockPacket:=TRNLPeerBlockPacket.Create(fPeer);
       try

        BlockPacket.fBlockPacket.Channel.Header.TypeAndSubtype:=(TRNLInt32(TRNLProtocolBlockPacketType(RNL_PROTOCOL_BLOCK_PACKET_TYPE_CHANNEL)) shl 0) or
                                                                (TRNLInt32(TRNLPeerReliableChannelCommandType(RNL_PEER_RELIABLE_CHANNEL_COMMAND_TYPE_LONG_MESSAGE)) shl 4);
        BlockPacket.fBlockPacket.Channel.ChannelNumber:=fChannelNumber;
        BlockPacket.fBlockPacket.Channel.PayloadDataLength:=TRNLEndianness.HostToLittleEndian16(SizeOf(TRNLPeerReliableChannelLongMessagePacketHeader)+MessagePartLength);

        BlockPacket.fBlockPacketDataLength:=SizeOf(TRNLPeerReliableChannelLongMessagePacketHeader)+MessagePartLength;

        SetLength(BlockPacket.fBlockPacketData,BlockPacket.fBlockPacketDataLength);

        LongMessagePacketHeader:=TRNLPointer(@BlockPacket.fBlockPacketData[0]);
        LongMessagePacketHeader^.Header.SequenceNumber:=TRNLEndianness.HostToLittleEndian16(fOutgoingMessageBlockPacketSequenceNumber);
        LongMessagePacketHeader^.MessageNumber:=TRNLEndianness.HostToLittleEndian16(fOutgoingMessageNumber);
        LongMessagePacketHeader^.Offset:=TRNLEndianness.HostToLittleEndian32(MessagePosition);
        LongMessagePacketHeader^.Length:=TRNLEndianness.HostToLittleEndian32(Message.fDataLength);

        Move(PRNLUInt8Array(TRNLPointer(Message.fData))^[MessagePosition],
             BlockPacket.fBlockPacketData[SizeOf(TRNLPeerReliableChannelLongMessagePacketHeader)],
             MessagePartLength);

        BlockPacket.fSequenceNumber:=fOutgoingMessageBlockPacketSequenceNumber;

        inc(fOutgoingMessageBlockPacketSequenceNumber);

        inc(fPeer.fUnacknowlegmentedBlockPackets);

       finally
        fOutgoingBlockPacketQueue.Enqueue(BlockPacket);
       end;

       inc(MessagePosition,MessagePartLength);

      end;

      inc(fOutgoingMessageNumber);

     finally
      Message.DecRef;
     end;

    end;

   end;

  end else begin

   try

    fOutgoingMessageQueue.Dequeue;

   finally

    if assigned(Message) then begin
     Message.DecRef;
    end;

   end;

  end;

 end;

end;

procedure TRNLPeerReliableOrderedChannel.DispatchIncomingMessageBlockPacket(const aBlockPacket:TRNLPeerBlockPacket);
var ChannelCommandType:TRNLPeerReliableChannelCommandType;
    BlockPacketDataPosition,BlockDataLength,FragmentOffset:TRNLSizeUInt;
    LongMessagePacketHeader:PRNLPeerReliableChannelLongMessagePacketHeader;
begin

 BlockPacketDataPosition:=0;

 ChannelCommandType:=TRNLPeerReliableChannelCommandType(TRNLInt32(aBlockPacket.fBlockPacket.Channel.Header.TypeAndSubtype shr 4));

 case ChannelCommandType of

  RNL_PEER_RELIABLE_CHANNEL_COMMAND_TYPE_SHORT_MESSAGE:begin

   fIncomingMessageLength:=0;
   if assigned(fIncomingMessageReceiveBufferData) then begin
    FreeMem(fIncomingMessageReceiveBufferData);
    fIncomingMessageReceiveBufferData:=nil;
   end;

   if (BlockPacketDataPosition+(SizeOf(TRNLPeerReliableChannelShortMessagePacketHeader)-1))>=aBlockPacket.fBlockPacketDataLength then begin
    exit;
   end;

   BlockPacketDataPosition:=SizeOf(TRNLPeerReliableChannelShortMessagePacketHeader);
   BlockDataLength:=aBlockPacket.fBlockPacketDataLength-BlockPacketDataPosition;

   if (BlockPacketDataPosition+BlockDataLength)>aBlockPacket.fBlockPacketDataLength then begin
    exit;
   end;

   fIncomingMessageQueue.Enqueue(TRNLMessage.CreateFromMemory(TRNLPointer(@aBlockPacket.fBlockPacketData[BlockPacketDataPosition]),
                                                              BlockDataLength,
                                                              []));

  end;

  RNL_PEER_RELIABLE_CHANNEL_COMMAND_TYPE_LONG_MESSAGE:begin

   if (BlockPacketDataPosition+(SizeOf(TRNLPeerReliableChannelLongMessagePacketHeader)-1))>=aBlockPacket.fBlockPacketDataLength then begin
    fIncomingMessageLength:=0;
    if assigned(fIncomingMessageReceiveBufferData) then begin
     FreeMem(fIncomingMessageReceiveBufferData);
     fIncomingMessageReceiveBufferData:=nil;
    end;
    exit;
   end;

   LongMessagePacketHeader:=TRNLPointer(@aBlockPacket.fBlockPacketData[BlockPacketDataPosition]);

   LongMessagePacketHeader^.MessageNumber:=TRNLEndianness.LittleEndianToHost16(LongMessagePacketHeader^.MessageNumber);
   LongMessagePacketHeader^.Offset:=TRNLEndianness.LittleEndianToHost32(LongMessagePacketHeader^.Offset);
   LongMessagePacketHeader^.Length:=TRNLEndianness.LittleEndianToHost32(LongMessagePacketHeader^.Length);

   if LongMessagePacketHeader^.Offset=0 then begin

    fIncomingMessageNumber:=LongMessagePacketHeader^.MessageNumber;

    fIncomingReceivedMessageDataLength:=0;

    fIncomingMessageLength:=LongMessagePacketHeader^.Length;

    if assigned(fIncomingMessageReceiveBufferData) then begin
     FreeMem(fIncomingMessageReceiveBufferData);
     fIncomingMessageReceiveBufferData:=nil;
    end;

    GetMem(fIncomingMessageReceiveBufferData,LongMessagePacketHeader^.Length);

   end else begin

    if (fIncomingMessageNumber<>LongMessagePacketHeader^.MessageNumber) or
       (not assigned(fIncomingMessageReceiveBufferData)) or
       (fIncomingMessageLength<>LongMessagePacketHeader^.Length) then begin
     // Reject
     fIncomingMessageLength:=0;
     if assigned(fIncomingMessageReceiveBufferData) then begin
      FreeMem(fIncomingMessageReceiveBufferData);
      fIncomingMessageReceiveBufferData:=nil;
     end;
     exit;
    end;

   end;

   if not assigned(fIncomingMessageReceiveBufferData) then begin
    fIncomingReceivedMessageDataLength:=0;
   end;

   BlockPacketDataPosition:=SizeOf(TRNLPeerReliableChannelLongMessagePacketHeader);
   BlockDataLength:=aBlockPacket.fBlockPacketDataLength-BlockPacketDataPosition;

   if (BlockPacketDataPosition+BlockDataLength)>aBlockPacket.fBlockPacketDataLength then begin
    fIncomingMessageLength:=0;
    if assigned(fIncomingMessageReceiveBufferData) then begin
     FreeMem(fIncomingMessageReceiveBufferData);
     fIncomingMessageReceiveBufferData:=nil;
    end;
    exit;
   end;

   FragmentOffset:=LongMessagePacketHeader^.Offset;

   if (FragmentOffset+BlockDataLength)>fIncomingMessageLength then begin
    fIncomingMessageLength:=0;
    if assigned(fIncomingMessageReceiveBufferData) then begin
     FreeMem(fIncomingMessageReceiveBufferData);
     fIncomingMessageReceiveBufferData:=nil;
    end;
    exit;
   end;

   Move(aBlockPacket.fBlockPacketData[BlockPacketDataPosition],
        PRNLUInt8Array(TRNLPointer(fIncomingMessageReceiveBufferData))^[FragmentOffset],
        BlockDataLength);

   inc(fIncomingReceivedMessageDataLength,BlockDataLength);

   if fIncomingReceivedMessageDataLength=fIncomingMessageLength then begin
    fIncomingMessageQueue.Enqueue(TRNLMessage.CreateFromMemory(fIncomingMessageReceiveBufferData,
                                                               fIncomingMessageLength,
                                                               [RNL_MESSAGE_FLAG_NO_ALLOCATE]));
    fIncomingMessageLength:=0;
    fIncomingMessageReceiveBufferData:=nil;
   end;

  end;

  else begin

   fIncomingMessageLength:=0;
   if assigned(fIncomingMessageReceiveBufferData) then begin
    FreeMem(fIncomingMessageReceiveBufferData);
    fIncomingMessageReceiveBufferData:=nil;
   end;

  end;

 end;

end;

constructor TRNLPeerReliableUnorderedChannelLongMessage.Create(const aChannel:TRNLPeerReliableUnorderedChannel;const aMessageNumber,aMessageLength:TRNLUInt32);
begin

 inherited Create;

 fValue:=self;

 fChannel:=aChannel;

 fMessageNumber:=aMessageNumber;

 fIncomingMessageLength:=aMessageLength;

 fIncomingReceivedMessageDataLength:=0;

 fIncomingMessageReceiveBufferData:=nil;
 GetMem(fIncomingMessageReceiveBufferData,fIncomingMessageLength);
 FillChar(fIncomingMessageReceiveBufferData^,fIncomingMessageLength,#0);

 fIncomingMessageReceiveBufferFlagData:=nil;
 GetMem(fIncomingMessageReceiveBufferFlagData,fIncomingMessageLength);
 FillChar(fIncomingMessageReceiveBufferFlagData^,fIncomingMessageLength,#0);

end;

destructor TRNLPeerReliableUnorderedChannelLongMessage.Destroy;
begin

 if assigned(fIncomingMessageReceiveBufferData) then begin
  FreeMem(fIncomingMessageReceiveBufferData);
  fIncomingMessageReceiveBufferData:=nil;
 end;

 if assigned(fIncomingMessageReceiveBufferFlagData) then begin
  FreeMem(fIncomingMessageReceiveBufferFlagData);
  fIncomingMessageReceiveBufferFlagData:=nil;
 end;

 inherited Destroy;

end;

procedure TRNLPeerReliableUnorderedChannelLongMessage.DispatchIncomingData(const aOffset,aLength:TRNLUInt32;const aData:TRNLPointer);
var Index:TRNLSizeUInt;
begin

 if aLength=0 then begin
  exit;
 end;

 if (aOffset+aLength)>fIncomingMessageLength then begin
  Free;
  exit;
 end;

 for Index:=aOffset to aOffset+(aLength-1) do begin
  if PRNLUInt8Array(TRNLPointer(fIncomingMessageReceiveBufferFlagData))^[Index]<>0 then begin
   Free;
   exit;
  end;
 end;

 FillChar(PRNLUInt8Array(TRNLPointer(fIncomingMessageReceiveBufferFlagData))^[aOffset],
          aLength,
          #$ff);

 System.Move(aData^,
             PRNLUInt8Array(TRNLPointer(fIncomingMessageReceiveBufferData))^[aOffset],
             aLength);

 inc(fIncomingReceivedMessageDataLength,aLength);

 if fIncomingReceivedMessageDataLength=fIncomingMessageLength then begin
  fChannel.fIncomingMessageQueue.Enqueue(TRNLMessage.CreateFromMemory(fIncomingMessageReceiveBufferData,
                                                                      fIncomingMessageLength,
                                                                      [RNL_MESSAGE_FLAG_NO_ALLOCATE]));
  fIncomingMessageLength:=0;
  fIncomingMessageReceiveBufferData:=nil;
  Free;
  exit;
 end;

end;

constructor TRNLPeerReliableUnorderedChannel.Create(const aPeer:TRNLPeer;const aChannelNumber:TRNLUInt16);
begin

 inherited Create(aPeer,aChannelNumber);

 fOrdered:=false;

 fIncomingLongMessages:=TRNLPeerReliableUnorderedChannelLongMessageListNode.Create;
 fIncomingLongMessages.fValue:=nil;

 fOutgoingMessageBlockPacketSequenceNumber:=0;

 fOutgoingMessageNumber:=0;

end;

destructor TRNLPeerReliableUnorderedChannel.Destroy;
begin

 while not fIncomingLongMessages.IsEmpty do begin
  fIncomingLongMessages.Front.Value.Free;
 end;

 FreeAndNil(fIncomingLongMessages);

 inherited Destroy;

end;

procedure TRNLPeerReliableUnorderedChannel.DispatchOutgoingMessageBlockPackets;
var Message:TRNLMessage;
    MaximumShortMessageBlockPacketSize,
    MaximumLongMessageBlockPacketSize,
    MessagePartLength,
    MessagePosition:TRNLSizeUInt;
    MaxPacketsToSend:TRNLSizeInt;
    BlockPacket:TRNLPeerBlockPacket;
    ShortMessagePacketHeader:PRNLPeerReliableChannelShortMessagePacketHeader;
    LongMessagePacketHeader:PRNLPeerReliableChannelLongMessagePacketHeader;
begin

 // Dispatch outgoing enqueued messages to outgoing short and long message (fragment) block packets

 if fOutgoingMessageQueue.IsEmpty then begin
  exit;
 end;

 MaximumShortMessageBlockPacketSize:=fPeer.fMTU-(RNL_IP_HEADER_SIZE+
                                                 RNL_UDP_HEADER_SIZE+
                                                 SizeOf(TRNLProtocolNormalPacketHeader)+
                                                 SizeOf(TRNLProtocolBlockPacketChannel)+
                                                 SizeOf(TRNLPeerReliableChannelShortMessagePacketHeader));

 MaximumLongMessageBlockPacketSize:=fPeer.fMTU-(RNL_IP_HEADER_SIZE+
                                                RNL_UDP_HEADER_SIZE+
                                                SizeOf(TRNLProtocolNormalPacketHeader)+
                                                SizeOf(TRNLProtocolBlockPacketChannel)+
                                                SizeOf(TRNLPeerReliableChannelLongMessagePacketHeader));

 MaxPacketsToSend:=TRNLSizeInt(fHost.fReliableChannelBlockPacketWindowSize)-TRNLSequenceNumber.Difference(fOutgoingBlockPacketSequenceNumber,fIncomingAcknowledgementSequenceNumber);

 while fOutgoingMessageQueue.Peek(Message) do begin

  if assigned(Message) and ((Message.fDataLength>0) and (Message.fDataLength<=fHost.fMaximumMessageSize)) then begin

   if Message.fDataLength<=MaximumShortMessageBlockPacketSize then begin

    if MaxPacketsToSend<1 then begin

     break;

    end else begin

     try

      fOutgoingMessageQueue.Dequeue;

      BlockPacket:=TRNLPeerBlockPacket.Create(fPeer);
      try

       BlockPacket.fBlockPacket.Channel.Header.TypeAndSubtype:=(TRNLInt32(TRNLProtocolBlockPacketType(RNL_PROTOCOL_BLOCK_PACKET_TYPE_CHANNEL)) shl 0) or
                                                               (TRNLInt32(TRNLPeerReliableChannelCommandType(RNL_PEER_RELIABLE_CHANNEL_COMMAND_TYPE_SHORT_MESSAGE)) shl 4);
       BlockPacket.fBlockPacket.Channel.ChannelNumber:=fChannelNumber;
       BlockPacket.fBlockPacket.Channel.PayloadDataLength:=TRNLEndianness.HostToLittleEndian16(SizeOf(TRNLPeerReliableChannelShortMessagePacketHeader)+Message.fDataLength);

       BlockPacket.fBlockPacketDataLength:=SizeOf(TRNLPeerReliableChannelShortMessagePacketHeader)+Message.fDataLength;

       SetLength(BlockPacket.fBlockPacketData,BlockPacket.fBlockPacketDataLength);

       ShortMessagePacketHeader:=TRNLPointer(@BlockPacket.fBlockPacketData[0]);
       ShortMessagePacketHeader^.Header.SequenceNumber:=TRNLEndianness.HostToLittleEndian16(fOutgoingMessageBlockPacketSequenceNumber);

       Move(Message.fData^,
            BlockPacket.fBlockPacketData[SizeOf(TRNLPeerReliableChannelShortMessagePacketHeader)],
            Message.fDataLength);

       BlockPacket.fSequenceNumber:=fOutgoingMessageBlockPacketSequenceNumber;

       inc(fOutgoingMessageBlockPacketSequenceNumber);

       inc(fPeer.fUnacknowlegmentedBlockPackets);

      finally
       fOutgoingBlockPacketQueue.Enqueue(BlockPacket);
      end;

     finally
      Message.DecRef;
     end;

    end;

   end else begin

    if MaxPacketsToSend<((Message.fDataLength+(MaximumLongMessageBlockPacketSize-1)) div MaximumLongMessageBlockPacketSize) then begin

     break;

    end else begin

     try

      fOutgoingMessageQueue.Dequeue;

      MessagePosition:=0;
      while MessagePosition<Message.fDataLength do begin

       MessagePartLength:=Min(Max(TRNLInt64(Message.fDataLength-MessagePosition),TRNLInt64(1)),TRNLInt64(MaximumLongMessageBlockPacketSize));

       BlockPacket:=TRNLPeerBlockPacket.Create(fPeer);
       try

        BlockPacket.fBlockPacket.Channel.Header.TypeAndSubtype:=(TRNLInt32(TRNLProtocolBlockPacketType(RNL_PROTOCOL_BLOCK_PACKET_TYPE_CHANNEL)) shl 0) or
                                                                (TRNLInt32(TRNLPeerReliableChannelCommandType(RNL_PEER_RELIABLE_CHANNEL_COMMAND_TYPE_LONG_MESSAGE)) shl 4);
        BlockPacket.fBlockPacket.Channel.ChannelNumber:=fChannelNumber;
        BlockPacket.fBlockPacket.Channel.PayloadDataLength:=TRNLEndianness.HostToLittleEndian16(SizeOf(TRNLPeerReliableChannelLongMessagePacketHeader)+MessagePartLength);

        BlockPacket.fBlockPacketDataLength:=SizeOf(TRNLPeerReliableChannelLongMessagePacketHeader)+MessagePartLength;

        SetLength(BlockPacket.fBlockPacketData,BlockPacket.fBlockPacketDataLength);

        LongMessagePacketHeader:=TRNLPointer(@BlockPacket.fBlockPacketData[0]);
        LongMessagePacketHeader^.Header.SequenceNumber:=TRNLEndianness.HostToLittleEndian16(fOutgoingMessageBlockPacketSequenceNumber);
        LongMessagePacketHeader^.MessageNumber:=TRNLEndianness.HostToLittleEndian16(fOutgoingMessageNumber);
        LongMessagePacketHeader^.Offset:=TRNLEndianness.HostToLittleEndian32(MessagePosition);
        LongMessagePacketHeader^.Length:=TRNLEndianness.HostToLittleEndian32(Message.fDataLength);

        Move(PRNLUInt8Array(TRNLPointer(Message.fData))^[MessagePosition],
             BlockPacket.fBlockPacketData[SizeOf(TRNLPeerReliableChannelLongMessagePacketHeader)],
             MessagePartLength);

        BlockPacket.fSequenceNumber:=fOutgoingMessageBlockPacketSequenceNumber;

        inc(fOutgoingMessageBlockPacketSequenceNumber);

        inc(fPeer.fUnacknowlegmentedBlockPackets);

       finally
        fOutgoingBlockPacketQueue.Enqueue(BlockPacket);
       end;

       inc(MessagePosition,MessagePartLength);

      end;

      inc(fOutgoingMessageNumber);

     finally
      Message.DecRef;
     end;

    end;

   end;

  end else begin

   try

    fOutgoingMessageQueue.Dequeue;

   finally

    if assigned(Message) then begin
     Message.DecRef;
    end;

   end;

  end;

 end;

end;

procedure TRNLPeerReliableUnorderedChannel.DispatchIncomingMessageBlockPacket(const aBlockPacket:TRNLPeerBlockPacket);
var ChannelCommandType:TRNLPeerReliableChannelCommandType;
    BlockPacketDataPosition,BlockDataLength:TRNLSizeUInt;
    LongMessagePacketHeader:PRNLPeerReliableChannelLongMessagePacketHeader;
    CurrentLongMessageListNode,NextLongMessageListNode:TRNLPeerReliableUnorderedChannelLongMessageListNode;
    LongMessage:TRNLPeerReliableUnorderedChannelLongMessage;
begin

 BlockPacketDataPosition:=0;

 ChannelCommandType:=TRNLPeerReliableChannelCommandType(TRNLInt32(aBlockPacket.fBlockPacket.Channel.Header.TypeAndSubtype shr 4));

 case ChannelCommandType of

  RNL_PEER_RELIABLE_CHANNEL_COMMAND_TYPE_SHORT_MESSAGE:begin

   if (BlockPacketDataPosition+(SizeOf(TRNLPeerReliableChannelShortMessagePacketHeader)-1))>=aBlockPacket.fBlockPacketDataLength then begin
    exit;
   end;

   BlockPacketDataPosition:=SizeOf(TRNLPeerReliableChannelShortMessagePacketHeader);
   BlockDataLength:=aBlockPacket.fBlockPacketDataLength-BlockPacketDataPosition;

   if (BlockPacketDataPosition+BlockDataLength)>aBlockPacket.fBlockPacketDataLength then begin
    exit;
   end;

   fIncomingMessageQueue.Enqueue(TRNLMessage.CreateFromMemory(TRNLPointer(@aBlockPacket.fBlockPacketData[BlockPacketDataPosition]),
                                                              BlockDataLength,
                                                              []));

  end;

  RNL_PEER_RELIABLE_CHANNEL_COMMAND_TYPE_LONG_MESSAGE:begin

   if (BlockPacketDataPosition+(SizeOf(TRNLPeerReliableChannelLongMessagePacketHeader)-1))>=aBlockPacket.fBlockPacketDataLength then begin
    exit;
   end;

   LongMessagePacketHeader:=TRNLPointer(@aBlockPacket.fBlockPacketData[BlockPacketDataPosition]);

   LongMessagePacketHeader^.MessageNumber:=TRNLEndianness.LittleEndianToHost16(LongMessagePacketHeader^.MessageNumber);
   LongMessagePacketHeader^.Offset:=TRNLEndianness.LittleEndianToHost32(LongMessagePacketHeader^.Offset);
   LongMessagePacketHeader^.Length:=TRNLEndianness.LittleEndianToHost32(LongMessagePacketHeader^.Length);

   BlockPacketDataPosition:=SizeOf(TRNLPeerReliableChannelLongMessagePacketHeader);
   BlockDataLength:=aBlockPacket.fBlockPacketDataLength-BlockPacketDataPosition;

   if (BlockPacketDataPosition+BlockDataLength)>aBlockPacket.fBlockPacketDataLength then begin
    exit;
   end;

   LongMessage:=nil;

   CurrentLongMessageListNode:=fIncomingLongMessages.Front;
   while CurrentLongMessageListNode<>fIncomingLongMessages do begin
    NextLongMessageListNode:=CurrentLongMessageListNode.fNext;
    try
     if assigned(CurrentLongMessageListNode.fValue) and
        (CurrentLongMessageListNode.fValue.fMessageNumber=LongMessagePacketHeader^.MessageNumber) then begin
      LongMessage:=CurrentLongMessageListNode.fValue;
      break;
     end;
    finally
     CurrentLongMessageListNode:=NextLongMessageListNode;
    end;
   end;

   if not assigned(LongMessage) then begin
    LongMessage:=TRNLPeerReliableUnorderedChannelLongMessage.Create(self,
                                                                    LongMessagePacketHeader^.MessageNumber,
                                                                    LongMessagePacketHeader^.Length);
    fIncomingLongMessages.Add(LongMessage);
   end;

   LongMessage.DispatchIncomingData(LongMessagePacketHeader^.Offset,
                                    BlockDataLength,
                                    @aBlockPacket.fBlockPacketData[BlockPacketDataPosition]);

  end;

 end;

end;

constructor TRNLPeerUnreliableOrderedChannel.Create(const aPeer:TRNLPeer;const aChannelNumber:TRNLUInt16);
begin
 inherited Create(aPeer,aChannelNumber);
 fIncomingSequenceNumber:=$ffff;
 fIncomingMessageNumber:=$ffff;
 fIncomingMessageLength:=0;
 fIncomingMessageReceiveBufferData:=nil;
 fIncomingSawLost:=false;
 fOutgoingSequenceNumber:=0;
 fOutgoingMessageNumber:=0;
end;

destructor TRNLPeerUnreliableOrderedChannel.Destroy;
begin
 if assigned(fIncomingMessageReceiveBufferData) then begin
  FreeMem(fIncomingMessageReceiveBufferData);
  fIncomingMessageReceiveBufferData:=nil;
 end;
 inherited Destroy;
end;

function TRNLPeerUnreliableOrderedChannel.GetMaximumUnfragmentedMessageSize:TRNLSizeUInt;
begin
 result:=fPeer.fMTU-(RNL_IP_HEADER_SIZE+
                     RNL_UDP_HEADER_SIZE+
                     SizeOf(TRNLProtocolNormalPacketHeader)+
                     SizeOf(TRNLProtocolBlockPacketChannel)+
                     SizeOf(TRNLPeerUnreliableOrderedChannelShortMessagePacketHeader));
end;

procedure TRNLPeerUnreliableOrderedChannel.DispatchOutgoingBlockPackets;
var Message:TRNLMessage;
    MaximumShortMessageBlockPacketSize,
    MaximumLongMessageBlockPacketSize,
    MessagePartLength,
    MessagePosition:TRNLSizeUInt;
    BlockPacket:TRNLPeerBlockPacket;
    ShortMessagePacketHeader:PRNLPeerUnreliableOrderedChannelShortMessagePacketHeader;
    LongMessagePacketHeader:PRNLPeerUnreliableOrderedChannelLongMessagePacketHeader;
begin

 if fOutgoingMessageQueue.IsEmpty then begin
  exit;
 end;

 MaximumShortMessageBlockPacketSize:=fPeer.fMTU-(RNL_IP_HEADER_SIZE+
                                                 RNL_UDP_HEADER_SIZE+
                                                 SizeOf(TRNLProtocolNormalPacketHeader)+
                                                 SizeOf(TRNLProtocolBlockPacketChannel)+
                                                 SizeOf(TRNLPeerUnreliableOrderedChannelShortMessagePacketHeader));

 MaximumLongMessageBlockPacketSize:=fPeer.fMTU-(RNL_IP_HEADER_SIZE+
                                                RNL_UDP_HEADER_SIZE+
                                                SizeOf(TRNLProtocolNormalPacketHeader)+
                                                SizeOf(TRNLProtocolBlockPacketChannel)+
                                                SizeOf(TRNLPeerUnreliableOrderedChannelLongMessagePacketHeader));

 while fOutgoingMessageQueue.Dequeue(Message) do begin

  try

   if (Message.fDataLength>0) and (Message.fDataLength<=fHost.fMaximumMessageSize) then begin

    if Message.fDataLength<=MaximumShortMessageBlockPacketSize then begin

     BlockPacket:=TRNLPeerBlockPacket.Create(fPeer);
     try

      BlockPacket.fBlockPacket.Channel.Header.TypeAndSubtype:=(TRNLInt32(TRNLProtocolBlockPacketType(RNL_PROTOCOL_BLOCK_PACKET_TYPE_CHANNEL)) shl 0) or
                                                              (TRNLInt32(TRNLPeerUnreliableOrderedChannelCommandType(RNL_PEER_UNRELIABLE_ORDERED_CHANNEL_COMMAND_TYPE_SHORT_MESSAGE)) shl 4);
      BlockPacket.fBlockPacket.Channel.ChannelNumber:=fChannelNumber;
      BlockPacket.fBlockPacket.Channel.PayloadDataLength:=TRNLEndianness.HostToLittleEndian16(SizeOf(TRNLPeerUnreliableOrderedChannelShortMessagePacketHeader)+Message.fDataLength);

      BlockPacket.fBlockPacketDataLength:=SizeOf(TRNLPeerUnreliableOrderedChannelShortMessagePacketHeader)+Message.fDataLength;

      SetLength(BlockPacket.fBlockPacketData,BlockPacket.fBlockPacketDataLength);

      ShortMessagePacketHeader:=TRNLPointer(@BlockPacket.fBlockPacketData[0]);
      ShortMessagePacketHeader^.SequenceNumber:=TRNLEndianness.HostToLittleEndian16(fOutgoingSequenceNumber);
      inc(fOutgoingSequenceNumber);

      Move(Message.fData^,
           BlockPacket.fBlockPacketData[SizeOf(TRNLPeerUnreliableOrderedChannelShortMessagePacketHeader)],
           Message.fDataLength);

     finally
      fPeer.fOutgoingBlockPackets.Enqueue(BlockPacket);
     end;

    end else begin

     MessagePosition:=0;
     while MessagePosition<Message.fDataLength do begin

      MessagePartLength:=Min(Max(TRNLInt64(Message.fDataLength-MessagePosition),TRNLInt64(1)),TRNLInt64(MaximumLongMessageBlockPacketSize));

      BlockPacket:=TRNLPeerBlockPacket.Create(fPeer);
      try

       BlockPacket.fBlockPacket.Channel.Header.TypeAndSubtype:=(TRNLInt32(TRNLProtocolBlockPacketType(RNL_PROTOCOL_BLOCK_PACKET_TYPE_CHANNEL)) shl 0) or
                                                               (TRNLInt32(TRNLPeerUnreliableOrderedChannelCommandType(RNL_PEER_UNRELIABLE_ORDERED_CHANNEL_COMMAND_TYPE_LONG_MESSAGE)) shl 4);
       BlockPacket.fBlockPacket.Channel.ChannelNumber:=fChannelNumber;
       BlockPacket.fBlockPacket.Channel.PayloadDataLength:=TRNLEndianness.HostToLittleEndian16(SizeOf(TRNLPeerUnreliableOrderedChannelLongMessagePacketHeader)+MessagePartLength);

       BlockPacket.fBlockPacketDataLength:=SizeOf(TRNLPeerUnreliableOrderedChannelLongMessagePacketHeader)+MessagePartLength;

       SetLength(BlockPacket.fBlockPacketData,BlockPacket.fBlockPacketDataLength);

       LongMessagePacketHeader:=TRNLPointer(@BlockPacket.fBlockPacketData[0]);
       LongMessagePacketHeader^.SequenceNumber:=TRNLEndianness.HostToLittleEndian16(fOutgoingSequenceNumber);
       LongMessagePacketHeader^.MessageNumber:=TRNLEndianness.HostToLittleEndian16(fOutgoingMessageNumber);
       LongMessagePacketHeader^.Offset:=TRNLEndianness.HostToLittleEndian32(MessagePosition);
       LongMessagePacketHeader^.Length:=TRNLEndianness.HostToLittleEndian32(Message.fDataLength);
       inc(fOutgoingSequenceNumber);

       Move(PRNLUInt8Array(TRNLPointer(Message.fData))^[MessagePosition],
            BlockPacket.fBlockPacketData[SizeOf(TRNLPeerUnreliableOrderedChannelLongMessagePacketHeader)],
            MessagePartLength);

      finally
       fPeer.fOutgoingBlockPackets.Enqueue(BlockPacket);
      end;

      inc(MessagePosition,MessagePartLength);

     end;

     inc(fOutgoingMessageNumber);

    end;

   end;

  finally
   Message.DecRef;
  end;

 end;

end;

procedure TRNLPeerUnreliableOrderedChannel.DispatchIncomingBlockPacket(const aBlockPacket:TRNLPeerBlockPacket);
var ChannelCommandType:TRNLPeerUnreliableOrderedChannelCommandType;
    BlockPacketDataPosition,BlockDataLength,FragmentOffset:TRNLSizeUInt;
    BlockSequenceNumber,LastSequenceNumber:TRNLSequenceNumber;
    ShortMessagePacketHeader:PRNLPeerUnreliableOrderedChannelShortMessagePacketHeader;
    LongMessagePacketHeader:PRNLPeerUnreliableOrderedChannelLongMessagePacketHeader;
    MessageFlags:TRNLMessageFlags;
begin

 BlockPacketDataPosition:=0;

 ChannelCommandType:=TRNLPeerUnreliableOrderedChannelCommandType(TRNLInt32(aBlockPacket.fBlockPacket.Channel.Header.TypeAndSubtype shr 4));

 MessageFlags:=[];

 case ChannelCommandType of

  RNL_PEER_UNRELIABLE_ORDERED_CHANNEL_COMMAND_TYPE_SHORT_MESSAGE:begin

   fIncomingMessageLength:=0;
   if assigned(fIncomingMessageReceiveBufferData) then begin
    FreeMem(fIncomingMessageReceiveBufferData);
    fIncomingMessageReceiveBufferData:=nil;
   end;

   if (BlockPacketDataPosition+(SizeOf(TRNLPeerUnreliableOrderedChannelShortMessagePacketHeader)-1))>=aBlockPacket.fBlockPacketDataLength then begin
    fIncomingSawLost:=true;
    exit;
   end;

   ShortMessagePacketHeader:=TRNLPointer(@aBlockPacket.fBlockPacketData[BlockPacketDataPosition]);

   BlockSequenceNumber:=TRNLEndianness.LittleEndianToHost16(ShortMessagePacketHeader^.SequenceNumber);

   fIncomingSawLost:=fIncomingSawLost or ((BlockSequenceNumber-fIncomingSequenceNumber).fValue>1);

   if fIncomingSequenceNumber>=BlockSequenceNumber then begin
    // Reject, it is anyway on an unreliable channel
    fIncomingSawLost:=true;
    exit;
   end;

   fIncomingSequenceNumber:=BlockSequenceNumber;

   BlockPacketDataPosition:=SizeOf(TRNLPeerUnreliableOrderedChannelShortMessagePacketHeader);
   BlockDataLength:=aBlockPacket.fBlockPacketDataLength-BlockPacketDataPosition;

   if (BlockPacketDataPosition+BlockDataLength)>aBlockPacket.fBlockPacketDataLength then begin
    exit;
   end;

   if fIncomingSawLost then begin
    fIncomingSawLost:=false;
    Include(MessageFlags,RNL_MESSAGE_FLAG_UNRELIABLE_ORDERED_CHANNEL_PREVIOUS_LOST);
   end;

   fIncomingMessageQueue.Enqueue(TRNLMessage.CreateFromMemory(TRNLPointer(@aBlockPacket.fBlockPacketData[BlockPacketDataPosition]),
                                                              BlockDataLength,
                                                              MessageFlags));

  end;

  RNL_PEER_UNRELIABLE_ORDERED_CHANNEL_COMMAND_TYPE_LONG_MESSAGE:begin

   if (BlockPacketDataPosition+(SizeOf(TRNLPeerUnreliableOrderedChannelLongMessagePacketHeader)-1))>=aBlockPacket.fBlockPacketDataLength then begin
    fIncomingSawLost:=true;
    fIncomingMessageLength:=0;
    if assigned(fIncomingMessageReceiveBufferData) then begin
     FreeMem(fIncomingMessageReceiveBufferData);
     fIncomingMessageReceiveBufferData:=nil;
    end;
    exit;
   end;

   LongMessagePacketHeader:=TRNLPointer(@aBlockPacket.fBlockPacketData[BlockPacketDataPosition]);

   BlockSequenceNumber:=TRNLEndianness.LittleEndianToHost16(LongMessagePacketHeader^.SequenceNumber);

   fIncomingSawLost:=fIncomingSawLost or ((BlockSequenceNumber-fIncomingSequenceNumber).fValue>1);

   LastSequenceNumber:=fIncomingSequenceNumber;

   if LastSequenceNumber>=BlockSequenceNumber then begin
    // Reject, it is anyway on an unreliable channel
    fIncomingSawLost:=true;
    fIncomingMessageLength:=0;
    if assigned(fIncomingMessageReceiveBufferData) then begin
     FreeMem(fIncomingMessageReceiveBufferData);
     fIncomingMessageReceiveBufferData:=nil;
    end;
    exit;
   end;

   fIncomingSequenceNumber:=BlockSequenceNumber;

   LongMessagePacketHeader^.MessageNumber:=TRNLEndianness.LittleEndianToHost16(LongMessagePacketHeader^.MessageNumber);
   LongMessagePacketHeader^.Offset:=TRNLEndianness.LittleEndianToHost32(LongMessagePacketHeader^.Offset);
   LongMessagePacketHeader^.Length:=TRNLEndianness.LittleEndianToHost32(LongMessagePacketHeader^.Length);

   if LongMessagePacketHeader^.Offset=0 then begin

    fIncomingMessageNumber:=LongMessagePacketHeader^.MessageNumber;

    fIncomingReceivedMessageDataLength:=0;

    fIncomingMessageLength:=LongMessagePacketHeader^.Length;

    if assigned(fIncomingMessageReceiveBufferData) then begin
     FreeMem(fIncomingMessageReceiveBufferData);
     fIncomingMessageReceiveBufferData:=nil;
    end;

    GetMem(fIncomingMessageReceiveBufferData,LongMessagePacketHeader^.Length);

   end else begin

    if (fIncomingMessageNumber<>LongMessagePacketHeader^.MessageNumber) or
       (not assigned(fIncomingMessageReceiveBufferData)) or
       (fIncomingMessageLength<>LongMessagePacketHeader^.Length) or
       ((BlockSequenceNumber-LastSequenceNumber).fValue>=2) then begin
     // Reject, it is anyway on an unreliable channel
     fIncomingSawLost:=true;
     fIncomingMessageLength:=0;
     if assigned(fIncomingMessageReceiveBufferData) then begin
      FreeMem(fIncomingMessageReceiveBufferData);
      fIncomingMessageReceiveBufferData:=nil;
     end;
     exit;
    end;

   end;

   if not assigned(fIncomingMessageReceiveBufferData) then begin
    fIncomingReceivedMessageDataLength:=0;
   end;

   BlockPacketDataPosition:=SizeOf(TRNLPeerUnreliableOrderedChannelLongMessagePacketHeader);
   BlockDataLength:=aBlockPacket.fBlockPacketDataLength-BlockPacketDataPosition;

   if (BlockPacketDataPosition+BlockDataLength)>aBlockPacket.fBlockPacketDataLength then begin
    fIncomingMessageLength:=0;
    if assigned(fIncomingMessageReceiveBufferData) then begin
     FreeMem(fIncomingMessageReceiveBufferData);
     fIncomingMessageReceiveBufferData:=nil;
    end;
    exit;
   end;

   FragmentOffset:=LongMessagePacketHeader^.Offset;

   if (FragmentOffset+BlockDataLength)>fIncomingMessageLength then begin
    fIncomingMessageLength:=0;
    if assigned(fIncomingMessageReceiveBufferData) then begin
     FreeMem(fIncomingMessageReceiveBufferData);
     fIncomingMessageReceiveBufferData:=nil;
    end;
    exit;
   end;

   Move(aBlockPacket.fBlockPacketData[BlockPacketDataPosition],
        PRNLUInt8Array(TRNLPointer(fIncomingMessageReceiveBufferData))^[FragmentOffset],
        BlockDataLength);

   inc(fIncomingReceivedMessageDataLength,BlockDataLength);

   if fIncomingReceivedMessageDataLength=fIncomingMessageLength then begin
    if fIncomingSawLost then begin
     fIncomingSawLost:=false;
     Include(MessageFlags,RNL_MESSAGE_FLAG_UNRELIABLE_ORDERED_CHANNEL_PREVIOUS_LOST);
    end;
    fIncomingMessageQueue.Enqueue(TRNLMessage.CreateFromMemory(fIncomingMessageReceiveBufferData,
                                                               fIncomingMessageLength,
                                                               MessageFlags+[RNL_MESSAGE_FLAG_NO_ALLOCATE]));
    fIncomingMessageLength:=0;
    fIncomingMessageReceiveBufferData:=nil;
   end;

  end;

  else begin

   fIncomingMessageLength:=0;
   if assigned(fIncomingMessageReceiveBufferData) then begin
    FreeMem(fIncomingMessageReceiveBufferData);
    fIncomingMessageReceiveBufferData:=nil;
   end;

  end;

 end;

end;

constructor TRNLPeerUnreliableUnorderedChannel.Create(const aPeer:TRNLPeer;const aChannelNumber:TRNLUInt16);
begin
 inherited Create(aPeer,aChannelNumber);
 fIncomingMessageNumber:=$ffff;
 fIncomingMessageLength:=0;
 fIncomingMessageReceiveBufferData:=nil;
 fIncomingMessageReceiveBufferFlagData:=nil;
 fOutgoingMessageNumber:=0;
end;

destructor TRNLPeerUnreliableUnorderedChannel.Destroy;
begin
 if assigned(fIncomingMessageReceiveBufferData) then begin
  FreeMem(fIncomingMessageReceiveBufferData);
  fIncomingMessageReceiveBufferData:=nil;
 end;
 if assigned(fIncomingMessageReceiveBufferFlagData) then begin
  FreeMem(fIncomingMessageReceiveBufferFlagData);
  fIncomingMessageReceiveBufferFlagData:=nil;
 end;
 inherited Destroy;
end;

function TRNLPeerUnreliableUnorderedChannel.GetMaximumUnfragmentedMessageSize:TRNLSizeUInt;
begin
 result:=fPeer.fMTU-(RNL_IP_HEADER_SIZE+
                     RNL_UDP_HEADER_SIZE+
                     SizeOf(TRNLProtocolNormalPacketHeader)+
                     SizeOf(TRNLProtocolBlockPacketChannel)+
                     SizeOf(TRNLPeerUnreliableUnorderedChannelShortMessagePacketHeader));
end;

procedure TRNLPeerUnreliableUnorderedChannel.DispatchOutgoingBlockPackets;
var Message:TRNLMessage;
    MaximumShortMessageBlockPacketSize,
    MaximumLongMessageBlockPacketSize,
    MessagePartLength,
    MessagePosition:TRNLSizeUInt;
    BlockPacket:TRNLPeerBlockPacket;
    LongMessagePacketHeader:PRNLPeerUnreliableUnorderedChannelLongMessagePacketHeader;
begin

 if fOutgoingMessageQueue.IsEmpty then begin
  exit;
 end;

 MaximumShortMessageBlockPacketSize:=fPeer.fMTU-(RNL_IP_HEADER_SIZE+
                                                 RNL_UDP_HEADER_SIZE+
                                                 SizeOf(TRNLProtocolNormalPacketHeader)+
                                                 SizeOf(TRNLProtocolBlockPacketChannel)+
                                                 SizeOf(TRNLPeerUnreliableUnorderedChannelShortMessagePacketHeader));

 MaximumLongMessageBlockPacketSize:=fPeer.fMTU-(RNL_IP_HEADER_SIZE+
                                                RNL_UDP_HEADER_SIZE+
                                                SizeOf(TRNLProtocolNormalPacketHeader)+
                                                SizeOf(TRNLProtocolBlockPacketChannel)+
                                                SizeOf(TRNLPeerUnreliableUnorderedChannelLongMessagePacketHeader));

 while fOutgoingMessageQueue.Dequeue(Message) do begin

  try

   if (Message.fDataLength>0) and (Message.fDataLength<=fHost.fMaximumMessageSize) then begin

    if Message.fDataLength<=MaximumShortMessageBlockPacketSize then begin

     BlockPacket:=TRNLPeerBlockPacket.Create(fPeer);
     try

      BlockPacket.fBlockPacket.Channel.Header.TypeAndSubtype:=(TRNLInt32(TRNLProtocolBlockPacketType(RNL_PROTOCOL_BLOCK_PACKET_TYPE_CHANNEL)) shl 0) or
                                                              (TRNLInt32(TRNLPeerUnreliableUnorderedChannelCommandType(RNL_PEER_UNRELIABLE_UNORDERED_CHANNEL_COMMAND_TYPE_SHORT_MESSAGE)) shl 4);
      BlockPacket.fBlockPacket.Channel.ChannelNumber:=fChannelNumber;
      BlockPacket.fBlockPacket.Channel.PayloadDataLength:=TRNLEndianness.HostToLittleEndian16(SizeOf(TRNLPeerUnreliableUnorderedChannelShortMessagePacketHeader)+Message.fDataLength);

      BlockPacket.fBlockPacketDataLength:=SizeOf(TRNLPeerUnreliableUnorderedChannelShortMessagePacketHeader)+Message.fDataLength;

      SetLength(BlockPacket.fBlockPacketData,BlockPacket.fBlockPacketDataLength);

      Move(Message.fData^,
           BlockPacket.fBlockPacketData[SizeOf(TRNLPeerUnreliableUnorderedChannelShortMessagePacketHeader)],
           Message.fDataLength);

     finally
      fPeer.fOutgoingBlockPackets.Enqueue(BlockPacket);
     end;

    end else begin

     MessagePosition:=0;
     while MessagePosition<Message.fDataLength do begin

      MessagePartLength:=Min(Max(TRNLInt64(Message.fDataLength-MessagePosition),TRNLInt64(1)),TRNLInt64(MaximumLongMessageBlockPacketSize));

      BlockPacket:=TRNLPeerBlockPacket.Create(fPeer);
      try

       BlockPacket.fBlockPacket.Channel.Header.TypeAndSubtype:=(TRNLInt32(TRNLProtocolBlockPacketType(RNL_PROTOCOL_BLOCK_PACKET_TYPE_CHANNEL)) shl 0) or
                                                               (TRNLInt32(TRNLPeerUnreliableUnorderedChannelCommandType(RNL_PEER_UNRELIABLE_UNORDERED_CHANNEL_COMMAND_TYPE_LONG_MESSAGE)) shl 4);
       BlockPacket.fBlockPacket.Channel.ChannelNumber:=fChannelNumber;
       BlockPacket.fBlockPacket.Channel.PayloadDataLength:=TRNLEndianness.HostToLittleEndian16(SizeOf(TRNLPeerUnreliableUnorderedChannelLongMessagePacketHeader)+MessagePartLength);

       BlockPacket.fBlockPacketDataLength:=SizeOf(TRNLPeerUnreliableUnorderedChannelLongMessagePacketHeader)+MessagePartLength;

       SetLength(BlockPacket.fBlockPacketData,BlockPacket.fBlockPacketDataLength);

       LongMessagePacketHeader:=TRNLPointer(@BlockPacket.fBlockPacketData[0]);
       LongMessagePacketHeader^.MessageNumber:=TRNLEndianness.HostToLittleEndian16(fOutgoingMessageNumber);
       LongMessagePacketHeader^.Offset:=TRNLEndianness.HostToLittleEndian32(MessagePosition);
       LongMessagePacketHeader^.Length:=TRNLEndianness.HostToLittleEndian32(Message.fDataLength);

       Move(PRNLUInt8Array(TRNLPointer(Message.fData))^[MessagePosition],
            BlockPacket.fBlockPacketData[SizeOf(TRNLPeerUnreliableUnorderedChannelLongMessagePacketHeader)],
            MessagePartLength);

      finally
       fPeer.fOutgoingBlockPackets.Enqueue(BlockPacket);
      end;

      inc(MessagePosition,MessagePartLength);

     end;

     inc(fOutgoingMessageNumber);

    end;

   end;

  finally
   Message.DecRef;
  end;

 end;
end;

procedure TRNLPeerUnreliableUnorderedChannel.DispatchIncomingBlockPacket(const aBlockPacket:TRNLPeerBlockPacket);
var ChannelCommandType:TRNLPeerUnreliableUnorderedChannelCommandType;
    BlockPacketDataPosition,BlockDataLength,FragmentOffset,Index:TRNLSizeUInt;
    LongMessagePacketHeader:PRNLPeerUnreliableUnorderedChannelLongMessagePacketHeader;
begin

 BlockPacketDataPosition:=0;

 ChannelCommandType:=TRNLPeerUnreliableUnorderedChannelCommandType(TRNLInt32(aBlockPacket.fBlockPacket.Channel.Header.TypeAndSubtype shr 4));

 case ChannelCommandType of

  RNL_PEER_UNRELIABLE_UNORDERED_CHANNEL_COMMAND_TYPE_SHORT_MESSAGE:begin

   if (BlockPacketDataPosition+TRNLSizeUInt(SizeOf(TRNLPeerUnreliableUnorderedChannelShortMessagePacketHeader)))>aBlockPacket.fBlockPacketDataLength then begin
    exit;
   end;

   BlockPacketDataPosition:=SizeOf(TRNLPeerUnreliableUnorderedChannelShortMessagePacketHeader);
   BlockDataLength:=aBlockPacket.fBlockPacketDataLength-BlockPacketDataPosition;

   if (BlockPacketDataPosition+BlockDataLength)>aBlockPacket.fBlockPacketDataLength then begin
    exit;
   end;

   fIncomingMessageQueue.Enqueue(TRNLMessage.CreateFromMemory(TRNLPointer(@aBlockPacket.fBlockPacketData[BlockPacketDataPosition]),
                                                              BlockDataLength,
                                                              []));

  end;

  RNL_PEER_UNRELIABLE_UNORDERED_CHANNEL_COMMAND_TYPE_LONG_MESSAGE:begin

   if (BlockPacketDataPosition+(SizeOf(TRNLPeerUnreliableUnorderedChannelLongMessagePacketHeader)-1))>=aBlockPacket.fBlockPacketDataLength then begin
    exit;
   end;

   LongMessagePacketHeader:=TRNLPointer(@aBlockPacket.fBlockPacketData[BlockPacketDataPosition]);

   LongMessagePacketHeader^.MessageNumber:=TRNLEndianness.LittleEndianToHost16(LongMessagePacketHeader^.MessageNumber);
   LongMessagePacketHeader^.Offset:=TRNLEndianness.LittleEndianToHost32(LongMessagePacketHeader^.Offset);
   LongMessagePacketHeader^.Length:=TRNLEndianness.LittleEndianToHost32(LongMessagePacketHeader^.Length);

   if fIncomingMessageNumber<>LongMessagePacketHeader^.MessageNumber then begin

    fIncomingMessageNumber:=LongMessagePacketHeader^.MessageNumber;

    fIncomingReceivedMessageDataLength:=0;

    fIncomingMessageLength:=LongMessagePacketHeader^.Length;

    if assigned(fIncomingMessageReceiveBufferData) then begin
     FreeMem(fIncomingMessageReceiveBufferData);
     fIncomingMessageReceiveBufferData:=nil;
    end;

    if assigned(fIncomingMessageReceiveBufferFlagData) then begin
     FreeMem(fIncomingMessageReceiveBufferFlagData);
     fIncomingMessageReceiveBufferFlagData:=nil;
    end;

    GetMem(fIncomingMessageReceiveBufferData,LongMessagePacketHeader^.Length);

    GetMem(fIncomingMessageReceiveBufferFlagData,LongMessagePacketHeader^.Length);

    FillChar(fIncomingMessageReceiveBufferFlagData^,LongMessagePacketHeader^.Length,#0);

   end else begin

    if (fIncomingMessageNumber<>LongMessagePacketHeader^.MessageNumber) or
       (not assigned(fIncomingMessageReceiveBufferData)) or
       (fIncomingMessageLength<>LongMessagePacketHeader^.Length) then begin
     // Reject, it is anyway on an unreliable channel
     fIncomingMessageLength:=0;
     if assigned(fIncomingMessageReceiveBufferData) then begin
      FreeMem(fIncomingMessageReceiveBufferData);
      fIncomingMessageReceiveBufferData:=nil;
     end;
     if assigned(fIncomingMessageReceiveBufferFlagData) then begin
      FreeMem(fIncomingMessageReceiveBufferFlagData);
      fIncomingMessageReceiveBufferFlagData:=nil;
     end;
     exit;
    end;

   end;

   if not (assigned(fIncomingMessageReceiveBufferData) and
           assigned(fIncomingMessageReceiveBufferFlagData)) then begin
    fIncomingReceivedMessageDataLength:=0;
   end;

   BlockPacketDataPosition:=SizeOf(TRNLPeerUnreliableUnorderedChannelLongMessagePacketHeader);
   BlockDataLength:=aBlockPacket.fBlockPacketDataLength-BlockPacketDataPosition;

   if (BlockPacketDataPosition+BlockDataLength)>aBlockPacket.fBlockPacketDataLength then begin
    fIncomingMessageLength:=0;
    if assigned(fIncomingMessageReceiveBufferData) then begin
     FreeMem(fIncomingMessageReceiveBufferData);
     fIncomingMessageReceiveBufferData:=nil;
    end;
    if assigned(fIncomingMessageReceiveBufferFlagData) then begin
     FreeMem(fIncomingMessageReceiveBufferFlagData);
     fIncomingMessageReceiveBufferFlagData:=nil;
    end;
    exit;
   end;

   FragmentOffset:=LongMessagePacketHeader^.Offset;

   if (FragmentOffset+BlockDataLength)>fIncomingMessageLength then begin
    fIncomingMessageLength:=0;
    if assigned(fIncomingMessageReceiveBufferData) then begin
     FreeMem(fIncomingMessageReceiveBufferData);
     fIncomingMessageReceiveBufferData:=nil;
    end;
    if assigned(fIncomingMessageReceiveBufferFlagData) then begin
     FreeMem(fIncomingMessageReceiveBufferFlagData);
     fIncomingMessageReceiveBufferFlagData:=nil;
    end;
    exit;
   end;

   for Index:=FragmentOffset to FragmentOffset+(BlockDataLength-1) do begin
    if PRNLUInt8Array(TRNLPointer(fIncomingMessageReceiveBufferFlagData))^[Index]<>0 then begin
     fIncomingMessageLength:=0;
     if assigned(fIncomingMessageReceiveBufferData) then begin
      FreeMem(fIncomingMessageReceiveBufferData);
      fIncomingMessageReceiveBufferData:=nil;
     end;
     if assigned(fIncomingMessageReceiveBufferFlagData) then begin
      FreeMem(fIncomingMessageReceiveBufferFlagData);
      fIncomingMessageReceiveBufferFlagData:=nil;
     end;
     exit;
    end;
   end;

   Move(aBlockPacket.fBlockPacketData[BlockPacketDataPosition],
        PRNLUInt8Array(TRNLPointer(fIncomingMessageReceiveBufferData))^[FragmentOffset],
        BlockDataLength);

   FillChar(PRNLUInt8Array(TRNLPointer(fIncomingMessageReceiveBufferFlagData))^[FragmentOffset],
            BlockDataLength,
            #$ff);

   inc(fIncomingReceivedMessageDataLength,BlockDataLength);

   if fIncomingReceivedMessageDataLength=fIncomingMessageLength then begin
    fIncomingMessageQueue.Enqueue(TRNLMessage.CreateFromMemory(fIncomingMessageReceiveBufferData,
                                                               fIncomingMessageLength,
                                                               [RNL_MESSAGE_FLAG_NO_ALLOCATE]));
    fIncomingMessageLength:=0;
    fIncomingMessageReceiveBufferData:=nil;
    if assigned(fIncomingMessageReceiveBufferFlagData) then begin
     FreeMem(fIncomingMessageReceiveBufferFlagData);
     fIncomingMessageReceiveBufferFlagData:=nil;
    end;
   end;

  end;

  else begin

   fIncomingMessageLength:=0;
   if assigned(fIncomingMessageReceiveBufferData) then begin
    FreeMem(fIncomingMessageReceiveBufferData);
    fIncomingMessageReceiveBufferData:=nil;
   end;
   if assigned(fIncomingMessageReceiveBufferFlagData) then begin
    FreeMem(fIncomingMessageReceiveBufferFlagData);
    fIncomingMessageReceiveBufferFlagData:=nil;
   end;

  end;

 end;

end;

constructor TRNLPeer.Create(const aHost:TRNLHost);
begin
 inherited Create;

 fValue:=self;

 fHost:=aHost;

 fHost.fPeerLock.Acquire;
 try

  fLocalPeerID:=fHost.fPeerIDManager.AllocateID;

  fRemotePeerID:=0;

{$if defined(RNL_LINEAR_PEER_LIST)}
  fPeerListIndex:=fHost.fPeerList.Add(self);
{$else}
  fHost.fPeerList.Add(self);
{$ifend}

  inc(fHost.fCountPeers);

  fHost.fPeerIDMap[fLocalPeerID]:=self;

  fPeerToFreeListNode:=TRNLPeerListNode.Create;
  fPeerToFreeListNode.fValue:=nil;

 finally
  fHost.fPeerLock.Release;
 end;

 fReferenceCounter:=1;

 fCurrentThreadIndex:=0;

 fIncomingPacketQueue:=TRNLPeerIncomingPacketQueue.Create;

 fChannels:=TRNLPeerChannelList.Create(true);

 fAddress.Host:=RNL_HOST_ANY;
 fAddress.Port:=0;

 fPointerToAddress:=@fAddress;

 fRemoteHostSalt:=0;

 fMTU:=fHost.fMTU;

 fOutgoingEncryptedPacketSequenceNumber:=0;
 fIncomingEncryptedPacketSequenceNumber:=0;
 fIncomingEncryptedPacketSequenceBuffer:=nil;

 fNextCheckTimeoutsTimeout:=0;

 fNextReliableBlockPacketTimeout:=0;

 fNextPendingConnectionSendTimeout:=0;

 fNextPendingConnectionSaltTimeout:=0;

 fNextPendingConnectionShortTermKeyPairTimeout:=0;

 fNextPendingDisconnectionSendTimeout:=0;

 fDisconnectionTimeout:=0;

 fDisconnectionSequenceNumber:=0;

 fDisconnectData:=0;

 fPendingConnectionHandshakeSendData:=nil;

 fConnectionChallengeResponse:=nil;

 fConnectionToken:=nil;

 fAuthenticationToken:=nil;

 fUnacknowlegmentedBlockPackets:=0;

 fRoundTripTimeFirst:=true;

 fRoundTripTime:=TRNLUInt64(aHost.fDefaultRoundTripTime) shl 32;

 fRoundTripTimeVariance:=0;

 fRetransmissionTimeout:=TRNLUInt64(aHost.fDefaultRoundTripTime) shl 32;

 fPacketLoss:=0;

 fPacketLossVariance:=0;

 fCountPacketLoss:=0;

 fCountSentPackets:=0;

 fLastPacketLossUpdateTime:=fHost.fTime;

 fLastSentDataTime:=fHost.fTime;

 fLastReceivedDataTime:=fHost.fTime;

 fLastPingSentTime:=fHost.fTime;

 fNextPingSendTime:=0;

 fNextPingResendTime:=0;

 fIncomingPongSequenceNumber:=0;

 fOutgoingPingSequenceNumber:=0;

 fKeepAliveWindowItems:=nil;
 SetLength(fKeepAliveWindowItems,fHost.fKeepAliveWindowSize);
 FillChar(fKeepAliveWindowItems[0],fHost.fKeepAliveWindowSize*SizeOf(TRNLPeerKeepAliveWindowItem),#0);

 fIncomingBlockPackets:=TRNLPeerBlockPacketQueue.Create;

 fOutgoingBlockPackets:=TRNLPeerBlockPacketQueue.Create;

 fOutgoingMTUProbeBlockPackets:=TRNLPeerBlockPacketQueue.Create;

 fDeferredOutgoingBlockPackets:=TRNLPeerBlockPacketQueue.Create;

 fState:=RNL_PEER_STATE_DISCONNECTED;

 fRemoteIncomingBandwidthLimit:=0;

 fRemoteOutgoingBandwidthLimit:=0;

 fMTUProbeIndex:=-1;

 fMTUProbeSequenceNumber:=$ffff;

 fSendNewHostBandwidthLimits:=false;

 fReceivedNewHostBandwidthLimitsSequenceNumber:=$ff;

 fSendNewHostBandwidthLimitsSequenceNumber:=$ff;

 fIncomingBandwidthRateTracker.Reset;

 fOutgoingBandwidthRateTracker.Reset;

 fIncomingBandwidthRateTracker.SetTime(fHost.fTime);

 fOutgoingBandwidthRateTracker.SetTime(fHost.fTime);

 fIncomingBandwidthRateTracker.Update;

 fOutgoingBandwidthRateTracker.Update;

 UpdateOutgoingBandwidthRateLimiter;

 fOutgoingBandwidthRateLimiter.Reset(fHost.fTime);

end;

destructor TRNLPeer.Destroy;
var BlockPacket:TRNLPeerBlockPacket;
begin

 fHost.fPeerLock.Acquire;
 try

  try
   fPeerToFreeListNode.Remove;
  finally
   FreeAndNil(fPeerToFreeListNode);
  end;

  if assigned(fConnectionChallengeResponse) then begin
   FreeMem(fConnectionChallengeResponse);
   fConnectionChallengeResponse:=nil;
  end;

  if assigned(fConnectionToken) then begin
   FreeMem(fConnectionToken);
   fConnectionToken:=nil;
  end;

  if assigned(fAuthenticationToken) then begin
   FreeMem(fAuthenticationToken);
   fAuthenticationToken:=nil;
  end;

  fIncomingEncryptedPacketSequenceBuffer:=nil;

  while fDeferredOutgoingBlockPackets.Dequeue(BlockPacket) do begin
   BlockPacket.DecRef;
  end;
  FreeAndNil(fDeferredOutgoingBlockPackets);

  while fOutgoingMTUProbeBlockPackets.Dequeue(BlockPacket) do begin
   BlockPacket.DecRef;
  end;
  FreeAndNil(fOutgoingMTUProbeBlockPackets);

  while fOutgoingBlockPackets.Dequeue(BlockPacket) do begin
   BlockPacket.DecRef;
  end;
  FreeAndNil(fOutgoingBlockPackets);

  while fIncomingBlockPackets.Dequeue(BlockPacket) do begin
   BlockPacket.DecRef;
  end;
  FreeAndNil(fIncomingBlockPackets);

  FreeAndNil(fPendingConnectionHandshakeSendData);

  FreeAndNil(fChannels);

  FreeAndNil(fIncomingPacketQueue);

  fKeepAliveWindowItems:=nil;

  dec(fHost.fCountPeers);

  fHost.fPeerIDMap[fLocalPeerID]:=nil;

  fHost.fPeerIDManager.FreeID(fLocalPeerID);

{$if defined(RNL_LINEAR_PEER_LIST)}

  if fPeerListIndex<>(fHost.fPeerList.Count-1) then begin
   fHost.fPeerList[fHost.fPeerList.Count-1].fPeerListIndex:=fPeerListIndex;
   fHost.fPeerList.Exchange(fHost.fPeerList.Count-1,fPeerListIndex);
  end;

  fPeerListIndex:=-1;

  fHost.fPeerList.Delete(fHost.fPeerList.Count-1);

{$else}
  Remove;
{$ifend}

 finally
  fHost.fPeerLock.Release;
 end;

 inherited Destroy;
end;

procedure TRNLPeer.IncRef;
begin
 {$ifdef fpc}InterlockedIncrement{$else}AtomicIncrement{$endif}(TRNLInt32(fReferenceCounter));
end;

procedure TRNLPeer.DecRef;
begin
 if assigned(self) and
    ({$ifdef fpc}InterlockedDecrement{$else}AtomicDecrement{$endif}(TRNLInt32(fReferenceCounter))=0) then begin
  Free;
 end;
end;

procedure TRNLPeer.UpdateOutgoingBandwidthRateLimiter;
begin
 fOutgoingBandwidthRateLimiter.Setup(fRemoteIncomingBandwidthLimit,1000);
end;

function TRNLPeer.GetIncomingBandwidthRate:TRNLUInt32;
begin
 result:=fIncomingBandwidthRateTracker.UnitsPerSecond;
end;

function TRNLPeer.GetOutgoingBandwidthRate:TRNLUInt32;
begin
 result:=fOutgoingBandwidthRateTracker.UnitsPerSecond;
end;

function TRNLPeer.GetCountChannels:TRNLSizeInt;
begin
 result:=fCountChannels;
end;

procedure TRNLPeer.SetCountChannels(aCountChannels:TRNLSizeInt);
var ChannelNumber:TRNLSizeInt;
begin
 fCountChannels:=aCountChannels;
 while fChannels.Count>aCountChannels do begin
  fChannels.Delete(fChannels.Count-1);
 end;
 while fChannels.Count<aCountChannels do begin
  ChannelNumber:=fChannels.Count;
  case fHost.fChannelTypes[ChannelNumber] of
   RNL_PEER_RELIABLE_ORDERED_CHANNEL:begin
    fChannels.Add(TRNLPeerReliableOrderedChannel.Create(self,ChannelNumber));
   end;
   RNL_PEER_RELIABLE_UNORDERED_CHANNEL:begin
    fChannels.Add(TRNLPeerReliableUnorderedChannel.Create(self,ChannelNumber));
   end;
   RNL_PEER_UNRELIABLE_ORDERED_CHANNEL:begin
    fChannels.Add(TRNLPeerUnreliableOrderedChannel.Create(self,ChannelNumber));
   end;
   RNL_PEER_UNRELIABLE_UNORDERED_CHANNEL:begin
    fChannels.Add(TRNLPeerUnreliableUnorderedChannel.Create(self,ChannelNumber));
   end;
   else begin
    Assert(false);
    break;
   end;
  end;
 end;
end;

procedure TRNLPeer.UpdateRoundTripTime(const aRoundTripTime:TRNLInt64);
var ValueError:TRNLInt64;
begin
 if fRoundTripTimeFirst then begin
  fRoundTripTimeFirst:=false;
  fRoundTripTime:=aRoundTripTime shl 32;
  fRoundTripTimeVariance:=0;
 end else begin
  ValueError:=(aRoundTripTime shl 32)-fRoundTripTime;
  inc(fRoundTripTime,SARInt64(ValueError,3));
  inc(fRoundTripTimeVariance,SARInt64(abs(ValueError),2)-SARInt64(fRoundTripTimeVariance,2));
 end;
 fRetransmissionTimeout:=fRoundTripTime+(fRoundTripTimeVariance shl 2);
end;

procedure TRNLPeer.UpdatePatchLossStatistics;
var Value64Bit:TRNLInt64;
begin

 if fLastPacketLossUpdateTime.fValue=0 then begin

  fLastPacketLossUpdateTime:=fHost.fTime;

 end else if (TRNLTime.Difference(fHost.fTime,fLastPacketLossUpdateTime)>=RNL_PEER_PACKET_LOSS_INTERVAL) and
             (fCountSentPackets>0) then begin

  // Jacobson's variance algorithm with 32.32bit fixed point
  // Error = Measured - OldPrediction
  // NewPrediction = OldPrediction + (Error / 8)
  //               = (OldPrediction * (7 / 8)) + (Measured / 8)
  // NewVariation = (OldVariation - (OldVariation / 4)) + (Error / 4)
  //              = (OldVariation * (3 / 4)) + (Error / 4)
  // RTO = Prediction + (Variation * 4)
  Value64Bit:=((TRNLInt64(fCountPacketLoss) shl 32) div TRNLInt64(fCountSentPackets))-fPacketLoss;
  inc(fPacketLoss,SARInt64(Value64Bit,3));
  inc(fPacketLossVariance,SARInt64(abs(Value64Bit),2)-SARInt64(fPacketLossVariance,2));

{$if defined(RNL_DEBUG)}
  fHost.fInstance.fDebugLock.Acquire;
  try
   RNLDebugOutputString('Peer '+IntToStr(fLocalPeerID)+': '+ //' [',TypInfo.GetEnumName(TypeInfo(TRNLPeerState),TRNLInt32(fState)),']: ',
                        IntToStr(fCountPacketLoss)+' Packets lost at last measured time frame, '+
                        RNLDebugFormatFloat(fPacketLoss*OneDiv32Bit,1,8)+'+-'+
                        RNLDebugFormatFloat(fPacketLossVariance*OneDiv32Bit,1,8)+
                        ' Packet loss, '+
                        RNLDebugFormatFloat(fRoundTripTime*OneDiv32Bit,1,2)+'+-'+RNLDebugFormatFloat(fRoundTripTimeVariance*OneDiv32Bit,1,2)+
                        ' ms round trip time, '+
                        RNLDebugFormatFloat(fIncomingBandwidthRateTracker.UnitsPerSecond/1024.0,1,3)+
                        ' incoming kbps, '+
                        RNLDebugFormatFloat(fOutgoingBandwidthRateTracker.UnitsPerSecond/1024.0,1,3)+
                        ' outgoing kbps');
  finally
   fHost.fInstance.fDebugLock.Release;
  end;
{$ifend}

  fCountPacketLoss:=0;

  fCountSentPackets:=0;

  fLastPacketLossUpdateTime:=fHost.fTime;

 end;

end;

procedure TRNLPeer.DispatchIncomingMTUProbeBlockPacket(const aIncomingBlockPacket:TRNLPeerBlockPacket);
var OutgoingBlockPacket:TRNLPeerBlockPacket;
    HostEvent:TRNLHostEvent;
begin

{$if defined(RNL_DEBUG) and defined(RNL_DEBUG_MTU)}
 fHost.fInstance.fDebugLock.Acquire;
 try
  RNLDebugOutputString('Peer '+IntToStr(fLocalPeerID)+': '+
                       'Incoming MTU probe with phase '+IntToStr(aIncomingBlockPacket.fBlockPacket.MTUProbe.Phase)+' '+
                       'and MTU size '+IntToStr(TRNLEndianness.LittleEndianToHost16(aIncomingBlockPacket.fBlockPacket.MTUProbe.Size)));
 finally
  fHost.fInstance.fDebugLock.Release;
 end;
{$ifend}

 if ((aIncomingBlockPacket.fBlockPacket.MTUProbe.Phase and 1)<>0) and
    (TRNLEndianness.LittleEndianToHost16(aIncomingBlockPacket.fBlockPacket.MTUProbe.SequenceNumber)<>fMTUProbeSequenceNumber.fValue) then begin
  exit;
 end;

 case aIncomingBlockPacket.fBlockPacket.MTUProbe.Phase of
  2:begin
   fMTU:=TRNLEndianness.LittleEndianToHost16(aIncomingBlockPacket.fBlockPacket.MTUProbe.Size);
   if assigned(fHost.fOnPeerMTU) then begin
    fHost.fOnPeerMTU(fHost,self,fMTU);
   end else begin
    HostEvent.Initialize;
    try
     HostEvent.Type_:=RNL_HOST_EVENT_TYPE_PEER_MTU;
     HostEvent.Peer:=self;
     HostEvent.Peer.IncRef;
     HostEvent.Message:=nil;
     HostEvent.MTU:=fMTU;
    finally
     fHost.fEventQueue.Enqueue(HostEvent);
    end;
   end;
  end;
  3..$ff:begin
   fMTU:=TRNLEndianness.LittleEndianToHost16(aIncomingBlockPacket.fBlockPacket.MTUProbe.Size);
   if assigned(fHost.fOnPeerMTU) then begin
    fHost.fOnPeerMTU(fHost,self,fMTU);
   end else begin
    HostEvent.Initialize;
    try
     HostEvent.Type_:=RNL_HOST_EVENT_TYPE_PEER_MTU;
     HostEvent.Peer:=self;
     HostEvent.Peer.IncRef;
     HostEvent.Message:=nil;
     HostEvent.MTU:=fMTU;
    finally
     fHost.fEventQueue.Enqueue(HostEvent);
    end;
   end;
   fMTUProbeIndex:=-1;
   fMTUProbeNextTimeout:=0;
   exit;
  end;
 end;

 if aIncomingBlockPacket.fBlockPacket.MTUProbe.Phase<5 then begin
  OutgoingBlockPacket:=TRNLPeerBlockPacket.Create(self);
  try
   OutgoingBlockPacket.fBlockPacket.Header.TypeAndSubtype:=TRNLInt32(TRNLProtocolBlockPacketType(RNL_PROTOCOL_BLOCK_PACKET_TYPE_MTU_PROBE));
   OutgoingBlockPacket.fBlockPacket.MTUProbe.SequenceNumber:=aIncomingBlockPacket.fBlockPacket.MTUProbe.SequenceNumber;
   OutgoingBlockPacket.fBlockPacket.MTUProbe.Phase:=aIncomingBlockPacket.fBlockPacket.MTUProbe.Phase+1;
   OutgoingBlockPacket.fBlockPacket.MTUProbe.Size:=aIncomingBlockPacket.fBlockPacket.MTUProbe.Size;
   OutgoingBlockPacket.fBlockPacketDataLength:=TRNLEndianness.LittleEndianToHost16(aIncomingBlockPacket.fBlockPacket.MTUProbe.Size)-(RNL_IP_HEADER_SIZE+
                                                                                                                                     RNL_UDP_HEADER_SIZE+
                                                                                                                                     SizeOf(TRNLProtocolNormalPacketHeader)+
                                                                                                                                     SizeOf(TRNLProtocolBlockPacketMTUProbe));
   SetLength(OutgoingBlockPacket.fBlockPacketData,OutgoingBlockPacket.fBlockPacketDataLength);
   OutgoingBlockPacket.fBlockPacket.MTUProbe.PayloadDataLength:=TRNLEndianness.LittleEndianToHost16(OutgoingBlockPacket.fBlockPacketDataLength);
   if OutgoingBlockPacket.fBlockPacketDataLength>0 then begin
    fHost.fRandomGenerator.GetRandomBytes(OutgoingBlockPacket.fBlockPacketData[0],OutgoingBlockPacket.fBlockPacketDataLength);
   end;
  finally
   fOutgoingMTUProbeBlockPackets.Enqueue(OutgoingBlockPacket);
  end;
 end;

end;

procedure TRNLPeer.DispatchIncomingBlockPackets;
var IncomingBlockPacket,OutgoingBlockPacket:TRNLPeerBlockPacket;
    HostEvent:TRNLHostEvent;
    KeepAliveWindowItem,OtherKeepAliveWindowItem:PRNLPeerKeepAliveWindowItem;
begin

 while fIncomingBlockPackets.Dequeue(IncomingBlockPacket) do begin

  try

   case TRNLProtocolBlockPacketType(TRNLInt32(IncomingBlockPacket.fBlockPacket.Header.TypeAndSubtype and $f)) of

    RNL_PROTOCOL_BLOCK_PACKET_TYPE_NONE:begin
    end;

    RNL_PROTOCOL_BLOCK_PACKET_TYPE_PING:begin

     OutgoingBlockPacket:=TRNLPeerBlockPacket.Create(self);
     try
      OutgoingBlockPacket.fBlockPacket.Header.TypeAndSubtype:=TRNLInt32(TRNLProtocolBlockPacketType(RNL_PROTOCOL_BLOCK_PACKET_TYPE_PONG));
      OutgoingBlockPacket.fBlockPacket.Pong.SequenceNumber:=IncomingBlockPacket.fBlockPacket.Ping.SequenceNumber;
      OutgoingBlockPacket.fBlockPacket.Pong.SentTime:=TRNLEndianness.HostToLittleEndian16(TRNLUInt16(IncomingBlockPacket.fSentTime.fValue));
     finally
      fOutgoingBlockPackets.Enqueue(OutgoingBlockPacket);
     end;

{$if defined(RNL_DEBUG) and defined(RNL_DEBUG_PING)}
     fHost.fInstance.fDebugLock.Acquire;
     try
      RNLDebugOutputString('Peer '+IntToStr(fLocalPeerID)+': '+
                           'Incoming ping '+IntToStr(IncomingBlockPacket.fBlockPacket.Ping.SequenceNumber)+
                           ' => Outgoing pong '+IntToStr(IncomingBlockPacket.fBlockPacket.Ping.SequenceNumber));
     finally
      fHost.fInstance.fDebugLock.Release;
     end;
{$ifend}

    end;

    RNL_PROTOCOL_BLOCK_PACKET_TYPE_PONG:begin

     if IncomingBlockPacket.fBlockPacket.Pong.SequenceNumber=1 then begin
      if IncomingBlockPacket.fBlockPacket.Pong.SequenceNumber=1 then begin
      end;
     end;

     KeepAliveWindowItem:=@fKeepAliveWindowItems[IncomingBlockPacket.fBlockPacket.Pong.SequenceNumber and fHost.fKeepAliveWindowMask];

     if (KeepAliveWindowItem^.State=RNL_PEER_KEEP_ALIVE_WINDOW_ITEM_STATE_SENT) and
        (KeepAliveWindowItem^.SequenceNumber=IncomingBlockPacket.fBlockPacket.Pong.SequenceNumber) then begin

      KeepAliveWindowItem^.State:=RNL_PEER_KEEP_ALIVE_WINDOW_ITEM_STATE_ACKNOWLEDGED;

      repeat
       OtherKeepAliveWindowItem:=@fKeepAliveWindowItems[fIncomingPongSequenceNumber and fHost.fKeepAliveWindowMask];;
       if (OTherKeepAliveWindowItem^.State=RNL_PEER_KEEP_ALIVE_WINDOW_ITEM_STATE_ACKNOWLEDGED) and
          (OtherKeepAliveWindowItem^.SequenceNumber=fIncomingPongSequenceNumber) then begin
        OtherKeepAliveWindowItem^.State:=RNL_PEER_KEEP_ALIVE_WINDOW_ITEM_STATE_FREE;
        inc(fIncomingPongSequenceNumber);
       end else begin
        break;
       end;
      until false;

      UpdateRoundTripTime(abs(TRNLInt16(TRNLInt16(fHost.fTime.fValue-IncomingBlockPacket.fBlockPacket.Pong.SentTime))));

{$if defined(RNL_DEBUG) and defined(RNL_DEBUG_PING)}
      fHost.fInstance.fDebugLock.Acquire;
      try
       RNLDebugOutputString('Peer '+IntToStr(fLocalPeerID)+': Incoming pong '+IntToStr(IncomingBlockPacket.fBlockPacket.Pong.SequenceNumber));
      finally
       fHost.fInstance.fDebugLock.Release;
      end;
{$ifend}

     end else begin

{$if defined(RNL_DEBUG) and defined(RNL_DEBUG_PING)}
      fHost.fInstance.fDebugLock.Acquire;
      try
       RNLDebugOutputString('Peer '+IntToStr(fLocalPeerID)+': Incoming ignored pong '+IntToStr(IncomingBlockPacket.fBlockPacket.Pong.SequenceNumber));
      finally
       fHost.fInstance.fDebugLock.Release;
      end;
{$ifend}

     end;

    end;

    RNL_PROTOCOL_BLOCK_PACKET_TYPE_DISCONNECT:begin

     if fState<>RNL_PEER_STATE_DISCONNECTION_ACKNOWLEDGING then begin
      fState:=RNL_PEER_STATE_DISCONNECTION_ACKNOWLEDGING;
      fDisconnectData:=IncomingBlockPacket.fBlockPacket.Disconnect.Data;
      fDisconnectionSequenceNumber:=0;
     end;

     fNextPendingDisconnectionSendTimeout.fValue:=0;

    end;

    RNL_PROTOCOL_BLOCK_PACKET_TYPE_DISCONNECT_ACKNOWLEGDEMENT:begin

     fState:=RNL_PEER_STATE_DISCONNECTION_ACKNOWLEDGING;

     fDisconnectionSequenceNumber:=IncomingBlockPacket.fBlockPacket.DisconnectAcknowledgement.SequenceNumber;

     fNextPendingDisconnectionSendTimeout.fValue:=0;

    end;

    RNL_PROTOCOL_BLOCK_PACKET_TYPE_BANDWIDTH_LIMITS:begin

     OutgoingBlockPacket:=TRNLPeerBlockPacket.Create(self);
     try
      OutgoingBlockPacket.fBlockPacket.Header.TypeAndSubtype:=TRNLInt32(TRNLProtocolBlockPacketType(RNL_PROTOCOL_BLOCK_PACKET_TYPE_BANDWIDTH_LIMITS_ACKNOWLEGDEMENT));
      OutgoingBlockPacket.fBlockPacket.BandwidthLimitsAcknowledgement.SequenceNumber:=IncomingBlockPacket.fBlockPacket.BandwidthLimitsAcknowledgement.SequenceNumber;
     finally
      fOutgoingBlockPackets.Enqueue(OutgoingBlockPacket);
     end;

     if TRNLInt8(TRNLUInt8(IncomingBlockPacket.fBlockPacket.BandwidthLimitsAcknowledgement.SequenceNumber-fReceivedNewHostBandwidthLimitsSequenceNumber))>=0 then begin

      fReceivedNewHostBandwidthLimitsSequenceNumber:=IncomingBlockPacket.fBlockPacket.BandwidthLimitsAcknowledgement.SequenceNumber;

      fRemoteIncomingBandwidthLimit:=TRNLEndianness.HostToLittleEndian32(IncomingBlockPacket.fBlockPacket.BandwidthLimits.IncomingBandwidthLimit);
      fRemoteOutgoingBandwidthLimit:=TRNLEndianness.HostToLittleEndian32(IncomingBlockPacket.fBlockPacket.BandwidthLimits.OutgoingBandwidthLimit);

      UpdateOutgoingBandwidthRateLimiter;

      if assigned(fHost.fOnPeerBandwidthLimits) then begin
       fHost.fOnPeerBandwidthLimits(fHost,self);
      end else begin
       HostEvent.Initialize;
       try
        HostEvent.Type_:=RNL_HOST_EVENT_TYPE_PEER_BANDWIDTH_LIMITS;
        HostEvent.Peer:=self;
        HostEvent.Peer.IncRef;
        HostEvent.Message:=nil;
       finally
        fHost.fEventQueue.Enqueue(HostEvent);
       end;
      end;

     end;

    end;

    RNL_PROTOCOL_BLOCK_PACKET_TYPE_BANDWIDTH_LIMITS_ACKNOWLEGDEMENT:begin

     if IncomingBlockPacket.fBlockPacket.BandwidthLimitsAcknowledgement.SequenceNumber=fSendNewHostBandwidthLimitsSequenceNumber then begin
      fSendNewHostBandwidthLimits:=false;
     end;

    end;

    RNL_PROTOCOL_BLOCK_PACKET_TYPE_MTU_PROBE:begin

     DispatchIncomingMTUProbeBlockPacket(IncomingBlockPacket);

    end;

    RNL_PROTOCOL_BLOCK_PACKET_TYPE_CHANNEL:begin

     if (fState=RNL_PEER_STATE_CONNECTED) and
        (IncomingBlockPacket.fBlockPacket.Channel.ChannelNumber<fCountChannels) then begin

      fChannels[IncomingBlockPacket.fBlockPacket.Channel.ChannelNumber].DispatchIncomingBlockPacket(IncomingBlockPacket);

     end;

    end;

   end;

  finally
   IncomingBlockPacket.DecRef;
  end;

 end;

end;

procedure TRNLPeer.DispatchStateActions;
var OutgoingBlockPacket:TRNLPeerBlockPacket;
    HostEvent:TRNLHostEvent;
begin

 case fState of

  RNL_PEER_STATE_CONNECTION_REQUESTING,
  RNL_PEER_STATE_CONNECTION_CHALLENGING,
  RNL_PEER_STATE_CONNECTION_AUTHENTICATING,
  RNL_PEER_STATE_CONNECTION_APPROVING:begin

   // Connection handshake state machine flow

   if fHost.fTime>=fNextPendingConnectionSendTimeout then begin

    fNextPendingConnectionSendTimeout:=fHost.fTime+fHost.fPendingConnectionSendTimeout;

    case fState of
     RNL_PEER_STATE_CONNECTION_REQUESTING:begin
      if assigned(fPendingConnectionHandshakeSendData) and
         (fPendingConnectionHandshakeSendData.fHandshakePacket.Header.PacketType=TRNLUInt32(TRNLProtocolHandshakePacketType(RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_REQUEST))) then begin
       if (fNextPendingConnectionSaltTimeout.fValue=0) or
          (fHost.fTime>=fNextPendingConnectionSaltTimeout) then begin
        fNextPendingConnectionSaltTimeout:=fHost.fTime+fHost.fPendingConnectionSaltTimeout;
        fLocalSalt:=fHost.fRandomGenerator.GetUInt64;
        fConnectionSalt:=fLocalSalt;
        fChecksumPlaceHolder:=fConnectionSalt xor (fConnectionSalt shl 32);
        fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionRequest.OutgoingSalt:=TRNLEndianness.HostToLittleEndian64(fLocalSalt);
       end;
       fPendingConnectionHandshakeSendData.Send;
      end else begin
       fState:=RNL_PEER_STATE_DISCONNECTED;
      end;
     end;
     RNL_PEER_STATE_CONNECTION_CHALLENGING:begin
      if assigned(fPendingConnectionHandshakeSendData) and
         (fPendingConnectionHandshakeSendData.fHandshakePacket.Header.PacketType=TRNLUInt32(TRNLProtocolHandshakePacketType(RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_CHALLENGE_RESPONSE))) then begin
       if (fNextPendingConnectionShortTermKeyPairTimeout.fValue=0) or
          (fHost.fTime>=fNextPendingConnectionShortTermKeyPairTimeout) then begin
        fNextPendingConnectionShortTermKeyPairTimeout:=fHost.fTime+fHost.fPendingConnectionShortTermKeyPairTimeout;
        TRNLX25519.GeneratePublicPrivateKeyPair(fHost.fRandomGenerator,
                                                fLocalShortTermPublicKey,
                                                fLocalShortTermPrivateKey);
        fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionChallengeResponse.ShortTermPublicKey:=fLocalShortTermPublicKey;
       end;
       fPendingConnectionHandshakeSendData.Send;
      end else begin
       fState:=RNL_PEER_STATE_DISCONNECTED;
      end;
     end;
     RNL_PEER_STATE_CONNECTION_AUTHENTICATING:begin
      if assigned(fPendingConnectionHandshakeSendData) and
         (fPendingConnectionHandshakeSendData.fHandshakePacket.Header.PacketType=TRNLUInt32(TRNLProtocolHandshakePacketType(RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_AUTHENTICATION_RESPONSE))) then begin
       fPendingConnectionHandshakeSendData.Send;
      end else begin
       fState:=RNL_PEER_STATE_DISCONNECTED;
      end;
     end;
     RNL_PEER_STATE_CONNECTION_APPROVING:begin
      if assigned(fPendingConnectionHandshakeSendData) and
         (fPendingConnectionHandshakeSendData.fHandshakePacket.Header.PacketType=TRNLUInt32(TRNLProtocolHandshakePacketType(RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_APPROVAL_RESPONSE))) then begin
       fPendingConnectionHandshakeSendData.Send;
      end else begin
       fState:=RNL_PEER_STATE_DISCONNECTED;
      end;
     end;
    end;

   end;

   if (fNextPendingConnectionSendTimeout.Value<>0) and
      (fNextPendingConnectionSendTimeout>=fHost.fTime) then begin
    fHost.fNextPeerEventTime:=TRNLTime.Minimum(fHost.fNextPeerEventTime,fNextPendingConnectionSendTimeout);
   end;

  end;

  RNL_PEER_STATE_CONNECTED:begin

   FreeAndNil(fPendingConnectionHandshakeSendData);

  end;

  RNL_PEER_STATE_DISCONNECT_LATER,
  RNL_PEER_STATE_DISCONNECTING,
  RNL_PEER_STATE_DISCONNECTION_ACKNOWLEDGING,
  RNL_PEER_STATE_DISCONNECTION_PENDING:begin

   // Disconnection state machine flow

   repeat
    case fState of
     RNL_PEER_STATE_DISCONNECT_LATER:begin
      if fOutgoingBlockPackets.IsEmpty and
         (fUnacknowlegmentedBlockPackets=0) then begin
       fState:=RNL_PEER_STATE_DISCONNECTING;
      end else begin
       break;
      end;
     end;
     RNL_PEER_STATE_DISCONNECTING:begin
      if (fDisconnectionTimeout.fValue<>0) and
         (fHost.fTime>=fDisconnectionTimeout) then begin
       fState:=RNL_PEER_STATE_DISCONNECTION_PENDING;
      end else if (fNextPendingDisconnectionSendTimeout.fValue=0) or
                  (fHost.fTime>=fNextPendingDisconnectionSendTimeout) then begin
       OutgoingBlockPacket:=TRNLPeerBlockPacket.Create(self);
       try
        OutgoingBlockPacket.fBlockPacket.Header.TypeAndSubtype:=TRNLInt32(TRNLProtocolBlockPacketType(RNL_PROTOCOL_BLOCK_PACKET_TYPE_DISCONNECT));
        OutgoingBlockPacket.fBlockPacket.Disconnect.Data:=fDisconnectData;
       finally
        fOutgoingBlockPackets.Enqueue(OutgoingBlockPacket);
       end;
       if fDisconnectionTimeout.fValue=0 then begin
        fDisconnectionTimeout:=fHost.fTime+fHost.fPendingDisconnectionTimeout;
       end;
       fNextPendingDisconnectionSendTimeout:=fHost.fTime+fHost.fPendingDisconnectionSendTimeout;
      end;
      break;
     end;
     RNL_PEER_STATE_DISCONNECTION_ACKNOWLEDGING:begin
      if (fDisconnectionTimeout.fValue<>0) and
         (fHost.fTime>=fDisconnectionTimeout) then begin
       fState:=RNL_PEER_STATE_DISCONNECTION_PENDING;
      end else begin
       if (fNextPendingDisconnectionSendTimeout.fValue=0) or
          (fHost.fTime>=fNextPendingDisconnectionSendTimeout) then begin
        OutgoingBlockPacket:=TRNLPeerBlockPacket.Create(self);
        try
         OutgoingBlockPacket.fBlockPacket.Header.TypeAndSubtype:=TRNLInt32(TRNLProtocolBlockPacketType(RNL_PROTOCOL_BLOCK_PACKET_TYPE_DISCONNECT_ACKNOWLEGDEMENT));
         OutgoingBlockPacket.fBlockPacket.DisconnectAcknowledgement.SequenceNumber:=fDisconnectionSequenceNumber+1;
        finally
         fOutgoingBlockPackets.Enqueue(OutgoingBlockPacket);
        end;
        case fDisconnectionSequenceNumber of
         0,1:begin
          // At this step, we can not be sure yet, that the counterside does know about the disconnection
         end;
         2,3:begin
          // At this step, we can be sure, that the counterside does know about the disconnection
          fDisconnectionSequenceNumber:=4;
         end;
         else begin
          fState:=RNL_PEER_STATE_DISCONNECTION_PENDING;
          continue;
         end;
        end;
        if fDisconnectionTimeout.fValue=0 then begin
         fDisconnectionTimeout:=fHost.fTime+fHost.fPendingDisconnectionTimeout;
        end;
        fNextPendingDisconnectionSendTimeout:=fHost.fTime+fHost.fPendingDisconnectionSendTimeout;
       end;
       break;
      end;
     end;
     RNL_PEER_STATE_DISCONNECTION_PENDING:begin
      fState:=RNL_PEER_STATE_DISCONNECTED;
      if assigned(fHost.fOnPeerDisconnect) then begin
       try
        fHost.fOnPeerDisconnect(fHost,self,fDisconnectData);
       finally
        fHost.fPeerToFreeList.Add(fPeerToFreeListNode);
       end;
      end else begin
       HostEvent.Initialize;
       try
        HostEvent.Type_:=RNL_HOST_EVENT_TYPE_PEER_DISCONNECT;
        HostEvent.Peer:=self;
        HostEvent.Message:=nil;
        HostEvent.Data:=fDisconnectData;
       finally
        fHost.fEventQueue.Enqueue(HostEvent);
       end;
      end;
      break;
     end;
     else begin
      break;
     end;
    end;
   until false;

   if (fDisconnectionTimeout.Value<>0) and
      (fDisconnectionTimeout>=fHost.fTime) then begin
    fHost.fNextPeerEventTime:=TRNLTime.Minimum(fHost.fNextPeerEventTime,fDisconnectionTimeout);
   end;

   if (fNextPendingDisconnectionSendTimeout.Value<>0) and
      (fNextPendingDisconnectionSendTimeout>=fHost.fTime) then begin
    fHost.fNextPeerEventTime:=TRNLTime.Minimum(fHost.fNextPeerEventTime,fNextPendingDisconnectionSendTimeout);
   end;

  end;

 end;

end;

procedure TRNLPeer.DispatchIncomingChannelMessages;
var Channel:TRNLPeerChannel;
begin
 for Channel in fChannels do begin
  Channel.DispatchIncomingMessages;
 end;
end;

procedure TRNLPeer.DispatchOutgoingChannelPackets;
var Channel:TRNLPeerChannel;
begin
 for Channel in fChannels do begin
  Channel.DispatchOutgoingBlockPackets;
 end;
end;

function TRNLPeer.DispatchOutgoingMTUProbeBlockPackets(var aOutgoingPacketBuffer:TRNLOutgoingPacketBuffer):boolean;
var OutgoingBlockPacket:TRNLPeerBlockPacket;
begin

 result:=false;

 while fOutgoingMTUProbeBlockPackets.Peek(OutgoingBlockPacket) do begin

  if OutgoingBlockPacket.fBlockPacket.Header.TypeAndSubtype=TRNLInt32(TRNLProtocolBlockPacketType(RNL_PROTOCOL_BLOCK_PACKET_TYPE_MTU_PROBE)) then begin

   aOutgoingPacketBuffer.Reset(SizeOf(TRNLProtocolNormalPacketHeader),
                               TRNLEndianness.LittleEndianToHost16(OutgoingBlockPacket.fBlockPacket.MTUProbe.Size)-
                               (RNL_IP_HEADER_SIZE+
                                RNL_UDP_HEADER_SIZE));

   if aOutgoingPacketBuffer.HasSpaceFor(OutgoingBlockPacket.Size) and
      fOutgoingMTUProbeBlockPackets.Dequeue then begin

    OutgoingBlockPacket.AppendTo(aOutgoingPacketBuffer);
    inc(fCountSentPackets);

    result:=true;

    break;

   end;

  end else begin

   fOutgoingMTUProbeBlockPackets.Dequeue;

  end;

 end;

end;

function TRNLPeer.DispatchOutgoingBlockPackets(var aOutgoingPacketBuffer:TRNLOutgoingPacketBuffer):boolean;
var OutgoingBlockPacket:TRNLPeerBlockPacket;
begin

 result:=true;

 while fOutgoingBlockPackets.Peek(OutgoingBlockPacket) and
       aOutgoingPacketBuffer.HasSpaceFor(OutgoingBlockPacket.Size) and
       fOutgoingBlockPackets.Dequeue do begin

  try

   OutgoingBlockPacket.AppendTo(aOutgoingPacketBuffer);
   inc(fCountSentPackets);

  finally

   if assigned(OutgoingBlockPacket.fPendingResendOutgoingBlockPacketsList) then begin

    OutgoingBlockPacket.fSentTime:=fHost.fTime;

    inc(OutgoingBlockPacket.fCountSendAttempts);

    if OutgoingBlockPacket.fRoundTripTimeout=0 then begin
     OutgoingBlockPacket.fRoundTripTimeout:=Min(Max(fRetransmissionTimeout shr 32,fHost.fMinimumRetransmissionTimeout),fHost.fMaximumRetransmissionTimeout);
     OutgoingBlockPacket.fRoundTripTimeoutLimit:=Min(Max(fRetransmissionTimeout shr 30,fHost.fMinimumRetransmissionTimeoutLimit),fHost.fMaximumRetransmissionTimeoutLimit);
    end;

    if (fNextReliableBlockPacketTimeout.Value=0) or
       (fNextReliableBlockPacketTimeout>=fHost.fTime) then begin
     fNextReliableBlockPacketTimeout:=fHost.fTime+OutgoingBlockPacket.fRoundTripTimeout;
    end;

    OutgoingBlockPacket.fPendingResendOutgoingBlockPacketsList.Add(OutgoingBlockPacket);

    result:=false;

   end else begin

    OutgoingBlockPacket.DecRef;

   end;

  end;

 end;

 if (fNextReliableBlockPacketTimeout.Value<>0) and
    (fNextReliableBlockPacketTimeout>=fHost.fTime) then begin
  fHost.fNextPeerEventTime:=TRNLTime.Minimum(fHost.fNextPeerEventTime,fNextReliableBlockPacketTimeout);
 end;

end;

procedure TRNLPeer.DispatchNewHostBandwidthLimits;
var OutgoingBlockPacket:TRNLPeerBlockPacket;
begin

 if not fSendNewHostBandwidthLimits then begin
  exit;
 end;

 if (fSendNewHostBandwidthLimitsNextTimeout.Value<>0) and
    (fSendNewHostBandwidthLimitsNextTimeout<=fHost.fTime) then begin

  OutgoingBlockPacket:=TRNLPeerBlockPacket.Create(self);
  try
   OutgoingBlockPacket.fBlockPacket.Header.TypeAndSubtype:=TRNLInt32(TRNLProtocolBlockPacketType(RNL_PROTOCOL_BLOCK_PACKET_TYPE_BANDWIDTH_LIMITS));
   OutgoingBlockPacket.fBlockPacket.BandwidthLimits.SequenceNumber:=fSendNewHostBandwidthLimitsSequenceNumber;
   OutgoingBlockPacket.fBlockPacket.BandwidthLimits.IncomingBandwidthLimit:=TRNLEndianness.HostToLittleEndian32(fHost.IncomingBandwidthLimit);
   OutgoingBlockPacket.fBlockPacket.BandwidthLimits.OutgoingBandwidthLimit:=TRNLEndianness.HostToLittleEndian32(fHost.OutgoingBandwidthLimit);
  finally
   fOutgoingMTUProbeBlockPackets.Enqueue(OutgoingBlockPacket);
  end;

  fSendNewHostBandwidthLimitsNextTimeout:=fHost.fTime+fSendNewHostBandwidthLimitsInterval;

 end;

 if (fSendNewHostBandwidthLimitsNextTimeout.Value<>0) and
    (fSendNewHostBandwidthLimitsNextTimeout>=fHost.fTime) then begin
  fHost.fNextPeerEventTime:=TRNLTime.Minimum(fHost.fNextPeerEventTime,fSendNewHostBandwidthLimitsNextTimeout);
 end;

end;

procedure TRNLPeer.DispatchMTUProbe;
var OutgoingBlockPacket:TRNLPeerBlockPacket;
    HostEvent:TRNLHostEvent;
begin

 if fMTUProbeIndex<0 then begin
  fMTUProbeNextTimeout:=0;
  exit;
 end;

 if (fMTUProbeNextTimeout.Value<>0) and
    (fMTUProbeNextTimeout<=fHost.fTime) then begin

  if fMTUProbeRemainingTryIterations>0 then begin

   dec(fMTUProbeRemainingTryIterations);
   if fMTUProbeRemainingTryIterations=0 then begin

    dec(fMTUProbeIndex);
    if fMTUProbeIndex<0 then begin
     fMTUProbeNextTimeout:=0;
     if assigned(fHost.fOnPeerMTU) then begin
      fHost.fOnPeerMTU(fHost,self,fMTU);
     end else begin
      HostEvent.Initialize;
      try
       HostEvent.Type_:=RNL_HOST_EVENT_TYPE_PEER_MTU;
       HostEvent.Peer:=self;
       HostEvent.Peer.IncRef;
       HostEvent.Message:=nil;
       HostEvent.MTU:=fMTU;
      finally
       fHost.fEventQueue.Enqueue(HostEvent);
      end;
     end;
     exit;
    end;

    inc(fMTUProbeSequenceNumber);

    fMTUProbeRemainingTryIterations:=fMTUProbeTryIterationsPerMTUProbeSize;

   end;

   OutgoingBlockPacket:=TRNLPeerBlockPacket.Create(self);
   try
    OutgoingBlockPacket.fBlockPacket.Header.TypeAndSubtype:=TRNLInt32(TRNLProtocolBlockPacketType(RNL_PROTOCOL_BLOCK_PACKET_TYPE_MTU_PROBE));
    OutgoingBlockPacket.fBlockPacket.MTUProbe.SequenceNumber:=TRNLEndianness.HostToLittleEndian16(fMTUProbeSequenceNumber.fValue);
    OutgoingBlockPacket.fBlockPacket.MTUProbe.Phase:=0;
    OutgoingBlockPacket.fBlockPacket.MTUProbe.Size:=TRNLEndianness.HostToLittleEndian16(RNLKnownCommonMTUSizes[fMTUProbeIndex]);
    OutgoingBlockPacket.fBlockPacketDataLength:=RNLKnownCommonMTUSizes[fMTUProbeIndex]-(RNL_IP_HEADER_SIZE+
                                                                                        RNL_UDP_HEADER_SIZE+
                                                                                        SizeOf(TRNLProtocolNormalPacketHeader)+
                                                                                        SizeOf(TRNLProtocolBlockPacketMTUProbe));
    SetLength(OutgoingBlockPacket.fBlockPacketData,OutgoingBlockPacket.fBlockPacketDataLength);
    OutgoingBlockPacket.fBlockPacket.MTUProbe.PayloadDataLength:=TRNLEndianness.LittleEndianToHost16(OutgoingBlockPacket.fBlockPacketDataLength);
    if OutgoingBlockPacket.fBlockPacketDataLength>0 then begin
     fHost.fRandomGenerator.GetRandomBytes(OutgoingBlockPacket.fBlockPacketData[0],OutgoingBlockPacket.fBlockPacketDataLength);
    end;
   finally
    fOutgoingMTUProbeBlockPackets.Enqueue(OutgoingBlockPacket);
   end;

  end;

  fMTUProbeNextTimeout:=fHost.fTime+fMTUProbeInterval;

 end;

 if (fMTUProbeNextTimeout.Value<>0) and
    (fMTUProbeNextTimeout>=fHost.fTime) then begin
  fHost.fNextPeerEventTime:=TRNLTime.Minimum(fHost.fNextPeerEventTime,fMTUProbeNextTimeout);
 end;

end;

procedure TRNLPeer.DispatchKeepAlive;
var OutgoingBlockPacket:TRNLPeerBlockPacket;
    KeepAliveWindowItem:PRNLPeerKeepAliveWindowItem;
    SequenceNumber:TRNLUInt8;
    SequenceIndex:TRNLSizeUInt;
begin

 fNextPingResendTime.fValue:=0;

 if (TRNLInt8(TRNLUInt8(fOutgoingPingSequenceNumber-fIncomingPongSequenceNumber))<TRNLSizeInt(fHost.fKeepAliveWindowSize)) and
    (fOutgoingBlockPackets.Count=0) and
    (fOutgoingMTUProbeBlockPackets.Count=0) and
    (fUnacknowlegmentedBlockPackets=0) and
    (fHost.fTime>=(fLastReceivedDataTime+fHost.fPingInterval)) and
    (fHost.fTime>=(fLastPingSentTime+fHost.fPingInterval)) then begin

  KeepAliveWindowItem:=@fKeepAliveWindowItems[fOutgoingPingSequenceNumber and fHost.fKeepAliveWindowMask];

  if KeepAliveWindowItem^.State=RNL_PEER_KEEP_ALIVE_WINDOW_ITEM_STATE_FREE then begin

   fLastPingSentTime:=fHost.fTime;

   fNextPingSendTime:=fHost.fTime+fHost.fPingInterval;

   fNextPingResendTime:=fHost.fTime+fHost.fPingResendTimeout;

   OutgoingBlockPacket:=TRNLPeerBlockPacket.Create(self);
   try
    OutgoingBlockPacket.fBlockPacket.Header.TypeAndSubtype:=TRNLInt32(TRNLProtocolBlockPacketType(RNL_PROTOCOL_BLOCK_PACKET_TYPE_PING));
    OutgoingBlockPacket.fBlockPacket.Ping.SequenceNumber:=fOutgoingPingSequenceNumber;
   finally
    fOutgoingBlockPackets.Enqueue(OutgoingBlockPacket);
   end;

   KeepAliveWindowItem^.State:=RNL_PEER_KEEP_ALIVE_WINDOW_ITEM_STATE_SENT;
   KeepAliveWindowItem^.SequenceNumber:=fOutgoingPingSequenceNumber;
   KeepAliveWindowItem^.Time:=fHost.fTime;
   KeepAliveWindowItem^.ResendTimeout:=fHost.fPingResendTimeout;

{$if defined(RNL_DEBUG) and defined(RNL_DEBUG_PING)}
   fHost.fInstance.fDebugLock.Acquire;
   try
    RNLDebugOutputString('Peer '+IntToStr(fLocalPeerID)+': Outgoing ping '+IntToStr(fOutgoingPingSequenceNumber));
   finally
    fHost.fInstance.fDebugLock.Release;
   end;
{$ifend}

   inc(fOutgoingPingSequenceNumber);

  end;

 end;

 for SequenceIndex:=0 to fHost.fKeepAliveWindowMask do begin

  SequenceNumber:=TRNLUInt8(fIncomingPongSequenceNumber+SequenceIndex);

  if TRNLInt8(TRNLUInt8(SequenceNumber-fOutgoingPingSequenceNumber))>=0 then begin
   break;
  end;

  KeepAliveWindowItem:=@fKeepAliveWindowItems[SequenceNumber and fHost.fKeepAliveWindowMask];

  if KeepAliveWindowItem^.State=RNL_PEER_KEEP_ALIVE_WINDOW_ITEM_STATE_SENT then begin

   if fHost.fTime>=(KeepAliveWindowItem^.Time+KeepAliveWindowItem^.ResendTimeout) then begin

    inc(fCountPacketLoss);

    OutgoingBlockPacket:=TRNLPeerBlockPacket.Create(self);
    try
     OutgoingBlockPacket.fBlockPacket.Header.TypeAndSubtype:=TRNLInt32(TRNLProtocolBlockPacketType(RNL_PROTOCOL_BLOCK_PACKET_TYPE_PING));
     OutgoingBlockPacket.fBlockPacket.Ping.SequenceNumber:=KeepAliveWindowItem^.SequenceNumber;
    finally
     fOutgoingBlockPackets.Enqueue(OutgoingBlockPacket);
    end;

    KeepAliveWindowItem^.Time:=fHost.fTime;

    KeepAliveWindowItem^.ResendTimeout:=TRNLTime.Minimum(KeepAliveWindowItem^.ResendTimeout+KeepAliveWindowItem^.ResendTimeout,
                                                         fHost.fPingInterval);

{$if defined(RNL_DEBUG) and defined(RNL_DEBUG_PING)}
    fHost.fInstance.fDebugLock.Acquire;
    try
     RNLDebugOutputString('Peer '+IntToStr(fLocalPeerID)+': Outgoing lost resend ping '+IntToStr(KeepAliveWindowItem^.SequenceNumber));
    finally
     fHost.fInstance.fDebugLock.Release;
    end;
{$ifend}

   end;

   if (fNextPingResendTime.fValue=0) or
      (fNextPingResendTime<(KeepAliveWindowItem^.Time+KeepAliveWindowItem^.ResendTimeout)) then begin
    fNextPingResendTime:=KeepAliveWindowItem^.Time+KeepAliveWindowItem^.ResendTimeout;
   end;

  end;

 end;

 if (fNextPingSendTime.Value<>0) and
    (fNextPingSendTime>=fHost.fTime) then begin
  fHost.fNextPeerEventTime:=TRNLTime.Minimum(fHost.fNextPeerEventTime,fNextPingSendTime);
 end;

 if (fNextPingResendTime.Value<>0) and
    (fNextPingResendTime>=fHost.fTime) then begin
  fHost.fNextPeerEventTime:=TRNLTime.Minimum(fHost.fNextPeerEventTime,fNextPingResendTime);
 end;

end;

procedure TRNLPeer.DispatchConnectionTimeout;
begin
 fHost.fNextPeerEventTime:=TRNLTime.Minimum(fHost.fNextPeerEventTime,fHost.fTime+fHost.fConnectionTimeout);
end;

procedure TRNLPeer.DispatchIncomingPacket(const aPayloadData;const aPayloadDataLength:TRNLSizeUInt;const aSentTime:TRNLUInt64);
var PayloadDataPosition,BlockPacketSize:TRNLSizeUInt;
    BlockPacket:PRNLProtocolBlockPacket;
    BlockPacketType:TRNLProtocolBlockPacketType;
    BlockPacketPayload:TRNLPointer;
    PeerBlockPacket:TRNLPeerBlockPacket;
begin

 fLastReceivedDataTime:=fHost.fTime;

 PayloadDataPosition:=0;

 while (PayloadDataPosition+SizeOf(TRNLProtocolBlockPacketHeader))<=aPayloadDataLength do begin

  BlockPacket:=TRNLPointer(@PRNLUInt8Array(TRNLPointer(@aPayloadData))^[PayloadDataPosition]);

  BlockPacketType:=TRNLProtocolBlockPacketType(TRNLInt32(BlockPacket^.Header.TypeAndSubtype and $f));

  if not (BlockPacketType in [TRNLProtocolBlockPacketType(Low(TRNLProtocolBlockPacketType))..TRNLProtocolBlockPacketType(High(TRNLProtocolBlockPacketType))]) then begin
   break;
  end;

  BlockPacketSize:=RNLProtocolBlockPacketSizes[BlockPacketType];

  if (PayloadDataPosition+BlockPacketSize)>aPayloadDataLength then begin
   break;
  end;
  inc(PayloadDataPosition,BlockPacketSize);

  case BlockPacketType of

   RNL_PROTOCOL_BLOCK_PACKET_TYPE_PING:begin

    PeerBlockPacket:=TRNLPeerBlockPacket.Create(self);
    try
     PeerBlockPacket.fSentTime:=aSentTime;
     PeerBlockPacket.fReceivedTime:=fHost.fTime;
     PRNLProtocolBlockPacketPing(TRNLPointer(@PeerBlockPacket.fBlockPacket))^:=PRNLProtocolBlockPacketPing(TRNLPointer(BlockPacket))^;
    finally
     fIncomingBlockPackets.Enqueue(PeerBlockPacket);
    end;

   end;

   RNL_PROTOCOL_BLOCK_PACKET_TYPE_PONG:begin

    BlockPacket.Pong.SentTime:=TRNLEndianness.LittleEndianToHost16(BlockPacket.Pong.SentTime);

    PeerBlockPacket:=TRNLPeerBlockPacket.Create(self);
    try
     PeerBlockPacket.fSentTime:=aSentTime;
     PeerBlockPacket.fReceivedTime:=fHost.fTime;
     PRNLProtocolBlockPacketPong(TRNLPointer(@PeerBlockPacket.fBlockPacket))^:=PRNLProtocolBlockPacketPong(TRNLPointer(BlockPacket))^;
    finally
     fIncomingBlockPackets.Enqueue(PeerBlockPacket);
    end;

   end;

   RNL_PROTOCOL_BLOCK_PACKET_TYPE_DISCONNECT:begin

    PeerBlockPacket:=TRNLPeerBlockPacket.Create(self);
    try
     PeerBlockPacket.fSentTime:=aSentTime;
     PeerBlockPacket.fReceivedTime:=fHost.fTime;
     PRNLProtocolBlockPacketDisconnect(TRNLPointer(@PeerBlockPacket.fBlockPacket))^:=PRNLProtocolBlockPacketDisconnect(TRNLPointer(BlockPacket))^;
    finally
     fIncomingBlockPackets.Enqueue(PeerBlockPacket);
    end;

   end;

   RNL_PROTOCOL_BLOCK_PACKET_TYPE_DISCONNECT_ACKNOWLEGDEMENT:begin

    PeerBlockPacket:=TRNLPeerBlockPacket.Create(self);
    try
     PeerBlockPacket.fSentTime:=aSentTime;
     PeerBlockPacket.fReceivedTime:=fHost.fTime;
     PRNLProtocolBlockPacketDisconnectAcknowledgement(TRNLPointer(@PeerBlockPacket.fBlockPacket))^:=PRNLProtocolBlockPacketDisconnectAcknowledgement(TRNLPointer(BlockPacket))^;
    finally
     fIncomingBlockPackets.Enqueue(PeerBlockPacket);
    end;

   end;

   RNL_PROTOCOL_BLOCK_PACKET_TYPE_BANDWIDTH_LIMITS:begin

    PeerBlockPacket:=TRNLPeerBlockPacket.Create(self);
    try
     PeerBlockPacket.fSentTime:=aSentTime;
     PeerBlockPacket.fReceivedTime:=fHost.fTime;
     PRNLProtocolBlockPacketBandwidthLimits(TRNLPointer(@PeerBlockPacket.fBlockPacket))^:=PRNLProtocolBlockPacketBandwidthLimits(TRNLPointer(BlockPacket))^;
    finally
     fIncomingBlockPackets.Enqueue(PeerBlockPacket);
    end;

   end;

   RNL_PROTOCOL_BLOCK_PACKET_TYPE_BANDWIDTH_LIMITS_ACKNOWLEGDEMENT:begin

    PeerBlockPacket:=TRNLPeerBlockPacket.Create(self);
    try
     PeerBlockPacket.fSentTime:=aSentTime;
     PeerBlockPacket.fReceivedTime:=fHost.fTime;
     PRNLProtocolBlockPacketBandwidthLimitsAcknowledgement(TRNLPointer(@PeerBlockPacket.fBlockPacket))^:=PRNLProtocolBlockPacketBandwidthLimitsAcknowledgement(TRNLPointer(BlockPacket))^;
    finally
     fIncomingBlockPackets.Enqueue(PeerBlockPacket);
    end;

   end;

   RNL_PROTOCOL_BLOCK_PACKET_TYPE_MTU_PROBE:begin

    if (PayloadDataPosition+TRNLEndianness.LittleEndianToHost16(BlockPacket^.MTUProbe.PayloadDataLength))>aPayloadDataLength then begin
     break;
    end;

    BlockPacketPayload:=TRNLPointer(@PRNLUInt8Array(TRNLPointer(@aPayloadData))^[PayloadDataPosition]);
    inc(PayloadDataPosition,TRNLEndianness.LittleEndianToHost16(BlockPacket^.MTUProbe.PayloadDataLength));

    PeerBlockPacket:=TRNLPeerBlockPacket.Create(self);
    try
     PeerBlockPacket.fSentTime:=aSentTime;
     PeerBlockPacket.fReceivedTime:=fHost.fTime;
     PRNLProtocolBlockPacketMTUProbe(TRNLPointer(@PeerBlockPacket.fBlockPacket))^:=PRNLProtocolBlockPacketMTUProbe(TRNLPointer(BlockPacket))^;
     PeerBlockPacket.fBlockPacketDataLength:=TRNLEndianness.LittleEndianToHost16(BlockPacket^.MTUProbe.PayloadDataLength);
     if PeerBlockPacket.fBlockPacketDataLength>0 then begin
      SetLength(PeerBlockPacket.fBlockPacketData,PeerBlockPacket.fBlockPacketDataLength);
      System.Move(BlockPacketPayload^,PeerBlockPacket.fBlockPacketData[0],PeerBlockPacket.fBlockPacketDataLength);
     end;
    finally
     fIncomingBlockPackets.Enqueue(PeerBlockPacket);
    end;

   end;

   RNL_PROTOCOL_BLOCK_PACKET_TYPE_CHANNEL:begin

    BlockPacket^.Channel.PayloadDataLength:=TRNLEndianness.LittleEndianToHost16(BlockPacket^.Channel.PayloadDataLength);

    if (PayloadDataPosition+BlockPacket^.Channel.PayloadDataLength)>aPayloadDataLength then begin
     break;
    end;

    BlockPacketPayload:=TRNLPointer(@PRNLUInt8Array(TRNLPointer(@aPayloadData))^[PayloadDataPosition]);
    inc(PayloadDataPosition,BlockPacket^.Channel.PayloadDataLength);

    PeerBlockPacket:=TRNLPeerBlockPacket.Create(self);
    try
     PeerBlockPacket.fSentTime:=aSentTime;
     PeerBlockPacket.fReceivedTime:=fHost.fTime;
     PRNLProtocolBlockPacketChannel(TRNLPointer(@PeerBlockPacket.fBlockPacket))^:=PRNLProtocolBlockPacketChannel(TRNLPointer(BlockPacket))^;
     PeerBlockPacket.fBlockPacketDataLength:=BlockPacket^.Channel.PayloadDataLength;
     if PeerBlockPacket.fBlockPacketDataLength>0 then begin
      SetLength(PeerBlockPacket.fBlockPacketData,PeerBlockPacket.fBlockPacketDataLength);
      System.Move(BlockPacketPayload^,PeerBlockPacket.fBlockPacketData[0],PeerBlockPacket.fBlockPacketDataLength);
     end;
    finally
     fIncomingBlockPackets.Enqueue(PeerBlockPacket);
    end;

   end;

  end;

 end;

end;

procedure TRNLPeer.DispatchIncomingPackets;
var NormalPacketHeader:PRNLProtocolNormalPacketHeader;
    EncryptedPacketSequenceNumber:TRNLUInt64;
    Index:TRNLInt32;
    PacketDataLength,PayloadDataLength,
    OriginalDecompressedDataLength,DecompressedDataLength:TRNLSizeInt;
    PayloadData:TRNLPointer;
    PayloadMAC:TRNLCipherMAC;
    CipherNonce:TRNLCipherNonce;
    PacketData:TBytes;
begin

 PacketData:=nil;

 try

  while fIncomingPacketQueue.Dequeue(PacketData) do begin

   try

    PacketDataLength:=length(PacketData);

    NormalPacketHeader:=@PacketData[0];

    if PacketDataLength<SizeOf(TRNLProtocolNormalPacketHeader) then begin
     // Too small packet, drop it!
     continue;
    end;

    if NormalPacketHeader^.Not255=$ff then begin
     // 255? Ups, there's probably something went wrong then :-)
     continue;
    end;

    fIncomingBandwidthRateTracker.AddUnits(PacketDataLength shl 3);

    if not (fState in RNLNormalPacketPeerStates) then begin
     continue;
    end;

    EncryptedPacketSequenceNumber:=TRNLEndianness.LittleEndianToHost64(NormalPacketHeader^.EncryptedPacketSequenceNumber);

    PayloadData:=TRNLPointer(@PRNLUInt8Array(TRNLPointer(@PacketData[0]))^[SizeOf(TRNLProtocolNormalPacketHeader)]);

    PayloadDataLength:=PacketDataLength-SizeOf(TRNLProtocolNormalPacketHeader);

    if PayloadDataLength=0 then begin
     // No payload? Then skip it!
     continue;
    end;

    TRNLMemoryAccess.StoreLittleEndianUInt64(CipherNonce.ui64[0],EncryptedPacketSequenceNumber);
    TRNLMemoryAccess.StoreLittleEndianUInt64(CipherNonce.ui64[1],TRNLEndianness.LittleEndianToHost64(fConnectionNonce));
    TRNLMemoryAccess.StoreLittleEndianUInt64(CipherNonce.ui64[2],fConnectionSalt);

    PayloadMAC:=NormalPacketHeader^.PayloadMAC;

    FillChar(NormalPacketHeader^.PayloadMAC,SizeOf(TRNLCipherMAC),#$00);

    if not TRNLAuthenticatedEncryption.Decrypt(PayloadData^,
                                               fSharedSecretKey,
                                               CipherNonce,
                                               PayloadMAC,
                                               NormalPacketHeader^,
                                               SizeOf(TRNLProtocolNormalPacketHeader),
                                               PayloadData^,
                                               PayloadDataLength) then begin
{$if defined(RNL_DEBUG) and defined(RNL_DEBUG_SECURITY_EXTENDED) and false}
     fHost.fInstance.fDebugLock.Acquire;
     try
      if assigned(Peer) then begin
       RNLDebugOutputString('DP: '+IntToStr(Peer.fSharedSecretKey.ui32[0])+' '+IntToStr(Peer.fSharedSecretKey.ui32[1])+' '+IntToStr(Peer.fSharedSecretKey.ui32[2])+' '+IntToStr(Peer.fSharedSecretKey.ui32[3])+' '+IntToStr(TRNLUInt32(fReceivedDataLength)-ReceivedDataOffset));
      end else begin
       RNLDebugOutputString('DH: '+IntToStr(Peer.fSharedSecretKey.ui32[0])+' '+IntToStr(Peer.fSharedSecretKey.ui32[1])+' '+IntToStr(Peer.fSharedSecretKey.ui32[2])+' '+IntToStr(Peer.fSharedSecretKey.ui32[3])+' '+IntToStr(TRNLUInt32(fReceivedDataLength)-ReceivedDataOffset));
      end;
     finally
      fHost.fInstance.fDebugLock.Release;
     end;
{$ifend}
     continue;
    end;

{$if defined(RNL_DEBUG) and false}
    fHost.fInstance.fDebugLock.Acquire;
    try
     RNLDebugOutputString(IntToStr(fIncomingEncryptedPacketSequenceNumber)+' '+IntToStr(EncryptedPacketSequenceNumber));
    finally
     fHost.fInstance.fDebugLock.Release;
    end;
{$ifend}

    begin
     // Replay protection based on the encrypted packet sequence number
     //   To enable playback protection, RNL performs the following steps:
     //     1. Encrypted packets are sent with 64-bit sequence numbers that
     //        start at zero and increase with each packet sent.
     //     2. The sequence number is included in the packet header and
     //        can be read by the recipient of a packet before decryption.
     //     3. The sequence number is used as a part of the nonce for packet
     //        encryption, so that any change to the sequence number does not
     //        pass the encryption signature check.
     //   The replay protection algorithm is as follows:
     //     1. Any packet older than the sequence number received last, minus the
     //        size of the replay sequence number window size, is discarded on the
     //        receiver side.
     //     2. If a packet arrives with a sequence number that is newer than the
     //        last received sequence number, the most recent sequence number on
     //        the receiver side is updated and the packet is accepted.
     //     3. If a packet arrives that is within the replay sequence window size
     //        of the last sequence number, it is only accepted if its sequence
     //        number has not yet been received, otherwise it is ignored.
     // It is basically almost the same what yojimbo respectively netcode.io does also.
     if TRNLUInt32(length(fIncomingEncryptedPacketSequenceBuffer))<>fHost.fEncryptedPacketSequenceWindowSize then begin
      SetLength(fIncomingEncryptedPacketSequenceBuffer,fHost.fEncryptedPacketSequenceWindowSize);
      FillChar(fIncomingEncryptedPacketSequenceBuffer[0],
               fHost.fEncryptedPacketSequenceWindowSize*SizeOf(TRNLUInt64),
               #$ff);
     end;
     if ((EncryptedPacketSequenceNumber and TRNLUInt64($8000000000000000))<>0) or
        ((EncryptedPacketSequenceNumber+fHost.fEncryptedPacketSequenceWindowSize)<=fIncomingEncryptedPacketSequenceNumber) then begin
      continue;
     end else if fIncomingEncryptedPacketSequenceNumber<EncryptedPacketSequenceNumber then begin
      fIncomingEncryptedPacketSequenceNumber:=EncryptedPacketSequenceNumber;
     end;
     Index:=EncryptedPacketSequenceNumber and fHost.fEncryptedPacketSequenceWindowMask;
     if (fIncomingEncryptedPacketSequenceBuffer[Index]<>TRNLUInt64($ffffffffffffffff)) and
        (fIncomingEncryptedPacketSequenceBuffer[Index]>=EncryptedPacketSequenceNumber) then begin
      continue;
     end;
     fIncomingEncryptedPacketSequenceBuffer[Index]:=EncryptedPacketSequenceNumber;
    end;

    if (NormalPacketHeader^.Flags and RNL_PROTOCOL_PACKET_HEADER_FLAG_COMPRESSED)<>0 then begin

     if not assigned(fHost.fCompressor) then begin
      continue;
     end;

     OriginalDecompressedDataLength:=TRNLMemoryAccess.LoadLittleEndianUInt16(PayloadData^);
     if OriginalDecompressedDataLength=0 then begin
      continue;
     end;

     DecompressedDataLength:=fHost.fCompressor.Decompress(@PRNLUInt8Array(PayloadData)^[SizeOf(TRNLUInt16)],
                                                          PayloadDataLength-SizeOf(TRNLUInt16),
                                                          @fHost.fCompressionBuffer[0],
                                                          OriginalDecompressedDataLength);

     if (DecompressedDataLength=0) or
        (DecompressedDataLength<>OriginalDecompressedDataLength) then begin
      continue;
     end;

{$if defined(RNL_DEBUG) and defined(RNL_DEBUG_COMPRESS)}
     fHost.fInstance.fDebugLock.Acquire;
     try
      RNLDebugOutputString('Peer '+IntToStr(fLocalPeerID)+': '+
                           'compressed '+IntToStr(PayloadDataLength-SizeOf(TRNLUInt16))+' => uncompressed '+IntToStr(DecompressedDataLength)+' '+
                           '('+RNLDebugFormatFloat(((PayloadDataLength-SizeOf(TRNLUInt16))*100.0)/DecompressedDataLength,1,1)+'%)');
     finally
      fHost.fInstance.fDebugLock.Release;
     end;
{$ifend}

     PayloadData:=@fHost.fCompressionBuffer[0];
     PayloadDataLength:=DecompressedDataLength;

     PacketData:=nil;

    end;

    DispatchIncomingPacket(PayloadData^,
                           PayloadDataLength,
                           TRNLEndianness.LittleEndianToHost16(NormalPacketHeader^.SentTime));

   finally
    PacketData:=nil;
   end;

  end;

 finally

  PacketData:=nil;

 end;

end;

function TRNLPeer.DispatchOutgoingPackets:boolean;
var OutgoingPacketData,OutgoingPayloadData:TRNLPointer;
    OutgoingPacketDataLength,OutgoingPayloadDataLength,CompressedDataLength:TRNLSizeInt;
    NormalPacketHeader:PRNLProtocolNormalPacketHeader;
    CipherNonce:TRNLCipherNonce;
    OutgoingPacketBuffer:PRNLOutgoingPacketBuffer;
    IsMTUProbe:boolean;
begin

 result:=true;

 OutgoingPacketBuffer:=@fHost.fOutgoingPacketBuffer;

 if fState in [RNL_PEER_STATE_CONNECTED,
               RNL_PEER_STATE_DISCONNECT_LATER] then begin
  DispatchOutgoingChannelPackets;
 end;

 repeat

  IsMTUProbe:=DispatchOutgoingMTUProbeBlockPackets(OutgoingPacketBuffer^);

  if not IsMTUProbe then begin

   OutgoingPacketBuffer^.Reset(SizeOf(TRNLProtocolNormalPacketHeader),
                               fMTU-(RNL_IP_HEADER_SIZE+RNL_UDP_HEADER_SIZE));

   DispatchOutgoingBlockPackets(OutgoingPacketBuffer^);

  end;

  if OutgoingPacketBuffer^.PayloadSize>0 then begin

   OutgoingPacketData:=@OutgoingPacketBuffer^.fData[0];
   OutgoingPacketDataLength:=OutgoingPacketBuffer^.Size;

   NormalPacketHeader:=TRNLPointer(@OutgoingPacketBuffer^.fData[0]);

   NormalPacketHeader^.PeerID:=fRemotePeerID;
   NormalPacketHeader^.Flags:=0;
   NormalPacketHeader^.Not255:=0;

   OutgoingPayloadData:=@OutgoingPacketBuffer^.fData[SizeOf(TRNLProtocolNormalPacketHeader)];
   OutgoingPayloadDataLength:=OutgoingPacketBuffer^.fSize-SizeOf(TRNLProtocolNormalPacketHeader);

   if assigned(fHost.fCompressor) and
      (OutgoingPacketDataLength>(SizeOf(TRNLProtocolNormalPacketHeader)+SizeOf(TRNLUInt16))) and
      (OutgoingPacketDataLength<65536) and
      not IsMTUProbe then begin

    CompressedDataLength:=fHost.fCompressor.Compress(OutgoingPayloadData,
                                                     OutgoingPayloadDataLength,
                                                     @fHost.fCompressionBuffer[SizeOf(TRNLProtocolNormalPacketHeader)+SizeOf(TRNLUInt16)],
                                                     OutgoingPayloadDataLength-SizeOf(TRNLUInt16));

    if (CompressedDataLength>0) and (CompressedDataLength<(OutgoingPayloadDataLength-SizeOf(TRNLUInt16))) then begin
{$if defined(RNL_DEBUG) and defined(RNL_DEBUG_COMPRESS)}
     fHost.fInstance.fDebugLock.Acquire;
     try
      RNLDebugOutputString('Peer '+IntToStr(fLocalPeerID)+': '+
                           'uncompressed '+IntToStr(OutgoingPayloadDataLength)+' => compressed '+IntToStr(CompressedDataLength)+' '+
                           '('+RNLDebugFormatFloat((CompressedDataLength*100.0)/OutgoingPayloadDataLength,1,1)+'%)');
     finally
      fHost.fInstance.fDebugLock.Release;
     end;
{$ifend}

     TRNLMemoryAccess.StoreLittleEndianUInt16(fHost.fCompressionBuffer[SizeOf(TRNLProtocolNormalPacketHeader)],OutgoingPayloadDataLength);

     PRNLProtocolNormalPacketHeader(TRNLPointer(@fHost.fCompressionBuffer[0]))^:=NormalPacketHeader^;

     NormalPacketHeader:=PRNLProtocolNormalPacketHeader(TRNLPointer(@fHost.fCompressionBuffer[0]));

     OutgoingPacketData:=@fHost.fCompressionBuffer[0];
     OutgoingPacketDataLength:=SizeOf(TRNLProtocolNormalPacketHeader)+SizeOf(TRNLUInt16)+CompressedDataLength;

     OutgoingPayloadData:=@fHost.fCompressionBuffer[SizeOf(TRNLProtocolNormalPacketHeader)];
     OutgoingPayloadDataLength:=OutgoingPacketDataLength-SizeOf(TRNLProtocolNormalPacketHeader);

     NormalPacketHeader^.Flags:=NormalPacketHeader^.Flags or RNL_PROTOCOL_PACKET_HEADER_FLAG_COMPRESSED;

    end;

   end;

   NormalPacketHeader^.SentTime:=TRNLEndianness.HostToLittleEndian16(TRNLUInt16(fHost.fTime.fValue));

   NormalPacketHeader^.EncryptedPacketSequenceNumber:=TRNLEndianness.HostToLittleEndian64(fOutgoingEncryptedPacketSequenceNumber);

   FillChar(NormalPacketHeader^.PayloadMAC,SizeOf(TRNLCipherMAC),#0);

   TRNLMemoryAccess.StoreLittleEndianUInt64(CipherNonce.ui64[0],fOutgoingEncryptedPacketSequenceNumber);
   TRNLMemoryAccess.StoreLittleEndianUInt64(CipherNonce.ui64[1],fConnectionNonce);
   TRNLMemoryAccess.StoreLittleEndianUInt64(CipherNonce.ui64[2],fConnectionSalt);

   inc(fOutgoingEncryptedPacketSequenceNumber);

   if not TRNLAuthenticatedEncryption.Encrypt(OutgoingPayloadData^,
                                              fSharedSecretKey,
                                              CipherNonce,
                                              NormalPacketHeader^.PayloadMAC,
                                              NormalPacketHeader^,
                                              SizeOf(TRNLProtocolNormalPacketHeader),
                                              OutgoingPayloadData^,
                                              OutgoingPayloadDataLength
                                             ) then begin
    continue;
   end;

   result:=SendPacket(OutgoingPacketData^,OutgoingPacketDataLength)<>RNL_NETWORK_SEND_RESULT_ERROR;

   if result then begin
    fLastSentDataTime:=fHost.fTime;
   end;

  end else begin

   break;

  end;

 until fOutgoingBlockPackets.IsEmpty;

end;

function TRNLPeer.DispatchPeer:boolean;
var HostEvent:TRNLHostEvent;
begin

 result:=true;

 if fState=RNL_PEER_STATE_DISCONNECTED then begin
  exit;
 end;

 if TRNLTime.Difference(fLastReceivedDataTime,Host.fTime)>=fHost.fConnectionTimeout then begin
  fState:=RNL_PEER_STATE_DISCONNECTED;
  if assigned(fHost.fOnPeerDisconnect) then begin
   try
    fHost.fOnPeerDisconnect(fHost,self,0);
   finally
    fHost.fPeerToFreeList.Add(fPeerToFreeListNode);
   end;
  end else begin
   HostEvent.Initialize;
   try
    HostEvent.Type_:=RNL_HOST_EVENT_TYPE_PEER_DISCONNECT;
    HostEvent.Peer:=self;
    HostEvent.Message:=nil;
    HostEvent.Data:=0;
   finally
    fHost.fEventQueue.Enqueue(HostEvent);
   end;
  end;
  exit;
 end;

 fIncomingBandwidthRateTracker.SetTime(fHost.fTime);
 fIncomingBandwidthRateTracker.Update;

 fOutgoingBandwidthRateTracker.SetTime(fHost.fTime);
 fOutgoingBandwidthRateTracker.Update;

 DispatchNewHostBandwidthLimits;

 DispatchMTUProbe;

 DispatchIncomingPackets;

 DispatchIncomingBlockPackets;

 DispatchIncomingChannelMessages;

 UpdatePatchLossStatistics;

 DispatchStateActions;

 DispatchKeepAlive;

 DispatchConnectionTimeout;

 result:=DispatchOutgoingPackets;

end;

procedure TRNLPeer.SendNewHostBandwidthLimits;
begin
 if not fSendNewHostBandwidthLimits then begin
  fSendNewHostBandwidthLimits:=true;
  fSendNewHostBandwidthLimitsInterval:=fHost.fPendingSendNewBandwidthLimitsSendTimeout;
  fSendNewHostBandwidthLimitsNextTimeout:=fHost.fTime;
 end;
 inc(fSendNewHostBandwidthLimitsSequenceNumber);
end;

function TRNLPeer.SendPacket(const aData;const aDataLength:TRNLSizeUInt):TRNLNetworkSendResult;
var DataLength:TRNLSizeUInt;
begin
 DataLength:=aDataLength shl 3;
 if (DataLength=0) or
    fOutgoingBandwidthRateLimiter.CanProceed(DataLength,fHost.fTime) then begin
  result:=fHost.SendPacket(fAddress,aData,aDataLength);
  if result=RNL_NETWORK_SEND_RESULT_OK then begin
   fOutgoingBandwidthRateLimiter.AddAmount(DataLength,fHost.fTime);
   fOutgoingBandwidthRateTracker.AddUnits(DataLength);
  end;
 end else begin
  // Drop the whole outgoing UDP packet for to satisfy the outgoing bandwidth limit (=> intended artificial packet loss)
  result:=RNL_NETWORK_SEND_RESULT_BANDWIDTH_RATE_LIMITER_DROP;
 end;
end;

procedure TRNLPeer.Disconnect(const aData:TRNLUInt64=0;const aDelayed:boolean=false);
begin
 if fState in [RNL_PEER_STATE_DISCONNECTED,
               RNL_PEER_STATE_DISCONNECT_LATER,
               RNL_PEER_STATE_DISCONNECTING,
               RNL_PEER_STATE_DISCONNECTION_ACKNOWLEDGING,
               RNL_PEER_STATE_DISCONNECTION_PENDING] then begin
  exit;
 end;
 if aDelayed then begin
  fState:=RNL_PEER_STATE_DISCONNECT_LATER;
 end else begin
  fState:=RNL_PEER_STATE_DISCONNECTING;
 end;
 fDisconnectData:=aData;
end;

procedure TRNLPeer.MTUProbe(const aTryIterationsPerMTUProbeSize:TRNLUInt32=5;const aMTUProbeInterval:TRNLUInt64=100);
begin

 fMTUProbeIndex:=High(RNLKnownCommonMTUSizes);

 inc(fMTUProbeSequenceNumber);

 fMTUProbeTryIterationsPerMTUProbeSize:=aTryIterationsPerMTUProbeSize;

 fMTUProbeRemainingTryIterations:=fMTUProbeTryIterationsPerMTUProbeSize;

 fMTUProbeInterval:=aMTUProbeInterval;

 fMTUProbeNextTimeout:=fHost.fTime;

end;

constructor TRNLHost.Create(const aInstance:TRNLInstance;const aNetwork:TRNLNetwork);
var Index:TRNLInt32;
begin

 inherited Create;

 fInstance:=aInstance;

 fNetwork:=aNetwork;

 fNetworkEvent:=nil;

 fRandomGenerator:=TRNLRandomGenerator.Create;

 fPeerLock:=TCriticalSection.Create;

 fPeerIDManager:=TRNLIDManager.Create;

 fPeerIDMap:=TRNLHostPeerIDMap.Create;

{$if defined(RNL_LINEAR_PEER_LIST)}
 fPeerList:=TRNLHostPeerList.Create(false);
{$else}
 fPeerList:=TRNLPeerListNode.Create;
{$ifend}

 fCountPeers:=0;

 fPeerToFreeList:=TRNLPeerListNode.Create;

 fTime:=0;

 fNextPeerEventTime.fValue:=TRNLUInt64(High(TRNLUInt64));

 fEventQueue:=TRNLHostEventQueue.Create;

 fAddress.Host:=RNL_HOST_ANY;
 fAddress.Port:=0;

 fPointerToAddress:=@fAddress;

 fAllowIncomingConnections:=true;

 for Index:=Low(TRNLPeerChannelTypes) to High(TRNLPeerChannelTypes) do begin
  case Index and 3 of
   0:begin
    fChannelTypes[Index]:=RNL_PEER_RELIABLE_ORDERED_CHANNEL;
   end;
   1:begin
    fChannelTypes[Index]:=RNL_PEER_RELIABLE_UNORDERED_CHANNEL;
   end;
   2:begin
    fChannelTypes[Index]:=RNL_PEER_UNRELIABLE_ORDERED_CHANNEL;
   end;
   else begin
    fChannelTypes[Index]:=RNL_PEER_UNRELIABLE_UNORDERED_CHANNEL;
   end;
  end;
 end;

 fMaximumCountPeers:=16;

 fMaximumCountChannels:=RNL_MAXIMUM_PEER_CHANNELS;

 fIncomingBandwidthLimit:=0;

 fOutgoingBandwidthLimit:=0;

 SetReliableChannelBlockPacketWindowSize(1024);

 fMaximumMessageSize:=16777216;

 fReceiveBufferSize:=262144;

 fSendBufferSize:=262144;

 SetMTU(0);

 fMTUDoFragment:=true;

 SetConnectionTimeout(0);

 SetPingInterval(0);

 SetPingResendTimeout(0);

 SetEncryptedPacketSequenceWindowSize(0);

 SetKeepAliveWindowSize(0);

 fProtocolID:=0;

 fSockets[0]:=RNL_SOCKET_NULL;
 fSockets[1]:=RNL_SOCKET_NULL;

 fSalt:=fRandomGenerator.GetUInt64;

 TRNLED25519.GeneratePublicPrivateKeyPair(fRandomGenerator,fLongTermPublicKey,fLongTermPrivateKey);

 fPendingConnectionTimeout:=10000;

 fPendingConnectionSendTimeout:=100;

 fPendingConnectionSaltTimeout:=1000;

 fPendingConnectionShortTermKeyPairTimeout:=1000;

 fPendingConnectionChallengeTimeout:=1000;

 fPendingConnectionNonceTimeout:=1000;

 fPendingDisconnectionTimeout:=5000;

 fPendingDisconnectionSendTimeout:=50;

 fPendingSendNewBandwidthLimitsSendTimeout:=50;

 fDefaultRoundTripTime:=500;

 fMinimumRetransmissionTimeout:=5000;

 fMaximumRetransmissionTimeout:=30000;

 fMinimumRetransmissionTimeoutLimit:=32;

 fMaximumRetransmissionTimeoutLimit:=320;

 fRateLimiterHostAddressBurst:=20;

 fRateLimiterHostAddressPeriod:=1000;

 fCheckConnectionTokens:=false;

 fCheckAuthenticationTokens:=false;

 fOnPeerCheckConnectionToken:=nil;

 fOnPeerCheckAuthenticationToken:=nil;

 fOnPeerConnect:=nil;

 fOnPeerDisconnect:=nil;

 fOnPeerApproval:=nil;

 fOnPeerDenial:=nil;

 fOnPeerBandwidthLimits:=nil;

 fOnPeerMTU:=nil;

 fOnPeerReceive:=nil;

 fTotalReceivedData:=0;

 fTotalReceivedPackets:=0;

 fConnectionCandidateHashTable:=nil;

 fConnectionKnownCandidateHostAddressHashTable:=nil;

 fIncomingBandwidthRateTracker.Reset;

 fOutgoingBandwidthRateTracker.Reset;

 Initialize(fOutgoingPacketBuffer);

end;

destructor TRNLHost.Destroy;
var Index:TRNLInt32;
    HostEvent:TRNLHostEvent;
begin

 for Index:=Low(TRNLHostSockets) to High(TRNLHostSockets) do begin
  if fSockets[Index]<>RNL_SOCKET_NULL then begin
   fNetwork.SocketDestroy(fSockets[Index]);
   fSockets[Index]:=RNL_SOCKET_NULL;
  end;
 end;

 try
  while fEventQueue.Dequeue(HostEvent) do begin
   HostEvent.Finalize;
  end;
 finally
  FreeAndNil(fEventQueue);
 end;

 try
  while not fPeerToFreeList.IsEmpty do begin
   fPeerToFreeList.Front.Value.DecRef;
  end;
 finally
  FreeAndNil(fPeerToFreeList);
 end;

{$if defined(RNL_LINEAR_PEER_LIST)}
 try
  while fPeerList.Count>0 do begin
   fPeerList[fPeerList.Count-1].DecRef;
  end;
 finally
  FreeAndNil(fPeerList);
 end;
{$else}
 try
  while not fPeerList.IsEmpty do begin
   fPeerList.Front.Value.DecRef;
  end;
 finally
  FreeAndNil(fPeerList);
 end;
{$ifend}

 FreeAndNil(fRandomGenerator);

 if assigned(fConnectionCandidateHashTable) then begin
  FreeMem(fConnectionCandidateHashTable);
  fConnectionCandidateHashTable:=nil;
 end;

 if assigned(fConnectionKnownCandidateHostAddressHashTable) then begin
  FreeMem(fConnectionKnownCandidateHostAddressHashTable);
  fConnectionKnownCandidateHostAddressHashTable:=nil;
 end;

 FreeAndNil(fPeerIDMap);

 FreeAndNil(fPeerIDManager);

 FreeAndNil(fPeerLock);

 Finalize(fOutgoingPacketBuffer);

 FreeAndNil(fCompressor);

 FreeAndNil(fNetworkEvent);

 inherited Destroy;
end;

function TRNLHost.GetInterruptible:boolean;
begin
 result:=assigned(fNetworkEvent);
end;

procedure TRNLHost.SetInterruptible(const aInterruptible:boolean);
begin
 if aInterruptible then begin
  if not assigned(fNetworkEvent) then begin
   fNetworkEvent:=TRNLNetworkEvent.Create;
  end;
 end else if assigned(fNetworkEvent) then begin
  FreeAndNil(fNetworkEvent);
 end;
end;

procedure TRNLHost.ClearPeerToFreeList;
begin
 while not fPeerToFreeList.IsEmpty do begin
  fPeerToFreeList.Front.Value.DecRef;
 end;
end;

procedure TRNLHost.SetReliableChannelBlockPacketWindowSize(const aReliableChannelBlockPacketWindowSize:TRNLUInt32);
begin
 fReliableChannelBlockPacketWindowSize:=Min(TRNLMath.RoundUpToPowerOfTwo32(aReliableChannelBlockPacketWindowSize),65536);
 fReliableChannelBlockPacketWindowMask:=fReliableChannelBlockPacketWindowSize-1;
end;

procedure TRNLHost.BroadcastNewBandwidthLimits;
var Peer:TRNLPeer;
begin
 for Peer in fPeerList do begin
  if Peer.fState in [RNL_PEER_STATE_CONNECTED,
                     RNL_PEER_STATE_DISCONNECT_LATER] then begin
   Peer.SendNewHostBandwidthLimits;
  end;
 end;
end;

procedure TRNLHost.SetIncomingBandwidthLimit(const aIncomingBandwidthLimit:TRNLUInt32);
begin
 if fIncomingBandwidthLimit<>aIncomingBandwidthLimit then begin
  fIncomingBandwidthLimit:=aIncomingBandwidthLimit;
  BroadcastNewBandwidthLimits;
 end;
end;

procedure TRNLHost.SetOutgoingBandwidthLimit(const aOutgoingBandwidthLimit:TRNLUInt32);
begin
 if OutgoingBandwidthLimit<>aOutgoingBandwidthLimit then begin
  fOutgoingBandwidthLimit:=aOutgoingBandwidthLimit;
  fOutgoingBandwidthRateLimiter.Setup(fOutgoingBandwidthLimit,1000);
  BroadcastNewBandwidthLimits;
 end;
end;

function TRNLHost.GetIncomingBandwidthRate:TRNLUInt32;
begin
 result:=fIncomingBandwidthRateTracker.UnitsPerSecond;
end;

function TRNLHost.GetOutgoingBandwidthRate:TRNLUInt32;
begin
 result:=fOutgoingBandwidthRateTracker.UnitsPerSecond;
end;

function TRNLHost.GetChannelType(const aIndex:TRNLUInt32):TRNLPeerChannelType;
begin
 result:=fChannelTypes[aIndex];
end;

procedure TRNLHost.SetChannelType(const aIndex:TRNLUInt32;const aChannelType:TRNLPeerChannelType);
begin
 fChannelTypes[aIndex]:=aChannelType;
end;

procedure TRNLHost.SetMaximumCountChannels(const aMaximumCountChannels:TRNLUInt32);
begin
 fMaximumCountChannels:=Min(Max(aMaximumCountChannels,1),RNL_MAXIMUM_PEER_CHANNELS);
end;

procedure TRNLHost.SetMTU(const aMTU:TRNLSizeUInt);
begin
 if aMTU=0 then begin
  fMTU:=900; // was 1500, but it is now lowered to 900 because some ISPs seem to drop
             // larger UDP packets (mainly RTSP DESCRIBE response packets)
 end else begin
  fMTU:=Min(Max(aMTU,RNL_MINIMUM_MTU),RNL_MAXIMUM_MTU);
 end;
end;

procedure TRNLHost.SetConnectionTimeout(const aConnectionTimeout:TRNLTime);
begin
 if aConnectionTimeout.fValue=0 then begin
  fConnectionTimeout:=10000;
 end else begin
  fConnectionTimeout:=aConnectionTimeout;
 end;
end;

procedure TRNLHost.SetPingInterval(const aPingInterval:TRNLTime);
begin
 if aPingInterval.fValue=0 then begin
  fPingInterval:=1000;
 end else begin
  fPingInterval:=aPingInterval;
 end;
end;

procedure TRNLHost.SetPingResendTimeout(const aPingResendTimeout:TRNLTime);
begin
 if aPingResendTimeout.fValue=0 then begin
  fPingResendTimeout:=100;
 end else begin
  fPingResendTimeout:=aPingResendTimeout;
 end;
end;

procedure TRNLHost.SetEncryptedPacketSequenceWindowSize(const aEncryptedPacketSequenceWindowSize:TRNLUInt32);
begin
 if aEncryptedPacketSequenceWindowSize=0 then begin
  fEncryptedPacketSequenceWindowSize:=256;
 end else if aEncryptedPacketSequenceWindowSize>65536 then begin
  fEncryptedPacketSequenceWindowSize:=65536;
 end else if aEncryptedPacketSequenceWindowSize<16 then begin
  fEncryptedPacketSequenceWindowSize:=16;
 end else begin
  fEncryptedPacketSequenceWindowSize:=TRNLMath.RoundUpToPowerOfTwo32(aEncryptedPacketSequenceWindowSize);
 end;
 fEncryptedPacketSequenceWindowMask:=fEncryptedPacketSequenceWindowSize-1;
end;

procedure TRNLHost.SetKeepAliveWindowSize(const aKeepAliveWindowSize:TRNLUInt32);
begin
 if aKeepAliveWindowSize=0 then begin
  fKeepAliveWindowSize:=4;
 end else if (aKeepAliveWindowSize>256) then begin
  fKeepAliveWindowSize:=256;
 end else if aKeepAliveWindowSize<1 then begin
  fKeepAliveWindowSize:=1;
 end else begin
  fKeepAliveWindowSize:=TRNLMath.RoundUpToPowerOfTwo32(aKeepAliveWindowSize);
 end;
 fKeepAliveWindowMask:=fKeepAliveWindowSize-1;
end;

function TRNLHost.SendPacket(const aAddress:TRNLAddress;const aData;const aDataLength:TRNLSizeUInt):TRNLNetworkSendResult;
var Index:TRNLInt32;
    Socket:TRNLSocket;
    Family:TRNLInt64;
begin
 Socket:=RNL_SOCKET_NULL;
 Family:=aAddress.GetAddressFamily;
 for Index:=Low(TRNLHostSockets) to High(TRNLHostSockets) do begin
  if (fSockets[Index]<>RNL_SOCKET_NULL) and
     ((fSocketFamilies[Index] and Family)<>0) then begin
   Socket:=fSockets[Index];
   Family:=HostSocketFamilies[Index];
   break;
  end;
 end;
 if Socket=RNL_SOCKET_NULL then begin
  result:=RNL_NETWORK_SEND_RESULT_ERROR;
 end else begin
  if fOutgoingBandwidthRateLimiter.CanProceed(aDataLength shl 3,fTime) then begin
   if fNetwork.Send(Socket,@aAddress,aData,aDataLength,Family)=TRNLSizeInt(aDataLength) then begin
    fOutgoingBandwidthRateLimiter.AddAmount(aDataLength shl 3,fTime);
    fOutgoingBandwidthRateTracker.AddUnits(aDataLength shl 3);
    result:=RNL_NETWORK_SEND_RESULT_OK;
   end else begin
    result:=RNL_NETWORK_SEND_RESULT_ERROR;
   end;
  end else begin
   // Drop the whole outgoing UDP packet for to satisfy the outgoing bandwidth limit (=> intended artificial packet loss)
   result:=RNL_NETWORK_SEND_RESULT_BANDWIDTH_RATE_LIMITER_DROP;
  end;
 end;
end;

procedure TRNLHost.ResetConnectionAttemptHistory;
begin
 fConnectionAttemptDeltaTime:=0;
 fConnectionAttemptLastTime:=0;
 fConnectionAttemptHasLastTime:=false;
 FillChar(fConnectionAttemptHistoryDeltaTimes,SizeOf(fConnectionAttemptHistoryDeltaTimes),#0);
 FillChar(fConnectionAttemptHistoryTimePoints,SizeOf(fConnectionAttemptHistoryTimePoints),#0);
 fConnectionAttemptHistoryReadIndex:=0;
 fConnectionAttemptHistoryWriteIndex:=0;
 fConnectionAttemptsPerSecond:=0;
end;

procedure TRNLHost.UpdateConnectionAttemptHistory(const aTime:TRNLTime);
var Index,Count:TRNLUInt32;
    SumOfConnectionAttemptTimes:TRNLUInt64;
begin

 if fConnectionAttemptHasLastTime then begin
  fConnectionAttemptDeltaTime:=aTime-fConnectionAttemptLastTime;
 end else begin
  fConnectionAttemptDeltaTime:=0;
 end;
 fConnectionAttemptLastTime:=aTime;
 fConnectionAttemptHasLastTime:=true;

 if fConnectionAttemptDeltaTime>0 then begin

  fConnectionAttemptHistoryDeltaTimes[fConnectionAttemptHistoryWriteIndex]:=fConnectionAttemptDeltaTime;
  fConnectionAttemptHistoryTimePoints[fConnectionAttemptHistoryWriteIndex]:=aTime;
  inc(fConnectionAttemptHistoryWriteIndex);
  if fConnectionAttemptHistoryWriteIndex>=RNL_CONNECTION_ATTEMPT_SIZE then begin
   fConnectionAttemptHistoryWriteIndex:=0;
  end;

  while (fConnectionAttemptHistoryReadIndex<>fConnectionAttemptHistoryWriteIndex) and
        ((aTime-fConnectionAttemptHistoryTimePoints[fConnectionAttemptHistoryReadIndex])>=1000) do begin
   inc(fConnectionAttemptHistoryReadIndex);
   if fConnectionAttemptHistoryReadIndex>=RNL_CONNECTION_ATTEMPT_SIZE then begin
    fConnectionAttemptHistoryReadIndex:=0;
   end;
  end;

 end;

 SumOfConnectionAttemptTimes:=0;
 Count:=0;
 Index:=fConnectionAttemptHistoryReadIndex;
 while Index<>fConnectionAttemptHistoryWriteIndex do begin
  SumOfConnectionAttemptTimes:=SumOfConnectionAttemptTimes+fConnectionAttemptHistoryDeltaTimes[Index];
  inc(Count);
  inc(Index);
  if Index>RNL_CONNECTION_ATTEMPT_SIZE then begin
   Index:=0;
  end;
 end;
 if (Count>0) and (SumOfConnectionAttemptTimes>0) then begin
  fConnectionAttemptsPerSecond:=(Count*1000) div SumOfConnectionAttemptTimes;
 end else if fConnectionAttemptDeltaTime>0 then begin
  fConnectionAttemptsPerSecond:=1000 div fConnectionAttemptDeltaTime;
 end else begin
  fConnectionAttemptsPerSecond:=0;
 end;

end;

procedure TRNLHost.Start(const aAddressFamilyWorkMode:TRNLHostAddressFamilyWorkMode=RNL_HOST_ADDRESS_FAMILY_WORK_MODE_IPV4_AND_IPV6);
 function CreateSocket(const aFamily:TRNLInt32;const aIPv4OnIPv6:boolean):TRNLSocket;
 begin
  result:=fNetwork.SocketCreate(RNL_SOCKET_TYPE_DATAGRAM,aFamily);
  if result<>RNL_SOCKET_NULL then begin
   case aFamily of
    RNL_IPV4:begin
     fNetwork.SocketSetOption(result,RNL_SOCKET_OPTION_DONTFRAGMENT,ord(not fMTUDoFragment) and 1);
    end;
    RNL_IPV6:begin
     if aIPv4OnIPv6 then begin
      fNetwork.SocketSetOption(result,RNL_SOCKET_OPTION_IPV6_V6ONLY,0);
     end else begin
      fNetwork.SocketSetOption(result,RNL_SOCKET_OPTION_IPV6_V6ONLY,1);
     end;
    end;
   end;
   if fNetwork.SocketBind(result,@fAddress,aFamily) then begin
    fNetwork.SocketSetOption(result,RNL_SOCKET_OPTION_NONBLOCK,1);
    fNetwork.SocketSetOption(result,RNL_SOCKET_OPTION_BROADCAST,1);
    fNetwork.SocketSetOption(result,RNL_SOCKET_OPTION_REUSEADDR,1);
    fNetwork.SocketSetOption(result,RNL_SOCKET_OPTION_RCVBUF,fReceiveBufferSize);
    fNetwork.SocketSetOption(result,RNL_SOCKET_OPTION_SNDBUF,fSendBufferSize);
    if aFamily=RNL_IPV4 then begin
     fNetwork.SocketSetOption(result,RNL_SOCKET_OPTION_DONTFRAGMENT,ord(not fMTUDoFragment) and 1);
    end;
   end else begin
    fNetwork.SocketDestroy(result);
    result:=RNL_SOCKET_NULL;
   end;
  end;
 end;
var Index,Families,Family:TRNLInt32;
    TemporaryAddress:TRNLAddress;
    Socket:TRNLSocket;
    IPv6OnIPv4:boolean;
begin

 case aAddressFamilyWorkMode of
  RNL_HOST_ADDRESS_FAMILY_WORK_MODE_IPV4_ONLY:begin
   Families:=RNL_IPV4;
  end;
  RNL_HOST_ADDRESS_FAMILY_WORK_MODE_IPV6_ONLY:begin
   Families:=RNL_IPV6;
  end;
  else {RNL_HOST_ADDRESS_FAMILY_WORK_MODE_IPV4_ON_IPV6,
        RNL_HOST_ADDRESS_FAMILY_WORK_MODE_IPV4_AND_IPV6,
        RNL_HOST_ADDRESS_FAMILY_WORK_MODE_AUTOMATIC:}begin
   Families:=RNL_IPV4 or RNL_IPV6;
  end;
 end;

 if not fAddress.Host.Equals(RNL_HOST_ANY) then begin
  Families:=Families and fAddress.GetAddressFamily;
 end;

 case aAddressFamilyWorkMode of
  RNL_HOST_ADDRESS_FAMILY_WORK_MODE_IPV4_ONLY,
  RNL_HOST_ADDRESS_FAMILY_WORK_MODE_IPV6_ONLY,
  RNL_HOST_ADDRESS_FAMILY_WORK_MODE_IPV4_AND_IPV6:begin
   for Index:=Low(TRNLHostSockets) to High(TRNLHostSockets) do begin
    Family:=HostSocketFamilies[Index];
    if (Families and Family)<>0 then begin
     IPv6OnIPv4:=(Family=RNL_IPV6) and
                 ((Families and RNL_IPV4)<>0) and
                 (aAddressFamilyWorkMode=RNL_HOST_ADDRESS_FAMILY_WORK_MODE_IPV4_AND_IPV6) and
                 (fSockets[0]=RNL_SOCKET_NULL);
     fSockets[Index]:=CreateSocket(Family,IPv6OnIPv4);
     if IPv6OnIPv4 then begin
      fSocketFamilies[Index]:=RNL_IPV4 or RNL_IPV6;
     end else begin
      fSocketFamilies[Index]:=Family;
     end;
    end else begin
     fSockets[Index]:=RNL_SOCKET_NULL;
     fSocketFamilies[Index]:=0;
    end;
   end;
  end;
  RNL_HOST_ADDRESS_FAMILY_WORK_MODE_IPV4_ON_IPV6:begin
   fSockets[0]:=RNL_SOCKET_NULL;
   fSocketFamilies[0]:=0;
   if (Families and RNL_IPV6)<>0 then begin
    fSockets[1]:=CreateSocket(RNL_IPV6,(Families and RNL_IPV4)<>0);
    if fSockets[1]<>RNL_SOCKET_NULL then begin
     if (Families and RNL_IPV4)<>0 then begin
      fSocketFamilies[1]:=RNL_IPV4 or RNL_IPV6;
     end else begin
      fSocketFamilies[1]:=RNL_IPV6;
     end;
    end else begin
     fSocketFamilies[1]:=0;
    end;
   end else begin
    fSockets[1]:=RNL_SOCKET_NULL;
    fSocketFamilies[1]:=0;
   end;
  end;
  else {RNL_HOST_ADDRESS_FAMILY_WORK_MODE_AUTOMATIC:}begin
   if (Families and RNL_IPV6)<>0 then begin
    fSockets[1]:=CreateSocket(RNL_IPV6,(Families and RNL_IPV4)<>0);
    if fSockets[1]<>RNL_SOCKET_NULL then begin
     fSockets[0]:=RNL_SOCKET_NULL;
     fSocketFamilies[0]:=0;
     if (Families and RNL_IPV4)<>0 then begin
      fSocketFamilies[1]:=RNL_IPV4 or RNL_IPV6;
     end else begin
      fSocketFamilies[1]:=RNL_IPV6;
     end;
    end else begin
     if (Families and RNL_IPV4)<>0 then begin
      fSockets[0]:=CreateSocket(RNL_IPV4,false);
      if fSockets[0]<>RNL_SOCKET_NULL then begin
       fSocketFamilies[0]:=RNL_IPV4;
      end else begin
       fSocketFamilies[0]:=0;
      end;
     end else begin
      fSockets[0]:=RNL_SOCKET_NULL;
      fSocketFamilies[0]:=0;
     end;
     fSockets[1]:=CreateSocket(RNL_IPV6,false);
     if fSockets[1]<>RNL_SOCKET_NULL then begin
      fSocketFamilies[1]:=RNL_IPV6;
     end else begin
      fSocketFamilies[1]:=0;
     end;
    end;
   end else begin
    fSockets[1]:=RNL_SOCKET_NULL;
    fSocketFamilies[1]:=0;
    if (Families and RNL_IPV4)<>0 then begin
     fSockets[0]:=CreateSocket(RNL_IPV4,false);
     if fSockets[0]<>RNL_SOCKET_NULL then begin
      fSocketFamilies[0]:=RNL_IPV4;
     end else begin
      fSocketFamilies[0]:=0;
     end;
    end else begin
     fSockets[0]:=RNL_SOCKET_NULL;
     fSocketFamilies[0]:=0;
    end;
   end;
  end;
 end;

 if (fSockets[0]=RNL_SOCKET_NULL) and (fSockets[1]=RNL_SOCKET_NULL) then begin
  raise ERNLHost.Create('Empty Socket');
 end;

 if fAddress.Host.Equals(RNL_HOST_ANY) then begin
  for Index:=Low(TRNLHostSockets) to High(TRNLHostSockets) do begin
   if (fSockets[Index]<>RNL_SOCKET_NULL) and
      fNetwork.SocketGetAddress(fSockets[Index],TemporaryAddress,HostSocketFamilies[Index]) then begin
    fAddress:=TemporaryAddress;
    break;
   end;
  end;
 end;

 if fAllowIncomingConnections then begin

  if assigned(fConnectionCandidateHashTable) then begin
   fConnectionCandidateHashTable^.Free;
   FreeMem(fConnectionCandidateHashTable);
   fConnectionCandidateHashTable:=nil;
  end;

  if assigned(fConnectionKnownCandidateHostAddressHashTable) then begin
   FreeMem(fConnectionKnownCandidateHostAddressHashTable);
   fConnectionKnownCandidateHostAddressHashTable:=nil;
  end;

  GetMem(fConnectionCandidateHashTable,SizeOf(TRNLConnectionCandidateHashTable));
  fConnectionCandidateHashTable^.Clear;

  GetMem(fConnectionKnownCandidateHostAddressHashTable,SizeOf(TRNLConnectionKnownCandidateHostAddressHashTable));
  fConnectionKnownCandidateHostAddressHashTable^.Clear;

  ResetConnectionAttemptHistory;

 end;

 fTime:=fInstance.Time;

 fIncomingBandwidthRateTracker.Reset;

 fOutgoingBandwidthRateTracker.Reset;

 fIncomingBandwidthRateTracker.SetTime(fTime);

 fOutgoingBandwidthRateTracker.SetTime(fTime);

 fIncomingBandwidthRateTracker.Update;

 fOutgoingBandwidthRateTracker.Update;

 fOutgoingBandwidthRateLimiter.Setup(fOutgoingBandwidthLimit,1000);

 fOutgoingBandwidthRateLimiter.Reset(fTime);

end;

function TRNLHost.Connect(const aAddress:TRNLAddress;
                          const aCountChannels:TRNLUInt32=1;
                          const aData:TRNLUInt64=0;
                          const aConnectionToken:PRNLConnectionToken=nil;
                          const aAuthenticationToken:PRNLAuthenticationToken=nil):TRNLPeer;
var Index:TRNLInt32;
//    Channel:TRNLChannel;
begin
 fTime:=fInstance.Time;
 if fCountPeers>=fMaximumCountPeers then begin
  raise ERNLHost.Create('No free peer available');
 end;
 result:=TRNLPeer.Create(self);
/// CurrentPeer.fConnectData:=aData;

 result.fState:=RNL_PEER_STATE_CONNECTION_REQUESTING;

 result.fNextPendingConnectionSendTimeout:=fTime+fPendingConnectionSendTimeout;

 result.fNextPendingConnectionSaltTimeout:=fTime+fPendingConnectionSaltTimeout;

 result.fAddress:=aAddress;

 result.fOutgoingEncryptedPacketSequenceNumber:=0;
 result.fIncomingEncryptedPacketSequenceNumber:=0;
 result.fIncomingEncryptedPacketSequenceBuffer:=nil;

 result.fLocalSalt:=fRandomGenerator.GetUInt64;

 result.fRemoteSalt:=0;

 result.SetCountChannels(aCountChannels);

 result.fDisconnectData:=aData;

 result.fConnectionData:=aData;

 result.fConnectionSalt:=result.fLocalSalt;

 result.fConnectionNonce:=0;

 result.fChecksumPlaceHolder:=result.fConnectionSalt xor (result.fConnectionSalt shl 32);

 TRNLX25519.GeneratePublicPrivateKeyPair(fRandomGenerator,
                                         result.fLocalShortTermPublicKey,
                                         result.fLocalShortTermPrivateKey);

 if assigned(result.fConnectionToken) then begin
  FreeMem(result.fConnectionToken);
  result.fConnectionToken:=nil;
 end;

 GetMem(result.fConnectionToken,SizeOf(TRNLConnectionToken));

 if assigned(aConnectionToken) then begin
  result.fConnectionToken^:=aConnectionToken^;
 end else begin
  for Index:=0 to SizeOf(TRNLConnectionToken)-1 do begin
   result.fConnectionToken^.Data[Index]:=fRandomGenerator.GetUInt32;
  end;
 end;

 if assigned(result.fAuthenticationToken) then begin
  FreeMem(result.fAuthenticationToken);
  result.fAuthenticationToken:=nil;
 end;

 GetMem(result.fAuthenticationToken,SizeOf(TRNLAuthenticationToken));

 if assigned(aAuthenticationToken) then begin
  result.fAuthenticationToken^:=aAuthenticationToken^;
 end else begin
  for Index:=0 to SizeOf(TRNLAuthenticationToken)-1 do begin
   result.fAuthenticationToken^.Data[Index]:=fRandomGenerator.GetUInt32;
  end;
 end;

 FreeAndNil(result.fPendingConnectionHandshakeSendData);

 result.fPendingConnectionHandshakeSendData:=TRNLPeerPendingConnectionHandshakeSendData.Create(result);
 result.fPendingConnectionHandshakeSendData.fHandshakePacket.Header.Signature:=RNLProtocolHandshakePacketHeaderSignature;
 result.fPendingConnectionHandshakeSendData.fHandshakePacket.Header.ProtocolVersion:=TRNLEndianness.HostToLittleEndian64(RNL_PROTOCOL_VERSION);
 result.fPendingConnectionHandshakeSendData.fHandshakePacket.Header.ProtocolID:=TRNLEndianness.HostToLittleEndian64(fProtocolID);
 result.fPendingConnectionHandshakeSendData.fHandshakePacket.Header.PacketType:=TRNLInt32(TRNLProtocolHandshakePacketType(RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_REQUEST));
 result.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionRequest.PeerID:=TRNLEndianness.HostToLittleEndian16(result.fLocalPeerID);
 result.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionRequest.OutgoingSalt:=TRNLEndianness.HostToLittleEndian64(result.fLocalSalt);
 result.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionRequest.IncomingBandwidthLimit:=TRNLEndianness.HostToLittleEndian32(fIncomingBandwidthLimit);
 result.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionRequest.OutgoingBandwidthLimit:=TRNLEndianness.HostToLittleEndian32(fOutgoingBandwidthLimit);
 result.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionRequest.ConnectionToken:=result.fConnectionToken^;
 result.fPendingConnectionHandshakeSendData.Send;

end;

procedure TRNLHost.AddHandshakePacketChecksum(var aHandshakePacket);
var PacketSize:TRNLSizeInt;
begin
 PacketSize:=RNLProtocolHandshakePacketSizes[TRNLProtocolHandshakePacketType(TRNLInt32(PRNLProtocolHandshakePacket(TRNLPointer(@aHandshakePacket))^.Header.PacketType))];
 PRNLProtocolHandshakePacket(TRNLPointer(@aHandshakePacket))^.Header.Checksum:=TRNLEndianness.HostToLittleEndian32(0);
 PRNLProtocolHandshakePacket(TRNLPointer(@aHandshakePacket))^.Header.Checksum:=ChecksumCRC32C(aHandshakePacket,PacketSize);
end;

function TRNLHost.VerifyHandshakePacketChecksum(var aHandshakePacket):boolean;
var PacketSize:TRNLSizeInt;
    DesiredChecksum:TRNLUInt32;
begin
 PacketSize:=RNLProtocolHandshakePacketSizes[TRNLProtocolHandshakePacketType(TRNLInt32(PRNLProtocolHandshakePacket(TRNLPointer(@aHandshakePacket))^.Header.PacketType))];
 DesiredChecksum:=TRNLEndianness.LittleEndianToHost32(PRNLProtocolHandshakePacket(TRNLPointer(@aHandshakePacket))^.Header.Checksum);
 PRNLProtocolHandshakePacket(TRNLPointer(@aHandshakePacket))^.Header.Checksum:=TRNLEndianness.HostToLittleEndian32(0);
 PRNLProtocolHandshakePacket(TRNLPointer(@aHandshakePacket))^.Header.Checksum:=TRNLEndianness.HostToLittleEndian32(ChecksumCRC32C(aHandshakePacket,PacketSize));
 result:=DesiredChecksum=TRNLEndianness.LittleEndianToHost32(PRNLProtocolHandshakePacket(TRNLPointer(@aHandshakePacket))^.Header.Checksum);
end;

procedure TRNLHost.AcceptHandshakeConnectionRequest(const aConnectionCandidate:PRNLConnectionCandidate);
var Index:TRNLInt32;
    OutgoingPacket:TRNLProtocolHandshakePacketConnectionChallengeRequest;
begin

 if not (assigned(aConnectionCandidate) and assigned(aConnectionCandidate^.fData)) then begin
  exit;
 end;

 if (aConnectionCandidate^.fData^.fNextChallengeTimeout.fValue=0) or
    (fTime>=aConnectionCandidate^.fData^.fNextChallengeTimeout.fValue) then begin

  aConnectionCandidate^.fData^.fNextChallengeTimeout:=fTime+fPendingConnectionChallengeTimeout;

  for Index:=0 to (SizeOf(TRNLConnectionChallenge) shr 3)-1 do begin
   PRNLUInt64Array(TRNLPointer(@aConnectionCandidate^.fData^.fChallenge))^[Index]:=fRandomGenerator.GetUInt64;
  end;

 end;

 OutgoingPacket.Header.Signature:=RNLProtocolHandshakePacketHeaderSignature;
 OutgoingPacket.Header.ProtocolVersion:=TRNLEndianness.HostToLittleEndian64(RNL_PROTOCOL_VERSION);
 OutgoingPacket.Header.ProtocolID:=TRNLEndianness.HostToLittleEndian64(fProtocolID);
 OutgoingPacket.Header.PacketType:=TRNLUInt32(TRNLProtocolHandshakePacketType(RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_CHALLENGE_REQUEST));
 OutgoingPacket.PeerID:=TRNLEndianness.HostToLittleEndian16(aConnectionCandidate^.fData^.fOutgoingPeerID);
 OutgoingPacket.OutgoingSalt:=TRNLEndianness.HostToLittleEndian64(aConnectionCandidate^.fRemoteSalt);
 OutgoingPacket.IncomingSalt:=TRNLEndianness.HostToLittleEndian64(aConnectionCandidate^.fLocalSalt);
 OutgoingPacket.IncomingBandwidthLimit:=TRNLEndianness.HostToLittleEndian32(fIncomingBandwidthLimit);
 OutgoingPacket.OutgoingBandwidthLimit:=TRNLEndianness.HostToLittleEndian32(fOutgoingBandwidthLimit);
 OutgoingPacket.CountChallengeRepetitions:=TRNLEndianness.HostToLittleEndian16(aConnectionCandidate^.fData^.fCountChallengeRepetitions);
 OutgoingPacket.Challenge:=aConnectionCandidate^.fData^.fChallenge;

 AddHandshakePacketChecksum(OutgoingPacket);

 SendPacket(fReceivedAddress,
            OutgoingPacket,
            SizeOf(TRNLProtocolHandshakePacketConnectionChallengeRequest));

 aConnectionCandidate^.fState:=RNL_CONNECTION_STATE_CHALLENGING;

end;

procedure TRNLHost.RejectHandshakeConnectionRequest(const aConnectionCandidate:PRNLConnectionCandidate);
begin
 if assigned(aConnectionCandidate^.fData) then begin
  Finalize(aConnectionCandidate^.fData^);
  FillChar(aConnectionCandidate^.fData^,SizeOf(TRNLConnectionCandidateData),#0);
  FreeMem(aConnectionCandidate^.fData);
  aConnectionCandidate^.fData:=nil;
 end;
 aConnectionCandidate^.fState:=RNL_CONNECTION_STATE_INVALID;
end;

procedure TRNLHost.DispatchReceivedHandshakePacketConnectionRequest(const aIncomingPacket:PRNLProtocolHandshakePacketConnectionRequest);
var ConnectionKnownCandidateHostAddress:PRNLConnectionKnownCandidateHostAddress;
    ConnectionCandidate:PRNLConnectionCandidate;
    HostEvent:TRNLHostEvent;
begin

{$if defined(RNL_DEBUG) and defined(RNL_DEBUG_SECURITY)}
 fInstance.fDebugLock.Acquire;
 try
  RNLDebugOutputString('DispatchReceivedHandshakePacketConnectionRequest');
 finally
  fInstance.fDebugLock.Release;
 end;
{$ifend}

 if not (assigned(fConnectionCandidateHashTable) and
         assigned(fConnectionKnownCandidateHostAddressHashTable)) then begin
  exit;
 end;

 UpdateConnectionAttemptHistory(fInstance.Time);

 fConnectionChallengeDifficultyLevel:=Min(Max((fConnectionAttemptsPerSecond*
                                               fConnectionAttemptsPerSecondChallengeDifficultyFactor) shr 12,
                                              0),
                                          65535);

 ConnectionKnownCandidateHostAddress:=fConnectionKnownCandidateHostAddressHashTable^.Find(fReceivedAddress.Host,
                                                                                          fInstance.Time,
                                                                                          true);
 if assigned(ConnectionKnownCandidateHostAddress) then begin
  if ConnectionKnownCandidateHostAddress^.RateLimiter.RateLimit(fInstance.Time,
                                                                 fRateLimiterHostAddressBurst,
                                                                 fRateLimiterHostAddressPeriod) then begin
   exit;
  end;
 end else begin
  exit;
 end;

 if fCheckConnectionTokens and
    assigned(fOnPeerCheckConnectionToken) and not
    fOnPeerCheckConnectionToken(self,fReceivedAddress,aIncomingPacket^.ConnectionToken) then begin
  exit;
 end;

 ConnectionCandidate:=fConnectionCandidateHashTable^.Find(fRandomGenerator,
                                                          fReceivedAddress,
                                                          TRNLEndianness.LittleEndianToHost64(aIncomingPacket^.OutgoingSalt),
                                                          fSalt,
                                                          fInstance.Time,
                                                          fPendingConnectionTimeout,
                                                          true);
 if assigned(ConnectionCandidate) then begin

  if not (ConnectionCandidate^.fState in [RNL_CONNECTION_STATE_REQUESTING,
                                          RNL_CONNECTION_STATE_CHALLENGING]) then begin
   exit;
  end;

  if assigned(ConnectionCandidate^.fData) then begin
   if TRNLMemory.SecureIsNotEqual(ConnectionCandidate^.fAddress,fReceivedAddress,SizeOf(TRNLAddress)) or
      (ConnectionCandidate^.fRemoteSalt<>TRNLEndianness.LittleEndianToHost64(aIncomingPacket^.OutgoingSalt)) then begin
    Finalize(ConnectionCandidate^.fData^);
    FillChar(ConnectionCandidate^.fData^,SizeOf(TRNLConnectionCandidateData),#0);
    Initialize(ConnectionCandidate^.fData^);
   end;
  end else begin
   GetMem(ConnectionCandidate^.fData,SizeOf(TRNLConnectionCandidateData));
   FillChar(ConnectionCandidate^.fData^,SizeOf(TRNLConnectionCandidateData),#0);
   Initialize(ConnectionCandidate^.fData^);
  end;

  ConnectionCandidate^.fData^.fOutgoingPeerID:=TRNLEndianness.LittleEndianToHost16(aIncomingPacket^.PeerID);

  ConnectionCandidate^.fData^.fIncomingBandwidthLimit:=TRNLEndianness.LittleEndianToHost32(aIncomingPacket^.IncomingBandwidthLimit);
  ConnectionCandidate^.fData^.fOutgoingBandwidthLimit:=TRNLEndianness.LittleEndianToHost32(aIncomingPacket^.OutgoingBandwidthLimit);

  ConnectionCandidate^.fData^.fCountChallengeRepetitions:=Max(1,fConnectionChallengeDifficultyLevel);

  if assigned(fOnPeerCheckConnectionToken) or not fCheckConnectionTokens then begin

   AcceptHandshakeConnectionRequest(ConnectionCandidate);

  end else begin

   ConnectionCandidate^.fData.fHost:=self;

   ConnectionCandidate^.fData.fConnectionToken:=aIncomingPacket^.ConnectionToken;

   HostEvent.Initialize;
   try
    HostEvent.Type_:=RNL_HOST_EVENT_TYPE_PEER_CHECK_CONNECTION_TOKEN;
    HostEvent.Peer:=nil;
    HostEvent.Message:=nil;
    HostEvent.ConnectionCandidate:=ConnectionCandidate;
   finally
    fEventQueue.Enqueue(HostEvent);
   end;

  end;

 end;

end;

procedure TRNLHost.DispatchReceivedHandshakePacketConnectionChallengeRequest(const aIncomingPacket:PRNLProtocolHandshakePacketConnectionChallengeRequest);
var Index:TRNLInt32;
    PeerID:TRNLID;
    Peer:TRNLPeer;
    LocalSalt,RemoteSalt:TRNLUInt64;
begin

{$if defined(RNL_DEBUG) and defined(RNL_DEBUG_SECURITY)}
 fInstance.fDebugLock.Acquire;
 try
  RNLDebugOutputString('DispatchReceivedHandshakePacketConnectionChallengeRequest');
 finally
  fInstance.fDebugLock.Release;
 end;
{$ifend}

 PeerID:=TRNLEndianness.LittleEndianToHost16(aIncomingPacket^.PeerID);

 Peer:=fPeerIDMap[PeerID];
 if not assigned(Peer) then begin
  exit;
 end;

 RemoteSalt:=TRNLEndianness.LittleEndianToHost64(aIncomingPacket^.IncomingSalt);
 LocalSalt:=TRNLEndianness.LittleEndianToHost64(aIncomingPacket^.OutgoingSalt);

 if Peer.fLocalSalt<>LocalSalt then begin
  exit;
 end;

 if Peer.fState<>RNL_PEER_STATE_CONNECTION_REQUESTING then begin
  exit;
 end;

 Peer.fRemoteSalt:=RemoteSalt;

 Peer.fConnectionSalt:=Peer.fLocalSalt xor Peer.fRemoteSalt;

 Peer.fRemoteIncomingBandwidthLimit:=TRNLEndianness.LittleEndianToHost32(aIncomingPacket^.IncomingBandwidthLimit);

 Peer.fRemoteOutgoingBandwidthLimit:=TRNLEndianness.LittleEndianToHost32(aIncomingPacket^.OutgoingBandwidthLimit);

 Peer.fChecksumPlaceHolder:=Peer.fConnectionSalt xor (Peer.fConnectionSalt shl 32);

 if assigned(Peer.fConnectionChallengeResponse) then begin
  FreeMem(Peer.fConnectionChallengeResponse);
 end;

 GetMem(Peer.fConnectionChallengeResponse,SizeOf(TRNLConnectionChallenge));

 Peer.fConnectionChallengeResponse^:=aIncomingPacket^.Challenge;

 for Index:=1 to TRNLEndianness.LittleEndianToHost16(aIncomingPacket^.CountChallengeRepetitions) do begin
{$ifdef RNLUseBLAKE2B}
  TRNLBLAKE2B.Process(Peer.fConnectionChallengeResponse^,
                      Peer.fConnectionChallengeResponse^,
                      SizeOf(TRNLConnectionChallenge));
{$else}
  TRNLSHA512.Process(Peer.fConnectionChallengeResponse^,
                     Peer.fConnectionChallengeResponse^,
                     SizeOf(TRNLConnectionChallenge));
{$endif}
 end;

 Peer.fConnectionNonce:=PRNLUInt64(TRNLPointer(Peer.fConnectionChallengeResponse))^;

 FreeAndNil(Peer.fPendingConnectionHandshakeSendData);

 Peer.fPendingConnectionHandshakeSendData:=TRNLPeerPendingConnectionHandshakeSendData.Create(Peer);
 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.Header.Signature:=RNLProtocolHandshakePacketHeaderSignature;
 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.Header.ProtocolVersion:=TRNLEndianness.HostToLittleEndian64(RNL_PROTOCOL_VERSION);
 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.Header.ProtocolID:=TRNLEndianness.HostToLittleEndian64(fProtocolID);
 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.Header.PacketType:=TRNLInt32(TRNLProtocolHandshakePacketType(RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_CHALLENGE_RESPONSE));
 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionChallengeResponse.ConnectionSalt:=TRNLEndianness.HostToLittleEndian64(Peer.fConnectionSalt);
 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionChallengeResponse.ShortTermPublicKey:=Peer.fLocalShortTermPublicKey;
 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionChallengeResponse.ChallengeResponse:=Peer.fConnectionChallengeResponse^;
 Peer.fPendingConnectionHandshakeSendData.Send;

 Peer.fNextPendingConnectionSendTimeout:=fTime+fPendingConnectionSendTimeout;

 Peer.fNextPendingConnectionShortTermKeyPairTimeout:=fTime+fPendingConnectionShortTermKeyPairTimeout;

 Peer.fState:=RNL_PEER_STATE_CONNECTION_CHALLENGING;

end;

procedure TRNLHost.DispatchReceivedHandshakePacketConnectionChallengeResponse(const aIncomingPacket:PRNLProtocolHandshakePacketConnectionChallengeResponse);
var Index:TRNLInt32;
    ConnectionCandidate:PRNLConnectionCandidate;
    ConnectionSalt,ChallengeResult:TRNLUInt64;
    OutgoingPacket:TRNLProtocolHandshakePacket;
    Nonce:TRNLCipherNonce;
    TwoKeys:TRNLTwoKeys;
begin

{$if defined(RNL_DEBUG) and defined(RNL_DEBUG_SECURITY)}
 fInstance.fDebugLock.Acquire;
 try
  RNLDebugOutputString('DispatchReceivedHandshakePacketConnectionChallengeResponse');
 finally
  fInstance.fDebugLock.Release;
 end;
{$ifend}

 if not (assigned(fConnectionCandidateHashTable) and
         assigned(fConnectionKnownCandidateHostAddressHashTable)) then begin
  exit;
 end;

 ConnectionCandidate:=fConnectionCandidateHashTable^.Find(fRandomGenerator,
                                                          fReceivedAddress,
                                                          TRNLEndianness.LittleEndianToHost64(aIncomingPacket^.ConnectionSalt) xor fSalt,
                                                          fSalt,
                                                          fInstance.Time,
                                                          fPendingConnectionTimeout,
                                                          false);

 if assigned(ConnectionCandidate) then begin

  if not (ConnectionCandidate^.fState in [RNL_CONNECTION_STATE_CHALLENGING,
                                          RNL_CONNECTION_STATE_AUTHENTICATING]) then begin
   exit;
  end;

  if not assigned(ConnectionCandidate^.fData) then begin
   exit;
  end;

  ConnectionSalt:=ConnectionCandidate^.fLocalSalt xor ConnectionCandidate^.fRemoteSalt;
  if ConnectionSalt<>TRNLEndianness.LittleEndianToHost64(aIncomingPacket^.ConnectionSalt) then begin
   exit;
  end;

  ConnectionCandidate^.fData^.fSolvedChallenge:=ConnectionCandidate^.fData^.fChallenge;

  for Index:=1 to ConnectionCandidate^.fData^.fCountChallengeRepetitions do begin
{$ifdef RNLUseBLAKE2B}
   TRNLBLAKE2B.Process(ConnectionCandidate^.fData^.fSolvedChallenge,
                       ConnectionCandidate^.fData^.fSolvedChallenge,
                       SizeOf(TRNLConnectionChallenge));
{$else}
   TRNLSHA512.Process(ConnectionCandidate^.fData^.fSolvedChallenge,
                      ConnectionCandidate^.fData^.fSolvedChallenge,
                      SizeOf(TRNLConnectionChallenge));
{$endif}
  end;

  ChallengeResult:=0;
  for Index:=0 to (SizeOf(TRNLConnectionChallenge) shr 3)-1 do begin
   ChallengeResult:=ChallengeResult or
                    (PRNLUInt64Array(TRNLPointer(@ConnectionCandidate^.fData^.fSolvedChallenge))^[Index] xor
                     PRNLUInt64Array(TRNLPointer(@aIncomingPacket^.ChallengeResponse))^[Index]);
  end;

  if ChallengeResult<>0 then begin
   exit;
  end;

  if (ConnectionCandidate^.fData^.fNextShortTermKeyPairTimeout.fValue=0) or
     (fTime>=ConnectionCandidate^.fData^.fNextShortTermKeyPairTimeout) then begin

   ConnectionCandidate^.fData^.fNextShortTermKeyPairTimeout:=fTime+fPendingConnectionShortTermKeyPairTimeout;

   TRNLX25519.GeneratePublicPrivateKeyPair(fRandomGenerator,
                                           ConnectionCandidate^.fData^.fLocalShortTermPublicKey,
                                           ConnectionCandidate^.fData^.fLocalShortTermPrivateKey);

  end;

  ConnectionCandidate^.fData^.fRemoteShortTermPublicKey:=aIncomingPacket^.ShortTermPublicKey;

  TRNLX25519.GenerateSharedSecretKey(ConnectionCandidate^.fData^.fSharedSecretKey,
                                     ConnectionCandidate^.fData^.fRemoteShortTermPublicKey,
                                     ConnectionCandidate^.fData^.fLocalShortTermPrivateKey);
 {$if defined(RNL_DEBUG) and defined(RNL_DEBUG_SECURITY_EXTENDED)}
  fInstance.fDebugLock.Acquire;
  try
   RNLDebugOutputString('HandleConnectionRequest SharedSecretKey: '+IntToStr(ConnectionCandidate^.fData^.fSharedSecretKey.ui32[0])+' '+IntToStr(ConnectionCandidate^.fData^.fSharedSecretKey.ui32[1])+' '+IntToStr(ConnectionCandidate^.fData^.fSharedSecretKey.ui32[2])+' '+IntToStr(ConnectionCandidate^.fData^.fSharedSecretKey.ui32[3]));
  finally
   fInstance.fDebugLock.Release;
  end;
 {$ifend}

  if (ConnectionCandidate^.fData^.fNextNonceTimeout.fValue=0) or
     (fTime>=ConnectionCandidate^.fData^.fNextNonceTimeout) then begin

   ConnectionCandidate^.fData^.fNextNonceTimeout:=fTime+fPendingConnectionNonceTimeout;

   ConnectionCandidate^.fData^.fNonce:=fRandomGenerator.GetUInt64;

  end;

  OutgoingPacket.Header.Signature:=RNLProtocolHandshakePacketHeaderSignature;
  OutgoingPacket.Header.ProtocolVersion:=TRNLEndianness.HostToLittleEndian64(RNL_PROTOCOL_VERSION);
  OutgoingPacket.Header.ProtocolID:=TRNLEndianness.HostToLittleEndian64(fProtocolID);

  OutgoingPacket.Header.PacketType:=TRNLUInt32(TRNLProtocolHandshakePacketType(RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_AUTHENTICATION_REQUEST));

  OutgoingPacket.ConnectionAuthenticationRequest.PeerID:=TRNLEndianness.HostToLittleEndian16(ConnectionCandidate^.fData^.fOutgoingPeerID);
  OutgoingPacket.ConnectionAuthenticationRequest.ConnectionSalt:=TRNLEndianness.HostToLittleEndian64(ConnectionSalt);
  OutgoingPacket.ConnectionAuthenticationRequest.ShortTermPublicKey:=ConnectionCandidate^.fData^.fLocalShortTermPublicKey;
  OutgoingPacket.ConnectionAuthenticationRequest.Nonce:=TRNLEndianness.HostToLittleEndian64(ConnectionCandidate^.fData^.fNonce);

  OutgoingPacket.ConnectionAuthenticationRequest.Payload.LongTermPublicKey:=fLongTermPublicKey;

  OutgoingPacket.ConnectionAuthenticationRequest.Payload.MTU:=TRNLEndianness.HostToLittleEndian16(fMTU);

  TwoKeys[0]:=ConnectionCandidate^.fData^.fLocalShortTermPublicKey;
  TwoKeys[1]:=ConnectionCandidate^.fData^.fRemoteShortTermPublicKey;

  TRNLED25519.Sign(OutgoingPacket.ConnectionAuthenticationRequest.Payload.Signature,
                   fLongTermPrivateKey,
                   fLongTermPublicKey,
                   TwoKeys,
                   SizeOf(TRNLTwoKeys));

  PRNLUInt64Array(TRNLPointer(@Nonce))^[0]:=TRNLEndianness.HostToLittleEndian64(ConnectionCandidate^.fData^.fNonce);
  PRNLUInt64Array(TRNLPointer(@Nonce))^[1]:=TRNLEndianness.HostToLittleEndian64(ConnectionCandidate^.fRemoteSalt);
  PRNLUInt64Array(TRNLPointer(@Nonce))^[2]:=TRNLEndianness.HostToLittleEndian64(ConnectionCandidate^.fLocalSalt);

  if not TRNLAuthenticatedEncryption.Encrypt(OutgoingPacket.ConnectionAuthenticationRequest.Payload,
                                             ConnectionCandidate^.fData^.fSharedSecretKey,
                                             Nonce,
                                             OutgoingPacket.ConnectionAuthenticationRequest.PayloadMAC,
                                             ConnectionCandidate^.fData^.fSolvedChallenge,
                                             SizeOf(TRNLConnectionChallenge),
                                             OutgoingPacket.ConnectionAuthenticationRequest.Payload,
                                             SizeOf(TTRNLProtocolHandshakePacketConnectionAuthenticationRequestPayload)) then begin
   exit;
  end;

  AddHandshakePacketChecksum(OutgoingPacket);

  SendPacket(fReceivedAddress,
             OutgoingPacket,
             SizeOf(TRNLProtocolHandshakePacketConnectionAuthenticationRequest));

  ConnectionCandidate^.fState:=RNL_CONNECTION_STATE_AUTHENTICATING;

 end;

end;

procedure TRNLHost.DispatchReceivedHandshakePacketConnectionAuthenticationRequest(const aIncomingPacket:PRNLProtocolHandshakePacketConnectionAuthenticationRequest);
var Index:TRNLInt32;
    PeerID:TRNLID;
    Peer:TRNLPeer;
    Nonce:TRNLCipherNonce;
    TwoKeys:TRNLTwoKeys;
begin

{$if defined(RNL_DEBUG) and defined(RNL_DEBUG_SECURITY)}
 fInstance.fDebugLock.Acquire;
 try
  RNLDebugOutputString('DispatchReceivedHandshakePacketConnectionAuthenticationRequest');
 finally
  fInstance.fDebugLock.Release;
 end;
{$ifend}

 PeerID:=TRNLEndianness.LittleEndianToHost16(aIncomingPacket^.PeerID);

 Peer:=fPeerIDMap[PeerID];
 if not assigned(Peer) then begin
  exit;
 end;

 if Peer.fConnectionSalt<>TRNLEndianness.LittleEndianToHost64(aIncomingPacket^.ConnectionSalt) then begin
  exit;
 end;

 if Peer.fState<>RNL_PEER_STATE_CONNECTION_CHALLENGING then begin
  exit;
 end;

 TRNLX25519.GenerateSharedSecretKey(Peer.fSharedSecretKey,
                                    aIncomingPacket^.ShortTermPublicKey,
                                    Peer.fLocalShortTermPrivateKey);

{$if defined(RNL_DEBUG) and defined(RNL_DEBUG_SECURITY_EXTENDED)}
 fInstance.fDebugLock.Acquire;
 try
  RNLDebugOutputString('HandleConnectionAuthenticationRequest SharedSecretKey: '+IntToStr(Peer.fSharedSecretKey.ui32[0])+' '+
                                                                                 IntToStr(Peer.fSharedSecretKey.ui32[1])+' '+
                                                                                 IntToStr(Peer.fSharedSecretKey.ui32[2])+' '+
                                                                                 IntToStr(Peer.fSharedSecretKey.ui32[3]));
 finally
  fInstance.fDebugLock.Release;
 end;
{$ifend}

 PRNLUInt64Array(TRNLPointer(@Nonce))^[0]:=aIncomingPacket^.Nonce;
 PRNLUInt64Array(TRNLPointer(@Nonce))^[1]:=TRNLEndianness.HostToLittleEndian64(Peer.fLocalSalt);
 PRNLUInt64Array(TRNLPointer(@Nonce))^[2]:=TRNLEndianness.HostToLittleEndian64(Peer.fRemoteSalt);

 if not TRNLAuthenticatedEncryption.Decrypt(aIncomingPacket^.Payload,
                                            Peer.fSharedSecretKey,
                                            Nonce,
                                            aIncomingPacket^.PayloadMAC,
                                            Peer.fConnectionChallengeResponse^,
                                            SizeOf(TRNLConnectionChallenge),
                                            aIncomingPacket^.Payload,
                                            SizeOf(TTRNLProtocolHandshakePacketConnectionAuthenticationRequestPayload)) then begin
  exit;
 end;

 TwoKeys[0]:=aIncomingPacket^.ShortTermPublicKey;
 TwoKeys[1]:=Peer.fLocalShortTermPublicKey;

 if not TRNLED25519.Verify(aIncomingPacket^.Payload.Signature,
                           aIncomingPacket^.Payload.LongTermPublicKey,
                           TwoKeys,
                           SizeOf(TRNLTwoKeys)) then begin
  exit;
 end;

 Peer.fRemoteMTU:=TRNLEndianness.LittleEndianToHost16(aIncomingPacket^.Payload.MTU);

 Peer.fMTU:=Min(Max(Min(fMTU,Peer.fRemoteMTU),RNL_MINIMUM_MTU),RNL_MAXIMUM_MTU);

 FreeAndNil(Peer.fPendingConnectionHandshakeSendData);

 Peer.fPendingConnectionHandshakeSendData:=TRNLPeerPendingConnectionHandshakeSendData.Create(Peer);
 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.Header.Signature:=RNLProtocolHandshakePacketHeaderSignature;
 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.Header.ProtocolVersion:=TRNLEndianness.HostToLittleEndian64(RNL_PROTOCOL_VERSION);
 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.Header.ProtocolID:=TRNLEndianness.HostToLittleEndian64(fProtocolID);
 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.Header.PacketType:=TRNLInt32(TRNLProtocolHandshakePacketType(RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_AUTHENTICATION_RESPONSE));
 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionAuthenticationResponse.ConnectionSalt:=TRNLEndianness.HostToLittleEndian64(Peer.fConnectionSalt);
 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionAuthenticationResponse.Nonce:=TRNLEndianness.HostToLittleEndian64(fRandomGenerator.GetUInt64);

 PRNLUInt64Array(TRNLPointer(@Nonce))^[0]:=aIncomingPacket^.Nonce;
 PRNLUInt64Array(TRNLPointer(@Nonce))^[1]:=Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionAuthenticationResponse.Nonce;
 PRNLUInt64Array(TRNLPointer(@Nonce))^[2]:=Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionAuthenticationResponse.ConnectionSalt;

 if assigned(Peer.fAuthenticationToken) then begin
  Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionAuthenticationResponse.Payload.AuthenticationToken:=Peer.fAuthenticationToken^;
 end else begin
  FillChar(Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionAuthenticationResponse.Payload.AuthenticationToken,SizeOf(TRNLAuthenticationToken),#0);
 end;

//Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionAuthenticationResponse.Payload.Data:=TRNLEndianness.HostToLittleEndian32(fConnectData);

 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionAuthenticationResponse.Payload.LongTermPublicKey:=fLongTermPublicKey;

 TwoKeys[0]:=Peer.fLocalShortTermPublicKey;
 TwoKeys[1]:=aIncomingPacket^.ShortTermPublicKey;

 TRNLED25519.Sign(Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionAuthenticationResponse.Payload.Signature,
                  fLongTermPrivateKey,
                  fLongTermPublicKey,
                  TwoKeys,
                  SizeOf(TRNLTwoKeys));

 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionAuthenticationResponse.Payload.MTU:=TRNLEndianness.HostToLittleEndian16(fMTU);

 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionAuthenticationResponse.Payload.CountChannels:=TRNLEndianness.HostToLittleEndian16(Peer.fCountChannels);

 for Index:=Low(TRNLPeerChannelTypes) to High(TRNLPeerChannelTypes) do begin
  Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionAuthenticationResponse.Payload.ChannelTypes[Index]:=TRNLInt32(TRNLPeerChannelType(fChannelTypes[Index]));
 end;

 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionAuthenticationResponse.Payload.Data:=TRNLEndianness.HostToLittleEndian64(Peer.fConnectionData);

 if not TRNLAuthenticatedEncryption.Encrypt(Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionAuthenticationResponse.Payload,
                                            Peer.fSharedSecretKey,
                                            Nonce,
                                            Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionAuthenticationResponse.PayloadMAC,
                                            Peer.fConnectionChallengeResponse^,
                                            SizeOf(TRNLConnectionChallenge),
                                            Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionAuthenticationResponse.Payload,
                                            SizeOf(TRNLProtocolHandshakePacketConnectionAuthenticationResponsePayload)
                                           ) then begin
  exit;
 end;

 Peer.fPendingConnectionHandshakeSendData.Send;

 Peer.fNextPendingConnectionSendTimeout:=fTime+fPendingConnectionSendTimeout;

 Peer.fState:=RNL_PEER_STATE_CONNECTION_AUTHENTICATING;

end;

function TRNLHost.AcceptHandshakePacketConnectionAuthenticationResponse(const aConnectionCandidate:PRNLConnectionCandidate):TRNLPeer;
var ConnectionSalt:TRNLUInt64;
    Peer:TRNLPeer;
    Nonce:TRNLCipherNonce;
begin

 result:=nil;

 if not assigned(aConnectionCandidate^.fData) then begin
  exit;
 end;

 ConnectionSalt:=aConnectionCandidate^.fLocalSalt xor aConnectionCandidate^.fRemoteSalt;

 if assigned(aConnectionCandidate^.fData^.fPeer) then begin

  Peer:=aConnectionCandidate^.fData^.fPeer;

 end else begin

  Peer:=TRNLPeer.Create(self);

  aConnectionCandidate^.fData^.fPeer:=Peer;

  Peer.fAddress:=fReceivedAddress;

  Peer.fRemoteMTU:=aConnectionCandidate^.fData^.fMTU;

  Peer.fMTU:=Min(Max(Min(fMTU,Peer.fRemoteMTU),RNL_MINIMUM_MTU),RNL_MAXIMUM_MTU);

  Peer.fRemotePeerID:=aConnectionCandidate^.fData^.fOutgoingPeerID;

  Peer.fRemoteSalt:=aConnectionCandidate^.fRemoteSalt;

  Peer.fLocalSalt:=aConnectionCandidate^.fLocalSalt;

  Peer.SetCountChannels(aConnectionCandidate^.fData^.fRemoteCountChannels);

  Peer.fConnectionSalt:=ConnectionSalt;

  Peer.fConnectionNonce:=PRNLUInt64(TRNLPointer(@aConnectionCandidate^.fData^.fSolvedChallenge))^;

  Peer.fChecksumPlaceHolder:=Peer.fConnectionSalt xor (Peer.fConnectionSalt shl 32);

  Peer.fSharedSecretKey:=aConnectionCandidate^.fData^.fSharedSecretKey;

 end;

 Peer.fConnectionData:=aConnectionCandidate^.fData^.fData;

 Peer.fRemoteIncomingBandwidthLimit:=aConnectionCandidate^.fData^.fIncomingBandwidthLimit;

 Peer.fRemoteOutgoingBandwidthLimit:=aConnectionCandidate^.fData^.fOutgoingBandwidthLimit;

 Peer.fLastReceivedDataTime:=fTime;

 FreeAndNil(Peer.fPendingConnectionHandshakeSendData);

 Peer.fPendingConnectionHandshakeSendData:=TRNLPeerPendingConnectionHandshakeSendData.Create(Peer);
 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.Header.Signature:=RNLProtocolHandshakePacketHeaderSignature;
 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.Header.ProtocolVersion:=TRNLEndianness.HostToLittleEndian64(RNL_PROTOCOL_VERSION);
 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.Header.ProtocolID:=TRNLEndianness.HostToLittleEndian64(fProtocolID);
 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.Header.PacketType:=TRNLInt32(TRNLProtocolHandshakePacketType(RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_APPROVAL_RESPONSE));

 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionApprovalResponse.PeerID:=TRNLEndianness.HostToLittleEndian16(aConnectionCandidate^.fData^.fOutgoingPeerID);
 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionApprovalResponse.ConnectionSalt:=TRNLEndianness.HostToLittleEndian64(ConnectionSalt);
 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionApprovalResponse.Nonce:=TRNLEndianness.HostToLittleEndian64(aConnectionCandidate^.fData^.fNonce);

 Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionApprovalResponse.Payload.PeerID:=TRNLEndianness.HostToLittleEndian16(Peer.fLocalPeerID);

 PRNLUInt64Array(TRNLPointer(@Nonce))^[0]:=TRNLEndianness.HostToLittleEndian64(aConnectionCandidate^.fData^.fNonce);
 PRNLUInt64Array(TRNLPointer(@Nonce))^[1]:=TRNLEndianness.HostToLittleEndian64(aConnectionCandidate^.fRemoteSalt);
 PRNLUInt64Array(TRNLPointer(@Nonce))^[2]:=TRNLEndianness.HostToLittleEndian64(aConnectionCandidate^.fLocalSalt);

 if not TRNLAuthenticatedEncryption.Encrypt(Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionApprovalResponse.Payload,
                                            aConnectionCandidate^.fData^.fSharedSecretKey,
                                            Nonce,
                                            Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionApprovalResponse.PayloadMAC,
                                            aConnectionCandidate^.fData^.fSolvedChallenge,
                                            SizeOf(TRNLConnectionChallenge),
                                            Peer.fPendingConnectionHandshakeSendData.fHandshakePacket.ConnectionApprovalResponse.Payload,
                                            SizeOf(TRNLProtocolHandshakePacketConnectionApprovalResponsePayload)) then begin
  exit;
 end;

 Peer.fPendingConnectionHandshakeSendData.Send;

 Peer.fState:=RNL_PEER_STATE_CONNECTION_APPROVING;

 Peer.fNextPendingConnectionSendTimeout:=fTime+fPendingConnectionSendTimeout;

 Peer.UpdateOutgoingBandwidthRateLimiter;

 aConnectionCandidate^.fState:=RNL_CONNECTION_STATE_APPROVING;

 result:=Peer;

end;

procedure TRNLHost.RejectHandshakePacketConnectionAuthenticationResponse(const aConnectionCandidate:PRNLConnectionCandidate;const aDenialReason:TRNLConnectionDenialReason);
var ConnectionSalt:TRNLUInt64;
    OutgoingPacket:TRNLProtocolHandshakePacket;
    Nonce:TRNLCipherNonce;
begin

 if assigned(aConnectionCandidate^.fData) then begin

  ConnectionSalt:=aConnectionCandidate^.fLocalSalt xor aConnectionCandidate^.fRemoteSalt;

  OutgoingPacket.Header.Signature:=RNLProtocolHandshakePacketHeaderSignature;
  OutgoingPacket.Header.ProtocolVersion:=TRNLEndianness.HostToLittleEndian64(RNL_PROTOCOL_VERSION);
  OutgoingPacket.Header.ProtocolID:=TRNLEndianness.HostToLittleEndian64(fProtocolID);

  OutgoingPacket.Header.PacketType:=TRNLUInt32(TRNLProtocolHandshakePacketType(RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_DENIAL_RESPONSE));

  OutgoingPacket.ConnectionDenialResponse.PeerID:=TRNLEndianness.HostToLittleEndian16(aConnectionCandidate^.fData^.fOutgoingPeerID);
  OutgoingPacket.ConnectionDenialResponse.ConnectionSalt:=TRNLEndianness.HostToLittleEndian64(ConnectionSalt);
  OutgoingPacket.ConnectionDenialResponse.Nonce:=TRNLEndianness.HostToLittleEndian64(aConnectionCandidate^.fData^.fNonce);

  OutgoingPacket.ConnectionDenialResponse.Payload.Reason:=TRNLInt32(TRNLConnectionDenialReason(aDenialReason));

  PRNLUInt64Array(TRNLPointer(@Nonce))^[0]:=TRNLEndianness.HostToLittleEndian64(aConnectionCandidate^.fData^.fNonce);
  PRNLUInt64Array(TRNLPointer(@Nonce))^[1]:=TRNLEndianness.HostToLittleEndian64(aConnectionCandidate^.fRemoteSalt);
  PRNLUInt64Array(TRNLPointer(@Nonce))^[2]:=TRNLEndianness.HostToLittleEndian64(aConnectionCandidate^.fLocalSalt);

  if not TRNLAuthenticatedEncryption.Encrypt(OutgoingPacket.ConnectionDenialResponse.Payload,
                                             aConnectionCandidate^.fData^.fSharedSecretKey,
                                             Nonce,
                                             OutgoingPacket.ConnectionDenialResponse.PayloadMAC,
                                             aConnectionCandidate^.fData^.fSolvedChallenge,
                                             SizeOf(TRNLConnectionChallenge),
                                             OutgoingPacket.ConnectionDenialResponse.Payload,
                                             SizeOf(TRNLProtocolHandshakePacketConnectionDenialResponsePayload)) then begin
   exit;
  end;

  AddHandshakePacketChecksum(OutgoingPacket);

  SendPacket(fReceivedAddress,
             OutgoingPacket,
             SizeOf(TRNLProtocolHandshakePacketConnectionDenialResponse));

  Finalize(aConnectionCandidate^.fData^);
  FillChar(aConnectionCandidate^.fData^,SizeOf(TRNLConnectionCandidateData),#0);
  FreeMem(aConnectionCandidate^.fData);
  aConnectionCandidate^.fData:=nil;

 end;

 aConnectionCandidate^.fState:=RNL_CONNECTION_STATE_INVALID;

end;

procedure TRNLHost.DispatchReceivedHandshakePacketConnectionAuthenticationResponse(const aIncomingPacket:PRNLProtocolHandshakePacketConnectionAuthenticationResponse);
var Index:TRNLInt32;
    RemoteCountChannels:TRNLUInt32;
    ConnectionCandidate:PRNLConnectionCandidate;
    ConnectionSalt:TRNLUInt64;
    Nonce:TRNLCipherNonce;
    TwoKeys:TRNLTwoKeys;
    Authorized:boolean;
    RemoteChannelTypes:TRNLPeerChannelTypes;
    DenialReason:TRNLConnectionDenialReason;
    HostEvent:TRNLHostEvent;
begin

{$if defined(RNL_DEBUG) and defined(RNL_DEBUG_SECURITY)}
 fInstance.fDebugLock.Acquire;
 try
  RNLDebugOutputString('DispatchReceivedHandshakePacketConnectionAuthenticationResponse');
 finally
  fInstance.fDebugLock.Release;
 end;
{$ifend}

 if not (assigned(fConnectionCandidateHashTable) and
         assigned(fConnectionKnownCandidateHostAddressHashTable)) then begin
  exit;
 end;

 ConnectionCandidate:=fConnectionCandidateHashTable^.Find(fRandomGenerator,
                                                          fReceivedAddress,
                                                          TRNLEndianness.LittleEndianToHost64(aIncomingPacket^.ConnectionSalt) xor fSalt,
                                                          fSalt,
                                                          fInstance.Time,
                                                          fPendingConnectionTimeout,
                                                          false);

 if assigned(ConnectionCandidate) then begin

  if not (ConnectionCandidate^.fState in [RNL_CONNECTION_STATE_AUTHENTICATING,
                                          RNL_CONNECTION_STATE_APPROVING]) then begin
   exit;
  end;

  if not assigned(ConnectionCandidate^.fData) then begin
   exit;
  end;

  ConnectionSalt:=ConnectionCandidate^.fLocalSalt xor ConnectionCandidate^.fRemoteSalt;
  if ConnectionSalt<>TRNLEndianness.LittleEndianToHost64(aIncomingPacket^.ConnectionSalt) then begin
   exit;
  end;

  Authorized:=true;

  PRNLUInt64Array(TRNLPointer(@Nonce))^[0]:=TRNLEndianness.HostToLittleEndian64(ConnectionCandidate^.fData^.fNonce);
  PRNLUInt64Array(TRNLPointer(@Nonce))^[1]:=aIncomingPacket^.Nonce;
  PRNLUInt64Array(TRNLPointer(@Nonce))^[2]:=TRNLEndianness.HostToLittleEndian64(ConnectionSalt);

  if not TRNLAuthenticatedEncryption.Decrypt(aIncomingPacket^.Payload,
                                             ConnectionCandidate^.fData^.fSharedSecretKey,
                                             Nonce,
                                             aIncomingPacket^.PayloadMAC,
                                             ConnectionCandidate^.fData^.fSolvedChallenge,
                                             SizeOf(TRNLConnectionChallenge),
                                             aIncomingPacket^.Payload,
                                             SizeOf(TRNLProtocolHandshakePacketConnectionAuthenticationResponsePayload)) then begin
   Authorized:=false;
  end;

  if Authorized then begin

   TwoKeys[0]:=ConnectionCandidate^.fData^.fRemoteShortTermPublicKey;
   TwoKeys[1]:=ConnectionCandidate^.fData^.fLocalShortTermPublicKey;

   if not TRNLED25519.Verify(aIncomingPacket^.Payload.Signature,
                             aIncomingPacket^.Payload.LongTermPublicKey,
                             TwoKeys,
                             SizeOf(TRNLTwoKeys)) then begin
    Authorized:=false;
   end;

  end;

  if fCheckAuthenticationTokens and
     assigned(fOnPeerCheckAuthenticationToken) and not
     fOnPeerCheckAuthenticationToken(self,fReceivedAddress,aIncomingPacket^.Payload.AuthenticationToken) then begin
   Authorized:=false;
  end;

  RemoteCountChannels:=TRNLEndianness.LittleEndianToHost16(aIncomingPacket^.Payload.CountChannels);

  for Index:=Low(TRNLPeerChannelTypes) to High(TRNLPeerChannelTypes) do begin
   RemoteChannelTypes[Index]:=TRNLPeerChannelType(TRNLInt32(aIncomingPacket^.Payload.ChannelTypes[Index]));
  end;

  if Authorized and
     ((fCountPeers+1)<fMaximumCountPeers) and
     ((RemoteCountChannels>0) and (RemoteCountChannels<=fMaximumCountChannels)) and
     TRNLMemory.SecureIsEqual(RemoteChannelTypes,fChannelTypes,SizeOf(TRNLPeerChannelType)*RemoteCountChannels) then begin

   ConnectionCandidate^.fData^.fRemoteCountChannels:=RemoteCountChannels;

   ConnectionCandidate^.fData^.fData:=TRNLEndianness.LittleEndianToHost64(aIncomingPacket^.Payload.Data);

   ConnectionCandidate^.fData^.fMTU:=TRNLEndianness.LittleEndianToHost16(aIncomingPacket^.Payload.MTU);

   if assigned(fOnPeerCheckAuthenticationToken) or not fCheckAuthenticationTokens then begin

    AcceptHandshakePacketConnectionAuthenticationResponse(ConnectionCandidate);

   end else begin

    ConnectionCandidate^.fData.fHost:=self;

    ConnectionCandidate^.fData.fAuthenticationToken:=aIncomingPacket^.Payload.AuthenticationToken;

    HostEvent.Initialize;
    try
     HostEvent.Type_:=RNL_HOST_EVENT_TYPE_PEER_CHECK_AUTHENTICATION_TOKEN;
     HostEvent.Peer:=nil;
     HostEvent.Message:=nil;
     HostEvent.ConnectionCandidate:=ConnectionCandidate;
    finally
     fEventQueue.Enqueue(HostEvent);
    end;

   end;

  end else begin

   if not Authorized then begin
    DenialReason:=RNL_CONNECTION_DENIAL_REASON_UNAUTHORIZED;
   end else if (fCountPeers+1)>=fMaximumCountPeers then begin
    DenialReason:=RNL_CONNECTION_DENIAL_REASON_FULL;
   end else if RemoteCountChannels=0 then begin
    DenialReason:=RNL_CONNECTION_DENIAL_REASON_TOO_LESS_CHANNELS;
   end else if RemoteCountChannels>fMaximumCountChannels then begin
    DenialReason:=RNL_CONNECTION_DENIAL_REASON_TOO_MANY_CHANNELS;
   end else if TRNLMemory.SecureIsNotEqual(RemoteChannelTypes,fChannelTypes,SizeOf(TRNLPeerChannelType)*RemoteCountChannels) then begin
    DenialReason:=RNL_CONNECTION_DENIAL_REASON_WRONG_CHANNEL_TYPES;
   end else begin
    DenialReason:=RNL_CONNECTION_DENIAL_REASON_UNKNOWN;
   end;

   RejectHandshakePacketConnectionAuthenticationResponse(ConnectionCandidate,DenialReason);

  end;

 end;

end;

procedure TRNLHost.DispatchReceivedHandshakePacketConnectionApprovalResponse(const aIncomingPacket:PRNLProtocolHandshakePacketConnectionApprovalResponse);
var PeerID:TRNLID;
    Peer:TRNLPeer;
    HostEvent:TRNLHostEvent;
    Nonce:TRNLCipherNonce;
    OutgoingPacket:TRNLProtocolHandshakePacket;
begin

{$if defined(RNL_DEBUG) and defined(RNL_DEBUG_SECURITY)}
 fInstance.fDebugLock.Acquire;
 try
  RNLDebugOutputString('DispatchReceivedHandshakePacketConnectionApprovalResponse');
 finally
  fInstance.fDebugLock.Release;
 end;
{$ifend}

 PeerID:=TRNLEndianness.LittleEndianToHost16(aIncomingPacket^.PeerID);

 Peer:=fPeerIDMap[PeerID];
 if not assigned(Peer) then begin
  exit;
 end;

 if Peer.fConnectionSalt<>TRNLEndianness.LittleEndianToHost64(aIncomingPacket^.ConnectionSalt) then begin
  exit;
 end;

 PRNLUInt64Array(TRNLPointer(@Nonce))^[0]:=aIncomingPacket^.Nonce;
 PRNLUInt64Array(TRNLPointer(@Nonce))^[1]:=TRNLEndianness.HostToLittleEndian64(Peer.fLocalSalt);
 PRNLUInt64Array(TRNLPointer(@Nonce))^[2]:=TRNLEndianness.HostToLittleEndian64(Peer.fRemoteSalt);

 if not TRNLAuthenticatedEncryption.Decrypt(aIncomingPacket^.Payload,
                                            Peer.fSharedSecretKey,
                                            Nonce,
                                            aIncomingPacket^.PayloadMAC,
                                            Peer.fConnectionChallengeResponse^,
                                            SizeOf(TRNLConnectionChallenge),
                                            aIncomingPacket^.Payload,
                                            SizeOf(TRNLProtocolHandshakePacketConnectionApprovalResponsePayload)) then begin
  exit;
 end;

 Peer.fState:=RNL_PEER_STATE_CONNECTED;

 Peer.fRemotePeerID:=TRNLEndianness.LittleEndianToHost16(aIncomingPacket^.Payload.PeerID);

 if assigned(fOnPeerApproval) then begin
  fOnPeerApproval(self,Peer);
 end else begin
  HostEvent.Initialize;
  try
   HostEvent.Type_:=RNL_HOST_EVENT_TYPE_PEER_APPROVAL;
   HostEvent.Peer:=Peer;
   HostEvent.Peer.IncRef;
   HostEvent.Message:=nil;
  finally
   fEventQueue.Enqueue(HostEvent);
  end;
 end;

 OutgoingPacket.Header.Signature:=RNLProtocolHandshakePacketHeaderSignature;
 OutgoingPacket.Header.ProtocolVersion:=TRNLEndianness.HostToLittleEndian64(RNL_PROTOCOL_VERSION);
 OutgoingPacket.Header.ProtocolID:=TRNLEndianness.HostToLittleEndian64(fProtocolID);
 OutgoingPacket.Header.PacketType:=TRNLUInt32(TRNLProtocolHandshakePacketType(RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_APPROVAL_ACKNOWLEDGE));
 OutgoingPacket.Header.Checksum:=0;

 OutgoingPacket.ConnectionApprovalAcknowledge.PeerID:=TRNLEndianness.HostToLittleEndian16(Peer.fRemotePeerID);
 OutgoingPacket.ConnectionApprovalAcknowledge.ConnectionSalt:=TRNLEndianness.HostToLittleEndian64(Peer.fConnectionSalt);
 OutgoingPacket.ConnectionApprovalAcknowledge.Nonce:=fRandomGenerator.GetUInt64;

 FillChar(OutgoingPacket.ConnectionApprovalAcknowledge.WholePacketMAC,SizeOf(TRNLCipherMAC),#0);

 TRNLPoly1305.OneTimeAuthentication(OutgoingPacket.ConnectionApprovalAcknowledge.WholePacketMAC,
                                    OutgoingPacket,
                                    SizeOf(TRNLProtocolHandshakePacketConnectionApprovalAcknowledge),
                                    Peer.fSharedSecretKey);

 AddHandshakePacketChecksum(OutgoingPacket);

 SendPacket(Peer.fAddress,
            OutgoingPacket,
            SizeOf(TRNLProtocolHandshakePacketConnectionApprovalAcknowledge));

end;

procedure TRNLHost.DispatchReceivedHandshakePacketConnectionDenialResponse(const aIncomingPacket:PRNLProtocolHandshakePacketConnectionDenialResponse);
var PeerID:TRNLID;
    Peer:TRNLPeer;
    HostEvent:TRNLHostEvent;
    Nonce:TRNLCipherNonce;
begin

{$if defined(RNL_DEBUG) and defined(RNL_DEBUG_SECURITY)}
 fInstance.fDebugLock.Acquire;
 try
  RNLDebugOutputString('DispatchReceivedHandshakePacketConnectionDenialResponse');
 finally
  fInstance.fDebugLock.Release;
 end;
{$ifend}

 PeerID:=TRNLEndianness.LittleEndianToHost16(aIncomingPacket^.PeerID);

 Peer:=fPeerIDMap[PeerID];
 if not assigned(Peer) then begin
  exit;
 end;

 if Peer.fConnectionSalt<>TRNLEndianness.LittleEndianToHost64(aIncomingPacket^.ConnectionSalt) then begin
  exit;
 end;

 PRNLUInt64Array(TRNLPointer(@Nonce))^[0]:=aIncomingPacket^.Nonce;
 PRNLUInt64Array(TRNLPointer(@Nonce))^[1]:=TRNLEndianness.HostToLittleEndian64(Peer.fLocalSalt);
 PRNLUInt64Array(TRNLPointer(@Nonce))^[2]:=TRNLEndianness.HostToLittleEndian64(Peer.fRemoteSalt);

 if not TRNLAuthenticatedEncryption.Decrypt(aIncomingPacket^.Payload,
                                            Peer.fSharedSecretKey,
                                            Nonce,
                                            aIncomingPacket^.PayloadMAC,
                                            Peer.fConnectionChallengeResponse^,
                                            SizeOf(TRNLConnectionChallenge),
                                            aIncomingPacket^.Payload,
                                            SizeOf(TRNLProtocolHandshakePacketConnectionDenialResponsePayload)) then begin
  exit;
 end;

 Peer.fState:=RNL_PEER_STATE_DISCONNECTED;

 if assigned(fOnPeerDenial) then begin
  try
   fOnPeerDenial(self,Peer,TRNLConnectionDenialReason(TRNLInt32(aIncomingPacket^.Payload.Reason)));
  finally
   fPeerToFreeList.Add(Peer.fPeerToFreeListNode);
  end;
 end else begin
  HostEvent.Initialize;
  try
   HostEvent.Type_:=RNL_HOST_EVENT_TYPE_PEER_DENIAL;
   HostEvent.Peer:=Peer;
   HostEvent.Message:=nil;
   HostEvent.DenialReason:=TRNLConnectionDenialReason(TRNLInt32(aIncomingPacket^.Payload.Reason));
  finally
   fEventQueue.Enqueue(HostEvent);
  end;
 end;

end;

procedure TRNLHost.DispatchReceivedHandshakePacketConnectionApprovalAcknowledge(const aIncomingPacket:PRNLProtocolHandshakePacketConnectionApprovalAcknowledge);
var PeerID:TRNLID;
    Peer:TRNLPeer;
    MAC:TRNLCipherMAC;
    HostEvent:TRNLHostEvent;
    ConnectionCandidate:PRNLConnectionCandidate;
begin

{$if defined(RNL_DEBUG) and defined(RNL_DEBUG_SECURITY)}
 fInstance.fDebugLock.Acquire;
 try
  RNLDebugOutputString('DispatchReceivedHandshakePacketConnectionApprovalAcknowledge');
 finally
  fInstance.fDebugLock.Release;
 end;
{$ifend}

 PeerID:=TRNLEndianness.LittleEndianToHost16(aIncomingPacket^.PeerID);

 Peer:=fPeerIDMap[PeerID];
 if not assigned(Peer) then begin
  exit;
 end;

 if Peer.fConnectionSalt<>TRNLEndianness.LittleEndianToHost64(aIncomingPacket^.ConnectionSalt) then begin
  exit;
 end;

 aIncomingPacket^.Header.Checksum:=0;

 MAC:=aIncomingPacket^.WholePacketMAC;

 FillChar(aIncomingPacket^.WholePacketMAC,SizeOf(TRNLCipherMAC),#0);

 if not TRNLPoly1305.OneTimeAuthenticationVerify(MAC,
                                                 aIncomingPacket^,
                                                 SizeOf(TRNLProtocolHandshakePacketConnectionApprovalAcknowledge),
                                                 Peer.fSharedSecretKey) then begin
  exit;
 end;

 FreeAndNil(Peer.fPendingConnectionHandshakeSendData);

 if not (Peer.fState in RNLNormalPacketPeerStates) then begin

  Peer.fState:=RNL_PEER_STATE_CONNECTED;

  Peer.UpdateOutgoingBandwidthRateLimiter;

  if assigned(fOnPeerConnect) then begin
   fOnPeerConnect(self,Peer,Peer.fConnectionData);
  end else begin
   HostEvent.Initialize;
   try
    HostEvent.Type_:=RNL_HOST_EVENT_TYPE_PEER_CONNECT;
    HostEvent.Peer:=Peer;
    HostEvent.Peer.IncRef;
    HostEvent.Message:=nil;
    HostEvent.Data:=Peer.fConnectionData;
   finally
    fEventQueue.Enqueue(HostEvent);
   end;
  end;

  ConnectionCandidate:=fConnectionCandidateHashTable^.Find(fRandomGenerator,
                                                           fReceivedAddress,
                                                           TRNLEndianness.LittleEndianToHost64(aIncomingPacket^.ConnectionSalt) xor fSalt,
                                                           fSalt,
                                                           fInstance.Time,
                                                           fPendingConnectionTimeout,
                                                           false);
  if assigned(ConnectionCandidate) then begin

   if assigned(ConnectionCandidate^.fData) then begin
    Finalize(ConnectionCandidate^.fData^);
    FillChar(ConnectionCandidate^.fData^,SizeOf(TRNLConnectionCandidateData),#0);
    FreeMem(ConnectionCandidate^.fData);
    ConnectionCandidate^.fData:=nil;
   end;

   ConnectionCandidate^.fState:=RNL_CONNECTION_STATE_INVALID;

  end;

 end;

end;

procedure TRNLHost.DispatchReceivedHandshakePacketData(var aPacketData;const aPacketDataLength:TRNLSizeUInt);
var ProtocolHandshakePacket:PRNLProtocolHandshakePacket;
begin

 if aPacketDataLength<SizeOf(TRNLProtocolHandshakePacketHeader) then begin
  exit;
 end;

 ProtocolHandshakePacket:=@aPacketData;

 // Protocol version check, but ignore the patch number part of the whole version number
 if ((TRNLEndianness.LittleEndianToHost64(ProtocolHandshakePacket^.Header.ProtocolVersion) xor RNL_PROTOCOL_VERSION) and TRNLUInt64($ffffffffffff0000))<>0 then begin
  exit;
 end;

 // Protocol ID check
 if TRNLEndianness.LittleEndianToHost64(ProtocolHandshakePacket^.Header.ProtocolID)<>fProtocolID then begin
  exit;
 end;

 if not VerifyHandshakePacketChecksum(ProtocolHandshakePacket^) then begin
  exit;
 end;

 case TRNLProtocolHandshakePacketType(TRNLInt32(ProtocolHandshakePacket^.Header.PacketType)) of
  RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_REQUEST:begin
   if aPacketDataLength=SizeOf(TRNLProtocolHandshakePacketConnectionRequest) then begin
    DispatchReceivedHandshakePacketConnectionRequest(@aPacketData);
   end;
  end;
  RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_CHALLENGE_REQUEST:begin
   if aPacketDataLength=SizeOf(TRNLProtocolHandshakePacketConnectionChallengeRequest) then begin
    DispatchReceivedHandshakePacketConnectionChallengeRequest(@aPacketData);
   end;
  end;
  RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_CHALLENGE_RESPONSE:begin
   if aPacketDataLength=SizeOf(TRNLProtocolHandshakePacketConnectionChallengeResponse) then begin
    DispatchReceivedHandshakePacketConnectionChallengeResponse(@aPacketData);
   end;
  end;
  RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_AUTHENTICATION_REQUEST:begin
   if aPacketDataLength=SizeOf(TRNLProtocolHandshakePacketConnectionAuthenticationRequest) then begin
    DispatchReceivedHandshakePacketConnectionAuthenticationRequest(@aPacketData);
   end;
  end;
  RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_AUTHENTICATION_RESPONSE:begin
   if aPacketDataLength=SizeOf(TRNLProtocolHandshakePacketConnectionAuthenticationResponse) then begin
    DispatchReceivedHandshakePacketConnectionAuthenticationResponse(@aPacketData);
   end;
  end;
  RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_APPROVAL_RESPONSE:begin
   if aPacketDataLength=SizeOf(TRNLProtocolHandshakePacketConnectionApprovalResponse) then begin
    DispatchReceivedHandshakePacketConnectionApprovalResponse(@aPacketData);
   end;
  end;
  RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_DENIAL_RESPONSE:begin
   if aPacketDataLength=SizeOf(TRNLProtocolHandshakePacketConnectionDenialResponse) then begin
    DispatchReceivedHandshakePacketConnectionDenialResponse(@aPacketData);
   end;
  end;
  RNL_PROTOCOL_HANDSHAKE_PACKET_TYPE_CONNECTION_APPROVAL_ACKNOWLEDGE:begin
   if aPacketDataLength=SizeOf(TRNLProtocolHandshakePacketConnectionApprovalAcknowledge) then begin
    DispatchReceivedHandshakePacketConnectionApprovalAcknowledge(@aPacketData);
   end;
  end;
  else begin
   exit;
  end;
 end;

end;

procedure TRNLHost.DispatchReceivedNormalPacketData(var aPacketData;const aPacketDataLength:TRNLSizeUInt);
var NormalPacketHeader:PRNLProtocolNormalPacketHeader;
    LocalPeerID:TRNLID;
    Peer:TRNLPeer;
    PacketData:TBytes;
begin

 NormalPacketHeader:=@aPacketData;

 if NormalPacketHeader^.Not255=$ff then begin
  // 255? Ups, there's probably something went wrong then :-)
  exit;
 end;

 LocalPeerID:=TRNLEndianness.LittleEndianToHost16(NormalPacketHeader^.PeerID);

 Peer:=fPeerIDMap[LocalPeerID];
 if not assigned(Peer) then begin
  exit;
 end;

 SetLength(PacketData,aPacketDataLength);
 Move(aPacketData,PacketData[0],aPacketDataLength);

 Peer.fIncomingPacketQueue.Enqueue(PacketData);

end;

procedure TRNLHost.DispatchReceivedPacketData(var aPacketData;const aPacketDataLength:TRNLSizeUInt);
begin

 if (aPacketDataLength>=SizeOf(TRNLProtocolHandshakePacketHeaderSignature)) and
    (TRNLUInt32(aPacketData)=PRNLUInt32(TRNLPointer(@RNLProtocolHandshakePacketHeaderSignature))^) then begin

  DispatchReceivedHandshakePacketData(aPacketData,aPacketDataLength);

 end else if aPacketDataLength>=SizeOf(TRNLProtocolNormalPacketHeader) then begin

  DispatchReceivedNormalPacketData(aPacketData,aPacketDataLength);

 end else begin

  // Otherwise just discard it :-)

 end;

end;

function TRNLHost.DispatchPeers(var aNextTimeout:TRNLTime):boolean;
var Peer:TRNLPeer;
begin

 fNextPeerEventTime.fValue:=TRNLUInt64(High(TRNLUInt64));

 for Peer in fPeerList do begin
  if not Peer.DispatchPeer then begin
   result:=false;
   exit;
  end;
 end;

 if (fNextPeerEventTime<>TRNLUInt64(High(TRNLUInt64))) and
    (fNextPeerEventTime>fTime) and
    (fNextPeerEventTime<aNextTimeout) then begin
  aNextTimeout:=fNextPeerEventTime;
 end;

 result:=true;

end;

function TRNLHost.ReceivePackets(const aTimeout:TRNLTime):boolean;
var Index,Family,Packets:TRNLInt32;
    Socket:TRNLSocket;
    HadReceived:boolean;
begin

 Packets:=0;
 repeat

  HadReceived:=false;

  for Index:=Low(TRNLHostSockets) to High(TRNLHostSockets) do begin

   Socket:=fSockets[Index];

   if Socket<>RNL_SOCKET_NULL then begin

    Family:=HostSocketFamilies[Index];

    fReceivedBufferLength:=fNetwork.Receive(Socket,
                                            @fReceivedAddress,
                                            fReceiveBuffer,
                                            SizeOf(fReceiveBuffer),
                                            Family);

    if fReceivedBufferLength>0 then begin
     fIncomingBandwidthRateTracker.AddUnits(fReceivedBufferLength shl 3);
    end;

    if (fReceivedBufferLength<0){or
       ((fReceivedBufferLength>0) and (fReceivedAddress.GetAddressFamily<>Family))} then begin

     result:=false;
     exit;

    end else if fReceivedBufferLength>0 then begin

     HadReceived:=true;

     DispatchReceivedPacketData(fReceiveBuffer,fReceivedBufferLength);

     inc(fTotalReceivedData,fReceivedBufferLength);
     inc(fTotalReceivedPackets);

    end;

   end;

  end;

  inc(Packets);

 until (not HadReceived) or
       (((Packets and 1023)=0) and
        (fInstance.Time>=aTimeout));

 result:=true;

end;

procedure TRNLHost.BroadcastMessage(const aChannel:TRNLUInt8;const aMessage:TRNLMessage);
var Peer:TRNLPeer;
begin
 for Peer in fPeerList do begin
  if Peer.fState in [RNL_PEER_STATE_CONNECTED,
                     RNL_PEER_STATE_DISCONNECT_LATER] then begin
   Peer.Channels[aChannel].SendMessage(aMessage);
  end;
 end;
end;

procedure TRNLHost.BroadcastMessageData(const aChannel:TRNLUInt8;const aData:TRNLPointer;const aDataLength:TRNLUInt32;const aFlags:TRNLMessageFlags=[]);
var Message:TRNLMessage;
begin
 Message:=TRNLMessage.CreateFromMemory(aData,aDataLength,aFlags);
 try
  BroadcastMessage(aChannel,Message);
 finally
  Message.DecRef;
 end;
end;

procedure TRNLHost.BroadcastMessageBytes(const aChannel:TRNLUInt8;const aBytes:TBytes;const aFlags:TRNLMessageFlags=[]);
var Message:TRNLMessage;
begin
 Message:=TRNLMessage.CreateFromBytes(aBytes,aFlags);
 try
  BroadcastMessage(aChannel,Message);
 finally
  Message.DecRef;
 end;
end;

procedure TRNLHost.BroadcastMessageBytes(const aChannel:TRNLUInt8;const aBytes:array of TRNLUInt8;const aFlags:TRNLMessageFlags=[]);
var Message:TRNLMessage;
begin
 Message:=TRNLMessage.CreateFromBytes(aBytes,aFlags);
 try
  BroadcastMessage(aChannel,Message);
 finally
  Message.DecRef;
 end;
end;

procedure TRNLHost.BroadcastMessageRawByteString(const aChannel:TRNLUInt8;const aString:TRNLRawByteString;const aFlags:TRNLMessageFlags=[]);
var Message:TRNLMessage;
begin
 Message:=TRNLMessage.CreateFromRawByteString(aString,aFlags);
 try
  BroadcastMessage(aChannel,Message);
 finally
  Message.DecRef;
 end;
end;

procedure TRNLHost.BroadcastMessageUTF8String(const aChannel:TRNLUInt8;const aString:TRNLUTF8String;const aFlags:TRNLMessageFlags=[]);
var Message:TRNLMessage;
begin
 Message:=TRNLMessage.CreateFromUTF8String(aString,aFlags);
 try
  BroadcastMessage(aChannel,Message);
 finally
  Message.DecRef;
 end;
end;

procedure TRNLHost.BroadcastMessageUTF16String(const aChannel:TRNLUInt8;const aString:TRNLUTF16String;const aFlags:TRNLMessageFlags=[]);
var Message:TRNLMessage;
begin
 Message:=TRNLMessage.CreateFromUTF16String(aString,aFlags);
 try
  BroadcastMessage(aChannel,Message);
 finally
  Message.DecRef;
 end;
end;

procedure TRNLHost.BroadcastMessageString(const aChannel:TRNLUInt8;const aString:TRNLString;const aFlags:TRNLMessageFlags=[]);
var Message:TRNLMessage;
begin
 Message:=TRNLMessage.CreateFromString(aString,aFlags);
 try
  BroadcastMessage(aChannel,Message);
 finally
  Message.DecRef;
 end;
end;

procedure TRNLHost.BroadcastMessageStream(const aChannel:TRNLUInt8;const aStream:TStream;const aFlags:TRNLMessageFlags=[]);
var Message:TRNLMessage;
begin
 Message:=TRNLMessage.CreateFromStream(aStream,aFlags);
 try
  BroadcastMessage(aChannel,Message);
 finally
  Message.DecRef;
 end;
end;

function TRNLHost.DispatchIteration(const aEvent:PRNLHostEvent=nil;const aTimeout:TRNLInt64=1000):TRNLHostServiceStatus;
var Timeout,NextTimeout:TRNLTime;
    WaitConditions:TRNLSocketWaitConditions;
begin

 result:=RNL_HOST_SERVICE_STATUS_TIMEOUT;

 if assigned(aEvent) then begin
  aEvent^.Free;
 end;

 Timeout:=fInstance.Time+Max(0,aTimeout);

 repeat

{$if defined(RNL_DEBUG) and defined(RNL_DEBUG_EXTENDED)}
  fInstance.fDebugLock.Acquire;
  try
   RNLDebugOutputString('Blup');
  finally
   fInstance.fDebugLock.Release;
  end;
{$ifend}

  repeat

   ClearPeerToFreeList;

   if assigned(aEvent) and fEventQueue.IsNotEmpty and fEventQueue.Dequeue(aEvent^) then begin
    result:=RNL_HOST_SERVICE_STATUS_EVENT;
    exit;
   end;

   // When aTimeout is negative (for example -1), then we do check only the event queue (for TRNLHost.CheckEvents)
   if aTimeout<0 then begin
    result:=RNL_HOST_SERVICE_STATUS_TIMEOUT;
    exit;
   end;

   fTime:=fInstance.Time;

   fIncomingBandwidthRateTracker.SetTime(fTime);
   fIncomingBandwidthRateTracker.Update;

   fOutgoingBandwidthRateTracker.SetTime(fTime);
   fOutgoingBandwidthRateTracker.Update;

   fPeerLock.Acquire;
   try

    NextTimeout:=Timeout;

    if not DispatchPeers(NextTimeout) then begin
     result:=RNL_HOST_SERVICE_STATUS_ERROR;
     exit;
    end;

    if not ReceivePackets(NextTimeout) then begin
     result:=RNL_HOST_SERVICE_STATUS_ERROR;
     exit;
    end;

    NextTimeout:=Timeout;

    if not DispatchPeers(NextTimeout) then begin
     result:=RNL_HOST_SERVICE_STATUS_ERROR;
     exit;
    end;

   finally
    fPeerLock.Release;
   end;

  until fEventQueue.IsEmpty or
        (fTime>=NextTimeout);

  // When aTimeout is zero, then we doing only one iteration without waiting (as fake-flushing for TRNLHost.Flush)
  if aTimeout=0 then begin
   result:=RNL_HOST_SERVICE_STATUS_TIMEOUT;
   exit;
  end;

  repeat

   fTime:=fInstance.Time;

   if fTime>=Timeout then begin
    result:=RNL_HOST_SERVICE_STATUS_TIMEOUT;
    exit;
   end;

   WaitConditions:=[RNL_SOCKET_WAIT_CONDITION_IO_RECEIVE,
                    RNL_SOCKET_WAIT_CONDITION_IO_INTERRUPT,
                    RNL_SOCKET_WAIT_CONDITION_SERVICE_INTERRUPT];

   if not fNetwork.SocketWait(fSockets,
                              WaitConditions,
                              TRNLTime.Difference(NextTimeout,fTime),
                              fNetworkEvent) then begin
    result:=RNL_HOST_SERVICE_STATUS_ERROR;
    exit;
   end;

   if RNL_SOCKET_WAIT_CONDITION_SERVICE_INTERRUPT in WaitConditions then begin
    result:=RNL_HOST_SERVICE_STATUS_INTERRUPT;
    exit;
   end;

  until not (RNL_SOCKET_WAIT_CONDITION_IO_INTERRUPT in WaitConditions);

 until (not (RNL_SOCKET_WAIT_CONDITION_IO_RECEIVE in WaitConditions)) and
       (fInstance.Time>=Timeout);

end;

function TRNLHost.Service(var aEvent:TRNLHostEvent;const aTimeout:TRNLInt64=1000):TRNLHostServiceStatus;
begin
 result:=DispatchIteration(@aEvent,aTimeout);
end;

function TRNLHost.ConnectService(var aEvent:TRNLHostEvent;const aTimeout:TRNLInt64=1000):TRNLHostServiceStatus;
var Timeout:TRNLTime;
    TimeoutInterval:Int64;
begin
 Timeout:=fInstance.Time+Max(0,aTimeout);
 repeat
  if aTimeout<>0 then begin
   TimeoutInterval:=Timeout.fValue-fInstance.Time;
   if TimeoutInterval<1 then begin
    TimeoutInterval:=1;
   end else if TimeoutInterval>aTimeout then begin
    TimeoutInterval:=aTimeout;
   end;
  end else begin
   TimeoutInterval:=aTimeout;
  end;
  result:=Service(aEvent,TimeoutInterval);
 until (result in [RNL_HOST_SERVICE_STATUS_EVENT,RNL_HOST_SERVICE_STATUS_ERROR]) or
       ((aTimeout>0) and (fInstance.Time>=Timeout)) or (aTimeout<0);
end;

function TRNLHost.CheckEvents(var aEvent:TRNLHostEvent):boolean;
begin
 result:=DispatchIteration(@aEvent,-1)=RNL_HOST_SERVICE_STATUS_EVENT;
end;

function TRNLHost.Flush:boolean;
begin
 result:=DispatchIteration(nil,0)<>RNL_HOST_SERVICE_STATUS_ERROR;
end;

procedure TRNLHost.Interrupt;
begin
 if assigned(fNetworkEvent) then begin
  fNetworkEvent.SetEvent;
 end;
end;

constructor TRNLDiscoveryServer.Create(const aInstance:TRNLInstance;
                                       const aNetwork:TRNLNetwork;
                                       const aPort:TRNLUInt16;
                                       const aServiceID:TRNLDiscoveryServiceID;
                                       const aServiceVersion:TRNLUInt32;
                                       const aServiceAddressIPv4:TRNLAddress;
                                       const aServiceAddressIPv6:TRNLAddress;
                                       const aFlags:TRNLDiscoveryServerFlags;
                                       const aOnAccept:TRNLDiscoveryServerOnAccept;
                                       const aMeta:TRNLDiscoveryMeta);
begin
 fInstance:=aInstance;
 fNetwork:=aNetwork;
 fPort:=aPort;
 fServiceID:=aServiceID;
 fServiceVersion:=aServiceVersion;
 fServiceAddressIPv4:=aServiceAddressIPv4;
 fServiceAddressIPv6:=aServiceAddressIPv6;
 fFlags:=aFlags;
 fOnAccept:=aOnAccept;
 fMeta:=aMeta;
 fSockets[0]:=RNL_SOCKET_NULL;
 fSockets[1]:=RNL_SOCKET_NULL;
 fActiveSockets:=nil;
 fEvent:=TRNLNetworkEvent.Create;
 inherited Create(false);
end;

destructor TRNLDiscoveryServer.Destroy;
begin
 Shutdown;
 fActiveSockets:=nil;
 FreeAndNil(fEvent);
 inherited Destroy;
end;

procedure TRNLDiscoveryServer.Shutdown;
begin
 if not Finished then begin
  Terminate;
  fEvent.SetEvent;
  WaitFor;
 end;
end;

procedure TRNLDiscoveryServer.Execute;
const Families:array[0..1] of TRNLAddressFamily=(RNL_IPV4,RNL_IPV6);
var Index,Count,RecvLength:TRNLInt32;
    Address,ClientAddress:TRNLAddress;
//  Conditions:TRNLSocketWaitConditions;
    MaxSocket:TRNLSocket;
    ReadSet,WriteSet:TRNLSocketSet;
    DiscoveryRequestPacket:PRNLDiscoveryRequestPacket;
    DiscoveryAnswerPacket:TRNLDiscoveryAnswerPacket;
begin

 for Index:=Low(TRNLHostSockets) to High(TRNLHostSockets) do begin
  fSockets[Index]:=RNL_SOCKET_NULL;
 end;

 Count:=0;
 fActiveSockets:=nil;
 SetLength(fActiveSockets,2);
 MaxSocket:=0;
 for Index:=0 to 1 do begin
  if ((Index=0) and (RNL_DISCOVERY_SERVER_FLAG_IPV4 in fFlags) and not fServiceAddressIPv4.Equals(RNL_ADDRESS_NONE)) or
     ((Index=1) and (RNL_DISCOVERY_SERVER_FLAG_IPV6 in fFlags) and not fServiceAddressIPv6.Equals(RNL_ADDRESS_NONE)) then begin
   Address.Host:=RNL_HOST_ANY_INIT;
   Address.ScopeID:=0;
   Address.Port:=fPort;
   fSockets[Index]:=fNetwork.SocketCreate(RNL_SOCKET_TYPE_DATAGRAM,Families[Index]);
   if fSockets[Index]<>RNL_SOCKET_NULL then begin
    if Index=1 then begin
     fNetwork.SocketSetOption(fSockets[Index],RNL_SOCKET_OPTION_IPV6_V6ONLY,1);
    end;
    fNetwork.SocketSetOption(fSockets[Index],RNL_SOCKET_OPTION_NONBLOCK,1);
    fNetwork.SocketSetOption(fSockets[Index],RNL_SOCKET_OPTION_REUSEADDR,1);
    fNetwork.SocketSetOption(fSockets[Index],RNL_SOCKET_OPTION_BROADCAST,1);
    if fNetwork.SocketBind(fSockets[Index],@Address,Families[Index]) then begin
     fNetwork.SocketSetOption(fSockets[Index],RNL_SOCKET_OPTION_NONBLOCK,1);
     fNetwork.SocketSetOption(fSockets[Index],RNL_SOCKET_OPTION_BROADCAST,1);
     fNetwork.SocketSetOption(fSockets[Index],RNL_SOCKET_OPTION_REUSEADDR,1);
     fActiveSockets[Count]:=fSockets[Index];
     inc(Count);
    end else begin
     fNetwork.SocketDestroy(fSockets[Index]);
     fSockets[Index]:=RNL_SOCKET_NULL;
    end;
   end;
  end;
 end;
 SetLength(fActiveSockets,Count);

 try

  while not Terminated do begin

   MaxSocket:=0;
   ReadSet.Clear;
   for Index:=Low(TRNLHostSockets) to High(TRNLHostSockets) do begin
    if fSockets[Index]<>RNL_SOCKET_NULL then begin
     ReadSet.Add(fSockets[Index]);
     if MaxSocket<fSockets[Index] then begin
      MaxSocket:=fSockets[Index];
     end;
    end;
   end;

   WriteSet.Clear;

   if fNetwork.SocketSelect(MaxSocket,
                            ReadSet,
                            WriteSet,
                            1000,
                            fEvent)>0 then begin

    if Terminated then begin
     break;
    end else begin

     for Index:=Low(TRNLHostSockets) to High(TRNLHostSockets) do begin

      if (fSockets[Index]<>RNL_SOCKET_NULL) and ReadSet.Check(fSockets[Index]) then begin

       RecvLength:=fNetwork.Receive(fSockets[Index],
                                    @ClientAddress,
                                    fRecvData[0],
                                    SizeOf(fRecvData),
                                    Families[Index]);

       if RecvLength=SizeOf(TRNLDiscoveryRequestPacket) then begin

        DiscoveryRequestPacket:=Pointer(@fRecvData[0]);
        if (DiscoveryRequestPacket^.Signature=RNLDiscoveryRequestSignature) and
           (DiscoveryRequestPacket^.ServiceID=fServiceID) then begin

         DiscoveryRequestPacket^.ClientVersion:=TRNLEndianness.LittleEndianToHost32(DiscoveryRequestPacket^.ClientVersion);
         DiscoveryRequestPacket^.ClientPort:=TRNLEndianness.LittleEndianToHost16(DiscoveryRequestPacket^.ClientPort);

         if (assigned(fOnAccept) and fOnAccept(DiscoveryRequestPacket^)) or not assigned(fOnAccept) then begin

          DiscoveryAnswerPacket.Signature:=RNLDiscoveryAnswerSignature;
          DiscoveryAnswerPacket.ServiceID:=fServiceID;
          DiscoveryAnswerPacket.ServerVersion:=TRNLEndianness.HostToLittleEndian32(fServiceVersion);
          if Index=0 then begin
           DiscoveryAnswerPacket.ServerHost:=fServiceAddressIPv4.Host;
           DiscoveryAnswerPacket.ServerPort:=TRNLEndianness.HostToLittleEndian16(fServiceAddressIPv4.Port);
          end else begin
           DiscoveryAnswerPacket.ServerHost:=fServiceAddressIPv6.Host;
           DiscoveryAnswerPacket.ServerPort:=TRNLEndianness.HostToLittleEndian16(fServiceAddressIPv6.Port);
          end;
          DiscoveryAnswerPacket.Meta:=fMeta;

          ClientAddress.Port:=DiscoveryRequestPacket^.ClientPort;

          fNetwork.Send(fSockets[Index],
                        @ClientAddress,
                        DiscoveryAnswerPacket,
                        SizeOf(TRNLDiscoveryAnswerPacket),
                        Families[Index]);

         end;

        end;

       end;

      end;

     end;

    end;

   end;

  end;

 finally

  for Index:=Low(TRNLHostSockets) to High(TRNLHostSockets) do begin
   if fSockets[Index]<>RNL_SOCKET_NULL then begin
    fNetwork.SocketDestroy(fSockets[Index]);
    fSockets[Index]:=RNL_SOCKET_NULL;
   end;
  end;

 end;

end;

class function TRNLDiscoveryClient.Discover(const aInstance:TRNLInstance;
                                            const aNetwork:TRNLNetwork;
                                            const aPort:TRNLUInt16;
                                            const aMulticastIPV4Address:TRNLAddress;
                                            const aMulticastIPV6Address:TRNLAddress;
                                            const aServiceID:TRNLDiscoveryServiceID;
                                            const aServiceVersion:TRNLUInt32;
                                            const aMeta:TRNLDiscoveryMeta='';
                                            const aMaximumServers:TRNLInt32=1;
                                            const aTimeOut:TRNLInt32=1000):TRNLDiscoveryServices;
const Families:array[0..1] of TRNLAddressFamily=(RNL_IPV4,RNL_IPV6);
var Index,Count,RecvLength,OtherIndex:TRNLInt32;
    Address,ClientAddress:TRNLAddress;
    MaxSocket:TRNLSocket;
    ReadSet,WriteSet:TRNLSocketSet;
    DiscoveryRequestPacket:TRNLDiscoveryRequestPacket;
    DiscoveryAnswerPacket:TRNLDiscoveryAnswerPacket;
    Sockets:TRNLHostSockets;
    NowTime,StartTime,StopTime:TRNLTime;
    TimeOut:TRNLInt64;
    DiscoveryService:TRNLDiscoveryService;
    Found:boolean;
begin

 result:=nil;
 Count:=0;
 try

  DiscoveryRequestPacket.Signature:=RNLDiscoveryRequestSignature;
  DiscoveryRequestPacket.ServiceID:=aServiceID;
  DiscoveryRequestPacket.ClientVersion:=TRNLEndianness.HostToLittleEndian32(aServiceVersion);
  DiscoveryRequestPacket.ClientHost:=RNL_HOST_NONE;
  DiscoveryRequestPacket.ClientPort:=TRNLEndianness.HostToLittleEndian16(aPort);
  DiscoveryRequestPacket.Meta:=aMeta;

  for Index:=Low(TRNLHostSockets) to High(TRNLHostSockets) do begin
   Sockets[Index]:=RNL_SOCKET_NULL;
  end;

  MaxSocket:=0;
  for Index:=0 to 1 do begin
   if (not aMulticastIPV4Address.Equals(RNL_ADDRESS_NONE)) or
      (not aMulticastIPV6Address.Equals(RNL_ADDRESS_NONE)) then begin
    Address.Host:=RNL_HOST_ANY_INIT;
    Address.ScopeID:=0;
    Address.Port:=aPort;
    Sockets[Index]:=aNetwork.SocketCreate(RNL_SOCKET_TYPE_DATAGRAM,Families[Index]);
    if Sockets[Index]<>RNL_SOCKET_NULL then begin
     if Index=1 then begin
      aNetwork.SocketSetOption(Sockets[Index],RNL_SOCKET_OPTION_IPV6_V6ONLY,1);
     end;
     aNetwork.SocketSetOption(Sockets[Index],RNL_SOCKET_OPTION_NONBLOCK,1);
     aNetwork.SocketSetOption(Sockets[Index],RNL_SOCKET_OPTION_REUSEADDR,1);
     aNetwork.SocketSetOption(Sockets[Index],RNL_SOCKET_OPTION_BROADCAST,1);
     if aNetwork.SocketBind(Sockets[Index],@Address,Families[Index]) then begin
      aNetwork.SocketSetOption(Sockets[Index],RNL_SOCKET_OPTION_NONBLOCK,1);
      aNetwork.SocketSetOption(Sockets[Index],RNL_SOCKET_OPTION_BROADCAST,1);
      aNetwork.SocketSetOption(Sockets[Index],RNL_SOCKET_OPTION_REUSEADDR,1);
     end else begin
      aNetwork.SocketDestroy(Sockets[Index]);
      Sockets[Index]:=RNL_SOCKET_NULL;
     end;
    end;
   end;
  end;

  try

   NowTime:=aInstance.GetTime;

   StartTime:=NowTime;

   StopTime:=StartTime+aTimeOut;

   while (NowTime<=StopTime) and (Count<aMaximumServers) do begin

    for Index:=Low(TRNLHostSockets) to High(TRNLHostSockets) do begin
     if Sockets[Index]<>RNL_SOCKET_NULL then begin
      case Index of
       0:begin
        aNetwork.Send(Sockets[Index],
                      @aMulticastIPV4Address,
                      DiscoveryRequestPacket,
                      SizeOf(TRNLDiscoveryRequestPacket),
                      Families[Index]);
       end;
       1:begin
        aNetwork.Send(Sockets[Index],
                      @aMulticastIPV6Address,
                      DiscoveryRequestPacket,
                      SizeOf(TRNLDiscoveryRequestPacket),
                      Families[Index]);
       end;
      end;
     end;
    end;

    MaxSocket:=0;
    ReadSet.Clear;
    for Index:=Low(TRNLHostSockets) to High(TRNLHostSockets) do begin
     if Sockets[Index]<>RNL_SOCKET_NULL then begin
      ReadSet.Add(Sockets[Index]);
      if MaxSocket<Sockets[Index] then begin
       MaxSocket:=Sockets[Index];
      end;
     end;
    end;

    WriteSet.Clear;

    NowTime:=aInstance.GetTime;
    TimeOut:=StopTime.Value-NowTime.Value;
    if TimeOut<1 then begin
     TimeOut:=1;
    end else if TimeOut>10 then begin
     TimeOut:=10;
    end;

    if aNetwork.SocketSelect(MaxSocket,
                             ReadSet,
                             WriteSet,
                             TimeOut)>0 then begin

     for Index:=Low(TRNLHostSockets) to High(TRNLHostSockets) do begin

      if (Sockets[Index]<>RNL_SOCKET_NULL) and ReadSet.Check(Sockets[Index]) then begin

       RecvLength:=aNetwork.Receive(Sockets[Index],
                                    @ClientAddress,
                                    DiscoveryAnswerPacket,
                                    SizeOf(TRNLDiscoveryAnswerPacket),
                                    Families[Index]);

       if RecvLength=SizeOf(TRNLDiscoveryAnswerPacket) then begin

        if (DiscoveryAnswerPacket.Signature=RNLDiscoveryAnswerSignature) and
           (DiscoveryAnswerPacket.ServiceID=aServiceID) then begin

         if DiscoveryAnswerPacket.ServerHost.Equals(RNL_HOST_NONE) then begin
          DiscoveryService.Address.Host:=ClientAddress.Host;
         end else begin
          DiscoveryService.Address.Host:=DiscoveryAnswerPacket.ServerHost;
         end;
         DiscoveryService.Address.ScopeID:=ClientAddress.ScopeID;
         DiscoveryService.Address.Port:=DiscoveryAnswerPacket.ServerPort;
         DiscoveryService.ServiceVersion:=DiscoveryAnswerPacket.ServerVersion;
         DiscoveryService.Meta:=DiscoveryAnswerPacket.Meta;

         Found:=false;
         for OtherIndex:=0 to Count-1 do begin
          if result[OtherIndex].Address.Equals(DiscoveryService.Address) and
             (result[OtherIndex].ServiceVersion=DiscoveryService.ServiceVersion) then begin
           Found:=true;
           break;
          end;
         end;

         if not Found then begin
          OtherIndex:=Count;
          if length(result)<=OtherIndex then begin
           SetLength(result,(OtherIndex+1)*2);
          end;
          result[OtherIndex]:=DiscoveryService;
          inc(Count);
         end;

        end;

       end;

      end;

     end;

    end;

    NowTime:=aInstance.GetTime;

   end;

  finally

   for Index:=Low(TRNLHostSockets) to High(TRNLHostSockets) do begin
    if Sockets[Index]<>RNL_SOCKET_NULL then begin
     aNetwork.SocketDestroy(Sockets[Index]);
     Sockets[Index]:=RNL_SOCKET_NULL;
    end;
   end;

  end;

 finally

  SetLength(result,Count);

 end;

end;

{$ifdef RNLWorkInProgress}
constructor TRNLTCPToUDPBridgeClient.Create(const aBridge:TRNLTCPToUDPBridge;const aClientSocket:TRNLSocket);
begin
 fBridge:=aBridge;
 fBridge.fClients.Add(self);
 fClientSocket:=aClientSocket;
 fEvent:=TRNLNetworkEvent.Create;
 FreeOnTerminate:=true;
 inherited Create(false);
end;

destructor TRNLTCPToUDPBridgeClient.Destroy;
begin
 fBridge.fNetwork.SocketShutdown(fClientSocket);
 fBridge.fNetwork.SocketDestroy(fClientSocket);
 fBridge.fClients.Remove(self);
 FreeAndNil(fEvent);
 inherited Destroy;
end;

procedure TRNLTCPToUDPBridgeClient.Execute;
begin
 // TODO
end;

constructor TRNLTCPToUDPBridge.Create;
begin
 fInstance:=TRNLInstance.Create;
 fNetwork:=TRNLRealNetwork.Create(fInstance);
 fAddress.Host:=RNL_HOST_ANY;
 fAddress.Port:=2048;
 fAddressFamilies:=RNL_IPV4 or RNL_IPV6;
 fPointerToAddress:=@fAddress;
 fTargetAddress:=TRNLAddress.CreateFromString('127.0.0.1:1');
 fPointerToTargetAddress:=@fTargetAddress;
 fStarted:=false;
 fBackLog:=-1;
 fEvent:=TRNLNetworkEvent.Create;
 fClients:=TThreadList.Create;
 inherited Create(true);
end;

destructor TRNLTCPToUDPBridge.Destroy;
begin
 Stop;
 FreeAndNil(fEvent);
 FreeAndNil(fNetwork);
 FreeAndNil(fInstance);
 FreeAndNil(fClients);
 inherited Destroy;
end;

procedure TRNLTCPToUDPBridge.Start;
 function CreateSocket(const aFamily:TRNLInt32):TRNLSocket;
 begin
  result:=fNetwork.SocketCreate(RNL_SOCKET_TYPE_STREAM,aFamily);
  if result<>RNL_SOCKET_NULL then begin
   fNetwork.SocketSetOption(result,RNL_SOCKET_OPTION_REUSEADDR,1);
   fNetwork.SocketSetOption(result,RNL_SOCKET_OPTION_NONBLOCK,1);
   if aFamily=RNL_IPV6 then begin
    if fSockets[0]=RNL_SOCKET_NULL then begin
     fNetwork.SocketSetOption(result,RNL_SOCKET_OPTION_IPV6_V6ONLY,0);
    end else begin
     fNetwork.SocketSetOption(result,RNL_SOCKET_OPTION_IPV6_V6ONLY,1);
    end;
   end;
   if fNetwork.SocketBind(result,fPointerToAddress,aFamily) then begin
    if fNetwork.SocketListen(result,fBackLog) then begin
     // ok
    end else begin
     fNetwork.SocketDestroy(result);
     result:=RNL_SOCKET_NULL;
    end;
   end else begin
    fNetwork.SocketDestroy(result);
    result:=RNL_SOCKET_NULL;
   end;
  end;
 end;
var Index,Family:TRNLInt32;
begin
 if not fAddress.Host.Equals(RNL_HOST_ANY) then begin
  fAddressFamilies:=fAddressFamilies and fAddressFamilies.GetAddressFamily;
 end;
 for Index:=Low(TRNLHostSockets) to High(TRNLHostSockets) do begin
  Family:=TRNLHost.HostSocketFamilies[Index];
  if (fAddressFamilies and Family)<>0 then begin
   fSockets[Index]:=CreateSocket(Family);
  end else begin
   fSockets[Index]:=RNL_SOCKET_NULL;
  end;
 end;
 fStarted:=true;
 inherited Start;
end;

procedure TRNLTCPToUDPBridge.Stop;
var Index:TRNLInt32;
    List:TList;
    OK:boolean;
    Client:TRNLTCPToUDPBridgeClient;
begin
 if fStarted and not Terminated then begin
  Terminate;
  fEvent.SetEvent;
  WaitFor;
 end;
 for Index:=Low(TRNLHostSockets) to High(TRNLHostSockets) do begin
  if fSockets[Index]<>RNL_SOCKET_NULL then begin
   fNetwork.SocketShutdown(fSockets[Index]);
   fNetwork.SocketDestroy(fSockets[Index]);
   fSockets[Index]:=RNL_SOCKET_NULL;
  end;
 end;
 repeat
  OK:=true;
  List:=fClients.LockList;
  try
   if List.Count>0 then begin
    OK:=false;
    for Index:=0 to List.Count-1 do begin
     try
      Client:=TRNLTCPToUDPBridgeClient(List[Index]);
      if not Client.Terminated then begin
       Client.Terminate;
       Client.fEvent.SetEvent;
      end;
     except
     end;
    end;
   end;
  finally
   fClients.UnlockList;
  end;
 until OK;
end;

procedure TRNLTCPToUDPBridge.Execute;
var Index,MaxSocket:TRNLInt32;
    ReadSet,WriteSet:TRNLSocketSet;
    AcceptAddress:TRNLAddress;
    AcceptSocket:TRNLSocket;
begin
 try
  while fStarted and not Terminated do begin
   MaxSocket:=0;
   ReadSet:=TRNLSocketSet.Empty;
   WriteSet:=TRNLSocketSet.Empty;
   for Index:=Low(TRNLHostSockets) to High(TRNLHostSockets) do begin
    if fSockets[Index]<>RNL_SOCKET_NULL then begin
     ReadSet.Add(fSockets[Index]);
     if MaxSocket<fSockets[Index] then begin
      MaxSocket:=fSockets[Index];
     end;
    end;
   end;
   if fNetwork.SocketSelect(MaxSocket+1,ReadSet,WriteSet,1000,fEvent)>0 then begin
    for Index:=Low(TRNLHostSockets) to High(TRNLHostSockets) do begin
     if ReadSet.Check(fSockets[Index]) then begin
      repeat
       AcceptAddress.Host:=RNL_HOST_ANY_INIT;
       AcceptAddress.Port:=0;
       AcceptAddress.ScopeID:=0;
       AcceptSocket:=fNetwork.SocketAccept(fSockets[Index],@AcceptAddress,TRNLHost.HostSocketFamilies[Index]);
       if AcceptSocket<>RNL_SOCKET_NULL then begin
        TRNLTCPToUDPBridgeClient.Create(self,AcceptSocket);
       end else begin
        break;
       end;
      until false;
     end;
    end;
   end;
  end;
 finally
 end;
end;
{$endif}

initialization
 InitializeCRC32C;
finalization
end.

