
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

$ pocarun gamebench.poca
poca: steps=10, N=1000, elapsed=0.6759996525943279s

$ lua gamebench.lua
lua: steps=10, N=1000, elapsed=0.225s

$ luajit gamebench.lua
lua: steps=10, N=1000, elapsed=0.009s

$ ruby gamebench.rb
ruby: steps=10, N=1000, elapsed=0.528s

$ python3 gamebench.py
python: steps=10, N=1000, elapsed=0.886s

# wren gamebench.wren # (non-class-bass)
wren: steps=10, N=1000, elapsed=0.76472s

$ wren gamebench2.wren # (class-based)
wren: steps=10, N=1000, elapsed=0.971246s

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
