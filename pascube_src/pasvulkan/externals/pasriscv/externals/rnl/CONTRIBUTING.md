
# General guidelines for code contributors                 
 
1. Make sure you are legally allowed to make a contribution under the zlib license.
2. The zlib license header goes at the top of each source file, with appropriate copyright notice.
3. After a pull request, check the status of your pull request on http://github.com/BeRo1985/rnl
4. Write code which's compatible with modern Delphi versions and FreePascal >= 3.0.x
5. Don't use Delphi-only, FreePascal-only or Lazarus-only libraries/units, but if needed, make it out-ifdef-able.
6. No use of third-party libraries/units as possible, but if needed, make it out-ifdef-able.
7. Try to use const when possible.
8. Make sure to comment out writeln, used while debugging.
9. Make sure the code compiles on 32-bit and 64-bit platforms (x86-32, x86-64, ARM, ARM64, etc.).
