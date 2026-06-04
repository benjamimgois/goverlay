local function now()
  -- os.clock() = CPU time; for wall-clock use socket.gettime if available.
  -- Keep it stdlib-only: os.clock() is fine for relative microbenchmarks.
  return os.clock()
end

local function bench(name, fn)
  collectgarbage(); collectgarbage()
  local t0 = now()
  local out = fn()
  local t1 = now()
  local dt = t1 - t0
  print(string.format("%-28s : %.6f s    (len=%d, sum=%d, items=%d)",
    name, dt, out.len or 0, out.sum or 0, out.items or 0))
  return {name=name, sec=dt}
end

local results = {}

-- 1) Naive concatenation (worst case)
table.insert(results, bench("naive_concat_200k", function()
  local N = 200000
  local s = ""
  for i = 1, N do
    s = s .. "a"
  end
  return { len = #s }
end))

-- 2) Builder: table.concat (best practice)
table.insert(results, bench("builder_table_concat", function()
  local N = 200000
  local buf = {}
  for i = 1, N do
    buf[i] = "a"
  end
  local s = table.concat(buf, "")
  return { len = #s, items = N }
end))

-- 3) Substring loop (copies)
table.insert(results, bench("substring_copy_loop", function()
  local s = string.rep("abcdef", 200000) -- 1.2M bytes
  local sum = 0
  for i = 1, #s, 3 do
    local sub = string.sub(s, i, i+1) -- copies
    sum = sum + #sub
  end
  return { sum = sum }
end))

-- 4) Hash-table usage with string keys
table.insert(results, bench("hash_keys_200k", function()
  local N = 200000
  local t = {}
  for i = 1, N do
    local k = tostring(i) -- interned; repeated compares become pointer compares
    t[k] = i
  end
  -- Read back a few
  local sum = 0
  for i = 1, 1000 do
    sum = sum + (t[tostring(i)] or 0)
  end
  return { items = N, sum = sum }
end))

-- 5) Streaming mixed writes
table.insert(results, bench("stream_mixed_builder", function()
  local N = 100000
  local b = {}
  local n = 0
  for i = 1, N do
    n = n + 1; b[n] = "ID:"
    n = n + 1; b[n] = tostring(i)
    n = n + 1; b[n] = "\n"
  end
  local out = table.concat(b, "")
  return { len = #out, items = N }
end))

-- CSV footer for quick diff/plot
io.write("\n#lua,name,seconds\n")
for _,r in ipairs(results) do
  io.write(string.format("lua,%s,%.6f\n", r.name, r.sec))
end
