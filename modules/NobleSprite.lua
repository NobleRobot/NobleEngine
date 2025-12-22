---
-- An extension of Playdate's sprite object, incorporating `Noble.Animation` and other Noble Engine features.
-- Use this in place of `playdate.graphics.sprite` in most cases.
--
-- `NobleSprite` is a child class of `playdate.graphics.sprite`, so see the Playdate SDK documentation for additional methods and properties.
--
-- @classmod NobleSprite
--

NobleSprite = {}
class("NobleSprite").extends(Graphics.sprite)

--- Do not call an "init" method directly. Use `NobleSprite()` (see usage examples).
-- @string[opt] __view This can be: the path to an image or spritesheet image file, an image object (`Graphics.image`) or an animation object (`Noble.Animation`)
-- @bool[opt=false] __viewIsSpritesheet Set this to `true` to indicate that `__view` is a spritesheet. Will only be considered if `__view` is a string path to an image.
-- @bool[opt=false] __singleState If this sprite has just one animation, set this to true. It saves you from having to use Noble.Animation.addState()
-- @bool[opt=true] __singleStateLoop If using a single state animation, should it loop?
--
-- @usage
--	-- Provide a spritesheet image file to create a new `Noble.Animation` for a NobleSprite's view.
--	myNobleSprite = NobleSprite("path/to/spritesheet", true)
--
-- @usage
--	-- Provide an image file to create a new `Graphics.image` for a NobleSprite's view.
--	myNobleSprite = NobleSprite("path/to/image")
--
-- @usage
--	-- Use an existing `Noble.Animation` for a NobleSprite's view.
-- 	local myAnimation = Noble.Animation.new("path/to/spritesheet")
--  myAnimation:addState("default", 1, animation.imageTable:getLength(), nil, true)
--	myNobleSprite = NobleSprite(myAnimation)
--
-- @usage
--	-- Use an existing `Graphics.image` object for a NobleSprite's view.
--  local myImage = Graphics.image.new("path/to/image")
--	myNobleSprite = NobleSprite(myImage)
--
-- @usage
--	-- Extending NobleSprite.
--
--	-- MyCustomSprite.lua
--	MyCustomSprite = {}
--	class("MyCustomSprite").extends(NobleSprite)
--
--	function MyCustomSprite:init(__x, __y, __anotherFunArgument)
--		MyCustomSprite.super.init(self, "path/to/spritesheet", true)
--		-- Etc. etc.
--	end
--
--	-- MyNobleScene.lua
--	myNobleSprite = MyCustomSprite(100, 100, "Fun!")
--
-- @see Noble.Animation:addState
-- @see Noble.Animation.new
--
function NobleSprite:init(__view, __viewIsSpritesheet, __singleState, __singleStateLoop)
	NobleSprite.super.init(self)
	self.isNobleSprite = true -- This is important so other methods don't confuse this for a playdate.graphics.sprite. DO NOT modify this value at runtime.

	if (__view ~= nil) then

		-- __view is the path to an image or spritesheet file.
		if (type(__view) == "string") then
			self.animated = __viewIsSpritesheet -- NO NOT modify self.animated at runtime.

			if (__viewIsSpritesheet == true) then
				-- Create a new Noble.Animation object.

				--- The animation for this NobleSprite.
				-- @see Noble.Animation.new
				self.animation = Noble.Animation.new(__view)

				local singleStateLoop = true
				if (__singleStateLoop ~= nil) then singleStateLoop = __singleStateLoop end

				if (__singleState == true) then
					self.animation:addState("default", 1, self.animation.imageTable:getLength(), nil, singleStateLoop)
				end

			else
				-- Create a new Graphics.image object.
				self:setImage(Graphics.image.new(__view))
			end

		-- __view is an existing Graphics.image object.
		elseif (type(__view) == "userdata") then
			self.animated = false
			self:setImage(__view)

		-- __view is an existing Noble.Animation object.
		elseif (type(__view) == "table") then
			self.animated = true
			self.animation = __view
		end

	end

end

function NobleSprite:update()
	if (self.animation ~= nil) then
		self:markDirty()
	end
end

function NobleSprite:draw()
	if (self.animation ~= nil) then
		self.animation:draw()
	end
end

--- This will enable the update loop for this NobleSprite, which also causes its Noble.Animation to play.
function NobleSprite:play()
	self:setUpdatesEnabled(true)
end

--- This will disable the update loop for this NobleSprite, which also causes its Noble.Animation to pause.
function NobleSprite:pause()
	self:setUpdatesEnabled(false)
	if (self.animation ~= nil) then
		self:markDirty()
	end
end

--- This will disable the update loop for this NobleSprite, and also reset its Noble.Animation (if it exists) to the first frame of its current state.
function NobleSprite:stop()
	self:setUpdatesEnabled(false)
	if (self.animation ~= nil) then
		self.animation.currentFrame = self.animation.current.startFrame
		self:markDirty()
	end
end

--- Use this to add this NobleSprite to your scene. This replaces `playdate.graphics.sprite:add()` to allow NobleSprites to be tracked by the current NobleScene.
--
-- To add a `playdate.graphics.sprite` to a scene, use `NobleScene:addSprite(__sprite)`.
-- @see NobleScene:addSprite
function NobleSprite:add(__x, __y)
	local x = __x or self.x
	local y = __y or self.y
	self:moveTo(x, y)
	Noble.currentScene():addSprite(self)
end

function NobleSprite:superAdd()
	NobleSprite.super.add(self)
end

--- Use this to remove this NobleSprite from your scene. This replaces `playdate.graphics.sprite:remove()` to allow NobleSprites to be tracked by the current NobleScene.
--
-- To remove a `playdate.graphics.sprite` from a scene, use `NobleScene:removeSprite(__sprite)`.
-- @see NobleScene:removeSprite
function NobleSprite:remove()
	if (self.animation ~= nil) then
		self:stop()
		self:setUpdatesEnabled(true)	-- reset!
	end
	Noble.currentScene():removeSprite(self)
end

function NobleSprite:superRemove()
	NobleSprite.super.remove(self)
end