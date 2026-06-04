import time

counter = 0

def TestFunction():
  global counter
  counter += 1
  return counter

def TestFunction2():
  global counter
  def TestFunction3():
    global counter
    counter += 1
    return counter
  
  for _ in range(10):
    TestFunction3()
  return counter

# Measure TestFunction performance
start = time.time()
for _ in range(1000000):
  TestFunction()
end = time.time()
elapsed_ms = (end - start) * 1000
print(f"TestFunction Time taken: {elapsed_ms:.2f}ms")

# Measure TestFunction2 performance
start = time.time()
for _ in range(1000000):
  TestFunction2()
end = time.time()
elapsed_ms = (end - start) * 1000
print(f"TestFunction2 Time taken: {elapsed_ms:.2f}ms")