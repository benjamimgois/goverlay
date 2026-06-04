$counter = 0

def test_function
  $counter += 1
  $counter
end

def test_function2
  test_function3 = lambda do
    $counter += 1
    $counter
  end

  10.times { test_function3.call }
  $counter
end

start_time = Time.now
1_000_000.times { test_function }
end_time = Time.now
elapsed_ms = (end_time - start_time) * 1000.0
puts "TestFunction Time taken: #{elapsed_ms}ms"

start_time = Time.now
1_000_000.times { test_function2 }
end_time = Time.now
elapsed_ms = (end_time - start_time) * 1000.0
puts "TestFunction2 Time taken: #{elapsed_ms}ms"
