counter = 0

function TestFunction()
  counter = counter + 1
  return counter
end

function TestFunction2()
  local function TestFunction3()
    counter = counter + 1
    return counter
  end
  for i = 1, 10 do
    TestFunction3()
  end
  return counter
end

local function milliseconds(seconds)
  return seconds * 1000
end

local ta = os.clock()
for i = 1, 1000000 do
  TestFunction()
end
local tb = os.clock()
print(string.format("TestFunction Time taken: %.2fms", milliseconds(tb - ta)))

ta = os.clock()
for i = 1, 1000000 do
  TestFunction2()
end
tb = os.clock()
print(string.format("TestFunction2 Time taken: %.2fms", milliseconds(tb - ta)))