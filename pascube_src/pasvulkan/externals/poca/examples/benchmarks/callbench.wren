
class CallBench {
    
  // Define a static counter (to serve as the global counter)
  construct new() {
    _counter = 0
  }

  // TestFunction increments the counter by one and returns it.
  testFunction() {
    _counter = _counter + 1
    return _counter
  }

  // TestFunction2 defines an inner function that increments the counter.
  // It calls this inner function 10 times and then returns the counter.
  testFunction2() {
    var testFunction3 = Fn.new {
      _counter = _counter + 1
      return _counter
    }
    for (i in 0...10) {
      testFunction3.call()
    }
    return _counter
  }
}

var callBench = CallBench.new()

// Measure execution time for testFunction:
var ta = System.clock
for (i in 0...1000000) {
  callBench.testFunction()
}
var tb = System.clock
System.print("TestFunction Time taken: %( (tb - ta) * 1000)ms")

// Measure execution time for testFunction2:
ta = System.clock
for (i in 0...1000000) {
  callBench.testFunction2()
}
tb = System.clock
System.print("TestFunction2 Time taken: %( (tb - ta) * 1000)ms")
