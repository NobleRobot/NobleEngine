--
-- Noble Engine
-- A li'l game engine for Playdate, as a treat.
--
-- by Mark LaCroix
-- https://noblerobot.com/
--
--

-- Playdate libraries
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/animation"
import "CoreLibs/animator"
import "CoreLibs/object"
import "CoreLibs/ui"
import "CoreLibs/math"
import "CoreLibs/timer"
import "CoreLibs/crank"

-- We create aliases for both fun and performance reasons.
Graphics = playdate.graphics
Display = playdate.display
Geometry = playdate.geometry
Ease = playdate.easingFunctions
UI = playdate.ui
Datastore = playdate.datastore

-- In lua, varibles are global by default, but having a "Global" object to put
-- varibles into is useful for maintaining sanity if you're coming from an OOP language.
Global = {}

Noble = {}
Noble.currentScene = nil
Noble.isTransitioning = false
Noble.showFPS = false;

-- Third-party libraries
import 'noble/libraries/Signal'
import 'noble/libraries/Sequence'

-- Noble libraries
import 'noble/utilities/Utilities'
import 'noble/NobleScene'



-- Input mananger
--
Noble.Input = {}
Noble.Input.handlers = {}
Noble.Input.current = {}

function Noble.Input.setHandler(__inputHandler)
	playdate.inputHandlers.pop()
	if (__inputHandler == nil) then
		Noble.Input.current = nil
	else
		Noble.Input.current = __inputHandler
		playdate.inputHandlers.push(__inputHandler, true)	-- The Playdate SDK allows for multiple inputHanders to mix and match methods. Noble Engine removes this functionality.
	end
end

-- Noble Engine defines extra "buttonHold" methods that run every frame that a button is held down, but to impliment them, we need to do some magic.

local buttonHoldBufferAmount = 3	-- This is how many frames to wait before the engine determines that a button is being held down. Using !buttonJustPressed() provides only 1 frame, which isn't enough.
local AButtonHoldBufferCount = 0
local BButtonHoldBufferCount = 0
local upButtonHoldBufferCount = 0
local downButtonHoldBufferCount = 0
local leftButtonHoldBufferCount = 0
local rightButtonHoldBufferCount = 0

local function inputUpdate()
	local handler = Noble.Input.current
	if (handler == nil) then return end
	if (handler.AButtonHold ~= nil) then
		if (playdate.buttonIsPressed(playdate.kButtonA)) then
			if (AButtonHoldBufferCount == buttonHoldBufferAmount) then handler.AButtonHold()		-- Execute!
			else AButtonHoldBufferCount = AButtonHoldBufferCount + 1 end							-- Wait another frame!
		end
		if (playdate.buttonJustReleased(playdate.kButtonA)) then AButtonHoldBufferCount = 0 end		-- Reset!
	end
	if (handler.BButtonHold ~= nil) then
		if (playdate.buttonIsPressed(playdate.kButtonB)) then
			if (BButtonHoldBufferCount == buttonHoldBufferAmount) then handler.BButtonHold()
			else BButtonHoldBufferCount = BButtonHoldBufferCount + 1 end
		end
		if (playdate.buttonJustReleased(playdate.kButtonB)) then BButtonHoldBufferCount = 0 end
	end
	if (handler.upButtonHold ~= nil) then
		if (playdate.buttonIsPressed(playdate.kButtonUp)) then
			if (upButtonHoldBufferCount == buttonHoldBufferAmount) then handler.upButtonHold()
			else upButtonHoldBufferCount = upButtonHoldBufferCount + 1 end
		end
		if (playdate.buttonJustReleased(playdate.kButtonUp)) then upButtonHoldBufferCount = 0 end
	end
	if (handler.downButtonHold ~= nil) then
		if (playdate.buttonIsPressed(playdate.kButtonDown)) then
			if (downButtonHoldBufferCount == buttonHoldBufferAmount) then handler.downButtonHold()
			else downButtonHoldBufferCount = downButtonHoldBufferCount + 1 end
		end
		if (playdate.buttonJustReleased(playdate.kButtonDown)) then downButtonHoldBufferCount = 0 end
	end
	if (handler.leftButtonHold ~= nil) then
		if (playdate.buttonIsPressed(playdate.kButtonLeft)) then
			if (leftButtonHoldBufferCount == buttonHoldBufferAmount) then handler.leftButtonHold()
			else leftButtonHoldBufferCount = leftButtonHoldBufferCount + 1 end
		end
		if (playdate.buttonJustReleased(playdate.kButtonLeft)) then leftButtonHoldBufferCount = 0 end
	end
	if (handler.rightButtonHold ~= nil) then
		if (playdate.buttonIsPressed(playdate.kButtonRight)) then
			if (rightButtonHoldBufferCount == buttonHoldBufferAmount) then handler.rightButtonHold()
			else rightButtonHoldBufferCount = rightButtonHoldBufferCount + 1 end
		end
		if (playdate.buttonJustReleased(playdate.kButtonRight)) then rightButtonHoldBufferCount = 0 end
	end
end
function playdate.crankDocked()
	if (Noble.Input.current.crankDocked ~= nil) then
		Noble.Input.current.crankDocked()
	end
end
function playdate.crankUndocked()
	if (Noble.Input.current.crankUndocked ~= nil) then
		Noble.Input.current.crankDocked()
	end
end

local updateCrankIndicator = false

-- bool:bool | Set true to start showing the on-screen crank indicator. Set false to stop showing it.
-- Enable/disable on-screen crank indicator.
function Noble.showCrankIndicator(__bool)
	if (__bool) then
		UI.crankIndicator:start()
	end
	updateCrankIndicator = __bool
end



-- Data (Settings and GameData)
--
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



-- Settings
--
Noble.Settings = {}				-- This is the "class" that holds methods.
local settings = nil			-- This is the actual settings object. We keep it local to avoid direct tampering.
local settingsDefault = nil		-- We keep track of default values so they can be reset.

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

-- __tableOfKeyValuePairs:table				| Your game's settings, and thier default values, as key/value pairs, i.e.: { difficulty = "normal", music = true, players = 2, highScore = 0 }. NOTE: Do not use "nil" as a value.
-- __saveToDisk:bool = true					| Saves your default values immediatly to disk.
-- __modifyExistingOnKeyChange:bool = true 	| Updates the existing settings object on disk if you make changes to your settings keys (not values) during development or when updating your game.
-- Sets up the settings for your game. You can only run this once. Ideally, it goes in your main.lua before you load your first scene.
function Noble.Settings.setup(__tableOfKeyValuePairs, __saveToDisk, __modifyExistingOnKeyChange)
	if (settingsHaveBeenSetup) then
		error("BONK: You can only run Noble.Settings.setup() once.")
		return
	else
		settingsHaveBeenSetup = true
	end

	local saveToDisk = __saveToDisk or true
	local modifyExistingOnKeyChange = __modifyExistingOnKeyChange or true
	settingsDefault = __tableOfKeyValuePairs

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

-- __settingName:string | The name of the setting.
-- Returns the Value of the requested setting.
-- Get the value of a setting.
function Noble.Settings.get(__settingName)
	if (settingExists(__settingName)) then
		return settings[__settingName]
	end
end

-- __settingName:string		| The name of the setting.
-- __value:any				| The setting's new value
-- __saveToDisk:bool = true	| Saves to disk immediately. Set to false if you prefer to manually save (via a confirm button, etc). See: Noble.Settings.save().
-- Set the value of a setting.
function Noble.Settings.set(__settingName, __value, __saveToDisk)
	if (settingExists(__settingName)) then
		settings[__settingName] = __value
		local saveToDisk = __saveToDisk or true
		if (saveToDisk) then Noble.Settings.save() end
	end
end

-- __settingName:string		| The name of the setting.
-- __saveToDisk:bool = true	| Saves to disk immediately. Set to false if you prefer to manually save (via a confirm button, etc). See: Noble.Settings.save().
-- Resets the value of a setting to its default value, defined in Noble.Settings.setup().
function Noble.Settings.reset(__settingName, __saveToDisk)
	if (settingExists(__settingName)) then
		settings[__settingName] = settingsDefault[__settingName]
		local saveToDisk = __saveToDisk or true
		if (saveToDisk) then Noble.Settings.save() end
	end
end

-- __saveToDisk:bool = true | Saves to disk immediately. Set to false if you prefer to manually save (via a confirm button, etc). See: Noble.Settings.save().
-- Resets all settings to thier default values, defined in Noble.Settings.setup().
function Noble.Settings.resetAll(__saveToDisk)
	settings = table.deepcopy(settingsDefault)
	local saveToDisk = __saveToDisk or true
	if (saveToDisk) then Noble.Settings.save() end
end

-- Saves settings to disk. You don't need to call this unless you set "__saveToDisk" as false when setting or resetting a setting (say that five times fast!).
function Noble.Settings.save()
	Datastore.write(settings, "Settings")
end



-- Game Data
--
Noble.GameData = {} 			-- This is the "class" that holds methods.
local gameDatas = {}			-- This is the actual "game datas" object, which holds multiple game data slots. We keep it local to avoid direct tampering.
local gameDataDefault = nil
local numberOfGameDataSlots = 1
local currentGameDataSlot = 1	-- This is a helper value, so you don't have to specify a save slot with every GameData operation.

-- Returns the number of Game Data slots.
function Noble.GameData.getNumberOfGameDataSlots() return numberOfGameDataSlots end
-- Returns the number of the current Game Data slot.
function Noble.GameData.getCurrentGameDataSlot() return currentGameDataSlot end

local function gameDatumExists(__key, __gameDataSlot)
	-- Check for valid gameSlot.
	if (__gameDataSlot > #gameDatas or __gameDataSlot <= 0 ) then
		error("BONK: Game Slot number " .. __gameDataSlot .. " does not exist. Use Noble.Data.addGameSlots().", 3)
		return false
	end
	-- Check for valid data item.
	for key, value in pairs(gameDatas[__gameDataSlot]) do
		if __key == key then
			return true
		end
	end
	error("BONK: Game Datum \"" .. __key .. "\" does not exist. Maybe you spellet it wronlgly.", 3)
	return false
end

local gameDataHasBeenSetup = false

-- __tableOfKeyValuePairs:table				| All the data for a saved game, and thier default values, as key/value pairs, i.e.: { checkpoint = 15, name = "player", highScore = 0 }. NOTE: Do not use "nil" as a value.
-- __numberOfGameDataSlots:int = 1			| If you want multiple gameData slots, enter an integer here.
-- __saveToDisk:bool = true					| Saves your default values immediatly to disk.
-- __modifyExistingOnKeyChange:bool = true	| Updates the existing gameData objects on disk if you make changes to your keys (not values) during development or when updating your game.
-- Sets up the Game Datas (save slots) for your game. You can only run this once. Ideally, it goes in your main.lua before you load your first scene.
function Noble.GameData.setup(__tableOfKeyValuePairs, __numberOfGameDataSlots, __saveToDisk, __modifyExistingOnKeyChange)
	if (gameDataHasBeenSetup) then
		error("BONK: You can only run Noble.GaemData.setup() once.")
		return
	else
		gameDataHasBeenSetup = true
	end

	numberOfGameDataSlots = __numberOfGameDataSlots or numberOfGameDataSlots
	local saveToDisk = __saveToDisk or true
	local modifyExistingOnKeyChange = __modifyExistingOnKeyChange or false
	gameDataDefault = __tableOfKeyValuePairs

	-- Noble Engine checks on disk for game data, including ones that were
	-- added with Noble.GameData.addGameSlots(), but it assumes your game
	-- will have no greater than 1000 of them.
	for i = 1, 1000, 1 do
		 -- We use a local here to avoid adding a nil item to the gameDatas table.
		local gameData = Datastore.read("Game" .. i)

		if (gameData == nil) then
			if (i <= numberOfGameDataSlots) then
				-- No gameData on disk, so we create a new ones using default values
				-- up to the numberOfGameDataSlots.
				gameDatas[i] = table.deepcopy(gameDataDefault)
			else
				-- We can't find any more game datas on disk, so we update the
				-- value of numberOfGameDataSlots if nessessary and get outta town!
				numberOfGameDataSlots = i - 1
				print ("Total number of game slots: " .. numberOfGameDataSlots)
				return
			end
		else
 			-- We found a gameData on disk, so we use it (either as-is or modified by a key change).
			if (modifyExistingOnKeyChange and keyChange(gameDataDefault, gameData)) then
				-- Found gameData on disk, but key changes have been made...
				-- ...so we start with a new one, with default values...
				local existingGameData = table.deepcopy(gameData)
				gameData = table.deepcopy(gameDataDefault)
				for key, value in pairs(gameData) do
					-- ...then copy data with unchanged keys to the new object,
					-- naturally discarding keys that don't exist anymore.
					if (existingGameData[key] ~= nil) then gameData[key] = existingGameData[key] end
				end
			end
			gameDatas[i] = gameData
		end

	end

end

-- __numberOfGameDataSlotsToAdd:int = 1 | What it says on the tin.
-- Add a save slot to the game. This is useful for games which have arbitrary save slots, or encourage save scumming.
function Noble.GameData.addGameSlot(__numberOfGameDataSlotsToAdd)
	local numberOfGameDataSlotsToAdd = __numberOfGameDataSlotsToAdd or 1
	if (__numberOfGameDataSlotsToAdd < 1) then error ("BONK: Don't use a number smaller than 1, silly.", 2) return end
	for i = 1, numberOfGameDataSlotsToAdd, 1 do
		table.insert(gameDatas, table.deepcopy(gameDataDefault))
		numberOfGameDataSlots = numberOfGameDataSlots + 1
	end
	print ("Added " .. numberOfGameDataSlotsToAdd .. " Game Slots. Total Game Slots: " .. numberOfGameDataSlots)
end

-- __dataItemName:string					| The name of the data item.
-- __gameDataSlot:int = currentGameDataSlot	| If set, uses a specific game data slot. If not, uses the most recently touched game data slot.
-- Returns the value of the requested data item.
-- Get the value of a game data item.
function Noble.GameData.get(__dataItemName, __gameDataSlot)
	currentGameDataSlot = __gameDataSlot or currentGameDataSlot
	if (gameDatumExists(__dataItemName, currentGameDataSlot)) then
		return gameDatas[currentGameDataSlot][__dataItemName]
	end
end

-- __dataItemName:string					| The name of the data item.
-- __value: any								| The data item's new value
-- __gameDataSlot:int = currentGameDataSlot	| If set, uses a specific game data slot. If not, uses the most recently touched game data slot.
-- __saveToDisk: bool = true				| Saves to disk immediately. Set to false if you prefer to manually save (via a checkpoint or menu). See: Noble.GameData.save().
-- Set the value of a game data item.
function Noble.GameData.set(__dataItemName, __value, __gameDataSlot, __saveToDisk)
	currentGameDataSlot = __gameDataSlot or currentGameDataSlot
	if (gameDatumExists(__dataItemName, currentGameDataSlot)) then
		gameDatas[currentGameDataSlot][__dataItemName] = __value
		local saveToDisk = __saveToDisk or true
		if (saveToDisk) then Noble.GameData.save() end
	end
end

-- __dataItemName:string					| The name of the data item.
-- __gameDataSlot:int = currentGameDataSlot	| If set, uses a specific game data slot. If not, uses the most recently touched game data slot.
-- __saveToDisk: bool = true				| Saves to disk immediately. Set to false if you prefer to manually save (via a checkpoint or menu). See: Noble.GameData.save().
-- Reset a game data item to its default value, defined in Noble.GameData.setup().
function Noble.GameData.reset(__dataItemName, __gameDataSlot, __saveToDisk)
	currentGameDataSlot = __gameDataSlot or currentGameDataSlot
	if (gameDatumExists(__dataItemName, currentGameDataSlot)) then
		gameDatas[currentGameDataSlot][__dataItemName] = gameDataDefault[__dataItemName]
		local saveToDisk = __saveToDisk or true
		if (saveToDisk) then Noble.GameData.save() end
	end
end

-- __gameDataSlot:int = currentGameDataSlot	| If set, saves a specific game data. If not, saves the most recently touched game data.
-- Saves a single game data to disk. If you want to save all game datas, use Noble.GameGata.saveAll() instead.
function Noble.GameData.save(__gameDataSlot)
	local gameDataSlot = __gameDataSlot or currentGameDataSlot
	if (gameDataSlot < 0) then error ("BONK: Don't use a number smaller than 0, silly.", 2) return end
	currentGameDataSlot = gameDataSlot
	Datastore.write(gameDatas[currentGameDataSlot], "Game" .. currentGameDataSlot)
end

-- Save all game datas to disk. If you only have one, or want to save a specicic one, use Noble.GameGata.save() instead.
function Noble.GameData.saveAll()
	for i = 1, numberOfGameDataSlots, 1 do
		Datastore.write(gameDatas[i], "Game" .. i)
	end
end



-- Fonts/Text
--
Noble.Text = {}
Noble.Text.system = Graphics.getSystemFont()
Noble.Text.small = Graphics.font.new("noble/assets/fonts/NobleSans")
Noble.Text.medium = Graphics.font.new("noble/assets/fonts/NobleSlab")
Noble.Text.large = Graphics.font.new("noble/assets/fonts/SatchelRoughed")
local currentFont = Noble.Text.system

Noble.Text.ALIGN_LEFT = kTextAlignment.left
Noble.Text.ALIGN_RIGHT = kTextAlignment.right
Noble.Text.ALIGN_CENTER = kTextAlignment.center

function Noble.Text.getCurrentFont() return currentFont end
function Noble.Text.setFont(__font, __variant)
	currentFont = __font
	local variant = __variant or Graphics.font.kVariantNormal
	Graphics.setFont(__font, variant)
end

function Noble.Text.draw(__string, __x, __y, __alignment, __localized, __font)
	if (__alignment == nil) then __alignment = kTextAlignment.left end
	if (__localized == nil) then __localized = false end
	if (__font ~= nil) then Graphics.setFont(__font) end -- Temporary font
	if (__localized) then
		Graphics.drawLocalizedTextAligned(__string, __x, __y, __alignment)
	else
		Graphics.drawTextAligned(__string, __x, __y, __alignment)
	end
	if (__font ~= nil) then Graphics.setFont(currentFont) end	-- Reset
end



-- Engine initialization
--
local engineInitialized = false

-- StartingScene:NobleScene 						| This is the scene your game begins with, usually a title screen or main menu.
-- transitionDuration:number 						| If you want to transition from the final frame of your launch image sequence, enter a duration in seconds here.
-- transitionType = Noble.Transition.CROSS_DISSOLVE | See Noble.Transition for included transition types.
-- checkForExtraBonks:bool = false 					| Noble Engine-specific errors are called "bonks." Set this to true during development to check for more of them. It is resource intensive, so turn it off for release
-- Game initialization, run this once in your main.lua file.
function Noble.new(StartingScene, __transitionDuration, __transitionType, __checkForExtraBonks)
	if (engineInitialized) then
		error("BONK: You can only run Noble.new() once.")
		return
	else
		engineInitialized = true
	end

	-- Noble Engine refers to an engine-specific error as a "bonk."
	local checkForExtraBonks = __checkForExtraBonks or false
	if (checkForExtraBonks) then Noble.Bonks.startChecking() end

	-- Screen drawing: see the Playdate SDK for details on these methods.
	Graphics.sprite.setAlwaysRedraw(true)
	Graphics.sprite.setBackgroundDrawingCallback(
		function ()
			if (Noble.currentScene ~= nil) then
				 -- Each scene has its own method for this. We only want to run one at a time.
				Noble.currentScene:drawBackground()
			end
		end
	)
	-- Override Playdate methods we've used already, and don't want to be used again, with Bonks!
	Graphics.sprite.setBackgroundDrawingCallback = function(callback)
		error("BONK: Don't call Graphics.sprite.setBackgroundDrawingCallback() directly. Put background drawing code in your scenes' drawBackground() methods instead.")
	end

	local transitionType = Noble.TransitionType.CUT
	if (__transitionDuration ~= nil) then
		transitionType = __transitionType or Noble.TransitionType.CROSS_DISSOLVE
	end

	-- Now that everything is set, let's-a go!
	Noble.transition(StartingScene, __transitionDuration, transitionType)
end



-- Scene Management
--
local transitionSequence = nil
local previousSceneScreenCapture = nil

Noble.TransitionType = {}
Noble.TransitionType.CUT = "Cut"
Noble.TransitionType.DIP = "Dip"
Noble.TransitionType.DIP_TO_BLACK = Noble.TransitionType.DIP .. " to black"
Noble.TransitionType.DIP_TO_WHITE = Noble.TransitionType.DIP .. " to white"
Noble.TransitionType.DIP_CUSTOM = Noble.TransitionType.DIP .. ": Custom"
Noble.TransitionType.DIP_WIDGET_SATCHEL = Noble.TransitionType.DIP .. ": Widget Satchel"
Noble.TransitionType.DIP_METRO_NEXUS = Noble.TransitionType.DIP .. ": Metro Nexus"
Noble.TransitionType.CROSS_DISSOLVE = "Cross dissolve"
Noble.TransitionType.SLIDE_OFF = "Slide off"
Noble.TransitionType.SLIDE_OFF_LEFT = Noble.TransitionType.SLIDE_OFF .. ": left"
Noble.TransitionType.SLIDE_OFF_RIGHT = Noble.TransitionType.SLIDE_OFF .. ": right"
Noble.TransitionType.SLIDE_OFF_UP = Noble.TransitionType.SLIDE_OFF .. ": up"
Noble.TransitionType.SLIDE_OFF_DOWN = Noble.TransitionType.SLIDE_OFF .. ": down"

local currentTransitionType = nil

local dipToBlackPanel = Graphics.image.new(400,240, Graphics.kColorBlack)
local dipToWhitePanel = Graphics.image.new(400,240, Graphics.kColorWhite)

local metroNexusPanels = {
	Graphics.image.new(80,240, Graphics.kColorWhite),
	Graphics.image.new(80,240, Graphics.kColorWhite),
	Graphics.image.new(80,240, Graphics.kColorWhite),
	Graphics.image.new(80,240, Graphics.kColorWhite),
	Graphics.image.new(80,240, Graphics.kColorWhite)
}

local widgetSatchelPanels = {
	Graphics.image.new(400,48, Graphics.kColorWhite),
	Graphics.image.new(400,48, Graphics.kColorWhite),
	Graphics.image.new(400,48, Graphics.kColorWhite),
	Graphics.image.new(400,48, Graphics.kColorWhite),
	Graphics.image.new(400,48, Graphics.kColorWhite)
}
Graphics.lockFocus(widgetSatchelPanels[1])
Graphics.setDitherPattern(0.4, Graphics.image.kDitherTypeScreen)
Graphics.fillRect(0,0,400,48)
Graphics.lockFocus(widgetSatchelPanels[2])
Graphics.setDitherPattern(0.7, Graphics.image.kDitherTypeScreen)
Graphics.fillRect(0,0,400,48)
Graphics.lockFocus(widgetSatchelPanels[3])
Graphics.setDitherPattern(0.25, Graphics.image.kDitherTypeBayer8x8)
Graphics.fillRect(0,0,400,48)
Graphics.lockFocus(widgetSatchelPanels[4])
Graphics.setDitherPattern(0.5, Graphics.image.kDitherTypeDiagonalLine)
Graphics.fillRect(0,0,400,48)
Graphics.lockFocus(widgetSatchelPanels[5])
Graphics.setDitherPattern(0.8, Graphics.image.kDitherTypeHorizontalLine)
Graphics.fillRect(0,0,400,48)
Graphics.unlockFocus()

-- NewScene:NobleScene 									| The scene to transition to. You always transition from Noble.currentScene
-- duration:number = 1 									| Duration of the transition, in seconds.
-- transitionType = Noble.TransitionType.DIP_TO_BLACK 	| See Noble.Transition for included transition types.
-- holdDuration:number = 0.2							| The time spent holding at the transition midpoint. Does not increase the transition duration.
-- Game initialization, run this once in your main.lua file.
function Noble.transition(NewScene, __duration, __transitionType, __holdDuration)
	if (Noble.isTransitioning) then
		print("BONK ALERT: You can't start a transition in the middle of another transition, silly!")
		return
	end

	local newScene = NewScene()			-- Creates new scene object. Its init() function runs.

	Noble.isTransitioning = true

	if (Noble.currentScene ~= nil) then
		Noble.currentScene:exit()		-- The current scene runs its "goodbye" code.
	end

	Noble.Input.setHandler(nil)			-- Disable user input. (This happens after self:ext() so exit() can query input)

	local duration = __duration or 1
	local holdDuration = __holdDuration or 0.2
	currentTransitionType = __transitionType

	local onMidpoint = function()
		Noble.currentScene = nil		-- Allows current scene to be garbage collected.

		Noble.currentScene = newScene	-- New scene's update loop begins.
		Noble.currentScene:enter()		-- The new scene runs its "hello" code.
	end
	local onComplete = function()
		previousSceneScreenCapture = nil-- Reset (if neccessary).
		Noble.isTransitioning = false	-- Reset
		Noble.currentScene:start()		-- The new scene is now active.
	end

	if (Utilities.startsWith(currentTransitionType, Noble.TransitionType.DIP)) then
		transitionSequence = Sequence.new()
			:from(0)
			:to(1, (duration-holdDuration)/2, Ease.linear)
			:callback(onMidpoint)
			:sleep(holdDuration)
			:to(2, (duration-holdDuration)/2, Ease.linear)
			:callback(onComplete)
	else
		previousSceneScreenCapture = Utilities.screenshot()
		onMidpoint()
		transitionSequence = Sequence.new()
			:from(0)
			:to(1, duration, Ease.linear)
			:callback(onComplete)
	end
	transitionSequence:start()
end

local function transitionUpdate()
	local progress = transitionSequence:get()

	-- Transition type: Dip to black
	if (currentTransitionType == Noble.TransitionType.DIP_TO_BLACK) then
		if (progress < 1) then
			dipToBlackPanel:drawFaded(0, 0, Ease.outQuad(progress, 0, 1, 1), Graphics.image.kDitherTypeBayer4x4)
		elseif (progress < 2) then
			dipToBlackPanel:drawFaded(0, 0, 1 - Ease.inQuad(progress - 1, 0, 1, 1), Graphics.image.kDitherTypeBayer4x4)
		end

	-- Transition type: Dip to white
	elseif (currentTransitionType == Noble.TransitionType.DIP_TO_WHITE) then
		if (progress < 1) then
			dipToWhitePanel:drawFaded(0, 0, Ease.outQuad(progress, 0, 1, 1), Graphics.image.kDitherTypeBayer8x8)
		elseif (progress < 2) then
			dipToWhitePanel:drawFaded(0, 0, 1 - Ease.inQuad(progress - 1, 0, 1, 1), Graphics.image.kDitherTypeBayer8x8)
		end

	-- Transition type: Cross dissolve (aka: crossfade)
	elseif (currentTransitionType == Noble.TransitionType.CROSS_DISSOLVE) then
		-- if previousSceneScreenCapture == nil then
		-- 	previousSceneScreenCapture = Utilities.screenshot()
		-- end
		if (progress < 1) then
			previousSceneScreenCapture:drawFaded(0, 0, 1 - Ease.inOutQuart(progress, 0, 1, 1), Graphics.image.kDitherTypeBayer4x4)
		-- else
		-- 	previousSceneScreenCapture = nil -- Reset
		end

	-- -- Transition type: Custom Fade
	-- elseif (Noble.Transition.type == Noble.Transition.DIP_CUSTOM) then
	-- 	if (progress < 1) then
	-- 		Graphics.setPattern(Pattern.fade[math.floor(progress*#Pattern.fade) + 1])
	-- 	elseif (progress < 2) then
	-- 		Graphics.setPattern(Pattern.fade[#Pattern.fade * 2 - (math.floor(progress * #Pattern.fade))])
	-- 	end
	-- 	Graphics.fillRect(0, 0, 400, 240)

	-- Transition type: Widget Satchel (horizontal "color" panels)
	elseif (currentTransitionType == Noble.TransitionType.DIP_WIDGET_SATCHEL) then
		if (progress < 1) then
			widgetSatchelPanels[1]:draw(0, -48 + Ease.outCubic(progress, 0, 1, 1) * 48*1 )
			widgetSatchelPanels[2]:draw(0, -48 + Ease.outCubic(progress, 0, 1, 1) * 48*2 )
			widgetSatchelPanels[3]:draw(0, -48 + Ease.outCubic(progress, 0, 1, 1) * 48*3 )
			widgetSatchelPanels[4]:draw(0, -48 + Ease.outCubic(progress, 0, 1, 1) * 48*4 )
			widgetSatchelPanels[5]:draw(0, -48 + Ease.outCubic(progress, 0, 1, 1) * 48*5 )
		elseif (progress < 2) then
			widgetSatchelPanels[1]:draw(0, 48*0 + Ease.inCubic(progress - 1, 0, 1, 1) * 48*5)
			widgetSatchelPanels[2]:draw(0, 48*1 + Ease.inCubic(progress - 1, 0, 1, 1) * 48*4)
			widgetSatchelPanels[3]:draw(0, 48*2 + Ease.inCubic(progress - 1, 0, 1, 1) * 48*3)
			widgetSatchelPanels[4]:draw(0, 48*3 + Ease.inCubic(progress - 1, 0, 1, 1) * 48*2)
			widgetSatchelPanels[5]:draw(0, 48*4 + Ease.inCubic(progress - 1, 0, 1, 1) * 48*1)
		end

	-- Transition type: Metro Nexus (vertical white panels)
	elseif (currentTransitionType == Noble.TransitionType.DIP_METRO_NEXUS) then
		if (progress < 1) then
			metroNexusPanels[1]:draw(000, (-1 + Ease.outQuint(progress, 0, 1, 1)) * 240 )
			metroNexusPanels[2]:draw(080, (-1 + Ease.outQuart(progress, 0, 1, 1)) * 240 )
			metroNexusPanels[3]:draw(160, (-1 + Ease.outQuart(progress, 0, 1, 1)) * 240 )
			metroNexusPanels[4]:draw(240, (-1 + Ease.outCubic(progress, 0, 1, 1)) * 240 )
			metroNexusPanels[5]:draw(320, (-1 + Ease.outSine (progress, 0, 1, 1)) * 240 )
		elseif (progress < 2) then
			metroNexusPanels[1]:draw(000, (1 - Ease.inQuint(progress - 1, 0, 1, 1)) * -240 + 240)
			metroNexusPanels[2]:draw(080, (1 - Ease.inQuart(progress - 1, 0, 1, 1)) * -240 + 240)
			metroNexusPanels[3]:draw(160, (1 - Ease.inQuart(progress - 1, 0, 1, 1)) * -240 + 240)
			metroNexusPanels[4]:draw(240, (1 - Ease.inCubic(progress - 1, 0, 1, 1)) * -240 + 240)
			metroNexusPanels[5]:draw(320, (1 - Ease.inSine (progress - 1, 0, 1, 1)) * -240 + 240)
		end

	-- Transition type: Slide
	elseif (currentTransitionType == Noble.TransitionType.SLIDE_OFF_LEFT) then
		if (progress < 1) then
			previousSceneScreenCapture:draw(Ease.inQuart(progress, 0, 1, 1) * -400, 0)
		end
	elseif (currentTransitionType == Noble.TransitionType.SLIDE_OFF_RIGHT) then
		if (progress < 1) then
			previousSceneScreenCapture:draw(Ease.inQuart(progress, 0, 1, 1) * 400, 0)
		end
	elseif (currentTransitionType == Noble.TransitionType.SLIDE_OFF_UP) then
		if (progress < 1) then
			previousSceneScreenCapture:draw(0, Ease.inQuart(progress, 0, 1, 1) * -240)
		end
	elseif (currentTransitionType == Noble.TransitionType.SLIDE_OFF_DOWN) then
		if (progress < 1) then
			previousSceneScreenCapture:draw(0, Ease.inQuart(progress, 0, 1, 1) * 240, 0)
		end

	end
end



-- Bonk
-- Noble Engine overrides/supercedes some Playdate SDK behavior. A "bonk" is what happens when your game breaks the engine.
-- You can check for bonks with "checkForBonks"
--
Noble.Bonks = {}
local bonksAreSetup = false
local checkingForBonks = false
local function setupBonks()
	Noble.Bonks.crankDocked = playdate.crankDocked
	Noble.Bonks.crankUndocked = playdate.crankUndocked
	Noble.Bonks.update = playdate.update
	Noble.Bonks.pause = playdate.gameWillPause
	Noble.Bonks.resume = playdate.gameWillResume
	bonksAreSetup = true
end
function Noble.startCheckingForBonks()
	if (bonksAreSetup == false) then
		setupBonks()
	end
	checkingForBonks = true
end
function Noble.stopCheckingForBonks()
	Noble.Bonks = {}
	checkingForBonks = false
	bonksAreSetup = false
end
local function bonkUpdate()
	if (Graphics.sprite.getAlwaysRedraw() == false) then
		error("BONK: Don't use Graphics.sprite.setAlwaysRedraw(false) unless you know what you're doing...")
	end
	if (playdate.crankDocked ~= Noble.Bonks.crankDocked) then
		error("BONK: Don't manaully define playdate.crankDocked(). Create a crankDocked() inside of an inputHandler instead.")
	end
	if (playdate.crankUndocked ~= Noble.Bonks.crankUndocked) then
		error("BONK: Don't manaully define playdate.crankUndocked(). Create a crankUndocked() inside of an inputHandler instead.")
	end
	if (playdate.update ~= Noble.Bonks.update) then
		error("BONK: Don't manaully define playdate.update(). Put update code in your scenes' update() methods instead.")
	end
	if (playdate.gameWillPause ~= Noble.Bonks.pause) then
		error("BONK: Don't manaully define playdate.gameWillPause(). Put pause code in your scenes' pause() methods instead.")
	end
	if (playdate.gameWillResume ~= Noble.Bonks.resume) then
		error("BONK: Don't manaully define playdate.gameWillResume(). Put resume code in your scenes' resume() methods instead.")
	end
	if (Noble.Input.current == nil) then
		error("BONK: Don't set Noble.Input.current to nil directly. To disable input, use Noble.Input.setHandler() (without an arguement) instead.")
	end
	if (Noble.currentScene.baseColor == Graphics.kColorClear) then
		error("BONK: Don't set a scene's baseColor to Graphics.kColorClear, silly.")
	end
end



-- Game loop
--
function playdate.update()
	inputUpdate()							-- Check for Noble Engine-specific input methods.

	Sequence.update()						-- Update all animations that use the Sequence library.

	Graphics.sprite.update()				-- Let's draw our sprites (and backgrounds).

	if (Noble.currentScene ~= nil) then
		Noble.currentScene:update()			-- Scene-specific update code.
	end

	if (Noble.isTransitioning) then
		transitionUpdate()					-- Update transition animations (if active).
	end

	if (updateCrankIndicator and playdate.isCrankDocked()) then
		UI.crankIndicator:update()			-- Draw crank indicator (if requested).
	end

	playdate.timer.updateTimers()			-- Finally, update all SDK timers.

	if (Noble.showFPS) then
		playdate.drawFPS(4, 4)
	end
	if (checkingForBonks) then				-- Checks for code that breaks the engine.
		bonkUpdate()
	end

end
function playdate.gameWillPause()
	if (Noble.currentScene ~= nil) then
		Noble.currentScene:gameWillPause()
	end
end
function playdate.gameWillResume()
	if (Noble.currentScene ~= nil) then
		Noble.currentScene:gameWillResume()
	end
end