import math
import time

def search_primes(start_range, end_range):
  primes = 0
  for n in range(start_range, end_range + 1):
    if n % 2 == 0:
      i = 2
    else:
      i = 3
    j = math.sqrt(n)
    is_prime = 1
    while i <= j:
      if n % i == 0:
        is_prime = 0
        break
      i += 2
    primes += is_prime
  return primes

def isprime(n):
  for i in range(2, n):
    if n % i == 0:
      return False
  return True

def primes(n):
  count = 0
  for i in range(2, n + 1):
    if isprime(i):
      count += 1
  return count

def primes2(n):
  count = 0
  for i in range(2, n + 1):
    is_prime = 1
    for j in range(2, i):
      if i % j == 0:
        is_prime = 0
        break
    count += is_prime
  return count

N = 200000

start = time.perf_counter()
K = search_primes(2, N)
end = time.perf_counter()
print(f"time: {end - start:.8f} seconds, primes: {K}")

start = time.perf_counter()
K = primes(N)
end = time.perf_counter()
print(f"time: {end - start:.8f} seconds, primes: {K}")

start = time.perf_counter()
K = primes2(N)
end = time.perf_counter()
print(f"time: {end - start:.8f} seconds, primes: {K}")
