--- Input manager.
-- @module Noble.Input
--
Noble.Input = {}

local currentHandler = {}

--- Get the currently active input handler. Returns nil if none are active.
-- @treturn table A table of callbacks which handle input events.
function Noble.Input.getHandler()
	return currentHandler
end

--- Use this to change the active inputHandler. Enter nil to disable input.
-- @tparam[opt=nil] table __inputHandler A table of callbacks which handle input events.
-- @see NobleScene.inputHandler
function Noble.Input.setHandler(__inputHandler)
	--if (__inputHandler ~= nil) then printTable(__inputHandler) end

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
function Noble.Input.disable()
	Noble.Input.setHandler()
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
	crankIndicatorForced = __evenWhenUndocked or false
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

-- Do not call this method directly, or modify it, thanks. :-)
function Noble.Input.update()
	if (currentHandler == nil) then return end
	if (currentHandler.AButtonHold ~= nil) then
		if (playdate.buttonIsPressed(playdate.kButtonA)) then
			if (AButtonHoldBufferCount == buttonHoldBufferAmount) then currentHandler.AButtonHold()		-- Execute!
			else AButtonHoldBufferCount = AButtonHoldBufferCount + 1 end								-- Wait another frame!
		end
		if (playdate.buttonJustReleased(playdate.kButtonA)) then AButtonHoldBufferCount = 0 end			-- Reset!
	end
	if (currentHandler.BButtonHold ~= nil) then
		if (playdate.buttonIsPressed(playdate.kButtonB)) then
			if (BButtonHoldBufferCount == buttonHoldBufferAmount) then currentHandler.BButtonHold()
			else BButtonHoldBufferCount = BButtonHoldBufferCount + 1 end
		end
		if (playdate.buttonJustReleased(playdate.kButtonB)) then BButtonHoldBufferCount = 0 end
	end
	if (currentHandler.upButtonHold ~= nil) then
		if (playdate.buttonIsPressed(playdate.kButtonUp)) then
			if (upButtonHoldBufferCount == buttonHoldBufferAmount) then currentHandler.upButtonHold()
			else upButtonHoldBufferCount = upButtonHoldBufferCount + 1 end
		end
		if (playdate.buttonJustReleased(playdate.kButtonUp)) then upButtonHoldBufferCount = 0 end
	end
	if (currentHandler.downButtonHold ~= nil) then
		if (playdate.buttonIsPressed(playdate.kButtonDown)) then
			if (downButtonHoldBufferCount == buttonHoldBufferAmount) then currentHandler.downButtonHold()
			else downButtonHoldBufferCount = downButtonHoldBufferCount + 1 end
		end
		if (playdate.buttonJustReleased(playdate.kButtonDown)) then downButtonHoldBufferCount = 0 end
	end
	if (currentHandler.leftButtonHold ~= nil) then
		if (playdate.buttonIsPressed(playdate.kButtonLeft)) then
			if (leftButtonHoldBufferCount == buttonHoldBufferAmount) then currentHandler.leftButtonHold()
			else leftButtonHoldBufferCount = leftButtonHoldBufferCount + 1 end
		end
		if (playdate.buttonJustReleased(playdate.kButtonLeft)) then leftButtonHoldBufferCount = 0 end
	end
	if (currentHandler.rightButtonHold ~= nil) then
		if (playdate.buttonIsPressed(playdate.kButtonRight)) then
			if (rightButtonHoldBufferCount == buttonHoldBufferAmount) then currentHandler.rightButtonHold()
			else rightButtonHoldBufferCount = rightButtonHoldBufferCount + 1 end
		end
		if (playdate.buttonJustReleased(playdate.kButtonRight)) then rightButtonHoldBufferCount = 0 end
	end
end

-- Do not call this method directly, or modify it, thanks. :-)
function playdate.crankDocked()
	if (currentHandler.crankDocked ~= nil) then
		currentHandler.crankDocked()
	end
end

-- Do not call this method directly, or modify it, thanks. :-)
function playdate.crankUndocked()
	if (currentHandler.crankUndocked ~= nil) then
		currentHandler.crankDocked()
	end
end

--- Constants
-- . A set of constants referencing device inputs, stored as strings. Can be used for querying button input,
-- but are mainly for on-screen prompts or other elements where a string literal is useful, such as a filename or GameData value.
-- For faster performance, use the ones that exist in the Playdate SDK (i.e.: `playdate.kButtonA`), which are stored as binary values.
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