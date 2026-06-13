# (Ararat) Synapse TCP/IP library for Pascal
Official source repository is https://github.com/geby/synapse (It was changed from SourceForge at January 2024)

This opensource library is my freetime hobby. You can reward me by any donation, thank you!

[![Paypal donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/donate/?hosted_button_id=8APS698SPM2VQ) or use https://paypal.me/gebauerl

### About
This project deals with network communication by means of blocking sockets (with limited non-blocking mode) on Windows, Linux, Android and on many POSIX based systems. This project not using asynchronous sockets! The Project contains simple low level non-visual classes in set of units for easiest programming.

Blocking mode is more natural in pre-emptive multitasking and multithreading environment. Synchronous mode (called 'blocking' in Winsock terminology) features acting thread waits until the needed operation terminates. When we want to send data, the program exits function only after data is sent - or - if we want to receive data, the program exits the function only after the desired data is received.

Thus, much more crisp and simple programming is achieved. You especially feel it when trying to implement any Internet protocol, which is typically based on 'send-wait for reply' method. If you want to implement it in an asynchronous method, you would have to accept complicated event processing and synchronous mode simulation. Therefore a synchronous socket is simple and natural for the majority programming tasks. No required multithread synchronisation, no need for windows message processing... Great for command line utilities, visual projects, services, simple servers...

You can found here addition to Synapse project called **SynaSer**, too. This is library for blocking communication on serial ports (COM). It is non-visual class as in Synapse, and API is very similar to Synapse.
 
### Compatibility
* **Delphi 5 - 2007** (ANSI, Win32)
* **Delphi 2009 - 12** (Unicode, Win32/Win64/Android)
* **FreePascal** (Win32/Win64, probably all platforms supported by **sockets** unit)

### Basic features
* IPv4 and IPv6 support
* low level UDP protocol, include SOCKS5 proxy support
* low level TCP protocol, include SOCKS4/5 or HTTP proxy support, TLS encryption by 3rd-party libraries (OpenSSL 3.x, etc.)
* ICMP pings
* Basic support for internet protocols like: DNS, SMTP, IMAP4, HTTP, NTP, POP3, FTP, TFTP, SNMP, LDAP, Syslog, NNTP, Telnet, ClamD 
* encoding/decoding MIME messages, include charset conversions. Old style UUcode, XXcode and Yenc supported too
* many handy utilities included
* Serial port communication, include high-speed USB chips

### Support
Feel free to use:
* Read the [wiki](https://github.com/geby/synapse/wiki)
* Ask in [discussions](https://github.com/geby/synapse/discussions)
* Report [issues](https://github.com/geby/synapse/issues)

### BSD style license
**Copyright (c)1999-2024, Lukas Gebauer**
**All rights reserved.**

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* Neither the name of Lukas Gebauer nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

<sub>Version: 2024/01/16</sub>
