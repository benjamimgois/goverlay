# Warning

RNL including its cryptography code is non-audited so far, thus RNL is only intended for real-time games and multimedia applications without processing of any with critical data, but not for serious applications with critical data!

# Description

RNL stands for "Realtime Network Library" 
 
RNL is an UDP-based network library for real-time applications and games, inspired by ENet, yojimbo, libgren, and so on.

RNL is designed around common patterns used in real-time games, which are simulation bound, not I/O bound, and completely stateful, so async IO does not make a lot of sense. Thus the RNL core design is single-threaded, not multi-threaded. But you can use multiple TRNLHost instances inside multiple different threads (one to very few instances per one thread), so that you can host multiple network game matches at the same machine, as long as this one machine is strong and fast enough for hosting multiple network game matches at the same time.

And at game client side, the whole network stuff should run, if possible, in an own (also if possible, CPU-core-pinned) thread, for possible few interferences and other similiar problems. (offtopic: the same also applies to the audio thread, unless one likes possible audio buffer underrun issues and so on, when it did not get enough CPU time at the right time points. :-) )
 
And for larger games with masses of clients in a single game world, you should use several subdivided TRNLHost instances, so that each TRNLHost must handle only few connected clients, in multiple threads and that in turn on multiple physical dedicated servers, which also in turn may communicate with each other to mimic the impression of a single very large game world. At least a single TRNLHost instance is rather designed for typical low client numbers, as these
are the typical case for egoshooters, racing games, and so forth. Or in other words for large game worlds with masses of clients: Divide and conquer (for example with partially sector-border overlapping game world sectors for just as an example of an divide-and-conquer concept idea)

# Support me

[Support me at Patreon](https://www.patreon.com/bero)

# Features

   - Mostly fully object oriented code design
   - IPv6 support
   - Cross platform
       - Windows (with FreePascal and Delphi)
       - Linux (with FreePascal)
       - *BSD (with FreePascal)
       - Android (with FreePascal and Delphi)
       - Darwin (MacOS(X) and iOS) (with FreePascal and Delphi)
   - UDP-based protocol
   - Sequencing
   - Channels
       - With following possible free configurable channel types: 
           - Reliable ordered
           - Reliable unordered
           - Unreliable ordered
           - Unreliable unordered
   - Reliability
   - Fragmentation and reassembly
   - Aggregation
   - Adaptability
   - Portability
   - Possibility of using a peer-to-peer model or even a mixed peer-to-peer and client/server hybrid model instead only a pure client/server model, and of course also of a classic client/server model 
   - Cryptographically secure pseudo-random number generator (CSPRNG)
       - Based on arc4random but with ChaCha20 instead RC4 as the basic building block
       - Multiple sources of entropy (because you should never trust a single source of
         entropy, as it may have a backdoor)
           - Including usage of the rdseed/rdrand instructions on newer x86 processors as an optional additional quasi-hardware-based entropy source, if these instructions are supported by the current running processor
   - Mutual authentication
       - Based on a Station-to-Station (STS) like protocol, which assumes that the parties have signature keys, which are used to sign messages, thereby providing minification security against man-in-the-middle attacks, unlike the basic plain Diffie-Hellman method without any so such extensions.
       - Long-term private/public keys are ED25519 keys and are used only for signing purposes
   - Forward secrecy using elliptic curve ephemeral Diffie-Hellman (curve 25519)
       - The consequence of this along other facts is that each connection always has new different private and public short-term keys on both sides and therefore also new shared secret short-term keys
       - Short-term private/public keys are X25519 keys and the short-term shared secret key is using only for AEAD-based ciphering purposes
   - Authenticated Encryption with Associated Data (AEAD) packet encryption
       - Based on ChaCha20 as cipher and Poly1305 as cryptographic message authentication code
   - Replay protection of application packet data
       - Based on various protection mechanisms at the connection establishment phase and encrypted packet sequence numbers
   - Delayed connection establishment mechanism as an additional attack surface minification mechanism
   - Connection and authentication tokens (as an optional option, where you should have a separate out-of-band communication channel, for example a HTTPS-based master backend for to generate and handle this stuff) as an additional attack surface minification mechanism against DDoS amplification attacks
       - Connection token are transferred in clear text, so that they are checked in a fast way at the first ever data packet from a connection attempt, without the need to decrypt the connection token first before it is possible to check the token, so in order to save CPU time in this point. This option is primarily for use in against DDoS amplification attacks, which means that the server will not respond straight away if the connection token does not match at the first ever data packet from a connection attempt, and thus DDoS amplification attacks would simply go into the nothing. Consequently, these tokens should only be valid for a short period of time, which also applies to the master backend side of your infrastructure.
       - Authentication tokens are transferred encrypted, after the private/public key exchange, shared secret key generation, etc. were successfully processed. Authentication tokens, in contrast to the connection token, are NOT a countermeasure against DDoS-category attacks, but rather authentication tokens are, as the name suggests, only for separate out-of-band communication channel authentication purposes, in other words, as additional protection against unauthorized connections, where you can check it in more detail on your master backend side of your infrastructure, before the "client" can connect to the real server, where all the real action happens.
   - Connection attempt rate limiter
       - Configurable with two constants, burst and period
   - Configurable bandwidth rate limiter
   - Optional virtual network feature (for example for fast network-API-less local loopback solution for singleplayer game matches, which should be still server/client concept based)
   - Network interference simulator (for example for testcases and so on)
       - Configurable simulated packet loss probability (each for incoming and outgoing packets)
       - Configurable simulated latency (each for incoming and outgoing packets)
       - Configurable simulated jitter (each for incoming and outgoing packets)
       - Configurable simulated duplicate packet probability (each for incoming and outgoing packets)
   - Dynamic connection challenge request response difficulty adjustment mechanism
       - Configurable with a factor value
       - Based on history-smoothing-frames-per-second-style determination mechanism, but just instead frames per second, connection attempts per second
   - More compression algorithms as choices
       - Deflate (a zlib bit-stream compatible LZ77 and canonical Huffman hybrid, only fixed-static-canonical-huffman in this implementation here on compressor side, but the decompressor side is full featured)
       - LZBRRC (a LZ77-style compressor together with an entropy range coder backend)
       - BRRC (a pure order 0 entropy range coder)
   - CRC32C instead CRC32 (without C at the end)
   - And a lot of more stuff  . . .

# Planned features (a.k.a Todo) in random order of priorities

   - TODO

# General guidelines for code contributors 

[General guidelines for code contributors](CONTRIBUTING.md)

# License

[zlib License](LICENSE)

# IRC channel

IRC channel #rnl on Freenode

 # Thanks

   - Thanks to Lee Salzman for ENet as inspiration for the base API design implementation ideas
   - Thanks to Glenn Fiedler for inspiration for security-oriented implementation ideas
   - Thanks to Sergey Ignatchenko ("No Bugs" Hare) for inspiration also for security-oriented implementation ideas

