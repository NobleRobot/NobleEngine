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
	if (__inputHandler ~= nil) then printTable(__inputHandler) end

	if (currentHandler ~= nil) then
		playdate.inputHandlers.pop()
	end

	if (__inputHandler == nil) then
		currentHandler = nil
	else
		currentHandler = __inputHandler
		playdate.inputHandlers.push(__inputHandler, true)	-- The Playdate SDK allows for multiple inputHanders to mix and match methods. Noble Engine removes this functionality.
	end
end

--- A helper function that calls Noble.Input.setHandler() with no argument.
-- @see setHandler
function Noble.Input.disable()
	Noble.Input.setHandler()
end

local crankIndicatorActive = false

--- Enable/disable on-screen crank indicator.
--
-- <strong>NOTE: The indicator will only ever show if the crank is docked.</strong>
-- @param __bool Set true to start showing the on-screen crank indicator. Set false to stop showing it.
function Noble.Input.activateCrankIndicator(__bool)
	if (__bool) then
		UI.crankIndicator:start()
	end
	crankIndicatorActive = __bool
end

--- Checks whethe the crank indicator has been activated via `activateCrankIndicator(true)`.
--
-- <strong>NOTE: The indicator will only ever show if the crank is docked.</strong>
-- @treturn bool
-- @see activateCrankIndicator
function Noble.Input.crankIndicatorActive()
	return crankIndicatorActive
end

-- Noble Engine defines extra "buttonHold" methods that run every frame that a button is held down, but to impliment them, we need to do some magic.
local buttonHoldBufferAmount = 3 -- This is how many frames to wait before the engine determines that a button is being held down. Using !buttonJustPressed() provides only 1 frame, which isn't enough.
local AButtonHoldBufferCount = 0
local BButtonHoldBufferCount = 0
local upButtonHoldBufferCount = 0
local downButtonHoldBufferCount = 0
local leftButtonHoldBufferCount = 0
local rightButtonHoldBufferCount = 0

-- Do not call this method directly, thanks.
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
function playdate.crankDocked()
	if (currentHandler.crankDocked ~= nil) then
		currentHandler.crankDocked()
	end
end
function playdate.crankUndocked()
	if (currentHandler.crankUndocked ~= nil) then
		currentHandler.crankDocked()
	end
end