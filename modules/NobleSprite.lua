---
-- An extention of Playdate's sprite object, incorporating `Noble.Animation` and other Noble Engine features.
-- Use this in place of `playdate.graphics.sprite` in most cases.
--
-- `NobleSprite` is a child class of `playdate.graphics.sprite`, so see the Playdate SDK documentation for additional methods and properties.
--
-- @classmod NobleSprite
--

NobleSprite = {}
class("NobleSprite").extends(Graphics.sprite)

--- Do not call an "init" method directly. Use `NobleSprite()` (see usage examples).
-- @string[opt] __imageOrSpritesheet The path to the image or spritesheet asset that this NobleSprite will use for its view.
-- @bool[opt=false] __animated Set this to `true` in order to use Noble.Animation.
-- @bool[opt=false] __singleState If this sprite has just one animation, set this to true. It saves you from having to use Noble.Anmiation.addState()
-- @bool[opt=true] __singleStateLoop If using a single state animation, should it loop?
--
-- @usage
--	-- Create a new NobleSprite, using a static image for its view.
--	mySprite = NobleSprite("path/to/image")
--
-- @usage
--	-- Create a new NobleSprite, using a Noble.Animation for its view.
--	mySprite = NobleSprite("path/to/spritesheet", true)
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
--	mySprite = MyCustomSprite(100, 100, "Fun!")
--
-- @see Noble.Animation:addState
--
function NobleSprite:init(__imageOrSpritesheet, __animated, __singleState, __singleStateLoop)
	NobleSprite.super.init(self)
	self.isNobleSprite = true -- This is important so other methods don't confuse this for a playdate.graphics.sprite. DO NOT modify this value at runtime.

	self.animated = __animated	-- NO NOT modify this value at runtime.

	if (__imageOrSpritesheet ~= nil) then
		if (__animated == true) then
			-- This sprite uses Noble.Animation for its "view."

			--- The animation for this NobleSprite.
			-- @see Noble.Animation.new
			self.animation = Noble.Animation.new(__imageOrSpritesheet)

			local singleStateLoop = true
			if (__singleStateLoop ~= nil) then singleStateLoop = __singleStateLoop end

			if (__singleState == true) then
				self.animation:addState("default", 1, self.animation.imageTable:getLength(), nil, singleStateLoop)
			end

		else
			-- This sprite uses playdate.graphics.image for its "view."
			self:setImage(Graphics.image.new(__imageOrSpritesheet))
		end
	end
end

function NobleSprite:draw(__x, __y)
	if (self.animation ~= nil) then
		local x = __x or 0
		local y = __y or 0
		self.animation:draw(x, y)
		self:markDirty()
	end
end

--- This will enable the update loop for this NobleSprite, which also causes its Noble.Animation to play.
function NobleSprite:play()
	self:setUpdatesEnabled(true)
end

--- This will disable the update loop for this NobleSprite, which also causes its Noble.Animation to pause.
function NobleSprite:pause()
	self:setUpdatesEnabled(false)
end

--- This will disable the update loop for this NobleSprite, and also reset its Noble.Animation (if it exists) to the first frame of its current state.
function NobleSprite:stop()
	self:setUpdatesEnabled(false)
	if (self.animation ~= nil) then
		self.animation.currentFrame = self.animation.current.startFrame
	end
end

--- Use this to add this NobleSprite to your scene. This replaces `playdate.graphics.sprite:add()` to allow NobleSprites to be tracked by the current NobleScene.
--
-- To add a `playdate.graphics.sprite` to a scene, use `NobleScene:addSprite(__sprite)`.
-- @see NobleScene:addSprite
function NobleSprite:add(__x, __y)
	local x = __x or 0
	local y = __y or 0
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