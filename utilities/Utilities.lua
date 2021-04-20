--
-- Utilities.lua
--
-- Useful helper functions and API extensions.
-- Place your own utilities in "utilities/Utilities.lua"
--

Utilities = {}

function Utilities.isNull(__object)
	return __object == nil or __object == ''
end
function Utilities.isNotNull(__object)
	return __object ~= nil and __object ~= ''
end

function Utilities.startsWith(__string, __start)
	return __string:sub(1, #__start) == __start
end

function Utilities.endsWith(__string, __ending)
	return __ending == "" or __string:sub(-#__ending) == __ending
end

Utilities.varName = {}
setmetatable(
	Utilities.varName,
	{
		__index = function(self, k, v)
			return string.format('%s', k)
		end
	}
)


function Utilities.getHypotenuse(__x,__y)
	return math.sqrt((__x*__x)+(__y*__y))
end

function Utilities.average(__a, __b)
	return (__a + __b) / 2
end

function Utilities.screenshot()
	return Graphics.getDisplayImage()
end

function Utilities.autoTable(__numberOfDimensions)
    local metatable = {};
    for i = 1, __numberOfDimensions do
        metatable[i] = {
			__index = function(__table, __key)
				if i < __numberOfDimensions then
					__table[__key] = setmetatable({}, metatable[i+1])
					return __table[__key];
				end
			end
		}
    end
    return setmetatable({}, metatable[1]);
end

function Utilities.newUUID()
	local func = function(x)
		local random = math.random(16) - 1
		random = (x == "x") and (random + 1) or (random % 4) + 9
		return ("0123456789abcdef"):sub(random, random)
	end
	return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", func))
end

-- New math methods
--
function math.clamp(a, min, max)
    if min > max then
        min, max = max, min
    end
    return math.max(min, math.min(max, a))
end
function math.ring(a, min, max)
    if min > max then
        min, max = max, min
    end
    return min + (a-min)%(max-min)
end
function math.ringInt(a, min, max)
    return math.ring(a, min, max + 1)
end
function math.approach( value, target, step)
    if value==target then
        return value, true
    end
    local d = target-value
    if d>0 then
        value = value + step
        if value >= target then
            return target, true
        else
            return value, false
        end
    elseif d<0 then
        value = value - step
        if value <= target then
            return target, true
        else
            return value, false
        end
    else
        return value, true
    end
end
function math.infiniteApproach(at_zero, at_infinite, x_halfway, x)
    return at_infinite - (at_infinite-at_zero)*0.5^(x/x_halfway)
end
function math.round(v, bracket)
	local bracket = bracket or 1
	return math.floor(v/bracket + math.sign(v) * 0.5) * bracket
end
function math.sign(v)
	return (v >= 0 and 1) or -1
end

-- New array methods
--
function table.random(t)
    if type(t)~="table" then return nil end
    return t[math.ceil(math.random(#t))]
end
function table.each(t, fn)
	if type(fn)~="function" then return end
	for _, e in pairs(t) do
		fn(e)
	end
end

function table.filter(t, filterIter)
	local out = {}

	for _, value in pairs(t) do
	  --if filterIter(v, k, table) then out[k] = v end
		if (filterIter(value)) then
			table.insert (out,value)
		end
	end

	return out
  end