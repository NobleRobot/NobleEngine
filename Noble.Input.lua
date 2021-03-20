--- Input Handling
-- @module Noble.Input
--
Noble.Input = {}

--- The current input handler. Don't set this manually
-- @see Noble.Input.setHandler
--
Noble.Input.currentHandler = {}

--- Use this to change the active inputHandler.
-- @param __inputHandler table
-- @see NobleScene.inputHandler
function Noble.Input.setHandler(__inputHandler)
	print(__inputHandler)
	if (__inputHandler ~= nil) then printTable(__inputHandler) end

	if (Noble.Input.currentHandler ~= nil) then
		playdate.inputHandlers.pop()
	end

	if (__inputHandler == nil) then
		Noble.Input.currentHandler = nil
	else
		Noble.Input.currentHandler = __inputHandler
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

Noble.Input.update()
	local handler = Noble.Input.currentHandler
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