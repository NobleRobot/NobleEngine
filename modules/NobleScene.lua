---
-- An abstract scene class.
-- Do not copy this file as a template for your scenes. Instead, your scenes will extend this class.
-- See <a href="../examples/SceneTemplate.lua.html">templates/SceneTemplate.lua</a> for a blank scene that you can copy and modify for your own scenes.
-- If you are using <a href="http://github.com/NobleRobot/NobleEngine-ProjectTemplate">NobleEngine-ProjectTemplate</a>,
-- see `scenes/ExampleScene.lua` for an implementation example.
-- @usage
--	YourSceneName = {}
--	class("YourSceneName").extends(NobleScene)
--
-- @classmod NobleScene
--

NobleScene = {}
class("NobleScene").extends(Object)

--- Properties
-- @section properties

--- The name of this scene. Optional.
-- If you do not set this value, it will take on the scene's `className`.
NobleScene.name = ""

--- This is the background color of this scene.
--
NobleScene.baseColor = Graphics.kColorWhite

--- Tables
-- @section tables

--- All scenes have a default inputHandler which is made active when the scene starts.
-- If you do not define your scene's `inputHandler`, it is `nil` and input is disabled when this scene
-- starts.
-- @see Noble.Input.setHandler
--
-- @usage
--	YourSceneName.inputHandler = {
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
--	}
--	-- OR...
--	-- Use a non-scene-specific inputHandler, defined elsewhere.
--	YourSceneName.inputHandler = somePreviouslyDefinedInputHandler
--	-- OR...
--	-- Reuse another scene's inputHandler.
--	YourSceneName.inputHandler = SomeOtherSceneName.inputHandler
NobleScene.inputHandler = {}

--- Callbacks
-- @section callbacks

--- Implement this in your scene if you have code to run when your scene's object is created.
--
-- @usage
--	function YourSceneName:init()
--		YourSceneName.super.init(self)
--		--[Your code here]--
--	end
--
function NobleScene:init()
	self.name = self.className
end

--- Implement if you want to run code as the transition to this scene begins, such as UI animation, triggers, etc.
--
-- @usage
--	function YourSceneName:enter()
--		YourSceneName.super.enter(self)
--		--[Your code here]--
--	end
--
function NobleScene:enter() end

--- Implement if you have code to run once the transition to this scene is complete. This method signifies the full activation of a scene. If this scene's `inputHandler` is defined, it is enabled now.
-- @see inputHandler
-- @usage
--	function YourSceneName:start()
--		YourSceneName.super.start(self)
--		--[Your code here]--
--	end
--
function NobleScene:start()
	Noble.Input.setHandler(self.inputHandler)
end

--- Implement to run scene-specific code on every frame while this scene is active.
-- NOTE: you may use coroutine.yield() here, because it only runs inside of playdate.update(), which is a coroutine.
--
-- @usage
--	function YourSceneName:update()
--		YourSceneName.super.update(self)
--		--[Your code here]--
--	end
--
function NobleScene:update() end

--- Implement this function to draw background visual elements in your scene. This runs every frame.
--
-- @usage
--	function YourSceneName:drawBackground()
--		YourSceneName.super.drawBackground(self)
--		--[Your code here]--
--	end
--
function NobleScene:drawBackground()
	Graphics.setColor(self.baseColor)
	Graphics.fillRect(0, 0, 400, 240)
end

--- Implement this in your scene if you have "goodbye" code to run when a transition to another scene
-- begins, such as UI animation, saving to disk, etc.
--
-- @usage
--	function YourSceneName:exit()
--		YourSceneName.super.exit(self)
--		--[Your code here]--
--	end
--
function NobleScene:exit() end

--- Implement this in your scene if you have code to run when a transition to another scene
-- is complete, such as resetting variables.
--
-- @usage
--	function YourSceneName:finish()
--		YourSceneName.super.finish(self)
--		--[Your code here]--
--	end
--
function NobleScene:finish() end

--- `pause()` / `resume()`
--
-- Implement one or both of these in your scene if you want something to happen when the game is paused/unpaused
-- by the system. The Playdate SDK does not require you to write pause logic, but these are useful if you want a
-- custom menu image (see Playdate SDK for more details), want to obscure game elements to prevent players from
-- cheating in a time-sensitive game, want to count the number of times the player pauses the game, etc.
--
-- @usage
--	function YourSceneName:pause()
--		YourSceneName.super.pause(self)
--		--[Your code here]--
--	end
function NobleScene:pause() end
--- <span></span>
-- @usage
--	function YourSceneName:resume()
--		YourSceneName.super.resume(self)
--		--[Your code here]--
--	end
function NobleScene:resume() end