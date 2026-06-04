
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

$ pocarun stringbench.poca
naive_concat_200k        : 6.909000 s   (len=200000 sum=0 items=0)
builder_table_concat     : 0.012000 s   (len=200000 sum=0 items=200000)
substring_copy_loop      : 0.088000 s   (len=0 sum=800000 items=0)
hash_keys_200k           : 0.167000 s   (len=0 sum=500500 items=200000)
stream_mixed_builder     : 0.068000 s   (len=888895 sum=0 items=0)

#poca,name,seconds
poca,naive_concat_200k,6.908999942243099
poca,builder_table_concat,0.012000161223113537
poca,substring_copy_loop,0.08799992501735687
poca,hash_keys_200k,0.167000200599432
poca,stream_mixed_builder,0.06799965631216764

$ lua stringbench.lua
naive_concat_200k            : 2.279352 s    (len=200000, sum=0, items=0)
builder_table_concat         : 0.007163 s    (len=200000, sum=0, items=200000)
substring_copy_loop          : 0.023552 s    (len=0, sum=800000, items=0)
hash_keys_200k               : 0.065051 s    (len=0, sum=500500, items=200000)
stream_mixed_builder         : 0.029205 s    (len=888895, sum=0, items=100000)

#lua,name,seconds
lua,naive_concat_200k,2.279352
lua,builder_table_concat,0.007163
lua,substring_copy_loop,0.023552
lua,hash_keys_200k,0.065051
lua,stream_mixed_builder,0.029205

$ luajit stringbench.lua
naive_concat_200k            : 4.664186 s    (len=200000, sum=0, items=0)
builder_table_concat         : 0.001976 s    (len=200000, sum=0, items=200000)
substring_copy_loop          : 0.002465 s    (len=0, sum=800000, items=0)
hash_keys_200k               : 0.037173 s    (len=0, sum=500500, items=200000)
stream_mixed_builder         : 0.013819 s    (len=888895, sum=0, items=100000)

#lua,name,seconds
lua,naive_concat_200k,4.664186
lua,builder_table_concat,0.001976
lua,substring_copy_loop,0.002465
lua,hash_keys_200k,0.037173
lua,stream_mixed_builder,0.013819

$ python3 stringbench.py
naive_concat_200k        : 0.011861 s   (len=200000 sum=0 items=0)
builder_table_concat     : 0.002014 s   (len=200000 sum=0 items=200000)
substring_copy_loop      : 0.069997 s   (len=0 sum=800000 items=0)
hash_keys_200k           : 0.063383 s   (len=0 sum=500500 items=200000)
stream_mixed_builder     : 0.017868 s   (len=888895 sum=0 items=0)

#python,name,seconds
python,naive_concat_200k,0.011861
python,builder_table_concat,0.002014
python,substring_copy_loop,0.069997
python,hash_keys_200k,0.063383
python,stream_mixed_builder,0.017868

$ ruby stringbench.rb
naive_concat_200k        : 0.024944 s   (len=200000 sum=0 items=0)
builder_table_concat     : 0.004168 s   (len=200000 sum=0 items=200000)
substring_copy_loop      : 0.055180 s   (len=0 sum=800000 items=0)
hash_keys_200k           : 0.115776 s   (len=0 sum=500500 items=200000)
stream_mixed_builder     : 0.026486 s   (len=888895 sum=0 items=0)

#ruby,name,seconds
ruby,naive_concat_200k,0.024944
ruby,builder_table_concat,0.004168
ruby,substring_copy_loop,0.055180
ruby,hash_keys_200k,0.115776
ruby,stream_mixed_builder,0.026486

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
