#### FLRE - Fast Light Regular Expressions - A fast light regular expression library

FLRE ( **F** ast **L** ight **R** egular **E** xpressions) is a fast, safe and efficient regular expression library, which is implemented in Object Pascal (Delphi and Free Pascal) but which is even usable from other languages like C/C++ and so on. It requires PUCU.pas from [PUCU](https://github.com/BeRo1985/pucu) for the Unicode data tables. 

It implements the many of the most common Perl and POSIX features, except **irregular** expression features like forward references and nested back references and so on, which aren't supported at FLRE, only real "back" references are supported, hence also the word "Light" at the FLRE name. It also finds the leftmost-first match, the same match that Perl and PCRE would, and can return submatch information. But it also features a flag for a yet experimental POSIX-style leftmost-longest match behaviour mode. 

FLRE is licensed under the LGPL v2.1 with static-linking-exception.

And as a side note, the experimental support for lookahead assertions and back references may be removed later again, if it is recognized later that these capabilities are not effective or not issue-free without backtracking, because FLRE is primarly a backtracking-free regular expression engine.

The secret of FLRE speed is that FLRE uses multiple subengines with automatic selection:

* **Fixed string search** for pure static literal string regexs, SBNDMQ2 (a shift-and/shift-or variant with boyer-moore-style skipping) for short strings shorter than 32 chars, and boyer-moore for strings longer than or equal 32 chars.
* **Approximate heuristic regular expression prefix matching** based on SBNDMQ2 for to find _possible_ match begin boundaries very fast. 
* **On the fly computed DFA** (aka lazy DFA, DFA with caching of parallel-threaded-NFA/Thompson-NFA states) to find the whole match boundaries. For submatches, if they exists, it uses the remain subengines after the DFA match pass. This subengine is very fast. 
* **One pass NFA** This subengine is quite still fast. But it can process simple regexs only, where it's always immediately obvious when a repetition ends. For example `x(y|z)` and `x*yx*` are onepass, but `(xy)|(xz)` and `x*x*` not, but the regex abstract syntax tree optimizer optimizes the most cases anyway out, before the bytecode and the one pass NFA state map will generated. The base idea is from the re2 regular expression engine from Google.
* **Bit state NFA** This subengine is quite still fast. But it can process short regexs only with less than 512 regex VM bytecode instructions and visited-flag-bitmaps with less than or equal 32 kilobytes. It's a backtracking algorithm with a manual stack in general, but it members the already visited (state, string position) pairs in a bitmap. The base idea is even from the re2 regular expression engine from Google.
* **Parallel threaded NFA** (aka Thompson NFA / Pike VM). This subengine supports the most 08/15 regular expression syntax features _except_ backtracking-stuff as backreferences and so on. And this subengine is also still fast, but not so fast like the one pass NFA subengine.

All these subengines are also UTF8 capable, where FLRE has Unicode 8.0.0 support, and where the UTF8 decoding work is baked into the regular expression DFA&NFA automations itself, so the underlying algorithms are still pure bytewise working algorithms, so that speed optimizations are easier to implement and where the code is overall less error-prone regarding bugs.

And as an addon, FLRE features prefix presearching. So for example the prefix for the example regex `Hel(?:lo|loop) [A-Za-z]+` is `Hello`.

And FLRE can process 0-based null terminated C/C++ and 1-based (Object-)Pascal strings, so it has also a foreign API for usage with C/C++ (see FLRELib.dpr).

FLRE features a prefilter boolean expression string generation feature in two variants, once as simple variant and once as SQL variant. For example, FLRE converts `(hello|hi) world[a-z]+and you` into the prefilter boolean expression string `("hello world" OR "hi world") AND "and you"` and into the prefilter boolean short expression string `("hello world"|"hi world")and you` and into the prefilter SQL boolean full text search expression string `+("hello world" "hi world") +("and you")` and into the prefilter boolean SQL expression string `(((field LIKE "%hello world%") OR (field like "%hi world%")) AND (field like "%and you%"))` where the field name is freely choosable, and FLRE converts `(hello|hi) world[a-z]+and you` into the prefilter boolean expression string `("hello world" OR "hi world") AND * AND "and you"` and into the prefilter boolean short expression string `(hello world|hi world)*and you`, so with wildcards then now. This feature can reduce the number of actual regular expression searches significantly, if you combine it with the data storage on the upper level (for example with with a text trigram index). 

For a more complete engine with more features including backreferences and unicode support etc., see my old regular expression engine [BRRE](https://github.com/BeRo1985/brre) but otherwise FLRE is preferred now, since FLRE with its better structured code is more easily maintainable and therefore also overall less error-prone regarding bugs.

IRC: #flre on freenode

How-to-compile-the-code-examples youtube videos: [https://youtu.be/rVdwOqo6rGQ](https://youtu.be/rVdwOqo6rGQ) and [https://youtu.be/rVdwOqo6rGQ](https://youtu.be/QrXyF9Bzbxw)

## Support me

[Support me at Patreon](https://www.patreon.com/bero)
