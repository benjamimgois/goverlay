
local MathTAU = math.pi * 2.0

function WrapIntoMinusPIToPI(x)
    x = (x + math.pi) % MathTAU
    if x < 0.0 then
        return (x - math.pi) + MathTAU
    else
        return x - math.pi
    end
end

-- Test case if both Phi calculation methods are equal enough for our purposes for the first x values,
-- when using the golden ratio based method and the golden angle based method, and when both are
-- wrapped into the range of -PI to PI.
local count = 1000000
local differences = false
for i = 0, count - 1 do
    local phiValues = {
        WrapIntoMinusPIToPI(((i * 0.61803398874989485) % 1.0) * MathTAU), -- Golden ratio based
        WrapIntoMinusPIToPI(i * -2.39996322972865332)                     -- Golden angle based, negative to match the golden ratio based method
    }
    if math.abs(phiValues[1] - phiValues[2]) > 1e-8 then
        print("Phi values are too different for i = " .. i, " phiValues[1] = " .. phiValues[1], " phiValues[2] = " .. phiValues[2])
        differences = true
        break
    end
end

if not differences then
    print("Phi calculation methods are equal enough for a fibonacci sphere for the first " .. count .. " values")
else
    print("Phi calculation methods are not equal enough for a fibonacci sphere for the first " .. count .. " values")
end
