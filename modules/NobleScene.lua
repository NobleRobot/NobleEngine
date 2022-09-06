---
-- An abstract scene class.
-- Do not copy this file as a template for your scenes. Instead, your scenes will extend this class.
-- See <a href="../examples/SceneTemplate.lua.html">templates/SceneTemplate.lua</a> for a blank scene that you can copy and modify for your own scenes.
-- If you are using <a href="http://github.com/NobleRobot/NobleEngine-ProjectTemplate">NobleEngine-ProjectTemplate</a>,
-- see `scenes/ExampleScene.lua` for an implementation example.
-- @usage
--	YourSceneName = {}
--	class("YourSceneName").extends(NobleScene)
--	local scene = YourSceneName
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
NobleScene.backgroundColor = Graphics.kColorWhite

--- Tables
-- @section tables

--- All scenes have a default inputHandler which is made active when the scene starts.
-- If you do not define your scene's `inputHandler`, it is `nil` and input is disabled when this scene
-- starts.
-- @see Noble.Input.setHandler
--
-- @usage
--	YourSceneName.inputHandler = {
--		AButtonDown = function()
--			// Your code here
--		end,
--		AButtonHold = function()
--			// Your code here
--		end,
--		-- ...
--		-- ...
--	}
--	-- OR...
--	-- Use a non-scene-specific inputHandler, defined elsewhere.
--	YourSceneName.inputHandler = somePreviouslyDefinedInputHandler
--	-- OR...
--	-- Reuse another scene's inputHandler.
--	YourSceneName.inputHandler = SomeOtherSceneName.inputHandler
NobleScene.inputHandler = {}

--- When you add a sprite to your scene, it is put in this table so the scene can keep track of it.
--
-- This is intended as `read-only`. You should not modify this table directly.
-- @see addSprite
NobleScene.sprites = {}

--- Methods
-- @section Methods

--- Use this to add sprites to your scene instead of `playdate.graphics.sprite:add()`.
--
-- If your sprite is a `NobleSprite`, using `NobleSprite:add()` will also call this method.
--
-- Sprites added with this method that are tracked by the scene. Any not manually removed before transitioning to another scene are automatically removed in @{finish|finish}.
-- @tparam playdate.graphics.sprite __sprite The sprite to add to the scene.
-- @see NobleSprite:add
-- @see removeSprite
function NobleScene:addSprite(__sprite)
	if (__sprite.isNobleSprite == true) then
		__sprite:superAdd()
	else
		__sprite:add()
	end

	if (table.indexOfElement(self.sprites, __sprite) == nil) then
		table.insert(self.sprites, __sprite)
	end
end

--- Use this to remove sprites from your scene instead of `playdate.graphics.sprite:remove()`.
--
-- If your sprite is a `NobleSprite`, using `NobleSprite:remove()` will also call this method.
--
-- Sprites not manually removed before transitioning to another scene are automatically removed in @{finish|finish}.
-- @tparam playdate.graphics.sprite __sprite The sprite to add to the scene.
-- @see NobleSprite:remove
-- @see addSprite
function NobleScene:removeSprite(__sprite)
	if (__sprite.isNobleSprite == true) then
		__sprite:superRemove()
	else
		__sprite:remove()
	end

	if (table.indexOfElement(self.sprites, __sprite) ~= nil) then
		table.remove(self.sprites, table.indexOfElement(self.sprites, __sprite))
	end
end

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
	self.sprites = {}
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
-- <strong>NOTE:</strong> you may use coroutine.yield() here, because it only runs inside of playdate.update(), which is a coroutine.
--
-- @usage
--	function YourSceneName:update()
--		YourSceneName.super.update(self)
--		--[Your code here]--
--	end
--
function NobleScene:update() end

--- Implement this function to draw background visual elements in your scene.
--- This runs when the engine need to redraw a background area.
--- By default it runs every frame and fills the background with self.backgroundColor. All arguments are optional.
--- Use `Graphics.sprite.setAlwaysRedraw(false)` after `Noble.new()` to optimize partial redraw.
--
-- @usage
--	function YourSceneName:drawBackground(__x, __y, __width, __height)
--		YourSceneName.super.drawBackground(self) -- optional, invokes default behavior.
--		--[Your code here]--
--	end
--
function NobleScene:drawBackground(__x, __y, __width, __height)
	__x = __x or 0
	__y = __y or 0
	__width = __width or Display.getWidth()
	__height = __height or Display.getHeight()

	 -- Cache the currently set color/pattern.
	local color <const> = Graphics.getColor()
	local color_type <const> = type(color)

	-- Draw background.
	Graphics.setColor(self.backgroundColor)
	Graphics.fillRect(__x, __y, __width, __height)

	-- Reset color/pattern from cache.
	if color_type == 'number' then
		Graphics.setColor(color)
	elseif color_type == 'table' then
		Graphics.setPattern(color)
	end
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
function NobleScene:exit()
	for _, sprite in ipairs(self.sprites) do
		sprite:setUpdatesEnabled(false)
		sprite:setCollisionsEnabled(false)
	end
end

--- Implement this in your scene if you have code to run when a transition to another scene
-- is complete, such as resetting variables.
--
-- @usage
--	function YourSceneName:finish()
--		YourSceneName.super.finish(self)
--		--[Your code here]--
--	end
--
function NobleScene:finish()
	for _, sprite in ipairs(self.sprites) do
		if (sprite.isNobleSprite) then
			sprite:superRemove()
		else
			sprite:remove()
		end
	end
end

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