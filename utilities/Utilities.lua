--
-- Utilities.lua
--
-- Useful helper functions and API extensions.
-- Place your own utilities in "utilities/Utilities.lua"
--

Utilities = {}

function Utilities.copy(obj, seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[Utilities.copy(k, s)] = Utilities.copy(v, s) end
	return res
end

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

function Utilities.handleOptionalBoolean(__argument, __default)
	if (__argument == nil) then
		return __default
	elseif (__argument == true or __argument == false) then
		return __argument
	else
		error("BONK: You shouldn’t pass non-boolean value as a boolean parameter.")
		return __argument
	end
end

Utilities.varName = {}
setmetatable(
	Utilities.varName,
	{
		__index = function(self, __key, __value)
			return string.format('%s', __key)
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

function math.clamp(__value, __min, __max)
	if (__min > __max) then
		__min, __max = __max, __min
	end
	return math.max(__min, math.min(__max, __value))
end

function math.ring(__value, __min, __max)
	if (__min > __max) then
		__min, __max = __max, __min
	end
	return __min + (__value - __min) % (__max - __min)
end

function math.ringInt(__value, __min, __max)
	return math.ring(__value, __min, __max + 1)
end

function math.approach(_value, __target, __step)
	if (_value == __target) then
		return _value, true
	end
	local d = __target - _value
	if (d > 0) then
		_value = _value + __step
		if (_value >= __target) then
			return __target, true
		else
			return _value, false
		end
	elseif (d < 0) then
		_value = _value - __step
		if (_value <= __target) then
			return __target, true
		else
			return _value, false
		end
	else
		return _value, true
	end
end

function math.infiniteApproach(at_zero, at_infinite, x_halfway, x)
	return at_infinite - (at_infinite - at_zero) * 0.5 ^ (x / x_halfway)
end

function math.round(__value, __bracket)
	local bracket = __bracket or 1
	return math.floor(__value/bracket + math.sign(__value) * 0.5) * bracket
end

function math.sign(__value)
	return (__value >= 0 and 1) or -1
end

function math.lerp(a, b, t)
	return a + (b - a) * t
end

-- New array/table methods
--

function table.merge(__table1, __table2)
	local mergedTable = {}
	for k,v in pairs(__table1) do
		mergedTable[k] = v
	end
	for k,v in pairs(__table2) do
		mergedTable[k] = v
	end
	return mergedTable
end

function table.random(__table)
	if (type(__table) ~= "table") then return nil end
	return __table[math.ceil(math.random(#__table))]
end
function table.each(__table, __function)
	if (type(__function) ~= "function") then return end
	for _, e in pairs(__table) do
		__function(e)
	end
end

function table.filter(__table, __filter)
	local out = {}
	for _, value in pairs(__table) do
	--if filterIter(v, k, table) then out[k] = v end
		if (__filter(value)) then
			table.insert (out,value)
		end
	end

	return out
end

function table.getSize(__table)
	local count = 0
	for _, _ in pairs(__table) do count += 1 end
	return count
end
