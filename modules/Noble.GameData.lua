--- Operations for game data / save slots.
-- @module Noble.GameData
--
Noble.GameData = {}

local gameDatas = {}			-- This is the actual "GameDatas" object, which holds multiple GameData slots. We keep it local to avoid direct tampering.
local gameDataDefault = nil
local numberOfGameDataSlotsAtSetup = 1
local numberOfSlots = 1
local currentSlot = 1	-- This is a helper value, so you don't have to specify a save slot with every GameData operation.

local function keyChange(__dataDefault, __data)
	local defaultKeys = {}
	local keys = {}
	for key, value in pairs(__dataDefault.data) do
		table.insert(defaultKeys, key)
	end
	for key, value in pairs(__data.data) do
		table.insert(keys, key)
	end
	for i = 1, #keys, 1 do
		if (defaultKeys[i] ~= keys[i]) then return true end
	end
	return false
end

local function exists(__gameDataSlot, __key)
	-- Check for valid gameSlot.
	if (__gameDataSlot > #gameDatas or __gameDataSlot <= 0 ) then
		error("BONK: Game Slot number " .. __gameDataSlot .. " does not exist. Use Noble.GameData.addSlot().", 3)
		return false
	end

	if (__key ~= nil) then
		-- Check for valid data item.
		for key, value in pairs(gameDatas[__gameDataSlot].data) do
			if __key == key then
				return true
			end
		end
	else
		return true
	end

	error("BONK: Game Datum \"" .. __key .. "\" does not exist. Maybe you spellet it wronlgly.", 3)
	return false
end

local function updateTimestamp(__gameData)
	__gameData.timestamp = playdate.getGMTTime()
end

local gameDataHasBeenSetup = false

--- Sets up the GameDatas (save slots) for your game, and/or loads any existing GameDatas from disk.
-- You can only run this once, ideally in your main.lua before you load your first scene.
-- @tparam table __keyValuePairs All the data items for a saved game, and their default values, as key/value pairs. <strong>NOTE:</strong> Do not use "nil" as a value.
-- @int[opt=1] __numberOfSlots If you want multiple save slots, enter an integer here. You can add additional slots later.
-- @bool[opt=true] __saveToDisk Saves your default values immediately to disk.
-- @bool[opt=true] __modifyExistingOnKeyChange Updates the existing gameData objects on disk if you make changes to your keys (not values) during development or when updating your game.
-- @usage
--	Noble.GameData.setup(
--		{
--			name = "",
--			checkpointReached = 0,
--			score = 0
--		},
--		3,
--		true,
--		true
--	)
--	Noble.GameData.set("name", "Game A", 1)
--	Noble.GameData.set("name", "Game B", 2)
--	Noble.GameData.set("name", "Game C", 3)
-- @see addSlot
-- @see deleteSlot
function Noble.GameData.setup(__keyValuePairs, __numberOfSlots, __saveToDisk, __modifyExistingOnKeyChange)
	if (gameDataHasBeenSetup) then
		error("BONK: You can only run Noble.GameData.setup() once.")
		return
	else
		gameDataHasBeenSetup = true
	end

	numberOfSlots = __numberOfSlots or numberOfSlots
	numberOfGameDataSlotsAtSetup = numberOfSlots

	local saveToDisk = Utilities.handleOptionalBoolean(__saveToDisk, true)
	local modifyExistingOnKeyChange = Utilities.handleOptionalBoolean(__modifyExistingOnKeyChange, true)
	
	gameDataDefault = {
		data = __keyValuePairs,
		timestamp = playdate.getGMTTime()
	}

	local createdNewData = false

	-- Noble Engine checks on disk for GameDatas, including ones that were
	-- added with addSlot, but it assumes your game will have no greater than 1000 of them.
	for i = 1, 1000, 1 do
		 -- We use a local here to avoid adding a nil item to the gameDatas table.
		local gameData = Datastore.read("Game" .. i)

		if (gameData == nil) then
			if (i <= numberOfSlots) then
				-- No gameData on disk, so we create a new ones using default values
				-- up to the numberOfGameDataSlots.
				gameDatas[i] = table.deepcopy(gameDataDefault)
				createdNewData = true
			else
				-- We can't find any more GameDatas on disk, so we update the
				-- value of numberOfGameDataSlots if necessary and get outta town!
				numberOfSlots = i - 1
				print("Total number of game slots: " .. numberOfSlots)

				if (saveToDisk and createdNewData) then
					Noble.GameData.saveAll()
				end

				return -- This is our only way out!
			end
		else
 			-- We found a gameData on disk, so we use it (either as-is or modified by a key change).
			if (modifyExistingOnKeyChange and keyChange(gameDataDefault, gameData)) then
				-- Found gameData on disk, but key changes have been made...
				-- ...so we start with a new one, with default values...
				local existingGameData = table.deepcopy(gameData)
				gameData = table.deepcopy(gameDataDefault)
				for key, _ in pairs(gameData.data) do
					-- ...then copy data with unchanged keys to the new object,
					-- naturally discarding keys that don't exist anymore.
					if (existingGameData.data[key] ~= nil) then gameData.data[key] = existingGameData.data[key] end
				end
				gameDatas.timestamp = existingGameData.timestamp
				createdNewData = true
			end
			gameDatas[i] = gameData
		end

	end

end

--- Returns the value of the requested data item.
-- @string __dataItemName The name of the data item.
-- @int[opt] __gameDataSlot If set, uses a specific GameData slot. If not, uses the most recently touched GameData slot.
-- @treturn any
-- @usage Noble.GameData.get("equippedItem")
-- @usage Noble.GameData.get("equippedItem", 2)
function Noble.GameData.get(__dataItemName, __gameDataSlot)
	currentSlot = __gameDataSlot or currentSlot
	if (exists(currentSlot, __dataItemName)) then
		return gameDatas[currentSlot].data[__dataItemName]
	end
end

--- Set the value of a GameData item.
-- @string __dataItemName The name of the data item.
-- @tparam any __value The data item's new value
-- @int[opt] __gameDataSlot If set, uses a specific GameData slot. If not, uses the most recently touched GameData slot.
-- @bool[opt=true] __saveToDisk Saves to disk immediately. Set to false if you prefer to manually save (via a checkpoint or menu).
-- @bool[opt=true] __updateTimestamp Sets the timestamp of this GameData to the current time. Leave false to retain existing timestamp.
-- @usage Noble.GameData.set("score", 74205)
-- @usage Noble.GameData.set("score", Noble.GameData.get("score") + 100)
-- @see save
function Noble.GameData.set(__dataItemName, __value, __gameDataSlot, __saveToDisk, __updateTimestamp)
	currentSlot = __gameDataSlot or currentSlot
	if (exists(currentSlot, __dataItemName)) then
		gameDatas[currentSlot].data[__dataItemName] = __value
		local setTimestamp = Utilities.handleOptionalBoolean(__updateTimestamp, true)
		if (setTimestamp) then updateTimestamp(gameDatas[currentSlot]) end
		local saveToDisk = Utilities.handleOptionalBoolean(__saveToDisk, true)
		if (saveToDisk) then Noble.GameData.save() end
	end
end

--- Reset a GameData item to its default value, defined in @{setup|setup}.
-- @string __dataItemName The name of the data item.
-- @int[opt] __gameDataSlot If set, uses a specific GameData slot. If not, uses the most recently touched GameData slot.
-- @bool[opt=true] __saveToDisk Saves to disk immediately. Set to false if you prefer to manually save (via a checkpoint or menu).
-- @bool[opt=true] __updateTimestamp Resets the timestamp of this GameData to the current time. Leave false to retain existing timestamp.
-- @see save
function Noble.GameData.reset(__dataItemName, __gameDataSlot, __saveToDisk, __updateTimestamp)
	currentSlot = __gameDataSlot or currentSlot
	if (exists(currentSlot, __dataItemName)) then
		gameDatas[currentSlot].data[__dataItemName] = gameDataDefault.data[__dataItemName]
		local setTimestamp = Utilities.handleOptionalBoolean(__updateTimestamp, true)
		if (setTimestamp) then updateTimestamp(gameDatas[currentSlot]) end
		local saveToDisk = Utilities.handleOptionalBoolean(__saveToDisk, true)
		if (saveToDisk) then Noble.GameData.save(currentSlot) end
	end
end

--- Reset all values in a GameData slot to the default values, defined in @{setup|setup}.
-- @int[opt] __gameDataSlot If set, uses a specific GameData slot. If not, uses the most recently touched GameData slot.
-- @bool[opt=true] __saveToDisk Saves to disk immediately. Set to false if you prefer to manually save (via a checkpoint or menu).
-- @bool[opt=true] __updateTimestamp Resets the timestamp of this GameData to the current time. Leave false to retain existing timestamp.
-- @see save
function Noble.GameData.resetAll(__gameDataSlot, __saveToDisk, __updateTimestamp)
	currentSlot = __gameDataSlot or currentSlot
	for key, _ in pairs(gameDatas[currentSlot].data) do
		gameDatas[currentSlot].data[key] = gameDataDefault.data[key]
	end
	local setTimestamp = Utilities.handleOptionalBoolean(__updateTimestamp, true)
	if (setTimestamp) then updateTimestamp(gameDatas[currentSlot]) end
	local saveToDisk = Utilities.handleOptionalBoolean(__saveToDisk, true)
	if (saveToDisk) then Noble.GameData.save(currentSlot) end
end

--- Add a save slot to your game. This is useful for games which have arbitrary save slots, or encourage save scumming.
-- @int[opt=1] __numberToAdd What it says on the tin.
-- @bool[opt=true] __saveToDisk Saves to disk immediately. Set to false if you prefer to manually save (via a checkpoint or menu).
-- @usage Noble.GameData.addSlot()
-- @usage Noble.GameData.addSlot(10)
function Noble.GameData.addSlot(__numberToAdd, __saveToDisk)
	local numberToAdd = __numberToAdd or 1
	local saveToDisk = Utilities.handleOptionalBoolean(__saveToDisk, true)
	if (__numberToAdd < 1) then error ("BONK: Don't use a number smaller than 1, silly.", 2) return end
	for i = 1, numberToAdd, 1 do
		local newGameData = table.deepcopy(gameDataDefault)
		updateTimestamp(newGameData)
		table.insert(gameDatas, newGameData)
		if (saveToDisk) then Noble.GameData.save() end
	end
	numberOfSlots = numberOfSlots + numberToAdd
	print("Added " .. numberToAdd .. " GameData slots. Total GameData slots: " .. numberOfSlots)
end

--- Deletes a GameData from disk if its save slot is greater than the default number established in `setup`.
-- Otherwise, resets all data items to default values using @{resetAll|resetAll}.
--
-- Generally, you won't need this unless you've added save slots using @{addSlot|addSlot}. In other cases, use @{resetAll|resetAll}.
-- @int __gameDataSlot The slot holding the GameData to delete. Unlike other methods that take this argument, this is not optional.
-- @bool[opt=true] __collapseGameDatas Re-sorts the gameDatas table (and renames existing JSON files on disk) to fill the gap left by the deleted GameData.
-- @see deleteAllSlots
-- @see addSlot
-- @see resetAll
-- @usage Noble.GameData.deleteSlot(6)
-- @usage Noble.GameData.deleteSlot(15, false)
function Noble.GameData.deleteSlot(__gameDataSlot, __collapseGameDatas)
	if (__gameDataSlot == nil) then
		error("BONK: You must specify a GameData slot to delete.")
	end
	local collapseGameDatas = Utilities.handleOptionalBoolean(__collapseGameDatas, true)
	if (exists(__gameDataSlot)) then
		if (__gameDataSlot > numberOfGameDataSlotsAtSetup) then
			-- If this GameData is not one of the default ones from setup(), it is removed from disk.
			if (playdate.file.exists("Game" .. __gameDataSlot)) then
				gameDatas[__gameDataSlot] = nil					-- Clear from memory.
				Datastore.delete("Game" .. __gameDataSlot)		-- Clear from disk.
				if (currentSlot == __gameDataSlot) then currentSlot = 1 end -- Safety!
				if (collapseGameDatas) then
					-- Collapse GameDatas
					local newGameDatas = {}
					for i = 1, numberOfSlots do
						if(gameDatas[i] ~= nil) then
							table.insert(newGameDatas, gameDatas[i])
							if (i >= __gameDataSlot) then
								playdate.file.rename("Game" .. __gameDataSlot, "Game" .. __gameDataSlot-1)
							end
						end
					end
					gameDatas = newGameDatas
					numberOfSlots = numberOfSlots - 1
				end
			else
				error("BONK: This GameData is in memory, but its file doesn't exist on disk, so it can't be deleted.", 2)
			end
		else
			-- If this GameData is one of the default ones from setup(), it is reset to default values.
			Noble.GameData.resetAll(__gameDataSlot)
		end
	end
end

--- Deletes all GameDatas from disk, except for the number specified in setup, which are reset to default values.
-- Use this to clear all data as if you were running setup again.
-- Generally, you don't need this unless you've added save slots using @{addSlot|addSlot}. In other cases, use @{resetAll|resetAll} on each slot.
-- @see deleteSlot
-- @see addSlot
function Noble.GameData.deleteAllSlots()
	local numberToDelete = numberOfSlots
	for i = numberToDelete, 1, -1 do
		Noble.GameData.deleteSlot(i, false) -- Don't need to collapse the table because we're deleting them in reverse order.
	end
end

--- Returns the timestamp of the requested GameData, as a tuple (local time, GMT time). The timestamp is updated
-- See Playdate SDK for details on how a time object is formatted. <strong>NOTE: Timestamps are stored internally in GMT.</strong>
-- @int __gameDataSlot The GameData slot to get the timestamp of. Unlike other methods that take this argument, this is not optional.
-- @treturn table Local time
-- @treturn table GMT time
-- @usage Noble.GameData.getTimestamp(1)
function Noble.GameData.getTimestamp(__gameDataSlot)
	if (exists(__gameDataSlot)) then
		return playdate.timeFromEpoch(playdate.epochFromGMTTime(gameDatas[__gameDataSlot].timestamp)), gameDatas[__gameDataSlot].timestamp
	end
end

--- Returns the current number of GameData slots.
-- @treturn int
function Noble.GameData.getNumberOfSlots() return numberOfSlots end

--- Returns the number of the current GameData slot.
-- @treturn int
function Noble.GameData.getCurrentSlot() return currentSlot end

--- Saves a single GameData to disk. If you want to save all GameDatas, use @{saveAll|saveAll} instead.
-- @int[opt] __gameDataSlot If set, uses a specific GameData slot. If not, uses the most recently touched GameData slot.
-- @see saveAll
-- @usage Noble.GameData.save()
-- @usage Noble.GameData.save(3)
function Noble.GameData.save(__gameDataSlot)
	local gameDataSlot = __gameDataSlot or currentSlot
	if (exists(gameDataSlot)) then
		currentSlot = gameDataSlot
		Datastore.write(gameDatas[currentSlot], "Game" .. currentSlot)
	end
end

--- Save all GameDatas to disk. If you only have one, or want to save a specific one, use @{save|save} instead.
-- @see save
function Noble.GameData.saveAll()
	for i = 1, numberOfSlots, 1 do
		Datastore.write(gameDatas[i], "Game" .. currentSlot)
	end
end
