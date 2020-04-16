--[[
    Utility functions useful for UI design, part of a larger Utility library
]]


local TweenService = game:GetService("TweenService")

local Utility = {}


--[[
    Linear interpolate any number, userdata with `lerp` method, or any
    data type supporting multiplication and addition operations.

    Returns initial value `p0` interpolated by alpha `a` towards final
    value `p1`. Optionally, the `easingStyle` (Enum.EasingStyle)
    and `easingDirection` (Enum.EasingDirection) can be passed, which will
    modify the provided alpha `a`.
]]
function Utility.interpolateAny(p0, p1, a, easingStyle, easingDirection)
    assert(typeof(p0) == typeof(p1), "Bad argument #2 p1: must be the same data type as p0")
    a = math.clamp(a or 0, 0, 1)
    if easingStyle and easingDirection then
        a = TweenService:GetValue(a, easingStyle, easingDirection)
    end
    if type(p0) == "userdata" and p0.lerp then
        return p0:lerp(p1, a)
    end
    return p0 + ((p1 - p0) * a)
end

--[[
    Returns a Color3 created by multiplying each component of 
    Color3 `color3` by number `n`
]]
function Utility.multiplyColor3(color3, n)
    assert(typeof(color3) == "Color3", "Bad argument #1 color3: must be a Color3")
    assert(type(n) == "number", "Bad argument #2 n: must be a number")
    return Color3.new(color3.R * n, color3.G * n, color3.B * n)
end

--[[
    Returns `n` rounded to `decimalPlaces` number of decimal places
    If decimalPlaces is 0 or not provided, `n` is rounded to the
    nearest integer.
]]
local function roundNumberToDecimalPlace(n, decimalPlaces)
    assert(type(n) == "number", "Bad argument #1 n: must be a number")
    if n == 0 then
        return 0
    end
    local mult = 10^(decimalPlaces or 0)
    return math.floor((n * mult) + 0.5) / mult
end
Utility.roundNumberToDecimalPlace = roundNumberToDecimalPlace

--[[
    Returns a formatted string of number `n`, such as that it is rounded
    to `decimalPlaces` number of decimal places, and the thousands of the integer
    component are separated by a comma ","
    e.g. beautifyNumber(1000.846, 2) -> "1,000.85"
]]
function Utility.beautifyNumber(n, decimalPlaces)
    assert(type(n) == "number", "Bad argument #1 n: must be a number")
    
    local flooredNumber = math.floor(n)
    local roundedNumber = roundNumberToDecimalPlace(n, decimalPlaces)
    local decimalPortion = roundNumberToDecimalPlace(roundedNumber - flooredNumber, decimalPlaces)
    local formattedNumber = tostring(flooredNumber)

    if roundedNumber >= 1000 then
        local k = 1
        while k ~= 0 do
            formattedNumber, k = string.gsub(formattedNumber, "^(-?%d+)(%d%d%d)", '%1,%2')
        end
    end

    if decimalPlaces > 0 then
        local decimalString = string.sub(decimalPortion, 3)
        decimalString = decimalString..(string.rep("0", decimalPlaces - string.len(decimalString)))
        formattedNumber = string.format("%s.%s", formattedNumber, decimalString)
    end

    return formattedNumber
end

return Utility