class SearchPrimes {
  static get(from, to) {
    var dummy = 0
    var primes = 0
    var n = from
    var i = 0
    var j = 0
    var isPrime = 0
    while(n <= to){
      if(((n % 2) == 0)){
        i = 2
      }else{
        i = 3
      }
      j = n.sqrt
      isPrime = 1
      while(i <= j){
        if((n % i) == 0){
          isPrime = 0
          break        
        }
        i = i + 2
      }
      primes = primes + isPrime
      n = n + 1
    }
    return primes
  }
}

class Primes {
  static isprime(n){
    var i = 2
    var j = n - 1 
    while(i < n){
      if((n % i) == 0){
        return false
      }
      i = i + 1
    }
    return true
  }
  static get(n){
    var count = 0
    var i = 2
    while(i < n){
      if(isprime(i)){
        count = count + 1
      }
      i = i + 1
    }
    return count
  }
} 

class Primes2 {
  static get(n){
    var count = 0
    var i = 2
    while(i < n){
      var isprime = 1
      var k = i - 1
      var j = 2
      while(j < k){
        if((i % j) == 0){
          isprime = 0
          break
        }
        j = j + 1 
      }
      count = count + isprime
      i = i + 1
    }
    return count
  }
} 

var N = 200000

var start = System.clock
System.print(SearchPrimes.get(2, N))
System.print("elapsed: %(System.clock - start)")

start = System.clock
System.print(Primes2.get(N))
System.print("elapsed: %(System.clock - start)")

start = System.clock
System.print(Primes.get(N))
System.print("elapsed: %(System.clock - start)")

