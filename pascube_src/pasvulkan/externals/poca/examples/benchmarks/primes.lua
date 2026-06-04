
function searchPrimes(from, to)
  local dummy = 0
  local primes = 0
  local n = 0
  local i = 0
  local j = 0
  local isPrime = 0
  for n = from, to do
    if ((n % 2) == 0) then
      i = 2
    else
      i = 3
    end
    j = math.sqrt(n)
    isPrime = 1    
    while i <= j do
      if ((n % i) == 0) then
        isPrime = 0
        break
      end
      i = i + 2
    end    
    primes = primes + isPrime
  end
  return primes
end 

function isprime(n)
    for i = 2, (n - 1) do
        if (n % i == 0) then
            return false
        end
    end
    return true
end

function primes(n)
    local count = 0

    for i = 2, n do
        if (isprime(i)) then
            count = count + 1
        end
    end
    return count
end

function primes2(n)
  local count = 0
  local isPrime = 0
  local i = 0
  local j = 0
  for i = 2, n do
    isPrime = 1; 
    for j = 2, (i  - 1) do
      if ((i % j) == 0) then
        isPrime = 0;
        break;
      end
    end
    count = count + isPrime;
  end
  return count
end
    
local N = 200000

local start = os.clock()
local K = searchPrimes(2, N)
local e = os.clock()
io.write(string.format("time: %.8f seconds, primes: %f\n", e - start, K))

start = os.clock()
K = primes(N)
local e = os.clock()
io.write(string.format("time: %.8f seconds, primes: %f\n", e - start, K))

start = os.clock()
K = primes2(N)
local e = os.clock()
io.write(string.format("time: %.8f seconds, primes: %f\n", e - start, K))

