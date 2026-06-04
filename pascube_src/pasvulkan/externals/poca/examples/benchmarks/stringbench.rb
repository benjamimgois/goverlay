# bench_strings.rb
# String performance microbenchmarks for Ruby
# Same test/function names and structure as POCA version.

def nowSeconds
  Time.now.to_f
end

def bench(name)
  GC.start
  GC.start
  ta = nowSeconds
  out = yield
  tb = nowSeconds
  dt = tb - ta

  # Extract result fields with safe defaults
  len   = out[:len]   || 0
  sum   = out[:sum]   || 0
  items = out[:items] || 0

  # pad name to 24 chars: "%-24s : %.6f s   (len=%d sum=%d items=%d)"
  n = name.ljust(24)

  # dt with 6 decimal places
  puts "#{n} : #{'%.6f' % dt} s   (len=#{len} sum=#{sum} items=#{items})"

  { name: name, sec: dt }
end

def repeatString(base, count)
  out = ""
  chunk = base.dup
  n = count
  while n > 0
    out << chunk if (n & 1) != 0
    n >>= 1
    chunk << chunk if n > 0
  end
  out
end

results = []

# 1) naive_concat_200k
results << bench("naive_concat_200k") {
  n = 200_000
  s = ""
  n.times { s << "a" }
  { len: s.length }
}

# 2) builder_table_concat
results << bench("builder_table_concat") {
  n = 200_000
  buf = Array.new(n, "a")
  s = buf.join
  { len: s.length, items: n }
}

# 3) substring_copy_loop
results << bench("substring_copy_loop") {
  s = repeatString("abcdef", 200_000)
  sum = 0
  i = 0
  while i < s.length
    sub = s[i, 2]
    sum += sub.length
    i += 3
  end
  { sum: sum }
}

# 4) hash_keys_200k
results << bench("hash_keys_200k") {
  n = 200_000
  t = {}
  (1..n).each { |i| t[i.to_s] = i }
  sum = 0
  (1..1000).each { |i| sum += t[i.to_s] }
  { items: n, sum: sum }
}

# 5) stream_mixed_builder
results << bench("stream_mixed_builder") {
  n = 100_000
  out = (1..n).map { |i| "ID:#{i}\n" }.join
  { len: out.length }
}

puts "\n#ruby,name,seconds"
results.each { |r| puts "ruby,#{r[:name]},#{'%.6f' % r[:sec]}" }
