--
-- SceneTemplate.lua
--
-- Use this as a starting point for your game's scenes. Copy this file to your root "scenes" directory,
-- rename it as you like.
--

SceneTemplate = {}
class("SceneTemplate").extends(NobleScene)
local S = SceneTemplate

-- It is recommended that you declare, but don't yet define, your scene-specific varibles and methods here. Use "local" where possible.
--
-- local variable1 = nil
-- S.variable2 = nil
-- ...
--

S.backgroundColor = Graphics.kColorWhite		-- This is the background color of this scene.

-- This runs when your scene's object is created, which is the first thing that happens when transitining away from another scene.
function S:init()
	S.super.init(self)

	-- variable1 = 100
	-- S.variable2 = "string"
	-- ...

	-- Your code here
end

-- When transitioning from another scene, this runs as soon as this scene needs to be visible (this moment depends on which transition type is used).
function S:enter()
	S.super.enter(self)
	-- Your code here
end

-- This runs once a transition from another scene is complete.
function S:start()
	S.super.start(self)
	-- Your code here
end

-- This runs once per frame.
function S:update()
	S.super.update(self)
	-- Your code here
end

-- This runs once per frame, and is meant for drawing code.
function S:drawBackground()
	S.super.drawBackground(self)
	-- Your code here
end

-- This runs as as soon as a transition to another scene begins.
function S:exit()
	S.super.exit(self)
	-- Your code here
end

-- This runs once a transition to another scene completes.
function S:finish()
	S.super.finish(self)
	-- Your code here
end

function S:pause()
	S.super.pause(self)
	-- Your code here
end
function S:resume()
	S.super.resume(self)
	-- Your code here
end

-- You can define this here, or within your scene's init() function.
S.inputHandler = {

	-- A button
	--
	AButtonDown = function()			-- Runs once when button is pressed.
		-- Your code here
	end,
	AButtonHold = function()			-- Runs every frame while the player is holding button down.
		-- Your code here
	end,
	AButtonHeld = function()			-- Runs after button is held for 1 second.
		-- Your code here
	end,
	AButtonUp = function()				-- Runs once when button is released.
		-- Your code here
	end,

	-- B button
	--
	BButtonDown = function()
		-- Your code here
	end,
	BButtonHeld = function()
		-- Your code here
	end,
	BButtonHold = function()
		-- Your code here
	end,
	BButtonUp = function()
		-- Your code here
	end,

	-- D-pad left
	--
	leftButtonDown = function()
		-- Your code here
	end,
	leftButtonHold = function()
		-- Your code here
	end,
	leftButtonUp = function()
		-- Your code here
	end,

	-- D-pad right
	--
	rightButtonDown = function()
		-- Your code here
	end,
	rightButtonHold = function()
		-- Your code here
	end,
	rightButtonUp = function()
		-- Your code here
	end,

	-- D-pad up
	--
	upButtonDown = function()
		-- Your code here
	end,
	upButtonHold = function()
		-- Your code here
	end,
	upButtonUp = function()
		-- Your code here
	end,

	-- D-pad down
	--
	downButtonDown = function()
		-- Your code here
	end,
	downButtonHold = function()
		-- Your code here
	end,
	downButtonUp = function()
		-- Your code here
	end,

	-- Crank
	--
	cranked = function(change, acceleratedChange)	-- Runs when the crank is rotated. See Playdate SDK documentation for details.
		-- Your code here
	end,
	crankDocked = function()						-- Runs once when when crank is docked.
		-- Your code here
	end,
	crankUndocked = function()						-- Runs once when when crank is undocked.
		-- Your code here
	end
}
