--- Operations for game settings / stats.
-- @module Noble.Settings
--
Noble.Settings = {}				-- This is the "class" that holds methods.
local settings = nil			-- This is the actual settings object. We keep it local to avoid direct tampering.
local settingsDefault = nil		-- We keep track of default values so they can be reset.

local function keyChange(__dataDefault, __data)
	local defaultKeys = {}
	local keys = {}
	for key, value in pairs(__dataDefault) do	table.insert(defaultKeys, key) end
	for key, value in pairs(__data) do table.insert(keys, key) end
	for i = 1, #keys, 1 do
		if (defaultKeys[i] ~= keys[i]) then return true end
	end
	return false
end

local function settingExists(__key)
	-- Check for valid data item.
	for key, value in pairs(settings) do
		if __key == key then
			return true
		end
	end
	error("BONK: Setting \'" .. __key .. "\' does not exist. Maybe you spellet ti wronlgly.", 3)
	return false
end

local settingsHaveBeenSetup = false

--- Sets up the settings for your game. You can only run this once, and you must run it before using other `Noble.Settings` functions. It is recommended to place it in your main.lua, before `Noble.new()`.
-- @tparam table __keyValuePairs table. Your game's settings, and thier default values, as key/value pairs. NOTE: Do not use "nil" as a value.
-- @bool[opt=true] __saveToDisk Saves your default values immediatly to disk.
-- @bool[opt=true] __modifyExistingOnKeyChange Updates the existing settings object on disk if you make changes to your settings keys (not values) during development or when updating your game.
-- @usage
--	Noble.Settings.setup({
--		difficulty = "normal",
--		music = true,
--		sfx = true,
--		players = 2,
--		highScore = 0	-- You can store persistant stats here, too!
--	})
function Noble.Settings.setup(__keyValuePairs, __saveToDisk, __modifyExistingOnKeyChange)
	if (settingsHaveBeenSetup) then
		error("BONK: You can only run Noble.Settings.setup() once.")
		return
	else
		settingsHaveBeenSetup = true
	end

	local saveToDisk = __saveToDisk or true
	local modifyExistingOnKeyChange = __modifyExistingOnKeyChange or true
	settingsDefault = __keyValuePairs

	-- Get existing settings from disk, if any.
	settings = Datastore.read("Settings")

	if (settings == nil) then
		-- No settings on disk, so we create a new settings object using default values.
		settings = table.deepcopy(settingsDefault)
	elseif (modifyExistingOnKeyChange and keyChange(settingsDefault, settings)) then
		-- Found settings on disk, but key changes have been made...
		-- ...so we start with a new default settings object...
		local existingSettings = table.deepcopy(settings)
		settings = table.deepcopy(settingsDefault)
		for key, value in pairs(settings) do
			-- ...then copy settings with unchanged keys to the new settings object,
			-- naturally discarding keys that don't exist anymore.
			if (existingSettings[key] ~= nil) then settings[key] = existingSettings[key] end
		end

	end

	if (saveToDisk) then
		Noble.Settings.save()
	end
end

--- Get the value of a setting.
-- @string __settingName The name of the setting.
-- @treturn any The value of the requested setting.
-- @see set
function Noble.Settings.get(__settingName)
	if (settingExists(__settingName)) then
		return settings[__settingName]
	end
end

--- Set the value of a setting.
-- @string __settingName The name of the setting.
-- @tparam any __value The setting's new value
-- @bool[opt=true] __saveToDisk Saves to disk immediately. Set to false if you prefer to manually save (via a confirm button, etc).
-- @see get
-- @see save
function Noble.Settings.set(__settingName, __value, __saveToDisk)
	if (settingExists(__settingName)) then
		settings[__settingName] = __value
		local saveToDisk = __saveToDisk or true
		if (saveToDisk) then Noble.Settings.save() end
	end
end

--- Resets the value of a setting to its default value defined in `setup()`.
-- @string __settingName The name of the setting.
-- @bool[opt=true] __saveToDisk Saves to disk immediately. Set to false if you prefer to manually save (via a confirm button, etc).
-- @see resetSome
-- @see resetAll
-- @see save
function Noble.Settings.reset(__settingName, __saveToDisk)
	if (settingExists(__settingName)) then
		settings[__settingName] = settingsDefault[__settingName]
		local saveToDisk = __saveToDisk or true
		if (saveToDisk) then Noble.Settings.save() end
	end
end

--- Resets the value of multiple settings to thier default value defined in `setup()`. This is useful if you are storing persistant stats like high scores in `Settings` and want the player to be able to reset them seperately.
-- @tparam table __settingNames The names of the settings, in an array-style table.
-- @bool[opt=true] __saveToDisk Saves to disk immediately. Set to false if you prefer to manually save (via a confirm button, etc).
-- @see resetAll
-- @see save
function Noble.Settings.resetSome(__settingNames, __saveToDisk)
	for i = 1, #__settingNames, 1 do
		Noble.Settings.reset(__settingNames[i], __saveToDisk)
	end
end

--- Resets all settings to thier default values defined in `setup()`.
-- @bool[opt=true] __saveToDisk Saves to disk immediately. Set to false if you prefer to manually save (via a confirm button, etc).
-- @see resetSome
-- @see save
function Noble.Settings.resetAll(__saveToDisk)
	settings = table.deepcopy(settingsDefault)
	local saveToDisk = __saveToDisk or true
	if (saveToDisk) then Noble.Settings.save() end
end

--- Saves settings to disk.
-- You don't need to call this unless you set `__saveToDisk` as false when setting or resetting a setting (say that five times fast!).
-- @see set
-- @see reset
-- @see resetAll
function Noble.Settings.save()
	Datastore.write(settings, "Settings")
end