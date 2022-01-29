--
-- SceneTemplate.lua
--
-- Use this as a starting point for your game's scenes. Copy this file to your root "scenes" directory,
-- rename it as you like, and then replace all instances of "SceneTemplate" with your scene's name.
--

SceneTemplate = {}
class("SceneTemplate").extends(NobleScene)

-- It is recommended that you declare, but don't yet define, your scene-specific varibles and methods here. Use "local" where possible.
--
-- local variable1 = nil
-- SceneTemplate.variable2 = nil
-- ...
--

SceneTemplate.backgroundColor = Graphics.kColorWhite		-- This is the background color of this scene.

-- This runs when your scene's object is created, which is the first thing that happens when transitining away from another scene.
function SceneTemplate:init()
	SceneTemplate.super.init(self)

	-- variable1 = 100
	-- SceneTemplate.variable2 = "string"
	-- ...

	-- Your code here
end

-- When transitioning from another scene, this runs as soon as this scene needs to be visible (this moment depends on which transition type is used).
function SceneTemplate:enter()
	SceneTemplate.super.enter(self)
	-- Your code here
end

-- This runs once a transition from another scene is complete.
function SceneTemplate:start()
	SceneTemplate.super.start(self)
	-- Your code here
end

-- This runs once per frame.
function SceneTemplate:update()
	SceneTemplate.super.update(self)
	-- Your code here
end

-- This runs once per frame, and is meant for drawing code.
function SceneTemplate:drawBackground()
	SceneTemplate.super.drawBackground(self)
	-- Your code here
end

-- This runs as as soon as a transition to another scene begins.
function SceneTemplate:exit()
	SceneTemplate.super.exit(self)
	-- Your code here
end

-- This runs once a transition to another scene completes.
function SceneTemplate:finish()
	SceneTemplate.super.finish(self)
	-- Your code here
end

function SceneTemplate:pause()
	SceneTemplate.super.pause(self)
	-- Your code here
end
function SceneTemplate:resume()
	SceneTemplate.super.resume(self)
	-- Your code here
end

-- You can define this here, or within your scene's init() function.
SceneTemplate.inputHandler = {

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