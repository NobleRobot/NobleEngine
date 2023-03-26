--- A complete encapsulation of the Playdate's input system. The Playdate SDK gives developers multiple ways to manage input. Noble Engine's approach revolves around the SDK's "inputHandlers," extending them to include additional input methods, and pull in other hardware functions that the SDK puts elsewhere. See usage below for the full list of supported methods.
-- <br><br>By default, Noble Engine assumes each scene will have an inputManager assigned to it. So, for example, you can define one inputManager for menu screens and another for gameplay scenes in your `main.lua`, and then in each scene, set which one that scene uses. You can instead define a unique inputHandler in each scene.
-- <br><br>You may also create and manage inputManagers within and outside of scenes. When a NobleScene is loaded, its inputHandler will become active, thus, inputHandlers do not carry across scenes, and all input is suspended during scene transitions. An advanced use-case is to leave a scene's inputHandler as nil, and manage it separately.
-- <br><br><strong>NOTE:</strong> While the Playdate SDK allows you to stack as many inputHandlers as you want, Noble Engine assumes only one <em>active</em> inputHandler at a time. You may still manually call `playdate.inputHandlers.push()` and `playdate.inputHandlers.pop()` yourself, but Noble Engine will not know about it and it may cause unexpected behavior.
-- <br><br>In addition, you may directly query button status using the SDK's methods for that, but it is not advised to use that as the primary way to manage input for Noble Engine projects, because much of Noble.Input's functionality will not apply.
-- @module Noble.Input
-- @usage
--	local myInputHandler = {
--		AButtonDown = function() end,	-- Fires once when button is pressed down.
--		AButtonHold = function() end,	-- Fires each frame while a button is held (Noble Engine implementation).
--		AButtonHeld = function() end,	-- Fires once after button is held for 1 second (available for A and B).
--		AButtonUp = function() end,		-- Fires once when button is released.
--		BButtonDown = function() end,
--		BButtonHold = function() end,
--		BButtonHeld = function() end,
--		BButtonUp = function() end,
--		downButtonDown = function() end,
--		downButtonHold = function() end,
--		downButtonUp = function() end,
--		leftButtonDown = function() end,
--		leftButtonHold = function() end,
--		leftButtonUp = function() end,
--		rightButtonDown = function() end,
--		rightButtonHold = function() end,
--		rightButtonUp = function() end,
--		upButtonDown = function() end,
--		upButtonHold = function() end
--		upButtonUp = function() end,
--
--		cranked = function(change, acceleratedChange) end,	-- See Playdate SDK.
--		crankDocked = function() end,						-- Noble Engine implementation.
--		crankUndocked = function() end,						-- Noble Engine implementation.
--
--		orientationChanged = function() end					-- Noble Engine implementation.
--	}
-- @see NobleScene.inputHandler
--
Noble.Input = {}

local currentHandler = {}

--- Get the currently active input handler. Returns nil if none are active.
-- @treturn table A table of callbacks which handle input events.
-- @see NobleScene.inputHandler
function Noble.Input.getHandler()
	return currentHandler
end

--- Use this to change the active inputHandler.
-- <br><br>Enter `nil` to disable input. Use @{setEnabled} to disable/enable input without losing track of the current inputHandler.
-- @tparam[opt=nil] table __inputHandler A table of callbacks which handle input events.
-- @see NobleScene.inputHandler
-- @see clearHandler
-- @see setEnabled
function Noble.Input.setHandler(__inputHandler)
	if (currentHandler ~= nil) then
		playdate.inputHandlers.pop()
	end

	if (__inputHandler == nil) then
		currentHandler = nil
	else
		currentHandler = __inputHandler
		playdate.inputHandlers.push(__inputHandler, true)	-- The Playdate SDK allows for multiple inputHandlers to mix and match methods. Noble Engine removes this functionality.
	end
end

--- A helper function that calls Noble.Input.setHandler() with no argument.
-- @see setHandler
function Noble.Input.clearHandler()
	Noble.Input.setHandler()
end

local cachedInputHandler = nil

--- Enable and disable user input without dealing with inputHanders.
-- The Playdate SDK requires removing all inputHanders to halt user input, so while the currentHandler is cleared when `false` is passed to this method,
-- it is cached so it can be later re-enabled by passing `true` it.
-- @bool __value Set to false to halt input. Set to true to resume accepting input.
-- @see getHandler
-- @see clearHandler
function Noble.Input.setEnabled(__value)
	local value = Utilities.handleOptionalBoolean(__value, true)
	if (value == true) then
		Noble.Input.setHandler(cachedInputHandler or currentHandler)
		cachedInputHandler = nil
	else
		cachedInputHandler = currentHandler
		Noble.Input.clearHandler()
	end
end

--- Checks to see that there is an active inputHandler
-- @treturn bool Returns true if the input system is enabled. Returns false if `setEnabled(false)` was used, or if currentHandler is `nil`.
function Noble.Input.getEnabled()
	return cachedInputHandler == nil
end

local crankIndicatorActive = false
local crankIndicatorForced = false

--- Enable/disable on-screen system crank indicator.
--
-- <strong>NOTE: The indicator will only ever show if the crank is docked, unless `__evenWhenUndocked` is true.</strong>
-- @bool __active Set true to start showing the on-screen crank indicator. Set false to stop showing it.
-- @bool[opt=false] __evenWhenUndocked Set true to show the crank indicator even if the crank is already undocked (`__active` must also be true).
function Noble.Input.setCrankIndicatorStatus(__active, __evenWhenUndocked)
	if (__active) then
		UI.crankIndicator:start()
	end
	crankIndicatorActive = __active
	crankIndicatorForced = Utilities.handleOptionalBoolean(__evenWhenUndocked, false)
end

--- Checks whether the system crank indicator status. Returns a tuple.
--
-- @treturn bool Is the crank indicator active?
-- @treturn bool Is the crank indicator being forced when active, even when the crank is undocked?
-- @see setCrankIndicatorStatus
function Noble.Input.getCrankIndicatorStatus()
	return crankIndicatorActive, crankIndicatorForced
end

-- Noble Engine defines extra "buttonHold" methods that run every frame that a button is held down, but to implement them, we need to do some magic.
local buttonHoldBufferAmount = 3 -- This is how many frames to wait before the engine determines that a button is being held down. Using !buttonJustPressed() provides only 1 frame, which isn't enough.

local AButtonHoldBufferCount = 0
local BButtonHoldBufferCount = 0
local upButtonHoldBufferCount = 0
local downButtonHoldBufferCount = 0
local leftButtonHoldBufferCount = 0
local rightButtonHoldBufferCount = 0

-- Store the latest orientation in order to know when to run the orientationChanged callback
local orientation = nil
local accelerometerValues = nil

--- Checks the current display orientation of the device. Returns a tuple.
-- If the accelerometer is not currently enabled, this method will turn it on, return current values, and then turn it off.
-- If you are trying to get raw accelerometer values rather than the display orientation, you may want to use `playdate.readAccelerometer()` instead.
-- @bool[opt=false] __getStoredValues If true, this method will simply return the most recently stored values, rather than use the accelerometer to check for new ones.
-- @treturn str The named orientation of the device (a pseudo enum Noble.Input.ORIENTATION_XX)
-- @treturn list Accelerometer values, where list[1] is x, list[2] is y and list[3] is z
-- @see Noble.Input.ORIENTATION_UP
-- @see Noble.Input.ORIENTATION_DOWN
-- @see Noble.Input.ORIENTATION_LEFT
-- @see Noble.Input.ORIENTATION_RIGHT
function Noble.Input.getOrientation(__getStoredValues)

	local getStoredValues = Utilities.handleOptionalBoolean(__getStoredValues, false)
	if (not getStoredValues) then

		local turnOffAfterUse = false
		if (not playdate.accelerometerIsRunning()) then
			playdate.startAccelerometer()
			turnOffAfterUse = true
		end

		local x, y, z = playdate.readAccelerometer()

		if (turnOffAfterUse) then
			playdate.stopAccelerometer()
		end

		local newOrientation = nil

		if (x <= -0.7) then
			newOrientation = Noble.Input.ORIENTATION_LEFT
		elseif (x >= 0.7) then
			newOrientation = Noble.Input.ORIENTATION_RIGHT
		elseif (y <= -0.3) then
			newOrientation = Noble.Input.ORIENTATION_DOWN
		else
			newOrientation = Noble.Input.ORIENTATION_UP
		end

		accelerometerValues = {x, y, z}

		if (newOrientation ~= orientation) then
			if (currentHandler.orientationChanged ~= nil) then
				currentHandler.orientationChanged(orientation, accelerometerValues)
			end
			orientation = newOrientation
		end
	end

	return orientation, accelerometerValues

end

-- Do not call this method directly, or modify it, thanks. :-)
function Noble.Input.update()

	if (currentHandler == nil) then return end

	if (currentHandler.AButtonHold ~= nil) then
		if (playdate.buttonIsPressed(playdate.kButtonA)) then
			if (AButtonHoldBufferCount >= buttonHoldBufferAmount) then currentHandler.AButtonHold(AButtonHoldBufferCount) end		-- Execute!
			AButtonHoldBufferCount = AButtonHoldBufferCount + 1																		-- Wait another frame!
		end
		if (playdate.buttonJustReleased(playdate.kButtonA)) then AButtonHoldBufferCount = 0 end										-- Reset!
	end
	if (currentHandler.BButtonHold ~= nil) then
		if (playdate.buttonIsPressed(playdate.kButtonB)) then
			if (BButtonHoldBufferCount >= buttonHoldBufferAmount) then currentHandler.BButtonHold(BButtonHoldBufferCount) end
			BButtonHoldBufferCount = BButtonHoldBufferCount + 1
		end
		if (playdate.buttonJustReleased(playdate.kButtonB)) then BButtonHoldBufferCount = 0 end
	end
	if (currentHandler.upButtonHold ~= nil) then
		if (playdate.buttonIsPressed(playdate.kButtonUp)) then
			if (upButtonHoldBufferCount >= buttonHoldBufferAmount) then currentHandler.upButtonHold(upButtonHoldBufferCount) end
			upButtonHoldBufferCount = upButtonHoldBufferCount + 1
		end
		if (playdate.buttonJustReleased(playdate.kButtonUp)) then upButtonHoldBufferCount = 0 end
	end
	if (currentHandler.downButtonHold ~= nil) then
		if (playdate.buttonIsPressed(playdate.kButtonDown)) then
			if (downButtonHoldBufferCount >= buttonHoldBufferAmount) then currentHandler.downButtonHold(downButtonHoldBufferCount) end
			downButtonHoldBufferCount = downButtonHoldBufferCount + 1
		end
		if (playdate.buttonJustReleased(playdate.kButtonDown)) then downButtonHoldBufferCount = 0 end
	end
	if (currentHandler.leftButtonHold ~= nil) then
		if (playdate.buttonIsPressed(playdate.kButtonLeft)) then
			if (leftButtonHoldBufferCount >= buttonHoldBufferAmount) then currentHandler.leftButtonHold(leftButtonHoldBufferCount) end
			leftButtonHoldBufferCount = leftButtonHoldBufferCount + 1
		end
		if (playdate.buttonJustReleased(playdate.kButtonLeft)) then leftButtonHoldBufferCount = 0 end
	end
	if (currentHandler.rightButtonHold ~= nil) then
		if (playdate.buttonIsPressed(playdate.kButtonRight)) then
			if (rightButtonHoldBufferCount >= buttonHoldBufferAmount) then currentHandler.rightButtonHold(rightButtonHoldBufferCount) end
			rightButtonHoldBufferCount = rightButtonHoldBufferCount + 1
		end
		if (playdate.buttonJustReleased(playdate.kButtonRight)) then rightButtonHoldBufferCount = 0 end
	end
	if (playdate.accelerometerIsRunning()) then
		Noble.Input.getOrientation()
	end
end

-- Do not call this method directly, or modify it, thanks. :-)
function playdate.crankDocked()
	if (currentHandler ~= nil and currentHandler.crankDocked ~= nil and Noble.Input.getEnabled() == true) then
		currentHandler.crankDocked()
	end
end

-- Do not call this method directly, or modify it, thanks. :-)
function playdate.crankUndocked()
	if (currentHandler ~= nil and currentHandler.crankUndocked ~= nil and Noble.Input.getEnabled() == true) then
		currentHandler.crankUndocked()
	end
end

--- Constants
-- . A set of constants referencing device inputs, stored as strings. Can be used for querying button input,
-- but are mainly for on-screen prompts or other elements where a string literal is useful, such as a filename, GameData value, or localization key.
-- For faster performance, use the ones that exist in the Playdate SDK (i.e.: `playdate.kButtonA`), which are stored as binary numbers.
-- @usage
--	function newPrompt(__input, __promptString)
--		-- ...
--		local icon = Graphics.image.new("assets/images/UI/Icon_" .. __input)
--		-- ...
--	end
--
--	promptMove = newPrompt(Noble.Input.DPAD_HORIZONTAL, "Move!")				-- assets/images/UI/Icon_dPadHorizontal.png"
--	promptJump = newPrompt(Noble.Input.BUTTON_A, "Jump!") 						-- assets/images/UI/Icon_buttonA.png"
--	promptCharge = newPrompt(Noble.Input.CRANK_FORWARD, "Charge the battery!")	-- assets/images/UI/Icon_crankForward.png"
-- @section constants

--- `"buttonA"`
Noble.Input.BUTTON_A = "buttonA"
--- `"buttonB"`
Noble.Input.BUTTON_B = "buttonB"
--- The system menu button.
--
-- `"buttonMenu"`
Noble.Input.BUTTON_MENU = "buttonMenu"

--- Referencing the D-pad component itself, rather than an input.
--
-- `"dPad"`
Noble.Input.DPAD = "dPad"
--- Referencing the left and right input D-pad inputs.
--
-- `"dPadHorizontal"`
Noble.Input.DPAD_HORIZONTAL = "dPadHorizontal"
--- Referencing the up and down input D-pad inputs.
--
-- `"dPadVertical"`
Noble.Input.DPAD_VERTICAL = "dPadVertical"
--- `"dPadUp"`
Noble.Input.DPAD_UP = "dPadUp"
--- `"dPadDown"`
Noble.Input.DPAD_DOWN = "dPadDown"
--- `"dPadLeft"`
Noble.Input.DPAD_LEFT = "dPadLeft"
--- `"dPadRight"`
Noble.Input.DPAD_RIGHT = "dPadRight"

--- Referencing the crank component itself, rather than an input.
--
-- `"crank"`
Noble.Input.CRANK = "crank"
--- AKA: Clockwise. See Playdate SDK.
--
-- `"crankForward"`
Noble.Input.CRANK_FORWARD = "crankForward"
--- AKA: Anticlockwise. See Playdate SDK.
--
-- `"crankReverse"`
Noble.Input.CRANK_REVERSE = "crankReverse"
--- Referencing the action of docking the crank.
--
-- `"crankDock"`
Noble.Input.CRANK_DOCK = "crankDock"
--- Referencing the action of undocking the crank.
--
-- `"crankUndock"`
Noble.Input.CRANK_UNDOCK = "crankUndock"

--- Referencing the display orientations.
--
-- `"orientationUp"`
Noble.Input.ORIENTATION_UP = "orientationUp"
-- `"orientationDown"`
Noble.Input.ORIENTATION_DOWN = "orientationDown"
-- `"orientationLeft"`
Noble.Input.ORIENTATION_LEFT = "orientationLeft"
-- `"orientationRight"`
Noble.Input.ORIENTATION_RIGHT = "orientationRight"