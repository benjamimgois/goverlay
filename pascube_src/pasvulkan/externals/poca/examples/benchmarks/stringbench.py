import gc, time

def nowSeconds():
    return time.time()

def bench(name, fn):
    gc.collect()
    gc.collect()
    ta = time.time()
    out = fn()
    tb = time.time()
    dt = tb - ta

    # Extract result fields with safe defaults
    length = out.get("len", 0)
    summ   = out.get("sum", 0)
    items  = out.get("items", 0)

    # pad name to 24 chars: "%-24s : %.6f s   (len=%d sum=%d items=%d)"
    n = name.ljust(24)

    # dt with 6 decimal places
    print(f"{n} : {dt:.6f} s   (len={length} sum={summ} items={items})")

    return {"name": name, "sec": dt}

# Utility: fast repeat by doubling
def repeatString(base, count):
    out = ""
    chunk = base
    n = count
    while n > 0:
        if n & 1:
            out += chunk
        n >>= 1
        if n:
            chunk += chunk
    return out

results = []

# 1) naive_concat_200k
def naive_concat_200k():
    N = 200000
    s = ""
    for _ in range(N):
        s += "a"
    return {"len": len(s)}

results.append(bench("naive_concat_200k", naive_concat_200k))

# 2) builder_table_concat
def builder_table_concat():
    N = 200000
    buf = ["a"] * N
    s = "".join(buf)
    return {"len": len(s), "items": N}

results.append(bench("builder_table_concat", builder_table_concat))

# 3) substring_copy_loop
def substring_copy_loop():
    s = repeatString("abcdef", 200000)
    summ = 0
    for i in range(0, len(s), 3):
        sub = s[i:i+2]
        summ += len(sub)
    return {"sum": summ}

results.append(bench("substring_copy_loop", substring_copy_loop))

# 4) hash_keys_200k
def hash_keys_200k():
    N = 200000
    t = {str(i): i for i in range(1, N+1)}
    summ = sum(t[str(i)] for i in range(1, 1001))
    return {"items": N, "sum": summ}

results.append(bench("hash_keys_200k", hash_keys_200k))

# 5) stream_mixed_builder
def stream_mixed_builder():
    N = 100000
    out = "".join(f"ID:{i}\n" for i in range(1, N+1))
    return {"len": len(out)}

results.append(bench("stream_mixed_builder", stream_mixed_builder))

print("\n#python,name,seconds")
for r in results:
    print(f"python,{r['name']},{r['sec']:.6f}")
