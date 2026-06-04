#require 'math'  # Optional: Provides some extended math functionality

def search_primes(start_range, end_range)
  primes = 0
  (start_range..end_range).each do |n|
    i = n.even? ? 2 : 3
    j = Math.sqrt(n)
    is_prime = 1
    while i <= j
      if n % i == 0
        is_prime = 0
        break
      end
      i += 2
    end
    primes += is_prime
  end
  primes
end

def isprime(n)
  (2...n).each do |i|
    return false if n % i == 0
  end
  true
end

def primes(n)
  count = 0
  (2..n).each do |i|
    count += 1 if isprime(i)
  end
  count
end

def primes2(n)
  count = 0
  (2..n).each do |i|
    is_prime = 1
    (2...i).each do |j|
      if i % j == 0
        is_prime = 0
        break
      end
    end
    count += is_prime
  end
  count
end

N = 200_000

start = Time.now
k = search_primes(2, N)
puts "time: #{Time.now - start} seconds, primes: #{k}"

start = Time.now
k = primes(N)
puts "time: #{Time.now - start} seconds, primes: #{k}"

start = Time.now
k = primes2(N)
puts "time: #{Time.now - start} seconds, primes: #{k}"
